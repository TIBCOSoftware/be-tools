# Running the Application Without Backing Store on Azure

After uploading your TIBCO BusinessEvents application image with no backing store to the Azure Container Registry and creating the Kubernetes cluster, you can deploy your application and services to the Kubernetes cluster. The cluster manages the availability and connectivity of the application and service.

For more information about Kubernetes concepts and Microsoft Azure, see [Azure Kubernetes Service documentation](https://docs.microsoft.com/en-us/azure/aks/).

TIBCO BusinessEvents provides a readme.html file at BE_HOME\cloud\kubernetes\Azure\cache for the Dockerized FraudDetectionCache application. You can follow the instruction in the readme.html file to run the application by the using the provided sample YAML files. These sample YAML files are available at BE_HOME\cloud\kubernetes\Azure\cache\persistence-none for deploying TIBCO BusinessEvents application with no backing store on Microsoft Azure. For details about these sample YAML files, see [Sample Kubernetes YAML Files for Applications without Backing Store](Sample%20YAML%20Files%20for%20Applications%20without%20a%20Backing%20Store#).

-   Your TIBCO BusinessEvents application must be uploaded to the Azure Container Registry, see [Setting Up an Azure Container Registry](Setting%20Up%20an%20Azure%20Container%20Registry).
-   The Kubernetes cluster must be deployed in the Microsoft Azure, see [Setting Up a Kubernetes Cluster on AKS](Setting%20Up%20a%20Kubernetes%20Cluster%20on%20AKS).

1.  Create the Kubernetes object specification \(`.yaml`\) files based on your deployment requirement.

    For details about describing Kubernetes objects in a YAML file, see the [Kubernetes documentation](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/). For details about the sample YAML files, see [Sample Kubernetes YAML Files for Applications without Backing Store](Sample%20YAML%20Files%20for%20Applications%20without%20a%20Backing%20Store#).

2.  Create Kubernetes objects required for deploying and running the application by using object specification \(`.yaml`\) files.

    **Syntax**:

    ```
    kubectl create -f <kubernetes_object.yaml>
    ```

    For example, create the following Kubernetes objects by using the sample YAML files mentioned in [Sample Kubernetes YAML Files for Applications without Backing Store](Sample%20YAML%20Files%20for%20Applications%20without%20a%20Backing%20Store).

    ```
    kubectl create -f bediscoverynode.yaml
    
    kubectl create -f bediscovery-service.yaml
    
    kubectl create -f becacheagent.yaml
    
    kubectl create -f beinferenceagent.yaml
    
    kubectl create -f befdservice.yaml
    ```

3.  \(Optional\) If required, you can also check logs of TIBCO BusinessEvents pods.

    **Syntax**:

    ```
    kubectl logs <pod>
    ```

    For example, use the `kubectl get` command to get list of pods and then use the `kubectl logs` command to view logs of `bediscoverynode`.

    ```
    kubectl get pods
    
    kubectl logs bediscoverynode-86d75d5fbc-z9gqt
    ```

4.  Get the external IP of your application which you can then use to connect to the cluster.

    **Syntax**:

    ```
    kubectl get services <external_service_name>
    ```

    For example,

    ```
    kubectl get services befdservice
    ```


Test the application by using the external IP obtained. For example, if you have deployed the FraudDetectionCache example application without backing store, you can use the sample readme.html file at BE_HOME\cloud\kubernetes\Azure\cache to test the application. Use the external IP that you have obtained in the readme.html file and follow the instructions in it to run the application.

However, if you have deployed any other sample application, update its readme.html file to test that application. Update the server address in application readme.html file from `localhost` to the external IP obtained. Now, follow the instructions in the readme.html file for testing the application.

**Parent topic:**[Running an Application on Microsoft Azure Based Kubernetes Cluster](Running%20an%20Application%20on%20Microsoft%20Azure%20Based%20Kubernetes%20Cluster)

**Related information**  


[Running an Application with Shared Nothing Persistence on Azure](Running%20an%20Application%20with%20Shared%20Nothing%20Storage%20on%20Azure)

[Running RMS on Azure Based Kubernetes](Running%20RMS%20on%20Azure%20Based%20Kubernetes)

[Running an Application with Shared All Persistence on Azure](Running%20the%20Application%20for%20Shared%20All%20Storage%20on%20Azure)

[Setting up the Microsoft Azure CLI Environment](Setting%20Microsoft%20Azure%20CLI%20Environment)

[Setting Up a Kubernetes Cluster on AKS](Setting%20Up%20a%20Kubernetes%20Cluster%20on%20AKS)

[Setting Up an Azure Container Registry](Setting%20Up%20an%20Azure%20Container%20Registry)

