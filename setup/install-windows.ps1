# Home Hosting Setup Script for Windows
# Script untuk setup awal sistem home hosting di Windows

param(
    [switch]$SkipDocker,
    [switch]$SkipWSL,
    [switch]$Force
)

# Set execution policy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force

# Colors untuk output
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"
$Blue = "Blue"
$White = "White"

function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor $Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor $Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor $Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor $Red
}

Write-Host "🚀 Starting Home Hosting System Setup for Windows..." -ForegroundColor $Green
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-Warning "Script tidak dijalankan sebagai Administrator. Beberapa fitur mungkin tidak berfungsi."
    Write-Host "Untuk hasil terbaik, jalankan PowerShell sebagai Administrator." -ForegroundColor $Yellow
    Write-Host ""
}

# Check Windows version
$osVersion = [System.Environment]::OSVersion.Version
Write-Status "Windows Version: $($osVersion.Major).$($osVersion.Minor)"

# Install Chocolatey if not present
Write-Status "Checking Chocolatey package manager..."
if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
    Write-Status "Installing Chocolatey..."
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        Write-Success "Chocolatey installed successfully"
    } catch {
        Write-Error "Failed to install Chocolatey: $($_.Exception.Message)"
        exit 1
    }
} else {
    Write-Success "Chocolatey already installed"
}

# Install WSL2 if not present
if (-not $SkipWSL) {
    Write-Status "Checking WSL2..."
    if (-not (Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -ErrorAction SilentlyContinue | Where-Object {$_.State -eq "Enabled"})) {
        Write-Status "Installing WSL2..."
        try {
            if ($isAdmin) {
                Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart
                Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart
                Write-Success "WSL2 features enabled. Please restart Windows when prompted."
            } else {
                Write-Warning "WSL2 installation requires Administrator privileges. Please run as Administrator."
            }
        } catch {
            Write-Error "Failed to install WSL2: $($_.Exception.Message)"
        }
    } else {
        Write-Success "WSL2 already installed"
    }
}

# Install Docker Desktop
if (-not $SkipDocker) {
    Write-Status "Checking Docker Desktop..."
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) {
        Write-Status "Installing Docker Desktop..."
        try {
            choco install docker-desktop -y
            Write-Success "Docker Desktop installed successfully"
            Write-Warning "Please restart Docker Desktop and enable WSL2 integration"
        } catch {
            Write-Error "Failed to install Docker Desktop: $($_.Exception.Message)"
        }
    } else {
        Write-Success "Docker already installed"
    }
}

# Install Node.js
Write-Status "Checking Node.js..."
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Status "Installing Node.js..."
    try {
        choco install nodejs -y
        Write-Success "Node.js installed successfully"
    } catch {
        Write-Error "Failed to install Node.js: $($_.Exception.Message)"
    }
} else {
    Write-Success "Node.js already installed"
}

# Install Python
Write-Status "Checking Python..."
if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    Write-Status "Installing Python..."
    try {
        choco install python -y
        Write-Success "Python installed successfully"
    } catch {
        Write-Error "Failed to install Python: $($_.Exception.Message)"
    }
} else {
    Write-Success "Python already installed"
}

# Install Git
Write-Status "Checking Git..."
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Status "Installing Git..."
    try {
        choco install git -y
        Write-Success "Git installed successfully"
    } catch {
        Write-Error "Failed to install Git: $($_.Exception.Message)"
    }
} else {
    Write-Success "Git already installed"
}

# Install OpenSSH Server
Write-Status "Checking OpenSSH Server..."
if (-not (Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH.Server*' | Where-Object State -eq 'Installed')) {
    Write-Status "Installing OpenSSH Server..."
    try {
        if ($isAdmin) {
            Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
            Start-Service sshd
            Set-Service -Name sshd -StartupType 'Automatic'
            Write-Success "OpenSSH Server installed and started"
        } else {
            Write-Warning "OpenSSH Server installation requires Administrator privileges"
        }
    } catch {
        Write-Error "Failed to install OpenSSH Server: $($_.Exception.Message)"
    }
} else {
    Write-Success "OpenSSH Server already installed"
}

# Create directories
Write-Status "Creating directories..."
$directories = @(
    "data\bots",
    "data\logs", 
    "data\backups",
    "data\uploads",
    "server\config\nginx",
    "server\config\mongodb",
    "server\config\prometheus",
    "server\config\filebrowser",
    "server\ssl",
    "dashboard\data",
    "dashboard\logs",
    "bots\discord",
    "bots\telegram",
    "bots\slack"
)

foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Status "Created directory: $dir"
    }
}

# Create environment file
Write-Status "Creating environment file..."
$envContent = @"
# Home Hosting System Environment Configuration
MONGODB_URI=mongodb://admin:hosting123@localhost:27017
REDIS_URL=redis://localhost:6379

# Dashboard Configuration
DASHBOARD_PORT=3000
DASHBOARD_SECRET=your-secret-key-here-change-this
JWT_SECRET=your-jwt-secret-key-here

# Bot Manager Configuration
BOT_MANAGER_PORT=4000

# File Manager Configuration
FILE_MANAGER_PORT=8080

# System Configuration
NODE_ENV=production
LOG_LEVEL=info

# Security Configuration
DEFAULT_ADMIN_USERNAME=admin
DEFAULT_ADMIN_PASSWORD=password
DEFAULT_ADMIN_EMAIL=admin@localhost

# Network Configuration
INTERNAL_IP=
EXTERNAL_IP=

# Docker Configuration
DOCKER_SOCKET_PATH=/var/run/docker.sock
DOCKER_NETWORK=home-hosting-network
"@

$envContent | Out-File -FilePath ".env" -Encoding UTF8
Write-Success "Environment file created"

# Create startup script
Write-Status "Creating startup script..."
$startupScript = @"
# Home Hosting System Startup Script for Windows
Write-Host "🚀 Starting Home Hosting System..." -ForegroundColor Green

# Check if Docker is running
if (-not (Get-Process "Docker Desktop" -ErrorAction SilentlyContinue)) {
    Write-Host "Starting Docker Desktop..." -ForegroundColor Yellow
    Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"
    Start-Sleep -Seconds 30
}

# Start services
Write-Host "Starting services..." -ForegroundColor Blue
docker-compose up -d

Write-Host "✅ Home Hosting System started!" -ForegroundColor Green
Write-Host "📊 Dashboard: http://localhost:3000" -ForegroundColor Cyan
Write-Host "📁 File Manager: http://localhost:8080" -ForegroundColor Cyan
Write-Host "📈 Monitoring: http://localhost:9090" -ForegroundColor Cyan
"@

$startupScript | Out-File -FilePath "start-hosting.ps1" -Encoding UTF8
Write-Success "Startup script created"

# Create stop script
$stopScript = @"
# Home Hosting System Stop Script for Windows
Write-Host "🛑 Stopping Home Hosting System..." -ForegroundColor Yellow

docker-compose down

Write-Host "✅ Home Hosting System stopped!" -ForegroundColor Green
"@

$stopScript | Out-File -FilePath "stop-hosting.ps1" -Encoding UTF8
Write-Success "Stop script created"

# Create Windows service
Write-Status "Creating Windows service..."
$serviceScript = @"
# Windows Service for Home Hosting System
# Run this as Administrator to install the service

param(
    [Parameter(Mandatory=`$true)]
    [ValidateSet("Install", "Uninstall", "Start", "Stop")]
    [string]`$Action
)

`$ServiceName = "HomeHostingSystem"
`$ServiceDisplayName = "Home Hosting System"
`$ServiceDescription = "Home Hosting System Service"
`$ServicePath = "`$PSScriptRoot\start-hosting.ps1"

switch (`$Action) {
    "Install" {
        New-Service -Name `$ServiceName -DisplayName `$ServiceDisplayName -Description `$ServiceDescription -BinaryPathName "powershell.exe -ExecutionPolicy Bypass -File `$ServicePath" -StartupType Automatic
        Write-Host "Service installed successfully" -ForegroundColor Green
    }
    "Uninstall" {
        Stop-Service -Name `$ServiceName -Force -ErrorAction SilentlyContinue
        Remove-Service -Name `$ServiceName
        Write-Host "Service uninstalled successfully" -ForegroundColor Green
    }
    "Start" {
        Start-Service -Name `$ServiceName
        Write-Host "Service started successfully" -ForegroundColor Green
    }
    "Stop" {
        Stop-Service -Name `$ServiceName
        Write-Host "Service stopped successfully" -ForegroundColor Green
    }
}
"@

$serviceScript | Out-File -FilePath "install-service.ps1" -Encoding UTF8
Write-Success "Service script created"

# Create desktop shortcut
Write-Status "Creating desktop shortcut..."
$WshShell = New-Object -comObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\Home Hosting Dashboard.lnk")
$Shortcut.TargetPath = "http://localhost:3000"
$Shortcut.Save()
Write-Success "Desktop shortcut created"

# Get system information
$ipAddress = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.*"}).IPAddress | Select-Object -First 1
$computerName = $env:COMPUTERNAME

Write-Success "Setup completed!"
Write-Host ""
Write-Host "📋 System Information:" -ForegroundColor $Blue
Write-Host "Computer Name: $computerName" -ForegroundColor $White
Write-Host "IP Address: $ipAddress" -ForegroundColor $White
Write-Host "Dashboard: http://$ipAddress`:3000" -ForegroundColor $Cyan
Write-Host "File Manager: http://$ipAddress`:8080" -ForegroundColor $Cyan
Write-Host "Monitoring: http://$ipAddress`:9090" -ForegroundColor $Cyan
Write-Host ""
Write-Host "🔐 Default Login:" -ForegroundColor $Blue
Write-Host "Username: admin" -ForegroundColor $White
Write-Host "Password: password" -ForegroundColor $White
Write-Host ""
Write-Host "📁 Useful Scripts:" -ForegroundColor $Blue
Write-Host "- .\start-hosting.ps1 - Start system" -ForegroundColor $White
Write-Host "- .\stop-hosting.ps1 - Stop system" -ForegroundColor $White
Write-Host "- .\install-service.ps1 Install - Install as Windows service" -ForegroundColor $White
Write-Host ""
Write-Warning "Don't forget to:"
Write-Host "1. Restart Docker Desktop and enable WSL2 integration" -ForegroundColor $Yellow
Write-Host "2. Change default passwords" -ForegroundColor $Yellow
Write-Host "3. Configure bot tokens" -ForegroundColor $Yellow
Write-Host "4. Test all services" -ForegroundColor $Yellow
