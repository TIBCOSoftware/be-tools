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

Also required to run the server itself:

- **Python 3.10+**.
- Optionally [`uv`](https://docs.astral.sh/uv/) — the repo ships a `uv.lock` for
  reproducible installs. Plain `pip` works too.

Call the `preflight` tool once the server is running to check all of the above at runtime.

## Setup

### Step 1 — Get the be-tools tree

Clone (or copy) the [`be-tools`](https://github.com/TIBCOSoftware/be-tools) repository so
the `cloud/` tree is on the host that will run the builds:

```sh
git clone https://github.com/TIBCOSoftware/be-tools.git
cd be-tools/mcp
```

The MCP server lives in `be-tools/mcp` and drives the sibling `cloud/` scripts.

### Step 2 — Install the server

Using **uv** (recommended — installs from the pinned `uv.lock`):

```sh
uv sync                       # create .venv and install deps (add --extra dev for tests)
```

Or using **pip** (into a virtualenv):

```sh
python -m venv .venv
# Linux/Mac:   source .venv/bin/activate
# Windows:     .venv\Scripts\activate
pip install -e ".[dev]"       # drop [dev] if you don't need the test deps
```

This provides the `be-tools-mcp` console script (stdio transport).

### Step 3 — Point the server at be-tools

The server locates the `cloud/` scripts and Helm chart via the **`BE_TOOLS_HOME`** env var.
It defaults to the repo root two levels above this package, so if you installed from inside
`be-tools/mcp` you can skip this. Otherwise set it to your be-tools checkout:

```sh
# Linux/Mac
export BE_TOOLS_HOME=/path/to/be-tools
# Windows (PowerShell)
$env:BE_TOOLS_HOME = "C:\path\to\be-tools"
```

### Step 4 — Register the server with your MCP client

**Claude Code (CLI):**

```sh
# from be-tools/mcp, so BE_TOOLS_HOME resolves to the checkout
claude mcp add be-tools --env BE_TOOLS_HOME=/path/to/be-tools -- be-tools-mcp
```

**Any MCP client (JSON config)** — add a stdio server entry. Use `uv run` if you installed
with uv and want it to run inside the project's virtualenv without activating it:

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

```jsonc
// uv variant (runs in the project venv):
{
  "mcpServers": {
    "be-tools": {
      "command": "uv",
      "args": ["run", "--directory", "/path/to/be-tools/mcp", "be-tools-mcp"],
      "env": { "BE_TOOLS_HOME": "/path/to/be-tools" }
    }
  }
}
```

To run the server directly (e.g. for debugging), invoke it by hand:

```sh
be-tools-mcp            # console script
# or
python -m be_tools_mcp
```

### Step 5 — Verify

Restart/reload your MCP client so it picks up the new server, then call the **`preflight`**
tool. It reports whether `docker`/`buildah`, `helm`, `go`, the build scripts, the Helm
chart, and your `BE_HOME`/source are present and usable, and returns `ready` (build) and
`deploy_ready` (helm) flags. A `ready: true` result means you can call `build_be_image`.

> **Windows note:** to build **Windows** container images, switch Docker Desktop to
> *Windows containers* mode first. Paths may be passed with either `/` or `\`; the server
> normalizes them for the underlying `build_image.bat`.

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
uv run pytest                              # unit + validation tests (no Docker needed)
BE_TOOLS_MCP_INTEGRATION=1 uv run pytest   # + gated integration smoke test (needs Docker + a BE app)
```

(Drop the `uv run` prefix if you installed with pip into an activated virtualenv.)
