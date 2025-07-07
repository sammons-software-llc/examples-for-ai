#!/bin/bash
# CLAUDE Framework One-Command Setup
# Usage: curl -sSL https://raw.githubusercontent.com/sammons-software-llc/examples-for-ai/main/install.sh | bash

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
REPO_URL="sammons-software-llc/examples-for-ai"

echo -e "${BLUE}🚀 CLAUDE Framework Installer${NC}"
echo "================================"
echo ""

# Check prerequisites
echo -e "${BLUE}Checking prerequisites...${NC}"

if ! command -v gh &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI (gh) not found${NC}"
    echo "Please install: https://cli.github.com/"
    exit 1
fi

if ! gh auth status &> /dev/null; then
    echo -e "${RED}❌ GitHub CLI not authenticated${NC}"
    echo "Please run: gh auth login"
    exit 1
fi

echo -e "${GREEN}✅ Prerequisites satisfied${NC}"
echo ""

# Interactive setup
echo -e "${BLUE}Project Setup${NC}"
echo "============="

# Get project name
read -p "Project name (or press Enter to use current directory): " PROJECT_NAME

if [ -z "$PROJECT_NAME" ]; then
    PROJECT_DIR="."
    echo -e "${YELLOW}Using current directory: $(pwd)${NC}"
else
    PROJECT_DIR="$PROJECT_NAME"
    if [ ! -d "$PROJECT_DIR" ]; then
        echo -e "${BLUE}Creating directory: $PROJECT_DIR${NC}"
        mkdir -p "$PROJECT_DIR"
    fi
    cd "$PROJECT_DIR"
fi

# Check if framework already exists
if [ -f "CLAUDE.md" ]; then
    echo -e "${YELLOW}⚠️  CLAUDE.md already exists${NC}"
    read -p "Update to latest version? (y/N): " UPDATE_CHOICE
    if [[ ! "$UPDATE_CHOICE" =~ ^[Yy]$ ]]; then
        echo "Setup cancelled."
        exit 0
    fi
fi

echo ""
echo -e "${BLUE}Downloading CLAUDE Framework...${NC}"
echo "=============================="

# Core framework files
echo "📥 Fetching CLAUDE.md..."
gh api repos/$REPO_URL/contents/CLAUDE.md --jq '.content' | base64 -d > CLAUDE.md

echo "📥 Fetching p-cli tool..."
mkdir -p claude-scripts
gh api repos/$REPO_URL/contents/claude-scripts/p --jq '.content' | base64 -d > claude-scripts/p
chmod +x claude-scripts/p

# Initialize memory system
echo "🧠 Initializing memory system..."
./claude-scripts/p memory-init

# Create framework markers
echo "📌 Creating framework markers..."
touch .claude-framework-active
echo "If you see this file, ensure CLAUDE.md is loaded" > ALWAYS-CHECK-CLAUDE.md

# Optional components
echo ""
echo -e "${BLUE}Optional Components${NC}"
echo "=================="

read -p "Download core context files? (Y/n): " CONTEXT_CHOICE
if [[ ! "$CONTEXT_CHOICE" =~ ^[Nn]$ ]]; then
    echo "📥 Fetching context files..."
    mkdir -p context
    gh api repos/$REPO_URL/contents/context/about-ben.md --jq '.content' | base64 -d > context/about-ben.md
    gh api repos/$REPO_URL/contents/context/workflow.md --jq '.content' | base64 -d > context/workflow.md
    gh api repos/$REPO_URL/contents/context/tech-stack.md --jq '.content' | base64 -d > context/tech-stack.md
fi

read -p "Download all personas? (Y/n): " PERSONAS_CHOICE
if [[ ! "$PERSONAS_CHOICE" =~ ^[Nn]$ ]]; then
    echo "📥 Fetching personas..."
    mkdir -p personas
    for persona in ml-llm-scientist developer architect security-expert performance-expert ux-designer team-lead; do
        echo "  - $persona.md"
        gh api repos/$REPO_URL/contents/personas/$persona.md --jq '.content' | base64 -d > personas/$persona.md
    done
fi

read -p "Download protocols for blunt prompt handling? (Y/n): " PROTOCOLS_CHOICE
if [[ ! "$PROTOCOLS_CHOICE" =~ ^[Nn]$ ]]; then
    echo "📥 Fetching protocols..."
    mkdir -p protocols
    for protocol in context-discovery debugging-discovery feature-scoping general-clarification performance-analysis; do
        echo "  - $protocol.md"
        gh api repos/$REPO_URL/contents/protocols/$protocol.md --jq '.content' | base64 -d > protocols/$protocol.md
    done
fi

# Project type selection
echo ""
echo -e "${BLUE}Project Type${NC}"
echo "============"
echo "Select your project type to download the appropriate archetype:"
echo ""
echo "1)  Static Website (GitHub Pages, Zola)"
echo "2)  Local App (Self-contained desktop)"
echo "3)  Serverless AWS (Lambda, DynamoDB)"
echo "4)  Component/Library (NPM package)"
echo "5)  Desktop App (Electron)"
echo "6)  Mobile App (React Native)"
echo "7)  Browser Extension"
echo "8)  CLI Tool"
echo "9)  Real-time App (WebSocket)"
echo "10) ML/AI App"
echo "11) IoT/Home Assistant"
echo "12) Unity Game"
echo "0)  Skip archetype selection"
echo ""

read -p "Select project type (0-12): " PROJECT_TYPE

if [ "$PROJECT_TYPE" != "0" ]; then
    mkdir -p archetypes
    case $PROJECT_TYPE in
        1) ARCHETYPE="static-websites" ;;
        2) ARCHETYPE="local-apps" ;;
        3) ARCHETYPE="serverless-aws" ;;
        4) ARCHETYPE="component-project" ;;
        5) ARCHETYPE="desktop-apps" ;;
        6) ARCHETYPE="mobile-apps" ;;
        7) ARCHETYPE="browser-extensions" ;;
        8) ARCHETYPE="cli-tools" ;;
        9) ARCHETYPE="real-time-apps" ;;
        10) ARCHETYPE="ml-ai-apps" ;;
        11) ARCHETYPE="iot-home-assistant" ;;
        12) ARCHETYPE="unity-games" ;;
        *) echo "Invalid selection"; ARCHETYPE="" ;;
    esac
    
    if [ -n "$ARCHETYPE" ]; then
        echo "📥 Fetching $ARCHETYPE archetype..."
        gh api repos/$REPO_URL/contents/archetypes/$ARCHETYPE.md --jq '.content' | base64 -d > archetypes/$ARCHETYPE.md
        echo "$ARCHETYPE" > .selected-archetype
    fi
fi

# Global p-cli symlink
echo ""
read -p "Create global 'p' command? (Y/n): " GLOBAL_CHOICE
if [[ ! "$GLOBAL_CHOICE" =~ ^[Nn]$ ]]; then
    echo "🔗 Creating global symlink..."
    sudo ln -sf $(pwd)/claude-scripts/p /usr/local/bin/p
    echo -e "${GREEN}✅ Global 'p' command available${NC}"
fi

# Framework check
echo ""
echo -e "${BLUE}Running framework check...${NC}"
echo "========================="
./claude-scripts/p framework-health

# Success message
echo ""
echo -e "${GREEN}✨ CLAUDE Framework Successfully Installed!${NC}"
echo ""
echo "Next steps:"
echo "1. Read CLAUDE.md to understand the framework"
echo "2. Run: ./claude-scripts/p framework-check"
echo "3. Start your project with proper framework compliance"
echo ""
echo "Quick commands:"
echo "  p framework-health    - Check framework status"
echo "  p framework-check     - Verify compliance"
echo "  p memory-init        - Initialize memory"
echo "  p version            - Check for updates"
echo ""
echo -e "${BLUE}Happy coding with CLAUDE! 🤖${NC}"