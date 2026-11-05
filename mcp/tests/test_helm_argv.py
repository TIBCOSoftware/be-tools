"""Unit + validation tests for the Helm/deploy argv builders.

No helm/go required — this is where the deploy-command correctness lives.
"""

from __future__ import annotations

import pytest

from be_tools_mcp.argv import ValidationError
from be_tools_mcp.helm_argv import (
    helm_dep_update_argv,
    helm_deploy_argv,
    helm_lint_argv,
    helm_list_argv,
    helm_render_argv,
    helm_status_argv,
    helm_test_argv,
    helm_uninstall_argv,
)

CHART = "/be/cloud/kubernetes/helm"


def test_render_minimal():
    argv = helm_render_argv(release="my-be", chart_dir=CHART)
    assert argv == ["template", "my-be", CHART]


def test_render_with_namespace_context_and_sets():
    argv = helm_render_argv(
        release="my-be",
        chart_dir=CHART,
        namespace="be-ns",
        set_values=["mysql.enabled=true", "replicaCount=3"],
        kube_context="staging",
    )
    assert argv[:3] == ["template", "my-be", CHART]
    assert "--namespace=be-ns" in argv
    assert "--kube-context=staging" in argv
    assert "--set=mysql.enabled=true" in argv
    assert "--set=replicaCount=3" in argv


def test_render_values_files_existence_checked(tmp_path):
    vf = tmp_path / "values.yaml"
    vf.write_text("")
    argv = helm_render_argv(release="my-be", chart_dir=CHART, values_files=[str(vf)])
    assert f"--values={vf}" in argv


def test_lint_and_dep_update():
    assert helm_lint_argv(chart_dir=CHART) == ["lint", CHART]
    assert helm_dep_update_argv(chart_dir=CHART) == ["dependency", "update", CHART]


def test_deploy_uses_upgrade_install():
    argv = helm_deploy_argv(
        release="my-be",
        chart_dir=CHART,
        namespace="be-ns",
        create_namespace=True,
        wait=True,
        timeout="5m0s",
        atomic=True,
    )
    assert argv[:4] == ["upgrade", "my-be", CHART, "--install"]
    assert "--create-namespace" in argv
    assert "--wait" in argv
    assert "--timeout=5m0s" in argv
    assert "--atomic" in argv


def test_uninstall():
    argv = helm_uninstall_argv(release="my-be", namespace="be-ns", wait=True)
    assert argv[:2] == ["uninstall", "my-be"]
    assert "--namespace=be-ns" in argv
    assert "--wait" in argv


def test_status_and_list_default_json():
    assert helm_status_argv(release="my-be")[:2] == ["status", "my-be"]
    argv = helm_list_argv(all_namespaces=True)
    assert argv[0] == "list"
    assert "--all-namespaces" in argv
    assert "--output=json" in argv


def test_test_suite_argv():
    assert helm_test_argv(suite="template") == ["test", "-v", "./..."]
    argv = helm_test_argv(suite="integration", run="TestAgents", verbose=False)
    assert argv == ["test", "-run=TestAgents", "./..."]


# --- validation ------------------------------------------------------------- #
def test_release_required():
    with pytest.raises(ValidationError):
        helm_render_argv(release="", chart_dir=CHART)


def test_invalid_release_name():
    with pytest.raises(ValidationError):
        helm_deploy_argv(release="My_Bad_Name", chart_dir=CHART)


def test_invalid_namespace():
    with pytest.raises(ValidationError):
        helm_render_argv(release="my-be", chart_dir=CHART, namespace="Bad_NS")


def test_missing_values_file():
    with pytest.raises(ValidationError):
        helm_render_argv(release="my-be", chart_dir=CHART, values_files=["/no/such.yaml"])


def test_set_requires_equals():
    with pytest.raises(ValidationError):
        helm_deploy_argv(release="my-be", chart_dir=CHART, set_values=["NOEQUALS"])


def test_invalid_test_suite():
    with pytest.raises(ValidationError):
        helm_test_argv(suite="bogus")
