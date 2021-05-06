# Cloud Foundry

This demonstrates how to run the Business Events applications in Cloud foundry.

## Prerequisites
* Install Ops Manager on available Iaas platforms referring Ops Manager [https://docs.pivotal.io/ops-manager/2-10/install/index.html].
* Install the Small footprint Tanzu Application Service(TAS) using here[https://docs.pivotal.io/application-service/2-10/operating/configure-pas.html].
* Install the cf cli[https://docs.pivotal.io/application-service/2-10/cf-cli/install-go-cli.html].

## Cf setup

1)Login to the cloud foundry using the below command:

     cf login -a API-URL -u USERNAME -p PASSWORD

       -API-URL is your API endpoint, the URL of the Cloud Controller in your TAS for VMs instance.
       -USERNAME and PASSWORD are the Admin credentials in UAA section from Small footprint TAS tile Credentials tab.

2)Target a specific organization and space. 
     
     cf target -o ORG -s SPACE

       -ORG is the org you want to target.
       -SPACE is the space you want to target.

Note: Required organizations and spaces can be created using the cf commands

3)Enable the diego-docker feature to run docker images. 
     
     cf enable-feature-flag diego_docker

## Deploying BE application

     git clone https://github.com/TIBCOSoftware/be-tools.git
     cd be-tools/cloud/cloud-foundry/manifests
     cf7 push <APP_NAME> -f <Manifest_file>

Use the respective manifest file:

| Topology Name | Manifest File |
| ------------- | :---: |
| Inmemory | inmemory.yml |
| Unclustered store AS4 |  |
| Unclustered store Cassandra | unclustercassandra.yml |
| AS2 Clustered Cache Persistence None | as2pnone.yml |
| AS2 Clustered Cache Shared Nothing | as2snone.yml |
| AS2 Clustered Cache Store RDBMS| as2mysql.yml |
| FTL Clustered Store AS4 |  |
| FTL Clustered Store Cassandra | ftlcassandra.yml |
| FTL Clustered Cache Persistence None | ftlpnone.yml |
| FTL Clustered Cache Shared Nothing | ftlsnone.yml |
| FTL Clustered Cache Store RDBMS | ftlmysql.yml |
| FTL Clustered Cache Store AS4 |  |
| FTL Clustered Cache Store Cassandra | ftlcachecassandra.yml |
| IGNITE Clustered Cache Persistence None | igntpnone.yml |
| IGNITE Clustered Cache Shared Nothing | igntsnone.yml |
| IGNITE Clustered Cache Store RDBMS | igntmysql.yml |
| IGNITE Clustered Cache Store AS4 |  |
| IGNITE Clustered Cache Store Cassandra | igntcassandra.yml |


## Service Discovery

For Service Discovery add below network policies with respect to application cluster type.

### Activespaces cluster with Activespaces cache

     cf add-network-policy <CACHE_APP_NAME> <INFERENCE_APP_NAME> --port 50000 --protocol tcp
     cf add-network-policy <INFERENCE_APP_NAME> <CACHE_APP_NAME> --port 50000 --protocol tcp

### FTL and Ignite Cluster with Ignite cache

     cf add-network-policy <CACHE_APP_NAME> <INFERENCE_APP_NAME> --port 47100-47110 --protocol tcp
     cf add-network-policy <INFERENCE_APP_NAME> <CACHE_APP_NAME> --port 47100-47110 --protocol tcp
     cf add-network-policy <CACHE_APP_NAME> <INFERENCE_APP_NAME> --port 47500-47510 --protocol tcp
     cf add-network-policy <INFERENCE_APP_NAME> <CACHE_APP_NAME> --port 47500-47510 --protocol tcp

## Testing the BE application

Add Route for the application port:

1)Get the APP_GUID from the below command:
    
    cf app <APP_NAME> --guid

2)Add the application port: 
    
    cf curl /v2/apps/<APP_GUID> -X PUT -d '{"ports": [APP_PORT]}'

3)Get the ROUTE_GUID from the below command:
    
    cf curl /v2/apps/<APP_GUID>/routes

4)Add the required route mapping to the application:
    
    cf curl /v2/route_mappings -X POST -d '{"app_guid": "<APP_GUID>", "route_guid": "<ROUTE_GUID>", "app_port": <APP_PORT>}'

5)Verify the Route mappings:
    
    cf curl /v2/routes/<ROUTE_GUID>/route_mappings

6)Delete the other unneccesary route mappings:
    
    cf curl /v2/route_mappings/<ROUTE_MAPPING_ID> -X DELETE

Hit the BE application with the route of the deployed cloud foundry application obtained using the below command:
     
    cf app <APP_NAME>
