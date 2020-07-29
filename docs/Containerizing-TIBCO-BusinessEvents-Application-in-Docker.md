# Containerizing TIBCO BusinessEvents Application in Docker

You can deploy and run a TIBCO BusinessEvents application in Docker by using the Docker image of the TIBCO BusinessEvents application.

### Prerequisites
See [Preparing for TIBCO BusinessEvents Containerization](Before-You-Begin#preparing-for-tibco-businessevents-containerization)

### Procedure
1.  Build the TIBCO BusinessEvents application Docker image using the script provided by TIBCO BusinessEvents.

    See [Building TIBCO BusinessEvents Application Docker Image](Building%20TIBCO%20BusinessEvents%20Application%20Docker%20Image).

2.  \(*Linux containers only*\) Create a network bridge for internal communication among Docker images by using the following command.

    ```
    docker network create <BRIDGE_NAME>
    ```

    For details about the command, see [Docker Documentation](https://docs.docker.com/v17.12/engine/reference/commandline/network_create/).

3.  Run the TIBCO BusinessEvents application image in Docker.

    See [Running a TIBCO BusinessEvents Application in Docker](Running%20TIBCO%20BusinessEvents%20Application%20in%20Docker).


**Parent topic:** [Dockerize TIBCO BusinessEvents](Dockerize%20TIBCO%20BusinessEvents)

