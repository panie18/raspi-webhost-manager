import os

def obtain_ssl(domain):
    os.system(f"certbot --apache -d {domain} --non-interactive --agree-tos -m admin@{domain}")
