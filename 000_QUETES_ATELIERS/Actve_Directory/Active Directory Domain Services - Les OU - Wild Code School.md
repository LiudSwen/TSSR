---
title: "Active Directory Domain Services - Les OU - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/1945/pages/18640"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Active Directory

## Active Directory Domain Services - Les OU

Facile

30mins

3 pairs

Active Directory

## Active Directory Domain Services - Les OU

## Introduction

L’ **unité d’organisation** (*Organizational Unit* ou **OU**) est couramment utilisé dans le monde de l'entreprise.  
Cependant, certains administrateurs utilisent les OU uniquement comme des dossiers pour classer les objets d’Active Directory. Dans cette quête, tu vas voir qu'elles ne servent pas qu'à cela.

## 📚 Prérequis

Avant de commencer, il est préférable d'avoir déjà terminé les quêtes suivantes:

```shell
Active Directory Domain Services - Introduction1hVoir la quête - Active Directory Domain Services - IntroductionActive Directory Domain Services - Installation1hVoir la quête - Active Directory Domain Services - Installation
```

---

![Unité d'organisation Windows](https://storage.googleapis.com/quest_editor_uploads/sgveiyMZeV8GB2QTspORg9mLIwfNgP63.jpg)

## 🎯 Objectifs:

✅ Connaître le but d'une Unité d'Organisation  
✅ Savoir utiliser une Unité d'Organisation au sein de l'Active Directory

## Sommaire

- [👉 Le but d'une Unité d'Organisation](https://odyssey.wildcodeschool.com/quests/1945/pages/18640#-le-but-dune-unit%C3%A9-dorganisation)
- [👉 Différences entre OU et groupe](https://odyssey.wildcodeschool.com/quests/1945/pages/18640#-diff%C3%A9rences-entre-ou-et-groupe)
- [👉 L'arborescence type d'une OU pour des comptes utilisateurs](https://odyssey.wildcodeschool.com/quests/1945/pages/18640#-larborescence-type-dune-ou-pour-des-comptes-utilisateurs)
- [👉 L'arborescence type d'une OU pour des comptes ordinateurs](https://odyssey.wildcodeschool.com/quests/1945/pages/18640#-larborescence-type-dune-ou-pour-des-comptes-ordinateurs)
- [☝️ Résumé](https://odyssey.wildcodeschool.com/quests/1945/pages/18640#%EF%B8%8F-r%C3%A9sum%C3%A9)
- [💪 Challenge](https://odyssey.wildcodeschool.com/quests/1945/pages/18640#-challenge)
- [🧐 Critères d'acceptation](https://odyssey.wildcodeschool.com/quests/1945/pages/18640#-crit%C3%A8res-dacceptation)

## 👉 Le but d'une Unité d'Organisation

L'un des objectifs principaux d’une **Unité d'Organisation** (**OU**), ce pourquoi elles ont été créées, est de déléguer les tâches d’administration et les droits sur les objets d’Active Directory. Les *Organization Unit* sont des conteneurs administratifs. Elles contiennent des objets ayant les mêmes besoins administratifs.  
De plus, une OU peu représenter:

- Un service
- Un site
- Une population métier  
	Si tout cela permet d'appliquer des GPO spécifiques à des ressources spécifiques.

## 👉 Différences entre OU et groupe

Les groupes servent à:

- Gérer les droits d'accès (**ACL**)
- Permettre des droits d'accès transverses

Les OU servent à:

- Appliquer des GPO
- Structurer l'annuaire

---

## 👉 L'arborescence type d'une OU pour des comptes utilisateurs

Il convient de séparer les comptes utilisateurs et ordinateurs.  
Prenons un exemple, une personne des ressources humaines pourrait avoir le besoin de désactiver un compte utilisateur. Cependant elle n’aura certainement pas le besoin de désactiver un compte ordinateur.

Nous pouvons donc envisager une OU **« employés »** regroupant les comptes utilisateurs.

Les administrateurs sont également des employés, mais il n’est peut-être pas souhaitable que la fameuse personne des ressources humaines puisse désactiver un compte d’administration.

Nous pouvons donc envisager une seconde OU **« administrateurs »** regroupant les comptes d’administration.

Dans le cas d’une entreprise multi-site, il est possible qu’elle dispose d’un support sur chaque site.  
Prenons en compte le fait que le support du site B n’aura besoin que de gérer les comptes du site B.

Dans ce cas des sous-OU à l’OU **« employés »** peuvent être envisagés comme l’OU **« Montpellier »** regroupant les utilisateurs du site de Montpellier et l’OU **« Nice »** regroupant les  
utilisateurs du site de Nice.

Voici ce à quoi pourrait ressembler notre arborescence d’OU pour la gestion des comptes utilisateurs:

![image.png](https://storage.googleapis.com/quest_editor_uploads/KgwNv1Tstpqw2MKJSsqIadukGR422OMq.png)

Évidemment c’est à l'administrateur de décider de l’arborescence à adopter.

---

## 👉 L'arborescence type d'une OU pour des comptes ordinateurs

Pour les comptes utilisateurs, il est conseillé de séparer utilisateurs standards et comptes d’administration. Nous allons procéder de manière similaire pour les comptes ordinateurs.  
Ainsi, créer une OU **« machines\_clientes »** regroupant tous les postes utilisateurs et une OU **« serveurs »** regroupant tous les serveurs pourrait être intéressant.

En effet, l’administration des serveurs n’est certainement pas gérée par les mêmes personnes que l’administration des postes clients.

À l’identique des comptes utilisateurs, nous pouvons redécouper l'OU **« machines\_clientes »** en sous-OU représentant les différents sites, ceci dans le but de favoriser la gestion par un éventuel service informatique décentralisé.

Avec l’augmentation de la mobilité, les entreprises enregistrent de plus en plus d’ordinateurs portables. Il pourrait donc être intéressant de segmenter ces OU en fonction de la mobilité avec **« ordinateurs\_portables »** et **« ordinateur\_fixes »**.

La gestion des serveurs quand à elle ne dépendra que très peu des sites de l’entreprise, mais plutôt du type de serveur. Il sera ainsi possible de segmenter l'OU « serveur » en sous-OU représentant les différents types de serveurs.

Voici ce que donnerait l’arborescence d’OU d’une telle gestion des comptes:

![image.png](https://storage.googleapis.com/quest_editor_uploads/8aMUkvQaDEDRGMsKBZchDND0hGnjVlkD.png)

---

## ☝️ Résumé

Une Ou permet de regrouper l’autorité dans un sous-ensemble de ressources d’un domaine. Une OU assure la fonction de barrière de sécurité pour les privilèges élevés et les autorisations. Les OU peuvent être utilisées pour mettre en place et limiter la sécurité et les rôles au sein des groupes

---

## 💪 Challenge

Sur ton Active Directory que tu as installé et configuré dans la quête précédente avec pour domaine `wilders.lan`

- Créer une OU `Wilders_students`
- Créer une OU `Wilder_Computers`
- Créer un Groupe d'utilisateurs `GrpUsersStudents`
- Créer un groupe d'ordinateurs `GrpComputersStudents`
- Créer un utilisateur **Wilder1**
- Mets cet utilisateur dans le groupe des utilisateurs et dans l'OU des utilisateurs que tu a crées
- Mets le client qui a joint le domaine dans le groupe des ordinateurs et dans l'OU des ordinateurs que tu a crées
- Connecte-toi sur le client avec le compte que tu as créer

Poste un lien Github qui contiendra des copies d'écran légendés:

- L'OU utilisateurs où on voit le compte utilisateur
- L'OU ordinateur où on voit le client
- La fenêtre du groupe utilisateur dans laquelle on voit l'utilisateur membre
- La fenêtre du groupe ordinateur dans laquelle on voit le client membre
- Sur le client, le résultat de la commande `whoami`

## 🧐 Critères d'acceptation

Le lien Github contient 5 copies d'écran avec une légende pour chacune.

Solution postée le **lundi 29 décembre 2025**

[https://github.com/LiudSwen/AD-DS-Quest/blob/main/AD-DS-OU.md](https://github.com/LiudSwen/AD-DS-Quest/blob/main/AD-DS-OU.md)