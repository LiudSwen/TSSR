

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

## 🌐 Introduction à PowerShell Gallery

### Qu'est-ce que PowerShell Gallery ?

PowerShell Gallery est le **repository public central** pour les modules et scripts PowerShell. C'est l'équivalent de npm pour Node.js ou PyPI pour Python.

> [!info] PowerShell Gallery
> 
> - URL officielle : [https://www.powershellgallery.com](https://www.powershellgallery.com/)
> - Contient des milliers de modules communautaires et officiels
> - Hébergé et maintenu par Microsoft
> - Gratuit et accessible à tous

### Pourquoi utiliser PowerShell Gallery ?

- **Centralisation** : Un seul endroit pour trouver des modules
- **Automatisation** : Installation et mise à jour simplifiées
- **Communauté** : Accès aux contributions de la communauté PowerShell
- **Gestion des dépendances** : Résolution automatique des dépendances
- **Versioning** : Plusieurs versions d'un même module disponibles

> [!warning] Prérequis PowerShell Gallery nécessite le provider **NuGet** qui sera installé automatiquement lors de votre première utilisation (avec demande de confirmation).

---

## 🔍 Find-Module : Rechercher des modules

### Concept et utilité

`Find-Module` permet de **rechercher des modules** dans les repositories configurés (PowerShell Gallery par défaut) sans les installer. C'est l'équivalent de faire une recherche sur le site web, mais directement depuis PowerShell.

> [!tip] Quand utiliser Find-Module ?
> 
> - Explorer les modules disponibles pour une tâche spécifique
> - Vérifier l'existence d'un module avant installation
> - Comparer les versions disponibles
> - Découvrir les dépendances d'un module

### Syntaxe de base

```powershell
# Recherche simple par nom
Find-Module -Name "Nom-Du-Module"

# Recherche avec wildcards
Find-Module -Name "Azure*"

# Recherche par tag/catégorie
Find-Module -Tag "Azure", "Cloud"

# Recherche par texte libre
Find-Module -Filter "Active Directory"

# Limiter le nombre de résultats
Find-Module -Name "Az*" | Select-Object -First 5
```

### Paramètres principaux

|Paramètre|Description|Exemple|
|---|---|---|
|`-Name`|Nom exact ou pattern (wildcards acceptés)|`-Name "Pester"`|
|`-Tag`|Recherche par catégories/tags|`-Tag "Security"`|
|`-Filter`|Recherche texte dans nom et description|`-Filter "backup"`|
|`-Repository`|Repository spécifique|`-Repository "PSGallery"`|
|`-AllVersions`|Afficher toutes les versions|`-AllVersions`|
|`-MinimumVersion`|Version minimale requise|`-MinimumVersion "2.0"`|
|`-MaximumVersion`|Version maximale acceptée|`-MaximumVersion "3.0"`|

### Informations retournées

```powershell
Find-Module -Name "Pester"
```

Retourne un objet avec :

- **Name** : Nom du module
- **Version** : Version actuelle (la plus récente par défaut)
- **Description** : Description courte
- **Author** : Auteur du module
- **CompanyName** : Entreprise/organisation
- **PublishedDate** : Date de publication
- **Dependencies** : Modules requis
- **Repository** : Repository source

### Exemples pratiques

```powershell
# Trouver tous les modules Azure
Find-Module -Name "Az.*" | Select-Object Name, Version, Description

# Rechercher des modules de sécurité
Find-Module -Tag "Security" | Format-Table Name, Author, Version

# Voir toutes les versions d'un module
Find-Module -Name "PSReadLine" -AllVersions

# Recherche avec filtrage avancé
Find-Module -Filter "Active Directory" | 
    Where-Object { $_.Author -like "*Microsoft*" } |
    Select-Object Name, Version, PublishedDate

# Vérifier les dépendances avant installation
$module = Find-Module -Name "AzureAD"
$module.Dependencies
```

> [!example] Cas d'usage : Trouver un module pour Exchange
> 
> ```powershell
> # Recherche large
> Find-Module -Filter "Exchange" | Select-Object Name, Description
> 
> # Affiner avec des tags
> Find-Module -Tag "Exchange" | 
>     Where-Object { $_.PublishedDate -gt (Get-Date).AddMonths(-6) }
> ```

> [!warning] Piège courant `Find-Module` ne recherche que dans les repositories configurés. Si vous cherchez un module d'un repository privé, assurez-vous qu'il est enregistré avec `Register-PSRepository`.

---

## 💾 Install-Module : Installer des modules

### Concept et utilité

`Install-Module` télécharge et installe des modules depuis un repository (PowerShell Gallery par défaut). C'est la méthode **recommandée** pour installer des modules depuis PowerShell 5.0+.

> [!info] Installation vs Import
> 
> - **Install-Module** : Télécharge et place le module dans un emplacement système
> - **Import-Module** : Charge le module en mémoire pour l'utiliser (généralement automatique)

### Syntaxe de base

```powershell
# Installation simple (scope utilisateur)
Install-Module -Name "Nom-Du-Module"

# Installation pour tous les utilisateurs (nécessite admin)
Install-Module -Name "Nom-Du-Module" -Scope AllUsers

# Installation sans confirmation
Install-Module -Name "Nom-Du-Module" -Force

# Installation d'une version spécifique
Install-Module -Name "Nom-Du-Module" -RequiredVersion "2.1.0"
```

### Le paramètre Scope

|Scope|Emplacement|Droits requis|Usage recommandé|
|---|---|---|---|
|**CurrentUser**|`$HOME\Documents\PowerShell\Modules`|Aucun|Développement, tests, usage personnel|
|**AllUsers**|`C:\Program Files\PowerShell\Modules`|Administrateur|Déploiement serveur, usage partagé|

```powershell
# Installation pour l'utilisateur courant (par défaut)
Install-Module -Name "Pester" -Scope CurrentUser

# Installation pour tous les utilisateurs
Install-Module -Name "AzureAD" -Scope AllUsers
```

> [!tip] Bonne pratique Utilisez `-Scope CurrentUser` par défaut pour éviter les problèmes de droits. Réservez `AllUsers` aux modules qui doivent être partagés entre tous les utilisateurs du système.

### Gestion des versions

```powershell
# Installer la dernière version (par défaut)
Install-Module -Name "Az"

# Installer une version spécifique
Install-Module -Name "Az" -RequiredVersion "9.0.0"

# Installer une version minimale
Install-Module -Name "Az" -MinimumVersion "8.0.0"

# Installer une version dans une plage
Install-Module -Name "Az" -MinimumVersion "8.0" -MaximumVersion "9.0"

# Forcer la réinstallation (écrase la version existante)
Install-Module -Name "Az" -Force
```

### Gestion automatique des dépendances

PowerShell installe automatiquement toutes les dépendances requises par un module.

```powershell
# Installation avec dépendances
Install-Module -Name "AzureAD"

# PowerShell va installer :
# 1. AzureAD
# 2. Toutes ses dépendances (ex: MSOnline, etc.)
```

> [!info] Provider NuGet Lors de votre première utilisation de `Install-Module`, PowerShell vous demandera d'installer le **NuGet provider** :
> 
> ```
> NuGet provider is required to continue
> PowerShellGet requires NuGet provider version '2.8.5.201' or newer
> ```
> 
> Répondez **Yes** pour continuer.

### Paramètres utiles

|Paramètre|Description|Exemple|
|---|---|---|
|`-Force`|Accepter sans confirmation, réinstaller si existe|`-Force`|
|`-AllowClobber`|Autoriser l'écrasement de commandes existantes|`-AllowClobber`|
|`-SkipPublisherCheck`|Ignorer la vérification de l'éditeur|`-SkipPublisherCheck`|
|`-AcceptLicense`|Accepter automatiquement la licence|`-AcceptLicense`|
|`-AllowPrerelease`|Autoriser les versions préliminaires|`-AllowPrerelease`|

### Exemples pratiques

```powershell
# Installation standard
Install-Module -Name "Pester" -Scope CurrentUser

# Installation silencieuse (scripts automatisés)
Install-Module -Name "Az" -Force -Scope CurrentUser -AcceptLicense

# Installation d'un module avec conflit de commandes
Install-Module -Name "PSScriptAnalyzer" -AllowClobber -Force

# Installation d'une version beta
Install-Module -Name "PowerShellGet" -AllowPrerelease

# Installer plusieurs modules d'un coup
$modules = @("Pester", "PSScriptAnalyzer", "platyPS")
$modules | ForEach-Object { Install-Module -Name $_ -Scope CurrentUser -Force }
```

> [!example] Workflow complet d'installation
> 
> ```powershell
> # 1. Rechercher le module
> Find-Module -Name "SqlServer"
> 
> # 2. Vérifier les dépendances
> (Find-Module -Name "SqlServer").Dependencies
> 
> # 3. Installer
> Install-Module -Name "SqlServer" -Scope CurrentUser
> 
> # 4. Vérifier l'installation
> Get-Module -Name "SqlServer" -ListAvailable
> 
> # 5. Importer et utiliser
> Import-Module SqlServer
> Get-Command -Module SqlServer
> ```

> [!warning] Pièges courants
> 
> 1. **Droits insuffisants** : Si `-Scope AllUsers` échoue, utilisez `CurrentUser` ou lancez PowerShell en administrateur
> 2. **Conflit de versions** : Si une version existe déjà, utilisez `-Force` pour réinstaller
> 3. **Repository non approuvé** : À la première installation, PowerShell demande de confirmer la confiance du repository

### Vérifier l'installation

```powershell
# Lister tous les modules installés
Get-InstalledModule

# Vérifier un module spécifique
Get-InstalledModule -Name "Pester"

# Voir toutes les versions installées
Get-InstalledModule -Name "Az" -AllVersions

# Localisation du module
(Get-Module -Name "Pester" -ListAvailable).ModuleBase
```

---

## 🔄 Update-Module : Mettre à jour des modules

### Concept et utilité

`Update-Module` met à jour un module vers sa **dernière version disponible** dans le repository. Les anciennes versions sont conservées par défaut (side-by-side installations).

> [!info] Side-by-side installations PowerShell peut conserver plusieurs versions d'un même module simultanément. Cela évite de casser les scripts qui dépendent d'une version spécifique.

### Syntaxe de base

```powershell
# Mettre à jour un module spécifique
Update-Module -Name "Nom-Du-Module"

# Mettre à jour tous les modules installés
Get-InstalledModule | Update-Module

# Mettre à jour sans confirmation
Update-Module -Name "Nom-Du-Module" -Force

# Mettre à jour vers une version spécifique
Update-Module -Name "Nom-Du-Module" -RequiredVersion "3.0.0"
```

### Comportement par défaut

```powershell
# Avant la mise à jour
Get-InstalledModule -Name "Pester" -AllVersions
# Version: 5.3.0, 5.2.0

# Mise à jour
Update-Module -Name "Pester"

# Après la mise à jour
Get-InstalledModule -Name "Pester" -AllVersions
# Version: 5.5.0, 5.3.0, 5.2.0  # Les anciennes versions restent !
```

> [!tip] Pourquoi conserver les anciennes versions ?
> 
> - **Compatibilité** : Certains scripts peuvent dépendre d'une version spécifique
> - **Rollback** : Possibilité de revenir en arrière si problème
> - **Tests** : Comparer le comportement entre versions

### Paramètres principaux

|Paramètre|Description|Exemple|
|---|---|---|
|`-Name`|Module à mettre à jour|`-Name "Az"`|
|`-Force`|Sans confirmation|`-Force`|
|`-RequiredVersion`|Mettre à jour vers version spécifique|`-RequiredVersion "2.0"`|
|`-AcceptLicense`|Accepter la licence automatiquement|`-AcceptLicense`|
|`-AllowPrerelease`|Autoriser versions préliminaires|`-AllowPrerelease`|
|`-Scope`|Scope de la mise à jour|`-Scope CurrentUser`|

### Exemples pratiques

```powershell
# Mettre à jour un module
Update-Module -Name "PSReadLine"

# Mettre à jour tous les modules (prudence !)
Get-InstalledModule | Update-Module -Force

# Mettre à jour uniquement les modules Azure
Get-InstalledModule -Name "Az.*" | Update-Module

# Mise à jour avec gestion d'erreurs
try {
    Update-Module -Name "Pester" -ErrorAction Stop
    Write-Host "✓ Pester mis à jour avec succès" -ForegroundColor Green
} catch {
    Write-Warning "Échec de la mise à jour : $_"
}

# Vérifier les mises à jour disponibles (sans installer)
$module = "Pester"
$installed = (Get-InstalledModule -Name $module).Version
$available = (Find-Module -Name $module).Version
if ($available -gt $installed) {
    Write-Host "Mise à jour disponible : $installed → $available"
}
```

> [!example] Script de mise à jour automatique
> 
> ```powershell
> # Liste des modules critiques à maintenir à jour
> $criticalModules = @("Az", "AzureAD", "Microsoft.Graph")
> 
> foreach ($module in $criticalModules) {
>     Write-Host "Vérification de $module..." -ForegroundColor Cyan
>     try {
>         Update-Module -Name $module -Force -ErrorAction Stop
>         Write-Host "✓ $module mis à jour" -ForegroundColor Green
>     } catch {
>         Write-Warning "× Échec pour $module : $_"
>     }
> }
> ```

### Nettoyer les anciennes versions

Pour supprimer les anciennes versions après mise à jour :

```powershell
# Obtenir toutes les versions sauf la plus récente
$module = "Pester"
$versions = Get-InstalledModule -Name $module -AllVersions
$latestVersion = ($versions | Sort-Object Version -Descending)[0]

# Désinstaller les anciennes versions
$versions | Where-Object { $_.Version -ne $latestVersion.Version } | 
    ForEach-Object { Uninstall-Module -Name $_.Name -RequiredVersion $_.Version -Force }

Write-Host "Conservé uniquement la version $($latestVersion.Version)"
```

> [!warning] Attention lors des mises à jour
> 
> - **Breaking changes** : Une nouvelle version peut introduire des changements incompatibles
> - **Testez d'abord** : Dans un environnement de test avant production
> - **Sauvegardez** : Notez les versions actuelles avant mise à jour massive
> - **Lisez les release notes** : Sur PowerShell Gallery ou GitHub du module

### Cas particulier : Mise à jour de PowerShellGet

PowerShellGet est le module qui gère lui-même les modules. Sa mise à jour nécessite une attention particulière :

```powershell
# Mettre à jour PowerShellGet
Install-Module -Name PowerShellGet -Force -Scope CurrentUser

# Redémarrer PowerShell pour utiliser la nouvelle version
```

---

## 🗑️ Uninstall-Module : Désinstaller des modules

### Concept et utilité

`Uninstall-Module` supprime un module installé via `Install-Module`. Il supprime physiquement les fichiers du module de son répertoire d'installation.

> [!info] Uninstall-Module vs Remove-Module
> 
> - **Uninstall-Module** : Supprime le module du disque (désinstallation)
> - **Remove-Module** : Décharge le module de la mémoire (mais reste installé)

### Syntaxe de base

```powershell
# Désinstaller un module
Uninstall-Module -Name "Nom-Du-Module"

# Désinstaller une version spécifique
Uninstall-Module -Name "Nom-Du-Module" -RequiredVersion "2.1.0"

# Désinstaller sans confirmation
Uninstall-Module -Name "Nom-Du-Module" -Force

# Désinstaller toutes les versions
Uninstall-Module -Name "Nom-Du-Module" -AllVersions
```

### Paramètres principaux

|Paramètre|Description|Exemple|
|---|---|---|
|`-Name`|Nom du module|`-Name "Pester"`|
|`-RequiredVersion`|Version spécifique|`-RequiredVersion "5.3.0"`|
|`-MinimumVersion`|Version minimale à désinstaller|`-MinimumVersion "5.0"`|
|`-MaximumVersion`|Version maximale à désinstaller|`-MaximumVersion "6.0"`|
|`-AllVersions`|Toutes les versions|`-AllVersions`|
|`-Force`|Sans confirmation|`-Force`|

### Exemples pratiques

```powershell
# Désinstaller la version la plus récente
Uninstall-Module -Name "Pester"

# Désinstaller une version spécifique
Uninstall-Module -Name "Pester" -RequiredVersion "5.3.0"

# Désinstaller toutes les versions d'un module
Uninstall-Module -Name "Pester" -AllVersions -Force

# Désinstaller plusieurs modules
$modules = @("OldModule1", "OldModule2", "OldModule3")
$modules | ForEach-Object { 
    Uninstall-Module -Name $_ -AllVersions -Force -ErrorAction SilentlyContinue 
}

# Désinstaller les anciennes versions uniquement
$module = "Az"
$versions = Get-InstalledModule -Name $module -AllVersions | Sort-Object Version
$versions | Select-Object -SkipLast 1 | ForEach-Object {
    Uninstall-Module -Name $_.Name -RequiredVersion $_.Version -Force
}
```

> [!example] Nettoyage après tests
> 
> ```powershell
> # Désinstaller tous les modules de test
> Get-InstalledModule | Where-Object { $_.Name -like "Test*" } | 
>     Uninstall-Module -AllVersions -Force
> 
> # Vérification
> Get-InstalledModule | Where-Object { $_.Name -like "Test*" }
> ```

### Gestion des dépendances

> [!warning] Attention aux dépendances `Uninstall-Module` ne supprime **pas automatiquement** les dépendances. Si vous désinstallez un module, les modules dont il dépendait restent installés.

```powershell
# Exemple : Module avec dépendances
# Si "ModuleA" dépend de "ModuleB" et "ModuleC"

Uninstall-Module -Name "ModuleA"
# Résultat : ModuleA est supprimé, mais ModuleB et ModuleC restent

# Pour nettoyer complètement, il faut désinstaller manuellement :
Uninstall-Module -Name "ModuleB", "ModuleC"
```

### Résolution des problèmes

```powershell
# Erreur : Module en cours d'utilisation
# Solution : Décharger d'abord le module
Remove-Module -Name "Pester" -Force
Uninstall-Module -Name "Pester"

# Erreur : Droits insuffisants (module en AllUsers)
# Solution : Lancer PowerShell en administrateur

# Vérifier si un module est vraiment désinstallé
Get-InstalledModule -Name "Pester" -ErrorAction SilentlyContinue
# Aucun résultat = module désinstallé
```

> [!tip] Nettoyage complet d'un environnement
> 
> ```powershell
> # Lister tous les modules installés manuellement
> $installedModules = Get-InstalledModule
> 
> # Filtrer ceux qu'on veut garder
> $modulesToKeep = @("PowerShellGet", "PackageManagement")
> $modulesToRemove = $installedModules | 
>     Where-Object { $_.Name -notin $modulesToKeep }
> 
> # Désinstaller
> $modulesToRemove | ForEach-Object {
>     Write-Host "Désinstallation de $($_.Name)..." -ForegroundColor Yellow
>     Uninstall-Module -Name $_.Name -AllVersions -Force -ErrorAction SilentlyContinue
> }
> ```

---

## 🏢 Gestion des Repositories

### Concept de Repository

Un **repository** est une source de modules PowerShell. PowerShell Gallery est le repository par défaut, mais vous pouvez en ajouter d'autres (internes à l'entreprise, privés, etc.).

> [!info] Cas d'usage des repositories personnalisés
> 
> - **Entreprise** : Modules internes privés
> - **Développement** : Repository de test/staging
> - **Conformité** : Contrôle des modules autorisés
> - **Performance** : Cache local pour réseau lent

### Get-PSRepository

Liste les repositories configurés sur votre système.

```powershell
# Lister tous les repositories
Get-PSRepository

# Informations détaillées
Get-PSRepository -Name "PSGallery" | Format-List *
```

**Résultat typique :**

```
Name                      : PSGallery
SourceLocation            : https://www.powershellgallery.com/api/v2
Trusted                   : False
Registered                : True
InstallationPolicy        : Untrusted
PackageManagementProvider : NuGet
PublishLocation           : https://www.powershellgallery.com/api/v2/package/
```

|Propriété|Description|
|---|---|
|**Name**|Nom du repository|
|**SourceLocation**|URL du repository|
|**Trusted**|Si les modules sont approuvés par défaut|
|**InstallationPolicy**|`Trusted` ou `Untrusted`|

### Register-PSRepository

Enregistre un nouveau repository pour rendre disponibles ses modules.

```powershell
# Syntaxe de base
Register-PSRepository -Name "MonRepo" -SourceLocation "https://repo.example.com/nuget" -InstallationPolicy Trusted

# Repository local (partage réseau)
Register-PSRepository -Name "RepoInterne" -SourceLocation "\\server\share\PSModules" -InstallationPolicy Trusted

# Repository privé avec authentification
Register-PSRepository -Name "RepoPrivé" -SourceLocation "https://pkgs.dev.azure.com/..." -Credential (Get-Credential)
```

**Paramètres importants :**

|Paramètre|Description|Valeurs|
|---|---|---|
|`-Name`|Nom du repository|Texte libre|
|`-SourceLocation`|URL ou chemin|URL ou UNC|
|`-InstallationPolicy`|Politique d'installation|`Trusted`, `Untrusted`|
|`-PublishLocation`|URL pour publier des modules|URL (optionnel)|
|`-Credential`|Identifiants|PSCredential|

### Set-PSRepository

Modifie les propriétés d'un repository existant.

```powershell
# Approuver PowerShell Gallery (évite les confirmations)
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

# Changer l'URL d'un repository
Set-PSRepository -Name "RepoInterne" -SourceLocation "https://nouveau-url.com/nuget"

# Désapprouver un repository
Set-PSRepository -Name "TestRepo" -InstallationPolicy Untrusted
```

> [!warning] PSGallery et sécurité Par défaut, PSGallery est `Untrusted`. PowerShell demandera confirmation à chaque installation. Vous pouvez le définir comme `Trusted`, mais soyez conscient des implications de sécurité.

### Unregister-PSRepository

Supprime un repository de la configuration.

```powershell
# Supprimer un repository
Unregister-PSRepository -Name "RepoInterne"

# Attention : Impossible de supprimer PSGallery (repository par défaut)
```

### Exemples pratiques

```powershell
# Configuration repository d'entreprise
Register-PSRepository -Name "EntrepriseModules" `
    -SourceLocation "https://nuget.entreprise.local/v3/index.json" `
    -InstallationPolicy Trusted `
    -PackageManagementProvider NuGet

# Vérifier la configuration
Get-PSRepository -Name "EntrepriseModules"

# Installer un module depuis ce repository
Install-Module -Name "ModuleInterne" -Repository "EntrepriseModules"

# Lister les modules disponibles dans un repository spécifique
Find-Module -Repository "EntrepriseModules"
```

> [!example] Configuration multi-repository
> 
> ```powershell
> # Repository de production
> Register-PSRepository -Name "Prod-Modules" `
>     -SourceLocation "\\prodserver\modules" `
>     -InstallationPolicy Trusted
> 
> # Repository de développement
> Register-PSRepository -Name "Dev-Modules" `
>     -SourceLocation "\\devserver\modules" `
>     -InstallationPolicy Untrusted
> 
> # Installation depuis un repository spécifique
> Install-Module -Name "MyModule" -Repository "Prod-Modules"
> 
> # Recherche dans tous les repositories
> Find-Module -Name "MyModule" -Repository * | 
>     Select-Object Name, Version, Repository
> ```

### Repository local (NuGet feed interne)

Pour créer un repository local simple :

```powershell
# 1. Créer un dossier partagé
New-Item -Path "C:\PSModules" -ItemType Directory

# 2. Enregistrer comme repository
Register-PSRepository -Name "LocalRepo" `
    -SourceLocation "C:\PSModules" `
    -PublishLocation "C:\PSModules" `
    -InstallationPolicy Trusted

# 3. Publier un module dans ce repository
Publish-Module -Name "MonModule" -Repository "LocalRepo" -NuGetApiKey "local"
```

> [!tip] Repositories multiples et priorité Quand plusieurs repositories sont configurés, `Find-Module` et `Install-Module` cherchent dans tous par défaut. Utilisez `-Repository` pour cibler un repository spécifique.

---

## 🔒 Sécurité et bonnes pratiques

### Signature de modules

Les modules peuvent être **signés numériquement** pour garantir leur authenticité et intégrité.

> [!info] Qu'est-ce qu'un module signé ? Un module signé contient une signature numérique qui :
> 
> - **Authentifie** l'éditeur du module
> - **Garantit** que le code n'a pas été modifié
> - **Protège** contre le code malveillant

```powershell
# Vérifier la signature d'un module
$modulePath = (Get-Module -Name "Pester" -ListAvailable).Path
Get-AuthenticodeSignature -FilePath $modulePath

# Résultat attendu pour un module signé :
# Status: Valid
# SignerCertificate: CN=Microsoft Corporation, ...
```

### Vérification d'éditeurs

```powershell
# Informations sur l'éditeur d'un module
$module = Find-Module -Name "Az"
$module.Author
$module.CompanyName

# Modules Microsoft officiels
Find-Module -Filter "Microsoft" | Where-Object { $_.CompanyName -eq "Microsoft Corporation" }

# Vérifier avant installation
$module = Find-Module -Name "SuspectModule"
if ($module.Author -notlike "*Microsoft*" -and $module.CompanyName -notlike "*Trusted*") {
    Write-Warning "⚠ Module d'un éditeur inconnu. Vérifier avant installation."
}
```

> [!warning] Modules non vérifiés PowerShell Gallery accepte les contributions de tous. Vérifiez toujours :
> 
> - L'éditeur du module
> - Le nombre de téléchargements
> - La date de dernière mise à jour
> - Les avis de la communauté (sur le site web)

### ExecutionPolicy et modules

L'**ExecutionPolicy** contrôle l'exécution des scripts PowerShell, mais s'applique aussi au chargement des modules.

```powershell
# Voir la politique actuelle
Get-ExecutionPolicy

# Politiques courantes et leur impact
```

|ExecutionPolicy|Scripts locaux|Modules installés|Recommandation|
|---|---|---|---|
|`Restricted`|Bloqués|Bloqués si non signés|❌ Trop restrictif|
|`AllSigned`|Signés uniquement|Signés uniquement|🔒 Très sécurisé|
|`RemoteSigned`|Autorisés|Signés si téléchargés|✅ Équilibre recommandé|
|`Unrestricted`|Autorisés avec avertissement|Autorisés|⚠️ Moins sécurisé|
|`Bypass`|Tous autorisés|Tous autorisés|❌ Dangereux|

```powershell
# Définir une ExecutionPolicy recommandée
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Vérifier l'impact sur les modules
Get-ExecutionPolicy -List
```

> [!tip] Bonne pratique ExecutionPolicy `RemoteSigned` est le meilleur compromis :
> 
> - Scripts locaux non signés fonctionnent
> - Scripts téléchargés doivent être signés ou débloqués
> - Modules de PowerShell Gallery fonctionnent correctement

### Débloquer des modules téléchargés

Quand vous téléchargez manuellement un module (zip), Windows le marque comme provenant d'Internet.

```powershell
# Débloquer tous les fichiers d'un module
$modulePath = "C:\Temp\MonModule"
Get-ChildItem -Path $modulePath -Recurse | Unblock-File

# Vérifier qu'un fichier est bloqué
Get-Item -Path "C:\Temp\MonModule\MonModule.psm1" -Stream Zone.Identifier

# Débloquer un fichier spécifique
Unblock-File -Path "C:\Temp\MonModule\MonModule.psm1"
```

### Bonnes pratiques de sécurité

#### 1. Approuver les sources uniquement si nécessaire

```powershell
# ❌ Mauvaise pratique
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

# ✅ Bonne pratique
# Laisser Untrusted et confirmer manuellement chaque installation critique
```

#### 2. Vérifier avant d'installer

```powershell
# Workflow de vérification sécurisé
$moduleName = "NewModule"

# 1. Rechercher et inspecter
$module = Find-Module -Name $moduleName
Write-Host "Auteur: $($module.Author)"
Write-Host "Société: $($module.CompanyName)"
Write-Host "Date publication: $($module.PublishedDate)"
Write-Host "Téléchargements: $($module.AdditionalMetadata.downloadCount)"

# 2. Vérifier le site web du projet
if ($module.ProjectUri) {
    Write-Host "Projet: $($module.ProjectUri)"
}

# 3. Lire la description et les release notes
$module.Description
$module.ReleaseNotes

# 4. Installer si tout est OK
Read-Host "Continuer l'installation ? (Ctrl+C pour annuler)"
Install-Module -Name $moduleName -Scope CurrentUser
```

#### 3. Utiliser des repositories internes en entreprise

```powershell
# Configuration d'entreprise sécurisée
# 1. Repository interne approuvé
Register-PSRepository -Name "EntrepriseApprouvee" `
    -SourceLocation "https://nuget.entreprise.local" `
    -InstallationPolicy Trusted

# 2. Bloquer PowerShell Gallery en production
Unregister-PSRepository -Name "PSGallery"

# 3. Installer uniquement depuis le repository interne
Install-Module -Name "ModuleInterne" -Repository "EntrepriseApprouvee"
```

#### 4. Auditer les modules installés

```powershell
# Lister tous les modules avec leurs sources
Get-InstalledModule | Select-Object Name, Version, Repository, InstalledDate |
    Sort-Object InstalledDate -Descending |
    Format-Table -AutoSize

# Identifier les modules non-Microsoft
Get-InstalledModule | Where-Object { 
    $_.CompanyName -notlike "*Microsoft*" 
} | Select-Object Name, Author, CompanyName

# Exporter un inventaire
Get-InstalledModule | Export-Csv -Path "C:\Audit\ModulesInstallés.csv" -NoTypeInformation
```

#### 5. Mise à jour sécurisée

```powershell
# Script de mise à jour avec validation
function Update-ModuleSecure {
    param([string]$ModuleName)
    
    $current = Get-InstalledModule -Name $ModuleName
    $latest = Find-Module -Name $ModuleName
    
    if ($latest.Version -gt $current.Version) {
        Write-Host "Mise à jour disponible : $($current.Version) → $($latest.Version)"
        Write-Host "Release notes :`n$($latest.ReleaseNotes)"
        
        $confirm = Read-Host "Confirmer la mise à jour ? (O/N)"
        if ($confirm -eq 'O') {
            Update-Module -Name $ModuleName -Force
            Write-Host "✓ Mise à jour effectuée" -ForegroundColor Green
        }
    } else {
        Write-Host "✓ Module déjà à jour ($($current.Version))" -ForegroundColor Green
    }
}

# Utilisation
Update-ModuleSecure -ModuleName "Pester"
```

### Sécurité : Points de contrôle essentiels

> [!warning] Checklist de sécurité Avant d'installer un module :
> 
> - ✅ Vérifier l'auteur et la société
> - ✅ Consulter le nombre de téléchargements (popularité)
> - ✅ Vérifier la date de dernière mise à jour (maintenance active ?)
> - ✅ Lire les avis sur PowerShell Gallery
> - ✅ Examiner le code source si open-source (GitHub)
> - ✅ Tester en environnement isolé d'abord
> - ✅ Scanner avec un antivirus si possible

### Gestion des credentials pour repositories privés

```powershell
# Stocker un credential de manière sécurisée
$credential = Get-Credential -Message "Identifiants repository privé"
$credential | Export-Clixml -Path "$env:USERPROFILE\.pscredentials\repo.xml"

# Réutiliser le credential
$credential = Import-Clixml -Path "$env:USERPROFILE\.pscredentials\repo.xml"
Register-PSRepository -Name "RepoPrivé" `
    -SourceLocation "https://repo.private.com" `
    -Credential $credential

# Alternative : Utiliser un Personal Access Token (PAT)
$pat = ConvertTo-SecureString "your-pat-token" -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential("username", $pat)
```

### Isolation et tests

```powershell
# Tester un module dans une session isolée
$job = Start-Job -ScriptBlock {
    Import-Module NouveauModule
    # Tests ici
    Get-Command -Module NouveauModule
}

$job | Wait-Job | Receive-Job
Remove-Job -Job $job

# Utiliser un environnement de test dédié
# Installer uniquement pour CurrentUser
Install-Module -Name "ModuleDeTest" -Scope CurrentUser -Force

# Tester
Import-Module ModuleDeTest
# ... tests ...

# Nettoyer si nécessaire
Uninstall-Module -Name "ModuleDeTest" -Force
```

> [!example] Politique de sécurité d'entreprise type
> 
> ```powershell
> # 1. Bloquer PowerShell Gallery public
> Unregister-PSRepository -Name "PSGallery" -ErrorAction SilentlyContinue
> 
> # 2. Enregistrer repository interne uniquement
> Register-PSRepository -Name "CompanyModules" `
>     -SourceLocation "https://nuget.company.local" `
>     -InstallationPolicy Trusted
> 
> # 3. Définir ExecutionPolicy stricte
> Set-ExecutionPolicy -ExecutionPolicy AllSigned -Scope LocalMachine
> 
> # 4. Fonction d'installation contrôlée
> function Install-ApprovedModule {
>     param([string]$Name)
>     
>     $approvedList = @("Az", "AzureAD", "Microsoft.Graph")
>     
>     if ($Name -notin $approvedList) {
>         Write-Error "Module non approuvé par la politique de sécurité"
>         return
>     }
>     
>     Install-Module -Name $Name -Repository "CompanyModules" -Scope AllUsers
> }
> ```

---

## 📋 Résumé des commandes essentielles

### Recherche et installation

```powershell
# Rechercher
Find-Module -Name "ModuleName"
Find-Module -Filter "keyword" -Tag "Azure"

# Installer
Install-Module -Name "ModuleName" -Scope CurrentUser
Install-Module -Name "ModuleName" -RequiredVersion "2.0" -Force

# Vérifier l'installation
Get-InstalledModule -Name "ModuleName"
Get-Module -Name "ModuleName" -ListAvailable
```

### Mise à jour et suppression

```powershell
# Mettre à jour
Update-Module -Name "ModuleName"
Get-InstalledModule | Update-Module -Force

# Désinstaller
Uninstall-Module -Name "ModuleName"
Uninstall-Module -Name "ModuleName" -AllVersions -Force
```

### Gestion des repositories

```powershell
# Lister les repositories
Get-PSRepository

# Ajouter un repository
Register-PSRepository -Name "MyRepo" -SourceLocation "URL" -InstallationPolicy Trusted

# Approuver PowerShell Gallery
Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted

# Supprimer un repository
Unregister-PSRepository -Name "MyRepo"
```

### Sécurité

```powershell
# Vérifier l'ExecutionPolicy
Get-ExecutionPolicy -List

# Définir ExecutionPolicy
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser

# Débloquer un module
Unblock-File -Path "Path\To\Module\*" -Recurse

# Vérifier la signature
Get-AuthenticodeSignature -FilePath "Module.psm1"
```

---

## 🎯 Astuces avancées

### Astuce 1 : Installation rapide de multiples modules

```powershell
# Liste de modules à installer
$modules = @(
    "Pester",
    "PSScriptAnalyzer",
    "PSReadLine",
    "Microsoft.Graph"
)

# Installation en masse avec gestion d'erreurs
$modules | ForEach-Object {
    Write-Host "Installation de $_..." -ForegroundColor Cyan
    try {
        Install-Module -Name $_ -Scope CurrentUser -Force -ErrorAction Stop
        Write-Host "  ✓ $_" -ForegroundColor Green
    } catch {
        Write-Host "  ✗ $_ : $($_.Exception.Message)" -ForegroundColor Red
    }
}
```

### Astuce 2 : Comparer les versions disponibles

```powershell
function Compare-ModuleVersion {
    param([string]$ModuleName)
    
    $installed = Get-InstalledModule -Name $ModuleName -ErrorAction SilentlyContinue
    $available = Find-Module -Name $ModuleName -ErrorAction SilentlyContinue
    
    if ($installed -and $available) {
        [PSCustomObject]@{
            Module    = $ModuleName
            Installed = $installed.Version
            Available = $available.Version
            Status    = if ($available.Version -gt $installed.Version) { "⬆ Mise à jour disponible" } else { "✓ À jour" }
        }
    } elseif (!$installed) {
        Write-Warning "$ModuleName n'est pas installé"
    } else {
        Write-Warning "$ModuleName introuvable dans les repositories"
    }
}

# Utilisation
Compare-ModuleVersion -ModuleName "Pester"
```

### Astuce 3 : Sauvegarder et restaurer une configuration

```powershell
# Exporter la liste des modules installés
$backup = Get-InstalledModule | Select-Object Name, Version
$backup | Export-Clixml -Path "$env:USERPROFILE\ModulesBackup.xml"

# Restaurer sur un autre système
$backup = Import-Clixml -Path "$env:USERPROFILE\ModulesBackup.xml"
$backup | ForEach-Object {
    Install-Module -Name $_.Name -RequiredVersion $_.Version -Scope CurrentUser -Force
}
```

### Astuce 4 : Installation offline (sans Internet)

```powershell
# Sur un PC avec Internet : Télécharger le module
Save-Module -Name "Pester" -Path "C:\OfflineModules"

# Copier le dossier sur le PC offline, puis :
$sourcePath = "C:\OfflineModules\Pester"
$destinationPath = "$env:USERPROFILE\Documents\PowerShell\Modules"
Copy-Item -Path $sourcePath -Destination $destinationPath -Recurse -Force

# Vérifier
Import-Module Pester
Get-Module Pester
```

### Astuce 5 : Audit et reporting

```powershell
# Générer un rapport HTML des modules installés
$modules = Get-InstalledModule | Select-Object Name, Version, Author, PublishedDate, Repository

$html = $modules | ConvertTo-Html -Title "Modules PowerShell installés" -PreContent "<h1>Inventaire des modules</h1>" -PostContent "<p>Généré le $(Get-Date)</p>"

$html | Out-File -FilePath "$env:USERPROFILE\Desktop\ModulesReport.html"
Start-Process "$env:USERPROFILE\Desktop\ModulesReport.html"
```

> [!tip] Astuce bonus : Auto-complétion PowerShell offre une excellente auto-complétion. Tapez `Install-Module -Name` puis `Ctrl+Space` pour voir les suggestions de modules populaires.

---

## 🚨 Pièges courants et solutions

### Piège 1 : "NuGet provider is required"

**Symptôme :** Premier usage de `Install-Module` demande NuGet.

**Solution :**

```powershell
# Installer NuGet sans confirmation
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
```

### Piège 2 : "Unable to resolve package source"

**Symptôme :** PowerShell ne peut pas contacter PowerShell Gallery.

**Solution :**

```powershell
# Vérifier la connectivité
Test-NetConnection -ComputerName www.powershellgallery.com -Port 443

# Forcer le protocole TLS 1.2
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Réessayer
Install-Module -Name "ModuleName"
```

### Piège 3 : Plusieurs versions chargées simultanément

**Symptôme :** Comportement imprévisible, commandes qui ne fonctionnent pas.

**Solution :**

```powershell
# Décharger toutes les versions
Remove-Module -Name "ModuleName" -Force -ErrorAction SilentlyContinue

# Charger une version spécifique
Import-Module -Name "ModuleName" -RequiredVersion "2.0.0"

# Ou supprimer les anciennes versions
Uninstall-Module -Name "ModuleName" -AllVersions
Install-Module -Name "ModuleName" -Force
```

### Piège 4 : Conflit avec des modules intégrés

**Symptôme :** `Install-Module` installe un module qui existe déjà en version intégrée.

**Solution :**

```powershell
# Utiliser -AllowClobber pour autoriser l'écrasement
Install-Module -Name "PowerShellGet" -AllowClobber -Force

# Vérifier quelle version est chargée
Get-Module -Name "PowerShellGet" -ListAvailable | Select-Object Name, Version, Path
```

### Piège 5 : Permissions insuffisantes

**Symptôme :** Erreur "Access denied" lors de l'installation.

**Solution :**

```powershell
# Option 1 : Utiliser CurrentUser (recommandé)
Install-Module -Name "ModuleName" -Scope CurrentUser

# Option 2 : Lancer PowerShell en admin (si AllUsers nécessaire)
Start-Process powershell -Verb RunAs
```

---

## 🎓 Récapitulatif des concepts clés

> [!info] Points essentiels à retenir
> 
> **PowerShell Gallery**
> 
> - Repository public central pour les modules PowerShell
> - Accessible via `Find-Module`, `Install-Module`, etc.
> - Nécessite le provider NuGet
> 
> **Find-Module**
> 
> - Rechercher des modules sans les installer
> - Filtrage par nom, tag, ou texte
> - Retourne informations détaillées (version, auteur, dépendances)
> 
> **Install-Module**
> 
> - Installer des modules depuis un repository
> - Gestion automatique des dépendances
> - `-Scope CurrentUser` recommandé (pas de droits admin requis)
> - Side-by-side : plusieurs versions peuvent coexister
> 
> **Update-Module**
> 
> - Mise à jour vers dernière version disponible
> - Conserve les anciennes versions par défaut
> - Tester en environnement de développement d'abord
> 
> **Uninstall-Module**
> 
> - Suppression physique du module
> - Ne supprime pas automatiquement les dépendances
> - `-AllVersions` pour nettoyer complètement
> 
> **Repositories**
> 
> - Possibilité d'ajouter des repositories personnalisés
> - Utile en entreprise pour modules internes
> - `Get-PSRepository`, `Register-PSRepository`, `Set-PSRepository`
> 
> **Sécurité**
> 
> - Vérifier toujours l'auteur et la provenance
> - ExecutionPolicy : `RemoteSigned` recommandé
> - Signature de modules pour garantir authenticité
> - Approuver les sources avec prudence

---

_Ce cours couvre la gestion complète des modules via PowerShell Gallery. Pour l'utilisation pratique des modules après installation, référez-vous aux autres sections du cours PowerShell._