=== CONTEXT ===
IoT application archetype for Home Assistant integrations and smart home projects.
Focuses on MQTT communication, device discovery, and automation workflows.

=== OBJECTIVE ===
Build reliable IoT applications that integrate with Home Assistant ecosystem.
Success metrics:
□ <100ms device response time
□ Automatic device discovery working
□ Reliable offline operation
□ Secure communication established
□ Home Assistant UI integration complete

=== TECHNICAL REQUIREMENTS ===
Core Stack:
- MQTT broker (Mosquitto)
- Home Assistant WebSocket API
- Node.js for device/bridge code
- TypeScript for type safety
- PM2 for process management

Protocols:
- MQTT for device communication
- WebSocket for HA integration
- mDNS for discovery
- TLS for security

=== PROJECT STRUCTURE ===
```
./lib/iot-bridge/
  ├── src/
  │   ├── mqtt/          # MQTT client setup
  │   ├── homeassistant/ # HA integration
  │   ├── devices/       # Device handlers
  │   ├── discovery/     # Auto-discovery
  │   └── index.ts       # Main entry
  └── package.json

./config/
  ├── devices.yml        # Device definitions
  └── automations.yml    # Automation rules

./homeassistant/
  ├── custom_components/ # HA custom integration
  └── configuration.yaml # HA config snippets
```

=== MQTT PATTERNS ===
MQTT Client Setup:
```typescript
// mqtt/client.ts
import mqtt from 'mqtt'
import { EventEmitter } from 'events'

export class MQTTClient extends EventEmitter {
  private client: mqtt.MqttClient
  private connected = false
  
  constructor(private config: MQTTConfig) {
    super()
    this.connect()
  }
  
  private connect() {
    this.client = mqtt.connect({
      host: this.config.host || 'localhost',
      port: this.config.port || 1883,
      username: this.config.username,
      password: this.config.password,
      clientId: `iot-bridge-${Date.now()}`,
      clean: true,
      reconnectPeriod: 5000,
      will: {
        topic: 'iot-bridge/status',
        payload: JSON.stringify({ online: false }),
        qos: 1,
        retain: true
      }
    })
    
    this.client.on('connect', () => {
      this.connected = true
      logger.info('MQTT connected')
      
      // Announce online status
      this.publish('iot-bridge/status', { online: true }, { retain: true })
      
      // Subscribe to command topics
      this.client.subscribe('iot-bridge/+/+/set')
      
      this.emit('connected')
    })
    
    this.client.on('message', (topic, payload) => {
      try {
        const message = JSON.parse(payload.toString())
        this.emit('message', topic, message)
      } catch (error) {
        logger.error('Invalid MQTT message', { topic, error })
      }
    })
  }
  
  publish(topic: string, payload: any, options?: mqtt.IClientPublishOptions) {
    if (!this.connected) {
      logger.warn('MQTT not connected, queuing message')
    }
    
    this.client.publish(
      topic,
      JSON.stringify(payload),
      { qos: 1, ...options }
    )
  }
}
```

=== HOME ASSISTANT DISCOVERY ===
Auto-Discovery Protocol:
```typescript
// discovery/ha-discovery.ts
export class HomeAssistantDiscovery {
  constructor(private mqtt: MQTTClient) {}
  
  async announceDevice(device: IoTDevice) {
    const discovery = {
      // Light example
      [`homeassistant/light/${device.id}/config`]: {
        name: device.name,
        unique_id: device.id,
        command_topic: `iot-bridge/${device.id}/light/set`,
        state_topic: `iot-bridge/${device.id}/light/state`,
        schema: 'json',
        brightness: true,
        color_mode: true,
        supported_color_modes: ['rgb', 'color_temp'],
        device: {
          identifiers: [device.id],
          name: device.name,
          model: device.model,
          manufacturer: 'Sammons IoT',
          sw_version: '1.0.0'
        }
      },
      
      // Sensor example
      [`homeassistant/sensor/${device.id}_temperature/config`]: {
        name: `${device.name} Temperature`,
        unique_id: `${device.id}_temperature`,
        state_topic: `iot-bridge/${device.id}/sensor/temperature`,
        device_class: 'temperature',
        unit_of_measurement: '°C',
        value_template: '{{ value_json.temperature }}',
        device: {
          identifiers: [device.id]
        }
      }
    }
    
    // Publish all discovery messages
    for (const [topic, config] of Object.entries(discovery)) {
      this.mqtt.publish(topic, config, { retain: true })
    }
  }
  
  removeDevice(deviceId: string) {
    // Remove by publishing empty retained message
    this.mqtt.publish(
      `homeassistant/light/${deviceId}/config`,
      '',
      { retain: true }
    )
  }
}
```

=== DEVICE HANDLERS ===
Generic Device Class:
```typescript
// devices/base-device.ts
export abstract class BaseDevice {
  protected state: any = {}
  
  constructor(
    protected id: string,
    protected mqtt: MQTTClient,
    protected config: DeviceConfig
  ) {
    this.setupMQTTHandlers()
    this.restoreState()
  }
  
  private setupMQTTHandlers() {
    this.mqtt.on('message', (topic, payload) => {
      const match = topic.match(/iot-bridge\/(.+)\/(.+)\/set/)
      if (match && match[1] === this.id) {
        const domain = match[2]
        this.handleCommand(domain, payload)
      }
    })
  }
  
  protected abstract handleCommand(domain: string, payload: any): Promise<void>
  
  protected async updateState(domain: string, state: any) {
    this.state[domain] = state
    
    // Publish state update
    this.mqtt.publish(
      `iot-bridge/${this.id}/${domain}/state`,
      state
    )
    
    // Persist state
    await this.saveState()
  }
  
  private async saveState() {
    await fs.writeFile(
      `./data/devices/${this.id}.json`,
      JSON.stringify(this.state)
    )
  }
}
```

Smart Light Implementation:
```typescript
// devices/smart-light.ts
export class SmartLight extends BaseDevice {
  async handleCommand(domain: string, payload: any) {
    if (domain !== 'light') return
    
    const newState = {
      state: payload.state || this.state.light?.state || 'OFF',
      brightness: payload.brightness || this.state.light?.brightness || 255,
      color_mode: payload.color_mode || 'color_temp',
      color_temp: payload.color_temp || 250,
      rgb_color: payload.rgb_color || [255, 255, 255]
    }
    
    // Send to actual device (hardware specific)
    await this.sendToDevice(newState)
    
    // Update MQTT state
    await this.updateState('light', newState)
  }
  
  private async sendToDevice(state: any) {
    // Example: Tuya, Zigbee, or custom protocol
    // This is where you'd integrate with actual hardware
  }
}
```

=== HOME ASSISTANT WEBSOCKET ===
WebSocket Integration:
```typescript
// homeassistant/websocket.ts
import WebSocket from 'ws'

export class HomeAssistantWebSocket {
  private ws: WebSocket
  private messageId = 1
  private pendingMessages = new Map()
  
  constructor(private config: HAConfig) {
    this.connect()
  }
  
  private async connect() {
    this.ws = new WebSocket(`ws://${this.config.host}:8123/api/websocket`)
    
    this.ws.on('open', () => {
      logger.info('Connected to Home Assistant')
    })
    
    this.ws.on('message', async (data) => {
      const message = JSON.parse(data.toString())
      
      if (message.type === 'auth_required') {
        await this.authenticate()
      } else if (message.type === 'auth_ok') {
        this.emit('ready')
        await this.subscribeToEvents()
      } else if (message.id && this.pendingMessages.has(message.id)) {
        const resolver = this.pendingMessages.get(message.id)
        resolver(message)
        this.pendingMessages.delete(message.id)
      }
    })
  }
  
  private async authenticate() {
    this.ws.send(JSON.stringify({
      type: 'auth',
      access_token: this.config.token
    }))
  }
  
  async callService(domain: string, service: string, data: any) {
    const id = this.messageId++
    
    return new Promise((resolve) => {
      this.pendingMessages.set(id, resolve)
      
      this.ws.send(JSON.stringify({
        id,
        type: 'call_service',
        domain,
        service,
        service_data: data
      }))
    })
  }
  
  async getStates() {
    const id = this.messageId++
    
    return new Promise((resolve) => {
      this.pendingMessages.set(id, resolve)
      
      this.ws.send(JSON.stringify({
        id,
        type: 'get_states'
      }))
    })
  }
}
```

=== AUTOMATION ENGINE ===
Rule Processing:
```typescript
// automations/engine.ts
export class AutomationEngine {
  private rules: AutomationRule[] = []
  
  constructor(
    private mqtt: MQTTClient,
    private ha: HomeAssistantWebSocket
  ) {
    this.loadRules()
    this.setupTriggers()
  }
  
  private async loadRules() {
    const rulesYaml = await fs.readFile('./config/automations.yml', 'utf8')
    this.rules = yaml.parse(rulesYaml)
  }
  
  private setupTriggers() {
    // MQTT state changes
    this.mqtt.on('message', (topic, payload) => {
      this.checkTriggers('mqtt', { topic, payload })
    })
    
    // Time-based triggers
    setInterval(() => {
      this.checkTriggers('time', { time: new Date() })
    }, 60000) // Check every minute
  }
  
  private async checkTriggers(type: string, data: any) {
    for (const rule of this.rules) {
      if (rule.trigger.platform === type) {
        const triggered = await this.evaluateTrigger(rule.trigger, data)
        
        if (triggered && await this.evaluateConditions(rule.conditions)) {
          await this.executeActions(rule.actions)
        }
      }
    }
  }
  
  private async executeActions(actions: Action[]) {
    for (const action of actions) {
      switch (action.platform) {
        case 'mqtt':
          this.mqtt.publish(action.topic, action.payload)
          break
          
        case 'homeassistant':
          await this.ha.callService(
            action.domain,
            action.service,
            action.data
          )
          break
          
        case 'delay':
          await new Promise(resolve => 
            setTimeout(resolve, action.seconds * 1000)
          )
          break
      }
    }
  }
}
```

=== CONFIGURATION ===
Device Configuration:
```yaml
# config/devices.yml
devices:
  - id: living_room_light
    name: Living Room Light
    type: smart_light
    platform: tuya
    config:
      device_id: xxxxx
      local_key: xxxxx
      ip: 192.168.1.100
    
  - id: temp_sensor_1
    name: Bedroom Temperature
    type: sensor
    platform: zigbee
    config:
      ieee: "0x00124b001234567"
      
  - id: smart_plug_1
    name: Coffee Maker
    type: switch
    platform: mqtt
    config:
      command_topic: tasmota/coffee/cmnd/POWER
      state_topic: tasmota/coffee/stat/POWER
```

Automation Rules:
```yaml
# config/automations.yml
- id: morning_routine
  alias: Morning Coffee
  trigger:
    platform: time
    at: "07:00:00"
  condition:
    - platform: state
      entity_id: device_tracker.phone
      state: home
  action:
    - platform: mqtt
      topic: iot-bridge/smart_plug_1/switch/set
      payload:
        state: "ON"
    - platform: delay
      seconds: 1800
    - platform: mqtt
      topic: iot-bridge/smart_plug_1/switch/set
      payload:
        state: "OFF"
```

=== DEPLOYMENT ===
PM2 Ecosystem:
```javascript
// ecosystem.config.js
module.exports = {
  apps: [{
    name: 'iot-bridge',
    script: './dist/index.js',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '500M',
    env: {
      NODE_ENV: 'production',
      MQTT_HOST: 'localhost',
      HA_HOST: 'localhost',
      HA_TOKEN: process.env.HA_TOKEN
    },
    error_file: './logs/error.log',
    out_file: './logs/out.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss'
  }]
}
```

=== CONSTRAINTS ===
⛔ NEVER hardcode device credentials
⛔ NEVER skip TLS for production MQTT
⛔ NEVER ignore Home Assistant rate limits
⛔ NEVER trust device-reported data
✅ ALWAYS validate MQTT payloads
✅ ALWAYS implement device timeouts
✅ ALWAYS use retained messages for state
✅ ALWAYS handle connection failures

=== VALIDATION CHECKLIST ===
□ MQTT broker connected
□ Devices auto-discovered in HA
□ State updates working bidirectionally
□ Automations triggering correctly
□ Offline operation handling
□ TLS/authentication configured
□ Process monitoring active
□ Logs properly configured