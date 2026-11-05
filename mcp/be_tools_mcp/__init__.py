"""be-tools MCP server.

A thin, validated MCP wrapper around the existing be-tools build/test entrypoints
(``cloud/docker/build_image.sh`` / ``.bat`` and ``cloud/docker/tests/run_tests.sh``).
The server delegates all build logic to those scripts; it constructs a safe argv
and shells out.
"""

__version__ = "0.1.0"
