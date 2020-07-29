# Application deployment using kubernetes yaml files

* TIBCO BusinessEvents application is deployed using kubernetes yaml file. Please refer to below details.
* [Runing an inMemory Application](Running-an-inMemory-Application.md)
*   [Running an Application without Backing Store ](Running%20the%20Application%20Without%20Backing%20Store)
*   [Running an Application with Shared Nothing Persistence ](Running%20an%20Application%20with%20Shared%20Nothing%20Store)
*   [Running an Application with Shared All Persistence ](Running%20an%20Application%20with%20Shared%20All%20Storage)

## Syntax for application deployment to kubernetes

* Create Kubernetes objects required for deploying and running the application by using object specification \(`.yaml`\) files.

    **Syntax**:

    ```
    kubectl create -f <kubernetes_object.yaml>
    ```
