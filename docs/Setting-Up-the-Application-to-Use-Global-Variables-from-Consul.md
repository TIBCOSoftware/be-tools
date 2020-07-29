Your TIBCO BusinessEvents application deployed on a cloud platform can use global variables from the key-value store in Consul.
### Prerequisites
-   The Consul server that is to be used as key-value store for the application global variables must already be setup. For instructions on installation and setup, see the [Consul documentation](https://www.consul.io/docs/index.html).
-   \(Optional\) For a secured \(HTTPS\) Consul server, ensure that you have access to the CA and CLI certificates.

### Procedure
1. Connect to the Consul server that you have already setup from your web browser. Set up your application global variables in the Consul server as key-value pairs.

   Syntax for keys in Consul is

   ```
   <AppName>/<ProfileName>/<GV-Key> = <GV-Value>
   ```

   Where,

   -   _<AppName>_ is a name for the TIBCO BusinessEvents application of your choosing, for example, FraudDetection.
   -   _<ProfileName>_ is the name for the profile in the application, for example, prod, default, and so on.
   -   _<GV-Key>_ is the name of the global variable as defined in your TIBCO BusinessEvents application. In the case of global variables within a global variable group, use the usual format of separating them with a forward slash, for example, RMS/port.
   -   _<GV-Value>_ is the value to set for the global variable.

2. \(Optional\) For the secured Consul server, copy the CA and CLI certificates in the same folder as application EAR and CDD files.

3. Build the application Docker image with Consul as the key-value store for global variables of the application.

   Run the Docker image build script with the option `--gv-providers="consul"`. This downloads the Consul CLI and installs it in the application Docker image.

   For example \(for Linux\):

   ```
   build_app_image.sh -l /home/user/tibco/installers -a /home/user/app -r fd:latest **--gv-providers "consul"**
   ```

   For more information on `build_app_image` script, see [Building TIBCO BusinessEvents Application Docker Image](Building%20TIBCO%20BusinessEvents%20Application%20Docker%20Image).

4. Run the application Docker image with Consul server details as environment variables.

   Command syntax:

   ```
   docker run -e CONSUL_SERVER_URL=<consul-server-url> -e APP_CONFIG_PROFILE=<profile-name> -e BE_APP_NAME=<app-name>  -e CONSUL_CACERT=<CA_certificate_path> -e CONSUL_CLIENT_CERT=<CLI-certificate-path> -e CONSUL_CLIENT_KEY=<CLI-certificate-keystore-file-path><APPLICATION_IMAGE_NAME>:<IMAGE_VERSION>
   ```

   **Note:** The `CONSUL_CACERT`, `CONSUL_CLIENT_CERT`, and `CONSUL_CLIENT_KEY` environment variables are only required for the secured Consul server.

   Sample command \(for Linux\):

   ```
   docker run -e CONSUL_SERVER_URL=http://consul:8500 -e APP_CONFIG_PROFILE=profile1 -e BE_APP_NAME=FraudDetection -e "CONSUL_CACERT=/opt/tibco/be/ext/consul-agent-ca.pem" -e "CONSUL_CLIENT_CERT=/opt/tibco/be/ext/dc1-cli-consul-0.pem" -e "CONSUL_CLIENT_KEY=/opt/tibco/be/ext/dc1-cli-consul-0-key.pem"--network=mynet -p 8108:8108 --name=fd fd:latest
   ```

   For more details about the Consul server environment variables and other options available with the docker run command, see [Docker Run Command Reference](Docker%20Run%20Command%20Reference).

### Result
The global variables from the Consul server are now available in the application with the updated value.

**Parent topic:** [Dockerize TIBCO BusinessEvents](Dockerize%20TIBCO%20BusinessEvents)