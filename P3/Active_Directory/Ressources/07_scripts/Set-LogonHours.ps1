# Restriction des horaires de connexion

# Heures autorisees
$heuresStandard = [byte[]](
    0,   0,   0,    # Dimanche  - bloqué
    192, 255, 7,    # Lundi     - 07h-20h (local UTC+1)
    192, 255, 7,    # Mardi     - 07h-20h
    192, 255, 7,    # Mercredi  - 07h-20h
    192, 255, 7,    # Jeudi     - 07h-20h
    192, 255, 7,    # Vendredi  - 07h-20h
    128, 15,  0     # Samedi    - 08h-13h (local UTC+1)
)


# Liste des OUs (ADMINISTRATION_SYSTEMES_RESEAUX pas inclus car acces illimite)
$ous = @(
    "OU=COMMERCIAL,OU=BilluUsers,DC=billu,DC=lan",
    "OU=COMMUNICATION,OU=BilluUsers,DC=billu,DC=lan",
    "OU=COMPTABILITE,OU=BilluUsers,DC=billu,DC=lan",
    "OU=DEV,OU=BilluUsers,DC=billu,DC=lan",
    "OU=DIRECTION,OU=BilluUsers,DC=billu,DC=lan",
    "OU=JURIDIQUE,OU=BilluUsers,DC=billu,DC=lan",
    "OU=QHSE,OU=BilluUsers,DC=billu,DC=lan",
    "OU=RH,OU=BilluUsers,DC=billu,DC=lan",
    "OU=SUPPORT,OU=DSI,OU=BilluUsers,DC=billu,DC=lan",
    "OU=EXPLOITATION,OU=DSI,OU=BilluUsers,DC=billu,DC=lan",
    "OU=DEVELOPPEMENT_INTEGRATION,OU=DSI,OU=BilluUsers,DC=billu,DC=lan"
)

# Application des restrictions
foreach ($ou in $ous) {
    Get-ADUser -Filter {Enabled -eq $true} -SearchBase $ou |
    ForEach-Object { Set-ADUser $_ -Replace @{logonHours = $heuresStandard} }
}
