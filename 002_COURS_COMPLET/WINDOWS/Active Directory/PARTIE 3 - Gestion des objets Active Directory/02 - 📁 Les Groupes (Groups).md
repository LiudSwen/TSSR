

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

## 🎯 Introduction aux groupes

Les **groupes Active Directory** sont des objets conteneurs qui permettent de regrouper des utilisateurs, ordinateurs et autres groupes pour faciliter l'administration. Ils constituent un pilier fondamental de la gestion des permissions et de la sécurité dans AD.

> [!info] Pourquoi utiliser des groupes ?
> 
> - **Simplification** : Attribuer des permissions à un groupe plutôt qu'individuellement
> - **Évolutivité** : Ajouter/retirer des membres sans modifier les permissions
> - **Traçabilité** : Comprendre facilement qui a accès à quoi
> - **Conformité** : Faciliter les audits de sécurité

---

## 🏷️ Types de groupes

Active Directory propose deux types de groupes distincts, chacun avec un objectif précis.

### 🔒 Groupes de sécurité (Security Groups)

Les groupes de sécurité sont utilisés pour **attribuer des permissions** et des droits d'accès aux ressources.

> [!example] Cas d'usage
> 
> - Donner accès à un dossier partagé
> - Attribuer des droits d'administration
> - Contrôler l'accès à des applications
> - Appliquer des GPO (Group Policy Objects)

**Caractéristiques :**

- Possèdent un **SID** (Security Identifier)
- Peuvent être utilisés dans les **ACL** (Access Control Lists)
- Peuvent recevoir des **permissions NTFS**
- **Peuvent aussi servir de liste de distribution** (double fonction)

### 📧 Groupes de distribution (Distribution Groups)

Les groupes de distribution sont utilisés uniquement pour **créer des listes de diffusion email**.

> [!example] Cas d'usage
> 
> - Listes de diffusion département (comptabilite@entreprise.com)
> - Newsletters internes
> - Groupes de projet pour communication

**Caractéristiques :**

- **Pas de SID** (Security Identifier)
- **Ne peuvent PAS** être utilisés pour les permissions
- Utilisés principalement avec **Exchange Server** ou **Microsoft 365**
- Plus légers en termes de traitement AD

### 📊 Comparaison des types

|Critère|Groupe de sécurité|Groupe de distribution|
|---|---|---|
|**Attribution de permissions**|✅ Oui|❌ Non|
|**Liste de diffusion email**|✅ Oui|✅ Oui|
|**Possède un SID**|✅ Oui|❌ Non|
|**Utilisable dans ACL**|✅ Oui|❌ Non|
|**Application de GPO**|✅ Oui|❌ Non|

> [!tip] Bonne pratique Utilisez **toujours des groupes de sécurité** par défaut, même pour les listes de diffusion. Ils offrent plus de flexibilité et peuvent servir les deux objectifs. Ne créez un groupe de distribution que si vous êtes certain qu'il ne servira jamais à des permissions.

### 🔄 Conversion entre types

Vous pouvez convertir un groupe d'un type à l'autre :

**Via l'interface graphique :**

1. Ouvrir les propriétés du groupe dans "Utilisateurs et ordinateurs Active Directory"
2. Onglet "Général"
3. Modifier le "Type de groupe"

**Via PowerShell :**

```powershell
# Convertir en groupe de sécurité
Set-ADGroup -Identity "NomDuGroupe" -GroupCategory Security

# Convertir en groupe de distribution
Set-ADGroup -Identity "NomDuGroupe" -GroupCategory Distribution
```

> [!warning] Attention lors de la conversion
> 
> - **Distribution → Sécurité** : Un nouveau SID sera généré
> - **Sécurité → Distribution** : Toutes les permissions seront perdues
> - Les membres du groupe restent inchangés

---

## 🌍 Étendues de groupes

L'**étendue** (scope) d'un groupe définit où le groupe peut être utilisé et quels membres il peut contenir. C'est un concept crucial pour la conception d'une architecture AD multi-domaines.

### 📍 Groupe local de domaine (Domain Local)

**Visibilité** : Utilisable uniquement dans **son propre domaine**

**Peut contenir** :

- Comptes utilisateurs de **n'importe quel domaine** de la forêt
- Groupes globaux de **n'importe quel domaine** de la forêt
- Groupes universels de **n'importe quel domaine** de la forêt
- Autres groupes locaux du **même domaine**

**Peut être utilisé pour** :

- Attribuer des permissions sur des ressources **locales au domaine**
- ACL sur des fichiers, dossiers, imprimantes du domaine

> [!example] Exemple d'utilisation Un groupe "Comptabilite_Acces_Fichiers_DL" dans le domaine `paris.entreprise.com` donne accès à un dossier partagé situé sur un serveur de ce domaine. Ce groupe peut contenir des utilisateurs de tous les domaines de la forêt.

**Convertibilité** :

- ✅ Peut être converti en Universel (si n'est membre d'aucun autre groupe local)

### 🌐 Groupe global (Global)

**Visibilité** : Utilisable dans **tous les domaines** de la forêt et dans les domaines approuvés

**Peut contenir** :

- Comptes utilisateurs **du même domaine uniquement**
- Autres groupes globaux **du même domaine uniquement**

**Peut être utilisé pour** :

- Attribuer des permissions dans **n'importe quel domaine** de la forêt
- Être membre de groupes locaux ou universels

> [!example] Exemple d'utilisation Un groupe "Comptables_Global" dans le domaine `paris.entreprise.com` contient tous les comptables de Paris. Ce groupe peut être ajouté à des groupes locaux dans les domaines de New York ou Londres pour donner accès à des ressources.

**Convertibilité** :

- ✅ Peut être converti en Universel (si n'est membre d'aucun autre groupe global)

### ⭐ Groupe universel (Universal)

**Visibilité** : Utilisable dans **tous les domaines** de la forêt

**Peut contenir** :

- Comptes utilisateurs de **n'importe quel domaine** de la forêt
- Groupes globaux de **n'importe quel domaine** de la forêt
- Autres groupes universels de **n'importe quel domaine** de la forêt

**Peut être utilisé pour** :

- Attribuer des permissions dans **tous les domaines** de la forêt
- Consolidation de groupes globaux de différents domaines

> [!example] Exemple d'utilisation Un groupe "Tous_Comptables_Universal" consolide les groupes globaux "Comptables_Paris", "Comptables_NewYork" et "Comptables_Londres". Ce groupe universel peut ensuite être utilisé pour donner accès à une application globale d'entreprise.

> [!warning] Impact sur la réplication Les groupes universels et leurs **membres** sont répliqués dans le **Catalogue Global** (Global Catalog). Toute modification de l'appartenance déclenche une réplication sur tous les serveurs de catalogue global de la forêt.
> 
> **Conséquence** : Évitez d'ajouter directement des utilisateurs dans des groupes universels dans de grandes infrastructures. Utilisez plutôt la stratégie AGDLP.

**Convertibilité** :

- ✅ Peut être converti en Local ou Global

### 📊 Tableau comparatif des étendues

|Caractéristique|Domain Local|Global|Universal|
|---|---|---|---|
|**Où utilisable**|Domaine local uniquement|Toute la forêt|Toute la forêt|
|**Membres : Utilisateurs**|Tous domaines|Même domaine|Tous domaines|
|**Membres : Groupes Global**|Tous domaines|Même domaine|Tous domaines|
|**Membres : Groupes Universal**|Oui|Non|Oui|
|**Membres : Groupes Local**|Même domaine|Non|Non|
|**Réplication**|Locale au domaine|Locale au domaine|Catalogue Global|
|**Cas d'usage principal**|Permissions locales|Regroupement d'utilisateurs|Consolidation inter-domaines|

### 🔄 Règles de conversion d'étendue

```
Domain Local ←→ Universal ←→ Global
```

**Conditions pour convertir** :

```powershell
# Domain Local → Universal
# Condition : Le groupe ne doit être membre d'aucun autre groupe Domain Local
Set-ADGroup -Identity "GroupeDL" -GroupScope Universal

# Universal → Global
# Condition : Le groupe ne doit contenir aucun autre groupe Universal
Set-ADGroup -Identity "GroupeU" -GroupScope Global

# Global → Universal
# Condition : Le groupe ne doit être membre d'aucun autre groupe Global
Set-ADGroup -Identity "GroupeG" -GroupScope Universal

# Universal → Domain Local
# Toujours possible
Set-ADGroup -Identity "GroupeU" -GroupScope DomainLocal
```

> [!tip] Choix de l'étendue
> 
> - **Domain Local** : Pour donner des accès à des ressources locales
> - **Global** : Pour regrouper des utilisateurs d'un même domaine
> - **Universal** : Pour consolider des groupes de différents domaines (avec modération)

---

## 👥 Gestion des appartenances

La gestion des appartenances aux groupes est une tâche quotidienne pour les administrateurs AD. Voici les différentes méthodes et bonnes pratiques.

### 🖥️ Via l'interface graphique (ADUC)

**Active Directory Users and Computers (ADUC)** est l'outil classique :

1. **Ajouter un membre à un groupe** :
    
    - Clic droit sur le groupe → Propriétés → Onglet "Membres" → Ajouter
2. **Voir les groupes d'un utilisateur** :
    
    - Clic droit sur l'utilisateur → Propriétés → Onglet "Membre de"

> [!info] Groupe principal (Primary Group) Chaque utilisateur a un "groupe principal" (par défaut "Utilisateurs du domaine"). Ce groupe n'apparaît pas dans l'onglet "Membre de" mais est défini dans l'onglet "Compte".

### 💻 Via PowerShell

PowerShell offre plus de flexibilité et permet l'automatisation.

#### Ajouter un membre à un groupe

```powershell
# Ajouter un utilisateur unique
Add-ADGroupMember -Identity "Groupe_Comptabilite" -Members "jdupont"

# Ajouter plusieurs utilisateurs
Add-ADGroupMember -Identity "Groupe_RH" -Members "jdupont", "mmartin", "pdurand"

# Ajouter un groupe à un autre groupe
Add-ADGroupMember -Identity "Groupe_Admins_Local" -Members "Groupe_Admins_Global"

# Ajouter tous les utilisateurs d'une OU
Get-ADUser -Filter * -SearchBase "OU=Comptabilite,DC=entreprise,DC=com" | 
    ForEach-Object { Add-ADGroupMember -Identity "Groupe_Comptabilite" -Members $_ }
```

#### Retirer un membre d'un groupe

```powershell
# Retirer un utilisateur
Remove-ADGroupMember -Identity "Groupe_Comptabilite" -Members "jdupont" -Confirm:$false

# Retirer plusieurs utilisateurs
Remove-ADGroupMember -Identity "Groupe_RH" -Members "jdupont", "mmartin" -Confirm:$false

# Vider complètement un groupe
Get-ADGroupMember -Identity "Groupe_Temporaire" | 
    ForEach-Object { Remove-ADGroupMember -Identity "Groupe_Temporaire" -Members $_ -Confirm:$false }
```

#### Lister les membres d'un groupe

```powershell
# Membres directs uniquement
Get-ADGroupMember -Identity "Groupe_Comptabilite"

# Membres directs avec détails
Get-ADGroupMember -Identity "Groupe_Comptabilite" | 
    Select-Object Name, SamAccountName, objectClass

# Tous les membres (récursif, incluant les sous-groupes)
Get-ADGroupMember -Identity "Groupe_Admins" -Recursive

# Compter les membres
(Get-ADGroupMember -Identity "Groupe_Comptabilite").Count

# Exporter vers CSV
Get-ADGroupMember -Identity "Groupe_RH" | 
    Select-Object Name, SamAccountName, distinguishedName | 
    Export-Csv -Path "C:\Membres_RH.csv" -NoTypeInformation
```

#### Lister les groupes d'un utilisateur

```powershell
# Groupes directs
Get-ADUser -Identity "jdupont" -Properties MemberOf | 
    Select-Object -ExpandProperty MemberOf

# Groupes formatés proprement
Get-ADUser -Identity "jdupont" -Properties MemberOf | 
    Select-Object -ExpandProperty MemberOf | 
    ForEach-Object { (Get-ADGroup $_).Name }

# Tous les groupes (récursif, via token)
Get-ADUser -Identity "jdupont" -Properties TokenGroups | 
    Select-Object -ExpandProperty TokenGroups | 
    ForEach-Object { (Get-ADGroup -Identity $_).Name }
```

#### Vérifier l'appartenance

```powershell
# Vérifier si un utilisateur est membre d'un groupe
$user = "jdupont"
$group = "Groupe_Admins"
$members = Get-ADGroupMember -Identity $group -Recursive | Select-Object -ExpandProperty SamAccountName

if ($members -contains $user) {
    Write-Host "L'utilisateur $user est membre de $group"
} else {
    Write-Host "L'utilisateur $user N'EST PAS membre de $group"
}
```

### 🔄 Gestion en masse

```powershell
# Ajouter tous les utilisateurs d'un CSV à un groupe
$users = Import-Csv -Path "C:\nouveaux_membres.csv"
foreach ($user in $users) {
    Add-ADGroupMember -Identity "Groupe_Projet" -Members $user.SamAccountName
    Write-Host "Ajout de $($user.SamAccountName)"
}

# Copier les membres d'un groupe vers un autre
$membres = Get-ADGroupMember -Identity "Groupe_Source"
Add-ADGroupMember -Identity "Groupe_Destination" -Members $membres

# Synchroniser deux groupes (rendre identiques)
$source = Get-ADGroupMember -Identity "Groupe_Reference"
$destination = Get-ADGroupMember -Identity "Groupe_Copie"

# Retirer les membres qui ne sont pas dans la source
$destination | Where-Object { $_.SamAccountName -notin $source.SamAccountName } | 
    ForEach-Object { Remove-ADGroupMember -Identity "Groupe_Copie" -Members $_ -Confirm:$false }

# Ajouter les membres manquants
$source | Where-Object { $_.SamAccountName -notin $destination.SamAccountName } | 
    ForEach-Object { Add-ADGroupMember -Identity "Groupe_Copie" -Members $_ }
```

### 📋 Création et gestion de groupes

```powershell
# Créer un groupe de sécurité global
New-ADGroup -Name "Groupe_Developpeurs" `
            -GroupCategory Security `
            -GroupScope Global `
            -Path "OU=Groupes,DC=entreprise,DC=com" `
            -Description "Équipe de développement"

# Créer un groupe local de domaine
New-ADGroup -Name "Acces_Serveur_Fichiers_DL" `
            -GroupCategory Security `
            -GroupScope DomainLocal `
            -Path "OU=Groupes_Ressources,DC=entreprise,DC=com"

# Modifier les propriétés d'un groupe
Set-ADGroup -Identity "Groupe_Developpeurs" `
            -Description "Nouvelle description" `
            -ManagedBy "chef_projet"

# Changer l'étendue d'un groupe
Set-ADGroup -Identity "Groupe_Test" -GroupScope Universal

# Supprimer un groupe
Remove-ADGroup -Identity "Groupe_Obsolete" -Confirm:$false
```

> [!warning] Suppressions de groupes
> 
> - La suppression d'un groupe est **irréversible** (le SID est perdu)
> - Toutes les **permissions ACL** utilisant ce groupe deviennent orphelines
> - Vérifiez les dépendances avant de supprimer
> - Pensez à désactiver plutôt que supprimer pour tester l'impact

### 🔍 Auditer les appartenances

```powershell
# Trouver tous les groupes vides
Get-ADGroup -Filter * -Properties Members | 
    Where-Object { -not $_.Members } | 
    Select-Object Name, DistinguishedName

# Trouver les groupes avec plus de X membres
Get-ADGroup -Filter * -Properties Members | 
    Where-Object { $_.Members.Count -gt 100 } | 
    Select-Object Name, @{Name="MembresCount";Expression={$_.Members.Count}} | 
    Sort-Object MembresCount -Descending

# Trouver les utilisateurs membres de plus de X groupes
Get-ADUser -Filter * -Properties MemberOf | 
    Where-Object { $_.MemberOf.Count -gt 20 } | 
    Select-Object Name, @{Name="GroupesCount";Expression={$_.MemberOf.Count}} | 
    Sort-Object GroupesCount -Descending

# Lister tous les groupes avec leurs membres
Get-ADGroup -Filter * | ForEach-Object {
    [PSCustomObject]@{
        GroupName = $_.Name
        Members = (Get-ADGroupMember -Identity $_ | Select-Object -ExpandProperty Name) -join "; "
        MemberCount = (Get-ADGroupMember -Identity $_).Count
    }
} | Export-Csv -Path "C:\Groupes_Et_Membres.csv" -NoTypeInformation
```

> [!tip] Bonnes pratiques de gestion
> 
> - **Nommez clairement** vos groupes (préfixes selon le type/étendue)
> - **Documentez** la description de chaque groupe
> - **Définissez un propriétaire** (attribut ManagedBy)
> - **Auditez régulièrement** les appartenances
> - **Automatisez** les ajouts/retraits via scripts pour les processus récurrents
> - **Nettoyez** régulièrement les groupes obsolètes ou vides

---

## 🎯 Stratégie AGDLP

La stratégie **AGDLP** (ou **AGUDLP** en incluant Universal) est une **méthodologie de conception** pour l'attribution de permissions dans Active Directory. C'est une best practice Microsoft pour les environnements multi-domaines.

### 📖 Signification de l'acronyme

**A-G-DL-P** ou **A-G-U-DL-P**

- **A** : **Accounts** (Comptes utilisateurs)
- **G** : **Global groups** (Groupes globaux)
- **U** : **Universal groups** (Groupes universels) - optionnel
- **DL** : **Domain Local groups** (Groupes locaux de domaine)
- **P** : **Permissions** (Permissions sur les ressources)

> [!info] Principe fondamental **Les utilisateurs ne reçoivent JAMAIS de permissions directement**. On utilise toujours une chaîne de groupes pour séparer l'identité (qui sont les utilisateurs) de l'accès (ce qu'ils peuvent faire).

### 🔄 Le flux AGDLP

```
Utilisateurs → Groupes Globaux → Groupes Universels → Groupes Locaux → Permissions
   (A)              (G)                  (U)               (DL)           (P)
```

**Détaillons chaque étape** :

1. **Comptes (A)** : Les utilisateurs individuels
2. **Groupes Globaux (G)** : Regroupent les utilisateurs par **fonction/rôle** dans leur domaine
3. **Groupes Universels (U)** : Consolident les groupes globaux de **différents domaines** (optionnel)
4. **Groupes Locaux (DL)** : Représentent les **droits d'accès aux ressources**
5. **Permissions (P)** : Attribuées aux groupes locaux sur les ressources

### 🏢 Exemple concret (sans Universal)

**Contexte** : Vous avez un serveur de fichiers avec un dossier "Comptabilité" à Paris.

**Mauvaise approche** (à éviter) :

```
❌ Utilisateur "jdupont" → Permission sur "\\SRVFILES\Comptabilite"
❌ Utilisateur "mmartin" → Permission sur "\\SRVFILES\Comptabilite"
❌ Utilisateur "pdurand" → Permission sur "\\SRVFILES\Comptabilite"
```

**Bonne approche AGDLP** :

```
✅ Utilisateurs (A)
   ├─ jdupont
   ├─ mmartin
   └─ pdurand
         ↓ Ajoutés dans
✅ Groupe Global (G) : "Comptables_Global"
   [Étendue : Global, Domaine : paris.entreprise.com]
         ↓ Ajouté dans
✅ Groupe Local (DL) : "Comptabilite_Acces_DL"
   [Étendue : Domain Local, Domaine : paris.entreprise.com]
         ↓ Reçoit la
✅ Permission (P) : Lecture/Écriture sur "\\SRVFILES\Comptabilite"
```

**Implémentation PowerShell** :

```powershell
# 1. Créer le groupe global pour les comptables
New-ADGroup -Name "Comptables_Global" `
            -GroupCategory Security `
            -GroupScope Global `
            -Path "OU=Roles,DC=paris,DC=entreprise,DC=com" `
            -Description "Tous les comptables du domaine Paris"

# 2. Ajouter les utilisateurs dans le groupe global
Add-ADGroupMember -Identity "Comptables_Global" `
                  -Members "jdupont", "mmartin", "pdurand"

# 3. Créer le groupe local pour l'accès à la ressource
New-ADGroup -Name "Comptabilite_Acces_DL" `
            -GroupCategory Security `
            -GroupScope DomainLocal `
            -Path "OU=Ressources,DC=paris,DC=entreprise,DC=com" `
            -Description "Accès au dossier Comptabilite sur SRVFILES"

# 4. Ajouter le groupe global dans le groupe local
Add-ADGroupMember -Identity "Comptabilite_Acces_DL" `
                  -Members "Comptables_Global"

# 5. Attribuer les permissions NTFS (via icacls ou l'interface)
# icacls "\\SRVFILES\Comptabilite" /grant "PARIS\Comptabilite_Acces_DL:(OI)(CI)M"
```

### 🌍 Exemple avec Universal (AGUDLP)

**Contexte** : Vous avez des comptables dans trois domaines (Paris, New York, Londres) et une application comptable globale.

```
✅ Utilisateurs (A) - Domaine Paris
   ├─ jdupont
   └─ mmartin
         ↓ Ajoutés dans
✅ Groupe Global (G) : "Comptables_Paris_Global"
   [Étendue : Global, Domaine : paris.entreprise.com]

✅ Utilisateurs (A) - Domaine New York
   ├─ jsmith
   └─ bjones
         ↓ Ajoutés dans
✅ Groupe Global (G) : "Comptables_NewYork_Global"
   [Étendue : Global, Domaine : newyork.entreprise.com]

✅ Utilisateurs (A) - Domaine Londres
   ├─ amiller
   └─ cdavis
         ↓ Ajoutés dans
✅ Groupe Global (G) : "Comptables_Londres_Global"
   [Étendue : Global, Domaine : london.entreprise.com]

         ↓ Tous ajoutés dans
✅ Groupe Universal (U) : "Tous_Comptables_Universal"
   [Étendue : Universal, Domaine : root.entreprise.com]
         ↓ Ajouté dans
✅ Groupe Local (DL) : "AppCompta_Acces_DL"
   [Étendue : Domain Local, Domaine : paris.entreprise.com]
         ↓ Reçoit la
✅ Permission (P) : Accès à l'application comptable
```

**Implémentation PowerShell** :

```powershell
# Dans le domaine Paris
New-ADGroup -Name "Comptables_Paris_Global" -GroupScope Global -GroupCategory Security
Add-ADGroupMember -Identity "Comptables_Paris_Global" -Members "jdupont", "mmartin"

# Dans le domaine New York
New-ADGroup -Name "Comptables_NewYork_Global" -GroupScope Global -GroupCategory Security
Add-ADGroupMember -Identity "Comptables_NewYork_Global" -Members "jsmith", "bjones"

# Dans le domaine Londres
New-ADGroup -Name "Comptables_Londres_Global" -GroupScope Global -GroupCategory Security
Add-ADGroupMember -Identity "Comptables_Londres_Global" -Members "amiller", "cdavis"

# Créer le groupe universal (domaine root)
New-ADGroup -Name "Tous_Comptables_Universal" -GroupScope Universal -GroupCategory Security
Add-ADGroupMember -Identity "Tous_Comptables_Universal" `
                  -Members "Comptables_Paris_Global", "Comptables_NewYork_Global", "Comptables_Londres_Global"

# Créer le groupe local pour l'accès
New-ADGroup -Name "AppCompta_Acces_DL" -GroupScope DomainLocal -GroupCategory Security
Add-ADGroupMember -Identity "AppCompta_Acces_DL" -Members "Tous_Comptables_Universal"

# Attribuer les permissions à AppCompta_Acces_DL
```

### ✅ Avantages de la stratégie AGDLP

|Avantage|Explication|
|---|---|
|**Séparation des rôles et des ressources**|Les groupes globaux représentent "qui" (rôles), les groupes locaux représentent "quoi" (accès)|
|**Facilité de gestion**|Pour changer l'accès d'un utilisateur, on modifie juste son groupe global|
|**Réutilisabilité**|Un groupe global peut être membre de plusieurs groupes locaux|
|**Évolutivité**|Facile d'ajouter de nouveaux domaines ou de nouvelles ressources|
|**Réplication optimisée**|Les groupes globaux ne se répliquent que localement (pas dans le GC)|
|**Clarté**|Nomenclature claire : rôles vs accès|
|**Multi-domaines**|Fonctionne parfaitement dans des forêts complexes|

### 🚫 Pièges à éviter

> [!warning] Erreurs courantes
> 
> **❌ Attribution directe aux utilisateurs**
> 
> ```
> Utilisateur → Permission
> ```
> 
> Devient ingérable avec des centaines d'utilisateurs.
> 
> **❌ Utiliser uniquement des groupes globaux**
> 
> ```
> Utilisateur → Groupe Global → Permission
> ```
> 
> Fonctionne mais perd la séparation rôle/ressource.
> 
> **❌ Utiliser uniquement des groupes locaux**
> 
> ```
> Utilisateur → Groupe Local → Permission
> ```
> 
> Ne fonctionne pas en multi-domaines (groupe local = domaine local uniquement).
> 
> **❌ Abuser des groupes universels**
> 
> ```
> Utilisateur → Groupe Universal → Permission
> ```
> 
> Provoque une réplication excessive dans le Catalogue Global.

### 📝 Convention de nommage recommandée

Une bonne nomenclature facilite l'identification :

```
[Fonction/Rôle]_[Localisation]_[Étendue]
```

**Exemples** :

```powershell
# Groupes Globaux (rôles/fonctions)
"Comptables_Paris_G"
"Developpeurs_NewYork_G"
"Managers_Londres_G"

# Groupes Universels (consolidation)
"Tous_Comptables_U"
"Tous_IT_U"

# Groupes Locaux (accès aux ressources)
"Comptabilite_Lecture_DL"
"Comptabilite_Ecriture_DL"
"ServeurFichiers_Admin_DL"
"ApplicationCRM_Utilisateur_DL"
```

**Suffixes** :

- `_G` : Global
- `_U` : Universal
- `_DL` : Domain Local

> [!tip] Alternative : Préfixes Certaines organisations préfèrent les préfixes :
> 
> - `G_Comptables_Paris`
> - `U_Tous_Comptables`
> - `DL_Comptabilite_Acces`

### 🧩 AGDLP dans différents scénarios

#### Scénario 1 : Domaine unique

Dans un domaine unique, le **U** (Universal) n'est pas nécessaire. Utilisez **AGDLP** simplifié (sans Universal).

```
Utilisateurs → Groupe Global → Groupe Local → Permission
```

**Exemple** :

```powershell
# Groupe des développeurs (rôle)
New-ADGroup "Developpeurs_G" -GroupScope Global
Add-ADGroupMember "Developpeurs_G" -Members "user1", "user2"

# Groupe d'accès au dépôt Git (ressource)
New-ADGroup "Git_Acces_DL" -GroupScope DomainLocal
Add-ADGroupMember "Git_Acces_DL" -Members "Developpeurs_G"

# Permission attribuée à Git_Acces_DL
```

#### Scénario 2 : Forêt multi-domaines

Dans une forêt avec plusieurs domaines, utilisez **AGUDLP** complet.

```
Utilisateurs (domaine A) → Groupe Global (domaine A) ┐
Utilisateurs (domaine B) → Groupe Global (domaine B) ├→ Groupe Universal → Groupe Local → Permission
Utilisateurs (domaine C) → Groupe Global (domaine C) ┘
```

**Exemple** :

```powershell
# Domaine paris.entreprise.com
New-ADGroup "RH_Paris_G" -GroupScope Global
Add-ADGroupMember "RH_Paris_G" -Members "user_paris1", "user_paris2"

# Domaine newyork.entreprise.com
New-ADGroup "RH_NewYork_G" -GroupScope Global
Add-ADGroupMember "RH_NewYork_G" -Members "user_ny1", "user_ny2"

# Domaine root.entreprise.com
New-ADGroup "Tous_RH_U" -GroupScope Universal
Add-ADGroupMember "Tous_RH_U" -Members "RH_Paris_G", "RH_NewYork_G"

# Groupe local pour l'application RH
New-ADGroup "AppRH_Acces_DL" -GroupScope DomainLocal
Add-ADGroupMember "AppRH_Acces_DL" -Members "Tous_RH_U"
```

#### Scénario 3 : Permissions multiples pour un même rôle

Un groupe de rôle (Global) peut être membre de plusieurs groupes de ressources (Local).

```
                    ┌→ Groupe Local 1 → Permission sur Serveur A
Groupe Global (RH) ─┼→ Groupe Local 2 → Permission sur Application B
                    └→ Groupe Local 3 → Permission sur Dossier C
```

**Exemple** :

```powershell
# Un seul groupe global
New-ADGroup "RH_G" -GroupScope Global
Add-ADGroupMember "RH_G" -Members "user1", "user2", "user3"

# Plusieurs groupes locaux pour différentes ressources
New-ADGroup "ServeurRH_Admin_DL" -GroupScope DomainLocal
New-ADGroup "DossierRH_Lecture_DL" -GroupScope DomainLocal
New-ADGroup "ApplicationPaie_Utilisateur_DL" -GroupScope DomainLocal

# Le groupe global est ajouté aux trois groupes locaux
Add-ADGroupMember "ServeurRH_Admin_DL" -Members "RH_G"
Add-ADGroupMember "DossierRH_Lecture_DL" -Members "RH_G"
Add-ADGroupMember "ApplicationPaie_Utilisateur_DL" -Members "RH_G"
```

#### Scénario 4 : Permissions combinées

Un groupe local (ressource) peut contenir plusieurs groupes globaux (rôles).

```
Groupe Global (Comptables) ┐
Groupe Global (Auditeurs)  ├→ Groupe Local → Permission sur Documents Financiers
Groupe Global (Managers)   ┘
```

**Exemple** :

```powershell
# Plusieurs groupes de rôles
New-ADGroup "Comptables_G" -GroupScope Global
New-ADGroup "Auditeurs_G" -GroupScope Global
New-ADGroup "Managers_G" -GroupScope Global

# Un seul groupe local pour la ressource
New-ADGroup "DocsFinanciers_Lecture_DL" -GroupScope DomainLocal

# Tous les groupes globaux sont ajoutés au groupe local
Add-ADGroupMember "DocsFinanciers_Lecture_DL" -Members "Comptables_G", "Auditeurs_G", "Managers_G"
```

### 🔍 Vérification de l'implémentation AGDLP

```powershell
# Vérifier la structure d'un groupe local (doit contenir des groupes globaux/universels)
$groupeLocal = "AppCompta_Acces_DL"
$membres = Get-ADGroupMember -Identity $groupeLocal

Write-Host "=== Analyse du groupe local $groupeLocal ===" -ForegroundColor Cyan
foreach ($membre in $membres) {
    $details = Get-ADGroup -Identity $membre
    $etendue = $details.GroupScope
    
    if ($etendue -eq "Global" -or $etendue -eq "Universal") {
        Write-Host "[OK] $($membre.Name) - Étendue: $etendue" -ForegroundColor Green
    } else {
        Write-Host "[ATTENTION] $($membre.Name) - Étendue: $etendue (devrait être Global ou Universal)" -ForegroundColor Yellow
    }
}

# Vérifier si des utilisateurs sont directement dans le groupe local (mauvaise pratique)
$utilisateursDirects = $membres | Where-Object { $_.objectClass -eq "user" }
if ($utilisateursDirects) {
    Write-Host "
[AVERTISSEMENT] Des utilisateurs sont directement membres du groupe local:" -ForegroundColor Red
    $utilisateursDirects | ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor Red }
    Write-Host "Recommandation: Déplacez-les dans un groupe global" -ForegroundColor Yellow
}
```

### 📊 Tableau récapitulatif AGDLP

|Étape|Type de groupe|Contenu|Objectif|Exemple|
|---|---|---|---|---|
|**A**|-|Comptes utilisateurs|Représente les individus|jdupont, mmartin|
|**G**|Global|Utilisateurs du même domaine|Regrouper par rôle/fonction|Comptables_Paris_G|
|**U**|Universal|Groupes globaux de différents domaines|Consolider inter-domaines|Tous_Comptables_U|
|**DL**|Domain Local|Groupes globaux/universels|Représenter l'accès à une ressource|Compta_Acces_DL|
|**P**|-|ACL/Permissions|Sécuriser la ressource|Lecture/Écriture sur dossier|

### 🎓 Résumé de la stratégie AGDLP

> [!tip] Mémo AGDLP **Pensez "Identité → Consolidation → Accès → Permission"**
> 
> - **Groupes Globaux** = **QUI** sont les utilisateurs (identité, rôle)
> - **Groupes Universels** = Consolidation multi-domaines (optionnel)
> - **Groupes Locaux** = **QUOI** peuvent-ils faire (accès aux ressources)
> - **Permissions** = Comment ils peuvent le faire (lecture, écriture, etc.)

> [!example] Règle d'or **"Ne jamais attribuer de permissions directement aux utilisateurs ou aux groupes globaux"**
> 
> Toujours passer par un groupe local de domaine pour les permissions sur les ressources.

### 🛠️ Outils de diagnostic

```powershell
# Script pour auditer la conformité AGDLP dans votre AD
function Test-AGDLPCompliance {
    param(
        [string]$SearchBase = (Get-ADDomain).DistinguishedName
    )
    
    Write-Host "=== Audit de conformité AGDLP ===" -ForegroundColor Cyan
    
    # Trouver tous les groupes locaux
    $groupesLocaux = Get-ADGroup -Filter {GroupScope -eq "DomainLocal"} -SearchBase $SearchBase
    
    $nonConformes = @()
    
    foreach ($groupe in $groupesLocaux) {
        $membres = Get-ADGroupMember -Identity $groupe
        $utilisateursDirects = $membres | Where-Object { $_.objectClass -eq "user" }
        
        if ($utilisateursDirects) {
            $nonConformes += [PSCustomObject]@{
                Groupe = $groupe.Name
                UtilisateursDirects = ($utilisateursDirects | Select-Object -ExpandProperty Name) -join ", "
                Nombre = $utilisateursDirects.Count
            }
        }
    }
    
    if ($nonConformes) {
        Write-Host "
[ATTENTION] $($nonConformes.Count) groupe(s) local(aux) avec des utilisateurs directs:" -ForegroundColor Yellow
        $nonConformes | Format-Table -AutoSize
        Write-Host "
Recommandation: Créez des groupes globaux pour ces utilisateurs" -ForegroundColor Cyan
    } else {
        Write-Host "
[OK] Tous les groupes locaux respectent AGDLP" -ForegroundColor Green
    }
}

# Exécuter l'audit
Test-AGDLPCompliance
```

---

## 🎯 Pièges courants et bonnes pratiques

### ❌ Erreurs fréquentes

> [!warning] Piège #1 : Utilisateurs directement dans les groupes locaux **Symptôme** : Utilisateurs ajoutés directement dans les groupes Domain Local
> 
> **Problème** : Perd tous les avantages d'AGDLP, difficile à gérer
> 
> **Solution** : Toujours créer un groupe Global intermédiaire

> [!warning] Piège #2 : Confusion entre type et étendue **Symptôme** : Utiliser des groupes de distribution pour les permissions
> 
> **Problème** : Les groupes de distribution n'ont pas de SID, ils ne peuvent pas recevoir de permissions
> 
> **Solution** : Toujours utiliser des groupes de sécurité pour les permissions

> [!warning] Piège #3 : Groupes universels surchargés **Symptôme** : Ajouter directement des centaines d'utilisateurs dans un groupe universel
> 
> **Problème** : Chaque changement réplique dans tout le Catalogue Global
> 
> **Solution** : Mettre les utilisateurs dans des groupes globaux, puis ces groupes dans l'universel

> [!warning] Piège #4 : Noms de groupes peu clairs **Symptôme** : Groupes nommés "Groupe1", "Accès", "Team"
> 
> **Problème** : Impossible de comprendre le rôle du groupe
> 
> **Solution** : Convention de nommage stricte avec préfixes/suffixes

> [!warning] Piège #5 : Groupes imbriqués excessifs **Symptôme** : Groupe A → Groupe B → Groupe C → Groupe D → Permission
> 
> **Problème** : Difficulté à tracer les permissions, lenteur d'évaluation
> 
> **Solution** : Limiter à 2-3 niveaux maximum (AGDLP = 2-3 niveaux)

### ✅ Bonnes pratiques

> [!tip] Bonne pratique #1 : Documentation
> 
> - Utiliser le champ **Description** de chaque groupe
> - Définir un attribut **ManagedBy** (propriétaire du groupe)
> - Tenir un registre des groupes et de leurs objectifs

> [!tip] Bonne pratique #2 : Audit régulier
> 
> ```powershell
> # Groupes non utilisés depuis 90 jours
> $date = (Get-Date).AddDays(-90)
> Get-ADGroup -Filter * -Properties whenChanged | 
>     Where-Object { $_.whenChanged -lt $date } |
>     Select-Object Name, whenChanged
> ```

> [!tip] Bonne pratique #3 : Séparation lecture/écriture Pour chaque ressource, créez des groupes locaux distincts :
> 
> - `Ressource_Lecture_DL`
> - `Ressource_Ecriture_DL`
> - `Ressource_Admin_DL`

> [!tip] Bonne pratique #4 : Groupes de rôles réutilisables Créez des groupes globaux basés sur les **fonctions métier** plutôt que sur les ressources :
> 
> - `Comptables_G` (pas `AccesDossierCompta_G`)
> - `Developpeurs_G` (pas `AccesGit_G`)

> [!tip] Bonne pratique #5 : Protection des groupes sensibles
> 
> ```powershell
> # Protéger un groupe contre la suppression accidentelle
> Get-ADGroup "Admins_Domaine" | 
>     Set-ADObject -ProtectedFromAccidentalDeletion $true
> ```

> [!tip] Bonne pratique #6 : Automatisation Créez des scripts PowerShell pour les tâches récurrentes :
> 
> - Création d'utilisateur → ajout automatique aux groupes appropriés
> - Départ d'utilisateur → retrait de tous les groupes
> - Rapport mensuel des appartenances

---

## 🎓 Synthèse finale

### Points clés à retenir

1. **Types de groupes** :
    
    - **Sécurité** : Pour les permissions (toujours privilégier)
    - **Distribution** : Pour les emails uniquement
2. **Étendues de groupes** :
    
    - **Domain Local** : Permissions sur ressources locales, contient tout
    - **Global** : Rôles/fonctions, contient uniquement du même domaine
    - **Universal** : Consolidation inter-domaines, à utiliser avec modération
3. **Stratégie AGDLP** :
    
    - **A** : Comptes utilisateurs
    - **G** : Groupes globaux (rôles)
    - **U** : Groupes universels (consolidation)
    - **DL** : Groupes locaux (accès)
    - **P** : Permissions sur ressources
4. **Règles d'or** :
    
    - ✅ Toujours utiliser des groupes pour les permissions
    - ✅ Respecter la stratégie AGDLP
    - ✅ Nommer clairement les groupes
    - ✅ Documenter et auditer régulièrement
    - ❌ Jamais d'utilisateurs directs dans les groupes locaux
    - ❌ Jamais de permissions directes aux utilisateurs

### Commandes PowerShell essentielles

```powershell
# Créer un groupe
New-ADGroup -Name "Nom" -GroupScope [Global|DomainLocal|Universal] -GroupCategory Security

# Ajouter des membres
Add-ADGroupMember -Identity "Groupe" -Members "user1", "user2"

# Retirer des membres
Remove-ADGroupMember -Identity "Groupe" -Members "user1" -Confirm:$false

# Lister les membres
Get-ADGroupMember -Identity "Groupe"

# Lister les groupes d'un utilisateur
Get-ADUser -Identity "user" -Properties MemberOf | Select-Object -ExpandProperty MemberOf

# Changer l'étendue
Set-ADGroup -Identity "Groupe" -GroupScope Universal

# Protéger contre la suppression
Get-ADGroup "Groupe" | Set-ADObject -ProtectedFromAccidentalDeletion $true
```

---

**Fin du cours sur les Groupes Active Directory** 🎉