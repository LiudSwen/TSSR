---
title: "Active Directory Domain Services  - Les Stratégies de Groupes ou GPO - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/1949/pages/18642"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Active Directory

## Active Directory Domain Services - Les Stratégies de Groupes ou GPO

Moyen

1h

3 pairs

Active Directory

## Active Directory Domain Services - Les Stratégies de Groupes ou GPO

## Introduction

Passer à côté des GPO, c’est passer à côté d’une grosse fonctionnalité d’Active Directory pour windows server.  
Les GPO pour *Group Policy Object* permettent de centraliser la gestion des configurations. Plus besoin de passer sur chaque poste pour appliquer un paramètre. Grâce aux GPO tu peux tout gérer depuis ton PC en quelques clics de souris. Un système de priorité et d’étendue te permettra d’appliquer les GPO très précisément aux utilisateurs et ordinateurs désirés.

## 📚 Prérequis

Avant de commencer, il est préférable d'avoir déjà terminé les quêtes suivantes:

```shell
Active Directory Domain Services - Les OU30minsVoir la quête - Active Directory Domain Services - Les OUActive Directory Domain Services - Domaines, Arborescences et Forêts30minsVoir la quête - Active Directory Domain Services - Domaines, Arborescences et Forêts
```

![image](https://storage.googleapis.com/quest_editor_uploads/VBMFcQB53YzfF45yJ8Avy3THB4NPmKBq.jpg)

---

## 🎯 Objectifs:

✅ Comprendre ce qu'est une GPO  
✅ Savoir créer une GPO dans l'Active Directory  
✅ Déployer une GPO

## Sommaire

- [👉 Présentation](https://odyssey.wildcodeschool.com/quests/1949/pages/18642#-pr%C3%A9sentation)
- [👉 Types de GPO](https://odyssey.wildcodeschool.com/quests/1949/pages/18642#-types-de-gpo)
	- [La Stratégie de groupe locale](https://odyssey.wildcodeschool.com/quests/1949/pages/18642#la-strat%C3%A9gie-de-groupe-locale)
		- [Stratégie de groupe Active Directory](https://odyssey.wildcodeschool.com/quests/1949/pages/18642#strat%C3%A9gie-de-groupe-active-directory)
- [👉 Exemple d'une GPO](https://odyssey.wildcodeschool.com/quests/1949/pages/18642#-exemple-dune-gpo)
	- [🔬 Exercice](https://odyssey.wildcodeschool.com/quests/1949/pages/18642#-exercice)
		- [Mettre en œuvre la stratégie de comptes locale](https://odyssey.wildcodeschool.com/quests/1949/pages/18642#mettre-en-%C5%93uvre-la-strat%C3%A9gie-de-comptes-locale)
				- [Paramétrer la stratégie de groupe locale](https://odyssey.wildcodeschool.com/quests/1949/pages/18642#param%C3%A9trer-la-strat%C3%A9gie-de-groupe-locale)
- [☝️ Résumé](https://odyssey.wildcodeschool.com/quests/1949/pages/18642#%EF%B8%8F-r%C3%A9sum%C3%A9)
- [💪 Challenge](https://odyssey.wildcodeschool.com/quests/1949/pages/18642#-challenge)
- [🧐 Critères d'acceptation](https://odyssey.wildcodeschool.com/quests/1949/pages/18642#-crit%C3%A8res-dacceptation)

## 👉 Présentation

Dans un environnement Active Directory, il est bien entendu possible de créer et déployer des stratégies de groupes pour cibler les postes clients et les utilisateurs. En complément, il faut savoir qu'il existe la possibilité d'appliquer des paramètres GPO directement en local sur un poste, notamment s'il est hors domaine.

Voyons ce qu'est une stratégie de groupe locale et ce qui la différencie d'une stratégie de groupe Active Directory.

---

## 👉 Types de GPO

## La Stratégie de groupe locale

Depuis Windows XP, toutes les versions de Windows intègrent les paramètres de configuration avec une organisation similaire et accessible localement au travers d'une console [MMC](https://docs.microsoft.com/fr-fr/troubleshoot/windows-server/system-management-components/what-is-microsoft-management-console). Ces paramètres de configuration sont ceux que l'on retrouve lorsque l'on crée une stratégie de groupe sur un domaine, organisé de la même façon, et qui sont utilisables pour personnaliser la machine ou le serveur sur lequel on se trouve.

Ces paramètres lorsqu'ils sont gérés en local, restent stockés en local, et l'on appelle cela la "Stratégie de groupe locale" ou "Local Group Policy", en anglais. Avec ce mode de fonctionnement, il n'y a rien de centralisé: le paramétrage s'effectue machine par machine, à la main. Autrement dit, cela peut s'avérer très gourmand en temps.

Si on souhaite configurer la stratégie de groupe locale de son PC, c'est tout simple: il suffit d'ouvrir la console `gpedit.msc`, soit via une commande Exécuter (touche Windows + R) ou en recherchant directement dans la barre de recherche de Windows.

![image.png](https://storage.googleapis.com/quest_editor_uploads/QvEwWKUzsAlAa8idNTwwosloR5vVpWYW.png)

Tu as alors accès à la stratégie de l'ordinateur local, que tu peux modifier à souhait. Cela peut s'avérer utile sur une machine hors domaine, c'est-à-dire en groupe de travail ("WORKGROUP" par défaut).

![image.png](https://storage.googleapis.com/quest_editor_uploads/hCRLYCgT7BVMMWXBeDviiVCgxPlktEHi.png)

C'est peut-être la première fois que tu vois cette interface. Lorsque nous allons créer des stratégies de groupe Active Directory, tu verras que la console est très proche de celle-ci.

La stratégie de groupe locale est une possibilité intéressante pour tester une nouvelle configuration afin de préconfigurer et sécuriser au mieux tes équipements. La gestion machine par machine étant difficilement envisageable, **comment faire pour gérer de façon centralisée les paramètres de stratégie de groupe? C'est là qu'interviennent les stratégies de groupe Active Directory.**

## Stratégie de groupe Active Directory

À l'aide d'une console unique, on peut gérer différentes stratégies de groupe (GPO) à appliquer sur ses machines et ses utilisateurs.

Garde à l'esprit que **la stratégie de groupe locle** peut s'avérer utile pour tester une configuration avant de la déployer sur un ensemble de machines de son parc. Ensuite, lorsque la configuration est testée et validée, tu pourras la déployer sur ton infrastructure grâce à une stratégie de groupe Active Directory.

La configuration sera ainsi appliquée sur tes machines, automatiquement, ce qui te feras gagner un temps précieux et offre une énorme flexibilité.

---

## 👉 Exemple d'une GPO

La GPO suivante est une stratégie de groupe de type utilisateur:

![image.png](https://storage.googleapis.com/quest_editor_uploads/hjEq59g803pALEaEv4wtbJ3cbKMBLE9Y.png)  
On peut détailler la stratégie comme ceci:

1. Le nom de la GPO qui va s'appliquer à un objet (Utilisateurs ou Groupes, UO etc)
2. Quelle configuration (ici utilisateur)
3. Dans quelle rubrique
4. On désactive la possibilité aux utilisateurs d'avoir accès à l'invite de commande.

Dans la forêt **intranet.lan**, on retrouve donc l'Unité d'Organisation nommée "Employee-Bank" qui possède une GPO nommée "Employee-GPO"

![image.png](https://storage.googleapis.com/quest_editor_uploads/6ZYtygsm1J8dPTIXm3YUPIT5tEglP4ZV.png)

Et dans le domaine Active Directory dans la rubrique, Utilisateurs et Ordinateurs Active Directory on retrouve:

![image.png](https://storage.googleapis.com/quest_editor_uploads/Mm2vCaKU1OOrbvAVRvMeWamvKWiYohue.png)

1. Le Domaine
2. L'Unité D'organisation
3. Les utilisateurs ou Groupes d'utilisateurs

En conclusion c'est à ces utilisateurs ou groupes d'utilisateurs que s'appliqueront la GPO nommée "Employee-GPO".

## 🔬 Exercice

### Mettre en œuvre la stratégie de comptes locale

Command Tips: WINDOWS + R

```shell
secpol.msc
```

Définir une stratégie de mot de passe comme suit:

| Description | Value |
| --- | --- |
| Historique des mots de passe | 5 |
| Durée de vie maximale du mot de passe | 45 |
| Durée de vie minimale du mot de passe | 3 |
| Longueur minimale du mot de passe | 16 |
| Le mot de passe doit respecter des exigences de complexité | Oui |

Définir une stratégie de verrouillage des comptes comme suit:

| Description | Value |
| --- | --- |
| Durée de verrouillage du compte | 30' |
| Seuil de verrouillage du compte | 5 |
| Réinitialiser le compteur de verrouillage après | 29' |

### Paramétrer la stratégie de groupe locale

1. Empêcher de modifier l’arrière-plan du bureau
2. Empêcher l’utilisation de Windows Media Player
3. Interdire l’installation à partir de supports amovibles (clé USB, CD-Rom, DVD)
4. Empêcher le lancement de certaines applications: OneDrive par exemple
5. Interdire l’accès à l’invite de commandes
6. Interdire l’accès au menu Exécuter du menu Démarrer
7. Interdire l’accès à la base de registre
8. Empêcher l’accès à Windows update

---

## ☝️ Résumé

Les GPO offrent le contrôle du parc informatique. Chaque paramètre appliqué par une GPO n’est pas modifiable par l’utilisateur. La gestion centralisée étant prioritaire à la gestion locale. Une fois prises en main les GPO deviennent un outil indispensable de l’infrastructure Active Directory, y compris sur un parc composé de très peu de machines.

Command Tips: Pour forcer l'application des GPO, dans une invit de commande en tant qu'Administrateur

```shell
C:\>gpupdate /force
```

---

## 💪 Challenge

Sur l'Active Directory que tu as installé et configuré dans la quête précédente avec pour domaine `wilders.lan`:

- Créé une GPO nommée `Users-Wilders`
- Modifies la GPO pour interdire l'accès au panneau de configuration
- Applique cette GPO sur l'OU `Wilders_students`
- Fais un filtrage avec le groupe `GrpUsersStudents`

Vérifie sur le poste client que l'accès au panneau de configuration est bien bloqué.

Poste un lien Github qui contiendra des copies d'écran légendés:

- La fenêtrede la GPO où on voit l'OU appliquée et le groupe de filtrage
- Sur le client la fenêtre indiquant que l'accès est refusé

## 🧐 Critères d'acceptation

- Le lien Github contient 2 copies d'écran avec une légende pour chacune.

Solution postée le **lundi 29 décembre 2025**

[https://github.com/LiudSwen/AD-DS-Quest/blob/main/AD-DS-GPO.md](https://github.com/LiudSwen/AD-DS-Quest/blob/main/AD-DS-GPO.md)