# Monitoring Script for Home Hosting System on Windows
# Script untuk monitoring status sistem di Windows

Write-Host "📊 Home Hosting System Status (Windows)" -ForegroundColor Green
Write-Host "=======================================" -ForegroundColor Green
Write-Host ""

# Colors
$Green = "Green"
$Red = "Red"
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

# Function to check service status
function Test-ServiceHealth {
    param(
        [string]$Url,
        [string]$Name
    )
    
    try {
        $response = Invoke-WebRequest -Uri $Url -TimeoutSec 5 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            Write-Host "✅ $Name`: Running" -ForegroundColor $Green
            return $true
        } else {
            Write-Host "❌ $Name`: Not responding" -ForegroundColor $Red
            return $false
        }
    } catch {
        Write-Host "❌ $Name`: Not responding" -ForegroundColor $Red
        return $false
    }
}

# Function to check port
function Test-PortStatus {
    param(
        [int]$Port,
        [string]$Name
    )
    
    try {
        $connection = Test-NetConnection -ComputerName localhost -Port $Port -WarningAction SilentlyContinue
        if ($connection.TcpTestSucceeded) {
            Write-Host "✅ $Name (Port $Port)`: Listening" -ForegroundColor $Green
        } else {
            Write-Host "❌ $Name (Port $Port)`: Not listening" -ForegroundColor $Red
        }
    } catch {
        Write-Host "❌ $Name (Port $Port)`: Not listening" -ForegroundColor $Red
    }
}

# System Information
Write-Host "🖥️  System Information" -ForegroundColor $Blue
Write-Host "Computer Name: $env:COMPUTERNAME" -ForegroundColor $White
Write-Host "User: $env:USERNAME" -ForegroundColor $White
Write-Host "OS: $((Get-WmiObject -Class Win32_OperatingSystem).Caption)" -ForegroundColor $White
Write-Host "Architecture: $((Get-WmiObject -Class Win32_OperatingSystem).OSArchitecture)" -ForegroundColor $White

# Get IP addresses
$ipAddresses = Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.*"}
Write-Host "IP Addresses:" -ForegroundColor $White
foreach ($ip in $ipAddresses) {
    Write-Host "  - $($ip.IPAddress) ($($ip.InterfaceAlias))" -ForegroundColor $White
}

# Get uptime
$uptime = (Get-Date) - (Get-CimInstance -ClassName Win32_OperatingSystem).LastBootUpTime
Write-Host "Uptime: $($uptime.Days) days, $($uptime.Hours) hours, $($uptime.Minutes) minutes" -ForegroundColor $White
Write-Host ""

# Docker Containers Status
Write-Host "🐳 Docker Containers" -ForegroundColor $Blue
try {
    if (Get-Command docker-compose -ErrorAction SilentlyContinue) {
        docker-compose ps
    } else {
        Write-Warning "Docker Compose not available"
    }
} catch {
    Write-Warning "Docker not available or not running"
}
Write-Host ""

# Service Health Checks
Write-Host "🌐 Service Health" -ForegroundColor $Blue
Test-ServiceHealth "http://localhost:3000/health" "Dashboard"
Test-ServiceHealth "http://localhost:4000/health" "Bot Manager"
Test-ServiceHealth "http://localhost:8080" "File Manager"
Test-ServiceHealth "http://localhost:9090" "Monitoring"
Write-Host ""

# Port Status
Write-Host "🔌 Port Status" -ForegroundColor $Blue
Test-PortStatus 3000 "Dashboard"
Test-PortStatus 4000 "Bot Manager"
Test-PortStatus 8080 "File Manager"
Test-PortStatus 9090 "Monitoring"
Test-PortStatus 27017 "MongoDB"
Test-PortStatus 6379 "Redis"
Write-Host ""

# Resource Usage
Write-Host "💾 Resource Usage" -ForegroundColor $Blue

# Memory Usage
Write-Host "Memory Usage:" -ForegroundColor $White
$memory = Get-WmiObject -Class Win32_OperatingSystem
$totalRAM = [math]::Round($memory.TotalVisibleMemorySize / 1MB, 2)
$freeRAM = [math]::Round($memory.FreePhysicalMemory / 1MB, 2)
$usedRAM = $totalRAM - $freeRAM
$ramPercentage = [math]::Round(($usedRAM / $totalRAM) * 100, 2)

Write-Host "  Total RAM: $totalRAM GB" -ForegroundColor $White
Write-Host "  Used RAM: $usedRAM GB ($ramPercentage%)" -ForegroundColor $White
Write-Host "  Free RAM: $freeRAM GB" -ForegroundColor $White
Write-Host ""

# Disk Usage
Write-Host "Disk Usage:" -ForegroundColor $White
Get-WmiObject -Class Win32_LogicalDisk | Where-Object {$_.DriveType -eq 3} | ForEach-Object {
    $size = [math]::Round($_.Size / 1GB, 2)
    $free = [math]::Round($_.FreeSpace / 1GB, 2)
    $used = $size - $free
    $percentage = [math]::Round(($used / $size) * 100, 2)
    
    Write-Host "  $($_.DeviceID) - Size: $size GB, Used: $used GB ($percentage%), Free: $free GB" -ForegroundColor $White
}
Write-Host ""

# CPU Usage
Write-Host "CPU Usage:" -ForegroundColor $White
$cpu = Get-WmiObject -Class Win32_Processor
Write-Host "  Processor: $($cpu.Name)" -ForegroundColor $White
Write-Host "  Cores: $($cpu.NumberOfCores)" -ForegroundColor $White
Write-Host "  Logical Processors: $($cpu.NumberOfLogicalProcessors)" -ForegroundColor $White
Write-Host ""

# Network Connections
Write-Host "🌐 Network Connections" -ForegroundColor $Blue
Write-Host "Active connections on hosting ports:" -ForegroundColor $White
try {
    $connections = netstat -an | Select-String ":3000|:4000|:8080|:9090|:27017|:6379"
    if ($connections) {
        $connections | ForEach-Object {
            Write-Host "  $_" -ForegroundColor $White
        }
    } else {
        Write-Host "  No active connections found on hosting ports" -ForegroundColor $Yellow
    }
} catch {
    Write-Warning "Could not retrieve network connections"
}
Write-Host ""

# Process Information
Write-Host "⚙️  Process Information" -ForegroundColor $Blue
Write-Host "Top processes by CPU usage:" -ForegroundColor $White
Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 | ForEach-Object {
    Write-Host "  $($_.ProcessName): $([math]::Round($_.CPU, 2)) seconds" -ForegroundColor $White
}
Write-Host ""

Write-Host "Top processes by memory usage:" -ForegroundColor $White
Get-Process | Sort-Object WorkingSet -Descending | Select-Object -First 5 | ForEach-Object {
    $memoryMB = [math]::Round($_.WorkingSet / 1MB, 2)
    Write-Host "  $($_.ProcessName): $memoryMB MB" -ForegroundColor $White
}
Write-Host ""

# Log Files Status
Write-Host "📝 Log Files" -ForegroundColor $Blue
if (Test-Path ".\data\logs") {
    Write-Host "Recent log files:" -ForegroundColor $White
    Get-ChildItem ".\data\logs" | Sort-Object LastWriteTime -Descending | Select-Object -First 5 | ForEach-Object {
        Write-Host "  $($_.Name) - $($_.LastWriteTime)" -ForegroundColor $White
    }
} else {
    Write-Host "No log directory found" -ForegroundColor $Yellow
}
Write-Host ""

# Backup Status
Write-Host "💾 Backup Status" -ForegroundColor $Blue
if (Test-Path ".\data\backups") {
    $backups = Get-ChildItem ".\data\backups" -Filter "home_hosting_backup_*.zip"
    if ($backups.Count -gt 0) {
        Write-Host "Available backups: $($backups.Count)" -ForegroundColor $White
        Write-Host "Latest backup:" -ForegroundColor $White
        $latestBackup = $backups | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        Write-Host "  $($latestBackup.Name) - $($latestBackup.LastWriteTime)" -ForegroundColor $White
    } else {
        Write-Host "No backups found" -ForegroundColor $Yellow
    }
} else {
    Write-Host "No backup directory found" -ForegroundColor $Yellow
}
Write-Host ""

# Security Status
Write-Host "🔒 Security Status" -ForegroundColor $Blue
Write-Host "Windows Firewall:" -ForegroundColor $White
try {
    $firewall = Get-NetFirewallProfile
    foreach ($profile in $firewall) {
        Write-Host "  $($profile.Name): $($profile.Enabled)" -ForegroundColor $White
    }
} catch {
    Write-Warning "Could not retrieve firewall status"
}

Write-Host "Windows Defender:" -ForegroundColor $White
try {
    $defender = Get-MpComputerStatus
    Write-Host "  Real-time Protection: $($defender.RealTimeProtectionEnabled)" -ForegroundColor $White
    Write-Host "  Antivirus Enabled: $($defender.AntivirusEnabled)" -ForegroundColor $White
} catch {
    Write-Warning "Could not retrieve Windows Defender status"
}
Write-Host ""

# Docker Status
Write-Host "🐳 Docker Status" -ForegroundColor $Blue
try {
    if (Get-Command docker -ErrorAction SilentlyContinue) {
        $dockerVersion = docker --version
        Write-Host "Docker Version: $dockerVersion" -ForegroundColor $White
        
        $dockerInfo = docker info 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Host "Docker Status: Running" -ForegroundColor $Green
        } else {
            Write-Host "Docker Status: Not running" -ForegroundColor $Red
        }
    } else {
        Write-Host "Docker: Not installed" -ForegroundColor $Red
    }
} catch {
    Write-Host "Docker: Not available" -ForegroundColor $Red
}
Write-Host ""

# Recommendations
Write-Host "💡 Recommendations" -ForegroundColor $Blue
if (-not (Test-Path ".\data\backups\home_hosting_backup_$(Get-Date -Format 'yyyyMMdd')*.zip")) {
    Write-Host "⚠️  No backup created today. Consider running .\scripts\backup-windows.ps1" -ForegroundColor $Yellow
}

if (-not (Test-ServiceHealth "http://localhost:3000/health" "Dashboard")) {
    Write-Host "⚠️  Dashboard is not responding. Check Docker containers." -ForegroundColor $Yellow
}

if ($ramPercentage -gt 80) {
    Write-Host "⚠️  High memory usage ($ramPercentage%). Consider restarting services." -ForegroundColor $Yellow
}

Write-Host ""
Write-Host "📋 Quick Commands:" -ForegroundColor $Blue
Write-Host "  View logs: docker-compose logs -f" -ForegroundColor $White
Write-Host "  Restart services: docker-compose restart" -ForegroundColor $White
Write-Host "  Create backup: .\scripts\backup-windows.ps1" -ForegroundColor $White
Write-Host "  Update system: .\scripts\update-windows.ps1" -ForegroundColor $White
Write-Host ""
Write-Host "🌐 Access URLs:" -ForegroundColor $Blue
$primaryIP = $ipAddresses | Select-Object -First 1
Write-Host "  Dashboard: http://$($primaryIP.IPAddress):3000" -ForegroundColor $Cyan
Write-Host "  File Manager: http://$($primaryIP.IPAddress):8080" -ForegroundColor $Cyan
Write-Host "  Monitoring: http://$($primaryIP.IPAddress):9090" -ForegroundColor $Cyan
