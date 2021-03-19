# Building opertors using helm

Building a Helm Based Operator using Operator SDK

## Pre-requisites

* Refer to installation [guide](https://sdk.operatorframework.io/docs/installation/)
* Running Kubernetes cluster 

## Generate Operator

* Navigate to cloud/kubernetes directory
* Create directory `operator`
* Run below commands to generator operator code

```
cd operator
operator-sdk init --plugins=helm --domain be.tibco.com
operator-sdk create api       --helm-chart=../helm     --helm-chart-version=1.0.0 --verbose
```

* Provide required rbac permissions to deploy horizontal pod autoscaling.
* Navigate to config/rbac/role.yaml file, add below snippet

```
- verbs:
  - create
  - delete
  - get
  - list
  - patch
  - update
  - watch
  apiGroups:
  - "autoscaling"
  resources:
  - "horizontalpodautoscalers"
```

* Install BE helm chart operator

```
make install
export IMG=<reponame>/ops:0.1
make docker-build docker-push IMG=$IMG
make deploy IMG=$IMG
kubectl get deployments -n operator-system
```

* Update the values in `config/samples/charts_v1alpha1_behelmchart.yaml` as per required BE topology and deploy customresource yaml

```
kubectl apply -f config/samples/charts_v1alpha1_behelmchart.yaml
kubectl get pods
```

* Test the application following example readme.
