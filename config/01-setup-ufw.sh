
#!/bin/bash
# Configuration du pare-feu UFW sur la VM ubuntu-cible
# Autorise l'IP d'administration AVANT d'activer le pare-feu,
# pour ne jamais se bloquer soi-même.

set -e

ADMIN_IP="192.168.56.1"   # À adapter selon votre réseau

echo "Installation d'UFW..."
sudo apt update
sudo apt install -y ufw

echo "Autorisation de l'IP admin ($ADMIN_IP) sur le port SSH..."
sudo ufw allow from "$ADMIN_IP" to any port 22

echo "Autorisation générale du port SSH (22/tcp)..."
sudo ufw allow 22/tcp

echo "Activation d'UFW..."
sudo ufw --force enable

echo "État actuel :"
sudo ufw status numbered
