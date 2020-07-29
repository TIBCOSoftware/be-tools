# Running RMS on Azure Based Kubernetes

By using the Azure Kubernetes Service \(AKS\), you can easily deploy the rule management server\(RMS\) on the Kubernetes cluster managed by Microsoft Azure.

TIBCO BusinessEvents installation provides the RMS project at BE_HOME\rms\project\BRMS. Deploying RMS on Azure based Kubernetes is similar to deploying any other TIBCO BusinessEvents application with no backing store. However, if you want to enable the hot deployment in RMS, you must create persistent volumes claims \(PVCs\) \([Step 4](#STEP_9B67982EAD2043129DC79A4042ACDD23)\) and setup JMX environment variables \([Step 1](#STEP_3B15CF332D10440D88D9B059B7871BD0)\).

Set up the [Microsoft Azure command line environment](Setting%20Microsoft%20Azure%20CLI%20Environment).

1.  To enable hot deployment, in the RMS.cdd file, add JMX connection details for each project for each environment under the **HotDeploy** section

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

    Alternatively, you can add these JMX connection details for the project from the Settings page in TIBCO BusinessEvents WebStudio. For details, see *TIBCO BusinessEvents WebStudio Users Guide*.

2.  Build the Docker image of RMS, see [Building RMS Docker Image](Building%20RMS%20Docker%20Image).

3.  Create an Azure Container Registry \(ACR\) and push the Docker image of RMS to it, see [Setting Up an Azure Container Registry](Setting%20Up%20an%20Azure%20Container%20Registry).

4.  Create a Kubernetes cluster and deploy it to the Microsoft Azure, see [Setting Up a Kubernetes Cluster on AKS](Setting%20Up%20a%20Kubernetes%20Cluster%20on%20AKS).

5.  To store hot deployment artifacts, create Azure File type storage class and PVCs by using the Kubernetes object specification \(.yaml\) files.

    The sample YAML file`berms-peristent-volume-claims.yaml` for creating storage class and PVCs is located at BE_HOME\cloud\kubernetes\Azure\rms. The `berms-peristent-volume-claims.yaml` file set up PVC for the following storage purpose:

    -   for storing TIBCO BusinessEvents project files
    -   for storing TIBCO BusinessEvents project ACL files, such as, `CreditCardApplication.ac`
    -   for storing RMS artifacts after hot deployment, such as, rule template instances
    -   for storing Email notification files, such as, `message.stg`
    For more information about the Kubernetes object spec files, see [Kubernetes documentation](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/).

6.  Create Kubernetes objects required for deploying RMS by using the object spec \(`.yaml`\) files.

    These objects include deployment and services for the cluster. Thus to deploy RMS on the Kubernetes cluster, create:

    -   a discovery node \(pod\) to start the cluster
    -   a service to connect to discovery node
    -   a cache agent node which connects to the discovery node service
    -   an inference agent node which connects to the discovery node service
    -   a service to connect to the inference agent
    -   a RMS node containing the RMS Docker image and persistent volume claims to mount the respective Azure File share
    -   an external service to connect to the RMS node
    -   an JMX service to connect to the JMX port of the RMS pod
    For your reference, sample YAML files for deploying RMS to Kubernetes are available at BE_HOME\cloud\kubernetes\Azure\rms, see [Sample Kubernetes YAML Files for RMS](Sample%20Kubernetes%20Resource%20YAML%20Files%20for%20RMS).

    In these `.yaml` files, update the `image` tag with the application Docker image tag including the registry login server name that you have used in [Step 4 of Setting Up an Azure Container Registry](Setting%20Up%20an%20Azure%20Container%20Registry#STEP_07658DED2A6241D79BB4B89A489CA573). Also, update the `DOCKER_HOST` environment variable with `bejmx-service.default.svc.cluster.local`.

    For more information about the Kubernetes object spec files, see [Kubernetes documentation](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/).

7.  Use the `kubectl create` command to create and deploy these objects to the Kubernetes cluster. This command parses the specified manifest file and creates the defined Kubernetes objects.

    ```
    kubectl create -f <kubernetes_object_spec>.yaml
    ```

    For example, enter the following command to create the Azure File type storage class.

    ```
    kubectl create -f manifest_azurefile.yaml
    ```

8.  After successful creation of Kubernetes objects, use the `kubectl cp` command to upload the files \(required to perform various operations in WebStudio\) from your computer to the PVCs.

    ```
    kubectl cp <host_folder_path> <berms_pod_name>:<berms_pod_folder_path>
    ```

    The following table lists the files to be uploaded to PVCs.

    |PVC Name|Files to be uploaded|
    |--------|--------------------|
    |`azurefile-webstudio`|BE_HOME\examples\standard\WebStudio\|
    |`azurefile-security`|BE_HOME\rms\config\security|
    |`azurefile-notify`|BE_HOME\rms\config\notify|
    |`azurefile-shared`|BE_HOME\rms\shared|

9.  To access WebStudio, you can get the external IP of the service of the RMS deployment by using the `kubectl get services` command.

    ```
    kubectl get services <external_service_name>
    ```

    For example,

    ```
    kubectl get services berms-service -o wide
    ```


Use the IP obtained to connect to TIBCO BusinessEvents WebStudio from your browser.

**Parent topic:**[TIBCO BusinessEvents on Microsoft Azure Based Kubernetes](TIBCO%20BusinessEvents%20on%20Microsoft%20Azure%20Based%20Kubernetes)

**Related information**  


[Running an Application on Microsoft Azure Based Kubernetes Cluster](Running%20an%20Application%20on%20Microsoft%20Azure%20Based%20Kubernetes%20Cluster)

[Monitoring TIBCO BusinessEvents Applications on Microsoft Azure](Monitoring%20TIBCO%20BusinessEvents%20Applications%20on%20Microsoft%20Azure)

[Running an Application with Shared Nothing Persistence on Azure](Running%20an%20Application%20with%20Shared%20Nothing%20Storage%20on%20Azure)

[Running an Application with Shared All Persistence on Azure](Running%20the%20Application%20for%20Shared%20All%20Storage%20on%20Azure)

[Running the Application Without Backing Store on Azure](Running%20the%20TIBCO%20BusinessEvents%20Application%20for%20No%20Backing%20Store)

[Setting up the Microsoft Azure CLI Environment](Setting%20Microsoft%20Azure%20CLI%20Environment)

[Setting Up a Kubernetes Cluster on AKS](Setting%20Up%20a%20Kubernetes%20Cluster%20on%20AKS)

[Setting Up an Azure Container Registry](Setting%20Up%20an%20Azure%20Container%20Registry)

