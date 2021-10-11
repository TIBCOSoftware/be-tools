<!-- Running BE on AWS Fargate/EC2 using ECS -->
Setup AWS ECS Fargate/EC2 Cluster using below steps

## Pre-requisites

* Docker image of TIBCO Business Events. For regsitry [setup](Setting-Up-an-AWS-Container-Registry)
* AWS Fargate/EC2 requires IAM role for your task definition.
* Create [IAM role and policy](https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-iam-roles.html)
* AWS ECS Fargate/EC2 cluster setup


### Key points for Shared nothing persistence application

* Create EFS referring [here](https://docs.aws.amazon.com/efs/latest/ug/gs-step-two-create-efs-resources.html). Choose VPC which was created while creating Fargate Cluster.
* Create Access Points in EFS with User ID and Group ID as 1000, Directory as /mnt/tibco/be/data-store. Provide all permissions to this User ID and Group ID.
* Create Volume definition in task definition. Select Volume type as EFS and add EFS details as created above.
* Attach volume to container part via source volume.
* Fargate creates new data file in mount path whenever we start new task. But, we need common file name so that data is persisted. So, we need to add following property, which goes in our be-engine.tra file.

       be.engine.cluster.as.hostaware.hostname = <data_filename>

  Or you can pass the same from the environment variables as:

       tra.be.engine.cluster.as.hostaware.hostname = <data_filename>


## Task Definition

* Select launch type compatibility as Fargate/EC2/External
* Create seperate task definitions for inference and cache agents

* Add Environment variables as required for BE APP/RMS based on the topology, here are few example env's
    * For AS2 use : AS_DISCOVER_URL=tcp://<cache/discovery-servicename>.local:50000. 
    * For ignite: IGNITE_DISCOVER_URL=<cache/discovery-servicename>.local 
    * For FTL: FTL/REALM_SERVER=http://<FTL_SERVER_IP>:<FTL_PORT>
   


| Task Definition | BE APP | RMS | TEAagent |
| ------------- | :---: | :---: | :---: |
| Name | BE-inference/cache | BERMS | BETEA |
| Network Type | AWSVPC | AWSVPC | AWSVPC |
| Memory | 2Gi | 2Gi | 2Gi |
| CPU | 1vCPU | 1vCPU | 1vCPU |
| Volumes | name=datastore<br> EFS AP ID<br>Enable transit encryption |  name=rms-shared<br>EFS AP ID<br> Enable transit encryption | - |
| ContainerName| inference/cache | rms | teagent |
| Environment Variables | PU=default/cache<br> JMX_PORT=5566<br> <Add_required_env_variables>| PU=default<br><Add_required_env_variables> | BE_TEA_AGENT_AUTO_REGISTER_ENABLE=true<br> TEA_SERVER_PASSWORD=admin<br> TEA_SERVER_URL=<TEA_SERVER_URL><br> TEA_SERVER_USERNAME=admin<br><Add_required_env_variables> |
| Mount points | datastore:/mnt/tibco/be/data-store<br>logs:/mnt/tibco/be/logs<br>shared:/opt/tibco/be/<be_version>/rms/shared<br>(applicable for RMS) |  shared:/opt/tibco/be/<be_version>/rms/shared<br>security:/opt/tibco/be/<be_version>/rms/config/security<br>webstudio:/opt/tibco/be/<be_version>/examples/standard/WebStudio | - |



**Note**:
* For rms mount points update the <be_verison> to respective version

## Create/Update Service    

| Service | BE APP | RMS | TEAagent |
| ------------- | :---: | :---: | :---: |
| Launch type | FARGATE/EC2 | FARGATE/EC2 | FARGATE/EC2
| Service Name | inference/discoveryservice | rms-service | teagent-service |
| Replicas | 2 | 1 | 1 |
| Auto-assign public IP | Enabled | Enabled | Enabled |
| LoadBalancer | inference loadbalancer | - | - |
| Service discovery | discoveryservice<br> inference_jmx_service(applicable for RMS) | - | -|

#### Service Discovery
* Service discovery in Fargate creates record set in Route 53.
* Make sure that VPC, which is created while cluster creation is associated with hosted zones. Default hosted zone is local.
* Service discovery endpoint is configured as per service name in Fargate.
* Docker environment variable, AS_DISCOVER_URL should be passed as per the name of the service, created for cache agent. For example, if name of the service is discoveryservice, then AS_DISCOVER_URL should be passed as tcp://discoveryservice.local:50000


**Note** :
* While creating the BE Inference Service, select the application load balancer.Create Load Balancer and target groups [from here](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/create-application-load-balancer.html)

* Modify the Inbound and outbound rules of security groups accordingly.

### Access the application

* For Accessing the application and testing, please refer [here](Testing.md)        