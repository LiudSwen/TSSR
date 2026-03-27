# Script de féminisation des postes Active Directory
# Auteur : Franck
# Description : Met à jour le titre des utilisatrices (Mme) dans l'AD
#               en appliquant la forme féminine de leur fonction

# Sommaire
# 01 - VARIABLES
# 02 - TABLE DE FÉMINISATION
# 03 - FONCTIONS UTILITAIRES
# 04 - VÉRIFICATIONS
# 05 - TRAITEMENT
# 06 - RÉSUMÉ

#==========================================================
#region 01 - VARIABLES
#==========================================================

$SourceCSV    = "C:\Users\Administrator\Documents\s04-a02-BillU-ListeRHCollaborateurs.csv"
$DomainDN     = "DC=billu,DC=lan"

$UsersUpdated = 0
$UsersSkipped = 0
$UsersNoChange = 0
$ErrorsList   = @()

#endregion


#==========================================================
#region 02 - TABLE DE FÉMINISATION
#==========================================================

$FeminisationMapping = @{
    # A
    "Acheteur"                               = "Acheteuse"
    "Agent"                                  = "Agente"
    "Agent RH"                               = "Agente RH"
    "Analyste financier"                     = "Analyste financière"
    "Animateur sécurité"                     = "Animatrice sécurité"
    "Assistant de direction"                 = "Assistante de direction"
    "Auditeur"                               = "Auditrice"
    "Avocat"                                 = "Avocate"
    # C
    "CEO"                                    = "CEO"
    "Chargé de communication"                = "Chargée de communication"
    "Chargé en droit de la communication"    = "Chargée en droit de la communication"
    "Chargée relation presse"                = "Chargée relation presse"
    "Commercial"                             = "Commerciale"
    "Community manager"                      = "Community manager"
    "Comptable"                              = "Comptable"
    "Controleur de gestion"                  = "Controleuse de gestion"
    # D
    "Designer graphique"                     = "Designer graphique"
    "Directeur Développement logiciel"       = "Directrice Développement logiciel"
    "Directeur adjoint"                      = "Directrice adjointe"
    "Directeur commercial"                   = "Directrice commerciale"
    "Directeur des ressources humaines"      = "Directrice des ressources humaines"
    "Directeur des systèmes d'information"  = "Directrice des systèmes d'information"
    "Directeur financier"                    = "Directrice financière"
    "Directeur juridique"                    = "Directrice juridique"
    "Directrice Communication et Relations publiques" = "Directrice Communication et Relations publiques"
    "Développeur"                            = "Développeuse"
    # G
    "Gestionnaire ADV"                       = "Gestionnaire ADV"
    # H
    "Hotliner"                               = "Hotliner"
    # I
    "Intégrateur"                            = "Intégratrice"
    # J
    "Juriste"                                = "Juriste"
    # M
    "Monteur"                                = "Monteuse"
    # R
    "Responsable ADV"                        = "Responsable ADV"
    "Responsable QHSE"                       = "Responsable QHSE"
    "Responsable Recherche"                  = "Responsable Recherche"
    "Responsable achat client"               = "Responsable achat client"
    "Responsable analyse et conception"      = "Responsable analyse et conception"
    "Responsable communication"              = "Responsable communication"
    "Responsable developpement"              = "Responsable developpement"
    "Responsable marques"                    = "Responsable marques"
    "Responsable recrutement"                = "Responsable recrutement"
    "Responsable relation média"             = "Responsable relation média"
    "Responsable test et qualité"            = "Responsable test et qualité"
    "Rédacteur"                              = "Rédactrice"
    # T
    "Technicien HSE"                         = "Technicienne HSE"
    "Technicien Systèmes"                    = "Technicienne Systèmes"
    "Technicien d'exploitation"             = "Technicienne d'exploitation"
    "Technicien de maintenance"              = "Technicienne de maintenance"
    "Technicien réseaux"                     = "Technicienne réseaux"
    "Testeur"                                = "Testeuse"
    # W
    "Webmaster"                              = "Webmaster"
    # P
    "photographe"                            = "photographe"
}

#endregion


#==========================================================
#region 03 - FONCTIONS UTILITAIRES
#==========================================================

function Escape-LDAPFilter {
    param([string]$Value)
    $Value = $Value -replace "\\", "\5c"
    $Value = $Value -replace "\*", "\2a"
    $Value = $Value -replace "\(", "\28"
    $Value = $Value -replace "\)", "\29"
    return $Value
}

function Find-ADUser {
    param([string]$Prenom, [string]$Nom)

    $PrenomLDAP = Escape-LDAPFilter -Value $Prenom
    $NomLDAP    = Escape-LDAPFilter -Value $Nom

    $ADUser = Get-ADUser -LDAPFilter "(&(givenName=$PrenomLDAP)(sn=$NomLDAP))" `
                         -Properties Title, GivenName, Surname -ErrorAction SilentlyContinue

    # Fallback Where-Object pour les noms avec apostrophes/caractères spéciaux
    if (-not $ADUser) {
        $ADUser = Get-ADUser -Filter * -SearchBase "OU=BilluUsers,$DomainDN" `
                             -Properties Title, GivenName, Surname -ErrorAction SilentlyContinue |
                  Where-Object { $_.GivenName -eq $Prenom -and $_.Surname -eq $Nom }
    }

    if ($ADUser -is [array]) {
        $ADUser = $ADUser | Where-Object { $_.Enabled -eq $true } | Select-Object -First 1
    }

    return $ADUser
}

#endregion


#==========================================================
#region 04 - VÉRIFICATIONS
#==========================================================

Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║         Script de féminisation des postes AD              ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Write-Host "[VÉRIFICATION] Fichier CSV ($SourceCSV)..." -NoNewline
if (-not (Test-Path $SourceCSV)) {
    Write-Host " ERREUR" -ForegroundColor Red
    Write-Host "Le fichier CSV n'existe pas : $SourceCSV" -ForegroundColor Red
    exit 1
}
Write-Host " OK" -ForegroundColor Green
Write-Host ""

#endregion


#==========================================================
#region 05 - TRAITEMENT
#==========================================================

$SourceData = Import-Csv -Path $SourceCSV -Delimiter "," -Encoding UTF8

# Filtre uniquement les femmes (Mme)
$Femmes = $SourceData | Where-Object { $_.Civilité -eq "Mme" -and `
    -not [string]::IsNullOrWhiteSpace($_.Prenom) -and `
    -not [string]::IsNullOrWhiteSpace($_.Nom) }

Write-Host "Femmes à traiter : $($Femmes.Count)" -ForegroundColor Cyan
Write-Host ""

foreach ($User in $Femmes) {

    try {
        $ADUser = Find-ADUser -Prenom $User.Prenom -Nom $User.Nom

        if (-not $ADUser) {
            Write-Host "[INTROUVABLE]" -ForegroundColor Yellow -NoNewline
            Write-Host " $($User.Prenom) $($User.Nom)" -ForegroundColor White
            $UsersSkipped++
            continue
        }

        $FonctionActuelle = $User.fonction
        $FonctionFeminine = $FeminisationMapping[$FonctionActuelle]

        if (-not $FonctionFeminine) {
            Write-Host "[MAPPING MANQUANT]" -ForegroundColor Red -NoNewline
            Write-Host " $($User.Prenom) $($User.Nom) → '$FonctionActuelle' non trouvé dans le mapping" -ForegroundColor White
            $ErrorsList += [PSCustomObject]@{
                Utilisateur = "$($User.Prenom) $($User.Nom)"
                Fonction    = $FonctionActuelle
                Erreur      = "Fonction non trouvée dans le mapping"
            }
            $UsersSkipped++
            continue
        }

        # Vérifie si le titre est déjà féminisé
        if ($ADUser.Title -eq $FonctionFeminine) {
            Write-Host "[DÉJÀ OK]" -ForegroundColor Gray -NoNewline
            Write-Host " $($User.Prenom) $($User.Nom) → '$FonctionFeminine'" -ForegroundColor Gray
            $UsersNoChange++
            continue
        }

        # Met à jour le titre
        Set-ADUser -Identity $ADUser.SamAccountName `
                   -Title $FonctionFeminine `
                   -ErrorAction Stop

        Write-Host "[MAJ]" -ForegroundColor Green -NoNewline
        Write-Host " $($User.Prenom) $($User.Nom)" -NoNewline
        Write-Host " → '$FonctionActuelle'" -ForegroundColor Gray -NoNewline
        Write-Host " → '$FonctionFeminine'" -ForegroundColor Cyan
        $UsersUpdated++

    } catch {
        Write-Host "[ERREUR]" -ForegroundColor Red -NoNewline
        Write-Host " $($User.Prenom) $($User.Nom) → $($_.Exception.Message)" -ForegroundColor Red
        $ErrorsList += [PSCustomObject]@{
            Utilisateur = "$($User.Prenom) $($User.Nom)"
            Fonction    = $User.fonction
            Erreur      = $_.Exception.Message
        }
        $UsersSkipped++
    }
}

#endregion


#==========================================================
#region 06 - RÉSUMÉ
#==========================================================

Write-Host ""
Write-Host "╔═══════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                        RÉSUMÉ                            ║" -ForegroundColor Cyan
Write-Host "╚═══════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""
Write-Host "Femmes traitées            : $($Femmes.Count)"  -ForegroundColor White
Write-Host "Postes féminisés           : $UsersUpdated"     -ForegroundColor Green
Write-Host "Déjà féminisés             : $UsersNoChange"    -ForegroundColor Gray
Write-Host "Ignorés / Erreurs          : $UsersSkipped"     -ForegroundColor Yellow
Write-Host ""

if ($ErrorsList.Count -gt 0) {
    Write-Host "DÉTAILS DES ERREURS :" -ForegroundColor Red
    Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Red
    $ErrorsList | Format-Table -AutoSize
}

Write-Host "Terminé!" -ForegroundColor Green

#endregion
