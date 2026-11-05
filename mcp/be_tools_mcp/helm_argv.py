"""Validated argv construction for the Helm/deploy tools.

Mirrors :mod:`be_tools_mcp.argv`: every command line is built as a *list* (never
a shell string), release/namespace names are regex-validated, values-file paths
are existence-checked, and ``--set`` entries must be ``KEY=VALUE`` — so there is
no room for shell injection and each function is pure and unit-testable without
``helm``/``go`` installed.

The chart target is the ``cloud/kubernetes/helm`` directory; callers pass its
path as ``chart_dir`` (the server resolves it from ``BE_TOOLS_HOME``).
"""

from __future__ import annotations

from pathlib import Path

from .argv import ValidationError
from .constants import HELM_TEST_SUITES, is_valid_namespace, is_valid_release_name


def _require_release(release: str) -> None:
    if not release:
        raise ValidationError("release is required.")
    if not is_valid_release_name(release):
        raise ValidationError(
            f"Invalid release name [{release}]. Use a lowercase RFC 1123 label "
            "(alphanumeric and '-', starting/ending alphanumeric, <= 53 chars)."
        )


def _validate_namespace(namespace: str | None) -> None:
    if namespace is not None and not is_valid_namespace(namespace):
        raise ValidationError(
            f"Invalid namespace [{namespace}]. Use a lowercase RFC 1123 label "
            "(alphanumeric and '-', starting/ending alphanumeric, <= 63 chars)."
        )


def _common_opts(
    *,
    namespace: str | None = None,
    values_files: list[str] | None = None,
    set_values: list[str] | None = None,
    kube_context: str | None = None,
    check_paths: bool = True,
) -> list[str]:
    """Shared ``--namespace``/``--values``/``--set``/``--kube-context`` options.

    Long options are emitted in ``--key=value`` form to match the repo
    convention and avoid next-token parsing ambiguities.
    """
    _validate_namespace(namespace)
    opts: list[str] = []
    if namespace:
        opts.append(f"--namespace={namespace}")
    if kube_context:
        opts.append(f"--kube-context={kube_context}")
    for vf in values_files or []:
        if check_paths and not Path(vf).is_file():
            raise ValidationError(f"values file [{vf}] does not exist.")
        opts.append(f"--values={vf}")
    for sv in set_values or []:
        if "=" not in sv:
            raise ValidationError(f"Invalid --set entry [{sv}]; expected KEY=VALUE.")
        opts.append(f"--set={sv}")
    return opts


def helm_render_argv(
    *,
    release: str,
    chart_dir: str,
    namespace: str | None = None,
    values_files: list[str] | None = None,
    set_values: list[str] | None = None,
    kube_context: str | None = None,
    check_paths: bool = True,
) -> list[str]:
    """``helm template RELEASE CHART`` — render manifests without a cluster."""
    _require_release(release)
    argv = ["template", release, chart_dir]
    argv += _common_opts(
        namespace=namespace,
        values_files=values_files,
        set_values=set_values,
        kube_context=kube_context,
        check_paths=check_paths,
    )
    return argv


def helm_lint_argv(
    *,
    chart_dir: str,
    values_files: list[str] | None = None,
    set_values: list[str] | None = None,
    check_paths: bool = True,
) -> list[str]:
    """``helm lint CHART`` — static validation of the chart."""
    argv = ["lint", chart_dir]
    argv += _common_opts(
        values_files=values_files,
        set_values=set_values,
        check_paths=check_paths,
    )
    return argv


def helm_dep_update_argv(*, chart_dir: str) -> list[str]:
    """``helm dependency update CHART`` — fetch subchart dependencies."""
    return ["dependency", "update", chart_dir]


def helm_deploy_argv(
    *,
    release: str,
    chart_dir: str,
    namespace: str | None = None,
    values_files: list[str] | None = None,
    set_values: list[str] | None = None,
    kube_context: str | None = None,
    create_namespace: bool = False,
    wait: bool = False,
    timeout: str | None = None,
    atomic: bool = False,
    dry_run: bool = False,
    check_paths: bool = True,
) -> list[str]:
    """``helm upgrade RELEASE CHART --install`` — idempotent install/upgrade."""
    _require_release(release)
    argv = ["upgrade", release, chart_dir, "--install"]
    argv += _common_opts(
        namespace=namespace,
        values_files=values_files,
        set_values=set_values,
        kube_context=kube_context,
        check_paths=check_paths,
    )
    if create_namespace:
        argv.append("--create-namespace")
    if wait:
        argv.append("--wait")
    if timeout:
        argv.append(f"--timeout={timeout}")
    if atomic:
        argv.append("--atomic")
    if dry_run:
        argv.append("--dry-run")
    return argv


def helm_uninstall_argv(
    *,
    release: str,
    namespace: str | None = None,
    kube_context: str | None = None,
    wait: bool = False,
    dry_run: bool = False,
) -> list[str]:
    """``helm uninstall RELEASE`` — remove a deployed release."""
    _require_release(release)
    argv = ["uninstall", release]
    argv += _common_opts(namespace=namespace, kube_context=kube_context)
    if wait:
        argv.append("--wait")
    if dry_run:
        argv.append("--dry-run")
    return argv


def helm_status_argv(
    *,
    release: str,
    namespace: str | None = None,
    kube_context: str | None = None,
    output: str | None = None,
) -> list[str]:
    """``helm status RELEASE`` — report a release's deployment status."""
    _require_release(release)
    argv = ["status", release]
    argv += _common_opts(namespace=namespace, kube_context=kube_context)
    if output:
        argv.append(f"--output={output}")
    return argv


def helm_list_argv(
    *,
    namespace: str | None = None,
    all_namespaces: bool = False,
    kube_context: str | None = None,
    output: str | None = "json",
) -> list[str]:
    """``helm list`` — list releases (defaults to JSON output)."""
    argv = ["list"]
    if all_namespaces:
        argv.append("--all-namespaces")
    argv += _common_opts(namespace=namespace, kube_context=kube_context)
    if output:
        argv.append(f"--output={output}")
    return argv


def helm_test_argv(*, suite: str, run: str | None = None, verbose: bool = True) -> list[str]:
    """``go test`` argv for a Kubernetes test suite (``template``/``integration``).

    Returns the arguments after ``go``; the working directory (the suite folder)
    is chosen by the invoker.
    """
    if suite not in HELM_TEST_SUITES:
        raise ValidationError(
            f"Invalid test suite [{suite}]. Must be one of {', '.join(HELM_TEST_SUITES)}."
        )
    argv = ["test"]
    if verbose:
        argv.append("-v")
    if run:
        argv.append(f"-run={run}")
    argv.append("./...")
    return argv
