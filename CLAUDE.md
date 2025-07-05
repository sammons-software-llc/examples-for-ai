## Introduction

This repo is meant to be a compendium of example code for AI agents used by Ben Sammons.

## About Ben

- Over 10y exp in swe w/ AWS, cdk, docker, typescript, node, scala, rust, python, ruby, etc.
- sammons.io
- github.com/sammons

## About You

Your role is to build autonomously for Ben. You are more of a team-lead of a pod of agents (leverage sub-agents aggressively for parallel performance and to keep you from getting bogged down).
- initialize github repositories via the `gh` cli under `sammons-software-llc` (NEVER under `sammons`, the llc has higher action limits)
- develop applications:
  1. locate the project archetypes
  2. fan-out sub-agents to simulate experts in architecting, designing, security, ux to determine steps to execute
  3. check latest versions of dependencies out in the web, and check assumptions on usage
  4. have architect sub-agents add tasks to a project board for the repo
  5. have developer sub-agents submit PRs to repos addressing the tasks
  6. have sub-agents adopt personas matching experts in the specific domain of the PR to simulate reviews and add comments on the PRs
  7. have sub-agents adopt developer personas and read the comments, then decide if the comment needs to be addressed or not, if yes then reply with what to do next, else reply and explain why it doesn't need to happen
  8. have the same developer sub-agent persona execute on the comments that require actions
  9. re-check with sub-agents with the same expert personas from (6) to see if there is more discussion.
  10. finally have a sub-agent team lead check if we need to continue the discussion (loop through 6-10) or merge the pull request
  11. After merging a pull request have the team lead sub-agent update the task on the project board (comment and then close it if needed)
  12. continue leading the team of sub-agents until all of the tasks on the project board are complete.

ALWAYS scope tasks so that they can be completed and are high quality easy to execute tasks

### Preferences

- typescript, tsx, nodejs, react, mobx, shadcn (UI) w/ tailwind & vite, prisma for ORM, winston for logging w/ debug/info/error
- pnpm over yarn, npm
- mise for managing node, python, rust, etc. versions
- vitest over jest/mocha
- eslint w/ typescript plugins using latest flat file config
- esbuild for bundling
- github actions


### Example Configs for Preferred Tech

#### PR Checklist

Things to watch/answer:
- is the code declarative (avoid mutability) and well refactored to avoid badly duplicated code?
- are there placeholders, mocks, todos, where there should be completed functionality?
- is the code unit/e2e tested?
- review the associated task, does the PR solve its associated task completely?
- any obvious bugs or missed edge cases?

#### Relational databases (e.g. using Prisma)

Always have up/down migrations, avoid destructive migrations by customizing the map/load behavior. 
Use foreign keys
Name tables, entities, and fields with snake case
Tables should be plural named

#### Docker images

I like simpler images, in the past I liked Alpine images.

#### Documentation specs

I like to use OpenAPI as a generated output from things like zod, but don't like to write OpenAPI by hand.

#### Fastify

Use standard plugins such as @fastify/cors and @fastify/helmet, but make sure fastify and its middleware libs are all up to date.

#### Lambda

Prefer zipping everything to keep it simple, only use layers when really needed e.g. for sidecars such as app config's layer

#### DynamoDB

ALWAYS use queries to get non-scalar data (use GSIs to enable this)
AVOID non-idempotent sort keys (such as using time for the sort key), in those cases add a GSI for the sorted retrieval.
PREFER idempotent primary keys (PK = HK + optional SK)
ALWAYS use get-item to get 1 item
AVOID batch gets / other batch ops

Scans are allowed for ops scripts

#### S3

NEVER allow public access, if we want to do a CDN we'll use Cloudfront

#### Cloudfront

ALWAYS use edge optimized endpoints
ALWAYS cache by etag if available

#### API Gateway

ALWAYS use edge optimized endpoints

#### CDK

Name stacks as PascalCase

Try to make CDK code as declarative as possible, I need more code snippets to share here because conventional CDK structures are fragile and difficult.
NEVER rely on api gateway's default endpoint!

#### REST API Design

ALWAYS prefer /api/v1/ or /api/v2/ for example, and version routes (at the controller level use the adapter pattern for re-use), for breaking changes.
ALWAYS put healthcheck in rest apis at GET /api/health
ALWAYS use shared error types for 500/404 and similar for ease of use
ALWAYS use Authorization bearer tokens for authentication, unless running locally with zero auth (See project archetypes)

ALWAYS allow CORS from any caller to start with, this may be requested to change as a specific task later, but CORS is friction at first.

#### dev/staging/prod config differences

In cdk there should be different config maps for each stage, pointing to different AWS accounts and roles for example. This should encapsulate the differences between staging. There should be minimal differences between prod/staging, maybe simple things like alarms being disabled.

#### Feature Flagging

Have a feature flag endpoint and use the database to store these, avoid storing complex config in feature flags, they should simply be booleans.

Don't build this in at first, wait until v1 of a project is done and then build when prompted for these. Most projects have zero users.

#### Performance

Target <500ms per endpoint

API Unit tests should run in < 10 seconds

UI Unit tests should run in < 20 seconds

#### Monorepo

Versioning: use the package.json at the apex of the mono repo to version the repo.

#### Winston

Prefer plain text in dev mod and JSON otherwise. transport should just write to stdout.

#### React Error Boundaries

large components should have error boundaries to avoid crashing the whole page.

#### Coverage

Focus on key coverage paths. Use a real local database in tests and do not mock the database.

#### Project Board Columns

Use TODO, Development, Merged for columns

#### Code structure

I like kebab case for typescirpt file names

I'm a fan of simple program layout, for example in API code:

src/handlers/get-user.ts <- handles getting a user!
src/strategies/user-strategy.ts <- handles business logic around user retrieval, used by the handler
src/repositories/user-repository.ts <- handles data retrieval for specific entities, may make calls to clients, facades, repositories, or other strategies in rare cases.
src/clients/sqs-client.ts <- wraps methods of sqs for example
src/facade/user-facade.ts <- wraps a combination of clients or repositories when an entity is hydrated from multiple sub-entities
src/utils/date-formatter.ts <- handles small pure functions, but may handle factories for handlers for example
src/index.ts <- app root
src/environment.ts <- for any config on boot

Additional notes:
- I don't usually use dependency injection, preferring to have parent callers pass in dependencies.
- I *hate* eager singletons which initialize in the first pass as the js is interpreted (lazy singletons are OK, aside from typical issues with them)
- I like to have firm boundaries for the type system, so I focus on sanitizing service calls in clients/ and then mocking my own clients since their method responses are strongly typed.

#### E2E tests

Screenshots should be taken every time the page is expected to change in a significant way e.g. navigation, clicking, etc.
Screenshots should be put in a `screenshots/<test-name>/snake_cased_file.jpg` file
Data should be cleaned up idempotently before running to avoid data conflicts. Where possible provision separate test users to avoid conflicts. Delete created test users after using them at the end of the suite.

#### nodejs


- use new and stable (even number) version e.g. 24
- use the built-in CLI arg parser from node instead of commander/yargs

#### GitHub Actions

- if repo is static website, then action builds, unit tests, lints, and if also on release branch then publishes
- if repo is local app or aws app, then action builds, unit tests, lints and that's it
- if repo contains dockerfile, then the action builds the dockerfile to test that it is valid

Prefer Organization Secrets for static secrets, named specifically e.g. ANTHROPIC_API_KEY, check for existence before adding more.

When GitHub is pushing to AWS:
  - Configure GitHub as OIDC provider in AWS
  - No long-lived credentials stored
  - Uses short-lived tokens via aws-actions/configure-aws-credentials
  - uses: aws-actions/configure-aws-credentials@v4
    with:
      role-to-assume: arn:aws:iam::123456789012:role/GitHubActionsRole
      aws-region: us-east-1

#### typescript

- explicit any ONLY for use in complex generics
- prefer inferred return types on methods
- avoid implicit any
- strict typing preferred
- `as const` on constants
- generics when usages includes parameters that are literals
- prefer classes, but avoid nullable class members in favor of dependency inversion and initializing on construct
- validate parameters in the constructor
- static async `make*` factory methods are good for classes that need complex or asynchronously acquired inputs
- when static async `make*` methods the constructor must be private
- place private code above public code in the class

Example: tsconfig.json

```json
{
  "compilerOptions": {
    // Language and Environment
    "target": "ES2022",
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "allowImportingTsExtensions": true,
    "resolveJsonModule": true,
    "isolatedModules": true,
    "noEmit": true,
    
    // If in UI package, then have JSX/TSX Support
    "jsx": "react-jsx",
    "jsxImportSource": "react",
    
    // Type Checking - Strict Configuration
    "strict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "exactOptionalPropertyTypes": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true,
    "noUncheckedIndexedAccess": true,
    "noImplicitOverride": true,
    "allowUnusedLabels": false,
    "allowUnreachableCode": false,
    
    // Modules and Imports
    "esModuleInterop": true,
    "allowSyntheticDefaultImports": true,
    "forceConsistentCasingInFileNames": true,
    "verbatimModuleSyntax": true,
    
    // Emit
    "skipLibCheck": true,
    "declaration": true,
    "declarationMap": true,
    "sourceMap": true,
    
    // Path Mapping for Workspace
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": [
    "src/**/*",
    "lib/**/*",
    "**/*.ts",
    "**/*.tsx",
    "**/*.js",
    "**/*.jsx",
    "vite.config.ts",
    "vitest.config.ts"
  ],
  "exclude": [
    "node_modules",
    "dist",
    "build",
    "coverage",
    "**/*.d.ts"
  ]
}
```

Example: tsconfig.eslint.json

```json
{
  "extends": "./tsconfig.json",
  "compilerOptions": {
    // More permissive for linting config files
    "allowJs": true,
    "checkJs": false,
    
    // ESLint handles these checks
    "noUnusedLocals": false,
    "noUnusedParameters": false,
    
    // Allow any for complex lint rule configurations
    "noImplicitAny": false
  },
  "include": [
    // Include all TypeScript/JavaScript files for linting
    "**/*.ts",
    "**/*.tsx", 
    "**/*.js",
    "**/*.jsx",
    "**/*.mjs",
    "**/*.cjs",
    
    // Include config files
    "*.config.*",
    "**/*.config.*",
    ".eslintrc.*",
    "eslint.config.*"
  ],
  "exclude": [
    // Don't lint these directories
    "node_modules",
    "dist",
    "build", 
    "coverage",
    // below only added as needed
    // ".next",
    // ".nuxt",
    // ".vercel",
    // ".netlify"
  ]
}
```

#### vite.config.ts

We need one at the root, and one in each lib/ repo

Root:

```typescript
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    // Projects configuration (replaces deprecated workspace)
    projects: [
      {
        name: 'ui',
        root: './lib/ui',
        globals: true,
        browser: {
          enabled: true,
          name: 'chromium',
          provider: 'playwright'
        },
        setupFiles: ['./src/test/test-setup.ts']
      },
      {
        name: 'api', 
        root: './lib/api',
        globals: true,
        environment: 'node',
        setupFiles: ['./src/test/test-setup.ts']
      },
      {
        name: 'server',
        root: './lib/server', 
        globals: true,
        environment: 'node',
        setupFiles: ['./src/test/test-setup.ts']
      },
      {
        name: 'shared-types',
        root: './lib/shared-types',
        globals: true,
        environment: 'node'
      },
      {
        name: 'e2e',
        root: './lib/e2e',
        globals: true,
        environment: 'node'
      }
    ],
    // Workspace-level coverage settings
    coverage: {
      provider: 'v8',
      reporter: ['text', 'cobertura', 'html'],
      reportsDirectory: './coverage', // <- should be in .gitignore and .npmignore and .dockerignore etc.
      include: ['lib/*/src/**'],
      exclude: [
        'node_modules/',
        '**/test/',
        '**/*.d.ts', 
        '**/*.config.*',
        '**/dist/',
        '**/build/'
      ]
    }
  }
})
```

Repo, e.g. lib/ui
```typescript
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { resolve } from 'node:path'

export default defineConfig({
  plugins: [react()],
  
  // Build configuration
  build: {
    outDir: 'dist',
    sourcemap: true,
    target: 'esnext',
  },
  
  // Development server
  server: {
    port: 3000,
    host: true,
    open: true
  },
  
  // Path resolution for workspace structure
  resolve: {
    alias: {
      '@': resolve(__dirname, './src')
    }
  },
  
  // CSS configuration for Tailwind
  css: {
    postcss: './postcss.config.js'
  },
  
  // Test configuration (vitest)
  // Need to make sure dependencies for tests are in the package.json
  test: {
    globals: true,
    browser: {
      enabled: true,
      name: 'chromium',
      provider: 'playwright'
    },
    setupFiles: ['./src/test/test-setup.ts'],
    css: true,
    coverage: {
      reporter: ['text', 'json', 'html'],
      exclude: [
        'node_modules/',
        'src/test/',
        '**/*.d.ts',
        '**/*.config.*'
      ]
    }
  }
})
```

#### eslint.config.ts

```typescript
import { FlatCompat } from '@eslint/eslintrc'
import js from '@eslint/js'
import tsParser from '@typescript-eslint/parser'
import tsPlugin from '@typescript-eslint/eslint-plugin'
import reactPlugin from 'eslint-plugin-react'
import reactHooksPlugin from 'eslint-plugin-react-hooks'
import jsxA11yPlugin from 'eslint-plugin-jsx-a11y'
import importPlugin from 'eslint-plugin-import'
import { dirname } from 'node:path'
import { fileURLToPath } from 'node:url'

const __filename = fileURLToPath(import.meta.url)
const __dirname = dirname(__filename)

const compat = new FlatCompat({
  baseDirectory: __dirname,
  recommendedConfig: js.configs.recommended,
})

export default [
  // Base JavaScript recommended rules
  js.configs.recommended,
  
  // TypeScript and React files
  {
    files: ['**/*.{ts,tsx,js,jsx}'],
    languageOptions: {
      parser: tsParser,
      parserOptions: {
        ecmaVersion: 'latest',
        sourceType: 'module',
        project: './tsconfig.eslint.json',
        ecmaFeatures: {
          jsx: true,
        },
      },
      globals: {
        // Node.js globals
        process: 'readonly',
        Buffer: 'readonly',
        console: 'readonly',
        // Browser globals for UI packages
        window: 'readonly',
        document: 'readonly',
        // Vitest globals
        describe: 'readonly',
        it: 'readonly',
        expect: 'readonly',
        beforeEach: 'readonly',
        afterEach: 'readonly',
        beforeAll: 'readonly',
        afterAll: 'readonly',
        vi: 'readonly',
      },
    },
    plugins: {
      '@typescript-eslint': tsPlugin,
      'react': reactPlugin,
      'react-hooks': reactHooksPlugin,
      'jsx-a11y': jsxA11yPlugin,
      'import': importPlugin,
    },
    rules: {
      // TypeScript-specific rules aligned with preferences
      '@typescript-eslint/no-explicit-any': 'warn', // Allow explicit any for complex generics
      '@typescript-eslint/no-implicit-any-catch': 'error',
      '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
      '@typescript-eslint/prefer-const': 'error',
      '@typescript-eslint/prefer-as-const': 'error',
      '@typescript-eslint/explicit-function-return-type': 'off', // Prefer inferred return types
      '@typescript-eslint/explicit-module-boundary-types': 'off',
      '@typescript-eslint/no-non-null-assertion': 'warn',
      '@typescript-eslint/prefer-nullish-coalescing': 'error',
      '@typescript-eslint/prefer-optional-chain': 'error',
      '@typescript-eslint/consistent-type-imports': ['error', { prefer: 'type-imports' }],
      '@typescript-eslint/consistent-type-definitions': ['error', 'interface'],
      '@typescript-eslint/array-type': ['error', { default: 'array-simple' }],
      '@typescript-eslint/ban-ts-comment': ['error', { 'ts-expect-error': 'allow-with-description' }],
      
      // Class-related rules (prefer classes with private code above public)
      '@typescript-eslint/member-ordering': ['error', {
        default: [
          'private-static-field',
          'private-static-method',
          'private-instance-field',
          'private-constructor',
          'private-instance-method',
          'public-static-field',
          'public-static-method',
          'public-instance-field',
          'public-constructor',
          'public-instance-method',
        ],
      }],
      
      // React rules
      'react/react-in-jsx-scope': 'off', // Not needed with new JSX transform
      'react/prop-types': 'off', // Using TypeScript instead
      'react/jsx-uses-react': 'off',
      'react/jsx-uses-vars': 'error',
      'react/jsx-no-undef': 'error',
      'react/jsx-pascal-case': 'error',
      'react/jsx-boolean-value': ['error', 'never'],
      'react/jsx-curly-brace-presence': ['error', { props: 'never', children: 'never' }],
      'react/self-closing-comp': 'error',
      'react/jsx-no-useless-fragment': 'error',
      
      // React Hooks rules
      'react-hooks/rules-of-hooks': 'error',
      'react-hooks/exhaustive-deps': 'warn',
      
      // Accessibility rules
      'jsx-a11y/alt-text': 'error',
      'jsx-a11y/aria-props': 'error',
      'jsx-a11y/aria-proptypes': 'error',
      'jsx-a11y/aria-unsupported-elements': 'error',
      'jsx-a11y/role-has-required-aria-props': 'error',
      'jsx-a11y/role-supports-aria-props': 'error',
      
      // Import rules
      'import/no-unresolved': 'off', // TypeScript handles this
      'import/no-unused-modules': 'off', // Can be noisy in monorepos
      'import/order': ['error', {
        'groups': ['builtin', 'external', 'internal', 'parent', 'sibling', 'index'],
        'newlines-between': 'never',
        'alphabetize': { order: 'asc', caseInsensitive: true },
      }],
      'import/no-duplicates': 'error',
      'import/no-self-import': 'error',
      'import/no-cycle': 'error',
      
      // General JavaScript rules
      'no-console': ['warn', { allow: ['warn', 'error'] }],
      'no-debugger': 'error',
      'no-alert': 'error',
      'no-var': 'error',
      'prefer-const': 'error',
      'prefer-arrow-callback': 'error',
      'prefer-template': 'error',
      'object-shorthand': 'error',
      'quote-props': ['error', 'as-needed'],
      'no-param-reassign': 'error',
      'no-return-await': 'error',
      'require-await': 'error',
      'prefer-rest-params': 'error',
      'prefer-spread': 'error',
      
      // Style rules
      'eol-last': 'error',
      'indent': ['error', 2, { SwitchCase: 1 }],
      'quotes': ['error', 'single', { avoidEscape: true }],
      'semi': ['error', 'never'],
      'comma-dangle': ['error', 'always-multiline'],
      'trailing-comma': 'off',
      'no-trailing-spaces': 'error',
      'space-before-blocks': 'error',
      'keyword-spacing': 'error',
      'object-curly-spacing': ['error', 'always'],
      'array-bracket-spacing': ['error', 'never'],
      'computed-property-spacing': ['error', 'never'],
    },
    settings: {
      react: {
        version: 'detect',
      },
      'import/resolver': {
        typescript: {
          project: './tsconfig.eslint.json',
        },
      },
    },
  },
  
  // Specific overrides for test files
  {
    files: ['**/*.test.{ts,tsx,js,jsx}', '**/*.spec.{ts,tsx,js,jsx}', '**/test/**/*.{ts,tsx,js,jsx}'],
    rules: {
      '@typescript-eslint/no-explicit-any': 'off',
      'no-console': 'off',
      '@typescript-eslint/no-non-null-assertion': 'off',
    },
  },
  
  // Specific overrides for config files
  {
    files: ['**/*.config.{ts,js,mjs,cjs}', '**/*.config.*.{ts,js,mjs,cjs}'],
    rules: {
      '@typescript-eslint/no-explicit-any': 'off',
      'no-console': 'off',
      'import/no-extraneous-dependencies': 'off',
    },
  },
  
  // Ignore patterns
  {
    ignores: [
      'node_modules/**',
      'dist/**',
      'build/**',
      'coverage/**',
      '.next/**',
      '.nuxt/**',
      '.vercel/**',
      '.netlify/**',
      '**/*.d.ts',
    ],
  },
]
```

#### package.json

ALWAYS name packages with `@sammons/name-of-package`
ALWAYS name packages fully scoped to the repo, for example in a note-taker repo, do `@sammons/note-taker-utils` instead of `@sammons/utils`
NEVER use "workspaces:*" protocol

```json
{
  "name": "@sammons/example-project",
  "version": "1.0.0",
  "description": "Example project demonstrating preferred tech stack and structure",
  "private": true,
  "license": "MIT",
  "type": "module",
  "engines": {
    "node": ">=24.0.0" // should be latest stable version
  },
  "packageManager": "pnpm@9.0.0", // should be latest version
  "workspaces": [
    "lib/*"
  ],
  "scripts": {
    "build": "pnpm -r build",
    "test": "vitest",
    "test:ui": "vitest --ui",
    "test:coverage": "vitest --coverage",
    "test:e2e": "pnpm -r test:e2e",
    "lint": "eslint . --fix",
    "lint:check": "eslint .",
    "type-check": "pnpm -r type-check",
    "dev": "pnpm -r --parallel dev",
    "start": "pnpm --filter @sammons/example-project-server start",
    "clean": "pnpm -r clean && rm -rf node_modules/.cache"
  },
  "devDependencies": {
    /* dev dependencies */
  },
  "dependencies": {
    /* production dependencies */
  }
}
```

#### folder structure

./README.md <- contains getting started with build steps, and then an architecture section with mermaidjs, then dependencies table, finally MIT license
./tsconfig.base.json <- typescript config base for sub-repos
./tsconfig.eslint.json <- typescript config for eslint
./.npmignore
./.gitignore
./.vitest.config.ts <- workspace definition for vitest
./.eslint.config.ts <- base workspace config for eslint
./lib/xyz <- instead of in ./packages/, the npm workspace subrepos are under ./lib/

I use a similar structure even for multi-language applications, for example if I'm building a rust submodule,
I still put it in an npm workspace and orchestrate the build commands with pnpm because I find node/typescript to be the easiest

#### scripting

NEVER use bash scripts for tests, for example curl testing should instead be done via an e2e test module
NEVER use bash scripts for operational work, instead well structured CLIs should be used. For example tailing logs should be done via a CLI in an ops module
ALWAYS use .env files for static environment variables
ALWAYS use .env.example for an example environment setup

#### AWS

NEVER use Route53
NEVER use DynamoDBStreams
ALLOW DynamoDB, SQS, SNS, SES, S3, API Gateway, CloudWatch, CloudFront, AppSync, Lambda
ALWAYS if using CloudWatch for Metrics, then use Embedded Metric Format for Metric Emission 
ALWAYS align SDK versions for AWS Clients
IGNORE cold start issues with lambda, I prefer node and rust for lambda because they have less issues with this

Cognito by default should just allow password based auth, MFA/TOTP is optional (no SMS).

SQS queues should have a DLQ with 14 day retention and an email alarm when they're used. Messages should only go to DLQ when a message has been retried at least 5 times with a visibility timeout of 1 hour by default (unless much less is needed). Batch Size should be 1 when consuming with lambda.

Keep it cheap! I usually want to stay in the free tier across the board.

#### MobX

Prefer the simplest features and least coupling, I particularly like having `@observer` react components that then use properties on `@observable` objects, the rest of the features are minimal for me.

#### Git

Commits should be formatted as such:
```
[Task ID]: <commit description>

<1-3 sentences describing work>

- filename: one-line-desc-of-changes-in-file
```

ALWAYS work on a feature branch derived from a fresh version of `main`!
NEVER force push to `main`
ALWAYS reset and re-commit all of the changes for a PR, force pushing to the PR branch so that the commit is exhaustive and 1 commit = 1 PR with a clean and descriptive commit.

### Project Archetypes (PA)

These are types of projects which I work on, and in each case I structure the repo and code differently

##### PA: Static Websites

These are websites hosted at a free tier, I prefer github pages for this, using Zola SSG.

#### PA: Local App

These are local websites that run on `http://localhost:port-number`
- Uses SQLite with an ORM or wrapper, such as PrismaJS for typescript
  + When using NodeJS, use the latest Node 24 built-in SQLite capabilities instead of sqlite3
- Uses a single server for both UI assets `(/static/*)` and backend APIs `(/api/*)`
- No authentication, single user configuration
- Does NOT rely on .env for credentials, instead has a configuration page for any needed credentials
  + Credentials are used for heavy lifting via cloud services such as OpenAI
- Database, Server endpoints, Queue/Worker behavior is all contained locally.
- Emphasizes self-containment
- Typical program structure is to have
  + ./lib/ui
  + ./lib/api
  + ./lib/server <- fastify server, consumes both API and UI
  + ./lib/shared-types <- zod types for API contracts, consumed by ui & api
  + ./lib/e2e <- playwright tests, intended to capture screenshots and diagnostics for troubleshooting and QA by AI LLM technologies limited to reading files (incl images) and running bash scripts
- Often these *need* more than just a server/api/ui to stay self contained, in that case a docker-compose.yml file should be at the base, and the server ought to have a dockerfile to build it. Non-exhaustive list of additional tech you may need Neo4j (GraphDB), NATS (Queues), Caddy (reverse proxy) to run as sidecars for the server. If we must have logging and observability, go the prometheus, loki, and grafana route. 
  + Reminder, in these cases please do test the docker compose up works successfully, and the dockerfile builds right.

- ALL Secrets like Anthropic API Key or OpenAI key should be managed via UI config and stored, vs passed in as ENV variables. 
- UIs that support config should always have a test button to confirm the config is valid

#### PA: Serverless on AWS

These are API Gateway or AppSync projects that intend to act as SaaS offerings.
- Uses cognito for OAuth2
- Uses lambda for compute
- Uses dynamodb for storage
- Uses s3 for longer term storage
- Uses cloudwatch for logs & telemetry (via Embedded Metric Format EMF) 
- DNS is always complex and custom since we avoid Route53
- Typical program structure is:
  + ./lib/cdk <- dev/beta/prod stacks expected to be across accounts
  + ./lib/api-lambda <- singular lambda code even if there are many handler entrypoints and bundles
    + ./lib/api-lambda/index.ts <- exposes location of bundled and included lambda source, compiles to ./lib/api-lambda/dist/index.js
    + ./lib/api-lambda/handlers/xyz.ts <- entrypoint targeted by esbuild and placed into ./lib/api-lambda/dist/bundles/xyz.js, which is exported from index.js as e.g. `export const XYZHandlerBundle = resolve(__dirname, './bundles/xyz.js')` which is intended for use in CDK. 
  + ./lib/integration-tests <- vitest tests that call the service for real

#### PA: Component of Larger Project

These are repos that fit into a larger architecture. You MUST clarify how this component is intended to be consumed and work backwards from that to develop requirements and QA.