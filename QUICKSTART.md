# 🚀 Quick Start - Home Hosting System

Panduan cepat untuk setup sistem home hosting di laptop yang tidak terpakai.

## ⚡ Setup dalam 5 Menit

### 1. Persiapan Laptop Hosting

```bash
# Update sistem
sudo apt update && sudo apt upgrade -y

# Clone repository
git clone <repository-url> home-hosting
cd home-hosting
```

### 2. Automated Setup

```bash
# Jalankan setup otomatis
chmod +x setup/install.sh
./setup/install.sh
```

### 3. Deploy Sistem

```bash
# Deploy semua services
chmod +x scripts/deploy.sh
./scripts/deploy.sh
```

### 4. Akses Sistem

Setelah setup selesai, akses sistem melalui:

- **Dashboard**: `http://laptop-ip:3000`
- **Login**: `admin` / `password`
- **SSH**: `ssh hosting-user@laptop-ip`
- **VNC**: Connect ke `laptop-ip:5901`

## 🤖 Membuat Bot Pertama

### Discord Bot

1. **Buat Bot di Discord**
   - Buka [Discord Developer Portal](https://discord.com/developers/applications)
   - Klik "New Application" → "Bot" → Copy token

2. **Deploy Bot**
   - Login ke dashboard
   - Klik "Create New Bot"
   - Pilih type: "discord"
   - Masukkan token
   - Klik "Create Bot"

3. **Start Bot**
   - Klik tombol "Start" di bot list
   - Bot akan otomatis online di Discord

### Telegram Bot

1. **Buat Bot di Telegram**
   - Chat dengan [@BotFather](https://t.me/botfather)
   - Ketik `/newbot` → Follow instructions
   - Copy token

2. **Deploy Bot**
   - Login ke dashboard
   - Klik "Create New Bot"
   - Pilih type: "telegram"
   - Masukkan token
   - Klik "Create Bot"

3. **Start Bot**
   - Klik tombol "Start" di bot list
   - Bot akan otomatis online di Telegram

## 📊 Monitoring Sistem

### Dashboard Features

- **Bot Management**: Start/stop/restart bots
- **System Monitoring**: CPU, memory, disk usage
- **File Manager**: Upload/download files
- **Real-time Updates**: Status update live

### Command Line Monitoring

```bash
# Check system status
./scripts/monitor.sh

# View logs
docker-compose logs -f

# Create backup
./scripts/backup.sh
```

## 🔧 Konfigurasi Cepat

### Environment Variables

Edit file `.env`:

```bash
# Copy example file
cp env.example .env

# Edit configuration
nano .env
```

### Firewall Setup

```bash
# Buka port yang diperlukan
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 3000/tcp # Dashboard
sudo ufw allow 8080/tcp # File Manager
sudo ufw --force enable
```

## 🆘 Troubleshooting

### Bot Tidak Start

```bash
# Check bot logs
docker-compose logs bot-discord-1

# Restart bot
docker-compose restart bot-discord-1
```

### Dashboard Tidak Load

```bash
# Check dashboard logs
docker-compose logs dashboard

# Restart dashboard
docker-compose restart dashboard
```

### Port Sudah Digunakan

```bash
# Check port usage
sudo netstat -tuln | grep :3000

# Kill process
sudo kill -9 <PID>
```

## 📋 Useful Commands

```bash
# Start all services
docker-compose up -d

# Stop all services
docker-compose down

# Restart all services
docker-compose restart

# View service status
docker-compose ps

# View logs
docker-compose logs -f

# Update system
./scripts/update.sh

# Create backup
./scripts/backup.sh

# Check system status
./scripts/monitor.sh
```

## 🔐 Security Checklist

- [ ] Ganti password default
- [ ] Setup SSH keys
- [ ] Configure firewall
- [ ] Update bot tokens
- [ ] Enable SSL (optional)
- [ ] Setup backup schedule

## 📞 Support

Jika mengalami masalah:

1. Check log files: `./data/logs/`
2. Run diagnostics: `./scripts/monitor.sh`
3. Restart services: `docker-compose restart`
4. Check network: `ping laptop-ip`

## 🎯 Next Steps

Setelah setup selesai:

1. **Customize Bots**: Edit bot code di `./bots/`
2. **Add More Bots**: Deploy bot Discord/Telegram lainnya
3. **Setup Monitoring**: Configure alerts dan notifications
4. **Backup Strategy**: Setup automated backups
5. **Security**: Implement SSL dan security measures

---

**Selamat! Sistem home hosting Anda sudah siap digunakan! 🎉**
