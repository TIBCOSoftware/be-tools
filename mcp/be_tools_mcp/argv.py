"""Validated argv construction for build_image and run_tests.

All command lines are built as *lists* (never shell strings), enum fields are
allowlisted, and paths are existence-checked, so there is no room for shell
injection. Every function here is pure and unit-testable without Docker.

Long options are emitted in ``--key=value`` form, matching the repo convention
("supply long options with '='") and avoiding the scripts' next-token parsing.
"""

from __future__ import annotations

import os
from pathlib import Path

from .constants import (
    BUILD_TOOLS,
    CONFIG_PROVIDERS,
    DISABLE_TESTS_IMAGE_TYPES,
    INSTALLER_TYPES,
    IMAGE_TYPES,
    TEST_IMAGE_TYPES,
    optimize_modules,
)


class ValidationError(ValueError):
    """Raised when inputs fail a server-side check before shelling out."""


def _native_path(value: str, *, only_if_exists: bool = False) -> str:
    """Return ``value`` with OS-native path separators.

    ``build_image.bat`` runs under ``cmd``, which mishandles forward slashes in
    path arguments (a leading ``/t`` in ``C:/tibcohome/...`` is parsed as a
    switch, and PowerShell copies of the app dir then fail). The same argv is
    launched for both the ``.sh`` and ``.bat`` variants, so normalize to the
    host separator. On non-Windows hosts this is a no-op.

    ``only_if_exists`` guards values that may not be filesystem paths at all
    (``source`` can be a base image name like ``registry/be:1.0``); such values
    are left untouched so their slashes survive.
    """
    if os.name != "nt":
        return value
    if only_if_exists and not Path(value).exists():
        return value
    return value.replace("/", "\\")


def _require_one_cdd_and_ear(app_location: Path) -> tuple[str, str]:
    """Enforce the be-tools rule: exactly one .cdd and one .ear in the app dir."""
    cdds = sorted(app_location.glob("*.cdd"))
    ears = sorted(app_location.glob("*.ear"))
    if len(cdds) != 1:
        raise ValidationError(
            f"App location [{app_location}] must contain exactly one .cdd file "
            f"(found {len(cdds)})."
        )
    if len(ears) != 1:
        raise ValidationError(
            f"App location [{app_location}] must contain exactly one .ear file "
            f"(found {len(ears)})."
        )
    return cdds[0].name, ears[0].name


def build_image_argv(
    *,
    image_type: str,
    app_location: str | None = None,
    source: str | None = None,
    tag: str | None = None,
    docker_file: str | None = None,
    config_provider: list[str] | None = None,
    disable_tests: bool = False,
    build_tool: str = "docker",
    openjdk: bool = False,
    optimize: bool = False,
    optimize_modules_extra: list[str] | None = None,
    installer_type: str | None = None,
    check_paths: bool = True,
    docker_lib_dir: str | None = None,
) -> list[str]:
    """Validate build inputs and return the argv for ``build_image.sh``/``.bat``.

    ``optimize=True`` enables optimization (auto-detected from the CDD/EAR).
    ``optimize_modules_extra`` names additional modules to strip; passing it
    implies ``optimize`` is on.
    """
    # --- enum checks -------------------------------------------------------
    if image_type not in IMAGE_TYPES:
        raise ValidationError(
            f"Invalid image_type [{image_type}]. Must be one of {', '.join(IMAGE_TYPES)}."
        )
    if build_tool not in BUILD_TOOLS:
        raise ValidationError(
            f"Invalid build_tool [{build_tool}]. Must be one of {', '.join(BUILD_TOOLS)}."
        )

    if installer_type is not None and installer_type not in INSTALLER_TYPES:
        raise ValidationError(
            f"Invalid installer_type [{installer_type}]. Must be one of "
            f"{', '.join(INSTALLER_TYPES)}."
        )

    # --- buildah restrictions ---------------------------------------------
    if build_tool == "buildah" and image_type == "s2ibuilder":
        raise ValidationError("s2ibuilder image is not supported with the buildah build tool.")

    # --- app_location by-type rules ---------------------------------------
    # Ignored entirely for these types (build_image.sh clears ARG_APP_LOCATION).
    if image_type in ("teagent", "s2ibuilder", "base"):
        app_location = None
    elif image_type == "app" and not app_location:
        raise ValidationError("app_location is required when image_type is 'app'.")

    if app_location is not None:
        app_path = Path(app_location)
        if check_paths:
            if not app_path.is_dir():
                raise ValidationError(f"app_location [{app_location}] is not a directory.")
            _require_one_cdd_and_ear(app_path)

    # --- docker_file existence --------------------------------------------
    if docker_file is not None and check_paths and not Path(docker_file).is_file():
        raise ValidationError(f"docker_file [{docker_file}] does not exist.")

    # --- config provider checks -------------------------------------------
    # Config providers are ignored for teagent images.
    if image_type == "teagent":
        config_provider = None
    if config_provider:
        for cp in config_provider:
            if cp not in CONFIG_PROVIDERS:
                raise ValidationError(
                    f"Invalid config_provider [{cp}]. Must be one of "
                    f"{', '.join(CONFIG_PROVIDERS)}."
                )

    # --- optimize module checks -------------------------------------------
    extra = optimize_modules_extra or []
    if extra:
        optimize = True
        supported = optimize_modules(docker_lib_dir)
        for mod in extra:
            if mod not in supported:
                raise ValidationError(
                    f"Unknown optimize module [{mod}]. Supported modules: "
                    f"{', '.join(supported)}."
                )

    # --- assemble argv -----------------------------------------------------
    argv: list[str] = [f"--image-type={image_type}"]

    if app_location is not None:
        argv.append(f"--app-location={_native_path(app_location)}")
    if source:
        # source may be a BE_HOME/installers path or a base image name.
        argv.append(f"--source={_native_path(source, only_if_exists=True)}")
    # -t/--tag is ignored for teagent images.
    if tag and image_type != "teagent":
        argv.append(f"--tag={tag}")
    if docker_file:
        argv.append(f"--docker-file={_native_path(docker_file)}")
    if config_provider:
        argv.append(f"--config-provider={','.join(config_provider)}")
    argv.append(f"--build-tool={build_tool}")
    if installer_type:
        argv.append(f"--installer-type={installer_type}")
    if openjdk:
        argv.append("--openjdk")
    # --disable-tests is only meaningful for app/base/s2ibuilder.
    if disable_tests and image_type in DISABLE_TESTS_IMAGE_TYPES:
        argv.append("--disable-tests")
    if optimize:
        # "--optimize=" (empty) enables auto-detection; a CSV adds explicit modules.
        argv.append(f"--optimize={','.join(extra)}")

    return argv


def run_tests_argv(
    *,
    image_name: str,
    be_version: str,
    as_legacy_version: str | None = None,
    as_version: str | None = None,
    ftl_version: str | None = None,
    hawk_version: str | None = None,
    tea_version: str | None = None,
    config_provider: str | None = None,
    image_type: str = "app",
    java_dir_name: str | None = None,
    key_value_pairs: list[str] | None = None,
) -> list[str]:
    """Validate test inputs and return the argv for ``run_tests.sh``/``.bat``."""
    if not image_name:
        raise ValidationError("image_name is required.")
    if not be_version:
        raise ValidationError("be_version is required.")
    if image_type not in TEST_IMAGE_TYPES:
        raise ValidationError(
            f"Invalid image_type [{image_type}]. Must be one of "
            f"{', '.join(TEST_IMAGE_TYPES)}."
        )
    if config_provider is not None and config_provider not in CONFIG_PROVIDERS:
        raise ValidationError(
            f"Invalid config_provider [{config_provider}]. Must be one of "
            f"{', '.join(CONFIG_PROVIDERS)}."
        )

    for kv in key_value_pairs or []:
        if "=" not in kv:
            raise ValidationError(f"Invalid key-value pair [{kv}]; expected KEY=VALUE.")

    argv: list[str] = [
        f"--image-name={image_name}",
        f"--be-version={be_version}",
        f"--image-type={image_type}",
    ]
    if as_legacy_version:
        argv.append(f"--as-legacy-version={as_legacy_version}")
    if as_version:
        argv.append(f"--as-version={as_version}")
    if ftl_version:
        argv.append(f"--ftl-version={ftl_version}")
    if hawk_version:
        argv.append(f"--hawk-version={hawk_version}")
    if tea_version:
        argv.append(f"--tea-version={tea_version}")
    if config_provider:
        argv.append(f"--config-provider={config_provider}")
    if java_dir_name:
        argv.append(f"--java-dir-name={java_dir_name}")
    for kv in key_value_pairs or []:
        argv.append(f"--key-value-pair={kv}")

    return argv


def _version_tuple(version: str) -> tuple[int, ...]:
    try:
        return tuple(int(p) for p in version.strip().split(".") if p != "")
    except ValueError:
        raise ValidationError(f"Invalid be_version [{version}]; expected x.x or x.x.x.") from None


def resolve_installer_type(installer_type: str | None, be_version: str | None) -> str | None:
    """Effective installer type, mirroring build_image.sh defaulting.

    The script defaults to ``native`` for BE >= 7.0.0 and ``universal`` below, and
    rejects ``native`` below 7.0.0. Without ``be_version`` an unset type is unknown
    (``None``) because the script derives the version from the installers.
    """
    if installer_type is not None and installer_type not in INSTALLER_TYPES:
        raise ValidationError(
            f"Invalid installer_type [{installer_type}]. Must be one of "
            f"{', '.join(INSTALLER_TYPES)}."
        )
    if be_version is None:
        return installer_type
    is_native_capable = _version_tuple(be_version) >= (7, 0)
    if installer_type == "native" and not is_native_capable:
        raise ValidationError(
            f"installer_type 'native' requires BE 7.0.0 or above (be_version [{be_version}])."
        )
    return installer_type or ("native" if is_native_capable else "universal")


def build_image_warnings(
    *,
    image_type: str,
    installer_type: str | None,
    openjdk: bool = False,
    optimize: bool = False,
    optimize_modules_extra: list[str] | None = None,
    docker_file: str | None = None,
) -> list[str]:
    """Options the script will silently ignore for the effective installer type."""
    warnings: list[str] = []
    if installer_type == "native":
        if openjdk:
            warnings.append("openjdk is ignored: the native installer bundles its own JRE.")
        if image_type == "rms" and (optimize or optimize_modules_extra):
            warnings.append(
                "optimize is ignored for the Quarkus RMS image (native installer)."
            )
        if image_type == "rms":
            warnings.append(
                "The native Quarkus RMS image skips post-build tests; run_image_tests "
                "does not apply to it."
            )
            warnings.append(
                "The Quarkus RMS image is not a BE engine and needs an external PostgreSQL; "
                "configure it with RMS_DB_HOST/RMS_DB_PORT/RMS_DB_NAME, RMS_DB_USER/"
                "RMS_DB_PASSWORD and RMS_BOOTSTRAP_ADMIN_* env vars, and mount a volume on "
                "the instance directory."
            )
            if docker_file:
                warnings.append(
                    "build_image passes --target final-native for native rms; the custom "
                    "docker_file must define a 'final-native' stage."
                )
    return warnings
