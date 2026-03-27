

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

## 🎯 Téléchargement de templates

### Qu'est-ce qu'un template LXC ?

Un template LXC est une image système préconfigurée qui sert de base pour créer des conteneurs. Contrairement aux images Docker, les templates LXC contiennent un système d'exploitation complet (mais léger) avec son propre noyau virtualisé.

> [!info] Pourquoi utiliser des templates ?
> 
> - Démarrage rapide : pas besoin d'installer l'OS manuellement
> - Standardisation : tous les conteneurs partent de la même base
> - Gain de temps : téléchargement une seule fois, utilisation multiple
> - Optimisés pour la conteneurisation

### Accéder aux templates disponibles

**Via l'interface web :**

1. Sélectionnez votre nœud Proxmox dans l'arborescence
2. Cliquez sur le stockage local (généralement `local` ou `local-lvm`)
3. Onglet **"CT Templates"** (Container Templates)
4. Cliquez sur le bouton **"Templates"** en haut

```bash
# Via CLI : lister les templates disponibles
pveam available

# Exemple de sortie :
# system          ubuntu-22.04-standard_22.04-1_amd64.tar.zst
# system          debian-12-standard_12.2-1_amd64.tar.zst
# system          alpine-3.18-default_20230607_amd64.tar.xz
```

### Télécharger un template

**Interface graphique :**

- Recherchez le template souhaité dans la liste
- Double-cliquez ou cliquez sur "Download"
- Le téléchargement démarre automatiquement

**Ligne de commande :**

```bash
# Télécharger un template spécifique
pveam download local debian-12-standard_12.2-1_amd64.tar.zst

# Télécharger avec stockage personnalisé
pveam download <storage-name> <template-name>

# Exemple avec Alpine Linux
pveam download local alpine-3.18-default_20230607_amd64.tar.xz
```

> [!tip] Templates populaires
> 
> |Distribution|Cas d'usage|Taille|
> |---|---|---|
> |**Alpine**|Services légers, conteneurs minimaux|~5 MB|
> |**Debian**|Polyvalent, stable, production|~110 MB|
> |**Ubuntu**|Compatibilité logicielle étendue|~130 MB|
> |**CentOS/Rocky**|Environnements enterprise|~150 MB|

### Vérifier les templates téléchargés

```bash
# Lister les templates locaux
pveam list local

# Supprimer un template obsolète
pveam remove local <template-name>
```

> [!warning] Espace disque Pensez à vérifier l'espace disponible sur votre stockage avant de télécharger plusieurs templates. Utilisez `pvesm status` pour voir l'utilisation.

---

## 🚀 Assistant de création

### Lancer l'assistant

L'assistant de création de conteneur LXC vous guide étape par étape dans la configuration.

**Interface web :**

1. Clic droit sur votre nœud → **"Create CT"** (Create Container)
2. Ou bouton **"Create CT"** en haut à droite

**Ligne de commande :**

```bash
# Création basique via CLI
pct create <CTID> <template> --hostname <nom> --password <motdepasse>

# Exemple complet
pct create 100 local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst \
  --hostname debian-web \
  --password monMotDePasse123 \
  --memory 1024 \
  --rootfs local-lvm:8 \
  --net0 name=eth0,bridge=vmbr0,ip=dhcp
```

### Étapes de l'assistant (interface web)

#### **Étape 1 : Général**

|Champ|Description|Recommandation|
|---|---|---|
|**Node**|Nœud Proxmox cible|Choisir selon la charge|
|**CT ID**|Identifiant unique (100-999999999)|Utiliser une convention (ex: 100-199 pour web)|
|**Hostname**|Nom du conteneur|Descriptif et sans espaces|
|**Unprivileged**|Type de conteneur|✅ Cocher (sécurité)|
|**Password**|Mot de passe root|Fort et unique|
|**SSH Key**|Clé publique SSH|Recommandé pour l'automatisation|

```bash
# Convention de numérotation suggérée
# 100-199 : Serveurs web
# 200-299 : Bases de données
# 300-399 : Services réseau
# 400-499 : Développement/test
```

> [!tip] Bonnes pratiques pour le hostname
> 
> - Utilisez des noms descriptifs : `web-prod-01`, `db-mysql-01`
> - Évitez les caractères spéciaux
> - Pensez au DNS : le hostname sera résolu sur le réseau

#### **Étape 2 : Template**

- Sélectionnez le template préalablement téléchargé
- La liste affiche uniquement les templates disponibles localement

> [!example] Choisir le bon template
> 
> - **Alpine** : reverse proxy léger (Nginx, Traefik)
> - **Debian** : serveur web standard (Apache, PHP)
> - **Ubuntu** : applications nécessitant des PPAs récents
> - **Rocky Linux** : environnements corporate/enterprise

#### **Étape 3 : Disks** (voir section Configuration stockage)

#### **Étape 4 : CPU** (voir section Paramètres CPU et mémoire)

#### **Étape 5 : Memory** (voir section Paramètres CPU et mémoire)

#### **Étape 6 : Network** (voir section Configuration réseau)

#### **Étape 7 : DNS**

```bash
# Configuration DNS typique
DNS domain: localdomain
DNS servers: 8.8.8.8, 1.1.1.1

# Pour un environnement d'entreprise
DNS domain: entreprise.local
DNS servers: 192.168.1.1, 192.168.1.2
```

> [!info] Héritage des paramètres Par défaut, les conteneurs héritent de la configuration DNS du nœud hôte Proxmox. Vous pouvez la personnaliser si nécessaire.

#### **Étape 8 : Confirm**

- Vérifiez tous les paramètres
- Option **"Start after created"** : démarrage automatique
- Cliquez sur **"Finish"**

### Création rapide avec profils

```bash
# Profil serveur web léger
pct create 101 local:vztmpl/alpine-3.18-default_20230607_amd64.tar.xz \
  --hostname nginx-web \
  --password SecurePass123! \
  --cores 1 \
  --memory 512 \
  --rootfs local-lvm:4 \
  --net0 name=eth0,bridge=vmbr0,ip=192.168.1.101/24,gw=192.168.1.1 \
  --onboot 1 \
  --unprivileged 1

# Profil base de données
pct create 201 local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst \
  --hostname mysql-db \
  --password SecurePass123! \
  --cores 2 \
  --memory 2048 \
  --rootfs local-lvm:20 \
  --net0 name=eth0,bridge=vmbr0,ip=192.168.1.201/24,gw=192.168.1.1 \
  --onboot 1 \
  --unprivileged 1
```

---

## 🔒 Configuration unprivileged vs privileged

### Comprendre la différence

La distinction entre conteneurs privileged et unprivileged est **cruciale pour la sécurité** de votre infrastructure.

#### **Conteneur Privileged (privilégié)**

```bash
# UID/GID mapping (identique à l'hôte)
Conteneur : root (UID 0) → Hôte : root (UID 0)
Conteneur : www-data (UID 33) → Hôte : www-data (UID 33)
```

- L'utilisateur root dans le conteneur = root sur l'hôte
- Accès direct aux périphériques matériels
- Peut modifier les paramètres du noyau
- **Risque majeur** : échappement du conteneur = compromission totale

#### **Conteneur Unprivileged (non privilégié)**

```bash
# UID/GID mapping (décalé)
Conteneur : root (UID 0) → Hôte : utilisateur non-privilégié (UID 100000)
Conteneur : www-data (UID 33) → Hôte : utilisateur non-privilégié (UID 100033)
```

- L'utilisateur root dans le conteneur = utilisateur normal sur l'hôte
- Isolation renforcée via user namespaces
- Restrictions d'accès aux ressources système
- **Sécurité** : échappement limité aux droits d'un utilisateur standard

> [!warning] Sécurité avant tout **Toujours privilégier les conteneurs unprivileged** sauf nécessité absolue. Un conteneur privileged compromis peut prendre le contrôle total du serveur hôte.

### Tableau comparatif

|Critère|Unprivileged ✅|Privileged ⚠️|
|---|---|---|
|**Sécurité**|Haute isolation|Faible isolation|
|**Accès matériel**|Limité|Direct|
|**Performance**|Identique|Identique|
|**Compatibilité**|Quelques limitations|Totale|
|**Cas d'usage**|95% des conteneurs|Docker-in-LXC, drivers spéciaux|

### Configurer un conteneur unprivileged

**Interface web :**

- Lors de la création : cocher **"Unprivileged container"**
- Après création : Options → Features → Unprivileged

**Ligne de commande :**

```bash
# Création unprivileged
pct create 100 <template> --unprivileged 1

# Vérifier le statut
pct config 100 | grep unprivileged
# unprivileged: 1

# Convertir un conteneur existant (ARRÊTÉ)
pct set 100 --unprivileged 1
```

> [!tip] Migration vers unprivileged Pour migrer un conteneur privileged vers unprivileged :
> 
> 1. Arrêtez le conteneur : `pct stop 100`
> 2. Activez unprivileged : `pct set 100 --unprivileged 1`
> 3. Redémarrez : `pct start 100`
> 4. Vérifiez les permissions fichiers si problèmes

### Résoudre les problèmes de permissions

#### **Problème : accès aux fichiers montés**

```bash
# Sur l'hôte Proxmox : mapper les UID/GID
# Fichier /etc/pve/lxc/100.conf

# Ajouter pour accès à un partage SMB/NFS
lxc.idmap: u 0 100000 1000
lxc.idmap: g 0 100000 1000
lxc.idmap: u 1000 1000 1
lxc.idmap: g 1000 1000 1
lxc.idmap: u 1001 101001 64535
lxc.idmap: g 1001 101001 64535
```

#### **Problème : accès à un périphérique USB**

```bash
# Donner accès à un périphérique spécifique
# Identifier le device
ls -l /dev/ttyUSB0
# crw-rw---- 1 root dialout 188, 0 Dec 24 10:00 /dev/ttyUSB0

# Ajouter dans /etc/pve/lxc/100.conf
lxc.cgroup2.devices.allow: c 188:* rwm
lxc.mount.entry: /dev/ttyUSB0 dev/ttyUSB0 none bind,optional,create=file 0 0
```

### Quand utiliser un conteneur privileged ?

> [!warning] Cas d'usage légitimes (rares)
> 
> - **Docker-in-LXC** : exécuter Docker dans un conteneur LXC
> - **Accès matériel direct** : GPUs, périphériques USB complexes
> - **Modules noyau** : nécessité de charger des modules kernel
> - **Systèmes legacy** : applications incompatibles avec unprivileged

```bash
# Création d'un conteneur privileged (à éviter)
pct create 100 <template> --unprivileged 0

# Activer des features privilégiées
pct set 100 --features nesting=1,keyctl=1
```

> [!tip] Alternative : nested virtualization Pour Docker, préférez une VM complète plutôt qu'un conteneur privileged. C'est plus sûr et tout aussi performant.

---

## ⚙️ Paramètres CPU et mémoire

### Allocation CPU

Les conteneurs LXC partagent le CPU de l'hôte de manière dynamique. Vous définissez des **limites** et des **priorités**, pas une allocation exclusive.

#### **Cores (cœurs CPU)**

```bash
# Définir le nombre de cœurs
pct set 100 --cores 2

# Affecter des cœurs spécifiques (CPU pinning)
pct set 100 --cpulimit 2 --cpuunits 1024
```

|Paramètre|Description|Valeur par défaut|
|---|---|---|
|**--cores**|Nombre de cœurs alloués|1|
|**--cpulimit**|Limite max de cœurs utilisables|illimité|
|**--cpuunits**|Poids relatif pour le scheduler|1024|

> [!info] Cores vs CPUlimit
> 
> - **--cores** : visibilité pour le conteneur (il voit N cœurs)
> - **--cpulimit** : limitation réelle (peut utiliser jusqu'à N cœurs)
> - Exemple : `--cores 4 --cpulimit 2` → le conteneur voit 4 cœurs mais n'en utilise que 2 max

#### **CPU Units (priorité)**

Le paramètre `cpuunits` définit la **priorité relative** du conteneur par rapport aux autres.

```bash
# Conteneur haute priorité (web production)
pct set 100 --cpuunits 2048

# Conteneur priorité normale (base de données)
pct set 200 --cpuunits 1024

# Conteneur basse priorité (développement)
pct set 300 --cpuunits 512
```

**Calcul de la répartition CPU :**

```
Part CPU = (cpuunits du conteneur) / (somme de tous les cpuunits)

Exemple avec 3 conteneurs sur un CPU à 100% de charge :
- CT100 (2048 units) : 2048 / (2048+1024+512) = 57% CPU
- CT200 (1024 units) : 1024 / 3584 = 28% CPU  
- CT300 (512 units) : 512 / 3584 = 14% CPU
```

> [!tip] Stratégie d'allocation
> 
> - **Production critique** : 2048+ units, cores suffisants
> - **Services standards** : 1024 units (défaut)
> - **Dev/test** : 512 units, partage des ressources
> - **Surveillance** : surveiller avec `pct exec 100 -- top` ou `htop`

### Allocation mémoire

La mémoire LXC peut être **statique** ou **dynamique** (avec swap).

#### **Memory (RAM physique)**

```bash
# Définir la RAM en MB
pct set 100 --memory 2048

# RAM en GB (CLI accepte les suffixes)
pct set 100 --memory 4G
```

**Interface web :** Memory (MiB) → entrer la valeur en mégaoctets

> [!warning] Sur-allocation mémoire Contrairement au CPU, la mémoire est une ressource **non compressible**. Ne sur-allouez pas : la somme des RAM de tous les conteneurs ne doit pas dépasser la RAM physique disponible (moins la RAM pour Proxmox lui-même).

#### **Swap**

```bash
# Ajouter du swap (en MB)
pct set 100 --swap 512

# Désactiver le swap
pct set 100 --swap 0
```

|Configuration|RAM|Swap|Usage recommandé|
|---|---|---|---|
|**Minimal**|512 MB|512 MB|Proxy léger, monitoring|
|**Standard**|1-2 GB|1 GB|Serveur web, services|
|**Intensif**|4-8 GB|2 GB|Base de données, cache|
|**Haute perf**|8+ GB|0 MB|Redis, Elasticsearch|

> [!tip] Swap : pour ou contre ?
> 
> - ✅ **Avec swap** : tolérance aux pics temporaires, OOM killer moins agressif
> - ❌ **Sans swap** : performances prévisibles, échec rapide si RAM insuffisante
> - **Recommandation** : 0.5x à 1x la RAM pour la plupart des cas

#### **Limites mémoire dynamiques**

Proxmox peut ajuster dynamiquement la mémoire avec `--memory` et `--swap` à chaud (conteneur en marche).

```bash
# Augmenter la RAM à chaud (conteneur running)
pct set 100 --memory 4096

# Réduire la RAM (conteneur doit être arrêté)
pct stop 100
pct set 100 --memory 1024
pct start 100
```

### Stratégies d'allocation

#### **Approche conservative (recommandée)**

```bash
# Serveur web PHP
--cores 2 --memory 2048 --swap 1024 --cpuunits 1024

# Base de données PostgreSQL
--cores 4 --memory 4096 --swap 2048 --cpuunits 2048

# Service de cache Redis
--cores 2 --memory 8192 --swap 0 --cpuunits 1536
```

#### **Approche agressive (risquée)**

```bash
# Sur-allocation légère (fonctionne si charge moyenne)
# 8 conteneurs × 2GB = 16GB sur un serveur avec 16GB RAM
# Risque : si tous sont actifs simultanément → OOM killer
```

> [!warning] OOM Killer Si un conteneur dépasse sa limite mémoire (RAM + swap), le kernel peut invoquer l'**OOM Killer** pour tuer des processus. Surveillez les logs : `journalctl -u pve-container@100`

### Surveillance des ressources

```bash
# Vue d'ensemble de tous les conteneurs
pct list

# Statistiques en temps réel
pct exec 100 -- top

# Utilisation mémoire détaillée
pct exec 100 -- free -h

# Monitoring depuis l'hôte
cat /proc/$(pct pid 100)/status | grep -i vmsize
```

**Interface web :** Sélectionner le conteneur → onglet **"Summary"** → graphiques en temps réel

---

## 🌐 Configuration réseau

### Modes de réseau LXC

Proxmox supporte plusieurs modes de réseau pour connecter vos conteneurs.

#### **Bridge (pont réseau) - Mode par défaut**

Le conteneur est connecté à un bridge Linux (généralement `vmbr0`) qui agit comme un switch virtuel.

```bash
# Configuration bridge standard
--net0 name=eth0,bridge=vmbr0,ip=dhcp

# Configuration avec IP statique
--net0 name=eth0,bridge=vmbr0,ip=192.168.1.100/24,gw=192.168.1.1

# Avec adresse MAC personnalisée
--net0 name=eth0,bridge=vmbr0,hwaddr=AA:BB:CC:DD:EE:FF,ip=dhcp
```

**Paramètres du bridge :**

|Paramètre|Description|Exemple|
|---|---|---|
|**name**|Nom de l'interface dans le conteneur|eth0, ens18|
|**bridge**|Bridge de l'hôte|vmbr0, vmbr1|
|**ip**|Adresse IP|`192.168.1.100/24`, `dhcp`|
|**gw**|Passerelle par défaut|192.168.1.1|
|**hwaddr**|Adresse MAC|Auto-générée ou personnalisée|
|**firewall**|Activer le firewall Proxmox|0 ou 1|
|**rate**|Limitation bande passante (MB/s)|10, 100|
|**tag**|VLAN tag|10, 20, 100|

> [!info] Bridge vs NAT Le mode bridge place le conteneur directement sur le réseau physique. Chaque conteneur a sa propre IP routable sur le LAN, comme une machine physique.

#### **DHCP vs IP statique**

```bash
# DHCP (pratique pour le développement)
pct set 100 --net0 name=eth0,bridge=vmbr0,ip=dhcp

# IP statique (recommandé pour la production)
pct set 100 --net0 name=eth0,bridge=vmbr0,ip=192.168.1.100/24,gw=192.168.1.1

# IPv6 + IPv4
pct set 100 --net0 name=eth0,bridge=vmbr0,ip=192.168.1.100/24,gw=192.168.1.1,ip6=2001:db8::100/64,gw6=2001:db8::1
```

> [!tip] Bonnes pratiques IP
> 
> - **DHCP** : dev/test, conteneurs éphémères
> - **IP statique** : production, services exposés, DNS
> - **Réservation DHCP** : compromis (DHCP avec IP fixe via MAC)

### Configuration avancée

#### **Multiples interfaces réseau**

Ajoutez plusieurs interfaces pour segmenter les réseaux (frontend/backend, public/privé).

```bash
# Interface 1 : réseau public (vmbr0)
pct set 100 --net0 name=eth0,bridge=vmbr0,ip=192.168.1.100/24,gw=192.168.1.1

# Interface 2 : réseau privé backend (vmbr1)
pct set 100 --net1 name=eth1,bridge=vmbr1,ip=10.0.0.100/24

# Interface 3 : VLAN management (vmbr0 avec tag)
pct set 100 --net2 name=eth2,bridge=vmbr0,tag=10,ip=10.10.10.100/24
```

**Schéma d'architecture :**

```
Internet
   ↓
vmbr0 (192.168.1.0/24) ← eth0 [Conteneur Web]
                          eth1 ↓
vmbr1 (10.0.0.0/24)    ← eth1 [Conteneur DB]
```

#### **VLAN tagging**

Isolez vos conteneurs dans des VLANs pour la sécurité et la segmentation.

```bash
# Conteneur dans VLAN 10 (DMZ)
pct set 100 --net0 name=eth0,bridge=vmbr0,tag=10,ip=10.10.0.100/24

# Conteneur dans VLAN 20 (Services internes)
pct set 200 --net0 name=eth0,bridge=vmbr0,tag=20,ip=10.20.0.100/24
```

> [!warning] Prérequis VLAN Le switch physique doit supporter les VLANs et être configuré en mode trunk sur le port du serveur Proxmox.

#### **Limitation de bande passante**

Contrôlez la bande passante réseau pour éviter qu'un conteneur monopolise les ressources.

```bash
# Limiter à 10 MB/s (80 Mbps)
pct set 100 --net0 name=eth0,bridge=vmbr0,ip=dhcp,rate=10

# Limiter à 100 MB/s (800 Mbps)
pct set 100 --net0 name=eth0,bridge=vmbr0,ip=dhcp,rate=100
```

> [!example] Cas d'usage
> 
> - **Sauvegardes** : limiter pour ne pas saturer le réseau
> - **Téléchargements** : éviter l'impact sur les services critiques
> - **Tests de charge** : simuler des connexions lentes

### Configuration DNS

Les serveurs DNS peuvent être configurés lors de la création ou modifiés après.

```bash
# Définir les serveurs DNS
pct set 100 --nameserver "8.8.8.8 1.1.1.1"

# Définir le domaine de recherche
pct set 100 --searchdomain "exemple.local"

# Configuration complète
pct set 100 \
  --nameserver "192.168.1.1 8.8.8.8" \
  --searchdomain "monentreprise.local"
```

**Fichier `/etc/resolv.conf` dans le conteneur :**

```bash
# Résultat de la configuration ci-dessus
nameserver 192.168.1.1
nameserver 8.8.8.8
search monentreprise.local
```

> [!info] DNS automatique Si vous ne spécifiez pas de DNS, le conteneur hérite de la configuration de l'hôte Proxmox.

### Firewall intégré Proxmox

Proxmox inclut un firewall au niveau de chaque interface réseau.

```bash
# Activer le firewall sur l'interface
pct set 100 --net0 name=eth0,bridge=vmbr0,ip=dhcp,firewall=1

# Configuration via l'interface web
# Conteneur → Firewall → Add Rule
```

**Règles typiques :**

```bash
# Interface web : Firewall → Add Rule

# Autoriser SSH (port 22)
Direction: IN
Action: ACCEPT
Protocol: tcp
Dest port: 22

# Autoriser HTTP/HTTPS
Direction: IN
Action: ACCEPT
Protocol: tcp
Dest port: 80,443

# Bloquer tout le reste (par défaut)
Direction: IN
Action: DROP
Enable: Yes (fin de la chaîne)
```

> [!tip] Ordre des règles Les règles sont évaluées de haut en bas. Placez les règles ACCEPT avant les règles DROP.

### Diagnostic réseau

```bash
# Tester la connectivité depuis le conteneur
pct exec 100 -- ping -c 3 8.8.8.8

# Vérifier la configuration IP
pct exec 100 -- ip addr show

# Tester la résolution DNS
pct exec 100 -- nslookup google.com

# Afficher les routes
pct exec 100 -- ip route show

# Vérifier les ports en écoute
pct exec 100 -- ss -tuln
```

**Depuis l'hôte :**

```bash
# Voir les bridges et leurs interfaces
brctl show

# Traffic réseau d'un conteneur
iftop -i vethXXXXXX  # Remplacer par l'interface veth du conteneur
```

---

## 💾 Configuration stockage

### Types de stockage pour les conteneurs

Proxmox supporte plusieurs backends de stockage pour héberger les disques des conteneurs.

|Type|Description|Performance|Cas d'usage|
|---|---|---|---|
|**local**|Répertoire local|Moyenne|Dev, templates|
|**local-lvm**|LVM Thin|Haute|Production, snapshots|
|**ZFS**|Système de fichiers CoW|Très haute|Données critiques, compression|
|**Ceph**|Stockage distribué|Variable|Clusters, haute disponibilité|
|**NFS**|Partage réseau|Moyenne|Stockage partagé|

> [!info] Stockage par défaut L'installation standard de Proxmox crée deux stockages :
> 
> - **local** : `/var/lib/vz` (répertoire, templates, ISO)
> - **local-lvm** : LVM thin pool (disques VM/CT)

### Configuration du rootfs (disque système)

Le **rootfs** est le système de fichiers racine du conteneur, contenant l'OS et les applications.

```bash
# Syntaxe de base
--rootfs <storage>:<size>

# Exemples
--rootfs local-lvm:8         # 8 GB sur local-lvm
--rootfs local-lvm:20        # 20 GB
--rootfs zfs-pool:16         # 16 GB sur un pool ZFS
```

**Interface web :** Step "Disks"

- **Storage** : Sélectionner le backend
- **Disk size (GB)** : Taille en gigaoctets
- **ACLs** : Activer les ACLs pour permissions avancées (optionnel)

#### **Taille recommandée selon l'usage**

```bash
# Serveur web minimal (Alpine + Nginx)
--rootfs local-lvm:4

# Serveur web standard (Debian/Ubuntu + Apache/PHP)
--rootfs local-lvm:8

# Serveur applicatif (Node.js, Python, Java)
--rootfs local-lvm:12

# Base de données (MySQL, PostgreSQL)
--rootfs local-lvm:20

# Applications lourdes (GitLab, Nextcloud)
--rootfs local-lvm:30
```

> [!warning] Redimensionnement Sur LVM thin, vous pouvez facilement agrandir le disque, mais le réduire nécessite des manipulations complexes. Prévoyez large ou commencez petit et agrandissez selon les besoins.

#### **Options avancées du rootfs**

```bash
# Avec ACLs activées (permissions POSIX étendues)
pct set 100 --rootfs local-lvm:8,acl=1

# Avec quota (limite d'espace utilisable)
pct set 100 --rootfs local-lvm:8,quota=1

# Avec options de montage personnalisées
pct set 100 --rootfs local-lvm:8,mountoptions=noatime,nodiratime
```

**Paramètres disponibles :**

|Option|Description|Utilité|
|---|---|---|
|**acl=1**|Active les ACLs POSIX|Permissions avancées multi-utilisateurs|
|**quota=1**|Active les quotas utilisateur|Limiter l'espace par utilisateur|
|**ro=1**|Montage lecture seule|Conteneurs immutables, sécurité|
|**shared=1**|Stockage partagé|Multiples conteneurs sur même volume|

### Points de montage supplémentaires (mount points)

Ajoutez des disques supplémentaires pour séparer les données du système.

#### **Pourquoi des mount points séparés ?**

> [!tip] Avantages de la séparation
> 
> - **Isolation** : données séparées du système
> - **Sauvegardes** : sauvegarder uniquement les données
> - **Maintenance** : reconstruire le conteneur sans perdre les données
> - **Performance** : différents backends pour système et données
> - **Quotas** : limiter l'espace données indépendamment

#### **Ajouter un mount point**

```bash
# Syntaxe générale
pct set <CTID> --mp<N> <storage>:<size>,mp=<path>

# Exemples pratiques
# Mount point pour /var/www (données web)
pct set 100 --mp0 local-lvm:20,mp=/var/www

# Mount point pour /var/lib/mysql (base de données)
pct set 200 --mp0 local-lvm:50,mp=/var/lib/mysql

# Mount point avec backup désactivé
pct set 100 --mp0 local-lvm:10,mp=/tmp,backup=0

# Mount point avec ACLs
pct set 100 --mp0 local-lvm:30,mp=/data,acl=1
```

**Interface web :**

1. Sélectionner le conteneur
2. Hardware → Add → Mount Point
3. Configurer storage, taille, et chemin de montage

#### **Configuration avancée des mount points**

```bash
# Lecture seule (pour partager des données)
pct set 100 --mp0 local-lvm:10,mp=/data/readonly,ro=1

# Avec quotas utilisateurs
pct set 100 --mp0 local-lvm:50,mp=/home,quota=1

# Plusieurs mount points
pct set 100 --mp0 local-lvm:20,mp=/var/www
pct set 100 --mp1 local-lvm:30,mp=/var/lib/mysql
pct set 100 --mp2 nfs-storage:100,mp=/backups
```

> [!example] Architecture typique serveur web
> 
> ```
> CT 100 - Serveur LAMP
> ├─ rootfs: local-lvm:8    → / (système)
> ├─ mp0: local-lvm:30      → /var/www (sites web)
> └─ mp1: nfs-share:50      → /backups (sauvegardes)
> ```

### Bind mounts (montage de répertoires hôte)

Montez des répertoires de l'hôte Proxmox directement dans le conteneur.

> [!warning] Sécurité des bind mounts Les bind mounts donnent au conteneur un accès direct au système de fichiers de l'hôte. À utiliser avec précaution, surtout avec des conteneurs unprivileged (problèmes de permissions).

#### **Configuration dans le fichier .conf**

```bash
# Éditer le fichier de configuration du conteneur
nano /etc/pve/lxc/100.conf

# Ajouter un bind mount
mp0: /mnt/hote/partage,mp=/mnt/partage

# Bind mount avec sous-répertoire spécifique
mp1: /storage/data/medias,mp=/var/www/medias

# Lecture seule
mp2: /etc/ssl/certs,mp=/shared/certs,ro=1
```

**Syntaxe complète :**

```bash
mp<N>: <chemin-hote>,mp=<chemin-conteneur>[,<options>]

Options disponibles :
- ro=1              : lecture seule
- backup=0          : exclure des sauvegardes
- replicate=0       : exclure de la réplication
- shared=1          : stockage partagé
- mountoptions=...  : options mount Linux
```

#### **Cas d'usage typiques**

```bash
# Partage de fichiers entre plusieurs conteneurs
# Hôte : /mnt/storage/shared
# CT100 : /data/shared
# CT101 : /data/shared
mp0: /mnt/storage/shared,mp=/data/shared

# Partage de certificats SSL
mp0: /etc/letsencrypt,mp=/etc/letsencrypt,ro=1

# Partage de logs centralisés
mp0: /var/log/containers,mp=/var/log/app

# Stockage NAS monté sur l'hôte
mp0: /mnt/nas/backups,mp=/backups
```

> [!tip] Permissions avec conteneurs unprivileged Pour les bind mounts avec unprivileged, ajustez les permissions sur l'hôte :
> 
> ```bash
> # Sur l'hôte, donner accès à l'UID mappé (100000+)
> chown -R 100000:100000 /mnt/hote/partage
> 
> # Ou utiliser les ID maps dans le fichier .conf
> lxc.idmap: u 0 100000 1000
> lxc.idmap: u 1000 1000 1
> lxc.idmap: u 1001 101001 64535
> ```

### Redimensionner les disques

#### **Agrandir un disque (sans arrêt)**

```bash
# Agrandir le rootfs de 8GB à 16GB
pct resize 100 rootfs 16G

# Agrandir un mount point
pct resize 100 mp0 50G

# Le système de fichiers est automatiquement étendu
```

**Interface web :**

1. Sélectionner le conteneur
2. Resources → Hard Disk
3. Bouton "Resize disk"
4. Entrer la nouvelle taille

> [!info] Redimensionnement en ligne Le redimensionnement fonctionne à chaud (conteneur en marche) et le système de fichiers est automatiquement étendu. Aucune manipulation manuelle nécessaire.

#### **Réduire un disque (complexe)**

> [!warning] Réduction de disque Réduire un disque est risqué et complexe. Il faut :
> 
> 1. Arrêter le conteneur
> 2. Réduire manuellement le système de fichiers dans le conteneur
> 3. Réduire le volume LVM sur l'hôte
> 4. Mettre à jour la configuration
> 
> **Non recommandé** : créez plutôt un nouveau conteneur avec la bonne taille et migrez les données.

### Gestion des snapshots et backups

#### **Snapshots (instantanés)**

Les snapshots capturent l'état du conteneur à un instant T. Utiles avant des modifications risquées.

```bash
# Créer un snapshot
pct snapshot 100 avant-mise-a-jour

# Créer un snapshot avec description
pct snapshot 100 pre-upgrade --description "Avant upgrade vers Debian 13"

# Lister les snapshots
pct listsnapshot 100

# Restaurer un snapshot (conteneur arrêté)
pct stop 100
pct rollback 100 avant-mise-a-jour
pct start 100

# Supprimer un snapshot
pct delsnapshot 100 avant-mise-a-jour
```

**Interface web :**

- Conteneur → Snapshots → Take Snapshot
- Entrer un nom et description
- Option "Include RAM" (pour les conteneurs running)

> [!tip] Bonnes pratiques snapshots
> 
> - Prenez un snapshot avant toute modification système
> - Nommez clairement : `avant-upgrade-php`, `pre-config-nginx`
> - Supprimez les anciens snapshots (consomment de l'espace)
> - Les snapshots ne remplacent PAS les backups (pas de protection contre panne matérielle)

#### **Exclusions de backup**

```bash
# Exclure un mount point des backups
pct set 100 --mp0 local-lvm:100,mp=/cache,backup=0

# Exclure des répertoires spécifiques
# Éditer /etc/pve/lxc/100.conf
mp0: local-lvm:50,mp=/var/www,backup=0

# Utile pour :
# - Dossiers cache
# - Dossiers temporaires
# - Données régénérables
# - Volumes très volumineux
```

### Stockage partagé et migration

#### **Stockage partagé (Ceph, NFS)**

Pour la haute disponibilité et la migration live, utilisez du stockage partagé.

```bash
# Créer un conteneur sur stockage partagé
pct create 100 <template> \
  --hostname web-ha \
  --rootfs ceph-pool:8 \
  --mp0 ceph-pool:20,mp=/var/www

# Permet la migration entre nœuds sans copie de données
```

**Avantages :**

- Migration live (sans downtime)
- Haute disponibilité automatique
- Snapshots répliqués

#### **Migration de stockage**

```bash
# Déplacer un conteneur d'un storage à un autre
pct move-volume 100 rootfs local-lvm --delete 1

# Déplacer un mount point
pct move-volume 100 mp0 ceph-pool --delete 1

# L'option --delete supprime l'ancien volume après copie
```

> [!info] Temps d'arrêt La migration de stockage nécessite l'arrêt du conteneur. Pour du stockage partagé, utilisez la migration de nœud standard.

### Optimisations de performance

#### **Choix du système de fichiers**

```bash
# LVM Thin (par défaut) : bon compromis
--rootfs local-lvm:8

# ZFS : compression, déduplication, snapshots avancés
--rootfs zfs-pool:8

# Répertoire : simple mais moins performant
--rootfs local:8
```

**Comparaison :**

|Backend|Performance|Snapshots|Compression|Dédup|Complexité|
|---|---|---|---|---|---|
|**LVM Thin**|★★★★☆|Oui|Non|Non|Faible|
|**ZFS**|★★★★★|Oui|Oui|Oui|Moyenne|
|**Ceph**|★★★☆☆|Oui|Oui|Non|Élevée|
|**Répertoire**|★★☆☆☆|Non|Non|Non|Très faible|

#### **Options de montage pour la performance**

```bash
# Désactiver atime (moins d'écritures disque)
pct set 100 --rootfs local-lvm:8,mountoptions=noatime,nodiratime

# Pour bases de données (journalisation)
pct set 200 --mp0 local-lvm:50,mp=/var/lib/mysql,mountoptions=noatime

# SSD : ajouter discard pour TRIM
pct set 100 --rootfs local-lvm:8,mountoptions=noatime,discard
```

> [!tip] Performance I/O Pour des charges I/O intensives (bases de données), privilégiez :
> 
> - LVM Thin ou ZFS sur SSD/NVMe
> - Options noatime/nodiratime
> - Caches write-back (ZFS)
> - RAID10 plutôt que RAID5/6

### Vérification et diagnostic

```bash
# Voir la configuration complète du stockage
pct config 100

# Utilisation disque dans le conteneur
pct exec 100 -- df -h

# Voir les mount points actifs
pct exec 100 -- mount | grep /var

# Performances I/O (depuis le conteneur)
pct exec 100 -- dd if=/dev/zero of=/tmp/test bs=1M count=1024 conv=fdatasync

# Vérifier l'espace utilisé sur l'hôte
lvs
zfs list
df -h /var/lib/vz
```

**Depuis l'interface web :**

- Conteneur → Summary : graphique d'utilisation disque
- Conteneur → Resources : détails des disques
- Datacenter → Storage : vue globale des backends

---

## 🎓 Récapitulatif

Vous savez maintenant créer et configurer des conteneurs LXC dans Proxmox :

### ✅ Points clés à retenir

**Templates :**

- Téléchargez les templates avant la création
- Choisissez la distribution selon vos besoins (Alpine = léger, Debian = stable)

**Sécurité :**

- Privilégiez TOUJOURS les conteneurs unprivileged
- N'utilisez privileged que si absolument nécessaire

**Ressources :**

- CPU : allocation flexible avec cpuunits pour priorisation
- RAM : non compressible, ne sur-allouez pas
- Swap : utile pour tolérance aux pics (0.5-1x la RAM)

**Réseau :**

- Mode bridge : conteneurs sur le réseau physique
- IP statique recommandée en production
- VLANs pour segmentation sécurisée
- Firewall Proxmox disponible par interface

**Stockage :**

- Rootfs : système (8-20 GB généralement)
- Mount points : séparez données et système
- LVM Thin : bon compromis performance/features
- Bind mounts : partage avec l'hôte (attention permissions)
- Snapshots : avant modifications importantes

### 🚀 Workflow de création recommandé

```bash
# 1. Télécharger le template
pveam download local debian-12-standard_12.2-1_amd64.tar.zst

# 2. Créer le conteneur (unprivileged, IP statique)
pct create 100 local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst \
  --hostname web-prod-01 \
  --password SecurePass123! \
  --unprivileged 1 \
  --cores 2 \
  --memory 2048 \
  --swap 1024 \
  --rootfs local-lvm:12 \
  --net0 name=eth0,bridge=vmbr0,ip=192.168.1.100/24,gw=192.168.1.1,firewall=1 \
  --nameserver "192.168.1.1 8.8.8.8" \
  --onboot 1

# 3. Ajouter un mount point pour les données
pct set 100 --mp0 local-lvm:30,mp=/var/www

# 4. Snapshot initial
pct start 100
pct snapshot 100 initial-setup

# 5. Configuration post-installation dans le conteneur
pct enter 100
# ... configuration système, installation services ...
```

> [!success] Prêt pour la suite Vous maîtrisez maintenant la création de conteneurs LXC. La prochaine étape sera de gérer et administrer vos conteneurs au quotidien.