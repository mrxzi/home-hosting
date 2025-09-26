# Home Hosting System Startup Script for Windows
# Script untuk start sistem home hosting di Windows

Write-Host "🚀 Starting Home Hosting System..." -ForegroundColor Green
Write-Host ""

# Colors
$Green = "Green"
$Blue = "Blue"
$Yellow = "Yellow"
$Red = "Red"
$Cyan = "Cyan"

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
        Write-Warning "Docker is not running. Starting Docker Desktop..."
        Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"
        Write-Status "Waiting for Docker Desktop to start..."
        Start-Sleep -Seconds 30
        
        # Check again
        $dockerInfo = docker info 2>$null
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Docker Desktop started successfully"
        } else {
            Write-Error "Docker Desktop failed to start. Please start it manually."
            exit 1
        }
    }
} catch {
    Write-Error "Docker is not available. Please install Docker Desktop first."
    exit 1
}

# Check if docker-compose is available
Write-Status "Checking Docker Compose..."
if (-not (Get-Command docker-compose -ErrorAction SilentlyContinue)) {
    Write-Error "Docker Compose is not available. Please install Docker Desktop with Compose."
    exit 1
} else {
    Write-Success "Docker Compose is available"
}

# Start services
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

# Get system information
$ipAddress = (Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -notlike "127.*" -and $_.IPAddress -notlike "169.*"}).IPAddress | Select-Object -First 1
$computerName = $env:COMPUTERNAME

Write-Success "Home Hosting System started!"
Write-Host ""
Write-Host "📊 Dashboard: http://$ipAddress`:3000" -ForegroundColor $Cyan
Write-Host "📁 File Manager: http://$ipAddress`:8080" -ForegroundColor $Cyan
Write-Host "📈 Monitoring: http://$ipAddress`:9090" -ForegroundColor $Cyan
Write-Host ""
Write-Host "🔐 Default Login:" -ForegroundColor $Yellow
Write-Host "Username: admin" -ForegroundColor $Yellow
Write-Host "Password: password" -ForegroundColor $Yellow
Write-Host ""
Write-Host "💡 Tips:" -ForegroundColor $Blue
Write-Host "- Use .\scripts\monitor-windows.ps1 to check system status" -ForegroundColor $Blue
Write-Host "- Use .\scripts\backup-windows.ps1 to create backups" -ForegroundColor $Blue
Write-Host "- Use .\stop-hosting.ps1 to stop the system" -ForegroundColor $Blue
