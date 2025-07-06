=== CONTEXT ===
Machine Learning and AI application archetype for TypeScript developers.
Focuses on using pre-trained models via APIs or dockerized local inference.

=== OBJECTIVE ===
Build AI-powered applications without deep ML expertise.
Success metrics:
□ <2 second inference time
□ Graceful API fallbacks
□ Cost-effective compute usage
□ Model versioning implemented
□ Privacy-preserving options available

=== TECHNICAL APPROACHES ===
Option 1: Cloud APIs
- AWS Bedrock (Claude, Llama, etc.)
- OpenAI API
- Anthropic API
- Google Vertex AI

Option 2: Local Docker
- Ollama for LLMs
- ONNX Runtime for general models
- TensorFlow.js for browser
- Whisper for speech-to-text

Option 3: Rented Compute
- Replicate.com
- Hugging Face Inference
- Modal.com
- Banana.dev

=== PROJECT STRUCTURE ===
```
./lib/ai-service/
  ├── src/
  │   ├── providers/      # AI provider implementations
  │   │   ├── bedrock.ts
  │   │   ├── openai.ts
  │   │   ├── ollama.ts
  │   │   └── replicate.ts
  │   ├── models/         # Model configurations
  │   │   ├── llm.ts     # Language models
  │   │   ├── vision.ts  # Image models
  │   │   └── audio.ts   # Speech models
  │   ├── strategies/     # Use case implementations
  │   │   ├── chat.ts
  │   │   ├── summarize.ts
  │   │   └── generate.ts
  │   └── index.ts       # Unified interface
  └── package.json

./docker/
  ├── ollama/
  │   └── docker-compose.yml
  └── models/
      └── download.sh
```

=== PROVIDER IMPLEMENTATIONS ===
Unified AI Interface:
```typescript
// src/index.ts
export interface AIProvider {
  chat(messages: Message[]): Promise<string>
  complete(prompt: string): Promise<string>
  embed(text: string): Promise<number[]>
  generateImage(prompt: string): Promise<Buffer>
}

export interface Message {
  role: 'system' | 'user' | 'assistant'
  content: string
}

export class AIService {
  private providers: Map<string, AIProvider>
  private primaryProvider: string
  
  constructor(config: AIConfig) {
    this.providers = new Map()
    this.setupProviders(config)
    this.primaryProvider = config.primary || 'bedrock'
  }
  
  async chat(messages: Message[], options?: ChatOptions): Promise<string> {
    const provider = this.getProvider(options?.provider)
    
    try {
      return await provider.chat(messages)
    } catch (error) {
      // Fallback to secondary provider
      if (this.providers.has('ollama')) {
        logger.warn('Primary provider failed, falling back to local')
        return this.providers.get('ollama')!.chat(messages)
      }
      throw error
    }
  }
}
```

AWS Bedrock Provider:
```typescript
// providers/bedrock.ts
import { BedrockRuntimeClient, InvokeModelCommand } from '@aws-sdk/client-bedrock-runtime'

export class BedrockProvider implements AIProvider {
  private client: BedrockRuntimeClient
  private modelId: string
  
  constructor(config: BedrockConfig) {
    this.client = new BedrockRuntimeClient({
      region: config.region || 'us-east-1'
    })
    this.modelId = config.modelId || 'anthropic.claude-3-sonnet-20240229-v1:0'
  }
  
  async chat(messages: Message[]): Promise<string> {
    const payload = {
      anthropic_version: "bedrock-2023-05-31",
      max_tokens: 4096,
      messages: messages.map(m => ({
        role: m.role === 'system' ? 'user' : m.role,
        content: m.content
      }))
    }
    
    const command = new InvokeModelCommand({
      modelId: this.modelId,
      contentType: 'application/json',
      body: JSON.stringify(payload)
    })
    
    const response = await this.client.send(command)
    const result = JSON.parse(new TextDecoder().decode(response.body))
    
    return result.content[0].text
  }
  
  async embed(text: string): Promise<number[]> {
    // Use Titan embeddings model
    const command = new InvokeModelCommand({
      modelId: 'amazon.titan-embed-text-v1',
      contentType: 'application/json',
      body: JSON.stringify({ inputText: text })
    })
    
    const response = await this.client.send(command)
    const result = JSON.parse(new TextDecoder().decode(response.body))
    
    return result.embedding
  }
}
```

Local Ollama Provider:
```typescript
// providers/ollama.ts
export class OllamaProvider implements AIProvider {
  private baseUrl: string
  private model: string
  
  constructor(config: OllamaConfig) {
    this.baseUrl = config.baseUrl || 'http://localhost:11434'
    this.model = config.model || 'llama2'
  }
  
  async chat(messages: Message[]): Promise<string> {
    const response = await fetch(`${this.baseUrl}/api/chat`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        model: this.model,
        messages,
        stream: false
      })
    })
    
    if (!response.ok) {
      throw new Error(`Ollama error: ${response.statusText}`)
    }
    
    const result = await response.json()
    return result.message.content
  }
  
  async complete(prompt: string): Promise<string> {
    const response = await fetch(`${this.baseUrl}/api/generate`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        model: this.model,
        prompt,
        stream: false
      })
    })
    
    const result = await response.json()
    return result.response
  }
}
```

=== DOCKER SETUP ===
Ollama Docker Compose:
```yaml
# docker/ollama/docker-compose.yml
version: '3.8'

services:
  ollama:
    image: ollama/ollama:latest
    container_name: ollama
    ports:
      - "11434:11434"
    volumes:
      - ollama_data:/root/.ollama
    environment:
      - OLLAMA_HOST=0.0.0.0
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
    restart: unless-stopped

  ollama-webui:
    image: ghcr.io/ollama-webui/ollama-webui:main
    container_name: ollama-webui
    ports:
      - "3000:8080"
    environment:
      - OLLAMA_API_BASE_URL=http://ollama:11434/api
    depends_on:
      - ollama
    restart: unless-stopped

volumes:
  ollama_data:
```

Model Download Script:
```bash
#!/bin/bash
# docker/models/download.sh

echo "Downloading models for Ollama..."

# Start Ollama service
docker-compose up -d ollama

# Wait for service to be ready
sleep 5

# Download models
docker exec ollama ollama pull llama2
docker exec ollama ollama pull codellama
docker exec ollama ollama pull mistral

echo "Models downloaded successfully!"
```

=== USE CASE IMPLEMENTATIONS ===
Chat Strategy:
```typescript
// strategies/chat.ts
export class ChatStrategy {
  constructor(private ai: AIService) {}
  
  async createConversation(systemPrompt?: string): Promise<Conversation> {
    const messages: Message[] = []
    
    if (systemPrompt) {
      messages.push({ role: 'system', content: systemPrompt })
    }
    
    return {
      messages,
      async send(userMessage: string): Promise<string> {
        messages.push({ role: 'user', content: userMessage })
        
        const response = await this.ai.chat(messages)
        messages.push({ role: 'assistant', content: response })
        
        return response
      },
      
      getHistory(): Message[] {
        return [...messages]
      }
    }
  }
}
```

Document Processing:
```typescript
// strategies/document.ts
export class DocumentStrategy {
  constructor(private ai: AIService) {}
  
  async summarize(text: string, maxLength = 500): Promise<string> {
    const prompt = `Summarize the following text in ${maxLength} characters or less:

${text}

Summary:`
    
    return this.ai.complete(prompt)
  }
  
  async extractEntities(text: string): Promise<Entity[]> {
    const prompt = `Extract all named entities (people, places, organizations) from the text.
Return as JSON array with type and name.

Text: ${text}

Entities:`
    
    const response = await this.ai.complete(prompt)
    return JSON.parse(response)
  }
  
  async classifyIntent(text: string, categories: string[]): Promise<string> {
    const prompt = `Classify the following text into one of these categories: ${categories.join(', ')}

Text: ${text}

Category:`
    
    return this.ai.complete(prompt)
  }
}
```

Vector Search:
```typescript
// strategies/vector-search.ts
import { PrismaClient } from '@prisma/client'

export class VectorSearchStrategy {
  constructor(
    private ai: AIService,
    private prisma: PrismaClient
  ) {}
  
  async indexDocument(content: string, metadata: any): Promise<void> {
    // Generate embeddings
    const embedding = await this.ai.embed(content)
    
    // Store in database with pgvector
    await this.prisma.$executeRaw`
      INSERT INTO documents (content, metadata, embedding)
      VALUES (${content}, ${metadata}, ${embedding}::vector)
    `
  }
  
  async search(query: string, limit = 10): Promise<SearchResult[]> {
    // Generate query embedding
    const queryEmbedding = await this.ai.embed(query)
    
    // Similarity search
    const results = await this.prisma.$queryRaw`
      SELECT content, metadata, 
             1 - (embedding <=> ${queryEmbedding}::vector) as similarity
      FROM documents
      ORDER BY embedding <=> ${queryEmbedding}::vector
      LIMIT ${limit}
    `
    
    return results
  }
}
```

=== STREAMING RESPONSES ===
Server-Sent Events:
```typescript
// handlers/stream-chat.ts
export async function streamChatHandler(
  request: FastifyRequest,
  reply: FastifyReply
) {
  const { messages } = request.body as { messages: Message[] }
  
  reply.raw.writeHead(200, {
    'Content-Type': 'text/event-stream',
    'Cache-Control': 'no-cache',
    'Connection': 'keep-alive'
  })
  
  try {
    const stream = await ai.streamChat(messages)
    
    for await (const chunk of stream) {
      reply.raw.write(`data: ${JSON.stringify({ text: chunk })}\n\n`)
    }
    
    reply.raw.write('data: [DONE]\n\n')
  } catch (error) {
    reply.raw.write(`data: ${JSON.stringify({ error: error.message })}\n\n`)
  } finally {
    reply.raw.end()
  }
}
```

React Hook:
```typescript
// hooks/use-streaming-chat.ts
export function useStreamingChat() {
  const [messages, setMessages] = useState<Message[]>([])
  const [isStreaming, setIsStreaming] = useState(false)
  
  const sendMessage = async (content: string) => {
    const userMessage: Message = { role: 'user', content }
    const newMessages = [...messages, userMessage]
    setMessages(newMessages)
    setIsStreaming(true)
    
    const response = { role: 'assistant' as const, content: '' }
    setMessages([...newMessages, response])
    
    const eventSource = new EventSource(
      `/api/chat/stream?messages=${encodeURIComponent(JSON.stringify(newMessages))}`
    )
    
    eventSource.onmessage = (event) => {
      const data = JSON.parse(event.data)
      
      if (data === '[DONE]') {
        eventSource.close()
        setIsStreaming(false)
        return
      }
      
      setMessages(prev => {
        const updated = [...prev]
        updated[updated.length - 1].content += data.text
        return updated
      })
    }
    
    eventSource.onerror = () => {
      eventSource.close()
      setIsStreaming(false)
    }
  }
  
  return { messages, sendMessage, isStreaming }
}
```

=== COST OPTIMIZATION ===
Caching Strategy:
```typescript
// Cache AI responses to reduce API calls
export class CachedAIService extends AIService {
  private cache = new Map<string, CacheEntry>()
  
  async complete(prompt: string): Promise<string> {
    const cacheKey = this.hashPrompt(prompt)
    const cached = this.cache.get(cacheKey)
    
    if (cached && Date.now() - cached.timestamp < 3600000) {
      return cached.response
    }
    
    const response = await super.complete(prompt)
    
    this.cache.set(cacheKey, {
      response,
      timestamp: Date.now()
    })
    
    return response
  }
}
```

=== CONSTRAINTS ===
⛔ NEVER expose API keys in client code
⛔ NEVER send sensitive data to external APIs
⛔ NEVER assume model availability
⛔ NEVER ignore rate limits
✅ ALWAYS implement fallback providers
✅ ALWAYS cache when appropriate
✅ ALWAYS monitor costs
✅ ALWAYS respect privacy settings

=== VALIDATION CHECKLIST ===
□ API keys configured securely
□ Local fallback working
□ Streaming responses implemented
□ Error handling comprehensive
□ Cost tracking in place
□ Privacy controls working
□ Model versioning handled
□ Docker setup documented