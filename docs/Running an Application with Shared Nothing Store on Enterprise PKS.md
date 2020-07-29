# Running an Application with Shared Nothing Persistence on Enterprise PKS

After uploading your TIBCO BusinessEvents application Docker image with shared nothing persistence to Google Container Registry and creating the Kubernetes cluster, deploy and run your application on the Kubernetes cluster. The cluster manages the availability and connectivity of the application.

For shared nothing persistence, create a Storage Class of GCP persistent disk in the Kubernetes cluster. The `StorageClass` is configured in the `manifest.yaml` file. You can use this `StorageClass` to provision persistent volumes for the cache and inference agents. For more information, see "Storage Classes" in [Kubernetes Documentation](https://kubernetes.io/docs/home/).

To run the Dockerized FraudDetectionStore application with shared nothing persistence, follow the instructions in the readme.html file at BE_HOME\cloud\kubernetes\PKS\cache. Typically, sample YAML files are provided to run the application. For this deployment, the sample YAML files are available at BE_HOME\cloud\kubernetes\PKS\cache\shared-nothing. For details about these sample YAML files, see [Sample Kubernetes YAML Files for Applications with Shared Nothing Persistence](Sample%20YAML%20Files%20for%20Applications%20with%20Shared%20Nothing%20Persistence#).

-   The Kubernetes cluster must be deployed on Enterprise PKS. See [Setting Up a Kubernetes Cluster with Enterprise PKS](Setting%20up%20a%20Kubernetes%20Cluster%20With%20Enterprise%20PKS).
-   Your TIBCO BusinessEvents application Docker image must be uploaded to the Google Container Registry. See [Setting up Google Container Registry](Pushing%20Application%20Docker%20Image%20to%20Google%20Container%20Registry).

1.  Create Kubernetes object specification \(`.yaml`\) files based on your deployment requirement.

    For details about describing a Kubernetes object in a YAML file, see [Kubernetes documentation](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/). For details about the sample YAML files, see [Sample Kubernetes YAML Files for Applications with Shared Nothing Persistence](Sample%20YAML%20Files%20for%20Applications%20with%20Shared%20Nothing%20Persistence#).

2.  Create Kubernetes objects required for deploying and running the application by using the object specification \(`.yaml`\) files.

    **Syntax**:

    ```
    kubectl create -f <kubernetes_object_spec>.yaml
    ```

    For example, create the following Kubernetes objects by using the sample YAML files mentioned in [Sample Kubernetes YAML Files for Applications with Shared Nothing Persistence](Sample%20YAML%20Files%20for%20Applications%20with%20Shared%20Nothing%20Persistence#).

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


Test the application by using the external IP obtained. For example, if you have deployed the FraudDetectionStore example application with the shared nothing persistence, you can use the sample readme.html file at BE_HOME\cloud\kubernetes\PKS\cache to test the application. Use the obtained external IP in the readme.html file and follow the instructions in it to run the application.

However, if you have deployed any other sample application then update its readme.html file to test the application. Update the server address in the application readme.html file from `localhost` to the external IP obtained. Now, follow the instructions in the readme.html file for testing the application.

**Parent topic:**[Running an Application in Enterprise PKS Installed on GCP](Running%20an%20Application%20in%20PKS%20Installed%20on%20GCP)

