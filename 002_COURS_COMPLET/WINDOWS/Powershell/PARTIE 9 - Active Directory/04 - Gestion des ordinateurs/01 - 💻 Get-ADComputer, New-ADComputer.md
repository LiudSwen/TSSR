

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

## Introduction

La gestion des ordinateurs dans Active Directory est une tâche administrative essentielle pour maintenir un parc informatique organisé et sécurisé. PowerShell propose deux cmdlets principales pour interagir avec les comptes ordinateurs : **Get-ADComputer** pour la consultation et l'inventaire, et **New-ADComputer** pour la création et le provisioning.

> [!info] Pourquoi gérer les comptes ordinateurs ?
> 
> - Maintenir un inventaire précis du parc informatique
> - Identifier les machines obsolètes ou inactives
> - Appliquer des stratégies de groupe ciblées via les OUs
> - Automatiser le déploiement de nouvelles machines
> - Assurer la conformité et la sécurité du réseau

---

## Get-ADComputer

### Syntaxe et paramètres

La cmdlet **Get-ADComputer** permet de récupérer des informations sur les comptes ordinateurs dans Active Directory. Elle fonctionne de manière très similaire à Get-ADUser.

```powershell
Get-ADComputer -Identity <nom_ordinateur>
Get-ADComputer -Filter <critère_de_filtrage>
Get-ADComputer -SearchBase <DN_de_OU>
```

#### Paramètres principaux

|Paramètre|Description|Exemple|
|---|---|---|
|`-Identity`|Identifie un ordinateur spécifique par son nom|`Get-ADComputer -Identity "PC-001"`|
|`-Filter`|Filtre les ordinateurs selon des critères|`Get-ADComputer -Filter "Enabled -eq $true"`|
|`-SearchBase`|Limite la recherche à une OU spécifique|`Get-ADComputer -SearchBase "OU=Workstations,DC=domain,DC=com"`|
|`-Properties`|Spécifie les attributs supplémentaires à récupérer|`Get-ADComputer -Identity "PC-001" -Properties *`|
|`-SearchScope`|Définit la portée de la recherche (Base, OneLevel, Subtree)|`Get-ADComputer -Filter * -SearchScope OneLevel`|

> [!warning] Propriétés par défaut limitées Par défaut, Get-ADComputer ne retourne qu'un ensemble limité de propriétés. Pour obtenir des informations détaillées comme `LastLogonDate`, `OperatingSystem`, ou `IPv4Address`, vous devez utiliser le paramètre `-Properties`.

```powershell
# Récupération basique (propriétés limitées)
Get-ADComputer -Identity "PC-001"

# Récupération avec toutes les propriétés
Get-ADComputer -Identity "PC-001" -Properties *

# Récupération avec des propriétés spécifiques
Get-ADComputer -Identity "PC-001" -Properties OperatingSystem, LastLogonDate, IPv4Address
```

### Propriétés principales

Voici les propriétés les plus importantes pour la gestion des ordinateurs :

|Propriété|Description|Utilité|
|---|---|---|
|`Name`|Nom de l'ordinateur|Identification principale|
|`SamAccountName`|Nom de compte (Name$)|Authentification|
|`DNSHostName`|Nom DNS complet (FQDN)|Résolution réseau|
|`DistinguishedName`|Chemin complet dans AD|Localisation dans l'arborescence|
|`Enabled`|État du compte (activé/désactivé)|Gestion de l'accès|
|`OperatingSystem`|Système d'exploitation|Inventaire et compatibilité|
|`OperatingSystemVersion`|Version de l'OS|Identification des versions obsolètes|
|`LastLogonDate`|Dernière connexion|Détection des comptes inactifs|
|`WhenCreated`|Date de création du compte|Audit et traçabilité|
|`IPv4Address`|Adresse IP|Diagnostic réseau|
|`MemberOf`|Groupes d'appartenance|Gestion des droits|

```powershell
# Affichage des propriétés essentielles
Get-ADComputer -Identity "PC-001" -Properties OperatingSystem, LastLogonDate, IPv4Address | 
    Select-Object Name, OperatingSystem, LastLogonDate, IPv4Address, Enabled
```

### Filtres courants

Les filtres permettent de cibler des ensembles d'ordinateurs selon des critères spécifiques.

> [!tip] Syntaxe des filtres Les filtres utilisent la même syntaxe que Get-ADUser :
> 
> - Opérateurs de comparaison : `-eq`, `-ne`, `-like`, `-notlike`, `-gt`, `-lt`
> - Opérateurs logiques : `-and`, `-or`, `-not`
> - Wildcards : `*` (plusieurs caractères), `?` (un caractère)

#### Filtres par système d'exploitation

```powershell
# Tous les ordinateurs Windows 11
Get-ADComputer -Filter "OperatingSystem -like '*Windows 11*'" -Properties OperatingSystem

# Tous les ordinateurs Windows Server
Get-ADComputer -Filter "OperatingSystem -like '*Server*'" -Properties OperatingSystem

# Ordinateurs avec un OS spécifique
Get-ADComputer -Filter "OperatingSystemVersion -eq '10.0 (22000)'" -Properties OperatingSystemVersion
```

#### Filtres par état

```powershell
# Ordinateurs activés uniquement
Get-ADComputer -Filter "Enabled -eq $true"

# Ordinateurs désactivés
Get-ADComputer -Filter "Enabled -eq $false"

# Combinaison : ordinateurs activés avec Windows 11
Get-ADComputer -Filter "Enabled -eq $true -and OperatingSystem -like '*Windows 11*'" -Properties OperatingSystem
```

#### Filtres par activité

```powershell
# Ordinateurs inactifs depuis plus de 90 jours
$DateLimite = (Get-Date).AddDays(-90)
Get-ADComputer -Filter "LastLogonDate -lt $DateLimite" -Properties LastLogonDate

# Ordinateurs créés dans les 30 derniers jours
$DateCreation = (Get-Date).AddDays(-30)
Get-ADComputer -Filter "WhenCreated -gt $DateCreation" -Properties WhenCreated

# Ordinateurs jamais connectés (LastLogonDate null)
Get-ADComputer -Filter "LastLogonDate -notlike '*'" -Properties LastLogonDate
```

#### Filtres par nom

```powershell
# Ordinateurs dont le nom commence par "LAP-"
Get-ADComputer -Filter "Name -like 'LAP-*'"

# Ordinateurs dont le nom contient "RH"
Get-ADComputer -Filter "Name -like '*RH*'"

# Ordinateurs avec un motif complexe
Get-ADComputer -Filter "Name -like 'PC-??-*'"  # PC-XX-quelquechose
```

### Cas d'usage pratiques

#### 📊 Inventaire du parc informatique

```powershell
# Inventaire complet avec export CSV
Get-ADComputer -Filter * -Properties OperatingSystem, OperatingSystemVersion, IPv4Address, LastLogonDate |
    Select-Object Name, DNSHostName, OperatingSystem, OperatingSystemVersion, IPv4Address, LastLogonDate, Enabled |
    Export-Csv -Path "C:\Inventaire_Ordinateurs.csv" -NoTypeInformation -Encoding UTF8

# Statistiques par OS
Get-ADComputer -Filter * -Properties OperatingSystem |
    Group-Object OperatingSystem |
    Select-Object Count, Name |
    Sort-Object Count -Descending
```

#### 🔍 Identification d'OS obsolètes

```powershell
# Liste des ordinateurs Windows 7 (obsolète)
Get-ADComputer -Filter "OperatingSystem -like '*Windows 7*'" -Properties OperatingSystem, LastLogonDate |
    Select-Object Name, OperatingSystem, LastLogonDate

# Comptage des versions d'OS
Get-ADComputer -Filter * -Properties OperatingSystem |
    Where-Object {$_.OperatingSystem -like '*Windows*'} |
    Group-Object OperatingSystem |
    Select-Object @{N='Système';E={$_.Name}}, @{N='Nombre';E={$_.Count}} |
    Sort-Object Nombre -Descending
```

#### 🧹 Détection de comptes obsolètes

```powershell
# Ordinateurs inactifs depuis plus de 6 mois
$SeuilInactivite = (Get-Date).AddMonths(-6)
Get-ADComputer -Filter * -Properties LastLogonDate |
    Where-Object {$_.LastLogonDate -lt $SeuilInactivite -or $_.LastLogonDate -eq $null} |
    Select-Object Name, LastLogonDate, DistinguishedName |
    Export-Csv -Path "C:\Ordinateurs_Inactifs.csv" -NoTypeInformation

# Comptage des ordinateurs par plage d'inactivité
Get-ADComputer -Filter * -Properties LastLogonDate |
    Select-Object Name, @{N='Inactivité';E={
        if ($_.LastLogonDate -eq $null) { "Jamais connecté" }
        elseif ($_.LastLogonDate -lt (Get-Date).AddYears(-1)) { "> 1 an" }
        elseif ($_.LastLogonDate -lt (Get-Date).AddMonths(-6)) { "6-12 mois" }
        elseif ($_.LastLogonDate -lt (Get-Date).AddMonths(-3)) { "3-6 mois" }
        else { "< 3 mois" }
    }} |
    Group-Object Inactivité |
    Select-Object Name, Count
```

#### 🔎 Recherche et diagnostic

```powershell
# Recherche d'un ordinateur par adresse IP
Get-ADComputer -Filter * -Properties IPv4Address |
    Where-Object {$_.IPv4Address -eq "192.168.1.50"} |
    Select-Object Name, DNSHostName, IPv4Address

# Liste des ordinateurs d'une OU spécifique
Get-ADComputer -Filter * -SearchBase "OU=Laptops,OU=Workstations,DC=domain,DC=com" -Properties LastLogonDate |
    Select-Object Name, LastLogonDate, Enabled
```

> [!example] Exemple complet : Rapport d'audit mensuel
> 
> ```powershell
> # Script de rapport mensuel sur le parc informatique
> $DateRapport = Get-Date -Format "yyyy-MM"
> $CheminRapport = "C:\Rapports\Audit_$DateRapport.txt"
> 
> # Statistiques générales
> $Total = (Get-ADComputer -Filter *).Count
> $Actifs = (Get-ADComputer -Filter "Enabled -eq $true").Count
> $Inactifs = (Get-ADComputer -Filter "Enabled -eq $false").Count
> 
> # Répartition par OS
> $RepartitionOS = Get-ADComputer -Filter * -Properties OperatingSystem |
>     Group-Object OperatingSystem |
>     Select-Object Count, Name
> 
> # Ordinateurs obsolètes (> 90 jours sans connexion)
> $SeuilObsolete = (Get-Date).AddDays(-90)
> $Obsoletes = Get-ADComputer -Filter * -Properties LastLogonDate |
>     Where-Object {$_.LastLogonDate -lt $SeuilObsolete -or $_.LastLogonDate -eq $null}
> 
> # Création du rapport
> "=== RAPPORT D'AUDIT - $DateRapport ===" | Out-File $CheminRapport
> "" | Out-File $CheminRapport -Append
> "Statistiques générales:" | Out-File $CheminRapport -Append
> "  Total d'ordinateurs : $Total" | Out-File $CheminRapport -Append
> "  Ordinateurs actifs : $Actifs" | Out-File $CheminRapport -Append
> "  Ordinateurs désactivés : $Inactifs" | Out-File $CheminRapport -Append
> "" | Out-File $CheminRapport -Append
> "Répartition par OS:" | Out-File $CheminRapport -Append
> $RepartitionOS | Format-Table -AutoSize | Out-File $CheminRapport -Append
> "" | Out-File $CheminRapport -Append
> "Ordinateurs potentiellement obsolètes : $($Obsoletes.Count)" | Out-File $CheminRapport -Append
> 
> Write-Host "Rapport généré : $CheminRapport" -ForegroundColor Green
> ```

---

## New-ADComputer

### Syntaxe et paramètres

La cmdlet **New-ADComputer** permet de créer de nouveaux comptes ordinateurs dans Active Directory. Cette cmdlet est particulièrement utile pour le provisioning automatisé et le pré-staging de machines.

```powershell
New-ADComputer -Name <nom_ordinateur> [-Path <OU>] [autres paramètres]
```

#### Paramètres obligatoires

|Paramètre|Description|Exemple|
|---|---|---|
|`-Name`|Nom de l'ordinateur (obligatoire)|`New-ADComputer -Name "PC-001"`|

#### Paramètres optionnels

|Paramètre|Description|Valeur par défaut|Exemple|
|---|---|---|---|
|`-SamAccountName`|Nom de compte SAM|`Name$`|`-SamAccountName "PC-001$"`|
|`-Path`|OU de destination|Container "Computers"|`-Path "OU=Workstations,DC=domain,DC=com"`|
|`-Description`|Description du compte|Vide|`-Description "Poste commercial RH"`|
|`-Enabled`|État activé/désactivé|`$false`|`-Enabled $true`|
|`-DNSHostName`|Nom DNS complet (FQDN)|Automatique|`-DNSHostName "pc-001.domain.com"`|
|`-Location`|Localisation physique|Vide|`-Location "Bâtiment A - Bureau 101"`|
|`-ManagedBy`|Gestionnaire du compte|Vide|`-ManagedBy "CN=Jean Dupont,OU=Users,DC=domain,DC=com"`|

> [!info] SamAccountName automatique Si vous ne spécifiez pas `-SamAccountName`, PowerShell génère automatiquement le nom en ajoutant `$` au nom de l'ordinateur. Par exemple, pour `-Name "PC-001"`, le SamAccountName sera `PC-001$`.

> [!warning] État désactivé par défaut Par défaut, les comptes ordinateurs créés avec New-ADComputer sont **désactivés** (`Enabled = $false`). Pensez à utiliser `-Enabled $true` si vous souhaitez que le compte soit immédiatement utilisable.

#### Syntaxe de base

```powershell
# Création minimale (compte désactivé, dans le conteneur par défaut)
New-ADComputer -Name "PC-001"

# Création complète avec tous les paramètres recommandés
New-ADComputer -Name "PC-001" `
    -SamAccountName "PC-001$" `
    -Path "OU=Workstations,OU=IT,DC=domain,DC=com" `
    -Description "Poste de travail - Service Marketing" `
    -Enabled $true `
    -DNSHostName "pc-001.domain.com" `
    -Location "Site Paris - Bât. A - Étage 2" `
    -ManagedBy "CN=Admin IT,OU=Admins,DC=domain,DC=com"
```

### Cas d'usage pratiques

#### 🚀 Provisioning de machines individuelles

```powershell
# Création d'un poste de travail standard
New-ADComputer -Name "DESK-MARKETING-01" `
    -Path "OU=Desktops,OU=Marketing,OU=Workstations,DC=entreprise,DC=local" `
    -Description "Poste fixe - Marketing - Bureau 201" `
    -Location "Paris - Tour A - Étage 2" `
    -Enabled $true

# Création d'un laptop avec gestionnaire
New-ADComputer -Name "LAP-RH-MOBILE-05" `
    -Path "OU=Laptops,OU=RH,OU=Workstations,DC=entreprise,DC=local" `
    -Description "Laptop Dell Latitude - Utilisateur mobile RH" `
    -Location "Itinérant" `
    -ManagedBy "CN=Marie Dubois,OU=RH,OU=Users,DC=entreprise,DC=local" `
    -Enabled $true
```

#### 🏭 Déploiement automatisé en masse

```powershell
# Création de 10 postes de travail avec numérotation
1..10 | ForEach-Object {
    $NomOrdinateur = "DESK-IT-{0:D2}" -f $_
    New-ADComputer -Name $NomOrdinateur `
        -Path "OU=Desktops,OU=IT,OU=Workstations,DC=entreprise,DC=local" `
        -Description "Poste de travail IT - Lot 2024" `
        -Enabled $false  # Désactivé jusqu'au déploiement physique
    Write-Host "Créé : $NomOrdinateur" -ForegroundColor Green
}

# Création à partir d'une liste CSV
# Fichier CSV avec colonnes : Nom, OU, Description, Location
$Ordinateurs = Import-Csv -Path "C:\Provisioning\NouveauxPC.csv"

foreach ($Ordi in $Ordinateurs) {
    try {
        New-ADComputer -Name $Ordi.Nom `
            -Path $Ordi.OU `
            -Description $Ordi.Description `
            -Location $Ordi.Location `
            -Enabled $false `
            -ErrorAction Stop
        Write-Host "✓ Créé : $($Ordi.Nom)" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ Erreur pour $($Ordi.Nom) : $($_.Exception.Message)" -ForegroundColor Red
    }
}
```

#### 📦 Placement dans OUs appropriées

```powershell
# Structure organisationnelle par département et type
$Departements = @{
    "IT" = "OU=IT,OU=Workstations,DC=entreprise,DC=local"
    "RH" = "OU=RH,OU=Workstations,DC=entreprise,DC=local"
    "Finance" = "OU=Finance,OU=Workstations,DC=entreprise,DC=local"
    "Marketing" = "OU=Marketing,OU=Workstations,DC=entreprise,DC=local"
}

$TypeMachine = @{
    "DESK" = "Desktops"
    "LAP" = "Laptops"
    "SRV" = "Servers"
}

# Fonction de création avec placement automatique
function New-OrdinateurEntreprise {
    param(
        [string]$Nom,
        [string]$Departement,
        [string]$Type,
        [string]$Description,
        [string]$Location
    )
    
    # Construction du chemin OU
    $OUBase = $Departements[$Departement]
    $SousOU = $TypeMachine[$Type]
    $CheminComplet = "OU=$SousOU,$OUBase"
    
    # Création de l'ordinateur
    New-ADComputer -Name $Nom `
        -Path $CheminComplet `
        -Description $Description `
        -Location $Location `
        -Enabled $false
    
    Write-Host "Ordinateur $Nom créé dans $CheminComplet" -ForegroundColor Cyan
}

# Utilisation
New-OrdinateurEntreprise -Nom "DESK-IT-15" -Departement "IT" -Type "DESK" `
    -Description "Poste technicien" -Location "Datacenter"
```

#### 🎯 Scripts de staging avancés

```powershell
# Script de staging complet avec vérifications
function New-StagingOrdinateur {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Nom,
        
        [Parameter(Mandatory=$true)]
        [string]$Path,
        
        [string]$Description = "",
        [string]$Location = "",
        [string]$ManagedBy = "",
        [bool]$Activer = $false
    )
    
    # Vérification de l'existence
    $Existe = Get-ADComputer -Filter "Name -eq '$Nom'" -ErrorAction SilentlyContinue
    if ($Existe) {
        Write-Warning "L'ordinateur $Nom existe déjà."
        return $false
    }
    
    # Vérification de l'OU
    try {
        Get-ADOrganizationalUnit -Identity $Path -ErrorAction Stop | Out-Null
    }
    catch {
        Write-Error "L'OU $Path n'existe pas."
        return $false
    }
    
    # Création de l'ordinateur
    try {
        $Params = @{
            Name = $Nom
            Path = $Path
            Enabled = $Activer
        }
        
        if ($Description) { $Params.Description = $Description }
        if ($Location) { $Params.Location = $Location }
        if ($ManagedBy) { $Params.ManagedBy = $ManagedBy }
        
        New-ADComputer @Params -ErrorAction Stop
        
        Write-Host "✓ Ordinateur $Nom créé avec succès" -ForegroundColor Green
        
        # Log de création
        $LogEntry = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Créé : $Nom dans $Path"
        Add-Content -Path "C:\Logs\CreationOrdinateurs.log" -Value $LogEntry
        
        return $true
    }
    catch {
        Write-Error "Erreur lors de la création de $Nom : $($_.Exception.Message)"
        return $false
    }
}

# Utilisation du script avec pipeline
$NouveauxOrdinateurs = @(
    @{Nom="PC-DEV-01"; Path="OU=Dev,OU=IT,DC=domain,DC=com"; Description="Poste développeur"; Location="Site A"},
    @{Nom="PC-DEV-02"; Path="OU=Dev,OU=IT,DC=domain,DC=com"; Description="Poste développeur"; Location="Site A"},
    @{Nom="PC-TEST-01"; Path="OU=Test,OU=IT,DC=domain,DC=com"; Description="Machine de test"; Location="Labo"}
)

$NouveauxOrdinateurs | ForEach-Object {
    New-StagingOrdinateur @_
}
```

> [!example] Exemple complet : Workflow de provisioning
> 
> ```powershell
> # Workflow complet : de la demande à la création
> 
> # 1. Lecture du fichier de demande
> $Demandes = Import-Csv -Path "C:\Provisioning\Demandes_Semaine.csv"
> # CSV attendu : Nom, Departement, Type, Utilisateur, Description
> 
> # 2. Mapping des départements vers OUs
> $MapDepartement = @{
>     "IT" = "OU=IT,OU=Workstations,DC=entreprise,DC=local"
>     "RH" = "OU=RH,OU=Workstations,DC=entreprise,DC=local"
>     "Commercial" = "OU=Commercial,OU=Workstations,DC=entreprise,DC=local"
> }
> 
> # 3. Mapping des types de machines
> $MapType = @{
>     "Desktop" = "Desktops"
>     "Laptop" = "Laptops"
> }
> 
> # 4. Traitement des demandes
> $Rapport = @()
> 
> foreach ($Demande in $Demandes) {
>     # Construction du nom (format : TYPE-DEPT-XX)
>     $Prefixe = if ($Demande.Type -eq "Desktop") { "DESK" } else { "LAP" }
>     $NomBase = "$Prefixe-$($Demande.Departement)"
>     
>     # Recherche du prochain numéro disponible
>     $Existants = Get-ADComputer -Filter "Name -like '$NomBase-*'" |
>         ForEach-Object { [int]($_.Name -replace "$NomBase-", "") } |
>         Sort-Object
>     $ProchainNumero = if ($Existants) { ($Existants | Select-Object -Last 1) + 1 } else { 1 }
>     $NomComplet = "{0}-{1:D2}" -f $NomBase, $ProchainNumero
>     
>     # Construction du chemin OU
>     $OUBase = $MapDepartement[$Demande.Departement]
>     $SousOU = $MapType[$Demande.Type]
>     $CheminOU = "OU=$SousOU,$OUBase"
>     
>     # Récupération du DN de l'utilisateur pour ManagedBy
>     $Utilisateur = Get-ADUser -Filter "SamAccountName -eq '$($Demande.Utilisateur)'" -ErrorAction SilentlyContinue
>     
>     # Création de l'ordinateur
>     try {
>         $Params = @{
>             Name = $NomComplet
>             Path = $CheminOU
>             Description = "$($Demande.Description) - Attribué à $($Demande.Utilisateur)"
>             Enabled = $false  # Désactivé jusqu'au déploiement
>         }
>         
>         if ($Utilisateur) {
>             $Params.ManagedBy = $Utilisateur.DistinguishedName
>         }
>         
>         New-ADComputer @Params -ErrorAction Stop
>         
>         $Rapport += [PSCustomObject]@{
>             Nom = $NomComplet
>             Departement = $Demande.Departement
>             Type = $Demande.Type
>             Utilisateur = $Demande.Utilisateur
>             Statut = "✓ Créé"
>             OU = $CheminOU
>         }
>         
>         Write-Host "✓ $NomComplet créé avec succès" -ForegroundColor Green
>     }
>     catch {
>         $Rapport += [PSCustomObject]@{
>             Nom = $NomComplet
>             Departement = $Demande.Departement
>             Type = $Demande.Type
>             Utilisateur = $Demande.Utilisateur
>             Statut = "✗ Erreur : $($_.Exception.Message)"
>             OU = $CheminOU
>         }
>         
>         Write-Host "✗ Erreur pour $NomComplet : $($_.Exception.Message)" -ForegroundColor Red
>     }
> }
> 
> # 5. Export du rapport
> $DateRapport = Get-Date -Format "yyyyMMdd_HHmmss"
> $Rapport | Export-Csv -Path "C:\Provisioning\Rapport_$DateRapport.csv" -NoTypeInformation
> 
> # 6. Affichage résumé
> Write-Host "`n=== RÉSUMÉ DU PROVISIONING ===" -ForegroundColor Cyan
> Write-Host "Total de demandes : $($Demandes.Count)" -ForegroundColor White
> Write-Host "Créations réussies : $(($Rapport | Where-Object {$_.Statut -like '*Créé*'}).Count)" -ForegroundColor Green
> Write-Host "Échecs : $(($Rapport | Where-Object {$_.Statut -like '*Erreur*'}).Count)" -ForegroundColor Red
> Write-Host "`nRapport exporté : C:\Provisioning\Rapport_$DateRapport.csv" -ForegroundColor Yellow
> ```

---

## Bonnes pratiques

> [!tip] Convention de nommage Adoptez une convention de nommage cohérente pour vos ordinateurs :
> 
> - **TYPE-DEPT-XX** : `DESK-IT-01`, `LAP-RH-05`, `SRV-PROD-03`
> - **FONCTION-LIEU-XX** : `WORKSTATION-PARIS-001`, `SERVER-DC-001`
> - Utilisez des préfixes clairs (DESK, LAP, SRV, VM)
> - Numérotez avec des zéros de remplissage (01, 02... au lieu de 1, 2...)

> [!tip] Organisation des OUs Structurez vos OUs de manière logique :
> 
> ```
> Workstations/
> ├── IT/
> │   ├── Desktops/
> │   └── Laptops/
> ├── RH/
> │   ├── Desktops/
> │   └── Laptops/
> └── Commercial/
>     ├── Desktops/
>     └── Laptops/
> ```
> 
> Cela facilite l'application de GPO et la gestion par département.

> [!tip] Propriété ManagedBy Utilisez systématiquement `-ManagedBy` pour tracer la responsabilité :
> 
> - Attribuez le compte de l'utilisateur principal du poste
> - Ou le gestionnaire IT responsable du matériel
> - Facilite l'identification en cas d'incident ou de besoin de maintenance

> [!warning] Comptes désactivés par défaut Les comptes créés avec `New-ADComputer` sont désactivés par défaut. C'est une mesure de sécurité : vous devez explicitement utiliser `-Enabled $true` pour activer le compte. Cela évite qu'un compte ne soit exploité avant le déploiement physique de la machine.

> [!tip] Validation avant création Avant de créer des ordinateurs en masse, vérifiez toujours :
> 
> - Que le nom n'existe pas déjà : `Get-ADComputer -Filter "Name -eq '$Nom'"`
> - Que l'OU de destination existe et est accessible
> - Que la convention de nommage est respectée
> - Que vous avez les droits nécessaires sur l'OU cible

> [!tip] Logging et traçabilité Gardez une trace de vos opérations :
> 
> ```powershell
> # Exemple de logging simple
> $LogFile = "C:\Logs\CreationOrdinateurs_$(Get-Date -Format 'yyyyMMdd').log"
> $Message = "[$(Get-Date -Format 'HH:mm:ss')] Création de $NomOrdinateur dans $OU"
> Add-Content -Path $LogFile -Value $Message
> ```
> 
> Cela facilite l'audit et le dépannage en cas de problème.

> [!warning] Gestion des erreurs Utilisez toujours des blocs `try/catch` lors de créations automatisées :
> 
> ```powershell
> try {
>     New-ADComputer -Name $Nom -Path $OU -ErrorAction Stop
>     Write-Host "✓ Succès" -ForegroundColor Green
> }
> catch {
>     Write-Host "✗ Erreur : $($_.Exception.Message)" -ForegroundColor Red
>     # Log de l'erreur pour investigation
> }
> ```

> [!tip] Nettoyage régulier Mettez en place une routine de nettoyage :
> 
> - Identifiez les comptes inactifs depuis plus de 6 mois
> - Vérifiez les comptes jamais connectés créés il y a plus de 30 jours
> - Désactivez avant de supprimer (période de grâce de 30 jours)
> - Documentez les suppressions dans un rapport d'audit

> [!tip] Propriétés étendues utiles N'oubliez pas de renseigner les propriétés étendues lors de la création :
> 
> - **Location** : localisation physique pour le support terrain
> - **Description** : fonction, département, utilisateur principal
> - **ManagedBy** : responsable du matériel Ces informations sont précieuses pour la gestion quotidienne et les audits.

> [!warning] Droits nécessaires Pour créer des ordinateurs dans Active Directory, vous devez disposer :
> 
> - Du droit **Create Computer Objects** sur l'OU cible
> - Ou être membre du groupe **Account Operators** (ou équivalent)
> - Ou être **Domain Admin** (privilège élevé, à éviter en production)
> 
> Privilégiez la délégation de droits spécifiques sur les OUs concernées.

> [!tip] Automatisation avec scripts planifiés Pour le provisioning automatisé :
> 
> 1. Créez un dossier de dépôt pour les demandes (fichiers CSV)
> 2. Planifiez un script qui traite automatiquement les demandes
> 3. Générez des rapports automatiques envoyés par email
> 4. Implémentez un workflow de validation si nécessaire
> 
> ```powershell
> # Exemple de tâche planifiée
> $Action = New-ScheduledTaskAction -Execute "PowerShell.exe" `
>     -Argument "-File C:\Scripts\Provisioning-Ordinateurs.ps1"
> $Trigger = New-ScheduledTaskTrigger -Daily -At "08:00"
> Register-ScheduledTask -TaskName "Provisioning AD" -Action $Action -Trigger $Trigger
> ```

---

## 🎯 Points clés à retenir

### Get-ADComputer

✅ **Quand l'utiliser**

- Inventaire et audit du parc informatique
- Identification de machines obsolètes ou inactives
- Recherche et diagnostic réseau
- Génération de rapports de conformité

✅ **Paramètres essentiels**

- `-Filter` pour les recherches ciblées
- `-Properties` pour obtenir les attributs étendus
- `-SearchBase` pour limiter la portée de recherche

✅ **Propriétés critiques à surveiller**

- `LastLogonDate` : détecter les comptes inactifs
- `OperatingSystem` : identifier les OS obsolètes
- `Enabled` : vérifier l'état des comptes
- `IPv4Address` : diagnostic réseau

### New-ADComputer

✅ **Quand l'utiliser**

- Provisioning de nouvelles machines
- Pré-création avant déploiement physique
- Automatisation de déploiements en masse
- Staging pour migration ou refresh de parc

✅ **Paramètres recommandés**

- `-Name` (obligatoire) : nom de l'ordinateur
- `-Path` : placement dans la bonne OU
- `-Description` : documentation intégrée
- `-Enabled $true` : activation explicite si nécessaire
- `-ManagedBy` : traçabilité et responsabilité

✅ **Workflow type**

1. Valider le nom et vérifier l'unicité
2. Déterminer l'OU de destination
3. Créer le compte (désactivé par défaut)
4. Documenter avec Description et Location
5. Logger l'opération
6. Activer au moment du déploiement physique

---

## 📝 Antisèches pratiques

### Commandes rapides - Get-ADComputer

```powershell
# Lister tous les ordinateurs
Get-ADComputer -Filter *

# Recherche par nom
Get-ADComputer -Identity "PC-001"

# Ordinateurs d'une OU spécifique
Get-ADComputer -Filter * -SearchBase "OU=IT,DC=domain,DC=com"

# Ordinateurs Windows 11
Get-ADComputer -Filter "OperatingSystem -like '*Windows 11*'" -Properties OperatingSystem

# Ordinateurs actifs
Get-ADComputer -Filter "Enabled -eq $true"

# Ordinateurs inactifs > 90 jours
$Date = (Get-Date).AddDays(-90)
Get-ADComputer -Filter * -Properties LastLogonDate | Where-Object {$_.LastLogonDate -lt $Date}

# Export CSV complet
Get-ADComputer -Filter * -Properties * | Export-Csv "C:\inventory.csv" -NoTypeInformation

# Comptage par OS
Get-ADComputer -Filter * -Properties OperatingSystem | Group-Object OperatingSystem

# Recherche par IP
Get-ADComputer -Filter * -Properties IPv4Address | Where-Object {$_.IPv4Address -eq "192.168.1.100"}
```

### Commandes rapides - New-ADComputer

```powershell
# Création basique
New-ADComputer -Name "PC-001"

# Création complète
New-ADComputer -Name "PC-001" -Path "OU=IT,DC=domain,DC=com" -Description "Poste IT" -Enabled $true

# Création en masse (1 à 10)
1..10 | ForEach-Object {
    New-ADComputer -Name "PC-$($_.ToString('00'))" -Path "OU=IT,DC=domain,DC=com"
}

# Depuis CSV
Import-Csv "computers.csv" | ForEach-Object {
    New-ADComputer -Name $_.Name -Path $_.OU -Description $_.Description
}

# Avec gestion d'erreurs
try {
    New-ADComputer -Name "PC-001" -Path "OU=IT,DC=domain,DC=com" -ErrorAction Stop
    Write-Host "✓ Créé" -ForegroundColor Green
}
catch {
    Write-Host "✗ Erreur : $_" -ForegroundColor Red
}
```

### Filtres courants

```powershell
# Par système d'exploitation
-Filter "OperatingSystem -like '*Windows*'"
-Filter "OperatingSystem -like '*Server*'"
-Filter "OperatingSystem -eq 'Windows 11 Pro'"

# Par état
-Filter "Enabled -eq $true"
-Filter "Enabled -eq $false"

# Par date
-Filter "LastLogonDate -lt $Date"
-Filter "WhenCreated -gt $Date"
-Filter "LastLogonDate -notlike '*'"  # Jamais connecté

# Par nom
-Filter "Name -like 'PC-*'"
-Filter "Name -like '*-IT-*'"
-Filter "Name -like 'LAP-??-*'"

# Combinaisons
-Filter "Enabled -eq $true -and OperatingSystem -like '*Windows 11*'"
-Filter "Enabled -eq $false -and LastLogonDate -lt $Date"
```

---

## 🔍 Scénarios de dépannage

### Problème : Impossible de créer un ordinateur

**Symptôme** : Erreur "Access Denied" lors de la création

**Solutions** :

```powershell
# Vérifier vos droits sur l'OU
Get-Acl "OU=IT,DC=domain,DC=com" | Select-Object -ExpandProperty Access | 
    Where-Object {$_.IdentityReference -like "*$env:USERNAME*"}

# Créer dans une OU où vous avez les droits
New-ADComputer -Name "PC-001" -Path "OU=Test,DC=domain,DC=com"

# Vérifier si l'ordinateur existe déjà
Get-ADComputer -Filter "Name -eq 'PC-001'"
```

### Problème : Ordinateur créé mais invisible dans l'OU

**Symptôme** : Get-ADComputer trouve l'ordinateur mais pas dans l'interface graphique

**Solutions** :

```powershell
# Vérifier l'emplacement réel
Get-ADComputer -Identity "PC-001" | Select-Object DistinguishedName

# Rafraîchir la console ADUC (F5)
# Ou vérifier les filtres d'affichage dans ADUC

# Déplacer si nécessaire vers la bonne OU
Move-ADObject -Identity "CN=PC-001,CN=Computers,DC=domain,DC=com" `
    -TargetPath "OU=IT,DC=domain,DC=com"
```

### Problème : Comptes ordinateurs inactifs en masse

**Symptôme** : Nombreux comptes jamais connectés ou très anciens

**Solution** :

```powershell
# Audit des comptes suspects
$DateLimite = (Get-Date).AddMonths(-6)
$Suspects = Get-ADComputer -Filter * -Properties LastLogonDate, WhenCreated |
    Where-Object {
        ($_.LastLogonDate -eq $null -and $_.WhenCreated -lt $DateLimite) -or
        ($_.LastLogonDate -lt $DateLimite)
    }

# Export pour validation
$Suspects | Select-Object Name, LastLogonDate, WhenCreated, DistinguishedName |
    Export-Csv "C:\Audit\Comptes_Inactifs.csv" -NoTypeInformation

# Désactivation progressive (avec validation manuelle recommandée)
$Suspects | ForEach-Object {
    Set-ADComputer -Identity $_.Name -Enabled $false
    Write-Host "Désactivé : $($_.Name)"
}

# Suppression après période de grâce (30 jours après désactivation)
# À faire uniquement après validation !
```

### Problème : Données d'inventaire incorrectes

**Symptôme** : LastLogonDate ou OperatingSystem manquants ou obsolètes

**Solutions** :

```powershell
# LastLogonDate peut être null si jamais connecté
Get-ADComputer -Filter * -Properties LastLogonDate |
    Where-Object {$_.LastLogonDate -eq $null} |
    Select-Object Name, WhenCreated

# Pour forcer la mise à jour des infos système
# La machine doit se reconnecter au domaine

# Vérifier la réplication AD si incohérences entre DCs
Get-ADComputer -Identity "PC-001" -Server "DC1.domain.com" -Properties LastLogonDate
Get-ADComputer -Identity "PC-001" -Server "DC2.domain.com" -Properties LastLogonDate
```

---

**🎓 Fin du cours - Active Directory : Gestion des ordinateurs**