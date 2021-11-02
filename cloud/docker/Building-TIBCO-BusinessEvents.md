You can build [OCI](https://opencontainers.org/) container images for TIBCO BusinessEvents application using your favourite tools [docker](https://docs.docker.com/) or [buildah](https://buildah.io/).

### Prerequisites
1.  See [Preparing for TIBCO BusinessEvents Containerization](Before-You-Begin#preparing-for-tibco-businessevents-containerization)
2.  If you choose to build container image with `docker` Install from [here](https://docs.docker.com/get-started/#download-and-install-docker).
3.  If you choose to build container image with `buildah` Install from [here](https://github.com/containers/buildah/blob/master/install.md).

### Build Script

TIBCO BusinessEvents provides the `build_image` script for building images of TIBCO BusinessEvents application and its components at `BE_HOME\cloud\docker`. Use the `--image-type` as below for the respective images:

-   `app` - To build the Container image for your TIBCO BusinessEvents application.
-   `s2ibuilder` - To build the S2i Container image for your TIBCO BusinessEvents application.
-   `rms` - To build the Container image for RMS.
-   `teagent` - To build the Container image for TIBCO BusinessEvents Enterprise Administrator Agent.

```sh
Usage: build_image.sh

 [-i/--image-type]    :    Type of the image to build ("app"|"rms"|"teagent"|"s2ibuilder") [required]
                           Note: For s2ibuilder image usage refer to be-tools wiki under containerize section.

 [-a/--app-location]  :    Path to BE application where cdd, ear & optional supporting jars are present
                           Note: Required if --image-type is "app"
                                 Optional if --image-type is "rms"
                                 Ignored  if --image-type is "teagent" or "s2ibuilder"

 [-s/--source]        :    Path to BE_HOME or TIBCO installers (BusinessEvents, Activespaces or FTL) are present (default "../../")

 [-t/--tag]           :    Name and optionally a tag in the 'name:tag' format [optional]

 [-d/--docker-file]   :    Dockerfile to be used for generating image [optional]

 [--gv-provider]      :    Name of GV provider to be included in the image ("consul"|"http"|"custom") [optional]
                           To add more than one GV use comma separated format ex: "consul,http" 
                           Note: This flag is ignored if --image-type is "teagent"

 [--disable-tests]    :    Disables docker unit tests on created image (applicable only for "app" and "s2ibuilder" image types) [optional]

 [-b/--build-tool]    :    Build tool to be used ("docker"|"buildah") (default is "docker")
                           Note: s2ibuilder image and docker unit tests not supported for buildah.

 [-o/--openjdk]       :    Enable to use OpenJDK instead of tibcojre [optional]
                           Note: Place OpenJDK installer archive along with TIBCO installers.
                                 OpenJDK can be downloaded from https://jdk.java.net/java-se-ri/11.

 [--optimize]         :    Enables container image optimization. Automatically retrieves required modules from CDD/EAR, if available. [optional]
                           Additional module names can be passed as comma separated string. Ex: "http,kafka" 
                           Supported modules: analytics, as2, as4, cassandra, eclipse, ftl, http, ignite, influx, kafka, kinesis, liveview, mqtt, opentelemetry, pattern, process, query, soap, sqlserver, store & streambase.

 [-h/--help]          :    Print the usage of script [optional]

 NOTE : supply long options with '='
```

**Note for the Windows platform** 
* Use `build_image.bat` script and enclose all arguments in double quotes \("\).
* Flags `disable-tests` and `build-tool` not applicable in windows environment.
* If you are building from a Windows machine behind a firewall, you may see error like - "Unable to connect to
the remote server". In such case you need to configure your firewall to allow all traffic on the nat virtual adapter which is only used by containers.
* `--optimize` flag requires perl dependency. Install perl from [here](https://strawberryperl.com/).
* If you are running `build_image.bat` from powershell tool. You need to supply comma separated values inside `'` quotes . Example usage: `build_image.bat -i app -a C:\apps\tibcoprodcuts\app\be620\inmem -s C:\apps\tibcoprodcuts\inst\be620 --optimize '"http,test1"' --gv-provider '"http,consul"' -t apptest:v1`

### Important Information
-   Docker version 18.09 introduces `BuildKit` for the improved docker build performance. By default `build_image` script uses `BuildKit` for the better build time. It can be disabled by using `export DOCKER_BUILDKIT=0`.

-   Openshift's Source-to-image toolkit can be downloaded from [here](https://github.com/openshift/source-to-image#installation). This toolkit is used to build TIBCO BusinessEvents application image from TIBCO BusinessEvents S2I Builder image.

-   `s2ibuilder` Image is not supported with `buildah` tool.

-   `--disable-tests` is not supported with `buildah` tool.

### Optimize BE container image size
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

### Details for building each component

1. [Building TIBCO BusinessEvents Application](Building-TIBCO-BusinessEvents-Application).

2. [Building TIBCO BusinessEvents RMS](Building-RMS)

3. [Building TIBCO BusinessEvents Enterprise Administrator Agent](Building-TIBCO-BusinessEvents-Enterprise-Administrator-Agent)


**Next Topic:** [Running TIBCO BusinessEvents](Running-TIBCO-BusinessEvents)

**Parent Topic:** [Containerize TIBCO BusinessEvents](Containerize-TIBCO-BusinessEvents)
