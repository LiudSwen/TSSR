

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

## Introduction

Les bonnes pratiques dans la configuration d'un cluster Proxmox sont essentielles pour garantir **stabilité**, **performance** et **résilience**. Un cluster mal configuré peut entraîner des problèmes de split-brain, des pertes de quorum, ou des dégradations de performance impactant l'ensemble de l'infrastructure.

Ce chapitre couvre trois piliers fondamentaux d'un cluster Proxmox bien conçu :

- L'isolation réseau pour les communications cluster
- Le dimensionnement optimal du nombre de nœuds
- La protection de la configuration

---

## 🌐 Réseau dédié pour le cluster

### Pourquoi un réseau dédié ?

La communication cluster dans Proxmox utilise **Corosync** pour la synchronisation et le maintien du quorum. Ce trafic est critique et sensible à la latence. Un réseau partagé avec d'autres flux (VM, stockage, administration) peut causer :

- **Perte de quorum** due à la latence réseau
- **Split-brain** si les nœuds ne peuvent plus communiquer
- **Dégradation des performances** de synchronisation
- **Problèmes de sécurité** (exposition des communications cluster)

> [!warning] Risque majeur Un réseau cluster saturé ou défaillant peut entraîner la mise hors ligne de tout le cluster, même si les nœuds fonctionnent individuellement.

### Architecture réseau recommandée

#### Séparation des flux réseau

|Type de réseau|Usage|VLAN recommandé|Priorité|
|---|---|---|---|
|**Cluster Network**|Communication Corosync|VLAN 10|Critique|
|**Management**|Interface Web, SSH|VLAN 20|Haute|
|**Storage**|Ceph, NFS, iSCSI|VLAN 30|Haute|
|**VM Network**|Trafic des machines virtuelles|VLAN 40+|Variable|

> [!tip] Astuce Utilisez des interfaces réseau physiques distinctes pour le cluster et le stockage si possible. Au minimum, isolez-les via VLANs.

### Configuration du réseau cluster

#### Étape 1 : Identifier l'interface dédiée

```bash
# Lister les interfaces réseau disponibles
ip addr show

# Exemple de sortie :
# 1: lo: <LOOPBACK,UP,LOWER_UP>
# 2: eno1: <BROADCAST,MULTICAST,UP,LOWER_UP> (Management)
# 3: eno2: <BROADCAST,MULTICAST,UP,LOWER_UP> (Cluster - À utiliser)
# 4: eno3: <BROADCAST,MULTICAST,UP,LOWER_UP> (Storage)
```

#### Étape 2 : Configurer l'interface dans `/etc/network/interfaces`

```bash
# Interface dédiée pour le cluster
auto eno2
iface eno2 inet static
    address 10.0.10.1/24    # IP du nœud 1 sur le réseau cluster
    # Pas de gateway sur cette interface
    # Réseau privé non routé

# Sur le nœud 2
# address 10.0.10.2/24

# Sur le nœud 3
# address 10.0.10.3/24
```

```bash
# Appliquer la configuration
ifreload -a

# Vérifier la connectivité entre nœuds
ping -c 4 10.0.10.2
ping -c 4 10.0.10.3
```

#### Étape 3 : Spécifier le réseau lors de la création du cluster

```bash
# Créer le cluster en spécifiant l'interface dédiée
pvecm create mon-cluster --link0 10.0.10.1

# Ajouter un nœud au cluster via le réseau dédié
pvecm add 10.0.10.1 --link0 10.0.10.2
```

#### Étape 4 : Vérifier la configuration Corosync

```bash
# Afficher la configuration Corosync
cat /etc/pve/corosync.conf
```

> [!example] Exemple de configuration Corosync optimale
> 
> ```
> totem {
>     version: 2
>     cluster_name: mon-cluster
>     transport: knet
>     crypto_cipher: aes256
>     crypto_hash: sha256
>     
>     interface {
>         linknumber: 0
>         bindnetaddr: 10.0.10.0    # Réseau cluster dédié
>     }
> }
> 
> nodelist {
>     node {
>         name: pve1
>         nodeid: 1
>         quorum_votes: 1
>         ring0_addr: 10.0.10.1     # IP sur réseau dédié
>     }
>     node {
>         name: pve2
>         nodeid: 2
>         quorum_votes: 1
>         ring0_addr: 10.0.10.2
>     }
>     node {
>         name: pve3
>         nodeid: 3
>         quorum_votes: 1
>         ring0_addr: 10.0.10.3
>     }
> }
> 
> quorum {
>     provider: corosync_votequorum
> }
> ```

### Redondance réseau (optionnel mais recommandé)

Pour les environnements critiques, configurez un **second lien réseau** (link1) :

```bash
# Ajouter un second lien lors de la création
pvecm create mon-cluster --link0 10.0.10.1 --link1 10.0.20.1

# Ou après création
pvecm updatecerts
```

> [!info] Fonctionnement du double lien Corosync utilise le transport **knet** qui permet d'utiliser plusieurs liens simultanément. En cas de défaillance d'un lien, le trafic bascule automatiquement sur l'autre sans perte de quorum.

### Caractéristiques réseau recommandées

- **Latence** : < 2ms entre nœuds (idéalement < 1ms)
- **Bande passante** : Minimum 1 Gbps, 10 Gbps recommandé
- **MTU** : 1500 standard, ou 9000 (Jumbo Frames) pour meilleures performances
- **Switch** : Manageable avec support VLAN et QoS

```bash
# Tester la latence entre nœuds
ping -c 100 10.0.10.2 | tail -1

# Vérifier le MTU
ip link show eno2 | grep mtu

# Modifier le MTU si nécessaire
ip link set eno2 mtu 9000
```

> [!warning] Pièges courants
> 
> - ❌ Utiliser le réseau de management pour Corosync
> - ❌ Partager le réseau cluster avec le trafic VM
> - ❌ Oublier de tester la latence avant déploiement
> - ❌ Ne pas documenter le plan d'adressage IP

---

## 🔢 Nombre de nœuds (impair)

### Pourquoi un nombre impair ?

Proxmox utilise un système de **quorum** pour maintenir la cohérence du cluster. Le quorum représente le nombre minimum de nœuds actifs nécessaires pour que le cluster reste opérationnel.

**Formule du quorum** : `(nombre_de_nœuds / 2) + 1`

> [!info] Comprendre le quorum Le quorum évite le **split-brain** : situation où le cluster se divise en plusieurs groupes isolés qui croient chacun être le cluster légitime, causant des conflits de données.

### Calcul du quorum selon le nombre de nœuds

|Nœuds|Quorum requis|Nœuds perdus tolérés|Recommandation|
|---|---|---|---|
|**2**|2|0|❌ Non recommandé|
|**3**|2|1|✅ **Optimal**|
|**4**|3|1|⚠️ Pas d'avantage vs 3 nœuds|
|**5**|3|2|✅ **Haute disponibilité**|
|**6**|4|2|⚠️ Pas d'avantage vs 5 nœuds|
|**7**|4|3|✅ Très haute disponibilité|

> [!warning] Cluster à 2 nœuds Un cluster à 2 nœuds ne peut tolérer aucune panne. Si un nœud tombe, le quorum est perdu et le cluster devient non-opérationnel. C'est une **configuration à éviter en production**.

### Configurations recommandées

#### Configuration minimale : 3 nœuds

```bash
# Créer un cluster à 3 nœuds
# Sur le nœud 1
pvecm create production-cluster

# Sur le nœud 2
pvecm add 192.168.1.1

# Sur le nœud 3
pvecm add 192.168.1.1

# Vérifier le quorum
pvecm status
```

**Avantages** :

- ✅ Tolère la perte d'1 nœud
- ✅ Coût optimal (3 serveurs minimum)
- ✅ Parfait pour PME ou environnements de test/dev

> [!example] Scénario avec 3 nœuds
> 
> - **Nœuds actifs** : pve1, pve2, pve3
> - **pve2 tombe en panne** → Quorum : 2/3 ✅ Cluster opérationnel
> - **pve3 tombe aussi** → Quorum : 1/3 ❌ Cluster bloqué

#### Configuration haute disponibilité : 5 nœuds

```bash
# Vérifier le statut d'un cluster à 5 nœuds
pvecm status

# Sortie attendue :
# Quorum information
# ------------------
# Date:             Wed Dec 24 10:30:00 2025
# Quorum provider:  corosync_votequorum
# Nodes:            5
# Node ID:          1
# Ring ID:          1.a
# Quorate:          Yes    # ✅ Quorum atteint
# 
# Votequorum information
# ----------------------
# Expected votes:   5
# Highest expected: 5
# Total votes:      5
# Quorum:           3      # Minimum requis
```

**Avantages** :

- ✅ Tolère la perte de 2 nœuds simultanément
- ✅ Maintenance sans risque (peut mettre un nœud hors ligne)
- ✅ Résilience élevée pour production critique

### Cas particulier : Cluster à nombre pair

Si vous devez absolument utiliser un nombre pair de nœuds (contraintes budgétaires, matériel existant), utilisez un **QDevice** :

#### Configuration d'un QDevice

Le QDevice est un service externe qui fournit un vote supplémentaire pour maintenir le quorum.

```bash
# Sur un serveur externe (peut être une VM légère)
apt update && apt install corosync-qnetd

# Démarrer le service
systemctl enable --now corosync-qnetd
systemctl status corosync-qnetd

# Sur le cluster Proxmox
apt update && apt install corosync-qdevice

# Configurer le QDevice
pvecm qdevice setup 192.168.1.100

# Vérifier la configuration
pvecm status
```

> [!info] Fonctionnement du QDevice Le QDevice ajoute 1 vote au cluster. Avec 4 nœuds + 1 QDevice = 5 votes totaux, le quorum devient 3. Le cluster peut maintenant tolérer la perte de 1 nœud.

|Configuration|Votes totaux|Quorum|Nœuds perdus tolérés|
|---|---|---|---|
|4 nœuds seuls|4|3|1 ❌ (peu fiable)|
|4 nœuds + QDevice|5|3|1 ✅ (plus fiable)|

### Vérification et monitoring du quorum

```bash
# Afficher le statut du quorum en temps réel
watch -n 2 'pvecm status'

# Afficher les votes de chaque nœud
corosync-quorumtool -s

# Logs Corosync pour diagnostic
journalctl -u corosync -f

# Vérifier les membres du cluster
pvecm nodes
```

> [!tip] Monitoring proactif Configurez des alertes pour être notifié si le quorum devient critique (juste au-dessus du minimum requis).

### Dimensionnement selon les besoins

**Petite infrastructure** (< 50 VM) :

- 3 nœuds suffisent
- Budget optimisé
- Maintenance en dehors des heures de production

**Infrastructure moyenne** (50-200 VM) :

- 5 nœuds recommandés
- Permet maintenance en continu
- Bonne répartition de charge

**Grande infrastructure** (> 200 VM) :

- 5-7 nœuds
- Considérer plusieurs clusters si > 16 nœuds
- Zones géographiques multiples possibles

> [!warning] Pièges courants
> 
> - ❌ Démarrer avec 2 nœuds en pensant étendre plus tard
> - ❌ Ignorer le calcul du quorum lors du dimensionnement
> - ❌ Oublier que 4 nœuds = même résilience que 3 nœuds
> - ❌ Ne pas prévoir de QDevice si nombre pair imposé

---

## 💾 Sauvegarde de la configuration cluster

### Importance de la sauvegarde

La configuration du cluster Proxmox contient des informations **critiques** :

- Configuration Corosync (topologie, membres, réseau)
- Certificats SSL et clés de chiffrement
- Configuration des VMs et conteneurs (emplacement, pas de données)
- Configuration réseau et stockage
- Droits et utilisateurs

> [!warning] Risque de perte totale Sans sauvegarde de configuration, la perte de tous les nœuds simultanément (incendie, catastrophe) rend **impossible** la reconstruction du cluster, même si les données VM sont sauvegardées ailleurs.

### Éléments à sauvegarder

#### Fichiers de configuration principaux

```bash
# Configuration du cluster
/etc/pve/corosync.conf          # Configuration Corosync
/etc/pve/datacenter.cfg         # Configuration datacenter
/etc/pve/storage.cfg            # Configuration stockage
/etc/pve/user.cfg               # Utilisateurs et permissions
/etc/pve/authkey.pub            # Clé publique d'authentification
/etc/pve/priv/authkey.key       # Clé privée d'authentification (sensible !)

# Certificats SSL
/etc/pve/nodes/*/pve-ssl.pem    # Certificats par nœud
/etc/pve/nodes/*/pve-ssl.key    # Clés privées par nœud (sensible !)
/etc/pve/pve-root-ca.pem        # CA racine du cluster

# Configuration réseau
/etc/network/interfaces         # Configuration réseau système
/etc/hosts                      # Résolution DNS locale
/etc/hostname                   # Nom d'hôte du nœud

# Configuration système Proxmox
/etc/pve/qemu-server/           # Configurations des VMs
/etc/pve/lxc/                   # Configurations des conteneurs
/etc/pve/firewall/              # Configuration firewall
/etc/pve/ha/                    # Configuration haute disponibilité
```

> [!info] Stockage de la configuration Les fichiers dans `/etc/pve/` sont stockés dans un **système de fichiers distribué** (pmxcfs) synchronisé automatiquement entre tous les nœuds. Cependant, une sauvegarde externe reste nécessaire.

### Méthode 1 : Sauvegarde manuelle complète

```bash
#!/bin/bash
# Script de sauvegarde de configuration Proxmox

# Variables
BACKUP_DIR="/root/cluster-backup"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="proxmox-config-$DATE"
BACKUP_PATH="$BACKUP_DIR/$BACKUP_NAME"

# Créer le répertoire de sauvegarde
mkdir -p "$BACKUP_PATH"

# Sauvegarder la configuration du cluster
echo "💾 Sauvegarde de la configuration cluster..."
cp -r /etc/pve "$BACKUP_PATH/"
cp /etc/network/interfaces "$BACKUP_PATH/"
cp /etc/hosts "$BACKUP_PATH/"
cp /etc/hostname "$BACKUP_PATH/"

# Sauvegarder la liste des paquets installés
echo "📦 Sauvegarde de la liste des paquets..."
dpkg --get-selections > "$BACKUP_PATH/package-list.txt"
apt-mark showauto > "$BACKUP_PATH/package-auto.txt"

# Sauvegarder les informations système
echo "ℹ️ Sauvegarde des informations système..."
pvecm status > "$BACKUP_PATH/cluster-status.txt"
pvecm nodes > "$BACKUP_PATH/cluster-nodes.txt"
pveversion -v > "$BACKUP_PATH/pve-version.txt"

# Créer une archive compressée
echo "🗜️ Compression de la sauvegarde..."
cd "$BACKUP_DIR"
tar -czf "$BACKUP_NAME.tar.gz" "$BACKUP_NAME/"
rm -rf "$BACKUP_NAME"

# Informations finales
echo "✅ Sauvegarde terminée : $BACKUP_DIR/$BACKUP_NAME.tar.gz"
ls -lh "$BACKUP_DIR/$BACKUP_NAME.tar.gz"

# Optionnel : Copier vers un serveur distant
# scp "$BACKUP_DIR/$BACKUP_NAME.tar.gz" backup-server:/backup/proxmox/
```

```bash
# Rendre le script exécutable
chmod +x /root/backup-cluster-config.sh

# Exécuter la sauvegarde
/root/backup-cluster-config.sh
```

> [!tip] Automatisation Programmez ce script en cron pour des sauvegardes régulières :
> 
> ```bash
> # Éditer le crontab
> crontab -e
> 
> # Ajouter une sauvegarde quotidienne à 3h du matin
> 0 3 * * * /root/backup-cluster-config.sh
> ```

### Méthode 2 : Sauvegarde avec rotation automatique

```bash
#!/bin/bash
# Script de sauvegarde avec rotation (garde les 7 dernières)

BACKUP_DIR="/root/cluster-backup"
RETENTION_DAYS=7
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="proxmox-config-$DATE.tar.gz"

mkdir -p "$BACKUP_DIR"

# Créer la sauvegarde
tar -czf "$BACKUP_DIR/$BACKUP_NAME" \
    /etc/pve \
    /etc/network/interfaces \
    /etc/hosts \
    /etc/hostname \
    2>/dev/null

# Ajouter les informations système
{
    echo "=== Cluster Status ==="
    pvecm status
    echo ""
    echo "=== Cluster Nodes ==="
    pvecm nodes
    echo ""
    echo "=== PVE Version ==="
    pveversion -v
} > "$BACKUP_DIR/system-info-$DATE.txt"

# Rotation : supprimer les sauvegardes de plus de X jours
find "$BACKUP_DIR" -name "proxmox-config-*.tar.gz" -mtime +$RETENTION_DAYS -delete
find "$BACKUP_DIR" -name "system-info-*.txt" -mtime +$RETENTION_DAYS -delete

echo "✅ Sauvegarde créée : $BACKUP_NAME"
echo "📊 Sauvegardes disponibles :"
ls -lh "$BACKUP_DIR"/proxmox-config-*.tar.gz | tail -5
```

### Méthode 3 : Synchronisation vers serveur distant

```bash
#!/bin/bash
# Sauvegarde avec synchronisation rsync

BACKUP_DIR="/root/cluster-backup"
REMOTE_SERVER="backup-server.example.com"
REMOTE_PATH="/backup/proxmox/$(hostname)"
DATE=$(date +%Y%m%d_%H%M%S)

# Créer la sauvegarde locale
tar -czf "$BACKUP_DIR/config-$DATE.tar.gz" /etc/pve /etc/network/interfaces

# Synchroniser vers le serveur distant
rsync -avz --delete \
    "$BACKUP_DIR/" \
    "$REMOTE_SERVER:$REMOTE_PATH/"

echo "✅ Sauvegarde synchronisée vers $REMOTE_SERVER"
```

> [!warning] Sécurité des clés privées Les clés privées (`/etc/pve/priv/`) sont **sensibles**. Assurez-vous que :
> 
> - Les archives sont chiffrées si stockées hors site
> - Les permissions sont restrictives (600)
> - L'accès au serveur de backup est sécurisé

### Chiffrement de la sauvegarde

Pour protéger les données sensibles (clés, certificats) :

```bash
#!/bin/bash
# Sauvegarde chiffrée avec GPG

BACKUP_DIR="/root/cluster-backup"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="proxmox-config-$DATE.tar.gz"
GPG_RECIPIENT="admin@example.com"

# Créer l'archive
tar -czf "/tmp/$BACKUP_NAME" /etc/pve /etc/network/interfaces

# Chiffrer l'archive
gpg --encrypt \
    --recipient "$GPG_RECIPIENT" \
    --output "$BACKUP_DIR/$BACKUP_NAME.gpg" \
    "/tmp/$BACKUP_NAME"

# Nettoyer le fichier temporaire non chiffré
rm "/tmp/$BACKUP_NAME"

echo "🔐 Sauvegarde chiffrée : $BACKUP_DIR/$BACKUP_NAME.gpg"
```

```bash
# Déchiffrement pour restauration
gpg --decrypt "$BACKUP_DIR/$BACKUP_NAME.gpg" > "/tmp/$BACKUP_NAME"
tar -xzf "/tmp/$BACKUP_NAME" -C /
```

### Restauration de la configuration

#### Restauration complète d'un nœud

```bash
# 1. Extraire la sauvegarde
cd /root
tar -xzf cluster-backup/proxmox-config-20251224_030000.tar.gz

# 2. Arrêter les services Proxmox
systemctl stop pve-cluster
systemctl stop corosync
systemctl stop pvedaemon
systemctl stop pveproxy

# 3. Restaurer les fichiers de configuration
cp -r proxmox-config-20251224_030000/etc/pve/* /etc/pve/
cp proxmox-config-20251224_030000/etc/network/interfaces /etc/network/
cp proxmox-config-20251224_030000/etc/hosts /etc/hosts
cp proxmox-config-20251224_030000/etc/hostname /etc/hostname

# 4. Corriger les permissions
chmod 600 /etc/pve/priv/*
chown -R root:www-data /etc/pve

# 5. Redémarrer les services
systemctl start corosync
systemctl start pve-cluster
systemctl start pvedaemon
systemctl start pveproxy

# 6. Vérifier le statut
pvecm status
```

> [!example] Scénario de disaster recovery **Situation** : Datacenter détruit, tous les nœuds perdus **Solution** :
> 
> 1. Réinstaller Proxmox sur nouveau matériel
> 2. Restaurer la configuration depuis sauvegarde externe
> 3. Recréer le cluster avec `pvecm create`
> 4. Restaurer les VM depuis sauvegardes PBS/externes

### Sauvegarde centralisée avec Proxmox Backup Server

Si vous utilisez Proxmox Backup Server, programmez la sauvegarde des configurations :

```bash
# Créer un job de sauvegarde spécifique pour la config
vzdump --mode snapshot --compress zstd --storage pbs-backup \
    --notes-template "Config backup {{guestname}}" \
    --all
```

### Bonnes pratiques de sauvegarde

✅ **À faire** :

- Sauvegarder **quotidiennement** la configuration
- Stocker les sauvegardes sur un **système externe** au cluster
- **Chiffrer** les sauvegardes contenant des clés privées
- Tester régulièrement la **restauration**
- Documenter la **procédure de restauration**
- Garder plusieurs **versions** (7-30 jours)
- Sauvegarder après **chaque modification majeure**

❌ **À éviter** :

- Stocker uniquement sur un nœud du cluster
- Ne jamais tester la restauration
- Oublier de sauvegarder après ajout/retrait de nœud
- Négliger le chiffrement des données sensibles
- Ne pas automatiser les sauvegardes

### Checklist de vérification

```bash
# Vérifier que les sauvegardes existent
ls -lh /root/cluster-backup/*.tar.gz

# Vérifier qu'elles sont récentes (< 24h)
find /root/cluster-backup -name "*.tar.gz" -mtime -1

# Tester l'intégrité d'une archive
tar -tzf /root/cluster-backup/proxmox-config-latest.tar.gz > /dev/null
echo $?  # Doit retourner 0

# Vérifier la synchronisation distante
ssh backup-server "ls -lh /backup/proxmox/$(hostname)/"
```

> [!tip] Documentation de crise Créez un document physique (papier/PDF imprimé) avec :
> 
> - Localisation des sauvegardes
> - Mots de passe de déchiffrement (coffre sécurisé)
> - Procédure de restauration pas-à-pas
> - Contacts d'urgence
> 
> Ce document doit être accessible même si toute l'infrastructure est indisponible.

---

## 🎓 Récapitulatif

Les trois piliers d'un cluster Proxmox robuste :

1. **Réseau dédié** : Isolez les communications Corosync pour éviter latence, perte de quorum et split-brain
    
2. **Nombre impair de nœuds** : 3 ou 5 nœuds pour tolérer respectivement 1 ou 2 défaillances. Utilisez un QDevice si nombre pair imposé
    
3. **Sauvegarde configuration** : Automatisez les sauvegardes quotidiennes chiffrées, stockez-les hors cluster, et testez régulièrement la restauration
    

> [!success] Cluster prêt pour la production En appliquant ces trois bonnes pratiques, votre cluster Proxmox bénéficiera d'une **haute disponibilité**, d'une **résilience optimale** et d'une **capacité de récupération** en cas de sinistre.

---

_📅 Dernière mise à jour : Décembre 2024_