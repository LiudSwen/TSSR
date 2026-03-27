---
title: "Atelier : GPO - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/3036/pages/11431"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Active Directory

## Atelier: GPO

Difficile

3h

Auto-validation

Active Directory

## Atelier: GPO

## Introduction

Les **GPO**, acronyme de *Group Policy Object* (**Objet de Stratégie de Groupe** en Français), sont des outils essentiels pour la gestion centralisée des configurations dans des environnements réseau basés sur Windows au sein d'un domaine Active Directory. Une fois mise en place, on peut définir des paramètres de configuration pour les utilisateurs et les ordinateurs. Il n'y a pas de limite pour ces paramètres qui peuvent inclure de la sécurité système, du déploiement et de la configuration de logiciel, de la modification d'interface, de la gestion d'accès aux ressources réseaux, etc.  
Dans cet atelier tu vas créer et mettre en place des GPO qui ont chacune un périmètre et un objectif précis, dans des scénarios d'utilisation réelles.

![logo microsoft active directory](https://i0.wp.com/networkcorp.fr/wp-content/uploads/2018/03/gpo_logo.jpg?w=439&ssl=1)

## 🎯 Objectifs:

✅ Créer des GPO et les appliquer sur des OU  
✅ Modifier les GPO selon une configuration ordinateur ou utiisateur  
✅ Savoir comment vérifier l'application sur des clients

## sommaire

- [✔️ Étape 1 - Prérequis](https://odyssey.wildcodeschool.com/quests/3036/pages/11431#%EF%B8%8F-%C3%A9tape-1---pr%C3%A9requis)
	- [Préparation des VM](https://odyssey.wildcodeschool.com/quests/3036/pages/11431#pr%C3%A9paration-des-vm)
		- [Sources à télécharger](https://odyssey.wildcodeschool.com/quests/3036/pages/11431#sources-%C3%A0-t%C3%A9l%C3%A9charger)
- [⚙️ Étape 2 - Déploiement de 7zip](https://odyssey.wildcodeschool.com/quests/3036/pages/11431#%EF%B8%8F-%C3%A9tape-2---d%C3%A9ploiement-de-7zip)
	- [Création de l'objet GPO](https://odyssey.wildcodeschool.com/quests/3036/pages/11431#cr%C3%A9ation-de-lobjet-gpo)
		- [Mise en place des éléments de la GPO](https://odyssey.wildcodeschool.com/quests/3036/pages/11431#mise-en-place-des-%C3%A9l%C3%A9ments-de-la-gpo)
		- [Liaison de la GPO à une OU](https://odyssey.wildcodeschool.com/quests/3036/pages/11431#liaison-de-la-gpo-%C3%A0-une-ou)
- [🔬 Étape 3 - Déploiement de Firefox](https://odyssey.wildcodeschool.com/quests/3036/pages/11431#-%C3%A9tape-3---d%C3%A9ploiement-de-firefox)
- [🔬 Étape 4 - Déploiement de Chrome](https://odyssey.wildcodeschool.com/quests/3036/pages/11431#-%C3%A9tape-4---d%C3%A9ploiement-de-chrome)
- [⚙️ Étape 5 - Mise en place d'un fond d'écran](https://odyssey.wildcodeschool.com/quests/3036/pages/11431#%EF%B8%8F-%C3%A9tape-5---mise-en-place-dun-fond-d%C3%A9cran)
	- [Fond d'écran global](https://odyssey.wildcodeschool.com/quests/3036/pages/11431#fond-d%C3%A9cran-global)
		- [Fond d'écran spécifique](https://odyssey.wildcodeschool.com/quests/3036/pages/11431#fond-d%C3%A9cran-sp%C3%A9cifique)
- [⚙️ Étape 6 - Mise en place de restrictions d'accès](https://odyssey.wildcodeschool.com/quests/3036/pages/11431#%EF%B8%8F-%C3%A9tape-6---mise-en-place-de-restrictions-dacc%C3%A8s)
	- [Restriction d'accès au panneau de configuration](https://odyssey.wildcodeschool.com/quests/3036/pages/11431#restriction-dacc%C3%A8s-au-panneau-de-configuration)
		- [Restriction d'accès à l'explorateur de fichiers](https://odyssey.wildcodeschool.com/quests/3036/pages/11431#restriction-dacc%C3%A8s-%C3%A0-lexplorateur-de-fichiers)
- [⚙️ Étape 7 - Vérification des GPO avec une configuration utilisateur](https://odyssey.wildcodeschool.com/quests/3036/pages/11431#%EF%B8%8F-%C3%A9tape-7---v%C3%A9rification-des-gpo-avec-une-configuration-utilisateur)
	- [Résumé des GPO](https://odyssey.wildcodeschool.com/quests/3036/pages/11431#r%C3%A9sum%C3%A9-des-gpo)
		- [Vérification de l'application des GPO](https://odyssey.wildcodeschool.com/quests/3036/pages/11431#v%C3%A9rification-de-lapplication-des-gpo)
- [⚙️ Étape 8 - Vérification des GPO avec une configuration ordinateur](https://odyssey.wildcodeschool.com/quests/3036/pages/11431#%EF%B8%8F-%C3%A9tape-8---v%C3%A9rification-des-gpo-avec-une-configuration-ordinateur)
	- [Résumé des GPO](https://odyssey.wildcodeschool.com/quests/3036/pages/11431#r%C3%A9sum%C3%A9-des-gpo-1)
		- [Vérification de l'application des GPO](https://odyssey.wildcodeschool.com/quests/3036/pages/11431#v%C3%A9rification-de-lapplication-des-gpo-1)
- [🏆 Conclusion](https://odyssey.wildcodeschool.com/quests/3036/pages/11431#-conclusion)

## ✔️ Étape 1 - Prérequis

## Préparation des VM

Tu a besoin de 3 VM sous Virtualbox:

- 1 VM serveur Windows Server 2022
- 2 VM client Windows 10  
	Chacune des VM a une carte réseau en mode `Réseau interne` sur le même nom de réseau

**VM client**  
Chaque machine:

- Est sur le domaine lab.lan
- A déjà eu une session d'ouverte avec les compte du domaine `User1` et `User2`

**VM serveur**

- Les rôles AD-DS et DNS sont installés
- Un domaine `lab.lan` est installé et les OU suivantes sont crées sur la racine du domaine:
	- `LabSecurite`
		- `LabOrdinateurs`
		- `LabUtilisateurs`
- Les groupes suivants sont crées dans l'OU `LabSecurite`:
	- `GrpComputers7Zip`
		- `GrpComputersFirefox`
		- `GrpUsersChrome`
		- `GrpUsersWallpaper-Green`
		- `GrpUsersWindowsRestrictions`
- Les utilisateurs suivants sont crées dans l'OU `LabUtilisateurs`:
	- `User1` fait partie du groupe `GrpUsersChrome`
		- `User2` fait partie des groupes `GrpUsersWindowsRestrictions` et `GrpUsersWallpaper-Green`
- Les objets ordinateurs **CLIENT1** et **CLIENT2** des VM clients sont dans l'OU `LabOrdinateurs`, et:
	- `CLIENT1` fait partie du groupe `GrpComputers7Zip`
		- `CLIENT2` fait partie du groupe `GrpComputersFirefox`
- Un dossier partagé **Ressources** est crée sur la racine du système de fichiers
	- Ce dossier est partagé avec le même nom **Ressources** sur le réseau
		- Il est accessible par le groupe `Everyone` avec les permissions `Read`

Détails de la configuration:

| Fonction de la VM | Serveur | Client |
| --- | --- | --- |
| Nom | WINSERV1 | CLIENT1 / CLIENT2 |
| OS | Windows Server 2022 | Windows 10 |
| OS version | Standard Desktop Experience | Professionnel |
| RAM | 4/8 Go | 2/4 Go |
| Langue à installer | English (US) | French |
| Time and currency / keyboard | French | French |
| Carte réseau VirtualBox | Réseau privé | Réseau privé |
| Adresse IP | 10.10.5.10/24 | 10.10.5.100/24 et 10.10.5.200/24 |
| Passerelle | \- | \- |
| DNS | 10.10.5.10 ou 127.0.0.1 | 10.10.5.10 |
| Utilisateur local | Administrator | Wilder |
| Firewall | Désactivé | Désactivé |

```shell
Pour cet atelier, le serveur est sous OS Windows Server 2022, et les clients sont sous OS Windows 10. Ces machines sont virtualisées sous Virtualbox 7 tournant sur un système hôte Ubuntu 22.04 LTS.

Les expérimentations pratiques peuvent être reproduites avec d'autres versions, sur d'autres distributions Linux, et sur d'autres environnement, mais des différences peuvent alors apparaître.
```

## Sources à télécharger

```shell
Installeur 7zipPrendre le type de fichier .msi pour les systèmes 64-bit Windows x64.https://www.7-zip.org/download.html
```
```shell
Installeur Mozilla Firefox ESRPrendre le type de fichier Firefox Extended Support Release (ESR) - Installeur MSI.https://www.mozilla.org/fr/firefox/enterprise/#download
```
```shell
Installeur Google ChromeChoisir :

Canal : Stable
Type de fichier : MSI
Architecture : 64 bits
https://chromeenterprise.google/intl/fr_fr/browser/download/#windows-tab
```
```shell
Fichiers jpg de fond d'écranPrendre les 2 fichiers wallpaper_blue.jpg et wallpaper_green.jpg.https://github.com/WildCodeSchool/TSSR_Resources/tree/main/Ressources_ateliers
```

Mettre les 5 fichiers (3 fichiers.msi et 2 fichiers.jpg) dans le dossier partagé du serveur.

## ⚙️ Étape 2 - Déploiement de 7zip

- Ouvre une session `Administrator` sur le serveur
- À partir du Server Manager, ouvre la console **Group Policy Management**

## Création de l'objet GPO

- Déroule l'arborescence **Group Policy Management** → **Forest: lab.lan** → **Domains** → **lab.lan** → **Group Policy Objects**
- Créer une nouvelle GPO nommée **Computer-Dpl-7zip**:
	- Dans l'onglet **Scope**, dans **Security Filtering**, supprime le groupe **Authenticated Users** et ajoute les groupes **GrpComputers7Zip** et **Domain Computers**
		- Dans l'onglet **Details**, comme c'est une GPO qui cible les ordinateurs, pour **GPO Status** sélectionne **User configuration settings disabled**

## Mise en place des éléments de la GPO

- Édite la GPO (bouton droit de la souris sur la GPO puis **Edit**). C'est une GPO "ordinateur" donc tu vas configurer la partie "Computer"
- Va dans **Computer Configuration**, puis **Policies** → **Software Settings** → **Software installation**
- Dans la partie de droite clic avec le bouton droit de la souris et fait **New** → **Package**
- Déplace toi dans le dossier partagé via le réseau, c'est-à-dire que tu ne vas pas dans `c:\Ressources` mais dans `\\winserv1\Ressources`!
```shell
Les cibles des GPO, que cela soit les utilisateurs et/ou les ordinateurs doivent pouvoir atteindre le dossier dans lequel tu as mis tes ressources.

Si tu mets c:\Ressources les cibles vont aller chercher les contenus sur leur propre système de fichiers, en local, sur lequel à priori le dossier Ressources n'existe pas !

Pour éviter cela, on indique le nom du dossier partagé sur le serveur, qui est visible sur le réseau.
```
- Une fois dans le dossier partagé, sélectionne le fichier installeur de 7Zip
- Dans la fenêtre suivante, tu as le choix entre **Assigned** et **Advanced**:

> **Assigned** valide directement le package  
> **Advanced** te permet de configurer le package

- Choisis **Advanced** et modifie le package comme ceci:
	- Nom: `7Zip`
		- Support information: Supprime l'URL
- Valide par **Ok** et sors de la GPO
```shell
En cliquant sur la GPO, tu trouve dans l'onglet Settings le résumé de la configuration de ta GPO
```

## Liaison de la GPO à une OU

- Clic avec le bouton droit de la souris sur l'OU **LabOrdinateurs**, et dans le menu sélectionne **Link an Existing GPO**, puis sélectionne la GPO **Computer-Dpl-7zip**
- Pour vérifier si la GPO est bien liée à l'OU, tu peux:
	- Cliquer sur l'OU, tu dois voir la GPO qui est liée
		- ou aller dans **Group Policy Objects**, sélectionner la GPO, et voir dans la partie **Links** l'OU avec laquelle est liée
```shell
Tu viens de créer ta première GPO de déploiement de logiciel et tu l'as liée à une OU en la filtrant avec un groupe !
```

## 🔬 Étape 3 - Déploiement de Firefox

De la même manière que la GPO d'installation de 7zip, créer une GPO pour l'installation de Firefox comme ceci:

- Elle se nomme **Computer-Dpl-Firefox**
- Fait en sorte qu'elle soit filtrée par le groupe **GrpComputersFirefox**
- Applique ce qui est nécessaire concernant le **GPO status**
- Fait en sorte qu'elle utilise le fichier d'installation de Firefox qui est dans le dossier partagé
- Lie cette GPO à l'OU **LabOrdinateurs** et vérifie que tous les paramètres sont bien présent

## 🔬 Étape 4 - Déploiement de Chrome

Comme tout à l'heure, créer une GPO pour l'installation de Chrome.  
Cette fois-ci tu va faire en sorte que l'installation se fasse au niveau des utilisateurs.

Pour cela:

- Elle se nomme **User-Dpl-Chrome**
- Fait en sorte qu'elle soit filtrée par les groupes **GrpUsersChrome** et **Domain Computers**
- Applique ce qui est nécessaire concernant le **GPO status**
- Fait en sorte qu'elle utilise le fichier d'installation de Chrome qui est dans le dossier partagé
- Utilise la nouvelle possibilité de déploiement **Published**
- Lie cette GPO à l'OU **LabUtilisateurs** et vérifie que tous les paramètres sont bien présent
```shell
Attention à bien faire le paramétrage dans la partie User Configuration de la GPO.
```

## ⚙️ Étape 5 - Mise en place d'un fond d'écran

## Fond d'écran global

- Créer une GPO **User-Interface-Wallpaper**
- Garde le groupe **Authenticated Users** en filtrage et modifie le **GPO Status**
- Une fois la GPO éditée, vas dans **User Configuration** → **Policies** → **Administrative Templates...** → **Desktop** → **Desktop**
- Active (avec **Enabled**) le paramètre **Desktop Wallpaper** en prenant le fichier **wallpaper\_blue.jpg** dans le dossier partagé **Ressources** du serveur
- Laisse le **Wallpaper Style**, valide par **Ok**, et sors de la GPO
- Lie cette GPO à l'OU **LabUtilisateurs**

## Fond d'écran spécifique

De la même manière:

- Crée une GPO **User-Interface-Wallpaper-Green**
- Filtre cette GPO avec les groupes **GrpUsersWallpaper-Green** et **Domain Computers**
- Utilise le fichier **wallpaper\_green.jpg**
- Lie cette GPO à l'OU **LabUtilisateurs**

## ⚙️ Étape 6 - Mise en place de restrictions d'accès

## Restriction d'accès au panneau de configuration

- Créer une GPO **User-Security-ControlPanel-Deny**
- Filtre cette GPO avec les groupes **GrpUsersWindowsRestrictions** et **Domain Computers**
- Une fois la GPO éditée, vas dans **User Configuration** → **Policies** → **Administrative Templates...** → **Control Panel**
- Active (avec **Enabled**) le paramètre **Prohibit access to Control Panel and PC settings**
- Valide par **Ok**, et sors de la GPO
- Lie cette GPO à l'OU **LabUtilisateurs**

## Restriction d'accès à l'explorateur de fichiers

De la même manière:

- Créer une GPO **User-Security-FileExplorer-Deny**
- Filtre cette GPO avec les groupes **GrpUsersWindowsRestrictions** et **Domain Computers**
- Une fois la GPO éditée, vas dans **User Configuration** → **Policies** → **Administrative Templates...** → **Windows Components** → **File Explorer**
- Active (avec **Enabled**) le paramètre **Hide these specified drives in My Computer**
- Sélectionne **Restrict C drive only**, valide par **Ok**, et sors de la GPO
- Lie cette GPO à l'OU **LabUtilisateurs**

## ⚙️ Étape 7 - Vérification des GPO avec une configuration utilisateur

## Résumé des GPO

| Nom de la GPO | Groupe de filtrage | OU sur laquelle elle est lié | Cible (utilisateurs ou ordinateurs) |
| --- | --- | --- | --- |
| User-Dpl-Chrome | GrpUsersChrome et Domain Computers | LabUtilisateurs | User 1 |
| User-Interface-Wallpaper | Authenticated Users | LabUtilisateurs |  |
| User-Interface-Wallpaper-Green | GrpUsersWallpaper-Green et Domain Computers | LabUtilisateurs | User2 |
| User-Security-ControlPanel-Deny | GrpUsersWindowsRestrictions et Domain Computers | LabUtilisateurs | User2 |
| User-Security-FileExplorer-Deny | GrpUsersWindowsRestrictions et Domain Computers | LabUtilisateurs | User2 |

## Vérification de l'application des GPO

```shell
Sur les clients, à partir d'un terminal cmd.exe, la commande gpresult /R vérifie que les GPO sont bien appliquée.

Si ce n'est pas le cas, tu peux forcer leur application avec la commande gpupdate /force.

Sur une session "normale", qui n'est pas administrateur local de ma machine, tu ne vois pas les GPO ordinateurs. Pour ça tu dois te connecter avec le compte administrateur local.
```
- Ouvre une session avec le compte `User1`
```shell
Ici le client n'a pas d'importance, que cela soit CLIENT1 ou CLIENT2, car les GPO sont sur la configuration utilisateur.
```
- Est-ce que toutes les GPO utilisateurs sont bien appliquées?
- Pourquoi les 3 GPO **User-Interface-Wallpaper-Green**, **User-Security-ControlPanel-Deny**, et **User-Security-FilesExplorer-Deny** sont refusées (et donc pas appliquées)?
- Est-ce que Chrome est installé?  
	C'est normal car rappelle-toi, tu l'as installé avec l'option `Published` (au lieu de **Assigned** ou **Advanced**), donc l'installation est publiée, elle est proposée à l'utilisateur.  
	Pour l'installer, va dans le panneau de configuration, puis dans **Programmes et fonctionnalités**, et clic dans la colonne de gauche dans **Installer un programme à partir du réseau**.  
	Là tu as une icone **Google Chrome**. En la sélectionnant, tu as une option **Installer** qui apparaît. En cliquant dessus, tu installe l'application. Après l'installation, l'icone de Chrome est sur le bureau de l'utilisateur.
- Maintenant, ouvre une session avec `User2`
- Vérifie l'application des GPO pour cet utilisateur
- As-tu accès au panneau de configuration?
- De même, accède-tu via l'explorateur de fichiers au lecteur c:?  
	Ici, tu n'a fait que *cacher* l'accès au lecteur C. En effet, si tu mets `c:` dans la barre d'URL (en haut) dans l'explorateur de fichiers, tu accède de nouveau au lecteur C... 😕  
	Retourne sur le DC, dans la GPO **User-Security-FileExplorer-Deny** ajoute les paramètres suivants:
	- **User Configuration** → **Policies** → **Administrative Templates** → **Windows Components** → **File Explorer**
		- Trouve et double-clique sur **Prevent access to drives from My Computer**
		- Dans la fenêtre qui s'ouvre, sélectionne `Enabled` et dans le menu déroulant selectionne `Restrict C drive only`
		- Valide et sors de la GPO
		- Modifie le nom de la GPO par **User-Security-C\_Drive-Deny**
		- Vérifie sur ton client (après un `gpupdate /force`) que le nom de la GPO a bien changé et que le lecteur C n'est plus accessible.
- Toujours sur cette session `User2` est-ce que le fond d'écran a changé?  
	Si ce n'est pas le cas, cela est probablement dû à l'ordre des GPO. En effet, si la GPO **User-Interface-Wallpaper** a un `Link Order` inférieur à la GPO **User-Interface-Wallpaper-Green**, elle s'appliquera toujours en dernier, et donc ecrasera les modifications de la première.
	- Sur le DC, sur l'OU **LabUtilisateurs**, modifie l'ordre des GPO pour que la GPO **User-Interface-Wallpaper-Green** s'applique après la GPO \*\* **User-Interface-Wallpaper**
		- Vérifie sur le client que le fond d'écran a bien changé

## ⚙️ Étape 8 - Vérification des GPO avec une configuration ordinateur

## Résumé des GPO

| Nom de la GPO | Groupe de filtrage | OU sur laquelle elle est lié | Cible (utilisateurs ou ordinateurs) |
| --- | --- | --- | --- |
| Computer-Dpl-7Zip | GrpComputers7Zip et Domain Computers | LabOrdinateurs | CLIENT1 |
| Computer-Dpl-Firefox | GrpComputersFirefox et Domain Computers | LabOrdinateurs | CLIENT2 |

## Vérification de l'application des GPO

Vérifie que 7zip est installé sur **CLIENT1** et que Firefox est installé sur **CLIENT2**.

## 🏆 Conclusion

Tu peux valider cet atelier si toutes tes GPO son bien appliquées selon tes clients et tes utilisateurs.

Quête terminée le **mercredi 07 janvier 2026**