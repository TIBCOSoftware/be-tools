
Kubernetes is an open-source platform designed to automate deploying, scaling, and operating application containers. Kubernetes can run application containers on clusters of physical or virtual machines.

For more information about Kubernetes, see [Kubernetes documentation](https://kubernetes.io/docs/home/).

In TIBCO BusinessEvents, to form a cluster, discovery nodes starts a cluster and other non-discovery nodes \(cache and inference\). These non-discovery nodes connect to one or more discovery nodes and become a member of the cluster. In Kubernetes, each TIBCO BusinessEvents node runs as a Kubernetes *pod*. Pods communicate with each other by using their IP addresses. However, due to the dynamic nature of the IP addresses, non-discovery nodes cannot always connect to discovery nodes. Thus, to resolve this issue, discovery nodes are modeled as Kubernetes *services*. The service is reachable by its name by using the Kubernetes DNS. Non-discovery nodes use indirection by using the Kubernetes service to connect to discovery nodes.

*  [TIBCO BusinessEvents application deployment using Helm charts](Kubernetes%20Helm.md)

-   [TIBCO BusinessEvents on OpenShift Container Platform Based Kubernetes](TIBCO-BusinessEvents-on-OpenShift-Container-Platform-Based-Kubernetes)
-   [TIBCO BusinessEvents on Microsoft Azure Based Kubernetes](TIBCO%20BusinessEvents%20on%20Microsoft%20Azure%20Based%20Kubernetes)
-   [TIBCO BusinessEvents on AWS Based Kubernetes](TIBCO%20BusinessEvents%20on%20AWS%20Based%20Kubernetes)
-   [TIBCO BusinessEvents on Amazon EKS Based Kubernetes](TIBCO%20BusinessEvents%20on%20Amazon%20EKS%20Based%20Kubernetes%20Cluster)
-   [TIBCO BusinessEvents on Pivotal Based Kubernetes](TIBCO%20BusinessEvents%20on%20Pivotal%20Based%20Kubernetes)
-   [TIBCO BusinessEvents on Minikube Based Kubernetes](TIBCO%20BusinessEvents%20on%20Minikube%20Based%20Kubernetes)

