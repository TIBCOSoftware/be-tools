## Introduction

This page demonstrates Pivotal Cloud foundry setup and deployment for TIBCO BusinessEvents.

## Prerequisites
* Install Ops Manager on available Iaas platforms referring [Ops Manager](https://docs.pivotal.io/ops-manager/2-10/install/index.html). The following content is verified on Azure Iaas platform, however it would work similarly in all available platforms.
* Install the Small footprint Tanzu Application Service(TAS) following [here](https://docs.pivotal.io/application-service/2-10/operating/configure-pas.html).
* Install the cf CLI v7 from [here](https://docs.pivotal.io/application-service/2-10/cf-cli/install-go-cli.html).
* Docker image of TIBCO BusinessEvents application. See [Building TIBCO BusinessEvents Application Docker Image](https://github.com/TIBCOSoftware/be-tools/wiki/Building-TIBCO-BusinessEvents-Application-Docker-Image). Push the TIBCO BusinessEvents application Docker image to respective cloud Container Registry.

## Setup

1. Login to the cloud foundry using the below command:

   ```sh
   cf login -a API-URL -u USERNAME -p PASSWORD
   ```

   * `API-URL` is your API endpoint, the URL of the Cloud Controller in your TAS for VMs instance.
   * `USERNAME` and `PASSWORD` are the Admin credentials in UAA section from Small footprint TAS tile Credentials tab.
 

2. Target a specific organization and space. 
     
     ```sh
     cf create-org ORG
     cf create-space SPACE
     cf target -o ORG -s SPACE
     ```


3. Enable the diego-docker feature to run docker images. 
   
   ```sh
   cf enable-feature-flag diego_docker
   ```

## Deployment

1. Clone the repo:
     ```sh
     git clone https://github.com/TIBCOSoftware/be-tools.git
     cd be-tools/cloud/cloud-foundry
     ```
     
2. Add required environment variables for your BE image in manifest.yml file in both cache and inference env sections. Ex:For FTL cluster update 
      
      ```sh
       FTL/REALM_SERVER: <REALM_URL>
      ```

3. Use the below command to deploy Business Events application:
    
     * Deploy BE applications without cache using:
     ```sh
     cf push inference -u process
     ```
     * Deploy BE applications with cache using:
     ```sh
      cf push cache -u process
      cf push inference -u process
     ```

4. If your docker image is in a Private repository update Docker username in manifest file. Use below command to deploy app.
   
   ```sh
   CF_DOCKER_PASSWORD=PASSWORD cf push <APP-NAME> -u process
   ```

Note: If your Private repository is AWS ECR refer [here](https://docs.cloudfoundry.org/devguide/deploy-apps/push-docker.html#ecr). Google Container registry refer [here](https://docs.cloudfoundry.org/devguide/deploy-apps/push-docker.html#gcr).

### Service Discovery

For Service Discovery add below network policies with respect to application cluster type.

#### Activespaces cluster with Activespaces cache
```sh
cf add-network-policy cache inference --port 50000 --protocol tcp
cf add-network-policy inference cache --port 50000 --protocol tcp
```

#### FTL and Ignite Cluster with Ignite cache
```sh
cf add-network-policy cache inference --port 47100-47110 --protocol tcp
cf add-network-policy inference cache --port 47100-47110 --protocol tcp
cf add-network-policy cache inference --port 47500-47510 --protocol tcp
cf add-network-policy inference cache --port 47500-47510 --protocol tcp
```

### Examples

* Activespaces application with multiple cache nodes using Backing store. Refer [here](https://github.com/TIBCOSoftware/be-tools/blob/feature-cloud-foundry/cloud/cloud-foundry/examples/as2store.md).
* Ignite application with multiple cache nodes using Activespaces store. Refer [here](https://github.com/TIBCOSoftware/be-tools/blob/feature-cloud-foundry/cloud/cloud-foundry/examples/igniteas4.md).

## Testing

Add Route for the application port:

1. Get the APP_GUID from the below command:
    ```sh
    cf app inference --guid
    ```

2. Add the application port: 
    ```sh
    cf curl /v2/apps/<APP_GUID> -X PUT -d '{"ports": [APP_PORT]}'
    ```

3. Get the ROUTE_GUID from the below command:
    ```sh
    cf curl /v2/apps/<APP_GUID>/routes
    ```

4. Add the required route mapping to the application:
    ```sh
    cf curl /v2/route_mappings -X POST -d '{"app_guid": "<APP_GUID>", "route_guid": "<ROUTE_GUID>", "app_port": <APP_PORT>}'
    ```

5. Verify the Route mappings:
    ```sh
    cf curl /v2/routes/<ROUTE_GUID>/route_mappings
    ```

6. Delete the other unneccesary route mappings:
    ```sh
    cf curl /v2/route_mappings/<ROUTE_MAPPING_ID> -X DELETE
    ```

7. Obtain the route of the deployed cloud foundry application using the below command:
    ```sh
    cf app <APP_NAME>
    ```

8. Test the application by using the route obtained in step 7. For example, if you have deployed the FraudDetectionStore example you can use the readme.html. Update the route in the readme.html file and follow the instructions in it to test the application.

9. Check the application logs using below command:
    ```sh
    cf logs <APP_NAME> --recent
    ```
