# Setting Up a Kubernetes Cluster on AKS

Azure Kubernetes Services \(AKS\) manages the Kubernetes environment and provides options to quickly deploy Kubernetes cluster.

Set up the Azure Container Registry and push the application Docker image to it, see [Setting Up an Azure Container Registry](Setting%20Up%20an%20Azure%20Container%20Registry).

1.  To enable a Kubernetes cluster to interact with other Azure resource, an Azure Active Directory service principal is required.

    1.  Create a service principal by using the `az ad sp create-for-rbac` command.

        ```
        az ad sp create-for-rbac --skip-assignment
        ```

        The output of the command provides the `appId` which is the service principal and `password` which is the `client-secret` for creating the Kubernetes cluster.

    2.  Create the Kubernetes cluster with repository group and service principal created earlier.

        ```
        az aks create --orchestrator-type=kubernetes --resource-group <resource_group_name> --name=<cluster_name> --service-principal <service_principal> --client-secret <client_secret> --node-count <node_count> --generate-ssh-keys
        ```

        Microsoft Azure creates a storage account when a Kubernetes cluster is created.

        For more information about commands, see [Microsoft Azure CLI documentation](https://docs.microsoft.com/en-us/cli/azure/?view=azure-cli-latest).

2.  To connect to Kubernetes cluster from your local computer, use `kubectl`, the Kubernetes CLI. If you use the Azure Cloud Shell, `kubectl` is already installed. You can also install it locally by using the `az aks install-cli` command.

    ```
    az aks install-cli
    ```

3.  Configure `kubectl` to connect your Kubernetes cluster by using the `az aks get-credentials` command.

    ```
    az aks kubernetes get-credentials --resource-group <resource_group_name> --name=<cluster_name>
    ```

4.  Verify the connection to your Kubernetes cluster by using the `kubectl get nodes` command.

    ```
    kubectl get nodes
    ```


Based on your application architecture, deploy the application on the Kubernetes cluster:

-   For deployment of application for No Backing Store cluster, see [Running the Application Without Backing Store on Azure](Running%20the%20TIBCO%20BusinessEvents%20Application%20for%20No%20Backing%20Store#).
-   For deployment of application for Shared Nothing persistence, see [Running an Application with Shared Nothing Persistence on Azure](Running%20an%20Application%20with%20Shared%20Nothing%20Storage%20on%20Azure#).
-   For deployment of application for Shared All persistence, see [Running an Application with Shared All Persistence on Azure](Running%20the%20Application%20for%20Shared%20All%20Storage%20on%20Azure#).

**Parent topic:**[Running an Application on Microsoft Azure Based Kubernetes Cluster](Running%20an%20Application%20on%20Microsoft%20Azure%20Based%20Kubernetes%20Cluster)

**Related information**  


[Running an Application with Shared Nothing Persistence on Azure](Running%20an%20Application%20with%20Shared%20Nothing%20Storage%20on%20Azure)

[Running RMS on Azure Based Kubernetes](Running%20RMS%20on%20Azure%20Based%20Kubernetes)

[Running an Application with Shared All Persistence on Azure](Running%20the%20Application%20for%20Shared%20All%20Storage%20on%20Azure)

[Running the Application Without Backing Store on Azure](Running%20the%20TIBCO%20BusinessEvents%20Application%20for%20No%20Backing%20Store)

[Setting up the Microsoft Azure CLI Environment](Setting%20Microsoft%20Azure%20CLI%20Environment)

[Setting Up an Azure Container Registry](Setting%20Up%20an%20Azure%20Container%20Registry)

