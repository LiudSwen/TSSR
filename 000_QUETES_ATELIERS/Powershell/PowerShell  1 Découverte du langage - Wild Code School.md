---
title: "PowerShell : 1 Découverte du langage - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2006/pages/10397"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
PowerShell

## PowerShell: 1 Découverte du langage

Découverte du langage PowerShell

Facile

3 pairs

PowerShell

## PowerShell: 1 Découverte du langage

```shell
Introduction
```

**Windows PowerShell**, est une suite logicielle développée par Microsoft pour les systèmes Windows qui intègre une interface en ligne de commande (un **terminal**), un langage de script nommé **PowerShell** ainsi qu'un kit de développement (un **SDK**). Il s'appuie sur le framework Microsoft.NET.  
C'est un langage de script fondé sur la programmation orientée objet. Il est différent des langages Linux, comme le Bash, qui ne sont pas orientés objet mais plutôt flux de texte à décomposer et à interpréter.

## 🎯 Objectifs:

✅ Découvrir le langage Windows Powershell  
✅ Savoir ce qu'est la programmation orienté objet  
✅ Manipuler les **cmdlet**

## Sommaire

- [📕 Un peu d'histoire!](https://odyssey.wildcodeschool.com/quests/2006/pages/10397#-un-peu-dhistoire-)
- [📗 PowerShell et programmation orientée objet](https://odyssey.wildcodeschool.com/quests/2006/pages/10397#-powershell-et-programmation-orient%C3%A9e-objet)
	- [Le langage](https://odyssey.wildcodeschool.com/quests/2006/pages/10397#le-langage)
		- [La programmation orientée Objet](https://odyssey.wildcodeschool.com/quests/2006/pages/10397#la-programmation-orient%C3%A9e-objet)
		- [Un outil: Visual Studio Code](https://odyssey.wildcodeschool.com/quests/2006/pages/10397#un-outil--visual-studio-code)
- [⌨️ Commencer à écrire du code](https://odyssey.wildcodeschool.com/quests/2006/pages/10397#%EF%B8%8F-commencer-%C3%A0-%C3%A9crire-du-code)
	- [Le terminal PowerShell et son éditeur](https://odyssey.wildcodeschool.com/quests/2006/pages/10397#le-terminal-powershell-et-son-%C3%A9diteur)
		- [Les instructions de commande](https://odyssey.wildcodeschool.com/quests/2006/pages/10397#les-instructions-de-commande)
		- [Une commande utile: Get-Help](https://odyssey.wildcodeschool.com/quests/2006/pages/10397#une-commande-utile-get-help)
- [💪 Challenge](https://odyssey.wildcodeschool.com/quests/2006/pages/10397#-challenge)
	- [🧐 Critères d'acceptation](https://odyssey.wildcodeschool.com/quests/2006/pages/10397#-crit%C3%A8res-dacceptation)

## 📕 Un peu d'histoire!

La 1ère version beta date de 2005. Ensuite, il a été inclus nativement dans Windows 7 et Windows 2008 Server. Il est possible d'installer Powershell sur des [versions antérieurs](https://www.tutos.eu/4088).  
Il existaient déjà beaucoup de langages de script sur les systèmes Microsoft:

- **Le batch** (ne pas confondre avec **Bash** sur Linux!)
- **Le Visual Basic Scipt** (ou VBS)
- **Le Windows Management Instrumentation** (ou WMI)

PowerShell a été crée par Microsoft dans le but de réunifier tout ces langages.  
Enfin, de la même manière que l'on peut faire du Bash sur Windows, on peut faire du PowerShell sur Linux.

## 📗 PowerShell et programmation orientée objet

## Le langage

Le PowerShell est un langage de script. Un langage de script ne nécessite pas d'étape de compilation (traduction d'un programme, écrit et lisible par un humain, en un programme exécutable par un ordinateur) et est plutôt **interprété**. Par exemple, un programme en langage C doit être compilé avant d'être exécuté, alors qu'un langage de script tel que PowerShell, Bash ou même Python n'a pas besoin d'être compilé.  
PowerShell fonctionne sur les OS Windows, Linux, et Mac.

Une vidéo pour découvrir le langage:

## La programmation orientée Objet

**En PowerShell tout est objet!**

Tu vas découvrir de nouveaux termes comme **classe**, **attribut**, et **méthode**.

Faisons un parallèle avec une voiture:

| Caractéristiques | Exemples |
| --- | --- |
| Classe | Voiture |
| Attributs | couleur, vitesse,... |
| Méthode | rouler () |

- La **classe** est ici `voiture`, mais on pourrait mettre vélo ou camion
- Les **attributs** définissent l'objet, ici on trouve la `couleur` et la `vitesse`, mais on pourrait rajouter le nombre de roues, s'il y a la radio, etc.  
	Chaque attribut a une valeur et l'ensemble de ces valeurs constituent les **propriétés** de l'objet.
- Les **méthodes** sont les possibilités de cet objet. Ici on a `rouler()`. Dans le cas d'un avion on aurait **voler()**, pour un bateau **naviguer()**.

Dans cet exemple, on a donc une voiture considérée comme un objet, avec les caractéristiques suivantes:

- Attributs:
	- Couleur --> valeur: rouge
		- vitesse --> valeur: 100 km/h
- Méthodes:
	- Rouler()

## Un outil: Visual Studio Code

Visual Studio Code est un éditeur de code extensible développé par Microsoft pour Windows, Linux et macOS. Les fonctionnalités incluent la prise en charge du débogage, la mise en évidence de la syntaxe, la complétion intelligente du code, les snippets, la refactorisation du code, et Git intégré.  
Avec cet éditeur on peut écrire du code PowerShell.

Sur le site officiel tu as les ressources et des tuto pour l'installer.

```shell
Site officiel de Visual Studio CodeSur ce site tu auras toutes les ressources d'installation de ce logicielhttps://code.visualstudio.com
```

![copie d'ecran de visual studio code](https://devblogs.microsoft.com/wp-content/uploads/sites/29/2019/02/2-HSG-0112171.png)

## ⌨️ Commencer à écrire du code

## Le terminal PowerShell et son éditeur

```shell
WindowsLinuxMac
PowerShell et son terminal sont installés nativement
L'éditeur PowerShell ISE est disponible nativement
```

## Les instructions de commande

Ces instructions de commandes sont généralement appelées **command-lets** (ou ***cmdlets***).  
Ce sont des commandes PowerShell natives. Elles sont contenues dans des modules PowerShell.  
On peut augmenter le nombre de cmdlets suivant les besoin en ajoutant des modules.

Les cmdlets sont écrite sous la forme **verbe-nom**:

- Le verbe identifie l'action qui sera effectuée:
	- `Get` va récuperer des informations sur une ressource
		- `New` va créer une nouvelle ressource
		- `Remove` va supprimer une ressource
- Le nom identifie la ressource:
	- `Module` indique que la ressource est un module
		- `ADUser` indique que la ressource est un utilisateur Active Directory
		- `Mailbox` indique que la ressource est une boite aux lettres de messagerie

Quelques exemples:

- `Get-Location` donne l'emplacement courant.
- `New-File` va créer un nouveau fichier
- `Remove-ADUser` va supprimer un utilisateur de l'Active Directory
```shell
Documentation officielle Microsoft sur PowerShellSur ce site tu auras toutes les ressources sur ce langagehttps://learn.microsoft.com/fr-fr/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands?view=powershell-7.4
```

## Une commande utile: Get-Help

Le cmdlet `Get-Help` donne l'aide sur une commande.

```powershell
1
Get-Help Get-Process
```

Affiche le manuel d'utilisation de la commande `Get-Process`

```powershell
1
Get-Help Get-Process -Online
```

Ouvre la page web dans le navigateur par défaut sur la page d'aide du cmdlet.

## 💪 Challenge

Trouve les commandes PowerShell qui correspondent aux commandes Linux (shell bash) suivantes:

- cp
- rm
- cd
- mkdir
- man
- history
- alias
- cat

Publie le résultat de tes recherches au format Markdown dans l'éditeur intégré sous la forme:

- La liste des commandes unix et leur équivalent
- Les commandes PowerShell que tu as utilisées pour faire tes recherches

Pour apprendre rapidement à utiliser Markdown rapidement si ce n'est déjà fait, tu peux t'appuyer sur [ce tuto](https://www.markdowntutorial.com/).

Et pour des informations un peu plus complète, tu peux regarder sur [ce guide](https://www.markdownguide.org/)

## 🧐 Critères d'acceptation

Le texte posté:

- Est dans une syntaxe Markdown correcte
- Contient les commandes unix et les commandes PowerShell équivalente écrite en entier, pas avec des noms courts d'alias.
- Contient les lignes de commandes utilisées pour trouver les cmdlets PowerShell

Solution postée le **lundi 27 octobre 2025**

[https://gist.github.com/LiudSwen/85e0637ebde2ab39307838c1495ab428](https://gist.github.com/LiudSwen/85e0637ebde2ab39307838c1495ab428)