# Adopt Foreign/Partial Project Process

## Context
You are adopting an existing project that was not built with this framework.
This process discovers the current state and retrofits our standards.

## Objective
Transform foreign projects to match our framework while preserving functionality.
Success metrics:
□ All tests passing after adoption
□ Framework standards applied
□ No functionality regression
□ Clear migration path documented

## Process

### === DISCOVERY PHASE ===

#### 1. Project Type Detection
```bash
# Detect project archetype
if [ -f "package.json" ]; then
  # Check for key indicators
  grep -E "react|vue|angular|next|nuxt" package.json && echo "→ Web App"
  grep -E "express|fastify|koa|hapi" package.json && echo "→ API Server"
  grep -E "electron" package.json && echo "→ Desktop App"
  grep -E "react-native|expo" package.json && echo "→ Mobile App"
  grep -E "serverless|aws-cdk|@aws-cdk" package.json && echo "→ AWS App"
  grep -E "commander|yargs|inquirer" package.json && echo "→ CLI Tool"
fi

[ -f "Dockerfile" ] && echo "→ Containerized"
[ -f "serverless.yml" ] && echo "→ Serverless Framework"
[ -d ".github/workflows" ] && echo "→ GitHub Actions CI/CD"
```

#### 2. Technology Stack Analysis
```bash
# Language detection
find . -name "*.ts" -o -name "*.tsx" | head -1 && echo "TypeScript: ✓"
find . -name "*.js" -o -name "*.jsx" | head -1 && echo "JavaScript: Needs migration"

# Test framework detection
grep -E "jest|mocha|jasmine|ava" package.json && echo "⚠️ WRONG TEST FRAMEWORK"
grep "vitest" package.json && echo "Vitest: ✓"

# Package manager
[ -f "pnpm-lock.yaml" ] && echo "pnpm: ✓"
[ -f "yarn.lock" ] && echo "yarn: Needs migration"
[ -f "package-lock.json" ] && echo "npm: Needs migration"
```

#### 3. Code Structure Analysis
```bash
# Check structure compliance
echo "=== Directory Structure ==="
tree -L 3 -I 'node_modules|dist|build|coverage' .

# Our standard check
[ -d "lib" ] && echo "Monorepo structure: ✓" || echo "Monorepo structure: ✗"
[ -d "src/handlers" ] && echo "Handler pattern: ✓" || echo "Handler pattern: ✗"
[ -d "src/strategies" ] && echo "Strategy pattern: ✓" || echo "Strategy pattern: ✗"
[ -d "src/repositories" ] && echo "Repository pattern: ✓" || echo "Repository pattern: ✗"
```

#### 4. Quality Assessment
```bash
# Test coverage
npm test -- --coverage 2>/dev/null || echo "No test coverage data"

# Linting status
npm run lint 2>/dev/null || echo "No lint script"

# Type checking
npx tsc --noEmit 2>/dev/null || echo "TypeScript errors present"

# Security scan
npm audit --audit-level=moderate || echo "Security vulnerabilities"
```

### === DECISION TREE ===

```
IF project_is_empty:
    THEN: Use standard archetype process
    STOP

ELIF project_has_tests && tests_passing:
    THEN: Safe to refactor incrementally
    CONTINUE: Migration path

ELIF project_has_no_tests:
    THEN: Write tests first (characterization tests)
    CONTINUE: Test-first migration

ELIF using_jest:
    THEN: Migrate to Vitest immediately
    CONTINUE: Test framework migration

ELSE:
    THEN: Full audit required
    CONTINUE: Deep analysis
```

### === MIGRATION STRATEGIES ===

#### Strategy 1: Incremental Adoption (Preferred)
For projects with good test coverage:

```typescript
// Step 1: Add framework files
gh api repos/sammons-software-llc/examples-for-ai/contents/CLAUDE.md --jq '.content' | base64 -d > CLAUDE.md
mkdir -p context archetypes personas examples

// Step 2: Create adapter layer
// old-code-adapter.ts
export class LegacyAdapter {
  // Wrap existing code to match our patterns
  constructor(private legacyService: any) {}
  
  async executeStrategy(): Promise<Result> {
    // Adapt old patterns to new
    return this.mapLegacyResult(
      await this.legacyService.oldMethod()
    )
  }
}

// Step 3: Gradually refactor
// - One module at a time
// - Keep tests green
// - Update imports last
```

#### Strategy 2: Parallel Implementation
For projects without tests:

```bash
# Create new structure alongside old
mkdir -p lib-new/{ui,api,server,shared-types,e2e}

# Implement feature parity
# - Write tests for new code
# - A/B test old vs new
# - Switch over when confident
```

#### Strategy 3: Big Bang Migration
For small projects (<5000 LOC):

```bash
# Full rewrite following archetype
# 1. Document current behavior
# 2. Write comprehensive E2E tests
# 3. Reimplement using framework
# 4. Verify behavior matches
```

### === SPECIFIC MIGRATIONS ===

#### Jest → Vitest Migration
```bash
# Step 1: Install Vitest
pnpm add -D vitest @vitest/ui @testing-library/jest-dom

# Step 2: Update imports
find . -name "*.test.ts" -o -name "*.spec.ts" | xargs sed -i '' 's/from "@jest\/globals"/from "vitest"/g'
find . -name "*.test.ts" -o -name "*.spec.ts" | xargs sed -i '' 's/jest\.fn/vi.fn/g'

# Step 3: Create vitest.config.ts
cat > vitest.config.ts << 'EOF'
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    globals: true,
    environment: 'node', // or 'jsdom' for UI
    setupFiles: ['./src/test/setup.ts']
  }
})
EOF

# Step 4: Update package.json
sed -i '' 's/"test": "jest"/"test": "vitest"/g' package.json
```

#### npm/yarn → pnpm Migration
```bash
# Step 1: Install pnpm
npm install -g pnpm@latest

# Step 2: Import from existing lockfile
pnpm import  # Creates pnpm-lock.yaml from package-lock.json

# Step 3: Clean install
rm -rf node_modules package-lock.json yarn.lock
pnpm install

# Step 4: Update scripts if needed
sed -i '' 's/npm run/pnpm/g' package.json
```

#### JavaScript → TypeScript Migration
```bash
# Step 1: Install TypeScript
pnpm add -D typescript @types/node

# Step 2: Generate initial tsconfig
npx tsc --init

# Step 3: Copy our standard tsconfig
gh api repos/sammons-software-llc/examples-for-ai/contents/examples/tsconfig.json.md --jq '.content' | base64 -d > tsconfig.reference.md

# Step 4: Rename files progressively
# Start with leaf modules (no dependencies)
find src -name "*.js" -not -path "*/node_modules/*" | while read f; do
  mv "$f" "${f%.js}.ts"
  # Add basic types
  # Fix errors
  # Commit
done
```

### === VALIDATION CHECKLIST ===

Before marking adoption complete:

```bash
# All must pass
pnpm test                     # ✓ Tests passing
pnpm lint:check              # ✓ Lint clean
pnpm type-check              # ✓ Types valid
pnpm build                   # ✓ Builds successfully

# Framework compliance
[ -f "CLAUDE.md" ]           # ✓ Framework file
[ -d "lib" ] || [ -d "src" ] # ✓ Proper structure
grep -q "vitest" package.json # ✓ Correct test runner
[ -f "pnpm-lock.yaml" ]      # ✓ Using pnpm

# Documentation
[ -f "README.md" ]           # ✓ Has readme
grep -q "Architecture" README.md # ✓ Architecture documented
```

### === COMMON PATTERNS TO REFACTOR ===

#### Express → Fastify
```typescript
// Old Express pattern
app.get('/users/:id', async (req, res) => {
  try {
    const user = await db.query('SELECT * FROM users WHERE id = ?', [req.params.id])
    res.json(user)
  } catch (error) {
    res.status(500).json({ error: error.message })
  }
})

// New Fastify + our patterns
// handlers/get-user.ts
export async function getUserHandler(
  request: FastifyRequest<{ Params: { id: string } }>,
  reply: FastifyReply
) {
  const strategy = new UserStrategy()
  const user = await strategy.getUser(request.params.id)
  return reply.send(user)
}
```

#### Mongoose → Prisma
```typescript
// Old Mongoose pattern
const user = await User.findById(id).populate('posts')

// New Prisma pattern
const user = await prisma.user.findUnique({
  where: { id },
  include: { posts: true }
})
```

#### Callback → Promise
```typescript
// Old callback pattern
function loadUser(id, callback) {
  db.query('SELECT * FROM users WHERE id = ?', [id], (err, result) => {
    if (err) return callback(err)
    callback(null, result[0])
  })
}

// New Promise pattern
async function loadUser(id: string): Promise<User> {
  const result = await db.query('SELECT * FROM users WHERE id = ?', [id])
  return result[0]
}
```

### === POST-ADOPTION ===

After successful adoption:

1. **Create Migration Documentation**
```markdown
# Migration Notes

## Original State
- Test Framework: [jest/mocha/none]
- Package Manager: [npm/yarn]
- Structure: [mvc/functional/chaos]

## Changes Made
- Migrated to Vitest (commit: abc123)
- Converted to pnpm (commit: def456)
- Restructured to handler/strategy/repository pattern (commit: ghi789)

## Breaking Changes
- API endpoints moved from /user to /api/v1/users
- Config now uses environment.ts instead of config.js

## Rollback Plan
- Tag pre-migration: git tag pre-framework-adoption
- Critical paths documented in e2e tests
```

2. **Set Up Monitoring**
- Track performance metrics pre/post migration
- Monitor error rates
- Check bundle sizes

3. **Team Notification**
```bash
gh issue create --title "Framework Adoption Complete" \
  --body "Project has been migrated to standard framework. See migration-notes.md for details."
```

Remember: The goal is working software that follows our standards, not perfection on day one. Incremental improvement is better than broken systems.