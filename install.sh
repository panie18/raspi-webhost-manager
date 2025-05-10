#!/bin/bash

# Raspi Webhost Manager Installation Script
# Made with ❤️ by Paulify Development

echo "🚀 Starting Raspi Webhost Manager Installation..."

# Check if running as root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Please run as root (use sudo)"
  exit 1
fi

# Update system
echo "📦 Updating system packages..."
apt update
apt upgrade -y

# Install dependencies
echo "📦 Installing required packages..."
apt install -y apache2 php libapache2-mod-php php-curl php-cli php-fpm php-json php-common php-mbstring php-xml php-zip curl unzip certbot python3-certbot-apache git

# Enable required Apache modules
echo "🔌 Enabling Apache modules..."
a2enmod rewrite
a2enmod ssl
a2enmod headers
a2enmod proxy
a2enmod proxy_fcgi
systemctl restart apache2

# Create working directory
INSTALL_DIR="/opt/raspi-webhost-manager"
echo "📁 Creating installation directory: $INSTALL_DIR"
mkdir -p $INSTALL_DIR
cp -r ./* $INSTALL_DIR/

# Set up web interface
echo "🌐 Setting up web interface..."
mkdir -p /var/www/webhost-manager
cp -r ./www/* /var/www/webhost-manager/
chown -R www-data:www-data /var/www/webhost-manager

# Create Apache configuration
echo "🔧 Creating Apache configuration..."
cat > /etc/apache2/sites-available/webhost-manager.conf << EOF
<VirtualHost *:8080>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/webhost-manager
    ErrorLog \${APACHE_LOG_DIR}/webhost-manager-error.log
    CustomLog \${APACHE_LOG_DIR}/webhost-manager-access.log combined

    <Directory /var/www/webhost-manager>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

# Configure Apache to listen on port 8080
echo "Listen 8080" >> /etc/apache2/ports.conf

# Enable site
a2ensite webhost-manager.conf

# Add executable permissions to scripts
chmod +x $INSTALL_DIR/scripts/*.sh

# Create a systemd service for the Raspi Webhost Manager
echo "🔄 Creating systemd service..."
cat > /etc/systemd/system/webhost-manager.service << EOF
[Unit]
Description=Raspi Webhost Manager Service
After=network.target

[Service]
ExecStart=/usr/bin/php -S 0.0.0.0:9001 -t $INSTALL_DIR/api
Restart=on-failure
User=www-data
Group=www-data

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
systemctl enable webhost-manager.service
systemctl start webhost-manager.service

# Create API directory and basic endpoints
mkdir -p $INSTALL_DIR/api
cat > $INSTALL_DIR/api/index.php << EOF
<?php
header('Content-Type: application/json');

// Basic API router
\$requestUri = \$_SERVER['REQUEST_URI'];
\$endpoint = trim(parse_url(\$requestUri, PHP_URL_PATH), '/');
\$method = \$_SERVER['REQUEST_METHOD'];

// Simple API endpoints
switch (\$endpoint) {
    case 'status':
        echo json_encode([
            'status' => 'online',
            'version' => '1.0.0',
            'server' => 'Raspberry Pi',
            'services' => [
                'apache' => serviceStatus('apache2'),
                'mysql' => serviceStatus('mariadb'),
                'php' => true
            ]
        ]);
        break;
    
    case 'websites':
        if (\$method === 'GET') {
            // Get all websites
            echo json_encode(getWebsites());
        } else if (\$method === 'POST') {
            // Create a new website
            \$data = json_decode(file_get_contents('php://input'), true);
            echo json_encode(createWebsite(\$data));
        }
        break;
    
    default:
        http_response_code(404);
        echo json_encode(['error' => 'Endpoint not found']);
}

// Helper functions
function serviceStatus(\$service) {
    \$status = shell_exec("systemctl is-active " . escapeshellarg(\$service));
    return trim(\$status) === 'active';
}

function getWebsites() {
    // In a real app, this would query Apache's config
    return [];
}

function createWebsite(\$data) {
    // In a real app, this would create the website
    if (!isset(\$data['siteName']) || !isset(\$data['documentRoot'])) {
        http_response_code(400);
        return ['error' => 'Missing required fields'];
    }
    
    return ['success' => true, 'message' => 'Website created successfully'];
}
EOF

# Create a sudoers entry for the web server to run specific scripts
echo "🔐 Setting up sudo permissions for web server..."
cat > /etc/sudoers.d/webhost-manager << EOF
www-data ALL=(ALL) NOPASSWD: $INSTALL_DIR/scripts/setup-apache.sh
www-data ALL=(ALL) NOPASSWD: $INSTALL_DIR/scripts/setup-certbot.sh
www-data ALL=(ALL) NOPASSWD: $INSTALL_DIR/scripts/setup-nextcloud.sh
www-data ALL=(ALL) NOPASSWD: /bin/systemctl restart apache2
EOF

# Create dummy folders and placeholder files for screenshots
mkdir -p $INSTALL_DIR/www/img
mkdir -p $INSTALL_DIR/www/screenshots
touch $INSTALL_DIR/www/screenshots/dashboard.png
touch $INSTALL_DIR/www/screenshots/apache-config.png
touch $INSTALL_DIR/www/screenshots/ssl-certificates.png
touch $INSTALL_DIR/www/screenshots/nextcloud-setup.png

# Create placeholder logo
cat > $INSTALL_DIR/www/img/logo.png << EOF
iVBORw0KGgoAAAANSUhEUgAAAGQAAABkCAYAAABw4pVUAAAABmJLR0QA/wD/AP+gvaeTAAAB1klEQVR4nO3cwUrDQBSF4dOqK1HwDdy6cqFP78qKa+miL+DCja+grgoqLowYiBNiMnPl/D/czQTuOSe5FHJbAAAAAAAAAADQqKtge2fbvfzsfj++i6/zpnIwzH4WqJKzupDDm7m62ptrP0a1ZjfBqoZiSNULVS1UYcjPP5zV4U5trZlc/9ZCa2t20taBKNXuDzUMUQxDBEMUwxDBEMUwRDBEMQwRDFEMQwRDFMMQwRDFEMUwRDBEMQwRDFEMQwRDFMMQwRDFMEQwRDEMEQxRDFEMQwRDFMMQwRDFMEQwRDEMEQxRDFEMQwRDFMMQwRDFMEQwRDBEMQwRDFFFbsPXfshFv7+4Wbzrff4U3HwTbO/o1GrrVeVQ7Xw4Kt7HXr6+xA8WrCfP6Vyb4+/Pr87rkRlFcEhpzVZGIZtLgkrnwcx5UU4pi3JmHZ0lzaK9bJTkFHYwjBPSw1HikJyCSudBwXlfztGcwrJGSXZhB3/+FDTVKMkubGbNDympM0pyC8vuhXSP8KZOyW/m2MVUL6Sj56SiDrEPpkZkD7aA1D2Gc6oImXGUVBdS0ShpZkjtUdLUkNqjpLkhNUdJk0NqEDrFBwAAAAAAAICm/QLcUlKIHzoPWAAAAABJRU5ErkJggg==
EOF

# Create placeholder user image
cat > $INSTALL_DIR/www/img/user.png << EOF
iVBORw0KGgoAAAANSUhEUgAAAGQAAABkCAYAAABw4pVUAAAABmJLR0QA/wD/AP+gvaeTAAAFT0lEQVR4nO2dXYhVVRTHf2OmZjqN+VFqViPRF9EHFtEDRVQQlBG9BEFFRBGW0EOBREQkKERFRA9BRfQgGBFB0YNEiUaWaFGRH2mNTpqN4ziOzYyz
EOF

# Copy the system PHP file
cat > $INSTALL_DIR/api/system.php << EOF
<?php
// System monitoring functions
header('Content-Type: application/json');

// Get requested action
\$action = isset(\$_GET['action']) ? \$_GET['action'] : 'all';

switch (\$action) {
    case 'cpu':
        echo json_encode(getCpuUsage());
        break;
    case 'memory':
        echo json_encode(getMemoryUsage());
        break;
    case 'disk':
        echo json_encode(getDiskUsage());
        break;
    case 'uptime':
        echo json_encode(getUptime());
        break;
    case 'services':
        echo json_encode(getServicesStatus());
        break;
    case 'all':
    default:
        echo json_encode([
            'cpu' => getCpuUsage(),
            'memory' => getMemoryUsage(),
            'disk' => getDiskUsage(),
            'uptime' => getUptime(),
            'services' => getServicesStatus(),
            'timestamp' => date('Y-m-d H:i:s')
        ]);
        break;
}

function getCpuUsage() {
    // Get CPU usage from /proc/stat
    \$load = sys_getloadavg();
    
    // On Raspberry Pi, get temperature if available
    \$temp = null;
    if (file_exists('/sys/class/thermal/thermal_zone0/temp')) {
        \$temp = intval(file_get_contents('/sys/class/thermal/thermal_zone0/temp')) / 1000;
    }
    
    // Get CPU usage percentage
    \$stat1 = file('/proc/stat');
    sleep(1);
    \$stat2 = file('/proc/stat');
    
    \$cpu_info1 = explode(" ", preg_replace("!cpu +!", "", \$stat1[0]));
    \$cpu_info2 = explode(" ", preg_replace("!cpu +!", "", \$stat2[0]));
    
    \$diff_idle = \$cpu_info2[3] - \$cpu_info1[3];
    \$diff_total = (\$cpu_info2[0] + \$cpu_info2[1] + \$cpu_info2[2] + \$cpu_info2[3]) - 
                 (\$cpu_info1[0] + \$cpu_info1[1] + \$cpu_info1[2] + \$cpu_info1[3]);
    
    \$diff_usage = \$diff_total - \$diff_idle;
    \$percent = (\$diff_usage / \$diff_total) * 100;
    
    return [
        'percent' => round(\$percent, 1),
        'load' => \$load,
        'temperature' => \$temp
    ];
}

function getMemoryUsage() {
    \$free = shell_exec('free -m');
    \$free = (string)trim(\$free);
    \$free_arr = explode("\\n", \$free);
    \$mem = explode(" ", \$free_arr[1]);
    \$mem = array_filter(\$mem);
    \$mem = array_merge(\$mem);
    
    \$memory_usage = \$mem[2]/\$mem[1] * 100;
    
    return [
        'total' => \$mem[1],
        'used' => \$mem[2],
        'free' => \$mem[3],
        'percent' => round(\$memory_usage, 1)
    ];
}

function getDiskUsage() {
    \$disktotal = disk_total_space('/');
    \$diskfree = disk_free_space('/');
    \$diskused = \$disktotal - \$diskfree;
    \$diskusage = (\$diskused / \$disktotal) * 100;
    
    return [
        'total' => round(\$disktotal / 1024 / 1024 / 1024, 2),
        'used' => round(\$diskused / 1024 / 1024 / 1024, 2),
        'free' => round(\$diskfree / 1024 / 1024 / 1024, 2),
        'percent' => round(\$diskusage, 1)
    ];
}

function getUptime() {
    \$uptime = shell_exec('cat /proc/uptime');
    \$uptime = explode(" ", \$uptime)[0];
    
    \$days = floor(\$uptime / 86400);
    \$hours = floor((\$uptime % 86400) / 3600);
    \$minutes = floor((\$uptime % 3600) / 60);
    \$seconds = \$uptime % 60;
    
    return [
        'seconds' => round(\$uptime),
        'formatted' => "{\$days}d {\$hours}h {\$minutes}m {\$seconds}s"
    ];
}

function getServicesStatus() {
    // Check status of important services
    return [
        'apache' => isServiceRunning('apache2'),
        'mysql' => isServiceRunning('mysql') || isServiceRunning('mariadb'),
        'php' => true,
        'certbot' => file_exists('/usr/bin/certbot') || file_exists('/usr/local/bin/certbot')
    ];
}

function isServiceRunning(\$service) {
    \$status = shell_exec("systemctl is-active " . escapeshellarg(\$service) . " 2>&1");
    return trim(\$status) === 'active';
}
EOF

# Restart Apache
systemctl restart apache2

# Get the current IP address
IP_ADDRESS=$(hostname -I | awk '{print $1}')

echo "✅ Installation complete!"
echo "🌍 You can access the Raspi Webhost Manager at: http://$IP_ADDRESS:8080"
echo "Made with ❤️ by Paulify Development"