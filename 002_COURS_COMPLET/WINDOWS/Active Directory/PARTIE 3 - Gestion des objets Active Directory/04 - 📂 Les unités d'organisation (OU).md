

> [!info] Vue d'ensemble Les Unités d'Organisation (Organizational Units - OU) sont des conteneurs Active Directory qui permettent d'organiser logiquement les objets (utilisateurs, groupes, ordinateurs) et d'appliquer des stratégies de groupe de manière ciblée. Elles constituent l'épine dorsale de l'architecture organisationnelle d'un domaine AD.

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

## 🏗️ Création et structure des OU

### Qu'est-ce qu'une unité d'organisation ?

Une OU est un **conteneur spécial** dans Active Directory qui permet de :

- Organiser les objets de manière hiérarchique et logique
- Appliquer des stratégies de groupe (GPO) de façon ciblée
- Déléguer des permissions administratives à des utilisateurs spécifiques
- Refléter la structure organisationnelle de l'entreprise

> [!warning] Distinction importante Ne confondez pas les OU avec les **conteneurs par défaut** (Users, Computers, Builtin). Ces derniers ne peuvent pas recevoir de GPO et n'offrent pas les mêmes possibilités de délégation.

### Création d'une OU via l'interface graphique

**Via la console Utilisateurs et ordinateurs Active Directory (dsa.msc) :**

1. Ouvrir **Utilisateurs et ordinateurs Active Directory**
2. Clic droit sur le domaine ou sur une OU parent → **Nouveau** → **Unité d'organisation**
3. Saisir le nom de l'OU
4. Cocher ou non **Protéger le conteneur contre la suppression accidentelle** (recommandé)
5. Cliquer sur **OK**

> [!tip] Astuce de navigation Utilisez `F2` pour renommer rapidement une OU, et `Ctrl + Shift + N` pour créer une nouvelle OU dans certaines versions de Windows Server.

### Création d'une OU via PowerShell

```powershell
# Syntaxe de base pour créer une OU
New-ADOrganizationalUnit -Name "NomDeLOU" -Path "DC=domaine,DC=local"

# Exemple concret : Créer une OU "Services" à la racine du domaine
New-ADOrganizationalUnit -Name "Services" -Path "DC=entreprise,DC=local"

# Créer une OU avec protection contre la suppression
New-ADOrganizationalUnit -Name "Ressources_Humaines" `
    -Path "OU=Services,DC=entreprise,DC=local" `
    -ProtectedFromAccidentalDeletion $true

# Créer une OU avec description
New-ADOrganizationalUnit -Name "Informatique" `
    -Path "OU=Services,DC=entreprise,DC=local" `
    -Description "Service informatique - Infrastructure et support" `
    -ProtectedFromAccidentalDeletion $true
```

> [!example] Exemple de structure hiérarchique
> 
> ```powershell
> # Créer une structure complète pour le département IT
> $Domain = "DC=entreprise,DC=local"
> 
> # OU principale
> New-ADOrganizationalUnit -Name "IT" -Path $Domain -ProtectedFromAccidentalDeletion $true
> 
> # Sous-OUs
> $ITPath = "OU=IT,$Domain"
> New-ADOrganizationalUnit -Name "Serveurs" -Path $ITPath -ProtectedFromAccidentalDeletion $true
> New-ADOrganizationalUnit -Name "Postes_Travail" -Path $ITPath -ProtectedFromAccidentalDeletion $true
> New-ADOrganizationalUnit -Name "Utilisateurs_IT" -Path $ITPath -ProtectedFromAccidentalDeletion $true
> New-ADOrganizationalUnit -Name "Groupes_IT" -Path $ITPath -ProtectedFromAccidentalDeletion $true
> ```

### Commandes PowerShell essentielles pour les OU

```powershell
# Lister toutes les OU du domaine
Get-ADOrganizationalUnit -Filter * | Select-Object Name, DistinguishedName

# Rechercher une OU spécifique
Get-ADOrganizationalUnit -Filter "Name -eq 'Services'"

# Rechercher les OU avec un filtre sur le chemin
Get-ADOrganizationalUnit -Filter * -SearchBase "OU=Services,DC=entreprise,DC=local"

# Obtenir les détails complets d'une OU
Get-ADOrganizationalUnit -Identity "OU=Services,DC=entreprise,DC=local" -Properties *

# Modifier une OU (exemple : changer la description)
Set-ADOrganizationalUnit -Identity "OU=Services,DC=entreprise,DC=local" `
    -Description "Services de l'entreprise - Mise à jour 2025"

# Désactiver la protection contre la suppression
Set-ADOrganizationalUnit -Identity "OU=Test,DC=entreprise,DC=local" `
    -ProtectedFromAccidentalDeletion $false

# Supprimer une OU (doit être vide et non protégée)
Remove-ADOrganizationalUnit -Identity "OU=Test,DC=entreprise,DC=local" -Confirm:$false

# Déplacer une OU vers un autre emplacement
Move-ADObject -Identity "OU=Ancienne,DC=entreprise,DC=local" `
    -TargetPath "OU=Nouvelle_Parent,DC=entreprise,DC=local"
```

### Propriétés importantes d'une OU

|Propriété|Description|Utilisation|
|---|---|---|
|**Name**|Nom de l'OU|Identification simple|
|**DistinguishedName**|Chemin complet LDAP|Référence unique dans AD|
|**Description**|Description textuelle|Documentation de l'objectif|
|**ProtectedFromAccidentalDeletion**|Protection contre la suppression|Sécurité (recommandé à $true)|
|**ManagedBy**|Gestionnaire de l'OU|Délégation et responsabilité|
|**gPLink**|GPOs liées|Stratégies appliquées|

> [!warning] Pièges courants
> 
> - **Suppression d'OU protégée** : Vous devez d'abord désactiver la protection avant de supprimer une OU
> - **OU non vide** : Impossible de supprimer une OU contenant des objets (utilisateurs, groupes, ordinateurs, sous-OU)
> - **Chemins LDAP** : Respectez la syntaxe exacte du Distinguished Name (sensible à la casse et aux virgules)

---

## 🔐 Délégation de contrôle

### Principe de la délégation

La **délégation de contrôle** permet d'accorder des permissions administratives spécifiques sur une OU à des utilisateurs ou groupes **sans leur donner des privilèges d'administrateur de domaine**. C'est un principe fondamental de la sécurité AD basé sur le **moindre privilège**.

### Pourquoi déléguer ?

- **Répartir les tâches** : Permettre aux équipes locales de gérer leurs propres ressources
- **Sécurité** : Limiter le nombre d'administrateurs de domaine
- **Efficacité** : Réduire la charge de travail de l'équipe IT centrale
- **Conformité** : Respecter les exigences de séparation des responsabilités

> [!info] Cas d'usage typiques
> 
> - Permettre aux RH de créer/modifier des comptes utilisateurs dans leur OU
> - Autoriser le support IT de réinitialiser les mots de passe
> - Donner la gestion des groupes à des chefs d'équipe
> - Déléguer la gestion des ordinateurs aux administrateurs locaux

### Délégation via l'assistant graphique

**Étapes dans Utilisateurs et ordinateurs Active Directory :**

1. Clic droit sur l'OU → **Délégation de contrôle**
2. **Assistant de délégation de contrôle** s'ouvre
3. Cliquer sur **Suivant**
4. **Ajouter** les utilisateurs ou groupes destinataires
5. Sélectionner les tâches à déléguer :
    - Tâches courantes prédéfinies (création d'utilisateurs, réinitialisation de mots de passe, etc.)
    - Ou créer une tâche personnalisée
6. Valider et terminer

> [!example] Tâches courantes prédéfinies
> 
> - Créer, supprimer et gérer les comptes d'utilisateur
> - Réinitialiser les mots de passe utilisateur et forcer le changement de mot de passe
> - Lire toutes les informations des utilisateurs
> - Créer, supprimer et gérer les groupes
> - Modifier l'appartenance à un groupe
> - Gérer les liens de stratégie de groupe
> - Créer, supprimer et gérer les comptes inetOrgPerson

### Délégation via PowerShell

PowerShell offre un contrôle plus granulaire via **DSACLS** ou les cmdlets AD.

```powershell
# Importer le module Active Directory
Import-Module ActiveDirectory

# Exemple 1 : Déléguer la création d'utilisateurs dans une OU
$OU = "OU=Services,DC=entreprise,DC=local"
$Group = "GRP_RH_Admins"

# Récupérer le SID du groupe
$GroupSID = (Get-ADGroup -Identity $Group).SID

# Définir les droits pour créer des objets utilisateur
$ACL = Get-Acl -Path "AD:\$OU"
$UserGUID = [GUID]"bf967aba-0de6-11d0-a285-00aa003049e2" # GUID pour l'objet User

$Identity = [System.Security.Principal.IdentityReference]$GroupSID
$ADRight = [System.DirectoryServices.ActiveDirectoryRights]"CreateChild,DeleteChild"
$Type = [System.Security.AccessControl.AccessControlType]"Allow"
$InheritanceType = [System.DirectoryServices.ActiveDirectorySecurityInheritance]"All"

$ACE = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($Identity, $ADRight, $Type, $UserGUID, $InheritanceType)
$ACL.AddAccessRule($ACE)

Set-Acl -Path "AD:\$OU" -AclObject $ACL
```

```powershell
# Exemple 2 : Déléguer la réinitialisation des mots de passe
$OU = "OU=Utilisateurs,OU=Services,DC=entreprise,DC=local"
$Group = "GRP_Support_IT"

$GroupSID = (Get-ADGroup -Identity $Group).SID
$ACL = Get-Acl -Path "AD:\$OU"

# GUID pour la propriété "Réinitialiser mot de passe"
$ResetPwdGUID = [GUID]"00299570-246d-11d0-a768-00aa006e0529"

$Identity = [System.Security.Principal.IdentityReference]$GroupSID
$ADRight = [System.DirectoryServices.ActiveDirectoryRights]"ExtendedRight"
$Type = [System.Security.AccessControl.AccessControlType]"Allow"
$InheritanceType = [System.DirectoryServices.ActiveDirectorySecurityInheritance]"Descendents"
$InheritedObjectType = [GUID]"bf967aba-0de6-11d0-a285-00aa003049e2" # User object

$ACE = New-Object System.DirectoryServices.ActiveDirectoryAccessRule($Identity, $ADRight, $Type, $ResetPwdGUID, $InheritanceType, $InheritedObjectType)
$ACL.AddAccessRule($ACE)

Set-Acl -Path "AD:\$OU" -AclObject $ACL
```

### Utilisation de DSACLS (outil en ligne de commande)

```bash
# Syntaxe de base DSACLS
dsacls "DistinguishedName_de_OU" /G "Utilisateur_ou_Groupe:Permissions"

# Exemple : Donner le contrôle total sur une OU
dsacls "OU=Services,DC=entreprise,DC=local" /G "ENTREPRISE\GRP_IT_Admins:GA"

# Exemple : Déléguer la création d'utilisateurs
dsacls "OU=RH,DC=entreprise,DC=local" /G "ENTREPRISE\GRP_RH_Admins:CC;user"

# Exemple : Déléguer la réinitialisation de mot de passe
dsacls "OU=Utilisateurs,DC=entreprise,DC=local" /G "ENTREPRISE\GRP_Support:CA;Reset Password;user"

# Voir les permissions actuelles d'une OU
dsacls "OU=Services,DC=entreprise,DC=local"
```

### Codes de permissions DSACLS courants

|Code|Signification|Description|
|---|---|---|
|**GA**|Generic All|Contrôle total|
|**GR**|Generic Read|Lecture seule|
|**GW**|Generic Write|Écriture|
|**CC**|Create Child|Créer des objets enfants|
|**DC**|Delete Child|Supprimer des objets enfants|
|**CA**|Control Access|Droits étendus spécifiques|
|**RP**|Read Property|Lire des propriétés|
|**WP**|Write Property|Écrire des propriétés|

> [!tip] Astuce : GUIDs utiles pour la délégation Quelques GUIDs importants pour les objets AD :
> 
> - **User** : `bf967aba-0de6-11d0-a285-00aa003049e2`
> - **Group** : `bf967a9c-0de6-11d0-a285-00aa003049e2`
> - **Computer** : `bf967a86-0de6-11d0-a285-00aa003049e2`
> - **Reset Password** : `00299570-246d-11d0-a768-00aa006e0529`
> - **Change Password** : `ab721a53-1e2f-11d0-9819-00aa0040529b`

### Vérifier les délégations existantes

```powershell
# Afficher les ACL d'une OU
Get-Acl -Path "AD:\OU=Services,DC=entreprise,DC=local" | Select-Object -ExpandProperty Access | Format-Table IdentityReference, ActiveDirectoryRights, AccessControlType -AutoSize

# Exporter les ACL dans un fichier pour analyse
Get-Acl -Path "AD:\OU=Services,DC=entreprise,DC=local" | 
    Select-Object -ExpandProperty Access | 
    Export-Csv -Path "C:\Temp\ACL_Services.csv" -NoTypeInformation
```

> [!warning] Bonnes pratiques de délégation
> 
> - **Toujours déléguer à des groupes**, jamais à des utilisateurs individuels
> - **Documenter** toutes les délégations effectuées
> - **Tester** les délégations avec un compte de test avant de les appliquer en production
> - **Auditer régulièrement** les permissions pour détecter les dérives
> - **Principe du moindre privilège** : ne donnez que les permissions strictement nécessaires
> - **Éviter les délégations au niveau du domaine** : préférez des OU spécifiques

---

## 🎯 Stratégie de conception

### Principes de conception d'une structure d'OU

Une bonne architecture d'OU doit être :

- **Simple** : Facile à comprendre et à maintenir
- **Évolutive** : Capable de s'adapter aux changements organisationnels
- **Sécurisée** : Permettre une délégation granulaire
- **Efficace** : Optimiser l'application des GPO

> [!info] Question fondamentale Avant de créer une structure d'OU, demandez-vous : "Quelle est ma logique d'organisation principale ?"
> 
> - Organisation par **géographie** ?
> - Organisation par **département** ?
> - Organisation par **fonction** ?
> - Organisation par **type d'objet** ?
> - Organisation **hybride** ?

### Modèles de conception courants

#### 1️⃣ Modèle basé sur la géographie

```
Racine du domaine
├── OU=Paris
│   ├── OU=Utilisateurs
│   ├── OU=Ordinateurs
│   ├── OU=Groupes
│   └── OU=Serveurs
├── OU=Lyon
│   ├── OU=Utilisateurs
│   ├── OU=Ordinateurs
│   ├── OU=Groupes
│   └── OU=Serveurs
└── OU=Marseille
    ├── OU=Utilisateurs
    ├── OU=Ordinateurs
    ├── OU=Groupes
    └── OU=Serveurs
```

**Avantages :**

- Idéal pour les entreprises multi-sites
- Facilite la délégation aux équipes IT locales
- Permet des GPO spécifiques par site (imprimantes, fuseaux horaires, etc.)

**Inconvénients :**

- Duplication de la structure si nécessaire
- Complexité si les utilisateurs sont mobiles entre sites

#### 2️⃣ Modèle basé sur les départements

```
Racine du domaine
├── OU=Ressources_Humaines
│   ├── OU=Utilisateurs_RH
│   ├── OU=Ordinateurs_RH
│   └── OU=Groupes_RH
├── OU=Finance
│   ├── OU=Utilisateurs_Finance
│   ├── OU=Ordinateurs_Finance
│   └── OU=Groupes_Finance
├── OU=Informatique
│   ├── OU=Utilisateurs_IT
│   ├── OU=Ordinateurs_IT
│   ├── OU=Serveurs
│   └── OU=Groupes_IT
└── OU=Marketing
    ├── OU=Utilisateurs_Marketing
    ├── OU=Ordinateurs_Marketing
    └── OU=Groupes_Marketing
```

**Avantages :**

- Reflète l'organigramme de l'entreprise
- Facilite la délégation par département
- GPO ciblées par métier (applications spécifiques, sécurité)

**Inconvénients :**

- Réorganisation complexe si l'entreprise change de structure
- Difficulté pour les utilisateurs multi-départements

#### 3️⃣ Modèle basé sur le type d'objet

```
Racine du domaine
├── OU=Utilisateurs
│   ├── OU=Admins
│   ├── OU=Employes
│   ├── OU=Consultants
│   └── OU=Comptes_Service
├── OU=Ordinateurs
│   ├── OU=Postes_Travail
│   ├── OU=Portables
│   └── OU=Terminaux_Legers
├── OU=Serveurs
│   ├── OU=Serveurs_Production
│   ├── OU=Serveurs_Test
│   └── OU=Serveurs_Infrastructure
└── OU=Groupes
    ├── OU=Groupes_Securite
    ├── OU=Groupes_Distribution
    └── OU=Groupes_Application
```

**Avantages :**

- Structure simple et claire
- Facilite l'application de GPO par type d'objet
- Gestion centralisée

**Inconvénients :**

- Délégation moins granulaire
- Difficile de distinguer les départements

#### 4️⃣ Modèle hybride (recommandé pour la plupart des organisations)

```
Racine du domaine
├── OU=Entreprise
│   ├── OU=Utilisateurs
│   │   ├── OU=Direction
│   │   ├── OU=RH
│   │   ├── OU=Finance
│   │   ├── OU=IT
│   │   └── OU=Marketing
│   ├── OU=Ordinateurs
│   │   ├── OU=Postes_Direction
│   │   ├── OU=Postes_RH
│   │   ├── OU=Postes_Finance
│   │   ├── OU=Postes_IT
│   │   └── OU=Postes_Marketing
│   ├── OU=Groupes
│   │   ├── OU=Groupes_Securite
│   │   └── OU=Groupes_Distribution
│   └── OU=Ressources
│       ├── OU=Imprimantes
│       └── OU=Partages
├── OU=Serveurs
│   ├── OU=Infrastructure
│   │   ├── OU=Controleurs_Domaine
│   │   ├── OU=Serveurs_Fichiers
│   │   └── OU=Serveurs_DHCP_DNS
│   ├── OU=Applications
│   │   ├── OU=Serveurs_Web
│   │   ├── OU=Serveurs_Base_Donnees
│   │   └── OU=Serveurs_Messagerie
│   └── OU=Test_Dev
└── OU=Comptes_Speciaux
    ├── OU=Comptes_Service
    ├── OU=Comptes_Admin
    └── OU=Comptes_Externes
```

**Avantages :**

- Combine les avantages des autres modèles
- Flexibilité maximale
- Permet une délégation granulaire ET une gestion centralisée

**Inconvénients :**

- Peut devenir complexe si mal planifié
- Nécessite une bonne documentation

### Règles d'or de la conception

> [!tip] Les 10 commandements de la structure d'OU
> 
> 1. **La simplicité tu privilégieras** : Maximum 5-7 niveaux de profondeur
> 2. **Par la fonction tu organiseras** : Pas par les personnes (qui changent)
> 3. **Les GPO tu optimiseras** : Structure alignée sur les besoins de stratégies
> 4. **La délégation tu anticiperas** : Penser aux besoins de délégation futurs
> 5. **L'héritage tu respecteras** : Comprendre l'héritage des GPO et permissions
> 6. **La documentation tu maintiendras** : Documenter la logique et les changements
> 7. **Le changement tu prévoiras** : Concevoir pour l'évolution, pas l'état actuel
> 8. **Les objets tu sépareras** : Utilisateurs, ordinateurs, groupes dans des OU distinctes
> 9. **La protection tu activeras** : Toujours protéger contre la suppression accidentelle
> 10. **Tester tu devras** : Valider dans un environnement de test avant la production

### Profondeur et largeur de la structure

**Profondeur excessive = Problème**

```
❌ MAUVAIS (trop profond - 8 niveaux)
Racine → OU=Entreprise → OU=Sites → OU=Paris → OU=Services → OU=IT 
→ OU=Equipes → OU=Support → OU=Utilisateurs
```

**Structure équilibrée = Meilleur**

```
✅ BON (4 niveaux)
Racine → OU=Paris → OU=IT_Support → OU=Utilisateurs
```

> [!warning] Limites techniques et pratiques
> 
> - **Profondeur recommandée** : 3 à 5 niveaux maximum
> - **Largeur** : Pas plus de 10-15 OU par niveau (lisibilité)
> - **Performance GPO** : Chaque niveau ajoute du temps de traitement
> - **Complexité administrative** : Plus c'est profond, plus c'est difficile à gérer

### Considérations pour les GPO

La structure d'OU doit **refléter vos besoins en termes de GPO** :

|Besoin GPO|Structure recommandée|
|---|---|
|Paramètres différents par site|Organisation géographique|
|Paramètres différents par département|Organisation par département|
|Paramètres différents par type de poste|Séparer postes fixes/portables/serveurs|
|Sécurité renforcée pour certains groupes|OU dédiée aux utilisateurs sensibles|
|Applications métier spécifiques|OU par métier ou application|

```powershell
# Exemple : Créer une structure optimisée pour les GPO
$Domain = "DC=entreprise,DC=local"

# OU principale pour utilisateurs avec sous-divisions par besoin GPO
New-ADOrganizationalUnit -Name "Utilisateurs_Standard" -Path $Domain
New-ADOrganizationalUnit -Name "Utilisateurs_Securises" -Path $Domain # Pour GPO de sécurité renforcée
New-ADOrganizationalUnit -Name "Utilisateurs_Nomades" -Path $Domain # Pour GPO spécifique aux portables

# OU pour ordinateurs avec sous-divisions techniques
New-ADOrganizationalUnit -Name "Postes_Windows11" -Path $Domain
New-ADOrganizationalUnit -Name "Postes_Windows10" -Path $Domain
```

### Gestion du cycle de vie avec les OU

Prévoir des OU pour les différents états du cycle de vie :

```
Racine du domaine
├── OU=Production
│   ├── OU=Utilisateurs_Actifs
│   └── OU=Ordinateurs_Actifs
├── OU=Nouveaux
│   ├── OU=Utilisateurs_Nouveaux
│   └── OU=Ordinateurs_Nouveaux
├── OU=Desactives
│   ├── OU=Utilisateurs_Desactives
│   └── OU=Ordinateurs_Desactives
└── OU=Quarantaine
    ├── OU=Utilisateurs_Compromis
    └── OU=Ordinateurs_Compromis
```

**Avantages de cette approche :**

- Facilite l'application de GPO restrictives aux objets désactivés
- Permet un audit facile des comptes inactifs
- Isole les objets compromis pour analyse

### Nommage des OU : conventions importantes

> [!tip] Conventions de nommage recommandées
> 
> - **Utiliser des préfixes** : `OU_Dept_`, `OU_Geo_`, `OU_Type_`
> - **Éviter les espaces** : Utiliser des underscores `_` ou camelCase
> - **Être descriptif** : `Utilisateurs_IT_Infrastructure` plutôt que `IT_Users`
> - **Être cohérent** : Adopter une convention et s'y tenir
> - **Éviter les caractères spéciaux** : Pas d'accents, de slash, de guillemets
> - **Limiter la longueur** : Maximum 30-40 caractères

```powershell
# Exemples de bons noms d'OU
New-ADOrganizationalUnit -Name "Users_Finance_Comptabilite"
New-ADOrganizationalUnit -Name "Computers_Geo_Paris"
New-ADOrganizationalUnit -Name "Servers_Prod_Web"
New-ADOrganizationalUnit -Name "Groups_Security_IT"

# Éviter ces noms
# ❌ "OU1", "Test", "Temp", "Utilisateurs RH & Finance"
```

### Migration et réorganisation des OU

Si vous devez **réorganiser** une structure d'OU existante :

```powershell
# 1. Analyser la structure actuelle
Get-ADOrganizationalUnit -Filter * | 
    Select-Object Name, DistinguishedName | 
    Export-Csv -Path "C:\Temp\OU_Actuelle.csv"

# 2. Créer la nouvelle structure (exemple)
New-ADOrganizationalUnit -Name "Nouvelle_Structure" -Path "DC=entreprise,DC=local"

# 3. Déplacer les objets (utilisateurs, ordinateurs, groupes)
$Utilisateurs = Get-ADUser -SearchBase "OU=Ancienne,DC=entreprise,DC=local" -Filter *
foreach ($User in $Utilisateurs) {
    Move-ADObject -Identity $User.DistinguishedName `
        -TargetPath "OU=Nouvelle_Structure,DC=entreprise,DC=local"
}

# 4. Vérifier les GPO liées et les redéployer si nécessaire
Get-GPInheritance -Target "OU=Nouvelle_Structure,DC=entreprise,DC=local"

# 5. Supprimer l'ancienne structure (une fois vide et testée)
Remove-ADOrganizationalUnit -Identity "OU=Ancienne,DC=entreprise,DC=local" -Recursive
```

> [!warning] Précautions lors d'une réorganisation
> 
> - **Testez en environnement de développement** avant la production
> - **Sauvegardez** l'état actuel d'Active Directory
> - **Planifiez pendant une fenêtre de maintenance**
> - **Vérifiez les impacts GPO** : les liens GPO ne suivent pas automatiquement
> - **Communiquez** aux utilisateurs et administrateurs
> - **Documentez** tous les changements effectués

### Cas pratiques de conception

#### Cas 1 : PME de 150 personnes, mono-site

```
Racine du domaine
├── OU=Entreprise
│   ├── OU=Utilisateurs
│   │   ├── OU=Direction
│   │   ├── OU=Employes
│   │   └── OU=Externes
│   ├── OU=Ordinateurs
│   │   ├── OU=Bureaux
│   │   └── OU=Portables
│   ├── OU=Groupes
│   └── OU=Ressources
├── OU=Serveurs
└── OU=Comptes_Admin
```

**Caractéristiques :**

- Structure simple et plate (3 niveaux maximum)
- Pas de complexité géographique
- Séparation claire utilisateurs/ordinateurs/serveurs
- Facile à administrer avec peu de personnel IT

**GPO principales :**

- Politique de mot de passe renforcée sur Direction
- Paramètres bureau standard sur Employes
- Restrictions supplémentaires sur Externes

#### Cas 2 : Entreprise multi-sites (500 personnes, 5 sites)

```
Racine du domaine
├── OU=Sites
│   ├── OU=Siege_Paris
│   │   ├── OU=Utilisateurs_Paris
│   │   ├── OU=Ordinateurs_Paris
│   │   └── OU=Serveurs_Paris
│   ├── OU=Agence_Lyon
│   │   ├── OU=Utilisateurs_Lyon
│   │   ├── OU=Ordinateurs_Lyon
│   │   └── OU=Serveurs_Lyon
│   ├── OU=Agence_Marseille
│   │   ├── OU=Utilisateurs_Marseille
│   │   └── OU=Ordinateurs_Marseille
│   ├── OU=Agence_Toulouse
│   │   ├── OU=Utilisateurs_Toulouse
│   │   └── OU=Ordinateurs_Toulouse
│   └── OU=Agence_Bordeaux
│       ├── OU=Utilisateurs_Bordeaux
│       └── OU=Ordinateurs_Bordeaux
├── OU=Groupes_Globaux
└── OU=Infrastructure_Centrale
    ├── OU=Serveurs_Production
    └── OU=Serveurs_Infrastructure
```

**Caractéristiques :**

- Organisation géographique prioritaire
- Délégation possible aux équipes IT locales
- Serveurs centralisés au siège
- Groupes centralisés pour la cohérence

**GPO principales :**

- GPO d'imprimantes spécifiques par site
- GPO de proxy/réseau par site
- GPO de sécurité globales héritées

#### Cas 3 : Grande entreprise (2000+ personnes, structure complexe)

```
Racine du domaine
├── OU=Corporate
│   ├── OU=Utilisateurs
│   │   ├── OU=Direction_Generale
│   │   ├── OU=Ressources_Humaines
│   │   ├── OU=Finance_Comptabilite
│   │   ├── OU=Marketing_Communication
│   │   ├── OU=Commercial_Ventes
│   │   ├── OU=Operations_Production
│   │   └── OU=IT_Infrastructure
│   ├── OU=Ordinateurs
│   │   ├── OU=Postes_Standard
│   │   ├── OU=Postes_Securises
│   │   ├── OU=Portables
│   │   └── OU=Kiosques
│   ├── OU=Groupes
│   │   ├── OU=Groupes_Securite
│   │   ├── OU=Groupes_Distribution
│   │   └── OU=Groupes_Application
│   └── OU=Ressources_Partagees
│       ├── OU=Imprimantes
│       └── OU=Peripheriques
├── OU=Serveurs
│   ├── OU=Production
│   │   ├── OU=Serveurs_Web
│   │   ├── OU=Serveurs_Application
│   │   ├── OU=Serveurs_Base_Donnees
│   │   └── OU=Serveurs_Fichiers
│   ├── OU=Infrastructure
│   │   ├── OU=Controleurs_Domaine
│   │   ├── OU=Serveurs_DHCP_DNS
│   │   └── OU=Serveurs_Monitoring
│   └── OU=Dev_Test
│       ├── OU=Serveurs_Developpement
│       └── OU=Serveurs_Recette
├── OU=Comptes_Privilegies
│   ├── OU=Admins_Domaine
│   ├── OU=Admins_Serveurs
│   ├── OU=Admins_Delegation
│   └── OU=Comptes_Service
└── OU=Gestion_Cycle_Vie
    ├── OU=Nouveaux_Objets
    ├── OU=Objets_Desactives
    └── OU=Quarantaine
```

**Caractéristiques :**

- Structure hybride département + type d'objet
- Séparation stricte des comptes privilégiés
- Gestion du cycle de vie intégrée
- Distinction Production/Dev/Test pour serveurs
- Permet une délégation très granulaire

**GPO principales :**

- GPO par département avec applications métier
- GPO de sécurité renforcée sur postes sécurisés
- GPO strictes sur comptes privilégiés
- GPO de redirection de dossiers
- GPO d'installation logiciels par groupe

### Script PowerShell pour créer une structure complète

```powershell
# Script de création d'une structure d'OU complète
# À adapter selon vos besoins

# Définir le domaine
$Domain = "DC=entreprise,DC=local"

# Fonction pour créer une OU avec protection
function New-ProtectedOU {
    param(
        [string]$Name,
        [string]$Path,
        [string]$Description = ""
    )
    
    try {
        New-ADOrganizationalUnit -Name $Name `
            -Path $Path `
            -Description $Description `
            -ProtectedFromAccidentalDeletion $true `
            -ErrorAction Stop
        Write-Host "✓ OU créée : $Name" -ForegroundColor Green
    }
    catch {
        Write-Host "✗ Erreur pour $Name : $_" -ForegroundColor Red
    }
}

# Structure principale
Write-Host "`n=== Création de la structure principale ===" -ForegroundColor Cyan
New-ProtectedOU -Name "Entreprise" -Path $Domain -Description "OU racine de l'entreprise"
New-ProtectedOU -Name "Serveurs" -Path $Domain -Description "Serveurs de l'infrastructure"
New-ProtectedOU -Name "Comptes_Privilegies" -Path $Domain -Description "Comptes administrateurs"

# Sous-structure Entreprise
Write-Host "`n=== Création des OUs Entreprise ===" -ForegroundColor Cyan
$EntreprisePath = "OU=Entreprise,$Domain"
New-ProtectedOU -Name "Utilisateurs" -Path $EntreprisePath -Description "Comptes utilisateurs"
New-ProtectedOU -Name "Ordinateurs" -Path $EntreprisePath -Description "Postes de travail"
New-ProtectedOU -Name "Groupes" -Path $EntreprisePath -Description "Groupes de sécurité et distribution"
New-ProtectedOU -Name "Ressources" -Path $EntreprisePath -Description "Ressources partagées"

# Sous-structure Utilisateurs par département
Write-Host "`n=== Création des OUs par département ===" -ForegroundColor Cyan
$UtilisateursPath = "OU=Utilisateurs,$EntreprisePath"
$Departements = @("Direction", "RH", "Finance", "IT", "Marketing", "Commercial", "Production")

foreach ($Dept in $Departements) {
    New-ProtectedOU -Name $Dept -Path $UtilisateursPath -Description "Utilisateurs $Dept"
}

# Sous-structure Ordinateurs
Write-Host "`n=== Création des OUs Ordinateurs ===" -ForegroundColor Cyan
$OrdinateursPath = "OU=Ordinateurs,$EntreprisePath"
New-ProtectedOU -Name "Bureaux" -Path $OrdinateursPath -Description "Postes fixes"
New-ProtectedOU -Name "Portables" -Path $OrdinateursPath -Description "Ordinateurs portables"
New-ProtectedOU -Name "Kiosques" -Path $OrdinateursPath -Description "Postes publics"

# Sous-structure Groupes
Write-Host "`n=== Création des OUs Groupes ===" -ForegroundColor Cyan
$GroupesPath = "OU=Groupes,$EntreprisePath"
New-ProtectedOU -Name "Groupes_Securite" -Path $GroupesPath -Description "Groupes de sécurité"
New-ProtectedOU -Name "Groupes_Distribution" -Path $GroupesPath -Description "Listes de distribution"

# Sous-structure Serveurs
Write-Host "`n=== Création des OUs Serveurs ===" -ForegroundColor Cyan
$ServeursPath = "OU=Serveurs,$Domain"
New-ProtectedOU -Name "Production" -Path $ServeursPath -Description "Serveurs de production"
New-ProtectedOU -Name "Infrastructure" -Path $ServeursPath -Description "Serveurs d'infrastructure"
New-ProtectedOU -Name "Dev_Test" -Path $ServeursPath -Description "Environnement de développement"

# Sous-structure Production
$ProductionPath = "OU=Production,$ServeursPath"
New-ProtectedOU -Name "Serveurs_Web" -Path $ProductionPath
New-ProtectedOU -Name "Serveurs_Application" -Path $ProductionPath
New-ProtectedOU -Name "Serveurs_Base_Donnees" -Path $ProductionPath
New-ProtectedOU -Name "Serveurs_Fichiers" -Path $ProductionPath

# Sous-structure Infrastructure
$InfraPath = "OU=Infrastructure,$ServeursPath"
New-ProtectedOU -Name "Controleurs_Domaine" -Path $InfraPath
New-ProtectedOU -Name "Serveurs_DHCP_DNS" -Path $InfraPath

# Sous-structure Comptes Privilégiés
Write-Host "`n=== Création des OUs Comptes Privilégiés ===" -ForegroundColor Cyan
$PrivilegiesPath = "OU=Comptes_Privilegies,$Domain"
New-ProtectedOU -Name "Admins_Domaine" -Path $PrivilegiesPath -Description "Administrateurs de domaine"
New-ProtectedOU -Name "Admins_Serveurs" -Path $PrivilegiesPath -Description "Administrateurs de serveurs"
New-ProtectedOU -Name "Comptes_Service" -Path $PrivilegiesPath -Description "Comptes de service"

Write-Host "`n=== Structure d'OU créée avec succès ===" -ForegroundColor Green
Write-Host "Pensez à configurer les délégations et les GPO appropriées." -ForegroundColor Yellow
```

### Maintenance et audit de la structure d'OU

#### Scripts d'audit

```powershell
# 1. Générer un rapport complet de la structure d'OU
Get-ADOrganizationalUnit -Filter * -Properties * | 
    Select-Object Name, DistinguishedName, Description, 
                  ProtectedFromAccidentalDeletion, 
                  @{Name='NombreObjets';Expression={(Get-ADObject -SearchBase $_.DistinguishedName -SearchScope OneLevel).Count}},
                  WhenCreated, WhenChanged |
    Export-Csv -Path "C:\Audit\Structure_OU_$(Get-Date -Format 'yyyyMMdd').csv" -NoTypeInformation

# 2. Identifier les OU vides
Get-ADOrganizationalUnit -Filter * | ForEach-Object {
    $ObjetsCount = (Get-ADObject -SearchBase $_.DistinguishedName -SearchScope OneLevel).Count
    if ($ObjetsCount -eq 0) {
        [PSCustomObject]@{
            OU = $_.Name
            DistinguishedName = $_.DistinguishedName
            WhenCreated = $_.WhenCreated
        }
    }
} | Format-Table -AutoSize

# 3. Vérifier les OU non protégées
Get-ADOrganizationalUnit -Filter * -Properties ProtectedFromAccidentalDeletion | 
    Where-Object {$_.ProtectedFromAccidentalDeletion -eq $false} |
    Select-Object Name, DistinguishedName |
    Format-Table -AutoSize

# 4. Lister les GPO liées par OU
Get-ADOrganizationalUnit -Filter * | ForEach-Object {
    $GPLinks = (Get-GPInheritance -Target $_.DistinguishedName).GpoLinks
    if ($GPLinks) {
        [PSCustomObject]@{
            OU = $_.Name
            DistinguishedName = $_.DistinguishedName
            GPOsLiees = ($GPLinks.DisplayName -join ", ")
            NombreGPO = $GPLinks.Count
        }
    }
} | Export-Csv -Path "C:\Audit\GPO_par_OU.csv" -NoTypeInformation

# 5. Identifier les délégations personnalisées
Get-ADOrganizationalUnit -Filter * | ForEach-Object {
    $ACL = Get-Acl -Path "AD:\$($_.DistinguishedName)"
    $CustomACEs = $ACL.Access | Where-Object {
        $_.IdentityReference -notlike "*\Domain Admins" -and
        $_.IdentityReference -notlike "*\Enterprise Admins" -and
        $_.IdentityReference -notlike "*\SYSTEM" -and
        $_.IsInherited -eq $false
    }
    
    if ($CustomACEs) {
        [PSCustomObject]@{
            OU = $_.Name
            DistinguishedName = $_.DistinguishedName
            Delegations = ($CustomACEs.IdentityReference | Select-Object -Unique) -join ", "
        }
    }
} | Format-Table -AutoSize
```

### Troubleshooting courant

> [!warning] Problèmes fréquents et solutions

**Problème 1 : Impossible de supprimer une OU**

```powershell
# Solution : Vérifier et désactiver la protection
Get-ADOrganizationalUnit -Identity "OU=Test,DC=entreprise,DC=local" -Properties ProtectedFromAccidentalDeletion

Set-ADOrganizationalUnit -Identity "OU=Test,DC=entreprise,DC=local" `
    -ProtectedFromAccidentalDeletion $false

# Vérifier qu'elle est vide
Get-ADObject -SearchBase "OU=Test,DC=entreprise,DC=local" -SearchScope OneLevel

# Puis supprimer
Remove-ADOrganizationalUnit -Identity "OU=Test,DC=entreprise,DC=local"
```

**Problème 2 : GPO non appliquée après déplacement d'objets**

```powershell
# Forcer la mise à jour des stratégies de groupe sur un ordinateur
Invoke-GPUpdate -Computer "NomOrdinateur" -Force

# Ou sur un utilisateur
gpupdate /force

# Vérifier les GPO appliquées
gpresult /R
gpresult /H C:\Temp\rapport_gpo.html
```

**Problème 3 : Délégation non fonctionnelle**

```powershell
# Vérifier les ACL effectives pour un utilisateur
$User = "ENTREPRISE\jdupont"
$OU = "OU=Services,DC=entreprise,DC=local"

# Afficher les permissions effectives
(Get-Acl -Path "AD:\$OU").Access | 
    Where-Object {$_.IdentityReference -eq $User} |
    Format-Table IdentityReference, ActiveDirectoryRights, AccessControlType -AutoSize

# Vérifier l'appartenance aux groupes (pour délégation par groupe)
Get-ADUser -Identity jdupont -Properties MemberOf | Select-Object -ExpandProperty MemberOf
```

**Problème 4 : Réplication lente après création d'OU**

```powershell
# Vérifier l'état de la réplication
repadmin /showrepl

# Forcer la réplication depuis tous les DC
repadmin /syncall /AdeP

# Vérifier les objets non répliqués
repadmin /showchanges
```

### Sauvegarde et restauration d'OU

```powershell
# Activer la corbeille Active Directory (si pas déjà fait)
Enable-ADOptionalFeature -Identity "Recycle Bin Feature" `
    -Scope ForestOrConfigurationSet `
    -Target "entreprise.local"

# Restaurer une OU supprimée (avec corbeille activée)
Get-ADObject -Filter 'Name -eq "Services"' -IncludeDeletedObjects | Restore-ADObject

# Restaurer avec tous les objets enfants
Get-ADObject -Filter 'Name -eq "Services"' -IncludeDeletedObjects | Restore-ADObject
Get-ADObject -SearchBase "OU=Services,DC=entreprise,DC=local" `
    -Filter * -IncludeDeletedObjects | Restore-ADObject

# Sauvegarder la structure (export)
Get-ADOrganizationalUnit -Filter * -Properties * | 
    Export-Clixml -Path "C:\Backup\OUs_Backup_$(Get-Date -Format 'yyyyMMdd').xml"

# Documenter la structure complète
$Report = @()
Get-ADOrganizationalUnit -Filter * | ForEach-Object {
    $Report += [PSCustomObject]@{
        Name = $_.Name
        DistinguishedName = $_.DistinguishedName
        Description = $_.Description
        Protected = $_.ProtectedFromAccidentalDeletion
        Created = $_.WhenCreated
        Modified = $_.WhenChanged
        GPOLinks = (Get-GPInheritance -Target $_.DistinguishedName).GpoLinks.DisplayName -join "; "
    }
}
$Report | Export-Excel -Path "C:\Backup\Structure_Complete_$(Get-Date -Format 'yyyyMMdd').xlsx" -AutoSize
```

---

## 📊 Récapitulatif et bonnes pratiques

### Checklist de création d'une structure d'OU

- [ ] **Analyser les besoins** : Départements, sites, applications, sécurité
- [ ] **Choisir le modèle** : Géographique, départemental, hybride
- [ ] **Limiter la profondeur** : Maximum 5 niveaux
- [ ] **Nommer de façon cohérente** : Convention claire et documentée
- [ ] **Protéger les OU** : Activer la protection contre la suppression
- [ ] **Documenter la structure** : Schéma et justification des choix
- [ ] **Planifier les GPO** : Aligner structure et besoins de stratégies
- [ ] **Prévoir la délégation** : Identifier les futurs besoins
- [ ] **Tester en dev** : Valider avant déploiement production
- [ ] **Former les équipes** : Expliquer la logique aux administrateurs

### Commandes PowerShell essentielles - Aide-mémoire

```powershell
# Création
New-ADOrganizationalUnit -Name "NomOU" -Path "DC=domaine,DC=local" -ProtectedFromAccidentalDeletion $true

# Consultation
Get-ADOrganizationalUnit -Filter * | Select Name, DistinguishedName
Get-ADOrganizationalUnit -Filter "Name -like '*IT*'"

# Modification
Set-ADOrganizationalUnit -Identity "OU=Test,DC=domaine,DC=local" -Description "Nouvelle description"

# Déplacement
Move-ADObject -Identity "OU=Source,DC=domaine,DC=local" -TargetPath "OU=Destination,DC=domaine,DC=local"

# Suppression (désactiver protection d'abord)
Set-ADOrganizationalUnit -Identity "OU=Test,DC=domaine,DC=local" -ProtectedFromAccidentalDeletion $false
Remove-ADOrganizationalUnit -Identity "OU=Test,DC=domaine,DC=local"

# Délégation (voir ACL)
$ACL = Get-Acl -Path "AD:\OU=Services,DC=domaine,DC=local"
Set-Acl -Path "AD:\OU=Services,DC=domaine,DC=local" -AclObject $ACL

# Audit
Get-ADOrganizationalUnit -Filter * -Properties * | Export-Csv -Path "audit.csv"
```

### Erreurs à éviter absolument

> [!warning] Top 10 des erreurs à éviter
> 
> 1. **Structure trop profonde** : Plus de 7 niveaux = cauchemar administratif
> 2. **Noms ambigus** : "OU1", "Test", "Temp" sans documentation
> 3. **Pas de protection** : OU non protégées = risque de suppression accidentelle
> 4. **Délégation à des utilisateurs** : Toujours déléguer aux groupes
> 5. **Ignorer l'héritage GPO** : Ne pas comprendre l'impact des GPO parents
> 6. **Modifier en production** : Toujours tester les changements structurels
> 7. **Pas de documentation** : Structure incompréhensible 6 mois plus tard
> 8. **Organisation par personne** : "OU=Jean", "OU=Marie" = mauvaise idée
> 9. **Trop de granularité** : Une OU par utilisateur = overhead inutile
> 10. **Oublier la corbeille AD** : Activer la corbeille pour récupération facilitée

---

## 🎓 Points clés à retenir

> [!tip] Synthèse finale
> 
> - **Les OU sont des conteneurs organisationnels** permettant de structurer AD, appliquer des GPO et déléguer des permissions
> - **La conception doit être simple** : 3-5 niveaux maximum, structure claire et évolutive
> - **La protection est essentielle** : Toujours activer `ProtectedFromAccidentalDeletion`
> - **La délégation suit le principe du moindre privilège** : Accorder uniquement les permissions nécessaires, toujours via des groupes
> - **La structure suit les besoins GPO** : Organiser en fonction des stratégies à appliquer
> - **PowerShell est votre ami** : Automatiser création, modification, audit
> - **La documentation est cruciale** : Une structure non documentée devient ingérable
> - **Tester avant de déployer** : Validation en dev obligatoire
> - **Auditer régulièrement** : Vérifier structure, délégations, objets orphelins

---

> [!info] 📌 Mémo rapide **Création OU** : `New-ADOrganizationalUnit` **Protection** : `-ProtectedFromAccidentalDeletion $true` **Délégation** : Via assistant ou ACL PowerShell **Structure** : Simple, évolutive, alignée sur GPO **Profondeur** : Max 5 niveaux **Nommage** : Cohérent, descriptif, sans espaces