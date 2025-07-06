=== CONTEXT ===
GraphQL API patterns using Zeus for type-safe client generation.
Provides end-to-end type safety without manual type definitions.

=== OBJECTIVE ===
Implement GraphQL APIs with automatic type generation and optimal DX.
Success metrics:
□ 100% type safety from schema to client
□ Zero manual type duplication
□ <200ms query response time
□ Automatic query validation
□ Efficient data fetching

=== TECHNICAL STACK ===
Server:
- Apollo Server (schema-first)
- GraphQL Yoga (alternative)
- DataLoader for N+1 prevention
- GraphQL Shield for authorization

Client:
- Zeus for TypeScript client generation
- React Query for caching
- GraphQL Code Generator for operations

=== SERVER IMPLEMENTATION ===
Schema Definition:
```graphql
# schema.graphql
type User {
  id: ID!
  email: String!
  name: String!
  posts: [Post!]!
  createdAt: DateTime!
}

type Post {
  id: ID!
  title: String!
  content: String!
  author: User!
  published: Boolean!
}

type Query {
  user(id: ID!): User
  users(limit: Int = 10, offset: Int = 0): [User!]!
  post(id: ID!): Post
}

type Mutation {
  createUser(input: CreateUserInput!): User!
  updateUser(id: ID!, input: UpdateUserInput!): User!
  createPost(input: CreatePostInput!): Post!
}

input CreateUserInput {
  email: String!
  name: String!
}
```

Apollo Server Setup:
```typescript
// server/graphql-server.ts
import { ApolloServer } from '@apollo/server'
import { expressMiddleware } from '@apollo/server/express4'
import { makeExecutableSchema } from '@graphql-tools/schema'
import { applyMiddleware } from 'graphql-middleware'
import { shield } from 'graphql-shield'
import DataLoader from 'dataloader'

// Type-safe resolvers
import type { Resolvers } from './generated/graphql'

const resolvers: Resolvers = {
  Query: {
    user: async (_, { id }, { dataSources }) => {
      return dataSources.users.getById(id)
    },
    users: async (_, { limit, offset }, { dataSources }) => {
      return dataSources.users.getMany({ limit, offset })
    }
  },
  Mutation: {
    createUser: async (_, { input }, { dataSources }) => {
      return dataSources.users.create(input)
    }
  },
  User: {
    posts: async (user, _, { loaders }) => {
      return loaders.postsByUser.load(user.id)
    }
  }
}

// DataLoader setup
function createLoaders() {
  return {
    postsByUser: new DataLoader<string, Post[]>(async (userIds) => {
      const posts = await db.posts.findMany({
        where: { authorId: { in: userIds } }
      })
      
      // Group by user
      const postsByUser = userIds.map(id => 
        posts.filter(post => post.authorId === id)
      )
      
      return postsByUser
    })
  }
}

// Authorization rules
const permissions = shield({
  Query: {
    '*': allow,
    user: isAuthenticated
  },
  Mutation: {
    '*': isAuthenticated,
    createUser: allow
  }
})

// Create schema with middleware
const schema = applyMiddleware(
  makeExecutableSchema({ typeDefs, resolvers }),
  permissions
)

// Apollo server
export const apolloServer = new ApolloServer({
  schema,
  csrfPrevention: true,
  cache: 'bounded'
})
```

Integration with Fastify:
```typescript
// server/app.ts
import Fastify from 'fastify'
import { apolloServer } from './graphql-server'

const app = Fastify()

await apolloServer.start()

app.register(async function (fastify) {
  fastify.route({
    url: '/graphql',
    method: ['GET', 'POST', 'OPTIONS'],
    handler: async (req, reply) => {
      const httpHandler = expressMiddleware(apolloServer, {
        context: async ({ req }) => ({
          user: await getUserFromToken(req.headers.authorization),
          dataSources: createDataSources(),
          loaders: createLoaders()
        })
      })
      
      return httpHandler(req, reply)
    }
  })
})
```

=== CLIENT IMPLEMENTATION ===
Zeus Client Generation:
```bash
# Generate from running server
npx zeus http://localhost:4000/graphql ./src/generated

# Or from schema file
npx zeus schema.graphql ./src/generated --typescript
```

Zeus Usage:
```typescript
// client/graphql-client.ts
import { Thunder } from './generated/zeus'

// Create typed client
const client = Thunder(async (query) => {
  const response = await fetch('http://localhost:4000/graphql', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${getToken()}`
    },
    body: JSON.stringify({ query })
  })
  
  if (!response.ok) {
    throw new Error('GraphQL request failed')
  }
  
  const result = await response.json()
  
  if (result.errors) {
    throw new Error(result.errors[0].message)
  }
  
  return result.data
})

// Type-safe queries with auto-completion
export const getUser = (id: string) => 
  client('query')({
    user: [{
      id
    }, {
      id: true,
      email: true,
      name: true,
      posts: {
        id: true,
        title: true,
        published: true
      }
    }]
  })

// Type-safe mutations
export const createUser = (input: CreateUserInput) =>
  client('mutation')({
    createUser: [{
      input
    }, {
      id: true,
      email: true,
      name: true
    }]
  })
```

React Query Integration:
```typescript
// hooks/use-graphql.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query'
import { getUser, createUser } from '../client/graphql-client'

export function useUser(id: string) {
  return useQuery({
    queryKey: ['user', id],
    queryFn: () => getUser(id),
    staleTime: 5 * 60 * 1000 // 5 minutes
  })
}

export function useCreateUser() {
  const queryClient = useQueryClient()
  
  return useMutation({
    mutationFn: createUser,
    onSuccess: (newUser) => {
      // Invalidate users list
      queryClient.invalidateQueries({ queryKey: ['users'] })
      
      // Add to cache
      queryClient.setQueryData(['user', newUser.id], newUser)
    }
  })
}
```

React Component:
```typescript
// components/user-profile.tsx
export function UserProfile({ userId }: { userId: string }) {
  const { data: user, isLoading, error } = useUser(userId)
  
  if (isLoading) return <Skeleton />
  if (error) return <ErrorAlert error={error} />
  if (!user) return <NotFound />
  
  return (
    <div>
      <h1>{user.name}</h1>
      <p>{user.email}</p>
      
      <h2>Posts</h2>
      {user.posts.map(post => (
        <article key={post.id}>
          <h3>{post.title}</h3>
          {post.published && <Badge>Published</Badge>}
        </article>
      ))}
    </div>
  )
}
```

=== ADVANCED PATTERNS ===
Subscription Support:
```typescript
// WebSocket subscriptions
import { createClient } from 'graphql-ws'

const wsClient = createClient({
  url: 'ws://localhost:4000/graphql',
  connectionParams: {
    authToken: getToken()
  }
})

// Zeus subscription
export const subscribeToUserUpdates = (userId: string) => {
  return new Observable((observer) => {
    const unsubscribe = wsClient.subscribe({
      query: `
        subscription UserUpdates($userId: ID!) {
          userUpdated(userId: $userId) {
            id
            name
            email
          }
        }
      `,
      variables: { userId }
    }, {
      next: (data) => observer.next(data),
      error: (err) => observer.error(err),
      complete: () => observer.complete()
    })
    
    return unsubscribe
  })
}
```

Error Handling:
```typescript
// Typed error handling
import { GraphQLError } from 'graphql'

class GraphQLClient {
  async request<T>(operation: string): Promise<T> {
    try {
      return await client(operation)
    } catch (error) {
      if (error instanceof GraphQLError) {
        // Handle specific GraphQL errors
        if (error.extensions?.code === 'UNAUTHENTICATED') {
          // Redirect to login
          router.push('/login')
        }
      }
      throw error
    }
  }
}
```

Optimistic Updates:
```typescript
export function useUpdatePost() {
  const queryClient = useQueryClient()
  
  return useMutation({
    mutationFn: updatePost,
    onMutate: async (variables) => {
      // Cancel in-flight queries
      await queryClient.cancelQueries(['post', variables.id])
      
      // Snapshot previous value
      const previousPost = queryClient.getQueryData(['post', variables.id])
      
      // Optimistically update
      queryClient.setQueryData(['post', variables.id], old => ({
        ...old,
        ...variables.input
      }))
      
      return { previousPost }
    },
    onError: (err, variables, context) => {
      // Rollback on error
      if (context?.previousPost) {
        queryClient.setQueryData(
          ['post', variables.id],
          context.previousPost
        )
      }
    }
  })
}
```

=== PERFORMANCE OPTIMIZATION ===
Query Complexity:
```typescript
import depthLimit from 'graphql-depth-limit'
import costAnalysis from 'graphql-cost-analysis'

const server = new ApolloServer({
  schema,
  validationRules: [
    depthLimit(5),
    costAnalysis({
      maximumCost: 1000,
      defaultCost: 1,
      variables: {},
      scalarCost: 1,
      objectCost: 2,
      listFactor: 10
    })
  ]
})
```

Persisted Queries:
```typescript
// Save bandwidth with query hashing
import { createPersistedQueryLink } from '@apollo/client/link/persisted-queries'
import { sha256 } from 'crypto-hash'

const link = createPersistedQueryLink({
  sha256,
  useGETForHashedQueries: true
})
```

=== CONSTRAINTS ===
⛔ NEVER expose internal errors to clients
⛔ NEVER allow unbounded queries
⛔ NEVER skip authorization checks
⛔ NEVER return null for non-nullable fields
✅ ALWAYS use DataLoader for relationships
✅ ALWAYS validate query depth/complexity
✅ ALWAYS implement proper error handling
✅ ALWAYS version schema changes carefully