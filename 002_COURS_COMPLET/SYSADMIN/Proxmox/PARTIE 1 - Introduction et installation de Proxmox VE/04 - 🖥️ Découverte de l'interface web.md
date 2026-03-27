

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

## 🧭 Navigation dans l'interface

### Vue d'ensemble

L'interface web de Proxmox VE est accessible via un navigateur web à l'adresse `https://IP-DU-SERVEUR:8006`. Cette interface constitue le point central d'administration de votre infrastructure de virtualisation.

> [!info] Pourquoi une interface web ? L'interface web permet de gérer l'ensemble de votre infrastructure Proxmox sans installer de logiciel client. Elle est accessible depuis n'importe quel appareil disposant d'un navigateur moderne.

### Connexion à l'interface

```bash
# Format de l'URL d'accès
https://<adresse-ip>:8006

# Exemple
https://192.168.1.100:8006
```

> [!warning] Certificat SSL auto-signé Par défaut, Proxmox utilise un certificat SSL auto-signé. Votre navigateur affichera un avertissement de sécurité. C'est normal pour une première connexion. Vous devrez accepter l'exception de sécurité.

**Informations de connexion :**

- **Utilisateur par défaut** : `root`
- **Mot de passe** : celui défini lors de l'installation
- **Domaine d'authentification** : `Linux PAM standard authentication` (pour l'utilisateur root)

### Organisation de l'interface

L'interface Proxmox est divisée en plusieurs zones distinctes :

|Zone|Position|Fonction|
|---|---|---|
|**Barre supérieure**|En haut|Informations système, recherche, déconnexion|
|**Arborescence**|Gauche|Navigation dans les ressources (Datacenter, nœuds, VMs, conteneurs)|
|**Panneau central**|Centre|Affichage du contenu principal et des détails|
|**Barre d'onglets**|Centre-haut|Onglets contextuels selon l'élément sélectionné|
|**Console de tâches**|Bas|Journal des tâches en cours et terminées|

### Éléments de la barre supérieure

```
[Datacenter] [Search] [Documentation] [Create VM] [Create CT] [...] [User] [Logout]
```

- **Search** : Recherche rapide de ressources (VMs, conteneurs, stockage)
- **Documentation** : Lien vers la documentation officielle
- **Create VM** : Création rapide d'une machine virtuelle
- **Create CT** : Création rapide d'un conteneur LXC
- **User** : Informations sur l'utilisateur connecté
- **Logout** : Déconnexion

> [!tip] Raccourci de recherche Utilisez la barre de recherche (en haut) pour trouver rapidement une VM ou un conteneur par son nom ou ID. Très utile dans les grandes infrastructures.

### Navigation au clavier

Proxmox supporte plusieurs raccourcis clavier pour améliorer la productivité :

- **`/`** : Focus sur la barre de recherche
- **`Ctrl + Alt + N`** : Créer une nouvelle VM
- **`Esc`** : Fermer les fenêtres modales

---

## 🌳 Structure de l'arborescence

### Hiérarchie des ressources

L'arborescence à gauche représente la structure logique de votre infrastructure Proxmox. Elle suit une hiérarchie stricte :

```
Datacenter
├── pve (nœud Proxmox)
│   ├── local (stockage local)
│   ├── local-lvm (stockage LVM)
│   ├── 100 (qemu) - Nom de la VM
│   ├── 101 (qemu) - Autre VM
│   ├── 200 (lxc) - Conteneur LXC
│   └── ...
├── Stockage
│   ├── local
│   ├── local-lvm
│   └── ...
└── Pools (optionnel)
```

### Le Datacenter

Le **Datacenter** est le niveau le plus haut de la hiérarchie. Il représente l'ensemble du cluster Proxmox.

> [!info] Cluster vs Nœud unique Même avec un seul serveur Proxmox, vous avez un "Datacenter". Cette structure permet d'ajouter facilement d'autres nœuds par la suite pour former un cluster.

**Sous-sections du Datacenter :**

- **Summary** : Vue d'ensemble de tous les nœuds
- **Cluster** : Configuration du cluster (visible même avec un seul nœud)
- **Options** : Paramètres globaux du Datacenter
- **Storage** : Configuration centralisée du stockage
- **Backup** : Planification des sauvegardes
- **Replication** : Réplication des VMs entre nœuds (nécessite un cluster)
- **Permissions** : Gestion des utilisateurs, groupes et droits d'accès
- **HA** : High Availability (nécessite un cluster)
- **ACME** : Gestion des certificats SSL Let's Encrypt
- **Firewall** : Configuration du pare-feu au niveau Datacenter
- **Metric Server** : Configuration des serveurs de métriques externes

### Les nœuds (Nodes)

Un **nœud** représente un serveur physique exécutant Proxmox VE. Dans une installation standard, vous verrez un nœud nommé selon le hostname défini lors de l'installation (ex: `pve`).

**Sous-sections d'un nœud :**

|Onglet|Description|
|---|---|
|**Summary**|Vue d'ensemble : CPU, RAM, disques, état|
|**Shell**|Console shell directe sur le serveur|
|**System**|Configuration réseau, DNS, hôtes, temps|
|**Updates**|Mises à jour des paquets Proxmox|
|**Firewall**|Règles de pare-feu spécifiques au nœud|
|**Disks**|Gestion des disques physiques (LVM, ZFS, Directory)|
|**Ceph**|Configuration Ceph (si utilisé)|
|**Replication**|État de la réplication|
|**Task History**|Historique des tâches exécutées|
|**Subscription**|Informations sur l'abonnement Proxmox|

### Les machines virtuelles (VMs)

Les VMs apparaissent sous le nœud qui les héberge, identifiées par un **VMID** (numéro unique) et le type `(qemu)`.

**Exemple :** `100 (qemu) - Ubuntu-Server`

**Onglets d'une VM :**

- **Summary** : État, utilisation des ressources, statistiques
- **Console** : Accès console VNC/SPICE à la VM
- **Hardware** : Configuration matérielle (CPU, RAM, disques, réseau)
- **Options** : Options de démarrage, BIOS, ordre de boot
- **Task History** : Historique des opérations sur cette VM
- **Monitor** : Moniteur QEMU (avancé)
- **Backup** : Gestion des sauvegardes de cette VM
- **Replication** : Configuration de la réplication
- **Snapshots** : Gestion des instantanés
- **Firewall** : Règles de pare-feu spécifiques à la VM
- **Permissions** : Droits d'accès à cette VM

### Les conteneurs LXC

Les conteneurs apparaissent également sous le nœud, identifiés par un **CTID** et le type `(lxc)`.

**Exemple :** `200 (lxc) - Nginx-Proxy`

> [!info] Différence VM vs Conteneur Les machines virtuelles (qemu) virtualisent un système complet avec son propre noyau. Les conteneurs LXC (lxc) partagent le noyau de l'hôte, ce qui les rend plus légers mais moins isolés.

### Le stockage (Storage)

La section **Storage** du Datacenter liste tous les espaces de stockage disponibles :

**Types de stockage courants :**

- **Directory** : Répertoire local ou monté (NFS, CIFS)
- **LVM** : Logical Volume Manager
- **LVM-Thin** : LVM avec provisionnement dynamique
- **ZFS** : Système de fichiers ZFS
- **Ceph RBD** : Stockage distribué Ceph
- **NFS** : Network File System
- **iSCSI** : Stockage réseau iSCSI

**Contenu supporté par stockage :**

|Type de contenu|Description|
|---|---|
|**Disk image**|Disques des VMs|
|**Container**|Templates et disques de conteneurs|
|**ISO image**|Images ISO d'installation|
|**Container template**|Templates de conteneurs LXC|
|**VZDump backup**|Fichiers de sauvegarde|
|**Snippets**|Scripts et configurations|

> [!tip] Stockage local par défaut Une installation standard de Proxmox crée deux stockages : `local` (pour ISOs, templates, backups) et `local-lvm` (pour les disques des VMs).

---

## 📊 Dashboard et vue d'ensemble

### Le Summary du Datacenter

Lorsque vous sélectionnez **Datacenter** dans l'arborescence, l'onglet **Summary** affiche une vue globale de votre infrastructure.

**Informations affichées :**

```
┌─────────────────────────────────────────────┐
│ Cluster Information                         │
│ - Nodes: 1/1 online                         │
│ - Guests: 5 VMs, 3 Containers              │
│ - Resources: CPU, Memory, Storage          │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│ Node Statistics (graphique)                │
│ - Utilisation CPU par nœud                 │
│ - Utilisation mémoire par nœud             │
└─────────────────────────────────────────────┘
```

### Le Summary d'un nœud

En sélectionnant un nœud (ex: `pve`), l'onglet **Summary** affiche l'état détaillé du serveur physique.

**Métriques en temps réel :**

|Métrique|Description|
|---|---|
|**CPU usage**|Pourcentage d'utilisation CPU avec graphique|
|**Memory usage**|RAM utilisée/totale avec graphique|
|**Swap usage**|Utilisation du swap (devrait rester faible)|
|**Disk I/O**|Opérations lecture/écriture par seconde|
|**Network traffic**|Bande passante entrante/sortante|

**Informations système :**

- **PVE Manager Version** : Version de Proxmox installée
- **Kernel Version** : Version du noyau Linux
- **CPU Model** : Modèle du processeur
- **Uptime** : Temps depuis le dernier démarrage
- **Load Average** : Charge système (1, 5, 15 minutes)

> [!warning] Surveillance du swap Si l'utilisation du swap est élevée de manière constante, c'est un signe que votre serveur manque de RAM. Cela dégrade fortement les performances.

### Graphiques de performance

Proxmox affiche des graphiques en temps réel pour visualiser l'utilisation des ressources :

- **Graphiques sur 1 heure** : Rafraîchissement toutes les 60 secondes
- **Graphiques sur 1 jour** : Conservés dans la base RRD
- **Graphiques sur 1 semaine** : Aperçu des tendances
- **Graphiques sur 1 mois** : Planification de capacité

> [!tip] Analyse des tendances Utilisez les graphiques à long terme pour détecter des patterns d'utilisation et planifier l'allocation des ressources. Par exemple, un pic régulier chaque nuit peut indiquer des sauvegardes automatiques.

### Le Summary d'une VM

Lorsque vous sélectionnez une VM, l'onglet **Summary** affiche son état spécifique :

**État de la VM :**

- **Status** : Running, Stopped, Paused
- **Node** : Nœud hébergeant la VM
- **Uptime** : Durée de fonctionnement
- **Boot Disk** : Disque de démarrage

**Utilisation des ressources :**

- **CPU usage** : Pourcentage d'utilisation des vCPUs alloués
- **Memory usage** : RAM utilisée par la VM
- **Disk read/write** : Débit disque
- **Network traffic** : Débit réseau

**Configuration matérielle :**

- **Cores** : Nombre de cœurs CPU alloués
- **Memory** : RAM totale allouée
- **Disk size** : Taille du ou des disques
- **IP Address** : Adresse IP (si QEMU Guest Agent est installé)

> [!info] QEMU Guest Agent Pour obtenir l'adresse IP et d'autres informations détaillées, installez le `qemu-guest-agent` dans la VM. Cet agent permet aussi des arrêts propres et des snapshots cohérents.

### Notes et commentaires

Chaque ressource (nœud, VM, conteneur) peut avoir une **note** associée :

```markdown
# Exemple de note pour une VM
Serveur web de production
- Port: 80, 443
- Domaine: www.example.com
- Contact: admin@example.com
- Dernière mise à jour: 2025-01-15
```

> [!tip] Utilisation des notes Utilisez les notes pour documenter le rôle de chaque machine, les contacts responsables, les configurations particulières. C'est essentiel dans une infrastructure avec plusieurs administrateurs.

---

## 💻 Accès console (Shell)

### Le Shell du nœud

L'un des outils les plus puissants de l'interface Proxmox est l'accès **Shell** directement depuis le navigateur.

**Pour accéder au shell d'un nœud :**

1. Sélectionnez le nœud dans l'arborescence (ex: `pve`)
2. Cliquez sur l'onglet **Shell**
3. Une console web s'ouvre avec accès root au serveur

> [!info] Shell web vs SSH Le shell web utilise la même authentification que l'interface web. C'est pratique pour un accès rapide sans client SSH, mais SSH reste préférable pour des sessions longues ou des transferts de fichiers.

### Fonctionnalités du shell web

**Caractéristiques :**

- **Accès root direct** : Vous êtes automatiquement connecté en root
- **Émulation de terminal** : Support des couleurs, de nano, vim, etc.
- **Copier-coller** : Fonctionne avec le clic droit ou Ctrl+Insert / Shift+Insert
- **Taille du terminal** : Ajustable en tirant sur les bords de la fenêtre
- **Plusieurs onglets** : Possibilité d'ouvrir plusieurs shells simultanément

**Commandes utiles dans le shell :**

```bash
# Vérifier l'état du système
pveversion -v                # Version détaillée de Proxmox
pvesh get /nodes/pve/status  # État du nœud en JSON

# Gestion des VMs en ligne de commande
qm list                      # Liste toutes les VMs
qm start 100                 # Démarrer la VM 100
qm shutdown 100              # Arrêter proprement la VM 100
qm stop 100                  # Forcer l'arrêt de la VM 100

# Gestion des conteneurs
pct list                     # Liste tous les conteneurs
pct start 200                # Démarrer le conteneur 200
pct shutdown 200             # Arrêter le conteneur 200

# Monitoring en temps réel
htop                         # Moniteur de processus interactif
iotop                        # Moniteur d'E/S disque
iftop                        # Moniteur de bande passante réseau

# Gestion du stockage
pvesm status                 # État de tous les stockages
lvs                          # Liste des volumes logiques LVM
df -h                        # Espace disque disponible

# Logs système
journalctl -f                # Suivre les logs système en temps réel
tail -f /var/log/syslog      # Logs syslog
pvesr status                 # État de la réplication
```

> [!warning] Puissance et responsabilité Le shell vous donne un accès root complet au serveur. Les modifications effectuées ici peuvent affecter la stabilité de tout le système. Soyez prudent avec les commandes de suppression ou de modification de la configuration.

### Le shell vs la console des VMs

Il est important de distinguer le **shell du nœud** de la **console d'une VM** :

|Shell du nœud|Console VM|
|---|---|
|Accès à l'hôte Proxmox|Accès à la VM elle-même|
|Gestion système Proxmox|Gestion OS de la VM|
|Commandes `qm`, `pct`, `pvesm`|Commandes propres à l'OS de la VM|
|Nécessite auth Proxmox|Nécessite login de la VM|

**Pour accéder à la console d'une VM :**

1. Sélectionnez la VM dans l'arborescence
2. Cliquez sur l'onglet **Console**
3. Choisissez le type de console : noVNC (HTML5), SPICE, xterm.js

> [!tip] Console vs SSH vers la VM La console VM passe par l'hyperviseur et fonctionne même si le réseau de la VM est cassé. Utile pour le dépannage réseau ou les configurations initiales.

### Types de consoles pour VMs

Proxmox propose plusieurs technologies de console :

**noVNC (par défaut) :**

- Console HTML5 pure
- Fonctionne dans tous les navigateurs
- Pas d'installation nécessaire
- Performance correcte

**SPICE :**

- Meilleure performance graphique
- Support de l'USB passthrough
- Nécessite un client SPICE
- Idéal pour les VMs avec interface graphique

**xterm.js :**

- Terminal texte uniquement
- Très léger et rapide
- Parfait pour les serveurs sans GUI

> [!example] Choix de console selon l'usage
> 
> - **Serveur Linux sans GUI** : xterm.js ou noVNC
> - **Serveur Windows** : noVNC ou SPICE
> - **Poste de travail virtuel** : SPICE avec client

### Exécution de commandes directes

Proxmox permet d'exécuter des commandes sur des VMs sans ouvrir une console :

```bash
# Via l'API ou le shell du nœud
qm guest exec 100 -- command-to-run

# Exemple : Exécuter une commande dans la VM 100
qm guest exec 100 -- ls -la /home
```

> [!info] Prérequis Cette fonctionnalité nécessite que le QEMU Guest Agent soit installé et actif dans la VM.

### Limitations du shell web

**À savoir :**

- **Timeout de session** : La session expire après un certain temps d'inactivité
- **Pas de scrollback infini** : L'historique du terminal est limité
- **Performance réseau** : Latence si connexion internet lente
- **Copier-coller** : Peut nécessiter des raccourcis spécifiques selon le navigateur

**Raccourcis clavier du shell web :**

```bash
Ctrl + Insert      # Copier
Shift + Insert     # Coller
Ctrl + C           # Interrompre commande (comme dans un terminal classique)
Ctrl + D           # EOF / Fermer session
Ctrl + L           # Effacer l'écran
```

> [!tip] Pour les sessions longues Pour des tâches administratives complexes ou des transferts de fichiers, préférez une connexion SSH classique avec un client terminal complet (PuTTY, MobaXterm, Terminal, etc.).

### Le shell dans les conteneurs LXC

Pour les conteneurs LXC, le shell fonctionne différemment :

**Accès au shell d'un conteneur :**

1. Sélectionnez le conteneur dans l'arborescence
2. Cliquez sur **Console**
3. Vous êtes directement dans le conteneur (pas besoin de login)

```bash
# Depuis le shell du nœud, vous pouvez aussi :
pct enter 200     # Entrer dans le conteneur 200
pct exec 200 -- command    # Exécuter une commande dans le conteneur
```

> [!info] Accès root automatique Par défaut, le shell d'un conteneur LXC vous connecte en root. Les conteneurs non-privilégiés utilisent le mappage d'UID pour la sécurité.

---

## 🎯 Récapitulatif

L'interface web de Proxmox VE est votre outil central de gestion :

✅ **Navigation intuitive** via l'arborescence hiérarchique ✅ **Vue d'ensemble complète** avec le dashboard et les graphiques ✅ **Accès shell intégré** pour l'administration système ✅ **Gestion unifiée** des VMs, conteneurs et du stockage ✅ **Monitoring en temps réel** des ressources

> [!tip] Bonnes pratiques
> 
> - Gardez plusieurs onglets ouverts pour naviguer rapidement entre différentes ressources
> - Utilisez la fonction de recherche pour les grandes infrastructures
> - Documentez vos VMs avec les notes pour faciliter la maintenance
> - Surveillez régulièrement les graphiques de performance
> - Privilégiez SSH pour les longues sessions d'administration

---

_L'interface web Proxmox combine puissance et simplicité pour gérer efficacement votre infrastructure de virtualisation._