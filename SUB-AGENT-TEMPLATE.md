# Sub-Agent Prompt Template

When spawning sub-agents, use this template to ensure they follow the CLAUDE framework:

## Template for Remote Framework Usage

```
[YOUR TASK DESCRIPTION HERE]

IMPORTANT: First, fetch and read the CLAUDE framework:
gh api repos/sammons-software-llc/examples-for-ai/contents/CLAUDE.md --jq '.content' | base64 -d > CLAUDE.md
cat CLAUDE.md

Follow the CLAUDE.md framework EXACTLY, including:
1. ML/LLM scientist refinement as the first step
2. Loading appropriate personas and contexts from GitHub
3. Using memory system for patterns

When the framework references files like ./personas/developer.md, fetch them using:
gh api repos/sammons-software-llc/examples-for-ai/contents/personas/developer.md --jq '.content' | base64 -d

DO NOT try to read framework files locally - always fetch from GitHub.
```

## Template for Local Framework Usage (Same Repository)

```
[YOUR TASK DESCRIPTION HERE]

IMPORTANT: Read and follow the CLAUDE framework:
cat CLAUDE.md

The framework is already present in this repository. Follow it EXACTLY, including:
1. ML/LLM scientist refinement as the first step
2. Loading appropriate personas and contexts
3. Using memory system via p-cli commands
```

## Common Mistakes to Avoid

1. **DON'T** spawn agents without framework instructions
2. **DON'T** let agents try to read remote files locally
3. **DON'T** forget to specify whether framework is local or remote
4. **DO** always include "Read CLAUDE.md first" in the prompt
5. **DO** specify the GitHub repository path for remote files

## Example: Correct Sub-Agent Spawning

### For New Project (Remote Framework)
```
Create a React authentication system.

IMPORTANT: First, fetch and read the CLAUDE framework:
gh api repos/sammons-software-llc/examples-for-ai/contents/CLAUDE.md --jq '.content' | base64 -d > CLAUDE.md
cat CLAUDE.md

Follow the CLAUDE.md framework EXACTLY. When loading personas or examples, use GitHub API:
gh api repos/sammons-software-llc/examples-for-ai/contents/[path] --jq '.content' | base64 -d
```

### For Existing Project (Local Framework)
```
Review the security of our authentication system.

IMPORTANT: Read and follow the CLAUDE framework:
cat CLAUDE.md

Load the security-expert persona as specified in the framework and conduct a thorough review.
```