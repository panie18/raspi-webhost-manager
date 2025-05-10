#!/bin/bash

# Abbruch bei Fehler
set -e

echo "📦 Installing system dependencies..."
sudo apt update
sudo apt install -y apache2 python3 python3-pip python3-venv git certbot python3-certbot-apache curl

echo "📁 Cloning repository..."
sudo git clone https://github.com/panie18/raspi-webhost-manager.git /opt/raspi-webhost-manager

echo "🐍 Setting up Python virtual environment..."
cd /opt/raspi-webhost-manager
python3 -m venv venv
source venv/bin/activate

echo "📦 Installing Python dependencies..."
pip install --upgrade pip
pip install -r requirements.txt

echo "🛠️ Creating systemd service for Flask app..."

# Systemd Service-Datei erstellen
sudo tee /etc/systemd/system/raspi-webhost.service > /dev/null <<EOF
[Unit]
Description=Raspberry Pi Webhost Manager
After=network.target

[Service]
User=www-data
WorkingDirectory=/opt/raspi-webhost-manager
ExecStart=/opt/raspi-webhost-manager/venv/bin/python3 app.py
Restart=always

[Install]
WantedBy=multi-user.target
EOF

echo "✅ Enabling and starting systemd service..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable raspi-webhost
sudo systemctl start raspi-webhost

echo ""
echo "✅ Installation complete!"
echo "🌐 Open your browser and go to: http://<YOUR_PI_IP>:5000"
