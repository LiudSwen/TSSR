

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

## 🗂️ Les permissions NTFS

### Rappel des permissions NTFS

Les permissions NTFS (New Technology File System) sont un mécanisme de sécurité qui contrôle l'accès aux fichiers et dossiers sur les volumes NTFS. Elles fonctionnent indépendamment d'Active Directory mais sont optimales lorsqu'elles sont combinées avec les groupes AD.

> [!info] Pourquoi les permissions NTFS ? Les permissions NTFS offrent une sécurité au niveau du système de fichiers, indépendamment du protocole d'accès (local, réseau, partage). Contrairement aux permissions de partage qui ne s'appliquent qu'en accès réseau, les permissions NTFS protègent les données dans tous les cas.

### Permissions de base vs avancées

#### 📊 Permissions de base (Standard)

Les permissions de base sont des combinaisons prédéfinies de permissions avancées, conçues pour simplifier la gestion quotidienne.

|Permission|Description|Cas d'usage typique|
|---|---|---|
|**Contrôle total**|Tous les droits possibles, y compris modification des permissions|Administrateurs, propriétaires|
|**Modification**|Lecture, écriture, suppression de fichiers|Utilisateurs ayant besoin d'éditer|
|**Lecture et exécution**|Visualiser et exécuter les fichiers|Applications, scripts|
|**Lecture**|Uniquement visualiser le contenu|Consultation sans modification|
|**Écriture**|Créer des fichiers et sous-dossiers|Dépôt de documents|
|**Permissions spéciales**|Combinaison personnalisée|Besoins spécifiques|

> [!example] Exemple pratique Pour un dossier "Documents Comptabilité" :
> 
> - Groupe "Comptables" → **Modification**
> - Groupe "Direction" → **Lecture**
> - Groupe "IT_Admins" → **Contrôle total**

#### 🔧 Permissions avancées (Granulaires)

Les permissions avancées offrent un contrôle précis sur chaque action possible. Elles constituent les briques élémentaires des permissions de base.

|Permission avancée|Action autorisée|
|---|---|
|**Parcourir le dossier / Exécuter le fichier**|Naviguer dans l'arborescence|
|**Lister le dossier / Lire les données**|Voir les noms des fichiers|
|**Lire les attributs**|Voir les propriétés (taille, date)|
|**Lire les attributs étendus**|Voir les métadonnées personnalisées|
|**Créer des fichiers / Écrire des données**|Ajouter de nouveaux fichiers|
|**Créer des dossiers / Ajouter des données**|Créer des sous-dossiers|
|**Écrire les attributs**|Modifier les propriétés|
|**Écrire les attributs étendus**|Modifier les métadonnées|
|**Supprimer les sous-dossiers et les fichiers**|Supprimer le contenu|
|**Supprimer**|Supprimer l'objet lui-même|
|**Lire les permissions**|Voir les ACL|
|**Modifier les permissions**|Changer les ACL|
|**Appropriation**|Devenir propriétaire|

> [!tip] Astuce Utilisez les permissions avancées uniquement pour des besoins spécifiques. Dans 90% des cas, les permissions de base suffisent et simplifient grandement la maintenance.

#### 📋 Composition des permissions de base

Voici comment les permissions de base sont composées :

**Contrôle total** = Toutes les permissions avancées

**Modification** =

- Parcourir/Exécuter
- Lister/Lire les données
- Lire les attributs
- Lire les attributs étendus
- Créer fichiers/Écrire
- Créer dossiers/Ajouter
- Écrire les attributs
- Écrire les attributs étendus
- Supprimer
- Lire les permissions

**Lecture et exécution** =

- Parcourir/Exécuter
- Lister/Lire les données
- Lire les attributs
- Lire les attributs étendus
- Lire les permissions

### Héritage et propagation

#### 🌳 Principe de l'héritage

L'héritage est un mécanisme fondamental des permissions NTFS qui permet aux dossiers enfants de recevoir automatiquement les permissions de leur parent.

> [!info] Fonctionnement de l'héritage Par défaut, lorsque vous créez un fichier ou un dossier, il hérite automatiquement des permissions du dossier parent. Cela simplifie considérablement la gestion dans les grandes arborescences.

**Types d'entrées dans les ACL :**

- **Permissions héritées** : Affichées en grisé, proviennent du parent
- **Permissions explicites** : Définies directement sur l'objet, prioritaires

#### 🔄 Options de propagation

Lors de la définition d'une permission, vous pouvez choisir comment elle se propage :

|Option de propagation|Application|Usage typique|
|---|---|---|
|**Ce dossier, les sous-dossiers et les fichiers**|Tout dans l'arborescence|Permission générale|
|**Ce dossier et les sous-dossiers**|Pas les fichiers|Contrôle de la structure|
|**Ce dossier et les fichiers**|Pas les sous-dossiers|Niveau actuel uniquement|
|**Uniquement les sous-dossiers et les fichiers**|Pas le dossier actuel|Délégation vers le bas|
|**Uniquement les sous-dossiers**|Sous-répertoires uniquement|Gestion des conteneurs|
|**Uniquement les fichiers**|Fichiers uniquement|Contenu sans structure|
|**Ce dossier uniquement**|Aucune propagation|Cas particulier|

> [!example] Scénario pratique Pour un dossier "Projets" contenant des sous-dossiers par projet :
> 
> ```
> Projets/
> ├── Projet_A/
> ├── Projet_B/
> └── Projet_C/
> ```
> 
> - Sur "Projets" : Groupe "Chefs_Projets" avec **Modification** sur "Ce dossier, les sous-dossiers et les fichiers"
> - Tous les projets actuels et futurs héritent automatiquement

#### 🚫 Blocage de l'héritage

Il est possible de bloquer l'héritage pour des besoins spécifiques de sécurité.

**Options lors du blocage :**

1. **Convertir les permissions héritées** : Les transforme en permissions explicites (recommandé)
2. **Supprimer toutes les permissions héritées** : Repart de zéro (attention !)

> [!warning] Attention aux blocages d'héritage Le blocage de l'héritage complexifie la gestion et la maintenance. Ne l'utilisez que lorsque c'est absolument nécessaire, par exemple :
> 
> - Dossiers confidentiels nécessitant des accès restreints
> - Zones de quarantaine
> - Espaces de travail temporaires

**Cas d'usage du blocage :**

```
Serveur_Fichiers/
├── Départements/           [Permissions standards héritées]
│   ├── RH/
│   ├── Finance/
│   └── Confidentiel_Direction/   [🔒 Héritage bloqué]
│       └── Stratégie_2025.docx
```

#### 🔀 Permissions effectives

Les permissions effectives sont le résultat de la combinaison de plusieurs règles :

**Règles de calcul :**

1. **Cumul** : Les permissions s'additionnent (Lecture + Écriture = Modification)
2. **Refus prioritaire** : Un refus explicite l'emporte sur toute autorisation
3. **Explicite > Hérité** : Les permissions explicites ont la priorité
4. **Groupe > Utilisateur** : Les permissions de groupe s'appliquent même si l'utilisateur a des permissions différentes

> [!example] Calcul de permissions effectives Utilisateur "Marie" membre de "Comptables" et "Auditeurs" :
> 
> - Comptables → Modification (héritée)
> - Auditeurs → Lecture (explicite)
> - Marie (utilisateur) → Refus d'écriture (explicite)
> 
> **Résultat** : Marie peut lire mais pas écrire (le refus explicite l'emporte)

#### 🛠️ Vérification des permissions effectives

**Via l'interface graphique :**

1. Clic droit sur le dossier → **Propriétés**
2. Onglet **Sécurité** → **Avancé**
3. Onglet **Accès effectif**
4. Sélectionner un utilisateur ou groupe

**Via PowerShell :**

```powershell
# Obtenir les ACL d'un dossier
Get-Acl "C:\Dossier" | Format-List

# Voir les permissions pour un utilisateur spécifique
(Get-Acl "C:\Dossier").Access | Where-Object {$_.IdentityReference -like "*utilisateur*"}

# Permissions effectives (nécessite module NTFSSecurity)
Get-NTFSEffectiveAccess -Path "C:\Dossier" -Account "DOMAINE\utilisateur"
```

> [!tip] Outil de diagnostic L'outil "Accès effectif" dans les propriétés de sécurité est votre meilleur ami pour déboguer les problèmes de permissions. Il simule l'accès réel d'un utilisateur en tenant compte de tous ses groupes et de toutes les règles.

---

## 👥 Utilisation des groupes AD pour les permissions

### Stratégie AGDLP/AGUDLP

La stratégie AGDLP (ou AGUDLP en environnement multi-domaines) est la méthode recommandée par Microsoft pour gérer les permissions dans Active Directory.

#### 📐 Le modèle AGDLP

**AGDLP** signifie :

- **A**ccounts (Comptes utilisateurs)
- **G**lobal groups (Groupes globaux)
- **D**omain local groups (Groupes locaux de domaine)
- **L**ocal groups (Groupes locaux)
- **P**ermissions (Permissions)

> [!info] Philosophie AGDLP Cette stratégie sépare clairement l'identité (qui sont les utilisateurs) de la fonction (que font-ils) et de l'accès (à quoi ont-ils accès). Cette séparation facilite grandement la maintenance et l'évolution.

#### 🔄 Flux de la stratégie

```
Utilisateurs → Groupes Globaux → Groupes Locaux de Domaine → Permissions
    (A)             (G)                    (DL)                  (P)
```

**Étape par étape :**

1. **A → G** : Les utilisateurs sont placés dans des **groupes globaux** basés sur leur rôle organisationnel
    
    - Exemple : Groupe "GG_Comptables", "GG_RH", "GG_IT"
2. **G → DL** : Les groupes globaux sont ajoutés dans des **groupes locaux de domaine** basés sur les besoins d'accès
    
    - Exemple : "DL_Compta_Lecture", "DL_Compta_Modification"
3. **DL → P** : Les permissions NTFS sont attribuées aux **groupes locaux de domaine**
    
    - Exemple : "DL_Compta_Modification" reçoit la permission "Modification" sur \Serveur\Comptabilité

> [!example] Exemple complet AGDLP
> 
> **Besoin** : Les comptables doivent pouvoir modifier les fichiers du dossier Comptabilité
> 
> **Mise en œuvre :**
> 
> ```
> 1. Créer le groupe global : GG_Comptables
>    └─ Ajouter : Marie, Pierre, Sophie
> 
> 2. Créer le groupe local de domaine : DL_Compta_Modification
>    └─ Ajouter comme membre : GG_Comptables
> 
> 3. Sur le dossier \\Serveur\Comptabilité
>    └─ Attribuer "Modification" à DL_Compta_Modification
> ```

#### 🌍 AGUDLP pour les environnements multi-domaines

**AGUDLP** ajoute un niveau supplémentaire :

- **A**ccounts
- **G**lobal groups
- **U**niversal groups (Groupes universels)
- **D**omain local groups
- **L**ocal groups
- **P**ermissions

```
Utilisateurs → Groupes Globaux → Groupes Universels → Groupes Locaux de Domaine → Permissions
```

Les groupes universels permettent de regrouper des groupes globaux de différents domaines.

> [!tip] Quand utiliser AGUDLP ? Utilisez AGUDLP uniquement si vous avez plusieurs domaines dans votre forêt. Pour un domaine unique, AGDLP suffit et simplifie la gestion.

### Attribution des permissions via groupes

#### 🎯 Méthodologie pratique

**Étape 1 : Analyse des besoins**

Identifiez les rôles organisationnels et leurs besoins d'accès :

- Qui sont les utilisateurs ? (Département, fonction)
- Que doivent-ils faire ? (Lire, modifier, créer)
- Sur quelles ressources ? (Dossiers, applications)

**Étape 2 : Création des groupes globaux**

Créez des groupes globaux basés sur l'organisation :

```powershell
# Créer un groupe global pour un département
New-ADGroup -Name "GG_Comptabilite" `
            -GroupScope Global `
            -GroupCategory Security `
            -Description "Membres du département Comptabilité" `
            -Path "OU=Groupes,OU=Departements,DC=entreprise,DC=local"

# Ajouter des utilisateurs
Add-ADGroupMember -Identity "GG_Comptabilite" `
                  -Members "marie.dubois", "pierre.martin", "sophie.bernard"
```

**Étape 3 : Création des groupes locaux de domaine**

Créez des groupes DL basés sur les permissions nécessaires :

```powershell
# Groupe pour la lecture seule
New-ADGroup -Name "DL_Compta_Lecture" `
            -GroupScope DomainLocal `
            -GroupCategory Security `
            -Description "Lecture sur dossiers comptabilité" `
            -Path "OU=Permissions,OU=Groupes,DC=entreprise,DC=local"

# Groupe pour la modification
New-ADGroup -Name "DL_Compta_Modification" `
            -GroupScope DomainLocal `
            -GroupCategory Security `
            -Description "Modification sur dossiers comptabilité" `
            -Path "OU=Permissions,OU=Groupes,DC=entreprise,DC=local"
```

**Étape 4 : Liaison des groupes**

Ajoutez les groupes globaux dans les groupes DL :

```powershell
# Les comptables peuvent modifier
Add-ADGroupMember -Identity "DL_Compta_Modification" -Members "GG_Comptabilite"

# La direction peut consulter
Add-ADGroupMember -Identity "DL_Compta_Lecture" -Members "GG_Direction"
```

**Étape 5 : Attribution des permissions NTFS**

Appliquez les permissions aux groupes DL :

```powershell
# Via PowerShell (nécessite le module NTFSSecurity)
Add-NTFSAccess -Path "\\Serveur\Partages\Comptabilite" `
               -Account "ENTREPRISE\DL_Compta_Modification" `
               -AccessRights Modify `
               -AppliesTo ThisFolderSubfoldersAndFiles

Add-NTFSAccess -Path "\\Serveur\Partages\Comptabilite" `
               -Account "ENTREPRISE\DL_Compta_Lecture" `
               -AccessRights ReadAndExecute `
               -AppliesTo ThisFolderSubfoldersAndFiles
```

> [!example] Architecture complète
> 
> ```
> Structure organisationnelle :
> 
> Utilisateurs                    Groupes Globaux              Groupes DL                    Ressources
> ────────────                    ───────────────              ──────────                    ──────────
> marie.dubois    ──┐
> pierre.martin   ──┼──→  GG_Comptabilite  ──┬──→  DL_Compta_Modification  ──→  \\Serveur\Comptabilite
> sophie.bernard  ──┘                        │                                       (Permission: Modification)
>                                            │
> jean.directeur  ──────→  GG_Direction  ────┴──→  DL_Compta_Lecture  ───────→  \\Serveur\Comptabilite
>                                                                                   (Permission: Lecture)
> ```

#### 🔐 Gestion des permissions spéciales

Pour des cas spécifiques, créez des groupes dédiés :

**Scénario 1 : Accès temporaire**

```powershell
# Groupe pour un projet temporaire
New-ADGroup -Name "GG_Projet_Migration_2025" `
            -GroupScope Global `
            -GroupCategory Security `
            -Description "Équipe projet migration - expire mars 2025"

# Groupe DL pour les permissions
New-ADGroup -Name "DL_Projet_Migration_RW" `
            -GroupScope DomainLocal `
            -GroupCategory Security

# Attribution de permissions avec date d'expiration dans la description
```

**Scénario 2 : Accès multi-départements**

```powershell
# Plusieurs groupes globaux pour un même accès
Add-ADGroupMember -Identity "DL_Projet_Lecture" -Members "GG_Comptabilite"
Add-ADGroupMember -Identity "DL_Projet_Lecture" -Members "GG_RH"
Add-ADGroupMember -Identity "DL_Projet_Lecture" -Members "GG_Direction"
```

#### 📊 Vérification et audit

**Lister les membres d'un groupe :**

```powershell
# Membres directs
Get-ADGroupMember -Identity "DL_Compta_Modification"

# Membres récursifs (inclut les sous-groupes)
Get-ADGroupMember -Identity "DL_Compta_Modification" -Recursive
```

**Lister les groupes d'un utilisateur :**

```powershell
Get-ADUser -Identity "marie.dubois" -Properties MemberOf | 
    Select-Object -ExpandProperty MemberOf
```

**Auditer les permissions d'un dossier :**

```powershell
# Via ACL natif
(Get-Acl "\\Serveur\Partages\Comptabilite").Access | 
    Format-Table IdentityReference, FileSystemRights, AccessControlType

# Avec NTFSSecurity (plus lisible)
Get-NTFSAccess -Path "\\Serveur\Partages\Comptabilite" | 
    Format-Table Account, AccessRights, AccessControlType, IsInherited
```

### Bonnes pratiques

#### ✅ Principes fondamentaux

> [!tip] Règle d'or **Principe du moindre privilège** : Accordez uniquement les permissions strictement nécessaires pour accomplir le travail. Rien de plus.

**1. Toujours utiliser des groupes, jamais des utilisateurs directs**

❌ **Mauvais :**

```
Permission sur \\Serveur\Compta → marie.dubois (Modification)
Permission sur \\Serveur\Compta → pierre.martin (Modification)
Permission sur \\Serveur\Compta → sophie.bernard (Modification)
```

✅ **Bon :**

```
Permission sur \\Serveur\Compta → DL_Compta_Modification (Modification)
└─ Membre : GG_Comptabilite
    └─ Membres : marie.dubois, pierre.martin, sophie.bernard
```

**2. Respecter la stratégie AGDLP**

Ne prenez pas de raccourcis, même si cela semble plus simple à court terme.

❌ **Mauvais :**

```
Utilisateurs → Permissions directement
Groupes Globaux → Permissions (court-circuite les DL)
```

✅ **Bon :**

```
Utilisateurs → Groupes Globaux → Groupes DL → Permissions
```

**3. Convention de nommage claire**

Adoptez une convention de nommage cohérente pour faciliter la compréhension :

```
Groupes Globaux : GG_[Département]_[Fonction]
  Exemples : GG_Compta_Analystes, GG_IT_Admins, GG_RH_Gestionnaires

Groupes Domain Local : DL_[Ressource]_[Permission]
  Exemples : DL_Compta_Lecture, DL_Compta_Modification, DL_SharePoint_Contributeur
```

> [!example] Convention complète
> 
> ```
> Type de groupe    Préfixe    Format
> ────────────────  ─────────  ──────────────────────────────
> Global            GG_        GG_[Dept]_[Role]
> Domain Local      DL_        DL_[Resource]_[Permission]
> Universal         UG_        UG_[MultiDomain]_[Function]
> ```

#### 🎯 Organisation et structure

**4. Créer une OU dédiée aux groupes de permissions**

```
Entreprise.local
└── Groupes
    ├── Departements (Groupes Globaux)
    │   ├── GG_Comptabilite
    │   ├── GG_RH
    │   └── GG_IT
    └── Permissions (Groupes Domain Local)
        ├── Partages
        │   ├── DL_Compta_Lecture
        │   └── DL_Compta_Modification
        └── Applications
            ├── DL_SAP_Utilisateurs
            └── DL_SAP_Admins
```

**5. Documenter les groupes**

Utilisez le champ "Description" de manière systématique :

```powershell
Set-ADGroup -Identity "DL_Compta_Modification" `
            -Description "Modification sur \\SRV-FS01\Departements\Comptabilite - Contact: responsable.it@entreprise.local"
```

**6. Grouper par fonction, pas par projet**

❌ **Mauvais :** DL_ProjetAlpha_Lecture, DL_ProjetBeta_Lecture ✅ **Bon :** DL_Projets_Lecture (utilisable pour tous les projets)

#### 🔒 Sécurité et maintenance

**7. Audit régulier des permissions**

Planifiez des revues trimestrielles :

- Qui a accès à quoi ?
- Les accès sont-ils toujours justifiés ?
- Des utilisateurs ont-ils quitté l'entreprise ?
- Des projets sont-ils terminés ?

```powershell
# Script d'audit mensuel
$Date = Get-Date -Format "yyyy-MM"
$RapportPath = "\\Serveur\Audits\Permissions_$Date.html"

# Lister tous les groupes DL et leurs membres
Get-ADGroup -Filter {GroupScope -eq "DomainLocal"} | 
    ForEach-Object {
        [PSCustomObject]@{
            Groupe = $_.Name
            Membres = (Get-ADGroupMember $_.Name).Name -join ", "
            Description = $_.Description
        }
    } | ConvertTo-Html | Out-File $RapportPath
```

**8. Éviter les refus explicites**

Les refus sont difficiles à déboguer et peuvent créer des comportements inattendus.

❌ **Mauvais :**

```
DL_Compta_Modification → Modification
marie.dubois → Refus d'écriture (explicite)
```

✅ **Bon :**

```
DL_Compta_Lecture → Lecture (marie dedans)
DL_Compta_Modification → Modification (marie pas dedans)
```

**9. Séparer les administrateurs des utilisateurs standard**

Les comptes administrateurs ne doivent pas être dans les groupes utilisateurs standards.

```
jean.dupont → GG_IT (utilisateur standard)
jean.dupont-admin → GG_IT_Admins (compte admin séparé)
```

**10. Limiter les modifications d'héritage**

Ne bloquez l'héritage que si absolument nécessaire. Chaque blocage augmente la complexité.

> [!warning] Impact du blocage d'héritage
> 
> - Augmente le temps de gestion
> - Complique les audits
> - Risque d'incohérences
> - Difficile à troubleshooter

#### 🚀 Optimisation

**11. Utiliser les permissions de base autant que possible**

Les permissions avancées sont rarement nécessaires et complexifient la gestion.

**12. Créer des modèles de permissions**

Pour des structures répétitives, créez des scripts de déploiement :

```powershell
function New-DossierDepartement {
    param(
        [string]$NomDepartement,
        [string]$CheminBase = "\\Serveur\Departements"
    )
    
    # Créer les groupes
    New-ADGroup -Name "GG_$NomDepartement" -GroupScope Global
    New-ADGroup -Name "DL_${NomDepartement}_Lecture" -GroupScope DomainLocal
    New-ADGroup -Name "DL_${NomDepartement}_Modification" -GroupScope DomainLocal
    
    # Lier les groupes
    Add-ADGroupMember -Identity "DL_${NomDepartement}_Modification" -Members "GG_$NomDepartement"
    
    # Créer le dossier
    $Chemin = Join-Path $CheminBase $NomDepartement
    New-Item -Path $Chemin -ItemType Directory
    
    # Appliquer les permissions
    Add-NTFSAccess -Path $Chemin -Account "ENTREPRISE\DL_${NomDepartement}_Modification" -AccessRights Modify
    Add-NTFSAccess -Path $Chemin -Account "ENTREPRISE\DL_${NomDepartement}_Lecture" -AccessRights Read
}

# Utilisation
New-DossierDepartement -NomDepartement "Marketing"
```

**13. Privilégier la simplicité**

Une structure simple est plus facile à maintenir et à comprendre.

> [!tip] Test de simplicité Si vous ne pouvez pas expliquer votre structure de permissions en 2 minutes à un nouvel administrateur, elle est probablement trop complexe.

#### 🔍 Dépannage

**14. Utiliser l'outil "Accès effectif"**

Pour résoudre les problèmes de permissions :

1. Propriétés du dossier → Sécurité → Avancé
2. Onglet "Accès effectif"
3. Sélectionner l'utilisateur
4. Voir exactement ce qu'il peut faire et pourquoi

**15. Vérifier l'appartenance aux groupes**

```powershell
# Voir tous les groupes d'un utilisateur (direct et imbriqués)
Get-ADUser "marie.dubois" -Properties MemberOf | 
    Select-Object -ExpandProperty MemberOf |
    ForEach-Object { Get-ADGroup $_ } |
    Select-Object Name, GroupScope
```

> [!warning] Pièges courants
> 
> **Piège 1** : Oublier la réplication AD
> 
> - Les modifications de groupes peuvent prendre 15 minutes pour se propager
> - Forcer la réplication si urgent : `repadmin /syncall`
> 
> **Piège 2** : Cache des credentials
> 
> - L'utilisateur doit se reconnecter pour obtenir ses nouveaux groupes
> - Ou lancer : `klist purge` puis ouvrir une nouvelle session
> 
> **Piège 3** : Permissions de partage vs NTFS
> 
> - Les permissions les plus restrictives s'appliquent
> - Vérifiez toujours les deux types de permissions

---

## 📝 Récapitulatif

### Points clés à retenir

1. **Permissions NTFS** : Sécurité au niveau fichier, indépendante du protocole d'accès
2. **Héritage** : Simplifie la gestion mais doit être utilisé judicieusement
3. **AGDLP** : Méthodologie standard pour lier utilisateurs et permissions
4. **Groupes avant tout** : Ne jamais attribuer de permissions directement aux utilisateurs
5. **Documentation** : Nommage cohérent et descriptions claires
6. **Audit régulier** : Vérifier et nettoyer les permissions périodiquement

### Flux de décision

```
Nouveau besoin d'accès
    ↓
L'utilisateur est-il dans un groupe global approprié ?
    Non → Créer GG_[Département] et ajouter l'utilisateur
    Oui → Passer à l'étape suivante
    ↓
Existe-t-il un groupe DL pour cette ressource/permission ?
    Non → Créer DL_[Ressource]_[Permission]
    Oui → Passer à l'étape suivante
    ↓
Le groupe global est-il membre du groupe DL ?
    Non → Ajouter GG dans DL
    Oui → Passer à l'étape suivante
    ↓
Le groupe DL a-t-il les permissions NTFS appropriées ?
    Non → Attribuer les permissions au groupe DL
    Oui → Terminé !
```

### Commandes PowerShell essentielles

**Gestion des groupes :**

```powershell
# Créer un groupe
New-ADGroup -Name "NomGroupe" -GroupScope Global/DomainLocal -GroupCategory Security

# Ajouter un membre
Add-ADGroupMember -Identity "NomGroupe" -Members "utilisateur1", "utilisateur2"

# Retirer un membre
Remove-ADGroupMember -Identity "NomGroupe" -Members "utilisateur1"

# Lister les membres
Get-ADGroupMember -Identity "NomGroupe"

# Lister les groupes d'un utilisateur
Get-ADUser "utilisateur" -Properties MemberOf | Select-Object -ExpandProperty MemberOf
```

**Gestion des permissions NTFS :**

```powershell
# Obtenir les ACL
Get-Acl "C:\Chemin\Dossier"

# Voir les permissions (avec NTFSSecurity)
Get-NTFSAccess -Path "C:\Chemin\Dossier"

# Ajouter une permission
Add-NTFSAccess -Path "C:\Chemin" -Account "DOMAINE\Groupe" -AccessRights Modify

# Retirer une permission
Remove-NTFSAccess -Path "C:\Chemin" -Account "DOMAINE\Groupe"

# Vérifier l'accès effectif
Get-NTFSEffectiveAccess -Path "C:\Chemin" -Account "DOMAINE\utilisateur"
```

---

## 🎓 Synthèse finale

### Architecture complète recommandée

```
┌─────────────────────────────────────────────────────────────────────┐
│                    ACTIVE DIRECTORY                                  │
│                                                                       │
│  ┌────────────────┐      ┌──────────────────┐      ┌──────────────┐│
│  │   UTILISATEURS │      │  GROUPES GLOBAUX │      │  GROUPES DL  ││
│  │                │      │                  │      │              ││
│  │  marie.dubois  │─────▶│  GG_Comptabilite │─────▶│DL_Compta_RW  ││
│  │ pierre.martin  │─────▶│                  │      │              ││
│  │ sophie.bernard │─────▶│                  │      │              ││
│  │                │      │                  │      │              ││
│  │ jean.directeur │─────▶│  GG_Direction    │─────▶│DL_Compta_RO  ││
│  └────────────────┘      └──────────────────┘      └──────┬───────┘│
│                                                             │        │
└─────────────────────────────────────────────────────────────┼────────┘
                                                              │
                                                              ▼
┌─────────────────────────────────────────────────────────────────────┐
│                    SERVEUR DE FICHIERS                               │
│                                                                       │
│  \\SRV-FS01\Departements\                                           │
│  │                                                                    │
│  ├── Comptabilite\                                                   │
│  │   ├── [DL_Compta_RW: Modification] ◄─────────────────────────────┤
│  │   ├── [DL_Compta_RO: Lecture]                                    │
│  │   │                                                               │
│  │   ├── Budget_2025.xlsx                                           │
│  │   ├── Factures\                                                  │
│  │   └── Bilans\                                                    │
│  │                                                                    │
│  ├── RH\                                                             │
│  └── IT\                                                             │
│                                                                       │
└─────────────────────────────────────────────────────────────────────┘
```

### Les 5 règles d'or

> [!tip] Les 5 commandements de la gestion des permissions
> 
> 1. **Tu utiliseras toujours des groupes** - Jamais de permissions directes aux utilisateurs
> 2. **Tu respecteras AGDLP** - Utilisateurs → GG → DL → Permissions
> 3. **Tu nommeras avec cohérence** - Convention claire et documentée
> 4. **Tu hériteras autant que possible** - Bloquer l'héritage uniquement si nécessaire
> 5. **Tu auditeras régulièrement** - Vérifier et nettoyer les accès périodiquement

### Checklist de mise en œuvre

**Phase 1 : Préparation**

- [ ] Définir la convention de nommage
- [ ] Créer la structure d'OU pour les groupes
- [ ] Documenter la stratégie AGDLP
- [ ] Former les administrateurs

**Phase 2 : Création des groupes**

- [ ] Créer les groupes globaux par département/fonction
- [ ] Créer les groupes DL par ressource/permission
- [ ] Ajouter les utilisateurs dans les groupes globaux
- [ ] Ajouter les groupes globaux dans les groupes DL

**Phase 3 : Attribution des permissions**

- [ ] Nettoyer les permissions utilisateurs directes existantes
- [ ] Attribuer les permissions NTFS aux groupes DL
- [ ] Vérifier l'héritage des permissions
- [ ] Tester avec des comptes utilisateurs

**Phase 4 : Validation et documentation**

- [ ] Vérifier les accès effectifs pour chaque rôle
- [ ] Documenter la structure dans un wiki/Confluence
- [ ] Créer des scripts de déploiement pour les nouveaux dossiers
- [ ] Mettre en place un processus d'audit mensuel

### Exemple de projet complet

Voici un exemple concret de déploiement pour une entreprise :

```powershell
# === SCRIPT DE DÉPLOIEMENT COMPLET ===
# Entreprise: Exemple Corp
# Date: 2025-01-15

# Variables
$DomainDN = "DC=exemple,DC=local"
$GroupsOU = "OU=Groupes,$DomainDN"
$SharePath = "\\SRV-FS01\Departements"

# === ÉTAPE 1: Créer la structure d'OU ===
New-ADOrganizationalUnit -Name "Groupes" -Path $DomainDN
New-ADOrganizationalUnit -Name "Departements" -Path $GroupsOU
New-ADOrganizationalUnit -Name "Permissions" -Path $GroupsOU

# === ÉTAPE 2: Créer les groupes globaux ===
$Departements = @("Comptabilite", "RH", "IT", "Commercial", "Direction")

foreach ($Dept in $Departements) {
    New-ADGroup -Name "GG_$Dept" `
                -GroupScope Global `
                -GroupCategory Security `
                -Path "OU=Departements,$GroupsOU" `
                -Description "Membres du département $Dept"
    
    Write-Host "✓ Groupe créé: GG_$Dept" -ForegroundColor Green
}

# === ÉTAPE 3: Créer les groupes Domain Local ===
$Permissions = @(
    @{Resource="Comptabilite"; Access="Lecture"},
    @{Resource="Comptabilite"; Access="Modification"},
    @{Resource="RH"; Access="Lecture"},
    @{Resource="RH"; Access="Modification"},
    @{Resource="Partage"; Access="Lecture"}  # Partage commun
)

foreach ($Perm in $Permissions) {
    $GroupName = "DL_$($Perm.Resource)_$($Perm.Access)"
    
    New-ADGroup -Name $GroupName `
                -GroupScope DomainLocal `
                -GroupCategory Security `
                -Path "OU=Permissions,$GroupsOU" `
                -Description "Permission $($Perm.Access) sur $($Perm.Resource)"
    
    Write-Host "✓ Groupe créé: $GroupName" -ForegroundColor Green
}

# === ÉTAPE 4: Lier les groupes (AGDLP) ===
# Comptabilité
Add-ADGroupMember -Identity "DL_Comptabilite_Modification" -Members "GG_Comptabilite"
Add-ADGroupMember -Identity "DL_Comptabilite_Lecture" -Members "GG_Direction", "GG_IT"

# RH
Add-ADGroupMember -Identity "DL_RH_Modification" -Members "GG_RH"
Add-ADGroupMember -Identity "DL_RH_Lecture" -Members "GG_Direction"

# Partage commun
Add-ADGroupMember -Identity "DL_Partage_Lecture" -Members "GG_Comptabilite", "GG_RH", "GG_Commercial"

Write-Host "✓ Groupes liés selon AGDLP" -ForegroundColor Green

# === ÉTAPE 5: Créer les dossiers et attribuer les permissions ===
$Dossiers = @(
    @{Nom="Comptabilite"; Groupes=@(
        @{Nom="DL_Comptabilite_Modification"; Droit="Modify"},
        @{Nom="DL_Comptabilite_Lecture"; Droit="ReadAndExecute"}
    )},
    @{Nom="RH"; Groupes=@(
        @{Nom="DL_RH_Modification"; Droit="Modify"},
        @{Nom="DL_RH_Lecture"; Droit="ReadAndExecute"}
    )},
    @{Nom="Partage_Commun"; Groupes=@(
        @{Nom="DL_Partage_Lecture"; Droit="ReadAndExecute"}
    )}
)

foreach ($Dossier in $Dossiers) {
    $CheminComplet = Join-Path $SharePath $Dossier.Nom
    
    # Créer le dossier
    New-Item -Path $CheminComplet -ItemType Directory -Force
    
    # Désactiver l'héritage et copier les permissions
    $Acl = Get-Acl $CheminComplet
    $Acl.SetAccessRuleProtection($true, $true)
    Set-Acl -Path $CheminComplet -AclObject $Acl
    
    # Supprimer les permissions utilisateurs
    $Acl = Get-Acl $CheminComplet
    $Acl.Access | Where-Object {$_.IsInherited -eq $false} | ForEach-Object {
        $Acl.RemoveAccessRule($_)
    }
    
    # Ajouter les permissions des groupes
    foreach ($Groupe in $Dossier.Groupes) {
        $Identity = "EXEMPLE\$($Groupe.Nom)"
        $Rights = [System.Security.AccessControl.FileSystemRights]$Groupe.Droit
        $InheritanceFlags = [System.Security.AccessControl.InheritanceFlags]"ContainerInherit,ObjectInherit"
        $PropagationFlags = [System.Security.AccessControl.PropagationFlags]"None"
        $AccessControl = [System.Security.AccessControl.AccessControlType]"Allow"
        
        $AccessRule = New-Object System.Security.AccessControl.FileSystemAccessRule(
            $Identity, $Rights, $InheritanceFlags, $PropagationFlags, $AccessControl
        )
        
        $Acl.AddAccessRule($AccessRule)
    }
    
    # Appliquer les permissions
    Set-Acl -Path $CheminComplet -AclObject $Acl
    
    Write-Host "✓ Dossier créé et sécurisé: $($Dossier.Nom)" -ForegroundColor Green
}

# === ÉTAPE 6: Rapport de validation ===
Write-Host "`n=== RAPPORT DE DÉPLOIEMENT ===" -ForegroundColor Cyan
Write-Host "Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm')" -ForegroundColor Cyan

Write-Host "`nGroupes créés:" -ForegroundColor Yellow
Get-ADGroup -Filter {Name -like "GG_*" -or Name -like "DL_*"} | 
    Sort-Object Name | 
    Format-Table Name, GroupScope, Description -AutoSize

Write-Host "`nStructure des dossiers:" -ForegroundColor Yellow
Get-ChildItem $SharePath | Format-Table Name, LastWriteTime

Write-Host "`n✓ Déploiement terminé avec succès!" -ForegroundColor Green
```

### Maintenance continue

**Scripts d'audit mensuel :**

```powershell
# Script d'audit des permissions
$DateRapport = Get-Date -Format "yyyy-MM-dd"
$CheminRapport = "C:\Audits\Permissions_$DateRapport.html"

# En-tête HTML
$HTML = @"
<html>
<head>
    <title>Audit des permissions - $DateRapport</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        h1 { color: #0066cc; }
        h2 { color: #333; border-bottom: 2px solid #0066cc; }
        table { border-collapse: collapse; width: 100%; margin-bottom: 20px; }
        th { background-color: #0066cc; color: white; padding: 10px; text-align: left; }
        td { border: 1px solid #ddd; padding: 8px; }
        tr:nth-child(even) { background-color: #f2f2f2; }
        .warning { color: #ff6600; font-weight: bold; }
        .info { color: #0066cc; }
    </style>
</head>
<body>
    <h1>Audit des permissions Active Directory</h1>
    <p>Date: $DateRapport</p>
"@

# Section 1: Groupes DL et leurs membres
$HTML += "<h2>Groupes Domain Local et leurs membres</h2>"
$GroupesDL = Get-ADGroup -Filter {GroupScope -eq "DomainLocal"} | Sort-Object Name

$TableauGroupes = foreach ($Groupe in $GroupesDL) {
    $Membres = Get-ADGroupMember $Groupe.Name | Select-Object -ExpandProperty Name
    
    [PSCustomObject]@{
        "Groupe" = $Groupe.Name
        "Description" = $Groupe.Description
        "Nombre de membres" = $Membres.Count
        "Membres" = ($Membres -join ", ")
    }
}

$HTML += $TableauGroupes | ConvertTo-Html -Fragment

# Section 2: Utilisateurs sans groupe
$HTML += "<h2>⚠️ Utilisateurs sans appartenance à un groupe</h2>"
$UtilisateursSansGroupe = Get-ADUser -Filter {Enabled -eq $true} -Properties MemberOf | 
    Where-Object {$_.MemberOf.Count -eq 0} |
    Select-Object Name, SamAccountName

if ($UtilisateursSansGroupe) {
    $HTML += "<p class='warning'>Attention: Ces utilisateurs n'appartiennent à aucun groupe!</p>"
    $HTML += $UtilisateursSansGroupe | ConvertTo-Html -Fragment
} else {
    $HTML += "<p class='info'>✓ Tous les utilisateurs appartiennent à au moins un groupe.</p>"
}

# Section 3: Groupes vides
$HTML += "<h2>⚠️ Groupes vides</h2>"
$GroupesVides = Get-ADGroup -Filter * | Where-Object {
    (Get-ADGroupMember $_.Name).Count -eq 0
} | Select-Object Name, GroupScope, Description

if ($GroupesVides) {
    $HTML += "<p class='warning'>Ces groupes n'ont aucun membre:</p>"
    $HTML += $GroupesVides | ConvertTo-Html -Fragment
} else {
    $HTML += "<p class='info'>✓ Aucun groupe vide détecté.</p>"
}

# Fermeture HTML
$HTML += "</body></html>"

# Sauvegarder le rapport
$HTML | Out-File $CheminRapport -Encoding UTF8

Write-Host "✓ Rapport d'audit généré: $CheminRapport" -ForegroundColor Green
```

---

## 🎯 Conclusion

La gestion des droits et permissions dans Active Directory repose sur trois piliers fondamentaux :

1. **Les permissions NTFS** assurent la sécurité au niveau du système de fichiers
2. **La stratégie AGDLP** structure l'attribution des droits de manière logique et maintenable
3. **Les bonnes pratiques** garantissent une gestion efficace et sécurisée à long terme

En appliquant ces principes avec rigueur, vous créerez une infrastructure de permissions robuste, facile à auditer et à maintenir. La clé du succès réside dans la discipline : respecter la convention de nommage, documenter chaque choix, et auditer régulièrement les accès.

> [!success] Objectif atteint Vous maîtrisez maintenant les concepts essentiels pour gérer efficacement les droits et permissions dans un environnement Active Directory. La mise en pratique progressive de ces connaissances vous permettra de développer des réflexes d'administration sécurisée.