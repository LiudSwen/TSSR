---
title: "Active Directory Domain Services - Domaines, Arborescences et Forêts - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/1950/pages/18641"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Active Directory

## Active Directory Domain Services - Domaines, Arborescences et Forêts

Facile

30mins

Quiz

Active Directory

## Active Directory Domain Services - Domaines, Arborescences et Forêts

## Introduction

Prenons un peu notre envol et intéressons-nous à la structure globale d’une architecture **Active Directory**, où l’on trouvera potentiellement plusieurs domaines, des arbres et une forêt.

Nous avons déjà évoqué la notion de domaine, mais voyons ce qu’est un arbre et ce qu’est une forêt, et la position d’un domaine dans tout ça.

## 📚 Prérequis

Avant de commencer, il est préférable d'avoir déjà terminé la quête suivante:

```shell
Active Directory Domain Services - Les OU30minsVoir la quête - Active Directory Domain Services - Les OU
```

---

![image](https://storage.googleapis.com/quest_editor_uploads/a4c8QtXNkHUqUG7azaKXe3r12CKI6khu.jpg)

## 🎯 Objectifs:

✅ Comprendre le principe d'un Domaine  
✅ Comprendre le principe d'une Forêt

## Sommaire

- [👉 La structure d'un Active Directory](https://odyssey.wildcodeschool.com/quests/1950/pages/18641#-la-structure-dun-active-directory)
- [👉 Représentation d'une Forêt AD](https://odyssey.wildcodeschool.com/quests/1950/pages/18641#-repr%C3%A9sentation-dune-for%C3%AAt-ad)
- [☝️ Résumé](https://odyssey.wildcodeschool.com/quests/1950/pages/18641#%EF%B8%8F-r%C3%A9sum%C3%A9)
- [💪 Challenge](https://odyssey.wildcodeschool.com/quests/1950/pages/18641#-challenge)
- [🧐 Critères d'acceptation](https://odyssey.wildcodeschool.com/quests/1950/pages/18641#-crit%C3%A8res-dacceptation)

## 👉 La structure d'un Active Directory

AD offre trois niveaux principaux: les domaines, les arborescences et les forêts.

Un domaine est un groupe dans lequel sont reliés différents utilisateurs, ordinateurs et objets AD, comme les objets AD du siège social de ton entreprise.  
Plusieurs domaines peuvent être combinés dans une arborescence, et un regroupement d’arborescences constitue une forêt.

N’oublie pas qu’un domaine représente un périmètre de gestion. Les objets pour un domaine donné sont stockés dans une base de données unique et peuvent être gérés ensemble.

Une structure d'un Active Directory est donc composée de:

1. La forêt: structure hiérarchique d'un ou plusieurs domaines indépendants (ensemble de tous les sous domaines Active Directory).
2. L''arborescence: domaine de toutes les ramifications. Par exemple, dans l'arbre `wilders.lan`, `data.wilders.lan` et `dev.wilders.lan` sont des sous-domaines de `wilders.lan`
3. Le domaine: constitue les feuilles de l'arborescence. `dev.wilders.lan` peut-être un domaine au même titre que `wilders.lan`

---

Une forêt est un périmètre de sécurité. Les objets de différentes forêts ne peuvent pas interagir les uns avec les autres, à moins que les administrateurs de chaque forêt ne créent une relation de confiance entre elles.

Voici un exemple:  
![image.png](https://storage.googleapis.com/quest_editor_uploads/kUEHnT5KWxM2KtvItgvwPMi35bTbRXXz.png)

Dans le schéma ci-desuss on retrouve `wilders.lan` qui va contenir les formations que propose la Wildcodeschool, puis on à le domaine `wildcodeschool.lan` qui va contenir tout les campus de la Wildcodeschool.

Cette structure complète contient donc:

1. Deux domaines `wilders.lan` et `wildcodeschool.lan`
2. Chacun des domaines contient une arborescence
3. L'ensemble des domaines, sous-domaines et arborescences forme la forêt

---

## ☝️ Résumé

La structure Active Directory est composée d'objets hiérarchisés contenus dans des Unités Organisationnelles (UO). Il y a trois degrés composant l'arborescence:

1. La forêt regroupe de façon hiérarchisée un ou plusieurs domaines indépendants, et donc l'ensemble des sous domaines compris dans l'Active Directory.
2. L'arbre ou arborescence contient tous les sous-domaines dans des ramifications au sein du domaine principal.
3. Le domaine, la plus petite unité, représente les feuilles de l'arbre. il peut s'agir de fichiers, par exemple.

---

## 💪 Challenge

Réponds au quizz.

## 🧐 Critères d'acceptation

Tu dois avoir 100% de bonnes réponses aux questions du quiz.

lundi 29 décembre 2025

5 questions

lundi 29 décembre 2025

5 questions

lundi 29 décembre 2025

5 questions

lundi 29 décembre 2025

5 questions