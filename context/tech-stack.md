=== CONTEXT ===
Technical standards and configuration requirements for all projects.
These specifications override any defaults or common practices.

=== AWS SERVICES ===
Allowed Services:
✅ DynamoDB, SQS, SNS, SES, S3
✅ API Gateway, CloudWatch, CloudFront
✅ AppSync, Lambda, Cognito

Forbidden Services:
⛔ Route53 - NEVER use
⛔ DynamoDBStreams - NEVER use

Service Configurations:
- Lambda: Zip deployment, Node.js/Rust preferred
- DynamoDB: ALWAYS use queries for non-scalar data
- S3: NEVER allow public access
- CloudFront/API Gateway: ALWAYS edge-optimized
- SQS: DLQ with 14-day retention, 5 retries, 1-hour visibility

=== DATABASE STANDARDS ===
Relational (Prisma):
- Up/down migrations required
- Foreign keys mandatory
- snake_case for all names
- Plural table names

DynamoDB:
- Idempotent primary keys (PK = HK + optional SK)
- GSI for non-idempotent sort requirements
- get-item for single item retrieval
- Queries for multi-item retrieval

=== API DESIGN ===
REST Standards:
- Versioned routes: /api/v1/, /api/v2/
- Health check: GET /api/health
- Auth: Bearer tokens (except local dev)
- CORS: Allow all origins initially
- Response time: <500ms target

Error Handling:
- Shared error types for standard HTTP codes
- Consistent error response format
- Never expose internal details

=== TESTING REQUIREMENTS ===
⛔ NEVER use Jest - Vitest is the ONLY approved test runner
⛔ If you see "jest" in any file, replace with "vitest"
⛔ If you see @jest/globals, replace with vitest imports

Test Runner: Vitest ONLY
- Configuration: vitest.config.ts (NOT jest.config)
- Test syntax: import { describe, it, expect } from 'vitest'
- Mock syntax: import { vi } from 'vitest' (NOT jest.fn())

Performance Targets:
- API unit tests: <10 seconds
- UI unit tests: <20 seconds
- E2E tests: Screenshot on every significant change

Test Structure:
- Real database for tests (no mocks)
- Focus on critical path coverage
- Idempotent test data cleanup

=== CODE ORGANIZATION ===
Monorepo Structure:
```
./lib/ui            # React frontend
./lib/api           # Business logic
./lib/server        # Fastify server
./lib/shared-types  # Zod contracts
./lib/e2e          # Playwright tests
./lib/cdk          # Infrastructure
```

File Naming:
- kebab-case.ts for TypeScript files
- PascalCase for CDK stacks
- snake_case for database entities

=== CONFIGURATION EXAMPLES ===
See: ./examples/config-files.md for:
- tsconfig.json templates
- vite.config.ts templates  
- eslint.config.ts template
- package.json structure

=== VALIDATION ===
□ All AWS services in allowed list
□ Database naming follows standards
□ API routes properly versioned
□ Test execution times within limits
□ File structure matches template