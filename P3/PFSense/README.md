## Sommaire

1. [Vue d'ensemble](#1-vue-densemble)
2. [Objectifs](#2-objectifs)
3. [Architecture](#3-architecture)
	- 3.1 [Pare-Feu pfSense](#31-pare-feu-pfsense)
	- 3.2 [Interfaces réseau](#32-interfaces-réseau)
	- 3.3 [Réseaux internes (VLANs)](#33-réseaux-internes-vlans)
	- 3.4 [Serveurs DMZ](#34-serveurs-dmz)
4. [Structure de la documentation](#4-structure-de-la-documentation)
5. [Services installés](#5-services-installés)
6. [Sécurité](#6-sécurité)
	- 6.1 [Règles de pare-feu](#61-règles-de-pare-feu)
	- 6.2 [NAT et redirection de ports](#62-nat-et-redirection-de-ports)
	- 6.3 [Aliases](#63-aliases)
7. [Maintenance](#7-maintenance)
	- 7.1 [Sauvegardes](#71-sauvegardes)
	- 7.2 [Monitoring](#72-monitoring)
8. [Références](#8-références)
9. [Historique des modifications](#9-historique-des-modifications)
10. [Contributeurs](#10-contributeurs)

## 1. Vue d'ensemble

Ce document présente la configuration complète du pare-feu pfSense pour l'entreprise BillU. Le pare-feu assure la sécurité du réseau en filtrant le trafic entre Internet (WAN), le réseau interne (LAN) et la zone démilitarisée (DMZ) qui héberge les serveurs publics (web).

pfSense agit comme passerelle de sécurité principale et permet :
- La protection du réseau interne contre les menaces externes
- L'hébergement sécurisé de services publics en DMZ
- Le routage entre les différents segments réseau
- La mise en place de règles de filtrage

---
## 2. Objectifs

- **Sécuriser le périmètre réseau** : Protéger le réseau interne de BillU contre les accès non autorisés depuis Internet
- **Isoler la DMZ** : Empêcher tout accès direct entre la DMZ et le réseau interne tout en permettant les services publics
- **Contrôler les flux** : Implémenter des règles de pare-feu strictes basées sur le principe du moindre privilège
- **Permettre les services publics** : Exposer de manière sécurisée le serveur web vers Internet
- **Router le trafic interne** : Assurer la connectivité entre pfSense et les VLANs via le routeur core

---
## 3. Architecture

#### 3.1 Pare-Feu pfSense

- **Hostname** : Firewall
- **Domain** : billu.pfsense
- **Fuseau horaire** : Europe/Paris
- **Mot de passe admin** : Azerty1*

#### 3.2 Interfaces réseau

| Interface | Adresse IP | Masque | Description |
|-----------|------------|--------|-------------|
| **WAN** | 10.0.0.2 | /29 | Connexion Internet |
| **LAN** | 10.10.10.1 | /30 | Liaison vers routeur core |
| **DMZ** | 10.10.11.1 | /29 | Zone démilitarisée |

- **Gateway WAN** : 10.0.0.1
- **Gateway LAN (ROUTERCORE)** : 10.10.10.2

#### 3.3 Réseaux internes (VLANs)

Tous les VLANs de l'entreprise sont accessibles via le routeur core (172.16.0.0/16) :

| VLAN | Réseau | Description |
|------|--------|-------------|
| LAN | 10.10.10.0/30 | Liaison pfSense-Core |
| Interne | 172.16.0.0/24 | LAN Interne |
| VLAN 10 | 172.16.1.0/24 | DEV |
| VLAN 20 | 172.16.2.0/26 | COMMERCIAL |
| VLAN 30 | 172.16.3.0/26 | COMMUNICATION |
| VLAN 50 | 172.16.5.0/27 | JURIDIQUE |
| VLAN 60 | 172.16.6.0/27 | DSI |
| VLAN 70 | 172.16.7.0/27 | COMPTABILITE |
| VLAN 80 | 172.16.8.0/28 | DIRECTION |
| VLAN 90 | 172.16.9.0/28 | IMPRESSION |
| VLAN 100 | 172.16.10.0/28 | QHSE |
| VLAN 110 | 172.16.11.0/28 | RH |
| VLAN 120 | 172.16.12.0/29 | AD/DNS/DHCP |
| VLAN 130 | 172.16.13.0/29 | Fichier/Message/GLPI |
| VLAN 140 | 172.16.14.0/26 | INVITE |
| VLAN 150 | 172.16.15.0/29 | ADMIN |

#### 3.4 Serveurs DMZ

| Serveur | Adresse IP | Services |
|---------|------------|----------|
| **Serveur Web** | 10.10.11.2 | HTTP (80), HTTPS (443) |

---
## 4. Structure de la documentation

-  **README.md** - Ce fichier - Vue d'ensemble du projet
-  **[installation.md](components/PFSense/installation.md)** - Procédure d'installation complète de pfSense
-  **[configuration.md](components/PFSense/configuration.md)** - Guide détaillé de configuration :
    - Configuration initiale (interfaces, fuseau horaire, hostname)
    - Ajout de l'interface DMZ
    - Création des aliases (réseaux et ports)
    - Configuration NAT pour les services publics
    - Règles de pare-feu LAN et DMZ
    - Routage statique vers les VLANs
-  **Ressources/**
    - Screenshots/ - Captures d'écran de la configuration

---
## 5. Services installés

### Services réseau
- **NAT (Network Address Translation)** : Redirection de ports pour les services publics
- **Firewall** : Filtrage de paquets avec règles granulaires
- **Routage statique** : Route vers les VLANs internes (172.16.0.0/16) via le routeur core
- **DNS Resolver** : Résolution DNS pour les clients internes

### Services exposés publiquement (via NAT)
- **HTTP/HTTPS** : Site web public (redirections vers 10.10.11.2)

---
## 6. Sécurité

#### 6.1 Règles de pare-feu

**Principe appliqué** : Deny first, allow after (tout est bloqué par défaut, seul le trafic explicitement autorisé passe)

**Règles LAN** (4 règles)
1. Bloquer LAN → DMZ
2. Bloquer LAN → Réseaux privés WAN (RFC1918)
3. Autoriser DNS vers pfSense (port 53)
4. Autoriser accès Internet depuis réseaux internes

**Règles DMZ** (6 règles)
1. Bloquer DMZ → Réseaux internes
2. Bloquer DMZ → Interface LAN pfSense
3. Bloquer DMZ → WebGUI pfSense (ports 80, 443)
4. Autoriser HTTP/HTTPS → Serveur Web (10.10.11.2)
5. Autoriser DNS sortant depuis DMZ (port 53)
6. Autoriser HTTP/HTTPS sortant depuis DMZ (mises à jour)

#### 6.2 NAT et redirection de ports

| Service | Ports | Destination | Description |
|---------|-------|-------------|-------------|
| Site web public | 80, 443 | 10.10.11.2 | Serveur Web |

#### 6.3 Aliases

**Aliases réseaux**
- `Internal_Networks` : Tous les réseaux LAN et VLANs de l'entreprise
- `RFC1918` : Réseaux privés (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16)
- `DMZ_Network` : 10.10.11.0/29
- `DMZ_WebServer` : 10.10.11.2

**Aliases de ports**
- `Web_Ports` : 80 (HTTP), 443 (HTTPS)
- `DNS_Ports` : 53 (DNS)

---
## 7. Maintenance

#### 7.1 Sauvegardes



#### 7.2 Monitoring

- **Logs système** : Status > System Logs
- **États des services** : Status > Services
- **Monitoring réseau** : Diagnostics > States Summary
- **Alertes** : Activation des logs sur les règles de blocage critiques

---
## 8. Références

- https://www.pfsense.org/ - Site officiel de pfSense
- https://docs.netgate.com/pfsense/en/latest/ - Documentation officielle
- https://docs.netgate.com/pfsense/en/latest/recipes/example-basic-configuration.html - Configuration basique
- https://docs.netgate.com/pfsense/en/latest/nat/port-forwards.html - Configuration NAT
- https://docs.netgate.com/pfsense/en/latest/firewall/index.html - Règles de pare-feu

---
## 9. Historique des modifications

| Date       | Auteur    | Modification                           |
| ---------- | --------- | -------------------------------------- |
| 28/01/2026 | Christian | Création du README                     |
| 28/01/2026 | Christian | Complétion des sections manquantes     |
| 23/01/2026 | Christian | Création du installation               |
| 23/01/2026 | Christian | Création du configuration              |
| 29/01/2026 | Christian | Documentation installation terminée    |

---
## 10. Contributeurs

- **Christian** - Installation, configuration et documentation

---

**Projet** : TSSR1025 Projet 3 - Build Your Infra  
**Entreprise** : BillU  
**Sprint** : 2  
**Dernière mise à jour** : 28/01/2026  

---
