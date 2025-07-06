# Validation Checklists - Quality Gates

## Self-Verification Requirements

Before marking ANY step complete, run the verification command for that step:

### Phase 1: Setup & Architecture
- **Step 2**: `gh repo view sammons-software-llc/[project]` - Repository exists and accessible
- **Step 5**: `gh project list --owner sammons-software-llc` - Project board created

### Phase 2: Planning
- **Step 6**: Count of tasks created matches feature scope
- **Step 7**: All tasks have priority labels and dependency links
- **Step 8**: Sprint waves are logically grouped

### Phase 3: Implementation
- **Step 10**: `pnpm test -- --run` - Tests should FAIL (red phase)
- **Step 11**: `pnpm test -- --run` - Tests should PASS (green phase)
- **Step 12**: Performance benchmarks met in test suite
- **Step 13**: Documentation updated with new features

### Phase 4: Quality Assurance
- **Step 14**: `pnpm run lint:check && echo "✓"` - Lint check passes
- **Step 15**: PR created with all required information
- **Step 16**: `gh pr checks` - All automated checks pass

### Phase 5: Review & Iteration
- **Step 17**: All 4 expert personas have reviewed and approved
- **Step 18**: All review comments addressed with commits
- **Step 19**: Final validation round passes

### Phase 6: Deployment
- **Step 20**: `curl https://[production-url]/api/health` - Production deployment healthy

## Checkpoint Validation

### CHECKPOINT 1: Architecture & Setup Complete
- ✓ Project archetype identified
- ✓ Repository created with branch protection
- ✓ Expert reports received (4 distinct reports)
- ✓ Dependencies verified (latest versions confirmed)
- ✓ Project board created with [N] tasks

**User Confirmation Required**: "Architecture phase complete with [N] tasks created. Continue to implementation?"

### CHECKPOINT 2: Tests Written & Failing
- ✓ Unit tests written for all acceptance criteria
- ✓ Tests are failing (red phase confirmed)
- ✓ Test coverage targets defined (>90%)

**User Confirmation Required**: "Tests written and failing as expected. Ready to implement?"

### CHECKPOINT 3: Implementation Complete
- ✓ All tests passing (green phase)
- ✓ Lint/type checks clean (0 errors)
- ✓ Performance benchmarks met (<500ms API, <16ms UI)
- ✓ Security scan passed (no moderate+ vulnerabilities)
- ✓ Documentation updated (API docs, README)

**User Confirmation Required**: "Implementation complete with all checks passing. Create PR?"

### CHECKPOINT 4: Ready to Merge
- ✓ All review comments addressed
- ✓ Expert approvals received (4 approvals)
- ✓ Final tests passing (re-run after changes)
- ✓ Performance validated (load test passed)

**User Confirmation Required**: "PR approved and ready to merge. Proceed?"

## Quality Gate Commands

### Pre-Development Quality Gate
```bash
# Environment verification
node --version                         # Should be v24+
pnpm --version                        # Should be latest
git --version                         # Should be 2.40+

# Project setup verification
gh repo view sammons-software-llc/[project] || echo "Repository not found"
gh project list --owner sammons-software-llc | grep "[project]" || echo "Project board not found"
```

### Pre-Implementation Quality Gate
```bash
# Test setup verification
pnpm test -- --run                    # Should FAIL (no implementation yet)
pnpm run lint:check                   # Should pass (test files only)
pnpm run type-check                   # Should pass (types defined)
```

### Pre-PR Quality Gate
```bash
# Full validation suite
pnpm run lint:check                   # ESLint with 0 errors
pnpm run type-check                   # TypeScript with 0 errors  
pnpm test -- --coverage              # >90% coverage
pnpm run test:integration            # All integration tests pass
pnpm run build                       # Build succeeds
pnpm run test:e2e -- --headed        # E2E with screenshots

# Security validation
pnpm audit --audit-level=moderate    # No moderate+ vulnerabilities
grep -r "api[_-]key\|secret\|password" src/ --exclude-dir=node_modules | wc -l # Should be 0

# Performance validation
pnpm run test:performance            # All endpoints <500ms
```

### Pre-Merge Quality Gate
```bash
# PR status verification
gh pr checks                         # All automated checks pass
gh pr review --list                  # 4 approvals from expert personas
gh pr view --json mergeable         # PR is mergeable

# Final validation
pnpm test -- --run                  # All tests pass
pnpm run build                      # Build succeeds
```

### Post-Merge Quality Gate
```bash
# Deployment verification
gh run watch                         # Deployment workflow completes
curl https://[production-url]/api/health # Production health check
gh issue close [ISSUE_NUMBER]       # Issue closed and linked to PR
```

## Coverage Requirements

### Unit Test Coverage
- **Minimum**: 90% line coverage
- **Preferred**: 95% line coverage
- **Required**: 100% coverage for security-critical functions

### Integration Test Coverage
- **API Endpoints**: All endpoints tested
- **Database Operations**: All CRUD operations tested
- **External Services**: All integrations mocked and tested

### E2E Test Coverage
- **Happy Path**: Primary user journeys tested
- **Error Scenarios**: Common error cases tested
- **Edge Cases**: Boundary conditions tested

## Performance Benchmarks

### API Performance
- **Authentication**: <200ms response time
- **CRUD Operations**: <500ms response time
- **Complex Queries**: <1000ms response time
- **File Uploads**: <2000ms for 10MB files

### UI Performance
- **Component Render**: <16ms (60fps)
- **Page Load**: <2000ms Time to Interactive
- **Bundle Size**: <500KB gzipped for critical path

### Database Performance
- **Query Optimization**: All queries use indexes
- **Connection Pooling**: Max 10 connections per service
- **Response Time**: <100ms for simple queries

## Security Checklist

### Authentication & Authorization
- [ ] JWT tokens expire appropriately
- [ ] Password hashing uses bcrypt with 10+ rounds
- [ ] Rate limiting implemented (5 attempts/minute)
- [ ] Session management secure

### Data Protection
- [ ] No secrets in source code
- [ ] Input validation on all endpoints
- [ ] SQL injection prevention
- [ ] XSS protection enabled

### Infrastructure Security
- [ ] HTTPS enforced in production
- [ ] Security headers configured
- [ ] Dependencies have no known vulnerabilities
- [ ] Access logs enabled

## Documentation Requirements

### Code Documentation
- [ ] API endpoints documented with OpenAPI/JSDoc
- [ ] Complex functions have explanatory comments
- [ ] README updated with new features
- [ ] Architecture decisions recorded (ADR)

### Test Documentation
- [ ] Test cases document expected behavior
- [ ] Performance benchmarks documented
- [ ] E2E test scenarios documented
- [ ] Test data setup documented

### Deployment Documentation
- [ ] Environment setup documented
- [ ] Deployment process documented
- [ ] Rollback procedures documented
- [ ] Monitoring setup documented