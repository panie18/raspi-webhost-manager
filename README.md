# Raspi Webhost Manager

A modern Flask-based web interface to manage Apache websites on a Raspberry Pi — including Let's Encrypt SSL, automatic vHost configuration, and an optional Nextcloud installer.  
The interface features a clean **glassmorphism UI**, **DM Sans font**, animated rounded buttons, and a fully responsive layout.

---

## 🛠️ Quick Installation

Run this command on your Raspberry Pi OS (Lite or Desktop):

```bash
curl -sSL https://raw.githubusercontent.com/panie18/raspi-webhost-manager/main/install.sh | bash
```

Or manually specify your own repository:

```bash
install.sh https://github.com/panie18/raspi-webhost-manager.git
```

---

## 🌐 Web Interface Overview

After installation, open your browser and go to:

```
http://<your_raspberry_pi_ip>:5000
```

From there, you can:

- ➕ **Add a new website**
- 🗂️ Specify the **directory for website files** (e.g., `/var/www/mydomain.com`)
- ⚙️ Automatically create **Apache vHost** configuration files
- 🔐 Enable **free SSL certificates** with Let's Encrypt
- 🧹 View or delete existing domain configurations
- ☁️ **Install Nextcloud** with one click on a demo domain

---

## 🎨 Modern Glassmorphism UI

- Beautiful glass-effect card design
- **Google Font: DM Sans**
- Rounded buttons, shadows, and hover animations
- Fully responsive and mobile-friendly
- Built with HTML, TailwindCSS, and vanilla JS

---

## 📂 File & Directory Structure

Website content is stored in:

```
/var/www/<yourdomain>
```

Apache virtual host files are created in:

```
/etc/apache2/sites-available/
```

When a new domain is added:

1. A directory is created (if not existing)
2. Apache vHost file is generated (port 80 + 443)
3. Let's Encrypt certificate is requested
4. Site is enabled via `a2ensite`
5. Apache is reloaded

---

## 🔐 Let's Encrypt SSL Certificates

SSL certificates are automatically issued for each domain using **Certbot**.

A working domain (pointing to your Raspberry Pi IP) is required.  
Certificates are installed and configured into the Apache virtual host automatically.

---

## 🔄 Automatic Certificate Renewal

A cron job is created to renew all SSL certificates automatically every day at 03:00:

```cron
0 3 * * * certbot renew --quiet
```

This keeps your HTTPS setup always valid.

---

## ☁️ Nextcloud Installer (Optional)

You can install a **Nextcloud demo instance** from the web interface.  
Just choose a domain (e.g., `cloud.mydomain.com`) and click "Install Nextcloud".  
The installer will:

- Download and unzip Nextcloud
- Place it in `/var/www/<yourcloud>`
- Configure Apache + SSL
- Make it accessible via your chosen subdomain

---

## 💡 Features Summary

- ✅ One-command full setup
- 🌐 Web-based domain manager
- 🔧 Auto Apache vHost generation
- 🔐 Let's Encrypt integration
- ♻️ Auto certificate renewal with cron
- 🎨 Modern glassmorphism UI
- ☁️ Optional Nextcloud installer
- 🧰 Works on Raspberry Pi OS (Lite or Desktop)

---

## ⚙️ Technologies Used

- **Apache2** — HTTP server
- **Python 3 & Flask** — Backend API
- **Certbot** — SSL certificates via Let's Encrypt
- **Tailwind CSS** — Modern styling
- **Shell Scripts** — Installer & automation
- **Systemd** — Auto-start on boot

---

## 📋 License

MIT License

Created with ❤️ by [panie18](https://github.com/panie18)
