# Running an Application on Microsoft Azure Based Kubernetes Cluster

By using the Azure Kubernetes Service \(AKS\), you can easily deploy an TIBCO BusinessEvents application in the Kubernetes cluster managed by Microsoft Azure.

For more details about the AKS, see [Azure Kubernetes Service documentation](https://docs.microsoft.com/en-us/azure/aks/).

-   Docker image of the TIBCO BusinessEvents application, see [Building TIBCO BusinessEvents Application Docker Image](Building%20TIBCO%20BusinessEvents%20Application%20Docker%20Image).
-   You must have a Microsoft Azure account with an active subscription. If you don't, [create a new Azure account](https://azure.microsoft.com/en-us/).

1.  Set up [Microsoft Azure command line environment](Setting%20Microsoft%20Azure%20CLI%20Environment).

2.  Create an Azure Container Registry \(ACR\) and push the Docker image of the application to it, see [Setting Up an Azure Container Registry](Setting%20Up%20an%20Azure%20Container%20Registry).

3.  Create a Kubernetes cluster and deploy it to the Microsoft Azure, see [Setting Up a Kubernetes Cluster on AKS](Setting%20Up%20a%20Kubernetes%20Cluster%20on%20AKS).

4.  Based on your application architecture, deploy the application on the Kubernetes cluster. See the following topics based on your application persistence option:

    -   [Running the Application Without Backing Store on Azure](Running%20the%20TIBCO%20BusinessEvents%20Application%20for%20No%20Backing%20Store#).
    -   [Running an Application with Shared Nothing Persistence on Azure](Running%20an%20Application%20with%20Shared%20Nothing%20Storage%20on%20Azure#).
    -   [Running an Application with Shared All Persistence on Azure](Running%20the%20Application%20for%20Shared%20All%20Storage%20on%20Azure#).



**Parent topic:**[TIBCO BusinessEvents on Microsoft Azure Based Kubernetes](TIBCO%20BusinessEvents%20on%20Microsoft%20Azure%20Based%20Kubernetes)

**Related information**  


[Monitoring TIBCO BusinessEvents Applications on Microsoft Azure](Monitoring%20TIBCO%20BusinessEvents%20Applications%20on%20Microsoft%20Azure)

[Running RMS on Azure Based Kubernetes](Running%20RMS%20on%20Azure%20Based%20Kubernetes)

