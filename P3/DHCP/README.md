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

Ce document décrit la mise en place et l’administration du service DHCP au sein d’une infrastructure Windows Server Active Directory.

Le service DHCP est installé sur un serveur Windows Server Core, tandis que son administration est réalisée à distance depuis un serveur Windows Server GLI (GUI). Cette séparation respecte les bonnes pratiques en environnement professionnel.

Le DHCP est intégré à Active Directory et interagit directement avec le service DNS pour l’enregistrement dynamique des machines du domaine.

---
## 2. Objectifs

Les objectifs de cette mise en place sont les suivants :

- Fournir une distribution automatique et centralisée des adresses IP
- Garantir une intégration complète avec Active Directory et DNS
- Empêcher l’utilisation de serveurs DHCP non autorisés
- Respecter une architecture réaliste et sécurisée
- Permettre une administration distante depuis un serveur GLI

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
-  **[installation.md](components/DHCP/installation.md)** - Procédure d'installation complète.
-  **[configuration.md](components/DHCP/configuration.md)** - Configuration des OU, utilisateurs, GPO.
-  **Ressources/**

---
## 5. Services installés

Les services et composants suivants sont utilisés :
DHCP Server (Windows Server)

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