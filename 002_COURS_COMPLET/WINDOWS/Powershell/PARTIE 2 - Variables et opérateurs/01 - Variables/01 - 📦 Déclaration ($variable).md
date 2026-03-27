
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

## Introduction aux variables

Les variables PowerShell sont des conteneurs qui stockent des données en mémoire pendant l'exécution d'un script ou d'une session. Contrairement à d'autres langages, PowerShell est **dynamiquement typé** : une variable peut contenir n'importe quel type de données sans déclaration explicite.

> [!info] Pourquoi utiliser des variables ?
> 
> - Stocker des résultats de commandes pour réutilisation
> - Rendre le code plus lisible et maintenable
> - Éviter de répéter des calculs coûteux
> - Passer des données entre différentes parties du script

---

## Déclaration de variables ($variable)

### Syntaxe de base

En PowerShell, toutes les variables commencent par le symbole **`$`** (dollar). La déclaration et l'assignation se font en une seule ligne :

```powershell
# Déclaration et assignation simple
$nom = "Alice"
$age = 30
$salaire = 45000.50

# Affichage
Write-Host "Nom : $nom"
Write-Host "Age : $age"
Write-Host "Salaire : $salaire"
```

> [!tip] Astuce Vous n'avez pas besoin de déclarer une variable avant de l'utiliser. L'assignation crée automatiquement la variable.

### Règles de nommage

PowerShell est **insensible à la casse** pour les noms de variables, mais suit des conventions strictes :

|Règle|Valide ✅|Invalide ❌|
|---|---|---|
|Commence par lettre ou underscore|`$nom`, `$_temp`|`$1nom`, `$-test`|
|Peut contenir lettres, chiffres, underscore|`$user1`, `$mon_nom`|`$mon-nom`, `$mon nom`|
|Pas de caractères spéciaux sauf underscore|`$ma_variable`|`$ma@variable`, `$ma#variable`|
|Insensible à la casse|`$Nom` = `$nom` = `$NOM`|-|

```powershell
# Exemples valides
$utilisateur = "Jean"
$nombre_total = 100
$_temp = "temporaire"
$MaVariableLongue = "valeur"

# Exemples invalides qui génèrent des erreurs
# $1variable = "test"        # Commence par un chiffre
# $mon-nom = "Jean"          # Contient un tiret
# $ma variable = "test"      # Contient un espace
```

> [!warning] Convention de nommage Bien que PowerShell soit insensible à la casse, il est recommandé d'utiliser :
> 
> - **PascalCase** pour les variables importantes : `$UserName`, `$TotalCount`
> - **camelCase** pour les variables locales : `$firstName`, `$itemCount`
> - **lowercase_underscore** pour les variables temporaires : `$temp_value`, `$old_data`

---

## Variables non typées vs typées

PowerShell permet de travailler avec des variables **non typées** (dynamiques) ou **typées** (statiques).

### Variables non typées (par défaut)

```powershell
# La variable peut changer de type
$variable = 42              # Nombre entier
$variable = "Texte"         # Maintenant une chaîne
$variable = Get-Date        # Maintenant un objet DateTime
$variable = @(1, 2, 3)      # Maintenant un tableau

# PowerShell s'adapte automatiquement
Write-Host $variable.GetType().Name
```

### Variables typées

Vous pouvez forcer un type en utilisant des **crochets** devant le nom de la variable :

```powershell
# Déclaration typée
[int]$nombre = 42
[string]$texte = "Bonjour"
[datetime]$date = Get-Date
[bool]$actif = $true
[array]$liste = @(1, 2, 3)

# Tentative de changement de type = erreur
[int]$nombre = 42
$nombre = "texte"  # ❌ Erreur : impossible de convertir "texte" en int
```

> [!example] Exemple pratique
> 
> ```powershell
> # Sans typage : risque d'erreur
> $port = "8080"
> $port = $port + 1  # Résultat : "80801" (concaténation de chaîne)
> 
> # Avec typage : comportement prévisible
> [int]$port = 8080
> $port = $port + 1  # Résultat : 8081 (addition mathématique)
> ```

### Tableau des types courants

|Type|Syntaxe|Exemple|Description|
|---|---|---|---|
|Entier|`[int]`|`[int]$x = 42`|Nombre entier 32 bits|
|Entier long|`[long]`|`[long]$x = 9999999999`|Nombre entier 64 bits|
|Décimal|`[double]`|`[double]$x = 3.14`|Nombre à virgule flottante|
|Chaîne|`[string]`|`[string]$x = "texte"`|Texte|
|Booléen|`[bool]`|`[bool]$x = $true`|Vrai ou faux|
|Date/Heure|`[datetime]`|`[datetime]$x = Get-Date`|Date et heure|
|Tableau|`[array]`|`[array]$x = @(1,2,3)`|Collection d'éléments|
|Hashtable|`[hashtable]`|`[hashtable]$x = @{}`|Collection clé-valeur|

---

## Initialisation de variables

L'initialisation consiste à donner une valeur initiale à une variable lors de sa création.

```powershell
# Initialisation simple
$nom = "Alice"

# Initialisation multiple sur une ligne
$prenom, $nom, $age = "Jean", "Dupont", 30

# Initialisation avec résultat de commande
$fichiers = Get-ChildItem -Path C:\Temp
$date = Get-Date
$processus = Get-Process

# Initialisation avec expression
$total = 10 + 20
$message = "Bonjour " + $nom

# Initialisation avec valeur par défaut
$compteur = 0
$liste = @()  # Tableau vide
$dict = @{}   # Hashtable vide
```

> [!tip] Astuce d'initialisation
> 
> ```powershell
> # Initialisation conditionnelle (valeur par défaut si null)
> $config = $config ?? "valeur_par_defaut"
> 
> # Ou avec la syntaxe classique
> if ($null -eq $config) {
>     $config = "valeur_par_defaut"
> }
> ```

---

## Variables nulles et $null

`$null` est une valeur spéciale qui représente l'**absence de valeur**. C'est différent de zéro, d'une chaîne vide ou d'un tableau vide.

```powershell
# Assignation de null
$variable = $null

# Test de nullité (ATTENTION À L'ORDRE)
if ($null -eq $variable) {
    Write-Host "La variable est null"
}

# Différence entre null, vide et zéro
$a = $null           # Absence de valeur
$b = ""              # Chaîne vide (existe mais vide)
$c = 0               # Zéro (valeur numérique)
$d = @()             # Tableau vide (existe mais sans éléments)

# Test de chaque cas
$null -eq $a   # True
$null -eq $b   # False (chaîne vide n'est pas null)
$null -eq $c   # False (zéro n'est pas null)
$null -eq $d   # False (tableau vide n'est pas null)
```

> [!warning] Piège courant avec $null
> 
> ```powershell
> # ❌ MAUVAIS : ordre incorrect
> if ($variable -eq $null) {
>     # Peut ne pas fonctionner si $variable est un tableau
> }
> 
> # ✅ BON : $null à gauche de la comparaison
> if ($null -eq $variable) {
>     # Fonctionne toujours correctement
> }
> ```

### Vérification avancée de nullité

```powershell
# Vérifier null ou vide
function Test-NullOrEmpty {
    param($value)
    return ($null -eq $value) -or ($value -eq "") -or ($value.Count -eq 0)
}

# Utilisation
$test1 = $null
$test2 = ""
$test3 = @()

Test-NullOrEmpty $test1  # True
Test-NullOrEmpty $test2  # True
Test-NullOrEmpty $test3  # True
```

---

## Suppression de variables (Remove-Variable)

PowerShell permet de supprimer des variables de la mémoire avec `Remove-Variable`.

```powershell
# Création de variables
$temp1 = "valeur temporaire"
$temp2 = 42

# Suppression d'une variable
Remove-Variable -Name temp1

# Suppression avec alias
rv temp2

# Suppression de plusieurs variables
Remove-Variable -Name var1, var2, var3

# Suppression avec wildcard
$test1 = 1
$test2 = 2
$test3 = 3
Remove-Variable -Name test*  # Supprime test1, test2, test3

# Vérification de l'existence
Test-Path variable:temp1  # False (supprimée)
```

> [!warning] Attention
> 
> - Les variables automatiques (comme `$_`, `$PSVersionTable`) ne peuvent pas être supprimées
> - Supprimer une variable inexistante génère une erreur (utiliser `-ErrorAction SilentlyContinue`)

```powershell
# Suppression silencieuse (sans erreur)
Remove-Variable -Name variableInexistante -ErrorAction SilentlyContinue

# Alternative : vérifier avant de supprimer
if (Test-Path variable:maVariable) {
    Remove-Variable -Name maVariable
}
```

> [!info] Quand supprimer des variables ?
> 
> - Libérer de la mémoire après traitement de gros objets
> - Nettoyer l'environnement dans les scripts longs
> - Éviter les conflits de noms dans les boucles
> - Sécurité : effacer des données sensibles (mots de passe)

---

## Variables automatiques (built-in)

PowerShell fournit des **variables automatiques** créées et maintenues par le système. Elles sont en **lecture seule** et fournissent des informations sur l'environnement d'exécution.

### $PSVersionTable

Contient des informations détaillées sur la version de PowerShell et du système.

```powershell
# Afficher toutes les informations
$PSVersionTable

# Accéder à des propriétés spécifiques
$PSVersionTable.PSVersion         # Version de PowerShell (ex: 7.4.0)
$PSVersionTable.PSEdition         # Edition (Core ou Desktop)
$PSVersionTable.OS                # Système d'exploitation
$PSVersionTable.Platform          # Plateforme (Win32NT, Unix, etc.)

# Exemple de vérification de version
if ($PSVersionTable.PSVersion.Major -ge 7) {
    Write-Host "PowerShell 7 ou supérieur détecté"
}
```

> [!example] Utilisation pratique
> 
> ```powershell
> # Adapter le script selon la version
> if ($PSVersionTable.PSEdition -eq "Core") {
>     # Code spécifique à PowerShell Core
>     $separateur = "/"
> } else {
>     # Code spécifique à Windows PowerShell
>     $separateur = "\"
> }
> ```

---

### $HOME

Contient le chemin du **répertoire personnel** de l'utilisateur actuel.

```powershell
# Afficher le répertoire personnel
Write-Host $HOME
# Windows : C:\Users\VotreNom
# Linux/Mac : /home/VotreNom

# Utilisation pour accéder aux fichiers utilisateur
$documentsPath = Join-Path $HOME "Documents"
$configFile = Join-Path $HOME ".config\monapp\config.json"

# Créer un chemin dans le profil utilisateur
$backupFolder = "$HOME\Backups\$(Get-Date -Format 'yyyy-MM-dd')"
New-Item -Path $backupFolder -ItemType Directory -Force
```

> [!tip] Astuce multiplateforme `$HOME` fonctionne sur Windows, Linux et macOS, ce qui rend vos scripts portables.

---

### $PWD

Contient le **répertoire de travail actuel** (Present Working Directory).

```powershell
# Afficher le répertoire actuel
Write-Host $PWD
# Affiche : C:\Users\VotreNom\Documents (par exemple)

# Équivalent de Get-Location
Get-Location  # Même résultat que $PWD

# Utilisation dans les chemins relatifs
$fichierLocal = Join-Path $PWD "data.txt"
$sousDossier = "$PWD\temp"

# Sauvegarder et restaurer le répertoire
$ancienRepertoire = $PWD
Set-Location C:\Temp
# ... faire des opérations ...
Set-Location $ancienRepertoire
```

> [!info] Différence entre $PWD et $HOME
> 
> - `$HOME` : Répertoire personnel de l'utilisateur (fixe)
> - `$PWD` : Répertoire de travail actuel (change avec `Set-Location`)

---

### $_

La variable **`$_`** (aussi appelée `$PSItem`) représente l'**objet actuel dans le pipeline**. C'est l'une des variables les plus utilisées en PowerShell.

```powershell
# Dans un pipeline
1..5 | ForEach-Object {
    Write-Host "Nombre : $_"
}
# Affiche : Nombre : 1, Nombre : 2, etc.

# Avec Where-Object
Get-Process | Where-Object { $_.CPU -gt 10 }
# Filtre les processus avec CPU > 10

# Accès aux propriétés de l'objet
Get-ChildItem | ForEach-Object {
    Write-Host "Fichier : $($_.Name) - Taille : $($_.Length) octets"
}

# Dans les blocs de script
$nombres = 1..10
$nombres | ForEach-Object {
    $_ * 2  # Multiplie chaque nombre par 2
}
```

> [!example] Exemples avancés avec $_
> 
> ```powershell
> # Filtrage et transformation
> Get-Service | 
>     Where-Object { $_.Status -eq "Running" } |
>     ForEach-Object {
>         [PSCustomObject]@{
>             Nom = $_.Name
>             Description = $_.DisplayName
>             Demarrage = $_.StartType
>         }
>     }
> 
> # Calcul sur une collection
> $total = Get-ChildItem | 
>     Where-Object { -not $_.PSIsContainer } |
>     ForEach-Object { $_.Length } |
>     Measure-Object -Sum |
>     Select-Object -ExpandProperty Sum
> ```

> [!warning] Portée de $_ `$_` n'existe **que dans le contexte du pipeline ou du bloc de script**. En dehors, elle est `$null`.

---

### $Error

Contient un **tableau** de tous les objets d'erreur générés pendant la session, du plus récent au plus ancien.

```powershell
# Afficher la dernière erreur
$Error[0]

# Afficher toutes les erreurs
$Error

# Nombre d'erreurs
$Error.Count

# Détails de la dernière erreur
$Error[0].Exception.Message      # Message d'erreur
$Error[0].ScriptStackTrace       # Trace de la pile
$Error[0].InvocationInfo         # Informations sur l'invocation

# Effacer toutes les erreurs
$Error.Clear()
```

> [!example] Gestion d'erreurs pratique
> 
> ```powershell
> # Tenter une opération et capturer l'erreur
> try {
>     Get-Item "C:\FichierInexistant.txt" -ErrorAction Stop
> } catch {
>     Write-Host "Erreur capturée : $($Error[0].Exception.Message)"
>     Write-Host "Type d'erreur : $($Error[0].CategoryInfo.Category)"
> }
> 
> # Vérifier si des erreurs se sont produites
> if ($Error.Count -gt 0) {
>     Write-Warning "Des erreurs se sont produites pendant l'exécution"
>     $Error | ForEach-Object {
>         Write-Host "- $($_.Exception.Message)" -ForegroundColor Red
>     }
> }
> ```

> [!tip] Limiter la taille de $Error
> 
> ```powershell
> # Par défaut, $Error garde 256 erreurs
> $MaximumErrorCount = 50  # Limiter à 50 erreurs
> ```

---

### $true et $false

Variables booléennes **constantes** qui représentent les valeurs logiques vraie et fausse.

```powershell
# Utilisation directe
$actif = $true
$termine = $false

# Dans les conditions
if ($true) {
    Write-Host "Toujours exécuté"
}

if ($false) {
    Write-Host "Jamais exécuté"
}

# Comparaisons
$a = 10
$b = 20
$resultat = $a -lt $b  # $resultat vaut $true

# Opérateurs logiques
$condition1 = $true
$condition2 = $false

$et = $condition1 -and $condition2  # False
$ou = $condition1 -or $condition2   # True
$non = -not $condition1              # False
```

> [!info] Valeurs considérées comme $true ou $false En PowerShell, plusieurs valeurs sont automatiquement converties en booléen :
> 
> **Évaluées comme `$true` :**
> 
> - Nombres différents de zéro
> - Chaînes non vides
> - Tableaux non vides
> - Objets (tous sauf `$null`)
> 
> **Évaluées comme `$false` :**
> 
> - `$false`
> - `$null`
> - Zéro (0)
> - Chaîne vide ("")
> - Tableau vide (@())

```powershell
# Exemples de conversion implicite
if (42) { Write-Host "Vrai" }           # Vrai (nombre non nul)
if ("texte") { Write-Host "Vrai" }      # Vrai (chaîne non vide)
if (@(1,2,3)) { Write-Host "Vrai" }     # Vrai (tableau non vide)

if (0) { Write-Host "Faux" }            # Faux (zéro)
if ("") { Write-Host "Faux" }           # Faux (chaîne vide)
if ($null) { Write-Host "Faux" }        # Faux (null)
if (@()) { Write-Host "Faux" }          # Faux (tableau vide)
```

---

## Variables d'environnement ($env:)

Les **variables d'environnement** sont des variables système qui stockent des informations sur l'environnement d'exécution. Elles sont accessibles via le préfixe **`$env:`**.

### Accès aux variables d'environnement

```powershell
# Lire une variable d'environnement
Write-Host $env:USERNAME      # Nom de l'utilisateur
Write-Host $env:COMPUTERNAME  # Nom de l'ordinateur
Write-Host $env:USERPROFILE   # Profil utilisateur (Windows)
Write-Host $env:HOME          # Répertoire personnel (Linux/Mac)
Write-Host $env:PATH          # Chemins d'exécution

# Vérifier l'existence d'une variable
if ($env:MONAPP_CONFIG) {
    Write-Host "Variable trouvée : $env:MONAPP_CONFIG"
}
```

### Variables d'environnement courantes

| Variable                      | Description                      | Exemple                            |
| ----------------------------- | -------------------------------- | ---------------------------------- |
| `$env:USERNAME`               | Nom de l'utilisateur             | `Jean`                             |
| `$env:COMPUTERNAME`           | Nom de l'ordinateur              | `PC-BUREAU-01`                     |
| `$env:USERPROFILE`            | Profil utilisateur (Windows)     | `C:\Users\Jean`                    |
| `$env:HOME`                   | Répertoire personnel (Linux/Mac) | `/home/jean`                       |
| `$env:TEMP`                   | Dossier temporaire               | `C:\Users\Jean\AppData\Local\Temp` |
| `$env:PATH`                   | Chemins d'exécution              | `C:\Windows;C:\Program Files;...`  |
| `$env:PROCESSOR_ARCHITECTURE` | Architecture CPU                 | `AMD64`                            |
| `$env:OS`                     | Système d'exploitation           | `Windows_NT`                       |

### Créer et modifier des variables d'environnement

```powershell
# Créer une variable d'environnement (session actuelle uniquement)
$env:MA_VARIABLE = "valeur"

# Modifier une variable existante
$env:PATH = "$env:PATH;C:\MonDossier\bin"

# Supprimer une variable d'environnement
$env:MA_VARIABLE = $null
Remove-Item env:MA_VARIABLE

# Créer une variable persistante (Windows)
[System.Environment]::SetEnvironmentVariable(
    "MA_VAR_PERMANENTE",
    "valeur",
    [System.EnvironmentVariableTarget]::User  # User ou Machine
)

# Lire une variable persistante
[System.Environment]::GetEnvironmentVariable("MA_VAR_PERMANENTE", "User")
```

> [!warning] Portée des variables d'environnement
> 
> - **Session actuelle** : `$env:VARIABLE = "valeur"` (perdue à la fermeture)
> - **Utilisateur** : Persiste pour cet utilisateur (clé registre `HKCU`)
> - **Système** : Persiste pour tous les utilisateurs (clé registre `HKLM`, nécessite admin)

### Lister toutes les variables d'environnement

```powershell
# Méthode 1 : Via Get-ChildItem
Get-ChildItem env: | Sort-Object Name

# Méthode 2 : Via Get-Item
Get-Item env:*

# Méthode 3 : Formaté en tableau
Get-ChildItem env: | Format-Table Name, Value -AutoSize

# Filtrer par nom
Get-ChildItem env: | Where-Object { $_.Name -like "*PATH*" }
```

> [!example] Utilisation pratique
> 
> ```powershell
> # Configuration d'application avec variables d'environnement
> $dbHost = $env:DB_HOST ?? "localhost"
> $dbPort = $env:DB_PORT ?? "5432"
> $dbName = $env:DB_NAME ?? "myapp"
> 
> Write-Host "Connexion à $dbHost:$dbPort/$dbName"
> 
> # Vérifier l'environnement d'exécution
> if ($env:COMPUTERNAME -eq "PROD-SERVER") {
>     Write-Host "Environnement de production détecté"
>     $logLevel = "Error"
> } else {
>     Write-Host "Environnement de développement"
>     $logLevel = "Debug"
> }
> ```

---

## Pièges courants et bonnes pratiques

### ⚠️ Pièges courants

> [!warning] Piège 1 : Comparaison avec $null
> 
> ```powershell
> # ❌ MAUVAIS : $null à droite
> if ($tableau -eq $null) { }  # Peut échouer avec tableaux
> 
> # ✅ BON : $null à gauche
> if ($null -eq $tableau) { }  # Toujours fiable
> ```

> [!warning] Piège 2 : Variables non initialisées
> 
> ```powershell
> # ❌ Utiliser une variable non définie
> $total = $total + 10  # $total est $null au départ
> 
> # ✅ Initialiser avant utilisation
> $total = 0
> $total = $total + 10
> ```

> [!warning] Piège 3 : Portée de $_
> 
> ```powershell
> # ❌ $_ en dehors du pipeline
> $elements | ForEach-Object { $temp = $_ }
> Write-Host $temp  # ❌ $temp contient le dernier élément, pas $_
> 
> # ✅ Utiliser $_ dans le bon contexte
> $elements | ForEach-Object {
>     Write-Host "Élément : $_"  # ✅ Correct
> }
> ```

> [!warning] Piège 4 : Modification de $env:PATH
> 
> ```powershell
> # ❌ Écraser PATH
> $env:PATH = "C:\MonDossier"  # ❌ Perd tous les chemins existants
> 
> # ✅ Ajouter à PATH
> $env:PATH = "$env:PATH;C:\MonDossier"  # ✅ Conserve les chemins
> ```

### ✅ Bonnes pratiques

> [!tip] Pratique 1 : Nommage cohérent
> 
> ```powershell
> # Utilisez des noms descriptifs
> ✅ $utilisateurActif, $nombreTotal, $cheminFichier
> ❌ $u, $n, $x, $temp
> 
> # Convention pour les boucles : noms courts acceptables
> ✅ $i, $j, $k (indices de boucles)
> ✅ $item, $element (objets dans foreach)
> ```

> [!tip] Pratique 2 : Typage pour la robustesse
> 
> ```powershell
> # Types pour les paramètres critiques
> [int]$port = 8080
> [string]$serveur = "localhost"
> [bool]$actif = $true
> 
> # Évite les erreurs de conversion silencieuses
> ```

> [!tip] Pratique 3 : Validation des entrées
> 
> ```powershell
> # Toujours valider les paramètres
> if ($null -eq $parametre) {
>     throw "Le paramètre est requis"
> }
> 
> if ($port -lt 1 -or $port -gt 65535) {
>     throw "Port invalide : $port"
> }
> ```

> [!tip] Pratique 4 : Nettoyage des ressources
> 
> ```powershell
> # Nettoyer les variables temporaires volumineuses
> $grossesDonnees = Import-Csv "fichier_volumineux.csv"
> # ... traitement ...
> Remove-Variable grossesDonnees  # Libérer la mémoire
> 
> # Effacer les données sensibles
> $motDePasse = "secret123"
> # ... utilisation ...
> $motDePasse = $null
> Remove-Variable motDePasse
> ```

> [!tip] Pratique 5 : Documentation
> 
> ```powershell
> # Commenter les variables non évidentes
> $seuilAlerte = 80  # Pourcentage d'utilisation CPU avant alerte
> $delaiRessai = 5   # Secondes entre chaque tentative
> 
> # Utiliser des variables pour les "magic numbers"
> ❌ if ($cpu -gt 80) { }
> ✅ $seuilAlerte = 80
>    if ($cpu -gt $seuilAlerte) { }
> ```

---

## 🎯 Résumé

|Concept|Syntaxe|Usage|
|---|---|---|
|Déclaration|`$variable = valeur`|Créer une variable|
|Typage|`[type]$var = valeur`|Forcer un type|
|Null|`$null`|Absence de valeur|
|Suppression|`Remove-Variable`|Libérer mémoire|
|Variables auto|`$PSVersionTable`, `$HOME`, `$PWD`, `$_`|Info système|
|Environnement|`$env:VARIABLE`|Config système|

Les variables sont la base de tout script PowerShell. Maîtriser leur déclaration, leur portée et les variables automatiques vous permettra d'écrire des scripts robustes et maintenables.