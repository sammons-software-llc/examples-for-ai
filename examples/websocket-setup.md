# WebSocket Setup Guide

## Context
You are implementing real-time communication features following Ben's preferences for Socket.io, Fastify WebSocket support, and efficient message handling patterns.

## Objective
Implement WebSocket connections that are reliable, scalable, and maintainable while supporting authentication, rooms, and presence tracking.

## Process

### === WEBSOCKET DECISION TREE ===

```
IF communication_pattern == "bidirectional":
    THEN: Use Socket.io for compatibility
    AND: Implement room-based messaging
    OUTPUT: Full duplex communication

ELIF communication_pattern == "server_to_client_only":
    THEN: Use Server-Sent Events (SSE)
    AND: Implement event streams
    OUTPUT: Efficient one-way updates

ELIF communication_pattern == "peer_to_peer":
    THEN: Use WebRTC with signaling server
    AND: Socket.io for signaling
    OUTPUT: Direct peer connections

ELIF scaling_required == true:
    THEN: Add Redis adapter
    AND: Implement sticky sessions
    OUTPUT: Horizontally scalable

ELSE:
    THEN: Use basic WebSocket
    AND: Implement reconnection logic
    OUTPUT: Simple real-time connection
```

## Implementation Patterns

### 1. Basic Socket.io Setup with Fastify

```typescript
// lib/server/src/socket-setup.ts
import type { FastifyInstance } from 'fastify'
import { Server as SocketIOServer } from 'socket.io'
import { createAdapter } from '@socket.io/redis-adapter'
import { Redis } from 'ioredis'
import { verifyToken } from './auth/verify-token'
import { logger } from './utils/logger'

export interface SocketData {
  userId: string
  username: string
  rooms: Set<string>
}

export interface ServerToClientEvents {
  message: (data: { id: string; text: string; userId: string; timestamp: Date }) => void
  userJoined: (data: { userId: string; username: string }) => void
  userLeft: (data: { userId: string; username: string }) => void
  typing: (data: { userId: string; isTyping: boolean }) => void
  error: (data: { code: string; message: string }) => void
}

export interface ClientToServerEvents {
  joinRoom: (roomId: string, callback: (error?: Error) => void) => void
  leaveRoom: (roomId: string, callback: (error?: Error) => void) => void
  sendMessage: (data: { roomId: string; text: string }, callback: (error?: Error) => void) => void
  startTyping: (roomId: string) => void
  stopTyping: (roomId: string) => void
}

export interface InterServerEvents {
  ping: () => void
}

export function setupSocketIO(app: FastifyInstance) {
  const io = new SocketIOServer<
    ClientToServerEvents,
    ServerToClientEvents,
    InterServerEvents,
    SocketData
  >(app.server, {
    cors: {
      origin: process.env.CLIENT_URL || 'http://localhost:3000',
      credentials: true
    },
    transports: ['websocket', 'polling'],
    pingTimeout: 60000,
    pingInterval: 25000
  })

  // Redis adapter for scaling
  if (process.env.REDIS_URL) {
    const pubClient = new Redis(process.env.REDIS_URL)
    const subClient = pubClient.duplicate()
    io.adapter(createAdapter(pubClient, subClient))
    
    logger.info('Socket.IO using Redis adapter for scaling')
  }

  // Authentication middleware
  io.use(async (socket, next) => {
    try {
      const token = socket.handshake.auth.token
      if (!token) {
        return next(new Error('Authentication required'))
      }

      const user = await verifyToken(token)
      if (!user) {
        return next(new Error('Invalid token'))
      }

      socket.data.userId = user.id
      socket.data.username = user.username
      socket.data.rooms = new Set()
      
      next()
    } catch (error) {
      logger.error('Socket authentication error:', error)
      next(new Error('Authentication failed'))
    }
  })

  // Connection handling
  io.on('connection', (socket) => {
    logger.info(`User ${socket.data.userId} connected`)

    // Join personal room for direct messages
    socket.join(`user:${socket.data.userId}`)

    // Room management
    socket.on('joinRoom', async (roomId, callback) => {
      try {
        // Validate user has access to room
        const hasAccess = await validateRoomAccess(socket.data.userId, roomId)
        if (!hasAccess) {
          return callback(new Error('Access denied'))
        }

        socket.join(roomId)
        socket.data.rooms.add(roomId)

        // Notify others in room
        socket.to(roomId).emit('userJoined', {
          userId: socket.data.userId,
          username: socket.data.username
        })

        // Get room members for presence
        const members = await getRoomMembers(io, roomId)
        socket.emit('roomMembers', members)

        callback()
      } catch (error) {
        logger.error('Join room error:', error)
        callback(error as Error)
      }
    })

    socket.on('leaveRoom', (roomId, callback) => {
      socket.leave(roomId)
      socket.data.rooms.delete(roomId)

      socket.to(roomId).emit('userLeft', {
        userId: socket.data.userId,
        username: socket.data.username
      })

      callback()
    })

    // Message handling
    socket.on('sendMessage', async (data, callback) => {
      try {
        const { roomId, text } = data

        if (!socket.data.rooms.has(roomId)) {
          return callback(new Error('Not in room'))
        }

        const message = {
          id: generateId(),
          text,
          userId: socket.data.userId,
          timestamp: new Date()
        }

        // Save to database
        await saveMessage(roomId, message)

        // Broadcast to room
        io.to(roomId).emit('message', message)
        
        callback()
      } catch (error) {
        logger.error('Send message error:', error)
        callback(error as Error)
      }
    })

    // Typing indicators
    const typingTimers = new Map<string, NodeJS.Timeout>()

    socket.on('startTyping', (roomId) => {
      if (!socket.data.rooms.has(roomId)) return

      socket.to(roomId).emit('typing', {
        userId: socket.data.userId,
        isTyping: true
      })

      // Auto-stop typing after 5 seconds
      const existingTimer = typingTimers.get(roomId)
      if (existingTimer) clearTimeout(existingTimer)

      const timer = setTimeout(() => {
        socket.to(roomId).emit('typing', {
          userId: socket.data.userId,
          isTyping: false
        })
        typingTimers.delete(roomId)
      }, 5000)

      typingTimers.set(roomId, timer)
    })

    socket.on('stopTyping', (roomId) => {
      if (!socket.data.rooms.has(roomId)) return

      const timer = typingTimers.get(roomId)
      if (timer) {
        clearTimeout(timer)
        typingTimers.delete(roomId)
      }

      socket.to(roomId).emit('typing', {
        userId: socket.data.userId,
        isTyping: false
      })
    })

    // Disconnection
    socket.on('disconnect', (reason) => {
      logger.info(`User ${socket.data.userId} disconnected: ${reason}`)

      // Clear all typing indicators
      typingTimers.forEach(timer => clearTimeout(timer))
      typingTimers.clear()

      // Notify all rooms
      socket.data.rooms.forEach(roomId => {
        socket.to(roomId).emit('userLeft', {
          userId: socket.data.userId,
          username: socket.data.username
        })
      })
    })
  })

  return io
}
```

### 2. Client-Side Implementation

```typescript
// lib/ui/src/hooks/use-socket.ts
import { useEffect, useRef, useCallback } from 'react'
import { io, Socket } from 'socket.io-client'
import { useAuthStore } from '../stores/auth-store'
import { useMessageStore } from '../stores/message-store'
import type { 
  ServerToClientEvents, 
  ClientToServerEvents 
} from '@sammons/shared-types'

export function useSocket() {
  const socketRef = useRef<Socket<ServerToClientEvents, ClientToServerEvents>>()
  const { token } = useAuthStore()
  const { addMessage, setUserTyping } = useMessageStore()

  useEffect(() => {
    if (!token) return

    // ✅ Initialize socket with auth
    const socket = io(process.env.REACT_APP_SERVER_URL || 'http://localhost:3000', {
      auth: { token },
      transports: ['websocket', 'polling'],
      reconnection: true,
      reconnectionDelay: 1000,
      reconnectionDelayMax: 5000,
      reconnectionAttempts: 5
    })

    socketRef.current = socket

    // ✅ Connection events
    socket.on('connect', () => {
      console.log('Connected to server')
    })

    socket.on('connect_error', (error) => {
      console.error('Connection error:', error.message)
    })

    socket.on('disconnect', (reason) => {
      console.log('Disconnected:', reason)
      if (reason === 'io server disconnect') {
        // Server disconnected us, try to reconnect
        socket.connect()
      }
    })

    // ✅ Message events
    socket.on('message', (data) => {
      addMessage(data)
    })

    socket.on('typing', ({ userId, isTyping }) => {
      setUserTyping(userId, isTyping)
    })

    socket.on('error', ({ code, message }) => {
      console.error(`Socket error ${code}:`, message)
    })

    return () => {
      socket.disconnect()
    }
  }, [token])

  // ✅ Socket methods
  const joinRoom = useCallback((roomId: string): Promise<void> => {
    return new Promise((resolve, reject) => {
      if (!socketRef.current) {
        reject(new Error('Socket not connected'))
        return
      }

      socketRef.current.emit('joinRoom', roomId, (error) => {
        if (error) {
          reject(error)
        } else {
          resolve()
        }
      })
    })
  }, [])

  const sendMessage = useCallback((roomId: string, text: string): Promise<void> => {
    return new Promise((resolve, reject) => {
      if (!socketRef.current) {
        reject(new Error('Socket not connected'))
        return
      }

      socketRef.current.emit('sendMessage', { roomId, text }, (error) => {
        if (error) {
          reject(error)
        } else {
          resolve()
        }
      })
    })
  }, [])

  const startTyping = useCallback((roomId: string) => {
    socketRef.current?.emit('startTyping', roomId)
  }, [])

  const stopTyping = useCallback((roomId: string) => {
    socketRef.current?.emit('stopTyping', roomId)
  }, [])

  return {
    socket: socketRef.current,
    joinRoom,
    sendMessage,
    startTyping,
    stopTyping,
    connected: socketRef.current?.connected ?? false
  }
}
```

### 3. Server-Sent Events (SSE) Alternative

```typescript
// lib/server/src/handlers/sse-handler.ts
import type { FastifyRequest, FastifyReply } from 'fastify'
import { EventEmitter } from 'events'

interface SSEClient {
  id: string
  userId: string
  reply: FastifyReply
}

class SSEManager extends EventEmitter {
  private clients = new Map<string, SSEClient>()

  addClient(client: SSEClient) {
    this.clients.set(client.id, client)
    
    // Send initial connection event
    this.sendToClient(client.id, {
      event: 'connected',
      data: { clientId: client.id }
    })
  }

  removeClient(id: string) {
    this.clients.delete(id)
  }

  sendToClient(clientId: string, data: any) {
    const client = this.clients.get(clientId)
    if (!client) return

    const message = `event: ${data.event}\ndata: ${JSON.stringify(data.data)}\n\n`
    client.reply.raw.write(message)
  }

  sendToUser(userId: string, data: any) {
    for (const client of this.clients.values()) {
      if (client.userId === userId) {
        this.sendToClient(client.id, data)
      }
    }
  }

  broadcast(data: any) {
    for (const client of this.clients.values()) {
      this.sendToClient(client.id, data)
    }
  }
}

export const sseManager = new SSEManager()

export async function sseHandler(
  request: FastifyRequest,
  reply: FastifyReply
) {
  // Set SSE headers
  reply.raw.writeHead(200, {
    'Content-Type': 'text/event-stream',
    'Cache-Control': 'no-cache',
    'Connection': 'keep-alive',
    'X-Accel-Buffering': 'no' // Disable Nginx buffering
  })

  const clientId = generateId()
  const client: SSEClient = {
    id: clientId,
    userId: request.user.id,
    reply
  }

  sseManager.addClient(client)

  // Handle client disconnect
  request.raw.on('close', () => {
    sseManager.removeClient(clientId)
  })

  // Keep connection alive
  const keepAlive = setInterval(() => {
    reply.raw.write(':ping\n\n')
  }, 30000)

  request.raw.on('close', () => {
    clearInterval(keepAlive)
  })
}

// Usage in other parts of the app
export function notifyUser(userId: string, notification: any) {
  sseManager.sendToUser(userId, {
    event: 'notification',
    data: notification
  })
}
```

### 4. Collaborative Editing with Yjs

```typescript
// lib/server/src/yjs-websocket.ts
import { WebSocketServer } from 'ws'
import { setupWSConnection } from 'y-websocket/bin/utils'
import * as Y from 'yjs'
import { Redis } from 'ioredis'

interface YjsDocument {
  name: string
  doc: Y.Doc
  connections: Set<any>
  lastUpdated: Date
}

export class YjsServer {
  private wss: WebSocketServer
  private documents = new Map<string, YjsDocument>()
  private redis?: Redis

  constructor(server: any, redisUrl?: string) {
    this.wss = new WebSocketServer({ server })
    
    if (redisUrl) {
      this.redis = new Redis(redisUrl)
    }

    this.setupWebSocket()
    this.startGarbageCollection()
  }

  private setupWebSocket() {
    this.wss.on('connection', (ws, req) => {
      const docName = req.url?.slice(1) || 'default'
      
      // Setup Yjs connection
      setupWSConnection(ws, docName, {
        gc: true,
        gcFilter: () => true
      })

      // Track document
      if (!this.documents.has(docName)) {
        const doc = new Y.Doc()
        this.documents.set(docName, {
          name: docName,
          doc,
          connections: new Set(),
          lastUpdated: new Date()
        })

        // Load from persistence if available
        this.loadDocument(docName, doc)
      }

      const docInfo = this.documents.get(docName)!
      docInfo.connections.add(ws)
      docInfo.lastUpdated = new Date()

      ws.on('close', () => {
        docInfo.connections.delete(ws)
        docInfo.lastUpdated = new Date()
      })
    })
  }

  private async loadDocument(name: string, doc: Y.Doc) {
    if (!this.redis) return

    try {
      const data = await this.redis.get(`yjs:${name}`)
      if (data) {
        const update = Buffer.from(data, 'base64')
        Y.applyUpdate(doc, update)
      }
    } catch (error) {
      console.error('Failed to load document:', error)
    }
  }

  private async saveDocument(name: string, doc: Y.Doc) {
    if (!this.redis) return

    try {
      const update = Y.encodeStateAsUpdate(doc)
      await this.redis.set(
        `yjs:${name}`,
        update.toString('base64'),
        'EX',
        86400 * 7 // 7 days
      )
    } catch (error) {
      console.error('Failed to save document:', error)
    }
  }

  private startGarbageCollection() {
    setInterval(() => {
      const now = Date.now()
      
      for (const [name, docInfo] of this.documents) {
        // Remove documents with no connections for 5 minutes
        if (
          docInfo.connections.size === 0 &&
          now - docInfo.lastUpdated.getTime() > 5 * 60 * 1000
        ) {
          // Save before removing
          this.saveDocument(name, docInfo.doc)
          this.documents.delete(name)
        }
      }
    }, 60000) // Check every minute
  }
}
```

### 5. React Component with Real-time Updates

```tsx
// lib/ui/src/components/chat-room.tsx
import React, { useState, useEffect, useCallback, useRef } from 'react'
import { useSocket } from '../hooks/use-socket'
import { MessageList } from './message-list'
import { MessageInput } from './message-input'
import { TypingIndicator } from './typing-indicator'
import { ConnectionStatus } from './connection-status'

interface ChatRoomProps {
  roomId: string
}

export const ChatRoom: React.FC<ChatRoomProps> = ({ roomId }) => {
  const [messages, setMessages] = useState<Message[]>([])
  const [typingUsers, setTypingUsers] = useState<string[]>([])
  const [isConnected, setIsConnected] = useState(false)
  const { socket, joinRoom, sendMessage, startTyping, stopTyping } = useSocket()
  const typingTimeoutRef = useRef<NodeJS.Timeout>()

  // ✅ Join room on mount
  useEffect(() => {
    if (!socket) return

    joinRoom(roomId)
      .then(() => {
        console.log(`Joined room ${roomId}`)
        setIsConnected(true)
      })
      .catch((error) => {
        console.error('Failed to join room:', error)
      })

    // Socket event listeners
    socket.on('message', (message) => {
      setMessages(prev => [...prev, message])
    })

    socket.on('typing', ({ userId, isTyping }) => {
      setTypingUsers(prev => {
        if (isTyping) {
          return prev.includes(userId) ? prev : [...prev, userId]
        }
        return prev.filter(id => id !== userId)
      })
    })

    socket.on('connect', () => setIsConnected(true))
    socket.on('disconnect', () => setIsConnected(false))

    return () => {
      socket.off('message')
      socket.off('typing')
      socket.off('connect')
      socket.off('disconnect')
    }
  }, [socket, roomId])

  // ✅ Handle sending messages
  const handleSendMessage = useCallback(async (text: string) => {
    try {
      await sendMessage(roomId, text)
    } catch (error) {
      console.error('Failed to send message:', error)
    }
  }, [roomId, sendMessage])

  // ✅ Handle typing indicators
  const handleTyping = useCallback(() => {
    startTyping(roomId)

    // Clear existing timeout
    if (typingTimeoutRef.current) {
      clearTimeout(typingTimeoutRef.current)
    }

    // Stop typing after 2 seconds of inactivity
    typingTimeoutRef.current = setTimeout(() => {
      stopTyping(roomId)
    }, 2000)
  }, [roomId, startTyping, stopTyping])

  return (
    <div className="flex flex-col h-full">
      <ConnectionStatus connected={isConnected} />
      
      <div className="flex-1 overflow-y-auto">
        <MessageList messages={messages} />
      </div>
      
      {typingUsers.length > 0 && (
        <TypingIndicator users={typingUsers} />
      )}
      
      <MessageInput 
        onSendMessage={handleSendMessage}
        onTyping={handleTyping}
        disabled={!isConnected}
      />
    </div>
  )
}
```

## Testing WebSocket Connections

```typescript
// src/__tests__/websocket.test.ts
import { describe, it, expect, beforeAll, afterAll } from 'vitest'
import { io as ioClient, Socket } from 'socket.io-client'
import { createApp } from '../app'
import type { FastifyInstance } from 'fastify'

describe('WebSocket Integration', () => {
  let app: FastifyInstance
  let clientSocket: Socket
  let serverUrl: string

  beforeAll(async () => {
    app = await createApp()
    await app.listen({ port: 0 })
    serverUrl = `http://localhost:${app.server.address().port}`
  })

  afterAll(async () => {
    if (clientSocket) clientSocket.close()
    await app.close()
  })

  it('connects with valid authentication', async () => {
    const token = 'valid-test-token'
    
    clientSocket = ioClient(serverUrl, {
      auth: { token },
      transports: ['websocket']
    })

    await new Promise<void>((resolve) => {
      clientSocket.on('connect', resolve)
    })

    expect(clientSocket.connected).toBe(true)
  })

  it('rejects connection without authentication', async () => {
    const unauthorizedSocket = ioClient(serverUrl, {
      transports: ['websocket']
    })

    await new Promise<void>((resolve) => {
      unauthorizedSocket.on('connect_error', (error) => {
        expect(error.message).toContain('Authentication required')
        resolve()
      })
    })
  })

  it('handles room messaging', async () => {
    const roomId = 'test-room'
    const messageText = 'Hello, WebSocket!'
    
    // Join room
    await new Promise<void>((resolve, reject) => {
      clientSocket.emit('joinRoom', roomId, (error) => {
        if (error) reject(error)
        else resolve()
      })
    })

    // Listen for message
    const messagePromise = new Promise((resolve) => {
      clientSocket.on('message', resolve)
    })

    // Send message
    await new Promise<void>((resolve, reject) => {
      clientSocket.emit('sendMessage', { roomId, text: messageText }, (error) => {
        if (error) reject(error)
        else resolve()
      })
    })

    const receivedMessage = await messagePromise
    expect(receivedMessage).toMatchObject({
      text: messageText,
      userId: expect.any(String),
      timestamp: expect.any(String)
    })
  })
})
```

## Performance Optimization

### Message Batching
```typescript
class MessageBatcher {
  private queue: Message[] = []
  private timer: NodeJS.Timeout | null = null
  private readonly batchSize = 10
  private readonly batchDelay = 100 // ms

  constructor(private onFlush: (messages: Message[]) => void) {}

  add(message: Message) {
    this.queue.push(message)
    
    if (this.queue.length >= this.batchSize) {
      this.flush()
    } else if (!this.timer) {
      this.timer = setTimeout(() => this.flush(), this.batchDelay)
    }
  }

  private flush() {
    if (this.queue.length === 0) return
    
    const messages = [...this.queue]
    this.queue = []
    
    if (this.timer) {
      clearTimeout(this.timer)
      this.timer = null
    }
    
    this.onFlush(messages)
  }
}
```

## Best Practices

### ✅ DO
- Implement automatic reconnection
- Use rooms for logical grouping
- Add authentication middleware
- Handle connection errors gracefully
- Implement heartbeat/ping-pong
- Use message acknowledgments
- Clean up resources on disconnect
- Add rate limiting for messages

### ⛔ DON'T
- Don't send sensitive data without encryption
- Don't trust client-provided data
- Don't forget to validate room access
- Don't ignore memory leaks from event listeners
- Don't use polling as primary transport
- Don't broadcast to all users unnecessarily

Remember: Real-time features should enhance user experience, not complicate it. Start simple and add complexity only when needed.