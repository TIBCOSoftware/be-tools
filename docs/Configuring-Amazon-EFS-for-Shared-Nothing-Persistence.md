### Procedure
1.  Create an Amazon Elastic File System \(EFS\) with the same Virtual Private Cloud \(VPC\) and security group as of the Amazon EC2 instances.

    Refer to the Amazon EFS documentation at [http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AmazonEFS.html](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AmazonEFS.html) for detailed steps on how to create an Amazon EFS file system.

2.  Note down DNS name which is required while mounting EFS on Amazon EC2 instances.

3.  Open an SSH client and connect to your Amazon EC2 instance.

4.  Install the NFS client on all Amazon EC2 instances.

    On an Amazon Linux, Red Hat Enterprise Linux, or SUSE Linux instance, run the following command:

    ```
    > sudo yum install -y nfs-utils
    ```

    On an Ubuntu instance, run the following command:

    ```
    > sudo apt-get install nfs-common
    ```

5.  Create a new directory on all Amazon EC2 instances, such as "efs".

    ```
    >  sudo mkdir efs
    ```

6.  Mount your file system by using the EFS DNS name.

    ```
    > sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2 fs-cb8b5e62.efs.us-west-2.amazonaws.com:/ efs
    ```

    If the connection was not successful, refer to Amazon EFS troubleshooting documentation at [http://docs.aws.amazon.com/efs/latest/ug/troubleshooting.html](http://docs.aws.amazon.com/efs/latest/ug/troubleshooting.html).

7.  Run the following command to see the mount:

    ```
    > df -T
    ```

8.  Update BusinessEvents application CDD with shared nothing datastore path as `/mnt/tibco/be/data-store`, which is declared as `VOLUME` in BusinessEvents base dockerfile.

9.  Create BusinessEvents application docker image locally on any machine and push it to docker registry.

    See [Containerizing TIBCO BusinessEvents Application in Docker](Containerizing%20TIBCO%20BusinessEvents%20Application%20in%20Docker) for more details on how to do it.

10. Pull this BusinessEvents application docker image on all Amazon EC2 instances.

    Once the BusinessEvents application image is available on all EC2 instances, you can run BusinessEvents application containers.

11. Set the Weave environment on all Amazon EC2 instances for running BusinessEvents application containers.

    ```
    >  eval $(weave env)
    ```

12. Start containers on all Amazon EC2 instances.

    For example,

    ```
    //Start cache 1 on instance 1
    docker run -d --name=cache1SN -v /home/ubuntu/efs:/mnt/tibco/be/data-store -e PU=cache <username>/fdstore_sharednothing:GA
    //Start cache 2 on instance 2
    docker run -d --name=cache2SN -v /home/ubuntu/efs:/mnt/tibco/be/data-store -e PU=cache -e AS_DISCOVER_URL=tcp://cache1SN:50000 <username>/fdstore_sharednothing:GA
    //Start inference on instance 2
    docker run -d --name=InfSN -v /home/ubuntu/efs:/mnt/tibco/be/data-store -p 8209:8209 -e PU=default -e AS_DISCOVER_URL=tcp://cache1SN:50000 <username>/fdstore_sharednothing:GA
    ```

    Ensure that all BusinessEvents application containers are connected to each other and inference is processing events at port 8209.

13. For sending events using readme.html of the example application, replace `localhost` with the public IP address of instance where the inference container is running.

    As long as EFS is in running state, data is persisted.

14. To check the data recovery, stop all Amazon EC2 instances and start them again. Mount the EFS target again as mentioned in Step 6.

15. Restart all stopped containers and check that the data is recovered in cache containers.


**Parent topic:** [Setting Up BusinessEvents Multihost Clustering on Amazon EC2 Instances Using Docker](Setting%20up%20BusinessEvents%20Multihost%20Clustering%20on%20Amazon%20EC2%20Instances%20Using%20Docker)

**Previous topic:** [Configuring Amazon RDS for Shared All Persistence](Configuring%20Amazon%20RDS%20for%20Shared%20All%20Persistence)

