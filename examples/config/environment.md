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

## GitHub CLI Setup

Essential for repository management:

```bash
# Install GitHub CLI
brew install gh  # macOS
# or
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh  # Linux

# Authenticate
gh auth login

# Configure default settings
gh config set editor code  # or vim, nano, etc.
gh config set git_protocol https
gh config set prompt enabled
```

## Docker Setup

For containerized development:

```bash
# Install Docker Desktop
# Download from https://www.docker.com/products/docker-desktop/

# Verify installation
docker --version
docker-compose --version

# Configure Docker for development
# Add user to docker group (Linux)
sudo usermod -aG docker $USER

# Configure resource limits in Docker Desktop
# Memory: 8GB minimum
# CPUs: 4 minimum
# Disk: 50GB minimum
```

## IDE Configuration

### VS Code Settings

.vscode/settings.json:

```json
{
  "typescript.preferences.importModuleSpecifier": "relative",
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": true,
    "source.organizeImports": true
  },
  "editor.formatOnSave": true,
  "editor.defaultFormatter": "esbenp.prettier-vscode",
  "files.associations": {
    "*.css": "tailwindcss"
  },
  "emmet.includeLanguages": {
    "javascript": "javascriptreact",
    "typescript": "typescriptreact"
  },
  "eslint.workingDirectories": ["lib/*"],
  "typescript.preferences.includePackageJsonAutoImports": "auto"
}
```

### VS Code Extensions

.vscode/extensions.json:

```json
{
  "recommendations": [
    "esbenp.prettier-vscode",
    "dbaeumer.vscode-eslint",
    "bradlc.vscode-tailwindcss",
    "ms-vscode.vscode-typescript-next",
    "ms-playwright.playwright",
    "vitest.explorer",
    "github.copilot",
    "github.copilot-chat"
  ]
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

### Node.js Memory Issues
```bash
# Increase Node.js memory limit
export NODE_OPTIONS="--max-old-space-size=8192"

# Or in .mise.toml
[env]
NODE_OPTIONS = "--max-old-space-size=8192"
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

# Development URLs
export API_URL=http://localhost:3001
export WEB_URL=http://localhost:3000
```

## Platform-specific Setup

### macOS
```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Essential tools
brew install git gh docker colima
brew install --cask visual-studio-code
```

### Linux (Ubuntu/Debian)
```bash
# Update package list
sudo apt update && sudo apt upgrade -y

# Essential tools
sudo apt install -y curl git build-essential

# Install gh CLI (see GitHub CLI setup above)
```

### Windows (WSL2)
```bash
# Ensure WSL2 is installed and updated
wsl --update

# Inside WSL2, follow Linux setup instructions
# Install Windows Terminal for better experience
```

## Performance Optimization

### System Configuration
```bash
# Increase file watcher limits (Linux/macOS)
echo 'fs.inotify.max_user_watches=524288' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p

# Increase ulimit for file descriptors
ulimit -n 65536

# Add to shell profile for persistence
echo 'ulimit -n 65536' >> ~/.bashrc
```

### Development Server Optimization
```bash
# Use faster DNS
echo 'nameserver 1.1.1.1' | sudo tee /etc/resolv.conf

# Disable unnecessary services during development
# This varies by platform - check running services
```

## Security Setup

### SSH Key Generation
```bash
# Generate SSH key for GitHub
ssh-keygen -t ed25519 -C "your-email@example.com"

# Add to SSH agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Add public key to GitHub
cat ~/.ssh/id_ed25519.pub
# Copy output and add to GitHub Settings > SSH Keys
```

### GPG Key for Commit Signing
```bash
# Generate GPG key
gpg --full-generate-key

# List keys
gpg --list-secret-keys --keyid-format LONG

# Configure git to use GPG key
git config --global user.signingkey <KEY_ID>
git config --global commit.gpgsign true

# Add GPG key to GitHub
gpg --armor --export <KEY_ID>
# Copy output and add to GitHub Settings > GPG Keys
```