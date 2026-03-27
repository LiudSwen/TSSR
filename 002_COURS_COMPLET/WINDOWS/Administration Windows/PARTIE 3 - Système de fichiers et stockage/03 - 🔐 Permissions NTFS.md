

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

Les permissions NTFS (New Technology File System) constituent le mécanisme de sécurité fondamental pour contrôler l'accès aux fichiers et dossiers dans Windows Server. Elles permettent de définir précisément qui peut faire quoi sur une ressource.

> [!info] Pourquoi les permissions NTFS sont essentielles
> - **Sécurité granulaire** : Contrôle précis au niveau fichier/dossier
> - **Protection des données** : Empêche les accès non autorisés
> - **Audit et traçabilité** : Permet de suivre qui accède à quoi
> - **Conformité** : Répond aux exigences de sécurité entreprise

### 🔍 Différence avec les permissions de partage

| Aspect | Permissions NTFS | Permissions de partage |
|--------|------------------|------------------------|
| **Scope** | Local + Réseau | Réseau uniquement |
| **Granularité** | Très détaillée | Basique (Lire, Modifier, Contrôle total) |
| **Héritage** | Oui | Non |
| **Sécurité** | Plus forte | Plus faible |

> [!tip] Règle d'or
> Les permissions NTFS s'appliquent **toujours**, que l'accès soit local ou distant. En cas d'accès réseau, c'est la permission la plus restrictive entre NTFS et partage qui s'applique.

---

## 📊 Types de permissions NTFS

NTFS propose deux niveaux de permissions : **de base** (simples) et **avancées** (détaillées).

---

## 🟢 Permissions de base

Les permissions de base sont des combinaisons prédéfinies de permissions avancées, conçues pour simplifier la gestion quotidienne.

### Liste des permissions de base

| Permission | Description | Cas d'usage typique |
|------------|-------------|---------------------|
| **Lecture** | Voir fichiers et dossiers, lire le contenu | Consultation de documentation |
| **Lecture et exécution** | Lecture + exécuter des programmes | Accès aux applications |
| **Écriture** | Créer fichiers/dossiers, modifier attributs | Dépôt de fichiers |
| **Modification** | Lire, écrire, supprimer fichiers | Travail collaboratif |
| **Contrôle total** | Toutes les permissions + modifier les permissions | Administrateurs, propriétaires |
| **Permissions spéciales** | Combinaison personnalisée de permissions avancées | Besoins spécifiques |

### 📝 Configuration des permissions de base

**Via l'interface graphique :**

1. Clic droit sur le fichier/dossier → **Propriétés**
2. Onglet **Sécurité**
3. Bouton **Modifier** pour changer les permissions
4. **Ajouter** pour ajouter un utilisateur/groupe
5. Cocher les permissions appropriées

> [!example] Exemple pratique
> Pour donner à un groupe "Comptabilité" l'accès en lecture seule au dossier "Rapports_Financiers" :
> 1. Propriétés → Sécurité → Modifier
> 2. Ajouter → Entrer "Comptabilité" → OK
> 3. Cocher uniquement "Lecture"
> 4. Appliquer → OK

**Via PowerShell :**

```powershell
# Obtenir les permissions actuelles
Get-Acl "C:\Dossier" | Format-List

# Ajouter une permission de lecture pour un utilisateur
$acl = Get-Acl "C:\Dossier"
$permission = "DOMAINE\Utilisateur","Read","Allow"
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
$acl.SetAccessRule($accessRule)
Set-Acl "C:\Dossier" $acl

# Ajouter une permission de modification pour un groupe
$acl = Get-Acl "C:\Dossier"
$permission = "DOMAINE\Groupe","Modify","ContainerInherit,ObjectInherit","None","Allow"
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission
$acl.SetAccessRule($accessRule)
Set-Acl "C:\Dossier" $acl
```

### 🎭 Permissions Autoriser vs Refuser

NTFS distingue deux types d'attribution :

- **Autoriser** : Accorde explicitement la permission
- **Refuser** : Bloque explicitement la permission

> [!warning] Le refus est prioritaire !
> Une permission **Refuser** l'emporte TOUJOURS sur **Autoriser**, même si l'utilisateur appartient à plusieurs groupes avec des autorisations contradictoires.

**Exemple de conflit :**
- Jean appartient au groupe "Utilisateurs" (Autoriser Lecture)
- Jean appartient au groupe "Restreints" (Refuser Lecture)
- **Résultat** : Jean ne peut PAS lire (Refuser gagne)

---

## 🔧 Permissions avancées

Les permissions avancées offrent un contrôle très granulaire. Les permissions de base sont en fait des ensembles de permissions avancées.

### Liste complète des permissions avancées

| Permission avancée | Description |
|-------------------|-------------|
| **Parcourir le dossier / Exécuter le fichier** | Naviguer dans l'arborescence, lancer un exécutable |
| **Afficher le contenu du dossier / Lire les données** | Voir la liste des fichiers, lire le contenu |
| **Lire les attributs** | Voir les attributs (lecture seule, caché, système) |
| **Lire les attributs étendus** | Voir les métadonnées supplémentaires |
| **Créer des fichiers / Écrire des données** | Ajouter de nouveaux fichiers, modifier le contenu |
| **Créer des dossiers / Ajouter des données** | Créer des sous-dossiers, ajouter au contenu |
| **Écrire les attributs** | Modifier les attributs de base |
| **Écrire les attributs étendus** | Modifier les métadonnées étendues |
| **Supprimer les sous-dossiers et les fichiers** | Effacer le contenu même sans permission sur celui-ci |
| **Supprimer** | Effacer le fichier/dossier |
| **Lire les autorisations** | Voir qui a quelles permissions |
| **Modifier les autorisations** | Changer les permissions |
| **Appropriation** | Devenir propriétaire de la ressource |
| **Synchroniser** | Utiliser la ressource pour synchronisation de threads |

### 📊 Correspondance permissions de base ↔ avancées

| Permission de base | Permissions avancées incluses |
|-------------------|------------------------------|
| **Lecture** | Afficher le contenu, Lire les données, Lire les attributs, Lire les attributs étendus, Lire les autorisations, Synchroniser |
| **Lecture et exécution** | Lecture + Parcourir le dossier / Exécuter le fichier |
| **Écriture** | Créer fichiers/dossiers, Écrire les données, Ajouter des données, Écrire les attributs, Écrire les attributs étendus, Lire les autorisations, Synchroniser |
| **Modification** | Lecture et exécution + Écriture + Supprimer |
| **Contrôle total** | Toutes les permissions avancées |

### 🛠️ Accéder aux permissions avancées

1. Propriétés du fichier/dossier → **Sécurité**
2. Bouton **Avancé**
3. Sélectionner un utilisateur/groupe → **Modifier**
4. La liste complète des permissions avancées s'affiche

> [!example] Cas d'usage des permissions avancées
> **Scénario** : Créer un dossier de dépôt où les utilisateurs peuvent uniquement ajouter des fichiers mais pas lire ceux des autres :
> - Accorder : "Créer des fichiers / Écrire des données"
> - Refuser : "Afficher le contenu du dossier / Lire les données"

---

## 🌳 Héritage des permissions

L'héritage permet de propager automatiquement les permissions d'un dossier parent vers ses sous-dossiers et fichiers.

### 📐 Principe de l'héritage

```
📁 Dossier_Parent (Groupe_A : Modification)
    │
    ├── 📁 Sous-Dossier_1 (hérite → Groupe_A : Modification)
    │   └── 📄 fichier.txt (hérite → Groupe_A : Modification)
    │
    └── 📁 Sous-Dossier_2 (hérite → Groupe_A : Modification)
        └── 📄 document.docx (hérite → Groupe_A : Modification)
```

### 🎨 Types d'héritage

Lors de la configuration des permissions avancées, vous pouvez spécifier :

| Option | Application |
|--------|-------------|
| **Ce dossier uniquement** | Pas d'héritage aux enfants |
| **Ce dossier, ses sous-dossiers et ses fichiers** | Héritage complet (par défaut) |
| **Ce dossier et ses sous-dossiers** | Fichiers exclus |
| **Ce dossier et ses fichiers** | Sous-dossiers exclus |
| **Sous-dossiers et fichiers uniquement** | Dossier actuel exclu |
| **Sous-dossiers uniquement** | Dossier actuel et fichiers exclus |
| **Fichiers uniquement** | Dossiers exclus |

### 🔓 Désactiver l'héritage

**Via l'interface graphique :**

1. Propriétés → Sécurité → **Avancé**
2. Bouton **Désactiver l'héritage**
3. Deux choix :
   - **Convertir les autorisations héritées en autorisations explicites** : Conserve les permissions actuelles
   - **Supprimer toutes les autorisations héritées** : Repart de zéro

> [!warning] Attention à la désactivation de l'héritage
> En supprimant toutes les autorisations héritées, vous risquez de bloquer l'accès, y compris pour vous-même ! Préférez la conversion pour garder le contrôle.

**Via PowerShell :**

```powershell
# Désactiver l'héritage en conservant les permissions
$acl = Get-Acl "C:\Dossier"
$acl.SetAccessRuleProtection($true, $true)  # $true, $true = protéger + conserver
Set-Acl "C:\Dossier" $acl

# Désactiver l'héritage en supprimant les permissions héritées
$acl = Get-Acl "C:\Dossier"
$acl.SetAccessRuleProtection($true, $false)  # $true, $false = protéger + supprimer
Set-Acl "C:\Dossier" $acl
```

### 🔄 Réactiver l'héritage

1. Propriétés → Sécurité → **Avancé**
2. Bouton **Activer l'héritage**
3. Les permissions du parent s'appliquent à nouveau

> [!tip] Bonne pratique
> Utilisez l'héritage autant que possible pour simplifier la gestion. Ne le désactivez que pour des besoins spécifiques clairement identifiés.

---

## 👤 Propriétaire et prise de contrôle

Chaque fichier et dossier a un **propriétaire** qui dispose de droits spéciaux, notamment celui de modifier les permissions même s'il n'y a pas accès autrement.

### 🔍 Identifier le propriétaire

**Via l'interface graphique :**

1. Propriétés → **Sécurité** → **Avancé**
2. En haut : **Propriétaire : DOMAINE\Utilisateur**

**Via PowerShell :**

```powershell
# Voir le propriétaire d'un fichier/dossier
(Get-Acl "C:\Dossier").Owner

# Lister les propriétaires de plusieurs fichiers
Get-ChildItem "C:\Dossier" -Recurse | ForEach-Object {
    [PSCustomObject]@{
        Chemin = $_.FullName
        Propriétaire = (Get-Acl $_.FullName).Owner
    }
} | Format-Table -AutoSize
```

### 🛡️ Prendre possession (Take Ownership)

La prise de contrôle permet de devenir propriétaire d'une ressource. C'est utile quand :
- Un ancien employé a laissé des fichiers verrouillés
- Les permissions sont corrompues
- Vous devez récupérer l'accès à un dossier

**Prérequis :** Être administrateur ou avoir le droit "Appropriation" sur la ressource.

**Via l'interface graphique :**

1. Propriétés → **Sécurité** → **Avancé**
2. Cliquer sur **Modifier** à côté du propriétaire
3. Entrer le nom du nouvel utilisateur/groupe
4. Cocher "**Remplacer le propriétaire des sous-conteneurs et des objets**" (pour dossiers)
5. **OK** → **Appliquer**

**Via PowerShell :**

```powershell
# Prendre possession d'un fichier/dossier
$acl = Get-Acl "C:\Dossier"
$utilisateur = New-Object System.Security.Principal.NTAccount("DOMAINE\Administrateur")
$acl.SetOwner($utilisateur)
Set-Acl "C:\Dossier" $acl

# Prendre possession récursivement
Get-ChildItem "C:\Dossier" -Recurse | ForEach-Object {
    $acl = Get-Acl $_.FullName
    $acl.SetOwner($utilisateur)
    Set-Acl $_.FullName $acl
}
```

**Via la ligne de commande (takeown & icacls) :**

```bash
# Prendre possession d'un dossier et de son contenu
takeown /f "C:\Dossier" /r /d y

# Accorder le contrôle total à un utilisateur
icacls "C:\Dossier" /grant "DOMAINE\Administrateur:(OI)(CI)F" /t
```

> [!info] Explication des options icacls
> - `(OI)` : Object Inherit (héritage fichiers)
> - `(CI)` : Container Inherit (héritage dossiers)
> - `F` : Full control (contrôle total)
> - `/t` : Appliquer récursivement

> [!warning] Prise de contrôle irréversible
> Une fois la possession prise, l'ancien propriétaire perd ses privilèges spéciaux. Documentez toujours cette action et n'agissez qu'en cas de nécessité.

---

## ✅ Permissions effectives

Les permissions effectives représentent **ce qu'un utilisateur peut réellement faire** sur une ressource, en tenant compte de :
- Permissions directes (accordées directement à l'utilisateur)
- Permissions de groupe (via l'appartenance à des groupes)
- Héritage
- Règles Autoriser vs Refuser

### 🔎 Consulter les permissions effectives

**Via l'interface graphique :**

1. Propriétés → **Sécurité** → **Avancé**
2. Onglet **Accès effectif**
3. Bouton **Sélectionner un utilisateur**
4. Entrer le nom de l'utilisateur → **OK**
5. La liste des permissions effectives s'affiche

> [!example] Résultat typique
> ```
> ✅ Parcourir le dossier / Exécuter le fichier
> ✅ Afficher le contenu du dossier / Lire les données
> ✅ Lire les attributs
> ❌ Créer des fichiers / Écrire des données
> ❌ Supprimer
> ✅ Lire les autorisations
> ```

**Via PowerShell :**

```powershell
# Voir les permissions effectives (nécessite l'outil Get-EffectiveAccess)
# Note : Plus complexe, nécessite souvent des scripts personnalisés

# Alternativement, voir toutes les ACL
Get-Acl "C:\Dossier" | Select-Object -ExpandProperty Access | Format-Table IdentityReference, FileSystemRights, AccessControlType -AutoSize
```

### 📊 Calcul des permissions effectives - Règles

1. **Cumul des autorisations** : Les permissions Autoriser s'additionnent
2. **Refus prioritaire** : Un seul Refuser annule tous les Autoriser
3. **Permissions explicites > héritées** : Les permissions directes priment sur l'héritage

**Exemple de calcul :**

| Source | Type | Permission |
|--------|------|-----------|
| Utilisateur direct | Autoriser | Lecture |
| Groupe "Comptables" | Autoriser | Modification |
| Groupe "Restreints" | Refuser | Écriture |
| **Résultat effectif** | - | Lecture seule (Refuser Écriture bloque la Modification) |

> [!tip] Astuce de dépannage
> En cas de problème d'accès, vérifiez toujours les permissions effectives plutôt que de parcourir manuellement toutes les ACL. Cela vous fait gagner un temps précieux.

---

## 🎯 Bonnes pratiques

### ✨ Stratégie AGDLP / AGUDLP

Utilisez la stratégie **A-G-DL-P** (Accounts - Global groups - Domain Local groups - Permissions) :

1. **A** : Ajouter les comptes utilisateurs (**A**ccounts)
2. **G** : Dans des groupes globaux (**G**lobal)
3. **DL** : Eux-mêmes membres de groupes locaux de domaine (**D**omain **L**ocal)
4. **P** : Auxquels on attribue les permissions (**P**ermissions)

> [!example] Exemple AGDLP
> 1. Jean, Marie → ajoutés au groupe **Global** "G_Compta_Users"
> 2. "G_Compta_Users" → membre du groupe **Domain Local** "DL_Acces_Compta"
> 3. "DL_Acces_Compta" → reçoit la permission Modification sur le dossier "Comptabilité"

### 🛠️ Recommandations générales

> [!tip] Permissions - Best Practices
> - **Privilège minimum** : N'accordez que les permissions strictement nécessaires
> - **Groupes > Utilisateurs** : Accordez toujours les permissions à des groupes, jamais directement aux utilisateurs
> - **Évitez les Refuser** : Utilisez-les uniquement en dernier recours, privilégiez le retrait de l'autorisation
> - **Documentez** : Tenez à jour une documentation des permissions critiques
> - **Auditez régulièrement** : Passez en revue les permissions pour détecter les anomalies
> - **Testez** : Vérifiez toujours les permissions effectives après modification
> - **Héritage par défaut** : Laissez l'héritage activé sauf nécessité absolue
> - **Propriétaires identifiés** : Chaque ressource doit avoir un propriétaire clairement désigné

### 🚫 Pièges courants à éviter

> [!warning] Erreurs fréquentes
> - **Désactiver l'héritage sans raison** : Complexifie la gestion
> - **Multiplier les Refuser** : Rend le dépannage très difficile
> - **Permissions directes aux utilisateurs** : Cauchemar de maintenance
> - **Oublier les groupes imbriqués** : Source de permissions inattendues
> - **Ne pas tester après modification** : Peut bloquer l'accès aux utilisateurs
> - **Prendre possession sans documentation** : Perte de traçabilité

### 🔍 Commandes utiles pour l'audit

```powershell
# Lister tous les fichiers/dossiers avec permissions personnalisées (non héritées)
Get-ChildItem "C:\Dossier" -Recurse | Where-Object {
    (Get-Acl $_.FullName).Access | Where-Object { -not $_.IsInherited }
} | Select-Object FullName

# Trouver tous les objets où un utilisateur spécifique a des permissions
Get-ChildItem "C:\Dossier" -Recurse | Where-Object {
    (Get-Acl $_.FullName).Access | Where-Object { $_.IdentityReference -eq "DOMAINE\Utilisateur" }
} | Select-Object FullName

# Exporter les permissions dans un CSV pour analyse
Get-ChildItem "C:\Dossier" -Recurse | ForEach-Object {
    $chemin = $_.FullName
    (Get-Acl $chemin).Access | ForEach-Object {
        [PSCustomObject]@{
            Chemin = $chemin
            Identité = $_.IdentityReference
            Droits = $_.FileSystemRights
            Type = $_.AccessControlType
            Hérité = $_.IsInherited
        }
    }
} | Export-Csv "C:\Audit_Permissions.csv" -NoTypeInformation -Encoding UTF8
```

---

## 🎓 Récapitulatif

Les permissions NTFS constituent le fondement de la sécurité des fichiers sous Windows Server. En maîtrisant les concepts d'autorisations de base et avancées, d'héritage, de propriété et de permissions effectives, vous disposez des outils nécessaires pour sécuriser efficacement vos données.

**Points clés à retenir :**
- Les permissions NTFS offrent un contrôle granulaire sur les ressources
- L'héritage simplifie la gestion, utilisez-le intelligemment
- Les permissions effectives sont le résultat final de toutes les règles combinées
- Le propriétaire a des privilèges spéciaux, notamment la modification des permissions
- Suivez la stratégie AGDLP et privilégiez les groupes aux utilisateurs individuels
- Auditez et documentez régulièrement vos permissions

---

**Navigation :** [← Gestion des disques](02-gestion-disques.md) | [Partages réseau →](04-partages-reseau.md)