# Setting Up an Azure Container Registry

Microsoft Azure uses the Azure Container Registry for securely building and deploying your applications. To create an Azure Container Registry, you need to create an Azure Resource group. An Azure resource group is a logical container into which Azure resources are deployed and managed.

For more information about commands used in the following procedure, see [Microsoft Azure CLI documentation](https://docs.microsoft.com/en-us/cli/azure/?view=azure-cli-latest).

-   Set up the [Microsoft Azure command line environment](Setting%20Microsoft%20Azure%20CLI%20Environment).
-   Docker image of the TIBCO BusinessEvents application that you want to deploy to the Kubernetes cluster, see [Building TIBCO BusinessEvents Application Docker Image](Building%20TIBCO%20BusinessEvents%20Application%20Docker%20Image#).

1.  Create a resource group by using the `az group create` command.

    ```
    az group create --name <resource_group_name> --location <location>
    ```

2.  Create an Azure Container Registry instance in your resource group by using the `az acr create` command.

    ```
    az acr create --resource-group <resource_group_name> --name <registry_name> --sku Basic --admin-enabled true
    ```

3.  Login to the container registry created earlier by using the `az acr login` command.

    ```
    az acr login --name <registry_name>
    ```

    The command returns a Login Succeeded message once completed.

4.  To use the TIBCO BusinessEvents application container image with Azure Container Registry, tag the image with the login server address of your registry.

    1.  View the list of your local image by using the docker images command.

        ```
        $ docker images

        REPOSITORY                   TAG                 IMAGE ID            CREATED             SIZE
        fdcache                      latest              4675398c9172        13 minutes ago      694MB

        ```

    2.  Get the login server address for the Azure Container Registry by using the `az acr list` command.

        ```
        az acr list --resource-group <resource_group_name> --query "[].{acrLoginServer:loginServer}" --output table
        ```

    3.  Tag your application image with login server address of your registry from the earlier step. This creates an alias of the application image with a fully qualifies path to your registry.

        ```
        docker tag fdcache <registry_login_server>/fdcache:01
        ```

    4.  Verify the tags applied to the image by running the `docker images` command again.

        ```
        $ docker images

        REPOSITORY                               TAG                 IMAGE ID            CREATED             SIZE
        mycontainerregistry.azuecr.io/fdcache    01                  4675398c9172        13 minutes ago      694MB

        ```

5.  Push the application image to your container registry by using the `docker push` command.

    ```
    docker push <registry_login_server>/fdcache:01
    ```

6.  Validate if the image is uploaded to your registry.

    ```
    az acr repository list --name <registry_login_server> --output table
    ```

**Next Topic**: Continue to [Kubernetes Deployments](deployments)
