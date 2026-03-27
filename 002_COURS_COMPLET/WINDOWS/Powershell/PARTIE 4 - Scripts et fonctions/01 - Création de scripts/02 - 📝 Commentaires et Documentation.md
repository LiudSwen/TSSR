

## 📚 Table des matières

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

## 💬 Commentaires sur une ligne

### Syntaxe de base

Les commentaires sur une ligne utilisent le symbole `#`. Tout ce qui suit ce symbole sur la même ligne est ignoré par PowerShell.

```powershell
# Ceci est un commentaire sur une ligne
Get-Process  # Commentaire en fin de ligne

# Calcul de la somme
$total = 10 + 20  # Addition simple
```

### Quand les utiliser

Les commentaires sur une ligne sont parfaits pour :

- Expliquer une ligne de code complexe
- Désactiver temporairement du code pendant le débogage
- Ajouter des notes rapides sur la logique
- Marquer des sections à améliorer (TODO, FIXME)

```powershell
# TODO: Ajouter la gestion des erreurs
# FIXME: Ce code ne fonctionne pas avec des chemins UNC
# HACK: Solution temporaire en attendant le correctif du module

# Récupération des services actifs uniquement
$services = Get-Service | Where-Object {$_.Status -eq 'Running'}
```

> [!tip] Astuce Utilisez des conventions comme `TODO:`, `FIXME:`, `HACK:`, ou `NOTE:` pour marquer des commentaires spéciaux. Cela facilite la recherche dans votre code.

> [!warning] Attention N'abusez pas des commentaires. Un code bien écrit avec des noms de variables explicites est souvent plus lisible que du code mal écrit avec beaucoup de commentaires.

---

## 📄 Commentaires multi-lignes

### Syntaxe

Les commentaires multi-lignes utilisent `<#` pour ouvrir et `#>` pour fermer le bloc de commentaire.

```powershell
<#
Ceci est un commentaire
qui s'étend sur plusieurs lignes.
Tout le contenu entre <# et #> est ignoré.
#>

Get-Service

<#
    Les espaces et l'indentation à l'intérieur
    des commentaires multi-lignes sont préservés
    mais n'ont aucun impact sur l'exécution
#>
```

### Placement flexible

Les commentaires multi-lignes peuvent être placés presque n'importe où :

```powershell
$resultat = <# Commentaire inline #> Get-Process

Get-Service <# Au milieu d'une commande #> -Name 'wuauserv'

# Même à l'intérieur de pipelines
Get-Process | 
    <# Filtrage par CPU #>
    Where-Object {$_.CPU -gt 100} |
    <# Tri par mémoire #>
    Sort-Object WS -Descending
```

### Quand les utiliser

Les commentaires multi-lignes sont idéaux pour :

- Expliquer un bloc de code complexe
- Documenter l'historique des modifications
- Ajouter des notes détaillées sur l'algorithme
- Désactiver temporairement plusieurs lignes de code

```powershell
<#
HISTORIQUE DES MODIFICATIONS:
2024-01-15 : Jean Dupont - Ajout de la gestion des erreurs
2024-02-20 : Marie Martin - Optimisation des performances
2024-03-10 : Pierre Durant - Ajout du support multi-threading
#>

<#
ALGORITHME:
1. Récupérer tous les fichiers du répertoire
2. Filtrer par extension .log
3. Trier par date de modification
4. Archiver les fichiers de plus de 30 jours
#>
```

> [!warning] Piège courant Les commentaires multi-lignes ne peuvent pas être imbriqués. Ceci provoquera une erreur :
> 
> ```powershell
> <# Commentaire 1 <# Commentaire 2 #> #>  # ❌ ERREUR
> ```

---

## 📦 Régions (#region / #endregion)

Les régions sont des commentaires spéciaux qui permettent d'organiser et de structurer visuellement votre code en sections pliables/dépliables dans les éditeurs modernes.

### Syntaxe de base

```powershell
#region Nom de la région
# Votre code ici
Get-Service
Get-Process
#endregion
```

### Pourquoi utiliser les régions

Les régions sont particulièrement utiles pour :

- **Organisation visuelle** : Structurer un long script en sections logiques
- **Navigation rapide** : Plier/déplier des sections pour se concentrer sur une partie spécifique
- **Lisibilité** : Masquer temporairement du code qui n'est pas pertinent pour la tâche en cours
- **Collaboration** : Faciliter la lecture et la compréhension du code par d'autres développeurs

```powershell
#region Initialisation
$configPath = "C:\Config\app.json"
$logPath = "C:\Logs\app.log"
$errorCount = 0
#endregion

#region Chargement de la configuration
$config = Get-Content $configPath | ConvertFrom-Json
Write-Host "Configuration chargée depuis $configPath"
#endregion

#region Traitement principal
foreach ($item in $config.Items) {
    try {
        Process-Item -Item $item
    }
    catch {
        $errorCount++
        Write-Error "Erreur lors du traitement de $item"
    }
}
#endregion

#region Nettoyage et rapports
Write-Host "Traitement terminé avec $errorCount erreur(s)"
Clear-TempFiles
#endregion
```

### Nommage des régions

Donnez des noms descriptifs et significatifs à vos régions :

```powershell
# ✅ BON : Noms clairs et descriptifs
#region Variables globales et configuration
#region Fonctions utilitaires
#region Traitement des données
#region Gestion des erreurs
#region Export et rapports

# ❌ MAUVAIS : Noms vagues ou inutiles
#region Section 1
#region Stuff
#region Code
#region Temp
```

### Régions imbriquées

Les régions peuvent être imbriquées pour créer une hiérarchie organisationnelle :

```powershell
#region Gestion des utilisateurs

    #region Création d'utilisateurs
    function New-UserAccount {
        param([string]$Username)
        # Code...
    }
    #endregion

    #region Modification d'utilisateurs
    function Set-UserAccount {
        param([string]$Username)
        # Code...
    }
    #endregion

    #region Suppression d'utilisateurs
    function Remove-UserAccount {
        param([string]$Username)
        # Code...
    }
    #endregion

#endregion Gestion des utilisateurs
```

> [!tip] Bonnes pratiques d'imbrication
> - Limitez l'imbrication à 2-3 niveaux maximum
> - Utilisez l'indentation pour visualiser la hiérarchie
> - Répétez le nom de la région dans `#endregion` pour les grandes sections

### Support dans les éditeurs

#### Visual Studio Code
- **Plier une région** : Cliquez sur l'icône `-` à gauche du numéro de ligne
- **Déplier une région** : Cliquez sur l'icône `+`
- **Plier toutes les régions** : `Ctrl+K Ctrl+0`
- **Déplier toutes les régions** : `Ctrl+K Ctrl+J`
- **Plier/déplier région courante** : `Ctrl+K Ctrl+L`

#### PowerShell ISE
- Les régions apparaissent avec des icônes `[+]` et `[-]` dans la marge
- Cliquez pour plier/déplier
- Menu : Affichage → Développer/Réduire les régions

#### Windows Terminal / Console PowerShell
- Les régions ne sont pas visuelles dans la console
- Elles restent des commentaires normaux
- Aucun impact sur l'exécution du code

### Cas d'usage typiques

#### 1. Scripts longs et complexes

```powershell
#region Configuration et variables
$server = "SQL01"
$database = "Production"
$backupPath = "\\NAS\Backups"
#endregion

#region Fonctions de validation
function Test-Prerequisites {
    # Vérifications...
}
#endregion

#region Connexion et authentification
$credentials = Get-Credential
Connect-Database -Server $server -Credential $credentials
#endregion

#region Traitement métier
# ... plusieurs centaines de lignes ...
#endregion

#region Nettoyage et fermeture
Disconnect-Database
Remove-TempFiles
#endregion
```

#### 2. Modules avec multiples fonctions

```powershell
#region Fonctions publiques (Export)

function Get-ServerInfo {
    <#
    .SYNOPSIS
        Récupère les informations d'un serveur
    #>
    # Code...
}

function Set-ServerConfig {
    <#
    .SYNOPSIS
        Modifie la configuration d'un serveur
    #>
    # Code...
}

#endregion

#region Fonctions privées (Helper)

function Test-ServerReachable {
    # Fonction interne non exportée
}

function Format-ServerData {
    # Fonction interne non exportée
}

#endregion

#region Exports de module
Export-ModuleMember -Function Get-ServerInfo, Set-ServerConfig
#endregion
```

#### 3. Scripts de déploiement avec phases

```powershell
#region Phase 1 : Pré-déploiement
Write-Host "=== PHASE 1 : PRÉ-DÉPLOIEMENT ===" -ForegroundColor Cyan

# Vérification des prérequis
Test-Prerequisites

# Sauvegarde de sécurité
Backup-CurrentVersion

# Arrêt des services
Stop-ApplicationServices
#endregion

#region Phase 2 : Déploiement
Write-Host "=== PHASE 2 : DÉPLOIEMENT ===" -ForegroundColor Cyan

# Copie des fichiers
Copy-ApplicationFiles

# Mise à jour de la base de données
Update-DatabaseSchema
#endregion

#region Phase 3 : Post-déploiement
Write-Host "=== PHASE 3 : POST-DÉPLOIEMENT ===" -ForegroundColor Cyan

# Redémarrage des services
Start-ApplicationServices

# Tests de validation
Invoke-SmokeTests

# Nettoyage
Remove-OldVersions
#endregion
```

### Quand NE PAS utiliser les régions

Les régions ne sont pas toujours appropriées :

```powershell
# ❌ Sur-utilisation : régions trop petites
#region Get process
$process = Get-Process
#endregion
# Inutile pour une seule ligne

# ❌ Masquer du code de mauvaise qualité
#region Code temporaire qui ne fonctionne pas bien
# ... 200 lignes de code mal écrit ...
#endregion
# Les régions ne sont pas une excuse pour du mauvais code

# ❌ Remplacer la modularisation
#region Fonction 1
# Code...
#endregion
#region Fonction 2
# Code...
#endregion
# Si vous avez beaucoup de régions, créez plutôt des fonctions séparées
```

> [!warning] Attention
> - Les régions sont **purement visuelles** et n'affectent pas l'exécution
> - Elles ne créent pas de portée (scope) pour les variables
> - N'utilisez pas les régions pour masquer du code problématique
> - Si votre script a besoin de trop de régions, envisagez de le découper en plusieurs fichiers

### Bonnes pratiques

1. **Utilisez les régions avec parcimonie** : Seulement pour des scripts vraiment longs (> 200 lignes)
2. **Noms descriptifs** : Le nom doit indiquer clairement le contenu de la région
3. **Cohérence** : Adoptez une convention de nommage pour toute votre équipe
4. **Complétez toujours** : Chaque `#region` doit avoir son `#endregion`
5. **Documentation complémentaire** : Les régions ne remplacent pas les commentaires explicatifs

```powershell
# ✅ Exemple de bon usage
#region Configuration du module
<#
    Cette section initialise toutes les variables de configuration
    nécessaires au fonctionnement du module. Ces valeurs peuvent
    être surchargées par un fichier de configuration externe.
#>
$script:DefaultTimeout = 30
$script:RetryCount = 3
$script:LogLevel = "Info"
#endregion

# Les régions et les commentaires travaillent ensemble
```

---

## 📖 Commentaires de documentation (Comment-Based Help)

Le Comment-Based Help est un système de documentation structuré qui permet de générer une aide interactive pour vos scripts et fonctions. Cette aide est accessible via `Get-Help`.

### Structure complète du Comment-Based Help

```powershell
<#
.SYNOPSIS
    Description courte en une ligne de ce que fait le script/fonction

.DESCRIPTION
    Description détaillée et complète du fonctionnement.
    Peut s'étendre sur plusieurs lignes pour expliquer
    tous les aspects importants du script.

.PARAMETER NomParametre
    Description du paramètre NomParametre.
    Expliquez ce qu'il fait, son type, et ses valeurs acceptées.

.PARAMETER AutreParametre
    Description d'un autre paramètre.
    Un bloc .PARAMETER par paramètre.

.EXAMPLE
    Exemple d'utilisation 1
    PS C:\> Mon-Script.ps1 -Parametre "valeur"
    
    Explication de ce que fait cet exemple et du résultat attendu.

.EXAMPLE
    Exemple d'utilisation 2
    PS C:\> Mon-Script.ps1 -AutreParametre 42
    
    Deuxième exemple avec un autre cas d'usage.

.INPUTS
    Type d'objets que le script accepte via le pipeline.
    Par exemple : System.String, System.IO.FileInfo

.OUTPUTS
    Type d'objets que le script retourne.
    Par exemple : System.Object, PSCustomObject

.NOTES
    Informations supplémentaires :
    - Auteur : Votre Nom
    - Date : 2024-12-10
    - Version : 1.0
    - Prérequis : PowerShell 5.1 ou supérieur
    
.LINK
    https://docs.microsoft.com/powershell
    
.LINK
    Get-Process
    
.COMPONENT
    Nom du composant ou module auquel appartient ce script

.ROLE
    Rôle ou fonction métier (ex: Administration, Sauvegarde)

.FUNCTIONALITY
    Fonctionnalité technique fournie (ex: Gestion des services)
#>
```

### Placement du Comment-Based Help

Le bloc d'aide peut être placé à trois endroits différents :

#### 1. Au début du script/fonction (recommandé)

```powershell
function Get-UserInfo {
    <#
    .SYNOPSIS
        Récupère les informations d'un utilisateur
    
    .DESCRIPTION
        Cette fonction interroge Active Directory pour obtenir
        les informations détaillées d'un compte utilisateur.
    
    .PARAMETER UserName
        Nom d'utilisateur (SamAccountName) à rechercher
    
    .EXAMPLE
        Get-UserInfo -UserName "jdupont"
    #>
    param(
        [string]$UserName
    )
    
    # Code de la fonction
}
```

#### 2. Avant le mot-clé `function`

```powershell
<#
.SYNOPSIS
    Récupère les informations d'un utilisateur
#>
function Get-UserInfo {
    param([string]$UserName)
    # Code
}
```

#### 3. À la fin de la fonction

```powershell
function Get-UserInfo {
    param([string]$UserName)
    
    # Code de la fonction
    
    <#
    .SYNOPSIS
        Récupère les informations d'un utilisateur
    #>
}
```

> [!tip] Recommandation Placez toujours l'aide au début de la fonction ou du script. C'est la convention la plus répandue et la plus lisible.

---

## 🔍 Les mots-clés principaux

### `.SYNOPSIS`

Description ultra-courte en une phrase. C'est ce qui apparaît dans les listes de commandes.

```powershell
<#
.SYNOPSIS
    Sauvegarde les fichiers de configuration système
#>
```

> [!info] Bonne pratique Le synopsis doit tenir sur une ligne et commencer par un verbe d'action : Get, Set, Start, Stop, New, Remove, etc.

### `.DESCRIPTION`

Description complète et détaillée. Expliquez le contexte, le fonctionnement, les limitations.

```powershell
<#
.DESCRIPTION
    Cette fonction effectue une sauvegarde complète des fichiers
    de configuration système critiques vers un emplacement sécurisé.
    
    La sauvegarde inclut :
    - Les fichiers de configuration des services
    - Les clés de registre importantes
    - Les paramètres réseau
    
    Un fichier journal est créé à chaque exécution pour tracer
    toutes les opérations effectuées.
    
    La fonction nécessite des droits administrateur pour accéder
    à certains emplacements système.
#>
```

### `.PARAMETER`

Documentation détaillée de chaque paramètre. Un bloc `.PARAMETER` par paramètre.

```powershell
<#
.PARAMETER Destination
    Chemin complet du répertoire de destination pour la sauvegarde.
    Le répertoire doit exister et être accessible en écriture.
    Si non spécifié, utilise C:\Backups par défaut.
    
.PARAMETER IncludeRegistry
    Switch optionnel. Si présent, inclut également la sauvegarde
    des clés de registre système importantes.
    
.PARAMETER RetentionDays
    Nombre de jours de rétention des anciennes sauvegardes.
    Les sauvegardes plus anciennes sont automatiquement supprimées.
    Valeur par défaut : 30 jours.
    Plage acceptée : 1 à 365 jours.
#>
param(
    [string]$Destination = "C:\Backups",
    [switch]$IncludeRegistry,
    [ValidateRange(1,365)]
    [int]$RetentionDays = 30
)
```

> [!tip] Détaillez vos paramètres Pour chaque paramètre, indiquez :
> 
> - Ce qu'il fait
> - Son type et format attendu
> - Sa valeur par défaut (si applicable)
> - Les valeurs acceptées ou plages valides
> - S'il est obligatoire ou optionnel

### `.EXAMPLE`

Exemples concrets d'utilisation. Montrez plusieurs cas d'usage typiques.

```powershell
<#
.EXAMPLE
    Backup-SystemConfig
    
    Effectue une sauvegarde standard vers l'emplacement par défaut
    C:\Backups sans inclure le registre.

.EXAMPLE
    Backup-SystemConfig -Destination "D:\Sauvegardes" -IncludeRegistry
    
    Effectue une sauvegarde complète incluant le registre vers
    le répertoire D:\Sauvegardes.

.EXAMPLE
    Backup-SystemConfig -RetentionDays 60 -Verbose
    
    Effectue une sauvegarde avec une rétention de 60 jours et
    affiche les messages détaillés de progression.

.EXAMPLE
    Get-Server | Backup-SystemConfig -Destination "\\Nas\Backups"
    
    Sauvegarde la configuration de plusieurs serveurs reçus via
    le pipeline vers un partage réseau.
#>
```

> [!example] Structure d'un bon exemple
> 
> 1. La commande exacte à exécuter
> 2. Une ligne vide
> 3. Explication de ce que fait la commande
> 4. Optionnel : le résultat attendu

### `.INPUTS`

Types d'objets acceptés via le pipeline.

```powershell
<#
.INPUTS
    System.String
    Vous pouvez passer des noms de serveurs via le pipeline.
    
    System.Management.Automation.PSCustomObject
    Accepte également des objets personnalisés avec une propriété Name.
#>
```

### `.OUTPUTS`

Types d'objets retournés par la fonction.

```powershell
<#
.OUTPUTS
    System.Management.Automation.PSCustomObject
    Retourne un objet personnalisé contenant :
    - Server : Nom du serveur
    - BackupPath : Chemin de la sauvegarde
    - Success : Booléen indiquant le succès
    - Timestamp : Date et heure de la sauvegarde
    - FileCount : Nombre de fichiers sauvegardés
#>
```

### `.NOTES`

Informations complémentaires : auteur, version, prérequis, historique.

```powershell
<#
.NOTES
    Auteur          : Jean Dupont
    Organisation    : Contoso Ltd
    Date de création: 2024-01-15
    Dernière modif. : 2024-12-10
    Version         : 2.1.0
    
    Prérequis :
    - PowerShell 5.1 ou supérieur
    - Module ActiveDirectory installé
    - Droits administrateur sur les serveurs cibles
    - Accès réseau au partage de sauvegarde
    
    Historique des versions :
    1.0.0 (2024-01-15) : Version initiale
    1.5.0 (2024-06-20) : Ajout du support pipeline
    2.0.0 (2024-09-10) : Refonte complète avec gestion d'erreurs
    2.1.0 (2024-12-10) : Ajout de la rétention automatique
    
    Licence : MIT
#>
```

### `.LINK`

Liens vers documentation externe ou commandes associées.

```powershell
<#
.LINK
    https://docs.contoso.com/backup-procedures

.LINK
    https://github.com/contoso/backup-scripts

.LINK
    Get-Service

.LINK
    Restore-SystemConfig

.LINK
    about_Functions_Advanced_Parameters
#>
```

### `.COMPONENT`, `.ROLE`, `.FUNCTIONALITY`

Métadonnées pour catégoriser et organiser vos scripts.

```powershell
<#
.COMPONENT
    SystemMaintenance

.ROLE
    SystemAdministrator

.FUNCTIONALITY
    Backup and Recovery
#>
```

> [!info] Usage de ces mots-clés Ces trois mots-clés sont principalement utilisés pour organiser de grandes bibliothèques de scripts dans des contextes d'entreprise. Ils permettent de filtrer et rechercher des scripts par composant, rôle utilisateur, ou fonctionnalité technique.

---

## ✨ Bonnes pratiques de documentation

### 1. Cohérence et standardisation

Adoptez un style cohérent dans toute votre base de code.

```powershell
# ✅ BON : Style cohérent
<#
.SYNOPSIS
    Démarre le service de sauvegarde
    
.SYNOPSIS
    Arrête le service de sauvegarde
    
.SYNOPSIS
    Redémarre le service de sauvegarde
#>

# ❌ MAUVAIS : Styles incohérents
<#
.SYNOPSIS
    Démarre le service de sauvegarde
    
.SYNOPSIS
    Cette fonction permet d'arrêter le service
    
.SYNOPSIS
    RESTART BACKUP SERVICE
#>
```

### 2. Documentation proportionnelle à la complexité

```powershell
# Simple fonction utilitaire = documentation minimale
<#
.SYNOPSIS
    Convertit une chaîne en majuscules
.PARAMETER InputString
    La chaîne à convertir
#>
function ConvertTo-UpperCase {
    param([string]$InputString)
    return $InputString.ToUpper()
}

# Fonction complexe = documentation complète
<#
.SYNOPSIS
    Migre une base de données entre serveurs
    
.DESCRIPTION
    Effectue une migration complète d'une base de données SQL Server
    incluant le schéma, les données, les utilisateurs, et les jobs.
    Gère automatiquement la vérification de compatibilité, la sauvegarde
    de sécurité, et le rollback en cas d'erreur.
    
.PARAMETER SourceServer
    Serveur SQL source contenant la base à migrer
    
.PARAMETER DestinationServer
    Serveur SQL de destination
    
.PARAMETER DatabaseName
    Nom de la base de données à migrer
    
.PARAMETER BackupFirst
    Si activé, crée une sauvegarde complète avant migration
    
.EXAMPLE
    Migrate-Database -SourceServer "SQL01" -DestinationServer "SQL02" -DatabaseName "Production"
    
.NOTES
    Nécessite le module dbatools
    Droits sysadmin requis sur les deux serveurs
#>
```

### 3. Utilisez des verbes PowerShell approuvés

PowerShell a une liste de verbes approuvés (Get, Set, New, Remove, etc.). Utilisez-les dans vos SYNOPSIS.

```powershell
# ✅ BON : Verbes approuvés
Get-UserInfo      # Récupération
Set-UserInfo      # Modification
New-UserAccount   # Création
Remove-UserAccount # Suppression
Start-Service     # Démarrage
Stop-Service      # Arrêt
Test-Connection   # Test/Validation
Invoke-Command    # Exécution

# ❌ ÉVITEZ : Verbes non standard
Fetch-UserInfo    # Utilisez Get-
Change-UserInfo   # Utilisez Set-
Create-User       # Utilisez New-
Delete-User       # Utilisez Remove-
```

> [!tip] Vérifier les verbes approuvés Utilisez `Get-Verb` pour voir la liste complète des verbes approuvés par PowerShell.

### 4. Documentez les effets de bord et les prérequis

```powershell
<#
.SYNOPSIS
    Réinitialise le mot de passe d'un compte utilisateur

.DESCRIPTION
    Réinitialise le mot de passe et force le changement à la prochaine connexion.
    
    ⚠️ EFFETS DE BORD :
    - Déconnecte l'utilisateur de toutes ses sessions actives
    - Révoque tous les tokens d'authentification existants
    - Supprime les sessions RemoteApp/RDS en cours
    - Envoie un email de notification à l'utilisateur
    
    PRÉREQUIS :
    - Module ActiveDirectory installé
    - Droits "Reset Password" sur l'OU cible
    - Connexion réseau au contrôleur de domaine
    - Module ExchangeOnline pour l'envoi d'email

.NOTES
    ATTENTION : Cette action est irréversible et immédiate.
    L'utilisateur sera forcé de changer son mot de passe.
#>
```

### 5. Incluez des exemples variés

Montrez différents cas d'usage, du plus simple au plus complexe.

```powershell
<#
.EXAMPLE
    # Cas simple : utilisation de base
    Get-DiskSpace
    
    Affiche l'espace disque de tous les lecteurs locaux.

.EXAMPLE
    # Cas avec paramètres
    Get-DiskSpace -ComputerName "SERVER01" -Threshold 20
    
    Vérifie l'espace disque sur SERVER01 et alerte si < 20% libre.

.EXAMPLE
    # Cas pipeline
    Get-Content servers.txt | Get-DiskSpace -Threshold 10 | 
        Where-Object {$_.FreePercent -lt 10} | 
        Export-Csv "alert.csv"
    
    Analyse l'espace disque de plusieurs serveurs et exporte
    dans un CSV uniquement ceux ayant moins de 10% d'espace libre.

.EXAMPLE
    # Cas avancé avec tous les paramètres
    Get-DiskSpace -ComputerName "SERVER01","SERVER02" `
                  -Threshold 15 `
                  -ExcludeDrive "D:" `
                  -SendAlert `
                  -EmailTo "admin@contoso.com" `
                  -Verbose
    
    Analyse complète avec alertes email, exclusion du lecteur D:
    et affichage des messages détaillés.
#>
```

### 6. Maintenez la documentation à jour

```powershell
<#
.NOTES
    Dernière modification : 2024-12-10
    
    Historique :
    2024-12-10 : Ajout du paramètre -ExcludeDrive
    2024-11-15 : Correction du bug d'encodage UTF-8
    2024-10-01 : Ajout du support pour les disques réseaux
    2024-09-15 : Version initiale
    
    TODO :
    - Ajouter le support des disques virtuels
    - Implémenter le cache des résultats
    - Améliorer la gestion des timeouts réseau
#>
```

### 7. Utilisez un langage clair et précis

```powershell
# ❌ MAUVAIS : Vague et imprécis
<#
.SYNOPSIS
    Fait des trucs avec des fichiers
.DESCRIPTION
    Manipule des fichiers de différentes manières selon les options
#>

# ✅ BON : Clair et précis
<#
.SYNOPSIS
    Archive les fichiers journaux de plus de 30 jours
.DESCRIPTION
    Compresse les fichiers .log d'un répertoire spécifié qui ont
    une date de modification supérieure à 30 jours, puis les déplace
    vers un emplacement d'archivage en conservant la structure
    de répertoires originale.
#>
```

### 8. Documentez les valeurs de retour complexes

```powershell
<#
.OUTPUTS
    PSCustomObject
    Retourne un objet avec les propriétés suivantes :
    
    - ComputerName  [string]  : Nom du serveur analysé
    - DriveLetter   [string]  : Lettre du lecteur (ex: "C:")
    - TotalGB       [double]  : Capacité totale en Go
    - UsedGB        [double]  : Espace utilisé en Go
    - FreeGB        [double]  : Espace libre en Go
    - FreePercent   [int]     : Pourcentage d'espace libre (0-100)
    - Status        [string]  : "OK", "Warning", ou "Critical"
    - Timestamp     [datetime]: Date/heure de l'analyse
    
    Exemple de sortie :
    ComputerName : SERVER01
    DriveLetter  : C:
    TotalGB      : 500.00
    UsedGB       : 380.50
    FreeGB       : 119.50
    FreePercent  : 24
    Status       : Warning
    Timestamp    : 2024-12-10 14:30:00
#>
```

---

## 🔍 Génération et utilisation de l'aide

### Accéder à l'aide d'une fonction

Une fois votre fonction correctement documentée, l'aide est accessible via `Get-Help`.

```powershell
# Aide basique
Get-Help Get-DiskSpace

# Aide détaillée
Get-Help Get-DiskSpace -Detailed

# Aide complète (inclut les détails techniques)
Get-Help Get-DiskSpace -Full

# Uniquement les exemples
Get-Help Get-DiskSpace -Examples

# Uniquement les paramètres
Get-Help Get-DiskSpace -Parameter *

# Aide en ligne (ouvre le navigateur)
Get-Help Get-DiskSpace -Online

# Aide sur un paramètre spécifique
Get-Help Get-DiskSpace -Parameter ComputerName
```

### Affichage de l'aide dans la console

```powershell
# Affichage interactif (navigation avec flèches)
Get-Help Get-DiskSpace -ShowWindow
```

> [!tip] Astuce `-ShowWindow` ouvre une fenêtre séparée avec recherche intégrée, très pratique pour consulter l'aide de fonctions complexes.

### Tester votre documentation

Après avoir écrit votre Comment-Based Help, testez-le systématiquement :

```powershell
# Vérifiez que l'aide s'affiche
Get-Help Ma-Fonction

# Vérifiez que tous les paramètres sont documentés
Get-Help Ma-Fonction -Parameter *

# Vérifiez que les exemples fonctionnent
Get-Help Ma-Fonction -Examples
# Puis testez chaque exemple manuellement
```

### Génération automatique de documentation

Vous pouvez exporter l'aide vers différents formats pour créer une documentation externe.

```powershell
# Exporter l'aide en HTML
Get-Help Get-DiskSpace -Full | ConvertTo-Html | Out-File "help.html"

# Exporter toutes les fonctions d'un module
Get-Command -Module MonModule | ForEach-Object {
    $helpFile = "$($_.Name)_help.txt"
    Get-Help $_.Name -Full | Out-File $helpFile
}

# Créer une documentation complète du module
$commands = Get-Command -Module MonModule
foreach ($cmd in $commands) {
    $doc = @{
        Name = $cmd.Name
        Synopsis = (Get-Help $cmd.Name).Synopsis
        Description = (Get-Help $cmd.Name).Description.Text
        Examples = (Get-Help $cmd.Name).Examples
    }
    $doc | ConvertTo-Json | Out-File "$($cmd.Name).json"
}
```

### Validation de la documentation

PowerShell n'émet pas d'erreur si votre Comment-Based Help est mal formaté, mais l'aide ne s'affichera pas correctement.

```powershell
# ❌ Erreurs courantes qui cassent l'aide

# 1. Mot-clé mal orthographié
<#
.SYNOPIS  # Faute de frappe : devrait être .SYNOPSIS
    Description
#>

# 2. Pas de point avant le mot-clé
<#
SYNOPSIS  # Manque le point : devrait être .SYNOPSIS
    Description
#>

# 3. Mots-clés non alignés
<#
.SYNOPSIS
    Description
    .DESCRIPTION  # Mauvais : l'indentation casse le mot-clé
    Détails
#>

# ✅ Correct
<#
.SYNOPSIS
    Description courte

.DESCRIPTION
    Description détaillée
#>
```

> [!warning] Points d'attention
> 
> - Les mots-clés doivent commencer par un point et être sur leur propre ligne
> - Le contenu peut être indenté, mais pas les mots-clés
> - Pas d'espace entre le point et le mot-clé
> - Les mots-clés sont insensibles à la casse (.SYNOPSIS = .synopsis)

---

## 📊 Tableau récapitulatif des mots-clés

|Mot-clé|Obligatoire|Usage|Occurrences|
|---|---|---|---|
|`.SYNOPSIS`|Recommandé|Description courte (1 ligne)|1 seule|
|`.DESCRIPTION`|Recommandé|Description détaillée|1 seule|
|`.PARAMETER`|Si paramètres|Documentation d'un paramètre|1 par paramètre|
|`.EXAMPLE`|Recommandé|Exemple d'utilisation|Multiple|
|`.INPUTS`|Optionnel|Types acceptés en entrée|1 seule|
|`.OUTPUTS`|Optionnel|Types retournés|1 seule|
|`.NOTES`|Optionnel|Infos supplémentaires|1 seule|
|`.LINK`|Optionnel|Liens externes|Multiple|
|`.COMPONENT`|Optionnel|Catégorie composant|1 seule|
|`.ROLE`|Optionnel|Rôle utilisateur cible|1 seule|
|`.FUNCTIONALITY`|Optionnel|Fonctionnalité technique|1 seule|

---

## 🎯 Template complet de fonction documentée

Voici un template prêt à l'emploi pour vos fonctions PowerShell :

```powershell
function Verb-Noun {
    <#
    .SYNOPSIS
        Description courte en une phrase commençant par un verbe
    
    .DESCRIPTION
        Description complète et détaillée de la fonction.
        Expliquez le contexte, le fonctionnement, et les limitations.
        
        Cette section peut s'étendre sur plusieurs paragraphes
        pour couvrir tous les aspects importants.
    
    .PARAMETER ParamName
        Description complète du paramètre.
        Type attendu, valeurs acceptées, comportement par défaut.
    
    .EXAMPLE
        Verb-Noun -ParamName "valeur"
        
        Explication de ce que fait cet exemple.
    
    .EXAMPLE
        "valeur" | Verb-Noun
        
        Exemple d'utilisation avec le pipeline.
    
    .INPUTS
        System.String
        Description des types acceptés en entrée.
    
    .OUTPUTS
        System.Object
        Description des types retournés.
    
    .NOTES
        Auteur : Votre Nom
        Date : 2024-12-10
        Version : 1.0.0
        
        Prérequis :
        - PowerShell 5.1+
        - Droits requis
        
    .LINK
        https://docs.votre-site.com
    
    .LINK
        Get-RelatedCommand
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   HelpMessage="Description pour l'invite interactive")]
        [ValidateNotNullOrEmpty()]
        [string]$ParamName
    )
    
    begin {
        Write-Verbose "Début du traitement"
    }
    
    process {
        try {
            # Votre code ici
            Write-Verbose "Traitement de $ParamName"
        }
        catch {
            Write-Error "Erreur : $_"
        }
    }
    
    end {
        Write-Verbose "Fin du traitement"
    }
}
```

---

## 🎓 Résumé des points clés

> [!info] Points essentiels à retenir
> 
> **Commentaires simples :**
> 
> - `#` pour une ligne, `<# ... #>` pour plusieurs lignes
> - Utilisez-les avec parcimonie, le code doit être auto-explicatif
> - Conventions : TODO, FIXME, HACK, NOTE pour marquer des sections spéciales
> 
> **Comment-Based Help :**
> 
> - Structure standardisée pour générer une aide interactive
> - Accessible via `Get-Help` avec différents niveaux de détail
> - Placez le bloc d'aide au début de la fonction (convention recommandée)
> 
> **Mots-clés essentiels :**
> 
> - `.SYNOPSIS` : Description courte obligatoire
> - `.DESCRIPTION` : Explication détaillée
> - `.PARAMETER` : Un bloc par paramètre
> - `.EXAMPLE` : Plusieurs exemples d'utilisation
> - `.NOTES` : Métadonnées (auteur, version, prérequis)
> 
> **Bonnes pratiques :**
> 
> - Documentez proportionnellement à la complexité
> - Utilisez des verbes PowerShell approuvés (Get, Set, New, etc.)
> - Incluez plusieurs exemples du simple au complexe
> - Maintenez la documentation à jour avec le code
> - Testez votre aide avec `Get-Help` après création
> - Documentez les effets de bord et prérequis importants
> 
> **À éviter :**
> 
> - Commentaires redondants qui répètent le code
> - Documentation obsolète ou inexacte
> - Mots-clés mal formatés (sans point, mal indentés)
> - Exemples qui ne fonctionnent pas
> - Sur-documentation de code simple

---

## 💡 Cas pratiques et scénarios réels

### Scénario 1 : Script d'administration système

```powershell
function Backup-ServerConfiguration {
    <#
    .SYNOPSIS
        Sauvegarde la configuration complète d'un serveur Windows
    
    .DESCRIPTION
        Effectue une sauvegarde exhaustive incluant :
        - Configuration réseau (IP, DNS, routes)
        - Paramètres IIS (sites, pools d'applications)
        - Services Windows (état, démarrage)
        - Tâches planifiées
        - Clés de registre spécifiées
        
        La sauvegarde est compressée au format ZIP avec horodatage.
        Un fichier manifest JSON est créé pour documenter le contenu.
        
        IMPORTANT : Nécessite des privilèges administrateur.
    
    .PARAMETER ServerName
        Nom ou adresse IP du serveur à sauvegarder.
        Si non spécifié, utilise le serveur local.
        Le serveur doit être accessible via WinRM.
    
    .PARAMETER BackupPath
        Chemin du répertoire de destination pour la sauvegarde.
        Le répertoire sera créé automatiquement s'il n'existe pas.
        Format attendu : chemin UNC ou local (ex: "C:\Backups" ou "\\NAS\Backups")
    
    .PARAMETER IncludeIIS
        Switch pour inclure la configuration IIS.
        Requiert que IIS soit installé sur le serveur cible.
    
    .PARAMETER RegistryKeys
        Tableau de chemins de registre à sauvegarder.
        Format : "HKLM:\SOFTWARE\MonApp", "HKCU:\Environment"
    
    .PARAMETER Compress
        Active la compression ZIP du dossier de sauvegarde.
        Réduit significativement la taille mais augmente le temps de traitement.
    
    .EXAMPLE
        Backup-ServerConfiguration
        
        Sauvegarde la configuration du serveur local vers C:\Backups
        avec les paramètres par défaut (sans IIS, sans compression).
    
    .EXAMPLE
        Backup-ServerConfiguration -ServerName "WEB01" -IncludeIIS -Compress
        
        Sauvegarde complète du serveur WEB01 incluant IIS,
        avec compression ZIP du résultat.
    
    .EXAMPLE
        Backup-ServerConfiguration -BackupPath "\\NAS\Backups\Servers" `
                                   -RegistryKeys "HKLM:\SOFTWARE\MyApp" `
                                   -Verbose
        
        Sauvegarde avec chemin personnalisé, clé de registre spécifique,
        et affichage des messages détaillés de progression.
    
    .EXAMPLE
        $servers = "WEB01","WEB02","SQL01"
        $servers | ForEach-Object {
            Backup-ServerConfiguration -ServerName $_ -IncludeIIS
        }
        
        Sauvegarde en boucle de plusieurs serveurs.
    
    .INPUTS
        System.String
        Peut accepter des noms de serveur via le pipeline.
    
    .OUTPUTS
        PSCustomObject
        Retourne un objet avec :
        - ServerName : Nom du serveur sauvegardé
        - BackupFile : Chemin complet du fichier de sauvegarde
        - SizeGB : Taille de la sauvegarde en Go
        - Duration : Durée de l'opération (TimeSpan)
        - Success : Booléen indiquant le succès
        - Timestamp : Date/heure de la sauvegarde
        - ItemCount : Nombre d'éléments sauvegardés
    
    .NOTES
        Auteur          : Service Infrastructure
        Version         : 2.3.1
        Date            : 2024-12-10
        PowerShell      : 5.1 minimum
        
        Prérequis :
        - Droits administrateur local ou distant
        - WinRM activé et configuré sur les serveurs cibles
        - Accès en écriture au chemin de sauvegarde
        - Module WebAdministration (si -IncludeIIS)
        
        Limitations :
        - Ne sauvegarde pas les mots de passe en clair
        - Taille maximale recommandée : 50 GB
        - Timeout WinRM : 30 minutes
        
        Changements récents :
        2.3.1 (2024-12-10) : Correction bug compression fichiers > 2GB
        2.3.0 (2024-11-15) : Ajout support serveurs Core
        2.2.0 (2024-10-01) : Amélioration performances IIS
    
    .LINK
        https://docs.contoso.com/backup-procedures
    
    .LINK
        Restore-ServerConfiguration
    
    .LINK
        Test-ServerBackup
    
    .LINK
        about_Remote_Requirements
    #>
    
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(ValueFromPipeline=$true)]
        [string]$ServerName = $env:COMPUTERNAME,
        
        [ValidateScript({Test-Path $_ -IsValid})]
        [string]$BackupPath = "C:\Backups",
        
        [switch]$IncludeIIS,
        
        [string[]]$RegistryKeys = @(),
        
        [switch]$Compress
    )
    
    begin {
        Write-Verbose "Initialisation de la sauvegarde..."
        # TODO: Ajouter validation de l'espace disque disponible
    }
    
    process {
        # Code de la fonction...
    }
}
```

### Scénario 2 : Script de maintenance légère

```powershell
function Clear-TempFiles {
    <#
    .SYNOPSIS
        Nettoie les fichiers temporaires de Windows
    
    .DESCRIPTION
        Supprime les fichiers temporaires des emplacements standards :
        - %TEMP%
        - C:\Windows\Temp
        - Dossiers temp des profils utilisateurs
        
        Les fichiers de moins de 24h et les fichiers verrouillés sont ignorés.
    
    .PARAMETER OlderThanDays
        Supprime uniquement les fichiers plus anciens que X jours.
        Valeur par défaut : 7 jours
    
    .EXAMPLE
        Clear-TempFiles
        
        Nettoie les fichiers temporaires de plus de 7 jours.
    
    .EXAMPLE
        Clear-TempFiles -OlderThanDays 30
        
        Nettoie uniquement les fichiers de plus de 30 jours.
    
    .NOTES
        Version : 1.0
        Prérequis : Droits administrateur pour C:\Windows\Temp
    #>
    
    param(
        [int]$OlderThanDays = 7
    )
    
    $cutoffDate = (Get-Date).AddDays(-$OlderThanDays)
    
    # Liste des chemins à nettoyer
    $tempPaths = @(
        $env:TEMP,
        "C:\Windows\Temp"
    )
    
    foreach ($path in $tempPaths) {
        if (Test-Path $path) {
            Get-ChildItem $path -Recurse -File |
                Where-Object {$_.LastWriteTime -lt $cutoffDate} |
                Remove-Item -Force -ErrorAction SilentlyContinue
        }
    }
}
```

### Scénario 3 : Documentation d'une fonction pipeline

```powershell
function ConvertTo-TitleCase {
    <#
    .SYNOPSIS
        Convertit du texte en casse de titre (Title Case)
    
    .DESCRIPTION
        Transforme une chaîne de caractères en format "Title Case"
        où chaque mot commence par une majuscule.
        
        Cette fonction est optimisée pour le pipeline et peut traiter
        de grandes quantités de texte efficacement.
        
        Mots exclus (toujours en minuscules) : le, la, les, un, une, des,
        de, du, et, ou, à, en, dans (sauf en début de phrase).
    
    .PARAMETER InputText
        Texte à convertir. Accepte le pipeline.
        Peut être une chaîne simple ou un tableau de chaînes.
    
    .PARAMETER Locale
        Locale à utiliser pour la conversion.
        Valeurs acceptées : "fr-FR", "en-US", "de-DE"
        Par défaut : "fr-FR"
    
    .PARAMETER IgnoreWords
        Tableau de mots à ne pas capitaliser (sauf en début).
        Remplace la liste par défaut si spécifié.
    
    .EXAMPLE
        ConvertTo-TitleCase -InputText "bonjour le monde"
        
        Résultat : "Bonjour le Monde"
    
    .EXAMPLE
        "le chat et le chien" | ConvertTo-TitleCase
        
        Résultat : "Le Chat et le Chien"
        (Note : "Le" est capitalisé car en début, "le" reste minuscule)
    
    .EXAMPLE
        Get-Content noms.txt | ConvertTo-TitleCase | Set-Content noms_clean.txt
        
        Lit un fichier, convertit chaque ligne, et sauvegarde le résultat.
    
    .EXAMPLE
        @("JEAN DUPONT", "marie martin", "Pierre DURANT") | ConvertTo-TitleCase
        
        Résultat :
        Jean Dupont
        Marie Martin
        Pierre Durant
    
    .INPUTS
        System.String
        System.String[]
    
    .OUTPUTS
        System.String
        Retourne le texte converti en Title Case.
    
    .NOTES
        Version : 1.2
        Performance : ~100 000 lignes/seconde sur CPU moderne
        
        Cas particuliers gérés :
        - Acronymes (IBM, NASA) : conservés en majuscules
        - Noms composés : Jean-Pierre devient Jean-Pierre
        - Apostrophes : l'homme devient L'Homme
    
    .LINK
        about_Pipeline
    #>
    
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=0)]
        [string[]]$InputText,
        
        [ValidateSet("fr-FR","en-US","de-DE")]
        [string]$Locale = "fr-FR",
        
        [string[]]$IgnoreWords = @("le","la","les","un","une","des","de","du","et","ou")
    )
    
    process {
        foreach ($text in $InputText) {
            # HACK: Utilisation de TextInfo pour la conversion de base
            # TODO: Implémenter gestion personnalisée des acronymes
            $textInfo = (Get-Culture $Locale).TextInfo
            $result = $textInfo.ToTitleCase($text.ToLower())
            
            # Traitement des mots à ignorer (sauf premier mot)
            # Code simplifié pour l'exemple...
            
            Write-Output $result
        }
    }
}
```

---

## 🚀 Techniques avancées de documentation

### Documentation inline pour logique complexe

Parfois, la logique métier nécessite des explications détaillées au sein même du code :

```powershell
function Calculate-BusinessDays {
    param(
        [datetime]$StartDate,
        [datetime]$EndDate
    )
    
    <#
        ALGORITHME DE CALCUL DES JOURS OUVRÉS :
        ========================================
        1. Calculer le nombre total de jours dans la période
        2. Soustraire les weekends complets (samedi + dimanche)
        3. Ajuster pour les weekends partiels en début/fin
        4. Soustraire les jours fériés dans la période
        
        FORMULE MATHÉMATIQUE :
        BusinessDays = TotalDays - (Weekends × 2) - Holidays
        
        Où Weekends = floor(TotalDays / 7) + PartialWeekendDays
    #>
    
    # Étape 1 : Calcul du nombre total de jours
    $totalDays = ($EndDate - $StartDate).Days + 1
    
    # Étape 2 : Calcul des weekends complets
    # Division par 7 pour obtenir le nombre de semaines complètes
    $fullWeeks = [Math]::Floor($totalDays / 7)
    $weekendDays = $fullWeeks * 2
    
    # Étape 3 : Gestion des weekends partiels
    # IMPORTANT : Les jours résiduels peuvent inclure un weekend partiel
    $remainingDays = $totalDays % 7
    $currentDay = $StartDate
    
    # NOTE : On parcourt les jours résiduels pour détecter samedi/dimanche
    for ($i = 0; $i -lt $remainingDays; $i++) {
        $dayOfWeek = $currentDay.DayOfWeek
        if ($dayOfWeek -eq 'Saturday' -or $dayOfWeek -eq 'Sunday') {
            $weekendDays++
        }
        $currentDay = $currentDay.AddDays(1)
    }
    
    # Étape 4 : Soustraction des jours fériés
    # FIXME: Actuellement utilise une liste statique, devrait interroger une API
    $holidays = Get-FrenchHolidays -Year $StartDate.Year
    $holidaysInRange = $holidays | Where-Object {
        $_ -ge $StartDate -and $_ -le $EndDate -and
        $_.DayOfWeek -ne 'Saturday' -and $_.DayOfWeek -ne 'Sunday'
    }
    
    # RÉSULTAT FINAL
    $businessDays = $totalDays - $weekendDays - $holidaysInRange.Count
    
    return $businessDays
}
```

### Documentation de décisions architecturales

```powershell
<#
.SYNOPSIS
    Synchronise les données entre deux bases de données

.DESCRIPTION
    DÉCISIONS ARCHITECTURALES :
    ===========================
    
    ⚠️ POURQUOI UTILISER UN STAGING TABLE :
    Nous utilisons une table de staging temporaire plutôt qu'une
    synchronisation directe pour les raisons suivantes :
    
    1. PERFORMANCE : La synchronisation directe provoquait des deadlocks
       sur des tables avec > 1M de lignes (testé en prod le 2024-08-15)
    
    2. ROLLBACK : En cas d'erreur, la table de staging peut être supprimée
       sans impact sur les données de production
    
    3. VALIDATION : Permet de valider les données avant commit final
       (contraintes, intégrité référentielle)
    
    4. AUDIT : La table temporaire conserve un log de toutes les
       tentatives de synchronisation pour analyse post-mortem
    
    ⚠️ POURQUOI NE PAS UTILISER MERGE :
    L'instruction SQL MERGE a été testée mais abandonnée car :
    - Bug connu de MERGE avec triggers (KB2334880)
    - Performances 40% moins bonnes que INSERT/UPDATE séparés
    - Logging impossible avec OUTPUT clause dans notre config
    
    CHOIX TECHNIQUE FINAL :
    Utilisation de INSERT/UPDATE séparés avec table staging
    Compromis optimal : performance, sécurité, maintenabilité
    
    ALTERNATIVE CONSIDÉRÉE :
    Azure Data Factory a été évalué mais rejeté car :
    - Coût : ~500€/mois vs solution in-house gratuite
    - Dépendance externe
    - Over-engineering pour notre volumétrie (< 10M lignes)
#>
```

### Documentation des performances

```powershell
<#
.SYNOPSIS
    Analyse les logs IIS pour générer des statistiques

.DESCRIPTION
    OPTIMISATIONS PERFORMANCES :
    ============================
    
    Cette fonction traite des fichiers de logs volumineux (> 1GB).
    Plusieurs optimisations ont été implémentées :
    
    1. STREAMING :
       Utilise Get-Content -ReadCount pour traiter par blocs de 10000 lignes
       au lieu de charger le fichier entier en mémoire.
       ✅ Avant : 8 GB RAM, 45 sec
       ✅ Après : 500 MB RAM, 12 sec
    
    2. REGEX COMPILÉE :
       La regex de parsing est compilée avec [RegexOptions]::Compiled
       pour améliorer les performances sur grandes volumétries.
       ✅ Gain : 35% plus rapide sur 1M lignes
    
    3. HASHTABLE VS ARRAY :
       Utilisation de hashtable pour l'agrégation au lieu d'un array.
       ✅ Complexité O(1) vs O(n) pour la recherche
       ✅ Gain : 10x plus rapide sur > 100K URLs uniques
    
    4. PARALLÉLISATION :
       Si plusieurs fichiers, utilise ForEach-Object -Parallel (PS 7+)
       ✅ Gain : quasi-linéaire avec nombre de cores (4x sur 4 cores)
    
    BENCHMARKS (fichier 1 GB, 10M lignes) :
    - Surface Pro 8 (i7, 16GB) : 12 secondes
    - Serveur (Xeon, 64GB)     : 4 secondes
    - Laptop ancien (i5, 8GB)  : 35 secondes
    
.NOTES
    Profiling effectué avec Measure-Command et Performance Monitor
    Tests de charge réalisés le 2024-11-20
    Environnement de test : Windows Server 2022, PowerShell 7.4
#>
```

---

## 🔍 Débogage et troubleshooting de la documentation

### Problème : L'aide ne s'affiche pas

```powershell
# ❌ SYMPTÔME : Get-Help Ma-Fonction ne montre rien

# DIAGNOSTIC :
# 1. Vérifier que la fonction est chargée
Get-Command Ma-Fonction

# 2. Vérifier la syntaxe du Comment-Based Help
# Cause fréquente : mot-clé mal formaté

# ❌ INCORRECT :
<#
SYNOPSIS  # Manque le point
.DESCRIPTION
    blabla
    .EXAMPLE  # Mauvaise indentation
#>

# ✅ CORRECT :
<#
.SYNOPSIS
    Description
.DESCRIPTION
    Détails
.EXAMPLE
    Exemple
#>
```

### Problème : Les paramètres ne s'affichent pas correctement

```powershell
# ❌ SYMPTÔME : Get-Help Ma-Fonction -Parameter * ne montre rien

# CAUSE : Nom de paramètre incorrect dans .PARAMETER

function Test-Fonction {
    <#
    .PARAMETER Nom  # ❌ Le paramètre s'appelle "Username" pas "Nom"
        Description
    #>
    param([string]$Username)
}

# ✅ SOLUTION : Faire correspondre exactement
function Test-Fonction {
    <#
    .PARAMETER Username  # ✅ Correspond au param()
        Description
    #>
    param([string]$Username)
}

# ASTUCE : Vérification automatique
$function = Get-Command Test-Fonction
$helpParams = (Get-Help Test-Fonction).Parameters.Parameter.Name
$actualParams = $function.Parameters.Keys

# Comparer les deux listes
Compare-Object $helpParams $actualParams
```

### Problème : Les exemples ne fonctionnent pas

```powershell
<#
.EXAMPLE
    Get-UserData -ID 12345
    
    Récupère les données de l'utilisateur 12345
#>

# ⚠️ PROBLÈME : L'exemple ne fonctionne pas car le paramètre
# ID est défini comme [int] mais l'exemple ne le montre pas clairement

# ✅ MEILLEURE APPROCHE : Tester chaque exemple
function Test-Examples {
    param([string]$FunctionName)
    
    $help = Get-Help $FunctionName
    $examples = $help.Examples.Example
    
    foreach ($ex in $examples) {
        Write-Host "Test de : $($ex.Code)" -ForegroundColor Cyan
        try {
            # ATTENTION : N'exécutez pas automatiquement les exemples
            # sans vérification manuelle !
            Write-Host "⚠️ Vérification manuelle requise" -ForegroundColor Yellow
        }
        catch {
            Write-Host "❌ Exemple cassé : $_" -ForegroundColor Red
        }
    }
}
```

---

## 🎨 Style et conventions de documentation

### Convention de nommage des fonctions

```powershell
# ✅ BON : Verbe-Nom
Get-UserProfile
Set-ServerConfiguration
New-BackupJob
Remove-TempFile
Test-Connection
Invoke-ApiCall

# ❌ MAUVAIS : Pas de verbe ou verbe non standard
UserProfile          # Manque le verbe
Fetch-Data           # "Fetch" n'est pas approuvé, utilisez Get
CreateBackup         # Pas de tiret, utilisez New-Backup
DeleteFile           # Utilisez Remove-File
CheckConnection      # Utilisez Test-Connection
```

### Style de rédaction de la documentation

```powershell
# ✅ BON : Clair, concis, actif
<#
.SYNOPSIS
    Crée une sauvegarde des fichiers de configuration

.DESCRIPTION
    Cette fonction sauvegarde les fichiers de configuration système
    vers un emplacement sécurisé. Elle vérifie l'intégrité des fichiers
    avant et après la copie.
#>

# ❌ MAUVAIS : Vague, passif, trop verbeux
<#
.SYNOPSIS
    Une fonction qui peut être utilisée pour créer des sauvegardes

.DESCRIPTION
    Cette fonction a été créée dans le but de permettre aux administrateurs
    système de pouvoir effectuer des sauvegardes de différents types de
    fichiers de configuration qui pourraient être importants pour le système.
    Les fichiers sont copiés vers un emplacement qui devrait être sécurisé
    et il y a une vérification qui est effectuée.
#>
```

### Documentation multilingue (optionnel)

Si vous travaillez dans un environnement international :

```powershell
<#
.SYNOPSIS
    [FR] Sauvegarde la configuration du serveur
    [EN] Backs up server configuration

.DESCRIPTION
    [FR] Cette fonction effectue une sauvegarde complète de la configuration
    incluant les services, le registre et les paramètres réseau.
    
    [EN] This function performs a complete backup of the configuration
    including services, registry and network settings.

.PARAMETER ServerName
    [FR] Nom du serveur à sauvegarder
    [EN] Name of the server to backup

.EXAMPLE
    Backup-ServerConfig -ServerName "WEB01"
    
    [FR] Sauvegarde la configuration du serveur WEB01
    [EN] Backs up configuration of server WEB01
#>
```

---

## ✅ Checklist finale de documentation

Avant de considérer votre documentation comme terminée, vérifiez ces points :

> [!tip] Checklist de qualité
> 
> **Structure :**
> 
> - [ ] `.SYNOPSIS` présent et en une ligne
> - [ ] `.DESCRIPTION` détaillée et complète
> - [ ] Un `.PARAMETER` par paramètre existant
> - [ ] Au moins 2-3 `.EXAMPLE` variés
> - [ ] `.NOTES` avec auteur, version, date
> 
> **Contenu :**
> 
> - [ ] Tous les paramètres sont documentés
> - [ ] Les exemples sont testés et fonctionnels
> - [ ] Les prérequis sont clairement indiqués
> - [ ] Les effets de bord sont mentionnés
> - [ ] Les limitations sont documentées
> 
> **Qualité :**
> 
> - [ ] Aucune faute d'orthographe
> - [ ] Langage clair et professionnel
> - [ ] Pas de jargon sans explication
> - [ ] Cohérent avec le reste de la base de code
> 
> **Tests :**
> 
> - [ ] `Get-Help Ma-Fonction` fonctionne
> - [ ] `Get-Help Ma-Fonction -Examples` affiche les exemples
> - [ ] `Get-Help Ma-Fonction -Parameter *` liste tous les paramètres
> - [ ] Tous les exemples ont été testés manuellement

---

## 🎯 Conclusion

La documentation en PowerShell n'est pas une option, c'est une nécessité professionnelle. Un code bien documenté avec Comment-Based Help devient :

- **Maintenable** : Les futurs développeurs (vous y compris) comprennent rapidement le code
- **Réutilisable** : L'aide intégrée facilite la réutilisation dans d'autres contextes
- **Professionnel** : Démontre une rigueur et un soin du détail
- **Collaboratif** : Facilite le travail en équipe et le partage de connaissances

> [!warning] Règle d'or **"Le meilleur moment pour documenter votre code, c'est MAINTENANT."**
> 
> N'attendez pas la fin du projet, documentez au fur et à mesure. Le temps "perdu" en documentation est largement récupéré lors de la maintenance et du débogage.