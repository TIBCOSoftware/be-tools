
You can run any TIBCO BusinessEvents application on OpenShift Container Platform based Kubernetes cluster and monitor them by using TIBCO BusinessEvents Enterprise Administrator Agent. You can also manage business rules through WebStudio by running RMS on OpenShift Container Platform based Kubernetes cluster.

For details, see [OpenShift Container Platform documentation](https://docs.openshift.com/container-platform).

## Kubernetes Environment Setup

* Setup [Azure OpenShift Cluster](Setting-Up-the-OpenShift-Container-Platform-CLI-Environment)
* create [container registry](Setting%20Up%20an%20Azure%20Container%20Registry)

Note: For Openshift cluster deployments, you can use `oc` or `kubectl` cli for deployments to cluster.


## Backing Store persistence setup 

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


