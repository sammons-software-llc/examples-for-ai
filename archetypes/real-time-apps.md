=== CONTEXT ===
Real-time collaborative application archetype for multi-user experiences.
Uses WebSockets with Socket.io and CRDT-based synchronization for conflict-free updates.

=== OBJECTIVE ===
Build scalable real-time applications with seamless collaboration features.
Success metrics:
□ <100ms latency for updates
□ Conflict-free simultaneous editing
□ Graceful offline/reconnection handling
□ Presence awareness working
□ Scales to 100+ concurrent users

=== TECHNICAL REQUIREMENTS ===
Core Stack:
- Socket.io for WebSocket abstraction
- Yjs for CRDT implementation
- Redis adapter for horizontal scaling
- Fastify + socket.io integration
- React with real-time hooks

Key Features:
- Document collaboration
- User presence/cursors
- Optimistic updates
- Offline support
- Automatic reconnection

=== PROJECT STRUCTURE ===
```
./lib/realtime-server/
  ├── src/
  │   ├── server.ts      # Socket.io server
  │   ├── rooms/         # Room management
  │   ├── documents/     # Document CRDTs
  │   ├── presence/      # Presence tracking
  │   └── persistence/   # Document storage
  └── package.json

./lib/realtime-client/
  ├── src/
  │   ├── socket.ts      # Socket client
  │   ├── hooks/         # React hooks
  │   ├── providers/     # Context providers
  │   └── crdt/          # Yjs integration
  └── package.json

./lib/shared-realtime/
  ├── src/
  │   ├── events.ts      # Event types
  │   ├── types.ts       # Shared types
  │   └── protocol.ts    # Wire protocol
  └── package.json
```

=== SERVER CONFIGURATION ===
Socket.io Server:
```typescript
// server.ts
import { Server } from 'socket.io'
import { createAdapter } from '@socket.io/redis-adapter'
import { Redis } from 'ioredis'
import * as Y from 'yjs'

const pubClient = new Redis()
const subClient = pubClient.duplicate()

export function createRealtimeServer(fastify: FastifyInstance) {
  const io = new Server(fastify.server, {
    cors: {
      origin: process.env.CLIENT_URL,
      credentials: true
    },
    adapter: createAdapter(pubClient, subClient)
  })
  
  // Middleware for auth
  io.use(async (socket, next) => {
    const token = socket.handshake.auth.token
    try {
      const user = await verifyToken(token)
      socket.data.user = user
      next()
    } catch (err) {
      next(new Error('Authentication failed'))
    }
  })
  
  io.on('connection', (socket) => {
    handleConnection(socket)
  })
  
  return io
}
```

Room Management:
```typescript
// rooms/room-manager.ts
export class RoomManager {
  private rooms = new Map<string, Room>()
  
  async joinRoom(socket: Socket, roomId: string) {
    let room = this.rooms.get(roomId)
    
    if (!room) {
      room = await this.createRoom(roomId)
      this.rooms.set(roomId, room)
    }
    
    await room.addUser(socket)
    socket.join(roomId)
    
    // Send current state
    socket.emit('room:state', {
      document: room.getDocumentState(),
      presence: room.getPresence()
    })
    
    // Broadcast user joined
    socket.to(roomId).emit('user:joined', {
      userId: socket.data.user.id,
      cursor: null
    })
  }
  
  private async createRoom(roomId: string): Promise<Room> {
    const doc = new Y.Doc()
    
    // Load from persistence if exists
    const persisted = await loadDocument(roomId)
    if (persisted) {
      Y.applyUpdate(doc, persisted)
    }
    
    return new Room(roomId, doc)
  }
}
```

CRDT Document Handling:
```typescript
// documents/document-handler.ts
import * as Y from 'yjs'
import * as syncProtocol from 'y-protocols/sync'

export function setupDocumentSync(socket: Socket, doc: Y.Doc) {
  // Handle sync messages
  socket.on('doc:sync', (message: Uint8Array) => {
    syncProtocol.readSyncMessage(
      decoder.decode(message),
      encoder,
      doc,
      socket
    )
    
    if (encoder.length > 0) {
      socket.emit('doc:sync', encoder.toUint8Array())
    }
  })
  
  // Handle updates
  socket.on('doc:update', (update: Uint8Array) => {
    Y.applyUpdate(doc, update)
    
    // Broadcast to other users in room
    socket.to(roomId).emit('doc:update', update)
    
    // Persist asynchronously
    persistDocument(roomId, doc)
  })
  
  // Send initial sync
  const encoder = encoding.createEncoder()
  syncProtocol.writeSyncStep1(encoder, doc)
  socket.emit('doc:sync', encoding.toUint8Array(encoder))
}
```

Presence System:
```typescript
// presence/presence-manager.ts
interface Presence {
  userId: string
  name: string
  color: string
  cursor?: { x: number; y: number }
  selection?: { start: number; end: number }
}

export class PresenceManager {
  private presence = new Map<string, Presence>()
  
  updatePresence(userId: string, data: Partial<Presence>) {
    const current = this.presence.get(userId) || {}
    const updated = { ...current, ...data, userId }
    
    this.presence.set(userId, updated)
    return updated
  }
  
  removeUser(userId: string) {
    this.presence.delete(userId)
  }
  
  getAll(): Presence[] {
    return Array.from(this.presence.values())
  }
}
```

=== CLIENT IMPLEMENTATION ===
Socket Client Setup:
```typescript
// socket.ts
import { io, Socket } from 'socket.io-client'

export function createRealtimeClient(token: string): Socket {
  const socket = io(process.env.REACT_APP_SERVER_URL, {
    auth: { token },
    reconnection: true,
    reconnectionDelay: 1000,
    reconnectionAttempts: 5
  })
  
  socket.on('connect', () => {
    console.log('Connected to realtime server')
  })
  
  socket.on('disconnect', (reason) => {
    if (reason === 'io server disconnect') {
      // Server disconnected us, try to reconnect
      socket.connect()
    }
  })
  
  return socket
}
```

React Provider:
```typescript
// providers/realtime-provider.tsx
import { createContext, useContext, useEffect, useState } from 'react'
import * as Y from 'yjs'
import { Socket } from 'socket.io-client'

interface RealtimeContextValue {
  socket: Socket
  doc: Y.Doc
  presence: Map<string, Presence>
  connected: boolean
}

const RealtimeContext = createContext<RealtimeContextValue | null>(null)

export function RealtimeProvider({ children, roomId, token }) {
  const [socket] = useState(() => createRealtimeClient(token))
  const [doc] = useState(() => new Y.Doc())
  const [presence, setPresence] = useState(new Map())
  const [connected, setConnected] = useState(false)
  
  useEffect(() => {
    socket.on('connect', () => setConnected(true))
    socket.on('disconnect', () => setConnected(false))
    
    // Join room
    socket.emit('room:join', roomId)
    
    // Setup document sync
    setupDocumentSync(socket, doc)
    
    // Handle presence updates
    socket.on('presence:update', (updates: Presence[]) => {
      setPresence(new Map(updates.map(p => [p.userId, p])))
    })
    
    return () => {
      socket.emit('room:leave', roomId)
      socket.disconnect()
    }
  }, [socket, doc, roomId])
  
  return (
    <RealtimeContext.Provider value={{ socket, doc, presence, connected }}>
      {children}
    </RealtimeContext.Provider>
  )
}
```

Collaborative Text Editor:
```typescript
// components/collaborative-editor.tsx
import { useEffect, useRef } from 'react'
import * as Y from 'yjs'
import { useRealtime } from '../hooks/use-realtime'

export function CollaborativeEditor() {
  const editorRef = useRef<HTMLDivElement>(null)
  const { doc, presence } = useRealtime()
  const yText = doc.getText('content')
  
  useEffect(() => {
    if (!editorRef.current) return
    
    // Initialize editor with Yjs binding
    const editor = createEditor(editorRef.current)
    bindYjsToEditor(editor, yText)
    
    // Render other users' cursors
    presence.forEach((user) => {
      if (user.cursor) {
        renderCursor(editor, user)
      }
    })
    
    return () => editor.destroy()
  }, [doc, presence])
  
  return (
    <div className="editor-container">
      <div ref={editorRef} className="editor" />
      <PresenceAvatars users={Array.from(presence.values())} />
    </div>
  )
}
```

Optimistic Updates:
```typescript
// hooks/use-optimistic.ts
export function useOptimisticUpdate<T>() {
  const { socket } = useRealtime()
  const [optimistic, setOptimistic] = useState<T[]>([])
  
  const update = useCallback((action: T) => {
    // Apply optimistically
    setOptimistic(prev => [...prev, action])
    
    // Send to server
    socket.emit('action', action, (error?: Error) => {
      if (error) {
        // Rollback on error
        setOptimistic(prev => prev.filter(a => a !== action))
        toast.error('Update failed')
      }
    })
  }, [socket])
  
  return { update, optimistic }
}
```

=== SCALING CONFIGURATION ===
Redis Adapter:
```typescript
// For horizontal scaling across multiple servers
const io = new Server(server, {
  adapter: createAdapter(pubClient, subClient)
})

// Sticky sessions in load balancer required
// Or use socket.io-sticky for IP hash routing
```

Document Persistence:
```typescript
// persistence/document-store.ts
export class DocumentStore {
  private redis: Redis
  
  async save(roomId: string, doc: Y.Doc): Promise<void> {
    const update = Y.encodeStateAsUpdate(doc)
    await this.redis.set(
      `doc:${roomId}`,
      Buffer.from(update).toString('base64'),
      'EX',
      86400 // 24 hour TTL
    )
  }
  
  async load(roomId: string): Promise<Uint8Array | null> {
    const data = await this.redis.get(`doc:${roomId}`)
    if (!data) return null
    
    return Buffer.from(data, 'base64')
  }
}
```

=== CONSTRAINTS ===
⛔ NEVER send full document state on every update
⛔ NEVER trust client-sent presence data
⛔ NEVER store CRDT updates in memory only
⛔ NEVER ignore connection state
✅ ALWAYS use incremental updates
✅ ALWAYS validate room permissions
✅ ALWAYS handle reconnection gracefully
✅ ALWAYS limit room size for performance

=== VALIDATION CHECKLIST ===
□ WebSocket connection established
□ Document sync working
□ Presence updates visible
□ Offline changes sync on reconnect
□ Multiple users can edit simultaneously
□ No conflicts or data loss
□ Redis adapter configured
□ Document persistence working
□ Scales to target user count