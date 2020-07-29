# Running an Application without Backing Store on Enterprise PKS

After uploading the Docker image of your TIBCO BusinessEvents application without backing store to Google Container Registry, you can deploy your application to the Pivotal based Kubernetes cluster. The cluster manages the availability and connectivity of the application and service.

TIBCO BusinessEvents provides a readme.html file at BE_HOME\cloud\kubernetes\PKS\cache for the Dockerized FraudDetectionCache application. You can follow the instructions given in the readme.html file to run the application by the using sample YAML files. These sample YAML files are available at BE_HOME\cloud\kubernetes\PKS\cache\persistence-none for deploying TIBCO BusinessEvents application without backing store on Enterprise PKS. For details about these sample YAML files, see [Sample Kubernetes YAML Files for Applications without Backing Store](Sample%20YAML%20Files%20for%20Applications%20without%20a%20Backing%20Store#).

-   The Kubernetes cluster must be deployed on Enterprise PKS. See [Setting Up a Kubernetes Cluster with Enterprise PKS](Setting%20up%20a%20Kubernetes%20Cluster%20With%20Enterprise%20PKS).
-   Your TIBCO BusinessEvents application Docker image must be uploaded to the Google Container Registry. See [Setting up Google Container Registry](Pushing%20Application%20Docker%20Image%20to%20Google%20Container%20Registry).

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


Test the application by using the external IP obtained. For example, if you have deployed the FraudDetectionCache example application without backing store, you can use the sample readme.html file at BE_HOME\cloud\kubernetes\PKS\cache to test the application. Use the obtained external IP in the readme.html file and follow the instructions in it to run the application.

However, if you have deployed any other sample application, update its readme.html file to test that application. Update the server address in application readme.html file from `localhost` to the external IP obtained. Now, follow the instructions in the readme.html file for testing the application.

**Parent topic:**[Running an Application in Enterprise PKS Installed on GCP](Running%20an%20Application%20in%20PKS%20Installed%20on%20GCP)

