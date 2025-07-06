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
```