# Script de mise à jour des utilisateurs Active Directory à partir d'un fichier RH .csv
# Auteur : Christian
#
# Ce script gère :
#   - Les nouveaux collaborateurs      → Création du compte AD
#   - Les départs de collaborateurs    → Désactivation + déplacement dans Disabled_Users (jamais supprimé)
#   - Les modifications d'informations → Mise à jour des attributs AD
#   - Les changements hiérarchiques    → Mise à jour du manager
#   - Les changements d'OU             → Déplacement automatique si département/service modifié
#   - Les nouvelles OUs                → Création automatique si inexistantes
#
# IMPORTANT : La correspondance CSV ↔ AD se fait par SamAccountName (ASCII pur),
#             ce qui évite tout problème d'encodage sur les caractères accentués.

# Sommaire
# 01 - VARIABLES
# 02 - TABLES DE MAPPING
# 03 - FONCTIONS UTILITAIRES
# 04 - VÉRIFICATIONS
# 05 - DONNÉES CSV
# 06 - PHASE 1 : DÉSACTIVATION DES COMPTES (DÉPARTS)
# 07 - PHASE 2 : INTÉGRATION DES NOUVEAUX ARRIVANTS
# 08 - PHASE 3 : MISE À JOUR DES UTILISATEURS EXISTANTS
# 09 - PHASE 4 : ATTRIBUTION DES MANAGERS
# 10 - RÉSUMÉ


#==========================================================
#region 01 - VARIABLES
#==========================================================

# Emplacement du fichier CSV de mise à jour RH
$SourceCSV = "C:\Users\Administrator\Documents\s04-a02-BillU-ListeRHCollaborateurs.csv"

# Configuration AD
$DomainDN   = "DC=billu,DC=lan"
$DomainName = "@billu.lan"

# Mot de passe par défaut pour les nouveaux arrivants
$DefaultPassword = "Azerty1*"

# OU de base contenant tous les utilisateurs actifs
$BaseOU = "OU=BilluUsers,$DomainDN"

# OU de destination pour les comptes désactivés (départs)
# Créée automatiquement si elle n'existe pas
$DisabledOU = "OU=Disabled_Users,$DomainDN"

# Compteurs pour le résumé final
$UsersCreated  = 0
$UsersUpdated  = 0
$UsersDisabled = 0
$UsersSkipped  = 0
$ManagerErrors = 0
$ErrorsList    = @()

# Stockage SamAccountName pour la phase 4 (managers)
$AccountsIndex = @{}

#endregion


#==========================================================
#region 02 - TABLES DE MAPPING
#==========================================================

# Mapping Département (nom RH) → nom OU dans l'AD
# Contient les anciens noms ET les nouveaux noms (renommages RH entre les deux fichiers)
$DepartementMapping = @{
    # Noms d'origine (fichier s01)
    "Service Commercial"                   = "COMMERCIAL"
    "Communication et Relations publiques" = "COMMUNICATION"
    "Finance et Comptabilité"              = "COMPTABILITE"
    "Développement logiciel"               = "DEV"
    "Direction"                            = "DIRECTION"
    "DSI"                                  = "DSI"
    "Département Juridique"                = "JURIDIQUE"
    "QHSE"                                 = "QHSE"
    "Service recrutement"                  = "RH"

    # Noms mis à jour (fichier s04 — renommages RH)
    "Département Commercial"               = "COMMERCIAL"
    "Département dev logiciel"             = "DEV"
    "Direction des ressources humaines"    = "RH"
}

# Mapping Service (nom RH) → nom sous-OU dans l'AD
$ServiceMapping = @{
    # COMMERCIAL
    "ADV"                                  = "ADMINISTRATION_DES_VENTES"
    "B2B"                                  = "B2B"
    "Service achat"                        = "SERVICE_ACHAT"
    "Service Client"                       = "SERVICE_CLIENT"

    # COMMUNICATION
    "Relation Médias"                      = "RELATION_MEDIAS"
    "Communication interne"                = "COMMUNICATION_INTERNE"
    "Gestion des marques"                  = "GESTION_MARQUES"

    # COMPTABILITE
    "Finance"                              = "FINANCE"
    "Fiscalité"                            = "FISCALITE"
    "Service Comptabilité"                 = "SERVICE_COMPTABILITE"

    # DEVELOPPEMENT
    "analyse et conception"                = "ANALYSE_CONCEPTION"
    "Développement"                        = "DEVELOPPEMENT"
    "Recherche et Prototype"               = "RECHERCHE_PROTOTYPAGE"
    "Tests et qualité"                     = "TESTS_QUALITE"

    # DSI
    "Administration Systèmes et Réseaux"   = "ADMINISTRATION_SYSTEMES_RESEAUX"
    "Développement et Intégration"         = "DEVELOPPEMENT_INTEGRATION"
    "Exploitation"                         = "EXPLOITATION"
    "Support"                              = "SUPPORT"

    # JURIDIQUE
    "Droit des sociétés"                   = "DROIT_DES_SOCIETES"
    "Protection des données et conformité" = "PROTECTION_DONNEES_CONFORMITES"
    "Propriété intellectuelle"             = "PROPRIETES_INTELLECTUELLES"

    # QHSE
    "Certification"                        = "CERTIFICATION"
    "Contrôle Qualité"                     = "CONTROLE_QUALITE"
    "Gestion environnementale"             = "GESTION_ENVIRONNEMENTALE"
}

#endregion


#==========================================================
#region 03 - FONCTIONS UTILITAIRES
#==========================================================

# Remplace les caractères accentués et supprime apostrophes/espaces/tirets
# Résultat toujours en ASCII pur → utilisé pour construire les SamAccountName
function Clean-Name {
    param([string]$Name)

    $Name = $Name -replace "[éèêë]", "e" -replace "[àâäá]", "a" -replace "[ôö]", "o" `
                  -replace "[ùûü]",  "u" -replace "[ïî]",   "i" -replace "[ç]",   "c" `
                  -replace "[ÉÈÊË]", "E" -replace "[ÀÂÄÁ]", "A" -replace "[ÔÖ]",  "O" `
                  -replace "[ÙÛÜ]",  "U" -replace "[ÏÎ]",   "I" -replace "[Ç]",   "C"

    $Name = $Name -replace "[''\s-]", ""
    return $Name
}

# Calcule le SamAccountName attendu pour un prénom/nom SANS interroger l'AD
# Logique identique à createUsersAD.ps1 → permet de retrouver un compte existant de façon fiable
function Get-ExpectedSam {
    param([string]$Prenom, [string]$Nom)

    $Sam = "$(Clean-Name $Prenom).$(Clean-Name $Nom)".ToLower()
    if ($Sam.Length -gt 20) { $Sam = $Sam.Substring(0, 20) }
    return $Sam
}

# Génère un SamAccountName unique (avec suffixe numérique si doublon) — pour les nouvelles créations
function Get-SamAccountName {
    param([string]$Prenom, [string]$Nom)

    $Sam     = Get-ExpectedSam -Prenom $Prenom -Nom $Nom
    $Counter = 2
    $Final   = $Sam

    while (Get-ADUser -Filter "SamAccountName -eq '$Final'" -ErrorAction SilentlyContinue) {
        $Final = "$Sam$Counter"
        if ($Final.Length -gt 20) {
            $Final = $Sam.Substring(0, 20 - $Counter.ToString().Length) + $Counter
        }
        $Counter++
    }

    return $Final
}

# Construit le chemin OU cible
function Get-OUPath {
    param([string]$Departement, [string]$Service)

    $DeptOU = $DepartementMapping[$Departement]
    if ([string]::IsNullOrWhiteSpace($DeptOU)) {
        throw "Département '$Departement' non trouvé dans le mapping"
    }

    if (-not [string]::IsNullOrWhiteSpace($Service)) {
        $ServiceOU = $ServiceMapping[$Service]
        if ([string]::IsNullOrWhiteSpace($ServiceOU)) {
            throw "Service '$Service' non trouvé dans le mapping"
        }
        return "OU=$ServiceOU,OU=$DeptOU,OU=BilluUsers,$DomainDN"
    }

    return "OU=$DeptOU,OU=BilluUsers,$DomainDN"
}

# Vérifie qu'une OU existe, et la crée (ainsi que ses parents) si nécessaire
function Ensure-OU {
    param([string]$OUPath)

    $Segments = $OUPath -split ",(?=OU=|DC=)"

    for ($i = $Segments.Count - 1; $i -ge 0; $i--) {
        if ($Segments[$i] -notmatch "^OU=") { continue }

        $CurrentPath = ($Segments[$i..($Segments.Count - 1)]) -join ","
        $ParentPath  = ($Segments[($i + 1)..($Segments.Count - 1)]) -join ","
        $OUName      = $Segments[$i] -replace "^OU=", ""

        try {
            Get-ADOrganizationalUnit -Identity $CurrentPath -ErrorAction Stop | Out-Null
        } catch {
            try {
                New-ADOrganizationalUnit -Name $OUName -Path $ParentPath `
                    -ProtectedFromAccidentalDeletion $false -ErrorAction Stop
                Write-Host "  [OU CRÉÉE] $CurrentPath" -ForegroundColor Magenta
            } catch {
                Write-Host "  [ERREUR OU] '$OUName' sous '$ParentPath' : $($_.Exception.Message)" -ForegroundColor Red
            }
        }
    }
}

#endregion


#==========================================================
#region 04 - VÉRIFICATIONS
#==========================================================

Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║  Script de mise à jour des utilisateurs Active Directory  ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Write-Host "[VÉRIFICATION] Fichier CSV ($SourceCSV)..." -NoNewline
if (-not (Test-Path $SourceCSV)) {
    Write-Host " ERREUR" -ForegroundColor Red
    Write-Host "Fichier introuvable : $SourceCSV" -ForegroundColor Red
    exit 1
}
Write-Host " OK" -ForegroundColor Green

Write-Host "[VÉRIFICATION] OU BilluUsers..." -NoNewline
try {
    Get-ADOrganizationalUnit -Identity $BaseOU -ErrorAction Stop | Out-Null
    Write-Host " OK" -ForegroundColor Green
} catch {
    Write-Host " INTROUVABLE" -ForegroundColor Red
    Write-Host "L'OU BilluUsers n'existe pas. Veuillez d'abord exécuter createUsersAD.ps1." -ForegroundColor Red
    exit 1
}

Write-Host "[VÉRIFICATION] OU Disabled_Users..." -NoNewline
try {
    Get-ADOrganizationalUnit -Identity $DisabledOU -ErrorAction Stop | Out-Null
    Write-Host " OK" -ForegroundColor Green
} catch {
    try {
        New-ADOrganizationalUnit -Name "Disabled_Users" -Path $DomainDN `
            -ProtectedFromAccidentalDeletion $false -ErrorAction Stop
        Write-Host " CRÉÉE" -ForegroundColor Yellow
    } catch {
        Write-Host " ERREUR — $($_.Exception.Message)" -ForegroundColor Red
        exit 1
    }
}

#endregion


#==========================================================
#region 05 - DONNÉES CSV
#==========================================================

# Le fichier CSV est encodé en Windows-1252 (Latin-1), PAS en UTF-8 → utiliser "Default"
$SourceData     = Import-Csv -Path $SourceCSV -Delimiter ";" -Encoding Default
$SecurePassword = ConvertTo-SecureString -String $DefaultPassword -AsPlainText -Force

# Filtre les lignes vides
$SourceData = $SourceData | Where-Object {
    -not [string]::IsNullOrWhiteSpace($_.Prenom) -and
    -not [string]::IsNullOrWhiteSpace($_.Nom)
}

Write-Host ""
Write-Host "Utilisateurs dans le fichier RH mis à jour : $($SourceData.Count)" -ForegroundColor Cyan

# Index CSV par SamAccountName calculé (ASCII pur, indépendant de tout encodage)
$CSVIndex = @{}
foreach ($Row in $SourceData) {
    $Sam = Get-ExpectedSam -Prenom $Row.Prenom -Nom $Row.Nom
    $CSVIndex[$Sam] = $Row
}

#endregion


#==========================================================
#region 06 - PHASE 1 : DÉSACTIVATION DES COMPTES (DÉPARTS)
#==========================================================

Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Yellow
Write-Host "║         PHASE 1 : DÉTECTION ET TRAITEMENT DES DÉPARTS     ║" -ForegroundColor Yellow
Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Yellow
Write-Host ""
Write-Host "Recherche des collaborateurs absents du nouveau fichier RH..." -ForegroundColor Gray
Write-Host ""

$ADActiveUsers = Get-ADUser -Filter * `
    -SearchBase $BaseOU `
    -Properties SamAccountName, GivenName, Surname, Enabled, DistinguishedName `
    -ErrorAction SilentlyContinue

$DepartsCount = 0

foreach ($ADUser in $ADActiveUsers) {

    # Comparaison par SamAccountName : ASCII pur, aucun problème d'encodage possible
    if (-not $CSVIndex.ContainsKey($ADUser.SamAccountName)) {

        try {
            Disable-ADAccount -Identity $ADUser.SamAccountName -ErrorAction Stop

            Set-ADUser -Identity $ADUser.SamAccountName `
                -Description "DEPART - Compte désactivé le $(Get-Date -Format 'dd/MM/yyyy') - Traitement RH automatique" `
                -ErrorAction Stop

            Move-ADObject -Identity $ADUser.DistinguishedName `
                -TargetPath $DisabledOU `
                -ErrorAction Stop

            Write-Host "[DÉSACTIVÉ]" -ForegroundColor Yellow -NoNewline
            Write-Host " $($ADUser.GivenName) $($ADUser.Surname)" -NoNewline
            Write-Host " ($($ADUser.SamAccountName))" -ForegroundColor Gray -NoNewline
            Write-Host " → Déplacé dans Disabled_Users" -ForegroundColor DarkYellow

            $UsersDisabled++
            $DepartsCount++

        } catch {
            Write-Host "[ERREUR DÉSACTIVATION]" -ForegroundColor Red -NoNewline
            Write-Host " $($ADUser.GivenName) $($ADUser.Surname) → $($_.Exception.Message)" -ForegroundColor Red

            $ErrorsList += [PSCustomObject]@{
                Utilisateur = "$($ADUser.GivenName) $($ADUser.Surname)"
                Phase       = "Désactivation"
                Erreur      = $_.Exception.Message
            }
        }
    }
}

if ($DepartsCount -eq 0) {
    Write-Host "Aucun départ détecté." -ForegroundColor Gray
}

#endregion


#==========================================================
#region 07 - PHASE 2 : INTÉGRATION DES NOUVEAUX ARRIVANTS
#==========================================================

Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Green
Write-Host "║         PHASE 2 : INTÉGRATION DES NOUVEAUX ARRIVANTS      ║" -ForegroundColor Green
Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Green
Write-Host ""

foreach ($User in $SourceData) {

    $ExpectedSam  = Get-ExpectedSam -Prenom $User.Prenom -Nom $User.Nom
    $ExistingUser = Get-ADUser -Filter "SamAccountName -eq '$ExpectedSam'" `
        -Properties SamAccountName, Department, Title, Company, OfficePhone, MobilePhone, `
                    Enabled, DistinguishedName, Manager `
        -ErrorAction SilentlyContinue

    if ($ExistingUser) {
        # Déjà dans l'AD → traité en phase 3
        $AccountsIndex[$ExpectedSam] = $ExistingUser.SamAccountName
        continue
    }

    # Introuvable dans l'AD → nouvel arrivant
    try {
        $SamAccount = Get-SamAccountName -Prenom $User.Prenom -Nom $User.Nom
        $UPN        = "$SamAccount$DomainName"
        $OUPath     = Get-OUPath -Departement $User.Departement -Service $User.Service

        Ensure-OU -OUPath $OUPath

        New-ADUser `
            -Name              "$($User.Prenom) $($User.Nom)" `
            -GivenName         $User.Prenom `
            -Surname           $User.Nom `
            -SamAccountName    $SamAccount `
            -UserPrincipalName $UPN `
            -DisplayName       "$($User.Prenom) $($User.Nom)" `
            -EmailAddress      $UPN `
            -Path              $OUPath `
            -AccountPassword   $SecurePassword `
            -Enabled           $true `
            -ChangePasswordAtLogon $true `
            -Department        $User.Departement `
            -Title             $User.fonction `
            -Company           $User.Societe `
            -OfficePhone       $User.'Telephone fixe' `
            -MobilePhone       $User.'Telephone portable' `
            -ErrorAction Stop

        $AccountsIndex[$ExpectedSam] = $SamAccount

        Write-Host "[CRÉÉ]" -ForegroundColor Green -NoNewline
        Write-Host " $($User.Prenom) $($User.Nom)" -NoNewline
        Write-Host " → SamAccount: " -NoNewline -ForegroundColor Gray
        Write-Host $SamAccount -ForegroundColor Yellow

        $UsersCreated++

    } catch {
        Write-Host "[ERREUR CRÉATION]" -ForegroundColor Red -NoNewline
        Write-Host " $($User.Prenom) $($User.Nom) → $($_.Exception.Message)" -ForegroundColor Red

        $ErrorsList += [PSCustomObject]@{
            Utilisateur = "$($User.Prenom) $($User.Nom)"
            Phase       = "Création"
            Erreur      = $_.Exception.Message
        }
        $UsersSkipped++
    }
}

#endregion


#==========================================================
#region 08 - PHASE 3 : MISE À JOUR DES UTILISATEURS EXISTANTS
#==========================================================

Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║          PHASE 3 : MODIFICATIONS UTILISATEURS              ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

foreach ($User in $SourceData) {

    $ExpectedSam  = Get-ExpectedSam -Prenom $User.Prenom -Nom $User.Nom

    # Ignore les nouveaux arrivants (pas encore dans l'index au moment de la phase 2)
    if (-not $AccountsIndex.ContainsKey($ExpectedSam)) { continue }

    $ExistingUser = Get-ADUser -Filter "SamAccountName -eq '$ExpectedSam'" `
        -Properties SamAccountName, Department, Title, Company, OfficePhone, MobilePhone, `
                    Enabled, DistinguishedName, Manager `
        -ErrorAction SilentlyContinue

    if (-not $ExistingUser) { continue }

    $SamAccount = $ExistingUser.SamAccountName
    $Changes    = @()

    try {
        $NewOUPath = Get-OUPath -Departement $User.Departement -Service $User.Service
        Ensure-OU -OUPath $NewOUPath

        $UpdateParams = @{}

        if ($ExistingUser.Department -ne $User.Departement) {
            $UpdateParams["Department"] = $User.Departement
            $Changes += "Département → '$($User.Departement)'"
        }

        if ($ExistingUser.Title -ne $User.fonction) {
            $UpdateParams["Title"] = $User.fonction
            $Changes += "Fonction → '$($User.fonction)'"
        }

        if ($ExistingUser.Company -ne $User.Societe) {
            $UpdateParams["Company"] = $User.Societe
            $Changes += "Société → '$($User.Societe)'"
        }

        $NewFixe   = $User.'Telephone fixe'
        $NewMobile = $User.'Telephone portable'

        if ($NewFixe -ne '-' -and $NewFixe -ne $ExistingUser.OfficePhone) {
            $UpdateParams["OfficePhone"] = $NewFixe
            $Changes += "Tél. fixe mis à jour"
        }

        if ($NewMobile -ne '-' -and $NewMobile -ne $ExistingUser.MobilePhone) {
            $UpdateParams["MobilePhone"] = $NewMobile
            $Changes += "Tél. mobile mis à jour"
        }

        if ($UpdateParams.Count -gt 0) {
            Set-ADUser -Identity $SamAccount @UpdateParams -ErrorAction Stop
        }

        # Déplacement d'OU si nécessaire
        $CurrentOU = $ExistingUser.DistinguishedName -replace "^CN=[^,]+,", ""
        if ($CurrentOU -ne $NewOUPath) {
            Move-ADObject -Identity $ExistingUser.DistinguishedName `
                -TargetPath $NewOUPath -ErrorAction Stop
            $Changes += "OU déplacé"
        }

        # Réactivation si compte désactivé (ex : réintégration)
        if (-not $ExistingUser.Enabled) {
            Enable-ADAccount -Identity $SamAccount -ErrorAction Stop
            $Changes += "Compte RÉACTIVÉ"
        }

        if ($Changes.Count -gt 0) {
            Write-Host "[MIS À JOUR]" -ForegroundColor Cyan -NoNewline
            Write-Host " $($User.Prenom) $($User.Nom)" -NoNewline
            Write-Host " → $($Changes -join ' | ')" -ForegroundColor Gray
            $UsersUpdated++
        }

    } catch {
        Write-Host "[ERREUR MISE À JOUR]" -ForegroundColor Red -NoNewline
        Write-Host " $($User.Prenom) $($User.Nom) → $($_.Exception.Message)" -ForegroundColor Red

        $ErrorsList += [PSCustomObject]@{
            Utilisateur = "$($User.Prenom) $($User.Nom)"
            Phase       = "Mise à jour"
            Erreur      = $_.Exception.Message
        }
    }
}

#endregion


#==========================================================
#region 09 - PHASE 4 : ATTRIBUTION DES MANAGERS
#==========================================================

Write-Host ""
Write-Host "[INFO] Mise à jour des relations hiérarchiques (managers)..." -ForegroundColor Cyan
Write-Host ""

foreach ($User in $SourceData) {

    if ([string]::IsNullOrWhiteSpace($User.'Manager-Prenom') -or
        [string]::IsNullOrWhiteSpace($User.'Manager-Nom')) { continue }

    $UserSam    = Get-ExpectedSam -Prenom $User.Prenom -Nom $User.Nom
    $ManagerSam = Get-ExpectedSam -Prenom $User.'Manager-Prenom' -Nom $User.'Manager-Nom'

    $SamAccount        = $AccountsIndex[$UserSam]
    $ManagerSamAccount = $AccountsIndex[$ManagerSam]

    if ($SamAccount -and $ManagerSamAccount) {
        try {
            $ManagerAD = Get-ADUser -Identity $ManagerSamAccount -ErrorAction Stop
            Set-ADUser -Identity $SamAccount -Manager $ManagerAD.DistinguishedName -ErrorAction Stop
            Write-Host "  [OK] $($User.Prenom) $($User.Nom)" -ForegroundColor Gray -NoNewline
            Write-Host " → Manager: $($User.'Manager-Prenom') $($User.'Manager-Nom')" -ForegroundColor DarkGray
        } catch {
            Write-Host "  [ERREUR MANAGER] $($User.Prenom) $($User.Nom) → $($_.Exception.Message)" -ForegroundColor DarkRed
            $ManagerErrors++
        }
    } else {
        if (-not $SamAccount) {
            Write-Host "  [AVERTISSEMENT] Utilisateur '$($User.Prenom) $($User.Nom)' non trouvé dans l'index." -ForegroundColor DarkYellow
        }
        if (-not $ManagerSamAccount) {
            Write-Host "  [AVERTISSEMENT] Manager '$($User.'Manager-Prenom') $($User.'Manager-Nom')' introuvable pour '$($User.Prenom) $($User.Nom)'." -ForegroundColor DarkYellow
        }
        $ManagerErrors++
    }
}

#endregion


#==========================================================
#region 10 - RÉSUMÉ
#==========================================================

$TotalErrors = $ErrorsList.Count

Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                         RÉSUMÉ                            ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "Utilisateurs dans le fichier RH     : $($SourceData.Count)" -ForegroundColor White
Write-Host ""
Write-Host "  Nouveaux arrivants créés          : $UsersCreated"  -ForegroundColor Green
Write-Host "  Collaborateurs mis à jour         : $UsersUpdated"  -ForegroundColor Cyan
Write-Host "  Comptes désactivés (départs)      : $UsersDisabled" -ForegroundColor Yellow
Write-Host "  Utilisateurs non traités (erreurs): $UsersSkipped"  -ForegroundColor Red
Write-Host ""
Write-Host "  Erreurs attribution manager       : $ManagerErrors" -ForegroundColor Yellow
Write-Host "  Total erreurs                     : $TotalErrors"   -ForegroundColor $(if ($TotalErrors -gt 0) { "Red" } else { "Green" })
Write-Host ""

if ($ErrorsList.Count -gt 0) {
    Write-Host "DÉTAIL DES ERREURS :" -ForegroundColor Red
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Red
    $ErrorsList | Format-Table -AutoSize
}

Write-Host "Terminé !" -ForegroundColor Green
Write-Host ""

#endregion
