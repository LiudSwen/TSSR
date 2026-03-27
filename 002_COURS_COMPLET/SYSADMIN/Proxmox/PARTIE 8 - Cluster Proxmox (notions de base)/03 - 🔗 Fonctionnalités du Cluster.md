# 

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

## 🎯 Gestion centralisée

### Concept

La gestion centralisée est l'une des fonctionnalités clés d'un cluster Proxmox. Elle permet d'administrer l'ensemble des nœuds du cluster depuis une seule interface web, sans avoir besoin de se connecter individuellement à chaque serveur.

> [!info] Pourquoi c'est important Dans un environnement avec plusieurs serveurs physiques, la gestion centralisée simplifie considérablement l'administration quotidienne. Au lieu de jongler entre plusieurs interfaces ou connexions SSH, vous avez une vue unifiée de toute votre infrastructure.

### Fonctionnalités principales

#### Vue d'ensemble du cluster

L'interface web Proxmox offre une vue hiérarchique complète :

- **Datacenter** : niveau racine représentant l'ensemble du cluster
- **Nœuds** : chaque serveur physique du cluster
- **Ressources** : VMs et conteneurs répartis sur les nœuds

```bash
# Structure visible dans l'interface
Datacenter
├── node1 (192.168.1.10)
│   ├── VM 100 (web-server)
│   ├── VM 101 (database)
│   └── CT 102 (proxy)
├── node2 (192.168.1.11)
│   ├── VM 200 (app-server)
│   └── CT 201 (monitoring)
└── node3 (192.168.1.12)
    └── VM 300 (backup)
```

#### Gestion des ressources depuis n'importe quel nœud

> [!example] Exemple pratique Vous êtes connecté à l'interface web du `node1`, mais vous pouvez :
> 
> - Démarrer une VM sur `node2`
> - Modifier la configuration d'un conteneur sur `node3`
> - Consulter les logs de n'importe quelle ressource
> - Effectuer des backups sur tous les nœuds

#### Console centralisée

Accès aux consoles des VMs et conteneurs depuis n'importe quel nœud du cluster :

- Console noVNC (navigateur web)
- Console SPICE (client externe)
- Shell pour les conteneurs LXC
- Terminal série pour les VMs

```bash
# Depuis l'interface web, vous pouvez accéder à la console d'une VM
# même si elle tourne sur un autre nœud physique
# Le trafic est automatiquement routé via le réseau de cluster
```

### Synchronisation de la configuration

Le cluster Proxmox synchronise automatiquement plusieurs types de données entre tous les nœuds.

#### Configuration du cluster

Le fichier `/etc/pve/` est un système de fichiers distribué (pmxcfs) qui est identique sur tous les nœuds :

```bash
# Ce répertoire est synchronisé en temps réel sur tous les nœuds
/etc/pve/
├── authkey.pub           # Clé publique d'authentification
├── corosync.conf         # Configuration du cluster
├── datacenter.cfg        # Configuration globale
├── nodes/                # Configuration spécifique par nœud
├── priv/                 # Clés privées et certificats
├── qemu-server/          # Configuration des VMs
├── lxc/                  # Configuration des conteneurs
└── storage.cfg           # Configuration du stockage
```

> [!warning] Attention Toute modification dans `/etc/pve/` est immédiatement répliquée sur tous les nœuds. Ne modifiez jamais ces fichiers manuellement sans comprendre l'impact sur l'ensemble du cluster.

#### Utilisateurs et permissions

Les comptes utilisateurs, groupes et permissions sont centralisés :

```bash
# Création d'un utilisateur depuis n'importe quel nœud
pveum user add admin@pve --comment "Administrateur principal"

# Attribution de permissions sur l'ensemble du cluster
pveum acl modify / --users admin@pve --roles Administrator

# Ces changements sont instantanément disponibles sur tous les nœuds
```

|Type d'authentification|Synchronisé|Centralité|
|---|---|---|
|Utilisateurs PVE|✅ Oui|Cluster|
|Groupes|✅ Oui|Cluster|
|Permissions (ACL)|✅ Oui|Cluster|
|LDAP/AD (config)|✅ Oui|Cluster|
|Tokens API|✅ Oui|Cluster|

### Gestion du stockage centralisée

> [!tip] Astuce Depuis l'interface Datacenter → Storage, vous pouvez ajouter un stockage qui sera automatiquement disponible sur tous les nœuds du cluster (selon le type de stockage).

```bash
# Ajout d'un stockage NFS depuis la ligne de commande
pvesm add nfs backup-nfs \
  --server 192.168.1.50 \
  --export /mnt/backup \
  --content backup,iso

# Ce stockage sera immédiatement visible sur tous les nœuds
pvesm status
```

### Monitoring centralisé

L'interface web permet de surveiller l'état de tous les nœuds :

- **Charge CPU** de chaque nœud
- **Utilisation RAM** et swap
- **I/O disque** et réseau
- **État des services** Proxmox
- **Alertes** et événements système

```bash
# Via CLI, récupération des statistiques de tous les nœuds
pvesh get /cluster/resources --type node

# Récupération de toutes les VMs du cluster
pvesh get /cluster/resources --type vm
```

### Recherche globale

> [!example] Fonction pratique La barre de recherche de l'interface Proxmox permet de trouver instantanément une VM, un conteneur, un nœud ou même un paramètre de configuration à travers tout le cluster.

```bash
# Recherche d'une VM par son nom depuis CLI
pvesh get /cluster/resources --type vm | grep "web-server"

# Recherche d'un conteneur par son ID
qm config 100  # Fonctionne même si la VM est sur un autre nœud
```

### Logs centralisés

Les logs de tous les nœuds et ressources sont accessibles depuis l'interface centralisée :

- Logs système de chaque nœud
- Logs des tâches (backups, migrations, etc.)
- Logs spécifiques des VMs et conteneurs

```bash
# Visualisation des logs d'une tâche depuis n'importe quel nœud
pvesh get /nodes/{node}/tasks/{upid}/log

# Logs système d'un nœud distant
pvesh get /nodes/node2/syslog
```

> [!tip] Bonnes pratiques
> 
> - Utilisez toujours l'interface web ou les commandes `pvesh` pour modifier la configuration
> - Documentez les changements importants dans les notes des VMs/conteneurs
> - Créez des groupes d'utilisateurs avec des permissions appropriées plutôt que de tout donner à un seul compte
> - Utilisez les tags pour organiser vos VMs et faciliter la recherche

### Pièges courants

> [!warning] Erreurs fréquentes
> 
> - **Éditer directement les fichiers dans `/etc/pve/`** : Peut causer des incohérences dans le cluster
> - **Oublier que les modifications sont globales** : Supprimer un stockage depuis un nœud le supprime partout
> - **Ne pas vérifier le quorum** : Sans quorum, certaines opérations centralisées peuvent échouer
> - **Connecter des stockages locaux comme partagés** : Peut causer des pertes de données

---

## 🚀 Migration à chaud (Live Migration)

### Concept

La migration à chaud (Live Migration) permet de déplacer une machine virtuelle en fonctionnement d'un nœud physique vers un autre **sans interruption de service**. La VM continue de tourner pendant le transfert, avec seulement une micro-coupure de quelques millisecondes imperceptible pour l'utilisateur.

> [!info] Pourquoi c'est important La Live Migration est essentielle pour :
> 
> - **Maintenance sans interruption** : Videz un serveur pour une maintenance matérielle sans arrêter les services
> - **Équilibrage de charge** : Redistribuez les VMs pour optimiser l'utilisation des ressources
> - **Éviter les pannes** : Évacuez les VMs d'un serveur présentant des signes de défaillance
> - **Économies d'énergie** : Consolidez les VMs sur moins de serveurs en heures creuses

### Types de migration

Proxmox propose deux types de migration :

|Type|Arrêt VM|Rapidité|Stockage requis|
|---|---|---|---|
|**Migration à chaud** (Live)|❌ Non|Lente (données + RAM)|Partagé ou réplication|
|**Migration hors ligne** (Offline)|✅ Oui|Rapide (données seulement)|Peut être local|

> [!tip] Quand utiliser chaque type
> 
> - **Live Migration** : VMs critiques nécessitant une disponibilité continue
> - **Offline Migration** : VMs pouvant être arrêtées, ou pour économiser du temps et de la bande passante

### Prérequis techniques

#### Pour la Live Migration

1. **CPU compatible**
    - Les CPUs doivent être de la même famille (Intel avec Intel, AMD avec AMD)
    - Les flags CPU doivent être compatibles entre les nœuds

```bash
# Vérifier les flags CPU sur chaque nœud
cat /proc/cpuinfo | grep flags | head -1

# Comparer les modèles CPU
lscpu | grep "Model name"
```

> [!warning] Incompatibilité CPU Si les CPUs sont trop différents, vous devrez utiliser un type CPU "generic" dans la configuration de la VM, ce qui peut réduire les performances.

2. **Stockage partagé ou réplication**

Le stockage des VMs doit être accessible depuis les deux nœuds :

```bash
# Exemples de stockages compatibles avec Live Migration
- NFS, iSCSI, Ceph RBD    # Stockage partagé
- ZFS avec réplication    # Réplication continue
- Ceph FS                 # Système de fichiers distribué
```

3. **Réseau de migration dédié (recommandé)**

```bash
# Configuration d'un réseau dédié pour les migrations dans /etc/network/interfaces
auto vmbr1
iface vmbr1 inet static
    address 10.0.0.10/24
    bridge-ports eth1
    bridge-stp off
    bridge-fd 0
    # Réseau dédié 10Gbps pour les migrations
```

> [!tip] Performance réseau Utilisez un réseau 10Gbps dédié aux migrations pour :
> 
> - Accélérer considérablement les migrations
> - Ne pas saturer le réseau de production
> - Permettre des migrations simultanées

4. **Temps système synchronisé**

```bash
# Vérifier la synchronisation NTP sur tous les nœuds
timedatectl status

# S'assurer que systemd-timesyncd ou chrony est actif
systemctl status systemd-timesyncd
```

### Processus de Live Migration

#### Phase 1 : Pré-copie mémoire

Le nœud source commence à copier la RAM de la VM vers le nœud cible pendant que la VM continue de fonctionner.

```
Nœud Source                    Nœud Cible
┌──────────┐                  ┌──────────┐
│   VM     │                  │          │
│ (active) │  ─────────────>  │ Copie    │
│  8 GB    │    Copie RAM     │ RAM      │
└──────────┘                  └──────────┘
```

#### Phase 2 : Copie itérative

Les pages mémoire modifiées pendant la copie sont recopiées (processus itératif).

> [!info] Détail technique Proxmox utilise le mécanisme "dirty page tracking" de KVM/QEMU pour identifier les pages mémoire qui ont changé et doivent être recopiées.

#### Phase 3 : Arrêt-copie final (downtime)

Quand le taux de pages modifiées devient assez faible, la VM est brièvement suspendue :

```bash
# Durée typique du downtime
- Cas optimal : 50-100 ms
- Cas normal : 100-500 ms  
- VM très active : 1-2 secondes
```

1. Suspension de la VM sur le nœud source
2. Copie des dernières pages mémoire modifiées
3. Transfert de l'état du CPU
4. Activation de la VM sur le nœud cible

```
Source (freeze)               Cible (start)
┌──────────┐                  ┌──────────┐
│   VM     │  ─────────────>  │   VM     │
│ (pause)  │  Dernières pages │ (active) │
└──────────┘                  └──────────┘
     ↓                              ↑
   Arrêt                        Démarrage
```

### Réaliser une Live Migration

#### Depuis l'interface web

1. Clic droit sur la VM → **Migrate**
2. Sélectionner le nœud cible
3. Cocher **Online** pour une migration à chaud
4. Cliquer sur **Migrate**

```bash
# L'interface affiche la progression en temps réel
Migration de VM 100 (web-server)
├── Phase: pre-copy
├── Progression: 45%
├── Transfert: 3.2 GB / 8 GB
└── Temps estimé: 2m 15s
```

#### Depuis la ligne de commande

```bash
# Migration à chaud vers node2
qm migrate 100 node2 --online

# Migration avec options avancées
qm migrate 100 node2 \
  --online \                          # Migration à chaud
  --migration_network 10.0.0.0/24 \   # Réseau spécifique
  --migration_type secure \           # Chiffrement des données
  --targetstorage local-lvm           # Stockage cible (si différent)
```

> [!example] Options de migration
> 
> - `--online` : Active la migration à chaud
> - `--force` : Force la migration même si les checks échouent
> - `--with-local-disks` : Migre aussi les disques locaux (plus lent)
> - `--migration_type` : `secure` (chiffré) ou `insecure` (plus rapide)

### Monitoring de la migration

```bash
# Suivre la progression d'une migration en cours
qm status 100 -verbose

# Vérifier les tâches de migration
pvesh get /cluster/tasks

# Logs détaillés d'une migration
tail -f /var/log/pve/tasks/*/qmigrate-*.log
```

### Migration avec disques locaux

> [!warning] Migration complexe Migrer une VM avec des disques sur du stockage local est plus complexe et beaucoup plus lent, car il faut copier à la fois la RAM et les disques.

```bash
# Migration avec stockage local (copie les disques)
qm migrate 100 node2 \
  --online \
  --with-local-disks 1 \
  --targetstorage local-lvm

# Temps estimé :
# - RAM : fonction du réseau (ex: 8GB sur 10Gbps = ~10s)
# - Disques : fonction du réseau (ex: 100GB sur 10Gbps = ~100s)
```

### Optimisation des performances

#### Configuration du réseau de migration

```bash
# Dans /etc/pve/datacenter.cfg
migration: secure,network=10.0.0.0/24

# Types de migration :
# - secure : chiffrement TLS (plus sécurisé, ~10% plus lent)
# - insecure : pas de chiffrement (plus rapide)
```

#### Paramètres de migration avancés

```bash
# Dans /etc/pve/qemu-server/100.conf
# Limite la bande passante de migration (en MB/s)
migrate_speed: 500

# Downtime maximum acceptable (en secondes)
migrate_downtime: 0.1
```

> [!tip] Tuning des performances
> 
> - Augmentez `migrate_speed` si vous avez un réseau rapide dédié
> - Réduisez `migrate_downtime` pour les VMs ultra-critiques (mais migrations plus longues)
> - Utilisez `insecure` pour les réseaux de migration isolés et sécurisés

### Limitations et contraintes

|Limitation|Description|Solution|
|---|---|---|
|**Incompatibilité CPU**|Flags CPU différents|Utiliser un type CPU "host" ou "kvm64"|
|**RAM insuffisante**|Pas assez de RAM sur la cible|Libérer de la RAM ou choisir un autre nœud|
|**VM très active**|Beaucoup d'écritures mémoire|Migration offline ou downtime plus long|
|**Réseau lent**|Migration trop longue|Ajouter un réseau 10Gbps dédié|
|**Disques locaux**|Pas de stockage partagé|Migration très lente avec `--with-local-disks`|

### Échecs de migration

> [!warning] Gestion des échecs Si une migration échoue, la VM continue de tourner sur le nœud source. Aucune donnée n'est perdue.

```bash
# Causes fréquentes d'échec
- Perte de connexion réseau entre les nœuds
- Espace disque insuffisant sur la cible
- Timeout dû à une VM trop active en écriture
- Incompatibilité matérielle non détectée

# Vérification des logs en cas d'échec
journalctl -u pvedaemon -f
tail -f /var/log/pve/tasks/*/qmigrate-*.log
```

### Bonnes pratiques

> [!tip] Recommandations
> 
> - **Testez les migrations** sur des VMs non critiques avant de les utiliser en production
> - **Planifiez les migrations** pendant les heures creuses pour réduire le downtime
> - **Utilisez un réseau dédié** 10Gbps pour les migrations fréquentes
> - **Surveillez les métriques** : durée, downtime, bande passante utilisée
> - **Documentez les incompatibilités** CPU entre vos nœuds
> - **Activez la réplication** pour accélérer les migrations futures

### Cas d'usage avancés

#### Migration automatisée (scripts)

```bash
#!/bin/bash
# Script de migration automatique pour maintenance

NODE_SOURCE="node1"
NODE_CIBLE="node2"

# Liste des VMs sur le nœud source
VMS=$(qm list | grep "$NODE_SOURCE" | awk '{print $1}')

for VMID in $VMS; do
  echo "Migration de VM $VMID..."
  qm migrate $VMID $NODE_CIBLE --online
  
  # Attendre la fin de la migration
  while qm status $VMID | grep -q "migrating"; do
    sleep 5
  done
done

echo "Toutes les VMs ont été migrées vers $NODE_CIBLE"
```

#### Équilibrage de charge

```bash
# Vérifier la charge CPU de chaque nœud
for node in node1 node2 node3; do
  echo "=== $node ==="
  pvesh get /nodes/$node/status | grep -E "cpu|maxcpu"
done

# Migrer manuellement pour équilibrer
# Si node1 est surchargé, migrer quelques VMs vers node2/node3
```

---

## 🛡️ Haute disponibilité (HA)

### Concept

La haute disponibilité (High Availability - HA) dans Proxmox permet de garantir que vos machines virtuelles critiques continuent de fonctionner même en cas de défaillance d'un nœud physique. Lorsqu'un nœud tombe en panne, les VMs configurées en HA sont automatiquement redémarrées sur un autre nœud sain du cluster.

> [!info] Pourquoi c'est important La HA est cruciale pour :
> 
> - **Services critiques** : Bases de données, serveurs web, applications métier
> - **Réduction du MTTR** (Mean Time To Recovery) : Redémarrage automatique en quelques minutes
> - **Disponibilité 24/7** : Limiter l'impact des pannes matérielles ou maintenance
> - **Conformité** : Respecter les SLA (Service Level Agreements) exigeants

> [!warning] HA vs Tolérance de panne La HA dans Proxmox **redémarre** les VMs sur un autre nœud, elle ne les migre pas à chaud. Il y a donc une interruption de service de quelques minutes (temps de détection + redémarrage). Pour une continuité totale, il faut combiner HA avec Live Migration et réplication.

### Concepts fondamentaux

#### Quorum

Le quorum est le mécanisme qui garantit qu'une majorité de nœuds est d'accord avant toute décision critique.

```bash
# Formule du quorum
Quorum = (Nombre de nœuds / 2) + 1

# Exemples
Cluster 3 nœuds : quorum = 2 nœuds minimum
Cluster 5 nœuds : quorum = 3 nœuds minimum  
Cluster 7 nœuds : quorum = 4 nœuds minimum
```

|Nœuds total|Quorum requis|Pannes tolérées|
|---|---|---|
|2|2|0 ⚠️|
|3|2|1 ✅|
|4|3|1 ⚠️|
|5|3|2 ✅|
|6|4|2 ⚠️|
|7|4|3 ✅|

> [!tip] Nombre de nœuds optimal Privilégiez un **nombre impair de nœuds** (3, 5, 7) pour optimiser la tolérance aux pannes. Un cluster de 4 nœuds n'offre pas plus de résilience qu'un cluster de 3 nœuds.

```bash
# Vérifier l'état du quorum
pvecm status

# Affiche notamment :
# Quorum information
# Date:             Wed Dec 24 14:30:00 2025
# Quorum provider:  corosync_votequorum
# Nodes:            3
# Expected votes:   3
# Highest expected: 3
# Total votes:      3
# Quorum:           2  
# Flags:            Quorate
```

#### Fencing (clôture)

Le fencing est le mécanisme qui s'assure qu'un nœud défaillant est bien isolé avant de redémarrer ses VMs ailleurs.

> [!warning] Importance critique du Fencing Sans fencing, vous risquez le "split-brain" : deux nœuds pensent tous les deux être responsables d'une VM, causant une corruption de données.

**Méthodes de fencing :**

1. **Watchdog** (méthode par défaut)
    - Module matériel ou logiciel qui redémarre le nœud s'il ne répond plus
    - Simple à configurer, pas besoin d'équipement externe

```bash
# Vérifier le watchdog sur un nœud
lsmod | grep softdog
# ou
lsmod | grep iTCO_wdt   # Pour les watchdogs matériels Intel

# Activer le watchdog software
modprobe softdog
echo "softdog" >> /etc/modules
```

2. **Hardware Fencing** (IPMI, iLO, iDRAC)
    - Utilise les cartes de gestion matérielle pour forcer l'extinction
    - Plus fiable car indépendant du système d'exploitation

```bash
# Configuration IPMI dans Proxmox (nécessite fence-agents)
apt install fence-agents

# Test de la commande de fencing
fence_ipmilan \
  -a 192.168.1.100 \
  -l admin \
  -p password \
  -o status
```

#### Manager HA

Le Manager HA est le composant qui surveille l'état du cluster et prend les décisions de basculement.

```bash
# Service responsable de la HA
systemctl status pve-ha-lrm    # Local Resource Manager (sur chaque nœud)
systemctl status pve-ha-crm    # Cluster Resource Manager (service maître)

# Vérifier l'état de la HA
ha-manager status
```

**Rôles des composants :**

- **LRM** (Local Resource Manager) : Agent local qui gère les VMs sur chaque nœud
- **CRM** (Cluster Resource Manager) : Maître élu qui coordonne les décisions de HA

> [!info] Élection du maître Un seul nœud à la fois est le CRM maître (élu via Corosync). Si ce nœud tombe, un nouveau maître est automatiquement élu parmi les nœuds survivants.

### Prérequis pour la HA

1. **Cluster Proxmox fonctionnel**
    
    - Minimum 3 nœuds (pour avoir un quorum résilient)
    - Corosync correctement configuré
2. **Stockage partagé**
    
    - Les disques des VMs HA doivent être sur un stockage accessible par tous les nœuds
    - NFS, Ceph, iSCSI, etc.

```bash
# Vérifier les stockages partagés
pvesm status | grep -E "shared|nfs|ceph|iscsi"

# Un stockage local ne peut pas héberger de VMs HA
# car les autres nœuds ne pourraient pas y accéder
```

3. **Watchdog configuré**
    - Module watchdog actif sur tous les nœuds

```bash
# Vérifier que le watchdog est actif
cat /proc/sys/kernel/watchdog

# Vérifier le device watchdog
ls -l /dev/watchdog*
```

4. **Réseau stable et redondant**
    - Liens réseau multiples pour Corosync (tolérance aux pannes réseau)

### Configuration de la HA

#### Ajouter une VM au groupe HA

**Depuis l'interface web :**

1. Sélectionner **Datacenter** → **HA**
2. Cliquer sur **Add** dans l'onglet Resources
3. Sélectionner la VM
4. Configurer les options :
    - **State** : `started` (démarrer automatiquement)
    - **Max. Restart** : nombre de tentatives de redémarrage
    - **Max. Relocate** : nombre de relocalisations autorisées

```bash
# Depuis la ligne de commande
ha-manager add vm:100 \
  --state started \
  --max_restart 3 \
  --max_relocate 3

# Vérifier la configuration
ha-manager config vm:100
```

#### Options de configuration HA

|Option|Description|Valeurs recommandées|
|---|---|---|
|**state**|État souhaité de la VM|`started`, `stopped`, `ignored`|
|**max_restart**|Tentatives de redémarrage sur le même nœud|2-3|
|**max_relocate**|Tentatives de relocalisation sur d'autres nœuds|2-3|
|**group**|Groupe HA (pour les contraintes de placement)|Nom du groupe|

```bash
# État 'started' : La VM doit toujours être démarrée
# Si elle s'arrête, HA la redémarre

# État 'stopped' : La VM doit être arrêtée
# Utilisé pour une maintenance temporaire

# État 'ignored' : Désactiver temporairement la HA sans la retirer
```

#### Groupes HA

Les groupes HA permettent de définir des contraintes de placement pour les VMs.

> [!example] Cas d'usage des groupes
> 
> - Répartir des VMs sur des nœuds spécifiques (ex: VMs GPU sur nœuds avec GPU)
> - Éviter que deux VMs critiques soient sur le même nœud
> - Privilégier certains nœuds plus puissants pour certaines VMs

```bash
# Créer un groupe HA avec des nœuds préférés
ha-manager groupadd prod-group \
  --nodes "node1:2,node2:1,node3:0" \
  --nofailback 0

# Format : noeud:priorité
# - Priorité 2 : nœud préféré
# - Priorité 1 : nœud secondaire  
# - Priorité 0 : nœud de secours uniquement

# Assigner une VM à ce groupe
ha-manager modify vm:100 --group prod-group
```

**Options des groupes :**

- `--nofailback 0` : La VM revient automatiquement sur son nœud préféré quand il est de nouveau disponible
- `--nofailback 1` : La VM reste sur le nœud où elle tourne, même si son nœud préféré revient
- `--restricted 1` : Les VMs ne peuvent tourner QUE sur les nœuds du groupe

### Processus de basculement HA

#### Détection de la panne

```
1. Le nœud 1 ne répond plus aux heartbeats Corosync
   └─> Timeout : 2-3 secondes
   
2. Les autres nœuds détectent la perte de quorum avec nœud 1
   └─> Délai : 5-10 secondes
   
3. Le CRM décide d'activer le fencing sur nœud 1
   └─> Watchdog force le redémarrage du nœud défaillant
   
4. Le CRM choisit un nœud cible pour redémarrer les VMs
   └─> Basé sur les priorités du groupe HA et les ressources disponibles
   
5. Les VMs sont démarrées sur le nouveau nœud
   └─> Temps total : 2-5 minutes selon la configuration
```

> [!info] Chronologie typique
> 
> - **T+0s** : Panne du nœud
> - **T+10s** : Détection de la panne (perte des heartbeats)
> - **T+20s** : Fencing activé (watchdog redémarre le nœud défaillant)
> - **T+30s** : CRM sélectionne le nœud cible
> - **T+40s** : Démarrage des VMs sur le nouveau nœud
> - **T+2-5min** : VMs complètement opérationnelles

#### Logs du basculement

```bash
# Suivre les décisions du manager HA
tail -f /var/log/pve-ha-lrm.log
tail -f /var/log/pve-ha-crm.log

# Exemple de log lors d'une panne de node1
Dec 24 14:35:10 node2 pve-ha-crm: node 'node1' lost quorum
Dec 24 14:35:15 node2 pve-ha-crm: fencing node 'node1'
Dec 24 14:35:20 node2 pve-ha-crm: service 'vm:100': state changed 'started' => 'fence'
Dec 24 14:35:30 node2 pve-ha-crm: service 'vm:100': chose node 'node2' to restart
Dec 24 14:35:35 node2 pve-ha-lrm: starting service vm:100
```

### Surveillance et monitoring HA

#### Vérifier l'état des services HA

```bash
# Lister tous les services HA et leur état
ha-manager status

# Exemple de sortie
quorum OK
master node2 (active, Wed Dec 24 14:40:15 2025)
lrm node1 (active, Wed Dec 24 14:40:12 2025)
lrm node2 (active, Wed Dec 24 14:40:15 2025)
lrm node3 (active, Wed Dec 24 14:40:13 2025)
service vm:100 (node2, state 'started', target 'started')
service vm:101 (node1, state 'started', target 'started')
service vm:102 (node3, state 'started', target 'started')
```

**Interprétation :**

- `quorum OK` : Le cluster a le quorum
- `master node2` : node2 est le CRM maître actuel
- `lrm nodeX (active)` : Les agents locaux sont actifs sur chaque nœud
- `service vm:100` : La VM 100 tourne sur node2, état actuel = état cible

#### États possibles d'une VM HA

|État|Signification|
|---|---|
|`started`|VM démarrée et fonctionnelle|
|`stopped`|VM arrêtée volontairement|
|`fence`|En cours de fencing avant relocalisation|
|`freeze`|VM figée, en attente de décision|
|`error`|Erreur, nombre max de tentatives atteint|
|`migrate`|Migration en cours vers un autre nœud|
|`request_stop`|Demande d'arrêt en cours|

```bash
# Voir l'historique des changements d'état
ha-manager log

# Filtrer pour une VM spécifique
ha-manager log | grep "vm:100"
```

#### Interface web

Dans l'interface Proxmox :

- **Datacenter** → **HA** → **Resources** : Liste des VMs en HA avec leur état
- **Datacenter** → **HA** → **Groups** : Configuration des groupes HA
- **Datacenter** → **HA** → **Fencing** : État du fencing et watchdog

### Gestion des erreurs HA

#### États d'erreur

Si une VM échoue trop souvent (dépasse `max_restart` et `max_relocate`), elle passe en état `error`.

```bash
# Lorsqu'une VM est en erreur
ha-manager status
# Affiche : service vm:100 (node2, state 'error', target 'started')

# Pour réinitialiser et réessayer
ha-manager set vm:100 --state started

# Ou retirer temporairement de la HA pour investigation
ha-manager set vm:100 --state stopped
```

> [!warning] Attention aux boucles infinies Si une VM a un problème de configuration et ne peut pas démarrer, elle entrera en boucle de redémarrage jusqu'à atteindre `max_restart`. Vérifiez toujours les logs avant de réinitialiser.

```bash
# Vérifier pourquoi une VM ne démarre pas
journalctl -u pve-ha-lrm -f
qm showcmd 100  # Affiche la commande QEMU utilisée
```

#### Maintenance d'un nœud

Pour effectuer une maintenance sur un nœud sans déclencher la HA :

```bash
# Méthode 1 : Migrer toutes les VMs HA vers d'autres nœuds
# (via l'interface ou avec qm migrate)

# Méthode 2 : Désactiver temporairement la HA sur les VMs du nœud
ha-manager set vm:100 --state stopped
ha-manager set vm:101 --state stopped

# Effectuer la maintenance...

# Réactiver la HA
ha-manager set vm:100 --state started
ha-manager set vm:101 --state started
```

> [!tip] Bonnes pratiques pour la maintenance
> 
> - Planifiez les maintenances en dehors des heures de pointe
> - Migrez les VMs manuellement plutôt que de compter sur le basculement HA
> - Testez le retour du nœud avec une VM non critique d'abord
> - Documentez la procédure de maintenance pour votre équipe

### Tests de la HA

> [!warning] Testez en environnement de test d'abord ! Ne testez jamais le fencing sur un cluster de production sans l'avoir testé en pré-production. Un mauvais paramétrage peut causer une panne généralisée.

#### Test 1 : Arrêt propre d'un nœud

```bash
# Sur node1, arrêter proprement
shutdown -h now

# Observer depuis node2 ou node3
ha-manager status
# Les VMs de node1 doivent être redémarrées sur node2 ou node3

# Vérifier les logs
tail -f /var/log/pve-ha-crm.log
```

#### Test 2 : Panne brutale (simuler une coupure électrique)

```bash
# Depuis l'interface IPMI/iLO/iDRAC du serveur
# Ou avec un bouton reset physique

# Observer le comportement du watchdog et du fencing
# Les VMs doivent être relocalisées après ~2-5 minutes
```

#### Test 3 : Perte de réseau Corosync

```bash
# Sur node1, désactiver l'interface réseau de Corosync
ip link set eth0 down

# Observer la réaction du cluster
pvecm status  # Depuis node2
# node1 devrait être marqué comme offline

# Réactiver
ip link set eth0 up
```

### Limitations de la HA Proxmox

|Limitation|Description|Impact|
|---|---|---|
|**Pas de Live Migration automatique**|HA redémarre les VMs, ne les migre pas à chaud|Interruption de service de 2-5 min|
|**Nécessite un stockage partagé**|Les disques locaux ne supportent pas la HA|Coût et complexité accrus|
|**Quorum requis**|Sans quorum, la HA ne fonctionne pas|Un cluster de 2 nœuds n'est pas HA|
|**Conteneurs LXC**|Support HA limité pour les conteneurs|Privilégier les VMs pour les services critiques|
|**Ordre de démarrage**|Pas de dépendances entre VMs HA|Gérer manuellement l'ordre avec des scripts|

> [!info] Conteneurs LXC et HA Les conteneurs LXC peuvent être ajoutés à la HA, mais leur redémarrage est moins fiable que celui des VMs KVM. Pour des services vraiment critiques, privilégiez les VMs.

### Scénarios avancés

#### Combinaison HA + Réplication

Pour minimiser le downtime, combinez HA avec la réplication de stockage :

```bash
# La réplication ZFS ou Ceph maintient une copie à jour des disques
# sur plusieurs nœuds

# En cas de panne :
# 1. Le nœud cible a déjà une copie récente des données
# 2. Le démarrage de la VM est presque instantané
# 3. Downtime réduit à ~30-60 secondes au lieu de 2-5 minutes
```

#### HA avec anti-affinité

Éviter que deux VMs critiques tournent sur le même nœud :

```bash
# Créer deux groupes HA distincts
ha-manager groupadd group-A --nodes "node1:2,node2:1,node3:0"
ha-manager groupadd group-B --nodes "node2:2,node3:1,node1:0"

# Assigner VM 100 à group-A (préfère node1)
ha-manager modify vm:100 --group group-A

# Assigner VM 101 à group-B (préfère node2)
ha-manager modify vm:101 --group group-B

# Ainsi, même en fonctionnement normal, les VMs sont sur des nœuds différents
```

### Bonnes pratiques HA

> [!tip] Recommandations essentielles
> 
> **Configuration du cluster :**
> 
> - Utilisez **3 nœuds minimum** (5 pour les environnements critiques)
> - Configurez un **watchdog matériel** (iTCO, IPMI) plutôt que software
> - Déployez un **stockage partagé performant** (Ceph ou NFS 10Gbps)
> - Mettez en place une **redondance réseau** pour Corosync
> 
> **Configuration des VMs :**
> 
> - Limitez le nombre de VMs en HA aux services **vraiment critiques**
> - Configurez `max_restart=2` et `max_relocate=2` pour éviter les boucles
> - Utilisez des **groupes HA** pour contrôler le placement
> - Activez le **boot automatique** sur les VMs HA
> 
> **Monitoring et tests :**
> 
> - Surveillez les logs HA régulièrement (`/var/log/pve-ha-*.log`)
> - Testez le basculement **au moins une fois par an** en pré-production
> - Documentez les temps de recovery observés
> - Configurez des **alertes** sur les événements de fencing
> 
> **Maintenance :**
> 
> - Planifiez les maintenances avec migration manuelle préalable
> - Vérifiez le quorum avant toute intervention
> - Ne désactivez jamais le watchdog sans raison valable

### Pièges courants

> [!warning] Erreurs fréquentes
> 
> **Cluster de 2 nœuds :**
> 
> - ❌ Un cluster de 2 nœuds ne peut PAS tolérer de panne (quorum = 2)
> - ✅ Utilisez 3 nœuds ou un QDevice externe
> 
> **Pas de fencing :**
> 
> - ❌ Désactiver le watchdog pour "simplifier"
> - ✅ Le fencing est obligatoire pour éviter le split-brain
> 
> **Stockage local :**
> 
> - ❌ Mettre une VM en HA avec disques sur stockage local
> - ✅ Tous les disques des VMs HA doivent être sur stockage partagé
> 
> **Trop de VMs en HA :**
> 
> - ❌ Mettre toutes les VMs en HA "au cas où"
> - ✅ Seules les VMs critiques, pour optimiser les ressources lors d'un basculement
> 
> **Ignorer les états d'erreur :**
> 
> - ❌ Réinitialiser automatiquement sans investiguer
> - ✅ Comprendre pourquoi la VM échoue avant de relancer

---

## 💾 Stockage partagé

### Concept

Le stockage partagé est un système de stockage accessible simultanément par plusieurs nœuds du cluster Proxmox. C'est un composant fondamental pour permettre la Live Migration et la Haute Disponibilité, car il permet à n'importe quel nœud d'accéder aux disques des VMs.

> [!info] Pourquoi c'est important Sans stockage partagé :
> 
> - **Pas de Live Migration possible** (sauf avec `--with-local-disks`, très lent)
> - **Pas de HA fonctionnelle** (les autres nœuds ne peuvent pas accéder aux disques)
> - **Flexibilité limitée** pour déplacer les VMs entre nœuds
> - **Backup complexe** (besoin d'accéder à chaque nœud individuellement)

### Types de stockage partagé

Proxmox supporte plusieurs technologies de stockage partagé, chacune avec ses avantages et inconvénients.

#### Comparaison des technologies

|Type|Complexité|Performance|Coût|Tolérance panne|Usage recommandé|
|---|---|---|---|---|---|
|**NFS**|⭐ Facile|⭐⭐ Moyen|€ Faible|❌ SPOF|PME, environnements de test|
|**iSCSI**|⭐⭐ Moyen|⭐⭐⭐ Bon|€€ Moyen|❌ SPOF|Entreprises, besoins performance|
|**Ceph RBD**|⭐⭐⭐ Complexe|⭐⭐⭐⭐ Excellent|€€€ Élevé|✅ Oui|Production critique, scalabilité|
|**GlusterFS**|⭐⭐⭐ Complexe|⭐⭐ Moyen|€€ Moyen|✅ Oui|Fichiers volumineux, archives|
|**ZFS over iSCSI**|⭐⭐⭐ Complexe|⭐⭐⭐⭐ Excellent|€€ Moyen|❌ SPOF|Haute performance, intégrité données|

> [!warning] SPOF = Single Point of Failure NFS, iSCSI et ZFS over iSCSI nécessitent un serveur de stockage dédié qui devient un point de défaillance unique. Pour éliminer ce SPOF, il faut mettre en place de la redondance (NFS HA, stockage SAN redondé, etc.)

### NFS (Network File System)

NFS est le plus simple à mettre en place pour débuter avec le stockage partagé.

#### Configuration d'un serveur NFS

Sur un serveur de stockage dédié (ou un des nœuds Proxmox) :

```bash
# Installation du serveur NFS
apt update
apt install nfs-kernel-server

# Créer le répertoire de partage
mkdir -p /mnt/pve-nfs
chown nobody:nogroup /mnt/pve-nfs
chmod 755 /mnt/pve-nfs

# Configuration NFS dans /etc/exports
echo "/mnt/pve-nfs 192.168.1.0/24(rw,sync,no_subtree_check,no_root_squash)" >> /etc/exports

# Appliquer la configuration
exportfs -ra

# Vérifier les exports actifs
showmount -e localhost
```

**Options NFS importantes :**

- `rw` : Lecture et écriture
- `sync` : Synchronisation immédiate (plus sûr mais plus lent)
- `no_subtree_check` : Améliore la fiabilité
- `no_root_squash` : Permet à root de conserver ses privilèges (nécessaire pour Proxmox)

> [!warning] Sécurité NFS `no_root_squash` est nécessaire pour Proxmox mais représente un risque de sécurité. Assurez-vous de restreindre l'accès NFS uniquement au réseau du cluster (pas d'accès depuis Internet).

#### Ajouter le stockage NFS dans Proxmox

**Via l'interface web :**

1. **Datacenter** → **Storage** → **Add** → **NFS**
2. Remplir les champs :
    - **ID** : `nfs-shared` (nom du stockage)
    - **Server** : `192.168.1.50` (IP du serveur NFS)
    - **Export** : `/mnt/pve-nfs`
    - **Content** : Sélectionner `Disk image`, `ISO image`, `Container`, `VZDump backup`

**Via la ligne de commande :**

```bash
# Ajouter le stockage NFS
pvesm add nfs nfs-shared \
  --server 192.168.1.50 \
  --export /mnt/pve-nfs \
  --content images,iso,vztmpl,backup \
  --options vers=3

# Vérifier que le stockage est actif
pvesm status

# Tester l'accès
pvesm list nfs-shared
```

**Options NFS avancées :**

```bash
# Spécifier la version NFS
--options vers=4.2

# Activer le mode asynchrone (plus rapide, moins sûr)
--options async

# Options combinées pour performances maximales
--options vers=4.2,async,nocto,nolock
```

> [!tip] Performance NFS Pour améliorer les performances NFS :
> 
> - Utilisez NFS v4.2 (plus récent et plus rapide)
> - Réseau 10Gbps dédié entre Proxmox et le serveur NFS
> - SSD ou NVMe sur le serveur NFS
> - MTU 9000 (Jumbo Frames) si le réseau le supporte

#### Limites de NFS

- **Point de défaillance unique** : Si le serveur NFS tombe, toutes les VMs sont inaccessibles
- **Performances I/O** : Moins performant que du stockage local ou Ceph
- **Latence réseau** : Sensible à la qualité du réseau

### iSCSI

iSCSI (Internet Small Computer System Interface) expose des volumes de stockage en mode bloc sur le réseau.

#### Avantages d'iSCSI vs NFS

- **Meilleures performances** pour les workloads intensifs en I/O
- **Mode bloc** : Plus proche du disque physique
- **Multipath** : Possibilité de redondance de chemins

> [!info] Quand utiliser iSCSI Privilégiez iSCSI pour :
> 
> - Les bases de données avec beaucoup d'écritures aléatoires
> - Les VMs nécessitant des performances disque élevées
> - Les environnements où vous avez déjà un SAN iSCSI

#### Configuration d'un serveur iSCSI (TrueNAS)

TrueNAS est une solution populaire pour exposer du stockage iSCSI :

1. Créer un **zvol** (volume ZFS)
2. Créer un **Target iSCSI**
3. Créer une **LUN** associée au zvol
4. Configurer les **Initiators** autorisés (IPs des nœuds Proxmox)

```bash
# Exemple de configuration sur TrueNAS via CLI
# (généralement fait via l'interface web)

# Créer un zvol de 500GB
zfs create -V 500G tank/iscsi-pve

# Le reste se fait via l'interface web TrueNAS
# Services → iSCSI → Portals, Initiators, Targets, Extents
```

#### Ajouter le stockage iSCSI dans Proxmox

```bash
# Installer les outils iSCSI sur chaque nœud Proxmox
apt install open-iscsi

# Découvrir les targets iSCSI disponibles
iscsiadm -m discovery -t st -p 192.168.1.50

# Exemple de sortie :
# 192.168.1.50:3260,1 iqn.2025-01.com.truenas:pve-storage

# Se connecter au target
iscsiadm -m node --targetname iqn.2025-01.com.truenas:pve-storage --portal 192.168.1.50 --login

# Vérifier les sessions iSCSI actives
iscsiadm -m session

# Les disques iSCSI apparaissent comme /dev/sdX
lsblk
```

**Ajouter dans Proxmox :**

```bash
# Ajouter le stockage iSCSI
pvesm add iscsi iscsi-storage \
  --portal 192.168.1.50 \
  --target iqn.2025-01.com.truenas:pve-storage

# Ajouter le stockage LVM sur iSCSI pour les disques de VMs
pvesm add lvmthin iscsi-lvm \
  --vgname pve-iscsi \
  --thinpool data \
  --content images,rootdir
```

> [!warning] Configuration sur tous les nœuds La connexion iSCSI doit être configurée sur **chaque nœud** du cluster pour que le stockage soit accessible partout.

#### Multipath iSCSI

Pour la redondance, configurez plusieurs chemins vers le stockage iSCSI :

```bash
# Installer multipath
apt install multipath-tools

# Configuration dans /etc/multipath.conf
defaults {
    user_friendly_names yes
    find_multipaths yes
}

# Redémarrer le service
systemctl restart multipath-tools

# Vérifier les chemins multiples
multipath -ll
```

### Ceph RBD

Ceph est un système de stockage distribué qui élimine le SPOF en répartissant les données sur plusieurs nœuds.

> [!info] Ceph en bref Ceph est un stockage objet, bloc et fichier entièrement distribué. Dans Proxmox, on utilise principalement **Ceph RBD** (RADOS Block Device) pour les disques de VMs.

#### Architecture Ceph

```
Cluster Proxmox/Ceph (3 nœuds minimum)
├── node1
│   ├── OSD (Object Storage Daemon) - Disque 1
│   ├── OSD - Disque 2
│   └── MON (Monitor) - Surveillance du cluster
├── node2
│   ├── OSD - Disque 1
│   ├── OSD - Disque 2
│   └── MON
└── node3
    ├── OSD - Disque 1
    ├── OSD - Disque 2
    └── MON

Les données sont répliquées sur plusieurs OSDs (généralement 3 copies)
```

#### Avantages de Ceph

- **Pas de SPOF** : Les données sont distribuées et répliquées
- **Scalabilité** : Ajoutez des nœuds pour plus d'espace et de performance
- **Auto-réparation** : Ceph détecte et corrige automatiquement les pannes de disques
- **Intégration native** dans Proxmox

#### Installation de Ceph dans Proxmox

> [!warning] Prérequis Ceph
> 
> - Minimum **3 nœuds** Proxmox
> - Minimum **3 disques** dédiés (idéalement SSD/NVMe)
> - Réseau **10Gbps** dédié recommandé
> - Eviter de mélanger stockage Ceph et VMs sur les mêmes disques en production

**Installation via l'interface web :**

1. **node1** → **Ceph** → **Install Ceph**
2. Choisir la version Ceph (ex: Quincy, Reef)
3. Configurer le réseau Ceph
4. Créer les Monitors (MON) sur chaque nœud
5. Créer les OSDs (un par disque physique)
6. Créer un pool RBD pour les VMs

```bash
# Installation via CLI (sur chaque nœud)
pveceph install --version quincy

# Initialiser Ceph (sur le premier nœud uniquement)
pveceph init --network 10.0.1.0/24

# Créer les monitors sur chaque nœud
pveceph mon create

# Créer les OSDs (répéter pour chaque disque)
pveceph osd create /dev/sdb
pveceph osd create /dev/sdc
pveceph osd create /dev/sdd

# Créer un pool RBD pour les VMs
pveceph pool create vm-pool --size 3 --min_size 2 --pg_num 128

# Ajouter le stockage RBD dans Proxmox
pvesm add rbd ceph-rbd \
  --pool vm-pool \
  --content images,rootdir \
  --krbd 0
```

**Options importantes :**

- `--size 3` : Nombre de réplicas (3 = tolérance à 2 pannes)
- `--min_size 2` : Nombre minimum de réplicas pour écriture
- `--pg_num 128` : Nombre de placement groups (ajuster selon la taille)

#### Performance Ceph

```bash
# Vérifier l'état du cluster Ceph
ceph -s

# Tester les performances
rados bench -p vm-pool 60 write --no-cleanup
rados bench -p vm-pool 60 seq
rados bench -p vm-pool 60 rand

# Nettoyer après les tests
rados -p vm-pool cleanup
```

> [!tip] Optimisation Ceph
> 
> - Utilisez des **SSD/NVMe** pour les OSDs (pas de HDD en production)
> - Séparez le réseau Ceph du réseau de management (VLANs ou interfaces physiques)
> - Configurez des **SSD séparés** pour les journaux Ceph (améliore l'écriture)
> - Moniteur la charge avec `ceph -w` en temps réel

#### Réplication et redondance

```bash
# Vérifier la réplication des données
ceph osd pool get vm-pool size
# Sortie : size: 3

# Afficher la distribution des données
ceph pg dump

# Simuler une panne (retirer un OSD)
systemctl stop ceph-osd@0

# Ceph commence automatiquement à ré-répliquer les données
ceph -w
# Observer : health HEALTH_WARN → recovery → HEALTH_OK
```

### GlusterFS

GlusterFS est un système de fichiers distribué, moins utilisé pour les VMs Proxmox mais utile pour le stockage de fichiers volumineux.

```bash
# Installation sur chaque nœud
apt install glusterfs-server

# Créer un volume distribué-répliqué
gluster volume create gv0 replica 3 \
  node1:/mnt/gluster/brick1 \
  node2:/mnt/gluster/brick1 \
  node3:/mnt/gluster/brick1

# Démarrer le volume
gluster volume start gv0

# Monter dans Proxmox
pvesm add glusterfs gluster-shared \
  --server node1 \
  --volume gv0 \
  --content backup,iso
```

> [!info] GlusterFS vs Ceph
> 
> - **GlusterFS** : Meilleur pour les gros fichiers séquentiels (ISO, backups)
> - **Ceph** : Meilleur pour les workloads aléatoires (disques de VMs)

### Configuration et bonnes pratiques

#### Types de contenu par stockage

Chaque type de stockage peut héberger différents types de contenu :

|Contenu|NFS|iSCSI|Ceph|Local|
|---|---|---|---|---|
|**Disk image**|✅|✅|✅|✅|
|**ISO image**|✅|❌|✅|✅|
|**Container template**|✅|❌|✅|✅|
|**VZDump backup**|✅|❌|✅|✅|
|**Snippets**|✅|❌|✅|✅|

```bash
# Configurer les types de contenu acceptés
pvesm set nfs-shared --content images,iso,vztmpl,backup,snippets

# Définir un stockage comme cible par défaut pour les VMs
pvesm set ceph-rbd --content images --default 1
```

#### Stratégie de stockage multi-tier

> [!tip] Architecture recommandée pour la production
> 
> **Tier 1 - Performance (Ceph SSD/NVMe)**
> 
> - VMs critiques nécessitant des performances élevées
> - Bases de données, applications transactionnelles
> 
> **Tier 2 - Standard (Ceph HDD ou NFS)**
> 
> - VMs standard, environnements de développement
> - Serveurs web, applications classiques
> 
> **Tier 3 - Backup (NFS)**
> 
> - Snapshots, backups, archives
> - ISOs, templates de conteneurs

```bash
# Exemple : 3 stockages pour 3 tiers
pvesm add rbd ceph-ssd --pool ssd-pool --content images
pvesm add rbd ceph-hdd --pool hdd-pool --content images
pvesm add nfs backup-nfs --server 192.168.1.50 --export /backup --content backup,iso
```

#### Monitoring du stockage

```bash
# État général de tous les stockages
pvesm status

# Détails d'un stockage spécifique
pvesm list nfs-shared

# Utilisation disque
df -h /mnt/pve/nfs-shared

# Pour Ceph
ceph df
ceph osd df tree

# Pour iSCSI
pvesm lvmscan
vgs   # Volume groups
lvs   # Logical volumes
```

**Interface web :**

- **Datacenter** → **Storage** : Vue d'ensemble de l'espace disponible
- **Node** → **Disks** : État des disques physiques et OSDs Ceph

#### Snapshots sur stockage partagé

Les snapshots de VMs sur stockage partagé dépendent de la technologie utilisée :

```bash
# NFS : Snapshots gérés par QCOW2 (intégrés dans le fichier image)
qm snapshot 100 snap1 --description "Avant mise à jour"

# Ceph : Snapshots natifs RBD (très rapides, CoW)
qm snapshot 100 snap1

# Lister les snapshots
qm listsnapshot 100

# Restaurer un snapshot
qm rollback 100 snap1

# Supprimer un snapshot
qm delsnapshot 100 snap1
```

> [!tip] Snapshots Ceph vs QCOW2
> 
> - **Ceph RBD** : Snapshots instantanés, pas d'impact performance, espace efficient
> - **QCOW2 (NFS)** : Snapshots plus lents, peuvent impacter les performances si trop nombreux

#### Migration de VMs entre stockages

```bash
# Migrer une VM d'un stockage local vers du stockage partagé
qm migrate 100 node1 \
  --targetstorage ceph-rbd \
  --online

# Déplacer juste un disque vers un autre stockage
qm move-disk 100 scsi0 ceph-rbd \
  --delete 1

# Vérifier la configuration des disques
qm config 100 | grep "scsi0"
```

### Dépannage du stockage partagé

#### Problèmes courants NFS

> [!warning] Erreurs NFS fréquentes

**Erreur : "Permission denied"**

```bash
# Vérifier les permissions sur le serveur NFS
ls -la /mnt/pve-nfs

# Vérifier la configuration /etc/exports
cat /etc/exports | grep pve-nfs

# S'assurer que no_root_squash est présent
exportfs -v

# Tester le mount manuellement
mount -t nfs 192.168.1.50:/mnt/pve-nfs /mnt/test
```

**Erreur : "Stale file handle"**

```bash
# Le serveur NFS a redémarré ou le export a changé
# Solution : remonter le share

# Sur chaque nœud Proxmox
umount /mnt/pve/nfs-shared
mount -a

# Ou redémarrer le service pve-storage
systemctl restart pve-storage
```

**Performances lentes**

```bash
# Vérifier la latence réseau
ping 192.168.1.50

# Tester les performances NFS
dd if=/dev/zero of=/mnt/pve/nfs-shared/test.img bs=1M count=1024 oflag=direct

# Optimiser les options de mount
# Dans /etc/fstab ou la configuration Proxmox :
# rsize=131072,wsize=131072,timeo=14,intr
```

#### Problèmes courants iSCSI

**Connexion iSCSI perdue**

```bash
# Vérifier les sessions iSCSI
iscsiadm -m session

# Rien n'apparaît ? Reconnecter
iscsiadm -m node --login

# Vérifier les logs
journalctl -u open-iscsi -f

# Problème réseau ? Vérifier la connectivité
ping 192.168.1.50
telnet 192.168.1.50 3260
```

**Multipath ne fonctionne pas**

```bash
# Vérifier la configuration multipath
multipath -ll

# Vérifier que les deux chemins sont visibles
iscsiadm -m session

# Reconfigurer multipath si nécessaire
multipath -F   # Flush
multipath -v3  # Rebuild avec verbosité
```

#### Problèmes courants Ceph

**Cluster HEALTH_WARN ou HEALTH_ERR**

```bash
# Diagnostic détaillé
ceph health detail

# Causes fréquentes :
# 1. OSD down
ceph osd tree
systemctl status ceph-osd@X

# 2. Problème de clock skew
# Vérifier la synchronisation NTP sur tous les nœuds
timedatectl status

# 3. PG incomplete
ceph pg dump | grep incomplete

# 4. Pas assez d'OSDs pour la réplication
ceph osd pool get vm-pool size
ceph osd pool get vm-pool min_size
```

**Performances Ceph dégradées**

```bash
# Identifier les OSDs lents
ceph osd perf

# Vérifier l'utilisation des OSDs
ceph osd df tree

# Monitorer les opérations en temps réel
ceph -w

# Vérifier la latency réseau entre les nœuds
# (important pour Ceph)
iperf3 -s  # Sur un nœud
iperf3 -c node1  # Depuis un autre nœud
```

**Espace disque plein**

```bash
# Vérifier l'utilisation globale
ceph df

# Identifier les pools qui consomment le plus
ceph osd pool stats

# Nettoyer les snapshots inutilisés
rbd snap ls vm-pool/vm-100-disk-0
rbd snap rm vm-pool/vm-100-disk-0@snap1

# Augmenter la capacité (ajouter des OSDs)
pveceph osd create /dev/sdX
```

### Pièges courants du stockage partagé

> [!warning] Erreurs à éviter
> 
> **NFS :**
> 
> - ❌ Oublier `no_root_squash` dans /etc/exports
> - ❌ Utiliser un réseau 1Gbps pour des VMs performantes
> - ❌ Ne pas configurer de NFS HA (SPOF)
> - ✅ Utilisez NFS v4.2 et un réseau 10Gbps dédié
> 
> **iSCSI :**
> 
> - ❌ Connecter le même LUN depuis plusieurs nœuds sans clustering filesystem
> - ❌ Oublier de configurer iSCSI sur tous les nœuds du cluster
> - ❌ Ne pas mettre en place multipath pour la redondance
> - ✅ Documentez vos IQNs et assurez la connectivité réseau stable
> 
> **Ceph :**
> 
> - ❌ Moins de 3 nœuds (pas de réplication efficace)
> - ❌ Utiliser des disques HDD pour des VMs nécessitant des performances
> - ❌ Sous-dimensionner le réseau (1Gbps insuffisant)
> - ❌ Mélanger OSDs et VMs sur les mêmes disques sans SSD séparés
> - ✅ Minimum 3 nœuds, réseau 10Gbps, SSD/NVMe pour les OSDs

### Comparaison finale et recommandations

#### Matrice de décision

|Critère|NFS|iSCSI/SAN|Ceph|
|---|---|---|---|
|**Budget**|💰 Faible|💰💰 Moyen|💰💰💰 Élevé|
|**Complexité**|⭐ Simple|⭐⭐ Moyen|⭐⭐⭐ Complexe|
|**Performance**|⭐⭐ Correct|⭐⭐⭐ Bon|⭐⭐⭐⭐ Excellent|
|**Scalabilité**|⭐ Limitée|⭐⭐ Moyenne|⭐⭐⭐⭐ Excellente|
|**Résilience**|❌ SPOF|❌ SPOF|✅ Distribué|
|**Maintenance**|⭐ Simple|⭐⭐ Moyenne|⭐⭐⭐ Complexe|

#### Recommandations par taille d'infrastructure

> [!tip] Guide de choix
> 
> **Petite infrastructure (2-3 nœuds, budget limité) :**
> 
> - 🥇 **NFS** pour démarrer rapidement
> - Alternative : iSCSI si vous avez un NAS existant
> - Accepter le SPOF ou mettre en place NFS HA
> 
> **Infrastructure moyenne (3-5 nœuds, budget moyen) :**
> 
> - 🥇 **Ceph** pour éliminer le SPOF
> - Alternative : iSCSI sur SAN redondant
> - Investir dans du réseau 10Gbps
> 
> **Grande infrastructure (5+ nœuds, production critique) :**
> 
> - 🥇 **Ceph** avec OSDs SSD/NVMe
> - Réseau 10Gbps (ou 25Gbps) dédié
> - Architecture multi-tier (Ceph SSD + Ceph HDD + NFS backup)

#### Configuration hybride recommandée

```bash
# Architecture type pour la production :

# Stockage primaire : Ceph RBD (VMs critiques)
pvesm add rbd ceph-ssd \
  --pool ssd-pool \
  --content images

# Stockage secondaire : NFS (backups, ISOs)
pvesm add nfs backup-nfs \
  --server 192.168.1.50 \
  --export /backup \
  --content backup,iso,vztmpl

# Stockage local : Snapshots temporaires, cache
# (déjà configuré par défaut sur chaque nœud)
```

### Bonnes pratiques finales

> [!tip] Checklist stockage partagé
> 
> **Planification :**
> 
> - [ ] Évaluer les besoins en IOPS et débit
> - [ ] Dimensionner le réseau (10Gbps minimum recommandé)
> - [ ] Prévoir la croissance (capacité, performance)
> - [ ] Budgéter les coûts matériels et de maintenance
> 
> **Mise en place :**
> 
> - [ ] Séparer le réseau de stockage du réseau de production
> - [ ] Configurer la redondance réseau (bonding/LACP)
> - [ ] Tester les performances avant la production
> - [ ] Documenter la configuration (IPs, identifiants, architecture)
> 
> **Exploitation :**
> 
> - [ ] Monitorer l'utilisation et les performances quotidiennement
> - [ ] Configurer des alertes (espace disque, santé Ceph, etc.)
> - [ ] Planifier les maintenances (firmwares, mises à jour)
> - [ ] Tester régulièrement les procédures de récupération
> 
> **Sécurité :**
> 
> - [ ] Isoler le réseau de stockage (VLAN dédié)
> - [ ] Limiter l'accès NFS/iSCSI aux seuls nœuds du cluster
> - [ ] Chiffrer les communications si sensible
> - [ ] Sauvegarder la configuration du stockage

---

## 🎯 Synthèse des fonctionnalités du cluster

Les quatre fonctionnalités présentées sont interdépendantes et forment ensemble un système cohérent :

```
┌─────────────────────────────────────────────────────────────┐
│                    GESTION CENTRALISÉE                       │
│  Interface unique pour administrer tout le cluster          │
└────────────────┬────────────────────────────────────────────┘
                 │
        ┌────────┴────────┬────────────┬───────────┐
        ▼                 ▼            ▼           ▼
   ┌─────────┐    ┌──────────┐  ┌─────────┐  ┌──────────┐
   │ STOCKAGE│    │   LIVE   │  │   HA    │  │  Autres  │
   │ PARTAGÉ │◄───┤ MIGRATION│◄─┤         │  │ features │
   └─────────┘    └──────────┘  └─────────┘  └──────────┘
        │              │              │
        └──────────────┴──────────────┘
                       │
              ┌────────▼────────┐
              │  VMs toujours   │
              │  disponibles    │
              │  et mobiles     │
              └─────────────────┘
```

### Matrice de dépendances

|Fonctionnalité|Nécessite|Permet|
|---|---|---|
|**Gestion centralisée**|Cluster Proxmox|Administrer toutes les ressources|
|**Stockage partagé**|Réseau performant|Live Migration, HA|
|**Live Migration**|Stockage partagé|Maintenance sans interruption|
|**HA**|Stockage partagé, Quorum|Redémarrage automatique|

### Scénario complet d'utilisation

> [!example] Cas pratique : Maintenance d'un nœud
> 
> **Situation :** Vous devez remplacer la RAM du node1
> 
> **Sans ces fonctionnalités :**
> 
> 1. Arrêter toutes les VMs sur node1 ❌
> 2. Maintenance (2-4h de downtime) ❌
> 3. Redémarrer les VMs manuellement ❌
> 4. Impact client majeur ❌
> 
> **Avec un cluster Proxmox complet :**
> 
> 1. Depuis l'interface web centralisée (node2 ou node3)
> 2. Migrer à chaud les VMs vers node2 et node3 (10-20 min)
> 3. Les VMs continuent de tourner, zéro interruption ✅
> 4. Effectuer la maintenance sur node1 en toute tranquillité
> 5. Remettre node1 en production
> 6. (Optionnel) Re-migrer certaines VMs vers node1 pour équilibrer
> 
> **Résultat :** Aucun impact utilisateur, maintenance transparente

### Points clés à retenir

> [!info] Mémo essentiel
> 
> **Gestion centralisée :**
> 
> - Une seule interface pour tout le cluster
> - Configuration synchronisée automatiquement via `/etc/pve/`
> - Recherche et monitoring global
> 
> **Live Migration :**
> 
> - Déplacement de VMs sans interruption (50-500ms de downtime)
> - Nécessite stockage partagé et CPUs compatibles
> - Essentiel pour la maintenance sans impact
> 
> **Haute disponibilité :**
> 
> - Redémarrage automatique en cas de panne nœud (2-5 min)
> - Nécessite quorum (minimum 3 nœuds recommandé)
> - Fencing obligatoire pour éviter le split-brain
> 
> **Stockage partagé :**
> 
> - Condition sine qua non pour Migration et HA
> - NFS (simple), iSCSI (performant), Ceph (résilient)
> - Choisir selon le budget et les besoins de performance

---

## 📚 Conclusion

Les fonctionnalités du cluster Proxmox transforment un ensemble de serveurs indépendants en une plateforme de virtualisation unifiée, flexible et hautement disponible. La combinaison de la gestion centralisée, de la migration à chaud, de la haute disponibilité et du stockage partagé permet de construire une infrastructure moderne répondant aux exigences de disponibilité et de flexibilité des environnements professionnels.

**La prochaine étape logique** après la maîtrise de ces fonctionnalités est l'apprentissage de la **gestion avancée du cluster**, notamment :

- La configuration réseau avancée (SDN, VLANs)
- Les stratégies de backup et réplication
- Le monitoring et l'alerting
- L'automatisation avec l'API Proxmox

> [!tip] Pour aller plus loin Expérimentez ces fonctionnalités dans un environnement de test avant de les déployer en production. Proxmox peut être installé dans des VMs imbriquées (nested virtualization) pour créer un lab de test sans matériel supplémentaire.