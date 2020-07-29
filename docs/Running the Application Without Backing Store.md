# Running an Application without Backing Store

* For this deployment, the sample YAML files are available at BE_HOME->cloud->kubernetes->cloud_name->cache->persistence-none.



1.  Create the Kubernetes object specification \(`.yaml`\) files based on your deployment requirement.

    For details about describing Kubernetes objects in a YAML file, see the [Kubernetes documentation](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/). 


* For example, create the following Kubernetes objects by using the sample YAML files mentioned in [Sample Kubernetes YAML Files for Applications without Backing Store](Sample%20YAML%20Files%20for%20Applications%20without%20a%20Backing%20Store).

    ```
    kubectl create -f bediscoverynode.yaml

    kubectl create -f bediscovery-service.yaml

    kubectl create -f becacheagent.yaml

    kubectl create -f beinferenceagent.yaml

    kubectl create -f befdservice.yaml
    ```

2.  Get the external IP of your application which you can then use to connect to the cluster.

    **Syntax**:

    ```
    kubectl get services <external_service_name>
    ```

    For example,

    ```
    kubectl get services befdservice
    ```

## Testing

* see [Testing](Testing.md)

**Parent topic:** [Running an Application](Running%20an%20Application)
