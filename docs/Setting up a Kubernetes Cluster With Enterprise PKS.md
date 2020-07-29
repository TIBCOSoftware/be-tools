# Setting Up a Kubernetes Cluster with Enterprise PKS

In Pivotal, you can use Enterprise PKS to create and manage a Kubernetes cluster. Use the Enterprise PKS Command Line Interface \(PKS CLI\) to deploy the Kubernetes cluster and manage its lifecycle. To deploy and manage container-based workloads on the Kubernetes cluster, use the Kubernetes CLI \(`kubectl`\).

## Pre-requisites
* Install [TKGI CLI](https://docs.pivotal.io/tkgi/1-8/installing-cli.html)
* Install [Kubernetes CLI](https://docs.pivotal.io/tkgi/1-8/installing-kubectl-cli.html)


### GCP Subscription
You need to have an account created and should be able to access Google Cloud Platform.

* GCP [Console](https://console.cloud.google.com/)

If your account is setup, you can login using your credentials.

#### VMware subscription for TKGI
* Create a [Pivotal account](https://account.run.pivotal.io/z/uaa/sign-up) to download various tools and dependent softwares required.

### Install TKGI on GCP
* Below are the various dependencies that need to be setup/configured as part of TKGI installation on Google Cloud Platform.

#### Install & configure Ops manager
* Deploy Ops manager using Terraform, as it automates creation of various required GCP resources. Follow [steps](https://docs.pivotal.io/platform/ops-manager/2-8/gcp/prepare-env-terraform.html)<br>

**Note**: Observed some errors with the latest terraform CLI. Use slightly older version, lets say "v0.11.14" to make it work.
* Configure BOSH Director by accessing the Ops manager you have created in the previous step. Follow [steps](https://docs.pivotal.io/platform/ops-manager/2-8/gcp/config-terraform.html)<br>

**Note**: Use "Internal Authentication" method here for quick setup.

#### Import TKGI & Configure
* Download the product "Tanzu Kubernetes Grid Integrated Edition" v1.8 [from](https://network.pivotal.io)<br>

**Note**: TKGI v1.8 package size would be ~4 GB, hence you may want to download this while preforming other steps.
* Import the TKGI package downloaded in the previous step and configure. Follow [steps](https://docs.pivotal.io/tkgi/1-8/installing-gcp.html)
#### Setup Admin Users

* You need to create at least one admin user. It is necessary step during the initial set up of TKGI. Follow [steps](https://docs.pivotal.io/tkgi/1-8/gcp-configure-users.html)

### Setup Kubernetes cluster
This section provisions new Kubernetes cluster using the TKGI you have created in previous section.

* Create Kubernetes cluster by using [TKGI CLI](https://docs.pivotal.io/tkgi/1-8/create-cluster.html)
* Create a Load Balancer in order to access/manage the cluster using Kubernetes CLI from local machine. [Load Balancer](https://docs.pivotal.io/tkgi/1-8/gcp-cluster-load-balancer.html)
* Run kubectl cluster-info command to confirm access to the cluster using the Kubernetes CLI.


**[Next]**: Continue to setup [container registry](Setting%20up%20Google%20Container%20Registry)
