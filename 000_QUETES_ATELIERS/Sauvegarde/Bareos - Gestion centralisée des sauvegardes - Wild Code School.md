---
title: "Bareos - Gestion centralisée des sauvegardes - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2359/pages/11673"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Sauvegarde

## Bareos - Gestion centralisée des sauvegardes

Bareos est un logiciel de gestion centralisée de sauvegardes

Moyen

3h

Quiz

Sauvegarde

## Bareos - Gestion centralisée des sauvegardes

## Introduction

Lorsque le nombre de serveurs augmente, la gestion manuelle des sauvegardes peut vite devenir délicate et complexe.

Des outils existent qui permettent d'automatiser cette gestion et d'offrir une vision centralisée de l'état des sauvegardes.

**Bareos** est l'un de ces outils.

![Logo de Bareos](https://openexpoeurope.com/wp-content/uploads/2019/04/bareos-logo-full.png)

## 🤓 Objectifs:

✅ Comprendre les concepts fondamentaux des sauvegardes  
✅ Analyser les enjeux de leur gestion quotidienne  
✅ Expérimenter **bareos**

## Sommaire

- [👉 Maintient de l'activité et tolérance aux pannes](https://odyssey.wildcodeschool.com/quests/2359/pages/11673#-maintient-de-lactivit%C3%A9-et-tol%C3%A9rance-aux-pannes)
	- [Le plan de reprise/continuité d'activité](https://odyssey.wildcodeschool.com/quests/2359/pages/11673#le-plan-de-reprisecontinuit%C3%A9-dactivit%C3%A9)
		- [Plan de reprise d'activité](https://odyssey.wildcodeschool.com/quests/2359/pages/11673#plan-de-reprise-dactivit%C3%A9)
				- [Plan de continuité d'activité](https://odyssey.wildcodeschool.com/quests/2359/pages/11673#plan-de-continuit%C3%A9-dactivit%C3%A9)
- [👉 Les sauvegardes](https://odyssey.wildcodeschool.com/quests/2359/pages/11673#-les-sauvegardes)
	- [Considérations générales sur les sauvegardes](https://odyssey.wildcodeschool.com/quests/2359/pages/11673#consid%C3%A9rations-g%C3%A9n%C3%A9rales-sur-les-sauvegardes)
		- [Les différents types de sauvegardes](https://odyssey.wildcodeschool.com/quests/2359/pages/11673#les-diff%C3%A9rents-types-de-sauvegardes)
		- [La politique de sauvegarde](https://odyssey.wildcodeschool.com/quests/2359/pages/11673#la-politique-de-sauvegarde)
		- [Archivage](https://odyssey.wildcodeschool.com/quests/2359/pages/11673#archivage)
- [👉 Bareos](https://odyssey.wildcodeschool.com/quests/2359/pages/11673#-bareos)
	- [Les composants](https://odyssey.wildcodeschool.com/quests/2359/pages/11673#les-composants)
		- [Les concepts clés](https://odyssey.wildcodeschool.com/quests/2359/pages/11673#les-concepts-cl%C3%A9s)
		- [🔬 Installation, configuration et test de bareos](https://odyssey.wildcodeschool.com/quests/2359/pages/11673#-installation-configuration-et-test-de-bareos)
- [☝️ Résumé](https://odyssey.wildcodeschool.com/quests/2359/pages/11673#%EF%B8%8F-r%C3%A9sum%C3%A9)
- [💪 Challenge](https://odyssey.wildcodeschool.com/quests/2359/pages/11673#-challenge)
- [🧐 Critères d'acceptation](https://odyssey.wildcodeschool.com/quests/2359/pages/11673#-crit%C3%A8res-dacceptation)

## 👉 Maintient de l'activité et tolérance aux pannes

Un [système d'information](https://fr.wikipedia.org/wiki/Syst%C3%A8me_d%27information) (SI) et les moyens informatiques qui le composent permettent ou facilitent une activité.

Des exemples:

- Un hôpital peut disposer d'un système informatique pour la gestion des rendez-vous et l'occupation des salles ainsi que pour le suivi des dossiers des patients.
- Un commerçant dépend de son site e-commerce pour la gestion de son activité de vente en ligne.
- etc.

Les incidents et pannes qui affectent le système d'information peuvent donc avoir un impact plus ou moins grave sur l'activité de la structure qui l'emploi.

## Le plan de reprise/continuité d'activité

Compte-tenu de l'importance que peut avoir un SI sur l'activité et parfois même sur la survie d'une structure, la question des moyens à mettre en œuvre pour pouvoir se remettre des pannes se pose.

Cette réflexion essentielle vise à:

1. établir la criticité de chacun des éléments du SI
2. évaluer les risques qui pèsent sur ces éléments
3. décider des moyens à déployer pour réduire ces risques.

Selon la nature des objectifs fixés, on parle de plan de reprise -ou de continuité- d'activité.

### Plan de reprise d'activité

Un [plan de reprise d'activité](https://fr.wikipedia.org/wiki/Plan_de_reprise_d%27activit%C3%A9) (ou **PRA**) vise à permettre de remettre le SI en fonctionnement après une panne, aussi rapidement que le nécessite l'activité et que le permettent les moyens dont on dispose.

### Plan de continuité d'activité

Un [plan de continuité d'activité](https://fr.wikipedia.org/wiki/Plan_de_continuit%C3%A9) (ou **PCA**) consiste quand à lui de maintenir l'activité malgré les pannes.

## 👉 Les sauvegardes

Les sauvegardes constituent évidemment un élément fondamental des PRA/PCA.

Leur objectif principal est de permettre de remettre en état un service (et donc en général le ou les serveurs qui l’héberge) après une perte des données, quel qu’en soit la cause.

Elles permettent donc de répondre aux risques de:

- Pannes matérielles sur les disques
- Corruptions des systèmes de fichiers
- Maladresse des utilisateurs et surtout des administrateurs
- [Rançongiciels](https://fr.wikipedia.org/wiki/Ran%C3%A7ongiciel) (ransomware) et attaques par destruction des données
- etc.

Une sauvegarde consiste en substance à recopier un ensemble de données.

On appelle restauration l'opération qui consiste à récupérer depuis les sauvegardes tout ou partie des données pour les remettre sur les systèmes en production.

## Considérations générales sur les sauvegardes

Recopier des données consomme évidemment de l'espace de stockage. Cette consommation peut être réduite en partie en utilisant des techniques de [compression](https://fr.wikipedia.org/wiki/Compression_de_donn%C3%A9es) mais pour simplifier, on peut considérer, en première intention, qu'il faut multiplier le besoin en espace de stockage par le nombre de copies que l'on souhaite conserver.

Autre point important: recopier des données prend du temps. Et même selon le volume de données à sauvegarder beaucoup de temps.  
En général, sauf cas particulier d'applications permettant de la sauvegarde en ligne, on considère que la sauvegarde doit avoir lieu alors que le service est éteint (ou en tout cas en lecture seule), pour garantir la cohérence des données sauvegardées.

```
En effet, si pendant le temps de la sauvegarde, les données sont aussi modifiées par l'application, il y a un risque qu'une partie des données sauvegardées l'ai été avant la modification et une autre partie après. Il y a fort à parier dans ce cas que relancer l'application après restauration des données sauvegardées introduise des incohérences dans l'application et donc des bugs.
```

Ce temps d'indisponibilité de l'application nécessaire à la réalisation des sauvegardes est appelée **fenêtre de sauvegarde** et est d'autant plus longue que le volume à sauvegarder est important.

Par ailleurs, cette copie de l'ensemble des données à un impact fort sur les performances de l'application. En effet, elle sollicite fortement les disques du serveurs, mais aussi le réseau si les sauvegardes ne sont pas exécutées localement (ce qui est le cas en général).

```
Astuce n°1Une astuce pour réduire le temps d'indisponibilité d'un service lié à la sauvegarde, on peut utiliser des snapshots.
L'idée générale est alors :
1 - Coupure de l'application

2 - Création de l'instantané

3 - Redémarrage de l'application
Cet ensemble d'opérations peut être réalisé très rapidement, il ne reste alors plus qu'à faire une copie de l'instantané avec une faible priorité pour ne pas trop impacter les performances du serveur et disposer au final d'une copie indépendante de l'original.
```
```
Astuce n°2Pour réduite l'impact sur le réseau des sauvegardes, il est courant de mettre en place un réseau indépendant dédié aux sauvegardes.
```

Une sauvegarde représente donc un état, créé à un instant T, d'une application.  
Dès l'application relancée, l'ensemble des données qu'elle manipule, et donc son état, va commencer à diverger de l'état de la sauvegarde.

Une restauration des données d'une application est donc toujours une forme de retour dans le temps.

![Image d'une horloge en spirale illustrant un voyage dans le temps](https://64.media.tumblr.com/89ed8d3679a5c93986f799135ad6a8f9/tumblr_o3xgp8pKNo1s8gtxto1_500.gif)

Pour réduire ce retour dans le temps, il faut refaire les sauvegardes régulièrement. Plus fréquemment les sauvegardes sont faites, plus le temps entre la dernière sauvegarde et la panne se raccourci. Mais comme les sauvegardes prennent du temps et qu'il est peu pertinent d'en faire plusieurs en même temps...

Autre point à noter: Les pannes ne sont pas toujours détectées immédiatement.  
Par exemple, une corruption d'un disque peut entraîner la perte ou la modification de quelques fichiers seulement. Cette corruption peut ne pas empêcher une utilisation normale de l'application et donc n'être détectée que bien plus tard. Les sauvegardes effectuées après la corruption sont incomplètes (si des fichiers sont manquants) ou corrompues (si des fichiers sont anormalement modifiés) et peuvent avoir remplacé les sauvegardes précédentes. Les sauvegardes disponibles sont alors inutilisables pour récupérer de cette corruption.

Aussi, il est courant de conserver plusieurs sauvegardes pour pouvoir revenir à différents moment dans le temps.

## Les différents types de sauvegardes

Afin de consommer moins d'espace et de raccourcir le temps nécessaire aux sauvegardes, il existe 2 stratégies basées sur le même constat: En général, seule une petite partie des données d'une application est modifiée dans un temps court.

En conséquence, pour augmenter la fréquence des sauvegardes sans trop augmenter leur consommation en espace de stockage et le temps nécessaire à les faire, pourquoi ne pas sauvegarder seulement les modifications?

C'est l'idée des **sauvegardes incrémentales** et **différentielles**.

La différence entre les deux c'est que les sauvegardes incrémentales recopient uniquement les différences depuis la dernière sauvegarde, que cette sauvegarde soit complète ou incrémentale.  
Alors que les sauvegardes différentielles recopient les différences avec la dernière sauvegarde complète uniquement.

Les sauvegardes incrémentales consomme en général moins de place et sont plus rapides, mais sont plus complexes à restaurer puisqu'il peut être nécessaire de manipuler plusieurs incrémentales + une complète pour faire une restauration.

Les sauvegardes différentielles sont un compromis puisque la restauration ne nécessite qu'une seule différentielle et une complète au plus.

La vidéo suivante illustre ces notions.

## La politique de sauvegarde

La politique de sauvegarde consiste à étudier les besoins en sauvegardes et définir ce qui doit être mis en place.

Elle consiste tout d'abord à lister l'ensemble des informations qu'il faut sauvegarder en les regroupant par applications selon leur criticité.

Pour chacun de ces groupes, elle définit la fréquence, la planification et la destination (ou les destinations) des sauvegardes.

```
Sauvegarde sur WikipediA
Ressource permettant de reprendre et approfondir la notion de sauvegardehttps://fr.wikipedia.org/wiki/Sauvegarde_(informatique)
```

## Archivage

L'archivage est une notion connexe de la sauvegarde.

Si la sauvegarde consiste principalement à pouvoir tolérer des pannes, l'archivage consiste a pouvoir conserver sur une longue durée des données qu'il n'est pas forcément nécessaire de garder en ligne.

```
Archivage sur WikipediA
Pour en apprendre plus sur l’archivage et ses enjeux.https://fr.wikipedia.org/wiki/Archivage_%C3%A9lectronique
```

---

## 👉 Bareos

[Bareos](https://www.bareos.com/) est un outil de sauvegarde centralisé. Son nom signifie *Backup Archiving Recovery Open Sourced*.  
C'est un [fork](https://fr.wikipedia.org/wiki/Fork_\(d%C3%A9veloppement_logiciel\)) de [Bacula](https://www.bacula.org/) avec qui il partage naturellement de nombreux points communs.

```
Documentation officielle de Bareos
Cette documentation regroupe l'ensemble des informations nécessaires à comprendre, installer, configurer et utiliser bareos.https://www.bareos.com/learn/documentation/
```

## Les composants

**Bareos** est constitué de plusieurs composants:

- **Bareos Director**  
	C'est le chef d'orchestre. Il est responsable de la planification, du contrôle et du lancement des tâches de sauvegardes. Il contrôle l'ensemble des autres composants. Il est installé sur le serveur en charge de la gestion des sauvegardes.
- **Bareos Console**  
	La console est un programme CLI qui permet de communiquer avec le **Bareos Director** et donc de lancer des sauvegardes ou des restaurations, manuelles ou planifiées, ainsi que de vérifier l'état des tâches passées, en cours ou planifiées.
- **Bareos File Daemon**  
	Ce composant est installé sur chaque machine devant être sauvegardée.  
	Il est en charge de collecter les informations à sauvegarder et de les envoyer au **Bareos Storage Daemon**
- **Bareos Storage Daemon**  
	Bareos permet d'effectuer des sauvegardes sur différents types de supports (bandes magnétiques, disques, stockage distant...). L'écriture sur ces supports est effectué par un **Storage Daemon**.  
	Il peut donc y en avoir plusieurs, si on souhaite par exemple que les sauvegardes soient hébergées sur les disques de plusieurs machines.  
	Une tâche de sauvegarde est donc lancée par le **Director** qui met en relation un **File Daemon** présent sur la machine à sauvegarder avec un **Storage Daemon** présent lui sur la machine qui enregistrent les informations de la sauvegarde sur un support de stockage.
- **Catalogue**  
	L'état de l'ensemble des tâches de sauvegardes et de leur résultat est enregistré dans une base de données qu'on appelle le catalogue. Cette base est hébergé par un programme tiers tel que **postgresql**, **mysql**, etc...  
	La consultation de ce catalogue permet ainsi de savoir quels sont les fichiers sauvegardés, à quelles dates, etc.

Un composant complémentaire, le **Bareos Webui** peut être ajouté à une installation. Il fournit une interface graphique web alternative à la console classique.

## Les concepts clés

**Bareos** s'appuie sur plusieurs notions qu'il peut être utile de définir rapidement pour mieux appréhender son utilisation.

**Bareos** utilise ainsi le terme **Job** pour définir une tâche de sauvegarde.

Un **Job** est associé à:

- Un **FileSet** qui est un ensemble de chemins de fichiers que le **Job** doit sauvegarder
- Un **Client**: la machine sur laquelle se trouve ces fichiers (et donc sur laquelle doit être installé un **File Daemon**.
- Un **Schedule** qui est une planification pour automatiser le lancement du **Job**
- Un **Pool**: l'ensemble des supports de stockage présents sur un **Storage Daemon** à utiliser pour le **Job**

## 🔬 Installation, configuration et test de bareos

Maintenant à toi de jouer.

Reprend la [documentation de bareos](https://www.bareos.com/learn/documentation/) depuis le début et parcours la attentivement.

En la suivant, procède pas à pas à:

- L'installation d'un serveur **bareos**  
	Pour cette mise en pratique, utlises un unique serveur GNU/Linux (qui peut évidemment être une VM) sur lequel tu dois donc installer **postgresql** (pour le catalogue) ainsi que l'ensemble des composants **bareos** qui s'installe par le méta-paquet **bareos**.
- L'installation sur le même serveur de **Bareos Webui**
- Procède ensuite à toute la partie [tutorial](https://docs.bareos.org/IntroductionAndTutorial/Tutorial.html#tutorial) qui t'amène à
	- Lancer et découvrir la console.
		- Lancer un premier **job** et faire ta première sauvegarde.
		- Faire une restauration des données sauvegardées.
		- Ajouter un client. Ce client est une deuxième machine (ou VM) sur laquelle tu installes uniquement **bareos-fd**.
		- Configurer le serveur et le client pour que la communication soit possible.
		- Lancer une sauvegarde sur le client.

---

## ☝️ Résumé

Les sauvegardes sont un éléments essentiel à la mise en place d'un plan de reprise ou de continuité d'activité.  
La définition d'une politique de sauvegarde est nécessairement un compromis entre les contraintes de production et la réalisation des sauvegardes qui peut avoir un impact fort sur la production.

Différentes techniques existent pour minimiser l'impact et la consommation de ressources des sauvegardes, telles que les sauvegardes incrémentales et différentielles.

La gestion d'une politique de sauvegarde complète sur un grand nombre de serveurs est une tâche complexe qui nécessite en général un outillage spécifique.

**Bareos** est un outil permettant d'avoir une gestion centralisée de l'ensemble des sauvegardes de son SI.

---

## 💪 Challenge

Répondre au quiz

## 🧐 Critères d'acceptation

5 réponses correctes sont fournies pour les 5 questions