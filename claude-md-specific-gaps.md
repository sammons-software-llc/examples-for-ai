# CLAUDE.md Specific Technical Gaps

## Critical Missing Patterns by Project Category

### Developer Tools & CLIs (100 simulated projects)

#### Gap 1: Package Publishing
**Current State**: No npm publishing guidance
**Missing**:
```json
// Missing package.json publishing config
{
  "publishConfig": {
    "access": "public",
    "registry": "https://registry.npmjs.org/"
  },
  "files": ["dist", "README.md", "LICENSE"],
  "bin": {
    "my-cli": "./dist/cli.js"
  }
}
```

#### Gap 2: CLI Framework Preferences
**Current State**: Only mentions Node.js built-in arg parser
**Missing**: Commander.js patterns for complex CLIs, despite preference against it
```typescript
// Missing guidance on when built-in parser isn't enough
// No patterns for subcommands, help generation, version management
```

#### Gap 3: Binary Distribution
**Current State**: No guidance
**Missing**: pkg, nexe, or Deno compile preferences

### Mobile Apps (100 simulated projects)

#### Completely Missing Archetype
```typescript
// No React Native + TypeScript patterns
// No Expo workflow preferences
// No mobile state management patterns
// No navigation library preferences (React Navigation)
// No mobile testing strategies
// No over-the-air update patterns
```

### Real-time Collaboration (60 simulated projects)

#### Gap 1: WebSocket Libraries
**Current State**: No WebSocket guidance
**Missing Preferences**:
- Socket.io vs native WebSocket
- Reconnection strategies
- Room/namespace patterns
- Authentication patterns for WebSockets

#### Gap 2: Conflict Resolution
**Current State**: No CRDT or OT guidance
**Missing**:
- Yjs vs Automerge preferences
- Conflict-free data type patterns
- Sync engine architecture

### Data Analysis/Visualization (50 simulated projects)

#### Gap 1: Visualization Libraries
**Current State**: No dataviz guidance beyond React
**Missing**:
- D3.js integration patterns with React
- Chart.js vs Recharts preferences
- Canvas vs SVG performance guidelines
- WebGL (Three.js) for 3D viz

#### Gap 2: Data Processing
**Current State**: No data pipeline patterns
**Missing**:
- Stream processing in Node.js
- Worker thread patterns
- Data transformation library preferences

### Machine Learning/AI Projects (50 simulated projects)

#### Gap 1: Python/TypeScript Interop
**Current State**: No cross-language guidance
**Missing**:
- Child process patterns for Python scripts
- REST API patterns for model serving
- Shared type definitions across languages

#### Gap 2: Model Deployment
**Current State**: No ML serving patterns
**Missing**:
- TensorFlow.js preferences
- ONNX runtime patterns
- Model versioning strategies

### Browser Extensions (70 simulated projects)

#### Completely Missing Archetype
```typescript
// No manifest.json v3 patterns
// No content script injection patterns  
// No background service worker patterns
// No cross-browser API abstraction
// No extension testing strategies
```

### Desktop Apps (80 simulated projects)

#### Electron Archetype Missing
```typescript
// No Electron + React + TypeScript patterns
// No main/renderer process communication
// No native menu integration
// No auto-updater patterns
// No code signing workflows
```

### IoT/Hardware (40 simulated projects)

#### Gap 1: Protocol Preferences
**Current State**: No IoT guidance
**Missing**:
- MQTT client patterns
- CoAP preferences
- WebSocket vs MQTT decision matrix

#### Gap 2: Edge Computing
**Current State**: No edge patterns
**Missing**:
- Local data aggregation patterns
- Offline-first sync strategies
- Resource-constrained computing patterns

### Infrastructure/DevOps Tools (80 simulated projects)

#### Gap 1: IaC Beyond CDK
**Current State**: Only CDK mentioned
**Missing**:
- Terraform patterns when needed
- Pulumi as TypeScript alternative
- CloudFormation for simple cases

#### Gap 2: Container Orchestration
**Current State**: Basic Docker only
**Missing**:
- Kubernetes manifest patterns
- Helm chart preferences
- Service mesh (Istio/Linkerd) patterns

### Gaming/3D Projects (40 simulated projects)

#### Completely Missing
```typescript
// No Three.js patterns
// No game loop architecture
// No physics engine integration (Matter.js, Cannon.js)
// No asset loading strategies
// No WebGL shader management
```

## Problematic Workflow Steps

### 1. Multi-Language Projects
**Problem**: Current workflow assumes TypeScript-only
**Example**: ML project with Python backend, TypeScript frontend
**Missing**: Cross-language type sharing, unified testing

### 2. Native Mobile Development
**Problem**: No workflow for app store submissions
**Missing**: 
- Code signing steps
- Screenshot generation
- Beta testing distribution
- App store metadata management

### 3. Hardware Integration Projects
**Problem**: No firmware update workflows
**Missing**:
- OTA update patterns
- Rollback mechanisms
- Device provisioning flows

### 4. High-Performance Requirements
**Problem**: No performance testing workflow
**Missing**:
- Load testing integration
- Performance budgets
- Profiling workflows
- Optimization decision trees

### 5. Regulated Industries
**Problem**: No compliance workflows
**Missing**:
- HIPAA compliance patterns
- PCI compliance checklist
- Audit trail requirements
- Data retention policies

## Database Gaps for Specific Use Cases

### Time-Series Data (40 projects)
**Current**: Only DynamoDB patterns
**Missing**: 
- InfluxDB patterns
- TimescaleDB with PostgreSQL
- Prometheus for metrics

### Graph Data (20 projects)
**Current**: No graph database guidance
**Missing**:
- Neo4j patterns
- AWS Neptune preferences
- GraphQL federation

### Full-Text Search (30 projects)
**Current**: No search guidance
**Missing**:
- Elasticsearch patterns
- Algolia integration
- PostgreSQL full-text search

### Geospatial Data (15 projects)
**Current**: No geo patterns
**Missing**:
- PostGIS patterns
- Geohashing strategies
- Spatial indexing

## State Management Gaps

### Complex State Requirements
**Current**: Only MobX mentioned
**Missing Modern Patterns**:
```typescript
// Redux Toolkit for complex state
// Zustand for simple state
// Valtio for proxy-based state
// Jotai for atomic state
// XState for state machines
```

### Server State Management
**Current**: No server state patterns
**Missing**:
```typescript
// React Query (TanStack Query) patterns
// SWR preferences
// Optimistic update strategies
// Cache invalidation patterns
```

## Testing Gaps for Specialized Projects

### Visual Regression Testing
**Missing**: Percy, Chromatic, or Playwright screenshot diff preferences

### Performance Testing
**Missing**: Lighthouse CI integration, Web Vitals monitoring

### Security Testing
**Missing**: OWASP ZAP integration, dependency scanning workflows

### Accessibility Testing
**Missing**: axe-core integration, WCAG compliance workflows

## Deployment Pattern Gaps

### Edge Computing
**Missing**: Cloudflare Workers, Vercel Edge Functions patterns

### Multi-Region
**Missing**: Data replication strategies, latency optimization

### Hybrid Cloud
**Missing**: On-premise integration patterns, VPN configurations

### Serverless Beyond Lambda
**Missing**: Fargate patterns, App Runner preferences