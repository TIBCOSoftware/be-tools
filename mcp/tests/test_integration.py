"""Gated integration smoke test.

Runs the real build_image + run_tests scripts. Skipped unless
BE_TOOLS_MCP_INTEGRATION=1 and the required env is present:

  BE_TOOLS_MCP_APP_LOCATION  BE app dir with one .cdd + one .ear
  BE_TOOLS_MCP_SOURCE        BE_HOME or installers dir
  BE_TOOLS_MCP_TAG           image tag to build (default: be-tools-mcp-smoke:test)
  BE_TOOLS_MCP_BE_VERSION    BE short version for the test run (e.g. 6.1)
"""

from __future__ import annotations

import asyncio
import os

import pytest

from be_tools_mcp import invoker
from be_tools_mcp.argv import build_image_argv, run_tests_argv
from be_tools_mcp.jobs import JobManager

pytestmark = pytest.mark.skipif(
    os.environ.get("BE_TOOLS_MCP_INTEGRATION") != "1",
    reason="set BE_TOOLS_MCP_INTEGRATION=1 to run the gated integration smoke test",
)


async def _run(kind, script, argv, cwd):
    jobs = JobManager()
    job = await jobs.start(kind, invoker.launch_command(script, argv), cwd)
    while job.status == "running":
        await asyncio.sleep(2)
    return job


def test_build_then_test_smoke():
    app_location = os.environ["BE_TOOLS_MCP_APP_LOCATION"]
    source = os.environ["BE_TOOLS_MCP_SOURCE"]
    tag = os.environ.get("BE_TOOLS_MCP_TAG", "be-tools-mcp-smoke:test")
    be_version = os.environ["BE_TOOLS_MCP_BE_VERSION"]

    build_argv = build_image_argv(
        image_type="app",
        app_location=app_location,
        source=source,
        tag=tag,
        disable_tests=True,
    )
    build_job = asyncio.run(
        _run("build", invoker.build_image_script(), build_argv, invoker.docker_dir())
    )
    assert build_job.status == "succeeded", build_job.log_tail()

    test_argv = run_tests_argv(image_name=tag, be_version=be_version)
    test_job = asyncio.run(
        _run("test", invoker.run_tests_script(), test_argv, invoker.tests_dir())
    )
    assert test_job.status == "succeeded", test_job.log_tail()
