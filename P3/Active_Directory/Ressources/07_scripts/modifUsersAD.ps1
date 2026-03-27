# Script de modification d'utilisateur Active Directory à partir d'un fichier .csv
# Auteur : Franck

# Sommaire
# 01 - VARIABLES
# 02 - TABLES DE MAPPING
# 03 - FONCTIONS UTILITAIRES
# 04 - VÉRIFICATIONS DU FICHIER CSV
# 05 - DONNEES FICHIERS CSV
# 06 - CRÉATION DES UTILISATEURS
# 07 - DESACTIVATION DES COMPTES SORTANTS
# 08 - RÉSUMÉ

#==========================================================
#region 01 - VARIABLES
#==========================================================

# Emplacement du fichier csv
$SourceCSV = "C:\Users\Administrator\Documents\s04-a02-BillU-ListeRHCollaborateurs.csv"

# Configuration AD
$DomainDN = "DC=billu,DC=lan"

# Suffixe pour les adresses mails
$DomainName = "@billu.lan"

# Mot de passe par défaut
$DefaultPassword = "Azerty1*" 

# Compteurs pour le résumé
$UsersCreated = 0
$UsersSkipped = 0
$ErrorsList = @()
$ManagerErrors = 0

# Stockage des comptes créés
$CreatedAccounts = @{}

# Modification des utilisateurs
$UsersUpdated = 0

# Desactivation des utilisateurs
$UsersDisabled = 0

#endregion


#==========================================================
#region 02 - TABLES DE MAPPING
#==========================================================

# Hashtables des Départements
$DepartementMapping = @{
    "Département Commercial"               = "COMMERCIAL"
    "Communication et Relations publiques" = "COMMUNICATION"
    "Finance et Comptabilité"              = "COMPTABILITE"
    "Développement dev logiciel"           = "DEV"
    "Direction générale"                   = "DIRECTION"
    "DSI"                                  = "DSI"
    "Département Juridique"                = "JURIDIQUE"
    "QHSE"                                 = "QHSE"
    "Direction des ressources humaines"    = "RH"
}

# Hashtables des Services 
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
    "Dev tests"                            = "DEV_TEST"

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

# Remplace les charactères spéciaux pour la création des noms de compte
function Clean-Name {
    param([string]$Name)
    
    $Name = $Name -replace "[éèêë]", "e" -replace "[àâäá]", "a" -replace "[ôö]", "o" `
        -replace "[ùûü]", "u" -replace "[ïî]", "i" -replace "[ç]", "c" `
        -replace "[ÉÈÊË]", "E" -replace "[ÀÂÄÁ]", "A" -replace "[ÔÖ]", "O" `
        -replace "[ÙÛÜ]", "U" -replace "[ÏÎ]", "I" -replace "[Ç]", "C"
    
    # Supprime TOUTES les variantes d'apostrophes, espaces et tirets
    $Name = $Name -replace "[\u0027\u2018\u2019\u02BC\u0060\s\-]", ""
    
    return $Name
}

# Génère un nom de compte à partir du prénom et nom
function Get-SamAccountName {
    param(
        [string]$Prenom,
        [string]$Nom
    )
    
    # "Nettoie" le prénom et le nom
    $PrenomClean = Clean-Name -Name $Prenom
    $NomClean = Clean-Name -Name $Nom
    
    # Crée le nom de compte : prenom.nom en minuscules
    $SamAccount = "$PrenomClean.$NomClean".ToLower()
    
    # Si trop long (max 20 caractères), le nom de compte est tronqué
    if ($SamAccount.Length -gt 20) {
        $SamAccount = $SamAccount.Substring(0, 20)
    }
    
    # Vérifie si le compte existe déjà
    $Counter = 2
    $FinalSamAccount = $SamAccount
    $Suffix = ""

    while (Get-ADUser -Filter "SamAccountName -eq '$FinalSamAccount'" -ErrorAction SilentlyContinue) {

        # Le compte existe, on ajoute un numéro 
        $Suffix = "$Counter"
        $FinalSamAccount = "$SamAccount$Counter"
        
        # Si le nouveau nom est trop long, on retronque
        if ($FinalSamAccount.Length -gt 20) {
            $BaseLength = 20 - $Counter.ToString().Length
            $FinalSamAccount = $SamAccount.Substring(0, $BaseLength) + $Counter
        }
        
        $Counter++
    }

    # Retourne un objet avec les deux valeurs
    return [PSCustomObject]@{
        SamAccount    = $FinalSamAccount
        DisplaySuffix = $Suffix
    }
}

# Construit le chemin de l'OU dans AD
function Get-OUPath {
    param(
        [string]$Departement,
        [string]$Service
    )
    
    # Récupère le nom de l'OU du département
    $DeptOU = $DepartementMapping[$Departement]
    
    if ([string]::IsNullOrWhiteSpace($DeptOU)) {
        throw "Département '$Departement' non trouvé dans le mapping"
    }
    
    # Si un service est défini, construit le chemin avec sous-OU
    if (-not [string]::IsNullOrWhiteSpace($Service)) {
        $ServiceOU = $ServiceMapping[$Service]
        if ([string]::IsNullOrWhiteSpace($ServiceOU)) {
            throw "Service '$Service' non trouvé dans le mapping"
        }
        $OUPath = "OU=$ServiceOU,OU=$DeptOU,OU=BilluUsers,$DomainDN"
    } else {
        # Sinon, utilise uniquement le département
        $OUPath = "OU=$DeptOU,OU=BilluUsers,$DomainDN"
    }
    
    return $OUPath
}

#endregion

#==========================================================
#region 04 - VÉRIFICATIONS DU FICHIER CSV
#==========================================================

Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   Script de synchronisation Active Directory              ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Vérifie que le fichier CSV existe
Write-Host "[VÉRIFICATION] Fichier CSV ($SourceCSV)..." -NoNewline
if (-not (Test-Path $SourceCSV)) {
    Write-Host " ERREUR" -ForegroundColor Red
    Write-Host "Le fichier CSV n'existe pas : $SourceCSV" -ForegroundColor Red
    exit 1
}
Write-Host " OK" -ForegroundColor Green

#endregion

#==========================================================
#region 05 - DONNEES FICHIERS CSV
#==========================================================

Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║              SYNCHRONISATION DES UTILISATEURS             ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Importation des données du CSV
$SourceData = Import-Csv -Path $SourceCSV -Delimiter "," -Encoding UTF8
$SecurePassword = ConvertTo-SecureString -String $DefaultPassword -AsPlainText -Force

Write-Host "Nombre d'utilisateurs à traiter : $($SourceData.Count)" -ForegroundColor Cyan
Write-Host ""

#endregion

########################################################################
#
#region 06 - COMPARAISON DES UTILISATEURS
#
########################################################################

foreach ($User in $SourceData) {

    # Ignore les lignes vides
    if ([string]::IsNullOrWhiteSpace($User.Prenom) -or [string]::IsNullOrWhiteSpace($User.Nom)) {
        continue
    }

    try {
        # NOUVEAU : On cherche si l'utilisateur existe déjà dans l'AD
        $PrenomEscaped = $User.Prenom -replace "'", "''"
        $NomEscaped = $User.Nom -replace "'", "''"
        $ADUsers = @(Get-ADUser -Filter "GivenName -eq '$PrenomEscaped' -and Surname -eq '$NomEscaped'" `
                     -Properties * -ErrorAction SilentlyContinue)

        # Gestion des doublons : si plusieurs comptes trouvés, on prend le premier
        if ($ADUsers.Count -gt 1) {
            Write-Host "[AVERTISSEMENT]" -ForegroundColor Yellow -NoNewline
            Write-Host " $($User.Prenom) $($User.Nom) → $($ADUsers.Count) comptes trouvés, mise à jour du premier" -ForegroundColor Yellow
        }
        $ADUser = if ($ADUsers.Count -ge 1) { $ADUsers[0] } else { $null }

        if ($ADUser) {
            # -----------------------------------------------
            # CAS 1 : L'utilisateur EXISTE → on met à jour
            # -----------------------------------------------
            Set-ADUser -Identity $ADUser.SamAccountName `
                -Department $User.Departement `
                -Title $User.fonction `
                -Company $User.Societe `
                -OfficePhone $User.'Telephone fixe' `
                -MobilePhone $User.'Telephone portable' `
                -ErrorAction Stop

            # Stocke pour la passe manager
            $UserKey = "$($User.Prenom) $($User.Nom)"
            $CreatedAccounts[$UserKey] = $ADUser.SamAccountName

            Write-Host "[MAJ]" -ForegroundColor Cyan -NoNewline
            Write-Host " $($User.Prenom) $($User.Nom)" -ForegroundColor White

            $UsersUpdated++

        } else {
            #------------------------------------------------
            # CAS 2 : L'utilisateur N'EXISTE PAS donc création
            #-------------------------------------------------

            # Génère le compte utilisateur
            $AccountInfo = Get-SamAccountName -Prenom $User.Prenom -Nom $User.Nom
            $SamAccount  = $AccountInfo.SamAccount

            # Nom d'affichage unique si doublon
            $DisplayName = if ($AccountInfo.DisplaySuffix) {
                "$($User.Prenom) $($User.Nom) ($($AccountInfo.DisplaySuffix))"
            } else {
                "$($User.Prenom) $($User.Nom)"
            }

            # Génère le mail
            $UPN = "$SamAccount$DomainName"
            
            # Chemin de l'OU
            $OUPath = Get-OUPath -Departement $User.Departement -Service $User.Service
            
            # Création de l'utilisateur dans AD
            New-ADUser `
                -Name              $DisplayName `
                -GivenName         $User.Prenom `
                -Surname           $User.Nom `
                -SamAccountName    $SamAccount `
                -UserPrincipalName $UPN `
                -DisplayName       $DisplayName `
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
                -ErrorAction       Stop

            # Stocke le SamAccount pour la deuxième passe
            $UserKey = "$($User.Prenom) $($User.Nom)"
            $CreatedAccounts[$UserKey] = $SamAccount
        
            Write-Host "[OK]" -ForegroundColor Green -NoNewline
            Write-Host " $($User.Prenom) $($User.Nom)" -NoNewline
            Write-Host " → SamAccount: " -NoNewline -ForegroundColor Gray
            Write-Host "$SamAccount" -ForegroundColor Yellow
        
            $UsersCreated++
        }

    } catch {
        # Si c'est un doublon
        if ($_.Exception.Message -like "*replace*") {
            $ErreurMessage = "DOUBLON - plusieurs comptes trouvés dans l'AD"
    } else {
        $ErreurMessage = $_.Exception.Message
    }

        Write-Host "[ERREUR]" -ForegroundColor Red -NoNewline
        Write-Host " $($User.Prenom) $($User.Nom)" -NoNewline
        Write-Host " → $ErreurMessage" -ForegroundColor Red
        
        $ErrorsList += [PSCustomObject]@{
            Utilisateur = "$($User.Prenom) $($User.Nom)"
            Erreur      = $ErreurMessage
        }
        $UsersSkipped++
    }
}
Write-Host ""
Write-Host "[INFO] Attribution des managers..." -ForegroundColor Cyan

# Attribution des managers
foreach ($User in $SourceData) {
    
    # Ignore les lignes vides
    if ([string]::IsNullOrWhiteSpace($User.Prenom) -or [string]::IsNullOrWhiteSpace($User.Nom)) {
        continue
    }
    
    # Si un manager est renseigné
    if (-not [string]::IsNullOrWhiteSpace($User.'Manager-Prenom') -and 
        -not [string]::IsNullOrWhiteSpace($User.'Manager-Nom')) {
        
        try {
            $UserKey = "$($User.Prenom) $($User.Nom)"
            $ManagerKey = "$($User.'Manager-Prenom') $($User.'Manager-Nom')"
            
            # Récupère les SamAccount depuis la hashtable
            $SamAccount = $CreatedAccounts[$UserKey]
            $ManagerSamAccount = $CreatedAccounts[$ManagerKey]
            
            if ($SamAccount -and $ManagerSamAccount) {
                $Manager = Get-ADUser -Identity $ManagerSamAccount -ErrorAction Stop
                Set-ADUser -Identity $SamAccount -Manager $Manager.DistinguishedName -ErrorAction Stop
                Write-Host "  [OK] $UserKey → Manager: $ManagerKey" -ForegroundColor Gray
            }
            
        } catch {
            $ManagerErrors++
        }
    }
}

#endregion

#==========================================================
#region 07 - DÉSACTIVATION DES COMPTES SORTANTS
#==========================================================

Write-Host ""
Write-Host "[INFO] Vérification des comptes à désactiver..." -ForegroundColor Cyan

# Récupère tous les users AD dans l'OU BilluUsers
$AllADUsers = Get-ADUser -Filter * -SearchBase "OU=BilluUsers,$DomainDN" -Properties GivenName, Surname

foreach ($ADUser in $AllADUsers) {

    # Cherche si cet user AD est présent dans le nouveau CSV
    $InCSV = $SourceData | Where-Object {
        $_.Prenom -eq $ADUser.GivenName -and $_.Nom -eq $ADUser.Surname
    }

    # S'il n'est plus dans le CSV → désactiver et déplacer
    if (-not $InCSV) {
        try {
            # Étape 1 : Désactiver le compte
            Disable-ADAccount -Identity $ADUser.SamAccountName -ErrorAction Stop

            # Étape 2 : Déplacer vers l'OU UserDeactived
            Move-ADObject -Identity $ADUser.DistinguishedName `
                          -TargetPath "OU=UsersDeactived,DC=billu,DC=lan" `
                          -ErrorAction Stop

            Write-Host "[DÉSACTIVÉ]" -ForegroundColor Yellow -NoNewline
            Write-Host " $($ADUser.GivenName) $($ADUser.Surname) → déplacé vers OU UsersDeactived" -ForegroundColor White
            $UsersDisabled++

        } catch {
            Write-Host "[ERREUR]" -ForegroundColor Red -NoNewline
            Write-Host " $($ADUser.GivenName) $($ADUser.Surname) → $($_.Exception.Message)" -ForegroundColor Red
        }
    }
}

#endregion

#==========================================================
#region 08 - RÉSUMÉ
#==========================================================

Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                      RÉSUMÉ                               ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "Utilisateurs traités  : $($SourceData.Count)" -ForegroundColor White
Write-Host "Utilisateurs créés    : $UsersCreated" -ForegroundColor Green
Write-Host "Utilisateurs ignorés  : $UsersSkipped" -ForegroundColor Yellow
Write-Host "Erreurs d'attribution manager : $ManagerErrors" -ForegroundColor Yellow
Write-Host "Utilisateurs mis à jour   : $UsersUpdated" -ForegroundColor Cyan
Write-Host "Utilisateurs désactivés   : $UsersDisabled" -ForegroundColor Yellow

Write-Host ""

if ($ErrorsList.Count -gt 0) {
    Write-Host "DÉTAILS DES ERREURS :" -ForegroundColor Red
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Red
    $ErrorsList | Format-Table -AutoSize
}

Write-Host "Terminé!" -ForegroundColor Green

#endregion
