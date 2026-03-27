## Sommaire

1. [Vue d'ensemble](#1-vue-densemble)
2. [Objectifs](#2-objectifs)
3. [Architecture](#3-architecture)
    - [3.1 Serveurs impliqués](#31-serveurs-impliques)
    - [3.2 Informations du domaine](#32-informations-du-domaine)
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

Ce document décrit la mise en place et l’administration du **serveur de fichiers** au sein de l’infrastructure Active Directory de l’entreprise BillU.

Le serveur de fichiers est déployé sous **Windows Server Core** et intégré au domaine Active Directory existant.  
L’administration est réalisée à distance depuis un serveur Windows Server GLI (GUI), conformément aux bonnes pratiques en environnement professionnel.

Le serveur de fichiers centralise le stockage des données utilisateurs et métiers, tout en assurant un cloisonnement strict des accès à l’aide des groupes Active Directory, des permissions NTFS et de l’Access-Based Enumeration (ABE).

---

## 2. Objectifs

Les objectifs de cette mise en place sont les suivants :

- Centraliser le stockage des données de l’entreprise
- Fournir des espaces de travail distincts :
  - dossiers personnels
  - dossiers de service
  - dossiers de département
- Garantir un cloisonnement strict des accès par groupe Active Directory
- Masquer les ressources non autorisées à l’aide de l’Access-Based Enumeration
- Respecter une architecture réaliste et sécurisée
- Permettre une administration distante depuis un serveur GLI

---

## 3. Architecture

### 3.1 Serveurs impliqués

- **DOM-AD-01** (GUI)  
  - Contrôleur de domaine principal  
  - DNS intégré  
  - Administration Active Directory et GPO  

- **DOM-FS-01** (CORE)  
  - Serveur de fichiers  
  - Hébergement des partages SMB  
  - Permissions NTFS et ABE  

---

### 3.2 Informations du domaine

- **Nom du domaine** : billu.lan  
- **Nom NetBIOS** : BILLU  
- **Niveau fonctionnel** : Windows Server 2022  
- **Serveur AD principal** : DOM-AD-01  

---

## 4. Structure de la documentation

La documentation du serveur de fichiers est organisée comme suit :

- **README.md**  
- **[installation.md](components/Serveur%20de%20fichiers/installation.md)** – Installation et préparation du serveur de fichiers (Server Core)  
- **[configuration.md](components/Serveur%20de%20fichiers/configuration.md)** – Configuration des partages SMB et de l’Access-Based Enumeration  
- **Ressources/**  

---

## 5. Services installés

Les services et composants suivants sont utilisés :

- File Server (Windows Server)
- Partages SMB
- Access-Based Enumeration (ABE)

---

## 6. Maintenance

### 6.1 Sauvegardes

---

### 6.2 Monitoring

---

## 7. Références

File server et protocole SMB : 
https://learn.microsoft.com/en-us/windows-server/storage/file-server/file-server-smb-overview
File server ressources Manager :
https://learn.microsoft.com/en-us/windows-server/storage/fsrm/fsrm-overview
AD security groups :
https://learn.microsoft.com/en-us/windows-server/identity/ad-ds/manage/understand-security-groups
GPO Drive maps : 
https://learn.microsoft.com/en-us/previous-versions/windows/it-pro/windows-server-2012-r2-and-2012/dn581924(v=ws.11)
NTFS :
https://learn.microsoft.com/fr-fr/windows-server/storage/file-server/ntfs-overview
ABE : Access-Based Enumeration : 
https://learn.microsoft.com/fr-fr/windows-server/storage/dfs-namespaces/enable-access-based-enumeration-on-a-namespace
SERVEURS DE FICHIERS - IT-CONNECT :
https://www.it-connect.fr/cours-tutoriels/administration-systemes/windows-server/tutos-serveur-de-fichiers/

---

## 8. Historique des modifications

| Date       | Auteur   | Modification                   |
| ---------- | -------- | ------------------------------ |
| 04/02/2026 | Matthias | Création du README File Server |
| 04/02/2026 | Matthias | Création du INSTALLATION       |
| 08/02/2026 | Matthias | Création du CONFIGURATION      |

---

## 9. Contributeurs

- **Matthias** – Installation et configuration

---

**Projet** : TSSR1025 Projet 3 - Build Your Infra  
**Entreprise** : BillU  
**Sprint** : 3  
**Dernière mise à jour** : 04/02/2026

---
