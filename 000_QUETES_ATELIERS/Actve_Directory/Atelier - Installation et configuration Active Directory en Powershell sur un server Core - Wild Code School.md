---
title: "Atelier - Installation et configuration Active Directory en Powershell sur un server Core - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/3035/pages/11428"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Active Directory

## Atelier - Installation et configuration Active Directory en Powershell sur un server Core

Moyen

2h

Auto-validation

Active Directory

## Atelier - Installation et configuration Active Directory en Powershell sur un server Core

## Introduction

On peut installer un **Active Directory** sur un serveur desktop, avec une interface graphique, ou bien sur un serveur Core, entièrement en ligne de commandes.  
L'intérêt de ce dernier est d'utiliser peu de ressource et d'être aussi efficace.  
Dans cet atelier tu vas installer et configurer un Active Directory sur un serveur Core. Ensuite tu vas rattacher à ce domaine un nouveau serveur graphique.

![logo microsoft active directory](https://storage.googleapis.com/quest_editor_uploads/dx5hzG1lrc2YsanVLpKWumup6WuUym9D.png)

## 🎯 Objectifs

✅ Installer un domaine sur un serveur core  
✅ Intégrer des ordinateurs à un domaine  
✅ Ajouter un DC à un domaine existant  
✅ Gérer un serveur core à partir d'un serveur desktop

## sommaire

- [✔️ Étape 1 - Prérequis](https://odyssey.wildcodeschool.com/quests/3035/pages/11428#%EF%B8%8F-%C3%A9tape-1---pr%C3%A9requis)
- [🔬 Étape 2 - Configuration initiale du serveur Core](https://odyssey.wildcodeschool.com/quests/3035/pages/11428#-%C3%A9tape-2---configuration-initiale-du-serveur-core)
	- [Nom du serveur](https://odyssey.wildcodeschool.com/quests/3035/pages/11428#nom-du-serveur)
		- [Configuration réseau](https://odyssey.wildcodeschool.com/quests/3035/pages/11428#configuration-r%C3%A9seau)
- [⚙️ Étape 3 - Installation des rôles](https://odyssey.wildcodeschool.com/quests/3035/pages/11428#%EF%B8%8F-%C3%A9tape-3---installation-des-r%C3%B4les)
- [⚙️ Étape 4 - Création du domaine AD](https://odyssey.wildcodeschool.com/quests/3035/pages/11428#%EF%B8%8F-%C3%A9tape-4---cr%C3%A9ation-du-domaine-ad)
- [⚙️ Étape 5 - Ajout d'un client au domaine](https://odyssey.wildcodeschool.com/quests/3035/pages/11428#%EF%B8%8F-%C3%A9tape-5---ajout-dun-client-au-domaine)
- [⚙️ Étape 6 - Ajout d'un nouveau DC au domaine](https://odyssey.wildcodeschool.com/quests/3035/pages/11428#%EF%B8%8F-%C3%A9tape-6---ajout-dun-nouveau-dc-au-domaine)
- [⚙️ Étape 7 - Gestion d'un serveur core via un serveur desktop](https://odyssey.wildcodeschool.com/quests/3035/pages/11428#%EF%B8%8F-%C3%A9tape-7---gestion-dun-serveur-core-via-un-serveur-desktop)
- [🏆 Conclusion](https://odyssey.wildcodeschool.com/quests/3035/pages/11428#-conclusion)

## ✔️ Étape 1 - Prérequis

Tu a besoin de 3 VM sous Virtualbox:

- 1 VM serveur Windows Server 2022 desktop
- 1 VM serveur Windows Server 2022 core
- 1 client Windows 10

Les VM sont configurés de la manière suivante:

| Fonction de la VM | Serveur | Serveur | Client |
| --- | --- | --- | --- |
| Nom | WINSERV3 | WINSERV2 | CLIENT3 |
| OS | Windows Server 2022 | Windows Server 2022 | Windows 10 |
| OS version | Standard Desktop Experience | Standard | Professionnel |
| RAM | 4/8 Go | 2/4 Go | 2/4 Go |
| Langue à installer | English (US) | English (US) | French |
| Time and currency / keyboard | French | French | French |
| Carte réseau VirtualBox | Réseau privé | Réseau privé | Réseau privé |
| Adresse IP | 10.10.5.30/24 | 10.10.5.20/24 | 10.10.5.230/24 |
| Passerelle | \- | \- | \- |
| DNS | 10.10.5.20 | 127.0.0.1 | 10.10.5.20 |
| Utilisateur local | Administrator | Administrator | Wilder |
| Firewall | Désactivé | Désactivé | Désactivé |

```powershell
Pour cet atelier, les serveur sont sous OS Windows Server 2022, et le client sous OS Windows 10. Ces machines sont virtualisées sous Virtualbox 7 tournant sur un système hôte Ubuntu 22.04 LTS.

Les expérimentations pratiques peuvent être reproduites avec d'autres versions, sur d'autres distributions Linux, et sur d'autres environnement, mais des différences peuvent alors apparaître.
```

## 🔬 Étape 2 - Configuration initiale du serveur Core

## Nom du serveur

Va dans **Computer name** et suis les menus pour modifier le nom du serveur.

## Configuration réseau

Va dans **Network settings** et suis les menus pour modifier l'adresse IP de la carte réseau ainsi que l'adresse IP du DNS.

Si cela ne fonctionne pas, ouvre une console Powershell et exécute les commandes suivantes:

```powershell
1
New-NetIPAddress -IPAddress "10.10.5.20" -PrefixLength "24" -InterfaceIndex (Get-NetAdapter).ifIndex
2
Set-DnsClientServerAddress -InterfaceIndex (Get-NetAdapter).ifIndex -ServerAddresses ("127.0.0.1")
```

Vérifie avec la commande `Get-NetIPAddress` que ton interface réseau est correctement configurée.

Installation et configuration AD

## ⚙️ Étape 3 - Installation des rôles

Tu vas installer les fonctionnalités suivantes qui sont necessaire à la préparation de ce serveur en controleur de domaine:

- **RSAT-AD-Tools**: Outils d'administration graphique
- **AD-Domain-Services**: Services de domaine Active Directory
- **DNS**

Exécute successivement les 3 lignes de commandes PowerShell ci-dessous:

```powershell
1
Add-WindowsFeature -Name "RSAT-AD-Tools" -IncludeManagementTools -IncludeAllSubFeature
2
Add-WindowsFeature -Name "AD-Domain-Services" -IncludeManagementTools -IncludeAllSubFeature
3
Add-WindowsFeature -Name "DNS" -IncludeManagementTools -IncludeAllSubFeature
```
- Toujours en PowerShell, exécute les lignes de commandes ci-dessous:

> Derrière le `@{` tu auras un prompt qui te permettras de rentrer les lignes successives.

```powershell
1
$ForestConfiguration = @{
2
'-DatabasePath' = 'C:\Windows\NTDS';
3
'-DomainMode' = 'Default';
4
'-DomainName' = "lab.lan";
5
'-DomainNetbiosName' = "lab";
6
'-ForestMode' = 'Default';
7
'-InstallDns' = $true;
8
'-LogPath' = 'C:\Windows\NTDS';
9
'-NoRebootOnCompletion' = $false;
10
'-SysvolPath' = 'C:\Windows\SYSVOL';
11
'-Force' = $true;
12
'-CreateDnsDelegation' = $false }
13

14
Import-Module ADDSDeployment
15
Install-ADDSForest @ForestConfiguration
```
- Indique un mot de passe pour la récupération
- L'installation va se faire, puis la machine va redémarrer

## ⚙️ Étape 5 - Ajout d'un client au domaine

Ajoute le client CLIENT3 au domaine `lab.lan` et utilise le compte `Administrator` pour valider l'action.

## ⚙️ Étape 6 - Ajout d'un nouveau DC au domaine

- Pour le serveur WINSERV3, ajoute le rôles AD-DS
- Configure ce serveur en contrôleur de domaine, et ajoute le au domaine `lab.lan`
- Continu la configuration, termine par Install, et attend que la machine redémarre

## ⚙️ Étape 7 - Gestion d'un serveur core via un serveur desktop

- Une fois WINSERV3 redémarré, connecte-toi en `Administrator`
- Dans le **Server Manager**, va dans **Manage** -> **Add Servers**, et ajoute le serveur WINSERV2
- Une fois que tu as fait cela, tu peux administrer ton serveur core à partir de ton serveur graphique 😁

Par exemple:

- À partir du menu **AD DS** du **Server Manager**, tu peux aller ouvrir la console **Active Directory Users and Computers** du serveur **WINSERV2**
- À partir du menu **Manage** du **Server Manager**, tu peux aller installer le rôle **DHCP** sur le serveur **WINSERV2**

## 🏆 Conclusion

Valide cet atelier si tu as pu effectuer avec succès toutes les actions.  
Tu peux t’entraîner avec les 2 exemples donnés à la fin de cet atelier.  
Tu peux également t’entraîner à administrer le serveur core en ligne de commande.

Quête terminée le **mercredi 07 janvier 2026**