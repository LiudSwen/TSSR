---
title: "Sauvegarder ses données avec tar - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2356/pages/11672"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Sauvegarde

## Sauvegarder ses données avec tar

La commande GNU tar permet de sauvegarder une arborescence de fichiers dans un unique fichier archive

Facile

1h

3 pairs

Sauvegarde

## Sauvegarder ses données avec tar

## Introduction

**tar** est une commande classique des systèmes Unix utilisée pour **sauvegarder des fichiers**.  
Sur les systèmes **GNU/Linux**, on y trouve habituellement son implémentation réalisée par le projet **GNU**.

![Seau plein de goudron](https://farm6.staticflickr.com/5171/5562246487_2a3d944acd_z.jpg)

## 🤓 Objectifs:

✅ Découvrir les principes et enjeux des sauvegardes  
✅ Expérimenter la commande **tar** pour la création de sauvegarde manuelle  
✅ Utiliser **tar** pour développer des scripts de sauvegarde automatisée

## Sommaire

- [👉 La commande tar](https://odyssey.wildcodeschool.com/quests/2356/pages/11672#-la-commande-tar)
- [☝️ Résumé](https://odyssey.wildcodeschool.com/quests/2356/pages/11672#%EF%B8%8F-r%C3%A9sum%C3%A9)
- [📝 Quiz](https://odyssey.wildcodeschool.com/quests/2356/pages/11672#-quiz)
- [💪Challenge](https://odyssey.wildcodeschool.com/quests/2356/pages/11672#challenge)
- [🧐 Critères d'acceptation](https://odyssey.wildcodeschool.com/quests/2356/pages/11672#-crit%C3%A8res-dacceptation)

## 👉 La commande tar

La commande **tar** permet de copier un ensemble de fichiers et répertoires dans un unique fichier archive.  
Son nom signifiant *tape archiver* vient du fait qu'il était classique d'utiliser des bandes magnétiques comme support pour les sauvegardes.

Cette pratique existe toujours mais tend à être remplacée, en tout cas en partie, par des sauvegardes sur disques ou chez des hébergeurs.

```shell
Magnetic Tape Backup in 2022: Full Overview
Cet article argumente la pertinence de l'utilisation de bande magnétique comme support de sauvegarde encore aujourd'hui.https://www.nakivo.com/blog/tape-backup-overview/
```

Que l'on utilise des bandes magnétiques ou pas, **tar** reste un outil très couramment utilisé pour:

- faire des sauvegardes manuelles
- mettre en place des sauvegardes automatisées sur un petits nombres de machines
- développer un système complet de sauvegarde à base de scripts maison

Parcours attentivement l'article suivant en expérimentant les exemples proposés pour commencer à appréhender **tar** et en profiter pour t'exercer un peu avec les scripts bash.

```shell
Créer une sauvegarde avec tar
Cet article de Ionos décrit la syntaxe de la commande tar puis la création de scripts de sauvegardes avec bash et leur automatisation avec cronhttps://www.ionos.fr/digitalguide/serveur/outils/sauvegarde-avec-tar/
```

---

## ☝️ Résumé

La commande **tar** permet de sauvegarder des répertoires complets dans un fichier archive, éventuellement compressé.

---

## 📝 Quiz

```shell
# 1  - tar permet uniquement de sauvegarder sur bandes magnétiquesFauxVraiValider# 2 Les sauvegardes sont plus longues à faireLa restauration des données est plus longue et plus délicateElles consomment plus d'espace de stockageValider# 3 recoveruntartarValiderTon score :0 / 3
```

---

## 💪Challenge

- Télécharge le fichier suivant: [Code source de tar (dernière version)](https://ftp.gnu.org/gnu/tar/tar-latest.tar.gz)
- Décompresse l'archive chez toi
- Ajoute la suggestion suivante en 3ème ligne du fichier TODO: `* Make tar brew good coffee <Suggested by YourName>` en remplaçant évidemment `<YourName>` par ton nom
- Créé une nouvelle archive nommée `tar-by-<YourName>.tar.bz2` avec l'ensemble des sources de tar modifiées par tes soins et compressée cette fois-ci avec bzip2 (Profites en pour constater que dans ce cas particulier, bzip2 est bien plus efficace de gzip)
- Poste l'archive en solution

## 🧐 Critères d'acceptation

- La solution est bien un fichier tar compressé avec bzip2 et correctement nommé
- On trouve bien la modification demandée
- C'est la seule différence avec l'archive originale

Envoie ton fichier: \*

Dépose ton fichier ici, ou clique pour en choisir un.

---

Contribuer à améliorer cette quête.Tous les retours sont précieux pour l'amélioration de nos formations.

Le contenu de la quête m'a permis de comprendre les concepts et d'atteindre les objectifs annoncés:

---

Un commentaire pour nous aider à mieux comprendre?