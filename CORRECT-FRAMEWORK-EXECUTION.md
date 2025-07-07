# Correct Framework Execution Example

When given: "complete this project using the framework"

## ❌ WHAT NOT TO DO (Agent's Failure)
```
1. Create todo list
2. Start implementing features
3. Fix errors
4. Done
```

## ✅ WHAT TO DO (Framework Compliant)

### Step 1: Load ML/LLM Scientist FIRST
```bash
cat personas/ml-llm-scientist.md
echo "ML/LLM scientist loaded" >> .framework-compliance.log
```

### Step 2: Refine the Request
- Analyze: "complete this project" is vague
- Discover: What project? What state? What's incomplete?
- Use Context Discovery Protocol

### Step 3: Load Required Context Files IN ORDER
```bash
cat context/about-ben.md
echo "about-ben.md loaded" >> .framework-compliance.log

cat context/workflow.md  
echo "workflow.md loaded" >> .framework-compliance.log

cat context/tech-stack.md
echo "tech-stack.md loaded" >> .framework-compliance.log
```

### Step 4: Run Framework Check
```bash
p framework-check
# Should show all green checkmarks
```

### Step 5: Follow workflow.md EXACTLY
The 12-step workflow includes:
1. Architecture design
2. Project board creation  
3. Task creation
4. Expert review by multiple personas
5. Implementation (only after review)
6. Testing
7. Multi-agent review
8. Git commits with specific format

### Step 6: Select Archetype
```bash
# Identify project type
ls archetypes/
# Select appropriate one
cat archetypes/[selected].md
echo "[archetype-name]" > .selected-archetype
```

### Step 7: Expert Analysis BEFORE Implementation
```bash
# Load multiple expert personas
cat personas/architect.md
cat personas/security-expert.md
cat personas/developer.md

# Create analysis document
# Review architecture
# Plan implementation
```

### Step 8: Create Git Commits Per Framework
```bash
# Framework specifies exact commit format:
git add .
git commit -m "$(cat <<'EOF'
[TYPE]: Brief description

Detailed explanation

🤖 Generated with Claude Code
Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

## Key Differences

| Framework Requirement | Agent Did | Should Have Done |
|----------------------|-----------|------------------|
| ML/LLM Scientist First | ❌ Skipped | ✅ Load and refine |
| Context Files | ❌ Skipped | ✅ Load all 3 in order |
| Framework Check | ❌ Never ran | ✅ Run p framework-check |
| Multi-agent Review | ❌ Skipped | ✅ Multiple expert reviews |
| Git Commits | ❌ Zero commits | ✅ Proper commit format |
| Test Suite | ❌ Partial | ✅ Complete test suite |

## Enforcement

The framework now includes:
- `p framework-check` command in p-cli
- Mandatory compliance logging
- Pre-implementation gate that blocks progress
- Clear action items for violations

This ensures agents cannot skip framework steps and jump straight to implementation.