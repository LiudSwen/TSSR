

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

## 🔰 Introduction aux rôles FSMO

### Qu'est-ce qu'un rôle FSMO ?

FSMO (Flexible Single Master Operations) désigne des rôles spécifiques dans Active Directory qui nécessitent un **maître unique** pour éviter les conflits lors de certaines opérations critiques. Bien qu'Active Directory fonctionne généralement en mode multi-maître (chaque contrôleur de domaine peut écrire), certaines opérations doivent être effectuées par un seul DC à la fois.

> [!info] Contexte historique Les rôles FSMO étaient anciennement appelés "Flexible Single Master Operations" mais Microsoft les appelle désormais "Operations Masters" dans sa documentation récente. Le terme FSMO reste toutefois largement utilisé.

### Pourquoi les rôles FSMO sont-ils importants ?

Sans rôles FSMO, certaines opérations dans AD pourraient créer des conflits :

- Création d'objets avec le même identifiant unique
- Modifications incompatibles du schéma
- Conflits de nommage entre domaines
- Problèmes d'authentification cross-domain
- Incohérences dans les relations d'approbation

> [!warning] Impact de l'indisponibilité La perte d'un rôle FSMO n'affecte pas immédiatement le fonctionnement quotidien d'AD, mais empêche certaines opérations administratives spécifiques. L'impact varie selon le rôle concerné.

---

## 🎭 Les 5 rôles FSMO

Les rôles FSMO se répartissent en deux catégories selon leur portée :

### 🌲 Rôles au niveau de la forêt

Ces rôles existent **une seule fois par forêt** Active Directory.

#### 1. Schema Master (Maître de schéma)

**Fonction :** Gère toutes les modifications du schéma Active Directory.

Le schéma définit la structure des objets AD (classes, attributs). Toute modification du schéma doit passer par ce rôle.

**Opérations concernées :**

- Modification des classes d'objets
- Ajout ou modification d'attributs
- Extension du schéma (par exemple lors de l'installation d'Exchange)
- Mise à jour du schéma lors d'une mise à niveau AD

**Impact de l'indisponibilité :**

- ⚠️ **Faible** pour les opérations quotidiennes
- ❌ Impossible de modifier le schéma
- ❌ Impossible d'installer certaines applications (Exchange, Skype for Business)

> [!tip] Astuce Ce rôle est rarement sollicité. Il est recommandé de le placer sur un DC stable et peu sollicité, idéalement au même endroit que le Domain Naming Master.

#### 2. Domain Naming Master (Maître de nommage de domaine)

**Fonction :** Contrôle l'ajout et la suppression de domaines dans la forêt.

Ce rôle garantit l'unicité des noms de domaine et gère les références croisées entre domaines.

**Opérations concernées :**

- Création d'un nouveau domaine dans la forêt
- Suppression d'un domaine
- Ajout ou suppression de partitions d'application
- Gestion des références croisées (crossRef objects)

**Impact de l'indisponibilité :**

- ⚠️ **Faible** pour les opérations quotidiennes
- ❌ Impossible d'ajouter ou supprimer des domaines
- ❌ Impossible de créer des partitions d'application

> [!info] Prérequis Le DC hébergeant ce rôle doit également être un serveur de catalogue global (GC) pour maintenir une vue complète de la forêt.

---

### 🏢 Rôles au niveau du domaine

Ces rôles existent **une fois par domaine** dans la forêt.

#### 3. RID Master (Maître RID)

**Fonction :** Alloue des pools de RID (Relative Identifier) aux contrôleurs de domaine.

Chaque objet dans AD possède un SID (Security Identifier) unique composé du SID du domaine + un RID. Le RID Master distribue des blocs de RID aux DC pour éviter les doublons.

**Opérations concernées :**

- Allocation de pools RID aux contrôleurs de domaine
- Création d'objets de sécurité (utilisateurs, groupes, ordinateurs)
- Déplacement d'objets entre domaines

**Impact de l'indisponibilité :**

- ⚠️ **Moyen** à court terme
- ✅ Les DC continuent de créer des objets avec leur pool existant
- ❌ Impossible d'obtenir de nouveaux RID quand le pool est épuisé (généralement 500 RID par pool)
- ❌ Impossible de déplacer des objets entre domaines

> [!warning] Surveillance importante Surveillez l'épuisement des pools RID sur vos DC. Par défaut, un DC reçoit 500 RID et en demande de nouveaux à 50% de consommation. Si le RID Master est indisponible et que les pools s'épuisent, la création d'objets devient impossible.

**Vérifier le pool RID disponible :**

```powershell
# Vérifier le pool RID restant sur un DC
dcdiag /test:ridmanager /v

# Voir les RID alloués et disponibles
Get-ADDomainController | ForEach-Object {
    $dc = $_.Name
    $ridAvailable = (Get-WmiObject -Class Win32_NTDomain -ComputerName $dc).RIDsRemaining
    [PSCustomObject]@{
        DC = $dc
        RIDsRemaining = $ridAvailable
    }
}
```

#### 4. PDC Emulator (Émulateur PDC)

**Fonction :** Le rôle le plus sollicité, assurant plusieurs fonctions critiques.

C'est le rôle FSMO le plus important au quotidien car il intervient dans de nombreuses opérations.

**Opérations concernées :**

1. **Gestion des mots de passe :**
    
    - Réception prioritaire des changements de mots de passe
    - Gestion des verrouillages de compte
    - Point de référence pour l'authentification en cas d'échec
2. **Synchronisation du temps :**
    
    - Source de temps faisant autorité pour le domaine
    - Synchronise l'horloge de tous les membres du domaine
3. **Stratégies de groupe :**
    
    - Autorité finale pour les modifications de GPO
    - Point de référence pour l'évaluation des GPO
4. **Compatibilité :**
    
    - Émulation du rôle PDC pour les clients Windows NT 4.0 (legacy)

**Impact de l'indisponibilité :**

- ⚠️ **Élevé** pour les opérations quotidiennes
- ❌ Problèmes d'authentification lors de changements de mot de passe récents
- ❌ Verrouillages de compte mal gérés (faux négatifs)
- ❌ Désynchronisation horaire du domaine
- ❌ Modifications de GPO non fiables
- ⚠️ Dégradation des performances d'authentification

> [!warning] Rôle critique Le PDC Emulator est le rôle FSMO le plus critique. Son indisponibilité affecte directement les utilisateurs. Placez-le sur votre DC le plus performant et le plus fiable.

**Exemple de flux d'authentification :**

```
1. Utilisateur tente de se connecter → DC1
2. DC1 valide le mot de passe → ❌ Échec
3. DC1 contacte le PDC Emulator → Vérification finale
4. PDC Emulator valide → ✅ Succès (mot de passe récemment changé)
```

> [!tip] Synchronisation NTP Configurez le PDC Emulator pour synchroniser son horloge avec une source externe fiable (serveur NTP) :
> 
> ```powershell
> w32tm /config /manualpeerlist:"pool.ntp.org" /syncfromflags:manual /reliable:YES /update
> w32tm /resync
> ```

#### 5. Infrastructure Master (Maître d'infrastructure)

**Fonction :** Maintient les références aux objets d'autres domaines (SID et GUID).

Ce rôle met à jour les références entre domaines, notamment pour les membres de groupes provenant d'autres domaines.

**Opérations concernées :**

- Mise à jour des SID dans les listes de membres de groupes multi-domaines
- Traduction des GUID et SID entre domaines
- Synchronisation des noms d'objets cross-domain

**Impact de l'indisponibilité :**

- ⚠️ **Faible** en environnement mono-domaine
- ⚠️ **Moyen** en environnement multi-domaine
- ❌ Affichage incorrect des membres de groupes provenant d'autres domaines
- ❌ Références obsolètes aux objets déplacés ou renommés

> [!warning] Restriction importante L'Infrastructure Master **NE DOIT PAS** être hébergé sur un serveur de catalogue global (GC), sauf si **tous** les DC du domaine sont des GC. Sinon, le rôle ne pourra pas détecter les objets obsolètes.

**Pourquoi cette restriction ?**

Un GC contient une copie partielle de tous les objets de la forêt. Si l'Infrastructure Master est sur un GC, il "voit" déjà tous les objets et ne détecte jamais qu'ils sont obsolètes dans son propre domaine.

```
Scénario problématique :
- Infrastructure Master sur GC
- Utilisateur du domaine B ajouté à un groupe du domaine A
- L'utilisateur est renommé dans le domaine B
- Infrastructure Master sur GC voit le nouvel nom directement
- Aucune mise à jour n'est propagée aux autres DC du domaine A
- Les autres DC affichent l'ancien nom
```

> [!tip] Configuration recommandée
> 
> - **Mono-domaine :** Aucune importance, tous les DC peuvent être GC
> - **Multi-domaine :** Placez l'Infrastructure Master sur un DC non-GC, ou activez GC sur tous les DC

---

## 🔍 Localisation des rôles FSMO

### Méthodes de vérification

#### Méthode 1 : PowerShell (recommandé)

```powershell
# Vérifier tous les rôles FSMO de la forêt et du domaine
Get-ADForest | Select-Object SchemaMaster, DomainNamingMaster
Get-ADDomain | Select-Object PDCEmulator, RIDMaster, InfrastructureMaster

# Vue consolidée avec un seul affichage
[PSCustomObject]@{
    "Schema Master" = (Get-ADForest).SchemaMaster
    "Domain Naming Master" = (Get-ADForest).DomainNamingMaster
    "PDC Emulator" = (Get-ADDomain).PDCEmulator
    "RID Master" = (Get-ADDomain).RIDMaster
    "Infrastructure Master" = (Get-ADDomain).InfrastructureMaster
}

# Version détaillée avec niveau et domaine
$forest = Get-ADForest
$domain = Get-ADDomain

Write-Host "`n=== Rôles FSMO au niveau FORÊT ===" -ForegroundColor Cyan
Write-Host "Schema Master          : $($forest.SchemaMaster)"
Write-Host "Domain Naming Master   : $($forest.DomainNamingMaster)"

Write-Host "`n=== Rôles FSMO au niveau DOMAINE ===" -ForegroundColor Yellow
Write-Host "Domaine                : $($domain.DNSRoot)"
Write-Host "PDC Emulator           : $($domain.PDCEmulator)"
Write-Host "RID Master             : $($domain.RIDMaster)"
Write-Host "Infrastructure Master  : $($domain.InfrastructureMaster)"
```

#### Méthode 2 : Netdom (ligne de commande classique)

```cmd
REM Afficher tous les rôles FSMO
netdom query fsmo

REM Sortie typique :
REM Schema master               DC01.contoso.com
REM Domain naming master        DC01.contoso.com
REM PDC                         DC01.contoso.com
REM RID pool manager            DC01.contoso.com
REM Infrastructure master       DC02.contoso.com
```

#### Méthode 3 : Outils graphiques

**Pour le Schema Master :**

```powershell
# Enregistrer le snap-in (une seule fois)
regsvr32 schmmgmt.dll

# Ouvrir la console
mmc
# Fichier > Ajouter/Supprimer un composant logiciel enfichable
# Sélectionner "Schéma Active Directory"
# Clic droit sur "Schéma Active Directory" > Maître d'opérations
```

**Pour le Domain Naming Master :**

- Ouvrir "Domaines et approbations Active Directory"
- Clic droit sur "Domaines et approbations Active Directory" (racine)
- "Maître d'opérations"

**Pour PDC Emulator, RID Master, Infrastructure Master :**

- Ouvrir "Utilisateurs et ordinateurs Active Directory"
- Clic droit sur le domaine
- "Maître d'opérations"
- Trois onglets pour les trois rôles

#### Méthode 4 : dcdiag (diagnostic)

```powershell
# Tester tous les rôles FSMO
dcdiag /test:knowsofroleholders /v

# Tester un rôle spécifique (par exemple RID)
dcdiag /test:ridmanager /v
```

---

## 🔄 Transfert des rôles FSMO

Le **transfert** est une opération **gracieuse** et **planifiée** où les deux contrôleurs de domaine (source et cible) sont en ligne et communiquent.

### Quand effectuer un transfert ?

- Maintenance planifiée d'un DC
- Décommissionnement d'un DC
- Rééquilibrage de la charge
- Mise à niveau d'un serveur
- Amélioration de la topologie

> [!info] Transfert vs Saisie
> 
> - **Transfert** : Opération normale et sûre, les deux DC sont en ligne
> - **Saisie** : Opération d'urgence, le DC source est hors ligne ou inaccessible

### Prérequis pour un transfert

1. Les deux DC doivent être en ligne et accessibles
2. La réplication entre les DC doit être fonctionnelle
3. Vous devez disposer des droits appropriés :
    - **Schema Master** : Admins du schéma
    - **Domain Naming Master** : Administrateurs de l'entreprise
    - **PDC, RID, Infrastructure** : Admins du domaine

### Méthode 1 : PowerShell (recommandé)

```powershell
# 1. Se connecter au DC CIBLE (qui recevra les rôles)
Enter-PSSession -ComputerName DC02

# 2. Transférer le rôle PDC Emulator
Move-ADDirectoryServerOperationMasterRole -Identity "DC02" -OperationMasterRole PDCEmulator

# 3. Transférer le rôle RID Master
Move-ADDirectoryServerOperationMasterRole -Identity "DC02" -OperationMasterRole RIDMaster

# 4. Transférer le rôle Infrastructure Master
Move-ADDirectoryServerOperationMasterRole -Identity "DC02" -OperationMasterRole InfrastructureMaster

# 5. Transférer le rôle Domain Naming Master
Move-ADDirectoryServerOperationMasterRole -Identity "DC02" -OperationMasterRole DomainNamingMaster

# 6. Transférer le rôle Schema Master
Move-ADDirectoryServerOperationMasterRole -Identity "DC02" -OperationMasterRole SchemaMaster

# Transférer TOUS les rôles en une seule commande (attention !)
Move-ADDirectoryServerOperationMasterRole -Identity "DC02" -OperationMasterRole @(
    "PDCEmulator",
    "RIDMaster",
    "InfrastructureMaster",
    "DomainNamingMaster",
    "SchemaMaster"
)
```

> [!warning] Confirmation requise Par défaut, PowerShell demande confirmation pour chaque transfert. Pour forcer sans confirmation :
> 
> ```powershell
> Move-ADDirectoryServerOperationMasterRole -Identity "DC02" -OperationMasterRole PDCEmulator -Force
> ```

### Méthode 2 : Ntdsutil (classique)

```cmd
REM Ouvrir une invite de commandes en tant qu'administrateur
ntdsutil

REM Session ntdsutil interactive :
roles
connections
connect to server DC02
quit

REM Transférer les rôles (choisir l'option appropriée)
transfer schema master
transfer naming master
transfer PDC
transfer RID master
transfer infrastructure master

REM Quitter
quit
quit
```

### Méthode 3 : Interfaces graphiques

**Pour PDC Emulator, RID Master, Infrastructure Master :**

1. Ouvrir "Utilisateurs et ordinateurs Active Directory"
2. Clic droit sur le domaine → "Maître d'opérations"
3. Sélectionner l'onglet du rôle à transférer
4. Cliquer sur "Modifier"
5. Confirmer le transfert

**Pour Domain Naming Master :**

1. Ouvrir "Domaines et approbations Active Directory"
2. Clic droit sur la racine → "Maître d'opérations"
3. Cliquer sur "Modifier"

**Pour Schema Master :**

1. Ouvrir la console Schéma Active Directory (schmmgmt.dll)
2. Clic droit sur "Schéma Active Directory" → "Changer de contrôleur de domaine Active Directory"
3. Sélectionner le DC cible
4. Clic droit → "Maître d'opérations" → "Modifier"

### Vérification post-transfert

```powershell
# Vérifier que les rôles ont bien été transférés
Get-ADDomain | Select-Object PDCEmulator, RIDMaster, InfrastructureMaster
Get-ADForest | Select-Object SchemaMaster, DomainNamingMaster

# Vérifier la réplication
repadmin /replsummary

# Vérifier les événements dans l'observateur d'événements
# Rechercher Event ID 1963-1967 (transfert de rôles FSMO)
Get-EventLog -LogName "Directory Service" -After (Get-Date).AddHours(-1) | 
    Where-Object {$_.EventID -ge 1963 -and $_.EventID -le 1967}
```

---

## ⚡ Saisie des rôles FSMO

La **saisie** (seizure) est une opération **forcée** utilisée en cas d'urgence lorsque le DC hébergeant un rôle FSMO est définitivement hors ligne ou inaccessible.

> [!warning] Opération d'urgence uniquement La saisie est une opération destructive. N'utilisez-la que si :
> 
> - Le DC source est définitivement perdu (panne matérielle, corruption)
> - Le DC source ne reviendra jamais en ligne
> - Vous avez tenté toutes les solutions de récupération
> 
> **Si le DC source revient en ligne après une saisie, il causera des conflits graves !**

### Quand effectuer une saisie ?

✅ **Situations justifiant une saisie :**

- Panne matérielle irréparable du DC
- Corruption totale d'Active Directory sur le DC
- Destruction physique du serveur (incendie, inondation)
- Le DC est perdu et ne reviendra jamais

❌ **Situations où il faut éviter la saisie :**

- Problème réseau temporaire
- DC en maintenance planifiée
- Possibilité de restaurer le DC
- Le DC pourrait revenir en ligne

### Conséquences d'une saisie

1. **Le DC source devient inutilisable** : Si le DC source revient en ligne, il doit être rétrogradé et supprimé d'AD
2. **Perte de données potentielle** : Les modifications non répliquées depuis le DC source sont perdues
3. **Nettoyage manuel requis** : Les métadonnées du DC source doivent être nettoyées

### Procédure de saisie avec PowerShell

```powershell
# ÉTAPE 1 : Vérifier les rôles actuels
Get-ADDomain | Select-Object PDCEmulator, RIDMaster, InfrastructureMaster
Get-ADForest | Select-Object SchemaMaster, DomainNamingMaster

# ÉTAPE 2 : Se connecter au DC qui prendra les rôles
# (Doit être sur ce DC pour effectuer la saisie)

# ÉTAPE 3 : Saisir les rôles (ajouter -Force pour saisie)
Move-ADDirectoryServerOperationMasterRole `
    -Identity "DC02" `
    -OperationMasterRole PDCEmulator, RIDMaster, InfrastructureMaster `
    -Force

# Pour les rôles au niveau forêt (nécessite droits Admins Entreprise)
Move-ADDirectoryServerOperationMasterRole `
    -Identity "DC02" `
    -OperationMasterRole SchemaMaster, DomainNamingMaster `
    -Force

# Saisir TOUS les rôles en une fois
Move-ADDirectoryServerOperationMasterRole `
    -Identity "DC02" `
    -OperationMasterRole @(
        "PDCEmulator",
        "RIDMaster", 
        "InfrastructureMaster",
        "DomainNamingMaster",
        "SchemaMaster"
    ) -Force
```

### Procédure de saisie avec Ntdsutil

```cmd
REM Ouvrir une invite de commandes en administrateur sur le DC CIBLE
ntdsutil

REM Session interactive
roles
connections
connect to server DC02
quit

REM Saisir les rôles (utiliser 'seize' au lieu de 'transfer')
seize schema master
seize naming master
seize PDC
seize RID master
seize infrastructure master

REM Confirmer chaque saisie avec 'Yes'
REM Quitter
quit
quit
```

### Nettoyage après saisie

Une fois la saisie effectuée, vous **DEVEZ** nettoyer les métadonnées du DC défaillant :

```powershell
# ÉTAPE 1 : Identifier le DC à supprimer
Get-ADDomainController -Filter * | Select-Object Name, Enabled, IPv4Address

# ÉTAPE 2 : Supprimer les métadonnées du DC mort
# Remplacer DC01 par le nom du DC défaillant
Remove-ADDomainController -Identity "DC01" -Credential (Get-Credential)

# ÉTAPE 3 : Nettoyer les enregistrements DNS obsolètes
# Dans la console DNS, supprimer manuellement les enregistrements du DC

# ÉTAPE 4 : Vérifier qu'il n'y a plus de références au DC mort
Get-ADDomainController -Filter {Name -eq "DC01"}

# ÉTAPE 5 : Forcer la réplication pour propager les changements
repadmin /syncall /AdeP
```

### Méthode alternative avec Ntdsutil (nettoyage métadonnées)

```cmd
REM Sur n'importe quel DC restant
ntdsutil
metadata cleanup
connections
connect to server DC02
quit

REM Sélectionner le serveur à supprimer
select operation target
list sites
select site 0
list servers in site
select server <numéro du DC à supprimer>
quit

REM Supprimer le serveur
remove selected server

REM Quitter
quit
quit
```

### Vérifications post-saisie

```powershell
# 1. Vérifier que les rôles sont bien sur le nouveau DC
Get-ADDomain | Format-List PDCEmulator, RIDMaster, InfrastructureMaster
Get-ADForest | Format-List SchemaMaster, DomainNamingMaster

# 2. Vérifier la réplication
repadmin /replsummary
repadmin /showrepl

# 3. Tester les rôles FSMO
dcdiag /test:knowsofroleholders /v
dcdiag /test:ridmanager /v

# 4. Vérifier qu'aucun DC mort n'apparaît
Get-ADDomainController -Filter * | Select-Object Name, Enabled, Site

# 5. Vérifier les événements système
Get-EventLog -LogName "Directory Service" -Newest 50 | 
    Where-Object {$_.EventID -in 1963..1967 -or $_.EventID -eq 2042}
```

> [!warning] Si le DC source réapparaît Si le DC d'origine revient en ligne après une saisie de rôles :
> 
> 1. **NE PAS** le laisser se reconnecter au domaine
> 2. Le démarrer en mode DSRM (Directory Services Restore Mode)
> 3. Le rétrograder complètement (dcpromo)
> 4. Le reformater et le réinstaller
> 
> Sinon, vous aurez des conflits de rôles FSMO qui corrompront Active Directory.

---

## ✅ Bonnes pratiques

### Distribution des rôles

|Rôle|Placement recommandé|Raison|
|---|---|---|
|**PDC Emulator**|DC le plus performant et disponible|Rôle le plus sollicité, impact direct utilisateurs|
|**RID Master**|Même DC que PDC Emulator|Souvent sollicité ensemble|
|**Infrastructure Master**|DC non-GC (sauf si tous sont GC)|Restriction technique obligatoire|
|**Schema Master**|DC stable, peu sollicité|Rarement utilisé, peut être sur DC secondaire|
|**Domain Naming Master**|Même DC que Schema Master|Rarement utilisés, administration simplifiée|

### Schéma de répartition typique

**Petite organisation (2-3 DC) :**

```
DC01 (siège social - performant) :
├── PDC Emulator
├── RID Master
├── Schema Master
└── Domain Naming Master

DC02 (site distant) :
└── Infrastructure Master (pas de GC)
```

**Organisation moyenne (4+ DC) :**

```
DC01 (datacenter principal) :
├── PDC Emulator
└── RID Master

DC02 (datacenter principal) :
├── Infrastructure Master
└── GC: Non

DC03 (site secondaire) :
├── Schema Master
└── Domain Naming Master
```

### Surveillance et maintenance

#### 1. Surveiller l'état des rôles FSMO

```powershell
# Script de surveillance quotidien
$fsmoCheck = [PSCustomObject]@{
    Date = Get-Date
    SchemaMaster = (Get-ADForest).SchemaMaster
    DomainNamingMaster = (Get-ADForest).DomainNamingMaster
    PDCEmulator = (Get-ADDomain).PDCEmulator
    RIDMaster = (Get-ADDomain).RIDMaster
    InfrastructureMaster = (Get-ADDomain).InfrastructureMaster
}

# Tester la connectivité
$fsmoCheck | Get-Member -MemberType NoteProperty | 
    Where-Object {$_.Name -ne "Date"} | 
    ForEach-Object {
        $role = $_.Name
        $server = $fsmoCheck.$role
        $ping = Test-Connection -ComputerName $server -Count 1 -Quiet
        Write-Host "$role ($server) : $(if($ping){'✅ OK'}else{'❌ OFFLINE'})"
    }
```

#### 2. Surveiller le pool RID

```powershell
# Alerte si moins de 100 RID disponibles
$ridThreshold = 100
dcdiag /test:ridmanager /v | Select-String "Available RID Pool"

# Vérification avancée
Get-ADDomainController -Filter * | ForEach-Object {
    $dc = $_.HostName
    # Récupérer le pool RID disponible (nécessite interrogation WMI ou LDAP)
    Write-Host "Vérification du pool RID sur $dc"
}
```

#### 3. Documenter les changements

Maintenez un fichier de documentation avec :

- Date et heure de chaque transfert/saisie
- Raison du changement
- Ancien et nouveau titulaire du rôle
- Nom de l'administrateur ayant effectué l'opération

### Plan de reprise après sinistre

> [!tip] Plan de sauvegarde FSMO Documentez votre plan de récupération :
> 
> 1. **Liste des DC par priorité** : Quel DC prendra quel rôle en cas de sinistre
> 2. **Procédures de saisie** : Scripts prêts à l'emploi
> 3. **Contacts d'urgence** : Qui peut autoriser une saisie
> 4. **Sauvegardes AD** : System State backup de tous les DC hébergeant des rôles FSMO
> 5. **Tests réguliers** : Simuler un transfert de rôles au moins une fois par an

#### Exemple de procédure d'urgence

```powershell
# Script d'urgence : Saisie de tous les rôles FSMO
# À UTILISER UNIQUEMENT SI LE DC SOURCE EST DÉFINITIVEMENT PERDU

# 1. Vérifier l'état actuel
Write-Host "=== ÉTAT ACTUEL DES RÔLES FSMO ===" -ForegroundColor Red
Get-ADForest | Select-Object SchemaMaster, DomainNamingMaster
Get-ADDomain | Select-Object PDCEmulator, RIDMaster, InfrastructureMaster

# 2. Demander confirmation
$confirmation = Read-Host "Le DC source est-il DÉFINITIVEMENT perdu ? (oui/non)"
if ($confirmation -ne "oui") {
    Write-Host "Opération annulée. Envisagez un transfert gracieux." -ForegroundColor Yellow
    exit
}

# 3. Saisir tous les rôles
Write-Host "`nSaisie des rôles FSMO en cours..." -ForegroundColor Yellow
$targetDC = $env:COMPUTERNAME

try {
    Move-ADDirectoryServerOperationMasterRole `
        -Identity $targetDC `
        -OperationMasterRole PDCEmulator, RIDMaster, InfrastructureMaster, DomainNamingMaster, SchemaMaster `
        -Force `
        -Confirm:$false
    
    Write-Host "`n✅ Saisie réussie !" -ForegroundColor Green
} catch {
    Write-Host "`n❌ Erreur lors de la saisie : $_" -ForegroundColor Red
    exit
}

# 4. Vérifier les nouveaux rôles
Write-Host "`n=== NOUVEAUX TITULAIRES DES RÔLES ===" -ForegroundColor Green
Get-ADForest | Select-Object SchemaMaster, DomainNamingMaster
Get-ADDomain | Select-Object PDCEmulator, RIDMaster, InfrastructureMaster

Write-Host "`n⚠️ N'OUBLIEZ PAS de nettoyer les métadonnées du DC défaillant !" -ForegroundColor Red
```

### Sauvegarde préventive

Avant toute opération sur les rôles FSMO, effectuez une sauvegarde :

```powershell
# Sauvegarder l'état système (System State) d'un DC
wbadmin start systemstatebackup -backupTarget:E: -quiet

# Vérifier les sauvegardes disponibles
wbadmin get versions -backupTarget:E:

# Restaurer en cas de problème
wbadmin start systemstaterecovery -version:MM/JJ/AAAA-HH:MM -backupTarget:E:
```

### Pièges courants à éviter

> [!warning] Erreurs fréquentes

**1. Placer l'Infrastructure Master sur un GC en multi-domaine**

```
❌ Infrastructure Master sur DC-GC01 (qui est aussi GC)
   → Le rôle ne fonctionne pas correctement

✅ Infrastructure Master sur DC02 (qui n'est PAS GC)
   → Le rôle fonctionne correctement
```

**2. Oublier de nettoyer les métadonnées après une saisie**

```
Conséquence : Le DC mort reste référencé dans AD
→ Erreurs de réplication
→ Échecs d'authentification
→ Problèmes de GPO
```

**3. Ne pas vérifier la réplication avant un transfert**

```powershell
# Toujours vérifier AVANT le transfert
repadmin /replsummary
repadmin /showrepl

# S'assurer qu'il n'y a pas d'erreurs de réplication
```

**4. Transférer tous les rôles sur un seul DC**

```
❌ Mettre les 5 rôles sur DC01
   → Point unique de défaillance (SPOF)

✅ Répartir les rôles entre DC01 et DC02
   → Résilience améliorée
```

**5. Ne pas tester la synchronisation NTP après transfert du PDC Emulator**

```powershell
# Toujours vérifier après transfert du PDC Emulator
w32tm /query /status
w32tm /monitor
```

### Scénarios de dépannage

#### Scénario 1 : Le PDC Emulator ne répond plus

**Symptômes :**

- Échecs d'authentification sporadiques
- Verrouillages de comptes non détectés
- Désynchronisation horaire

**Diagnostic :**

```powershell
# Vérifier la connectivité
Test-Connection -ComputerName (Get-ADDomain).PDCEmulator

# Vérifier les services
Get-Service -ComputerName (Get-ADDomain).PDCEmulator -Name NTDS, DNS, Netlogon

# Vérifier la réplication
repadmin /showrepl (Get-ADDomain).PDCEmulator
```

**Solution :**

```powershell
# Si temporaire : redémarrer les services
Restart-Service -Name NTDS -ComputerName (Get-ADDomain).PDCEmulator

# Si permanent : transférer le rôle
Move-ADDirectoryServerOperationMasterRole -Identity "DC02" -OperationMasterRole PDCEmulator
```

#### Scénario 2 : Épuisement du pool RID

**Symptômes :**

- Impossible de créer de nouveaux utilisateurs/groupes
- Erreur : "Le serveur n'est pas opérationnel"

**Diagnostic :**

```powershell
dcdiag /test:ridmanager /v

# Vérifier le pool disponible
# Si < 50 RID, c'est critique
```

**Solution :**

```powershell
# Vérifier que le RID Master est accessible
Test-Connection -ComputerName (Get-ADDomain).RIDMaster

# Si inaccessible, transférer/saisir le rôle immédiatement
Move-ADDirectoryServerOperationMasterRole -Identity "DC02" -OperationMasterRole RIDMaster -Force

# Forcer l'allocation d'un nouveau pool
# Se connecter au DC et exécuter :
repadmin /syncall /AdeP
```

#### Scénario 3 : Conflit de rôles FSMO après restauration

**Symptômes :**

- Deux DC prétendent avoir le même rôle
- Erreurs de réplication 8606 (conflits d'attributs)

**Diagnostic :**

```powershell
# Vérifier sur plusieurs DC
Get-ADDomainController -Filter * | ForEach-Object {
    $dc = $_.HostName
    Write-Host "`n=== $dc ==="
    Invoke-Command -ComputerName $dc -ScriptBlock {
        Get-ADDomain | Select-Object PDCEmulator, RIDMaster
    }
}
```

**Solution :**

```powershell
# 1. Identifier le DC légitime (généralement le plus récent)
# 2. Sur le DC illégitime, forcer l'abandon du rôle
ntdsutil
metadata cleanup
connections
connect to server DC_ILLEGITIME
quit
transfer PDC
# etc.

# 3. Forcer la réplication
repadmin /syncall /AdeP
```

### Optimisation des performances

#### Placement optimal selon la charge

**PDC Emulator :**

```
Critères de placement :
✅ CPU puissant (gère beaucoup de requêtes)
✅ RAM suffisante (cache d'authentification)
✅ Disque rapide (logs d'événements)
✅ Connectivité réseau optimale
✅ Proximité des utilisateurs principaux
```

**RID Master :**

```
Critères de placement :
✅ Disponibilité élevée
✅ Peut être co-localisé avec PDC Emulator
⚠️ Surveiller le pool RID régulièrement
```

**Infrastructure Master :**

```
Critères de placement :
✅ NE PAS placer sur un GC (si multi-domaine)
✅ Charge relativement faible
✅ Peut être sur un DC secondaire
```

#### Surveillance proactive avec tâches planifiées

```powershell
# Créer un script de surveillance quotidien
$scriptPath = "C:\Scripts\Monitor-FSMO.ps1"

$scriptContent = @'
# Script de surveillance FSMO
$results = @()

# Vérifier la disponibilité de chaque rôle
$forest = Get-ADForest
$domain = Get-ADDomain

$roles = @{
    "Schema Master" = $forest.SchemaMaster
    "Domain Naming Master" = $forest.DomainNamingMaster
    "PDC Emulator" = $domain.PDCEmulator
    "RID Master" = $domain.RIDMaster
    "Infrastructure Master" = $domain.InfrastructureMaster
}

foreach ($role in $roles.GetEnumerator()) {
    $server = $role.Value
    $ping = Test-Connection -ComputerName $server -Count 2 -Quiet
    
    $results += [PSCustomObject]@{
        Role = $role.Key
        Server = $server
        Status = if($ping) {"OK"} else {"OFFLINE"}
        Date = Get-Date
    }
}

# Envoyer un email si problème détecté
$offline = $results | Where-Object {$_.Status -eq "OFFLINE"}
if ($offline) {
    $body = $offline | Format-Table | Out-String
    Send-MailMessage -To "admin@contoso.com" -From "monitoring@contoso.com" `
        -Subject "⚠️ Alerte FSMO - Rôle indisponible" -Body $body -SmtpServer "smtp.contoso.com"
}

# Sauvegarder dans un log
$results | Export-Csv "C:\Logs\FSMO-$(Get-Date -Format 'yyyyMMdd').csv" -Append -NoTypeInformation
'@

# Créer le script
$scriptContent | Out-File -FilePath $scriptPath -Encoding UTF8

# Créer une tâche planifiée
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File $scriptPath"
$trigger = New-ScheduledTaskTrigger -Daily -At 8am
Register-ScheduledTask -TaskName "Monitor-FSMO" -Action $action -Trigger $trigger -RunLevel Highest
```

### Checklist complète

#### Avant un transfert planifié

- [ ] Vérifier la réplication entre tous les DC
- [ ] Confirmer que les deux DC sont en ligne
- [ ] Sauvegarder le System State du DC source
- [ ] Documenter les rôles actuels
- [ ] Planifier une fenêtre de maintenance
- [ ] Informer les équipes concernées
- [ ] Préparer la procédure de rollback

#### Pendant le transfert

- [ ] Exécuter les commandes de transfert
- [ ] Vérifier immédiatement les nouveaux titulaires
- [ ] Tester la réplication
- [ ] Vérifier les logs d'événements (Event ID 1963-1967)
- [ ] Documenter l'opération effectuée

#### Après le transfert

- [ ] Vérifier le bon fonctionnement des services AD
- [ ] Tester l'authentification des utilisateurs
- [ ] Vérifier la synchronisation NTP (si PDC Emulator transféré)
- [ ] Surveiller les erreurs pendant 24-48h
- [ ] Mettre à jour la documentation
- [ ] Archiver les logs de l'opération

---

## 📊 Tableau récapitulatif des rôles FSMO

|Rôle|Niveau|Nombre|Critique|Impact indispo.|Peut être sur GC|
|---|---|---|---|---|---|
|**Schema Master**|Forêt|1|⚠️ Faible|Modifications schéma impossibles|✅ Oui|
|**Domain Naming Master**|Forêt|1|⚠️ Faible|Ajout/suppression domaines impossible|✅ Oui (obligatoire)|
|**PDC Emulator**|Domaine|1/domaine|🔴 Élevé|Authentification, temps, GPO affectés|✅ Oui|
|**RID Master**|Domaine|1/domaine|⚠️ Moyen|Création objets impossible (à terme)|✅ Oui|
|**Infrastructure Master**|Domaine|1/domaine|⚠️ Faible|Références cross-domain obsolètes|❌ Non (multi-domaine)|

---

## 🎓 Points clés à retenir

> [!tip] L'essentiel sur les rôles FSMO

1. **5 rôles FSMO** répartis en 2 niveaux :
    
    - Forêt : Schema Master, Domain Naming Master
    - Domaine : PDC Emulator, RID Master, Infrastructure Master
2. **PDC Emulator** est le rôle le plus critique (authentification, temps, GPO)
    
3. **Infrastructure Master** ne doit PAS être sur un GC (sauf si tous les DC sont GC)
    
4. **Transfert** = opération gracieuse planifiée (les deux DC en ligne)
    
5. **Saisie** = opération d'urgence forcée (DC source définitivement perdu)
    
6. **Toujours nettoyer** les métadonnées après une saisie
    
7. **Surveiller régulièrement** la disponibilité et l'état des rôles
    
8. **Documenter** tous les changements et maintenir un plan de reprise
    

---

## 🔧 Commandes rapides de référence

```powershell
# Voir tous les rôles FSMO
Get-ADForest | Select SchemaMaster, DomainNamingMaster
Get-ADDomain | Select PDCEmulator, RIDMaster, InfrastructureMaster

# Transférer un rôle (DC cible en ligne)
Move-ADDirectoryServerOperationMasterRole -Identity "DC02" -OperationMasterRole PDCEmulator

# Saisir un rôle (DC source perdu)
Move-ADDirectoryServerOperationMasterRole -Identity "DC02" -OperationMasterRole PDCEmulator -Force

# Vérifier la réplication
repadmin /replsummary
repadmin /showrepl

# Tester les rôles FSMO
dcdiag /test:knowsofroleholders /v

# Vérifier le pool RID
dcdiag /test:ridmanager /v

# Nettoyer les métadonnées d'un DC mort
Remove-ADDomainController -Identity "DC01"
```

---

_Cours rédigé pour Obsidian - Active Directory Domain Services (ADDS)_