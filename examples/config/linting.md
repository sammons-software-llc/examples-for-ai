# Linting Configuration

ESLint and code quality tool configurations.

## ESLint Configuration (eslint.config.ts)

Modern flat config for TypeScript and React projects:

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

## Node.js-specific ESLint Config

For server/API packages:

```typescript
import js from '@eslint/js'
import tsParser from '@typescript-eslint/parser'
import tsPlugin from '@typescript-eslint/eslint-plugin'

export default [
  js.configs.recommended,
  {
    files: ['**/*.{ts,js}'],
    languageOptions: {
      parser: tsParser,
      parserOptions: {
        ecmaVersion: 'latest',
        sourceType: 'module',
        project: './tsconfig.eslint.json'
      },
      globals: {
        process: 'readonly',
        console: 'readonly',
        Buffer: 'readonly',
        __dirname: 'readonly',
        __filename: 'readonly',
        describe: 'readonly',
        it: 'readonly',
        expect: 'readonly'
      }
    },
    plugins: {
      '@typescript-eslint': tsPlugin
    },
    rules: {
      '@typescript-eslint/no-explicit-any': 'warn',
      '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
      '@typescript-eslint/prefer-nullish-coalescing': 'error',
      '@typescript-eslint/consistent-type-imports': ['error', { prefer: 'type-imports' }],
      'no-console': 'off', // Allow console in Node.js
      'prefer-const': 'error',
      'quotes': ['error', 'single'],
      'semi': ['error', 'never']
    }
  },
  {
    ignores: ['node_modules/**', 'dist/**', 'coverage/**']
  }
]
```

## Prettier Configuration

.prettierrc for code formatting:

```json
{
  "semi": false,
  "singleQuote": true,
  "tabWidth": 2,
  "trailingComma": "es5",
  "printWidth": 80,
  "arrowParens": "avoid",
  "endOfLine": "lf",
  "bracketSpacing": true,
  "bracketSameLine": false,
  "quoteProps": "as-needed"
}
```

## EditorConfig

.editorconfig for consistent formatting:

```ini
root = true

[*]
charset = utf-8
end_of_line = lf
indent_style = space
indent_size = 2
insert_final_newline = true
trim_trailing_whitespace = true

[*.md]
trim_trailing_whitespace = false

[*.{yml,yaml}]
indent_size = 2

[Makefile]
indent_style = tab
```

## Stylelint Configuration

For CSS/SCSS linting:

```json
{
  "extends": [
    "stylelint-config-standard",
    "stylelint-config-recess-order"
  ],
  "plugins": [
    "stylelint-order"
  ],
  "rules": {
    "declaration-empty-line-before": "never",
    "rule-empty-line-before": [
      "always",
      {
        "except": ["first-nested"],
        "ignore": ["after-comment"]
      }
    ],
    "selector-class-pattern": "^[a-z][a-zA-Z0-9]*$",
    "property-no-vendor-prefix": null,
    "value-no-vendor-prefix": null
  },
  "ignoreFiles": [
    "dist/**/*",
    "coverage/**/*",
    "node_modules/**/*"
  ]
}
```

## Husky Pre-commit Hooks

.husky/pre-commit:

```bash
#!/usr/bin/env sh
. "$(dirname -- "$0")/_/husky.sh"

pnpm lint:check
pnpm type-check
pnpm test:unit
```

## Lint-staged Configuration

package.json configuration:

```json
{
  "lint-staged": {
    "*.{ts,tsx,js,jsx}": [
      "eslint --fix",
      "prettier --write"
    ],
    "*.{css,scss}": [
      "stylelint --fix",
      "prettier --write"
    ],
    "*.{md,json,yaml,yml}": [
      "prettier --write"
    ]
  }
}
```

## Custom ESLint Rules

For project-specific patterns:

```typescript
// eslint-rules/no-direct-api-import.js
module.exports = {
  meta: {
    type: 'problem',
    docs: {
      description: 'Disallow direct API imports',
      category: 'Best Practices'
    },
    schema: []
  },
  create(context) {
    return {
      ImportDeclaration(node) {
        if (node.source.value.includes('/api/')) {
          context.report({
            node,
            message: 'Use API hooks instead of direct imports'
          })
        }
      }
    }
  }
}
```

## TypeScript-specific Rules

Additional rules for strict TypeScript:

```typescript
{
  rules: {
    // Require explicit return types
    '@typescript-eslint/explicit-function-return-type': 'error',
    
    // Require explicit member accessibility
    '@typescript-eslint/explicit-member-accessibility': 'error',
    
    // Prefer interfaces over type aliases
    '@typescript-eslint/consistent-type-definitions': ['error', 'interface'],
    
    // Require consistent generic naming
    '@typescript-eslint/naming-convention': [
      'error',
      {
        selector: 'typeParameter',
        format: ['PascalCase'],
        prefix: ['T']
      }
    ],
    
    // Prevent any usage
    '@typescript-eslint/no-explicit-any': 'error',
    
    // Require null checks
    '@typescript-eslint/prefer-optional-chain': 'error',
    '@typescript-eslint/prefer-nullish-coalescing': 'error'
  }
}
```

## Performance Rules

For large codebases:

```typescript
{
  rules: {
    // Prevent excessive complexity
    'complexity': ['error', 10],
    'max-depth': ['error', 4],
    'max-lines-per-function': ['error', 50],
    'max-params': ['error', 4],
    
    // React performance
    'react-hooks/exhaustive-deps': 'error',
    'react/jsx-no-bind': 'error',
    'react/jsx-no-constructed-context-values': 'error'
  }
}
```

## Security Rules

Additional security-focused linting:

```typescript
{
  plugins: ['security'],
  extends: ['plugin:security/recommended'],
  rules: {
    'security/detect-object-injection': 'error',
    'security/detect-non-literal-regexp': 'error',
    'security/detect-unsafe-regex': 'error',
    'security/detect-buffer-noassert': 'error',
    'security/detect-child-process': 'warn',
    'security/detect-disable-mustache-escape': 'error',
    'security/detect-eval-with-expression': 'error',
    'security/detect-no-csrf-before-method-override': 'error',
    'security/detect-pseudoRandomBytes': 'error'
  }
}
```