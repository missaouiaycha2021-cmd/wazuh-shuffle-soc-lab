#!/bin/bash
# Installe un serveur FTP de démonstration (vsftpd) sur ubuntu-cible,
# utilisé pour la comparaison Wireshark FTP (clair) vs SFTP (chiffré).
# À exécuter UNIQUEMENT sur la VM cible, jamais sur la machine attaquante.

set -e

echo "Installation de vsftpd..."
sudo apt update
sudo apt install -y vsftpd

echo "Démarrage du service..."
sudo systemctl enable --now vsftpd
sudo systemctl status vsftpd --no-pager

echo ""
echo "Créez maintenant un compte de test avec :"
echo "  sudo adduser ftptest"
echo ""
echo "Ce compte servira uniquement à la démonstration Wireshark."
