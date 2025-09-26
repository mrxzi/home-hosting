# Deployment Script for Home Hosting System on Windows
# Script untuk deploy dan update sistem di Windows

param(
    [switch]$SkipBuild,
    [switch]$SkipBackup,
    [switch]$Force
)

Write-Host "🚀 Starting Home Hosting System Deployment on Windows..." -ForegroundColor Green
Write-Host ""

# Colors
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"
$Blue = "Blue"
$Cyan = "Cyan"
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

# Check if Docker is running
Write-Status "Checking Docker status..."
try {
    $dockerInfo = docker info 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Docker is running"
    } else {
        Write-Error "Docker is not running. Please start Docker Desktop first."
        exit 1
    }
} catch {
    Write-Error "Docker is not available. Please install Docker Desktop first."
    exit 1
}

# Create necessary directories
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
    "dashboard\logs"
)

foreach ($dir in $directories) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
        Write-Status "Created directory: $dir"
    }
}

# Set permissions (Windows equivalent)
Write-Status "Setting permissions..."
# Windows doesn't need chmod, but we can set ACL if needed
try {
    icacls "data" /grant "Everyone:(OI)(CI)F" /T 2>$null
    icacls "server" /grant "Everyone:(OI)(CI)F" /T 2>$null
    icacls "dashboard" /grant "Everyone:(OI)(CI)F" /T 2>$null
    Write-Success "Permissions set"
} catch {
    Write-Warning "Could not set permissions: $($_.Exception.Message)"
}

# Build and start services
if (-not $SkipBuild) {
    Write-Status "Building Docker images..."
    try {
        docker-compose build --no-cache
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Docker images built successfully"
        } else {
            Write-Error "Failed to build Docker images"
            exit 1
        }
    } catch {
        Write-Error "Error building Docker images: $($_.Exception.Message)"
        exit 1
    }
}

Write-Status "Starting services..."
try {
    docker-compose up -d
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Services started successfully"
    } else {
        Write-Error "Failed to start services"
        exit 1
    }
} catch {
    Write-Error "Error starting services: $($_.Exception.Message)"
    exit 1
}

# Wait for services to be ready
Write-Status "Waiting for services to start..."
Start-Sleep -Seconds 30

# Check service health
Write-Status "Checking service health..."

# Check Dashboard
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/health" -TimeoutSec 10 -ErrorAction Stop
    if ($response.StatusCode -eq 200) {
        Write-Success "Dashboard is running"
    } else {
        Write-Warning "Dashboard health check failed"
    }
} catch {
    Write-Warning "Dashboard health check failed: $($_.Exception.Message)"
}

# Check MongoDB
try {
    $mongoCheck = docker-compose exec -T mongodb mongosh --eval "db.runCommand('ping')" 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Success "MongoDB is running"
    } else {
        Write-Warning "MongoDB health check failed"
    }
} catch {
    Write-Warning "MongoDB health check failed"
}

# Check Redis
try {
    $redisCheck = docker-compose exec -T redis redis-cli ping 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Redis is running"
    } else {
        Write-Warning "Redis health check failed"
    }
} catch {
    Write-Warning "Redis health check failed"
}

# Setup initial data
Write-Status "Setting up initial data..."

# Create admin user in MongoDB
try {
    $mongoScript = @"
use home_hosting;
db.users.insertOne({
  username: 'admin',
  email: 'admin@localhost',
  password: '\$2a\$10\$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
  role: 'admin',
  createdAt: new Date()
});
"@
    $mongoScript | docker-compose exec -T mongodb mongosh --quiet
    Write-Success "Admin user created"
} catch {
    Write-Warning "Failed to create admin user: $($_.Exception.Message)"
}

# Create sample bot configurations
Write-Status "Creating sample bot configurations..."
$sampleBots = @"
[
  {
    "name": "Discord Bot",
    "type": "discord",
    "status": "stopped",
    "config": {
      "token": "your-discord-token-here",
      "prefix": "!",
      "commands": ["ping", "help", "status"]
    }
  },
  {
    "name": "Telegram Bot",
    "type": "telegram",
    "status": "stopped",
    "config": {
      "token": "your-telegram-token-here",
      "commands": ["start", "help", "info"]
    }
  }
]
"@

$sampleBots | Out-File -FilePath "data\bots\sample-bots.json" -Encoding UTF8
Write-Success "Sample bot configurations created"

# Create Windows-specific scripts
Write-Status "Creating Windows-specific scripts..."

# Create backup script
$backupScript = @"
# Backup script for Home Hosting System on Windows
param(
    [string]`$BackupPath = ".\data\backups"
)

`$Date = Get-Date -Format "yyyyMMdd_HHmmss"
`$BackupFile = "home_hosting_backup_`$Date.zip"

Write-Host "Creating backup: `$BackupFile" -ForegroundColor Blue

# Create backup directory if it doesn't exist
if (-not (Test-Path `$BackupPath)) {
    New-Item -ItemType Directory -Path `$BackupPath -Force | Out-Null
}

# Create backup using PowerShell compression
try {
    # Get all files except backups, logs, and uploads
    `$filesToBackup = Get-ChildItem -Path . -Recurse | Where-Object {
        `$_.FullName -notlike "*\data\backups\*" -and
        `$_.FullName -notlike "*\data\logs\*" -and
        `$_.FullName -notlike "*\data\uploads\*" -and
        `$_.FullName -notlike "*\node_modules\*" -and
        `$_.FullName -notlike "*\.git\*"
    }
    
    # Create ZIP archive
    Compress-Archive -Path `$filesToBackup.FullName -DestinationPath "`$BackupPath\`$BackupFile" -Force
    
    `$BackupSize = (Get-Item "`$BackupPath\`$BackupFile").Length
    `$BackupSizeMB = [math]::Round(`$BackupSize / 1MB, 2)
    
    Write-Host "Backup created successfully!" -ForegroundColor Green
    Write-Host "Backup size: `$BackupSizeMB MB" -ForegroundColor Cyan
    Write-Host "Backup location: `$BackupPath\`$BackupFile" -ForegroundColor Cyan
    
    # Clean up old backups (keep last 7)
    `$oldBackups = Get-ChildItem -Path `$BackupPath -Filter "home_hosting_backup_*.zip" | Sort-Object CreationTime -Descending | Select-Object -Skip 7
    foreach (`$oldBackup in `$oldBackups) {
        Remove-Item `$oldBackup.FullName -Force
        Write-Host "Removed old backup: `$(`$oldBackup.Name)" -ForegroundColor Yellow
    }
    
} catch {
    Write-Host "Backup creation failed: `$(`$_.Exception.Message)" -ForegroundColor Red
    exit 1
}
"@

$backupScript | Out-File -FilePath "scripts\backup-windows.ps1" -Encoding UTF8
Write-Success "Backup script created"

# Create update script
$updateScript = @"
# Update script for Home Hosting System on Windows
Write-Host "🔄 Updating Home Hosting System..." -ForegroundColor Blue

# Pull latest changes
git pull origin main

# Rebuild and restart services
docker-compose down
docker-compose build --no-cache
docker-compose up -d

Write-Host "✅ Update completed!" -ForegroundColor Green
"@

$updateScript | Out-File -FilePath "scripts\update-windows.ps1" -Encoding UTF8
Write-Success "Update script created"

# Create monitoring script
$monitorScript = @"
# Monitoring script for Home Hosting System on Windows
Write-Host "📊 Home Hosting System Status" -ForegroundColor Green
Write-Host "==============================" -ForegroundColor Green
Write-Host ""

# Check Docker containers
Write-Host "🐳 Docker Containers:" -ForegroundColor Blue
docker-compose ps

Write-Host ""
Write-Host "💾 Disk Usage:" -ForegroundColor Blue
Get-WmiObject -Class Win32_LogicalDisk | Select-Object DeviceID, @{Name="Size(GB)";Expression={[math]::Round(`$_.Size/1GB,2)}}, @{Name="FreeSpace(GB)";Expression={[math]::Round(`$_.FreeSpace/1GB,2)}}, @{Name="PercentFree";Expression={[math]::Round((`$_.FreeSpace/`$_.Size)*100,2)}}

Write-Host ""
Write-Host "🧠 Memory Usage:" -ForegroundColor Blue
Get-WmiObject -Class Win32_OperatingSystem | Select-Object @{Name="TotalRAM(GB)";Expression={[math]::Round(`$_.TotalVisibleMemorySize/1MB,2)}}, @{Name="FreeRAM(GB)";Expression={[math]::Round(`$_.FreePhysicalMemory/1MB,2)}}, @{Name="UsedRAM(GB)";Expression={[math]::Round((`$_.TotalVisibleMemorySize-`$_.FreePhysicalMemory)/1MB,2)}}

Write-Host ""
Write-Host "🌐 Network Connections:" -ForegroundColor Blue
netstat -an | Select-String ":3000|:4000|:8080|:9090|:27017|:6379"

Write-Host ""
Write-Host "📈 Service Health:" -ForegroundColor Blue
try {
    `$dashboardHealth = Invoke-RestMethod -Uri "http://localhost:3000/health" -TimeoutSec 5
    Write-Host "Dashboard: OK" -ForegroundColor Green
} catch {
    Write-Host "Dashboard: Not responding" -ForegroundColor Red
}

try {
    `$botManagerHealth = Invoke-RestMethod -Uri "http://localhost:4000/health" -TimeoutSec 5
    Write-Host "Bot Manager: OK" -ForegroundColor Green
} catch {
    Write-Host "Bot Manager: Not responding" -ForegroundColor Red
}
"@

$monitorScript | Out-File -FilePath "scripts\monitor-windows.ps1" -Encoding UTF8
Write-Success "Monitoring script created"

# Get system information
$ipAddress = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.*"}).IPAddress | Select-Object -First 1
$computerName = $env:COMPUTERNAME

Write-Success "Deployment completed!"
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
Write-Host "- .\scripts\backup-windows.ps1 - Create system backup" -ForegroundColor $White
Write-Host "- .\scripts\update-windows.ps1 - Update system" -ForegroundColor $White
Write-Host "- .\scripts\monitor-windows.ps1 - Check system status" -ForegroundColor $White
Write-Host ""
Write-Warning "Don't forget to:"
Write-Host "1. Change default passwords" -ForegroundColor $Yellow
Write-Host "2. Configure bot tokens" -ForegroundColor $Yellow
Write-Host "3. Set up Windows Firewall rules" -ForegroundColor $Yellow
Write-Host "4. Test all services" -ForegroundColor $Yellow
