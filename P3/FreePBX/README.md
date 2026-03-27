# FreePBX — Serveur de téléphonie BillU

## Sommaire

1. [Vue d'ensemble](#1-vue-densemble)
2. [Objectifs](#2-objectifs)
3. [Architecture](#3-architecture)
	- 3.1 [Serveur FreePBX](#31-serveur-freepbx)
	- 3.2 [Informations réseau](#32-informations-réseau)
	- 3.3 [Composants installés](#33-composants-installés)
4. [Structure de la documentation](#4-structure-de-la-documentation)
5. [Services installés](#5-services-installés)
6. [Fonctionnalités](#6-fonctionnalités)
	- 6.1 [Gestion des extensions SIP](#61-gestion-des-extensions-sip)
	- 6.2 [Authentification via Active Directory](#62-authentification-via-active-directory)
	- 6.3 [Interface web d'administration](#63-interface-web-dadministration)
7. [Maintenance](#7-maintenance)
	- 7.1 [Sauvegardes](#71-sauvegardes)
	- 7.2 [Monitoring](#72-monitoring)
8. [Références](#8-références)
9. [Historique des modifications](#9-historique-des-modifications)
10. [Contributeurs](#10-contributeurs)

---

## 1. Vue d'ensemble

Ce document présente l'installation et la configuration complète de FreePBX pour l'entreprise BillU. FreePBX est une solution open source de gestion de téléphonie sur IP (VoIP), permettant la gestion centralisée des extensions téléphoniques avec intégration à l'Active Directory de l'infrastructure BillU.

FreePBX permet :
- La gestion centralisée des postes téléphoniques de tous les utilisateurs du domaine `billu.lan`
- L'authentification et la synchronisation des utilisateurs via l'Active Directory (LDAP)
- La gestion des extensions SIP via Asterisk (chan_pjsip)
- L'administration des postes et de la téléphonie via l'interface web FreePBX

---

## 2. Objectifs

- **Centraliser la téléphonie** : Fournir un serveur VoIP unique pour l'ensemble des utilisateurs BillU
- **Intégrer l'Active Directory** : Synchroniser les utilisateurs via les comptes AD existants pour éviter la double gestion des identités
- **Sécuriser les accès** : Restreindre les accès SSH et administratifs via des comptes de service dédiés
- **Faciliter l'administration** : Utiliser l'interface web FreePBX pour la gestion des extensions et des utilisateurs
- **Simplifier l'ajout d'utilisateurs** : Associer chaque extension SIP à un compte AD existant

---

## 3. Architecture

#### 3.1 Serveur FreePBX

- **Hostname** : DOM-VOIP-01.billu.lan
- **OS** : FreePBX Distro (CentOS/RHEL based) — SNG7-PBX16-64bit
- **Services** : Asterisk 18, FreePBX 16, chan_pjsip
- **Fuseau horaire** : Europe/Paris

#### 3.2 Informations réseau

| Composant | Adresse IP | Description |
|-----------|------------|-------------|
| **Serveur FreePBX** | 172.16.13.7 | VLAN 130 - Fichier/Message/GLPI |
| **Serveur AD** | 172.16.12.1 | VLAN 120 - Contrôleur de domaine |
| **Interface Web (Admin)** | http://172.16.13.7 | Console d'administration FreePBX |

**VLAN** : VLAN 130 (172.16.13.0/29)  
**Domaine** : billu.lan  
**Compte admin** : domadmin

**Ports utilisés :**
- **80** : HTTP — Interface web FreePBX
- **22** : SSH — Administration système
- **5060** : SIP — Signalisation VoIP (UDP/TCP)
- **10000-20000** : RTP — Flux audio (UDP)
- **389** : LDAP — Requêtes vers l'Active Directory (interne)

#### 3.3 Composants installés

| Composant | Version | Rôle |
|-----------|---------|------|
| **FreePBX** | 16 | Interface de gestion de la téléphonie |
| **Asterisk** | 18 | Serveur PBX — gestion des appels |
| **chan_pjsip** | Intégré Asterisk | Protocole SIP pour les extensions |
| **User Management** | Module FreePBX | Gestion et synchronisation des utilisateurs |
| **System Admin** | Module FreePBX | Administration système et activation |

---

## 4. Structure de la documentation

- **README.md** - Ce fichier - Vue d'ensemble du projet
- **[installation.md](installation.md)** - Procédure d'installation complète de FreePBX :
  - Téléchargement de l'ISO FreePBX
  - Installation et configuration initiale
  - Modification du layout clavier en Azerty
  - Création de l'utilisateur SSH de service
  - Configuration de l'adresse IP statique
- **[configuration.md](configuration.md)** - Guide détaillé de configuration :
  - Première connexion et création du compte administrateur
  - Activation du serveur et des modules
  - Synchronisation des utilisateurs Active Directory
  - Ajout des extensions SIP
- **Ressources/**
  - installation_img/ - Captures d'écran de l'installation
  - configuration_img/ - Captures d'écran de la configuration

---

## 5. Services installés

### Services système
- **Asterisk** : Moteur PBX gérant les appels entrants, sortants et internes
- **chan_pjsip** : Module Asterisk pour la gestion des extensions SIP

### Interface web
- **FreePBX** : Interface d'administration web pour la gestion des extensions, utilisateurs et modules

### Compte de service Active Directory
- **Compte** : `svc-freepbx@billu.lan`
- **Rôle** : Lecture LDAP de l'annuaire AD pour la synchronisation des utilisateurs FreePBX
- **Mot de passe** : `Azerty1*`

### Comptes système
- **Compte SSH** : `svc-freepbx` — accès SSH restreint (PasswordAuthentication, PermitRootLogin désactivé)
- **Compte admin web** : `domadmin` — administration de l'interface FreePBX

### Configuration User Manager (AD)
- **Répertoire** : AD BillU
- **Protocole** : LDAP (Microsoft Active Directory)
- **Serveur AD** : 172.16.12.1:389
- **Base DN** : `dc=billu,dc=lan`
- **Synchronisation** : toutes les 1 heure

---

## 6. Fonctionnalités

#### 6.1 Gestion des extensions SIP

**Protocole configuré :**
- **SIP via chan_pjsip** : Extensions téléphoniques sur la plage `80xxx`

**Flux de création d'une extension :**
1. Ajout d'une extension SIP (chan_pjsip) via l'interface web
2. Attribution d'un numéro de poste (ex. `80100`)
3. Association à un utilisateur AD synchronisé (ex. `marie.meyer`)
4. Soumission et application de la configuration

#### 6.2 Authentification via Active Directory

**Intégration AD :**
- Synchronisation des utilisateurs FreePBX via le module User Management
- Requêtes LDAP vers l'AD sur le port 389 (172.16.12.1)
- Base DN : `dc=billu,dc=lan`
- Mise à jour automatique toutes les heures

**Paramètres de connexion LDAP :**
- Domaine : `billu.lan`
- Port : `389`
- Compte de service : `billu.lan` / `Azerty1*`

#### 6.3 Interface web d'administration

**FreePBX Admin :**
- URL : http://172.16.13.7
- Compte : `domadmin` / `Azerty1*`
- Fonctions : gestion des extensions, synchronisation AD, administration des modules

---

## 7. Maintenance

#### 7.1 Sauvegardes

- Sauvegarder la configuration Asterisk : `/etc/asterisk/`
- Sauvegarder la configuration réseau : `/etc/sysconfig/network-scripts/`
- Sauvegarder la configuration SSH : `/etc/ssh/sshd_config`
- Utiliser le module **Backup & Restore** de FreePBX pour les sauvegardes complètes de la configuration PBX

#### 7.2 Monitoring

```bash
# Vérifier l'état des services principaux
systemctl status asterisk
systemctl status httpd

# Consulter les logs Asterisk en temps réel
tail -f /var/log/asterisk/full

# Accéder à la console Asterisk
asterisk -rvvv

# Vérifier les extensions enregistrées
asterisk -rx "pjsip show endpoints"

# Vérifier les modules FreePBX
fwconsole ma list
```

---

## 8. Références

- https://www.freepbx.org/ - Site officiel FreePBX
- https://wiki.freepbx.org/ - Documentation FreePBX
- https://downloads.freepbxdistro.org/ISO/SNG7-PBX16-64bit-2302-1.iso - ISO utilisé
- https://www.asterisk.org/ - Documentation Asterisk
- https://wiki.freepbx.org/display/FPG/User+Management - Module User Management

---

## 9. Historique des modifications

| Date       | Auteur    | Modification                              |
| ---------- | --------- | ----------------------------------------- |
| 26/02/2026 | -         | Création du README FreePBX                |

---

## 10. Contributeurs

**Projet** : TSSR1025 Projet 3 - Build Your Infra  
**Entreprise** : BillU  
**Sprint** : 4  
**Dernière mise à jour** : 26/02/2026  

---
