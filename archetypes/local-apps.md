=== CONTEXT ===
Local application archetype for self-contained desktop/development tools.
Runs on http://localhost:port with zero external dependencies for core functionality.

=== OBJECTIVE ===
Create fully self-contained application with local-first architecture.
Success metrics:
□ Zero required external services for core features
□ <2 second cold start time
□ All data persisted locally
□ Configuration via UI (not environment variables)

=== TECHNICAL REQUIREMENTS ===
Database:
- SQLite with Node.js 24 built-in support
- Prisma for ORM when needed
- Local file storage for assets

Server Architecture:
- Single Fastify server
- Static files: /static/*
- API routes: /api/*
- No authentication required

UI Requirements:
- Configuration page for any API keys
- Test buttons for external service configs
- Clear success/failure indicators

=== PROJECT STRUCTURE ===
Required directories:
```
./lib/ui          # React frontend
./lib/api         # API handlers  
./lib/server      # Fastify server combining ui+api
./lib/shared-types # Zod schemas
./lib/e2e         # Playwright tests with screenshots
```

Optional (when needed):
```
./docker-compose.yml  # For additional services
./Dockerfile         # For server containerization
```

Additional services (if required):
- Neo4j for graph data
- NATS for queuing
- Caddy for reverse proxy
- Prometheus/Loki/Grafana for observability

=== CONFIGURATION APPROACH ===
External Services:
- ALL credentials via UI configuration
- Store in local SQLite database
- Never use .env for secrets
- Always provide config validation endpoint

Example Config Flow:
1. User visits /settings
2. Enters API key (e.g., OpenAI)
3. Clicks "Test Connection"
4. System validates and stores
5. Shows success/error message

=== CONSTRAINTS ===
⛔ NEVER require environment variables for secrets
⛔ NEVER depend on external services for core features
⛔ NEVER use external authentication
✅ ALWAYS test docker-compose if provided
✅ ALWAYS include config UI for external services
✅ ALWAYS provide offline fallbacks

=== VALIDATION CHECKLIST ===
□ Runs fully offline for core features
□ Config UI implemented for all external services
□ Test buttons functional for all configs
□ SQLite database properly initialized
□ Screenshots captured in E2E tests