

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

## 🎯 Introduction

L'application et la liaison des GPO constituent le mécanisme central qui détermine **quelles stratégies** s'appliquent à **quels objets** dans Active Directory. Comprendre ce système est essentiel pour gérer efficacement un environnement AD.

> [!info] Concept clé Une GPO n'a aucun effet tant qu'elle n'est pas **liée** à un conteneur (Site, Domaine ou OU). La liaison crée le pont entre la stratégie et les objets ciblés.

---

## 🔗 Liaison des GPO

### Conteneurs de liaison

Les GPO peuvent être liées à trois types de conteneurs dans Active Directory :

|Conteneur|Portée|Cas d'usage typique|
|---|---|---|
|**Site**|Tous les ordinateurs du site physique|Configuration réseau spécifique à un emplacement géographique|
|**Domaine**|Tous les utilisateurs/ordinateurs du domaine|Politiques de sécurité globales, paramètres de base|
|**OU (Unité d'Organisation)**|Objets contenus dans l'OU|Configurations spécifiques par département, service, fonction|

> [!example] Exemple de structuration
> 
> - GPO liée au **domaine** : Politique de mots de passe, paramètres antivirus
> - GPO liée à une **OU "Comptabilité"** : Restriction d'accès aux applications financières
> - GPO liée à un **Site "Paris"** : Configuration des imprimantes locales

### Opérations de liaison

#### Lier une GPO via la console GPMC

```powershell
# Lier une GPO existante à une OU
New-GPLink -Name "GPO-Securite-Serveurs" -Target "OU=Serveurs,DC=entreprise,DC=local"

# Lier avec un ordre spécifique (1 = priorité la plus haute)
New-GPLink -Name "GPO-Config-Bureau" -Target "OU=Utilisateurs,DC=entreprise,DC=local" -LinkEnabled Yes -Order 1

# Désactiver une liaison sans la supprimer
Set-GPLink -Name "GPO-Test" -Target "OU=Dev,DC=entreprise,DC=local" -LinkEnabled No
```

#### États d'une liaison

Une liaison GPO peut avoir plusieurs états :

- **Activée** : La GPO s'applique normalement
- **Désactivée** : La liaison existe mais la GPO n'est pas appliquée
- **Appliquée** (Enforced) : La GPO ne peut pas être bloquée par héritage

> [!warning] Attention Une même GPO peut être liée à **plusieurs conteneurs** simultanément. Cela permet de réutiliser une stratégie sans la dupliquer, mais peut compliquer le dépannage.

---

## 🔄 Ordre d'application et héritage

### Séquence LSDOU

Les GPO s'appliquent dans un ordre précis, connu sous l'acronyme **LSDOU** :

```
L - Local (GPO locale de la machine)
  ↓
S - Site
  ↓
D - Domain (Domaine)
  ↓
OU - Organizational Unit (de la plus haute à la plus basse)
```

> [!info] Principe fondamental Les GPO appliquées **en dernier ont priorité**. Une GPO liée à une OU basse écrase donc les paramètres conflictuels des GPO de niveau supérieur.

#### Exemple de séquence

Pour un utilisateur dans `OU=Commerciaux,OU=Paris,OU=France,DC=entreprise,DC=local` :

1. GPO locale de l'ordinateur
2. GPO liées au Site (ex: Site "Paris-La-Défense")
3. GPO liées au Domaine `entreprise.local`
4. GPO liées à `OU=France`
5. GPO liées à `OU=Paris`
6. GPO liées à `OU=Commerciaux` ← **Priorité maximale**

### Gestion de l'héritage

#### Bloquer l'héritage

Empêche les GPO des niveaux supérieurs de s'appliquer au conteneur.

```powershell
# Bloquer l'héritage sur une OU
Set-GPInheritance -Target "OU=DMZ,DC=entreprise,DC=local" -IsBlocked Yes

# Vérifier l'état de l'héritage
Get-GPInheritance -Target "OU=DMZ,DC=entreprise,DC=local"
```

> [!warning] Usage du blocage d'héritage
> 
> - À utiliser **avec parcimonie**
> - Peut empêcher l'application de politiques de sécurité critiques
> - Complique la gestion et le dépannage
> - Cas légitime : OU de serveurs nécessitant une configuration totalement distincte

#### Appliquer la liaison (Enforced)

Force l'application d'une GPO, même si l'héritage est bloqué en dessous.

```powershell
# Forcer l'application d'une GPO
Set-GPLink -Name "GPO-Securite-Critique" -Target "DC=entreprise,DC=local" -Enforced Yes

# Vérifier les liens forcés
Get-GPInheritance -Target "OU=Serveurs,DC=entreprise,DC=local" | Select-Object -ExpandProperty InheritedGpoLinks | Where-Object {$_.Enforced -eq $true}
```

> [!tip] Bonnes pratiques
> 
> - Utiliser "Enforced" pour les politiques de sécurité non négociables
> - Les GPO "Enforced" sont prioritaires sur toutes les autres, même en bas de l'arborescence
> - Documenter chaque utilisation de "Enforced" dans un registre de gestion

### Résolution des conflits

Lorsque plusieurs GPO configurent le même paramètre :

|Situation|Résultat|
|---|---|
|Paramètres différents sans conflit|Tous s'appliquent (cumul)|
|Paramètres identiques avec la même valeur|Pas de conflit, valeur appliquée|
|Paramètres identiques avec valeurs différentes|La **dernière GPO appliquée** (la plus basse dans LSDOU) l'emporte|
|GPO avec "Enforced" active|La GPO "Enforced" l'emporte, quel que soit l'ordre|

> [!example] Exemple de conflit
> 
> - GPO Domaine : Fond d'écran → `logo_entreprise.jpg`
> - GPO OU Marketing : Fond d'écran → `marketing_banner.jpg`
> 
> **Résultat** : Les utilisateurs de Marketing auront `marketing_banner.jpg` car l'OU est appliquée après le domaine.

#### Ordre au sein d'un même conteneur

Si plusieurs GPO sont liées au même conteneur, un **ordre de liaison** détermine la priorité :

```powershell
# Lister les GPO liées avec leur ordre
Get-GPInheritance -Target "OU=Marketing,DC=entreprise,DC=local" | Select-Object -ExpandProperty GpoLinks

# Modifier l'ordre d'une liaison (1 = priorité la plus haute)
Set-GPLink -Name "GPO-Config-Bureau" -Target "OU=Marketing,DC=entreprise,DC=local" -Order 1
```

> [!info] Ordre de liaison
> 
> - **Ordre 1** = Appliquée en dernier = **Priorité maximale**
> - Plus le numéro est élevé, plus la GPO est appliquée tôt (et peut être écrasée)

---

## 🔒 Filtrage de sécurité

### Principe du filtrage

Le filtrage de sécurité permet de restreindre l'application d'une GPO à des utilisateurs ou groupes spécifiques, même s'ils se trouvent dans un conteneur lié.

> [!info] Mécanisme Pour qu'une GPO s'applique, l'objet doit avoir :
> 
> - **Lecture** (Read) sur la GPO
> - **Appliquer la stratégie de groupe** (Apply Group Policy)
> 
> Par défaut, ces permissions sont accordées au groupe "Utilisateurs authentifiés".

#### Cas d'usage typiques

- Appliquer une GPO uniquement aux membres d'un groupe de sécurité spécifique
- Exclure des administrateurs de certaines restrictions
- Cibler des ordinateurs portables vs postes fixes

### Configuration pratique

#### Méthode 1 : Interface GPMC

1. Ouvrir la console GPMC
2. Sélectionner la GPO → Onglet "Délégation"
3. Dans "Filtrage de sécurité", ajouter/supprimer les groupes

#### Méthode 2 : PowerShell

```powershell
# Supprimer "Utilisateurs authentifiés" du filtrage
Set-GPPermission -Name "GPO-Appli-Specialisee" -TargetName "Utilisateurs authentifiés" -TargetType Group -PermissionLevel None

# Ajouter un groupe avec les permissions nécessaires
Set-GPPermission -Name "GPO-Appli-Specialisee" -TargetName "GRP-Utilisateurs-Finance" -TargetType Group -PermissionLevel GpoApply

# Vérifier les permissions
Get-GPPermission -Name "GPO-Appli-Specialisee" -All | Where-Object {$_.Permission -eq "GpoApply"}
```

> [!example] Exemple concret **Objectif** : Appliquer une GPO de configuration d'application uniquement aux comptables
> 
> 1. Créer un groupe de sécurité `GRP-Comptables`
> 2. Lier la GPO à l'OU `Utilisateurs`
> 3. Configurer le filtrage :
>     - Supprimer "Utilisateurs authentifiés"
>     - Ajouter `GRP-Comptables` avec permission "Appliquer la stratégie de groupe"
> 
> **Résultat** : Seuls les membres de `GRP-Comptables` recevront la GPO, même si d'autres utilisateurs sont dans l'OU.

#### Exclusions spécifiques

Pour exclure un utilisateur ou groupe :

```powershell
# Refuser explicitement l'application d'une GPO
Set-GPPermission -Name "GPO-Restrictions-Bureau" -TargetName "GRP-Administrateurs-IT" -TargetType Group -PermissionLevel GpoDeny
```

> [!warning] Attention au "Deny"
> 
> - La permission "Deny" (Refuser) est **prioritaire** sur "Allow" (Autoriser)
> - Utiliser avec précaution, peut créer des situations complexes
> - Préférer l'approche positive (ne donner l'accès qu'à ceux qui en ont besoin)

### Combinaison avec l'héritage

Le filtrage de sécurité s'applique **après** le calcul de l'héritage :

```
1. Détermination des GPO applicables selon LSDOU
         ↓
2. Vérification des permissions de sécurité
         ↓
3. Application effective des GPO autorisées
```

---

## 🔍 Filtres WMI

### Fonctionnement

Les filtres WMI (Windows Management Instrumentation) permettent de conditionner l'application d'une GPO en fonction de caractéristiques matérielles ou logicielles de la machine cible.

> [!info] Différence avec le filtrage de sécurité
> 
> - **Filtrage de sécurité** : Basé sur l'identité (utilisateur/groupe)
> - **Filtre WMI** : Basé sur des propriétés de l'ordinateur (OS, RAM, disque, etc.)

#### Mécanisme d'évaluation

```
GPO liée à un conteneur
         ↓
Filtre de sécurité validé ?
         ↓ Oui
Filtre WMI attaché ?
         ↓ Oui
Requête WMI vraie pour cette machine ?
         ↓ Oui
Application de la GPO
```

> [!warning] Impact sur les performances
> 
> - Les filtres WMI sont évalués à **chaque actualisation** de GPO
> - Requêtes complexes peuvent ralentir le traitement
> - Limiter l'utilisation aux cas où c'est vraiment nécessaire

### Création et utilisation

#### Créer un filtre WMI

Via la console GPMC :

1. Développer "Filtres WMI"
2. Clic droit → "Nouveau"
3. Nom : `Filtre-Windows11`
4. Description : "Cible uniquement les machines Windows 11"
5. Requête WQL :

```sql
SELECT * FROM Win32_OperatingSystem WHERE Version LIKE "10.0.22%" AND ProductType = "1"
```

#### Via PowerShell

```powershell
# Créer un filtre WMI
$filter = @{
    Name = "Filtre-RAM-Superieure-8Go"
    Description = "Machines avec plus de 8 Go de RAM"
    Filter = "SELECT * FROM Win32_ComputerSystem WHERE TotalPhysicalMemory >= 8589934592"
}

# Note : Pas de cmdlet native pour créer un filtre WMI
# Utilisation de l'API .NET ou création manuelle via GPMC
```

#### Lier un filtre WMI à une GPO

```powershell
# Lier un filtre WMI existant à une GPO
# Via la console GPMC : 
# GPO → Onglet "Portée" → Section "Filtrage WMI" → Sélectionner le filtre
```

> [!tip] Astuce Un filtre WMI peut être réutilisé par **plusieurs GPO**, ce qui évite de dupliquer les requêtes et facilite la maintenance.

### Requêtes WMI utiles

#### Filtrer par version d'OS

```sql
-- Windows 11
SELECT * FROM Win32_OperatingSystem WHERE Version LIKE "10.0.22%" AND ProductType = "1"

-- Windows 10
SELECT * FROM Win32_OperatingSystem WHERE Version LIKE "10.0.19%" AND ProductType = "1"

-- Windows Server 2022
SELECT * FROM Win32_OperatingSystem WHERE Version LIKE "10.0.20%" AND ProductType = "3"
```

> [!info] ProductType
> 
> - `1` = Workstation (poste client)
> - `2` = Domain Controller
> - `3` = Server (serveur membre)

#### Filtrer par type de matériel

```sql
-- Ordinateurs portables
SELECT * FROM Win32_Battery

-- Machines avec plus de 16 Go de RAM
SELECT * FROM Win32_ComputerSystem WHERE TotalPhysicalMemory >= 17179869184

-- Machines avec SSD (nécessite vérification du type de média)
SELECT * FROM Win32_DiskDrive WHERE MediaType = "Fixed hard disk media"
```

#### Filtrer par emplacement réseau

```sql
-- Machines sur un sous-réseau spécifique
SELECT * FROM Win32_NetworkAdapterConfiguration WHERE IPAddress LIKE "192.168.1.%"

-- Machines connectées au domaine
SELECT * FROM Win32_ComputerSystem WHERE PartOfDomain = TRUE
```

#### Filtrer par logiciel installé

```sql
-- Présence d'une application spécifique (exemple : Adobe Reader)
SELECT * FROM Win32_Product WHERE Name LIKE "%Adobe%Reader%"
```

> [!warning] Performance de Win32_Product La classe `Win32_Product` déclenche une vérification complète de tous les packages MSI et peut être **très lente**. Éviter son utilisation dans les filtres WMI en production.

#### Filtrer par architecture

```sql
-- Machines 64 bits
SELECT * FROM Win32_Processor WHERE AddressWidth = "64"

-- Machines 32 bits
SELECT * FROM Win32_Processor WHERE AddressWidth = "32"
```

### Combinaison de critères

```sql
-- Windows 11 ET plus de 8 Go de RAM
SELECT * FROM Win32_OperatingSystem WHERE Version LIKE "10.0.22%" AND ProductType = "1"
AND (SELECT TotalPhysicalMemory FROM Win32_ComputerSystem) >= 8589934592
```

> [!tip] Bonnes pratiques pour les filtres WMI
> 
> - **Tester** les requêtes avec `wmic` avant de les déployer
> - Privilégier les requêtes **simples et rapides**
> - Documenter chaque filtre avec une description claire
> - Utiliser les filtres WMI en **complément** du filtrage de sécurité, pas en remplacement
> - Surveiller l'impact sur les performances d'actualisation des GPO

### Test d'un filtre WMI

Pour tester une requête WMI sur une machine locale :

```powershell
# Tester une requête WMI
Get-WmiObject -Query "SELECT * FROM Win32_OperatingSystem WHERE Version LIKE '10.0.22%'"

# Vérifier la RAM
Get-WmiObject Win32_ComputerSystem | Select-Object TotalPhysicalMemory

# Alternative avec CIM (recommandé)
Get-CimInstance Win32_OperatingSystem | Where-Object {$_.Version -like "10.0.22*"}
```

---

## 📊 Vue d'ensemble du processus d'application

```
[GPO créée dans SYSVOL]
         ↓
[Liaison à un conteneur : Site/Domaine/OU]
         ↓
[Objet dans le conteneur lié]
         ↓
[Calcul de l'héritage : LSDOU]
         ↓
[Vérification filtrage de sécurité]
    ↓ Autorisé ?
    ↓ Oui
[Évaluation filtre WMI (si présent)]
    ↓ Conditions remplies ?
    ↓ Oui
[Application effective de la GPO]
         ↓
[Actualisation : 90 min + 0-30 min aléatoire]
```

> [!tip] Résumé des bonnes pratiques
> 
> **Liaison et héritage :**
> 
> - Structurer les OU de manière logique avant de lier les GPO
> - Minimiser l'utilisation de "Bloquer l'héritage" et "Enforced"
> - Documenter toute exception à la structure d'héritage standard
> 
> **Filtrage de sécurité :**
> 
> - Utiliser des groupes de sécurité dédiés plutôt que des utilisateurs individuels
> - Préférer l'approche "allowlist" plutôt que "denylist"
> - Supprimer "Utilisateurs authentifiés" seulement si nécessaire
> 
> **Filtres WMI :**
> 
> - Réserver aux cas où le filtrage par sécurité est insuffisant
> - Maintenir les requêtes simples pour éviter l'impact sur les performances
> - Tester exhaustivement avant déploiement en production
> - Documenter la logique de chaque filtre

---

## 🔧 Commandes PowerShell de référence

```powershell
# === Gestion des liaisons ===

# Lier une GPO
New-GPLink -Name "GPO-Name" -Target "OU=Users,DC=domain,DC=local" -LinkEnabled Yes

# Modifier l'ordre d'une liaison
Set-GPLink -Name "GPO-Name" -Target "OU=Users,DC=domain,DC=local" -Order 1

# Activer "Enforced" sur une liaison
Set-GPLink -Name "GPO-Name" -Target "OU=Users,DC=domain,DC=local" -Enforced Yes

# Supprimer une liaison
Remove-GPLink -Name "GPO-Name" -Target "OU=Users,DC=domain,DC=local"

# === Gestion de l'héritage ===

# Bloquer l'héritage sur une OU
Set-GPInheritance -Target "OU=DMZ,DC=domain,DC=local" -IsBlocked Yes

# Voir l'héritage effectif
Get-GPInheritance -Target "OU=Users,DC=domain,DC=local"

# === Filtrage de sécurité ===

# Ajouter un groupe avec permission "Apply"
Set-GPPermission -Name "GPO-Name" -TargetName "Group-Name" -TargetType Group -PermissionLevel GpoApply

# Supprimer les permissions par défaut
Set-GPPermission -Name "GPO-Name" -TargetName "Authenticated Users" -TargetType Group -PermissionLevel None

# Lister les permissions
Get-GPPermission -Name "GPO-Name" -All

# === Diagnostic ===

# Voir les GPO appliquées à un utilisateur/ordinateur
gpresult /R /SCOPE:USER
gpresult /R /SCOPE:COMPUTER

# Rapport HTML détaillé
gpresult /H rapport.html /F

# Forcer l'actualisation des GPO
gpupdate /force
```