---
title: "Détection d'intrusion avec Snort sur pfSense - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/1477/pages/8428"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Sécurité réseau

## Détection d'intrusion avec Snort sur pfSense

Voici une première initiation à la détection d'intrusion avec le package IDS/IPS Snort

Moyen

2h

3 pairs

Sécurité réseau

## Détection d'intrusion avec Snort sur pfSense

## Introduction

IDS, IPS, HIDS, NIDS... Tout ces termes sont encore flou pour toi, et c'est normal! Mais dans cette quêtes tu vas y voir plus clair grâce à la mise en place d'un système de détection d'intrusion sur un firewall **pfSense**.

```
Marie est en charge de la sécurité réseau de son entreprise.

Elle a déployé un pare feu en entrée de la DMZ qui bloque tout le trafic entrant à l'exception des ports 22, 80 et 443. En effet, la DMZ comporte un site web administrable via ssh.
En parcourant les logs des requêtes acceptées par le pare feu, elle découvre quelque chose d'un peu suspect...
De très nombreuses tentatives de connexion au serveur ssh provenant des mêmes adresses IP avec des identifiants crédibles mais tous différents.
Elle en déduit qu'il s'agit d'une tentative d'attaque par force brute !
Elle ajoute donc une règle de filtrage spécifique sur le pare-feu pour bloquer cette adresse.
Quelques jours plus tard, elle consulte à nouveau les logs pour découvrir que d'autres tentatives similaires ont lieu. Et même que ce genre de tentative d'attaque par force brute est permanent et est donc sans doute l’œuvre de bots !
```

En effet, chaque jours des robots, des malwares ou encore des pirates parcours des plages d'adresses IP publiques avec des scans de masse dans le but de récolter des informations, ou exploiter d'éventuelles failles de sécurité.

Pour assurer une détection et une réponse rapide aux tentatives d'intrusion, notamment en tenant compte de la permanence d'attaques automatisées, il est nécessaire d'avoir des outils pour automatiser aussi cette détection et cette réponse.

Ce genre d'outils sont appelés IDS pour *Intrusion Detection System* et IPS pour *Intrusion Prevention System*.

Tu as donc pour mission dans cette quête de mettre en place un IDS pour analyser les flux réseaux entrants et décider si le trafic est légitime ou suspect.

Attention de ne pas bloquer l'accès aux utilisateurs légitimes! il est primordiale d'être minutieux sur l'implémentation de la sécurité dans un environnement de production.

---

![ ](https://storage.googleapis.com/quest_editor_uploads/wouXegpFVXFCF8h3sULTGgAqPBuevHpA.jpg)

## 🤓 Objectifs:

✅ Comprendre le rôle d'un IPS/IDS  
✅ Connaître la différence entre un IPS et un IDS

## Sommaire

- [👉 Qu'est ce qu'un IPS/IDS?](https://odyssey.wildcodeschool.com/quests/1477/pages/8428#-quest-ce-quun-ipsids-)
	- [Le rôle d'un IDS](https://odyssey.wildcodeschool.com/quests/1477/pages/8428#le-r%C3%B4le-dun-ids)
		- [Le rôle d'un IPS](https://odyssey.wildcodeschool.com/quests/1477/pages/8428#le-r%C3%B4le-dun-ips)
- [👉 L'IDS/IPS Snort avec pfSense](https://odyssey.wildcodeschool.com/quests/1477/pages/8428#-lidsips-snort-avec-pfsense)
- [📒 Documentation](https://odyssey.wildcodeschool.com/quests/1477/pages/8428#-documentation)
	- [📝 Quiz](https://odyssey.wildcodeschool.com/quests/1477/pages/8428#-quiz)
- [💪 Challenge](https://odyssey.wildcodeschool.com/quests/1477/pages/8428#-challenge)
- [🧐 Critères d'acceptation](https://odyssey.wildcodeschool.com/quests/1477/pages/8428#-crit%C3%A8res-dacceptation)

## 👉 Qu'est ce qu'un IPS/IDS?

Les IDS et les IPS lisent tous deux les paquets réseau et en comparent le contenu à une base de menaces connues. La principale différence entre les deux tient à ce qui se passe ensuite.

Les IDS sont des outils de détection et de surveillance qui n’engagent pas d’action de leur propre fait.

Les IPS constituent un système de contrôle et de prévention qui accepte ou rejette un paquet en fonction d’un ensemble de règles.

Avec l’IDS, il est nécessaire qu’un humain ou un autre système prenne ensuite le relais pour examiner les résultats et déterminer les actions à mettre en œuvre, ce qui peut représenter un travail à temps plein selon la quantité quotidienne de trafic généré.

Pour sa part, l’objectif de l’IPS est de capturer les paquets dangereux et de les retirer avant qu’ils n’atteignent leur cible. Il est plus passif qu’un IDS et exige simplement de mettre régulièrement à jour la base de données pour y intégrer les informations relatives aux nouvelles menaces.

## Le rôle d'un IDS

Les IDS (Intrusion Detection Systems): analysent et surveillent le trafic réseau pour détecter des signes indiquant que des cybercriminels sont en train d'utiliser une vulnérabilité connue afin de s’infiltrer dans le réseau ou de récolter des informations critiques.

Les systèmes d’IDS comparent l’activité réseau en cours avec une base de données d’attaques connues afin de détecter divers types de comportements tels que les violations de la politique de sécurité, les malwares et les scanners de port...

## Le rôle d'un IPS

Les IPS (Intrusion Prevention Systems): agissent dans la même zone du réseau qu’un pare-feu, entre le monde extérieur et le réseau interne.

Les IPS rejettent de façon proactive les paquets réseau en fonction d’un profil de sécurité si ces paquets représentent une menace connue.

De nombreux fournisseurs d’IDS/IPS ont intégré de nouveaux systèmes IPS à des pare-feu, afin de créer une technologie appelée UTM (Unified Threat Management).

Cette technologie combine en une seule entité les fonctionnalités de ces deux systèmes similaires. Certains systèmes intègrent dans une même entité les fonctionnalités d’un IDS et d’un IPS.

---

## 👉 L'IDS/IPS Snort avec pfSense

Après avoir installer le paquet Snort depuis le menu System > Packet Manager

Lancer l'application de configuration Snort, accédez à Services > Snort dans le menu de l'interface graphique Web pfSense.

![../../_images/launchsnortgui.png](https://docs.netgate.com/pfsense/en/latest/_images/launchsnortgui.png)

Consultez la documentation officielle dans le lien ci-dessous pour allez plus loin.

---

## 📒 Documentation

```
Snort configuration on pfSensehttps://docs.netgate.com/pfsense/en/latest/packages/snort/setup.html
```

---

## 📝 Quiz

```
# 1  - Quel est le rôle principal d'un IDS ?De capturer le flux réseau pour une consultation ultérieureD’empêcher les pirates d'exploiter des vulnérabilitésD'analyser le flux réseau et détecter des indicateurs de tentative d'attaqueValider# 2 D'analyser le flux réseauD'analyser le flux réseau, de détecter les menaces et Cyber-AttaquesD'analyser le flux réseau, de détecter et bloquer les menaces ainsi que les Cyber-AttaquesValider# 3 OuiNonValider# 4 IDSIPSValider# 5 OuiNonValider# 6 OuiNonValider# 7 DupliquéCommutéValider# 8 OuiNonValider# 9 OuiNonValider# 10 OuiNonValiderTon score :0 / 10
```

## 💪 Challenge

Installer et configurer l'IDS/IPS Snort sur pfSense pour:

- Bloquer les attaques force brute sur ssh
- Bloquer les scans de ports ([nmap](https://nmap.org/))

Ta solution consiste à:

- Décrire ta configuration
- Expliquer les tests que tu as effectués pour vérifier l'efficacité des règles mises en place
- Montrer que les tests ont bien été détecté et bloqué par snort dans l'onglet **Blocked**

## 🧐 Critères d'acceptation

La configuration réalisée est correcte et il est possible de constater que les 2 types d'attaques sont bien bloqués par snort.

---

Contribuer à améliorer cette quête.Tous les retours sont précieux pour l'amélioration de nos formations.

Le contenu de la quête m'a permis de comprendre les concepts et d'atteindre les objectifs annoncés:

---

Un commentaire pour nous aider à mieux comprendre?