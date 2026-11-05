# be-tools MCP Server — Plan

## Goal

Expose `be-tools` functionality through a [Model Context Protocol](https://modelcontextprotocol.io)
(MCP) server so that other AI agents can build and test TIBCO BusinessEvents (BE)
container images programmatically, with the same behavior a user gets from running the
scripts by hand.

`be-tools` is not an application — it is deployment/build tooling (see the repo's
`CLAUDE.md`). The MCP server is therefore a thin, validated wrapper that **delegates all
build logic to** the existing entrypoints
(`cloud/docker/build_image.sh` / `.bat`, `cloud/docker/tests/run_tests.sh`) and returns
structured results.

## Decisions (locked for v1)

| Decision | Choice | Rationale |
|---|---|---|
| Language / runtime | **Python + FastMCP** | Fast to build, excellent for shelling out, official MCP SDK. |
| Transport | **Local stdio** | Server runs on the same host as `docker`/`buildah`. Remote HTTP deferred. |
| v1 scope | **Docker image build + tests**, **Helm render/lint/deploy + k8s tests**, **info resources + prompts** | The core value: build → test → deploy. GraalVM deferred. |
| Location | **`mcp/` at repo root** | Keeps the server in lockstep with the scripts it wraps, mirroring the existing `.sh`/`.bat` lockstep convention. |
| Deploy safety | **`confirm=true` opt-in per mutating call** | `helm_deploy`/`helm_uninstall` change a live cluster; an explicit ack prevents accidental mutation, matching how push/`--disable-tests` are treated as opt-ins. |

### Deferred (not in v1)
- GraalVM native flow (`graal/be_graal.sh`).
- Remote (streamable HTTP) transport.
- Image **push** to a registry.

## Runtime contract / prerequisites

The server assumes the host it runs on can already run the scripts by hand:
- `docker` (or `buildah`) available and usable (image build/test).
- `helm` on `PATH` (render/lint/deploy) and `go` on `PATH` (k8s test suites); a working
  `kubeconfig`/context for any cluster operation.
- A `BE_HOME` or a directory of TIBCO installers (BusinessEvents, ActiveSpaces, FTL)
  as required by `build_image.sh --source`.
- The `be-tools` `cloud/` tree present, located via a `BE_TOOLS_HOME` env var.

The server does not install any of these; it detects and reports their absence
(see `preflight`).

## Capability mapping (v1)

| be-tools function | Entrypoint | MCP shape |
|---|---|---|
| Build container image (`app`/`rms`/`teagent`/`s2ibuilder`/`base`) | `cloud/docker/build_image.sh` / `.bat` | tool `build_be_image` |
| Docker image structure tests | `cloud/docker/tests/run_tests.sh` | tool `run_image_tests` |
| Fetch Helm subchart dependencies | `helm dependency update` @ `cloud/kubernetes/helm` | tool `helm_dep_update` |
| Render / lint the chart | `helm template` / `helm lint` | tools `helm_render`, `helm_lint` |
| Deploy / remove a release | `helm upgrade --install` / `helm uninstall` | tools `helm_deploy`, `helm_uninstall` (confirm-gated) |
| Inspect releases | `helm status` / `helm list` | tools `helm_status`, `helm_list` |
| Kubernetes tests (template / integration) | `go test ./...` @ `cloud/kubernetes/tests/<suite>` | tool `run_helm_tests` |
| Environment readiness check | derived | tool `preflight` |
| Enumerate valid options | derived from scripts / chart | resources |
| Guided "containerize" / "deploy my BE app" workflows | composed | prompts |

## MCP interface design

### Tools

#### `build_be_image`
Wraps `build_image.sh` / `build_image.bat`. Input schema mirrors the script flags:

| Param | Type | Notes |
|---|---|---|
| `image_type` | enum `app\|rms\|teagent\|s2ibuilder\|base` | **required** (`-i/--image-type`) |
| `app_location` | path | required if `image_type=app`; optional for `rms`; ignored otherwise (`-a`) |
| `source` | path or base image name | `BE_HOME` / installers dir; default `../../` (`-s`) |
| `tag` | string `name:tag` | optional (`-t`); ignored for `teagent` |
| `docker_file` | path | optional (`-d`) |
| `config_provider` | list of enum `gvconsul\|gvhttp\|gvcyberark\|cmcncf\|custom` | joined CSV (`--config-provider`); ignored for `teagent` |
| `disable_tests` | bool | `--disable-tests` (app/base/s2ibuilder only) |
| `build_tool` | enum `docker\|buildah` | default `docker` (`-b`); buildah cannot build s2ibuilder or run tests |
| `openjdk` | bool | `-o/--openjdk` |
| `optimize` | bool \| list of modules | `--optimize` |

Validation performed server-side (before invoking the script):
- Required-by-type rules for `app_location`.
- `app_location` must contain **exactly one** `.cdd` and **exactly one** `.ear`.
- Enum / allowed-value checks for every enum field.
- buildah restrictions (no s2ibuilder image, no tests).
- Path existence checks.

Returns: resolved image tag, exit code, log tail, and detected artifacts.

#### `run_image_tests`
Wraps `cloud/docker/tests/run_tests.sh` — image name plus the product-version flags
(`-b` BE, `-as`/`-al` ActiveSpaces, `-f` FTL, `-hk` Hawk, `-ts` TEA, `--image-type`).

#### Helm / deploy tools
Wrap the `helm` CLI against `cloud/kubernetes/helm` and the Go test suites under
`cloud/kubernetes/tests`. Argv is built the same way as the docker tools (lists, never
shell strings); release/namespace names are regex-validated (RFC 1123 labels), values-file
paths are existence-checked, and `--set` entries must be `KEY=VALUE`.

| Tool | Wraps | Nature |
|---|---|---|
| `helm_dep_update` | `helm dependency update` | sync; run once before render/deploy |
| `helm_render` | `helm template` | sync; returns rendered manifests |
| `helm_lint` | `helm lint` | sync; returns lint output |
| `helm_status` / `helm_list` | `helm status` / `helm list` | sync; read-only inspection |
| `helm_deploy` | `helm upgrade --install` | **async job; `confirm=true` required** |
| `helm_uninstall` | `helm uninstall` | **async job; `confirm=true` required** |
| `run_helm_tests` | `go test ./...` (`template`/`integration`) | async job |

Common inputs: `release`, `namespace`, `kube_context`, `values_files` (list of `-f`),
`set_values` (list of `KEY=VALUE`); deploy adds `create_namespace`, `wait`, `timeout`,
`atomic`, `dry_run`. **Split by nature:** fast, read-only operations run synchronously and
return their output directly (an agent wants the rendered YAML / status now); mutating or
long operations run as async jobs and return a `job_id`. Mutating tools without `confirm`
refuse and echo back the target namespace/context.

#### `preflight`
Reports whether `docker`/`buildah`, `helm`, `go`, the `build_image` scripts, the Helm
chart, and a `BE_HOME`/source are present and usable, so an agent can self-diagnose before
building or deploying. Returns `ready` (build) and `deploy_ready` (helm) flags.

### Long-running-job model
Image builds take minutes, so the build/test tools are asynchronous:
- `build_be_image` / `run_image_tests` **start** the job and return a `job_id`.
- `get_job_status(job_id)` and `get_job_logs(job_id)` report progress (wired to MCP
  progress notifications where the client supports them).
- `cancel_job(job_id)` stops a running job.

### Resources (read-only; drive valid inputs)
- `be://image-types` → `app | rms | teagent | s2ibuilder | base`
- `be://config-providers` → `gvconsul | gvhttp | gvcyberark | cmcncf | custom`
- `be://optimize-modules` → parsed from the script's supported-modules list
- `be://build-tools` → `docker | buildah`
- `be://help/build-image` → raw usage block from the script (source of truth for agents)
- `be://help/deploy` → usage summary of the Helm/deploy tools
- `be://helm/test-suites` → `template | integration`
- `be://helm/values` → the chart's full `values.yaml` (source of truth for deploy knobs)

### Prompts
- Guided **"containerize my BE app"** workflow: gathers app dir, source, tag, optional
  config providers / optimization, then calls `build_be_image` and (optionally)
  `run_image_tests`.
- Guided **"deploy my BE app"** workflow: preflight → pick topology from `be://helm/values`
  → `helm_dep_update` → dry-run with `helm_render`/`helm_lint` → `helm_deploy` (confirm) →
  verify with `helm_status`.

## Cross-cutting concerns
- **Argv builder:** centralized; no raw shell string interpolation. Enums allowlisted,
  paths existence-checked — contains command-injection risk.
- **OS awareness:** invoker picks `.sh` vs `.bat` by host OS and locates `cloud/docker`
  relative to `BE_TOOLS_HOME`.
- **Error mapping:** script exit codes → meaningful MCP errors with the relevant log tail.
- **Config:** `BE_TOOLS_HOME`, default build tool, default registry via env vars.
- **Safety:** `--disable-tests` and (future) image push treated as explicit opt-ins.

## Testing
- **Unit tests** asserting the exact argv produced for representative flag combinations
  (no docker required) — most correctness lives here.
- **Validation tests** for the `.cdd`/`.ear` rule, enum checks, and buildah restrictions.
- **One gated integration smoke test** that actually runs `build_image.sh` +
  `run_tests.sh`, behind an env flag.

## Docs & CI
- `mcp/README.md` with a Claude Code / MCP client config snippet and prerequisites.
- CI job to lint + run the unit tests, alongside the existing
  `.github/workflows/helm-template-test.yml`.

## Project layout (proposed)
```
mcp/
  PLAN.md              # this document
  README.md            # usage + client config
  pyproject.toml       # fastmcp, pydantic, pytest
  be_tools_mcp/
    __init__.py
    server.py          # FastMCP app, tool/resource/prompt registration
    invoker.py         # OS-aware script locator + subprocess runner
    argv.py            # validated argv construction for build_image / run_tests
    helm_argv.py       # validated argv construction for helm / go test
    jobs.py            # async job manager (start/status/logs/cancel)
    resources.py       # enum/help resources
    prompts.py         # guided workflows
  tests/
    test_argv.py
    test_helm_argv.py    # helm/go argv + validation
    test_validation.py
    test_integration.py  # gated by env flag
```

## Build order
1. Scaffold + `preflight` + resources (unblocks agents to introspect).
2. `build_be_image` argv builder + validation + unit tests.
3. Async job model + log streaming.
4. `run_image_tests`.
5. Helm/deploy: `helm_argv` builders + validation + unit tests; render/lint/status/list
   (sync), deploy/uninstall (async, confirm-gated), `run_helm_tests`; deploy resources +
   prompt.
6. Prompts + docs + CI.

## Open questions
- Confirm `mcp/` (repo root) vs a separate repo for the server.
- Registry/auth handling once push is added (out of v1).
- Whether to expose `run_tests.sh` independently or only as a post-build step.
