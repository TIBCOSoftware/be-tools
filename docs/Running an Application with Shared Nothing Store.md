# Running an Application with Shared Nothing Persistence

* For shared nothing persistence, create a Storage Class of GCP persistent disk in the Kubernetes cluster. The `StorageClass` is configured in the `manifest.yaml` file. You can use this `StorageClass` to provision persistent volumes for the cache and inference agents. For more information, see "Storage Classes" in [Kubernetes Documentation](https://kubernetes.io/docs/home/).

* For this deployment, the sample YAML files are available at BE_HOME->cloud->kubernetes->cloud_name->cache->shared-nothing.

* Your TIBCO BusinessEvents application Docker image must be uploaded to respective cloud Container Registry.

1.  Create Kubernetes object specification \(`.yaml`\) files based on your deployment requirement.

    For details about describing a Kubernetes object in a YAML file, see [Kubernetes documentation](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/).

* For AWS and PKS cluster deploy the files

    ```
    kubectl create -f manifest.yaml
    ```
* For Azure cluster with azure file storageclass deploy the files

    ```
    kubectl create -f manifest.yaml
    ```
* For OpenShift and minikube deploy the files

    ```
    kubectl create -f persistent-volume.yaml
    ```

* For example, create the following Kubernetes objects by using the sample YAML files mentioned in [Sample Kubernetes YAML Files for Applications with Shared Nothing Persistence](Sample%20YAML%20Files%20for%20Applications%20with%20Shared%20Nothing%20Persistence#).

    ```

    kubectl create -f becacheagent.yaml

    kubectl create -f bediscovery-service.yaml

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
