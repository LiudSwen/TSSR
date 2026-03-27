## Sommaire

1. [Vue d'ensemble](#1-vue-densemble)
2. [Objectifs](#2-objectifs)
3. [Architecture](#3-architecture)
	- 3.1 [Serveur GLPI](#31-serveur-glpi)
	- 3.2 [Informations réseau](#32-informations-réseau)
	- 3.3 [Composants installés](#33-composants-installés)
4. [Structure de la documentation](#4-structure-de-la-documentation)
5. [Services installés](#5-services-installés)
6. [Fonctionnalités](#6-fonctionnalités)
	- 6.1 [Authentification](#61-authentification)
	- 6.2 [Inventaire](#62-inventaire)
	- 6.3 [Gestion des tickets](#63-gestion-des-tickets)
7. [Maintenance](#7-maintenance)
	- 7.1 [Sauvegardes](#71-sauvegardes)
	- 7.2 [Monitoring](#72-monitoring)
8. [Références](#8-références)
9. [Historique des modifications](#9-historique-des-modifications)
10. [Contributeurs](#10-contributeurs)

## 1. Vue d'ensemble

Ce document présente l'installation et la configuration complète de GLPI (Gestionnaire Libre de Parc Informatique) pour l'entreprise BillU. GLPI est une solution open source de gestion des services informatiques (ITSM).

GLPI permet :
- La gestion centralisée de l'inventaire du parc informatique
- La gestion des tickets d'incidents et de demandes
- Le suivi des interventions et de la maintenance
- L'intégration avec l'Active Directory pour l'authentification
- L'inventaire automatique des postes via GLPI Agent

---
## 2. Objectifs

- **Centraliser la gestion du parc** : Inventorier et suivre tous les équipements informatiques de l'entreprise
- **Gérer les incidents** : Mettre en place un système de ticketing pour le support IT
- **Intégrer avec l'AD** : Synchroniser les utilisateurs depuis l'Active Directory de BillU
- **Automatiser l'inventaire** : Déployer GLPI Agent sur les postes clients pour un inventaire automatique
- **Sécuriser l'accès** : Désactiver les comptes par défaut et utiliser l'authentification centralisée

---
## 3. Architecture

#### 3.1 Serveur GLPI

- **Hostname** : DOM-GLPI-01
- **OS** : Debian 12 (ou version actuelle)
- **Services** : Apache2, PHP 8.4+, MariaDB
- **Fuseau horaire** : Europe/Paris

#### 3.2 Informations réseau

| Composant | Adresse IP | Description |
|-----------|------------|-------------|
| **Serveur GLPI** | 172.16.13.1 | VLAN 130 - Fichier/Message/GLPI |
| **Serveur AD** | 172.16.12.1 | VLAN 120 - AD/DNS/DHCP |

**VLAN** : VLAN 130 (172.16.13.0/29)  
**Accès web** : http://172.16.13.1/

#### 3.3 Composants installés

| Composant | Version | Rôle |
|-----------|---------|------|
| **MariaDB** | Dernière stable | Base de données GLPI |
| **Apache2** | 2.4+ | Serveur web |
| **PHP** | 8.4+ | Langage de script |
| **GLPI** | 11.0.5 (ou actuelle) | Application principale |
| **GLPI Agent** | Dernière version | Agent d'inventaire (postes clients) |

---
## 4. Structure de la documentation

- **README.md** - Ce fichier - Vue d'ensemble du projet
- **[installation.md](components/GLPI/installation.md)** - Procédure d'installation complète de GLPI :
  - Préparation du système Debian
  - Installation de MariaDB et création de la base de données
  - Installation d'Apache et PHP avec modules requis
  - Téléchargement et installation de GLPI
  - Configuration d'Apache (VirtualHost)
  - Installation via l'interface web
- **[configuration.md](components/GLPI/configuration.md)** - Guide détaillé de configuration :
  - Connexion et sécurisation post-installation
  - Création du compte Super-Admin
  - Désactivation des comptes par défaut
  - Synchronisation avec Active Directory
  - Importation des utilisateurs AD
  - Installation de GLPI Agent sur les postes
- **Ressources/**
  - glpi_img/ - Captures d'écran de l'installation et configuration

---
## 5. Services installés

### Services système
- **MariaDB** : Base de données relationnelle pour GLPI
- **Apache2** : Serveur web pour l'interface GLPI
- **PHP** : Moteur d'exécution de l'application GLPI
- **PHP-LDAP** : Module pour l'authentification Active Directory

### Application GLPI
- **GLPI Core** : Application principale de gestion
- **GLPI Agent** : Agent d'inventaire déployé sur les postes clients (via GPO)

### Base de données
- **Base** : glpidb
- **Utilisateur** : glpiuser
- **Encodage** : utf8mb4_unicode_ci

---
## 6. Fonctionnalités

#### 6.1 Authentification

**Méthodes d'authentification configurées :**
- **Base interne GLPI** : Compte Super-Admin local
- **Annuaire LDAP** : Synchronisation avec Active Directory BillU

**Configuration LDAP :**
- Serveur : 172.16.12.1
- Base DN : dc=billu,dc=lan
- Compte de liaison : svc_glpi@billu.lan
- Filtre : (objectClass=user)
- Champ identifiant : samaccountname
- Champ synchronisation : objectguid

#### 6.2 Inventaire

**Inventaire automatique :**
- GLPI Agent déployé via GPO sur les postes Windows
- Remontée automatique des informations matérielles et logicielles
- Mise à jour périodique de l'inventaire

#### 6.3 Gestion des tickets

- Système de ticketing pour incidents et demandes
- Attribution aux techniciens
- Suivi des interventions
- Historique des actions

---
## 7. Maintenance


---
## 8. Références

- https://glpi-project.org/ - Site officiel de GLPI
- https://glpi-install.readthedocs.io/ - Documentation d'installation
- https://github.com/glpi-project/glpi - Dépôt GitHub officiel


---
## 9. Historique des modifications

| Date       | Auteur    | Modification                           |
| ---------- | --------- | -------------------------------------- |
| 01/02/2026 | Christian | Création du README GLPI                |

---
## 10. Contributeurs

- **Christian** - Installation, configuration et documentation

---

**Projet** : TSSR1025 Projet 3 - Build Your Infra  
**Entreprise** : BillU  
**Sprint** : 2  
**Dernière mise à jour** : 01/02/2026  

---
