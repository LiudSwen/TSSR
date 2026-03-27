---
title: "GNS3 : Graphical Network Simulator-3 - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2063/pages/11265"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
GNS3

## GNS3: Graphical Network Simulator-3

GNS3 est un logiciel libre pour la simulation de réseaux.

Facile

1h 30mins

Quiz

GNS3

## GNS3: Graphical Network Simulator-3

## Introduction

**GNS3** est un logiciel libre pour la simulation de réseaux.  
Il permet virtuellement de déployer des réseaux, potentiellement complexes pour tester ou apprendre.

![GNS3 Logo](https://storage.googleapis.com/quest_editor_uploads/wITrWaAiDiseOOhALdGsN71gy2Nygd1P.png)

## 🤓 Objectifs:

✅ Découvrir GNS3  
✅ Installer l'outil sur sa machine  
✅ Construire son premier réseau virtuel

## 👀 Contenu de la quête:

- Introduction
- Installer GNS3
- Déployer son premier réseau

---

## 👉 Introduction à GNS3

**GNS3** est un outil permettant de simuler des réseaux. Il est construit en 2 parties:

- Une interface graphique (GUI)
- Un serveur qui héberge et fait tourner l'infrastructure virtuelle

Ce serveur peut-être installé et exécuté localement ou hébergé par une machine virtuelle (VmWare, VirtualBox, Hyper-V) locale ou distante: La **GNS3 VM**.

L'utilisation de la **GNS3 VM** est recommandée pour les installations sous Windows ou Mac OS.

Le serveur GNS3 s'appuie sur plusieurs autres outils pour faire tourner l'infrastructure virtuelle, notamment:

- [QEMU](https://www.qemu.org/): émulateur permettant la virtualisation de nombreuses plateformes matérielles
- [KVM](https://www.linux-kvm.org/page/Main_Page): hyperviseur libre intégré dans Linux
- [Docker](https://www.docker.com/): Outil permettant la gestion de conteneurs logiciels

**GNS3** permet d'écouter et d'analyser les trafics réseaux, notamment à l'aide de [Wireshark](https://www.wireshark.org/) via la [libpcap](https://www.tcpdump.org/).

Pour plus d'information sur GNS3, voir [leur site](https://gns3.com/).

---

## 👉 Installer GNS3

Lire attentivement la partie *Getting Started* de [la documentation officielle](https://docs.gns3.com/docs/) en commençant par *What's GNS3* puis en poursuivant par la partie *Installation* propre à son environnement d'installation (Windows, Linux...).

L'installation se termine en appliquant la partie *Setup wizard* du serveur installé (*local server* ou *GNS3 VM*)

```shell
Il n'est pas nécessaire d'importer d'appliances ou d'image IOS pour l'instant
```

---

## 👉 Créer son premier réseau

Suivre pas à pas la partie *You First GNS3 Topology* de la documentation pour créer son premier réseau composé d'un switch ethernet et de 3 PC virtuels (VPCS) communiquant sur le réseau IP `10.1.1.0/24`.

La configuration réseau de ces 3 PC virtuels étant enregistrée, il est possible de:

1. fermer GNS3
2. ouvrir à nouveau son projet
3. relancer les vpcs et de vérifier à nouveau les connexions.

---

## 💪 Challenge

Répondre correctement aux 3 questions du quizz