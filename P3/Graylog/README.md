## Sommaire

1. [Vue d'ensemble](#1-vue-densemble)
2. [Objectifs](#2-objectifs)
3. [Architecture](#3-architecture)
	- 3.1 [Serveur Graylog](#31-serveur-graylog)
	- 3.2 [Informations réseau](#32-informations-réseau)
	- 3.3 [Composants installés](#33-composants-installés)
4. [Structure de la documentation](#4-structure-de-la-documentation)
5. [Services installés](#5-services-installés)
6. [Fonctionnalités](#6-fonctionnalités)
	- 6.1 [Collecte de logs](#61-collecte-de-logs)
	- 6.2 [Gestion des streams](#62-gestion-des-streams)
	- 6.3 [Monitoring et alertes](#63-monitoring-et-alertes)
7. [Maintenance](#7-maintenance)
	- 7.1 [Sauvegardes](#71-sauvegardes)
	- 7.2 [Monitoring](#72-monitoring)
8. [Références](#8-références)
9. [Historique des modifications](#9-historique-des-modifications)
10. [Contributeurs](#10-contributeurs)

## 1. Vue d'ensemble

Ce document présente l'installation et la configuration complète de Graylog pour l'entreprise BillU. Graylog est une solution open source de gestion centralisée des logs permettant la collecte, l'analyse et le monitoring en temps réel des événements système.

Graylog permet :
- La collecte centralisée des logs de l'ensemble de l'infrastructure (Windows et Linux)
- L'analyse et la recherche en temps réel des événements
- La création de streams dédiés par serveur pour une meilleure organisation
- L'alerting et le monitoring des événements critiques
- La visualisation et la création de tableaux de bord personnalisés

---
## 2. Objectifs

- **Centraliser la collecte des logs** : Agréger tous les logs des serveurs Windows et Linux de l'infrastructure BillU
- **Organiser par streams** : Créer des flux dédiés pour chaque serveur (AD, DHCP, GLPI, Zabbix)
- **Monitoring en temps réel** : Surveiller les événements système et détecter les anomalies
- **Sécuriser l'accès** : Créer des comptes administrateurs dédiés et gérer les permissions
- **Faciliter l'analyse** : Permettre la recherche et l'investigation rapide sur l'ensemble des logs

---
## 3. Architecture

#### 3.1 Serveur Graylog

- **Hostname** : DOM-LOGS-01
- **OS** : Debian 12
- **Services** : MongoDB, OpenSearch, Graylog Server
- **Fuseau horaire** : Europe/Paris

#### 3.2 Informations réseau

| Composant | Adresse IP | Description |
|-----------|------------|-------------|
| **Serveur Graylog** | 172.16.13.2 | VLAN 130 - Fichier/Message/GLPI |
| **Interface Web** | http://172.16.13.2:9000 | Console d'administration Graylog |

**VLAN** : VLAN 130 (172.16.13.0/29)  
**Accès web** : http://172.16.13.2:9000

**Ports utilisés :**
- **9000** : Interface web Graylog
- **12201** : GELF TCP (logs Windows via NXLog)
- **514** : Syslog UDP (logs Linux via rsyslog)
- **9200** : OpenSearch (interne)
- **27017** : MongoDB (interne)

#### 3.3 Composants installés

| Composant | Version | Rôle |
|-----------|---------|------|
| **MongoDB** | 8.0 | Base de données pour la configuration Graylog |
| **OpenSearch** | 2.x | Moteur de recherche et stockage des logs |
| **Graylog Server** | 7.0 | Application principale de gestion des logs |
| **NXLog** | Dernière stable | Agent de collecte pour Windows |
| **rsyslog** | Intégré Debian | Agent de collecte pour Linux |

---
## 4. Structure de la documentation

- **README.md** - Ce fichier - Vue d'ensemble du projet
- **[installation.md](components/Graylog/installation.md)** - Procédure d'installation complète de Graylog :
  - Préparation du système Debian
  - Installation de MongoDB
  - Installation et configuration d'OpenSearch
  - Installation et configuration de Graylog Server
  - Première connexion à l'interface web
- **[configuration.md](components/Graylog/configuration.md)** - Guide détaillé de configuration :
  - Création du compte administrateur
  - Configuration des agents Windows (NXLog)
  - Configuration des agents Linux (rsyslog)
  - Création des inputs (GELF TCP et Syslog UDP)
  - Création des streams par serveur
- **Ressources/**
  - graylog_img/ - Captures d'écran de l'installation et configuration

---
## 5. Services installés

### Services système
- **MongoDB** : Base de données NoSQL pour stocker la configuration Graylog
- **OpenSearch** : Moteur de recherche distribué pour l'indexation et la recherche de logs
- **Graylog Server** : Application serveur principale

### Agents de collecte
- **NXLog** : Agent déployé sur les serveurs Windows
- **rsyslog** : Service système Linux pour l'envoi des logs

### Configuration MongoDB
- **Port** : 27017 (localhost uniquement)
- **Service** : mongod

### Configuration OpenSearch
- **Cluster name** : graylog
- **Node name** : DOM-LOGS-01
- **Network host** : 127.0.0.1
- **Port** : 9200
- **Mémoire JVM** : 4 Go (configurable selon les ressources)

### Configuration Graylog
- **Port web** : 9000
- **Compte admin par défaut** : admin
- **Inputs configurés** :
  - NXLog_TCP_Windows (GELF TCP - Port 12201)
  - SYSLOG_UDP_Linux (Syslog UDP - Port 514)

---
## 6. Fonctionnalités

#### 6.1 Collecte de logs

**Sources de logs configurées :**
- **Serveurs Windows** : Via NXLog en GELF TCP sur le port 12201
- **Serveurs Linux** : Via rsyslog en Syslog UDP sur le port 514

**Configuration Windows (NXLog) :**
- Protocole : GELF TCP
- Port : 12201
- Module : om_tcp
- Hostname automatique via `$Hostname = hostname()`

**Configuration Linux (rsyslog) :**
- Protocole : Syslog UDP
- Port : 514
- Fichier de configuration : `/etc/rsyslog.d/90-graylog.conf`

#### 6.2 Gestion des streams

**Streams créés pour l'infrastructure :**
- **DOM-AD-01** : Serveur Active Directory
- **DOM-DHCP-01** : Serveur DHCP
- **DOM-GLPI-01** : Serveur GLPI
- **DOM-ZABBIX-01** : Serveur Zabbix

**Configuration des streams :**
- Routage par nom de source (hostname)
- Type de filtre : Contain
- Collaborateur : DOM Admin (rôle Manager)
- Activation manuelle après création

#### 6.3 Monitoring et alertes

- Visualisation en temps réel des logs
- Recherche avancée avec filtres
- Création de tableaux de bord personnalisés
- Configuration d'alertes (à configurer selon les besoins)

---
## 7. Références

- https://www.graylog.org/ - Site officiel de Graylog
- https://go2docs.graylog.org/ - Documentation officielle Graylog
- https://github.com/graylog2 - Dépôt GitHub officiel
- https://nxlog.co/ - Documentation NXLog pour Windows
- https://opensearch.org/ - Documentation OpenSearch
- https://www.mongodb.com/ - Documentation MongoDB

---
## 8. Historique des modifications

| Date       | Auteur    | Modification                           |
| ---------- | --------- | -------------------------------------- |
| 07/02/2026 | Christian | Création du README Graylog             |

---
## 9. Contributeurs

- **Christian** - Installation, configuration et documentation

---

**Projet** : TSSR1025 Projet 3 - Build Your Infra  
**Entreprise** : BillU  
**Sprint** : 3  
**Dernière mise à jour** : 07/02/2026  

---
