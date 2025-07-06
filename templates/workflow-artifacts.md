# Standardized Workflow Artifacts

## 1. Project Board Ticket Format

```markdown
Title: [FEAT-XXX] Brief description (8 words max)
Labels: type:feature, priority:high, size:medium, component:frontend

## Description
As a [user type], I want [functionality] so that [benefit].

## Context
[2-3 sentences providing background and why this is needed]

## Acceptance Criteria
- [ ] User can perform X action
- [ ] System validates Y input
- [ ] Z displays correctly on mobile
- [ ] Performance remains under 500ms
- [ ] Accessibility standards met (WCAG AA)

## Technical Requirements
- [ ] TypeScript strict mode passes
- [ ] 95% test coverage
- [ ] No new dependencies without approval
- [ ] Follows existing patterns in codebase

## Dependencies
- Depends on: FEAT-002 (if applicable)
- Blocks: FEAT-004 (if applicable)

## Definition of Done
- [ ] Code complete and follows standards
- [ ] Unit tests written and passing
- [ ] E2E tests updated if needed
- [ ] Documentation updated
- [ ] Passed code review (3 approvals)
- [ ] Deployed to staging
```

## 2. Daily Status Update Format

```markdown
## Status Update: [Date]

### 🏃 In Progress
- **[FEAT-001]** User authentication (75% complete)
  - ✅ JWT implementation complete
  - ✅ Login/logout endpoints
  - 🔄 Working on refresh token logic
  - ⏳ Remaining: Password reset flow

### ✅ Completed Today
- **[FEAT-002]** Database schema setup
  - Migrations created and tested
  - Seed data implemented
  - Performance indexes added

### 🚧 Blockers
- **[FEAT-003]** Waiting on Cognito configuration approval
  - Impact: Cannot test OAuth flow
  - Mitigation: Working on other auth features

### 📊 Metrics
- Velocity: 8/10 story points this sprint
- Test Coverage: 96.2% (↑ 2.1%)
- Build Time: 2m 34s (↓ 15s)
- Open PRs: 3 (1 ready to merge)

### 🎯 Tomorrow's Focus
- Complete refresh token implementation
- Start on password reset flow
- Review PR #45 from @developer-agent
```

## 3. Pull Request Template

```markdown
## Summary
[One sentence describing what this PR does]

## Related Issue
Closes #[task-number]

## Type of Change
- [ ] 🐛 Bug fix (non-breaking change)
- [x] ✨ New feature (non-breaking change)
- [ ] 💥 Breaking change (fix or feature)
- [ ] 📝 Documentation update
- [ ] ♻️ Code refactoring
- [ ] ⚡ Performance improvement

## Changes Made
- Added JWT authentication to API endpoints
- Implemented refresh token rotation
- Created auth middleware for route protection
- Added comprehensive auth tests

## Testing
### Test Plan
1. **Unit Tests**
   - Auth service: token generation, validation
   - Middleware: authorized/unauthorized flows
   - Coverage: 98% on new code

2. **Integration Tests**
   - Login flow end-to-end
   - Token refresh scenarios
   - Concurrent request handling

3. **Manual Testing**
   - [ ] Login with valid credentials
   - [ ] Login with invalid credentials  
   - [ ] Access protected route with token
   - [ ] Token expires and refreshes
   - [ ] Logout invalidates tokens

### Test Results
```
✓ auth.service.test.ts (12 tests, 145ms)
✓ auth.middleware.test.ts (8 tests, 89ms)
✓ auth.e2e.test.ts (6 tests, 1.2s)

Test Suites: 3 passed, 3 total
Tests:       26 passed, 26 total
Coverage:    98.2% of new code
```

## Screenshots/Recordings
[If applicable, add screenshots or Loom video]

## Performance Impact
- Login endpoint: 145ms average (within 500ms target)
- Token validation: 12ms (cached), 89ms (fresh)
- Memory usage: No increase detected

## Checklist
- [x] My code follows the style guidelines
- [x] I have performed a self-review
- [x] I have commented hard-to-understand areas
- [x] I have made corresponding changes to docs
- [x] My changes generate no new warnings
- [x] I have added tests that prove my fix works
- [x] New and existing unit tests pass locally
- [x] Any dependent changes have been merged

## Deployment Notes
- No database migrations required
- No environment variables added
- Backward compatible with existing clients
```

## 4. Code Review Comment Format

### 🔴 Critical (Must Fix)
```markdown
**[Security]** SQL Injection vulnerability in user query

File: `user-repository.ts:45`

```typescript
// ❌ Current implementation
const query = `SELECT * FROM users WHERE email = '${email}'`
```

This is vulnerable to SQL injection. Please use parameterized queries:

```typescript
// ✅ Suggested fix
const user = await prisma.user.findUnique({
  where: { email }
})
```

References:
- OWASP: https://owasp.org/www-community/attacks/SQL_Injection
- Our security guidelines: `/docs/security.md#sql-injection`
```

### 🟡 Major (Should Fix)
```markdown
**[Performance]** N+1 query issue in post loading

File: `post-service.ts:78-92`

This will execute 1 + N queries when loading posts with authors. Consider using a join or DataLoader pattern:

```typescript
// Current: N+1 queries
const posts = await getPosts()
for (const post of posts) {
  post.author = await getUser(post.authorId) // N queries!
}

// Suggested: Single query with join
const posts = await prisma.post.findMany({
  include: { author: true }
})
```

Impact: With 100 posts, this creates 101 database queries instead of 1.
```

### 🟢 Minor (Consider)
```markdown
**[Code Quality]** Consider extracting magic number to constant

File: `auth-service.ts:34`

```typescript
// Consider extracting
const TOKEN_EXPIRY_MINUTES = 15
const expiresIn = TOKEN_EXPIRY_MINUTES * 60
```

This would improve maintainability and make the expiry time configurable.
```

### 👍 Positive Feedback
```markdown
**[Well Done]** Excellent error handling!

File: `payment-service.ts:156-178`

Great job implementing comprehensive error handling with specific error types and user-friendly messages. The retry logic with exponential backoff is particularly well done.
```

## 5. Sprint Review Summary

```markdown
# Sprint 23 Review

## Sprint Goal Achievement
✅ **Achieved**: Implement core authentication system

## Completed Stories (32 points)
1. [FEAT-001] JWT Authentication - 8 points ✅
2. [FEAT-002] User Registration - 5 points ✅
3. [FEAT-003] Password Reset - 5 points ✅
4. [FEAT-004] OAuth Integration - 8 points ✅
5. [BUG-001] Fix memory leak - 3 points ✅
6. [TECH-001] Upgrade dependencies - 3 points ✅

## Incomplete Stories (8 points)
1. [FEAT-005] 2FA Implementation - 8 points
   - Carried to next sprint
   - 60% complete, blocked on SMS provider

## Metrics
- **Velocity**: 32 points (↑ from 28 last sprint)
- **Commitment Accuracy**: 80% (32/40 points)
- **Defect Rate**: 2 bugs found in staging
- **Test Coverage**: 94.8% overall (↑ 2.3%)

## Demonstrations
1. User registration flow - @ux-designer
2. JWT authentication - @developer
3. Security review findings - @security-expert

## Retrospective Highlights
### What Went Well
- Excellent collaboration on auth design
- All PRs reviewed within 4 hours
- Zero critical security issues

### Improvements Needed
- Better estimation for complex features
- Need SMS provider decision earlier
- More frequent status updates

## Next Sprint Preview
Focus: User Profile & Settings (40 points planned)
```

## 6. Commit Message Format

```bash
[TASK-ID]: Brief description of change (50 chars max)

Detailed explanation of what changed and why. Focus on the why
rather than the what (code shows what changed). Include any
important context or decisions made.

- auth-service.ts: Add JWT token generation with RS256
- auth-middleware.ts: Implement request authentication  
- user-repository.ts: Add session management methods
- auth.test.ts: Comprehensive test coverage for auth flows

Breaking Changes: None
Performance Impact: -15ms on login endpoint
Security: Implements OWASP best practices
```

## 7. Architecture Decision Record (ADR)

```markdown
# ADR-004: Use Redis for Session Management

## Status
Accepted

## Context
We need a solution for managing user sessions in our distributed system. Requirements:
- Support 10k+ concurrent sessions
- Sub-100ms response times
- Horizontal scalability
- Session sharing across services

## Decision
We will use Redis for session storage with the following configuration:
- Redis Cluster for high availability
- 24-hour session timeout
- Session data encrypted at rest
- ioredis client library

## Consequences
### Positive
- Proven scalability to millions of sessions
- 50ms average response time in testing
- Built-in expiration handling
- Supports our microservices architecture

### Negative  
- Additional infrastructure to maintain
- Requires Redis expertise on team
- $150/month for managed Redis cluster

### Neutral
- Need to implement session migration strategy
- Monitoring requirements increase

## Alternatives Considered
1. **DynamoDB**: Higher latency (150ms), more expensive
2. **In-memory**: Doesn't support distributed system
3. **PostgreSQL**: Not optimized for key-value access

## References
- Redis session best practices: [link]
- Performance benchmarks: [link]
- Security audit results: [link]
```

## 8. Bug Report Format

```markdown
## Bug Report: [BUG-XXX] Brief description

### Environment
- **Environment**: Production / Staging / Local
- **Browser/Device**: Chrome 120 on macOS
- **User Role**: Admin
- **Timestamp**: 2024-01-15 14:32 UTC

### Description
Clear description of what happened vs what should happen.

### Steps to Reproduce
1. Navigate to /dashboard
2. Click on "Export Data" button
3. Select date range: Last 30 days
4. Click "Download"

### Expected Behavior
CSV file downloads with user data from selected range

### Actual Behavior
Error toast appears: "Export failed"
Console error: `TypeError: Cannot read property 'map' of undefined`

### Screenshots/Videos
[Error screenshot]
[Console screenshot]
[Loom video of reproduction]

### Impact
- **Severity**: High (blocking feature)
- **Affected Users**: All users trying to export
- **Frequency**: 100% reproducible

### Additional Context
- Started after deploy 3.2.1
- Only affects date ranges > 7 days
- Works correctly in staging

### Workaround
Export in 7-day chunks and combine manually

### Logs
```
ERROR [2024-01-15 14:32:15] ExportService: Failed to process data
  userId: 123
  dateRange: 30
  error: TypeError: Cannot read property 'map' of undefined
    at formatData (export-service.ts:45)
    at processExport (export-service.ts:78)
```
```

## 9. Performance Report Format

```markdown
# Performance Report: Week 23

## API Performance
| Endpoint | P50 | P95 | P99 | Target | Status |
|----------|-----|-----|-----|--------|--------|
| GET /api/users | 45ms | 123ms | 234ms | <500ms | ✅ |
| POST /api/auth/login | 134ms | 298ms | 456ms | <500ms | ✅ |
| GET /api/posts | 234ms | 567ms | 890ms | <500ms | ⚠️ |

## Frontend Metrics
- **LCP**: 1.8s (Good)
- **FID**: 45ms (Good)  
- **CLS**: 0.05 (Good)
- **Bundle Size**: 187KB gzipped (↓ 5KB)

## Database Performance
```sql
-- Slow Query Log (>100ms)
SELECT * FROM posts p 
JOIN users u ON p.author_id = u.id 
WHERE p.created_at > '2024-01-01'
-- Time: 345ms
-- Rows: 10,000
-- Missing index on created_at
```

## Improvements Made
1. Added index on posts.created_at (-200ms)
2. Implemented query result caching (-150ms)
3. Optimized images with WebP (-500KB)

## Action Items
- [ ] Investigate posts endpoint P99 latency
- [ ] Add Redis caching for user queries
- [ ] Enable CDN for static assets
```

## 10. Incident Report Format

```markdown
# Incident Report: INC-2024-001

## Summary
Database connection pool exhaustion caused 15-minute service degradation

## Impact
- **Duration**: 2024-01-15 14:00 - 14:15 UTC
- **Severity**: P2 (Partial Outage)
- **Affected Users**: ~2,500 (25% of active users)
- **Error Rate**: 45% of requests failed

## Timeline
- **13:55** - Increased traffic from marketing campaign
- **14:00** - Connection pool alerts triggered
- **14:02** - On-call engineer notified
- **14:05** - Root cause identified
- **14:10** - Fix deployed
- **14:15** - Service fully restored

## Root Cause
Marketing campaign drove 5x normal traffic. Connection pool size (20) insufficient for load.

## Resolution
1. Increased connection pool to 100
2. Implemented connection pooling middleware
3. Added circuit breaker pattern

## Lessons Learned
1. Need better capacity planning for campaigns
2. Connection pool monitoring was inadequate
3. Autoscaling would have prevented issue

## Action Items
- [ ] Implement database proxy (Owner: @developer)
- [ ] Add predictive scaling (Owner: @devops)
- [ ] Create runbook for connection issues (Owner: @sre)

## Prevention
- Load test all campaigns with 10x expected traffic
- Implement automatic connection pool scaling
- Add preemptive alerts at 60% capacity
```