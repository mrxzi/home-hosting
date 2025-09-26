#!/bin/bash

# Deployment Script for Home Hosting System
# Script untuk deploy dan update sistem

set -e

echo "🚀 Starting Home Hosting System Deployment..."

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker first."
    exit 1
fi

# Create necessary directories
print_status "Creating directories..."
mkdir -p data/{bots,logs,backups,uploads}
mkdir -p server/{config/{nginx,mongodb,prometheus,filebrowser},ssl}
mkdir -p dashboard/{data,logs}

# Set permissions
print_status "Setting permissions..."
chmod 755 data/
chmod 755 server/
chmod 755 dashboard/

# Build and start services
print_status "Building Docker images..."
docker-compose build --no-cache

print_status "Starting services..."
docker-compose up -d

# Wait for services to be ready
print_status "Waiting for services to start..."
sleep 30

# Check service health
print_status "Checking service health..."

# Check Dashboard
if curl -f http://localhost:3000/health > /dev/null 2>&1; then
    print_success "Dashboard is running"
else
    print_warning "Dashboard health check failed"
fi

# Check MongoDB
if docker-compose exec mongodb mongosh --eval "db.runCommand('ping')" > /dev/null 2>&1; then
    print_success "MongoDB is running"
else
    print_warning "MongoDB health check failed"
fi

# Check Redis
if docker-compose exec redis redis-cli ping > /dev/null 2>&1; then
    print_success "Redis is running"
else
    print_warning "Redis health check failed"
fi

# Setup initial data
print_status "Setting up initial data..."

# Create admin user in MongoDB
docker-compose exec mongodb mongosh --eval "
use home_hosting;
db.users.insertOne({
  username: 'admin',
  email: 'admin@localhost',
  password: '\$2a\$10\$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
  role: 'admin',
  createdAt: new Date()
});
" > /dev/null 2>&1 || print_warning "Failed to create admin user"

# Create sample bot configurations
cat > data/bots/sample-bots.json << 'EOF'
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
EOF

print_success "Sample bot configurations created"

# Create backup script
cat > scripts/backup.sh << 'EOF'
#!/bin/bash
# Backup script for Home Hosting System

BACKUP_DIR="./data/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="home_hosting_backup_$DATE.tar.gz"

echo "Creating backup: $BACKUP_FILE"

# Create backup
tar -czf "$BACKUP_DIR/$BACKUP_FILE" \
  --exclude='./data/backups' \
  --exclude='./data/logs' \
  --exclude='./data/uploads' \
  .

echo "Backup created: $BACKUP_DIR/$BACKUP_FILE"

# Keep only last 7 backups
cd "$BACKUP_DIR"
ls -t home_hosting_backup_*.tar.gz | tail -n +8 | xargs -r rm

echo "Backup completed!"
EOF

chmod +x scripts/backup.sh

# Create update script
cat > scripts/update.sh << 'EOF'
#!/bin/bash
# Update script for Home Hosting System

echo "🔄 Updating Home Hosting System..."

# Pull latest changes
git pull origin main

# Rebuild and restart services
docker-compose down
docker-compose build --no-cache
docker-compose up -d

echo "✅ Update completed!"
EOF

chmod +x scripts/update.sh

# Create monitoring script
cat > scripts/monitor.sh << 'EOF'
#!/bin/bash
# Monitoring script for Home Hosting System

echo "📊 Home Hosting System Status"
echo "=============================="

# Check Docker containers
echo "🐳 Docker Containers:"
docker-compose ps

echo ""
echo "💾 Disk Usage:"
df -h

echo ""
echo "🧠 Memory Usage:"
free -h

echo ""
echo "🌐 Network Connections:"
netstat -tuln | grep -E ':(3000|4000|8080|9090|27017|6379)'

echo ""
echo "📈 Service Health:"
curl -s http://localhost:3000/health | jq . 2>/dev/null || echo "Dashboard: Not responding"
curl -s http://localhost:4000/health | jq . 2>/dev/null || echo "Bot Manager: Not responding"
EOF

chmod +x scripts/monitor.sh

# Get system information
IP=$(hostname -I | awk '{print $1}')
USER=$(whoami)

print_success "Deployment completed!"
echo ""
echo "📋 System Information:"
echo "IP Address: $IP"
echo "User: $USER"
echo "Dashboard: http://$IP:3000"
echo "File Manager: http://$IP:8080"
echo "Monitoring: http://$IP:9090"
echo ""
echo "🔐 Default Login:"
echo "Username: admin"
echo "Password: password"
echo ""
echo "📁 Useful Scripts:"
echo "- ./scripts/backup.sh - Create system backup"
echo "- ./scripts/update.sh - Update system"
echo "- ./scripts/monitor.sh - Check system status"
echo ""
print_warning "Don't forget to:"
echo "1. Change default passwords"
echo "2. Configure bot tokens"
echo "3. Set up SSL certificates"
echo "4. Configure firewall rules"
