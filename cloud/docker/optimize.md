# Optimize BE container image size
BE application for which you want to build a container image, may not need all BE runtime capabilities. You can use the optimization option while building the image to include only required capabilities, so that the resulting image will be smaller in size.

Various dependencies (jars, libs, etc...) pertaining to all optional BE runtime capabilities are classified and tagged under appropriate module names depending on the nature of the functionality they offer. For instance all AS2 dependencies are tagged with a module name "as2".

You can use following options to enable optimization:

### --optimize
When this option is used, scripts automatically parse the CDD file to extract various configurations and identify modules required for the application. Once required modules are identified, build script excludes all other modules dependencies from the container image.

Below table illustrates how various CDD configurations are associated with various modules.

| CDD Configuration | Module Names |
| ----------- | ----------- |
| Cluster Provider | as2, ignite or ftl |
| Cache provider | as2 or ignite |
| Store provider | store, sqlserver, cassandra or as4 |
| Metrics provider | liveview or influx |
| Open Telemetry | opentelemetry |

Example usage:
```
./build_image.sh -i app \
-s /home/user/tibco/installers \
-a /home/user/tibco/be/6.2/examples/standard/FraudDetection \
--optimize \
-t fdapp:01
```

You can use this option, if the CDD file is available during BE container image build time (i.e --image-type is "app" or "rms").

Note that this option alone may not be able to identify all modules required by the application. In such cases, the option `--optimize-for` option can be used along with `--optimize`.

### --optimize-for
This option allows you to supply required module names as comma separated string.

Example usage:
```
./build_image.sh 
-i app \
-s /home/user/tibco/installers \
-a /home/user/tibco/be/6.2/examples/standard/FraudDetection \
--optimize \
--optimize-for="http,kafka" \
-t fdapp:01
```

Try `./build_image.sh --help` and go to the section `--optimize-for` to see all supported modules.
