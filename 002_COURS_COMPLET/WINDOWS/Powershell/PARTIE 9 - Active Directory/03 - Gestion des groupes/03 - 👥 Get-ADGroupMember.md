

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

## 🎯 Introduction

`Get-ADGroupMember` est une cmdlet essentielle pour gérer et auditer les appartenances aux groupes Active Directory. Elle permet de lister tous les membres d'un groupe, qu'ils soient des utilisateurs, des ordinateurs ou d'autres groupes.

> [!info] Pourquoi utiliser Get-ADGroupMember ?
> 
> - **Audit de sécurité** : Vérifier qui a accès à quelles ressources
> - **Documentation** : Maintenir une vue à jour des appartenances
> - **Conformité** : Générer des rapports pour les audits
> - **Troubleshooting** : Diagnostiquer les problèmes de permissions
> - **Nettoyage** : Identifier les membres obsolètes ou inappropriés

---

## 📝 Syntaxe de base

```powershell
Get-ADGroupMember -Identity <String> [-Recursive] [-Server <String>]
```

**Exemple simple :**

```powershell
# Lister les membres d'un groupe
Get-ADGroupMember -Identity "Domain Admins"
```

> [!example] Résultat typique
> 
> ```
> distinguishedName : CN=Administrator,CN=Users,DC=contoso,DC=com
> name              : Administrator
> objectClass       : user
> objectGUID        : a1b2c3d4-e5f6-7890-abcd-ef1234567890
> SamAccountName    : Administrator
> SID               : S-1-5-21-...
> ```

---

## 🎯 Le paramètre -Identity

Le paramètre `-Identity` spécifie le groupe à interroger. Il accepte plusieurs formats :

```powershell
# Par nom (SamAccountName)
Get-ADGroupMember -Identity "IT_Support"

# Par Distinguished Name (DN)
Get-ADGroupMember -Identity "CN=IT Support,OU=Groups,DC=contoso,DC=com"

# Par GUID
Get-ADGroupMember -Identity "a1b2c3d4-e5f6-7890-abcd-ef1234567890"

# Par SID
Get-ADGroupMember -Identity "S-1-5-21-1234567890-1234567890-1234567890-1234"
```

> [!tip] Astuce : Utilisation de variables
> 
> ```powershell
> $groupe = "IT_Support"
> Get-ADGroupMember -Identity $groupe
> ```

---

## 🔄 Membres récursifs avec -Recursive

Le paramètre `-Recursive` est crucial pour obtenir une vision complète de tous les membres, y compris ceux appartenant à des sous-groupes.

### Sans -Recursive (membres directs uniquement)

```powershell
Get-ADGroupMember -Identity "IT_Department"

# Résultat : 
# - Groupe IT_Support
# - Groupe IT_Admin
# - User JohnDoe
```

### Avec -Recursive (tous les membres)

```powershell
Get-ADGroupMember -Identity "IT_Department" -Recursive

# Résultat :
# - User JohnDoe (membre direct)
# - User JaneSmith (membre de IT_Support)
# - User BobMartin (membre de IT_Support)
# - User AliceCooper (membre de IT_Admin)
# - User CharlieBlack (membre de IT_Admin)
```

> [!warning] Important Avec `-Recursive`, les groupes imbriqués n'apparaissent PAS dans la liste finale. Seuls les objets "feuilles" (users, computers) sont retournés.

**Comparaison visuelle :**

```powershell
# Sans -Recursive : On voit la structure
Get-ADGroupMember -Identity "IT_Department" | Select-Object Name, ObjectClass

# Avec -Recursive : On voit tous les utilisateurs finaux
Get-ADGroupMember -Identity "IT_Department" -Recursive | Select-Object Name, ObjectClass
```

---

## 📊 Propriétés retournées

Par défaut, `Get-ADGroupMember` retourne un ensemble limité de propriétés :

|Propriété|Description|Exemple|
|---|---|---|
|**Name**|Nom d'affichage|"John Doe"|
|**SamAccountName**|Nom de compte logon|"jdoe"|
|**DistinguishedName**|Chemin complet dans AD|"CN=John Doe,OU=Users,DC=contoso,DC=com"|
|**ObjectClass**|Type d'objet|user, group, computer|
|**ObjectGUID**|Identifiant unique|a1b2c3d4-...|
|**SID**|Security Identifier|S-1-5-21-...|

### Filtrer par type d'objet

```powershell
# Uniquement les utilisateurs
Get-ADGroupMember -Identity "IT_Department" | 
    Where-Object {$_.ObjectClass -eq "user"}

# Uniquement les groupes imbriqués
Get-ADGroupMember -Identity "IT_Department" | 
    Where-Object {$_.ObjectClass -eq "group"}

# Uniquement les ordinateurs
Get-ADGroupMember -Identity "IT_Department" | 
    Where-Object {$_.ObjectClass -eq "computer"}
```

### Obtenir plus de détails

```powershell
# Pipeline vers Get-ADUser pour plus d'informations
Get-ADGroupMember -Identity "IT_Department" | 
    Where-Object {$_.ObjectClass -eq "user"} |
    ForEach-Object {
        Get-ADUser $_ -Properties EmailAddress, Department, Title
    }
```

> [!tip] Optimisation Récupérer les détails pour chaque membre peut être lent. Utilisez uniquement les propriétés nécessaires.

---

## ⚖️ Différence membres directs vs récursifs

### Tableau comparatif

|Critère|Membres directs|Membres récursifs|
|---|---|---|
|**Commande**|`Get-ADGroupMember -Identity "Groupe"`|`Get-ADGroupMember -Identity "Groupe" -Recursive`|
|**Inclut les sous-groupes**|Oui (objets group)|Non (uniquement users/computers)|
|**Profondeur**|1 niveau|Tous les niveaux|
|**Performance**|Rapide|Plus lent|
|**Cas d'usage**|Structure de groupes|Liste exhaustive d'utilisateurs|

### Exemple pratique : Hiérarchie de groupes

```powershell
# Structure :
# IT_Global
#   ├─ IT_France
#   │   ├─ User: Pierre
#   │   └─ User: Marie
#   └─ IT_USA
#       ├─ User: John
#       └─ User: Sarah

# Membres directs
Get-ADGroupMember -Identity "IT_Global"
# Résultat : IT_France (group), IT_USA (group)

# Membres récursifs
Get-ADGroupMember -Identity "IT_Global" -Recursive
# Résultat : Pierre (user), Marie (user), John (user), Sarah (user)
```

### Combiner les deux approches

```powershell
# Pour voir la structure complète avec détails
$groupe = "IT_Global"

# Membres directs
Write-Host "=== Membres directs ===" -ForegroundColor Cyan
Get-ADGroupMember -Identity $groupe | 
    Select-Object Name, ObjectClass | 
    Format-Table -AutoSize

# Tous les utilisateurs (récursif)
Write-Host "`n=== Tous les utilisateurs ===" -ForegroundColor Cyan
Get-ADGroupMember -Identity $groupe -Recursive | 
    Select-Object Name, SamAccountName | 
    Format-Table -AutoSize
```

---

## 💾 Export de listes de membres

### Export CSV simple

```powershell
# Export basique
Get-ADGroupMember -Identity "IT_Department" | 
    Select-Object Name, SamAccountName, ObjectClass |
    Export-Csv -Path "C:\Exports\IT_Members.csv" -NoTypeInformation -Encoding UTF8
```

### Export avec détails utilisateurs

```powershell
# Export enrichi avec informations utilisateur
Get-ADGroupMember -Identity "IT_Department" -Recursive |
    Where-Object {$_.ObjectClass -eq "user"} |
    ForEach-Object {
        Get-ADUser $_ -Properties EmailAddress, Department, Title, Enabled
    } |
    Select-Object Name, SamAccountName, EmailAddress, Department, Title, Enabled |
    Export-Csv -Path "C:\Exports\IT_Members_Detailed.csv" -NoTypeInformation -Encoding UTF8
```

### Export multi-groupes

```powershell
# Exporter plusieurs groupes dans un seul fichier
$groupes = @("IT_Department", "HR_Department", "Finance_Department")
$results = @()

foreach ($groupe in $groupes) {
    $membres = Get-ADGroupMember -Identity $groupe -Recursive |
        Where-Object {$_.ObjectClass -eq "user"} |
        Select-Object @{Name="Groupe";Expression={$groupe}}, Name, SamAccountName
    
    $results += $membres
}

$results | Export-Csv -Path "C:\Exports\All_Departments.csv" -NoTypeInformation -Encoding UTF8
```

### Export Excel avec formatage

```powershell
# Nécessite le module ImportExcel (Install-Module ImportExcel)
Get-ADGroupMember -Identity "IT_Department" -Recursive |
    Where-Object {$_.ObjectClass -eq "user"} |
    Select-Object Name, SamAccountName, DistinguishedName |
    Export-Excel -Path "C:\Exports\IT_Members.xlsx" -AutoSize -TableName "Members" -WorksheetName "IT Department"
```

---

## 🔍 Audit d'appartenance

### Vérifier si un utilisateur est membre

```powershell
# Méthode 1 : Vérification simple
$utilisateur = "jdoe"
$groupe = "IT_Department"

$isMember = Get-ADGroupMember -Identity $groupe -Recursive | 
    Where-Object {$_.SamAccountName -eq $utilisateur}

if ($isMember) {
    Write-Host "$utilisateur est membre de $groupe" -ForegroundColor Green
} else {
    Write-Host "$utilisateur n'est PAS membre de $groupe" -ForegroundColor Red
}
```

### Audit de multiples utilisateurs

```powershell
# Vérifier une liste d'utilisateurs
$utilisateurs = @("jdoe", "jsmith", "bmartin")
$groupe = "Domain Admins"

$membres = Get-ADGroupMember -Identity $groupe -Recursive

foreach ($user in $utilisateurs) {
    $isMember = $membres | Where-Object {$_.SamAccountName -eq $user}
    
    [PSCustomObject]@{
        Utilisateur = $user
        Membre = if ($isMember) {"Oui"} else {"Non"}
        Type = if ($isMember) {$isMember.ObjectClass} else {"N/A"}
    }
} | Format-Table -AutoSize
```

### Identifier les membres orphelins

```powershell
# Trouver les membres dont le compte utilisateur n'existe plus
$groupe = "IT_Department"
$membres = Get-ADGroupMember -Identity $groupe

foreach ($membre in $membres) {
    try {
        if ($membre.ObjectClass -eq "user") {
            $user = Get-ADUser -Identity $membre.SamAccountName -ErrorAction Stop
        }
    } catch {
        Write-Warning "Membre orphelin détecté : $($membre.Name) ($($membre.SamAccountName))"
    }
}
```

---

## 🛡️ Rapports de sécurité

### Audit des groupes privilégiés

```powershell
# Groupes à surveiller
$groupesPrivilegies = @(
    "Domain Admins",
    "Enterprise Admins",
    "Schema Admins",
    "Account Operators",
    "Backup Operators"
)

$rapport = foreach ($groupe in $groupesPrivilegies) {
    $membres = Get-ADGroupMember -Identity $groupe -Recursive -ErrorAction SilentlyContinue
    
    foreach ($membre in $membres) {
        [PSCustomObject]@{
            Groupe = $groupe
            Membre = $membre.Name
            SamAccountName = $membre.SamAccountName
            Type = $membre.ObjectClass
            DateAudit = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }
    }
}

# Exporter le rapport
$rapport | Export-Csv -Path "C:\Audits\Privileged_Groups_$(Get-Date -Format 'yyyyMMdd').csv" -NoTypeInformation -Encoding UTF8

# Afficher un résumé
$rapport | Group-Object Groupe | Select-Object Name, Count | Format-Table -AutoSize
```

### Détection de comptes inactifs dans des groupes sensibles

```powershell
# Trouver les comptes désactivés ou inactifs dans un groupe
$groupe = "Domain Admins"
$joursInactivite = 90

Get-ADGroupMember -Identity $groupe -Recursive |
    Where-Object {$_.ObjectClass -eq "user"} |
    ForEach-Object {
        $user = Get-ADUser $_ -Properties Enabled, LastLogonDate, PasswordLastSet
        
        [PSCustomObject]@{
            Nom = $user.Name
            SamAccountName = $user.SamAccountName
            Actif = $user.Enabled
            DerniereConnexion = $user.LastLogonDate
            MotDePasseChange = $user.PasswordLastSet
            Alerte = if (-not $user.Enabled) {
                "DESACTIVE"
            } elseif ($user.LastLogonDate -lt (Get-Date).AddDays(-$joursInactivite)) {
                "INACTIF >$joursInactivite jours"
            } else {
                "OK"
            }
        }
    } |
    Where-Object {$_.Alerte -ne "OK"} |
    Format-Table -AutoSize
```

### Rapport hebdomadaire automatisé

```powershell
# Script à planifier avec Task Scheduler
$groupes = @("Domain Admins", "IT_Department", "Finance_Admins")
$destinataire = "admin@contoso.com"
$rapportHTML = @"
<html>
<head>
    <style>
        table { border-collapse: collapse; width: 100%; }
        th { background-color: #4CAF50; color: white; padding: 8px; }
        td { border: 1px solid #ddd; padding: 8px; }
        tr:nth-child(even) { background-color: #f2f2f2; }
    </style>
</head>
<body>
    <h2>Rapport d'appartenance aux groupes - $(Get-Date -Format 'dd/MM/yyyy')</h2>
"@

foreach ($groupe in $groupes) {
    $membres = Get-ADGroupMember -Identity $groupe -Recursive
    $rapportHTML += "<h3>$groupe ($($membres.Count) membres)</h3>"
    $rapportHTML += "<table><tr><th>Nom</th><th>SamAccountName</th><th>Type</th></tr>"
    
    foreach ($membre in $membres) {
        $rapportHTML += "<tr><td>$($membre.Name)</td><td>$($membre.SamAccountName)</td><td>$($membre.ObjectClass)</td></tr>"
    }
    
    $rapportHTML += "</table><br>"
}

$rapportHTML += "</body></html>"

# Envoyer par email (nécessite configuration SMTP)
Send-MailMessage -To $destinataire -From "powershell@contoso.com" `
    -Subject "Rapport hebdomadaire - Groupes AD" `
    -Body $rapportHTML -BodyAsHtml `
    -SmtpServer "smtp.contoso.com"
```

---

## ✅ Vérification de permissions

### Vérifier les accès à un partage réseau

```powershell
# Identifier qui a accès via un groupe de sécurité
$groupePartage = "Finance_Share_ReadWrite"
$chemin = "\\server\finance"

Write-Host "=== Utilisateurs ayant accès à $chemin ===" -ForegroundColor Cyan

Get-ADGroupMember -Identity $groupePartage -Recursive |
    Where-Object {$_.ObjectClass -eq "user"} |
    ForEach-Object {
        Get-ADUser $_ -Properties EmailAddress, Department
    } |
    Select-Object Name, SamAccountName, EmailAddress, Department |
    Sort-Object Name |
    Format-Table -AutoSize
```

### Matrice d'accès multi-ressources

```powershell
# Créer une matrice d'accès pour plusieurs ressources
$ressources = @{
    "Finance_Share" = "Finance_Share_ReadWrite"
    "HR_Share" = "HR_Share_Admins"
    "IT_Share" = "IT_Department"
}

$utilisateurs = Get-ADUser -Filter * -SearchBase "OU=Users,DC=contoso,DC=com"
$matrice = @()

foreach ($user in $utilisateurs) {
    $ligne = [PSCustomObject]@{
        Utilisateur = $user.SamAccountName
        Nom = $user.Name
    }
    
    foreach ($ressource in $ressources.GetEnumerator()) {
        $membres = Get-ADGroupMember -Identity $ressource.Value -Recursive
        $acces = if ($membres.SamAccountName -contains $user.SamAccountName) {"X"} else {""}
        $ligne | Add-Member -NotePropertyName $ressource.Key -NotePropertyValue $acces
    }
    
    $matrice += $ligne
}

$matrice | Format-Table -AutoSize
```

### Audit d'accès temporaire

```powershell
# Identifier les membres ajoutés récemment (nécessite audit AD activé)
# Cette approche utilise Get-ADReplicationAttributeMetadata
$groupe = "Temporary_Access"
$joursRecents = 7

$membres = Get-ADGroupMember -Identity $groupe

foreach ($membre in $membres) {
    # Note : Cette cmdlet nécessite des permissions élevées
    $metadata = Get-ADReplicationAttributeMetadata -Object $membre.DistinguishedName -Server (Get-ADDomain).PDCEmulator
    $whenCreated = ($metadata | Where-Object {$_.AttributeName -eq "whenCreated"}).LastOriginatingChangeTime
    
    if ($whenCreated -ge (Get-Date).AddDays(-$joursRecents)) {
        [PSCustomObject]@{
            Membre = $membre.Name
            Type = $membre.ObjectClass
            DateAjout = $whenCreated
            Anciennete = ((Get-Date) - $whenCreated).Days
        }
    }
} | Format-Table -AutoSize
```

---

## 🔗 Gestion des groupes imbriqués complexes

### Visualiser la hiérarchie complète

```powershell
function Get-GroupHierarchy {
    param(
        [string]$GroupName,
        [int]$Level = 0
    )
    
    $indent = "  " * $Level
    $membres = Get-ADGroupMember -Identity $GroupName
    
    foreach ($membre in $membres) {
        Write-Host "$indent└─ $($membre.Name) [$($membre.ObjectClass)]"
        
        if ($membre.ObjectClass -eq "group") {
            Get-GroupHierarchy -GroupName $membre.SamAccountName -Level ($Level + 1)
        }
    }
}

# Utilisation
Write-Host "IT_Global [group]" -ForegroundColor Cyan
Get-GroupHierarchy -GroupName "IT_Global"
```

### Identifier les boucles de groupes (circular nesting)

```powershell
function Test-CircularGroupMembership {
    param(
        [string]$GroupName,
        [System.Collections.ArrayList]$Visited = (New-Object System.Collections.ArrayList)
    )
    
    if ($Visited -contains $GroupName) {
        Write-Warning "BOUCLE DETECTEE : $GroupName est déjà dans la hiérarchie !"
        return $true
    }
    
    $Visited.Add($GroupName) | Out-Null
    $membres = Get-ADGroupMember -Identity $GroupName
    
    foreach ($membre in $membres) {
        if ($membre.ObjectClass -eq "group") {
            $hasLoop = Test-CircularGroupMembership -GroupName $membre.SamAccountName -Visited $Visited
            if ($hasLoop) { return $true }
        }
    }
    
    return $false
}

# Tester un groupe
Test-CircularGroupMembership -GroupName "IT_Department"
```

### Cartographier tous les chemins d'appartenance

```powershell
function Get-MembershipPath {
    param(
        [string]$UserName,
        [string]$TargetGroup
    )
    
    function Find-Path {
        param($CurrentGroup, $Path)
        
        $membres = Get-ADGroupMember -Identity $CurrentGroup
        
        foreach ($membre in $membres) {
            $newPath = $Path + @($CurrentGroup)
            
            if ($membre.SamAccountName -eq $UserName) {
                Write-Host "Chemin trouvé : $($newPath -join ' -> ') -> $UserName" -ForegroundColor Green
                return
            }
            
            if ($membre.ObjectClass -eq "group") {
                Find-Path -CurrentGroup $membre.SamAccountName -Path $newPath
            }
        }
    }
    
    Find-Path -CurrentGroup $TargetGroup -Path @()
}

# Trouver tous les chemins
Get-MembershipPath -UserName "jdoe" -TargetGroup "IT_Global"
```

### Compter la profondeur de nesting

```powershell
function Get-GroupNestingDepth {
    param(
        [string]$GroupName,
        [int]$CurrentDepth = 0
    )
    
    $membres = Get-ADGroupMember -Identity $GroupName
    $sousGroupes = $membres | Where-Object {$_.ObjectClass -eq "group"}
    
    if ($sousGroupes.Count -eq 0) {
        return $CurrentDepth
    }
    
    $maxDepth = $CurrentDepth
    foreach ($groupe in $sousGroupes) {
        $depth = Get-GroupNestingDepth -GroupName $groupe.SamAccountName -CurrentDepth ($CurrentDepth + 1)
        if ($depth -gt $maxDepth) {
            $maxDepth = $depth
        }
    }
    
    return $maxDepth
}

# Vérifier la profondeur
$profondeur = Get-GroupNestingDepth -GroupName "IT_Global"
Write-Host "Profondeur maximale de nesting : $profondeur niveaux"

if ($profondeur -gt 3) {
    Write-Warning "La profondeur dépasse 3 niveaux - Considérer une simplification"
}
```

---

## ⚡ Considérations de performance

### Impact de -Recursive sur les gros groupes

> [!warning] Attention aux performances Sur des groupes avec des milliers de membres et plusieurs niveaux de nesting, `-Recursive` peut prendre plusieurs minutes et générer une charge importante sur les contrôleurs de domaine.

**Mesurer le temps d'exécution :**

```powershell
# Mesurer sans -Recursive
Measure-Command {
    Get-ADGroupMember -Identity "Large_Group"
} | Select-Object TotalSeconds

# Mesurer avec -Recursive
Measure-Command {
    Get-ADGroupMember -Identity "Large_Group" -Recursive
} | Select-Object TotalSeconds
```

### Optimisations pour les gros environnements

**1. Utiliser un serveur DC spécifique**

```powershell
# Cibler un DC spécifique pour répartir la charge
Get-ADGroupMember -Identity "Large_Group" -Server "DC01.contoso.com"
```

**2. Filtrer tôt dans le pipeline**

```powershell
# MAUVAIS : Tout récupérer puis filtrer
$membres = Get-ADGroupMember -Identity "Large_Group" -Recursive
$users = $membres | Where-Object {$_.ObjectClass -eq "user"}

# MEILLEUR : Filtrer immédiatement
$users = Get-ADGroupMember -Identity "Large_Group" -Recursive | 
    Where-Object {$_.ObjectClass -eq "user"}
```

**3. Utiliser des jobs parallèles pour plusieurs groupes**

```powershell
# Traiter plusieurs groupes en parallèle
$groupes = @("Group1", "Group2", "Group3", "Group4", "Group5")

$jobs = foreach ($groupe in $groupes) {
    Start-Job -ScriptBlock {
        param($g)
        Get-ADGroupMember -Identity $g -Recursive
    } -ArgumentList $groupe
}

# Attendre et récupérer les résultats
$results = $jobs | Wait-Job | Receive-Job
$jobs | Remove-Job
```

**4. Mise en cache pour requêtes multiples**

```powershell
# Si vous devez interroger le même groupe plusieurs fois
$cache = @{}

function Get-CachedGroupMembers {
    param([string]$GroupName)
    
    if (-not $cache.ContainsKey($GroupName)) {
        Write-Host "Chargement de $GroupName..." -ForegroundColor Yellow
        $cache[$GroupName] = Get-ADGroupMember -Identity $GroupName -Recursive
    }
    
    return $cache[$GroupName]
}

# Utilisation
$membres1 = Get-CachedGroupMembers -GroupName "IT_Department"  # Chargement
$membres2 = Get-CachedGroupMembers -GroupName "IT_Department"  # Depuis cache
```

### Alternatives pour de très gros groupes

```powershell
# Approche alternative : Utiliser LDAP directement pour plus de contrôle
$searcher = New-Object DirectoryServices.DirectorySearcher
$searcher.Filter = "(&(objectClass=group)(cn=Large_Group))"
$searcher.PropertiesToLoad.Add("member") | Out-Null
$group = $searcher.FindOne()

$memberCount = $group.Properties.member.Count
Write-Host "Nombre de membres directs : $memberCount"

# Traiter par lots
$batchSize = 100
for ($i = 0; $i -lt $memberCount; $i += $batchSize) {
    $batch = $group.Properties.member[$i..([Math]::Min($i + $batchSize - 1, $memberCount - 1))]
    # Traiter ce lot
    Write-Host "Traitement du lot $([Math]::Floor($i / $batchSize) + 1)..."
}
```

---

## ⚠️ Pièges courants

### 1. Confusion entre membres directs et récursifs

```powershell
# PIEGE : Oublier -Recursive et manquer des membres
$membres = Get-ADGroupMember -Identity "IT_Global"
# On voit seulement IT_France et IT_USA (groupes)

# CORRECT : Utiliser -Recursive pour avoir tous les utilisateurs
$tousLesMembres = Get-ADGroupMember -Identity "IT_Global" -Recursive
# On voit Pierre, Marie, John, Sarah (utilisateurs)
```

### 2. Groupes avec le même nom dans différentes OUs

```powershell
# PIEGE : Nom ambigu
Get-ADGroupMember -Identity "IT_Support"  # Quel IT_Support ?

# CORRECT : Utiliser le Distinguished Name
Get-ADGroupMember -Identity "CN=IT Support,OU=France,OU=Groups,DC=contoso,DC=com"
```

### 3. Gestion des erreurs

```powershell
# PIEGE : Ne pas gérer les groupes vides ou inexistants
Get-ADGroupMember -Identity "NonExistent_Group"  # Erreur !

# CORRECT : Toujours gérer les erreurs
try {
    $membres = Get-ADGroupMember -Identity "IT_Department" -ErrorAction Stop
    if ($membres) {
        Write-Host "Trouvé $($membres.Count) membres"
    } else {
        Write-Host "Groupe vide"
    }
} catch {
    Write-Warning "Impossible de récupérer les membres : $_"
}
```

### 4. Objets supprimés (tombstone)

```powershell
# PIEGE : Des membres peuvent apparaître mais ne plus exister
$membres = Get-ADGroupMember -Identity "Old_Group"

foreach ($membre in $membres) {
    try {
        $user = Get-ADUser -Identity $membre.SamAccountName -ErrorAction Stop
    } catch {
        Write-Warning "Membre introuvable : $($membre.Name) - Probablement supprimé"
    }
}
```

### 5. Performance sur les domaines étendus

```powershell
# PIEGE : Requête lente sur plusieurs sites AD
Get-ADGroupMember -Identity "Global_Group" -Recursive  # Peut prendre 10+ minutes !

# MEILLEUR : Cibler le bon DC
$dc = (Get-ADDomainController -Discover -Service PrimaryDC).HostName
Get-ADGroupMember -Identity "Global_Group" -Recursive -Server $dc
```

### 6. Codage des caractères dans les exports

```powershell
# PIEGE : Caractères spéciaux mal encodés
Get-ADGroupMember -Identity "RH_France" | 
    Export-Csv -Path "membres.csv"  # Accents corrompus !

# CORRECT : Toujours spécifier UTF8
Get-ADGroupMember -Identity "RH_France" | 
    Select-Object Name, SamAccountName |
    Export-Csv -Path "membres.csv" -NoTypeInformation -Encoding UTF8
```

### 7. Limitation du pipeline

```powershell
# PIEGE : Get-ADGroupMember ne retourne pas toutes les propriétés
Get-ADGroupMember -Identity "IT_Department" | 
    Select-Object Name, EmailAddress  # EmailAddress est $null !

# CORRECT : Pipeline vers Get-ADUser pour plus de propriétés
Get-ADGroupMember -Identity "IT_Department" |
    Where-Object {$_.ObjectClass -eq "user"} |
    ForEach-Object {
        Get-ADUser $_ -Properties EmailAddress
    } |
    Select-Object Name, EmailAddress
```

---

## ✨ Bonnes pratiques

### 1. Toujours spécifier -Identity de manière unique

```powershell
# BONNE PRATIQUE : Utiliser le Distinguished Name pour éviter l'ambiguïté
$groupeDN = "CN=IT Support,OU=Groups,DC=contoso,DC=com"
Get-ADGroupMember -Identity $groupeDN

# OU : Stocker dans une variable pour réutilisation
$groupe = Get-ADGroup -Filter "Name -eq 'IT Support'" -SearchBase "OU=Groups,DC=contoso,DC=com"
Get-ADGroupMember -Identity $groupe.DistinguishedName
```

### 2. Documenter les requêtes récursives

```powershell
# BONNE PRATIQUE : Commenter pourquoi on utilise -Recursive
# Récupération de TOUS les utilisateurs ayant accès au partage Finance
# Y compris ceux dans les sous-groupes IT_Finance_Admins et IT_Finance_Users
$membres = Get-ADGroupMember -Identity "Finance_Share_Access" -Recursive |
    Where-Object {$_.ObjectClass -eq "user"}
```

### 3. Implémenter une gestion d'erreurs robuste

```powershell
# BONNE PRATIQUE : Fonction wrapper avec gestion d'erreurs
function Get-SafeGroupMembers {
    param(
        [Parameter(Mandatory)]
        [string]$GroupName,
        [switch]$Recursive
    )
    
    try {
        $params = @{
            Identity = $GroupName
            ErrorAction = 'Stop'
        }
        
        if ($Recursive) { $params.Recursive = $true }
        
        $membres = Get-ADGroupMember @params
        
        if (-not $membres) {
            Write-Warning "Le groupe '$GroupName' est vide"
            return @()
        }
        
        return $membres
        
    } catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
        Write-Error "Le groupe '$GroupName' n'existe pas"
        return $null
    } catch {
        Write-Error "Erreur lors de la récupération des membres : $_"
        return $null
    }
}

# Utilisation
$membres = Get-SafeGroupMembers -GroupName "IT_Department" -Recursive
if ($membres) {
    Write-Host "Trouvé $($membres.Count) membres"
}
```

### 4. Utiliser des objets personnalisés pour les rapports

```powershell
# BONNE PRATIQUE : Créer des objets structurés
function Get-GroupMembershipReport {
    param([string]$GroupName)
    
    $membres = Get-ADGroupMember -Identity $GroupName -Recursive
    
    foreach ($membre in $membres) {
        $details = switch ($membre.ObjectClass) {
            'user' { 
                Get-ADUser $membre -Properties EmailAddress, Department, Title, Enabled
            }
            'computer' { 
                Get-ADComputer $membre -Properties OperatingSystem, LastLogonDate
            }
            default { $null }
        }
        
        [PSCustomObject]@{
            Groupe = $GroupName
            Nom = $membre.Name
            SamAccountName = $membre.SamAccountName
            Type = $membre.ObjectClass
            Email = if ($details) { $details.EmailAddress } else { "N/A" }
            Departement = if ($details) { $details.Department } else { "N/A" }
            Actif = if ($details) { $details.Enabled } else { "N/A" }
            DateAudit = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        }
    }
}

# Export propre et structuré
Get-GroupMembershipReport -GroupName "IT_Department" |
    Export-Csv -Path "C:\Reports\IT_Report.csv" -NoTypeInformation -Encoding UTF8
```

### 5. Planifier les audits réguliers

```powershell
# BONNE PRATIQUE : Script d'audit planifié
# À enregistrer comme tâche planifiée Windows

$config = @{
    GroupesToAudit = @("Domain Admins", "Enterprise Admins", "Schema Admins")
    ReportPath = "C:\Audits\AD_Groups"
    RetentionDays = 90
    EmailTo = "security@contoso.com"
}

# Créer le dossier de rapports
$reportDate = Get-Date -Format "yyyyMMdd_HHmmss"
$reportFolder = Join-Path $config.ReportPath $reportDate
New-Item -Path $reportFolder -ItemType Directory -Force | Out-Null

# Auditer chaque groupe
foreach ($groupe in $config.GroupesToAudit) {
    $membres = Get-ADGroupMember -Identity $groupe -Recursive -ErrorAction SilentlyContinue
    
    if ($membres) {
        $reportFile = Join-Path $reportFolder "$groupe.csv"
        $membres | 
            Select-Object Name, SamAccountName, ObjectClass, DistinguishedName |
            Export-Csv -Path $reportFile -NoTypeInformation -Encoding UTF8
    }
}

# Nettoyer les anciens rapports
$cutoffDate = (Get-Date).AddDays(-$config.RetentionDays)
Get-ChildItem -Path $config.ReportPath -Directory |
    Where-Object { $_.CreationTime -lt $cutoffDate } |
    Remove-Item -Recurse -Force

Write-Host "Audit terminé : $reportFolder" -ForegroundColor Green
```

### 6. Optimiser les requêtes multiples

```powershell
# BONNE PRATIQUE : Récupérer une seule fois, utiliser plusieurs fois
$groupes = @("IT_Department", "HR_Department", "Finance_Department")

# Mauvais : 3 requêtes AD
foreach ($groupe in $groupes) {
    $count = (Get-ADGroupMember -Identity $groupe).Count
    Write-Host "$groupe : $count membres"
}

# Meilleur : Stocker les résultats
$membersCache = @{}
foreach ($groupe in $groupes) {
    $membersCache[$groupe] = Get-ADGroupMember -Identity $groupe
}

# Utilisation multiple sans requêtes supplémentaires
foreach ($groupe in $groupes) {
    Write-Host "$groupe : $($membersCache[$groupe].Count) membres"
}

# Analyse croisée sans nouvelles requêtes
$tousLesMembres = $membersCache.Values | ForEach-Object { $_ } | 
    Select-Object -Unique SamAccountName
Write-Host "Total membres uniques : $($tousLesMembres.Count)"
```

### 7. Valider les résultats

```powershell
# BONNE PRATIQUE : Toujours valider les résultats critiques
function Get-ValidatedGroupMembers {
    param(
        [string]$GroupName,
        [switch]$Recursive
    )
    
    # Première récupération
    $membres1 = Get-ADGroupMember -Identity $GroupName -Recursive:$Recursive
    Start-Sleep -Seconds 2
    
    # Seconde récupération pour validation
    $membres2 = Get-ADGroupMember -Identity $GroupName -Recursive:$Recursive
    
    # Comparer
    $diff = Compare-Object -ReferenceObject $membres1.SamAccountName -DifferenceObject $membres2.SamAccountName
    
    if ($diff) {
        Write-Warning "Incohérence détectée dans les résultats du groupe '$GroupName' !"
        Write-Warning "Différences : $($diff | Out-String)"
    }
    
    return $membres1
}
```

### 8. Logger les opérations sensibles

```powershell
# BONNE PRATIQUE : Logger les accès aux groupes privilégiés
function Get-ADGroupMember-Logged {
    param(
        [string]$Identity,
        [switch]$Recursive
    )
    
    $logPath = "C:\Logs\AD_GroupAccess.log"
    $logEntry = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] " +
                "User: $env:USERNAME | " +
                "Computer: $env:COMPUTERNAME | " +
                "Group: $Identity | " +
                "Recursive: $Recursive"
    
    Add-Content -Path $logPath -Value $logEntry
    
    return Get-ADGroupMember -Identity $Identity -Recursive:$Recursive
}

# Utilisation
$admins = Get-ADGroupMember-Logged -Identity "Domain Admins" -Recursive
```

### 9. Créer des rapports comparatifs

```powershell
# BONNE PRATIQUE : Comparer les appartenances dans le temps
function Compare-GroupMembership {
    param(
        [string]$GroupName,
        [string]$PreviousReportPath
    )
    
    # Membres actuels
    $currentMembers = Get-ADGroupMember -Identity $GroupName -Recursive |
        Select-Object -ExpandProperty SamAccountName
    
    # Membres précédents
    $previousMembers = Import-Csv -Path $PreviousReportPath |
        Select-Object -ExpandProperty SamAccountName
    
    # Nouveaux membres
    $nouveaux = $currentMembers | Where-Object { $_ -notin $previousMembers }
    
    # Membres retirés
    $retires = $previousMembers | Where-Object { $_ -notin $currentMembers }
    
    # Rapport
    [PSCustomObject]@{
        Groupe = $GroupName
        DateComparaison = Get-Date
        NouveauxMembres = $nouveaux -join ", "
        MembresRetires = $retires -join ", "
        TotalActuel = $currentMembers.Count
        TotalPrecedent = $previousMembers.Count
        Changement = $currentMembers.Count - $previousMembers.Count
    }
}
```

### 10. Utiliser le splatting pour la lisibilité

```powershell
# BONNE PRATIQUE : Splatting pour les commandes complexes
$params = @{
    Identity = "CN=IT Department,OU=Groups,DC=contoso,DC=com"
    Recursive = $true
    Server = "DC01.contoso.com"
    ErrorAction = 'Stop'
}

try {
    $membres = Get-ADGroupMember @params
    Write-Host "Récupération réussie : $($membres.Count) membres" -ForegroundColor Green
} catch {
    Write-Error "Échec : $_"
}
```

---

## 📊 Exemples d'utilisation avancés

### Exemple 1 : Dashboard de groupes interactif

```powershell
# Créer un menu interactif pour explorer les groupes
function Show-GroupDashboard {
    param([string]$GroupName)
    
    Clear-Host
    Write-Host "╔════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║    DASHBOARD GROUPE ACTIVE DIRECTORY      ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host ""
    
    $membres = Get-ADGroupMember -Identity $GroupName -ErrorAction SilentlyContinue
    if (-not $membres) {
        Write-Host "Groupe introuvable ou vide !" -ForegroundColor Red
        return
    }
    
    $users = $membres | Where-Object {$_.ObjectClass -eq "user"}
    $groups = $membres | Where-Object {$_.ObjectClass -eq "group"}
    $computers = $membres | Where-Object {$_.ObjectClass -eq "computer"}
    
    Write-Host "Groupe : " -NoNewline; Write-Host $GroupName -ForegroundColor Yellow
    Write-Host "Membres totaux : " -NoNewline; Write-Host $membres.Count -ForegroundColor Green
    Write-Host ""
    
    Write-Host "  👤 Utilisateurs : " -NoNewline; Write-Host $users.Count -ForegroundColor Cyan
    Write-Host "  📁 Sous-groupes : " -NoNewline; Write-Host $groups.Count -ForegroundColor Magenta
    Write-Host "  💻 Ordinateurs : " -NoNewline; Write-Host $computers.Count -ForegroundColor Yellow
    Write-Host ""
    
    if ($groups.Count -gt 0) {
        Write-Host "Expansion récursive..." -ForegroundColor Gray
        $recursive = Get-ADGroupMember -Identity $GroupName -Recursive
        Write-Host "  🔄 Total récursif : " -NoNewline; Write-Host $recursive.Count -ForegroundColor Green
    }
}

# Utilisation
Show-GroupDashboard -GroupName "IT_Department"
```

### Exemple 2 : Nettoyer les groupes obsolètes

```powershell
# Identifier et reporter les membres inactifs
function Find-InactiveGroupMembers {
    param(
        [string]$GroupName,
        [int]$InactiveDays = 90
    )
    
    $cutoffDate = (Get-Date).AddDays(-$InactiveDays)
    $membres = Get-ADGroupMember -Identity $GroupName -Recursive |
        Where-Object {$_.ObjectClass -eq "user"}
    
    $inactifs = foreach ($membre in $membres) {
        $user = Get-ADUser $membre -Properties LastLogonDate, Enabled, PasswordLastSet
        
        $isInactive = (-not $user.Enabled) -or 
                      ($user.LastLogonDate -and $user.LastLogonDate -lt $cutoffDate)
        
        if ($isInactive) {
            [PSCustomObject]@{
                Nom = $user.Name
                SamAccountName = $user.SamAccountName
                Actif = $user.Enabled
                DerniereConnexion = $user.LastLogonDate
                MotDePasseChange = $user.PasswordLastSet
                Raison = if (-not $user.Enabled) {
                    "Compte désactivé"
                } else {
                    "Inactif depuis $((New-TimeSpan -Start $user.LastLogonDate -End (Get-Date)).Days) jours"
                }
            }
        }
    }
    
    if ($inactifs) {
        Write-Host "`n⚠️  $($inactifs.Count) membres inactifs trouvés dans '$GroupName' :" -ForegroundColor Yellow
        $inactifs | Format-Table -AutoSize
        
        # Option d'export
        $export = Read-Host "`nExporter vers CSV ? (O/N)"
        if ($export -eq 'O') {
            $path = "C:\Reports\Inactifs_$($GroupName)_$(Get-Date -Format 'yyyyMMdd').csv"
            $inactifs | Export-Csv -Path $path -NoTypeInformation -Encoding UTF8
            Write-Host "✅ Exporté vers : $path" -ForegroundColor Green
        }
    } else {
        Write-Host "✅ Aucun membre inactif détecté" -ForegroundColor Green
    }
}

# Utilisation
Find-InactiveGroupMembers -GroupName "IT_Department" -InactiveDays 90
```

### Exemple 3 : Matrice de conformité RBAC

```powershell
# Vérifier la conformité des rôles (Role-Based Access Control)
function Test-RBACCompliance {
    $roles = @{
        "Administrateurs" = @{
            GroupesAutorises = @("Domain Admins", "IT_Admins")
            GroupesInterdits = @("Standard_Users", "Guests")
        }
        "Finances" = @{
            GroupesAutorises = @("Finance_Users", "Finance_Admins")
            GroupesInterdits = @("IT_Department", "HR_Department")
        }
    }
    
    $violations = @()
    
    foreach ($role in $roles.GetEnumerator()) {
        Write-Host "Vérification du rôle : $($role.Key)" -ForegroundColor Cyan
        
        # Vérifier les groupes autorisés
        foreach ($groupe in $role.Value.GroupesAutorises) {
            $membres = Get-ADGroupMember -Identity $groupe -Recursive -ErrorAction SilentlyContinue
            
            foreach ($membre in $membres) {
                # Vérifier si le membre est aussi dans un groupe interdit
                foreach ($interdit in $role.Value.GroupesInterdits) {
                    $membresInterdits = Get-ADGroupMember -Identity $interdit -Recursive -ErrorAction SilentlyContinue
                    
                    if ($membresInterdits.SamAccountName -contains $membre.SamAccountName) {
                        $violations += [PSCustomObject]@{
                            Role = $role.Key
                            Utilisateur = $membre.Name
                            SamAccountName = $membre.SamAccountName
                            GroupeAutorise = $groupe
                            GroupeInterdit = $interdit
                            Severite = "CRITIQUE"
                        }
                    }
                }
            }
        }
    }
    
    if ($violations) {
        Write-Host "`n❌ $($violations.Count) violations RBAC détectées !" -ForegroundColor Red
        $violations | Format-Table -AutoSize
    } else {
        Write-Host "`n✅ Aucune violation RBAC détectée" -ForegroundColor Green
    }
    
    return $violations
}

# Exécution
$violations = Test-RBACCompliance
if ($violations) {
    $violations | Export-Csv -Path "C:\Audits\RBAC_Violations.csv" -NoTypeInformation -Encoding UTF8
}
```

---

## 🎓 Récapitulatif

`Get-ADGroupMember` est une cmdlet fondamentale pour :

✅ **Lister les membres** d'un groupe Active Directory  
✅ **Auditer les appartenances** pour la sécurité et la conformité  
✅ **Générer des rapports** sur les accès et permissions  
✅ **Identifier les problèmes** (comptes inactifs, groupes circulaires)  
✅ **Automatiser la gestion** des groupes et des accès

### Points clés à retenir

|Aspect|Point important|
|---|---|
|**-Identity**|Peut accepter Name, DN, GUID ou SID|
|**-Recursive**|Essentiel pour avoir TOUS les membres effectifs|
|**Performance**|Attention sur les gros groupes avec récursivité|
|**Propriétés**|Limitées par défaut, utiliser Get-ADUser/Computer pour plus|
|**Erreurs**|Toujours implémenter une gestion d'erreurs robuste|
|**Sécurité**|Logger les accès aux groupes privilégiés|
|**Audit**|Planifier des vérifications régulières|

### Syntaxe essentielle

```powershell
# Basique
Get-ADGroupMember -Identity "GroupName"

# Récursif (recommandé pour la plupart des cas)
Get-ADGroupMember -Identity "GroupName" -Recursive

# Avec détails utilisateurs
Get-ADGroupMember -Identity "GroupName" -Recursive |
    Where-Object {$_.ObjectClass -eq "user"} |
    ForEach-Object { Get-ADUser $_ -Properties EmailAddress, Department }

# Export sécurisé
Get-ADGroupMember -Identity "GroupName" -Recursive |
    Select-Object Name, SamAccountName, ObjectClass |
    Export-Csv -Path "membres.csv" -NoTypeInformation -Encoding UTF8
```

---

**💡 Astuce finale** : Créez une bibliothèque de fonctions réutilisables pour vos tâches courantes d'administration de groupes. Cela vous fera gagner un temps précieux et garantira la cohérence de vos opérations.

---

_Cours PowerShell Active Directory - Get-ADGroupMember_  
_Dernière mise à jour : Décembre 2025_