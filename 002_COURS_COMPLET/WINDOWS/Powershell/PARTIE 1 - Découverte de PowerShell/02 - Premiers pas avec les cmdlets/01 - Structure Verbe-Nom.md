
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

## 🔍 Introduction à la convention Verbe-Nom

PowerShell utilise une convention de nommage stricte et standardisée appelée **Verb-Noun** (Verbe-Nom) pour toutes ses commandes natives appelées **cmdlets**.

> [!info] Pourquoi cette convention ? Cette standardisation permet une cohérence dans l'apprentissage et l'utilisation de PowerShell. Une fois que vous connaissez les verbes principaux, vous pouvez deviner intuitivement le nom de nombreuses commandes.

### Principe fondamental

Chaque cmdlet PowerShell suit le format :

```
Verbe-Nom
```

- **Verbe** : Action à effectuer (toujours au singulier en anglais)
- **Nom** : Objet sur lequel agir (toujours au singulier)
- **Séparateur** : Tiret obligatoire entre les deux

> [!example] Exemples simples
> 
> - `Get-Process` : **Obtenir** un processus
> - `Stop-Service` : **Arrêter** un service
> - `New-Item` : **Créer** un élément
> - `Remove-User` : **Supprimer** un utilisateur

---

## 🧩 Anatomie d'une cmdlet

### Structure complète

```powershell
# Format de base
Verbe-Nom

# Avec paramètres
Verbe-Nom -Paramètre1 Valeur1 -Paramètre2 Valeur2

# Exemple concret
Get-Process -Name "chrome" -ComputerName "SERVER01"
```

### Décomposition d'une cmdlet

|Composant|Description|Exemple|
|---|---|---|
|**Verbe**|Action standardisée|`Get`, `Set`, `New`, `Remove`|
|**Nom**|Objet cible (singulier)|`Process`, `Service`, `Item`, `User`|
|**Tiret**|Séparateur obligatoire|`-`|
|**Paramètres**|Options précédées de `-`|`-Name`, `-Path`, `-Force`|

> [!tip] Sensibilité à la casse PowerShell n'est **pas sensible à la casse** pour les cmdlets. `Get-Process`, `get-process` et `GET-PROCESS` sont équivalents. Cependant, par convention, on utilise la casse Pascal (majuscule à chaque mot).

---

## ✅ Les verbes approuvés

PowerShell maintient une liste officielle de verbes approuvés pour garantir la cohérence. Ces verbes sont organisés en groupes fonctionnels.

### Obtenir la liste complète

```powershell
# Afficher tous les verbes approuvés
Get-Verb

# Filtrer par groupe
Get-Verb -Group Security

# Rechercher un verbe spécifique
Get-Verb -Verb Get
```

### Verbes les plus courants par catégorie

#### 📥 **Common (Communs)**

|Verbe|Description|Exemples|
|---|---|---|
|`Get`|Récupérer une ressource|`Get-Process`, `Get-Service`|
|`Set`|Modifier une ressource|`Set-Location`, `Set-Content`|
|`New`|Créer une nouvelle ressource|`New-Item`, `New-User`|
|`Remove`|Supprimer une ressource|`Remove-Item`, `Remove-User`|
|`Add`|Ajouter à une collection|`Add-Content`, `Add-Member`|
|`Clear`|Vider/Effacer le contenu|`Clear-Content`, `Clear-History`|
|`Copy`|Copier une ressource|`Copy-Item`, `Copy-File`|
|`Find`|Rechercher une ressource|`Find-Module`, `Find-Package`|
|`Move`|Déplacer une ressource|`Move-Item`, `Move-File`|
|`Read`|Lire depuis une source|`Read-Host`, `Read-Content`|
|`Write`|Écrire vers une destination|`Write-Host`, `Write-Output`|

#### 🔧 **Lifecycle (Cycle de vie)**

|Verbe|Description|Exemples|
|---|---|---|
|`Start`|Démarrer une opération|`Start-Process`, `Start-Service`|
|`Stop`|Arrêter une opération|`Stop-Process`, `Stop-Service`|
|`Restart`|Redémarrer|`Restart-Service`, `Restart-Computer`|
|`Suspend`|Suspendre/Mettre en pause|`Suspend-Service`, `Suspend-Job`|
|`Resume`|Reprendre après suspension|`Resume-Service`, `Resume-Job`|

#### 🔐 **Security (Sécurité)**

|Verbe|Description|Exemples|
|---|---|---|
|`Grant`|Accorder un accès|`Grant-Permission`, `Grant-Access`|
|`Revoke`|Révoquer un accès|`Revoke-Permission`, `Revoke-Certificate`|
|`Protect`|Protéger une ressource|`Protect-String`, `Protect-File`|
|`Unprotect`|Retirer la protection|`Unprotect-String`, `Unprotect-File`|
|`Block`|Bloquer l'accès|`Block-User`, `Block-Connection`|
|`Unblock`|Débloquer|`Unblock-File`, `Unblock-User`|

#### 📊 **Data (Données)**

|Verbe|Description|Exemples|
|---|---|---|
|`Convert`|Convertir d'un format à un autre|`ConvertTo-Json`, `ConvertFrom-Csv`|
|`Import`|Importer des données|`Import-Csv`, `Import-Module`|
|`Export`|Exporter des données|`Export-Csv`, `Export-Clixml`|
|`Compare`|Comparer des objets|`Compare-Object`, `Compare-Content`|
|`Measure`|Mesurer des propriétés|`Measure-Object`, `Measure-Command`|
|`Select`|Sélectionner des propriétés|`Select-Object`, `Select-String`|
|`Sort`|Trier des objets|`Sort-Object`|
|`Group`|Grouper des objets|`Group-Object`|

#### ⚙️ **Diagnostic (Diagnostique)**

|Verbe|Description|Exemples|
|---|---|---|
|`Test`|Tester/Vérifier une condition|`Test-Path`, `Test-Connection`|
|`Debug`|Déboguer|`Debug-Process`, `Debug-Runspace`|
|`Trace`|Tracer l'exécution|`Trace-Command`|

#### 🔄 **Communications**

|Verbe|Description|Exemples|
|---|---|---|
|`Connect`|Établir une connexion|`Connect-PSSession`, `Connect-Server`|
|`Disconnect`|Fermer une connexion|`Disconnect-PSSession`|
|`Send`|Envoyer des données|`Send-MailMessage`, `Send-Notification`|
|`Receive`|Recevoir des données|`Receive-Job`, `Receive-Message`|

> [!info] Verbes non approuvés Si vous créez vos propres fonctions, PowerShell vous avertira si vous utilisez un verbe non approuvé. Bien que cela fonctionne, il est fortement recommandé d'utiliser uniquement les verbes officiels.

---

## 🎯 Avantages de la standardisation

### 1. **Prévisibilité et cohérence**

Une fois que vous connaissez la logique, vous pouvez deviner le nom des commandes :

```powershell
# Si vous connaissez Get-Service...
Get-Service      # Lister les services

# Vous pouvez deviner :
Start-Service    # Démarrer un service
Stop-Service     # Arrêter un service
Restart-Service  # Redémarrer un service
Set-Service      # Modifier un service
```

### 2. **Découvrabilité facilitée**

```powershell
# Trouver toutes les commandes liées aux processus
Get-Command -Noun Process

# Résultat :
# Get-Process
# Start-Process
# Stop-Process
# Wait-Process
# Debug-Process
```

```powershell
# Trouver toutes les commandes qui "obtiennent" quelque chose
Get-Command -Verb Get

# Trier par module
Get-Command -Verb Get | Group-Object ModuleName
```

### 3. **Apprentissage progressif**

Vous n'avez pas besoin de mémoriser des centaines de commandes. Apprenez les verbes, puis explorez les noms.

> [!tip] Stratégie d'apprentissage
> 
> 1. Maîtrisez les 10 verbes les plus courants (`Get`, `Set`, `New`, `Remove`, `Start`, `Stop`, `Test`, `Add`, `Copy`, `Move`)
> 2. Découvrez les noms pertinents à votre domaine (Process, Service, Item, User, etc.)
> 3. Combinez-les logiquement

### 4. **Documentation cohérente**

Tous les modules PowerShell bien écrits suivent cette convention, ce qui rend la documentation plus intuitive.

### 5. **Interopérabilité entre modules**

Différents modules utilisent les mêmes verbes pour des actions similaires :

```powershell
# Active Directory
Get-ADUser

# Azure
Get-AzVM

# Exchange
Get-Mailbox

# Tous utilisent "Get" pour récupérer des informations
```

---

## 📚 Exemples de cmdlets courantes

### Gestion des fichiers et dossiers

```powershell
# Obtenir des éléments (fichiers/dossiers)
Get-Item "C:\Users"
Get-ChildItem "C:\Users" -Recurse

# Créer un nouveau fichier ou dossier
New-Item -Path "C:\Temp\test.txt" -ItemType File
New-Item -Path "C:\Temp\Dossier" -ItemType Directory

# Copier des éléments
Copy-Item "C:\Source\fichier.txt" -Destination "C:\Dest\"

# Déplacer des éléments
Move-Item "C:\Temp\fichier.txt" -Destination "C:\Archive\"

# Supprimer des éléments
Remove-Item "C:\Temp\fichier.txt" -Force

# Renommer des éléments
Rename-Item "C:\Temp\ancien.txt" -NewName "nouveau.txt"

# Tester l'existence d'un chemin
Test-Path "C:\Temp\fichier.txt"
```

### Gestion des processus

```powershell
# Lister les processus en cours
Get-Process

# Obtenir un processus spécifique
Get-Process -Name "chrome"

# Démarrer un nouveau processus
Start-Process "notepad.exe"

# Arrêter un processus
Stop-Process -Name "notepad" -Force

# Attendre la fin d'un processus
Wait-Process -Name "chrome"
```

### Gestion des services

```powershell
# Lister tous les services
Get-Service

# Obtenir un service spécifique
Get-Service -Name "wuauserv"  # Windows Update

# Démarrer un service
Start-Service -Name "wuauserv"

# Arrêter un service
Stop-Service -Name "wuauserv"

# Redémarrer un service
Restart-Service -Name "wuauserv"

# Modifier la configuration d'un service
Set-Service -Name "wuauserv" -StartupType Manual
```

### Gestion du contenu

```powershell
# Lire le contenu d'un fichier
Get-Content "C:\Logs\app.log"

# Écrire dans un fichier (écrase le contenu)
Set-Content -Path "C:\Temp\file.txt" -Value "Nouveau contenu"

# Ajouter à un fichier
Add-Content -Path "C:\Temp\file.txt" -Value "Ligne supplémentaire"

# Vider un fichier
Clear-Content -Path "C:\Temp\file.txt"
```

### Gestion de la localisation

```powershell
# Obtenir la localisation actuelle
Get-Location

# Changer de répertoire
Set-Location "C:\Users"

# Revenir au répertoire précédent
Set-Location -

# Empiler la localisation actuelle
Push-Location "C:\Temp"

# Revenir à la localisation empilée
Pop-Location
```

### Manipulation d'objets

```powershell
# Sélectionner des propriétés spécifiques
Get-Process | Select-Object Name, CPU, Memory

# Filtrer des objets
Get-Service | Where-Object {$_.Status -eq "Running"}

# Trier des objets
Get-Process | Sort-Object CPU -Descending

# Grouper des objets
Get-Service | Group-Object Status

# Mesurer des objets
Get-ChildItem | Measure-Object -Property Length -Sum
```

### Conversion de données

```powershell
# Convertir en JSON
Get-Process | Select-Object Name, CPU | ConvertTo-Json

# Convertir depuis JSON
$json = '{"Name":"Test","Value":123}'
$json | ConvertFrom-Json

# Convertir en CSV
Get-Service | Export-Csv "C:\Temp\services.csv" -NoTypeInformation

# Convertir depuis CSV
Import-Csv "C:\Temp\services.csv"

# Convertir en HTML
Get-Process | ConvertTo-Html | Out-File "C:\Temp\processes.html"
```

### Diagnostic et tests

```powershell
# Tester une connexion réseau
Test-Connection "google.com"

# Tester l'existence d'un chemin
Test-Path "C:\Windows\System32"

# Mesurer le temps d'exécution d'une commande
Measure-Command { Get-ChildItem C:\ -Recurse }

# Comparer deux objets
Compare-Object -ReferenceObject (Get-Content file1.txt) -DifferenceObject (Get-Content file2.txt)
```

---

## ⚠️ Pièges courants

### 1. Utiliser le pluriel au lieu du singulier

```powershell
# ❌ INCORRECT - Le nom doit être au singulier
Get-Processes    # Cette commande n'existe pas

# ✅ CORRECT
Get-Process      # Même si elle retourne plusieurs processus
```

> [!warning] Attention au pluriel Même si la commande retourne plusieurs objets, le nom est **toujours au singulier** dans PowerShell.

### 2. Oublier le tiret

```powershell
# ❌ INCORRECT
GetProcess       # N'est pas une cmdlet valide

# ✅ CORRECT
Get-Process
```

### 3. Utiliser des verbes non standardisés

```powershell
# ❌ DÉCONSEILLÉ - Verbes non approuvés
Retrieve-Data    # Utiliser Get au lieu de Retrieve
Delete-File      # Utiliser Remove au lieu de Delete
Create-Item      # Utiliser New au lieu de Create

# ✅ RECOMMANDÉ
Get-Data
Remove-File
New-Item
```

### 4. Confusion entre cmdlets similaires

```powershell
# Get-Content vs Get-Item
Get-Content "file.txt"   # ✅ Lit le CONTENU du fichier
Get-Item "file.txt"      # ✅ Obtient l'OBJET fichier (métadonnées)

# Set-Content vs Set-Item
Set-Content "file.txt" "texte"   # ✅ Définit le CONTENU du fichier
Set-Item "file.txt" -Value ...   # ❌ Rarement utilisé pour les fichiers
```

### 5. Ne pas respecter la casse dans les scripts

Bien que PowerShell ne soit pas sensible à la casse, il est recommandé d'utiliser la casse Pascal pour la lisibilité :

```powershell
# ❌ Lisibilité réduite
get-childitem | where-object {$_.length -gt 1000}

# ✅ Meilleure lisibilité
Get-ChildItem | Where-Object {$_.Length -gt 1000}
```

---

## 💡 Bonnes pratiques

### 1. Explorez avant d'utiliser

```powershell
# Découvrez les commandes disponibles pour un nom
Get-Command -Noun Service

# Obtenez l'aide complète
Get-Help Get-Service -Full

# Voyez des exemples pratiques
Get-Help Get-Service -Examples
```

### 2. Utilisez l'auto-complétion

Tapez les premières lettres et appuyez sur **Tab** pour compléter automatiquement :

```powershell
Get-Proc[Tab]     # Complète en Get-Process
Get-S[Tab]        # Cycle entre Get-Service, Get-Status, etc.
```

### 3. Respectez la convention dans vos fonctions

Si vous créez vos propres fonctions, suivez la même convention :

```powershell
# ✅ CORRECT
function Get-UserData {
    # Votre code
}

# ❌ INCORRECT
function RetrieveUsers {
    # Verbe non approuvé
}
```

### 4. Combinez avec le pipeline

PowerShell est conçu pour chaîner les cmdlets :

```powershell
# Exemple : Arrêter tous les processus Chrome
Get-Process -Name "chrome" | Stop-Process -Force

# Exemple : Exporter les services arrêtés
Get-Service | Where-Object {$_.Status -eq "Stopped"} | Export-Csv "services.csv"
```

### 5. Documentez vos découvertes

Créez un fichier de référence avec vos cmdlets préférées :

```powershell
# Mes cmdlets essentielles

# Fichiers
Get-ChildItem, New-Item, Copy-Item, Move-Item, Remove-Item

# Processus
Get-Process, Start-Process, Stop-Process

# Services
Get-Service, Start-Service, Stop-Service, Restart-Service

# Contenu
Get-Content, Set-Content, Add-Content
```

---

> [!tip] Astuce finale La maîtrise de la structure Verbe-Nom est la **fondation** de votre apprentissage PowerShell. Investissez du temps à comprendre cette logique, et vous serez capable de deviner intuitivement 80% des commandes dont vous aurez besoin !