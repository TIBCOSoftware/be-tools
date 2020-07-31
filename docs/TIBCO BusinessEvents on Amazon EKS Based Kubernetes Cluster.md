# TIBCO BusinessEvents on Amazon EKS Based Kubernetes

You can run any TIBCO BusinessEvents application on Amazon Elastic Kubernetes Service \(Amazon EKS\) and monitor the application by using TIBCO BusinessEvents Enterprise Administrator Agent. You can also manage business rules in TIBCO BusinessEvents WebStudio by running RMS on the AWS based Kubernetes cluster.

For details, see [Amazon EKS Documentation](https://docs.aws.amazon.com/eks/index.html).

## Prerequisite

* Setup eksctl [cli](https://docs.aws.amazon.com/eks/latest/userguide/getting-started-eksctl.html)


## Create EKS Cluster
* Create your Amazon EKS cluster and worker nodes with the following command:
```
eksctl create cluster
eksctl create cluster --help
```
* To delete the cluster, run the following command:
```
eksctl delete cluster --name <cluster-name>
```
* To check if everything is properly configured, run the following command
```
kubectl get services
```

**Next Topic**: [Registry](Setting%20Up%20an%20AWS%20Container%20Registry)

