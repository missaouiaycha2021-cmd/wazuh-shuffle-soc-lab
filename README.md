# Automated SOC Lab — Wazuh (SIEM) + Shuffle (SOAR)

Lab de cybersécurité simulant une chaîne complète de détection et réponse
automatisée face à une attaque par force brute SSH.

## Objectif

Démontrer, dans un environnement isolé, comment un SIEM (Wazuh) et un SOAR
(Shuffle) peuvent détecter une attaque et y répondre automatiquement, sans
intervention humaine, en bloquant l'adresse IP de l'attaquant via un
pare-feu (UFW).

## Architecture

```
┌─────────────┐        ┌──────────────┐
│    Kali     │───────▶│ ubuntu-cible │
│ (attaquant) │  attack │   (victime)  │
└─────────────┘        └──────┬───────┘
                               │ logs
                               ▼
                        ┌──────────────┐
                        │    Wazuh     │
                        │ (SIEM)       │
                        └──────┬───────┘
                               │ webhook
                               ▼
                        ┌──────────────┐
                        │   Shuffle    │
                        │ (SOAR)       │
                        └──────┬───────┘
                               │ SSH + ufw deny
                               ▼
                        ubuntu-cible (bloquée)
```

| VM | IP | Rôle |
|----|-----|------|
| wazuh | 192.168.56.11 | Manager Wazuh + dashboard |
| ubuntu-cible | 192.168.56.10 | Machine protégée (agent Wazuh, SSH, UFW) |
| shuffle | 192.168.56.13 | Plateforme SOAR Shuffle |
| kali | 192.168.56.12 | Machine attaquante |

## Déroulement

1. **Reconnaissance** : scan Nmap de la cible (port 22 SSH détecté)
2. **Analyse de protocole** : capture Wireshark comparant FTP (clair) et SFTP
   (chiffré)
3. **Attaque** : force brute SSH avec Hydra
4. **Détection** : Wazuh déclenche une alerte (règles 5710/5712/5763)
5. **Orchestration** : l'alerte est envoyée à Shuffle via un webhook configuré
   dans `ossec.conf`
6. **Réponse automatique** : Shuffle extrait l'adresse IP source et exécute
   `ufw deny from <IP>` sur la machine cible via SSH

## Technologies utilisées

Wazuh, Shuffle, Docker, Docker Swarm, UFW, Hydra, Nmap, Wireshark, Ubuntu
Server, VirtualBox

## Résultats

- Alerte Wazuh déclenchée en quelques secondes après le début de l'attaque
- Chaîne Wazuh → Shuffle validée de bout en bout (exécution `FINISHED`)
- Blocage automatique de l'IP attaquante confirmé via `ufw status`

## Difficultés techniques rencontrées et résolues

| Problème | Cause | Solution |
|----------|-------|----------|
| OpenSearch tué en boucle | RAM insuffisante sur la VM Shuffle | Augmentation de la RAM, réduction des réplicas Swarm |
| Disque saturé | Volume LVM trop petit | `lvextend` pour agrandir le volume |
| Téléchargement Docker interrompu | DNS instable | Configuration de DNS publics (8.8.8.8, 1.1.1.1) |
| Actions Shuffle qui ne s'exécutent jamais | Réseau Docker Swarm manquant | `docker swarm init` |
| Timeout lors de l'exécution du workflow | Trop de réplicas Swarm déployés | `docker service scale <service>=1` |

## Limites et améliorations possibles

- La réponse est **réactive**, pas préventive : quelques tentatives
  d'authentification passent avant le blocage
- Pourrait être étendu avec **Suricata** (détection réseau), **TheHive**
  (gestion d'incidents), **Prometheus/Grafana** (supervision du SOC)
- Le blocage est actuellement manuel à lever ; une expiration automatique
  des règles UFW serait une amélioration pertinente

## Documentation complémentaire

- `docs/captures/` : captures d'écran de chaque étape
- `config/ossec.conf.example` : extrait de configuration Wazuh (anonymisé)
- `scripts/` : scripts d'installation réutilisables

## Avertissement

Ce projet est réalisé dans un environnement de laboratoire totalement
isolé, à des fins pédagogiques. Les outils utilisés (Hydra notamment) ne
doivent jamais être utilisés contre des systèmes sans autorisation
explicite.
