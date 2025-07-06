# Package Management Configuration

Package.json configurations for different project types.

## Root Workspace Package.json

For monorepo root:

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

## API/Server Package.json

For Node.js services:

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

## UI Package.json

For React UI packages:

```json
{
  "name": "@sammons/project-name-ui",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "main": "./dist/index.js",
  "types": "./dist/index.d.ts",
  "scripts": {
    "build": "vite build",
    "dev": "vite",
    "preview": "vite preview",
    "test": "vitest",
    "test:ui": "vitest --ui",
    "type-check": "tsc --noEmit",
    "clean": "rm -rf dist coverage"
  },
  "dependencies": {
    "@sammons/project-name-shared-types": "workspace:*",
    "react": "^18.0.0",
    "react-dom": "^18.0.0"
  },
  "devDependencies": {
    "@types/react": "^18.0.0",
    "@types/react-dom": "^18.0.0",
    "@vitejs/plugin-react": "^4.0.0",
    "vite": "^5.0.0"
  }
}
```

## Library Package.json

For publishable libraries:

```json
{
  "name": "@sammons/library-name",
  "version": "1.0.0",
  "description": "Library description",
  "license": "MIT",
  "type": "module",
  "main": "./dist/index.cjs",
  "module": "./dist/index.js",
  "types": "./dist/index.d.ts",
  "exports": {
    ".": {
      "import": "./dist/index.js",
      "require": "./dist/index.cjs",
      "types": "./dist/index.d.ts"
    }
  },
  "files": [
    "dist",
    "README.md",
    "CHANGELOG.md"
  ],
  "scripts": {
    "build": "vite build",
    "dev": "vite build --watch",
    "test": "vitest",
    "type-check": "tsc --noEmit",
    "clean": "rm -rf dist coverage",
    "prepublishOnly": "pnpm build"
  },
  "keywords": [
    "typescript",
    "library"
  ],
  "repository": {
    "type": "git",
    "url": "git+https://github.com/sammons-software-llc/library-name.git"
  },
  "bugs": {
    "url": "https://github.com/sammons-software-llc/library-name/issues"
  },
  "homepage": "https://github.com/sammons-software-llc/library-name#readme",
  "peerDependencies": {
    "react": ">=18.0.0",
    "react-dom": ">=18.0.0"
  },
  "devDependencies": {
    "@types/react": "^18.0.0",
    "@types/react-dom": "^18.0.0",
    "react": "^18.0.0",
    "react-dom": "^18.0.0",
    "vite": "^5.0.0",
    "vite-plugin-dts": "^3.0.0"
  }
}
```

## E2E Testing Package.json

For end-to-end testing:

```json
{
  "name": "@sammons/project-name-e2e",
  "version": "1.0.0",
  "private": true,
  "type": "module",
  "scripts": {
    "test": "playwright test",
    "test:headed": "playwright test --headed",
    "test:ui": "playwright test --ui",
    "test:debug": "playwright test --debug",
    "test:report": "playwright show-report",
    "install-deps": "playwright install",
    "clean": "rm -rf test-results playwright-report coverage"
  },
  "dependencies": {
    "@playwright/test": "^1.40.0"
  },
  "devDependencies": {
    "@types/node": "^20.0.0"
  }
}
```

## CLI Tool Package.json

For command-line tools:

```json
{
  "name": "@sammons/cli-tool",
  "version": "1.0.0",
  "description": "CLI tool description",
  "license": "MIT",
  "type": "module",
  "bin": {
    "tool-name": "./dist/cli.js"
  },
  "main": "./dist/index.js",
  "types": "./dist/index.d.ts",
  "scripts": {
    "build": "tsc",
    "dev": "tsc --watch",
    "test": "vitest",
    "type-check": "tsc --noEmit",
    "clean": "rm -rf dist coverage",
    "prepublishOnly": "pnpm build"
  },
  "dependencies": {
    "commander": "^11.0.0",
    "chalk": "^5.0.0",
    "ora": "^7.0.0"
  },
  "devDependencies": {
    "@types/node": "^20.0.0",
    "typescript": "^5.4.0"
  },
  "engines": {
    "node": ">=18.0.0"
  }
}
```

## PNPM Workspace Configuration

pnpm-workspace.yaml:

```yaml
packages:
  - 'lib/*'
  - 'apps/*'
  - 'tools/*'
```

## NPM Configuration

.npmrc for consistent behavior:

```
engine-strict=true
auto-install-peers=true
node-linker=isolated
prefer-workspace-packages=true
save-exact=true
```

## Package.json Scripts Patterns

### Common script patterns:

```json
{
  "scripts": {
    // Development
    "dev": "vite",
    "dev:api": "tsx watch src/index.ts",
    "dev:debug": "node --inspect src/index.js",
    
    // Building
    "build": "vite build",
    "build:lib": "vite build --config vite.config.lib.ts",
    "build:watch": "vite build --watch",
    "build:analyze": "vite build --analyze",
    
    // Testing
    "test": "vitest",
    "test:run": "vitest run",
    "test:coverage": "vitest --coverage",
    "test:ui": "vitest --ui",
    "test:e2e": "playwright test",
    "test:e2e:headed": "playwright test --headed",
    
    // Quality
    "lint": "eslint . --fix",
    "lint:check": "eslint .",
    "format": "prettier --write .",
    "format:check": "prettier --check .",
    "type-check": "tsc --noEmit",
    
    // Cleanup
    "clean": "rm -rf dist coverage .turbo",
    "clean:deps": "rm -rf node_modules",
    "clean:all": "pnpm clean && pnpm clean:deps",
    
    // Release
    "version": "changeset version",
    "release": "changeset publish",
    "prepublishOnly": "pnpm build && pnpm test:run"
  }
}
```

## Version Management

Using Changesets for version management:

```json
{
  "devDependencies": {
    "@changesets/cli": "^2.0.0"
  },
  "scripts": {
    "changeset": "changeset",
    "version-packages": "changeset version",
    "release": "pnpm build && changeset publish"
  }
}
```

## Dependencies Best Practices

### Dependency categories:
- **dependencies**: Runtime requirements
- **devDependencies**: Build/development tools
- **peerDependencies**: Expected to be provided by consumer
- **optionalDependencies**: Optional features

### Version ranges:
- `^1.0.0`: Compatible version (recommended)
- `~1.0.0`: Patch updates only
- `1.0.0`: Exact version (for critical deps)
- `>=1.0.0 <2.0.0`: Range specification

### Workspace dependencies:
- `workspace:*`: Latest workspace version
- `workspace:^1.0.0`: Specific workspace version
- `workspace:~`: Development workspace version