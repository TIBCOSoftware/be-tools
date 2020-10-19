# GV Configuration Framework

This framework allows customers to configure and pull GV values from various end-stores (also referred as GV provider in this document) when running the BE application in container mode. Framework supports following types of GV providers:

1. HTTP - Use this type when end-store has an http based API to access it. Example: AWS S3, Azure Blob, github, etc...
2. Consul - Use this type when end-store is Consul
3. Custom - Use this type to provide custom implementation to pull GV values from an end-store of user choice

While building the BE application image, use `--gv-provider` flag to select GV provider type - `http`, `consul` OR `custom name`. More details are available in their respective sections below.

## HTTP

### Build
To select this provider type, pass `http` to --gv-provider flag while building the BE application image.

Sample:
```sh
./build_image.sh \
-i app \
-s /home/user/tibco/installers \
--gv-provider http \
-t fdhttp:latest
```

### Run
Following environment variables are applicable for this GV provider type:
* GVP_HTTP_SERVER_URL - end-store URL
* GVP_HTTP_HEADERS - Header values to access the end-store API

### Examples

#### github

Sample run:
```sh
docker run \
-e GVP_HTTP_SERVER_URL="<SERVER_URL>" \
-e GVP_HTTP_HEADERS="Authorization:token 9222c5cf6e380ba1395e9d8acce8764265f85933,Content-Type:application/json" \
-p 8108:8108 --name=fdhttpgit fdhttp:latest
```

#### azure storage

Sample run:
```sh
docker run \
-e GVP_HTTP_SERVER_URL="<SERVER_URL>" \
-e GVP_HTTP_HEADERS="x-ms-date: $(date -u)" \
-p 8108:8108 --name=fdhttpazure fdhttp:latest
```

## Consul

### Build
To select this provider type, pass `consul` to --gv-provider flag while building the BE application image.
Sample:
```sh
./build_image.sh \
-i app \
-s /home/user/tibco/installers \
--gv-provider consul \
-t fdconsul:latest
```

### Run
Following environment variables are applicable for this GV provider type:
* CONSUL_SERVER_URL - Consul URL
* BE_APP_NAME - App name created in the Consul
* APP_CONFIG_PROFILE - Profile created in the Consul

Sample run:
```sh
docker run \
-e CONSUL_SERVER_URL=<SERVER_URL> \
-e BE_APP_NAME=FraudDetection \
-e APP_CONFIG_PROFILE=default \
-p 8108:8108 --name=fdconsul fdconsul:latest
```

## Custom

### Implementation
To add a custom GV provider, create a new folder under `be-tools/cloud/docker/gvproviders/custom/` and name it as per your choice - lets say `CUSTOM_PROVIDER`. Provide implementation as per below instructions:

1. Add `be-tools/cloud/docker/gvproviders/custom/CUSTOM_PROVIDER/setup.sh` (setup.bat for windows). This gets invoked by the framework during BE application docker build. Provide logic to download required packages & setup environment needed for the config provider.
2. Add `be-tools/cloud/docker/gvproviders/custom/CUSTOM_PROVIDER/run.sh` (run.bat for windows). This gets invoked by the framework during run time. Provide logic to pull GV values from the end-store, parse and write them into the JSON file at `/home/tibco/be/gvproviders/output.json`

Sample `output.json` for reference:
```json
{
    "KEY1": "VALUE1",
    "KEY2": "VALUE2"
}
```

### Build
To select this provider type, pass `CUSTOM_PROVIDER` to --gv-provider flag while building the BE application image.
Sample:
```sh
./build_image.sh \
-i app \
-s /home/user/tibco/installers \
--gv-provider CUSTOM_PROVIDER \
-t fdcustom:latest
```

### Example - custom/aws
There is a custom GV provider `aws` added a reference example. This GV provider uses [AWS Secrets Manager](https://aws.amazon.com/secrets-manager/getting-started/) as an end-store, however it can easily updated to use other AWS end-stores options like `s3`.

Refer to following files at `be-tools/cloud/docker/gvproviders/custom/aws` for the implementation logic:
```sh
setup.sh -> Installs aws cli & other tools
run.sh -> Configure aws cli, pull secrets from AWS Secrets Manager
```

#### Build

Sample command to build BE app image which uses `aws` GV provider:
```sh
./build_image.sh \
-i app \
-s /home/user/tibco/installers \
--gv-provider aws \
-t fdcustom:latest
```

#### Run

```sh
docker run \
-e AWS_ACCESS_KEY_ID=<AWS ACCESS ID> \
-e AWS_SECRET_ACCESS_KEY=<AWS SECRET> \
-e AWS_DEFAULT_REGION=<REGION> \
-e AWS_ROLE_ARN=<ASSUMED ROLE> \
-e AWS_SM_SECRET_ID=<AWS SECRETS MANAGER - SECRET ID> \
-p 8108:8108 --name=fdcustom fdcustom:latest
```
