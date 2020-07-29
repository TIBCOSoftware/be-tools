
You can set up BusinessEvents multihost clustering on Amazon Elastic Compute Cloud \(Amazon EC2\) instances using Docker and Weave Net.

### Prerequisites

-   An Amazon Web Services \(AWS\) account. Refer to the Amazon EC2 documentation at [https://aws.amazon.com/documentation/ec2/](https://aws.amazon.com/documentation/ec2/) to learn Amazon EC2 concepts and how to use the Amazon EC2 console.
-   TIBCO BusinessEvents application image. See [Dockerize TIBCO BusinessEvents](Dockerize%20TIBCO%20BusinessEvents) for more details on running TIBCO BusinessEvents on Docker.
-   \(Optional\) Docker Hub registry account or any other Docker registry account. Refer to the [https://docs.docker.com/](https://docs.docker.com/) to learn more about Docker.
-   Weave Net for multihost docker networking. Refer to the Weave Net documentation at [https://www.weave.works/docs/net/latest/features/](https://www.weave.works/docs/net/latest/features/) to learn on how to use Weave Net and how to integrate with Docker.
-   Amazon Elastic File System configuration \(EFS\) for shared-nothing persistence. Refer to the Amazon EFS documentation at [https://aws.amazon.com/documentation/efs/](https://aws.amazon.com/documentation/efs/) to learn about Amazon EFS concepts and configurations.
-   Relational Database Service configuration \(RDS\) for shared all persistence. Refer to the Amazon RDS documentation at [https://aws.amazon.com/documentation/rds/](https://aws.amazon.com/documentation/rds/) to learn about Amazon RDS concepts and configurations.

### Procedure

1.  [Setting Up Standalone Amazon EC2 Instances](Setting%20Up%20Standalone%20Amazon%20EC2%20Instances)  
     For BusinessEvents multihost clustering, you must create Amazon Elastic Cloud Compute \(Amazon EC2\) instances and configure Docker and Weave Net on each of them. This setup is common for shared all and shared-nothing persistence options.
2.  [Configuring Amazon RDS for Shared All Persistence](Configuring%20Amazon%20RDS%20for%20Shared%20All%20Persistence)  

3.  [Configuring Amazon EFS for Shared Nothing Persistence](Configuring%20Amazon%20EFS%20for%20Shared%20Nothing%20Persistence)  


**Parent topic:** [Dockerize TIBCO BusinessEvents](Dockerize%20TIBCO%20BusinessEvents)

