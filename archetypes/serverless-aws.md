=== CONTEXT ===
Serverless AWS archetype for SaaS applications using API Gateway/AppSync.
Multi-account deployment (dev/beta/prod) with infrastructure as code.

=== OBJECTIVE ===
Build scalable serverless application on AWS free tier.
Success metrics:
□ Zero monthly cost in free tier usage
□ <500ms API response times
□ 99.9% uptime target
□ Automated multi-stage deployment

=== ARCHITECTURE ===
Authentication:
- Cognito with password auth
- Optional MFA/TOTP (no SMS)
- JWT tokens for API access

Compute:
- Lambda functions (Node.js/Rust)
- Single codebase, multiple handlers
- Zip deployment (layers only when necessary)

Storage:
- DynamoDB for application data
- S3 for file/asset storage
- CloudWatch for logs (EMF for metrics)

API Layer:
- API Gateway (edge-optimized)
- RESTful design with versioning
- CloudFront for caching

=== PROJECT STRUCTURE ===
```
./lib/cdk/
  ├── stacks/
  │   ├── dev-stack.ts
  │   ├── beta-stack.ts
  │   └── prod-stack.ts
  └── constructs/
      └── [shared constructs]

./lib/api-lambda/
  ├── index.ts              # Bundle exports
  ├── handlers/
  │   └── [handler].ts      # Entry points
  └── dist/
      ├── index.js
      └── bundles/
          └── [handler].js

./lib/integration-tests/    # Live service tests
```

Handler Bundle Pattern:
```typescript
// index.ts
export const UserHandlerBundle = resolve(__dirname, './bundles/user.js')
export const AuthHandlerBundle = resolve(__dirname, './bundles/auth.js')
```

=== CDK CONFIGURATION ===
Stack Naming:
- PascalCase: DevStack, BetaStack, ProdStack
- Environment-specific configs
- Cross-account deployment ready

GitHub OIDC Setup:
```yaml
- uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: arn:aws:iam::123456789012:role/GitHubActionsRole
    aws-region: us-east-1
```

=== DYNAMODB PATTERNS ===
Key Design:
- Idempotent PKs (never timestamp alone)
- GSI for flexible queries
- Single-table design preferred

Access Patterns:
- get-item for single records
- query for collections
- GSI for alternate access
- Avoid scans except ops scripts

=== CONSTRAINTS ===
⛔ NEVER use default API Gateway endpoints
⛔ NEVER expose S3 buckets publicly  
⛔ NEVER store secrets in code/env vars
✅ ALWAYS use edge-optimized endpoints
✅ ALWAYS implement health checks
✅ ALWAYS use structured logging (JSON)

=== VALIDATION CHECKLIST ===
□ Free tier usage calculated
□ Multi-account CDK configs ready
□ GitHub OIDC configured
□ Lambda bundles properly structured  
□ DynamoDB access patterns optimized