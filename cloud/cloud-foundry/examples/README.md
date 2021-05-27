## Introduction

This page describes deployment steps for BE Application with multiple cache nodes in Cloud foundry.

## Deployment

1. Clone the repo:
     ```sh
     git clone https://github.com/TIBCOSoftware/be-tools.git
     cd be-tools/cloud/cloud-foundry/examples
     ```

2. The deployment uses manifest.yml file by default. Update the below mentioned details in the manifest.yml file.
    
    * Update required environment variables for your BE image in manifest.yml file in both cache and inference env sections. Ex:For FTL cluster update  
      
      ```sh
       FTL/REALM_SERVER: <REALM_URL>
      ```
    * Update BE Docker image. If your docker image is in a Private repository update Docker username. While pushing the application append CF_DOCKER_PASSWORD=PASSWORD to the cf push command (in Step 3) as below:
   
      ```sh
       CF_DOCKER_PASSWORD=PASSWORD cf push <APP-NAME> -u process
      ```
    Note: If your Private repository is AWS ECR refer [here](https://docs.cloudfoundry.org/devguide/deploy-apps/push-docker.html#ecr). Google Container registry refer [here](https://docs.cloudfoundry.org/devguide/deploy-apps/push-docker.html#gcr).

3. Use the below command to deploy Business Events application:
    
      ```sh
      cf push cache-0 -u process -f <Application-manifest.yml>
      cf push cache-1 -u process -f <Application-manifest.yml>
      cf push inference -u process -f <Application-manifest.yml>
      ```

4. Service Discovery 

    Network policies for Activespaces cluster with activespaces cache:

      ```sh
      cf add-network-policy cache-0 cache-1 --port 50000 --protocol tcp
      cf add-network-policy cache-1 cache-0 --port 50000 --protocol tcp
      cf add-network-policy cache-0 inference --port 50000 --protocol tcp
      cf add-network-policy inference cache-0 --port 50000 --protocol tcp
      cf add-network-policy cache-1 inference --port 50000 --protocol tcp
      cf add-network-policy inference cache-1 --port 50000 --protocol tcp
      ```
   Network policies for Ignite cluster with Ignite cache:
      ```sh
      cf add-network-policy cache-0 cache-1 --port 47100-47510 --protocol tcp
      cf add-network-policy cache-1 cache-0 --port 47100-47510 --protocol tcp
      cf add-network-policy cache-0 inference --port 47100-47510 --protocol tcp
      cf add-network-policy inference cache-0 --port 47100-47510 --protocol tcp
      cf add-network-policy cache-1 inference --port 47100-47510 --protocol tcp
      cf add-network-policy inference cache-1 --port 47100-47510 --protocol tcp
      ```

## Testing

Test the deployed application using the steps mentioned [here](https://github.com/nareshkumarthota/rootrepo/wiki/Cloud-Foundry#testing).
