---
title: "Découverte du déploiement Windows - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2335/pages/11635"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Windows

## Découverte du déploiement Windows

Facile

30mins

Quiz

Windows

## Découverte du déploiement Windows

Avant de commencer, la quête suivante t'aidera à aborder cette quête.

```
Suivi de parc - les enjeux1hVoir la quête - Suivi de parc - les enjeux
```

## Introduction

Qu'est-ce qu'un déploiement informatique en entreprise?  
Également appelé **déploiement par étapes** (ou ***phased rollout*** en anglais), il consiste à faire migrer graduellement les éléments matériels ou logiciels lors de l'implémentation et de la mise en œuvre progressive d'un nouveau système.  
Donc après avoir parlé du suivi de parc précédemment, nous allons voir ici pourquoi et comment ce parc informatique va évoluer.  
Au niveau des OS, le déploiement en masse est une pratique assez courante dès lors que le parc informatique est assez important et/ou dès que l'on souhaite avoir une uniformisation, tant au niveau des méthodes que des OS.

![des objets tombent dans une boite](https://storage.googleapis.com/quest_editor_uploads/yxGbdkXbAbdjKJgOI1Kf8fixW3LACEHX.jpg)

## 🤓 Objectifs:

✅ Savoir ce qu'est un déploiement  
✅ Comprendre les enjeux d'un déploiement d'entreprise  
✅ Connaître les méthodes de masterisation  
✅ Connaître les technologies utilisables

## Sommaire

- [👉 Pourquoi faire des mise-à-jour?](https://odyssey.wildcodeschool.com/quests/2335/pages/11635#-pourquoi-faire-des-mise-%C3%A0-jour-)
- [👉 Installation de systèmes d'exploitation au niveau personnel](https://odyssey.wildcodeschool.com/quests/2335/pages/11635#-installation-de-syst%C3%A8mes-dexploitation-au-niveau-personnel)
- [👉 Déploiement en entreprise](https://odyssey.wildcodeschool.com/quests/2335/pages/11635#-d%C3%A9ploiement-en-entreprise)
	- [Avant d'aller plus loin, un peu de vocabulaire](https://odyssey.wildcodeschool.com/quests/2335/pages/11635#avant-daller-plus-loin-un-peu-de-vocabulaire)
		- [De la méthodologie](https://odyssey.wildcodeschool.com/quests/2335/pages/11635#de-la-m%C3%A9thodologie)
		- [Quelle technologie utiliser?](https://odyssey.wildcodeschool.com/quests/2335/pages/11635#quelle-technologie-utiliser-)
- [☝️ Résumé](https://odyssey.wildcodeschool.com/quests/2335/pages/11635#%EF%B8%8F-r%C3%A9sum%C3%A9)
- [💪Challenge](https://odyssey.wildcodeschool.com/quests/2335/pages/11635#challenge)
- [🧐 Critères d'acceptation](https://odyssey.wildcodeschool.com/quests/2335/pages/11635#-crit%C3%A8res-dacceptation)

## 👉 Pourquoi faire des mise-à-jour?

Les logiciels proposent régulièrement des mises-à-jour.  
Elles:

- Permettent de résoudre des bugs
- De renforcer la sécurité
- D'améliorer les produits

Parmi les types de mises-à-jour, les **importantes** ou **critiques** corrigent des failles de sécurité.  
Les **mises à jour de version** apportent en général de nouvelles fonctionnalités et corrigent également des failles de sécurité. Ce type de mise à jour peut être payant.

Concernant plus spécifiquement les mises-à-jour de système d'exploitation, que peut-on en dire?  
La vidéo ci-dessous essaie de répondre à la question en posant le postulat suivant: que se passerait-il si on ne faisait pas les mises-à-jour d'OS?

## 👉 Installation de systèmes d'exploitation au niveau personnel

En plus de ces différentes mises-à-jour, il existe des mises-à-jour majeures. Ces dernières sont une évolution complète, voir dans certains cas une refonte du logiciel. Cela peut se faire juste au niveau de l'interface, mais également en profondeur avec une toute nouvel gestion de la sécurité par exemple.  
Ainsi les 2 dernières versions de Windows, 10 et 11, proposent 2 fois par ans des mises-à-jour majeure.  
Néanmoins, dans le cas d'un nouveau PC, il serait fastidieux et long de faire toutes les mise-à-jour depuis une vieille version de Windows. Dans ce cas on va installer la version choisie (qui sera la dernière ou non).  
Tu as vu qu'avec une **gestion de parc** on pouvait suivre ces évolution du parc.  
Concrètement comment cela se passe?

## 👉 Déploiement en entreprise

Afin de pouvoir suivre et gérer les déploiements, les différentes mise-à-jour et évolution sont souvent interdites et désactivées pour les utilisateurs.

```
La question de la responsabilité
Le blocage de certaines actions sur les postes de travail d'une entreprise pourrait apparaître comme un abus de pouvoir, il s'agit plutôt une question de responsabilité.
En effet, dans la plupart des structures, l'équipe IT est responsable du bon fonctionnement du parc.

Ils doivent donc intervenir et remettre en état en cas de panne ou de dysfonctionnement.

Pour pouvoir mener à bien cette mission, il est indispensable que l'état général des postes de travail (leur configuration matérielle, les versions de logiciels installés et leur configuration, etc.) soit conforme à ce qui a été prévu et tester.
Par ailleurs, ce contrôle est aussi nécessaire pour assurer une évolution et un suivi du parc informatique.
```

En entreprise, un déploiement consiste en une évolution complètement gérée et progressive d'un matériel, d'un OS, ou d'un logiciel.  
Dans le cas d'un OS, il existe plusieurs scénarios:

1. Mettre à niveau Windows vers la dernière version  
	C'est identique à ce que l'on peut faire chez soi.
2. Rafraîchir un ordinateur existant avec une nouvelle version de Windows  
	Cela consiste à **réinstaller** une version d'OS sur une machine existante (utilisation de **master**)
3. Installer une nouvelle version de Windows sur un nouvel ordinateur  
	Comme l'exemple précédant, mais avec une nouvelle machine.
4. Remplacer un ordinateur existant et transférer les paramètres  
	Dans ce cas, on va transférer un OS d'une machine ancienne vers une plus récente.
```
Pourquoi ne pas toujours déployer la dernière version ?

En entreprise, à la différence de chez soi, on doit s'assurer que l'ensemble de l'ecosystème informatique continue de fonctionner correctement après un déploiement. Cela veut dire que les systèmes, les machines, les interfaces, etc. doivent fonctionner correctement de la même manière au minimum après un déploiement.

En règle générale, on ne déploie pas la toute dernière version d'un OS dès sa disponibilité. Cela permet d'avoir les premiers correctifs qui seront ajouté plus tard au déploiement.
```

## Avant d'aller plus loin, un peu de vocabulaire

**Master**:  
Image d'un système d'exploitation pré-configuré sur un ordinateur. Ce type d'image existe sous plusieurs formats de fichiers (**Windows Imaging Format** et **ISO**).  
Le fichier correspondant peut être léger car ne contenant que l'OS (***Thin image***) ou beaucoup plus lourd avec l'ensemble des logiciels (***Thick image***).

**Masteriser (ou remasteriser)**:  
Déployer un master, exécuter le process d'installation d'un OS sur plusieurs machines.

**Descendre (ou redescendre) un master**:  
Action de déploiement d'un master.

**Clone**:  
Image exact d'un OS, n'ayant subi aucun changement, hormis la suppression de l'identificateur unique.

## De la méthodologie

Pour le déploiement d'un OS complet, il existe 2 méthodes:

1. La préparation d'un master tout-en-un:  
	On va préparer une machine type qui servira de **matrice** et sur laquelle on trouvera:
- L'OS choisi
- Les pilotes
- Les logiciels
- Les dernières mise-à-jour

Avantages:

- Dès la fin du déploiement, la machine est prête à être utilisée
- Facilité à mettre en place
- L'image peut être placée sur un support amovible et indépendant

Inconvenants:

- Plus on avancera dans le temps et plus le master descendu ne sera plus à jour
- Obligation de recréer régulièrement un master à jour
- Taille d'image lourde
1. Préparation d'un master en séparant les socles suivants par gestion de **packages**:
- L'OS en lui-même
- Les pilotes
- Les logiciels

Avantages:

- Dès la fin du déploiement, la machine est prête à être utilisée
- La machine sera toujours à jour (***up-to-date***)
- Image légère

Inconvenants:

- Complexité de mise en place
- Obligation de mettre-à-jour les différentes entités (OS, pilotes, logiciels) régulièrement par le biais des packages.
- L'image ne peut pas être mise sur un support amovible et on doit avoir un système de gestion d'images de déploiement.
```
Laquelle de ces 2 méthodes choisir ?

En fait, ces 2 méthodes coexistent. On va ainsi pouvoir créer un master complet tous les ans, ou tous les 2 ans, qui contiendra à l'instant t tous les éléments. Pour le suivi réguliers, on mettra en place un 2ème master qui fonctionnera par packages, et qui permettra un meilleur suivi des mise-à-jour et des évolutions.

Une méthode best practice consiste à faire la même chose mais uniquement avec le modèle par packages.
```

## Quelle technologie utiliser?

WDS (**Windows Deployment Services**) et SCCM (**System Center Configuration Manager**) sont les 2 technologies les plus utilisées. Ce sont des technologies propriétaires soumises à licence.  
Il existe également MDT (**Microsoft Deployment Toolkit**) qui est une solution gratuite.  
Les fichiers images sont souvent stockés sur le réseau, et un serveur de déploiement va chercher ces images pour les installer sur les machines clientes.

---

## ☝️ Résumé

Un déploiement est géré par le service informatique d'une entreprise pour faire évoluer correctement un parc informatique.  
On peut installer un OS de différentes manières, complètement ou partiellement.  
On peut utiliser des packages pour rendre un master plus durable dans le temps.  
WDS, SCCM, et MDT sont des technologies permettant de gérer un déploiement.

---

## 💪Challenge

Répondre aux questions du quiz pour valider cette quête.

## 🧐 Critères d'acceptation

Répondre correctement à l'ensemble des questions du quiz.

lundi 02 février 2026

4 questions

lundi 02 février 2026

4 questions