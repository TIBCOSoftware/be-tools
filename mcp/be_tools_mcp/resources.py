"""Read-only resource content that drives valid tool inputs."""

from __future__ import annotations

from . import invoker
from .constants import (
    BUILD_TOOLS,
    CONFIG_PROVIDERS,
    HELM_TEST_SUITES,
    IMAGE_TYPES,
    optimize_modules,
)


def image_types() -> str:
    return " | ".join(IMAGE_TYPES)


def config_providers() -> str:
    return " | ".join(CONFIG_PROVIDERS)


def build_tools() -> str:
    return " | ".join(BUILD_TOOLS)


def optimize_module_list() -> str:
    lib_dir = str(invoker.docker_dir() / "lib")
    return " | ".join(optimize_modules(lib_dir))


BUILD_IMAGE_HELP = """\
build_be_image — wraps cloud/docker/build_image.sh (.bat on Windows).

Parameters (map directly to script flags):
  image_type            -i/--image-type   required: app | rms | teagent | s2ibuilder | base
  app_location          -a/--app-location required for app; optional for rms; ignored otherwise.
                                          Must contain exactly one .cdd and one .ear.
  source                -s/--source       Path to BE_HOME or TIBCO installers, or a base
                                          image name (app image only). Default ../../.
  tag                   -t/--tag          name:tag. Ignored for teagent.
  docker_file           -d/--docker-file  Override Dockerfile.
  config_provider       --config-provider gvconsul | gvhttp | gvcyberark | cmcncf | custom
                                          (list -> CSV). Ignored for teagent.
  disable_tests         --disable-tests   app/base/s2ibuilder only.
  build_tool            -b/--build-tool   docker (default) | buildah. buildah cannot build
                                          s2ibuilder and skips tests.
  openjdk               -o/--openjdk      Use OpenJDK instead of tibcojre.
  optimize/modules      --optimize        Image size optimization; extra modules as a list.

Builds are asynchronous: the tool returns a job_id; poll get_job_status / get_job_logs.
"""


def helm_test_suites() -> str:
    return " | ".join(HELM_TEST_SUITES)


def helm_values() -> str:
    """Raw ``values.yaml`` from the chart — the source of truth for deploy knobs."""
    values = invoker.helm_dir() / "values.yaml"
    try:
        return values.read_text(encoding="utf-8")
    except OSError as exc:
        return f"# values.yaml not readable at {values}: {exc}"


DEPLOY_HELP = """\
Helm/deploy tools — wrap the `helm` CLI against cloud/kubernetes/helm and the Go
test suites under cloud/kubernetes/tests. `helm` (and `go` for the tests) must be
on PATH; see the `preflight` tool.

Prerequisite: run `helm_dep_update` once to fetch subchart dependencies
(mysql/influxdb/grafana) before rendering or deploying.

Read-only / fast tools (return output directly):
  helm_dep_update   helm dependency update  — fetch subchart deps.
  helm_render       helm template           — render manifests, no cluster.
  helm_lint         helm lint               — static chart validation.
  helm_status       helm status RELEASE     — status of a deployed release.
  helm_list         helm list               — releases (JSON by default).

Cluster-mutating tools (asynchronous job; require confirm=True):
  helm_deploy       helm upgrade --install  — install or upgrade a release.
  helm_uninstall    helm uninstall RELEASE  — remove a release.

Test tool (asynchronous job):
  run_helm_tests    go test in tests/<suite>: template (no cluster; CI runs this)
                                             | integration (needs a live cluster).

Common inputs: release, namespace, kube_context, values_files (list of -f files),
set_values (list of KEY=VALUE). Release names must be lowercase RFC 1123 labels.
The `be://helm/values` resource holds the full values.yaml (all deploy knobs).
"""
