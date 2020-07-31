# BE Helm Chart

## Introduction

This chart installs TIBCO BusinessEvents application deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

## Prerequisites Details

* Kubectl 1.15 or 1.17+
* [Helm](https://helm.sh/docs/intro/install/)
* PV provisioner support in the underlying infrastructure
* A Kubernetes cluster: You must have Kubernetes installed. For the latest release of Helm, we recommend the latest stable release of Kubernetes.


## Installing the Chart

Clone be-tools repo and navigate to cloud/kubernetes folder

```
git clone https://github.com/TIBCOSoftware/be-tools.git
cd cloud/kubernetes
helm dep update ./helm
```

* cpType → Refers to Cloud provider type.
* cmType → Refers to Cluster management type.
* omType → Refers to Object manage type.
* bsType → Refers to Backing Store type.
* storeType → Refers to store type. It has significance only when bsType=store OR omType=store. Valid values: RDBMS(Oracle/SQLServer/DB2/MySql/PostgreSQL)/AS4/Cassandra

Following table illustrates how to use helm switches to select particular deployment option out of 13 possible options:

| Topology Name | cmType | omType | bsType  | storeType |
| ------------- | :---: | :---: | :---: | :---: |
| Unclustered Inmemory *   |  unclustered      | inmemory       |  na      | na          |
| Unclustered store AS4             | unclustered        |  store      | na       | AS4          |
| Unclustered store Cassandra              | unclustered       | store       |na        | Cassandra          |
| clustered store AS4                           | FTL      | store       | na        | AS4          |
| clustered store Cassandra              | FTL       | store       | na         | Cassandra          |
| clustered Cache AS2 None *                        | AS2      | cache       | None        | na          |
| clustered Cache AS2 sharedNothing *                            | AS2       | cache       | sharedNothing       |  na         |
| clustered Cache AS2 store *                           |AS2       | cache       | store        |  RDBMS         |
| clustered Cache FTL None                          | FTL      | cache       | None       |   na        |
| clustered Cache FTL sharedNothing                           |FTL       | cache       | sharedNothing       | na           |
| clustered Cache FTL store RDBMS              |  FTL      |  cache      | store       | RDBMS          |
| clustered Cache FTL store AS4              | FTL       | cache       | store       | AS4          |
| clustered Cache FTL store Cassandra              |  FTL      | cache       | store       | Cassandra          |


**Key Points** :
* `*` in above table indicates, topologies that were supported in 5.x.x
* `Minikube` is the default provider.
* Update the required values in values.yaml.(ex: image,imagePullPolicy etc..,)
* For setting up local mysql database, update mysql->enabled to true in values.yaml
* For setting up AWS EFS file storage, update aws-efs->enabled to true in values.yaml
* If you are using global variable group in cdd file, instead of the slash '`/`' delimiter between global variable group name and global variable name, use "`_gv_`". For example, `port` is a global variable which is part of the `VariableGP` global variable group, then instead of using `VariableGP/port` in values.yaml file, use `VariableGP_gv_port`. Also, ensure that you do not use the "`gv`" token in any global variable group name or global variable name.

To install the chart with the release name `my-release` in azure

```
helm install my-release ./helm --set cpType=azure
```

**Note**:

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


## Testing

* see [Testing](Testing.md)

## Additional Information

Below dependencies are included in BE helm charts

1. [MySQL chart](https://github.com/kubernetes/charts/tree/master/stable/mysql): It installs MySQL deployment for the database requirements of the backingstore BE applications.
2. [efs-provisioner chart](https://github.com/helm/charts/tree/master/stable/efs-provisioner): Used to fulfill PersistentVolumeClaims with EFS PersistentVolumes for the BE applications.

The persisent volumes are created as folders with in an AWS EFS filesystem.

https://aws.amazon.com/efs/

### StatefulSet and persistent volumes Details

* http://kubernetes.io/docs/concepts/abstractions/controllers/statefulsets/
* https://kubernetes.io/docs/concepts/storage/persistent-volumes/