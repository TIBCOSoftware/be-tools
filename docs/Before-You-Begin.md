You can containerize a TIBCO BusinessEvents application by using Docker. You can also run the dockerized TIBCO BusinessEvents application in a Kubernetes cluster on the cloud platform of your choice.

## Supported Versions

Before you begin, see TIBCO BusinessEvents Readme for supported versions of Docker and cloud platforms.

## Concepts

Before you begin, you must be familiar with the following concepts and services:

-   Docker concepts. See [Docker Documentation](https://docs.docker.com/).
-   Kubernetes concepts. See[Kubernetes Documentation](https://kubernetes.io/docs/home/).
-   Administration knowledge of the cloud platform and the service that you want to use:
    -   [Amazon Web Services \(AWS\)](https://docs.aws.amazon.com/)
    -   [Microsoft Azure](https://docs.microsoft.com/en-us/azure/) and [Azure Kubernetes Service \(AKS\)](https://docs.microsoft.com/en-us/azure/aks/)
    -   [Red Hat OpenShift Container Platform](https://access.redhat.com/documentation/en-us/openshift_container_platform/)
    -   [Google Cloud Platform \(GCP\)](https://cloud.google.com/docs/) and [Pivotal Container Service \(PKS\)](https://docs.pivotal.io/runtimes/pks)

## Preparing for TIBCO BusinessEvents Containerization

Ensure that you have the following infrastructure in place:

-   A machine with the Docker installation and initial setup based on your operating system, to generate Docker images. For complete information about Docker installation, see [Docker Documentation](https://docs.docker.com/).
-   TIBCO BusinessEvents installation and a TIBCO BusinessEvents project that you want to deploy and run on the cloud. For installation instructions, see the *TIBCO BusinessEvents Installation Guide* at [TIBCO BusinessEvents Documentation](https://docs.tibco.com/products/tibco-businessevents-enterprise-edition).
-   Clone or download the `cloud` folder from the [TIBCO BusinessEvents GitHub repository](https://github.com/TIBCOSoftware/be-tools/tree/v1.0) to your system. You can download the `cloud` folder to any location on your system. The `cloud` folder contains utilities to deploy and monitor your TIBCO BusinessEvents applications on different cloud platforms by using Docker and Kubernetes.

    **Note:** In this guide, it is assumed that the `cloud` folder from GitHub is downloaded at BE_HOME and merged with the existing BE_HOME/cloud folder. Thus, all file paths in this guide are mentioned based on this assumption.

-   Installer ZIP files for the following software:
    -   TIBCO BusinessEvents
    -   TIBCO BusinessEvents add-ons \(Optional\)
    -   TIBCO ActiveSpaces \(Optional\)
    -   TIBCO FTL \(Optional\)

    For more details, see the `Optional Software Requirements` section in *TIBCO BusinessEvents Installation Guide* at [TIBCO BusinessEvents Documentation](https://docs.tibco.com/products/tibco-businessevents-enterprise-edition) <br>


    **Note** **\(macOS only\)**: <br>
    On the macOS platform, you can build only Linux containers. To build a Docker image on macOS, you must store the TIBCO BusinessEvents Linux installer ZIP file \(`TIB_businessevents-enterprise_<version>_linux26gl25_x86_64.zip`\) on your computer instead of the macOS installer ZIP file. Similarly, if your application uses TIBCO BusinessEvents add-ons \(OR\) TIBCO ActiveSpaces \(OR\) TIBCO FTL, download respective Linux installers on your computer.

-   \(Optional\) For monitoring TIBCO BusinessEvents applications, install TIBCO Enterprise Administrator with the latest hotfix. For installation instructions, see [TIBCO Enterprise Administrator documentation](https://docs.tibco.com/products/tibco-enterprise-administrator).
-   If you are running the application in a Kubernetes cluster on a cloud platform, ensure that you have an active account on that cloud platform.

