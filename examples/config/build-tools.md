# Build Tools Configuration

Configuration files for Vite, build tools, and development servers.

## Root Vite Config (vite.config.ts)

For workspace root with multiple test projects:

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

## UI Package Vite Config

For React UI packages (lib/ui/vite.config.ts):

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

## Library Build Config

For libraries that need to be published:

```typescript
import { defineConfig } from 'vite'
import { resolve } from 'node:path'
import dts from 'vite-plugin-dts'

export default defineConfig({
  plugins: [
    dts({
      include: ['src/**/*'],
      exclude: ['src/**/*.test.ts', 'src/**/*.stories.ts']
    })
  ],
  
  build: {
    lib: {
      entry: resolve(__dirname, 'src/index.ts'),
      name: 'LibraryName',
      fileName: (format) => `index.${format}.js`,
      formats: ['es', 'cjs']
    },
    rollupOptions: {
      external: ['react', 'react-dom'],
      output: {
        globals: {
          react: 'React',
          'react-dom': 'ReactDOM'
        }
      }
    },
    sourcemap: true,
    target: 'esnext'
  }
})
```

## Node.js Service Config

For API/server packages:

```typescript
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    setupFiles: ['./src/test/test-setup.ts']
  },
  
  build: {
    target: 'node18',
    ssr: true,
    outDir: 'dist',
    sourcemap: true
  }
})
```

## PostCSS Configuration

postcss.config.js for styling:

```javascript
export default {
  plugins: {
    'tailwindcss': {},
    'autoprefixer': {},
    'cssnano': {
      preset: 'default'
    }
  }
}
```

## Tailwind Configuration

tailwind.config.js:

```javascript
/** @type {import('tailwindcss').Config} */
export default {
  content: [
    './src/**/*.{js,ts,jsx,tsx,html}',
    './index.html'
  ],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#eff6ff',
          500: '#3b82f6',
          900: '#1e3a8a'
        }
      }
    }
  },
  plugins: [
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography')
  ]
}
```

## Rollup Configuration

For advanced build scenarios:

```javascript
import { defineConfig } from 'rollup'
import typescript from '@rollup/plugin-typescript'
import resolve from '@rollup/plugin-node-resolve'
import commonjs from '@rollup/plugin-commonjs'
import terser from '@rollup/plugin-terser'

export default defineConfig({
  input: 'src/index.ts',
  output: [
    {
      file: 'dist/index.cjs',
      format: 'cjs',
      sourcemap: true
    },
    {
      file: 'dist/index.esm.js',
      format: 'esm',
      sourcemap: true
    }
  ],
  plugins: [
    resolve(),
    commonjs(),
    typescript({
      tsconfig: './tsconfig.build.json'
    }),
    terser()
  ],
  external: ['react', 'react-dom']
})
```

## Vitest Configuration Options

Advanced testing configuration:

```typescript
import { defineConfig } from 'vitest/config'

export default defineConfig({
  test: {
    globals: true,
    environment: 'jsdom', // or 'node', 'happy-dom'
    setupFiles: ['./src/test/setup.ts'],
    
    // Coverage configuration
    coverage: {
      provider: 'v8', // or 'c8', 'istanbul'
      reporter: ['text', 'json', 'html'],
      reportsDirectory: './coverage',
      thresholds: {
        global: {
          branches: 80,
          functions: 80,
          lines: 80,
          statements: 80
        }
      }
    },
    
    // Browser testing
    browser: {
      enabled: true,
      name: 'chromium',
      provider: 'playwright',
      headless: true
    },
    
    // Performance
    maxConcurrency: 4,
    minThreads: 1,
    maxThreads: 4,
    
    // Timeouts
    testTimeout: 10000,
    hookTimeout: 10000
  }
})
```

## Webpack Alternative (if needed)

Basic webpack.config.js for special cases:

```javascript
const path = require('path')

module.exports = {
  entry: './src/index.ts',
  output: {
    path: path.resolve(__dirname, 'dist'),
    filename: 'bundle.js',
    library: 'LibraryName',
    libraryTarget: 'umd'
  },
  resolve: {
    extensions: ['.ts', '.tsx', '.js', '.jsx']
  },
  module: {
    rules: [
      {
        test: /\.tsx?$/,
        use: 'ts-loader',
        exclude: /node_modules/
      }
    ]
  },
  externals: {
    react: 'React',
    'react-dom': 'ReactDOM'
  }
}
```