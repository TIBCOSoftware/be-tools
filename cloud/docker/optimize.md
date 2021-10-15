# Optimize BE container image size
By default every BE application container image is built with full runtime capabilities irrespective of whether the application needs/uses it. You can use the optimization option while building the image to include only required capabilities, so that the resulting image will not only be customized to your specific needs but this process helps significantly reduce the image size as well.

Various dependencies (jars, libs, etc...) pertaining to all optional BE runtime capabilities are classified and tagged under appropriate module names depending on the nature of the functionality they offer. For instance all AS2 dependencies are tagged with a module name "as2".

You can enable optimization using the option `--optimize`

When this option is used, based on the CDD, modules required for the application are identified and all the other modules dependencies are excluded from the container image.

To know all supported modules, Try `./build_image.sh --help`

Example usage: Below command will generate an image with optimization solely based on the configurations available in the cdd, with no additional modules.
```
./build_image.sh -i app \
-s /home/user/tibco/installers \
-a /home/user/tibco/be/6.2/examples/standard/FraudDetection \
--optimize \
-t fdapp:01
```

Channel/function modules (ex: http, kafka, analytics, etc...) need to be provided by the user explicitly. You can supply these additional modules as a comma separated string.

Example usage: Below command will generate an image with optimization based on the configurations available in the cdd as well as include 'http' & 'kafka' modules.
```
./build_image.sh 
-i app \
-s /home/user/tibco/installers \
-a /home/user/tibco/be/6.2/examples/standard/FraudDetection \
--optimize "http,kafka" \
-t fdapp:01
```
