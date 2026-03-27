---
title: "Atelier : Appliquer une politique de sauvegarde avec Bareos - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2365/pages/11674"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Sauvegarde

## Atelier: Appliquer une politique de sauvegarde avec Bareos

Utilisation de Bareos pour la mise en place de sauvegardes planifiées sur des clients GNU/Linux et Windows

Moyen

3h

Auto-validation

Sauvegarde

## Atelier: Appliquer une politique de sauvegarde avec Bareos

## Introduction

Cet atelier consiste a planifier des tâches sur **Bareos** afin de sauvegarder un client GNU/Linux ainsi qu'un client Windows.

![Logo de Bareos](https://openexpoeurope.com/wp-content/uploads/2019/04/bareos-logo-full.png)

## 📚 Pré-requis

Avant de commencer cet atelier, il est préférable d'avoir déjà terminé la quête suivante:

```shell
Bareos - Gestion centralisée des sauvegardesBareos est un logiciel de gestion centralisée de sauvegardes3hVoir la quête - Bareos - Gestion centralisée des sauvegardes
```

## 🤓 Objectifs:

✅ Comprendre les notions de **FileSet**, **Schedule** et **Job**  
✅ Configurer Bareos pour effectuer des sauvegardes planifiées  
✅ Vérifier l'exécution des sauvegardes

## Sommaire

- [🗓️ La politique de sauvegarde](https://odyssey.wildcodeschool.com/quests/2365/pages/11674#%EF%B8%8F-la-politique-de-sauvegarde)
- [📌 La configuration de bareos (rappel)](https://odyssey.wildcodeschool.com/quests/2365/pages/11674#-la-configuration-de-bareos-rappel)
- [🔬 Étape 1: Installation des composants **bareos**](https://odyssey.wildcodeschool.com/quests/2365/pages/11674#-%C3%A9tape-1--installation-des-composants-bareos)
- [🔬 Étape 2: Création des *FileSets*](https://odyssey.wildcodeschool.com/quests/2365/pages/11674#-%C3%A9tape-2--cr%C3%A9ation-des-filesets)
- [🔬 Étape 3: Création du *Schedule*](https://odyssey.wildcodeschool.com/quests/2365/pages/11674#-%C3%A9tape-3--cr%C3%A9ation-du-schedule)
- [🔬 Étape 4: Création des *Jobs*](https://odyssey.wildcodeschool.com/quests/2365/pages/11674#-%C3%A9tape-4--cr%C3%A9ation-des-jobs)
- [🔍 Étape 5: Vérification](https://odyssey.wildcodeschool.com/quests/2365/pages/11674#-%C3%A9tape-5--v%C3%A9rification)
- [💪 Conclusion](https://odyssey.wildcodeschool.com/quests/2365/pages/11674#-conclusion)

## 🗓️ La politique de sauvegarde

Les serveurs nécessaires à cet atelier sont les suivants:

- Un serveur de sauvegarde sous GNU/Linux avec
	- Le **Director**: `bareos-dir` qui est en charge de l'orchestration des sauvegardes
		- Le **Storage Daemon**: `bareos-sd` pour l'enregistrement des sauvegardes sur disque
- Un serveur quelconque sous GNU/Linux avec un **File Daemon** (`bareos-fd`)
- Un serveur quelconque sous Windows Server avec un **File Daemon** (`bareos-fd`)

Les 2 derniers serveurs n'ont pas besoin de disposer d'autre chose que `bareos-fd` pour cet atelier. Ils représentent des serveurs applicatifs quelconques même si en pratique, ils n'hébergent pas réellement d'application.  
Dans un cas réel, l'ensemble des fichiers à sauvegarder sur ces serveurs est bien sûr à adapter en fonction des applicatifs qu'ils hébergent.

Ces 3 serveurs doivent pouvoir communiquer à travers un réseau IP.  
Un fois les paquets nécessaires à l'installation des différents composants de **Bareos** récupérés, il n'est pas nécessaire qu'ils aient accès à Internet.  
Il peut s'agir de machines virtuelles.

La politique de sauvegarde à mettre en place consiste à sauvegarder des données spécifiques sur chacun des 2 serveurs.

- `/home` sur le serveur GNU/Linux
- `c:\Users` sur le serveur Windows

Pour les besoins de l'atelier, on opte pour une planification rapide des sauvegardes avec

- Une complète toute les heures
- Une incrémentale toute les 10 min

Tu peux consulter l'article suivant pour t'aider dans la réalisation de cet atelier.

```shell
Effectuez vos sauvegardes avec Bareos
Article de GNU/Linux magazine traitant des sauvegardes avec bareoshttps://connect.ed-diamond.com/GNU-Linux-Magazine/glmf-212/effectuez-vos-sauvegardes-avec-bareos
```

## 📌 La configuration de bareos (rappel)

La configuration de bareos se situe principalement sur le **Director**.

Elle peut s'effectuer directement à l'aide des fichiers de configurations qui se trouve habituellement dans `/etc/bareos`: [plus d'info dans la documentation](https://docs.bareos.org/Configuration/CustomizingTheConfiguration.html#configurechapter)

La prise en compte des modifications nécessite le redémarrage de `bareos-dir`.

```shell
Une erreur de syntaxe dans les fichiers de configuration peut empêcher le redémarrage.
Aussi pense à vérifier que ta configuration est correcte après chaque modification comme indiqué dans la doc à la section : tester sa configuration
```

La configuration est aussi possible directement via la console à l'aide de la commande suivante:

```shell
Le commande configurehttps://docs.bareos.org/TasksAndConcepts/BareosConsole.html#section-bcommandconfigure
```

---

## 🔬 Étape 1: Installation des composants bareos

Dans cette étape, tu peux repartir de l'installation réalisée dans la quête:

**Objectif de cette étape**:

- Avoir un serveur de sauvegarde fonctionnel qui peut communiquer avec le client GNU/Linux et les client Windows.

Il est possible de se reporter à la section [The Windows Version of Bareos](https://docs.bareos.org/TasksAndConcepts/TheWindowsVersionOfBareos.html) pour plus d'information sur l'installation sous Windows.

---

## 🔬 Étape 2: Création des FileSets

**Objectif de cette étape**:

- Créé un **FileSet** pour le client GNU/Linux déclarant la sauvegarde de `/home`
- Créé un autre **FileSet** pour le client Windows déclarant la sauvegarde de `C:\Users`
- Ces 2 configurations doivent imposer une compression avec **GZIP** et une vérification des signatures de fichiers avec **SHA256**
```shell
Astuce : Pour éviter des erreurs de syntaxe, il peut-être judicieux de recopier et modifier un fichier de configuration existant
```

Plus d'info sur la configuration des **FileSets** dans la doc:

```shell
FileSet Resource
Documentation sur la configuration des FileSetshttps://docs.bareos.org/Configuration/Director.html#fileset-resource
```

---

## 🔬 Étape 3: Création du Schedule

**Objectif de cette étape**:

- Créé un **Schedule** déclarant:
	- Une sauvegarde complete par heure
		- Une sauvegarde incrémentale toutes les 10 minutes

Plus d'info sur la configuration des **Schedules** dans la doc:

```shell
Schedule Resource
Documentation sur la configuration des Scheduleshttps://docs.bareos.org/Configuration/Director.html#schedule-resource
```

---

## 🔬 Étape 4: Création des Jobs

**Objectif de cette étape**:

- Créé un **Job** de sauvegarde pour chaque client déclarant:
	- Le client à sauvegarder
		- Le **FileSet** souhaité
		- Le **Schedule**
		- Le type `Backup`
		- Les autres éléments nécessaires

Plus d'info sur la configuration des **Jobs** dans la doc:

```shell
Job Resource
Documentation sur la configuration des Jobshttps://docs.bareos.org/Configuration/Director.html#job-resource
```

---

## 🔍 Étape 5: Vérification

À l'aide de la console ou de la webui, vérifier que les sauvegardes se font correctement.

Constater notamment que le temps et l'espace de stockage nécessaire à une sauvegarde complète est beaucoup plus important que pour une incrémentale.

Vérifier que les restaurations permettent bien de récupérer les fichiers sauvegardés.

---

## 💪 Conclusion

Valide l'atelier si les sauvegardes complètes et incrémentales se sont correctement effectuées.

Quête terminée le **jeudi 19 février 2026**