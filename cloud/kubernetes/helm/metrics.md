# Metrics Configuration and Deployment

* BE Helm charts offers provision for time series database setup using InfluxDB and Grafana as dashboard.

## Metrics - InfluxDB and Grafana deployment 

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

## Database creation and Testing

* Please refer to example html file

## TIBCO Streaming with dashboards in TIBCO LiveViewWeb

* If you want to deploy BE application with TIBCO streaming with dashboard in TIBCO LiveViewWeb, set metricsType to `liveview`

    ```
    helm install my-release ./helm --set metricsType=liveview
    ```

## Custom metrics deployment

* If you want to deploy BE application with custom metrics(ex:elastic,kibana,prometheus or anyother dashboard tool), update the key value pairs in `metricdetails` section of values yaml file and set `metricsType` to `custom`

    ```
    helm install my-release ./helm --set metricsType=custom
    ```