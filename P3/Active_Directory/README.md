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

## 1. Vue d'ensemble

Brève description du rôle d'Active Directory dans l'infrastructure BillU.
- Domaine : **billu.local**
- Contrôleur de domaine principal : **DOM-AD-01**
- Version : **Windows Server 2022**

---
## 2. Objectifs

- Centraliser l'authentification des utilisateurs
- Gérer les comptes et groupes de l'entreprise BillU
- Structurer l'organisation avec les unités d'organisation (OU)

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

-  **README.md** - Ce fichier.
-  **[installation.md](components/Active_Directory/installation.md)** - Procédure d'installation complète.
-  **[configuration.md](components/Active_Directory/configuration.md)** - Configuration des OU, utilisateurs, GPO.
-  **Ressources/**
-  Screenshots/ - Captures d'écran.
-  Scripts/ - Scripts PowerShell. 

---
## 5. Services installés

 -  Active Directory Domain Services (AD DS)
 -  DNS Server (intégré AD)

---
## 6. Maintenance

#### 6.1 Sauvegardes

#### 6.2 Monitoring

---
## 7. Références

---
## 8. Historique des modifications

| Date       | Auteur | Modification              |
| ---------- | ------ | ------------------------- |
| 19/01/2026 | Franck | Création du README        |
| 19/01/2026 | Franck | Création du installation  |
| 19/01/2026 | Franck | Création du configuration |
| 20/01/2026 | Franck | Doc installation terminer |
|            |        |                           |

---
## 9. Contributeurs

- **Franck** - Installation et configuration

---

**Projet** : TSSR1025 Projet 3 - Build Your Infra
**Entreprise** : BillU
**Sprint** : 2
**Dernière mise à jour** : 20/01/2026

---
