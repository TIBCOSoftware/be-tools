# be-tools MCP server

A [Model Context Protocol](https://modelcontextprotocol.io) server that lets AI agents
build and test TIBCO BusinessEvents (BE) container images through the existing
[`be-tools`](https://github.com/TIBCOSoftware/be-tools) scripts.

It is a **thin, validated wrapper** that delegates all build logic to those scripts. It
constructs a safe argv (enums allowlisted, paths existence-checked, no shell string
interpolation) and shells out to `cloud/docker/build_image.sh` (`.bat` on Windows) and
`cloud/docker/tests/run_tests.sh`. See [`PLAN.md`](PLAN.md) for the full design.

## Prerequisites

The host must already be able to run the be-tools scripts by hand:

- `docker` (or `buildah`) installed and usable.
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

**Tools**
- `preflight` — check build tools, scripts, and source readiness.
- `build_be_image` — start a BE image build (`app` | `rms` | `teagent` | `s2ibuilder` | `base`). Returns a `job_id`.
- `run_image_tests` — start container-structure tests on an image. Returns a `job_id`.
- `get_job_status` / `get_job_logs` / `cancel_job` — manage long-running jobs.

**Resources**
- `be://image-types`, `be://config-providers`, `be://build-tools`, `be://optimize-modules`
- `be://help/build-image`

**Prompts**
- `containerize_be_app` — guided "containerize my BE app" workflow.

Builds take minutes, so `build_be_image` / `run_image_tests` are asynchronous: they start a
job and return a `job_id` you poll with `get_job_status` / `get_job_logs`.

## Not in v1

GraalVM native flow, Helm render/lint/deploy, remote (HTTP) transport, and image push are
deferred — see [`PLAN.md`](PLAN.md).

## Tests

```sh
cd mcp
pytest                              # unit + validation tests (no Docker needed)
BE_TOOLS_MCP_INTEGRATION=1 pytest   # + gated integration smoke test (needs Docker + a BE app)
```
