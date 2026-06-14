# Project

This project is enabled for Claude + Codex collaboration through AgentBridge.

## AgentBridge Collaboration

You are working with Codex through AgentBridge in this project.

### Role Split
- Claude: planning synthesis, code edits, integration, final user-facing decisions.
- Codex: independent review, reproduction, tests, verification, risk analysis.

### Communication
- Claude -> Codex: use AgentBridge MCP tools (`reply`, `reply_and_wait`, `get_messages`).
- Use `reply_and_wait` when a Codex answer is required.
- Include a unique `Request-ID` and require Codex to echo it.

### Shared Memory
Canonical protocol: `memory/README.md`.
On `abg-open --resume`, read `memory/resume.md` as a startup summary.
Entry files under `memory/` are source of truth. `MEMORY.md` is non-authoritative.
