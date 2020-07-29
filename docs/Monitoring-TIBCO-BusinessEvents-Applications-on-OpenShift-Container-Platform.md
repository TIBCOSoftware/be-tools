
To monitor TIBCO BusinessEvents applications running on OpenShift Container Platform based Kubernetes, run TIBCO BusinessEvents Enterprise Administrator Agent container in the same Kubernetes namespace.

**Note:** For TIBCO BusinessEvents Enterprise Administrator Agent, you can build only Linux containers \(and not Windows containers\).

### Prerequisites

-   See [Preparing for TIBCO BusinessEvents Containerization](Before%20You%20Begin)
-   Docker image of TIBCO Enterprise Administrator server. For instructions, see readme at TEA_HOME/docker in the TIBCO Enterprise Administrator installation.
-   An TIBCO BusinessEvents application running on OpenShift Container Platform based Kubernetes, see [Running an Application on OpenShift Based Kubernetes Cluster](Running%20an%20Application%20on%20OpenShift%20Container%20Platform%20Based%20Kubernetes%20Cluster#)

### Procedure

1. Build the TIBCO BusinessEvents Enterprise Administrator Agent Docker image by using the script provided by TIBCO BusinessEvents.

   See [Building TIBCO BusinessEvents Enterprise Administrator Agent Docker Image](Building%20TIBCO%20BusinessEvents%20Enterprise%20Administrator%20Agent%20Docker%20Image#).

2. Push Docker images of TIBCO BusinessEvents Enterprise Administrator Agent and TIBCO Enterprise Administrator server to OpenShift Container Registry.

   For details, see [Pushing Application Docker Image to OpenShift Container Registry](Pushing%20Application%20Docker%20Image%20to%20OpenShift%20Container%20Registry).

3. Run the TIBCO Enterprise Administrator server on OpenShift Container Platform based Kubernetes.

   For instructions, refer readme at TEA_HOME/docker in the TIBCO Enterprise Administrator installation.

4. Update the following Kubernetes object specification \(`.yaml`\) files for TIBCO BusinessEvents Enterprise Administrator Agent:

   -   beteagentdeploymemt.yaml - A deployment of TIBCO BusinessEvents Enterprise Administrator Agent Docker image with the TIBCO Enterprise Administrator server URL and login details.
   -   beteagentinternalservice.yaml - An internal service for connecting to TIBCO BusinessEvents Enterprise Administrator Agent from other nodes
   -   k8s-authorization.yaml - A ClusterRoleBinding for binding roles to the user.
       These object specification files are available at BE_HOME\cloud\kubernetes\<cloud_name>\tea. For details about describing a Kubernetes object in a YAML file, see [Kubernetes Documentation](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/). For details about the sample YAML files, see [Sample YAML Files for TIBCO BusinessEvents Enterprise Administrator Agent](Sample%20YAML%20Files%20for%20TIBCO%20BusinessEvents%20Enterprise%20Administrator%20Agent#).

5. Create Kubernetes objects required for deploying and running TIBCO BusinessEvents Enterprise Administrator Agent by using the object specification \(`.yaml`\) files.

   **Syntax**:

   ```
   oc create -f <kubernetes_object.yaml>
   ```

   For example, create the Kubernetes objects by using the sample YAML files mentioned in [Sample YAML Files for TIBCO BusinessEvents Enterprise Administrator Agent](Sample%20YAML%20Files%20for%20TIBCO%20BusinessEvents%20Enterprise%20Administrator%20Agent#).

   ```
   oc create -f k8s-authorization.yaml
   
   oc create -f beteagentdeploymemt.yaml
   
   oc create -f beteagentinternalservice.yaml
   
   ```

6. \(Optional\) If required, you can check the logs of TIBCO BusinessEvents Enterprise Administrator Agent pod.

   **Syntax**:

   ```
   oc logs <pod>
   ```

   For example, use the `oc get` command for a list of pods and then use the `oc logs` command to view the logs of `beteagentdeploymemt`.

   ```
   oc get pods
   
   oc logs beteagentdeploymemt-86d75d5fbc-z9gqt
   ```

### What to do Next
Launch TIBCO Enterprise Administrator in a web browser by using the external IP and port obtained from the TIBCO Enterprise Administrator external service.

For more details about the functioning of TIBCO BusinessEvents Enterprise Administrator Agent, see *TIBCO BusinessEvents Administration*..

**Parent topic:** [TIBCO BusinessEvents on OpenShift Container Platform Based Kubernetes](TIBCO%20BusinessEvents%20on%20OpenShift%20Container%20Platform%20Based%20Kubernetes)

**Related topics:**  

* [Running an Application on OpenShift Based Kubernetes Cluster](Running%20an%20Application%20on%20OpenShift%20Container%20Platform%20Based%20Kubernetes%20Cluster)

* [Running the RMS on OpenShift Container Platform](Running%20the%20RMS%20on%20OpenShift%20Container%20Platform)

