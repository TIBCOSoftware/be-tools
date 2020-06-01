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


There are 4 primary configuration switches:

* cpType → Represents Cloud provider type. Valid values: AWS/Azure/OpenShift/GCP/Minikube | Default - Minikube
* cmType → Represents Cluster management type. Valid values: None/AS2/FTL | Default - None
* omType → Represents Object manage type. Valid values: Inmemory/Store/Cache | Default - Inmemory
* bsType → Represents Backing Store type. Valid values: None/SharedNothing/Store | Default - None <br>

There can be secondary configuration switches like mentioned below:

* storeType → Represents store type. It has significance only when bsType=Store OR omType=Store. Valid values: Oracle/SQLServer/DB2/MySql/PostgreSQL/AS4/Cassandra
* cacheType → Represents cache type. Valid values: AS2/Ignite | Default - AS2 (when cmType=AS2) / Ignite (when cmType=FTL)
Based on above switches section, Helm picks up required configuration and properties and deploys into connected Kubernetes environment.

Following table illustrates how to use helm switches to select particular deployment option out of 13 possible options in case of AWS cloud provider(i.e. cpType=AWS):


| Topology Name | cmType | omType | bsType  | storeType |
| ------------- | :---: | :---: | :---: | :---: |
| Unclustered Inmemory              |  unclustered      |        |        |           |
| Unclustered store AS4              | unclustered        |  store      |        | AS4          |
| Unclustered store Cassandra               | unclustered       | store       |        | Cassandra          | 
| clustered store AS4               |  AS2      | cache       | None       |           |
| clustered store Cassandra               | AS2       | cache       | sharedNothing        |           |
| clustered Cache AS2 None              | AS2      | cache       | None        |           |
| clustered Cache AS2 sharedNothing                | AS2       | cache       | sharedNothing       |           |
| clustered Cache AS2 store               | AS2       | cache       | store        |  RDBMS         |
| clustered Cache FTL None              |  FTL      | cache       | None       |           |
| clustered Cache FTL sharedNothing               | FTL       | cache       | sharedNothing       |           |
| clustered Cache FTL store RDBMS               |  FTL      |  cache      | store       | RDBMS          |
| clustered Cache FTL store AS4               | FTL       | cache       | store       | AS4          |
| clustered Cache FTL store Cassandra               |  FTL      | cache       | store       | Cassandra          |

Note: minikube is the default provider

To install the chart with the release name `my-release` in azure

```
helm install my-release ./helm --set cpType=azure
```

Note:<br> 
1.minikube is the default provider.<br> 
2.Update the values of mysql and efs-provisioner dependency in mysql section of helm/values.yaml.<br>


At any point to check how to use helm, simply run the `help` command
```
helm --help
```

## Testing Example:

* To test FraudDetection example refer to readme.html in helm folder

## Uninstalling the Chart

To uninstall/delete the my-release deployment:

```
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart

