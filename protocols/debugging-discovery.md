# Debugging Discovery Protocol

## Purpose
Systematically identify and diagnose problems when users provide vague debugging requests like "fix the bug", "it's broken", or "something's wrong".

## Activation Triggers
- Keywords: "fix", "broken", "bug", "error", "crash", "doesn't work", "failed"
- No specific error message provided
- No location of problem specified
- No reproduction steps given

## Discovery Framework

### Step 1: Error Surface Scan (1-2 minutes)
```bash
# Console/Runtime Errors
echo "=== Checking for runtime errors ==="
# Node.js projects
if [ -f "package.json" ]; then
    timeout 10s npm start 2>&1 | grep -i "error\|exception\|fail\|uncaught\|fatal" | head -20
    timeout 10s npm run dev 2>&1 | grep -i "error\|exception\|fail" | head -20
fi

# Python projects
if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
    timeout 10s python main.py 2>&1 | grep -i "error\|exception\|traceback" | head -20
    timeout 10s python app.py 2>&1 | grep -i "error\|exception\|traceback" | head -20
fi

# Log files
echo "=== Recent error logs ==="
find . -name "*.log" -mtime -1 -exec grep -l "ERROR\|FATAL\|Exception" {} \; | head -10
find . -name "*.log" -mtime -1 -exec tail -50 {} \; | grep -A2 -B2 "ERROR\|FATAL\|Exception" | head -30
```

### Step 2: Test Failure Analysis (1-2 minutes)
```bash
echo "=== Test Status ==="
# JavaScript/TypeScript
if [ -f "package.json" ]; then
    npm test 2>&1 | grep -E "FAIL|✗|✖|failing|error" -A3 -B1 | head -40
fi

# Python
if [ -f "pytest.ini" ] || [ -f "setup.cfg" ]; then
    python -m pytest -v 2>&1 | grep -E "FAILED|ERROR" -A3 -B1 | head -40
fi

# Count failures
echo "=== Failure Summary ==="
npm test 2>&1 | grep -c "failing\|FAIL" || echo "0 test failures"
```

### Step 3: Build/Compilation Errors (30-60 seconds)
```bash
echo "=== Build Status ==="
# JavaScript/TypeScript
if [ -f "tsconfig.json" ]; then
    npx tsc --noEmit 2>&1 | head -30
fi
if [ -f "package.json" ]; then
    npm run build 2>&1 | grep -i "error" -A2 -B2 | head -30
fi

# Other build systems
make 2>&1 | grep -i "error" -A2 -B2 | head -30
```

### Step 4: Static Analysis (30-60 seconds)
```bash
echo "=== Linting/Static Analysis ==="
# JavaScript/TypeScript
if [ -f ".eslintrc.json" ] || [ -f ".eslintrc.js" ]; then
    npx eslint . --max-warnings=0 2>&1 | grep -E "error|Error" -A1 -B1 | head -30
fi

# Python
if command -v pylint &> /dev/null; then
    pylint *.py 2>&1 | grep -E "E:|error:" | head -20
fi
```

### Step 5: Recent Change Analysis (1 minute)
```bash
echo "=== Recent Changes That Might Cause Issues ==="
# Git diff for recent changes
git diff HEAD~1 2>&1 | grep -E "^[\+\-].*error|throw|catch|except|fatal" | head -20

# Files changed in last 24 hours
find . -type f -mtime -1 -name "*.js" -o -name "*.ts" -o -name "*.py" | head -20

# Recent commits that might be problematic
git log --oneline -10 --grep="fix\|bug\|error\|revert" 2>&1
```

### Step 6: Temporal Analysis
Compare current state with last known good state:

```bash
echo "=== Temporal Analysis ==="
# When did tests last pass?
git log --oneline --grep="test.*pass\|all tests pass\|✓" -1

# Check CI/CD status if available
if [ -f ".github/workflows" ]; then
    echo "GitHub Actions workflows present - check recent runs"
fi

# Environment changes
echo "=== Environment Changes ==="
git diff HEAD~5 -- package.json package-lock.json requirements.txt Gemfile.lock
```

## Problem Categorization

After discovery, categorize the issue:

### Category A: Runtime Errors
- Application crashes on startup
- Uncaught exceptions during operation
- Timeout or connection errors
- Memory/resource exhaustion

### Category B: Logic Errors  
- Incorrect output/calculations
- Unexpected behavior (works but wrong)
- Edge case failures
- State management issues

### Category C: Build/Deploy Errors
- Compilation failures
- Dependency conflicts
- Environment misconfigurations
- Asset processing errors

### Category D: Test Failures
- Unit test failures
- Integration test failures
- Flaky tests
- Coverage gaps

### Category E: Performance Issues
- Slow operations
- High memory usage
- CPU spikes
- Database query problems

## Structured Diagnosis Output

```markdown
## Debugging Analysis Complete

### Issues Detected
1. **Primary Issue**: [Type and location]
   - Error: `[specific error message]`
   - Location: `[file:line]`
   - First occurred: [timestamp or commit]

2. **Secondary Issues**: [if any]
   - [List other problems found]

### Root Cause Analysis
- **Most Likely Cause**: [Based on evidence]
- **Evidence**: 
  - [Specific indicators]
  - [Related changes]
- **Confidence**: [High/Medium/Low]

### Recommended Fix Strategy
1. **Immediate Fix**: [Specific action]
2. **Verification**: [How to test the fix]
3. **Prevention**: [Avoid future occurrences]

### Would you like me to:
A) Fix the primary issue automatically
B) Show you the detailed fix steps
C) Investigate a different issue
D) Run more diagnostic tests
```

## Interactive Debugging Mode

If initial discovery is insufficient:

```markdown
I need more information to pinpoint the issue. Please help me by answering:

1. **When did this last work correctly?**
   - [ ] Today
   - [ ] Yesterday  
   - [ ] Last week
   - [ ] Don't know

2. **What changed recently?**
   - [ ] Code changes
   - [ ] Dependencies updated
   - [ ] Configuration modified
   - [ ] Environment changed
   - [ ] Nothing I'm aware of

3. **How does it fail?**
   - [ ] Won't start/compile
   - [ ] Crashes during use
   - [ ] Wrong output/behavior
   - [ ] Slow/unresponsive
   - [ ] Other: ___

4. **Can you reproduce it?**
   - [ ] Every time
   - [ ] Sometimes
   - [ ] Only in production
   - [ ] Only for some users
```

## Memory Patterns

Store discovered patterns for faster future debugging:

```bash
# Learn from this debugging session
p memory-learn "debug-pattern" "$ERROR_TYPE $ROOT_CAUSE $FIX_APPLIED" "success"

# Check if we've seen similar issues
p memory-find "similar error $ERROR_TYPE"

# Store error signatures
p memory-learn "error-signature" "$ERROR_MESSAGE $STACK_TRACE" "$ROOT_CAUSE"
```

## Success Metrics
- Issue identification rate: > 85%
- Root cause accuracy: > 75%  
- Fix success rate: > 90%
- Average diagnosis time: < 5 minutes
- User rounds needed: ≤ 2

## Common Anti-Patterns
- Don't assume the newest change caused the bug
- Don't focus only on error messages (logic bugs exist)
- Don't ignore environment/configuration issues
- Don't skip reproduction verification
- Don't apply fixes without understanding root cause