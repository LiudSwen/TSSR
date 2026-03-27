---
title: "Installation d'un serveur VPN sur pfSense - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/1410/pages/18668"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Sécurité réseau

## Installation d'un serveur VPN sur pfSense

Mettre en place un serveur VPN pour accéder à un réseau contenant des ressources non hébergé sur internet, en toute sécurité.

Moyen

2h

Auto-validation

Sécurité réseau

## Installation d'un serveur VPN sur pfSense

⚠️ Avant de commencer cette quête, tu dois avoir terminé les quêtes suivantes:

```shell
Installation du firewall pfSenseInstallation et configuration d'un firewall pfSense.2hVoir la quête - Installation du firewall pfSense
```

## Introduction

Ici nous allons voir avec **pfSense** comment monter rapidement et efficacement un serveur VPN utilisant **OpenVPN**.

![VPN](https://storage.googleapis.com/quest_editor_uploads/K1FwT9ZRVuMDS7RcSkQmSBPi17Lsyd3V.jpg)

## 🤓 Objectifs:

✅ Comprendre le rôle du VPN  
✅ Savoir installer et configurer un VPN sur pfSense

## Sommaire

- [👉 Qu’est-ce qu’un vpn?](https://odyssey.wildcodeschool.com/quests/1410/pages/18668#-quest-ce-quun-vpn-)
- [👉 Comment fonctionne un VPN?](https://odyssey.wildcodeschool.com/quests/1410/pages/18668#-comment-fonctionne-un-vpn-)
- [👉 L'utilité d'un VPN en entreprise](https://odyssey.wildcodeschool.com/quests/1410/pages/18668#-lutilit%C3%A9-dun-vpn-en-entreprise)
- [🔬 Mise en application avec pfSense](https://odyssey.wildcodeschool.com/quests/1410/pages/18668#-mise-en-application-avec-pfsense)
- [💪 Challenge](https://odyssey.wildcodeschool.com/quests/1410/pages/18668#-challenge)
- [🧐 Critères d'acceptation](https://odyssey.wildcodeschool.com/quests/1410/pages/18668#-crit%C3%A8res-dacceptation)

## 👉 Qu’est-ce qu’un vpn?

VPN est l’abréviation de *Virtual Private Network* (réseau privé virtuel) et désigne un service qui fourni une connectivité sécurisée entre 2 nœuds à travers un réseau non sûr quelconque, par exemple Internet.

C’est un canal de communication, on parle généralement de tunnel, entre d'un coté un hôte ou un réseau et de l'autre un hôte ou un réseau.

On distingue donc les VPN site à site servant à relier 2 réseaux. Par exemple pour interconnecter (tout ou partie des machines de) 2 sites distants.

Des VPN d'accès à distance permettant à un unique hôte d'accéder à un réseau à distance.

Cet accès à distance peut alors, à son tour permettre d'accéder à d'autres ressources, typiquement Internet, via un routeur réalisant un masquage d'adresse (NAT) et offrant ainsi une forme d'anonymat en ligne.

```shell
Qu'est-ce qu'un VPN
IT-connect propose un court article de définition de la notion de VPN.https://www.it-connect.fr/quest-ce-qu-un-vpn/
```

---

Un VPN est une connexion entre un serveur et un client VPN.  
Cette connexion est appelée tunnel et consiste dans l'ensemble à encapsuler les informations reçues d'un coté du tunnel dans des PDU en général chiffrés que l'autre coté du tunnel récupère et transmet.

Le trafic circulant est ainsi rendu *invisible* pour le réseau se situant entre les 2 extrémités du tunnel.

---

## 👉 L'utilité d'un VPN en entreprise

Si vos données et applications métiers sont hébergées sur des serveurs situés dans les locaux de votre entreprise et que certains utilisateurs ne travaillent pas sur site (télétravail, locaux annexes, etc.), un accès à distance à ces ressources est nécessaire.

Plusieurs solutions sont possibles, mais bien souvent les entreprises mettent à disposition des salariés un accès VPN. Cet accès VPN va permettre d'établir une connexion sécurisée entre votre ordinateur et le réseau de votre entreprise, permettant ainsi l'accès à vos fichiers et applications professionnelles.

C'est donc à cela que sert un accès VPN pour une entreprise, vous comprenez alors tout l'intérêt d'un tel outil lorsque l'on se retrouve en télétravail.

Le VPN crée une sorte d'extension du réseau de votre entreprise jusqu'à votre PC afin de simuler les accès comme si vous étiez sur place, physiquement.

![image.png](https://storage.googleapis.com/quest_editor_uploads/GGwdD9JSoKHxIgKcdpS9l0l5RuzKTBzS.png)  
Néanmoins, en fonction des usages la réactivité ne sera probablement pas la même: vous êtes dépendant de la qualité de la connexion Internet de votre domicile mais aussi de celle de votre entreprise.

---

## 🔬 Mise en application avec pfSense

pfSense permet la mise en place de serveurs VPN avec un choix de protocoles variés: IPsec, L2TP, WireWguard et OpenVPN.  
C'est avec ce dernier que cette mise en application s'effectue.

Tu peux commencer par suivre le tutoriel suivant.

```shell
pfSense : configurer un VPN-SSL client-to-site avec OpenVPN
Tutoriel pas à pas pour la configuration d'un VPN type accès distant avec openVPN sur pfSensehttps://www.it-connect.fr/pfsense-configurer-un-vpn-ssl-client-to-site-avec-openvpn/
```

---

## 💪 Challenge

Configurer un serveur VPN avec pfSense permettant l'accès distant à des utilisateurs aux ressources du réseau interne.

La machine cliente de test peut être une machine Windows ou GNU/Linux.

## 🧐 Critères d'acceptation

- Un serveur OpenVPN sur pfSense est installé et configuré
- La connexion au VPN est fonctionnel.
- Au moins un serveur présent sur le réseau interne `LAN` est accessible après avoir rejoint le réseau VPN. Ce même serveur n'est pas accessible depuis l'extérieur sinon.

Quête terminée le **mercredi 14 janvier 2026**