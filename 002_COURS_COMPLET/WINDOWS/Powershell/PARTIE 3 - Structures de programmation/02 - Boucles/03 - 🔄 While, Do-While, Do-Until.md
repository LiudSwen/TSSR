

## 📋 Table des matières

```table-of-contents
title: 
style: nestedList # TOC style (nestedList|nestedOrderedList|inlineFirstLevel)
minLevel: 2 # Include headings from the specified level
maxLevel: 2 # Include headings up to the specified level
include: 
exclude: 
includeLinks: true # Make headings clickable
hideWhenEmpty: false # Hide TOC if no headings are found
debugInConsole: false # Print debug info in Obsidian console
```

---

## Introduction

Les boucles While, Do-While et Do-Until permettent d'exécuter du code de manière répétée tant qu'une condition est remplie (ou non remplie). Contrairement aux boucles For/ForEach qui itèrent sur une collection définie, ces boucles sont idéales quand :

- Le nombre d'itérations n'est pas connu à l'avance
- L'exécution dépend d'une condition dynamique
- Vous attendez qu'un état particulier soit atteint

> [!info] Différence fondamentale La principale différence entre ces trois boucles réside dans **quand** et **comment** la condition est évaluée.

---

## La boucle While

### 🎯 Concept

La boucle `While` teste la condition **avant** chaque itération. Si la condition est fausse dès le départ, le code ne s'exécute jamais.

### Syntaxe

```powershell
While (<condition>) {
    # Code à exécuter tant que la condition est vraie
}
```

### 📘 Explication détaillée

1. PowerShell évalue la condition entre parenthèses
2. Si la condition retourne `$true`, le bloc de code s'exécute
3. Après l'exécution du bloc, on retourne à l'étape 1
4. Si la condition retourne `$false`, on sort de la boucle

> [!example] Exemple pratique : Compte à rebours
> 
> ```powershell
> $compteur = 5
> 
> While ($compteur -gt 0) {
>     Write-Host "Décompte : $compteur"
>     $compteur--  # Décrémente de 1
>     Start-Sleep -Seconds 1
> }
> 
> Write-Host "Décollage ! 🚀"
> ```

> [!example] Exemple : Attendre qu'un service démarre
> 
> ```powershell
> $service = Get-Service -Name "Spooler"
> 
> While ($service.Status -ne "Running") {
>     Write-Host "Le service n'est pas démarré, attente..."
>     Start-Sleep -Seconds 2
>     $service.Refresh()  # Met à jour l'état du service
> }
> 
> Write-Host "Service démarré avec succès !"
> ```

### ⚠️ Risque de boucle infinie

> [!warning] Attention aux boucles infinies ! Si la condition reste toujours vraie, la boucle ne s'arrêtera jamais. Assurez-vous que quelque chose dans le bloc modifie l'état qui rendra éventuellement la condition fausse.

```powershell
# ❌ DANGEREUX - Boucle infinie
$nombre = 10
While ($nombre -gt 0) {
    Write-Host "Nombre : $nombre"
    # Oups ! On oublie de décrémenter $nombre
    # La boucle tournera indéfiniment
}

# ✅ CORRECT
$nombre = 10
While ($nombre -gt 0) {
    Write-Host "Nombre : $nombre"
    $nombre--  # On modifie la variable de condition
}
```

### 💡 Quand utiliser While ?

- Quand vous voulez **peut-être** ne jamais exécuter le code (si la condition est fausse dès le départ)
- Pour attendre qu'une condition externe soit remplie
- Pour des compteurs qui doivent être vérifiés avant exécution

> [!tip] Astuce Ajoutez toujours un compteur de sécurité ou un timeout pour éviter les boucles infinies accidentelles en production :
> 
> ```powershell
> $tentatives = 0
> $maxTentatives = 10
> 
> While (($service.Status -ne "Running") -and ($tentatives -lt $maxTentatives)) {
>     Write-Host "Tentative $($tentatives + 1)/$maxTentatives"
>     Start-Sleep -Seconds 2
>     $service.Refresh()
>     $tentatives++
> }
> ```

---

## La boucle Do-While

### 🎯 Concept

La boucle `Do-While` exécute le bloc de code **au moins une fois**, puis teste la condition. Elle continue tant que la condition est **vraie**.

### Syntaxe

```powershell
Do {
    # Code à exécuter au moins une fois
    # puis tant que la condition est vraie
} While (<condition>)
```

### 📘 Explication détaillée

1. PowerShell exécute d'abord le bloc de code
2. Puis évalue la condition
3. Si la condition est `$true`, on retourne à l'étape 1
4. Si la condition est `$false`, on sort de la boucle

> [!info] Garantie d'exécution Le code s'exécute **toujours au moins une fois**, même si la condition est fausse dès le départ.

> [!example] Exemple : Menu interactif
> 
> ```powershell
> Do {
>     Write-Host "`n=== MENU PRINCIPAL ===" -ForegroundColor Cyan
>     Write-Host "1. Afficher la date"
>     Write-Host "2. Afficher les processus"
>     Write-Host "3. Quitter"
>     
>     $choix = Read-Host "`nVotre choix"
>     
>     Switch ($choix) {
>         "1" { Get-Date }
>         "2" { Get-Process | Select-Object -First 10 }
>         "3" { Write-Host "Au revoir !" -ForegroundColor Green }
>         default { Write-Host "Choix invalide !" -ForegroundColor Red }
>     }
>     
> } While ($choix -ne "3")
> ```

> [!example] Exemple : Validation de saisie utilisateur
> 
> ```powershell
> Do {
>     $age = Read-Host "Entrez votre âge (entre 1 et 120)"
>     $age = [int]$age  # Conversion en entier
>     
>     if ($age -lt 1 -or $age -gt 120) {
>         Write-Host "Age invalide ! Réessayez." -ForegroundColor Red
>     }
>     
> } While ($age -lt 1 -or $age -gt 120)
> 
> Write-Host "Age valide : $age ans" -ForegroundColor Green
> ```

### 💡 Quand utiliser Do-While ?

- Pour les menus interactifs (l'utilisateur doit voir les options au moins une fois)
- Pour la validation de saisie utilisateur
- Quand vous devez **garantir une première exécution**
- Pour des opérations qui doivent être tentées au moins une fois

> [!tip] Astuce Do-While est parfait pour les interactions utilisateur car il affiche toujours le prompt au moins une fois, même si vous pourriez théoriquement avoir une valeur pré-remplie.

---

## La boucle Do-Until

### 🎯 Concept

La boucle `Do-Until` est similaire à Do-While, mais la logique de la condition est **inversée** : elle continue tant que la condition est **fausse** et s'arrête quand elle devient **vraie**.

### Syntaxe

```powershell
Do {
    # Code à exécuter au moins une fois
    # puis jusqu'à ce que la condition soit vraie
} Until (<condition>)
```

### 📘 Explication détaillée

1. PowerShell exécute d'abord le bloc de code
2. Puis évalue la condition
3. Si la condition est `$false`, on retourne à l'étape 1
4. Si la condition est `$true`, on sort de la boucle

> [!info] Logique inverse `Do-Until` continue **jusqu'à ce que** la condition soit vraie, contrairement à `Do-While` qui continue **tant que** la condition est vraie.

### 🔄 Différence avec Do-While

|Aspect|Do-While|Do-Until|
|---|---|---|
|Continue quand|Condition = `$true`|Condition = `$false`|
|S'arrête quand|Condition = `$false`|Condition = `$true`|
|Logique|"Tant que..."|"Jusqu'à ce que..."|
|Lisibilité|Pour conditions positives|Pour conditions d'arrêt|

> [!example] Comparaison directe
> 
> ```powershell
> # Avec Do-While (continue TANT QUE c'est vrai)
> $compteur = 1
> Do {
>     Write-Host "Compteur : $compteur"
>     $compteur++
> } While ($compteur -le 5)  # Continue tant que ≤ 5
> 
> # Avec Do-Until (continue JUSQU'À CE QUE ce soit vrai)
> $compteur = 1
> Do {
>     Write-Host "Compteur : $compteur"
>     $compteur++
> } Until ($compteur -gt 5)  # Continue jusqu'à > 5
> 
> # Les deux produisent le même résultat !
> ```

> [!example] Exemple : Attendre qu'un fichier existe
> 
> ```powershell
> $cheminFichier = "C:\Temp\donnees.txt"
> $tentative = 0
> 
> Do {
>     $tentative++
>     Write-Host "Tentative $tentative : Recherche du fichier..."
>     Start-Sleep -Seconds 2
>     
> } Until (Test-Path $cheminFichier)  # S'arrête quand le fichier existe
> 
> Write-Host "Fichier trouvé !" -ForegroundColor Green
> ```

> [!example] Exemple : Génération de mot de passe sécurisé
> 
> ```powershell
> Do {
>     # Génère un mot de passe aléatoire
>     $motDePasse = -join ((48..57) + (65..90) + (97..122) | 
>                          Get-Random -Count 12 | 
>                          ForEach-Object {[char]$_})
>     
>     Write-Host "Mot de passe généré : $motDePasse"
>     
>     # Vérifie la complexité
>     $aMajuscule = $motDePasse -cmatch '[A-Z]'
>     $aMinuscule = $motDePasse -cmatch '[a-z]'
>     $aChiffre = $motDePasse -cmatch '[0-9]'
>     
>     $estValide = $aMajuscule -and $aMinuscule -and $aChiffre
>     
> } Until ($estValide)  # Continue jusqu'à avoir un mot de passe valide
> 
> Write-Host "Mot de passe sécurisé généré !" -ForegroundColor Green
> ```

### 💡 Quand utiliser Do-Until ?

- Quand la logique "jusqu'à ce que" est plus naturelle à lire
- Pour attendre qu'un état souhaité soit atteint
- Quand vous cherchez une condition de **succès** plutôt qu'une condition de continuation

> [!tip] Astuce de lisibilité Choisissez entre Do-While et Do-Until en fonction de ce qui rend le code le plus lisible :
> 
> - `While ($fichierNonTraite)` → Condition de continuation
> - `Until ($fichierTraite)` → Condition d'achèvement
> 
> Le second est souvent plus clair pour exprimer un objectif à atteindre.

---

## Contrôle de flux : Break et Continue

### 🛑 Break - Sortir d'une boucle

Le mot-clé `break` permet de **sortir immédiatement** de la boucle, quelle que soit la condition.

```powershell
$compteur = 1

While ($compteur -le 100) {
    if ($compteur -eq 5) {
        Write-Host "Condition d'arrêt atteinte à 5 !"
        break  # Sort de la boucle immédiatement
    }
    
    Write-Host "Compteur : $compteur"
    $compteur++
}

Write-Host "Boucle terminée."
# Affiche seulement 1, 2, 3, 4 puis sort
```

> [!example] Exemple : Recherche dans une liste
> 
> ```powershell
> $utilisateurs = @("Alice", "Bob", "Charlie", "Diana", "Eve")
> $recherche = "Charlie"
> $trouve = $false
> $index = 0
> 
> While ($index -lt $utilisateurs.Count) {
>     if ($utilisateurs[$index] -eq $recherche) {
>         Write-Host "Utilisateur trouvé à l'index $index !"
>         $trouve = $true
>         break  # Inutile de continuer à chercher
>     }
>     $index++
> }
> 
> if (-not $trouve) {
>     Write-Host "Utilisateur non trouvé."
> }
> ```

### ⏭️ Continue - Passer à l'itération suivante

Le mot-clé `continue` permet de **sauter le reste du code** dans l'itération actuelle et de passer directement à la suivante.

```powershell
$compteur = 0

While ($compteur -lt 10) {
    $compteur++
    
    if ($compteur % 2 -eq 0) {
        continue  # Saute les nombres pairs
    }
    
    Write-Host "Nombre impair : $compteur"
}

# Affiche seulement : 1, 3, 5, 7, 9
```

> [!example] Exemple : Traitement de fichiers avec erreurs
> 
> ```powershell
> $fichiers = Get-ChildItem -Path "C:\Logs" -Filter "*.log"
> $compteur = 0
> 
> While ($compteur -lt $fichiers.Count) {
>     $fichier = $fichiers[$compteur]
>     $compteur++
>     
>     # Ignore les fichiers vides
>     if ($fichier.Length -eq 0) {
>         Write-Host "Fichier vide ignoré : $($fichier.Name)" -ForegroundColor Yellow
>         continue
>     }
>     
>     # Ignore les fichiers verrouillés
>     try {
>         $contenu = Get-Content $fichier.FullName -ErrorAction Stop
>     } catch {
>         Write-Host "Fichier verrouillé ignoré : $($fichier.Name)" -ForegroundColor Yellow
>         continue
>     }
>     
>     # Traite le fichier
>     Write-Host "Traitement de : $($fichier.Name)" -ForegroundColor Green
>     # ... traitement ...
> }
> ```

### 📊 Tableau comparatif

|Mot-clé|Action|Quand l'utiliser|
|---|---|---|
|`break`|Sort complètement de la boucle|Quand la condition de sortie est atteinte|
|`continue`|Passe à l'itération suivante|Quand il faut ignorer certains cas|

> [!warning] Piège courant avec Do-While/Do-Until Attention : `continue` dans une boucle Do-While/Do-Until saute à la **vérification de condition**, pas au début du bloc !
> 
> ```powershell
> $compteur = 0
> Do {
>     $compteur++
>     if ($compteur -eq 3) {
>         continue  # Saute à la vérification While
>     }
>     Write-Host $compteur
> } While ($compteur -lt 5)
> # Affiche : 1, 2, 4, 5 (le 3 est sauté)
> ```

---

## Les étiquettes (labels) pour boucles imbriquées

### 🎯 Concept

Lorsque vous avez des boucles imbriquées (une boucle dans une autre), `break` et `continue` n'affectent que la boucle la plus proche. Les **étiquettes** (labels) permettent de contrôler des boucles externes.

### Syntaxe

```powershell
:nomEtiquette While (<condition>) {
    # Code...
    
    While (<autre_condition>) {
        # Code imbriqué...
        
        break nomEtiquette  # Sort de la boucle étiquetée
        # ou
        continue nomEtiquette  # Continue la boucle étiquetée
    }
}
```

> [!info] Convention de nommage Les étiquettes commencent par `:` et sont placées juste avant la déclaration de la boucle. Par convention, utilisez des noms descriptifs en PascalCase.

### 📘 Exemples pratiques

> [!example] Exemple : Break avec étiquette
> 
> ```powershell
> :BoucleExterne While ($true) {
>     $ligne = 1
>     
>     While ($ligne -le 5) {
>         $colonne = 1
>         
>         While ($colonne -le 5) {
>             Write-Host "$ligne,$colonne " -NoNewline
>             
>             # Condition spéciale : arrêter TOUT
>             if ($ligne -eq 3 -and $colonne -eq 3) {
>                 Write-Host "`n*** Arrêt complet à 3,3 ***"
>                 break BoucleExterne  # Sort de toutes les boucles !
>             }
>             
>             $colonne++
>         }
>         
>         Write-Host ""  # Nouvelle ligne
>         $ligne++
>     }
> }
> 
> Write-Host "Programme terminé."
> ```

> [!example] Exemple : Continue avec étiquette
> 
> ```powershell
> :BoucleUtilisateurs While ($true) {
>     Write-Host "`n=== Nouveau lot d'utilisateurs ===" -ForegroundColor Cyan
>     
>     $utilisateurs = @("Alice", "Bob", "Charlie")
>     $index = 0
>     
>     While ($index -lt $utilisateurs.Count) {
>         $user = $utilisateurs[$index]
>         Write-Host "Traitement de : $user"
>         
>         # Simule une erreur critique pour Bob
>         if ($user -eq "Bob") {
>             Write-Host "Erreur critique ! Passage au lot suivant." -ForegroundColor Red
>             continue BoucleUtilisateurs  # Saute au prochain lot !
>         }
>         
>         Write-Host "  -> $user traité avec succès" -ForegroundColor Green
>         $index++
>     }
>     
>     # Demande si on continue
>     $reponse = Read-Host "Traiter un autre lot ? (O/N)"
>     if ($reponse -ne "O") {
>         break BoucleUtilisateurs
>     }
> }
> ```

> [!example] Exemple pratique : Recherche dans une matrice
> 
> ```powershell
> $matrice = @(
>     @(1, 2, 3, 4),
>     @(5, 6, 7, 8),
>     @(9, 10, 11, 12)
> )
> 
> $recherche = 7
> $trouve = $false
> 
> :RechercheMatrice For ($i = 0; $i -lt $matrice.Count; $i++) {
>     For ($j = 0; $j -lt $matrice[$i].Count; $j++) {
>         Write-Host "Vérification [$i,$j] = $($matrice[$i][$j])"
>         
>         if ($matrice[$i][$j] -eq $recherche) {
>             Write-Host "Valeur trouvée à [$i,$j] !" -ForegroundColor Green
>             $trouve = $true
>             break RechercheMatrice  # Sort des DEUX boucles For
>         }
>     }
> }
> 
> if (-not $trouve) {
>     Write-Host "Valeur non trouvée." -ForegroundColor Yellow
> }
> ```

### 💡 Quand utiliser les étiquettes ?

- **Boucles imbriquées complexes** : Quand vous avez 2 niveaux ou plus
- **Conditions d'arrêt globales** : Quand une condition dans une boucle interne doit arrêter toute la structure
- **Clarté du code** : Quand `break` ou `continue` seul serait ambigu

> [!tip] Astuce : Alternative aux étiquettes Si votre code nécessite beaucoup d'étiquettes, envisagez de refactoriser en **fonctions** :
> 
> ```powershell
> function Rechercher-DansMatrice {
>     param($matrice, $valeur)
>     
>     For ($i = 0; $i -lt $matrice.Count; $i++) {
>         For ($j = 0; $j -lt $matrice[$i].Count; $j++) {
>             if ($matrice[$i][$j] -eq $valeur) {
>                 return @{Trouve=$true; Ligne=$i; Colonne=$j}
>             }
>         }
>     }
>     
>     return @{Trouve=$false}
> }
> 
> # Utilisation simple sans étiquettes
> $resultat = Rechercher-DansMatrice -matrice $matrice -valeur 7
> ```

> [!warning] Piège : Orthographe des étiquettes Les étiquettes sont sensibles à la casse ! `:MaBoucle` et `:maboucle` sont différentes.
> 
> ```powershell
> :MaBoucle While ($true) {
>     break maboucle  # ❌ Erreur ! Casse incorrecte
>     break MaBoucle  # ✅ Correct
> }
> ```

---

## Comparaison des trois types de boucles

### 📊 Tableau récapitulatif

|Caractéristique|While|Do-While|Do-Until|
|---|---|---|---|
|**Test de condition**|Avant l'exécution|Après l'exécution|Après l'exécution|
|**Exécutions minimum**|0 (si condition fausse)|1 (garanti)|1 (garanti)|
|**Continue quand**|Condition = `$true`|Condition = `$true`|Condition = `$false`|
|**S'arrête quand**|Condition = `$false`|Condition = `$false`|Condition = `$true`|
|**Logique naturelle**|"Tant que..."|"Tant que..."|"Jusqu'à ce que..."|
|**Cas d'usage typique**|Attente conditionnelle|Menus, validation|Atteinte d'objectif|

### 🔄 Même résultat, différentes approches

```powershell
# Scénario : Afficher les nombres de 1 à 5

# ─── Avec While ───
$i = 1
While ($i -le 5) {
    Write-Host $i
    $i++
}

# ─── Avec Do-While ───
$i = 1
Do {
    Write-Host $i
    $i++
} While ($i -le 5)

# ─── Avec Do-Until ───
$i = 1
Do {
    Write-Host $i
    $i++
} Until ($i -gt 5)

# Les trois produisent : 1, 2, 3, 4, 5
```

### 🎯 Guide de choix

> [!tip] Quel type de boucle choisir ?
> 
> **Utilisez While quand :**
> 
> - La première vérification pourrait empêcher l'exécution
> - Vous attendez qu'une condition externe change
> - La logique est "tant que X, faire Y"
> 
> **Utilisez Do-While quand :**
> 
> - Le code doit s'exécuter au moins une fois
> - Vous créez un menu ou une interface interactive
> - La validation se fait après une action
> - La logique est "faire Y tant que X"
> 
> **Utilisez Do-Until quand :**
> 
> - Le code doit s'exécuter au moins une fois
> - Vous cherchez à atteindre un état spécifique
> - La condition d'arrêt est plus claire que la condition de continuation
> - La logique est "faire Y jusqu'à ce que X"

### ⚠️ Pièges communs à tous les types

> [!warning] Erreurs fréquentes
> 
> **1. Oublier de modifier la variable de condition**
> 
> ```powershell
> # ❌ Boucle infinie !
> $compteur = 0
> While ($compteur -lt 10) {
>     Write-Host "Toujours zéro !"
>     # Oubli : $compteur++
> }
> ```
> 
> **2. Conditions inversées**
> 
> ```powershell
> # ❌ Ne s'exécute jamais avec While
> $nombre = 10
> While ($nombre -gt 10) {  # Déjà faux au départ !
>     Write-Host $nombre
>     $nombre++
> }
> 
> # ✅ Utiliser Do-While ou corriger la condition
> Do {
>     Write-Host $nombre
>     $nombre++
> } While ($nombre -le 15)
> ```
> 
> **3. Confusion entre Do-While et Do-Until**
> 
> ```powershell
> # Ces deux boucles font la MÊME chose :
> Do { ... } While ($x -lt 10)     # Continue si < 10
> Do { ... } Until ($x -ge 10)     # Continue jusqu'à >= 10
> 
> # Mais pas celles-ci :
> Do { ... } While ($x -lt 10)     # Continue si < 10
> Do { ... } Until ($x -lt 10)     # S'arrête si < 10 (inverse !)
> ```

### 💡 Bonnes pratiques

> [!tip] Conseils professionnels
> 
> **1. Toujours avoir une issue de secours**
> 
> ```powershell
> $tentatives = 0
> $maxTentatives = 100
> 
> While (($condition) -and ($tentatives -lt $maxTentatives)) {
>     # Code...
>     $tentatives++
> }
> 
> if ($tentatives -ge $maxTentatives) {
>     Write-Warning "Nombre maximum de tentatives atteint !"
> }
> ```
> 
> **2. Privilégier la lisibilité**
> 
> ```powershell
> # ❌ Difficile à lire
> While (-not $fichierTraite -and $tentatives -lt 10 -and -not $erreur) { ... }
> 
> # ✅ Plus clair avec variables intermédiaires
> $peutContinuer = (-not $fichierTraite) -and 
>                  ($tentatives -lt 10) -and 
>                  (-not $erreur)
> While ($peutContinuer) { ... }
> ```
> 
> **3. Commenter les conditions complexes**
> 
> ```powershell
> # Continue tant que :
> # - Le service n'est pas démarré
> # - ET nous n'avons pas dépassé le timeout
> # - ET aucune erreur critique n'est survenue
> While (($service.Status -ne "Running") -and 
>        ($elapsed -lt $timeout) -and 
>        (-not $erreurCritique)) {
>     # ...
> }
> ```

---

## 🎓 Points clés à retenir

- **While** teste **avant**, peut ne jamais s'exécuter
- **Do-While** et **Do-Until** testent **après**, garantissent au moins une exécution
- **Do-While** continue tant que `$true`, **Do-Until** continue tant que `$false`
- **break** sort de la boucle, **continue** passe à l'itération suivante
- Les **étiquettes** permettent de contrôler les boucles imbriquées
- Toujours prévoir une **condition de sortie** pour éviter les boucles infinies
- Choisir le type de boucle selon la **logique naturelle** du problème

---

_Cours créé pour Obsidian - PowerShell 🚀_