# Testing BE application

## Key points

* To list all kubernetes objects, run below command

```
kubectl get all
```

* To list pods and check pod logs, run below command

```
kubectl get pods
# pod logs
kubectl logs -f <podName>
```

* To get node IP, run below command

```
kubectl get nodes -o wide
```

**Notes**:

* If the beservice port type is Nodeport, application is accessed with `<k8s-node-ip>:<external-be-serviceport>`
```
  example:     192.168.0.100:3xxxx
```
* If beservice port type is LoadBalancer, application is accessed with `<be-service-external-IP>:<be-serviceport>`
```
  example:     10.0.100.1:8xxx
```
* How to test BE Application?
  * If you are testing an BE example application, Refer to readme.html available in example folder

  * Test the application by using the external IP obtained. For example, if you have deployed the FraudDetectionStore example application with the shared all persistence, you can use the sample readme.html application. Use the obtained external IP in the readme.html file and follow the instructions in it to run the application.

  * However, if you have deployed any other sample application then update its readme.html file to test the application. Update the server address in application readme.html file from `localhost` to the external IP obtained. Now, follow the instructions in the readme.html file for testing the application.
