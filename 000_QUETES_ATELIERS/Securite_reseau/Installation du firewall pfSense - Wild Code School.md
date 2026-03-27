---
title: "Installation du firewall pfSense - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/1390/pages/13852"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Sécurité réseau

## Installation du firewall pfSense

Installation et configuration d'un firewall pfSense.

Moyen

2h

3 pairs

Sécurité réseau

## Installation du firewall pfSense

## Introduction

Le but de cette quête est d'expérimenter l'utilisation d'un pare-feu (*firewall*).  
On s'appuie sur le système d'exploitation libre **pfSense** qui est basé sur **freeBSD** et vise à permettre le déploiement de firewall sur du matériel spécifique ou sur des ordinateurs quelconques.

---

![Mur_Firewall_picture](https://storage.googleapis.com/quest_editor_uploads/9vTSCNVgc5oyPSsvCyUxgjLn37q5mlbt.jpg)

## 🤓 Objectifs:

✅ Comprendre le fonctionnement d'un firewall  
✅ Savoir installer et configurer un firewall sur pfSense

## 👀 Contenu de la quête:

- Le rôle du firewall
- Les types de firewall

---

## 👉 Le rôle du firewall

Les pares-feux sont utilisés pour restreindre l’accès extérieur à votre ordinateur par le réseau. Ils peuvent bloquer les tentatives d’intrusion via des signatures applicatives, des protocoles ou des ports. Les administrateurs peuvent configurer le type de trafic autorisé ou non à passer.

Le pare-feu est aussi un outil efficace de gestion de règles d’accès vers l’extérieur. Il permet de limiter les communications des ordinateurs internes vers un réseau extérieur tel qu'Internet.

Il contrôle véritablement le trafic réseau, l’analyse et le filtre pour essayer de n'avoir depuis et vers son réseau que des communications légitimes.

---

## 👉 Les types de firewall

Il existe deux types de pare-feu:

1. pare-feux classiques
2. pare-feux personnels

Les pares-feux classiques sont habituellement placés à l'interconnexion de plusieurs réseaux et agissent comme un garde de sécurité pour l'ensemble du trafic passant par cette interconnexion tandis que les pares-feux personnels font la même chose mais seulement pour le périphérique spécifique sur lequel ils sont installés.  
De nombreux ordinateurs individuels sont équipés de pares-feux personnels, mais le type de firewall le plus efficace est le pare-feu sur le réseau.

En effet, un pare-feu personnel n'offre pas le même niveau de sécurité.  
Il est destiné à un public non professionnel. Son utilisation est souvent plus simple et il permet une utilisation interactive. Il peut ainsi prévenir l'utilisateur qu'un trafic vient d'être bloqué et lui offrir la possibilité de l'autoriser à la volée.  
Néanmoins ce confort d'utilisation et son intégration à un ordinateur servant à d'autres usages le rendent moins fiable qu'un pare-feu plus classique.

Les pares-feux classiques sont en général intégrés directement sur un équipement réseau tel qu'un routeur. Ils requièrent des compétences techniques pour les paramétrer. L'intégration d'un pare-feu à un équipement du réseau le rend peu vulnérable aux attaques.  
On trouve d'ailleurs des équipements spécialisés dits firewall qui cumulent en général dans un équipement materiel préinstallé, des fonctionnalités de routage et de filtrage du réseau (et souvent bien plus). Il est courant d'appeler ce genre d'équipement des pare-feux matériels.

---

## 💻 Installation de pfSense

Pour commencer à expérimenter avec un firewall, tu vas installer **pfSense** dans un environnement de test (qui peut être constitué de machines virtuelles).

## 📚 Introduction à pfSense

pfSense est un système dédié au firewalling. Il est installé sur des équipements matériels spécialisés (qu'on appellent firewall matériels), mais peut aussi être installé sur des machines plus classiques. Il ne nécessite d'ailleurs que peu de ressources matérielles pour fonctionner, en tout cas quand il n'a pas beaucoup de trafic réseau à traiter.

Il s'agit en pratique d'une distribution du système [FreeBSD](https://www.freebsd.org/fr/) configurée et customisée pour servir de firewall facile d'accès en proposant notamment un interface web complète d'administration. Son nom fait d'ailleurs référence à [Packet Filter](https://fr.wikipedia.org/wiki/Packet_Filter), le firewall d' [OpenBSD](https://www.openbsd.org/) qui est aussi le firewall standard de FreeBSD.

Il offre de multiples fonctionnalités telles que:

- Le filtrage réseau (bien sûr)
- DHCP
- DNS et DNS Dynamique
- Routeur avec NAT
- Pont et VLAN
- Serveur de temps NTP
- Portail captif
- Gestion de connexions Internet multiples
- ...

## 🛠️ Mise en œuvre

L'environnement de test à mettre en place est constitué d'une machine avec 2 interfaces réseaux sur laquelle est installé pfSense.

L'une de ces interfaces est reliée à ton réseau Internet (par exemple via un pont). Cette interface constitue l'accès à l'extérieur, appelé WAN du point de vue de pfSense.

L'autre sert de connexion avec réseau interne que pfSense appelle LAN.

pfSense est ainsi chargé à la fois du routage entre les 2 réseaux avec du NAT pour la partie IPv4 puisque l'utilisation d'adresses privées RFC 1918 est toute indiquée pour ce réseau privé mais aussi de l'adressage automatique du réseau interne via DHCP.  
pfSense peut de plus se comporter soit comme un relai DNS vers des serveurs récursifs tiers, soit être lui-même un serveur DNS récursif pour le réseau interne.

2 machines sont nécessaires sur le réseau interne. Une machine qui sera le poste d'administration permettant de configurer pfSense. L'autre machine sera une machine client test quelconque.

```
La documentation officielle de pfSenseLa documentation de pfSense contient une partie Installing and Upgrading que tu peux suivre pour faire l'installation pas à pas de pfSensehttps://docs.netgate.com/pfsense/en/latest/
```

Une fois cette installation effectuée et les réseaux configurés, assure toi que:

- Les machines du réseau interne peuvent communiquer avec le firewall sur leur interface interne et peuvent aussi se connecter aux machines de l'extérieur.
- Les machines de l'extérieur ne peuvent pas se connecter à l'interface d'administration de pfSense
- Le mot de passe par défaut du compte admin a bien été modifié comme la configuration de l'interface web d'administration te l'a suggéré.

En cas d'utilisation de VM, les instantanés (*snapshots*) permettent d'enregistrer l'état complet d'une machine pour pouvoir y revenir en cas de problème. N'hésite pas à faire un snapshot de ta machine installée pour pouvoir revenir à son état initial en cas de problème.

---

## 📝 Quiz

```
# 1  -  Quelles sont les particularités d'un firewall personnel ?Il est installé sur une machine clienteIl offre un niveau de sécurité équivalent à un firewall classiqueIl permet un fonctionnement interactifValider# 2 Filtrer le trafic réseauLimiter la propagation des incendiesVérifier la présence de logiciels malveillants sur le système de fichier d'un ordinateurEmpêcher les spamValider# 3 Aucune, ce n'est pas un outil réseau2, une pour l'intérieur et une pour l'extérieurPlusieursUne seuleValider# 4 NonOuiValider# 5 WANLANValiderTon score :0 / 5
```

---

## 💪 Challense

1. Installer pfSense
2. S'assurer d'une configuration réseau valide permettant aux machines internes d’accéder à l'extérieur
3. Tester que la machine client peut accéder à l'extérieur
4. Mettre en place une règle de filtrage réseau pour interdire à la machine client de sortir du réseau interne
5. Vérifier que la machine client ne peut plus communiquer avec l'extérieur, mais que le poste d'administration peut encore communiquer avec l'extérieur
6. Expliquer la règle de filtrage mise en place dans le bloc de texte solution de la quête

## 🧐 Critères de validation

- La règle de filtrage proposée permet bien d’empêcher uniquement la machine cliente d'acceder aux réseaux extérieurs

Solution postée le **mercredi 14 janvier 2026**

## Description de la règle de filtrage mise en place

Une règle de pare-feu a été créée sur l'interface LAN afin d'empecher une machine cliente spécifique d'accéder aux réseaux extérieurs.

La règle est définie comme suit:  
Action: Block  
Interface: LAN  
Famille d’adresses: IPv4 et IPv6  
Protocole: any  
Source: adresse IP de la machine cliente (192.168.1.100)  
Destination: any  
Position de la règle: placée au-dessus des règles d’autorisation par défaut du LAN

Cette règle bloque tout trafic sortant provenant de la machine cliente vers l’extérieur du réseau interne.