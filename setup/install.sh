#!/bin/bash

# Home Hosting Setup Script
# Script untuk setup awal sistem home hosting

set -e

echo "🚀 Memulai setup Home Hosting System..."

# Colors untuk output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function untuk print dengan warna
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

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "Jangan jalankan script ini sebagai root!"
   exit 1
fi

# Update system
print_status "Mengupdate sistem..."
sudo apt update && sudo apt upgrade -y

# Install dependencies
print_status "Menginstall dependencies..."
sudo apt install -y curl wget git unzip software-properties-common apt-transport-https ca-certificates gnupg lsb-release

# Install Docker
print_status "Menginstall Docker..."
if ! command -v docker &> /dev/null; then
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker $USER
    print_success "Docker berhasil diinstall"
else
    print_warning "Docker sudah terinstall"
fi

# Install Docker Compose
print_status "Menginstall Docker Compose..."
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    print_success "Docker Compose berhasil diinstall"
else
    print_warning "Docker Compose sudah terinstall"
fi

# Install Node.js
print_status "Menginstall Node.js..."
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get install -y nodejs
    print_success "Node.js berhasil diinstall"
else
    print_warning "Node.js sudah terinstall"
fi

# Install Python
print_status "Menginstall Python..."
sudo apt install -y python3 python3-pip python3-venv

# Install SSH Server
print_status "Menginstall SSH Server..."
sudo apt install -y openssh-server
sudo systemctl enable ssh
sudo systemctl start ssh

# Install VNC Server (optional)
print_status "Menginstall VNC Server..."
sudo apt install -y tightvncserver

# Create directories
print_status "Membuat direktori..."
mkdir -p data/{bots,logs,backups}
mkdir -p server/{config/{nginx,mongodb,prometheus,filebrowser},ssl}
mkdir -p dashboard/{frontend,backend}
mkdir -p bots/{discord,telegram,slack}

# Setup SSH keys
print_status "Setup SSH keys..."
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
    print_success "SSH key berhasil dibuat"
fi

# Setup firewall
print_status "Setup firewall..."
sudo ufw allow 22/tcp    # SSH
sudo ufw allow 80/tcp    # HTTP
sudo ufw allow 443/tcp   # HTTPS
sudo ufw allow 3000/tcp  # Dashboard
sudo ufw allow 8080/tcp  # File Manager
sudo ufw allow 9090/tcp  # Monitoring
sudo ufw --force enable

# Create environment file
print_status "Membuat environment file..."
cat > .env << EOF
# Database
MONGODB_URI=mongodb://admin:hosting123@localhost:27017
REDIS_URL=redis://localhost:6379

# Dashboard
DASHBOARD_PORT=3000
DASHBOARD_SECRET=your-secret-key-here

# Bot Manager
BOT_MANAGER_PORT=4000

# File Manager
FILE_MANAGER_PORT=8080

# SSL
SSL_CERT_PATH=./server/ssl/cert.pem
SSL_KEY_PATH=./server/ssl/key.pem
EOF

# Create startup script
print_status "Membuat startup script..."
cat > start-hosting.sh << 'EOF'
#!/bin/bash
echo "🚀 Starting Home Hosting System..."
docker-compose up -d
echo "✅ Home Hosting System started!"
echo "📊 Dashboard: http://localhost:3000"
echo "📁 File Manager: http://localhost:8080"
echo "📈 Monitoring: http://localhost:9090"
EOF

chmod +x start-hosting.sh

# Create stop script
cat > stop-hosting.sh << 'EOF'
#!/bin/bash
echo "🛑 Stopping Home Hosting System..."
docker-compose down
echo "✅ Home Hosting System stopped!"
EOF

chmod +x stop-hosting.sh

# Create systemd service
print_status "Membuat systemd service..."
sudo tee /etc/systemd/system/home-hosting.service > /dev/null << EOF
[Unit]
Description=Home Hosting System
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=$(pwd)
ExecStart=/bin/bash $(pwd)/start-hosting.sh
ExecStop=/bin/bash $(pwd)/stop-hosting.sh
User=$USER

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable home-hosting.service

print_success "Setup selesai!"
echo ""
echo "📋 Langkah selanjutnya:"
echo "1. Restart komputer atau jalankan: newgrp docker"
echo "2. Jalankan: ./start-hosting.sh"
echo "3. Akses dashboard di: http://$(hostname -I | awk '{print $1}'):3000"
echo "4. Default login: admin / hosting123"
echo ""
echo "🔧 Untuk remote access:"
echo "SSH: ssh $USER@$(hostname -I | awk '{print $1}')"
echo "VNC: vncserver -geometry 1920x1080"
echo ""
print_warning "Jangan lupa ganti password default di .env file!"
