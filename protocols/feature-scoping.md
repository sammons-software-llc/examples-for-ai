# Feature Scoping Protocol

## Purpose
Transform vague feature requests like "add auth", "make it faster", or "implement search" into well-defined, actionable specifications.

## Activation Triggers
- Keywords: "add", "implement", "create", "build", "make", "need"
- Feature requests without specifications
- Missing technical requirements
- No success criteria defined

## Scoping Framework

### Phase 1: Feature Identification (1-2 minutes)

```bash
echo "=== Current Project Analysis ==="
# Identify existing patterns
find . -type f \( -name "*.js" -o -name "*.ts" -o -name "*.py" \) | head -20

# Check for existing similar features
grep -r "auth\|login\|user\|session" --include="*.js" --include="*.ts" . 2>/dev/null | head -10
grep -r "search\|filter\|query" --include="*.js" --include="*.ts" . 2>/dev/null | head -10

# Architecture detection
echo "=== Architecture Patterns ==="
# Check for common patterns
find . -name "*controller*" -o -name "*service*" -o -name "*model*" -o -name "*route*" | head -20

# Database detection
find . -name "*schema*" -o -name "*migration*" -o -name "*.sql" | head -10
```

### Phase 2: Feature Decomposition

Based on the request type, break down into components:

#### For "add auth":
```markdown
## Authentication Feature Breakdown

### Core Components Needed:
1. **User Model/Schema**
   - Fields: email, password_hash, created_at, updated_at
   - Indexes: email (unique)
   - Relations: [identify existing models to connect]

2. **Authentication Strategy**
   - [ ] Local (username/password)
   - [ ] OAuth (Google, GitHub, etc.)
   - [ ] JWT tokens
   - [ ] Session-based
   - [ ] Multi-factor

3. **API Endpoints**
   - POST /auth/register
   - POST /auth/login
   - POST /auth/logout
   - GET /auth/me
   - POST /auth/refresh

4. **Middleware/Guards**
   - Authentication check
   - Authorization levels
   - Rate limiting

5. **UI Components** (if applicable)
   - Login form
   - Registration form
   - Password reset flow
   - User profile
```

#### For "make it faster":
```markdown
## Performance Optimization Breakdown

### Analysis Areas:
1. **Current Performance Baseline**
   ```bash
   # Measure current performance
   npm run build -- --profile
   time npm start
   ```

2. **Bottleneck Identification**
   - [ ] Database queries (N+1, missing indexes)
   - [ ] API response times
   - [ ] Frontend bundle size
   - [ ] Rendering performance
   - [ ] Network waterfalls

3. **Optimization Strategies**
   - [ ] Caching (Redis, in-memory)
   - [ ] Query optimization
   - [ ] Code splitting
   - [ ] Lazy loading
   - [ ] CDN usage
   - [ ] Compression
```

#### For "add search":
```markdown
## Search Feature Breakdown

### Search Specifications:
1. **Search Scope**
   - [ ] Which entities/data to search?
   - [ ] Fields to include in search
   - [ ] Full-text vs. exact match

2. **Search Interface**
   - [ ] Search bar location
   - [ ] Auto-complete?
   - [ ] Filters/facets?
   - [ ] Results format

3. **Technical Approach**
   - [ ] Database full-text search
   - [ ] Elasticsearch/Algolia
   - [ ] In-memory search
   - [ ] Frontend filtering
```

### Phase 3: Requirements Elicitation

Generate targeted questions based on feature type:

```markdown
## Feature Requirements Questionnaire

### For Authentication:
1. **User Types**
   - How many user roles? (admin, user, guest?)
   - Different permissions per role?
   - Self-registration allowed?

2. **Security Requirements**
   - Password complexity rules?
   - Session timeout period?
   - Remember me functionality?
   - Account lockout after failed attempts?

3. **Integration Points**
   - Existing user table?
   - SSO requirements?
   - Email service for verification?

### For Performance:
1. **Performance Targets**
   - Current load time?
   - Target load time?
   - Expected concurrent users?
   - Acceptable response time?

2. **Constraints**
   - Budget for services?
   - Infrastructure limitations?
   - Browser support requirements?

### For Search:
1. **Search Behavior**
   - Real-time or on-submit?
   - Typo tolerance needed?
   - Search history/suggestions?
   - Multi-language support?

2. **Scale Requirements**
   - Number of searchable items?
   - Update frequency?
   - Search query volume?
```

### Phase 4: Technical Specification Generation

```markdown
## Feature Specification: [Feature Name]

### Overview
- **Purpose**: [Clear description]
- **User Story**: As a [user type], I want to [action] so that [benefit]
- **Priority**: [High/Medium/Low]
- **Estimated Effort**: [Time estimate]

### Technical Requirements
1. **Backend Requirements**
   - Database changes: [schemas, migrations]
   - API endpoints: [list with methods]
   - Business logic: [key algorithms/rules]
   - External services: [if any]

2. **Frontend Requirements**
   - UI components: [list]
   - State management: [approach]
   - Routes: [new routes needed]
   - Validation: [client-side rules]

3. **Infrastructure Requirements**
   - Environment variables: [new configs]
   - Dependencies: [new packages]
   - Services: [Redis, queues, etc.]

### Success Criteria
- [ ] Functional: [What it must do]
- [ ] Performance: [Speed/scale metrics]
- [ ] Security: [Security requirements]
- [ ] UX: [User experience goals]

### Implementation Plan
1. **Phase 1**: [Database/Model setup]
2. **Phase 2**: [Core functionality]
3. **Phase 3**: [UI implementation]
4. **Phase 4**: [Testing & refinement]

### Testing Strategy
- Unit tests: [coverage areas]
- Integration tests: [key flows]
- E2E tests: [user journeys]
- Performance tests: [if applicable]
```

### Phase 5: Validation Questions

Before proceeding, confirm understanding:

```markdown
## Feature Validation Checklist

Based on my analysis, I understand you want to:

**Feature**: [Specific feature name]
**Scope**: [What's included/excluded]
**Approach**: [Technical strategy]

### Please confirm:
1. ✓/✗ The scope matches your needs
2. ✓/✗ The technical approach is acceptable
3. ✓/✗ The timeline seems reasonable
4. ✓/✗ All requirements are captured

### Questions before starting:
1. [Specific clarification 1]
2. [Specific clarification 2]
3. [Specific clarification 3]

Would you like me to:
A) Proceed with this specification
B) Adjust the scope/approach
C) Create a proof of concept first
D) Break it into smaller phases
```

## Memory Integration

```bash
# Store feature patterns
p memory-learn "feature-request" "$FEATURE_TYPE $TECH_STACK $APPROACH" "specified"

# Retrieve similar implementations
p memory-find "similar feature $FEATURE_TYPE"

# Store successful patterns
p memory-learn "implementation-pattern" "$FEATURE $PATTERN" "successful"
```

## Output Templates

### Simple Feature Response:
```markdown
I'll help you add [feature]. Based on your project structure, here's what I recommend:

**Approach**: [Recommended approach]
**Components needed**:
1. [Component 1]
2. [Component 2]
3. [Component 3]

**Quick questions**:
- [Key question 1]?
- [Key question 2]?

Shall I create a detailed implementation plan?
```

### Complex Feature Response:
```markdown
I've analyzed your request to [feature description]. This is a comprehensive feature that involves:

**Major Components**:
1. [System 1]: [Description]
2. [System 2]: [Description]
3. [System 3]: [Description]

**Critical Decisions Needed**:
1. [Decision 1]: Option A vs Option B
2. [Decision 2]: Option A vs Option B

**Recommended Phased Approach**:
- Phase 1 (1-2 days): [Basic functionality]
- Phase 2 (2-3 days): [Enhanced features]
- Phase 3 (1-2 days): [Polish and optimization]

Would you like me to start with Phase 1 or create a detailed specification first?
```

## Success Metrics
- Scope clarification: < 3 minutes
- Requirements gathering: < 5 minutes
- Specification accuracy: > 90%
- Implementation success rate: > 85%
- Rework rate: < 15%

## Anti-Patterns to Avoid
- Don't assume feature complexity
- Don't skip integration analysis
- Don't ignore existing patterns
- Don't over-engineer simple requests
- Don't under-scope complex features