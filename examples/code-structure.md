=== CONTEXT ===
Code organization examples demonstrating Ben's preferred patterns and structures.
Reference these patterns when implementing new features.

=== API CODE STRUCTURE ===
Standard API Layout:
```
src/
├── handlers/           # HTTP request handlers
│   ├── get-user.ts
│   ├── create-user.ts
│   └── update-user.ts
├── strategies/         # Business logic layer
│   ├── user-strategy.ts
│   └── auth-strategy.ts
├── repositories/       # Data access layer
│   ├── user-repository.ts
│   └── session-repository.ts
├── clients/           # External service wrappers
│   ├── sqs-client.ts
│   ├── ses-client.ts
│   └── dynamodb-client.ts
├── facades/           # Complex data aggregation
│   └── user-profile-facade.ts
├── utils/             # Pure utility functions
│   ├── date-formatter.ts
│   └── validators.ts
├── index.ts           # Application entry
└── environment.ts     # Config management
```

=== HANDLER PATTERN ===
```typescript
// handlers/get-user.ts
import { FastifyRequest, FastifyReply } from 'fastify'
import { UserStrategy } from '../strategies/user-strategy'
import { GetUserSchema } from '@sammons/shared-types'

export async function getUserHandler(
  request: FastifyRequest<{ Params: { userId: string } }>,
  reply: FastifyReply
): Promise<void> {
  const { userId } = request.params
  
  try {
    const strategy = new UserStrategy()
    const user = await strategy.getUser(userId)
    
    if (!user) {
      return reply.status(404).send({
        error: 'User not found',
        code: 'USER_NOT_FOUND'
      })
    }
    
    return reply.status(200).send(user)
  } catch (error) {
    request.log.error({ error, userId }, 'Failed to get user')
    return reply.status(500).send({
      error: 'Internal server error',
      code: 'INTERNAL_ERROR'
    })
  }
}
```

=== STRATEGY PATTERN ===
```typescript
// strategies/user-strategy.ts
import { UserRepository } from '../repositories/user-repository'
import { SessionRepository } from '../repositories/session-repository'
import { User, UserWithSessions } from '@sammons/shared-types'

export class UserStrategy {
  private readonly userRepo: UserRepository
  private readonly sessionRepo: SessionRepository
  
  constructor(
    userRepo = new UserRepository(),
    sessionRepo = new SessionRepository()
  ) {
    this.userRepo = userRepo
    this.sessionRepo = sessionRepo
  }
  
  async getUser(userId: string): Promise<User | null> {
    return this.userRepo.findById(userId)
  }
  
  async getUserWithSessions(userId: string): Promise<UserWithSessions | null> {
    const [user, sessions] = await Promise.all([
      this.userRepo.findById(userId),
      this.sessionRepo.findByUserId(userId)
    ])
    
    if (!user) return null
    
    return {
      ...user,
      sessions
    }
  }
}
```

=== REPOSITORY PATTERN ===
```typescript
// repositories/user-repository.ts
import { DynamoDBClient } from '../clients/dynamodb-client'
import { User } from '@sammons/shared-types'

export class UserRepository {
  private readonly tableName = 'users'
  private readonly db: DynamoDBClient
  
  constructor(db = new DynamoDBClient()) {
    this.db = db
  }
  
  async findById(userId: string): Promise<User | null> {
    const result = await this.db.getItem({
      TableName: this.tableName,
      Key: { user_id: userId }
    })
    
    return result.Item ? this.mapToUser(result.Item) : null
  }
  
  async create(user: Omit<User, 'userId' | 'createdAt'>): Promise<User> {
    const newUser = {
      ...user,
      user_id: generateId(),
      created_at: new Date().toISOString()
    }
    
    await this.db.putItem({
      TableName: this.tableName,
      Item: newUser
    })
    
    return this.mapToUser(newUser)
  }
  
  private mapToUser(item: Record<string, any>): User {
    return {
      userId: item.user_id,
      email: item.email,
      name: item.name,
      createdAt: item.created_at
    }
  }
}
```

=== CLIENT PATTERN ===
```typescript
// clients/dynamodb-client.ts
import { DynamoDB } from '@aws-sdk/client-dynamodb'
import { DynamoDBDocument } from '@aws-sdk/lib-dynamodb'
import { logger } from '../utils/logger'

export class DynamoDBClient {
  private readonly client: DynamoDBDocument
  
  constructor() {
    const dynamodb = new DynamoDB({
      region: process.env.AWS_REGION || 'us-east-1'
    })
    
    this.client = DynamoDBDocument.from(dynamodb)
  }
  
  async getItem(params: any): Promise<any> {
    try {
      return await this.client.get(params)
    } catch (error) {
      logger.error({ error, params }, 'DynamoDB getItem failed')
      throw new Error('Database operation failed')
    }
  }
  
  async query(params: any): Promise<any> {
    try {
      return await this.client.query(params)
    } catch (error) {
      logger.error({ error, params }, 'DynamoDB query failed')
      throw new Error('Database operation failed')
    }
  }
}
```

=== MONOREPO STRUCTURE ===
Full Application Layout:
```
/
├── lib/
│   ├── ui/              # React frontend
│   │   ├── src/
│   │   │   ├── components/
│   │   │   ├── hooks/
│   │   │   ├── stores/    # MobX stores
│   │   │   └── pages/
│   │   └── package.json
│   ├── api/             # Business logic
│   │   ├── src/
│   │   │   └── [patterns above]
│   │   └── package.json
│   ├── server/          # Fastify server
│   │   ├── src/
│   │   │   ├── routes/
│   │   │   ├── plugins/
│   │   │   └── index.ts
│   │   └── package.json
│   ├── shared-types/    # Zod schemas
│   │   ├── src/
│   │   │   ├── user.ts
│   │   │   ├── api.ts
│   │   │   └── index.ts
│   │   └── package.json
│   └── e2e/            # Playwright tests
│       ├── tests/
│       ├── fixtures/
│       └── package.json
├── package.json         # Workspace root
├── pnpm-workspace.yaml
└── tsconfig.base.json

=== CLASS PATTERNS ===
Private Constructor with Factory:
```typescript
export class ConfigService {
  private static instance: ConfigService | null = null
  private readonly config: Config
  
  private constructor(config: Config) {
    this.validateConfig(config)
    this.config = config
  }
  
  static async create(): Promise<ConfigService> {
    if (!this.instance) {
      const config = await this.loadConfig()
      this.instance = new ConfigService(config)
    }
    return this.instance
  }
  
  private static async loadConfig(): Promise<Config> {
    // Load from secure source
  }
  
  private validateConfig(config: Config): void {
    if (!config.apiKey) {
      throw new Error('API key is required')
    }
  }
  
  get apiKey(): string {
    return this.config.apiKey
  }
}

=== ERROR HANDLING PATTERNS ===
Custom Error Classes:
```typescript
// utils/errors.ts
export class AppError extends Error {
  constructor(
    message: string,
    public readonly code: string,
    public readonly statusCode: number,
    public readonly details?: any
  ) {
    super(message)
    this.name = 'AppError'
    Error.captureStackTrace(this, this.constructor)
  }
}

export class ValidationError extends AppError {
  constructor(message: string, details?: any) {
    super(message, 'VALIDATION_ERROR', 400, details)
    this.name = 'ValidationError'
  }
}

export class NotFoundError extends AppError {
  constructor(resource: string, id: string) {
    super(`${resource} not found`, 'NOT_FOUND', 404, { resource, id })
    this.name = 'NotFoundError'
  }
}

export class UnauthorizedError extends AppError {
  constructor(message = 'Unauthorized') {
    super(message, 'UNAUTHORIZED', 401)
    this.name = 'UnauthorizedError'
  }
}

// Usage in handler
export async function getUserHandler(request: FastifyRequest, reply: FastifyReply) {
  try {
    const user = await userStrategy.getUser(request.params.userId)
    return reply.send(user)
  } catch (error) {
    if (error instanceof NotFoundError) {
      return reply.status(error.statusCode).send({
        error: error.message,
        code: error.code,
        details: error.details
      })
    }
    
    // Log unexpected errors
    request.log.error({ error }, 'Unexpected error')
    return reply.status(500).send({
      error: 'Internal server error',
      code: 'INTERNAL_ERROR'
    })
  }
}
```

=== DEPENDENCY INJECTION PATTERNS ===
Parent Caller Pattern:
```typescript
// No framework DI, parent passes dependencies
export class OrderService {
  constructor(
    private readonly orderRepo: OrderRepository,
    private readonly paymentClient: PaymentClient,
    private readonly emailService: EmailService
  ) {}
  
  async createOrder(orderData: CreateOrderDto): Promise<Order> {
    // Business logic using injected dependencies
    const order = await this.orderRepo.create(orderData)
    await this.paymentClient.processPayment(order)
    await this.emailService.sendOrderConfirmation(order)
    return order
  }
}

// In handler, parent creates and passes dependencies
export async function createOrderHandler(request: FastifyRequest, reply: FastifyReply) {
  const orderRepo = new OrderRepository()
  const paymentClient = new PaymentClient()
  const emailService = new EmailService()
  
  const orderService = new OrderService(
    orderRepo,
    paymentClient,
    emailService
  )
  
  const order = await orderService.createOrder(request.body)
  return reply.status(201).send(order)
}
```

=== ASYNC PATTERNS ===
Proper Promise Handling:
```typescript
// utils/async-utils.ts
export async function withRetry<T>(
  fn: () => Promise<T>,
  maxRetries = 3,
  delayMs = 1000
): Promise<T> {
  let lastError: Error
  
  for (let i = 0; i < maxRetries; i++) {
    try {
      return await fn()
    } catch (error) {
      lastError = error as Error
      if (i < maxRetries - 1) {
        await new Promise(resolve => setTimeout(resolve, delayMs * (i + 1)))
      }
    }
  }
  
  throw lastError!
}

export async function parallel<T>(
  tasks: Array<() => Promise<T>>,
  concurrency = 5
): Promise<T[]> {
  const results: T[] = []
  const executing: Promise<void>[] = []
  
  for (const task of tasks) {
    const promise = task().then(result => {
      results.push(result)
    })
    
    executing.push(promise)
    
    if (executing.length >= concurrency) {
      await Promise.race(executing)
      executing.splice(executing.findIndex(p => p === promise), 1)
    }
  }
  
  await Promise.all(executing)
  return results
}
```

=== REACT COMPONENT STRUCTURE ===
MobX Observable Pattern:
```typescript
// stores/user-store.ts
import { makeAutoObservable } from 'mobx'
import { UserRepository } from '../repositories/user-repository'

export class UserStore {
  users: User[] = []
  currentUser: User | null = null
  loading = false
  error: string | null = null
  
  constructor(private readonly userRepo: UserRepository) {
    makeAutoObservable(this)
  }
  
  async loadUsers() {
    this.loading = true
    this.error = null
    
    try {
      this.users = await this.userRepo.findAll()
    } catch (error) {
      this.error = error.message
    } finally {
      this.loading = false
    }
  }
  
  get sortedUsers() {
    return this.users.slice().sort((a, b) => 
      a.name.localeCompare(b.name)
    )
  }
}

// components/user-list.tsx
import { observer } from 'mobx-react-lite'
import { useUserStore } from '../hooks/use-stores'

export const UserList = observer(() => {
  const userStore = useUserStore()
  
  useEffect(() => {
    userStore.loadUsers()
  }, [])
  
  if (userStore.loading) return <Spinner />
  if (userStore.error) return <ErrorMessage error={userStore.error} />
  
  return (
    <ul>
      {userStore.sortedUsers.map(user => (
        <li key={user.id}>{user.name}</li>
      ))}
    </ul>
  )
})
```

=== DATABASE PATTERNS ===
Prisma with Transactions:
```typescript
// repositories/order-repository.ts
import { PrismaClient } from '@prisma/client'
import { Order, OrderItem } from '@sammons/shared-types'

export class OrderRepository {
  constructor(private readonly prisma = new PrismaClient()) {}
  
  async createWithItems(
    orderData: CreateOrderDto,
    items: CreateOrderItemDto[]
  ): Promise<Order> {
    return this.prisma.$transaction(async (tx) => {
      // Create order
      const order = await tx.order.create({
        data: {
          user_id: orderData.userId,
          total_amount: orderData.totalAmount,
          status: 'pending'
        }
      })
      
      // Create order items
      await tx.orderItem.createMany({
        data: items.map(item => ({
          order_id: order.id,
          product_id: item.productId,
          quantity: item.quantity,
          price: item.price
        }))
      })
      
      // Update inventory
      for (const item of items) {
        const updated = await tx.product.update({
          where: { id: item.productId },
          data: {
            inventory: {
              decrement: item.quantity
            }
          }
        })
        
        if (updated.inventory < 0) {
          throw new Error(`Insufficient inventory for product ${item.productId}`)
        }
      }
      
      return order
    })
  }
}
```

=== TESTING PATTERNS ===
Test Organization:
```typescript
// handlers/__tests__/create-user.test.ts
import { describe, it, expect, beforeEach, afterEach } from 'vitest'
import { build } from '../../test/app-builder'
import { PrismaClient } from '@prisma/client'

describe('POST /api/v1/users', () => {
  let app: FastifyInstance
  let prisma: PrismaClient
  
  beforeEach(async () => {
    prisma = new PrismaClient()
    app = await build({ prisma })
    await prisma.user.deleteMany() // Clean state
  })
  
  afterEach(async () => {
    await app.close()
    await prisma.$disconnect()
  })
  
  it('creates a new user with valid data', async () => {
    const userData = {
      email: 'test@example.com',
      name: 'Test User',
      password: 'SecurePass123!'
    }
    
    const response = await app.inject({
      method: 'POST',
      url: '/api/v1/users',
      payload: userData
    })
    
    expect(response.statusCode).toBe(201)
    
    const user = response.json()
    expect(user).toMatchObject({
      email: userData.email,
      name: userData.name,
      id: expect.any(String)
    })
    expect(user.password).toBeUndefined() // Should not expose password
    
    // Verify in database
    const dbUser = await prisma.user.findUnique({
      where: { email: userData.email }
    })
    expect(dbUser).toBeDefined()
    expect(dbUser.password).not.toBe(userData.password) // Should be hashed
  })
  
  it('validates email format', async () => {
    const response = await app.inject({
      method: 'POST',
      url: '/api/v1/users',
      payload: {
        email: 'invalid-email',
        name: 'Test User',
        password: 'SecurePass123!'
      }
    })
    
    expect(response.statusCode).toBe(400)
    expect(response.json()).toMatchObject({
      error: 'Validation error',
      code: 'VALIDATION_ERROR',
      details: expect.objectContaining({
        email: expect.any(String)
      })
    })
  })
})
```

=== ENVIRONMENT CONFIGURATION ===
Type-safe Environment:
```typescript
// environment.ts
import { z } from 'zod'

const envSchema = z.object({
  NODE_ENV: z.enum(['development', 'test', 'production']).default('development'),
  PORT: z.string().transform(Number).default('3000'),
  DATABASE_URL: z.string().url(),
  REDIS_URL: z.string().url().optional(),
  JWT_SECRET: z.string().min(32),
  AWS_REGION: z.string().default('us-east-1'),
  LOG_LEVEL: z.enum(['error', 'warn', 'info', 'debug']).default('info')
})

export type Env = z.infer<typeof envSchema>

export function loadEnv(): Env {
  const result = envSchema.safeParse(process.env)
  
  if (!result.success) {
    console.error('❌ Invalid environment variables:')
    console.error(result.error.flatten().fieldErrors)
    process.exit(1)
  }
  
  return result.data
}

export const env = loadEnv()
```

Remember: Clean architecture separates concerns, making code testable, maintainable, and scalable. Each layer should have a single responsibility.
```