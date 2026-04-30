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

# Generate entrypoint.sh with CDD/EAR paths baked in; PU is supplied at runtime via -e PU=<name>
# License path is set in be-engine.tra above — no -DTIB_ACTIVATION needed here.
cat > scripts/docker/context/entrypoint.sh << 'ENTRYPOINT_EOF'
#!/bin/sh
_props=$(mktemp /tmp/beprops-XXXXXX.props)
tr '\0' '\n' < /proc/self/environ | while IFS='=' read -r _k _v; do
    [ -n "$_k" ] && printf 'tibco.clientVar.%s=%s\n' "$_k" "$_v"
done > "$_props"

echo "=== beprops ===" >&2
cat "$_props" >&2
echo "=== end beprops ===" >&2

exec /app \
  -DLD_LIBRARY_PATH=/usr/lib \
  -DTIB_ACTIVATION=/license \
  -Dextended.properties="--add-opens=jdk.management/com.sun.management.internal=ALL-UNNAMED --add-opens=java.base/jdk.internal.misc=ALL-UNNAMED --add-opens=java.base/sun.nio.ch=ALL-UNNAMED --add-opens=java.management/com.sun.jmx.mbeanserver=ALL-UNNAMED --add-opens=jdk.internal.jvmstat/sun.jvmstat.monitor=ALL-UNNAMED --add-opens=java.base/sun.reflect.generics.reflectiveObjects=ALL-UNNAMED --add-opens=java.base/java.io=ALL-UNNAMED --add-opens=java.base/java.nio=ALL-UNNAMED --add-opens=java.base/java.util=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/java.util.concurrent=ALL-UNNAMED --add-opens=java.base/java.util.concurrent.locks=ALL-UNNAMED --add-opens=java.base/sun.security.ssl=ALL-UNNAMED --add-opens=java.base/sun.net.util=ALL-UNNAMED --add-opens=java.xml/com.sun.org.apache.xerces.internal.jaxp=ALL-UNNAMED --add-opens=java.xml/com.sun.xml.internal.stream=ALL-UNNAMED --add-opens=java.xml/com.sun.org.apache.xalan.internal.xsltc.trax=ALL-UNNAMED --add-opens=java.base/sun.util.calendar=ALL-UNNAMED --add-opens=java.base/sun.net=ALL-UNNAMED --add-opens=java.base/jdk.internal.access=ALL-UNNAMED --add-opens=java.base/java.net=ALL-UNNAMED --add-opens=java.base/java.util.concurrent.atomic=ALL-UNNAMED --add-opens=java.base/java.math=ALL-UNNAMED --add-opens=java.sql/java.sql=ALL-UNNAMED --add-opens=java.base/java.lang.reflect=ALL-UNNAMED --add-opens=java.base/java.time=ALL-UNNAMED --add-opens=java.base/java.text=ALL-UNNAMED --add-opens=java.management/sun.management=ALL-UNNAMED --add-opens=java.desktop/java.awt.font=ALL-UNNAMED" \
  --propFile /be-engine.tra \
  -p "$_props" \
  -u "${PU:-default}" \
  -c "/__CDD_NAME__" "/__EAR_NAME__"
ENTRYPOINT_EOF

sed -i \
    -e "s|__CDD_NAME__|${CDD_NAME}|g" \
    -e "s|__EAR_NAME__|${EAR_NAME}|g" \
    scripts/docker/context/entrypoint.sh
chmod +x scripts/docker/context/entrypoint.sh

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
