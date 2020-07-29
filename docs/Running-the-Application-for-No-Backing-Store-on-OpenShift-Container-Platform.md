
After uploading your TIBCO BusinessEvents application Docker image with no backing store to the OpenShift Docker registry, you can deploy your application and services to the Kubernetes cluster. The cluster manages the availability and connectivity of the application and service.

In the OpenShift Container Platform, you do not have to set up Kubernetes separately. For more information about Kubernetes and OpenShift Container Platform, see [OpenShift Container Platform documentation](https://docs.openshift.com/container-platform/latest/welcome/index.html).

TIBCO BusinessEvents provides a readme.html file at `BE_HOME\cloud\kubernetes\OpenShift\cach`e for the Dockerized FraudDetectionCache application. You can follow the instruction in the readme.html file to run the application by the using the sample YAML files. These sample YAML files are available at `BE_HOME\cloud\kubernetes\OpenShift\cache\persistence-none` for deploying TIBCO BusinessEvents application with no backing store on OpenShift Container Platform. For details about these sample YAML files, see [Sample Kubernetes YAML Files for Applications without Backing Store](Sample%20YAML%20Files%20for%20Applications%20without%20a%20Backing%20Store).
### Prerequisites
Your TIBCO BusinessEvents application must be uploaded to the OpenShift Docker registry, see [Pushing Application Docker Image to OpenShift Container Registry](Pushing%20Application%20Docker%20Image%20to%20OpenShift%20Container%20Registry).
### Procedure
1. Create the Kubernetes object specification \(`.yaml`\) files based on your deployment requirement.

   For details about describing Kubernetes objects in a YAML file, see the [Kubernetes documentation](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/). For details about the sample YAML files, see [Sample Kubernetes YAML Files for Applications without Backing Store](Sample%20YAML%20Files%20for%20Applications%20without%20a%20Backing%20Store).

2. Create Kubernetes objects required for deploying and running the application by using the object specification \(`.yaml`\) files.

   **Syntax**:

   ```
   oc create -f <kubernetes_object.yaml>
   ```

   For example, create the Kubernetes objects by using the sample YAML files mentioned in Step 1.

   ```
   oc create -f bediscoverynode.yaml
   
   oc create -f bediscovery-service.yaml
   
   oc create -f becacheagent.yaml
   
   oc create -f beinferenceagent.yaml
   
   oc create -f befdservice.yaml
   ```

3. \(Optional\) If required, you can check logs of TIBCO BusinessEvents pod.

   **Syntax**:

   ```
   oc logs <pod>
   ```

   For example, use the `oc get` command to get the list of pods and then use the `oc logs` command to view logs of `bediscoverynode`.

   ```
   oc get pods
   
   oc logs bediscoverynode-86d75d5fbc-z9gqt
   ```

4. Get the external IP of your application, which you can use to connect to the cluster.

   **Syntax**:

   ```
   oc get services <external_service_name>
   ```

   For example,

   ```
   oc get service befdservice
   ```

### What to do Next
Test the application by using the external IP obtained. For example, if you have deployed the FraudDetectionCache example application with no backing store, you can use the provided sample `readme.html` file at `BE_HOME\cloud\kubernetes\OpenShift\cache` to test the application. Provide the external IP obtained to the readme.html file and follow the instructions in it to run the application.

However, if you have deployed any other sample application then update its readme.html file to test the application. Update the server address in application `readme.html` file from `localhost` to the external IP obtained. Now, follow the instructions in the `readme.html` file for testing the application.

**Parent topic:** [Running an Application on OpenShift Based Kubernetes Cluster](Running%20an%20Application%20on%20OpenShift%20Container%20Platform%20Based%20Kubernetes%20Cluster)

**Previous topic:** [Pushing Application Docker Image to OpenShift Container Registry](Pushing%20Application%20Docker%20Image%20to%20OpenShift%20Container%20Registry)

**Related topics:**  

[Running the Application with Shared All Persistence on OpenShift Container Platform](Running%20the%20Application%20for%20Shared%20All%20Persistence%20on%20OpenShift%20Container%20Platform)

[Running the Application with Shared Nothing Persistence on OpenShift Container Platform](Running%20the%20Application%20with%20Shared%20Nothing%20Persistence%20on%20OpenShift%20Container%20Platform)

