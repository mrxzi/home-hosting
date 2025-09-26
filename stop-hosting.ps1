# Home Hosting System Stop Script for Windows
# Script untuk stop sistem home hosting di Windows

Write-Host "🛑 Stopping Home Hosting System..." -ForegroundColor Yellow
Write-Host ""

# Colors
$Green = "Green"
$Blue = "Blue"
$Yellow = "Yellow"
$Red = "Red"

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
        Write-Warning "Docker is not running"
        exit 0
    }
} catch {
    Write-Warning "Docker is not available"
    exit 0
}

# Stop services
Write-Status "Stopping services..."
try {
    docker-compose down
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Services stopped successfully"
    } else {
        Write-Warning "Some services may not have stopped properly"
    }
} catch {
    Write-Error "Error stopping services: $($_.Exception.Message)"
    exit 1
}

Write-Success "Home Hosting System stopped!"
Write-Host ""
Write-Host "💡 To start the system again, run: .\start-hosting.ps1" -ForegroundColor $Blue
