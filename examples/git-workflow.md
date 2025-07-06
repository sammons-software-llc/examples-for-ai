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