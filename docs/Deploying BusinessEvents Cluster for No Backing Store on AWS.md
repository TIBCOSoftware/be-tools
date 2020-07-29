# Running the Application Without Backing Store on AWS

After uploading your TIBCO BusinessEvents application image with no backing store to the AWS Registry and creating the Kubernetes cluster, you can deploy your application and services to the Kubernetes cluster. The cluster manages the availability and connectivity of the application and service.

For deploying BusinessEvents cluster for No Backing Store on AWS, you must first set up Kubernetes cluster on AWS and then upload your Docker image on AWS. For more information, see [Running TIBCO BusinessEvents® on AWS Based Kubernetes Cluster](Running%20BusinessEvents%20Applications%20in%20Kubernetes#).

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


Test the application by using the external IP obtained. For example, if you have deployed the FraudDetectionCache example application with no backing store, update its readme.html file to test the application. Update the server address in application readme.html file from `localhost` to the external IP obtained. Now, follow the instructions in the readme.html file for testing the application.

**Parent topic:**[Running TIBCO BusinessEvents® on AWS Based Kubernetes Cluster](Running%20BusinessEvents%20Applications%20in%20Kubernetes)

