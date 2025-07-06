# Deployment Configuration

Docker, CI/CD, and environment configurations for deployment.

## Dockerfile (Local Apps)

For applications with server components:

```dockerfile
FROM node:24-alpine AS builder

WORKDIR /app

# Install pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

# Copy workspace files
COPY pnpm-lock.yaml ./
COPY pnpm-workspace.yaml ./
COPY package.json ./

# Copy all workspace packages
COPY lib/ ./lib/

# Install dependencies
RUN pnpm install --frozen-lockfile

# Build all packages
RUN pnpm build

# Runtime stage
FROM node:24-alpine

WORKDIR /app

# Install pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

# Copy built application
COPY --from=builder /app/lib/server/dist ./dist
COPY --from=builder /app/lib/server/package.json ./
COPY --from=builder /app/node_modules ./node_modules

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

USER nodejs

EXPOSE 3000

CMD ["node", "dist/index.js"]
```

## Docker Compose (Development)

docker-compose.yml for local development:

```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
      - DATABASE_URL=postgresql://postgres:password@db:5432/app
    volumes:
      - ./src:/app/src
      - ./lib:/app/lib
    depends_on:
      - db
      - redis

  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: app
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: password
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data

volumes:
  postgres_data:
  redis_data:
```

## GitHub Actions CI/CD

.github/workflows/ci.yml:

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - uses: pnpm/action-setup@v2
        with:
          version: 9
          
      - uses: actions/setup-node@v4
        with:
          node-version: '24'
          cache: 'pnpm'
          
      - run: pnpm install --frozen-lockfile
      
      - run: pnpm lint:check
      
      - run: pnpm type-check
      
      - run: pnpm test:coverage
      
      - uses: actions/upload-artifact@v4
        if: always()
        with:
          name: coverage
          path: coverage/

  build:
    runs-on: ubuntu-latest
    needs: test
    
    steps:
      - uses: actions/checkout@v4
      
      - uses: pnpm/action-setup@v2
        with:
          version: 9
          
      - uses: actions/setup-node@v4
        with:
          node-version: '24'
          cache: 'pnpm'
          
      - run: pnpm install --frozen-lockfile
      
      - run: pnpm build
      
      - name: Build Docker image
        if: ${{ hashFiles('Dockerfile') != '' }}
        run: docker build -t test-build .
```

## AWS Lambda Deployment

For serverless applications:

```yaml
# .github/workflows/deploy-lambda.yml
name: Deploy Lambda

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - uses: pnpm/action-setup@v2
        with:
          version: 9
          
      - uses: actions/setup-node@v4
        with:
          node-version: '24'
          cache: 'pnpm'
          
      - run: pnpm install --frozen-lockfile
      - run: pnpm build
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1
      
      - name: Deploy with CDK
        run: |
          cd infrastructure
          npm install
          npx cdk deploy --require-approval never
```

## Environment Configuration

.env.example:

```bash
# Server Configuration
PORT=3000
NODE_ENV=development

# Database
DATABASE_URL=file:./dev.db

# External Services (configured via UI)
# These are loaded from database after UI configuration
# OPENAI_API_KEY=
# ANTHROPIC_API_KEY=

# Feature Flags
ENABLE_DEBUG_LOGGING=true

# AWS (for serverless deployments)
AWS_REGION=us-east-1
AWS_ACCOUNT_ID=123456789012

# Security
JWT_SECRET=your-secret-key
SESSION_SECRET=your-session-secret

# Monitoring
LOG_LEVEL=info
METRICS_ENABLED=true
```

## Kubernetes Deployment

For container orchestration:

```yaml
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: app-deployment
  labels:
    app: my-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: app
        image: my-app:latest
        ports:
        - containerPort: 3000
        env:
        - name: NODE_ENV
          value: "production"
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: app-secrets
              key: database-url
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
        livenessProbe:
          httpGet:
            path: /health
            port: 3000
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 3000
          initialDelaySeconds: 5
          periodSeconds: 5

---
apiVersion: v1
kind: Service
metadata:
  name: app-service
spec:
  selector:
    app: my-app
  ports:
    - protocol: TCP
      port: 80
      targetPort: 3000
  type: LoadBalancer
```

## Nginx Configuration

For reverse proxy setup:

```nginx
# nginx.conf
upstream app {
    server app:3000;
}

server {
    listen 80;
    server_name localhost;

    # Security headers
    add_header X-Frame-Options DENY;
    add_header X-Content-Type-Options nosniff;
    add_header X-XSS-Protection "1; mode=block";
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/javascript
        application/xml+rss
        application/json;

    # Static assets
    location /static/ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        try_files $uri =404;
    }

    # API routes
    location /api/ {
        proxy_pass http://app;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Frontend routes
    location / {
        proxy_pass http://app;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

## CDK Infrastructure (TypeScript)

For AWS CDK deployments:

```typescript
// infrastructure/lib/app-stack.ts
import * as cdk from 'aws-cdk-lib'
import * as lambda from 'aws-cdk-lib/aws-lambda'
import * as apigateway from 'aws-cdk-lib/aws-apigateway'
import * as dynamodb from 'aws-cdk-lib/aws-dynamodb'

export class AppStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props)

    // DynamoDB table
    const table = new dynamodb.Table(this, 'AppTable', {
      partitionKey: { name: 'id', type: dynamodb.AttributeType.STRING },
      billingMode: dynamodb.BillingMode.PAY_PER_REQUEST,
      removalPolicy: cdk.RemovalPolicy.DESTROY,
    })

    // Lambda function
    const lambdaFunction = new lambda.Function(this, 'AppFunction', {
      runtime: lambda.Runtime.NODEJS_20_X,
      handler: 'index.handler',
      code: lambda.Code.fromAsset('../dist'),
      environment: {
        TABLE_NAME: table.tableName,
      },
      timeout: cdk.Duration.seconds(30),
      memorySize: 512,
    })

    // Grant permissions
    table.grantReadWriteData(lambdaFunction)

    // API Gateway
    const api = new apigateway.RestApi(this, 'AppApi', {
      restApiName: 'App API',
      description: 'API for the app',
    })

    const integration = new apigateway.LambdaIntegration(lambdaFunction)
    api.root.addMethod('ANY', integration)
    api.root.addProxy({
      defaultIntegration: integration,
    })

    // Outputs
    new cdk.CfnOutput(this, 'ApiUrl', {
      value: api.url,
    })
  }
}
```

## GitIgnore for Deployments

Additional patterns for deployment files:

```gitignore
# Dependencies
node_modules/
.pnpm-store/

# Build outputs
dist/
build/
coverage/
*.tsbuildinfo

# Environment
.env
.env.local
.env.*.local

# IDE
.vscode/
.idea/
*.swp
*.swo
.DS_Store

# Logs
logs/
*.log

# Test artifacts
screenshots/
test-results/
playwright-report/

# Database
*.db
*.db-journal
*.sqlite

# Temporary
tmp/
temp/
.cache/

# Docker
.dockerignore

# Infrastructure
infrastructure/cdk.out/
infrastructure/node_modules/

# Kubernetes
k8s/secrets.yaml
```

## Health Check Endpoints

For monitoring and load balancers:

```typescript
// src/routes/health.ts
export const healthRoutes = {
  // Basic health check
  '/health': () => ({ status: 'ok', timestamp: new Date().toISOString() }),
  
  // Readiness check (for K8s)
  '/ready': async () => {
    // Check database connection, external services, etc.
    const checks = await Promise.allSettled([
      checkDatabase(),
      checkExternalServices(),
    ])
    
    const allHealthy = checks.every(result => result.status === 'fulfilled')
    
    return {
      status: allHealthy ? 'ready' : 'not ready',
      checks: checks.map(result => ({
        status: result.status,
        ...(result.status === 'rejected' && { error: result.reason.message })
      }))
    }
  }
}
```