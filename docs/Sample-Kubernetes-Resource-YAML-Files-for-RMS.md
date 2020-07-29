# Sample Kubernetes YAML Files for RMS

TIBCO BusinessEvents provides sample YAML files at BE_HOME\cloud\kubernetes\rms.

**Note:** If you are using global variable group in YAML files, instead of the slash '`/`' delimiter between global variable group name and global variable name, use "`_gv_`". For example, `port` is a global variable which is part of the `VariableGP` global variable group, then instead of using `VariableGP/port` in YAML files, use `VariableGP_gv_port`. Also, ensure that you do not use the "`gv`" token in any global variable group name or global variable name.

The following tables list the sample Kubernetes object specification files provided for cloud platforms. For details on the Kubernetes objects used and YAML files, see the [Kubernetes documentation](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/).

|Cloud Platform|File Name|Resource Type|Description|
|--------------|---------|-------------|-----------|
|OpenShift Container Platform|`persistent-volume.yaml`|PersistentVolume|Set up persistent volumes to provision storage for the following RMS artifacts: <ul><li>Project hot deployed artifacts \(`webstudio-pv`\)</li><li>Project shared files \(`shared-pv`\)</li> <li>Project ACLs \(`security-pv`\)</li> <li>Email notifications \(`notify-pv`\)</li></ul> Specify the amount of storage to be allocated to these volumes. This sample file uses the NFS plugin for the volume. Provide path of the folder that you have created, and server URL for mounting that folder. Use these persistent volumes in `persistent-volume-claims.yaml` to provision persistent volume claims for the storage of RMS artifacts.|
||`persistent-volume-claims.yaml`|PersistentVolumeClaim|Set up the persistent volume claims to store the following RMS artifacts by using the respective `PersistentVolume` defined in `persistent-volume.yaml`: <ul> <li>Project hot deployed artifacts \(`webstudio-pvc`\)</li> <li>Project shared files \(`shared-pvc`\)</li> <li>Project ACLs \(`security-pvc`\)</li> <li>Email notifications \(`notify-pvc`\)</li> </ul>Use these persistent volume claims in the inference agent beinferenceagent.yaml to mount volumes for RMS artifacts storage.|
|Microsoft Azure \(MySQL\)|`persistent-volume-claims.yaml`|PersistentVolumeClaim|Set up the `StorageClass` object with the Azure File \(`azure-file`\) provisioner. This `StorageClass` is used to provision persistent volume claims for storage of the following RMS artifacts: <ul> <li>Project hot deployed artifacts \(`azurefile-webstudio`\)</li> <li>Project shared files \(`azurefile-shared`\)</li> <li>Project ACLs \(`azurefile-security`\)</li> <li>Email notifications \(`azurefile-notify`\)</li> </ul>Use these persistent volume claims in the inference agent beinferenceagent.yaml to mount volumes for RMS artifacts storage.|
|Enterprise PKS|`manifest_gcp.yaml`|StorageClass|Set the `StorageClass` object with the GCP persistent disk \(`gce-pd`\) provisioner. This `StorageClass` is used to provision persistent volume claims for storage of RMS artifacts.|
||`persistent-volume-claims.yaml`|PersistentVolumeClaim|Set up the persistent volume claims to store the following RMS artifacts by using the `StorageClass` defined in `manifest_gcp.yaml`:<ul> <li>Project hot deployed artifacts \(`webstudio-pvc`\)</li> <li>Project shared files \(`shared-pvc`\)</li> <li>Project ACLs \(`security-pvc`\)</li> <li>Email notifications \(`notify-pvc`\)</li> </ul>Use these persistent volume claims in the inference agent beinferenceagent.yaml to mount volumes for RMS artifacts storage.|

|File Name|Resource|Resource Type|Description|
|---------|--------|-------------|-----------|
|bediscoverynode.yaml|Discovery node|Deployment|Set up the container with the docker image of the application. Provide a label to the deployment which the discovery node service can use as `selector`. Specify only one replica of the discovery node. Provide the JMX Kubernetes service name created earlier \(`bejmx-service.default.svc.cluster.local`\) as the value of `DOCKER_HOST`. Specify the volume mounts to use the shared persistent volume claims created earlier.|
|bediscovery-service.yaml|Discovery node service|Service \(Internal\)|Set up the service to connect to the discovery node. Specify the label of the discovery node as the value of `selector`. Other nodes in the cluster use this service to connect to the discovery node. Specify the `protocol` and `port` to connect to this service.|
|becacheagent.yaml|Cache agent node|Deployment|Set up the container with the docker image of the application. Specify `replicas` value and start as many cache agent as specified in the value. Connect to the discovery node service using the discovery protocol and port specified in the discovery node service. Provide the JMX Kubernetes service name created earlier \(`bejmx-service.default.svc.cluster.local`\) as the value of `DOCKER_HOST`. Specify the volume mounts to use the shared persistent volume claims created earlier.|
|beinferenceagent.yaml|Inference agent node|Deployment|Set up the container with the docker image of the application. Provide a label to the deployment which the JMX service can use as `selector`. Specify at least one replica of the inference agent node. Connect to the discovery node service using the discovery protocol and port specified in the discovery node service. Provide the JMX Kubernetes service name created earlier \(for example, `bejmx-service.default.svc.cluster.local`\) as the value of `DOCKER_HOST`. Specify the volume mounts to use the shared persistent volume claims for storing artifacts.|
|befdservice.yaml|Inference agent service|Service \(LoadBalancer/External\)|Set up an external service to connect to the inference agent. Specify label of the inference agent as value of `selector` for the service. Specify the `protocol` and `port` to connect to this service externally.|
|berms.yaml|Discovery node|Deployment|Set up the container with the RMS docker image. Provide a label to the deployment which the RMS node service can use as `selector`. Specify the volume mounts to use the shared persistent volume claims created earlier.|
|berms-service.yaml|Discovery node service|Service \(LoadBalancer/External\)|Set up the service to externally connect to the RMS node. Specify the label of the RMS node as the value of `selector`. Specify the `protocol` and `port` to connect to this service.|
|bejmx-service.yaml|JMX service|Service \(Internal\)|Set up the service for RMS to connect to the JMX port of the inference agent. Set up the label of the inference agent as the value of the `selector` variable for connection. Specify the `protocol` and `port` to connect to this service.|

**Parent topic:**[Appendix: Sample YAML Files for Kubernetes Cluster](Sample%20YAML%20Files%20for%20Kubernetes%20Cluster)

**Related information**  


[Sample Kubernetes YAML Files for Applications without Backing Store](Sample%20YAML%20Files%20for%20Applications%20without%20a%20Backing%20Store)

[Sample Kubernetes YAML Files for Applications with Shared Nothing Persistence](Sample%20YAML%20Files%20for%20Applications%20with%20Shared%20Nothing%20Persistence)

[Sample Kubernetes YAML Files for Applications with Shared All Persistence](Sample-Kubernetes-YAML-Files-for-Applications-with-Shared-All-Persistence)

[Sample YAML Files for TIBCO BusinessEvents Enterprise Administrator Agent](Sample%20YAML%20Files%20for%20TIBCO%20BusinessEvents%20Enterprise%20Administrator%20Agent)

