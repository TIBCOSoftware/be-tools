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


# --- per-image-type coverage -------------------------------------------------

from be_tools_mcp.argv import ValidationError  # noqa: E402


@pytest.mark.parametrize("image_type", ["rms", "teagent", "s2ibuilder", "base"])
def test_types_without_required_app_location(image_type):
    argv = build_image_argv(image_type=image_type)
    assert argv[0] == f"--image-type={image_type}"
    assert not any(a.startswith("--app-location") for a in argv)


@pytest.mark.parametrize("image_type", ["teagent", "s2ibuilder", "base"])
def test_app_location_ignored_for_non_app_types(image_type, tmp_path):
    argv = build_image_argv(image_type=image_type, app_location=str(tmp_path))
    assert not any(a.startswith("--app-location") for a in argv)


def test_rms_accepts_optional_app_location(tmp_path):
    (tmp_path / "a.cdd").write_text("")
    (tmp_path / "a.ear").write_text("")
    argv = build_image_argv(image_type="rms", app_location=str(tmp_path))
    assert any(a.startswith("--app-location=") for a in argv)


@pytest.mark.parametrize("image_type", ["app", "base", "s2ibuilder"])
def test_disable_tests_honoured(image_type, tmp_path):
    (tmp_path / "a.cdd").write_text("")
    (tmp_path / "a.ear").write_text("")
    argv = build_image_argv(
        image_type=image_type, app_location=str(tmp_path), disable_tests=True
    )
    assert "--disable-tests" in argv


def test_disable_tests_ignored_for_teagent():
    assert "--disable-tests" not in build_image_argv(image_type="teagent", disable_tests=True)


@pytest.mark.parametrize("image_type", ["app", "rms", "teagent", "base"])
def test_buildah_allowed_except_s2i(image_type, tmp_path):
    (tmp_path / "a.cdd").write_text("")
    (tmp_path / "a.ear").write_text("")
    argv = build_image_argv(image_type=image_type, app_location=str(tmp_path), build_tool="buildah")
    assert "--build-tool=buildah" in argv


@pytest.mark.parametrize("installer", ["native", "universal"])
def test_installer_type(installer):
    argv = build_image_argv(image_type="rms", installer_type=installer)
    assert f"--installer-type={installer}" in argv


def test_installer_type_omitted_by_default():
    assert not any(a.startswith("--installer-type") for a in build_image_argv(image_type="base"))


def test_invalid_installer_type():
    with pytest.raises(ValidationError):
        build_image_argv(image_type="base", installer_type="msi")


@pytest.mark.parametrize("image_type", ["app", "s2ibuilder", "rms", "teagent"])
def test_run_tests_all_supported_types(image_type):
    argv = run_tests_argv(image_name="x:1", be_version="7.0", image_type=image_type)
    assert f"--image-type={image_type}" in argv


from be_tools_mcp.argv import build_image_warnings, resolve_installer_type  # noqa: E402


def test_resolve_installer_defaults_by_version():
    assert resolve_installer_type(None, "7.0.0") == "native"
    assert resolve_installer_type(None, "6.3.0") == "universal"
    assert resolve_installer_type(None, None) is None
    assert resolve_installer_type("universal", "7.0.0") == "universal"


def test_native_rejected_below_7():
    with pytest.raises(ValidationError):
        resolve_installer_type("native", "6.3.0")


def test_bad_be_version():
    with pytest.raises(ValidationError):
        resolve_installer_type(None, "abc")


def test_warnings_native_rms():
    w = build_image_warnings(image_type="rms", installer_type="native", openjdk=True, optimize=True)
    assert len(w) == 4


def test_no_warnings_for_universal_or_unknown():
    assert build_image_warnings(image_type="rms", installer_type="universal", openjdk=True) == []
    assert build_image_warnings(image_type="rms", installer_type=None, openjdk=True) == []


def test_warning_custom_dockerfile_for_native_rms():
    w = build_image_warnings(image_type="rms", installer_type="native", docker_file="D")
    assert any("final-native" in m for m in w)
