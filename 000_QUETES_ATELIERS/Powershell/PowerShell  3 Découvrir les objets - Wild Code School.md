---
title: "PowerShell : 3 Découvrir les objets - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2030/pages/6531"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
PowerShell

## PowerShell: 3 Découvrir les objets

Moyen

3 pairs

PowerShell

## PowerShell: 3 Découvrir les objets

\*\*⚠️ Avant de commencer cette quête, tu dois avoir terminé la quête suivante:\*\*  

```shell
PowerShell : 1 Découverte du langageDécouverte du langage PowerShellVoir la quête - PowerShell : 1 Découverte du langage
```

## Introduction

On peut utiliser PowerShell comme un shell classique mais la gestion des objets est une des forces de ce langage. Regardons ça de plus près.

![image](https://microsofttouch.fr/cfs-file/__key/communityserver-blogs-components-weblogfiles/00-00-00-00-70/20780.logo_2D00_powershell.png)

## 🤓 Objectifs:

✅ Manipuler les propriétés d'objet  
✅ Connaître la notion de variable  
✅ Savoir utiliser une méthode (Get-Type)

## 💻 Quel OS je peux utiliser?

Quel que soit l'OS (Windows, Linux, ou bien Mac OS), tu peux exécuter les commandes ci-dessous.

```shell
Suivant l'OS que tu utiliseras, les fichiers ou dossiers affichés ne seront pas les même.
```

## 😌 Quelle console prendre?

```shell
WindowsMacLinux
L'éditeur natif PowerShell ISE
Le terminal PowerShell
Un éditeur externe comme Visual Studio Code par exemple
```

### Ce qui va suivre va être exécuté sous l'OS Windows, avec l'éditeur natif PowerShell ISE.

## 💻 Lancement de l’éditeur

- Aller dans le menu démarrer
- Chercher ***Windows Powershell ISE***
- La console se lance
- La partie **bleue** (en bas) est le terminal, la partie **blanche** (en haut) est la console de Script
- Aller dans le menu **Afficher** puis cliquer sur **Afficher le volet de script** pour afficher/masquer la partie blanche en haut

## ⌨️ Premières commandes

- Dans le terminal, taper `Get-Host`.
```powershell
1
Get-Host
```

Ce qui donne en résultat:

```shell
Name             : Windows PowerShell ISE Host
 Version          : 5.1.22000.613
 InstanceId       : f65cc4db-0fe5-418a-88ec-62db0bcb2fdf
 UI               : System.Management.Automation.Internal.Host.InternalHostUserIn
                    terface
 CurrentCulture   : fr-FR
 CurrentUICulture : fr-FR
 PrivateData      : Microsoft.PowerShell.Host.ISE.ISEOptions
 DebuggerEnabled  : True
 IsRunspacePushed : False
 Runspace         : System.Management.Automation.Runspaces.LocalRunspace
```

`Version          : 5.1.22000.613` indique la version du PowerShell installé.

- Maintenant taper `Get-Host | Select-Object -Property Version`
```powershell
1
Get-Host | Select-Object -Property Version
```

Voici le résultat:

```shell
Version      
-------      
5.1.22000.613
```

**📖 Explications:**

- Nous avons ici 2 commandes, tout d'abord `Get-Host` puis `Select-Object` séparée par un `|` que l'on appelle un **pipe**.
- La 1ère commande (`Get-Host`) sort un résultat qui s'affiche dans la console (voir le résultat quelques lignes plus haut).
- Sans le pipe, le résultat s'affiche
- Avec le pipe, ce résultat de commande est mis en entrée de la commande suivant pipe, donc ici `Select-Object`
- La commande `Select-Object` sert à sélectionner des objets ou des propriétés d'objets
- Ici on utilise le paramètre `-Property` et on lui donne la valeur `Version`
- On peut traduire la commande après le pipe par ***Sélectionne la propriété dont le nom est Version***
- La seule ligne correspondante est **Version: 5.1.22000.613** d'où l'affichage de sortie
```shell
Sans le savoir, tu viens de manipuler ton 1er objet PowerShell !
```

**🔍 Regardons de plus près:**

- La méthode `GetType()` donne le type de donnée actuel d'une valeur.  
	Par exemple, s'agit-il du type **String**, **Booléen**, ou encore **Objet**.
- Tape la commande `(Get-Host).GetType()`
```powershell
1
(Get-Host).GetType()
```

Le résultat ne donne pas la même chose que tout à l'heure:

```shell
IsPublic IsSerial Name                                     BaseType                                                                                                 
-------- -------- ----                                     --------                                                                                                 
False    False    InternalHost                             System.Management.Automation.Host.PSHost
```

**📖 Explications:**

- L'application de la méthode `GetType()` à la commande `Get-Host` va nous donner le type de variable représentée par la commande `Get-Host`. On met des parentèses autour de `Get-Host` car `GetType` va s'appliquer sur le contenu à l'interieur.
- Ici le type de variable est **InternalHost** qui est un type système.
- Maintenant, tape la commande `(Get-Host | Select-Object -Property Version).GetType()`
```powershell
1
(Get-Host | Select-Object -Property Version).GetType()
```

Le résultat est:

```shell
IsPublic IsSerial Name                                     BaseType                                                                                                 
-------- -------- ----                                     --------                                                                                                 
True     False    PSCustomObject                           System.Object
```

**📖 Explications:**

- Ici on voit que toute la suite de commande `Get-Host | Select-Object -Property Version` est de type **PSCustomObject**, donc un objet PowerShell
- Dans le cas présent, on a **instancié** un objet de classe **PSCustomObject**
- Pour le montrer, taper la commande `(Get-Host | Select-Object -Property Version).Version`
```powershell
1
(Get-Host | Select-Object -Property Version).Version
```

Voici le résultat:

```shell
Major  Minor  Build  Revision
-----  -----  -----  --------
5      1      22000  613
```

Ici on a demandé d'afficher l'attribut **Version** de l'objet de classe **PSCustomObject** qui est `(Get-Host | Select-Object -Property Version)`

```shell
Cette manière d'instancier des objets est très courante en shell PowerShell.

Cela permet d'avoir rapidement des informations et de les stocker.
```

Exemple pour afficher différemment la version du PowerShell:

```powershell
1
$ObjVersion = (Get-Host | Select-Object -Property Version).Version
2
$ObjVersion | Format-List -Property *
```

Ici on enregistre le résultat de `(Get-Host | Select-Object -Property Version).Version` dans la variable `$ObjVersion`  
Ensuite on demande d'afficher ce résultat (contenu dans la variable `$ObjVersion`) sous forme de liste avec la commande `Format-List`.  
Voici le résultat:

```shell
Major         : 5
Minor         : 1
Build         : 22000
Revision      : 613
MajorRevision : 0
MinorRevision : 613
```

Pour enregistrer les valeurs dans des variables, on peut utiliser le code suivant:

```powershell
1
$ObjVersion = (Get-Host | Select-Object -Property Version).Version
2
$ObjVersionMajor = $ObjVersion.Major
3
$ObjVersionMinor = $ObjVersion.Minor
4
$ObjVersionBuild = $ObjVersion.Build
5
$ObjVersionRevision = $ObjVersion.Revision
6
$ObjVersionMajorRevision = $ObjVersion.MajorRevision
7
$ObjVersionMinorRevision = $ObjVersion.MinorRevision
```

Qui n'affichera rien car on ne fait qu'enregistrer dans des variables!

- Pour affiche la version majeure:
```powershell
1
$ObjVersionMajor
```

Donnera:

```shell
5
```

---

## 💪 Challenge

- Après avoir ouvert un éditeur PowerShell, faire les actions ci-dessous:
```powershell
1
Start-Process calc.exe
2
Start-Sleep -Seconds 1
3
Start-Process calc.exe
4
$AllProcess = Get-Process
```
- Ce code va:
	- Lancer 1 fois la calculatrice
		- faire une pause d'1 second dans l'exécution du script
		- Lancer 1 fois la calculatrice
		- Stocker dans une variable `$AllProcess` tous les processus qui sont exécutés.

---

## 🤓 Petite aide pour la suite!

- ## Where-Object
```powershell
1
Set-Location c:\
2
Get-ChildItem | Where-Object {$_.Name -like "*program*"}
```
- Cette ligne de code:
	- Place le répertoire courant dans c:\\
		- Lance la commande `GetChildItem` qui affiche le contenu d'un répertoire
		- Le pipe `|` envoie la sortie standard de la commande `GetChildItem` dans l'entrée standard de la commande `Where-Object`
		- La commande `Where-Object {$_.Name -like "*program*"}` va filtrer les lignes dont l'attribut **Name** contient la chaine de caractères **program**.  
		Tu vois ici une des utilisations des wildcards, ici l'étoile \*.
- Le résultat:
```shell
Répertoire : C:\

Mode                 LastWriteTime         Length Name                                                                                                              
----                 -------------         ------ ----                                                                                                              
d-r---        16/05/2022     13:35                Program Files                                                                                                     
d-r---        13/05/2022     11:12                Program Files (x86)
```

---

- En t'aidant de l'aide ci-dessus:
	- Trouve la ligne de commande qui permettra d'avoir à l'écran les différentes lignes de processus qui contiennent **"calc"**
		- Il y a 2 méthodes différentes: à partir de la variable `$AllProcess` et à partir de la recherche direct avec la commande `Get-Process`

Une fois la tâche réalisée, pour partager ton résultat:

- Récupère l'historique des commandes que tu as tapées avec `Get-History`
- Partage cet historique via la fenêtre de texte de cette quête

## 🧐 Critères d'acceptation

L'historique de commandes fourni permet bien d'afficher uniquement les processus correspondant à la calculatrice

Solution postée le **lundi 27 octobre 2025**

Get-History

```shell
8 Get-Process | Where-Object {$_.Name -like "*calc*"}                                                                    
 9 $AllProcess | Where-Object {$_.Name -like "*calc*"}
```

Get-Process

```shell
PS C:\Users\chica> Get-Process | Where-Object {$_.Name -like "*calc*"}

Handles  NPM(K)    PM(K)      WS(K)     CPU(s)     Id  SI ProcessName                                                       
-------  ------    -----      -----     ------     --  -- -----------                                                       
    709      48    63964      98928       0.44  24636   9 CalculatorApp                                                     
    709      48    62068      98180       0.48  30580   9 CalculatorApp
```

$AllProcess

```shell
PS C:\Users\chica> $AllProcess | Where-Object {$_.Name -like "*calc*"}

Handles  NPM(K)    PM(K)      WS(K)     CPU(s)     Id  SI ProcessName                                                       
-------  ------    -----      -----     ------     --  -- -----------                                                       
     39       7     1080       5152             11460   9 calc                                                              
    713      48    64564      99700       0.50  24636   9 CalculatorApp
```