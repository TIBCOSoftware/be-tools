# Optimize BE container image size
BE application for which you want to build a container image, may not need all BE runtime capabilities. You can use the optimization option while building the image to include only required capabilities, so that the resulting image will be smaller in size.

Various dependencies (jars, libs, etc...) pertaining to all optional BE runtime capabilities are classified and tagged under appropriate module names depending on the nature of the functionality they offer. For instance all AS2 dependencies are tagged with a module name "as2".

You can enable optimization using the option `--optimize`

When this option is used, scripts automatically parse the CDD/EAR to extract various configurations and identify modules required for the application. Once required modules are identified, build script excludes all other modules dependencies from the container image.

Below table illustrates how various CDD/EAR configurations are associated with various modules.

| CDD Configuration | Module Names |
| ----------- | ----------- |
| Cluster Provider | as2, ignite or ftl |
| Cache provider | as2 or ignite |
| Store provider | store, sqlserver, cassandra or as4 |
| Metrics provider | liveview or influx |
| Open Telemetry | opentelemetry |

To know all supported modules, Try `./build_image.sh --help`

Example usage:
```
./build_image.sh -i app \
-s /home/user/tibco/installers \
-a /home/user/tibco/be/6.2/examples/standard/FraudDetection \
--optimize \
-t fdapp:01
```

Channel related modules (ex: http, kafka, etc...) need to be supplied by the user explicitly, as current scripts will not retrieve them automatically. You can supply these additional modules as a comma separated string.

Example usage:
```
./build_image.sh 
-i app \
-s /home/user/tibco/installers \
-a /home/user/tibco/be/6.2/examples/standard/FraudDetection \
--optimize "http,kafka" \
-t fdapp:01
```
