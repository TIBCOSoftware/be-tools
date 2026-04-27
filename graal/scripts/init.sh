#!/bin/bash

# Check if BE_HOME and APP_HOME are provided
if [ -z "$BE_HOME" ]; then
    echo "Error: BE_HOME is required."
    usage
fi

if [ -z "$APP_HOME" ]; then
    echo "Error: APP_HOME is required."
    usage
fi

# Validate if application home exists
if [ ! -d "$APP_HOME" ]; then
  echo "Error: Application home directory '$APP_HOME' does not exist."
  exit 1
fi

# Validate if be home exists
if [ ! -d "$BE_HOME" ]; then
  echo "Error: BE home directory '$BE_HOME' does not exist."
  exit 1
fi

LICENSE_PATH=$(grep -E '^java\.property\.TIB_ACTIVATION=' $BE_HOME/bin/be-engine.tra | cut -d'=' -f2)

# If licPath is found, print it
if [ -n "$LICENSE_PATH" ]; then
    echo "The value of java.property.TIB_ACTIVATION is: $LICENSE_PATH"
else
    echo "The property java.property.TIB_ACTIVATION is not found in the file. Setting it to default license path ~/license"
    LICENSE_PATH="~/license"
fi

PSP=:

# Function to extract EAR, find BAR and extract BE_JAR
extract_and_copy_be_jar() {
    local EAR_FILE=$1
    local APP_HOME=$2

    # Step 1: Check if EAR file exists
    if [ ! -f "$EAR_FILE" ]; then
        echo "Error: EAR file does not exist at $EAR_FILE"
        exit 1
    fi

    echo "Extracting EAR file: $EAR_FILE"

    # Step 2: Extract the EAR file to a temporary directory
    TEMP_DIR=$(mktemp -d)
    unzip -q "$EAR_FILE" -d "$TEMP_DIR"
    echo "Extracted EAR file to $TEMP_DIR"

    # Step 3: Find BAR files inside the EAR
    BAR_FILE=$(find "$TEMP_DIR" -type f -name "*.bar" | head -n 1)

    if [ -z "$BAR_FILE" ]; then
        echo "Error: No BAR file found inside the EAR."
        rm -rf "$TEMP_DIR"
        exit 1
    fi

    echo "Found BAR file: $BAR_FILE"

    # Step 4: Extract the BAR file to a temporary directory
    BAR_TEMP_DIR=$(mktemp -d)
    unzip -q "$BAR_FILE" -d "$BAR_TEMP_DIR"
    echo "Extracted BAR file to $BAR_TEMP_DIR"

    # Step 5: Find BE_JAR inside the BAR file
    BE_JAR=$(find "$BAR_TEMP_DIR" -type f -name "be.jar" | head -n 1)

    if [ -z "$BE_JAR" ]; then
        echo "Error: No be.jar found inside the BAR file."
        rm -rf "$TEMP_DIR"
        rm -rf "$BAR_TEMP_DIR"
        exit 1
    fi

    echo "Found be.jar: $BE_JAR"

    # Step 6: Create the appjar directory inside APP_HOME if it doesn't exist
    APPJAR_DIR="$APP_HOME/.graal/appjar"
    mkdir -p "$APPJAR_DIR"

    # Step 7: Copy be.jar to the appjar directory
    cp "$BE_JAR" "$APPJAR_DIR"
    echo "Copied be.jar to $APPJAR_DIR"

    # Clean up temporary directories
    rm -rf "$TEMP_DIR"
    rm -rf "$BAR_TEMP_DIR"
}

# Search for .cdd and .ear files in the cddear directory
CDD_FILE=$(find "$APP_HOME" -name "*.cdd" -print -quit)
EAR_FILE=$(find "$APP_HOME" -name "*.ear" -print -quit)

if [ -n "$CDD_FILE" ] && [ -n "$EAR_FILE" ]; then
    echo "Found .cdd file: $CDD_FILE"
    echo "Found .ear file: $EAR_FILE"
else
    echo "Error: .cdd or .ear file missing in $CDDEAR_DIR."
    exit 1
fi

if [ ! -f "$APP_HOME/.graal/appjar/be.jar" ]; then
  echo "be.jar not found in $APP_HOME/.graal/appjar. Extracting from EAR file..."
  extract_and_copy_be_jar "$EAR_FILE" "$APP_HOME"
fi

allJarsInPath(){
    DIRPATH=$1
    allFiles=`find $DIRPATH -type f`
    CPPATH=""
    for eachFile in $allFiles
    do
        if [[ "$eachFile" == *".jar" ]]; then
            CPPATH=$CPPATH$eachFile$PSP
        fi
    done
    echo $CPPATH
}

CP_PATH=`allJarsInPath $BE_HOME/lib`

CP_EXT_JARS=`allJarsInPath $EXTERNAL_JARS_PATH`
if [ "$CP_EXT_JARS" != "" ]; then
    CP_PATH=$CP_PATH$CP_EXT_JARS
fi

# add be.jar to classpath
CP_PATH=$CP_PATH$APP_HOME/.graal/appjar/be.jar

# exclude jars from CP_PATH
EXCLUDE_JARS=(
    "BE_HOME/lib/ext/tpcl/opentelemetry/exporters/grpc-netty-shaded.jar"
)
for eachJar in "${EXCLUDE_JARS[@]}"; do
    eachJar="${eachJar/BE_HOME/$BE_HOME}"
    CP_PATH=${CP_PATH/$eachJar$PSP/}
done

export LD_LIBRARY_PATH=$BE_HOME/lib:$LD_LIBRARY_PATH:$BE_HOME/lib/ext/tpcl:$BE_HOME/lib/ext/tibco:$BE_HOME/lib/ext/apache

# Apply classpath optimization if --optimize was requested.
# Reuses cloud/docker/lib/optimize.json and be_container_optimize.pl as single source of truth.
apply_cp_optimize() {
    [ -z "$OPTIMIZE_MODULES" ] && return

    # Resolve cloud/docker directory relative to this script's location
    local INIT_DIR
    INIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local DOCKER_DIR="$INIT_DIR/../../cloud/docker"

    if [ ! -f "$DOCKER_DIR/lib/optimize.json" ]; then
        echo "Warning: optimize.json not found at $DOCKER_DIR/lib/optimize.json. Skipping optimization."
        return
    fi
    if [ ! -f "$DOCKER_DIR/lib/be_container_optimize.pl" ]; then
        echo "Warning: be_container_optimize.pl not found at $DOCKER_DIR/lib/. Skipping optimization."
        return
    fi
    if ! command -v perl >/dev/null 2>&1; then
        echo "Warning: perl not found. Please install perl to use --optimize. Skipping optimization."
        return
    fi
    if [ -z "$CDD_FILE" ] || [ ! -f "$CDD_FILE" ] || [ -z "$EAR_FILE" ] || [ ! -f "$EAR_FILE" ]; then
        echo "Warning: CDD/EAR not available yet, skipping optimization."
        return
    fi

    # Step A: Auto-detect required modules from CDD/EAR first (base set)
    # Calls parse_optimize_modules directly via -e 'require' matching Docker's build_image.sh pattern
    echo "Auto-detecting required modules from CDD/EAR..."
    local auto_modules
    auto_modules=$(cd "$DOCKER_DIR" && perl -e 'require "./lib/be_container_optimize.pl"; print be_container_optimize::parse_optimize_modules("","'"$CDD_FILE"'","'"$EAR_FILE"'")')
    echo "Auto-detected modules: ${auto_modules:-none}"

    # Step B: Append any user-specified modules to the auto-detected base
    local user_modules="$OPTIMIZE_MODULES"
    [ "$user_modules" = "auto" ] && user_modules=""

    local final_modules="$auto_modules"
    if [ -n "$user_modules" ]; then
        if [ -n "$auto_modules" ]; then
            final_modules="$auto_modules,$user_modules"
        else
            final_modules="$user_modules"
        fi
        echo "User-specified modules appended: $user_modules"
    fi

    if [ -z "$final_modules" ]; then
        echo "Warning: No modules resolved for optimization. Skipping."
        return
    fi
    echo "Optimizing classpath for modules: $final_modules"

    # Generate the exclude-patterns file using the Perl script
    local EXCLUDE_FILE="$APP_HOME/.graal/cp-exclude.txt"
    mkdir -p "$APP_HOME/.graal"
    > "$EXCLUDE_FILE"
    (cd "$DOCKER_DIR" && perl -e 'require "./lib/be_container_optimize.pl"; be_container_optimize::prepare_delete_list("'"$final_modules"'","'"$EXCLUDE_FILE"'")')

    if [ ! -s "$EXCLUDE_FILE" ]; then
        echo "No JARs to exclude for the resolved modules."
        return
    fi

    # Filter CP_PATH: substitute BE_HOME placeholder, expand globs, strip matches
    local excluded_count=0
    while IFS= read -r pattern; do
        [ -z "$pattern" ] && continue
        local actual_pattern="${pattern/BE_HOME/$BE_HOME}"
        for actual_jar in $actual_pattern; do
            [ -f "$actual_jar" ] || continue
            if [[ "$CP_PATH" == *"${actual_jar}${PSP}"* ]]; then
                CP_PATH="${CP_PATH//${actual_jar}${PSP}/}"
                ((excluded_count++))
            fi
        done
    done < "$EXCLUDE_FILE"

    echo "Optimization complete: $excluded_count JAR(s) excluded from classpath."
}

apply_cp_optimize

# echo CP_PATH--$CP_PATH--
