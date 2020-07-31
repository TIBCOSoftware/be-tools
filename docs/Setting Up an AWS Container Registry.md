# Setting Up an Azure Container Registry

Amazon AWS uses the AWS Container Registry for securely building and deploying your applications.


-   Docker image of the TIBCO BusinessEvents application that you want to deploy to the Kubernetes cluster, see [Building TIBCO BusinessEvents Application Docker Image](Building%20TIBCO%20BusinessEvents%20Application%20Docker%20Image#).

## Registry setup
* Create the docker repository in AWS by running following command:

```
aws ecr create-repository --repository-name <repository-name>
```

* Tag the created image by running following command

```
docker tag fdcache:01 <aws_account_id>.dkr.ecr.<region>.amazonaws.com/<repository-name>:01
```

## Push Image

* Run following command to get docker login details:
```
aws ecr get-login --no-include-email
```

* Further, login to docker and push the image to your registry.

```
docker push <aws_account_id>.dkr.ecr.<region>.amazonaws.com/fdcache:01
```

**Next Topic**: Continue to [Kubernetes Deployments](deployments)
