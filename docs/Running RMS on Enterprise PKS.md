# Running RMS on Enterprise PKS

To use TIBCO BusinessEvents WebStudio on Pivotal, you must set up TIBCO BusinessEvents and Rule Management Server \(RMS\) on Pivotal by using Enterprise PKS.

To connect to WebStudio, you must set up an external service to deploy the RMS project. The RMS deployment can communicate with an instance of TIBCO BusinessEvents by using the instance JMX port. You can implement it by setting up an internal JMX service Kubernetes object.

For storing project's hot deployed artifacts, project shared files, project ACLs, and email notifications, define a Storage Class object of the GCP persistent disk \(`gce-pd`\) provisioner. You can use this Storage Class to provision persistence volumes claims required for storage of these artifacts. For more information about Storage Class and persistent volume claims, see [Kubernetes Documentation](https://kubernetes.io/docs/home/).

TIBCO BusinessEvents provides a readme.html file at BE_HOME\cloud\kubernetes\PKS\rms for the Dockerized CreditCardApplication project and RMS project. You can follow the instructions in the readme.html file to run CreditCardApplication by using sample YAML files. These sample YAML files for deploying CreditCardApplication on Enterprise PKS are available at BE_HOME\cloud\kubernetes\PKS\rms. For details about these sample YAML files, see [Sample Kubernetes YAML Files for RMS](Sample%20Kubernetes%20Resource%20YAML%20Files%20for%20RMS#).

The Kubernetes cluster must be deployed on Enterprise PKS, see [Setting Up a Kubernetes Cluster with Enterprise PKS](Setting%20up%20a%20Kubernetes%20Cluster%20With%20Enterprise%20PKS).

1.  To enable hot deployment in RMS, add JMX connection details in RMS.cdd for each project of each environment under the **HotDeploy** section.

    For example,

    ```
     <property name="ProjectName.ws.applicableEnvironments" type="string" value="QA,PROD"/>
     <property name="ProjectName.QA.ws.jmx.hotDeploy.enable" type="boolean" value="true"/>
     <property name="ProjectName.QA.ws.jmx.host" type="string" value="bejmx-service.default.svc.cluster.local"/>
     <property name="ProjectName.QA.ws.jmx.port" type="integer" value="5555"/>
     <property name="ProjectName.QA.ws.jmx.user" type="string" value=""/>
     <property name="ProjectName.QA.ws.jmx.password" type="string" value=""/>
     <property name="ProjectName.QA.ws.jmx.clusterName" value="CreditCardApplication"/>
     <property name="ProjectName.QA.ws.jmx.agentName" value="inference-class"/>
    ```

    For more informationabout hot deployment property group, see the "RMS Server Configuration Property Reference" section in *TIBCO BusinessEvents WebStudio Users Guide*.

    Alternatively, you can add these JMX connection details for the project from the **Settings** page in TIBCO BusinessEvents WebStudio. For details, see *TIBCO BusinessEvents WebStudio Users Guide*.

2.  Build the RMS Docker image. See [Building RMS Docker Image](Building%20RMS%20Docker%20Image).

3.  In the RMS application CDD file, update the path for hot deployment of artifacts to the shared location in RMS.

    For example, update the following properties for the CreditCardApplication sample:

    ```
    <property name="be.engine.cluster.externalClasses.path" value="C:/tibco/be/5.6/rms/shared/CreditCardApplication/Decision_Tables"/>
    <property name="be.cluster.ruletemplateinstances.deploy.dir" value="C:/tibco/be/5.6/rms/shared/CreditCardApplication/RTI/"/>
    ```

4.  Build the RMS application Docker image. See [Building TIBCO BusinessEvents Application Docker Image](Building%20TIBCO%20BusinessEvents%20Application%20Docker%20Image).

5.  Tag and push the RMS and application Docker images to Google Container Registry. For details, see [Setting up Google Container Registry](Pushing%20Application%20Docker%20Image%20to%20Google%20Container%20Registry).

6.  Create the Kubernetes object specification \(`.yaml`\) files based on your deployment requirement.

    You must consider the following point while creating the object specification file:

    -   Create separate persistent volume and persistent volume claims for storing the project hot deployed artifacts, project shared files, project ACLs, and email notifications.
    -   Create a node with the RMS container, an internal JMX service for connecting it to the cluster, and an external RMS service for accessing WebStudio.
    -   Create discovery node, cache agent, and inference agent by using the application Docker image.
    For details about defining Kubernetes objects in a YAML file, see [Kubernetes documentation](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/). For details about sample YAML files, see [Sample Kubernetes YAML Files for RMS](Sample%20Kubernetes%20Resource%20YAML%20Files%20for%20RMS#).

7.  Create Kubernetes objects required for deploying and running the application by using the YAML files.

    **Syntax**:

    ```
    kubectl create -f <kubernetes_object.yaml>
    ```

    For example, create the following Kubernetes objects by using the sample YAML files in the previous step.

    ```
    kubectl create -f manifest_gcp.yaml
    
    kubectl create -f persistent-volume-claims.yaml
    
    kubectl create -f berms.yaml
    
    kubectl create -f berms-service.yaml
    
    kubectl create -f bejmx-service.yaml
    
    kubectl create -f bediscoverynode.yaml
    
    kubectl create -f bediscovery-service.yaml
    
    kubectl create -f becacheagent.yaml
    
    kubectl create -f beinferenceagent.yaml
    
    kubectl create -f befdservice.yaml
    
    ```

8.  \(Optional\) If required, you can check logs of TIBCO BusinessEvents pod.

    **Syntax**:

    ```
    kubectl logs <pod>
    ```

    For example, use the `kubectl get` command to get the list of pods and then use the `kubectl logs` command to view logs of `becacheagent`.

    ```
    kubectl get pods
    
    kubectl logs becacheagent-86d75d5fbc-z9gqt
    ```

9.  Copy the masked persistent volume folders to the same path in the container. When you mount the persistent volume claims to the RMS project folder, it masks the other existing projects that are at the same path in the container.

    Use the following command to copy the relevant folders to the RMS pods.

    **Syntax**:

    ```
    kubectl cp *<host_folder_path berms_pod_name>:<berms_pod_folder_path>*
    ```

    **For example**:

    ```
    kubectl cp security berms-65f89dff4-cwg6z:/opt/tibco/be/5.6.1/rms/config/ 
    
    kubectl cp notify berms-65f89dff4-cwg6z:/opt/tibco/be/5.6.1/rms/config/
    
    kubectl cp shared berms-65f89dff4-cwg6z:/opt/tibco/be/5.6.1/rms/
    
    kubectl cp webstudio berms-65f89dff4-cwg6z:/opt/tibco/be/5.6.1/examples/standard/
    
    ```

10. Get the external IP of the RMS service.

    **Syntax**:

    ```
    kubectl get services <external_service_name>
    ```

    For example,

    ```
    kubectl get services rms-service
    ```


Use the IP obtained from `rms-service` to connect to TIBCO BusinessEvents WebStudio from your browser. For example, if you have deployed the CreditCardApplication example application, you can use the provided sample readme.html file at BE_HOME\cloud\kubernetes\PKS\rms to test the application. Use the obtained external IP in the readme.html file and follow the instructions in it to run the application.

**Parent topic:**[TIBCO BusinessEvents on Pivotal Based Kubernetes](TIBCO%20BusinessEvents%20on%20Pivotal%20Based%20Kubernetes)

