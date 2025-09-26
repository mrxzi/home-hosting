# Windows Service for Home Hosting System
# Script untuk install/uninstall Windows Service

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Install", "Uninstall", "Start", "Stop", "Status")]
    [string]$Action
)

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

# Service configuration
$ServiceName = "HomeHostingSystem"
$ServiceDisplayName = "Home Hosting System"
$ServiceDescription = "Home Hosting System Service"
$ServicePath = "$PSScriptRoot\start-hosting.ps1"

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-Error "This script must be run as Administrator to manage Windows services."
    Write-Host "Please right-click PowerShell and select 'Run as Administrator'" -ForegroundColor $Yellow
    exit 1
}

switch ($Action) {
    "Install" {
        Write-Status "Installing Windows Service..."
        try {
            # Check if service already exists
            $existingService = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
            if ($existingService) {
                Write-Warning "Service already exists. Uninstalling first..."
                Stop-Service -Name $ServiceName -Force -ErrorAction SilentlyContinue
                Remove-Service -Name $ServiceName -ErrorAction SilentlyContinue
            }
            
            # Create new service
            New-Service -Name $ServiceName -DisplayName $ServiceDisplayName -Description $ServiceDescription -BinaryPathName "powershell.exe -ExecutionPolicy Bypass -File `"$ServicePath`"" -StartupType Automatic
            Write-Success "Service installed successfully"
            Write-Host "Service Name: $ServiceName" -ForegroundColor $Blue
            Write-Host "Display Name: $ServiceDisplayName" -ForegroundColor $Blue
            Write-Host "Startup Type: Automatic" -ForegroundColor $Blue
        } catch {
            Write-Error "Failed to install service: $($_.Exception.Message)"
            exit 1
        }
    }
    
    "Uninstall" {
        Write-Status "Uninstalling Windows Service..."
        try {
            # Stop service if running
            $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
            if ($service -and $service.Status -eq "Running") {
                Write-Status "Stopping service..."
                Stop-Service -Name $ServiceName -Force
            }
            
            # Remove service
            Remove-Service -Name $ServiceName
            Write-Success "Service uninstalled successfully"
        } catch {
            Write-Error "Failed to uninstall service: $($_.Exception.Message)"
            exit 1
        }
    }
    
    "Start" {
        Write-Status "Starting Windows Service..."
        try {
            Start-Service -Name $ServiceName
            Write-Success "Service started successfully"
        } catch {
            Write-Error "Failed to start service: $($_.Exception.Message)"
            exit 1
        }
    }
    
    "Stop" {
        Write-Status "Stopping Windows Service..."
        try {
            Stop-Service -Name $ServiceName
            Write-Success "Service stopped successfully"
        } catch {
            Write-Error "Failed to stop service: $($_.Exception.Message)"
            exit 1
        }
    }
    
    "Status" {
        Write-Status "Checking Windows Service status..."
        try {
            $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
            if ($service) {
                Write-Host "Service Name: $($service.Name)" -ForegroundColor $Blue
                Write-Host "Display Name: $($service.DisplayName)" -ForegroundColor $Blue
                Write-Host "Status: $($service.Status)" -ForegroundColor $Blue
                Write-Host "Start Type: $($service.StartType)" -ForegroundColor $Blue
                
                if ($service.Status -eq "Running") {
                    Write-Success "Service is running"
                } else {
                    Write-Warning "Service is not running"
                }
            } else {
                Write-Warning "Service not found"
            }
        } catch {
            Write-Error "Failed to check service status: $($_.Exception.Message)"
            exit 1
        }
    }
}

Write-Host ""
Write-Host "💡 Usage Examples:" -ForegroundColor $Yellow
Write-Host "  .\install-service.ps1 Install   - Install service" -ForegroundColor $Yellow
Write-Host "  .\install-service.ps1 Uninstall - Uninstall service" -ForegroundColor $Yellow
Write-Host "  .\install-service.ps1 Start     - Start service" -ForegroundColor $Yellow
Write-Host "  .\install-service.ps1 Stop      - Stop service" -ForegroundColor $Yellow
Write-Host "  .\install-service.ps1 Status    - Check service status" -ForegroundColor $Yellow
