## Introduction


The following table lists location of sample YAML files for running sample applications and other components:

|Scenario| Sample YAML Files Location|
|--------|------------------------------------------|
|Running TIBCO BusinessEvents application \(FraudDetection\) without cache on cloud_name|BE_HOME\cloud\kubernetes\cloud_name\inmemory|
|Running TIBCO BusinessEvents application \(FraudDetectionCache and FraudDetectionStore\) with cache on cloud_name|BE_HOME\cloud\kubernetes\cloud_name\cache|
|Running TIBCO BusinessEvents WebStudio on cloud_name|BE_HOME\cloud\kubernetes\cloud_name\rms|
|Running TIBCO BusinessEvents Enterprise Administration Agent for monitoring TIBCO BusinessEvents applications on cloud_name|BE_HOME\cloud\kubernetes\cloud_name\tea|


**Note**: cloud_name can be AWS, Azure, Openshift, PKS, minikube

## Deployments

Please refer to deployments below.

* [Running BE Application](Running%20an%20Application)
* [Running the RMS](Running-on-RMS.md)
* [ Monitoring TIBCO BusinessEvents Applications](Monitoring%20TIBCO%20BusinessEvents%20Applications.md)

## Need to add content 

ex: abt BE app, RMS and tea

Provide reference in below pages
1. Cluster setup of cloud provider
2. link as Next topic in cloud registry setup


Note: For Openshift cluster deployments, you can use `oc` or `kubectl` cli for deployments to cluster.
