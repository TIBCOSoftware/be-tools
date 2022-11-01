# GV Configuration Framework

This framework allows customers to configure and pull GV values from various end-stores when running the BE application in container mode.

## Documentation
TIBCO BusinessEvents® documentation is available at [Using GV Configuration Framework](https://github.com/TIBCOSoftware/be-tools/wiki/GV-Configuration-Framework).

## Cyberark Conjur GV Provider

## Prerequisites

*  The Conjur server that is to be used as key-value store for the application global variables must already be setup. For instructions on local installation and setup, see the Conjur [Quickstart](https://www.conjur.org/get-started/quick-start/oss-environment/).In the change the varibles and policies accordingly. Use the `my_app_data` file generated for CONJUR_LOGINNAME and CONJUR_APIKEY.
*  (Optional) For initializing Conjur client in secure mode, ensure that you have access to the CA certificate.

## Procedure

*  Get the conjur details, such as server url,account name, your login and certificates from conjur admin.
*  Use complete conjur variable names in Tibco Business Events. 
If your variables in conjur is of the format `<Conjur-account>:variable:<GV-Key>` 
   use only `<GV-Key>` in Application.

   For example: If a conjur variable is "myConjurAccount:variable:backend/ci/users-app/db-username" use "backend/ci/users-app/db-username" in your Tibco Business Events application.

### Build
To select this provider type, pass `cyberark` to --gv-provider flag while building the BE application image.
Sample:
```sh
./build_image.sh \
-i app \
-s /home/user/tibco/installers \
-a /home/user/tibco/app \
--gv-provider "cyberark" \
-t fdconjur:latest
```

### Conjur Run
Following environment variables are applicable for this GV provider type:
* CONJUR_SERVER_URL - Conjur Server URL
* CONJUR_ACCOUNT - Account created in conjur
* CONJUR_LOGINNAME - User or host name
* CONJUR_APIKEY - Api key
* CONJUR_SECURE - Set value to `true` to run conjur cli in secure mode.Also copy the CA certificate in the same folder as application EAR and CDD files.

Sample run:
```sh
docker run \
-e "CONJUR_SERVER_URL=<Conjur server url>" \
-e "CONJUR_ACCOUNT=<Conjur account>" \
-e "CONJUR_LOGINNAME=<Conjur user or host>" \
-e "CONJUR_APIKEY=<api_key>" \
-p 8108:8108 --name=fdconjur fdconjur:latest
```
Note: For initializing the Conjur client in secure mode add `CONJUR_SECURE=true` environment variable to the above command.