# 🔧 PowerShell Active Directory - Set-ADUser et Remove-ADUser

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

## 🔄 Set-ADUser - Modification d'utilisateurs

### Pourquoi Set-ADUser ?

`Set-ADUser` est la cmdlet centrale pour modifier les propriétés des comptes utilisateurs existants dans Active Directory. Elle permet de maintenir à jour les informations des utilisateurs, d'ajuster leurs paramètres de compte et de gérer des attributs personnalisés.

> [!info] Cas d'usage courants
> 
> - Mise à jour des informations de contact après un changement de poste
> - Modification des paramètres de sécurité (expiration de mot de passe, etc.)
> - Synchronisation d'attributs depuis un système RH externe
> - Gestion d'attributs personnalisés pour des applications métiers

---

### Identification de l'utilisateur

Le paramètre `-Identity` permet de cibler l'utilisateur à modifier. Il accepte plusieurs formats :

```powershell
# Par SamAccountName (le plus courant)
Set-ADUser -Identity jdoe

# Par Distinguished Name
Set-ADUser -Identity "CN=John Doe,OU=Users,DC=contoso,DC=com"

# Par GUID
Set-ADUser -Identity "a8b2c3d4-e5f6-7890-1234-567890abcdef"

# Par SID
Set-ADUser -Identity "S-1-5-21-..."

# Par UserPrincipalName
Set-ADUser -Identity "jdoe@contoso.com"
```

> [!tip] Bonne pratique Privilégiez le **SamAccountName** pour la lisibilité du code, sauf si vous travaillez avec des résultats de pipeline qui fournissent d'autres identifiants.

---

### Propriétés standard

`Set-ADUser` offre des paramètres dédiés pour les propriétés les plus courantes :

#### Informations personnelles

```powershell
# Modifier le prénom et le nom
Set-ADUser -Identity jdoe -GivenName "Jean" -Surname "Dupont"

# Mettre à jour le nom d'affichage
Set-ADUser -Identity jdoe -DisplayName "Jean Dupont"

# Modifier la description
Set-ADUser -Identity jdoe -Description "Développeur Senior - Équipe Infrastructure"
```

#### Informations professionnelles

```powershell
# Poste et département
Set-ADUser -Identity jdoe `
    -Title "Architecte Solutions" `
    -Department "IT" `
    -Company "Contoso Ltd"

# Bureau et téléphone
Set-ADUser -Identity jdoe `
    -Office "Paris - Bâtiment A" `
    -OfficePhone "+33 1 23 45 67 89"

# Email professionnel
Set-ADUser -Identity jdoe -EmailAddress "jean.dupont@contoso.com"

# Manager (utilise le Distinguished Name du manager)
Set-ADUser -Identity jdoe -Manager "CN=Marie Martin,OU=Managers,DC=contoso,DC=com"
```

> [!example] Exemple complet de mise à jour
> 
> ```powershell
> # Mise à jour complète lors d'un changement de poste
> Set-ADUser -Identity jdoe `
>     -Title "Chef de Projet" `
>     -Department "PMO" `
>     -Office "Lyon - Site Central" `
>     -OfficePhone "+33 4 12 34 56 78" `
>     -Manager "CN=Sophie Durand,OU=Managers,DC=contoso,DC=com" `
>     -Description "Chef de Projet - Transformation Digitale"
> ```

|Paramètre|Description|Exemple|
|---|---|---|
|`-GivenName`|Prénom|"Jean"|
|`-Surname`|Nom de famille|"Dupont"|
|`-DisplayName`|Nom d'affichage complet|"Jean Dupont"|
|`-EmailAddress`|Adresse email|"j.dupont@contoso.com"|
|`-Title`|Poste/fonction|"Développeur"|
|`-Department`|Département|"IT"|
|`-Manager`|Manager (DN)|"CN=Manager,OU=..."|
|`-Office`|Bureau|"Paris"|
|`-OfficePhone`|Téléphone|"+33123456789"|
|`-Description`|Description|"Équipe Dev"|

---

### Options de compte

Ces paramètres contrôlent le comportement et la sécurité du compte utilisateur :

#### Activation/Désactivation

```powershell
# Activer un compte
Set-ADUser -Identity jdoe -Enabled $true

# Désactiver un compte (départ, suspension)
Set-ADUser -Identity jdoe -Enabled $false
```

#### Gestion des mots de passe

```powershell
# Forcer le changement de mot de passe à la prochaine connexion
Set-ADUser -Identity jdoe -ChangePasswordAtLogon $true

# Le mot de passe n'expire jamais (comptes de service)
Set-ADUser -Identity jdoe -PasswordNeverExpires $true

# Permettre l'expiration normale du mot de passe
Set-ADUser -Identity jdoe -PasswordNeverExpires $false
```

#### Expiration du compte

```powershell
# Définir une date d'expiration (consultant temporaire)
Set-ADUser -Identity jdoe -AccountExpirationDate "2024-12-31"

# Supprimer la date d'expiration
Set-ADUser -Identity jdoe -AccountExpirationDate $null

# Expiration dans 90 jours
$expiration = (Get-Date).AddDays(90)
Set-ADUser -Identity jdoe -AccountExpirationDate $expiration
```

> [!warning] Attention aux comptes de service Ne définissez jamais `-PasswordNeverExpires $true` sur des comptes utilisateurs normaux. Réservez cette option aux comptes de service uniquement, et documentez-la systématiquement.

> [!example] Configuration complète d'un compte temporaire
> 
> ```powershell
> # Configuration d'un compte stagiaire avec expiration automatique
> Set-ADUser -Identity stagiaire01 `
>     -Enabled $true `
>     -ChangePasswordAtLogon $true `
>     -PasswordNeverExpires $false `
>     -AccountExpirationDate "2025-06-30" `
>     -Description "Stagiaire - Expire le 30/06/2025"
> ```

---

### Attributs étendus

Pour les propriétés qui ne disposent pas de paramètres dédiés, ou pour les attributs personnalisés, utilisez les opérateurs d'attributs étendus.

#### Les quatre opérateurs

|Opérateur|Action|Usage|
|---|---|---|
|`-Add`|Ajouter des valeurs|Attributs multi-valués|
|`-Remove`|Retirer des valeurs|Attributs multi-valués|
|`-Replace`|Remplacer complètement|Attributs mono ou multi-valués|
|`-Clear`|Vider l'attribut|Suppression totale|

#### Syntaxe avec hashtable

```powershell
# -Add : Ajouter une valeur à un attribut multi-valué
Set-ADUser -Identity jdoe -Add @{proxyAddresses="smtp:alias@contoso.com"}

# -Replace : Remplacer complètement la valeur
Set-ADUser -Identity jdoe -Replace @{extensionAttribute1="VIP-User"}

# -Remove : Retirer une valeur spécifique
Set-ADUser -Identity jdoe -Remove @{proxyAddresses="smtp:old@contoso.com"}

# -Clear : Vider complètement l'attribut
Set-ADUser -Identity jdoe -Clear extensionAttribute1
```

#### Modifications multiples simultanées

```powershell
# Modifier plusieurs attributs en une seule commande
Set-ADUser -Identity jdoe -Replace @{
    extensionAttribute1 = "Building-A"
    extensionAttribute2 = "Floor-3"
    extensionAttribute3 = "Department-IT"
}

# Combiner plusieurs opérateurs
Set-ADUser -Identity jdoe `
    -Add @{proxyAddresses="smtp:j.dupont@contoso.com"} `
    -Replace @{extensionAttribute1="Updated"} `
    -Remove @{otherMailbox="old@contoso.com"}
```

> [!info] Attributs étendus courants
> 
> - **proxyAddresses** : Adresses email multiples (Exchange)
> - **extensionAttribute1-15** : Attributs personnalisés disponibles par défaut
> - **info** : Champ notes
> - **msExchHideFromAddressLists** : Masquer des listes d'adresses Exchange
> - **telephoneNumber**, **mobile**, **facsimileTelephoneNumber** : Numéros de téléphone

#### Exemples pratiques

```powershell
# Ajouter un alias email secondaire
Set-ADUser -Identity jdoe -Add @{
    proxyAddresses="smtp:jean.d@contoso.com"
}

# Marquer un utilisateur VIP avec un attribut personnalisé
Set-ADUser -Identity jdoe -Replace @{
    extensionAttribute1="VIP"
    extensionAttribute2="Priority-Support"
}

# Masquer de la GAL Exchange
Set-ADUser -Identity jdoe -Replace @{
    msExchHideFromAddressLists=$true
}

# Nettoyer un attribut obsolète
Set-ADUser -Identity jdoe -Clear extensionAttribute10
```

> [!warning] Piège fréquent avec -Add L'opérateur `-Add` ajoute sans vérifier si la valeur existe déjà. Sur un attribut mono-valué, cela provoquera une erreur. Sur un multi-valué, cela peut créer des doublons selon l'attribut.

---

### Opérations en masse

La puissance de `Set-ADUser` se révèle particulièrement dans les opérations en masse via le pipeline.

#### Pipeline depuis Get-ADUser

```powershell
# Désactiver tous les utilisateurs d'une OU spécifique
Get-ADUser -Filter * -SearchBase "OU=Stagiaires,DC=contoso,DC=com" | 
    Set-ADUser -Enabled $false

# Forcer le changement de mot de passe pour un département
Get-ADUser -Filter {Department -eq "IT"} | 
    Set-ADUser -ChangePasswordAtLogon $true

# Mettre à jour le manager pour toute une équipe
Get-ADUser -Filter {Title -like "*Développeur*"} | 
    Set-ADUser -Manager "CN=Tech Lead,OU=Managers,DC=contoso,DC=com"
```

#### Scripts de mise à jour départementale

```powershell
# Mise à jour en masse depuis un fichier CSV
# Fichier CSV : SamAccountName,NewTitle,NewDepartment
$users = Import-Csv "C:\Scripts\updates.csv"

foreach ($user in $users) {
    Set-ADUser -Identity $user.SamAccountName `
        -Title $user.NewTitle `
        -Department $user.NewDepartment
    
    Write-Host "Mise à jour : $($user.SamAccountName)" -ForegroundColor Green
}
```

#### Synchronisation d'attributs depuis un système externe

```powershell
# Exemple : Synchronisation d'employés depuis un export RH
$hrData = Import-Csv "C:\HR\employees.csv"

foreach ($employee in $hrData) {
    $user = Get-ADUser -Filter {EmployeeID -eq $employee.EmployeeID} -Properties EmployeeID
    
    if ($user) {
        Set-ADUser -Identity $user.SamAccountName `
            -Title $employee.JobTitle `
            -Department $employee.Department `
            -OfficePhone $employee.Phone `
            -Office $employee.Location `
            -Replace @{
                extensionAttribute1 = $employee.CostCenter
                extensionAttribute2 = $employee.ManagerID
            }
        
        Write-Host "Synchronisé : $($user.SamAccountName)" -ForegroundColor Cyan
    }
}
```

> [!tip] Optimisation des performances Pour les opérations en masse sur des milliers d'utilisateurs :
> 
> - Utilisez `-Filter` plutôt que `-LDAPFilter` pour les requêtes simples
> - Limitez les propriétés récupérées avec `-Properties`
> - Ajoutez des logs pour suivre la progression
> - Testez d'abord sur un petit échantillon

#### Mise à jour conditionnelle avancée

```powershell
# Mettre à jour uniquement si certaines conditions sont remplies
Get-ADUser -Filter * -Properties Title, Department | 
    Where-Object {
        $_.Title -eq $null -and 
        $_.Department -eq "IT"
    } | 
    Set-ADUser -Title "Technicien IT" -Description "Titre mis à jour automatiquement"

# Nettoyer les comptes expirés depuis plus de 30 jours
$cutoffDate = (Get-Date).AddDays(-30)
Get-ADUser -Filter {AccountExpirationDate -lt $cutoffDate} -Properties AccountExpirationDate |
    Set-ADUser -Enabled $false -Description "Compte désactivé - expiration dépassée"
```

---

## 🗑️ Remove-ADUser - Suppression d'utilisateurs

### Pourquoi Remove-ADUser ?

`Remove-ADUser` supprime définitivement un compte utilisateur d'Active Directory. Cette opération est irréversible (sauf si la Corbeille AD est activée) et doit être manipulée avec une extrême prudence.

> [!warning] Opération critique La suppression d'un utilisateur est **définitive** et supprime :
> 
> - L'objet utilisateur AD
> - Toutes les appartenances aux groupes
> - Les permissions NTFS associées au SID (converties en SID orphelin)
> - L'historique de connexion
> 
> **Privilégiez toujours la désactivation à la suppression immédiate.**

---

### Syntaxe de base

```powershell
# Suppression simple (demandera confirmation)
Remove-ADUser -Identity jdoe

# Suppression sans confirmation (DANGEREUX)
Remove-ADUser -Identity jdoe -Confirm:$false

# Simulation de la suppression (recommandé pour tester)
Remove-ADUser -Identity jdoe -WhatIf
```

#### Paramètres principaux

|Paramètre|Description|Recommandation|
|---|---|---|
|`-Identity`|Identifiant de l'utilisateur|Obligatoire|
|`-Confirm`|Demander confirmation|Toujours $true en production|
|`-WhatIf`|Simuler sans exécuter|Utilisez avant toute suppression|

> [!tip] Always use -WhatIf first
> 
> ```powershell
> # 1. Tester d'abord
> Remove-ADUser -Identity jdoe -WhatIf
> 
> # 2. Si tout est OK, exécuter avec confirmation
> Remove-ADUser -Identity jdoe -Confirm:$true
> ```

---

### Précautions essentielles

Avant toute suppression, plusieurs vérifications sont indispensables :

#### 1. Sauvegarde des données utilisateur

```powershell
# Exporter les informations complètes avant suppression
$user = Get-ADUser -Identity jdoe -Properties *
$user | Export-Clixml "C:\Backups\AD\jdoe_$(Get-Date -Format 'yyyyMMdd').xml"

# Alternative : Export CSV lisible
$user | Select-Object SamAccountName, DisplayName, EmailAddress, Department, 
    Manager, MemberOf, Created, Modified, LastLogonDate | 
    Export-Csv "C:\Backups\AD\jdoe_info.csv" -NoTypeInformation
```

#### 2. Vérification des dépendances

```powershell
# Lister toutes les appartenances aux groupes
$groups = Get-ADUser -Identity jdoe -Properties MemberOf | 
    Select-Object -ExpandProperty MemberOf

Write-Host "L'utilisateur appartient à $($groups.Count) groupes :" -ForegroundColor Yellow
$groups | ForEach-Object { Write-Host "  - $_" }

# Vérifier si l'utilisateur est manager d'autres utilisateurs
$directReports = Get-ADUser -Filter {Manager -eq (Get-ADUser jdoe).DistinguishedName}

if ($directReports) {
    Write-Host "ATTENTION : Cet utilisateur est manager de $($directReports.Count) personnes" -ForegroundColor Red
    $directReports | Select-Object Name, SamAccountName
}
```

#### 3. Permissions héritées et objets possédés

```powershell
# Vérifier les dossiers partagés où l'utilisateur a des permissions
# (nécessite le module NTFSSecurity ou scripts personnalisés)

# Lister les objets AD dont l'utilisateur est propriétaire
Get-ADObject -Filter {managedBy -eq (Get-ADUser jdoe).DistinguishedName} |
    Select-Object Name, ObjectClass, DistinguishedName
```

#### 4. Vérification des boîtes mail Exchange

```powershell
# Si Exchange est présent (nécessite le module Exchange)
# Get-Mailbox -Identity jdoe | Select-Object DisplayName, PrimarySmtpAddress, Database

# Vérifier les calendriers partagés, délégations, etc.
```

> [!warning] Checklist avant suppression
> 
> - [ ] Export complet des données utilisateur effectué
> - [ ] Appartenances aux groupes documentées
> - [ ] Aucun direct report ou réassignation effectuée
> - [ ] Boîte mail traitée (archivage, transfert)
> - [ ] Permissions NTFS inventoriées et réassignées si nécessaire
> - [ ] Objets possédés (dossiers publics, groupes) réassignés
> - [ ] Validation métier obtenue
> - [ ] Date de suppression planifiée respectée (ex: 30 jours après départ)

---

### Alternatives à la suppression

Dans la majorité des cas, il est préférable de **désactiver** plutôt que de supprimer immédiatement :

#### Désactivation avec archivage

```powershell
# Désactiver et marquer pour archivage
Set-ADUser -Identity jdoe `
    -Enabled $false `
    -Description "DÉSACTIVÉ - Départ le $(Get-Date -Format 'dd/MM/yyyy') - Supprimer après 90 jours"

# Déplacer vers une OU d'archivage
Move-ADObject -Identity (Get-ADUser jdoe).DistinguishedName `
    -TargetPath "OU=Utilisateurs Désactivés,DC=contoso,DC=com"

# Retirer des groupes (sauf Domain Users)
$user = Get-ADUser -Identity jdoe -Properties MemberOf
$user.MemberOf | ForEach-Object {
    Remove-ADGroupMember -Identity $_ -Members jdoe -Confirm:$false
}
```

#### Script d'offboarding complet

```powershell
function Disable-UserAccount {
    param(
        [Parameter(Mandatory=$true)]
        [string]$SamAccountName,
        
        [string]$ArchiveOU = "OU=Utilisateurs Désactivés,DC=contoso,DC=com"
    )
    
    # 1. Export des données
    $backupPath = "C:\Backups\AD\$SamAccountName`_$(Get-Date -Format 'yyyyMMdd').xml"
    Get-ADUser -Identity $SamAccountName -Properties * | Export-Clixml $backupPath
    Write-Host "✓ Sauvegarde créée : $backupPath" -ForegroundColor Green
    
    # 2. Désactivation
    Set-ADUser -Identity $SamAccountName -Enabled $false
    Write-Host "✓ Compte désactivé" -ForegroundColor Green
    
    # 3. Mise à jour description
    $description = "DÉSACTIVÉ - $(Get-Date -Format 'dd/MM/yyyy') - Supprimer après $(Get-Date).AddDays(90).ToString('dd/MM/yyyy')"
    Set-ADUser -Identity $SamAccountName -Description $description
    
    # 4. Retrait des groupes
    $user = Get-ADUser -Identity $SamAccountName -Properties MemberOf
    foreach ($group in $user.MemberOf) {
        Remove-ADGroupMember -Identity $group -Members $SamAccountName -Confirm:$false
    }
    Write-Host "✓ Retiré de $($user.MemberOf.Count) groupes" -ForegroundColor Green
    
    # 5. Déplacement vers OU d'archivage
    Move-ADObject -Identity $user.DistinguishedName -TargetPath $ArchiveOU
    Write-Host "✓ Déplacé vers OU d'archivage" -ForegroundColor Green
    
    Write-Host "`n✓ Offboarding terminé pour $SamAccountName" -ForegroundColor Cyan
}

# Utilisation
Disable-UserAccount -SamAccountName "jdoe"
```

> [!tip] Politique recommandée **Processus en trois étapes :**
> 
> 1. **J+0** : Désactivation immédiate du compte au départ
> 2. **J+30** : Archivage de la boîte mail et vérification des permissions
> 3. **J+90** : Suppression définitive après validation métier

---

### Récupération et archivage

#### Corbeille Active Directory

Si la Corbeille AD est activée, les objets supprimés peuvent être récupérés :

```powershell
# Vérifier si la Corbeille AD est activée
Get-ADOptionalFeature -Filter {Name -like "Recycle*"}

# Rechercher un utilisateur supprimé
Get-ADObject -Filter {
    SamAccountName -eq "jdoe" -and 
    IsDeleted -eq $true
} -IncludeDeletedObjects -Properties *

# Restaurer un utilisateur supprimé
Restore-ADObject -Identity "CN=John Doe\0ADEL:a1b2c3d4...,CN=Deleted Objects,DC=contoso,DC=com"
```

> [!info] Durée de rétention Par défaut, les objets supprimés restent dans la Corbeille AD pendant **180 jours** avant suppression définitive. Cette durée correspond au paramètre `msDS-DeletedObjectLifetime`.

#### Suppression en masse contrôlée

```powershell
# Supprimer tous les comptes désactivés depuis plus de 90 jours
# situés dans l'OU d'archivage

$archiveOU = "OU=Utilisateurs Désactivés,DC=contoso,DC=com"
$cutoffDate = (Get-Date).AddDays(-90)

# 1. Identifier les comptes éligibles
$usersToDelete = Get-ADUser -Filter {Enabled -eq $false} `
    -SearchBase $archiveOU `
    -Properties Modified, Description | 
    Where-Object {$_.Modified -lt $cutoffDate}

Write-Host "Comptes à supprimer : $($usersToDelete.Count)" -ForegroundColor Yellow

# 2. Export de sécurité
$usersToDelete | Export-Csv "C:\Backups\AD\Deletion_$(Get-Date -Format 'yyyyMMdd').csv" -NoTypeInformation

# 3. Suppression avec confirmation
foreach ($user in $usersToDelete) {
    Write-Host "Suppression de $($user.SamAccountName)..." -ForegroundColor Red
    Remove-ADUser -Identity $user.SamAccountName -Confirm:$true
}
```

#### Script de purge automatisée sécurisée

```powershell
function Remove-ArchivedUsers {
    param(
        [int]$DaysInactive = 90,
        [string]$ArchiveOU = "OU=Utilisateurs Désactivés,DC=contoso,DC=com",
        [switch]$WhatIf
    )
    
    $cutoffDate = (Get-Date).AddDays(-$DaysInactive)
    
    # Récupérer les candidats
    $candidates = Get-ADUser -Filter {Enabled -eq $false} `
        -SearchBase $ArchiveOU `
        -Properties Modified, Description, LastLogonDate
    
    $toDelete = $candidates | Where-Object {$_.Modified -lt $cutoffDate}
    
    Write-Host "`n=== Rapport de purge ===" -ForegroundColor Cyan
    Write-Host "Date limite : $($cutoffDate.ToString('dd/MM/yyyy'))"
    Write-Host "Comptes éligibles : $($toDelete.Count)"
    
    if ($toDelete.Count -eq 0) {
        Write-Host "Aucun compte à supprimer." -ForegroundColor Green
        return
    }
    
    # Export de sécurité
    $exportPath = "C:\Backups\AD\Purge_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"
    $toDelete | Select-Object SamAccountName, Name, Modified, LastLogonDate, Description |
        Export-Csv $exportPath -NoTypeInformation
    Write-Host "Export créé : $exportPath" -ForegroundColor Green
    
    # Suppression
    if ($WhatIf) {
        Write-Host "`n[MODE SIMULATION]" -ForegroundColor Yellow
        $toDelete | ForEach-Object {
            Write-Host "  Supprimerait : $($_.SamAccountName) (modifié le $($_.Modified))"
        }
    } else {
        foreach ($user in $toDelete) {
            try {
                Remove-ADUser -Identity $user.SamAccountName -Confirm:$false
                Write-Host "✓ Supprimé : $($user.SamAccountName)" -ForegroundColor Green
            } catch {
                Write-Host "✗ Erreur : $($user.SamAccountName) - $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
}

# Utilisation
Remove-ArchivedUsers -DaysInactive 90 -WhatIf  # Test d'abord
Remove-ArchivedUsers -DaysInactive 90           # Exécution réelle
```

---

### Droits requis

Pour supprimer des utilisateurs, vous devez disposer de :

- **Permissions sur l'objet** : Droits de suppression (`Delete` et `Delete Tree`)
- **Permissions sur l'OU** : Droits de suppression d'objets enfants
- **Appartenance typique** : Admins du domaine, Administrateurs délégués

```powershell
# Vérifier ses propres permissions (nécessite le module ActiveDirectory)
$user = Get-ADUser -Identity $env:USERNAME
$ou = "OU=Users,DC=contoso,DC=com"

# Cette commande nécessite des droits élevés
# Get-Acl "AD:\$ou" | Select-Object -ExpandProperty Access | 
#     Where-Object {$_.IdentityReference -like "*$($user.SamAccountName)*"}
```

> [!warning] Audit des suppressions Les suppressions d'utilisateurs sont des événements de sécurité critiques. Assurez-vous que :
> 
> - L'audit AD est activé (Event ID 4726 : User Account Deleted)
> - Les logs sont conservés suffisamment longtemps
> - Un processus d'approbation métier existe
> - Les scripts automatisés incluent des logs détaillés

---

## 🎯 Résumé des bonnes pratiques

### Set-ADUser

✅ **À FAIRE**

- Utiliser `-WhatIf` avant les modifications en masse
- Exporter les données avant modifications importantes
- Combiner plusieurs modifications en une seule commande
- Utiliser le pipeline pour les opérations en masse
- Logger les modifications dans les scripts de production
- Tester sur un compte de test d'abord

❌ **À ÉVITER**

- Modifier les attributs systèmes critiques (SID, GUID, etc.)
- Utiliser `-PasswordNeverExpires $true` sur des comptes utilisateurs normaux
- Oublier de valider les modifications avec `Get-ADUser -Properties *`
- Modifier des attributs sans comprendre leur impact (notamment Exchange)

### Remove-ADUser

✅ **À FAIRE**

- **Toujours** utiliser `-WhatIf` en premier
- Exporter les données utilisateur avant suppression
- Vérifier les dépendances (groupes, manager, boîte mail)
- Préférer la désactivation à la suppression immédiate
- Documenter la raison de la suppression
- Implémenter une période de rétention (90 jours recommandé)
- Valider avec le métier avant suppression définitive

❌ **À ÉVITER**

- Supprimer immédiatement au départ d'un employé
- Utiliser `-Confirm:$false` sans sauvegarde préalable
- Supprimer sans vérifier la Corbeille AD
- Oublier de réassigner les objets possédés
- Supprimer sans audit/traçabilité

---

> [!tip] Automatisation intelligente Créez des fonctions réutilisables qui intègrent toutes les vérifications et sauvegardes. Cela garantit la cohérence et réduit les erreurs humaines lors des opérations critiques.