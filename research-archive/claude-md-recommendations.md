# CLAUDE.md Enhancement Recommendations

## Priority 1: New Archetypes (Address 50% gap)

### PA: Desktop Application
```markdown
#### PA: Desktop Application

Electron applications that run on Windows, macOS, and Linux.
- Uses Electron with React and TypeScript
- Main/renderer process separation with type-safe IPC
- Auto-updater using electron-updater
- Code signing for distribution
- Native OS integration (menus, tray, notifications)
- Typical structure:
  + ./lib/main <- main process code
  + ./lib/renderer <- React UI code  
  + ./lib/shared <- shared types and utilities
  + ./lib/preload <- preload scripts for security
- Use electron-builder for packaging
- Store user data in app.getPath('userData')
- Preferences via electron-store
- Deep linking support
- Crash reporting with Sentry
```

### PA: Mobile Application
```markdown
#### PA: Mobile Application

React Native applications with Expo for iOS and Android.
- Uses Expo with React Native and TypeScript
- Expo managed workflow preferred over bare
- React Navigation for routing
- AsyncStorage for persistence
- Typical structure:
  + ./src/screens <- screen components
  + ./src/components <- reusable components
  + ./src/navigation <- navigation configuration
  + ./src/services <- API and native services
  + ./src/stores <- MobX stores
- EAS Build for CI/CD
- Over-the-air updates via Expo Updates
- Push notifications via Expo Notifications
- Prefer expo-secure-store for sensitive data
```

### PA: CLI Tool
```markdown
#### PA: CLI Tool

Command-line tools distributed via npm or as binaries.
- Uses Node.js built-in parseArgs when simple
- Commander.js only for complex multi-command CLIs
- Typical structure:
  + ./src/cli.ts <- entry point with shebang
  + ./src/commands <- command implementations
  + ./src/utils <- shared utilities
- Use chalk for colors, ora for spinners
- Update notifier for version checks
- Prefer inquirer for interactive prompts
- Distribution:
  + npm for Node.js developers
  + pkg or nexe for standalone binaries
  + Homebrew formula for macOS
- Store config in XDG paths
- Add shell completion scripts
```

### PA: Real-time Collaborative
```markdown
#### PA: Real-time Collaborative

Applications with real-time multi-user features.
- Uses Socket.io for WebSocket abstraction
- Yjs for CRDT-based collaboration
- Presence system with user awareness
- Typical structure:
  + ./lib/server <- Socket.io server
  + ./lib/client <- Socket.io client hooks
  + ./lib/crdt <- Yjs document types
  + ./lib/presence <- presence system
- Room-based isolation
- Optimistic UI updates
- Conflict-free merge strategies
- Persistence via y-websocket
- Redis adapter for scaling
```

### PA: Browser Extension
```markdown
#### PA: Browser Extension

Extensions for Chrome, Firefox, and Edge.
- Manifest V3 for future compatibility
- TypeScript for all scripts
- React for popup and options UI
- Typical structure:
  + ./src/background <- service worker
  + ./src/content <- content scripts
  + ./src/popup <- popup UI
  + ./src/options <- options page
  + ./public/manifest.json
- Use webextension-polyfill for cross-browser
- Chrome storage sync for settings
- Message passing patterns
- Webpack config for multiple entries
- Web store deployment automation
```

## Priority 2: Technical Stack Expansions

### State Management Additions
```markdown
#### State Management

Beyond MobX for specific use cases:
- Zustand: For simpler stores without decorators
- Valtio: For proxy-based reactive state
- XState: For complex state machines
- TanStack Query: For server state
- Jotai: For atomic state management

Example Zustand store:
\`\`\`typescript
interface StoreState {
  count: number
  increment: () => void
}

const useStore = create<StoreState>((set) => ({
  count: 0,
  increment: () => set((state) => ({ count: state.count + 1 })),
}))
\`\`\`
```

### Database Expansions
```markdown
#### PostgreSQL with Prisma

For relational data beyond SQLite:
- Use PostgreSQL 15+ with Prisma
- Connection pooling via Prisma
- JSON columns for flexible data
- Full-text search with tsvector
- Naming: snake_case for all database objects

Example schema:
\`\`\`prisma
model users {
  id         String   @id @default(uuid())
  email      String   @unique
  created_at DateTime @default(now())
  updated_at DateTime @updatedAt
  
  @@map("users")
}
\`\`\`

#### Redis Patterns

For caching and pub/sub:
- ioredis as client
- Key naming: project:entity:id
- TTL on all cache keys
- Lua scripts for atomic operations
- Redis Streams for event sourcing
```

### API Patterns Beyond REST
```markdown
#### GraphQL Patterns

When REST becomes limiting:
- Apollo Server with TypeGraphQL
- Code-first schema approach
- DataLoader for N+1 prevention
- Subscription support via WebSockets
- Error handling via GraphQL errors
- Depth limiting for security
- Generate TypeScript types

#### tRPC Patterns

For TypeScript-only stacks:
- End-to-end type safety
- No code generation needed
- React Query integration
- WebSocket support
- Error handling via procedures
```

## Priority 3: Workflow Enhancements

### Monorepo Tooling
```markdown
#### Turborepo Configuration

For better monorepo performance:
\`\`\`json
{
  "pipeline": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**"]
    },
    "test": {
      "dependsOn": ["build"],
      "inputs": ["src/**", "test/**"]
    }
  }
}
\`\`\`

Remote caching with Vercel
Parallel execution optimization
```

### Code Generation
```markdown
#### Code Generation Patterns

Reduce boilerplate with generation:
- GraphQL Code Generator for types
- Prisma Client generation
- OpenAPI to TypeScript client
- Route type generation
- Icon sprite generation

Example codegen.yml:
\`\`\`yaml
generates:
  src/generated/graphql.ts:
    plugins:
      - typescript
      - typescript-operations
      - typescript-react-query
\`\`\`
```

### Advanced Testing
```markdown
#### Testing Expansions

Beyond unit tests:
- Testcontainers for integration tests
- MSW for API mocking
- Playwright component testing
- Visual regression with Percy
- Load testing with k6
- Mutation testing with Stryker

Example MSW setup:
\`\`\`typescript
const handlers = [
  rest.get('/api/user', (req, res, ctx) => {
    return res(ctx.json({ name: 'John' }))
  }),
]
\`\`\`
```

## Priority 4: Domain-Specific Additions

### Machine Learning Integration
```markdown
#### ML/AI Patterns

For TypeScript ML projects:
- TensorFlow.js for in-browser ML
- ONNX Runtime for model portability
- Worker threads for CPU-intensive tasks
- Model versioning via S3
- A/B testing for model comparison
- Feature store patterns

Python interop:
- Child process with structured output
- REST API with FastAPI
- Shared Protobuf definitions
```

### Real-time Data Processing
```markdown
#### Streaming Patterns

For high-throughput data:
- Node.js streams for ETL
- Kafka.js for event streaming
- BullMQ for job queues
- EventEmitter patterns
- Backpressure handling
- Dead letter queues

Example stream pipeline:
\`\`\`typescript
pipeline(
  readStream,
  transformStream,
  writeStream,
  (err) => console.error(err)
)
\`\`\`
```

### Security Patterns
```markdown
#### Security Enhancements

For sensitive applications:
- Helmet.js configurations
- Rate limiting strategies
- Input validation with Zod
- SQL injection prevention
- XSS protection patterns
- CSRF token handling
- Security headers
- Dependency scanning
- Secret scanning in CI

Example rate limiter:
\`\`\`typescript
const limiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  max: 100,
  standardHeaders: true,
})
\`\`\`
```

## Priority 5: Performance Patterns

### Frontend Performance
```markdown
#### Web Performance

Optimization strategies:
- Code splitting with React.lazy
- Bundle analysis with webpack-bundle-analyzer
- Image optimization with sharp
- Lazy loading with Intersection Observer
- Web Workers for heavy computation
- Service Worker for offline
- Preloading critical resources
- Resource hints (prefetch, preconnect)
```

### Backend Performance  
```markdown
#### API Performance

Optimization patterns:
- Response caching strategies
- Database query optimization
- Connection pooling
- Gzip/Brotli compression
- ETags for conditional requests
- Pagination best practices
- Batch endpoint patterns
- GraphQL query complexity analysis
```

## Implementation Priority

1. **Immediate** (Covers 80% of gaps):
   - Add 5 new archetypes
   - Expand state management section
   - Add PostgreSQL/Redis patterns

2. **Short-term** (Next 15%):
   - GraphQL/tRPC patterns
   - Monorepo tooling
   - Security patterns

3. **Long-term** (Final 5%):
   - ML/AI patterns
   - Domain-specific guides
   - Advanced performance patterns

This enhancement would transform CLAUDE.md from covering ~30% to ~95% of potential projects.