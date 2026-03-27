

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

## 🗑️ Remove-LocalUser

### Vue d'ensemble

`Remove-LocalUser` permet de supprimer définitivement des comptes utilisateurs locaux d'un système Windows. Cette cmdlet est irréversible et doit être utilisée avec précaution.

> [!warning] Attention La suppression d'un utilisateur est **permanente** et ne peut pas être annulée. Les données de profil peuvent être perdues.

### Pourquoi et quand l'utiliser

- Nettoyage de comptes obsolètes ou temporaires
- Départ définitif d'un employé
- Suppression de comptes de test après validation
- Maintenance et audit de sécurité du système

### Syntaxe détaillée

```powershell
# Syntaxe de base
Remove-LocalUser -Name "NomUtilisateur"

# Par SID (Security Identifier)
Remove-LocalUser -SID "S-1-5-21-..."

# Avec confirmation interactive
Remove-LocalUser -Name "NomUtilisateur" -Confirm

# Simulation sans exécution réelle (test)
Remove-LocalUser -Name "NomUtilisateur" -WhatIf

# Supprimer plusieurs utilisateurs
"User1", "User2", "User3" | Remove-LocalUser

# Avec gestion d'erreur
try {
    Remove-LocalUser -Name "TempUser" -ErrorAction Stop
    Write-Host "Utilisateur supprimé avec succès" -ForegroundColor Green
} catch {
    Write-Host "Erreur: $_" -ForegroundColor Red
}
```

### Paramètres principaux

|Paramètre|Description|Exemple|
|---|---|---|
|`-Name`|Nom de l'utilisateur à supprimer|`-Name "JDupont"`|
|`-SID`|Identifiant de sécurité unique|`-SID "S-1-5-21-123..."`|
|`-Confirm`|Demande confirmation avant suppression|`-Confirm`|
|`-WhatIf`|Simule l'action sans l'exécuter|`-WhatIf`|

### Précautions avant suppression

> [!info] Vérifications essentielles Avant de supprimer un utilisateur, vérifiez toujours :

```powershell
# 1. Vérifier l'existence de l'utilisateur
Get-LocalUser -Name "NomUtilisateur"

# 2. Vérifier les groupes d'appartenance
Get-LocalGroup | Where-Object {
    (Get-LocalGroupMember -Group $_.Name).Name -contains "NomUtilisateur"
}

# 3. Lister les processus en cours de l'utilisateur
Get-Process -IncludeUserName | Where-Object {$_.UserName -like "*NomUtilisateur*"}

# 4. Vérifier les sessions actives
query user
```

### Limitations importantes

> [!warning] Utilisateurs intégrés protégés Impossible de supprimer les comptes système Windows intégrés :

- **Administrateur** (Administrator)
- **Invité** (Guest)
- **DefaultAccount**
- **WDAGUtilityAccount**

```powershell
# Cette commande échouera
Remove-LocalUser -Name "Administrator"
# Erreur: Impossible de supprimer un compte intégré
```

### Impact sur les fichiers et dossiers personnels

> [!warning] Profil utilisateur La suppression d'un utilisateur **NE SUPPRIME PAS automatiquement** :
> 
> - Le dossier profil (`C:\Users\NomUtilisateur`)
> - Les fichiers personnels
> - Les paramètres de registre

```powershell
# Supprimer l'utilisateur ET son profil
Remove-LocalUser -Name "TempUser"

# Ensuite, supprimer manuellement le profil
$ProfilePath = "C:\Users\TempUser"
if (Test-Path $ProfilePath) {
    Remove-Item -Path $ProfilePath -Recurse -Force
}

# Nettoyer le registre des profils
$ProfileList = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"
Get-ChildItem $ProfileList | Where-Object {
    (Get-ItemProperty $_.PSPath).ProfileImagePath -like "*TempUser*"
} | Remove-Item -Recurse
```

### Sauvegarde avant suppression

> [!tip] Bonnes pratiques Toujours sauvegarder avant une suppression définitive

```powershell
# Script de sauvegarde et suppression sécurisée
$UserName = "JDupont"
$BackupPath = "C:\Backups\Users\$UserName-$(Get-Date -Format 'yyyyMMdd')"

# 1. Créer le dossier de sauvegarde
New-Item -Path $BackupPath -ItemType Directory -Force

# 2. Exporter les informations utilisateur
Get-LocalUser -Name $UserName | Export-Clixml "$BackupPath\UserInfo.xml"

# 3. Sauvegarder les appartenances aux groupes
Get-LocalGroup | Where-Object {
    (Get-LocalGroupMember -Group $_.Name -ErrorAction SilentlyContinue).Name -contains $UserName
} | Select-Object Name | Export-Csv "$BackupPath\GroupMembership.csv" -NoTypeInformation

# 4. Copier le profil utilisateur
$SourceProfile = "C:\Users\$UserName"
if (Test-Path $SourceProfile) {
    Copy-Item -Path $SourceProfile -Destination "$BackupPath\Profile" -Recurse -Force
}

# 5. Procéder à la suppression
Remove-LocalUser -Name $UserName -Confirm
```

### Pièges courants

```powershell
# ❌ ERREUR: Utilisateur connecté
Remove-LocalUser -Name "UserActif"
# Solution: Déconnecter d'abord l'utilisateur
logoff (query user | Select-String "UserActif" | ForEach-Object {($_ -split '\s+')[2]})

# ❌ ERREUR: Permissions insuffisantes
Remove-LocalUser -Name "Test"
# Solution: Exécuter PowerShell en tant qu'administrateur

# ❌ ERREUR: Utilisateur utilisé par des services
Remove-LocalUser -Name "ServiceAccount"
# Solution: Arrêter les services concernés d'abord
Get-Service | Where-Object {$_.StartName -like "*ServiceAccount*"} | Stop-Service
```

---

## ✅ Enable-LocalUser

### Vue d'ensemble

`Enable-LocalUser` réactive un compte utilisateur local précédemment désactivé, restaurant son accès au système.

### Pourquoi et quand l'utiliser

- Retour d'un employé après absence prolongée
- Fin d'une période de suspension disciplinaire
- Réactivation de comptes saisonniers
- Déblocage après investigation de sécurité

### Syntaxe détaillée

```powershell
# Activer par nom d'utilisateur
Enable-LocalUser -Name "NomUtilisateur"

# Activer par SID
Enable-LocalUser -SID "S-1-5-21-..."

# Activer plusieurs utilisateurs
"User1", "User2", "User3" | Enable-LocalUser

# Pipeline depuis Get-LocalUser
Get-LocalUser -Name "JDupont" | Enable-LocalUser

# Avec confirmation
Enable-LocalUser -Name "JDupont" -Confirm
```

### Vérification de l'état avant/après activation

```powershell
# Vérifier l'état actuel
$User = Get-LocalUser -Name "JDupont"
if ($User.Enabled -eq $false) {
    Write-Host "Utilisateur désactivé - Activation en cours..." -ForegroundColor Yellow
    Enable-LocalUser -Name "JDupont"
    Write-Host "Utilisateur activé avec succès" -ForegroundColor Green
} else {
    Write-Host "Utilisateur déjà actif" -ForegroundColor Cyan
}

# Vérification après activation
Get-LocalUser -Name "JDupont" | Select-Object Name, Enabled, LastLogon
```

### Utilisation après suspension temporaire

> [!example] Scénario réel Gestion d'un retour après congé

```powershell
# Script de réactivation avec notifications
param(
    [Parameter(Mandatory=$true)]
    [string]$UserName
)

# Vérifier que l'utilisateur existe
if (-not (Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue)) {
    Write-Error "Utilisateur $UserName introuvable"
    exit
}

# Activer le compte
Enable-LocalUser -Name $UserName

# Réinitialiser l'expiration du mot de passe si nécessaire
Set-LocalUser -Name $UserName -PasswordNeverExpires $false

# Journal d'activation
$LogEntry = @{
    Date = Get-Date
    User = $UserName
    Action = "Account Enabled"
    Administrator = $env:USERNAME
}
$LogEntry | Export-Csv "C:\Logs\UserActivations.csv" -Append -NoTypeInformation

Write-Host "✓ Compte $UserName réactivé avec succès" -ForegroundColor Green
```

### Logs d'activation

> [!tip] Traçabilité Garder une trace des activations pour l'audit

```powershell
# Fonction de journalisation avancée
function Enable-LocalUserWithLog {
    param(
        [Parameter(Mandatory=$true)]
        [string]$UserName,
        [string]$Reason = "Non spécifié"
    )
    
    try {
        # Capturer l'état avant
        $UserBefore = Get-LocalUser -Name $UserName
        
        # Activer l'utilisateur
        Enable-LocalUser -Name $UserName -ErrorAction Stop
        
        # Capturer l'état après
        $UserAfter = Get-LocalUser -Name $UserName
        
        # Créer l'entrée de log
        $LogEntry = [PSCustomObject]@{
            Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            UserName = $UserName
            Action = "ENABLED"
            PreviousState = $UserBefore.Enabled
            NewState = $UserAfter.Enabled
            Administrator = $env:USERNAME
            ComputerName = $env:COMPUTERNAME
            Reason = $Reason
        }
        
        # Écrire dans le fichier de log
        $LogPath = "C:\Logs\UserManagement.csv"
        $LogEntry | Export-Csv -Path $LogPath -Append -NoTypeInformation
        
        # Écrire dans l'Event Log Windows
        Write-EventLog -LogName Application -Source "UserManagement" `
            -EventId 1001 -EntryType Information `
            -Message "Compte utilisateur $UserName activé par $($env:USERNAME). Raison: $Reason"
        
        Write-Host "✓ $UserName activé et journalisé" -ForegroundColor Green
        
    } catch {
        Write-Error "Échec de l'activation: $_"
    }
}

# Utilisation
Enable-LocalUserWithLog -UserName "JDupont" -Reason "Retour de congé"
```

### Vérifications post-activation

```powershell
# Vérifier que tout fonctionne correctement
function Test-UserActivation {
    param([string]$UserName)
    
    $User = Get-LocalUser -Name $UserName
    
    $Tests = @{
        "Compte activé" = $User.Enabled
        "Mot de passe non expiré" = -not $User.PasswordExpired
        "Compte non verrouillé" = -not $User.LockoutEnabled
        "Description présente" = $User.Description -ne ""
    }
    
    $Tests.GetEnumerator() | ForEach-Object {
        $Status = if ($_.Value) { "✓" } else { "✗" }
        $Color = if ($_.Value) { "Green" } else { "Red" }
        Write-Host "$Status $($_.Key)" -ForegroundColor $Color
    }
}

# Exécution
Test-UserActivation -UserName "JDupont"
```

---

## 🔒 Disable-LocalUser

### Vue d'ensemble

`Disable-LocalUser` désactive temporairement un compte utilisateur local sans le supprimer, empêchant toute connexion tout en préservant les données et permissions.

> [!info] Différence clé **Disable** vs **Remove** : La désactivation est réversible et conserve toutes les données utilisateur, contrairement à la suppression.

### Pourquoi c'est une alternative à la suppression

|Aspect|Disable-LocalUser|Remove-LocalUser|
|---|---|---|
|Réversibilité|✅ Réversible|❌ Irréversible|
|Données conservées|✅ Tout conservé|❌ Nécessite sauvegarde|
|Permissions|✅ Préservées|❌ Perdues|
|Connexion possible|❌ Bloquée|❌ Impossible|
|Profil|✅ Intact|⚠️ Nécessite gestion manuelle|

### Syntaxe détaillée

```powershell
# Désactiver par nom
Disable-LocalUser -Name "NomUtilisateur"

# Désactiver par SID
Disable-LocalUser -SID "S-1-5-21-..."

# Désactiver plusieurs utilisateurs
"User1", "User2", "User3" | Disable-LocalUser

# Pipeline depuis Get-LocalUser
Get-LocalUser -Name "JDupont" | Disable-LocalUser

# Désactiver avec confirmation
Disable-LocalUser -Name "JDupont" -Confirm

# Désactiver tous les utilisateurs inactifs depuis 90 jours
Get-LocalUser | Where-Object {
    $_.Enabled -and 
    $_.LastLogon -and 
    $_.LastLogon -lt (Get-Date).AddDays(-90)
} | Disable-LocalUser
```

### Préservation des données et permissions

```powershell
# Vérifier ce qui est préservé après désactivation
function Show-DisabledUserInfo {
    param([string]$UserName)
    
    $User = Get-LocalUser -Name $UserName
    
    Write-Host "`n=== Informations préservées pour $UserName ===" -ForegroundColor Cyan
    
    # Informations de base
    Write-Host "`nInformations de compte:" -ForegroundColor Yellow
    $User | Select-Object Name, SID, Description, PasswordLastSet | Format-List
    
    # Appartenance aux groupes
    Write-Host "Appartenance aux groupes:" -ForegroundColor Yellow
    Get-LocalGroup | Where-Object {
        (Get-LocalGroupMember -Group $_.Name -ErrorAction SilentlyContinue).Name -contains $UserName
    } | Select-Object Name
    
    # Profil utilisateur
    Write-Host "`nProfil utilisateur:" -ForegroundColor Yellow
    $ProfilePath = "C:\Users\$UserName"
    if (Test-Path $ProfilePath) {
        $Size = (Get-ChildItem $ProfilePath -Recurse -ErrorAction SilentlyContinue | 
                 Measure-Object -Property Length -Sum).Sum / 1MB
        Write-Host "  Chemin: $ProfilePath"
        Write-Host "  Taille: $([math]::Round($Size, 2)) MB"
        Write-Host "  Status: ✓ Intact" -ForegroundColor Green
    }
}

# Utilisation
Disable-LocalUser -Name "JDupont"
Show-DisabledUserInfo -UserName "JDupont"
```

### Utilisations courantes

#### 1. Départs temporaires

```powershell
# Gestion de congé prolongé
function Set-UserLeaveStatus {
    param(
        [string]$UserName,
        [DateTime]$LeaveStart,
        [DateTime]$LeaveEnd,
        [string]$Reason
    )
    
    # Désactiver le compte
    Disable-LocalUser -Name $UserName
    
    # Ajouter une description avec les dates
    $Description = "CONGÉ: du $($LeaveStart.ToShortDateString()) au $($LeaveEnd.ToShortDateString()). Raison: $Reason"
    Set-LocalUser -Name $UserName -Description $Description
    
    # Programmer la réactivation automatique (nécessite une tâche planifiée)
    $Action = New-ScheduledTaskAction -Execute "powershell.exe" `
        -Argument "-Command Enable-LocalUser -Name '$UserName'"
    
    $Trigger = New-ScheduledTaskTrigger -Once -At $LeaveEnd
    
    Register-ScheduledTask -TaskName "ReactivateUser_$UserName" `
        -Action $Action -Trigger $Trigger -Description "Réactivation auto de $UserName"
    
    Write-Host "✓ Compte $UserName désactivé jusqu'au $($LeaveEnd.ToShortDateString())" -ForegroundColor Green
}

# Exemple d'utilisation
Set-UserLeaveStatus -UserName "JDupont" `
    -LeaveStart (Get-Date) `
    -LeaveEnd (Get-Date).AddDays(30) `
    -Reason "Congé parental"
```

#### 2. Comptes de service inactifs

```powershell
# Désactiver les comptes de service obsolètes
function Disable-UnusedServiceAccounts {
    # Identifier les comptes de service (par convention de nommage)
    $ServiceAccounts = Get-LocalUser | Where-Object {
        $_.Name -like "svc_*" -or 
        $_.Name -like "service_*" -or
        $_.Description -like "*service*"
    }
    
    foreach ($Account in $ServiceAccounts) {
        # Vérifier si utilisé par un service actif
        $UsedByService = Get-Service | Where-Object {
            $_.StartName -like "*$($Account.Name)*"
        }
        
        if (-not $UsedByService -and $Account.Enabled) {
            Write-Host "Désactivation de $($Account.Name) (non utilisé)" -ForegroundColor Yellow
            Disable-LocalUser -Name $Account.Name
            
            # Marquer dans la description
            $NewDesc = "[DÉSACTIVÉ $(Get-Date -Format 'yyyy-MM-dd')] " + $Account.Description
            Set-LocalUser -Name $Account.Name -Description $NewDesc
        }
    }
}

# Exécution
Disable-UnusedServiceAccounts
```

### Sécurité : désactiver plutôt que supprimer

> [!tip] Principe de sécurité En cas de doute, toujours désactiver plutôt que supprimer. Vous pourrez toujours supprimer plus tard.

```powershell
# Workflow de sécurité recommandé
function Invoke-SecureUserRemoval {
    param(
        [string]$UserName,
        [int]$QuarantineDays = 30
    )
    
    # Étape 1: Désactivation immédiate
    Write-Host "Étape 1: Désactivation du compte..." -ForegroundColor Yellow
    Disable-LocalUser -Name $UserName
    
    # Étape 2: Marquer pour suppression différée
    $RemovalDate = (Get-Date).AddDays($QuarantineDays)
    $Description = "[SUPPRESSION PLANIFIÉE: $($RemovalDate.ToShortDateString())] " + 
                   (Get-LocalUser -Name $UserName).Description
    Set-LocalUser -Name $UserName -Description $Description
    
    # Étape 3: Créer une tâche de suppression différée
    $Action = New-ScheduledTaskAction -Execute "powershell.exe" `
        -Argument "-Command Remove-LocalUser -Name '$UserName'"
    
    $Trigger = New-ScheduledTaskTrigger -Once -At $RemovalDate
    
    Register-ScheduledTask -TaskName "DelayedRemoval_$UserName" `
        -Action $Action -Trigger $Trigger `
        -Description "Suppression différée de $UserName après période de quarantaine"
    
    Write-Host "`n✓ Compte désactivé. Suppression automatique prévue le $($RemovalDate.ToShortDateString())" -ForegroundColor Green
    Write-Host "  Pour annuler: Enable-LocalUser -Name '$UserName' et supprimer la tâche planifiée" -ForegroundColor Cyan
}

# Utilisation
Invoke-SecureUserRemoval -UserName "ExEmployee" -QuarantineDays 30
```

### Audit des comptes désactivés

```powershell
# Générer un rapport des comptes désactivés
function Get-DisabledUsersReport {
    param(
        [string]$ExportPath = "C:\Reports\DisabledUsers_$(Get-Date -Format 'yyyyMMdd').csv"
    )
    
    # Récupérer tous les utilisateurs désactivés
    $DisabledUsers = Get-LocalUser | Where-Object { $_.Enabled -eq $false }
    
    # Créer un rapport détaillé
    $Report = $DisabledUsers | ForEach-Object {
        $UserName = $_.Name
        
        # Trouver les groupes
        $Groups = (Get-LocalGroup | Where-Object {
            (Get-LocalGroupMember -Group $_.Name -ErrorAction SilentlyContinue).Name -contains $UserName
        }).Name -join "; "
        
        # Vérifier le profil
        $ProfileExists = Test-Path "C:\Users\$UserName"
        
        [PSCustomObject]@{
            Nom = $_.Name
            SID = $_.SID
            Description = $_.Description
            DernièreConnexion = $_.LastLogon
            MotDePasseDéfini = $_.PasswordLastSet
            GroupesMembre = $Groups
            ProfilExiste = $ProfileExists
            DateVérification = Get-Date -Format "yyyy-MM-dd HH:mm"
        }
    }
    
    # Exporter et afficher
    $Report | Export-Csv -Path $ExportPath -NoTypeInformation -Encoding UTF8
    $Report | Format-Table -AutoSize
    
    Write-Host "`n✓ Rapport exporté vers: $ExportPath" -ForegroundColor Green
    Write-Host "  Total de comptes désactivés: $($Report.Count)" -ForegroundColor Cyan
}

# Générer le rapport
Get-DisabledUsersReport
```

### Bonnes pratiques de désactivation

> [!tip] Checklist avant désactivation
> 
> - [ ] Notifier l'utilisateur (si applicable)
> - [ ] Vérifier les sessions actives et processus en cours
> - [ ] Documenter la raison dans la description du compte
> - [ ] Sauvegarder les informations importantes
> - [ ] Transférer les fichiers critiques si nécessaire
> - [ ] Mettre à jour la documentation système

```powershell
# Script complet de désactivation sécurisée
function Disable-LocalUserSecure {
    param(
        [Parameter(Mandatory=$true)]
        [string]$UserName,
        [Parameter(Mandatory=$true)]
        [string]$Reason,
        [switch]$ForceLogoff
    )
    
    Write-Host "`n=== Désactivation sécurisée de $UserName ===" -ForegroundColor Cyan
    
    # 1. Vérifier l'existence
    $User = Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue
    if (-not $User) {
        Write-Error "Utilisateur $UserName introuvable"
        return
    }
    
    # 2. Vérifier les sessions actives
    Write-Host "`n[1/5] Vérification des sessions..." -ForegroundColor Yellow
    $ActiveSession = query user 2>$null | Select-String $UserName
    if ($ActiveSession) {
        Write-Warning "Session active détectée pour $UserName"
        if ($ForceLogoff) {
            Write-Host "  Déconnexion forcée..." -ForegroundColor Yellow
            $SessionId = ($ActiveSession -split '\s+')[2]
            logoff $SessionId
            Start-Sleep -Seconds 2
        } else {
            Write-Error "Session active. Utilisez -ForceLogoff pour déconnecter"
            return
        }
    } else {
        Write-Host "  ✓ Aucune session active" -ForegroundColor Green
    }
    
    # 3. Sauvegarder les informations
    Write-Host "`n[2/5] Sauvegarde des informations..." -ForegroundColor Yellow
    $BackupPath = "C:\Backups\UserDisable\$UserName-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    New-Item -Path $BackupPath -ItemType Directory -Force | Out-Null
    
    $User | Export-Clixml "$BackupPath\UserInfo.xml"
    Get-LocalGroup | Where-Object {
        (Get-LocalGroupMember -Group $_.Name -ErrorAction SilentlyContinue).Name -contains $UserName
    } | Select-Object Name | Export-Csv "$BackupPath\Groups.csv" -NoTypeInformation
    
    Write-Host "  ✓ Sauvegarde créée: $BackupPath" -ForegroundColor Green
    
    # 4. Désactiver le compte
    Write-Host "`n[3/5] Désactivation du compte..." -ForegroundColor Yellow
    Disable-LocalUser -Name $UserName
    Write-Host "  ✓ Compte désactivé" -ForegroundColor Green
    
    # 5. Mettre à jour la description
    Write-Host "`n[4/5] Mise à jour de la description..." -ForegroundColor Yellow
    $NewDescription = "[DÉSACTIVÉ $(Get-Date -Format 'yyyy-MM-dd HH:mm')] Raison: $Reason | Par: $($env:USERNAME)"
    Set-LocalUser -Name $UserName -Description $NewDescription
    Write-Host "  ✓ Description mise à jour" -ForegroundColor Green
    
    # 6. Journal et rapport final
    Write-Host "`n[5/5] Journalisation..." -ForegroundColor Yellow
    $LogEntry = [PSCustomObject]@{
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        UserName = $UserName
        Action = "DISABLED"
        Reason = $Reason
        Administrator = $env:USERNAME
        ComputerName = $env:COMPUTERNAME
        BackupLocation = $BackupPath
    }
    $LogEntry | Export-Csv "C:\Logs\UserDisable.csv" -Append -NoTypeInformation
    Write-Host "  ✓ Journalisation terminée" -ForegroundColor Green
    
    # Rapport final
    Write-Host "`n=== Désactivation terminée ===" -ForegroundColor Green
    Write-Host "Utilisateur: $UserName" -ForegroundColor Cyan
    Write-Host "Raison: $Reason" -ForegroundColor Cyan
    Write-Host "Sauvegarde: $BackupPath" -ForegroundColor Cyan
    Write-Host "`nPour réactiver: Enable-LocalUser -Name '$UserName'" -ForegroundColor Yellow
}

# Exemple d'utilisation
Disable-LocalUserSecure -UserName "JDupont" -Reason "Fin de contrat - Période de préavis" -ForceLogoff
```

---

## 🔍 Comparaison des trois cmdlets

|Action|Remove-LocalUser|Enable-LocalUser|Disable-LocalUser|
|---|---|---|---|
|**Effet**|Suppression définitive|Activation du compte|Désactivation temporaire|
|**Réversible**|❌ Non|✅ Oui (via Disable)|✅ Oui (via Enable)|
|**Données préservées**|❌ Non (sauf profil)|N/A|✅ Oui|
|**Permissions**|❌ Perdues|N/A|✅ Conservées|
|**Usage recommandé**|Départ définitif|Retour après suspension|Suspension temporaire|
|**Risque**|⚠️ Élevé|✅ Faible|✅ Faible|

---

## ✨ Astuces avancées

### Gestion en masse

```powershell
# Désactiver tous les comptes temporaires
Get-LocalUser | Where-Object { 
    $_.Name -like "temp_*" -and $_.Enabled 
} | Disable-LocalUser

# Supprimer les comptes marqués pour suppression
Get-LocalUser | Where-Object {
    $_.Description -like "*SUPPRESSION PLANIFIÉE*" -and
    $_.Description -match '\[SUPPRESSION PLANIFIÉE: (\d{2}/\d{2}/\d{4})\]' -and
    [DateTime]::ParseExact($Matches[1], "dd/MM/yyyy", $null) -lt (Get-Date)
} | Remove-LocalUser -Confirm

# Activer tous les utilisateurs d'un département
Import-Csv "C:\Data\ReturnFromLeave.csv" | ForEach-Object {
    Enable-LocalUser -Name $_.UserName
}
```

### Notifications par email

```powershell
# Envoyer une notification après désactivation
function Send-UserDisabledNotification {
    param(
        [string]$UserName,
        [string]$Reason,
        [string]$AdminEmail = "admin@entreprise.com"
    )
    
    $MailParams = @{
        To = $AdminEmail
        From = "system@entreprise.com"
        Subject = "Compte utilisateur désactivé: $UserName"
        Body = @"
Le compte utilisateur suivant a été désactivé:

Utilisateur: $UserName
Date: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
Raison: $Reason
Administrateur: $($env:USERNAME)
Ordinateur: $($env:COMPUTERNAME)

Pour réactiver: Enable-LocalUser -Name '$UserName'
"@
        SmtpServer = "smtp.entreprise.com"
        Port = 587
        UseSsl = $true
        Credential = Get-Credential
    }
    
    Send-MailMessage @MailParams
}
```

### Automatisation avec surveillance

```powershell
# Script de surveillance et désactivation automatique des comptes inactifs
function Watch-InactiveAccounts {
    param(
        [int]$InactiveDays = 90,
        [switch]$AutoDisable
    )
    
    $ThresholdDate = (Get-Date).AddDays(-$InactiveDays)
    
    $InactiveUsers = Get-LocalUser | Where-Object {
        $_.Enabled -and 
        $_.LastLogon -and 
        $_.LastLogon -lt $ThresholdDate -and
        $_.Name -notlike "*admin*"  # Exclure les comptes admin
    }
    
    if ($InactiveUsers) {
        Write-Host "`n⚠️  Comptes inactifs détectés (>$InactiveDays jours):" -ForegroundColor Yellow
        
        $InactiveUsers | Select-Object Name, LastLogon, 
            @{Name="JoursInactif";Expression={(New-TimeSpan -Start $_.LastLogon -End (Get-Date)).Days}} |
            Format-Table -AutoSize
        
        if ($AutoDisable) {
            foreach ($User in $InactiveUsers) {
                Write-Host "Désactivation de $($User.Name)..." -ForegroundColor Yellow
                Disable-LocalUser -Name $User.Name
                
                $Reason = "Inactivité de $((New-TimeSpan -Start $User.LastLogon -End (Get-Date)).Days) jours"
                Set-LocalUser -Name $User.Name -Description "[AUTO-DÉSACTIVÉ $(Get-Date -Format 'yyyy-MM-dd')] $Reason"
            }
            Write-Host "`n✓ $($InactiveUsers.Count) compte(s) désactivé(s)" -ForegroundColor Green
        }
    } else {
        Write-Host "✓ Aucun compte inactif détecté" -ForegroundColor Green
    }
}

# Créer une tâche planifiée pour exécuter cette surveillance
$Action = New-ScheduledTaskAction -Execute "powershell.exe" `
    -Argument "-File C:\Scripts\Watch-InactiveAccounts.ps1"

$Trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Monday -At 9am

Register-ScheduledTask -TaskName "WeeklyInactiveAccountCheck" `
    -Action $Action -Trigger $Trigger `
    -Description "Surveillance hebdomadaire des comptes inactifs"
```

### Dashboard de gestion utilisateur

```powershell
# Tableau de bord interactif pour la gestion des utilisateurs
function Show-UserManagementDashboard {
    Clear-Host
    
    $AllUsers = Get-LocalUser
    $EnabledUsers = $AllUsers | Where-Object { $_.Enabled }
    $DisabledUsers = $AllUsers | Where-Object { -not $_.Enabled }
    
    Write-Host "`n" "="*60 -ForegroundColor Cyan
    Write-Host "        TABLEAU DE BORD - GESTION DES UTILISATEURS" -ForegroundColor Cyan
    Write-Host " "*60 -ForegroundColor Cyan
    Write-Host "="*60 -ForegroundColor Cyan
    
    # Statistiques globales
    Write-Host "`n📊 STATISTIQUES" -ForegroundColor Yellow
    Write-Host "   Total utilisateurs:     $($AllUsers.Count)" -ForegroundColor White
    Write-Host "   ✓ Actifs:               $($EnabledUsers.Count)" -ForegroundColor Green
    Write-Host "   ✗ Désactivés:           $($DisabledUsers.Count)" -ForegroundColor Red
    
    # Utilisateurs actifs
    Write-Host "`n✅ UTILISATEURS ACTIFS" -ForegroundColor Green
    $EnabledUsers | Select-Object Name, LastLogon, PasswordLastSet | 
        Format-Table -AutoSize
    
    # Utilisateurs désactivés
    if ($DisabledUsers) {
        Write-Host "❌ UTILISATEURS DÉSACTIVÉS" -ForegroundColor Red
        $DisabledUsers | Select-Object Name, Description | 
            Format-Table -AutoSize
    }
    
    # Alertes
    Write-Host "⚠️  ALERTES" -ForegroundColor Yellow
    
    # Comptes sans dernière connexion
    $NeverLoggedIn = $EnabledUsers | Where-Object { -not $_.LastLogon }
    if ($NeverLoggedIn) {
        Write-Host "   • $($NeverLoggedIn.Count) compte(s) jamais connecté(s):" -ForegroundColor Yellow
        $NeverLoggedIn.Name | ForEach-Object { Write-Host "     - $_" }
    }
    
    # Comptes inactifs (>90 jours)
    $Inactive = $EnabledUsers | Where-Object {
        $_.LastLogon -and $_.LastLogon -lt (Get-Date).AddDays(-90)
    }
    if ($Inactive) {
        Write-Host "   • $($Inactive.Count) compte(s) inactif(s) (>90 jours):" -ForegroundColor Yellow
        $Inactive.Name | ForEach-Object { Write-Host "     - $_" }
    }
    
    # Mots de passe anciens (>180 jours)
    $OldPasswords = $EnabledUsers | Where-Object {
        $_.PasswordLastSet -and $_.PasswordLastSet -lt (Get-Date).AddDays(-180)
    }
    if ($OldPasswords) {
        Write-Host "   • $($OldPasswords.Count) mot(s) de passe ancien(s) (>180 jours):" -ForegroundColor Yellow
        $OldPasswords.Name | ForEach-Object { Write-Host "     - $_" }
    }
    
    Write-Host "`n" "="*60 -ForegroundColor Cyan
    Write-Host "`nDernière mise à jour: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
}

# Afficher le dashboard
Show-UserManagementDashboard
```

### Pièges courants et solutions

> [!warning] Erreurs fréquentes

```powershell
# ❌ PIÈGE 1: Supprimer un utilisateur avec session active
Remove-LocalUser -Name "User1"
# Erreur: Cannot perform operation on user while user is logged on

# ✅ SOLUTION: Déconnecter d'abord
$Sessions = query user | Select-String "User1"
if ($Sessions) {
    $SessionId = ($Sessions -split '\s+')[2]
    logoff $SessionId
    Start-Sleep -Seconds 3
}
Remove-LocalUser -Name "User1"

# ❌ PIÈGE 2: Oublier de sauvegarder avant suppression
Remove-LocalUser -Name "ImportantUser"  # Données perdues !

# ✅ SOLUTION: Toujours sauvegarder
$BackupPath = "C:\Backups\Users\ImportantUser-$(Get-Date -Format 'yyyyMMdd')"
New-Item -Path $BackupPath -ItemType Directory -Force
Get-LocalUser -Name "ImportantUser" | Export-Clixml "$BackupPath\UserInfo.xml"
Copy-Item "C:\Users\ImportantUser" -Destination "$BackupPath\Profile" -Recurse
Remove-LocalUser -Name "ImportantUser"

# ❌ PIÈGE 3: Désactiver sans documentation
Disable-LocalUser -Name "User1"  # Pourquoi ? Qui ? Quand ?

# ✅ SOLUTION: Toujours documenter
$Reason = "Congé maladie prolongé - Dr. Martin"
Disable-LocalUser -Name "User1"
$Description = "[DÉSACTIVÉ $(Get-Date -Format 'yyyy-MM-dd')] $Reason | Par: $($env:USERNAME)"
Set-LocalUser -Name "User1" -Description $Description

# ❌ PIÈGE 4: Réactiver sans vérifier l'état de sécurité
Enable-LocalUser -Name "OldAccount"  # Compte compromis ?

# ✅ SOLUTION: Auditer avant réactivation
function Enable-LocalUserSecure {
    param([string]$UserName)
    
    $User = Get-LocalUser -Name $UserName
    
    # Vérifications de sécurité
    Write-Host "Vérifications de sécurité..." -ForegroundColor Yellow
    
    # Mot de passe ancien ?
    if ($User.PasswordLastSet -lt (Get-Date).AddDays(-90)) {
        Write-Warning "Mot de passe ancien (>90 jours)"
        $ResetPassword = Read-Host "Forcer le changement de mot de passe ? (O/N)"
        if ($ResetPassword -eq "O") {
            Set-LocalUser -Name $UserName -PasswordNeverExpires $false
            # L'utilisateur devra changer son mot de passe à la prochaine connexion
        }
    }
    
    # Dernière connexion suspecte ?
    if ($User.LastLogon) {
        $DaysSinceLastLogon = (New-TimeSpan -Start $User.LastLogon -End (Get-Date)).Days
        Write-Host "Dernière connexion: il y a $DaysSinceLastLogon jours"
    }
    
    # Activer seulement si tout est OK
    Enable-LocalUser -Name $UserName
    Write-Host "✓ Compte réactivé avec succès" -ForegroundColor Green
}

# ❌ PIÈGE 5: Suppression de masse sans validation
Get-LocalUser -Name "temp_*" | Remove-LocalUser  # Dangereux !

# ✅ SOLUTION: Valider avant suppression
$TempUsers = Get-LocalUser -Name "temp_*"
Write-Host "Utilisateurs à supprimer:" -ForegroundColor Yellow
$TempUsers | Select-Object Name, LastLogon | Format-Table

$Confirm = Read-Host "Confirmer la suppression de $($TempUsers.Count) compte(s) ? (oui/non)"
if ($Confirm -eq "oui") {
    $TempUsers | ForEach-Object {
        Write-Host "Suppression de $($_.Name)..." -ForegroundColor Yellow
        Remove-LocalUser -Name $_.Name
    }
    Write-Host "✓ Suppression terminée" -ForegroundColor Green
} else {
    Write-Host "Opération annulée" -ForegroundColor Cyan
}
```

### Scripts de maintenance avancés

```powershell
# Maintenance complète des comptes utilisateurs
function Invoke-UserAccountMaintenance {
    param(
        [switch]$AutoFix,
        [string]$ReportPath = "C:\Reports\UserMaintenance_$(Get-Date -Format 'yyyyMMdd').html"
    )
    
    Write-Host "`n🔧 MAINTENANCE DES COMPTES UTILISATEURS" -ForegroundColor Cyan
    Write-Host "="*60 "`n"
    
    $Issues = @()
    $AllUsers = Get-LocalUser
    
    # 1. Comptes jamais connectés (>30 jours)
    Write-Host "[1/5] Vérification des comptes jamais connectés..." -ForegroundColor Yellow
    $NeverConnected = $AllUsers | Where-Object {
        $_.Enabled -and
        -not $_.LastLogon -and
        $_.Name -notlike "*admin*" -and
        (New-TimeSpan -Start $_.PasswordLastSet -End (Get-Date)).Days -gt 30
    }
    
    if ($NeverConnected) {
        $Issues += [PSCustomObject]@{
            Type = "Jamais connecté"
            Count = $NeverConnected.Count
            Users = $NeverConnected.Name -join ", "
            Action = "Désactivation recommandée"
        }
        
        if ($AutoFix) {
            $NeverConnected | Disable-LocalUser
            Write-Host "  ✓ $($NeverConnected.Count) compte(s) désactivé(s)" -ForegroundColor Green
        }
    }
    
    # 2. Comptes inactifs (>90 jours)
    Write-Host "[2/5] Vérification des comptes inactifs..." -ForegroundColor Yellow
    $Inactive = $AllUsers | Where-Object {
        $_.Enabled -and
        $_.LastLogon -and
        $_.LastLogon -lt (Get-Date).AddDays(-90) -and
        $_.Name -notlike "*admin*"
    }
    
    if ($Inactive) {
        $Issues += [PSCustomObject]@{
            Type = "Inactif >90 jours"
            Count = $Inactive.Count
            Users = $Inactive.Name -join ", "
            Action = "Désactivation recommandée"
        }
        
        if ($AutoFix) {
            $Inactive | ForEach-Object {
                Disable-LocalUser -Name $_.Name
                $Days = (New-TimeSpan -Start $_.LastLogon -End (Get-Date)).Days
                Set-LocalUser -Name $_.Name -Description "[AUTO-DÉSACTIVÉ] Inactif depuis $Days jours"
            }
            Write-Host "  ✓ $($Inactive.Count) compte(s) désactivé(s)" -ForegroundColor Green
        }
    }
    
    # 3. Mots de passe anciens
    Write-Host "[3/5] Vérification des mots de passe anciens..." -ForegroundColor Yellow
    $OldPasswords = $AllUsers | Where-Object {
        $_.Enabled -and
        $_.PasswordLastSet -and
        $_.PasswordLastSet -lt (Get-Date).AddDays(-180) -and
        -not $_.PasswordNeverExpires
    }
    
    if ($OldPasswords) {
        $Issues += [PSCustomObject]@{
            Type = "Mot de passe ancien >180 jours"
            Count = $OldPasswords.Count
            Users = $OldPasswords.Name -join ", "
            Action = "Changement recommandé"
        }
    }
    
    # 4. Comptes désactivés depuis longtemps
    Write-Host "[4/5] Vérification des comptes désactivés..." -ForegroundColor Yellow
    $LongDisabled = $AllUsers | Where-Object {
        -not $_.Enabled -and
        $_.Description -match '\[.*DÉSACTIVÉ.*(\d{4}-\d{2}-\d{2}).*\]' -and
        [DateTime]::ParseExact($Matches[1], "yyyy-MM-dd", $null) -lt (Get-Date).AddDays(-180)
    }
    
    if ($LongDisabled) {
        $Issues += [PSCustomObject]@{
            Type = "Désactivé >180 jours"
            Count = $LongDisabled.Count
            Users = $LongDisabled.Name -join ", "
            Action = "Suppression recommandée"
        }
        
        if ($AutoFix) {
            Write-Host "  ⚠️  Suppression nécessite validation manuelle" -ForegroundColor Yellow
        }
    }
    
    # 5. Profils orphelins
    Write-Host "[5/5] Vérification des profils orphelins..." -ForegroundColor Yellow
    $UserProfiles = Get-ChildItem "C:\Users" -Directory -ErrorAction SilentlyContinue
    $OrphanProfiles = $UserProfiles | Where-Object {
        $ProfileName = $_.Name
        -not (Get-LocalUser -Name $ProfileName -ErrorAction SilentlyContinue) -and
        $ProfileName -notin @("Public", "Default", "Default User", "All Users")
    }
    
    if ($OrphanProfiles) {
        $Issues += [PSCustomObject]@{
            Type = "Profils orphelins"
            Count = $OrphanProfiles.Count
            Users = $OrphanProfiles.Name -join ", "
            Action = "Nettoyage recommandé"
        }
    }
    
    # Génération du rapport
    Write-Host "`n📊 RÉSUMÉ DE LA MAINTENANCE" -ForegroundColor Cyan
    Write-Host "="*60
    
    if ($Issues.Count -eq 0) {
        Write-Host "✓ Aucun problème détecté !" -ForegroundColor Green
    } else {
        $Issues | Format-Table -AutoSize
        
        # Générer rapport HTML
        $HtmlReport = @"
<!DOCTYPE html>
<html>
<head>
    <title>Rapport de maintenance - $(Get-Date -Format 'yyyy-MM-dd')</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
        h1 { color: #2c3e50; border-bottom: 3px solid #3498db; padding-bottom: 10px; }
        table { border-collapse: collapse; width: 100%; margin: 20px 0; background-color: white; }
        th { background-color: #3498db; color: white; padding: 12px; text-align: left; }
        td { padding: 10px; border-bottom: 1px solid #ddd; }
        tr:hover { background-color: #f5f5f5; }
        .summary { background-color: white; padding: 15px; margin: 20px 0; border-left: 4px solid #3498db; }
        .footer { margin-top: 30px; color: #7f8c8d; font-size: 12px; }
    </style>
</head>
<body>
    <h1>🔧 Rapport de Maintenance des Comptes Utilisateurs</h1>
    <div class="summary">
        <strong>Date:</strong> $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')<br>
        <strong>Ordinateur:</strong> $($env:COMPUTERNAME)<br>
        <strong>Problèmes détectés:</strong> $($Issues.Count)<br>
        <strong>Mode:</strong> $(if ($AutoFix) { "Correction automatique activée" } else { "Analyse uniquement" })
    </div>
    <h2>Problèmes détectés</h2>
    <table>
        <tr>
            <th>Type</th>
            <th>Nombre</th>
            <th>Utilisateurs</th>
            <th>Action recommandée</th>
        </tr>
        $($Issues | ForEach-Object {
            "<tr><td>$($_.Type)</td><td>$($_.Count)</td><td>$($_.Users)</td><td>$($_.Action)</td></tr>"
        })
    </table>
    <div class="footer">
        Rapport généré automatiquement par PowerShell<br>
        Pour plus d'informations, consultez les logs système
    </div>
</body>
</html>
"@
        
        $HtmlReport | Out-File -FilePath $ReportPath -Encoding UTF8
        Write-Host "`n✓ Rapport HTML généré: $ReportPath" -ForegroundColor Green
    }
    
    Write-Host "`n" "="*60
}

# Exécution
Invoke-UserAccountMaintenance -AutoFix
```

---

## 🎯 Récapitulatif des commandes essentielles

```powershell
# SUPPRESSION
Remove-LocalUser -Name "User1"                    # Suppression simple
Remove-LocalUser -Name "User1" -Confirm           # Avec confirmation
Remove-LocalUser -Name "User1" -WhatIf            # Simulation

# ACTIVATION
Enable-LocalUser -Name "User1"                    # Activation simple
Get-LocalUser -Name "User1" | Enable-LocalUser    # Via pipeline

# DÉSACTIVATION
Disable-LocalUser -Name "User1"                   # Désactivation simple
Disable-LocalUser -Name "User1" -Confirm          # Avec confirmation

# GESTION EN MASSE
Get-LocalUser -Name "temp_*" | Disable-LocalUser  # Désactiver plusieurs
"User1","User2","User3" | Enable-LocalUser        # Activer plusieurs

# VÉRIFICATIONS
Get-LocalUser | Where-Object {-not $_.Enabled}    # Lister désactivés
Get-LocalUser | Select-Object Name, Enabled       # État de tous
```

---