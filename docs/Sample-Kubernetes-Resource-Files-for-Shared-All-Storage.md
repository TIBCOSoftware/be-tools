
TIBCO BusinessEvents provides sample YAML files at `BE_HOME\cloud\kubernetes\<cloud_name>\cache\shared-all`.

**Note:** If you are using global variable group in YAML files, instead of the slash '`/`' delimiter between global variable group name and global variable name, use "`_gv_`". For example, `port` is a global variable which is part of the `VariableGP` global variable group, then instead of using `VariableGP/port` in YAML files, use `VariableGP_gv_port`. Also, ensure that you do not use the "`gv`" token in any global variable group name or global variable name.

The following tables list the sample database and common Kubernetes object specification files provided for cloud platforms. For details on the Kubernetes objects used and YAML files, see the [Kubernetes documentation](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/).

| Cloud Platform               | File Name            | Resource Type                                            | Description                                                  |
| ---------------------------- | -------------------- | -------------------------------------------------------- | ------------------------------------------------------------ |
| OpenShift Container Platform | `mysql.yaml`         | StatefulSet                                              | Set up the MySQL node with the MySQL container. Specify the CentOS based MySQL Docker image to create the container. Specify the port that you have forwarded as the container port. Specify the persistent volume claims to be used for the MySQL database. |
|| `mysql-service.yaml`         | Service \(Internal\) | Set up the service for connecting to the MySQL database. |                                                              |
||`persistent-volume-and-claim.yaml`|PersistentVolume PersistentVolumeClaim|Set up the persistent volume and persistent volume claims to be used in MySQL. The MySQL node uses this persistent volume claims for storage. Specify the amount of storage to be allocated to this volume. This sample file uses NFS plugin for the volume. Provide path of the folder that you have created, and server URL for mounting that folder.|
|Microsoft Azure \(MySQL\)|`mysql.yaml`|StatefulSet PersistentVolumeClaim|Set up the MySQL node with the MySQL container. Specify the MySQL Docker image to create the container. Specify the port that you have forwarded as the container port. Specify the PVC to be used for the MySQL database.|
||`mysql-service.yaml`|Service \(Internal\)|Set up the service for connecting to the MySQL database.|
|Enterprise PKS|`mysql.yaml`|StatefulSet|Set up the MySQL node with the `mysql` container from the Docker hub. Specify the port that you have forwarded as the container port. Define the `volume` by using the `PersistentVolumeClaim` defined in the `persistent-volume-and-claim.yaml` file for the database storage. Also provide the path of the folder to mount the volume.|
||`mysql-service.yaml`|Service \(Internal\)|Set up the service for connecting to the MySQL database.|
||`persistent-volume-claim.yaml`|StorageClass PersistentVolumeClaim|Setup the `StorageClass` with `gce-pd` provisioner and its `PersistentVolumeClaim` to be used for the MySQL database. The MySQL node uses this `PersistentVolumeClaim` for storage. Specify the amount of storage to be allocated to this `PersistentVolumeClaim`.|

| File Name            | Resource       | Resource Type | Description                                                  |
| -------------------- | -------------- | ------------- | ------------------------------------------------------------ |
| db-configmap.yaml    | ConfigMap      | ConfigMap     | Set up the environment variables for the database connection. These environment variables are used by deployment instances \(bediscoverynode.yaml, becacheagent.yaml, and beinferenceagent.yaml\) for connection to the database. |
| bediscoverynode.yaml | Discovery node | Deployment    | Set up the discovery node with the application Docker container for the starting the cluster. Specify the application Docker image to create the container. Provide a label which is used by the discovery node service as `selector`. Specify only one replica of the discovery node. Use the ConfigMap environment variables to provide database connection values for the global variables that are used in the application. |
|bediscovery-service.yaml|Discovery node service|Service \(Internal\)|Set up an internal service for connecting non-discovery nodes of the cluster to the discovery node. Specify the label of the discovery node as `selector`. Specify the `protocol` and `port` that is used by other nodes to connect to this service.|
|becacheagent.yaml|Cache agent node|Deployment|Set up the cache agent node with the application Docker container for the cluster. Specify the application Docker image to create the container. Specify `replicas` value based on the number of cache agent you want to start. Connect to the discovery node service using the discovery protocol and port specified in the discovery node service. Provide database connection values for the global variables that are used in the application, using the ConfigMap environment variables.|
|beinferenceagent.yaml|Inference agent node|Deployment|Set up an inference agent with the application Docker container for connecting to external APIs. Specify the application Docker image to create the container. Provide a label to the deployment which the inference agent service can use as `selector`. Specify at least one replica of the inference agent node. Connect to the discovery node service using the discovery protocol and port specified in the discovery node service. Provide database connection values for the global variables, that are used in the application, using the ConfigMap environment variables.|
|befdservice.yaml|Inference agent service|Service \(LoadBalancer/External\)|Set up an external service to connect to the inference agent. Specify label of the inference agent as `selector` for the service. Specify the `protocol` and `port` to connect to this service externally.|

**Parent topic:** [Appendix: Sample YAML Files for Kubernetes Cluster](Sample%20YAML%20Files%20for%20Kubernetes%20Cluster)

**Related topics:**  
* [Sample Kubernetes YAML Files for Applications without Backing Store](Sample%20YAML%20Files%20for%20Applications%20without%20a%20Backing%20Store)
* [Sample Kubernetes YAML Files for Applications with Shared Nothing Persistence](Sample%20YAML%20Files%20for%20Applications%20with%20Shared%20Nothing%20Persistence)
* [Sample YAML Files for TIBCO BusinessEvents Enterprise Administrator Agent](Sample%20YAML%20Files%20for%20TIBCO%20BusinessEvents%20Enterprise%20Administrator%20Agent)
* [Sample Kubernetes YAML Files for RMS](Sample%20Kubernetes%20Resource%20YAML%20Files%20for%20RMS)

