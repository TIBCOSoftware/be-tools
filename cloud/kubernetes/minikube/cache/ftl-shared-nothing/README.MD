# Steps to deploy sharedNothing FTL cluster on minikube

* Create a minikube cluster by running minikube start
* Deploy sharedNothing FTL cluster as follows

```
kubectl create configmap app --from-file=cepftlcluster_persistence.yaml
kubectl create -f persistent-volumes.yaml
kubectl create -f ftlserver.yaml
kubectl create -f ftlsvc.yaml
```

Run the ftlclient from local machine:
```
tibftladmin -ur <path to cepftlrealm.json> -rs http://<minikube ip>:<minikube ftl port>
```


```
kubectl create -f bediscovery-service.yaml
kubectl create -f befdservice.yaml
kubectl create -f becacheagent.yaml
kubectl create -f beinferenceagent.yaml
```

## Testing:
Create an account by accesing `http://<minikube ip>:<minikube fdservice port>`

For more details refer to readme.html in cachefolder