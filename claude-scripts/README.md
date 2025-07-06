# p - Project CLI for Multi-Agent Workflows

A lightweight wrapper around GitHub CLI (`gh`) optimized for LLM sub-agents executing Ben's 12-step development workflow.

## Purpose

This tool enables LLM agents to efficiently collaborate on GitHub projects by providing:
- Simplified command syntax for common operations
- Bulk operations to reduce API calls
- Agent coordination through shared context
- Command transparency for debugging

## Installation

```bash
# Make executable and add to PATH
chmod +x p
ln -s $(pwd)/p /usr/local/bin/p

# Or copy directly
cp p /usr/local/bin/p

# Verify gh CLI is installed
gh --version || echo "Install gh first: brew install gh"
```

## Environment Variables

```bash
P_ECHO=1     # Show gh commands before execution (recommended for LLMs)
P_DEBUG=1    # Enable verbose debug output
```

## Command Reference

### Repository Management

```bash
# Create private repository under sammons-software-llc
p create-repo <name>
# Example: p create-repo note-taker-app
# Executes: gh repo create "sammons-software-llc/note-taker-app" --private --clone

# Clone framework files into current directory
p clone-framework
# Downloads CLAUDE.md and creates framework directories
```

### Task Management

```bash
# Create single task with options
p create-task --title "Add user authentication" --body "Implement JWT auth" --label "feature,backend"
# Supports: --title, --body, --label, --assignee, --milestone

# Bulk create tasks from JSON file
p bulk-create-tasks tasks.json [project-id]
# JSON format: [{"title": "...", "body": "...", "labels": "task,feature"}]

# Create task with template
p create-typed-task <type> <title> [options]
# Types: feature, bug, security
# Example: p create-typed-task feature "Add dark mode"

# Complete task by linking to PR
p complete-task <issue-num> <pr-num> [comment]
# Example: p complete-task 123 456 "Implemented in PR"
```

### Pull Request Workflow

```bash
# Create pull request
p create-pr --title "Add auth" --body "..." --base main

# Add review comment with agent identifier
p review-pr <pr-num> <comment> [agent-name]
# Example: p review-pr 123 "LGTM, tests pass" security-expert

# Get PR reviews in text or JSON format
p get-pr-reviews <pr-num> [format]
# Example: p get-pr-reviews 123 json

# Check if required reviews are complete
p check-reviews-complete <pr-num> [required-count]
# Example: p check-reviews-complete 123 3
# Returns: "true" or "false (2/3 approved)"

# Bulk review from JSON file
p bulk-review <pr-num> reviews.json
# JSON format: [{"agent": "security", "action": "approve", "comment": "..."}]
# Actions: approve, request-changes, comment
```

### Agent Coordination

```bash
# Set shared context value
p set-context <key> <value>
# Example: p set-context architecture-complete true

# Get shared context value
p get-context <key>
# Example: p get-context architecture-complete

# Wait for context with timeout (seconds)
p wait-for-context <key> [timeout]
# Example: p wait-for-context all-tests-pass 300

# List tasks for specific agent
p get-agent-tasks [agent] [state]
# Example: p get-agent-tasks architect open
```

### Performance Optimization

```bash
# Cache project board ID for faster operations
p cache-project <project-name>
# Example: p cache-project "Note Taker App"

# Clear all cached data
p clear-cache
```

## Usage Patterns for LLM Agents

### 1. Project Initialization (Team Lead Agent)
```bash
P_ECHO=1 p create-repo my-new-app
cd my-new-app
p clone-framework
p cache-project "My New App"
```

### 2. Task Creation (Architect Agent)
```bash
# Create tasks.json
cat > tasks.json << 'EOF'
[
  {"title": "[ARCH] Design system architecture", "body": "...", "labels": "task,architecture"},
  {"title": "[SEC] Security requirements", "body": "...", "labels": "task,security"},
  {"title": "[UX] UI patterns", "body": "...", "labels": "task,design"}
]
EOF

p bulk-create-tasks tasks.json
```

### 3. Development (Developer Agent)
```bash
# Start work
p set-context dev-task-123 in-progress

# After completion
p create-pr --title "[TASK-123] Implement feature" --body "..."
p set-context dev-task-123 ready-for-review
```

### 4. Review Cycle (Expert Agents)
```bash
# Security expert
p review-pr 456 "Found SQL injection risk in line 45" security-expert

# After fixes
p review-pr 456 "Security issues resolved" security-expert
p set-context security-review-456 approved

# Check all reviews
p check-reviews-complete 456 3
```

### 5. Merge Decision (Team Lead)
```bash
# Wait for all reviews
p wait-for-context all-reviews-complete-456 300

# If approved
p complete-task 123 456 "Feature implemented successfully"
```

## Best Practices for LLM Agents

1. **Always use P_ECHO=1** during development to see actual commands
2. **Use bulk operations** when creating multiple items
3. **Set context keys** to coordinate between agents
4. **Include agent names** in reviews for tracking
5. **Cache project IDs** at start to improve performance
6. **Check command success** by examining output/exit codes

## Common Workflows

### Creating Multiple Related Tasks
```bash
p create-typed-task feature "User authentication" --label "priority:high"
p create-typed-task feature "Password reset" --label "priority:medium"
p create-typed-task security "Rate limiting for auth endpoints" --label "priority:high"
```

### Multi-Agent PR Review
```bash
# Create reviews.json
cat > reviews.json << 'EOF'
[
  {"agent": "security", "action": "request-changes", "comment": "Add rate limiting"},
  {"agent": "architect", "action": "comment", "comment": "Consider using strategy pattern"},
  {"agent": "performance", "action": "approve", "comment": "Metrics look good"}
]
EOF

p bulk-review 123 reviews.json
```

### Coordinated Task Completion
```bash
p set-context task-789-status "development"
# ... development work ...
p set-context task-789-status "testing"
# ... testing ...
p set-context task-789-status "complete"
p complete-task 789 456
```

## Troubleshooting

### Command Failed
```bash
# Enable echo to see exact command
P_ECHO=1 p <command>

# Check gh authentication
gh auth status

# Verify repository access
gh repo view sammons-software-llc/<repo>
```

### Cache Issues
```bash
# Clear cache if stale
p clear-cache

# Re-cache project
p cache-project "Project Name"
```

### Rate Limiting
```bash
# Use bulk operations instead of loops
# Good: p bulk-create-tasks tasks.json
# Bad: for task in tasks; do p create-task ...; done
```

## Architecture

The tool is designed for:
- **Stateless operation**: Each invocation is independent
- **Composability**: Commands can be chained with shell operators
- **Transparency**: All operations can be inspected with P_ECHO=1
- **Performance**: Caching reduces redundant API calls
- **Multi-agent**: Shared context enables coordination

## Additional Notes

The `p` script was developed through simulation of 50 projects across different archetypes, optimizing for the most common sub-agent operations and coordination patterns.