# Metrics Configuration and Deployment

* BE Helm charts offers provision for time series database setup using InfluxDB and Grafana as dashboard.

## Both InfluxDB and Grafana deployment 

* To deploy helm chart for metrics, Set metricsType to `influx`
    
    * Using InfluxDB and Grafana dependency charts
        ```
        helm install my-release ./helm --set tags.metrics=true,metricsType=influx
        ```

    * Using external influx and grafana services
        ```
        helm install my-release ./helm --set metricsType=influx
        ```
* After deploying BE app connect to influx pod and create database
* Access grafana in browser using {clusterip}:{grafana-service-nodeport}
* Generate password for grafana
    ```
    kubectl get secret --namespace default <grafana secret name> -o jsonpath="{.data.admin-password}" | base64 --decode ; echo
    ```
* Login to grafana dashboard using username:admin, password obtained from above command

## InfluxDB deployment

* If you want to deploy only InfluxDB as dependency chart

    ```
    helm install my-release ./helm --set influxdb.enabled=true
    ``` 

## Grafana deployment

* If you want to deploy only grafana as dependency chart

    ```
    helm install my-release ./helm --set grafana.enabled=true
    ``` 
## Database creation and Testing

* Please refer to example html file

## TIBCO Streaming with dashboards in TIBCO LiveViewWeb

* If you want to deploy BE application with TIBCO streaming with dashboard in TIBCO LiveViewWeb, set metricsType to `liveview`

    ```
    helm install my-release ./helm --set metricsType=liveview
    ```