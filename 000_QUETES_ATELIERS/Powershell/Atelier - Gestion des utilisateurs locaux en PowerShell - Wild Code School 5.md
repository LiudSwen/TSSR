---
title: "Atelier - Gestion des utilisateurs locaux en PowerShell - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/3954/pages/18533"
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

## Suppressions de comptes utilisateurs

Créer un fichier **SuppressionComptes.ps1** et utilise le code ci-dessous:

```powershell
1
# SuppressionComptes.ps1
2
$Local = [ADSI]"WinNT://."
3
#changer le nom du dossier
4
$Fichier = "c:\xxx\comptes.txt"
5
If (Test-Path -Path $Fichier)
6
{
7
    $Lignes = Get-Content -Path $Fichier
8
    Foreach ($Ligne in $Lignes)
9
    {
10
        $TabCompte = $Ligne.Split("/")
11
        $Nom = $TabCompte[0]
12
        $Compte = [ADSI]"WinNT://./$Nom"
13
        If ($Compte.path)
14
        {
15
            $Local.delete("user",$Nom)
16
            Write-Host "$Nom supprimé"
17
        }
18
        Else
19
        {
20
            Write-Host "$Nom n'existe pas"
21
        }
22
    }
23
}
24
Else
25
{
26
    Write-Host "$Fichier non-trouvé" -ForegroundColor Red
27
}
```

Que fait-il?

- Ce script permet de supprimer tous les comptes utilisateurs dont les noms sont contenus dans un fichier texte
- Les informations sont toujours sous la forme: `nomCompte/nomComplet/Description`

> Remarques:  
> Comme pour la création, la variable `$local` possède une méthode `delete()` qui permet de supprimer un objet de type **user**.

***A faire:***

- Exécuter le script et vérifier la liste des noms affichés
- Afficher les comptes pour vérifier que les comptes du fichier Comptes1.txt ont bien été supprimé
- Modifier le fichier **Comptes.txt** en y ajoutant les comptes crées au **4**
- Relancer le script et vérifier si tous les comptes créés dans cet atelier ont été supprimés

Si tu es arrivé au bout de cet atelier, tu viens d'avoir une première approche de la gestion des comptes locaux en Powershell!

Quête terminée le **lundi 08 décembre 2025**

### Atelier - Gestion des utilisateurs locaux en PowerShell

2h