#!/bin/bash
# Let's Encrypt Certbot Setup Script for Raspi Webhost Manager
# Made with ❤️ by Paulify Development

# Parameters: $1 = domain name, $2 = email

DOMAIN=$1
EMAIL=$2

if [ -z "$DOMAIN" ] || [ -z "$EMAIL" ]; then
    echo "❌ Missing parameters. Usage: $0 <domain_name> <email>"
    exit 1
fi

# Check if certbot is installed
if ! command -v certbot &> /dev/null; then
    echo "📦 Installing certbot..."
    apt update
    apt install -y certbot python3-certbot-apache
fi

# Check if the domain is configured in Apache
if [ ! -f "/etc/apache2/sites-available/${DOMAIN}.conf" ]; then
    echo "❌ Domain $DOMAIN is not configured in Apache. Please set up the site first."
    exit 1
fi

# Request certificate
echo "🔒 Requesting Let's Encrypt SSL certificate for $DOMAIN..."
certbot --apache -d "$DOMAIN" -d "www.$DOMAIN" --non-interactive --agree-tos --email "$EMAIL" --redirect

if [ $? -eq 0 ]; then
    echo "✅ SSL certificate has been successfully installed for $DOMAIN!"
    echo "🔄 Certificate will auto-renew when needed"
else
    echo "❌ Failed to obtain SSL certificate. Check the error messages above."
    exit 1
fi

# Ensure certbot renew is in crontab
if ! crontab -l | grep -q "certbot renew"; then
    (crontab -l 2>/dev/null; echo "0 3 * * * certbot renew --quiet") | crontab -
    echo "🕒 Added scheduled task for certificate renewal"
fi

echo "🎉 Let's Encrypt setup complete for ${DOMAIN}!"