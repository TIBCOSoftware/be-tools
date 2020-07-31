# TIBCO BusinessEvents on Microsoft AWS Based Kubernetes

You can run any TIBCO BusinessEvents application on Microsoft AWS based Kubernetes cluster and monitor them by using TIBCO BusinessEvents Enterprise Administrator Agent. You can also manage business rules through WebStudio by running RMS on Microsoft AWS based Kubernetes cluster.

* There are options available to create AWS Container platform:

    * [EKS](TIBCO%20BusinessEvents%20on%20AWS%20Based%20Kubernetes)
    * [KOPS](Setting%20up%20a%20Kubernetes%20Cluster%20in%20AWS)


**Note:** Ensure that your application connection properties for database use global variables.

## Setup Amazon RDS for store(backing store) persistence

Create an Amazon RDS based instance and configure it to connect to a TIBCO BusinessEvents supported database \(Oracle, MySQL, DB2, and so on\).

    For configuration details, see [Amazon RDS documentation](https://aws.amazon.com/documentation/rds/).    


## Setup EFS file system

* Create an EFS file system [here](Running%20RMS%20Applications%20in%20Kubernetes)