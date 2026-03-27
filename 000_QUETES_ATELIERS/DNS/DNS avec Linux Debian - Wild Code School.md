---
title: "DNS avec Linux Debian - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/1454/pages/12549"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
DNS

## DNS avec Linux Debian

Moyen

2h

3 pairs

DNS

## DNS avec Linux Debian

## Introduction

Cette quête concerne la mise en place un serveur DNS sur un système GNU/Linux en CLI (Command Line Interface) avec le Bind9.

⚠️Avant de commencer cette quête, tu dois avoir terminé les quêtes suivantes:

```shell
DNS avec Windows ServerDécouverte du Système des noms de domaine (Domain Name System - DNS) et configuration sur un serveur Windows2hVoir la quête - DNS avec Windows Server
```

---

![image](https://storage.googleapis.com/quest_editor_uploads/1x93rzVGf5W0o5TUegkZvPgLpO6uu69A.jpg)

## 🤓 Objectifs:

✅ Installer et configurer un service DNS sur Linux

## 👉 Installation de DNS avec Bind9

Maintenant que la résolution de nom avec le DNS n'est plus une découverte, tu peux t'attaquer à sa mise en œuvre sous GNU/Linux.

```shell
Tuto d'installation du serveur DNS bind 9 sous debianCette ressource montre comment faire une installation et une configuration simple du serveur DNS Bind9https://www.linuxtechi.com/install-configure-bind-9-dns-server-ubuntu-debian/
```

---

## 📝 Quiz

```shell
# 1  - Dans quel répertoire sont stocké les fichiers de configuration du service bind9 ? /var/bind9/etc/bind//etc/bind9/Valider# 2 nslookuphostdigValider# 3 /etc/bind/named.conf.local/etc/bind/reverse.confValider# 4 dignamed-checkzonename-checkValider# 5 FacultatifObligatoirechrooté bind9 si AppArmor est désactivéAutoriser la résolution de nom uniquement en localValider# 6 NonOuiValiderTon score :0 / 6
```

---

## 💪Challenge

Sur une VM GNU/Linux [debian](https://www.debian.org/) en t'aidant de la ressource d'installation indiquée plus haut.

```shell
Pense à faire un clone de ta machine (Snapshot) pour avoir un backup, au cas où tu ferais une mauvaise configuration qui rendrait ta machine inutilisable.
La configuration de daemons se faisant en général à l'aide de fichiers, il est aussi recommandé de sauvegarder chaque fichier avant modification pour pouvoir revenir en arrière aisément.
```
- Configure la carte réseau de ta machine virtuelle en "Réseau Interne"
- Mettre en place un serveur DNS sur Linux avec Bind9
- Ce serveur fait autorité sur la zone `wilders.lan`
- Créer un enregistrement de type A et CNAME
- Test le bon fonctionnement du serveur y compris depuis un client sur le réseau local

## 🧐 Critères d'acceptation

- La zone de recherche se nomme `wilders.lan`
- La résolution d'adresse IP est fonctionnelle (champs A)
- La résolution de l'alias est fonctionnelle (champs CNAME)
- Les tests proposés permettent effectivement de valider les points ci-dessus
- Le lien Github contient les copies d'écran montrant les configurations et les résultats

Solution postée le **dimanche 14 décembre 2025**

[https://github.com/LiudSwen/dns-quest/blob/main/READMEdebian.md](https://github.com/LiudSwen/dns-quest/blob/main/READMEdebian.md)