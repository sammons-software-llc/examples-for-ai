=== CONTEXT ===
Git workflow examples and templates for consistent version control practices.
Follow these patterns for all repository interactions.

=== BRANCH STRATEGY ===
Branch Naming:
```bash
feature/task-id-description   # New features
fix/task-id-description       # Bug fixes
chore/task-id-description     # Maintenance tasks
docs/task-id-description      # Documentation only
```

Workflow:
```bash
# Start new feature
git checkout main
git pull origin main
git checkout -b feature/TASK-123-user-authentication

# Work on feature
git add -A
git commit -m "[TASK-123]: Add user authentication

Implement JWT-based authentication with refresh tokens.

- auth-handler.ts: Add login/logout endpoints
- auth-strategy.ts: Implement token generation and validation
- user-repository.ts: Add session management methods"

# Push feature branch
git push -u origin feature/TASK-123-user-authentication
```

=== COMMIT MESSAGE FORMAT ===
Standard Format:
```
[Task-ID]: Brief description (50 chars max)

Detailed explanation of what changed and why. Focus on the
why rather than the what (code shows what changed).

- file1.ts: Specific change made
- file2.ts: Another specific change
- file3.test.ts: Test coverage added
```

Examples:
```
[TASK-100]: Add user profile endpoint

Implement GET /api/v1/users/:id endpoint to retrieve user
profiles. This supports the new user dashboard feature.

- get-user-handler.ts: New handler for profile retrieval
- user-strategy.ts: Add profile aggregation logic
- user-repository.ts: Add efficient query with projections
- get-user.test.ts: Comprehensive test coverage
```

```
[TASK-101]: Fix memory leak in WebSocket handler

Connection cleanup was not properly handled when clients
disconnected abruptly, causing memory accumulation.

- websocket-manager.ts: Add proper cleanup on disconnect
- connection-pool.ts: Implement connection timeout
- websocket.test.ts: Add tests for edge cases
```

=== PULL REQUEST WORKFLOW ===
Creating PR with gh CLI:
```bash
# Create PR
gh pr create \
  --title "[TASK-123]: Add user authentication" \
  --body "$(cat <<'EOF'
## Summary
- Implement JWT-based authentication system
- Add login/logout endpoints
- Include refresh token mechanism

## Changes
- New auth handlers for login/logout
- JWT token generation and validation
- Session management in database
- Comprehensive test coverage

## Testing
1. Run `pnpm test` - all tests should pass
2. Start server with `pnpm dev`
3. Test login endpoint: `POST /api/v1/auth/login`
4. Verify token in response
5. Test protected endpoints with token

## Checklist
- [x] Tests written and passing
- [x] No linting errors
- [x] TypeScript compilation successful
- [x] Manual testing completed
- [x] Documentation updated

Related to #123
EOF
)"

# Alternative: Create draft PR
gh pr create --draft --title "[WIP] Feature name"
```

=== PR REVIEW WORKFLOW ===
Reviewing a PR:
```bash
# Check out PR locally
gh pr checkout 123

# Run tests
pnpm test
pnpm lint:check
pnpm type-check

# Review changes
git diff main...HEAD

# Add review comments via gh
gh pr review 123 --comment -b "Great implementation! Few suggestions:"

# Request changes
gh pr review 123 --request-changes -b "Please address security concern in auth-handler.ts"

# Approve PR
gh pr review 123 --approve -b "LGTM! Ready to merge."
```

=== REBASE WORKFLOW ===
Squashing commits before merge:
```bash
# Ensure main is up to date
git checkout main
git pull origin main

# Go back to feature branch
git checkout feature/TASK-123-user-authentication

# Interactive rebase
git rebase -i main

# In editor, change all but first commit to 'squash'
# Edit the combined commit message

# Force push to update PR
git push --force-with-lease origin feature/TASK-123-user-authentication
```

Final squashed commit format:
```
[TASK-123]: Add complete user authentication system

Implement JWT-based authentication with refresh tokens, session
management, and comprehensive security measures.

- auth-handler.ts: Login/logout endpoints with rate limiting
- auth-strategy.ts: JWT generation with RS256 algorithm
- session-repository.ts: Secure session storage
- auth-middleware.ts: Request authentication verification
- auth.test.ts: 100% coverage of auth flows
```

=== GITHUB PROJECT BOARD ===
Task Movement with gh:
```bash
# List project boards
gh project list

# View specific project
gh project view PROJECT_NUMBER

# Move task to "In Development"
gh project item-edit --project PROJECT_NUMBER --id ITEM_ID --field Status --value "Development"

# Add comment to task
gh issue comment ISSUE_NUMBER -b "Started implementation. PR coming soon."

# After merge, move to "Merged"
gh project item-edit --project PROJECT_NUMBER --id ITEM_ID --field Status --value "Merged"

# Close issue with comment
gh issue close ISSUE_NUMBER -c "Completed in PR #123"
```

=== RELEASE WORKFLOW ===
Creating releases:
```bash
# Create annotated tag
git tag -a v1.2.0 -m "Release version 1.2.0

Features:
- User authentication system
- Profile management
- Email notifications

Bug fixes:
- Memory leak in WebSocket handler
- Race condition in session cleanup

Breaking changes:
- None"

# Push tag
git push origin v1.2.0

# Create GitHub release
gh release create v1.2.0 \
  --title "v1.2.0: Authentication Update" \
  --notes "$(cat CHANGELOG.md)" \
  --draft
```

=== MERGE STRATEGIES ===
PR Merge via CLI:
```bash
# Standard merge (after squashing commits)
gh pr merge 123 --squash --delete-branch

# Merge with custom message
gh pr merge 123 --squash --subject "[TASK-123]: Add user authentication" \
  --body "Complete authentication system with JWT tokens"

# Auto-merge when checks pass
gh pr merge 123 --auto --squash --delete-branch
```

=== COLLABORATION PATTERNS ===
Multi-agent PR workflow:
```bash
# Developer creates PR
gh pr create --title "[TASK-123]: Implement feature"

# Architect reviews
gh pr review 123 --comment -b "Architecture looks solid. Consider adding caching layer."

# Security expert reviews  
gh pr review 123 --request-changes -b "SQL injection vulnerability in line 45"

# Developer addresses feedback
git add -A
git commit -m "Address security review feedback"
git push

# Developer responds
gh pr review 123 --comment -b "Fixed SQL injection issue. Using parameterized queries now."

# Security expert approves
gh pr review 123 --approve -b "Security issues resolved. Good work!"

# Team lead merges
gh pr merge 123 --squash
```

=== GIT ALIASES ===
Useful aliases for .gitconfig:
```ini
[alias]
    # Concise log
    lg = log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
    
    # Show files changed in last commit
    last = show --name-only --oneline
    
    # Amend without editing message
    amend = commit --amend --no-edit
    
    # Reset to previous commit keeping changes
    undo = reset HEAD~1 --mixed
    
    # Show current branch
    current = rev-parse --abbrev-ref HEAD
```

=== COMMON SCENARIOS ===

### Scenario 1: Fixing a mistake in the last commit
```bash
# Made a typo in the last commit
git add -A
git commit --amend -m "[TASK-123]: Add user authentication (fixed typo)"

# Forgot to include a file
git add forgotten-file.ts
git commit --amend --no-edit
git push --force-with-lease
```

### Scenario 2: Working with stale branch
```bash
# Your branch is behind main
git checkout main
git pull
git checkout feature/my-feature
git rebase main

# Resolve conflicts if any
git add resolved-file.ts
git rebase --continue

# Update remote
git push --force-with-lease
```

### Scenario 3: Cherry-picking specific commits
```bash
# Apply specific commit from another branch
git cherry-pick abc123

# Apply multiple commits
git cherry-pick abc123..def456

# Apply commit without committing
git cherry-pick -n abc123
```

### Scenario 4: Recovering lost work
```bash
# Find lost commits
git reflog

# Recover specific commit
git checkout -b recovery-branch abc123

# View what was in a deleted branch
git log --all --grep="search term"
```

### Scenario 5: Clean working directory
```bash
# Remove untracked files (dry run first)
git clean -n
git clean -f

# Remove untracked files and directories
git clean -fd

# Reset all changes to match remote
git fetch origin
git reset --hard origin/main
```

=== TROUBLESHOOTING ===

### Issue: Accidental commit to main
```bash
# Create branch from current state
git branch feature/TASK-123

# Reset main to previous commit
git reset --hard HEAD~1

# Switch to feature branch
git checkout feature/TASK-123
```

### Issue: Large file accidentally committed
```bash
# Remove from history (requires force push)
git filter-branch --tree-filter 'rm -f path/to/large/file' HEAD

# Alternative with BFG
bfg --delete-files large-file.zip
git reflog expire --expire=now --all
git gc --prune=now --aggressive
```

### Issue: Wrong commit message after push
```bash
# Only if you're the only one working on the branch
git commit --amend -m "[TASK-123]: Correct commit message"
git push --force-with-lease

# If others are working on it, create a new commit
git commit --allow-empty -m "[TASK-123]: Correction: Previous commit actually implements X not Y"
```

=== ADVANCED PATTERNS ===

### Pattern: Bisect to find bug introduction
```bash
# Start bisect
git bisect start

# Mark current commit as bad
git bisect bad

# Mark known good commit
git bisect good v1.0.0

# Git will checkout commits to test
# After testing each:
git bisect good  # or
git bisect bad

# When done
git bisect reset
```

### Pattern: Patch workflow
```bash
# Create patch from commits
git format-patch -3  # Last 3 commits

# Apply patch
git apply --check 0001-patch.patch  # Dry run
git apply 0001-patch.patch

# Apply patch with commit info
git am 0001-patch.patch
```

### Pattern: Submodule management
```bash
# Add submodule
git submodule add https://github.com/org/repo.git lib/external

# Update submodules
git submodule update --init --recursive

# Update to latest
git submodule update --remote
```

=== COMMIT MESSAGE EXAMPLES ===

### Feature Implementation
```
[TASK-200]: Implement real-time notifications

Add WebSocket-based notification system for instant updates
to users. Supports both in-app and email notifications with
user preferences.

- notification-service.ts: Core notification logic
- websocket-handler.ts: Real-time delivery via Socket.io
- notification-preferences.ts: User preference management
- notification.test.ts: 95% test coverage
- README.md: Updated with notification API docs
```

### Bug Fix
```
[TASK-201]: Fix race condition in payment processing

Multiple simultaneous payment requests could result in 
duplicate charges due to missing transaction locking.

- payment-processor.ts: Add distributed lock via Redis
- transaction-repository.ts: Implement optimistic locking
- payment.test.ts: Add concurrent request tests
```

### Performance Improvement
```
[TASK-202]: Optimize dashboard query performance

Dashboard load time reduced from 3s to 300ms by implementing
query result caching and database index optimization.

- dashboard-repository.ts: Add Redis caching layer
- database/migrations/add-indexes.ts: Strategic indexes
- dashboard.test.ts: Add performance benchmarks
```

### Security Update
```
[TASK-203]: Patch XSS vulnerability in comment system

User-generated content was not properly sanitized before
rendering, allowing potential script injection.

- comment-handler.ts: Add DOMPurify sanitization
- render-utils.ts: Escape HTML entities
- security.test.ts: Add XSS prevention tests
```

Remember: Commit messages are documentation for future developers (including yourself). Be clear, concise, and focus on the "why" not just the "what".