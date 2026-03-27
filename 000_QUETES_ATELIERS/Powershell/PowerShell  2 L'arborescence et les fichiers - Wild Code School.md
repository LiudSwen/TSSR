---
title: "PowerShell : 2 L'arborescence et les fichiers - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2039/pages/6619"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
PowerShell

## PowerShell: 2 L'arborescence et les fichiers

Facile

3 pairs

PowerShell

## PowerShell: 2 L'arborescence et les fichiers

\*\*⚠️ Avant de commencer cette quête, tu dois avoir terminé la quête suivante:\*\*  

```shell
PowerShell : 1 Découverte du langageDécouverte du langage PowerShellVoir la quête - PowerShell : 1 Découverte du langage
```

## Introduction

Naviguer dans l'arborescence de fichiers en PowerShell et manipuler les fichiers est beaucoup plus rapide en ligne de commande qu'en mode graphique.  
Nous allons voir ça ensemble!

## 🤓 Objectifs:

- ✅ Comprendre comment afficher le contenu d'un répertoire
- ✅ Savoir se repérer dans l'arborescence
- ✅ Comprendre comment naviguer dans l'arborescence
- ✅ Connaître ce que sont les arguments ou les paramètres d'une commande

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
```shell
Ce qui va suivre va être exécuté sous l'OS Windows. Tu dois adapter les emplacements si tu exécute PowerShell sous un autre OS. De plus, les dossiers vu seront alors différents.
```

## 💻 Lancement de l'éditeur PowerShell ISE

- Chercher ***Windows Powershell ISE***
- La console se lance
- La partie **bleue** (en bas) est le terminal, la partie **blanche** (en haut) est la console de script
- Aller dans le menu **Afficher** puis cliquer sur **Afficher le volet de script** pour afficher/masquer la partie blanche en haut

## ⌨️ Premières commandes

- Dans le terminal, taper `Get-Location`.
```powershell
1
Get-Location
```

Ce qui donne en résultat:

```shell
Path          
----          
C:\Users\wilder
```

`Get-Location` donne l'emplacement courant. Soit ici `c:\Users\wilder` (si le nom que tu utilises pour te connecter à ton ordinateur est `wilder`)

- Maintenant, ecrire `Get-Host`
```powershell
1
Get-Host
```

On obtient:

```shell
Name             : Windows PowerShell ISE Host
Version          : 5.1.22000.653
InstanceId       : 7736a470-1f2b-4877-a5e4-9ded82c7ed00
UI               : System.Management.Automation.Internal.Host.InternalHostUserInterface
CurrentCulture   : fr-FR
CurrentUICulture : fr-FR
PrivateData      : Microsoft.PowerShell.Host.ISE.ISEOptions
DebuggerEnabled  : True
IsRunspacePushed : False
Runspace         : System.Management.Automation.Runspaces.LocalRunspace
```

Soit des indication sur l'hôte:

- La version de PowerShell
- La langue,...

## 📁 Changer le répertoire courant

- Maintenant, changeons l'emplacement courant à la racine: `C:\`

On utilise le cmdlet `Set-Location`

```powershell
1
Set-Location -Path C:\
```

Il ne se passe rien, mais le prompt indique `PS C:\>` au lieu de `PS C:\Users\wilder\>`.  
Pour vérifier, on peut réutiliser `Get-Location`:

```powershell
1
Get-Location
```

Résultat:

```shell
Path
----
C:\
```

Le répertoire courant a bien changé.

```shell
Note : il est possible de rappeler une commande précédente avec la touche flèche vers le haut ⬆️.
```

## 📁 Créer des dossiers

Utilisation du cmdlet `New-Item`:

```powershell
1
New-Item -Path Temp -ItemType Directory
```

On demande:

- Dans le répertoire courant, la création d'un répertoire
- son nom est `Temp`
```shell
Répertoire : C:\

Mode                 LastWriteTime         Length Name                                                                                                              
----                 -------------         ------ ----                                                                                                              
d-----        12/05/2022     18:03                Temp
```

Plaçons nous dans ce dossier:

```powershell
1
Set-Location Temp
```

Créons 2 dossiers Rep1 et Rep2:

```powershell
1
New-Item -Path Rep1 -ItemType Directory
```
```shell
Répertoire : C:\Temp

Mode                 LastWriteTime         Length Name                                                                                                              
----                 -------------         ------ ----                                                                                                              
d-----        12/05/2022     12:07                Rep1
```
```powershell
1
New-Item -Path Rep2 -ItemType Directory
```
```shell
Répertoire : C:\Temp

Mode                 LastWriteTime         Length Name                                                                                                              
----                 -------------         ------ ----                                                                                                              
d-----        12/05/2022     12:08                Rep2
```

## ⌨️ Lister le contenu d'un dossier

Aller dans le dossier `C:\Temp` si besoin

```powershell
1
Set-Location C:\Temp
```

Maintenant, utilisons la commande `Get-ChildItem`

```powershell
1
Get-ChildItem
```

Résultat:

```shell
Répertoire : C:\Temp

Mode                 LastWriteTime         Length Name                                                                                                              
    Répertoire : C:\Temp
d-----        12/05/2022     12:07                Rep1                                                                                                              
d-----        12/05/2022     12:12                Rep2
```

## 📄 Créer des fichiers

Nous utiliserons encore le cmdlet `New-Item` mais cette fois-ci avec la valeur `File` pour l'attribut `ItemType`:

```powershell
1
New-Item -Path file1 -ItemType File
```
```shell
Mode                 LastWriteTime         Length Name                                                                                                              
----                 -------------         ------ ----                                                                                                              
-a----        12/05/2022     12:15              0 file1
```

Créons 2 autres fichiers file2 et file3:

```powershell
1
New-Item -Path file2 -ItemType File
2
New-Item -Path file3 -ItemType File
```

Regardons le contenu du répertoire courant:

```powershell
1
Get-ChildItem
```

Résultat:

```shell
Répertoire : C:\Temp

Mode                 LastWriteTime         Length Name                                                                                                              
----                 -------------         ------ ----                                                                                                              
d-----        12/05/2022     12:07                Rep1                                                                                                              
d-----        12/05/2022     12:12                Rep2                                                                                                              
-a----        12/05/2022     12:15              0 file1                                                                                                             
-a----        12/05/2022     12:20              0 file2                                                                                                             
-a----        12/05/2022     12:20              0 file3
```

## 🧺 Déplacer des fichiers ou des dossiers

Nous utiliserons le cmdlet `Move-Item`.  
Déplaçons le fichier `file1` dans le dossier `Rep1`.

```powershell
1
Move-Item -Path file1 -Destination Rep1
```

Il ne se passe rien à l'écran. Avec `Get-ChildItem` on va vérifier que le fichier `file1` a bien été déplacé.

```powershell
1
Get-ChildItem
```
```shell
Répertoire : C:\Temp

Mode                 LastWriteTime         Length Name                                                                                                              
----                 -------------         ------ ----                                                                                                              
d-----        12/05/2022     12:25                Rep1                                                                                                              
d-----        12/05/2022     12:12                Rep2                                                                                                              
-a----        12/05/2022     12:20              0 file2                                                                                                             
-a----        12/05/2022     12:20              0 file3
```

Le fichier `file1` n'est plus là.  
Allons voir dans le dossier `Rep1`:

```powershell
1
Get-ChildItem -Path Rep1
```
```shell
Répertoire : C:\Temp\Rep1

Mode                 LastWriteTime         Length Name                                                                                                              
----                 -------------         ------ ----                                                                                                              
-a----        12/05/2022     12:15              0 file1
```
```shell
Utilisons l'attribut recurse pour voir tout le contenu d'un dossier, même des sous dossiers
```
```powershell
1
Get-ChildItem -Recurse
```

Ce qui donne:

```shell
Répertoire : C:\Temp

Mode                 LastWriteTime         Length Name                                                                                                              
----                 -------------         ------ ----                                                                                                              
d-----        12/05/2022     12:25                Rep1                                                                                                              
d-----        12/05/2022     12:12                Rep2                                                                                                              
-a----        12/05/2022     12:20              0 file2                                                                                                             
-a----        12/05/2022     12:20              0 file3                                                                                                             

    Répertoire : C:\Temp\Rep1

Mode                 LastWriteTime         Length Name                                                                                                              
----                 -------------         ------ ----                                                                                                              
-a----        12/05/2022     12:15              0 file1
```

Maintenant, déplaçons le dossier Rep1 dans le dossier Rep2:

```powershell
1
Move-Item -Path Rep1 -Destination Rep2
```

Avec un `Get-ChildItem` associé à `recurse` sur le dossier `C:\Temp`:

```powershell
1
 Get-ChildItem -recurse
```

On obtient:

```shell
Répertoire : C:\Temp

Mode                 LastWriteTime         Length Name                                                                                                              
----                 -------------         ------ ----                                                                                                              
d-----        12/05/2022     12:37                Rep2                                                                                                              
-a----        12/05/2022     12:20              0 file2                                                                                                             
-a----        12/05/2022     12:20              0 file3                                                                                                             

    Répertoire : C:\Temp\Rep2

Mode                 LastWriteTime         Length Name                                                                                                              
----                 -------------         ------ ----                                                                                                              
d-----        12/05/2022     12:25                Rep1                                                                                                              

    Répertoire : C:\Temp\Rep2\Rep1

Mode                 LastWriteTime         Length Name                                                                                                              
----                 -------------         ------ ----                                                                                                              
-a----        12/05/2022     12:15              0 file1
```

## 🗑️ Suppression de fichiers et dossiers

On va utiliser `Remove-Item`.  
Supprimons le fichier `file3`:

```powershell
1
Remove-Item -Path file3
```

Le fichier est supprimé et il ne se passe rien à l'écran.

Le procédé est le même pour la suppression de dossier ***vide***.  
Si le dossier n'est pas vide, il faut utiliser l'attribut ***recurse***:

```powershell
1
Remove-Item Rep2 -Recurse
```
```shell
AttentionIl n'y a pas de confirmation ni de mise à la corbeille des fichiers/dossiers supprimés.

Il n'est pas possible de récupérer un fichier ou un dossier supprimé.
```

## 📝 Quiz

```shell
# 1  - Le cmdlet Get-LocationDonne l'emplacement du répertoire courantModifie le répertoire distantModifie le répertoire courantDonne l'emplacement du répertoire distantValider# 2  -  Que va faire la commande suivante: New-Item -Path Rep4 -ItemType Directory ?Elle va créer un dossier Rep4 à la racine c:\Elle va créer un fichier nommé Rep4 à la racine c:\Elle va créer un dossier Rep4 dans le répertoire courantElle va créer un fichier Rep4 dans le répertoire courantValider# 3  -  Le cmdlet Get-HostDonne le nom du système d'exploitationDonne la version du PowerShellDonne le nom de l'ordinateurValider# 4  -  Quel cmdlet permet de changer l'emplacement du répertoire courant ?Change-LocationSet-LocationGet-LocationSet-DirectoryValiderTon score :0 / 4
```

---

## 💪 Challenge: Manipuler les fichiers et dossiers

- Copier le code ci-dessous dans la fenêtre script de PowerShell ISE et l'executer (F5):
```powershell
1
Set-Location -Path C:\
2
#Une écriture possible pour la création d'un dossier
3
New-Item -ItemType Directory -Path C:\ -Name FolderTest1
4
#Une autre écriture possible pour la création d'un dossier
5
New-Item -ItemType Directory -Path C:\FolderTest2
6
#Création de fichier vide dans le dossier c:\FolderTest
7
New-Item -ItemType File -Path C:\FolderTest1 -Name File1
8
New-Item -ItemType File -Path C:\FolderTest1 -Name File2
9
New-Item -ItemType File -Path C:\FolderTest1 -Name File3
10
New-Item -ItemType File -Path C:\FolderTest1 -Name File4
11
New-Item -ItemType File -Path C:\FolderTest1 -Name File5
12
#Création de fichier vide dans le dossier c:\FolderTest2
13
$Count = 6
14
Do
15
{
16
    New-Item -ItemType File -Path C:\FolderTest2 -Name "File$Count"
17
    $Count++
18
}
19
While ($Count -lt 11)
```
- Ce code va créer des dossiers et des fichiers:
	- Les fichiers File1 à File5 sont dans le dossier C:\\FolderTest1
		- Les fichiers File6 à File10 sont dans le dossier C:\\FolderTest2
- Ta tâche est la suivante:
	- Mettre les fichiers avec un numéro pair dans un dossier c:\\EvenFolder
		- Mettre les fichiers avec un numéro impair dans un dossier c:\\OddFolder

🤓 Pour rappel:

- `Copy-Item` copie un fichier ou un dossier d'un emplacement à un autre
- `Move-Item` déplace un fichier ou un dossier d'un emplacement à un autre
- `Remove-Item` Supprime un fichier ou un dossier
- `New-Item` crée un dossier ou un fichier
- `Get-ChildItem` liste le contenu d'un dossier

Une fois la tâche réalisée pour partager ton résultat:

- Récupère l'historique des commandes que tu as tapées avec `Get-History > historique.txt`
- Récupère le contenu des dossiers avec `Get-ChildItem -Path *Folder* -Recurse > listing.txt`
- Partage ces fichiers via une URL, par exemple via un gist, un dépôt github

## 🧐 Critères d'acceptation

Il devra y avoir 2 fichiers avec les informations suivantes:

1. Un fichier avec les différentes lignes de commandes
2. Un fichier avec le contenu de chacun des 2 dossiers **EvenFolder** et **OddFolder**, les dossiers **FolderTest1** et **FolderTest2** n'apparaissant pas parce qu'ils sont vides.

Solution postée le **lundi 27 octobre 2025**

[https://gist.github.com/LiudSwen/a20e92e39bb3e74761a9f2147e2bcf17](https://gist.github.com/LiudSwen/a20e92e39bb3e74761a9f2147e2bcf17)