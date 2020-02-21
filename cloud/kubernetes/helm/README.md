## Introduction

Helm helps you manage Kubernetes applications — Helm Charts help you define, install, and upgrade even the most complex Kubernetes application.


## Installation

### Prerequisites

The following prerequisites are required for a successful and properly secured use of Helm.

A Kubernetes cluster: You must have Kubernetes installed. For the latest release of Helm, we recommend the latest stable release of Kubernetes, which in most cases is the second-latest minor release.
You should also have a local configured copy of kubectl.


### Install
Clone https://github.com/TIBCOSoftware/be-tools.git using git clone command on your local machine. Open terminal and go to folder `cloud/docker/kubernetes`
Refer https://helm.sh/docs/intro/install/ to install Helm.


## Getting Started

Following command will run application:

        helm install <release_name> <chart_name>

              where release_name release name that you pick
              chart_name is the name of the chart you want to install

For example:
To run FraudDetectionCache application in Azure:

       helm install helm ./helm --set isType=cache,cloudProvider=azure


At any point to check how to use helm, simply run the `help` command

      helm --help
