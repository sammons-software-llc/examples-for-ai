#!/bin/bash
# CLAUDE Framework Git Hooks
# Install these hooks to enforce framework compliance

# Pre-edit hook (for editors that support it)
pre_edit_hook() {
    cat << 'EOF'
#!/bin/bash
# Check framework compliance before allowing edits
./.framework-enforcer.py pre-edit "$1"
EOF
}

# Pre-commit hook
pre_commit_hook() {
    cat << 'EOF'
#!/bin/bash
# Check framework compliance before allowing commits

echo "🔍 Checking CLAUDE Framework compliance..."

# Run enforcer
if ! ./.framework-enforcer.py pre-commit; then
    echo ""
    echo "❌ Commit blocked due to framework violations"
    echo "Complete the required steps and try again."
    exit 1
fi

# Additional checks
if ! grep -q "ML/LLM scientist loaded" .framework-compliance.log 2>/dev/null; then
    echo "❌ ML/LLM scientist must be loaded first!"
    exit 1
fi

echo "✅ Framework compliance verified"
EOF
}

# Install hooks
install_hooks() {
    echo "Installing CLAUDE Framework hooks..."
    
    # Create .git/hooks directory if it doesn't exist
    mkdir -p .git/hooks
    
    # Install pre-commit hook
    pre_commit_hook > .git/hooks/pre-commit
    chmod +x .git/hooks/pre-commit
    echo "✅ Installed pre-commit hook"
    
    # Create editor config for VS Code
    if [ -d ".vscode" ] || [ -f ".vscode/settings.json" ]; then
        echo "📝 Detected VS Code - adding task"
        mkdir -p .vscode
        cat > .vscode/tasks.json << 'EOF'
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Check Framework Compliance",
            "type": "shell",
            "command": "./.framework-enforcer.py check",
            "group": {
                "kind": "test",
                "isDefault": true
            },
            "presentation": {
                "reveal": "always",
                "panel": "dedicated"
            },
            "problemMatcher": []
        }
    ]
}
EOF
        echo "✅ Added VS Code task (Cmd+Shift+P -> 'Run Task')"
    fi
    
    echo ""
    echo "🎉 Framework hooks installed successfully!"
    echo ""
    echo "Hooks will now:"
    echo "  • Block commits without framework compliance"
    echo "  • Remind you to load required personas/context"
    echo "  • Ensure proper workflow is followed"
}

# Uninstall hooks
uninstall_hooks() {
    echo "Removing CLAUDE Framework hooks..."
    rm -f .git/hooks/pre-commit
    rm -f .vscode/tasks.json
    echo "✅ Hooks removed"
}

# Main
case "${1:-install}" in
    install)
        install_hooks
        ;;
    uninstall)
        uninstall_hooks
        ;;
    *)
        echo "Usage: $0 [install|uninstall]"
        exit 1
        ;;
esac