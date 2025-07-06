# Package Configuration (package.json)

This is the root package.json for a monorepo project using pnpm workspaces.

```json
{
  "name": "@sammons/example-project",
  "version": "1.0.0",
  "description": "Example project demonstrating preferred tech stack and structure",
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
    "start": "pnpm --filter @sammons/example-project-server start",
    "clean": "pnpm -r clean && rm -rf node_modules/.cache"
  },
  "devDependencies": {
    "@eslint/eslintrc": "^3.0.0",
    "@eslint/js": "^9.0.0",
    "@typescript-eslint/eslint-plugin": "^8.0.0",
    "@typescript-eslint/parser": "^8.0.0",
    "@vitejs/plugin-react": "^4.0.0",
    "@vitest/coverage-v8": "^2.0.0",
    "@vitest/ui": "^2.0.0",
    "eslint": "^9.0.0",
    "eslint-plugin-import": "^2.29.0",
    "eslint-plugin-jsx-a11y": "^6.8.0",
    "eslint-plugin-react": "^7.34.0",
    "eslint-plugin-react-hooks": "^4.6.0",
    "playwright": "^1.48.0",
    "typescript": "^5.5.0",
    "vite": "^5.0.0",
    "vitest": "^2.0.0"
  },
  "dependencies": {
    "react": "^18.3.0",
    "react-dom": "^18.3.0"
  }
}
```

## Key Points

- **ALWAYS** name packages with `@sammons/name-of-package`
- **ALWAYS** name packages fully scoped to the repo (e.g., `@sammons/note-taker-utils` instead of `@sammons/utils`)
- **NEVER** use "workspaces:*" protocol
- Uses `pnpm` as the package manager with workspaces in `lib/*`
- Node 24+ required (latest stable version)
- Type module for ES modules
- Scripts use pnpm recursive commands (`-r`) for workspace operations