#!/bin/bash

# Monitoring Script for Home Hosting System
# Script untuk monitoring status sistem

echo "📊 Home Hosting System Status"
echo "=============================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Function to check service status
check_service() {
    local url=$1
    local name=$2
    
    if curl -s -f "$url" > /dev/null 2>&1; then
        echo -e "${GREEN}✅${NC} $name: Running"
    else
        echo -e "${RED}❌${NC} $name: Not responding"
    fi
}

# Function to check port
check_port() {
    local port=$1
    local name=$2
    
    if netstat -tuln | grep -q ":$port "; then
        echo -e "${GREEN}✅${NC} $name (Port $port): Listening"
    else
        echo -e "${RED}❌${NC} $name (Port $port): Not listening"
    fi
}

# System Information
echo -e "${BLUE}🖥️  System Information${NC}"
echo "Hostname: $(hostname)"
echo "IP Address: $(hostname -I | awk '{print $1}')"
echo "Uptime: $(uptime -p)"
echo "Load Average: $(uptime | awk -F'load average:' '{print $2}')"
echo ""

# Docker Containers Status
echo -e "${BLUE}🐳 Docker Containers${NC}"
if command -v docker-compose > /dev/null 2>&1; then
    docker-compose ps
else
    echo "Docker Compose not available"
fi
echo ""

# Service Health Checks
echo -e "${BLUE}🌐 Service Health${NC}"
check_service "http://localhost:3000/health" "Dashboard"
check_service "http://localhost:4000/health" "Bot Manager"
check_service "http://localhost:8080" "File Manager"
check_service "http://localhost:9090" "Monitoring"
echo ""

# Port Status
echo -e "${BLUE}🔌 Port Status${NC}"
check_port "3000" "Dashboard"
check_port "4000" "Bot Manager"
check_port "8080" "File Manager"
check_port "9090" "Monitoring"
check_port "27017" "MongoDB"
check_port "6379" "Redis"
echo ""

# Resource Usage
echo -e "${BLUE}💾 Resource Usage${NC}"
echo "Memory Usage:"
free -h | grep -E "Mem|Swap"
echo ""

echo "Disk Usage:"
df -h | grep -E "Filesystem|/dev/"
echo ""

# Network Connections
echo -e "${BLUE}🌐 Network Connections${NC}"
echo "Active connections on hosting ports:"
netstat -tuln | grep -E ':(3000|4000|8080|9090|27017|6379)' | while read line; do
    echo "  $line"
done
echo ""

# Process Information
echo -e "${BLUE}⚙️  Process Information${NC}"
echo "Top processes by CPU usage:"
ps aux --sort=-%cpu | head -6
echo ""

echo "Top processes by memory usage:"
ps aux --sort=-%mem | head -6
echo ""

# Log Files Status
echo -e "${BLUE}📝 Log Files${NC}"
if [ -d "./data/logs" ]; then
    echo "Recent log files:"
    ls -la ./data/logs/ | tail -5
else
    echo "No log directory found"
fi
echo ""

# Backup Status
echo -e "${BLUE}💾 Backup Status${NC}"
if [ -d "./data/backups" ]; then
    BACKUP_COUNT=$(ls -1 ./data/backups/home_hosting_backup_*.tar.gz 2>/dev/null | wc -l)
    if [ "$BACKUP_COUNT" -gt 0 ]; then
        echo "Available backups: $BACKUP_COUNT"
        echo "Latest backup:"
        ls -la ./data/backups/home_hosting_backup_*.tar.gz | tail -1
    else
        echo "No backups found"
    fi
else
    echo "No backup directory found"
fi
echo ""

# Security Status
echo -e "${BLUE}🔒 Security Status${NC}"
echo "SSH Status:"
systemctl is-active ssh 2>/dev/null && echo -e "${GREEN}✅${NC} SSH: Active" || echo -e "${RED}❌${NC} SSH: Inactive"

echo "Firewall Status:"
if command -v ufw > /dev/null 2>&1; then
    ufw status | head -3
else
    echo "UFW not available"
fi
echo ""

# Recommendations
echo -e "${BLUE}💡 Recommendations${NC}"
if [ ! -f "./data/backups/home_hosting_backup_$(date +%Y%m%d)*.tar.gz" ]; then
    echo -e "${YELLOW}⚠️${NC} No backup created today. Consider running ./scripts/backup.sh"
fi

if ! curl -s -f "http://localhost:3000/health" > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️${NC} Dashboard is not responding. Check Docker containers."
fi

echo ""
echo "📋 Quick Commands:"
echo "  View logs: docker-compose logs -f"
echo "  Restart services: docker-compose restart"
echo "  Create backup: ./scripts/backup.sh"
echo "  Update system: ./scripts/update.sh"
echo ""
echo "🌐 Access URLs:"
echo "  Dashboard: http://$(hostname -I | awk '{print $1}'):3000"
echo "  File Manager: http://$(hostname -I | awk '{print $1}'):8080"
echo "  Monitoring: http://$(hostname -I | awk '{print $1}'):9090"
