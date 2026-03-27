

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

## 🚀 Démarrage, arrêt et redémarrage

### Vue d'ensemble

La gestion du cycle de vie d'un conteneur LXC est une opération quotidienne essentielle. Contrairement aux machines virtuelles, les conteneurs LXC démarrent et s'arrêtent presque instantanément car ils partagent le noyau de l'hôte.

### Opérations via l'interface Web

#### Démarrage d'un conteneur

**Via l'interface graphique :**
1. Sélectionnez le conteneur dans l'arborescence
2. Cliquez sur le bouton **Start** dans la barre d'outils
3. Le statut passe de "stopped" à "running"

**Démarrage automatique au boot :**
- Options → Start at boot → Cochez la case
- Le conteneur démarrera automatiquement après le redémarrage de l'hôte Proxmox

#### Arrêt d'un conteneur

Deux méthodes sont disponibles :

**Shutdown (arrêt propre) :**
- Envoie un signal SIGTERM au système
- Permet au conteneur de terminer proprement ses processus
- Attente de 60 secondes par défaut avant un arrêt forcé

**Stop (arrêt forcé) :**
- Tue immédiatement tous les processus
- À utiliser si le conteneur ne répond plus
- ⚠️ Risque de perte de données ou de corruption

> [!warning] Attention
> Utilisez toujours **Shutdown** en priorité. Le **Stop** forcé doit être réservé aux situations d'urgence où le conteneur est bloqué.

#### Redémarrage

**Reboot (redémarrage propre) :**
- Combine shutdown + start
- Permet au système d'exécuter les scripts d'arrêt et de démarrage

### Opérations en ligne de commande

#### Commandes de base

```bash
# Démarrer un conteneur
pct start <vmid>

# Exemples
pct start 100
pct start 101

# Arrêt propre (shutdown)
pct shutdown <vmid>

# Arrêt forcé (stop)
pct stop <vmid>

# Redémarrage propre
pct reboot <vmid>
```

#### Options avancées

```bash
# Démarrage avec timeout personnalisé
pct start <vmid> --timeout 120

# Arrêt avec timeout avant force stop
pct shutdown <vmid> --timeout 120

# Arrêt immédiat sans attente
pct stop <vmid> --skiplock

# Forcer l'arrêt même si verrouillé
pct stop <vmid> --force
```

#### Vérifier l'état d'un conteneur

```bash
# Afficher le statut
pct status <vmid>

# Lister tous les conteneurs avec leur état
pct list

# Format détaillé
pct list | column -t

# Filtrer uniquement les conteneurs actifs
pct list | grep running
```

> [!example] Exemple pratique
> ```bash
> # Arrêter tous les conteneurs en cours d'exécution
> for id in $(pct list | grep running | awk '{print $1}'); do
>     pct shutdown $id
> done
> 
> # Démarrer tous les conteneurs configurés pour le boot
> for id in $(pct list | awk 'NR>1 {print $1}'); do
>     if grep -q "onboot: 1" /etc/pve/lxc/${id}.conf 2>/dev/null; then
>         pct start $id
>     fi
> done
> ```

### Gestion des timeouts

Le timeout par défaut est de 60 secondes. Vous pouvez le modifier :

```bash
# Dans le fichier de configuration du conteneur
# /etc/pve/lxc/<vmid>.conf
startup: order=1,up=60,down=120

# order : ordre de démarrage (1 = premier)
# up : délai d'attente au démarrage (secondes)
# down : délai d'attente à l'arrêt (secondes)
```

> [!tip] Astuce
> Pour les conteneurs hébergeant des bases de données, augmentez le timeout d'arrêt (down) à 180-300 secondes pour permettre une fermeture propre des connexions.

### Pièges courants

| Problème | Cause | Solution |
|----------|-------|----------|
| Conteneur ne démarre pas | Ressources insuffisantes | Vérifier CPU/RAM disponibles |
| Arrêt très lent | Processus bloqués | Identifier avec `pct exec` puis `ps aux` |
| Redémarrage au lieu de stop | onboot=1 activé | Désactiver dans Options |
| Perte de données à l'arrêt | Stop forcé utilisé | Toujours privilégier shutdown |

> [!info] Différence avec les VMs
> Les conteneurs LXC démarrent en 1-3 secondes contre 30-60 secondes pour une VM, car ils ne doivent pas initialiser un noyau complet ni détecter du matériel virtuel.

---

## 💻 Console et accès aux conteneurs

### Types d'accès disponibles

Proxmox offre plusieurs méthodes pour accéder à un conteneur LXC, chacune adaptée à des besoins spécifiques.

### Console via l'interface Web

#### Console interactive

**Accès :**
1. Sélectionnez le conteneur
2. Cliquez sur **Console** dans le menu de gauche
3. Une console s'ouvre dans le navigateur

**Caractéristiques :**
- Console noVNC intégrée au navigateur
- Pas besoin de client SSH
- Idéal pour le dépannage rapide
- Supporte le copier-coller (via menu contextuel)

> [!tip] Raccourci clavier
> `Ctrl+Alt+2` bascule entre la console et le presse-papier dans noVNC. Utile pour copier-coller des commandes.

#### Shell direct (sans login)

```bash
# Via l'interface web : bouton "Shell" au lieu de "Console"
# Accès root direct sans authentification

# En ligne de commande
pct enter <vmid>

# Exemple
pct enter 100
```

> [!warning] Sécurité
> `pct enter` donne un accès root SANS authentification. Ne l'utilisez que depuis l'hôte Proxmox sécurisé. Pour un accès sécurisé, utilisez SSH.

### Exécution de commandes à distance

#### Commande unique

```bash
# Syntaxe de base
pct exec <vmid> -- <commande>

# Exemples pratiques
pct exec 100 -- ls -la /root
pct exec 100 -- apt update
pct exec 100 -- systemctl status nginx
pct exec 100 -- cat /etc/hostname

# Avec redirection
pct exec 100 -- df -h > /root/disk-usage.txt

# Avec pipes (nécessite des guillemets)
pct exec 100 -- bash -c "ps aux | grep nginx"
```

#### Scripts et commandes complexes

```bash
# Exécuter un script depuis l'hôte
pct exec 100 -- bash << 'EOF'
apt update
apt upgrade -y
apt autoremove -y
systemctl restart apache2
EOF

# Passer des variables
HOSTNAME="web-server"
pct exec 100 -- hostnamectl set-hostname "$HOSTNAME"

# Exécuter un script local dans le conteneur
pct push 100 /root/mon-script.sh /tmp/script.sh
pct exec 100 -- chmod +x /tmp/script.sh
pct exec 100 -- /tmp/script.sh
```

> [!example] Automatisation courante
> ```bash
> # Mettre à jour tous les conteneurs
> for id in $(pct list | awk 'NR>1 && $2=="running" {print $1}'); do
>     echo "Mise à jour du conteneur $id..."
>     pct exec $id -- bash -c "apt update && apt upgrade -y"
> done
> ```

### Accès SSH au conteneur

#### Configuration SSH dans le conteneur

```bash
# Entrer dans le conteneur
pct enter 100

# Installer et activer SSH (si nécessaire)
apt update
apt install openssh-server -y
systemctl enable --now ssh

# Configurer SSH (optionnel mais recommandé)
nano /etc/ssh/sshd_config

# Désactiver login root par mot de passe
PermitRootLogin prohibit-password

# Autoriser uniquement les clés SSH
PasswordAuthentication no

# Redémarrer SSH
systemctl restart ssh
```

#### Connexion SSH depuis l'hôte

```bash
# Obtenir l'IP du conteneur
pct exec 100 -- ip -4 addr show eth0 | grep inet

# Se connecter en SSH
ssh root@<IP-conteneur>
ssh user@<IP-conteneur>

# Avec clé SSH
ssh -i ~/.ssh/id_rsa root@<IP-conteneur>
```

#### Copie de fichiers

```bash
# Depuis l'hôte Proxmox vers le conteneur
pct push <vmid> <source-hôte> <destination-conteneur>
pct push 100 /root/config.conf /etc/app/config.conf

# Depuis le conteneur vers l'hôte
pct pull <vmid> <source-conteneur> <destination-hôte>
pct pull 100 /var/log/syslog /root/logs/ct100-syslog

# Avec SCP (via SSH)
scp fichier.txt root@<IP-conteneur>:/root/
scp root@<IP-conteneur>:/etc/hosts /tmp/
```

### Accès aux logs du conteneur

```bash
# Logs du conteneur depuis l'hôte
pct console 100 -e -o /tmp/console.log

# Journal système du conteneur
pct exec 100 -- journalctl -xe

# Logs en temps réel
pct exec 100 -- journalctl -f

# Logs d'un service spécifique
pct exec 100 -- journalctl -u nginx -n 50
```

### Montage de répertoires partagés

#### Bind mount (partage de répertoire hôte → conteneur)

```bash
# Arrêter le conteneur
pct shutdown 100

# Ajouter un point de montage
pct set 100 -mp0 /mnt/shared,mp=/mnt/shared

# Configuration dans /etc/pve/lxc/100.conf
mp0: /mnt/shared,mp=/mnt/shared

# Options avancées
mp0: /mnt/shared,mp=/mnt/shared,backup=0,ro=1
# backup=0 : exclure du backup
# ro=1 : lecture seule

# Démarrer le conteneur
pct start 100
```

> [!warning] Sécurité des bind mounts
> Les bind mounts contournent l'isolation du conteneur. N'utilisez que des répertoires dont vous contrôlez totalement le contenu, sinon le conteneur pourrait accéder à des données sensibles de l'hôte.

### Comparaison des méthodes d'accès

| Méthode | Avantages | Inconvénients | Usage recommandé |
|---------|-----------|---------------|------------------|
| Console Web | Pas de config, toujours disponible | Limité, pas de scripts | Dépannage rapide |
| `pct enter` | Accès root immédiat | Pas de log d'authentification | Administration depuis hôte |
| `pct exec` | Scriptable, automatisation | Une commande à la fois | Scripts de maintenance |
| SSH | Sécurisé, authentification | Config requise | Administration quotidienne |
| Bind mount | Partage de fichiers permanent | Sécurité réduite | Données partagées |

> [!tip] Bonne pratique
> - **Dépannage d'urgence** : Console Web ou `pct enter`
> - **Administration quotidienne** : SSH avec clés
> - **Automatisation** : `pct exec` dans des scripts
> - **Audit et sécurité** : SSH uniquement (logs d'authentification)

---

## 📸 Snapshots et backups

### Snapshots : instantanés du conteneur

#### Qu'est-ce qu'un snapshot ?

Un snapshot est une capture instantanée de l'état complet d'un conteneur à un moment T. Il inclut :
- Le système de fichiers complet
- La configuration du conteneur
- L'état de la mémoire (optionnel, mais rare pour LXC)

> [!info] Différence snapshot vs backup
> - **Snapshot** : instantané sur le même stockage, ultra-rapide, pour tests temporaires
> - **Backup** : copie complète archivée, peut être stockée ailleurs, pour restauration à long terme

#### Création de snapshots via l'interface Web

**Procédure :**
1. Sélectionnez le conteneur
2. Allez dans **Snapshots**
3. Cliquez sur **Take Snapshot**
4. Donnez un nom descriptif : `avant-maj-php`, `config-initiale`, etc.
5. (Optionnel) Ajoutez une description

**Options disponibles :**
- **Name** : nom du snapshot (obligatoire)
- **Description** : commentaire libre
- **Include RAM** : Non applicable pour LXC (réservé aux VMs)

#### Création de snapshots en CLI

```bash
# Créer un snapshot
pct snapshot <vmid> <snapshot-name>

# Exemples
pct snapshot 100 avant-mise-a-jour
pct snapshot 100 config-20241224
pct snapshot 100 "avant-maj" --description "Avant upgrade vers Ubuntu 24.04"

# Lister les snapshots
pct listsnapshot <vmid>
pct listsnapshot 100

# Informations détaillées
pvesm list local-lvm | grep 100
```

#### Restauration d'un snapshot

```bash
# Via CLI
pct rollback <vmid> <snapshot-name>

# Exemple
pct rollback 100 avant-mise-a-jour

# ⚠️ Attention : cette opération est DESTRUCTIVE
# Toutes les modifications après le snapshot seront perdues
```

> [!warning] Restauration destructive
> `pct rollback` écrase définitivement l'état actuel. Si vous avez un doute, créez un snapshot de l'état actuel avant de restaurer un ancien snapshot.

**Via l'interface Web :**
1. Snapshots → Sélectionnez le snapshot
2. Cliquez sur **Rollback**
3. Confirmez (la fenêtre affiche un avertissement)

#### Suppression de snapshots

```bash
# Supprimer un snapshot
pct delsnapshot <vmid> <snapshot-name>

# Exemple
pct delsnapshot 100 avant-mise-a-jour

# Supprimer tous les snapshots (DANGEREUX)
for snap in $(pct listsnapshot 100 | awk 'NR>1 {print $1}'); do
    pct delsnapshot 100 $snap
done
```

> [!tip] Gestion de l'espace
> Les snapshots consomment de l'espace disque proportionnel aux modifications. Supprimez régulièrement les snapshots obsolètes pour libérer de l'espace, surtout avec ZFS ou LVM-thin.

#### Cas d'usage des snapshots

| Scénario | Quand créer | Quand restaurer |
|----------|-------------|-----------------|
| Mise à jour système | Avant `apt upgrade` | Si le système ne boot plus |
| Modification config | Avant édition fichiers critiques | Si la config casse le service |
| Test de logiciel | Avant installation | Si l'app cause des problèmes |
| Changement réseau | Avant modif IP/firewall | Si perte de connectivité |

### Backups : sauvegardes complètes

#### Types de backup disponibles

Proxmox supporte plusieurs modes de backup :

| Mode | Description | Temps | Espace | Conteneur actif |
|------|-------------|-------|--------|-----------------|
| **Snapshot** | Backup à chaud via snapshot | Rapide | Moyen | ✅ Oui |
| **Suspend** | Suspend → backup → reprend | Moyen | Moyen | ⏸️ Pause courte |
| **Stop** | Arrêt → backup → redémarre | Lent | Optimal | ❌ Non |

> [!tip] Recommandation
> - **Production 24/7** : Mode snapshot (backup à chaud)
> - **Services tolérant une pause** : Mode suspend (meilleure cohérence)
> - **Services non critiques** : Mode stop (backup le plus fiable)

#### Création de backup via l'interface Web

**Procédure manuelle :**
1. Sélectionnez le conteneur
2. Cliquez sur **Backup** dans le menu
3. Cliquez sur **Backup now**
4. Configurez les options :
   - **Storage** : choix du stockage (local, NFS, etc.)
   - **Mode** : snapshot / suspend / stop
   - **Compression** : LZO (rapide) / GZIP (économique) / ZSTD (compromis)
   - **Notes** : commentaire optionnel

**Backup programmé (schedule) :**
1. Datacenter → Backup
2. Add → Créer une planification
3. Sélectionnez les conteneurs/VMs
4. Définissez la fréquence (quotidienne, hebdomadaire...)
5. Configurez la rétention (nombre de backups à conserver)

#### Configuration d'un backup job

```bash
# Fichier de configuration backup
# /etc/pve/vzdump.cron

# Backup quotidien à 2h du matin, garder 7 backups
0 2 * * * root vzdump --mode snapshot --compress zstd --storage backup-nfs --maxfiles 7 --all 1

# Backup spécifique de certains conteneurs
0 3 * * * root vzdump 100 101 102 --mode snapshot --storage local --compress lzo --maxfiles 14

# Avec notification email
0 2 * * * root vzdump --mode snapshot --mailto admin@example.com --mailnotification always --all 1
```

#### Création de backup en CLI

```bash
# Backup simple
vzdump <vmid>

# Backup avec options
vzdump <vmid> --mode snapshot --storage local --compress zstd

# Exemples complets
# Backup d'un conteneur spécifique
vzdump 100 --mode snapshot --storage backup-nfs --compress zstd

# Backup de plusieurs conteneurs
vzdump 100 101 102 --mode suspend --compress lzo

# Backup de tous les conteneurs
vzdump --all 1 --mode snapshot

# Backup avec rétention
vzdump 100 --mode snapshot --storage local --maxfiles 7

# Options de compression
vzdump 100 --compress lzo      # Rapide, compression faible
vzdump 100 --compress gzip     # Lent, compression forte
vzdump 100 --compress zstd     # Équilibré (recommandé)
```

#### Options avancées de backup

```bash
# Backup avec exclusion de points de montage
vzdump 100 --mode snapshot --exclude-path /mnt/

# Backup avec notification
vzdump 100 --mailto admin@domain.com --mailnotification always

# Backup avec bande passante limitée (en KB/s)
vzdump 100 --bwlimit 10000

# Backup avec script pre/post
vzdump 100 --script /usr/local/bin/backup-hook.sh

# Mode protect (empêche la suppression accidentelle)
vzdump 100 --protected 1
```

#### Restauration d'un backup

**Via l'interface Web :**
1. Sélectionnez le stockage contenant les backups
2. Allez dans **Content**
3. Sélectionnez le backup (fichier .tar.zst ou .vma)
4. Cliquez sur **Restore**
5. Choisissez :
   - Restaurer sur place (écrase le conteneur)
   - Créer un nouveau conteneur (change le VMID)

**Via CLI :**

```bash
# Lister les backups disponibles
pvesm list <storage>
pvesm list local | grep vzdump

# Restaurer un backup (écrase le conteneur existant)
pct restore <vmid> <backup-path>

# Exemple
pct restore 100 /var/lib/vz/dump/vzdump-lxc-100-2024_12_24-02_00_00.tar.zst

# Restaurer vers un nouveau conteneur (nouveau VMID)
pct restore 105 /var/lib/vz/dump/vzdump-lxc-100-2024_12_24-02_00_00.tar.zst

# Restaurer avec options
pct restore 100 /path/to/backup.tar.zst \
  --storage local-lvm \
  --force 1 \
  --unprivileged 1

# Restaurer uniquement certains fichiers (extraction manuelle)
tar -xvf vzdump-lxc-100-*.tar.zst -C /tmp/restore
```

> [!example] Script de restauration d'urgence
> ```bash
> #!/bin/bash
> # restore-container.sh
> 
> VMID=$1
> BACKUP_DIR="/var/lib/vz/dump"
> 
> # Trouver le backup le plus récent
> LATEST_BACKUP=$(ls -t $BACKUP_DIR/vzdump-lxc-${VMID}-*.tar.zst | head -1)
> 
> echo "Restauration de : $LATEST_BACKUP"
> 
> # Arrêter le conteneur s'il tourne
> pct stop $VMID 2>/dev/null
> 
> # Restaurer
> pct restore $VMID "$LATEST_BACKUP" --force 1
> 
> # Démarrer
> pct start $VMID
> 
> echo "Restauration terminée"
> ```

### Stratégies de backup recommandées

#### Règle 3-2-1

Une stratégie professionnelle suit la règle 3-2-1 :
- **3** copies de vos données (production + 2 backups)
- **2** types de supports différents (local + NFS/Ceph)
- **1** copie hors site (distant/cloud)

#### Rétention selon criticité

```bash
# Conteneurs critiques (production)
vzdump <vmid> --maxfiles 30  # 30 jours de backups quotidiens

# Conteneurs importants (staging)
vzdump <vmid> --maxfiles 14  # 14 jours

# Conteneurs de dev/test
vzdump <vmid> --maxfiles 7   # 7 jours

# Configuration avec rotation complète
# 7 backups quotidiens + 4 hebdomadaires + 6 mensuels
# À configurer via un script personnalisé ou un outil comme proxmox-backup-server
```

#### Planification typique

| Environnement | Fréquence | Mode | Rétention | Compression |
|---------------|-----------|------|-----------|-------------|
| Production DB | Quotidien 2h | Snapshot | 30 jours | ZSTD |
| Production Web | Quotidien 3h | Snapshot | 14 jours | ZSTD |
| Staging | Hebdomadaire | Suspend | 4 backups | LZO |
| Dev/Test | Mensuel | Stop | 3 backups | GZIP |

### Stockage des backups

#### Emplacements recommandés

```bash
# Storage local (rapide, mais pas de redondance)
/var/lib/vz/dump/

# NFS (partagé entre nœuds)
pvesm add nfs backup-nfs --server 192.168.1.10 --export /backup

# CIFS/SMB (Windows share)
pvesm add cifs backup-smb --server nas.local --share backups --username proxmox

# Proxmox Backup Server (déduplication, chiffrement)
pvesm add pbs backup-pbs --server backup.local --datastore proxmox
```

> [!warning] Jamais sur le même disque que la production !
> Ne stockez JAMAIS vos backups sur le même disque/array que vos conteneurs en production. En cas de panne matérielle, vous perdriez tout.

### Pièges courants

| Problème | Cause | Solution |
|----------|-------|----------|
| Backup échoue avec "locked" | Snapshot ou backup en cours | Attendre ou supprimer le lock : `rm /var/lock/vzdump*` |
| Snapshots prennent beaucoup d'espace | Nombreuses modifications | Supprimer les snapshots anciens |
| Backup très lent | Compression GZIP + gros volume | Utiliser LZO ou ZSTD |
| Restauration échoue | Backup corrompu | Vérifier l'intégrité : `tar -tzf backup.tar.gz` |
| Snapshots impossibles | Stockage ne supporte pas | Utiliser mode suspend ou stop |

> [!tip] Vérification de l'intégrité
> Testez régulièrement vos backups en les restaurant sur un conteneur de test. Un backup non testé n'est pas un backup fiable !

---

## 🧬 Clonage de conteneurs

### Principe du clonage

Le clonage permet de créer une copie exacte d'un conteneur existant avec un nouveau VMID. Deux modes sont disponibles :
- **Clone complet** : copie indépendante, consomme autant d'espace que l'original
- **Clone lié** : référence l'original, économise l'espace (avec stockages compatibles)

> [!info] Différence clonage vs backup/restore
> Le clonage est plus rapide et plus direct qu'un backup/restore. Il est idéal pour dupliquer rapidement un environnement de test ou créer des conteneurs similaires.

### Clonage via l'interface Web

**Procédure :**
1. Cliquez droit sur le conteneur source
2. Sélectionnez **Clone**
3. Configurez les paramètres :
   - **Target Node** : nœud de destination
   - **VM ID** : nouveau VMID (obligatoire, unique)
   - **Hostname** : nouveau nom d'hôte (recommandé)
   - **Mode** : Full clone ou Linked clone
   - **Storage** : stockage de destination
   - **Description** : description optionnelle

> [!warning] Clonage et conteneur actif
> Il est possible de cloner un conteneur en cours d'exécution, mais la cohérence des données n'est pas garantie. Pour une cohérence maximale, arrêtez ou faites un snapshot du conteneur avant de cloner.

### Clonage en ligne de commande

#### Clone complet

```bash
# Syntaxe de base
pct clone <vmid-source> <vmid-nouveau> --hostname <nouveau-nom>

# Exemple simple
pct clone 100 110 --hostname web-clone

# Clone avec tous les paramètres
pct clone 100 110 \
  --hostname web-prod-02 \
  --description "Clone du serveur web principal" \
  --full 1 \
  --storage local-lvm \
  --pool production

# Options disponibles
# --full 1 : clone complet (défaut)
# --storage <nom> : stockage cible
# --pool <nom> : associer à un pool de ressources
# --description "..." : description du nouveau conteneur
# --snapname <nom> : cloner depuis un snapshot spécifique
```

#### Clone lié (linked clone)

```bash
# Clone lié (nécessite un stockage supportant les snapshots : ZFS, LVM-thin, Ceph)
pct clone 100 111 \
  --hostname web-dev \
  --full 0

# Clone lié depuis un snapshot existant
pct clone 100 112 \
  --hostname web-test \
  --snapname config-initiale \
  --full 0
```

> [!tip] Quand utiliser un clone lié ?
> Les clones liés sont parfaits pour :
> - Environnements de développement temporaires
> - Tests rapides nécessitant peu de modifications
> - Économie d'espace disque
> 
> ⚠️ Le conteneur source ne peut pas être supprimé tant que des clones liés existent.

### Comparaison des modes de clonage

| Caractéristique | Clone complet | Clone lié |
|-----------------|---------------|-----------|
| Espace disque | Égal à l'original | Minimal (delta uniquement) |
| Indépendance | Totale | Dépend du parent |
| Performance | Identique à l'original | Légèrement réduite |
| Suppression parent | Possible | Impossible |
| Vitesse de création | Lente (copie complète) | Rapide (snapshot) |
| Stockages compatibles | Tous | ZFS, LVM-thin, Ceph |

### Post-clonage : personnalisation

Après un clonage, certaines modifications sont nécessaires pour éviter les conflits :

#### Changements automatiques

```bash
# Proxmox change automatiquement :
# - VMID (nouveau ID unique)
# - Hostname (si spécifié avec --hostname)
```

#### Changements manuels recommandés

```bash
# Entrer dans le nouveau conteneur
pct enter 110

# 1. Modifier l'adresse IP (si DHCP n'est pas utilisé)
nano /etc/network/interfaces

# Configuration statique IPv4
auto eth0
iface eth0 inet static
    address 192.168.1.21/24
    gateway 192.168.1.1
    dns-nameservers 8.8.8.8

# Redémarrer le réseau
systemctl restart networking

# 2. Changer le hostname (si pas fait pendant le clone)
hostnamectl set-hostname web-clone
nano /etc/hosts
# Modifier 127.0.1.1 avec le nouveau hostname

# 3. Régénérer les clés SSH (IMPORTANT pour la sécurité)
rm /etc/ssh/ssh_host_*
dpkg-reconfigure openssh-server

# 4. Changer le machine-id (pour éviter les conflits)
rm /etc/machine-id /var/lib/dbus/machine-id
dbus-uuidgen --ensure=/etc/machine-id
dbus-uuidgen --ensure=/var/lib/dbus/machine-id

# 5. Vider les logs anciens (optionnel)
journalctl --rotate
journalctl --vacuum-time=1s

# 6. Nettoyer l'historique bash (optionnel)
history -c
rm ~/.bash_history
```

> [!warning] Sécurité critique : régénérer les clés SSH
> Si vous ne régénérez pas les clés SSH, le clone aura les MÊMES clés que l'original. Cela représente un risque de sécurité majeur. Toujours exécuter `dpkg-reconfigure openssh-server` après un clonage.

#### Script de post-clonage automatisé

```bash
#!/bin/bash
# post-clone-setup.sh
# À exécuter dans le conteneur cloné

NEW_HOSTNAME=$1
NEW_IP=$2

if [ -z "$NEW_HOSTNAME" ] || [ -z "$NEW_IP" ]; then
    echo "Usage: $0 <hostname> <ip>"
    exit 1
fi

echo "=== Configuration post-clonage ==="

# Hostname
echo "Changement du hostname..."
hostnamectl set-hostname $NEW_HOSTNAME
sed -i "s/127.0.1.1.*/127.0.1.1\t$NEW_HOSTNAME/" /etc/hosts

# IP statique
echo "Configuration de l'IP..."
cat > /etc/network/interfaces << EOF
auto lo
iface lo inet loopback

auto eth0
iface eth0 inet static
    address $NEW_IP/24
    gateway 192.168.1.1
    dns-nameservers 8.8.8.8 8.8.4.4
EOF

# Clés SSH
echo "Régénération des clés SSH..."
rm -f /etc/ssh/ssh_host_*
dpkg-reconfigure -f noninteractive openssh-server

# Machine ID
echo "Régénération du machine-id..."
rm -f /etc/machine-id /var/lib/dbus/machine-id
dbus-uuidgen --ensure=/etc/machine-id
dbus-uuidgen --ensure=/var/lib/dbus/machine-id

# Nettoyage
echo "Nettoyage des logs..."
journalctl --rotate
journalctl --vacuum-time=1s
history -c

echo "=== Configuration terminée ==="
echo "Redémarrez le conteneur : pct reboot <vmid>"
```

### Clonage vers un autre nœud (cluster)

Dans un cluster Proxmox, vous pouvez cloner un conteneur directement vers un autre nœud :

```bash
# Clone vers un autre nœud
pct clone 100 210 \
  --hostname web-node2 \
  --target node2 \
  --storage local-lvm \
  --full 1

# Vérifier la progression
pct status 210 -node node2
```

> [!info] Migration vs Clonage
> - **Clonage vers autre nœud** : crée une copie, l'original reste
> - **Migration** : déplace le conteneur, supprime l'original du nœud source

### Clonage à partir d'un template

```bash
# Créer un template depuis un conteneur
pct template <vmid>

# Exemple
pct template 100
# Le conteneur 100 devient un template (non démarrable)

# Cloner depuis le template
pct clone 100 120 --hostname web-from-template --full 1

# Les templates sont marqués dans la liste
pct list
# VMID    STATUS      NAME
# 100     template    ubuntu-template
# 120     running     web-from-template
```

> [!tip] Workflow avec templates
> 1. Créez un conteneur de base avec votre configuration standard
> 2. Convertissez-le en template avec `pct template`
> 3. Clonez ce template pour créer rapidement de nouveaux conteneurs
> 4. Mettez à jour le template périodiquement (le reconvertir en conteneur, mettre à jour, re-template)

### Clonage avec modification de ressources

```bash
# Cloner et modifier les ressources en une commande
pct clone 100 130 --hostname web-large --full 1

# Puis modifier immédiatement les ressources
pct set 130 --cores 4 --memory 4096 --rootfs local-lvm:32

# Ou tout en un avec un script
pct clone 100 130 --hostname web-large --full 1 && \
pct set 130 --cores 4 --memory 4096 && \
pct start 130
```

### Cas d'usage courants du clonage

| Scénario | Type de clone | Configuration |
|----------|---------------|---------------|
| Environnement de test | Lié | Clone rapide, faible durée de vie |
| Mise en production | Complet | Indépendant, haute disponibilité |
| Développement multi-dev | Lié | Plusieurs devs, même base |
| Backup pré-migration | Complet | Sécurité avant changement majeur |
| Template de déploiement | Complet | Base pour nouveaux projets |

> [!example] Workflow de déploiement automatisé
> ```bash
> #!/bin/bash
> # deploy-web-server.sh
> 
> TEMPLATE_ID=100
> NEW_ID=$1
> HOSTNAME=$2
> IP=$3
> 
> # Cloner depuis le template
> pct clone $TEMPLATE_ID $NEW_ID --hostname $HOSTNAME --full 1
> 
> # Configurer les ressources
> pct set $NEW_ID --cores 2 --memory 2048
> 
> # Démarrer
> pct start $NEW_ID
> 
> # Attendre le démarrage
> sleep 5
> 
> # Configuration post-clone
> pct exec $NEW_ID -- bash -c "
>     sed -i 's/address .*/address $IP\/24/' /etc/network/interfaces
>     hostnamectl set-hostname $HOSTNAME
>     rm /etc/ssh/ssh_host_*
>     dpkg-reconfigure -f noninteractive openssh-server
>     systemctl restart networking
> "
> 
> echo "Conteneur $NEW_ID déployé : $HOSTNAME ($IP)"
> ```

### Pièges courants lors du clonage

| Problème | Cause | Solution |
|----------|-------|----------|
| Conflit IP | Même IP que l'original | Toujours changer l'IP après clonage |
| Clés SSH identiques | Pas régénérées | `dpkg-reconfigure openssh-server` |
| Services ne démarrent pas | Conflits de ports/IPs | Vérifier la config réseau et services |
| Clone lié ne démarre pas | Parent supprimé ou modifié | Utiliser un clone complet |
| Espace disque plein | Clone complet sur petit stockage | Vérifier l'espace avant de cloner |

---

## 🚚 Migration de conteneurs

### Types de migration

Proxmox offre deux types de migration pour les conteneurs LXC :

#### Migration offline (à froid)

- Le conteneur est **arrêté** pendant la migration
- Transfert du stockage vers le nœud cible
- Redémarrage sur le nouveau nœud
- Temps d'arrêt = durée du transfert

#### Migration online (à chaud)

- Le conteneur reste **actif** pendant la migration
- Utilise CRIU (Checkpoint/Restore In Userspace)
- Minimise le temps d'arrêt (quelques secondes)
- ⚠️ Nécessite des conditions spécifiques

> [!warning] Limitations de la migration à chaud
> La migration online n'est pas toujours possible pour LXC. Elle nécessite :
> - Conteneurs privilégiés (pas unprivileged)
> - Noyaux compatibles entre les nœuds
> - Pas de périphériques particuliers montés
> - Configurations réseau compatibles

### Migration via l'interface Web

**Procédure :**
1. Cliquez droit sur le conteneur
2. Sélectionnez **Migrate**
3. Configurez les options :
   - **Target node** : nœud de destination
   - **Mode** : Online ou Offline
   - **Target storage** : stockage sur le nœud cible
   - **Online** : cocher pour migration à chaud (si possible)
   - **With local disks** : migrer aussi les disques locaux
   - **Delete source** : supprimer du nœud source après migration

4. Cliquez sur **Migrate**
5. Suivez la progression dans les **Tasks**

> [!tip] Vérification préalable
> Avant de migrer, vérifiez que le nœud cible a suffisamment de ressources (CPU, RAM, stockage) pour accueillir le conteneur.

### Migration en ligne de commande

#### Migration offline (recommandée)

```bash
# Syntaxe de base
pct migrate <vmid> <target-node>

# Migration simple
pct migrate 100 node2

# Migration avec options
pct migrate 100 node2 \
  --online 0 \
  --storage local-lvm \
  --target-storage local-lvm

# Migration avec transfert du stockage local
pct migrate 100 node2 \
  --target-storage node2-storage
```

#### Migration online (à chaud)

```bash
# Tenter une migration à chaud
pct migrate 100 node2 --online 1

# Si la migration à chaud échoue, Proxmox bascule automatiquement en offline
# Pour forcer offline dès le départ :
pct migrate 100 node2 --online 0
```

#### Options avancées de migration

```bash
# Migration avec bande passante limitée (en MB/s)
pct migrate 100 node2 --bwlimit 50

# Migration sans redémarrage après transfert
pct migrate 100 node2 --restart 0

# Migration avec timeout personnalisé (secondes)
pct migrate 100 node2 --timeout 300

# Migration forcée (ignore certains warnings)
pct migrate 100 node2 --force 1

# Migration avec stockage différent sur la cible
pct migrate 100 node2 \
  --targetstorage "local-lvm:zfs-pool,backup-nfs:ceph-storage"
```

### Migration avec stockage partagé vs local

#### Stockage partagé (NFS, Ceph, GlusterFS)

Avec un stockage partagé, la migration est **quasi instantanée** :

```bash
# Les données sont déjà accessibles sur le nœud cible
# Seule la configuration est transférée

pct migrate 100 node2
# Migration en quelques secondes
```

**Avantages :**
- Migration très rapide (secondes)
- Pas de transfert de données
- Idéal pour haute disponibilité

**Inconvénients :**
- Nécessite infrastructure de stockage partagé
- Point de défaillance unique (le stockage)

#### Stockage local (LVM, ZFS local, Directory)

Avec un stockage local, les données doivent être copiées :

```bash
# Transfert complet du système de fichiers

pct migrate 100 node2 --target-storage local-lvm
# Durée dépend de la taille et de la bande passante
```

**Durée estimée :**
- 10 GB à 1 Gbps réseau : ~2-3 minutes
- 50 GB à 1 Gbps réseau : ~10-15 minutes
- 100 GB à 10 Gbps réseau : ~2-3 minutes

> [!tip] Optimisation du transfert
> Pour accélérer la migration avec stockage local :
> - Utilisez un réseau dédié 10 Gbps pour les migrations
> - Désactivez la compression si CPU limité
> - Limitez les I/O sur le stockage pendant la migration

### Vérification post-migration

```bash
# Vérifier que le conteneur est sur le bon nœud
pct list --node node2 | grep 100

# Vérifier l'état du conteneur
pct status 100

# Démarrer si arrêté
pct start 100

# Tester la connectivité
pct exec 100 -- ip a
pct exec 100 -- ping -c 3 8.8.8.8

# Vérifier les logs
pct exec 100 -- journalctl -n 50
```

### Migration en masse (bulk migration)

```bash
# Migrer tous les conteneurs d'un nœud vers un autre
for vmid in $(pct list --node node1 | awk 'NR>1 {print $1}'); do
    echo "Migration du conteneur $vmid vers node2..."
    pct migrate $vmid node2 --online 0
    sleep 5  # Pause entre chaque migration
done

# Migrer uniquement les conteneurs actifs
for vmid in $(pct list --node node1 | grep running | awk '{print $1}'); do
    pct migrate $vmid node2
done
```

> [!example] Script de migration avec vérification
> ```bash
> #!/bin/bash
> # migrate-containers.sh
> 
> SOURCE_NODE=$1
> TARGET_NODE=$2
> 
> if [ -z "$SOURCE_NODE" ] || [ -z "$TARGET_NODE" ]; then
>     echo "Usage: $0 <source-node> <target-node>"
>     exit 1
> fi
> 
> echo "=== Migration de $SOURCE_NODE vers $TARGET_NODE ==="
> 
> # Liste des conteneurs
> CONTAINERS=$(pct list --node $SOURCE_NODE | awk 'NR>1 {print $1}')
> 
> for vmid in $CONTAINERS; do
>     STATUS=$(pct status $vmid --node $SOURCE_NODE | awk '{print $2}')
>     echo ""
>     echo "Conteneur $vmid (status: $STATUS)"
>     
>     # Vérifier l'espace disponible sur la cible
>     SIZE=$(du -sh /var/lib/lxc/$vmid 2>/dev/null | awk '{print $1}')
>     echo "Taille: $SIZE"
>     
>     # Migrer
>     echo "Migration en cours..."
>     if pct migrate $vmid $TARGET_NODE --online 0; then
>         echo "✓ Migration réussie"
>     else
>         echo "✗ Échec de la migration"
>         continue
>     fi
>     
>     # Vérifier
>     sleep 3
>     if [ "$STATUS" == "running" ]; then
>         pct start $vmid --node $TARGET_NODE
>         echo "✓ Conteneur redémarré"
>     fi
> done
> 
> echo ""
> echo "=== Migration terminée ==="
> ```

### Migration pour maintenance

Scénario typique : vider un nœud pour maintenance matérielle

```bash
# 1. Empêcher le démarrage de nouveaux conteneurs sur le nœud
# (via l'interface : Node → Options → Status → Set to Maintenance)

# 2. Migrer tous les conteneurs actifs
for vmid in $(pct list --node node1 | grep running | awk '{print $1}'); do
    echo "Migration CT $vmid..."
    pct migrate $vmid node2 --online 0
done

# 3. Vérifier qu'il n'y a plus de conteneurs actifs
pct list --node node1

# 4. Mettre le nœud en maintenance ou l'éteindre
# shutdown -h now
```

### Cas d'usage de la migration

| Scénario | Type | Raison |
|----------|------|--------|
| Maintenance matérielle | Offline | Vidage complet du nœud |
| Équilibrage de charge | Online/Offline | Répartir les ressources |
| Mise à jour noyau | Offline | Redémarrage nœud requis |
| Panne matérielle imminente | Online | Minimiser l'interruption |
| Consolidation | Offline | Réduire le nombre de nœuds actifs |
| Test de HA | Online | Vérifier la résilience |

### Migration vs autres opérations

| Opération | Données | Temps d'arrêt | VMID change |
|-----------|---------|---------------|-------------|
| **Migration** | Déplacées | Minimal/Nul | Non |
| **Clonage** | Copiées | Aucun | Oui |
| **Backup/Restore** | Archivées | Important | Optionnel |
| **Réplication** | Synchronisées | Aucun | Non |

### Troubleshooting des migrations

#### Échec de migration à chaud

```bash
# Message d'erreur typique
# "online migration failed, switching to offline"

# Solutions :
# 1. Forcer la migration offline
pct migrate 100 node2 --online 0

# 2. Vérifier la compatibilité CRIU
pct migrate 100 node2 --online 1 --force 1

# 3. Convertir en conteneur privilégié (si acceptable)
pct set 100 --unprivileged 0
pct reboot 100
pct migrate 100 node2 --online 1
```

#### Migration bloquée

```bash
# Vérifier le statut de la tâche
pvesh get /cluster/tasks

# Tuer une tâche bloquée (en dernier recours)
# ID de la tâche visible dans Tasks
# kill -9 <PID>

# Supprimer le verrou
pct unlock 100
```

#### Erreur de réseau après migration

```bash
# Vérifier la configuration réseau
pct config 100 | grep net

# Entrer dans le conteneur
pct enter 100

# Vérifier et redémarrer le réseau
ip a
systemctl restart networking

# Si nécessaire, reconfigurer le bridge
nano /etc/pve/lxc/100.conf
# net0: name=eth0,bridge=vmbr0,ip=dhcp
```

### Pièges courants lors des migrations

| Problème | Cause | Solution |
|----------|-------|----------|
| Migration échoue "storage not available" | Stockage non partagé/non accessible | Vérifier que le stockage existe sur la cible |
| Conteneur ne démarre pas après migration | Config réseau incompatible | Adapter la config réseau (bridge, VLAN) |
| Migration online échoue | Conteneur unprivileged | Utiliser --online 0 |
| Très lente | Réseau 1 Gbps saturé | Utiliser --bwlimit ou réseau dédié |
| Échec "not enough space" | Espace insuffisant sur cible | Libérer de l'espace ou changer de stockage |

> [!tip] Bonnes pratiques de migration
> - **Planifiez** : migrez pendant les heures creuses
> - **Testez** : faites un test avec un conteneur non critique
> - **Surveillez** : observez les performances réseau et I/O
> - **Vérifiez** : testez toujours le conteneur après migration
> - **Documentez** : notez les migrations pour l'audit

---

## 📊 Récapitulatif des commandes essentielles

### Gestion du cycle de vie

```bash
# Démarrage / Arrêt
pct start <vmid>
pct shutdown <vmid>
pct stop <vmid>
pct reboot <vmid>
pct status <vmid>
```

### Accès et console

```bash
# Console et shell
pct enter <vmid>
pct exec <vmid> -- <commande>
pct console <vmid>

# Transfert de fichiers
pct push <vmid> <source> <destination>
pct pull <vmid> <source> <destination>
```

### Snapshots

```bash
# Gestion des snapshots
pct snapshot <vmid> <snapshot-name>
pct listsnapshot <vmid>
pct rollback <vmid> <snapshot-name>
pct delsnapshot <vmid> <snapshot-name>
```

### Backups

```bash
# Création de backups
vzdump <vmid> --mode snapshot --compress zstd --storage <storage>
vzdump --all 1 --mode snapshot

# Restauration
pct restore <vmid> <backup-path>
```

### Clonage

```bash
# Clonage
pct clone <vmid-source> <vmid-cible> --hostname <nom>
pct clone <vmid> <nouveau-vmid> --full 1  # Clone complet
pct clone <vmid> <nouveau-vmid> --full 0  # Clone lié
pct template <vmid>  # Convertir en template
```

### Migration

```bash
# Migration entre nœuds
pct migrate <vmid> <target-node>
pct migrate <vmid> <target-node> --online 1  # À chaud
pct migrate <vmid> <target-node> --target-storage <storage>
```

---

## 🎯 Points clés à retenir

> [!info] Résumé des concepts essentiels
> 
> **Démarrage/Arrêt :**
> - Privilégiez toujours `shutdown` à `stop` pour éviter la corruption de données
> - Les conteneurs LXC démarrent quasi instantanément (1-3 secondes)
> - Utilisez `onboot=1` pour le démarrage automatique
> 
> **Console et accès :**
> - `pct enter` pour un accès root direct depuis l'hôte
> - `pct exec` pour l'automatisation et les scripts
> - SSH pour l'administration quotidienne sécurisée
> - Régénérez toujours les clés SSH après clonage
> 
> **Snapshots :**
> - Création instantanée, idéal avant modifications importantes
> - Consomme de l'espace proportionnel aux modifications
> - Supprimez les snapshots obsolètes régulièrement
> 
> **Backups :**
> - Mode **snapshot** pour production 24/7
> - Mode **stop** pour cohérence maximale (si tolérable)
> - Respectez la règle 3-2-1 (3 copies, 2 supports, 1 hors site)
> - Testez régulièrement vos restaurations
> 
> **Clonage :**
> - **Clone complet** : indépendant, recommandé pour la production
> - **Clone lié** : économise l'espace, parfait pour les tests temporaires
> - Personnalisez toujours : IP, hostname, clés SSH, machine-id
> 
> **Migration :**
> - **Avec stockage partagé** : migration en secondes
> - **Avec stockage local** : transfert complet nécessaire
> - Migration **offline** recommandée pour LXC (plus fiable)
> - Vérifiez toujours le conteneur après migration

---

*Cours rédigé pour Proxmox VE - Partie : Gestion des conteneurs LXC*