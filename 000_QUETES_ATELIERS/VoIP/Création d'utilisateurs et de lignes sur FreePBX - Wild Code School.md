---
title: "Création d'utilisateurs et de lignes sur FreePBX - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2794/pages/10065"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
VoIP

## Création d'utilisateurs et de lignes sur FreePBX

Moyen

1h

Auto-validation

VoIP

## Création d'utilisateurs et de lignes sur FreePBX

## Introduction

Un IPBX permet la gestion d'utilisateurs, de lignes, de messagerie vocales, etc.  
Dans cette quête tu va gérer tout cela et faire communiquer 2 utilisateurs par le biais d'un client SIP.

## 📚 Pré-requis

Avant de commencer cette quête, assure-toi d'avoir déjà terminé les quêtes suivantes:

```shell
Configuration de FreePBX et mise-à-jour des modules1hVoir la quête - Configuration de FreePBX et mise-à-jour des modules
```

## 🤓 Objectifs:

✅ Créer des utilisateurs et des lignes  
✅ Configurer un client SIP  
✅ Faire communiquer 2 utilisateurs

## Sommaire

- [📖 Définitions](https://odyssey.wildcodeschool.com/quests/2794/pages/10065#-d%C3%A9finitions)
	- [☎️ Client SIP](https://odyssey.wildcodeschool.com/quests/2794/pages/10065#%EF%B8%8F-client-sip)
		- [💻 Softphone](https://odyssey.wildcodeschool.com/quests/2794/pages/10065#-softphone)
- [👉 Mise en œuvre](https://odyssey.wildcodeschool.com/quests/2794/pages/10065#-mise-en-%C5%93uvre)
	- [✔️ Prérequis](https://odyssey.wildcodeschool.com/quests/2794/pages/10065#%EF%B8%8F-pr%C3%A9requis)
		- [⚙️ Configuration réseau du serveur](https://odyssey.wildcodeschool.com/quests/2794/pages/10065#%EF%B8%8F-configuration-r%C3%A9seau-du-serveur)
		- [⚙️ Configuration réseau des clients](https://odyssey.wildcodeschool.com/quests/2794/pages/10065#%EF%B8%8F-configuration-r%C3%A9seau-des-clients)
		- [🏗️ Création d'utilisateurs et de lignes sur le serveur](https://odyssey.wildcodeschool.com/quests/2794/pages/10065#%EF%B8%8F-cr%C3%A9ation-dutilisateurs-et-de-lignes-sur-le-serveur)
		- [🔬 Installation du logiciel SIP sur les postes clients](https://odyssey.wildcodeschool.com/quests/2794/pages/10065#-installation-du-logiciel-sip-sur-les-postes-clients)
		- [⚙️ Configuration du logiciel SIP](https://odyssey.wildcodeschool.com/quests/2794/pages/10065#%EF%B8%8F-configuration-du-logiciel-sip)
		- [💬 Communication entre les postes](https://odyssey.wildcodeschool.com/quests/2794/pages/10065#-communication-entre-les-postes)
- [☝️ Résumé](https://odyssey.wildcodeschool.com/quests/2794/pages/10065#%EF%B8%8F-r%C3%A9sum%C3%A9)
- [💪Challenge](https://odyssey.wildcodeschool.com/quests/2794/pages/10065#challenge)
- [🧐 Critères d'acceptation](https://odyssey.wildcodeschool.com/quests/2794/pages/10065#-crit%C3%A8res-dacceptation)

## 📖 Définitions

Quelques définitions pour commencer.

## ☎️ Client SIP

Un **client SIP** est une application ou un dispositif qui utilise le protocole SIP (*Session Initiation Protocol*) pour gérer des communications multimédia telles que la voix, la vidéo et la messagerie instantanée. Le protocole SIP est largement utilisé pour la signalisation et le contrôle de sessions de communication dans les réseaux IP, notamment pour les appels VoIP.  
Un client SIP peut être un **softphone** installé sur un ordinateur ou un smartphone. Cela peut également être un téléphone IP physique.

## 💻 Softphone

Un **softphone** est une application qui émule la fonctionnalité d'un téléphone sur un appareil informatique. Ils peuvent également offrir des fonctionnalités supplémentaires, telles qu'une messagerie instantanée, de la visioconférence, la gestion des contacts, etc.

## 👉 Mise en œuvre

Et maintenant, la pratique!

## ✔️ Prérequis

Pour cette quête, tu as besoin des machines suivantes:

- Une VM avec FreePBX d'installé. Cette VM aura une carte réseau configurée en réseau interne.
- 2 VM Windows avec pour chacune d'elle une carte réseau configurée en réseau interne.

A moins que tu ne connecte au réseau un serveur DHCP, il faut fixer une adresse IP à chacune des machines.  
Voici ce qui va être fait ici:

- Serveur FreePBX: `172.16.10.5`
- PC client Windows 1: `172.16.10.10`
- PC client Windows 2: `172.16.10.20`

> Tu peux également connecter sur chaque machine une seconde carte réseau en **NAT** pour avoir un accès internet.

```shell
Les expérimentations pratiques ont été testées avec des OS Windows 10 installés dans des machines virtuelles VirtualBox 7 tournant sur un système hôte Ubuntu 22.04 LTS.

Elles peuvent être reproduites avec d'autres distributions Linux, sur d'autres environnement, mais des différences peuvent alors apparaître.
```

## ⚙️ Configuration réseau du serveur

Le serveur FreePBX est basé sur une distribution Linux CentOS, donc la configuration n'est pas la même que sur une Debian par exemple.

La commande `ip a` te permet d'afficher les cartes réseaux.  
Le fichier de configuration réseau à éditer pour modifier les paramètres de la carte `eth0` est `/etc/sysconfig/network-scripts/ifcfg-eth0`.  
Ajoute ou modifie les lignes suivantes:

```shell
BOOTPROTO=static
IPADDR=172.16.10.5
NETMASK=255.255.255.0
```

Enregistre le fichier et redémarre le service réseau avec la commande `systemctl restart network`.

## ⚙️ Configuration réseau des clients

Sur la VM client 1, écrire les commandes PowerShell suivante pour avoir une configuration IP statique:

```powershell
1
$Adapter = $(Get-NetAdapter)[0]
2
New-NetIPAddress -InterfaceIndex $Adapter.ifIndex -IPAddress 172.16.10.10 -PrefixLength 24
```

Faire la même chose sur la VM client 2 avec l'adresse `172.16.10.20`

## 🏗️ Création d'utilisateurs et de lignes sur le serveur

Tu as ci-dessous le plan de numérotation que tu vas utiliser:

| Poste client | Numéro de ligne | Nom | Mot de passe |
| --- | --- | --- | --- |
| Client 1 | 80100 | Marie Dupont | 1234 |
| Client 1 | 80101 | Pierre Martin | 1234 |
| Client 2 | 80102 | Stéphanie Lefevre | 1234 |
| Client 2 | 80103 | Jacques Petit | 1234 |

Connecte-toi en web à partir d'un des clients, sur l'adresse `172.16.10.5` du serveur.  
Utilise le compte root.

Va dans le menu `Applications` puis `Extensions`, tu arrives sur cette fenêtre:

![fenêtre du menu extension](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/Freepbx-29.png?raw=true)

Va sur sur l'onglet `SIP [chan_pjsip] Extensions` et clique sur le bouton +Add New SIP \[chan\_pjsip\] Extension.

![fenêtre de l'onglet SIP Extensions du menu extension](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/Freepbx-30.png?raw=true)

La fenêtre suivante va s'afficher:

![fenêtre de création de compte SIP](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/Freepbx-31.png?raw=true)

Pour créer la 1ère ligne, celle de **Marie Dupont**, renseigne les informations suivante:

- **User Extension**: `80100`
- **Display Name**: `Marie Dupont`
- **Secret**: `1234`
- **Password For New User**: `1234`

Tu dois avoir les informations comme ceci:

![fenêtre de création de compte SIP avec les information de l'utilisateur Marie Dupont](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/Freepbx-32.png?raw=true)

Clique sur le bouton Submit puis Apply Config pour enregistrer ton utilisateur.  
Tu viens de créer ta première ligne téléphonique!

![fenêtre qui montre la liste des utilisateurs et des lignes téléphoniques](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/Freepbx-33.png?raw=true)

De la même manière, créer les 3 autres lignes.  
Tu dois avoir ceci:

![fenêtre qui montre la liste des 4 utilisateurs crées](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/Freepbx-34.png?raw=true)

## 🔬 Installation du logiciel SIP sur les postes clients

Prendre la source [ici](https://3cxphone.software.informer.com/download/).  
Télécharge la version **x86/x64** sur le site de et installe-là sur les 2 clients Windows.

![Choix du type de logiciel à télécharger](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/Freepbx-35.png?raw=true)

![liste des versions téléchargeables du logiciel 3cx](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/Freepbx-36.png?raw=true)

## ⚙️ Configuration du logiciel SIP

Sur le poste client 1, va dans le menu démarrer et cherche le logiciel **3CX Phone** pour l'éxecuter.

![sip phone 3cx](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/Freepbx-37.png?raw=true)

Sur l'écran du SIP phone, clique sur `Set account` pour avoir la fenêtre **Accounts**.

![SIP phone 3cx](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/Freepbx-38.png?raw=true)

![fenêtre Account dans le SIP phone 3cx](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/Freepbx-39.png?raw=true)

En cliquant sur New, la fenêtre de création de compte **Account settings** apparaît:

![fenêtre Account settings dans le SIP phone 3cx](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/Freepbx-40.png?raw=true)

Pour configurer la ligne de l'utilisatrice **Marie Dupont**, rentre les informations comme ceci:

- **Account Name**: `Marie Dupont`
- **Caller ID**: `80100`
- **Extension**: `80100`
- **ID**: `80100`
- **Password**: `1234`
- **I am in the office - local IP**: l'adresse IP du serveur soit `172.16.10.5`

Clique sur Ok tu dois avoir cette fenêtre:

![fenêtre Account settings dans le SIP phone 3cx avec le compte marie dupont](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/Freepbx-41.png?raw=true)

De la même manière, configure la ligne pour **Pierre Martin**.

Sur le client 2, configure les lignes de **Stéphanie Lefevre** et **Jacques Petit**.

## 💬 Communication entre les postes

Sur le client 1, tape sur le clavier du SIP phone le numéro **80103** et clique sur la touche d'appel (la touche verte).

![taper 80103 sur le SIP phone du client 1 pour initier un appel](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/Freepbx-42.png?raw=true)

Sur le client 2 on voit l'appel arriver. On peut répondre en cliquant sur le bouton vert ou refuser l'appel en cliquant sur le bouton rouge.

![appel arrivant sur le SIP phone du client 2](https://github.com/WildCodeSchool/TSSR_Resources/blob/main/Ressources_quetes/Freepbx-43.png?raw=true)

```shell
Tu a réussi à faire communiquer tes 2 utilisateurs !
```

---

## ☝️ Résumé

Au lieu d'utiliser un téléphone physique on peut utiliser un logiciel pour communiquer, un softphone.  
En softphonie, on parle de clients SIP pour évoquer les logiciels installés sur des ordinateurs ou des smartphones servant à prendre le rôle de téléphone.

## 💪Challenge

Faire communiquer 2 utilisateurs par le biais de 2 SIP phones sur 2 client différents.

## 🧐 Critères d'acceptation

Un appel est possible entre les 2 clients.

Quête terminée le **jeudi 19 février 2026**