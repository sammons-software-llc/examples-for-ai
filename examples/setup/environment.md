# Development Environment Setup

## Initial Environment Check

When starting any development task, first ensure the environment is properly configured:

```bash
# Check if mise is installed
if ! command -v mise &> /dev/null; then
  echo "Installing mise..."
  curl https://mise.run | sh
  echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
  echo 'eval "$(~/.local/bin/mise activate zsh)"' >> ~/.zshrc
  # Activate for current session
  export PATH="$HOME/.local/bin:$PATH"
  eval "$($HOME/.local/bin/mise activate bash)"
fi

# Create .mise.toml if it doesn't exist
if [ ! -f .mise.toml ]; then
  cat > .mise.toml << 'EOF'
[tools]
node = "24"
python = "3.12"
rust = "latest"

[env]
NODE_OPTIONS = "--max-old-space-size=4096"
EOF
fi

# Install all tools defined in .mise.toml
mise install

# Verify installations
mise list

# Install global npm packages
npm install -g pnpm@latest
```

## Per-Project Setup

For each project, create a `.mise.toml` in the project root:

```toml
[tools]
node = "24.0.0"  # Pin to specific version for consistency
pnpm = "9.0.0"

[env]
NODE_ENV = "development"
```

## Common Tools Installation

```bash
# Node.js and package managers
mise use node@24
mise use pnpm@latest

# Python for scripts
mise use python@3.12

# Rust for performance-critical tools
mise use rust@latest

# Additional tools
npm install -g @githubnext/github-copilot-cli
```

## Shell Configuration

Add to your shell profile (~/.bashrc or ~/.zshrc):

```bash
# Mise activation
eval "$(~/.local/bin/mise activate bash)"

# Helpful aliases
alias nr="pnpm run"
alias nrd="pnpm run dev"
alias nrt="pnpm test"
alias nrl="pnpm run lint"

# Auto-activate mise in project directories
cd() {
  builtin cd "$@"
  if [[ -f .mise.toml ]]; then
    mise install
  fi
}
```

## Troubleshooting Common Issues

### Command not found
```bash
mise doctor  # Diagnose mise issues
echo $PATH   # Verify mise is in PATH
```

### Version conflicts
```bash
mise prune           # Clean old versions
mise list --current  # Show active versions
mise reshim          # Rebuild shims
```

### Shell integration
```bash
# Verify mise is activated
which node  # Should show ~/.local/share/mise/shims/node

# Force reload
exec $SHELL
```

### Permission issues
```bash
# Fix mise directory permissions
chmod -R u+rwX ~/.local/share/mise
chmod -R u+rwX ~/.config/mise
```

## Environment Variables

Essential environment variables to set:

```bash
# Node.js
export NODE_ENV=development
export NODE_OPTIONS="--max-old-space-size=4096"

# AWS (if needed)
export AWS_REGION=us-east-1
export AWS_PROFILE=default

# GitHub
export GH_TOKEN=<your-token>  # For gh CLI
```