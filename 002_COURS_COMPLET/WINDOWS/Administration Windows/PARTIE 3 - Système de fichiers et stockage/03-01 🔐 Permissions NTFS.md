
---

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

## 🎯 Introduction aux permissions NTFS

Les **permissions NTFS** constituent le système de sécurité fondamental de Windows pour contrôler l'accès aux fichiers et dossiers. Contrairement aux permissions de partage qui ne s'appliquent qu'aux accès réseau, les permissions NTFS protègent les ressources localement ET à distance.

> [!info] Pourquoi les permissions NTFS sont essentielles
> 
> - **Sécurité granulaire** : Contrôle précis fichier par fichier
> - **Protection multicouche** : S'appliquent en local et via le réseau
> - **Auditabilité** : Traçabilité complète des accès
> - **Héritage intelligent** : Propagation automatique des permissions

### 🔍 Quand utiliser les permissions NTFS

- **Protéger des données sensibles** : Documents confidentiels, bases de données
- **Séparer les accès par département** : Comptabilité, RH, Direction
- **Limiter les modifications** : Empêcher la suppression accidentelle
- **Respecter la conformité** : RGPD, normes ISO, audits de sécurité

---

## 📊 Types de permissions NTFS

### Permissions de base

Les permissions de base sont les permissions standard présentées dans l'onglet "Sécurité" des propriétés d'un fichier ou dossier. Elles représentent des combinaisons logiques de permissions avancées.

|Permission|Fichiers|Dossiers|Usage typique|
|---|---|---|---|
|**Contrôle total**|Toutes les actions possibles|Toutes les actions possibles|Administrateurs, propriétaires|
|**Modification**|Lire, écrire, modifier, supprimer|Créer, modifier, supprimer fichiers/sous-dossiers|Utilisateurs standards sur leurs données|
|**Lecture et exécution**|Lire et exécuter|Lire et parcourir|Applications, scripts|
|**Lecture**|Consulter le contenu|Lister le contenu|Consultation uniquement|
|**Écriture**|Créer, modifier|Créer fichiers et sous-dossiers|Dépôts de fichiers|
|**Permissions spéciales**|Combinaison personnalisée|Combinaison personnalisée|Cas avancés|

> [!example] Exemple d'utilisation **Dossier "Comptabilité"** :
> 
> - Groupe "Comptables" : Modification
> - Groupe "Direction" : Lecture et exécution
> - Groupe "RH" : Aucun accès (non listé)

### Permissions avancées

Les permissions avancées offrent un contrôle granulaire. Elles sont accessibles via le bouton "Avancé" dans l'onglet Sécurité.

#### 📁 Permissions avancées pour les dossiers

|Permission avancée|Description|Incluse dans|
|---|---|---|
|**Parcourir le dossier / Exécuter le fichier**|Naviguer dans la structure|Lecture et exécution|
|**Lister le dossier / Lire les données**|Voir les fichiers et sous-dossiers|Lecture|
|**Attributs de lecture**|Consulter les attributs (lecture seule, caché)|Lecture|
|**Attributs étendus de lecture**|Lire métadonnées supplémentaires|Lecture|
|**Créer des fichiers / Écrire des données**|Ajouter de nouveaux fichiers|Écriture|
|**Créer des dossiers / Ajouter des données**|Créer des sous-dossiers|Écriture|
|**Attributs d'écriture**|Modifier les attributs|Écriture|
|**Attributs étendus d'écriture**|Modifier les métadonnées|Écriture|
|**Supprimer les sous-dossiers et les fichiers**|Supprimer le contenu|Modification|
|**Supprimer**|Supprimer l'élément lui-même|Modification|
|**Autorisations de lecture**|Voir les permissions actuelles|Lecture|
|**Modifier les autorisations**|Changer les permissions|Contrôle total|
|**Appropriation**|Devenir propriétaire|Contrôle total|

#### 📄 Permissions avancées pour les fichiers

|Permission avancée|Description|
|---|---|
|**Lire les données**|Ouvrir et lire le fichier|
|**Écrire les données**|Modifier le contenu|
|**Ajouter des données**|Écrire à la fin du fichier|
|**Lire les attributs étendus**|Consulter les métadonnées|
|**Écrire les attributs étendus**|Modifier les métadonnées|
|**Exécuter le fichier**|Lancer un exécutable ou script|
|**Supprimer**|Effacer le fichier|
|**Autorisations de lecture**|Voir les ACL|
|**Modifier les autorisations**|Changer les ACL|
|**Appropriation**|Prendre possession du fichier|

> [!tip] Astuce pratique Pour voir rapidement toutes les permissions avancées d'un élément :
> 
> ```powershell
> icacls "C:\Chemin\Dossier"
> ```

---

## 🌳 Héritage des permissions

L'**héritage** est le mécanisme par lequel les permissions d'un dossier parent se propagent automatiquement à ses enfants (sous-dossiers et fichiers).

### Principe de fonctionnement

```
📁 Dossier Parent (Permissions définies)
    │
    ├── 📁 Sous-dossier 1 (Hérite)
    │       ├── 📄 Fichier A (Hérite)
    │       └── 📄 Fichier B (Hérite)
    │
    └── 📁 Sous-dossier 2 (Hérite)
            └── 📄 Fichier C (Hérite)
```

> [!info] Types d'héritage
> 
> - **Héritage activé** : Les permissions du parent s'appliquent automatiquement
> - **Héritage désactivé** : Les permissions sont définies manuellement
> - **Héritage bloqué** : Les nouvelles permissions du parent ne se propagent plus

### Gérer l'héritage

#### Via l'interface graphique

1. **Propriétés** du fichier/dossier → Onglet **Sécurité**
2. Bouton **Avancé**
3. Section "Héritage" :
    - **"Désactiver l'héritage"** :
        - Option 1 : Convertir les permissions héritées en permissions explicites
        - Option 2 : Supprimer toutes les permissions héritées
    - **"Activer l'héritage"** : Restaurer la propagation

#### Via PowerShell

```powershell
# Désactiver l'héritage et conserver les permissions actuelles
$acl = Get-Acl "C:\Donnees\Confidentiel"
$acl.SetAccessRuleProtection($true, $true)
Set-Acl "C:\Donnees\Confidentiel" $acl

# Désactiver l'héritage et supprimer les permissions héritées
$acl = Get-Acl "C:\Donnees\Confidentiel"
$acl.SetAccessRuleProtection($true, $false)
Set-Acl "C:\Donnees\Confidentiel" $acl

# Réactiver l'héritage
$acl = Get-Acl "C:\Donnees\Confidentiel"
$acl.SetAccessRuleProtection($false, $false)
Set-Acl "C:\Donnees\Confidentiel" $acl
```

#### Via icacls

```powershell
# Désactiver l'héritage (conserver les permissions)
icacls "C:\Donnees\Confidentiel" /inheritance:d

# Désactiver l'héritage (supprimer les permissions héritées)
icacls "C:\Donnees\Confidentiel" /inheritance:r

# Réactiver l'héritage
icacls "C:\Donnees\Confidentiel" /inheritance:e
```

> [!warning] Attention aux ruptures d'héritage
> 
> - Désactiver l'héritage complique la gestion
> - Privilégier l'organisation par OU et dossiers
> - Documenter les exceptions à l'héritage

### Propagation des permissions

Lors de la modification de permissions sur un dossier parent :

```powershell
# Appliquer les permissions au dossier ET à tout son contenu
icacls "C:\Donnees" /grant "DOMAINE\Comptables:(OI)(CI)M" /T

# Légende :
# (OI) = Object Inherit (héritage pour les fichiers)
# (CI) = Container Inherit (héritage pour les sous-dossiers)
# M = Modify (permission de modification)
# /T = Appliquer récursivement
```

> [!tip] Bonnes pratiques d'héritage
> 
> - Définir les permissions au plus haut niveau possible
> - Utiliser l'héritage pour simplifier la gestion
> - Ne désactiver l'héritage qu'en cas de nécessité absolue
> - Tester avant d'appliquer massivement

---

## 👤 Propriétaire et prise de contrôle

### Concept de propriétaire

Le **propriétaire** d'un fichier ou dossier possède des droits spéciaux :

- Peut toujours modifier les permissions (même sans "Contrôle total")
- Peut consulter et modifier le contenu (selon le contexte)
- Ne peut pas se voir refuser complètement l'accès

> [!info] Propriétaire par défaut
> 
> - **Créateur** : L'utilisateur qui crée un fichier/dossier en devient propriétaire
> - **Groupe Administrateurs** : Souvent propriétaire sur les ressources système

### Voir le propriétaire

#### Interface graphique

1. **Propriétés** → **Sécurité** → **Avancé**
2. Section "Propriétaire" en haut de la fenêtre

#### PowerShell

```powershell
# Voir le propriétaire d'un élément
(Get-Acl "C:\Donnees\Document.docx").Owner

# Voir le propriétaire de plusieurs fichiers
Get-ChildItem "C:\Donnees" -Recurse | ForEach-Object {
    [PSCustomObject]@{
        Chemin = $_.FullName
        Propriétaire = (Get-Acl $_.FullName).Owner
    }
}
```

#### Icacls

```powershell
icacls "C:\Donnees\Document.docx" | Select-String "propriétaire"
```

### Prendre possession (Take Ownership)

#### Qui peut prendre possession ?

- Les **Administrateurs** (droit "Appropriation")
- Les utilisateurs avec le privilège **SeTakeOwnershipPrivilege**
- Le propriétaire actuel (peut transférer)

#### Méthodes de prise de contrôle

**Via l'interface graphique :**

1. **Propriétés** → **Sécurité** → **Avancé**
2. Cliquer sur **"Modifier"** à côté du propriétaire
3. Saisir le nouveau propriétaire → **OK**
4. Cocher **"Remplacer le propriétaire sur les sous-conteneurs et les objets"** si nécessaire

**Via PowerShell :**

```powershell
# Prendre possession d'un fichier
$acl = Get-Acl "C:\Donnees\Document.docx"
$user = New-Object System.Security.Principal.NTAccount("DOMAINE\Utilisateur")
$acl.SetOwner($user)
Set-Acl "C:\Donnees\Document.docx" $acl

# Prendre possession récursivement (dossier + contenu)
Get-ChildItem "C:\Donnees" -Recurse | ForEach-Object {
    $acl = Get-Acl $_.FullName
    $acl.SetOwner($user)
    Set-Acl $_.FullName $acl
}
```

**Via takeown :**

```powershell
# Prendre possession (utilisateur actuel)
takeown /F "C:\Donnees\Document.docx"

# Prendre possession récursivement
takeown /F "C:\Donnees" /R /D Y

# Transférer au groupe Administrateurs
takeown /F "C:\Donnees" /A /R /D Y
```

**Via icacls :**

```powershell
# Définir un nouveau propriétaire
icacls "C:\Donnees" /setowner "DOMAINE\Admin" /T /C
```

> [!warning] Pièges courants
> 
> - La prise de possession est **irréversible** sans sauvegarde des ACL
> - Sur un domaine, privilégier un compte de service plutôt qu'un compte personnel
> - Documenter les prises de possession pour l'audit

> [!tip] Cas d'usage de la prise de possession
> 
> - **Récupération de données** : Utilisateur parti, compte supprimé
> - **Migration** : Transfert de serveur de fichiers
> - **Correction d'erreurs** : Permissions cassées après une manipulation
> - **Audit de sécurité** : Analyse de tous les fichiers

---

## 🧮 Permissions effectives

Les **permissions effectives** représentent les droits réels dont dispose un utilisateur sur un fichier ou dossier, après calcul de toutes les règles applicables.

### Calcul des permissions effectives

Les permissions effectives résultent de :

1. **Permissions directes** sur l'utilisateur
2. **Permissions des groupes** auxquels appartient l'utilisateur
3. **Permissions héritées** du parent
4. **Application des refus** (prioritaires)

> [!info] Formule de calcul
> 
> ```
> Permissions effectives = 
>   (Permissions explicites + Permissions héritées + Permissions de groupes) 
>   - Refus explicites - Refus hérités
> ```

### Consulter les permissions effectives

#### Interface graphique

1. **Propriétés** → **Sécurité** → **Avancé**
2. Onglet **"Accès effectif"**
3. Bouton **"Sélectionner un utilisateur"**
4. Saisir le compte → **OK**
5. Windows affiche les permissions réelles et leur origine

#### PowerShell

```powershell
# Voir les permissions effectives d'un utilisateur
$path = "C:\Donnees\Document.docx"
$user = "DOMAINE\JDupont"

# Récupérer l'ACL
$acl = Get-Acl $path

# Afficher toutes les entrées ACL concernant l'utilisateur ou ses groupes
$acl.Access | Where-Object {
    $_.IdentityReference -like "*$user*"
} | Format-Table IdentityReference, FileSystemRights, AccessControlType, IsInherited
```

#### Icacls

```powershell
# Afficher les permissions complètes
icacls "C:\Donnees\Document.docx"

# Résultat typique :
# C:\Donnees\Document.docx DOMAINE\JDupont:(R,W)
#                          BUILTIN\Administrateurs:(F)
#                          NT AUTHORITY\SYSTEM:(F)
```

> [!example] Exemple de calcul **Contexte** :
> 
> - Utilisateur : **JDupont**
> - Groupes : **Comptables**, **Utilisateurs**
> 
> **Permissions sur C:\Rapports** :
> 
> - JDupont (direct) : Lecture ✅
> - Comptables (groupe) : Modification ✅
> - Utilisateurs (groupe) : Lecture et exécution ✅
> - REFUS : Comptables → Écriture ❌
> 
> **Résultat effectif** :
> 
> - ✅ Lecture (cumulée)
> - ✅ Exécution (via Utilisateurs)
> - ❌ Écriture (REFUS prioritaire)
> - ❌ Modification (bloquée par le refus d'écriture)

---

## ⚖️ Cumul et priorité des permissions

### Règles de cumul

Les permissions NTFS suivent des règles strictes de cumul et de priorité :

#### 1️⃣ Cumul des autorisations

Les permissions **AUTORISÉES** se cumulent pour donner le maximum de droits :

```
Utilisateur : Lecture
+ Groupe1 : Écriture
+ Groupe2 : Exécution
= RÉSULTAT : Lecture + Écriture + Exécution
```

> [!tip] Principe du cumul positif Un utilisateur obtient **l'union** de toutes ses permissions autorisées (directes et de groupes).

#### 2️⃣ Priorité des refus

Les permissions **REFUSÉES** l'emportent TOUJOURS sur les permissions autorisées :

```
Utilisateur : Modification AUTORISÉE
+ Groupe : Écriture REFUSÉE
= RÉSULTAT : Lecture et Exécution uniquement (pas d'écriture)
```

> [!warning] Le refus est absolu Un seul REFUS annule toutes les autorisations correspondantes, même un Contrôle Total.

#### 3️⃣ Permissions explicites vs héritées

Les permissions **explicites** (définies directement) ont priorité sur les permissions **héritées** :

```
Dossier Parent : Groupe → Lecture (hérité)
Fichier Enfant : Groupe → Modification (explicite)
= RÉSULTAT sur le fichier : Modification
```

### Tableau de priorité complète

|Priorité|Type de permission|Exemple|
|---|---|---|
|**1 (Max)**|Refus explicite|REFUS Écriture sur le fichier|
|**2**|Autorisation explicite|Modification sur le fichier|
|**3**|Refus hérité|REFUS Écriture du parent|
|**4 (Min)**|Autorisation héritée|Lecture du parent|

### Exemples pratiques

#### Scénario 1 : Cumul simple

```
📁 C:\Projets
   - Groupe "Développeurs" : Modification ✅
   - Groupe "Lecteurs" : Lecture ✅
   - Utilisateur "JDupont" (membre des 2 groupes)

Résultat : JDupont a Modification (le plus permissif)
```

#### Scénario 2 : Refus bloquant

```
📁 C:\Projets
   - Groupe "Développeurs" : Contrôle total ✅
   - Groupe "Stagiaires" : Écriture REFUSÉE ❌
   - Utilisateur "PDurand" (membre des 2 groupes)

Résultat : PDurand peut tout faire SAUF écrire
```

#### Scénario 3 : Explicite vs hérité

```
📁 C:\Projets (parent)
   - Groupe "Tous" : Lecture ✅ (hérité)

📄 C:\Projets\confidentiel.docx (enfant)
   - Groupe "Tous" : Accès REFUSÉ ❌ (explicite)

Résultat : Personne ne peut accéder au fichier confidentiel
```

### Diagnostic des permissions cumulées

```powershell
# Script pour analyser les permissions effectives
$path = "C:\Donnees\Document.docx"
$username = "DOMAINE\JDupont"

# Récupérer les groupes de l'utilisateur
$groups = ([System.Security.Principal.WindowsIdentity]::GetCurrent().Groups | 
    ForEach-Object { $_.Translate([System.Security.Principal.NTAccount]) }).Value

# Analyser l'ACL
$acl = Get-Acl $path
Write-Host "=== Permissions pour $username ===" -ForegroundColor Cyan

$acl.Access | ForEach-Object {
    $identity = $_.IdentityReference.Value
    if ($identity -eq $username -or $groups -contains $identity) {
        [PSCustomObject]@{
            Identité = $identity
            Type = $_.AccessControlType
            Droits = $_.FileSystemRights
            Hérité = $_.IsInherited
        }
    }
} | Format-Table -AutoSize
```

> [!tip] Astuce de dépannage Si un utilisateur n'a pas les accès attendus :
> 
> 1. Vérifier les REFUS (prioritaires)
> 2. Vérifier les groupes dont il est membre
> 3. Vérifier l'héritage depuis les parents
> 4. Utiliser "Accès effectif" pour confirmer

---

## ✅ Bonnes pratiques

### 🎯 Stratégie de gestion des permissions

#### 1. Utiliser les groupes, pas les utilisateurs

```
❌ MAUVAIS :
C:\Compta → JDupont : Modification
C:\Compta → MMartin : Modification
C:\Compta → PLeclerc : Modification

✅ BON :
C:\Compta → Groupe "G_Compta" : Modification
Groupe "G_Compta" contient : JDupont, MMartin, PLeclerc
```

> [!tip] Convention de nommage
> 
> - **G_** : Groupes globaux (domaine)
> - **L_** : Groupes locaux
> - **DL_** : Groupes de distribution
> 
> Exemple : `G_Finance_RW`, `G_RH_RO`

#### 2. Privilégier l'héritage

```
✅ Structure recommandée :
📁 C:\Donnees
   ├── 📁 Compta (permissions définies ici)
   │   ├── 📁 2024 (hérite)
   │   └── 📁 2025 (hérite)
   ├── 📁 RH (permissions définies ici)
   │   ├── 📁 Paie (hérite)
   │   └── 📁 Recrutement (hérite)
```

#### 3. Appliquer le principe du moindre privilège

```
✅ Donner le minimum nécessaire :
- Lecture seule par défaut
- Écriture uniquement si besoin
- Modification pour les responsables
- Contrôle total pour les administrateurs système
```

#### 4. Documenter les exceptions

```powershell
# Créer un rapport des permissions non héritées
Get-ChildItem "C:\Donnees" -Recurse -Directory | ForEach-Object {
    $acl = Get-Acl $_.FullName
    if ($acl.AreAccessRulesProtected) {
        [PSCustomObject]@{
            Dossier = $_.FullName
            HéritageBloqué = $true
            DateModification = $_.LastWriteTime
        }
    }
} | Export-Csv "C:\Rapports\Exceptions_Heritage.csv" -NoTypeInformation
```

### 🔍 Audit et surveillance

#### Activer l'audit des accès

```powershell
# Activer l'audit sur un dossier sensible
$acl = Get-Acl "C:\Donnees\Confidentiel"
$auditRule = New-Object System.Security.AccessControl.FileSystemAuditRule(
    "DOMAINE\Utilisateurs",
    "ReadData,WriteData,Delete",
    "ContainerInherit,ObjectInherit",
    "None",
    "Success,Failure"
)
$acl.AddAuditRule($auditRule)
Set-Acl "C:\Donnees\Confidentiel" $acl
```

#### Générer un rapport de permissions

```powershell
# Exporter toutes les permissions d'une arborescence
function Get-FolderPermissions {
    param([string]$Path)
    
    Get-ChildItem $Path -Recurse | ForEach-Object {
        $acl = Get-Acl $_.FullName
        $acl.Access | ForEach-Object {
            [PSCustomObject]@{
                Chemin = $acl.Path
                Identité = $_.IdentityReference
                Droits = $_.FileSystemRights
                Type = $_.AccessControlType
                Hérité = $_.IsInherited
            }
        }
    }
}

Get-FolderPermissions "C:\Donnees" | 
    Export-Csv "C:\Rapports\Permissions_Complete.csv" -NoTypeInformation
```

### 🛡️ Sécurisation avancée

#### Supprimer les permissions "Tout le monde"

```powershell
# Nettoyer les permissions trop permissives
$acl = Get-Acl "C:\Donnees"
$acl.Access | Where-Object {
    $_.IdentityReference -eq "Tout le monde" -or
    $_.IdentityReference -eq "Everyone"
} | ForEach-Object {
    $acl.RemoveAccessRule($_)
}
Set-Acl "C:\Donnees" $acl
```

#### Définir des permissions strictes

```powershell
# Template de permissions strictes
function Set-SecurePermissions {
    param(
        [string]$Path,
        [string]$AdminGroup = "DOMAINE\Admins",
        [string]$UserGroup = "DOMAINE\Utilisateurs"
    )
    
    # Désactiver l'héritage
    $acl = Get-Acl $Path
    $acl.SetAccessRuleProtection($true, $false)
    
    # Supprimer toutes les règles existantes
    $acl.Access | ForEach-Object { $acl.RemoveAccessRule($_) | Out-Null }
    
    # Ajouter Admins (Contrôle total)
    $rule1 = New-Object System.Security.AccessControl.FileSystemAccessRule(
        $AdminGroup, "FullControl", "ContainerInherit,ObjectInherit", "None", "Allow"
    )
    $acl.AddAccessRule($rule1)
    
    # Ajouter Utilisateurs (Lecture seule)
    $rule2 = New-Object System.Security.AccessControl.FileSystemAccessRule(
        $UserGroup, "ReadAndExecute", "ContainerInherit,ObjectInherit", "None", "Allow"
    )
    $acl.AddAccessRule($rule2)
    
    # Appliquer
    Set-Acl $Path $acl
}

# Utilisation
Set-SecurePermissions "C:\Donnees\Projets"
```

### ⚠️ Pièges à éviter

> [!warning] Erreurs fréquentes
> 
> ❌ **Permissions directes sur utilisateurs**
> 
> - Difficile à maintenir
> - Risque d'oublis
> - Pas de traçabilité
> 
> ❌ **Abus des refus explicites**
> 
> - Complexifie la gestion
> - Difficile à déboguer
> - Utiliser plutôt l'exclusion de groupes
> 
> ❌ **Trop d'exceptions d'héritage**
> 
> - Maintenance cauchemardesque
> - Incohérences fréquentes
> - Préférer une réorganisation des dossiers
> 
> ❌ **Ignorer les permissions effectives**
> 
> - Surprises lors de tests
> - Problèmes d'accès inexpliqués
> - Toujours vérifier le résultat final

### 📝 Checklist de sécurité NTFS

- [ ] Permissions définies par groupes uniquement
- [ ] Héritage activé sauf exception documentée
- [ ] Principe du moindre privilège appliqué
- [ ] Aucune permission "Tout le monde" sur données sensibles
- [ ] Audit activé sur les ressources critiques
- [ ] Propriétaires définis correctement
- [ ] Permissions effectives vérifiées pour les utilisateurs clés
- [ ] Documentation des exceptions d'héritage
- [ ] Rapport de permissions généré régulièrement
- [ ] Tests de restauration effectués

---

## 🎓 Récapitulatif

> [!info] Points clés à retenir
> 
> **Les permissions NTFS** constituent la base de la sécurité Windows :
> 
> - **6 permissions de base** : de Lecture à Contrôle total
> - **13+ permissions avancées** : pour un contrôle granulaire
> - **L'héritage** simplifie la gestion et maintient la cohérence
> - **Le propriétaire** garde toujours le contrôle de ses fichiers
> - **Les permissions effectives** = calcul final de tous les droits
> - **Les REFUS** l'emportent toujours sur les autorisations
> - **Les groupes** doivent être privilégiés pour la gestion

### Commandes essentielles à maîtriser

```powershell
# Consulter les permissions
icacls "C:\Chemin"
Get-Acl "C:\Chemin" | Format-List

# Définir des permissions
icacls "C:\Chemin" /grant "DOMAINE\Groupe:(OI)(CI)M"
$acl = Get-Acl "C:\Chemin"
# ... modifications ...
Set-Acl "C:\Chemin" $acl

# Gérer l'héritage
icacls "C:\Chemin" /inheritance:d  # Désactiver
icacls "C:\Chemin" /inheritance:e  # Activer

# Prendre possession
takeown /F "C:\Chemin" /R
icacls "C:\Chemin" /setowner "DOMAINE\Admin" /T

# Voir les permissions effectives
# Interface graphique : Propriétés > Sécurité > Avancé > Accès effectif
```

---

**Navigation** : ⬅️ [Gestion des disques](https://claude.ai/chat/02-gestion-disques.md) | ➡️ [Partages réseau](https://claude.ai/chat/04-partages-reseau.md)