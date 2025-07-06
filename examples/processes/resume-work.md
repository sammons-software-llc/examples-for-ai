# Resume Work Process

Use this when user says: "keep going", "continue", "resume", or when joining existing project.

## Initial Assessment

### 1. Check Project State
```bash
# Repository status
gh repo view
git status
git branch --show-current

# Open work
gh pr list
gh issue list --state open

# Project board
gh project list --owner sammons-software-llc
```

### 2. Review Recent Activity
```bash
# Recent commits
git log --oneline -10

# CI/CD status  
gh run list --limit 5

# Current test status
pnpm test -- --run
```

### 3. Check Todo State
Use TodoRead to see:
- Current process type
- Last completed step
- Any blockers
- Open tasks

## Priority Decision Tree

Resume work in this order:

### Priority 1: Failed CI/CD
```bash
gh run list --status failure
# Fix immediately - blocks everything else
```

### Priority 2: Open PR Feedback
```bash
gh pr list --state open
gh pr view [NUMBER] --comments
# Address all review comments
```

### Priority 3: In-Progress Tasks
- Check project board "Development" column
- Check todos marked "in_progress"
- Complete current feature/fix

### Priority 4: Code TODOs
```bash
grep -r "TODO\|FIXME" src/ --exclude-dir=node_modules
```

### Priority 5: New Tasks
- Pick next item from "TODO" column
- Start appropriate process (20-step or 8-step)

## Resume Strategies by Scenario

### Scenario: Mid-Implementation
```bash
# You were writing code
git status  # Check uncommitted changes
pnpm test -- --run  # See what's failing

# Continue from Test-Driven Development step
```

### Scenario: Post-PR Creation
```bash
# PR exists, waiting for review
gh pr checks  # Ensure CI passing
gh pr view --comments  # Check feedback

# Jump to step 17 (Review phase)
```

### Scenario: Unknown State
```bash
# Complete assessment
find . -name "*.md" -mtime -7  # Recent docs
git diff main...HEAD  # All changes
pnpm run lint:check  # Code quality

# Start fresh assessment or ask user
```

## State Recovery

If no todo list exists:
1. Create new todo list
2. Add discovered tasks
3. Mark appropriate process type
4. Continue from identified point

## Confirmation Before Proceeding

After assessment, always confirm:
```
Found:
- [N] open PRs with feedback
- [N] failing tests
- [N] tasks in progress
- Current branch: [branch-name]

Recommend: [specific action]
Proceed?
```