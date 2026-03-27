---
title: "Atelier : IPv6 - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2883/pages/11384"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Réseau

## Atelier: IPv6

Moyen

2h

Auto-validation

Réseau

## Atelier: IPv6

## Introduction

Dans cet atelier tu va configurer des machines en IPv6 et les faire communiquer entre-elles.

## 🤓 Objectifs:

✅ Savoir configurer une adresse IPv6  
✅ Gérer la configuration IPv6 sur Ubuntu, Debian, et Windows 10  
✅ Savoir tester la connectivité IPv6 entre des machines  
✅ Configurer un réseau IPv6 avec des adresse IPv6 lien local

## Sommaire

- [👉 Connectivité IPv6](https://odyssey.wildcodeschool.com/quests/2883/pages/11384#-connectivit%C3%A9-ipv6)
- [⚙️ Utilisation d'adresses link-locale](https://odyssey.wildcodeschool.com/quests/2883/pages/11384#%EF%B8%8F-utilisation-dadresses-link-locale)
	- [☮️ Sur la VM Ubuntu](https://odyssey.wildcodeschool.com/quests/2883/pages/11384#%EF%B8%8F-sur-la-vm-ubuntu)
		- [🐧 Configuration de la VM Debian](https://odyssey.wildcodeschool.com/quests/2883/pages/11384#-configuration-de-la-vm-debian)
		- [🪟 Sur la VM Windows](https://odyssey.wildcodeschool.com/quests/2883/pages/11384#-sur-la-vm-windows)
		- [💬 Vérification de la connexion entre les machines](https://odyssey.wildcodeschool.com/quests/2883/pages/11384#-v%C3%A9rification-de-la-connexion-entre-les-machines-1)
- [💪Challenge](https://odyssey.wildcodeschool.com/quests/2883/pages/11384#challenge)
- [🧐 Critères d'acceptation](https://odyssey.wildcodeschool.com/quests/2883/pages/11384#-crit%C3%A8res-dacceptation)

## 👉 Connectivité IPv6

## ✔️ Prérequis

Tu a besoin de 3 VM:

- Une VM avec une distribution Linux Ubuntu
- Une VM avec une distribution Linux Debian
- Une VM avec un OS Windows client

Les 3 VM ont une carte réseau configurée en mode `Réseau interne` sous VirtualBox.  
Le nom de réseau interne est le même pour les 3 VM.

```shell
Les expérimentations pratiques ont été testées avec avec une distribution Linux Ubuntu 22.04 LTS, une distribution Debian 12, et un Windows 10. Ces 3 OS sont installés sur des machines virtuelles VirtualBox 7 tournant sur un système hôte Ubuntu 22.04 LTS.

Elles peuvent être reproduites sur d'autres distributions Linux, et sur d'autres environnement, mais des différences peuvent alors apparaître.
```

## ☮️ Configuration de la VM Ubuntu

Dans un terminal, trouver le nom de l'interface réseau avec la commande `ip a`  
Configurer l'adresse IPv6 `2001:db8::1/64` sur cette interface réseau:

```bash
1
# Si l'interface réseau est enp0s3
2
sudo ip -6 addr add 2001:db8::1/64 dev enp0s3
```

Pour vérifier que l'adresse est bien sur la bonne interface:

```bash
1
# Si l'interface réseau est enp0s3
2
ip -6 addr show enp0s3 | grep inet6
```

## 🪟 Configuration de la VM Windows

Dans une console PowerShell lançée en Administrateur, trouver le nom de l'interface avec la commande `Get-NetAdapter`  
Configurer l'adresse IPv6 `3001:db8::2` sur cette interface réseau:

```powershell
1
# Si l'interface réseau est Ethernet
2
New-NetIPAddress -InterfaceAlias "Ethernet" -IPAddress "3001:db8::2" -PrefixLength 64
```

Pour vérifier que l'adresse est bien sur la bonne interface:

```powershell
1
# Si l'interface réseau est Ethernet
2
Get-NetIPAddress | Where-Object {($_.InterfaceAlias -eq "Ethernet") -and ($_.AddressFamily -eq "IPv6")}
```

## 💬 Vérification de la connexion entre les machines

**Sur la VM Ubuntu**:

Faire un ping vers la VM Windows:

```bash
1
# <NomInterface> est le numéro d'interface configuré en IPv6 à partir de laquelle tu veux agir
2
ping -6 3001:db8::2 -I <NomInterface>
```

Par exemple `ping -6 3001:db8::2 -I enp0s3`

**Sur la VM Windows**:

Faire un ping vers la VM Linux, avec le numéro d'interface réseau configuré en IPv6:

```powershell
1
# <NumeroInterface> est le numéro d'interface configuré en IPv6 à partir de laquelle tu veux agir
2
Test-Connection -ComputerName 2001:db8::1%<NumeroInterface>
```

Ou sans:

```powershell
1
Test-Connection -ComputerName 2001:db8::1
```
```shell
La commande Test-NetConnectionUn cmdlet pour remplacer Test-Connection.

Fais un ping vers la VM Linux avec cette nouvelle commande.https://learn.microsoft.com/en-us/powershell/module/nettcpip/test-netconnection?view=windowsserver2022-ps
```

Au vu des résultats que peux-tu en déduire?

```shell
Une vue d'ensemble de l'IPv6Documentation Microsoft.

Voir en particulier le paragraphe Type d'adresse.https://learn.microsoft.com/fr-fr/dotnet/fundamentals/networking/ipv6-overview
```

## 🔬 Changement des adresses et test de connexion

Change les adresse IPv6 des VM comme ceci:

- Pour la VM Ubuntu: `2001:db8::3`
- Pour la VM Windows: `2001:db8::4`

Refais les vérifications de connexion entre les machines.  
Qu'en déduis-tu?

## ⚙️ Utilisation d'adresses link-locale

## ☮️ Sur la VM Ubuntu

Vérifier que les fichiers `/etc/network/interfaces` ou les fichiers **.yaml** sous `/etc/netplan/` ne contiennent pas de configuration IPv6.

Dans l'interface graphique du réseau, dans la partie **IPv6**, tu as ces options:

- **Automatique**: Configuration IPv6 via SLAAC (*Stateless Address Autoconfiguration*) ou DHCPv6, selon ce qui est disponible sur le réseau
- **Réseau local seulement**: Utilise uniquement une adresse **link-local** (fe80::/64) pour la communication locale sur le réseau
- **Automatique, DHCP seulement**: Utilise DHCPv6 pour obtenir une adresse IPv6, sans utiliser SLAAC
- **Manuel**: On doit fournir manuellement une adresse IPv6, un masque de sous-réseau et éventuellement une passerelle
- **Partagé avec d'autres ordinateurs**: La machine agit comme un routeur ou une passerelle, elle partage sa connexion Internet avec d'autres appareils sur le même réseau local

Sélectionne la bonne option!  
Relance le réseau avec la commande `sudo systemctl restart networking`.  
Vérifie que l'interface réseau a une adresse commençant par **fe80**.

## 🐧 Configuration de la VM Debian

Dans un terminal, trouver le nom de l'interface réseau avec la commande `ip a`  
Editer le fichier `/etc/network/interfaces` et modifier le comme ceci:

```bash
1
# Si l'interface est enp0s3
2
auto enp0s3
3
iface enp0s3 inet6 manual
4
iface enp0s3 inet manual
```
```shell
Ne pas changer la configuration de la carte loopback
```

Relancer la configuration réseau avec:

```bash
1
systemctl restart networking
```

Vérifier que l'interface réseau IPv6 a une adresse commençant par **fe80**.

## 🪟 Sur la VM Windows

Supprime l'adresse IPv6 `2001:db8::4` que tu as mis tout à l'heure.  
Tu peux utiliser la cmdlet `Remove-NetIPAddress`.

Désactive le DHCP pour l'IPv6.  
Voici comment faire en PowerShell:

```powershell
1
# Si l'interface réseau est Ethernet
2
Set-NetIPInterface -InterfaceAlias "Ethernet" -AddressFamily IPv6 -Dhcp Disabled
```

Redémarre la machine.  
Vérifie que l'interface réseau a une adresse commençant par **fe80**.

## 💬 Vérification de la connexion entre les machines

Fais un ping entre les machines Linux et la machine Windows.

La bonne réussite des tests indique que tu as créer un réseau entre tes machines en IPv6, et cela sans aucune configuration d'IP!

---

## 💪Challenge

Faire fonctionner le réseau IPv6 avec les 3 VM.

## 🧐 Critères d'acceptation

Valide cet atelier si ton réseau de machines IPv6 fonctionne correctement.

Quête terminée le **mardi 09 décembre 2025**