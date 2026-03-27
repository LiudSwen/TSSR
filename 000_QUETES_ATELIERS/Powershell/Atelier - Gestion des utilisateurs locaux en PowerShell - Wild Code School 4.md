---
title: "Atelier - Gestion des utilisateurs locaux en PowerShell - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/3954/pages/18532"
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

## Ajout d'utilisateurs par fichier

Créer un fichier **CreationDossier.ps1** et utilise le code ci-dessous:

```powershell
1
#CreationDossier.ps1
2
$Dossier = "DossierTemporaire" #Changer le nom
3
If (Test-Path "c:\$Dossier")
4
{
5
    Write-Host "Le dossier $Dossier existe déjà"
6
}
7
Else
8
{
9
    New-Item -Path "c:\$Dossier" -ItemType Directory
10
}
```

Que fait ce script?

- Si le dossier n'existe pas, le script va créer automatiquement un dossier sous la racine C: de Windows
- On utilise la variable `$Dossier` qui contient le nom du dossier

***A faire:***

- Modifie le code pour que le nom du dossier soit demandé à l'utilisateur

**Pour la suite:**

- Créée un fichier **Comptes.txt** et mets le dans un dossier de ton choix
- Copie le contenu ci-dessous dans ce fichier:
```shell
"jhenry"/"Jean Henry"/"Comptable"
"dlarry"/"David Larry"/"Comptable"
"jlanvin"/"Jerome Lanvin"/"Secrétaire"
"sforest"/"Sébastien Forest"/"Informaticien"
"klaurry"/"Kevin Laurry"/"Commercial"
"mchollet"/"Mathieu Chollet"/"Commercial"
"joffstater"/"Jennifer Offstater"/"Commercial"
"npillet"/"Nicolas Pillet"/"Commercial"
"rfarry"/"Remy Farry"/"Directeur"
"nlehello"/"Norbet Lehello"/"Commercial"
```
- Tu as maintenant un fichier **comptes.txt** dont les informations sont sous la forme: **nomCompte/nomComplet/Description**

Créer un fichier **LectureFichier.ps1** et utilise le code ci-dessous:

```powershell
1
#LectureFichier.ps1
2
$Fichier = "c:\xxx\comptes.txt" #Ici tu dois remplacer xxx par le nom du dossier dans lequel tu as mis ton fichier comptes.txt
3
If (Test-Path $Fichier)
4
{
5
    $Lignes = Get-Content -Path $Fichier
6
    Foreach ($Ligne in $Lignes)
7
    {
8
        $TabCompte = $Ligne.Split("/")
9
        Write-Host $TabCompte[0]
10
    }
11
}
12
Else
13
{
14
    Write-Host "Fichier $Fichier non-trouvé"
15
}
```

**Remarques**

- `Foreach`: Cette instruction peut s’interpréter de la manière suivante:
	- Pour chaque ligne `$Ligne` contenue dans le tableau `$Lignes`, la variable `$ligne` va successivement prendre la valeur de chaque ligne du tableau
- `$ligne` est une chaîne de caractères
- La variable `$ligne` possède une méthode `Split()` qui permet de retourner un tableau construit à partir de la chaîne de caractères contenue dans `$ligne`
- Les éléments du tableau correspondent aux chaînes de caractères délimitées par le séparateur `/`

***A faire:***

- Par rapport à ce qui vient de s'afficher, modifier le script pour que le nom complet et la description soient également affichés en dessous du nom du compte
- En utilisant les 2 scripts **AjoutCompteLocal.ps1** et **LectureFichier.ps1** écrire un script:
	- Il va lire le contenu d'un fichier qui contient des informations de comptes
		- Il va ajouter dans la base locale du système, tous les comptes trouvés
- Tester ce nouveau script pour ajouter tous les comptes du fichier **comptes.txt**
- Relancer le script une deuxième fois. Que se passe-t-il pour les comptes déjà existants?

### Atelier - Gestion des utilisateurs locaux en PowerShell

2h