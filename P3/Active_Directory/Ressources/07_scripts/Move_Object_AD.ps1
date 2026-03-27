# ====================================
#   Script déplacement des objets AD
#   10/03/2026 
#   Matthias Chicaud
# ====================================

Import-Module ActiveDirectory

# ======================================
# CONFIGURATION
# ======================================

# Base du Domaine
$Domain = "DC=billu,DC=lan"

# OU contenant les ordinateurs
$SearchBase = "CN=Computers,$Domain"

# Récupération des ordinateurs dans l'AD
$Computers = Get-ADComputer -SearchBase $SearchBase -Filter * -Properties DistinguishedName, Name

# Correspondance nom ordinateurs vers OU cible
$OUMap = @{
        # Correspondance département COMMERCIAL
        "COMMER" = "OU=COMMERCIAL,OU=BilluComputers,$Domain"
            # COrrespondance par Service COMMERCIAL
            "ADV" = "OU=ADMINISTRATION_DES_VENTES,OU=COMMERCIAL,OU=BilluComputers,$Domain"
            "B2B" = "OU=B2B,OU=COMMERCIAL,OU=BilluComputers,$Domain"
            "SA" = "OU=SERVICE_ACHAT,OU=COMMERCIAL,OU=BilluComputers,$Domain"
            "SCL" = "OU=SERVICE_CLIENT,OU=COMMERCIAL,OU=BilluComputers,$Domain"
        # Correspondance département COMMUNICATION
        "COMMU" = "OU=COMMUNICATION,OU=BilluComputers,$Domain"
            # Correspondance par Service COMMUNICATION
            "CI" = "OU=COMMUNICATION_INTERNE,OU=COMMUNICATION,OU=BilluComputers,$Domain"
            "GDM" = "OU=GESTION_DES_MARQUES,OU=COMMUNICATION,OU=BilluComputers,$Domain"
            "RM" = "OU=RELATION_MEDIA,OU=COMMUNICATION,OU=BilluComputers,$Domain"
        # Correspondance département COMPTABILITE
        "COMPT" = "OU=COMPTABILITE,OU=BilluComputers,$Domain"
            # Correspondance par Service COMPTABILITE
            "FIN" = "OU=FINANCE,OU=COMPTABILITE,OU=BilluComputers,$Domain"
            "FIS" = "OU=FISCALITE,OU=COMPTABILITE,OU=BilluComputers,$Domain"
            "SCO" = "OU=SERVICE_COMPTABILITE,OU=COMPTABILITE,OU=BilluComputers,$Domain"
        # Correspondance département DEVELOPPEMENT
        "DEV" = "OU=DEV,OU=BilluComputers,$Domain"
            # Correspondance par Service DEVELOPPEMENT
            "AC" = "OU=ANALYSE_CONCEPTION,OU=DEV,OU=BilluComputers,$Domain"
            "DV" = "OU=DEVELOPPEMENT,OU=DEV,OU=BilluComputers,$Domain"
            "RP" = "OU=RECHERCHE_PROTOTYPAGE,OU=DEV,OU=BilluComputers,$Domain"
            "TQ" = "OU=TESTS_QUALITE,OU=DEV,OU=BilluComputers,$Domain"
        # Correspondance département DIRECTION
        "DIR" = "OU=DIRECTION,OU=BilluComputers,$Domain"
        # Correspondance département DSI
        "DSI" = "OU=DSI,OU=BilluComputers,$Domain"
            # Correspondance par Service DSI
            "ASR" = "OU=ADMINISTRATION_SYSTEMES_RESEAUX,OU=DSI,OU=BilluComputers,$Domain"
            "DI" = "OU=DEVELOPPEMENT_INTEGRATION,OU=DSI,OU=BilluComputers,$Domain"
            "EXP" = "OU=EXPLOITATION,OU=DSI,OU=BilluComputers,$Domain"
            "SUP" = "OU=SUPPORT,OU=DSI,OU=BilluComputers,$Domain"
        # Correspondance département JURIDIQUE
        "JUR" = "OU=JURIDIQUE,OU=BilluComputers,$Domain"
            # Correspondance par Service JURIDIQUE
            "DDS" = "OU=DROITS_DES_SOCIETES,OU=JURIDIQUE,OU=BilluComputers,$Domain"
            "PI" = "OU=PROPRIETES_INTELLECTUELLES,OU=JURIDIQUE,OU=BilluComputers,$Domain"
            "PDC" = "OU=PROTECTION_DONNEES_CONFORMITES,OU=JURIDIQUE,OU=BilluComputers,$Domain"
        # Correspondance département QHSE
        "QHSE" = "OU=QHSE,OU=BilluComputers,$Domain"
            # Correspondance par Service QHSE
            "CER" = "OU=CERTIFICATION,OU=QHSE,OU=BilluComputers,$Domain"
            "CQ" = "OU=CONTROLE_QUALITE,OU=QHSE,OU=BilluComputers,$Domain"
            "GE" = "OU=GESTION_ENVIRONNEMENTALE,OU=QHSE,OU=BilluComputers,$Domain"
        # Correspondance département RH
        "RH" = "OU=RH,OU=BilluComputers,$Domain"
}

# ======================================
# FONCTIONS
# ======================================

# Recupère la bonne OU par le nom de l'ordinateur
function TargetOUFromComputerName {
    param(
        [string]$ComputerName
    )

    # Format attendu : PC-DEV-001 / PC-DSI-002 / PC-ASR-014
    if ($ComputerName -match '^[A-Z]+-([A-Z0-9]+)-\d+$') {
        $code = $matches[1]
        if ($OUMap.ContainsKey($code)) {
            return $OUMap[$code]
        }
    }
}

# ======================================
# SCRIPT
# ======================================

foreach ($Computer in $Computers) {

    $ComputerName = $Computer.Name
    $CurrentComputer = Get-ADComputer -Identity $ComputerName -Properties DistinguishedName
    $CurrentDN = $CurrentComputer.DistinguishedName
    $TargetOU = TargetOUFromComputerName -ComputerName $ComputerName

    if ($TargetOU) {
        Write-Host "$ComputerName est envoye vers $TargetOU"

        try {
            Move-ADObject -Identity $CurrentDN -TargetPath $TargetOU -ErrorAction Stop
            Write-Host "$ComputerName déplacé avec succes"
        }
        catch {
            Write-Host "Erreur lors du deplacement de $ComputerName : $($_.Exception.Message)"
        }
    }
    else {
        Write-Host "$ComputerName n'a pas de correspondance dans le mapping"
    }
}