# Deployment Guide

## Context
You are deploying applications following Ben's preferences for AWS, GitHub Actions, and cost-effective infrastructure. This guide provides battle-tested deployment patterns with security and monitoring built-in.

## Objective
Deploy applications reliably and securely while maintaining low costs and high observability using appropriate deployment strategies for each project type.

## Process

### === DEPLOYMENT DECISION TREE ===

```
IF project_type == "static-website":
    THEN: Deploy to GitHub Pages
    AND: Use GitHub Actions for CI/CD
    OUTPUT: Zero-cost static hosting

ELIF project_type == "local-app":
    THEN: Package as executable/container
    AND: Distribute via GitHub Releases
    OUTPUT: Self-hosted deployment

ELIF project_type == "serverless-aws":
    THEN: Deploy via CDK
    AND: Use GitHub OIDC for AWS access
    OUTPUT: Serverless infrastructure

ELIF project_type == "containerized-app":
    THEN: Build and push to ECR
    AND: Deploy to ECS Fargate or Lambda
    OUTPUT: Container deployment

ELSE:
    THEN: Default to GitHub Releases
    AND: Provide deployment scripts
    OUTPUT: Flexible deployment
```

## Deployment Patterns

### 1. GitHub Actions Base Configuration

```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]
  release:
    types: [created]

env:
  NODE_VERSION: '24'
  PNPM_VERSION: '9'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: ${{ env.NODE_VERSION }}
          
      - name: Setup pnpm
        uses: pnpm/action-setup@v3
        with:
          version: ${{ env.PNPM_VERSION }}
          
      - name: Get pnpm store directory
        id: pnpm-cache
        shell: bash
        run: |
          echo "STORE_PATH=$(pnpm store path)" >> $GITHUB_OUTPUT
          
      - uses: actions/cache@v4
        name: Setup pnpm cache
        with:
          path: ${{ steps.pnpm-cache.outputs.STORE_PATH }}
          key: ${{ runner.os }}-pnpm-store-${{ hashFiles('**/pnpm-lock.yaml') }}
          restore-keys: |
            ${{ runner.os }}-pnpm-store-
            
      - name: Install dependencies
        run: pnpm install --frozen-lockfile
        
      - name: Run tests
        run: pnpm test
        
      - name: Run lint
        run: pnpm lint:check
        
      - name: Type check
        run: pnpm type-check
        
      - name: Build
        run: pnpm build
        
      - name: Upload coverage
        uses: codecov/codecov-action@v4
        with:
          files: ./coverage/cobertura-coverage.xml
          flags: unittests
          name: codecov-umbrella
```

### 2. Static Website Deployment (GitHub Pages)

```yaml
# .github/workflows/deploy-static.yml
name: Deploy Static Site

on:
  push:
    branches: [main]
  workflow_dispatch:

permissions:
  contents: read
  pages: write
  id-token: write

concurrency:
  group: "pages"
  cancel-in-progress: false

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '24'
          
      - name: Setup pnpm
        uses: pnpm/action-setup@v3
        with:
          version: '9'
          
      - name: Install dependencies
        run: pnpm install --frozen-lockfile
        
      - name: Build site
        run: pnpm build
        env:
          PUBLIC_URL: https://${{ github.repository_owner }}.github.io/${{ github.event.repository.name }}
          
      - name: Setup Pages
        uses: actions/configure-pages@v4
        
      - name: Upload artifact
        uses: actions/upload-pages-artifact@v3
        with:
          path: './dist'
          
  deploy:
    environment:
      name: github-pages
      url: ${{ steps.deployment.outputs.page_url }}
    runs-on: ubuntu-latest
    needs: build
    steps:
      - name: Deploy to GitHub Pages
        id: deployment
        uses: actions/deploy-pages@v4
```

### 3. AWS Serverless Deployment (CDK)

```yaml
# .github/workflows/deploy-aws.yml
name: Deploy to AWS

on:
  push:
    branches: [main]
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy to'
        required: true
        default: 'dev'
        type: choice
        options:
          - dev
          - staging
          - prod

permissions:
  id-token: write
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: ${{ inputs.environment || 'dev' }}
    steps:
      - uses: actions/checkout@v4
      
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: us-east-1
          
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '24'
          
      - name: Setup pnpm
        uses: pnpm/action-setup@v3
        with:
          version: '9'
          
      - name: Install dependencies
        run: pnpm install --frozen-lockfile
        
      - name: Build application
        run: pnpm build
        
      - name: Run CDK diff
        run: |
          cd lib/cdk
          pnpm cdk diff --context env=${{ inputs.environment || 'dev' }}
          
      - name: Deploy CDK stack
        run: |
          cd lib/cdk
          pnpm cdk deploy --require-approval never --context env=${{ inputs.environment || 'dev' }}
          
      - name: Run smoke tests
        run: pnpm test:smoke
        env:
          API_ENDPOINT: ${{ steps.deploy.outputs.api_url }}
```

### 4. Container Deployment

```yaml
# .github/workflows/deploy-container.yml
name: Build and Deploy Container

on:
  push:
    branches: [main]
  release:
    types: [created]

env:
  REGISTRY: ghcr.io
  IMAGE_NAME: ${{ github.repository }}

jobs:
  build:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      packages: write
    outputs:
      image: ${{ steps.image.outputs.image }}
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3
        
      - name: Log in to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ${{ env.REGISTRY }}
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
          
      - name: Extract metadata
        id: meta
        uses: docker/metadata-action@v5
        with:
          images: ${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}
          tags: |
            type=ref,event=branch
            type=ref,event=pr
            type=semver,pattern={{version}}
            type=semver,pattern={{major}}.{{minor}}
            type=sha
            
      - name: Build and push Docker image
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ${{ steps.meta.outputs.tags }}
          labels: ${{ steps.meta.outputs.labels }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
          platforms: linux/amd64,linux/arm64
          
      - name: Output image
        id: image
        run: echo "image=${{ env.REGISTRY }}/${{ env.IMAGE_NAME }}:${{ steps.meta.outputs.version }}" >> $GITHUB_OUTPUT
```

### 5. Desktop App Deployment (Electron)

```yaml
# .github/workflows/deploy-desktop.yml
name: Build Desktop App

on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    strategy:
      matrix:
        os: [macos-latest, ubuntu-latest, windows-latest]
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '24'
          
      - name: Setup pnpm
        uses: pnpm/action-setup@v3
        with:
          version: '9'
          
      - name: Install dependencies
        run: pnpm install --frozen-lockfile
        
      - name: Build app
        run: pnpm build
        
      - name: Build Electron app
        run: pnpm electron:build
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
          
      - name: Upload artifacts
        uses: actions/upload-artifact@v4
        with:
          name: desktop-${{ matrix.os }}
          path: |
            dist_electron/*.exe
            dist_electron/*.dmg
            dist_electron/*.AppImage
            dist_electron/*.deb
            
  release:
    needs: build
    runs-on: ubuntu-latest
    permissions:
      contents: write
    steps:
      - name: Download artifacts
        uses: actions/download-artifact@v4
        
      - name: Create Release
        uses: softprops/action-gh-release@v1
        with:
          files: |
            desktop-*/*
          draft: false
          prerelease: false
```

## CDK Stack Examples

### Basic API Stack

```typescript
// lib/cdk/stacks/api-stack.ts
import * as cdk from 'aws-cdk-lib'
import * as lambda from 'aws-cdk-lib/aws-lambda'
import * as apigateway from 'aws-cdk-lib/aws-apigateway'
import * as dynamodb from 'aws-cdk-lib/aws-dynamodb'
import * as logs from 'aws-cdk-lib/aws-logs'
import { Construct } from 'constructs'

export interface ApiStackProps extends cdk.StackProps {
  environment: 'dev' | 'staging' | 'prod'
}

export class ApiStack extends cdk.Stack {
  public readonly apiUrl: string
  
  constructor(scope: Construct, id: string, props: ApiStackProps) {
    super(scope, id, props)
    
    // DynamoDB Table
    const table = new dynamodb.Table(this, 'Table', {
      partitionKey: { name: 'pk', type: dynamodb.AttributeType.STRING },
      sortKey: { name: 'sk', type: dynamodb.AttributeType.STRING },
      billingMode: dynamodb.BillingMode.PAY_PER_REQUEST,
      encryption: dynamodb.TableEncryption.AWS_MANAGED,
      pointInTimeRecovery: props.environment === 'prod',
      removalPolicy: props.environment === 'prod' 
        ? cdk.RemovalPolicy.RETAIN 
        : cdk.RemovalPolicy.DESTROY
    })
    
    // Add GSI for queries
    table.addGlobalSecondaryIndex({
      indexName: 'gsi1',
      partitionKey: { name: 'gsi1pk', type: dynamodb.AttributeType.STRING },
      sortKey: { name: 'gsi1sk', type: dynamodb.AttributeType.STRING },
      projectionType: dynamodb.ProjectionType.ALL
    })
    
    // Lambda Function
    const handler = new lambda.Function(this, 'Handler', {
      runtime: lambda.Runtime.NODEJS_20_X,
      code: lambda.Code.fromAsset('../api-lambda/dist/bundles'),
      handler: 'index.handler',
      memorySize: props.environment === 'prod' ? 1024 : 512,
      timeout: cdk.Duration.seconds(30),
      environment: {
        NODE_ENV: props.environment,
        TABLE_NAME: table.tableName,
        LOG_LEVEL: props.environment === 'prod' ? 'info' : 'debug'
      },
      logRetention: logs.RetentionDays.ONE_WEEK,
      tracing: lambda.Tracing.ACTIVE
    })
    
    // Grant permissions
    table.grantReadWriteData(handler)
    
    // API Gateway
    const api = new apigateway.RestApi(this, 'Api', {
      restApiName: `${props.environment}-api`,
      deployOptions: {
        stageName: props.environment,
        tracingEnabled: true,
        loggingLevel: apigateway.MethodLoggingLevel.ERROR,
        dataTraceEnabled: props.environment !== 'prod',
        metricsEnabled: true,
        throttlingBurstLimit: 100,
        throttlingRateLimit: 50
      },
      defaultCorsPreflightOptions: {
        allowOrigins: apigateway.Cors.ALL_ORIGINS,
        allowMethods: apigateway.Cors.ALL_METHODS,
        allowHeaders: ['Content-Type', 'Authorization']
      }
    })
    
    // Lambda integration
    const integration = new apigateway.LambdaIntegration(handler)
    
    // API routes
    const v1 = api.root.addResource('api').addResource('v1')
    
    // Health check
    v1.addResource('health').addMethod('GET', integration)
    
    // Users endpoint
    const users = v1.addResource('users')
    users.addMethod('GET', integration) // List users
    users.addMethod('POST', integration) // Create user
    
    const user = users.addResource('{userId}')
    user.addMethod('GET', integration) // Get user
    user.addMethod('PATCH', integration) // Update user
    user.addMethod('DELETE', integration) // Delete user
    
    // Outputs
    this.apiUrl = api.url
    new cdk.CfnOutput(this, 'ApiUrl', {
      value: this.apiUrl,
      description: 'API Gateway URL'
    })
  }
}
```

### Multi-Environment Configuration

```typescript
// lib/cdk/app.ts
#!/usr/bin/env node
import 'source-map-support/register'
import * as cdk from 'aws-cdk-lib'
import { ApiStack } from './stacks/api-stack'

const app = new cdk.App()

// Get environment from context
const environment = app.node.tryGetContext('env') as 'dev' | 'staging' | 'prod'

// Environment-specific configuration
const config = {
  dev: {
    account: '123456789012',
    region: 'us-east-1',
    domainName: 'api-dev.example.com'
  },
  staging: {
    account: '123456789013',
    region: 'us-east-1',
    domainName: 'api-staging.example.com'
  },
  prod: {
    account: '123456789014',
    region: 'us-east-1',
    domainName: 'api.example.com'
  }
}

const envConfig = config[environment] || config.dev

new ApiStack(app, `ApiStack-${environment}`, {
  env: {
    account: envConfig.account,
    region: envConfig.region
  },
  environment,
  tags: {
    Environment: environment,
    Project: 'MyApp',
    ManagedBy: 'CDK'
  }
})
```

## Monitoring and Alerts

### CloudWatch Dashboard

```typescript
// lib/cdk/constructs/monitoring.ts
import * as cdk from 'aws-cdk-lib'
import * as cloudwatch from 'aws-cdk-lib/aws-cloudwatch'
import * as sns from 'aws-cdk-lib/aws-sns'
import * as lambda from 'aws-cdk-lib/aws-lambda'
import { Construct } from 'constructs'

export interface MonitoringProps {
  lambdaFunction: lambda.Function
  apiName: string
  environment: string
}

export class Monitoring extends Construct {
  constructor(scope: Construct, id: string, props: MonitoringProps) {
    super(scope, id)
    
    // SNS Topic for alerts
    const alertTopic = new sns.Topic(this, 'AlertTopic', {
      displayName: `${props.apiName} Alerts`
    })
    
    // Lambda metrics
    const errorMetric = props.lambdaFunction.metricErrors({
      period: cdk.Duration.minutes(1)
    })
    
    const throttleMetric = props.lambdaFunction.metricThrottles({
      period: cdk.Duration.minutes(1)
    })
    
    const durationMetric = props.lambdaFunction.metricDuration({
      period: cdk.Duration.minutes(1)
    })
    
    // Alarms
    new cloudwatch.Alarm(this, 'ErrorAlarm', {
      metric: errorMetric,
      threshold: 10,
      evaluationPeriods: 2,
      treatMissingData: cloudwatch.TreatMissingData.NOT_BREACHING,
      alarmDescription: 'Lambda function errors'
    }).addAlarmAction(new cloudwatch_actions.SnsAction(alertTopic))
    
    new cloudwatch.Alarm(this, 'ThrottleAlarm', {
      metric: throttleMetric,
      threshold: 5,
      evaluationPeriods: 1,
      treatMissingData: cloudwatch.TreatMissingData.NOT_BREACHING,
      alarmDescription: 'Lambda function throttles'
    }).addAlarmAction(new cloudwatch_actions.SnsAction(alertTopic))
    
    // Dashboard
    new cloudwatch.Dashboard(this, 'Dashboard', {
      dashboardName: `${props.apiName}-${props.environment}`,
      widgets: [
        [
          new cloudwatch.GraphWidget({
            title: 'Lambda Invocations',
            left: [props.lambdaFunction.metricInvocations()],
            right: [errorMetric]
          }),
          new cloudwatch.GraphWidget({
            title: 'Lambda Duration',
            left: [durationMetric]
          })
        ],
        [
          new cloudwatch.GraphWidget({
            title: 'Lambda Throttles',
            left: [throttleMetric]
          }),
          new cloudwatch.GraphWidget({
            title: 'Lambda Concurrent Executions',
            left: [props.lambdaFunction.metricConcurrentExecutions()]
          })
        ]
      ]
    })
  }
}
```

## Security Best Practices

### GitHub OIDC Setup

```typescript
// lib/cdk/stacks/github-oidc-stack.ts
import * as cdk from 'aws-cdk-lib'
import * as iam from 'aws-cdk-lib/aws-iam'
import { Construct } from 'constructs'

export class GitHubOidcStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props)
    
    // Create OIDC provider for GitHub
    const provider = new iam.OpenIdConnectProvider(this, 'GitHubProvider', {
      url: 'https://token.actions.githubusercontent.com',
      clientIds: ['sts.amazonaws.com'],
      thumbprints: ['6938fd4d98bab03faadb97b34396831e3780aea1']
    })
    
    // Create role for GitHub Actions
    const role = new iam.Role(this, 'GitHubActionsRole', {
      assumedBy: new iam.OpenIdConnectPrincipal(provider, {
        StringEquals: {
          'token.actions.githubusercontent.com:aud': 'sts.amazonaws.com'
        },
        StringLike: {
          'token.actions.githubusercontent.com:sub': 'repo:sammons-software-llc/*:*'
        }
      }),
      description: 'Role for GitHub Actions deployments',
      maxSessionDuration: cdk.Duration.hours(1)
    })
    
    // Add necessary policies
    role.addManagedPolicy(
      iam.ManagedPolicy.fromAwsManagedPolicyName('PowerUserAccess')
    )
    
    // Deny dangerous actions
    role.addToPolicy(new iam.PolicyStatement({
      effect: iam.Effect.DENY,
      actions: [
        'iam:DeleteRole',
        'iam:DeleteRolePolicy',
        'iam:DeleteUser',
        'iam:DeleteUserPolicy',
        'organizations:*'
      ],
      resources: ['*']
    }))
    
    // Output role ARN
    new cdk.CfnOutput(this, 'GitHubActionsRoleArn', {
      value: role.roleArn,
      description: 'ARN of the role for GitHub Actions'
    })
  }
}
```

## Deployment Checklist

### Pre-deployment
- [ ] All tests passing
- [ ] Security scan completed
- [ ] Dependencies updated
- [ ] Environment variables documented
- [ ] Database migrations ready
- [ ] Rollback plan prepared

### During deployment
- [ ] Monitor deployment progress
- [ ] Check health endpoints
- [ ] Verify metrics flowing
- [ ] Test critical paths

### Post-deployment
- [ ] Smoke tests passing
- [ ] Metrics normal
- [ ] No error spikes
- [ ] Performance acceptable
- [ ] Alerts configured
- [ ] Documentation updated

## Cost Optimization

### AWS Free Tier Optimization
```typescript
// Use these settings to stay within free tier
const freeTeierSettings = {
  lambda: {
    memorySize: 128, // Minimum memory
    timeout: cdk.Duration.seconds(10),
    reservedConcurrentExecutions: undefined // No reserved capacity
  },
  dynamodb: {
    billingMode: dynamodb.BillingMode.PAY_PER_REQUEST,
    pointInTimeRecovery: false,
    contributorInsightsEnabled: false
  },
  apiGateway: {
    throttlingBurstLimit: 10,
    throttlingRateLimit: 5
  },
  cloudWatch: {
    logRetention: logs.RetentionDays.ONE_DAY // Minimize log storage
  }
}
```

Remember: Always use GitHub's built-in secrets management and never commit sensitive data to the repository.