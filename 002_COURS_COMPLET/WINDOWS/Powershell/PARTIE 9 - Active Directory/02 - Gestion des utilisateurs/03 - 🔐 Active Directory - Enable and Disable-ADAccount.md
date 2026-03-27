

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

## 🎯 Vue d'ensemble

Les commandes `Enable-ADAccount` et `Disable-ADAccount` permettent de gérer l'état actif/inactif des comptes Active Directory sans modifier leurs autres propriétés. Cette approche est fondamentale pour la gestion du cycle de vie des utilisateurs et la sécurité des systèmes d'information.

> [!info] Principe de fonctionnement Ces cmdlets modifient l'attribut `userAccountControl` dans Active Directory, spécifiquement le flag `ACCOUNTDISABLE` (valeur 0x0002). Un compte désactivé conserve toutes ses propriétés, appartenance aux groupes et permissions, mais ne peut plus s'authentifier.

### Pourquoi utiliser Enable/Disable plutôt que supprimer ?

|Avantage|Description|
|---|---|
|**Réversibilité**|Réactivation instantanée sans reconfiguration|
|**Conservation des données**|Préserve l'historique, les permissions et les appartenances|
|**Traçabilité**|Maintient l'objet AD pour l'audit et la conformité|
|**Sécurité SID**|Évite les problèmes de réaffectation de SID|
|**Rapidité**|Pas de recréation complète du profil utilisateur|

---

## ✅ Enable-ADAccount

### Présentation

`Enable-ADAccount` réactive un compte Active Directory qui a été désactivé. Cette cmdlet est essentielle dans les processus de réintégration d'utilisateurs après une absence temporaire, une suspension levée, ou une correction d'erreur administrative.

> [!warning] Attention aux prérequis Le compte doit exister dans Active Directory et être actuellement désactivé. La commande ne réinitialise pas le mot de passe ni ne modifie d'autres attributs du compte.

### Syntaxe de base

```powershell
Enable-ADAccount -Identity <ADAccount>
```

### Paramètres principaux

#### `-Identity` (Obligatoire)

Identifie le compte à activer. Accepte plusieurs formats :

```powershell
# Par Distinguished Name (DN)
Enable-ADAccount -Identity "CN=Jean Dupont,OU=Utilisateurs,DC=entreprise,DC=local"

# Par SamAccountName (identifiant de connexion)
Enable-ADAccount -Identity "jdupont"

# Par GUID (identifiant unique)
Enable-ADAccount -Identity "a8f3d892-5c41-4b8f-9e2a-1d5c8b9f3e4a"

# Par SID (Security Identifier)
Enable-ADAccount -Identity "S-1-5-21-3623811015-3361044348-30300820-1013"
```

> [!tip] Meilleure pratique d'identification Utilisez le SamAccountName pour les scripts courants (plus lisible) et le GUID pour les opérations critiques nécessitant une identification absolument unique.

#### `-Server`

Spécifie le contrôleur de domaine à contacter :

```powershell
Enable-ADAccount -Identity "jdupont" -Server "DC01.entreprise.local"
```

#### `-Credential`

Permet d'exécuter la commande avec des identifiants différents :

```powershell
$cred = Get-Credential
Enable-ADAccount -Identity "jdupont" -Credential $cred
```

### Cas d'usage courants

#### Réintégration après congés

```powershell
# Script de retour d'un employé
$username = "jdupont"

# Activation du compte
Enable-ADAccount -Identity $username

# Notification (mention d'envoi d'email, sans développer)
Write-Host "Compte $username réactivé avec succès" -ForegroundColor Green
```

#### Levée de suspension disciplinaire

```powershell
# Processus de levée de suspension avec journalisation
$username = "mmartin"
$logPath = "C:\Logs\AD_Reactivations.log"

try {
    Enable-ADAccount -Identity $username -ErrorAction Stop
    $logEntry = "$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss') - Compte $username réactivé"
    Add-Content -Path $logPath -Value $logEntry
}
catch {
    Write-Error "Erreur lors de l'activation de $username : $_"
}
```

#### Réactivation en masse depuis un fichier CSV

```powershell
# CSV avec une colonne "SamAccountName"
$users = Import-Csv -Path "C:\Scripts\comptes_a_reactiver.csv"

foreach ($user in $users) {
    try {
        Enable-ADAccount -Identity $user.SamAccountName -ErrorAction Stop
        Write-Host "✓ $($user.SamAccountName) activé" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ Échec pour $($user.SamAccountName) : $_" -ForegroundColor Red
    }
}
```

### Comportement et limitations

> [!warning] Points d'attention
> 
> - `Enable-ADAccount` n'effectue AUCUNE modification en dehors de l'activation du compte
> - Le mot de passe existant reste inchangé (peut nécessiter une réinitialisation séparée)
> - Les appartenances aux groupes ne sont pas modifiées
> - Les stratégies de groupe s'appliquent immédiatement après activation
> - La propagation peut prendre quelques minutes sur les grands domaines (réplication AD)

```powershell
# Activation ET réinitialisation de mot de passe (opérations séparées)
$username = "jdupont"
$newPassword = ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force

Enable-ADAccount -Identity $username
Set-ADAccountPassword -Identity $username -NewPassword $newPassword -Reset
Set-ADUser -Identity $username -ChangePasswordAtLogon $true
```

---

## 🚫 Disable-ADAccount

### Présentation

`Disable-ADAccount` désactive un compte Active Directory, empêchant toute authentification tout en préservant intégralement l'objet utilisateur et ses attributs. Cette cmdlet est un pilier des processus d'offboarding et de la gestion de la sécurité.

> [!info] Fonctionnement technique La désactivation positionne le bit `ACCOUNTDISABLE` dans l'attribut `userAccountControl`. Les sessions actives peuvent persister jusqu'à expiration des tickets Kerberos, mais aucune nouvelle authentification n'est possible.

### Syntaxe de base

```powershell
Disable-ADAccount -Identity <ADAccount>
```

### Paramètres principaux

Les paramètres sont identiques à `Enable-ADAccount` :

```powershell
# Désactivation simple
Disable-ADAccount -Identity "jdupont"

# Avec serveur spécifique
Disable-ADAccount -Identity "jdupont" -Server "DC02.entreprise.local"

# Avec credentials alternatifs
Disable-ADAccount -Identity "jdupont" -Credential $cred
```

### Cas d'usage stratégiques

#### 1. Départs temporaires

```powershell
# Congé sabbatique de 6 mois
$username = "amelie.durand"
$startDate = Get-Date
$comment = "Congé sabbatique - Retour prévu : $($startDate.AddMonths(6).ToString('dd/MM/yyyy'))"

# Désactivation avec annotation
Disable-ADAccount -Identity $username
Set-ADUser -Identity $username -Description $comment

Write-Host "Compte $username désactivé jusqu'au $($startDate.AddMonths(6).ToString('dd/MM/yyyy'))" -ForegroundColor Yellow
```

#### 2. Processus d'offboarding sécurisé

```powershell
# Script de départ d'employé (version simplifiée)
param(
    [Parameter(Mandatory=$true)]
    [string]$Username,
    [string]$Reason = "Départ de l'entreprise"
)

$user = Get-ADUser -Identity $Username -Properties *

# 1. Désactivation immédiate du compte
Disable-ADAccount -Identity $Username

# 2. Suppression des appartenances aux groupes sensibles (mention seulement)
# Retrait des groupes critiques...

# 3. Journalisation
$logEntry = @"
[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')]
Utilisateur : $Username
Nom complet : $($user.DisplayName)
Raison : $Reason
Action : Compte désactivé
"@

Add-Content -Path "C:\Logs\Offboarding.log" -Value $logEntry
Write-Host "Compte $Username désactivé avec succès" -ForegroundColor Green
```

#### 3. Suspension disciplinaire

```powershell
# Suspension immédiate avec notification
$username = "utilisateur.suspect"
$incident = "INC-2024-0042"

Disable-ADAccount -Identity $username

# Ajout d'informations dans les notes
Set-ADUser -Identity $username -Replace @{
    info = "COMPTE SUSPENDU - Incident: $incident - Date: $(Get-Date -Format 'yyyy-MM-dd')"
}

Write-Warning "Compte $username suspendu - Référence incident: $incident"
```

#### 4. Détection et désactivation de comptes inactifs

```powershell
# Recherche de comptes non utilisés depuis 90 jours
$inactivityThreshold = (Get-Date).AddDays(-90)

$inactiveUsers = Get-ADUser -Filter {
    Enabled -eq $true -and 
    LastLogonDate -lt $inactivityThreshold
} -Properties LastLogonDate, Description

foreach ($user in $inactiveUsers) {
    Write-Host "Compte inactif détecté: $($user.SamAccountName) - Dernière connexion: $($user.LastLogonDate)" -ForegroundColor Yellow
    
    # Désactivation avec conservation de l'historique
    Disable-ADAccount -Identity $user.SamAccountName
    
    $note = "Désactivé automatiquement - Inactif depuis $($user.LastLogonDate)"
    Set-ADUser -Identity $user.SamAccountName -Description $note
}

Write-Host "`n$($inactiveUsers.Count) comptes inactifs désactivés" -ForegroundColor Cyan
```

#### 5. Sécurité préventive lors d'incidents

```powershell
# Désactivation d'urgence suite à compromission suspectée
$compromisedAccounts = @("user1", "user2", "user3")
$incidentID = "SEC-2024-001"

foreach ($account in $compromisedAccounts) {
    Disable-ADAccount -Identity $account
    
    # Marquage du compte
    Set-ADUser -Identity $account -Replace @{
        extensionAttribute1 = "LOCKED-SECURITY-$incidentID"
    }
    
    Write-Host "SÉCURITÉ: Compte $account désactivé - Incident $incidentID" -ForegroundColor Red
}
```

### Scripts d'audit des comptes désactivés

#### Rapport des comptes désactivés

```powershell
# Génération d'un rapport complet
$disabledAccounts = Get-ADUser -Filter {Enabled -eq $false} -Properties *

$report = $disabledAccounts | Select-Object @{
    Name = "Nom d'utilisateur"
    Expression = {$_.SamAccountName}
}, @{
    Name = "Nom complet"
    Expression = {$_.DisplayName}
}, @{
    Name = "Date de désactivation"
    Expression = {$_.Modified}
}, @{
    Name = "Description"
    Expression = {$_.Description}
}, @{
    Name = "Dernière connexion"
    Expression = {$_.LastLogonDate}
}

$report | Export-Csv -Path "C:\Reports\Comptes_Desactives_$(Get-Date -Format 'yyyyMMdd').csv" -NoTypeInformation -Encoding UTF8

Write-Host "Rapport généré : $($disabledAccounts.Count) comptes désactivés" -ForegroundColor Cyan
```

#### Vérification périodique avec alertes

```powershell
# Script de vérification hebdomadaire
$disabledOver6Months = Get-ADUser -Filter {
    Enabled -eq $false
} -Properties Modified | Where-Object {
    $_.Modified -lt (Get-Date).AddMonths(-6)
}

if ($disabledOver6Months.Count -gt 0) {
    Write-Warning "⚠️ $($disabledOver6Months.Count) comptes désactivés depuis plus de 6 mois"
    Write-Host "Considérez une revue de ces comptes pour suppression définitive`n"
    
    $disabledOver6Months | ForEach-Object {
        Write-Host "  - $($_.SamAccountName) (désactivé le : $($_.Modified.ToString('dd/MM/yyyy')))"
    }
}
```

### Bonnes pratiques d'utilisation

> [!tip] Recommandations de sécurité
> 
> 1. **Désactiver plutôt que supprimer** : Permet un audit et une traçabilité complète
> 2. **Documenter systématiquement** : Utiliser le champ Description ou les extensionAttributes
> 3. **Processus de revue** : Établir une politique de revue trimestrielle des comptes désactivés
> 4. **Délai avant suppression** : Maintenir les comptes désactivés pendant 6-12 mois avant suppression définitive
> 5. **Automatisation** : Mettre en place des scripts de désactivation automatique pour comptes inactifs

```powershell
# Template de désactivation avec documentation complète
function Disable-ADAccountWithAudit {
    param(
        [string]$Identity,
        [string]$Reason,
        [string]$TicketNumber
    )
    
    $auditInfo = @{
        DisabledDate = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
        DisabledBy = $env:USERNAME
        Reason = $Reason
        Ticket = $TicketNumber
    }
    
    Disable-ADAccount -Identity $Identity
    
    $description = "DÉSACTIVÉ: $($auditInfo.DisabledDate) | Par: $($auditInfo.DisabledBy) | Raison: $Reason | Ticket: $TicketNumber"
    Set-ADUser -Identity $Identity -Description $description
    
    Write-Host "Compte $Identity désactivé et documenté" -ForegroundColor Green
}

# Utilisation
Disable-ADAccountWithAudit -Identity "jdupont" -Reason "Fin de contrat" -TicketNumber "RH-2024-156"
```

---

## 🔍 Vérification du statut

### Récupération du statut d'activation

La propriété `Enabled` indique si un compte est actif ou désactivé. Cette vérification est essentielle avant d'effectuer des opérations ou pour des audits de sécurité.

```powershell
# Vérification simple
Get-ADUser -Identity "jdupont" -Properties Enabled | Select-Object Name, Enabled
```

### Exemples de vérifications avancées

#### Vérification avec affichage formaté

```powershell
$user = Get-ADUser -Identity "jdupont" -Properties Enabled, LastLogonDate, PasswordLastSet

[PSCustomObject]@{
    "Nom d'utilisateur" = $user.SamAccountName
    "Nom complet" = $user.Name
    "Compte actif" = if($user.Enabled){"✓ Oui"}else{"✗ Non"}
    "Dernière connexion" = $user.LastLogonDate
    "Dernier changement MDP" = $user.PasswordLastSet
} | Format-List
```

#### Fonction de vérification avec contexte

```powershell
function Test-ADAccountStatus {
    param([string]$Identity)
    
    $user = Get-ADUser -Identity $Identity -Properties Enabled, LockedOut, PasswordExpired
    
    Write-Host "`n=== Statut du compte $Identity ===" -ForegroundColor Cyan
    
    if ($user.Enabled) {
        Write-Host "État: ACTIF" -ForegroundColor Green
    } else {
        Write-Host "État: DÉSACTIVÉ" -ForegroundColor Red
    }
    
    if ($user.LockedOut) {
        Write-Host "Verrouillage: VERROUILLÉ" -ForegroundColor Red
    }
    
    if ($user.PasswordExpired) {
        Write-Host "Mot de passe: EXPIRÉ" -ForegroundColor Yellow
    }
}

# Utilisation
Test-ADAccountStatus -Identity "jdupont"
```

#### Vérification en masse avec export

```powershell
# Vérification du statut de tous les utilisateurs d'une OU
$users = Get-ADUser -SearchBase "OU=Utilisateurs,DC=entreprise,DC=local" -Filter * -Properties Enabled, LastLogonDate

$statusReport = $users | Select-Object @{
    Name = "Utilisateur"
    Expression = {$_.SamAccountName}
}, @{
    Name = "Statut"
    Expression = {if($_.Enabled){"Actif"}else{"Désactivé"}}
}, @{
    Name = "Dernière connexion"
    Expression = {$_.LastLogonDate}
} | Sort-Object Statut, "Dernière connexion" -Descending

$statusReport | Export-Csv -Path "C:\Reports\Statut_Comptes.csv" -NoTypeInformation -Encoding UTF8

# Statistiques rapides
$activeCount = ($users | Where-Object {$_.Enabled}).Count
$disabledCount = ($users | Where-Object {-not $_.Enabled}).Count

Write-Host "`n📊 Statistiques:" -ForegroundColor Cyan
Write-Host "  Comptes actifs: $activeCount" -ForegroundColor Green
Write-Host "  Comptes désactivés: $disabledCount" -ForegroundColor Yellow
```

#### Vérification conditionnelle dans un script

```powershell
# Vérifier avant d'effectuer une action
$username = "jdupont"
$user = Get-ADUser -Identity $username -Properties Enabled

if ($user.Enabled) {
    Write-Host "Le compte $username est déjà actif" -ForegroundColor Green
} else {
    Write-Host "Activation du compte $username..." -ForegroundColor Yellow
    Enable-ADAccount -Identity $username
    Write-Host "Compte $username activé avec succès" -ForegroundColor Green
}
```

### Filtrage par statut dans les recherches

```powershell
# Trouver tous les comptes désactivés dans une OU spécifique
$disabledInOU = Get-ADUser -SearchBase "OU=Anciens,DC=entreprise,DC=local" -Filter {Enabled -eq $false}

Write-Host "Nombre de comptes désactivés dans l'OU Anciens: $($disabledInOU.Count)" -ForegroundColor Cyan

# Trouver tous les comptes actifs créés récemment
$recentActiveUsers = Get-ADUser -Filter {
    Enabled -eq $true -and 
    Created -gt $((Get-Date).AddDays(-30))
} -Properties Created

Write-Host "Comptes actifs créés dans les 30 derniers jours: $($recentActiveUsers.Count)" -ForegroundColor Green
```

---

## 📊 Comparaison et bonnes pratiques

### Tableau comparatif Enable vs Disable

|Aspect|Enable-ADAccount|Disable-ADAccount|
|---|---|---|
|**Action principale**|Active le compte|Désactive le compte|
|**Flag modifié**|Retire ACCOUNTDISABLE|Ajoute ACCOUNTDISABLE|
|**Authentification**|Autorisée immédiatement|Bloquée immédiatement|
|**Sessions actives**|N/A|Peuvent persister temporairement|
|**Autres attributs**|Aucun changement|Aucun changement|
|**Permissions**|Conservées|Conservées|
|**Groupes**|Maintenus|Maintenus|
|**Réversibilité**|Désactivation possible|Activation possible|
|**Usage typique**|Retour d'absence, réintégration|Départ, suspension, inactivité|

### Matrice de décision : Désactiver vs Supprimer

|Situation|Action recommandée|Justification|
|---|---|---|
|Départ définitif|Désactiver puis supprimer après 6-12 mois|Conformité et audit|
|Congé longue durée|Désactiver|Réactivation rapide au retour|
|Suspension disciplinaire|Désactiver|Situation temporaire|
|Inactivité > 90 jours|Désactiver|Sécurité préventive|
|Compte de test terminé|Supprimer|Aucun besoin de conservation|
|Compte compromis|Désactiver immédiatement|Investigation nécessaire|
|Changement de fonction|Modifier (ni désactiver ni supprimer)|L'utilisateur reste actif|

### Workflow de gestion du cycle de vie

> [!example] Processus complet de gestion de compte
> 
> ```
> EMBAUCHE
>   ↓
> Création (New-ADUser)
>   ↓
> PÉRIODE ACTIVE
>   ↓
> ┌─────────────────────┐
> │ Événement déclencheur │
> └─────────────────────┘
>          ↓
>    ┌─────────┐
>    │ Absence │─→ Disable-ADAccount → [Compte désactivé] → Retour → Enable-ADAccount
>    └─────────┘
>          ↓
>    ┌─────────┐
>    │  Départ │─→ Disable-ADAccount → [Attente 6-12 mois] → Remove-ADUser
>    └─────────┘
> ```

### Bonnes pratiques de sécurité

> [!warning] Règles de sécurité essentielles
> 
> 1. **Jamais de suppression immédiate** : Toujours désactiver d'abord
> 2. **Documentation obligatoire** : Chaque désactivation doit être justifiée et tracée
> 3. **Revue périodique** : Audit trimestriel des comptes désactivés
> 4. **Automatisation intelligente** : Scripts pour détecter et désactiver les comptes inactifs
> 5. **Notification** : Alerter les responsables lors de désactivations automatiques
> 6. **Double vérification** : Processus de validation pour les comptes critiques
> 7. **Backup avant suppression** : Export des attributs avant suppression définitive

### Checklist avant désactivation de compte

```powershell
# Script de vérification pré-désactivation
function Start-PreDisableCheck {
    param([string]$Identity)
    
    $user = Get-ADUser -Identity $Identity -Properties MemberOf, Manager, Title
    
    Write-Host "`n🔍 Vérifications avant désactivation de $Identity" -ForegroundColor Cyan
    Write-Host "═══════════════════════════════════════════════════" -ForegroundColor Cyan
    
    # 1. Groupes sensibles
    $criticalGroups = @("Domain Admins", "Enterprise Admins", "Administrators")
    $userGroups = $user.MemberOf | ForEach-Object {($_ -split ',')[0] -replace 'CN='}
    $hasCriticalGroup = $userGroups | Where-Object {$_ -in $criticalGroups}
    
    if ($hasCriticalGroup) {
        Write-Host "⚠️  ATTENTION: Membre de groupes critiques: $($hasCriticalGroup -join ', ')" -ForegroundColor Red
    } else {
        Write-Host "✓ Pas de groupes critiques" -ForegroundColor Green
    }
    
    # 2. Manager
    if ($user.Manager) {
        Write-Host "✓ Manager identifié: $($user.Manager)" -ForegroundColor Green
    } else {
        Write-Host "⚠️  Aucun manager défini" -ForegroundColor Yellow
    }
    
    # 3. Fonction
    Write-Host "ℹ️  Fonction: $($user.Title)" -ForegroundColor Cyan
    
    Write-Host "`n✅ Vérifications terminées" -ForegroundColor Green
}

# Utilisation
Start-PreDisableCheck -Identity "jdupont"
```

### Gestion des erreurs courantes

```powershell
# Gestion robuste des erreurs
function Safe-DisableADAccount {
    param([string]$Identity)
    
    try {
        # Vérification de l'existence
        $user = Get-ADUser -Identity $Identity -ErrorAction Stop
        
        # Vérification du statut actuel
        if (-not $user.Enabled) {
            Write-Warning "Le compte $Identity est déjà désactivé"
            return
        }
        
        # Désactivation
        Disable-ADAccount -Identity $Identity -ErrorAction Stop
        Write-Host "✓ Compte $Identity désactivé avec succès" -ForegroundColor Green
        
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
        Write-Error "Utilisateur $Identity introuvable dans Active Directory"
    }
    catch {
        Write-Error "Erreur lors de la désactivation de $Identity : $($_.Exception.Message)"
    }
}
```

### Scripts de maintenance automatisée

```powershell
# Maintenance hebdomadaire automatisée
$inactivityThreshold = 90
$disabledRetention = 180

# 1. Désactivation des comptes inactifs
$inactiveDate = (Get-Date).AddDays(-$inactivityThreshold)
$inactiveUsers = Get-ADUser -Filter {
    Enabled -eq $true -and 
    LastLogonDate -lt $inactiveDate
} -Properties LastLogonDate

foreach ($user in $inactiveUsers) {
    Disable-ADAccount -Identity $user.SamAccountName
    $note = "Auto-désactivé: Inactif depuis le $($user.LastLogonDate)"
    Set-ADUser -Identity $user.SamAccountName -Description $note
}

Write-Host "Phase 1: $($inactiveUsers.Count) comptes inactifs désactivés" -ForegroundColor Yellow

# 2. Identification des comptes à supprimer
$deleteDate = (Get-Date).AddDays(-$disabledRetention)
$accountsToReview = Get-ADUser -Filter {
    Enabled -eq $false
} -Properties Modified | Where-Object {
    $_.Modified -lt $deleteDate
}

Write-Host "Phase 2: $($accountsToReview.Count) comptes désactivés depuis >6 mois (revue manuelle requise)" -ForegroundColor Cyan
```

---

## 🎯 Points clés à retenir

> [!tip] Synthèse
> 
> - **Enable-ADAccount** et **Disable-ADAccount** sont des outils de gestion réversible du cycle de vie des comptes
> - La désactivation préserve TOUTES les données et permissions du compte
> - Toujours privilégier la désactivation à la suppression pour la traçabilité
> - La vérification du statut avec `-Properties Enabled` est essentielle dans les scripts
> - Documenter systématiquement les raisons de chaque désactivation
> - Mettre en place des processus automatisés pour les comptes inactifs
> - Réviser régulièrement les comptes désactivés avant suppression définitive