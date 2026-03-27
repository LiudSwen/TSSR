---
title: "Atelier - Gestion des utilisateurs locaux en PowerShell - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/3954/pages/18531"
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

## Ajout d’un compte local

Créer un fichier **AjoutCompteLocal.ps1** et utilise le code ci-dessous:

```powershell
1
#AjoutCompteLocal.ps1
2
#Ajoute un compte dans la base local du système
3
$Local = [ADSI]"WinNT://."
4
$Nom = Read-Host -Prompt "Saisir un nom de compte local"
5
$Description = Read-Host -Prompt "Saisir une description"
6
$Compte = [ADSI]"WinNT://./$Nom"
7
If (!$Compte.Path)
8
{
9
    $Utilisateur = $Local.Create("User",$Nom)
10
    $Utilisateur.InvokeSet("Description",$Description)
11
    $Utilisateur.CommitChanges()
12
    Write-Host "$Nom ajouté"
13
}
14
Else
15
{
16
    Write-Host "$Nom existe déjà"
17
}
```

**Remarques**:

- Ici on utilise des méthodes de programmation objet pour gérer les utilisateurs
- La variable **$local** possède une méthode `Create()`:
	- Format: `Create("User", $Var)` où `$Var` est une variable contenant une étiquette de nom à créer
		- Cela permet de créer un objet de type **user** (premier paramètre), dont le nom du compte est spécifié par le deuxième paramètre, ici la variable `$nom`
- On demande d'abord 2 propriétés: le **nom d'utilisateur** qui sera stocké dans la variable `$Nom`, et la **description de l'utilisateur** qui sera stockée dans `$Description`
- Le résultat est une variable nommée `$utilisateur`
- Cette variable possède une méthode `InvokeSet()` qui permet de renseigner une information du compte:
	- Format: `InvokeSet("Description", $Var)` où `$Var` est une variable contenant la chaîne de description
		- Cela permet de modifier l'attribut **description** de l'objet **user** créée plus haut (premier paramètre), dont la valeur est contenue dans le deuxième, ici `$description`
- La méthode `CommitChanges()` valide les changements effectués sur l'objet `$User`

***A faire:***

- Tester le script en ajoutant un compte avec une description associée, par exemple avec un compte **Wilder1** et une description **test de création de compte**
- Afficher les comptes locaux pour vérifier que le compte est bien crée
- Modifier le script pour ajouter d'autres propriétés
- Relancer le script pour vérifier que le compte est bien créé.

### Atelier - Gestion des utilisateurs locaux en PowerShell

2h