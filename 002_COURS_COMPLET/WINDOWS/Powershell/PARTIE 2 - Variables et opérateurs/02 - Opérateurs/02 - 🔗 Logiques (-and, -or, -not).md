

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

## <a id="introduction"></a>🎯 Introduction aux opérateurs logiques

Les opérateurs logiques permettent de combiner plusieurs expressions booléennes pour créer des conditions complexes. Ils sont essentiels pour :

- Construire des conditions `if` sophistiquées
- Filtrer des données avec `Where-Object`
- Valider plusieurs critères simultanément
- Contrôler le flux d'exécution de vos scripts

> [!info] Opérateurs disponibles PowerShell propose quatre opérateurs logiques principaux :
> 
> - `-and` : Toutes les conditions doivent être vraies
> - `-or` : Au moins une condition doit être vraie
> - `-not` (ou `!`) : Inverse la valeur booléenne
> - `-xor` : Exactement une condition doit être vraie (mais pas les deux)

---

## <a id="and"></a>🔗 L'opérateur -and (ET logique)

### Fonctionnement

L'opérateur `-and` retourne `$true` uniquement si **toutes** les expressions qui l'entourent sont vraies.

### Syntaxe

```powershell
# Syntaxe de base
$expression1 -and $expression2

# Exemple simple
$age = 25
$permis = $true

if ($age -ge 18 -and $permis) {
    Write-Host "Peut conduire"
}
```

### Table de vérité

|Expression 1|Expression 2|Résultat|
|---|---|---|
|`$true`|`$true`|`$true`|
|`$true`|`$false`|`$false`|
|`$false`|`$true`|`$false`|
|`$false`|`$false`|`$false`|

### Exemples pratiques

```powershell
# Vérifier plusieurs conditions sur un fichier
$file = Get-Item "C:\temp\test.txt"
if ($file.Exists -and $file.Length -gt 0) {
    Write-Host "Fichier valide et non vide"
}

# Validation de données utilisateur
$username = "admin"
$password = "secret123"
if ($username -ne "" -and $password.Length -ge 8) {
    Write-Host "Identifiants valides"
}

# Filtrage avec Where-Object
Get-Process | Where-Object { $_.CPU -gt 10 -and $_.WorkingSet -gt 100MB }
```

> [!tip] Astuce Placez la condition la plus susceptible d'être fausse en premier pour profiter du court-circuit d'évaluation et améliorer les performances.

---

## <a id="or"></a>🔀 L'opérateur -or (OU logique)

### Fonctionnement

L'opérateur `-or` retourne `$true` si **au moins une** des expressions est vraie.

### Syntaxe

```powershell
# Syntaxe de base
$expression1 -or $expression2

# Exemple simple
$estAdmin = $false
$estSuperUser = $true

if ($estAdmin -or $estSuperUser) {
    Write-Host "Accès autorisé"
}
```

### Table de vérité

|Expression 1|Expression 2|Résultat|
|---|---|---|
|`$true`|`$true`|`$true`|
|`$true`|`$false`|`$true`|
|`$false`|`$true`|`$true`|
|`$false`|`$false`|`$false`|

### Exemples pratiques

```powershell
# Vérifier plusieurs extensions de fichiers
$extension = ".txt"
if ($extension -eq ".txt" -or $extension -eq ".log" -or $extension -eq ".csv") {
    Write-Host "Fichier texte détecté"
}

# Validation avec valeurs par défaut
$env = $ENV:ENVIRONMENT
if ($env -eq "DEV" -or $env -eq $null) {
    Write-Host "Utilisation de l'environnement de développement"
}

# Filtrage flexible
Get-Service | Where-Object { $_.Status -eq "Running" -or $_.StartType -eq "Automatic" }
```

> [!example] Cas d'usage typique L'opérateur `-or` est parfait pour gérer plusieurs scénarios acceptables ou pour implémenter des valeurs par défaut.

---

## <a id="not"></a>❌ L'opérateur -not (NON logique)

### Fonctionnement

L'opérateur `-not` inverse la valeur booléenne d'une expression. Il peut aussi s'écrire avec le symbole `!`.

### Syntaxe

```powershell
# Syntaxe avec -not
-not $expression

# Syntaxe avec !
!$expression

# Les deux sont équivalents
$fichierExiste = $false
if (-not $fichierExiste) {
    Write-Host "Fichier introuvable"
}

if (!$fichierExiste) {
    Write-Host "Fichier introuvable"  # Même résultat
}
```

### Table de vérité

|Expression|Résultat|
|---|---|
|`$true`|`$false`|
|`$false`|`$true`|

### Exemples pratiques

```powershell
# Vérifier l'absence d'un élément
$utilisateur = Get-ADUser -Filter "Name -eq 'JohnDoe'" -ErrorAction SilentlyContinue
if (-not $utilisateur) {
    Write-Host "Utilisateur non trouvé, création nécessaire"
}

# Inverser une condition complexe
$age = 15
$autorisation = $false
if (-not ($age -ge 18 -and $autorisation)) {
    Write-Host "Accès refusé"
}

# Filtrage par exclusion
Get-ChildItem | Where-Object { -not $_.PSIsContainer }  # Seulement les fichiers

# Avec le symbole !
$service = Get-Service -Name "Spooler"
if (!$service.Status -eq "Running") {
    Start-Service -Name "Spooler"
}
```

> [!tip] Convention de style Le symbole `!` est plus court et souvent préféré dans les scripts modernes, mais `-not` est plus lisible pour les débutants.

---

## <a id="xor"></a>⚡ L'opérateur -xor (OU exclusif)

### Fonctionnement

L'opérateur `-xor` retourne `$true` uniquement si **exactement une** des deux expressions est vraie (mais pas les deux en même temps).

### Syntaxe

```powershell
# Syntaxe de base
$expression1 -xor $expression2

# Exemple simple
$modeManuel = $true
$modeAuto = $false

if ($modeManuel -xor $modeAuto) {
    Write-Host "Configuration valide : un seul mode actif"
}
```

### Table de vérité

|Expression 1|Expression 2|Résultat|
|---|---|---|
|`$true`|`$true`|`$false`|
|`$true`|`$false`|`$true`|
|`$false`|`$true`|`$true`|
|`$false`|`$false`|`$false`|

### Exemples pratiques

```powershell
# Valider qu'une seule option est activée
$useLocalDB = $true
$useRemoteDB = $true

if (-not ($useLocalDB -xor $useRemoteDB)) {
    Write-Host "ERREUR : Activez une seule base de données"
    exit
}

# Toggle entre deux états
$nightMode = $false
$dayMode = $true

if ($nightMode -xor $dayMode) {
    Write-Host "Mode cohérent"
} else {
    Write-Host "ERREUR : Les deux modes sont identiques"
}

# Détection de changement d'état
$ancienEtat = $true
$nouvelEtat = $false

if ($ancienEtat -xor $nouvelEtat) {
    Write-Host "L'état a changé"
}
```

> [!warning] Attention `-xor` est moins utilisé que `-and` et `-or`, mais il est très utile pour valider des configurations mutuellement exclusives.

---

## <a id="priorite"></a>📊 Priorité des opérateurs logiques

### Ordre de priorité

PowerShell évalue les opérateurs logiques dans cet ordre (du plus prioritaire au moins prioritaire) :

1. **Parenthèses** `( )`
2. **Opérateur de négation** `-not` / `!`
3. **Opérateur ET** `-and`
4. **Opérateurs OU** `-or` et `-xor` (même priorité)

### Impact de la priorité

```powershell
# Sans parenthèses - peut être ambigu
$a = $true
$b = $false
$c = $true

# -and est évalué AVANT -or
$resultat = $a -or $b -and $c
# Équivalent à : $a -or ($b -and $c)
# Résultat : $true

# Exemple plus complexe
$age = 20
$permis = $false
$accompagnateur = $true

# Évaluation : ($age -ge 18 -and $permis) OU ($accompagnateur)
if ($age -ge 18 -and $permis -or $accompagnateur) {
    Write-Host "Peut conduire"
}
```

### Tableau récapitulatif

|Priorité|Opérateur|Nom|Évaluation|
|---|---|---|---|
|1|`( )`|Parenthèses|En premier|
|2|`-not`, `!`|Négation|Avant ET/OU|
|3|`-and`|ET logique|Avant OU|
|4|`-or`, `-xor`|OU logique|En dernier|

> [!warning] Piège fréquent Ne comptez jamais sur la priorité implicite pour des expressions complexes. Utilisez toujours des parenthèses pour rendre votre intention claire !

---

## <a id="parentheses"></a>🔲 Utilisation des parenthèses

### Pourquoi utiliser des parenthèses ?

Les parenthèses permettent de :

- **Contrôler l'ordre d'évaluation** explicitement
- **Améliorer la lisibilité** du code
- **Éviter les bugs** dus à une mauvaise interprétation de la priorité

### Syntaxe et exemples

```powershell
# Sans parenthèses - évaluation selon la priorité par défaut
$resultat = $true -or $false -and $false
# Équivalent à : $true -or ($false -and $false)
# Résultat : $true

# Avec parenthèses - ordre explicite différent
$resultat = ($true -or $false) -and $false
# On force l'évaluation de -or en premier
# Résultat : $false

# Cas pratique : validation d'accès
$estAdmin = $false
$estDeveloppeur = $true
$projetActif = $true
$urgence = $false

# Sans parenthèses - ambigu
if ($estAdmin -or $estDeveloppeur -and $projetActif -or $urgence) {
    # Difficile de comprendre la logique
}

# Avec parenthèses - intention claire
if ($estAdmin -or ($estDeveloppeur -and $projetActif) -or $urgence) {
    Write-Host "Accès autorisé"
}
```

### Imbrication de parenthèses

```powershell
# Parenthèses imbriquées pour des conditions complexes
$age = 17
$accompagne = $true
$autorisationParentale = $true
$formation = $false

if (
    ($age -ge 18) -or 
    (
        ($age -ge 16) -and 
        ($accompagne -or $autorisationParentale) -and 
        $formation
    )
) {
    Write-Host "Peut participer à l'activité"
}
```

### Bonnes pratiques de formatage

```powershell
# Mauvais : tout sur une ligne
if (($a -and $b) -or ($c -and $d) -or ($e -and ($f -or $g))) { }

# Bon : une condition par ligne
if (
    ($a -and $b) -or
    ($c -and $d) -or
    ($e -and ($f -or $g))
) {
    Write-Host "Condition remplie"
}

# Excellent : avec commentaires
if (
    # L'utilisateur est un administrateur
    ($estAdmin -and $sessionActive) -or
    # OU il a une autorisation temporaire valide
    ($autorisationTemp -and $dateExpiration -gt (Get-Date)) -or
    # OU c'est une situation d'urgence
    ($urgence -and $managerApprouve)
) {
    Write-Host "Accès accordé"
}
```

> [!tip] Règle d'or En cas de doute, ajoutez des parenthèses. La clarté est plus importante que la concision.

---

## <a id="court-circuit"></a>⚡ Court-circuit d'évaluation

### Qu'est-ce que le court-circuit ?

PowerShell utilise l'évaluation en **court-circuit** : il arrête d'évaluer une expression dès que le résultat final est déterminé.

### Comportement avec -and

Avec `-and`, si la première expression est `$false`, la seconde n'est **jamais évaluée**.

```powershell
# La fonction GetValue ne sera JAMAIS appelée
function GetValue {
    Write-Host "GetValue appelée"
    return $true
}

$condition1 = $false
if ($condition1 -and (GetValue)) {
    # GetValue n'est pas exécutée car $condition1 est $false
}
# Aucun affichage de "GetValue appelée"

# Exemple pratique : vérification sécurisée
$fichier = $null
# Sans court-circuit, on aurait une erreur sur $fichier.Length
if ($fichier -ne $null -and $fichier.Length -gt 0) {
    Write-Host "Fichier valide"
}
```

### Comportement avec -or

Avec `-or`, si la première expression est `$true`, la seconde n'est **jamais évaluée**.

```powershell
# La fonction CheckDatabase ne sera JAMAIS appelée
function CheckDatabase {
    Write-Host "CheckDatabase appelée"
    return $true
}

$cacheValide = $true
if ($cacheValide -or (CheckDatabase)) {
    Write-Host "Données disponibles"
}
# Aucun affichage de "CheckDatabase appelée"

# Exemple pratique : optimisation
$resultatCache = Get-CacheValue
if ($resultatCache -or (InvokeExpensiveQuery)) {
    # InvokeExpensiveQuery n'est appelée que si le cache est vide
}
```

### Avantages du court-circuit

```powershell
# 1. Performance : évite des calculs inutiles
if ($quickCheck -or $expensiveCheck) {
    # $expensiveCheck n'est exécuté que si nécessaire
}

# 2. Sécurité : évite les erreurs
$user = Get-ADUser -Filter "Name -eq 'John'" -ErrorAction SilentlyContinue
if ($user -and $user.Enabled) {
    # Pas d'erreur même si $user est $null
}

# 3. Éviter les effets de bord non désirés
$logEnabled = $false
if ($logEnabled -and (Write-Log "Message")) {
    # Write-Log n'est jamais appelé si $logEnabled est $false
}
```

### Pièges à éviter

```powershell
# PIÈGE : Compter sur des effets de bord
$compteur = 0
function IncrementAndCheck {
    $script:compteur++
    return $true
}

# Le compteur ne sera PAS incrémenté !
if ($true -or (IncrementAndCheck)) {
    Write-Host "Compteur : $compteur"  # Affiche 0
}

# SOLUTION : Séparez la logique
IncrementAndCheck
if ($true -or $compteur -gt 0) {
    Write-Host "Compteur : $compteur"
}
```

> [!warning] Attention aux effets de bord Ne placez jamais de code avec des effets de bord (modification de variables, écriture de logs, etc.) dans des conditions qui peuvent être court-circuitées.

---

## <a id="combinaisons"></a>🧩 Combinaisons complexes

### Construire des logiques sophistiquées

Les opérateurs logiques peuvent être combinés pour créer des conditions très complexes.

```powershell
# Exemple réaliste : validation de déploiement
$environnement = "PROD"
$testsReussis = $true
$approbationManager = $true
$heureActuelle = (Get-Date).Hour
$jourSemaine = (Get-Date).DayOfWeek

$peutDeployer = (
    # Environnement de développement : toujours autorisé
    ($environnement -eq "DEV") -or
    
    # Environnement de test : si les tests passent
    ($environnement -eq "TEST" -and $testsReussis) -or
    
    # Environnement de production : conditions strictes
    (
        $environnement -eq "PROD" -and
        $testsReussis -and
        $approbationManager -and
        $heureActuelle -ge 22 -and  # Après 22h
        $heureActuelle -lt 6 -and   # Avant 6h
        $jourSemaine -ne "Saturday" -and
        $jourSemaine -ne "Sunday"
    )
)

if ($peutDeployer) {
    Write-Host "Déploiement autorisé"
} else {
    Write-Host "Déploiement refusé"
}
```

### Validation de formulaires

```powershell
# Validation complexe de données utilisateur
function Test-UserInput {
    param(
        [string]$Username,
        [string]$Email,
        [string]$Password,
        [int]$Age
    )
    
    $usernameValide = (
        $Username -and
        $Username.Length -ge 3 -and
        $Username.Length -le 20 -and
        $Username -match '^[a-zA-Z0-9_]+$'
    )
    
    $emailValide = (
        $Email -and
        $Email -match '^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$'
    )
    
    $passwordValide = (
        $Password -and
        $Password.Length -ge 8 -and
        $Password -match '[A-Z]' -and  # Au moins une majuscule
        $Password -match '[a-z]' -and  # Au moins une minuscule
        $Password -match '\d' -and     # Au moins un chiffre
        $Password -match '[\W_]'       # Au moins un caractère spécial
    )
    
    $ageValide = (
        $Age -ge 13 -and
        $Age -le 120
    )
    
    return (
        $usernameValide -and
        $emailValide -and
        $passwordValide -and
        $ageValide
    )
}
```

### Filtrage avancé avec Where-Object

```powershell
# Filtrer des processus selon plusieurs critères
Get-Process | Where-Object {
    (
        # Processus gourmands en CPU
        ($_.CPU -gt 100 -and $_.WorkingSet -gt 500MB) -or
        
        # OU processus avec beaucoup de handles
        ($_.HandleCount -gt 1000) -or
        
        # OU processus spécifiques critiques
        ($_.Name -in @('chrome', 'firefox', 'code') -and $_.Responding -eq $false)
    ) -and
    
    # Mais pas les processus système
    (-not ($_.Name -like 'svchost*' -or $_.Name -eq 'System'))
}

# Filtrer des fichiers avec logique complexe
Get-ChildItem -Recurse | Where-Object {
    (
        # Fichiers texte de plus de 1 MB
        ($_.Extension -in @('.txt', '.log') -and $_.Length -gt 1MB) -or
        
        # OU fichiers modifiés dans les 7 derniers jours
        ($_.LastWriteTime -gt (Get-Date).AddDays(-7))
    ) -and
    
    # Mais pas dans les dossiers cachés ou temporaires
    (-not ($_.FullName -match '\\temp\\|\\\.git\\'))
}
```

### Logique de retry avec conditions multiples

```powershell
# Système de retry intelligent
$maxTentatives = 5
$tentative = 0
$succes = $false
$derniereErreur = $null

while (
    (-not $succes) -and
    ($tentative -lt $maxTentatives) -and
    (
        # Continuer si c'est la première tentative
        ($tentative -eq 0) -or
        # OU si l'erreur est temporaire
        (
            $derniereErreur -and
            (
                $derniereErreur -match "timeout" -or
                $derniereErreur -match "network" -or
                $derniereErreur -match "unavailable"
            )
        )
    )
) {
    $tentative++
    try {
        # Votre code ici
        Invoke-RestMethod -Uri "https://api.example.com/data"
        $succes = $true
    }
    catch {
        $derniereErreur = $_.Exception.Message
        Write-Host "Tentative $tentative échouée : $derniereErreur"
        Start-Sleep -Seconds ($tentative * 2)  # Backoff exponentiel
    }
}
```

> [!tip] Conseil pour les conditions complexes Décomposez les conditions complexes en variables intermédiaires avec des noms explicites. Cela améliore grandement la lisibilité.

```powershell
# Au lieu de ceci (difficile à lire) :
if (($a -and $b -or $c) -and ($d -or ($e -and $f)) -and -not $g) { }

# Faites ceci (beaucoup plus clair) :
$conditionPrincipale = ($a -and $b -or $c)
$conditionSecondaire = ($d -or ($e -and $f))
$pasDeBlocage = -not $g

if ($conditionPrincipale -and $conditionSecondaire -and $pasDeBlocage) { }
```

---

## <a id="pieges"></a>⚠️ Pièges courants

### 1. Confusion entre -eq et -and

```powershell
# ERREUR : Utiliser -eq au lieu de -and
$a = 5
if ($a -eq 5 -eq $true) {  # FAUX !
    # Ne fonctionne pas comme prévu
}

# CORRECT : Utiliser -and
if (($a -eq 5) -and ($true)) {
    Write-Host "Correct"
}
```

### 2. Oublier les parenthèses avec -not

```powershell
# ERREUR : Mauvaise portée de -not
if (-not $a -eq 5) {  # Équivaut à (-not $a) -eq 5
    # Pas ce que vous voulez !
}

# CORRECT : Parenthèses autour de toute l'expression
if (-not ($a -eq 5)) {
    Write-Host "a n'est pas égal à 5"
}
```

### 3. Comparer directement des valeurs non-booléennes

```powershell
# PIÈGE : Les valeurs non-booléennes sont converties
$nombre = 0
if ($nombre) {  # 0 est converti en $false
    Write-Host "Ne s'affiche pas"
}

$chaine = ""
if ($chaine) {  # Chaîne vide est convertie en $false
    Write-Host "Ne s'affiche pas"
}

# MEILLEURE PRATIQUE : Soyez explicite
if ($nombre -ne 0) {
    Write-Host "Nombre non nul"
}

if ($chaine -ne "" -and $chaine -ne $null) {
    Write-Host "Chaîne valide"
}
```

### 4. Ordre d'évaluation inattendu

```powershell
# PIÈGE : Ordre surprenant sans parenthèses
$a = $true
$b = $false
$c = $true

# Que vaut cette expression ?
$resultat = $a -and $b -or $c
# Réponse : $true (car -and est prioritaire)
# Équivaut à : ($a -and $b) -or $c
# Soit : ($false) -or $true = $true

# SOLUTION : Utilisez des parenthèses
$resultat = $a -and ($b -or $c)
```

### 5. Variables $null dans les comparaisons

```powershell
# PIÈGE : $null peut causer des erreurs
$variable = $null

# ERREUR potentielle
if ($variable.Length -gt 0) {  # Exception !
    Write-Host "Jamais exécuté"
}

# CORRECT : Vérifiez $null en premier (court-circuit)
if ($variable -ne $null -and $variable.Length -gt 0) {
    Write-Host "Variable valide et non vide"
}
```

### 6. Effets de bord dans les conditions

```powershell
# PIÈGE : Fonction avec effet de bord dans condition
$compteur = 0
function Incrementer {
    $script:compteur++
    return $true
}

# Le compteur peut ne pas être incrémenté !
if ($true -or (Incrementer)) {
    Write-Host $compteur  # Affiche 0 (Incrementer n'a pas été appelé)
}

# SOLUTION : Séparez la logique
$resultat = Incrementer
if ($true -or $resultat) {
    Write-Host $compteur  # Affiche 1
}
```

### 7. Confusion entre -xor et -or

```powershell
# ATTENTION : -xor n'est PAS un -or
$mode1 = $true
$mode2 = $true

if ($mode1 -xor $mode2) {
    Write-Host "Ne s'affiche pas car les deux sont vrais"
}

# -xor retourne $false si les deux sont vrais
# Utilisez -or si vous voulez "au moins un"
if ($mode1 -or $mode2) {
    Write-Host "Au moins un mode est actif"
}
```

### 8. Négation de conditions complexes

```powershell
# PIÈGE : Mal placer -not dans une expression complexe
$a = $true
$b = $false
$c = $true

# Ce n'est PAS la négation de ($a -and $b -or $c)
$resultat = -not $a -and $b -or $c

# Pour nier toute l'expression, utilisez des parenthèses
$resultat = -not ($a -and $b -or $c)
```

> [!warning] Règles de sécurité
> 
> - **Toujours vérifier $null avant d'accéder aux propriétés**
> - **Toujours utiliser des parenthèses pour les expressions complexes**
> - **Éviter les effets de bord dans les conditions logiques**
> - **Être explicite plutôt que de compter sur les conversions automatiques**

---

## 🎓 Résumé

Les opérateurs logiques sont des outils puissants pour construire des conditions sophistiquées :

- **`-and`** : Toutes les conditions doivent être vraies
- **`-or`** : Au moins une condition doit être vraie
- **`-not` / `!`** : Inverse la valeur booléenne
- **`-xor`** : Exactement une condition doit être vraie

**Points clés à retenir :**

1. La priorité est : Parenthèses > `-not` > `-and` > `-or`/`-xor`
2. Le court-circuit optimise les performances et évite les erreurs
3. Utilisez toujours des parenthèses pour les expressions complexes
4. Vérifiez $null avant d'accéder aux propriétés
5. Évitez les effets de bord dans les conditions

**Bonne pratique universelle :** En cas de doute, ajoutez des parenthèses et des commentaires explicatifs !

