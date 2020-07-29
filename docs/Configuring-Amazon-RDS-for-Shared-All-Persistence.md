
**Note:** In this approach BusinessEvents application image is built locally and the docker registry is used to push or pull images. You can also build images directly on Amazon EC2 instances. If required, you can also configure separate VPC and security group.
### Prerequisites
Check Amazon Relational Database Service \(RDS\) prerequisites at [http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_SettingUp.html](http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_SettingUp.html).
### Procedure
1. Create an Amazon RDS of type Oracle.

   Refer to the Amazon RDS documentation at [http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_GettingStarted.CreatingConnecting.Oracle.html](http://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/CHAP_GettingStarted.CreatingConnecting.Oracle.html) for more details on how to do it.

2. Use default VPC, same used for Amazon EC2 instances. Also, in the same security group add one more inbound rule for database port.

   | Type            | Protocol | Port | Source   |
   | --------------- | -------- | ---- | -------- |
   | Custom TCP Rule | TCP      | 1501 | Anywhere |

   Or if required, you can create a separate security group for the database instance

3. After the database instance is running and is in "available" state, you can establish a connection to it using any SQL client.

4. Create a BusinessEvents specific user and run all BusinessEvents specific scripts that are required.

5. After the database setup is ready, use the same database setup in the JDBC shared resource. You can use the database instance endpoint as **Database URL** in the JDBC shared resource. Use the **Test Connection** feature to check if the connection is successful.

6. Create BusinessEvents application docker image locally on any machine and push it to the Docker registry.

   See [Containerizing TIBCO BusinessEvents Application in Docker](Containerizing%20TIBCO%20BusinessEvents%20Application%20in%20Docker) for more details on how to do it.

7. Pull this BusinessEvents application docker image on all Amazon EC2 instances.

   After the BusinessEvents application image is available on all EC2 instances, you can run BusinessEvents application containers.

8. Set the Weave environment on all Amazon EC2 instances for running BusinessEvents application containers.

   ```
   >  eval $(weave env)
   ```

9. Start containers on all Amazon EC2 instances.

   For example,

   ```
   //Start cache 1 on instance 1
   docker run -d --name=cache1SA -e PU=cache <username>/fdstore_sharedall:GA
   //Start cache 2 on instance 2
   docker run -d --name=cache2SA -e PU=cache -e AS_DISCOVER_URL=tcp://cache1SA:50000 <username>/fdstore_sharedall:GA
   //Start inference on instance 2
   docker run -d --name=InfSA -p 8209:8209 -e PU=default -e AS_DISCOVER_URL=tcp://cache1SA:50000 <username>/fdstore_sharedall:GA
   ```

   Ensure that all BusinessEvents application containers are connected to each other and inference is processing events at port 8209.

10. For sending events using readme.html of the example application, replace `localhost` with the public IP address of instance where the inference container is running.

    As long as the RDS database instance is in running state, data is persisted.

11. To check the data recovery, stop all Amazon EC2 instances and start them again.

12. Restart all stopped containers and check that the data is recovered in cache containers.


**Parent topic:** [Setting Up BusinessEvents Multihost Clustering on Amazon EC2 Instances Using Docker](Setting%20up%20BusinessEvents%20Multihost%20Clustering%20on%20Amazon%20EC2%20Instances%20Using%20Docker)

**Previous topic:** [Setting Up Standalone Amazon EC2 Instances](Setting%20Up%20Standalone%20Amazon%20EC2%20Instances)

**Next topic:** [Configuring Amazon EFS for Shared Nothing Persistence](Configuring%20Amazon%20EFS%20for%20Shared%20Nothing%20Persistence)

