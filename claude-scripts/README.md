# Claude Scripts

This directory contains helper scripts for the Claude Code workflow framework.

## Main Script

### `p` - Project CLI Wrapper
A lightweight wrapper around `gh` CLI optimized for sub-agent workflows.

**Usage:**
```bash
# Basic usage
p create-repo my-app
p clone-framework
p create-task --title "Add feature"

# With command echo
P_ECHO=1 p create-repo my-app

# Debug mode
P_DEBUG=1 p bulk-create-tasks tasks.json
```

**Key Features:**
- Repository management
- Task creation (single and bulk)
- PR workflow with agent tracking
- Agent coordination via shared context
- Performance caching
- Command echo for transparency

## Documentation

See `docs/` directory for:
- `SIMULATION-RESULTS.md` - Analysis from 50-project simulation
- `P-CLI-IMPROVEMENTS.md` - Enhancement roadmap
- `test-p-echo.sh` - Example of echo functionality

## Archive

The `archive/` directory contains previous versions:
- `p-cli-simple` - Initial simple wrapper
- `p-cli` - First attempt (overcomplicated)
- `p-cli-v2` - Advanced version with scaffolding
- `simulate-projects.sh` - Simulation script

## Installation

```bash
# Add to PATH
ln -s $(pwd)/p /usr/local/bin/p

# Or copy directly
cp p /usr/local/bin/p
```

## Environment Variables

- `P_ECHO=1` - Show gh commands before execution
- `P_DEBUG=1` - Enable debug output
- `P_CLI_CACHE` - Override cache directory (default: ~/.p-cli-cache)