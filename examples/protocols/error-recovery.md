# Error Recovery Protocol

## When ANY Command Fails

### 1. Immediate Response
```bash
# Capture error details
LAST_EXIT_CODE=$?
FAILED_COMMAND="<exact command that failed>"
ERROR_OUTPUT="<full error message>"

# Log to todo list
echo "ERROR: Command failed with exit code $LAST_EXIT_CODE"
```

### 2. Automated Recovery Attempts

```bash
# Attempt 1: Environment issue?
mise install && eval "$(mise activate bash)"

# Attempt 2: Dependencies missing?
pnpm install

# Attempt 3: Permission issue?
sudo chown -R $(whoami) .
```

### 3. Escalation Protocol
- After 2 failed attempts: Ask user for guidance
- NEVER skip silently
- NEVER mark task complete if command failed
- ALWAYS document what failed and why

### 4. Common Recovery Scenarios

| Error | Solution |
|-------|----------|
| `command not found` | Install via mise or pnpm |
| `EACCES` | Fix permissions or use different directory |
| `ENOENT` | Create missing file/directory |
| `port already in use` | Kill process or use different port |
| `module not found` | Run pnpm install |
| `type error` | Run pnpm run type-check for details |
| `npm ERR! 404` | Check package name spelling |
| `git push rejected` | Pull latest changes and rebase |
| `CORS error` | Check API Gateway or server CORS config |
| `timeout` | Increase timeout or optimize query |

### 5. Error Documentation Template
```markdown
## Error Report
- **Command**: `<exact command>`
- **Exit Code**: <number>
- **Error Message**: <full error>
- **Attempted Fixes**: 
  1. <fix 1> - <result>
  2. <fix 2> - <result>
- **Next Steps**: <ask user | try alternative | skip with warning>
```

### 6. Never Fail Silently
If error cannot be resolved:
```bash
echo "BLOCKED: Unable to proceed due to error"
echo "User intervention required: <specific ask>"
# Update todo item status to 'blocked'
```