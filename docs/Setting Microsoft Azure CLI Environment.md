# Setting up the Microsoft Azure CLI Environment

You can use either the Microsoft Azure Cloud Shell or Microsoft Azure command-line interface \(CLI\) for running the Microsoft Azure commands. In the following sections, the procedures are provided for the Azure CLI.

You must have a Microsoft Azure account with an active subscription. If required, [create a new Azure account](https://azure.microsoft.com/en-us/).

1.  Install the Microsoft Azure command-line interface \(CLI\). For installation instructions, see [Microsoft Azure CLI documentation](https://docs.microsoft.com/en-us/cli/azure/?view=azure-cli-latest)

2.  In Microsoft Azure CLI, sign in to Microsoft Azure by using the `login` command.

    ```
    az login
    ```

    The CLI opens a browser and loads the sign-in page.

3.  Sign in with your account credentials in the browser.

    For details, see [Get started with Azure CLI](https://docs.microsoft.com/en-us/cli/azure/get-started-with-azure-cli?view=azure-cli-latest).


Create an Azure Container Registry \(ACR\) and push the Docker image of the application to it, see [Setting Up an Azure Container Registry](Setting%20Up%20an%20Azure%20Container%20Registry).

**Parent topic:**[Running an Application on Microsoft Azure Based Kubernetes Cluster](Running%20an%20Application%20on%20Microsoft%20Azure%20Based%20Kubernetes%20Cluster)

**Related information**  


[Running an Application with Shared Nothing Persistence on Azure](Running%20an%20Application%20with%20Shared%20Nothing%20Storage%20on%20Azure)

[Running RMS on Azure Based Kubernetes](Running%20RMS%20on%20Azure%20Based%20Kubernetes)

[Running an Application with Shared All Persistence on Azure](Running%20the%20Application%20for%20Shared%20All%20Storage%20on%20Azure)

[Running the Application Without Backing Store on Azure](Running%20the%20TIBCO%20BusinessEvents%20Application%20for%20No%20Backing%20Store)

[Setting Up a Kubernetes Cluster on AKS](Setting%20Up%20a%20Kubernetes%20Cluster%20on%20AKS)

[Setting Up an Azure Container Registry](Setting%20Up%20an%20Azure%20Container%20Registry)

