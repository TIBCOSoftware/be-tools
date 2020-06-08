# Basic FTL & AS4 Applications for BE testing
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