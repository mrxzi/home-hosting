# Setup Guide - Home Hosting System untuk Windows

Panduan lengkap untuk setup sistem home hosting di Windows (laptop yang tidak terpakai).

## 📋 Persyaratan Sistem

### Hardware Minimum
- **RAM**: 4GB (8GB recommended)
- **Storage**: 20GB free space
- **Network**: Koneksi internet stabil
- **OS**: Windows 10/11 (64-bit)

### Software Requirements
- **Docker Desktop** dengan WSL2 backend
- **WSL2** (Windows Subsystem for Linux)
- **Node.js** 18+
- **Python** 3.9+
- **Git**
- **PowerShell** 5.1+
- **Chocolatey** (package manager)

## 🚀 Quick Setup untuk Windows

### 1. Persiapan Sistem

```powershell
# Buka PowerShell sebagai Administrator
# Set execution policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# Install Chocolatey (jika belum ada)
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

### 2. Automated Setup

```powershell
# Clone repository
git clone <repository-url> home-hosting
cd home-hosting

# Jalankan setup otomatis
.\setup\install-windows.ps1
```

### 3. Manual Setup (Alternative)

Jika automated setup gagal, lakukan setup manual:

#### Install WSL2
```powershell
# Enable WSL2 features (run as Administrator)
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart

# Restart Windows when prompted
```

#### Install Docker Desktop
```powershell
# Install Docker Desktop via Chocolatey
choco install docker-desktop -y

# Atau download dari: https://www.docker.com/products/docker-desktop
```

#### Install Node.js
```powershell
# Install Node.js via Chocolatey
choco install nodejs -y

# Atau download dari: https://nodejs.org/
```

#### Install Python
```powershell
# Install Python via Chocolatey
choco install python -y

# Atau download dari: https://python.org/
```

#### Install Git
```powershell
# Install Git via Chocolatey
choco install git -y

# Atau download dari: https://git-scm.com/
```

### 4. Setup Remote Access

```powershell
# Install OpenSSH Server
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

# Start and enable SSH service
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'

# Configure Windows Firewall
New-NetFirewallRule -Name sshd -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
```

### 5. Deploy Sistem

```powershell
# Deploy semua services
.\scripts\deploy-windows.ps1
```

## 🔧 Konfigurasi Windows

### Environment Variables

Edit file `.env`:

```powershell
# Copy example file
Copy-Item env.example .env

# Edit configuration
notepad .env
```

### Windows Firewall Configuration

```powershell
# Buka port yang diperlukan
New-NetFirewallRule -DisplayName "Home Hosting Dashboard" -Direction Inbound -Protocol TCP -LocalPort 3000 -Action Allow
New-NetFirewallRule -DisplayName "Home Hosting File Manager" -Direction Inbound -Protocol TCP -LocalPort 8080 -Action Allow
New-NetFirewallRule -DisplayName "Home Hosting Monitoring" -Direction Inbound -Protocol TCP -LocalPort 9090 -Action Allow
New-NetFirewallRule -DisplayName "Home Hosting Bot Manager" -Direction Inbound -Protocol TCP -LocalPort 4000 -Action Allow
New-NetFirewallRule -DisplayName "Home Hosting MongoDB" -Direction Inbound -Protocol TCP -LocalPort 27017 -Action Allow
New-NetFirewallRule -DisplayName "Home Hosting Redis" -Direction Inbound -Protocol TCP -LocalPort 6379 -Action Allow
```

### Windows Service Setup

```powershell
# Install sebagai Windows Service (run as Administrator)
.\install-service.ps1 Install

# Start service
.\install-service.ps1 Start

# Stop service
.\install-service.ps1 Stop

# Uninstall service
.\install-service.ps1 Uninstall
```

## 🤖 Bot Configuration untuk Windows

### Discord Bot

1. Buat aplikasi Discord di [Discord Developer Portal](https://discord.com/developers/applications)
2. Copy bot token
3. Edit `bots\discord\.env`:
   ```
   DISCORD_TOKEN=your-bot-token-here
   BOT_PREFIX=!
   ```

### Telegram Bot

1. Chat dengan [@BotFather](https://t.me/botfather) di Telegram
2. Buat bot baru dan dapatkan token
3. Edit `bots\telegram\.env`:
   ```
   TELEGRAM_TOKEN=your-bot-token-here
   ```

## 🌐 Access URLs untuk Windows

Setelah setup selesai, akses sistem melalui:

- **Dashboard**: `http://laptop-ip:3000`
- **File Manager**: `http://laptop-ip:8080`
- **Monitoring**: `http://laptop-ip:9090`
- **SSH**: `ssh username@laptop-ip`
- **RDP**: `mstsc /v:laptop-ip` (jika RDP enabled)

## 🔐 Default Credentials

### Dashboard Login
- **Username**: `admin`
- **Password**: `password`

### Windows User
- **Username**: `%USERNAME%` (current user)
- **Password**: (Windows user password)

### File Manager
- **Username**: `admin`
- **Password**: `admin123`

## 🛠️ Troubleshooting untuk Windows

### Common Issues

#### Docker Desktop tidak bisa start
```powershell
# Check Docker status
Get-Process "Docker Desktop" -ErrorAction SilentlyContinue

# Start Docker Desktop
Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"

# Check WSL2 integration
docker info
```

#### WSL2 tidak berfungsi
```powershell
# Check WSL version
wsl --list --verbose

# Update WSL
wsl --update

# Set WSL2 as default
wsl --set-default-version 2
```

#### Port sudah digunakan
```powershell
# Check port usage
netstat -an | Select-String ":3000"

# Kill process
Get-Process -Name "node" | Stop-Process -Force
```

#### Services tidak start
```powershell
# Check logs
docker-compose logs

# Restart services
docker-compose restart

# Check Windows Firewall
Get-NetFirewallRule | Where-Object {$_.DisplayName -like "*Home Hosting*"}
```

### Windows-Specific Solutions

#### PowerShell Execution Policy
```powershell
# Set execution policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# Check execution policy
Get-ExecutionPolicy -List
```

#### Windows Defender
```powershell
# Add exclusion for project folder
Add-MpPreference -ExclusionPath "C:\path\to\home-hosting"

# Check exclusions
Get-MpPreference | Select-Object -ExpandProperty ExclusionPath
```

#### Windows Updates
```powershell
# Check for updates
Get-WindowsUpdate

# Install updates
Install-WindowsUpdate -AcceptAll -AutoReboot
```

## 🔄 Updates untuk Windows

Untuk update sistem:

```powershell
# Update otomatis
.\scripts\update-windows.ps1

# Update manual
git pull origin main
docker-compose down
docker-compose build --no-cache
docker-compose up -d
```

## 💾 Backup & Restore untuk Windows

### Create Backup
```powershell
.\scripts\backup-windows.ps1
```

### Restore from Backup
```powershell
# Stop services
docker-compose down

# Extract backup
Expand-Archive -Path "data\backups\home_hosting_backup_YYYYMMDD_HHMMSS.zip" -DestinationPath . -Force

# Start services
docker-compose up -d
```

## 📊 Monitoring untuk Windows

### Windows Performance Monitor
```powershell
# Start Performance Monitor
perfmon

# Check specific counters
Get-Counter "\Processor(_Total)\% Processor Time"
Get-Counter "\Memory\Available MBytes"
Get-Counter "\PhysicalDisk(_Total)\Disk Read Bytes/sec"
```

### Windows Event Logs
```powershell
# Check application logs
Get-WinEvent -LogName Application | Where-Object {$_.ProviderName -like "*Docker*"}

# Check system logs
Get-WinEvent -LogName System | Where-Object {$_.LevelDisplayName -eq "Error"}
```

## 🔒 Security untuk Windows

### Windows Defender
```powershell
# Check Defender status
Get-MpComputerStatus

# Run quick scan
Start-MpScan -ScanType QuickScan

# Update definitions
Update-MpSignature
```

### Windows Firewall
```powershell
# Check firewall status
Get-NetFirewallProfile

# Check rules
Get-NetFirewallRule | Where-Object {$_.DisplayName -like "*Home Hosting*"}
```

### User Account Control (UAC)
```powershell
# Check UAC status
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA"

# Disable UAC (not recommended)
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" -Name "EnableLUA" -Value 0
```

## 📞 Support untuk Windows

### Getting Help

1. **Check Logs**
   - Application logs: `.\data\logs\`
   - Docker logs: `docker-compose logs`
   - Windows Event Logs: `eventvwr.msc`

2. **Run Diagnostics**
   ```powershell
   # System status
   .\scripts\monitor-windows.ps1
   
   # Service health
   Invoke-WebRequest -Uri "http://localhost:3000/health"
   ```

3. **Common Commands**
   ```powershell
   # Restart all services
   docker-compose restart
   
   # View service status
   docker-compose ps
   
   # Create backup
   .\scripts\backup-windows.ps1
   ```

### Windows-Specific Resources

- **Docker Desktop Documentation**: https://docs.docker.com/desktop/windows/
- **WSL2 Documentation**: https://docs.microsoft.com/en-us/windows/wsl/
- **PowerShell Documentation**: https://docs.microsoft.com/en-us/powershell/
- **Windows Firewall**: https://docs.microsoft.com/en-us/windows/security/threat-protection/windows-firewall/

## 🎯 Windows-Specific Tips

### Performance Optimization
```powershell
# Disable Windows Search indexing for project folder
Add-MpPreference -ExclusionPath "C:\path\to\home-hosting"

# Set high performance power plan
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
```

### Startup Configuration
```powershell
# Add to Windows startup
$startupPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
Copy-Item "start-hosting.ps1" "$startupPath\Home Hosting.lnk"
```

### Remote Desktop
```powershell
# Enable Remote Desktop
Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
```

---

**Selamat! Sistem home hosting Windows Anda sudah siap digunakan! 🎉**
