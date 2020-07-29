# Running an Application with Shared Nothing Persistence on Azure

After uploading your TIBCO BusinessEvents application image with shared nothing persistenceto the Azure Container Registry and creating the Kubernetes cluster, you can deploy your application to the Kubernetes cluster. The cluster manages the availability and connectivity of the application. Microsoft Azure also provide storage options to store and retrieve data.

Microsoft Azure provides two storage options for persistent volumes:

-   *Azure Disks* - available for access to single node with the ReadWriteOnce privilege.
-   *Azure Files* - available for access to multiple nodes and pods.

For more information about Kubernetes concepts and Microsoft Azure, see [Azure Kubernetes Service documentation](https://docs.microsoft.com/en-us/azure/aks/).

TIBCO BusinessEvents also provides a readme.html file at BE_HOME\cloud\kubernetes\Azure\cache for the Dockerized FraudDetectionStore application. You can follow the instruction in the readme.html file to run the application by the using the provided sample YAML files. These sample YAML files are available at BE_HOME\cloud\kubernetes\azure\cache\shared-nothing\<azure_storage_type> for deploying TIBCO BusinessEvents application with shared nothing persistence on Microsoft Azure. For details about these sample YAML files, see [Sample Kubernetes YAML Files for Applications with Shared Nothing Persistence](Sample%20YAML%20Files%20for%20Applications%20with%20Shared%20Nothing%20Persistence#).

-   Your TIBCO BusinessEvents application must be uploaded to the Azure Container Registry, see [Setting Up an Azure Container Registry](Setting%20Up%20an%20Azure%20Container%20Registry).
-   The Kubernetes cluster must be deployed in the Microsoft Azure, see [Setting Up a Kubernetes Cluster on AKS](Setting%20Up%20a%20Kubernetes%20Cluster%20on%20AKS).

1.  Create Kubernetes object specification \(`.yaml`\) files based on your deployment requirement.

    For details about describing a Kubernetes object in a YAML file, see [Kubernetes documentation](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/). For details about the sample YAML files, see [Sample Kubernetes YAML Files for Applications with Shared Nothing Persistence](Sample%20YAML%20Files%20for%20Applications%20with%20Shared%20Nothing%20Persistence#).

2.  Create Kubernetes objects required for deploying and running the application by using the object specification \(`.yaml`\) files.

    **Syntax**:

    ```
    kubectl create -f <kubernetes_object_spec>.yaml
    ```

    For example, create the Kubernetes objects by using the sample YAML files mentioned in [Sample Kubernetes YAML Files for Applications with Shared Nothing Persistence](Sample%20YAML%20Files%20for%20Applications%20with%20Shared%20Nothing%20Persistence#) for Azure file storage.

    ```
    kubectl create -f manifest.yaml
    
    kubectl create -f becacheagent.yaml
    
    kubectl create -f bediscovery-service.yaml
    
    kubectl create -f beinferenceagent.yaml
    
    kubectl create -f befdservice.yaml
    ```

3.  \(Optional\) If required, you can check logs of TIBCO BusinessEvents pod.

    **Syntax**:

    ```
    kubectl logs <pod>
    ```

    For example, use the `kubectl get` command to get the list of pods and then use the `kubectl logs` command to view logs of `becacheagent`.

    ```
    kubectl get pods
    
    kubectl logs becacheagent-86d75d5fbc-z9gqt
    ```

4.  Get the external IP of your application, which you can use to connect to the cluster.

    **Syntax**

    ```
    kubectl get services <external_service_name>
    ```

    For example,

    ```
    kubectl get services befdservice
    ```


Test the application by using the external IP obtained. For example, if you have deployed the FraudDetectionStore example application with shared nothing persistence, you can use the provided sample readme.html file at BE_HOME\cloud\kubernetes\Azure\cache to test the application. Provide the external IP obtained to the readme.html file and follow the instructions in it to run the application.

However, if you have deployed any other sample application then update its readme.html file to test the application. Update the server address in application readme.html file from `localhost` to the external IP obtained. Now, follow the instructions in the readme.html file for testing the application.

**Parent topic:**[Running an Application on Microsoft Azure Based Kubernetes Cluster](Running%20an%20Application%20on%20Microsoft%20Azure%20Based%20Kubernetes%20Cluster)

**Related information**  


[Running RMS on Azure Based Kubernetes](Running%20RMS%20on%20Azure%20Based%20Kubernetes)

[Running an Application with Shared All Persistence on Azure](Running%20the%20Application%20for%20Shared%20All%20Storage%20on%20Azure)

[Running the Application Without Backing Store on Azure](Running%20the%20TIBCO%20BusinessEvents%20Application%20for%20No%20Backing%20Store)

[Setting up the Microsoft Azure CLI Environment](Setting%20Microsoft%20Azure%20CLI%20Environment)

[Setting Up a Kubernetes Cluster on AKS](Setting%20Up%20a%20Kubernetes%20Cluster%20on%20AKS)

[Setting Up an Azure Container Registry](Setting%20Up%20an%20Azure%20Container%20Registry)

