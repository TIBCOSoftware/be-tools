For BusinessEvents multihost clustering, you must create Amazon Elastic Cloud Compute \(Amazon EC2\) instances and configure Docker and Weave Net on each of them. This setup is common for shared all and shared-nothing persistence options.
### Procedure
1. Log in to Amazon EC2 console with your credentials.

   Refer to Amazon EC2 documentation at [https://aws.amazon.com/documentation/ec2/](https://aws.amazon.com/documentation/ec2/) for more details on setting Amazon EC2 account.

2. In the Amazon EC2 console, create a new security group with the following inbound rules.

   | Rule No. | Type            | Protocol | Port                                       | Source   |
   | -------- | --------------- | -------- | ------------------------------------------ | -------- |
   | 1        | SSH             | TCP      | 22                                         | Anywhere |
   | 2        | Custom TCP Rule | TCP      | 6783                                       | Anywhere |
   | 3        | Custom UDP Rule | UDP      | 6783                                       | Anywhere |
   | 4        | Custom TCP Rule | TCP      | <HTTP Port as per BusinessEvents project> | Anywhere |

   **Note:** Port TCP/UDP 6783 is required for weave networking. You can configure source according to your requirement.

   Refer to Amazon EC2 documentation at [http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/get-set-up-for-amazon-ec2.html](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/get-set-up-for-amazon-ec2.html) for details on how to create security group.

3. On the Amazon EC2 console, create two or more Standalone Amazon EC2 instances of type Ubuntu or CentOS or as per your requirement. Specify the configuration parameters according to your requirement in the wizard.

   -   Select the default Virtual Private Cloud \(VPC\) for testing purpose or you can use an customized one.
   -   Select the security group created earlier in Step 2.
   -   Generate a new key pair \(`.pem`\) per instance and save it.
       Refer to the Amazon EC2 documentation at [http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/LaunchingAndUsingInstances.html](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/LaunchingAndUsingInstances.html) for more details on launching an instance.

4. In the Amazon EC2 console, on **Review Instance Launch** page, check the details of your instance, and after the verification click **Launch**.

5. Ensure that all instances are in the "running" state and status checks are marked with no error.

6. Note down the public and private IP address/DNS of all instances, which can be later used for connection.

7. Change the permission of PEM key.

   ```
   > chmod 400 mykey.pem
   ```

8. Securely log in to Amazon EC2 instances using an SSH client.

   ```
   > ssh -i /pathto/mykey.pem ec2-user@<public IP address of EC2 instance or public DNS>
   ```

   **Note:** User name could be `ec2-user` or `ubuntu` as per the Amazon EC2 instance type.

9. Install Docker on all Amazon EC2 instances.

   Refer to the installation instructions mentioned in the Docker Documentation at [https://docs.docker.com/engine/installation/](https://docs.docker.com/engine/installation/).

10. Install Weave Net all EC2 instances.

    ```
    > sudo curl -L git.io/weave -o /usr/local/bin/weave
    > sudo chmod a+x /usr/local/bin/weave
    ```

    Refer to the installation instructions in the Weave Net documentation at [https://www.weave.works/docs/net/latest/installing-weave/](https://www.weave.works/docs/net/latest/installing-weave/).

11. Start weave on each instance, and provide it other peers private IP addresses.

    On Instance 1,

    ```
    > weave launch
    ```

    On Instance 2,

    ```
    > weave launch <HostName/Private IP address of Instance 1>
    ```

12. Run the following command and check status of the peers connection.

    ```
    > weave status
    ```

    If the connection is successful, the status displays the number of established connections. For example,

    ```
    Peers: 2 (with 2 established connections)
    ```


**Parent topic:** [Setting Up BusinessEvents Multihost Clustering on Amazon EC2 Instances Using Docker](Setting%20up%20BusinessEvents%20Multihost%20Clustering%20on%20Amazon%20EC2%20Instances%20Using%20Docker)

**Next topic:** [Configuring Amazon RDS for Shared All Persistence](Configuring%20Amazon%20RDS%20for%20Shared%20All%20Persistence)

