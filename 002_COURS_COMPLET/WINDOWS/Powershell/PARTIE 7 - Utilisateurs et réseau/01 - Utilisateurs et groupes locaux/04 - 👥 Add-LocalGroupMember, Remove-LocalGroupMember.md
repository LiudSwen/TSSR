

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

## Add-LocalGroupMember

### 🎯 Vue d'ensemble

`Add-LocalGroupMember` permet d'ajouter des utilisateurs ou des groupes comme membres d'un groupe local Windows. Cette cmdlet est essentielle pour la gestion des permissions et l'attribution de droits d'accès sur un système.

> [!info] Pourquoi c'est important L'ajout de membres à des groupes permet de gérer efficacement les permissions sans avoir à les attribuer individuellement à chaque utilisateur. C'est la base de la gestion par rôles (RBAC) au niveau système.

### 📖 Syntaxe de base

```powershell
Add-LocalGroupMember -Group <String> -Member <String[]> [-Confirm] [-WhatIf]
```

### 🔑 Paramètres principaux

|Paramètre|Description|Obligatoire|
|---|---|---|
|`-Group`|Nom du groupe cible où ajouter les membres|✅ Oui|
|`-Member`|Utilisateur(s) ou groupe(s) à ajouter|✅ Oui|
|`-Confirm`|Demande confirmation avant l'exécution|❌ Non|
|`-WhatIf`|Simule l'action sans l'exécuter|❌ Non|

### 💡 Concepts clés

#### Types de membres acceptés

Le paramètre `-Member` accepte plusieurs formats d'identification :

```powershell
# Par nom d'utilisateur local
Add-LocalGroupMember -Group "Administrateurs" -Member "JeanDupont"

# Par nom de compte domaine
Add-LocalGroupMember -Group "Utilisateurs du Bureau à distance" -Member "DOMAINE\MarieMartin"

# Par SID (Security Identifier)
Add-LocalGroupMember -Group "Administrateurs" -Member "S-1-5-21-1234567890-1234567890-1234567890-1001"

# Ajout d'un autre groupe (imbrication)
Add-LocalGroupMember -Group "Administrateurs" -Member "DOMAINE\Groupe-IT"
```

> [!tip] Astuce : SID vs Nom Utiliser le SID est plus fiable que le nom, car les noms peuvent changer mais les SID restent constants. Le SID est particulièrement utile dans les scripts automatisés.

#### Ajout de multiples membres

Vous pouvez ajouter plusieurs membres en une seule commande :

```powershell
# Syntaxe avec tableau
Add-LocalGroupMember -Group "Utilisateurs" -Member "User1", "User2", "User3"

# Syntaxe avec variable
$nouveauxMembres = @("Alice", "Bob", "Charlie")
Add-LocalGroupMember -Group "Développeurs" -Member $nouveauxMembres

# Depuis un fichier CSV
$utilisateurs = Import-Csv "C:\users.csv"
foreach ($user in $utilisateurs) {
    Add-LocalGroupMember -Group "Utilisateurs" -Member $user.Username
}
```

### ✅ Cas d'usage pratiques

#### 1. Script d'onboarding

```powershell
# Ajout d'un nouvel employé aux groupes appropriés
$nouvelEmploye = "DOMAINE\nouveauuser"

Add-LocalGroupMember -Group "Utilisateurs" -Member $nouvelEmploye
Add-LocalGroupMember -Group "Utilisateurs du Bureau à distance" -Member $nouvelEmploye

Write-Host "Utilisateur $nouvelEmploye ajouté aux groupes requis" -ForegroundColor Green
```

#### 2. Gestion des permissions par groupe

```powershell
# Création d'un groupe de gestion de serveur
Add-LocalGroupMember -Group "Administrateurs" -Member "DOMAINE\Groupe-Admins-Serveur"

# Ajout d'utilisateurs spécifiques pour accès RDP
$utilisateursRDP = @("DOMAINE\user1", "DOMAINE\user2")
Add-LocalGroupMember -Group "Utilisateurs du Bureau à distance" -Member $utilisateursRDP
```

#### 3. Vérification avant ajout

```powershell
# Éviter les erreurs en vérifiant l'appartenance existante
$groupe = "Administrateurs"
$membre = "JeanDupont"

$appartenance = Get-LocalGroupMember -Group $groupe -ErrorAction SilentlyContinue | 
                Where-Object { $_.Name -like "*$membre*" }

if (-not $appartenance) {
    Add-LocalGroupMember -Group $groupe -Member $membre
    Write-Host "$membre ajouté au groupe $groupe"
} else {
    Write-Host "$membre est déjà membre du groupe $groupe"
}
```

### ⚠️ Pièges courants

> [!warning] Attention : Appartenance existante Si vous essayez d'ajouter un membre qui existe déjà, PowerShell génère une erreur. Utilisez toujours une vérification préalable ou `-ErrorAction SilentlyContinue` dans les scripts.

```powershell
# Mauvais : Provoquera une erreur si le membre existe
Add-LocalGroupMember -Group "Administrateurs" -Member "UserExistant"

# Bon : Gestion de l'erreur
Add-LocalGroupMember -Group "Administrateurs" -Member "UserExistant" -ErrorAction SilentlyContinue
```

> [!warning] Format du nom de compte Pour les comptes de domaine, utilisez toujours le format `DOMAINE\Utilisateur` ou `utilisateur@domaine.com`. Le format incorrect provoquera une erreur.

### 🎯 Bonnes pratiques

1. **Utiliser `-Confirm` pour les opérations critiques**

```powershell
Add-LocalGroupMember -Group "Administrateurs" -Member "NouvelAdmin" -Confirm
```

2. **Journaliser les modifications**

```powershell
$logPath = "C:\Logs\GroupChanges.log"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

Add-LocalGroupMember -Group "Administrateurs" -Member "NewUser"
Add-Content -Path $logPath -Value "$timestamp - Ajout de NewUser au groupe Administrateurs"
```

3. **Utiliser des variables pour la réutilisabilité**

```powershell
$groupeCible = "Utilisateurs du Bureau à distance"
$nouveauxUtilisateurs = @("User1", "User2", "User3")

foreach ($user in $nouveauxUtilisateurs) {
    Add-LocalGroupMember -Group $groupeCible -Member $user
}
```

---

## Remove-LocalGroupMember

### 🎯 Vue d'ensemble

`Remove-LocalGroupMember` retire des utilisateurs ou groupes d'un groupe local Windows. Cette cmdlet est l'inverse de `Add-LocalGroupMember` et est essentielle pour la révocation de permissions et les processus d'offboarding.

> [!info] Pourquoi c'est important Le retrait rapide et précis des membres d'un groupe est crucial pour la sécurité. Lors du départ d'un employé ou d'un changement de fonction, il faut pouvoir révoquer immédiatement les accès sensibles.

### 📖 Syntaxe de base

```powershell
Remove-LocalGroupMember -Group <String> -Member <String[]> [-Confirm] [-WhatIf]
```

### 🔑 Paramètres principaux

|Paramètre|Description|Obligatoire|
|---|---|---|
|`-Group`|Nom du groupe dont retirer les membres|✅ Oui|
|`-Member`|Utilisateur(s) ou groupe(s) à retirer|✅ Oui|
|`-Confirm`|Demande confirmation avant l'exécution|❌ Non|
|`-WhatIf`|Simule l'action sans l'exécuter|❌ Non|

### 💡 Utilisation pratique

#### Retrait simple

```powershell
# Retirer un utilisateur local
Remove-LocalGroupMember -Group "Administrateurs" -Member "JeanDupont"

# Retirer un utilisateur de domaine
Remove-LocalGroupMember -Group "Utilisateurs du Bureau à distance" -Member "DOMAINE\MarieMartin"

# Retirer par SID
Remove-LocalGroupMember -Group "Administrateurs" -Member "S-1-5-21-1234567890-1234567890-1234567890-1001"
```

#### Retrait de multiples membres

```powershell
# Retrait de plusieurs membres en une fois
Remove-LocalGroupMember -Group "Développeurs" -Member "User1", "User2", "User3"

# Retrait depuis une liste
$anciensEmployes = @("DOMAINE\AncienUser1", "DOMAINE\AncienUser2")
Remove-LocalGroupMember -Group "Administrateurs" -Member $anciensEmployes
```

### ✅ Cas d'usage pratiques

#### 1. Script d'offboarding

```powershell
# Retrait complet d'un employé sortant de tous les groupes sensibles
$employeSortant = "DOMAINE\departing_user"

$groupesSensibles = @(
    "Administrateurs",
    "Utilisateurs du Bureau à distance",
    "Opérateurs de sauvegarde",
    "Utilisateurs avec pouvoir"
)

foreach ($groupe in $groupesSensibles) {
    try {
        Remove-LocalGroupMember -Group $groupe -Member $employeSortant -ErrorAction Stop
        Write-Host "✓ Retiré de $groupe" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ Non membre de $groupe ou erreur" -ForegroundColor Yellow
    }
}

Write-Host "`nOffboarding terminé pour $employeSortant" -ForegroundColor Cyan
```

#### 2. Révocation d'accès temporaire

```powershell
# Retirer les accès temporaires accordés pour un projet
$utilisateursTemporaires = Import-Csv "C:\temp_access.csv"

foreach ($user in $utilisateursTemporaires) {
    if ($user.EndDate -lt (Get-Date)) {
        Remove-LocalGroupMember -Group $user.GroupName -Member $user.Username
        Write-Host "Accès temporaire révoqué pour $($user.Username)"
    }
}
```

#### 3. Audit et nettoyage

```powershell
# Retirer les comptes désactivés du groupe Administrateurs
$membresAdmins = Get-LocalGroupMember -Group "Administrateurs"

foreach ($membre in $membresAdmins) {
    # Vérifier si le compte existe et est actif
    $compte = Get-LocalUser -Name $membre.Name.Split('\')[-1] -ErrorAction SilentlyContinue
    
    if ($compte -and -not $compte.Enabled) {
        Remove-LocalGroupMember -Group "Administrateurs" -Member $membre.Name
        Write-Host "Compte désactivé retiré : $($membre.Name)" -ForegroundColor Yellow
    }
}
```

### ⚠️ Pièges courants

> [!warning] Attention : Membre non existant Tenter de retirer un membre qui n'appartient pas au groupe génère une erreur. Vérifiez toujours l'appartenance avant ou gérez l'erreur.

```powershell
# Mauvais : Provoquera une erreur si le membre n'existe pas
Remove-LocalGroupMember -Group "Administrateurs" -Member "UserInexistant"

# Bon : Vérification préalable
$membre = Get-LocalGroupMember -Group "Administrateurs" | 
          Where-Object { $_.Name -like "*UserCible*" }

if ($membre) {
    Remove-LocalGroupMember -Group "Administrateurs" -Member $membre.Name
} else {
    Write-Host "Le membre n'appartient pas au groupe"
}
```

> [!warning] Ne pas retirer le dernier administrateur Windows vous empêchera de retirer le dernier compte administrateur du groupe Administrateurs pour des raisons de sécurité. Assurez-vous toujours qu'au moins un compte administrateur reste actif.

### 🎯 Bonnes pratiques

1. **Toujours utiliser `-Confirm` pour les groupes critiques**

```powershell
Remove-LocalGroupMember -Group "Administrateurs" -Member "UserCritique" -Confirm
```

2. **Utiliser `-WhatIf` pour tester**

```powershell
# Voir ce qui serait retiré sans l'exécuter
Remove-LocalGroupMember -Group "Administrateurs" -Member "TestUser" -WhatIf
```

3. **Journaliser les retraits pour l'audit**

```powershell
$logPath = "C:\Logs\GroupRemovals.log"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$membre = "UserRetiré"
$groupe = "Administrateurs"

Remove-LocalGroupMember -Group $groupe -Member $membre
Add-Content -Path $logPath -Value "$timestamp - Retrait de $membre du groupe $groupe"
```

4. **Créer une fonction réutilisable**

```powershell
function Remove-UserFromAllGroups {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Username
    )
    
    $groupes = Get-LocalGroup
    
    foreach ($groupe in $groupes) {
        $membres = Get-LocalGroupMember -Group $groupe.Name -ErrorAction SilentlyContinue
        
        if ($membres.Name -contains $Username) {
            Remove-LocalGroupMember -Group $groupe.Name -Member $Username
            Write-Host "Retiré de : $($groupe.Name)"
        }
    }
}

# Utilisation
Remove-UserFromAllGroups -Username "DOMAINE\employé_sortant"
```

---

## Get-LocalGroupMember

### 🎯 Vue d'ensemble

`Get-LocalGroupMember` liste tous les membres d'un groupe local spécifique. Cette cmdlet est essentielle pour l'audit, la vérification des permissions et les rapports de sécurité.

> [!info] Pourquoi c'est important Connaître qui appartient à quels groupes est fondamental pour la sécurité. Cette cmdlet permet d'auditer régulièrement les appartenances, de détecter les comptes indésirables et de documenter les permissions.

### 📖 Syntaxe de base

```powershell
Get-LocalGroupMember -Group <String> [-Member <String>]
```

### 🔑 Paramètres principaux

|Paramètre|Description|Obligatoire|
|---|---|---|
|`-Group`|Nom du groupe à interroger|✅ Oui|
|`-Member`|Filtre sur un membre spécifique|❌ Non|

### 💡 Propriétés retournées

Chaque membre retourné contient plusieurs propriétés importantes :

```powershell
Get-LocalGroupMember -Group "Administrateurs" | Select-Object *
```

|Propriété|Description|Exemple|
|---|---|---|
|`Name`|Nom complet du membre|`MACHINE\Utilisateur` ou `DOMAINE\User`|
|`SID`|Security Identifier unique|`S-1-5-21-...`|
|`PrincipalSource`|Origine du principal (Local, ActiveDirectory, etc.)|`Local`, `ActiveDirectory`|
|`ObjectClass`|Type d'objet (User ou Group)|`User`, `Group`|

### ✅ Cas d'usage pratiques

#### 1. Liste simple des membres

```powershell
# Lister tous les membres d'un groupe
Get-LocalGroupMember -Group "Administrateurs"

# Affichage formaté
Get-LocalGroupMember -Group "Administrateurs" | 
    Format-Table Name, ObjectClass, PrincipalSource -AutoSize

# Export vers CSV
Get-LocalGroupMember -Group "Administrateurs" | 
    Export-Csv "C:\Rapports\Admins.csv" -NoTypeInformation
```

#### 2. Identification des membres domaine vs locaux

```powershell
# Séparer les membres locaux et de domaine
$membres = Get-LocalGroupMember -Group "Administrateurs"

$membresLocaux = $membres | Where-Object { $_.PrincipalSource -eq "Local" }
$membresDomaine = $membres | Where-Object { $_.PrincipalSource -eq "ActiveDirectory" }

Write-Host "=== Membres locaux ===" -ForegroundColor Cyan
$membresLocaux | Format-Table Name, ObjectClass

Write-Host "`n=== Membres du domaine ===" -ForegroundColor Green
$membresDomaine | Format-Table Name, ObjectClass
```

#### 3. Vérification d'appartenance spécifique

```powershell
# Vérifier si un utilisateur est membre d'un groupe
$utilisateur = "JeanDupont"
$groupe = "Administrateurs"

$estMembre = Get-LocalGroupMember -Group $groupe | 
             Where-Object { $_.Name -like "*$utilisateur*" }

if ($estMembre) {
    Write-Host "$utilisateur est membre du groupe $groupe" -ForegroundColor Green
} else {
    Write-Host "$utilisateur n'est PAS membre du groupe $groupe" -ForegroundColor Yellow
}
```

#### 4. Audit de sécurité complet

```powershell
# Audit de tous les groupes sensibles
$groupesSensibles = @(
    "Administrateurs",
    "Utilisateurs du Bureau à distance",
    "Opérateurs de sauvegarde",
    "Utilisateurs avec pouvoir"
)

$rapport = @()

foreach ($groupe in $groupesSensibles) {
    $membres = Get-LocalGroupMember -Group $groupe -ErrorAction SilentlyContinue
    
    foreach ($membre in $membres) {
        $rapport += [PSCustomObject]@{
            Groupe = $groupe
            Membre = $membre.Name
            Type = $membre.ObjectClass
            Source = $membre.PrincipalSource
            SID = $membre.SID
            DateAudit = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }
    }
}

# Affichage et export
$rapport | Format-Table -AutoSize
$rapport | Export-Csv "C:\Rapports\AuditGroupes_$(Get-Date -Format 'yyyyMMdd').csv" -NoTypeInformation

Write-Host "`nRapport d'audit généré avec succès" -ForegroundColor Green
```

#### 5. Détection de comptes imbriqués

```powershell
# Identifier les groupes membres d'autres groupes (imbrication)
$groupesImbriQués = Get-LocalGroupMember -Group "Administrateurs" | 
                    Where-Object { $_.ObjectClass -eq "Group" }

if ($groupesImbriQués) {
    Write-Host "⚠ Groupes imbriqués détectés dans Administrateurs :" -ForegroundColor Yellow
    $groupesImbriQués | Format-Table Name, PrincipalSource
    
    # Lister les membres des groupes imbriqués
    foreach ($groupe in $groupesImbriQués) {
        Write-Host "`nMembres du groupe imbriqué : $($groupe.Name)" -ForegroundColor Cyan
        # Note : Cette opération nécessiterait Get-ADGroupMember pour les groupes de domaine
    }
}
```

#### 6. Rapport comparatif dans le temps

```powershell
# Comparer l'appartenance actuelle avec un fichier de référence
$fichierReference = "C:\Rapports\Admins_Baseline.csv"
$membresActuels = Get-LocalGroupMember -Group "Administrateurs"

if (Test-Path $fichierReference) {
    $baseline = Import-Csv $fichierReference
    
    # Nouveaux membres
    $nouveaux = $membresActuels | Where-Object { 
        $_.SID.Value -notin $baseline.SID 
    }
    
    # Membres retirés
    $retirés = $baseline | Where-Object { 
        $_.SID -notin $membresActuels.SID.Value 
    }
    
    if ($nouveaux) {
        Write-Host "✓ Nouveaux membres détectés :" -ForegroundColor Green
        $nouveaux | Format-Table Name, PrincipalSource
    }
    
    if ($retirés) {
        Write-Host "✗ Membres retirés depuis la baseline :" -ForegroundColor Red
        $retirés | Format-Table Name, PrincipalSource
    }
} else {
    # Créer la baseline
    $membresActuels | Select-Object Name, @{N='SID';E={$_.SID.Value}}, PrincipalSource, ObjectClass |
        Export-Csv $fichierReference -NoTypeInformation
    Write-Host "Baseline créée : $fichierReference"
}
```

### 🎯 Bonnes pratiques

1. **Filtrer intelligemment**

```powershell
# Filtrer par type
Get-LocalGroupMember -Group "Administrateurs" | 
    Where-Object { $_.ObjectClass -eq "User" }

# Filtrer par source
Get-LocalGroupMember -Group "Administrateurs" | 
    Where-Object { $_.PrincipalSource -eq "ActiveDirectory" }
```

2. **Gérer les erreurs pour les groupes inexistants**

```powershell
$groupe = "GroupeInexistant"
$membres = Get-LocalGroupMember -Group $groupe -ErrorAction SilentlyContinue

if ($membres) {
    $membres | Format-Table
} else {
    Write-Host "Le groupe '$groupe' n'existe pas ou est vide" -ForegroundColor Yellow
}
```

3. **Créer des fonctions d'audit réutilisables**

```powershell
function Get-GroupMembershipReport {
    param(
        [string[]]$Groupes = @("Administrateurs", "Utilisateurs"),
        [string]$ExportPath
    )
    
    $rapport = foreach ($groupe in $Groupes) {
        Get-LocalGroupMember -Group $groupe -ErrorAction SilentlyContinue | 
            Select-Object @{N='Groupe';E={$groupe}}, Name, ObjectClass, PrincipalSource, 
                          @{N='SID';E={$_.SID.Value}}
    }
    
    if ($ExportPath) {
        $rapport | Export-Csv $ExportPath -NoTypeInformation
        Write-Host "Rapport exporté : $ExportPath"
    }
    
    return $rapport
}

# Utilisation
Get-GroupMembershipReport -Groupes "Administrateurs", "Utilisateurs du Bureau à distance" -ExportPath "C:\audit.csv"
```

> [!tip] Astuce : Automatisation avec tâches planifiées Créez une tâche planifiée qui exécute un script d'audit quotidien avec `Get-LocalGroupMember`. Cela permet de détecter rapidement toute modification non autorisée des appartenances aux groupes sensibles.

### ⚠️ Considérations importantes

> [!warning] Groupes vides `Get-LocalGroupMember` ne retourne rien pour un groupe vide et ne génère pas d'erreur. Utilisez `Get-LocalGroup` pour vérifier l'existence du groupe d'abord.

```powershell
# Vérification robuste
$groupe = "MonGroupe"

if (Get-LocalGroup -Name $groupe -ErrorAction SilentlyContinue) {
    $membres = Get-LocalGroupMember -Group $groupe
    if ($membres) {
        Write-Host "Le groupe contient $($membres.Count) membre(s)"
    } else {
        Write-Host "Le groupe existe mais est vide"
    }
} else {
    Write-Host "Le groupe n'existe pas"
}
```

---

## 🔗 Combinaison des trois cmdlets

### Workflow complet de gestion

```powershell
# 1. Audit initial
Write-Host "=== AUDIT INITIAL ===" -ForegroundColor Cyan
$membresInitiaux = Get-LocalGroupMember -Group "Administrateurs"
$membresInitiaux | Format-Table Name, ObjectClass, PrincipalSource

# 2. Ajout de nouveaux membres
Write-Host "`n=== AJOUT DE MEMBRES ===" -ForegroundColor Green
Add-LocalGroupMember -Group "Administrateurs" -Member "NouvelAdmin" -Confirm

# 3. Vérification post-ajout
Write-Host "`n=== VÉRIFICATION ===" -ForegroundColor Yellow
Get-LocalGroupMember -Group "Administrateurs" | Where-Object { $_.Name -like "*NouvelAdmin*" }

# 4. Retrait après période de test
Write-Host "`n=== RETRAIT ===" -ForegroundColor Red
Remove-LocalGroupMember -Group "Administrateurs" -Member "NouvelAdmin" -Confirm

# 5. Audit final
Write-Host "`n=== AUDIT FINAL ===" -ForegroundColor Cyan
Get-LocalGroupMember -Group "Administrateurs" | Format-Table
```

---

> [!tip] 💡 Astuce finale Combinez ces trois cmdlets dans des scripts d'automatisation pour créer des workflows complets de gestion des groupes : onboarding automatique, révocations planifiées, audits réguliers et rapports de conformité.