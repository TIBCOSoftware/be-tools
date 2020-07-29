# TIBCO BusinessEvents on Minikube Based Kubernetes

You can try out any TIBCO BusinessEvents application locally on a Kubernetes cluster by using the Minikube client and monitor them by using TIBCO BusinessEvents Enterprise Administrator Agent. You can also manage business rules through WebStudio by running RMS on Minikube based Kubernetes cluster.

For details about the Minikube client, see [Kubernetes Documentation](https://kubernetes.io/docs/home/).

## Readme for Sample Applications

TIBCO BusinessEvents provides readme.html files to help you in running the sample applications and components on Minikube. You can follow the instruction in the readme.html file to run the application, WebStudio, and TIBCO BusinessEvents Enterprise Administrator Agent by using the provided sample YAML files.

The following table lists location of readme.html and sample YAML files for running sample applications and other components:

|Scenario|readme.html and Sample YAML Files Location|
|--------|------------------------------------------|
|Running TIBCO BusinessEvents application \(FraudDetection\) without cache on Minikube|BE_HOME\cloud\kubernetes\minikube\inmemory|
|Running TIBCO BusinessEvents application \(FraudDetectionCache and FraudDetectionStore\) with cache on Minikube|BE_HOME\cloud\kubernetes\minikube\cache|
|Running TIBCO BusinessEvents WebStudio on Minikube|BE_HOME\cloud\kubernetes\minikube\rms|
|Running TIBCO BusinessEvents Enterprise Administration Agent for monitoring TIBCO BusinessEvents applications on Minikube|BE_HOME\cloud\kubernetes\minikube\tea|

