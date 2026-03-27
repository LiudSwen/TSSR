

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

## 🎯 Introduction

La gestion des membres de groupes locaux est essentielle pour contrôler l'accès et les permissions sur un système Windows. Ces trois cmdlets forment le trio indispensable pour gérer l'appartenance aux groupes : ajouter, retirer et lister les membres.

> [!info] Pourquoi c'est important
> 
> - Contrôle précis des permissions par groupe
> - Automatisation des processus d'onboarding/offboarding
> - Audit et conformité de sécurité
> - Gestion centralisée des accès

---

## ➕ Add-LocalGroupMember

### 📖 Concept

`Add-LocalGroupMember` permet d'ajouter un ou plusieurs utilisateurs ou groupes à un groupe local existant. C'est l'outil privilégié pour attribuer des permissions via l'appartenance à un groupe.

### 🎯 Cas d'usage

- Attribution de droits administratifs à un nouvel utilisateur
- Ajout d'utilisateurs de domaine à des groupes locaux
- Imbrication de groupes (ajouter un groupe dans un autre)
- Scripts d'automatisation d'onboarding
- Gestion temporaire de permissions

### 📝 Syntaxe de base

```powershell
Add-LocalGroupMember -Group "NomDuGroupe" -Member "NomUtilisateur"
```

### 🔧 Paramètres principaux

|Paramètre|Description|Type accepté|
|---|---|---|
|`-Group`|Groupe cible où ajouter le membre|Nom ou SID|
|`-Member`|Membre(s) à ajouter|Nom, SID, objet|
|`-Confirm`|Demande confirmation avant l'action|Switch|
|`-WhatIf`|Simule l'action sans l'exécuter|Switch|

### 💡 Types de membres supportés

Le paramètre `-Member` accepte plusieurs formats :

```powershell
# Par nom d'utilisateur local
Add-LocalGroupMember -Group "Administrateurs" -Member "JeanDupont"

# Par SID (Security Identifier)
Add-LocalGroupMember -Group "Administrateurs" -Member "S-1-5-21-xxx"

# Utilisateur de domaine (format DOMAINE\Utilisateur)
Add-LocalGroupMember -Group "Utilisateurs" -Member "ENTREPRISE\marie.martin"

# Groupe de domaine dans un groupe local
Add-LocalGroupMember -Group "Administrateurs" -Member "ENTREPRISE\AdminsIT"

# Autre groupe local (imbrication)
Add-LocalGroupMember -Group "GroupeParent" -Member "GroupeEnfant"
```

### 📦 Ajout de multiples membres

```powershell
# Plusieurs membres en une seule commande
Add-LocalGroupMember -Group "Utilisateurs" -Member "user1","user2","user3"

# Depuis un tableau
$nouveauxUtilisateurs = @("alice", "bob", "charlie")
Add-LocalGroupMember -Group "Utilisateurs" -Member $nouveauxUtilisateurs

# Depuis un fichier CSV
$users = Import-Csv "nouveaux_users.csv"
foreach ($user in $users) {
    Add-LocalGroupMember -Group "Utilisateurs" -Member $user.Username
}
```

> [!tip] Astuce : Vérification préalable Avant d'ajouter, vérifiez si le membre existe déjà pour éviter les erreurs :
> 
> ```powershell
> if (-not (Get-LocalGroupMember -Group "Administrateurs" -Member "JeanDupont" -ErrorAction SilentlyContinue)) {
>     Add-LocalGroupMember -Group "Administrateurs" -Member "JeanDupont"
> }
> ```

### ⚠️ Gestion des erreurs courantes

```powershell
# Avec gestion d'erreur
try {
    Add-LocalGroupMember -Group "Administrateurs" -Member "NewUser" -ErrorAction Stop
    Write-Host "✅ Membre ajouté avec succès" -ForegroundColor Green
}
catch {
    if ($_.Exception.Message -like "*already a member*") {
        Write-Host "⚠️ L'utilisateur est déjà membre du groupe" -ForegroundColor Yellow
    }
    else {
        Write-Host "❌ Erreur : $($_.Exception.Message)" -ForegroundColor Red
    }
}
```

> [!warning] Pièges courants
> 
> - Le membre doit exister avant l'ajout (utilisateur ou groupe)
> - Erreur si le membre est déjà dans le groupe
> - Droits administrateur requis pour modifier les groupes système
> - La casse n'est pas sensible pour les noms Windows

### 🔐 Bonnes pratiques

```powershell
# Avec confirmation pour les groupes sensibles
Add-LocalGroupMember -Group "Administrateurs" -Member "NewAdmin" -Confirm

# Documentation de l'ajout
$logEntry = @{
    Date = Get-Date
    Action = "Add"
    Group = "Administrateurs"
    Member = "NewAdmin"
    ExecutedBy = $env:USERNAME
}
$logEntry | Export-Csv "GroupChanges.csv" -Append -NoTypeInformation
```

---

## ➖ Remove-LocalGroupMember

### 📖 Concept

`Remove-LocalGroupMember` retire un ou plusieurs membres d'un groupe local. Essentiel pour la révocation de permissions et les processus d'offboarding.

### 🎯 Cas d'usage

- Retrait des droits d'un employé quittant l'entreprise
- Révocation temporaire de permissions
- Nettoyage de groupes après une réorganisation
- Scripts d'offboarding automatisés
- Correction d'erreurs d'attribution

### 📝 Syntaxe de base

```powershell
Remove-LocalGroupMember -Group "NomDuGroupe" -Member "NomUtilisateur"
```

### 🔧 Paramètres principaux

Les paramètres sont identiques à `Add-LocalGroupMember` :

|Paramètre|Description|Type accepté|
|---|---|---|
|`-Group`|Groupe cible d'où retirer le membre|Nom ou SID|
|`-Member`|Membre(s) à retirer|Nom, SID, objet|
|`-Confirm`|Demande confirmation avant l'action|Switch|
|`-WhatIf`|Simule l'action sans l'exécuter|Switch|

### 💡 Exemples de retrait

```powershell
# Retrait d'un utilisateur local
Remove-LocalGroupMember -Group "Administrateurs" -Member "AncienAdmin"

# Retrait d'un utilisateur de domaine
Remove-LocalGroupMember -Group "Utilisateurs" -Member "ENTREPRISE\ancien.employe"

# Retrait avec confirmation
Remove-LocalGroupMember -Group "Administrateurs" -Member "UserTest" -Confirm

# Simulation (test sans exécution)
Remove-LocalGroupMember -Group "Administrateurs" -Member "UserTest" -WhatIf
```

### 📦 Retrait de multiples membres

```powershell
# Plusieurs membres simultanément
Remove-LocalGroupMember -Group "Utilisateurs" -Member "user1","user2","user3"

# Depuis une liste
$anciensEmployes = @("alice", "bob", "charlie")
foreach ($user in $anciensEmployes) {
    Remove-LocalGroupMember -Group "Utilisateurs" -Member $user -ErrorAction SilentlyContinue
}

# Retrait de tous les membres d'un groupe
$membres = Get-LocalGroupMember -Group "TempGroup"
foreach ($membre in $membres) {
    Remove-LocalGroupMember -Group "TempGroup" -Member $membre.Name
}
```

> [!tip] Astuce : Vérification avant retrait
> 
> ```powershell
> if (Get-LocalGroupMember -Group "Administrateurs" -Member "User" -ErrorAction SilentlyContinue) {
>     Remove-LocalGroupMember -Group "Administrateurs" -Member "User"
>     Write-Host "✅ Membre retiré" -ForegroundColor Green
> } else {
>     Write-Host "ℹ️ Le membre n'est pas dans le groupe" -ForegroundColor Cyan
> }
> ```

### ⚠️ Gestion sécurisée des retraits

```powershell
# Script d'offboarding avec vérifications
function Remove-UserFromAllGroups {
    param([string]$Username)
    
    $groupes = Get-LocalGroup
    foreach ($groupe in $groupes) {
        try {
            $isMember = Get-LocalGroupMember -Group $groupe.Name -Member $Username -ErrorAction SilentlyContinue
            if ($isMember) {
                Remove-LocalGroupMember -Group $groupe.Name -Member $Username
                Write-Host "✅ Retiré de : $($groupe.Name)" -ForegroundColor Green
            }
        }
        catch {
            Write-Host "⚠️ Impossible de traiter : $($groupe.Name)" -ForegroundColor Yellow
        }
    }
}
```

> [!warning] Attention aux retraits critiques
> 
> - Ne jamais retirer le dernier administrateur du groupe Administrateurs
> - Confirmer avant de retirer des comptes système
> - Tester avec `-WhatIf` pour les opérations massives
> - Documenter tous les retraits pour l'audit

### 🔐 Script d'offboarding complet

```powershell
# Processus d'offboarding sécurisé
$employeeToRemove = "ancien.employe"
$groupesToCheck = @("Administrateurs", "Utilisateurs du Bureau à distance", "Utilisateurs")

Write-Host "`n🔍 Audit avant retrait :" -ForegroundColor Cyan
foreach ($group in $groupesToCheck) {
    $isMember = Get-LocalGroupMember -Group $group -Member $employeeToRemove -ErrorAction SilentlyContinue
    if ($isMember) {
        Write-Host "  ✓ Membre de : $group" -ForegroundColor Yellow
    }
}

Write-Host "`n🗑️ Retrait en cours :" -ForegroundColor Cyan
foreach ($group in $groupesToCheck) {
    try {
        Remove-LocalGroupMember -Group $group -Member $employeeToRemove -ErrorAction Stop
        Write-Host "  ✅ Retiré de : $group" -ForegroundColor Green
    }
    catch {
        Write-Host "  ℹ️ N'était pas dans : $group" -ForegroundColor Gray
    }
}
```

---

## 🔍 Get-LocalGroupMember

### 📖 Concept

`Get-LocalGroupMember` liste tous les membres d'un groupe local spécifique. C'est l'outil d'audit indispensable pour vérifier les appartenances et contrôler les permissions.

### 🎯 Cas d'usage

- Audit de sécurité régulier
- Vérification des permissions avant/après modifications
- Génération de rapports de conformité
- Identification des membres de domaine vs locaux
- Documentation des accès

### 📝 Syntaxe de base

```powershell
Get-LocalGroupMember -Group "NomDuGroupe"
```

### 🔧 Paramètres principaux

|Paramètre|Description|Utilisation|
|---|---|---|
|`-Group`|Groupe à inspecter|Obligatoire (nom ou SID)|
|`-Member`|Filtre sur un membre spécifique|Optionnel, pour vérification|
|`-Name`|Alias de `-Group`|Alternative|

### 📊 Propriétés des membres retournés

Chaque membre retourné contient :

|Propriété|Description|Exemple|
|---|---|---|
|`Name`|Nom complet du membre|`ORDINATEUR\JeanDupont` ou `DOMAINE\User`|
|`SID`|Security Identifier unique|`S-1-5-21-xxx-xxx-xxx-1001`|
|`PrincipalSource`|Origine du compte|`Local`, `ActiveDirectory`, `MicrosoftAccount`|
|`ObjectClass`|Type d'objet|`User`, `Group`|

### 💡 Exemples d'utilisation

```powershell
# Liste simple des membres
Get-LocalGroupMember -Group "Administrateurs"

# Affichage formaté
Get-LocalGroupMember -Group "Administrateurs" | Format-Table Name, ObjectClass, PrincipalSource

# Export vers CSV pour audit
Get-LocalGroupMember -Group "Administrateurs" | Export-Csv "Admins_Audit.csv" -NoTypeInformation

# Compte du nombre de membres
(Get-LocalGroupMember -Group "Utilisateurs").Count
```

### 🔎 Filtrage et recherche

```powershell
# Vérifier si un utilisateur spécifique est membre
Get-LocalGroupMember -Group "Administrateurs" -Member "JeanDupont"

# Filtrer uniquement les utilisateurs (pas les groupes)
Get-LocalGroupMember -Group "Administrateurs" | Where-Object {$_.ObjectClass -eq "User"}

# Filtrer uniquement les membres de domaine
Get-LocalGroupMember -Group "Administrateurs" | Where-Object {$_.PrincipalSource -eq "ActiveDirectory"}

# Filtrer uniquement les comptes locaux
Get-LocalGroupMember -Group "Administrateurs" | Where-Object {$_.PrincipalSource -eq "Local"}
```

> [!example] Identification membres domaine vs locaux
> 
> ```powershell
> $membres = Get-LocalGroupMember -Group "Administrateurs"
> 
> Write-Host "`n📋 Analyse du groupe Administrateurs :" -ForegroundColor Cyan
> Write-Host "👤 Comptes locaux :" -ForegroundColor Green
> $membres | Where-Object {$_.PrincipalSource -eq "Local"} | ForEach-Object { Write-Host "  - $($_.Name)" }
> 
> Write-Host "`n🌐 Comptes de domaine :" -ForegroundColor Yellow
> $membres | Where-Object {$_.PrincipalSource -eq "ActiveDirectory"} | ForEach-Object { Write-Host "  - $($_.Name)" }
> ```

### 📈 Audit multi-groupes

```powershell
# Audit de tous les groupes système importants
$groupesImportants = @("Administrateurs", "Utilisateurs", "Utilisateurs du Bureau à distance", "Invités")

foreach ($groupe in $groupesImportants) {
    Write-Host "`n📊 Groupe : $groupe" -ForegroundColor Cyan
    $membres = Get-LocalGroupMember -Group $groupe -ErrorAction SilentlyContinue
    
    if ($membres) {
        $membres | Format-Table Name, ObjectClass, PrincipalSource -AutoSize
        Write-Host "Total : $($membres.Count) membre(s)" -ForegroundColor Gray
    } else {
        Write-Host "  Aucun membre" -ForegroundColor Gray
    }
}
```

### 🔐 Rapport de sécurité complet

```powershell
# Génération d'un rapport d'audit détaillé
$rapport = @()

$groupes = Get-LocalGroup
foreach ($groupe in $groupes) {
    $membres = Get-LocalGroupMember -Group $groupe.Name -ErrorAction SilentlyContinue
    
    foreach ($membre in $membres) {
        $rapport += [PSCustomObject]@{
            Date = Get-Date -Format "yyyy-MM-dd HH:mm"
            Groupe = $groupe.Name
            Membre = $membre.Name
            Type = $membre.ObjectClass
            Source = $membre.PrincipalSource
            SID = $membre.SID
        }
    }
}

$rapport | Export-Csv "Audit_Groupes_$(Get-Date -Format 'yyyyMMdd').csv" -NoTypeInformation
Write-Host "✅ Rapport généré : $($rapport.Count) entrées" -ForegroundColor Green
```

> [!tip] Astuce : Détection d'anomalies
> 
> ```powershell
> # Alerte si un utilisateur local est administrateur (potentiel risque)
> $adminLocaux = Get-LocalGroupMember -Group "Administrateurs" | 
>     Where-Object {$_.PrincipalSource -eq "Local" -and $_.Name -notlike "*\Administrateur"}
> 
> if ($adminLocaux) {
>     Write-Host "⚠️ ALERTE : Comptes locaux non-standard détectés dans Administrateurs :" -ForegroundColor Red
>     $adminLocaux | ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor Yellow }
> }
> ```

### 🔄 Comparaison temporelle

```powershell
# Comparer l'état actuel avec un audit précédent
$auditActuel = Get-LocalGroupMember -Group "Administrateurs" | Select-Object -ExpandProperty Name
$auditPrecedent = Import-Csv "Admins_Audit_Precedent.csv" | Select-Object -ExpandProperty Name

# Nouveaux membres
$nouveaux = $auditActuel | Where-Object {$_ -notin $auditPrecedent}
# Membres retirés
$retires = $auditPrecedent | Where-Object {$_ -notin $auditActuel}

if ($nouveaux) {
    Write-Host "➕ Nouveaux membres :" -ForegroundColor Green
    $nouveaux | ForEach-Object { Write-Host "  - $_" }
}

if ($retires) {
    Write-Host "➖ Membres retirés :" -ForegroundColor Red
    $retires | ForEach-Object { Write-Host "  - $_" }
}
```

---

## 📊 Comparaison des cmdlets

### Tableau récapitulatif

|Cmdlet|Action|Quand l'utiliser|Paramètre clé|
|---|---|---|---|
|`Add-LocalGroupMember`|Ajoute membre(s)|Onboarding, attribution de droits|`-Member` (accepte plusieurs valeurs)|
|`Remove-LocalGroupMember`|Retire membre(s)|Offboarding, révocation de droits|`-Confirm` (recommandé)|
|`Get-LocalGroupMember`|Liste membres|Audit, vérification, rapports|Aucun filtre par défaut|

### 🔄 Workflow typique

```powershell
# 1. Vérifier l'état actuel (Get)
Get-LocalGroupMember -Group "Administrateurs"

# 2. Ajouter un nouveau membre (Add)
Add-LocalGroupMember -Group "Administrateurs" -Member "NewAdmin" -Confirm

# 3. Vérifier l'ajout (Get)
Get-LocalGroupMember -Group "Administrateurs" -Member "NewAdmin"

# 4. Plus tard : Retrait si nécessaire (Remove)
Remove-LocalGroupMember -Group "Administrateurs" -Member "NewAdmin" -Confirm

# 5. Vérification finale (Get)
Get-LocalGroupMember -Group "Administrateurs"
```

> [!tip] Bonnes pratiques globales
> 
> - Toujours utiliser `Get-LocalGroupMember` avant et après les modifications
> - Activer `-Confirm` pour les groupes sensibles (Administrateurs)
> - Utiliser `-WhatIf` pour tester les scripts avant exécution réelle
> - Logger toutes les modifications pour l'audit
> - Vérifier `PrincipalSource` pour distinguer local/domaine
> - Gérer les erreurs avec `try/catch` ou `-ErrorAction`

---

> [!info] 📝 Points clés à retenir
> 
> - **Add-LocalGroupMember** : Ajoute des membres, supporte multiple membres et différents types (local, domaine, groupes)
> - **Remove-LocalGroupMember** : Retire des membres, utiliser `-Confirm` pour sécurité
> - **Get-LocalGroupMember** : Audite les membres, distingue local/domaine via `PrincipalSource`
> - Toujours vérifier l'appartenance avec `Get` avant `Add` ou `Remove`
> - Ces cmdlets nécessitent des privilèges administrateur
> - Idéales pour automatiser onboarding/offboarding et génération de rapports de conformité