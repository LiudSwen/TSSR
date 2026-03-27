

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

## 🗑️ Remove-ADComputer

### Vue d'ensemble

La cmdlet `Remove-ADComputer` permet de supprimer définitivement des comptes ordinateurs de l'Active Directory. Cette opération est irréversible (sauf si la Corbeille AD est activée) et nécessite une grande prudence.

> [!warning] Attention La suppression d'un compte ordinateur est une opération destructive qui rompt la relation d'approbation entre la machine et le domaine. La machine ne pourra plus se connecter au domaine sans être réintégrée.

**Quand utiliser Remove-ADComputer :**

- Machines définitivement hors service ou reformatées
- Comptes obsolètes détectés lors d'audits
- Nettoyage de comptes créés par erreur
- Maintenance régulière du répertoire

---

### Syntaxe et paramètres

```powershell
Remove-ADComputer [-Identity] <ADComputer>
    [-AuthType <ADAuthType>]
    [-Credential <PSCredential>]
    [-Partition <String>]
    [-Server <String>]
    [-Confirm]
    [-WhatIf]
    [<CommonParameters>]
```

#### Paramètres principaux

|Paramètre|Description|Obligatoire|
|---|---|---|
|`-Identity`|Identifie le compte ordinateur à supprimer (SAMAccountName, DN, GUID, SID)|✅ Oui|
|`-Confirm`|Demande confirmation avant l'exécution|❌ Non (mais recommandé)|
|`-WhatIf`|Simule l'opération sans l'exécuter|❌ Non (mais recommandé)|
|`-Server`|Spécifie le contrôleur de domaine à contacter|❌ Non|
|`-Credential`|Permet d'utiliser des identifiants alternatifs|❌ Non|

> [!info] Paramètre Identity Le paramètre `-Identity` accepte plusieurs formats :
> 
> - **SAMAccountName** : `PC-01$` (noter le `$` final)
> - **Distinguished Name** : `CN=PC-01,OU=Workstations,DC=contoso,DC=com`
> - **GUID** : `a8c3d7f2-4b5e-6a8d-9c1b-2e3f4a5b6c7d`
> - **SID** : `S-1-5-21-3623811015-3361044348-30300820-1013`

---

### Précautions essentielles

Avant de supprimer un compte ordinateur, plusieurs vérifications sont indispensables :

#### 1. Vérifier que la machine n'est plus utilisée

```powershell
# Vérifier la dernière connexion
Get-ADComputer -Identity "PC-01" -Properties LastLogonDate, OperatingSystem |
    Select-Object Name, LastLogonDate, OperatingSystem, Enabled

# Vérifier si la machine répond sur le réseau
Test-Connection -ComputerName "PC-01" -Count 2 -Quiet
```

> [!tip] Astuce - Critères d'obsolescence Considérez un ordinateur comme obsolète si :
> 
> - `LastLogonDate` est supérieur à 90-180 jours
> - La machine ne répond plus au ping
> - Le compte est déjà désactivé
> - L'emplacement physique est confirmé comme vide

#### 2. Désactivation préalable recommandée

La meilleure pratique consiste à désactiver d'abord le compte, attendre une période de grâce (30-60 jours), puis supprimer.

```powershell
# Étape 1 : Désactiver le compte
Disable-ADAccount -Identity "PC-01"

# Étape 2 : Déplacer vers une OU de quarantaine
Move-ADObject -Identity "CN=PC-01,OU=Workstations,DC=contoso,DC=com" `
              -TargetPath "OU=Disabled_Computers,DC=contoso,DC=com"

# Étape 3 : Ajouter une description avec la date
Set-ADComputer -Identity "PC-01" `
               -Description "Désactivé le $(Get-Date -Format 'dd/MM/yyyy') - À supprimer après 60 jours"
```

> [!warning] Pourquoi désactiver avant de supprimer ?
> 
> - Permet de détecter rapidement si la machine est encore utilisée
> - Donne le temps de vérifier l'absence d'impact
> - Facilite la réactivation en cas d'erreur
> - Respecte les procédures d'audit et de conformité

#### 3. Sauvegarde d'informations

Avant la suppression, exportez les informations importantes :

```powershell
# Exporter toutes les propriétés du compte
Get-ADComputer -Identity "PC-01" -Properties * |
    Export-Clixml -Path "C:\Backup\PC-01_backup.xml"

# Ou en CSV pour une lecture facile
Get-ADComputer -Identity "PC-01" -Properties * |
    Select-Object Name, DNSHostName, OperatingSystem, LastLogonDate, 
                  Description, MemberOf, Created, Modified |
    Export-Csv -Path "C:\Backup\PC-01_info.csv" -NoTypeInformation
```

---

### Nettoyage et maintenance

#### Scripts de maintenance automatisés

```powershell
# Script de nettoyage des ordinateurs obsolètes
# Rechercher les ordinateurs non connectés depuis 180 jours

$InactiveDays = 180
$CutoffDate = (Get-Date).AddDays(-$InactiveDays)
$TargetOU = "OU=Workstations,DC=contoso,DC=com"

# Recherche des ordinateurs inactifs
$InactiveComputers = Get-ADComputer -Filter {LastLogonDate -lt $CutoffDate} `
    -SearchBase $TargetOU `
    -Properties LastLogonDate, OperatingSystem, Description

# Afficher le résumé
Write-Host "Ordinateurs inactifs trouvés : $($InactiveComputers.Count)" -ForegroundColor Yellow

foreach ($Computer in $InactiveComputers) {
    Write-Host "`nNom : $($Computer.Name)"
    Write-Host "Dernière connexion : $($Computer.LastLogonDate)"
    Write-Host "OS : $($Computer.OperatingSystem)"
    
    # Test de connectivité
    $Pingable = Test-Connection -ComputerName $Computer.Name -Count 1 -Quiet
    Write-Host "Répond au ping : $Pingable"
}

# Demander confirmation avant suppression massive
$Confirmation = Read-Host "`nVoulez-vous désactiver ces comptes ? (O/N)"
if ($Confirmation -eq 'O') {
    foreach ($Computer in $InactiveComputers) {
        Disable-ADAccount -Identity $Computer
        Set-ADComputer -Identity $Computer `
            -Description "Auto-désactivé le $(Get-Date -Format 'dd/MM/yyyy') - Inactif > $InactiveDays jours"
        Write-Host "✓ $($Computer.Name) désactivé" -ForegroundColor Green
    }
}
```

> [!example] Exemple - Nettoyage par phases **Phase 1 - Identification (Jour 0)**
> 
> ```powershell
> # Marquer les ordinateurs suspects
> $Suspects | Set-ADComputer -Description "AUDIT - À vérifier avant $(Get-Date -Format 'dd/MM/yyyy')"
> ```
> 
> **Phase 2 - Désactivation (Jour 30)**
> 
> ```powershell
> # Désactiver après vérification
> $Suspects | Disable-ADAccount
> ```
> 
> **Phase 3 - Suppression (Jour 90)**
> 
> ```powershell
> # Suppression définitive
> $Suspects | Remove-ADComputer -Confirm:$false
> ```

#### Utilisation de -Confirm et -WhatIf

```powershell
# Simulation sans exécution (TOUJOURS recommandé en premier)
Remove-ADComputer -Identity "PC-01" -WhatIf

# Sortie attendue :
# What if: Performing the operation "Remove" on target "CN=PC-01,OU=Workstations,DC=contoso,DC=com".

# Demander confirmation interactive
Remove-ADComputer -Identity "PC-01" -Confirm

# Sortie :
# Confirm
# Are you sure you want to perform this action?
# Performing the operation "Remove" on target "CN=PC-01,OU=Workstations,DC=contoso,DC=com".
# [Y] Yes  [A] Yes to All  [N] No  [L] No to All  [S] Suspend  [?] Help (default is "Y"):

# Suppression sans confirmation (DANGEREUX - réservé aux scripts testés)
Remove-ADComputer -Identity "PC-01" -Confirm:$false
```

> [!warning] Utilisation de -Confirm:$false N'utilisez `-Confirm:$false` que dans des scripts bien testés et avec :
> 
> - Des filtres stricts et vérifiés
> - Une sauvegarde récente de l'AD
> - Une journalisation complète des actions
> - Une validation préalable avec `-WhatIf`

---

### Désactivation vs Suppression

Comparaison des deux approches :

|Critère|Désactivation|Suppression|
|---|---|---|
|**Réversibilité**|✅ Immédiate|⚠️ Nécessite la Corbeille AD|
|**Délai de récupération**|Instantané|Jusqu'à 180 jours selon config|
|**Impact sur l'AD**|Minime (compte conservé)|Libère le SID et le nom|
|**Audit trail**|Conservé|Perdu si Corbeille non activée|
|**Appartenance aux groupes**|Conservée|❌ Perdue|
|**Recommandation**|✅ Première étape|Après période de grâce|

#### Flux de travail recommandé

```powershell
# Fonction complète pour le cycle de vie des ordinateurs
function Remove-ObsoleteComputer {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$ComputerName,
        
        [Parameter(Mandatory=$false)]
        [switch]$Force  # Force la suppression immédiate
    )
    
    # Récupérer les informations
    $Computer = Get-ADComputer -Identity $ComputerName -Properties *
    
    if (-not $Computer) {
        Write-Error "Ordinateur '$ComputerName' introuvable."
        return
    }
    
    # Afficher les informations
    Write-Host "`n=== Informations de l'ordinateur ===" -ForegroundColor Cyan
    Write-Host "Nom : $($Computer.Name)"
    Write-Host "Dernière connexion : $($Computer.LastLogonDate)"
    Write-Host "État : $(if($Computer.Enabled){'Activé'}else{'Désactivé'})"
    Write-Host "Créé le : $($Computer.Created)"
    
    if ($Force) {
        # Suppression immédiate
        Write-Host "`n⚠️  Suppression immédiate demandée" -ForegroundColor Red
        Remove-ADComputer -Identity $ComputerName -Confirm
    }
    else {
        # Processus standard : désactivation
        if ($Computer.Enabled) {
            Write-Host "`nÉtape 1 : Désactivation du compte" -ForegroundColor Yellow
            Disable-ADAccount -Identity $ComputerName
            
            # Déplacer vers OU de quarantaine
            $QuarantineOU = "OU=Disabled_Computers,DC=contoso,DC=com"
            Move-ADObject -Identity $Computer.DistinguishedName -TargetPath $QuarantineOU
            
            # Marquer avec date de suppression prévue
            $DeletionDate = (Get-Date).AddDays(60).ToString("dd/MM/yyyy")
            Set-ADComputer -Identity $ComputerName `
                -Description "Désactivé - Suppression prévue le $DeletionDate"
            
            Write-Host "✓ Compte désactivé et déplacé en quarantaine" -ForegroundColor Green
            Write-Host "✓ Suppression prévue le : $DeletionDate" -ForegroundColor Green
        }
        else {
            Write-Host "`n⚠️  Le compte est déjà désactivé" -ForegroundColor Yellow
            $Response = Read-Host "Voulez-vous le supprimer maintenant ? (O/N)"
            if ($Response -eq 'O') {
                Remove-ADComputer -Identity $ComputerName -Confirm
            }
        }
    }
}

# Utilisation
Remove-ObsoleteComputer -ComputerName "PC-01"          # Processus standard
Remove-ObsoleteComputer -ComputerName "PC-02" -Force   # Suppression immédiate
```

---

### Droits et permissions

#### Permissions requises

Pour exécuter `Remove-ADComputer`, vous devez disposer de l'un des privilèges suivants :

|Niveau d'accès|Description|
|---|---|
|**Admins du domaine**|Droits complets sur tous les objets|
|**Account Operators**|Peut gérer les comptes dans les OUs standard|
|**Délégation personnalisée**|"Delete Computer Objects" sur l'OU cible|

#### Vérifier ses permissions

```powershell
# Vérifier l'appartenance aux groupes privilégiés
$CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent()
$Principal = New-Object System.Security.Principal.WindowsPrincipal($CurrentUser)

$IsAdmin = $Principal.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
Write-Host "Administrateur local : $IsAdmin"

# Vérifier appartenance "Domain Admins"
$Groups = Get-ADPrincipalGroupMembership -Identity $env:USERNAME
$IsDomainAdmin = $Groups.Name -contains "Domain Admins"
Write-Host "Domain Admin : $IsDomainAdmin"
```

#### Déléguer les droits de suppression

```powershell
# Exemple de délégation sur une OU spécifique
# (nécessite le module Active Directory et droits Domain Admins)

$OU = "OU=Workstations,DC=contoso,DC=com"
$Group = "ITSupport"

# Importer le module
Import-Module ActiveDirectory

# Obtenir le SID du groupe
$GroupSID = (Get-ADGroup $Group).SID

# Créer une ACL pour autoriser la suppression
$ACL = Get-Acl -Path "AD:\$OU"

$Identity = [System.Security.Principal.IdentityReference] $GroupSID
$ADRight = [System.DirectoryServices.ActiveDirectoryRights]::DeleteChild
$Type = [System.Security.AccessControl.AccessControlType]::Allow
$InheritanceType = [System.DirectoryServices.ActiveDirectorySecurityInheritance]::All
$ObjectType = [Guid]"bf967a86-0de6-11d0-a285-00aa003049e2" # GUID pour Computer

$ACE = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
    $Identity, $ADRight, $Type, $ObjectType, $InheritanceType
)

$ACL.AddAccessRule($ACE)
Set-Acl -Path "AD:\$OU" -AclObject $ACL

Write-Host "✓ Droits de suppression délégués au groupe '$Group' sur '$OU'" -ForegroundColor Green
```

> [!tip] Astuce - Principe du moindre privilège Plutôt que d'ajouter des utilisateurs à "Domain Admins", créez des groupes de délégation spécifiques par OU avec uniquement les droits nécessaires.

---

### Récupération depuis la Corbeille AD

La Corbeille Active Directory permet de récupérer des objets supprimés accidentellement.

#### Vérifier si la Corbeille AD est activée

```powershell
# Vérifier l'état de la Corbeille AD
Get-ADOptionalFeature -Filter {Name -eq "Recycle Bin Feature"}

# Sortie si activée :
# FeatureScope              : ForestOrConfigurationSet
# EnabledScopes             : {CN=Partitions,CN=Configuration,DC=contoso,DC=com}
# IsDisableable             : False
```

> [!warning] Activation de la Corbeille AD
> 
> - La Corbeille AD doit être activée AVANT la suppression
> - Une fois activée, elle ne peut pas être désactivée
> - Nécessite un niveau fonctionnel de forêt Windows Server 2008 R2 minimum
> - Cette fonctionnalité ne sera pas détaillée ici (fait partie d'une autre section)

#### Récupérer un ordinateur supprimé

```powershell
# Lister les ordinateurs supprimés
Get-ADObject -Filter {ObjectClass -eq "computer"} `
    -IncludeDeletedObjects `
    -Properties Name, LastKnownParent, whenChanged, Deleted |
    Select-Object Name, LastKnownParent, whenChanged, Deleted |
    Format-Table -AutoSize

# Rechercher un ordinateur spécifique supprimé
$DeletedPC = Get-ADObject -Filter {Name -eq "PC-01" -and ObjectClass -eq "computer"} `
    -IncludeDeletedObjects `
    -Properties *

# Afficher les détails
$DeletedPC | Select-Object Name, DistinguishedName, whenChanged, Deleted

# Restaurer l'ordinateur
Restore-ADObject -Identity $DeletedPC -Confirm

# Restaurer à un emplacement spécifique
Restore-ADObject -Identity $DeletedPC `
    -TargetPath "OU=Restored_Computers,DC=contoso,DC=com" `
    -Confirm
```

> [!info] Durée de rétention Par défaut, les objets supprimés sont conservés dans la Corbeille AD pendant **180 jours** (configurable). Après ce délai, ils sont définitivement purgés.

#### Restauration avec propriétés complètes

```powershell
# La restauration standard ne restaure pas toujours toutes les propriétés
# Voici une fonction complète :

function Restore-ADComputerComplete {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ComputerName
    )
    
    # Récupérer l'objet supprimé
    $DeletedComputer = Get-ADObject -Filter {Name -eq $ComputerName -and ObjectClass -eq "computer"} `
        -IncludeDeletedObjects -Properties *
    
    if (-not $DeletedComputer) {
        Write-Error "Ordinateur '$ComputerName' introuvable dans la Corbeille AD"
        return
    }
    
    # Afficher les informations
    Write-Host "Ordinateur trouvé :" -ForegroundColor Cyan
    Write-Host "  Nom : $($DeletedComputer.Name)"
    Write-Host "  Supprimé le : $($DeletedComputer.Deleted)"
    Write-Host "  Dernier emplacement : $($DeletedComputer.LastKnownParent)"
    
    # Restaurer
    try {
        Restore-ADObject -Identity $DeletedComputer
        Write-Host "`n✓ Ordinateur '$ComputerName' restauré avec succès" -ForegroundColor Green
        
        # Réactiver si nécessaire
        $RestoredComputer = Get-ADComputer -Identity $ComputerName
        if (-not $RestoredComputer.Enabled) {
            Enable-ADAccount -Identity $ComputerName
            Write-Host "✓ Compte réactivé" -ForegroundColor Green
        }
    }
    catch {
        Write-Error "Erreur lors de la restauration : $_"
    }
}

# Utilisation
Restore-ADComputerComplete -ComputerName "PC-01"
```

---

### Exemples pratiques

#### Exemple 1 : Suppression simple avec confirmation

```powershell
# Supprimer un ordinateur avec confirmation
Remove-ADComputer -Identity "PC-01" -Confirm

# Supprimer en utilisant le Distinguished Name
Remove-ADComputer -Identity "CN=PC-01,OU=Workstations,DC=contoso,DC=com" -Confirm
```

#### Exemple 2 : Suppression multiple avec filtre

```powershell
# Supprimer tous les ordinateurs d'une OU spécifique désactivés depuis plus de 60 jours
$DisabledDate = (Get-Date).AddDays(-60)

Get-ADComputer -Filter {Enabled -eq $false} `
    -SearchBase "OU=Disabled_Computers,DC=contoso,DC=com" `
    -Properties Modified |
    Where-Object {$_.Modified -lt $DisabledDate} |
    ForEach-Object {
        Write-Host "Suppression de : $($_.Name)" -ForegroundColor Yellow
        Remove-ADComputer -Identity $_ -WhatIf
    }

# Retirer -WhatIf et ajouter -Confirm:$false pour exécuter réellement
```

#### Exemple 3 : Suppression avec journalisation

```powershell
# Script de suppression avec log détaillé
$LogPath = "C:\Logs\AD_Computer_Removal_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
$ComputersToRemove = @("PC-01", "PC-02", "PC-03")

function Write-Log {
    param([string]$Message)
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$Timestamp - $Message" | Out-File -FilePath $LogPath -Append
    Write-Host $Message
}

foreach ($Computer in $ComputersToRemove) {
    try {
        # Récupérer les infos avant suppression
        $Info = Get-ADComputer -Identity $Computer -Properties * -ErrorAction Stop
        
        # Logger les détails
        Write-Log "=== Suppression de $Computer ==="
        Write-Log "  DN : $($Info.DistinguishedName)"
        Write-Log "  Dernière connexion : $($Info.LastLogonDate)"
        Write-Log "  OS : $($Info.OperatingSystem)"
        
        # Sauvegarder les infos
        $Info | Export-Clixml -Path "C:\Backup\$Computer`_$(Get-Date -Format 'yyyyMMdd').xml"
        
        # Supprimer
        Remove-ADComputer -Identity $Computer -Confirm:$false -ErrorAction Stop
        Write-Log "  ✓ Supprimé avec succès"
        
    }
    catch {
        Write-Log "  ✗ ERREUR : $_"
    }
    Write-Log ""
}

Write-Host "`nLog enregistré dans : $LogPath" -ForegroundColor Cyan
```

#### Exemple 4 : Nettoyage basé sur l'inactivité avec rapport

```powershell
# Script de nettoyage complet avec rapport HTML
$InactiveDays = 180
$CutoffDate = (Get-Date).AddDays(-$InactiveDays)
$ReportPath = "C:\Reports\Inactive_Computers_$(Get-Date -Format 'yyyyMMdd').html"

# Recherche
$InactiveComputers = Get-ADComputer -Filter * -Properties LastLogonDate, OperatingSystem, Description |
    Where-Object {$_.LastLogonDate -lt $CutoffDate -or $_.LastLogonDate -eq $null}

# Créer le rapport HTML
$HTML = @"
<html>
<head>
    <title>Rapport de nettoyage - Ordinateurs inactifs</title>
    <style>
        body { font-family: Arial; }
        table { border-collapse: collapse; width: 100%; }
        th { background-color: #4CAF50; color: white; padding: 10px; }
        td { border: 1px solid #ddd; padding: 8px; }
        tr:nth-child(even) { background-color: #f2f2f2; }
        .warning { color: red; font-weight: bold; }
    </style>
</head>
<body>
    <h1>Ordinateurs inactifs détectés</h1>
    <p>Date du rapport : $(Get-Date -Format 'dd/MM/yyyy HH:mm')</p>
    <p>Critère : Pas de connexion depuis $InactiveDays jours (avant le $($CutoffDate.ToString('dd/MM/yyyy')))</p>
    <p class="warning">Total : $($InactiveComputers.Count) ordinateurs</p>
    <table>
        <tr>
            <th>Nom</th>
            <th>Dernière connexion</th>
            <th>Système d'exploitation</th>
            <th>Description</th>
            <th>Action recommandée</th>
        </tr>
"@

foreach ($Computer in $InactiveComputers) {
    $LastLogon = if ($Computer.LastLogonDate) { $Computer.LastLogonDate.ToString('dd/MM/yyyy') } else { "Jamais" }
    $HTML += @"
        <tr>
            <td>$($Computer.Name)</td>
            <td>$LastLogon</td>
            <td>$($Computer.OperatingSystem)</td>
            <td>$($Computer.Description)</td>
            <td>Désactiver puis supprimer</td>
        </tr>
"@
}

$HTML += @"
    </table>
</body>
</html>
"@

$HTML | Out-File -FilePath $ReportPath
Write-Host "✓ Rapport généré : $ReportPath" -ForegroundColor Green

# Ouvrir le rapport
Invoke-Item $ReportPath
```

---

### Pièges courants

> [!warning] Piège 1 : Oublier le symbole $ Les noms SAM des ordinateurs se terminent par `$` dans AD. Si vous utilisez le SAMAccountName, incluez-le :
> 
> ```powershell
> # ❌ Incorrect
> Remove-ADComputer -Identity "PC-01"
> 
> # ✅ Correct
> Remove-ADComputer -Identity "PC-01$"
> 
> # ✅ Ou utiliser le nom DNS (sans $)
> Remove-ADComputer -Identity "PC-01"  # Fonctionne si Name est utilisé
> ```

> [!warning] Piège 2 : Supprimer un contrôleur de domaine Ne supprimez JAMAIS un DC avec `Remove-ADComputer` ! Utilisez la procédure de rétrogradation appropriée.
> 
> ```powershell
> # Vérifier si c'est un DC avant suppression
> $Computer = Get-ADComputer -Identity "SERVER-01" -Properties OperatingSystem
> if ($Computer.OperatingSystem -like "*Server*") {
>     Write-Warning "ATTENTION : Ceci semble être un serveur. Vérifiez qu'il ne s'agit pas d'un DC !"
>     $IsDC = Get-ADDomainController -Filter {Name -eq $Computer.Name}
>     if ($IsDC) {
>         Write-Error "ERREUR : Il s'agit d'un contrôleur de domaine. Utilisez la procédure de rétrogradation."
>         return
>     }
> }
> ```

> [!warning] Piège 3 : Ignorer les dépendances Certains ordinateurs peuvent avoir des dépendances (services hébergés, rôles spécifiques) :
> 
> ```powershell
> # Vérifier les groupes d'appartenance (peut indiquer des rôles)
> Get-ADComputer -Identity "PC-01" -Properties MemberOf |
>     Select-Object -ExpandProperty MemberOf
> 
> # Vérifier si l'ordinateur héberge des services critiques
> Get-Service -ComputerName "PC-01" |
>     Where-Object {$_.Status -eq "Running" -and $_.StartType -eq "Automatic"}
> ```

> [!warning] Piège 4 : Suppression pendant les heures ouvrées Planifiez les opérations de nettoyage en dehors des heures de production :
> 
> ```powershell
> # Exemple : n'autoriser l'exécution qu'en dehors des heures de travail
> $CurrentHour = (Get-Date).Hour
> if ($CurrentHour -ge 8 -and $CurrentHour -lt 18) {
>     Write-Warning "Opération non autorisée pendant les heures ouvrées (8h-18h)"
>     Write-Host "Planifiez cette tâche pour après 18h ou avant 8h."
>     exit
> }
> ```

> [!tip] Bonne pratique : Tester d'abord Utilisez toujours `-WhatIf` avant toute opération de suppression massive :
> 
> ```powershell
> # 1. Simulation
> Get-ADComputer -Filter {condition} | Remove-ADComputer -WhatIf
> 
> # 2. Vérification du nombre
> $Count = (Get-ADComputer -Filter {condition}).Count
> Write-Host "Nombre d'ordinateurs affectés : $Count"
> 
> # 3. Si OK, exécution réelle
> Get-ADComputer -Filter {condition} | Remove-ADComputer -Confirm
> ```

> [!warning] Piège 5 : Supprimer sans sauvegarde AD récente Assurez-vous toujours d'avoir une sauvegarde récente de l'Active Directory avant des opérations de suppression massives :
> 
> ```powershell
> # Vérifier la date de la dernière sauvegarde AD
> Get-ADObject -Filter {objectClass -eq "dSA"} -Properties whenCreated | 
>     Select-Object whenCreated
> 
> # Ou utiliser wbadmin si Windows Server Backup est configuré
> wbadmin get versions
> ```

> [!warning] Piège 6 : Oublier les effets sur DHCP/DNS La suppression d'un ordinateur n'efface pas automatiquement :
> 
> - Les réservations DHCP associées
> - Les enregistrements DNS statiques
> - Les certificats délivrés à la machine
> 
> Nettoyez manuellement ces éléments si nécessaire.

---

## 📊 Tableau récapitulatif des commandes

|Commande|Usage|Niveau de risque|
|---|---|---|
|`Remove-ADComputer -Identity "PC" -WhatIf`|Simulation sans impact|🟢 Aucun|
|`Remove-ADComputer -Identity "PC" -Confirm`|Suppression avec confirmation|🟡 Moyen|
|`Remove-ADComputer -Identity "PC" -Confirm:$false`|Suppression sans confirmation|🔴 Élevé|
|`Get-ADComputer -Filter {...} \| Remove-ADComputer`|Suppression massive|🔴 Très élevé|

---

## 🎯 Points clés à retenir

> [!tip] Checklist avant suppression ✅ Vérifier la dernière connexion (LastLogonDate) ✅ Tester la connectivité réseau (ping) ✅ Exporter les informations importantes ✅ Désactiver le compte en premier ✅ Attendre une période de grâce (30-60 jours) ✅ Utiliser `-WhatIf` pour simuler ✅ Vérifier que la Corbeille AD est activée ✅ S'assurer d'avoir les droits nécessaires ✅ Documenter et journaliser l'action ✅ Planifier hors heures ouvrées si possible

> [!info] Résumé des bonnes pratiques
> 
> - **Ne jamais supprimer immédiatement** : Toujours désactiver d'abord
> - **Sauvegarder avant de supprimer** : Exportez les propriétés importantes
> - **Utiliser -WhatIf systématiquement** : Simulez avant d'exécuter
> - **Journaliser toutes les actions** : Conservez une trace des suppressions
> - **Activer la Corbeille AD** : Permet la récupération en cas d'erreur
> - **Principe du moindre privilège** : Déléguez les droits de manière ciblée
> - **Planifier le nettoyage** : Automatisez la détection des ordinateurs obsolètes
> - **Documenter les procédures** : Créez des scripts standardisés et testés

---

## 🔧 Script complet de gestion du cycle de vie

Voici un script complet qui combine toutes les bonnes pratiques :

```powershell
<#
.SYNOPSIS
    Gestion complète du cycle de vie des ordinateurs AD
.DESCRIPTION
    Script de maintenance pour identifier, désactiver et supprimer les ordinateurs obsolètes
.PARAMETER Action
    identify : Liste les ordinateurs inactifs
    disable : Désactive les ordinateurs identifiés
    remove : Supprime les ordinateurs désactivés depuis longtemps
.PARAMETER InactiveDays
    Nombre de jours d'inactivité pour considérer un ordinateur comme obsolète (défaut: 180)
.PARAMETER GracePeriodDays
    Nombre de jours avant suppression après désactivation (défaut: 60)
.EXAMPLE
    .\Manage-ADComputers.ps1 -Action identify
    .\Manage-ADComputers.ps1 -Action disable -InactiveDays 90
    .\Manage-ADComputers.ps1 -Action remove -GracePeriodDays 30
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("identify", "disable", "remove", "report")]
    [string]$Action,
    
    [Parameter(Mandatory=$false)]
    [int]$InactiveDays = 180,
    
    [Parameter(Mandatory=$false)]
    [int]$GracePeriodDays = 60,
    
    [Parameter(Mandatory=$false)]
    [string]$SearchBase = "DC=contoso,DC=com",
    
    [Parameter(Mandatory=$false)]
    [string]$QuarantineOU = "OU=Disabled_Computers,DC=contoso,DC=com",
    
    [Parameter(Mandatory=$false)]
    [string]$LogPath = "C:\Logs\AD_Computer_Management.log"
)

# Fonction de journalisation
function Write-Log {
    param(
        [string]$Message,
        [ValidateSet("INFO", "WARNING", "ERROR", "SUCCESS")]
        [string]$Level = "INFO"
    )
    
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] [$Level] $Message"
    
    # Couleur selon le niveau
    $Color = switch ($Level) {
        "INFO"    { "White" }
        "WARNING" { "Yellow" }
        "ERROR"   { "Red" }
        "SUCCESS" { "Green" }
    }
    
    Write-Host $LogMessage -ForegroundColor $Color
    $LogMessage | Out-File -FilePath $LogPath -Append
}

# Fonction d'identification des ordinateurs inactifs
function Get-InactiveComputers {
    param([int]$Days)
    
    Write-Log "Recherche des ordinateurs inactifs depuis $Days jours..." -Level INFO
    
    $CutoffDate = (Get-Date).AddDays(-$Days)
    
    $InactiveComputers = Get-ADComputer -Filter * `
        -SearchBase $SearchBase `
        -Properties Name, LastLogonDate, OperatingSystem, Description, Enabled, DistinguishedName, Created |
        Where-Object {
            ($_.LastLogonDate -lt $CutoffDate -or $_.LastLogonDate -eq $null) -and
            $_.Enabled -eq $true
        }
    
    Write-Log "Trouvé $($InactiveComputers.Count) ordinateurs inactifs" -Level SUCCESS
    
    return $InactiveComputers
}

# Fonction de désactivation
function Disable-InactiveComputers {
    param($Computers)
    
    Write-Log "Début de la désactivation de $($Computers.Count) ordinateurs" -Level INFO
    
    $SuccessCount = 0
    $ErrorCount = 0
    
    foreach ($Computer in $Computers) {
        try {
            # Sauvegarder les infos
            $BackupPath = "C:\Backup\Computers\$($Computer.Name)_$(Get-Date -Format 'yyyyMMdd').xml"
            $Computer | Export-Clixml -Path $BackupPath -ErrorAction Stop
            
            # Désactiver
            Disable-ADAccount -Identity $Computer -ErrorAction Stop
            
            # Déplacer vers quarantaine
            Move-ADObject -Identity $Computer.DistinguishedName `
                -TargetPath $QuarantineOU `
                -ErrorAction Stop
            
            # Mettre à jour la description
            $DeletionDate = (Get-Date).AddDays($GracePeriodDays).ToString("dd/MM/yyyy")
            Set-ADComputer -Identity $Computer `
                -Description "Désactivé le $(Get-Date -Format 'dd/MM/yyyy') - Suppression prévue le $DeletionDate" `
                -ErrorAction Stop
            
            Write-Log "✓ $($Computer.Name) : Désactivé et déplacé" -Level SUCCESS
            $SuccessCount++
        }
        catch {
            Write-Log "✗ $($Computer.Name) : ERREUR - $_" -Level ERROR
            $ErrorCount++
        }
    }
    
    Write-Log "Désactivation terminée : $SuccessCount succès, $ErrorCount erreurs" -Level INFO
}

# Fonction de suppression
function Remove-DisabledComputers {
    param([int]$GraceDays)
    
    Write-Log "Recherche des ordinateurs à supprimer (désactivés depuis $GraceDays jours)..." -Level INFO
    
    $CutoffDate = (Get-Date).AddDays(-$GraceDays)
    
    $ComputersToRemove = Get-ADComputer -Filter {Enabled -eq $false} `
        -SearchBase $QuarantineOU `
        -Properties Name, Modified, Description, DistinguishedName |
        Where-Object { $_.Modified -lt $CutoffDate }
    
    Write-Log "Trouvé $($ComputersToRemove.Count) ordinateurs à supprimer" -Level WARNING
    
    if ($ComputersToRemove.Count -eq 0) {
        Write-Log "Aucun ordinateur à supprimer" -Level INFO
        return
    }
    
    # Afficher la liste
    Write-Host "`n=== Ordinateurs qui seront supprimés ===" -ForegroundColor Yellow
    $ComputersToRemove | Format-Table Name, Modified, Description -AutoSize
    
    $Confirmation = Read-Host "`nÊtes-vous sûr de vouloir supprimer ces $($ComputersToRemove.Count) ordinateurs ? (OUI en majuscules pour confirmer)"
    
    if ($Confirmation -ne "OUI") {
        Write-Log "Suppression annulée par l'utilisateur" -Level WARNING
        return
    }
    
    $SuccessCount = 0
    $ErrorCount = 0
    
    foreach ($Computer in $ComputersToRemove) {
        try {
            # Dernière sauvegarde
            $FinalBackupPath = "C:\Backup\Computers\Deleted\$($Computer.Name)_$(Get-Date -Format 'yyyyMMdd_HHmmss').xml"
            Get-ADComputer -Identity $Computer -Properties * | 
                Export-Clixml -Path $FinalBackupPath -ErrorAction Stop
            
            # Supprimer
            Remove-ADComputer -Identity $Computer -Confirm:$false -ErrorAction Stop
            
            Write-Log "✓ $($Computer.Name) : Supprimé" -Level SUCCESS
            $SuccessCount++
        }
        catch {
            Write-Log "✗ $($Computer.Name) : ERREUR - $_" -Level ERROR
            $ErrorCount++
        }
    }
    
    Write-Log "Suppression terminée : $SuccessCount succès, $ErrorCount erreurs" -Level INFO
}

# Fonction de rapport HTML
function Generate-Report {
    $ReportPath = "C:\Reports\AD_Computer_Status_$(Get-Date -Format 'yyyyMMdd_HHmmss').html"
    
    Write-Log "Génération du rapport..." -Level INFO
    
    # Récupérer les statistiques
    $AllComputers = Get-ADComputer -Filter * -SearchBase $SearchBase -Properties Enabled, LastLogonDate
    $EnabledComputers = ($AllComputers | Where-Object {$_.Enabled -eq $true}).Count
    $DisabledComputers = ($AllComputers | Where-Object {$_.Enabled -eq $false}).Count
    $InactiveComputers = Get-InactiveComputers -Days $InactiveDays
    $QuarantinedComputers = Get-ADComputer -Filter * -SearchBase $QuarantineOU
    
    $HTML = @"
<!DOCTYPE html>
<html>
<head>
    <title>Rapport de statut - Ordinateurs AD</title>
    <style>
        body { 
            font-family: 'Segoe UI', Arial, sans-serif; 
            margin: 20px;
            background-color: #f5f5f5;
        }
        .container {
            max-width: 1200px;
            margin: 0 auto;
            background-color: white;
            padding: 20px;
            box-shadow: 0 0 10px rgba(0,0,0,0.1);
        }
        h1 { 
            color: #2c3e50; 
            border-bottom: 3px solid #3498db;
            padding-bottom: 10px;
        }
        h2 {
            color: #34495e;
            margin-top: 30px;
        }
        .stats {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin: 20px 0;
        }
        .stat-box {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 20px;
            border-radius: 8px;
            text-align: center;
        }
        .stat-box.warning {
            background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
        }
        .stat-box.success {
            background: linear-gradient(135deg, #4facfe 0%, #00f2fe 100%);
        }
        .stat-number {
            font-size: 36px;
            font-weight: bold;
            margin: 10px 0;
        }
        .stat-label {
            font-size: 14px;
            opacity: 0.9;
        }
        table { 
            border-collapse: collapse; 
            width: 100%; 
            margin: 20px 0;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        th { 
            background-color: #3498db; 
            color: white; 
            padding: 12px; 
            text-align: left;
            font-weight: 600;
        }
        td { 
            border: 1px solid #ddd; 
            padding: 10px; 
        }
        tr:nth-child(even) { 
            background-color: #f8f9fa; 
        }
        tr:hover {
            background-color: #e9ecef;
        }
        .warning-text { 
            color: #e74c3c; 
            font-weight: bold; 
        }
        .info-box {
            background-color: #e8f4f8;
            border-left: 4px solid #3498db;
            padding: 15px;
            margin: 20px 0;
        }
        .footer {
            margin-top: 40px;
            padding-top: 20px;
            border-top: 1px solid #ddd;
            text-align: center;
            color: #7f8c8d;
            font-size: 12px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>📊 Rapport de statut - Ordinateurs Active Directory</h1>
        
        <div class="info-box">
            <strong>Date du rapport :</strong> $(Get-Date -Format 'dddd dd MMMM yyyy à HH:mm:ss')<br>
            <strong>Généré par :</strong> $env:USERNAME<br>
            <strong>Domaine :</strong> $env:USERDNSDOMAIN
        </div>
        
        <h2>📈 Statistiques globales</h2>
        <div class="stats">
            <div class="stat-box success">
                <div class="stat-label">ORDINATEURS ACTIFS</div>
                <div class="stat-number">$EnabledComputers</div>
            </div>
            <div class="stat-box">
                <div class="stat-label">ORDINATEURS DÉSACTIVÉS</div>
                <div class="stat-number">$DisabledComputers</div>
            </div>
            <div class="stat-box warning">
                <div class="stat-label">ORDINATEURS INACTIFS</div>
                <div class="stat-number">$($InactiveComputers.Count)</div>
                <div class="stat-label">(&gt; $InactiveDays jours)</div>
            </div>
            <div class="stat-box">
                <div class="stat-label">EN QUARANTAINE</div>
                <div class="stat-number">$($QuarantinedComputers.Count)</div>
            </div>
        </div>
        
        <h2>⚠️ Ordinateurs inactifs nécessitant une action</h2>
        <p>Ces ordinateurs n'ont pas été connectés depuis plus de <strong>$InactiveDays jours</strong> :</p>
        <table>
            <tr>
                <th>Nom</th>
                <th>Dernière connexion</th>
                <th>Système d'exploitation</th>
                <th>Description</th>
                <th>Jours d'inactivité</th>
            </tr>
"@
    
    foreach ($Computer in $InactiveComputers) {
        $LastLogon = if ($Computer.LastLogonDate) { 
            $Computer.LastLogonDate.ToString('dd/MM/yyyy HH:mm') 
        } else { 
            "Jamais connecté" 
        }
        
        $DaysInactive = if ($Computer.LastLogonDate) {
            ((Get-Date) - $Computer.LastLogonDate).Days
        } else {
            "N/A"
        }
        
        $HTML += @"
            <tr>
                <td>$($Computer.Name)</td>
                <td>$LastLogon</td>
                <td>$($Computer.OperatingSystem)</td>
                <td>$($Computer.Description)</td>
                <td class="warning-text">$DaysInactive</td>
            </tr>
"@
    }
    
    $HTML += @"
        </table>
        
        <h2>🔒 Ordinateurs en quarantaine</h2>
        <p>Ces ordinateurs sont désactivés et en attente de suppression :</p>
        <table>
            <tr>
                <th>Nom</th>
                <th>Date de modification</th>
                <th>Description</th>
            </tr>
"@
    
    foreach ($Computer in $QuarantinedComputers) {
        $HTML += @"
            <tr>
                <td>$($Computer.Name)</td>
                <td>$($Computer.Modified.ToString('dd/MM/yyyy HH:mm'))</td>
                <td>$($Computer.Description)</td>
            </tr>
"@
    }
    
    $HTML += @"
        </table>
        
        <div class="info-box">
            <strong>📌 Actions recommandées :</strong>
            <ul>
                <li>Désactiver les ordinateurs inactifs identifiés</li>
                <li>Vérifier les ordinateurs en quarantaine depuis plus de $GracePeriodDays jours</li>
                <li>Supprimer les ordinateurs désactivés après la période de grâce</li>
            </ul>
        </div>
        
        <div class="footer">
            Généré par le script de gestion des ordinateurs AD - Version 1.0
        </div>
    </div>
</body>
</html>
"@
    
    $HTML | Out-File -FilePath $ReportPath -Encoding UTF8
    Write-Log "✓ Rapport généré : $ReportPath" -Level SUCCESS
    
    # Ouvrir le rapport
    Invoke-Item $ReportPath
}

# ==================================================
# EXÉCUTION PRINCIPALE
# ==================================================

Write-Log "=== Début de l'exécution ===" -Level INFO
Write-Log "Action : $Action" -Level INFO
Write-Log "Jours d'inactivité : $InactiveDays" -Level INFO
Write-Log "Période de grâce : $GracePeriodDays jours" -Level INFO

switch ($Action) {
    "identify" {
        $InactiveComputers = Get-InactiveComputers -Days $InactiveDays
        if ($InactiveComputers.Count -gt 0) {
            $InactiveComputers | Format-Table Name, LastLogonDate, OperatingSystem, Description -AutoSize
        }
    }
    
    "disable" {
        $InactiveComputers = Get-InactiveComputers -Days $InactiveDays
        if ($InactiveComputers.Count -gt 0) {
            $Confirmation = Read-Host "Voulez-vous désactiver ces $($InactiveComputers.Count) ordinateurs ? (O/N)"
            if ($Confirmation -eq 'O') {
                Disable-InactiveComputers -Computers $InactiveComputers
            } else {
                Write-Log "Opération annulée" -Level WARNING
            }
        }
    }
    
    "remove" {
        Remove-DisabledComputers -GraceDays $GracePeriodDays
    }
    
    "report" {
        Generate-Report
    }
}

Write-Log "=== Fin de l'exécution ===" -Level INFO
```

---

## 🎓 Synthèse finale

La cmdlet `Remove-ADComputer` est un outil puissant mais potentiellement dangereux qui nécessite :

1. **Une planification rigoureuse** : Ne jamais supprimer impulsivement
2. **Des vérifications multiples** : LastLogonDate, connectivité, dépendances
3. **Un processus graduel** : Désactivation → Quarantaine → Suppression
4. **Une traçabilité complète** : Sauvegardes, logs, rapports
5. **Des garde-fous** : -WhatIf, -Confirm, validation manuelle
6. **Une récupération possible** : Corbeille AD activée

En suivant ces principes et en utilisant les scripts fournis, vous pourrez maintenir un Active Directory propre et à jour tout en minimisant les risques d'erreur.