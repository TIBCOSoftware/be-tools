Using the scripts provided at the TIBCO BusinessEvents GitHub repository, you can containerize and run a TIBCO BusinessEvents application by using Docker.

Docker provides a way to run applications securely isolated in a container, packaged with all its dependencies and libraries. Your application can run in any environment as all the dependencies are already present in the image of the application. For details about Docker, see [Docker Documentation](https://docs.docker.com/).

A TIBCO BusinessEvents application comprises a common TIBCO BusinessEvents runtime and project \(application\) specific TIBCO BusinessEvents code running inside the TIBCO BusinessEvents runtime. Thus to containerize a TIBCO BusinessEvents application, TIBCO BusinessEvents software archive and application archive are included in the Docker image.

## Docker Scripts with BusinessEvents

TIBCO BusinessEvents provides the following scripts for building images of TIBCO BusinessEvents application and its components at `BE_HOME\cloud\docker\bin`:

-   `build_app_image` - Script to build the Docker image for your TIBCO BusinessEvents application.
-   `build_rms_image` - Script to build the Docker image for RMS.
-   `build_teagent_image` - Script to build the Docker image for TIBCO BusinessEvents Enterprise Administrator Agent.

These scripts use the platform-specific Dockerfiles bundled with TIBCO BusinessEvents at BE_HOME\cloud\docker\bin. For details about Dockerfiles provided with TIBCO BusinessEvents, see [Dockerfile for TIBCO BusinessEvents](Dockerfile%20for%20TIBCO%20BusinessEvents).

## Containerizing TIBCO BusinessEvents Application and Components

To deploy and run different TIBCO BusinessEvents components in Docker, see the following topics:

-   [Containerizing TIBCO BusinessEvents Application in Docker](Containerizing%20TIBCO%20BusinessEvents%20Application%20in%20Docker)
-   [Containerizing RMS by Using Docker](Containerizing-RMS-by-Using-Docker)
-   [Building TIBCO BusinessEvents Enterprise Administrator Agent Docker Image](Building%20TIBCO%20BusinessEvents%20Enterprise%20Administrator%20Agent%20Docker%20Image)

