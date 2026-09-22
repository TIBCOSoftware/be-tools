"""OS-aware locator for the be-tools scripts and the subprocess launch command.

The server assumes the host can already run the scripts by hand. ``BE_TOOLS_HOME``
points at the be-tools checkout (the directory containing ``cloud/``); it defaults
to the repo root two levels above this package.
"""

from __future__ import annotations

import os
import shutil
import subprocess
from pathlib import Path


def be_tools_home() -> Path:
    """Root of the be-tools checkout (contains ``cloud/``)."""
    env = os.environ.get("BE_TOOLS_HOME")
    if env:
        return Path(env).expanduser()
    # be_tools_mcp/ -> mcp/ -> <repo root>
    return Path(__file__).resolve().parents[2]


def docker_dir() -> Path:
    return be_tools_home() / "cloud" / "docker"


def tests_dir() -> Path:
    return docker_dir() / "tests"


def kubernetes_dir() -> Path:
    return be_tools_home() / "cloud" / "kubernetes"


def helm_dir() -> Path:
    """The Helm chart directory (``helm template``/``install`` target)."""
    return kubernetes_dir() / "helm"


def helm_tests_dir(suite: str) -> Path:
    """Directory of a Go test suite (``template`` or ``integration``)."""
    return kubernetes_dir() / "tests" / suite


def _resolve_script(directory: Path, base: str) -> Path:
    """Locate a be-tools script, preferring the host OS variant.

    Windows prefers ``.bat`` and other hosts prefer ``.sh``, but not every
    script ships both variants (e.g. ``run_tests`` is ``.sh`` only). When the
    preferred variant is absent, fall back to the one that exists so a Windows
    host can still run a ``.sh`` through ``bash`` (see :func:`launch_command`).
    If neither exists, return the preferred path so errors name the expected
    file.
    """
    preferred, fallback = (".bat", ".sh") if os.name == "nt" else (".sh", ".bat")
    preferred_path = directory / f"{base}{preferred}"
    if preferred_path.exists():
        return preferred_path
    fallback_path = directory / f"{base}{fallback}"
    if fallback_path.exists():
        return fallback_path
    return preferred_path


def build_image_script() -> Path:
    return _resolve_script(docker_dir(), "build_image")


def run_tests_script() -> Path:
    return _resolve_script(tests_dir(), "run_tests")


def launch_command(script: Path, argv: list[str]) -> list[str]:
    """Full argv to launch ``script`` with ``argv``, picking the right interpreter.

    ``.bat`` files run through ``cmd /c``; ``.sh`` files through ``bash`` so we do
    not depend on the execute bit being set on a checked-out tree.
    """
    if script.suffix == ".bat":
        return ["cmd", "/c", str(script), *argv]
    return ["bash", str(script), *argv]


def which(tool: str) -> str | None:
    return shutil.which(tool)


def run_sync(command: list[str], cwd: Path, timeout: int = 600) -> tuple[int, str]:
    """Run ``command`` to completion and return ``(returncode, merged_output)``.

    Used for fast, read-only helm operations (template/lint/status/list) whose
    output is the point of the call; long/mutating operations go through the
    async :class:`~be_tools_mcp.jobs.JobManager` instead.
    """
    try:
        proc = subprocess.run(
            command,
            cwd=str(cwd),
            capture_output=True,
            text=True,
            timeout=timeout,
        )
    except FileNotFoundError:
        return 127, f"Executable not found: {command[0]}"
    except subprocess.TimeoutExpired:
        return 124, f"Command timed out after {timeout}s: {' '.join(command)}"
    return proc.returncode, (proc.stdout or "") + (proc.stderr or "")
