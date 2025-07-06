# Persona Integration Guide

## How to Use Expert Personas

### Loading Personas in Sub-Agents

When spawning sub-agents, include the persona prompt:

```markdown
You are spawning an expert agent. Load and follow: `examples/personas/architect.md`

Additional context for this specific task:
- Project type: [local app/serverless/static site]
- Key requirements: [specific needs]
- Constraints: [budget/timeline/tech limits]
```

### Persona Activation Patterns

#### Phase 1: Architecture & Planning
```
Parallel spawn:
├── Architect → examples/personas/architect.md
├── Security Expert → examples/personas/security-expert.md
├── Performance Expert → examples/personas/performance-expert.md
└── UX Designer → examples/personas/ux-designer.md
```

#### Phase 2: Implementation
```
Sequential spawn:
└── Developer → examples/personas/developer.md
    └── For each task from project board
```

#### Phase 3: Review
```
Parallel spawn for each PR:
├── Security Expert → Review for vulnerabilities
├── Performance Expert → Review for bottlenecks
├── UX Designer → Review implementation matches design
└── Team Lead → Final review and merge decision
```

## Persona Interaction Patterns

### 1. Initial Architecture Phase
```yaml
Architect:
  Input: "Design architecture for [project-type]"
  Output: 
    - Architecture document
    - Component breakdown
    - Task list for project board

Security Expert:
  Input: "Review architecture for [project-type]"
  Output:
    - Security requirements
    - Compliance checklist
    - Security-focused tasks

Performance Expert:
  Input: "Define performance targets for [project-type]"
  Output:
    - Performance benchmarks
    - Optimization strategy
    - Performance test suite

UX Designer:
  Input: "Design UI/UX for [project-type]"
  Output:
    - User flows
    - Component specifications
    - Design system choices
```

### 2. Development Phase
```yaml
Developer:
  Input: "Implement [TASK-ID]: [description]"
  Context: 
    - Architecture document
    - Security requirements
    - Performance targets
    - UX specifications
  Output:
    - Feature implementation
    - Tests
    - Documentation
    - Pull request
```

### 3. Review Phase
```yaml
Security Expert:
  Input: "Review PR #[NUMBER] for security"
  Output:
    - Security issues found
    - Remediation steps
    - Approval/block decision

Performance Expert:
  Input: "Review PR #[NUMBER] for performance"
  Output:
    - Performance analysis
    - Bottlenecks identified
    - Optimization suggestions

Team Lead:
  Input: "Final review PR #[NUMBER]"
  Context: All expert reviews
  Output:
    - Merge decision
    - Required changes
    - Process improvements
```

## Coordination Patterns

### Synchronous Coordination
When experts need to collaborate:
```
Team Lead: "We need to design a payment system"

Parallel:
- Architect: Creates payment flow architecture
- Security: Defines PCI compliance requirements  
- UX: Designs checkout experience

Team Lead: Synthesizes all inputs into unified plan
```

### Asynchronous Handoffs
When work flows sequentially:
```
Architect → Creates tasks → Developer picks up task → Implements → Experts review → Team Lead merges
```

## Conflict Resolution

When personas disagree:

### Example: Performance vs Security
```
Performance Expert: "Cache user sessions for speed"
Security Expert: "No caching of sensitive data"

Resolution by Team Lead:
- Cache non-sensitive data only
- Use encrypted cache for sensitive data
- Add cache invalidation on security events
```

### Example: UX vs Technical
```
UX Designer: "Real-time updates needed"
Developer: "Polling is simpler than WebSockets"

Resolution by Architect:
- Start with polling (5-second intervals)
- Add WebSockets in v2 if users complain
- Monitor user feedback
```

## Quality Patterns

### Cross-Persona Validation
Each persona validates others' work:
- Architect reviews if Developer followed architecture
- Security reviews if UX exposed sensitive info
- Performance reviews if Architecture scales
- UX reviews if Developer matched designs

### Escalation Path
```
Issue found → Persona flags it → Team Lead decides → Either fix or accept with documentation
```

## Persona Prompt Optimization

### Keep Personas Focused
DO:
- Give specific task context
- Reference project constraints
- Set clear deliverable expectations

DON'T:
- Overload with irrelevant context
- Mix multiple personas in one agent
- Skip persona loading

### Example Spawn Commands

#### Good Example
```
Task: Design authentication system
Load: examples/personas/architect.md
Context: 
- Local app for note-taking
- Single user, no cloud sync
- Must work offline
Deliver: Architecture doc with task breakdown
```

#### Bad Example
```
Task: Do everything for auth system
Context: Build it good
```

## Measuring Persona Effectiveness

Track these metrics:
1. **Consistency**: Do personas maintain their perspective?
2. **Quality**: Are deliverables complete and accurate?
3. **Coordination**: Do handoffs work smoothly?
4. **Conflicts**: Are disagreements productive?

## Common Pitfalls

1. **Persona Drift**: Agent forgets its role
   - Fix: Remind of persona file in each interaction

2. **Over-Engineering**: Experts gold-plate everything
   - Fix: Emphasize pragmatism and constraints

3. **Analysis Paralysis**: Too much planning
   - Fix: Time-box expert phases

4. **Echo Chamber**: All experts agree
   - Fix: Explicitly ask for contrarian views

## Persona Maintenance

Personas should evolve based on:
- Project post-mortems
- New best practices
- Tool updates
- Team feedback

Update personas when you notice:
- Repeated mistakes
- Missing expertise areas
- Outdated practices
- Inconsistent outputs