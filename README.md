# cocowork-tools

AgentBridge dual-agent collaboration CLI tools.

## Install

```bash
git clone https://github.com/Nyarlathoteppppp/cocowork-tools.git
cd cocowork-tools
./install.sh
```

## Tools

| Command | Description |
|---------|-------------|
| `abg-open` | Launch Claude + Codex collaboration in any project |
| `abg-upgrade` | Check and upgrade cowork framework version |
| `abg-remember` | Write a memory entry from the command line |
| `abg-recall` | Search memory entries |

## Usage

```bash
# Start collaboration in current project
abg-open .

# Dry run (preview without launching)
abg-open . --dry-run

# Start with resume
abg-open . --resume --logs

# Write a memory entry
abg-remember "Don't use current-minute cron" --type gotcha --priority critical

# Search memory
abg-recall "cron"
abg-recall --type gotcha --priority critical

# Check framework version
abg-upgrade --check
```

## Requirements

- macOS (for osascript/Terminal)
- [AgentBridge](https://github.com/agentbridge/agentbridge) installed
- Claude Code and Codex CLI installed

## License

MIT
