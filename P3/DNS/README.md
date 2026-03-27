## Sommaire

1. [Vue d'ensemble](#1-vue-densemble)
2. [Objectifs](#2-objectifs)
3. [Architecture](#3-architecture)
    - [3.1 Serveurs impliqués](#31-serveurs-impliques)
    - [3.2 Information du domaine](#32-informations-du-domaine)
4. [Structure de la documentation](#4-structure-de-la-documentation)
5. [Services installés](#5-services-installes)
6. [Maintenance](#6-maintenance)
    - [6.1 Sauvegardes](#61-sauvegardes)
    - [6.2 Monitoring](#62-monitoring)
7. [Références](#7-references)
8. [Historique des modifications](#8-historique-des-modifications)
9. [Contributeurs](#9-contributeurs)

---
## 1. Vue d'ensemble

Ce document décrit la mise en place et l’administration du service DNS au sein d’une infrastructure Windows Server Active Directory.

Le service DNS est intégré au contrôleur de domaine et constitue un composant fondamental du bon fonctionnement d’Active Directory. Il permet la résolution de noms, la localisation des services AD (LDAP, Kerberos) et l’enregistrement dynamique des machines du domaine.

Le DNS fonctionne en interaction directe avec les services AD DS et DHCP.

---
## 2. Objectifs

Les objectifs de cette mise en place sont les suivants :

- Assurer la résolution de noms interne au domaine
- Permettre la localisation des services Active Directory
- Garantir l’enregistrement dynamique sécurisé des hôtes du domaine
- Mettre en place une zone directe et une zone inverse cohérentes
- Fournir une base DNS fiable pour les services DHCP et les postes clients

---
## 3. Architecture

#### 3.1 Serveurs impliqués

- **DOM-AD-01** (GUI) : Contrôleur de domaine principal + DNS intégré
- **DOM-DHCP-01** (CORE) : Serveur DHCP (rattaché au domaine)
 
#### 3.2 Information du domaine

- **Nom du domaine** : billu.lan
- **Nom NetBIOS** : BILLU
- **Niveau fonctionnel** : Windows Server 2022
- **Adresse IP AD** : 172.16.12.1/29

---
## 4. Structure de la documentation

-  **README.md**
-  **[installation.md](components/DNS/installation.md)** - Procédure d'installation complète.
-  **[configuration.md](components/DNS/configuration.md)** - Configuration des OU, utilisateurs, GPO.
-  **Ressources/**


---
## 5. Services installés

Les services et composants suivants sont utilisés :

- DNS Server (Windows Server)
- Active Directory Domain Services (AD DS)
- Les zones DNS sont intégrées à Active Directory et configurées pour des mises à jour dynamiques sécurisées.

---
## 6. Maintenance
### 6.1 Sauvegardes

### 6.2 Monitoring

---
## 7. Références

Documentation officielle Microsoft :

https://learn.microsoft.com/fr-fr/windows-server/networking/technologies/dhcp/quickstart-install-configure-dhcp-server?tabs=powershell

https://learn.microsoft.com/fr-fr/windows-server/networking/technologies/dhcp/dhcp-deploy-wps

---
## 8. Historique des modifications

| Date       | Auteur | Modification              |
| ---------- | ------ | ------------------------- |
| 22/01/2026 | Matthias | Création du README        |
| 22/01/2026 | Matthias | Création du installation  |
| 22/01/2026 | Matthias | Doc installation terminer |
|            |        |                           |

---
## 9. Contributeurs

- **Matthias** - Installation et configuration

---

**Projet** : TSSR1025 Projet 3 - Build Your Infra
**Entreprise** : BillU
**Sprint** : 2
**Dernière mise à jour** : 20/01/2026

---