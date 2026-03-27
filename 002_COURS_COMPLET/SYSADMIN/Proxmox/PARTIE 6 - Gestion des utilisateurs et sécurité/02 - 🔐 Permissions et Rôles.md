

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

Le système de permissions de Proxmox VE est basé sur un modèle **RBAC** (Role-Based Access Control) sophistiqué qui permet de contrôler finement qui peut faire quoi sur quelles ressources.

> [!info] Principe fondamental Proxmox combine trois éléments pour déterminer les droits d'accès :
> 
> - **Utilisateur/Groupe** : Qui effectue l'action
> - **Rôle** : Quel ensemble de permissions
> - **Chemin** : Sur quelle ressource (VM, stockage, datacenter, etc.)

### Pourquoi c'est important ?

- **Sécurité** : Limiter les accès selon le principe du moindre privilège
- **Délégation** : Permettre aux équipes de gérer leurs propres ressources
- **Audit** : Tracer qui a fait quoi dans l'infrastructure
- **Multi-tenancy** : Isoler les ressources entre différents clients ou départements

---

## 🏗️ Architecture du système de permissions

### Structure hiérarchique des chemins

Proxmox utilise une structure de chemins pour identifier les ressources :

```
/                           # Racine (datacenter)
├── /access                 # Gestion des accès
│   ├── /access/users       # Utilisateurs
│   ├── /access/groups      # Groupes
│   └── /access/acl         # ACLs
├── /nodes                  # Tous les nœuds
│   └── /nodes/{node}       # Nœud spécifique
│       ├── /nodes/{node}/qemu      # VMs sur ce nœud
│       ├── /nodes/{node}/lxc       # Conteneurs sur ce nœud
│       └── /nodes/{node}/storage   # Stockage sur ce nœud
├── /storage                # Tous les stockages
│   └── /storage/{storage}  # Stockage spécifique
├── /pool                   # Tous les pools
│   └── /pool/{pool}        # Pool spécifique
├── /vms                    # Toutes les VMs
│   └── /vms/{vmid}         # VM spécifique
└── /sdn                    # Software Defined Network
```

> [!tip] Héritage des permissions Les permissions sont héritées dans l'arborescence. Une permission sur `/nodes` s'applique à tous les nœuds et leurs ressources.

### Les privilèges (Privileges)

Les privilèges sont les actions atomiques qu'un utilisateur peut effectuer :

|Catégorie|Privilèges|Description|
|---|---|---|
|**VM**|`VM.Allocate`|Créer/supprimer des VMs|
||`VM.Migrate`|Migrer des VMs|
||`VM.PowerMgmt`|Démarrer/arrêter des VMs|
||`VM.Console`|Accéder à la console|
||`VM.Config.*`|Modifier la configuration|
||`VM.Audit`|Voir les infos sans modification|
||`VM.Backup`|Créer des sauvegardes|
||`VM.Clone`|Cloner des VMs|
||`VM.Snapshot`|Créer des snapshots|
|**Datastore**|`Datastore.Allocate`|Créer des volumes|
||`Datastore.AllocateSpace`|Utiliser l'espace|
||`Datastore.Audit`|Voir les infos du stockage|
||`Datastore.AllocateTemplate`|Charger des templates|
|**User**|`User.Modify`|Modifier les utilisateurs|
||`Permissions.Modify`|Modifier les permissions|
|**System**|`Sys.Audit`|Voir la config système|
||`Sys.Modify`|Modifier la config système|
||`Sys.Console`|Console système|
||`Sys.Syslog`|Voir les logs système|
||`Sys.PowerMgmt`|Gérer l'alimentation du nœud|
|**Pool**|`Pool.Allocate`|Créer/supprimer des pools|
||`Pool.Audit`|Voir les pools|

> [!example] Exemple de privilège composé Pour permettre à un utilisateur de gérer complètement une VM, il faut plusieurs privilèges :
> 
> - `VM.PowerMgmt` : démarrer/arrêter
> - `VM.Console` : accéder à la console
> - `VM.Config.Disk` : modifier les disques
> - `VM.Config.Network` : modifier le réseau

### Propagation des permissions

```bash
# Vérifier les permissions effectives d'un utilisateur
pveum user permissions user@pve

# Afficher toutes les ACL du système
pveum acl list
```

> [!warning] Attention à la propagation Une permission sur `/` donne des droits sur **tout** le datacenter. Soyez très prudent avec les permissions à la racine.

---

## 🎭 Rôles prédéfinis

Proxmox fournit plusieurs rôles prêts à l'emploi, chacun avec un ensemble cohérent de privilèges.

### 1. Administrator (admin)

**Le super-utilisateur** - Tous les privilèges sur tout.

```bash
# Voir les privilèges du rôle Administrator
pveum role list Administrator
```

**Privilèges inclus** : `ALL` (tous les privilèges)

**Cas d'usage** :

- Administrateurs système complets
- Gestion de l'infrastructure complète
- Configuration du cluster

> [!warning] À utiliser avec parcimonie N'accordez ce rôle qu'aux personnes ayant besoin d'un accès complet. Préférez des rôles plus restreints pour la majorité des utilisateurs.

### 2. PVEAdmin

**Administrateur de virtualisation** - Peut tout faire sauf gérer les utilisateurs et les permissions.

**Privilèges inclus** :

- `VM.*` (toutes les opérations VM)
- `Datastore.*` (gestion du stockage)
- `Pool.*` (gestion des pools)
- `Sys.Audit`, `Sys.Console`, `Sys.Syslog` (système en lecture)

**Cas d'usage** :

- Administrateurs de VMs
- Équipes DevOps gérant l'infrastructure virtuelle
- Support technique niveau 2

```bash
# Attribuer PVEAdmin à un utilisateur sur tout le datacenter
pveum acl modify / -user admin@pve -role PVEAdmin
```

### 3. PVEAuditor

**Audit en lecture seule** - Peut tout voir mais rien modifier.

**Privilèges inclus** :

- `VM.Audit`
- `Datastore.Audit`
- `Sys.Audit`
- `Pool.Audit`

**Cas d'usage** :

- Équipes d'audit
- Monitoring et supervision
- Managers nécessitant une vue d'ensemble

```bash
# Créer un utilisateur auditeur
pveum user add auditor@pve --comment "Compte audit"
pveum acl modify / -user auditor@pve -role PVEAuditor
```

> [!tip] Idéal pour le monitoring Utilisez ce rôle pour les comptes de monitoring (Nagios, Zabbix, etc.) qui ont besoin de lire les métriques sans pouvoir modifier quoi que ce soit.

### 4. PVEVMAdmin

**Administrateur de VMs** - Gestion complète des VMs mais pas du stockage ni des nœuds.

**Privilèges inclus** :

- `VM.*` (toutes les opérations VM)
- `Datastore.AllocateSpace` (utiliser l'espace uniquement)

**Cas d'usage** :

- Développeurs gérant leurs propres VMs
- Équipes projet avec leurs propres ressources
- Environnements de test/dev

```bash
# Donner PVEVMAdmin à un utilisateur sur un pool spécifique
pveum acl modify /pool/dev-team -user dev-user@pve -role PVEVMAdmin
```

### 5. PVEVMUser

**Utilisateur de VMs** - Peut utiliser les VMs existantes mais pas les créer.

**Privilèges inclus** :

- `VM.Console`
- `VM.PowerMgmt`
- `VM.Config.CDROM` (pour monter des ISOs)

**Cas d'usage** :

- Utilisateurs finaux
- Stagiaires avec accès limité
- Environnements de formation

```bash
# Donner accès console uniquement à une VM spécifique
pveum acl modify /vms/100 -user stagiaire@pve -role PVEVMUser
```

> [!info] Combinaison fréquente Souvent utilisé avec `VM.Backup` pour permettre aux utilisateurs de créer leurs propres sauvegardes.

### 6. PVEDatastoreUser

**Utilisateur de stockage** - Peut voir et utiliser l'espace de stockage.

**Privilèges inclus** :

- `Datastore.AllocateSpace`
- `Datastore.Audit`

**Cas d'usage** :

- Backup des VMs
- Téléchargement d'ISOs
- Stockage de fichiers

### 7. PVEDatastoreAdmin

**Administrateur de stockage** - Gestion complète du stockage.

**Privilèges inclus** :

- `Datastore.*` (tous les privilèges stockage)

**Cas d'usage** :

- Administrateurs stockage
- Gestion des backups
- Maintenance du stockage

### 8. PVETemplateUser

**Utilisateur de templates** - Peut utiliser des templates pour créer des VMs.

**Privilèges inclus** :

- `VM.Allocate`
- `VM.Clone`
- `Datastore.AllocateTemplate`

**Cas d'usage** :

- Déploiement automatisé
- Self-service de VMs
- Environnements standardisés

### 9. PVEPoolAdmin

**Administrateur de pool** - Gestion complète d'un pool de ressources.

**Privilèges inclus** :

- `Pool.Allocate`
- `VM.Allocate`
- `VM.*`
- `Datastore.AllocateSpace`

**Cas d'usage** :

- Chef de projet gérant son pool
- Délégation par département
- Multi-tenancy

### 10. PVEPoolUser

**Utilisateur de pool** - Utilisation des ressources d'un pool.

**Privilèges inclus** :

- `VM.Console`
- `VM.PowerMgmt`
- `Pool.Audit`

**Cas d'usage** :

- Membres d'équipe
- Utilisateurs avec accès limité
- Environnements partagés

### Tableau récapitulatif

|Rôle|Créer VM|Modifier VM|Console|Gérer Stockage|Gérer Users|
|---|---|---|---|---|---|
|Administrator|✅|✅|✅|✅|✅|
|PVEAdmin|✅|✅|✅|✅|❌|
|PVEAuditor|❌|❌|❌|❌|❌|
|PVEVMAdmin|✅|✅|✅|🟡 Utiliser|❌|
|PVEVMUser|❌|🟡 Limité|✅|❌|❌|
|PVEDatastoreAdmin|❌|❌|❌|✅|❌|
|PVEDatastoreUser|❌|❌|❌|🟡 Utiliser|❌|
|PVETemplateUser|🟡 Template|❌|❌|🟡 Template|❌|
|PVEPoolAdmin|✅|✅|✅|🟡 Pool|❌|
|PVEPoolUser|❌|❌|✅|❌|❌|

---

## ⚙️ Création de rôles personnalisés

### Pourquoi créer des rôles personnalisés ?

Les rôles prédéfinis couvrent les cas d'usage communs, mais vous aurez souvent besoin de rôles sur mesure pour :

- **Conformité** : Respecter les politiques de sécurité de l'entreprise
- **Séparation des tâches** : Diviser les responsabilités précisément
- **Automatisation** : Créer des comptes API avec privilèges minimaux
- **Cas spécifiques** : Gérer des situations non couvertes par les rôles standards

### Syntaxe de création

```bash
# Créer un rôle vide
pveum role add <nom-role> --comment "Description du rôle"

# Ajouter des privilèges à un rôle
pveum role modify <nom-role> --privs <privilege1>,<privilege2>,...

# Voir les détails d'un rôle
pveum role list <nom-role>

# Supprimer un rôle (si non utilisé)
pveum role delete <nom-role>
```

> [!warning] Rôles en lecture seule Les rôles prédéfinis (Administrator, PVEAdmin, etc.) ne peuvent pas être modifiés. Vous devez créer de nouveaux rôles.

### Exemple 1 : Rôle "Backup Operator"

Un rôle pour un compte dédié aux sauvegardes automatiques.

```bash
# Créer le rôle
pveum role add BackupOperator --comment "Compte de backup automatique"

# Ajouter les privilèges nécessaires
pveum role modify BackupOperator --privs VM.Backup,VM.Audit,Datastore.AllocateSpace,Datastore.Audit

# Vérifier
pveum role list BackupOperator
```

**Privilèges inclus** :

- `VM.Backup` : Créer des sauvegardes
- `VM.Audit` : Lister les VMs à sauvegarder
- `Datastore.AllocateSpace` : Écrire les backups
- `Datastore.Audit` : Vérifier l'espace disponible

**Attribution** :

```bash
# Créer un utilisateur pour les backups
pveum user add backup@pve --comment "Compte automatique PBS"

# Attribuer le rôle sur tout le datacenter
pveum acl modify / -user backup@pve -role BackupOperator
```

### Exemple 2 : Rôle "Developer"

Pour des développeurs qui gèrent leurs VMs de dev/test.

```bash
# Créer le rôle
pveum role add Developer --comment "Développeur avec gestion VMs limitée"

# Privilèges pour gérer complètement les VMs
pveum role modify Developer --privs \
    VM.Allocate,\
    VM.Clone,\
    VM.PowerMgmt,\
    VM.Console,\
    VM.Config.Disk,\
    VM.Config.CPU,\
    VM.Config.Memory,\
    VM.Config.Network,\
    VM.Config.Options,\
    VM.Snapshot,\
    VM.Audit,\
    Datastore.AllocateSpace,\
    Datastore.Audit,\
    Pool.Audit
```

> [!tip] Limiter la portée Attribuez ce rôle uniquement sur un pool de développement, pas sur tout le datacenter.

```bash
# Attribution sur un pool spécifique
pveum acl modify /pool/dev-environment -user developer@pve -role Developer
```

### Exemple 3 : Rôle "Network Manager"

Pour un administrateur réseau qui gère uniquement les configurations réseau.

```bash
# Créer le rôle
pveum role add NetworkManager --comment "Gestion réseau des VMs"

# Privilèges réseau uniquement
pveum role modify NetworkManager --privs \
    VM.Config.Network,\
    VM.Audit,\
    Sys.Audit
```

**Cas d'usage** : Permettre à l'équipe réseau de modifier les configurations réseau des VMs sans pouvoir toucher aux autres paramètres.

### Exemple 4 : Rôle "Template Manager"

Pour gérer les templates sans pouvoir créer de VMs.

```bash
# Créer le rôle
pveum role add TemplateManager --comment "Gestion des templates uniquement"

# Privilèges templates
pveum role modify TemplateManager --privs \
    VM.Allocate,\
    VM.Clone,\
    VM.Config.Disk,\
    Datastore.AllocateTemplate,\
    Datastore.Audit
```

### Exemple 5 : Rôle "ReadOnly Plus"

Audit avec accès console (pour le support).

```bash
# Créer le rôle
pveum role add ReadOnlyPlus --comment "Lecture + console pour support"

# Lecture + console
pveum role modify ReadOnlyPlus --privs \
    VM.Audit,\
    VM.Console,\
    Datastore.Audit,\
    Sys.Audit,\
    Pool.Audit
```

### Exemple 6 : Rôle "Monitoring API"

Pour un système de monitoring externe (Prometheus, Grafana, etc.).

```bash
# Créer le rôle
pveum role add MonitoringAPI --comment "Compte API monitoring externe"

# Privilèges lecture uniquement
pveum role modify MonitoringAPI --privs \
    VM.Audit,\
    Datastore.Audit,\
    Sys.Audit,\
    Pool.Audit

# Créer un token API pour ce rôle
pveum user token add monitoring@pve monitoring-token --privsep 1
pveum acl modify / -token 'monitoring@pve!monitoring-token' -role MonitoringAPI
```

> [!info] Privilège de séparation (--privsep) Avec `--privsep 1`, le token a ses propres permissions indépendantes de l'utilisateur. C'est recommandé pour la sécurité.

### Liste des privilèges disponibles

Pour voir tous les privilèges disponibles :

```bash
# Lister tous les privilèges
pveum role list Administrator | grep -E '^\s+'

# Ou consulter la documentation
cat /usr/share/perl5/PVE/AccessControl.pm | grep -A 1 "add_role_privs"
```

**Catégories complètes** :

```
VM.Allocate
VM.Migrate
VM.PowerMgmt
VM.Console
VM.Monitor
VM.Backup
VM.Audit
VM.Clone
VM.Snapshot
VM.Snapshot.Rollback
VM.Config.Disk
VM.Config.CDROM
VM.Config.CPU
VM.Config.Memory
VM.Config.Network
VM.Config.HWType
VM.Config.Options
VM.Config.Cloudinit

Datastore.Allocate
Datastore.AllocateSpace
Datastore.AllocateTemplate
Datastore.Audit

Permissions.Modify
User.Modify

Sys.PowerMgmt
Sys.Modify
Sys.Audit
Sys.Console
Sys.Syslog

Pool.Allocate
Pool.Audit

SDN.Allocate
SDN.Audit
SDN.Use
```

### Pièges courants

> [!warning] Piège 1 : Oublier les privilèges de lecture Un utilisateur avec `VM.PowerMgmt` mais sans `VM.Audit` ne verra même pas les VMs dans l'interface. Pensez toujours à inclure les privilèges `*.Audit`.

> [!warning] Piège 2 : Privilèges insuffisants pour l'interface Web L'interface Web nécessite certains privilèges de base. Un rôle trop restrictif empêchera la connexion.

> [!warning] Piège 3 : Confusion entre rôle et ACL Créer un rôle ne donne aucun accès. Il faut ensuite l'attribuer via une ACL sur un chemin.

### Bonnes pratiques pour les rôles personnalisés

1. **Nommage clair** : Utilisez des noms explicites (`BackupOperator`, pas `Role1`)
2. **Documentation** : Utilisez `--comment` pour expliquer l'usage
3. **Principe du moindre privilège** : N'ajoutez que les privilèges strictement nécessaires
4. **Tests** : Testez toujours avec un utilisateur test avant déploiement
5. **Versioning** : Documentez les modifications des rôles

```bash
# Exporter la configuration des rôles pour backup
pveum role list > /root/roles-backup-$(date +%Y%m%d).txt
```

---

## 🎯 Attribution de permissions

Une fois les rôles créés (prédéfinis ou personnalisés), il faut les **attribuer** aux utilisateurs sur des ressources spécifiques via les **ACL** (Access Control Lists).

### Structure d'une ACL

```
Chemin + Utilisateur/Groupe/Token + Rôle = Permission
```

### Syntaxe de base

```bash
# Attribuer un rôle à un utilisateur
pveum acl modify <chemin> -user <user@realm> -role <role>

# Attribuer un rôle à un groupe
pveum acl modify <chemin> -group <group> -role <role>

# Attribuer un rôle à un token API
pveum acl modify <chemin> -token <user@realm!tokenid> -role <role>

# Supprimer une permission
pveum acl delete <chemin> -user <user@realm> -role <role>

# Lister toutes les ACL
pveum acl list

# Lister les ACL d'un chemin spécifique
pveum acl list <chemin>
```

### Chemins d'attribution

#### 1. Attribution au niveau Datacenter

**Chemin** : `/`

Donne accès à **toutes** les ressources du datacenter.

```bash
# Administrateur complet
pveum acl modify / -user admin@pve -role Administrator

# Auditeur sur tout
pveum acl modify / -user audit@pve -role PVEAuditor
```

> [!warning] Très permissif N'utilisez `/` que pour les administrateurs ou les comptes de monitoring globaux.

#### 2. Attribution sur un nœud

**Chemin** : `/nodes/{nodename}`

Donne accès à un nœud spécifique et toutes ses ressources (VMs, stockage local, etc.).

```bash
# Administrateur du nœud pve-node1
pveum acl modify /nodes/pve-node1 -user nodeadmin@pve -role PVEAdmin

# Accès console uniquement sur ce nœud
pveum acl modify /nodes/pve-node1 -user operator@pve -role PVEVMUser
```

**Cas d'usage** :

- Administrateurs par site physique
- Maintenance localisée
- Isolation géographique

#### 3. Attribution sur un stockage

**Chemin** : `/storage/{storagename}`

Donne accès à un stockage spécifique.

```bash
# Administrateur du stockage NFS
pveum acl modify /storage/nfs-storage -user storageadmin@pve -role PVEDatastoreAdmin

# Utilisateur peut uploader sur ce stockage
pveum acl modify /storage/iso-storage -user user@pve -role PVEDatastoreUser
```

**Cas d'usage** :

- Délégation par type de stockage (backup, ISO, templates)
- Quotas et gestion d'espace
- Séparation dev/prod

#### 4. Attribution sur une VM spécifique

**Chemin** : `/vms/{vmid}`

Donne accès à une seule VM.

```bash
# Propriétaire de la VM 100
pveum acl modify /vms/100 -user owner@pve -role PVEVMAdmin

# Utilisateur peut juste utiliser la console
pveum acl modify /vms/100 -user viewer@pve -role PVEVMUser
```

**Cas d'usage** :

- Attribution individuelle de VMs
- Environnements multi-clients
- VMs personnelles

> [!tip] VM ID vs Chemin nœud `/vms/{vmid}` fonctionne même si la VM est migrée vers un autre nœud. C'est préférable à `/nodes/{node}/qemu/{vmid}`.

#### 5. Attribution sur un Pool

**Chemin** : `/pool/{poolname}`

Donne accès à toutes les ressources d'un pool.

```bash
# Administrateur du pool de développement
pveum acl modify /pool/dev-pool -user devlead@pve -role PVEPoolAdmin

# Utilisateur du pool
pveum acl modify /pool/dev-pool -user developer@pve -role PVEPoolUser
```

**Cas d'usage** : **LA MEILLEURE PRATIQUE**

- Gestion par projet ou département
- Multi-tenancy
- Délégation organisée

> [!tip] Pools : la solution recommandée Les pools sont le moyen le plus propre de gérer les permissions à grande échelle. Créez des pools par projet/équipe et gérez les permissions au niveau pool.

### Gestion des Pools

#### Créer un pool

```bash
# Créer un pool
pveum pool add <poolname> --comment "Description"

# Exemple
pveum pool add production --comment "VMs de production"
pveum pool add dev-team-a --comment "Équipe Dev A"
```

#### Ajouter des ressources à un pool

```bash
# Ajouter une VM au pool
pveum pool modify <poolname> --vms <vmid>

# Ajouter plusieurs VMs
pveum pool modify production --vms 100,101,102

# Ajouter un stockage au pool
pveum pool modify <poolname> --storage <storagename>

# Exemple complet
pveum pool modify dev-team-a --vms 200,201,202 --storage dev-storage
```

#### Retirer des ressources d'un pool

```bash
# Retirer une VM
pveum pool modify <poolname> --delete --vms <vmid>

# Retirer plusieurs VMs
pveum pool modify dev-team-a --delete --vms 200,201
```

#### Voir le contenu d'un pool

```bash
# Lister les pools
pveum pool list

# Détails d'un pool
pveum pool list <poolname>
```

#### Supprimer un pool

```bash
# Supprimer un pool (doit être vide)
pveum pool delete <poolname>
```

### Scénarios d'attribution complexes

#### Scénario 1 : Équipe multi-rôles sur un pool

Une équipe avec un chef de projet admin et des développeurs utilisateurs.

```bash
# Créer le pool
pveum pool add project-alpha --comment "Projet Alpha"

# Ajouter les VMs au pool
pveum pool modify project-alpha --vms 300,301,302,303

# Chef de projet : admin complet du pool
pveum acl modify /pool/project-alpha -user chef@pve -role PVEPoolAdmin

# Développeurs : peuvent utiliser les VMs
pveum acl modify /pool/project-alpha -user dev1@pve -role PVEPoolUser
pveum acl modify /pool/project-alpha -user dev2@pve -role PVEPoolUser

# Ops : peuvent créer des backups
pveum acl modify /pool/project-alpha -user ops@pve -role BackupOperator
```

#### Scénario 2 : Multi-tenancy par client

Chaque client a son propre pool isolé.

```bash
# Client A
pveum pool add client-a --comment "Client A - Environnement isolé"
pveum pool modify client-a --vms 400,401,402
pveum acl modify /pool/client-a -user clienta-admin@pve -role PVEPoolAdmin

# Client B
pveum pool add client-b --comment "Client B - Environnement isolé"
pveum pool modify client-b --vms 410,411,412
pveum acl modify /pool/client-b -user clientb-admin@pve -role PVEPoolAdmin

# Admin général peut auditer tous les pools
pveum acl modify / -user superadmin@pve -role Administrator
```

> [!info] Isolation Les utilisateurs ne voient que les ressources de leur pool. L'isolation est forte.

#### Scénario 3 : Permissions cumulatives

Un utilisateur peut avoir plusieurs rôles sur différentes ressources.

```bash
# User peut gérer le pool dev
pveum acl modify /pool/dev-pool -user user@pve -role PVEPoolAdmin

# Mais seulement voir (audit) les VMs de production
pveum acl modify /pool/prod-pool -user user@pve -role PVEAuditor

# Et a un accès complet à sa VM personnelle
pveum acl modify /vms/999 -user user@pve -role PVEVMAdmin
```

#### Scénario 4 : Accès temporaire

Donner un accès temporaire à un consultant externe.

```bash
# Créer un utilisateur temporaire
pveum user add consultant@pve --expire $(date -d '+30 days' +%s) --comment "Accès 30 jours"

# Donner accès limité
pveum acl modify /vms/500 -user consultant@pve -role PVEVMUser
```

> [!tip] Expiration automatique L'utilisateur sera automatiquement désactivé après 30 jours.

#### Scénario 5 : Groupes pour simplifier la gestion

Utiliser des groupes pour gérer plusieurs utilisateurs simultanément.

```bash
# Créer un groupe
pveum group add dev-team --comment "Équipe de développement"

# Ajouter des utilisateurs au groupe
pveum user modify dev1@pve -group dev-team
pveum user modify dev2@pve -group dev-team
pveum user modify dev3@pve -group dev-team

# Attribuer le rôle au groupe (tous les membres héritent)
pveum acl modify /pool/dev-pool -group dev-team -role PVEPoolAdmin

# Ajouter un nouveau développeur = automatiquement les bonnes permissions
pveum user add dev4@pve
pveum user modify dev4@pve -group dev-team
```

**Avantages** :

- Gestion centralisée
- Modifications en masse
- Moins d'erreurs
- Audit simplifié

#### Scénario 6 : Séparation prod/dev/test

Environnements strictement séparés avec permissions appropriées.

```bash
# Pool Production - accès très restreint
pveum pool add production --comment "Production - accès contrôlé"
pveum pool modify production --vms 100,101,102
pveum acl modify /pool/production -user prodadmin@pve -role PVEVMAdmin
pveum acl modify /pool/production -group dev-team -role PVEAuditor  # Lecture seule

# Pool Staging - équipe ops
pveum pool add staging --comment "Staging - pré-production"
pveum pool modify staging --vms 200,201,202
pveum acl modify /pool/staging -group ops-team -role PVEPoolAdmin

# Pool Dev - développeurs ont tout accès
pveum pool add development --comment "Développement - libre"
pveum pool modify development --vms 300,301,302,303,304
pveum acl modify /pool/development -group dev-team -role PVEPoolAdmin
```

### Permissions héritées et propagation

```bash
# Permission sur le datacenter (se propage partout)
pveum acl modify / -user global-admin@pve -role Administrator

# Permission sur un nœud (se propage aux VMs du nœud)
pveum acl modify /nodes/pve1 -user node-admin@pve -role PVEAdmin

# Permission spécifique sur une VM (prioritaire)
pveum acl modify /vms/100 -user vm-owner@pve -role PVEVMAdmin
```

> [!info] Règle de résolution Quand plusieurs ACL s'appliquent, Proxmox utilise la **plus spécifique** :
> 
> 1. Permission directe sur la ressource (plus spécifique)
> 2. Permission sur le pool contenant la ressource
> 3. Permission sur le nœud
> 4. Permission sur le datacenter (moins spécifique)

### Propagation avec option `--propagate`

```bash
# Par défaut, les permissions se propagent aux sous-ressources
pveum acl modify /nodes/pve1 -user admin@pve -role PVEAdmin

# Désactiver la propagation (permission uniquement sur ce niveau)
pveum acl modify /nodes/pve1 -user limited@pve -role PVEAuditor -propagate 0
```

> [!warning] Propagate=0 : cas rare La désactivation de la propagation est rarement nécessaire. N'utilisez ceci que si vous comprenez vraiment les implications.

### Vérification des permissions

#### Voir les permissions d'un utilisateur

```bash
# Toutes les permissions effectives d'un utilisateur
pveum user permissions user@pve

# Format plus lisible
pveum user permissions user@pve | column -t
```

#### Voir qui a accès à une ressource

```bash
# Lister les ACL sur un chemin
pveum acl list /pool/dev-pool

# Toutes les ACL du système
pveum acl list | grep "user@pve"
```

#### Tester les permissions

```bash
# Se connecter en tant qu'utilisateur pour tester
# (via l'interface web ou API)

# Ou simuler avec pvesh (API shell)
pvesh get /access/permissions -path /vms/100 -userid user@pve
```

### Suppression de permissions

```bash
# Supprimer une ACL spécifique
pveum acl delete /pool/dev-pool -user dev1@pve -role PVEPoolAdmin

# Supprimer toutes les ACL d'un utilisateur sur un chemin
pveum acl delete /pool/dev-pool -user dev1@pve

# Attention : ne supprime pas l'utilisateur, juste ses permissions
```

> [!warning] Vérifier avant suppression Listez toujours les ACL avant de les supprimer pour éviter les mauvaises surprises.

```bash
# Vérifier avant
pveum acl list /pool/dev-pool

# Supprimer
pveum acl delete /pool/dev-pool -user dev1@pve -role PVEPoolAdmin

# Vérifier après
pveum acl list /pool/dev-pool
```

### Tokens API et permissions

Les tokens API permettent d'utiliser l'API Proxmox sans mot de passe, idéal pour l'automatisation.

#### Créer un token avec ses propres permissions

```bash
# Créer un utilisateur pour l'API
pveum user add api-monitoring@pve --comment "Compte monitoring"

# Créer un token avec séparation de privilèges
pveum user token add api-monitoring@pve monitoring-token --privsep 1

# Attribuer des permissions AU TOKEN (pas à l'utilisateur)
pveum acl modify / -token 'api-monitoring@pve!monitoring-token' -role PVEAuditor

# Récupérer le secret du token (affiché une seule fois !)
# Exemple de sortie : "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

> [!warning] Secret unique Le secret du token n'est affiché qu'une fois à la création. Sauvegardez-le immédiatement dans un gestionnaire de secrets.

#### Token sans séparation de privilèges

```bash
# Token utilise les permissions de l'utilisateur
pveum user token add backup@pve backup-token --privsep 0

# Les permissions sont celles de l'utilisateur backup@pve
pveum acl modify / -user backup@pve -role BackupOperator
```

**Différence** :

- `--privsep 1` : Token a ses propres permissions (recommandé, plus sûr)
- `--privsep 0` : Token hérite des permissions de l'utilisateur

#### Utilisation du token

```bash
# Format d'authentification API
# Authorization: PVEAPIToken=USER@REALM!TOKENID=SECRET

# Exemple avec curl
curl -k -H "Authorization: PVEAPIToken=api-monitoring@pve!monitoring-token=xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx" \
  https://proxmox-server:8006/api2/json/cluster/resources
```

#### Lister et gérer les tokens

```bash
# Lister les tokens d'un utilisateur
pveum user token list api-monitoring@pve

# Supprimer un token
pveum user token delete api-monitoring@pve monitoring-token

# Modifier l'expiration d'un token
pveum user token modify api-monitoring@pve monitoring-token --expire $(date -d '+90 days' +%s)
```

### Audit et traçabilité

#### Voir l'historique des connexions

```bash
# Logs d'authentification
grep -i "authentication" /var/log/pve/auth.log

# Qui s'est connecté récemment
journalctl -u pvedaemon | grep "authentication.*successful"
```

#### Audit des modifications de permissions

```bash
# Historique des tâches (inclut modifications ACL)
pvesh get /cluster/tasks

# Logs système pour les modifications d'ACL
grep "pveum acl" /var/log/syslog
```

#### Exporter la configuration pour backup

```bash
# Exporter toutes les ACL
pveum acl list > /root/acl-backup-$(date +%Y%m%d).txt

# Exporter tous les utilisateurs
pveum user list > /root/users-backup-$(date +%Y%m%d).txt

# Exporter tous les rôles
pveum role list > /root/roles-backup-$(date +%Y%m%d).txt

# Exporter tous les groupes
pveum group list > /root/groups-backup-$(date +%Y%m%d).txt

# Ou tout en un
{
  echo "=== ACL ==="
  pveum acl list
  echo "=== USERS ==="
  pveum user list
  echo "=== ROLES ==="
  pveum role list
  echo "=== GROUPS ==="
  pveum group list
} > /root/permissions-full-backup-$(date +%Y%m%d).txt
```

---

## 💡 Bonnes pratiques

### 1. Principe du moindre privilège

> [!tip] Règle d'or Donnez toujours le **minimum** de permissions nécessaires pour accomplir la tâche.

**Mauvais** :

```bash
# Donner Administrator à tout le monde
pveum acl modify / -user dev@pve -role Administrator
```

**Bon** :

```bash
# Donner accès uniquement au pool dev
pveum acl modify /pool/dev-pool -user dev@pve -role PVEPoolUser
```

### 2. Utiliser les pools systématiquement

> [!tip] Organisation par pools Créez des pools pour chaque projet, équipe, ou client. Gérez les permissions au niveau pool.

**Structure recommandée** :

```
pools/
├── production/       # VMs critiques
├── staging/          # Pré-production
├── development/      # Dev/test
├── client-a/         # Multi-tenancy
├── client-b/
└── infrastructure/   # VMs système (monitoring, etc.)
```

```bash
# Créer la structure
for pool in production staging development infrastructure; do
    pveum pool add $pool --comment "Pool $pool"
done
```

### 3. Groupes pour simplifier la gestion

> [!tip] Groupes avant utilisateurs individuels Attribuez les permissions aux **groupes**, pas aux utilisateurs individuels.

```bash
# Créer les groupes par fonction
pveum group add admins --comment "Administrateurs système"
pveum group add developers --comment "Développeurs"
pveum group add operations --comment "Équipe ops"

# Attribuer les permissions aux groupes
pveum acl modify / -group admins -role Administrator
pveum acl modify /pool/development -group developers -role PVEPoolAdmin
pveum acl modify /pool/production -group operations -role PVEVMAdmin

# Ajouter les utilisateurs aux groupes
pveum user modify alice@pve -group admins
pveum user modify bob@pve -group developers
pveum user modify charlie@pve -group operations
```

### 4. Tokens API avec privsep

> [!tip] Toujours --privsep 1 pour l'automatisation Les tokens API doivent avoir leurs propres permissions, séparées de l'utilisateur.

```bash
# BON : Token avec ses propres permissions
pveum user token add automation@pve deploy-token --privsep 1
pveum acl modify /pool/production -token 'automation@pve!deploy-token' -role CustomDeployRole

# ÉVITER : Token hérite de l'utilisateur (moins sûr)
pveum user token add automation@pve deploy-token --privsep 0
```

### 5. Documentation et commentaires

> [!tip] Documentez TOUT Utilisez `--comment` partout pour expliquer le but de chaque élément.

```bash
# Utilisateurs
pveum user add monitoring@pve --comment "Compte Zabbix - surveillance infrastructure"

# Rôles
pveum role add CustomBackup --comment "Backup nightly automatique PBS"

# Pools
pveum pool add client-x --comment "Client X - Contrat #12345 - Expire 2025-12-31"

# ACL via script avec commentaire
echo "# Attribution accès dev-team au pool development - Ticket #456" >> /root/acl-changes.log
pveum acl modify /pool/development -group dev-team -role PVEPoolAdmin
```

### 6. Révision régulière des permissions

> [!warning] Audit trimestriel Révisez les permissions tous les 3 mois minimum.

Script d'audit :

```bash
#!/bin/bash
# audit-permissions.sh

echo "=== Audit des permissions Proxmox ==="
echo "Date: $(date)"
echo ""

echo "=== Utilisateurs avec rôle Administrator ==="
pveum acl list | grep Administrator

echo ""
echo "=== Permissions sur la racine (/) ==="
pveum acl list /

echo ""
echo "=== Tokens API actifs ==="
for user in $(pveum user list | grep -v "┌\|│\|└" | awk '{print $1}'); do
    tokens=$(pveum user token list $user 2>/dev/null)
    if [ ! -z "$tokens" ]; then
        echo "User: $user"
        echo "$tokens"
        echo ""
    fi
done

echo ""
echo "=== Utilisateurs n'ayant pas de permissions ==="
for user in $(pveum user list | grep -v "┌\|│\|└" | awk '{print $1}'); do
    perms=$(pveum user permissions $user 2>/dev/null)
    if [ -z "$perms" ]; then
        echo "$user"
    fi
done
```

### 7. Expiration des comptes temporaires

> [!tip] Toujours définir une expiration pour les comptes temporaires

```bash
# Consultant pour 2 mois
pveum user add consultant@pve \
    --expire $(date -d '+60 days' +%s) \
    --comment "Consultant externe - Projet Alpha - Expire $(date -d '+60 days' +%Y-%m-%d)"

# Stagiaire pour 3 mois
pveum user add stagiaire@pve \
    --expire $(date -d '+90 days' +%s) \
    --comment "Stagiaire été - Expire $(date -d '+90 days' +%Y-%m-%d)"
```

### 8. Séparation des environnements

> [!tip] Prod/Staging/Dev strictement séparés

```bash
# Production : accès minimal, audit strict
pveum pool add production
pveum acl modify /pool/production -group prod-admins -role PVEVMAdmin
pveum acl modify /pool/production -group developers -role PVEAuditor  # Lecture seule

# Staging : ops peuvent tout faire
pveum pool add staging
pveum acl modify /pool/staging -group ops-team -role PVEPoolAdmin

# Dev : développeurs autonomes
pveum pool add development
pveum acl modify /pool/development -group developers -role PVEPoolAdmin
```

### 9. Backup de la configuration

> [!warning] Backup automatique Sauvegardez régulièrement la configuration des permissions.

```bash
# Script de backup quotidien
cat << 'EOF' > /etc/cron.daily/backup-proxmox-permissions
#!/bin/bash
BACKUP_DIR="/var/backups/proxmox-permissions"
mkdir -p $BACKUP_DIR

DATE=$(date +%Y%m%d)
{
  echo "=== ACL ==="
  pveum acl list
  echo ""
  echo "=== USERS ==="
  pveum user list
  echo ""
  echo "=== GROUPS ==="
  pveum group list
  echo ""
  echo "=== ROLES ==="
  pveum role list
  echo ""
  echo "=== POOLS ==="
  pveum pool list
} > "$BACKUP_DIR/permissions-$DATE.txt"

# Garder 30 jours
find $BACKUP_DIR -name "permissions-*.txt" -mtime +30 -delete
EOF

chmod +x /etc/cron.daily/backup-proxmox-permissions
```

### 10. Nomenclature cohérente

> [!tip] Standards de nommage Utilisez une nomenclature cohérente pour tous les éléments.

**Exemple de convention** :

```bash
# Utilisateurs : prenom.nom@realm
alice.dupont@pve
bob.martin@ldap

# Groupes : fonction-equipe
admins-infra
devs-team-a
ops-production

# Pools : environnement-projet
prod-app-web
staging-app-mobile
dev-team-alpha

# Rôles custom : Prefix + Description
Custom_BackupOperator
Custom_NetworkManager
Custom_ReadOnlyPlus

# Tokens : utilisateur + fonction
monitoring@pve!zabbix-token
automation@pve!deploy-token
backup@pve!pbs-token
```

### 11. Tester avant déploiement

> [!warning] Toujours tester Créez un utilisateur test pour valider les permissions avant attribution.

```bash
# Créer un utilisateur test
pveum user add test-user@pve --comment "COMPTE TEST - NE PAS UTILISER"

# Attribuer les permissions à tester
pveum acl modify /pool/dev-pool -user test-user@pve -role CustomDevelopeur

# Se connecter avec ce compte pour tester
# Vérifier :
# - Voit-on bien les bonnes ressources ?
# - Peut-on faire les actions attendues ?
# - Ne peut-on PAS faire les actions interdites ?

# Supprimer après test
pveum user delete test-user@pve
```

### 12. Pièges à éviter

> [!warning] Erreurs courantes

❌ **Donner Administrator par facilité**

```bash
# MAUVAIS : tout le monde admin
pveum acl modify / -user dev@pve -role Administrator
```

✅ **Utiliser le rôle approprié**

```bash
# BON : juste ce qu'il faut
pveum acl modify /pool/dev-pool -user dev@pve -role PVEPoolAdmin
```

---

❌ **Oublier les privilèges Audit**

```bash
# MAUVAIS : utilisateur ne verra rien
pveum role add CustomRole
pveum role modify CustomRole --privs VM.PowerMgmt
```

✅ **Toujours inclure Audit**

```bash
# BON : peut voir ET gérer
pveum role add CustomRole
pveum role modify CustomRole --privs VM.PowerMgmt,VM.Audit
```

---

❌ **Permissions sans pool**

```bash
# MAUVAIS : difficile à maintenir
pveum acl modify /vms/100 -user user1@pve -role PVEVMAdmin
pveum acl modify /vms/101 -user user1@pve -role PVEVMAdmin
pveum acl modify /vms/102 -user user1@pve -role PVEVMAdmin
```

✅ **Grouper avec des pools**

```bash
# BON : une seule permission pour plusieurs VMs
pveum pool add project-x
pveum pool modify project-x --vms 100,101,102
pveum acl modify /pool/project-x -user user1@pve -role PVEVMAdmin
```

---

❌ **Tokens sans privsep**

```bash
# RISQUÉ : token hérite de tout
pveum user add admin@pve
pveum acl modify / -user admin@pve -role Administrator
pveum user token add admin@pve api-token --privsep 0
```

✅ **Tokens avec permissions minimales**

```bash
# SÛR : token a juste ce qu'il faut
pveum user add monitoring@pve
pveum user token add monitoring@pve api-token --privsep 1
pveum acl modify / -token 'monitoring@pve!api-token' -role PVEAuditor
```

---

### 13. Checklist de déploiement

Avant de mettre en production un nouveau système de permissions :

- [ ] Les rôles personnalisés sont documentés
- [ ] Les pools sont créés et organisés logiquement
- [ ] Les groupes sont définis par fonction
- [ ] Les permissions sont attribuées aux groupes, pas aux individus
- [ ] Un utilisateur test a validé chaque niveau d'accès
- [ ] Les tokens API utilisent `--privsep 1`
- [ ] Les comptes temporaires ont une date d'expiration
- [ ] La configuration est sauvegardée
- [ ] L'équipe est formée sur le nouveau système
- [ ] Un processus d'audit régulier est en place

---

## 🎓 Récapitulatif

### Points clés à retenir

1. **Modèle RBAC** : Utilisateur + Rôle + Chemin = Permission
2. **Rôles prédéfinis** : Couvrent 90% des cas d'usage
3. **Rôles personnalisés** : Pour les besoins spécifiques
4. **Pools** : Solution recommandée pour la gestion à grande échelle
5. **Groupes** : Simplifier la gestion des utilisateurs
6. **Moindre privilège** : Toujours donner le minimum nécessaire
7. **Documentation** : Commentez tout
8. **Audit** : Révision régulière obligatoire

### Commandes essentielles

```bash
# Créer un rôle
pveum role add <nom> --comment "Description"
pveum role modify <nom> --privs <privilege1>,<privilege2>

# Créer un pool
pveum pool add <nom> --comment "Description"
pveum pool modify <nom> --vms <vmid1>,<vmid2>

# Attribuer des permissions
pveum acl modify <chemin> -user <user@realm> -role <role>
pveum acl modify <chemin> -group <group> -role <role>

# Vérifier les permissions
pveum user permissions <user@realm>
pveum acl list <chemin>

# Backup
pveum acl list > /root/acl-backup.txt
```

### Hiérarchie des chemins

```
/                           → Tout le datacenter
/nodes/{node}              → Nœud spécifique
/storage/{storage}         → Stockage spécifique
/pool/{pool}               → Pool (RECOMMANDÉ)
/vms/{vmid}                → VM spécifique
```

### Workflow recommandé

1. **Créer les pools** (par projet/équipe)
2. **Créer les groupes** (par fonction)
3. **Créer/choisir les rôles** (personnalisés si besoin)
4. **Attribuer permissions** aux groupes sur les pools
5. **Ajouter utilisateurs** aux groupes
6. **Tester** avec un compte test
7. **Documenter** et sauvegarder
8. **Auditer** régulièrement

---

_Fin du cours sur les Permissions et Rôles dans Proxmox VE_ 🎉