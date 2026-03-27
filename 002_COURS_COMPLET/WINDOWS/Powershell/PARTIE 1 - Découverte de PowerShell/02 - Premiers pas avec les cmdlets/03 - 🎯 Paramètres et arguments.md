
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

## Introduction

Les paramètres sont le principal mécanisme pour passer des informations aux cmdlets et fonctions PowerShell. Comprendre comment utiliser les paramètres efficacement est essentiel pour maîtriser PowerShell, car ils contrôlent le comportement des commandes et permettent une automatisation flexible.

> [!info] Terminologie
> 
> - **Paramètre** : Variable définie dans une cmdlet/fonction qui accepte des valeurs
> - **Argument** : Valeur concrète que vous passez à un paramètre
> - **Switch** : Paramètre booléen qui ne nécessite pas de valeur

---

## Paramètres positionnels vs nommés

### 🎯 Concept

PowerShell permet deux façons de passer des arguments aux paramètres :

1. **Paramètres positionnels** : L'ordre détermine quelle valeur va à quel paramètre
2. **Paramètres nommés** : Vous spécifiez explicitement le nom du paramètre

### 💡 Pourquoi c'est important

- Les paramètres positionnels sont **rapides** pour les commandes courantes
- Les paramètres nommés sont **clairs** et **auto-documentés**
- Les scripts de production doivent privilégier les paramètres nommés pour la lisibilité

### 📝 Syntaxe et exemples

#### Paramètres positionnels

```powershell
# Syntaxe : les valeurs sont passées dans l'ordre défini
Get-Content fichier.txt

# Équivaut à :
Get-Content -Path fichier.txt

# Autre exemple avec plusieurs paramètres positionnels
Copy-Item source.txt destination.txt

# Position 0 = Path, Position 1 = Destination
```

#### Paramètres nommés

```powershell
# Syntaxe : -NomParamètre Valeur
Get-Content -Path fichier.txt

# Avantage : l'ordre n'a plus d'importance
Get-ChildItem -Filter "*.txt" -Path "C:\Temp" -Recurse

# Même résultat avec un ordre différent
Get-ChildItem -Recurse -Path "C:\Temp" -Filter "*.txt"
```

#### Mélange des deux approches

```powershell
# Valide : positionnels PUIS nommés
Get-ChildItem C:\Temp -Filter "*.txt" -Recurse

# ❌ INVALIDE : nommés PUIS positionnels
Get-ChildItem -Filter "*.txt" C:\Temp -Recurse
# Erreur : paramètre positionnel après un paramètre nommé
```

### 📊 Comparaison

|Aspect|Positionnels|Nommés|
|---|---|---|
|Rapidité d'écriture|⚡ Rapide|🐌 Plus lent|
|Lisibilité|📖 Moins claire|✨ Très claire|
|Maintenabilité|⚠️ Risque d'erreur|✅ Fiable|
|Usage recommandé|Interactive|Scripts|

> [!tip] Bonne pratique Utilisez les paramètres positionnels en ligne de commande pour gagner du temps, mais préférez les paramètres nommés dans vos scripts pour une meilleure maintenance.

> [!warning] Piège courant Ne mélangez pas paramètres positionnels et nommés sans respecter l'ordre : tous les paramètres positionnels doivent venir AVANT les paramètres nommés.

---

## Paramètres obligatoires et optionnels

### 🎯 Concept

Chaque paramètre d'une cmdlet peut être :

- **Obligatoire (Mandatory)** : Doit être fourni, sinon PowerShell demandera interactivement
- **Optionnel** : Peut être omis, une valeur par défaut ou un comportement par défaut s'applique

### 💡 Pourquoi c'est important

Connaître quels paramètres sont obligatoires évite les erreurs et permet d'écrire des commandes correctes du premier coup.

### 📝 Comment identifier les paramètres obligatoires

#### Avec Get-Help

```powershell
# Afficher l'aide complète
Get-Help Get-Service -Full

# Section SYNTAX montre les paramètres obligatoires
# Paramètres obligatoires : [-Name] <String[]>
# Paramètres optionnels : [[-ComputerName] <String[]>]
```

#### Avec Get-Command

```powershell
# Voir tous les paramètres et leurs propriétés
(Get-Command Get-Service).Parameters

# Filtrer uniquement les paramètres obligatoires
(Get-Command Get-Service).Parameters.Values | 
    Where-Object { $_.Attributes.Mandatory } |
    Select-Object Name, ParameterType
```

#### Notation dans l'aide

```powershell
# Dans la syntaxe de Get-Help :
Get-Service [-Name] <String[]>           # Obligatoire (pas de crochets autour de -Name dans certains jeux)
Get-Service [[-DisplayName] <String[]>]  # Optionnel (double crochets)
Get-Service [-ComputerName <String[]>]   # Optionnel
```

### 📝 Comportement des paramètres obligatoires

```powershell
# Si un paramètre obligatoire est omis, PowerShell demande interactivement
Stop-Process
# Invite : cmdlet Stop-Process at command pipeline position 1
# Supply values for the following parameters:
# Id[0]: _

# Pour éviter l'invite interactive, fournissez le paramètre
Stop-Process -Id 1234

# Ou utilisez -WhatIf pour tester sans exécuter
Stop-Process -Id 1234 -WhatIf
```

### 📊 Exemples concrets

```powershell
# Get-Service : -Name obligatoire dans certains jeux de paramètres
Get-Service -Name "wuauserv"

# Mais optionnel si on utilise sans paramètre (liste tous les services)
Get-Service

# Stop-Process : -Id ou -Name obligatoire
Stop-Process -Id 1234
Stop-Process -Name "notepad"

# New-Item : -Path obligatoire
New-Item -Path "C:\Temp\test.txt" -ItemType File
```

> [!info] Jeux de paramètres (Parameter Sets) Une cmdlet peut avoir plusieurs "jeux de paramètres" - des combinaisons différentes de paramètres obligatoires/optionnels pour différents scénarios d'utilisation. Par exemple, `Get-Service` peut utiliser `-Name` OU `-DisplayName`.

> [!warning] Erreur courante Ne pas fournir un paramètre obligatoire lance une invite interactive qui bloque les scripts non supervisés. Toujours fournir explicitement les paramètres obligatoires dans vos scripts.

---

## Valeurs par défaut

### 🎯 Concept

Les paramètres optionnels ont souvent des **valeurs par défaut** qui s'appliquent lorsqu'ils ne sont pas spécifiés. PowerShell utilise également des **variables de préférence** globales qui définissent le comportement par défaut de certains paramètres communs.

### 💡 Pourquoi c'est important

Comprendre les valeurs par défaut vous permet de :

- Prédire le comportement d'une commande
- Savoir quand vous devez explicitement spécifier un paramètre
- Personnaliser le comportement global de PowerShell

### 📝 Types de valeurs par défaut

#### 1. Valeurs par défaut des paramètres

```powershell
# Get-ChildItem : -Path par défaut = répertoire courant
Get-ChildItem
# Équivalent à :
Get-ChildItem -Path .

# Get-Content : -Encoding par défaut = UTF8
Get-Content fichier.txt
# Équivalent à :
Get-Content fichier.txt -Encoding UTF8

# New-Item : -ItemType par défaut = File (dans certains contextes)
New-Item "test.txt"
```

#### 2. Variables de préférence globales

```powershell
# Variables contrôlant le comportement par défaut
$ErrorActionPreference      # Défaut : "Continue"
$WarningPreference         # Défaut : "Continue"
$VerbosePreference         # Défaut : "SilentlyContinue"
$DebugPreference           # Défaut : "SilentlyContinue"
$ProgressPreference        # Défaut : "Continue"

# Afficher la valeur actuelle
$ErrorActionPreference

# Modifier globalement pour la session
$ErrorActionPreference = "Stop"  # Les erreurs arrêtent l'exécution
```

#### 3. Paramètres avec valeurs calculées

```powershell
# Select-Object : -First sans valeur = 1
Get-Process | Select-Object -First
# Sélectionne le premier objet

# Get-Random : plage par défaut = 0 à Int32.MaxValue
Get-Random
# Retourne un nombre aléatoire dans toute la plage

# Get-Date : sans paramètres = date/heure actuelle
Get-Date
```

### 📝 Personnaliser les valeurs par défaut

#### Modifier temporairement (session actuelle)

```powershell
# Changer le comportement des erreurs
$ErrorActionPreference = "SilentlyContinue"

# Afficher les messages verbeux par défaut
$VerbosePreference = "Continue"
Get-ChildItem C:\  # Affichera des messages verbeux si la cmdlet en génère
```

#### Modifier définitivement (profil PowerShell)

```powershell
# Éditer votre profil
notepad $PROFILE

# Ajouter dans le profil :
$VerbosePreference = "Continue"
$ErrorActionPreference = "Stop"

# Ces modifications s'appliqueront à chaque session
```

#### Utiliser $PSDefaultParameterValues

```powershell
# Définir des valeurs par défaut personnalisées pour des cmdlets spécifiques
$PSDefaultParameterValues = @{
    'Get-ChildItem:Recurse' = $true          # Toujours récursif
    'Send-MailMessage:SmtpServer' = 'smtp.entreprise.com'
    'Export-Csv:NoTypeInformation' = $true    # Supprimer la ligne #TYPE
    '*:Encoding' = 'UTF8'                     # UTF8 pour toutes les cmdlets
}

# Vérifier les valeurs définies
$PSDefaultParameterValues

# Maintenant Get-ChildItem est récursif par défaut
Get-ChildItem C:\Temp
```

### 📊 Exemples pratiques

```powershell
# Sans personnalisation
Get-ChildItem C:\Temp  # Non récursif par défaut

# Avec personnalisation
$PSDefaultParameterValues['Get-ChildItem:Recurse'] = $true
Get-ChildItem C:\Temp  # Maintenant récursif par défaut !

# Désactiver temporairement une valeur par défaut
$PSDefaultParameterValues['Get-ChildItem:Recurse'] = $false

# Supprimer une valeur par défaut
$PSDefaultParameterValues.Remove('Get-ChildItem:Recurse')
```

> [!tip] Astuce professionnelle Utilisez `$PSDefaultParameterValues` dans votre profil pour personnaliser les cmdlets que vous utilisez fréquemment. Cela améliore significativement votre productivité.

> [!warning] Attention aux effets de bord Modifier les variables de préférence globales affecte TOUS les scripts et commandes de la session. Soyez prudent dans les scripts partagés ou en production.

> [!example] Cas d'usage courant
> 
> ```powershell
> # Pour les développeurs qui veulent voir tous les détails
> $PSDefaultParameterValues = @{
>     '*:Verbose' = $true
>     '*:Debug' = $true
> }
> 
> # Pour les scripts de production qui doivent être silencieux
> $PSDefaultParameterValues = @{
>     '*:ErrorAction' = 'Stop'
>     '*:WarningAction' = 'SilentlyContinue'
> }
> ```

---

## Syntaxe complète et abrégée

### 🎯 Concept

PowerShell permet d'**abréger** les noms de paramètres tant qu'il n'y a pas d'ambiguïté. Vous n'avez pas besoin d'écrire le nom complet du paramètre.

### 💡 Pourquoi c'est important

- **Gain de temps** en ligne de commande
- **Flexibilité** pour trouver le bon équilibre lisibilité/rapidité
- **Compréhension** des scripts d'autres personnes qui utilisent des abréviations

### 📝 Règles d'abréviation

#### Règle de base

```powershell
# Vous pouvez abréger tant que c'est non-ambigu
Get-ChildItem -Path C:\Temp -Recurse

# Abréviations valides :
Get-ChildItem -P C:\Temp -R
Get-ChildItem -Pat C:\Temp -Rec
Get-ChildItem -Pa C:\Temp -Re

# Trop court (ambigu si d'autres paramètres commencent par 'R')
Get-ChildItem -P C:\Temp -R
```

#### Exemples concrets

```powershell
# Get-Service
Get-Service -Name "wuauserv"
Get-Service -N "wuauserv"        # Abréviation minimale

# Get-Process
Get-Process -ComputerName "Server01"
Get-Process -Comp "Server01"     # Suffisant
Get-Process -Co "Server01"       # Trop court si -ComputerName et -Company existent

# Select-Object
Get-Process | Select-Object -Property Name, CPU -First 5
Get-Process | Select-Object -Prop Name, CPU -F 5
Get-Process | Select -Pro Name, CPU -Fi 5
```

### 📝 Trouver l'abréviation minimale

```powershell
# Tester progressivement
Get-ChildItem -Rec      # Fonctionne
Get-ChildItem -Re       # Fonctionne encore
Get-ChildItem -R        # Fonctionne aussi (si non ambigu)

# Si erreur d'ambiguïté, allonger d'un caractère
Get-Service -D          # ❌ Erreur si -DisplayName et -DependentServices existent
Get-Service -Di         # ✅ Maintenant non ambigu pour -DisplayName
```

### 📝 Switches (paramètres booléens)

```powershell
# Switches : pas besoin de valeur, leur présence = $true
Get-ChildItem -Recurse           # -Recurse est un switch
Get-ChildItem -Recurse:$true     # Explicite (rarement nécessaire)
Get-ChildItem -Recurse:$false    # Désactivation explicite

# Abréviation des switches
Get-ChildItem -R                 # Fonctionne
Get-ChildItem -Rec              # Fonctionne aussi
```

### 📊 Comparaison syntaxe complète vs abrégée

```powershell
# ✅ Scripts de production (lisibilité maximale)
Get-ChildItem -Path "C:\Logs" -Filter "*.log" -Recurse -ErrorAction Stop

# ⚡ Ligne de commande interactive (rapidité)
gci -Pa "C:\Logs" -Fi "*.log" -R -EA Stop

# 🎯 Compromis équilibré
Get-ChildItem -Path "C:\Logs" -Filter "*.log" -Rec -ErrorAction Stop
```

|Contexte|Recommandation|Raison|
|---|---|---|
|Scripts partagés|Syntaxe complète|Lisibilité, maintenance|
|Scripts personnels|Compromis|Équilibre|
|Ligne de commande|Abrégé|Rapidité|
|Documentation|Syntaxe complète|Clarté|

> [!tip] Bonne pratique Dans les scripts destinés à être partagés ou maintenus, utilisez toujours les noms complets des paramètres. Réservez les abréviations aux commandes interactives.

> [!warning] Risque d'ambiguïté Les abréviations peuvent devenir ambiguës dans les versions futures de PowerShell si de nouveaux paramètres sont ajoutés. Un script fonctionnel peut casser après une mise à jour.

> [!example] Exemple de cassure potentielle
> 
> ```powershell
> # PowerShell 5.1
> Get-Service -D "wuauserv"  # Fonctionne, -DisplayName
> 
> # PowerShell 7+ (hypothétique si -Description était ajouté)
> Get-Service -D "wuauserv"  # ❌ Erreur : ambigu entre -DisplayName et -Description
> ```

---

## Tab completion (auto-complétion)

### 🎯 Concept

PowerShell offre une **auto-complétion intelligente** avec la touche **Tab** (ou **Ctrl+Space** dans VSCode). C'est l'une des fonctionnalités les plus puissantes pour améliorer votre productivité.

### 💡 Pourquoi c'est important

- **Gain de temps** massif : plus besoin de taper les noms complets
- **Découverte** : explore les options disponibles sans consulter l'aide
- **Réduction d'erreurs** : moins de typos grâce à la complétion automatique

### 📝 Types d'auto-complétion

#### 1. Complétion des noms de cmdlets

```powershell
# Tapez les premières lettres puis Tab
Get-Ch[Tab]         # → Get-ChildItem
Get-Ch[Tab][Tab]    # Cycle entre Get-ChildItem, Get-Checkbox, Get-Character...

# Avec verbe et nom partiel
Get-S[Tab]          # Cycle entre Get-Service, Get-SecureString, Get-Shortcut...

# Avec wildcards
Get-*Item[Tab]      # → Get-ChildItem, Get-Item, Get-ItemProperty...
*-Process[Tab]      # → Get-Process, Start-Process, Stop-Process...
```

#### 2. Complétion des noms de paramètres

```powershell
# Après le nom de la cmdlet, Tab complète les paramètres
Get-ChildItem -[Tab]           # Cycle entre -Path, -Filter, -Include, -Exclude...
Get-ChildItem -P[Tab]          # → -Path
Get-ChildItem -Path C:\Temp -[Tab]  # Montre les paramètres restants disponibles
```

#### 3. Complétion des valeurs de paramètres

```powershell
# Chemins de fichiers
Get-ChildItem -Path C:\[Tab]   # Complète avec les dossiers dans C:\
Get-Content C:\Windows\[Tab]   # Complète avec les fichiers et dossiers

# Noms de services
Get-Service -Name w[Tab]       # Cycle entre wuauserv, WinRM, WSearch...
Stop-Service -Name [Tab]       # Liste tous les services disponibles

# Noms de processus
Get-Process -Name n[Tab]       # → notepad, netsh, node...

# Énumérations et valeurs fixes
Set-ExecutionPolicy [Tab]      # Cycle entre Restricted, AllSigned, RemoteSigned...
Get-ChildItem -Attributes [Tab] # → Archive, Compressed, Hidden, ReadOnly...
```

#### 4. Complétion des propriétés d'objets

```powershell
# Après le point (.) sur un objet
$process = Get-Process -Name pwsh
$process.[Tab]                 # Liste toutes les propriétés : Name, Id, CPU...
$process.Ha[Tab]               # → Handle, Handles, HasExited

# Dans Select-Object
Get-Process | Select-Object -Property [Tab]  # Liste les propriétés disponibles
Get-Process | Select-Object N[Tab]           # → Name
```

#### 5. Complétion des variables

```powershell
# Variables existantes
$myVariable = "test"
$my[Tab]                       # → $myVariable

# Variables automatiques
$PS[Tab]                       # Cycle entre $PSVersionTable, $PSHome, $PSHOME...
$[Tab]                         # Liste TOUTES les variables de la session
```

### 📝 Complétion avancée

#### Avec wildcards dans les valeurs

```powershell
# PowerShell 7+ : complétion intelligente avec wildcards
Get-Service -Name *u*[Tab]     # Trouve les services contenant "u"
Get-Process -Name *p*[Tab]     # Trouve les processus contenant "p"
```

#### Complétion de méthodes

```powershell
# Méthodes d'objets
"Hello World".To[Tab]          # → ToLower, ToUpper, ToString...
(Get-Date).Add[Tab]            # → AddDays, AddHours, AddMinutes...
```

#### Complétion dans les pipelines

```powershell
# Les cmdlets en aval connaissent le type d'objet entrant
Get-Process | Stop-[Tab]       # Suggère Stop-Process (contexte approprié)
Get-Service | Start-[Tab]      # Suggère Start-Service
Get-Process | Select-Object -Property [Tab]  # Propriétés de Process
```

### 📝 Raccourcis clavier utiles

|Raccourci|Action|Contexte|
|---|---|---|
|**Tab**|Complète vers l'avant|Console, ISE, VSCode|
|**Shift+Tab**|Complète vers l'arrière|Console, ISE, VSCode|
|**Ctrl+Space**|Affiche toutes les options|VSCode, ISE|
|**Ctrl+]**|Ferme citations/parenthèses|VSCode|
|**F8**|Exécute la sélection|ISE, VSCode|

### 📝 Personnaliser PSReadLine (PowerShell 7+)

```powershell
# Voir la configuration actuelle
Get-PSReadLineOption

# Activer la prédiction basée sur l'historique
Set-PSReadLineOption -PredictionSource History

# Afficher les prédictions en liste
Set-PSReadLineOption -PredictionViewStyle ListView

# Style de complétion de menu
Set-PSReadLineOption -EditMode Windows  # ou Emacs

# Dans votre profil pour rendre permanent :
Set-PSReadLineOption -PredictionSource HistoryAndPlugin
Set-PSReadLineOption -PredictionViewStyle ListView
```

### 📊 Exemples d'utilisation optimale

```powershell
# Workflow rapide de découverte
Get-[Tab][Tab][Tab]            # Explorer les cmdlets disponibles
Get-ChildItem -[Tab]           # Explorer les paramètres disponibles
Get-ChildItem -Path [Tab]      # Explorer les chemins disponibles

# Construction de commande complexe
Get-Process |                  # Tapé manuellement
  Where-Object {$_.CPU -gt 10} |
  Select-Object -Property [Tab] # N[Tab] → Name, [Tab] → CPU
  Sort-Object -Property CPU -Descending
```

> [!tip] Astuce pro : Menu interactif Dans PowerShell 7+, utilisez **Ctrl+Space** au lieu de **Tab** pour voir un menu interactif avec TOUTES les options disponibles. Utilisez les flèches pour naviguer et **Entrée** pour sélectionner.

> [!tip] Gagner encore plus de temps Installez le module **PSReadLine** et configurez la prédiction intelligente. PowerShell suggérera automatiquement des commandes basées sur votre historique :
> 
> ```powershell
> Install-Module PSReadLine -Force
> Set-PSReadLineOption -PredictionSource HistoryAndPlugin
> ```

> [!warning] Attention aux noms ambigus Si plusieurs options correspondent, **Tab** cycle entre elles. Tapez plus de caractères pour réduire les options, ou utilisez **Ctrl+Space** pour voir la liste complète.

> [!example] Complétion contextuelle intelligente
> 
> ```powershell
> # PowerShell comprend le contexte
> Get-Service -Name "wuauserv" | Stop-[Tab]  # Suggère Stop-Service
> Get-Process -Name "notepad" | Stop-[Tab]   # Suggère Stop-Process
> 
> # Complétion basée sur le type d'objet
> $service = Get-Service -Name "wuauserv"
> $service.[Tab]  # Montre les propriétés de ServiceController
> ```

---

## Paramètres communs (Common Parameters)

### 🎯 Concept

PowerShell ajoute automatiquement un ensemble de **paramètres communs** à (presque) toutes les cmdlets avancées. Ces paramètres contrôlent le comportement d'exécution, le débogage, et la gestion des erreurs.

### 💡 Pourquoi c'est important

- **Uniformité** : mêmes paramètres sur toutes les cmdlets
- **Contrôle** : gérer précisément le comportement et les sorties
- **Débogage** : outils intégrés pour diagnostiquer les problèmes
- **Sécurité** : tester avant d'exécuter avec `-WhatIf`

### 📝 Liste des paramètres communs

|Paramètre|Alias|Type|Description|
|---|---|---|---|
|`-Verbose`|`-vb`|Switch|Affiche des messages détaillés|
|`-Debug`|`-db`|Switch|Affiche des messages de débogage|
|`-ErrorAction`|`-EA`|ActionPreference|Contrôle la gestion des erreurs|
|`-WarningAction`|`-WA`|ActionPreference|Contrôle l'affichage des avertissements|
|`-InformationAction`|`-IA`|ActionPreference|Contrôle les messages d'information|
|`-ErrorVariable`|`-EV`|String|Stocke les erreurs dans une variable|
|`-WarningVariable`|`-WV`|String|Stocke les avertissements dans une variable|
|`-InformationVariable`|`-IV`|String|Stocke les messages d'info dans une variable|
|`-OutVariable`|`-OV`|String|Stocke les sorties dans une variable|
|`-OutBuffer`|`-OB`|Int32|Taille du buffer de sortie|
|`-PipelineVariable`|`-PV`|String|Stocke l'objet actuel du pipeline|
|`-WhatIf`|`-wi`|Switch|Simule l'exécution sans modifier le système|
|`-Confirm`|`-cf`|Switch|Demande confirmation avant exécution|

---

### 🔍 `-Verbose` : Messages détaillés

#### 💡 Utilité

Affiche des informations supplémentaires sur ce que fait la cmdlet, utile pour comprendre le déroulement et déboguer.

#### 📝 Syntaxe et exemples

```powershell
# Activer les messages verbeux pour une commande
Get-ChildItem C:\Temp -Recurse -Verbose

# Messages affichés en couleur (généralement jaune) :
# VERBOSE: Performing the operation "Get-ChildItem" on target "Item: C:\Temp"
# VERBOSE: Processing folder: C:\Temp\Subfolder

# Activer globalement pour toute la session
$VerbosePreference = "Continue"
Get-ChildItem C:\Temp  # Maintenant verbeux par défaut

# Revenir au comportement par défaut
$VerbosePreference = "SilentlyContinue"

# Dans vos propres fonctions
function Test-MyFunction {
    [CmdletBinding()]
    param()
    
    Write-Verbose "Début du traitement"
    # ... code ...
    Write-Verbose "Fin du traitement"
}

Test-MyFunction -Verbose
```

> [!tip] Débogage rapide Ajoutez `-Verbose` à n'importe quelle commande qui ne fait pas ce que vous attendez pour voir ce qui se passe réellement.

---

### 🐛 `-Debug` : Messages de débogage

#### 💡 Utilité

Affiche des messages de débogage et peut suspendre l'exécution pour inspection. Plus détaillé que `-Verbose`.

#### 📝 Syntaxe et exemples

```powershell
# Activer le mode debug
Get-Process -Name "pwsh" -Debug

# Prompt interactif à chaque point de debug :
# DEBUG: Checking process: pwsh
# Continue with this operation?
# [Y] Yes  [A] Yes to All  [H] Halt Command  [S] Suspend  [?] Help (default is "Y"):

# Dans vos fonctions
function Test-Debug {
    [CmdletBinding()]
    param()
    
    Write-Debug "Point de debug 1"
    $value = Get-Random
    Write-Debug "Valeur générée : $value"
}

Test-Debug -Debug

# Activer globalement
$DebugPreference = "Continue"
```

> [!warning] Mode interactif Avec `-Debug`, l'exécution s'arrête à chaque `Write-Debug`. Utile pour le développement, mais ne l'utilisez pas dans les scripts de production.

---

### 🚨 `-ErrorAction` : Gestion des erreurs

#### 💡 Utilité

Contrôle comment PowerShell réagit aux erreurs **non-terminantes** (erreurs qui n'arrêtent pas normalement le script).

#### 📝 Valeurs possibles

|Valeur|Alias|Comportement|
|---|---|---|
|`Continue`|-|**(Défaut)** Affiche l'erreur et continue|
|`SilentlyContinue`|-|Masque l'erreur et continue|
|`Stop`|-|Arrête l'exécution (erreur terminante)|
|`Inquire`|-|Demande à l'utilisateur comment procéder|
|`Ignore`|-|Ignore complètement l'erreur (pas de log)|
|`Suspend`|-|Suspend le workflow (workflows uniquement)|

#### 📝 Exemples pratiques

```powershell
# Comportement par défaut (Continue)
Get-Item "C:\FichierInexistant.txt"
# Affiche : Get-Item : Cannot find path 'C:\FichierInexistant.txt'...
# Le script continue après l'erreur

# Ignorer silencieusement les erreurs
Get-Item "C:\FichierInexistant.txt" -ErrorAction SilentlyContinue
# Aucun message, continue sans interruption

# Arrêter à la première erreur (scripts de production)
Get-Item "C:\FichierInexistant.txt" -ErrorAction Stop
# Arrête complètement l'exécution du script

# Demander à l'utilisateur
Get-Item "C:\FichierInexistant.txt" -ErrorAction Inquire
# Prompt : Confirm
# Are you sure you want to perform this action?

# Cas pratique : traiter plusieurs fichiers
$files = @("fichier1.txt", "fichier_inexistant.txt", "fichier2.txt")

# Sans gestion : s'arrête à la première erreur
foreach ($file in $files) {
    Get-Content $file  # ❌ S'arrête à fichier_inexistant.txt
}

# Avec SilentlyContinue : traite tous les fichiers valides
foreach ($file in $files) {
    Get-Content $file -ErrorAction SilentlyContinue  # ✅ Continue malgré l'erreur
}

# Avec Stop et try/catch : gestion personnalisée
foreach ($file in $files) {
    try {
        Get-Content $file -ErrorAction Stop
    }
    catch {
        Write-Warning "Impossible de lire $file : $_"
        # Logique de fallback ici
    }
}
```

#### 📝 Modifier le comportement global

```powershell
# Pour toute la session
$ErrorActionPreference = "Stop"  # Toutes les erreurs deviennent terminantes

# Revenir au défaut
$ErrorActionPreference = "Continue"
```

> [!tip] Scripts robustes Dans les scripts de production, utilisez `$ErrorActionPreference = "Stop"` en début de script pour détecter immédiatement les problèmes, puis gérez les erreurs avec des blocs `try/catch`.

> [!warning] Différence SilentlyContinue vs Ignore
> 
> - **SilentlyContinue** : L'erreur est enregistrée dans `$Error`, juste pas affichée
> - **Ignore** : L'erreur n'est ni affichée ni enregistrée (comme si elle n'existait pas)

---

### ⚠️ `-WarningAction` : Gestion des avertissements

#### 💡 Utilité

Contrôle l'affichage des messages d'avertissement (généralement en jaune).

#### 📝 Valeurs possibles

|Valeur|Comportement|
|---|---|
|`Continue`|**(Défaut)** Affiche l'avertissement et continue|
|`SilentlyContinue`|Masque l'avertissement|
|`Stop`|Traite l'avertissement comme une erreur terminante|
|`Inquire`|Demande confirmation|

#### 📝 Exemples

```powershell
# Cmdlet qui génère un avertissement
Get-Process -Name "ServiceInexistant" -ErrorAction SilentlyContinue
# WARNING: Cannot find a process with the name "ServiceInexistant"

# Masquer les avertissements
Get-Process -Name "ServiceInexistant" -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
# Aucun message

# Dans vos fonctions
function Test-Warning {
    [CmdletBinding()]
    param()
    
    Write-Warning "Ceci est un avertissement"
    Write-Output "Suite du traitement"
}

Test-Warning -WarningAction SilentlyContinue  # Masque l'avertissement
```

---

### 📦 Variables `-ErrorVariable`, `-WarningVariable`, `-OutVariable`

#### 💡 Utilité

Capturent les erreurs, avertissements, ou sorties dans des variables pour traitement ultérieur, **en plus** du comportement normal.

#### 📝 Syntaxe importante

```powershell
# ⚠️ PAS de $ devant le nom de variable !
Get-Item "inexistant.txt" -ErrorAction SilentlyContinue -ErrorVariable monErreur
# Correct : -ErrorVariable monErreur
# ❌ Incorrect : -ErrorVariable $monErreur

# Maintenant la variable $monErreur contient l'erreur
$monErreur
$monErreur.Exception.Message

# Ajouter à une variable existante avec +
Get-Item "autre_inexistant.txt" -ErrorAction SilentlyContinue -ErrorVariable +monErreur
# Le + ajoute au lieu de remplacer
```

#### 📝 Exemples pratiques

```powershell
# Capturer les erreurs pour analyse
$erreurs = @()
$fichiers = @("fichier1.txt", "fichier2.txt", "fichier3.txt")

foreach ($fichier in $fichiers) {
    Get-Content $fichier -ErrorAction SilentlyContinue -ErrorVariable +erreurs
}

# Analyser les erreurs capturées
if ($erreurs.Count -gt 0) {
    Write-Host "❌ $($erreurs.Count) erreurs détectées :"
    $erreurs | ForEach-Object { Write-Host "  - $_" }
}

# Capturer les avertissements
Get-Process -Name "test*" -WarningVariable avertissements -WarningAction SilentlyContinue
$avertissements  # Contient tous les avertissements générés

# Capturer la sortie (en plus de l'affichage normal)
Get-Process -Name "pwsh" -OutVariable processus
# Affiche les processus ET les stocke dans $processus
$processus.Count
```

> [!tip] Combinaison puissante Combinez `-ErrorAction SilentlyContinue` avec `-ErrorVariable` pour capturer les erreurs sans interrompre l'exécution ni polluer la console.

---

### 🔗 `-PipelineVariable` : Référencer l'objet dans le pipeline

#### 💡 Utilité

Permet de référencer l'objet actuel du pipeline à n'importe quel stade ultérieur, même après transformation.

#### 📝 Syntaxe et exemples

```powershell
# Sans -PipelineVariable (problème)
Get-Service | 
    Where-Object {$_.Status -eq "Running"} |
    ForEach-Object {
        # Ici, $_ est le service
        Get-Process -Name $_.Name -ErrorAction SilentlyContinue |
            Select-Object @{N="ServiceName"; E={$_.Name}}  
            # ❌ $_.Name ici est le nom du PROCESSUS, pas du service !
    }

# Avec -PipelineVariable (solution)
Get-Service -PipelineVariable svc |
    Where-Object {$_.Status -eq "Running"} |
    Get-Process -Name {$svc.Name} -ErrorAction SilentlyContinue |
    Select-Object ProcessName, @{N="ServiceName"; E={$svc.Name}}
    # ✅ $svc contient toujours le service original

# Autre exemple : enrichir des données
Get-ChildItem C:\Logs\*.log -PipelineVariable fichier |
    Get-Content |
    Where-Object {$_ -match "ERROR"} |
    ForEach-Object {
        [PSCustomObject]@{
            Fichier = $fichier.Name           # Nom du fichier
            Ligne   = $_                       # Ligne d'erreur
            Date    = $fichier.LastWriteTime   # Date du fichier
        }
    }
```

> [!example] Cas d'usage typique Utiliser `-PipelineVariable` quand vous devez conserver une référence à l'objet original à travers plusieurs étapes de pipeline qui le transforment.

---

### 🛡️ `-WhatIf` et `-Confirm` : Sécurité avant exécution

#### 💡 Utilité

Paramètres critiques pour éviter les erreurs destructrices :

- **`-WhatIf`** : Simule l'action sans l'exécuter (mode "dry-run")
- **`-Confirm`** : Demande confirmation avant chaque action

#### 📝 `-WhatIf` : Tester sans risque

```powershell
# Supprimer des fichiers (dangereux !)
Remove-Item C:\Temp\*.log

# Tester d'abord avec -WhatIf
Remove-Item C:\Temp\*.log -WhatIf
# Affiche : What if: Performing the operation "Remove File" on target "C:\Temp\app.log"
# Affiche : What if: Performing the operation "Remove File" on target "C:\Temp\error.log"
# ✅ Aucun fichier supprimé !

# Autres exemples
Stop-Service -Name "wuauserv" -WhatIf
# What if: Performing the operation "Stop-Service" on target "Windows Update (wuauserv)"

New-Item -Path C:\Temp\test.txt -ItemType File -WhatIf
# What if: Performing the operation "Create File" on target "Destination: C:\Temp\test.txt"

# Dans des boucles
Get-Process -Name "notepad" | Stop-Process -WhatIf
# Montre ce qui serait arrêté sans toucher aux processus
```

#### 📝 `-Confirm` : Demander confirmation

```powershell
# Confirmation interactive
Stop-Process -Name "notepad" -Confirm
# Prompt :
# Confirm
# Are you sure you want to perform this action?
# Performing the operation "Stop-Process" on target "notepad (12345)".
# [Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"):

# Combiner avec un pipeline
Get-Process -Name "chrome" | Stop-Process -Confirm
# Demande confirmation pour CHAQUE processus Chrome

# Forcer l'exécution sans confirmation
Remove-Item C:\Temp\*.log -Confirm:$false
# Utile quand $ConfirmPreference est élevé
```

#### 📝 Préférence de confirmation globale

```powershell
# Variable contrôlant le seuil de confirmation automatique
$ConfirmPreference
# Défaut : "High" (confirme uniquement les actions à fort impact)

# Valeurs possibles (par ordre d'impact) :
# None     - Aucune confirmation automatique
# Low      - Confirme même les actions à faible impact
# Medium   - Confirme les actions à impact moyen et élevé
# High     - Confirme uniquement les actions à fort impact

# Forcer la confirmation pour tout
$ConfirmPreference = "Low"
Remove-Item test.txt  # Demandera confirmation même sans -Confirm

# Désactiver toutes les confirmations
$ConfirmPreference = "None"
```

#### 📝 SupportsShouldProcess dans vos fonctions

```powershell
# Ajouter le support de -WhatIf et -Confirm à vos fonctions
function Remove-MyFiles {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [string]$Path
    )
    
    $files = Get-ChildItem $Path
    
    foreach ($file in $files) {
        # Vérifier si on doit vraiment exécuter
        if ($PSCmdlet.ShouldProcess($file.FullName, "Supprimer")) {
            Remove-Item $file.FullName
        }
    }
}

# Maintenant votre fonction supporte -WhatIf et -Confirm !
Remove-MyFiles -Path C:\Temp -WhatIf
Remove-MyFiles -Path C:\Temp -Confirm
```

> [!tip] Workflow sécurisé recommandé
> 
> 1. Développer et tester avec `-WhatIf`
> 2. Exécuter une première fois avec `-Confirm`
> 3. Si tout est correct, exécuter sans paramètres
> 
> ```powershell
> # Phase 1 : Tester
> Get-ChildItem C:\OldData -Recurse | Remove-Item -WhatIf
> 
> # Phase 2 : Confirmer interactivement
> Get-ChildItem C:\OldData -Recurse | Remove-Item -Confirm
> 
> # Phase 3 : Exécution finale
> Get-ChildItem C:\OldData -Recurse | Remove-Item
> ```

> [!warning] Cmdlets sans support Toutes les cmdlets ne supportent pas `-WhatIf` et `-Confirm`. Vérifiez avec :
> 
> ```powershell
> (Get-Command Get-ChildItem).Parameters.ContainsKey("WhatIf")  # False
> (Get-Command Remove-Item).Parameters.ContainsKey("WhatIf")     # True
> ```

> [!example] Cas d'usage réel
> 
> ```powershell
> # Nettoyage de logs de plus de 30 jours
> $cutoffDate = (Get-Date).AddDays(-30)
> 
> # 1. Voir ce qui serait supprimé
> Get-ChildItem C:\Logs -Recurse |
>     Where-Object {$_.LastWriteTime -lt $cutoffDate} |
>     Remove-Item -WhatIf
> 
> # 2. Vérifier les fichiers et confirmer
> Get-ChildItem C:\Logs -Recurse |
>     Where-Object {$_.LastWriteTime -lt $cutoffDate} |
>     Remove-Item -Confirm
> 
> # 3. Exécution automatisée (script planifié)
> Get-ChildItem C:\Logs -Recurse |
>     Where-Object {$_.LastWriteTime -lt $cutoffDate} |
>     Remove-Item -Force -ErrorAction SilentlyContinue
> ```

---

## Paramètres avec valeurs multiples (arrays)

### 🎯 Concept

De nombreux paramètres PowerShell acceptent **plusieurs valeurs** sous forme de tableau (array). Cela permet de traiter plusieurs éléments en une seule commande au lieu de boucler manuellement.

### 💡 Pourquoi c'est important

- **Efficacité** : Une seule commande pour plusieurs cibles
- **Lisibilité** : Code plus concis et clair
- **Performance** : Traitement optimisé par la cmdlet

### 📝 Syntaxes pour passer des arrays

#### 1. Séparés par des virgules

```powershell
# Syntaxe de base
Get-Service -Name "wuauserv", "WinRM", "Spooler"

# Équivalent à (mais plus efficace que) :
Get-Service -Name "wuauserv"
Get-Service -Name "WinRM"
Get-Service -Name "Spooler"

# Autres exemples
Get-Process -Name "pwsh", "notepad", "chrome"
Remove-Item "fichier1.txt", "fichier2.txt", "fichier3.txt"
```

#### 2. Avec une variable array

```powershell
# Créer un array
$services = @("wuauserv", "WinRM", "Spooler")

# Passer l'array au paramètre
Get-Service -Name $services

# Array de chemins
$paths = @(
    "C:\Logs\app.log",
    "C:\Logs\error.log",
    "C:\Logs\debug.log"
)
Get-Content $paths | Select-Object -First 10
```

#### 3. À partir d'un pipeline ou d'un fichier

```powershell
# À partir d'un fichier texte (un élément par ligne)
$computerNames = Get-Content "C:\computers.txt"
Get-Service -ComputerName $computerNames

# À partir d'un pipeline
Get-ChildItem C:\Temp\*.txt | Remove-Item

# Combiner : extraire des noms d'un CSV
$users = Import-Csv users.csv | Select-Object -ExpandProperty Username
Get-ADUser -Identity $users
```

#### 4. Syntaxe avec @()

```powershell
# Array vide
$empty = @()

# Array sur plusieurs lignes (lisibilité)
$services = @(
    "wuauserv"
    "WinRM"
    "Spooler"
    "BITS"
)

Get-Service -Name $services

# Array dynamique
$processes = @(
    "pwsh"
    if ($env:COMPUTERNAME -eq "PROD") { "apache" }
    "notepad"
)
```

### 📝 Identifier les paramètres acceptant des arrays

#### Avec Get-Help

```powershell
Get-Help Get-Service -Parameter Name

# Sortie :
# -Name <System.String[]>        # Le [] indique un array !
#     Specifies the service names of services to retrieve.
```

#### Avec Get-Command

```powershell
# Voir le type du paramètre
(Get-Command Get-Service).Parameters["Name"].ParameterType

# Sortie : System.String[]  → array de strings
# Si pas de [], c'est une valeur unique
```

#### Dans la signature de fonction

```powershell
function Test-Array {
    param(
        [string[]]$Names,          # Array de strings
        [int[]]$Numbers,           # Array d'entiers
        [string]$SingleValue       # Valeur unique (pas d'array)
    )
}

# Utilisation
Test-Array -Names "John", "Jane", "Bob" -Numbers 1, 2, 3 -SingleValue "test"
```

### 📝 Exemples pratiques

#### Gestion de services

```powershell
# Arrêter plusieurs services d'un coup
$servicesToStop = @("wuauserv", "BITS", "Spooler")
Stop-Service -Name $servicesToStop -WhatIf

# Vérifier l'état de plusieurs services
Get-Service -Name $servicesToStop | 
    Select-Object Name, Status, StartType |
    Format-Table -AutoSize
```

#### Gestion de processus

```powershell
# Surveiller plusieurs processus
$processesToMonitor = "pwsh", "code", "chrome"
Get-Process -Name $processesToMonitor |
    Select-Object Name, CPU, WorkingSet |
    Sort-Object CPU -Descending

# Arrêter tous les processus notepad
Get-Process -Name "notepad" | Stop-Process -Confirm
```

#### Gestion de fichiers

```powershell
# Supprimer plusieurs types de fichiers
$extensionsToClean = "*.tmp", "*.log", "*.bak"
foreach ($ext in $extensionsToClean) {
    Remove-Item "C:\Temp\$ext" -ErrorAction SilentlyContinue
}

# Ou avec Get-ChildItem
Get-ChildItem C:\Temp -Include $extensionsToClean -Recurse |
    Remove-Item -WhatIf
```

#### Requêtes sur plusieurs machines

```powershell
# Liste de serveurs
$servers = @(
    "SERVER01",
    "SERVER02",
    "SERVER03"
)

# Vérifier l'espace disque sur tous les serveurs
Get-CimInstance -ClassName Win32_LogicalDisk -ComputerName $servers |
    Where-Object {$_.DriveType -eq 3} |
    Select-Object SystemName, DeviceID, 
        @{N="SizeGB"; E={[math]::Round($_.Size/1GB, 2)}},
        @{N="FreeGB"; E={[math]::Round($_.FreeSpace/1GB, 2)}} |
    Format-Table -AutoSize
```

### 📝 Wildcards dans les arrays

```powershell
# PowerShell traite automatiquement les wildcards
Get-Service -Name "*win*"  # Tous les services contenant "win"

# Combiner valeurs exactes et wildcards
Get-Service -Name "wuauserv", "*win*", "Spooler"

# Dans les fichiers
Get-ChildItem -Path "C:\Logs" -Include "*.log", "*.txt"
```

### 📝 Opérations sur les arrays

```powershell
# Ajouter des éléments
$services = @("wuauserv", "WinRM")
$services += "Spooler"      # Ajoute un élément
$services += "BITS", "W32Time"  # Ajoute plusieurs éléments

# Filtrer un array
$allServices = Get-Service
$runningServices = $allServices | Where-Object {$_.Status -eq "Running"}

# Transformer un array
$serviceNames = $allServices | Select-Object -ExpandProperty Name

# Compter les éléments
$services.Count

# Trier un array
$sortedServices = $services | Sort-Object
```

### 📊 Comparaison : Boucle vs Array parameter

```powershell
# ❌ Méthode inefficace : boucle manuelle
$services = "wuauserv", "WinRM", "Spooler"
foreach ($service in $services) {
    Get-Service -Name $service
}
# 3 appels séparés à Get-Service

# ✅ Méthode efficace : array parameter
Get-Service -Name $services
# 1 seul appel à Get-Service qui traite les 3 services

# Différence de performance significative avec de gros volumes !
```

> [!tip] Performances Toujours préférer passer un array à un paramètre plutôt que de boucler manuellement. Les cmdlets sont optimisées pour traiter des arrays efficacement.

> [!tip] Construire des arrays dynamiquement
> 
> ```powershell
> # Array vide au départ
> $results = @()
> 
> # Ajouter conditionnellement
> foreach ($server in $servers) {
>     if (Test-Connection $server -Count 1 -Quiet) {
>         $results += $server
>     }
> }
> 
> # Utiliser l'array résultant
> Get-Service -ComputerName $results
> ```

> [!warning] Différence paramètre array vs pipeline
> 
> ```powershell
> # Paramètre array : un seul appel, tous les éléments d'un coup
> Get-Service -Name "service1", "service2", "service3"
> 
> # Pipeline : plusieurs appels, un par un
> "service1", "service2", "service3" | Get-Service
> 
> # Le paramètre array est généralement plus performant
> ```

> [!example] Cas d'usage avancé : Inventaire multi-serveurs
> 
> ```powershell
> # Configuration
> $servers = Get-Content "C:\servers.txt"
> $services = "wuauserv", "WinRM", "W32Time"
> 
> # Collecter l'état de plusieurs services sur plusieurs serveurs
> $inventory = foreach ($server in $servers) {
>     Get-Service -Name $services -ComputerName $server -ErrorAction SilentlyContinue |
>         Select-Object @{N="Server"; E={$server}}, Name, Status, StartType
> }
> 
> # Analyser les résultats
> $inventory | Where-Object {$_.Status -ne "Running"} |
>     Format-Table Server, Name, Status -AutoSize
> 
> # Exporter pour rapport
> $inventory | Export-Csv "ServiceInventory.csv" -NoTypeInformation
> ```

---

## 🎓 Récapitulatif

### Points clés à retenir

1. **Paramètres positionnels vs nommés**
    
    - Positionnels = rapides mais moins lisibles
    - Nommés = clairs et maintenables
    - Toujours nommer dans les scripts de production
2. **Obligatoires vs optionnels**
    
    - Identifiez-les avec `Get-Help` et la syntaxe
    - Les paramètres obligatoires déclenchent une invite interactive si omis
    - Utilisez des jeux de paramètres pour différents scénarios
3. **Valeurs par défaut**
    
    - Variables de préférence globales : `$ErrorActionPreference`, etc.
    - `$PSDefaultParameterValues` pour personnaliser cmdlets spécifiques
    - Configurez votre profil pour un environnement optimal
4. **Syntaxe complète vs abrégée**
    
    - Abrégez en interactif, écrivez complet dans les scripts
    - Risque d'ambiguïté avec les abréviations
    - Les alias sont encore plus courts mais moins recommandés
5. **Tab completion**
    
    - Votre meilleur ami pour la productivité
    - **Tab** pour compléter, **Ctrl+Space** pour le menu complet
    - Fonctionne pour cmdlets, paramètres, valeurs, propriétés
    - PSReadLine améliore encore l'expérience (PowerShell 7+)
6. **Paramètres communs**
    
    - `-Verbose` et `-Debug` pour comprendre et déboguer
    - `-ErrorAction` pour contrôler la gestion d'erreurs
    - `-WhatIf` et `-Confirm` pour la sécurité
    - `-ErrorVariable`, `-WarningVariable` pour capturer les messages
    - `-PipelineVariable` pour référencer l'objet original dans le pipeline
7. **Arrays**
    
    - Passez plusieurs valeurs avec des virgules : `"val1", "val2", "val3"`
    - Identifiez les paramètres array avec `[]` dans la signature
    - Plus efficace que les boucles manuelles
    - Combinez avec wildcards pour plus de flexibilité

### Bonnes pratiques

✅ **À faire :**

- Utiliser des paramètres nommés dans les scripts
- Tester avec `-WhatIf` avant les opérations destructrices
- Utiliser `-ErrorAction Stop` en production avec `try/catch`
- Passer des arrays aux paramètres plutôt que de boucler
- Exploiter Tab completion pour explorer les options
- Configurer `$PSDefaultParameterValues` dans votre profil

❌ **À éviter :**

- Mélanger positionnels et nommés sans respecter l'ordre
- Utiliser des abréviations dans les scripts partagés
- Ignorer les erreurs sans raison (`-ErrorAction Ignore`)
- Oublier les paramètres obligatoires dans les scripts non supervisés
- Oublier de tester avec `-WhatIf` sur des commandes critiques

---

**Maîtriser les paramètres, c'est maîtriser PowerShell.** Ces concepts sont la fondation de scripts robustes, maintenables et professionnels. Pratiquez-les régulièrement et ils deviendront une seconde nature ! 🚀 |