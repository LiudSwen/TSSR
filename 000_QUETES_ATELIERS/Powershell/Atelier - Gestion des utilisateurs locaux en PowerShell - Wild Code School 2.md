---
title: "Atelier - Gestion des utilisateurs locaux en PowerShell - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/3954/pages/18530"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
PowerShell

## Atelier - Gestion des utilisateurs locaux en PowerShell

Moyen

2h

Auto-validation

PowerShell

## Atelier - Gestion des utilisateurs locaux en PowerShell

## Accès aux comptes locaux du système

- Afficher les comptes locaux:
```powershell
1
PS C:\Users\wilder> Get-LocalUser
```
- Recherche d'un compte

Exécute la commande suivante:`Get-LocalUser -Name <Nom d'utilisateur>` en mettant à la place de `<Nom d'utilisateur>` un nom de compte existant.  
Qu'est-ce qui s'affiche?  
Réessaye avec un compte qui n'existe pas. Quelle différence vois-tu?

On peut aussi utiliser la méthode **ADSI**.  
Créer un fichier **RechercheExistenceCompte-MethodeADSI.ps1**.  
Copie le code PowerShell ci-dessous dans ce fichier.

```powershell
1
#RechercheExistenceCompte-MethodeADSI.ps1
2

3
#La variable $ErrorActionPreference est initialisée à la valeur par défaut
4
$ErrorActionPreference = "Continue"
5
$Nom = Read-Host -Prompt "Saisir un nom de compte local"
6
$Compte = [ADSI]"WinNT://./$Nom"
7
If ($Compte.Path)
8
{
9
    Write-Host "Le compte $($Compte.FullName) existe" -ForegroundColor Green
10
}
11
Else
12
{
13
     Write-Host "Le compte $Nom n'a pas été trouvé" -ForegroundColor Red
14
}
```

Exécute ce script avec un compte existant, puis inexistant.

> Remarque:  
> L’accès à la base locale de comptes utilisateurs d’un système Windows est ici réalisé avec l’instruction: **\[ADSI\]"WinNT://."**

Pour la nomenclature:

- Les majuscules et les minuscules doivent être respectées
- Le point `.` représente le nom du système sur lequel est lancée l’instruction, il peut être remplacé par le nom de l’ordinateur cible
- Il faut des droits d’administration sur un ordinateur distant pour une utilisateion à distance
- Pour filtrer les éléments de la base de comptes, il est possible de spécifier le nom de l’élément recherché:
	- Ici il est contenu dans la variable `$nom`: `[ADSI]"WinNT://./$nom"`
```powershell
Les variables seront vue plus tard dans la formation.
```

Affiche les propriétés de la variable `$compte`:

```powershell
1
PS C:\Users\wilder> $compte | Get-Member
```

Dans le volet de sortie, on peut voir les méthodes et propriétés de la variable `$Compte`.

***A faire:***  
Modifie le script **RechercheExistenceCompte-MethodeADSI.ps1** pour afficher 3 autres propriétés de ton choix.

### Atelier - Gestion des utilisateurs locaux en PowerShell

2h