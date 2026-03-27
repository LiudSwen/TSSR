---
title: "Sauvegarder sur un serveur distant avec rsync - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2358/pages/11671"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Sauvegarde

## Sauvegarder sur un serveur distant avec rsync

rsync est un outil libre multi-plateforme permettant la synchronisation de répertoires

Facile

1h

3 pairs

Sauvegarde

## Sauvegarder sur un serveur distant avec rsync

## Introduction

**rsync** (*remote synchronization*) est un outil en ligne de commande permettant la synchronisation de dossiers.  
Il peut tout autant synchroniser 2 dossiers locaux que synchroniser un dossier local avec un dossier sur un serveur distant, en général via **ssh**.

Cette quête est une introduction à l'utilisation de cet outil de sauvegarde.

![Logo rsync](https://rsync.samba.org/newrsynclogo.jpg)

## 🤓 Objectifs:

✅ Explorer l'utilisation de la commande **rsync**  
✅ Réaliser une synchronisation entre un dossier local et une copie sur un serveur distant  
✅ Ajouter une nouvelle commande à sa boite à outils de sauvegarde

## Sommaire

- [👉 La commande rsync](https://odyssey.wildcodeschool.com/quests/2358/pages/11671#-la-commande-rsync)
- [☝️ Résumé](https://odyssey.wildcodeschool.com/quests/2358/pages/11671#%EF%B8%8F-r%C3%A9sum%C3%A9)
	- [📝 Quiz](https://odyssey.wildcodeschool.com/quests/2358/pages/11671#-quiz)
- [💪 Challenge](https://odyssey.wildcodeschool.com/quests/2358/pages/11671#-challenge)
- [🧐 Critères d'acceptation](https://odyssey.wildcodeschool.com/quests/2358/pages/11671#-crit%C3%A8res-dacceptation)

## 👉 La commande rsync

**rsync** est un outil permettant de réaliser des synchronisations unidirectionnelles.

Il travaille donc avec un dossier source et un dossier destination.  
La synchronisation s'effectue de la source vers la destination uniquement. Elle consiste à parcourir l'ensemble des fichiers de la source et à vérifier leur existence sur la destination.

- Si un fichier n'existe pas, il est copié sur la destination
- Si un fichier existe mais est différent, il est recopié (ou modifié) pour qu'il soit identique
- Si un fichier est identique, il n'y a rien à faire.

Il est aussi possible pour **rsync** de supprimer tous les fichiers de la destination absents de la source.

La vérification que 2 fichiers sont identiques s'effectue:

- soit via *quick check*, c'est à dire en vérifiant les tailles et dates de dernière modification
- soit via des sommes de contrôle (*checksum*) (Ce cas de figure nécessite beaucoup plus d'accès disque des 2 cotés).

L'autre point important de **rsync**, c'est que la source ou la destination peut être distante (mais pas les 2).  
La communication entre la machine qui lance la commande et la machine distante s'effectue soit via un protocole de shell distant (typiquement **ssh**), soit via un protocole spécifique, appelé aussi **rsync**.  
L'utilisation du protocole **rsync** nécessite qu'un serveur **rsync** soit en cours d'exécution sur la machine distante.

Pour découvrir comment utiliser cette commande, tu peux bien sûr te référer à la page de **man** avec `man rsync` et lire, en guise d'introduction, la ressource suivante.

```shell
rsync sur le wiki ubuntu-fr
Article expliquant quelques cas d'utilisation de la commmande rsync.https://doc.ubuntu-fr.org/rsync
```

---

## ☝️ Résumé

**rsync** est un protocole client/serveur et un outil de synchronisation entre dossiers source et destination éventuellement à distance.

---

## 📝 Quiz

```shell
# 1  - rsync signifie ?Remote SynchronizationRapide Sauvegarde YncrémentaleRapid SynchronizationRsync SynchronisationValider# 2 bidirectionnelleentre une source distante et une destination distanteunidirectionnelleentre une source locale et une destination distanteentre une source distante et une destination localeentre une source locale et une destination localeValider# 3 est un outil en ligne de commandeest un outil graphiqueValider# 4 Un outil libre sous licence GPLDéveloppé par MicrosoftDisponible pour les systèmes UnixValiderTon score :0 / 4
```

---

## 💪 Challenge

Pour ce challenge, tu as besoin d'une machine GNU/Linux quelconque, appelée cliente dans la suite, et d'un serveur SSH avec lequel elle peut communiquer.

Ces machines peuvent être virtuelles si besoin.

- Commence par t'assurer que la machine cliente peut se connecter en **ssh** au serveur sans mot de passe (donc via une authentification par clé)
- Installe **rsync** sur les 2 systèmes.
- Sur la machine cliente, choisis (ou créé) un dossier quelconque ne contenant pas d'information confidentielle et comportant plusieurs fichiers et dossiers (au moins certains de ces dossiers contenant eux aussi des dossiers non vides). C'est ce dossier que tu vas synchroniser.
- En redirigeant la sortie standard de la commande **ls**, enregistre l'ensemble des éléments présents dans ce dossier dans un fichier journal qui retrace les commandes et le résultat de ton challenge
- Synchronise maintenant ce dossier avec un dossier distant sur le serveur **ssh**. Là aussi redirige la sortie standard de **rsync** à la suite dans le fichier journal précédent.
- Sur le serveur, vérifie qu'il se trouve bien maintenant une copie du dossier. Supprime quelques fichiers de cette copie (mais pas tout!)
- Relance maintenant la synchronisation (toujours en journalisant) et constate que seul les fichiers manquants ont été copier.
- Ajoute des commentaires au fichier journal pour aider à sa compréhension
- Copie maintenant le contenu de ton fichier journal comme solution à cette quête

## 🧐 Critères d'acceptation

Le fichier journal contient bien **les commandes utilisées** pour synchroniser ainsi que **leurs affichages** et permet donc bien de constater:

- que la première synchronisation a copié l'ensemble des éléments du dossier à synchroniser (la liste affichée par **rsync** est la même que celle affichée par **ls**);
- puis que la seconde synchronisation, réalisée avec une commande identique, n'a copié que quelques fichiers (ceux manquant) et pas les autres.

---

Contribuer à améliorer cette quête.Tous les retours sont précieux pour l'amélioration de nos formations.

Le contenu de la quête m'a permis de comprendre les concepts et d'atteindre les objectifs annoncés:

---

Un commentaire pour nous aider à mieux comprendre?