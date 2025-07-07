# Performance Analysis Protocol

## Purpose
Systematically identify and analyze performance issues when users provide vague optimization requests like "make it faster", "optimize", or "improve performance".

## Activation Triggers
- Keywords: "slow", "fast", "optimize", "performance", "speed", "lag"
- No specific metrics provided
- No bottleneck identified
- Missing baseline measurements

## Analysis Framework

### Phase 1: Baseline Measurement (2-3 minutes)

```bash
echo "=== Current Performance Baseline ==="

# Web Application Performance
if [ -f "package.json" ]; then
    # Build time
    echo "Build Performance:"
    time npm run build 2>&1 | tail -20
    
    # Bundle size
    echo "Bundle Analysis:"
    if [ -d "dist" ] || [ -d "build" ]; then
        find dist build -name "*.js" -o -name "*.css" 2>/dev/null | xargs du -sh 2>/dev/null | sort -hr | head -10
    fi
    
    # Development server startup
    echo "Dev Server Startup:"
    timeout 15 npm run dev 2>&1 | grep -E "ready|compiled|built" | head -5
fi

# API/Backend Performance
echo "=== API Performance Check ==="
# Check for common performance test files
find . -name "*benchmark*" -o -name "*perf*" -o -name "*load-test*" | head -10

# Database queries (if applicable)
if [ -f ".env" ] || [ -f ".env.example" ]; then
    grep -E "DATABASE|MONGO|POSTGRES|MYSQL" .env* | head -5
fi
```

### Phase 2: Bottleneck Identification (2-3 minutes)

```bash
echo "=== Potential Bottlenecks ==="

# Large files
echo "Large Source Files (>100KB):"
find . -name "*.js" -o -name "*.ts" -size +100k 2>/dev/null | head -10

# Complex operations
echo "Potentially Heavy Operations:"
grep -r "forEach.*forEach\|for.*for.*for" --include="*.js" --include="*.ts" . 2>/dev/null | head -10

# Database queries
echo "Database Query Patterns:"
grep -r "SELECT.*JOIN.*JOIN\|findAll\|aggregate" --include="*.js" --include="*.ts" . 2>/dev/null | head -10

# API calls
echo "External API Calls:"
grep -r "fetch\|axios\|http\|request" --include="*.js" --include="*.ts" . 2>/dev/null | head -10
```

### Phase 3: Performance Categories

After initial analysis, categorize the performance issue:

#### Category A: Frontend Performance
```markdown
## Frontend Performance Issues

### Load Time Analysis
- Bundle size: [Measured]
- Number of chunks: [Count]
- Code splitting: [Yes/No]
- Lazy loading: [Implemented/Missing]

### Rendering Performance
- React/Vue/Angular detected
- Component count estimate
- Re-render patterns
- Virtual scrolling needs

### Asset Optimization
- Image formats and sizes
- Font loading strategy
- CSS optimization level
- Third-party scripts
```

#### Category B: Backend Performance
```markdown
## Backend Performance Issues

### API Response Times
- Average response time: [Measure if possible]
- Slowest endpoints identified
- Database query patterns
- Caching implementation: [Found/Missing]

### Resource Usage
- Memory patterns
- CPU-intensive operations
- Connection pooling
- Background job queues
```

#### Category C: Database Performance
```markdown
## Database Performance Issues

### Query Analysis
- N+1 query patterns detected
- Missing indexes likely
- Complex joins found
- Full table scans possible

### Data Volume
- Table sizes (if detectable)
- Query complexity
- Aggregation patterns
- Write vs read ratio
```

### Phase 4: Optimization Strategy Generation

Based on findings, generate targeted optimization strategies:

```markdown
## Performance Optimization Plan

### Quick Wins (< 1 day)
1. [Specific optimization with impact estimate]
2. [Another quick optimization]
3. [Third quick win]

### Medium Effort (1-3 days)
1. [Larger optimization task]
2. [Significant refactoring]
3. [Infrastructure change]

### Long Term (> 3 days)
1. [Architectural improvement]
2. [Major refactoring]
3. [Platform migration]
```

### Phase 5: Measurement Plan

```markdown
## Performance Measurement Strategy

### Metrics to Track
1. **User-Facing Metrics**
   - Page Load Time (target: <3s)
   - Time to Interactive (target: <5s)
   - First Contentful Paint (target: <1.5s)

2. **Technical Metrics**
   - Bundle size (target: <500KB)
   - API response time (target: <200ms)
   - Database query time (target: <100ms)

3. **Tools to Use**
   - Lighthouse for web vitals
   - Bundle analyzer for size
   - APM tools for backend
   - Query profiler for database
```

## Structured Output

```markdown
## Performance Analysis Complete

### Current Performance Status
**Type**: [Frontend/Backend/Database/Full-stack]
**Primary Issue**: [Identified bottleneck]
**Impact**: [User-facing description]

### Measurements
- Current: [Metric and value]
- Target: [Suggested target]
- Potential improvement: [X%]

### Root Causes Identified
1. **[Cause 1]**: [Evidence and impact]
2. **[Cause 2]**: [Evidence and impact]
3. **[Cause 3]**: [Evidence and impact]

### Optimization Recommendations

#### Immediate Actions (High Impact, Low Effort)
1. [Specific action]: ~[X]% improvement
2. [Specific action]: ~[X]% improvement

#### Next Steps
Would you like me to:
A) Implement the quick wins immediately
B) Create a detailed optimization plan
C) Set up performance monitoring
D) Focus on a specific bottleneck
```

## Interactive Performance Discovery

If initial analysis is insufficient:

```markdown
I need to understand your performance concerns better:

1. **Where do you notice slowness?**
   - [ ] Page loads
   - [ ] User interactions
   - [ ] API calls
   - [ ] Build/compile time
   - [ ] Data processing

2. **When did it start?**
   - [ ] Always been slow
   - [ ] Recent degradation
   - [ ] After specific change
   - [ ] Under high load only

3. **What's the impact?**
   - [ ] Users complaining
   - [ ] Development slowed
   - [ ] Costs increasing
   - [ ] Scale limitations

4. **Current measurements?**
   - [ ] Have metrics (share them)
   - [ ] No measurements yet
   - [ ] Subjective feeling
```

## Common Optimizations by Category

### Frontend
1. **Bundle Size**
   - Code splitting
   - Tree shaking
   - Lazy loading
   - Compression

2. **Rendering**
   - Memoization
   - Virtual scrolling
   - Debouncing/throttling
   - Web workers

3. **Assets**
   - Image optimization
   - CDN usage
   - Font subsetting
   - Critical CSS

### Backend
1. **API**
   - Response caching
   - Query optimization
   - Pagination
   - Connection pooling

2. **Processing**
   - Background jobs
   - Parallel processing
   - Algorithm optimization
   - Memory management

### Database
1. **Queries**
   - Index optimization
   - Query restructuring
   - Denormalization
   - Read replicas

2. **Architecture**
   - Caching layer
   - Query batching
   - Connection pooling
   - Sharding strategy

## Memory Integration

```bash
# Store performance patterns
p memory-learn "performance-issue" "$BOTTLENECK_TYPE $SOLUTION" "improved-by-X%"

# Retrieve similar optimizations
p memory-find "performance optimization $ISSUE_TYPE"

# Track optimization effectiveness
p memory-learn "optimization-result" "$TECHNIQUE $IMPROVEMENT" "successful"
```

## Success Metrics
- Bottleneck identification: < 5 minutes
- Root cause accuracy: > 80%
- Optimization impact prediction: ±20%
- User satisfaction with suggestions: > 85%

## Anti-Patterns to Avoid
- Don't optimize without measuring first
- Don't assume the obvious bottleneck
- Don't ignore user perception of performance
- Don't over-optimize edge cases
- Don't skip impact estimation