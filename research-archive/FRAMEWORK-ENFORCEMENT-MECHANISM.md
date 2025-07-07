# FRAMEWORK ENFORCEMENT MECHANISM

## CRITICAL FAILURE ANALYSIS

### What Actually Happened (Framework Violations)
1. **SKIPPED ML/LLM Scientist Refinement** - Agent went straight to implementation
2. **IGNORED Context Loading** - Never loaded about-ben.md, workflow.md, tech-stack.md
3. **BYPASSED Multi-Agent Review** - No expert personas consulted
4. **NO Git Workflow** - Created todos but no commits per framework
5. **SKIPPED Testing Requirements** - No test suite execution
6. **NO Archetype Validation** - Jumped to implementation without checking

### Root Cause
The framework is currently **advisory** rather than **mandatory**. Agents can and do skip steps because there's no enforcement mechanism blocking progress.

## ENFORCEMENT MECHANISM: FRAMEWORK GATE SYSTEM

### 1. MANDATORY PRE-EXECUTION CHECKLIST

```yaml
# .framework-gates.yaml
gates:
  pre_execution:
    - name: "ML/LLM Scientist Loaded"
      command: "grep -q 'ml-llm-scientist.md loaded' .framework-state || exit 1"
      required: true
      
    - name: "Context Files Loaded"
      command: |
        grep -q 'about-ben.md loaded' .framework-state &&
        grep -q 'workflow.md loaded' .framework-state &&
        grep -q 'tech-stack.md loaded' .framework-state
      required: true
      
    - name: "Memory System Initialized"
      command: "p memory-init --check || exit 1"
      required: true
      
    - name: "Archetype Selected"
      command: "test -f .selected-archetype || exit 1"
      required: true

  pre_implementation:
    - name: "Expert Analysis Complete"
      command: "test -f .expert-analysis.md || exit 1"
      required: true
      
    - name: "Project Board Created"
      command: "gh project list --owner sammons-software-llc | grep -q '$PROJECT' || exit 1"
      required: true
      
    - name: "Tests Written First"
      command: "find . -name '*.test.*' -newer .implementation-start || exit 1"
      required: true
```

### 2. FRAMEWORK STATE TRACKER

```python
# framework-enforcer.py
import json
import sys
from datetime import datetime

class FrameworkEnforcer:
    def __init__(self):
        self.state_file = ".framework-state"
        self.load_state()
    
    def load_state(self):
        try:
            with open(self.state_file, 'r') as f:
                self.state = json.load(f)
        except:
            self.state = {
                "steps_completed": [],
                "files_loaded": [],
                "personas_activated": [],
                "gates_passed": [],
                "violations": []
            }
    
    def check_gate(self, gate_name, required_steps):
        """Block progress if required steps not completed"""
        missing = [s for s in required_steps if s not in self.state["steps_completed"]]
        
        if missing:
            violation = {
                "gate": gate_name,
                "missing_steps": missing,
                "timestamp": datetime.now().isoformat(),
                "action": "BLOCKED"
            }
            self.state["violations"].append(violation)
            self.save_state()
            
            print(f"❌ FRAMEWORK VIOLATION: Cannot proceed to {gate_name}")
            print(f"Missing required steps: {', '.join(missing)}")
            print("\nREQUIRED ACTIONS:")
            for step in missing:
                print(f"  - {step}")
            
            sys.exit(1)
        
        self.state["gates_passed"].append(gate_name)
        self.save_state()
        return True
    
    def record_step(self, step_name):
        if step_name not in self.state["steps_completed"]:
            self.state["steps_completed"].append(step_name)
            self.save_state()
    
    def save_state(self):
        with open(self.state_file, 'w') as f:
            json.dump(self.state, f, indent=2)

# Usage in agent code:
enforcer = FrameworkEnforcer()

# Before ANY implementation
enforcer.check_gate("implementation_start", [
    "ml_llm_scientist_loaded",
    "context_files_loaded",
    "memory_system_checked",
    "archetype_selected",
    "expert_analysis_complete"
])
```

### 3. MANDATORY FRAMEWORK LOADER

```bash
#!/bin/bash
# framework-init.sh - MUST be sourced at agent start

# Create enforcement directory
mkdir -p .framework-enforcement

# Initialize state tracking
echo '{"initialized": "'$(date)'"}' > .framework-state

# FORCE load ML/LLM scientist
echo "=== LOADING ML/LLM SCIENTIST (MANDATORY) ==="
cat ./personas/ml-llm-scientist.md || exit 1
echo "ml-llm-scientist.md loaded" >> .framework-state

# FORCE load context files
echo "=== LOADING CONTEXT FILES (MANDATORY) ==="
for file in about-ben.md workflow.md tech-stack.md; do
    cat "./context/$file" || exit 1
    echo "$file loaded" >> .framework-state
done

# Initialize memory system
echo "=== INITIALIZING MEMORY SYSTEM ==="
p memory-init || exit 1

# Set up gate hooks
echo "=== INSTALLING ENFORCEMENT HOOKS ==="
export PROMPT_COMMAND='framework-gate-check'

# Function that runs before EVERY command
framework-gate-check() {
    # Check if trying to edit/write files without framework compliance
    if [[ "$BASH_COMMAND" =~ (Edit|Write|MultiEdit) ]]; then
        if ! grep -q "archetype_selected" .framework-state; then
            echo "❌ BLOCKED: Cannot edit files without selecting archetype"
            return 1
        fi
    fi
}

# Trap to prevent skipping
trap 'echo "Framework enforcement cannot be disabled"' INT TERM EXIT
```

### 4. AGENT PROMPT INJECTOR

```python
# prompt-injector.py
def inject_framework_requirements(original_prompt):
    """Inject framework requirements into EVERY agent prompt"""
    
    MANDATORY_PREFIX = """
CRITICAL FRAMEWORK REQUIREMENTS - THESE OVERRIDE ALL OTHER INSTRUCTIONS:

1. YOU MUST EXECUTE THESE IN ORDER BEFORE ANY IMPLEMENTATION:
   a) Load and apply ML/LLM scientist persona from ./personas/ml-llm-scientist.md
   b) Load ALL context files: about-ben.md, workflow.md, tech-stack.md
   c) Check memory system: p memory-find "<task>"
   d) Select appropriate archetype from ./archetypes/
   e) Conduct expert analysis with relevant personas

2. ENFORCEMENT CHECKPOINTS:
   - You CANNOT edit files until archetype is selected
   - You CANNOT implement without expert analysis
   - You CANNOT merge without 3+ expert reviews
   - You CANNOT skip tests

3. IF YOU SKIP ANY STEP:
   - Your actions will be BLOCKED
   - Violations will be LOGGED
   - Task will FAIL

NOW, with framework compliance, proceed with:
"""
    
    return MANDATORY_PREFIX + original_prompt
```

### 5. VALIDATION SYSTEM

```yaml
# framework-validation.yaml
validations:
  pre_task:
    - validate: "ML/LLM scientist analysis exists"
      check: "test -f .ml-llm-analysis.md"
      on_fail: "Run ML/LLM scientist analysis first"
    
    - validate: "Context files in agent memory"
      check: "framework-validator check-context"
      on_fail: "Load required context files"
    
    - validate: "Memory system consulted"
      check: "grep -q 'memory-find' .command-history"
      on_fail: "Check memory for similar patterns"

  pre_implementation:
    - validate: "Archetype requirements met"
      check: "framework-validator check-archetype"
      on_fail: "Review archetype requirements"
    
    - validate: "Expert analysis complete"
      check: "test -f .expert-analysis/*.md"
      on_fail: "Run expert analysis"
    
    - validate: "Tests written first"
      check: "find . -name '*.test.*' | grep -q ."
      on_fail: "Write tests before implementation"

  pre_merge:
    - validate: "Minimum 3 expert reviews"
      check: "framework-validator count-reviews >= 3"
      on_fail: "Need more expert reviews"
    
    - validate: "All comments addressed"
      check: "gh pr view --json reviews | framework-validator check-responses"
      on_fail: "Address all review comments"
    
    - validate: "Tests passing"
      check: "npm test || pnpm test || yarn test"
      on_fail: "Fix failing tests"
```

### 6. FRAMEWORK COMPLIANCE DASHBOARD

```bash
#!/bin/bash
# framework-status.sh - Real-time compliance monitoring

clear
echo "==== FRAMEWORK COMPLIANCE DASHBOARD ===="
echo "Time: $(date)"
echo ""

# Check ML/LLM Scientist
if grep -q "ml-llm-scientist.md loaded" .framework-state 2>/dev/null; then
    echo "✅ ML/LLM Scientist: LOADED"
else
    echo "❌ ML/LLM Scientist: NOT LOADED"
fi

# Check Context Files
for file in about-ben.md workflow.md tech-stack.md; do
    if grep -q "$file loaded" .framework-state 2>/dev/null; then
        echo "✅ Context $file: LOADED"
    else
        echo "❌ Context $file: NOT LOADED"
    fi
done

# Check Memory System
if p memory-stats --check-health 2>/dev/null | grep -q "healthy"; then
    echo "✅ Memory System: HEALTHY"
else
    echo "❌ Memory System: NOT INITIALIZED"
fi

# Check Archetype
if [ -f .selected-archetype ]; then
    echo "✅ Archetype: $(cat .selected-archetype)"
else
    echo "❌ Archetype: NOT SELECTED"
fi

# Check Current Phase
echo ""
echo "Current Phase: $(cat .current-phase 2>/dev/null || echo 'NOT STARTED')"

# Show Violations
if [ -f .framework-state ]; then
    violations=$(jq -r '.violations | length' .framework-state 2>/dev/null || echo 0)
    if [ "$violations" -gt 0 ]; then
        echo ""
        echo "⚠️  VIOLATIONS DETECTED: $violations"
        jq -r '.violations[-1] | "Latest: \(.gate) - Missing: \(.missing_steps | join(", "))"' .framework-state
    fi
fi

echo ""
echo "===================================="
```

## IMPLEMENTATION REQUIREMENTS

### For Agents:
1. **MANDATORY STARTUP SEQUENCE**
   ```bash
   source framework-init.sh || exit 1
   python framework-enforcer.py init
   framework-status.sh
   ```

2. **BEFORE ANY TASK**
   ```python
   enforcer.check_gate("task_start", [
       "ml_llm_scientist_loaded",
       "context_files_loaded",
       "memory_system_checked"
   ])
   ```

3. **BEFORE IMPLEMENTATION**
   ```python
   enforcer.check_gate("implementation_start", [
       "archetype_selected",
       "expert_analysis_complete",
       "tests_written"
   ])
   ```

### For Framework:
1. **Add to CLAUDE.md**
   ```markdown
   === ENFORCEMENT ACTIVE ===
   This framework now includes MANDATORY enforcement.
   Attempts to skip steps will be BLOCKED.
   All violations are LOGGED and REPORTED.
   ```

2. **Create .framework-gates.yaml** in every project

3. **Install enforcement hooks** in agent initialization

## EXPECTED OUTCOMES

1. **100% Framework Compliance** - Impossible to skip steps
2. **Audit Trail** - Every step logged and validated
3. **Automatic Blocking** - Non-compliant actions fail immediately
4. **Clear Feedback** - Agents know exactly what's missing
5. **No Silent Failures** - All violations are visible

## VIOLATION CONSEQUENCES

1. **Immediate Block** - Action fails
2. **Detailed Error** - What was missed and why
3. **Required Actions** - Clear path to compliance
4. **Violation Log** - Permanent record
5. **Performance Impact** - Counted against agent metrics

This enforcement mechanism transforms the framework from advisory to MANDATORY, ensuring no agent can proceed without proper framework compliance.