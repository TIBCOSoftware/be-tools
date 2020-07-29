
By using Red Hat OpenShift Container Platform, you can deploy a TIBCO BusinessEvents application in the Kubernetes cluster managed in an on-premises infrastructure.

As OpenShift Container Platform is built on top of Kubernetes cluster, you do not need to install Kubernetes separately. For details about OpenShift Container Platform, see [OpenShift Container Platform documentation](https://docs.openshift.com/index.html).
### Prerequisites
-   See [Preparing for TIBCO BusinessEvents Containerization](Before%20You%20Begin).
-   Docker image of your TIBCO BusinessEvents application, see [Building TIBCO BusinessEvents Application Docker Image](Building%20TIBCO%20BusinessEvents%20Application%20Docker%20Image).
### Procedure
1. Set up OpenShift Container Platform CLI to deploy the application from a terminal.

   See [Setting Up the OpenShift CLI Environment](Setting%20Up%20the%20OpenShift%20Container%20Platform%20CLI%20Environment).

2. Push the application Docker image to the OpenShift Container Platform registry.

   See [Pushing Application Docker Image to OpenShift Container Registry](Pushing%20Application%20Docker%20Image%20to%20OpenShift%20Container%20Registry).

3. Based on your application architecture, deploy the application on the Kubernetes cluster. See the following topics based on your application persistence option:

   -   [Running the Application Without Backing Store on OpenShift Container Platform](Running%20the%20Application%20for%20No%20Backing%20Store%20on%20OpenShift%20Container%20Platform).
   -   [Running the Application with Shared Nothing Persistence on OpenShift Container Platform](Running%20the%20Application%20with%20Shared%20Nothing%20Persistence%20on%20OpenShift%20Container%20Platform).
   -   [Running the Application with Shared All Persistence on OpenShift Container Platform](Running%20the%20Application%20for%20Shared%20All%20Persistence%20on%20OpenShift%20Container%20Platform).


**Parent topic:** [TIBCO BusinessEvents on OpenShift Container Platform Based Kubernetes](TIBCO%20BusinessEvents%20on%20OpenShift%20Container%20Platform%20Based%20Kubernetes)

**Related topics:**  
[Monitoring TIBCO BusinessEvents Applications on OpenShift Container Platform](Monitoring%20TIBCO%20BusinessEvents%20Applications%20on%20OpenShift%20Container%20Platform)

[Running the RMS on OpenShift Container Platform](Running%20the%20RMS%20on%20OpenShift%20Container%20Platform)

