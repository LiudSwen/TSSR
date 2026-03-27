---
title: "L'Observateur d'Événements Windows - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/3129/pages/11996"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Windows

## L'Observateur d'Événements Windows

Cette quête vous guidera à travers les aspects essentiels de la gestion de vos journaux d'évènements.

Moyen

3 pairs

Windows

## L'Observateur d'Événements Windows

## Introduction

Dans cette quête, tu vas plonger dans l'Observateur d'événements de Windows **(Event Viewer)**, un outil indispensable pour tout administrateur Windows.

Event Viewer enregistre chaque action et chaque incident de ton système Windows, te permettant de suivre les événements importants. Prépare toi à déchiffrer les indices laissés par chaque action de ton système, car aujourd'hui, tu apprends à lire les histoires que ton ordinateur raconte à travers ses logs.

![Event Viewer Interface](https://sematext.com/wp-content/uploads/2024/07/evnet-log.webp)

## Objectif 🎯

L'objectif de cette quête est de te donner les bases de l'utilisation de l'Observateur d'événements. À la fin, tu seras capable de:

- ✅ Comprendre l'importance des journaux d'événements dans Windows
- ✅ Te familiariser avec les différents types de logs disponibles dans Event Viewer
- ✅ Apprendre à naviguer, lire et interpréter les logs de base

## Sommaire

- [❓ Qu'est-ce que l'Observateur d'événements de Windows?](https://odyssey.wildcodeschool.com/quests/3129/pages/11996#-quest-ce-que-lobservateur-d%C3%A9v%C3%A9nements-de-windows)
	- [🔍 Aperçu](https://odyssey.wildcodeschool.com/quests/3129/pages/11996#-aper%C3%A7u)
		- [🔬 Exercice](https://odyssey.wildcodeschool.com/quests/3129/pages/11996#-exercice)
- [🧐 **Comprendre les Niveaux d'Événements:**](https://odyssey.wildcodeschool.com/quests/3129/pages/11996#comprendre-les-niveaux-d%C3%A9v%C3%A9nements-)
	- [🔬 Exercice](https://odyssey.wildcodeschool.com/quests/3129/pages/11996#-exercice-1)
- [🛠️ **Utilisation des ID d'Événements:**](https://odyssey.wildcodeschool.com/quests/3129/pages/11996#%EF%B8%8F-utilisation-des-id-d%C3%A9v%C3%A9nements-)
	- [🔬 Exercice](https://odyssey.wildcodeschool.com/quests/3129/pages/11996#-exercice-2)
- [🔧 **Créer des Vues Personnalisées dans Event Viewer:**](https://odyssey.wildcodeschool.com/quests/3129/pages/11996#-cr%C3%A9er-des-vues-personnalis%C3%A9es-dans-event-viewer-)
- [💪 Challenge](https://odyssey.wildcodeschool.com/quests/3129/pages/11996#-challenge)
- [🧐 Critères d'acceptation](https://odyssey.wildcodeschool.com/quests/3129/pages/11996#-crit%C3%A8res-dacceptation)

## ❓ Qu'est-ce que l'Observateur d'événements de Windows?

L'Observateur d'événements est un outil intégré à Windows qui affiche des informations détaillées sur les événements importants de ton serveur Windows. Ces événements peuvent être liés à des applications, à la sécurité, au système, ou à des services spécifiques.

## 🔍 Aperçu

![](https://storage.googleapis.com/quest_editor_uploads/Pqhi0edrbjgH5W9MFqgoomdfElfGbvsS.png)

- Dans le panneau de gauche (repère 1) on trouve les journaux de Windows répartis en plusieurs catégories (applications, sécurité, installations, système) ainsi que les journaux d’applications et services installés ou tournant sur le système.
- Dans la partie centrale (repère 2) se situent la liste des évènements du journal sélectionné dans le volet de gauche.
- Dans le panneau de droite (repère 3) on trouve un certain nombre d’actions liées au journal sélectionné dans le panneau de gauche.
- Dans la partie inférieure (repère 4) sont affichées les détails de l’évènement sélectionné dans la zone 2.

**Principaux Journaux d'Événements:**

| **Type de journal** | **Description** |
| --- | --- |
| **Application** | Contient les événements générés par les applications installées sur le système. |
| **Sécurité** | Enregistre les événements liés à la sécurité, tels que les tentatives de connexion. |
| **Système** | Stocke les événements générés par les composants système de Windows. |
| **Applications et Services** | Enregistre les événements pour des applications spécifiques ou des composants système individuels en dehors des journaux standards Windows. |

**Pourquoi Event Viewer est-il important?**

- **Dépannage**: Aide à identifier la cause des problèmes système, comme des crashs ou des défaillances.
- **Sécurité**: Permet de surveiller les tentatives de connexion et d'autres activités sensibles en temps réel.
- **Maintenance**: Aide à planifier la maintenance en identifiant les composants défaillants ou les tendances négatives.

## 🔬 Exercice

- **Tâche**:
	- Lance Event Viewer en utilisant `Windows + R`, tape `eventvwr`, et appuie sur `Entrée`.
		- Explore l'interface: quels sont les principaux types de journaux que tu vois?

---

## 🧐Comprendre les Niveaux d'Événements:

Chaque événement journalisé dans Event Viewer a un niveau de gravité. Voici les principaux niveaux:

| **Niveau** | **Description** |
| --- | --- |
| **Critique** | Événements très graves nécessitant une attention immédiate (ex. crash système). |
| **Erreur** | Indique un problème qui a empêché une opération de se compléter (ex. échec d'une application). |
| **Avertissement** | Événement qui n'est pas nécessairement significatif mais peut indiquer des problèmes futurs. |
| **Information** | Événements qui décrivent le bon déroulement d'une opération (ex. démarrage d'un service). |

## 🔬 Exercice

- **Tâche**:
	- Crée un filtre dans le journal **Sécurité** pour montrer uniquement les événements de connexion des dernières 24 heures.
		- Analyse un événement d'information du journal **Système**: que te dit l'ID de l'événement?

---

## 🛠️ Utilisation des ID d'Événements:

Chaque événement a un **ID unique** qui peut être utilisé pour rechercher des informations spécifiques sur l'erreur ou l'événement en ligne. Ces IDs sont très utiles pour le dépannage, car ils peuvent souvent te mener directement à une solution.

Comment utiliser les ID d'événements pour le dépannage:

1. **Identifier l'événement**: Trouve un événement critique ou une erreur dans le journal concerné (par exemple, Système).
2. **Rechercher l'ID de l'événement**: Note l'ID associé à cet événement.
3. **Effectuer une recherche en ligne**: Utilise cet ID pour trouver des informations supplémentaires, telles que des solutions ou des discussions sur des forums techniques.

## 🔬 Exercice

- **Tâche**:
	- Trouve un événement critique ou d'erreur récent dans le journal **Système**.
		- Utilise l'ID de l'événement pour rechercher une solution ou des informations supplémentaires en ligne.

---

## 🔧 Créer des Vues Personnalisées dans Event Viewer:

Une des fonctionnalités les plus puissantes d'Event Viewer est la possibilité de créer des **vues personnalisées** pour cibler les événements spécifiques qui t'intéressent. Cela te permet de filtrer les logs et de te concentrer uniquement sur les informations essentielles pour ton diagnostic ou ta surveillance.

Pourquoi créer des vues personnalisées?

- **Gain de temps**: En filtrant uniquement les événements qui correspondent à tes besoins spécifiques.
- **Suivi des incidents**: Facilite le suivi des événements récurrents ou critiques sans avoir à parcourir l'intégralité des journaux.
- **Alertes spécifiques**: Te permet de te concentrer sur les événements qui méritent vraiment ton attention, comme les erreurs critiques ou les avertissements.

Comment créer une vue personnalisée?

1. **Accéder à la fonctionnalité:**
	- Dans Event Viewer, fais un clic droit sur "Vues personnalisées" et sélectionne "Créer une vue personnalisée...".
2. **Définir les critères de la vue:**
	- Choisis une plage de dates ou des niveaux d'événements spécifiques (Critique, Erreur, Avertissement, etc.).
		- Sélectionne les journaux pertinents, comme **Journaux Windows** ou **Applications et Services Logs**.
		- Si nécessaire, spécifie des mots-clés ou des ID d'événements particuliers.
3. **Nommer et sauvegarder ta vue:**
	- Donne un nom descriptif à ta vue personnalisée et enregistre-la dans le dossier "Vues personnalisées" pour un accès rapide.

---

```shell
📚 Ressources complémentaires
Documentation officielle de l'Event Viewer
Événements à surveiller
```

## 💪 Challenge

Crée une machine virtuelle Windows Server, installe le rôle DNS, puis crée une vue personnalisée dans l'Event Viewer pour surveiller spécifiquement les événements liés au service DNS et son état.

**Configuration de ta vue personnalisée:**

1. Niveaux à surveiller
- Critique (1)
- Erreur (2)
- Avertissement (3)
- Information (4) - Pour les démarrages/arrêts
1. Sources d'événements à inclure
- DNS-Server-Service: Pour les opérations du serveur DNS
- DNS Client Events: Pour les événements côté client
1. Événements critiques (ID principaux)

## 🧐 Critères d'acceptation

Configure la vue personnalisée dans l'Event Viewer avec les critères demandés.  
Attribue un nom descriptif à la vue personnalisée.  
Exporte la vue au format XML.  
Sur un dépôt GitHub, ajoute le fichier XML et inclue un bref README expliquant ta vue personnalisée.

Solution postée le **dimanche 01 février 2026**

[https://github.com/LiudSwen/LOG\_Microsoft-Windows-DNS-Server](https://github.com/LiudSwen/LOG_Microsoft-Windows-DNS-Server)