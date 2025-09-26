# Setup Guide - Home Hosting System

Panduan lengkap untuk setup sistem home hosting di laptop yang tidak terpakai.

## 📋 Persyaratan Sistem

### Hardware Minimum
- **RAM**: 4GB (8GB recommended)
- **Storage**: 20GB free space
- **Network**: Koneksi internet stabil
- **OS**: Ubuntu 20.04+ atau Windows dengan WSL2

### Software Requirements
- Docker & Docker Compose
- Node.js 18+
- Python 3.9+
- Git
- SSH Server
- VNC Server (optional)

## 🚀 Quick Setup

### 1. Persiapan Laptop Hosting

```bash
# Update sistem
sudo apt update && sudo apt upgrade -y

# Install dependencies
sudo apt install -y curl wget git unzip software-properties-common

# Clone repository
git clone <repository-url> home-hosting
cd home-hosting
```

### 2. Automated Setup

```bash
# Jalankan script setup otomatis
chmod +x setup/install.sh
./setup/install.sh
```

### 3. Manual Setup (Alternative)

Jika automated setup gagal, lakukan setup manual:

#### Install Docker
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

#### Install Docker Compose
```bash
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

#### Install Node.js
```bash
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs
```

### 4. Setup Remote Access

```bash
# Setup SSH dan VNC
chmod +x setup/remote-access-setup.sh
./setup/remote-access-setup.sh
```

### 5. Deploy Sistem

```bash
# Deploy semua services
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

## 🔧 Konfigurasi

### Environment Variables

Edit file `.env`:

```bash
# Database
MONGODB_URI=mongodb://admin:hosting123@localhost:27017
REDIS_URL=redis://localhost:6379

# Dashboard
DASHBOARD_PORT=3000
DASHBOARD_SECRET=your-secret-key-here

# Bot Manager
BOT_MANAGER_PORT=4000

# File Manager
FILE_MANAGER_PORT=8080

# SSL (optional)
SSL_CERT_PATH=./server/ssl/cert.pem
SSL_KEY_PATH=./server/ssl/key.pem
```

### Firewall Configuration

```bash
# Buka port yang diperlukan
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw allow 3000/tcp  # Dashboard
sudo ufw allow 8080/tcp  # File Manager
sudo ufw allow 9090/tcp  # Monitoring
sudo ufw --force enable
```

## 🤖 Bot Configuration

### Discord Bot

1. Buat aplikasi Discord di [Discord Developer Portal](https://discord.com/developers/applications)
2. Copy bot token
3. Edit `bots/discord/.env`:
   ```
   DISCORD_TOKEN=your-bot-token-here
   BOT_PREFIX=!
   ```

### Telegram Bot

1. Chat dengan [@BotFather](https://t.me/botfather) di Telegram
2. Buat bot baru dan dapatkan token
3. Edit `bots/telegram/.env`:
   ```
   TELEGRAM_TOKEN=your-bot-token-here
   ```

## 🌐 Access URLs

Setelah setup selesai, akses sistem melalui:

- **Dashboard**: `http://laptop-ip:3000`
- **File Manager**: `http://laptop-ip:8080`
- **Monitoring**: `http://laptop-ip:9090`
- **SSH**: `ssh hosting-user@laptop-ip`
- **VNC**: Connect ke `laptop-ip:5901`

## 🔐 Default Credentials

### Dashboard Login
- **Username**: `admin`
- **Password**: `password`

### SSH Access
- **Username**: `hosting-user`
- **Password**: (setelah setup)

### File Manager
- **Username**: `admin`
- **Password**: `admin123`

## 🛠️ Troubleshooting

### Common Issues

#### Docker tidak bisa start
```bash
# Check Docker status
sudo systemctl status docker

# Restart Docker
sudo systemctl restart docker

# Check permissions
sudo usermod -aG docker $USER
```

#### Port sudah digunakan
```bash
# Check port usage
sudo netstat -tuln | grep :3000

# Kill process
sudo kill -9 <PID>
```

#### Services tidak start
```bash
# Check logs
docker-compose logs

# Restart services
docker-compose restart
```

### Log Files

- **Application logs**: `./data/logs/`
- **Docker logs**: `docker-compose logs`
- **System logs**: `/var/log/syslog`

## 📞 Support

Jika mengalami masalah:

1. Check log files
2. Jalankan `./scripts/monitor.sh` untuk status
3. Restart services: `docker-compose restart`
4. Check network connectivity
5. Verify firewall settings

## 🔄 Updates

Untuk update sistem:

```bash
# Update otomatis
./scripts/update.sh

# Update manual
git pull origin main
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

## 💾 Backup & Restore

### Create Backup
```bash
./scripts/backup.sh
```

### Restore from Backup
```bash
# Stop services
docker-compose down

# Extract backup
tar -xzf data/backups/home_hosting_backup_YYYYMMDD_HHMMSS.tar.gz

# Start services
docker-compose up -d
```
