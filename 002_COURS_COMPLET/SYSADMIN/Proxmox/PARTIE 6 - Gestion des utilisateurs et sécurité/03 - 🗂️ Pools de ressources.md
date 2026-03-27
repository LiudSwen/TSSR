

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

## Introduction aux pools de ressources

Les **pools de ressources** dans Proxmox permettent de regrouper logiquement des ressources (VMs, conteneurs, stockages) et de les associer à des utilisateurs ou groupes spécifiques. C'est un mécanisme fondamental pour organiser et déléguer l'administration des ressources.

> [!info] Pourquoi utiliser des pools ?
> 
> - **Organisation logique** : Regrouper les ressources par projet, client, département ou environnement
> - **Délégation simplifiée** : Attribuer des permissions globales sur un ensemble de ressources en une seule fois
> - **Isolation administrative** : Permettre à des utilisateurs de gérer uniquement leurs ressources
> - **Facturation et suivi** : Faciliter la comptabilité des ressources par entité

> [!example] Cas d'usage typiques
> 
> - **Par département** : Pool "DEV", "PROD", "STAGING"
> - **Par client** : Pool "Client_A", "Client_B" pour les hébergeurs
> - **Par projet** : Pool "Projet_Web", "Projet_Data"
> - **Par équipe** : Pool "Equipe_Infrastructure", "Equipe_Developpement"

### Différence avec les groupes d'utilisateurs

|Concept|Objectif|Contenu|
|---|---|---|
|**Pool de ressources**|Regrouper des ressources (VMs, CTs, stockages)|Machines virtuelles, conteneurs, stockages|
|**Groupe d'utilisateurs**|Regrouper des utilisateurs|Utilisateurs et comptes de service|

Les deux travaillent ensemble : un groupe d'utilisateurs peut recevoir des permissions sur un pool de ressources.

---

## Création de pools

### Via l'interface web (GUI)

La création de pools via l'interface graphique est la méthode la plus simple et visuelle.

**Navigation :**

1. Se connecter à l'interface web Proxmox
2. Datacenter → Permissions → Pools
3. Cliquer sur **"Create"**
4. Remplir les champs :
    - **Pool ID** : Identifiant unique (alphanumérique, tirets et underscores autorisés)
    - **Comment** : Description facultative mais recommandée

> [!warning] Contraintes sur le nom du pool
> 
> - Le Pool ID ne peut pas être modifié après création
> - Utilisez des noms explicites et cohérents avec votre convention de nommage
> - Évitez les caractères spéciaux autres que `-` et `_`
> - La casse est importante (sensible à la casse)

> [!example] Exemples de noms de pools
> 
> ```
> prod-web
> dev-database
> client-acme-corp
> staging-api
> backup-storage
> test-environment
> ```

### Via la ligne de commande (CLI)

La création via CLI est utile pour l'automatisation et les scripts.

```bash
# Syntaxe de base
pvesh create /pools --poolid <nom_du_pool> --comment "<description>"

# Exemple : Créer un pool pour la production
pvesh create /pools --poolid prod-web --comment "Serveurs web de production"

# Exemple : Pool pour un client
pvesh create /pools --poolid client-acme --comment "Ressources du client ACME Corp"

# Exemple : Pool sans commentaire
pvesh create /pools --poolid dev-testing
```

> [!tip] Automatisation de la création de pools Vous pouvez créer un script pour générer plusieurs pools :
> 
> ```bash
> #!/bin/bash
> 
> # Liste des pools à créer
> pools=(
>     "dev-web:Environnement de développement web"
>     "dev-db:Environnement de développement base de données"
>     "prod-web:Production web"
>     "prod-db:Production base de données"
> )
> 
> for pool_info in "${pools[@]}"; do
>     poolid="${pool_info%%:*}"
>     comment="${pool_info#*:}"
>     pvesh create /pools --poolid "$poolid" --comment "$comment"
>     echo "✓ Pool $poolid créé"
> done
> ```

### Vérification de la création

```bash
# Lister tous les pools existants
pvesh get /pools

# Obtenir les détails d'un pool spécifique
pvesh get /pools/<poolid>

# Exemple avec formatage JSON pour plus de lisibilité
pvesh get /pools/prod-web --output-format json-pretty
```

> [!info] Format de sortie La commande retourne les informations du pool au format JSON :
> 
> - `poolid` : Identifiant du pool
> - `comment` : Description
> - `members` : Liste des ressources contenues (vide à la création)

---

## Ajout de ressources

Une fois le pool créé, vous devez y ajouter des ressources (VMs, conteneurs, stockages) pour qu'il soit utile.

### Types de ressources supportées

|Type|Description|Identifiant|
|---|---|---|
|**VM (QEMU)**|Machine virtuelle complète|`qemu/<vmid>`|
|**CT (LXC)**|Conteneur Linux|`lxc/<ctid>`|
|**Storage**|Espace de stockage|`storage/<storage_id>`|

### Ajout via l'interface web

**Pour une VM ou un conteneur :**

1. Sélectionner la VM/CT dans l'arborescence
2. Onglet **"Permissions"**
3. Bouton **"Add to Pool"** ou modifier les propriétés
4. Sélectionner le pool cible

**Lors de la création d'une VM/CT :**

- Dans l'assistant de création, un champ **"Pool"** permet d'assigner directement la ressource

> [!tip] Bonne pratique Assignez les ressources à un pool dès leur création pour maintenir une organisation cohérente.

### Ajout via la ligne de commande

#### Ajouter une VM ou un conteneur

```bash
# Syntaxe générale
pvesh set /pools/<poolid> --vms <vmid>

# Exemple : Ajouter la VM 100 au pool prod-web
pvesh set /pools/prod-web --vms 100

# Ajouter plusieurs VMs en une seule commande (séparées par des virgules)
pvesh set /pools/prod-web --vms 100,101,102

# Ajouter un conteneur LXC
pvesh set /pools/dev-testing --vms 200
```

> [!info] Note sur l'option --vms Malgré son nom, l'option `--vms` fonctionne aussi bien pour les machines virtuelles (QEMU) que pour les conteneurs (LXC). Le paramètre prend simplement l'ID de la ressource.

#### Ajouter un stockage

```bash
# Syntaxe
pvesh set /pools/<poolid> --storage <storage_id>

# Exemple : Ajouter le stockage local-lvm au pool
pvesh set /pools/prod-web --storage local-lvm

# Ajouter plusieurs stockages
pvesh set /pools/prod-web --storage local-lvm,nfs-backup
```

### Vérifier les ressources d'un pool

```bash
# Voir toutes les ressources d'un pool
pvesh get /pools/<poolid>

# Exemple avec formatage
pvesh get /pools/prod-web --output-format json-pretty

# Lister uniquement les VMs d'un pool
pvesh get /pools/prod-web | grep -E "vmid|type"
```

Sortie exemple :

```json
{
  "comment": "Serveurs web de production",
  "members": [
    {
      "id": "qemu/100",
      "node": "pve1",
      "status": "running",
      "type": "qemu",
      "vmid": 100
    },
    {
      "id": "lxc/200",
      "node": "pve1",
      "status": "stopped",
      "type": "lxc",
      "vmid": 200
    },
    {
      "id": "storage/local-lvm",
      "storage": "local-lvm",
      "type": "storage"
    }
  ],
  "poolid": "prod-web"
}
```

### Retirer des ressources d'un pool

```bash
# Retirer une VM/CT d'un pool
pvesh set /pools/<poolid> --delete 1 --vms <vmid>

# Exemple : Retirer la VM 100 du pool prod-web
pvesh set /pools/prod-web --delete 1 --vms 100

# Retirer un stockage
pvesh set /pools/<poolid> --delete 1 --storage <storage_id>
```

> [!warning] Attention lors du retrait
> 
> - Retirer une ressource d'un pool ne la supprime pas, elle devient simplement non assignée
> - Les permissions associées au pool ne s'appliquent plus à cette ressource
> - Une ressource ne peut appartenir qu'à un seul pool à la fois

### Script de gestion en masse

```bash
#!/bin/bash
# Script pour ajouter toutes les VMs d'un nœud à un pool

NODE="pve1"
POOL="prod-web"

# Récupérer la liste des VMs sur le nœud
for vmid in $(pvesh get /nodes/$NODE/qemu --output-format json | jq -r '.[].vmid'); do
    echo "Ajout de la VM $vmid au pool $POOL..."
    pvesh set /pools/$POOL --vms $vmid
done

echo "✓ Toutes les VMs ont été ajoutées au pool $POOL"
```

---

## Gestion multi-utilisateurs

Les pools deviennent véritablement puissants lorsqu'ils sont combinés avec le système de permissions pour créer une délégation d'administration.

### Concept de délégation via les pools

Le principe est simple :

1. **Créer un pool** contenant les ressources à déléguer
2. **Créer un utilisateur ou un groupe** qui gérera ces ressources
3. **Attribuer des permissions** sur le pool à cet utilisateur/groupe

> [!info] Avantages de cette approche
> 
> - Permissions granulaires par ensemble de ressources
> - Facilite l'organisation multi-tenant
> - Permet l'isolation des responsabilités
> - Simplifie l'audit et la traçabilité

### Attribution de permissions sur un pool

#### Via l'interface web

1. Datacenter → Permissions → Pools
2. Sélectionner le pool
3. Bouton **"Permissions"**
4. Cliquer sur **"Add"** → **"User Permission"** ou **"Group Permission"**
5. Configurer :
    - **Path** : Automatiquement rempli avec `/pool/<poolid>`
    - **User/Group** : Sélectionner l'utilisateur ou groupe
    - **Role** : Choisir le rôle approprié
    - **Propagate** : Cocher pour appliquer aux ressources enfants

#### Via la ligne de commande

```bash
# Syntaxe générale
pveum acl modify /pool/<poolid> --users <username>@<realm> --roles <role>

# Exemple : Donner le rôle PVEVMAdmin à un utilisateur sur un pool
pveum acl modify /pool/prod-web --users john@pve --roles PVEVMAdmin

# Attribuer à un groupe
pveum acl modify /pool/prod-web --groups dev-team --roles PVEVMUser

# Avec propagation explicite (par défaut activée pour les pools)
pveum acl modify /pool/prod-web --users marie@pve --roles PVEVMAdmin --propagate 1
```

### Rôles typiques pour les pools

|Rôle|Permissions|Usage recommandé|
|---|---|---|
|**PVEVMAdmin**|Gestion complète des VMs/CTs (création, suppression, configuration)|Administrateurs d'équipe|
|**PVEVMUser**|Utilisation des VMs (start, stop, console)|Utilisateurs finaux|
|**PVEAdmin**|Administration complète incluant permissions|Administrateurs système|
|**PVEAuditor**|Lecture seule de toutes les informations|Audit et supervision|
|**PVEDatastoreUser**|Accès en lecture/écriture au stockage|Pour les backups et templates|

> [!tip] Création de rôles personnalisés Pour des besoins spécifiques, vous pouvez créer des rôles sur mesure avec uniquement les privilèges nécessaires (principe du moindre privilège).

### Scénarios de gestion multi-utilisateurs

#### Scénario 1 : Équipe de développement autonome

```bash
# 1. Créer le pool
pvesh create /pools --poolid dev-team-alpha --comment "Environnement équipe Dev Alpha"

# 2. Créer le groupe d'utilisateurs (déjà couvert dans la partie groupes)
# pveum group add dev-alpha

# 3. Ajouter les VMs de développement au pool
pvesh set /pools/dev-team-alpha --vms 110,111,112

# 4. Attribuer les permissions
pveum acl modify /pool/dev-team-alpha --groups dev-alpha --roles PVEVMAdmin

# Résultat : Les membres du groupe dev-alpha peuvent gérer complètement
# les VMs 110, 111, 112 mais rien d'autre
```

#### Scénario 2 : Client avec accès restreint

```bash
# 1. Créer le pool client
pvesh create /pools --poolid client-acme --comment "Ressources ACME Corp"

# 2. Créer l'utilisateur client
pveum user add acme-admin@pve --comment "Administrateur ACME"

# 3. Ajouter les ressources
pvesh set /pools/client-acme --vms 300,301,302
pvesh set /pools/client-acme --storage client-acme-storage

# 4. Permissions : PVEVMUser pour utilisation basique
pveum acl modify /pool/client-acme --users acme-admin@pve --roles PVEVMUser

# Le client peut démarrer/arrêter ses VMs et accéder à la console
# mais ne peut pas les supprimer ou modifier la configuration
```

#### Scénario 3 : Hiérarchie d'administration

```bash
# Pool principal avec sous-organisation
pvesh create /pools --poolid prod-all --comment "Toutes les ressources de production"
pvesh create /pools --poolid prod-web --comment "Production web uniquement"
pvesh create /pools --poolid prod-db --comment "Production bases de données uniquement"

# Responsable général de la production (tous les pools prod)
pveum acl modify /pool/prod-all --users prod-manager@pve --roles PVEAdmin

# Responsable web (uniquement pool web)
pveum acl modify /pool/prod-web --users web-admin@pve --roles PVEVMAdmin

# Responsable DB (uniquement pool DB)
pveum acl modify /pool/prod-db --users db-admin@pve --roles PVEVMAdmin
```

### Vérification des permissions

```bash
# Lister toutes les ACL d'un pool
pveum acl list | grep "pool/<poolid>"

# Exemple
pveum acl list | grep "pool/prod-web"

# Voir les permissions effectives d'un utilisateur
pveum user permissions <username>@<realm>

# Exemple
pveum user permissions john@pve
```

> [!example] Sortie typique
> 
> ```
> /pool/prod-web:
>   john@pve: PVEVMAdmin (propagate=1)
>   dev-team: PVEVMUser (propagate=1)
> ```

### Bonnes pratiques de gestion multi-utilisateurs

> [!tip] Organisation recommandée
> 
> 1. **Nommage cohérent** : Utilisez un schéma de nommage prévisible pour pools et utilisateurs
> 2. **Groupes plutôt qu'utilisateurs individuels** : Facilite la gestion à long terme
> 3. **Documentation des pools** : Utilisez le champ comment pour décrire le contenu et l'usage
> 4. **Principe du moindre privilège** : Donnez uniquement les permissions nécessaires
> 5. **Audit régulier** : Vérifiez périodiquement les permissions actives

> [!warning] Pièges courants
> 
> - **Sur-permission** : Donner PVEAdmin au lieu de PVEVMAdmin par facilité
> - **Oubli de propagation** : Les permissions ne s'appliquent pas aux nouvelles ressources ajoutées
> - **Pools vides** : Créer des pools sans y ajouter de ressources rend les permissions inefficaces
> - **Chevauchement de pools** : Une ressource ne peut appartenir qu'à un seul pool

### Suppression d'un pool

```bash
# Supprimer un pool (il doit être vide)
pvesh delete /pools/<poolid>

# Exemple
pvesh delete /pools/dev-testing
```

> [!warning] Prérequis pour la suppression Le pool doit être vide (aucune ressource assignée). Retirez d'abord toutes les VMs, conteneurs et stockages avant de supprimer le pool.

```bash
# Script pour vider puis supprimer un pool
#!/bin/bash

POOL="dev-testing"

echo "Retrait des ressources du pool $POOL..."
# Récupérer et retirer toutes les VMs
for vmid in $(pvesh get /pools/$POOL --output-format json | jq -r '.members[] | select(.type=="qemu" or .type=="lxc") | .vmid'); do
    pvesh set /pools/$POOL --delete 1 --vms $vmid
    echo "  VM/CT $vmid retirée"
done

# Récupérer et retirer tous les stockages
for storage in $(pvesh get /pools/$POOL --output-format json | jq -r '.members[] | select(.type=="storage") | .storage'); do
    pvesh set /pools/$POOL --delete 1 --storage $storage
    echo "  Storage $storage retiré"
done

echo "Suppression du pool $POOL..."
pvesh delete /pools/$POOL
echo "✓ Pool supprimé avec succès"
```

---

## 🎯 Points clés à retenir

- Les **pools de ressources** permettent de regrouper logiquement VMs, conteneurs et stockages
- Ils sont essentiels pour la **délégation d'administration** et l'organisation multi-utilisateurs
- Un pool se crée facilement via GUI ou CLI avec `pvesh create /pools`
- Les ressources s'ajoutent avec `pvesh set /pools/<poolid> --vms <vmid>`
- La combinaison **pool + groupe + rôle** permet une gestion granulaire des permissions
- Privilégiez les **groupes d'utilisateurs** plutôt que les permissions individuelles
- Appliquez le **principe du moindre privilège** dans l'attribution des rôles
- Une ressource ne peut appartenir qu'à **un seul pool à la fois**

---

_Cours rédigé pour Proxmox VE - Partie Gestion des utilisateurs et sécurité_