"""Unit tests for OS-aware script resolution.

No Docker required. Exercises the ``.bat``/``.sh`` fallback so a Windows host
still finds scripts that ship only as ``.sh`` (e.g. ``run_tests``).
"""

from __future__ import annotations

import pytest

from be_tools_mcp import invoker


def test_prefers_host_variant(tmp_path, monkeypatch):
    (tmp_path / "foo.bat").write_text("")
    (tmp_path / "foo.sh").write_text("")
    monkeypatch.setattr(invoker.os, "name", "nt")
    assert invoker._resolve_script(tmp_path, "foo").name == "foo.bat"
    monkeypatch.setattr(invoker.os, "name", "posix")
    assert invoker._resolve_script(tmp_path, "foo").name == "foo.sh"


def test_falls_back_when_preferred_missing(tmp_path, monkeypatch):
    # Only the .sh exists (the run_tests case): a Windows host must still find it.
    (tmp_path / "run_tests.sh").write_text("")
    monkeypatch.setattr(invoker.os, "name", "nt")
    assert invoker._resolve_script(tmp_path, "run_tests").name == "run_tests.sh"


def test_returns_preferred_path_when_neither_exists(tmp_path, monkeypatch):
    monkeypatch.setattr(invoker.os, "name", "nt")
    assert invoker._resolve_script(tmp_path, "missing").name == "missing.bat"


def test_launch_command_picks_interpreter(tmp_path):
    bat = tmp_path / "x.bat"
    sh = tmp_path / "x.sh"
    assert invoker.launch_command(bat, ["-h"]) == ["cmd", "/c", str(bat), "-h"]
    assert invoker.launch_command(sh, ["-h"]) == ["bash", str(sh), "-h"]
