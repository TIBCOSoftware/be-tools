# Sample Kubernetes YAML Files for Applications with Shared Nothing Persistence

TIBCO BusinessEvents provides sample YAML files at BE_HOME\cloud\kubernetes\<cloud_name>\cache\shared-nothing for deploying TIBCO BusinessEvents application with shared nothing persistence.

**Note:** If you are using global variable group in YAML files, instead of the slash '`/`' delimiter between global variable group name and global variable name, use "`_gv_`". For example, `port` is a global variable which is part of the `VariableGP` global variable group, then instead of using `VariableGP/port` in YAML files, use `VariableGP_gv_port`. Also, ensure that you do not use the "`gv`" token in any global variable group name or global variable name.

The following tables list Kubernetes object specification files provided for cloud platforms. For details on the Kubernetes objects used and YAML files, see the [Kubernetes documentation](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/).

|Cloud Platform|File Name|Resource Type|Description|
|--------------|---------|-------------|-----------|
|OpenShift Container Platform|`persistentvol.yaml`|PersistentVolume|Set up the persistent volume for the agent in the Kubernetes cluster. Specify the name for the persistent volume, which the cache agent and inference agent uses to create persistent volume claims \(PVCs\). Specify the amount of storage to be allocated to this volume. This sample file uses the NFS plugin for the volume. Provide path of the folder that you have created, and server URL for mounting that folder.|
|Microsoft Azure|`manifest.yaml` \(for Azure disk storage\)|StorageClass|Set up the persistent volume for the Azure File provisioner type. Provide the mount options based on the Kubernetes version. For details, see [Microsoft Azure documentation](https://docs.microsoft.com/bs-cyrl-ba/azure/aks/azure-files-dynamic-pv).|
|Amazon Web Services \(AWS\)|`manifest.yaml`|ConfigMap Deployment, StorageClass|Set up the `ConfigMap` with the EFS file system details. Also, set up the deployment to create a container with the EFS provisioner and persistent volume.|
|Enterprise PKS|`manifest.yaml`|StorageClass|Set up a `StorageClass` of the GCP persistent disk in the Kubernetes cluster. Set the `provisioner` field as `kubernetes.io/gce-pd`. You can use this `StorageClass` to provision persistence volume claims for the cache and inference agents. For more information, see [Storage Classes in Kubernetes](https://kubernetes.io/docs/concepts/storage/storage-classes/#gce-pd).|

|File Name|Resource|Resource Type|Description|
|---------|--------|-------------|-----------|
|bediscovery-service.yaml|Discovery node service|Service \(Internal\)|Set up an internal service for connecting non-discovery nodes of the cluster to the discovery node. In case of the shared nothing persistence, the first cache agent node is the discovery node. Set the `selector` value as the label of the cache agent defined in becacheagent.yaml . Other nodes in the cluster use this service to connect to the discovery node. Specify `protocol` and `port` that are used by other nodes to connect to this service.|
|becacheagent.yaml|Cache agent node|StatefulSet|Set up the cache agent node of the application Docker container for the cluster. Specify the application Docker image to create the container. Specify `replicas` value \(minimum value is 1\) and start as many cache agent as specified in the value. Connect to the discovery node service using the discovery protocol and port specified in the discovery node service. Also, specify the details of the persistent volume claims based on the storage used by the cloud platform.|
|beinferenceagent.yaml|Inference agent node|StatefulSet|Set up an inference agent of the application Docker container for connecting to external APIs. Specify the application Docker image to create the container. Provide a label to the StatefulSet which the inference agent service can use as `selector`. Specify at least one replica of the inference agent node. Connect to the discovery node service using the discovery protocol and port specified in the discovery node service. Also, specify the details of the persistent volume claims based on the storage used by the cloud platform.|
|befdservice.yaml|Inference agent service|Service \(LoadBalancer/External\)|Set up an external service to connect to the inference agent. Set the `selector` value as the label of the inference agent defined in beinferenceagent.yaml. Specify `protocol` and `port` to connect to this service externally.|

**Parent topic:** [Appendix: Sample YAML Files for Kubernetes Cluster](Sample%20YAML%20Files%20for%20Kubernetes%20Cluster)

**Related topics:**  
* [Sample Kubernetes YAML Files for Applications without Backing Store](Sample%20YAML%20Files%20for%20Applications%20without%20a%20Backing%20Store)
* [Sample Kubernetes YAML Files for Applications with Shared All Persistence](Sample-Kubernetes-YAML-Files-for-Applications-with-Shared-All-Persistence)
* [Sample YAML Files for TIBCO BusinessEvents Enterprise Administrator Agent](Sample%20YAML%20Files%20for%20TIBCO%20BusinessEvents%20Enterprise%20Administrator%20Agent)
* [Sample Kubernetes YAML Files for RMS](Sample%20Kubernetes%20Resource%20YAML%20Files%20for%20RMS)

