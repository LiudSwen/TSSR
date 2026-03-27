

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

## 🎯 Présentation de Proxmox VE

### Qu'est-ce que Proxmox VE ?

**Proxmox Virtual Environment (Proxmox VE)** est une plateforme de virtualisation open source complète qui permet de gérer des machines virtuelles (VM) et des conteneurs sur une seule interface. C'est une solution de virtualisation d'entreprise basée sur Debian Linux.

> [!info] Définition Proxmox VE combine deux technologies de virtualisation majeures :
> 
> - **KVM** (Kernel-based Virtual Machine) pour la virtualisation complète
> - **LXC** (Linux Containers) pour la conteneurisation légère

### Composants principaux

Proxmox VE repose sur plusieurs technologies clés :

|Composant|Rôle|Technologie|
|---|---|---|
|**Hyperviseur**|Gestion des VM|KVM (intégré au noyau Linux)|
|**Conteneurs**|Virtualisation légère|LXC|
|**Stockage**|Gestion des données|ZFS, LVM, Ceph, NFS, iSCSI|
|**Interface Web**|Administration|Interface web responsive|
|**Cluster**|Haute disponibilité|Corosync + pmxcfs|
|**API REST**|Automatisation|API complète pour scripts|

> [!tip] Licence Proxmox VE est distribué sous licence **AGPLv3** (gratuit et open source). Une souscription optionnelle payante donne accès aux dépôts de production stables et au support professionnel.

### Différence entre VM et Conteneur

Il est essentiel de comprendre la distinction entre ces deux approches :

**Machine Virtuelle (VM - KVM)** :

- Virtualisation complète avec son propre noyau
- Émulation matérielle complète
- Isolation totale
- Peut exécuter n'importe quel OS (Windows, Linux, BSD...)
- Plus gourmande en ressources
- Démarrage plus lent

**Conteneur (CT - LXC)** :

- Partage le noyau de l'hôte
- Virtualisation au niveau du système d'exploitation
- Plus léger et rapide
- Uniquement pour Linux
- Consommation minimale de ressources
- Démarrage quasi instantané

> [!example] Analogie
> 
> - Une **VM** est comme un appartement complet avec sa propre plomberie, électricité, et structure
> - Un **conteneur** est comme une chambre dans une maison partagée : plus économique mais moins isolé

---

## ⚙️ Hyperviseur Type 1 vs Type 2

### Classification des hyperviseurs

Les hyperviseurs se divisent en deux catégories principales selon leur architecture :

### Hyperviseur Type 1 (Bare Metal)

L'hyperviseur s'exécute **directement sur le matériel physique**, sans système d'exploitation intermédiaire.

```
┌─────────────────────────────────────┐
│  VM 1    │   VM 2    │   VM 3       │ ← Machines virtuelles
├──────────┴───────────┴──────────────┤
│     HYPERVISEUR TYPE 1 (Proxmox)    │ ← Couche de virtualisation
├─────────────────────────────────────┤
│       MATÉRIEL PHYSIQUE             │ ← Serveur bare metal
└─────────────────────────────────────┘
```

**Caractéristiques** :

- Accès direct au matériel
- Performances optimales
- Latence minimale
- Pas de surcharge liée à un OS hôte
- Gestion dédiée à la virtualisation

**Exemples** :

- **Proxmox VE** ✅
- VMware ESXi
- Microsoft Hyper-V (standalone)
- Citrix XenServer
- KVM (quand utilisé comme hyperviseur principal)

### Hyperviseur Type 2 (Hosted)

L'hyperviseur s'exécute **comme une application** sur un système d'exploitation existant.

```
┌─────────────────────────────────────┐
│  VM 1    │   VM 2    │   VM 3       │ ← Machines virtuelles
├──────────┴───────────┴──────────────┤
│     HYPERVISEUR TYPE 2              │ ← Application de virtualisation
├─────────────────────────────────────┤
│     SYSTÈME D'EXPLOITATION HÔTE     │ ← Windows, macOS, Linux
├─────────────────────────────────────┤
│       MATÉRIEL PHYSIQUE             │ ← PC ou serveur
└─────────────────────────────────────┘
```

**Caractéristiques** :

- Installation comme un logiciel classique
- Dépendant de l'OS hôte
- Performances réduites (double couche)
- Plus simple pour le développement/test
- Adapté aux postes de travail

**Exemples** :

- VirtualBox
- VMware Workstation/Fusion
- Parallels Desktop
- QEMU (standalone)

### Comparaison détaillée

|Critère|Type 1 (Proxmox)|Type 2 (VirtualBox)|
|---|---|---|
|**Performance**|⭐⭐⭐⭐⭐ Excellente|⭐⭐⭐ Bonne|
|**Latence**|Très faible|Modérée|
|**Overhead**|Minimal (~2-5%)|Important (~10-20%)|
|**Complexité**|Moyenne/Élevée|Faible|
|**Cas d'usage**|Production, datacenter|Développement, test|
|**Coût matériel**|Serveur dédié requis|PC standard suffisant|
|**Isolation**|Maximale|Bonne|
|**Accès matériel**|Direct (PCI passthrough)|Limité|

> [!warning] Attention à la terminologie KVM peut être considéré comme Type 1 ou Type 2 selon son utilisation :
> 
> - **Type 1** quand Linux est installé minimal uniquement pour la virtualisation (cas de Proxmox)
> - **Type 2** quand KVM est ajouté à un Linux desktop existant

### Pourquoi Proxmox est Type 1 ?

Proxmox VE est basé sur **Debian Linux**, mais il est considéré comme un hyperviseur Type 1 pour ces raisons :

1. **Linux minimal optimisé** : Le système est épuré pour la virtualisation
2. **KVM intégré au noyau** : Accès direct aux instructions de virtualisation matérielle (Intel VT-x / AMD-V)
3. **Dédié à la virtualisation** : L'OS sert uniquement de base pour l'hyperviseur
4. **Pas d'interface graphique** : Tout est géré via interface web ou CLI
5. **Performances bare metal** : Overhead minimal proche du matériel direct

> [!info] Architecture hybride Techniquement, Proxmox utilise une **architecture hybride** :
> 
> - Base Linux minimale (Type 1 optimisé)
> - KVM pour les VM (intégré au noyau)
> - LXC pour les conteneurs (niveau OS)
> 
> Mais en pratique, il se comporte et performe comme un hyperviseur Type 1 pur.

---

## 💡 Cas d'usage et avantages

### Cas d'usage typiques

#### 1. 🏢 Infrastructure d'entreprise

**Scénario** : PME souhaitant consolider ses serveurs physiques

- Hébergement de multiples serveurs sur une machine
- Réduction des coûts matériels et énergétiques
- Serveurs Windows (Active Directory, Exchange)
- Serveurs Linux (web, base de données, fichiers)
- Snapshots pour sauvegardes rapides

> [!example] Exemple concret Une entreprise avec 5 serveurs physiques (consommation 2000W, coût 10 000€) migre vers 1 serveur Proxmox (consommation 400W, coût 3 000€). Économie : 7 000€ + 80% d'électricité.

#### 2. 🔬 Environnement de développement et test

**Scénario** : Équipe de développeurs nécessitant des environnements isolés

- Création rapide d'environnements de test
- Clonage de VM pour tests parallèles
- Rollback instantané après tests destructifs
- Isolation réseau pour simulations
- Templates réutilisables

#### 3. 🎓 Lab d'apprentissage et formation

**Scénario** : Formation IT ou apprentissage personnel

- Création de topologies réseau complexes
- Tests de technologies sans risque
- Simulations d'attaques (pentesting)
- Apprentissage de l'administration système
- Certifications IT (CCNA, MCSA, Linux)

#### 4. 🏠 Homelab et auto-hébergement

**Scénario** : Passionné créant son infrastructure personnelle

- Serveur multimédia (Plex/Jellyfin)
- NAS et stockage centralisé
- Serveur domotique (Home Assistant)
- VPN personnel
- Services cloud privés (Nextcloud)

#### 5. ☁️ Cloud privé et IaaS

**Scénario** : Entreprise créant son cloud interne

- Alternative à AWS/Azure
- Maîtrise totale des données
- Conformité RGPD garantie
- API pour provisioning automatique
- Cluster haute disponibilité

#### 6. 🛡️ Sécurité et segmentation

**Scénario** : Isolation des services critiques

- DMZ virtualisée
- Segmentation réseau par VLAN
- Firewall virtuel (pfSense, OPNsense)
- Honeypots et analyse de malware
- Environnements sandbox

### Avantages de Proxmox VE

#### Avantages techniques

|Avantage|Description|Impact|
|---|---|---|
|**🆓 Open Source**|Code source ouvert (AGPLv3)|Pas de coûts de licence, transparence|
|**🔄 Flexibilité**|VM (KVM) + Conteneurs (LXC)|Choix adapté à chaque besoin|
|**🌐 Interface web moderne**|GUI responsive et intuitive|Administration depuis n'importe où|
|**📊 Haute disponibilité (HA)**|Clustering intégré|Redondance et continuité de service|
|**💾 Gestion du stockage avancée**|ZFS, Ceph, LVM, NFS...|Solutions adaptées de PME à datacenter|
|**🔌 API REST complète**|Automatisation totale|Intégration CI/CD et Infrastructure as Code|
|**📸 Snapshots et backup**|Sauvegardes incrémentales|Protection des données sans interruption|
|**🔧 Live Migration**|Migration à chaud de VM|Maintenance sans downtime|

#### Avantages économiques

**Réduction des coûts** :

- ✅ Pas de licence VMware (économie de 5 000€+ par socket)
- ✅ Consolidation matérielle (1 serveur physique = 10-20 VM)
- ✅ Réduction électricité et climatisation (~70%)
- ✅ Support communautaire gratuit
- ✅ Souscription optionnelle (à partir de 90€/an)

> [!tip] Calcul ROI Pour un serveur hébergeant 10 VM :
> 
> - **Avant** : 10 serveurs × 300W = 3000W × 24h × 365j × 0,20€/kWh = 5 256€/an
> - **Après** : 1 serveur × 400W = 400W × 24h × 365j × 0,20€/kWh = 701€/an
> - **Économie annuelle** : 4 555€ d'électricité + espace physique + maintenance

#### Avantages opérationnels

**Gestion simplifiée** :

- Interface centralisée pour tout gérer
- Provisioning de VM en quelques clics
- Templates pour déploiements standards
- Monitoring intégré des ressources
- Logs centralisés et alertes

**Agilité et rapidité** :

- Déploiement d'un serveur en 5 minutes (vs plusieurs heures)
- Clonage instantané de VM
- Tests et rollback sans risque
- Scaling horizontal facile

> [!warning] Limitations à connaître
> 
> - **Courbe d'apprentissage** : Plus technique que des solutions grand public
> - **Matériel requis** : Nécessite support virtualisation (VT-x/AMD-V)
> - **Documentation** : Principalement en anglais
> - **GUI limitée** : Certaines actions nécessitent la ligne de commande
> - **Support officiel** : Payant (mais communauté très active)

### Comparaison avec les alternatives

|Solution|Coût|Complexité|Performance|Cas d'usage|
|---|---|---|---|---|
|**Proxmox VE**|Gratuit|Moyenne|⭐⭐⭐⭐⭐|PME, Homelab, Production|
|**VMware ESXi**|Payant|Moyenne|⭐⭐⭐⭐⭐|Entreprise, Datacenter|
|**Hyper-V**|Inclus Windows|Faible|⭐⭐⭐⭐|Environnement Microsoft|
|**XCP-ng**|Gratuit|Élevée|⭐⭐⭐⭐|Alternative Citrix|
|**VirtualBox**|Gratuit|Faible|⭐⭐⭐|Desktop, Dev|

---

## 🏗️ Architecture de Proxmox

### Vue d'ensemble de l'architecture

Proxmox VE est construit sur une architecture en couches qui combine plusieurs technologies open source pour créer une plateforme de virtualisation complète.

```
┌─────────────────────────────────────────────────────────────┐
│                    INTERFACE WEB (Port 8006)                │
│              Management API REST + Websocket                │
├─────────────────────────────────────────────────────────────┤
│  Couche de gestion Proxmox VE                              │
│  ├─ pve-cluster (Clustering)                               │
│  ├─ pve-ha-manager (Haute disponibilité)                   │
│  ├─ pve-firewall (Firewall)                                │
│  └─ pvescheduler (Planification)                            │
├─────────────────────────────────────────────────────────────┤
│  Virtualisation                  │   Conteneurs             │
│  ├─ QEMU/KVM (VM)               │   ├─ LXC (Conteneurs)   │
│  ├─ libvirt                      │   └─ cgroup/namespaces   │
│  └─ VirtIO drivers               │                          │
├─────────────────────────────────────────────────────────────┤
│  Stockage                                                   │
│  ├─ ZFS (pool local)                                        │
│  ├─ LVM / LVM-thin                                          │
│  ├─ Ceph (stockage distribué)                              │
│  ├─ NFS / SMB / iSCSI (stockage réseau)                    │
│  └─ Directories                                             │
├─────────────────────────────────────────────────────────────┤
│  Réseau                                                     │
│  ├─ Linux Bridge (réseau virtuel)                          │
│  ├─ Open vSwitch (OVS)                                      │
│  ├─ VLAN (802.1Q)                                           │
│  └─ SDN (Software Defined Networking)                       │
├─────────────────────────────────────────────────────────────┤
│             Debian Linux (Système de base)                  │
│  ├─ Noyau Linux avec KVM                                    │
│  ├─ systemd (gestion des services)                          │
│  └─ Corosync + pmxcfs (cluster filesystem)                 │
├─────────────────────────────────────────────────────────────┤
│                  MATÉRIEL PHYSIQUE                          │
│  CPU (VT-x/AMD-V) │ RAM │ Disques │ Réseau                 │
└─────────────────────────────────────────────────────────────┘
```

### Composants système fondamentaux

#### 1. Système de base : Debian Linux

Proxmox VE utilise **Debian Linux** comme fondation :

- **Version** : Basé sur Debian Bookworm (12) pour Proxmox 8.x
- **Noyau** : Kernel Linux personnalisé avec KVM intégré
- **Rôle** : Fournit la base système minimale et les outils standards Linux

> [!info] Pourquoi Debian ?
> 
> - Stabilité reconnue en production
> - Cycle de vie long (LTS)
> - Large communauté et documentation
> - Compatibilité matérielle étendue
> - Outils système éprouvés

#### 2. Hyperviseur : KVM (Kernel-based Virtual Machine)

**KVM** est le cœur de la virtualisation des machines virtuelles :

- Intégré directement dans le noyau Linux
- Transforme Linux en hyperviseur Type 1
- Utilise les extensions matérielles (Intel VT-x / AMD-V)
- Gère l'isolation et l'allocation des ressources CPU/RAM

**QEMU** (Quick Emulator) :

- Travaille avec KVM pour émuler le matériel
- Fournit les périphériques virtuels (disque, réseau, USB...)
- Gère les entrées/sorties des VM

> [!tip] VirtIO **VirtIO** est un framework de drivers paravirtualisés qui améliore drastiquement les performances :
> 
> - Disques : virtio-blk (jusqu'à 3x plus rapide que IDE)
> - Réseau : virtio-net (latence réduite)
> - Nécessite drivers dans le système invité (inclus dans Linux, disponible pour Windows)

#### 3. Conteneurs : LXC (Linux Containers)

**LXC** fournit la conteneurisation légère :

- Partage le noyau de l'hôte Proxmox
- Utilise les **namespaces** Linux (isolation)
- Utilise les **cgroups** (limitation de ressources)
- Beaucoup plus léger qu'une VM complète

**Différence avec Docker** :

- LXC : conteneur système (init, plusieurs processus)
- Docker : conteneur applicatif (un processus principal)
- LXC sur Proxmox peut héberger Docker !

### Composants de gestion

#### 1. pve-cluster : Gestion du cluster

Permet la création de clusters Proxmox :

```
Nœud 1 (pve1)  ←─┐
                  ├─ Corosync (communication)
Nœud 2 (pve2)  ←─┤
                  ├─ pmxcfs (configuration synchronisée)
Nœud 3 (pve3)  ←─┘
```

**Fonctionnalités** :

- Synchronisation de configuration entre nœuds
- Quorum pour décisions distribuées
- Migration live de VM entre nœuds
- Gestion centralisée depuis n'importe quel nœud

> [!warning] Nombre de nœuds Un cluster nécessite **minimum 3 nœuds** pour éviter le split-brain. Avec 2 nœuds, un QDevice externe est recommandé.

#### 2. pve-ha-manager : Haute disponibilité

Gère la redondance et le failover automatique :

- Surveille l'état de santé des nœuds
- Redémarre automatiquement les VM sur un autre nœud si panne
- Configuration de priorités de nœuds
- Fencing pour éviter les corruptions

#### 3. pve-firewall : Pare-feu intégré

Firewall centralisé au niveau :

- **Datacenter** : règles globales
- **Nœud** : règles par serveur physique
- **VM/CT** : règles par machine virtuelle

Basé sur **iptables** avec interface web simplifiée.

#### 4. Interface Web et API

**Interface Web** :

- Port **8006** (HTTPS)
- Interface responsive (fonctionne sur mobile)
- Console VNC/SPICE intégrée
- Gestion complète sans ligne de commande

**API REST** :

- Endpoint : `https://proxmox-server:8006/api2/json`
- Authentification par ticket ou token API
- Documentation complète : `/pve-docs/api-viewer/`
- Permet automatisation avec Ansible, Terraform, scripts Python...

### Stockage dans Proxmox

Proxmox supporte de multiples backends de stockage :

#### Types de stockage

|Type|Description|Usage|Performance|
|---|---|---|---|
|**Directory**|Dossier standard Linux|Simple, ISO, backups|⭐⭐⭐|
|**LVM**|Logical Volume Manager|Disques VM|⭐⭐⭐⭐|
|**LVM-Thin**|LVM avec provisioning léger|Disques VM + snapshots|⭐⭐⭐⭐|
|**ZFS**|Filesystem avancé|Pool local, snapshots|⭐⭐⭐⭐⭐|
|**Ceph**|Stockage distribué|Cluster, HA|⭐⭐⭐⭐|
|**NFS**|Network File System|Stockage partagé|⭐⭐⭐|
|**iSCSI**|Disques réseau|SAN|⭐⭐⭐⭐|
|**GlusterFS**|Filesystem distribué|Stockage partagé|⭐⭐⭐|

> [!example] Configuration typique
> 
> - **OS des VM** : LVM-Thin ou ZFS (snapshots rapides)
> - **ISO et templates** : Directory sur un volume dédié
> - **Backups** : NFS vers NAS ou Directory vers disque externe
> - **Cluster** : Ceph pour stockage partagé entre nœuds

#### Emplacement des données

Chemins importants sur le système de fichiers :

```bash
/etc/pve/              # Configuration du cluster (synchronisé)
  ├─ nodes/            # Configuration des nœuds
  ├─ qemu-server/      # Configuration des VM (*.conf)
  ├─ lxc/              # Configuration des CT (*.conf)
  ├─ storage.cfg       # Configuration du stockage
  ├─ datacenter.cfg    # Configuration globale
  └─ firewall/         # Règles firewall

/var/lib/vz/           # Données de virtualisation
  ├─ images/           # Disques des VM et CT
  ├─ template/         # Templates et ISO
  └─ dump/             # Backups

/var/lib/pve/          # Données Proxmox
  └─ local-lvm/        # Volumes LVM
```

> [!warning] Ne jamais modifier /etc/pve/ manuellement ! Le répertoire `/etc/pve/` est un système de fichiers spécial (**pmxcfs**) synchronisé entre nœuds. Utilisez toujours les commandes Proxmox pour modifier la configuration.

### Réseau dans Proxmox

#### Architecture réseau de base

```
┌────────────────────────────────────────────────────┐
│                    Internet                        │
└────────────────────┬───────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────┐
│  Routeur / Box Internet                         │
│  (passerelle : 192.168.1.1)                     │
└────────────────────┬────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────┐
│  Switch physique                                │
└────┬─────────┬─────────┬──────────┬────────────┘
     │         │         │          │
     │         │         │          │
┌────▼─────────▼─────────▼──────────▼────────────┐
│  Serveur Proxmox (IP: 192.168.1.100)           │
│  Interface physique : eno1                      │
│                                                 │
│  ┌───────────────────────────────────────────┐ │
│  │   Linux Bridge : vmbr0                    │ │
│  │   (192.168.1.100/24)                      │ │
│  └──┬──────┬──────┬──────┬──────┬───────────┘ │
│     │      │      │      │      │              │
│  ┌──▼──┐┌──▼──┐┌──▼──┐┌──▼──┐┌──▼──┐         │
│  │ VM1 ││ VM2 ││ VM3 ││ CT1 ││ CT2 │         │
│  │.101 ││.102 ││.103 ││.104 ││.105 │         │
│  └─────┘└─────┘└─────┘└─────┘└─────┘         │
└─────────────────────────────────────────────────┘
```

#### Composants réseau

**Linux Bridge (vmbr)** :

- Switch virtuel logiciel intégré au noyau Linux
- Connecte les interfaces virtuelles des VM/CT
- Peut être branché sur interface physique (bridging) ou isolé
- Configuration dans `/etc/network/interfaces`

**VLAN (802.1Q)** :

- Segmentation réseau au niveau Layer 2
- Tag VLAN sur les paquets
- Un bridge par VLAN (vmbr0.10, vmbr0.20...)
- Nécessite switch physique compatible VLAN

**Open vSwitch (OVS)** :

- Alternative plus avancée au Linux Bridge
- Support VXLAN, GRE, QoS avancé
- Plus complexe mais plus flexible
- Utilisé dans les datacenters

> [!tip] Configuration réseau par défaut À l'installation, Proxmox crée automatiquement :
> 
> - **vmbr0** : bridge connecté à l'interface physique principale
> - IP du serveur assignée au bridge (pas à l'interface physique)
> - Les VM/CT utilisent vmbr0 pour accéder au réseau externe

### Flux de communication

#### Création et démarrage d'une VM

1. **Requête Web** : Admin clique sur "Create VM" dans l'interface
2. **API REST** : Requête POST envoyée au serveur Proxmox
3. **pvedaemon** : Daemon reçoit la requête et valide les paramètres
4. **qm create** : Commande CLI génère le fichier de configuration `/etc/pve/qemu-server/XXX.conf`
5. **pmxcfs** : Synchronise automatiquement la config sur tous les nœuds du cluster
6. **Stockage** : Crée le disque virtuel (qcow2, raw, LVM...)
7. **qm start** : Lance le processus QEMU/KVM
8. **KVM** : Initialise la VM avec les ressources allouées (CPU, RAM)
9. **QEMU** : Émule les périphériques matériels virtuels
10. **vmbr0** : Connecte l'interface réseau virtuelle au bridge

### Surveillance et monitoring

Proxmox intègre plusieurs outils de monitoring :

**Métriques en temps réel** :

- Graphiques CPU, RAM, disque, réseau
- Par nœud et par VM/CT
- Historique conservé en RRD (Round Robin Database)

**Logs système** :

- Journal de tous les événements
- Accessible via interface web (Tasks)
- Stocké dans `/var/log/pve/`

**Alertes** :

- Notifications par email
- Événements : panne nœud, espace disque faible, backup échoué
- Configuration dans Datacenter > Notifications

> [!info] Intégrations externes Proxmox peut être monitoré par :
> 
> - **Prometheus** : métriques détaillées via pve-exporter
> - **Grafana** : dashboards personnalisés
> - **Zabbix** : supervision d'infrastructure
> - **Nagios/Icinga** : alerting avancé

---

## 🎓 Récapitulatif

Vous avez maintenant une compréhension solide de Proxmox VE :

✅ **Proxmox VE** est une plateforme open source combinant virtualisation (KVM) et conteneurisation (LXC)

✅ En tant qu'**hyperviseur Type 1**, Proxmox s'exécute directement sur le matériel pour des performances optimales

✅ Les **cas d'usage** sont variés : entreprise, développement, homelab, cloud privé, avec des avantages économiques et techniques majeurs

✅ L'**architecture** repose sur Debian, KVM/QEMU, LXC, avec des couches de gestion (cluster, HA, firewall) et des systèmes de stockage/réseau flexibles

Cette base théorique vous prépare pour la suite : l'installation et la configuration pratique de Proxmox VE.