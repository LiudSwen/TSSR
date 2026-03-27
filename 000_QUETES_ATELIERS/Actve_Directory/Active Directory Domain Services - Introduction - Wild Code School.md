---
title: "Active Directory Domain Services - Introduction - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/3966/pages/18637"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Active Directory

## Active Directory Domain Services - Introduction

Moyen

1h

Quiz

Active Directory

## Active Directory Domain Services - Introduction

## Introduction

**Active Directory Domain Services** (**AD DS**) est la mise en œuvre par Microsoft du service d'annuaire LDAP pour les systèmes d'exploitation Windows. Historiquement nommé NTDS et introduit avec Windows 2000 Server, il a remplacé la base SAM (utilisée pour les petits réseaux) afin d'offrir une meilleure évolutivité. C'est un système distribué qui stocke les informations et met en relation les utilisateurs avec les ressources du réseau.

---

![logo AD](https://storage.googleapis.com/assets_upload_prod/gYvscNi5odzBEuKUszGCPeImVfxbrQcg.png)

## 🎯 Objectifs

✅ Savoir ce qu'est AD DS  
✅ Connaître les principaux composants d'AD DS

## Sommaire

- [🕰️ Historique](https://odyssey.wildcodeschool.com/quests/3966/pages/18637#%EF%B8%8F-historique)
- [📖 Active Directory](https://odyssey.wildcodeschool.com/quests/3966/pages/18637#-active-directory)
- [📘 AD DS](https://odyssey.wildcodeschool.com/quests/3966/pages/18637#-ad-ds)
- [🚀 Objectifs d'AD DS](https://odyssey.wildcodeschool.com/quests/3966/pages/18637#-objectifs-dad-ds)
- [🖥️ Composants physiques et rôles](https://odyssey.wildcodeschool.com/quests/3966/pages/18637#%EF%B8%8F-composants-physiques-et-r%C3%B4les)
- [🔄 Réplication AD DS](https://odyssey.wildcodeschool.com/quests/3966/pages/18637#-r%C3%A9plication-ad-ds)
- [🔑 Gestion par Stratégies de Groupe](https://odyssey.wildcodeschool.com/quests/3966/pages/18637#-gestion-par-strat%C3%A9gies-de-groupe)
- [📝 Résumé](https://odyssey.wildcodeschool.com/quests/3966/pages/18637#-r%C3%A9sum%C3%A9)
- [💪 Challenge](https://odyssey.wildcodeschool.com/quests/3966/pages/18637#-challenge)
- [🧐 Critères d'acceptation](https://odyssey.wildcodeschool.com/quests/3966/pages/18637#-crit%C3%A8res-dacceptation)

## 🕰️ Historique

Les premiers concepts (Directory Services et LDAP) datent de la fin des années 90.  
L' **Active Directory** fut présenté pour la première fois en 1996, mais sa première utilisation remonte à Windows 2000 Server. Les administrateurs informatiques travaillent avec depuis l’introduction de cette technologie.  
L'Active Directory est le résultat de l'évolution de la base de données de comptes de domaine SAM *(Security Account Manager)* et une mise en œuvre de LDAP, protocole de hiérarchie.  
À la base, chaque système Windows est basé sur le **Registre Windows**, qui contient la **base SAM**.  
Active Directory est stocké sur chaque Contrôleur de Domaine.

## 📖 Active Directory

L'Active Directory est un ensemble de services.  
Il existe 5 services AD:

- AD DS ⇒ celui qui nous intéresse ici
- AD LDS
- AD CS
- AD FS
- AD RMS  
	Le terme AD désigne l'ensemble des services AD.  
	**AD DS** (*Active Directory Domain Services*) correspond au service d'annuaire Microsoft.
```
D'un point de vue cybersécurité, la compréhension d’AD DS est une priorité absolue pour les professionnels de la réponse aux incidents et de la cybersécurité. En effet, la plupart des cyberattaques affectent AD DS et lorsqu’elles se produisent, il faut savoir ce qu’il faut rechercher et comment y répondre.
```

## 📘 AD DS

C'est un rôle serveur disponible sur les versions de Windows Server.  
Il repose sur une structure hiérarchique logique.  
Les ressources sont donc organisées indépendamment de leur emplacement physique.  
Hiérarchiquement on trouve:

- **L'objet**: plus petite entité logique d'un annuaire AD DS. Il représente une ressource (ex.: un utilisateur) et possède des attributs (ex.: un nom, un prénom, etc.)
- **Le conteneur**: terme générique désignant tout objet capable de contenir d'autres objets (ex.: le conteneur **groupe**). Il existe des conteneurs particulier crées à la création d'un DC. Par exemple le conteneur "Computers" qui contient les machines qui rejoignent un domaine.
- **L'Unité d'Organisation** ou **OU** (*Organizational unit*): élément logique à l'intérieur d'un domaine. Les OU permettent d'organiser les objets et surtout d'appliquer des **stratégies de groupe** ou **GPO** (*Group Policy Objects*) spécifiques ou de déléguer des droits d'administration.
- **Le domaine**: unité de base administrative et de sécurité. Il regroupe des **objets** (utilisateurs, ordinateurs, gpo, etc.) partageant une base de données d'annuaire commune. Contrairement à un **Workgroup** (où chaque machine est gérée individuellement), le domaine permet une administration centralisée.
- **L'arbre**: arborescence de domaines partageant un espace de noms contigu (ex.: paris.masociete.fr et lyon.masociete.fr)
- **La forêt**: ensemble d'arbres constituant le niveau logique le plus haut dans la hiérarchie.

## 🚀 Objectifs d'AD DS

- Centraliser l'identification et l'authentification
- Stocker les ressources (utilisateurs, ordinateurs, etc.) sous forme d'objets pour faciliter leur gestion
- Appliquer des politiques de sécurité et de contrôle d'accès
- Faciliter l'administration par les stratégies de groupes

## 🖥️ Composants physiques et rôles

Pour fonctionner, l'architecture logique s'appuie sur des serveurs spécifiques:

- **Contrôleur de Domaine** ou **DC** (*Domain Controller*): C'est un serveur qui détient une copie de la base de données de l'annuaire et qui répond aux demandes d'authentification et aux requêtes LDAP. Il est indispensable au domaine. Le premier DC d'un domaine crée également la forêt.
- **Catalogue Global**: C'est un rôle attribué à un DC qui stocke une copie partielle de tous les objets de la forêt. Il permet de rechercher des informations sur des objets situés dans n'importe quel domaine de la forêt. Le premier DC d'un domaine est Catalogue Global.
- **RODC** (*Read-Only Domain Controller*): C'est un DC spécifique en lecture seule, utilisé dans les sites distants moins sécurisés. Il fournit les services d’authentification AD DS localement, sans exposer l’intégralité en cas de compromission.
- **Rôles FSMO** (*Flexible Single Master Operation*): Bien que la réplication soit "multi-maître" (les modifications peuvent se faire sur n'importe quel DC), certaines opérations sensibles nécessitent un maître unique. Il existe 5 rôles FSMO, dont 2 sont uniques par forêt (Maître de schéma, Maître d'attribution de noms) et 3 uniques par domaine (RID, Infrastructure, Émulateur PDC). Le premier DC d'un domaine a tous les rôles FSMO.

## 🔄 Réplication AD DS

Elle permet de maintenir une cohérence des données d'annuaire entre tous les DC d'une même forêt.  
Chaque DC détient une copie de la base de données AD DS et les modifications effectuées sur l'un d'eux sont propagées automatiquement aux autres.

Les modifications sur un élément (utilisateur, GPO, OU, etc.) peuvent être réalisées sur n'importe quel DC:

- Les changements sont répliqués vers les autres DC
- Cette réplication est:
	- Automatique
		- Sécurisée
		- Optimisée pour le réseau
		- En mode **multi-maître**

## 🔑 Gestion par Stratégies de Groupe

Les **GPO** (*Group Policy Objects*) sont des collections de paramètres qui permettent de gérer la configuration des utilisateurs et des ordinateurs de manière centralisée.

- Application: Elles peuvent servir à déployer des logiciels, gérer la sécurité (mots de passe), ou configurer l'interface Windows
- Hiérarchie: Les GPO s'appliquent dans un ordre précis: Local → Site → Domaine → OU. En cas de conflit, la dernière appliquée (celle de l'OU) l'emporte, sauf exception (héritage ou forcée)

---

## 📝 Résumé

AD DS est le service d'annuaire de Microsoft destiné à centraliser la gestion des identités et des accès sur un réseau.  
Il repose sur une base de données hiérarchique (LDAP) structurée en Forêts, Domaines et Unités d'Organisation (OU).  
À retenir:

- Tout est objet: Utilisateurs, ordinateurs, groupes, OU, GPO, etc.
- Sécurité gérée par les GPO
- Une réplication des données entre DC

---

## 💪 Challenge

Réponds au quizz.

## 🧐 Critères d'acceptation

Tu dois avoir 100% de bonnes réponses aux questions du quiz.