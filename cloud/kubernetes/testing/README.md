# Basic FTL, AS4 and Cassandra Applications for BE testing
This page contains steps to deploy basic FTL & AS4 applications into kubernetes cluster.

## FTL
Load docker images:
```sh
cd /opt/tibco/ftl/6.4/docker-images
docker load -i ftl-tibftlserver-6.4.0.dockerimage.xz
```

Deploy FTL server:
```sh
kubectl create namespace ftl
kubectl create -f ftl4be.yml -n ftl
kubectl get pods -n ftl
echo "FTL REALM URL: $(kubectl get service/ftlservers4be -n ftl -o jsonpath='{.status.loadBalancer.ingress[0].ip}'):8585"
```

Clean up:
```sh
kubectl delete -f ftl4be.yml -n ftl
kubectl delete namespace ftl
```

## AS4
Load docker images:
```sh
cd /opt/tibco/as/4.4/docker-images
docker load -i as-operations-4.4.0.dockerimage.xz
docker load -i as-tibdg-4.4.0.dockerimage.xz
docker load -i as-tibdgnode-4.4.0.dockerimage.xz
docker load -i as-tibdgkeeper-4.4.0.dockerimage.xz
docker load -i as-tibdgproxy-4.4.0.dockerimage.xz
docker load -i as-tibdgadmind-4.4.0.dockerimage.xz
```

Deploy AS4 Datagrid:
```sh
kubectl create namespace asdg
kubectl create -f asdg.yml -n asdg
kubectl get pods -n asdg
kubectl get services -n asdg
echo "AS4 DATAGRID REALM URL: $(kubectl get service/ftlservers -n asdg -o jsonpath='{.status.loadBalancer.ingress[0].ip}'):30080"
```

Add tables to AS4 datagrid:
```sh
cd /opt/tibco/as/4.4/bin/
./tibdg -r <AS4 DATAGRID REALM URL> status
export BE_HOME=<BE HOME PATH>
./tibdg -r <AS4 DATAGRID REALM URL> -s $BE_HOME/bin/create_tables_as4.tibdg
./tibdg -r <AS4 DATAGRID REALM URL> table list
```

Clean up:
```sh
kubectl delete -f asdg.yml -n asdg
kubectl get pvc -n asdg -o name | xargs kubectl delete -n asdg
kubectl delete namespace asdg
```

## Cassandra

Install Cassandra using using [BITNAMI CASSANDRA](https://bitnami.com/stack/cassandra/helm) helm chart:
```sh
helm repo add bitnami https://charts.bitnami.com/bitnami
helm install cassandra bitnami/cassandra
```

Get the cassandra password:
```sh
kubectl get secret --namespace default cassandra -o jsonpath="{.data.cassandra-password}" | base64 --decode
```

Connect to cassandra db:
```sh
# Replace CASSANDRA-POD-NAME and PASSWORD with actual values
kubectl exec -it CASSANDRA-POD-NAME bash
cqlsh -u cassandra -p PASSWORD 127.0.0.1 9042
```

Clean up:
```sh
helm uninstall cassandra
```

## Consul

Install Consul using [hashicorp consul](https://github.com/hashicorp/consul-helm) helm chart:

```sh
helm repo add hashicorp https://helm.releases.hashicorp.com
helm install -f helm-consul-values.yaml consulapp hashicorp/consul
```

Reference: [here](https://learn.hashicorp.com/tutorials/consul/kubernetes-minikube?in=consul/kubernetes)

Access consul UI using below service:
```sh
kubectl get service/consulapp-consul-ui
```

Clean up:
```sh
helm uninstall consulapp
```
## Telemetry

### OTLP

Install OpenTelemetry collector using [opentelemetry-collector](https://github.com/open-telemetry/opentelemetry-helm-charts/tree/main/charts/opentelemetry-collector) 

```
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm install -f otlp-collector-values.yaml my-opentelemetry-collector open-telemetry/opentelemetry-collector
```

Note: update the Zipkin and jaeger endpoints in config->exporters section of otlp-collector-values.yaml file.

Access Jaeger/zipking using the Jaeger or zipkin services.

Clean up:
```sh
helm uninstall my-opentelemetry-collector
```


### Jaeger

Install Jaeger tracing using [Jaeger Operator](https://github.com/jaegertracing/jaeger-operator)

```

kubectl create -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/crds/jaegertracing.io_jaegers_crd.yaml
kubectl create -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/service_account.yaml
kubectl create -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/role.yaml
kubectl create -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/role_binding.yaml
kubectl create -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/operator.yaml


kubectl create -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/cluster_role.yaml
kubectl create -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/cluster_role_binding.yaml

```
Once the jaeger-operator deployment in the namespace default is ready, create a Jaeger instance, like:

```
kubectl apply -n observability -f - <<EOF
apiVersion: jaegertracing.io/v1
kind: Jaeger
metadata:
  name: simplest
EOF
```


### Zipkin


Install zipkin in kubernetes cluster

```
kubectl create deployment zipkin --image openzipkin/zipkin
kubectl expose deployment zipkin --type ClusterIP --port 9411
```