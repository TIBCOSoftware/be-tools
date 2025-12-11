# `Graal` Tools

[GraalVM](https://www.graalvm.org) accelerates application performance while consuming fewer resources—improving application efficiency. It achieves this by compiling your Java application ahead of time into a native binary.

By using the scripts provided in the graal folder, you can generate native binary for your BE application.

## Prerequisites

* Install TIBCO BusinessEvents
* You need to have `GraalVM` CE. Install from [here](https://github.com/graalvm/graalvm-ce-builds/releases/tag/jdk-25.0.1).
* Install `GraalVM` related tools for Linux `sudo apt-get install build-essential zlib1g-dev jq`.
* You need to have jnr posix jar file in external jars path. Get it from [here](https://repo1.maven.org/maven2/com/github/jnr/jnr-posix/3.1.20/jnr-posix-3.1.20.jar).

## Script

TIBCO BusinessEvents provides the be_graal script for building native executable binary for your TIBCO BusinessEvents application.

```sh
Usage: ./be_graal.sh -s <BE_HOME> -a <APP_HOME> -e <EXTERNAL_JARS_PATH> -t <IMAGE_NAME> [-m] [-c] [-n] [-r] [-d] [-h]
  -m                       Generate metadata
  -c                       Clean metadata
  -n                       Create native image
  -r                       Run the native image
  -d                       Build Docker image from native binary
  -s <BE_HOME>             Path to BE Home
  -a <APP_HOME>            Path to BE application directory with cdd and ear
  -u <PU>                  Processing Unit name (default: default)
  -e <EXTERNAL_JARS_PATH>  Path to External Jars (default: extjars)
  -t <IMAGE_NAME>          Provide docker image name (default: be-graal-image)
  -h                       Display this usage message
```

### Generate meta-data

Run this step for all processing units and thoroughly test the application to cover all functionality so that the scripts can generate sufficient Graal metadata.

```sh
./be_graal.sh -m \
-s <BE_HOME> \
-a <APP_HOME> \
-u <PU> \
-e <EXTERNAL_JARS_PATH>

```

### Clean meta-data

Run this step to remove Graal metadata.

```sh
./be_graal.sh -c \
-a <APP_HOME>

```

### Create native image

Create a native executable binary for your BE application as shown below. Note that the generated binary is specific to the operating system and architecture you are currently using.

```sh
./be_graal.sh -n \
-s <BE_HOME> \
-a <APP_HOME> \
-e <EXTERNAL_JARS_PATH>
```

### Run the application

You can run the application as shown below.

```sh
./be_graal.sh -r \
-s <BE_HOME> \
-a <APP_HOME> \
-u <PU> \
-e <EXTERNAL_JARS_PATH>
```

### Docker image from native binary

You can create the docker image from native binary as shown below.

```sh
./be_graal.sh -d \
-s <BE_HOME> \
-a <APP_HOME> \
-t <IMAGE_NAME>
```