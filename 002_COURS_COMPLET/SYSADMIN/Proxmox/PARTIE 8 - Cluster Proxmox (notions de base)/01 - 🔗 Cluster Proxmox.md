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

## 🎯 Introduction au clustering

Le clustering dans Proxmox VE permet de regrouper plusieurs serveurs physiques (nœuds) en une infrastructure unifiée et hautement disponible. Cette technologie est essentielle pour les environnements de production nécessitant résilience et facilité de gestion.

> [!info] Contexte Un cluster Proxmox transforme plusieurs serveurs indépendants en une plateforme cohérente où les ressources peuvent être gérées centralement et où les machines virtuelles peuvent être déplacées entre serveurs sans interruption.

---

## 🏗️ Qu'est-ce qu'un cluster Proxmox

### Définition

Un cluster Proxmox VE est un groupe de nœuds Proxmox interconnectés qui :

- Partagent une configuration commune
- Communiquent via un réseau dédié
- Permettent la gestion centralisée depuis n'importe quel nœud
- Offrent la haute disponibilité des VM et conteneurs

### Architecture d'un cluster

```
┌─────────────┐      ┌─────────────┐      ┌─────────────┐
│   Nœud 1    │◄────►│   Nœud 2    │◄────►│   Nœud 3    │
│  (Master)   │      │             │      │             │
└─────────────┘      └─────────────┘      └─────────────┘
       │                    │                    │
       └────────────────────┴────────────────────┘
                    Réseau Cluster
                  (Corosync + PMxCFS)
```

> [!example] Composants clés
> 
> - **Corosync** : Gère la communication entre nœuds et le quorum
> - **PMxCFS (Proxmox Cluster File System)** : Système de fichiers distribué pour la configuration
> - **Quorum** : Mécanisme de vote pour maintenir la cohérence du cluster

### Caractéristiques techniques

|Caractéristique|Description|
|---|---|
|**Nombre de nœuds**|Minimum 3 recommandé (peut fonctionner avec 2 + QDevice)|
|**Synchronisation**|Configuration synchronisée en temps réel|
|**Base de données**|SQLite distribuée (PMxCFS)|
|**Communication**|UDP multicast ou unicast (Corosync)|
|**Latence max**|< 5ms recommandé entre nœuds|

> [!warning] Limitation importante Tous les nœuds d'un cluster doivent pouvoir communiquer directement entre eux. Un cluster ne peut pas être étendu sur plusieurs sites distants sans infrastructure spécifique (stretched cluster).

### Fonctionnement de la synchronisation

La configuration du cluster est stockée dans `/etc/pve/`, un système de fichiers monté via FUSE qui :

- Est en lecture/écriture sur tous les nœuds
- Se synchronise automatiquement via Corosync
- Contient toutes les configurations : VMs, stockages, utilisateurs, etc.

```bash
# Contenu typique de /etc/pve/
/etc/pve/
├── authkey.pub          # Clé publique du cluster
├── corosync.conf        # Configuration Corosync
├── datacenter.cfg       # Configuration globale
├── nodes/               # Configuration par nœud
│   ├── node1/
│   ├── node2/
│   └── node3/
├── priv/                # Clés privées
├── qemu-server/         # Configuration des VMs
└── storage.cfg          # Configuration du stockage
```

> [!tip] Astuce de diagnostic Si un fichier de configuration ne se synchronise pas, vérifiez l'état de PMxCFS avec `pvecm status` et `systemctl status pve-cluster`.

---

## ✨ Avantages du clustering

### 1. Gestion centralisée

**Ce que ça apporte :**

- Interface web unique pour gérer tous les nœuds
- Configuration centralisée des utilisateurs et permissions
- Vue d'ensemble des ressources disponibles
- Déploiement et gestion simplifiés

```bash
# Commandes exécutables depuis n'importe quel nœud
pvesh get /cluster/resources    # Liste toutes les ressources du cluster
pvecm nodes                     # Liste tous les nœuds
```

> [!example] Exemple concret Au lieu de se connecter à chaque serveur individuellement, un administrateur peut gérer 10 serveurs depuis une seule interface web, voir instantanément quelle VM tourne sur quel nœud, et migrer des ressources en quelques clics.

### 2. Haute disponibilité (HA)

**Fonctionnalités HA :**

- Redémarrage automatique des VMs sur un autre nœud en cas de panne
- Surveillance continue de l'état des nœuds
- Politiques de placement configurables
- Protection contre le split-brain

> [!info] Fonctionnement du HA Le gestionnaire HA (ha-manager) surveille constamment les VMs marquées comme "HA". Si un nœud tombe en panne, les VMs sont automatiquement redémarrées sur les nœuds survivants selon les ressources disponibles.

**Configuration HA :**

```bash
# Activer le HA pour une VM
ha-manager add vm:100 --state started --max_relocate 3 --max_restart 5

# Voir l'état HA
ha-manager status
```

### 3. Migration en direct (Live Migration)

**Capacités de migration :**

- Migration de VMs sans interruption de service
- Migration de conteneurs LXC (avec restart)
- Maintenance sans downtime
- Équilibrage de charge manuel ou automatique

> [!tip] Quand utiliser la migration
> 
> - Mise à jour d'un hyperviseur
> - Équilibrage des ressources
> - Maintenance matérielle
> - Optimisation énergétique (consolidation)

```bash
# Migration en direct d'une VM
qm migrate 100 node2 --online --with-local-disks 0

# Migration d'un conteneur (avec redémarrage)
pct migrate 101 node3 --restart
```

> [!warning] Prérequis pour la live migration
> 
> - Stockage partagé (Ceph, NFS, iSCSI) OU utilisation de `--with-local-disks` (plus lent)
> - Réseau performant (10 Gbps recommandé)
> - CPU compatibles ou mode "host" désactivé

### 4. Résilience et continuité de service

**Mécanismes de protection :**

- Détection automatique des pannes via quorum
- Isolation des nœuds défaillants (fencing)
- Récupération automatique des services critiques
- Tolérance aux pannes réseau partielles

|Scénario|Comportement du cluster|
|---|---|
|1 nœud down (sur 3)|Cluster continue, VMs HA redémarrent|
|2 nœuds down (sur 3)|Cluster perd le quorum, aucune action automatique|
|Panne réseau cluster|Split-brain évité par quorum|
|Corruption d'un nœud|Autres nœuds non affectés|

### 5. Scalabilité horizontale

**Ajout de ressources :**

- Ajout de nouveaux nœuds sans interruption
- Distribution automatique de la charge
- Croissance progressive selon les besoins
- Pas de limite technique stricte (32 nœuds recommandé)

```bash
# Ajouter un nouveau nœud au cluster (depuis le nouveau nœud)
pvecm add IP_DU_CLUSTER
```

### 6. Sauvegarde et réplication centralisées

**Avantages pour les sauvegardes :**

- Configuration des jobs de backup depuis l'interface centrale
- Sauvegardes distribuées sur plusieurs nœuds
- Réplication entre nœuds pour la redondance
- Planification centralisée

> [!info] Note importante Ces fonctionnalités de sauvegarde et réplication seront détaillées dans les parties dédiées du cours.

---

## 🌐 Prérequis réseau

### Configuration réseau essentielle

Pour qu'un cluster Proxmox fonctionne correctement, le réseau doit respecter des critères stricts de performance et de fiabilité.

### 1. Réseau dédié pour le cluster

> [!warning] Bonne pratique critique Utilisez **toujours** un réseau séparé pour la communication du cluster, distinct du réseau de gestion et du réseau des VMs.

**Pourquoi un réseau dédié ?**

- Évite la congestion réseau
- Garantit une latence faible et stable
- Isole le trafic critique du cluster
- Améliore la sécurité

```
Architecture réseau recommandée :

┌─────────────────────────────────────────┐
│              Nœud Proxmox               │
├─────────────────────────────────────────┤
│ eth0: 192.168.1.10  → Réseau gestion    │
│ eth1: 10.0.0.10     → Réseau cluster    │
│ eth2: 172.16.0.10   → Réseau VM/storage │
└─────────────────────────────────────────┘
```

### 2. Spécifications réseau

|Paramètre|Valeur recommandée|Valeur minimale|
|---|---|---|
|**Latence**|< 2ms|< 5ms|
|**Bande passante**|10 Gbps|1 Gbps|
|**MTU**|9000 (Jumbo Frames)|1500|
|**Perte de paquets**|0%|< 0.01%|
|**Jitter**|< 1ms|< 5ms|

> [!tip] Test de latence Avant de créer un cluster, testez la latence entre nœuds :
> 
> ```bash
> # Test depuis nœud1 vers nœud2
> ping -c 100 10.0.0.11 | tail -1
> 
> # Test avec statistiques détaillées
> fping -c 1000 -q 10.0.0.11 10.0.0.12 10.0.0.13
> ```

### 3. Configuration réseau par nœud

**Fichier `/etc/network/interfaces` typique :**

```bash
# Interface de gestion (accès web)
auto eth0
iface eth0 inet static
    address 192.168.1.10/24
    gateway 192.168.1.1

# Interface cluster (Corosync)
auto eth1
iface eth1 inet static
    address 10.0.0.10/24
    mtu 9000
    # Pas de gateway sur le réseau cluster

# Interface storage/VM
auto eth2
iface eth2 inet static
    address 172.16.0.10/24
    mtu 9000

# Bridge pour les VMs
auto vmbr0
iface vmbr0 inet static
    address 172.16.0.10/24
    bridge-ports eth2
    bridge-stp off
    bridge-fd 0
```

> [!info] Explication des interfaces
> 
> - **eth0** : Accès à l'interface web et SSH
> - **eth1** : Communication Corosync (trafic cluster)
> - **eth2/vmbr0** : Réseau des VMs et accès au stockage

### 4. Résolution de noms (DNS/Hosts)

**Chaque nœud doit pouvoir résoudre les noms des autres nœuds.**

**Option 1 : Fichier `/etc/hosts` (recommandé pour les petits clusters)**

```bash
# Sur chaque nœud, ajouter :
10.0.0.10    node1.cluster.local    node1
10.0.0.11    node2.cluster.local    node2
10.0.0.12    node3.cluster.local    node3
```

**Option 2 : DNS interne**

```bash
# Configurer le DNS dans /etc/resolv.conf
nameserver 10.0.0.1
search cluster.local
```

> [!warning] Attention aux FQDN Lors de la création du cluster, utilisez des noms de domaine pleinement qualifiés (FQDN) ou des adresses IP. Ne mélangez jamais les deux dans un même cluster.

### 5. Pare-feu et ports nécessaires

**Ports à ouvrir entre les nœuds du cluster :**

|Port|Protocole|Service|Description|
|---|---|---|---|
|22|TCP|SSH|Gestion à distance|
|5405-5412|UDP|Corosync|Communication cluster|
|3128|TCP|SPICE Proxy|Console SPICE|
|8006|TCP|pveproxy|Interface web|
|85|TCP|pvedaemon|API Proxmox|
|111|TCP/UDP|rpcbind|RPC (pour NFS si utilisé)|
|60000-60050|TCP|Migration|Live migration VMs|

**Configuration pare-feu (exemple avec iptables) :**

```bash
# Autoriser tout le trafic sur le réseau cluster
iptables -A INPUT -s 10.0.0.0/24 -j ACCEPT

# Ou de manière plus granulaire
iptables -A INPUT -p udp --dport 5405:5412 -s 10.0.0.0/24 -j ACCEPT
iptables -A INPUT -p tcp --dport 60000:60050 -s 10.0.0.0/24 -j ACCEPT
```

> [!tip] Proxmox Firewall intégré Proxmox VE dispose d'un pare-feu intégré configurable via l'interface web. Il est recommandé de l'utiliser plutôt que de gérer manuellement iptables.

### 6. Multicast vs Unicast

Corosync peut utiliser deux modes de communication :

**Multicast (par défaut jusqu'à Proxmox 7.x) :**

- Nécessite un support multicast sur les switchs
- Adresse multicast : 239.192.0.0/16
- Plus efficace pour de nombreux nœuds

**Unicast (recommandé et par défaut depuis Proxmox 8.x) :**

- Ne nécessite pas de support multicast
- Communication point à point
- Plus fiable sur les réseaux complexes

```bash
# Vérifier le mode dans /etc/pve/corosync.conf
cat /etc/pve/corosync.conf | grep transport

# Résultat attendu pour unicast :
transport: udpu
```

> [!info] Migration vers unicast Si vous avez un ancien cluster en multicast, il est recommandé de migrer vers unicast pour plus de fiabilité.

### 7. Synchronisation temporelle (NTP)

**Pourquoi c'est critique :**

- Corosync nécessite une synchronisation temporelle précise
- Écart > 1 seconde peut causer des problèmes de quorum
- Essentiel pour les certificats SSL et les logs

```bash
# Installer et configurer chrony
apt install chrony

# Vérifier la synchronisation
chronyc tracking

# Configuration /etc/chrony/chrony.conf
server 0.debian.pool.ntp.org iburst
server 1.debian.pool.ntp.org iburst
server 2.debian.pool.ntp.org iburst
```

> [!warning] Serveur NTP commun Configurez tous les nœuds pour utiliser les **mêmes serveurs NTP** afin d'éviter les dérives temporelles.

### Checklist pré-cluster

Avant de créer votre cluster, vérifiez :

- [ ] Réseau dédié configuré sur tous les nœuds
- [ ] Latence < 5ms testée entre tous les nœuds
- [ ] Résolution de noms fonctionnelle (ping par nom)
- [ ] Ports Corosync ouverts (5405-5412 UDP)
- [ ] NTP synchronisé sur tous les nœuds
- [ ] MTU identique sur toutes les interfaces cluster
- [ ] Pas de pare-feu bloquant entre nœuds cluster

---

## 🗳️ Quorum et Corosync

### Qu'est-ce que le Quorum ?

Le **quorum** est un mécanisme de vote qui détermine si un cluster a suffisamment de nœuds actifs pour prendre des décisions et effectuer des opérations.

> [!info] Définition Le quorum est atteint lorsque **plus de 50% des nœuds** du cluster sont en ligne et peuvent communiquer. C'est la majorité simple.

**Formule du quorum :**

```
Votes nécessaires = (nombre total de votes / 2) + 1
```

|Nombre de nœuds|Votes totaux|Quorum requis|Pannes tolérées|
|---|---|---|---|
|1|1|1|0|
|2|2|2|0 ⚠️|
|3|3|2|1 ✅|
|4|4|3|1|
|5|5|3|2 ✅|
|6|6|4|2|

> [!warning] Clusters à 2 nœuds Un cluster de 2 nœuds est problématique : si un nœud tombe, le cluster perd le quorum. Solution : ajouter un QDevice (voir plus bas).

### Pourquoi le quorum est-il crucial ?

**Protection contre le split-brain :** Le quorum évite qu'un cluster divisé en plusieurs partitions réseau continue à fonctionner de manière incohérente.

```
Scénario sans quorum :

    [Nœud1 + Nœud2]  ←┈┈ Coupure réseau ┈┈→  [Nœud3]
    
    Les deux partitions pourraient :
    - Démarrer les mêmes VMs
    - Modifier les mêmes configurations
    → Corruption des données garantie !

Avec quorum :

    [Nœud1 + Nœud2]  ←┈┈ Coupure réseau ┈┈→  [Nœud3]
         (2 votes)                              (1 vote)
      ✅ A le quorum                         ❌ Pas de quorum
      Continue à fonctionner                 Se met en pause
```

### États du quorum

```bash
# Vérifier l'état du quorum
pvecm status

# Sortie typique :
Cluster information
-------------------
Name:             mycluster
Config Version:   3
Transport:        knet
Secure auth:      on

Quorum information
------------------
Date:             Wed Dec 24 10:30:00 2025
Quorum provider:  corosync_votequorum
Nodes:            3
Node ID:          0x00000001
Ring ID:          1.2
Quorate:          Yes      # ← État du quorum

Votequorum information
----------------------
Expected votes:   3        # Nombre de votes attendus
Highest expected: 3
Total votes:      3        # Votes actuels
Quorum:           2        # Votes nécessaires pour le quorum
Flags:            Quorate
```

**Statuts possibles :**

- **Quorate: Yes** ✅ → Cluster opérationnel
- **Quorate: No** ❌ → Cluster en lecture seule, pas d'opérations critiques

> [!example] Opérations bloquées sans quorum
> 
> - Démarrage de VMs HA
> - Migrations
> - Modifications de configuration
> - Création/suppression de ressources

### Corosync : le moteur de communication

**Corosync** est le système qui gère la communication entre les nœuds et détermine le quorum.

**Rôles de Corosync :**

1. Communication en temps réel entre nœuds
2. Détection des pannes (heartbeat)
3. Gestion du quorum
4. Synchronisation des états
5. Fourniture d'une vue cohérente du cluster

### Configuration de Corosync

**Fichier `/etc/pve/corosync.conf` :**

```bash
totem {
  version: 2
  cluster_name: mycluster
  transport: knet                    # Protocole de transport (knet/udpu)
  crypto_cipher: aes256             # Chiffrement
  crypto_hash: sha256               # Hash
}

nodelist {
  node {
    name: node1
    nodeid: 1
    quorum_votes: 1                 # Poids du vote
    ring0_addr: 10.0.0.10           # IP réseau cluster
  }
  
  node {
    name: node2
    nodeid: 2
    quorum_votes: 1
    ring0_addr: 10.0.0.11
  }
  
  node {
    name: node3
    nodeid: 3
    quorum_votes: 1
    ring0_addr: 10.0.0.12
  }
}

quorum {
  provider: corosync_votequorum
  expected_votes: 3                  # Nombre total de votes
  two_node: 0                        # 0 = plus de 2 nœuds
}

logging {
  to_logfile: yes
  logfile: /var/log/corosync/corosync.log
  to_syslog: yes
  timestamp: on
}
```

> [!tip] Modification de la configuration Ne modifiez **jamais** `/etc/pve/corosync.conf` manuellement. Utilisez `pvecm` pour toute modification, puis rechargez avec :
> 
> ```bash
> systemctl reload corosync
> ```

### Redondance réseau (Knet)

Proxmox 6.2+ utilise **Knet** (Kronosnet) qui permet d'avoir plusieurs liens réseau pour Corosync.

**Configuration multi-liens :**

```bash
nodelist {
  node {
    name: node1
    nodeid: 1
    quorum_votes: 1
    ring0_addr: 10.0.0.10      # Lien primaire
    ring1_addr: 10.0.1.10      # Lien secondaire (backup)
  }
}
```

**Avantages :**

- Tolérance aux pannes réseau
- Basculement automatique sur le lien secondaire
- Agrégation de bande passante possible

> [!info] Test de basculement
> 
> ```bash
> # Simuler une panne du lien primaire
> ip link set eth1 down
> 
> # Corosync bascule automatiquement sur ring1
> corosync-cfgtool -s    # Vérifier le statut
> ```

### QDevice : le tiers de confiance

Pour les clusters avec un **nombre pair de nœuds**, utilisez un **QDevice** (Quorum Device).

**Qu'est-ce qu'un QDevice ?**

- Serveur externe léger qui participe au vote
- Donne un vote supplémentaire pour atteindre le quorum
- Ne stocke aucune donnée
- Évite le split-brain dans les clusters pairs

```
Cluster 2 nœuds + QDevice :

  [Nœud1]  [Nœud2]  [QDevice]
     1        1         1      = 3 votes totaux
  
  Quorum requis : 2 votes
  
  Si Nœud2 tombe : Nœud1 (1) + QDevice (1) = 2 ✅ Quorum OK
```

**Installation d'un QDevice :**

```bash
# Sur un serveur Debian séparé (pas un nœud Proxmox)
apt install corosync-qnetd

# Sur un nœud du cluster
pvecm qdevice setup <IP_QDEVICE>

# Vérifier
pvecm status
# Vous devriez voir "Qdevice" dans la sortie
```

> [!warning] Emplacement du QDevice Le QDevice doit être :
> 
> - Sur un serveur séparé (pas un nœud du cluster)
> - Sur un réseau/site différent si possible
> - Hautement disponible (ou accepter de perdre le quorum s'il tombe)

### Manipulation du quorum

**Voir les votes attendus :**

```bash
pvecm expected 3    # Définir manuellement les votes attendus
```

> [!warning] Commande d'urgence uniquement N'utilisez `pvecm expected` qu'en cas d'urgence, lorsque vous ne pouvez pas rétablir le quorum normalement. Cette commande force le cluster à considérer un nouveau nombre de votes.

**Scénario d'utilisation :**

```bash
# Cluster de 5 nœuds, 3 tombent en panne
# Le cluster a 2 votes sur 5 → pas de quorum

# Solution temporaire (sur un nœud survivant)
pvecm expected 2    # Forcer le quorum avec 2 votes

# Le cluster redevient opérationnel
# ⚠️ Attention au split-brain si les autres nœuds reviennent !
```

### Surveillance et diagnostic

**Commandes de diagnostic Corosync :**

```bash
# État général
corosync-cfgtool -s

# État détaillé des nœuds
corosync-cmapctl | grep members

# Logs Corosync
journalctl -u corosync -f

# Logs quorum
journalctl -u corosync | grep -i quorum

# Test de connectivité
corosync-quorumtool -l    # Liste des nœuds et leur état
```

**Indicateurs de problème :**

- Nœuds marqués comme "offline" dans `pvecm status`
- Messages "lost quorum" dans les logs
- Latence > 5ms dans `corosync-cmapctl`
- Paquets perdus visibles avec `fping`

> [!tip] Monitoring proactif Configurez des alertes sur :
> 
> - Perte de quorum
> - Latence réseau cluster > 3ms
> - Nœud marqué comme offline
> - Erreurs Corosync dans les logs

### Pièges courants

> [!warning] Erreurs fréquentes à éviter

**1. Cluster à 2 nœuds sans QDevice**

```
Problème : Perte de quorum si 1 nœud tombe
Solution : Ajouter un QDevice ou passer à 3 nœuds
```

**2. Réseau cluster sur le même réseau que la production**

```
Problème : Congestion réseau → latence → perte de quorum
Solution : Réseau dédié pour Corosync
```

**3. NTP non synchronisé**

```
Problème : Dérive temporelle → problèmes Corosync
Solution : Configurer chrony correctement
```

**4. Modification manuelle de corosync.conf**

```
Problème : Corruption de la configuration
Solution : Toujours utiliser pvecm
```

**5. Pare-feu bloquant les ports Corosync**

```
Problème : Nœuds ne peuvent pas communiquer
Solution : Ouvrir les ports 5405-5412 UDP
```

### Best practices pour le quorum

✅ **À faire :**

- Utiliser un nombre impair de nœuds (3, 5, 7...)
- Ajouter un QDevice pour les clusters pairs
- Dédier un réseau pour Corosync
- Tester régulièrement les scénarios de panne
- Monitorer la latence réseau cluster

❌ **À éviter :**

- Clusters de 2 nœuds sans QDevice
- Forcer le quorum (`expected`) sans comprendre les risques
- Ignorer les alertes de perte de quorum
- Réseau cluster sur le même VLAN que la production
- Mélanger des nœuds avec des latences très différentes

---

## 🎓 Points clés à retenir

> [!tip] Synthèse du clustering Proxmox

1. **Un cluster Proxmox** regroupe plusieurs serveurs en une infrastructure unifiée avec gestion centralisée et haute disponibilité
2. **Le quorum** protège contre le split-brain en exigeant une majorité de votes pour toute opération critique
3. **Corosync** gère la communication entre nœuds et la détection des pannes avec une latence < 5ms requise
4. **Le réseau dédié** pour le cluster est indispensable pour la stabilité et les performances
5. **Les clusters impairs** (3, 5, 7 nœuds) sont préférables, ou utilisez un QDevice pour les clusters pairs
6. **La haute disponibilité** redémarre automatiquement les VMs sur d'autres nœuds en cas de panne
7. **La live migration** permet de déplacer des VMs sans interruption si le stockage est partagé

---

_Ce document est un support de cours sur le clustering Proxmox VE. Pour une documentation officielle complète, consultez https://pve.proxmox.com/pve-docs/_