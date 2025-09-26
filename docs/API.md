# API Documentation - Home Hosting System

Dokumentasi lengkap untuk API endpoints sistem home hosting.

## 🔗 Base URL

```
http://laptop-ip:3000/api
```

## 🔐 Authentication

Sistem menggunakan JWT (JSON Web Tokens) untuk authentication.

### Login

```http
POST /api/auth/login
Content-Type: application/json

{
  "username": "admin",
  "password": "password"
}
```

**Response:**
```json
{
  "message": "Login successful",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 1,
    "username": "admin",
    "email": "admin@localhost",
    "role": "admin"
  }
}
```

### Register

```http
POST /api/auth/register
Content-Type: application/json

{
  "username": "newuser",
  "email": "user@example.com",
  "password": "password123"
}
```

### Verify Token

```http
GET /api/auth/verify
Authorization: Bearer <token>
```

## 🤖 Bot Management API

### Get All Bots

```http
GET /api/bots
Authorization: Bearer <token>
```

**Response:**
```json
[
  {
    "id": 1,
    "name": "Discord Bot",
    "type": "discord",
    "status": "running",
    "containerId": "bot-discord-1",
    "port": 3001,
    "createdAt": "2024-01-01T00:00:00.000Z",
    "config": {
      "token": "your-discord-token",
      "prefix": "!",
      "commands": ["ping", "help", "status"]
    }
  }
]
```

### Get Bot by ID

```http
GET /api/bots/:id
Authorization: Bearer <token>
```

### Create New Bot

```http
POST /api/bots
Authorization: Bearer <token>
Content-Type: application/json

{
  "name": "My Discord Bot",
  "type": "discord",
  "config": {
    "token": "your-discord-token",
    "prefix": "!",
    "commands": ["ping", "help"]
  }
}
```

### Start Bot

```http
POST /api/bots/:id/start
Authorization: Bearer <token>
```

**Response:**
```json
{
  "message": "Bot started successfully",
  "bot": {
    "id": 1,
    "status": "running"
  }
}
```

### Stop Bot

```http
POST /api/bots/:id/stop
Authorization: Bearer <token>
```

### Restart Bot

```http
POST /api/bots/:id/restart
Authorization: Bearer <token>
```

### Delete Bot

```http
DELETE /api/bots/:id
Authorization: Bearer <token>
```

### Get Bot Logs

```http
GET /api/bots/:id/logs
Authorization: Bearer <token>
```

**Response:**
```json
{
  "logs": "2024-01-01T00:00:00.000Z Bot started\n2024-01-01T00:01:00.000Z Ready!"
}
```

## 🖥️ System Information API

### Get System Info

```http
GET /api/system/info
Authorization: Bearer <token>
```

**Response:**
```json
{
  "cpu": {
    "manufacturer": "Intel",
    "brand": "Intel(R) Core(TM) i5-8400",
    "cores": 6,
    "physicalCores": 6,
    "speed": 2.8
  },
  "memory": {
    "total": 8589934592,
    "free": 4294967296,
    "used": 4294967296,
    "available": 6442450944
  },
  "disk": [
    {
      "name": "/dev/sda1",
      "size": 500107862016,
      "type": "SSD"
    }
  ],
  "network": [
    {
      "iface": "eth0",
      "ip4": "192.168.1.100",
      "ip6": "::1"
    }
  ]
}
```

### Get System Stats

```http
GET /api/system/stats
Authorization: Bearer <token>
```

**Response:**
```json
{
  "cpu": {
    "load": 15.5,
    "loadAverage": [1.2, 1.5, 1.8]
  },
  "memory": {
    "used": 4294967296,
    "free": 4294967296,
    "percentage": 50.0
  },
  "disk": [
    {
      "device": "/dev/sda1",
      "readIO": 1234,
      "writeIO": 5678
    }
  ],
  "network": [
    {
      "iface": "eth0",
      "rx_bytes": 1024000,
      "tx_bytes": 2048000
    }
  ]
}
```

## 📁 File Management API

### Get File List

```http
GET /api/files?path=./data
Authorization: Bearer <token>
```

**Response:**
```json
[
  {
    "name": "uploads",
    "type": "directory",
    "size": 4096,
    "modified": "2024-01-01T00:00:00.000Z",
    "path": "./data/uploads"
  },
  {
    "name": "config.json",
    "type": "file",
    "size": 1024,
    "modified": "2024-01-01T00:00:00.000Z",
    "path": "./data/config.json"
  }
]
```

### Upload File

```http
POST /api/files/upload
Authorization: Bearer <token>
Content-Type: multipart/form-data

file: <file>
```

**Response:**
```json
{
  "message": "File uploaded successfully",
  "file": {
    "name": "1704067200000-document.pdf",
    "originalName": "document.pdf",
    "size": 1024000,
    "path": "./data/uploads/1704067200000-document.pdf"
  }
}
```

### Download File

```http
GET /api/files/download/:filename
Authorization: Bearer <token>
```

### Delete File

```http
DELETE /api/files/:filename
Authorization: Bearer <token>
```

## 📊 Monitoring API

### Get Container Stats

```http
GET /api/monitoring/containers
Authorization: Bearer <token>
```

**Response:**
```json
[
  {
    "id": "abc123def456",
    "name": "dashboard",
    "status": "running",
    "cpu": {
      "cpu_usage": {
        "total_usage": 1234567890,
        "percpu_usage": [123456789, 123456789]
      }
    },
    "memory": {
      "usage": 52428800,
      "limit": 1073741824
    },
    "network": {
      "eth0": {
        "rx_bytes": 1024000,
        "tx_bytes": 2048000
      }
    }
  }
]
```

### Get System Monitoring

```http
GET /api/monitoring/system
Authorization: Bearer <token>
```

**Response:**
```json
{
  "timestamp": "2024-01-01T00:00:00.000Z",
  "cpu": {
    "load": 15.5,
    "loadAverage": [1.2, 1.5, 1.8]
  },
  "memory": {
    "used": 4294967296,
    "free": 4294967296,
    "percentage": 50.0
  },
  "disk": [
    {
      "device": "/dev/sda1",
      "readIO": 1234,
      "writeIO": 5678
    }
  ],
  "network": [
    {
      "iface": "eth0",
      "rx_bytes": 1024000,
      "tx_bytes": 2048000
    }
  ]
}
```

## 🔌 WebSocket API

Sistem menggunakan WebSocket untuk real-time updates.

### Connection

```javascript
const socket = io('http://laptop-ip:3000');

// Join room for updates
socket.emit('join-room', 'system-updates');
```

### Events

#### Bot Status Update

```javascript
socket.on('bot-status-update', (data) => {
  console.log(`Bot ${data.botId} status: ${data.status}`);
});
```

#### System Stats Update

```javascript
socket.on('system-stats-update', (stats) => {
  console.log('CPU:', stats.cpu.load);
  console.log('Memory:', stats.memory.percentage);
});
```

#### Container Status Update

```javascript
socket.on('container-status-update', (data) => {
  console.log(`Container ${data.name}: ${data.status}`);
});
```

## 📝 Error Handling

### Error Response Format

```json
{
  "error": "Error message",
  "message": "Detailed error description",
  "code": "ERROR_CODE",
  "timestamp": "2024-01-01T00:00:00.000Z"
}
```

### Common Error Codes

- `AUTH_REQUIRED`: Authentication required
- `INVALID_TOKEN`: Invalid or expired token
- `BOT_NOT_FOUND`: Bot not found
- `CONTAINER_ERROR`: Docker container error
- `FILE_NOT_FOUND`: File not found
- `PERMISSION_DENIED`: Insufficient permissions
- `VALIDATION_ERROR`: Request validation failed

### HTTP Status Codes

- `200`: Success
- `201`: Created
- `400`: Bad Request
- `401`: Unauthorized
- `403`: Forbidden
- `404`: Not Found
- `500`: Internal Server Error

## 🔧 Rate Limiting

API menggunakan rate limiting untuk mencegah abuse:

- **Authentication endpoints**: 5 requests per minute
- **Bot management**: 10 requests per minute
- **File operations**: 20 requests per minute
- **Monitoring**: 30 requests per minute

### Rate Limit Headers

```http
X-RateLimit-Limit: 10
X-RateLimit-Remaining: 9
X-RateLimit-Reset: 1640995200
```

## 📋 Example Usage

### JavaScript/Node.js

```javascript
const axios = require('axios');

const api = axios.create({
  baseURL: 'http://laptop-ip:3000/api',
  headers: {
    'Content-Type': 'application/json'
  }
});

// Login
const loginResponse = await api.post('/auth/login', {
  username: 'admin',
  password: 'password'
});

const token = loginResponse.data.token;

// Set authorization header
api.defaults.headers.common['Authorization'] = `Bearer ${token}`;

// Get all bots
const bots = await api.get('/bots');
console.log(bots.data);

// Create new bot
const newBot = await api.post('/bots', {
  name: 'My Bot',
  type: 'discord',
  config: {
    token: 'your-token',
    prefix: '!'
  }
});

// Start bot
await api.post(`/bots/${newBot.data.id}/start`);
```

### Python

```python
import requests
import json

base_url = 'http://laptop-ip:3000/api'

# Login
login_data = {
    'username': 'admin',
    'password': 'password'
}

response = requests.post(f'{base_url}/auth/login', json=login_data)
token = response.json()['token']

headers = {
    'Authorization': f'Bearer {token}',
    'Content-Type': 'application/json'
}

# Get all bots
bots = requests.get(f'{base_url}/bots', headers=headers)
print(bots.json())

# Create new bot
bot_data = {
    'name': 'My Bot',
    'type': 'discord',
    'config': {
        'token': 'your-token',
        'prefix': '!'
    }
}

new_bot = requests.post(f'{base_url}/bots', json=bot_data, headers=headers)
bot_id = new_bot.json()['id']

# Start bot
requests.post(f'{base_url}/bots/{bot_id}/start', headers=headers)
```

### cURL Examples

```bash
# Login
TOKEN=$(curl -s -X POST http://laptop-ip:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"password"}' | jq -r '.token')

# Get all bots
curl -H "Authorization: Bearer $TOKEN" \
  http://laptop-ip:3000/api/bots

# Create new bot
curl -X POST http://laptop-ip:3000/api/bots \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "My Bot",
    "type": "discord",
    "config": {
      "token": "your-token",
      "prefix": "!"
    }
  }'

# Start bot
curl -X POST http://laptop-ip:3000/api/bots/1/start \
  -H "Authorization: Bearer $TOKEN"
```
