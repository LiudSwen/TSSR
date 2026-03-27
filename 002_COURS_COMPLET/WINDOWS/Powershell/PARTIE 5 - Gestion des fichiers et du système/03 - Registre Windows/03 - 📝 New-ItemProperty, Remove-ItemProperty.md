

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

## Introduction

Les cmdlets **New-ItemProperty** et **Remove-ItemProperty** permettent de manipuler les **valeurs** (propriétés) au sein des clés de registre. Contrairement à `New-Item` et `Remove-Item` qui gèrent les clés elles-mêmes, ces cmdlets travaillent sur le contenu des clés.

> [!info] Rappel terminologique
> 
> - **Clé de registre** = Conteneur (équivalent d'un dossier)
> - **Valeur/Propriété** = Donnée stockée dans une clé (équivalent d'un fichier)
> - Une clé peut contenir plusieurs valeurs

---

## New-ItemProperty - Créer des valeurs

### Syntaxe de base

La cmdlet **New-ItemProperty** permet de créer une nouvelle valeur dans une clé de registre existante.

```powershell
New-ItemProperty -Path <Chemin> -Name <Nom> -Value <Valeur> -PropertyType <Type>
```

**Paramètres essentiels :**

|Paramètre|Description|Obligatoire|
|---|---|---|
|`-Path`|Chemin de la clé où créer la valeur|Oui|
|`-Name`|Nom de la nouvelle valeur|Oui|
|`-Value`|Contenu/données de la valeur|Oui|
|`-PropertyType`|Type de données (String, DWord, etc.)|Recommandé|
|`-Force`|Écrase si la valeur existe déjà|Non|

### Les types de propriétés

Le paramètre `-PropertyType` définit le format de stockage de la donnée. Voici les types disponibles :

|Type|Description|Exemple d'utilisation|
|---|---|---|
|**String**|Texte simple (REG_SZ)|Chemins, noms, descriptions|
|**ExpandString**|Texte avec variables d'environnement (REG_EXPAND_SZ)|`%SystemRoot%\System32`|
|**Binary**|Données binaires brutes (REG_BINARY)|Configurations complexes|
|**DWord**|Entier 32 bits (REG_DWORD)|Flags, options activées/désactivées (0 ou 1)|
|**QWord**|Entier 64 bits (REG_QWORD)|Grandes valeurs numériques|
|**MultiString**|Tableau de chaînes (REG_MULTI_SZ)|Listes d'éléments|

> [!tip] Choix du type
> 
> - **DWord** est le type le plus utilisé pour les paramètres booléens (0 = désactivé, 1 = activé)
> - **String** pour tout texte fixe
> - **ExpandString** quand vous avez besoin de variables d'environnement qui seront interprétées

### Exemples pratiques

**Créer une valeur de type String :**

```powershell
# Créer une valeur texte simple
New-ItemProperty -Path "HKCU:\Software\MonApp" `
                 -Name "Version" `
                 -Value "1.0.5" `
                 -PropertyType String
```

**Créer une valeur DWord pour activer une option :**

```powershell
# Désactiver les notifications de mise à jour Windows (exemple)
New-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" `
                 -Name "NoAutoUpdate" `
                 -Value 1 `
                 -PropertyType DWord
```

**Créer une valeur ExpandString avec variables d'environnement :**

```powershell
# Chemin qui sera interprété dynamiquement
New-ItemProperty -Path "HKCU:\Software\MonApp" `
                 -Name "InstallPath" `
                 -Value "%ProgramFiles%\MonApplication" `
                 -PropertyType ExpandString
```

**Créer une valeur MultiString (tableau) :**

```powershell
# Liste de serveurs
New-ItemProperty -Path "HKCU:\Software\MonApp" `
                 -Name "Servers" `
                 -Value @("server1.domain.com", "server2.domain.com", "server3.domain.com") `
                 -PropertyType MultiString
```

**Créer une valeur Binary :**

```powershell
# Données binaires (exemple : configuration encodée)
$binaryData = [byte[]](0x01, 0x02, 0x03, 0x04)
New-ItemProperty -Path "HKCU:\Software\MonApp" `
                 -Name "Config" `
                 -Value $binaryData `
                 -PropertyType Binary
```

### Option -Force

Le paramètre `-Force` permet d'écraser une valeur existante sans erreur.

```powershell
# Sans -Force : génère une erreur si "Timeout" existe déjà
New-ItemProperty -Path "HKCU:\Software\MonApp" `
                 -Name "Timeout" `
                 -Value 30 `
                 -PropertyType DWord

# Avec -Force : écrase la valeur existante
New-ItemProperty -Path "HKCU:\Software\MonApp" `
                 -Name "Timeout" `
                 -Value 60 `
                 -PropertyType DWord `
                 -Force
```

> [!warning] Attention avec -Force `-Force` écrase silencieusement les valeurs existantes. Utilisez-le avec précaution, surtout sur des clés système. Privilégiez `Set-ItemProperty` pour modifier une valeur existante de manière explicite.

---

## Remove-ItemProperty - Supprimer des valeurs

### Syntaxe et utilisation

La cmdlet **Remove-ItemProperty** supprime une valeur spécifique d'une clé de registre (la clé elle-même reste intacte).

```powershell
Remove-ItemProperty -Path <Chemin> -Name <NomValeur>
```

**Exemple simple :**

```powershell
# Supprimer la valeur "Version" de la clé MonApp
Remove-ItemProperty -Path "HKCU:\Software\MonApp" -Name "Version"
```

**Supprimer plusieurs valeurs en une fois :**

```powershell
# Supprimer plusieurs valeurs d'une même clé
"Timeout", "MaxConnections", "RetryCount" | ForEach-Object {
    Remove-ItemProperty -Path "HKCU:\Software\MonApp" -Name $_ -ErrorAction SilentlyContinue
}
```

### Gestion des confirmations

Par défaut, `Remove-ItemProperty` ne demande pas de confirmation, ce qui peut être risqué.

**Demander confirmation avant suppression :**

```powershell
# Avec -Confirm : demande confirmation pour chaque suppression
Remove-ItemProperty -Path "HKCU:\Software\MonApp" -Name "ImportantSetting" -Confirm

# Avec -WhatIf : simule l'action sans l'exécuter (test)
Remove-ItemProperty -Path "HKCU:\Software\MonApp" -Name "ImportantSetting" -WhatIf
```

> [!tip] Bonne pratique Utilisez toujours `-WhatIf` en premier pour vérifier ce qui sera supprimé, puis exécutez la commande réelle. C'est particulièrement important pour les clés système.

**Gestion des erreurs si la valeur n'existe pas :**

```powershell
# Éviter l'erreur si la valeur n'existe pas
Remove-ItemProperty -Path "HKCU:\Software\MonApp" `
                    -Name "MaybeExists" `
                    -ErrorAction SilentlyContinue

# Vérifier l'existence avant de supprimer
if (Get-ItemProperty -Path "HKCU:\Software\MonApp" -Name "ToDelete" -ErrorAction SilentlyContinue) {
    Remove-ItemProperty -Path "HKCU:\Software\MonApp" -Name "ToDelete"
    Write-Host "Valeur supprimée avec succès"
} else {
    Write-Host "La valeur n'existe pas"
}
```

---

## Gestion des clés avec New-Item et Remove-Item

Bien que ce cours se concentre sur les **propriétés**, il est important de savoir que les **clés** elles-mêmes se gèrent avec `New-Item` et `Remove-Item`.

**Créer une clé de registre :**

```powershell
# Créer une nouvelle clé (conteneur)
New-Item -Path "HKCU:\Software\MonApp\Parametres"

# Créer une clé avec force (pas d'erreur si elle existe)
New-Item -Path "HKCU:\Software\MonApp\Logs" -Force
```

**Supprimer une clé et tout son contenu :**

```powershell
# Supprimer une clé (attention : supprime aussi toutes les valeurs qu'elle contient)
Remove-Item -Path "HKCU:\Software\MonApp\TempSettings" -Recurse

# -Recurse supprime aussi les sous-clés
# Sans -Recurse, une erreur survient si la clé contient des sous-clés
```

> [!warning] Danger de Remove-Item `Remove-Item` avec `-Recurse` supprime **tout** : la clé, ses valeurs, et toutes ses sous-clés. Vérifiez toujours avec `-WhatIf` avant d'exécuter.

**Workflow complet : Créer une clé et y ajouter des valeurs :**

```powershell
# 1. Créer la clé principale
New-Item -Path "HKCU:\Software\MonAppPerso" -Force

# 2. Créer une sous-clé
New-Item -Path "HKCU:\Software\MonAppPerso\Config" -Force

# 3. Ajouter des valeurs dans la clé
New-ItemProperty -Path "HKCU:\Software\MonAppPerso\Config" `
                 -Name "Mode" `
                 -Value "Production" `
                 -PropertyType String

New-ItemProperty -Path "HKCU:\Software\MonAppPerso\Config" `
                 -Name "LogLevel" `
                 -Value 2 `
                 -PropertyType DWord
```

---

## Précautions et sauvegardes

Avant toute modification du registre, il est **crucial** de créer des sauvegardes, surtout pour les clés système.

### Export de clés de registre

**Exporter une clé complète (avec toutes ses valeurs) :**

```powershell
# Export en fichier .reg (format standard Windows)
reg export "HKCU\Software\MonApp" "C:\Backups\MonApp_backup.reg"

# Export avec PowerShell (format personnalisé)
Get-ItemProperty -Path "HKCU:\Software\MonApp" | 
    Export-Clixml -Path "C:\Backups\MonApp_backup.xml"
```

**Exporter une branche entière avec sous-clés :**

```powershell
# Le /y force l'écrasement si le fichier existe
reg export "HKLM\SOFTWARE\Policies" "C:\Backups\Policies_backup.reg" /y
```

> [!example] Exemple de script de sauvegarde automatique
> 
> ```powershell
> # Script de backup avant modification
> $backupPath = "C:\RegistryBackups\$(Get-Date -Format 'yyyyMMdd_HHmmss')"
> New-Item -Path $backupPath -ItemType Directory -Force
> 
> # Exporter plusieurs clés importantes
> reg export "HKCU\Software\MonApp" "$backupPath\MonApp.reg"
> reg export "HKLM\SOFTWARE\MonEntreprise" "$backupPath\MonEntreprise.reg"
> 
> Write-Host "Sauvegarde créée dans : $backupPath" -ForegroundColor Green
> ```

### Import de clés de registre

**Restaurer une clé depuis un fichier .reg :**

```powershell
# Import d'un fichier .reg
reg import "C:\Backups\MonApp_backup.reg"

# Avec confirmation
$confirmation = Read-Host "Êtes-vous sûr de vouloir restaurer ? (O/N)"
if ($confirmation -eq 'O') {
    reg import "C:\Backups\MonApp_backup.reg"
    Write-Host "Restauration effectuée" -ForegroundColor Green
}
```

**Restaurer depuis un XML PowerShell :**

```powershell
# Importer depuis Export-Clixml
$backup = Import-Clixml -Path "C:\Backups\MonApp_backup.xml"

# Recréer les valeurs
foreach ($property in $backup.PSObject.Properties) {
    if ($property.Name -notin @('PSPath', 'PSParentPath', 'PSChildName', 'PSDrive', 'PSProvider')) {
        Set-ItemProperty -Path "HKCU:\Software\MonApp" `
                        -Name $property.Name `
                        -Value $property.Value
    }
}
```

> [!warning] Prudence avec HKLM Les modifications dans `HKEY_LOCAL_MACHINE` (HKLM) affectent **tous les utilisateurs** et nécessitent des droits administrateur. Testez toujours d'abord dans `HKEY_CURRENT_USER` (HKCU) quand c'est possible.

---

## Cas d'usage pratiques

### Paramètres système

**Désactiver le Centre de notifications Windows :**

```powershell
# Créer la clé si elle n'existe pas
New-Item -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Force

# Désactiver les notifications
New-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" `
                 -Name "DisableNotificationCenter" `
                 -Value 1 `
                 -PropertyType DWord `
                 -Force
```

**Modifier le délai d'extinction de l'écran :**

```powershell
# Délai en secondes (0 = jamais)
New-ItemProperty -Path "HKCU:\Control Panel\PowerCfg\GlobalPowerPolicy" `
                 -Name "Policies" `
                 -Value 1800 `
                 -PropertyType DWord `
                 -Force
```

### Configuration applicative

**Configurer les paramètres d'une application personnalisée :**

```powershell
# Créer la structure de clés
$appPath = "HKCU:\Software\MaCompagnie\MonApplication"
New-Item -Path $appPath -Force
New-Item -Path "$appPath\Database" -Force
New-Item -Path "$appPath\UI" -Force

# Configuration de la base de données
New-ItemProperty -Path "$appPath\Database" `
                 -Name "ServerAddress" `
                 -Value "sql.monentreprise.local" `
                 -PropertyType String -Force

New-ItemProperty -Path "$appPath\Database" `
                 -Name "Port" `
                 -Value 1433 `
                 -PropertyType DWord -Force

New-ItemProperty -Path "$appPath\Database" `
                 -Name "Timeout" `
                 -Value 30 `
                 -PropertyType DWord -Force

# Configuration de l'interface
New-ItemProperty -Path "$appPath\UI" `
                 -Name "Theme" `
                 -Value "Dark" `
                 -PropertyType String -Force

New-ItemProperty -Path "$appPath\UI" `
                 -Name "Language" `
                 -Value "fr-FR" `
                 -PropertyType String -Force
```

**Déploiement de paramètres sur plusieurs machines :**

```powershell
# Script de déploiement de configuration
function Deploy-AppSettings {
    param(
        [string]$Environment = "Production"
    )
    
    $basePath = "HKCU:\Software\MaCompagnie\MonApp"
    
    # Créer la structure
    New-Item -Path $basePath -Force | Out-Null
    
    # Paramètres selon l'environnement
    switch ($Environment) {
        "Production" {
            New-ItemProperty -Path $basePath -Name "ApiUrl" `
                -Value "https://api.prod.monentreprise.com" `
                -PropertyType String -Force
            New-ItemProperty -Path $basePath -Name "LogLevel" `
                -Value 1 -PropertyType DWord -Force
        }
        "Test" {
            New-ItemProperty -Path $basePath -Name "ApiUrl" `
                -Value "https://api.test.monentreprise.com" `
                -PropertyType String -Force
            New-ItemProperty -Path $basePath -Name "LogLevel" `
                -Value 3 -PropertyType DWord -Force
        }
        "Dev" {
            New-ItemProperty -Path $basePath -Name "ApiUrl" `
                -Value "http://localhost:5000" `
                -PropertyType String -Force
            New-ItemProperty -Path $basePath -Name "LogLevel" `
                -Value 4 -PropertyType DWord -Force
        }
    }
    
    Write-Host "Configuration $Environment déployée avec succès" -ForegroundColor Green
}

# Utilisation
Deploy-AppSettings -Environment "Production"
```

### Nettoyage et maintenance

**Supprimer les traces d'une application désinstallée :**

```powershell
# Script de nettoyage complet
$appName = "AncienneApp"
$paths = @(
    "HKCU:\Software\$appName",
    "HKLM:\SOFTWARE\$appName",
    "HKLM:\SOFTWARE\WOW6432Node\$appName"  # Pour apps 32-bit sur Windows 64-bit
)

foreach ($path in $paths) {
    if (Test-Path $path) {
        Write-Host "Suppression de : $path" -ForegroundColor Yellow
        Remove-Item -Path $path -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "Nettoyage terminé" -ForegroundColor Green
```

---

## Pièges courants et bonnes pratiques

### ❌ Pièges à éviter

> [!warning] Piège n°1 : Oublier le PropertyType
> 
> ```powershell
> # ❌ Mauvais : le type sera String par défaut
> New-ItemProperty -Path "HKCU:\Software\MonApp" -Name "Port" -Value 8080
> 
> # ✅ Bon : type explicite DWord pour un nombre
> New-ItemProperty -Path "HKCU:\Software\MonApp" -Name "Port" -Value 8080 -PropertyType DWord
> ```

> [!warning] Piège n°2 : Confusion entre clé et valeur
> 
> ```powershell
> # ❌ Mauvais : Remove-Item supprime la CLÉ entière
> Remove-Item -Path "HKCU:\Software\MonApp\Config"
> 
> # ✅ Bon : Remove-ItemProperty supprime juste une VALEUR
> Remove-ItemProperty -Path "HKCU:\Software\MonApp" -Name "Config"
> ```

> [!warning] Piège n°3 : Ne pas vérifier l'existence de la clé parente
> 
> ```powershell
> # ❌ Mauvais : erreur si la clé parente n'existe pas
> New-ItemProperty -Path "HKCU:\Software\AppInexistante\Config" -Name "Value" -Value 1
> 
> # ✅ Bon : créer la structure complète
> $path = "HKCU:\Software\AppInexistante\Config"
> if (-not (Test-Path $path)) {
>     New-Item -Path $path -Force
> }
> New-ItemProperty -Path $path -Name "Value" -Value 1 -PropertyType DWord
> ```

> [!warning] Piège n°4 : Modifications sans backup
> 
> ```powershell
> # ❌ Dangereux : modification directe sans sauvegarde
> Remove-Item -Path "HKLM:\SOFTWARE\Important" -Recurse -Force
> 
> # ✅ Sécurisé : toujours sauvegarder avant
> reg export "HKLM\SOFTWARE\Important" "C:\Backup\Important.reg"
> # Puis faire la modification
> Remove-Item -Path "HKLM:\SOFTWARE\Important" -Recurse -Force
> ```

### ✅ Bonnes pratiques

> [!tip] 1. Toujours tester avec -WhatIf
> 
> ```powershell
> # Simuler avant d'exécuter
> Remove-ItemProperty -Path "HKCU:\Software\MonApp" -Name "Critical" -WhatIf
> 
> # Si tout semble correct, exécuter réellement
> Remove-ItemProperty -Path "HKCU:\Software\MonApp" -Name "Critical"
> ```

> [!tip] 2. Utiliser des fonctions réutilisables
> 
> ```powershell
> function Set-RegistryValue {
>     param(
>         [string]$Path,
>         [string]$Name,
>         [object]$Value,
>         [string]$Type = "String"
>     )
>     
>     # Créer le chemin si nécessaire
>     if (-not (Test-Path $Path)) {
>         New-Item -Path $Path -Force | Out-Null
>     }
>     
>     # Créer ou modifier la valeur
>     New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $Type -Force | Out-Null
>     Write-Host "✓ $Name défini sur $Value" -ForegroundColor Green
> }
> 
> # Utilisation simple
> Set-RegistryValue -Path "HKCU:\Software\MonApp" -Name "Timeout" -Value 60 -Type DWord
> ```

> [!tip] 3. Logger les modifications
> 
> ```powershell
> function Set-RegistryWithLog {
>     param($Path, $Name, $Value, $Type)
>     
>     $logFile = "C:\Logs\RegistryChanges.log"
>     $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
>     
>     # Sauvegarder la valeur actuelle si elle existe
>     $oldValue = (Get-ItemProperty -Path $Path -Name $Name -ErrorAction SilentlyContinue).$Name
>     
>     # Appliquer la modification
>     New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType $Type -Force
>     
>     # Logger
>     "$timestamp | $Path | $Name | Ancienne: $oldValue | Nouvelle: $Value" | 
>         Add-Content -Path $logFile
> }
> ```

> [!tip] 4. Gérer les droits administrateur
> 
> ```powershell
> function Test-Admin {
>     $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
>     $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
>     return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
> }
> 
> # Vérifier avant de modifier HKLM
> if (-not (Test-Admin)) {
>     Write-Host "Ce script nécessite des droits administrateur pour modifier HKLM" -ForegroundColor Red
>     exit
> }
> 
> # Maintenant on peut modifier HKLM en toute sécurité
> New-ItemProperty -Path "HKLM:\SOFTWARE\MonApp" -Name "GlobalSetting" -Value 1 -PropertyType DWord
> ```

> [!tip] 5. Valider les données avant insertion
> 
> ```powershell
> function Set-ValidatedRegistryValue {
>     param(
>         [string]$Path,
>         [string]$Name,
>         [int]$Value,
>         [int]$Min,
>         [int]$Max
>     )
>     
>     # Validation
>     if ($Value -lt $Min -or $Value -gt $Max) {
>         Write-Error "La valeur doit être entre $Min et $Max"
>         return
>     }
>     
>     # Insertion sécurisée
>     New-ItemProperty -Path $Path -Name $Name -Value $Value -PropertyType DWord -Force
>     Write-Host "✓ Valeur $Value validée et enregistrée" -ForegroundColor Green
> }
> 
> # Exemple : Port entre 1024 et 65535
> Set-ValidatedRegistryValue -Path "HKCU:\Software\MonApp" `
>                            -Name "Port" `
>                            -Value 8080 `
>                            -Min 1024 `
>                            -Max 65535
> ```

---

## 🎯 Points clés à retenir

- **New-ItemProperty** crée des **valeurs** dans des clés existantes
- **Remove-ItemProperty** supprime des **valeurs** sans toucher aux clés
- Toujours spécifier `-PropertyType` pour des données cohérentes
- **DWord** pour les nombres et booléens, **String** pour le texte
- `-Force` écrase sans erreur, mais utilisez-le avec précaution
- **Sauvegarder** avant toute modification importante avec `reg export`
- Utiliser `-WhatIf` et `-Confirm` pour les opérations sensibles
- `New-Item` et `Remove-Item` gèrent les **clés**, pas les valeurs
- Toujours tester dans HKCU avant de toucher à HKLM
- Logger vos modifications pour traçabilité et débogage