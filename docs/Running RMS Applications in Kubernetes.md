# AWS EFS file system


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
* For RMS continute to setp 4

4.  As RMS is running in a Docker container, separate external storage must be set up for required files and artifacts. For this, create EFS based `PersistentVolumeClaim` \(PVC\) using the configuration files \(YAML format\).

    The sample YAML file `berms-efs-persistent-volume-claims.yaml` for creating storage class and PVCs is located at BE_HOME\cloud\kubernetes\AWS\rms. The `berms-efs-persistent-volume-claims.yaml` file set up the following PVC:

    |PVC Name|Description|
    |--------|-----------|
    |`efs-webstudio`|Set up the PVC for storing TIBCO BusinessEvents project files.|
    |efs-security|Set up the PVC for storing TIBCO BusinessEvents project ACL files, such as, `CreditCardApplication.ac`.|
    |`efs-shared`|Set up the PVC for storing RMS artifacts after hot deployment, such as, rule template instances.|
    |`efs-notify`|Set up the PVC for storing Email notification files, such as, `message.stg`.|

    For more information about the Kubernetes object spec files, see [Kubernetes documentation](https://kubernetes.io/docs/concepts/overview/working-with-objects/kubernetes-objects/).

5.  Run the `create` command of `kubectl` utility using the YAML files to create PVCs on the EFS file system.

    For example, create PVCs using the sample files:

    ```
    kubectl create -f berms-efs-persistent-volume-claims.yaml
    ```

6.  Mount the EFS file system into the Kubernetes EC2 instance nodes.

    For more information on how to mount EFS file system on EC2 instance, refer AWS Documentation at [https://docs.aws.amazon.com/efs/latest/ug/mounting-fs.html](https://docs.aws.amazon.com/efs/latest/ug/mounting-fs.html).

    After successful mounting, PVCs on EFS are available for uploading files.

**Next Topic**: Continue to [RMS Deployments](Running-on-RMS.md)

