"""FastMCP application: tools, resources, and prompts for be-tools.

Run with ``python -m be_tools_mcp`` or the ``be-tools-mcp`` console script
(stdio transport). The server shells out to the be-tools scripts; it installs
nothing and detects/reports missing prerequisites via ``preflight``.
"""

from __future__ import annotations

from typing import Annotated

from mcp.server.mcpserver import MCPServer
from pydantic import Field

from . import invoker, prompts, resources
from .argv import ValidationError, build_image_argv, run_tests_argv
from .helm_argv import (
    helm_dep_update_argv,
    helm_deploy_argv,
    helm_lint_argv,
    helm_list_argv,
    helm_render_argv,
    helm_status_argv,
    helm_test_argv,
    helm_uninstall_argv,
)
from .jobs import JobManager

mcp = MCPServer("be-tools", version="0.1.0")
_jobs = JobManager()


# --------------------------------------------------------------------------- #
# Tools
# --------------------------------------------------------------------------- #
@mcp.tool()
def preflight(
    source: Annotated[
        str | None,
        Field(description="Optional path to BE_HOME / installers to check for existence."),
    ] = None,
) -> dict:
    """Report whether the host can build BE images (build tools, scripts, source)."""
    script = invoker.build_image_script()
    tests_script = invoker.run_tests_script()
    helm_chart = invoker.helm_dir() / "Chart.yaml"
    result = {
        "be_tools_home": str(invoker.be_tools_home()),
        "docker": invoker.which("docker"),
        "buildah": invoker.which("buildah"),
        "perl": invoker.which("perl"),
        "helm": invoker.which("helm"),
        "go": invoker.which("go"),
        "build_image_script": str(script),
        "build_image_script_present": script.is_file(),
        "run_tests_script": str(tests_script),
        "run_tests_script_present": tests_script.is_file(),
        "helm_chart": str(helm_chart),
        "helm_chart_present": helm_chart.is_file(),
    }
    if source is not None:
        from pathlib import Path

        result["source"] = source
        result["source_present"] = Path(source).exists()
    ready = (result["docker"] or result["buildah"]) and result["build_image_script_present"]
    result["ready"] = bool(ready)
    result["deploy_ready"] = bool(result["helm"] and result["helm_chart_present"])
    return result


@mcp.tool()
async def build_be_image(
    image_type: Annotated[
        str, Field(description="app | rms | teagent | s2ibuilder | base")
    ],
    app_location: Annotated[
        str | None,
        Field(description="BE app dir (one .cdd + one .ear). Required for app."),
    ] = None,
    source: Annotated[
        str | None,
        Field(description="BE_HOME / installers dir, or a base image name (app only)."),
    ] = None,
    tag: Annotated[str | None, Field(description="Image tag as name:tag.")] = None,
    docker_file: Annotated[str | None, Field(description="Override Dockerfile path.")] = None,
    config_provider: Annotated[
        list[str] | None,
        Field(description="gvconsul | gvhttp | gvcyberark | cmcncf | custom (list)."),
    ] = None,
    disable_tests: Annotated[
        bool, Field(description="Skip post-build tests (app/base/s2ibuilder).")
    ] = False,
    build_tool: Annotated[str, Field(description="docker (default) | buildah")] = "docker",
    openjdk: Annotated[bool, Field(description="Use OpenJDK instead of tibcojre.")] = False,
    optimize: Annotated[bool, Field(description="Enable image size optimization.")] = False,
    optimize_modules: Annotated[
        list[str] | None,
        Field(description="Extra modules to strip; implies optimize=True."),
    ] = None,
) -> dict:
    """Start an asynchronous BE container image build. Returns a job_id to poll."""
    try:
        argv = build_image_argv(
            image_type=image_type,
            app_location=app_location,
            source=source,
            tag=tag,
            docker_file=docker_file,
            config_provider=config_provider,
            disable_tests=disable_tests,
            build_tool=build_tool,
            openjdk=openjdk,
            optimize=optimize,
            optimize_modules_extra=optimize_modules,
            docker_lib_dir=str(invoker.docker_dir() / "lib"),
        )
    except ValidationError as exc:
        return {"error": str(exc)}

    script = invoker.build_image_script()
    if not script.is_file():
        return {"error": f"build_image script not found at {script}. Set BE_TOOLS_HOME."}

    command = invoker.launch_command(script, argv)
    job = await _jobs.start("build", command, invoker.docker_dir())
    return {"job_id": job.id, "argv": argv, "command": command, "status": job.status}


@mcp.tool()
async def run_image_tests(
    image_name: Annotated[str, Field(description="Image to test, as name:tag.")],
    be_version: Annotated[str, Field(description="BE version x.x, e.g. 6.1.")],
    as_legacy_version: Annotated[str | None, Field(description="AS legacy version x.x.")] = None,
    as_version: Annotated[str | None, Field(description="ActiveSpaces version x.x.")] = None,
    ftl_version: Annotated[str | None, Field(description="FTL version x.x.")] = None,
    hawk_version: Annotated[str | None, Field(description="Hawk version x.x.")] = None,
    tea_version: Annotated[str | None, Field(description="TEA version x.x.x.")] = None,
    config_provider: Annotated[str | None, Field(description="gvconsul | gvhttp.")] = None,
    image_type: Annotated[str, Field(description="app | s2ibuilder | rms | teagent")] = "app",
    java_dir_name: Annotated[str | None, Field(description="Java home dir name.")] = None,
    key_value_pairs: Annotated[
        list[str] | None, Field(description="KEY=VALUE overrides for the yaml tests.")
    ] = None,
) -> dict:
    """Start an asynchronous container-structure test run. Returns a job_id to poll."""
    try:
        argv = run_tests_argv(
            image_name=image_name,
            be_version=be_version,
            as_legacy_version=as_legacy_version,
            as_version=as_version,
            ftl_version=ftl_version,
            hawk_version=hawk_version,
            tea_version=tea_version,
            config_provider=config_provider,
            image_type=image_type,
            java_dir_name=java_dir_name,
            key_value_pairs=key_value_pairs,
        )
    except ValidationError as exc:
        return {"error": str(exc)}

    script = invoker.run_tests_script()
    if not script.is_file():
        return {"error": f"run_tests script not found at {script}. Set BE_TOOLS_HOME."}

    command = invoker.launch_command(script, argv)
    job = await _jobs.start("test", command, invoker.tests_dir())
    return {"job_id": job.id, "argv": argv, "command": command, "status": job.status}


@mcp.tool()
def get_job_status(job_id: str) -> dict:
    """Status of a build/test job started earlier."""
    job = _jobs.get(job_id)
    if job is None:
        return {"error": f"Unknown job_id [{job_id}]."}
    return job.snapshot()


@mcp.tool()
def get_job_logs(
    job_id: str,
    tail: Annotated[int, Field(description="Number of trailing log lines (0 = all).")] = 200,
) -> dict:
    """Recent log output of a build/test job."""
    job = _jobs.get(job_id)
    if job is None:
        return {"error": f"Unknown job_id [{job_id}]."}
    return {"job_id": job_id, "status": job.status, "logs": job.log_tail(tail)}


@mcp.tool()
async def cancel_job(job_id: str) -> dict:
    """Cancel a running build/test job."""
    job = _jobs.get(job_id)
    if job is None:
        return {"error": f"Unknown job_id [{job_id}]."}
    cancelled = await _jobs.cancel(job_id)
    return {"job_id": job_id, "cancelled": cancelled, "status": job.status}


# --------------------------------------------------------------------------- #
# Helm / deploy tools
# --------------------------------------------------------------------------- #
def _helm_missing() -> dict | None:
    """Shared guard: helm on PATH and the chart present, else an error dict."""
    if invoker.which("helm") is None:
        return {"error": "helm not found on PATH. See the preflight tool."}
    chart = invoker.helm_dir() / "Chart.yaml"
    if not chart.is_file():
        return {"error": f"Helm chart not found at {chart}. Set BE_TOOLS_HOME."}
    return None


def _run_helm_sync(argv: list[str], *, kind: str) -> dict:
    """Run a fast, read-only helm command and return its output directly."""
    missing = _helm_missing()
    if missing is not None:
        return missing
    command = ["helm", *argv]
    returncode, output = invoker.run_sync(command, invoker.helm_dir())
    return {
        "kind": kind,
        "command": command,
        "returncode": returncode,
        "succeeded": returncode == 0,
        "output": output,
    }


@mcp.tool()
def helm_dep_update() -> dict:
    """Fetch the chart's subchart dependencies (helm dependency update)."""
    try:
        argv = helm_dep_update_argv(chart_dir=str(invoker.helm_dir()))
    except ValidationError as exc:
        return {"error": str(exc)}
    return _run_helm_sync(argv, kind="dep-update")


@mcp.tool()
def helm_render(
    release: Annotated[str, Field(description="Helm release name (lowercase RFC 1123).")],
    namespace: Annotated[str | None, Field(description="Target namespace.")] = None,
    values_files: Annotated[
        list[str] | None, Field(description="Values override files (-f, as a list).")
    ] = None,
    set_values: Annotated[
        list[str] | None, Field(description="Inline overrides as KEY=VALUE (--set, list).")
    ] = None,
    kube_context: Annotated[str | None, Field(description="kubeconfig context name.")] = None,
) -> dict:
    """Render chart manifests without a cluster (helm template)."""
    try:
        argv = helm_render_argv(
            release=release,
            chart_dir=str(invoker.helm_dir()),
            namespace=namespace,
            values_files=values_files,
            set_values=set_values,
            kube_context=kube_context,
        )
    except ValidationError as exc:
        return {"error": str(exc)}
    return _run_helm_sync(argv, kind="render")


@mcp.tool()
def helm_lint(
    values_files: Annotated[
        list[str] | None, Field(description="Values override files (-f, as a list).")
    ] = None,
    set_values: Annotated[
        list[str] | None, Field(description="Inline overrides as KEY=VALUE (--set, list).")
    ] = None,
) -> dict:
    """Statically validate the chart (helm lint)."""
    try:
        argv = helm_lint_argv(
            chart_dir=str(invoker.helm_dir()),
            values_files=values_files,
            set_values=set_values,
        )
    except ValidationError as exc:
        return {"error": str(exc)}
    return _run_helm_sync(argv, kind="lint")


@mcp.tool()
def helm_status(
    release: Annotated[str, Field(description="Helm release name.")],
    namespace: Annotated[str | None, Field(description="Release namespace.")] = None,
    kube_context: Annotated[str | None, Field(description="kubeconfig context name.")] = None,
) -> dict:
    """Report the deployment status of a release (helm status)."""
    try:
        argv = helm_status_argv(
            release=release, namespace=namespace, kube_context=kube_context
        )
    except ValidationError as exc:
        return {"error": str(exc)}
    return _run_helm_sync(argv, kind="status")


@mcp.tool()
def helm_list(
    namespace: Annotated[str | None, Field(description="Namespace to list.")] = None,
    all_namespaces: Annotated[bool, Field(description="List across all namespaces.")] = False,
    kube_context: Annotated[str | None, Field(description="kubeconfig context name.")] = None,
) -> dict:
    """List Helm releases (helm list, JSON output)."""
    try:
        argv = helm_list_argv(
            namespace=namespace, all_namespaces=all_namespaces, kube_context=kube_context
        )
    except ValidationError as exc:
        return {"error": str(exc)}
    return _run_helm_sync(argv, kind="list")


@mcp.tool()
async def helm_deploy(
    release: Annotated[str, Field(description="Helm release name (lowercase RFC 1123).")],
    confirm: Annotated[
        bool, Field(description="Must be true — this mutates the cluster.")
    ] = False,
    namespace: Annotated[str | None, Field(description="Target namespace.")] = None,
    values_files: Annotated[
        list[str] | None, Field(description="Values override files (-f, as a list).")
    ] = None,
    set_values: Annotated[
        list[str] | None, Field(description="Inline overrides as KEY=VALUE (--set, list).")
    ] = None,
    kube_context: Annotated[str | None, Field(description="kubeconfig context name.")] = None,
    create_namespace: Annotated[
        bool, Field(description="Create the namespace if it does not exist.")
    ] = False,
    wait: Annotated[bool, Field(description="Wait for resources to become ready.")] = False,
    timeout: Annotated[str | None, Field(description="Wait timeout, e.g. 5m0s.")] = None,
    atomic: Annotated[bool, Field(description="Roll back on failure (implies wait).")] = False,
    dry_run: Annotated[bool, Field(description="Simulate the deploy server-side.")] = False,
) -> dict:
    """Install or upgrade a release (helm upgrade --install). Async; needs confirm=True."""
    if not confirm and not dry_run:
        return {
            "error": "helm_deploy mutates the cluster; pass confirm=true to proceed.",
            "release": release,
            "namespace": namespace,
            "kube_context": kube_context,
        }
    missing = _helm_missing()
    if missing is not None:
        return missing
    try:
        argv = helm_deploy_argv(
            release=release,
            chart_dir=str(invoker.helm_dir()),
            namespace=namespace,
            values_files=values_files,
            set_values=set_values,
            kube_context=kube_context,
            create_namespace=create_namespace,
            wait=wait,
            timeout=timeout,
            atomic=atomic,
            dry_run=dry_run,
        )
    except ValidationError as exc:
        return {"error": str(exc)}

    command = ["helm", *argv]
    job = await _jobs.start("deploy", command, invoker.helm_dir())
    return {"job_id": job.id, "argv": argv, "command": command, "status": job.status}


@mcp.tool()
async def helm_uninstall(
    release: Annotated[str, Field(description="Helm release name.")],
    confirm: Annotated[
        bool, Field(description="Must be true — this mutates the cluster.")
    ] = False,
    namespace: Annotated[str | None, Field(description="Release namespace.")] = None,
    kube_context: Annotated[str | None, Field(description="kubeconfig context name.")] = None,
    wait: Annotated[bool, Field(description="Wait for resources to be removed.")] = False,
    dry_run: Annotated[bool, Field(description="Simulate the uninstall.")] = False,
) -> dict:
    """Remove a deployed release (helm uninstall). Async; needs confirm=True."""
    if not confirm and not dry_run:
        return {
            "error": "helm_uninstall mutates the cluster; pass confirm=true to proceed.",
            "release": release,
            "namespace": namespace,
            "kube_context": kube_context,
        }
    missing = _helm_missing()
    if missing is not None:
        return missing
    try:
        argv = helm_uninstall_argv(
            release=release, namespace=namespace, kube_context=kube_context,
            wait=wait, dry_run=dry_run,
        )
    except ValidationError as exc:
        return {"error": str(exc)}

    command = ["helm", *argv]
    job = await _jobs.start("uninstall", command, invoker.helm_dir())
    return {"job_id": job.id, "argv": argv, "command": command, "status": job.status}


@mcp.tool()
async def run_helm_tests(
    suite: Annotated[
        str, Field(description="template (no cluster; CI runs this) | integration (needs cluster)")
    ] = "template",
    run: Annotated[str | None, Field(description="Go -run regex to select tests.")] = None,
) -> dict:
    """Run a Kubernetes Go test suite (go test). Returns a job_id to poll."""
    if invoker.which("go") is None:
        return {"error": "go not found on PATH. See the preflight tool."}
    try:
        argv = helm_test_argv(suite=suite, run=run)
    except ValidationError as exc:
        return {"error": str(exc)}

    suite_dir = invoker.helm_tests_dir(suite)
    if not suite_dir.is_dir():
        return {"error": f"test suite dir not found at {suite_dir}. Set BE_TOOLS_HOME."}

    command = ["go", *argv]
    job = await _jobs.start("helm-test", command, suite_dir)
    return {"job_id": job.id, "argv": argv, "command": command, "status": job.status}


# --------------------------------------------------------------------------- #
# Resources
# --------------------------------------------------------------------------- #
@mcp.resource("be://image-types")
def r_image_types() -> str:
    return resources.image_types()


@mcp.resource("be://config-providers")
def r_config_providers() -> str:
    return resources.config_providers()


@mcp.resource("be://build-tools")
def r_build_tools() -> str:
    return resources.build_tools()


@mcp.resource("be://optimize-modules")
def r_optimize_modules() -> str:
    return resources.optimize_module_list()


@mcp.resource("be://help/build-image")
def r_build_image_help() -> str:
    return resources.BUILD_IMAGE_HELP


@mcp.resource("be://help/deploy")
def r_deploy_help() -> str:
    return resources.DEPLOY_HELP


@mcp.resource("be://helm/test-suites")
def r_helm_test_suites() -> str:
    return resources.helm_test_suites()


@mcp.resource("be://helm/values")
def r_helm_values() -> str:
    return resources.helm_values()


# --------------------------------------------------------------------------- #
# Prompts
# --------------------------------------------------------------------------- #
@mcp.prompt()
def containerize_be_app(
    app_location: str = "", source: str = "", tag: str = ""
) -> str:
    """Guided workflow to containerize a BE application."""
    return prompts.containerize_be_app(app_location, source, tag)


@mcp.prompt()
def deploy_be_app(
    release: str = "", namespace: str = "", values_file: str = ""
) -> str:
    """Guided workflow to deploy a BE application to Kubernetes with Helm."""
    return prompts.deploy_be_app(release, namespace, values_file)


def main() -> None:
    mcp.run()


if __name__ == "__main__":
    main()
