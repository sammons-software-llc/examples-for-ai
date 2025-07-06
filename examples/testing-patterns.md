# Testing Patterns

## Context
You are implementing comprehensive testing strategies following Ben's preferences for fast, reliable tests using Vitest, real databases (not mocks), and achieving meaningful coverage.

## Objective
Design and implement testing strategies that ensure code quality while maintaining fast feedback cycles and focusing on critical paths.

## Process

### === TESTING HIERARCHY ===

```
1. Unit Tests (60% of tests)
   ├── Pure functions
   ├── Business logic
   └── Component behavior

2. Integration Tests (30% of tests)
   ├── API endpoints
   ├── Database operations
   └── Service interactions

3. E2E Tests (10% of tests)
   ├── Critical user flows
   ├── Screenshot captures
   └── Cross-browser validation
```

### === DECISION TREE ===

```
IF testing_pure_functions:
    THEN: Use simple unit tests
    AND: Focus on edge cases
    OUTPUT: Fast, isolated tests

ELIF testing_api_endpoints:
    THEN: Use integration tests with real database
    AND: Test full request/response cycle
    OUTPUT: Realistic API validation

ELIF testing_ui_components:
    THEN: Use Vitest browser mode
    AND: Include accessibility tests
    OUTPUT: Component behavior validation

ELIF testing_user_flows:
    THEN: Use Playwright E2E
    AND: Capture screenshots at each step
    OUTPUT: Full flow validation

ELSE:
    THEN: Default to integration test
    AND: Use real dependencies
    OUTPUT: Pragmatic test coverage
```

## Testing Patterns by Type

### 1. Unit Tests - Business Logic

```typescript
// src/strategies/__tests__/user-strategy.test.ts
import { describe, it, expect, beforeEach } from 'vitest'
import { UserStrategy } from '../user-strategy'
import { UserRepository } from '../../repositories/user-repository'
import type { User } from '@sammons/shared-types'

describe('UserStrategy', () => {
  let strategy: UserStrategy
  let repository: UserRepository
  
  beforeEach(() => {
    repository = new UserRepository()
    strategy = new UserStrategy(repository)
  })
  
  describe('calculateUserScore', () => {
    it('calculates score based on activity metrics', () => {
      const user: User = {
        id: '123',
        posts: 10,
        comments: 20,
        likes: 50,
        joinedAt: new Date('2024-01-01')
      }
      
      const score = strategy.calculateUserScore(user)
      
      expect(score).toBe(95) // (10*3 + 20*2 + 50*0.5)
    })
    
    it('applies new user bonus for accounts < 30 days', () => {
      const newUser: User = {
        id: '124',
        posts: 1,
        comments: 0,
        likes: 0,
        joinedAt: new Date() // Today
      }
      
      const score = strategy.calculateUserScore(newUser)
      
      expect(score).toBe(13) // (1*3) + 10 bonus
    })
    
    it('handles edge case of negative metrics', () => {
      const user: User = {
        id: '125',
        posts: -5, // Data corruption scenario
        comments: 10,
        likes: 20,
        joinedAt: new Date('2024-01-01')
      }
      
      const score = strategy.calculateUserScore(user)
      
      expect(score).toBe(30) // Max(0, -15) + 20 + 10
    })
  })
})
```

### 2. Integration Tests - API Endpoints

```typescript
// src/handlers/__tests__/get-user.test.ts
import { describe, it, expect, beforeAll, afterAll, beforeEach } from 'vitest'
import { PrismaClient } from '@prisma/client'
import { createApp } from '../../app'
import type { FastifyInstance } from 'fastify'

describe('GET /api/users/:id', () => {
  let app: FastifyInstance
  let prisma: PrismaClient
  
  beforeAll(async () => {
    // Use real test database
    prisma = new PrismaClient({
      datasourceUrl: process.env.TEST_DATABASE_URL
    })
    
    app = await createApp({ prisma })
    await app.ready()
  })
  
  afterAll(async () => {
    await prisma.$disconnect()
    await app.close()
  })
  
  beforeEach(async () => {
    // Clean database before each test
    await prisma.$transaction([
      prisma.user.deleteMany(),
      prisma.post.deleteMany()
    ])
  })
  
  it('returns user with their posts', async () => {
    // Arrange
    const user = await prisma.user.create({
      data: {
        id: 'test-123',
        email: 'test@example.com',
        name: 'Test User',
        posts: {
          create: [
            { title: 'Post 1', content: 'Content 1' },
            { title: 'Post 2', content: 'Content 2' }
          ]
        }
      }
    })
    
    // Act
    const response = await app.inject({
      method: 'GET',
      url: `/api/users/${user.id}`,
      headers: {
        authorization: 'Bearer test-token'
      }
    })
    
    // Assert
    expect(response.statusCode).toBe(200)
    
    const body = response.json()
    expect(body).toMatchObject({
      id: 'test-123',
      email: 'test@example.com',
      name: 'Test User',
      posts: expect.arrayContaining([
        expect.objectContaining({ title: 'Post 1' }),
        expect.objectContaining({ title: 'Post 2' })
      ])
    })
  })
  
  it('returns 404 for non-existent user', async () => {
    const response = await app.inject({
      method: 'GET',
      url: '/api/users/non-existent',
      headers: {
        authorization: 'Bearer test-token'
      }
    })
    
    expect(response.statusCode).toBe(404)
    expect(response.json()).toMatchObject({
      error: 'USER_NOT_FOUND',
      message: 'User not found'
    })
  })
  
  it('validates authentication', async () => {
    const response = await app.inject({
      method: 'GET',
      url: '/api/users/test-123'
      // Missing auth header
    })
    
    expect(response.statusCode).toBe(401)
  })
})
```

### 3. Component Tests - React with Vitest Browser

```typescript
// src/components/__tests__/user-profile.test.tsx
import { describe, it, expect, vi } from 'vitest'
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { UserProfile } from '../user-profile'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'

describe('UserProfile', () => {
  const createWrapper = () => {
    const queryClient = new QueryClient({
      defaultOptions: {
        queries: { retry: false }
      }
    })
    
    return ({ children }: { children: React.ReactNode }) => (
      <QueryClientProvider client={queryClient}>
        {children}
      </QueryClientProvider>
    )
  }
  
  it('displays user information', async () => {
    const mockUser = {
      id: '123',
      name: 'John Doe',
      email: 'john@example.com',
      avatar: 'https://example.com/avatar.jpg'
    }
    
    // Mock API response
    global.fetch = vi.fn(() =>
      Promise.resolve({
        ok: true,
        json: () => Promise.resolve(mockUser)
      } as Response)
    )
    
    render(<UserProfile userId="123" />, { wrapper: createWrapper() })
    
    // Wait for data to load
    await waitFor(() => {
      expect(screen.getByText('John Doe')).toBeInTheDocument()
    })
    
    expect(screen.getByText('john@example.com')).toBeInTheDocument()
    expect(screen.getByRole('img', { name: 'John Doe' })).toHaveAttribute(
      'src',
      'https://example.com/avatar.jpg'
    )
  })
  
  it('handles edit mode interaction', async () => {
    const user = userEvent.setup()
    const mockUser = {
      id: '123',
      name: 'John Doe',
      email: 'john@example.com'
    }
    
    global.fetch = vi.fn(() =>
      Promise.resolve({
        ok: true,
        json: () => Promise.resolve(mockUser)
      } as Response)
    )
    
    render(<UserProfile userId="123" canEdit />, { wrapper: createWrapper() })
    
    await waitFor(() => {
      expect(screen.getByText('John Doe')).toBeInTheDocument()
    })
    
    // Click edit button
    await user.click(screen.getByRole('button', { name: 'Edit profile' }))
    
    // Should show form inputs
    expect(screen.getByLabelText('Name')).toHaveValue('John Doe')
    expect(screen.getByLabelText('Email')).toHaveValue('john@example.com')
    
    // Change name
    await user.clear(screen.getByLabelText('Name'))
    await user.type(screen.getByLabelText('Name'), 'Jane Doe')
    
    // Submit form
    await user.click(screen.getByRole('button', { name: 'Save' }))
    
    // Verify API call
    await waitFor(() => {
      expect(global.fetch).toHaveBeenCalledWith(
        '/api/users/123',
        expect.objectContaining({
          method: 'PATCH',
          body: JSON.stringify({ name: 'Jane Doe', email: 'john@example.com' })
        })
      )
    })
  })
  
  it('meets accessibility standards', async () => {
    const { container } = render(<UserProfile userId="123" />, { 
      wrapper: createWrapper() 
    })
    
    // Run axe accessibility tests
    const results = await axe(container)
    expect(results).toHaveNoViolations()
  })
})
```

### 4. E2E Tests - Critical User Flows

```typescript
// lib/e2e/tests/user-onboarding.spec.ts
import { test, expect } from '@playwright/test'
import { createTestUser, deleteTestUser } from '../helpers/test-users'

test.describe('User Onboarding Flow', () => {
  let testEmail: string
  
  test.beforeEach(async () => {
    testEmail = `test-${Date.now()}@example.com`
  })
  
  test.afterEach(async () => {
    await deleteTestUser(testEmail)
  })
  
  test('complete onboarding flow with screenshots', async ({ page, browserName }) => {
    // Navigate to signup
    await page.goto('http://localhost:3000/signup')
    await page.screenshot({ 
      path: `screenshots/onboarding/${browserName}/01_signup_page.jpg` 
    })
    
    // Fill signup form
    await page.fill('[name="email"]', testEmail)
    await page.fill('[name="password"]', 'SecurePass123!')
    await page.fill('[name="confirmPassword"]', 'SecurePass123!')
    await page.screenshot({ 
      path: `screenshots/onboarding/${browserName}/02_filled_form.jpg` 
    })
    
    // Submit and wait for redirect
    await page.click('button[type="submit"]')
    await page.waitForURL('**/welcome')
    await page.screenshot({ 
      path: `screenshots/onboarding/${browserName}/03_welcome_page.jpg` 
    })
    
    // Complete profile
    await page.fill('[name="displayName"]', 'Test User')
    await page.fill('[name="bio"]', 'I am a test user')
    await page.selectOption('[name="timezone"]', 'America/New_York')
    await page.screenshot({ 
      path: `screenshots/onboarding/${browserName}/04_profile_filled.jpg` 
    })
    
    // Upload avatar
    const [fileChooser] = await Promise.all([
      page.waitForEvent('filechooser'),
      page.click('button[aria-label="Upload avatar"]')
    ])
    await fileChooser.setFiles('test-fixtures/avatar.jpg')
    await page.screenshot({ 
      path: `screenshots/onboarding/${browserName}/05_avatar_uploaded.jpg` 
    })
    
    // Complete onboarding
    await page.click('button[text="Complete Setup"]')
    await page.waitForURL('**/dashboard')
    await page.screenshot({ 
      path: `screenshots/onboarding/${browserName}/06_dashboard.jpg` 
    })
    
    // Verify welcome message
    await expect(page.locator('h1')).toContainText('Welcome, Test User!')
    await expect(page.locator('[data-testid="onboarding-complete"]')).toBeVisible()
  })
  
  test('handles validation errors gracefully', async ({ page, browserName }) => {
    await page.goto('http://localhost:3000/signup')
    
    // Try to submit empty form
    await page.click('button[type="submit"]')
    await page.screenshot({ 
      path: `screenshots/onboarding/${browserName}/validation_errors.jpg` 
    })
    
    // Check error messages
    await expect(page.locator('text=Email is required')).toBeVisible()
    await expect(page.locator('text=Password is required')).toBeVisible()
    
    // Test weak password
    await page.fill('[name="email"]', testEmail)
    await page.fill('[name="password"]', '123')
    await page.fill('[name="confirmPassword"]', '123')
    await page.click('button[type="submit"]')
    
    await expect(page.locator('text=Password must be at least 8 characters')).toBeVisible()
  })
})
```

### 5. Performance Tests

```typescript
// src/__tests__/performance.test.ts
import { describe, it, expect } from 'vitest'
import { performance } from 'perf_hooks'
import { createApp } from '../app'

describe('Performance Benchmarks', () => {
  it('handles 100 concurrent requests under 500ms average', async () => {
    const app = await createApp()
    await app.ready()
    
    const requests = Array.from({ length: 100 }, async () => {
      const start = performance.now()
      await app.inject({
        method: 'GET',
        url: '/api/health'
      })
      return performance.now() - start
    })
    
    const times = await Promise.all(requests)
    const avgTime = times.reduce((a, b) => a + b, 0) / times.length
    
    expect(avgTime).toBeLessThan(500)
    await app.close()
  })
  
  it('processes large dataset efficiently', async () => {
    const largeArray = Array.from({ length: 10000 }, (_, i) => ({
      id: i,
      name: `User ${i}`,
      score: Math.random() * 100
    }))
    
    const start = performance.now()
    const top100 = largeArray
      .sort((a, b) => b.score - a.score)
      .slice(0, 100)
    const duration = performance.now() - start
    
    expect(duration).toBeLessThan(50) // Should complete in 50ms
    expect(top100).toHaveLength(100)
  })
})
```

## Test Configuration

### vitest.config.ts (Root)

```typescript
import { defineConfig } from 'vitest/config'
import { resolve } from 'node:path'

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    setupFiles: ['./src/test/setup.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html', 'cobertura'],
      exclude: [
        'node_modules/',
        'src/test/',
        '**/*.d.ts',
        '**/*.config.*',
        '**/dist/'
      ],
      thresholds: {
        lines: 80,
        functions: 80,
        branches: 70,
        statements: 80
      }
    },
    pool: 'forks', // Better isolation for integration tests
    poolOptions: {
      forks: {
        singleFork: true
      }
    }
  },
  resolve: {
    alias: {
      '@': resolve(__dirname, './src')
    }
  }
})
```

### Test Setup File

```typescript
// src/test/setup.ts
import { beforeAll, afterAll, beforeEach } from 'vitest'
import { PrismaClient } from '@prisma/client'

let prisma: PrismaClient

beforeAll(async () => {
  // Setup test database
  process.env.DATABASE_URL = process.env.TEST_DATABASE_URL
  prisma = new PrismaClient()
  
  // Run migrations
  await prisma.$executeRaw`CREATE TABLE IF NOT EXISTS users (...)`
})

beforeEach(async () => {
  // Clean tables between tests
  const tables = await prisma.$queryRaw<Array<{ tablename: string }>>`
    SELECT tablename FROM pg_tables 
    WHERE schemaname = 'public'
  `
  
  for (const { tablename } of tables) {
    if (tablename !== '_prisma_migrations') {
      await prisma.$executeRawUnsafe(`TRUNCATE TABLE "${tablename}" CASCADE`)
    }
  }
})

afterAll(async () => {
  await prisma.$disconnect()
})

// Global test utilities
global.createAuthToken = (userId: string) => {
  return `test-token-${userId}`
}

global.waitForCondition = async (
  condition: () => boolean | Promise<boolean>,
  timeout = 5000
) => {
  const start = Date.now()
  while (Date.now() - start < timeout) {
    if (await condition()) return true
    await new Promise(resolve => setTimeout(resolve, 100))
  }
  throw new Error('Condition not met within timeout')
}
```

## Testing Best Practices

### ✅ DO
- Use real databases for integration tests
- Focus on critical user paths for E2E
- Capture screenshots in E2E tests
- Clean up test data after each test
- Use meaningful test descriptions
- Test error cases and edge conditions
- Run tests in parallel when possible
- Use data-testid for E2E selectors

### ⛔ DON'T
- Don't mock the database in integration tests
- Don't test implementation details
- Don't ignore flaky tests
- Don't skip accessibility tests
- Don't use arbitrary waits in E2E tests
- Don't test third-party libraries
- Don't aim for 100% coverage blindly

## Test Organization

```
src/
├── strategies/
│   └── __tests__/
│       └── user-strategy.test.ts
├── handlers/
│   └── __tests__/
│       └── get-user.test.ts
├── components/
│   └── __tests__/
│       └── user-profile.test.tsx
└── test/
    ├── setup.ts
    ├── fixtures/
    └── helpers/

lib/e2e/
├── tests/
│   ├── onboarding.spec.ts
│   └── checkout.spec.ts
├── helpers/
└── screenshots/
```

## Performance Targets

| Test Type | Target Time | Max Time |
|-----------|-------------|----------|
| Unit tests | < 10ms | 50ms |
| Integration tests | < 100ms | 500ms |
| E2E single test | < 5s | 10s |
| Full test suite | < 10s | 20s |
| E2E full suite | < 2min | 5min |

## Coverage Guidelines

Focus coverage on:
1. Business logic (90%+)
2. API handlers (85%+)
3. Critical components (80%+)
4. Utility functions (95%+)

Acceptable lower coverage:
1. UI components (70%+)
2. Configuration files (50%+)
3. Error handling (60%+)