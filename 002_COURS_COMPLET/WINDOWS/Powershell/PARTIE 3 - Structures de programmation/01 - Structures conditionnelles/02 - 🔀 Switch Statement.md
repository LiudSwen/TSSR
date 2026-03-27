

## 📑 Table des matières

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

## 🎯 Introduction au Switch

Le `switch` est une structure de contrôle qui permet d'évaluer une expression et d'exécuter différents blocs de code selon la valeur obtenue. C'est une alternative élégante et performante aux longues chaînes de `if/elseif`.

> [!info] Pourquoi utiliser switch ?
> 
> - **Lisibilité** : Plus clair que des multiples `if/elseif` pour tester une même variable
> - **Performance** : Optimisé pour de nombreuses comparaisons
> - **Flexibilité** : Support des wildcards, regex, et fichiers
> - **Puissance** : Peut traiter plusieurs correspondances simultanément

---

## 📝 Syntaxe de base

La structure fondamentale du `switch` suit ce modèle :

```powershell
switch (expression) {
    valeur1 { 
        # Code à exécuter si expression == valeur1
    }
    valeur2 { 
        # Code à exécuter si expression == valeur2
    }
    valeur3 { 
        # Code à exécuter si expression == valeur3
    }
    default { 
        # Code à exécuter si aucune correspondance
    }
}
```

> [!example] Exemple simple
> 
> ```powershell
> $jour = "Lundi"
> 
> switch ($jour) {
>     "Lundi" {
>         Write-Host "Début de semaine"
>     }
>     "Vendredi" {
>         Write-Host "Bientôt le weekend !"
>     }
>     "Samedi" {
>         Write-Host "Weekend !"
>     }
>     "Dimanche" {
>         Write-Host "Weekend !"
>     }
>     default {
>         Write-Host "Milieu de semaine"
>     }
> }
> # Affiche : Début de semaine
> ```

---

## 🎯 Correspondance simple de valeurs

Le `switch` compare l'expression avec chaque valeur définie et exécute le bloc correspondant.

```powershell
$code = 404

switch ($code) {
    200 {
        Write-Host "OK - Succès"
    }
    404 {
        Write-Host "Not Found - Page introuvable"
    }
    500 {
        Write-Host "Internal Server Error"
    }
}
# Affiche : Not Found - Page introuvable
```

> [!tip] Astuce : Multiples valeurs pour un même bloc
> 
> ```powershell
> $status = "Warning"
> 
> switch ($status) {
>     "OK" { Write-Host "Tout va bien" -ForegroundColor Green }
>     { $_ -in "Warning", "Attention", "Alert" } { 
>         Write-Host "Attention requise" -ForegroundColor Yellow 
>     }
>     { $_ -in "Error", "Critical", "Fatal" } { 
>         Write-Host "Problème critique !" -ForegroundColor Red 
>     }
> }
> ```

### Types de valeurs supportés

Le `switch` fonctionne avec différents types de données :

```powershell
# Nombres
switch (42) {
    42 { "La réponse" }
    0 { "Zéro" }
}

# Chaînes de caractères
switch ("PowerShell") {
    "PowerShell" { "C'est un shell" }
    "Bash" { "C'est un autre shell" }
}

# Booléens
switch ($true) {
    $true { "Vrai" }
    $false { "Faux" }
}

# Variables
$valeur = 10
switch ($valeur) {
    10 { "Dix" }
    20 { "Vingt" }
}
```

---

## 🌟 Option -Wildcard

L'option `-Wildcard` permet d'utiliser des caractères génériques (`*`, `?`) pour la correspondance de motifs.

```powershell
switch -Wildcard (expression) {
    pattern { # Code }
}
```

### Caractères génériques disponibles

|Caractère|Signification|Exemple|
|---|---|---|
|`*`|N'importe quelle séquence de caractères|`"*.txt"` correspond à tous les fichiers .txt|
|`?`|Un seul caractère quelconque|`"fichier?.log"` correspond à fichier1.log, fichierA.log|

> [!example] Exemples pratiques
> 
> ```powershell
> $fichier = "rapport_2024.xlsx"
> 
> switch -Wildcard ($fichier) {
>     "*.txt" {
>         Write-Host "Fichier texte"
>     }
>     "*.xlsx" {
>         Write-Host "Fichier Excel"
>     }
>     "rapport_*" {
>         Write-Host "C'est un rapport"
>     }
>     "*_2024*" {
>         Write-Host "Document de 2024"
>     }
> }
> # Affiche : Fichier Excel
> #           C'est un rapport
> #           Document de 2024
> ```

```powershell
# Validation d'email simplifiée
$email = "utilisateur@domaine.com"

switch -Wildcard ($email) {
    "*@domaine.com" {
        Write-Host "Email du domaine principal"
    }
    "*@*.fr" {
        Write-Host "Email français"
    }
    "*admin*" {
        Write-Host "Compte administrateur"
    }
    default {
        Write-Host "Email externe"
    }
}
```

> [!warning] Attention aux correspondances multiples Avec `-Wildcard`, plusieurs patterns peuvent correspondre. Par défaut, tous les blocs correspondants seront exécutés (voir section [Multiples correspondances](https://claude.ai/chat/0b79a522-c863-42b6-b043-0c7d59a3e32c#multiples-correspondances)).

---

## 🔍 Option -Regex

L'option `-Regex` permet d'utiliser des expressions régulières pour des correspondances plus complexes et précises.

```powershell
switch -Regex (expression) {
    pattern { # Code }
}
```

> [!info] Quand utiliser -Regex ?
> 
> - Validation de formats complexes (emails, téléphones, codes postaux)
> - Extraction de données structurées
> - Recherche de motifs spécifiques
> - Besoin de précision supérieure aux wildcards

### Exemples d'expressions régulières courantes

```powershell
$texte = "Mon email est contact@exemple.fr"

switch -Regex ($texte) {
    '\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b' {
        Write-Host "Contient une adresse email"
    }
    '^\d{5}$' {
        Write-Host "Code postal français"
    }
    '^0[1-9]\d{8}$' {
        Write-Host "Numéro de téléphone français"
    }
}
```

### Validation de données

```powershell
$input = "192.168.1.1"

switch -Regex ($input) {
    '^(\d{1,3}\.){3}\d{1,3}$' {
        Write-Host "Format d'adresse IP"
        # Vérification supplémentaire recommandée pour valider les octets
    }
    '^[A-Z]{2}\d{2}[A-Z0-9]{1,30}$' {
        Write-Host "IBAN potentiel"
    }
    '^\d{4}-\d{2}-\d{2}$' {
        Write-Host "Date au format YYYY-MM-DD"
    }
}
```

### Capture de groupes avec $matches

Lorsqu'une regex correspond, la variable automatique `$matches` contient les groupes capturés :

```powershell
$log = "Error: File not found at line 42"

switch -Regex ($log) {
    '^(Error|Warning|Info): (.+) at line (\d+)$' {
        Write-Host "Type: $($matches[1])"
        Write-Host "Message: $($matches[2])"
        Write-Host "Ligne: $($matches[3])"
    }
}
# Affiche :
# Type: Error
# Message: File not found
# Ligne: 42
```

> [!tip] Astuce : Groupes nommés
> 
> ```powershell
> $date = "2024-03-15"
> 
> switch -Regex ($date) {
>     '^(?<annee>\d{4})-(?<mois>\d{2})-(?<jour>\d{2})$' {
>         Write-Host "Année: $($matches['annee'])"
>         Write-Host "Mois: $($matches['mois'])"
>         Write-Host "Jour: $($matches['jour'])"
>     }
> }
> ```

---

## 🔤 Option -CaseSensitive

Par défaut, le `switch` PowerShell est **insensible à la casse** (case-insensitive). L'option `-CaseSensitive` force une comparaison stricte.

```powershell
# Sans -CaseSensitive (défaut)
$texte = "PowerShell"

switch ($texte) {
    "powershell" { Write-Host "Match !" }  # ✅ Correspond
    "POWERSHELL" { Write-Host "Match !" }  # ✅ Correspond aussi
}

# Avec -CaseSensitive
switch -CaseSensitive ($texte) {
    "powershell" { Write-Host "Match !" }  # ❌ Ne correspond pas
    "PowerShell" { Write-Host "Match !" }  # ✅ Correspond exactement
    "POWERSHELL" { Write-Host "Match !" }  # ❌ Ne correspond pas
}
```

### Cas d'usage typiques

```powershell
# Validation de constantes strictes
$niveau = "ERROR"

switch -CaseSensitive ($niveau) {
    "ERROR" { 
        Write-Host "Erreur majeure" -ForegroundColor Red 
    }
    "error" { 
        Write-Host "Erreur mineure" -ForegroundColor Yellow 
    }
    "Warning" { 
        Write-Host "Avertissement" 
    }
}

# Traitement de codes sensibles à la casse
$code = "UsR"

switch -CaseSensitive ($code) {
    "USR" { "Utilisateur administrateur" }
    "usr" { "Utilisateur standard" }
    "UsR" { "Utilisateur invité" }
}
```

> [!warning] Combinaison avec -Wildcard et -Regex L'option `-CaseSensitive` fonctionne aussi avec `-Wildcard` et `-Regex` :
> 
> ```powershell
> switch -Wildcard -CaseSensitive ($fichier) {
>     "*.TXT" { "Fichier .TXT en majuscules" }
>     "*.txt" { "Fichier .txt en minuscules" }
> }
> 
> switch -Regex -CaseSensitive ($texte) {
>     '^ERROR' { "Erreur en majuscules" }
>     '^error' { "Erreur en minuscules" }
> }
> ```

---

## 📄 Option -File

L'option `-File` permet de traiter chaque ligne d'un fichier texte comme une valeur d'entrée pour le `switch`. C'est extrêmement utile pour le traitement de logs, fichiers de configuration, ou listes.

```powershell
switch -File chemin\vers\fichier.txt {
    pattern1 { # Code pour pattern1 }
    pattern2 { # Code pour pattern2 }
}
```

> [!info] Fonctionnement PowerShell lit le fichier ligne par ligne et compare chaque ligne contre les patterns définis. La variable `$_` contient la ligne courante.

### Exemple : Analyse de logs

Contenu de `logs.txt` :

```
INFO: Application démarrée
ERROR: Connexion échouée
WARNING: Mémoire faible
INFO: Traitement terminé
ERROR: Fichier introuvable
```

```powershell
switch -File "logs.txt" {
    "ERROR*" {
        Write-Host "🔴 $_" -ForegroundColor Red
    }
    "WARNING*" {
        Write-Host "🟡 $_" -ForegroundColor Yellow
    }
    "INFO*" {
        Write-Host "🟢 $_" -ForegroundColor Green
    }
}
```

### Combinaison avec -Regex

```powershell
# Analyse de fichier de configuration
switch -Regex -File "config.ini" {
    '^\[(.+)\]$' {
        Write-Host "`nSection: $($matches[1])" -ForegroundColor Cyan
    }
    '^(\w+)=(.+)$' {
        $key = $matches[1]
        $value = $matches[2]
        Write-Host "  $key = $value"
    }
    '^#' {
        # Ignorer les commentaires
    }
}
```

### Comptage et statistiques

```powershell
# Compter les types de messages dans un log
$stats = @{
    Errors = 0
    Warnings = 0
    Info = 0
}

switch -Wildcard -File "application.log" {
    "*ERROR*" { $stats.Errors++ }
    "*WARNING*" { $stats.Warnings++ }
    "*INFO*" { $stats.Info++ }
}

Write-Host "Statistiques du log:"
Write-Host "Erreurs: $($stats.Errors)"
Write-Host "Warnings: $($stats.Warnings)"
Write-Host "Info: $($stats.Info)"
```

> [!tip] Astuce : Filtrage avancé
> 
> ```powershell
> # Extraire uniquement les erreurs d'un log et les sauvegarder
> switch -Regex -File "app.log" {
>     '^ERROR: (.+)$' {
>         $matches[1] | Add-Content "erreurs_extraites.txt"
>     }
> }
> ```

> [!warning] Performance avec grands fichiers Pour les très gros fichiers (plusieurs Go), l'option `-File` peut être lente. Dans ce cas, privilégiez `Get-Content -ReadCount` ou le traitement par flux avec `StreamReader`.

---

## 🎲 Clause default

La clause `default` est exécutée lorsqu'aucune autre condition ne correspond. C'est l'équivalent du `else` final dans une structure `if/elseif/else`.

```powershell
switch (expression) {
    valeur1 { # Code }
    valeur2 { # Code }
    default { 
        # Code exécuté si aucune correspondance
    }
}
```

> [!info] Caractéristiques de default
> 
> - Optionnel mais recommandé pour gérer les cas imprévus
> - Toujours placé en dernier (par convention)
> - Exécuté une seule fois, même si plusieurs patterns ne correspondent pas
> - Ne bloque pas les correspondances multiples (voir section suivante)

### Exemples pratiques

```powershell
# Gestion de commandes utilisateur
$commande = "STATUS"

switch ($commande) {
    "START" { 
        Write-Host "Démarrage du service..." 
    }
    "STOP" { 
        Write-Host "Arrêt du service..." 
    }
    "RESTART" { 
        Write-Host "Redémarrage..." 
    }
    default { 
        Write-Host "Commande '$commande' non reconnue"
        Write-Host "Commandes disponibles: START, STOP, RESTART"
    }
}
```

### Default avec validation

```powershell
$age = 150

switch ($age) {
    { $_ -lt 0 } {
        Write-Host "Âge invalide (négatif)" -ForegroundColor Red
    }
    { $_ -ge 0 -and $_ -lt 18 } {
        Write-Host "Mineur"
    }
    { $_ -ge 18 -and $_ -lt 65 } {
        Write-Host "Adulte"
    }
    { $_ -ge 65 -and $_ -lt 120 } {
        Write-Host "Senior"
    }
    default {
        Write-Host "Âge invalide (hors limites réalistes)" -ForegroundColor Red
    }
}
```

### Default avec logging

```powershell
$action = "DELETE_ALL"

switch ($action) {
    "READ" { 
        Invoke-ReadOperation 
    }
    "WRITE" { 
        Invoke-WriteOperation 
    }
    "UPDATE" { 
        Invoke-UpdateOperation 
    }
    default {
        $message = "Action non autorisée: $action à $(Get-Date)"
        Add-Content -Path "security.log" -Value $message
        Write-Warning "Action refusée et journalisée"
    }
}
```

> [!tip] Astuce : Default pour debug
> 
> ```powershell
> switch ($value) {
>     "expected1" { "OK" }
>     "expected2" { "OK" }
>     default {
>         Write-Host "DEBUG: Valeur inattendue = $value" -ForegroundColor Magenta
>         Write-Host "Type: $($value.GetType().Name)"
>         Write-Host "Contenu: $($value | Out-String)"
>     }
> }
> ```

---

## 🔄 Multiples correspondances

Par défaut, le `switch` PowerShell **continue d'évaluer toutes les conditions** même après avoir trouvé une correspondance. C'est un comportement différent des langages comme C# ou Java.

```powershell
$nombre = 10

switch ($nombre) {
    10 {
        Write-Host "C'est 10"
    }
    { $_ -gt 5 } {
        Write-Host "Plus grand que 5"
    }
    { $_ % 2 -eq 0 } {
        Write-Host "C'est un nombre pair"
    }
    default {
        Write-Host "Valeur par défaut"
    }
}
# Affiche :
# C'est 10
# Plus grand que 5
# C'est un nombre pair
```

> [!info] Pourquoi ce comportement ? Cela permet de traiter un même élément selon plusieurs critères simultanément, particulièrement utile pour :
> 
> - Catégorisation multiple
> - Application de plusieurs règles
> - Collecte de statistiques
> - Validation multi-critères

### Exemple : Catégorisation multiple

```powershell
$fichier = "rapport_important_2024.xlsx"

switch -Wildcard ($fichier) {
    "*rapport*" {
        Write-Host "📊 Type: Rapport"
    }
    "*important*" {
        Write-Host "⚠️  Priorité: Important"
    }
    "*2024*" {
        Write-Host "📅 Année: 2024"
    }
    "*.xlsx" {
        Write-Host "📑 Format: Excel"
    }
}
# Affiche les 4 messages
```

### Collecte d'informations

```powershell
$user = "admin_john_active"
$roles = @()
$status = ""

switch -Wildcard ($user) {
    "*admin*" {
        $roles += "Administrator"
    }
    "*manager*" {
        $roles += "Manager"
    }
    "*user*" {
        $roles += "User"
    }
    "*active*" {
        $status = "Active"
    }
    "*inactive*" {
        $status = "Inactive"
    }
}

Write-Host "Rôles: $($roles -join ', ')"
Write-Host "Statut: $status"
```

> [!warning] Impact sur default La clause `default` s'exécute **uniquement** si aucune autre condition ne correspond. Si au moins une condition correspond, `default` n'est pas exécuté, même si d'autres conditions ne correspondent pas.
> 
> ```powershell
> switch (5) {
>     1 { "Un" }
>     5 { "Cinq" }         # ✅ Correspond
>     10 { "Dix" }         # ❌ Ne correspond pas
>     default { "Autre" }  # ❌ N'est PAS exécuté car 5 a correspondu
> }
> ```

---

## ⛔ Break et Continue

Les instructions `break` et `continue` permettent de contrôler le flux d'exécution dans un `switch`.

### Break

`break` arrête immédiatement l'évaluation du `switch` et sort de la structure.

```powershell
$nombre = 10

switch ($nombre) {
    10 {
        Write-Host "C'est 10"
        break  # Sort immédiatement du switch
    }
    { $_ -gt 5 } {
        Write-Host "Plus grand que 5"  # Ne sera jamais exécuté
    }
    { $_ % 2 -eq 0 } {
        Write-Host "Nombre pair"  # Ne sera jamais exécuté
    }
}
# Affiche uniquement : C'est 10
```

#### Cas d'usage de break

```powershell
# Recherche du premier match
$fichiers = @("data.txt", "config.xml", "backup.zip", "readme.md")

foreach ($fichier in $fichiers) {
    switch -Wildcard ($fichier) {
        "*.txt" {
            Write-Host "Fichier texte trouvé: $fichier"
            break  # Trouve le premier, puis passe au suivant
        }
        "*.xml" {
            Write-Host "Fichier config trouvé: $fichier"
            break
        }
        default {
            Write-Host "Autre type: $fichier"
        }
    }
}
```

### Continue

`continue` passe immédiatement à l'itération suivante dans le contexte d'une boucle englobante.

> [!warning] Continue dans switch `continue` n'a de sens que si le `switch` est **à l'intérieur d'une boucle** (foreach, for, while). Il ne fait rien dans un switch isolé.

```powershell
# Continue pour sauter des éléments
$nombres = 1..10

foreach ($n in $nombres) {
    switch ($n) {
        { $_ % 2 -eq 0 } {
            Write-Host "$n est pair"
            continue  # Passe au nombre suivant dans foreach
        }
        { $_ -gt 7 } {
            Write-Host "$n est grand"
        }
        default {
            Write-Host "$n"
        }
    }
}
```

### Différence break vs continue

|Instruction|Effet dans switch|Effet dans boucle englobante|
|---|---|---|
|`break`|Sort du switch|Continue la boucle|
|`continue`|(Pas d'effet direct)|Passe à l'itération suivante|

```powershell
# Démonstration break vs continue
Write-Host "=== Test avec break ==="
foreach ($i in 1..5) {
    Write-Host "Nombre: $i"
    switch ($i) {
        3 {
            Write-Host "  C'est 3 !"
            break  # Sort du switch, mais continue la boucle
        }
        default {
            Write-Host "  Pas 3"
        }
    }
}

Write-Host "`n=== Test avec continue ==="
foreach ($i in 1..5) {
    Write-Host "Nombre: $i"
    switch ($i) {
        3 {
            Write-Host "  C'est 3 ! On saute."
            continue  # Passe au nombre suivant dans foreach
        }
        default {
            Write-Host "  Pas 3"
        }
    }
    Write-Host "  Après le switch"  # Ne s'affiche pas pour 3
}
```

> [!tip] Astuce : Break pour optimisation Utilisez `break` pour éviter des évaluations inutiles quand vous savez qu'une seule correspondance est nécessaire :
> 
> ```powershell
> switch ($type) {
>     "A" { 
>         $resultat = "Type A détecté"
>         break  # Inutile d'évaluer le reste
>     }
>     "B" { $resultat = "Type B détecté"; break }
>     "C" { $resultat = "Type C détecté"; break }
>     default { $resultat = "Type inconnu" }
> }
> ```

---

## ⚖️ Switch vs If/ElseIf

Le choix entre `switch` et `if/elseif` dépend du contexte. Voici une comparaison détaillée.

### Tableau comparatif

|Critère|Switch|If/ElseIf|
|---|---|---|
|**Lisibilité**|✅ Excellent pour tester une même variable|✅ Meilleur pour conditions complexes|
|**Performance**|✅ Plus rapide pour nombreuses comparaisons|⚠️ Ralentit avec beaucoup de conditions|
|**Flexibilité**|⚠️ Une seule expression testée|✅ Conditions multiples et variées|
|**Wildcards/Regex**|✅ Support natif|❌ Nécessite des opérateurs `-like`, `-match`|
|**Multiples matches**|✅ Par défaut|❌ S'arrête au premier match|
|**Fichiers**|✅ Option `-File` intégrée|❌ Nécessite Get-Content|

### Quand utiliser Switch ?

✅ **Utilisez switch quand :**

1. **Tester une seule variable contre plusieurs valeurs**

```powershell
# ✅ Parfait pour switch
switch ($statut) {
    "actif" { ... }
    "inactif" { ... }
    "suspendu" { ... }
    "bloqué" { ... }
}

# ❌ Répétitif avec if
if ($statut -eq "actif") { ... }
elseif ($statut -eq "inactif") { ... }
elseif ($statut -eq "suspendu") { ... }
elseif ($statut -eq "bloqué") { ... }
```

2. **Utiliser des patterns (wildcards/regex)**

```powershell
# ✅ Élégant avec switch
switch -Wildcard ($fichier) {
    "*.txt" { ... }
    "*.log" { ... }
    "backup_*" { ... }
}

# ❌ Verbeux avec if
if ($fichier -like "*.txt") { ... }
elseif ($fichier -like "*.log") { ... }
elseif ($fichier -like "backup_*") { ... }
```

3. **Besoin de multiples correspondances**

```powershell
# ✅ Switch évalue tout naturellement
switch -Wildcard ($tag) {
    "*urgent*" { $priorite = "haute" }
    "*important*" { $flagged = $true }
    "*archive*" { $archiver = $true }
}
```

4. **Traiter des fichiers ligne par ligne**

```powershell
# ✅ Très simple avec switch
switch -File "config.txt" {
    "*.conf" { ... }
    "#*" { ... }
}
```

### Quand utiliser If/ElseIf ?

✅ **Utilisez if/elseif quand :**

1. **Tester différentes variables**

```powershell
# ✅ If/ElseIf obligatoire
if ($age -gt 18 -and $permis -eq $true) {
    Write-Host "Peut conduire"
}
elseif ($age -gt 16) {
    Write-Host "Conduite accompagnée"
}
else {
    Write-Host "Trop jeune"
}
```

2. **Conditions complexes avec logique booléenne**

```powershell
# ✅ If plus adapté
if ($user.Role -eq "Admin" -and $user.Active -and $user.LastLogin -gt (Get-Date).AddDays(-30)) {
    Grant-FullAccess
}
elseif ($user.Role -eq "Manager" -or $user.Temporary) {
    Grant-LimitedAccess
}
```

3. **Comparaisons de plages**

```powershell
# ✅ If plus lisible
if ($score -ge 90) {
    $grade = "A"
}
elseif ($score -ge 80) {
    $grade = "B"
}
elseif ($score -ge 70) {
    $grade = "C"
}
```

4. **Arrêt au premier match souhaité** (sans break)

```powershell
# ✅ If s'arrête naturellement
if ($error) {
    Handle-Error
}
elseif ($warning) {
    Handle-Warning
}
else {
    Process-Normal
}
```

### Exemples de conversion

#### Cas simple : Switch gagne

```powershell
# ❌ If/ElseIf verbeux
if ($jour -eq "Lundi") {
    $travail = $true
}
elseif ($jour -eq "Mardi") {
    $travail = $true
}
elseif ($jour -eq "Mercredi") {
    $travail = $true
}
elseif ($jour -eq "Jeudi") {
    $travail = $true
}
elseif ($jour -eq "Vendredi") {
    $travail = $true
}
else {
    $travail = $false
}

# ✅ Switch concis
switch ($jour) {
    { $_ -in "Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi" } {
        $travail = $true
    }
    default {
        $travail = $false
    }
}
```

#### Cas complexe : If/ElseIf gagne

```powershell
# ✅ If/ElseIf plus adapté
if ($temperature -gt 30 -and $humidite -gt 70) {
    Write-Host "Canicule dangereuse"
}
elseif ($temperature -lt 0 -and $vent -gt 20) {
    Write-Host "Froid glacial"
}
elseif ($pluie -and $temperature -gt 0 -and $temperature -lt 5) {
    Write-Host "Risque de verglas"
}
else {
    Write-Host "Conditions normales"
}

# ❌ Switch difficile à adapter ici
# (nécessiterait des scriptblocks complexes)
```

### Cas hybride

Parfois, combiner les deux est la meilleure solution :

```powershell
# Utiliser switch pour catégoriser, if pour la logique
switch -Wildcard ($fichier) {
    "*.log" {
        $type = "log"
        if ((Get-Item $fichier).Length -gt 10MB) {
            Compress-Archive $fichier
        }
    }
    "*.tmp" {
        $type = "temporaire"
        if ((Get-Item $fichier).LastWriteTime -lt (Get-Date).AddDays(-7)) {
            Remove-Item $fichier
        }
    }
}
```

> [!tip] Règle générale **Une variable, plusieurs valeurs → Switch**  
> **Plusieurs variables, logique complexe → If/ElseIf**

---

## 🚀 Cas d'usage et performances

### Cas d'usage courants

#### 1. **Validation et routage**

```powershell
# Router des commandes API
function Invoke-ApiCommand {
    param($Action, $Data)
    
    switch ($Action) {
        "GET" {
            Get-Resource -Data $Data
        }
        "POST" {
            New-Resource -Data $Data
        }
        "PUT" {
            Update-Resource -Data $Data
        }
        "DELETE" {
            Remove-Resource -Data $Data
        }
        default {
            throw "Action non supportée: $Action"
        }
    }
}
```

#### 2. **Traitement de logs et fichiers**

```powershell
# Analyser un fichier de log Apache
$stats = @{
    GET = 0
    POST = 0
    Errors = 0
    Warnings = 0
}

switch -Regex -File "access.log" {
    '"\s+GET\s+' { $stats.GET++ }
    '"\s+POST\s+' { $stats.POST++ }
    '\s+[45]\d{2}\s+' { $stats.Errors++ }
    'warn|warning' { $stats.Warnings++ }
}

Write-Host "Requêtes GET: $($stats.GET)"
Write-Host "Requêtes POST: $($stats.POST)"
Write-Host "Erreurs (4xx/5xx): $($stats.Errors)"
Write-Host "Avertissements: $($stats.Warnings)"
```

#### 3. **Gestion d'états et workflows**

```powershell
# Machine à états simple
$etat = "initialisation"

while ($etat -ne "termine") {
    switch ($etat) {
        "initialisation" {
            Write-Host "Initialisation..."
            $etat = "connexion"
        }
        "connexion" {
            Write-Host "Connexion à la base..."
            if (Test-Connection) {
                $etat = "traitement"
            } else {
                $etat = "erreur"
            }
        }
        "traitement" {
            Write-Host "Traitement des données..."
            $etat = "nettoyage"
        }
        "nettoyage" {
            Write-Host "Nettoyage..."
            $etat = "termine"
        }
        "erreur" {
            Write-Host "Erreur détectée"
            $etat = "termine"
        }
    }
}
```

#### 4. **Classification et tagging**

```powershell
# Classifier des serveurs selon leurs noms
$serveurs = @("WEB-PROD-01", "DB-TEST-03", "APP-DEV-12", "WEB-PROD-02")

foreach ($serveur in $serveurs) {
    $tags = @()
    
    switch -Wildcard ($serveur) {
        "*PROD*" { 
            $tags += "Production"
            $tags += "Critique"
        }
        "*TEST*" { 
            $tags += "Test"
        }
        "*DEV*" { 
            $tags += "Développement"
        }
        "WEB-*" { 
            $tags += "Serveur Web"
        }
        "DB-*" { 
            $tags += "Base de données"
        }
        "APP-*" { 
            $tags += "Application"
        }
    }
    
    Write-Host "$serveur → Tags: $($tags -join ', ')"
}
```

#### 5. **Configuration et paramètres**

```powershell
# Parser un fichier de configuration
$config = @{}

switch -Regex -File "app.config" {
    '^\[(.+)\] {
        $section = $matches[1]
        $config[$section] = @{}
    }
    '^(\w+)\s*=\s*(.+) {
        $key = $matches[1]
        $value = $matches[2]
        $config[$section][$key] = $value
    }
    '^#' {
        # Ignorer les commentaires
    }
    '^\s* {
        # Ignorer les lignes vides
    }
}

# Utiliser la configuration
Write-Host "Port: $($config['Server']['Port'])"
Write-Host "Timeout: $($config['Server']['Timeout'])"
```

### Performances

#### Comparaison des performances

```powershell
# Test de performance : Switch vs If/ElseIf
$testValue = 8

# Mesurer Switch
$switchTime = Measure-Command {
    for ($i = 0; $i -lt 10000; $i++) {
        switch ($testValue) {
            1 { $null }
            2 { $null }
            3 { $null }
            4 { $null }
            5 { $null }
            6 { $null }
            7 { $null }
            8 { $null }
            9 { $null }
            10 { $null }
        }
    }
}

# Mesurer If/ElseIf
$ifTime = Measure-Command {
    for ($i = 0; $i -lt 10000; $i++) {
        if ($testValue -eq 1) { $null }
        elseif ($testValue -eq 2) { $null }
        elseif ($testValue -eq 3) { $null }
        elseif ($testValue -eq 4) { $null }
        elseif ($testValue -eq 5) { $null }
        elseif ($testValue -eq 6) { $null }
        elseif ($testValue -eq 7) { $null }
        elseif ($testValue -eq 8) { $null }
        elseif ($testValue -eq 9) { $null }
        elseif ($testValue -eq 10) { $null }
    }
}

Write-Host "Switch: $($switchTime.TotalMilliseconds) ms"
Write-Host "If/ElseIf: $($ifTime.TotalMilliseconds) ms"
Write-Host "Différence: $(($ifTime.TotalMilliseconds - $switchTime.TotalMilliseconds)) ms"
```

> [!info] Résultats typiques Pour 10+ comparaisons, le `switch` est généralement **15-30% plus rapide** que `if/elseif` en raison de son optimisation interne.

#### Facteurs de performance

|Facteur|Impact|Recommandation|
|---|---|---|
|**Nombre de conditions**|⬆️ Plus il y en a, plus switch est avantageux|Switch si 5+ conditions|
|**Position de la valeur**|⬆️ If/ElseIf ralentit si match en fin de chaîne|Switch a une performance constante|
|**Utilisation de break**|⬇️ Réduit les évaluations|Utilisez break si une seule correspondance|
|**Regex complexes**|⬇️ Ralentit significativement|Optimisez vos regex, pré-compilez si possible|
|**Lecture de fichiers**|⬇️ I/O est le goulot|Utilisez `-File` pour l'efficacité mémoire|

#### Optimisations

**1. Ordonnez les cas par fréquence**

```powershell
# ✅ Bon : cas les plus fréquents en premier
switch ($statut) {
    "actif" { ... }        # 70% des cas
    "en_attente" { ... }   # 20% des cas
    "inactif" { ... }      # 8% des cas
    "erreur" { ... }       # 2% des cas
}

# ❌ Mauvais : cas rares en premier
switch ($statut) {
    "erreur" { ... }       # 2% des cas → évalué en premier !
    "inactif" { ... }
    "en_attente" { ... }
    "actif" { ... }        # 70% → évalué en dernier !
}
```

**2. Utilisez break pour éviter les évaluations inutiles**

```powershell
# ✅ Optimisé avec break
switch ($type) {
    "A" { 
        Process-TypeA
        break  # Économise l'évaluation des autres cas
    }
    "B" { Process-TypeB; break }
    "C" { Process-TypeC; break }
}

# ❌ Non optimisé : évalue tout
switch ($type) {
    "A" { Process-TypeA }
    "B" { Process-TypeB }
    "C" { Process-TypeC }
}
```

**3. Pré-compilez les regex complexes**

```powershell
# Pour des regex utilisées fréquemment
$emailRegex = [regex]::new('\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b', 
                           [System.Text.RegularExpressions.RegexOptions]::Compiled)

foreach ($ligne in $lignes) {
    if ($emailRegex.IsMatch($ligne)) {
        # Traitement
    }
}
```

**4. Évitez les scriptblocks complexes**

```powershell
# ❌ Scriptblock complexe évalué à chaque fois
switch ($valeur) {
    { (Get-Process | Measure-Object).Count -gt 50 } {
        # Cette requête est exécutée à chaque évaluation !
    }
}

# ✅ Calculez en amont
$processCount = (Get-Process | Measure-Object).Count

switch ($valeur) {
    { $processCount -gt 50 } {
        # Utilise une valeur pré-calculée
    }
}
```

### Pièges courants à éviter

> [!warning] Piège 1 : Oublier que switch continue par défaut
> 
> ```powershell
> # ⚠️ Tous les blocs correspondants s'exécutent !
> switch (5) {
>     5 { "Cinq" }
>     { $_ -gt 3 } { "Plus que 3" }
>     { $_ % 5 -eq 0 } { "Multiple de 5" }
> }
> # Affiche les 3 messages !
> 
> # ✅ Utilisez break si vous voulez un seul match
> switch (5) {
>     5 { "Cinq"; break }
>     { $_ -gt 3 } { "Plus que 3" }
>     { $_ % 5 -eq 0 } { "Multiple de 5" }
> }
> ```

> [!warning] Piège 2 : Sensibilité à la casse par défaut
> 
> ```powershell
> # ⚠️ Correspond car insensible par défaut
> switch ("PowerShell") {
>     "powershell" { "Match !" }  # ✅ Correspond
> }
> 
> # ✅ Soyez explicite si nécessaire
> switch -CaseSensitive ("PowerShell") {
>     "powershell" { "Match !" }  # ❌ Ne correspond pas
>     "PowerShell" { "Match !" }  # ✅ Correspond
> }
> ```

> [!warning] Piège 3 : Continue dans switch sans boucle
> 
> ```powershell
> # ⚠️ Continue n'a aucun effet ici
> switch ($valeur) {
>     1 { 
>         Write-Host "Un"
>         continue  # Ne fait RIEN (pas dans une boucle)
>     }
>     2 { Write-Host "Deux" }
> }
> 
> # ✅ Continue n'a de sens que dans une boucle
> foreach ($v in $valeurs) {
>     switch ($v) {
>         1 { 
>             Write-Host "Un"
>             continue  # Passe au prochain élément de foreach
>         }
>     }
> }
> ```

> [!warning] Piège 4 : Wildcards sans -Wildcard
> 
> ```powershell
> # ❌ Le * est traité littéralement
> switch ($fichier) {
>     "*.txt" { "Fichier texte" }  # Ne fonctionne pas !
> }
> 
> # ✅ Utilisez l'option -Wildcard
> switch -Wildcard ($fichier) {
>     "*.txt" { "Fichier texte" }  # Fonctionne !
> }
> ```

---

## 🎓 Bonnes pratiques récapitulatives

### ✅ À faire

1. **Utilisez switch pour tester une seule variable contre plusieurs valeurs**
2. **Ajoutez toujours une clause `default` pour gérer les cas imprévus**
3. **Utilisez `break` quand vous ne voulez qu'une seule correspondance**
4. **Ordonnez les cas par fréquence d'occurrence pour optimiser les performances**
5. **Exploitez `-Wildcard` et `-Regex` pour les patterns complexes**
6. **Utilisez `-File` pour traiter efficacement des fichiers ligne par ligne**
7. **Combinez `-CaseSensitive` avec `-Wildcard` ou `-Regex` si nécessaire**
8. **Documentez les switch complexes avec des commentaires**

### ❌ À éviter

1. **Ne pas utiliser switch pour des conditions testant plusieurs variables différentes**
2. **Ne pas oublier que switch continue par défaut (sauf avec break)**
3. **Ne pas utiliser `-Wildcard` pour des comparaisons exactes simples**
4. **Ne pas créer des scriptblocks trop complexes dans les conditions**
5. **Ne pas utiliser `continue` dans un switch en dehors d'une boucle**
6. **Ne pas négliger les performances avec des regex non optimisées**
7. **Ne pas abuser des multiples correspondances sans raison valable**

---

## 📚 Récapitulatif syntaxique

```powershell
# Syntaxe complète avec toutes les options
switch [-Regex] [-Wildcard] [-CaseSensitive] [-File] (expression) {
    pattern1 { 
        # Code
        break      # Optionnel : sort du switch
        continue   # Optionnel : dans une boucle, passe à l'itération suivante
    }
    pattern2 { # Code }
    { scriptblock } { # Code }
    default { # Code pour aucune correspondance }
}
```

### Tableau des options

|Option|Description|Exemple|
|---|---|---|
|`-Wildcard`|Active les caractères génériques `*` et `?`|`"*.txt"`|
|`-Regex`|Active les expressions régulières|`'^\d{5}`|
|`-CaseSensitive`|Compare en tenant compte de la casse|`"ERROR"` ≠ `"error"`|
|`-File`|Lit un fichier ligne par ligne|`switch -File "log.txt"`|
|(combinaison)|Les options peuvent être combinées|`-Regex -CaseSensitive`|

---

## 🎯 Conclusion

Le `switch` PowerShell est une structure de contrôle puissante et flexible qui offre :

- **Simplicité** pour les cas de comparaison multiples
- **Performance** supérieure aux chaînes if/elseif
- **Flexibilité** avec wildcards, regex, et fichiers
- **Expressivité** grâce aux multiples correspondances

Maîtriser le `switch` vous permettra d'écrire du code PowerShell plus lisible, maintenable et performant.

> [!tip] Conseil final Commencez par des switch simples, puis explorez progressivement les options avancées (-Regex, -File) au fur et à mesure de vos besoins. Le switch deviendra rapidement un outil indispensable dans votre boîte à outils PowerShell !