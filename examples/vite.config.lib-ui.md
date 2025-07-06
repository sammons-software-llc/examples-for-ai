# Vite Configuration - UI Library (vite.config.ts)

This is the vite configuration for a UI library package (e.g., lib/ui).

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