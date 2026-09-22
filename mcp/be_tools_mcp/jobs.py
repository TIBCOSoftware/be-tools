"""Async job manager for long-running builds and tests.

Image builds take minutes, so build/test tools start a job and return a
``job_id``; callers poll status/logs and can cancel. Jobs run as child
processes with their stdout/stderr merged into a rolling in-memory buffer.
"""

from __future__ import annotations

import asyncio
import uuid
from collections import deque
from dataclasses import dataclass, field
from pathlib import Path
from typing import Literal

JobStatus = Literal["running", "succeeded", "failed", "cancelled"]

# Cap the retained log so a chatty build cannot grow memory without bound.
_MAX_LOG_LINES = 5000


@dataclass
class Job:
    id: str
    kind: str  # "build" | "test"
    command: list[str]
    cwd: str
    status: JobStatus = "running"
    returncode: int | None = None
    _log: deque[str] = field(default_factory=lambda: deque(maxlen=_MAX_LOG_LINES))
    _proc: asyncio.subprocess.Process | None = None
    _task: asyncio.Task | None = None

    def snapshot(self) -> dict:
        return {
            "job_id": self.id,
            "kind": self.kind,
            "status": self.status,
            "returncode": self.returncode,
            "command": self.command,
            "cwd": self.cwd,
            "log_lines": len(self._log),
        }

    def log_tail(self, tail: int = 200) -> str:
        lines = list(self._log)
        if tail > 0:
            lines = lines[-tail:]
        return "\n".join(lines)


class JobManager:
    """In-memory registry of running/finished jobs for one server process."""

    def __init__(self) -> None:
        self._jobs: dict[str, Job] = {}

    async def start(self, kind: str, command: list[str], cwd: Path) -> Job:
        job = Job(id=uuid.uuid4().hex[:12], kind=kind, command=command, cwd=str(cwd))
        self._jobs[job.id] = job
        proc = await asyncio.create_subprocess_exec(
            *command,
            cwd=str(cwd),
            stdout=asyncio.subprocess.PIPE,
            stderr=asyncio.subprocess.STDOUT,
        )
        job._proc = proc
        job._task = asyncio.create_task(self._pump(job))
        return job

    async def _pump(self, job: Job) -> None:
        assert job._proc is not None
        stream = job._proc.stdout
        if stream is not None:
            while True:
                raw = await stream.readline()
                if not raw:
                    break
                job._log.append(raw.decode("utf-8", errors="replace").rstrip("\n"))
        rc = await job._proc.wait()
        job.returncode = rc
        if job.status == "cancelled":
            return
        job.status = "succeeded" if rc == 0 else "failed"

    def get(self, job_id: str) -> Job | None:
        return self._jobs.get(job_id)

    def list(self) -> list[dict]:
        return [job.snapshot() for job in self._jobs.values()]

    async def cancel(self, job_id: str) -> bool:
        job = self._jobs.get(job_id)
        if job is None or job.status != "running" or job._proc is None:
            return False
        job.status = "cancelled"
        try:
            job._proc.terminate()
        except ProcessLookupError:
            pass
        return True
