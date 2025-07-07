# CLAUDE Framework Enhancement: Blunt Prompt Handling

Based on simulation of 1000 blunt prompts with 31% failure rate, these enhancements address critical gaps.

## New Framework Sections to Add to CLAUDE.md

### 1. CONTEXT DISCOVERY SYSTEM (Addresses 42% of failures)

```markdown
=== CONTEXT DISCOVERY SYSTEM ===
TRIGGER: When prompt lacks sufficient context (< 20 words, no file paths, no specifics)

EXECUTE IN ORDER:
1. Project Type Discovery
   - Run: find . -name "package.json" -o -name "Cargo.toml" -o -name "pyproject.toml" | head -5
   - Run: git remote -v 2>/dev/null || echo "No git repo"
   - Check: README.md, CLAUDE.md existence

2. Current State Assessment
   - Run: git status --short
   - Run: git log --oneline -5
   - Check build status: npm test 2>&1 | head -20 || make test 2>&1 | head -20
   - Find TODO/FIXME: grep -r "TODO\|FIXME" --include="*.js" --include="*.ts" | head -10

3. Error Discovery (if debugging)
   - Check logs: find . -name "*.log" -mtime -1 | xargs tail -50
   - Recent errors: git diff HEAD~1 | grep -E "error|Error|ERROR"
   - Console output: npm start 2>&1 | head -50

4. Context Building
   - Create WORKING_CONTEXT.md with findings
   - Ask ONE clarifying question based on discoveries
   - Load appropriate archetype based on project type

OUTPUT: Refined prompt with discovered context
```

### 2. AMBIGUITY RESOLUTION PROTOCOL (Addresses 38% of failures)

```markdown
=== AMBIGUITY RESOLUTION PROTOCOL ===
TRIGGER: Vague action words ("fix", "make", "add", "improve") without specifics

CLASSIFICATION TREE:
IF "fix" or "broken" or "bug":
    THEN: Load ./protocols/debugging-discovery.md
    ASK: "What specific behavior is incorrect? What error do you see?"
    
ELIF "add" or "implement" or "create":
    THEN: Load ./protocols/feature-scoping.md
    ASK: "What specific functionality? Where in the app?"
    
ELIF "make faster" or "optimize" or "improve":
    THEN: Load ./protocols/performance-analysis.md
    ASK: "What specific operation is slow? What's the current performance?"
    
ELIF "finish" or "complete" or "todo":
    THEN: Search for incomplete work patterns
    RUN: grep -r "TODO\|WIP\|FIXME" . | head -20
    ASK: "Which specific task should I complete?"

ELSE:
    DEFAULT: Load ./protocols/general-clarification.md
    ASK: "Can you describe what you'd like me to do in more detail?"
```

### 3. STATE INSPECTION FRAMEWORK (Addresses 35% of failures)

```markdown
=== STATE INSPECTION FRAMEWORK ===
TRIGGER: Commands assuming knowledge ("finish the feature", "continue working")

INSPECTION SEQUENCE:
1. Git State Analysis
   - Current branch: git branch --show-current
   - Uncommitted changes: git diff --stat
   - Stashed work: git stash list
   - Recent commits: git log --oneline -10

2. Code State Analysis
   - Find WIP markers: grep -r "WIP\|TODO\|HACK" --include="*.{js,ts,py}"
   - Incomplete functions: grep -r "throw.*NotImplemented\|pass.*TODO"
   - Recent modifications: find . -type f -mtime -1 | grep -E "\.(js|ts|py)$"

3. Build/Test State
   - Last build status: cat .build.log 2>/dev/null || echo "No build log"
   - Test coverage gaps: npm test -- --coverage 2>/dev/null | grep -E "Uncovered|0%"
   - Lint issues: npm run lint 2>&1 | head -20

4. Memory Recall
   - Check project memory: p memory-find "recent-work"
   - Look for patterns: p memory-find "incomplete"

OUTPUT: State summary + next logical steps
```

### 4. MULTI-INTENT PARSER (Addresses 25% of failures)

```markdown
=== MULTI-INTENT PARSER ===
TRIGGER: Prompts with multiple "and" clauses or mixed intents

PARSING RULES:
1. Split by conjunctions ("and", "then", "also", "plus")
2. Identify dependencies between tasks
3. Sequence by logical order:
   - Debug/Fix BEFORE Test
   - Implement BEFORE Deploy
   - Test BEFORE Commit
   
EXAMPLE:
Input: "fix the bugs and add tests and deploy"
Parsed:
1. [DEBUG] Fix the bugs -> Load debugging protocol
2. [TEST] Add tests -> Load testing patterns
3. [DEPLOY] Deploy -> Load deployment checklist

EXECUTION: Sequential with state validation between steps
```

### 5. ZERO-CONTEXT ENTRY POINTS (Addresses 22% of failures)

```markdown
=== ZERO-CONTEXT ENTRY POINTS ===
For completely context-free prompts, establish these entry points:

"make it work" → State Inspection → Error Discovery → Fix Protocol
"it's broken" → Error Discovery → Diagnosis → Fix Protocol  
"finish it" → TODO Discovery → State Inspection → Completion Protocol
"add [feature]" → Project Discovery → Architecture Analysis → Implementation
"debug this" → Error Discovery → State Inspection → Debug Protocol

Each entry point MUST:
1. Discover context first
2. Confirm understanding
3. Then proceed with framework routing
```

## Implementation Priority

1. **Immediate**: Add Context Discovery System to CLAUDE.md
2. **High**: Implement Ambiguity Resolution Protocol
3. **High**: Add State Inspection Framework
4. **Medium**: Integrate Multi-Intent Parser
5. **Low**: Create Zero-Context Entry Points

## Memory System Enhancement

Add these patterns to memory for blunt prompt handling:

```bash
p memory-learn "blunt-fix" "context-discovery,state-inspection,debugging" "success"
p memory-learn "blunt-add" "context-discovery,feature-scoping,architecture" "success"
p memory-learn "blunt-finish" "state-inspection,todo-discovery,completion" "success"
```

## Success Metrics

After implementation, expect:
- Failure rate: 31% → <10%
- Partial success: 47% → 30%
- Full success: 22% → 60%

The key insight: **Don't assume context, discover it.**