# TIBCO BusinessEvents on Amazon EKS Based Kubernetes

You can run any TIBCO BusinessEvents application on Amazon Elastic Kubernetes Service \(Amazon EKS\) and monitor the application by using TIBCO BusinessEvents Enterprise Administrator Agent. You can also manage business rules in TIBCO BusinessEvents WebStudio by running RMS on the AWS based Kubernetes cluster.

For details, see [Amazon EKS Documentation](https://docs.aws.amazon.com/eks/index.html).

## Readme for Sample Applications

The readme.html files that are provided with TIBCO BusinessEvents contain information about running the sample applications and components on Amazon EKS. You can follow the instruction in the readme.html files to run the application, WebStudio, and TIBCO BusinessEvents Enterprise Administrator Agent by using the sample YAML files.

The following table lists location of readme.html and sample YAML files for running sample applications and other components:

|Scenario|Readme.html and Sample YAML Files Location|
|--------|------------------------------------------|
|Running TIBCO BusinessEvents application \(FraudDetection\) without cache on AWS|BE_HOME\cloud\kubernetes\AWS\inmemory|
|Running TIBCO BusinessEvents application \(FraudDetectionCache and FraudDetectionStore\) with cache on AWS|BE_HOME\cloud\kubernetes\AWS\cache|
|Running TIBCO BusinessEvents WebStudio on AWS|BE_HOME\cloud\kubernetes\AWS\rms|
|Running TIBCO BusinessEvents Enterprise Administration Agent for monitoring TIBCO BusinessEvents applications on AWS|BE_HOME\cloud\kubernetes\AWS\tea|

