---
title: "DHCP avec Windows Server - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/1445/pages/18627"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Réseau

## DHCP avec Windows Server

Installation et configuration d'un serveur DHCP avec Windows Server.

Moyen

2h

3 pairs

Réseau

## DHCP avec Windows Server

## Introduction

Dans cette quête nous allons apprendre à configurer un serveur DHCP sur Windows Server, ce service est essentiel pour gérer l'adressage IP de manière dynamique. Il nous évite d'avoir à attribuer une adresse IP fixe à chaque client souhaitant utiliser le réseau.  
Pour un administrateur systèmes et réseaux il est fondamental de savoir gérer et configurer ce genre de service, souvent présent dans le monde de l'entreprise.

---

#### ⚠️Avant de commencer cette quête, tu dois avoir terminé les quêtes suivantes:

```shell
À la découverte de l'adresse IP30minsVoir la quête - À la découverte de l'adresse IPDécoupage de réseaux IP2hVoir la quête - Découpage de réseaux IPLe protocole DHCP1hVoir la quête - Le protocole DHCP
```

![Ping_DHCP_Quest](https://storage.googleapis.com/quest_editor_uploads/B3k5i2QCIjhOz1jTJuggfTWch8mXLmt2.jpg)

## 🤓 Objectifs:

✅ Comprendre le fonctionnement du protocole DHCP  
✅ Configurer le service DHCP sur un serveur Windows

## sommaire

- [👉 Rappels](https://odyssey.wildcodeschool.com/quests/1445/pages/18627#-rappels)
	- [Le fonctionnement du protocole DHCP](https://odyssey.wildcodeschool.com/quests/1445/pages/18627#le-fonctionnement-du-protocole-dhcp)
		- [Le Rôle du Service DHCP](https://odyssey.wildcodeschool.com/quests/1445/pages/18627#le-r%C3%B4le-du-service-dhcp)
		- [Pourquoi utiliser DHCP?](https://odyssey.wildcodeschool.com/quests/1445/pages/18627#pourquoi-utiliser-dhcp-)
		- [Fonctionnement](https://odyssey.wildcodeschool.com/quests/1445/pages/18627#fonctionnement)
		- [Renouvellement de bail IP](https://odyssey.wildcodeschool.com/quests/1445/pages/18627#renouvellement-de-bail-ip)
- [👉 Configuration d'un serveur DHCP](https://odyssey.wildcodeschool.com/quests/1445/pages/18627#-configuration-dun-serveur-dhcp)
- [👉 Installation du rôle DHCP](https://odyssey.wildcodeschool.com/quests/1445/pages/18627#-installation-du-r%C3%B4le-dhcp)
- [👉Configuration post-déploiement](https://odyssey.wildcodeschool.com/quests/1445/pages/18627#configuration-post-d%C3%A9ploiement)
- [👉Configuration d'une étendue DHCP](https://odyssey.wildcodeschool.com/quests/1445/pages/18627#configuration-dune-%C3%A9tendue-dhcp)
- [👉Test du service DHCP](https://odyssey.wildcodeschool.com/quests/1445/pages/18627#test-du-service-dhcp)
- [👉Réservation d'adresse IP](https://odyssey.wildcodeschool.com/quests/1445/pages/18627#r%C3%A9servation-dadresse-ip)
	- [📝 Quiz](https://odyssey.wildcodeschool.com/quests/1445/pages/18627#-quiz)
- [💪Challenge](https://odyssey.wildcodeschool.com/quests/1445/pages/18627#challenge)
- [🧐 Critères d'acceptation](https://odyssey.wildcodeschool.com/quests/1445/pages/18627#-crit%C3%A8res-dacceptation)

## 👉 Rappels

## Le fonctionnement du protocole DHCP

Le protocole DHCP (Dynamic Host Configuration Protocol) ([RFC 2131](https://www.rfc-editor.org/rfc/rfc2131), [RFC 2132](https://www.rfc-editor.org/rfc/rfc2132.html)) est une extension de BOOTP ([RFC 951](https://www.rfc-editor.org/rfc/rfc951)), il fournit une configuration dynamique des adresses IP et des informations associées aux ordinateurs configurés pour l'utiliser (clients DHCP).

## Le Rôle du Service DHCP

Par le biais d'un serveur DHCP, les hôtes du réseau qui en font la demande obtiennent une configuration IP dynamiquement au moment du démarrage.  
Le serveur DHCP leur attribue notamment une adresse IP, un masque et éventuellement l'adresse d'une passerelle par défaut.  
Il peut attribuer beaucoup d'autres paramètres IP notamment en matière de noms (l'adresse des serveurs DNS, l'adresse des serveurs WINS)

Un serveur DHCP (Dynamic Host Configuration Protocol) distribue des configuration IP à des clients pour une durée déterminée. On parle de baux DHCP.

Au lieu d'affecter manuellement à chaque hôte une adresse statique et tous les paramètres de configuration réseau tels que l'adresse des serveurs de noms, la passerelle par défaut, le nom du domaine, un serveur DHCP alloue à un client, un bail d'accès au réseau, pour une durée déterminée  
(durée du bail). Le serveur passe en paramètres au client toutes les informations dont il a besoin.

## Pourquoi utiliser DHCP?

- Le protocole DHCP offre une configuration de réseau IP fiable et simple, empêche les conflits d'adresses et permet de contrôler l'utilisation des adresses IP de façon centralisée. Ainsi, si un paramètre change au niveau du réseau, comme, par exemple l'adresse de la passerelle par défaut, il suffit de changer la valeur du paramètre au niveau du serveur DHCP, pour que toutes les  
	stations prennent en compte le nouveau paramètre dès que le bail sera renouvelé. Dans le cas de l'adressage statique, il faudrait manuellement reconfigurer toutes les machines.
- Économie d'adresses: ce protocole est presque toujours utilisé par les fournisseurs d'accès Internet qui disposent d'un nombre d'adresses limité. Ainsi grâce à DHCP, seules les machines connectées en ligne ont une adresse IP.
- Les postes itinérants sont plus faciles à gérer.
- Le changement de plan d'adressage se trouve facilité par le dynamisme d'attribution. Il est d'ailleurs envisageable d'utiliser DHCP aussi pour des machines devant toujours avoir la même adresse (on parle d'adressage statique) en créant sur le serveur une association entre une adresse MAC et une adresse IP ([RFC 3046](https://www.rfc-editor.org/rfc/rfc3046.html)).

## Fonctionnement

Un client DHCP est un ordinateur qui demande une adresse IP à un serveur DHCP.

Comment, un client DHCP, qui utilise le protocole IP mais qui n'a pas encore obtenu d'adresse IP par le serveur, peut-il communiquer sur le réseau?

Lorsqu'un client DHCP initialise un accès à un réseau IP, le processus d'obtention d'un bail IP se déroule en 4 étapes:

**1ère étape** (`DISCOVER`): Le client émet un message de demande de bail IP qui est envoyé sous forme d'une diffusion sur le réseau physique avec comme adresse IP source: `0.0.0.0` et comme adresse IP destination: `255.255.255.255`.

**2e étape** (`OFFER`): Les serveurs DHCP répondent en proposant une adresse IP avec une durée de bail et l'adresse IP du serveur DHCP

**3e étape** (`REQUEST`): Le client sélectionne la première adresse IP (s'il y a plusieurs serveurs DHCP) reçue et envoie une demande d'utilisation de cette adresse au serveur DHCP. Son message envoyé par diffusion comporte l'identification du serveur sélectionné qui est informé que son offre a été retenue, tous les autres serveurs DHCP retirent leur offre et les adresses proposées redeviennent disponibles.

**4e et dernière étape** (`ACK`): Le serveur DHCP accuse réception de la demande et accorde l'adresse en bail, les autres serveurs retirent leur proposition. Enfin le client utilise l'adresse pour se connecter au réseau.

Une mnémotechnique: c'est le processus `D.O.R.A` pour **D** iscover **O** ffer **R** equest **A** cknowledge

## Renouvellement de bail IP

Lorsque 50% de la durée du bail est écoulée, le client tente de renouveler son bail auprès du serveur qui lui a offert. Sans réponse positive lorsqu'il atteint 87,5% de la durée de son bail, le client contacte l'ensemble des serveurs DHCP (par diffusion d'un `REQUEST`). Les serveurs répondent soit par `ACK` soit par `NACK` (adresse inutilisable, étendue désactivée...).

Lorsque le bail expire ou qu'un message `NACK` est reçu le client doit cesser d'utiliser l'adresse IP et demander un nouveau bail (retour au processus de souscription). Lorsque le bail expire et que le client n'obtient pas d'autre adresse la communication IP s'interrompt.

Remarque: Si la demande n'aboutit pas et que le bail n'est pas expiré, le client continue à utiliser ses paramètres IP.

Lorsqu'un client redémarre, il tente d'obtenir un bail pour la même adresse auprès du serveur DHCP qui lui a accordé, en émettant un `REQUEST`. Si la tentative se solde par un échec, le client continue à utiliser la même adresse IP s'il lui reste du temps sur son bail.

## 👉 Configuration d'un serveur DHCP

La configuration d'un serveur DHCP consiste à définir une plage d'adresses qui peuvent être allouées à des hôtes qui en font la demande.

En général, on donne:

- Une adresse de début (la première qui sera attribuée)
- Une adresse de fin (la dernière)
- Une ou plusieurs plages d'adresses à exclure de l'attribution (ceci permet de faire cohabiter un modèle de configuration IP dynamique avec un modèle statique)
- Un masque de sous-réseau
- Une adresse de passerelle par défaut
- Les adresses de serveurs DNS
- La durée du bail

Si, au bout de cette durée, l'hôte ne sollicite pas à nouveau une adresse au serveur, cette adresse est jugée disponible pour un autre hôte.  
Il est possible de connaître les baux actifs (les adresses actuellement attribuées), on voit alors à quelle adresse MAC est attribuée chaque adresse IP.

## 👉 Installation du rôle DHCP

Le serveur doit avoir une adresse IP statique.  
Pour la suite on estime que ce serveur a une adresse fixe dans la plage IP des machines clientes, par exemple 172.16.10.0/24.

- Aller dans le **Server Manager**
- Cliquer sur **Manage** -> **Add Roles and Features** pour démarrer l'ajout du rôle DHCP
- Cliquer sur **Next**
- Laisser l'option sélectionnée par défaut **Role-Based or feature-based installation** et cliquer sur **Next**
- Garder le serveur sélectionné et cliquer sur **Next**
- Cocher le rôle **DHCP Server**
- Une fenêtre contextuelle va apparaître, il faut cliquer sur **Add Features** pour inclure les outils d'administration proposés
- Cliquer sur **Next** 3 fois
- Cliquer sur **Install** et ensuite sur **Close** pour laisser l'installation en arrière-plan

## 👉Configuration post-déploiement

- Cliquer sur l'icône ronde avec des flèches à l’intérieur qui tournent pour rafraîchir l'affichage
- Attendre l'icone de notification (triangle jaune)
- Une fois que l'icone apparait, cliquer dessus et cliquer sur **Complete DHCP configuration**
- Cliquer sur **Commit** puis **Close**

## 👉Configuration d'une étendue DHCP

- Ouvrir la console DHCP avec l'une de ces méthodes:
	- Cliquer sur l'icone **DHCP** dans le panneau gauche de la console
		- Cliquer avec le bouton droit de la souris sur le serveur sélectionné
				- Cliquer sur **DHCP Manager**
		- Cliquer dans **Tools** puis sur **DHCP**
- Dérouler le nœud du serveur et cliquer avec le bouton droit de la souris sur **IPv4**
- Sélectionner **New Scope**
- Cliquer sur **Next**
- Donner un nom et une description, par exemple **VLAN 10**
- Ensuite indique le début et la fin de la plage IP ainsi que le CIDR
- Cliquer sur **Next** plusieurs fois et finalement sur **Finish**

## 👉Test du service DHCP

Tester avec un client sur le même réseau s'il reçoit bien une adresse IP dans la plage IP configurée sur le serveur.

## 👉Réservation d'adresse IP

Dans la partie **Reservation** tu peux réserver une adresse IP dans une étendue (ou non).  
Tu vas dans ce cas identifier l'hôte par son adresse MAC.

---

## 📝 Quiz

```shell
# 1  - Quel acronyme récapitule les 4 étapes d'une demande d'adresse d'un client a un serveur DHCP ?D.O.R.AD.O.R.ED.O.R.IValider# 2 RFC 2131RFC 1497RFC 3046Valider# 3 1983199319951990Valider# 4 RFC 2131RFC 1531RFC 1497RFC 2132Valider# 5 68538067Valider# 6 443686967Valider# 7 BroadcastUnicastValider# 8 Uniquement à la fin du bail87,5% pourcentage de la durée du bail75% pourcentage de la durée du bail50% pourcentage de la durée du bailValider# 9 Uniquement à la fin du bail75% pourcentage de la durée du bail87,5% pourcentage de la durée du bail50% pourcentage de la durée du bailValider# 10 75% pourcentage de la durée du bail87,5% pourcentage de la durée du bail50% pourcentage de la durée du bailUniquement à la fin du bailValider# 11 À la récéption du DHCP OfferÀ la récéption du DHCP AckAprès l'envoi du DHCP DiscoverAprès l'envoi du DHCP RequestValiderTon score :0 / 11
```

---

## 💪Challenge

Sur un Windows Server (tu peux éventuellement utiliser une version d'évaluation disponible sur [le centre d'évaluation Microsoft](https://www.microsoft.com/fr-fr/evalcenter/)) déployé sur une VM.

```shell
Pense à faire un clone de ta machine (Snapshot) pour avoir un backup, en cas ou tu ferais une mauvaise configuration qui rendrait ta machine inutilisable.
```
- Configure la carte réseau de ta machine virtuelle en *Réseau Interne*
- Tu vas mettre en place l'étendue DHCP 172.20.0.100 - 172.20.0.200 sur le réseau 172.20.0.0/24
	- Configure l'adresse IP du serveur en statique en 172.20.0.1/24
		- Configure le service DHCP pour qu'il fournisse des adresses IP de la plage donnée
- Un client qui rejoint le réseau obtient une adresse IP dans la plage donnée par le DHCP
	- Intègre un client sur ce réseau et vérifie cela
- Mets en place une attribution statique pour une machine cliente particulière dont l'adresse MAC permet d'obtenir l'adresse 172.20.0.10

Poste un lien Github qui contiendra des copies d'écran légendés:

- La configuration DHCP du serveur
	- L'étendue IP doit être visible
- La configuration IP du 1er client
	- Il est en DHCP
		- Il a une adresse IP dans l'étendue DHCP du serveur
- La configuration IP du second client
	- Il est en DHCP
- L'affichage de la fenêtre de réservation sur le serveur

## 🧐 Critères d'acceptation

- Le serveur DHCP possède un nom d'hôte adapté à son rôle (Exemple: SRV-DHCP) ainsi qu'une configuration IP correcte
- La configuration du serveur permet bien aux client d'obtenir une adresse IP par le serveur DHCP dans la plage d'adresse donnée
- Le client qui possède la réservation n'obtient pas une autre IPv4, même s'il demande un renouvellement
- Le lien github contient 4 copies d'écran avec une légende pour chacune

Solution postée le **dimanche 14 décembre 2025**

[https://github.com/LiudSwen/dhcp-quest/blob/main/READMEwindows.md](https://github.com/LiudSwen/dhcp-quest/blob/main/READMEwindows.md)