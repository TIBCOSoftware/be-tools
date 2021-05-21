## Introduction

This page deploys Activespaces store Application with multiple cache nodes in Pivotal Cloud foundry.

## Deployment

1)Clone the repo:

     git clone https://github.com/TIBCOSoftware/be-tools.git
     cd be-tools/cloud/cloud-foundry/examples
     
2)Update environment variables for your BE image in as2store.yml file in both cache and inference env sections.

3)Use the below command to deploy Business Events application:

      cf push cache-0 -u process
      cf push cache-1 -u process
      cf push inference -u process

4)If your docker image is in a Private repository update Docker username in manifest file.Also add 'CF_DOCKER_PASSWORD=PASSWORD' environment variable in above commands.
       
        CF_DOCKER_PASSWORD=PASSWORD cf push <APP-NAME> -u process

Note: For AWS ECR refer [here](https://docs.cloudfoundry.org/devguide/deploy-apps/push-docker.html#ecr).For Google Container registry refer [here](https://docs.cloudfoundry.org/devguide/deploy-apps/push-docker.html#gcr).

### Service Discovery

For Activespaces Service Discovery add below network policies with respect to application cluster type.

    cf add-network-policy cache-0 cache-1 --port 50000 --protocol tcp
    cf add-network-policy cache-1 cache-0 --port 50000 --protocol tcp
    cf add-network-policy cache-0 inference --port 50000 --protocol tcp
    cf add-network-policy inference cache-0 --port 50000 --protocol tcp
    cf add-network-policy cache-1 inference --port 50000 --protocol tcp
    cf add-network-policy inference cache-1 --port 50000 --protocol tcp

## Testing

Refer to [here](https://github.com/TIBCOSoftware/be-tools/blob/feature-cloud-foundry/cloud/cloud-foundry/README.md#testing).