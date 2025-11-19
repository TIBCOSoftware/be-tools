# `Graal` Tools

[GraalVM](https://www.graalvm.org) accelerates application performance while consuming fewer resources—improving application efficiency. It achieves this by compiling your Java application ahead of time into a native binary.

By using the scripts provided in the grall folder, you can generate native binary for your BE application.

## Prerequisites

* Install TIBCO BusinessEvents
* You need to have Oracle `GraalVM`. Install from [here](https://www.graalvm.org/downloads).

## Script

TIBCO BusinessEvents provides the build_graal_image script for building native executable binary for your TIBCO BusinessEvents application.

```sh
Usage: ./build_graal_image.sh -s <BE_HOME> -a <APP_HOME> -e <EXTERNAL_JARS_PATH> [-g] [-c] [-r]
  -g                       Generate metadata
  -c                       Create native image
  -r                       Run the native image
  -s <BE_HOME>             Path to BE Home
  -a <APP_HOME>            Path to Application Home
  -u <PU>                  Processing Unit name (default: default)
  -e <EXTERNAL_JARS_PATH>  Path to External Jars (default: extjars)
  -h                       Display this usage message
```

### Generate meta-data

Run this step for all processing units and thoroughly test the application to cover all functionality so that the scripts can generate sufficient Graal metadata.

```sh
./build_graal_image.sh -g \
-s <BE_HOME> \
-a <APP_HOME> \
-u <PU> \
-e <EXTERNAL_JARS_PATH>

```

### Create native image

Create a native executable binary for your BE application as shown below. Note that the generated binary is specific to the operating system and architecture you are currently using.

```sh
./build_graal_image.sh -c \
-s <BE_HOME> \
-a <APP_HOME> \
-u <PU> \
-e <EXTERNAL_JARS_PATH>
```

### Run the application

You can run the application as shown below.

```sh
./build_graal_image.sh -r \
-s <BE_HOME> \
-a <APP_HOME> \
-u <PU> \
-e <EXTERNAL_JARS_PATH>
```
