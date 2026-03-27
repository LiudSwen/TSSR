## Sommaire

## Sommaire

1. [Vue d'ensemble](#1-vue-densemble)
2. [Objectifs](#2-objectifs)
3. [Architecture](#3-architecture)
   - [3.1 Serveurs impliqués](#31-serveurs-impliqués)
   - [3.2 Informations du domaine](#32-informations-du-domaine)
   - [3.3 Plan d'adressage VLAN](#33-plan-dadressage-vlan)
4. [Structure de la documentation](#4-structure-de-la-documentation)
5. [Services installés](#5-services-installés)
6. [Configuration réseau PXE](#6-configuration-réseau-pxe)
   - [6.1 Flux PXE multi-VLAN](#61-flux-pxe-multi-vlan)
   - [6.2 Options DHCP par scope](#62-options-dhcp-par-scope)
   - [6.3 Configuration VyOS DHCP Relay](#63-configuration-vyos-dhcp-relay)
   - [6.4 Configuration WDS (onglet DHCP)](#64-configuration-wds-onglet-dhcp)
7. [Maintenance](#7-maintenance)
   - [7.1 Sauvegardes](#71-sauvegardes)
   - [7.2 Monitoring](#72-monitoring)
8. [Références](#8-références)
9. [Historique des modifications](#9-historique-des-modifications)
10. [Contributeurs](#10-contributeurs)

---

## 1. Vue d'ensemble

Ce document d'écrit la mise en place et l'administration du service **Windows Deployment Services (WDS)** au sein de l'infrastructure Active Directory de l'entreprise **BillU**.

Le service WDS est installé sur un serveur Windows Server membre du domaine. Il permet le déploiement automatisé des systèmes Windows via le réseau **(PXE boot)** dans une architecture multi-VLAN.

L'infrastructure repose sur :

- Un serveur DHCP distinct (rôle séparé du WDS)
- Un DHCP Relay configuré sur le routeur VyOS
- Une segmentation réseau par VLAN
- Une intégration complète avec Active Directory

---

## 2. Objectifs

- Permettre le déploiement automatisé des postes Windows via le réseau
- Centraliser l'installation des systèmes Windows (10 / 11 / Server)
- Assurer le fonctionnement en environnement multi-VLAN
- Documenter l'ensemble du processus de déploiement

---

## 3. Architecture

### 3.1 Serveurs impliqués

|Nom|Rôle|Type|
|---|---|---|
|`DOM-AD-01`|Contrôleur de domaine principal + DNS intégré|GUI|
|`DOM-DHCP-01`|Serveur DHCP|CORE|
|`DOM-WDS-01`|Serveur WDS (membre du domaine)|GUI|
|`VYOS-ROUTER-01`|Routeur L3 – DHCP Relay inter-VLAN|VyOS|

### 3.2 Informations du domaine

|Paramètre|Valeur|
|---|---|
|Nom du domaine|`billu.lan`|
|Nom NetBIOS|`BILLU`|
|Niveau fonctionnel|Windows Server 2022|
|IP Contrôleur de domaine / DNS|`172.16.12.1/28`|
|IP Serveur DHCP|`172.16.12.2/28`|
|IP Serveur WDS|`172.16.12.3/28`|
|Passerelle VLAN Serveurs (VyOS)|`172.16.12.14`|
|Dossier RemoteInstall|`W:\RemoteInstall` (volume NTFS dédié)|

> **Note :** Le serveur WDS est configuré avec un volume dédié NTFS pour le dossier `RemoteInstall` afin d'isoler les images du volume système.

### 3.3 Plan d'adressage VLAN

|VLAN|Description|Réseau|Passerelle VyOS|PXE activé|
|---|---|---|---|---|
|10|DEV|172.16.1.0/24|172.16.1.254|✅|
|20|COMMER|172.16.2.0/26|172.16.2.62|✅|
|30|COMMU|172.16.3.0/26|172.16.3.62|✅|
|40|VOIP|172.16.4.0/24|172.16.4.254|❌|
|50|JURI|172.16.5.0/27|172.16.5.30|✅|
|60|DSI|172.16.6.0/27|172.16.6.30|✅|
|70|COMPTA|172.16.7.0/27|172.16.7.30|✅|
|80|DIREC|172.16.8.0/28|172.16.8.14|✅|
|90|IMPRESSION|172.16.9.0/28|172.16.9.14|✅|
|100|QHSE|172.16.10.0/28|172.16.10.14|✅|
|110|RH|172.16.11.0/29|172.16.11.6|✅|
|120|SERVEURS AD|172.16.12.0/28|172.16.12.14|—|
|130|SERVEUR|172.16.13.0/28|172.16.13.14|✅|
|150|ADMIN|172.16.15.0/26|172.16.15.62|✅|

---

## 4. Structure de la documentation

```
WDS/
├── README.md           < Ce fichier — vue d'ensemble
├── installation.md     < Procédure complète d'installation du rôle WDS
├── configuration.md    < Configuration PXE, DHCP Relay, images Boot et Install
└── Ressources/         < Captures
```

---

## 5. Services installés

**Rôles et composants Windows :**

- Windows Deployment Services (WDS)
- TFTP Server (intégré à WDS) — port UDP 69
- PXE Server — port UDP 4011
- Intégration Active Directory (mode Native)

**Images configurées :**

|Type|Contenu|
|---|---|
|Boot Image|WinPE x64 (`boot.wim`)|
|Install Image|Windows 10|
|Install Image|Windows 11|
|Install Image|Windows Server|

**Mode PXE :**

- Réponse : `Respond to all client computers (known and unknown)`
- Approbation : `Require administrator approval` activé

---

## 6. Configuration réseau PXE

### 6.1 Flux PXE multi-VLAN

```
Client PXE (VLAN X)
    │
    │  1. Broadcast DHCP Discover
    ▼
VyOS DHCP Relay (eth0.X > eth0.120)
    │
    ├──►  172.16.12.2  (DHCP) > attribue IP + options 66/67
    └──►  172.16.12.3  (WDS)  > reçoit le Discover sur port 4011
    │
    │  2. Client reçoit IP + Next Server + Bootfile
    ▼
TFTP > téléchargement de boot\x86\wdsnbp.com depuis 172.16.12.3
    │
    │  3. WDSNBP démarre > contacte WDS sur port 4011
    ▼
Pending Request > approbation administrateur
    │
    ▼
WinPE chargé > déploiement Windows
```

### 6.2 Options DHCP par scope

Les options suivantes doivent être configurées

```powershell
# Option 66 — Boot Server (IP du WDS)
172.16.12.3

# Option 67 — Bootfile (BIOS Legacy / SeaBIOS)
"boot\x86\wdsnbp.com"
```

### 6.3 Configuration VyOS DHCP Relay

```
service dhcp-relay {
    listen-interface eth0.10
    listen-interface eth0.20
    listen-interface eth0.30
    listen-interface eth0.50
    listen-interface eth0.60
    listen-interface eth0.70
    listen-interface eth0.80
    listen-interface eth0.100
    listen-interface eth0.110
    listen-interface eth0.120
    listen-interface eth0.130
    listen-interface eth0.150
    server 172.16.12.2
    server 172.16.12.3
    upstream-interface eth0.120
}
```

### 6.4 Configuration WDS (onglet DHCP)

Dans la console WDS (`wdsmgmt.msc`) > Propriétés du serveur > onglet DHCP :

| Option                      | État requis | Raison                                 |
| --------------------------- | ----------- | -------------------------------------- |
| Do not listen on DHCP ports | Activé      | Le DHCP est géré par un serveur séparé |
| Configure DHCP option 60    | Désactivé   | Géré par le relay VyOS, inutile ici    |

---

## 7. Maintenance

### 7.1 Sauvegardes

### 7.2 Monitoring
---

## 8. Références

- [Vue d'ensemble WDS — Microsoft Learn](https://learn.microsoft.com/fr-fr/windows-server/administration/windows-deployment-services/windows-deployment-services-overview)
- [Déployer WDS — Microsoft Learn](https://learn.microsoft.com/fr-fr/windows-server/administration/windows-deployment-services/deploy-wds)

---

## 9. Historique des modifications

| Date       | Auteur   | Modification                              |
| ---------- | -------- | ----------------------------------------- |
| 21/02/2026 | Matthias | Création du README WDS                    |
| 21/02/2026 | Matthias | Création De configuration et installation |

---

## 10. Contributeurs

- Matthias — Installation, configuration et validation PXE