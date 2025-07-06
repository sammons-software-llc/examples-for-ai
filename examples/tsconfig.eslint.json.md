# TypeScript ESLint Configuration (tsconfig.eslint.json)

This configuration extends the base TypeScript config but is more permissive for linting configuration files.

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