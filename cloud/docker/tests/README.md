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
```

## Test Cases
Various test cases are developed and organized in different yaml files. File names are self explanatory.
* `betestcases.yaml` Validates BE related artifacts
* `astestcases.yaml/aslegacytestcases.yaml` Validates AS related artifacts
* `ftltestcases.yaml` Validates FTL related artifacts<br><br>

Note: A part from given files you can create your own yaml testcases. If you have generic testcases there is option for supplying key value pairs using `-kv or --key-value-pair`. This key should be unique string in all yaml files. Custom yaml files should be placed along with existing testcases.