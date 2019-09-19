Openshift's source to image for TIBCO BE is a toolkit for creating reproducible Docker images from application EAR and CDD files.

Source-to-Image (S2I) is a framework that makes it easy to write images that take application source code as an input and produce a new image that runs the assembled application as output.

Install openshift s2i by referring https://github.com/openshift/source-to-image

Follow the given steps to use S2I for deploying BE applications:

Clone https://github.com/TIBCOSoftware/be-tools.git using git clone command on your local machine.
Go to the folder cloud/docker/s2i which will be your S2I_HOME.
Add application files such as the EAR and CDD of the application to the folder $S2I_HOME/appsrc/ .
Open terminal and go to folder $S2I_HOME


To create builder image:
./create_builder_image.sh -l <installers-location> -v <BE-version> -i <image-version>

where
[-l|--installers-location]  :       Location where TIBCO BusinessEvents and TIBCO Activespaces installers are located [required]
[-v|--version]              :       TIBCO BusinessEvents product version (3 part number) [required]
[-i|--image-version]        :       Version|tag to be given to the image ('v01' for example) [required]
[-a|--addons]               :       Comma separated values for required addons : process|views [optional]
[--hf]                      :       Additional TIBCO BusinessEvents hotfix version ('1' for example) [optional]"
[--as-hf]                   :       Additional TIBCO ActiveSpaces hotfix version ('1' for example) [optional]"
[-d|--docker-file]          :       Dockerfile to be used for generating image.(default Dockerfile) [optional]"

For example:
./create_builder_image.sh -l /Users/TIBCO_HOME56/be/5.6/cloud/docker/lib/ -v 5.6.0 -i v01

To create application image:
s2i build <appsrc-location> <builder-image> <app-image>

where
<appsrc-location>         :        Location where application related files are located [required]"
<builder-image>           :        Name of builder image created in previous step [required]
<app-image>               :        Name to be given to the application image [required]

For example:
s2i build /Users/TIBCOHOME56/be/5.6/examples/standard/FraudDetection/cddearbackup/source com.tibco.be:5.6.0-v01 fdopenshifts2i:01

To run FraudDetection application:
docker run -p 8108:8108 -e CDD_FILE="/opt/tibco/be/application/fd.cdd" -e EAR_FILE="/opt/tibco/be/application/ear/fd.ear" <app-image>

To check usage of how to run application images via Openshift S2I, run following command:
s2i usage
