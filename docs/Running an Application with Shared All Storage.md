# Running an Application with Shared All Persistence

* For the shared all persistence, configure a database server and define a storage for its database. For example, you can use a MySQL server for database connections. To implement the database, you can use the `mysql` container from the Docker hub. Provide the database connection details in the cache and inference agent configuration files. Define a Storage Class respective to cloud provider for storage class provisioner to provision storage \(persistent volume claim\) for the MySQL database.

* For this deployment, the sample YAML files are available at BE_HOME->cloud->kubernetes->cloud_name->cache->shared-all.


1.  Create the Kubernetes object specification \(`.yaml`\) files based on your deployment requirement.

    For details about describing a Kubernetes object in a YAML file, see [Kubernetes documentation](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/). 

* For example, create the following Kubernetes objects by using the sample YAML files mentioned in [Sample Kubernetes YAML Files for Applications with Shared All Persistence](Sample%20Kubernetes%20Resource%20Files%20for%20Shared%20All%20Storage#).

    ```

    kubectl create -f db-configmap.yaml

    kubectl create -f bediscoverynode.yaml

    kubectl create -f bediscovery-service.yaml

    kubectl create -f becacheagent.yaml

    kubectl create -f beinferenceagent.yaml

    kubectl create -f befdservice.yaml
    ```

2.  \(Optional\) If required, you can check logs of TIBCO BusinessEvents pod.

    **Syntax**:

    ```
    kubectl logs <pod>
    ```

    For example, use the `kubectl get` command to get the list of pods and then use the `kubectl logs` command to view logs of `becacheagent`.

    ```
    kubectl get pods

    kubectl logs becacheagent-86d75d5fbc-z9gqt
    ```

3.  Get the external IP of your application, which you can use to connect to the cluster.

    **Syntax**

    ```
    kubectl get services <external_service_name>
    ```

    For example,

    ```
    kubectl get services befdservice
    ```


## Testing

* see [Testing](Testing.md)

**Parent topic:**[Running an Application](Running%20an%20Application)
