

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

## 1. Module ActiveDirectory

### 1.1 Installation et import

#### Présentation du module

Le module **ActiveDirectory** est la boîte à outils PowerShell essentielle pour administrer Active Directory. Il permet de gérer tous les objets AD (utilisateurs, groupes, ordinateurs, OUs, etc.) directement depuis PowerShell sans passer par l'interface graphique.

> [!info] Qu'est-ce que le module ActiveDirectory ? Le module ActiveDirectory fait partie des **RSAT** (Remote Server Administration Tools), un ensemble d'outils Microsoft permettant d'administrer à distance les serveurs Windows. Il contient plus de 140 cmdlets dédiées à la gestion d'Active Directory.

**Pourquoi utiliser ce module ?**

- Automatisation des tâches répétitives (création de comptes en masse, modifications groupées)
- Scripts d'audit et de reporting
- Administration à distance depuis un poste client
- Intégration dans des workflows automatisés
- Gain de temps considérable par rapport à l'interface graphique

**Où est-il disponible ?**

- Sur les serveurs Windows avec le rôle **AD DS** (Active Directory Domain Services) installé
- Sur les postes clients Windows après installation de RSAT
- Nécessite une connexion réseau à un contrôleur de domaine

---

#### Installation sur Windows 10/11

Il existe deux méthodes pour installer le module sur les postes clients Windows 10 ou Windows 11.

##### Méthode 1 : Via l'interface graphique

1. Ouvrir **Paramètres** → **Applications** → **Fonctionnalités facultatives**
2. Cliquer sur **Ajouter une fonctionnalité**
3. Rechercher **"RSAT: Active Directory Domain Services and Lightweight Directory Services Tools"**
4. Sélectionner et cliquer sur **Installer**
5. Redémarrer si nécessaire

> [!tip] Astuce de recherche Dans la barre de recherche des fonctionnalités, tapez simplement "RSAT" ou "Active Directory" pour filtrer rapidement les résultats.

##### Méthode 2 : Via PowerShell (recommandé)

Cette méthode est plus rapide et scriptable pour des déploiements en masse.

```powershell
# Lister les capacités RSAT disponibles pour Active Directory
Get-WindowsCapability -Name RSAT.ActiveDirectory* -Online

# Installer le module Active Directory
Add-WindowsCapability -Name "RSAT.ActiveDirectory.DS-LDS.Tools~~~~0.0.1.0" -Online
```

> [!warning] Élévation des privilèges L'installation nécessite des **droits administrateur**. Lancez PowerShell en tant qu'administrateur (clic droit → "Exécuter en tant qu'administrateur").

**Explication de la commande :**

- `Get-WindowsCapability` : Liste les fonctionnalités Windows disponibles
- `-Name RSAT.ActiveDirectory*` : Filtre sur les outils Active Directory
- `-Online` : Recherche sur les serveurs Microsoft (nécessite Internet)
- `Add-WindowsCapability` : Installe la fonctionnalité
- Le nom complet inclut la version (`~~~~0.0.1.0`)

**Vérification de l'installation :**

```powershell
# Vérifier si la fonctionnalité est installée
Get-WindowsCapability -Name "RSAT.ActiveDirectory.DS-LDS.Tools*" -Online | Select-Object Name, State

# Résultat attendu : State = Installed
```

---

#### Installation sur Windows Server

Sur Windows Server, le module fait généralement partie des outils RSAT qui s'installent avec le rôle AD DS, mais il peut aussi être installé séparément.

##### Méthode 1 : Via Server Manager

1. Ouvrir **Server Manager**
2. Cliquer sur **Manage** → **Add Roles and Features**
3. Suivre l'assistant jusqu'à **Features**
4. Développer **Remote Server Administration Tools** → **Role Administration Tools** → **AD DS and AD LDS Tools**
5. Cocher **Active Directory module for Windows PowerShell**
6. Compléter l'installation

##### Méthode 2 : Via PowerShell (recommandé)

```powershell
# Installer le module PowerShell pour Active Directory
Install-WindowsFeature RSAT-AD-PowerShell

# Installation avec barre de progression et redémarrage automatique si nécessaire
Install-WindowsFeature RSAT-AD-PowerShell -IncludeManagementTools -Restart
```

> [!info] Différence avec les clients Sur Windows Server, on utilise `Install-WindowsFeature` (cmdlet pour les fonctionnalités serveur) au lieu de `Add-WindowsCapability` (pour les clients Windows).

**Options utiles :**

- `-IncludeManagementTools` : Installe aussi les outils graphiques AD
- `-Restart` : Redémarre automatiquement si nécessaire
- `-Verbose` : Affiche des informations détaillées pendant l'installation

**Vérification de l'installation :**

```powershell
# Vérifier si la fonctionnalité est installée
Get-WindowsFeature RSAT-AD-PowerShell

# Résultat : Install State = Installed
```

---

#### Import et vérification

Une fois installé, le module doit être importé dans votre session PowerShell pour être utilisable.

##### Import du module

```powershell
# Import explicite du module
Import-Module ActiveDirectory

# Vérifier que l'import a réussi (aucune erreur = succès)
```

> [!tip] Import automatique À partir de **PowerShell 3.0**, le module s'importe automatiquement dès que vous utilisez une de ses cmdlets. L'import explicite n'est donc pas obligatoire, mais reste une bonne pratique pour s'assurer de sa disponibilité au début d'un script.

**Pourquoi importer explicitement ?**

- Détection précoce des problèmes d'installation
- Clarté du code (on sait quels modules sont utilisés)
- Compatibilité avec les anciennes versions de PowerShell

##### Vérifier la disponibilité du module

```powershell
# Vérifier si le module est installé
Get-Module -Name ActiveDirectory -ListAvailable

# Vérifier si le module est chargé dans la session actuelle
Get-Module -Name ActiveDirectory

# Afficher des informations détaillées sur le module
Get-Module -Name ActiveDirectory -ListAvailable | Select-Object Name, Version, ModuleType, Path
```

**Interprétation des résultats :**

- `-ListAvailable` : Cherche dans tous les modules installés (même non chargés)
- Sans `-ListAvailable` : Affiche uniquement les modules chargés en mémoire
- Si aucun résultat : le module n'est pas installé

##### Lister les cmdlets disponibles

```powershell
# Lister toutes les cmdlets du module ActiveDirectory
Get-Command -Module ActiveDirectory

# Compter le nombre de cmdlets
(Get-Command -Module ActiveDirectory).Count

# Filtrer par type de cmdlet (ex: tout ce qui concerne les utilisateurs)
Get-Command -Module ActiveDirectory -Name *User*

# Afficher avec description
Get-Command -Module ActiveDirectory | Select-Object Name, CommandType | Format-Table -AutoSize
```

> [!example] Exemples de cmdlets courantes
> 
> - `Get-ADUser` : Récupérer des utilisateurs
> - `New-ADUser` : Créer un utilisateur
> - `Set-ADUser` : Modifier un utilisateur
> - `Get-ADGroup` : Récupérer des groupes
> - `Get-ADComputer` : Récupérer des ordinateurs
> - `Get-ADOrganizationalUnit` : Récupérer des OUs

##### Obtenir de l'aide

```powershell
# Aide complète sur une cmdlet
Get-Help Get-ADUser -Full

# Exemples d'utilisation
Get-Help Get-ADUser -Examples

# Aide en ligne (plus récente)
Get-Help Get-ADUser -Online

# Liste des paramètres
Get-Help Get-ADUser -Parameter *
```

---

#### Prérequis et compatibilité

Pour utiliser efficacement le module ActiveDirectory, plusieurs conditions doivent être remplies.

##### Prérequis techniques

|Prérequis|Description|
|---|---|
|**Droits d'administration**|Droits appropriés sur Active Directory (lecture minimum, modification pour certaines opérations)|
|**Connectivité réseau**|Connexion réseau vers au moins un contrôleur de domaine|
|**Résolution DNS**|DNS correctement configuré pour résoudre le domaine AD|
|**Ports réseau**|Ports nécessaires ouverts (voir tableau ci-dessous)|
|**Appartenance au domaine**|Machine jointe au domaine (recommandé mais pas obligatoire)|

**Ports réseau utilisés :**

|Port|Protocole|Utilisation|
|---|---|---|
|389|TCP/UDP|LDAP (Lightweight Directory Access Protocol)|
|636|TCP|LDAPS (LDAP sur SSL/TLS)|
|3268|TCP|Global Catalog (LDAP)|
|3269|TCP|Global Catalog (LDAPS)|
|88|TCP/UDP|Kerberos|
|53|TCP/UDP|DNS|

> [!warning] Pare-feu Si vous administrez AD depuis un poste distant, assurez-vous que ces ports sont ouverts dans les pare-feu entre votre machine et les contrôleurs de domaine.

##### Permissions Active Directory requises

Les permissions nécessaires dépendent de l'opération :

```powershell
# Opérations de LECTURE : nécessitent les droits de lecture standard
# - Get-ADUser, Get-ADGroup, Get-ADComputer, etc.
# - Par défaut, tous les utilisateurs authentifiés peuvent lire l'AD

# Opérations de MODIFICATION : nécessitent des droits élevés
# - New-ADUser, Set-ADUser, Remove-ADUser, etc.
# - Nécessitent généralement l'appartenance au groupe "Account Operators" ou "Domain Admins"

# Vérifier vos permissions actuelles
whoami /groups
```

> [!tip] Connexion avec des credentials alternatifs Si votre compte actuel n'a pas les droits nécessaires, la plupart des cmdlets acceptent le paramètre `-Credential` pour spécifier un compte différent.

```powershell
# Demander les identifiants et les stocker
$cred = Get-Credential

# Utiliser ces identifiants pour une opération AD
Get-ADUser -Identity "jdupont" -Credential $cred
```

##### Compatibilité des versions

|Environnement|Compatibilité|Notes|
|---|---|---|
|**Windows PowerShell 5.1**|✅ Entièrement compatible|Version recommandée pour la production|
|**PowerShell 7+**|⚠️ Compatible avec limitations|Fonctionne via la compatibilité Windows PowerShell|
|**.NET Framework**|Requis sur Windows|Le module nécessite .NET Framework|
|**Windows 10/11**|✅ Compatible|Après installation RSAT|
|**Windows Server 2016+**|✅ Entièrement compatible|Support natif|
|**Linux / macOS**|❌ Non supporté|Le module utilise des API Windows uniquement|

> [!warning] PowerShell 7+ sur Windows Bien que PowerShell 7+ puisse charger le module via la couche de compatibilité Windows PowerShell, certaines fonctionnalités avancées peuvent ne pas fonctionner parfaitement. Pour l'administration AD en production, **Windows PowerShell 5.1** reste le choix le plus sûr.

##### Vérifier la configuration

```powershell
# Vérifier la version de PowerShell
$PSVersionTable

# Vérifier la connectivité vers un contrôleur de domaine
Test-Connection -ComputerName (Get-ADDomainController).HostName -Count 2

# Vérifier le domaine actuel
(Get-ADDomain).DNSRoot

# Tester une requête simple
Get-ADUser -Filter {Name -like "*"} -ResultSetSize 1
```

##### Bonnes pratiques d'installation

1. **Sur les serveurs** : Installer systématiquement lors du déploiement AD DS
2. **Sur les postes administrateurs** : Installer via RSAT pour administration à distance
3. **Scripts de déploiement** : Automatiser l'installation sur tous les postes administratifs
4. **Documentation** : Maintenir une liste des machines avec RSAT installé
5. **Mises à jour** : Vérifier régulièrement les mises à jour de RSAT

> [!tip] Script de vérification pour un environnement Créez un script qui vérifie l'installation du module sur toutes vos machines administratives pour vous assurer que votre équipe a les outils nécessaires.

```powershell
# Script simple de vérification à distance
$computers = "PC-ADMIN1", "PC-ADMIN2", "PC-ADMIN3"

foreach ($computer in $computers) {
    $result = Invoke-Command -ComputerName $computer -ScriptBlock {
        Get-Module -Name ActiveDirectory -ListAvailable
    } -ErrorAction SilentlyContinue
    
    if ($result) {
        Write-Host "✅ $computer : Module installé (version $($result.Version))" -ForegroundColor Green
    } else {
        Write-Host "❌ $computer : Module NON installé" -ForegroundColor Red
    }
}
```

---

## 🎯 Points clés à retenir

- Le module ActiveDirectory fait partie de RSAT et contient 140+ cmdlets
- Installation différente selon l'OS : `Add-WindowsCapability` (clients) vs `Install-WindowsFeature` (serveurs)
- Import automatique depuis PowerShell 3.0, mais l'import explicite reste recommandé
- Nécessite des droits AD appropriés et une connectivité réseau vers les DC
- Windows PowerShell 5.1 est la version recommandée pour l'administration AD
- Vérifiez toujours l'installation avec `Get-Module -ListAvailable`

---