## Introduction

This page describes deployment steps for Ignite cluster cache Activespaces store Application with multiple cache nodes in Pivotal Cloud foundry.

## Deployment

1. Clone the repo:
     ```sh
     git clone https://github.com/TIBCOSoftware/be-tools.git
     cd be-tools/cloud/cloud-foundry/examples
     ```
     
2. Update environment variables for your BE image in igniteas4.yml file in both cache and inference env sections.

3. Use the below command to deploy Business Events application:

      ```sh
      cf push cache-0 -u process
      cf push cache-1 -u process
      cf push inference -u process
      ```

4. If your docker image is in a Private repository update Docker username in manifest file.Also add 'CF_DOCKER_PASSWORD=PASSWORD' environment variable in above commands.

    ```sh 
    CF_DOCKER_PASSWORD=PASSWORD cf push <APP-NAME> -u process
    ```

    Note: If your Private repository is AWS ECR refer [here](https://docs.cloudfoundry.org/devguide/deploy-apps/push-docker.html#ecr). Google Container registry refer [here](https://docs.cloudfoundry.org/devguide/deploy-apps/push-docker.html#gcr).

### Service Discovery

For Ignite Service Discovery add network policies using the Ignite communication and listen ports as below.

```sh
cf add-network-policy cache-0 cache-1 --port 47100-47510 --protocol tcp
cf add-network-policy cache-1 cache-0 --port 47100-47510 --protocol tcp
cf add-network-policy cache-0 inference --port 47100-47510 --protocol tcp
cf add-network-policy inference cache-0 --port 47100-47510 --protocol tcp
cf add-network-policy cache-1 inference --port 47100-47510 --protocol tcp
cf add-network-policy inference cache-1 --port 47100-47510 --protocol tcp
```

## Testing

Refer to [here](https://github.com/TIBCOSoftware/be-tools/blob/feature-cloud-foundry/cloud/cloud-foundry/README.md#testing).