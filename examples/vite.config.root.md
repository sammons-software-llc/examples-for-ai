# Vite Configuration - Root (vite.config.ts)

This is the root vite configuration for a monorepo workspace. It defines the test projects and coverage settings.

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