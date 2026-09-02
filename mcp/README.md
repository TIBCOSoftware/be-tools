# be-tools MCP server

A [Model Context Protocol](https://modelcontextprotocol.io) server that lets AI agents
build, test, and deploy TIBCO BusinessEvents (BE) container images through the existing
[`be-tools`](https://github.com/TIBCOSoftware/be-tools) scripts and Helm chart.

It is a **thin, validated wrapper** that delegates all logic to those scripts and to
`helm`/`go`. It constructs a safe argv (enums allowlisted, paths existence-checked, no
shell string interpolation) and shells out to `cloud/docker/build_image.sh` (`.bat` on
Windows), `cloud/docker/tests/run_tests.sh`, the `helm` CLI against
`cloud/kubernetes/helm`, and the Go test suites under `cloud/kubernetes/tests`.
See [`PLAN.md`](PLAN.md) for the full design.

## Prerequisites

The host must already be able to run the be-tools scripts by hand:

- `docker` (or `buildah`) installed and usable (for image build/test).
- `helm` — and `go` for the Helm test suites — on `PATH` (for deploy/render/test).
  Cluster operations also need a working `kubeconfig`/context.
- A `BE_HOME` or a directory of TIBCO installers (BusinessEvents, ActiveSpaces, FTL).
- The be-tools `cloud/` tree. The server locates it via **`BE_TOOLS_HOME`** (defaults to
  the repo root two levels above this package).

Call the `preflight` tool to check all of this at runtime.

## Install

```sh
cd mcp
pip install -e ".[dev]"
```

## Run

```sh
be-tools-mcp          # console script (stdio transport)
# or
python -m be_tools_mcp
```

## MCP client config

For Claude Code / any MCP client (stdio):

```json
{
  "mcpServers": {
    "be-tools": {
      "command": "be-tools-mcp",
      "env": { "BE_TOOLS_HOME": "/path/to/be-tools" }
    }
  }
}
```

## Capabilities (v1)

**Tools — build/test**
- `preflight` — check build tools, `helm`/`go`, scripts, chart, and source readiness.
- `build_be_image` — start a BE image build (`app` | `rms` | `teagent` | `s2ibuilder` | `base`). Returns a `job_id`.
- `run_image_tests` — start container-structure tests on an image. Returns a `job_id`.
- `get_job_status` / `get_job_logs` / `cancel_job` — manage long-running jobs.

**Tools — Helm/deploy**
- `helm_dep_update` — fetch subchart dependencies (run once before render/deploy).
- `helm_render` — `helm template` (render manifests, no cluster). Returns output directly.
- `helm_lint` — `helm lint` (static chart validation). Returns output directly.
- `helm_status` / `helm_list` — inspect deployed releases. Return output directly.
- `helm_deploy` — `helm upgrade --install`. **Mutates the cluster; requires `confirm=true`.** Returns a `job_id`.
- `helm_uninstall` — `helm uninstall`. **Mutates the cluster; requires `confirm=true`.** Returns a `job_id`.
- `run_helm_tests` — `go test` for the `template` (no cluster) or `integration` (needs a cluster) suite. Returns a `job_id`.

**Resources**
- `be://image-types`, `be://config-providers`, `be://build-tools`, `be://optimize-modules`
- `be://help/build-image`, `be://help/deploy`
- `be://helm/test-suites`, `be://helm/values` (the chart's full `values.yaml`)

**Prompts**
- `containerize_be_app` — guided "containerize my BE app" workflow.
- `deploy_be_app` — guided "deploy my BE app to Kubernetes" workflow.

Long operations (image build/test, `helm_deploy`, `helm_uninstall`, `run_helm_tests`) are
asynchronous: they start a job and return a `job_id` you poll with `get_job_status` /
`get_job_logs`. Fast read-only Helm tools (`helm_render`, `helm_lint`, `helm_status`,
`helm_list`, `helm_dep_update`) run synchronously and return their output directly.

## Planned for later versions

GraalVM native flow, remote (HTTP) transport, and image push are on the roadmap.

## Tests

```sh
cd mcp
pytest                              # unit + validation tests (no Docker needed)
BE_TOOLS_MCP_INTEGRATION=1 pytest   # + gated integration smoke test (needs Docker + a BE app)
```
