# TIBCO BusinessEvents on Microsoft Azure Based Kubernetes

You can run any TIBCO BusinessEvents application on Microsoft Azure based Kubernetes cluster and monitor them by using TIBCO BusinessEvents Enterprise Administrator Agent. You can also manage business rules through WebStudio by running RMS on Microsoft Azure based Kubernetes cluster.

## Readme for Sample Applications

TIBCO BusinessEvents provides readme.html files for running the sample applications and components on Microsoft Azure. You can follow the instruction in the readme.html file to run the application, WebStudio, and TIBCO BusinessEvents Enterprise Administrator Agent by using the provided sample YAML files.

The following table lists location of readme.html and sample YAML files for running sample applications and other components:

|Scenario|readme.html and Sample YAML Files Location|
|--------|------------------------------------------|
|Running TIBCO BusinessEvents application \(FraudDetection\) without cache on Microsoft Azure|BE_HOME\cloud\kubernetes\Azure\inmemory|
|Running TIBCO BusinessEvents application \(FraudDetectionCache and FraudDetectionStore\) with cache on Microsoft Azure|BE_HOME\cloud\kubernetes\Azure\cache|
|Running TIBCO BusinessEvents WebStudio on Microsoft Azure|BE_HOME\cloud\kubernetes\Azure\rms|
|Running TIBCO BusinessEvents Enterprise Administration Agent for monitoring TIBCO BusinessEvents applications on Microsoft Azure|BE_HOME\cloud\kubernetes\Azure\tea|

## Topics


-   **[Running an Application on Microsoft Azure Based Kubernetes Cluster](Running%20an%20Application%20on%20Microsoft%20Azure%20Based%20Kubernetes%20Cluster)**  
By using the Azure Kubernetes Service \(AKS\), you can easily deploy an TIBCO BusinessEvents application in the Kubernetes cluster managed by Microsoft Azure.
-   **[Monitoring TIBCO BusinessEvents Applications on Microsoft Azure](Monitoring%20TIBCO%20BusinessEvents%20Applications%20on%20Microsoft%20Azure)**  
To monitor TIBCO BusinessEvents applications running on Microsoft Azure based Kubernetes, run TIBCO BusinessEvents Enterprise Administrator Agent container in the same Kubernetes namespace.
-   **[Running RMS on Azure Based Kubernetes](Running%20RMS%20on%20Azure%20Based%20Kubernetes)**  
By using the Azure Kubernetes Service \(AKS\), you can easily deploy the rule management server\(RMS\) on the Kubernetes cluster managed by Microsoft Azure.

