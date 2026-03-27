## Sommaire

## Sommaire

1. [Configuration réseau du serveur WDS](#1-configuration-réseau-du-serveur-wds)
2. [Jonction du serveur WDS au domaine](#2-jonction-du-serveur-wds-au-domaine)
3. [Installation du rôle Windows Deployment Services](#3-installation-du-rôle-windows-deployment-services)
4. [Préparation du volume NTFS pour RemoteInstall](#4-préparation-du-volume-ntfs-pour-remoteinstall)
5. [Configuration initiale du serveur WDS](#5-configuration-initiale-du-serveur-wds)
6. [Configuration spécifique liée à notre infrastructure](#6-configuration-spécifique-liée-à-notre-infrastructure)
7. [Validation du bon fonctionnement du service](#7-validation-du-bon-fonctionnement-du-service)

---

## 1. Configuration réseau du serveur WDS

Le serveur `DOM-WDS-01` doit disposer d'une **adresse IP statique** afin d'assurer la stabilité du service PXE.

|Paramètre|Valeur|
|---|---|
|Adresse IP|`172.16.12.3`|
|Masque|`255.255.255.240` (/28)|
|Passerelle|`172.16.12.14` (VyOS eth0.120)|
|DNS|`172.16.12.1` (AD / DNS)|

Vérification via PowerShell :

```powershell
ipconfig /all
```

Avant de continuer, s'assurer que le serveur peut :

- Résoudre le domaine `billu.lan`
- Joindre le contrôleur de domaine (`172.16.12.1`)
- Joindre la passerelle VLAN serveurs (`172.16.12.14`)

```powershell
# Test de résolution DNS
Resolve-DnsName billu.lan

# Test de connectivité
ping 172.16.12.1
ping 172.16.12.14
```

---

## 2. Jonction du serveur WDS au domaine

Le serveur WDS doit impérativement être **membre du domaine** `billu.lan` pour fonctionner en mode intégré Active Directory.

```powershell
Add-Computer -DomainName "billu.lan" -Credential (Get-Credential)
Restart-Computer
```

Le redémarrage est obligatoire après la jonction.

**Vérification après redémarrage :**

```powershell
# Vérifier l'appartenance au domaine
(Get-WmiObject Win32_ComputerSystem).Domain
```

Le serveur doit apparaître dans **Active Directory Users and Computers** sous `BilluServer` (ou l'OU définie).

---

## 3. Installation du rôle Windows Deployment Services

### Via Server Manager (GUI)

1. `Manage` > `Add Roles and Features`
2. Type d'installation : `Role-based or feature-based installation`
3. Sélectionner le serveur `DOM-WDS-01`
4. Cocher **Windows Deployment Services** et ses composants :
    -  `Deployment Server` > gestion PXE + images
    -  `Transport Server` > transfert réseau optimisé

---

## 4. Préparation du volume NTFS pour RemoteInstall

WDS nécessite un **volume NTFS dédié**, distinct du disque système, pour héberger les images et le dossier `RemoteInstall`.

### Étapes réalisées

1. Ajout d'un second disque sur la VM Proxmox
2. Initialisation du disque en **GPT**
3. Création d'un nouveau volume simple :
    - Lettre : `W:`
    - Système de fichiers : `NTFS`
    - Étiquette : `WDS_Data`

```powershell
# Initialisation et formatage via PowerShell (disque numéro 1)
Initialize-Disk -Number 1 -PartitionStyle GPT
New-Partition -DiskNumber 1 -UseMaximumSize -DriveLetter W
Format-Volume -DriveLetter W -FileSystem NTFS -NewFileSystemLabel "WDS_Data" -Confirm:$false
```

Le dossier RemoteInstall sera créé automatiquement par WDS à l'étape suivante :

```
W:\RemoteInstall
```

---

## 5. Configuration initiale du serveur WDS

### Ouverture de la console WDS

```
Server Manager > Tools > Windows Deployment Services
```

Ou directement :

```powershell
wdsmgmt.msc
```

### Assistant de configuration

Clic droit sur le serveur > `Configure Server`

|Paramètre|Valeur choisie|
|---|---|
|Mode|`Integrated with Active Directory`|
|Dossier RemoteInstall|`W:\RemoteInstall`|

### Paramètres DHCP (onglet DHCP des propriétés du serveur)

Notre infrastructure dispose d'un serveur DHCP **distinct** (`172.16.12.2`). Les paramètres suivants doivent être configurés en conséquence :

| Option                      | État       | Raison                                      |
| --------------------------- | ---------- | ------------------------------------------- |
| Do not listen on DHCP ports | Activé     | Évite le conflit avec le serveur DHCP dédié |
| Configure DHCP option 60    |  Désactivé | Géré par le DHCP Relay VyOS                 |

### Réponse PXE (onglet PXE Response)

| Option                 | Valeur                                                          |
| ---------------------- | --------------------------------------------------------------- |
| PXE Response           | `Respond to all client computers (known and unknown)`           |
| Administrator approval | Activé (`Require administrator approval for unknown computers`) |

---

## 6. Configuration spécifique liée à notre infrastructure

### Contexte multi-VLAN

Notre infrastructure repose sur :

- Un **DHCP Relay** actif sur VyOS, avec deux serveurs déclarés :
    - `172.16.12.2` > serveur DHCP
    - `172.16.12.3` > serveur WDS
- Une segmentation réseau par VLAN (clients dans des VLANs distincts du VLAN serveurs)

### Problème rencontré et résolution

Lors des tests initiaux, le client PXE obtenait une adresse IP mais ne parvenait pas à localiser le serveur de boot (`Nothing to boot` ou timeout TFTP).

**Cause :** Les options DHCP 66 et 67 n'étaient pas configurées sur les scopes VLAN clients.

**Solution :** Ajout des options 66/67 sur DHCP.

|Option DHCP|Valeur|Description|
|---|---|---|
|66|`172.16.12.3`|Adresse du Boot Server (WDS)|
|67|`boot\x86\wdsnbp.com`|Fichier de boot (BIOS Legacy / SeaBIOS)|

---

## 7. Validation du bon fonctionnement du service

### Vérification du service WDS

```powershell
Get-Service WDSServer
```

Le statut doit être `Running`.

### Test PXE depuis un client

**Configuration du client de test (VM Proxmox) :**

|Paramètre|Valeur|
|---|---|
|BIOS|SeaBIOS|
|Carte réseau|Intel E1000|
|VLAN|10 (DEV) - ou tout VLAN avec PXE activé|
|Boot order|Network en priorité|

**Séquence attendue :**

```
1. Client reçoit une IP du scope VLAN correspondant
2. Next server : 172.16.12.3
3. Filename    : boot\x86\wdsnbp.com
4. Téléchargement TFTP > OK
5. WDSNBP démarre > contacte WDS sur 172.16.12.3:4011
6. Message "Pending Request" > en attente d'approbation admin
```

### Approbation d'une machine en attente

Dans la console WDS > `DOM-WDS-01` > `Pending Devices` > clic droit > `Approve`

Ou via PowerShell :

```powershell
# Lister les machines en attente
Get-WdsClient -DeviceType UnknownDevices

# Approuver par GUID
Approve-WdsClient -DeviceID <GUID>
```
