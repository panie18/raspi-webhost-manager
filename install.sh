#!/bin/bash

# Update system
sudo apt update && sudo apt upgrade -y

# Install core packages
sudo apt install -y apache2 python3 python3-pip git certbot python3-certbot-apache

# Clone repository (assumes public GitHub repo exists)
REPO=${1:-"https://github.com/USERNAME/raspi-webhost-manager.git"}
sudo git clone "$REPO" /opt/raspi-webhost-manager

# Install Python requirements
cd /opt/raspi-webhost-manager
sudo pip3 install -r requirements.txt

# Create systemd service for Flask app
sudo bash -c 'cat > /etc/systemd/system/raspi-webhost-manager.service <<EOF
[Unit]
Description=Raspi Webhost Manager
After=network.target

[Service]
User=root
WorkingDirectory=/opt/raspi-webhost-manager
ExecStart=/usr/bin/flask run --host=0.0.0.0 --port=5000
Environment=FLASK_APP=app
Restart=always

[Install]
WantedBy=multi-user.target
EOF'

sudo systemctl daemon-reload
sudo systemctl enable raspi-webhost-manager --now

# Cronjob for automatic cert renewal
(crontab -l 2>/dev/null; echo "0 3 * * * /usr/bin/certbot renew --quiet") | crontab -

echo "Installation complete. Open http://<Pi_IP>:5000 in your browser."
