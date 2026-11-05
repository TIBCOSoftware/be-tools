"""Allowed-value lists and derived option data.

These mirror the checks in ``cloud/docker/build_image.sh`` / ``.bat`` and
``cloud/docker/tests/run_tests.sh``. Keep them in lockstep with those scripts.
"""

from __future__ import annotations

import json
import re
from functools import lru_cache
from pathlib import Path

# build_image.sh: -i/--image-type
IMAGE_TYPES: tuple[str, ...] = ("app", "rms", "teagent", "s2ibuilder", "base")

# run_tests.sh: --image-type (no "base")
TEST_IMAGE_TYPES: tuple[str, ...] = ("app", "s2ibuilder", "rms", "teagent")

# build_image.sh: --config-provider
CONFIG_PROVIDERS: tuple[str, ...] = ("gvconsul", "gvhttp", "gvcyberark", "cmcncf", "custom")

# build_image.sh: -b/--build-tool
BUILD_TOOLS: tuple[str, ...] = ("docker", "buildah")

# --disable-tests is honoured only for these image types (see build_image.sh usage).
DISABLE_TESTS_IMAGE_TYPES: tuple[str, ...] = ("app", "base", "s2ibuilder")

# --------------------------------------------------------------------------- #
# Helm / deploy (cloud/kubernetes)
# --------------------------------------------------------------------------- #
# Go test suites under cloud/kubernetes/tests. "template" is what CI runs and
# needs no cluster; "integration" needs a live cluster + published images.
HELM_TEST_SUITES: tuple[str, ...] = ("template", "integration")

# Helm release names: RFC 1123 label, <= 53 chars (leaves room for suffixes).
_RELEASE_NAME_RE = re.compile(r"^[a-z0-9]([a-z0-9-]{0,51}[a-z0-9])?$")

# Kubernetes namespace: RFC 1123 label, <= 63 chars.
_NAMESPACE_RE = re.compile(r"^[a-z0-9]([a-z0-9-]{0,61}[a-z0-9])?$")


def is_valid_release_name(name: str) -> bool:
    """True if ``name`` is a valid Helm release name."""
    return bool(_RELEASE_NAME_RE.match(name))


def is_valid_namespace(name: str) -> bool:
    """True if ``name`` is a valid Kubernetes namespace."""
    return bool(_NAMESPACE_RE.match(name))


# Fallback module list, used only if lib/optimize.json cannot be read.
_FALLBACK_OPTIMIZE_MODULES: tuple[str, ...] = (
    "analytics", "as2", "as4", "cassandra", "eclipse", "ftl", "http", "ignite",
    "influx", "java", "kafka", "kinesis", "liveview", "mqtt", "opentelemetry",
    "pattern", "process", "pulsar", "query", "soap", "sqlserver", "store", "streambase",
)


@lru_cache(maxsize=8)
def optimize_modules(docker_lib_dir: str | None = None) -> tuple[str, ...]:
    """Supported ``--optimize`` module names.

    Parsed from ``cloud/docker/lib/optimize.json`` (the same source the Perl
    optimizer reads) so the resource stays accurate without needing Perl/Docker.
    """
    if docker_lib_dir is not None:
        optimize_json = Path(docker_lib_dir) / "optimize.json"
        try:
            data = json.loads(optimize_json.read_text(encoding="utf-8"))
            modules = data.get("modules")
            if isinstance(modules, dict) and modules:
                return tuple(sorted(modules.keys()))
        except (OSError, ValueError):
            pass
    return _FALLBACK_OPTIMIZE_MODULES
