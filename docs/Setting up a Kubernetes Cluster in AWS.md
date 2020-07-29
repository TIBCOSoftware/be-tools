# Setting up a Kubernetes Cluster on AWS

Set up a Kubernetes cluster with AWS for running TIBCO BusinessEvents® application.

1.  Creating Cluster
2.  Create an Amazon Simple Storage Service \(Amazon S3\) storage to store the cluster configuration and state. You can use either AWS CLI or AWS console to create the storage.

    For more information about Amazon S3, see [Amazon S3 Documentation](https://aws.amazon.com/documentation/s3/).

    **For example:**

    ```
    aws s3 mb s3://be-bucket
    ```

3.  Create the Kubernetes cluster on AWS using the `kops` CLI.

    For more information, see the [kops CLI documentation](https://github.com/kubernetes/kops/tree/master/docs).

    **For example:**

    ```
    kops create cluster --zones us-west-2a --master-zones us-west-2a --master-size t2.large --node-size t2.large --name becluster.k8s.local --state s3://<s3-bucket-name> --yes
    ```

    Where,

    -   `s3-bucket-name` is the name of the S3 storage created earlier.
    -   `becluster.k8s.local` is the name of the cluster being created. Use `k8s.local` prefix to identify a gossip-based Kubernetes cluster and you can skip the DNS configuration.
4.  Validating Cluster
5.  Validate your cluster using the `validate` command.

    ```
    kops validate cluster
    ```

    Node and master must be in ready state. The `kops` utility stores the connection information at ~/.kops/config, and `kubectl` uses the connection information to connect to the cluster.


**Parent topic:**[Running TIBCO BusinessEvents® on AWS Based Kubernetes Cluster](Running%20BusinessEvents%20Applications%20in%20Kubernetes)

