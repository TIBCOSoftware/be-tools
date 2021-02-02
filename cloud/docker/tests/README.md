# BE Application Container Structure Tests
These tests validates structure of the BE Application container image using Google's [container-structure-test](https://github.com/GoogleContainerTools/container-structure-test) framework.

These tests performs following validations on the BE app image:
1. Output of important commands
2. metadata of the image
3. Whether important files are present
4. Whether important files are updated correctly

## Run Tests
Run run_tests.sh in a shell to invoke BE container structure tests. To check usage run below command.
```sh
./run_tests.sh -h

Usage: run_tests.sh

 [ -i|--image-name]           : BE app image name with tag <image-name>:<tag> ex(be6:v1) [required]

 [ -b|--be-version]           : BE version in x.x format ex(6.1) [required]

 [-al|--as-legacy-version]    : AS legacy version in x.x format ex(2.4) [optional]

 [-as|--as-version]           : ACTIVESPACES version in x.x format ex(4.5) [optional]

 [ -f|--ftl-version]          : FTL version in x.x format ex(6.5) [optional]

 [-kv|--key-value-pair]       : Key value pairs to replace in yaml files ex(JRE_VERSION=11) can be multiple [optional]

 [-gv|--gv-provider]          : GV Provider value ex(consul) [optional]

 [ -h|--help]                 : Print the usage of script [optional]

 NOTE : supply long options with '='
```
Sample run command:
```sh
./run_tests.sh --image-name beappimage:01 \
--be-version 6.1 \
--as-version 4.5 \
--ftl-version 6.5 \
--gv-provider consul
```

## Test Cases
Various test cases are developed and organized in different yaml files. File names are self explanatory.
* `betestcases.yaml` Contains BE artifacts related test cases
* `astestcases.yaml/aslegacytestcases.yaml` Contains Active Spaces artifacts related test cases
* `ftltestcases.yaml` Contains FTL artifacts related test cases
* `consulgv.yaml` Contains `consul` gvprovider related test cases
* `httpgv.yaml` Contains `http` gvprovider related test cases
<br><br>

## Notes to add Additional Test Cases

* Additional test cases can be added to existing yaml files OR to a new file with extension *.yaml under /testcases folder
* You can add generic test cases which has variable tokens in it like BE_SHORT_VERSION, JRE_VERSION, etc. Supply values to be replaced using `-kv or --key-value-pair` while running test cases.
Sample usage:
```sh
--key-value-pair JRE_VERSION=1.8.0
```