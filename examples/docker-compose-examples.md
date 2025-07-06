# Docker Compose Patterns

## Context
You are implementing containerized architectures following Ben's preferences for simplicity and Alpine-based images. This guide provides battle-tested Docker Compose patterns for common scenarios.

## Objective
Select and implement the appropriate Docker Compose configuration based on your project archetype while maintaining security, performance, and simplicity.

## Process

### === DECISION TREE ===

```
IF project_type == "local-app":
    THEN: Use single-service compose with SQLite volume
    AND: Include health checks
    OUTPUT: Local development configuration

ELIF project_type == "local-app-with-services":
    THEN: Use multi-service compose
    AND: Add Redis/NATS as needed
    OUTPUT: Full local stack

ELIF project_type == "ml-ai-app":
    THEN: Include GPU support configuration
    AND: Add Jupyter/model serving containers
    OUTPUT: ML development stack

ELIF project_type == "real-time-app":
    THEN: Add WebSocket-capable reverse proxy
    AND: Include message queue service
    OUTPUT: Real-time stack

ELSE:
    THEN: Start with basic web service
    AND: Add services incrementally
    OUTPUT: Extensible configuration
```

## Patterns

### 1. Basic Local App with SQLite

```yaml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
      args:
        NODE_VERSION: 24
    image: myapp:latest
    container_name: myapp
    ports:
      - "3000:3000"
    volumes:
      - ./data:/app/data  # SQLite database location
      - ./uploads:/app/uploads
    environment:
      - NODE_ENV=development
      - DATABASE_URL=file:/app/data/app.db
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    restart: unless-stopped

volumes:
  data:
  uploads:
```

### 2. Full Stack with Services

```yaml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
      target: production
    image: myapp:latest
    container_name: myapp
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://user:pass@postgres:5432/myapp
      - REDIS_URL=redis://redis:6379
      - NATS_URL=nats://nats:4222
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
      nats:
        condition: service_started
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:3000/api/health"]
      interval: 30s
      timeout: 10s
      retries: 3
    restart: unless-stopped

  postgres:
    image: postgres:16-alpine
    container_name: myapp-postgres
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=pass
      - POSTGRES_DB=myapp
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user -d myapp"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    container_name: myapp-redis
    command: redis-server --appendonly yes
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  nats:
    image: nats:2.10-alpine
    container_name: myapp-nats
    command: ["-js", "-sd", "/data"]
    volumes:
      - nats_data:/data
    ports:
      - "4222:4222"  # Client connections
      - "8222:8222"  # HTTP monitoring
    restart: unless-stopped

volumes:
  postgres_data:
  redis_data:
  nats_data:
```

### 3. ML/AI Development Stack

```yaml
version: '3.8'

services:
  app:
    build:
      context: .
      dockerfile: Dockerfile
    image: myapp:latest
    container_name: myapp
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
      - MODEL_SERVICE_URL=http://model-server:8000
      - JUPYTER_URL=http://jupyter:8888
    depends_on:
      - model-server
      - jupyter
    volumes:
      - ./src:/app/src
      - ./models:/app/models
    restart: unless-stopped

  model-server:
    build:
      context: ./ml
      dockerfile: Dockerfile.ml
    image: myapp-ml:latest
    container_name: myapp-model-server
    ports:
      - "8000:8000"
    volumes:
      - ./models:/models
      - model_cache:/root/.cache
    environment:
      - CUDA_VISIBLE_DEVICES=0  # For GPU support
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
    restart: unless-stopped

  jupyter:
    image: jupyter/tensorflow-notebook:latest
    container_name: myapp-jupyter
    ports:
      - "8888:8888"
    volumes:
      - ./notebooks:/home/jovyan/work
      - ./data:/home/jovyan/data
      - ./models:/home/jovyan/models
    environment:
      - JUPYTER_ENABLE_LAB=yes
      - JUPYTER_TOKEN=your-secure-token-here
    restart: unless-stopped

  ollama:
    image: ollama/ollama:latest
    container_name: myapp-ollama
    ports:
      - "11434:11434"
    volumes:
      - ollama_data:/root/.ollama
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: all
              capabilities: [gpu]
    restart: unless-stopped

volumes:
  model_cache:
  ollama_data:
```

### 4. Real-time Collaborative App

```yaml
version: '3.8'

services:
  caddy:
    image: caddy:2-alpine
    container_name: myapp-caddy
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - caddy_data:/data
      - caddy_config:/config
    depends_on:
      - app
    restart: unless-stopped

  app:
    build:
      context: .
      dockerfile: Dockerfile
    image: myapp:latest
    container_name: myapp
    environment:
      - NODE_ENV=production
      - DATABASE_URL=postgresql://user:pass@postgres:5432/myapp
      - REDIS_URL=redis://redis:6379
      - NATS_URL=nats://nats:4222
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
      nats:
        condition: service_started
      yjs-server:
        condition: service_started
    restart: unless-stopped

  yjs-server:
    build:
      context: ./yjs
      dockerfile: Dockerfile
    image: myapp-yjs:latest
    container_name: myapp-yjs
    environment:
      - REDIS_URL=redis://redis:6379
    depends_on:
      - redis
    restart: unless-stopped

  postgres:
    image: postgres:16-alpine
    container_name: myapp-postgres
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=pass
      - POSTGRES_DB=myapp
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U user -d myapp"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  redis:
    image: redis:7-alpine
    container_name: myapp-redis
    command: redis-server --appendonly yes --maxmemory 512mb --maxmemory-policy allkeys-lru
    volumes:
      - redis_data:/data
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  nats:
    image: nats:2.10-alpine
    container_name: myapp-nats
    command: ["-js", "-sd", "/data", "--max_payload", "4MB"]
    volumes:
      - nats_data:/data
    restart: unless-stopped

volumes:
  caddy_data:
  caddy_config:
  postgres_data:
  redis_data:
  nats_data:
```

### 5. Monitoring Stack Addition

```yaml
# Add to any docker-compose.yml
  prometheus:
    image: prom/prometheus:latest
    container_name: myapp-prometheus
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.path=/prometheus'
    ports:
      - "9090:9090"
    restart: unless-stopped

  loki:
    image: grafana/loki:latest
    container_name: myapp-loki
    ports:
      - "3100:3100"
    volumes:
      - loki_data:/loki
    restart: unless-stopped

  grafana:
    image: grafana/grafana:latest
    container_name: myapp-grafana
    ports:
      - "3001:3000"
    volumes:
      - grafana_data:/var/lib/grafana
      - ./grafana/provisioning:/etc/grafana/provisioning
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_USERS_ALLOW_SIGN_UP=false
    depends_on:
      - prometheus
      - loki
    restart: unless-stopped

volumes:
  prometheus_data:
  loki_data:
  grafana_data:
```

## Common Dockerfiles

### Node.js Alpine Multi-stage

```dockerfile
# Build stage
FROM node:24-alpine AS builder

WORKDIR /app

# Install pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

# Copy package files
COPY package.json pnpm-lock.yaml ./
COPY lib/*/package.json ./lib/

# Install dependencies
RUN pnpm install --frozen-lockfile

# Copy source
COPY . .

# Build
RUN pnpm build

# Production stage
FROM node:24-alpine AS production

WORKDIR /app

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

# Create non-root user
RUN addgroup -g 1001 -S nodejs && \
    adduser -S nodejs -u 1001

# Copy built application
COPY --from=builder --chown=nodejs:nodejs /app/dist ./dist
COPY --from=builder --chown=nodejs:nodejs /app/package.json ./
COPY --from=builder --chown=nodejs:nodejs /app/node_modules ./node_modules

# Switch to non-root user
USER nodejs

# Use dumb-init to handle signals
ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "dist/index.js"]

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/api/health', (r) => r.statusCode === 200 ? process.exit(0) : process.exit(1))"
```

## Best Practices

### ✅ DO
- Use Alpine-based images for smaller size
- Include health checks for all services
- Use specific version tags (not `latest` in production)
- Set resource limits for containers
- Use volumes for persistent data
- Run containers as non-root users
- Use multi-stage builds to reduce image size
- Include `dumb-init` or `tini` for proper signal handling

### ⛔ DON'T
- Don't expose unnecessary ports
- Don't store secrets in environment variables (use secrets management)
- Don't use root user in production containers
- Don't ignore health checks
- Don't use host networking unless absolutely necessary

## Debugging Commands

```bash
# View logs
docker-compose logs -f app

# Execute commands in container
docker-compose exec app sh

# Check resource usage
docker stats

# Inspect network
docker network inspect myapp_default

# Clean up everything
docker-compose down -v --remove-orphans
```

## Performance Tuning

### Database Connections
```yaml
environment:
  # Postgres connection pooling
  - DATABASE_URL=postgresql://user:pass@postgres:5432/myapp?pool_max=20&pool_timeout=60

  # Redis connection options
  - REDIS_URL=redis://redis:6379?max_retries=3&retry_delay=500
```

### Memory Limits
```yaml
deploy:
  resources:
    limits:
      cpus: '2'
      memory: 2G
    reservations:
      cpus: '1'
      memory: 1G
```

## Security Considerations

### Network Isolation
```yaml
networks:
  frontend:
    driver: bridge
  backend:
    driver: bridge
    internal: true  # No external access

services:
  app:
    networks:
      - frontend
      - backend
  
  postgres:
    networks:
      - backend  # Only accessible internally
```

### Read-only Filesystem
```yaml
services:
  app:
    read_only: true
    tmpfs:
      - /tmp
      - /app/tmp
    volumes:
      - ./data:/app/data:rw  # Explicitly allow writes
```

Remember: Keep it simple, secure, and maintainable. Start with basic configurations and add complexity only when needed.