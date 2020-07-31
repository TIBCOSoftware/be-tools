# TIBCO BusinessEvents on Minikube Based Kubernetes

You can try out any TIBCO BusinessEvents application locally on a Kubernetes cluster by using the Minikube client and monitor them by using TIBCO BusinessEvents Enterprise Administrator Agent. You can also manage business rules through WebStudio by running RMS on Minikube based Kubernetes cluster.

For details about the Minikube client, see [Kubernetes Documentation](https://kubernetes.io/docs/home/).


## Prerequisites

* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* [minikube](https://kubernetes.io/docs/tasks/tools/install-minikube/)

## Setup

* Start the Minikube

Syntax :

```
minikube  start --cpus  <cpus>  --memory  <memory>       // here <cpus> is number of cpu unit (for ex, 2)  and <memory> is RAM allocated (like, 4096)
```

* For Persistence cases

Syntax :

```
minikube  start --cpus  <cpus>  --memory  <memory> --mount --mount-string ="host dir path:/data"       // here <cpus> is number of cpu unit (for ex, 2)  and <memory> is RAM allocated (like, 4096)
```

## Next Steps

* How to deploy TIBCO BusinessEvents application is available [here](deployments) 


