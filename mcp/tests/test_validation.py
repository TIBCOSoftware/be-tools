"""Validation tests: .cdd/.ear rule, enum checks, buildah restrictions."""

from __future__ import annotations

import os

import pytest

from be_tools_mcp.argv import ValidationError, build_image_argv, run_tests_argv


def test_invalid_image_type():
    with pytest.raises(ValidationError):
        build_image_argv(image_type="bogus")


def test_invalid_build_tool():
    with pytest.raises(ValidationError):
        build_image_argv(image_type="base", build_tool="podman")


def test_app_requires_app_location():
    with pytest.raises(ValidationError):
        build_image_argv(image_type="app")


def test_buildah_cannot_build_s2ibuilder():
    with pytest.raises(ValidationError):
        build_image_argv(image_type="s2ibuilder", build_tool="buildah")


def test_app_location_must_be_dir():
    with pytest.raises(ValidationError):
        build_image_argv(image_type="app", app_location="/no/such/dir")


def test_app_location_needs_exactly_one_cdd_and_ear(tmp_path):
    (tmp_path / "a.cdd").write_text("")
    # no ear
    with pytest.raises(ValidationError):
        build_image_argv(image_type="app", app_location=str(tmp_path))

    (tmp_path / "a.ear").write_text("")
    (tmp_path / "b.ear").write_text("")
    # two ears
    with pytest.raises(ValidationError):
        build_image_argv(image_type="app", app_location=str(tmp_path))


def test_check_paths_can_be_disabled():
    argv = build_image_argv(
        image_type="app", app_location="/no/such/dir", check_paths=False
    )
    # On Windows the path separators are normalized for cmd/build_image.bat.
    expected = os.path.normpath("/no/such/dir")
    assert f"--app-location={expected}" in argv


def test_invalid_config_provider(tmp_path):
    (tmp_path / "a.cdd").write_text("")
    (tmp_path / "a.ear").write_text("")
    with pytest.raises(ValidationError):
        build_image_argv(
            image_type="app",
            app_location=str(tmp_path),
            config_provider=["vault"],
        )


def test_unknown_optimize_module():
    with pytest.raises(ValidationError):
        build_image_argv(image_type="base", optimize_modules_extra=["not-a-module"])


def test_run_tests_requires_image_and_version():
    with pytest.raises(ValidationError):
        run_tests_argv(image_name="", be_version="6.1")
    with pytest.raises(ValidationError):
        run_tests_argv(image_name="be6:v1", be_version="")


def test_run_tests_invalid_image_type():
    with pytest.raises(ValidationError):
        run_tests_argv(image_name="be6:v1", be_version="6.1", image_type="base")


def test_run_tests_invalid_kv():
    with pytest.raises(ValidationError):
        run_tests_argv(
            image_name="be6:v1", be_version="6.1", key_value_pairs=["NOEQUALS"]
        )
