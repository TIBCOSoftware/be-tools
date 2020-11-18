# BE Helm Chart Unit Tests
These tests validates BE Helm Chart using [terratest](https://github.com/gruntwork-io/terratest) `Go` library.

Validations include:
1. Template Tests: Whether `kubernetes` templates are rendered as expected
2. Integration Tests: Whether `kubernetes` configurations are deployed into a cluster as expected.

## Setup
* Install [Go](https://golang.org/doc/install) `v1.14` or above
* Install and set up [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
* Install [helm](https://helm.sh/docs/intro/install/)

## Run Tests

### Template Tests
Navigate to template test folder and use below command to run  `Template` tests:
```sh
cd cloud/kubernetes/tests/template
go test -v ./...
```

### Integration Tests:
#### Prerequisite
* Kubernetes cluster - Make sure that `kubectl` context is point to a running Kubernetes cluster
* BE application docker images - Make sure that BE application docker images are available and whose references are updated correctly in the `cloud/kubernetes/tests/common/values.go` file.

Sample reference in the values.go:
```go
UnclInmemory = "unclinmem" // If the image is available in the same machine as Kuberenetes cluster
UnclInmemory = "myreg.azurecr.io/unclinmem:1.0" // If the image with tag 1.0 is available at myreg.azurecr.io 
```
* Other dependent docker images - Make sure that TIBCO AS4 and TIBCO FTL docker images are available and whose references are updated correctly in `asdg.yml` & `ftl4be.yml` files under `cloud/kubernetes/tests/utils` folder.

Navigate to integration test folder and use below command to run  `Integration` tests:
```sh
cd cloud/kubernetes/tests/integration/
go test -v ./...
```