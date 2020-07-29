# Monitoring TIBCO BusinessEvents Applications

To monitor TIBCO BusinessEvents applications running on kubernetes cluster, run TIBCO BusinessEvents Enterprise Administrator Agent container in the same Kubernetes namespace as the application.

**Note:** You can build only Linux container \(and not Windows container\) of TIBCO BusinessEvents Enterprise Administrator Agent.

-   See [Preparing for TIBCO BusinessEvents Containerization](Before%20You%20Begin).
-   Docker image of TIBCO Enterprise Administrator server. For instructions, see readme at TEA_HOME/docker in the TIBCO Enterprise Administrator installation.
-   A TIBCO BusinessEvents application running on kubernetes cluster. See [Running an Application](Running%20an%20Application).

1.  Build the TIBCO BusinessEvents Enterprise Administrator Agent Docker image by using the script provided by TIBCO BusinessEvents.

    See [Building TIBCO BusinessEvents Enterprise Administrator Agent Docker Image](Building%20TIBCO%20BusinessEvents%20Enterprise%20Administrator%20Agent%20Docker%20Image#).

2.  Push Docker images of TIBCO BusinessEvents Enterprise Administrator Agent and TIBCO Enterprise Administrator server to respective cloud Container Registry.

3.  Run the TIBCO Enterprise Administrator server.

    For instructions, see readme at TEA_HOME/docker in the TIBCO Enterprise Administrator installation.

4.  Update the following Kubernetes object specification \(`.yaml`\) files for TIBCO BusinessEvents Enterprise Administrator Agent:

    -   beteagentdeploymemt.yaml - A deployment of TIBCO BusinessEvents Enterprise Administrator Agent Docker image with the TIBCO Enterprise Administrator server URL and login details.
    -   beteagentinternalservice.yaml - An internal service for connecting to TIBCO BusinessEvents Enterprise Administrator Agent from other nodes
    -   k8s-authorization.yaml - A ClusterRoleBinding for binding roles to the user.
    These object specification files are available at BE_HOME->cloud->kubernetes->cloud_name->tea. For details about describing a Kubernetes object in a YAML file, see [Kubernetes Documentation](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/). For details about the sample YAML files, see [Sample YAML Files for TIBCO BusinessEvents Enterprise Administrator Agent](Sample%20YAML%20Files%20for%20TIBCO%20BusinessEvents%20Enterprise%20Administrator%20Agent#).

5.  Create Kubernetes objects required for deploying and running TIBCO BusinessEvents Enterprise Administrator Agent by using the YAML files.

    **Syntax**:

    ```
    kubectl create -f <kubernetes_object.yaml>
    ```

    For example, create the Kubernetes objects by using the sample YAML files mentioned in [Sample YAML Files for TIBCO BusinessEvents Enterprise Administrator Agent](Sample%20YAML%20Files%20for%20TIBCO%20BusinessEvents%20Enterprise%20Administrator%20Agent#).

    ```
    kubectl create -f k8s-authorization.yaml

    kubectl create -f beteagentdeploymemt.yaml

    kubectl create -f beteagentinternalservice.yaml

    ```

6.  \(Optional\) If required, you can check logs of TIBCO BusinessEvents Enterprise Administrator Agent pod.

    **Syntax**:

    ```
    kubectl logs <pod>
    ```

    For example, use the `kubectl get` command to get the list of pods and then use the `kubectl logs` command to view logs of `beteagentdeploymemt`.

    ```
    kubectl get pods

    kubectl logs beteagentdeploymemt-86d75d5fbc-z9gqt
    ```


Launch TIBCO Enterprise Administrator in a web browser by using the external IP and port obtained from the TIBCO Enterprise Administrator external service.

For more details on functioning of TIBCO BusinessEvents Enterprise Administrator Agent, see TIBCO BusinessEvents Administration guide..
