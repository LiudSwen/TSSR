# Script de création d'utilisateur Active Directory à partir d'un fichier .csv
# Auteur : Christian

# Sommaire
# 01 - VARIABLES
# 02 - TABLES DE MAPPING
# 03 - FONCTIONS UTILITAIRES
# 04 - VÉRIFICATIONS DU FICHIER CSV
# 05 - DONNEES FICHIERS CSV
# 06 - CRÉATION DES UTILISATEURS
# 07 - RÉSUMÉ

#==========================================================
#region 01 - VARIABLES
#==========================================================

# Emplacement du fichier csv
$SourceCSV = "C:\Scripts\s01_BillU.csv"

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

#endregion


#==========================================================
#region 02 - TABLES DE MAPPING
#==========================================================

# Hashtables des Départements
$DepartementMapping = @{
    "Service Commercial"                   = "COMMERCIAL"
    "Communication et Relations publiques" = "COMMUNICATION"
    "Finance et Comptabilité"              = "COMPTABILITE"
    "Développement logiciel"               = "DEV"
    "Direction"                            = "DIRECTION"
    "DSI"                                  = "DSI"
    "Département Juridique"                = "JURIDIQUE"
    "QHSE"                                 = "QHSE"
    "Service recrutement"                  = "RH"
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
    "Gestion des marques"                  = "GESTION_DES_MARQUES"

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

# Remplace les charactères spéciaux pour la création des noms de compte
function Clean-Name {
    param([string]$Name)
    
    $Name = $Name -replace "[éèêë]", "e" -replace "[àâäá]", "a" -replace "[ôö]", "o" `
        -replace "[ùûü]", "u" -replace "[ïî]", "i" -replace "[ç]", "c" `
        -replace "[ÉÈÊË]", "E" -replace "[ÀÂÄÁ]", "A" -replace "[ÔÖ]", "O" `
        -replace "[ÙÛÜ]", "U" -replace "[ÏÎ]", "I" -replace "[Ç]", "C"
    
    # Supprime les apostrophes, espaces et tirets
    $Name = $Name -replace "[''\s-]", ""
    
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
    
    while (Get-ADUser -Filter "SamAccountName -eq '$FinalSamAccount'" -ErrorAction SilentlyContinue) {

        # Le compte existe, on ajoute un numéro 
        $FinalSamAccount = "$SamAccount$Counter"
        
        # Si le nouveau nom est trop long, on retronque
        if ($FinalSamAccount.Length -gt 20) {
            $BaseLength = 20 - $Counter.ToString().Length
            $FinalSamAccount = $SamAccount.Substring(0, $BaseLength) + $Counter
        }
        
        $Counter++
    }
    
    return $FinalSamAccount
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
Write-Host "║   Script de création d'utilisateurs Active Directory     ║" -ForegroundColor Cyan
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
Write-Host "║              CRÉATION DES UTILISATEURS                    ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

# Importation des données du CSV
$SourceData = Import-Csv -Path $SourceCSV -Delimiter ";" -Encoding UTF8
$SecurePassword = ConvertTo-SecureString -String $DefaultPassword -AsPlainText -Force

Write-Host "Nombre d'utilisateurs à traiter : $($SourceData.Count)" -ForegroundColor Cyan
Write-Host ""

#endregion


#==========================================================
#region 06 - CRÉATION DES UTILISATEURS
#==========================================================

# PREMIÈRE PASSE : Création des utilisateurs sans les managers
foreach ($User in $SourceData) {
    
    # Ignore les lignes vides
    if ([string]::IsNullOrWhiteSpace($User.Prenom) -or [string]::IsNullOrWhiteSpace($User.Nom)) {
        continue
    }

    try {
        # Génère le compte utilisateur
        $SamAccount = Get-SamAccountName -Prenom $User.Prenom -Nom $User.Nom
        
        # Génère le mail
        $UPN = "$SamAccount$DomainName"
        
        # Chemin de l'OU
        $OUPath = Get-OUPath -Departement $User.Departement -Service $User.Service
        
        # Création de l'utilisateur dans AD
        New-ADUser `
            -Name "$($User.Prenom) $($User.Nom)" `
            -GivenName $User.Prenom `
            -Surname $User.Nom `
            -SamAccountName $SamAccount `
            -UserPrincipalName $UPN `
            -DisplayName "$($User.Prenom) $($User.Nom)" `
            -EmailAddress $UPN `
            -Path $OUPath `
            -AccountPassword $SecurePassword `
            -Enabled $true `
            -ChangePasswordAtLogon $true `
            -Department $User.Departement `
            -Title $User.fonction `
            -Company $User.Societe `
            -OfficePhone $User.'Telephone fixe' `
            -MobilePhone $User.'Telephone portable' `
            -ErrorAction Stop
        
        # Stocke le SamAccount pour la deuxième passe
        $UserKey = "$($User.Prenom) $($User.Nom)"
        $CreatedAccounts[$UserKey] = $SamAccount
        
        Write-Host "[OK]" -ForegroundColor Green -NoNewline
        Write-Host " $($User.Prenom) $($User.Nom)" -NoNewline
        Write-Host " → SamAccount: " -NoNewline -ForegroundColor Gray
        Write-Host "$SamAccount" -ForegroundColor Yellow
        
        $UsersCreated++
        
    } catch {
        Write-Host "[ERREUR]" -ForegroundColor Red -NoNewline
        Write-Host " $($User.Prenom) $($User.Nom)" -NoNewline
        Write-Host " → $($_.Exception.Message)" -ForegroundColor Red
        
        $ErrorsList += [PSCustomObject]@{
            Utilisateur = "$($User.Prenom) $($User.Nom)"
            Erreur      = $_.Exception.Message
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
#region 07 - RÉSUMÉ
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

Write-Host ""

if ($ErrorsList.Count -gt 0) {
    Write-Host "DÉTAILS DES ERREURS :" -ForegroundColor Red
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Red
    $ErrorsList | Format-Table -AutoSize
}

Write-Host "Terminé!" -ForegroundColor Green

#endregion
