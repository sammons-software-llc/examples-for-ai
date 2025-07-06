# Development Phases - Detailed Implementation Guide

## Phase 1: Project Setup and Architecture (Steps 1-5)

### 1. Identify Project Archetype
- Run `ls -la` to check for existing project files
- Check for package.json, Dockerfile, serverless.yml, or index.html
- Determine: static site, local app, serverless AWS app, or component
- If unclear, ask user: "Is this a static site, local app, AWS serverless app, or component library?"

### 2. Repository Setup
```bash
# Check if repo exists
gh repo view sammons-software-llc/[project-name] 2>/dev/null || \
gh repo create sammons-software-llc/[project-name] --private --clone

# Set up branch protection
gh api repos/sammons-software-llc/[project-name]/branches/main/protection \
  --method PUT \
  --field required_status_checks='{"strict":true,"contexts":["lint","test","build"]}' \
  --field enforce_admins=false \
  --field required_pull_request_reviews='{"required_approving_review_count":1}'
```

### 3. Expert Agent Initialization
- Spawn 4 agents simultaneously with specific prompts:
  - **Architect**: "Design the system architecture for [project-type] with focus on scalability and maintainability"
  - **Security**: "Identify security requirements and vulnerabilities for [project-type]"
  - **Designer**: "Create UI/UX patterns appropriate for [project-type]"
  - **Performance**: "Define performance benchmarks and optimization strategies"
- Each agent must produce a markdown report within their response

### 4. Dependency Verification
```bash
# Ensure pnpm is available
command -v pnpm || npm install -g pnpm@latest

# Check npm for latest versions
pnpm view typescript version
pnpm view react version
pnpm view vite version
# etc for all core dependencies

# Search for breaking changes
# WebSearch: "typescript 5.x breaking changes migration guide"
# WebSearch: "[dependency] [version] compatibility with [other-dependency]"
```

### 5. Project Board Creation
```bash
# Create project board
gh project create --owner sammons-software-llc --title "[project-name] Development"

# Add columns
gh api graphql -f query='mutation {
  addProjectColumn(input: {projectId: "[PROJECT_ID]", name: "TODO"}) { clientMutationId }
  addProjectColumn(input: {projectId: "[PROJECT_ID]", name: "Development"}) { clientMutationId }
  addProjectColumn(input: {projectId: "[PROJECT_ID]", name: "In Review"}) { clientMutationId }
  addProjectColumn(input: {projectId: "[PROJECT_ID]", name: "Testing"}) { clientMutationId }
  addProjectColumn(input: {projectId: "[PROJECT_ID]", name: "Merged"}) { clientMutationId }
}'
```

## Phase 2: Task Planning and Breakdown (Steps 6-8)

### 6. Task Decomposition
- Architect agent creates tasks with specific format:
  ```
  Title: [FEAT-001] Implement user authentication
  Body:
  ## Acceptance Criteria
  - [ ] User can register with email/password
  - [ ] Password meets security requirements (min 12 chars, mixed case, numbers, symbols)
  - [ ] JWT tokens expire after 24 hours
  - [ ] Refresh token mechanism implemented
  
  ## Technical Requirements
  - Use bcrypt with 10 rounds
  - Store sessions in Redis
  - Implement rate limiting (5 attempts per minute)
  
  ## Definition of Done
  - [ ] Unit tests achieve 90% coverage
  - [ ] Integration tests pass
  - [ ] Security scan shows no vulnerabilities
  - [ ] Documentation updated
  - [ ] Performance: Auth endpoints respond in <200ms
  ```
- Each task must be completable in <8 hours
- Complex features split into: API task, UI task, Integration task

### 7. Task Prioritization and Dependencies
```bash
# Add tasks to project board with labels
gh issue create \
  --title "[FEAT-001] Implement user authentication" \
  --body "[content from above]" \
  --label "priority:high,type:feature,size:medium" \
  --project "[project-name] Development"

# Link dependencies
gh issue comment [ISSUE_NUMBER] --body "Depends on: #[OTHER_ISSUE]"
```

### 8. Sprint Planning
- Group related tasks into implementation waves
- First wave: Core infrastructure (DB, server setup, CI/CD)
- Second wave: Core features
- Third wave: Enhanced features
- Fourth wave: Polish and optimization

## Phase 3: Implementation (Steps 9-13)

### 9. Pre-Development Setup
```bash
# Check for Node.js availability
if ! command -v node &> /dev/null; then
  echo "Node.js not found, installing via mise..."
  
  # Install mise if not present
  if ! command -v mise &> /dev/null; then
    curl https://mise.run | sh
    echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc
    source ~/.bashrc
  fi
  
  # Install Node.js 24 (latest stable)
  mise use node@24
  mise install
fi

# Verify correct Node version
REQUIRED_NODE_VERSION="24"
CURRENT_NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$CURRENT_NODE_VERSION" -lt "$REQUIRED_NODE_VERSION" ]; then
  echo "Node $CURRENT_NODE_VERSION found, but $REQUIRED_NODE_VERSION required. Installing..."
  mise use node@24
  mise install
fi

# Install pnpm if not present
if ! command -v pnpm &> /dev/null; then
  echo "Installing pnpm..."
  npm install -g pnpm@latest
fi

# Developer agent for each task
git checkout main && git pull
git checkout -b feat/[TASK-ID]-description

# Install dependencies
pnpm install

# Set up pre-commit hooks
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
pnpm run lint:check || exit 1
pnpm run type-check || exit 1
pnpm run test:unit || exit 1
EOF
chmod +x .git/hooks/pre-commit
```

### 10. Test-Driven Development
- Write tests FIRST:
  ```typescript
  // user-auth.test.ts
  describe('User Authentication', () => {
    it('should hash passwords with bcrypt rounds 10', async () => {
      const password = 'Test123!@#Pass'
      const hashed = await hashPassword(password)
      expect(hashed).toMatch(/^\$2[aby]\$10\$/)
    })
    
    it('should reject passwords under 12 characters', async () => {
      await expect(validatePassword('short')).rejects.toThrow('Password must be at least 12 characters')
    })
  })
  ```
- Run tests to see them fail: `pnpm test -- --run user-auth.test.ts`
- Implement minimum code to pass
- Refactor while keeping tests green

### 11. Implementation with Continuous Validation
```bash
# Every 10 minutes during development
pnpm run lint:check && pnpm run type-check && pnpm test -- --run

# Check bundle size for frontend
pnpm run build && du -sh dist/

# Run security scan
pnpm audit

# Check for console.logs or debugger statements
grep -r "console\.\|debugger" src/ --exclude-dir=node_modules
```

### 12. Performance Validation
- For APIs:
  ```typescript
  // In tests
  const start = performance.now()
  await request(app).get('/api/v1/users')
  const duration = performance.now() - start
  expect(duration).toBeLessThan(500) // Must be under 500ms
  ```
- For UI components:
  ```typescript
  // React performance test
  const { rerender } = render(<UserList users={mockUsers} />)
  const renderTime = measureRenderTime(() => {
    rerender(<UserList users={updatedUsers} />)
  })
  expect(renderTime).toBeLessThan(16) // One frame at 60fps
  ```

### 13. Documentation During Development
- Update API docs in code:
  ```typescript
  /**
   * @route POST /api/v1/auth/register
   * @body {email: string, password: string}
   * @response 201 {user: User, token: string}
   * @response 400 {error: 'Invalid email format' | 'Password too weak'}
   * @response 429 {error: 'Too many requests'}
   */
  ```
- Update README.md with new endpoints
- Add architecture decisions to docs/architecture/adr-[number]-[title].md

## Phase 4: Quality Assurance (Steps 14-16)

### 14. Pre-PR Validation Checklist
```bash
# All commands must pass
pnpm run lint:check                    # ESLint with 0 errors
pnpm run type-check                    # TypeScript with 0 errors  
pnpm test -- --coverage               # >90% coverage
pnpm run test:integration             # All integration tests pass
pnpm run build                        # Build succeeds
pnpm run test:e2e -- --headed         # E2E with screenshots

# Security checks
pnpm audit --audit-level=moderate    # No moderate+ vulnerabilities
grep -r "api[_-]key\|secret\|password" src/ # No hardcoded secrets

# Performance check
pnpm run test:performance             # All endpoints <500ms
```

### 15. Pull Request Creation
```bash
# Commit with specific format
git add -A
git commit -m "[FEAT-001]: Implement user authentication system

Added complete user authentication with JWT tokens, password hashing,
and rate limiting. Includes comprehensive test coverage and security measures.

- src/handlers/auth-handler.ts: JWT token generation and validation
- src/strategies/auth-strategy.ts: Business logic for authentication
- src/repositories/user-repository.ts: User data persistence
- src/middleware/rate-limit.ts: Request rate limiting
- tests/auth.test.ts: 95% test coverage achieved"

# Push and create PR
git push -u origin feat/[TASK-ID]-description

gh pr create \
  --title "[FEAT-001]: Implement user authentication system" \
  --body "## Summary
- Implements secure user authentication with JWT
- Adds rate limiting to prevent brute force attacks  
- Achieves 95% test coverage

## Checklist
- [x] Tests pass with >90% coverage
- [x] No lint or type errors
- [x] Security scan clean
- [x] Performance benchmarks met (<200ms)
- [x] Documentation updated
- [x] E2E tests include screenshots

## Screenshots
![Login Page](./screenshots/e2e/auth/login-page.png)
![Registration Flow](./screenshots/e2e/auth/registration-flow.png)

Closes #[ISSUE_NUMBER]"
```

### 16. Automated PR Checks
- GitHub Actions must run:
  - Lint check
  - Type check  
  - Unit tests with coverage report
  - Integration tests
  - Security scan
  - Bundle size check
  - Performance tests
- All checks must pass before review

## Phase 5: Review and Iteration (Steps 17-19)

### 17. Multi-Persona Expert Review
- Each expert reviews with specific focus:
  - **Security Expert**: Check for OWASP Top 10, secrets, injection vulnerabilities
  - **Performance Expert**: Review algorithms, database queries, caching strategy
  - **Architecture Expert**: Verify SOLID principles, proper separation of concerns
  - **UX Expert**: Check error messages, loading states, accessibility
- Each expert must leave specific, actionable comments with code suggestions

### 18. Developer Response Protocol
```markdown
For each review comment:
1. Acknowledge: "Good catch regarding [specific issue]"
2. Explain approach: "I'll address this by [specific solution]"
3. If disagreeing: "I chose [approach] because [specific reason]. Alternative would cause [specific problem]"
4. Implement fix with commit: "fix: Address [reviewer] feedback on [specific issue]"
```

### 19. Final Validation Round
- Re-run all tests after changes
- Expert personas verify their concerns addressed
- Performance expert runs load test:
  ```bash
  # Simple load test
  for i in {1..100}; do
    curl -X POST http://localhost:3000/api/v1/auth/login \
      -H "Content-Type: application/json" \
      -d '{"email":"test@example.com","password":"Test123!@#"}' \
      -w "%{time_total}\n" -o /dev/null -s
  done | awk '{sum+=$1} END {print "Average response time:", sum/NR*1000, "ms"}'
  ```

## Phase 6: Deployment and Monitoring (Step 20)

### 20. Merge and Post-Merge Activities
```bash
# Team lead merges PR
gh pr merge [PR_NUMBER] --squash --delete-branch

# Update task board
gh issue close [ISSUE_NUMBER] --comment "Completed in PR #[PR_NUMBER]"
gh project item-edit --id [ITEM_ID] --field-id [FIELD_ID] --project-id [PROJECT_ID] --value "Merged"

# For production projects, trigger deployment
gh workflow run deploy.yml --ref main

# Monitor deployment
gh run watch

# Post-deployment validation
curl https://[production-url]/api/health

# Update project documentation
echo "## Version History
- v1.1.0 - Added user authentication system" >> CHANGELOG.md
```