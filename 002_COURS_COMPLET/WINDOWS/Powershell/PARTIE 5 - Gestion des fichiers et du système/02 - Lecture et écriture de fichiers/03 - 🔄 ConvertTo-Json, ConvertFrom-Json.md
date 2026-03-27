

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

## 🎯 Introduction au format JSON

**JSON** (JavaScript Object Notation) est un format léger d'échange de données, largement utilisé pour :

- Les **APIs REST** : communication avec des services web
- Les **fichiers de configuration** : paramètres d'applications
- L'**échange de données** entre systèmes hétérogènes
- Le **stockage de données structurées** de manière lisible

PowerShell offre deux cmdlets natives pour travailler avec JSON :

- `ConvertTo-Json` : convertit des objets PowerShell en JSON
- `ConvertFrom-Json` : parse du JSON vers des objets PowerShell

> [!info] Pourquoi utiliser JSON ? JSON est universel, léger, lisible par l'humain et supporté par pratiquement tous les langages de programmation. C'est le format standard pour les APIs modernes.

---

## 📤 ConvertTo-Json : Exporter en JSON

### Syntaxe de base

```powershell
ConvertTo-Json [-InputObject] <Object> 
               [-Depth <Int32>] 
               [-Compress] 
               [-EnumsAsStrings] 
               [-AsArray]
```

### Conversion simple d'objets

```powershell
# Objet simple
$utilisateur = [PSCustomObject]@{
    Nom = "Dupont"
    Prenom = "Jean"
    Age = 35
}

$utilisateur | ConvertTo-Json
```

**Résultat** :

```json
{
  "Nom": "Dupont",
  "Prenom": "Jean",
  "Age": 35
}
```

> [!example] Exemple avec plusieurs objets
> 
> ```powershell
> # Array d'objets
> $utilisateurs = @(
>     [PSCustomObject]@{Nom = "Dupont"; Prenom = "Jean"},
>     [PSCustomObject]@{Nom = "Martin"; Prenom = "Sophie"}
> )
> 
> $utilisateurs | ConvertTo-Json
> ```

### Le paramètre `-Depth` : Contrôler la profondeur

Par défaut, `ConvertTo-Json` ne sérialise que **2 niveaux de profondeur**. Pour les objets complexes imbriqués, cela peut poser problème.

```powershell
# Objet avec plusieurs niveaux
$config = [PSCustomObject]@{
    Application = "MonApp"
    Serveur = [PSCustomObject]@{
        Nom = "SRV01"
        Configuration = [PSCustomObject]@{
            CPU = 4
            RAM = 16
            Disques = @(
                [PSCustomObject]@{Lettre = "C"; Taille = 100},
                [PSCustomObject]@{Lettre = "D"; Taille = 500}
            )
        }
    }
}

# Avec profondeur par défaut (2) - ATTENTION : données tronquées !
$config | ConvertTo-Json

# Avec profondeur suffisante (5)
$config | ConvertTo-Json -Depth 5
```

> [!warning] Piège courant : Profondeur insuffisante Si vous ne spécifiez pas `-Depth` et que votre objet a plus de 2 niveaux, les données profondes seront remplacées par le type de l'objet (ex: `"System.Object"` ou `"System.Collections.Hashtable"`). Utilisez toujours `-Depth` avec des structures complexes !

**Recommandations** :

- Objets simples (1-2 niveaux) : pas besoin de `-Depth`
- Objets moyennement complexes : `-Depth 5`
- Objets très complexes : `-Depth 10` ou plus
- Maximum autorisé : `-Depth 100`

### Le paramètre `-Compress` : Format compact

Par défaut, JSON est formaté avec indentation pour être lisible. `-Compress` supprime les espaces et retours à la ligne.

```powershell
# Format lisible (par défaut)
$utilisateur | ConvertTo-Json

# Format compact (pour transmission réseau ou fichiers)
$utilisateur | ConvertTo-Json -Compress
```

**Résultat compressé** :

```json
{"Nom":"Dupont","Prenom":"Jean","Age":35}
```

> [!tip] Quand utiliser `-Compress` ?
> 
> - Lors d'envoi via API REST pour réduire la bande passante
> - Pour des fichiers de log où la lisibilité n'est pas prioritaire
> - Pour optimiser l'espace disque avec de gros volumes de données

### Gestion des hashtables

Les hashtables PowerShell se convertissent naturellement en objets JSON :

```powershell
# Hashtable simple
$config = @{
    Serveur = "SQL01"
    Port = 1433
    Database = "Production"
    Options = @{
        Timeout = 30
        Retry = 3
    }
}

$config | ConvertTo-Json -Depth 3
```

### Gestion des arrays

Les arrays PowerShell deviennent des arrays JSON :

```powershell
# Array de valeurs simples
$couleurs = @("Rouge", "Vert", "Bleu")
$couleurs | ConvertTo-Json

# Array d'objets complexes
$serveurs = @(
    @{Nom = "SRV01"; IP = "192.168.1.10"},
    @{Nom = "SRV02"; IP = "192.168.1.11"}
)
$serveurs | ConvertTo-Json -Depth 2
```

### Le paramètre `-EnumsAsStrings`

Convertit les énumérations en chaînes de caractères au lieu de valeurs numériques :

```powershell
# Exemple avec FileAttributes
$fichier = Get-Item "C:\Windows\System32\notepad.exe"

# Sans -EnumsAsStrings : valeur numérique
$fichier | Select-Object Name, Attributes | ConvertTo-Json

# Avec -EnumsAsStrings : nom lisible
$fichier | Select-Object Name, Attributes | ConvertTo-Json -EnumsAsStrings
```

### Sauvegarder dans un fichier

```powershell
# Exporter vers un fichier de configuration
$configuration = @{
    Version = "1.0"
    Environnement = "Production"
    Parametres = @{
        LogLevel = "Info"
        MaxConnections = 100
    }
}

$configuration | ConvertTo-Json -Depth 3 | Out-File "config.json" -Encoding UTF8
```

> [!tip] Astuce : Encodage UTF-8 Utilisez toujours `-Encoding UTF8` avec `Out-File` pour garantir la compatibilité avec d'autres systèmes et éviter les problèmes d'accents.

---

## 📥 ConvertFrom-Json : Importer depuis JSON

### Syntaxe de base

```powershell
ConvertFrom-Json [-InputObject] <String> 
                 [-AsHashtable] 
                 [-Depth <Int32>] 
                 [-NoEnumerate]
```

### Parsing simple

```powershell
# JSON simple sous forme de chaîne
$json = '{"Nom":"Dupont","Prenom":"Jean","Age":35}'

# Conversion en objet PowerShell
$utilisateur = $json | ConvertFrom-Json

# Accès aux propriétés
$utilisateur.Nom        # Affiche : Dupont
$utilisateur.Prenom     # Affiche : Jean
$utilisateur.Age        # Affiche : 35
```

### Lire depuis un fichier

```powershell
# Lire un fichier de configuration JSON
$configJson = Get-Content "config.json" -Raw
$config = $configJson | ConvertFrom-Json

# Accéder aux valeurs
$config.Version
$config.Parametres.LogLevel
```

> [!warning] Important : Utilisez `-Raw` Toujours utiliser `-Raw` avec `Get-Content` pour lire du JSON. Sans ce paramètre, le fichier est lu ligne par ligne dans un array, ce qui casse la structure JSON !

```powershell
# ❌ MAUVAIS - Crée un array de lignes
$json = Get-Content "config.json"

# ✅ BON - Charge le fichier complet
$json = Get-Content "config.json" -Raw
```

### Le paramètre `-AsHashtable` (PowerShell 6+)

Par défaut, `ConvertFrom-Json` retourne un **PSCustomObject**. Avec `-AsHashtable`, vous obtenez une **hashtable** :

```powershell
# Objet PSCustomObject (par défaut)
$objetPS = $json | ConvertFrom-Json
$objetPS.GetType()  # PSCustomObject

# Hashtable (PowerShell 6+)
$hashtable = $json | ConvertFrom-Json -AsHashtable
$hashtable.GetType()  # System.Collections.Hashtable

# Différence d'accès
$objetPS.Nom           # Notation point
$hashtable["Nom"]      # Notation index (aussi possible : $hashtable.Nom)
```

**Avantages des hashtables** :

- Plus flexible pour ajouter/modifier des clés dynamiquement
- Meilleures performances pour de grosses structures
- Compatibilité avec certaines cmdlets qui nécessitent des hashtables

> [!info] Compatibilité `-AsHashtable` est disponible uniquement à partir de **PowerShell Core 6.0**. Sur Windows PowerShell 5.1, vous obtiendrez toujours un PSCustomObject.

### Accès aux propriétés imbriquées

```powershell
$jsonConfig = @"
{
    "Application": "MonApp",
    "Serveur": {
        "Nom": "SRV01",
        "Configuration": {
            "CPU": 4,
            "RAM": 16
        }
    }
}
"@

$config = $jsonConfig | ConvertFrom-Json

# Accès aux propriétés imbriquées avec notation point
$config.Application                        # MonApp
$config.Serveur.Nom                        # SRV01
$config.Serveur.Configuration.CPU          # 4
```

### Gestion des arrays JSON

```powershell
$jsonArray = @"
[
    {"Nom": "Dupont", "Age": 35},
    {"Nom": "Martin", "Age": 42},
    {"Nom": "Durand", "Age": 28}
]
"@

$utilisateurs = $jsonArray | ConvertFrom-Json

# Parcourir l'array
foreach ($user in $utilisateurs) {
    Write-Host "$($user.Nom) a $($user.Age) ans"
}

# Filtrer avec Where-Object
$utilisateurs | Where-Object {$_.Age -gt 30}
```

### Modifier et réexporter

```powershell
# Charger un fichier de configuration
$config = Get-Content "config.json" -Raw | ConvertFrom-Json

# Modifier des valeurs
$config.Parametres.LogLevel = "Debug"
$config.Parametres.MaxConnections = 200

# Réexporter en JSON
$config | ConvertTo-Json -Depth 5 | Set-Content "config.json" -Encoding UTF8
```

---

## 💼 Cas d'usage pratiques

### 1. Appels d'API REST

```powershell
# Préparer les données pour une API
$body = @{
    username = "admin"
    password = "P@ssw0rd"
    domain = "ENTREPRISE"
} | ConvertTo-Json

# Appel POST avec JSON
$response = Invoke-RestMethod -Uri "https://api.exemple.com/login" `
                              -Method POST `
                              -Body $body `
                              -ContentType "application/json"

# Le résultat est automatiquement converti depuis JSON
$response.token
```

> [!example] Exemple complet avec authentification
> 
> ```powershell
> # Authentification et récupération de données
> $credentials = @{
>     email = "user@exemple.com"
>     password = "secret"
> } | ConvertTo-Json
> 
> $auth = Invoke-RestMethod -Uri "https://api.exemple.com/auth" `
>                           -Method POST `
>                           -Body $credentials `
>                           -ContentType "application/json"
> 
> # Utiliser le token pour d'autres requêtes
> $headers = @{Authorization = "Bearer $($auth.token)"}
> $data = Invoke-RestMethod -Uri "https://api.exemple.com/data" `
>                           -Headers $headers
> ```

### 2. Fichiers de configuration

```powershell
# Créer un fichier de configuration structuré
$config = @{
    Application = @{
        Nom = "MonApp"
        Version = "2.1.0"
        Environnement = "Production"
    }
    Database = @{
        Serveur = "SQL01.entreprise.local"
        Port = 1433
        Nom = "AppDB"
        ConnectionTimeout = 30
    }
    Logging = @{
        Niveau = "Info"
        Fichier = "C:\Logs\app.log"
        MaxSize = "10MB"
        Rotation = $true
    }
}

# Exporter la configuration
$config | ConvertTo-Json -Depth 5 | Out-File "app.config.json" -Encoding UTF8

# Plus tard : charger la configuration
$appConfig = Get-Content "app.config.json" -Raw | ConvertFrom-Json
$connectionString = "Server=$($appConfig.Database.Serveur);Database=$($appConfig.Database.Nom)"
```

### 3. Sauvegarde et restauration d'état

```powershell
# Sauvegarder l'état d'un système
$etatSysteme = @{
    Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Serveurs = Get-Service | Where-Object {$_.Status -eq "Running"} | 
               Select-Object Name, DisplayName, Status
    Disques = Get-PSDrive -PSProvider FileSystem | 
              Select-Object Name, Used, Free
}

$etatSysteme | ConvertTo-Json -Depth 5 | Out-File "etat_$(Get-Date -Format 'yyyyMMdd').json"

# Restaurer et comparer
$etatPrecedent = Get-Content "etat_20241210.json" -Raw | ConvertFrom-Json
```

### 4. Échange de données entre scripts

```powershell
# Script 1 : Collecte de données
$resultats = @{
    Timestamp = Get-Date
    Utilisateurs = Get-ADUser -Filter * | Select-Object Name, SamAccountName
    Serveurs = Get-ADComputer -Filter * | Select-Object Name, OperatingSystem
}

$resultats | ConvertTo-Json -Depth 5 | Out-File "data.json"

# Script 2 : Traitement des données
$donnees = Get-Content "data.json" -Raw | ConvertFrom-Json
$donnees.Utilisateurs | Export-Csv "users.csv" -NoTypeInformation
```

---

## ⚠️ Gestion des erreurs

### Erreurs de parsing JSON invalide

```powershell
# JSON invalide (virgule finale)
$jsonInvalide = '{"Nom":"Dupont","Age":35,}'

try {
    $objet = $jsonInvalide | ConvertFrom-Json
} catch {
    Write-Error "Erreur de parsing JSON : $($_.Exception.Message)"
}
```

> [!warning] JSON mal formaté Les erreurs courantes incluent :
> 
> - Virgules finales dans les objets ou arrays
> - Guillemets manquants ou mal placés
> - Accolades/crochets non fermés
> - Commentaires (JSON ne supporte pas les commentaires)

### Validation avant parsing

```powershell
function Test-JsonValide {
    param([string]$Json)
    
    try {
        $null = $Json | ConvertFrom-Json
        return $true
    } catch {
        return $false
    }
}

# Utilisation
$json = Get-Content "config.json" -Raw
if (Test-JsonValide -Json $json) {
    $config = $json | ConvertFrom-Json
} else {
    Write-Error "Le fichier JSON est invalide"
}
```

### Gestion des propriétés manquantes

```powershell
$json = '{"Nom":"Dupont"}'  # Propriété "Age" manquante
$utilisateur = $json | ConvertFrom-Json

# Vérifier l'existence d'une propriété avant accès
if ($utilisateur.PSObject.Properties["Age"]) {
    Write-Host "Age : $($utilisateur.Age)"
} else {
    Write-Host "Propriété Age non trouvée"
}

# Alternative avec test null
if ($null -ne $utilisateur.Age) {
    Write-Host "Age : $($utilisateur.Age)"
}
```

### Try-Catch pour fichiers corrompus

```powershell
function Import-JsonSafe {
    param(
        [string]$FilePath,
        [object]$DefaultValue = $null
    )
    
    try {
        if (Test-Path $FilePath) {
            $content = Get-Content $FilePath -Raw -ErrorAction Stop
            return ($content | ConvertFrom-Json -ErrorAction Stop)
        } else {
            Write-Warning "Fichier introuvable : $FilePath"
            return $DefaultValue
        }
    } catch {
        Write-Error "Impossible de charger le JSON : $($_.Exception.Message)"
        return $DefaultValue
    }
}

# Utilisation avec valeur par défaut
$config = Import-JsonSafe -FilePath "config.json" -DefaultValue @{Version = "1.0"}
```

---

## ✅ Bonnes pratiques

### 1. Toujours spécifier `-Depth` pour objets complexes

```powershell
# ❌ MAUVAIS - Profondeur par défaut (2)
$objetComplexe | ConvertTo-Json

# ✅ BON - Profondeur explicite
$objetComplexe | ConvertTo-Json -Depth 10
```

### 2. Utiliser `-Raw` avec Get-Content

```powershell
# ❌ MAUVAIS - Lit ligne par ligne
$json = Get-Content "config.json"

# ✅ BON - Charge le contenu complet
$json = Get-Content "config.json" -Raw
```

### 3. Encoder en UTF-8 pour la compatibilité

```powershell
# ✅ BON - Spécifier l'encodage
$data | ConvertTo-Json | Out-File "data.json" -Encoding UTF8
```

### 4. Valider le JSON avant parsing critique

```powershell
# Pour les fichiers de configuration critiques
$jsonContent = Get-Content "critical-config.json" -Raw

if (Test-JsonValide -Json $jsonContent) {
    $config = $jsonContent | ConvertFrom-Json
    # Utiliser la configuration
} else {
    # Utiliser des valeurs par défaut ou alerter
    Write-Error "Configuration JSON invalide, utilisation des paramètres par défaut"
}
```

### 5. Gérer les objets circulaires

PowerShell peut avoir des problèmes avec les objets qui se référencent eux-mêmes :

```powershell
# Créer un nouvel objet propre sans références circulaires
$objetPropre = $objetComplexe | Select-Object Propriete1, Propriete2, Propriete3
$objetPropre | ConvertTo-Json -Depth 5
```

### 6. Compresser pour la transmission réseau

```powershell
# Pour les APIs et transmissions réseau
$body = $data | ConvertTo-Json -Depth 5 -Compress
Invoke-RestMethod -Uri $apiUrl -Method POST -Body $body
```

### 7. Documenter la structure attendue

```powershell
# Créer un template commenté
<#
Structure JSON attendue pour la configuration :
{
    "Application": {
        "Nom": "string",
        "Version": "string",
        "Environnement": "Development|Production"
    },
    "Database": {
        "Serveur": "string",
        "Port": number,
        "Nom": "string"
    }
}
#>

$config = Get-Content "config.json" -Raw | ConvertFrom-Json
```

### 8. Créer des fonctions wrapper pour réutilisation

```powershell
function Export-JsonConfig {
    param(
        [Parameter(Mandatory)]
        [object]$Data,
        
        [Parameter(Mandatory)]
        [string]$FilePath,
        
        [int]$Depth = 10,
        [switch]$Compress
    )
    
    $params = @{
        Depth = $Depth
    }
    if ($Compress) { $params.Add('Compress', $true) }
    
    $Data | ConvertTo-Json @params | Out-File $FilePath -Encoding UTF8
}

function Import-JsonConfig {
    param(
        [Parameter(Mandatory)]
        [string]$FilePath,
        [switch]$AsHashtable
    )
    
    if (-not (Test-Path $FilePath)) {
        throw "Fichier introuvable : $FilePath"
    }
    
    $content = Get-Content $FilePath -Raw
    $params = @{}
    if ($AsHashtable -and $PSVersionTable.PSVersion.Major -ge 6) {
        $params.Add('AsHashtable', $true)
    }
    
    return ($content | ConvertFrom-Json @params)
}
```

---

## 📊 Tableau récapitulatif

|Cmdlet|Direction|Paramètres clés|Usage principal|
|---|---|---|---|
|`ConvertTo-Json`|PowerShell → JSON|`-Depth`, `-Compress`|Exporter des données, appels API|
|`ConvertFrom-Json`|JSON → PowerShell|`-AsHashtable` (PS6+)|Importer des configurations, parser des réponses|

### Paramètres importants

|Paramètre|Cmdlet|Description|Valeur recommandée|
|---|---|---|---|
|`-Depth`|ConvertTo-Json|Niveaux d'imbrication|5-10 pour objets complexes|
|`-Compress`|ConvertTo-Json|Supprimer espaces/retours|Pour transmission réseau|
|`-AsHashtable`|ConvertFrom-Json|Retourner hashtable|PS Core 6+ uniquement|
|`-Raw`|Get-Content|Lire fichier complet|**Obligatoire** pour JSON|

---

> [!tip] 🎯 Points clés à retenir
> 
> - JSON est le format standard pour les APIs et configurations modernes
> - Toujours utiliser `-Depth` avec des objets complexes (défaut = 2 niveaux)
> - Toujours utiliser `-Raw` avec `Get-Content` pour lire du JSON
> - Gérer les erreurs de parsing avec try-catch
> - Encoder en UTF-8 pour la compatibilité maximale
> - `-Compress` pour optimiser la transmission, format lisible pour le développement