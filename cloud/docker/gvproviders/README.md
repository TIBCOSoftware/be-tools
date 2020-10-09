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
-r fdapp:latest \
--gv-providers "http"
```

### Run
This provider type expects following environment variables to be supplied while running:
* GVP_HTTP_SERVER_URL - end-store URL
* GVP_HTTP_HEADERS - Header values to access the end-store API

### Examples

#### github

Sample run:
```sh
docker run \
-e GVP_HTTP_SERVER_URL="<SERVER_URL>" \
-e GVP_HTTP_HEADERS="Authorization:token 9222c5cf6e380ba1395e9d8acce8764265f85933,Content-Type:application/json" \
-p 8108:8108 --name=fdhttpgit fdapp:latest
```

#### azure storage

Sample run:
```sh
docker run \
-e GVP_HTTP_SERVER_URL="<SERVER_URL>" \
-e GVP_HTTP_HEADERS="x-ms-date: $(date -u)" \
-p 8108:8108 --name=fdhttpazure fdapp:latest
```

## Consul

### Build
To select this provider type, pass `consul` to --gv-providers flag while building the BE application image.
Sample:
```sh
./build_app_image.sh \
-l /home/user/tibco/installers \
-a /home/user/tibco/be/5.6/examples/standard/FraudDetection \
-r fdapp:latest \
--gv-providers "consul"
```

### Run
This provider type expects following environment variables to be supplied while running:
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
Provide custom implementation in the following files:
* be-tools/cloud/docker/gvproviders/custom/setup.sh - This gets invoked during docker build time. Provide instructions to install required packages in the docker image.
* be-tools/cloud/docker/gvproviders/custom/setup.bat - Windows version of setup.sh
* be-tools/cloud/docker/gvproviders/custom/run.sh - This gets invoked during run time. Provide logic to pull GV values from end-server.
* be-tools/cloud/docker/gvproviders/custom/run.bat - Windows version of run.sh

### Build
To select this provider type, pass `custom` to --gv-providers flag while building the BE application image.
Sample:
```sh
./build_app_image.sh \
-l /home/user/tibco/installers \
-a /home/user/tibco/be/5.6/examples/standard/FraudDetection \
-r fdapp:latest \
--gv-providers "custom"
```