## Custom/samlaws
This provider pulls GVs from a AWS Secrets Manager service where federated access to AWS is enabled using Windows Active Directory, ADFS and SAML 2.0

Note: This provider implementation is based on [AWS reference - general solution for federated apicli access using SAML 2.0](https://aws.amazon.com/blogs/security/how-to-implement-a-general-solution-for-federated-apicli-access-using-saml-2-0/). This requires adaption before real use as per your Identity Providers (IdPs) requirements.

### Build
To select this provider type, pass `samlaws` to --gv-provider flag while building the BE application image.

Sample:
```sh
./build_image.sh \
-i app \
-s /home/user/tibco/installers \
--gv-provider samlaws \
-t fd:latest
```

### Run
Following environment variables are applicable for this GV provider type:
* SAML_IDP_URL - IdP-initiated login URL (i.e. URL using for SSO access to the AWS Management Console)
* SAML_USERNAME - User name
* SAML_PASSWORD - Password
* AWS_SM_SECRET_ID - AWS Secter ID
* AWS_DEFAULT_REGION - AWS region

### Examples

#### github

Sample run:
```sh
docker run \
  -e AWS_SM_SECRET_ID=<AWS SECRETS MANAGER - SECRET ID> \
  -e AWS_DEFAULT_REGION=<REGION> \
  -e SAML_IDP_URL=<IdP login URL> \
  -e SAML_USERNAME=<user name> \
  -e SAML_PASSWORD=<password> \
  fd:latest
```
