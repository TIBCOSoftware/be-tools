# Sample YAML Files for TIBCO BusinessEvents Enterprise Administrator Agent

TIBCO BusinessEvents provides sample YAML files at BE_HOME\cloud\kubernetes\<cloud_name>\tea for deploying TIBCO BusinessEvents Enterprise Administrator Agent for monitoring TIBCO BusinessEvents applications.

**Note:** If you are using global variable group in YAML files, instead of the slash '`/`' delimiter between global variable group name and global variable name, use "`_gv_`". For example, `port` is a global variable which is part of the `VariableGP` global variable group, then instead of using `VariableGP/port` in YAML files, use `VariableGP_gv_port`. Also, ensure that you do not use the "`gv`" token in any global variable group name or global variable name.

The following tables list the sample database and common Kubernetes object specification files provided for cloud platforms. For details on the Kubernetes objects used and YAML files, see the [Kubernetes documentation](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/).

|File Name|Resource|Resource Type|Description|
|---------|--------|-------------|-----------|
|beteagentdeploymemt.yaml|TIBCO BusinessEvents Enterprise Administrator Agent node|Deployment|Set up the node with the TIBCO BusinessEvents Enterprise Administrator Agent Docker container. Specify the TIBCO BusinessEvents Enterprise Administrator Agent Docker image to create the container. Provide a label which is used by the `beteagentinternalservice` service as `selector`. Specify only one replica of the node. Specify the TIBCO Enterprise Administrator server URL obtained from the TIBCO Enterprise Administrator server external service and login credentials.|
|beteagentinternalservice.yaml|TIBCO BusinessEvents Enterprise Administrator Agent node service|Service \(Internal\)|Set up an internal service for connecting TIBCO Enterprise Administrator server to TIBCO BusinessEvents Enterprise Administrator Agent. Specify the label of the TIBCO BusinessEvents Enterprise Administrator Agent node as `selector`. Specify the `protocol` and `port` that is used by other nodes to connect to this service.|
|k8s-authorization.yaml|Authorization|ClusterRoleBinding|Assign roles to the users in TIBCO Enterprise Administrator in the same Kubernetes namespace.|

**Parent topic:**[Appendix: Sample YAML Files for Kubernetes Cluster](Sample%20YAML%20Files%20for%20Kubernetes%20Cluster)

**Related topics:**  

* [Sample Kubernetes YAML Files for Applications without Backing Store](Sample%20YAML%20Files%20for%20Applications%20without%20a%20Backing%20Store)

* [Sample Kubernetes YAML Files for Applications with Shared Nothing Persistence](Sample%20YAML%20Files%20for%20Applications%20with%20Shared%20Nothing%20Persistence)

* [Sample Kubernetes YAML Files for Applications with Shared All Persistence](Sample-Kubernetes-YAML-Files-for-Applications-with-Shared-All-Persistence)

* [Sample Kubernetes YAML Files for RMS](Sample%20Kubernetes%20Resource%20YAML%20Files%20for%20RMS)

