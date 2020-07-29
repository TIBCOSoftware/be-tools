By using the TIBCO BusinessEvents application Docker image, you can run the TIBCO BusinessEvents application in Docker.
### Prerequisites
-   Build the RMS Docker image. See [Building RMS Docker Image](Building%20RMS%20Docker%20Image).
-   \(Linux containers only\) Ensure that a network bridge exists for internal communication between Docker images. You can use the `docker network create` command of Docker to create the network bridge. For details about the command, see [Docker Documentation](https://docs.docker.com/engine/reference/commandline/network_create/).
### Procedure
1. Execute the `run` command on the machine where you have created the application Docker image.

   ```
   docker run --net=<BRIDGE_NETWORK> -p <CONTAINER_PORT>:<HOST_PORT> -v <LOCAL_DIRECTORIES>:<CONTAINER_DIRECTORIES> -e <ENVIRONMENT_VARIABLES> <RMS_IMAGE_NAME>:<IMAGE_VERSION>
   ```

   For details about the Docker `run` command options, see [Docker Run Command Reference](Docker%20Run%20Command%20Reference).


### Example

```
docker run -p 8090:8090 -e PU=default "HOSTNAME=localhost" rms:5.6.0
```

**Parent topic:** [Containerizing RMS by Using Docker](Containerizing-RMS-by-Using-Docker)