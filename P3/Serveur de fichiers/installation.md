# Installation du serveur de fichiers Windows Server Core


## Sommaire

1. [Pré-requis](#1-pre-requis)
2. [Installation de Windows Server Core](#2-installation-de-windows-server-core)
3. [Première configuration via SConfig](#3-premiere-configuration-via-sconfig)
4. [Configuration réseau (IP statique)](#4-configuration-reseau-ip-statique)
5. [Configuration DNS](#5-configuration-dns)
6. [Réglage de la date et de l’heure](#6-reglage-de-la-date-et-de-lheure)
7. [Jonction au domaine Active Directory](#7-jonction-au-domaine-active-directory)
8. [Installation du rôle File Server](#8-installation-du-role-file-server)
9. [Préparation du disque DATA (E:)](#9-preparation-du-disque-data-e)
10. [Création de l’arborescence de base](#10-creation-de-larborescence-de-base)
11. [Conclusion](#11-conclusion)

  

---

## 1. Pré-requis

Avant de commencer, assurez-vous d'avoir :

| Élément               | Description                             |
| --------------------- | --------------------------------------- |
| Contrôleur de domaine | AD DS / DNS opérationnel (serveur GLI) |
| Réseau                | Connexion au VLAN serveurs             |
| Compte administrateur | Droits d'administration du domaine     |
| Disques               | • Disque OS (C:)<br>• Disque DATA (E:) |
  
---

## 2. Installation de Windows Server Core

### Étapes d'installation

1. Démarrer sur l'ISO Windows Server
2. Sélectionner l'édition :
    - `Windows Server Standard (Server Core Installation)`
    - ou Datacenter Core selon le cas
3. Installer Windows sur le disque système
4. Définir le mot de passe du compte Administrator (local)

> Le serveur redémarre automatiquement et affiche l'outil SConfig

---

## 3. Première configuration via SConfig

Au premier démarrage, nous allons :
- Renommer le serveur
- Configurer le réseau + DNS
- Régler l'heure
- Joindre le domaine

---

## 4. Configuration réseau (IP statique)

### Accès aux paramètres réseau

Dans SConfig :
Appuyer sur `8` puis `Entrée` > Network Settings

### Sélection de la carte réseau

- Sélectionner l'interface à configurer (généralement `1`)
- Appuyer sur Entrée
  
### Configuration de l'adresse IP

Dans Network Adapter Settings :
1. Appuyer sur `1` > Set Network Adapter Address
2. Choisir `S` > Static
  
**Paramètres réseau :**


| Paramètre       | Valeur exemple    |
| --------------- | ----------------- |
| IP Address      | `172.16.13.4`     |
| Subnet Mask     | `255.255.255.248` |
| Default Gateway | `172.16.13.6`     |

3. Valider avec Entrée

### Vérification

Sortir vers la console (option 15), exécuter :

```powershell
ipconfig /all
ping 172.16.12.1
```

> Cible du ping : l'adresse IP du contrôleur de domaine

---

## 5. Configuration DNS

### Configuration DNS dans SConfig

Toujours dans Network Adapter Settings :

1. Appuyer sur `2` > Set DNS Servers

**Paramètres DNS :**

| Serveur DNS          | Valeur                    |
| -------------------- | ------------------------- |
| Preferred DNS Server | `172.16.12.1` (IP du DC) |
| Alternate DNS Server | Laisser vide ou second DC |

2. Valider

### Vérification DNS

Tester la résolution de noms :

```powershell
nslookup billu.lan
```

---

## 6. Réglage de la date et de l'heure

Dans SConfig :
1. Appuyer sur `9` > Date and Time
2. Vérifier le fuseau horaire
3. Corriger l'heure si nécessaire

> Critique : Kerberos est sensible au décalage horaire. Une heure incorrecte empêchera possiblement la jonction au domaine !

---

## 7. Jonction au domaine Active Directory

### Renommage du serveur (avant jonction)

Dans SConfig :
1. Appuyer sur `2` > Computer Name
2. Renseigner un nom conforme :

```
DOM-FS-01
```
  
3. Redémarrage demandé > `Yes`

### Jonction au domaine

Après redémarrage, retourner dans SConfig :
1. Appuyer sur `1` > Domain/Workgroup
2. Choisir `D` > Domain
3. Renseigner le domaine :

```
billu.lan
```

4. Saisir les identifiants d'un compte administrateur du domaine
5. Redémarrage demandé > `Yes`

---

## 8. Installation du rôle File Server

### Sortie vers PowerShell

Dans SConfig :

```
Appuyer sur [15] > Exit to command line
```

### Installation du rôle

```powershell
Install-WindowsFeature FS-FileServer
```

### Vérification de l'installation

```powershell
Get-WindowsFeature FS-FileServer
```

Résultat attendu :

```
InstallState : Installed
```

---

## 9. Préparation du disque DATA (E:)

> **Objectif** : Préparer un volume dédié aux données, séparé du disque système

### Identifier le disque DATA

Lister les disques disponibles :

```powershell
Get-Disk
```

> Repérer le disque non initialisé (généralement Disk 1)
  
### Initialiser le disque

```powershell
Initialize-Disk -Number 1 -PartitionStyle GPT
```

### Créer une partition et assigner la lettre E:

```powershell
New-Partition -DiskNumber 1 -UseMaximumSize -DriveLetter E
```

### Formater en NTFS

```powershell
Format-Volume -DriveLetter E -FileSystem NTFS -NewFileSystemLabel DATA
```

### Vérifier le volume

```powershell
Get-Volume
```

Résultat attendu :

|Lettre|FileSystem|Label|Taille|État|
|---|---|---|---|---|
|E:|NTFS|DATA|> 0|Healthy|
  
---

## 10. Création de l'arborescence de base

### Création des dossiers racines

Sur le volume DATA, créer la structure de base :

```powershell
mkdir E:\DATA
mkdir E:\DATA\HOME
mkdir E:\DATA\SERVICES
mkdir E:\DATA\DEPARTEMENTS
```

### Vérification de l'arborescence

```powershell
tree E:\DATA
```

**Résultat attendu :**

```
E:\DATA
├── HOME
├── SERVICES
└── DEPARTEMENTS
```

> **Note** : À ce stade, aucune permission spécifique n'est encore appliquée

---
