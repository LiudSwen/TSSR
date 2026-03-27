
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

## Introduction aux commandes de découverte {#introduction}

PowerShell dispose de trois commandes fondamentales qui forment la **triade de la découverte**. Ces commandes vous permettent d'explorer et de comprendre PowerShell sans avoir à consulter constamment la documentation externe.

> [!info] Philosophie PowerShell PowerShell est conçu pour être **auto-documenté**. Contrairement à d'autres shells, vous n'avez pas besoin de mémoriser toutes les commandes - vous devez simplement savoir comment les découvrir.

**Les trois piliers** :

- `Get-Help` → Comprendre **comment utiliser** une commande
- `Get-Command` → Découvrir **quelles commandes** existent
- `Get-Member` → Explorer **ce qu'un objet** contient

---

## 🆘 Get-Help - Le système d'aide {#get-help}

`Get-Help` est votre première ressource pour comprendre n'importe quelle commande PowerShell. Il affiche la documentation intégrée avec des exemples, la syntaxe et les descriptions détaillées.

### Pourquoi utiliser Get-Help ?

- **Apprendre la syntaxe** d'une commande sans chercher sur Internet
- **Voir des exemples concrets** d'utilisation
- **Comprendre les paramètres** disponibles et leur fonctionnement
- **Accéder à des explications conceptuelles** via les "about topics"

---

### Syntaxe de base

```powershell
# Aide basique pour une commande
Get-Help Get-Process

# Aide pour un alias
Get-Help gps

# Recherche par mot-clé
Get-Help *process*
```

> [!tip] Raccourci pratique Vous pouvez utiliser `help` au lieu de `Get-Help`. C'est une fonction qui ajoute une pagination automatique, plus confortable à lire dans la console.

---

### Les différents niveaux d'aide

#### Aide par défaut (basique)

```powershell
Get-Help Get-Process
```

Affiche :

- Nom de la commande
- Synopsis (description courte)
- Syntaxe simplifiée
- Description générale
- Liens associés

#### Aide avec exemples

```powershell
Get-Help Get-Process -Examples
```

> [!example] Quand l'utiliser ? Parfait quand vous connaissez la commande mais voulez voir rapidement comment l'utiliser dans des cas concrets.

Affiche uniquement la section exemples avec des scénarios d'utilisation courants.

#### Aide détaillée

```powershell
Get-Help Get-Process -Detailed
```

Ajoute à l'aide basique :

- Description détaillée de **chaque paramètre**
- Exemples d'utilisation
- Notes supplémentaires

#### Aide complète

```powershell
Get-Help Get-Process -Full
```

> [!info] Le niveau le plus exhaustif Contient absolument tout : descriptions techniques complètes, informations sur les types d'entrée/sortie, et tous les détails de chaque paramètre.

Inclut :

- Toutes les informations de `-Detailed`
- Types d'objets acceptés en entrée
- Types d'objets retournés
- Informations techniques avancées

#### Aide en ligne

```powershell
Get-Help Get-Process -Online
```

Ouvre la documentation officielle Microsoft dans votre navigateur. Utile car :

- Documentation toujours à jour
- Commentaires de la communauté
- Liens vers des ressources connexes

---

### Aide ciblée sur les paramètres

```powershell
# Voir uniquement les paramètres disponibles
Get-Help Get-Process -Parameter *

# Aide sur un paramètre spécifique
Get-Help Get-Process -Parameter Name
```

> [!tip] Astuce de recherche Utilisez `*` comme joker pour explorer. Par exemple : `Get-Help Get-Process -Parameter *Name*` trouvera tous les paramètres contenant "Name".

---

### Mise à jour de l'aide

L'aide PowerShell n'est **pas installée par défaut** dans les versions récentes. Vous devez la télécharger.

```powershell
# Mise à jour de toute l'aide (nécessite des droits administrateur)
Update-Help

# Mise à jour pour un module spécifique
Update-Help -Module Microsoft.PowerShell.Management

# Forcer la mise à jour même si récente
Update-Help -Force

# Mise à jour sans erreurs si un module échoue
Update-Help -ErrorAction SilentlyContinue
```

> [!warning] Attention aux erreurs `Update-Help` peut échouer pour certains modules tiers qui n'ont pas d'aide téléchargeable. Utilisez `-ErrorAction SilentlyContinue` pour ignorer ces erreurs.

**Fréquence recommandée** : Tous les 2-3 mois ou après l'installation de nouveaux modules.

---

### About Topics - Les concepts PowerShell

Les **about topics** sont des pages d'aide qui expliquent des **concepts** plutôt que des commandes spécifiques.

```powershell
# Lister tous les about topics disponibles
Get-Help about_*

# Exemples de topics importants
Get-Help about_Variables
Get-Help about_Operators
Get-Help about_Comparison_Operators
Get-Help about_If
Get-Help about_Functions
Get-Help about_Pipelines
```

> [!example] Exemples de topics essentiels
> 
> - `about_Execution_Policies` : Comprendre les politiques d'exécution
> - `about_Operators` : Tous les opérateurs PowerShell
> - `about_Regular_Expressions` : Les regex dans PowerShell
> - `about_Automatic_Variables` : Variables automatiques comme `$_`, `$PSItem`

#### Recherche dans les topics

```powershell
# Rechercher un concept spécifique
Get-Help about_* | Where-Object Name -like "*comparison*"

# Lire un topic complet
Get-Help about_Comparison_Operators -Full
```

---

### Navigation et recherche dans l'aide

#### Recherche par mot-clé

```powershell
# Chercher dans les noms de commandes et synopsis
Get-Help *service*

# Recherche plus large (plus lente)
Get-Help service -Category All
```

#### Filtrage par catégorie

Les catégories d'aide incluent : Cmdlet, Function, Provider, Alias, ExternalScript, HelpFile, etc.

```powershell
# Aide sur les cmdlets uniquement
Get-Help Get-Process -Category Cmdlet

# Aide sur les fonctions
Get-Help *profile* -Category Function
```

---

### Pièges courants

> [!warning] Erreur fréquente : Aide non téléchargée **Symptôme** : L'aide affiche uniquement la syntaxe de base. **Solution** : Exécutez `Update-Help` en tant qu'administrateur.

> [!warning] Paramètre mal orthographié `Get-Help` est tolérant, mais si vous cherchez de l'aide sur un paramètre inexistant, il ne retourne rien sans erreur.

```powershell
# Mauvais - ne retourne rien
Get-Help Get-Process -Parameter Namee

# Bon - utilisez le joker pour explorer
Get-Help Get-Process -Parameter *Name*
```

---

### Bonnes pratiques

✅ **Consultez toujours les exemples** en premier : `Get-Help <commande> -Examples`

✅ **Utilisez `help` plutôt que `Get-Help`** pour une lecture paginée dans la console

✅ **Explorez les about topics** pour comprendre les concepts fondamentaux

✅ **Mettez à jour l'aide régulièrement** pour avoir les informations les plus récentes

✅ **Utilisez `-Online`** pour la documentation la plus à jour avec commentaires

---

### Astuces avancées

```powershell
# Recherche intelligente avec Select-String
Get-Help Get-Process -Full | Select-String "CPU"

# Sauvegarder l'aide dans un fichier texte
Get-Help Get-Process -Full | Out-File C:\Aide\Get-Process.txt

# Comparer l'aide de deux commandes similaires
Compare-Object (Get-Help Get-Process) (Get-Help Get-Service)
```

---

## 🔎 Get-Command - Découvrir les commandes {#get-command}

`Get-Command` vous permet de **découvrir quelles commandes existent** dans PowerShell. C'est votre outil de recherche pour explorer les cmdlets, fonctions, alias et applications disponibles.

### Pourquoi utiliser Get-Command ?

- **Trouver une commande** quand vous ne connaissez qu'une partie du nom
- **Lister toutes les commandes** d'un module spécifique
- **Découvrir les commandes disponibles** après l'installation d'un nouveau module
- **Explorer par verbe ou nom** selon la convention Verbe-Nom

---

### Syntaxe de base

```powershell
# Lister TOUTES les commandes disponibles (très long)
Get-Command

# Rechercher par nom partiel
Get-Command *process*

# Rechercher une commande spécifique
Get-Command Get-Process
```

> [!info] Nombre de commandes Une installation PowerShell standard contient plus de 1500 commandes. `Get-Command` sans paramètre les affiche toutes.

---

### Recherche par verbe

PowerShell utilise une convention **Verbe-Nom**. Les verbes sont standardisés pour garantir la cohérence.

```powershell
# Toutes les commandes commençant par "Get"
Get-Command -Verb Get

# Toutes les commandes commençant par "Set"
Get-Command -Verb Set

# Comparer les verbes Get et Set pour un même nom
Get-Command -Verb Get, Set -Noun Process
```

#### Verbes PowerShell courants

|Verbe|Signification|Exemple|
|---|---|---|
|`Get`|Récupérer des données|`Get-Process`|
|`Set`|Modifier des données|`Set-ExecutionPolicy`|
|`New`|Créer quelque chose|`New-Item`|
|`Remove`|Supprimer|`Remove-Item`|
|`Start`|Démarrer|`Start-Service`|
|`Stop`|Arrêter|`Stop-Process`|
|`Test`|Vérifier|`Test-Path`|
|`Add`|Ajouter|`Add-Content`|
|`Clear`|Effacer|`Clear-Content`|

```powershell
# Lister tous les verbes approuvés
Get-Verb
```

---

### Recherche par nom (Noun)

Le nom représente **ce sur quoi la commande agit**.

```powershell
# Toutes les commandes agissant sur les processus
Get-Command -Noun Process

# Toutes les commandes agissant sur les services
Get-Command -Noun Service

# Combinaison verbe + nom
Get-Command -Verb Get -Noun *Item*
```

> [!tip] Astuce de recherche Si vous voulez faire quelque chose avec des fichiers, cherchez `-Noun Item` ou `-Noun Content`. Pour les services système, cherchez `-Noun Service`.

---

### Recherche par module

Les commandes sont organisées en **modules**. Vous pouvez filtrer par module pour voir ce qu'un module spécifique offre.

```powershell
# Lister les commandes d'un module spécifique
Get-Command -Module Microsoft.PowerShell.Management

# Voir tous les modules chargés
Get-Module

# Voir tous les modules disponibles (chargés ou non)
Get-Module -ListAvailable

# Commandes d'un module non encore chargé
Get-Command -Module ActiveDirectory
```

> [!example] Modules courants
> 
> - `Microsoft.PowerShell.Management` : Gestion du système
> - `Microsoft.PowerShell.Utility` : Utilitaires généraux
> - `Microsoft.PowerShell.Security` : Sécurité et exécution
> - `NetTCPIP` : Configuration réseau

---

### Filtrage par type de commande

PowerShell distingue plusieurs types de commandes.

```powershell
# Seulement les cmdlets
Get-Command -CommandType Cmdlet

# Seulement les fonctions
Get-Command -CommandType Function

# Seulement les alias
Get-Command -CommandType Alias

# Plusieurs types
Get-Command -CommandType Cmdlet, Function
```

|Type|Description|
|---|---|
|`Cmdlet`|Commandes compilées en C# (les "vraies" cmdlets)|
|`Function`|Fonctions PowerShell|
|`Alias`|Raccourcis vers d'autres commandes|
|`Application`|Exécutables externes (.exe)|
|`Script`|Scripts PowerShell (.ps1)|

---

### Découverte des commandes disponibles

#### Scénario 1 : Je veux gérer des services

```powershell
# Méthode 1 : Par nom
Get-Command *service*

# Méthode 2 : Par noun
Get-Command -Noun Service

# Résultat typique :
# Get-Service, Start-Service, Stop-Service, Restart-Service, etc.
```

#### Scénario 2 : Que puis-je faire avec Get-Command ?

```powershell
# Toutes les commandes Get
Get-Command -Verb Get | Measure-Object  # Compter

# Les plus couramment utilisées
Get-Command -Verb Get -Noun Process, Service, Item, Content, ChildItem
```

#### Scénario 3 : J'ai installé un module, que contient-il ?

```powershell
# Exemple avec le module Pester (framework de tests)
Install-Module Pester -Force
Get-Command -Module Pester
```

---

### Informations détaillées sur une commande

```powershell
# Vue simple
Get-Command Get-Process

# Vue détaillée (avec paramètres)
Get-Command Get-Process | Format-List *

# Propriétés importantes
Get-Command Get-Process | Select-Object Name, Module, CommandType, Version
```

---

### Recherche d'applications externes

`Get-Command` trouve aussi les exécutables dans votre `$env:PATH`.

```powershell
# Trouver où est notepad.exe
Get-Command notepad

# Toutes les applications .exe disponibles
Get-Command -CommandType Application

# Chercher une application spécifique
Get-Command *docker*
```

---

### Pièges courants

> [!warning] Confusion entre Get-Command et Get-Help
> 
> - `Get-Command` → **Trouve** une commande
> - `Get-Help` → **Explique** comment utiliser une commande

> [!warning] Trop de résultats `Get-Command` sans filtre retourne plus de 1500 commandes. Utilisez toujours des filtres.

```powershell
# Mauvais - trop de résultats
Get-Command

# Bon - ciblé
Get-Command -Verb Get -Noun Process
Get-Command *network*
```

---

### Bonnes pratiques

✅ **Utilisez les jokers** pour explorer : `Get-Command *process*`

✅ **Filtrez par verbe ET nom** pour des résultats précis

✅ **Explorez les modules** après installation pour découvrir leurs capacités

✅ **Combinez avec Where-Object** pour des filtres complexes

✅ **Utilisez `-Syntax`** pour voir rapidement la syntaxe sans ouvrir l'aide complète

---

### Astuces avancées

```powershell
# Voir la syntaxe rapidement sans l'aide complète
Get-Command Get-Process -Syntax

# Trouver les commandes avec un paramètre spécifique
Get-Command -ParameterName ComputerName

# Compter les commandes par module
Get-Command | Group-Object ModuleName | Sort-Object Count -Descending

# Trouver toutes les commandes expérimentales
Get-Command | Where-Object { $_.Name -like '*-*-*' }

# Exporter la liste des commandes disponibles
Get-Command | Export-Csv C:\commandes.csv -NoTypeInformation
```

---

## 🧩 Get-Member - Explorer les objets {#get-member}

`Get-Member` est la commande qui vous permet de **découvrir ce qu'un objet contient** : ses propriétés (données) et ses méthodes (actions possibles).

### Pourquoi utiliser Get-Member ?

- **Comprendre la structure** des objets retournés par une commande
- **Découvrir les propriétés** disponibles pour filtrer ou afficher
- **Trouver les méthodes** pour manipuler les objets
- **Identifier le type** exact d'un objet

> [!info] PowerShell = Objets Contrairement aux shells traditionnels qui manipulent du texte, PowerShell manipule des **objets**. `Get-Member` est votre fenêtre sur ces objets.

---

### Syntaxe de base

```powershell
# Explorer les propriétés et méthodes d'un objet
Get-Process | Get-Member

# Raccourci courant
Get-Process | gm
```

**Sortie typique** :

```
TypeName: System.Diagnostics.Process

Name                MemberType     Definition
----                ----------     ----------
Handles             Property       int Handles {get;}
Id                  Property       int Id {get;}
ProcessName         Property       string ProcessName {get;}
Kill                Method         void Kill()
WaitForExit         Method         void WaitForExit()
```

---

### Comprendre la sortie de Get-Member

#### TypeName

```powershell
Get-Process | Get-Member
# TypeName: System.Diagnostics.Process
```

Le **TypeName** indique le type .NET de l'objet. C'est son "identité" dans le système de types PowerShell.

> [!tip] Pourquoi c'est important ? Connaître le type vous permet de :
> 
> - Chercher de la documentation .NET
> - Comprendre quelles conversions sont possibles
> - Filtrer avec `-MemberType` ou `Where-Object`

#### Les colonnes

|Colonne|Description|
|---|---|
|`Name`|Nom de la propriété ou méthode|
|`MemberType`|Type de membre (Property, Method, etc.)|
|`Definition`|Signature technique (type de retour, paramètres)|

---

### Types de membres

#### Properties (Propriétés)

Les propriétés sont des **données** associées à l'objet.

```powershell
# Voir uniquement les propriétés
Get-Process | Get-Member -MemberType Property

# Exemples de propriétés d'un processus
# - ProcessName : Le nom du processus
# - Id : L'identifiant unique
# - CPU : Le temps CPU utilisé
# - WorkingSet : La mémoire utilisée
```

**Accès aux propriétés** :

```powershell
# Via la notation point
$process = Get-Process -Name "powershell"
$process.ProcessName
$process.Id

# Via Select-Object
Get-Process | Select-Object ProcessName, Id, CPU
```

#### Methods (Méthodes)

Les méthodes sont des **actions** que vous pouvez effectuer sur l'objet.

```powershell
# Voir uniquement les méthodes
Get-Process | Get-Member -MemberType Method

# Exemples de méthodes d'un processus
# - Kill() : Arrêter le processus
# - WaitForExit() : Attendre que le processus se termine
# - Refresh() : Actualiser les données du processus
```

**Utilisation des méthodes** :

```powershell
# Appeler une méthode sans paramètre
$process = Get-Process -Name "notepad"
$process.Kill()

# Appeler une méthode avec paramètres
$process.WaitForExit(5000)  # Attendre 5 secondes maximum
```

> [!warning] Attention aux méthodes destructrices Certaines méthodes comme `Kill()` ou `Delete()` modifient ou détruisent des objets. Soyez prudent !

---

### Différence entre propriétés et méthodes

|Aspect|Propriété|Méthode|
|---|---|---|
|**Nature**|Données, attributs|Actions, comportements|
|**Lecture**|`$objet.Propriété`|`$objet.Méthode()`|
|**Modification**|Peut être en lecture seule|Peut modifier l'objet|
|**Exemple**|`$process.ProcessName`|`$process.Kill()`|

```powershell
# Propriété : Lire une information
$service = Get-Service -Name "Spooler"
$service.Status        # Propriété : Lire le statut

# Méthode : Effectuer une action
$service.Start()       # Méthode : Démarrer le service
```

---

### Utilisation avec le pipeline

`Get-Member` s'utilise principalement **dans le pipeline** pour analyser les objets produits par d'autres commandes.

```powershell
# Analyser le résultat de Get-Process
Get-Process | Get-Member

# Analyser le résultat de Get-Service
Get-Service | Get-Member

# Analyser le résultat de Get-ChildItem
Get-ChildItem C:\ | Get-Member
```

> [!example] Exemple pratique Vous voulez filtrer des fichiers par taille, mais vous ne savez pas quelle propriété utiliser :
> 
> ```powershell
> Get-ChildItem | Get-Member -MemberType Property
> # Résultat : La propriété s'appelle "Length"
> 
> Get-ChildItem | Where-Object Length -gt 1MB
> ```

---

### Filtrage des membres

#### Par type de membre

```powershell
# Seulement les propriétés
Get-Process | Get-Member -MemberType Property

# Seulement les méthodes
Get-Process | Get-Member -MemberType Method

# Propriétés ET méthodes (par défaut)
Get-Process | Get-Member -MemberType Property, Method
```

#### Par nom

```powershell
# Trouver un membre spécifique
Get-Process | Get-Member -Name "ProcessName"

# Recherche avec joker
Get-Process | Get-Member -Name "*Name*"

# Trouver toutes les méthodes contenant "Kill"
Get-Process | Get-Member -Name "*Kill*" -MemberType Method
```

---

### Types d'objets PowerShell

Différents types d'objets ont des propriétés et méthodes différentes.

```powershell
# Type de processus
Get-Process | Get-Member
# TypeName: System.Diagnostics.Process

# Type de service
Get-Service | Get-Member
# TypeName: System.ServiceProcess.ServiceController

# Type de fichier/dossier
Get-ChildItem | Get-Member
# TypeName: System.IO.FileInfo (fichiers)
# TypeName: System.IO.DirectoryInfo (dossiers)

# Type de chaîne de caractères
"Hello" | Get-Member
# TypeName: System.String
```

---

### Explorer les propriétés cachées

Par défaut, PowerShell n'affiche pas toutes les propriétés dans la console. `Get-Member` vous les révèle.

```powershell
# Affichage par défaut
Get-Process powershell

# Toutes les propriétés disponibles
Get-Process powershell | Get-Member -MemberType Property

# Afficher une propriété spécifique
Get-Process powershell | Select-Object ProcessName, Threads, Modules
```

> [!tip] Astuce : Select-Object * Pour voir TOUTES les propriétés d'un objet dans la console :
> 
> ```powershell
> Get-Process powershell | Select-Object *
> ```

---

### Méthodes statiques vs méthodes d'instance

#### Méthodes d'instance

S'appliquent à un objet **spécifique**.

```powershell
$process = Get-Process -Name "notepad"
$process.Kill()  # Agit sur CE processus spécifique
```

#### Méthodes statiques

S'appliquent à la **classe** elle-même, pas à une instance.

```powershell
# Voir les membres statiques
Get-Process | Get-Member -Static

# Exemple de méthode statique
[System.Math]::Sqrt(16)        # Racine carrée
[System.DateTime]::Now         # Date actuelle
```

---

### Pièges courants

> [!warning] Oublier le pipeline `Get-Member` s'utilise **après** une commande dans le pipeline.
> 
> ```powershell
> # Mauvais - ne fonctionne pas
> Get-Member Get-Process
> 
> # Bon
> Get-Process | Get-Member
> ```

> [!warning] Confondre propriété et méthode Les propriétés se lisent sans parenthèses, les méthodes nécessitent `()`.
> 
> ```powershell
> # Propriété (pas de parenthèses)
> $process.ProcessName
> 
> # Méthode (avec parenthèses)
> $process.Kill()
> ```

> [!warning] Méthodes sans effet visible Certaines méthodes retournent une valeur mais ne modifient pas l'objet.
> 
> ```powershell
> # Mauvais - ne modifie pas $text
> $text = "hello"
> $text.ToUpper()  # Retourne "HELLO" mais ne change pas $text
> 
> # Bon - réassigner le résultat
> $text = $text.ToUpper()
> ```

---

### Bonnes pratiques

✅ **Utilisez Get-Member systématiquement** quand vous découvrez un nouveau type d'objet

✅ **Filtrez par MemberType** pour réduire le bruit

✅ **Combinez avec Where-Object** pour explorer des collections d'objets

✅ **Documentez les propriétés clés** dans vos scripts avec des commentaires

✅ **Testez les méthodes** dans un environnement de test avant de les utiliser en production

---

### Astuces avancées

```powershell
# Comparer les membres de deux types d'objets
Compare-Object (Get-Process | Get-Member) (Get-Service | Get-Member)

# Trouver les propriétés communes à tous les objets d'une collection
Get-Process | Get-Member -MemberType Property | 
    Group-Object Name | Where-Object Count -eq (Get-Process).Count

# Voir la définition complète d'une propriété
Get-Process | Get-Member -Name "CPU" | Format-List *

# Trouver toutes les méthodes qui ne prennent aucun paramètre
Get-Process | Get-Member -MemberType Method | 
    Where-Object Definition -like "*void *(*)*"

# Explorer les propriétés d'un fichier
Get-Item "C:\Windows\System32\notepad.exe" | Get-Member

# Voir les méthodes de manipulation de chaînes
"texte" | Get-Member -MemberType Method
```

---

## 🎯 Synthèse : Utilisation combinée des trois commandes

Les trois commandes forment un **flux de travail naturel** :

```powershell
# 1. Trouver une commande
Get-Command *process*

# 2. Comprendre comment l'utiliser
Get-Help Get-Process -Examples

# 3. Explorer ce qu'elle retourne
Get-Process | Get-Member
```

### Exemple pratique complet

**Objectif** : Trouver et arrêter les processus qui consomment beaucoup de mémoire.

```powershell
# Étape 1 : Trouver les commandes liées aux processus
Get-Command -Noun Process
# Résultat : Get-Process, Stop-Process, Start-Process...

# Étape 2 : Comprendre Get-Process
Get-Help Get-Process -Examples

# Étape 3 : Voir quelles propriétés sont disponibles
Get-Process | Get-Member -MemberType Property
# Résultat : WorkingSet (mémoire), CPU, ProcessName...

# Étape 4 : Utiliser ces propriétés
Get-Process | Where-Object WorkingSet -gt 500MB | 
    Select-Object ProcessName, Id, @{N='MemoryMB';E={$_.WorkingSet / 1MB}}

# Étape 5 : Arrêter un processus si nécessaire
Stop-Process -Id 1234 -WhatIf  # -WhatIf pour simuler
```

---

**🎓 Fin de la section 2.2**