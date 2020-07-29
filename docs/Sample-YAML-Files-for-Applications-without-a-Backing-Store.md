# Sample Kubernetes YAML Files for Applications without Backing Store

TIBCO BusinessEvents provides sample YAML files for deploying the TIBCO BusinessEvents application without a backing store at BE_HOME\cloud\kubernetes\<cloud_name>\cache\persistence-none.

**Note:** If you are using global variable group in YAML files, instead of the slash '`/`' delimiter between global variable group name and global variable name, use "`_gv_`". For example, `port` is a global variable which is part of the `VariableGP` global variable group, then instead of using `VariableGP/port` in YAML files, use `VariableGP_gv_port`. Also, ensure that you do not use the "`gv`" token in any global variable group name or global variable name.

The following tables list Kubernetes object specification files provided for cloud platforms. For details on the Kubernetes objects used and YAML files, see the [Kubernetes documentation](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/).

|File Name|Resource|Resource Type|Description|
|---------|--------|-------------|-----------|
|bediscoverynode.yaml|Discovery node|Deployment|Set up the discovery node with the application Docker container for starting the cluster. Specify the application Docker image to create the container. This label which is used by the discovery node service as `selector`. Specify only one replica of the discovery node.|
|bediscovery-service.yaml|Discovery node service|Service \(Internal\)|Set up an internal service for connecting non-discovery nodes of the cluster to the discovery node. Specify the label of the discovery node as `selector`. Specify `protocol` and `port` that is used by other nodes to connect to this service.|
|becacheagent.yaml|Cache agent node|Deployment|Set up the cache agent node with the application Docker container for the cluster. Specify the application Docker image to create the container. Specify `replicas` value based on the number of cache agent you want to start. Connect to the discovery node service using the discovery protocol and port specified in the discovery node service.|
|beinferenceagent.yaml|Inference agent node|Deployment|Set up an inference agent with the application Docker container for connecting to external APIs. Specify the application Docker image to create the container. Provide a label to the deployment which the inference agent service can use as `selector`. Specify at least one replica of the inference agent node. Connect to the discovery node service using the discovery protocol and port specified in the discovery node service.|
|befdservice.yaml|Inference agent service|Service \(LoadBalancer/External\)|Set up an external service to connect to the inference agent. Specify label of the inference agent as `selector` for the service. Specify the `protocol` and `port` to connect to this service externally.|

## Kubernetes Cluster Diagram

The following diagram shows the connections between different Kubernetes objects defined by using the sample YAML files \(listed in the previous table\) for deploying TIBCO BusinessEvents application without backing store.

![](Kubernetes%20(application%20without%20backing%20store).png "Kubernetes Cluster Diagram for an Application without Backing Store ")

**Parent topic:**[Appendix: Sample YAML Files for Kubernetes Cluster](Sample%20YAML%20Files%20for%20Kubernetes%20Cluster)

**Related topics:**  
* [Sample Kubernetes YAML Files for Applications with Shared Nothing Persistence](Sample%20YAML%20Files%20for%20Applications%20with%20Shared%20Nothing%20Persistence)
* [Sample Kubernetes YAML Files for Applications with Shared All Persistence](Sample-Kubernetes-YAML-Files-for-Applications-with-Shared-All-Persistence)
* [Sample YAML Files for TIBCO BusinessEvents Enterprise Administrator Agent](Sample%20YAML%20Files%20for%20TIBCO%20BusinessEvents%20Enterprise%20Administrator%20Agent)
* [Sample Kubernetes YAML Files for RMS](Sample%20Kubernetes%20Resource%20YAML%20Files%20for%20RMS)

