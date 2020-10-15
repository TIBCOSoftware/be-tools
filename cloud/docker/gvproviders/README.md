# GV Configuration Framework

This framework allows customers to configure and pull GV values from various end-stores (also referred as GV provider in this document) when running the BE application in container mode. Framework supports following types of GV providers:

1. HTTP - Use this type when end-store has an http based API to access it. Example: AWS S3, Azure Blob, github, etc...
2. Consul - Use this type when end-store is Consul
3. Custom - Use this type to provide custom implemetation to pull GV values from an end-store of user choice

While building the BE application image, use `--gv-providers` flag to select GV provider type - `http`, `consul` OR `custom`. More details are available in their respective sections below.

## HTTP

### Build
To select this provider type, pass `http` to --gv-providers flag while building the BE application image.

Sample:
```sh
./build_app_image.sh \
-l /home/user/tibco/installers \
-a /home/user/tibco/be/5.6/examples/standard/FraudDetection \
-r fdhttp:latest \
--gv-providers "http"
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
To select this provider type, pass `consul` to --gv-providers flag while building the BE application image.
Sample:
```sh
./build_app_image.sh \
-l /home/user/tibco/installers \
-a /home/user/tibco/be/5.6/examples/standard/FraudDetection \
-r fdconsul:latest \
--gv-providers "consul"
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
Provide custom implementation to the following files:
* be-tools/cloud/docker/gvproviders/custom/setup.sh - This gets invoked by the framework during docker build. Provide logic to setup required packages & environment in the docker image which gets used by run.sh during run time.
* be-tools/cloud/docker/gvproviders/custom/setup.bat - Windows version of setup.sh
* be-tools/cloud/docker/gvproviders/custom/run.sh - This gets invoked by the framework during run time. Provide logic to pull GV values from an end-store.
* be-tools/cloud/docker/gvproviders/custom/run.bat - Windows version of run.sh

### Build
To select this provider type, pass `custom` to --gv-providers flag while building the BE application image.
Sample:
```sh
./build_app_image.sh \
-l /home/user/tibco/installers \
-a /home/user/tibco/be/5.6/examples/standard/FraudDetection \
-r fdcustom:latest \
--gv-providers "custom"
```

### Example
This example shows how to provide custom implementation to pull GV values from `AWS Secrets Manager`.
* Step 1: Create a secret store on AWS Secrets Manager console and add few secrets (key value pairs). Refer [Getting Started with AWS Secrets Manager](https://aws.amazon.com/secrets-manager/getting-started/)

* Step 2: Update setup.sh & run.sh files as mentioned below:

be-tools/cloud/docker/gvproviders/custom/setup.sh:
```sh
# install aws cli
apt-get install -y curl unzip less groff

cd /home/tibco/be/gvproviders/custom
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
./aws/install
aws --version

# clean up
rm -f awscliv2.zip
rm -rf aws
apt-get remove -y curl unzip
```

be-tools/cloud/docker/gvproviders/custom/run.sh:
```sh
if [[ -z "$AWS_ACCESS_KEY_ID" ]]; then
  echo "ERROR: Cannot read GVs from AWS Secrets Manager.."
  echo "ERROR: Specify env variable AWS_ACCESS_KEY_ID"
  exit 1;
fi

if [[ -z "$AWS_SECRET_ACCESS_KEY" ]]; then
  echo "ERROR: Cannot read GVs from AWS Secrets Manager.."
  echo "ERROR: Specify env variable AWS_SECRET_ACCESS_KEY"
  exit 1;
fi

if [[ -z "$AWS_DEFAULT_REGION" ]]; then
  echo "ERROR: Cannot read GVs from AWS Secrets Manager.."
  echo "ERROR: Specify env variable AWS_DEFAULT_REGION"
  exit 1;
fi

if [[ -z "$AWS_SM_SECRET_ID" ]]; then
  echo "ERROR: Cannot read GVs from AWS Secrets Manager.."
  echo "ERROR: Specify env variable AWS_SM_SECRET_ID"
  exit 1;
fi

echo "INFO: Reading GV values from AWS Secrets Manager.."

BE_PROPS_FILE=/home/tibco/be/beprops_all.props
touch /home/tibco/be/gvproviders/output.json
JSON_FILE=/home/tibco/be/gvproviders/output.json

# configure aws cli
PROFILE_NAME="beuser"
printf "%s\n%s\n%s\njson" "$AWS_ACCESS_KEY_ID" "$AWS_SECRET_ACCESS_KEY" "$AWS_DEFAULT_REGION" | aws configure --profile $PROFILE_NAME
if [ ! -z "$AWS_ROLE_ARN" ]; then
  aws configure set role_arn $AWS_ROLE_ARN --profile $PROFILE_NAME
  aws configure set source_profile $PROFILE_NAME --profile $PROFILE_NAME
fi

# read GV values and write into JSON_FILE
aws secretsmanager get-secret-value --secret-id $AWS_SM_SECRET_ID --output text --query 'SecretString' --profile $PROFILE_NAME >> $JSON_FILE
```

* Step 3: Build

```sh
./build_app_image.sh \
-l /home/user/tibco/installers \
-a /home/user/tibco/be/5.6/examples/standard/FraudDetection \
-r fdcustom:latest \
--gv-providers "custom"
```

* Step 4: Run

```sh
docker run \
-e AWS_ACCESS_KEY_ID=<AWS ACCESS ID> \
-e AWS_SECRET_ACCESS_KEY=<AWS SECRET> \
-e AWS_DEFAULT_REGION=<REGION> \
-e AWS_ROLE_ARN=<ASSUMED ROLE> \
-e AWS_SM_SECRET_ID=<AWS SECRETS MANAGER - SECRET ID> \
-p 8108:8108 --name=fdcustom fdcustom:latest
```
