# `Graal` Tools

[GraalVM](https://www.graalvm.org) accelerates application performance while consuming fewer resources—improving application efficiency. It achieves this by compiling your Java application ahead of time into a native binary.

By using the scripts provided in the grall folder, you can generate native binary for your BE application.

## Prerequisites

* Install TIBCO BusinessEvents
* You need to have Oracle `GraalVM`. Install from [here](https://www.graalvm.org/downloads).

## Script

TIBCO BusinessEvents provides the build_graal_image script for building native image for your TIBCO BusinessEvents application.

```sh
Usage: ./be_graal.sh -s <BE_HOME> -a <APP_HOME> -e <EXTERNAL_JARS_PATH> [-g] [-c] [-r]
  -g                       Generate metadata
  -c                       Create native image
  -r                       Run the native image
  -s <BE_HOME>             Path to BE Home
  -a <APP_HOME>            Path to Application Home
  -u <PU>                  Processing Unit name (default: default)
  -e <EXTERNAL_JARS_PATH>  Path to External Jars (default: extjars)
  -h                       Display this usage message
```

### Generate native iamge

### Run your application
