---
title: "Authentification avec serveur FreeRadius - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/1676/pages/3763"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Réseau

## Authentification avec serveur FreeRadius

Facile

10mins

Auto-validation

Réseau

## Authentification avec serveur FreeRadius

![image](https://miro.medium.com/max/1024/1*Es5VnOhPzeHp3CUDZkH-bQ.png)

## Introduction

`FreeRADIUS` est un serveur d’authentification. RADIUS `(Remote Authentication Dial-In User Service)` est un protocole dédié à la mise en place d’une authentification sécurisée dans les réseaux. Cela permet également de centraliser des données d'authentification dans un réseau informatique. Le protocole `Radius` a été inventé et développé en 1991 par la societé `Livingston enterprise`.

- On utilise le protocole `EAP (Extensible Authentication Protocol)` et un serveur d’authentification qui est un serveur `RADIUS`. Le serveur `RADIUS` va automatiquement connecter chaque client qui se connecte au réseau sur un port précis.
- Le protocole `EAP` permet de définir quel type d'authentification sera prise en compte, cela peut être avec un mot de passe, un certificat, via une encapsulation sécurisée etc..
```python
1
- EAP-TLS (Transport Layer Security)
2
Authentification par certificat du client et du serveur.
3

4
- EAP-TTLS (Tunneled Transport Layer Security)
5
Authentification par certificat et mot de passe grâce à la génération d’un tunnel sécurisé.
6

7
- EAP-MD5
8
Authentification avec mot de passe.
9

10
- PEAP (Protected EAP)
11
Authentification avec mot de passe via une encapsulation sécurisée.
12

13
- LEAP (protocole Cisco)
14
Authentification avec mot de passe via une encapsulation sécurisée.
```
- Il existe également des protocoles comme `PAP (Password Authentication Protocol)` qui est peu sécurisé car les données peuvent être interceptées en clair, mais assez simple à mettre en place dans un réseau informatique, notamment dans des environnements comme `pfSense`.
- Le protocole `MD5-CHAP` est assez similaire au protocole `PAP` mais beaucoup plus sécurisé que son prédécesseur. L'objectif de `CHAP (Challenge Handshake Authentication Protocol)` est que le pair s'authentifie auprès d'un authentificateur sans échange de mot de passe en clair sur le réseau et sans que l'échange puisse être rejoué par un tiers à l'écoute. Il existe également des versions beaucoup plus poussées du protocole `CHAP` comme `MS-CHAPv1` et `MS-CHAPv2`.

## 🤓 Objectifs

✅ Comprendre comment fonctionne le protocole `RADIUS` et ses sous-protocoles.  
✅ Installer et mettre en place le protocole `RADIUS` avec le système du `Captive Portal`.

## 👉 Installation du package FreeRadius

- Nous utiliserons `pfSense` pour configurer notre serveur `FreeRadius`, la mise en place n'est pas très compliqué. Tu peux directement installer `pfSense` dans une machine virtuelle [ici](https://www.pfsense.org/download/), l'installation est simple et rapide.

Maintenant, nous devons installer le `package` nécessaire pour faire configurer et faire fonctionner notre serveur `FreeRadius`, allons dans `pfSense` dans `Système` et ensuite dans `Gestionnaire de paquets`.

Il suffit simplement de taper dans la barre de recherche, le nom du paquet qu'on souhaite installer, dans notre cas ça sera `freeradius` et ensuite de cliquer sur le bouton `Install` pour installer le paquet en question.

## 👉 Configuration du serveur FreeRadius

Qu'est qu'on va configurer? Lorsqu'un client tentera de contacter `Internet` en allant par exemple sur `google.fr`, il sera dirigé vers une page de connexion qui lui demandera un `login` et un `mot de passe`. Sans cette authentification, il ne pourra pas accéder au serveur `WEB`, c'est ce que on appelle un `Captive Portal` ou portail captif (en français), pour chaque client, il est possible de créer un utilisateur et mot de passe unique, et toutes les informations passeront par la passerelle, et nous pouvons centraliser les données authentifications de cette manière.

Une fois que le `package` a été installé avec succès, il suffit de partir dans `Service`, `FreeRadius`, et enfin de partir sur `Interface`.

Nous ajouterons une nouvelle interface pour configurer le serveur `FreeRadius`. Basiquement, dans l'interface `IP`, il y a une étoile (`*`), cela signifie toutes les interfaces de la machine. Personnellement, j'ai mis l'adresse de `loopback`. J'ai également mis une description à ma nouvelle configuration pour `FreeRadius`, et le port par défaut est `1812`. Enregistrons la configuration.

Notre configuration est bien présente, c'est parfait!

## 👉 Configuration du client pour FreeRadius

Il suffit maintenant de partir dans `NAS / Clients` et d'ajouter un nouveau client à notre serveur. J'ai mis à nouveau l'adresse de `loopback`, ainsi un `shortname`, et ce mot de passe. Il s'agit du secret partagé (mot de passe) dont le NAS (commutateur, point d'accès, etc.) a besoin pour communiquer avec le serveur `RADIUS`. `FreeRADIUS` est limité à 31 caractères pour le secret partagé. Ensuite, il suffit d'enregistrer la configuration.

Et comme prévu, notre configuration est bien présente.

## 👉 Création d'utilisateur pour le client

Pour qu'un client ait accès au serveur `WEB`, il doit avoir des informations d'identifications, donc, allons dans la partie `FreeRadius` et ensuite `Users`.

Cliquons sur `Ajouter`, nous ajouterons un utilisateur dans le serveur `FreeRadius`. Il suffit simplement de mettre le nom d'utilisateur, et le mot de passe. Nous pouvons sauvegarder la configuration.

## 👉 Configuration de la méthode d'authentification

- Nous devons ensuite configurer la méthode d'authentification du serveur. Il suffit simplement d'aller dans `Système`, `Gestionnaire d'usages`, et sur `Serveur d'authentification`. Ensuite, il suffira simplement d'ajouter une nouvelle méthode d'authentification.

Nous mettrons un nom descriptif. Par la suite, nous choisirons le protocole `RADIUS` (*ce qui est logique*). Ensuite, nous choisissons le protocole `PAP` car il est plus facile à mettre en place que les autres (*mais moins `safe`*). Par la suite nous mettrons l'adresse de `loopback` qui est basiquement `127.0.0.1`. Il est également important de mettre le secret partagé, et le plus important tout en bas est l'interface. Choisis la bonne interface, c'est généralement le réseau local `LAN`. Nous pouvons ensuite sauvegarder la configuration.

## 👉 Création et configuration du Portail Captif

Il nous reste encore une dernière chose à faire, c'est de mettre en place le système `Portail Captif`. Il suffit ensuite d'aller `Services` et sur `Portail Captif`. Nous ajouterons une nouvelle zone de portail captif, donc cliquons sur `Ajouter`.

Il faut attribuer un nom de zone au `Portail Captif`, il y a aussi la possibilité de mettre une description, si tu le souhaites, mais c'est facultatif. Enregistrons la configuration et poursuivons.

Il suffit simplement d'activer le `Portail Captif`, et de sélectionner l'interface (*c'est généralement le LAN*).

Et tout en bas, dans la partie `Authentification`, pour la méthode d'authentification, il suffit de prendre `Use an Authentication backend`, et ensuite de sélectionner le serveur d'authentification (*ce que nous avons créé avant, dans le gestionnaire d'usages.*), il suffit ensuite de sauvegarder la configuration.

## 👉 Essaie avec un client du Portail Captif

Maintenant, imaginons qu'un client se connecte à son ordinateur et décide d'aller sur Google, le serveur lui redirigera et demandera un `nom d'utilisateur` et `un mot de passe`.

- Donc, si je lui envoie le nom d'utilisateur et le mot de passe, j'aurais normalement accès à `Google`.

Tu peux encore aller plus loin en regardant les sources, en configurant une authentification à deux facteurs (`OTP`), avec le protocole `Kerberos`, annuaire `LDAP` etc..

```shell
Two-Factor Authentication With PFsense (FreeRadius)https://www.youtube.com/watch?v=arGofrM-YjA&t=2s&ab_channel=LawrenceSystemsLawrenceSystems
```
```shell
RADIUS and LDAP on pfSensehttps://www.youtube.com/watch?v=ZZgfqkK2q54&ab_channel=TechOuiTechOui
```

## ☝️ Résumé

- Le protocole `RADIUS` permet de s'authentifier en toute sécurité, basiquement mis au point par `Livingston`.
- Le protocole `RADIUS` connaît deux protocoles de mots de passe:
	1. **PAP (échange en clair du nom et du mot de passe).**
		2. **CHAP (protocole d'authentification, bien plus sûr que le PAP).**
- Le serveur `RADIUS` consulte sa base de données d’identification afin de connaître le type de scénario d’identification demandé pour l’utilisateur.

Contribuer à améliorer cette quête.Tous les retours sont précieux pour l'amélioration de nos formations.

Le contenu de la quête m'a permis de comprendre les concepts et d'atteindre les objectifs annoncés:

---

Un commentaire pour nous aider à mieux comprendre?