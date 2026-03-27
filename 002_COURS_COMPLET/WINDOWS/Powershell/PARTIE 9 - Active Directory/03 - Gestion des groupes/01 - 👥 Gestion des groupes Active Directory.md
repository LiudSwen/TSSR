

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

## 🎯 Introduction aux groupes AD

Les groupes Active Directory sont des conteneurs logiques permettant d'organiser les utilisateurs, ordinateurs et autres groupes pour faciliter l'administration des permissions et la distribution d'emails. PowerShell offre des cmdlets puissantes pour automatiser leur gestion.

> [!info] Pourquoi gérer les groupes via PowerShell ?
> 
> - **Automatisation** : création en masse et provisioning
> - **Cohérence** : application de conventions de nommage
> - **Audit** : extraction rapide d'informations
> - **Efficacité** : manipulation de centaines de groupes simultanément

---

## 🔍 Get-ADGroup - Récupération de groupes

### Vue d'ensemble

`Get-ADGroup` permet d'interroger Active Directory pour récupérer des informations sur un ou plusieurs groupes. C'est l'équivalent PowerShell de la recherche dans "Utilisateurs et ordinateurs Active Directory".

### Syntaxe de base

```powershell
Get-ADGroup -Identity "NomDuGroupe"
Get-ADGroup -Filter {Critères}
Get-ADGroup -SearchBase "OU=Groups,DC=contoso,DC=com"
```

---

### 🎯 Recherche par identité

La méthode la plus directe pour récupérer un groupe spécifique.

```powershell
# Recherche par nom
Get-ADGroup -Identity "IT-Admins"

# Recherche par Distinguished Name (DN)
Get-ADGroup -Identity "CN=IT-Admins,OU=Groups,DC=contoso,DC=com"

# Recherche par GUID
Get-ADGroup -Identity "a8df2e5f-2b3c-4d1e-9f8a-1c2b3d4e5f6a"
```

> [!tip] Conseil pratique Utilisez `-Identity` quand vous connaissez exactement le nom du groupe. C'est plus rapide que `-Filter` car il n'y a pas de recherche dans l'annuaire.

---

### 🔎 Recherche avec filtres

Les filtres permettent de rechercher des groupes selon des critères spécifiques.

```powershell
# Tous les groupes de sécurité
Get-ADGroup -Filter "GroupCategory -eq 'Security'"

# Groupes commençant par "IT-"
Get-ADGroup -Filter "Name -like 'IT-*'"

# Groupes créés après une date
Get-ADGroup -Filter "Created -gt '2024-01-01'"

# Combinaison de critères
Get-ADGroup -Filter "GroupCategory -eq 'Security' -and Name -like 'Finance-*'"

# Tous les groupes (attention en production !)
Get-ADGroup -Filter *
```

> [!warning] Attention aux performances `Get-ADGroup -Filter *` peut être très lourd sur un domaine avec des milliers de groupes. Préférez toujours des filtres spécifiques.

**Opérateurs de filtre courants :**

|Opérateur|Description|Exemple|
|---|---|---|
|`-eq`|Égal à|`"Name -eq 'IT-Admins'"`|
|`-ne`|Différent de|`"GroupScope -ne 'DomainLocal'"`|
|`-like`|Correspondance avec wildcards|`"Name -like 'HR-*'"`|
|`-notlike`|Non correspondance|`"Name -notlike 'Test-*'"`|
|`-gt` / `-lt`|Supérieur / Inférieur|`"Created -gt '2024-01-01'"`|
|`-and` / `-or`|ET / OU logique|`"... -and ..."`|

---

### 📂 Recherche dans une OU spécifique

Le paramètre `-SearchBase` limite la recherche à une unité d'organisation particulière.

```powershell
# Recherche dans une OU spécifique
Get-ADGroup -Filter * -SearchBase "OU=Groups,OU=Paris,DC=contoso,DC=com"

# Combinaison SearchBase + Filter
Get-ADGroup -Filter "GroupCategory -eq 'Security'" `
            -SearchBase "OU=IT,OU=Groups,DC=contoso,DC=com"

# Limiter la profondeur de recherche
Get-ADGroup -Filter * `
            -SearchBase "OU=Groups,DC=contoso,DC=com" `
            -SearchScope OneLevel  # Base, OneLevel, ou Subtree
```

> [!info] Portées de recherche (SearchScope)
> 
> - **Base** : uniquement l'OU spécifiée
> - **OneLevel** : OU spécifiée + enfants directs
> - **Subtree** (défaut) : OU + toute la hiérarchie descendante

---

### 📊 Propriétés et attributs étendus

Par défaut, `Get-ADGroup` retourne un ensemble limité de propriétés. Utilisez `-Properties` pour en obtenir davantage.

```powershell
# Propriétés de base (défaut)
Get-ADGroup -Identity "IT-Admins" | Select-Object *

# Ajouter des propriétés spécifiques
Get-ADGroup -Identity "IT-Admins" -Properties Description, ManagedBy, Members

# Toutes les propriétés (peut être lent)
Get-ADGroup -Identity "IT-Admins" -Properties *

# Membres directs du groupe
Get-ADGroup -Identity "IT-Admins" -Properties Members | 
    Select-Object -ExpandProperty Members

# Groupes dont fait partie ce groupe
Get-ADGroup -Identity "IT-Admins" -Properties MemberOf | 
    Select-Object -ExpandProperty MemberOf
```

**Propriétés importantes :**

|Propriété|Type|Description|
|---|---|---|
|`Name`|String|Nom du groupe|
|`SamAccountName`|String|Nom pré-Windows 2000|
|`DistinguishedName`|String|Chemin complet LDAP|
|`GroupCategory`|Enum|Security ou Distribution|
|`GroupScope`|Enum|DomainLocal, Global, Universal|
|`Description`|String|Description du groupe|
|`ManagedBy`|DN|Gestionnaire du groupe|
|`Members`|Array|Membres directs (DN)|
|`MemberOf`|Array|Groupes parents (DN)|
|`Created`|DateTime|Date de création|
|`Modified`|DateTime|Dernière modification|

> [!example] Exemple pratique : Audit des groupes
> 
> ```powershell
> # Lister tous les groupes de sécurité avec leurs gestionnaires
> Get-ADGroup -Filter "GroupCategory -eq 'Security'" `
>             -Properties ManagedBy, Description |
>     Select-Object Name, Description, 
>         @{Name='Manager';Expression={
>             if ($_.ManagedBy) {
>                 (Get-ADUser $_.ManagedBy).Name
>             } else { "Non défini" }
>         }} |
>     Export-Csv "C:\Audit_Groupes.csv" -NoTypeInformation
> ```

---

### 📦 Types et portées de groupes

#### Types de groupes (GroupCategory)

Active Directory distingue deux catégories de groupes :

**1. Security (Sécurité)** 🔐

- Utilisés pour **assigner des permissions** et droits d'accès
- Peuvent également servir de listes de distribution email
- Apparaissent dans les ACL (Access Control Lists)
- Cas d'usage : groupes d'administrateurs, accès aux ressources

```powershell
# Tous les groupes de sécurité
Get-ADGroup -Filter "GroupCategory -eq 'Security'"
```

**2. Distribution** 📧

- Utilisés **uniquement pour les emails** (Exchange, Office 365)
- Ne peuvent PAS être utilisés pour les permissions
- Plus légers en termes de réplication AD
- Cas d'usage : listes de diffusion, groupes de projet

```powershell
# Tous les groupes de distribution
Get-ADGroup -Filter "GroupCategory -eq 'Distribution'"
```

> [!tip] Bonne pratique Utilisez toujours des groupes Security sauf si vous avez besoin exclusivement d'une liste de diffusion sans permissions. Un groupe Security peut faire tout ce qu'un groupe Distribution fait, mais l'inverse n'est pas vrai.

---

#### Portées de groupes (GroupScope)

La portée définit où le groupe peut être utilisé et qui peut en être membre.

**1. DomainLocal (Local au domaine)** 🏠

```powershell
Get-ADGroup -Filter "GroupScope -eq 'DomainLocal'"
```

- **Membres possibles** : comptes et groupes de n'importe quel domaine de la forêt
- **Utilisation** : uniquement dans le domaine où il est créé
- **Cas d'usage** : assigner des permissions sur des ressources locales

> [!example] Exemple DomainLocal
> 
> ```powershell
> # Groupe pour accès à un partage de fichiers
> # Peut contenir des utilisateurs de différents domaines
> # Mais permissions uniquement sur le domaine local
> New-ADGroup -Name "Access-FileServer01" `
>             -GroupScope DomainLocal `
>             -GroupCategory Security `
>             -Path "OU=Resources,DC=contoso,DC=com"
> ```

**2. Global** 🌍

```powershell
Get-ADGroup -Filter "GroupScope -eq 'Global'"
```

- **Membres possibles** : uniquement du même domaine
- **Utilisation** : partout dans la forêt et domaines approuvés
- **Cas d'usage** : regrouper des utilisateurs par fonction/département

> [!example] Exemple Global
> 
> ```powershell
> # Groupe regroupant tous les utilisateurs IT du domaine Paris
> # Peut être utilisé dans n'importe quel domaine de la forêt
> New-ADGroup -Name "Paris-IT-Users" `
>             -GroupScope Global `
>             -GroupCategory Security `
>             -Path "OU=Groups,OU=Paris,DC=contoso,DC=com"
> ```

**3. Universal** 🌐

```powershell
Get-ADGroup -Filter "GroupScope -eq 'Universal'"
```

- **Membres possibles** : comptes et groupes de n'importe quel domaine de la forêt
- **Utilisation** : partout dans la forêt
- **Cas d'usage** : groupes d'envergure forestière, consolidation de groupes Global
- **⚠️ Impact** : répliqué sur tous les catalogues globaux (plus de trafic réseau)

> [!warning] Attention à la réplication Les groupes Universal sont répliqués sur tous les serveurs de catalogue global. Évitez d'y mettre directement des utilisateurs si vous en avez beaucoup. Privilégiez la structure AGDLP/IGDLP.

> [!example] Exemple Universal
> 
> ```powershell
> # Groupe consolidant plusieurs groupes Global de différents domaines
> New-ADGroup -Name "Corporate-Admins" `
>             -GroupScope Universal `
>             -GroupCategory Security `
>             -Path "OU=Enterprise,DC=contoso,DC=com"
> 
> # Ajouter des groupes Global de différents domaines
> Add-ADGroupMember -Identity "Corporate-Admins" `
>                   -Members "Paris-IT-Admins","London-IT-Admins"
> ```

---

**Tableau récapitulatif des portées :**

|Portée|Membres|Utilisation|Réplication|Usage typique|
|---|---|---|---|---|
|**DomainLocal**|Tout domaine de la forêt|Domaine local uniquement|Locale au domaine|Permissions sur ressources|
|**Global**|Même domaine uniquement|Toute la forêt|Locale au domaine|Regroupement d'utilisateurs|
|**Universal**|Tout domaine de la forêt|Toute la forêt|Catalogue global|Consolidation inter-domaines|

---

### 🏗️ Stratégie AGDLP/IGDLP

Une bonne pratique dans les environnements multi-domaines :

**A G DL P** (ou **I G DL P** pour des ressources)

- **A**ccounts (ou **I**dentities) → ajoutés dans des groupes...
- **G**lobal → eux-mêmes ajoutés dans des groupes...
- **DL** (DomainLocal) → qui reçoivent des...
- **P**ermissions

```powershell
# 1. Créer groupe Global pour utilisateurs
New-ADGroup -Name "Paris-HR-Users" -GroupScope Global

# 2. Créer groupe DomainLocal pour ressource
New-ADGroup -Name "Access-HR-Folder" -GroupScope DomainLocal

# 3. Ajouter Global dans DomainLocal
Add-ADGroupMember -Identity "Access-HR-Folder" -Members "Paris-HR-Users"

# 4. Assigner permissions au groupe DomainLocal (via GUI ou icacls)
```

> [!tip] Pourquoi cette structure ?
> 
> - **Flexibilité** : facile d'ajouter des utilisateurs d'autres domaines
> - **Maintenance** : permissions définies une fois sur DomainLocal
> - **Performance** : réduction de la réplication inutile
> - **Évolutivité** : structure claire pour grandes organisations

---

### 🔄 Groupes imbriqués (Nesting)

Les groupes peuvent contenir d'autres groupes, créant une hiérarchie.

```powershell
# Vérifier les groupes enfants d'un groupe
Get-ADGroup -Identity "IT-All-Staff" -Properties Members |
    Select-Object -ExpandProperty Members |
    ForEach-Object {
        Get-ADObject $_ -Properties objectClass |
        Where-Object {$_.objectClass -eq 'group'}
    }

# Vérifier les groupes parents (membership)
Get-ADGroup -Identity "IT-Developers" -Properties MemberOf |
    Select-Object -ExpandProperty MemberOf

# Récupérer tous les membres récursivement (y compris groupes imbriqués)
Get-ADGroupMember -Identity "IT-All-Staff" -Recursive
```

> [!warning] Attention aux imbrications circulaires Active Directory empêche les références circulaires (A membre de B, B membre de A), mais des chaînes complexes peuvent ralentir l'authentification. Gardez une structure simple et documentée.

**Limitations d'imbrication par portée :**

|Groupe parent|Peut contenir|
|---|---|
|DomainLocal|DomainLocal (même domaine), Global (tout domaine), Universal|
|Global|Global (même domaine uniquement)|
|Universal|Global (tout domaine), Universal|

---

### 📝 Exemples pratiques avancés

#### Trouver les groupes vides

```powershell
Get-ADGroup -Filter * -Properties Members |
    Where-Object {-not $_.Members} |
    Select-Object Name, DistinguishedName
```

#### Groupes modifiés récemment

```powershell
$Since = (Get-Date).AddDays(-7)
Get-ADGroup -Filter "Modified -gt '$Since'" -Properties Modified |
    Select-Object Name, Modified |
    Sort-Object Modified -Descending
```

#### Groupes sans gestionnaire

```powershell
Get-ADGroup -Filter "GroupCategory -eq 'Security'" -Properties ManagedBy |
    Where-Object {-not $_.ManagedBy} |
    Select-Object Name, DistinguishedName
```

#### Exporter la structure de groupes

```powershell
Get-ADGroup -Filter * -Properties Members, MemberOf, Description |
    Select-Object Name, GroupScope, GroupCategory, Description,
        @{N='MemberCount';E={$_.Members.Count}},
        @{N='MemberOfCount';E={$_.MemberOf.Count}} |
    Export-Csv "C:\AD_Groups_Audit.csv" -NoTypeInformation
```

---

## ➕ New-ADGroup - Création de groupes

### Vue d'ensemble

`New-ADGroup` permet de créer de nouveaux groupes dans Active Directory avec un contrôle total sur leurs propriétés. C'est essentiel pour l'automatisation du provisioning et l'application de standards organisationnels.

### Syntaxe de base

```powershell
New-ADGroup -Name "NomDuGroupe" -GroupScope <Scope> [-GroupCategory <Category>]
```

---

### 🎯 Paramètres obligatoires

Deux paramètres sont absolument nécessaires pour créer un groupe :

**1. -Name** (Nom du groupe)

```powershell
New-ADGroup -Name "IT-NewTeam" -GroupScope Global
```

> [!info] À propos du nom Le nom doit être unique dans le conteneur où vous créez le groupe. Il sera visible dans toutes les interfaces d'administration.

**2. -GroupScope** (Portée du groupe)

```powershell
New-ADGroup -Name "IT-NewTeam" -GroupScope Global
New-ADGroup -Name "Access-Files" -GroupScope DomainLocal
New-ADGroup -Name "Corp-Managers" -GroupScope Universal
```

Valeurs possibles : `DomainLocal`, `Global`, `Universal`

> [!tip] Choix de la portée
> 
> - **Utilisateurs/Départements** → Global
> - **Permissions sur ressources** → DomainLocal
> - **Consolidation multi-domaines** → Universal

---

### ⚙️ Paramètres optionnels

#### -GroupCategory (Type de groupe)

Par défaut, les groupes créés sont de type **Security**. Vous pouvez le spécifier explicitement ou créer des groupes Distribution.

```powershell
# Groupe de sécurité (valeur par défaut)
New-ADGroup -Name "IT-Security" -GroupScope Global -GroupCategory Security

# Groupe de distribution (email uniquement)
New-ADGroup -Name "Marketing-List" -GroupScope Global -GroupCategory Distribution
```

> [!warning] Rappel important Les groupes Distribution ne peuvent PAS être utilisés pour les permissions. Utilisez Security par défaut sauf besoin spécifique.

---

#### -Path (Emplacement dans l'AD)

Spécifie l'unité d'organisation (OU) où créer le groupe. Si omis, le groupe est créé dans le conteneur par défaut `CN=Users`.

```powershell
# Créer dans une OU spécifique
New-ADGroup -Name "Finance-Users" `
            -GroupScope Global `
            -Path "OU=Groups,OU=Finance,DC=contoso,DC=com"

# Créer dans le conteneur Users (par défaut)
New-ADGroup -Name "Test-Group" -GroupScope Global
# Équivaut à : -Path "CN=Users,DC=contoso,DC=com"
```

> [!tip] Bonne pratique Créez toujours une structure d'OU dédiée pour vos groupes, par exemple `OU=Groups,DC=contoso,DC=com`, avec des sous-OU par département ou fonction.

---

#### -Description (Description du groupe)

Documenter le but du groupe est crucial pour la maintenance à long terme.

```powershell
New-ADGroup -Name "IT-Developers" `
            -GroupScope Global `
            -Description "Équipe de développement - Accès aux environnements de dev et test"
```

> [!tip] Conseil de documentation Incluez dans la description :
> 
> - **But** du groupe
> - **Ressources** auxquelles il donne accès
> - **Contact** du gestionnaire
> 
> Exemple : "Accès RW au partage \srv01\projects - Contact: admin@contoso.com"

---

#### -DisplayName (Nom d'affichage)

Le nom convivial affiché dans Outlook et les listes globales d'adresses.

```powershell
New-ADGroup -Name "IT-Dev-Team" `
            -GroupScope Global `
            -DisplayName "IT Development Team" `
            -Description "Development team members"
```

> [!info] Name vs DisplayName
> 
> - **Name** : identifiant technique, doit être unique
> - **DisplayName** : nom convivial pour utilisateurs finaux
> - Si DisplayName est omis, Name est utilisé par défaut

---

#### -SamAccountName (Nom pré-Windows 2000)

Nom utilisé pour la compatibilité avec les anciens systèmes. Auto-généré si omis.

```powershell
# Spécifier explicitement
New-ADGroup -Name "IT Development Team" `
            -SamAccountName "IT-Dev" `
            -GroupScope Global

# Laisser auto-générer (dérivé de Name)
New-ADGroup -Name "IT-Dev-Team" -GroupScope Global
# SamAccountName sera "IT-Dev-Team"
```

> [!warning] Limitation de longueur SamAccountName est limité à **20 caractères**. Si votre Name est plus long, spécifiez un SamAccountName abrégé.

---

#### -ManagedBy (Gestionnaire du groupe)

Désigne qui est responsable de la maintenance du groupe. Doit être un Distinguished Name (DN).

```powershell
# Avec DN complet
New-ADGroup -Name "Finance-Users" `
            -GroupScope Global `
            -ManagedBy "CN=John Doe,OU=Users,DC=contoso,DC=com"

# Récupérer le DN d'un utilisateur d'abord
$Manager = (Get-ADUser -Identity "jdoe").DistinguishedName
New-ADGroup -Name "Finance-Users" `
            -GroupScope Global `
            -ManagedBy $Manager
```

> [!tip] Délégation de gestion L'utilisateur défini dans ManagedBy peut recevoir des droits de gestion sur le groupe (ajout/retrait de membres) via la délégation AD, sans être admin du domaine.

---

### 📋 Exemple complet de création

```powershell
# Création d'un groupe avec tous les paramètres recommandés
New-ADGroup -Name "HR-Managers-Paris" `
            -SamAccountName "HR-Mgr-Paris" `
            -GroupScope Global `
            -GroupCategory Security `
            -DisplayName "HR Managers - Paris Office" `
            -Description "Groupe des managers RH du site de Paris - Accès dossiers confidentiels RH" `
            -Path "OU=Groups,OU=Paris,DC=contoso,DC=com" `
            -ManagedBy (Get-ADUser -Identity "hr.admin").DistinguishedName

# Vérifier la création
Get-ADGroup -Identity "HR-Managers-Paris" -Properties *
```

---

### 📏 Conventions de nommage

Une convention de nommage cohérente facilite l'administration et l'automatisation.

#### Exemples de conventions

**Par fonction et localisation :**

```
<Département>-<Fonction>-<Localisation>
```

- `IT-Admins-Paris`
- `HR-Managers-London`
- `Finance-Users-Global`

**Par type d'accès :**

```
Access-<Ressource>-<Niveau>
```

- `Access-FileServer01-RW`
- `Access-SharePoint-Read`
- `Access-Database-Admin`

**Par projet :**

```
<Projet>-<Rôle>
```

- `Phoenix-Developers`
- `Phoenix-Testers`
- `Atlas-ProjectManagers`

#### Script pour valider les conventions

```powershell
function New-StandardADGroup {
    param(
        [Parameter(Mandatory)]
        [string]$Department,
        
        [Parameter(Mandatory)]
        [string]$Function,
        
        [Parameter(Mandatory)]
        [string]$Location,
        
        [Parameter(Mandatory)]
        [ValidateSet('Global','DomainLocal','Universal')]
        [string]$Scope
    )
    
    # Construire le nom selon la convention
    $GroupName = "$Department-$Function-$Location"
    
    # Valider que le nom n'existe pas déjà
    if (Get-ADGroup -Filter "Name -eq '$GroupName'" -ErrorAction SilentlyContinue) {
        Write-Error "Le groupe $GroupName existe déjà"
        return
    }
    
    # Créer le groupe
    $Params = @{
        Name          = $GroupName
        SamAccountName = $GroupName
        GroupScope    = $Scope
        GroupCategory = 'Security'
        Description   = "Groupe $Function pour le département $Department - Site $Location"
        Path          = "OU=Groups,OU=$Location,DC=contoso,DC=com"
    }
    
    New-ADGroup @Params
    Write-Host "✅ Groupe créé : $GroupName" -ForegroundColor Green
}

# Utilisation
New-StandardADGroup -Department "IT" -Function "Developers" -Location "Paris" -Scope Global
```

> [!tip] Avantages d'une convention stricte
> 
> - **Recherche facilitée** : `Get-ADGroup -Filter "Name -like 'IT-*'"`
> - **Automatisation** : parsing du nom pour extraire département, fonction, etc.
> - **Clarté** : le nom révèle immédiatement le but du groupe
> - **Cohérence** : tous les administrateurs suivent le même modèle

---

### 🏗️ Structure et hiérarchie de groupes

Une structure bien pensée simplifie la gestion à long terme.

#### Structure organisationnelle typique

```
OU=Groups
├── OU=Security
│   ├── OU=Admins
│   │   ├── IT-Domain-Admins
│   │   ├── IT-Server-Admins
│   │   └── IT-Workstation-Admins
│   ├── OU=Departments
│   │   ├── IT-All-Users
│   │   ├── HR-All-Users
│   │   └── Finance-All-Users
│   └── OU=Resources
│       ├── Access-FileServer01-RW
│       └── Access-FileServer01-RO
└── OU=Distribution
    ├── Company-Announcements
    └── Department-IT-News
```

#### Script pour créer la structure

```powershell
# Définir la structure d'OU
$OUStructure = @(
    "OU=Groups,DC=contoso,DC=com",
    "OU=Security,OU=Groups,DC=contoso,DC=com",
    "OU=Admins,OU=Security,OU=Groups,DC=contoso,DC=com",
    "OU=Departments,OU=Security,OU=Groups,DC=contoso,DC=com",
    "OU=Resources,OU=Security,OU=Groups,DC=contoso,DC=com",
    "OU=Distribution,OU=Groups,DC=contoso,DC=com"
)

# Créer les OU si elles n'existent pas
foreach ($OU in $OUStructure) {
    if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$OU'" -ErrorAction SilentlyContinue)) {
        $OUName = ($OU -split ',')[0] -replace 'OU=',''
        $ParentPath = ($OU -split ',',2)[1]
        
        New-ADOrganizationalUnit -Name $OUName -Path $ParentPath
        Write-Host "✅ OU créée : $OU" -ForegroundColor Green
    }
}
```

---

### 🔗 Stratégie de groupes imbriqués

Les groupes imbriqués permettent une gestion hiérarchique et modulaire.

#### Exemple de structure AGDLP

```powershell
# 1. Créer les groupes Global par département (A → G)
$Departments = @('IT', 'HR', 'Finance')
foreach ($Dept in $Departments) {
    New-ADGroup -Name "$Dept-Users" `
                -GroupScope Global `
                -Path "OU=Departments,OU=Security,OU=Groups,DC=contoso,DC=com" `
                -Description "Tous les utilisateurs du département $Dept"
}

# 2. Créer les groupes DomainLocal pour ressources (DL → P)
$Resources = @{
    'FileServer01' = @('RW', 'RO')
    'SharePoint-HR' = @('Contribute', 'Read')
}

foreach ($Resource in $Resources.Keys) {
    foreach ($Permission in $Resources[$Resource]) {
        New-ADGroup -Name "Access-$Resource-$Permission" `
                    -GroupScope DomainLocal `
                    -Path "OU=Resources,OU=Security,OU=Groups,DC=contoso,DC=com" `
                    -Description "Accès $Permission à $Resource"
    }
}

# 3. Imbriquer : ajouter Global dans DomainLocal
Add-ADGroupMember -Identity "Access-FileServer01-RW" -Members "IT-Users"
Add-ADGroupMember -Identity "Access-SharePoint-HR-Contribute" -Members "HR-Users"
```

#### Groupes de consolidation

```powershell
# Créer un groupe Universal consolidant plusieurs Global
New-ADGroup -Name "Corporate-IT-Staff" `
            -GroupScope Universal `
            -Path "OU=Enterprise,DC=contoso,DC=com" `
            -Description "Tout le personnel IT de tous les sites"

# Ajouter les groupes Global de chaque site
$Sites = @('Paris', 'London', 'NewYork')
foreach ($Site in $Sites) {
    Add-ADGroupMember -Identity "Corporate-IT-Staff" -Members "IT-Users-$Site"
}
```

> [!warning] Profondeur d'imbrication Évitez plus de 3-4 niveaux d'imbrication. Chaque niveau ajoute du temps lors de l'authentification et complique le dépannage.

---

### 🚀 Scripts de provisioning automatisé

#### Provisioning en masse depuis CSV

**Fichier CSV (NewGroups.csv) :**

```csv
GroupName,GroupScope,Department,Description,Manager
IT-Developers,Global,IT,Équipe de développement,jdoe
IT-Support,Global,IT,Support technique niveau 1-2,asmith
HR-Managers,Global,HR,Managers des ressources humaines,mwilson
Finance-Analysts,Global,Finance,Analystes financiers,bjones
Access-FileServer01-RW,DomainLocal,IT,Accès RW au serveur de fichiers,jdoe
```

**Script de provisioning :**

```powershell
# Importer le CSV
$Groups = Import-Csv "C:\NewGroups.csv"

foreach ($Group in $Groups) {
    try {
        # Construire le chemin OU
        $OUPath = "OU=Groups,OU=$($Group.Department),DC=contoso,DC=com"
        
        # Vérifier que le groupe n'existe pas déjà
        if (Get-ADGroup -Filter "Name -eq '$($Group.GroupName)'" -ErrorAction SilentlyContinue) {
            Write-Warning "⚠️ Le groupe $($Group.GroupName) existe déjà - ignoré"
            continue
        }
        
        # Récupérer le DN du manager
        $ManagerDN = $null
        if ($Group.Manager) {
            $ManagerDN = (Get-ADUser -Identity $Group.Manager -ErrorAction Stop).DistinguishedName
        }
        
        # Paramètres de création
        $Params = @{
            Name          = $Group.GroupName
            GroupScope    = $Group.GroupScope
            GroupCategory = 'Security'
            Description   = $Group.Description
            Path          = $OUPath
        }
        
        if ($ManagerDN) {
            $Params.Add('ManagedBy', $ManagerDN)
        }
        
        # Créer le groupe
        New-ADGroup @Params
        Write-Host "✅ Groupe créé : $($Group.GroupName)" -ForegroundColor Green
        
    } catch {
        Write-Error "❌ Erreur lors de la création de $($Group.GroupName) : $_"
    }
}

Write-Host "`n📊 Provisioning terminé !" -ForegroundColor Cyan
```

---

#### Provisioning avec validation et rollback

```powershell
function New-ADGroupWithValidation {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [string]$Name,
        
        [Parameter(Mandatory)]
        [ValidateSet('DomainLocal','Global','Universal')]
        [string]$GroupScope,
        
        [Parameter(Mandatory)]
        [string]$Path,
        
        [string]$Description,
        [string]$ManagedBy
    )
    
    # Validation du nom (pas d'espaces multiples, caractères spéciaux)
    if ($Name -match '\s{2,}|[<>:"/\\|?*]') {
        throw "Le nom contient des caractères invalides"
    }
    
    # Vérifier que l'OU existe
    if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$Path'" -ErrorAction SilentlyContinue)) {
        throw "L'OU $Path n'existe pas"
    }
    
    # Vérifier que le groupe n'existe pas
    if (Get-ADGroup -Filter "Name -eq '$Name'" -ErrorAction SilentlyContinue) {
        throw "Le groupe $Name existe déjà"
    }
    
    # Valider le manager si spécifié
    if ($ManagedBy) {
        if (-not (Get-ADUser -Filter "SamAccountName -eq '$ManagedBy'" -ErrorAction SilentlyContinue)) {
            throw "Le manager $ManagedBy n'existe pas"
        }
    }
    
    # Si -WhatIf, ne rien faire
    if ($PSCmdlet.ShouldProcess($Name, "Créer le groupe")) {
        try {
            $Params = @{
                Name          = $Name
                GroupScope    = $GroupScope
                GroupCategory = 'Security'
                Path          = $Path
            }
            
            if ($Description) { $Params.Add('Description', $Description) }
            if ($ManagedBy) { 
                $ManagerDN = (Get-ADUser -Identity $ManagedBy).DistinguishedName
                $Params.Add('ManagedBy', $ManagerDN) 
            }
            
            New-ADGroup @Params -ErrorAction Stop
            
            # Vérification post-création
            Start-Sleep -Seconds 2
            $CreatedGroup = Get-ADGroup -Identity $Name
            
            return [PSCustomObject]@{
                Status  = 'Success'
                Name    = $Name
                DN      = $CreatedGroup.DistinguishedName
                Message = "Groupe créé avec succès"
            }
            
        } catch {
            return [PSCustomObject]@{
                Status  = 'Failed'
                Name    = $Name
                DN      = $null
                Message = $_.Exception.Message
            }
        }
    }
}

# Utilisation avec test préalable
New-ADGroupWithValidation -Name "IT-Test" `
                          -GroupScope Global `
                          -Path "OU=Groups,DC=contoso,DC=com" `
                          -Description "Groupe de test" `
                          -ManagedBy "jdoe" `
                          -WhatIf

# Création réelle
$Result = New-ADGroupWithValidation -Name "IT-Test" `
                                     -GroupScope Global `
                                     -Path "OU=Groups,DC=contoso,DC=com" `
                                     -Description "Groupe de test" `
                                     -ManagedBy "jdoe"

$Result | Format-List
```

---

#### Template de provisioning pour nouveau projet

```powershell
function New-ProjectGroupStructure {
    param(
        [Parameter(Mandatory)]
        [string]$ProjectName,
        
        [Parameter(Mandatory)]
        [string]$ProjectManager,
        
        [string]$BasePath = "OU=Projects,OU=Groups,DC=contoso,DC=com"
    )
    
    Write-Host "🚀 Création de la structure pour le projet : $ProjectName" -ForegroundColor Cyan
    
    # Définir les groupes à créer
    $GroupStructure = @(
        @{
            Name   = "$ProjectName-Owners"
            Scope  = 'Global'
            Desc   = "Propriétaires du projet $ProjectName - Droits complets"
        },
        @{
            Name   = "$ProjectName-Contributors"
            Scope  = 'Global'
            Desc   = "Contributeurs du projet $ProjectName - Lecture/Écriture"
        },
        @{
            Name   = "$ProjectName-Readers"
            Scope  = 'Global'
            Desc   = "Lecteurs du projet $ProjectName - Lecture seule"
        },
        @{
            Name   = "Access-$ProjectName-Full"
            Scope  = 'DomainLocal'
            Desc   = "Accès complet aux ressources du projet $ProjectName"
        },
        @{
            Name   = "Access-$ProjectName-Modify"
            Scope  = 'DomainLocal'
            Desc   = "Accès modification aux ressources du projet $ProjectName"
        },
        @{
            Name   = "Access-$ProjectName-Read"
            Scope  = 'DomainLocal'
            Desc   = "Accès lecture aux ressources du projet $ProjectName"
        }
    )
    
    $CreatedGroups = @()
    
    foreach ($GroupDef in $GroupStructure) {
        try {
            $Params = @{
                Name          = $GroupDef.Name
                GroupScope    = $GroupDef.Scope
                GroupCategory = 'Security'
                Description   = $GroupDef.Desc
                Path          = $BasePath
                ManagedBy     = (Get-ADUser -Identity $ProjectManager).DistinguishedName
            }
            
            New-ADGroup @Params -ErrorAction Stop
            $CreatedGroups += $GroupDef.Name
            Write-Host "  ✅ $($GroupDef.Name)" -ForegroundColor Green
            
        } catch {
            Write-Error "  ❌ Erreur avec $($GroupDef.Name) : $_"
        }
    }
    
    # Créer les imbrications AGDLP
    Write-Host "`n🔗 Configuration des appartenances..." -ForegroundColor Cyan
    
    try {
        Add-ADGroupMember -Identity "Access-$ProjectName-Full" -Members "$ProjectName-Owners"
        Add-ADGroupMember -Identity "Access-$ProjectName-Modify" -Members "$ProjectName-Contributors"
        Add-ADGroupMember -Identity "Access-$ProjectName-Read" -Members "$ProjectName-Readers"
        Write-Host "  ✅ Appartenances configurées" -ForegroundColor Green
    } catch {
        Write-Error "  ❌ Erreur lors de la configuration : $_"
    }
    
    # Résumé
    Write-Host "`n📊 Résumé de création :" -ForegroundColor Cyan
    Write-Host "  Projet       : $ProjectName"
    Write-Host "  Gestionnaire : $ProjectManager"
    Write-Host "  Groupes créés: $($CreatedGroups.Count)"
    Write-Host "`n📝 Prochaines étapes :"
    Write-Host "  1. Ajouter les utilisateurs aux groupes Global (*-Owners, *-Contributors, *-Readers)"
    Write-Host "  2. Assigner les permissions NTFS aux groupes DomainLocal (Access-*)"
    Write-Host "  3. Documenter dans le wiki projet"
}

# Utilisation
New-ProjectGroupStructure -ProjectName "Phoenix" -ProjectManager "jdoe"
```

---

### 🔐 Droits requis pour la création

#### Permissions nécessaires

Pour créer des groupes dans Active Directory, vous devez avoir :

1. **Droits de création sur l'OU cible**
    
    - Délégation « Create Group Objects » sur l'OU
    - Ou appartenance à « Account Operators », « Domain Admins »
2. **Droits de lecture sur les objets référencés**
    
    - Accès lecture sur les utilisateurs (pour ManagedBy)
    - Accès lecture sur les OU (pour validation Path)

#### Vérifier ses permissions

```powershell
# Vérifier les permissions effectives sur une OU
$OU = "OU=Groups,DC=contoso,DC=com"
$ACL = Get-Acl -Path "AD:\$OU"

# Filtrer sur votre compte
$CurrentUser = [System.Security.Principal.WindowsIdentity]::GetCurrent().Name
$ACL.Access | Where-Object {
    $_.IdentityReference -like "*$env:USERNAME*" -or
    $_.IdentityReference -like "*Domain Admins*"
} | Format-Table IdentityReference, ActiveDirectoryRights, AccessControlType

# Vérifier si vous pouvez créer des groupes
$CanCreate = $ACL.Access | Where-Object {
    $_.ActiveDirectoryRights -match 'CreateChild|GenericAll' -and
    $_.AccessControlType -eq 'Allow'
}

if ($CanCreate) {
    Write-Host "✅ Vous avez les droits de création de groupes" -ForegroundColor Green
} else {
    Write-Host "❌ Droits insuffisants" -ForegroundColor Red
}
```

#### Déléguer la création de groupes

```powershell
# Script pour déléguer la création de groupes à un utilisateur/groupe
$OU = "OU=Groups,DC=contoso,DC=com"
$Delegate = "CONTOSO\IT-GroupAdmins"  # Groupe ou utilisateur

# Récupérer l'ACL actuelle
$ACL = Get-Acl -Path "AD:\$OU"

# Créer la règle de délégation
$SID = (Get-ADGroup -Identity "IT-GroupAdmins").SID
$Identity = [System.Security.Principal.IdentityReference] $SID
$ADRight = [System.DirectoryServices.ActiveDirectoryRights]::CreateChild
$Type = [System.Security.AccessControl.AccessControlType]::Allow
$InheritanceType = [System.DirectoryServices.ActiveDirectorySecurityInheritance]::All

# GUID pour objets groupe
$GroupGUID = [GUID]"bf967a9c-0de6-11d0-a285-00aa003049e2"

$Rule = New-Object System.DirectoryServices.ActiveDirectoryAccessRule(
    $Identity, $ADRight, $Type, $GroupGUID, $InheritanceType
)

# Appliquer la règle
$ACL.AddAccessRule($Rule)
Set-Acl -Path "AD:\$OU" -AclObject $ACL

Write-Host "✅ Délégation appliquée : $Delegate peut créer des groupes dans $OU" -ForegroundColor Green
```

> [!tip] Principe du moindre privilège Ne donnez jamais « Domain Admins » pour la simple création de groupes. Utilisez la délégation ciblée sur les OU nécessaires.

---

### ⚠️ Pièges courants et bonnes pratiques

#### Piège n°1 : Nom vs SamAccountName

```powershell
# ❌ ERREUR : Nom trop long sans SamAccountName
New-ADGroup -Name "IT-Development-Team-Paris-Infrastructure-Monitoring" `
            -GroupScope Global
# SamAccountName sera tronqué à 20 caractères automatiquement !

# ✅ CORRECT : Spécifier un SamAccountName court
New-ADGroup -Name "IT-Development-Team-Paris-Infrastructure-Monitoring" `
            -SamAccountName "IT-Dev-Paris-Infra" `
            -GroupScope Global
```

> [!warning] Limite des 20 caractères SamAccountName ne peut pas dépasser 20 caractères. Si votre Name est plus long, vous DEVEZ spécifier un SamAccountName manuel.

---

#### Piège n°2 : GroupScope et imbrication

```powershell
# ❌ ERREUR : Impossible d'imbriquer ainsi
New-ADGroup -Name "Global-Parent" -GroupScope Global
New-ADGroup -Name "DomainLocal-Child" -GroupScope DomainLocal
Add-ADGroupMember -Identity "Global-Parent" -Members "DomainLocal-Child"
# ERREUR : Un groupe Global ne peut pas contenir un DomainLocal

# ✅ CORRECT : Respecter les règles d'imbrication
New-ADGroup -Name "DomainLocal-Parent" -GroupScope DomainLocal
New-ADGroup -Name "Global-Child" -GroupScope Global
Add-ADGroupMember -Identity "DomainLocal-Parent" -Members "Global-Child"
```

**Règle d'or :** Global → DomainLocal, jamais l'inverse !

---

#### Piège n°3 : Path inexistant

```powershell
# ❌ ERREUR : L'OU n'existe pas
New-ADGroup -Name "Test-Group" `
            -GroupScope Global `
            -Path "OU=NonExistante,DC=contoso,DC=com"
# ERREUR : The specified directory service attribute or value does not exist

# ✅ CORRECT : Vérifier l'existence d'abord
$OUPath = "OU=Groups,DC=contoso,DC=com"
if (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$OUPath'") {
    New-ADGroup -Name "Test-Group" -GroupScope Global -Path $OUPath
} else {
    Write-Error "L'OU $OUPath n'existe pas"
}
```

---

#### Piège n°4 : ManagedBy avec valeur incorrecte

```powershell
# ❌ ERREUR : ManagedBy attend un DN, pas un SamAccountName
New-ADGroup -Name "Test-Group" `
            -GroupScope Global `
            -ManagedBy "jdoe"  # ERREUR !

# ✅ CORRECT : Récupérer le DN d'abord
$ManagerDN = (Get-ADUser -Identity "jdoe").DistinguishedName
New-ADGroup -Name "Test-Group" `
            -GroupScope Global `
            -ManagedBy $ManagerDN
```

---

#### Piège n°5 : Caractères spéciaux dans le nom

```powershell
# ❌ ERREUR : Caractères interdits
New-ADGroup -Name "IT/Dev\Test" -GroupScope Global
# ERREUR : Le nom contient des caractères invalides

# ✅ CORRECT : Utiliser uniquement alphanumériques, tirets et underscores
New-ADGroup -Name "IT-Dev-Test" -GroupScope Global
```

**Caractères à éviter :** `/` `\` `:` `*` `?` `"` `<` `>` `|`

---

### 📋 Bonnes pratiques récapitulatives

|Pratique|✅ À faire|❌ À éviter|
|---|---|---|
|**Nommage**|Convention cohérente, préfixes|Noms génériques, espaces multiples|
|**Description**|Documenter le but et le contact|Laisser vide|
|**Structure OU**|Hiérarchie logique par fonction|Tout dans CN=Users|
|**GroupScope**|Global pour utilisateurs, DomainLocal pour ressources|Universal partout (réplication)|
|**GroupCategory**|Security par défaut|Distribution si permissions nécessaires|
|**ManagedBy**|Toujours définir un gestionnaire|Laisser orphelin|
|**Imbrication**|Structure AGDLP, max 3-4 niveaux|Imbrications complexes et circulaires|
|**Validation**|Tester avec -WhatIf, vérifier l'existence|Créer en aveugle|
|**Documentation**|Commenter les scripts, journaliser|Scripts sans documentation|
|**Droits**|Délégation ciblée|Domain Admins pour tout|

---

### 🎯 Astuce finale : Template de fonction complète

```powershell
function New-StandardSecurityGroup {
    <#
    .SYNOPSIS
        Crée un groupe de sécurité selon les standards de l'entreprise
    
    .DESCRIPTION
        Crée un groupe avec validation, logging et conformité aux conventions
    
    .EXAMPLE
        New-StandardSecurityGroup -Department "IT" -Function "Developers" -Location "Paris"
    #>
    
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('IT','HR','Finance','Sales','Marketing')]
        [string]$Department,
        
        [Parameter(Mandatory)]
        [string]$Function,
        
        [Parameter(Mandatory)]
        [string]$Location,
        
        [Parameter(Mandatory)]
        [ValidateSet('Global','DomainLocal','Universal')]
        [string]$GroupScope,
        
        [string]$Manager,
        [string]$Description
    )
    
    # Construction du nom selon convention
    $GroupName = "$Department-$Function-$Location"
    $DisplayName = "$Department $Function - $Location"
    $OUPath = "OU=Groups,OU=$Location,DC=contoso,DC=com"
    
    # Description auto si non fournie
    if (-not $Description) {
        $Description = "Groupe $Function pour le département $Department - Site $Location - Créé le $(Get-Date -Format 'dd/MM/yyyy')"
    }
    
    # Validation pré-création
    Write-Verbose "Validation du groupe $GroupName..."
    
    if (Get-ADGroup -Filter "Name -eq '$GroupName'" -ErrorAction SilentlyContinue) {
        throw "Le groupe $GroupName existe déjà"
    }
    
    if (-not (Get-ADOrganizationalUnit -Filter "DistinguishedName -eq '$OUPath'" -ErrorAction SilentlyContinue)) {
        throw "L'OU $OUPath n'existe pas"
    }
    
    # Construire les paramètres
    $Params = @{
        Name          = $GroupName
        SamAccountName = $GroupName
        DisplayName   = $DisplayName
        GroupScope    = $GroupScope
        GroupCategory = 'Security'
        Description   = $Description
        Path          = $OUPath
    }
    
    if ($Manager) {
        $ManagerDN = (Get-ADUser -Identity $Manager -ErrorAction Stop).DistinguishedName
        $Params.Add('ManagedBy', $ManagerDN)
    }
    
    # Création
    if ($PSCmdlet.ShouldProcess($GroupName, "Créer le groupe de sécurité")) {
        try {
            New-ADGroup @Params -ErrorAction Stop
            
            # Log de l'action
            $LogEntry = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] Groupe créé : $GroupName par $env:USERNAME"
            Add-Content -Path "C:\Logs\ADGroupCreation.log" -Value $LogEntry
            
            Write-Host "✅ Groupe créé avec succès : $GroupName" -ForegroundColor Green
            
            return Get-ADGroup -Identity $GroupName
            
        } catch {
            Write-Error "Échec de la création : $_"
            throw
        }
    }
}

# Utilisation
New-StandardSecurityGroup -Department "IT" `
                          -Function "Developers" `
                          -Location "Paris" `
                          -GroupScope Global `
                          -Manager "jdoe" `
                          -Verbose
```

---

## 🎓 Synthèse du chapitre

### Ce que vous avez appris

✅ **Get-ADGroup** : récupération et interrogation de groupes

- Recherche par identité, filtres, OU
- Propriétés étendues (Members, MemberOf, Description)
- Types et portées de groupes (Security/Distribution, DomainLocal/Global/Universal)

✅ **New-ADGroup** : création automatisée de groupes

- Paramètres obligatoires et optionnels
- Conventions de nommage et structure organisationnelle
- Groupes imbriqués et stratégie AGDLP
- Scripts de provisioning en masse

✅ **Concepts avancés**

- Hiérarchies et imbrication de groupes
- Délégation de droits de création
- Validation et gestion d'erreurs
- Templates réutilisables

### Points clés à retenir

> [!tip] Les 5 règles d'or de la gestion des groupes
> 
> 1. **Nommage cohérent** : adoptez et respectez une convention
> 2. **AGDLP toujours** : Global pour utilisateurs, DomainLocal pour permissions
> 3. **Documentation** : Description + ManagedBy sur tous les groupes
> 4. **Structure logique** : organisez vos OU de manière intuitive
> 5. **Validation** : testez avec -WhatIf, gérez les erreurs proprement

---

### Commandes essentielles à retenir

```powershell
# Recherche de groupes
Get-ADGroup -Identity "GroupName"
Get-ADGroup -Filter "Name -like 'IT-*'"
Get-ADGroup -SearchBase "OU=Groups,DC=contoso,DC=com"

# Création de groupe
New-ADGroup -Name "IT-Team" -GroupScope Global

# Création complète
New-ADGroup -Name "IT-Developers" `
            -GroupScope Global `
            -GroupCategory Security `
            -Description "Équipe de développement" `
            -Path "OU=Groups,DC=contoso,DC=com" `
            -ManagedBy (Get-ADUser "jdoe").DistinguishedName
```

---

_Fin du chapitre sur la gestion des groupes Active Directory avec PowerShell_