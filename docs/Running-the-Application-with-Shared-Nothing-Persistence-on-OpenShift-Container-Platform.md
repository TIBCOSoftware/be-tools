
After uploading your TIBCO BusinessEvents application Docker image with shared nothing persistence to the OpenShift Docker registry, you can deploy your application and services to the Kubernetes cluster. The cluster manages the availability and connectivity of the application and service.

In OpenShift Container Platform, you do not have to setup Kubernetes separately. For more information about Kubernetes and OpenShift Container Platform, see [OpenShift Container Platform documentation](https://docs.openshift.com/container-platform/latest/welcome/index.html).

TIBCO BusinessEvents provides a readme.html file at `BE_HOME\cloud\kubernetes\OpenShift\cache` for the Dockerized FraudDetectionStore application. You can follow the instruction in the readme.html file to run the application by the using the provided sample YAML files. These sample YAML files are available at `BE_HOME\cloud\kubernetes\OpenShift\cache\shared-nothing` for deploying TIBCO BusinessEvents application with shared nothing persistence on OpenShift Container Platform. For details about these sample YAML files, see [Sample Kubernetes YAML Files for Applications with Shared Nothing Persistence](Sample%20YAML%20Files%20for%20Applications%20with%20Shared%20Nothing%20Persistence#).
### Prerequisites
Your TIBCO BusinessEvents application must be uploaded to the OpenShift Docker registry, see [Pushing Application Docker Image to OpenShift Container Registry](Pushing%20Application%20Docker%20Image%20to%20OpenShift%20Container%20Registry).
### Procedure
1. Create the persistent volume folders with NFS on the master node and make them accessible from remote server. For details about sharing the folder, refer to your operating system documentation.

   For example, the following steps create a new folder on the system and make it accessible from remote server.

   1. Create a new directory `pv001` and change its permission to read, write, and execute.

      ```
      mkdir -p /home/data/pv001
      chmod -R 777 /home/data/
      ```

   2. Edit the `/etc/exports` file and add the following entry for the new folder.

      ```
      /home/data/pv0001 *(rw,sync)
      ```

   3. Export the file system to the remote server which can mount the folder and use it as local file system. If you are connected to the remote server, do not mention the remote server URL in the command.

      ```
      exportfs -a
      ```

2. Create an object definition \(`.yaml`\) file for the persistent volume \(PV\) by using the folder path and URL of machine in which the folder was created.

3. Create other Kubernetes object specification \(`.yaml`\) files based on your deployment requirement.

   For details about describing a Kubernetes object in a YAML file, see [Kubernetes documentation](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/). For details about the sample YAML files, see [Sample Kubernetes YAML Files for Applications with Shared Nothing Persistence](Sample%20YAML%20Files%20for%20Applications%20with%20Shared%20Nothing%20Persistence#).

4. Create Kubernetes objects required for deploying and running the application by using the object specification \(`.yaml`\) files.

   **Syntax**:

   ```
   oc create -f <kubernetes_object.yaml>
   ```

   For example, create the Kubernetes objects by using the sample YAML files mentioned in [Sample Kubernetes YAML Files for Applications with Shared Nothing Persistence](Sample%20YAML%20Files%20for%20Applications%20with%20Shared%20Nothing%20Persistence#) .

   ```
   oc create -f persistentvol.yaml
   
   oc create -f becacheagent.yaml
   
   oc create -f bediscovery-service.yaml
   
   oc create -f beinferenceagent.yaml
   
   oc create -f befdservice.yaml
   ```

5. \(Optional\) If required, you can check logs of TIBCO BusinessEvents pod.

   Syntax:

   ```
   oc logs <pod>
   ```

   For example, use the `oc get` command to get the list of pods and then use the `oc logs` command to view logs of `becacheagent`.

   ```
   oc get pods
   
   oc logs becacheagent-86d75d5fbc-z9gqt
   ```

6. Get the external IP of your application which you can use to connect to the cluster.

   **Syntax**:

   ```
   oc get services <external_service_name>
   ```

   For example,

   ```
   oc get service befdservice
   ```

### What to do Next

Test the application by using the external IP obtained. For example, if you have deployed the FraudDetectionStore example application with shared nothing persistence, you can use the provided sample readme.html file at `BE_HOME\cloud\kubernetes\OpenShift\cache` to test the application. Provide the external IP obtained to the readme.html file and follow the instructions in it to run the application.

However, if you have deployed any other sample application, then update its readme.html file to test the application. Update the server address in application readme.html file from `localhost` to the external IP obtained. Now, follow the instructions in the readme.html file for testing the application.

**Parent topic:** [Running an Application on OpenShift Based Kubernetes Cluster](Running%20an%20Application%20on%20OpenShift%20Container%20Platform%20Based%20Kubernetes%20Cluster)

**Previous topic:** [Pushing Application Docker Image to OpenShift Container Registry](Pushing%20Application%20Docker%20Image%20to%20OpenShift%20Container%20Registry)

**Related topics:**  

* [Running the Application Without Backing Store on OpenShift Container Platform](Running%20the%20Application%20for%20No%20Backing%20Store%20on%20OpenShift%20Container%20Platform)

* [Running the Application with Shared All Persistence on OpenShift Container Platform](Running%20the%20Application%20for%20Shared%20All%20Persistence%20on%20OpenShift%20Container%20Platform)