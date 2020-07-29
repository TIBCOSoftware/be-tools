
To use TIBCO BusinessEvents WebStudio in OpenShift Container Platform, you must set up TIBCO BusinessEvents and Rule Management Server \(RMS\) in OpenShift Container Platform based Kubernetes.

In OpenShift Container Platform, you do not have to setup Kubernetes separately. For more information about Kubernetes and OpenShift Container Platform, see [OpenShift Container Platform documentation](https://docs.openshift.com/container-platform).

TIBCO BusinessEvents provides a `readme.html` file at `BE_HOME\cloud\kubernetes\OpenShift\rms` for the Dockerized CreditCardApplication project and RMS project. You can follow the instruction in the `readme.html` file to run CreditCardApplication by the using the provided sample YAML files. These sample YAML files are available at `BE_HOME\cloud\kubernetes\OpenShift\rms` for deploying CreditCardApplication on OpenShift Container Platform. For details about these sample YAML files, see [Sample Kubernetes YAML Files for RMS](Sample%20Kubernetes%20Resource%20YAML%20Files%20for%20RMS#).

### Prerequisites

-   See [Preparing for TIBCO BusinessEvents Containerization](Before%20You%20Begin)
-   You must have installed and login to OpenShift Container Platform CLI, see [Setting Up the OpenShift CLI Environment](Setting%20Up%20the%20OpenShift%20Container%20Platform%20CLI%20Environment).

### Procedure

1. To enable hot deployment for a project, add JMX connection details for each project for each environment under the **HotDeploy** section in the `RMS.cdd` file. :

   For example,

   ```
    <property name="ProjectName.ws.applicableEnvironments" type="string" value="QA,PROD">
    <property name="ProjectName.QA.ws.jmx.hotDeploy.enable" type="boolean" value="true">
    <property name="ProjectName.QA.ws.jmx.host" type="string" value="bejmx-service.default.svc.cluster.local">
    <property name="ProjectName.QA.ws.jmx.port" type="integer" value="5555">
    <property name="ProjectName.QA.ws.jmx.user" type="string" value="">
    <property name="ProjectName.QA.ws.jmx.password" type="string" value="">
    <property name="ProjectName.QA.ws.jmx.clusterName" value="CreditCardApplication">
    <property name="ProjectName.QA.ws.jmx.agentName" value="inference-class">
   ```

   For more information about hot deployment property group, see the "RMS Server Configuration Property Reference" section in *TIBCO BusinessEvents WebStudio Users Guide*.

2. Build the RMS Docker image. See [Building RMS Docker Image](Building%20RMS%20Docker%20Image).

3. In the RMS application CDD file, update the path for hot deployment of artifacts to the shared location in RMS. For example:

   ```
   <property name="be.engine.cluster.externalClasses.path" value="C:/tibco/be/5.6/rms/shared/CreditCardApplication/Decision_Tables">
   <property name="be.cluster.ruletemplateinstances.deploy.dir" value="C:/tibco/be/5.6/rms/shared/CreditCardApplication/RTI/">
   ```

4. Build the RMS application Docker image. See [Building TIBCO BusinessEvents Application Docker Image](Building%20TIBCO%20BusinessEvents%20Application%20Docker%20Image).

5. Tag and push the RMS and application Docker images to the OpenShift Docker container registry. For details, see [Pushing Application Docker Image to OpenShift Container Registry](Pushing%20Application%20Docker%20Image%20to%20OpenShift%20Container%20Registry).

   For example:

   ```
   **$ oc describe -n default service/docker-registry**
   Name:              docker-registry
   Namespace:         default
   Labels:            <none>
   Annotations:       <none>
   Selector:          docker-registry=default
   Type:              ClusterIP
   **IP:                192.0.2.0**
   **Port:              5000-tcp  5000/TCP**
   TargetPort:        5000/TCP
   Endpoints:         198.51.100.10:5000
   Session Affinity:  ClientIP
   Events:            <none>
   $ docker tag rms:5.6.1  192.0.2.0:5000/test-project/rms:5.6.1
   $ docker tag creditcardapp:01  192.0.2.0:5000/test-project/creditcardapp:01
   $ docker login 192.0.2.0:5000 -u userid -p ov40AhpTXYZOwHBtC_vat0SF4xJd8lQNjylccs8ZOLc
   $ docker push 192.0.2.0:5000/test-project/rms:5.6.1
   $ docker push 192.0.2.0:5000/test-project/creditcardapp:01
   ```

6. Create the Kubernetes object specification \(`.yaml`\) files based on your deployment requirement.

   You must consider the following point while creating the object specification file:

   -   Create separate persistent volume and PVCs for storing the project's hot deployed artifacts, project shared files, projects ACLs, and email notifications.
   -   Create a node with RMS container and an internal service for connecting it to the cluster.
   -   Create discovery node, cache agent, and inference agent by using the application Docker image.
       For details about describing a Kubernetes object in a YAML file, see [Kubernetes documentation](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/). For details about sample YAML files, see [Sample Kubernetes YAML Files for RMS](Sample%20Kubernetes%20Resource%20YAML%20Files%20for%20RMS#).

7. Create Kubernetes objects required for deploying and running the application by using the object specification \(`.yaml`\) files.

   **Syntax**:

   ```
   oc create -f <kubernetes_object.yaml>
   ```

   For example, create the Kubernetes objects by using the sample YAML files mentioned in [Step 1](Running%20the%20Application%20for%20No%20Backing%20Store%20on%20OpenShift%20Container%20Platform#STEP_E5947E23B29443D8AB62E16A2B7BEAE5).

   ```
   oc create -f bejmx-service.yaml
   
   oc create -f berms-persistent-volumes.yaml
   
   oc create -f berms-persistent-volume-claims.yaml
   
   oc create -f berms.yaml
   
   oc create -f berms-service.yaml
   
   oc create -f bediscoverynode.yaml
   
   oc create -f bediscovery-service.yaml
   
   oc create -f becacheagent.yaml
   
   oc create -f beinferenceagent.yaml
   
   oc create -f befdservice.yaml
   ```

8. \(Optional\) If required, you can check logs of TIBCO BusinessEvents pod.

   **Syntax**:

   ```
   oc logs <pod>
   ```

   For example, use the `oc get` command to get the list of pods and then use the `oc logs` command to view logs of `bediscoverynode`.

   ```
   oc get pods
   
   oc logs bediscoverynode-86d75d5fbc-z9gqt
   ```

9. Copy the masked persistent volume folders to the same path in the container. When you mount the PVC to the RMS project folder, it mask the other existing projects at the same path in the container.

   Use the following command for copying required folders in RMS pods.

   **Syntax**:

   ```
     oc cp *<host_folder_path berms_pod_name>:<berms_pod_folder_path>*
   ```

   **For example**:

   ```
   oc cp security berms-65f89dff4-cwg6z:/opt/tibco/be/5.6.1/rms/config/ 
   
   oc cp notify berms-65f89dff4-cwg6z:/opt/tibco/be/5.6.1/rms/config/
   
   oc cp shared berms-65f89dff4-cwg6z:/opt/tibco/be/5.6.1/rms/
   
   oc cp WebStudio berms-65f89dff4-cwg6z:/opt/tibco/be/5.6.1/examples/standard/
   
   ```

10. Get the external IP of the RMS service.

    **Syntax**:

    ```
    oc get services <external_service_name>
    ```

    For example,

    ```
    oc get service rms-service
    ```

### What to do Next

Use the IP obtained to connect to TIBCO BusinessEvents WebStudio from your browser. For example, if you have deployed the CreditCardApplication example application, you can use the provided sample readme.html file at `BE_HOME\cloud\kubernetes\OpenShift\rms` to test the application. Provide the external IP obtained to the readme.html file and follow the instructions in it to run the application.

**Parent topic:** [TIBCO BusinessEvents on OpenShift Container Platform Based Kubernetes](TIBCO%20BusinessEvents%20on%20OpenShift%20Container%20Platform%20Based%20Kubernetes)

**Related topics:**  

* [Running an Application on OpenShift Based Kubernetes Cluster](Running%20an%20Application%20on%20OpenShift%20Container%20Platform%20Based%20Kubernetes%20Cluster)

* [Monitoring TIBCO BusinessEvents Applications on OpenShift Container Platform](Monitoring%20TIBCO%20BusinessEvents%20Applications%20on%20OpenShift%20Container%20Platform)