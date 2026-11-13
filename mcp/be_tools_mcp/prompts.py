"""Guided workflow prompts."""

from __future__ import annotations


def containerize_be_app(
    app_location: str = "",
    source: str = "",
    tag: str = "",
) -> str:
    """Text of the guided 'containerize my BE app' workflow."""
    app_location = app_location or "<path to BE app dir with one .cdd and one .ear>"
    source = source or "<path to BE_HOME or installers, or a base image name>"
    tag = tag or "<name:tag>"
    return f"""\
Goal: containerize a TIBCO BusinessEvents application into a Docker image using be-tools.

Follow these steps, calling the MCP tools in order:

1. Call `preflight` to confirm docker/buildah, the build_image script, and the source
   (BE_HOME or installers) are present. Fix anything reported as missing before continuing.

2. Confirm the inputs with the user:
   - app_location: {app_location}
   - source:       {source}
   - tag:          {tag}
   - optional: config_provider(s), openjdk, optimize/optimize_modules.
   Read the `be://image-types`, `be://config-providers`, and `be://optimize-modules`
   resources if you need the valid values.

3. Call `build_be_image` with image_type="app" and the inputs above. It returns a job_id.

4. Poll `get_job_status(job_id)` until status is no longer "running". On failure, call
   `get_job_logs(job_id)` and report the relevant error to the user.

5. On success, offer to run `run_image_tests` against the resulting image tag.
"""


def deploy_be_app(
    release: str = "",
    namespace: str = "",
    values_file: str = "",
) -> str:
    """Text of the guided 'deploy my BE app to Kubernetes' workflow."""
    release = release or "<helm release name, e.g. my-be-app>"
    namespace = namespace or "<kubernetes namespace>"
    values_file = values_file or "<path to a values override file>"
    return f"""\
Goal: deploy a TIBCO BusinessEvents application to Kubernetes with the be-tools Helm chart.

Follow these steps, calling the MCP tools in order:

1. Call `preflight` to confirm `helm` (and `go`, if you plan to run tests) are on PATH
   and the chart is present. Fix anything reported as missing before continuing.

2. Read `be://helm/values` to understand the deploy knobs, and pick the BE topology
   (in-memory / cache / RMS / TEA). Prepare a values override file or `set_values`
   (KEY=VALUE) accordingly. The image built by `build_be_image` must be pushed to a
   registry the cluster can pull from.

3. Call `helm_dep_update` once to fetch subchart dependencies.

4. Dry-run first: call `helm_render` (and optionally `helm_lint`) with:
   - release:      {release}
   - namespace:    {namespace}
   - values_files: [{values_file}]
   Review the rendered manifests with the user.

5. Deploy: call `helm_deploy` with the same inputs and `confirm=True` (required — it
   mutates the cluster). It returns a job_id; poll `get_job_status` / `get_job_logs`.

6. Verify with `helm_status(release, namespace)`. To roll back, `helm_uninstall`
   (also requires `confirm=True`).
"""
