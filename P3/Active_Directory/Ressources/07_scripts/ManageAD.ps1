#########################################################################
# Script ManageAD                                                       #
# Paisant Franck                                                        #
# 19/02/2026                                                            #
#########################################################################

#########################################################################
#                          MENU PRINCIPAL                               #
#########################################################################
Set-Location -Path $PSScriptRoot
function menu {
    Clear-Host
    while ($true) {
        Write-Host "=================================================" -ForegroundColor Cyan
        Write-Host "   Gestion des utilisateurs Active Directory     " -ForegroundColor Cyan
        Write-Host "=================================================" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Menu :" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "1) Création Utilisateur AD"
        Write-Host "2) Désactivation des comptes AD sortants"
        Write-Host "3) Féminisation des intitulés de poste AD"
        Write-Host "4) Sortie"
        Write-Host ""
        $choice = Read-Host "Votre choix"

        switch ($choice) {
            1 {
                & ".\createUsersAD.ps1"
                Read-Host "Appuyer sur ENTER pour revenir au menu"
            }
            2 {
                & ".\modifUsersAD.ps1"
                Read-Host "Appuyer sur ENTER pour revenir au menu"
            }
            3 {
                & ".\feminisationPosteAD.ps1"
                Read-Host "Appuyer sur ENTER pour revenir au menu"
            }
            4 {
                Write-Host ""
                Write-Host "Exit - FIN DE SCRIPT" -ForegroundColor Red
                exit 0
            }
            default {
                Write-Host ""
                Write-Host "Choix invalide, veuillez recommencer" -ForegroundColor Red
                Write-Host ""
                Start-Sleep -Seconds 2
            }
        }
    }
}

#########################################################################
#                             LANCEMENT                                 #
#########################################################################
menu
