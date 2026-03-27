## Sommaire

1. [Prérequis](#1-prérequis)
   - 1.1. [Caractéristiques matérielles et logicielles requises](#11-caractéristiques-matérielles-et-logicielles-requises)
2. [Architecture et positionnement](#2-architecture-et-positionnement)
   - 2.1. [VLAN de rattachement](#21-vlan-de-rattachement)
3. [Installation des outils Windows (RSAT)](#3-installation-des-outils-windows-rsat)
   - 3.1. [Téléchargement de RSAT](#31-téléchargement-de-rsat)
   - 3.2. [Installation des Fonctionnalités Facultatives](#32-installation-des-fonctionnalités-facultatives)
4. [Installation des outils Linux/réseau](#4-installation-des-outils-linuxréseau)
   - 4.1. [Installation de MobaXterm/GitBash](#41-installation-de-mobaxterm-gitbash)
   - 4.2. [Installation de Putty](#42-installation-de-putty)
   - 4.3. [Installation de WinSCP/FileZilla](#43-installation-de-winscpfilezilla)
   - 4.4. [Installation de WSL](#44-installation-de-wsl)
   - 4.5. [Installation de TightVNC](#45-installation-de-tightvnc)
5. [Installation des outils d'analyse](#5-installation-des-outils-danalyse)
   - 5.1. [Installation de Wireshark](#51-installation-de-wireshark)
   - 5.2. [Installation de Trippy](#52-installation-de-trippy)
   - 5.3. [Installation de la suite Sysinternals](#53-installation-de-la-suite-sysinternals)
   - 5.4. [Installation OpenSSH](#54-installation-openssh)

---
## 1. Prérequis

### 1.1. Caractéristiques matérielles et logicielles requises

#### Matériel
- **Type** : VM sous Proxmox
- **RAM** : 4 Go
- **CPU** : 2 CPU
- **Disque dur** : 40 Go
- **Carte réseau** : 1 interface réseau  **VMBR412**

#### Logiciel
- **Système d'exploitation** : Windows 10 Pro 22H2

#### Accès réseau
- Accès au réseau VLAN DSI (VLAN 60)
- Connectivité vers tous les VLANs de l'infrastructure 
- Accès Internet pour téléchargement des outils

---
## 2. Architecture et positionnement

### 2.1. VLAN de rattachement

Le PC d'administration est positionné sur le **VLAN 60 - DSI**.

**Configuration réseau** :
- **Nom de la machine** : `G1-PC-ADMIN-01`
- **VLAN** : `60`
- **Adresse IP** : `172.16.6.1/24`
- **Passerelle** : `172.16.6.30`
- **DNS :** `172.16.12.1` 
- **Nom de domaine** : `billu.lan`

**Justification du positionnement** :

Le PC d'administration est placé dans le VLAN DSI pour des raisons de sécurité. Seuls les administrateurs système et réseau ont accès à ce VLAN, permettant ainsi de contrôler strictement qui peut accéder aux outils d'administration sensibles de l'infrastructure.

---
## 3. Installation des outils Windows (RSAT)

### 3.1 Téléchargement de RSAT

**RSAT (Remote Server Administration Tools)** permet d'administrer les serveurs Windows à distance, notamment Active Directory, DNS, DHCP, etc.

### 3.2 Installation des Fonctionnalités Facultatives

1. Ouvrir **Paramètres** > **Applications** > **Fonctionnalités facultatives**
2. Cliquer sur **Afficher les fonctionnalités**
3. Dans la barre de recherche, taper **RSAT**

Sélectionner et installer les fonctionnalités suivantes :

-  **RSAT: Outils Active Directoory Domain Services Directory et services LDS**
-  **RSAT: Outils du serveur DHCP**
-  **RSAT: Outils du serveur DNS**
-  **RSAT: Outils de gestion de l'accès à distance**
-  **RSAT: Gestionnaire du serveur**
-  **RSAT : Outils de gestion de stratégie de groupe**

**Cliquer sur Installer** pour chaque fonctionnalité sélectionnée.

---
## 4. Installation des outils Linux/réseau

### 4.1. Installation de MobaXterm/GitBash

**Choisir l'un des deux outils selon vos besoins** :
- **MobaXterm** : Solution tout-en-un (SSH, X11, SFTP intégré) 
- **GitBash** : Plus léger, axé Git + terminal Unix
#### Installation de MobaXterm 

1. **Téléchargement** :
   - Site officiel : https://mobaxterm.mobatek.net/download.html
   - Télécharger la version **"Installer Edition"** pour une installation permanente

2. **Installation** :
   - **Version Installer** : Exécuter le fichier `.msi` et suivre l'assistant d'installation
#### Installation de Git Bash

1. Télécharger Git pour Windows : https://git-scm.com/install/windows
	- Télécharger la version **"Git for Windows/x64 Setup"**
	
2. Exécuter l'installateur

### 4.2. Installation de Putty

**Putty** est un client SSH léger et populaire pour Windows.

1. **Téléchargement** :
   - Site officiel : https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html
   - Télécharger le fichier **"putty-64bit-0.83-installer.msi"** (version 64-bit)

2. **Installation** :
   - Exécuter le fichier `.msi`
   - Accepter les options par défaut
   - Terminer l'installation

### 4.3 Installation de WinSCP/FileZilla

Ces outils permettent le transfert de fichiers via SCP, SFTP, FTP.
#### Installation de WinSCP 

1. **Téléchargement** :
   - Site officiel : https://winscp.net/eng/download.php
   - Télécharger la version **"DOWNLOAD WINSCP 6.5.5"**

2. **Installation** :
   - Exécuter le fichier d'installation
   - Type d'installation : **"Installation typique"**
   - Interface utilisateur : **"Commander"** 
   - Terminer l'installation

#### Installation de FileZilla

1. **Téléchargement** :
   - Site officiel : https://filezilla-project.org/download.php?type=client
   - Télécharger la version **"Download FileZilla Client"**
   
2. **Installation** :
   - Exécuter le fichier d'installation
   - Suivre l'assistant d'installation avec les options par défaut

### 4.4 Installation de WSL

Dans PowerShell taper cette commande :

```powershell
wsl --install
```

### 4.5 Installation de TightVNC

1. **Téléchargement** :
   - Site officiel : https://tightvnc.com/download.php
   - Télécharger la version **"Installer for Windows (64-bit)**
   
2. **Installation** :
   - Exécuter le fichier d'installation
   - Suivre l'assistant d'installation cocher **"Installation complète"**
   - Entrer le MDP quand cela est demander.

---
## 5. Installation des outils d'analyse

### 5.1. Installation de Wireshark

**Wireshark** est l'outil de référence pour l'analyse de trafic réseau.

1. **Téléchargement** :
   - Site officiel : https://www.wireshark.org/download.html
   - Télécharger la version **"Windows x64 Installer"**

2. **Installation** :
   - Exécuter le fichier `.exe`
   - Composants à installer :
     -  Wireshark
     - TShark (CLI version)
     -  Plugins & Extensions
   - **Npcap** (capture driver) :
     - Cocher **Install Npcap** (nécessaire pour capturer du trafic)
     - Accepter l'installation de Npcap avec les options par défaut
   - Terminer l'installation

### 5.2. Installation de Trippy

Via PowerShell exécuter les commandes suivantes :

Installer Scoop (Gestionnaire de paquets Windows)

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
```

Puis installer Trippy

```powershell
scoop install trippy
```

### 5.3. Installation de la suite Sysinternals

**Sysinternals Suite** regroupe des outils puissants pour l'administration Windows (Process Explorer, TCPView, Autoruns, etc.).

#### Téléchargement de la suite complète

1. **Téléchargement** :
   - Site officiel : https://learn.microsoft.com/en-us/sysinternals/downloads/sysinternals-suite
   - Télécharger le fichier **SysinternalsSuite.zip**

2. **Installation** :
   - Créer le répertoire `C:\Program Files\Sysinternals\`
   - Extraire tous les fichiers du ZIP dans ce répertoire
   - Exécuter l'installateur

### 5.4. Installation OpenSSH

1. Ouvrir **Paramètres** > **Applications** > **Fonctionnalités facultatives**
2. Cliquer sur **Afficher les fonctionnalités**
3. Dans la barre de recherche, taper **Client OpenSSH**

**Cliquer sur Installer** pour la fonctionnalité sélectionnée.

Démarrage du service **"sshd"** :

```powershell
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'
```

---