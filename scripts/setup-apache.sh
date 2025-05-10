#!/bin/bash
# Apache Setup Script for Raspi Webhost Manager
# Made with ❤️ by Paulify Development

# Parameters: $1 = site name, $2 = document root

SITE_NAME=$1
DOC_ROOT=$2

if [ -z "$SITE_NAME" ] || [ -z "$DOC_ROOT" ]; then
    echo "❌ Missing parameters. Usage: $0 <site_name> <document_root>"
    exit 1
fi

# Create document root directory if it doesn't exist
if [ ! -d "$DOC_ROOT" ]; then
    mkdir -p "$DOC_ROOT"
    chown -R www-data:www-data "$DOC_ROOT"
    chmod -R 755 "$DOC_ROOT"
    echo "📁 Created document root: $DOC_ROOT"
fi

# Create a default index.html file
if [ ! -f "$DOC_ROOT/index.html" ]; then
    cat > "$DOC_ROOT/index.html" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Welcome to $SITE_NAME</title>
    <style>
        body {
            font-family: 'Arial', sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            text-align: center;
        }
        h1 {
            color: #2c3e50;
        }
        .container {
            border: 1px solid #ddd;
            border-radius: 8px;
            padding: 20px;
            margin-top: 20px;
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }
        footer {
            margin-top: 30px;
            font-size: 0.8em;
            color: #888;
        }
    </style>
</head>
<body>
    <h1>Welcome to $SITE_NAME</h1>
    <div class="container">
        <p>Your website has been successfully created with Raspi Webhost Manager!</p>
        <p>Replace this file with your own content.</p>
    </div>
    <footer>
        Created with Raspi Webhost Manager<br>
        Made with ❤️ by Paulify Development
    </footer>
</body>
</html>
EOF
    echo "📄 Created default index.html"
fi

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
</VirtualHost>
EOF

echo "🔧 Created virtual host configuration: $VHOST_CONF"

# Enable the site
a2ensite "${SITE_NAME}.conf"
echo "✅ Enabled site: ${SITE_NAME}"

# Reload Apache
systemctl reload apache2
echo "🔄 Reloaded Apache configuration"

echo "🎉 Apache setup complete for ${SITE_NAME}!"