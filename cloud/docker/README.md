# Docker Tools

By using the scripts provided in the `docker` folder, you can containerize and run a TIBCO BusinessEvents application in Docker. The folder contains scripts and Dockerfiles that you can use to build Docker images for the following:

- TIBCO BusinessEvents Application

- TIBCO BusinessEvents Rule Management Server

- TIBCO BusinessEvents Enterprise Administrator Agent

- TIBCO BusinessEvents S2I Builder Image

## Dockerize TIBCO BusinessEvents

TIBCO BusinessEvents provides single script `build_image` for building images of TIBCO BusinessEvents application and its components at `..\cloud\docker`. Script uses the platform-specific Dockerfiles bundled with TIBCO BusinessEvents at `..\cloud\docker\dockerfiles`.

### Script Usage

Linux and macos based platforms can use `build_image.sh` script. Windows platforms can use `build_image.bat` script. Both scripts accepts same arguments.

Clone https://github.com/TIBCOSoftware/be-tools.git using git clone command on your local machine.
Open terminal and go to folder cloud/docker

```bash
./build_image.sh -h

Usage: build_image.sh

 [-i/--image-type]    :    Type of image. Values must be(app/rms/teagent/s2ibuilder). (example: app) [required]
                           Note: s2ibuilder image has prerequisite. Check the documentation in be-tools wiki.

 [-a/--app-location]  :    Location where the ear, cdd are located. [required only if -i/--image-type is app]

 [-s/--source]        :    Path to be-home or location where installers(TIBCO BusinessEvents, Activespaces, FTL) located. [required for installers]
                           Note: No need to specify be-home if script is executed from BE_HOME/cloud/docker folder.

 [-t/--tag]           :    Tag or name of the image. (example: beimage:v1) [optional]

 [-d/--docker-file]   :    Dockerfile to be used for generating image. [optional]

 [--gv-provider]      :    Name of GV provider to be included in the image. Values must be (consul/http/custom). (example: consul) [optional]
                           Note: Use this flag only if -i/--image-type is app/s2ibuilder.

 [--disable-tests]    :    Disables docker unit tests on created image. [optional]
                           Note: Use this flag only if -i/--image-type is app/s2ibuilder.

 [-h/--help]          :    Print the usage of script. [optional]

 NOTE : supply long options with '=' 
```

NOTE: While supplying arguments `-s` can be any of the following.

- Location where software installers or provided.
- TIBCO BusinessEvents installed then path to be-home.
- If script is executed from `be-home/cloud/docker` then `-s` can be ignored.

### TIBCO BusinessEvents Application Image

#### Syntax:
```bash
./build_image.sh -i <image-type> -a <application-location> -s <be-home path or software installers location>
```
#### Example:
```bash
./build_image.sh -i app -a /home/user/tibco/be/6.0/examples/standard/FraudDetection -s /home/user/tibco/be/6.0
```
On successful completion docker image `app:6.0.0` will get created. In above command 

### TIBCO BusinessEvents Rule Management Server

#### Syntax:
```bash
./build_image.sh -i <image-type> -s <be-home path or software installers location>
```
#### Example:
```bash
./build_image.sh -i rms -s /home/user/tibco/be/6.0
```
On successful completion docker image `rms:6.0.0` will get created.

### TIBCO BusinessEvents Enterprise Administrator Agent

#### Syntax:
```bash
./build_image.sh -i <image-type> -s <be-home path or software installers location>
```
#### Example:
```bash
./build_image.sh -i teagent -s /home/user/tibco/be/6.0
```
On successful completion docker image `teagent:6.0.0` will get created.

### TIBCO BusinessEvents S2I Builder Image
Openshift's Source-to-Image (S2I) is a framework for building reproducible container images making it super easy for developers to provide application source code as an input and produce a new image that runs the assembled application as output.
TIBCO Business Events's S2I support allows users to create a reusable builder image while the developer can provide end application source code (via ear & cdd) to create and run the assembled image.

#### Syntax:
```bash
./build_image.sh -i <image-type> -s <be-home path or software installers location>
```
#### Example:
```bash
./build_image.sh -i s2ibuilder -s /home/user/tibco/be/6.0
```
On successful completion docker image `s2ibuilder:6.0.0` will get created. Next we provide application source to s2i to create an assembled image off the previously created builder image.
```bash
s2i build <location of the source code> <name of the builder image> <name of the application image>
```
Using FraudDetection application for this example.
```bash
s2i build /home/user/tibco/be/6.0/examples/standard/FraudDetection s2ibuilder:6.0.0 fdapps2i:01
```
NOTE: s2i can be downloaded from [here](https://github.com/openshift/source-to-image).
