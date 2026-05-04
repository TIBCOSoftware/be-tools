#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 -s <BE_HOME> -a <APP_HOME> [-t <IMAGE_NAME>]"
    echo "  -s <BE_HOME>            Path to BE Home (mandatory)"
    echo "  -a <APP_HOME>           Path to BE application directory with cdd and ear (mandatory)"
    echo "  -t <IMAGE_NAME>         Docker image name (default: be-graal-image)"
    echo "  -h                      Display this usage message"
    exit 1
}

# Parse command-line arguments
while getopts "s:a:t:h" opt; do
    case $opt in
        s) BE_HOME=$OPTARG ;;
        a) APP_HOME=$OPTARG ;;
        t) IMAGE_NAME=$OPTARG ;;
        h) usage ;;
        *) usage ;;
    esac
done

# Load environment variables (sets CDD_FILE, EAR_FILE, LD_LIBRARY_PATH)
source scripts/init.sh

IMAGE_NAME="${IMAGE_NAME:-be-graal-image}"

OUTPUT_PATH=$APP_HOME/.graal/bin/$(basename "$CDD_FILE" .cdd)
BIN_NAME=$(basename "$OUTPUT_PATH")
CDD_NAME=$(basename "$CDD_FILE")
EAR_NAME=$(basename "$EAR_FILE")

# Validate native binary exists
if [ ! -f "$OUTPUT_PATH" ]; then
    echo "Error: Native binary not found at $OUTPUT_PATH. Run 'be_graal.sh -n' first."
    exit 1
fi

# Verify cloud/docker/lib files are available
BE_DOCKER_RUN_DIR="../cloud/docker/lib"
if [ ! -f "$BE_DOCKER_RUN_DIR/be_docker_run.pm" ] || [ ! -f "$BE_DOCKER_RUN_DIR/run" ]; then
    echo "Error: cloud/docker/lib/be_docker_run.pm or run not found. Ensure cloud/docker is present alongside graal/."
    exit 1
fi

# Clean and recreate staging area
rm -rf scripts/docker/context
mkdir -p scripts/docker/context/bin
mkdir -p scripts/docker/context/lib
mkdir -p scripts/docker/context/license

# Copy application files
cp "$OUTPUT_PATH" scripts/docker/context/bin/
cp "$CDD_FILE" scripts/docker/context/
cp "$EAR_FILE" scripts/docker/context/
cp "$BE_HOME/bin/be-engine.tra" scripts/docker/context/
cp "$BE_DOCKER_RUN_DIR/be_docker_run.pm" scripts/docker/context/

# Fix license path in TRA to container path — original TRA has dev machine path which doesn't exist in the image
if grep -q 'java\.property\.TIB_ACTIVATION=' scripts/docker/context/be-engine.tra; then
    sed -i 's|^java\.property\.TIB_ACTIVATION=.*|java.property.TIB_ACTIVATION=/license|' scripts/docker/context/be-engine.tra
else
    echo 'java.property.TIB_ACTIVATION=/license' >> scripts/docker/context/be-engine.tra
fi

# License: look for a .bin file alongside CDD/EAR in APP_HOME.
# The native image reads from /root/license (TRA default ~/license), so we copy the file there.
# If not found, /root/license is left as an empty directory to be mounted at runtime.
LICENSE_BIN=$(find "$APP_HOME" -maxdepth 1 -name "*.bin" -type f | head -n 1)
if [ -n "$LICENSE_BIN" ]; then
    echo "License file found: $(basename "$LICENSE_BIN") — baking into image at /root/license."
    cp "$LICENSE_BIN" scripts/docker/context/license/
else
    echo "No .bin license file found in $APP_HOME — mount license folder at runtime: -v /path/to/licensedir:/license"
fi

# Collect .so* files from all BE lib directories (maxdepth 1 per dir).
# No -type f: .so files are often symlinks on Linux; cp -L dereferences them so the
# actual file content is copied into the image rather than a broken symlink.
echo "Collecting native shared libraries..."
lib_count=0
for lib_dir in "$BE_HOME/lib" "$BE_HOME/lib/ext/tpcl" "$BE_HOME/lib/ext/tibco" "$BE_HOME/lib/ext/apache"; do
    [ -d "$lib_dir" ] || continue
    while IFS= read -r -d '' so_file; do
        cp -L "$so_file" scripts/docker/context/lib/ 2>/dev/null && ((lib_count++))
    done < <(find "$lib_dir" -maxdepth 1 \( -name "lib*.so" -o -name "lib*.so.*" \) -print0)
done
echo "Collected $lib_count shared library file(s):"
ls scripts/docker/context/lib/

# Patch cloud/docker/lib/run for GraalVM: replace be-engine binary with native /app
# and fix the TRA file path and VERSION placeholder. Everything else (makeBeProps,
# LOG_LEVEL, AS URLs, JMX, config providers) is reused as-is.
sed \
    -e 's|VERSION=%%%BE_VERSION%%%|VERSION=6.0|' \
    -e 's|TRA_FILE=\$BE_HOME/bin/be-engine\.tra|TRA_FILE=/be-engine.tra|' \
    -e 's|\$BE_HOME/bin/be-engine |/app -DTIB_ACTIVATION=/license |g' \
    -e 's| --propVar [^ "]*||g' \
    -e '/"\$AS_LISTEN_PORT" = ""/,/fi/d' \
    -e '/"\$AS_REMOTE_LISTEN_PORT" = ""/,/fi/d' \
    -e '/^[[:space:]]*AS_LISTEN_URL=/d' \
    -e '/^[[:space:]]*AS_REMOTE_LISTEN_URL=/d' \
    -e '/"\$AS_DISCOVER_URL" = "self"/,/fi/d' \
    -e '/echo.*AS Discover URL/d' \
    -e '/echo.*AS Listen URL/d' \
    "$BE_DOCKER_RUN_DIR/run" > scripts/docker/context/run
chmod +x scripts/docker/context/run

# Build Docker image
docker build \
  --build-arg BIN_NAME="$BIN_NAME" \
  --build-arg CDD_NAME="$CDD_NAME" \
  --build-arg EAR_NAME="$EAR_NAME" \
  -t "$IMAGE_NAME" \
  -f scripts/docker/Dockerfile .

if [ $? -eq 0 ]; then
    echo ""
    echo "Docker image '$IMAGE_NAME' built successfully."
    echo ""
    echo "Run with:"
    if [ -n "$LICENSE_BIN" ]; then
        echo "  docker run -e PU=<processing-unit> $IMAGE_NAME"
    else
        echo "  docker run -e PU=<processing-unit> \\"
        echo "             -v /path/to/licensedir:/license \\"
        echo "             $IMAGE_NAME"
    fi
    echo "  (omit -e PU to use the default PU: 'default')"
else
    echo "Error: docker image build failed."
    rm -rf scripts/docker/context
    exit 1
fi

rm -rf scripts/docker/context
