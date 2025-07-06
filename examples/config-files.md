=== CONTEXT ===
Configuration file templates for consistent project setup across all repositories.
Copy these exactly, modifying only project-specific values.

=== TYPESCRIPT CONFIG ===
Base tsconfig.json:
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
    
    // If in UI package, add JSX Support
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
    
    // Path Mapping
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": [
    "src/**/*",
    "**/*.ts",
    "**/*.tsx"
  ],
  "exclude": [
    "node_modules",
    "dist",
    "build",
    "coverage"
  ]
}
```

=== VITE CONFIG ===
Root vite.config.ts:
```typescript
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
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
    coverage: {
      provider: 'v8',
      reporter: ['text', 'cobertura', 'html'],
      reportsDirectory: './coverage',
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

Package vite.config.ts (e.g., lib/ui):
```typescript
import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { resolve } from 'node:path'

export default defineConfig({
  plugins: [react()],
  
  build: {
    outDir: 'dist',
    sourcemap: true,
    target: 'esnext',
  },
  
  server: {
    port: 3000,
    host: true,
    open: true
  },
  
  resolve: {
    alias: {
      '@': resolve(__dirname, './src')
    }
  },
  
  css: {
    postcss: './postcss.config.js'
  },
  
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

=== ESLINT CONFIG ===
eslint.config.ts:
```typescript
import js from '@eslint/js'
import tsParser from '@typescript-eslint/parser'
import tsPlugin from '@typescript-eslint/eslint-plugin'
import reactPlugin from 'eslint-plugin-react'
import reactHooksPlugin from 'eslint-plugin-react-hooks'

export default [
  js.configs.recommended,
  {
    files: ['**/*.{ts,tsx,js,jsx}'],
    languageOptions: {
      parser: tsParser,
      parserOptions: {
        ecmaVersion: 'latest',
        sourceType: 'module',
        project: './tsconfig.eslint.json',
        ecmaFeatures: { jsx: true }
      },
      globals: {
        process: 'readonly',
        console: 'readonly',
        window: 'readonly',
        document: 'readonly',
        describe: 'readonly',
        it: 'readonly',
        expect: 'readonly'
      }
    },
    plugins: {
      '@typescript-eslint': tsPlugin,
      'react': reactPlugin,
      'react-hooks': reactHooksPlugin
    },
    rules: {
      '@typescript-eslint/no-explicit-any': 'warn',
      '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
      '@typescript-eslint/prefer-nullish-coalescing': 'error',
      '@typescript-eslint/consistent-type-imports': ['error', { prefer: 'type-imports' }],
      'react/react-in-jsx-scope': 'off',
      'react/prop-types': 'off',
      'react-hooks/rules-of-hooks': 'error',
      'react-hooks/exhaustive-deps': 'warn',
      'no-console': ['warn', { allow: ['warn', 'error'] }],
      'prefer-const': 'error',
      'quotes': ['error', 'single'],
      'semi': ['error', 'never']
    }
  },
  {
    ignores: ['node_modules/**', 'dist/**', 'build/**', 'coverage/**']
  }
]
```

=== PACKAGE.JSON ===
Root package.json:
```json
{
  "name": "@sammons/project-name",
  "version": "1.0.0",
  "description": "Project description",
  "private": true,
  "license": "MIT",
  "type": "module",
  "engines": {
    "node": ">=24.0.0"
  },
  "packageManager": "pnpm@9.0.0",
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
    "start": "pnpm --filter @sammons/project-name-server start",
    "clean": "pnpm -r clean && rm -rf node_modules/.cache"
  },
  "devDependencies": {
    "@eslint/js": "^9.0.0",
    "@types/node": "^20.0.0",
    "@typescript-eslint/eslint-plugin": "^7.0.0",
    "@typescript-eslint/parser": "^7.0.0",
    "@vitest/coverage-v8": "^1.0.0",
    "@vitest/ui": "^1.0.0",
    "eslint": "^9.0.0",
    "typescript": "^5.4.0",
    "vite": "^5.0.0",
    "vitest": "^1.0.0"
  }
}
```

Package package.json (e.g., lib/api):
```json
{
  "name": "@sammons/project-name-api",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "main": "./dist/index.js",
  "types": "./dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "dev": "tsc --watch",
    "test": "vitest",
    "type-check": "tsc --noEmit",
    "clean": "rm -rf dist coverage"
  },
  "dependencies": {
    "@sammons/project-name-shared-types": "workspace:*",
    "winston": "^3.0.0"
  },
  "devDependencies": {
    "@types/node": "^20.0.0"
  }
}
```

=== GITHUB ACTIONS ===
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

=== DOCKERFILE ===
For local apps with server:
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

=== ENVIRONMENT FILES ===
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
```

=== GITIGNORE ===
.gitignore:
```
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
```