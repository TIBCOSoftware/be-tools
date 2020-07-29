TIBCO BusinessEvents provides the Dockerfiles for creating Docker image of the TIBCO BusinessEvents application and components.

The Dockerfiles for different platforms and components provided with TIBCO BusinessEvents to build Docker image by using either software installers or by using the existing TIBCO BusinessEvents installation. The following table lists Dockerfiles provided with the TIBCO BusinessEvents installation, along with the list of the script files that are using the Dockerfile and type of the container:

|Files Location|Dockerfile|Platform|Used for Creating the Docker Image of|Associated Script File|
|--------------|----------|--------|-------------------------------------|----------------------|
|BE_HOME/cloud/docker/bin \(*For the Docker image based on software installers*\)|Dockerfile|Ubuntu|TIBCO BusinessEvents application|build_app_image.sh|
||Dockerfile.rhel|Red Hat Enterprise Linux|TIBCO BusinessEvents application|build_app_image.sh|
||Dockerfile.win|Microsoft Windows|TIBCO BusinessEvents application|build_app_image.bat|
||Dockerfile-rms|Ubuntu|Rule Management Server \(RMS\)|build_rms_image.sh|
||Dockerfile-rms.win|Microsoft Windows|Rule Management Server \(RMS\)|build_rms_image.bat|
||Dockerfile-teagent|Ubuntu **Note:** The same Dockerfile is used on both Linux and Windows platforms, and creates a Linux container.|TIBCO BusinessEvents Enterprise Administrator Agent|build_teagent_image.sh build_teagent_image.bat|
|BE_HOME/cloud/docker/frominstall \(*For the Docker image based on the existing TIBCO BusinessEvents installation*\)|Dockerfile_fromtar|Ubuntu|TIBCO BusinessEvents application|build_app_image.sh|
||Dockerfile_fromtar.win|Microsoft Windows|TIBCO BusinessEvents application|build_app_image.bat|
||Dockerfile-rms_fromtar|Ubuntu|Rule Management Server \(RMS\)|build_rms_image.sh|
||Dockerfile-rms_fromtar.win|Microsoft Windows|Rule Management Server \(RMS\)|build_rms_image.bat|
||Dockerfile-teagent_fromtar|Ubuntu|TIBCO BusinessEvents Enterprise Administrator Agent|build_teagent_image.sh|

**Note:** When building the Red Hat Enterprise Linux based Docker image, update the dockerfile \(`Dockerfile.rhel`\) with your subscribed Red Hat Docker image before running the Docker build script. In the Dockerfile, replace the `<RHEL_IMAGE>` placeholder with the Red Hat Enterprise Linux Docker image name.

To use any other platform, update the Dockerfile with the platform details. For more information about Dockerfile structure, see [Docker Documentation](https://docs.docker.com/engine/reference/builder/).

The following sections identify key instructions to set up key configurations for the TIBCO BusinessEvents Docker images.

## Environment Variables \(`ENV`\)

The `ENV` instruction is used to set the environment variables. These variables consist of key-value pairs which can be accessed from within the container by scripts and applications alike. The syntax for the `ENV` instruction is:

```
ENV key value
```

The default TIBCO BusinessEvents Dockerfiles have the following common environment variables:

-   `CDD_FILE`: Path of the TIBCO BusinessEvents application or RMS CDD file.
-   `EAR_FILE`: Path of the TIBCO BusinessEvents application or RMS EAR file.
-   `PU`: The name of the processing unit to run. The value is provided at the runtime by the user. The default value is default.
-   `AS_DISCOVER_URL`: Discovery URL of TIBCO ActiveSpaces.
-   `ENGINE_NAME`: TIBCO BusinessEvents engine name. The default value is be-engine.
-   `LOG_LEVEL`: Logging level for BusinessEvents. The default value is na.

```
# BusinessEvents Environment Variables
ENV CDD_FILE no-default
ENV PU default
ENV EAR_FILE no-default
ENV ENGINE_NAME be-engine
ENV LOG_LEVEL na
ENV AS_DISCOVER_URL self
```

## Data Volumes \(`VOLUME`\)

The `VOLUME` instruction is used to enable access from your container to a directory on the host machine. The syntax for the `VOLUME` instruction is:

```
VOLUME /dir1, /dir2 ...
```

Using data volumes, you can persist the data across Docker runs. For example, in the default Dockerfile ActiveSpaces Shared Nothing file stores, the log file locations and the Rule Management Server directories are configured. The Docker volumes for them are created and all internal file paths are rooted to the specified directories. These volumes are predefined in Dockerfiles provided with TIBCO BusinessEvents. The following table lists the predefined \(Linux\) directory path for creating data volume. Similar paths are also defined in the Windows Dockerfiles.

|Volumes|Dockerfiles|Description|
|-------|-----------|-----------|
|/mnt/tibco/be/logs|`Dockerfile` `Dockerfile-rms`|Directory where log files are stored.|
|/mnt/tibco/be/data-store|`Dockerfile` `Dockerfile-rms`|Directory where shared nothing data is stored.|
|`/opt/tibco/be/${BE_SHORT_VERSION}/rms/config/security`|`Dockerfile-rms`|Directory which holds the RMS application’s ACL \(permission configuration\) and user.pwd files.|
|`/opt/tibco/be/${BE_SHORT_VERSION}/examples/standard/WebStudio`|`Dockerfile-rms`|The repository directory for BusinessEvents WebStudio where all projects are stored.|
|`/opt/tibco/be/${BE_SHORT_VERSION}/rms/config/notify`|`Dockerfile-rms`|Directory where email notification configuration files are stored.|
|`/opt/tibco/be/${BE_SHORT_VERSION}/rms/shared`|`Dockerfile-rms`|Directory where RMS applications exported files are stored.|
|`/opt/tibco/be/${BE_SHORT_VERSION}/rms/locale`|`Dockerfile-rms`|Directory where the user locale configuration is stored.|
|`/mnt/tibco/be/`|`Dockerfile-teagent`|Directory where TIBCO BusinessEvents is stored.|
|`/opt/tibco/be/${BE_SHORT_VERSION}/teagent/logs/`|`Dockerfile-teagent`|Directory where TIBCO BusinessEvents Enterprise Administrator Agent logs are stored.|

Here, BE_SHORT_VERSION stands for the TIBCO BusinessEvents software version in the short form. For example, for TIBCO BusinessEvents version 5.6.1, the BE_SHORT_VERSION is 5.6.

## Ports \(`EXPOSE`\)

The `EXPOSE` instruction is used to associate a specified port to enable networking between the running process inside the container and the external nodes \(that is, the host\). The syntax for the `EXPOSE` instruction is:

```
EXPOSE port1 port2 ...
```

By default the following ports are exposed by the TIBCO BusinessEvents Dockerfiles:

-   `50000` and `50001`: These are the ports on which TIBCO ActiveSpaces listens. These are exposed by the base image.

    **Note:** The port for `AS_LISTEN_URL` and `AS_DISCOVER_URL` are set to `50000` in scripts. Also, for `AS_REMOTE_LISTEN_URL`, the port is set to `50001`. You must not change these ports.

-   `5555`: This is the JMX port exposed by the base image.
-   `8090` and `5000`: These are the rule management server ports exposed by the base image.

These ports can be mapped during Docker run.

**Parent topic:** [Dockerize TIBCO BusinessEvents](Dockerize%20TIBCO%20BusinessEvents)

