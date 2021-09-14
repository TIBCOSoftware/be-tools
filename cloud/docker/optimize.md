
# Optimize BE container size

BE app container image size can be optimized by including only required dependencies (lib/jars) 
in the image. To optimize use `--optimize`, `--include` OR both options while building BE container imague
using `be-tools/cloud/docker/build_image.sh`.


### --optimize

This option optimizes BE app container size by inspecting CDD to included only required dependencies in the container image.

Example:
```
./build_image.sh -i app \
-s /home/user/tibco/installers \
-a /home/user/tibco/be/6.2/examples/standard/FraudDetection \
-- optimize \
-t fdapp
```

### --include

This option can be used to supply required module names to that corresponding dependencies would be available in the container image.

Available modules names: as2, ignite, etc
