"""Unit tests asserting the exact argv produced for representative flag combos.

No Docker required — this is where most of the correctness lives.
"""

from __future__ import annotations

import os

import pytest

from be_tools_mcp.argv import build_image_argv, run_tests_argv


def test_minimal_app_build(tmp_path):
    (tmp_path / "app.cdd").write_text("")
    (tmp_path / "app.ear").write_text("")
    argv = build_image_argv(
        image_type="app",
        app_location=str(tmp_path),
        tag="myapp:1.0",
    )
    assert argv == [
        "--image-type=app",
        f"--app-location={tmp_path}",
        "--tag=myapp:1.0",
        "--build-tool=docker",
    ]


def test_source_and_config_providers(tmp_path):
    (tmp_path / "a.cdd").write_text("")
    (tmp_path / "a.ear").write_text("")
    argv = build_image_argv(
        image_type="app",
        app_location=str(tmp_path),
        source="/opt/tibco/be/6.1",
        config_provider=["gvconsul", "gvhttp"],
    )
    # A non-existent source (here on Windows) is left untouched: it may be a
    # base image name, not a filesystem path.
    assert "--source=/opt/tibco/be/6.1" in argv
    assert "--config-provider=gvconsul,gvhttp" in argv


def test_app_location_uses_native_separators(tmp_path):
    """Path args are emitted with OS-native separators so build_image.bat (cmd)
    does not mangle forward slashes on Windows."""
    (tmp_path / "a.cdd").write_text("")
    (tmp_path / "a.ear").write_text("")
    forward = str(tmp_path).replace("\\", "/")
    argv = build_image_argv(image_type="app", app_location=forward)
    assert f"--app-location={os.path.normpath(forward)}" in argv


def test_existing_source_path_is_normalized(tmp_path):
    """A source that resolves to a real directory is normalized to native
    separators (an existing BE_HOME), unlike a base image name."""
    (tmp_path / "a.cdd").write_text("")
    (tmp_path / "a.ear").write_text("")
    forward = str(tmp_path).replace("\\", "/")
    argv = build_image_argv(
        image_type="app", app_location=str(tmp_path), source=forward
    )
    assert f"--source={os.path.normpath(forward)}" in argv


def test_optimize_enable_all_uses_empty_value():
    argv = build_image_argv(image_type="base", optimize=True)
    assert "--optimize=" in argv


def test_optimize_with_modules():
    argv = build_image_argv(
        image_type="base",
        optimize_modules_extra=["process", "query"],
    )
    assert "--optimize=process,query" in argv


def test_openjdk_and_disable_tests_are_bare_flags():
    argv = build_image_argv(image_type="base", openjdk=True, disable_tests=True)
    assert "--openjdk" in argv
    assert "--disable-tests" in argv


def test_teagent_drops_tag_and_config_provider():
    argv = build_image_argv(
        image_type="teagent",
        tag="ignored:1",
        config_provider=["gvconsul"],
    )
    assert not any(a.startswith("--tag=") for a in argv)
    assert not any(a.startswith("--config-provider=") for a in argv)


def test_disable_tests_ignored_for_rms():
    argv = build_image_argv(image_type="rms", disable_tests=True)
    assert "--disable-tests" not in argv


def test_run_tests_argv_basic():
    argv = run_tests_argv(image_name="be6:v1", be_version="6.1")
    assert argv == [
        "--image-name=be6:v1",
        "--be-version=6.1",
        "--image-type=app",
    ]


def test_run_tests_argv_full():
    argv = run_tests_argv(
        image_name="be6:v1",
        be_version="6.1",
        as_version="4.5",
        ftl_version="6.5",
        image_type="rms",
        key_value_pairs=["JRE_VERSION=11", "FOO=bar"],
    )
    assert "--as-version=4.5" in argv
    assert "--ftl-version=6.5" in argv
    assert "--image-type=rms" in argv
    assert argv.count("--key-value-pair=JRE_VERSION=11") == 1
    assert "--key-value-pair=FOO=bar" in argv
