# Remote File Reference Guide

## Quick Conversion Table

When CLAUDE.md references a local file path, use the GitHub API equivalent:

| Framework Reference | GitHub API Command |
|-------------------|-------------------|
| `./personas/developer.md` | `gh api repos/sammons-software-llc/examples-for-ai/contents/personas/developer.md --jq '.content' \| base64 -d` |
| `./context/workflow.md` | `gh api repos/sammons-software-llc/examples-for-ai/contents/context/workflow.md --jq '.content' \| base64 -d` |
| `./archetypes/serverless-aws.md` | `gh api repos/sammons-software-llc/examples-for-ai/contents/archetypes/serverless-aws.md --jq '.content' \| base64 -d` |
| `./examples/testing-patterns.md` | `gh api repos/sammons-software-llc/examples-for-ai/contents/examples/testing-patterns.md --jq '.content' \| base64 -d` |

## Complete Fetch Pattern

```bash
# Step 1: Fetch the file
gh api repos/sammons-software-llc/examples-for-ai/contents/[PATH] --jq '.content' | base64 -d > [FILENAME]

# Step 2: Read the file
cat [FILENAME]
```

## Common Personas to Fetch

```bash
# Developer
gh api repos/sammons-software-llc/examples-for-ai/contents/personas/developer.md --jq '.content' | base64 -d > developer.md

# Security Expert  
gh api repos/sammons-software-llc/examples-for-ai/contents/personas/security-expert.md --jq '.content' | base64 -d > security-expert.md

# ML/LLM Scientist (ALWAYS FIRST!)
gh api repos/sammons-software-llc/examples-for-ai/contents/personas/ml-llm-scientist.md --jq '.content' | base64 -d > ml-llm-scientist.md

# Architect
gh api repos/sammons-software-llc/examples-for-ai/contents/personas/architect.md --jq '.content' | base64 -d > architect.md

# UX Designer
gh api repos/sammons-software-llc/examples-for-ai/contents/personas/ux-designer.md --jq '.content' | base64 -d > ux-designer.md
```

## Core Context Files

```bash
# About Ben (user preferences)
gh api repos/sammons-software-llc/examples-for-ai/contents/context/about-ben.md --jq '.content' | base64 -d > about-ben.md

# Workflow (agent orchestration)
gh api repos/sammons-software-llc/examples-for-ai/contents/context/workflow.md --jq '.content' | base64 -d > workflow.md

# Tech Stack (technical requirements)
gh api repos/sammons-software-llc/examples-for-ai/contents/context/tech-stack.md --jq '.content' | base64 -d > tech-stack.md
```

## Error Recovery

```bash
# ALWAYS load on errors
gh api repos/sammons-software-llc/examples-for-ai/contents/examples/protocols/error-recovery.md --jq '.content' | base64 -d > error-recovery.md
```

## Pro Tips

1. **Batch Downloads**: Fetch all needed files at once
2. **Check First**: Use `ls` to see if files already exist locally
3. **Memory Pattern**: Store successful fetches in memory with `p memory-learn`
4. **Error Handling**: If API fails, check your GitHub authentication with `gh auth status`