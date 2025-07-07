# General Clarification Protocol

## Purpose
Handle ambiguous requests that don't fit into specific categories, ensuring efficient clarification without frustrating the user.

## Activation Triggers
- Extremely vague requests: "help", "do the thing", "you know what to do"
- Multi-interpretation prompts
- Conflicting requirements
- Missing critical context
- Unclear success criteria

## Clarification Strategy

### Step 1: Intent Classification (30 seconds)

Quickly categorize the likely intent:

```markdown
## Intent Analysis Matrix

### Category A: Task Continuation
Signs: "continue", "keep going", "finish", "next"
→ Check: Recent work, TODOs, git history

### Category B: Problem Solving  
Signs: "help", "stuck", "not sure", "doesn't work"
→ Check: Errors, failures, blockers

### Category C: Feature Request
Signs: "need", "want", "should have", "missing"
→ Check: Feature gaps, enhancement opportunities

### Category D: Information Seeking
Signs: "how", "what", "explain", "show"
→ Check: Documentation needs, examples

### Category E: Decision Making
Signs: "which", "should I", "better", "best"
→ Check: Alternatives, trade-offs
```

### Step 2: Context Gathering (1 minute)

```bash
# Quick context scan
echo "=== Project Quick Scan ==="
# Project type
ls -la | grep -E "package.json|Cargo.toml|pyproject.toml|go.mod|pom.xml" | head -5

# Recent activity
echo "=== Recent Activity ==="
find . -type f -mtime -1 | grep -v node_modules | grep -v ".git" | head -10

# Current git state
echo "=== Git State ==="
git status --short 2>/dev/null | head -10
git log --oneline -5 2>/dev/null

# Running processes
echo "=== Active Processes ==="
ps aux | grep -E "node|python|java|cargo" | grep -v grep | head -5
```

### Step 3: Smart Clarification

Based on context, ask ONE high-value question:

#### Pattern A: Zero Context
```markdown
I want to help! I see you're working on a [detected project type] project. 

What would you like me to help with?
- 🔧 Fix something that's broken
- ✨ Add a new feature
- 📖 Explain how something works
- 🔍 Review code or find issues
- 💡 Something else: ___
```

#### Pattern B: Partial Context
```markdown
I see you're working on [specific file/feature] with recent changes to [what changed].

Are you looking to:
A) Continue the work on [specific task detected]
B) Fix an issue with [potential problem area]
C) Add something new to [relevant component]
D) Something else specific?
```

#### Pattern C: Multiple Interpretations
```markdown
Your request could mean a few things:

1. **[Most likely interpretation]**
   - What: [Specific action]
   - Where: [Location/scope]
   
2. **[Second interpretation]**
   - What: [Alternative action]
   - Where: [Different scope]

3. **[Third interpretation]**
   - What: [Another possibility]
   - Where: [Another scope]

Which matches your intent? (1/2/3/other)
```

### Step 4: Efficient Clarification Techniques

#### The 3W Technique
```markdown
To help effectively, I need to understand:
- **What**: What specific outcome do you want?
- **Where**: What part of the system/code?
- **Why**: What problem does this solve?

Quick example: "What: Add user login, Where: Frontend React app, Why: Secure user access"
```

#### The Example Technique
```markdown
Could you give me an example? Something like:
- "Make the API endpoint return user data with their posts"
- "Fix the login button that's not responding" 
- "Add dark mode to the settings page"
- "Explain how the payment processing works"
```

#### The Multiple Choice Technique
```markdown
I'll list some common tasks - pick the closest one:

**Code Changes:**
□ Fix a bug/error
□ Add new feature
□ Refactor/improve existing code
□ Update dependencies

**Information:**
□ Explain how something works
□ Find specific code/files
□ Review for issues
□ Best practices advice

**Setup/Config:**
□ Environment setup
□ Deployment help
□ Configuration issues
□ Tool installation

**Other:** Please describe: ___
```

### Step 5: Progressive Refinement

If first clarification doesn't work, progressively narrow:

#### Round 1: Broad Categories
"Is this about: Code / Setup / Debugging / Documentation / Other?"

#### Round 2: Specific Area  
"Which part: Frontend / Backend / Database / API / Tests / Config?"

#### Round 3: Concrete Example
"Can you show me: An error message / The file you're working on / What you tried?"

### Step 6: Fallback Strategies

If clarification fails after 2 rounds:

```markdown
## Let's Try a Different Approach

Instead of me guessing, would you mind:

1. **Showing me something specific**:
   - Paste an error message
   - Point to a file: "Look at src/components/Header.js"
   - Share what you tried: "I ran npm start and..."

2. **Or describe the problem/goal in detail**:
   - Current state: "Right now, the app..."
   - Desired state: "I want it to..."
   - Blockers: "But I can't because..."

3. **Or let me explore and suggest**:
   I can analyze your project and suggest common improvements?
```

## Memory Integration

```bash
# Learn from ambiguous requests
p memory-learn "ambiguous-request" "$ORIGINAL_REQUEST $CLARIFIED_INTENT" "resolved"

# Find similar patterns
p memory-find "clarification pattern"

# Store successful clarification paths
p memory-learn "clarification-success" "$TECHNIQUE_USED $ROUNDS_NEEDED" "effective"
```

## Response Templates

### Template 1: Friendly and Efficient
```markdown
I'd love to help! To make sure I understand correctly:

You want to: [best guess based on context]
Is that right? 

If not, what specifically would you like help with?
```

### Template 2: Proactive Discovery
```markdown
I see several things I could help with in your project:

1. 🔴 Fix: [Detected issue or test failure]
2. 🟡 Complete: [Found TODO or incomplete feature]
3. 🟢 Enhance: [Possible improvement area]
4. 🔵 Other: Something else entirely

Which would be most helpful right now? (1-4)
```

### Template 3: Context-Building
```markdown
Let me understand your situation better:

**Currently**: [What I can see from the project]
**You said**: "[Original request]"

This could mean:
- Option A: [Interpretation]
- Option B: [Interpretation]

Could you either:
1. Pick an option (A/B)
2. Or tell me more specifically what you need?
```

## Quick Decision Tree

```
User says something vague
    ↓
Is it 1-3 words? → YES → Use Multiple Choice Technique
    ↓ NO
Can I detect context? → YES → Use Partial Context Pattern
    ↓ NO
Are there multiple interpretations? → YES → Use Multiple Interpretations Pattern
    ↓ NO
Use 3W Technique or Example Technique
    ↓
Still unclear after 1 round? → Use Progressive Refinement
    ↓
Still unclear after 2 rounds? → Use Fallback Strategies
```

## Success Metrics
- Clarification success rate: > 95%
- Rounds needed: ≤ 2 average
- User frustration: < 5%
- Time to clarity: < 2 minutes
- Successful task completion after clarification: > 90%

## Anti-Patterns to Avoid
- Don't ask too many questions at once
- Don't use technical jargon in clarifications
- Don't make user repeat everything
- Don't guess wildly without evidence
- Don't give up - always offer alternatives

## Conversation Samples

### Sample 1: "Help"
```
User: help