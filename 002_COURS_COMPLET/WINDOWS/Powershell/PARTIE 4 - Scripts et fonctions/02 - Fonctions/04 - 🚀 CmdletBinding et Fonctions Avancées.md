

## 📑 Table des matières

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

## 🎯 Introduction

Les **fonctions avancées** (Advanced Functions) sont des fonctions PowerShell qui se comportent exactement comme des cmdlets natifs. Grâce à l'attribut `[CmdletBinding()]`, une simple fonction PowerShell hérite automatiquement de nombreuses fonctionnalités professionnelles sans avoir besoin d'écrire du code C#.

> [!info] Pourquoi utiliser CmdletBinding ?
> 
> - Transforme votre fonction en cmdlet professionnel
> - Ajoute automatiquement des paramètres communs (-Verbose, -Debug, -ErrorAction, etc.)
> - Permet une gestion avancée du pipeline
> - Support natif de -WhatIf et -Confirm
> - Meilleure intégration dans l'écosystème PowerShell

---

## 🔧 L'attribut CmdletBinding

### Syntaxe de base

L'attribut `[CmdletBinding()]` se place au tout début de la fonction, avant la déclaration des paramètres.

```powershell
function Get-UserInfo {
    [CmdletBinding()]
    param(
        [string]$Username
    )
    
    Write-Verbose "Récupération des informations pour $Username"
    # Logique de la fonction...
}
```

### Propriétés de CmdletBinding

```powershell
function Set-Configuration {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'High',
        DefaultParameterSetName = 'ByName',
        PositionalBinding = $false
    )]
    param(
        [string]$ConfigName,
        [string]$Value
    )
    
    # Code de la fonction...
}
```

|Propriété|Type|Description|
|---|---|---|
|`SupportsShouldProcess`|Boolean|Active -WhatIf et -Confirm|
|`ConfirmImpact`|String|Niveau de confirmation (None, Low, Medium, High)|
|`DefaultParameterSetName`|String|Set de paramètres par défaut|
|`PositionalBinding`|Boolean|Active/désactive les paramètres positionnels|
|`HelpUri`|String|URL de la documentation d'aide|

> [!tip] Bonne pratique Ajoutez toujours `[CmdletBinding()]` à vos fonctions professionnelles, même si vous n'utilisez pas ses propriétés immédiatement. Cela facilite l'évolution future de votre code.

---

## ⚡ Transformation en cmdlet avancée

### Avant : Fonction simple

```powershell
function Get-DiskSpace {
    param([string]$ComputerName = $env:COMPUTERNAME)
    
    Get-WmiObject Win32_LogicalDisk -ComputerName $ComputerName |
        Where-Object {$_.DriveType -eq 3}
}
```

### Après : Fonction avancée

```powershell
function Get-DiskSpace {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [string]$ComputerName = $env:COMPUTERNAME
    )
    
    process {
        Write-Verbose "Analyse du disque sur $ComputerName"
        
        try {
            Get-WmiObject Win32_LogicalDisk -ComputerName $ComputerName -ErrorAction Stop |
                Where-Object {$_.DriveType -eq 3}
        }
        catch {
            Write-Error "Impossible de contacter $ComputerName : $_"
        }
    }
}
```

> [!example] Avantages immédiats
> 
> - Support automatique de `-Verbose` et `-Debug`
> - Gestion d'erreur améliorée avec `-ErrorAction`
> - Intégration pipeline avec le bloc `process`
> - Traçabilité et débogage facilités

---

## 📋 Paramètres communs automatiques

Une fois `[CmdletBinding()]` ajouté, votre fonction hérite automatiquement de ces paramètres :

### Liste des paramètres communs

```powershell
function Test-AdvancedFunction {
    [CmdletBinding()]
    param([string]$Message)
    
    Write-Verbose "Message en mode verbose : $Message"
    Write-Debug "Point de débogage atteint"
    
    $Message
}

# Utilisation automatique des paramètres communs
Test-AdvancedFunction -Message "Test" -Verbose
Test-AdvancedFunction -Message "Test" -Debug
Test-AdvancedFunction -Message "Test" -ErrorAction Stop
```

|Paramètre|Description|Exemple|
|---|---|---|
|`-Verbose`|Affiche les messages Write-Verbose|`-Verbose`|
|`-Debug`|Affiche les messages Write-Debug et pause|`-Debug`|
|`-ErrorAction`|Contrôle le comportement des erreurs|`-ErrorAction Stop`|
|`-WarningAction`|Contrôle l'affichage des avertissements|`-WarningAction SilentlyContinue`|
|`-InformationAction`|Contrôle les messages d'information|`-InformationAction Continue`|
|`-ErrorVariable`|Stocke les erreurs dans une variable|`-ErrorVariable err`|
|`-WarningVariable`|Stocke les avertissements|`-WarningVariable warn`|
|`-OutVariable`|Stocke la sortie dans une variable|`-OutVariable result`|
|`-OutBuffer`|Taille du buffer de sortie|`-OutBuffer 1000`|
|`-PipelineVariable`|Crée une variable pour le pipeline|`-PipelineVariable item`|

### Utilisation pratique

```powershell
function Save-UserData {
    [CmdletBinding()]
    param(
        [string]$Username,
        [string]$FilePath
    )
    
    Write-Verbose "Début de la sauvegarde pour $Username"
    Write-Debug "Chemin cible : $FilePath"
    
    if (Test-Path $FilePath) {
        Write-Warning "Le fichier existe déjà et sera écrasé"
    }
    
    # Logique de sauvegarde...
    Write-Verbose "Sauvegarde terminée avec succès"
}

# Appels avec différents paramètres communs
Save-UserData -Username "Alice" -FilePath "C:\data.txt" -Verbose
Save-UserData -Username "Bob" -FilePath "C:\data.txt" -WarningAction SilentlyContinue
```

> [!warning] Attention Les paramètres communs sont réservés et ne peuvent pas être utilisés comme noms de paramètres personnalisés dans votre fonction.

---

## 🔄 Support du pipeline

Le pipeline est l'une des fonctionnalités les plus puissantes de PowerShell. Les fonctions avancées offrent deux méthodes principales pour accepter des données du pipeline.

### ValueFromPipeline

Accepte l'objet entier du pipeline.

```powershell
function Get-SquaredNumber {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [int]$Number
    )
    
    process {
        [PSCustomObject]@{
            Original = $Number
            Squared  = $Number * $Number
        }
    }
}

# Utilisation
1..5 | Get-SquaredNumber

# Résultat :
# Original Squared
# -------- -------
#        1       1
#        2       4
#        3       9
#        4      16
#        5      25
```

### ValueFromPipelineByPropertyName

Accepte les objets dont les propriétés correspondent aux noms de paramètres.

```powershell
function Get-UserDetails {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]$Name,
        
        [Parameter(ValueFromPipelineByPropertyName = $true)]
        [string]$Department
    )
    
    process {
        Write-Verbose "Traitement de $Name du département $Department"
        
        [PSCustomObject]@{
            FullName    = $Name
            Department  = $Department
            Status      = "Active"
            ProcessedAt = Get-Date
        }
    }
}

# Utilisation avec des objets ayant les bonnes propriétés
$users = @(
    [PSCustomObject]@{ Name = "Alice"; Department = "IT" }
    [PSCustomObject]@{ Name = "Bob"; Department = "HR" }
)

$users | Get-UserDetails -Verbose
```

### Combinaison des deux méthodes

```powershell
function Copy-FileWithLog {
    [CmdletBinding()]
    param(
        # Accepte le chemin source du pipeline (par valeur ou propriété)
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias('FullName', 'Path')]
        [string]$Source,
        
        # Destination (paramètre obligatoire)
        [Parameter(Mandatory = $true)]
        [string]$Destination
    )
    
    process {
        Write-Verbose "Copie de $Source vers $Destination"
        
        try {
            Copy-Item -Path $Source -Destination $Destination -ErrorAction Stop
            Write-Host "✓ Copié : $Source" -ForegroundColor Green
        }
        catch {
            Write-Error "✗ Échec : $Source - $_"
        }
    }
}

# Utilisation multiple
Get-ChildItem "C:\Source\*.txt" | Copy-FileWithLog -Destination "C:\Backup\" -Verbose
```

> [!tip] Astuce pour le pipeline Utilisez l'alias `[Alias('FullName')]` sur votre paramètre pour accepter directement les sorties de `Get-ChildItem`, `Get-Item`, etc., qui retournent une propriété `FullName`.

---

## 🔀 Les blocs Begin, Process, End

Les fonctions avancées peuvent définir trois blocs distincts pour gérer différentes phases de l'exécution, particulièrement utiles avec le pipeline.

### Structure complète

```powershell
function Measure-Pipeline {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [object]$InputObject
    )
    
    begin {
        # Exécuté UNE FOIS au début
        Write-Verbose "=== Début du traitement ==="
        $count = 0
        $totalSize = 0
    }
    
    process {
        # Exécuté POUR CHAQUE objet du pipeline
        $count++
        
        if ($InputObject.Length) {
            $totalSize += $InputObject.Length
        }
        
        Write-Verbose "Objet $count traité"
    }
    
    end {
        # Exécuté UNE FOIS à la fin
        Write-Verbose "=== Fin du traitement ==="
        
        [PSCustomObject]@{
            TotalObjects = $count
            TotalSize    = $totalSize
            AverageSize  = if($count -gt 0) { $totalSize / $count } else { 0 }
        }
    }
}

# Utilisation
Get-ChildItem "C:\Windows\System32\*.dll" | Measure-Pipeline -Verbose
```

### Quand utiliser chaque bloc ?

#### Begin - Initialisation

```powershell
function Export-ToDatabase {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [object]$Data,
        
        [string]$ConnectionString
    )
    
    begin {
        # Ouvrir la connexion UNE SEULE FOIS
        Write-Verbose "Ouverture de la connexion à la base de données"
        $connection = New-Object System.Data.SqlClient.SqlConnection
        $connection.ConnectionString = $ConnectionString
        $connection.Open()
        
        $insertCount = 0
    }
    
    process {
        # Insérer CHAQUE élément
        Write-Verbose "Insertion de l'enregistrement $($insertCount + 1)"
        # Code d'insertion...
        $insertCount++
    }
    
    end {
        # Fermer la connexion UNE SEULE FOIS
        Write-Verbose "Fermeture de la connexion ($insertCount enregistrements insérés)"
        $connection.Close()
        $connection.Dispose()
    }
}
```

#### Process - Traitement itératif

```powershell
function Convert-Temperature {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [double]$Celsius
    )
    
    process {
        # Traiter CHAQUE température
        [PSCustomObject]@{
            Celsius    = $Celsius
            Fahrenheit = ($Celsius * 9/5) + 32
            Kelvin     = $Celsius + 273.15
        }
    }
}

# Chaque valeur est traitée individuellement
0, 25, 100 | Convert-Temperature
```

#### End - Finalisation et résumé

```powershell
function Test-NetworkConnectivity {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [string]$ComputerName
    )
    
    begin {
        $results = @()
    }
    
    process {
        $results += Test-Connection -ComputerName $ComputerName -Count 1 -Quiet
    }
    
    end {
        # Produire un rapport final
        $successCount = ($results | Where-Object {$_}).Count
        $totalCount = $results.Count
        
        [PSCustomObject]@{
            TotalTested = $totalCount
            Successful  = $successCount
            Failed      = $totalCount - $successCount
            SuccessRate = "{0:P0}" -f ($successCount / $totalCount)
        }
    }
}

# Résultat : un seul objet résumé à la fin
"server1", "server2", "server3" | Test-NetworkConnectivity
```

> [!warning] Piège courant Sans bloc `process`, le paramètre pipeline ne recevra que le **dernier** objet du pipeline ! Utilisez toujours `process` pour traiter chaque élément.

### Exemple : Fonction sans bloc process (incorrect)

```powershell
function Bad-PipelineFunction {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [int]$Number
    )
    
    # PAS de bloc process - seul le DERNIER nombre sera traité !
    Write-Host "Nombre reçu : $Number"
}

1..5 | Bad-PipelineFunction
# Affiche seulement : Nombre reçu : 5
```

### Exemple : Fonction avec bloc process (correct)

```powershell
function Good-PipelineFunction {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        [int]$Number
    )
    
    process {
        # Traite CHAQUE nombre
        Write-Host "Nombre reçu : $Number"
    }
}

1..5 | Good-PipelineFunction
# Affiche :
# Nombre reçu : 1
# Nombre reçu : 2
# Nombre reçu : 3
# Nombre reçu : 4
# Nombre reçu : 5
```

---

## ✅ SupportsShouldProcess

Cette fonctionnalité permet à vos fonctions de supporter `-WhatIf` et `-Confirm`, essentiels pour les opérations destructives ou critiques.

### Activation de base

```powershell
function Remove-CustomFile {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )
    
    # Demander confirmation avant l'action
    if ($PSCmdlet.ShouldProcess($Path, "Supprimer le fichier")) {
        Remove-Item -Path $Path -Force
        Write-Verbose "Fichier supprimé : $Path"
    }
}

# Utilisation
Remove-CustomFile -Path "C:\temp\test.txt" -WhatIf  # Simule l'action
Remove-CustomFile -Path "C:\temp\test.txt" -Confirm # Demande confirmation
```

### Méthode ShouldProcess - Signatures multiples

```powershell
# Signature simple
$PSCmdlet.ShouldProcess("target")

# Signature avec action
$PSCmdlet.ShouldProcess("target", "action")

# Signature complète avec description
$PSCmdlet.ShouldProcess("target", "action", "description")
```

### Exemple avancé avec ConfirmImpact

```powershell
function Reset-UserPassword {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'High'  # Force la confirmation même sans -Confirm
    )]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$Username,
        
        [Parameter(Mandatory = $true)]
        [securestring]$NewPassword
    )
    
    process {
        # Description complète pour l'utilisateur
        $confirmMessage = "Réinitialiser le mot de passe"
        $whatIfMessage = "Mot de passe réinitialisé pour $Username"
        
        if ($PSCmdlet.ShouldProcess($Username, $confirmMessage)) {
            try {
                # Code de réinitialisation...
                Set-ADAccountPassword -Identity $Username -NewPassword $NewPassword -ErrorAction Stop
                Write-Host "✓ Mot de passe réinitialisé pour $Username" -ForegroundColor Green
            }
            catch {
                Write-Error "Échec de la réinitialisation pour $Username : $_"
            }
        }
        else {
            Write-Verbose "Opération annulée pour $Username"
        }
    }
}

# Simule l'action sans l'exécuter
Reset-UserPassword -Username "alice" -NewPassword $securePass -WhatIf

# Demande confirmation avant chaque utilisateur
Get-ADUser -Filter * | Reset-UserPassword -NewPassword $securePass -Confirm
```

### Niveaux de ConfirmImpact

|Niveau|Description|Comportement|
|---|---|---|
|`None`|Aucun impact|Pas de confirmation|
|`Low`|Impact faible|Confirmation si `$ConfirmPreference = 'Low'`|
|`Medium`|Impact moyen|Confirmation si `$ConfirmPreference = 'Medium'` (défaut)|
|`High`|Impact élevé|Demande toujours confirmation|

### Exemple pratique complet

```powershell
function Stop-ServiceSafely {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'Medium'
    )]
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias('ServiceName')]
        [string]$Name,
        
        [switch]$Force
    )
    
    process {
        $service = Get-Service -Name $Name -ErrorAction SilentlyContinue
        
        if (-not $service) {
            Write-Warning "Service introuvable : $Name"
            return
        }
        
        if ($service.Status -eq 'Stopped') {
            Write-Verbose "$Name est déjà arrêté"
            return
        }
        
        # Message personnalisé selon l'option Force
        $action = if ($Force) { "Arrêt forcé" } else { "Arrêt" }
        
        if ($PSCmdlet.ShouldProcess($Name, "$action du service")) {
            try {
                if ($Force) {
                    Stop-Service -Name $Name -Force -ErrorAction Stop
                }
                else {
                    Stop-Service -Name $Name -ErrorAction Stop
                }
                
                Write-Host "✓ Service arrêté : $Name" -ForegroundColor Green
            }
            catch {
                Write-Error "Impossible d'arrêter $Name : $_"
            }
        }
    }
}

# Exemples d'utilisation
Stop-ServiceSafely -Name "Spooler" -WhatIf
Get-Service "W*" | Stop-ServiceSafely -Confirm
Stop-ServiceSafely -Name "wuauserv" -Force -Verbose
```

> [!tip] Bonne pratique Utilisez toujours `SupportsShouldProcess` pour les fonctions qui :
> 
> - Modifient des données
> - Suppriment des éléments
> - Arrêtent des services
> - Modifient des configurations système
> - Effectuent des actions irréversibles

---

## 🎛️ Parameter Sets

Les **Parameter Sets** permettent de définir différentes combinaisons de paramètres mutuellement exclusives dans une même fonction.

### Concept de base

```powershell
function Get-UserInfo {
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    param(
        # Set 1 : Recherche par nom
        [Parameter(ParameterSetName = 'ByName', Mandatory = $true)]
        [string]$Name,
        
        # Set 2 : Recherche par ID
        [Parameter(ParameterSetName = 'ById', Mandatory = $true)]
        [int]$Id,
        
        # Paramètre commun aux deux sets
        [Parameter()]
        [string]$Domain = "contoso.com"
    )
    
    # Déterminer quel set est utilisé
    Write-Verbose "Parameter Set utilisé : $($PSCmdlet.ParameterSetName)"
    
    switch ($PSCmdlet.ParameterSetName) {
        'ByName' {
            Write-Host "Recherche de l'utilisateur : $Name@$Domain"
            # Logique de recherche par nom...
        }
        'ById' {
            Write-Host "Recherche de l'utilisateur avec l'ID : $Id"
            # Logique de recherche par ID...
        }
    }
}

# Utilisation - L'un OU l'autre, pas les deux
Get-UserInfo -Name "alice"              # ✓ OK - Set ByName
Get-UserInfo -Id 1001                   # ✓ OK - Set ById
Get-UserInfo -Name "alice" -Id 1001     # ✗ ERREUR - Sets incompatibles
```

### Exemple avancé : Fonction de sauvegarde

```powershell
function Backup-Data {
    [CmdletBinding(
        DefaultParameterSetName = 'Local',
        SupportsShouldProcess = $true
    )]
    param(
        # Paramètre obligatoire commun
        [Parameter(Mandatory = $true)]
        [string]$SourcePath,
        
        # Set 1 : Sauvegarde locale
        [Parameter(ParameterSetName = 'Local', Mandatory = $true)]
        [string]$LocalDestination,
        
        # Set 2 : Sauvegarde réseau
        [Parameter(ParameterSetName = 'Network', Mandatory = $true)]
        [string]$NetworkPath,
        
        [Parameter(ParameterSetName = 'Network', Mandatory = $true)]
        [PSCredential]$Credential,
        
        # Set 3 : Sauvegarde cloud
        [Parameter(ParameterSetName = 'Cloud', Mandatory = $true)]
        [string]$CloudContainer,
        
        [Parameter(ParameterSetName = 'Cloud', Mandatory = $true)]
        [string]$ApiKey,
        
        # Paramètre optionnel commun à tous les sets
        [Parameter()]
        [switch]$Compress
    )
    
    Write-Verbose "Mode de sauvegarde : $($PSCmdlet.ParameterSetName)"
    Write-Verbose "Source : $SourcePath"
    
    if (-not (Test-Path $SourcePath)) {
        Write-Error "Le chemin source n'existe pas : $SourcePath"
        return
    }
    
    switch ($PSCmdlet.ParameterSetName) {
        'Local' {
            if ($PSCmdlet.ShouldProcess($LocalDestination, "Sauvegarde locale")) {
                Write-Host "📁 Sauvegarde locale vers : $LocalDestination"
                # Logique de copie locale...
            }
        }
        
        'Network' {
            if ($PSCmdlet.ShouldProcess($NetworkPath, "Sauvegarde réseau")) {
                Write-Host "🌐 Sauvegarde réseau vers : $NetworkPath"
                # Connexion avec $Credential et copie...
            }
        }
        
        'Cloud' {
            if ($PSCmdlet.ShouldProcess($CloudContainer, "Sauvegarde cloud")) {
                Write-Host "☁️ Sauvegarde cloud vers : $CloudContainer"
                # Upload avec $ApiKey...
            }
        }
    }
    
    if ($Compress) {
        Write-Verbose "Compression activée"
    }
}

# Utilisations variées
Backup-Data -SourcePath "C:\Data" -LocalDestination "D:\Backup" -Compress
Backup-Data -SourcePath "C:\Data" -NetworkPath "\\server\share" -Credential $cred
Backup-Data -SourcePath "C:\Data" -CloudContainer "my-bucket" -ApiKey "abc123"
```

### Paramètres appartenant à plusieurs sets

```powershell
function New-Report {
    [CmdletBinding(DefaultParameterSetName = 'Summary')]
    param(
        # Appartient aux deux sets
        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'Summary'
        )]
        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'Detailed'
        )]
        [string]$ReportName,
        
        # Uniquement pour Summary
        [Parameter(ParameterSetName = 'Summary')]
        [switch]$IncludeGraphs,
        
        # Uniquement pour Detailed
        [Parameter(ParameterSetName = 'Detailed')]
        [switch]$IncludeRawData,
        
        [Parameter(ParameterSetName = 'Detailed')]
        [int]$MaxRecords = 1000
    )
    
    Write-Host "Génération du rapport : $ReportName"
    Write-Host "Type : $($PSCmdlet.ParameterSetName)"
    
    if ($PSCmdlet.ParameterSetName -eq 'Summary') {
        Write-Host "Mode résumé $(if($IncludeGraphs){'avec graphiques'})"
    }
    else {
        Write-Host "Mode détaillé - $MaxRecords enregistrements max"
        if ($IncludeRawData) {
            Write-Host "Données brutes incluses"
        }
    }
}
```

### DefaultParameterSetName

Définit le set utilisé quand l'utilisateur ne spécifie aucun paramètre exclusif.

```powershell
function Search-Files {
    [CmdletBinding(DefaultParameterSetName = 'ByName')]
    param(
        [Parameter(ParameterSetName = 'ByName')]
        [string]$Name = "*",
        
        [Parameter(ParameterSetName = 'ByExtension')]
        [string]$Extension,
        
        [Parameter(ParameterSetName = 'ByDate')]
        [datetime]$CreatedAfter,
        
        [string]$Path = "."
    )
    
    Write-Host "Recherche avec le set : $($PSCmdlet.ParameterSetName)"
    
    # Si aucun paramètre spécifique n'est fourni, 'ByName' est utilisé par défaut
}

# Utilise le DefaultParameterSetName 'ByName'
Search-Files -Path "C:\Docs"
```

> [!warning] Pièges courants
> 
> - Oubli de `DefaultParameterSetName` : PowerShell choisira arbitrairement un set
> - Paramètres obligatoires dans tous les sets : rendent la fonction difficile à utiliser
> - Noms de sets peu clairs : utilisez des noms descriptifs comme 'ByName', 'ByDate', etc.

### Validation avec Parameter Sets

```powershell
function Connect-Database {
    [CmdletBinding(DefaultParameterSetName = 'Integrated')]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ServerName,
        
        [Parameter(Mandatory = $true)]
        [string]$DatabaseName,
        
        # Set 1 : Authentification intégrée Windows
        [Parameter(ParameterSetName = 'Integrated')]
        [switch]$UseWindowsAuth,
        
        # Set 2 : Authentification SQL
        [Parameter(ParameterSetName = 'SqlAuth', Mandatory = $true)]
        [string]$Username,
        
        [Parameter(ParameterSetName = 'SqlAuth', Mandatory = $true)]
        [securestring]$Password
    )
    
    $connectionString = "Server=$ServerName;Database=$DatabaseName;"
    
    if ($PSCmdlet.ParameterSetName -eq 'Integrated') {
        $connectionString += "Integrated Security=True;"
        Write-Host "🔐 Connexion avec l'authentification Windows"
    }
    else {
        $connectionString += "User Id=$Username;"
        Write-Host "🔑 Connexion avec l'authentification SQL"
    }
    
    Write-Verbose "Connection String: $connectionString"
    
    # Code de connexion...
}

# Choix de l'authentification
Connect-Database -ServerName "SQL01" -DatabaseName "MyDB" -UseWindowsAuth
Connect-Database -ServerName "SQL01" -DatabaseName "MyDB" -Username "sa" -Password $secPass
```

---

## ⚖️ Fonctions avancées vs fonctions simples

### Tableau comparatif

|Caractéristique|Fonction simple|Fonction avancée|
|---|---|---|
|**Déclaration**|`function Nom { }`|`[CmdletBinding()] function Nom { }`|
|**Paramètres communs**|❌ Non|✅ Oui (-Verbose, -Debug, etc.)|
|**Pipeline avancé**|⚠️ Limité|✅ Complet avec Begin/Process/End|
|**ShouldProcess**|❌ Non|✅ Oui (-WhatIf, -Confirm)|
|**Parameter Sets**|⚠️ Limité|✅ Complet|
|**Gestion d'erreurs**|⚠️ Basique|✅ Avancée|
|**Performance**|🚀 Légèrement plus rapide|🏃 Excellente|
|**Complexité**|📝 Simple|🔧 Plus complexe|
|**Cas d'usage**|Scripts simples, one-liners|Scripts professionnels, modules|

### Exemple 1 : Fonction simple

```powershell
function Get-FileSize {
    param($Path)
    
    (Get-Item $Path).Length
}

# Limitations :
# - Pas de -Verbose
# - Pas de gestion du pipeline
# - Pas de validation avancée
# - Pas de -WhatIf/-Confirm
```

### Exemple 1 : Version avancée

```powershell
function Get-FileSize {
    [CmdletBinding()]
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [Alias('FullName')]
        [ValidateScript({ Test-Path $_ -PathType Leaf })]
        [string]$Path
    )
    
    process {
        Write-Verbose "Analyse de : $Path"
        
        try {
            $file = Get-Item $Path -ErrorAction Stop
            
            [PSCustomObject]@{
                FileName = $file.Name
                SizeBytes = $file.Length
                SizeKB = [math]::Round($file.Length / 1KB, 2)
                SizeMB = [math]::Round($file.Length / 1MB, 2)
                Path = $file.FullName
            }
        }
        catch {
            Write-Error "Impossible de lire le fichier : $_"
        }
    }
}

# Avantages :
# ✓ Support complet du pipeline
# ✓ Validation automatique
# ✓ Gestion d'erreurs robuste
# ✓ Messages détaillés avec -Verbose
# ✓ Sortie structurée

# Utilisation avancée
Get-ChildItem "C:\Windows\System32\*.dll" | Get-FileSize -Verbose | 
    Where-Object SizeMB -gt 1 | 
    Sort-Object SizeMB -Descending |
    Select-Object -First 10
```

### Exemple 2 : Fonction simple pour nettoyage

```powershell
function Remove-OldFiles {
    param($Path, $Days = 30)
    
    Get-ChildItem $Path | 
        Where-Object {$_.LastWriteTime -lt (Get-Date).AddDays(-$Days)} |
        Remove-Item -Force
}

# Problèmes :
# - Pas de confirmation
# - Pas de simulation (-WhatIf)
# - Pas de rapport
# - Risque de suppression accidentelle
```

### Exemple 2 : Version avancée professionnelle

```powershell
function Remove-OldFiles {
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'High'
    )]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript({ Test-Path $_ -PathType Container })]
        [string]$Path,
        
        [Parameter()]
        [ValidateRange(1, 3650)]
        [int]$DaysOld = 30,
        
        [Parameter()]
        [string[]]$Include = @('*'),
        
        [Parameter()]
        [string[]]$Exclude,
        
        [Parameter()]
        [switch]$Recurse
    )
    
    begin {
        Write-Verbose "=== Début du nettoyage ==="
        Write-Verbose "Dossier : $Path"
        Write-Verbose "Fichiers modifiés avant : $((Get-Date).AddDays(-$DaysOld).ToString('yyyy-MM-dd'))"
        
        $deletedCount = 0
        $deletedSize = 0
        $errorCount = 0
    }
    
    process {
        $getParams = @{
            Path = $Path
            File = $true
            ErrorAction = 'SilentlyContinue'
        }
        
        if ($Recurse) { $getParams['Recurse'] = $true }
        if ($Include) { $getParams['Include'] = $Include }
        if ($Exclude) { $getParams['Exclude'] = $Exclude }
        
        $cutoffDate = (Get-Date).AddDays(-$DaysOld)
        $oldFiles = Get-ChildItem @getParams | 
            Where-Object { $_.LastWriteTime -lt $cutoffDate }
        
        Write-Verbose "Fichiers trouvés : $($oldFiles.Count)"
        
        foreach ($file in $oldFiles) {
            $fileSize = $file.Length
            
            if ($PSCmdlet.ShouldProcess(
                $file.FullName,
                "Supprimer (Modifié le : $($file.LastWriteTime.ToString('yyyy-MM-dd')))"
            )) {
                try {
                    Remove-Item -Path $file.FullName -Force -ErrorAction Stop
                    $deletedCount++
                    $deletedSize += $fileSize
                    Write-Verbose "✓ Supprimé : $($file.Name)"
                }
                catch {
                    $errorCount++
                    Write-Error "✗ Échec : $($file.Name) - $_"
                }
            }
        }
    }
    
    end {
        Write-Verbose "=== Résumé du nettoyage ==="
        
        [PSCustomObject]@{
            Path = $Path
            FilesDeleted = $deletedCount
            SpaceFreed = "{0:N2} MB" -f ($deletedSize / 1MB)
            Errors = $errorCount
            Timestamp = Get-Date
        }
    }
}

# Utilisation sécurisée
Remove-OldFiles -Path "C:\Temp" -DaysOld 90 -WhatIf -Verbose
Remove-OldFiles -Path "C:\Logs" -DaysOld 30 -Include "*.log" -Recurse -Confirm
Remove-OldFiles -Path "C:\Backup" -DaysOld 180 -Exclude "*.important" -Verbose
```

### Quand utiliser une fonction simple ?

```powershell
# ✓ Bon usage : Script rapide, usage personnel
function q { exit }

function ll { Get-ChildItem | Format-Table -AutoSize }

function gh { Set-Location $HOME }

# ✓ Bon usage : Wrapper simple sans paramètres complexes
function Update-Help-All {
    Update-Help -Force -ErrorAction SilentlyContinue
}
```

### Quand utiliser une fonction avancée ?

```powershell
# ✓ Toujours pour : Modules partagés
# ✓ Toujours pour : Scripts de production
# ✓ Toujours pour : Opérations critiques/destructives
# ✓ Toujours pour : Fonctions avec pipeline complexe
# ✓ Toujours pour : Scripts nécessitant validation et logging
```

---

## 🎯 Récapitulatif des bonnes pratiques

> [!tip] Checklist pour fonctions avancées professionnelles
> 
> **Structure de base**
> 
> - ✅ Toujours inclure `[CmdletBinding()]`
> - ✅ Utiliser des noms de verbes approuvés (Get-Verb pour la liste)
> - ✅ Documenter avec comment-based help
> 
> **Paramètres**
> 
> - ✅ Utiliser `[Parameter()]` avec attributs appropriés
> - ✅ Définir `Mandatory`, `ValueFromPipeline` quand nécessaire
> - ✅ Ajouter `[ValidateScript()]`, `[ValidateSet()]` pour la validation
> - ✅ Utiliser des Parameter Sets pour logiques mutuellement exclusives
> 
> **Pipeline**
> 
> - ✅ Utiliser le bloc `process` pour traiter chaque objet
> - ✅ Utiliser `begin` pour initialisation unique
> - ✅ Utiliser `end` pour résumé et finalisation
> 
> **Sécurité et confirmation**
> 
> - ✅ Ajouter `SupportsShouldProcess` pour opérations destructives
> - ✅ Définir `ConfirmImpact` approprié (High pour danger élevé)
> - ✅ Tester avec `-WhatIf` avant déploiement
> 
> **Logging et débogage**
> 
> - ✅ Utiliser `Write-Verbose` pour détails d'exécution
> - ✅ Utiliser `Write-Debug` pour points de contrôle
> - ✅ Utiliser `Write-Warning` pour alertes non-bloquantes
> - ✅ Utiliser `Write-Error` pour erreurs avec contexte
> 
> **Gestion d'erreurs**
> 
> - ✅ Utiliser des blocs `try/catch` avec `-ErrorAction Stop`
> - ✅ Fournir des messages d'erreur clairs et actionnables
> - ✅ Logger les erreurs pour audit

### Exemple complet : Fonction avancée modèle

```powershell
function Verb-Noun {
    <#
    .SYNOPSIS
        Brève description de la fonction
    
    .DESCRIPTION
        Description détaillée de ce que fait la fonction
    
    .PARAMETER ParameterName
        Description du paramètre
    
    .EXAMPLE
        Verb-Noun -ParameterName "Value"
        Description de l'exemple
    
    .NOTES
        Auteur: Votre Nom
        Version: 1.0
        Date: 2025-12-10
    #>
    
    [CmdletBinding(
        SupportsShouldProcess = $true,
        ConfirmImpact = 'Medium',
        DefaultParameterSetName = 'Default'
    )]
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0,
            ParameterSetName = 'Default',
            HelpMessage = "Message d'aide pour le paramètre"
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('Alias1', 'Alias2')]
        [string]$ParameterName,
        
        [Parameter()]
        [ValidateSet('Option1', 'Option2', 'Option3')]
        [string]$Choice = 'Option1',
        
        [Parameter()]
        [switch]$Force
    )
    
    begin {
        Write-Verbose "=== Début de Verb-Noun ==="
        Write-Verbose "Parameter Set: $($PSCmdlet.ParameterSetName)"
        
        # Initialisation
        $results = [System.Collections.ArrayList]::new()
        $errorCount = 0
    }
    
    process {
        Write-Verbose "Traitement de : $ParameterName"
        
        try {
            # Validation supplémentaire si nécessaire
            if (-not (Test-SomeCondition $ParameterName)) {
                Write-Warning "Condition non remplie pour $ParameterName"
                return
            }
            
            # Demander confirmation si nécessaire
            if ($PSCmdlet.ShouldProcess($ParameterName, "Action à effectuer")) {
                
                # Logique principale
                $result = Invoke-SomeOperation -Input $ParameterName -Option $Choice
                
                [void]$results.Add($result)
                
                Write-Verbose "✓ Traitement réussi"
            }
        }
        catch {
            $errorCount++
            Write-Error "Erreur lors du traitement de '$ParameterName': $_"
            
            if (-not $Force) {
                throw
            }
        }
    }
    
    end {
        Write-Verbose "=== Fin de Verb-Noun ==="
        Write-Verbose "Éléments traités: $($results.Count)"
        
        if ($errorCount -gt 0) {
            Write-Warning "Terminé avec $errorCount erreur(s)"
        }
        
        # Retourner les résultats
        return $results
    }
}
```

---

## 📊 Tableau de décision rapide

|Besoin|Solution|Exemple|
|---|---|---|
|Traiter chaque élément du pipeline|`process { }` + `ValueFromPipeline`|`1..10 \| ForEach-Object`|
|Initialiser une connexion une fois|`begin { }`|Ouvrir connexion DB|
|Résumé final après traitement|`end { }`|Rapport de statistiques|
|Opération destructive|`SupportsShouldProcess`|Suppression de fichiers|
|Choix exclusifs|Parameter Sets|Authentification Windows/SQL|
|Validation de paramètre|`[ValidateScript()]`|Vérifier existence de fichier|
|Messages de débogage|`Write-Verbose`, `Write-Debug`|Traçage d'exécution|
|Accepter propriété d'objet|`ValueFromPipelineByPropertyName`|Accepter `FullName` de `Get-ChildItem`|

---

## 🚀 Points clés à retenir

> [!info] Résumé essentiel
> 
> **CmdletBinding transforme vos fonctions en cmdlets professionnels** :
> 
> - Ajoute automatiquement -Verbose, -Debug, -ErrorAction, etc.
> - Permet une gestion avancée du pipeline avec Begin/Process/End
> - Active -WhatIf et -Confirm pour les opérations critiques
> - Supporte les Parameter Sets pour logiques alternatives
> 
> **Structure recommandée** :
> 
> ```powershell
> [CmdletBinding(SupportsShouldProcess)]
> param(
>     [Parameter(ValueFromPipeline = $true)]
>     [ValidateNotNull()]
>     $Input
> )
> 
> begin   { # Init }
> process { # Traitement itératif }
> end     { # Finalisation }
> ```
> 
> **Règle d'or** : Si votre fonction sera utilisée par d'autres ou en production, utilisez toujours `[CmdletBinding()]` et les blocs Begin/Process/End appropriés.

---

## 🎨 Patterns courants à mémoriser

### Pattern 1 : Traitement de fichiers avec pipeline

```powershell
function Process-Files {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias('FullName')]
        [string]$Path
    )
    
    process {
        Get-Item $Path | ForEach-Object {
            # Traitement
        }
    }
}

Get-ChildItem *.txt | Process-Files
```

### Pattern 2 : Opération avec confirmation

```powershell
function Do-CriticalAction {
    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param([string]$Target)
    
    if ($PSCmdlet.ShouldProcess($Target, "Action critique")) {
        # Action
    }
}
```

### Pattern 3 : Fonction avec rapport final

```powershell
function Process-Items {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline = $true)]
        $Item
    )
    
    begin { $count = 0; $errors = 0 }
    
    process {
        try { $count++; # Traitement }
        catch { $errors++ }
    }
    
    end {
        [PSCustomObject]@{
            Processed = $count
            Errors = $errors
        }
    }
}
```

---

**🎓 Vous maîtrisez maintenant les fonctions avancées PowerShell !**

Les concepts couverts dans ce cours vous permettent de créer des fonctions professionnelles, robustes et réutilisables qui s'intègrent parfaitement dans l'écosystème PowerShell. Utilisez ces techniques pour écrire du code de qualité production.