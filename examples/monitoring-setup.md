# Monitoring Setup Guide

## Context
You are implementing comprehensive monitoring and observability following Ben's preferences for CloudWatch with EMF, Prometheus/Grafana for local development, and cost-effective solutions.

## Objective
Establish monitoring that provides actionable insights while maintaining low costs and avoiding alert fatigue through intelligent thresholds and aggregation.

## Process

### === MONITORING DECISION TREE ===

```
IF environment == "production":
    THEN: Use CloudWatch with EMF
    AND: Set up critical alerts only
    OUTPUT: AWS-native monitoring

ELIF environment == "local-development":
    THEN: Use Prometheus + Grafana
    AND: Include detailed dashboards
    OUTPUT: Local observability stack

ELIF project_type == "serverless":
    THEN: Use CloudWatch Insights
    AND: X-Ray for tracing
    OUTPUT: Serverless monitoring

ELIF budget_constrained == true:
    THEN: Use minimal CloudWatch
    AND: Aggregate metrics locally
    OUTPUT: Cost-optimized monitoring

ELSE:
    THEN: Use structured logging
    AND: Basic health checks
    OUTPUT: Essential monitoring
```

## Monitoring Patterns

### 1. CloudWatch EMF (Embedded Metric Format)

```typescript
// lib/shared/src/monitoring/metrics.ts
import { Unit } from 'aws-embedded-metrics'
import { createMetricsLogger } from 'aws-embedded-metrics'

export class MetricsService {
  private static instance: MetricsService
  
  static getInstance(): MetricsService {
    if (!MetricsService.instance) {
      MetricsService.instance = new MetricsService()
    }
    return MetricsService.instance
  }

  // ✅ Request metrics
  async recordRequest(
    method: string,
    path: string,
    statusCode: number,
    duration: number
  ) {
    const metrics = createMetricsLogger()
    
    metrics.setNamespace('MyApp/API')
    metrics.setDimensions({ Environment: process.env.NODE_ENV || 'dev' })
    
    metrics.putMetric('RequestCount', 1, Unit.Count)
    metrics.putMetric('RequestDuration', duration, Unit.Milliseconds)
    
    metrics.setProperty('Method', method)
    metrics.setProperty('Path', path)
    metrics.setProperty('StatusCode', statusCode)
    
    // Add custom dimensions for better filtering
    if (statusCode >= 400) {
      metrics.setDimensions({ 
        Environment: process.env.NODE_ENV || 'dev',
        ErrorType: statusCode >= 500 ? 'ServerError' : 'ClientError'
      })
      metrics.putMetric('ErrorCount', 1, Unit.Count)
    }
    
    await metrics.flush()
  }

  // ✅ Business metrics
  async recordBusinessMetric(
    metricName: string,
    value: number,
    unit: Unit = Unit.Count,
    dimensions?: Record<string, string>
  ) {
    const metrics = createMetricsLogger()
    
    metrics.setNamespace('MyApp/Business')
    metrics.setDimensions({
      Environment: process.env.NODE_ENV || 'dev',
      ...dimensions
    })
    
    metrics.putMetric(metricName, value, unit)
    await metrics.flush()
  }

  // ✅ Performance metrics
  async recordPerformance(
    operation: string,
    duration: number,
    success: boolean
  ) {
    const metrics = createMetricsLogger()
    
    metrics.setNamespace('MyApp/Performance')
    metrics.setDimensions({
      Environment: process.env.NODE_ENV || 'dev',
      Operation: operation,
      Success: success.toString()
    })
    
    metrics.putMetric('OperationDuration', duration, Unit.Milliseconds)
    metrics.putMetric('OperationCount', 1, Unit.Count)
    
    if (!success) {
      metrics.putMetric('OperationErrors', 1, Unit.Count)
    }
    
    await metrics.flush()
  }

  // ✅ Resource utilization
  async recordResourceUsage() {
    const metrics = createMetricsLogger()
    const usage = process.memoryUsage()
    
    metrics.setNamespace('MyApp/Resources')
    metrics.setDimensions({
      Environment: process.env.NODE_ENV || 'dev',
      InstanceId: process.env.INSTANCE_ID || 'local'
    })
    
    metrics.putMetric('HeapUsed', usage.heapUsed / 1024 / 1024, Unit.Megabytes)
    metrics.putMetric('HeapTotal', usage.heapTotal / 1024 / 1024, Unit.Megabytes)
    metrics.putMetric('RSS', usage.rss / 1024 / 1024, Unit.Megabytes)
    metrics.putMetric('External', usage.external / 1024 / 1024, Unit.Megabytes)
    
    await metrics.flush()
  }
}

// Usage in API handlers
export function withMetrics(handler: any) {
  return async (req: any, res: any) => {
    const start = Date.now()
    const metrics = MetricsService.getInstance()
    
    try {
      const result = await handler(req, res)
      
      await metrics.recordRequest(
        req.method,
        req.path,
        res.statusCode,
        Date.now() - start
      )
      
      return result
    } catch (error) {
      await metrics.recordRequest(
        req.method,
        req.path,
        500,
        Date.now() - start
      )
      
      throw error
    }
  }
}
```

### 2. Structured Logging with Winston

```typescript
// lib/shared/src/monitoring/logger.ts
import winston from 'winston'
import { Request } from 'express'

// ✅ Log levels with quantitative thresholds
const levels = {
  error: 0,   // System errors, failures
  warn: 1,    // Degraded performance, retries
  info: 2,    // Important business events
  http: 3,    // HTTP requests
  debug: 4    // Detailed debugging
}

// ✅ Custom format for structured logging
const structuredFormat = winston.format.combine(
  winston.format.timestamp(),
  winston.format.errors({ stack: true }),
  winston.format.metadata({ fillExcept: ['message', 'level', 'timestamp'] }),
  winston.format.json()
)

// ✅ Development format for readability
const devFormat = winston.format.combine(
  winston.format.colorize(),
  winston.format.timestamp({ format: 'HH:mm:ss' }),
  winston.format.printf(({ timestamp, level, message, metadata }) => {
    let log = `${timestamp} ${level}: ${message}`
    if (Object.keys(metadata).length > 0) {
      log += ` ${JSON.stringify(metadata, null, 2)}`
    }
    return log
  })
)

// ✅ Create logger instance
export const logger = winston.createLogger({
  level: process.env.LOG_LEVEL || 'info',
  levels,
  format: process.env.NODE_ENV === 'production' ? structuredFormat : devFormat,
  transports: [
    new winston.transports.Console({
      stderrLevels: ['error']
    })
  ],
  exceptionHandlers: [
    new winston.transports.Console()
  ],
  rejectionHandlers: [
    new winston.transports.Console()
  ]
})

// ✅ Request logging middleware
export function requestLogger(req: Request, res: any, next: any) {
  const start = Date.now()
  
  // Log request
  logger.http('Incoming request', {
    method: req.method,
    url: req.url,
    ip: req.ip,
    userAgent: req.get('user-agent')
  })
  
  // Log response
  res.on('finish', () => {
    const duration = Date.now() - start
    
    logger.http('Request completed', {
      method: req.method,
      url: req.url,
      statusCode: res.statusCode,
      duration,
      contentLength: res.get('content-length')
    })
    
    // Warn on slow requests
    if (duration > 1000) {
      logger.warn('Slow request detected', {
        method: req.method,
        url: req.url,
        duration
      })
    }
  })
  
  next()
}

// ✅ Error logging with context
export function logError(error: Error, context?: any) {
  logger.error(error.message, {
    stack: error.stack,
    name: error.name,
    ...context
  })
}

// ✅ Business event logging
export function logBusinessEvent(event: string, data?: any) {
  logger.info(`Business Event: ${event}`, data)
}

// ✅ Performance logging
export function logPerformance(operation: string, duration: number, metadata?: any) {
  const level = duration > 1000 ? 'warn' : 'debug'
  logger.log(level, `Performance: ${operation}`, {
    duration,
    ...metadata
  })
}
```

### 3. Health Checks and Readiness

```typescript
// lib/server/src/monitoring/health.ts
import { FastifyInstance } from 'fastify'
import { PrismaClient } from '@prisma/client'
import { Redis } from 'ioredis'

interface HealthCheckResult {
  status: 'healthy' | 'degraded' | 'unhealthy'
  checks: Record<string, {
    status: 'pass' | 'fail'
    responseTime?: number
    error?: string
    metadata?: any
  }>
  timestamp: string
  uptime: number
}

export class HealthChecker {
  constructor(
    private prisma: PrismaClient,
    private redis?: Redis
  ) {}

  async checkHealth(): Promise<HealthCheckResult> {
    const startTime = process.hrtime()
    const checks: HealthCheckResult['checks'] = {}
    
    // ✅ Database health
    try {
      const dbStart = Date.now()
      await this.prisma.$queryRaw`SELECT 1`
      checks.database = {
        status: 'pass',
        responseTime: Date.now() - dbStart
      }
    } catch (error) {
      checks.database = {
        status: 'fail',
        error: error.message
      }
    }
    
    // ✅ Redis health (if configured)
    if (this.redis) {
      try {
        const redisStart = Date.now()
        await this.redis.ping()
        checks.redis = {
          status: 'pass',
          responseTime: Date.now() - redisStart
        }
      } catch (error) {
        checks.redis = {
          status: 'fail',
          error: error.message
        }
      }
    }
    
    // ✅ Memory health
    const memUsage = process.memoryUsage()
    const maxHeap = 512 * 1024 * 1024 // 512MB threshold
    checks.memory = {
      status: memUsage.heapUsed < maxHeap ? 'pass' : 'fail',
      metadata: {
        heapUsed: Math.round(memUsage.heapUsed / 1024 / 1024),
        heapTotal: Math.round(memUsage.heapTotal / 1024 / 1024),
        rss: Math.round(memUsage.rss / 1024 / 1024),
        external: Math.round(memUsage.external / 1024 / 1024)
      }
    }
    
    // ✅ Disk space (for local apps)
    if (process.env.CHECK_DISK_SPACE === 'true') {
      try {
        const diskSpace = await this.checkDiskSpace()
        checks.disk = {
          status: diskSpace.available > 1024 ? 'pass' : 'fail', // 1GB threshold
          metadata: diskSpace
        }
      } catch (error) {
        checks.disk = {
          status: 'fail',
          error: error.message
        }
      }
    }
    
    // ✅ Calculate overall status
    const failedChecks = Object.values(checks).filter(c => c.status === 'fail')
    const status = failedChecks.length === 0 ? 'healthy' :
                  failedChecks.length === 1 ? 'degraded' : 'unhealthy'
    
    return {
      status,
      checks,
      timestamp: new Date().toISOString(),
      uptime: process.uptime()
    }
  }
  
  private async checkDiskSpace() {
    // Implementation depends on OS
    // This is a placeholder
    return {
      total: 100 * 1024, // MB
      used: 50 * 1024,
      available: 50 * 1024
    }
  }
}

// ✅ Register health endpoints
export function registerHealthEndpoints(app: FastifyInstance, checker: HealthChecker) {
  // Basic health check (for load balancers)
  app.get('/health', async (request, reply) => {
    reply.send({ status: 'ok' })
  })
  
  // Detailed health check
  app.get('/health/detailed', async (request, reply) => {
    const health = await checker.checkHealth()
    
    reply
      .code(health.status === 'healthy' ? 200 : 503)
      .send(health)
  })
  
  // Readiness check (for k8s)
  app.get('/ready', async (request, reply) => {
    const health = await checker.checkHealth()
    
    if (health.status === 'unhealthy') {
      reply.code(503).send({ ready: false })
    } else {
      reply.send({ ready: true })
    }
  })
  
  // Liveness check (for k8s)
  app.get('/live', async (request, reply) => {
    reply.send({ alive: true })
  })
}
```

### 4. Application Performance Monitoring (APM)

```typescript
// lib/shared/src/monitoring/apm.ts
export class PerformanceTracker {
  private timers = new Map<string, number>()
  private metrics = MetricsService.getInstance()
  
  // ✅ Start timing an operation
  startTimer(operationId: string): void {
    this.timers.set(operationId, Date.now())
  }
  
  // ✅ End timing and record metric
  async endTimer(operationId: string, operation: string, success = true): Promise<number> {
    const startTime = this.timers.get(operationId)
    if (!startTime) {
      throw new Error(`No timer found for operation ${operationId}`)
    }
    
    const duration = Date.now() - startTime
    this.timers.delete(operationId)
    
    // Record metric
    await this.metrics.recordPerformance(operation, duration, success)
    
    // Log if slow
    if (duration > 1000) {
      logger.warn(`Slow operation detected: ${operation}`, { duration })
    }
    
    return duration
  }
  
  // ✅ Measure async operation
  async measure<T>(
    operation: string,
    fn: () => Promise<T>
  ): Promise<T> {
    const id = `${operation}-${Date.now()}-${Math.random()}`
    this.startTimer(id)
    
    try {
      const result = await fn()
      await this.endTimer(id, operation, true)
      return result
    } catch (error) {
      await this.endTimer(id, operation, false)
      throw error
    }
  }
  
  // ✅ Create child span for distributed tracing
  createSpan(operationName: string, parentSpan?: any): any {
    // This would integrate with X-Ray or other tracing
    return {
      operationName,
      startTime: Date.now(),
      parentSpan,
      end: async (success = true) => {
        const duration = Date.now() - this.startTime
        await this.metrics.recordPerformance(operationName, duration, success)
      }
    }
  }
}

// ✅ Decorator for automatic performance tracking
export function TrackPerformance(operation: string) {
  return function (target: any, propertyKey: string, descriptor: PropertyDescriptor) {
    const originalMethod = descriptor.value
    
    descriptor.value = async function (...args: any[]) {
      const tracker = new PerformanceTracker()
      return tracker.measure(
        `${target.constructor.name}.${propertyKey}`,
        () => originalMethod.apply(this, args)
      )
    }
    
    return descriptor
  }
}
```

### 5. Local Development Stack (Docker Compose)

```yaml
# docker-compose.monitoring.yml
version: '3.8'

services:
  prometheus:
    image: prom/prometheus:latest
    container_name: prometheus
    volumes:
      - ./monitoring/prometheus.yml:/etc/prometheus/prometheus.yml
      - prometheus_data:/prometheus
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--storage.tsdb.retention.time=7d'
    ports:
      - "9090:9090"
    networks:
      - monitoring

  grafana:
    image: grafana/grafana:latest
    container_name: grafana
    volumes:
      - grafana_data:/var/lib/grafana
      - ./monitoring/grafana/dashboards:/etc/grafana/provisioning/dashboards
      - ./monitoring/grafana/datasources:/etc/grafana/provisioning/datasources
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_USERS_ALLOW_SIGN_UP=false
    ports:
      - "3001:3000"
    networks:
      - monitoring
    depends_on:
      - prometheus

  loki:
    image: grafana/loki:latest
    container_name: loki
    ports:
      - "3100:3100"
    volumes:
      - loki_data:/loki
    command: -config.file=/etc/loki/local-config.yaml
    networks:
      - monitoring

  promtail:
    image: grafana/promtail:latest
    container_name: promtail
    volumes:
      - ./logs:/var/log/app
      - ./monitoring/promtail.yml:/etc/promtail/config.yml
    command: -config.file=/etc/promtail/config.yml
    networks:
      - monitoring
    depends_on:
      - loki

networks:
  monitoring:

volumes:
  prometheus_data:
  grafana_data:
  loki_data:
```

### 6. Prometheus Configuration

```yaml
# monitoring/prometheus.yml
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'app'
    static_configs:
      - targets: ['host.docker.internal:3000']
    metrics_path: '/metrics'
    
  - job_name: 'node-exporter'
    static_configs:
      - targets: ['node-exporter:9100']
```

### 7. Custom Metrics Endpoint

```typescript
// lib/server/src/monitoring/prometheus-metrics.ts
import { Registry, Counter, Histogram, Gauge } from 'prom-client'
import { FastifyInstance } from 'fastify'

export class PrometheusMetrics {
  private registry: Registry
  
  // ✅ Define metrics
  private httpRequestDuration: Histogram<string>
  private httpRequestTotal: Counter<string>
  private activeConnections: Gauge<string>
  private databaseConnectionPool: Gauge<string>
  
  constructor() {
    this.registry = new Registry()
    
    // ✅ HTTP metrics
    this.httpRequestDuration = new Histogram({
      name: 'http_request_duration_seconds',
      help: 'Duration of HTTP requests in seconds',
      labelNames: ['method', 'route', 'status_code'],
      buckets: [0.1, 0.5, 1, 2, 5]
    })
    
    this.httpRequestTotal = new Counter({
      name: 'http_requests_total',
      help: 'Total number of HTTP requests',
      labelNames: ['method', 'route', 'status_code']
    })
    
    // ✅ Connection metrics
    this.activeConnections = new Gauge({
      name: 'active_connections',
      help: 'Number of active connections',
      labelNames: ['type']
    })
    
    this.databaseConnectionPool = new Gauge({
      name: 'database_connection_pool',
      help: 'Database connection pool metrics',
      labelNames: ['state']
    })
    
    // Register metrics
    this.registry.registerMetric(this.httpRequestDuration)
    this.registry.registerMetric(this.httpRequestTotal)
    this.registry.registerMetric(this.activeConnections)
    this.registry.registerMetric(this.databaseConnectionPool)
  }
  
  // ✅ Record HTTP request
  recordHttpRequest(method: string, route: string, statusCode: number, duration: number) {
    const labels = { method, route, status_code: statusCode.toString() }
    this.httpRequestTotal.inc(labels)
    this.httpRequestDuration.observe(labels, duration / 1000) // Convert to seconds
  }
  
  // ✅ Update connection metrics
  updateConnections(type: string, count: number) {
    this.activeConnections.set({ type }, count)
  }
  
  // ✅ Get metrics for endpoint
  async getMetrics(): Promise<string> {
    return this.registry.metrics()
  }
}

// ✅ Register Prometheus endpoint
export function registerPrometheusEndpoint(app: FastifyInstance, metrics: PrometheusMetrics) {
  app.get('/metrics', async (request, reply) => {
    reply
      .header('Content-Type', this.registry.contentType)
      .send(await metrics.getMetrics())
  })
  
  // Add middleware to track requests
  app.addHook('onRequest', async (request, reply) => {
    request.startTime = Date.now()
  })
  
  app.addHook('onResponse', async (request, reply) => {
    const duration = Date.now() - request.startTime
    metrics.recordHttpRequest(
      request.method,
      request.routerPath || request.url,
      reply.statusCode,
      duration
    )
  })
}
```

## Alert Configuration

### CloudWatch Alarms (CDK)

```typescript
// lib/cdk/constructs/alarms.ts
import * as cloudwatch from 'aws-cdk-lib/aws-cloudwatch'
import * as sns from 'aws-cdk-lib/aws-sns'
import * as lambda from 'aws-cdk-lib/aws-lambda'

export function createAlarms(
  lambdaFunction: lambda.Function,
  alertTopic: sns.Topic
) {
  // ✅ Error rate alarm
  new cloudwatch.Alarm(this, 'ErrorRateAlarm', {
    metric: new cloudwatch.MathExpression({
      expression: 'errors / invocations * 100',
      usingMetrics: {
        errors: lambdaFunction.metricErrors(),
        invocations: lambdaFunction.metricInvocations()
      }
    }),
    threshold: 1, // 1% error rate
    evaluationPeriods: 2,
    treatMissingData: cloudwatch.TreatMissingData.NOT_BREACHING
  }).addAlarmAction(new cloudwatch_actions.SnsAction(alertTopic))
  
  // ✅ Duration alarm
  new cloudwatch.Alarm(this, 'DurationAlarm', {
    metric: lambdaFunction.metricDuration({
      statistic: 'p99'
    }),
    threshold: 3000, // 3 seconds
    evaluationPeriods: 2
  }).addAlarmAction(new cloudwatch_actions.SnsAction(alertTopic))
  
  // ✅ Throttles alarm
  new cloudwatch.Alarm(this, 'ThrottlesAlarm', {
    metric: lambdaFunction.metricThrottles(),
    threshold: 10,
    evaluationPeriods: 1
  }).addAlarmAction(new cloudwatch_actions.SnsAction(alertTopic))
}
```

## Best Practices

### ✅ DO
- Use structured logging with correlation IDs
- Set meaningful alert thresholds
- Monitor business metrics, not just technical
- Use sampling for high-volume metrics
- Include context in error logs
- Set up dashboards for different audiences
- Use distributed tracing for complex flows
- Archive logs for compliance

### ⛔ DON'T
- Don't log sensitive data (PII, credentials)
- Don't create noisy alerts
- Don't ignore metric costs
- Don't log everything at debug level
- Don't forget log rotation
- Don't monitor vanity metrics

## Cost Optimization

| Service | Free Tier | Cost Optimization |
|---------|-----------|-------------------|
| CloudWatch Logs | 5GB ingestion | Use log levels, sampling |
| CloudWatch Metrics | 10 custom metrics | Use EMF, batch metrics |
| X-Ray | 100k traces/month | Sample at 10% for high volume |
| CloudWatch Alarms | 10 alarms | Combine related alarms |

Remember: Good monitoring helps you sleep at night. Focus on actionable metrics and alerts that matter.