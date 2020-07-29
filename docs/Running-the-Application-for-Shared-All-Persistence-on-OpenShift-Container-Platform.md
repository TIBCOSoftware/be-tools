
After uploading your TIBCO BusinessEvents application Docker image with shared all storage to the OpenShift Docker registry, you can deploy your application and services to the Kubernetes cluster. The cluster manages the availability and connectivity of the application and service.

In OpenShift Container Platform, you do not have to setup Kubernetes separately. For more information about Kubernetes and OpenShift Container Platform, see [OpenShift Container Platform documentation](https://docs.openshift.com/container-platform/latest/welcome/index.html).

TIBCO BusinessEvents provides a `readme.html` file at `BE_HOME\cloud\kubernetes\OpenShift\cache` for the Dockerized FraudDetectionStore application. You can follow the instruction in the `readme.html` file to run the application by using the provided sample YAML files. These sample YAML files are available at `BE_HOME\cloud\kubernetes\OpenShift\cache\shared-all` for deploying TIBCO BusinessEvents application with shared all persistence on OpenShift Container Platform. For details about these sample YAML files, see [Sample Kubernetes YAML Files for Applications with Shared All Persistence](Sample-Kubernetes-YAML-Files-for-Applications-with-Shared-All-Persistence).

**Note:** As a sample use case, the procedure uses MySQL databases. The supported databases are MySQL, MariaDB, and PostgeSQL.

### Prerequisites

Your TIBCO BusinessEvents application must be uploaded to the OpenShift Docker registry, see [Pushing Application Docker Image to OpenShift Container Registry](Pushing%20Application%20Docker%20Image%20to%20OpenShift%20Container%20Registry).

### Procedure

1. Set up database with OpenShift Container Platform by using the CentOS based MySQL Docker image in Kubernetes.

   For details, see [OpenShift Container Platform documentation](https://docs.openshift.com/container-platform/3.11/using_images/db_images/mysql.html).

2. Connect to the database by using the port forwarding.

   ```
   oc port-forward <mysql_pod_name> <port_number>:<port_number>
   ```

3. Run generated SQL scripts, such as `initialize_database_mysql.sql`, `create_tables_mysql.sql`, and the project schema specific SQL script \(see *TIBCO BusinessEvents Configuration Guide*).

4. Set up the provisioner for the MySQL database by creating the persistent volume and PVC.

   For details about the sample YAML files for persistent volume and PVC, see [Sample Kubernetes YAML Files for Applications with Shared All Persistence](Sample-Kubernetes-YAML-Files-for-Applications-with-Shared-All-Persistence).

5. Create a configMap resource with database details.

   You can use the Kubernetes command to enter into the pod container and then use Linux commands get the database URL.

6. Create the Kubernetes object specification \(`.yaml`\) files based on your deployment requirement.

   For details about describing a Kubernetes object in a YAML file, see [Kubernetes documentation](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/). For details about the sample YAML files, see [Sample Kubernetes YAML Files for Applications with Shared All Persistence](Sample-Kubernetes-YAML-Files-for-Applications-with-Shared-All-Persistence).

7. Create Kubernetes objects required for deploying and running the application by using the object specification \(`.yaml`\) files.

   **Syntax**:

   ```
   oc create -f <kubernetes_object.yaml>
   ```

   For example, create the Kubernetes objects by using the sample YAML files mentioned in [Sample Kubernetes YAML Files for Applications with Shared All Persistence](Sample-Kubernetes-YAML-Files-for-Applications-with-Shared-All-Persistence).

   ```
   oc create -f mysql.yaml
   
   oc create -f mysql-service.yaml
   
   oc create -f persistent-volume-and-claim.yaml
   
   oc create -f db-configmap.yaml
   
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

9. Get the external IP of your application which you can use to connect to the cluster.

   **Syntax**:

   ```
   oc get services <external_service_name>
   ```

   For example,

   ```
   oc get services befdservice
   ```
### What to do Next

Test the application by using the external IP obtained. For example, if you have deployed the FraudDetectionStore example application with shared all persistence, you can use the provided sample `readme.html` file at `BE_HOME\cloud\kubernetes\OpenShift\cache` to test the application. Provide the external IP obtained to the readme.html file and follow the instructions in it to run the application.

However, if you have deployed any other sample application then update its `readme.html` file to test the application. Update the server address in the application `readme.html` file from `localhost` to the external IP obtained. Now, follow the instructions in the `readme.html` file for testing the application.

**Parent topic:** [Running an Application on OpenShift Based Kubernetes Cluster](Running%20an%20Application%20on%20OpenShift%20Container%20Platform%20Based%20Kubernetes%20Cluster)

**Previous topic:** [Pushing Application Docker Image to OpenShift Container Registry](Pushing%20Application%20Docker%20Image%20to%20OpenShift%20Container%20Registry)

**Related topics:**  

* [Running the Application Without Backing Store on OpenShift Container Platform](Running%20the%20Application%20for%20No%20Backing%20Store%20on%20OpenShift%20Container%20Platform)

* [Running the Application with Shared Nothing Persistence on OpenShift Container Platform](Running%20the%20Application%20with%20Shared%20Nothing%20Persistence%20on%20OpenShift%20Container%20Platform)



