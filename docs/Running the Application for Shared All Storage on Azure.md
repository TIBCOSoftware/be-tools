# Running an Application with Shared All Persistence on Azure

After uploading your TIBCO BusinessEvents application image with shared all persistence to the Azure Container Registry and creating the Kubernetes cluster, you can deploy your application to the Kubernetes cluster. The cluster manages the availability and connectivity of the application. You can use Microsoft Azure provided relational database service or you can use the Docker image of the database that you want to use.

For more information about Kubernetes concepts and Microsoft Azure, see [Azure Kubernetes Service documentation](https://docs.microsoft.com/en-us/azure/aks/).

The following procedure provides a sample implementation of Azure Database for MySQL as the database service. For more information, see [Azure Database for MySQL documentation](https://docs.microsoft.com/en-us/azure/mysql/).

If you want to use any other database service, follow its documentation on how to use with Docker and Kubernetes.

TIBCO BusinessEvents also provides a readme.html file at BE_HOME\cloud\kubernetes\Azure\cache for the Dockerized FraudDetectionStore application. You can follow the instruction in the readme.html file to run the application by the using the provided sample YAML files. These sample YAML files are available at BE_HOME\cloud\kubernetes\azure\cache\shared-all\<database_type> for deploying TIBCO BusinessEvents application with shared nothing persistence on Microsoft Azure. For details about these sample YAML files, see [Sample Kubernetes YAML Files for Applications with Shared All Persistence](Sample%20Kubernetes%20Resource%20Files%20for%20Shared%20All%20Storage#).

-   Your TIBCO BusinessEvents application must be uploaded to the Azure Container Registry, see [Setting Up an Azure Container Registry](Setting%20Up%20an%20Azure%20Container%20Registry).
-   The Kubernetes cluster must be deployed in the Microsoft Azure, see [Setting Up a Kubernetes Cluster on AKS](Setting%20Up%20a%20Kubernetes%20Cluster%20on%20AKS).

1.  Create an Azure Database instance of MySQL server with the `az mysql server create` command.

    ```
    az mysql server create -g <resource_group_name> -n <mysql_server_name> -l <location> --admin-user <admin_user> --admin-password <admin_password> --sku-name <sku_name>
    ```

    For details about command options, see [Azure Database for MySQL documentation](https://docs.microsoft.com/en-us/azure/mysql/).

2.  Create a MySQL server-level firewall rule and disable the SSL connection to connect to the server from your local MySQL client.

    ```
    az mysql server firewall-rule create --resource-group <resource_group_name> --server <mysql_server_name> --name <firewall_rule_name> --start-ip-address <start_ip_address> --end-ip-address <end_ip_address>
    
    az mysql server update --resource-group <resource_group_name> --name <mysql_server_name> --ssl-enforcement Disabled
    ```

    For details about command options, see [Azure Database for MySQL documentation](https://docs.microsoft.com/en-us/azure/mysql/).

3.  To connect to the MySQL server, get the host information and access credentials.

    ```
    az mysql server show --resource-group <resource_group_name> --name <mysql_server_name>
    ```

    For details about command options, see [Azure Database for MySQL documentation](https://docs.microsoft.com/en-us/azure/mysql/).

4.  Use the `mysql` command-line tool to establish a connection to your Azure Database for MySQL server by using the earlier obtained host and credentials details, see [mysql command-line documentation](https://dev.mysql.com/doc/refman/5.6/en/mysql.html).

5.  Initialize the database, create the user, create the table, and load the data in the tables by using the MySQL commands.

    For details, see [MySQL documentation](https://dev.mysql.com/doc/).

6.  Create Kubernetes object specification \(`.yaml`\) files based on your deployment requirement.

    For details about describing a Kubernetes object in a YAML file, see [Kubernetes documentation](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/). For details about the sample YAML files, see [Sample Kubernetes YAML Files for Applications with Shared All Persistence](Sample%20Kubernetes%20Resource%20Files%20for%20Shared%20All%20Storage#).

7.  Create Kubernetes objects required for deploying and running the application by using the object specification \(`.yaml`\) files.

    **Syntax**:

    ```
    kubectl create -f <kubernetes_object_spec>.yaml
    ```

    For example, create the Kubernetes objects by using the sample YAML files mentioned in [Sample Kubernetes YAML Files for Applications with Shared All Persistence](Sample%20Kubernetes%20Resource%20Files%20for%20Shared%20All%20Storage#):

    ```
    kubectl create -f db-configmapmysql.yaml
    
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

    For example, use the `kubectl get` command to get the list of pods and then use the `kubectl logs` command to view logs of `bediscovery`.

    ```
    kubectl get pods
    
    kubectl logs bediscovery-86d75d5fbc-z9gqt
    ```

9.  Get the external IP of your application which you can use to connect to the cluster.

    **Syntax**

    ```
    kubectl get services <external_service_name>
    ```

    For example,

    ```
    kubectl get services befdservice
    ```


Test the application by using the external IP obtained. For example, if you have deployed the FraudDetectionStore example application with shared all persistence, you can use the provided sample readme.html file at BE_HOME\cloud\kubernetes\Azure\cache to test the application. Provide the external IP obtained to the readme.html file and follow the instructions in it to run the application.

However, if you have deployed any other sample application then update its readme.html file to test the application. Update the server address in application readme.html file from `localhost` to the external IP obtained. Now, follow the instructions in the readme.html file for testing the application.

**Parent topic:**[Running an Application on Microsoft Azure Based Kubernetes Cluster](Running%20an%20Application%20on%20Microsoft%20Azure%20Based%20Kubernetes%20Cluster)

**Related information**  


[Running an Application with Shared Nothing Persistence on Azure](Running%20an%20Application%20with%20Shared%20Nothing%20Storage%20on%20Azure)

[Running RMS on Azure Based Kubernetes](Running%20RMS%20on%20Azure%20Based%20Kubernetes)

[Running the Application Without Backing Store on Azure](Running%20the%20TIBCO%20BusinessEvents%20Application%20for%20No%20Backing%20Store)

[Setting up the Microsoft Azure CLI Environment](Setting%20Microsoft%20Azure%20CLI%20Environment)

[Setting Up a Kubernetes Cluster on AKS](Setting%20Up%20a%20Kubernetes%20Cluster%20on%20AKS)

[Setting Up an Azure Container Registry](Setting%20Up%20an%20Azure%20Container%20Registry)

