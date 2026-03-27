
## Sommaire

1. [Vue d'ensemble](#1-vue-densemble)
2. [Objectifs](#2-objectifs)
3. [Architecture](#3-architecture)
4. [Structure de la documentation](#4-structure-de-la-documentation)
5. [Services installés](#5-services-installés)
6. [Maintenance](#6-maintenance)
7. [Historique des modifications](#8-historique-des-modifications)

---

## 1. Vue d'ensemble

Le serveur **`G1-DOM-WSUS-01`** héberge le rôle **Windows Server Update Services (WSUS)**, solution Microsoft de gestion centralisée des mises à jour pour l'ensemble du parc informatique de **BillU**.

Ce serveur permet de contrôler, filtrer et déployer les mises à jour Windows sur les postes clients, les serveurs membres et les contrôleurs de domaine, en appliquant des politiques différenciées selon les groupes de machines.

Il est intégré au domaine **`billu.lan`** et communique avec l'Active Directory via des GPO pour assigner automatiquement chaque machine à son groupe de mise à jour correspondant.

---

## 2. Objectifs

- Centraliser la gestion des mises à jour Windows pour l'ensemble du parc BillU
- Différencier les politiques de mise à jour entre les **postes clients**, les **serveurs** et les **contrôleurs de domaine**
- Réduire la consommation de bande passante Internet en téléchargeant les MAJ une seule fois
- Contrôler et approuver les mises à jour avant leur déploiement
- Intégrer la gestion des groupes WSUS avec l'Active Directory via GPO

---

## 3. Architecture

### 3.1 Serveurs impliqués

| Serveur | Rôle | VLAN |
|---------|------|------|
| `G1-DOM-WSUS-01` | Serveur WSUS | VLAN 120 - Serveurs |
| `G1-DOM-AD-01` | Contrôleur de domaine / DNS | VLAN 120 - Serveurs |
| `PC-ADMIN` | Poste d'administration (console WSUS) | VLAN 110 - Administration |

### 3.2 Configuration réseau du serveur WSUS

| Propriété | Valeur |
|-----------|--------|
| **Nom de la machine** | `G1-DOM-WSUS-01` |
| **Système d'exploitation** | Windows Server 2022 Core |
| **VLAN** | `120` |
| **Adresse IP** | `172.16.12.3/29` |
| **Passerelle** | `172.16.12.6` |
| **DNS** | `172.16.12.1` |
| **Nom de domaine** | `billu.lan` |
| **RAM** | 2048 Mo |
| **CPU** | 2 vCPU |
| **Disque système** | 32 Go |
| **Disque données WSUS** | Lecteur `E:\` |
| **Bridge Proxmox** | `vmbr412` |

### 3.3 Groupes WSUS et GPO associées

| Groupe WSUS | GPO | Cible AD | Plage horaire (redémarrage) |
|-------------|-----|----------|-----------------------------|
| `PC` | `WSUS_COMPUTERS_PC` | `BillU > BilluComputers > Tous les départements` | 08h - 17h |
| `SERVERS` | `WSUS_COMPUTERS_SERVER` | `BillU > BilluServers` | 07h - 22h |
| `AD` | `WSUS_COMPUTERS_AD` | `BillU > Domain Controllers` | 07h - 22h |


## 4. Structure de la documentation

| Fichier | Type | Contenu |
|---------|------|---------|
| `README.md` | DAT | Vue d'ensemble, architecture, objectifs |
| `installation.md` | LLD | Configuration réseau, jonction domaine, installation du rôle |
| `configuration.md` | LLD | 1ère configuration WSUS, groupes, GPO, approbation des MAJ |

---

## 5. Services installés

### Windows Server Update Services (WSUS)

| Propriété | Valeur |
|-----------|--------|
| **Rôle** | Windows Server Update Services |
| **Stockage MAJ** | Lecteur `E:\` |
| **Synchronisation** | Automatique |
| **Console d'administration** | Gérée depuis `PC-ADMIN` via Gestionnaire de serveur |

### Produits couverts par les mises à jour

- Windows 10 version 1903 and later
- Windows Server 2019
- PowerShell

### Classifications gérées

- Mises à jour critiques
- Mises à jour de sécurité
- Mises à jour de définitions

### GPO déployées

| Nom GPO | Fonction |
|---------|----------|
| `WSUS_COMPUTERS_Common_Parameter` | Paramètres communs : URL WSUS, désactivation Windows Update public |
| `WSUS_COMPUTERS_PC` | Ciblage groupe `PC`, plages horaires de redémarrage |
| `WSUS_COMPUTERS_SERVER` | Ciblage groupe `SERVERS`, plages horaires de redémarrage |
| `WSUS_COMPUTERS_AD` | Ciblage groupe `AD`, plages horaires de redémarrage |

---

## 6. Maintenance

### 6.1 Vérification de l'état du service

Depuis le `PC-ADMIN`, ouvrir la console **WSUS** :

- Vérifier le statut de la synchronisation dans **Synchronisations**
- Contrôler les rapports dans **Rapports** → **Résumé de l'état des mises à jour**
- Surveiller les machines non conformes dans **Ordinateurs**

### 6.2 Approbation des mises à jour

```
Console WSUS → Mises à jour → Toutes les mises à jour
→ Sélectionner la MAJ → Clic droit → Approuver
→ Choisir le groupe cible (PC / SERVERS / AD)
```

### 6.3 Synchronisation manuelle (si besoin)

```
Console WSUS → DOM-WSUS-01 → Synchroniser maintenant
```

### 6.4 Nettoyage du serveur WSUS

```
Console WSUS → Options → Assistant Nettoyage du serveur
→ Cocher toutes les options → Lancer
```

Fréquence recommandée : **mensuelle**

---

## 7. Historique des modifications

| Version | Date | Auteur | Description |
|---------|------|--------|-------------|
| 1.0 | 03/03/2026 | Franck | Création initiale - Installation et configuration WSUS |

---
