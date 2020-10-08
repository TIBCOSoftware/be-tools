# GV Configuration Framework

This framework will allow customers to use any server to configure GV values when running BE applications in container mode.

While builder application image, we need to pass --gv-providers parameter with required provider value i.e. http, consul or custom.

There are three options to configure GV values:
1. HTTP
2. Consul
3. Custom

I) HTTP:

HEADER_VALUES, HTTP_SERVER_URL and GVPROVIDER are passed as Environment variables while running docker image.

For example:

i) Using github:

To build app image, run following command:

./build_app_image.sh -l /Users/shrikant/Downloads/installationzipfiles/5.6 -a /Users/shrikant/Downloads/Installationfiles/fd -r fdhttpgit --gv-providers http -d Dockerfile

To run the application, run following command:

docker run -e HEADER_VALUES="Authorization:token 9222c5cf6e380ba1395e9d8acce8764265f85933,Content-Type:application/json" -e HTTP_SERVER_URL="<SERVER_URL>" -e GVPROVIDER=http -p 8108:8108 --name=fdhttpgit fdhttpgit:latest

ii) Using azure storage:

For example:

docker run -e HEADER_VALUES="x-ms-date: $(date -u)" -e HTTP_SERVER_URL="<SERVER_URL>" -e GVPROVIDER=http -p 8108:8108 --name=fdhttpazure fdhttpazure:latest


II) Consul:

CONSUL_SERVER_URL, GVPROVIDER, APP_CONFIG_PROFILE and BE_APP_NAME are passed as Environment variables while running docker image.

To build app image, run following command:

./build_app_image.sh -l /Users/shrikant/Downloads/installationzipfiles/5.6 -a /Users/shrikant/Downloads/Installationfiles/fd -r fdconsul--gv-providers consul -d Dockerfile

To run the application, run following command:

docker run -e CONSUL_SERVER_URL=<SERVER_URL> -e GVPROVIDER=consul -e APP_CONFIG_PROFILE=default -e BE_APP_NAME=FraudDetection -p 8108:8108 --name=fdconsul fdconsul:latest

III) Using custom:

It provides an option to the customer to add an approach for getting the required json file.
