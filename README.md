# Raspi Webhost Manager

Moderne Flask-Webanwendung zur Verwaltung von Apache-Webseiten **mit Glassmorphism-UI**, Let's Encrypt‑SSL und optionaler Nextcloud-Installation.

## 🛠️ Schnelle Installation

```bash
curl -sSL https://raw.githubusercontent.com/panie18/raspi-webhost-manager/main/install.sh | bash
```



## 🌐 Webinterface

Nach der Installation: `http://<Raspberry_Pi_IP>:5000`

### Funktionen
- Neue Domain hinzufügen + automatische vHost‑ & SSL‑Konfiguration
- Ein‑Klick‑Nextcloud‑Installation
- Glassmorphism‑UI mit DM Sans, runden Buttons & Animationen

## 📂 Website‑Verzeichnisse

Seiten liegen in `/var/www/<domain>`.

## 🔄 Zertifikate

Certbot – Erneuerung täglich um 03:00 Uhr via Cron.

## 📝 Lizenz

MIT
