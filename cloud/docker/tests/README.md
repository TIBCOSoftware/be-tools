# BE Application Container Structure Tests
These tests validates structure of the BE Application container image using Google's [container-structure-test](https://github.com/GoogleContainerTools/container-structure-test) framework.

These tests performs following validations on the BE app image:
1. Output of important commands
2. metadata of the image
3. Whether important files are present
4. Whether important files are updated correctly

## Run Tests
Run run_tests.sh in a shell to invoke BE container structure tests.
```sh
./run_tests.sh
``` 

## Test Cases
Various test cases are developed and organized in different yaml files.
* `be-testcases.yaml` Validates BE related artifacts
* `as-testcases.yaml` Validates AS related artifacts
* `ftl-testcases.yaml` Validates FTL related artifacts
