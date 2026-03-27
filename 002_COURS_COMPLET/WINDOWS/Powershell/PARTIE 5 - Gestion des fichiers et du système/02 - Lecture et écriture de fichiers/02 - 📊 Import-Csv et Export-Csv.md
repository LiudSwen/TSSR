

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

## 🎯 Introduction aux fichiers CSV {#introduction}

### Qu'est-ce qu'un fichier CSV ?

Les fichiers **CSV** (Comma-Separated Values) sont des fichiers texte structurés où chaque ligne représente un enregistrement et chaque valeur est séparée par un délimiteur (généralement une virgule ou un point-virgule).

> [!info] Pourquoi utiliser CSV avec PowerShell ?
> 
> - **Échange de données universel** : Compatible avec Excel, bases de données, applications web
> - **Lisible par l'humain** : Format texte simple à inspecter
> - **Manipulation facile** : PowerShell convertit automatiquement les CSV en objets
> - **Logging et exports** : Idéal pour sauvegarder des résultats de scripts

### Structure typique d'un CSV

```csv
Nom,Prénom,Email,Département
Dupont,Jean,jean.dupont@example.com,IT
Martin,Sophie,sophie.martin@example.com,RH
Bernard,Luc,luc.bernard@example.com,Ventes
```

**Composants** :

- **Ligne d'en-tête** : Première ligne contenant les noms des colonnes
- **Lignes de données** : Chaque ligne suivante = un enregistrement
- **Délimiteur** : Caractère séparant les valeurs (`,` ou `;` selon la locale)

---

## 📥 Import-Csv - Lecture de données {#import-csv}

### Fonctionnement de base

`Import-Csv` lit un fichier CSV et **convertit automatiquement chaque ligne en objet PowerShell**, avec les en-têtes comme propriétés.

```powershell
# Import simple
$utilisateurs = Import-Csv -Path "C:\Data\utilisateurs.csv"

# Affichage
$utilisateurs | Format-Table

# Accès aux propriétés
$utilisateurs[0].Nom      # "Dupont"
$utilisateurs[0].Email    # "jean.dupont@example.com"
```

> [!example] Conversion automatique
> 
> ```powershell
> # Le fichier CSV :
> # Nom,Age,Actif
> # Alice,25,true
> # Bob,30,false
> 
> $data = Import-Csv "personnes.csv"
> 
> # PowerShell crée des objets :
> $data[0].Nom     # "Alice" (string)
> $data[0].Age     # "25" (string, pas int!)
> $data[0].Actif   # "true" (string, pas boolean!)
> ```

> [!warning] Types de données `Import-Csv` lit TOUT comme des **chaînes de caractères** (string). Vous devez convertir manuellement si besoin :
> 
> ```powershell
> [int]$data[0].Age          # Conversion en entier
> [bool]::Parse($data[0].Actif)  # Conversion en boolean
> ```

### Paramètre `-Delimiter` : Séparateurs personnalisés

Par défaut, `Import-Csv` utilise la **virgule** comme séparateur. Si votre fichier utilise un autre délimiteur (point-virgule, tabulation), spécifiez-le avec `-Delimiter`.

```powershell
# Fichier avec point-virgule (format européen)
$data = Import-Csv -Path "data.csv" -Delimiter ";"

# Fichier TSV (Tab-Separated Values)
$data = Import-Csv -Path "data.tsv" -Delimiter "`t"

# Délimiteur pipe
$data = Import-Csv -Path "data.txt" -Delimiter "|"
```

> [!tip] Détection automatique locale PowerShell utilise le séparateur de liste de votre système par défaut. En France (locale fr-FR), c'est le **point-virgule** (`;`). Pour forcer la virgule :
> 
> ```powershell
> Import-Csv -Path "data.csv" -Delimiter ","
> ```

### Paramètre `-Header` : Spécifier les en-têtes manuellement

Si votre fichier **n'a pas de ligne d'en-tête**, ou si vous voulez **renommer les colonnes**, utilisez `-Header`.

```powershell
# Fichier sans en-tête :
# Jean,Dupont,35
# Sophie,Martin,28

$data = Import-Csv -Path "sans_entete.csv" -Header "Prénom","Nom","Age"

$data[0].Prénom  # "Jean"
$data[0].Nom     # "Dupont"
$data[0].Age     # "35"
```

> [!warning] Attention avec `-Header` Quand vous utilisez `-Header`, PowerShell considère la **première ligne comme des données** (pas comme en-tête). Si votre fichier a déjà un en-tête, la première ligne sera traitée comme données !
> 
> Pour **sauter la première ligne ET définir vos en-têtes** :
> 
> ```powershell
> Import-Csv -Path "fichier.csv" -Header "Col1","Col2" | Select-Object -Skip 1
> ```

### Paramètre `-Encoding` : Fichiers internationaux

Pour lire correctement des fichiers avec des **caractères spéciaux** (accents, caractères non-ASCII), spécifiez l'encodage.

```powershell
# UTF-8 avec BOM
$data = Import-Csv -Path "fichier.csv" -Encoding UTF8

# UTF-8 sans BOM (PS 7+)
$data = Import-Csv -Path "fichier.csv" -Encoding utf8NoBOM

# Latin-1 / ISO-8859-1 (anciens fichiers Windows)
$data = Import-Csv -Path "fichier.csv" -Encoding Default

# UTF-16 Little Endian (Unicode)
$data = Import-Csv -Path "fichier.csv" -Encoding Unicode
```

> [!info] Encodages courants
> 
> |Encodage|Usage|
> |---|---|
> |`UTF8`|Standard moderne (avec BOM)|
> |`utf8NoBOM`|UTF-8 sans marqueur BOM (PS 7+)|
> |`Unicode`|UTF-16 LE (fichiers Windows)|
> |`ASCII`|Caractères basiques uniquement|
> |`Default`|Encodage système (ANSI/Latin-1 sur Windows FR)|

### Exemples pratiques

```powershell
# Import avec filtrage direct
$utilisateurs = Import-Csv "users.csv" | Where-Object {$_.Département -eq "IT"}

# Import avec transformation
$data = Import-Csv "ages.csv" | ForEach-Object {
    [PSCustomObject]@{
        Nom = $_.Nom
        Age = [int]$_.Age
        Majeur = ([int]$_.Age -ge 18)
    }
}

# Import depuis plusieurs fichiers
$allData = Get-ChildItem "C:\Logs\*.csv" | ForEach-Object {
    Import-Csv $_.FullName
}

# Vérification de l'existence du fichier
if (Test-Path "data.csv") {
    $data = Import-Csv "data.csv"
} else {
    Write-Warning "Fichier introuvable"
}
```

---

## 📤 Export-Csv - Écriture de données {#export-csv}

### Fonctionnement de base

`Export-Csv` prend des **objets PowerShell** et les convertit en fichier CSV. Toutes les propriétés des objets deviennent des colonnes.

```powershell
# Création d'objets
$utilisateurs = @(
    [PSCustomObject]@{Nom="Dupont"; Prénom="Jean"; Age=35}
    [PSCustomObject]@{Nom="Martin"; Prénom="Sophie"; Age=28}
)

# Export vers CSV
$utilisateurs | Export-Csv -Path "utilisateurs.csv" -NoTypeInformation
```

**Résultat** (`utilisateurs.csv`) :

```csv
"Nom","Prénom","Age"
"Dupont","Jean","35"
"Martin","Sophie","28"
```

> [!info] Pourquoi les guillemets ? Par défaut, `Export-Csv` entoure toutes les valeurs de **guillemets doubles** pour protéger les valeurs contenant des délimiteurs ou des retours à la ligne. C'est conforme au standard RFC 4180.

### Paramètre `-NoTypeInformation`

**PowerShell 5.1 et versions antérieures** ajoutent une première ligne avec le type d'objet :

```csv
#TYPE System.Management.Automation.PSCustomObject
"Nom","Prénom","Age"
...
```

Pour **supprimer cette ligne**, utilisez `-NoTypeInformation` :

```powershell
# PowerShell 5.1
Export-Csv -Path "data.csv" -NoTypeInformation

# PowerShell 7+ : comportement par défaut (pas besoin du paramètre)
Export-Csv -Path "data.csv"
```

> [!tip] PowerShell 7+ Dans **PowerShell Core (7+)**, le comportement par défaut est de **NE PAS** inclure la ligne de type. Le paramètre `-NoTypeInformation` est donc optionnel.

### Paramètre `-Delimiter` : Format personnalisé

Choisissez le délimiteur pour l'export (par défaut : virgule).

```powershell
# Point-virgule (format européen)
Export-Csv -Path "data.csv" -Delimiter ";" -NoTypeInformation

# Tabulation (TSV)
Export-Csv -Path "data.tsv" -Delimiter "`t" -NoTypeInformation

# Pipe
Export-Csv -Path "data.txt" -Delimiter "|" -NoTypeInformation
```

### Paramètre `-Append` : Ajouter à un fichier existant

Au lieu d'écraser le fichier, **ajoutez** de nouvelles lignes à la fin.

```powershell
# Premier export
$batch1 | Export-Csv -Path "logs.csv" -NoTypeInformation

# Ajout de nouvelles données (sans réécrire l'en-tête)
$batch2 | Export-Csv -Path "logs.csv" -Append -NoTypeInformation

# Résultat : logs.csv contient batch1 + batch2
```

> [!warning] Attention à l'en-tête Avec `-Append`, PowerShell **n'ajoute PAS** de nouvelle ligne d'en-tête. Assurez-vous que les objets ajoutés ont les **mêmes propriétés** que l'export initial, sinon les colonnes seront décalées.

### Paramètre `-Force` : Écraser sans confirmation

Si le fichier existe et est **en lecture seule**, utilisez `-Force` pour forcer l'écrasement.

```powershell
# Écrase le fichier même s'il est protégé
Export-Csv -Path "data.csv" -Force -NoTypeInformation
```

### Paramètre `-Encoding` : Contrôler l'encodage de sortie

```powershell
# UTF-8 avec BOM
Export-Csv -Path "data.csv" -Encoding UTF8

# UTF-8 sans BOM (PS 7+, recommandé pour compatibilité multi-plateforme)
Export-Csv -Path "data.csv" -Encoding utf8NoBOM

# UTF-16 (Unicode)
Export-Csv -Path "data.csv" -Encoding Unicode
```

### Exemples pratiques

```powershell
# Export de services en cours d'exécution
Get-Service | Where-Object {$_.Status -eq "Running"} |
    Select-Object Name, DisplayName, Status |
    Export-Csv "services_running.csv" -NoTypeInformation

# Export de processus triés par mémoire
Get-Process | Sort-Object -Property WS -Descending | Select-Object -First 10 |
    Select-Object Name, Id, @{Name="MemoryMB";Expression={$_.WS / 1MB}} |
    Export-Csv "top_processes.csv" -NoTypeInformation -Delimiter ";"

# Export avec horodatage dans le nom de fichier
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
Get-EventLog -LogName System -Newest 100 |
    Export-Csv "events_$timestamp.csv" -NoTypeInformation

# Export conditionnel (seulement si des données existent)
$errors = Get-EventLog -LogName Application -EntryType Error -Newest 50
if ($errors.Count -gt 0) {
    $errors | Export-Csv "errors.csv" -NoTypeInformation
}
```

---

## 🔄 ConvertTo-Csv et ConvertFrom-Csv {#convert-csv}

### Différence avec Import/Export-Csv

|Cmdlet|Action|Sortie|
|---|---|---|
|`Import-Csv`|Lit un **fichier**|Objets PowerShell|
|`Export-Csv`|Écrit un **fichier**|Fichier CSV|
|`ConvertFrom-Csv`|Convertit une **chaîne CSV**|Objets PowerShell|
|`ConvertTo-Csv`|Convertit des objets|**Chaîne CSV** (en mémoire)|

> [!info] Quand utiliser Convert ?
> 
> - **Manipulation en mémoire** : Pas besoin d'écrire/lire un fichier temporaire
> - **Transmission réseau** : Envoyer des données CSV via HTTP, email, etc.
> - **Tests** : Créer des données CSV fictives sans fichier
> - **Pipeline** : Transformer des objets en CSV pour traitement ultérieur

### ConvertTo-Csv : Objets → Chaîne CSV

```powershell
# Créer des objets
$data = @(
    [PSCustomObject]@{Nom="Alice"; Age=25}
    [PSCustomObject]@{Nom="Bob"; Age=30}
)

# Convertir en chaîne CSV
$csvString = $data | ConvertTo-Csv -NoTypeInformation

# Afficher
$csvString
```

**Résultat** :

```
"Nom","Age"
"Alice","25"
"Bob","30"
```

> [!example] Utilisation pratique : Enregistrer en variable
> 
> ```powershell
> # Conversion en mémoire
> $csv = Get-Process | Select-Object -First 5 | ConvertTo-Csv -NoTypeInformation
> 
> # Envoyer par email ou API
> Send-MailMessage -Body ($csv -join "`n") -To "admin@example.com"
> ```

### ConvertFrom-Csv : Chaîne CSV → Objets

```powershell
# Données CSV en chaîne (simulant une réponse API, un clipboard, etc.)
$csvString = @"
Nom,Age,Ville
Alice,25,Paris
Bob,30,Lyon
Charlie,35,Marseille
"@

# Convertir en objets
$objets = $csvString | ConvertFrom-Csv

# Utiliser comme des objets normaux
$objets | Where-Object {$_.Age -gt 27}
```

### Paramètres identiques à Import/Export-Csv

Les cmdlets `Convert` acceptent les mêmes paramètres :

```powershell
# Délimiteur personnalisé
$csv = $data | ConvertTo-Csv -Delimiter ";"
$objets = $csvString | ConvertFrom-Csv -Delimiter ";"

# En-têtes personnalisés
$objets = $csvString | ConvertFrom-Csv -Header "Col1","Col2","Col3"

# Sans type information
$csv = $data | ConvertTo-Csv -NoTypeInformation
```

### Exemples d'usage

```powershell
# Récupérer du CSV depuis le presse-papiers
$csvFromClipboard = Get-Clipboard
$data = $csvFromClipboard | ConvertFrom-Csv

# Sauvegarder en JSON après conversion
$csv = Import-Csv "data.csv"
$csv | ConvertTo-Json | Out-File "data.json"

# Envoyer des données via REST API
$users = Get-ADUser -Filter * | Select-Object Name, Email
$csvPayload = $users | ConvertTo-Csv -NoTypeInformation
Invoke-RestMethod -Uri "https://api.example.com/upload" -Method Post -Body $csvPayload

# Combiner plusieurs fichiers CSV en un seul
$combined = Get-ChildItem "*.csv" | ForEach-Object {
    Get-Content $_.FullName | ConvertFrom-Csv
}
$combined | Export-Csv "combined.csv" -NoTypeInformation
```

---

## 🛠️ Manipulation de données tabulaires {#manipulation-données}

### Filtrage et sélection

```powershell
# Import avec filtrage
$data = Import-Csv "users.csv" | Where-Object {$_.Age -gt 30}

# Sélectionner des colonnes spécifiques
$data = Import-Csv "users.csv" | Select-Object Nom, Email

# Renommer des colonnes
$data = Import-Csv "users.csv" | Select-Object @{Name="FullName";Expression={$_.Nom}}, Email
```

### Tri et regroupement

```powershell
# Trier par colonne
$sorted = Import-Csv "data.csv" | Sort-Object -Property Age -Descending

# Regrouper par département
$grouped = Import-Csv "employees.csv" | Group-Object -Property Département

# Afficher les groupes
$grouped | ForEach-Object {
    Write-Host "Département: $($_.Name) - Employés: $($_.Count)"
    $_.Group | Format-Table
}
```

### Ajout de colonnes calculées

```powershell
# Ajouter une propriété calculée
$data = Import-Csv "salaires.csv" | Select-Object *,
    @{Name="SalaireAnnuel"; Expression={[int]$_.SalaireMensuel * 12}}

# Conversion de type avec calcul
$data = Import-Csv "ages.csv" | Select-Object Nom,
    @{Name="AgeInt"; Expression={[int]$_.Age}},
    @{Name="Majeur"; Expression={[int]$_.Age -ge 18}}
```

### Fusion de données (JOIN)

```powershell
# Charger deux CSV
$utilisateurs = Import-Csv "utilisateurs.csv"  # Colonnes: Id, Nom
$departements = Import-Csv "departements.csv"  # Colonnes: Id, Département

# JOIN manuel sur Id
$joined = $utilisateurs | ForEach-Object {
    $user = $_
    $dept = $departements | Where-Object {$_.Id -eq $user.Id}
    
    [PSCustomObject]@{
        Nom = $user.Nom
        Département = $dept.Département
    }
}
```

> [!tip] Pour des JOINs complexes Utilisez la méthode `Join-Object` disponible via le module PowerShell Gallery, ou scriptez votre propre logique de jointure avec des hashtables pour de meilleures performances.

### Agrégation et statistiques

```powershell
# Compter les lignes
$count = (Import-Csv "data.csv").Count

# Somme d'une colonne
$data = Import-Csv "ventes.csv"
$totalVentes = ($data | Measure-Object -Property Montant -Sum).Sum

# Moyenne, min, max
$stats = $data | Measure-Object -Property Montant -Average -Minimum -Maximum

Write-Host "Moyenne: $($stats.Average)"
Write-Host "Min: $($stats.Minimum)"
Write-Host "Max: $($stats.Maximum)"

# Statistiques par groupe
Import-Csv "sales.csv" | Group-Object -Property Region | ForEach-Object {
    $sum = ($_.Group | Measure-Object -Property Amount -Sum).Sum
    [PSCustomObject]@{
        Region = $_.Name
        TotalSales = $sum
    }
}
```

### Dédoublonnage

```powershell
# Supprimer les doublons
$unique = Import-Csv "data.csv" | Sort-Object -Property Email -Unique

# Ou avec Select-Object
$unique = Import-Csv "data.csv" | Select-Object -Property * -Unique
```

### Modification de données et ré-export

```powershell
# Importer, modifier, ré-exporter
$data = Import-Csv "users.csv"

$data | ForEach-Object {
    # Modification en place
    $_.Email = $_.Email.ToLower()
    $_.Nom = $_.Nom.ToUpper()
    
    # Retourner l'objet modifié
    $_
} | Export-Csv "users_updated.csv" -NoTypeInformation

# Ajouter une colonne "DateTraitement"
Import-Csv "logs.csv" | Select-Object *,
    @{Name="DateTraitement"; Expression={Get-Date -Format "yyyy-MM-dd"}} |
    Export-Csv "logs_processed.csv" -NoTypeInformation
```

---

## ⚠️ Pièges courants et bonnes pratiques {#pièges-bonnes-pratiques}

### 🔴 Piège 1 : Tous les types sont des strings

```powershell
# ❌ MAUVAIS : Comparaison incorrecte
$data = Import-Csv "ages.csv"
if ($data[0].Age -gt 18) {  # FAUX si Age = "18" (string)
    Write-Host "Majeur"
}

# ✅ BON : Conversion explicite
if ([int]$data[0].Age -gt 18) {
    Write-Host "Majeur"
}

# ✅ BON : Conversion lors de l'import
$data = Import-Csv "ages.csv" | ForEach-Object {
    [PSCustomObject]@{
        Nom = $_.Nom
        Age = [int]$_.Age
    }
}
```

### 🔴 Piège 2 : Délimiteur incorrect

```powershell
# ❌ MAUVAIS : Le fichier utilise ";" mais on ne le spécifie pas
$data = Import-Csv "european_data.csv"  # Échec si fichier avec ";"

# ✅ BON : Toujours vérifier et spécifier le délimiteur
$data = Import-Csv "european_data.csv" -Delimiter ";"
```

> [!tip] Détecter le délimiteur automatiquement
> 
> ```powershell
> $firstLine = Get-Content "data.csv" -First 1
> if ($firstLine -match ";") {
>     $delimiter = ";"
> } else {
>     $delimiter = ","
> }
> $data = Import-Csv "data.csv" -Delimiter $delimiter
> ```

### 🔴 Piège 3 : Problèmes d'encodage

```powershell
# ❌ MAUVAIS : Accents mal affichés
$data = Import-Csv "données_françaises.csv"  # Caractères corrompus

# ✅ BON : Spécifier l'encodage correct
$data = Import-Csv "données_françaises.csv" -Encoding UTF8
```

> [!warning] Tester l'encodage Si les accents ne s'affichent pas correctement, essayez :
> 
> - `UTF8`
> - `utf8NoBOM` (PS 7+)
> - `Default` (ANSI/Latin-1)
> - `Unicode` (UTF-16)

### 🔴 Piège 4 : Headers manquants ou mal alignés

```powershell
# ❌ MAUVAIS : Utiliser -Header sur un fichier qui a déjà un en-tête
$data = Import-Csv "users.csv" -Header "Nom","Email"
# Résultat : La vraie ligne d'en-tête devient la première ligne de données !

# ✅ BON : Utiliser -Header SEULEMENT si pas d'en-tête dans le fichier
$data = Import-Csv "users_noheader.csv" -Header "Nom","Email"

# ✅ BON : Si vous voulez remplacer l'en-tête, sautez la première ligne
$data = Import-Csv "users.csv" -Header "CustomName","CustomEmail" | 
    Select-Object -Skip 1
```

### 🔴 Piège 5 : Export écrase sans avertissement

```powershell
# ❌ MAUVAIS : Écrase le fichier original
Import-Csv "data.csv" | Where-Object {$_.Age -gt 18} | 
    Export-Csv "data.csv" -NoTypeInformation  # PERTE DE DONNÉES !

# ✅ BON : Toujours sauvegarder avec un nouveau nom ou backup
$data = Import-Csv "data.csv"
Copy-Item "data.csv" "data_backup.csv"  # Backup
$data | Where-Object {$_.Age -gt 18} | 
    Export-Csv "data_filtered.csv" -NoTypeInformation
```

### 🔴 Piège 6 : Guillemets dans les données

```powershell
# Données problématiques : "Dupont, Jean" (contient un délimiteur)
# CSV standard :
# Nom,Email
# "Dupont, Jean",jean@example.com

# ✅ Import-Csv gère automatiquement les guillemets protecteurs
$data = Import-Csv "data.csv"
$data[0].Nom  # "Dupont, Jean" (correct, guillemets retirés)

# ❌ Problème si guillemets mal échappés dans le CSV :
# Nom,Email
# Dupont, Jean,jean@example.com  # Sera parsé comme 3 colonnes !

# ✅ Toujours utiliser Export-Csv pour garantir le format correct
```

### ✅ Bonnes pratiques générales

> [!tip] 📋 Checklist pour Import-Csv
> 
> 1. **Vérifier l'encodage** : Spécifier `-Encoding` si accents/caractères spéciaux
> 2. **Tester le délimiteur** : Examiner le fichier, utiliser `-Delimiter` si nécessaire
> 3. **Valider les en-têtes** : Vérifier que la première ligne est bien un en-tête
> 4. **Convertir les types** : Transformer les strings en int, datetime, bool selon besoin
> 5. **Gestion d'erreurs** : Encadrer avec `try/catch` pour fichiers externes

```powershell
# Template robuste pour Import-Csv
try {
    if (-not (Test-Path "data.csv")) {
        throw "Fichier introuvable"
    }
    
    $data = Import-Csv -Path "data.csv" `
                       -Delimiter ";" `
                       -Encoding UTF8 `
                       -ErrorAction Stop
    
    # Validation basique
    if ($data.Count -eq 0) {
        Write-Warning "Fichier vide"
    } else {
        Write-Host "✓ $($data.Count) lignes importées"
    }
    
} catch {
    Write-Error "Erreur d'import : $_"
}
```

> [!tip] 📋 Checklist pour Export-Csv
> 
> 1. **Utiliser `-NoTypeInformation`** (PS 5.1) pour supprimer la ligne de type
> 2. **Spécifier le délimiteur** si format non standard
> 3. **Choisir l'encodage** : `-Encoding utf8NoBOM` (PS 7+) pour compatibilité multi-plateforme
> 4. **Backup avant écrasement** : Sauvegarder l'original si vous écrasez
> 5. **Tester avec `-WhatIf`** : Vérifier le chemin avant écriture réelle

```powershell
# Template robuste pour Export-Csv
$outputPath = "C:\Exports\data_$(Get-Date -Format 'yyyyMMdd_HHmmss').csv"

try {
    # Créer le dossier si nécessaire
    $folder = Split-Path $outputPath -Parent
    if (-not (Test-Path $folder)) {
        New-Item -ItemType Directory -Path $folder -Force | Out-Null
    }
    
    # Export
    $data | Export-Csv -Path $outputPath `
                       -NoTypeInformation `
                       -Delimiter ";" `
                       -Encoding UTF8 `
                       -ErrorAction Stop
    
    Write-Host "✓ Export réussi : $outputPath"
    
} catch {
    Write-Error "Erreur d'export : $_"
}
```

### 🎯 Astuces de performance

```powershell
# ⚡ Pour gros fichiers : Traiter ligne par ligne avec Get-Content
Get-Content "huge_file.csv" | Select-Object -Skip 1 | ForEach-Object {
    $fields = $_ -split ","
    # Traiter chaque ligne individuellement (économie mémoire)
}

# ⚡ Éviter les conversions répétées dans les boucles
# ❌ LENT :
$data = Import-Csv "data.csv"
foreach ($row in $data) {
    [int]$row.Age  # Conversion à chaque itération
}

# ✅ RAPIDE : Convertir une fois pour toutes
$data = Import-Csv "data.csv" | ForEach-Object {
    $_.Age = [int]$_.Age
    $_
}

# ⚡ Utiliser -Append intelligemment pour logging progressif
# Plutôt que d'accumuler en mémoire puis exporter d'un coup
$resultats | Export-Csv "log.csv" -Append -NoTypeInformation
```

---

## 🎓 Résumé

Les cmdlets CSV de PowerShell offrent une solution puissante pour manipuler des données tabulaires :

|Cmdlet|Usage principal|Points clés|
|---|---|---|
|**Import-Csv**|Lire fichiers CSV → Objets|`-Delimiter`, `-Header`, `-Encoding`|
|**Export-Csv**|Objets → Fichiers CSV|`-NoTypeInformation`, `-Append`, `-Force`|
|**ConvertFrom-Csv**|String CSV → Objets|Manipulation en mémoire|
|**ConvertTo-Csv**|Objets → String CSV|Pas de fichier créé|

**Points essentiels à retenir** :

🔑 **Import-Csv convertit automatiquement en objets** : Chaque ligne devient un objet avec les en-têtes comme propriétés

🔑 **Toutes les valeurs sont des strings** : Convertissez explicitement les types avec `[int]`, `[datetime]`, etc.

🔑 **Spécifiez toujours le délimiteur si non standard** : Europe = `;`, US = `,`, TSV = tabulation

🔑 **Gestion de l'encodage cruciale** : UTF8 pour caractères internationaux, utf8NoBOM (PS7+) pour compatibilité

🔑 **Export-Csv écrase par défaut** : Utilisez `-Append` pour ajouter, faites des backups

🔑 **Convert vs Import/Export** : `Convert` pour manipulation en mémoire, `Import/Export` pour fichiers

---

## 💡 Cas d'usage réels

### Exemple 1 : Analyse de logs

```powershell
# Import et analyse de logs d'accès web
$logs = Import-Csv "access_log.csv" -Delimiter " " | ForEach-Object {
    [PSCustomObject]@{
        IP = $_.IP
        Date = [datetime]$_.Timestamp
        StatusCode = [int]$_.Status
        BytesSent = [int]$_.Bytes
        UserAgent = $_.UserAgent
    }
}

# Statistiques
$stats = $logs | Group-Object -Property StatusCode | Select-Object Name, Count
$stats | Export-Csv "stats_by_status.csv" -NoTypeInformation

# Top 10 des IPs par requêtes
$logs | Group-Object IP | 
    Sort-Object Count -Descending | 
    Select-Object -First 10 Name, Count |
    Export-Csv "top_ips.csv" -NoTypeInformation
```

### Exemple 2 : Gestion d'utilisateurs

```powershell
# Import d'utilisateurs depuis HR
$hrUsers = Import-Csv "hr_export.csv" -Delimiter ";" -Encoding UTF8

# Enrichissement avec données AD (mention seulement, pas développé)
$enrichedUsers = $hrUsers | ForEach-Object {
    [PSCustomObject]@{
        Nom = $_.Nom
        Prénom = $_.Prénom
        Email = "$($_.Prénom.ToLower()).$($_.Nom.ToLower())@company.com"
        Département = $_.Département
        DateEmbauche = [datetime]$_.DateEmbauche
        Status = "Actif"
    }
}

# Export pour import dans système tiers
$enrichedUsers | Export-Csv "users_for_import.csv" -NoTypeInformation -Encoding UTF8
```

### Exemple 3 : Reporting consolidé

```powershell
# Consolidation de rapports mensuels
$allReports = @()

Get-ChildItem "C:\Reports\2024\*.csv" | ForEach-Object {
    $monthData = Import-Csv $_.FullName
    $allReports += $monthData
}

# Calculs agrégés
$summary = $allReports | Group-Object Département | ForEach-Object {
    $total = ($_.Group | Measure-Object -Property Ventes -Sum).Sum
    
    [PSCustomObject]@{
        Département = $_.Name
        NombreVentes = $_.Count
        TotalVentes = $total
        Moyenne = [math]::Round($total / $_.Count, 2)
    }
}

# Export du rapport consolidé
$summary | Sort-Object TotalVentes -Descending |
    Export-Csv "rapport_annuel_2024.csv" -NoTypeInformation -Delimiter ";"
```

### Exemple 4 : Data cleaning et normalisation

```powershell
# Import de données "sales" avec nettoyage
$rawData = Import-Csv "raw_sales.csv"

$cleanedData = $rawData | ForEach-Object {
    # Nettoyage et normalisation
    [PSCustomObject]@{
        Date = [datetime]::ParseExact($_.Date, "dd/MM/yyyy", $null)
        Client = $_.Client.Trim().ToUpper()
        Montant = [decimal]$_.Montant.Replace("€", "").Replace(",", ".")
        Statut = switch ($_.Statut.ToLower()) {
            "payé" { "PAID" }
            "en attente" { "PENDING" }
            "annulé" { "CANCELLED" }
            default { "UNKNOWN" }
        }
        Email = $_.Email.Trim().ToLower()
    }
} | Where-Object { $_.Email -match "^[\w\.-]+@[\w\.-]+\.\w+$" }  # Validation email

$cleanedData | Export-Csv "sales_cleaned.csv" -NoTypeInformation
```

### Exemple 5 : Comparaison avant/après

```powershell
# Comparer deux exports pour détecter les changements
$avant = Import-Csv "inventory_before.csv"
$apres = Import-Csv "inventory_after.csv"

# Créer des hashtables pour comparaison rapide
$avantHash = @{}
$avant | ForEach-Object { $avantHash[$_.ID] = $_ }

# Identifier les changements
$changements = $apres | ForEach-Object {
    $current = $_
    $previous = $avantHash[$current.ID]
    
    if ($previous) {
        if ($current.Quantite -ne $previous.Quantite) {
            [PSCustomObject]@{
                ID = $current.ID
                Produit = $current.Produit
                QuantiteAvant = [int]$previous.Quantite
                QuantiteApres = [int]$current.Quantite
                Difference = [int]$current.Quantite - [int]$previous.Quantite
                Type = if ([int]$current.Quantite -gt [int]$previous.Quantite) { "Entrée" } else { "Sortie" }
            }
        }
    }
}

$changements | Export-Csv "inventory_changes.csv" -NoTypeInformation
```

---

## 🚀 Astuces avancées

### Astuce 1 : Lecture en streaming pour gros fichiers

```powershell
# Pour fichiers > 100 MB : éviter de tout charger en mémoire
$reader = [System.IO.StreamReader]::new("huge_file.csv")
$header = $reader.ReadLine() -split ","

$count = 0
while ($null -ne ($line = $reader.ReadLine())) {
    $fields = $line -split ","
    
    # Traiter la ligne
    $count++
    
    if ($count % 10000 -eq 0) {
        Write-Progress -Activity "Traitement" -Status "$count lignes traitées"
    }
}
$reader.Close()
```

### Astuce 2 : Export avec formatage personnalisé

```powershell
# Créer un CSV avec colonnes formatées
$data = Get-Process | Select-Object -First 10

$formatted = $data | Select-Object @{
    Name = "Nom"
    Expression = { $_.Name }
}, @{
    Name = "Mémoire (MB)"
    Expression = { [math]::Round($_.WS / 1MB, 2) }
}, @{
    Name = "CPU (%)"
    Expression = { [math]::Round($_.CPU, 2) }
}, @{
    Name = "Threads"
    Expression = { $_.Threads.Count }
}

$formatted | Export-Csv "processes_formatted.csv" -NoTypeInformation -Delimiter ";"
```

### Astuce 3 : Validation des données avant import

```powershell
function Test-CsvFormat {
    param([string]$Path)
    
    try {
        $sample = Get-Content $Path -First 2
        
        if ($sample.Count -lt 2) {
            throw "Fichier trop court"
        }
        
        $headerCount = ($sample[0] -split ",").Count
        $dataCount = ($sample[1] -split ",").Count
        
        if ($headerCount -ne $dataCount) {
            throw "Nombre de colonnes incohérent : Header=$headerCount, Data=$dataCount"
        }
        
        Write-Host "✓ Format valide : $headerCount colonnes détectées"
        return $true
        
    } catch {
        Write-Error "Format CSV invalide : $_"
        return $false
    }
}

# Utilisation
if (Test-CsvFormat "data.csv") {
    $data = Import-Csv "data.csv"
}
```

### Astuce 4 : Export multi-feuilles (simulé)

```powershell
# Créer plusieurs CSV pour simuler un workbook Excel
$data = Import-Csv "all_data.csv"

# Séparer par catégorie
$groupes = $data | Group-Object -Property Catégorie

$groupes | ForEach-Object {
    $filename = "export_$($_.Name).csv"
    $_.Group | Export-Csv $filename -NoTypeInformation
    Write-Host "✓ Créé : $filename ($($_.Count) lignes)"
}
```

### Astuce 5 : Conversion CSV ↔ JSON ↔ XML

```powershell
# CSV → JSON
$csv = Import-Csv "data.csv"
$csv | ConvertTo-Json -Depth 10 | Out-File "data.json"

# JSON → CSV
$json = Get-Content "data.json" | ConvertFrom-Json
$json | Export-Csv "data_from_json.csv" -NoTypeInformation

# CSV → XML
$csv = Import-Csv "data.csv"
$csv | Export-Clixml "data.xml"

# XML → CSV
$xml = Import-Clixml "data.xml"
$xml | Export-Csv "data_from_xml.csv" -NoTypeInformation
```

---

**Le cours est maintenant complet ! 🎉**

Vous maîtrisez désormais :

- ✅ Import et export de fichiers CSV
- ✅ Conversion en mémoire avec ConvertTo/From-Csv
- ✅ Manipulation de données tabulaires
- ✅ Gestion des pièges courants
- ✅ Cas d'usage pratiques et astuces avancées