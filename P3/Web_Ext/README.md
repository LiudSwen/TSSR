## Sommaire

- [1. Vue d'ensemble](#1-vue-densemble)
- [2. Objectifs](#2-objectifs)
- [3. Architecture](#3-architecture)
  - [3.1 Serveurs impliqués](#31-serveurs-impliqués)
  - [3.2 Informations réseau](#32-informations-réseau)
- [4. Structure de la documentation](#4-structure-de-la-documentation)
- [5. Services installés](#5-services-installés)
- [6. Maintenance](#6-maintenance)
  - [6.1 Sauvegardes](#61-sauvegardes)
  - [6.2 Monitoring](#62-monitoring)
- [7. Références](#7-références)
- [8. Historique des modifications](#8-historique-des-modifications)
- [9. Contributeurs](#9-contributeurs)


---

## 1. Vue d'ensemble

Ce document décrit la mise en place et l’administration d’un serveur Web externe Apache positionné en DMZ au sein de l’infrastructure BillU.
Le serveur Web est installé sur un serveur Linux (Debian 12) hébergé sur Proxmox, dans un segment réseau DMZ isolé du LAN.
L’accès au service est contrôlé par le firewall pfSense via des règles NAT et des règles de filtrage spécifiques.

Le serveur fournit :

- Un site vitrine accessible en HTTP et HTTPS
- Un accès interne via DNS Active Directory
- Un accès externe via NAT WAN

---

## 2. Objectifs

Les objectifs de cette mise en place sont les suivants :

- Mettre en place un serveur Web externe isolé en DMZ
- Publier un site vitrine accessible depuis Internet
- Sécuriser les flux réseau via pfSense
- Mettre en œuvre HTTPS (certificat auto-signé)
- Permettre un accès d’administration sécurisé via SSH

---

## 3. Architecture

### 3.1 Serveurs impliqués

- **DOM-AD-01** : Contrôleur de domaine + DNS intégré
- **pfSense** : Firewall + NAT WAN
- **DOM-WEBEXT-01** : Serveur Web Apache (DMZ)
---

### 3.2 Informations réseau

- **Nom du domaine** : billu.lan
- **Serveur Web** : DOM-WEBEXT-01
- **Adresse IP DMZ** : 10.10.11.2
- **Accès interne DNS** : [www.billu.lan](http://www.billu.lan) → 10.10.11.2
- **Accès externe** : IP WAN → NAT vers 10.10.11.2

Flux autorisés :

- LAN → DMZ → Port 80 (HTTP)
- LAN → DMZ → Port 443 (HTTPS)
- LAN → DMZ → Port 22 (SSH administration)
- WAN → DMZ → Port 80 / 443 (publication site)

Blocage par défaut des flux LAN → DMZ non autorisés.

---

## 4. Structure de la documentation

- **README.md**
- **installation.md** – Procédure d'installation Apache et dépendances
- **configuration.md** – Configuration VirtualHost, SSL, DNS et firewall
- **Ressources/**

---

## 5. Services installés

Les services et composants suivants sont utilisés :

- Apache2 (Debian 12)
- OpenSSL (certificat auto-signé)
- OpenSSH Server
- pfSense (NAT et règles firewall)

---

## 6. Maintenance

### 6.1 Sauvegardes

---

### 6.2 Monitoring


---

## 7. Références

Documentation officielle Apache :
[https://httpd.apache.org/docs/2.4/](https://httpd.apache.org/docs/2.4/)

Documentation OpenSSL :
[https://www.openssl.org/docs/](https://www.openssl.org/docs/)

Documentation pfSense :
https://docs.netgate.com/pfsense/

---

## 8. Historique des modifications

| Date       | Auteur   | Modification                      |
| ---------- | -------- | --------------------------------- |
| 17/02/2026 | Matthias | Création du README Web EXT        |
| 18/02/2026 | Matthias | Création du INSTALLATION Web EXT  |
| 18/02/2026 | Matthias | Création du CONFIGURATION Web EXT |

---

## 9. Contributeurs

- Matthias – Installation et configuration du serveur Web externe

---

**Projet** : TSSR1025 Projet 3 - Build Your Infra  
**Entreprise** : BillU  
**Sprint** : 4  
**Dernière mise à jour** : 18/02/2026