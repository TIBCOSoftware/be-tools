# BE Helm Chart Unit Tests
These tests validates BE Helm Chart using [terratest](https://github.com/gruntwork-io/terratest) `Go` library.

Validations include:
1. Template Tests: Whether `kubernetes` templates are rendered as expected
2. Integration Tests: Whether `kubernetes` templates are deployed as expected.

## Setup
Install [Go](https://golang.org/doc/install) `v1.14` or above.
Install and Set Up [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

## Run Tests
Make sure that kubectl is properly configured and pointing to a running kubernetes cluster like `minikube`, `EKS`, `AKS`, etc.
Run test using `go test` command:
```sh
cd cloud/kubernetes/helm/tests
go test -v ./...
```