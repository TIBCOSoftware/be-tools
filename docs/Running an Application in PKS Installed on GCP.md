# Running an Application in Enterprise PKS Installed on GCP

By using Enterprise PKS installed on GCP, you can deploy a TIBCO BusinessEvents application in the Kubernetes cluster managed by Enterprise PKS.

For more information, see "Enterprise Pivotal Container Service" in [Pivotal Docs](https://docs.pivotal.io/pks).

-   See [Preparing for TIBCO BusinessEvents Containerization](Before%20You%20Begin)
-   Docker image of your TIBCO BusinessEvents application. See [Building TIBCO BusinessEvents Application Docker Image](Building%20TIBCO%20BusinessEvents%20Application%20Docker%20Image).
-   Active Pivotal and Google Cloud accounts
-   Download and install the following CLIs on your system:

    |CLI|Download and Installation Reference|
    |---|-----------------------------------|
    |Enterprise PKS CLI \(`pks`\)|"Installing the PKS CLI" in [Pivotal Docs](https://docs.pivotal.io/pks)|
    |Kubernetes CLI \(`kubectl`\)|"Installing the Kubernetes CLI" in [Pivotal Docs](https://docs.pivotal.io/pks)|
    |Google Cloud CLI \(`gcloud`\)|[Google Cloud SDK documentation](https://cloud.google.com/sdk/docs/)|


1.  Install Enterprise PKS on GCP.

    See [Enterprise PKS documentation](https://docs.pivotal.io/pks).

2.  Set up a Kubernetes cluster on Enterprise PKS.

    See [Setting Up a Kubernetes Cluster with Enterprise PKS](Setting%20up%20a%20Kubernetes%20Cluster%20With%20Enterprise%20PKS).

3.  Push the TIBCO BusinessEvents application Docker image to Google Container Registry.

    See [Setting up Google Container Registry](Pushing%20Application%20Docker%20Image%20to%20Google%20Container%20Registry).

4.  Based on your application architecture, deploy the application on the Kubernetes cluster. See the following topics based on your application persistence option:

    -   [Running an Application without Backing Store on Enterprise PKS](Running%20the%20Application%20Without%20Backing%20Store%20on%20PKS)
    -   [Running an Application with Shared Nothing Persistence on Enterprise PKS](Running%20an%20Application%20with%20Shared%20Nothing%20Store%20on%20Enterprise%20PKS)
    -   [Running an Application with Shared All Persistence on Enterprise PKS](Running%20an%20Application%20with%20Shared%20All%20Storage%20on%20Enterprise%20PKS)

-   **[Setting Up a Kubernetes Cluster with Enterprise PKS](Setting%20up%20a%20Kubernetes%20Cluster%20With%20Enterprise%20PKS)**  
In Pivotal, you can use Enterprise PKS to create and manage a Kubernetes cluster. Use the Enterprise PKS Command Line Interface \(PKS CLI\) to deploy the Kubernetes cluster and manage its lifecycle. To deploy and manage container-based workloads on the Kubernetes cluster, use the Kubernetes CLI \(`kubectl`\).
-   **[Setting up Google Container Registry](Pushing%20Application%20Docker%20Image%20to%20Google%20Container%20Registry)**  
For deploying the TIBCO BusinessEvents application to the Kubernetes cluster, you must push the application Docker image to Google Container Registry.
-   **[Running an Application without Backing Store on Enterprise PKS](Running%20the%20Application%20Without%20Backing%20Store%20on%20PKS)**  
After uploading the Docker image of your TIBCO BusinessEvents application without backing store to Google Container Registry, you can deploy your application to the Pivotal based Kubernetes cluster. The cluster manages the availability and connectivity of the application and service.
-   **[Running an Application with Shared Nothing Persistence on Enterprise PKS](Running%20an%20Application%20with%20Shared%20Nothing%20Store%20on%20Enterprise%20PKS)**  
After uploading your TIBCO BusinessEvents application Docker image with shared nothing persistence to Google Container Registry and creating the Kubernetes cluster, deploy and run your application on the Kubernetes cluster. The cluster manages the availability and connectivity of the application.
-   **[Running an Application with Shared All Persistence on Enterprise PKS](Running%20an%20Application%20with%20Shared%20All%20Storage%20on%20Enterprise%20PKS)**  
After uploading your TIBCO BusinessEvents application image with shared all persistence to the Google Container Registry and creating the Kubernetes cluster, you can deploy your application to the Kubernetes cluster. The cluster manages the availability and connectivity of the application. You can use the Docker image of the database that you want to use.

**Parent topic:**[TIBCO BusinessEvents on Pivotal Based Kubernetes](TIBCO%20BusinessEvents%20on%20Pivotal%20Based%20Kubernetes)

