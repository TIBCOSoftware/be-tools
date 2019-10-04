## Introduction

<a href="https://docs.openshift.com/container-platform/3.6/creating_images/s2i.html">Openshift's Source-to-Image (S2I)</a> is a framework for building reproducible container images making it super easy for developers to provide application source code as an input and produce a new image that runs the assembled application as output.


TIBCO Business Events's S2I support allows users to create a reusable builder image while the developer can provide end application source code (via ear & cdd) to create and run the assembled image.

## Installation

### Prerequisites

You'll need to have a few things, 

<p><a href="https://docs.docker.com/docker-for-mac/install/">Docker</a></p>
<p><a href="https://github.com/openshift/source-to-image">Openshift S2I</a></p>

### Install
Clone https://github.com/TIBCOSoftware/be-tools.git using git clone command on your local machine. Open terminal and go to folder `cloud/docker/s2i`


## Getting Started

Should be fairly straightforward. Lets start off with creating a reusable builder image.
    
    ./create_builder_image.sh -l -v -i
    
    where,
    [-l|--installers-location] : Location where TIBCO BusinessEvents and TIBCO Activespaces installers are located [required] 
    [-v|--version] : TIBCO BusinessEvents product version (3 part number) [required] 
    [-i|--image-version] : Version|tag to be given to the image ('v01' for example) [required] 
    [-a|--addons] : Comma separated values for required addons : process|views [optional] 
    [--hf] : Additional TIBCO BusinessEvents hotfix version ('1' for example) [optional] 
    [--as-hf] : Additional TIBCO ActiveSpaces hotfix version ('1' for example) [optional] 
    [-d|--docker-file] : Dockerfile to be used for generating image.(default Dockerfile) [optional]
    
    Using Business Events v5.6.0 for this example,
    ./create_builder_image.sh -l /Users/test/BE_Installers -v 5.6.0 -i v01

Next we provide application source to s2i to create an assembled image off the previously created builder image.

    s2i build <location of the source code> <name of the builder image> <name of the application image>

    Using FraudDetection application for this example,
    s2i build /Users/test/Applications/FraudDetection/source com.tibco.be:5.6.0-v01 fdopenshifts2i:01

Finally run the application,

    docker run -p 8108:8108 fdopenshifts2i:01

At any point to check how to use this, simply run the `usage` command

    s2i usage


## Limitation

Currently s2i does not support windows containers. Refer to this github issue <a href="https://github.com/openshift/source-to-image/issues/991">991</a> for more details.
