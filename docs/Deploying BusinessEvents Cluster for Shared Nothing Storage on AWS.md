# Running an Application with Shared Nothing Persistence on AWS

By using the Kubernetes elements such as the StatefulSets object and dynamic volume provisioning features, you can create TIBCO ActiveSpaces and Shared Nothing deployments.

StatefulSets gives deterministic names to the pods. Along with dynamic volume provisioning, StatefulSets also give deterministic names to `PersistentVolumeClaims` \(PVC\). This ensures that when a particular member of a StatefulSet goes down and comes up again, it attaches itself to the same PVC. For more information about the Kubernetes concepts of StatefulSets, dynamic volume provisioning, and `PersistentVolumeClaims`, see [Kubernetes documentation](https://kubernetes.io/docs/concepts/).

Ensure that CDD of your application is configured to use shared nothing persistence. For deploying BusinessEvents cluster for the shared nothing persistence on AWS, you must first set up Kubernetes cluster on AWS and then upload your docker image to an AWS docker registry. For more information, see [Running TIBCO BusinessEvents® on AWS Based Kubernetes Cluster](Running%20BusinessEvents%20Applications%20in%20Kubernetes#).

1.  In AWS, create an EFS file system.

    For more information on the steps to create an EFS file system, see [Amazon EFS documentation](https://docs.aws.amazon.com/efs/latest/ug/gs-step-two-create-efs-resources.html). Specify the Kubernetes cluster Virtual Private Cloud \(**VPC**\) and **Security Group** while creating a mount target for the file system. On the File Systems page, verify that the mount target shows the **Life Cycle State** as Available. Under **File system access**, you see the file system **DNS name**. Make a note of this DNS name.

    After successful creation of the EFS file system, note its **File System ID**, which can be used for creating EFS provisioner.

2.  Create the EFS provisioner and other associated resources. Specify all the connection setup values for the EFS file system in a manifest.yaml file and run the `kubectl` command to create the EFS provisioner.

    1.  Download the sample manifest.yaml file from [https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/aws/efs/deploy/manifest.yaml](https://raw.githubusercontent.com/kubernetes-incubator/external-storage/master/aws/efs/deploy/manifest.yaml) and edit it according to your setup.

    2.  In the `configmap` section, specify **File System ID** of the newly created EFS as the value of the `file.system.id:` variable and **Availability Zone** of the newly created EFS as the value of the `aws.region:` variables.

    3.  In the `Deployment` section, specify DNS name of the newly created EFS as the value of the `server:` variable.

    4.  Run the `kubectl` command to apply the settings in manifest.yaml.

        ```
        kubectl apply -f manifest.yaml
        ```

    5.  Ensure that the EFS provisioner pod is in the running state using the `kubectl` command.

        ```
        kubectl get pods
        ```

3.  Create other Kubernetes object specification \(`.yaml`\) files based on your deployment requirement.

    For details about describing a Kubernetes object in a YAML file, see [Kubernetes documentation](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/). For details about the sample YAML files, see [Sample Kubernetes YAML Files for Applications with Shared Nothing Persistence](Sample%20YAML%20Files%20for%20Applications%20with%20Shared%20Nothing%20Persistence#).

4.  Create Kubernetes objects required for deploying and running the application by using the object specification \(`.yaml`\) files.

    For example, create the Kubernetes objects by using the sample YAML files mentioned in [Sample Kubernetes YAML Files for Applications with Shared Nothing Persistence](Sample%20YAML%20Files%20for%20Applications%20with%20Shared%20Nothing%20Persistence#).

    ```
    kubectl create -f becacheagent.yaml
    
    kubectl create -f bediscovery-service.yaml
    
    kubectl create -f beinferenceagent.yaml
    
    kubectl create -f befdservice.yaml
    ```

5.  \(Optional\) If required, you can check logs of TIBCO BusinessEvents pod.

    **Syntax**:

    ```
    kubectl logs <pod>
    ```

    For example, use the `kubectl get` command to get the list of pods and then use the `kubectl logs` command to view logs of `becacheagent`.

    ```
    kubectl get pods
    
    kubectl logs becacheagent-86d75d5fbc-z9gqt
    ```

6.  Get the external IP of your application, which you can use to connect to the cluster.

    **Syntax**

    ```
    kubectl get services <external_service_name>
    ```

    For example,

    ```
    kubectl get services befdservice
    ```


Test the application by using the external IP obtained. For example, if you have deployed the FraudDetectionStore example application with shared nothing persistence, update its readme.html file to test the application. Update the server address in application readme.html file from `localhost` to the external IP obtained. Now, follow the instructions in the readme.html file for testing the application.

**Parent topic:**[Running TIBCO BusinessEvents® on AWS Based Kubernetes Cluster](Running%20BusinessEvents%20Applications%20in%20Kubernetes)

