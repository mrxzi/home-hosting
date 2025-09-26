# Home Hosting System

Sistem home hosting untuk mengubah laptop yang tidak terpakai menjadi server hosting bot dan aplikasi yang dapat di-remote dari komputer utama.

## Fitur Utama

- 🖥️ Remote access ke laptop hosting via SSH/VNC
- 🤖 Bot hosting environment (Discord, Telegram, dll)
- 📊 Web dashboard untuk monitoring
- 🐳 Docker containerization
- 🔄 Automated deployment
- 📱 Mobile-friendly interface

## Struktur Project

```
home-hosting/
├── server/                 # Server-side components
│   ├── docker/            # Docker configurations
│   ├── scripts/           # Automation scripts
│   └── config/            # Server configurations
├── dashboard/             # Web dashboard
│   ├── frontend/          # React dashboard
│   └── backend/           # Express.js API
├── bots/                  # Bot templates dan examples
├── docs/                  # Dokumentasi
└── setup/                 # Setup scripts
```

## Quick Start

1. Clone repository ini ke laptop hosting
2. Jalankan `./setup/install.sh` untuk setup awal
3. Akses dashboard di `http://laptop-ip:3000`
4. Mulai deploy bot dan aplikasi

## Requirements

- Ubuntu/Debian atau Windows dengan WSL
- Docker & Docker Compose
- Node.js 18+
- Python 3.9+
- Git

## Dokumentasi Lengkap

Lihat folder `docs/` untuk dokumentasi detail setup dan penggunaan.
