# Context Discovery Protocol

## Purpose
Systematically discover missing context when presented with minimal-information prompts. This protocol prevents the framework from making incorrect assumptions and ensures proper routing.

## Activation Trigger
- Prompt length < 20 words
- No file paths specified
- No specific technical terms
- Vague action words ("fix", "make", "help", "do")
- Missing critical details (what, where, how)

## Discovery Sequence

### Phase 1: Project Discovery (30-60 seconds)
```bash
# 1. Identify project type
find . -maxdepth 3 -name "package.json" -o -name "Cargo.toml" -o -name "pyproject.toml" -o -name "pom.xml" -o -name "build.gradle" -o -name "*.csproj" | head -10

# 2. Check for framework indicators
find . -maxdepth 3 -name "README.md" -o -name "CLAUDE.md" -o -name ".env.example" | head -10

# 3. Identify git repository
git remote -v 2>/dev/null || echo "No git repository found"
git branch --show-current 2>/dev/null || echo "Not in git repo"

# 4. Recent activity
find . -type f -mtime -1 | grep -E "\.(js|ts|py|java|cs|go|rs)$" | head -10
```

### Phase 2: State Assessment (45-60 seconds)
```bash
# 1. Git state analysis
git status --short 2>/dev/null | head -20
git log --oneline -10 2>/dev/null

# 2. Build/test state
if [ -f "package.json" ]; then
    npm test 2>&1 | tail -20 || echo "No test command"
    npm run build 2>&1 | tail -20 || echo "No build command"
elif [ -f "Cargo.toml" ]; then
    cargo test 2>&1 | tail -20
elif [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
    python -m pytest 2>&1 | tail -20 || python test.py 2>&1 | tail -20
fi

# 3. TODO/FIXME markers
grep -r "TODO\|FIXME\|HACK\|XXX\|BUG" --include="*.js" --include="*.ts" --include="*.py" --include="*.java" --include="*.cs" . 2>/dev/null | head -15
```

### Phase 3: Problem Identification (30-45 seconds)
For debugging/fix requests:
```bash
# 1. Error logs
find . -name "*.log" -mtime -1 2>/dev/null | xargs tail -50 2>/dev/null | grep -i "error\|exception\|fail"

# 2. Recent crashes/errors
if [ -f "package.json" ]; then
    npm start 2>&1 | head -50 &
    sleep 5
    kill $! 2>/dev/null
fi

# 3. Failed tests
npm test 2>&1 | grep -E "fail|error|✗|✖|FAIL" | head -20
```

### Phase 4: Context Building
Create a structured context summary:

```markdown
## Discovered Context

### Project Type
- Language: [detected]
- Framework: [detected]  
- Project structure: [monorepo/standard/etc]

### Current State
- Branch: [current branch]
- Uncommitted changes: [count and nature]
- Last commit: [message and time]
- Build status: [passing/failing/unknown]
- Test status: [passing/failing/unknown]

### Potential Issues
- TODOs found: [count and samples]
- Recent errors: [summary]
- Failed tests: [list]
- Recent changes: [files modified in last 24h]

### Recommended Next Steps
Based on the context discovered:
1. [Specific action based on findings]
2. [Alternative if more info needed]
```

## Clarifying Questions

### For "fix" requests:
1. "I found [X] potential issues. Which specific problem are you experiencing?"
2. "I see [recent changes]. Is the issue related to these changes?"
3. "What's the expected behavior vs. what you're seeing?"

### For "add" requests:
1. "Where should this feature be added? I see these main modules: [list]"
2. "I found similar patterns in [files]. Should I follow this pattern?"
3. "What's the intended use case for this feature?"

### For "make it work" requests:
1. "I see [specific errors/failures]. Should I focus on these?"
2. "The [build/tests] are failing. Should I fix these first?"
3. "What was working before that isn't now?"

### For "finish" requests:
1. "I found [N] TODOs. Which should I complete?"
2. "I see incomplete work in [areas]. Should I continue this?"
3. "What's the definition of 'done' for this task?"

## Memory Integration
```bash
# Store discovered context for future reference
p memory-learn "context-discovery" "$PROJECT_TYPE $CURRENT_STATE" "discovered"

# Check if we've seen similar context before
p memory-find "similar project state"
```

## Output Format
After context discovery, present findings as:

```markdown
I've analyzed your project and found:

**Project**: [Type and structure]
**Current Status**: [State summary]
**Potential Focus Areas**: 
1. [Most likely area based on prompt]
2. [Second most likely]
3. [Third option]

**Suggested approach**: [Specific recommendation]

Would you like me to:
A) [Most likely action based on context]
B) [Alternative action]
C) Something else specific?
```

## Success Metrics
- Context discovery time: < 2 minutes
- Accuracy of focus area: > 80%
- User clarification needed: < 2 rounds
- Successful routing after discovery: > 90%

## Anti-Patterns to Avoid
- Don't assume the most recent change is the problem
- Don't focus only on errors (user might want features)
- Don't ignore project conventions discovered
- Don't make changes without confirming understanding
- Don't skip context discovery even if task seems obvious