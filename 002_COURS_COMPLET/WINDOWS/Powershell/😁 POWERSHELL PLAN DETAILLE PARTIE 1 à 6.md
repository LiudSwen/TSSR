# Plan détaillé PowerShell avec sous-catégories approfondies

---

## 📘 PARTIE 1 : Découverte de PowerShell

**Fichier Obsidian suggéré :** `01-decouverte-powershell.md`

### 1. Introduction

#### 1.1 Qu'est-ce que PowerShell

- Définition et objectifs de PowerShell
- Shell orienté objet vs shells textuels traditionnels (cmd, bash)
- Intégration avec .NET Framework/.NET Core
- Cas d'usage principaux (administration système, automation, DevOps)
- PowerShell comme langage de scripting et shell interactif

#### 1.2 Versions (Windows PowerShell vs PowerShell Core)

- Windows PowerShell 5.1 (dernière version Windows PowerShell)
- PowerShell Core 6.x et PowerShell 7.x (multiplateforme)
- Différences principales entre les versions
- Compatibilité et migration
- Comment vérifier sa version (`$PSVersionTable`)
- Quelle version choisir selon son contexte

#### 1.3 Console, ISE, VS Code

- Windows PowerShell Console (console native)
- PowerShell ISE (Integrated Scripting Environment)
    - Interface et fonctionnalités
    - Limitations de l'ISE
- Visual Studio Code avec extension PowerShell
    - Installation et configuration
    - Fonctionnalités avancées (IntelliSense, debugging)
    - Avantages pour le développement de scripts
- Windows Terminal et autres alternatives
- Différences entre environnements d'exécution

#### 1.4 ExecutionPolicy

- Concept de politique d'exécution
- Niveaux de politique (Restricted, AllSigned, RemoteSigned, Unrestricted, Bypass)
- Portée des politiques (Process, CurrentUser, LocalMachine)
- `Get-ExecutionPolicy` et `Set-ExecutionPolicy`
- Implications de sécurité
- Contournement et bonnes pratiques

---

### 2. Premiers pas avec les cmdlets

#### 2.1 Structure Verbe-Nom

- Convention de nommage Verb-Noun
- Verbes approuvés (Get, Set, New, Remove, Start, Stop, etc.)
- Liste complète des verbes (`Get-Verb`)
- Avantages de cette standardisation
- Exemples de cmdlets courantes

#### 2.2 Get-Help, Get-Command, Get-Member

- **Get-Help**
    - Syntaxe de base et paramètres
    - Mise à jour de l'aide (`Update-Help`)
    - Exemples d'utilisation (`-Examples`, `-Detailed`, `-Full`, `-Online`)
    - Navigation dans l'aide
    - About topics (`Get-Help about_*`)
- **Get-Command**
    - Recherche de cmdlets
    - Filtrage par verbe, nom, module
    - Découverte de commandes disponibles
    - Paramètres `-Verb`, `-Noun`, `-Module`
- **Get-Member**
    - Exploration des propriétés et méthodes d'objets
    - Types d'objets
    - Utilisation avec le pipeline
    - Différence entre propriétés et méthodes

#### 2.3 Paramètres et arguments

- Paramètres positionnels vs nommés
- Paramètres obligatoires et optionnels
- Valeurs par défaut
- Syntaxe complète et abrégée
- Tab completion (auto-complétion)
- Paramètres communs (Common Parameters)
    - `-Verbose`, `-Debug`, `-ErrorAction`, `-WarningAction`
    - `-WhatIf` et `-Confirm` pour la sécurité
- Paramètres avec valeurs multiples (arrays)

#### 2.4 Alias

- Concept d'alias (raccourcis de commandes)
- Alias prédéfinis courants (ls, dir, cd, cls, etc.)
- `Get-Alias` pour lister les alias
- `New-Alias` et `Set-Alias` pour créer des alias personnalisés
- Différences entre alias et cmdlets complètes
- Bonnes pratiques : éviter les alias dans les scripts de production
- Exportation et persistance des alias

---

### 3. Le Pipeline

#### 3.1 Concept de pipeline ( | )

- Définition du pipeline
- Symbole pipe ( | )
- Flux de données entre commandes
- Différence avec les pipes Unix/Linux (objets vs texte)
- Avantages du pipeline orienté objet

#### 3.2 Chaînage de commandes

- Syntaxe de chaînage
- Exemples simples de pipelines
- Ordre d'exécution
- Combinaison de multiples cmdlets
- Bonnes pratiques de lisibilité
- Utilisation du backtick (`) pour lignes multiples

#### 3.3 Objets dans le pipeline

- Nature des objets transmis
- Propriétés et méthodes disponibles
- Variable automatique `$_` (objet courant dans le pipeline)
- `$PSItem` (alias de `$_`)
- Inspection des objets avec `Get-Member`
- Manipulation d'objets dans le pipeline
- Transformation d'objets
- Filtrage et sélection

---

## 📘 PARTIE 2 : Variables et opérateurs

**Fichier Obsidian suggéré :** `02-variables-operateurs.md`

### 1. Variables

#### 1.1 Déclaration ($variable)

- Syntaxe de déclaration avec `$`
- Règles de nommage des variables
- Variables non typées vs typées
- Initialisation de variables
- Variables nulles et `$null`
- Suppression de variables (`Remove-Variable`)
- Variables automatiques (built-in)
    - `$PSVersionTable`, `$HOME`, `$PWD`, `$_`
    - `$Error`, `$true`, `$false`
- Variables d'environnement (`$env:`)

#### 1.2 Types de données (string, int, bool, array, hashtable)

- **String (chaînes de caractères)**
    - Guillemets simples vs doubles
    - Interpolation de variables
    - Caractères d'échappement
    - Here-strings (chaînes multi-lignes)
    - Méthodes de manipulation (`.ToUpper()`, `.Replace()`, etc.)
- **Int et types numériques**
    - Int32, Int64, Double, Decimal
    - Opérations arithmétiques de base
- **Bool (booléens)**
    - `$true` et `$false`
    - Valeurs truthy et falsy
- **Array (tableaux)**
    - Création de tableaux (`@()`)
    - Accès aux éléments (index)
    - Ajout d'éléments (`+=`)
    - Propriétés (`.Count`, `.Length`)
    - Tableaux multidimensionnels
    - ArrayList pour performances
- **Hashtable (tables de hachage)**
    - Création (`@{}`)
    - Paires clé-valeur
    - Accès aux éléments
    - Ajout et suppression de clés
    - Méthodes `.Keys`, `.Values`, `.ContainsKey()`
- **Autres types**
    - DateTime
    - PSCustomObject
    - Collections spécialisées

#### 1.3 Conversion de types

- Conversion implicite vs explicite
- Cast de types (`[type]$variable`)
- Méthodes de conversion (`.ToString()`, etc.)
- `[int]`, `[string]`, `[datetime]`, etc.
- Gestion des erreurs de conversion
- `Convert` et méthodes .NET

#### 1.4 Portée des variables

- Portée locale (Local)
- Portée de script (Script)
- Portée globale (Global)
- Portée privée (Private)
- Modificateurs de portée (`$global:`, `$script:`)
- Variables dans les fonctions
- Variables dans les blocs de script
- Durée de vie des variables

---

### 2. Opérateurs

#### 2.1 Comparaison (-eq, -ne, -gt, -lt, -like, -match)

- **Opérateurs d'égalité**
    - `-eq` (égal)
    - `-ne` (différent)
    - `-ceq`, `-cne` (versions sensibles à la casse)
- **Opérateurs de comparaison**
    - `-gt` (supérieur)
    - `-ge` (supérieur ou égal)
    - `-lt` (inférieur)
    - `-le` (inférieur ou égal)
- **Opérateurs de correspondance**
    - `-like` (correspondance avec wildcards * et ?)
    - `-notlike`
    - `-match` (correspondance avec regex)
    - `-notmatch`
- **Opérateurs de contenance**
    - `-contains` et `-notcontains`
    - `-in` et `-notin`
- **Opérateurs de remplacement**
    - `-replace` avec regex
- Sensibilité à la casse (versions avec 'c')

#### 2.2 Logiques (-and, -or, -not)

- `-and` (ET logique)
- `-or` (OU logique)
- `-not` ou `!` (NON logique)
- `-xor` (OU exclusif)
- Priorité des opérateurs logiques
- Utilisation de parenthèses pour grouper
- Court-circuit d'évaluation
- Combinaisons complexes

#### 2.3 Arithmétiques

- Addition (`+`)
- Soustraction (`-`)
- Multiplication (`*`)
- Division (`/`)
- Modulo (`%`)
- Opérateurs d'affectation (`=`, `+=`, `-=`, `*=`, `/=`)
- Incrémentation et décrémentation (`++`, `--`)
- Priorité des opérations
- Opérations sur chaînes (concaténation avec `+`)
- Opérations sur tableaux

---

### 3. Manipulation de données

#### 3.1 Where-Object (filtrage)

- Syntaxe de base
- Utilisation avec bloc de script `{}`
- Variable `$_` ou `$PSItem`
- Script block simplifié
- Combinaison de conditions
- Performance : `Where-Object` vs `.Where()`
- Filtrage sur propriétés multiples
- Exemples pratiques

#### 3.2 Select-Object (sélection)

- Sélection de propriétés (`-Property`)
- Propriétés calculées (Calculated Properties)
    - Structure `@{Name=''; Expression={}}`
    - Alias `@{n=''; e={}}` ou `@{l=''; e={}}`
- Sélection des premiers/derniers éléments (`-First`, `-Last`)
- Suppression de doublons (`-Unique`)
- Expansion de propriétés (`-ExpandProperty`)
- Exclusion de propriétés (`-ExcludeProperty`)
- Exemples de transformation de données

#### 3.3 ForEach-Object (itération)

- Syntaxe de base avec bloc de script
- Variable `$_` dans le contexte
- Blocs Begin, Process, End
- Différence avec la boucle `foreach`
- Utilisation dans le pipeline
- Performance et cas d'usage
- Paramètres `-Parallel` (PowerShell 7+)
- Exemples de traitement par lot

#### 3.4 Sort-Object, Measure-Object, Group-Object

- **Sort-Object**
    - Tri croissant et décroissant (`-Descending`)
    - Tri sur propriétés multiples
    - Tri sur propriétés calculées
    - `-Unique` pour valeurs uniques
- **Measure-Object**
    - Comptage (`-Count`)
    - Somme (`-Sum`)
    - Moyenne (`-Average`)
    - Minimum et Maximum (`-Minimum`, `-Maximum`)
    - Propriété à mesurer (`-Property`)
    - Statistiques sur texte (lignes, mots, caractères)
- **Group-Object**
    - Regroupement par propriété
    - Propriétés des groupes (Name, Count, Group)
    - `-NoElement` pour performances
    - `-AsHashTable` et `-AsString`
    - Exemples d'analyse de données

---

## 📘 PARTIE 3 : Structures de programmation

**Fichier Obsidian suggéré :** `03-structures-programmation.md`

### 1. Structures conditionnelles

#### 1.1 If / ElseIf / Else

- Syntaxe de base `if`
- Conditions et opérateurs de comparaison
- Bloc `else` pour alternative
- Chaînage avec `elseif`
- Conditions multiples et imbriquées
- Bonnes pratiques de lisibilité (indentation, accolades)
- Conditions complexes avec opérateurs logiques
- Exemples pratiques

#### 1.2 Switch

- Syntaxe de base du `switch`
- Correspondance simple de valeurs
- Option `-Wildcard` pour patterns
- Option `-Regex` pour expressions régulières
- Option `-CaseSensitive`
- Option `-File` pour lire depuis un fichier
- Clause `default`
- Multiples correspondances possibles
- `break` et `continue` dans switch
- Comparaison switch vs if/elseif
- Cas d'usage et performances

---

### 2. Boucles

#### 2.1 ForEach et ForEach-Object

- **Boucle foreach**
    - Syntaxe : `foreach ($item in $collection)`
    - Variable d'itération
    - Parcours de tableaux et collections
    - Performance et utilisation en mémoire
- **ForEach-Object (cmdlet)**
    - Utilisation dans le pipeline
    - Différences avec la boucle foreach
    - Quand utiliser l'un ou l'autre
    - Streaming vs chargement en mémoire
- Méthode `.ForEach()` (PowerShell 4+)
- Exemples comparatifs

#### 2.2 For

- Syntaxe de la boucle `for`
- Initialisation, condition, itération
- Compteurs et indices
- Boucles imbriquées
- `break` et `continue`
- Cas d'usage typiques
- Performance vs foreach

#### 2.3 While, Do-While, Do-Until

- **While**
    - Syntaxe et condition préalable
    - Boucle tant que condition vraie
    - Risque de boucle infinie
- **Do-While**
    - Exécution puis test de condition
    - Garantie d'au moins une exécution
- **Do-Until**
    - Boucle jusqu'à ce que condition soit vraie
    - Différence avec do-while
- `break` pour sortir de boucle
- `continue` pour passer à l'itération suivante
- Étiquettes (labels) pour boucles imbriquées
- Exemples pratiques de chaque type

---

### 3. Gestion des erreurs

#### 3.1 Try / Catch / Finally

- Structure try/catch/finally
- Bloc `try` pour code à risque
- Bloc `catch` pour capture d'erreurs
    - Capture générale
    - Capture par type d'exception
    - Captures multiples spécifiques
- Bloc `finally` pour nettoyage
    - Exécution garantie
    - Libération de ressources
- Variable `$_` dans catch
- Propriétés de l'exception
- `throw` pour lever des exceptions
- Exceptions personnalisées
- Bonnes pratiques de gestion d'erreurs

#### 3.2 ErrorAction

- Paramètre commun `-ErrorAction`
- Valeurs possibles
    - `Continue` (défaut, affiche et continue)
    - `SilentlyContinue` (masque et continue)
    - `Stop` (génère exception terminante)
    - `Inquire` (demande à l'utilisateur)
    - `Ignore` (ignore complètement)
- Préférence `$ErrorActionPreference`
- Portée de l'ErrorAction
- Différence erreurs terminantes vs non-terminantes
- Conversion d'erreurs non-terminantes en terminantes

#### 3.3 $Error

- Variable automatique `$Error`
- Collection d'erreurs (tableau)
- Accès aux erreurs récentes (`$Error[0]`)
- Propriétés des objets d'erreur
    - `.Exception`
    - `.ErrorDetails`
    - `.InvocationInfo`
    - `.TargetObject`
- `$Error.Clear()` pour vider l'historique
- `Get-Error` pour détails étendus (PS 7+)
- Logging et analyse d'erreurs
- Débogage avec informations d'erreur

---

## 📘 PARTIE 4 : Scripts et fonctions

**Fichier Obsidian suggéré :** `04-scripts-fonctions.md`

### 1. Création de scripts

#### 1.1 Fichiers .ps1

- Extension .ps1 pour scripts PowerShell
- Création et édition de fichiers
- Encodage de fichiers (UTF-8 avec BOM recommandé)
- Structure de base d'un script
- Shebang et interpréteur (pour cross-platform)
- Organisation du code dans un script

#### 1.2 Commentaires

- Commentaires sur une ligne (`#`)
- Commentaires multi-lignes (`<# ... #>`)
- Commentaires de documentation (comment-based help)
    - `.SYNOPSIS`
    - `.DESCRIPTION`
    - `.PARAMETER`
    - `.EXAMPLE`
    - `.NOTES`
    - `.LINK`
- Bonnes pratiques de documentation
- Génération d'aide pour scripts

#### 1.3 Param() et paramètres de script

- Bloc `param()` en début de script
- Déclaration de paramètres
- Paramètres typés
- Paramètres obligatoires (`[Parameter(Mandatory)]`)
- Valeurs par défaut
- Attributs de paramètres
    - `Mandatory`
    - `Position`
    - `ValueFromPipeline`
    - `ValueFromPipelineByPropertyName`
    - `HelpMessage`
- Validation de paramètres
    - `[ValidateSet()]`
    - `[ValidateRange()]`
    - `[ValidatePattern()]`
    - `[ValidateScript()]`
    - `[ValidateNotNull()]`
    - `[ValidateNotNullOrEmpty()]`
    - `[ValidateLength()]`
    - `[ValidateCount()]`
- Paramètres switch (`[switch]`)
- `$PSBoundParameters` et `$args`

#### 1.4 Exécution de scripts

- Exécution depuis la console
- Chemins relatifs vs absolus
- Opérateur d'appel `&`
- Dot sourcing (`. .\script.ps1`)
    - Différence avec exécution normale
    - Portée des variables et fonctions
- Passage d'arguments au script
- Exécution à distance
- Planification de tâches (Task Scheduler)
- Droits d'exécution et sécurité

---

### 2. Fonctions

#### 2.1 Déclaration et appel

- Syntaxe de déclaration `function`
- Nommage des fonctions (convention Verb-Noun)
- Bloc de code de la fonction
- Appel de fonction
- Fonctions dans scripts vs fonctions interactives
- Portée des fonctions

#### 2.2 Paramètres de fonctions

- Bloc `param()` dans les fonctions
- Paramètres positionnels et nommés
- Tous les concepts de paramètres de scripts s'appliquent
- `$args` pour paramètres non déclarés
- Splatting de paramètres (`@params`)

#### 2.3 Return et sortie

- Instruction `return`
- Sortie implicite (tout objet non capturé)
- Différence entre return et Write-Output
- Retour de valeurs multiples
- Gestion du pipeline dans les fonctions
- `Write-Host` vs `Write-Output` vs `return`
- Bonnes pratiques de sortie

#### 2.4 CmdletBinding et fonctions avancées

- Attribut `[CmdletBinding()]`
- Transformation en cmdlet avancée
- Paramètres communs automatiques
- Support du pipeline
    - `ValueFromPipeline`
    - `ValueFromPipelineByPropertyName`
- Blocs `Begin`, `Process`, `End`
    - Begin : exécuté une fois au début
    - Process : exécuté pour chaque objet du pipeline
    - End : exécuté une fois à la fin
- `SupportsShouldProcess` pour `-WhatIf` et `-Confirm`
    - Méthode `$PSCmdlet.ShouldProcess()`
- `DefaultParameterSetName`
- Sets de paramètres (Parameter Sets)
- Fonctions avancées vs fonctions simples

---

### 3. Bonnes pratiques de code

#### 3.1 Nommage cohérent

- Convention Verb-Noun pour fonctions
- Verbes approuvés (`Get-Verb`)
- Noms de variables explicites
- CamelCase vs snake_case
- Constantes en majuscules
- Préfixes pour éviter conflits
- Noms significatifs et descriptifs

#### 3.2 Documentation

- Commentaires pertinents
- Comment-based help complet
- Documentation inline pour code complexe
- README pour modules et projets
- Exemples d'utilisation
- Documentation des paramètres
- Notes de version et changelog

#### 3.3 Validation des paramètres

- Utilisation systématique d'attributs de validation
- Tests de valeurs en entrée
- Messages d'erreur clairs et utiles
- Gestion des cas limites (edge cases)
- Validation métier vs validation technique
- Fail-fast principle (échouer rapidement)
- Tests unitaires et validation

---

## 📘 PARTIE 5 : Gestion des fichiers et du système

**Fichier Obsidian suggéré :** `05-fichiers-systeme.md`

### 1. Système de fichiers

#### 1.1 Get-ChildItem, New-Item, Remove-Item

- **Get-ChildItem**
    - Lister fichiers et dossiers
    - Paramètre `-Path` et `-LiteralPath`
    - Filtres : `-Filter`, `-Include`, `-Exclude`
    - Récursivité (`-Recurse`)
    - Profondeur (`-Depth`)
    - Fichiers cachés (`-Force`)
    - Propriétés des objets retournés
    - Alias : `ls`, `dir`, `gci`
- **New-Item**
    - Création de fichiers (`-ItemType File`)
    - Création de dossiers (`-ItemType Directory`)
    - `-Force` pour créer chemin complet
    - Paramètre `-Value` pour contenu initial
    - Liens symboliques et jonctions
- **Remove-Item**
    - Suppression de fichiers et dossiers
    - `-Recurse` pour dossiers non vides
    - `-Force` pour attributs read-only
    - `-Confirm` pour confirmation
    - `-WhatIf` pour simulation
    - Suppression sécurisée

#### 1.2 Copy-Item, Move-Item, Rename-Item

- **Copy-Item**
    - Copie de fichiers
    - Copie de dossiers (`-Recurse`)
    - `-Destination` et chemins
    - `-Force` pour écraser
    - Filtrage avec `-Filter`, `-Include`, `-Exclude`
    - Préservation d'attributs
- **Move-Item**
    - Déplacement de fichiers/dossiers
    - Renommage implicite
    - `-Force` pour écraser destination
    - Différences avec Cut/Paste
- **Rename-Item**
    - Renommage de fichiers/dossiers
    - `-NewName` pour nouveau nom
    - Renommage en masse avec pipeline
    - Expressions régulières pour renommage
- Gestion des chemins relatifs et absolus
- Wildcards dans les opérations

#### 1.3 Test-Path

- Vérification d'existence de fichier/dossier
- Retour booléen
- `-PathType` pour distinguer Leaf (fichier) et Container (dossier)
- `-IsValid` pour valider syntaxe de chemin
- Utilisation avant opérations de fichier
- Tests sur registre et autres providers
- Exemples de validation de chemins

---

### 2. Lecture et écriture de fichiers

#### 2.1 Get-Content, Set-Content, Add-Content

- **Get-Content**
    - Lecture de fichier texte
    - Lecture ligne par ligne
    - `-TotalCount` et `-Tail` pour limiter
    - `-ReadCount` pour performance
    - `-Encoding` pour encodages spécifiques
    - `-Raw` pour lire en une seule chaîne
    - Surveillance de fichier (`-Wait`)
- **Set-Content**
    - Écriture (écrase contenu existant)
    - Création automatique si inexistant
    - `-Encoding` pour format de sortie
    - `-Force` pour fichiers read-only
    - Écriture de tableaux (une ligne par élément)
- **Add-Content**
    - Ajout à la fin du fichier
    - Création si inexistant
    - Mêmes paramètres que Set-Content
    - Logging et journalisation
- **Clear-Content** pour vider sans supprimer
- Gestion des encodages (UTF8, ASCII, Unicode, etc.)

#### 2.2 Import-Csv, Export-Csv

- **Import-Csv**
    - Lecture de fichiers CSV
    - `-Delimiter` pour séparateurs personnalisés
    - `-Header` pour spécifier en-têtes
    - Conversion automatique en objets
    - `-Encoding` pour fichiers internationaux
- **Export-Csv**
    - Exportation d'objets vers CSV
    - `-NoTypeInformation` (PS 5.1) ou comportement par défaut (PS 7+)
    - `-Delimiter` pour format personnalisé
    - `-Append` pour ajouter à fichier existant
    - `-Force` pour écraser
- **ConvertTo-Csv** et **ConvertFrom-Csv**
    - Conversion sans écriture fichier
    - Manipulation en mémoire
- Manipulation de données tabulaires
- Exemples d'import/export de données

#### 2.3 ConvertTo-Json, ConvertFrom-Json

- **ConvertTo-Json**
    - Conversion d'objets en JSON
    - `-Depth` pour profondeur de sérialisation
    - `-Compress` pour format compact
    - Gestion d'objets complexes
    - Arrays et hashtables
- **ConvertFrom-Json**
    - Parsing de JSON vers objets PowerShell
    - `-AsHashtable` (PS 6+) pour tables de hachage
    - Accès aux propriétés après parsing
- Cas d'usage : APIs REST, configuration, échange de données
- Gestion d'erreurs de parsing
- Fichiers de configuration JSON

#### 2.4 Out-File

- Redirection vers fichier
- `-FilePath` pour destination
- `-Encoding` pour format
- `-Append` pour ajouter
- `-Width` pour largeur de ligne
- `-NoClobber` pour éviter écrasement
- Différence avec `>` et `>>`
- Cas d'usage vs Set-Content

---

### 3. Registre Windows

#### 3.1 Navigation (HKLM:, HKCU:)

- Registre comme système de fichiers (PSDrive)
- Ruches principales
    - `HKLM:` (HKEY_LOCAL_MACHINE)
    - `HKCU:` (HKEY_CURRENT_USER)
    - `HKCR:` (HKEY_CLASSES_ROOT)
    - `HKU:` (HKEY_USERS)
    - `HKCC:` (HKEY_CURRENT_CONFIG)
- Navigation avec `Set-Location` (`cd`)
- `Get-ChildItem` pour lister clés
- Structure hiérarchique du registre
- Chemins de registre

#### 3.2 Get-ItemProperty, Set-ItemProperty

- **Get-ItemProperty**
    - Lecture de valeurs de registre
    - `-Path` pour chemin de clé
    - `-Name` pour propriété spécifique
    - Lecture de toutes les propriétés
    - Types de valeurs retournées
- **Set-ItemProperty**
    - Modification de valeurs existantes
    - `-Path`, `-Name`, `-Value`
    - Types de données (String, DWORD, Binary, etc.)
    - `-Force` si nécessaire
    - Droits administrateur pour HKLM

#### 3.3 New-ItemProperty, Remove-ItemProperty

- **New-ItemProperty**
    - Création de nouvelles valeurs
    - `-Path`, `-Name`, `-Value`
    - `-PropertyType` pour type de données
        - String, ExpandString, Binary, DWord, MultiString, QWord
    - `-Force` pour écraser si existe
- **Remove-ItemProperty**
    - Suppression de valeurs
    - `-Path` et `-Name`
    - Confirmation recommandée
- **New-Item** et **Remove-Item** pour clés
- Précautions et sauvegardes avant modification
- Export/Import de clés de registre
- Cas d'usage pratiques (paramètres système, configuration applicative)

---

## 📘 PARTIE 6 : Services et processus

**Fichier Obsidian suggéré :** `06-services-processus.md`

### 1. Gestion des services

#### 1.1 Get-Service, Start-Service, Stop-Service

- **Get-Service**
    - Liste de tous les services
    - Filtrage par nom (`-Name`)
    - Wildcards acceptés
    - `-DisplayName` pour nom d'affichage
    - Propriétés des objets service
        - Name, DisplayName, Status, StartType
    - Filtrage par statut (Running, Stopped, etc.)
- **Start-Service**
    - Démarrage de service
    - `-Name` pour identifier
    - `-PassThru` pour retourner objet
    - Droits administrateur requis
    - Gestion des dépendances
- **Stop-Service**
    - Arrêt de service
    - `-Force` pour forcer arrêt
    - Services dépendants
    - Confirmation pour services critiques

#### 1.2 Restart-Service, Set-Service

- **Restart-Service**
    - Redémarrage (stop puis start)
    - Utile après modifications de configuration
    - `-Force` pour services avec dépendances
    - Gestion du timeout
- **Set-Service**
    - Modification de configuration de service
    - `-StartupType` : Automatic, Manual, Disabled
    - `-DisplayName` et `-Description`
    - `-Status` pour démarrer/arrêter
    - Droits administrateur nécessaires
    - Exemples de configuration courante

#### 1.3 Statut et dépendances

- États de service
    - Running (en cours d'exécution)
    - Stopped (arrêté)
    - Paused (en pause)
    - StartPending, StopPending, ContinuePending, PausePending
- Types de démarrage (StartType)
    - Automatic (automatique)
    - Manual (manuel)
    - Disabled (désactivé)
    - Automatic (Delayed Start)
- Dépendances de services
    - `DependentServices` (services dépendant de celui-ci)
    - `ServicesDependedOn` (services dont celui-ci dépend)
    - Impact lors du démarrage/arrêt
- Propriété `RequiredServices`
- Analyse de chaîne de dépendances
- Gestion des services en échec
- Service Recovery options

---

### 2. Gestion des processus

#### 2.1 Get-Process, Stop-Process

- **Get-Process**
    - Liste de tous les processus en cours
    - Filtrage par nom (`-Name`)
    - Filtrage par ID (`-Id`)
    - Propriétés des objets processus
        - Id, Name, CPU, WorkingSet (mémoire)
        - StartTime, Path, Company
        - Handles, Threads, NPM, PM, WS, VM
    - Processus pour utilisateur spécifique
    - Tri par utilisation ressources
    - Modules chargés (`-Module`)
    - `-FileVersionInfo` pour infos fichier
- **Stop-Process**
    - Arrêt de processus
    - `-Id` ou `-Name`
    - `-Force` pour forcer terminaison
    - `-PassThru` pour retourner objet
    - `-WhatIf` pour simulation
    - Gestion des processus multiples
    - Précautions et risques
    - Droits nécessaires selon processus

#### 2.2 Start-Process

- Lancement de nouveaux processus
- `-FilePath` pour exécutable
- `-ArgumentList` pour paramètres
- `-WorkingDirectory` pour répertoire de travail
- `-Verb` pour actions spéciales (RunAs, etc.)
- `-WindowStyle` (Normal, Hidden, Minimized, Maximized)
- `-Wait` pour attendre la fin
- `-PassThru` pour objet processus
- `-RedirectStandardOutput` et `-RedirectStandardError`
- `-NoNewWindow` pour même fenêtre console
- Élévation de privilèges (Run as Administrator)
- Exemples de lancement d'applications

#### 2.3 Propriétés des processus

- **Identification**
    - Id (PID)
    - Name (nom du processus)
    - ProcessName
    - Path (chemin complet)
- **Ressources système**
    - CPU (temps processeur)
    - WorkingSet/WS (mémoire physique)
    - VirtualMemorySize/VM (mémoire virtuelle)
    - PrivateMemorySize/PM (mémoire privée)
    - PagedMemorySize
    - NonpagedSystemMemorySize/NPM
- **Informations temporelles**
    - StartTime (heure de démarrage)
    - TotalProcessorTime
    - UserProcessorTime
- **Autres propriétés**
    - Handles (nombre de handles)
    - Threads (nombre de threads)
    - MainWindowTitle
    - Company, Product, ProductVersion
    - PriorityClass (priorité)
- Méthodes des objets processus
    - `.Kill()` pour terminer
    - `.WaitForExit()` pour attendre
    - `.CloseMainWindow()`
- Surveillance de performance
- Identification de processus gourmands

---

### 3. Journaux d'événements

#### 3.1 Get-EventLog

- Cmdlet pour journaux classiques Windows
- Journaux disponibles
    - Application
    - System
    - Security
    - Setup
- Paramètres principaux
    - `-LogName` pour spécifier journal
    - `-Newest` pour limiter nombre
    - `-After` et `-Before` pour plage temporelle
    - `-EntryType` (Error, Warning, Information, SuccessAudit, FailureAudit)
    - `-Source` pour source spécifique
    - `-InstanceId` ou `-EventId`
- Propriétés des événements
    - EventID, TimeGenerated, EntryType
    - Source, Message, Category
    - UserName, MachineName
- Filtrage et recherche
- Export d'événements
- Limitation : journaux classiques uniquement

#### 3.2 Get-WinEvent

- Cmdlet moderne pour tous journaux Windows
- Journaux ETW (Event Tracing for Windows)
- Avantages vs Get-EventLog
    - Accès à tous les journaux (y compris Applications and Services Logs)
    - Meilleure performance
    - Requêtes XML complexes
    - Compatible PowerShell Core
- Paramètres de base
    - `-LogName` pour journal
    - `-MaxEvents` pour limiter
    - `-FilterHashtable` pour filtrage efficace
    - `-FilterXml` pour requêtes complexes
    - `-FilterXPath` pour requêtes XPath
- Liste des journaux disponibles
    - `Get-WinEvent -ListLog *`
    - Journaux d'application
    - Journaux de sécurité avancés
- Propriétés d'événements
    - Id, LevelDisplayName, TimeCreated
    - ProviderName, Message
    - Properties (données supplémentaires)

#### 3.3 Filtrage et recherche

- **FilterHashtable (méthode recommandée)**
    - Structure : `@{LogName=''; Id=''}`
    - Clés disponibles
        - LogName
        - ProviderName
        - Path (fichier .evtx)
        - Keywords
        - Id (EventID)
        - Level (1=Critical, 2=Error, 3=Warning, 4=Information)
        - StartTime et EndTime
        - UserID, Data
    - Performance optimale
    - Exemples de filtres complexes
- **FilterXPath et FilterXML**
    - Requêtes XPath pour filtres avancés
    - Structure XML de requête
    - Opérateurs XPath
    - Filtrage sur données structurées
- **Filtrage avec Where-Object**
    - Moins performant mais plus flexible
    - Filtrage après récupération
    - Recherche dans Message
- **Recherche de patterns**
    - Expressions régulières
    - Recherche de mots-clés
    - Analyse de sécurité
- **Cas d'usage pratiques**
    - Erreurs d'application
    - Événements de sécurité (connexions, échecs)
    - Événements système (redémarrages, services)
    - Audit et conformité
    - Détection d'incidents
    - Corrélation d'événements
- **Export et reporting**
    - Export vers CSV
    - Export vers HTML
    - Rapports automatisés
    - Archivage de journaux
- **Journaux distants**
    - `-ComputerName` pour machines distantes
    - Droits nécessaires
    - Configuration WinRM
- **Performance et bonnes pratiques**
    - Toujours filtrer côté serveur (FilterHashtable)
    - Limiter le nombre d'événements
    - Éviter de charger trop d'événements en mémoire
    - Utiliser des index temporels

---

