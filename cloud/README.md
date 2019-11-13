# The `cloud` Tools

The `cloud` folder provide tools that enables you deploy and monitor your TIBCO BusinessEvents applications on different cloud platforms by using Docker and Kubernetes.   

## Docker Tools

By using the scripts provided in the `docker` folder, you can containerize and run a TIBCO BusinessEvents application in Docker.  The folder contains scripts and Dockerfiles that you can use to build Docker images of the following:

- TIBCO BusinessEvents application

- Rule Management Server (RMS)

- TIBCO BusinessEvents Enterprise Administrator Agent

## Kubernetes Tools

The  `kubernetes` folder provides sample YAML files to create the Kubernetes objects required for running sample TIBCO BusinessEvents applications on the Kubernetes cluster based on different cloud platforms. It also provides `readme.html` files with instructions that help you to run and test these applications. 

The  `kubernetes` folder provides sample YAML files and `readme.html` files for the following scenarios based on your cloud platform:

- Running an in-memory application

- Running a cache-based application with different persistence options

- Running RMS to manage business rules through WebStudio

- Running TIBCO BusinessEvents Enterprise Administrator Agent to monitor applications on the Kubernetes cluster



To use these tools and scripts for your TIBCO BusinessEvents applications, clone or download this "cloud" folder to BE_HOME. For more information on how to use those scripts after copying them to BE_HOME, see [TIBCO BusinessEvents Cloud Deployment Guide](https://docs.tibco.com/dyno/businessevents-enterprise/5.6.1/doc/html/GUID-EB00D602-12FD-4C4D-835D-2ECBBB32D235.html).
