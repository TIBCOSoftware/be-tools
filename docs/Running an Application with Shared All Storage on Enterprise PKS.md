# Running an Application with Shared All Persistence on Enterprise PKS

After uploading your TIBCO BusinessEvents application image with shared all persistence to the Google Container Registry and creating the Kubernetes cluster, you can deploy your application to the Kubernetes cluster. The cluster manages the availability and connectivity of the application. You can use the Docker image of the database that you want to use.

For the shared all persistence, configure a database server and define a storage for its database. For example, you can use a MySQL server for database connections. To implement the database, you can use the `mysql` container from the Docker hub. Provide the database connection details in the cache and inference agent configuration files. Define a Storage Class object of the GCP persistent disk \(`gce-pd`\) provisioner to provision storage \(persistent volume claim\) for the MySQL database.

TIBCO BusinessEvents provides a readme.html file at BE_HOME\cloud\kubernetes\PKS\cache for the Dockerized FraudDetectionStore application. You can follow the instructions in the readme.html file to run the application by the using the sample YAML files. These sample YAML files for deploying TIBCO BusinessEvents application with the shared all persistence on Enterprise PKS are available at BE_HOME\cloud\kubernetes\PKS\cache\shared-all. For details about these sample YAML files, see [Sample Kubernetes YAML Files for Applications with Shared All Persistence](Sample%20Kubernetes%20Resource%20Files%20for%20Shared%20All%20Storage#).

1.  Create the Kubernetes object specification \(`.yaml`\) files based on your deployment requirement.

    For details about describing a Kubernetes object in a YAML file, see [Kubernetes documentation](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/). For details about the sample YAML files, see [Sample Kubernetes YAML Files for Applications with Shared All Persistence](Sample%20Kubernetes%20Resource%20Files%20for%20Shared%20All%20Storage#).

2.  Create Kubernetes objects required for deploying and running the application by using the object specification \(`.yaml`\) files.

    **Syntax**:

    ```
    kubectl create -f <kubernetes_object_spec>.yaml
    ```

    For example, create the following Kubernetes objects by using the sample YAML files mentioned in [Sample Kubernetes YAML Files for Applications with Shared All Persistence](Sample%20Kubernetes%20Resource%20Files%20for%20Shared%20All%20Storage#).

    ```
    kubectl create -f persistent-volume-claim.yaml
    
    kubectl create -f mysql.yaml
    
    kubectl create -f mysql-service.yaml
    
    kubectl create -f db-configmap.yaml
    
    kubectl create -f bediscoverynode.yaml
    
    kubectl create -f bediscovery-service.yaml
    
    kubectl create -f becacheagent.yaml
    
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


Test the application by using the external IP obtained. For example, if you have deployed the FraudDetectionStore example application with the shared all persistence, you can use the sample readme.html file at BE_HOME\cloud\kubernetes\PKS\cache to test the application. Use the obtained external IP in the readme.html file and follow the instructions in it to run the application.

However, if you have deployed any other sample application then update its readme.html file to test the application. Update the server address in application readme.html file from `localhost` to the external IP obtained. Now, follow the instructions in the readme.html file for testing the application.

**Parent topic:**[Running an Application in Enterprise PKS Installed on GCP](Running%20an%20Application%20in%20PKS%20Installed%20on%20GCP)

