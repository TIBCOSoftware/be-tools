The rule management server \(RMS\) is an integral part of BusinessEvents for using TIBCO BusinessEvents WebStudio and Decision Manager. To run TIBCO BusinessEvents WebStudio in a container, you must containerize RMS.

To run RMS in a container, you must build its Docker image and run it with Docker like a TIBCO BusinessEvents application.
### Prerequisite
See [Preparing for TIBCO BusinessEvents Containerization](Before%20You%20Begin#preparing-for-tibco-businessevents-containerization)
### Procedure
1. Build the RMS Docker image using the script provided by TIBCO BusinessEvents.

   See [Building RMS Docker Image](Building%20RMS%20Docker%20Image).

2. \(*Linux containers only*\) Create a network bridge for internal communication among Docker images by using the following command.

   ```
   docker network create <BRIDGE_NAME>
   ```

   For details about the command, see [Docker Documentation](https://docs.docker.com/v17.12/engine/reference/commandline/network_create/).

3. Run the RMS Docker image in Docker.

   See [Running RMS in Docker](Running%20RMS%20in%20Docker).


**Child Topics:**
-   **[Building RMS Docker Image](Building%20RMS%20Docker%20Image)**  
    TIBCO BusinessEvents provides a script file to build the RMS Docker image by using bundled Dockerfiles.
-   **[Running RMS in Docker](Running%20RMS%20in%20Docker)**  
     By using the TIBCO BusinessEvents application Docker image, you can run the TIBCO BusinessEvents application in Docker.

**Parent topic:** [Dockerize TIBCO BusinessEvents](Dockerize%20TIBCO%20BusinessEvents)