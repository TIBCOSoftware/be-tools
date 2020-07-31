# Setting up Google Container Registry

For deploying the TIBCO BusinessEvents application to the Kubernetes cluster, you must push the application Docker image to Google Container Registry.

Alternatively, you can also use VMware Harbor Registry to store and manage application Docker images for your Enterprise PKS deployment. For details, see [Pivotal Docs](https://docs.pivotal.io/pks).

To access Docker images in the Google Container Registry from an environment other than GCP, set up a secret object \(containing the credential information\) for Kubernetes. You can use this secret object in Kubernetes object specification \(YAML\) files for your deployment.

-   See [Preparing for TIBCO BusinessEvents Containerization](Before%20You%20Begin)
-   Docker image of your TIBCO BusinessEvents application. See [Building TIBCO BusinessEvents Application Docker Image](Building%20TIBCO%20BusinessEvents%20Application%20Docker%20Image).
-   Download and install the following CLIs on your system:

    |CLI|Download and Installation Reference|
    |---|-----------------------------------|
    |Kubernetes CLI \(`kubectl`\)|"Installing the Kubernetes CLI" in [Pivotal Docs](https://docs.pivotal.io/pks)|
    |Google Cloud CLI \(`gcloud`\)|[Google Cloud SDK documentation](https://cloud.google.com/sdk/docs/)|


1.  Retrieve the project ID of the default project of your Google Cloud account.

    Sample `gcloud` command:

    ```
    gcloud config list core/project
    ```

2.  To push the TIBCO BusinessEvents application Docker image to the Google Container Registry, first tag it with the registry name and then push it. For details, see the [Google Container Registry documentation](https://cloud.google.com/container-registry/docs/).

    Sample command syntax:

    ```
    docker tag <source-image> <hostname>/<project-id>/<image-name>

    docker push <hostname>/<project-id>/<image-name>
    ```

3.  Set up the Kubernetes secret object for pulling Docker images from Google Container Registry.

    1.  Create a Google cloud service account and store its key in a JSON file. See the [Cloud Identity and Access Management documentation](https://cloud.google.com/iam/docs/).

        Sample `gcloud` commands syntax:

        ```
        gcloud iam service-accounts create <service-account-name>

        gcloud iam service-accounts keys create ~/key.json --iam-account <service-account-name>@<project-id>.iam.gserviceaccount.com

        ```

    2.  Add an IAM policy binding for the defined project and service account. See the [Cloud Identity and Access Management documentation](https://cloud.google.com/iam/docs/).

        Sample `gcloud` commands syntax:

        ```
        gcloud projects add-iam-policy-binding <project-id> --member=serviceAccount:<service-account-name>@<project-id>.iam.gserviceaccount.com --role=<role>
        ```

    3.  Create the Kubernetes secret object by using the JSON file you have just created. See [Kubernetes documentation](https://kubernetes.io/docs).

        Sample `kubectl` commands syntax:

        ```
        kubectl create secret docker-registry <secret-name> --docker-server=<hostname> --docker-username=_json_key --docker-email=<email_id> --docker-password=<password>

        ```

        You can add this secret object in Kubernetes configuration \(YAML\) files of your deployments by using the `ImagePullSecrets` field.

    4.  Add the secret object to the default service account. See [Kubernetes Documentation](https://kubernetes.io/docs).

        ```
        kubectl patch serviceaccount default -p "{\"imagePullSecrets\": [{\"name\": \"<secret-name>\"}]}"

        ```


**Parent topic:**[Running an Application in Enterprise PKS Installed on GCP](Running%20an%20Application%20in%20PKS%20Installed%20on%20GCP)




# Docker container registry
We can use either VMware Harbor registry or Google Container Registry.

## Google Container Registry
First create service account for container registry and create secret for pulling image from kubernetes.

### Create service account and secret
Run following commands with google cloud cli on your system,

* Create a GCP service account; format of account is email address
```
SA_EMAIL=$(gcloud iam service-accounts --format='value(email)' create k8s-gcr-auth-ro)
```
* Create the json key file and associate it with the service account
    ```
    gcloud iam service-accounts keys create k8s-gcr-auth-ro.json --iam-account=$SA_EMAIL
    ```
* Get the project ID
```
     PROJECT=$(gcloud config list core/project --format='value(core.project)')
     gcloud projects add-iam-policy-binding $PROJECT --member serviceAccount:$SA_EMAIL --role roles/storage.objectViewer
     SECRETNAME=<secretname>
```
* Create a secret for pulling docker images

     ```
     kubectl patch serviceaccount default -p "{\"imagePullSecrets\": [{\"name\": \"$SECRETNAME\"}]}" .
     kubectl create secret docker-registry $SECRETNAME --docker-server=https://us.gcr.io --docker-username=_json_key --docker-email=<email_id> --docker-password="$(cat k8s-gcr-auth-ro.jso
    ```   
#### Tag and push the image:
```
docker tag <image> us.gcr.io/<GCP project ID>/<image>
docker push us.gcr.io/<GCP project ID>/<image>
```
* Update yaml files with secret in imagePullSecret field.

## VMWare Harbor Registry
Download the file for the Harbor tile from Pivotal Network and import it in Ops Manager Dashboard. (Refer: https://network.pivotal.io/products/harbor-container-registry/). It will display a VMware Harbor tile in dashboard.

### Setup
* Select harbor tile and assign AZs and Networks by selecting network.
* Enter any hostname which you own to use for harbor host.
* Generate RSA Certificate and domain must match the domain name that you used when you specified the hostname for harbor.
* Set password for harbor admin account.
* Select Internal for authentication mode and local file system for container registry storage.
* Change the resource config page if required.

#### Integrate with PKS
* Download the Root CA Cert from settings section under username.
* Provide the Harbor CA Certificate to OPs Manager by entering contents of CA certificate file into the Trusted Certificates field.

#### Accessing Registry:
* Create load balancer, firewall rules and DNS entry for Harbor VM.
* Add the <harbor_host_address> in docker daemon.
* To log in to VMware Harbor Registry, perform the following steps.
  * In a web browser, navigate to https://<harbor_host_address>:443.
  * Enter the username admin.
  * Enter the password that you set when you configured Harbor for PKS.
* Create user in harbor registry and provide admin or any required privileges to it.
* Tag and Push the image
```
docker login <harbor_host_address> -u <username> -p <password>
docker tag <image> <harbor_host_address>/library/<image>
docker push <harbor_host_address>/library/<image>
```

## Next Steps

* How to deploy TIBCO BusinessEvents application is available [here](deployments)
