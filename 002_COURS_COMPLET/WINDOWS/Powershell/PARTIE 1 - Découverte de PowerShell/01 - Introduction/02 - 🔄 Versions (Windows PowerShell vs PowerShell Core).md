

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

## 🪟 Windows PowerShell 5.1

### Présentation

Windows PowerShell 5.1 est la **dernière version de Windows PowerShell**, basée sur le .NET Framework. Elle est pré-installée sur Windows 10 et Windows Server 2016/2019.

> [!info] Fin du développement Microsoft a annoncé que Windows PowerShell 5.1 ne recevra plus de nouvelles fonctionnalités. Seules des corrections de bugs critiques et de sécurité sont fournies.

### Caractéristiques principales

- **Framework** : .NET Framework 4.5+
- **Plateforme** : Windows uniquement
- **Installation** : Intégré nativement dans Windows
- **Exécutable** : `powershell.exe`
- **Emplacement** : `C:\Windows\System32\WindowsPowerShell\v1.0\`

### Points forts

- **Maturité** : Stable et éprouvé depuis des années
- **Compatibilité legacy** : Supporte tous les anciens scripts et modules Windows
- **Intégration Windows** : Accès complet à toutes les fonctionnalités Windows (WMI, COM, etc.)
- **Modules Windows** : Accès natif aux modules d'administration Windows (ActiveDirectory, Hyper-V, etc.)

### Limitations

- **Plateforme unique** : Ne fonctionne que sur Windows
- **Framework obsolescent** : Basé sur .NET Framework qui n'évolue plus
- **Pas de nouvelles fonctionnalités** : Développement arrêté
- **Performance** : Moins optimisé que PowerShell 7

```powershell
# Exemple de fonctionnalité Windows PowerShell 5.1
# Accès aux modules Windows natifs
Import-Module ActiveDirectory
Get-ADUser -Filter *
```

---

## 🌐 PowerShell Core 6.x et PowerShell 7.x

### PowerShell Core 6.x (2018-2020)

PowerShell Core 6.x a marqué une **révolution** dans l'écosystème PowerShell en devenant multiplateforme et open-source.

> [!warning] Version transitoire PowerShell Core 6.x était une version de transition. Microsoft recommande maintenant de migrer directement vers PowerShell 7.x.

**Caractéristiques PowerShell Core 6.x** :

- **Framework** : .NET Core 2.x/3.x
- **Open-source** : Code disponible sur GitHub
- **Multiplateforme** : Windows, Linux, macOS
- **Exécutable** : `pwsh` ou `pwsh.exe`
- **Installation** : Séparée, coexiste avec Windows PowerShell

### PowerShell 7.x (2020-présent)

PowerShell 7 est la **version moderne et recommandée** de PowerShell. Elle combine les avantages de Windows PowerShell et PowerShell Core.

> [!tip] Version recommandée Microsoft recommande PowerShell 7.x pour tous les nouveaux projets et scripts. C'est le futur de PowerShell.

**Caractéristiques PowerShell 7.x** :

- **Framework** : .NET 5+ (maintenant .NET 8 pour PS 7.4+)
- **Compatibilité améliorée** : Meilleure compatibilité avec Windows PowerShell 5.1
- **Performance** : Nettement plus rapide que les versions précédentes
- **Nouvelles fonctionnalités** : Opérateurs ternaires, null coalescing, pipeline parallèle, etc.
- **Support LTS** : Versions avec support à long terme (7.2 LTS, 7.4 LTS)

```powershell
# Exemple de fonctionnalité PowerShell 7
# Opérateur ternaire (disponible uniquement en PS 7+)
$status = $age -ge 18 ? "Adulte" : "Mineur"

# Pipeline parallèle (PS 7+)
1..10 | ForEach-Object -Parallel {
    Start-Sleep -Seconds 1
    "Traitement de $_"
}

# Null coalescing (PS 7+)
$value = $null ?? "Valeur par défaut"
```

### Versions de PowerShell 7

|Version|Date sortie|Framework|Support|Notes|
|---|---|---|---|---|
|7.0|Mars 2020|.NET Core 3.1|Terminé|Première version PS 7|
|7.1|Novembre 2020|.NET 5|Terminé|Améliorations performance|
|7.2 LTS|Novembre 2021|.NET 6|Jusqu'à fin 2024|Support long terme|
|7.3|Novembre 2022|.NET 7|Terminé|Fonctionnalités experimentales|
|7.4 LTS|Novembre 2023|.NET 8|Jusqu'à novembre 2026|Version LTS actuelle|
|7.5|Novembre 2024|.NET 9|Jusqu'à mai 2026|Version actuelle|

> [!tip] Versions LTS Les versions LTS (Long Term Support) sont recommandées pour les environnements de production. Elles reçoivent des mises à jour de sécurité pendant 3 ans.

---

## ⚖️ Différences principales entre les versions

### Tableau comparatif global

|Critère|Windows PowerShell 5.1|PowerShell 7.x|
|---|---|---|
|**Plateforme**|Windows uniquement|Windows, Linux, macOS|
|**Framework**|.NET Framework 4.5+|.NET 5+|
|**Développement**|Arrêté (maintenance uniquement)|Actif avec nouvelles fonctionnalités|
|**Open-source**|❌ Non|✅ Oui (GitHub)|
|**Performance**|Correcte|Excellente (jusqu'à 2-3x plus rapide)|
|**Modules Windows**|Tous natifs|Certains via compatibilité|
|**Syntaxe moderne**|Limitée|Complète (opérateurs C#, etc.)|
|**Déploiement**|Intégré Windows|Installation séparée|

### Différences techniques majeures

#### 1. **Syntaxe et opérateurs**

```powershell
# ❌ Windows PowerShell 5.1 - Syntaxe verbose
$result = if ($age -ge 18) { "Adulte" } else { "Mineur" }

# ✅ PowerShell 7 - Opérateur ternaire
$result = $age -ge 18 ? "Adulte" : "Mineur"

# ❌ Windows PowerShell 5.1 - Gestion du null
if ($variable -eq $null) {
    $variable = "Défaut"
}

# ✅ PowerShell 7 - Null coalescing
$variable = $variable ?? "Défaut"
```

#### 2. **Performance et parallélisme**

```powershell
# Windows PowerShell 5.1 - Traitement séquentiel
1..100 | ForEach-Object {
    Invoke-WebRequest "https://api.exemple.com/item/$_"
}
# Durée : ~100 secondes (1s par requête)

# PowerShell 7 - Traitement parallèle
1..100 | ForEach-Object -Parallel -ThrottleLimit 10 {
    Invoke-WebRequest "https://api.exemple.com/item/$_"
}
# Durée : ~10 secondes (10 requêtes simultanées)
```

#### 3. **Gestion des erreurs améliorée**

```powershell
# PowerShell 7 - ErrorView amélioré
$ErrorView = 'ConciseView'  # Vue condensée des erreurs
# Affichage plus clair et moins verbeux des erreurs

# PowerShell 7 - Get-Error détaillé
Get-Error  # Informations détaillées sur la dernière erreur
```

#### 4. **Compatibilité des modules**

> [!warning] Attention aux modules Windows Certains modules Windows PowerShell ne fonctionnent pas nativement dans PowerShell 7 car ils dépendent du .NET Framework.

**Solution de compatibilité** :

```powershell
# PowerShell 7 - Utilisation du module de compatibilité
Import-Module ActiveDirectory -UseWindowsPowerShell

# Liste des modules nécessitant la compatibilité
Get-Module -ListAvailable -SkipEditionCheck
```

### Fonctionnalités exclusives à PowerShell 7

|Fonctionnalité|Description|Exemple|
|---|---|---|
|**Opérateur ternaire**|Condition en une ligne|`$x = $a ? $b : $c`|
|**Null coalescing**|Valeur par défaut si null|`$x = $a ?? "défaut"`|
|**Pipeline parallèle**|Traitement parallèle|`ForEach-Object -Parallel`|
|**Chain operators**|Enchaînement conditionnel|`cmd1 && cmd2` ou `cmd1 \| cmd2`|
|**Improved JSON**|Meilleure gestion JSON|`-Depth` illimité|
|**Get-Error**|Analyse erreurs détaillée|Diagnostique avancé|

---

## 🔄 Compatibilité et migration

### Coexistence des versions

> [!info] Installation côte à côte Windows PowerShell 5.1 et PowerShell 7 peuvent coexister sur le même système sans conflit. Ils utilisent des exécutables différents (`powershell.exe` vs `pwsh.exe`).

**Emplacements des exécutables** :

```powershell
# Windows PowerShell 5.1
C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe

# PowerShell 7 (installation par défaut)
C:\Program Files\PowerShell\7\pwsh.exe
```

### Stratégies de migration

#### 1. **Évaluation de la compatibilité**

```powershell
# Tester un script en PowerShell 7
# Depuis PowerShell 7
pwsh -File MonScript.ps1

# Analyser les problèmes de compatibilité
# Utiliser PSScriptAnalyzer
Install-Module -Name PSScriptAnalyzer
Invoke-ScriptAnalyzer -Path .\MonScript.ps1 -Settings PSGallery
```

#### 2. **Migration progressive**

> [!tip] Approche recommandée Migrer progressivement en commençant par les scripts les moins critiques et en testant soigneusement chaque étape.

**Ordre de migration suggéré** :

1. Scripts de reporting et d'analyse (faible risque)
2. Scripts d'automatisation non critiques
3. Modules personnalisés
4. Scripts de production critiques
5. Tâches planifiées

#### 3. **Gestion des modules incompatibles**

```powershell
# Vérifier la compatibilité d'un module
Get-Module -Name ActiveDirectory -ListAvailable | 
    Select-Object Name, Version, CompatiblePSEditions

# Utiliser la compatibilité Windows PowerShell
# PowerShell 7 peut charger des modules PS 5.1 via WinPSCompatSession
Import-Module ActiveDirectory -UseWindowsPowerShell

# Vérifier si on est en mode compatibilité
Get-PSSession | Where-Object Name -like 'WinPSCompat*'
```

### Pièges courants lors de la migration

> [!warning] Attention aux différences subtiles

**1. Variables automatiques différentes** :

```powershell
# $IsWindows, $IsLinux, $IsMacOS n'existent pas en PS 5.1
# Solution : Vérifier avant utilisation
if (Get-Variable -Name IsWindows -ErrorAction SilentlyContinue) {
    if ($IsWindows) { "Windows" }
}
```

**2. Comportement JSON** :

```powershell
# PS 5.1 : Profondeur limitée par défaut (2 niveaux)
$json = Get-Content data.json | ConvertFrom-Json

# PS 7 : Profondeur illimitée par défaut
$json = Get-Content data.json | ConvertFrom-Json

# Solution : Spécifier -Depth pour compatibilité
ConvertFrom-Json -Depth 100
```

**3. Encodage des fichiers** :

```powershell
# PS 5.1 : UTF-16 LE par défaut
"Texte" | Out-File fichier.txt

# PS 7 : UTF-8 sans BOM par défaut
"Texte" | Out-File fichier.txt

# Solution : Spécifier explicitement l'encodage
"Texte" | Out-File fichier.txt -Encoding UTF8
```

---

## 🔍 Vérifier sa version

### Commande $PSVersionTable

La variable automatique `$PSVersionTable` contient toutes les informations sur la version de PowerShell.

```powershell
# Afficher toutes les informations de version
$PSVersionTable

# Résultat typique Windows PowerShell 5.1 :
<#
Name                           Value
----                           -----
PSVersion                      5.1.19041.5247
PSEdition                      Desktop
PSCompatibleVersions           {1.0, 2.0, 3.0, 4.0...}
BuildVersion                   10.0.19041.5247
CLRVersion                     4.0.30319.42000
WSManStackVersion              3.0
PSRemotingProtocolVersion      2.3
SerializationVersion           1.1.0.1
#>

# Résultat typique PowerShell 7.4 :
<#
Name                           Value
----                           -----
PSVersion                      7.4.6
PSEdition                      Core
GitCommitId                    7.4.6
OS                             Microsoft Windows 10.0.19045
Platform                       Win32NT
PSCompatibleVersions           {1.0, 2.0, 3.0, 4.0…}
PSRemotingProtocolVersion      2.3
SerializationVersion           1.1.0.1
WSManStackVersion              3.0
#>
```

### Vérifications spécifiques

```powershell
# Obtenir uniquement le numéro de version
$PSVersionTable.PSVersion

# Version sous forme de chaîne
$PSVersionTable.PSVersion.ToString()
# Résultat : "7.4.6" ou "5.1.19041.5247"

# Vérifier l'édition (Desktop = Windows PS, Core = PS 6+)
$PSVersionTable.PSEdition
# Résultat : "Desktop" ou "Core"

# Tester si on est en PowerShell 7+
if ($PSVersionTable.PSVersion.Major -ge 7) {
    "PowerShell 7 ou supérieur"
}

# Tester si on est en Windows PowerShell
if ($PSVersionTable.PSEdition -eq 'Desktop') {
    "Windows PowerShell"
}
```

### Vérification programmatique pour compatibilité

```powershell
# Fonction pour vérifier la version minimale requise
function Test-PSVersion {
    param(
        [Version]$MinimumVersion = "5.1"
    )
    
    $currentVersion = $PSVersionTable.PSVersion
    
    if ($currentVersion -lt $MinimumVersion) {
        Write-Warning "Version PowerShell insuffisante."
        Write-Warning "Requis : $MinimumVersion - Actuel : $currentVersion"
        return $false
    }
    
    return $true
}

# Utilisation dans un script
if (-not (Test-PSVersion -MinimumVersion "7.2")) {
    throw "Ce script nécessite PowerShell 7.2 ou supérieur"
}
```

### Vérifier depuis l'extérieur

```powershell
# Depuis CMD ou un autre shell
powershell -Command "$PSVersionTable.PSVersion"
pwsh -Command "$PSVersionTable.PSVersion"

# Depuis un script batch
powershell -NoProfile -Command "if ($PSVersionTable.PSVersion.Major -ge 7) { exit 0 } else { exit 1 }"
```

---

## 🎯 Quelle version choisir

### Arbre de décision

```
Nouveau projet ?
├─ Oui → PowerShell 7.x (LTS recommandé)
└─ Non → Projet existant ?
    ├─ Scripts Windows uniquement
    │   ├─ Modules Windows spécifiques requis ? → Windows PS 5.1
    │   └─ Sinon → Migrer vers PowerShell 7.x
    └─ Scripts multiplateforme → PowerShell 7.x obligatoire
```

### Recommandations par contexte

#### ✅ Choisir PowerShell 7.x dans ces cas

> [!tip] PowerShell 7.x est recommandé pour

**1. Nouveaux projets et scripts**

- Développement moderne avec syntaxe actuelle
- Performance optimale
- Support continu et nouvelles fonctionnalités

**2. Environnements multiplateforme**

- Scripts devant tourner sur Linux/macOS
- Conteneurs Docker
- Infrastructure cloud (Azure, AWS, GCP)

**3. Automatisation moderne**

- DevOps et CI/CD (GitHub Actions, Azure Pipelines)
- Orchestration Kubernetes
- Infrastructure as Code (Terraform, Ansible)

**4. Performance critique**

- Traitement de gros volumes de données
- API REST et web scraping
- Traitements parallèles

**Exemple de cas d'usage** :

```powershell
# Script moderne PowerShell 7 - DevOps
# Déploiement multi-environnement avec parallélisme

$environments = @('dev', 'staging', 'prod')

$environments | ForEach-Object -Parallel -ThrottleLimit 3 {
    $env = $_
    $status = Invoke-RestMethod "https://api.app.com/$env/health"
    
    [PSCustomObject]@{
        Environment = $env
        Status      = $status.healthy ? "✅" : "❌"
        ResponseTime = $status.responseTime
    }
} | Format-Table -AutoSize
```

#### ⚠️ Rester sur Windows PowerShell 5.1 dans ces cas

> [!warning] Windows PowerShell 5.1 si

**1. Dépendances Windows critiques**

- Modules Windows non compatibles (certains modules Exchange, SCCM anciens)
- COM objects spécifiques
- Composants .NET Framework legacy

**2. Contraintes organisationnelles**

- Politique interdisant l'installation de logiciels
- Scripts legacy critiques sans ressources pour migration
- Support d'anciennes versions de Windows Server

**3. Intégration système profonde**

- Scripts Group Policy
- Scripts de démarrage système
- Tâches Windows intégrées nécessitant PowerShell 5.1

**Exemple de cas d'usage** :

```powershell
# Script nécessitant Windows PowerShell 5.1
# Administration Active Directory avec modules spécifiques

Import-Module ActiveDirectory
Import-Module GroupPolicy

# Certains cmdlets AD avancés peuvent avoir des comportements
# différents entre PS 5.1 et PS 7 avec -UseWindowsPowerShell
Get-ADUser -Filter * -Properties MemberOf, LastLogonDate |
    Export-Csv -Path "Users.csv" -NoTypeInformation
```

### Stratégie hybride (recommandée pour la transition)

> [!example] Approche pragmatique

**Utiliser les deux versions en parallèle** :

```powershell
# Script launcher intelligent
# Détecte automatiquement la meilleure version

$scriptPath = "C:\Scripts\MonScript.ps1"

# Vérifier si PowerShell 7 est disponible
$pwsh7 = Get-Command pwsh -ErrorAction SilentlyContinue

if ($pwsh7) {
    # Utiliser PowerShell 7 si disponible
    & pwsh -File $scriptPath
    Write-Host "Exécuté avec PowerShell 7" -ForegroundColor Green
} else {
    # Fallback sur Windows PowerShell 5.1
    & powershell -File $scriptPath
    Write-Host "Exécuté avec Windows PowerShell 5.1" -ForegroundColor Yellow
}
```

### Tableau récapitulatif des recommandations

|Critère|Windows PS 5.1|PowerShell 7.x|
|---|---|---|
|**Nouveaux projets**|❌ Non recommandé|✅ Fortement recommandé|
|**Scripts legacy**|✅ Conserver|⚠️ Migrer progressivement|
|**Multiplateforme**|❌ Impossible|✅ Obligatoire|
|**Performance**|⚠️ Acceptable|✅ Optimale|
|**Support futur**|⚠️ Maintenance seule|✅ Développement actif|
|**Modules Windows**|✅ Tous natifs|⚠️ Certains via compatibilité|
|**CI/CD moderne**|⚠️ Limité|✅ Excellent|
|**Conteneurs**|❌ Non adapté|✅ Idéal|

### Installation de PowerShell 7

```powershell
# Installation via winget (Windows 10/11)
winget install Microsoft.PowerShell

# Installation via Microsoft Store
# Rechercher "PowerShell" dans le Microsoft Store

# Installation via script officiel
iex "& { $(irm https://aka.ms/install-powershell.ps1) } -UseMSI"

# Vérification post-installation
pwsh -Command '$PSVersionTable'
```

> [!tip] Astuce pro Installer PowerShell 7 LTS pour les environnements de production afin de bénéficier d'un support à long terme (3 ans).

---

## 🎓 Bonnes pratiques

### 1. **Spécifier la version requise dans les scripts**

```powershell
#Requires -Version 7.2

# Le script s'arrêtera si la version est insuffisante
Write-Host "Script exécuté avec PowerShell 7.2+"
```

### 2. **Gérer la compatibilité multi-versions**

```powershell
# Détecter les fonctionnalités disponibles
$hasParallelForEach = Get-Command ForEach-Object -ParameterName Parallel -ErrorAction SilentlyContinue

if ($hasParallelForEach) {
    # Code PowerShell 7+
    1..10 | ForEach-Object -Parallel { "Item $_" }
} else {
    # Code compatible PS 5.1
    1..10 | ForEach-Object { "Item $_" }
}
```

### 3. **Documenter les dépendances**

```powershell
<#
.SYNOPSIS
    Script de traitement de données

.NOTES
    Version PowerShell requise : 7.2+
    Modules requis : Az.Accounts, Az.Storage
    Plateforme : Multiplateforme (Windows, Linux, macOS)
    
    Fonctionnalités utilisées :
    - Pipeline parallèle (PS 7+)
    - Opérateurs ternaires (PS 7+)
    - Null coalescing (PS 7+)
#>
```

---

## 🔑 Points clés à retenir

> [!info] Résumé essentiel

1. **Windows PowerShell 5.1** = Dernière version Windows uniquement, développement arrêté
2. **PowerShell 7.x** = Version moderne multiplateforme, développement actif, recommandée
3. **Coexistence possible** = Les deux versions peuvent tourner simultanément
4. **Migration progressive** = Tester et migrer par étapes, commencer par le non-critique
5. **$PSVersionTable** = Commande essentielle pour vérifier la version
6. **PowerShell 7 LTS** = Version avec support long terme pour la production (7.2 ou 7.4)
7. **Compatibilité modules** = Certains modules Windows nécessitent `-UseWindowsPowerShell`
8. **Nouveaux projets** = Toujours démarrer avec PowerShell 7.x
9. **Syntaxe moderne** = Opérateurs ternaires, null coalescing uniquement en PS 7+
10. **Performance** = PowerShell 7 significativement plus rapide (2-3x)