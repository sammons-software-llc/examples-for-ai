# ESLint Configuration (eslint.config.ts)

This is the flat ESLint configuration for TypeScript and React projects.

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