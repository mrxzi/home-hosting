# 🚀 Quick Start - Home Hosting System untuk Windows

Panduan cepat untuk setup sistem home hosting di Windows (laptop yang tidak terpakai).

## ⚡ Setup dalam 5 Menit (Windows)

### 1. Persiapan Laptop Windows

```powershell
# Buka PowerShell sebagai Administrator
# Set execution policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# Clone repository
git clone <repository-url> home-hosting
cd home-hosting
```

### 2. Automated Setup

```powershell
# Jalankan setup otomatis untuk Windows
.\setup\install-windows.ps1
```

### 3. Deploy Sistem

```powershell
# Deploy semua services
.\scripts\deploy-windows.ps1
```

### 4. Akses Sistem

Setelah setup selesai, akses sistem melalui:

- **Dashboard**: `http://laptop-ip:3000`
- **Login**: `admin` / `password`
- **SSH**: `ssh username@laptop-ip`
- **RDP**: `mstsc /v:laptop-ip`

## 🤖 Membuat Bot Pertama (Windows)

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

## 📊 Monitoring Sistem (Windows)

### Dashboard Features

- **Bot Management**: Start/stop/restart bots
- **System Monitoring**: CPU, memory, disk usage
- **File Manager**: Upload/download files
- **Real-time Updates**: Status update live

### PowerShell Monitoring

```powershell
# Check system status
.\scripts\monitor-windows.ps1

# View logs
docker-compose logs -f

# Create backup
.\scripts\backup-windows.ps1
```

## 🔧 Konfigurasi Cepat (Windows)

### Environment Variables

```powershell
# Copy example file
Copy-Item env.example .env

# Edit configuration
notepad .env
```

### Windows Firewall Setup

```powershell
# Buka port yang diperlukan
New-NetFirewallRule -DisplayName "Home Hosting Dashboard" -Direction Inbound -Protocol TCP -LocalPort 3000 -Action Allow
New-NetFirewallRule -DisplayName "Home Hosting File Manager" -Direction Inbound -Protocol TCP -LocalPort 8080 -Action Allow
New-NetFirewallRule -DisplayName "Home Hosting Monitoring" -Direction Inbound -Protocol TCP -LocalPort 9090 -Action Allow
```

### Windows Service Setup

```powershell
# Install sebagai Windows Service (run as Administrator)
.\install-service.ps1 Install

# Start service
.\install-service.ps1 Start
```

## 🆘 Troubleshooting (Windows)

### Bot Tidak Start

```powershell
# Check bot logs
docker-compose logs bot-discord-1

# Restart bot
docker-compose restart bot-discord-1
```

### Dashboard Tidak Load

```powershell
# Check dashboard logs
docker-compose logs dashboard

# Restart dashboard
docker-compose restart dashboard
```

### Docker Desktop Tidak Start

```powershell
# Start Docker Desktop
Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"

# Check Docker status
docker info
```

### WSL2 Issues

```powershell
# Check WSL version
wsl --list --verbose

# Update WSL
wsl --update

# Set WSL2 as default
wsl --set-default-version 2
```

## 📋 Useful Commands (Windows)

```powershell
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
.\scripts\update-windows.ps1

# Create backup
.\scripts\backup-windows.ps1

# Check system status
.\scripts\monitor-windows.ps1

# Install as Windows Service
.\install-service.ps1 Install

# Start Windows Service
.\install-service.ps1 Start

# Stop Windows Service
.\install-service.ps1 Stop
```

## 🔐 Security Checklist (Windows)

- [ ] Ganti password default
- [ ] Setup Windows Firewall rules
- [ ] Enable Windows Defender exclusions
- [ ] Update bot tokens
- [ ] Enable SSL (optional)
- [ ] Setup backup schedule
- [ ] Configure Windows Service

## 📞 Support (Windows)

Jika mengalami masalah:

1. Check log files: `.\data\logs\`
2. Run diagnostics: `.\scripts\monitor-windows.ps1`
3. Restart services: `docker-compose restart`
4. Check Windows Firewall: `Get-NetFirewallRule`
5. Check Docker status: `docker info`

## 🎯 Next Steps (Windows)

Setelah setup selesai:

1. **Customize Bots**: Edit bot code di `.\bots\`
2. **Add More Bots**: Deploy bot Discord/Telegram lainnya
3. **Setup Monitoring**: Configure Windows Performance Monitor
4. **Backup Strategy**: Setup automated backups dengan Task Scheduler
5. **Security**: Implement Windows Defender exclusions
6. **Windows Service**: Install sebagai Windows Service untuk auto-start

## 🔧 Windows-Specific Features

### Task Scheduler Integration

```powershell
# Create scheduled task for backup
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File C:\path\to\scripts\backup-windows.ps1"
$trigger = New-ScheduledTaskTrigger -Daily -At 2AM
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
Register-ScheduledTask -Action $action -Trigger $trigger -Settings $settings -TaskName "Home Hosting Backup"
```

### Windows Event Logs

```powershell
# Check application logs
Get-WinEvent -LogName Application | Where-Object {$_.ProviderName -like "*Docker*"}

# Check system logs
Get-WinEvent -LogName System | Where-Object {$_.LevelDisplayName -eq "Error"}
```

### Performance Monitoring

```powershell
# Start Performance Monitor
perfmon

# Check specific counters
Get-Counter "\Processor(_Total)\% Processor Time"
Get-Counter "\Memory\Available MBytes"
```

---

**Selamat! Sistem home hosting Windows Anda sudah siap digunakan! 🎉**

**Tips**: Untuk hasil terbaik, jalankan PowerShell sebagai Administrator dan pastikan Docker Desktop sudah running dengan WSL2 backend enabled.
