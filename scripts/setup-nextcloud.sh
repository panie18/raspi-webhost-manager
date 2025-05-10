#!/bin/bash
# Nextcloud Setup Script for Raspi Webhost Manager
# Made with ❤️ by Paulify Development

# Parameters: $1 = site name, $2 = document root, $3 = admin username, $4 = admin password

SITE_NAME=$1
DOC_ROOT=$2
ADMIN_USER=$3
ADMIN_PASS=$4

if [ -z "$SITE_NAME" ] || [ -z "$DOC_ROOT" ] || [ -z "$ADMIN_USER" ] || [ -z "$ADMIN_PASS" ]; then
    echo "❌ Missing parameters. Usage: $0 <site_name> <document_root> <admin_username> <admin_password>"
    exit 1
fi

# Install required PHP extensions and MySQL
echo "📦 Installing required packages..."
apt update
apt install -y php php-gd php-curl php-zip php-dom php-xml php-mbstring php-mysql php-bz2 php-intl php-bcmath php-gmp php-imagick mariadb-server

# Configure MySQL
echo "🔧 Configuring MySQL..."
systemctl start mariadb
systemctl enable mariadb

# Create database and user
DB_NAME="nextcloud_db"
DB_USER="nextcloud_user"
DB_PASS=$(openssl rand -base64 12)

mysql -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;"
mysql -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
mysql -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';"
mysql -e "FLUSH PRIVILEGES;"

echo "📊 Created database: ${DB_NAME}"

# Download and extract Nextcloud
echo "⬇️ Downloading Nextcloud..."
NEXTCLOUD_VERSION="25.0.3"
NEXTCLOUD_URL="https://download.nextcloud.com/server/releases/nextcloud-${NEXTCLOUD_VERSION}.zip"

if [ ! -d "$DOC_ROOT" ]; then
    mkdir -p "$DOC_ROOT"
fi

cd /tmp
wget -O nextcloud.zip "$NEXTCLOUD_URL"
unzip -q nextcloud.zip
cp -r nextcloud/* "$DOC_ROOT/"
rm -rf nextcloud nextcloud.zip

# Set permissions
echo "🔐 Setting permissions..."
chown -R www-data:www-data "$DOC_ROOT"
find "$DOC_ROOT/" -type d -exec chmod 750 {} \;
find "$DOC_ROOT/" -type f -exec chmod 640 {} \;

# Create Apache virtual host configuration
VHOST_CONF="/etc/apache2/sites-available/${SITE_NAME}.conf"

cat > "$VHOST_CONF" << EOF
<VirtualHost *:80>
    ServerName ${SITE_NAME}
    ServerAlias www.${SITE_NAME}
    DocumentRoot ${DOC_ROOT}
    
    <Directory ${DOC_ROOT}>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog \${APACHE_LOG_DIR}/${SITE_NAME}-error.log
    CustomLog \${APACHE_LOG_DIR}/${SITE_NAME}-access.log combined
    
    <IfModule mod_headers.c>
      Header always set Strict-Transport-Security "max-age=15552000; includeSubDomains"
    </IfModule>
</VirtualHost>
EOF

echo "🔧 Created virtual host configuration: $VHOST_CONF"

# Enable the site and required modules
a2ensite "${SITE_NAME}.conf"
a2enmod rewrite
a2enmod headers
a2enmod env
a2enmod dir
a2enmod mime

# Reload Apache
systemctl restart apache2
echo "🔄 Restarted Apache"

# Create Nextcloud config file
CONFIG_PHP="${DOC_ROOT}/config/config.php"
if [ ! -d "${DOC_ROOT}/config" ]; then
    mkdir -p "${DOC_ROOT}/config"
fi

# Create installation command
INSTALL_CMD="sudo -u www-data php ${DOC_ROOT}/occ maintenance:install \
  --database mysql \
  --database-name ${DB_NAME} \
  --database-user ${DB_USER} \
  --database-pass ${DB_PASS} \
  --admin-user ${ADMIN_USER} \
  --admin-pass ${ADMIN_PASS} \
  --data-dir ${DOC_ROOT}/data"

# Execute installation command
echo "🚀 Installing Nextcloud..."
eval $INSTALL_CMD

# Get server IP
SERVER_IP=$(hostname -I | awk '{print $1}')

# Update trusted domains
sudo -u www-data php ${DOC_ROOT}/occ config:system:set trusted_domains 1 --value="${SITE_NAME}"
sudo -u www-data php ${DOC_ROOT}/occ config:system:set trusted_domains 2 --value="www.${SITE_NAME}"
sudo -u www-data php ${DOC_ROOT}/occ config:system:set trusted_domains 3 --value="${SERVER_IP}"

echo "✅ Nextcloud installation complete!"
echo "🌍 You can access Nextcloud at: http://${SITE_NAME} or http://${SERVER_IP}"
echo "👤 Admin username: ${ADMIN_USER}"
echo "🔑 Admin password: ${ADMIN_PASS}"
echo "🗄️ Database name: ${DB_NAME}"
echo "👤 Database user: ${DB_USER}"
echo "🔑 Database password: ${DB_PASS}"

# Save credentials to a file for reference
CREDS_FILE="/root/nextcloud_credentials_${SITE_NAME}.txt"
cat > "$CREDS_FILE" << EOF
Nextcloud Installation Credentials
=================================
Site: ${SITE_NAME}
URL: http://${SITE_NAME} or http://${SERVER_IP}

Admin Username: ${ADMIN_USER}
Admin Password: ${ADMIN_PASS}

Database Name: ${DB_NAME}
Database User: ${DB_USER}
Database Password: ${DB_PASS}

Created: $(date)
EOF

chmod 600 "$CREDS_FILE"
echo "📝 Credentials saved to: $CREDS_FILE"

echo "🎉 Nextcloud setup complete for ${SITE_NAME}!"