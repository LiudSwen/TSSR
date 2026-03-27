

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

## Introduction

Le déverrouillage de comptes Active Directory est une tâche courante pour les équipes de support informatique. Lorsqu'un utilisateur entre un mot de passe incorrect plusieurs fois, son compte est automatiquement verrouillé pour des raisons de sécurité. PowerShell offre des outils puissants pour gérer ces situations efficacement.

> [!info] Pourquoi c'est important Le verrouillage de comptes est un mécanisme de sécurité essentiel qui protège contre les attaques par force brute. Cependant, les utilisateurs légitimes peuvent aussi être verrouillés par erreur, et savoir gérer ces situations rapidement améliore la productivité et la satisfaction des utilisateurs.

---

## Unlock-ADAccount - Déverrouillage de comptes

La cmdlet `Unlock-ADAccount` permet de déverrouiller un compte utilisateur Active Directory qui a été verrouillé suite à des tentatives de connexion échouées.

### Syntaxe de base

```powershell
# Déverrouillage d'un compte par nom d'utilisateur
Unlock-ADAccount -Identity "jdupont"

# Déverrouillage par Distinguished Name (DN)
Unlock-ADAccount -Identity "CN=Jean Dupont,OU=Utilisateurs,DC=entreprise,DC=local"

# Déverrouillage par SamAccountName
Unlock-ADAccount -Identity "jdupont@entreprise.local"
```

> [!example] Cas d'usage typique
> 
> ```powershell
> # Un utilisateur appelle le helpdesk car il ne peut plus se connecter
> Unlock-ADAccount -Identity "marie.martin"
> 
> # Confirmation du déverrouillage
> Write-Host "Le compte de marie.martin a été déverrouillé avec succès" -ForegroundColor Green
> ```

### Paramètres supplémentaires

```powershell
# Déverrouillage avec spécification du serveur
Unlock-ADAccount -Identity "jdupont" -Server "DC01.entreprise.local"

# Utilisation d'identifiants alternatifs
$creds = Get-Credential
Unlock-ADAccount -Identity "jdupont" -Credential $creds

# Traitement par pipeline
Get-ADUser -Filter {Enabled -eq $true} -SearchBase "OU=Marketing,DC=entreprise,DC=local" | 
    Where-Object {$_.LockedOut -eq $true} | 
    Unlock-ADAccount
```

---

## Identification des utilisateurs avec -Identity

Le paramètre `-Identity` est le cœur de la cmdlet et accepte plusieurs formats pour identifier le compte à déverrouiller.

### Formats acceptés

|Format|Exemple|Utilisation recommandée|
|---|---|---|
|SamAccountName|`"jdupont"`|Le plus courant, simple et rapide|
|Distinguished Name|`"CN=Jean Dupont,OU=Users,DC=corp,DC=com"`|Scripts automatisés, précision maximale|
|UserPrincipalName|`"jdupont@entreprise.local"`|Environnements multi-domaines|
|GUID|`"a1b2c3d4-e5f6-7890-abcd-ef1234567890"`|Référence immuable|
|SID|`"S-1-5-21-..."`|Contextes de sécurité avancés|

```powershell
# Exemple avec différents formats
Unlock-ADAccount -Identity "jdupont"                                    # SamAccountName
Unlock-ADAccount -Identity "CN=Jean Dupont,OU=IT,DC=corp,DC=com"       # DN
Unlock-ADAccount -Identity "jean.dupont@entreprise.local"               # UPN
Unlock-ADAccount -Identity "a1b2c3d4-e5f6-7890-abcd-ef1234567890"      # GUID
```

> [!tip] Astuce Privilégiez le SamAccountName pour les opérations manuelles du helpdesk (plus court et intuitif) et le Distinguished Name pour les scripts automatisés (plus précis et moins d'ambiguïté).

### Récupération dynamique de l'identité

```powershell
# Depuis une variable
$username = "jdupont"
Unlock-ADAccount -Identity $username

# Depuis une liste d'utilisateurs
$users = @("jdupont", "mmartin", "pdubois")
foreach ($user in $users) {
    Unlock-ADAccount -Identity $user
    Write-Host "Compte $user déverrouillé" -ForegroundColor Green
}

# Depuis un fichier CSV
Import-Csv "C:\Scripts\comptes_verrouilles.csv" | ForEach-Object {
    Unlock-ADAccount -Identity $_.SamAccountName
}
```

---

## Comprendre le verrouillage de comptes

Le verrouillage de compte est déclenché automatiquement par Active Directory selon les stratégies de sécurité définies dans les Group Policy Objects (GPO).

### Mécanisme de verrouillage

> [!info] Fonctionnement Lorsqu'un utilisateur entre un mot de passe incorrect un certain nombre de fois (défini par la stratégie), son compte est automatiquement verrouillé pour une durée déterminée ou jusqu'à intervention manuelle d'un administrateur.

### Stratégies de verrouillage typiques

```powershell
# Consultation de la stratégie de verrouillage du domaine
Get-ADDefaultDomainPasswordPolicy

# Propriétés importantes :
# - LockoutThreshold : Nombre de tentatives avant verrouillage (ex: 5)
# - LockoutDuration : Durée du verrouillage (ex: 30 minutes)
# - LockoutObservationWindow : Période de réinitialisation du compteur (ex: 30 minutes)
```

> [!example] Exemple de résultat
> 
> ```
> LockoutThreshold         : 5
> LockoutDuration          : 00:30:00
> LockoutObservationWindow : 00:30:00
> 
> Interprétation :
> - 5 tentatives échouées déclenchent le verrouillage
> - Le compte reste verrouillé pendant 30 minutes
> - Le compteur de tentatives se réinitialise après 30 minutes
> ```

### Causes courantes de verrouillage

|Cause|Description|Solution|
|---|---|---|
|Mot de passe oublié|L'utilisateur entre le mauvais mot de passe|Déverrouillage + réinitialisation|
|Anciennes sessions|Sessions ouvertes avec ancien mot de passe|Fermer toutes les sessions actives|
|Connexions automatiques|Applications/scripts avec identifiants obsolètes|Mettre à jour les identifiants|
|Tâches planifiées|Services Windows avec mot de passe expiré|Vérifier les services et tâches|
|Smartphones/Tablettes|Synchronisation avec ancien mot de passe|Mettre à jour sur les appareils mobiles|
|Lecteurs mappés|Lecteurs réseau avec anciennes credentials|Reconnecter les lecteurs réseau|

```powershell
# Vérification des sessions actives d'un utilisateur
Get-ADUser "jdupont" -Properties * | Select-Object Name, LastLogonDate, LockedOut, LockoutTime

# Vérification des services Windows utilisant un compte
Get-WmiObject Win32_Service | 
    Where-Object {$_.StartName -like "*jdupont*"} | 
    Select-Object Name, StartName, State
```

---

## Vérification de l'état de verrouillage

Avant de déverrouiller un compte, il est essentiel de vérifier son état actuel.

### Propriété LockedOut

La propriété `LockedOut` indique si un compte est actuellement verrouillé (`$true`) ou non (`$false`).

```powershell
# Vérification simple de l'état de verrouillage
Get-ADUser -Identity "jdupont" -Properties LockedOut | Select-Object Name, LockedOut

# Affichage avec mise en forme
$user = Get-ADUser -Identity "jdupont" -Properties LockedOut
if ($user.LockedOut) {
    Write-Host "⛔ Le compte $($user.Name) est VERROUILLÉ" -ForegroundColor Red
} else {
    Write-Host "✅ Le compte $($user.Name) est actif" -ForegroundColor Green
}
```

### Vérification avec -Properties LockedOut,LockoutTime

L'ajout de la propriété `LockoutTime` fournit des informations complémentaires précieuses.

```powershell
# Vérification détaillée
Get-ADUser -Identity "jdupont" -Properties LockedOut, LockoutTime | 
    Select-Object Name, SamAccountName, LockedOut, LockoutTime

# Script de vérification avancé
$user = Get-ADUser -Identity "jdupont" -Properties LockedOut, LockoutTime, BadPwdCount, LastBadPasswordAttempt

[PSCustomObject]@{
    "Utilisateur"              = $user.Name
    "Compte"                   = $user.SamAccountName
    "Verrouillé"              = $user.LockedOut
    "Heure de verrouillage"   = $user.LockoutTime
    "Tentatives échouées"     = $user.BadPwdCount
    "Dernière tentative"      = $user.LastBadPasswordAttempt
} | Format-List
```

> [!example] Exemple de sortie
> 
> ```
> Utilisateur          : Jean Dupont
> Compte               : jdupont
> Verrouillé          : True
> Heure de verrouillage: 16/12/2024 14:35:22
> Tentatives échouées : 5
> Dernière tentative  : 16/12/2024 14:35:22
> ```

### Propriétés utiles pour le diagnostic

```powershell
# Liste complète des propriétés de verrouillage
Get-ADUser -Identity "jdupont" -Properties * | 
    Select-Object Name, 
                  LockedOut, 
                  LockoutTime, 
                  BadPwdCount, 
                  BadLogonCount, 
                  LastBadPasswordAttempt, 
                  PasswordLastSet, 
                  PasswordExpired, 
                  AccountExpirationDate, 
                  Enabled
```

|Propriété|Description|Utilité|
|---|---|---|
|`LockedOut`|État de verrouillage (booléen)|Détection rapide|
|`LockoutTime`|Date/heure du verrouillage|Chronologie|
|`BadPwdCount`|Nombre de tentatives échouées|Analyse des tentatives|
|`LastBadPasswordAttempt`|Dernière tentative échouée|Origine temporelle|
|`PasswordLastSet`|Date du dernier changement de mot de passe|Détection de services obsolètes|
|`BadLogonCount`|Compteur de mauvaises connexions|Analyse de sécurité|

---

## Recherche de comptes verrouillés

La cmdlet `Search-ADAccount` permet de rechercher efficacement tous les comptes verrouillés dans le domaine.

### Syntaxe de base avec Search-ADAccount -LockedOut

```powershell
# Recherche de tous les comptes verrouillés
Search-ADAccount -LockedOut

# Recherche avec sélection de propriétés
Search-ADAccount -LockedOut | 
    Select-Object Name, SamAccountName, DistinguishedName

# Recherche avec comptage
$lockedUsers = Search-ADAccount -LockedOut
Write-Host "Nombre de comptes verrouillés : $($lockedUsers.Count)" -ForegroundColor Yellow
```

### Recherche avancée

```powershell
# Recherche dans une OU spécifique
Search-ADAccount -LockedOut -SearchBase "OU=Utilisateurs,DC=entreprise,DC=local"

# Recherche avec limitation de résultats
Search-ADAccount -LockedOut -ResultSetSize 50

# Recherche avec informations détaillées
Search-ADAccount -LockedOut | 
    Get-ADUser -Properties LockedOut, LockoutTime, LastBadPasswordAttempt, Department | 
    Select-Object Name, 
                  SamAccountName, 
                  Department, 
                  LockoutTime, 
                  LastBadPasswordAttempt |
    Sort-Object LockoutTime -Descending
```

> [!tip] Astuce pour le helpdesk
> 
> ```powershell
> # Création d'un rapport formaté pour le helpdesk
> Search-ADAccount -LockedOut | 
>     Get-ADUser -Properties LockoutTime, Department, EmailAddress | 
>     Select-Object @{N="Utilisateur";E={$_.Name}},
>                   @{N="Compte";E={$_.SamAccountName}},
>                   @{N="Service";E={$_.Department}},
>                   @{N="Email";E={$_.EmailAddress}},
>                   @{N="Verrouillé depuis";E={$_.LockoutTime}} |
>     Format-Table -AutoSize
> ```

### Combinaison avec Get-ADUser

```powershell
# Alternative avec Get-ADUser pour plus de contrôle
Get-ADUser -Filter {LockedOut -eq $true} -Properties LockedOut, LockoutTime

# Recherche avec filtres multiples
Get-ADUser -Filter {(LockedOut -eq $true) -and (Enabled -eq $true)} -Properties *

# Recherche par département
Get-ADUser -Filter {LockedOut -eq $true} -Properties Department | 
    Where-Object {$_.Department -eq "IT"} |
    Select-Object Name, SamAccountName, Department
```

### Export des résultats

```powershell
# Export en CSV pour analyse
Search-ADAccount -LockedOut | 
    Get-ADUser -Properties LockoutTime, LastBadPasswordAttempt, Department | 
    Select-Object Name, SamAccountName, Department, LockoutTime, LastBadPasswordAttempt |
    Export-Csv "C:\Reports\comptes_verrouilles_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv" -NoTypeInformation

# Export en HTML pour rapport
Search-ADAccount -LockedOut | 
    Get-ADUser -Properties LockoutTime, Department | 
    ConvertTo-Html -Property Name, SamAccountName, Department, LockoutTime -Title "Comptes verrouillés" |
    Out-File "C:\Reports\comptes_verrouilles.html"
```

---

## Scripts de surveillance

La surveillance proactive des verrouillages de comptes permet de détecter rapidement les problèmes de sécurité ou les incidents utilisateurs.

### Script de surveillance simple

```powershell
# Script de surveillance basique
$lockedAccounts = Search-ADAccount -LockedOut

if ($lockedAccounts) {
    Write-Host "⚠️ ALERTE : $($lockedAccounts.Count) compte(s) verrouillé(s) détecté(s)" -ForegroundColor Red
    
    foreach ($account in $lockedAccounts) {
        $user = Get-ADUser $account -Properties LockoutTime
        Write-Host "  - $($user.Name) (verrouillé à $($user.LockoutTime))" -ForegroundColor Yellow
    }
} else {
    Write-Host "✅ Aucun compte verrouillé" -ForegroundColor Green
}
```

### Script avec notification par email

```powershell
# Script de surveillance avec alerte email
$lockedAccounts = Search-ADAccount -LockedOut | 
    Get-ADUser -Properties LockoutTime, LastBadPasswordAttempt, Department

if ($lockedAccounts) {
    # Préparation du rapport HTML
    $htmlReport = $lockedAccounts | 
        Select-Object Name, SamAccountName, Department, LockoutTime, LastBadPasswordAttempt |
        ConvertTo-Html -Title "Comptes Active Directory verrouillés" -PreContent "<h2>Alerte : Comptes verrouillés détectés</h2>"
    
    # Paramètres d'envoi d'email
    $mailParams = @{
        From       = "alertes@entreprise.local"
        To         = "helpdesk@entreprise.local"
        Subject    = "🔒 Alerte : $($lockedAccounts.Count) compte(s) verrouillé(s)"
        Body       = $htmlReport | Out-String
        BodyAsHtml = $true
        SmtpServer = "smtp.entreprise.local"
    }
    
    Send-MailMessage @mailParams
    
    Write-Host "Email d'alerte envoyé au helpdesk" -ForegroundColor Yellow
}
```

### Script de surveillance avec historique

```powershell
# Script avec conservation d'historique
$logPath = "C:\Logs\AD_Lockouts"
$logFile = "$logPath\lockout_history.csv"

# Création du dossier de logs si nécessaire
if (-not (Test-Path $logPath)) {
    New-Item -Path $logPath -ItemType Directory | Out-Null
}

# Récupération des comptes verrouillés
$lockedAccounts = Search-ADAccount -LockedOut | 
    Get-ADUser -Properties LockoutTime, LastBadPasswordAttempt, Department, BadPwdCount

# Enrichissement avec timestamp
$lockoutData = $lockedAccounts | Select-Object @{N="DateDetection";E={Get-Date}},
                                                Name,
                                                SamAccountName,
                                                Department,
                                                LockoutTime,
                                                LastBadPasswordAttempt,
                                                BadPwdCount

# Ajout à l'historique
if ($lockoutData) {
    $lockoutData | Export-Csv $logFile -NoTypeInformation -Append
    Write-Host "📝 $($lockoutData.Count) verrouillage(s) ajouté(s) à l'historique" -ForegroundColor Cyan
}
```

### Script de surveillance avec statistiques

```powershell
# Script avec analyse statistique
function Get-LockoutStatistics {
    param(
        [int]$LastDays = 7
    )
    
    # Chargement de l'historique
    $logFile = "C:\Logs\AD_Lockouts\lockout_history.csv"
    
    if (Test-Path $logFile) {
        $history = Import-Csv $logFile
        $startDate = (Get-Date).AddDays(-$LastDays)
        
        # Filtrage sur la période
        $recentLockouts = $history | Where-Object {
            [datetime]$_.DateDetection -gt $startDate
        }
        
        # Statistiques globales
        Write-Host "`n📊 STATISTIQUES DES VERROUILLAGES ($LastDays derniers jours)" -ForegroundColor Cyan
        Write-Host "=" * 60
        Write-Host "Nombre total de verrouillages : $($recentLockouts.Count)"
        Write-Host "Nombre d'utilisateurs distincts : $(($recentLockouts | Select-Object -Unique SamAccountName).Count)"
        
        # Top 5 des utilisateurs les plus verrouillés
        Write-Host "`n🔝 Top 5 des utilisateurs les plus verrouillés :"
        $recentLockouts | 
            Group-Object SamAccountName | 
            Sort-Object Count -Descending | 
            Select-Object -First 5 | 
            ForEach-Object {
                Write-Host "  $($_.Name) : $($_.Count) fois" -ForegroundColor Yellow
            }
        
        # Répartition par service
        Write-Host "`n🏢 Répartition par service :"
        $recentLockouts | 
            Group-Object Department | 
            Sort-Object Count -Descending | 
            ForEach-Object {
                Write-Host "  $($_.Name) : $($_.Count) verrouillage(s)"
            }
        
        # Répartition par heure
        Write-Host "`n🕐 Répartition par heure de la journée :"
        $recentLockouts | 
            ForEach-Object {[datetime]$_.LockoutTime} | 
            Group-Object {$_.Hour} | 
            Sort-Object Name | 
            ForEach-Object {
                Write-Host "  $($_.Name)h : $($_.Count) verrouillage(s)"
            }
    } else {
        Write-Host "❌ Aucun historique trouvé" -ForegroundColor Red
    }
}

# Utilisation
Get-LockoutStatistics -LastDays 7
```

> [!warning] Attention aux performances Les scripts de surveillance qui s'exécutent fréquemment (toutes les 5 minutes par exemple) doivent être optimisés pour ne pas surcharger les contrôleurs de domaine. Privilégiez `Search-ADAccount -LockedOut` plutôt que `Get-ADUser -Filter *` pour de meilleures performances.

### Tâche planifiée de surveillance

```powershell
# Création d'une tâche planifiée pour surveillance automatique
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" `
    -Argument "-NoProfile -ExecutionPolicy Bypass -File C:\Scripts\Monitor-LockedAccounts.ps1"

$trigger = New-ScheduledTaskTrigger -Once -At (Get-Date) -RepetitionInterval (New-TimeSpan -Minutes 15)

$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest

$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries

Register-ScheduledTask -TaskName "AD-Monitor-LockedAccounts" `
    -Action $action `
    -Trigger $trigger `
    -Principal $principal `
    -Settings $settings `
    -Description "Surveillance des comptes AD verrouillés toutes les 15 minutes"
```

---

## Support Helpdesk

Les équipes de support helpdesk sont les principales utilisatrices des commandes de déverrouillage. Voici les meilleures pratiques et outils pour faciliter leur travail.

### Script interactif pour le helpdesk

```powershell
# Script helpdesk convivial
function Unlock-UserAccount {
    [CmdletBinding()]
    param()
    
    Write-Host "`n🔓 OUTIL DE DÉVERROUILLAGE DE COMPTES" -ForegroundColor Cyan
    Write-Host "=" * 50 "`n"
    
    # Demande du nom d'utilisateur
    $username = Read-Host "Entrez le nom d'utilisateur (SamAccountName)"
    
    try {
        # Récupération des informations du compte
        $user = Get-ADUser -Identity $username -Properties LockedOut, LockoutTime, BadPwdCount, LastBadPasswordAttempt, Department, EmailAddress -ErrorAction Stop
        
        # Affichage des informations
        Write-Host "`n📋 Informations du compte :" -ForegroundColor Yellow
        Write-Host "  Nom complet      : $($user.Name)"
        Write-Host "  Compte           : $($user.SamAccountName)"
        Write-Host "  Service          : $($user.Department)"
        Write-Host "  Email            : $($user.EmailAddress)"
        Write-Host "  Compte actif     : $($user.Enabled)"
        Write-Host "  État verrouillé  : $($user.LockedOut)"
        
        if ($user.LockedOut) {
            Write-Host "  Verrouillé depuis: $($user.LockoutTime)" -ForegroundColor Red
            Write-Host "  Tentatives       : $($user.BadPwdCount)"
            Write-Host "  Dernière tentative: $($user.LastBadPasswordAttempt)"
            
            # Confirmation du déverrouillage
            $confirm = Read-Host "`n⚠️  Voulez-vous déverrouiller ce compte ? (O/N)"
            
            if ($confirm -eq "O") {
                Unlock-ADAccount -Identity $username
                Write-Host "`n✅ Compte déverrouillé avec succès !" -ForegroundColor Green
                
                # Vérification
                $userCheck = Get-ADUser -Identity $username -Properties LockedOut
                Write-Host "  État actuel : Verrouillé = $($userCheck.LockedOut)"
                
                # Log de l'action
                $logEntry = "[$(Get-Date)] Compte $username déverrouillé par $env:USERNAME"
                Add-Content -Path "C:\Logs\helpdesk_unlocks.log" -Value $logEntry
                
            } else {
                Write-Host "`n❌ Opération annulée" -ForegroundColor Yellow
            }
        } else {
            Write-Host "`n✅ Ce compte n'est pas verrouillé" -ForegroundColor Green
        }
        
    } catch {
        Write-Host "`n❌ ERREUR : Utilisateur '$username' introuvable" -ForegroundColor Red
        Write-Host "  Vérifiez l'orthographe du nom d'utilisateur"
    }
    
    Write-Host "`n" ("-" * 50) "`n"
}

# Utilisation
Unlock-UserAccount
```

### Menu interactif complet

```powershell
# Menu principal pour le helpdesk
function Show-HelpdeskMenu {
    do {
        Clear-Host
        Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
        Write-Host "║   HELPDESK - GESTION DES COMPTES AD    ║" -ForegroundColor Cyan
        Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "  1. 🔓 Déverrouiller un compte"
        Write-Host "  2. 📋 Lister les comptes verrouillés"
        Write-Host "  3. 🔍 Vérifier l'état d'un compte"
        Write-Host "  4. 📊 Statistiques de verrouillages"
        Write-Host "  5. 🔄 Déverrouiller plusieurs comptes"
        Write-Host "  6. ❌ Quitter"
        Write-Host ""
        
        $choice = Read-Host "Choisissez une option (1-6)"
        
        switch ($choice) {
            "1" {
                # Déverrouillage simple
                $username = Read-Host "`nNom d'utilisateur"
                try {
                    $user = Get-ADUser $username -Properties LockedOut
                    if ($user.LockedOut) {
                        Unlock-ADAccount -Identity $username
                        Write-Host "✅ Compte $username déverrouillé" -ForegroundColor Green
                    } else {
                        Write-Host "ℹ️  Le compte n'est pas verrouillé" -ForegroundColor Yellow
                    }
                } catch {
                    Write-Host "❌ Erreur : $($_.Exception.Message)" -ForegroundColor Red
                }
                Read-Host "`nAppuyez sur Entrée pour continuer"
            }
            "2" {
                # Liste des comptes verrouillés
                Write-Host "`n🔒 Comptes actuellement verrouillés :" -ForegroundColor Yellow
                Search-ADAccount -LockedOut | 
                    Get-ADUser -Properties LockoutTime, Department | 
                    Format-Table Name, SamAccountName, Department, LockoutTime -AutoSize
                Read-Host "`nAppuyez sur Entrée pour continuer"
            }
            "3" {
                # Vérification d'état
                $username = Read-Host "`nNom d'utilisateur"
                Get-ADUser $username -Properties LockedOut, LockoutTime, BadPwdCount, LastBadPasswordAttempt | 
                    Format-List Name, SamAccountName, LockedOut, LockoutTime, BadPwdCount, LastBadPasswordAttempt
                Read-Host "`nAppuyez sur Entrée pour continuer"
            }
            "4" {
                # Statistiques
                $locked = Search-ADAccount -LockedOut
                Write-Host "`n📊 Statistiques :" -ForegroundColor Cyan
                Write-Host "  Comptes verrouillés : $($locked.Count)"
                Read-Host "`nAppuyez sur Entrée pour continuer"
            }
            "5" {
                # Déverrouillage multiple
                Write-Host "`n🔄 Déverrouillage de tous les comptes verrouillés" -ForegroundColor Yellow
                $confirm = Read-Host "⚠️  Confirmer ? (O/N)"
                if ($confirm -eq "O") {
                    $count = 0
                    Search-ADAccount -LockedOut | ForEach-Object {
                        Unlock-ADAccount -Identity $_.SamAccountName
                        Write-Host "  ✓ $($_.Name)" -ForegroundColor Green
                        $count++
                    }
                    Write-Host "`n✅ $count compte(s) déverrouillé(s)" -ForegroundColor Green
                }
                Read-Host "`nAppuyez sur Entrée pour continuer"
            }
            "6" {
                Write-Host "`n👋 Au revoir !" -ForegroundColor Green
                return
            }
            default {
                Write-Host "`n❌ Choix invalide" -ForegroundColor Red
                Start-Sleep -Seconds 2
            }
        }
    } while ($true)
}

# Lancement du menu
Show-HelpdeskMenu
```

### Modèle de ticket helpdesk

```powershell
# Génération automatique de ticket lors du déverrouillage
function New-UnlockTicket {
    param(
        [string]$Username,
        [string]$TechnicianName = $env:USERNAME
    )
    
    $user = Get-ADUser $Username -Properties LockedOut, LockoutTime, Department, EmailAddress
    
    $ticket = @"
=====================================
TICKET DE DÉVERROUILLAGE DE COMPTE
=====================================
Date/Heure    : $(Get-Date -Format "dd/MM/yyyy HH:mm:ss")
Technicien    : $TechnicianName
Utilisateur   : $($user.Name)
Compte        : $($user.SamAccountName)
Service       : $($user.Department)
Email         : $($user.EmailAddress)
Verrouillé à  : $($user.LockoutTime)
Action        : Compte déverrouillé
Remarques     : Utilisateur informé de changer son mot de passe si nécessaire
=====================================
"@
    
    # Sauvegarde du ticket
    $ticketPath = "C:\Helpdesk\Tickets"
    if (-not (Test-Path $ticketPath)) {
        New-Item -Path $ticketPath -ItemType Directory | Out-Null
    }
    
    $ticketFile = "$ticketPath\Unlock_$($Username)_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
    $ticket | Out-File $ticketFile
    
    Write-Host $ticket
    Write-Host "`n📄 Ticket sauvegardé : $ticketFile" -ForegroundColor Cyan
}
```

### Script de déverrouillage avec notifications

```powershell
# Déverrouillage avec notification à l'utilisateur
function Unlock-AndNotifyUser {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Username
    )
    
    try {
        # Récupération des informations
        $user = Get-ADUser $Username -Properties LockedOut, EmailAddress, DisplayName -ErrorAction Stop
        
        if ($user.LockedOut) {
            # Déverrouillage
            Unlock-ADAccount -Identity $Username
            
            # Envoi d'email à l'utilisateur
            if ($user.EmailAddress) {
                $mailParams = @{
                    From       = "helpdesk@entreprise.local"
                    To         = $user.EmailAddress
                    Subject    = "Votre compte a été déverrouillé"
                    Body       = @"
Bonjour $($user.DisplayName),

Votre compte Active Directory a été déverrouillé par le service Helpdesk.

Vous pouvez maintenant vous reconnecter à vos applications.

Si vous continuez à rencontrer des problèmes :
- Vérifiez que vous utilisez le bon mot de passe
- Fermez toutes les sessions ouvertes (Outlook, VPN, etc.)
- Mettez à jour vos identifiants sur vos appareils mobiles

En cas de besoin, contactez le Helpdesk au : 01.XX.XX.XX.XX

Cordialement,
L'équipe Helpdesk
"@
                    SmtpServer = "smtp.entreprise.local"
                }
                
                Send-MailMessage @mailParams
                Write-Host "✅ Compte déverrouillé et email envoyé à $($user.EmailAddress)" -ForegroundColor Green
            } else {
                Write-Host "✅ Compte déverrouillé (pas d'email configuré)" -ForegroundColor Yellow
            }
        } else {
            Write-Host "ℹ️  Le compte n'était pas verrouillé" -ForegroundColor Cyan
        }
        
    } catch {
        Write-Host "❌ Erreur : $($_.Exception.Message)" -ForegroundColor Red
    }
}
```

---

## Logs et Event Viewer

Les événements de verrouillage sont enregistrés dans les journaux Windows, permettant une analyse détaillée des incidents.

### Événements de sécurité importants

|Event ID|Description|Emplacement|Utilité|
|---|---|---|---|
|**4740**|Compte verrouillé|Security Log (DC)|Identification du verrouillage|
|**4625**|Échec de connexion|Security Log (DC)|Tentatives échouées|
|**4767**|Compte déverrouillé|Security Log (DC)|Historique des déverrouillages|
|**4768**|Ticket Kerberos demandé|Security Log (DC)|Authentification Kerberos|
|**4776**|Validation des identifiants|Security Log (DC)|Authentification NTLM|

### Consultation des logs avec PowerShell

```powershell
# Recherche des événements de verrouillage (Event ID 4740)
Get-WinEvent -FilterHashtable @{
    LogName = 'Security'
    Id = 4740
} -MaxEvents 50 | 
Select-Object TimeCreated, 
              @{N="Compte";E={$_.Properties[0].Value}},
              @{N="Ordinateur";E={$_.Properties[1].Value}} |
Format-Table -AutoSize

# Recherche des échecs de connexion (Event ID 4625)
Get-WinEvent -FilterHashtable @{
    LogName = 'Security'
    Id = 4625
} -MaxEvents 100 |
Select-Object TimeCreated,
              @{N="Compte";E={$_.Properties[5].Value}},
              @{N="Station";E={$_.Properties[13].Value}},
              @{N="IP Source";E={$_.Properties[19].Value}}
```

### Script d'analyse des événements de verrouillage

```powershell
# Analyse complète des événements de verrouillage
function Get-LockoutEvents {
    param(
        [string]$Username,
        [int]$LastHours = 24
    )
    
    $startTime = (Get-Date).AddHours(-$LastHours)
    
    Write-Host "`n🔍 ANALYSE DES ÉVÉNEMENTS DE VERROUILLAGE" -ForegroundColor Cyan
    Write-Host "Utilisateur : $Username"
    Write-Host "Période : Dernières $LastHours heures"
    Write-Host "=" * 60
    
    # Événements de verrouillage (4740)
    Write-Host "`n🔒 Événements de verrouillage :" -ForegroundColor Yellow
    $lockoutEvents = Get-WinEvent -FilterHashtable @{
        LogName = 'Security'
        Id = 4740
        StartTime = $startTime
    } -ErrorAction SilentlyContinue |
    Where-Object {$_.Properties[0].Value -eq $Username}
    
    if ($lockoutEvents) {
        foreach ($event in $lockoutEvents) {
            Write-Host "  $(Get-Date $event.TimeCreated -Format 'dd/MM/yyyy HH:mm:ss') - Verrouillé depuis $($event.Properties[1].Value)"
        }
    } else {
        Write-Host "  Aucun événement de verrouillage trouvé"
    }
    
    # Échecs de connexion (4625)
    Write-Host "`n❌ Échecs de connexion :" -ForegroundColor Red
    $failedLogons = Get-WinEvent -FilterHashtable @{
        LogName = 'Security'
        Id = 4625
        StartTime = $startTime
    } -ErrorAction SilentlyContinue |
    Where-Object {$_.Properties[5].Value -eq $Username}
    
    if ($failedLogons) {
        $grouped = $failedLogons | 
            Group-Object @{E={$_.Properties[13].Value}} | 
            Sort-Object Count -Descending
        
        foreach ($group in $grouped) {
            Write-Host "  $($group.Name) : $($group.Count) tentative(s)"
        }
        
        Write-Host "`n  Total : $($failedLogons.Count) échec(s) de connexion"
    } else {
        Write-Host "  Aucun échec de connexion trouvé"
    }
    
    # Déverrouillages (4767)
    Write-Host "`n🔓 Événements de déverrouillage :" -ForegroundColor Green
    $unlockEvents = Get-WinEvent -FilterHashtable @{
        LogName = 'Security'
        Id = 4767
        StartTime = $startTime
    } -ErrorAction SilentlyContinue |
    Where-Object {$_.Properties[0].Value -eq $Username}
    
    if ($unlockEvents) {
        foreach ($event in $unlockEvents) {
            Write-Host "  $(Get-Date $event.TimeCreated -Format 'dd/MM/yyyy HH:mm:ss') - Déverrouillé par $($event.Properties[4].Value)"
        }
    } else {
        Write-Host "  Aucun événement de déverrouillage trouvé"
    }
}

# Utilisation
Get-LockoutEvents -Username "jdupont" -LastHours 48
```

### Recherche sur tous les contrôleurs de domaine

```powershell
# Recherche d'événements sur tous les DCs
function Search-LockoutEventsAllDCs {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Username,
        [int]$LastHours = 24
    )
    
    $startTime = (Get-Date).AddHours(-$LastHours)
    $dcs = Get-ADDomainController -Filter *
    
    Write-Host "`n🌐 Recherche sur tous les contrôleurs de domaine..." -ForegroundColor Cyan
    
    foreach ($dc in $dcs) {
        Write-Host "`n📡 $($dc.HostName)" -ForegroundColor Yellow
        
        try {
            $events = Get-WinEvent -ComputerName $dc.HostName -FilterHashtable @{
                LogName = 'Security'
                Id = 4740
                StartTime = $startTime
            } -ErrorAction Stop |
            Where-Object {$_.Properties[0].Value -eq $Username}
            
            if ($events) {
                foreach ($event in $events) {
                    Write-Host "  ⚠️  Verrouillage détecté à $(Get-Date $event.TimeCreated -Format 'HH:mm:ss')" -ForegroundColor Red
                    Write-Host "     Source : $($event.Properties[1].Value)"
                }
            } else {
                Write-Host "  ✓ Aucun événement" -ForegroundColor Green
            }
        } catch {
            Write-Host "  ❌ Erreur d'accès aux logs" -ForegroundColor Red
        }
    }
}
```

### Export des logs pour analyse

```powershell
# Export des événements de sécurité liés aux verrouillages
function Export-LockoutLogs {
    param(
        [int]$LastDays = 7,
        [string]$OutputPath = "C:\Reports\LockoutLogs_$(Get-Date -Format 'yyyyMMdd').csv"
    )
    
    $startTime = (Get-Date).AddDays(-$LastDays)
    
    # Collecte des événements
    $events = Get-WinEvent -FilterHashtable @{
        LogName = 'Security'
        Id = 4740, 4625, 4767
        StartTime = $startTime
    } -ErrorAction SilentlyContinue
    
    # Transformation en objets structurés
    $results = foreach ($event in $events) {
        $eventType = switch ($event.Id) {
            4740 { "Verrouillage" }
            4625 { "Échec connexion" }
            4767 { "Déverrouillage" }
        }
        
        [PSCustomObject]@{
            DateHeure    = $event.TimeCreated
            Type         = $eventType
            EventID      = $event.Id
            Utilisateur  = $event.Properties[0].Value
            Source       = if ($event.Properties.Count -gt 1) {$event.Properties[1].Value} else {"N/A"}
            Ordinateur   = $event.MachineName
        }
    }
    
    # Export
    $results | Export-Csv $OutputPath -NoTypeInformation -Encoding UTF8
    Write-Host "✅ Logs exportés vers : $OutputPath" -ForegroundColor Green
    Write-Host "   $($results.Count) événements exportés" -ForegroundColor Cyan
}
```

---

## Analyse des tentatives de connexion

L'analyse des tentatives de connexion permet d'identifier les sources de verrouillages et les potentielles menaces de sécurité.

### Identification de la source du verrouillage

```powershell
# Identification de la source du dernier verrouillage
function Find-LockoutSource {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Username
    )
    
    Write-Host "`n🔎 RECHERCHE DE LA SOURCE DU VERROUILLAGE" -ForegroundColor Cyan
    Write-Host "Utilisateur : $Username"
    Write-Host "=" * 60
    
    # Recherche sur le DC qui maintient le rôle PDC Emulator
    $pdcEmulator = Get-ADDomain | Select-Object -ExpandProperty PDCEmulator
    Write-Host "`nAnalyse sur le PDC Emulator : $pdcEmulator" -ForegroundColor Yellow
    
    # Récupération de l'événement de verrouillage le plus récent
    $lockoutEvent = Get-WinEvent -ComputerName $pdcEmulator -FilterHashtable @{
        LogName = 'Security'
        Id = 4740
    } -MaxEvents 100 -ErrorAction SilentlyContinue |
    Where-Object {$_.Properties[0].Value -eq $Username} |
    Select-Object -First 1
    
    if ($lockoutEvent) {
        Write-Host "`n🔒 Dernier verrouillage :" -ForegroundColor Red
        Write-Host "  Date/Heure : $(Get-Date $lockoutEvent.TimeCreated -Format 'dd/MM/yyyy HH:mm:ss')"
        Write-Host "  Source : $($lockoutEvent.Properties[1].Value)"
        
        # Recherche des échecs de connexion associés
        $failedAttempts = Get-WinEvent -ComputerName $pdcEmulator -FilterHashtable @{
            LogName = 'Security'
            Id = 4625
            StartTime = $lockoutEvent.TimeCreated.AddMinutes(-5)
            EndTime = $lockoutEvent.TimeCreated
        } -ErrorAction SilentlyContinue |
        Where-Object {$_.Properties[5].Value -eq $Username}
        
        if ($failedAttempts) {
            Write-Host "`n❌ Tentatives échouées avant le verrouillage :" -ForegroundColor Yellow
            
            $failedAttempts | ForEach-Object {
                $workstation = $_.Properties[13].Value
                $ipAddress = $_.Properties[19].Value
                $time = Get-Date $_.TimeCreated -Format 'HH:mm:ss'
                
                Write-Host "  $time - Station: $workstation - IP: $ipAddress"
            }
            
            # Analyse des sources
            Write-Host "`n📊 Répartition par source :" -ForegroundColor Cyan
            $failedAttempts | 
                Group-Object {$_.Properties[13].Value} |
                Sort-Object Count -Descending |
                ForEach-Object {
                    Write-Host "  $($_.Name) : $($_.Count) tentative(s)"
                }
        }
    } else {
        Write-Host "`n❌ Aucun événement de verrouillage trouvé" -ForegroundColor Red
    }
}

# Utilisation
Find-LockoutSource -Username "jdupont"
```

### Détection de patterns suspects

```powershell
# Analyse des patterns de verrouillage suspects
function Get-SuspiciousLockoutPatterns {
    param(
        [int]$LastDays = 7,
        [int]$ThresholdCount = 3
    )
    
    $startTime = (Get-Date).AddDays(-$LastDays)
    
    Write-Host "`n🚨 DÉTECTION DE PATTERNS SUSPECTS" -ForegroundColor Red
    Write-Host "Période : $LastDays derniers jours"
    Write-Host "Seuil : $ThresholdCount verrouillages"
    Write-Host "=" * 60
    
    # Récupération des événements de verrouillage
    $lockouts = Get-WinEvent -FilterHashtable @{
        LogName = 'Security'
        Id = 4740
        StartTime = $startTime
    } -ErrorAction SilentlyContinue
    
    # Analyse par utilisateur
    Write-Host "`n👤 Utilisateurs avec verrouillages multiples :" -ForegroundColor Yellow
    $userLockouts = $lockouts | 
        Group-Object {$_.Properties[0].Value} |
        Where-Object {$_.Count -ge $ThresholdCount} |
        Sort-Object Count -Descending
    
    foreach ($group in $userLockouts) {
        Write-Host "  ⚠️  $($group.Name) : $($group.Count) verrouillage(s)" -ForegroundColor Red
        
        # Sources multiples ?
        $sources = $group.Group | 
            Group-Object {$_.Properties[1].Value}
        
        if ($sources.Count -gt 1) {
            Write-Host "     💡 Sources multiples détectées :" -ForegroundColor Cyan
            foreach ($source in $sources) {
                Write-Host "        - $($source.Name) : $($source.Count) fois"
            }
        }
    }
    
    # Analyse par source (machine)
    Write-Host "`n💻 Sources avec verrouillages multiples :" -ForegroundColor Yellow
    $sourceLockouts = $lockouts | 
        Group-Object {$_.Properties[1].Value} |
        Where-Object {$_.Count -ge $ThresholdCount} |
        Sort-Object Count -Descending
    
    foreach ($group in $sourceLockouts) {
        Write-Host "  ⚠️  $($group.Name) : $($group.Count) verrouillage(s)" -ForegroundColor Red
        
        # Utilisateurs multiples ?
        $users = $group.Group | 
            Group-Object {$_.Properties[0].Value}
        
        if ($users.Count -gt 1) {
            Write-Host "     💡 Utilisateurs multiples affectés : $($users.Count)" -ForegroundColor Cyan
            Write-Host "     ⚠️  ALERTE : Possible attaque depuis cette machine !" -ForegroundColor Red
        }
    }
    
    # Verrouillages en dehors des heures ouvrables
    Write-Host "`n🌙 Verrouillages en dehors des heures ouvrables :" -ForegroundColor Yellow
    $afterHours = $lockouts | Where-Object {
        $hour = $_.TimeCreated.Hour
        $hour -lt 7 -or $hour -gt 19
    }
    
    if ($afterHours) {
        Write-Host "  $($afterHours.Count) verrouillage(s) détecté(s) en dehors des heures (7h-19h)"
        $afterHours | 
            Group-Object {$_.Properties[0].Value} |
            ForEach-Object {
                Write-Host "    - $($_.Name) : $($_.Count) fois"
            }
    } else {
        Write-Host "  ✓ Aucun verrouillage suspect hors heures ouvrables"
    }
}

# Utilisation
Get-SuspiciousLockoutPatterns -LastDays 7 -ThresholdCount 3
```

### Analyse des adresses IP sources

```powershell
# Analyse des IPs sources des tentatives échouées
function Analyze-FailedLogonIPs {
    param(
        [string]$Username,
        [int]$LastHours = 24
    )
    
    $startTime = (Get-Date).AddHours(-$LastHours)
    
    Write-Host "`n🌐 ANALYSE DES ADRESSES IP SOURCES" -ForegroundColor Cyan
    Write-Host "Utilisateur : $Username"
    Write-Host "=" * 60
    
    # Récupération des échecs de connexion
    $failedLogons = Get-WinEvent -FilterHashtable @{
        LogName = 'Security'
        Id = 4625
        StartTime = $startTime
    } -ErrorAction SilentlyContinue |
    Where-Object {$_.Properties[5].Value -eq $Username}
    
    if ($failedLogons) {
        # Extraction des IPs
        $ipStats = $failedLogons | 
            ForEach-Object {
                [PSCustomObject]@{
                    Time = $_.TimeCreated
                    IP = $_.Properties[19].Value
                    Workstation = $_.Properties[13].Value
                }
            } |
            Group-Object IP |
            Sort-Object Count -Descending
        
        Write-Host "`n📊 Statistiques par IP :" -ForegroundColor Yellow
        foreach ($ipGroup in $ipStats) {
            Write-Host "  IP: $($ipGroup.Name)"
            Write-Host "    Tentatives : $($ipGroup.Count)"
            Write-Host "    Stations   : $($ipGroup.Group.Workstation | Select-Object -Unique)"
            Write-Host "    Première   : $(($ipGroup.Group | Sort-Object Time)[0].Time)"
            Write-Host "    Dernière   : $(($ipGroup.Group | Sort-Object Time -Descending)[0].Time)"
            Write-Host ""
        }
        
        # Alertes
        $suspiciousIPs = $ipStats | Where-Object {$_.Count -ge 10}
        if ($suspiciousIPs) {
            Write-Host "⚠️  ALERTE : IPs suspectes (10+ tentatives) :" -ForegroundColor Red
            foreach ($ip in $suspiciousIPs) {
                Write-Host "  🚨 $($ip.Name) - $($ip.Count) tentatives" -ForegroundColor Red
            }
        }
    } else {
        Write-Host "`n✅ Aucune tentative échouée trouvée" -ForegroundColor Green
    }
}
```

---

## Sécurité et vérification

Avant de déverrouiller un compte, il est crucial de vérifier la légitimité de la demande et d'investiguer les causes du verrouillage.

### Liste de vérification de sécurité

> [!warning] Procédure de sécurité obligatoire Avant tout déverrouillage, le technicien DOIT :
> 
> 1. ✅ Vérifier l'identité de la personne qui demande le déverrouillage
> 2. ✅ Consulter l'historique des verrouillages (récurrence ?)
> 3. ✅ Identifier la source du verrouillage
> 4. ✅ Vérifier les tentatives de connexion récentes
> 5. ✅ S'assurer qu'il ne s'agit pas d'une attaque en cours

### Script de vérification avant déverrouillage

```powershell
# Vérification complète avant déverrouillage
function Test-BeforeUnlock {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Username
    )
    
    Write-Host "`n🔐 VÉRIFICATION DE SÉCURITÉ AVANT DÉVERROUILLAGE" -ForegroundColor Cyan
    Write-Host "Utilisateur : $Username"
    Write-Host "=" * 70
    
    $securityIssues = @()
    $warnings = @()
    
    try {
        # 1. Informations du compte
        $user = Get-ADUser $Username -Properties LockedOut, LockoutTime, BadPwdCount, LastBadPasswordAttempt, PasswordLastSet, Enabled, Department -ErrorAction Stop
        
        Write-Host "`n📋 1. INFORMATIONS DU COMPTE" -ForegroundColor Yellow
        Write-Host "  Nom         : $($user.Name)"
        Write-Host "  Service     : $($user.Department)"
        Write-Host "  Actif       : $($user.Enabled)"
        Write-Host "  Verrouillé  : $($user.LockedOut)"
        
        if (-not $user.Enabled) {
            $securityIssues += "Le compte est désactivé"
        }
        
        # 2. Historique des verrouillages
        Write-Host "`n📊 2. HISTORIQUE DES VERROUILLAGES (7 derniers jours)" -ForegroundColor Yellow
        $startTime = (Get-Date).AddDays(-7)
        $lockoutHistory = Get-WinEvent -FilterHashtable @{
            LogName = 'Security'
            Id = 4740
            StartTime = $startTime
        } -ErrorAction SilentlyContinue |
        Where-Object {$_.Properties[0].Value -eq $Username}
        
        if ($lockoutHistory) {
            Write-Host "  ⚠️  $($lockoutHistory.Count) verrouillage(s) dans les 7 derniers jours" -ForegroundColor Yellow
            
            if ($lockoutHistory.Count -ge 5) {
                $securityIssues += "Verrouillages récurrents ($($lockoutHistory.Count) en 7 jours)"
            } elseif ($lockoutHistory.Count -ge 3) {
                $warnings += "Plusieurs verrouillages récents"
            }
            
            $lockoutHistory | Select-Object -First 3 | ForEach-Object {
                Write-Host "    - $(Get-Date $_.TimeCreated -Format 'dd/MM HH:mm') depuis $($_.Properties[1].Value)"
            }
        } else {
            Write-Host "  ✓ Premier verrouillage" -ForegroundColor Green
        }
        
        # 3. Analyse des tentatives récentes
        Write-Host "`n🔍 3. TENTATIVES DE CONNEXION (dernière heure)" -ForegroundColor Yellow
        $recentAttempts = Get-WinEvent -FilterHashtable @{
            LogName = 'Security'
            Id = 4625
            StartTime = (Get-Date).AddHours(-1)
        } -ErrorAction SilentlyContinue |
        Where-Object {$_.Properties[5].Value -eq $Username}
        
        if ($recentAttempts) {
            Write-Host "  $($recentAttempts.Count) tentative(s) échouée(s) dans la dernière heure"
            
            # Sources multiples ?
            $sources = $recentAttempts | Group-Object {$_.Properties[13].Value}
            if ($sources.Count -gt 3) {
                $securityIssues += "Sources multiples ($($sources.Count) machines différentes)"
                Write-Host "  🚨 ALERTE : $($sources.Count) machines différentes" -ForegroundColor Red
            }
            
            # IPs uniques
            $ips = $recentAttempts | Group-Object {$_.Properties[19].Value}
            if ($ips.Count -gt 1) {
                Write-Host "  📍 IPs détectées :"
                $ips | ForEach-Object {
                    Write-Host "    - $($_.Name) : $($_.Count) tentative(s)"
                }
            }
        } else {
            Write-Host "  ✓ Aucune tentative récente" -ForegroundColor Green
        }
        
        # 4. Âge du mot de passe
        Write-Host "`n🔑 4. ÉTAT DU MOT DE PASSE" -ForegroundColor Yellow
        if ($user.PasswordLastSet) {
            $passwordAge = (Get-Date) - $user.PasswordLastSet
            Write-Host "  Dernier changement : $($user.PasswordLastSet.ToString('dd/MM/yyyy'))"
            Write-Host "  Âge : $([math]::Round($passwordAge.TotalDays)) jours"
            
            if ($passwordAge.TotalDays -gt 180) {
                $warnings += "Mot de passe ancien (> 180 jours)"
            }
        }
        
        # 5. Tentatives en dehors des heures ouvrables
        Write-Host "`n🌙 5. TENTATIVES HORS HEURES OUVRABLES" -ForegroundColor Yellow
        $afterHoursAttempts = $recentAttempts | Where-Object {
            $hour = $_.TimeCreated.Hour
            $hour -lt 7 -or $hour -gt 19
        }
        
        if ($afterHoursAttempts) {
            $securityIssues += "Tentatives hors heures ouvrables ($($afterHoursAttempts.Count))"
            Write-Host "  🚨 $($afterHoursAttempts.Count) tentative(s) hors heures (7h-19h)" -ForegroundColor Red
        } else {
            Write-Host "  ✓ Toutes les tentatives pendant heures ouvrables" -ForegroundColor Green
        }
        
        # RÉSUMÉ ET RECOMMANDATION
        Write-Host "`n" ("=" * 70)
        Write-Host "📝 RÉSUMÉ DE L'ÉVALUATION" -ForegroundColor Cyan
        Write-Host ("=" * 70)
        
        if ($securityIssues.Count -gt 0) {
            Write-Host "`n🚨 PROBLÈMES DE SÉCURITÉ DÉTECTÉS :" -ForegroundColor Red
            foreach ($issue in $securityIssues) {
                Write-Host "  ❌ $issue" -ForegroundColor Red
            }
            Write-Host "`n⛔ RECOMMANDATION : NE PAS DÉVERROUILLER SANS INVESTIGATION APPROFONDIE" -ForegroundColor Red
            Write-Host "   Actions requises :" -ForegroundColor Yellow
            Write-Host "   1. Contacter l'utilisateur pour vérifier son identité"
            Write-Host "   2. Analyser les logs en détail"
            Write-Host "   3. Vérifier les services/applications utilisant ce compte"
            Write-Host "   4. Envisager un changement de mot de passe obligatoire"
            return $false
        } elseif ($warnings.Count -gt 0) {
            Write-Host "`n⚠️  AVERTISSEMENTS :" -ForegroundColor Yellow
            foreach ($warning in $warnings) {
                Write-Host "  ⚠️  $warning" -ForegroundColor Yellow
            }
            Write-Host "`n✅ RECOMMANDATION : Déverrouillage possible AVEC PRÉCAUTIONS" -ForegroundColor Yellow
            Write-Host "   Actions recommandées :" -ForegroundColor Cyan
            Write-Host "   1. Confirmer l'identité de l'utilisateur"
            Write-Host "   2. Demander à l'utilisateur de changer son mot de passe"
            Write-Host "   3. Vérifier ses appareils/applications"
            return $true
        } else {
            Write-Host "`n✅ AUCUN PROBLÈME DÉTECTÉ" -ForegroundColor Green
            Write-Host "   Le déverrouillage peut être effectué en toute sécurité" -ForegroundColor Green
            return $true
        }
        
    } catch {
        Write-Host "`n❌ ERREUR : $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Utilisation avec décision automatique
$canUnlock = Test-BeforeUnlock -Username "jdupont"

if ($canUnlock) {
    $confirm = Read-Host "`nProcéder au déverrouillage ? (O/N)"
    if ($confirm -eq "O") {
        Unlock-ADAccount -Identity "jdupont"
        Write-Host "✅ Compte déverrouillé" -ForegroundColor Green
    }
}
```

### Checklist de vérification manuelle

```powershell
# Génération d'une checklist de vérification
function New-UnlockChecklist {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Username,
        [Parameter(Mandatory=$true)]
        [string]$TechnicianName
    )
    
    $checklist = @"
╔══════════════════════════════════════════════════════════════════╗
║         CHECKLIST DE VÉRIFICATION AVANT DÉVERROUILLAGE           ║
╚══════════════════════════════════════════════════════════════════╝

Date/Heure : $(Get-Date -Format "dd/MM/yyyy HH:mm:ss")
Technicien : $TechnicianName
Utilisateur : $Username

┌─────────────────────────────────────────────────────────────────┐
│ 1. VÉRIFICATION D'IDENTITÉ                                       │
└─────────────────────────────────────────────────────────────────┘
[ ] L'utilisateur a fourni au moins 2 éléments d'identification :
    [ ] Numéro d'employé
    [ ] Date de naissance
    [ ] Service/Département
    [ ] Manager/Supérieur
    [ ] Dernière connexion connue

┌─────────────────────────────────────────────────────────────────┐
│ 2. ANALYSE TECHNIQUE                                             │
└─────────────────────────────────────────────────────────────────┘
[ ] Compte actif dans AD
[ ] Pas de verrouillages récurrents (< 3 en 7 jours)
[ ] Source du verrouillage identifiée
[ ] Pas de tentatives depuis sources multiples suspectes
[ ] Pas de tentatives hors heures ouvrables

┌─────────────────────────────────────────────────────────────────┐
│ 3. INVESTIGATION DES CAUSES                                      │
└─────────────────────────────────────────────────────────────────┘
[ ] Utilisateur interrogé sur :
    [ ] Mot de passe récemment changé ?
    [ ] Sessions ouvertes sur d'autres appareils ?
    [ ] Applications avec identifiants obsolètes ?
    [ ] Appareils mobiles à jour ?
    [ ] VPN/Bureau à distance actifs ?
    [ ] Lecteurs réseau mappés ?

┌─────────────────────────────────────────────────────────────────┐
│ 4. ACTIONS CORRECTIVES                                           │
└─────────────────────────────────────────────────────────────────┘
[ ] Identification de la cause racine
[ ] Plan d'action défini pour éviter récurrence :
    Cause identifiée : _______________________________________
    
    Actions à entreprendre :
    [ ] Mise à jour mot de passe sur appareils
    [ ] Fermeture sessions obsolètes
    [ ] Mise à jour credentials applications
    [ ] Réinitialisation mot de passe
    [ ] Autre : ______________________________________________

┌─────────────────────────────────────────────────────────────────┐
│ 5. DÉCISION ET SUIVI                                             │
└─────────────────────────────────────────────────────────────────┘
[ ] Déverrouillage autorisé
[ ] Utilisateur informé des prochaines étapes
[ ] Ticket créé/mis à jour
[ ] Escalade si nécessaire : [ ] Oui  [ ] Non

NOTES ADDITIONNELLES :
_____________________________________________________________________
_____________________________________________________________________
_____________________________________________________________________

SIGNATURE TECHNICIEN : ________________  DATE : ____/____/________

"@
    
    # Sauvegarde de la checklist
    $checklistPath = "C:\Helpdesk\Checklists"
    if (-not (Test-Path $checklistPath)) {
        New-Item -Path $checklistPath -ItemType Directory | Out-Null
    }
    
    $fileName = "$checklistPath\Checklist_$($Username)_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
    $checklist | Out-File $fileName
    
    Write-Host $checklist
    Write-Host "`n📄 Checklist sauvegardée : $fileName" -ForegroundColor Cyan
}
```

### Détection d'attaques par force brute

```powershell
# Détection d'attaque par force brute en cours
function Test-BruteForceAttack {
    param(
        [int]$TimeWindowMinutes = 30,
        [int]$ThresholdAttempts = 50
    )
    
    $startTime = (Get-Date).AddMinutes(-$TimeWindowMinutes)
    
    Write-Host "`n🛡️  DÉTECTION D'ATTAQUES PAR FORCE BRUTE" -ForegroundColor Red
    Write-Host "Fenêtre d'analyse : $TimeWindowMinutes dernières minutes"
    Write-Host "Seuil d'alerte : $ThresholdAttempts tentatives"
    Write-Host "=" * 60
    
    # Récupération des échecs de connexion
    $failedAttempts = Get-WinEvent -FilterHashtable @{
        LogName = 'Security'
        Id = 4625
        StartTime = $startTime
    } -ErrorAction SilentlyContinue
    
    if ($failedAttempts) {
        # Analyse par utilisateur
        $userAttacks = $failedAttempts | 
            Group-Object {$_.Properties[5].Value} |
            Where-Object {$_.Count -ge $ThresholdAttempts} |
            Sort-Object Count -Descending
        
        if ($userAttacks) {
            Write-Host "`n🚨 ALERTE : ATTAQUE DÉTECTÉE !" -ForegroundColor Red
            Write-Host "`nUtilisateurs ciblés :" -ForegroundColor Yellow
            
            foreach ($attack in $userAttacks) {
                Write-Host "`n  🎯 CIBLE : $($attack.Name)" -ForegroundColor Red
                Write-Host "     Tentatives : $($attack.Count)" -ForegroundColor Red
                
                # Analyse des sources
                $sources = $attack.Group | Group-Object {$_.Properties[19].Value}
                Write-Host "     Sources IP :"
                $sources | Sort-Object Count -Descending | Select-Object -First 5 | ForEach-Object {
                    Write-Host "       - $($_.Name) : $($_.Count) tentatives"
                }
                
                # Recommandation
                Write-Host "`n     ⚠️  ACTIONS RECOMMANDÉES :" -ForegroundColor Yellow
                Write-Host "       1. NE PAS déverrouiller ce compte"
                Write-Host "       2. Bloquer les IPs sources au firewall"
                Write-Host "       3. Alerter l'équipe sécurité"
                Write-Host "       4. Forcer un changement de mot de passe"
                Write-Host "       5. Activer l'authentification multi-facteurs"
            }
            
            return $true
        } else {
            Write-Host "`n✅ Aucune attaque par force brute détectée" -ForegroundColor Green
            return $false
        }
    } else {
        Write-Host "`n✅ Aucune tentative échouée dans la période analysée" -ForegroundColor Green
        return $false
    }
}

# Utilisation
if (Test-BruteForceAttack -TimeWindowMinutes 30 -ThresholdAttempts 50) {
    Write-Host "`n🚨 INCIDENT DE SÉCURITÉ : Contacter immédiatement l'équipe sécurité !" -ForegroundColor Red
}
```

### Politique de déverrouillage sécurisé

> [!tip] Bonnes pratiques de sécurité **Déverrouillage standard :**
> 
> - Vérifier l'identité de l'utilisateur (2 éléments minimum)
> - Consulter l'historique des verrouillages
> - Identifier la cause avant de déverrouiller
> - Documenter chaque déverrouillage
> 
> **Déverrouillage avec précautions (flags jaunes) :**
> 
> - 2-4 verrouillages en 7 jours → Demander changement de mot de passe
> - Mot de passe ancien (> 180 jours) → Forcer le renouvellement
> - Sources multiples → Vérifier les appareils/applications
> 
> **Escalade requise (flags rouges) :**
> 
> - 5+ verrouillages en 7 jours
> - Sources multiples suspectes (> 3 machines)
> - Tentatives hors heures ouvrables
> - Pattern d'attaque par force brute
> - IPs étrangères ou suspectes
> 
> **En cas d'attaque confirmée :**
> 
> - NE PAS déverrouiller
> - Alerter l'équipe sécurité immédiatement
> - Bloquer les IPs sources
> - Envisager désactivation temporaire du compte
> - Forcer MFA si disponible

---

## Pièges courants

### ❌ Erreur 1 : Déverrouiller sans identifier la cause

```powershell
# MAUVAIS : Déverrouillage sans analyse
Unlock-ADAccount -Identity "jdupont"

# BON : Analyse avant déverrouillage
$user = Get-ADUser "jdupont" -Properties LockedOut, LockoutTime, BadPwdCount
if ($user.LockedOut) {
    Write-Host "Verrouillé depuis : $($user.LockoutTime)"
    Write-Host "Tentatives échouées : $($user.BadPwdCount)"
    
    # Identifier la source
    Find-LockoutSource -Username "jdupont"
    
    # Décision éclairée
    $confirm = Read-Host "Déverrouiller après analyse ? (O/N)"
    if ($confirm -eq "O") {
        Unlock-ADAccount -Identity "jdupont"
    }
}
```

> [!warning] Pourquoi c'est problématique Déverrouiller sans comprendre la cause peut :
> 
> - Laisser une attaque en cours se poursuivre
> - Ne pas résoudre le problème sous-jacent (l'utilisateur sera re-verrouillé)
> - Masquer un problème de sécurité important
> - Causer des verrouillages récurrents frustrants pour l'utilisateur

### ❌ Erreur 2 : Ne pas vérifier si le compte est effectivement verrouillé

```powershell
# MAUVAIS : Déverrouillage aveugle
Unlock-ADAccount -Identity "jdupont"  # Pas d'erreur mais inutile si déjà déverrouillé

# BON : Vérification préalable
$user = Get-ADUser "jdupont" -Properties LockedOut
if ($user.LockedOut) {
    Unlock-ADAccount -Identity "jdupont"
    Write-Host "✅ Compte déverrouillé" -ForegroundColor Green
} else {
    Write-Host "ℹ️  Le compte n'est pas verrouillé" -ForegroundColor Cyan
    Write-Host "   Problème probable : Mot de passe incorrect ou compte désactivé"
}
```

### ❌ Erreur 3 : Oublier les sessions obsolètes

```powershell
# PROBLÈME : L'utilisateur sera re-verrouillé immédiatement
# Si des sessions/applications utilisent l'ancien mot de passe

# SOLUTION : Vérifier et informer l'utilisateur
function Unlock-WithGuidance {
    param([string]$Username)
    
    Unlock-ADAccount -Identity $Username
    
    Write-Host "`n✅ Compte déverrouillé" -ForegroundColor Green
    Write-Host "`n⚠️  IMPORTANT : Pour éviter un nouveau verrouillage :" -ForegroundColor Yellow
    Write-Host "   1. Fermez toutes vos sessions actives (Outlook, Teams, etc.)"
    Write-Host "   2. Déconnectez-vous du VPN et reconnectez-vous"
    Write-Host "   3. Mettez à jour le mot de passe sur vos appareils mobiles"
    Write-Host "   4. Vérifiez les lecteurs réseau mappés"
    Write-Host "   5. Redémarrez votre ordinateur si possible"
}
```

### ❌ Erreur 4 : Ne pas logger les actions

```powershell
# MAUVAIS : Aucune trace
Unlock-ADAccount -Identity "jdupont"

# BON : Logging systématique
function Unlock-WithLogging {
    param(
        [string]$Username,
        [string]$Reason = "Demande utilisateur"
    )
    
    $user = Get-ADUser $Username -Properties LockedOut, LockoutTime
    
    if ($user.LockedOut) {
        # Action
        Unlock-ADAccount -Identity $Username
        
        # Logging
        $logEntry = @{
            Timestamp = Get-Date
            Technician = $env:USERNAME
            Username = $Username
            Action = "Unlock"
            LockoutTime = $user.LockoutTime
            Reason = $Reason
        }
        
        $logEntry | Export-Csv "C:\Logs\AD_Unlocks.csv" -Append -NoTypeInformation
        
        Write-Host "✅ Compte déverrouillé et action loggée" -ForegroundColor Green
    }
}
```

### ❌ Erreur 5 : Ignorer les verrouillages récurrents

```powershell
# PROBLÈME : Traiter chaque verrouillage indépendamment
# sans voir le pattern global

# SOLUTION : Vérifier l'historique
function Unlock-CheckRecurrence {
    param([string]$Username)
    
    # Vérification historique
    $startTime = (Get-Date).AddDays(-7)
    $lockouts = Get-WinEvent -FilterHashtable @{
        LogName = 'Security'
        Id = 4740
        StartTime = $startTime
    } -ErrorAction SilentlyContinue |
    Where-Object {$_.Properties[0].Value -eq $Username}
    
    if ($lockouts.Count -ge 3) {
        Write-Host "⚠️  ATTENTION : $($lockouts.Count) verrouillages en 7 jours !" -ForegroundColor Red
        Write-Host "   Ce n'est PAS normal. Investigation requise avant déverrouillage." -ForegroundColor Yellow
        
        $proceed = Read-Host "   Déverrouiller quand même ? (O/N)"
        if ($proceed -ne "O") {
            Write-Host "❌ Opération annulée - Escalade recommandée" -ForegroundColor Yellow
            return
        }
    }
    
    Unlock-ADAccount -Identity $Username
}
```

### ❌ Erreur 6 : Utiliser le mauvais format d'identité

```powershell
# ATTENTION aux différents formats

# Problèmes courants :
Unlock-ADAccount -Identity "Jean Dupont"  # ❌ Nom complet ne fonctionne pas
Unlock-ADAccount -Identity "Dupont"       # ❌ Nom de famille seul ne fonctionne pas

# Solutions correctes :
Unlock-ADAccount -Identity "jdupont"                              # ✅ SamAccountName
Unlock-ADAccount -Identity "jdupont@entreprise.local"             # ✅ UPN
Unlock-ADAccount -Identity "CN=Jean Dupont,OU=IT,DC=corp,DC=com"  # ✅ DN

# Si vous avez le nom complet, récupérez d'abord le compte :
$user = Get-ADUser -Filter {Name -eq "Jean Dupont"}
if ($user) {
    Unlock-ADAccount -Identity $user.SamAccountName
}
```

### ❌ Erreur 7 : Ne pas gérer les erreurs

```powershell
# MAUVAIS : Pas de gestion d'erreur
Unlock-ADAccount -Identity "utilisateur_inexistant"  # Génère une erreur non gérée

# BON : Gestion appropriée des erreurs
try {
    $user = Get-ADUser -Identity "jdupont" -Properties LockedOut -ErrorAction Stop
    
    if ($user.LockedOut) {
        Unlock-ADAccount -Identity "jdupont" -ErrorAction Stop
        Write-Host "✅ Compte déverrouillé avec succès" -ForegroundColor Green
    } else {
        Write-Host "ℹ️  Le compte n'est pas verrouillé" -ForegroundColor Cyan
    }
    
} catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
    Write-Host "❌ Utilisateur '$Username' introuvable dans AD" -ForegroundColor Red
} catch [System.UnauthorizedAccessException] {
    Write-Host "❌ Droits insuffisants pour cette opération" -ForegroundColor Red
} catch {
    Write-Host "❌ Erreur inattendue : $($_.Exception.Message)" -ForegroundColor Red
}
```

### ❌ Erreur 8 : Déverrouiller en masse sans discrimination

```powershell
# DANGEREUX : Déverrouillage aveugle de tous les comptes
Search-ADAccount -LockedOut | Unlock-ADAccount  # ❌ TRÈS MAUVAISE PRATIQUE

# MEILLEUR : Déverrouillage sélectif avec validation
Search-ADAccount -LockedOut | ForEach-Object {
    $user = Get-ADUser $_ -Properties LockoutTime, BadPwdCount, Department
    
    Write-Host "`nAnalyse : $($user.Name)" -ForegroundColor Cyan
    Write-Host "  Service : $($user.Department)"
    Write-Host "  Verrouillé : $($user.LockoutTime)"
    Write-Host "  Tentatives : $($user.BadPwdCount)"
    
    # Vérification de sécurité basique
    if ($user.BadPwdCount -lt 10) {  # Seuil arbitraire
        Unlock-ADAccount -Identity $user.SamAccountName
        Write-Host "  ✅ Déverrouillé" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  Trop de tentatives - Investigation requise" -ForegroundColor Red
    }
}
```

### ❌ Erreur 9 : Ne pas considérer la réplication AD

```powershell
# PROBLÈME : Le déverrouillage peut prendre du temps à se répliquer

# SOLUTION : Spécifier le bon DC et vérifier la réplication
function Unlock-WithReplication {
    param([string]$Username)
    
    # Déverrouillage sur le PDC Emulator (gère les verrouillages)
    $pdcEmulator = (Get-ADDomain).PDCEmulator
    
    Write-Host "Déverrouillage sur le PDC Emulator : $pdcEmulator" -ForegroundColor Cyan
    Unlock-ADAccount -Identity $Username -Server $pdcEmulator
    
    Write-Host "✅ Compte déverrouillé" -ForegroundColor Green
    Write-Host "ℹ️  La réplication vers les autres DCs peut prendre quelques minutes" -ForegroundColor Yellow
    
    # Vérification
    Start-Sleep -Seconds 5
    $user = Get-ADUser $Username -Server $pdcEmulator -Properties LockedOut
    Write-Host "Vérification : LockedOut = $($user.LockedOut)" -ForegroundColor Cyan
}
```

### ❌ Erreur 10 : Négliger la formation utilisateur

```powershell
# Après déverrouillage, éduquer l'utilisateur
function Unlock-WithEducation {
    param([string]$Username)
    
    Unlock-ADAccount -Identity $Username
    
    $educationMessage = @"

╔══════════════════════════════════════════════════════════════════╗
║              INFORMATION IMPORTANTE POUR L'UTILISATEUR           ║
╚══════════════════════════════════════════════════════════════════╝

Votre compte a été déverrouillé. Pour éviter de futurs verrouillages :

✅ BONNES PRATIQUES :
   • Utilisez un gestionnaire de mots de passe
   • Fermez vos sessions avant de changer votre mot de passe
   • Mettez à jour immédiatement tous vos appareils
   • Vérifiez vos applications en arrière-plan (Outlook, OneDrive, etc.)

⚠️  CAUSES COURANTES DE VERROUILLAGE :
   • Ancien mot de passe sauvegardé sur smartphone/tablette
   • Sessions VPN ou Bureau à distance oubliées
   • Applications avec identifiants obsolètes
   • Lecteurs réseau mappés avec anciennes credentials
   • Services Windows configurés avec votre compte

📞 EN CAS DE PROBLÈME :
   Contactez le Helpdesk : helpdesk@entreprise.local

"@
    
    Write-Host $educationMessage -ForegroundColor Cyan
    
    # Option : envoyer par email
    $user = Get-ADUser $Username -Properties EmailAddress
    if ($user.EmailAddress) {
        # Code d'envoi email ici
    }
}
```

---

## 🎓 Résumé des bonnes pratiques

> [!tip] Points clés à retenir
> 
> **Avant de déverrouiller :**
> 
> - ✅ Toujours vérifier l'état actuel avec `Get-ADUser -Properties LockedOut`
> - ✅ Consulter l'historique des verrouillages récents
> - ✅ Identifier la source du verrouillage avec les Event Logs
> - ✅ Vérifier l'identité de la personne qui demande le déverrouillage
> - ✅ Rechercher des patterns suspects (attaques, sources multiples)
> 
> **Lors du déverrouillage :**
> 
> - ✅ Utiliser le format d'identité approprié (SamAccountName recommandé)
> - ✅ Logger toutes les actions pour audit
> - ✅ Générer un ticket ou rapport
> - ✅ Gérer les erreurs correctement avec try/catch
> 
> **Après le déverrouillage :**
> 
> - ✅ Vérifier que le compte est bien déverrouillé
> - ✅ Informer l'utilisateur des actions à entreprendre
> - ✅ Identifier et corriger la cause racine
> - ✅ Documenter l'incident
> - ✅ Suivre les verrouillages récurrents
> 
> **Sécurité :**
> 
> - ⚠️ Ne JAMAIS déverrouiller sans analyse en cas de :
>     - Verrouillages récurrents (5+ en 7 jours)
>     - Sources multiples suspectes
>     - Tentatives hors heures ouvrables
>     - Patterns d'attaque par force brute
> - ⚠️ Escalader à l'équipe sécurité si nécessaire
> - ⚠️ Considérer MFA pour les comptes à risque

---

**Fin du cours : Unlock-ADAccount et gestion des verrouillages Active Directory**