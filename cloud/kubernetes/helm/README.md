# BE Helm Chart

## Introduction

This chart install a Business Events application deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Dependencies:

1. [MySQL chart](https://github.com/kubernetes/charts/tree/master/stable/mysql): It install a MySQL deployment for the database requirements of the backingstore BE applications. 
2. [efs-provisioner chart](https://github.com/helm/charts/tree/master/stable/efs-provisioner): Used to fulfill PersistentVolumeClaims with EFS PersistentVolumes for the BE applications.

The persisent volumes are created as folders with in an AWS EFS filesystem.

https://aws.amazon.com/efs/

## Prerequisites Details

* Kubernetes 1.15 or 1.17+
* Helm stable version 3.1.0
* PV provisioner support in the underlying infrastructure
* A Kubernetes cluster: You must have Kubernetes installed. For the latest release of Helm, we recommend the latest stable release of Kubernetes, which in most cases is the second-latest minor release. 

## StatefulSet and persistent volumes Details

* http://kubernetes.io/docs/concepts/abstractions/controllers/statefulsets/
* https://kubernetes.io/docs/concepts/storage/persistent-volumes/

## Installing the Chart

Clone be-tools repo and navigate to cloud/kubernetes folder

```
git clone https://github.com/TIBCOSoftware/be-tools.git
cd cloud/kubernetes
helm dep update ./helm
```

Update the required values for deployment in helm/values.yaml file(ex:image, imagePullPolicy etc.,)

To install the chart with the release name `my-release` in minikube

* omType: inmemory 

```
helm install my-release ./helm
```

For cache modes that includes persistentNone, sharedNothing and sharedAll
* persistentType=None
```
helm install my-release ./helm --set omType:cache,persistentType=None
```

* persistentType=sharedNothing
```
helm install my-release ./helm --set omType:cache,persistentType=sharedNothing
```

* persistentType=sharedAll with mysql dependency
```
helm install my-release ./helm --set omType:cache,persistentType=sharedAll,mysql.enabled=true
```

Note: minikube is the default provider

To install the chart with the release name `my-release` in azure

```
helm install my-release ./helm --set cloudProvider=azure
```

Note:<br> 
1.minikube is the default provider.<br> 
2.Update the values of mysql and efs-provisioner dependency in mysql section of helm/values.yaml.<br>


At any point to check how to use helm, simply run the `help` command
```
helm --help
```

## Uninstalling the Chart

To uninstall/delete the my-release deployment:

```
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart