# CLAUDE Framework Context Persistence Guide

## The Problem
Claude Code uses context compaction that can drop CLAUDE.md from active memory during long conversations, causing the framework to stop functioning properly.

## Understanding Context Management

### How Claude Code Manages Context
1. **Finite Context Window**: Limited to ~200,000 tokens
2. **FIFO Management**: Older content dropped when window fills
3. **No Native Persistence**: Context doesn't persist between sessions
4. **Compaction Events**: Triggered at ~70% capacity or via `/compact`

### What Gets Prioritized
- Recent messages and tool outputs
- System reminders (but not immune to pruning)
- Active task context
- No built-in mechanism for "sticky" content

## Solution: Multi-Layer Persistence Strategy

### 1. Framework Refresh Triggers
Add these to CLAUDE.md to ensure periodic reloading:

```markdown
=== CONTEXT PERSISTENCE CHECKS ===
TRIGGER: Every 10 operations OR when you notice:
- Missing framework guidance
- Routing decisions without framework
- No memory system usage
- Generic responses without persona loading

ACTION: Immediately run:
`grep -c "PRIMARY DIRECTIVE" CLAUDE.md || (echo "Framework lost - reloading" && cat CLAUDE.md > /dev/null)`
```

### 2. Memory-Based Recovery
Store critical framework elements in memory:

```bash
# One-time setup (add to framework init)
p memory-learn "framework-core" "CLAUDE.md" "critical-always-load"
p memory-learn "ml-llm-first" "personas/ml-llm-scientist.md" "always-execute-first"
p memory-learn "safety-net" "examples/protocols/error-recovery.md" "on-any-error"

# Recovery trigger (add to CLAUDE.md)
=== FRAMEWORK RECOVERY ===
IF framework_not_responding:
    THEN: p memory-find "framework-core"
    AND: Reload CLAUDE.md based on memory
```

### 3. Compact-Resistant Structure
Modify CLAUDE.md structure to survive compaction:

```markdown
=== 🚨 CRITICAL PERSISTENT RULES 🚨 ===
[NEVER REMOVE - CORE FRAMEWORK]
1. ML/LLM scientist refinement ALWAYS first
2. Load ./personas/ml-llm-scientist.md before ANY processing
3. On errors: load ./examples/protocols/error-recovery.md
4. Memory operations via p-cli commands
5. Check framework health every 10 operations

[COMPACT-SAFE REFERENCE]
Primary: CLAUDE.md | Workflow: context/workflow.md | Memory: p memory-* commands
```

### 4. File Naming Reinforcement
Create marker files that remind about framework:

```bash
# Create framework markers
touch .claude-framework-active
echo "If you see this file, ensure CLAUDE.md is loaded" > ALWAYS-CHECK-CLAUDE.md
```

### 5. User Training Prompts
Add to README:

```markdown
## Maintaining Framework Context

If Claude Code seems to forget the framework:
1. Say: "Check CLAUDE.md framework status"
2. Or: "Reload CLAUDE framework if needed"
3. Or: "Use p memory-find framework-core"

For long sessions, periodically ask:
- "Are you still following CLAUDE.md?"
- "Show current framework routing decision"
```

### 6. Enhanced P-CLI Integration
Add framework health check to p:

```bash
framework-health)
    echo "🔍 Checking CLAUDE framework status..."
    
    # Check if CLAUDE.md accessible
    if grep -q "PRIMARY DIRECTIVE" CLAUDE.md 2>/dev/null; then
        echo "✅ CLAUDE.md accessible"
    else
        echo "❌ CLAUDE.md not found - reloading needed"
    fi
    
    # Check recent memory usage
    RECENT_MEMORY=$(find "$MEMORY_DIR" -mmin -30 -name "*.jsonl" | wc -l)
    if [ "$RECENT_MEMORY" -gt 0 ]; then
        echo "✅ Memory system active (${RECENT_MEMORY} recent operations)"
    else
        echo "⚠️  No recent memory activity"
    fi
    
    # Suggest recovery if needed
    if [ "$RECENT_MEMORY" -eq 0 ]; then
        echo "💡 Run: p memory-find 'framework-core' to restore"
    fi
    ;;
```

## Implementation Checklist

### Immediate Actions
- [ ] Add CONTEXT PERSISTENCE CHECKS section to CLAUDE.md
- [ ] Implement framework-health command in p-cli
- [ ] Create one-time memory storage for critical components
- [ ] Add compact-resistant structure to CLAUDE.md

### User Documentation
- [ ] Update README with context persistence guidance
- [ ] Add troubleshooting section for framework loss
- [ ] Create quick recovery commands

### Monitoring
- [ ] Watch for patterns of framework dropping
- [ ] Track context usage percentage when shown
- [ ] Note conversation length when issues occur

## Quick Recovery Commands

When framework seems lost:
```bash
# Quick check and reload
cat CLAUDE.md && echo "Framework reloaded"

# Memory-based recovery
p memory-find "framework-core"
p framework-health

# Force full reload
echo "=== RELOADING FRAMEWORK ===" && \
cat CLAUDE.md && \
cat context/workflow.md && \
cat personas/ml-llm-scientist.md
```

## Best Practices

1. **Start Strong**: Always begin sessions with explicit CLAUDE.md reference
2. **Check Periodically**: Every 10-15 messages, verify framework active
3. **Use Memory**: Store successful patterns to enable quick recovery
4. **Compact Wisely**: Before `/compact`, ensure critical items in memory
5. **Watch Context**: When approaching 70% full, proactively refresh

## Warning Signs Framework Is Lost
- Generic responses without routing logic
- No persona loading for specialized tasks  
- Missing memory system operations
- No ML/LLM scientist refinement step
- Errors without loading recovery protocols

## Emergency Recovery
If all else fails:
```
Please reload the CLAUDE framework by reading CLAUDE.md and ensure you're following the ML/LLM scientist refinement process as the first step for all requests.
```

Remember: Context persistence requires active management - there's no "set and forget" solution in Claude Code's current architecture.