
By using the TIBCO BusinessEvents application Docker image, you can run the TIBCO BusinessEvents application in Docker.

### Prerequisites
-   Build the BusinessEvents application Docker image. See [Building BusinessEvents Application Docker Image](Building%20TIBCO%20BusinessEvents%20Application%20Docker%20Image).
-   \(Linux containers only\) Ensure that a network bridge exists for internal communication between Docker images. You can use the `docker network create` command to create the network bridge. For details about the command, see [Docker Documentation](https://docs.docker.com/v17.12/engine/reference/commandline/network_create/).

### Procedure
1.  Execute the `run` command on the machine where you have created the application Docker image.

    ```
    docker run --net=<BRIDGE_NETWORK> -p <CONTAINER_PORT>:<HOST_PORT> -v <LOCAL_DIRECTORIES>:<CONTAINER_DIRECTORIES> -e <ENVIRONMENT_VARIABLES> <APPLICATION_IMAGE_NAME>:<IMAGE_VERSION>
    ```

    For details about the `docker run` command options, see [Docker Run Command Reference](Docker%20Run%20Command%20Reference).


### Example

```
docker run -p 8110:8110 -e PU=default "HOSTNAME=localhost" httpapp 
```

**Parent topic:** [Containerizing TIBCO BusinessEvents Application in Docker](Containerizing%20TIBCO%20BusinessEvents%20Application%20in%20Docker)

