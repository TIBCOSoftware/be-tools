# Running an Application with Shared All Persistence on AWS

After uploading your TIBCO BusinessEvents application Docker image with shared all storage to the AWS registry and creating Kubernetes cluster, you can deploy your application and services to the Kubernetes cluster. The cluster manages the availability and connectivity of the application and service.

**Note:** Ensure that your application connection properties for database use global variables.

-   A Kubernetes cluster, see [Setting up a Kubernetes Cluster on AWS](Setting%20up%20a%20Kubernetes%20Cluster%20in%20AWS).
-   An AWS service registry. For instructions, see [AWS documentation](https://docs.aws.amazon.com/ecr/).

1.  Create an Amazon RDS based instance and configure it to connect to a TIBCO BusinessEvents supported database \(Oracle, MySQL, DB2, and so on\).

    For configuration details, see [Amazon RDS documentation](https://aws.amazon.com/documentation/rds/).

2.  Create other Kubernetes object specification \(`.yaml`\) files based on your deployment requirement.

    For details about describing a Kubernetes object in a YAML file, see [Kubernetes Documentation](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/). For details about the sample YAML files, see [Sample Kubernetes YAML Files for Applications with Shared All Persistence](Sample%20Kubernetes%20Resource%20Files%20for%20Shared%20All%20Storage#).

3.  Create Kubernetes objects required for deploying and running the application by using the object specification \(`.yaml`\) files.

    For example, create the Kubernetes objects by using the sample YAML files mentioned in [Sample Kubernetes YAML Files for Applications with Shared All Persistence](Sample%20Kubernetes%20Resource%20Files%20for%20Shared%20All%20Storage#).

    ```
    kubectl create -f db-configmap.yaml
    
    kubectl create -f bediscoverynode.yaml
    
    kubectl create -f bediscovery-service.yaml
    
    kubectl create -f becacheagent.yaml
    
    kubectl create -f beinferenceagent.yaml
    
    kubectl create -f befdservice.yaml
    ```

4.  \(Optional\) If required, you can check logs of TIBCO BusinessEvents pod.

    **Syntax**:

    ```
    kubectl logs <pod>
    ```

    For example, use the `kubectl get` command to get the list of pods and then use the `kubectl logs` command to view logs of `bediscoverynode`.

    ```
    kubectl get pods
    
    kubectl logs bediscoverynode-86d75d5fbc-z9gqt
    ```

5.  Get the external IP of your application which you can use to connect to the cluster.

    **Syntax**:

    ```
    kubectl get services <external_service_name>
    ```

    For example,

    ```
    kubectl get service befdservice
    ```


Test the application by using the external IP obtained. For example, if you have deployed the FraudDetectionStore example application with shared all persistence, update its readme.html file to test the application. Update the server address in application readme.html file from `localhost` to the external IP obtained. Now, follow the instructions in the readme.html file for testing the application.

**Parent topic:**[Running TIBCO BusinessEvents® on AWS Based Kubernetes Cluster](Running%20BusinessEvents%20Applications%20in%20Kubernetes)

