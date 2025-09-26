#!/bin/bash

# Remote Access Setup Script
# Script untuk setup SSH dan VNC remote access

set -e

echo "🔐 Setting up Remote Access..."

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

# Get current user and IP
USER=$(whoami)
IP=$(hostname -I | awk '{print $1}')

print_status "Setting up SSH access..."

# Configure SSH
sudo tee /etc/ssh/sshd_config > /dev/null << 'EOF'
# SSH Configuration for Home Hosting
Port 22
Protocol 2
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key

# Authentication
LoginGraceTime 120
PermitRootLogin no
StrictModes yes
PubkeyAuthentication yes
PasswordAuthentication yes
PermitEmptyPasswords no
ChallengeResponseAuthentication no

# Security
X11Forwarding yes
X11DisplayOffset 10
PrintMotd no
AcceptEnv LANG LC_*
Subsystem sftp /usr/lib/openssh/sftp-server

# Allow specific users
AllowUsers hosting-user
EOF

# Create hosting user if not exists
if ! id "hosting-user" &>/dev/null; then
    sudo useradd -m -s /bin/bash hosting-user
    sudo usermod -aG docker hosting-user
    sudo usermod -aG sudo hosting-user
    print_success "User 'hosting-user' created"
fi

# Setup SSH keys for hosting-user
sudo -u hosting-user mkdir -p /home/hosting-user/.ssh
sudo -u hosting-user chmod 700 /home/hosting-user/.ssh

# Copy current user's SSH key to hosting-user
if [ -f ~/.ssh/id_rsa.pub ]; then
    sudo cp ~/.ssh/id_rsa.pub /home/hosting-user/.ssh/authorized_keys
    sudo chown hosting-user:hosting-user /home/hosting-user/.ssh/authorized_keys
    sudo chmod 600 /home/hosting-user/.ssh/authorized_keys
    print_success "SSH key copied to hosting-user"
fi

# Restart SSH service
sudo systemctl restart ssh
sudo systemctl enable ssh

print_status "Setting up VNC access..."

# Install VNC server
sudo apt install -y tightvncserver xfce4 xfce4-goodies

# Create VNC startup script
sudo tee /home/hosting-user/.vnc/xstartup > /dev/null << 'EOF'
#!/bin/bash
xrdb $HOME/.Xresources
startxfce4 &
EOF

sudo chown hosting-user:hosting-user /home/hosting-user/.vnc/xstartup
sudo chmod +x /home/hosting-user/.vnc/xstartup

# Create VNC service
sudo tee /etc/systemd/system/vncserver@.service > /dev/null << EOF
[Unit]
Description=Start TightVNC server at startup
After=syslog.target network.target

[Service]
Type=forking
User=hosting-user
Group=hosting-user
WorkingDirectory=/home/hosting-user

PIDFile=/home/hosting-user/.vnc/%H:%i.pid
ExecStartPre=-/usr/bin/vncserver -kill :%i > /dev/null 2>&1
ExecStart=/usr/bin/vncserver -depth 24 -geometry 1920x1080 :%i
ExecStop=/usr/bin/vncserver -kill :%i

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable vncserver@1.service

# Create VNC password
print_warning "Setting up VNC password..."
sudo -u hosting-user vncpasswd

# Create remote access info file
cat > remote-access-info.txt << EOF
=== REMOTE ACCESS INFORMATION ===

SSH Access:
- Host: $IP
- Port: 22
- User: hosting-user
- Command: ssh hosting-user@$IP

VNC Access:
- Host: $IP
- Port: 5901
- Display: :1
- Resolution: 1920x1080
- VNC Client: RealVNC, TightVNC, atau TigerVNC

Web Access:
- Dashboard: http://$IP:3000
- File Manager: http://$IP:8080
- Monitoring: http://$IP:9090

=== SECURITY NOTES ===
1. Change default passwords immediately
2. Use SSH keys instead of passwords when possible
3. Keep system updated regularly
4. Monitor access logs

=== FIREWALL PORTS ===
- 22: SSH
- 80: HTTP
- 443: HTTPS
- 3000: Dashboard
- 5901: VNC
- 8080: File Manager
- 9090: Monitoring
EOF

print_success "Remote access setup completed!"
echo ""
echo "📋 Remote Access Information:"
echo "SSH: ssh hosting-user@$IP"
echo "VNC: Connect to $IP:5901"
echo "Dashboard: http://$IP:3000"
echo ""
echo "📄 Detailed info saved to: remote-access-info.txt"
echo ""
print_warning "Don't forget to:"
echo "1. Change default passwords"
echo "2. Test SSH and VNC connections"
echo "3. Configure firewall if needed"
