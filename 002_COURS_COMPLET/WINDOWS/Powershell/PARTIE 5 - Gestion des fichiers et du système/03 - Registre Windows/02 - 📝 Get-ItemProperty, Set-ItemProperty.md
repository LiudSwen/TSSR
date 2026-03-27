
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

Les cmdlets `Get-ItemProperty` et `Set-ItemProperty` permettent de manipuler les **valeurs** (propriétés) contenues dans les clés du registre Windows. Contrairement aux cmdlets qui manipulent les clés elles-mêmes, ces commandes se concentrent sur le contenu des clés.

> [!info] Distinction importante
> 
> - **Clé de registre** = Container (dossier)
> - **Propriété/Valeur** = Donnée stockée dans la clé
> 
> `Get-ItemProperty` et `Set-ItemProperty` travaillent sur les **propriétés**, pas sur les clés.

---

## Get-ItemProperty - Lecture des valeurs

### Concepts fondamentaux

`Get-ItemProperty` permet de **lire** les valeurs stockées dans une clé de registre. C'est l'équivalent PowerShell de l'action "consulter" dans l'éditeur de registre (regedit.exe).

**Pourquoi l'utiliser ?**

- Récupérer des configurations système
- Vérifier des paramètres d'applications
- Auditer des valeurs de registre
- Automatiser la lecture de multiples valeurs

**Quand l'utiliser ?**

- Pour diagnostiquer un problème système
- Avant de modifier une valeur (vérification)
- Pour documenter une configuration
- Dans des scripts de monitoring

---

### Syntaxe et paramètres

```powershell
Get-ItemProperty [-Path] <String> [[-Name] <String>] [<CommonParameters>]
```

#### Paramètres principaux

|Paramètre|Description|Obligatoire|Exemple|
|---|---|---|---|
|`-Path`|Chemin de la clé à lire|✅ Oui|`HKLM:\SOFTWARE\Microsoft`|
|`-Name`|Nom de la propriété spécifique|❌ Non|`Version`|

> [!tip] Astuce - Path positionnel Le paramètre `-Path` est positionnel, vous pouvez l'omettre :
> 
> ```powershell
> Get-ItemProperty HKLM:\SOFTWARE\Microsoft -Name Version
> ```

---

### Exemples pratiques

#### 1️⃣ Lire toutes les propriétés d'une clé

```powershell
# Récupère TOUTES les propriétés de la clé
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion"

# Affiche : ProgramFilesDir, CommonFilesDir, DevicePath, etc.
```

> [!example] Résultat typique
> 
> ```
> ProgramFilesDir      : C:\Program Files
> CommonFilesDir       : C:\Program Files\Common Files
> ProgramFilesDir (x86): C:\Program Files (x86)
> DevicePath           : C:\WINDOWS\inf
> PSPath               : Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\...
> PSParentPath         : Microsoft.PowerShell.Core\Registry::HKEY_LOCAL_MACHINE\...
> PSChildName          : CurrentVersion
> PSDrive              : HKLM
> PSProvider           : Microsoft.PowerShell.Core\Registry
> ```

#### 2️⃣ Lire une propriété spécifique

```powershell
# Lecture ciblée avec -Name
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion" -Name "ProgramFilesDir"

# Retourne uniquement la valeur de ProgramFilesDir
```

> [!warning] Attention aux propriétés PS* PowerShell ajoute automatiquement des propriétés comme `PSPath`, `PSChildName`, etc. Ces propriétés ne sont **pas** dans le registre, mais ajoutées par PowerShell pour la navigation.

#### 3️⃣ Filtrer les résultats

```powershell
# Récupérer seulement certaines propriétés
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion" | 
    Select-Object ProgramFilesDir, CommonFilesDir

# Exclure les propriétés PowerShell
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion" | 
    Select-Object -Property * -ExcludeProperty PS*
```

#### 4️⃣ Lecture dans HKCU (utilisateur courant)

```powershell
# Configuration personnelle de l'utilisateur
Get-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "Wallpaper"

# Retourne le chemin du fond d'écran actuel
```

#### 5️⃣ Gestion des erreurs

```powershell
# Si la clé ou la propriété n'existe pas
Get-ItemProperty -Path "HKLM:\SOFTWARE\MaClefInexistante" -ErrorAction SilentlyContinue

# Ou avec Try/Catch
try {
    $value = Get-ItemProperty -Path "HKLM:\SOFTWARE\Test" -Name "Version" -ErrorAction Stop
    Write-Host "Version trouvée : $($value.Version)"
} catch {
    Write-Host "Propriété non trouvée"
}
```

---

### Types de valeurs retournées

`Get-ItemProperty` retourne un objet PowerShell avec les propriétés sous forme de **membres** de l'objet.

```powershell
# Stockage dans une variable
$props = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion"

# Accès aux valeurs
$props.ProgramFilesDir          # C:\Program Files
$props.'ProgramFilesDir (x86)'  # Guillemets si espaces ou caractères spéciaux
```

|Type de valeur (Registre)|Type PowerShell|Exemple|
|---|---|---|
|REG_SZ (chaîne)|`[String]`|`"C:\Windows"`|
|REG_DWORD (32-bit)|`[Int32]`|`1`|
|REG_QWORD (64-bit)|`[Int64]`|`1234567890`|
|REG_BINARY|`[Byte[]]`|`@(01, 02, 03)`|
|REG_MULTI_SZ|`[String[]]`|`@("ligne1", "ligne2")`|
|REG_EXPAND_SZ|`[String]`|`"%SystemRoot%\System32"`|

> [!info] REG_EXPAND_SZ Les variables d'environnement sont **automatiquement développées** par PowerShell lors de la lecture.

---

## Set-ItemProperty - Modification des valeurs

### Concepts fondamentaux

`Set-ItemProperty` permet de **modifier** les valeurs existantes dans une clé de registre. Cette cmdlet ne crée pas de nouvelles propriétés (utilisez `New-ItemProperty` pour cela).

**Pourquoi l'utiliser ?**

- Modifier des paramètres système
- Appliquer des configurations
- Automatiser des changements de registre
- Corriger des valeurs incorrectes

**Quand l'utiliser ?**

- Configuration automatisée de postes
- Scripts de déploiement
- Résolution de problèmes nécessitant une modification
- Personnalisation de l'environnement

> [!warning] Prérequis - Propriété existante `Set-ItemProperty` modifie des propriétés **existantes**. Si la propriété n'existe pas, utilisez `New-ItemProperty`.

---

### Syntaxe et paramètres

```powershell
Set-ItemProperty [-Path] <String> [-Name] <String> [-Value] <Object> [-Type <RegistryValueKind>] [-Force] [<CommonParameters>]
```

#### Paramètres principaux

|Paramètre|Description|Obligatoire|Exemple|
|---|---|---|---|
|`-Path`|Chemin de la clé contenant la propriété|✅ Oui|`HKLM:\SOFTWARE\MyApp`|
|`-Name`|Nom de la propriété à modifier|✅ Oui|`Version`|
|`-Value`|Nouvelle valeur à appliquer|✅ Oui|`"2.0"` ou `1`|
|`-Type`|Type de donnée (si conversion nécessaire)|❌ Non|`String`, `DWord`|
|`-Force`|Forcer la modification sans confirmation|❌ Non|`-Force`|

---

### Types de données

Lors de la modification d'une valeur, il est crucial de respecter le **type** approprié.

|Type (-Type)|Description|Exemple de valeur|
|---|---|---|
|`String`|Chaîne de caractères (REG_SZ)|`"Texte"`|
|`ExpandString`|Chaîne avec variables d'environnement (REG_EXPAND_SZ)|`"%TEMP%\log"`|
|`Binary`|Données binaires (REG_BINARY)|`[byte[]](0x01,0x02)`|
|`DWord`|Entier 32-bit (REG_DWORD)|`1`, `0`, `255`|
|`QWord`|Entier 64-bit (REG_QWORD)|`1234567890`|
|`MultiString`|Tableau de chaînes (REG_MULTI_SZ)|`@("ligne1","ligne2")`|

> [!tip] Conversion automatique PowerShell tente de convertir automatiquement le type si vous ne spécifiez pas `-Type`. Mais pour plus de sécurité, spécifiez-le explicitement.

---

### Exemples pratiques

#### 1️⃣ Modification simple d'une chaîne

```powershell
# Modifier une valeur de type String
Set-ItemProperty -Path "HKCU:\SOFTWARE\MonApplication" -Name "Version" -Value "2.5"

# Vérification
Get-ItemProperty -Path "HKCU:\SOFTWARE\MonApplication" -Name "Version"
```

#### 2️⃣ Modification d'un DWORD

```powershell
# Activer/désactiver une option (0 = désactivé, 1 = activé)
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "ScreenSaveActive" -Value 1 -Type DWord

# Vérification du type
(Get-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "ScreenSaveActive").ScreenSaveActive
```

> [!example] Cas d'usage : Désactiver l'écran de veille
> 
> ```powershell
> Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "ScreenSaveActive" -Value 0 -Type DWord
> ```

#### 3️⃣ Modification dans HKLM (droits admin requis)

```powershell
# Nécessite une élévation de privilèges
Set-ItemProperty -Path "HKLM:\SOFTWARE\MyCompany\MyApp" -Name "LicenseKey" -Value "ABC-123-XYZ" -Force

# Sans -Force, peut demander confirmation
```

> [!warning] Droits administrateur obligatoires Toute modification dans `HKLM:\` nécessite d'exécuter PowerShell **en tant qu'administrateur**.

#### 4️⃣ Modification de données binaires

```powershell
# Créer un tableau de bytes
$binaryData = [byte[]](0x01, 0x02, 0x03, 0xFF)

# Appliquer la valeur binaire
Set-ItemProperty -Path "HKCU:\SOFTWARE\Test" -Name "BinaryValue" -Value $binaryData -Type Binary
```

#### 5️⃣ Modification avec vérification préalable

```powershell
# Lire la valeur actuelle
$currentValue = (Get-ItemProperty -Path "HKCU:\SOFTWARE\MyApp" -Name "Setting").Setting

if ($currentValue -ne "Desired") {
    # Modifier seulement si différent
    Set-ItemProperty -Path "HKCU:\SOFTWARE\MyApp" -Name "Setting" -Value "Desired"
    Write-Host "Valeur modifiée : $currentValue -> Desired"
} else {
    Write-Host "Valeur déjà correcte"
}
```

#### 6️⃣ Modification de plusieurs propriétés

```powershell
# Définir plusieurs valeurs dans la même clé
$path = "HKCU:\SOFTWARE\MyApp"

Set-ItemProperty -Path $path -Name "Version" -Value "3.0"
Set-ItemProperty -Path $path -Name "LastUpdate" -Value (Get-Date -Format "yyyy-MM-dd")
Set-ItemProperty -Path $path -Name "AutoStart" -Value 1 -Type DWord
```

#### 7️⃣ Utilisation de -Force

```powershell
# Forcer la modification sans confirmation
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\MyApp" -Name "Enabled" -Value 1 -Force

# Utile dans les scripts automatisés pour éviter les prompts
```

---

## Comparaison Get vs Set

|Aspect|Get-ItemProperty|Set-ItemProperty|
|---|---|---|
|**Action**|📖 Lecture seule|✏️ Modification|
|**Droits requis (HKLM)**|👤 Utilisateur standard|🔑 Administrateur|
|**Erreur si inexistant**|❌ Erreur|❌ Erreur (utiliser New-ItemProperty)|
|**Retour**|Objet avec toutes les propriétés|Aucun retour (ou erreur)|
|**Paramètre -Name**|Optionnel (toutes si omis)|Obligatoire|
|**Impact système**|Aucun|Modifie le registre|

---

## Bonnes pratiques

### ✅ À faire

1. **Toujours vérifier avant de modifier**
    
    ```powershell
    $current = Get-ItemProperty -Path $path -Name $name
    if ($current.$name -ne $newValue) {
        Set-ItemProperty -Path $path -Name $name -Value $newValue
    }
    ```
    
2. **Utiliser -ErrorAction pour gérer les erreurs**
    
    ```powershell
    Get-ItemProperty -Path $path -Name $name -ErrorAction SilentlyContinue
    ```
    
3. **Spécifier explicitement le type de données**
    
    ```powershell
    Set-ItemProperty -Path $path -Name "Count" -Value 5 -Type DWord
    ```
    
4. **Sauvegarder avant modification**
    
    ```powershell
    # Export de la clé avant modification
    $backup = Get-ItemProperty -Path $path
    ```
    
5. **Tester en HKCU avant HKLM**
    
    ```powershell
    # Test en HKCU d'abord (pas d'admin requis)
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Test" -Name "TestValue" -Value "OK"
    ```
    

### ❌ À éviter

1. **Ne jamais modifier HKLM sans sauvegarde**
    
    - Risque de rendre le système instable
2. **Ne pas oublier les guillemets pour les chemins avec espaces**
    
    ```powershell
    # ❌ Incorrect
    Get-ItemProperty -Path HKCU:\Control Panel\Desktop
    
    # ✅ Correct
    Get-ItemProperty -Path "HKCU:\Control Panel\Desktop"
    ```
    
3. **Ne pas confondre les types de données**
    
    - Un DWORD doit recevoir un entier, pas une chaîne
4. **Ne pas utiliser Set-ItemProperty sur une propriété inexistante**
    
    - Utilisez `New-ItemProperty` à la place

---

## Pièges courants

### 🔴 Piège 1 : Propriété inexistante

```powershell
# ❌ Erreur : la propriété n'existe pas
Set-ItemProperty -Path "HKCU:\SOFTWARE\MyApp" -Name "NewSetting" -Value "Test"

# ✅ Solution : vérifier ou créer d'abord
if (!(Get-ItemProperty -Path "HKCU:\SOFTWARE\MyApp" -Name "NewSetting" -ErrorAction SilentlyContinue)) {
    New-ItemProperty -Path "HKCU:\SOFTWARE\MyApp" -Name "NewSetting" -Value "Test" -PropertyType String
}
```

### 🔴 Piège 2 : Chemin avec espaces non quoté

```powershell
# ❌ Erreur de syntaxe
Get-ItemProperty -Path HKCU:\Control Panel\Desktop

# ✅ Correct
Get-ItemProperty -Path "HKCU:\Control Panel\Desktop"
```

### 🔴 Piège 3 : Confusion entre clé et propriété

```powershell
# ❌ Tente de lire une CLÉ comme une propriété
Get-ItemProperty -Path "HKLM:\SOFTWARE" -Name "Microsoft"  # Erreur !

# ✅ Lire les propriétés d'une clé
Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion"
```

### 🔴 Piège 4 : Type de données incorrect

```powershell
# ❌ Erreur : tente d'affecter une chaîne à un DWORD
Set-ItemProperty -Path $path -Name "Count" -Value "cinq" -Type DWord  # Erreur de conversion

# ✅ Correct : valeur numérique
Set-ItemProperty -Path $path -Name "Count" -Value 5 -Type DWord
```

### 🔴 Piège 5 : Oublier les droits administrateur

```powershell
# ❌ Erreur d'accès refusé en PowerShell non-admin
Set-ItemProperty -Path "HKLM:\SOFTWARE\MyApp" -Name "Setting" -Value "Test"

# ✅ Solution : lancer PowerShell en administrateur
# Ou modifier dans HKCU au lieu de HKLM
```

### 🔴 Piège 6 : Variables d'environnement non développées

```powershell
# Lecture d'une REG_EXPAND_SZ
$path = Get-ItemProperty -Path "HKLM:\SYSTEM\Setup" -Name "SystemPartition"
# PowerShell développe automatiquement : C:\ (et non %SystemRoot%)

# Si vous voulez la valeur brute (non développée), utilisez .NET
[Microsoft.Win32.Registry]::LocalMachine.OpenSubKey("SYSTEM\Setup").GetValue("SystemPartition", $null, [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames)
```

---

> [!tip] Astuce finale - Pipeline Vous pouvez combiner Get et Set dans un pipeline pour des modifications conditionnelles :
> 
> ```powershell
> Get-ItemProperty -Path "HKCU:\SOFTWARE\MyApp" | 
>     Where-Object { $_.Version -lt "2.0" } |
>     ForEach-Object { Set-ItemProperty -Path $_.PSPath -Name "Version" -Value "2.0" }
> ```

---

_Cours complet sur Get-ItemProperty et Set-ItemProperty - Manipulation des valeurs du registre Windows avec PowerShell_