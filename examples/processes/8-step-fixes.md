# 8-Step Process for Updates and Fixes

Use this process when user request contains: ["fix", "update", "modify", "patch", "refactor"]

## Quick Fix Workflow

### 1. Assess Current State
```bash
git status && git branch
pnpm test -- --run
pnpm run lint:check
```

### 2. Create Fix Branch
```bash
git checkout main && git pull
git checkout -b fix/[description]
```

### 3. Write Failing Test (if bug fix)
```typescript
it('should handle [edge case]', () => {
  expect(buggyFunction()).not.toThrow()
})
```

### 4. Implement Fix
- Minimal changes only
- Preserve existing functionality
- Follow existing code patterns

### 5. Validate Fix
```bash
pnpm test -- --run
pnpm run lint:check
pnpm run type-check
```

### 6. Create PR
```bash
git add -A && git commit -m "fix: [description]"
git push -u origin fix/[description]
gh pr create --title "fix: [description]"
```

### 7. Address Reviews
- Respond within existing PR
- Push additional commits

### 8. Merge
```bash
gh pr merge --squash --delete-branch
```

## Key Differences from 20-Step Process
- No sub-agent spawning required
- No architecture phase
- Single developer persona
- Focused scope (one issue)
- Faster turnaround (hours not days)