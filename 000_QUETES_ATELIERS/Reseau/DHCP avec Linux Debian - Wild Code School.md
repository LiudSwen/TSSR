---
title: "DHCP avec Linux Debian - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/1453/pages/18624"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Réseau

## DHCP avec Linux Debian

Moyen

2h

3 pairs

Réseau

## DHCP avec Linux Debian

## Introduction

Maintenant que le serveur DHCP n'a plus de secrets pour toi, tu peux désormais passer à la configuration d'un serveur DHCP sur Linux en CLI (Command Line Interface)

---

#### ⚠️Avant de commencer cette quête, tu dois avoir terminé les quêtes suivantes:

```
À la découverte de l'adresse IP30minsVoir la quête - À la découverte de l'adresse IPDécoupage de réseaux IP2hVoir la quête - Découpage de réseaux IPLe protocole DHCP1hVoir la quête - Le protocole DHCPDHCP avec Windows ServerInstallation et configuration d'un serveur DHCP avec Windows Server.2hVoir la quête - DHCP avec Windows Server
```

![Ubuntu](https://storage.googleapis.com/quest_editor_uploads/SCmtB0M08gmFIjiZzRteATmbkOwe4uwW.jpg)

## 🤓 Objectifs:

✅ Configuration type d'un serveur DHCP sur Linux

## 👀 Contenu de la quête:

- Installation standard d'un serveur DHCP

---

```
Dynamic Host Configuration Protocol (DHCP)
```
```
Documentation officiellehttps://www.isc.org/dhcp/
```
```
Basic installhttps://synay.net/fr/support/kb/installing-and-configuring-dhcp-server-linux-debian-12
```

---

## 📝 Quiz

```
# 1  - Ou se situe par défaut le fichier de configuration du DHCP pour le service isc-dhcp-server sur un système Linux ?/etc/dhcp/dhcpd.conf/etc/dhcpd.confValider# 2 fixed-addressstatic-addressValider# 3 /etc/default/isc-dhcp-server/etc/dhcpd/dhcpd.confValider# 4 /var/log/syslog/var/log/dhcp/dhcpd.logValider# 5 /var/lib/dhcp/dhcpd.leases/etc/dhcp/leasesValider# 6 /etc/default/dhcpd-relay/var/lib/default/dhcpd-relayValider# 7 OuiNonValider# 8 /etc/rsyslog.d/50-default.conf & /etc/dhcp/dhcpd.conf/var/log/syslog & /etc/dhcp/dhcpd.conf/etc/dhcpd.conf & /etc/dhcp/dhcpd.confValider# 9 Le propriétaire doit être root avec RWchmod 500Le propriétaire doit être syslog avec RWLe groupe adm doit avoir les droits R (lecture uniquement)Valider# 10 OuiNonValiderTon score :0 / 10
```

---

## 💪Challenge

Sur une VM GNU/Linux [debian](https://www.debian.org/) et en t'aidant de la *Basic install* indiquée plus haut.

```
Pense à faire un clone de ta machine (Snapshot) pour avoir un backup, en cas ou tu ferais une mauvaise configuration qui rendrait ta machine inutilisable.
La configuration de daemons se faisant en général à l'aide de fichiers, il est aussi recommander de sauvegarder chaque fichier avant modification pour pouvoir revenir en arrière aisément.
```
- Configure la carte réseau de ta machine virtuelle en *Réseau Interne*
- Configure l'interface réseau du serveur
- Configure le service DHCP sur l'étendue 172.20.0.80 - 172.20.0.150 sur le réseau 172.20.0.0/24
- Vérifie avec un client que ce dernier prend bien une adresse IP sur la plage configurée sur le serveur
- Met en place une adresse statique par adresse MAC pour un client particulier pour qu'il ai l'adresse 172.20.0.100
- Vérifie que ce second client a bien cette adresse
- Poste un lien Github qui contiendra des copies d'écran légendés:
	- La configuration DHCP du serveur
		- L'étendue IP doit être visible
		- La configuration IP du 1er client
		- Il est en DHCP
				- Il a une adresse IP dans l'étendue DHCP du serveur
		- La configuration IP du second client
		- Il est en DHCP
		- L'affichage de la fenêtre de reservation sur le serveur

## 🧐 Critères d'acceptation

- Le serveur DHCP possède un nom d'hôte adapté à son rôle ainsi qu'une configuration IP correcte
- La configuration du serveur permet bien aux client d'obtenir une adresse IP par le serveur DHCP dans la plage d'adresse donnée
- Le client qui possède la réservation n'obtient pas une autre IPv4, même s'il demande un renouvellement
- Le lien github contient 4 copies d'écran avec une légende pour chacune

Solution postée le **dimanche 14 décembre 2025**

[https://github.com/LiudSwen/dhcp-quest/blob/main/READMEdebian.md](https://github.com/LiudSwen/dhcp-quest/blob/main/READMEdebian.md)