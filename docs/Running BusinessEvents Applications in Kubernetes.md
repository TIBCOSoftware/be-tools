# Running TIBCO BusinessEvents® on AWS Based Kubernetes Cluster

By using Amazon EC2, you can fully manage your Kubernetes deployment. You can provision and run Kubernetes on your choice of instance types.

-   Docker image of TIBCO BusinessEvents application, see [Building TIBCO BusinessEvents Application Docker Image](Building%20TIBCO%20BusinessEvents%20Application%20Docker%20Image).
-   Download and install the following CLIs on your system:

    |CLI|Download and Installation Instruction Link|
    |---|------------------------------------------|
    |`kops`|https://github.com/kubernetes/kops/blob/master/docs/aws|
    |`kubectl`|https://kubernetes.io/docs/tasks/tools/install-kubectl/|
    |`aws`|https://aws.amazon.com/cli/|


1.  Set up a Kubernetes cluster on Amazon Web Services \(AWS\). For more information, see [Setting up a Kubernetes Cluster on AWS](Setting%20up%20a%20Kubernetes%20Cluster%20in%20AWS).

2.  Go to the EC2 Container Services dashboard and create a repository with the same name as the Docker image of TIBCO BusinessEvents application. Upload the BusinessEvents application image to the repository. For help you can use the **View Push Commands** button.

    **Note:** AWS Repository name must be the same as the Docker image of TIBCO BusinessEvents application.

    For more information on how to create a repository in Amazon AWS, refer to [https://docs.aws.amazon.com/AmazonECR/latest/userguide/repository-create.html](https://docs.aws.amazon.com/AmazonECR/latest/userguide/repository-create.html).

3.  Based on your application architecture, deploy the TIBCO BusinessEvents application on the Kubernetes cluster. See the following topics based on your application persistence option:

    -   [Running the Application Without Backing Store on AWS](Deploying%20BusinessEvents%20Cluster%20for%20No%20Backing%20Store%20on%20AWS#)
    -   [Running an Application with Shared Nothing Persistence on AWS](Deploying%20BusinessEvents%20Cluster%20for%20Shared%20Nothing%20Storage%20on%20AWS#).
    -   [Running an Application with Shared All Persistence on AWS](Deploying%20BusinessEvents%20Cluster%20for%20Shared%20All%20Storage%20on%20AWS#).

-   **[Setting up a Kubernetes Cluster on AWS](Setting%20up%20a%20Kubernetes%20Cluster%20in%20AWS)**  
Set up a Kubernetes cluster with AWS for running TIBCO BusinessEvents® application.
-   **[Running the Application Without Backing Store on AWS](Deploying%20BusinessEvents%20Cluster%20for%20No%20Backing%20Store%20on%20AWS)**  
After uploading your TIBCO BusinessEvents application image with no backing store to the AWS Registry and creating the Kubernetes cluster, you can deploy your application and services to the Kubernetes cluster. The cluster manages the availability and connectivity of the application and service.
-   **[Running an Application with Shared Nothing Persistence on AWS](Deploying%20BusinessEvents%20Cluster%20for%20Shared%20Nothing%20Storage%20on%20AWS)**  
By using the Kubernetes elements such as the StatefulSets object and dynamic volume provisioning features, you can create TIBCO ActiveSpaces and Shared Nothing deployments.
-   **[Running an Application with Shared All Persistence on AWS](Deploying%20BusinessEvents%20Cluster%20for%20Shared%20All%20Storage%20on%20AWS)**  
After uploading your TIBCO BusinessEvents application Docker image with shared all storage to the AWS registry and creating Kubernetes cluster, you can deploy your application and services to the Kubernetes cluster. The cluster manages the availability and connectivity of the application and service.

**Parent topic:**[TIBCO BusinessEvents on AWS Based Kubernetes](TIBCO%20BusinessEvents%20on%20AWS%20Based%20Kubernetes)

**Related information**  


[Monitoring TIBCO BusinessEvents Applications on AWS](Monitoring%20TIBCO%20BusinessEvents%20Applications%20on%20AWS)

[Running RMS Applications in AWS Based Kubernetes](Running%20RMS%20Applications%20in%20Kubernetes)

