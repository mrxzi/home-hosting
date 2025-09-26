#!/bin/bash

# Backup Script for Home Hosting System
# Script untuk backup data dan konfigurasi

set -e

echo "💾 Starting Home Hosting System Backup..."

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Configuration
BACKUP_DIR="./data/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="home_hosting_backup_$DATE.tar.gz"
MAX_BACKUPS=7

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

print_status "Creating backup: $BACKUP_FILE"

# Create backup with compression
tar -czf "$BACKUP_DIR/$BACKUP_FILE" \
  --exclude='./data/backups' \
  --exclude='./data/logs' \
  --exclude='./data/uploads' \
  --exclude='./node_modules' \
  --exclude='./.git' \
  .

# Check if backup was created successfully
if [ -f "$BACKUP_DIR/$BACKUP_FILE" ]; then
    BACKUP_SIZE=$(du -h "$BACKUP_DIR/$BACKUP_FILE" | cut -f1)
    print_success "Backup created successfully!"
    print_status "Backup size: $BACKUP_SIZE"
    print_status "Backup location: $BACKUP_DIR/$BACKUP_FILE"
else
    print_warning "Backup creation failed!"
    exit 1
fi

# Clean up old backups (keep only last MAX_BACKUPS)
print_status "Cleaning up old backups (keeping last $MAX_BACKUPS)..."
cd "$BACKUP_DIR"
BACKUP_COUNT=$(ls -1 home_hosting_backup_*.tar.gz 2>/dev/null | wc -l)

if [ "$BACKUP_COUNT" -gt "$MAX_BACKUPS" ]; then
    OLD_BACKUPS=$(ls -t home_hosting_backup_*.tar.gz | tail -n +$((MAX_BACKUPS + 1)))
    for backup in $OLD_BACKUPS; do
        rm "$backup"
        print_status "Removed old backup: $backup"
    done
fi

# Create backup info file
cat > "$BACKUP_DIR/backup_info.txt" << EOF
Home Hosting System Backup Information
=====================================

Latest Backup: $BACKUP_FILE
Backup Date: $(date)
Backup Size: $BACKUP_SIZE
Total Backups: $(ls -1 home_hosting_backup_*.tar.gz 2>/dev/null | wc -l)

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
2. Extract backup: tar -xzf $BACKUP_FILE
3. Start services: docker-compose up -d
EOF

print_success "Backup completed successfully!"
echo ""
echo "📋 Backup Summary:"
echo "File: $BACKUP_FILE"
echo "Size: $BACKUP_SIZE"
echo "Location: $BACKUP_DIR/"
echo "Total Backups: $(ls -1 home_hosting_backup_*.tar.gz 2>/dev/null | wc -l)"
echo ""
echo "📄 Backup info saved to: $BACKUP_DIR/backup_info.txt"
