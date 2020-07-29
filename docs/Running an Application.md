# Running BusinessEvents Application

You can deploy a TIBCO BusinessEvents application in the Kubernetes cluster.

## Prereqisites

*  See [Preparing for TIBCO BusinessEvents Containerization](Before%20You%20Begin)
*  Docker image of your TIBCO BusinessEvents application. See [Building TIBCO BusinessEvents Application Docker Image](Building%20TIBCO%20BusinessEvents%20Application%20Docker%20Image).

*  Push the TIBCO BusinessEvents application Docker image to respective cloud Container Registry.
*  Based on your application architecture, deploy the application on the Kubernetes cluster. See the following topics based on your application persistence option:

## BE Application Deployment

* Application deployment in kubernetes can be done using two approaches
    * Using [Kubernetes yaml files](kubernetes%20yaml%20files)
    * Using [Helm charts](helm%20chart)
