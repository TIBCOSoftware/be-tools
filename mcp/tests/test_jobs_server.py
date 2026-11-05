"""Job manager lifecycle and server registration tests (no Docker/helm needed)."""

from __future__ import annotations

import asyncio
import sys
from pathlib import Path

from be_tools_mcp import server
from be_tools_mcp.jobs import JobManager

EXPECTED_TOOLS = {
    "preflight", "build_be_image", "run_image_tests", "get_job_status", "get_job_logs",
    "cancel_job", "helm_dep_update", "helm_render", "helm_lint", "helm_status",
    "helm_list", "helm_deploy", "helm_uninstall", "run_helm_tests",
}


async def _wait(jobs: JobManager, job_id: str) -> None:
    job = jobs.get(job_id)
    await asyncio.wait_for(job._task, timeout=30)


async def test_job_success_captures_log():
    jobs = JobManager()
    job = await jobs.start("test", [sys.executable, "-c", "print('hello')"], Path.cwd())
    await _wait(jobs, job.id)
    assert job.status == "succeeded"
    assert job.returncode == 0
    assert "hello" in job.log_tail()


async def test_job_failure_status():
    jobs = JobManager()
    job = await jobs.start("test", [sys.executable, "-c", "raise SystemExit(3)"], Path.cwd())
    await _wait(jobs, job.id)
    assert job.status == "failed"
    assert job.returncode == 3


async def test_job_cancel():
    jobs = JobManager()
    job = await jobs.start(
        "test", [sys.executable, "-c", "import time; time.sleep(60)"], Path.cwd()
    )
    assert await jobs.cancel(job.id) is True
    await _wait(jobs, job.id)
    assert job.status == "cancelled"
    assert await jobs.cancel(job.id) is False
    assert await jobs.cancel("missing") is False


async def test_server_registers_tools_resources_prompts():
    mcp = server.mcp
    assert EXPECTED_TOOLS <= {t.name for t in await mcp.list_tools()}
    assert {"containerize_be_app", "deploy_be_app"} <= {
        p.name for p in await mcp.list_prompts()
    }
    uris = {str(r.uri) for r in await mcp.list_resources()}
    assert {"be://image-types", "be://helm/values", "be://help/build-image"} <= uris
