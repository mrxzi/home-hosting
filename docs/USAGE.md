# Usage Guide - Home Hosting System

Panduan penggunaan sistem home hosting untuk mengelola bot dan aplikasi.

## 🏠 Dashboard Overview

Dashboard adalah interface utama untuk mengelola sistem home hosting. Akses melalui `http://laptop-ip:3000`.

### Main Features

- **Bot Management**: Kelola Discord, Telegram, dan bot lainnya
- **System Monitoring**: Monitor CPU, memory, disk usage
- **File Manager**: Upload, download, dan kelola file
- **Container Management**: Kelola Docker containers
- **Real-time Updates**: Status update real-time via WebSocket

## 🤖 Bot Management

### Creating a New Bot

1. **Login ke Dashboard**
   - Username: `admin`
   - Password: `password`

2. **Navigate ke Bot Management**
   - Klik menu "Bots" di sidebar
   - Klik tombol "Create New Bot"

3. **Configure Bot**
   ```
   Bot Name: My Discord Bot
   Bot Type: discord
   Token: your-discord-bot-token
   Prefix: !
   ```

4. **Deploy Bot**
   - Klik "Create Bot"
   - Sistem akan membuat Docker container
   - Bot akan otomatis start

### Managing Existing Bots

#### Start/Stop Bot
- Klik tombol "Start" atau "Stop" di bot list
- Status akan update real-time

#### View Bot Logs
- Klik "Logs" button di bot card
- Logs akan ditampilkan dalam modal

#### Edit Bot Configuration
- Klik "Edit" button
- Update token atau konfigurasi lainnya
- Klik "Save Changes"

#### Delete Bot
- Klik "Delete" button
- Konfirmasi penghapusan
- Container akan dihapus

### Bot Types Supported

#### Discord Bot
- **Features**: Commands, embeds, reactions
- **Commands**: `/ping`, `/help`, `/status`, `/info`
- **Configuration**: Token, prefix, owner ID

#### Telegram Bot
- **Features**: Commands, inline keyboards, file sharing
- **Commands**: `/start`, `/help`, `/status`, `/info`
- **Configuration**: Token, webhook URL

#### Custom Bot
- **Features**: Custom implementation
- **Configuration**: Environment variables, custom ports

## 📊 System Monitoring

### Real-time Metrics

Dashboard menampilkan metrics real-time:

- **CPU Usage**: Current load dan load average
- **Memory Usage**: Used, free, dan percentage
- **Disk Usage**: Space available dan used
- **Network Stats**: Incoming/outgoing traffic

### Container Monitoring

- **Container Status**: Running, stopped, restarting
- **Resource Usage**: CPU, memory per container
- **Logs**: Real-time log streaming
- **Health Checks**: Automatic health monitoring

## 📁 File Management

### Upload Files

1. **Navigate ke File Manager**
   - Klik menu "Files" di sidebar
   - Atau akses langsung: `http://laptop-ip:8080`

2. **Upload File**
   - Drag & drop file ke upload area
   - Atau klik "Upload" button
   - File akan tersimpan di `./data/uploads/`

### Manage Files

- **View Files**: Browse file structure
- **Download Files**: Klik nama file untuk download
- **Delete Files**: Klik tombol delete
- **Create Folders**: Klik "New Folder"

### File Types Supported

- **Bot Scripts**: `.js`, `.py`, `.ts`
- **Config Files**: `.json`, `.yaml`, `.env`
- **Media Files**: `.jpg`, `.png`, `.mp4`, `.mp3`
- **Documents**: `.pdf`, `.txt`, `.md`

## 🔧 Advanced Configuration

### Environment Variables

Edit file `.env` untuk konfigurasi sistem:

```bash
# Database Configuration
MONGODB_URI=mongodb://admin:hosting123@localhost:27017
REDIS_URL=redis://localhost:6379

# Dashboard Configuration
DASHBOARD_PORT=3000
DASHBOARD_SECRET=your-secret-key-here

# Bot Manager Configuration
BOT_MANAGER_PORT=4000

# File Manager Configuration
FILE_MANAGER_PORT=8080

# SSL Configuration (optional)
SSL_CERT_PATH=./server/ssl/cert.pem
SSL_KEY_PATH=./server/ssl/key.pem
```

### Custom Bot Development

#### Discord Bot Template

```javascript
const { Client, GatewayIntentBits } = require('discord.js');

const client = new Client({
  intents: [GatewayIntentBits.Guilds, GatewayIntentBits.GuildMessages]
});

client.on('ready', () => {
  console.log(`Bot ready as ${client.user.tag}`);
});

client.on('messageCreate', (message) => {
  if (message.content === '!ping') {
    message.reply('Pong!');
  }
});

client.login(process.env.DISCORD_TOKEN);
```

#### Telegram Bot Template

```javascript
const TelegramBot = require('node-telegram-bot-api');

const bot = new TelegramBot(process.env.TELEGRAM_TOKEN, { polling: true });

bot.onText(/\/start/, (msg) => {
  bot.sendMessage(msg.chat.id, 'Hello! Bot is running.');
});

bot.onText(/\/ping/, (msg) => {
  bot.sendMessage(msg.chat.id, 'Pong!');
});
```

## 🌐 Remote Access

### SSH Access

```bash
# Connect ke laptop hosting
ssh hosting-user@laptop-ip

# Run commands remotely
ssh hosting-user@laptop-ip "docker-compose ps"
```

### VNC Access

1. **Install VNC Client**
   - Windows: RealVNC Viewer
   - Mac: Built-in Screen Sharing
   - Linux: TigerVNC

2. **Connect**
   - Host: `laptop-ip:5901`
   - Username: `hosting-user`
   - Password: (set saat setup)

### Web Access

- **Dashboard**: `http://laptop-ip:3000`
- **File Manager**: `http://laptop-ip:8080`
- **Monitoring**: `http://laptop-ip:9090`

## 🔄 Automation

### Scheduled Tasks

Sistem menggunakan cron jobs untuk automation:

```bash
# Update bot status setiap 30 detik
*/30 * * * * * - Update bot statuses

# Backup harian jam 2 pagi
0 2 * * * - Daily backup

# Cleanup logs mingguan
0 0 * * 0 - Weekly log cleanup
```

### Custom Scripts

#### Backup Script
```bash
# Manual backup
./scripts/backup.sh

# Automated backup (daily)
0 2 * * * /path/to/scripts/backup.sh
```

#### Monitoring Script
```bash
# Check system status
./scripts/monitor.sh

# Automated monitoring (every 5 minutes)
*/5 * * * * /path/to/scripts/monitor.sh
```

#### Update Script
```bash
# Update system
./scripts/update.sh
```

## 🛡️ Security Best Practices

### Password Security

1. **Change Default Passwords**
   ```bash
   # Change dashboard password
   # Login ke dashboard dan update password
   
   # Change SSH password
   sudo passwd hosting-user
   ```

2. **Use SSH Keys**
   ```bash
   # Generate SSH key
   ssh-keygen -t rsa -b 4096
   
   # Copy public key to server
   ssh-copy-id hosting-user@laptop-ip
   ```

### Network Security

1. **Firewall Configuration**
   ```bash
   # Only allow necessary ports
   sudo ufw allow 22/tcp    # SSH
   sudo ufw allow 3000/tcp # Dashboard
   sudo ufw deny 8080/tcp  # File Manager (optional)
   ```

2. **SSL Certificates**
   ```bash
   # Generate self-signed certificate
   openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.pem -days 365 -nodes
   ```

### Regular Maintenance

1. **System Updates**
   ```bash
   # Update system packages
   sudo apt update && sudo apt upgrade -y
   
   # Update Docker images
   docker-compose pull
   docker-compose up -d
   ```

2. **Log Rotation**
   ```bash
   # Configure logrotate
   sudo nano /etc/logrotate.d/home-hosting
   ```

3. **Backup Verification**
   ```bash
   # Test backup restoration
   tar -tzf data/backups/latest_backup.tar.gz
   ```

## 🆘 Troubleshooting

### Common Issues

#### Bot Not Starting
```bash
# Check bot logs
docker-compose logs bot-discord-1

# Check bot configuration
cat bots/discord/.env

# Restart bot
docker-compose restart bot-discord-1
```

#### Dashboard Not Loading
```bash
# Check dashboard logs
docker-compose logs dashboard

# Check port availability
netstat -tuln | grep :3000

# Restart dashboard
docker-compose restart dashboard
```

#### High Resource Usage
```bash
# Check resource usage
./scripts/monitor.sh

# Check running processes
docker stats

# Restart services
docker-compose restart
```

### Performance Optimization

1. **Resource Limits**
   ```yaml
   # docker-compose.yml
   services:
     bot-discord-1:
       deploy:
         resources:
           limits:
             memory: 512M
             cpus: '0.5'
   ```

2. **Log Management**
   ```bash
   # Limit log size
   docker-compose logs --tail=100
   
   # Clean old logs
   docker system prune -f
   ```

3. **Database Optimization**
   ```bash
   # MongoDB optimization
   docker-compose exec mongodb mongosh --eval "db.runCommand({compact: 'collection_name'})"
   ```

## 📞 Support

### Getting Help

1. **Check Logs**
   - Application logs: `./data/logs/`
   - Docker logs: `docker-compose logs`
   - System logs: `/var/log/syslog`

2. **Run Diagnostics**
   ```bash
   # System status
   ./scripts/monitor.sh
   
   # Service health
   curl http://localhost:3000/health
   ```

3. **Common Commands**
   ```bash
   # Restart all services
   docker-compose restart
   
   # View service status
   docker-compose ps
   
   # Create backup
   ./scripts/backup.sh
   ```

### Useful Resources

- **Docker Documentation**: https://docs.docker.com/
- **Discord.js Guide**: https://discordjs.guide/
- **Telegram Bot API**: https://core.telegram.org/bots/api
- **Node.js Documentation**: https://nodejs.org/docs/
