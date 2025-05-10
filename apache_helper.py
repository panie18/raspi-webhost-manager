import os

def create_vhost(domain, root_dir):
    os.makedirs(root_dir, exist_ok=True)
    conf_path = f"/etc/apache2/sites-available/{domain}.conf"
    vhost_conf = f"""<VirtualHost *:80>
    ServerName {domain}
    DocumentRoot {root_dir}

    <Directory {root_dir}>
        Options -Indexes +FollowSymLinks
        AllowOverride All
    </Directory>

    ErrorLog {{APACHE_LOG_DIR}}/{domain}_error.log
    CustomLog {{APACHE_LOG_DIR}}/{domain}_access.log combined
</VirtualHost>
"""
    with open(conf_path, 'w') as f:
        f.write(vhost_conf)

    os.system(f"a2ensite {domain}")
    os.system("systemctl reload apache2")
