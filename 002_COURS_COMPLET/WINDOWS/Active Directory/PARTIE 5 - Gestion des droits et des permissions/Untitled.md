# 🛡️ Active Directory - Groupes privilégiés et administratifs

## 📋 Table des matières

1. [Introduction aux groupes privilégiés](https://claude.ai/chat/2f3cbb66-13fe-4586-aab2-832d0d774adf#introduction)
2. [Administrateurs du domaine](https://claude.ai/chat/2f3cbb66-13fe-4586-aab2-832d0d774adf#admin-domaine)
3. [Administrateurs de l'entreprise](https://claude.ai/chat/2f3cbb66-13fe-4586-aab2-832d0d774adf#admin-entreprise)
4. [Administrateurs de schéma](https://claude.ai/chat/2f3cbb66-13fe-4586-aab2-832d0d774adf#admin-schema)
5. [Autres groupes intégrés importants](https://claude.ai/chat/2f3cbb66-13fe-4586-aab2-832d0d774adf#autres-groupes)
6. [Comparaison et hiérarchie des groupes](https://claude.ai/chat/2f3cbb66-13fe-4586-aab2-832d0d774adf#comparaison)
7. [Bonnes pratiques de sécurité](https://claude.ai/chat/2f3cbb66-13fe-4586-aab2-832d0d774adf#bonnes-pratiques)

---

## 🎯 Introduction aux groupes privilégiés {#introduction}

Les **groupes privilégiés** dans Active Directory sont des groupes de sécurité prédéfinis qui disposent de permissions administratives étendues sur le domaine, la forêt ou l'infrastructure AD. Ces groupes sont créés automatiquement lors de l'installation d'Active Directory.

> [!info] Pourquoi sont-ils critiques ? Ces groupes représentent les clés du royaume AD. Un compte compromis dans l'un de ces groupes peut permettre à un attaquant de prendre le contrôle total de l'infrastructure. Leur gestion appropriée est donc primordiale pour la sécurité.

### Caractéristiques communes

- **Création automatique** : générés lors de l'installation d'AD
- **Permissions élevées** : accès administratif complet à différents niveaux
- **Non supprimables** : protégés par AD contre la suppression
- **Portée variable** : domaine local, global ou universel selon le groupe
- **Audités** : modifications traçables dans les logs de sécurité

> [!warning] Principe du moindre privilège Ne jamais ajouter un compte utilisateur à ces groupes "par facilité". Chaque membre doit être justifié et documenté.

---

## 👑 Administrateurs du domaine (Domain Admins) {#admin-domaine}

### Description et rôle

Le groupe **Domain Admins** est le groupe administratif principal d'un domaine Active Directory. Les membres de ce groupe ont un contrôle total sur tous les objets du domaine.

**Nom du groupe :**

- Anglais : `Domain Admins`
- Français : `Administrateurs du domaine`
- SID : `S-1-5-21-<domain>-512`

### Portée et permissions

**Portée du groupe :** Global (peut être utilisé dans tout le domaine et dans les domaines approuvés)

**Permissions principales :**

- Administration complète de tous les contrôleurs de domaine
- Création, modification et suppression de tous les objets AD du domaine
- Gestion des stratégies de groupe (GPO)
- Réinitialisation des mots de passe de tous les utilisateurs
- Ajout/suppression de membres dans tous les groupes
- Installation de logiciels sur les contrôleurs de domaine

> [!example] Appartenance automatique Par défaut, le groupe Domain Admins est automatiquement membre du groupe local **Administrateurs** sur tous les ordinateurs joints au domaine. Cela lui confère des droits administratifs locaux sur toutes les machines.

### Où intervient ce groupe ?

```
🏢 Domaine contoso.com
    │
    ├─ 🖥️ Contrôleurs de domaine → Administration totale
    ├─ 👥 Objets utilisateurs → Gestion complète
    ├─ 🗂️ Unités organisationnelles → Contrôle total
    ├─ 📋 Stratégies de groupe → Création et édition
    └─ 💻 Postes de travail → Droits admin locaux (via groupe Administrateurs)
```

### Gestion des membres

**Lister les membres via PowerShell :**

```powershell
# Afficher les membres du groupe Domain Admins
Get-ADGroupMember -Identity "Domain Admins" | Select-Object Name, SamAccountName

# Version détaillée avec informations supplémentaires
Get-ADGroupMember -Identity "Domain Admins" -Recursive | 
    Get-ADUser -Properties LastLogonDate, Enabled | 
    Select-Object Name, SamAccountName, Enabled, LastLogonDate
```

**Ajouter un membre :**

```powershell
# Ajouter un utilisateur au groupe Domain Admins
Add-ADGroupMember -Identity "Domain Admins" -Members "jdupont"

# Vérifier l'ajout
Get-ADGroupMember -Identity "Domain Admins" | Where-Object {$_.SamAccountName -eq "jdupont"}
```

**Retirer un membre :**

```powershell
# Retirer un utilisateur du groupe
Remove-ADGroupMember -Identity "Domain Admins" -Members "jdupont" -Confirm:$false
```

> [!tip] Astuce d'audit Utilisez un script planifié pour surveiller les changements de membres dans ce groupe :
> 
> ```powershell
> $Members = Get-ADGroupMember -Identity "Domain Admins" | Select-Object -ExpandProperty SamAccountName
> $Members | Out-File "C:\Audit\DomainAdmins_$(Get-Date -Format 'yyyyMMdd').txt"
> ```

### Pièges courants

> [!warning] Erreurs à éviter
> 
> - **Ne jamais utiliser Domain Admins pour les tâches quotidiennes** : créez des comptes administratifs dédiés
> - **Éviter les comptes de service** : les services ne devraient jamais s'exécuter avec ces privilèges
> - **Attention aux sessions ouvertes** : un admin qui se connecte sur un poste compromis expose ses identifiants
> - **Pas de connexion RDP direct** : utiliser des stations d'administration dédiées (PAW - Privileged Access Workstation)

---

## 🌐 Administrateurs de l'entreprise (Enterprise Admins) {#admin-entreprise}

### Description et rôle

Le groupe **Enterprise Admins** est le groupe le plus puissant dans une forêt Active Directory multi-domaines. Il existe uniquement dans le domaine racine de la forêt et ses membres ont des droits administratifs sur tous les domaines de la forêt.

**Nom du groupe :**

- Anglais : `Enterprise Admins`
- Français : `Administrateurs de l'entreprise`
- SID : `S-1-5-21-<root-domain>-519`

### Portée et permissions

**Portée du groupe :** Universel (disponible dans toute la forêt)

**Permissions principales :**

- Administration de tous les domaines de la forêt
- Modification de la configuration de la forêt
- Ajout ou suppression de domaines dans la forêt
- Gestion des sites et des relations d'approbation
- Modification du schéma Active Directory (avec Schema Admins)
- Configuration des contrôleurs de domaine en lecture seule (RODC)

> [!info] Emplacement unique Ce groupe n'existe que dans le domaine racine de la forêt. Dans une forêt avec un seul domaine, Domain Admins et Enterprise Admins ont des privilèges similaires.

### Architecture multi-domaines

```
🌳 Forêt contoso.com
    │
    ├─ 🏢 Domaine racine : contoso.com
    │   └─ 👥 Enterprise Admins (existe ici uniquement)
    │       │
    │       ├─→ Administration sur contoso.com
    │       ├─→ Administration sur emea.contoso.com
    │       └─→ Administration sur americas.contoso.com
    │
    ├─ 🏢 Domaine enfant : emea.contoso.com
    │   └─ 👥 Domain Admins (local à ce domaine)
    │
    └─ 🏢 Domaine enfant : americas.contoso.com
        └─ 👥 Domain Admins (local à ce domaine)
```

### Différence avec Domain Admins

|Critère|Domain Admins|Enterprise Admins|
|---|---|---|
|**Portée**|Un seul domaine|Toute la forêt|
|**Existence**|Dans chaque domaine|Uniquement domaine racine|
|**Type**|Global|Universel|
|**Usage**|Administration quotidienne du domaine|Modifications structurelles de la forêt|
|**Membres par défaut**|Compte Administrator du domaine|Compte Administrator du domaine racine|

### Quand utiliser Enterprise Admins ?

> [!example] Cas d'usage légitimes
> 
> - Ajout d'un nouveau domaine à la forêt
> - Configuration de relations d'approbation inter-forêts
> - Modification de la structure de réplication
> - Mise à niveau du niveau fonctionnel de la forêt
> - Configuration de sites AD multi-domaines

**Ces tâches sont rares** : le groupe devrait rester vide la plupart du temps !

### Gestion des membres

```powershell
# Lister les membres (depuis le domaine racine uniquement)
Get-ADGroupMember -Identity "Enterprise Admins" -Server "racine-dc.contoso.com"

# Ajouter temporairement un membre pour une tâche spécifique
Add-ADGroupMember -Identity "Enterprise Admins" -Members "admin-projet" -Server "racine-dc.contoso.com"

# ⚠️ Important : retirer immédiatement après la tâche
Remove-ADGroupMember -Identity "Enterprise Admins" -Members "admin-projet" -Confirm:$false -Server "racine-dc.contoso.com"
```

> [!warning] Sécurité critique Dans la plupart des organisations, ce groupe devrait être **vide** en temps normal. Les membres ne devraient être ajoutés que temporairement pour des tâches spécifiques, puis retirés immédiatement.

### Appartenance par défaut

Par défaut, Enterprise Admins est automatiquement membre de :

- **Administrateurs** dans chaque domaine de la forêt
- Donc droits administratifs locaux sur toutes les machines de la forêt

---

## 🔧 Administrateurs de schéma (Schema Admins) {#admin-schema}

### Description et rôle

Le groupe **Schema Admins** a le pouvoir exclusif de modifier le schéma Active Directory, qui définit la structure et les types d'objets possibles dans AD.

**Nom du groupe :**

- Anglais : `Schema Admins`
- Français : `Administrateurs du schéma`
- SID : `S-1-5-21-<root-domain>-518`

### Portée et permissions

**Portée du groupe :** Universel (toute la forêt)

**Permission unique :** Modification du schéma Active Directory

> [!info] Qu'est-ce que le schéma ? Le schéma AD est le plan architectural qui définit :
> 
> - Les classes d'objets (utilisateur, ordinateur, groupe, etc.)
> - Les attributs disponibles pour chaque classe
> - Les règles de syntaxe et de validation
> - Les relations entre objets

### Modifications du schéma

**Exemples de modifications nécessitant Schema Admins :**

```
📋 Schéma Active Directory
    │
    ├─ Ajouter une nouvelle classe d'objet
    │  (ex: "Badge" pour gérer les accès physiques)
    │
    ├─ Ajouter un nouvel attribut à une classe existante
    │  (ex: "NumeroTelephone2" sur la classe User)
    │
    ├─ Modifier les propriétés d'un attribut existant
    │  (ex: rendre un attribut indexé pour les recherches)
    │
    └─ Extension du schéma pour une application
       (ex: Microsoft Exchange, SCCM, Skype for Business)
```

### Pourquoi est-ce si sensible ?

> [!warning] Modifications irréversibles Les modifications du schéma sont **quasi-irréversibles**. Vous pouvez désactiver des éléments mais rarement les supprimer. Une erreur peut :
> 
> - Corrompre la structure AD
> - Empêcher la réplication entre contrôleurs de domaine
> - Rendre impossible l'ajout de nouveaux DC
> - Nécessiter une restauration complète de la forêt

### Quand utiliser Schema Admins ?

**Cas d'usage typiques :**

1. **Installation d'applications Microsoft :**
    
    ```powershell
    # Extension du schéma pour Exchange Server
    # Cette commande nécessite d'être Schema Admin
    Setup.exe /PrepareSchema /IAcceptExchangeServerLicenseTerms
    ```
    
2. **Extension du schéma pour applications tierces :**
    
    - Solutions de gestion d'identités
    - Outils de synchronisation annuaire
    - Applications métier nécessitant des attributs personnalisés
3. **Ajout d'attributs personnalisés :**
    
    ```powershell
    # Exemple : ajouter un attribut personnalisé (simplifié)
    # Nécessite d'être Schema Admin
    $schemaPath = (Get-ADRootDSE).schemaNamingContext
    New-ADObject -Name "Matricule-Employe" -Type attributeSchema -Path "CN=Schema,CN=Configuration,DC=contoso,DC=com" -OtherAttributes @{
        lDAPDisplayName = "employeeMatricule"
        attributeID = "1.2.840.113556.1.8000.2554.999999.1"
        attributeSyntax = "2.5.5.5"
        oMSyntax = 22
        isSingleValued = $true
    }
    ```
    

### Bonnes pratiques de gestion

> [!tip] Gestion sécurisée de Schema Admins
> 
> **1. Groupe vide par défaut**
> 
> ```powershell
> # Vérifier que le groupe est vide
> Get-ADGroupMember -Identity "Schema Admins"
> # Résultat attendu : aucun membre
> ```
> 
> **2. Ajout temporaire uniquement**
> 
> ```powershell
> # Ajouter juste avant la tâche
> Add-ADGroupMember -Identity "Schema Admins" -Members "admin-schema-temp"
> 
> # Effectuer la modification du schéma
> # ...
> 
> # Retirer IMMÉDIATEMENT après
> Remove-ADGroupMember -Identity "Schema Admins" -Members "admin-schema-temp" -Confirm:$false
> ```
> 
> **3. Documenter chaque modification**
> 
> - Date et heure
> - Qui a effectué la modification
> - Raison de la modification
> - Application ou fonctionnalité concernée
> - Tests effectués avant déploiement

### Protection supplémentaire

> [!example] Désactiver les modifications du schéma Pour une protection maximale, vous pouvez désactiver les modifications du schéma :
> 
> ```powershell
> # Se connecter au Schema Master
> $schemaMaster = (Get-ADForest).SchemaMaster
> 
> # Désactiver les modifications (valeur 1 = désactivé)
> Set-ADObject -Identity (Get-ADRootDSE).schemaNamingContext -Replace @{schemaUpdateNow=1}
> 
> # Réactiver temporairement avant une modification
> Set-ADObject -Identity (Get-ADRootDSE).schemaNamingContext -Replace @{schemaUpdateNow=0}
> ```

### Rôle FSMO associé

Le contrôleur de domaine qui détient le rôle **Schema Master** est le seul DC autorisé à écrire dans le schéma.

```powershell
# Identifier le Schema Master
Get-ADForest | Select-Object SchemaMaster

# Résultat exemple
SchemaMaster
------------
DC01.contoso.com
```

> [!info] Un seul DC par forêt Il n'existe qu'un seul Schema Master par forêt Active Directory. Toutes les modifications du schéma doivent être effectuées sur ce DC spécifique.

---

## 🔐 Autres groupes intégrés importants {#autres-groupes}

Au-delà des trois groupes principaux, Active Directory contient de nombreux autres groupes privilégiés avec des permissions spécifiques.

### 1. Administrateurs (Administrators)

**Type :** Domaine local  
**SID :** `S-1-5-32-544`

**Description :** Groupe local présent sur chaque machine (incluant les DC). Contrôle total sur le système local.

**Membres par défaut :**

- Domain Admins (sur les postes joints au domaine)
- Enterprise Admins (sur tous les systèmes de la forêt)
- Compte Administrator local

```powershell
# Lister les membres sur un contrôleur de domaine
Get-ADGroupMember -Identity "Administrators"

# Sur un poste de travail (PowerShell local)
Get-LocalGroupMember -Group "Administrators"
```

> [!warning] Attention Sur les postes de travail, évitez d'ajouter trop d'utilisateurs dans le groupe Administrateurs local. Privilégiez des groupes spécifiques avec des permissions limitées.

---

### 2. Opérateurs de compte (Account Operators)

**Type :** Domaine local  
**SID :** `S-1-5-32-548`

**Description :** Permissions limitées sur la gestion des comptes utilisateurs et groupes, sans être administrateur complet.

**Permissions :**

- Créer, modifier et supprimer des comptes utilisateurs et groupes (sauf dans les conteneurs Admin et Domain Controllers)
- Gérer les appartenances aux groupes (sauf groupes protégés)
- Se connecter localement aux contrôleurs de domaine
- **Ne peut PAS** modifier les administrateurs ou leurs groupes

**Cas d'usage :**

- Équipes support helpdesk
- Gestionnaires RH avec délégation
- Techniciens responsables de la création de comptes

```powershell
# Ajouter un utilisateur helpdesk
Add-ADGroupMember -Identity "Account Operators" -Members "helpdesk-user1"

# Vérifier les permissions
Get-ADGroup "Account Operators" -Properties MemberOf | Select-Object -ExpandProperty MemberOf
```

> [!tip] Alternative plus sécurisée Plutôt que d'utiliser Account Operators, préférez une **délégation personnalisée** sur des UO spécifiques pour limiter encore plus la portée des permissions.

---

### 3. Opérateurs de serveur (Server Operators)

**Type :** Domaine local  
**SID :** `S-1-5-32-549`

**Description :** Gestion opérationnelle des serveurs, notamment des contrôleurs de domaine.

**Permissions :**

- Connexion locale aux contrôleurs de domaine
- Créer et gérer des partages réseau
- Sauvegarder et restaurer des fichiers
- Arrêter et redémarrer les serveurs
- Gérer les services
- **Ne peut PAS** modifier les paramètres de sécurité ou les groupes administratifs

**Cas d'usage :**

- Équipes d'exploitation système
- Techniciens responsables des sauvegardes
- Administrateurs juniors avec responsabilités limitées

> [!warning] Risque d'escalade de privilèges Un membre de Server Operators peut potentiellement exploiter ses permissions pour élever ses privilèges. Ce groupe devrait être utilisé avec précaution.

---

### 4. Opérateurs de sauvegarde (Backup Operators)

**Type :** Domaine local  
**SID :** `S-1-5-32-551`

**Description :** Permissions pour effectuer des sauvegardes et restaurations, indépendamment des permissions sur les fichiers.

**Permissions :**

- Sauvegarder et restaurer tous les fichiers (contourne les ACL)
- Se connecter localement aux contrôleurs de domaine
- Arrêter et démarrer le système

**Cas d'usage :**

- Comptes de service pour logiciels de sauvegarde
- Administrateurs de backup dédiés

```powershell
# Ajouter un compte de service de backup
Add-ADGroupMember -Identity "Backup Operators" -Members "svc-backup"

# Créer une tâche de sauvegarde planifiée
# Ce compte pourra sauvegarder même les fichiers auxquels il n'a pas accès normalement
```

> [!tip] Compte de service dédié Toujours utiliser un compte de service spécifique pour les sauvegardes, jamais un compte utilisateur personnel.

---

### 5. Propriétaires créateurs de la stratégie de groupe (Group Policy Creator Owners)

**Type :** Global  
**SID :** `S-1-5-21-<domain>-520`

**Description :** Autorise la création de nouvelles stratégies de groupe (GPO) dans le domaine.

**Permissions :**

- Créer de nouvelles GPO
- Modifier les GPO qu'ils ont créées
- **Ne peut PAS** lier les GPO à des UO (nécessite des permissions supplémentaires)

**Membres par défaut :**

- Domain Admins

```powershell
# Déléguer la création de GPO à un administrateur junior
Add-ADGroupMember -Identity "Group Policy Creator Owners" -Members "admin-gpo"

# L'utilisateur peut maintenant créer des GPO
New-GPO -Name "Ma Nouvelle GPO" -Comment "Créée par admin-gpo"
# Mais ne peut pas la lier sans délégation supplémentaire
```

> [!info] Séparation des responsabilités Ce groupe permet de séparer la création de GPO (par les équipes techniques) de leur déploiement (validé par les responsables).

---

### 6. Administrateurs DNS (DnsAdmins)

**Type :** Domaine local  
**SID :** Variable selon le domaine

**Description :** Gestion complète des zones DNS hébergées sur les contrôleurs de domaine.

**Permissions :**

- Créer, modifier et supprimer des zones DNS
- Gérer les enregistrements DNS
- Configurer les paramètres du serveur DNS

**Cas d'usage :**

- Équipes réseau responsables du DNS
- Administrateurs d'infrastructure

```powershell
# Ajouter un administrateur réseau
Add-ADGroupMember -Identity "DnsAdmins" -Members "admin-reseau"

# Gérer le DNS via PowerShell
Add-DnsServerResourceRecordA -Name "serveur01" -IPv4Address "192.168.1.100" -ZoneName "contoso.com"
```

> [!warning] Risque de sécurité Un membre de DnsAdmins peut charger une DLL arbitraire dans le processus DNS (s'exécutant en tant que SYSTEM). Cela peut être exploité pour l'escalade de privilèges. Limiter strictement l'appartenance.

---

### 7. Accès RODC autorisé à répliquer les mots de passe (Allowed RODC Password Replication Group)

**Type :** Domaine local  
**SID :** Variable

**Description :** Définit quels comptes peuvent avoir leurs mots de passe mis en cache sur les contrôleurs de domaine en lecture seule (RODC).

**Contexte :** Les RODC sont conçus pour les sites distants avec sécurité physique limitée. Par défaut, ils ne mettent **aucun** mot de passe en cache.

**Utilisation :**

```powershell
# Autoriser un groupe d'utilisateurs de site distant
Add-ADGroupMember -Identity "Allowed RODC Password Replication Group" -Members "Utilisateurs-SiteDistant"

# Vérifier les mots de passe mis en cache sur un RODC
Get-ADDomainControllerPasswordReplicationPolicy -Identity "RODC01" -AllowedList
```

---

### 8. Contrôleurs de domaine clonables (Cloneable Domain Controllers)

**Type :** Global  
**SID :** `S-1-5-21-<domain>-522`

**Description :** Autorise le clonage virtualisé des contrôleurs de domaine.

**Contexte :** Windows Server 2012 et ultérieur permet de cloner un DC virtualisé pour en déployer rapidement de nouveaux.

**Prérequis pour le clonage :**

- Le DC source doit être membre de ce groupe
- Hyperviseur compatible (Hyper-V, VMware, etc.)
- Le DC doit exécuter Windows Server 2012 ou supérieur

```powershell
# Ajouter un DC au groupe pour permettre son clonage
Add-ADGroupMember -Identity "Cloneable Domain Controllers" -Members "DC03$"

# Vérifier l'éligibilité au clonage
Get-ADDCCloningExcludedApplicationList

# Créer le fichier de configuration de clonage
New-ADDCCloneConfigFile -CloneComputerName "DC04" -SiteName "Site-Paris" -Static -IPv4Address "192.168.1.15" -IPv4DNSResolver "192.168.1.10"
```

---

### 9. Administrateurs protégés (Protected Users)

**Type :** Global  
**SID :** `S-1-5-21-<domain>-525`

**Description :** Groupe de sécurité qui applique des protections renforcées contre le vol d'identifiants (Windows Server 2012 R2+).

**Protections appliquées automatiquement :**

- Pas de délégation Kerberos (ConstrainedDelegation)
- Pas de DES ou RC4 pour Kerberos (uniquement AES)
- Durée de vie des tickets Kerberos limitée à 4 heures
- Pas de mise en cache des identifiants NTLM
- Impossibilité d'utiliser CredSSP/WDigest

**Cas d'usage :**

- Comptes administrateurs hautement privilégiés
- Comptes VIP nécessitant une protection maximale

```powershell
# Ajouter des comptes administrateurs au groupe
Add-ADGroupMember -Identity "Protected Users" -Members "admin-domaine1", "admin-domaine2"

# Vérifier le niveau fonctionnel requis
Get-ADDomain | Select-Object DomainMode
# Requis : Windows2012R2Domain ou supérieur
```

> [!warning] Limitations à connaître Les membres de Protected Users ne peuvent pas :
> 
> - S'authentifier avec NTLM
> - Utiliser l'authentification Digest
> - Utiliser la délégation Kerberos
> - Renouveler les tickets TGT au-delà de 4 heures
> 
> Cela peut causer des problèmes avec des applications anciennes. Testez avant de déployer !

---

### 10. Utilisateurs du Bureau à distance (Remote Desktop Users)

**Type :** Domaine local  
**SID :** `S-1-5-32-555`

**Description :** Autorise la connexion via Remote Desktop Protocol (RDP) aux serveurs membres du domaine.

**Permissions :**

- Connexion Bureau à distance uniquement
- Aucun droit administratif

```powershell
# Autoriser un groupe support à se connecter en RDP aux serveurs
Add-ADGroupMember -Identity "Remote Desktop Users" -Members "Support-Helpdesk"

# Sur un serveur spécifique (commande locale)
Add-LocalGroupMember -Group "Remote Desktop Users" -Member "CONTOSO\Support-Helpdesk"
```

> [!info] Portée limitée Sur les contrôleurs de domaine, ce groupe ne donne **pas** accès RDP. Il faut des privilèges plus élevés (ex: Account Operators minimum).

---

## 📊 Comparaison et hiérarchie des groupes {#comparaison}

### Tableau comparatif des groupes principaux

|Groupe|Portée|Niveau|Permissions|Usage typique|Membres recommandés|
|---|---|---|---|---|---|
|**Schema Admins**|Universel|Forêt|Modification du schéma|Extension schéma applicatif|0 (ajout temporaire uniquement)|
|**Enterprise Admins**|Universel|Forêt|Administration multi-domaines|Modifications structurelles forêt|0-1 (usage exceptionnel)|
|**Domain Admins**|Global|Domaine|Administration complète domaine|Gestion quotidienne domaine|2-5 selon taille|
|**Administrators**|Local|Système|Contrôle total local|Administration serveurs/DC|Contient les groupes ci-dessus|
|**Account Operators**|Local|Domaine|Gestion utilisateurs (limité)|Support helpdesk|5-20 selon organisation|
|**Server Operators**|Local|Domaine|Gestion opérationnelle serveurs|Exploitation système|2-10|
|**Backup Operators**|Local|Domaine|Sauvegarde/restauration|Comptes de service backup|1-3 (comptes service)|
|**GPO Creator Owners**|Global|Domaine|Création GPO|Équipes configuration|3-10|
|**DnsAdmins**|Local|Domaine|Administration DNS|Équipes réseau|2-5|
|**Protected Users**|Global|Domaine|Aucune (protection)|Sécurisation comptes VIP|Tous les admins privilégiés|

### Hiérarchie de privilèges

```
🏔️ Niveau de privilège (du plus au moins élevé)

┌─────────────────────────────────────────┐
│ 1️⃣ Schema Admins                        │ ← Modification structure AD
│    (uniquement domaine racine)          │    (irréversible)
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│ 2️⃣ Enterprise Admins                    │ ← Administration multi-domaines
│    (uniquement domaine racine)          │    dans la forêt
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│ 3️⃣ Domain Admins                        │ ← Administration complète
│    (chaque domaine)                     │    d'un domaine
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│ 4️⃣ Administrators (local)               │ ← Contrôle total système local
│    (sur chaque machine)                 │    (serveurs, DC, postes)
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│ 5️⃣ Groupes opérationnels               │ ← Permissions spécialisées
│    • Server Operators                   │    sans administration complète
│    • Account Operators                  │
│    • Backup Operators                   │
│    • DnsAdmins                          │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│ 6️⃣ Groupes fonctionnels                │ ← Permissions ciblées
│    • GPO Creator Owners                 │    pour des tâches spécifiques
│    • Remote Desktop Users               │
└─────────────────────────────────────────┘
```

### Relations d'appartenance par défaut

```
🔗 Chaîne d'appartenance automatique

Schema Admins ──┐
                │
Enterprise Admins ─┼──> Administrators ──> Droits admin locaux
                │       (de chaque domaine)    sur toutes les machines
Domain Admins ──┘                              du domaine/forêt


📝 Signification :
- Schema Admins et Enterprise Admins sont automatiquement membres 
  du groupe Administrators dans chaque domaine de la forêt
- Domain Admins est membre du groupe Administrators de son domaine
- Le groupe Administrators donne des droits admin locaux sur toutes 
  les machines jointes au domaine
```

### Matrice de permissions

|Action|Schema Admins|Enterprise Admins|Domain Admins|Account Operators|Server Operators|
|---|:-:|:-:|:-:|:-:|:-:|
|Modifier le schéma AD|✅|❌|❌|❌|❌|
|Ajouter un domaine à la forêt|❌|✅|❌|❌|❌|
|Gérer tous les domaines|❌|✅|❌|❌|❌|
|Administrer un domaine complet|✅*|✅|✅|❌|❌|
|Créer des utilisateurs|✅*|✅|✅|✅**|❌|
|Modifier les admins|✅*|✅|✅|❌|❌|
|Gérer les GPO|✅*|✅|✅|❌|❌|
|Redémarrer les DC|✅*|✅|✅|❌|✅|
|Gérer les services|✅*|✅|✅|❌|✅|
|Gérer les partages|✅*|✅|✅|❌|✅|
|Sauvegarder les fichiers|✅*|✅|✅|❌|❌|

_* Via appartenance au groupe Administrators_  
_** Sauf dans conteneurs protégés (Admins, Domain Controllers)_

---

## ✅ Bonnes pratiques de sécurité {#bonnes-pratiques}

### 1. Principe du moindre privilège

> [!tip] Règle d'or **Ne donnez jamais plus de permissions que nécessaire.** Un utilisateur qui a besoin de réinitialiser des mots de passe n'a pas besoin d'être Domain Admin.

**Approche par délégation :**

```powershell
# ❌ MAUVAISE PRATIQUE : Ajouter au groupe Domain Admins
Add-ADGroupMember -Identity "Domain Admins" -Members "support-user"

# ✅ BONNE PRATIQUE : Déléguer uniquement la réinitialisation de mots de passe
# Sur une UO spécifique
$ou = "OU=Utilisateurs,DC=contoso,DC=com"
$user = "support-user"

# Déléguer la permission de réinitialiser les mots de passe
dsacls $ou /I:S /G "$($user):CA;Reset Password;user"
```

**Hiérarchie de délégation recommandée :**

1. **Délégation au niveau UO** (le plus sécurisé) → pour des tâches spécifiques
2. **Groupes opérationnels** (Account Operators, etc.) → pour des rôles définis
3. **Domain Admins** → pour l'administration quotidienne du domaine
4. **Enterprise Admins** → uniquement pour modifications structurelles
5. **Schema Admins** → uniquement pour extensions du schéma

### 2. Gestion des groupes les plus privilégiés

> [!warning] Règles strictes pour Schema Admins et Enterprise Admins

**Groupe vide par défaut :**

```powershell
# Script de vérification quotidienne
$groupes = @("Schema Admins", "Enterprise Admins")

foreach ($groupe in $groupes) {
    $membres = Get-ADGroupMember -Identity $groupe
    if ($membres.Count -gt 0) {
        # Alerte : le groupe ne devrait pas avoir de membres permanents
        Send-MailMessage -To "securite@contoso.com" `
            -Subject "⚠️ ALERTE : Membres détectés dans $groupe" `
            -Body "Membres trouvés : $($membres.Name -join ', ')" `
            -SmtpServer "smtp.contoso.com"
    }
}
```

**Processus d'ajout temporaire :**

```powershell
# Script d'ajout temporaire avec traçabilité
function Add-TemporaryPrivilegedAccess {
    param(
        [string]$Group,
        [string]$User,
        [string]$Justification,
        [int]$DurationHours = 2
    )
    
    # Enregistrer la demande
    $logEntry = @{
        Date = Get-Date
        Group = $Group
        User = $User
        Justification = $Justification
        Duration = $DurationHours
        AddedBy = $env:USERNAME
    }
    $logEntry | Export-Csv "C:\Logs\PrivilegedAccess.csv" -Append -NoTypeInformation
    
    # Ajouter l'utilisateur
    Add-ADGroupMember -Identity $Group -Members $User
    Write-Host "✅ $User ajouté à $Group pour $DurationHours heures" -ForegroundColor Green
    Write-Host "⚠️ RAPPEL : Retirer manuellement après la tâche !" -ForegroundColor Yellow
    
    # Programmer un rappel (nécessite une tâche planifiée)
    $triggerTime = (Get-Date).AddHours($DurationHours)
    Write-Host "⏰ Rappel programmé pour : $triggerTime" -ForegroundColor Cyan
}

# Utilisation
Add-TemporaryPrivilegedAccess -Group "Schema Admins" `
    -User "admin-projet" `
    -Justification "Extension schéma Exchange 2019" `
    -DurationHours 2
```

### 3. Comptes administratifs dédiés

> [!example] Architecture à deux comptes Chaque administrateur devrait avoir **deux comptes distincts** :

**Structure recommandée :**

```
👤 Jean Dupont (administrateur)
    │
    ├─ 📧 jdupont@contoso.com
    │      └─ Compte standard (utilisateur normal)
    │         • Email quotidien
    │         • Navigation web
    │         • Applications métier
    │         • AUCUN privilège administratif
    │
    └─ 🔑 jdupont-admin@contoso.com
           └─ Compte administratif (dédié aux tâches admin)
              • Membre de Domain Admins
              • Utilisation uniquement depuis PAW
              • Pas d'email, pas de navigation
              • Mot de passe complexe différent
              • MFA obligatoire
```

**Création d'un compte administratif dédié :**

```powershell
# Créer le compte admin dédié
$userStandard = "jdupont"
$userAdmin = "$userStandard-admin"

New-ADUser -Name "Jean Dupont (Admin)" `
    -SamAccountName $userAdmin `
    -UserPrincipalName "$userAdmin@contoso.com" `
    -AccountPassword (Read-Host -AsSecureString "Mot de passe admin") `
    -Enabled $true `
    -PasswordNeverExpires $false `
    -ChangePasswordAtLogon $false `
    -Description "Compte administratif dédié - Propriétaire: $userStandard"

# Forcer MFA sur ce compte (si Azure AD Connect)
# Configuration via Azure AD

# Ajouter aux groupes administratifs
Add-ADGroupMember -Identity "Domain Admins" -Members $userAdmin
Add-ADGroupMember -Identity "Protected Users" -Members $userAdmin

# Restreindre la connexion aux stations d'administration uniquement
Set-ADUser -Identity $userAdmin -LogonWorkstations "PAW01,PAW02,DC01"
```

> [!warning] Jamais d'admin pour les tâches quotidiennes
> 
> - Ne jamais utiliser un compte Domain Admin pour lire ses emails
> - Ne jamais naviguer sur Internet avec un compte privilégié
> - Ne jamais se connecter à un poste utilisateur standard avec un compte admin
> - Toujours basculer sur le compte administratif uniquement pour les tâches nécessitant ces privilèges

### 4. Stations d'administration privilégiées (PAW)

> [!info] Concept PAW (Privileged Access Workstation) Une PAW est un poste de travail sécurisé, dédié exclusivement aux tâches administratives, isolé du réseau standard.

**Caractéristiques d'une PAW :**

```
🖥️ Station d'Administration Privilégiée (PAW)
    │
    ├─ 🔒 Durcissement système
    │   • Pas d'accès Internet
    │   • Pas de messagerie
    │   • Applications limitées (outils admin uniquement)
    │   • Antivirus + EDR renforcé
    │
    ├─ 🌐 Isolation réseau
    │   • VLAN dédié pour l'administration
    │   • Firewall limitant les connexions sortantes
    │   • Accès uniquement vers serveurs/DC
    │
    ├─ 👤 Authentification stricte
    │   • Connexion uniquement avec comptes admin dédiés
    │   • MFA obligatoire (carte à puce / FIDO2)
    │   • Session timeout agressif
    │
    └─ 📋 Journalisation exhaustive
        • Tous les événements loggués
        • Monitoring en temps réel
        • Alertes sur anomalies
```

**Restriction GPO pour forcer l'utilisation des PAW :**

```powershell
# Créer une GPO qui restreint où les admins peuvent se connecter
New-GPO -Name "Restriction Connexion Admins" -Comment "Force l'utilisation des PAW"

# Configurer le droit "Autoriser l'ouverture d'une session localement"
# uniquement sur les PAW pour les comptes admins

# Lier la GPO au domaine
New-GPLink -Name "Restriction Connexion Admins" -Target "DC=contoso,DC=com"
```

### 5. Audit et surveillance

> [!tip] Surveillez activement les groupes privilégiés

**Script de monitoring quotidien :**

```powershell
# Script de surveillance des groupes privilégiés
$groupesPrivilegies = @(
    "Domain Admins",
    "Enterprise Admins",
    "Schema Admins",
    "Administrators",
    "Account Operators",
    "Server Operators",
    "Backup Operators"
)

$rapportHTML = @"
<html>
<head>
    <style>
        table { border-collapse: collapse; width: 100%; }
        th, td { border: 1px solid black; padding: 8px; text-align: left; }
        th { background-color: #4CAF50; color: white; }
        tr:nth-child(even) { background-color: #f2f2f2; }
        .warning { background-color: #ffcccc; }
    </style>
</head>
<body>
    <h1>Rapport d'audit des groupes privilégiés - $(Get-Date -Format 'dd/MM/yyyy')</h1>
    <table>
        <tr>
            <th>Groupe</th>
            <th>Nombre de membres</th>
            <th>Membres</th>
            <th>Statut</th>
        </tr>
"@

foreach ($groupe in $groupesPrivilegies) {
    $membres = Get-ADGroupMember -Identity $groupe -ErrorAction SilentlyContinue
    $count = $membres.Count
    $listeNoms = ($membres | Select-Object -ExpandProperty Name) -join ", "
    
    # Déterminer si c'est anormal
    $classe = ""
    $statut = "✅ Normal"
    
    if ($groupe -in @("Schema Admins", "Enterprise Admins") -and $count -gt 0) {
        $classe = "warning"
        $statut = "⚠️ Groupe devrait être vide"
    }
    
    if ($groupe -eq "Domain Admins" -and $count -gt 5) {
        $classe = "warning"
        $statut = "⚠️ Trop de membres"
    }
    
    $rapportHTML += @"
        <tr class='$classe'>
            <td>$groupe</td>
            <td>$count</td>
            <td>$listeNoms</td>
            <td>$statut</td>
        </tr>
"@
}

$rapportHTML += @"
    </table>
</body>
</html>
"@

# Sauvegarder et envoyer
$rapportHTML | Out-File "C:\Rapports\Audit_Groupes_$(Get-Date -Format 'yyyyMMdd').html"
Send-MailMessage -To "securite@contoso.com" `
    -Subject "Rapport d'audit quotidien - Groupes privilégiés" `
    -Body $rapportHTML -BodyAsHtml `
    -SmtpServer "smtp.contoso.com"
```

**Événements Windows à surveiller :**

|Event ID|Description|Criticité|
|---|---|---|
|4728|Membre ajouté à un groupe de sécurité global|🔴 Critique si groupe admin|
|4732|Membre ajouté à un groupe de sécurité local|🔴 Critique si Administrators|
|4756|Membre ajouté à un groupe de sécurité universel|🔴 Critique si Enterprise/Schema Admins|
|4735|Groupe de sécurité local modifié|🟡 Important|
|4727|Groupe de sécurité global créé|🟢 Informatif|
|4720|Compte utilisateur créé|🟢 Informatif|
|4724|Tentative de réinitialisation de mot de passe|🟡 Important|
|4738|Compte utilisateur modifié|🟢 Informatif|

**Requête SIEM pour détecter les ajouts suspects :**

```powershell
# Rechercher tous les ajouts dans Domain Admins sur les 7 derniers jours
Get-WinEvent -FilterHashtable @{
    LogName = 'Security'
    ID = 4728, 4732, 4756
    StartTime = (Get-Date).AddDays(-7)
} | Where-Object {
    $_.Message -match "Domain Admins|Enterprise Admins|Schema Admins"
} | Select-Object TimeCreated, Message | Format-Table -AutoSize
```

### 6. Rotation et révision régulière

> [!example] Processus de révision trimestrielle

**Checklist de révision (tous les 3 mois) :**

```
📋 Revue trimestrielle des accès privilégiés

┌─ ÉTAPE 1 : Audit des membres
│   □ Exporter la liste de tous les membres des groupes privilégiés
│   □ Vérifier que chaque membre a toujours besoin de cet accès
│   □ Supprimer les comptes inactifs ou dont le rôle a changé
│
├─ ÉTAPE 2 : Vérification des comptes
│   □ S'assurer que tous les comptes admin ont un propriétaire identifié
│   □ Vérifier la dernière connexion de chaque compte
│   □ Désactiver les comptes non utilisés depuis 90 jours
│
├─ ÉTAPE 3 : Conformité aux standards
│   □ Vérifier que Schema Admins et Enterprise Admins sont vides
│   □ S'assurer que tous les admins utilisent des comptes dédiés
│   □ Confirmer que Protected Users contient tous les comptes privilégiés
│
├─ ÉTAPE 4 : Contrôle des mots de passe
│   □ Vérifier l'âge des mots de passe (< 90 jours)
│   □ S'assurer que MFA est activé sur tous les comptes admin
│   □ Tester la complexité (25+ caractères recommandés)
│
└─ ÉTAPE 5 : Documentation
    □ Mettre à jour la matrice des accès
    □ Documenter les changements effectués
    □ Archiver le rapport d'audit
```

**Script de génération du rapport de révision :**

```powershell
# Rapport complet pour la révision trimestrielle
$rapport = @()

$groupesPrivilegies = @("Domain Admins", "Enterprise Admins", "Schema Admins")

foreach ($groupe in $groupesPrivilegies) {
    $membres = Get-ADGroupMember -Identity $groupe | Get-ADUser -Properties LastLogonDate, PasswordLastSet, Enabled
    
    foreach ($membre in $membres) {
        $joursDepuisConnexion = if ($membre.LastLogonDate) { 
            (New-TimeSpan -Start $membre.LastLogonDate -End (Get-Date)).Days 
        } else { 
            "Jamais" 
        }
        
        $joursDepuisMDP = (New-TimeSpan -Start $membre.PasswordLastSet -End (Get-Date)).Days
        
        $rapport += [PSCustomObject]@{
            Groupe = $groupe
            Utilisateur = $membre.Name
            Login = $membre.SamAccountName
            Actif = $membre.Enabled
            DerniereConnexion = $membre.LastLogonDate
            JoursDepuisConnexion = $joursDepuisConnexion
            DernierChangementMDP = $membre.PasswordLastSet
            AgeMDP = $joursDepuisMDP
            ActionRequise = if ($joursDepuisConnexion -gt 90 -or $joursDepuisMDP -gt 90) { "⚠️ Révision nécessaire" } else { "✅ Conforme" }
        }
    }
}

# Exporter en CSV pour révision
$rapport | Export-Csv "C:\Rapports\Revision_Trimestrielle_$(Get-Date -Format 'yyyy-Q')Q.csv" -NoTypeInformation -Encoding UTF8

# Afficher un résumé
$rapport | Format-Table -AutoSize
```

### 7. Gestion des comptes de service

> [!warning] Comptes de service : attention particulière

**Règles pour les comptes de service :**

1. **Ne jamais ajouter de comptes de service aux groupes Domain Admins**
2. Utiliser des **comptes de service gérés** (gMSA) quand c'est possible
3. Déléguer uniquement les permissions strictement nécessaires
4. Mots de passe ultra-complexes (30+ caractères) si pas gMSA
5. Documenter chaque compte de service et son usage

**Créer un compte de service géré :**

```powershell
# Créer un Groupe de sécurité pour les serveurs autorisés
New-ADGroup -Name "Servers-ServiceBackup" -GroupScope DomainLocal -Path "OU=Groupes,DC=contoso,DC=com"
Add-ADGroupMember -Identity "Servers-ServiceBackup" -Members "SRV-BACKUP01$", "SRV-BACKUP02$"

# Créer un compte de service géré (gMSA)
New-ADServiceAccount -Name "svc-backup" `
    -DNSHostName "svc-backup.contoso.com" `
    -PrincipalsAllowedToRetrieveManagedPassword "Servers-ServiceBackup" `
    -Description "Compte de service pour solution de backup Veeam"

# Installer le compte sur un serveur
Install-ADServiceAccount -Identity "svc-backup"

# Déléguer uniquement les permissions nécessaires (pas Domain Admin !)
$ou = "OU=Serveurs,DC=contoso,DC=com"
dsacls $ou /I:S /G "contoso\svc-backup$:CA;Backup;organizationalUnit"
```

**Avantages des gMSA :**

- Mot de passe géré automatiquement par AD (changement tous les 30 jours)
- Pas de gestion manuelle des mots de passe
- Impossible d'utiliser pour connexion interactive
- Audit automatique des serveurs utilisant le compte

### 8. Documentation et traçabilité

> [!tip] Matrice d'accès et responsabilités

**Exemple de matrice à maintenir :**

```
📊 MATRICE DES ACCÈS PRIVILÉGIÉS - CONTOSO.COM

┌─────────────────┬──────────────┬───────────────┬─────────────┬────────────┐
│ Compte          │ Propriétaire │ Groupes       │ Justification│ Révision   │
├─────────────────┼──────────────┼───────────────┼─────────────┼────────────┤
│ admin-jdupont   │ J. Dupont    │ Domain Admins │ Resp. Infra │ 01/03/2025 │
│ admin-mmartin   │ M. Martin    │ Domain Admins │ Adjoint IT  │ 01/03/2025 │
│ admin-projet-ex │ Projet Exchan│ (temporaire)  │ Install Exch│ 15/01/2025 │
│ svc-backup$     │ Service      │ Backup Ops    │ Veeam Backup│ 01/03/2025 │
│ svc-monitoring$ │ Service      │ (délégation)  │ SCOM Monitor│ 01/03/2025 │
└─────────────────┴──────────────┴───────────────┴─────────────┴────────────┘

Dernière mise à jour : 28/12/2024
Prochaine révision : 28/03/2025
Responsable : Chef de la Sécurité IT
```

**Template de demande d'accès privilégié :**

```markdown
# DEMANDE D'ACCÈS PRIVILÉGIÉ

## Informations demandeur
- Nom : ______________________
- Fonction : ______________________
- Manager : ______________________

## Détails de l'accès
- Groupe demandé : ☐ Domain Admins  ☐ Account Operators  ☐ Autre: ___________
- Temporaire : ☐ Oui (durée: ___ jours)  ☐ Non (permanent)
- Justification métier :
  _____________________________________________________________
  _____________________________________________________________

## Validation
- Manager direct : ☐ Approuvé  ☐ Refusé  Signature: ___________  Date: ______
- Responsable Sécurité : ☐ Approuvé  ☐ Refusé  Signature: ___________  Date: ______

## Traçabilité
- Date d'ajout : ____________
- Ajouté par : ____________
- Date de révision prévue : ____________
- Date de retrait (si temporaire) : ____________
```

---

## 🎓 Pièges courants à éviter

### ❌ Erreur #1 : Utiliser les comptes privilégiés au quotidien

**Mauvais :**

```powershell
# Se connecter avec admin-jdupont sur son poste de travail tous les jours
# pour lire ses emails et travailler normalement
```

**Bon :**

```powershell
# Utiliser jdupont (compte standard) pour le travail quotidien
# Basculer sur admin-jdupont uniquement depuis une PAW pour les tâches admin
```

---

### ❌ Erreur #2 : Laisser des membres permanents dans Schema/Enterprise Admins

**Mauvais :**

```powershell
# "Au cas où j'en ai besoin rapidement"
Add-ADGroupMember -Identity "Enterprise Admins" -Members "admin-principal"
```

**Bon :**

```powershell
# Ajouter uniquement au moment de la tâche, retirer immédiatement après
Add-ADGroupMember -Identity "Enterprise Admins" -Members "admin-principal"
# [Effectuer la tâche]
Remove-ADGroupMember -Identity "Enterprise Admins" -Members "admin-principal" -Confirm:$false
```

---

### ❌ Erreur #3 : Ajouter des comptes de service à Domain Admins

**Mauvais :**

```powershell
# "Le service ne démarre pas sans droits admin"
Add-ADGroupMember -Identity "Domain Admins" -Members "svc-application"
```

**Bon :**

```powershell
# Déléguer uniquement les permissions strictement nécessaires
$ou = "OU=Serveurs,DC=contoso,DC=com"
dsacls $ou /I:S /G "contoso\svc-application:RPWP;computer"
# Ou utiliser un gMSA avec délégation ciblée
```

---

### ❌ Erreur #4 : Partager des comptes administratifs

**Mauvais :**

```
Équipe IT partage le compte "admin-support" 
avec un seul mot de passe connu de tous
```

**Bon :**

```
Chaque administrateur a son propre compte :
- admin-jdupont
- admin-mmartin
- admin-pbernard
Traçabilité complète des actions
```

---

### ❌ Erreur #5 : Ne pas surveiller les modifications

**Mauvais :**

```
Pas d'audit, découverte 6 mois plus tard qu'un ex-employé 
est toujours dans Domain Admins
```

**Bon :**

```powershell
# Audit quotidien automatisé avec alertes
# Script planifié qui vérifie et notifie toute modification
```

---

## 📌 Résumé des points clés

> [!info] À retenir absolument
> 
> **Les 3 groupes les plus puissants :**
> 
> 1. **Schema Admins** → Modification du schéma (irréversible)
> 2. **Enterprise Admins** → Administration multi-domaines
> 3. **Domain Admins** → Administration d'un domaine
> 
> **Règles d'or :**
> 
> - Schema Admins et Enterprise Admins doivent rester **vides** par défaut
> - Chaque admin doit avoir **deux comptes** (standard + admin)
> - Utiliser les comptes admin **uniquement depuis des PAW**
> - **Jamais** de comptes de service dans les groupes privilégiés
> - **Auditer** systématiquement toutes les modifications
> - **Réviser** trimestriellement tous les membres
> - Appliquer le **principe du moindre privilège** systématiquement
> 
> **En cas de doute :**
> 
> - Privilégier la **délégation ciblée** plutôt que l'ajout à un groupe
> - Préférer les **groupes opérationnels** (Account Operators) plutôt que Domain Admins
> - Toujours **documenter** et **justifier** chaque ajout

---

## 🔍 Commandes PowerShell de référence rapide

```powershell
# ===== CONSULTATION =====

# Lister les membres d'un groupe
Get-ADGroupMember -Identity "Domain Admins"

# Lister tous les groupes privilégiés et leurs membres
"Domain Admins","Enterprise Admins","Schema Admins" | ForEach-Object {
    Write-Host "
=== $_ ===" -ForegroundColor Cyan
    Get-ADGroupMember -Identity $_ | Select-Object Name, SamAccountName
}

# Trouver tous les groupes dont un utilisateur est membre
Get-ADUser "jdupont" -Properties MemberOf | Select-Object -ExpandProperty MemberOf

# ===== MODIFICATIONS =====

# Ajouter un membre
Add-ADGroupMember -Identity "Domain Admins" -Members "admin-user"

# Retirer un membre
Remove-ADGroupMember -Identity "Domain Admins" -Members "admin-user" -Confirm:$false

# Ajouter plusieurs membres
Add-ADGroupMember -Identity "Account Operators" -Members "user1","user2","user
```