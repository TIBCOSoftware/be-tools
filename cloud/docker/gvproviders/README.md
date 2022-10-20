# GV Configuration Framework

This framework allows customers to configure and pull GV values from various end-stores when running the BE application in container mode.

## Documentation
TIBCO BusinessEvents® documentation is available at [Using GV Configuration Framework](https://github.com/TIBCOSoftware/be-tools/wiki/GV-Configuration-Framework).

## Cyberark Conjur GV Provider

## Prerequisites

*  The Conjur server with all policies and variables loaded.
*  (Optional) For using conjur cli in secured mode, ensure that you have access to the CA certificate.

Note: You may use [Quickstart](https://www.conjur.org/get-started/quick-start/oss-environment/) for basic setup of conjur using docker images in local. 
Refer Unit 1-For setting up conjur server, Unit 2-Change the policies according to your variables and Unit 3-Load the variables mentioned in the policies. Use the `my_app_data` file generated for CONJUR_LOGIN and CONJUR_APIKEY.

### Procedure
1. For existing Conjur server, get the conjur details from conjur admin.
2. \(Optional\) For the secured conjur connection, copy the CA certificate in the same folder as application EAR and CDD files.

### Build
To select this provider type, pass `conjur` to --gv-provider flag while building the BE application image.
Sample:
```sh
./build_image.sh \
-i app \
-s /home/user/tibco/installers \
--gv-provider "custom/cyberark-conjur" \
-t fdconjur:latest
```

###Conjur Run
Following environment variables are applicable for this GV provider type:
* CONJUR_SERVER_URL - Conjur Server URL
* CONJUR_ACCOUNT - Account created in conjur
* CONJUR_LOGIN - User or host name
* CONJUR_APIKEY - Api key

Sample run:
```sh
docker run \
-e "CONJUR_SERVER_URL=http://consul:8500" \
-e "CONJUR_ACCOUNT=<Conjur account>" \
-e "CONJUR_LOGIN=<Conjur user or host>" \
-e "CONJUR_APIKEY=<api_key>" \
-p 8108:8108 --name=fdconjur fdconjur:latest
```
Sample run(Secured Conjur Server):TBD

The `CONJUR_CACERT` environment variable is only required for the secured mode.

```sh
docker run \
-e CONJUR_ACCOUNT=myConjurAccount \
-e CONJUR_SERVER_URL=https://proxy \
-e CONJUR_LOGIN=admin \
-e CONJUR_APIKEY=2jtsx0c358kcyw15a0rm112d4b1e5yfsm11eeah7q6n0dx61t8cr57 \
--network conjur-quickstart_default
-p 8108:8108 --name=bot_app fdconsul:latest
```