# Backup Script for Home Hosting System on Windows
# Script untuk backup data dan konfigurasi di Windows

param(
    [string]$BackupPath = ".\data\backups",
    [int]$MaxBackups = 7
)

Write-Host "💾 Starting Home Hosting System Backup on Windows..." -ForegroundColor Green
Write-Host ""

# Colors
$Green = "Green"
$Blue = "Blue"
$Yellow = "Yellow"
$Cyan = "Cyan"
$Red = "Red"
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

# Create backup directory if it doesn't exist
if (-not (Test-Path $BackupPath)) {
    New-Item -ItemType Directory -Path $BackupPath -Force | Out-Null
    Write-Status "Created backup directory: $BackupPath"
}

# Generate backup filename with timestamp
$Date = Get-Date -Format "yyyyMMdd_HHmmss"
$BackupFile = "home_hosting_backup_$Date.zip"
$FullBackupPath = Join-Path $BackupPath $BackupFile

Write-Status "Creating backup: $BackupFile"

try {
    # Get all files except backups, logs, uploads, node_modules, and .git
    $filesToBackup = Get-ChildItem -Path . -Recurse | Where-Object {
        $_.FullName -notlike "*\data\backups\*" -and
        $_.FullName -notlike "*\data\logs\*" -and
        $_.FullName -notlike "*\data\uploads\*" -and
        $_.FullName -notlike "*\node_modules\*" -and
        $_.FullName -notlike "*\.git\*" -and
        $_.FullName -notlike "*\*.log" -and
        $_.FullName -notlike "*\*.tmp"
    }
    
    # Create temporary directory for backup
    $tempDir = Join-Path $env:TEMP "home_hosting_backup_$Date"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    
    # Copy files to temporary directory
    foreach ($file in $filesToBackup) {
        $relativePath = $file.FullName.Substring((Get-Location).Path.Length + 1)
        $targetPath = Join-Path $tempDir $relativePath
        $targetDir = Split-Path $targetPath -Parent
        
        if (-not (Test-Path $targetDir)) {
            New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
        }
        
        Copy-Item $file.FullName $targetPath -Force
    }
    
    # Create ZIP archive
    Compress-Archive -Path "$tempDir\*" -DestinationPath $FullBackupPath -Force
    
    # Clean up temporary directory
    Remove-Item -Path $tempDir -Recurse -Force
    
    # Check if backup was created successfully
    if (Test-Path $FullBackupPath) {
        $BackupSize = (Get-Item $FullBackupPath).Length
        $BackupSizeMB = [math]::Round($BackupSize / 1MB, 2)
        
        Write-Success "Backup created successfully!"
        Write-Status "Backup size: $BackupSizeMB MB"
        Write-Status "Backup location: $FullBackupPath"
    } else {
        Write-Error "Backup creation failed!"
        exit 1
    }
    
} catch {
    Write-Error "Backup creation failed: $($_.Exception.Message)"
    exit 1
}

# Clean up old backups
Write-Status "Cleaning up old backups (keeping last $MaxBackups)..."
try {
    $existingBackups = Get-ChildItem -Path $BackupPath -Filter "home_hosting_backup_*.zip" | Sort-Object CreationTime -Descending
    $backupCount = $existingBackups.Count
    
    if ($backupCount -gt $MaxBackups) {
        $backupsToRemove = $existingBackups | Select-Object -Skip $MaxBackups
        foreach ($backup in $backupsToRemove) {
            Remove-Item $backup.FullName -Force
            Write-Status "Removed old backup: $($backup.Name)"
        }
    }
    
    Write-Success "Backup cleanup completed"
} catch {
    Write-Warning "Backup cleanup failed: $($_.Exception.Message)"
}

# Create backup info file
$backupInfo = @"
Home Hosting System Backup Information
=====================================

Latest Backup: $BackupFile
Backup Date: $(Get-Date)
Backup Size: $BackupSizeMB MB
Total Backups: $backupCount

Backup Contents:
- Application code
- Configuration files
- Bot configurations
- Database dumps (if available)
- SSL certificates
- Custom scripts

Excluded:
- Log files
- Upload files
- Node modules
- Git history
- Previous backups

To restore from backup:
1. Stop all services: docker-compose down
2. Extract backup: Expand-Archive -Path $BackupFile -DestinationPath .
3. Start services: docker-compose up -d
"@

$backupInfo | Out-File -FilePath "$BackupPath\backup_info.txt" -Encoding UTF8

Write-Success "Backup completed successfully!"
Write-Host ""
Write-Host "📋 Backup Summary:" -ForegroundColor $Blue
Write-Host "File: $BackupFile" -ForegroundColor $White
Write-Host "Size: $BackupSizeMB MB" -ForegroundColor $White
Write-Host "Location: $BackupPath\" -ForegroundColor $White
Write-Host "Total Backups: $backupCount" -ForegroundColor $White
Write-Host ""
Write-Host "📄 Backup info saved to: $BackupPath\backup_info.txt" -ForegroundColor $Cyan
