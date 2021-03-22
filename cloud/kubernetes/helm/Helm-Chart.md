This chart installs TIBCO BusinessEvents application deployment on a [Kubernetes](http://kubernetes.io) cluster using the [Helm](https://helm.sh) package manager.

* [Prerequisites](#Prerequisites-Details)
* [Installing chart](#Installing-the-Chart)
* [Metrics](#Metrics-Configuration-and-Deployment)
* [Uninstalling chart](#Uninstalling-the-Chart)
* [Testing](#Testing)
* [Backup and Restore](#Backup-and-Restore)

## Features

* Dynamic persistence volumes
* Dependency chart support for mysql, aws-efs csi driver, influxdb and grafana
* Support BE App metrics
* Support all Business Events application Topologies
* Auto scaling of pods using Horizonal Pod autoscaler
* Scale up BE pods evenly across nodes
* Scale down BE pods evenly across nodes

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
```

* cpType → Refers to Cloud provider type.Use this flag for awsfargate deployments. For other cloudproviders it is not required.
* cmType → Refers to Cluster management type.
* omType → Refers to Object manage type.
* bsType → Refers to Backing Store type.
* storeType → Refers to store type. It has significance only when bsType=store OR omType=store. Valid values: RDBMS(Oracle/SQLServer/DB2/MySql/PostgreSQL)/AS4/Cassandra

Following table illustrates how to use helm switches to select particular deployment option out of possible options:

| Topology Name | cmType | omType | bsType  | storeType |
| ------------- | :---: | :---: | :---: | :---: |
| Unclustered Inmemory *   |  unclustered      | inmemory       |  na      | na          |
| Unclustered store AS4             | unclustered        |  store      | na       | AS4          |
| Unclustered store Cassandra              | unclustered       | store       |na        | cassandra          |
| clustered store AS4                           | ftl      | store       | na        | as4          |
| clustered store Cassandra              | ftl       | store       | na         | cassandra          |
| clustered Cache AS2 None *                        | as2      | cache       | none        | na          |
| clustered Cache AS2 sharednothing *                            | as2       | cache       | sharednothing       |  na         |
| clustered Cache AS2 store *                           |as2       | cache       | store        |  rdbms         |
| clustered Cache FTL None                          | ftl      | cache       | none       |   na        |
| clustered Cache FTL sharednothing                           |ftl       | cache       | sharednothing       | na           |
| clustered Cache FTL store RDBMS              |  ftl      |  cache      | store       | rdbms          |
| clustered Cache FTL store AS4              | ftl       | cache       | store       | as4          |
| clustered Cache FTL store Cassandra              |  ftl      | cache       | store       | cassandra          |
| clustered Cache IGNITE None                          | ignite      | cache       | none       |   na        |
| clustered Cache IGNITE sharednothing                           |ignite       | cache       | sharednothing       | na           |
| clustered Cache IGNITE store RDBMS              |  ignite      |  cache      | store       | rdbms          |
| clustered Cache IGNITE store AS4              | ignite       | cache       | store       | as4          |
| clustered Cache IGNITE store Cassandra              |  ignite      | cache       | store       | cassandra          |


**Key Points** :
* `*` in above table indicates, topologies that were supported in 5.x.x
* `Minikube` is the default provider.
* Update the required values in values.yaml.(ex: image,imagePullPolicy etc..,)
* For setting up local mysql database, update mysql->enabled to true in values.yaml
* For setting up AWS EFS file storage, update aws-efs->enabled to true in values.yaml
* If you are using external servers(FTL) or databases(ex: MySQL, Cassandra), make sure that the url's are reachable by the cluster.  
* If you are using global variable group in cdd file, instead of the slash '`/`' delimiter between global variable group name and global variable name, use "`_gv_`". For example, `port` is a global variable which is part of the `VariableGP` global variable group, then instead of using `VariableGP/port` in values.yaml file, use `VariableGP_gv_port`. Also, ensure that you do not use the "`gv`" token in any global variable group name or global variable name.
* If you want to use custom GV provider, you need pass appropriate environment variables under `env` section of the values.yaml. For more details refer to [GV configuration Framework](https://github.com/TIBCOSoftware/be-tools/wiki/Using-GV-Configuration-Framework).
* If your clusterprovider is `awsfargate` make sure to use `beservice.type` as `NodePort`.Also the `volumes.storageClass` should not be an existing storage class, as the storage class will be created on helm deployment.

To install the chart with the release name `my-release` in azure with Horizonal pod autoscaling

```
helm install my-release ./helm --set cpType=azure,hpa=true
```

**Note**:

At any point to check how to use helm, simply run the `help` command
```
helm --help
```
## Metrics Configuration and Deployment

* BE Helm charts offers provision for time series database setup using InfluxDB and Grafana as dashboard.

### Metrics - InfluxDB and Grafana deployment 

* If you want to deploy BE application with InfluxDB and grafana, set metricsType to `influx`

    ```
    helm install my-release ./helm --set metricsType=influx
    ```
### Dependency chart deployment
* Using InfluxDB and Grafana dependency charts

    ```
    helm install my-release ./helm --set metricsType=influx,influxdb.enabled=true,grafana.enabled=true
    ```
    * After deploying BE app connect to influx pod and create database
    * Access grafana in browser using {clusterip}:{grafana-service-port}
    * Generate password for grafana
        ```
        kubectl get secret --namespace default <grafana secret name> -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
        ```
    * Login to grafana dashboard using username:admin, password obtained from above command

### Database creation and Testing

* Please refer to example html file

### TIBCO Streaming with dashboards in TIBCO LiveViewWeb

* If you want to deploy BE application with TIBCO streaming with dashboard in TIBCO LiveViewWeb, set metricsType to `liveview`

    ```
    helm install my-release ./helm --set metricsType=liveview
    ```

### Custom metrics deployment

* If you want to deploy BE application with custom metrics(ex:elastic,kibana,prometheus or any other dashboard tool), update the key value pairs in `metricdetails` section of values yaml file and set `metricsType` to `custom`

    ```
    helm install my-release ./helm --set metricsType=custom
    ```

### Health Check

* If you want to deploy BE application with health check,such as Readiness probe and Liveliness probe for the cache and inference agents, enable the `healthcheck` section of values yaml file by setting `healthcheck.enable` to true and set appropriate time intervals.

    ```
    helm install my-release ./helm --set healthcheck.enabled=true
    ```


## Uninstalling the Chart

To uninstall/delete the my-release deployment:

```
$ helm delete my-release
```

The command removes all the Kubernetes components associated with the chart


## Testing

* See [Testing](Testing)

## Backup and Restore

* Backup and restore BE application using [Velero](https://velero.io/).

* Refer to velero documentation for support across cloud providers [here](https://velero.io/docs)

* Deploy [velero](https://github.com/vmware-tanzu/helm-charts/tree/master/charts/velero) using helm charts

## Additional Information

Below dependencies are included in BE helm charts

1. [MySQL chart](https://github.com/bitnami/charts/tree/master/bitnami/mysql): It installs MySQL deployment for the database requirements of the backingstore BE applications.
2. [efs-provisioner chart](https://github.com/helm/charts/tree/master/stable/efs-provisioner): Used to fulfill PersistentVolumeClaims with EFS PersistentVolumes for the BE applications.
3.  [influxdb chart](https://github.com/influxdata/helm-charts/tree/master/charts/influxdb):  It's useful for recording metrics, events, and performing analytics.
4. [Grafana chart](https://github.com/grafana/helm-charts/tree/main/charts/grafana): Used for viewing BE application metrics.

The persisent volumes are created as folders with in an [AWS EFS](https://aws.amazon.com/efs/)

### StatefulSet and persistent volumes Details

* [Statefulsets](http://kubernetes.io/docs/concepts/abstractions/controllers/statefulsets/)
* [Persistent-volumes](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)
