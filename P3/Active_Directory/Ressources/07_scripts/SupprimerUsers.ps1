# Script de nettoyage des utilisateurs Active Directory
# Auteur : Christian
# Description : Supprime tous les utilisateurs dans l'OU BilluUsers pour les tests

#==========================================================
# VARIABLES
#==========================================================

$DomainDN = "DC=billU,DC=lan"
$BaseOU = "OU=BilluUsers,$DomainDN"

#==========================================================
# VÉRIFICATIONS
#==========================================================

Write-Host "`n========================================" -ForegroundColor Yellow
Write-Host "NETTOYAGE DES UTILISATEURS AD" -ForegroundColor Yellow
Write-Host "========================================`n" -ForegroundColor Yellow

# Vérifier le module Active Directory
if (-not (Get-Module -Name ActiveDirectory -ListAvailable)) {
    Write-Error "Le module ActiveDirectory n'est pas disponible."
    exit
}

Import-Module ActiveDirectory

# Vérifier que l'OU de base existe
try {
    $null = Get-ADOrganizationalUnit -Identity $BaseOU -ErrorAction Stop
} catch {
    Write-Error "L'OU de base n'existe pas : $BaseOU"
    exit
}

#==========================================================
# RÉCUPÉRATION DES UTILISATEURS
#==========================================================

Write-Host "Recherche des utilisateurs dans : $BaseOU" -ForegroundColor Cyan

try {
    $Users = Get-ADUser -Filter * -SearchBase $BaseOU -SearchScope Subtree
} catch {
    Write-Error "Erreur lors de la récupération des utilisateurs : $($_.Exception.Message)"
    exit
}

if ($Users.Count -eq 0) {
    Write-Host "`nAucun utilisateur trouvé dans $BaseOU" -ForegroundColor Green
    Write-Host "Rien à supprimer !`n" -ForegroundColor Green
    exit
}

Write-Host "Nombre d'utilisateurs trouvés : $($Users.Count)" -ForegroundColor Yellow

# Afficher quelques exemples
Write-Host "`nExemples d'utilisateurs qui seront supprimés :" -ForegroundColor Cyan
$Users | Select-Object -First 5 | ForEach-Object {
    Write-Host "  - $($_.Name) ($($_.SamAccountName))" -ForegroundColor Gray
}

if ($Users.Count -gt 5) {
    Write-Host "  - ... et $($Users.Count - 5) autres" -ForegroundColor Gray
}

#==========================================================
# CONFIRMATION
#==========================================================

Write-Host "`n⚠️  ATTENTION ⚠️" -ForegroundColor Red
Write-Host "Cette action va supprimer TOUS les $($Users.Count) utilisateurs de l'OU BilluUsers !" -ForegroundColor Red
Write-Host "Cette action est IRRÉVERSIBLE !`n" -ForegroundColor Red

$Confirmation = Read-Host "Êtes-vous sûr de vouloir continuer ? (Tapez 'OUI' en majuscules pour confirmer)"

if ($Confirmation -ne "OUI") {
    Write-Host "`nOpération annulée par l'utilisateur." -ForegroundColor Yellow
    exit
}

#==========================================================
# SUPPRESSION
#==========================================================

Write-Host "`nSuppression des utilisateurs en cours...`n" -ForegroundColor Yellow

$DeletedCount = 0
$ErrorCount = 0

foreach ($User in $Users) {
    try {
        Remove-ADUser -Identity $User.SamAccountName -Confirm:$false
        Write-Host "  [SUPPRIMÉ] $($User.Name) ($($User.SamAccountName))" -ForegroundColor Green
        $DeletedCount++
    } catch {
        Write-Host "  [ERREUR] $($User.Name) : $($_.Exception.Message)" -ForegroundColor Red
        $ErrorCount++
    }
}

#==========================================================
# RÉSUMÉ
#==========================================================

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "NETTOYAGE TERMINÉ" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

Write-Host "`nStatistiques :" -ForegroundColor Cyan
Write-Host "  - Utilisateurs trouvés  : $($Users.Count)" -ForegroundColor White
Write-Host "  - Supprimés             : $DeletedCount" -ForegroundColor Green
Write-Host "  - Erreurs               : $ErrorCount" -ForegroundColor $(if ($ErrorCount -gt 0) { "Red" } else { "Green" })

Write-Host "`nVous pouvez maintenant relancer votre script de création d'utilisateurs !`n" -ForegroundColor Yellow