# Docker Run Command Reference

The `docker run` command is used for containerizing and running a TIBCO BusinessEvents application by using its Docker image.

## Syntax

```
docker run --net=<BRIDGE_NETWORK> -p <CONTAINER_PORT>:<HOST_PORT> -v <LOCAL_DIRECTORIES> -e <ENVIRONMENT_VARIABLES> <APPLICATION_IMAGE_NAME>:<IMAGE_VERSION>
```

Where:

-   `--net=<BRIDGE_NETWORK>` - Specify the name of the network bridge that you have created. This connects the container to the specified network.
-   `-p <CONTAINER_PORT>:<HOST_PORT>` - \(Optional\) Specify the host port and container port that you want to map.
-   `-v <LOCAL_DIRECTORIES>:<CONTAINER_DIRECTORIES>` - \(Optional\) Specify the path of the local directory that you want to mount to the container.
-   `<APPLICATION_IMAGE_NAME>` - Specify the name of the BusinessEvents application Docker image. If you want to use RMS, use the RMS Docker image name.
-   `<IMAGE_VERSION>`- \(Optional\) Specify the version of the specified Docker image.
-   `-e <ENVIRONMENT_VARIABLES>` - Use the `-e` option to set environment variables, as required, with syntax `VAR=Value`. You can use the following environmental variables at the run time.
    -   **`AS_DISCOVER_URL`**: Specify the discover URL, which enables members to discover each other in the network. For example:

        ```
        docker run --net=simple-bridge --name=inference **-e AS_DISCOVER_URL=tcp://cache:50000** -e PU=default -p 8109:8109 fdcache:v01
        ```

        Here the Docker name of the cache server "cacheagent" is used for the `AS_DISCOVER_URL` of the inference agent. The port number of `AS_DISCOVER_URL` must be set to `50000` as this is setup in the Docker scripts. As all agents running on the same Docker host can resolve Docker names to their IP addresses on the network, you can create clusters across instances on the same network.

    -   **`PU`**: Specify the processing unit that needs to be started. For example, running the application with "cache" as processing unit:

        ```
        docker run --net=be_network --name=cacheagent **-e PU=cache** fdcache:v01
        ```

    -   **`LOG_LEVEL`**: Specify the override value for the predefined log level. You can specify comma-separated values for the log patterns required. If the `LOG_LEVEL` environment variable is not specified, the `log-config` of the CDD file is used. The pattern configurations are the same as the `log-config` of the CDD file. For example:

        ```
        docker run --net=simple-bridge --name=cacheagent -e PU=cache **–e LOG_LEVEL=\*:debug** fdcache:v01
        ```

    -   **`DOCKER_HOST`**: Specify the host where the `docker run` command is executed. This environment variable is required for remote JMX connections to the running container. For example:

        ```
        docker run --net=be_network --name=sample **–p 5555:5555** -e PU=default **–e DOCKER_HOST=10.97.123.56** sample:v01
        ```

        **Note:** The default JMX port for engines running in Docker is `5555`. You must map this default port to the local port defined in the Dockerfile.

    -   **`AS_PROXY_NODE`**: Specifies whether the container run as a proxy node. Set the value to true, to start the node in proxy mode. For example:

        ```
        docker  run ... **–e  AS_PROXY_NODE=true** ...
        ```

        The port 50001 is set as the ActiveSpaces remote listen port which can be specified while connecting to the proxy node. For example:

        ```
        docker run ...  -e AS_REMOTE_LISTEN_URL=tcp://<container_name>:50001?remote=true ...
        ```

    -   **`CONSUL_SERVER_URL`**: Specify the URL of the Consul server.
    -   **`APP_CONFIG_PROFILE`**: Specify name of the global variables profile that you have used for grouping in Consul. The default value is “default”, if not specified.
    -   **`BE_APP_NAME`**: Specify the application name that you have used for grouping global variables in the key value store in Consul.
    -   **`CONSUL_CACERT`**: Specify the absolute path of the CA certificates placed in the container.
    -   **`CONSUL_CLIENT_CERT`**: Specify the absolute path of the CLI certificates placed in the container.
    -   **`CONSUL_CLIENT_KEY`**: Specify the absolute path of the client keystore file placed in the container.
    -   ***TRA properties***: You can specify any of the BusinessEvents engine and JVM properties as an environment variable.

        To use the property, append `**tra.**` at the beginning of the property name. For example, to use `java.extended.properties`, provide `**tra.**java.extended.properties` and its value as environment variable. The value of the environment variable `tra.java.extended.properties` overwrites the value of the `java.extended.properties` property in the be-engine.tra file.

        You can also specify a few JVM properties, such as, `-Xms`, `-Xmx`, and `-Xss` as environment variable individually. These individual JVM properties, when specified as environment variable, take precedence over the JVM properties defined in the `tra.java.extended.properties` environment variable. Other JVM properties, such as, garbage collection properties still have to be defined under the `tra.java.extended.properties` environment variable. The following table lists the environment variables that you can use for these JVM property options.

        |Task|JVM Property Option|Environment Variable|
        |----|-------------------|--------------------|
        |Set initial Java heap size|`-Xms`|`tra.java.heap.size.initial`|
        |Set maximum Java heap size|`-Xmx`|`tra.java.heap.size.max`|
        |Set Java thread stack size|`-Xss`|`tra.java.stack.size`|

        For example:

        ```
        docker run -e "tra.java.heap.size.initial=1024m" -e "tra.java.heap.size.max=1024m" -e "tra.java.stack.size=2m" -e="tra.java.extended.properties=-server -Xms512m -Xmx512m -javaagent:%BE_HOME%/lib/cep-base.jar -XX:MaxMetaspaceSize=256m -XX:+UseParNewGC -XX:+UseConcMarkSweepGC" com.tibco.be.fd:v016
        ```

        In the previous example, `tra.java.heap.size.initial=1024m` and `tra.java.heap.size.max=1024m` takes precedence over the `-Xms512m` and `-Xmx512m` options of `tra.java.extended.properties`. Thus, the initial Java heap size and maximum Java heap size is set to 1024M instead of 512M. Also, the `tra.java.stack.size=2m` environment variable sets the `-Xss` option of `java.extended.properties` property in the be-engine.tra file to 2M.

    -   ***Global Variable***: You can specify a global variable as an environment variable to override its value. Provide the global variable name and its value as an environment variable. For example, to specify value for the global variable `HOSTNAME` as `localhost`, run the following command:

        ```
        docker  run ... **–e  "DB_USERNAME=scott"** ...
        ```

        **Note:** In order to update global variables during runtime, ensure that global variables are used in shared resources of the TIBCO BusinessEvents project. For example, to change database details at runtime without regenerating application Docker image, ensure that global variables are used in the JDBC shared resource.


For more details about the `docker run` command, see [Docker Documentation](https://docs.docker.com/engine/reference/commandline/run/).

**Parent topic:**[Dockerize TIBCO BusinessEvents](Dockerize%20TIBCO%20BusinessEvents)

