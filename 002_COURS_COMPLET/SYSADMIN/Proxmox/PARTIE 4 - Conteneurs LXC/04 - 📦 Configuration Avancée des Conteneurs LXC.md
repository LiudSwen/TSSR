

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

## 🗂️ Points de montage (Mount Points)

### Concept et utilité

Les points de montage permettent d'attacher du stockage supplémentaire à un conteneur LXC. Contrairement au disque racine du conteneur, ces volumes peuvent être :

- Partagés entre plusieurs conteneurs
- Montés/démontés dynamiquement
- Redimensionnés sans arrêter le conteneur
- Sauvegardés indépendamment

> [!info] Différence avec les VM Dans les conteneurs LXC, les points de montage sont beaucoup plus flexibles que dans les VM car ils utilisent directement le système de fichiers de l'hôte plutôt qu'une émulation complète de disque.

### Types de points de montage

|Type|Description|Cas d'usage|
|---|---|---|
|**Volume**|Stockage géré par Proxmox|Données persistantes, bases de données|
|**Bind Mount**|Répertoire de l'hôte monté directement|Partage de fichiers, configuration centralisée|
|**Device**|Périphérique physique|Disques externes, USB|

### Configuration via Proxmox

#### Via l'interface web

1. Sélectionner le conteneur
2. Aller dans **Resources** → **Add** → **Mount Point**
3. Configurer les paramètres :

> [!example] Paramètres d'un point de montage
> 
> - **Storage** : Emplacement du stockage (local-lvm, nfs, etc.)
> - **Disk size** : Taille du volume
> - **Mount point** : Chemin dans le conteneur (ex: `/mnt/data`)
> - **ACL** : Activer les ACL POSIX
> - **Quota** : Activer les quotas utilisateur
> - **Backup** : Inclure dans les sauvegardes

#### Via la ligne de commande

```bash
# Ajouter un nouveau point de montage
pct set <CTID> -mp0 /chemin/hote,mp=/chemin/conteneur

# Exemple : Ajouter un volume de 50GB
pct set 100 -mp0 local-lvm:50,mp=/mnt/data

# Exemple : Bind mount d'un répertoire existant
pct set 100 -mp0 /mnt/nas/shared,mp=/mnt/shared
```

> [!warning] Numérotation des mount points Les points de montage sont numérotés de `mp0` à `mp255`. Le système racine utilise `mp0` dans certaines configurations, donc commencez généralement par `mp1` pour éviter les conflits.

### Configuration manuelle

Le fichier de configuration du conteneur se trouve dans `/etc/pve/lxc/<CTID>.conf` :

```bash
# Volume géré par Proxmox
mp0: local-lvm:vm-100-disk-1,mp=/mnt/data,size=50G

# Bind mount simple
mp1: /mnt/nas/shared,mp=/mnt/shared

# Bind mount en lecture seule
mp2: /mnt/backup,mp=/mnt/backup,ro=1

# Avec ACL et quota activés
mp3: local-lvm:vm-100-disk-2,mp=/var/lib/mysql,acl=1,quota=1,size=100G
```

### Options avancées

#### Options de montage principales

```bash
# Syntaxe complète
mp<N>: <STORAGE>:<SIZE>,mp=<PATH>[,acl=<1|0>][,backup=<1|0>][,quota=<1|0>][,replicate=<1|0>][,ro=<1|0>][,shared=<1|0>]
```

|Option|Description|Valeurs|
|---|---|---|
|`acl`|Active les ACL POSIX|0 ou 1|
|`backup`|Inclure dans les backups|0 ou 1 (défaut)|
|`quota`|Active les quotas utilisateur|0 ou 1|
|`replicate`|Active la réplication|0 ou 1|
|`ro`|Lecture seule|0 ou 1|
|`shared`|Stockage partagé (cluster)|0 ou 1|

> [!example] Exemple de configuration avancée
> 
> ```bash
> # Point de montage pour base de données avec ACL et quotas
> pct set 100 -mp1 local-lvm:100,mp=/var/lib/postgresql,acl=1,quota=1,backup=1
> 
> # Partage NFS en lecture seule
> pct set 100 -mp2 /mnt/nfs/documents,mp=/mnt/docs,ro=1,backup=0
> 
> # Stockage partagé pour cluster
> pct set 100 -mp3 ceph-storage:50,mp=/mnt/shared,shared=1
> ```

#### Redimensionnement d'un volume

```bash
# Augmenter la taille d'un volume (ne peut pas réduire)
pct resize 100 mp1 +20G

# Vérifier la taille actuelle
pct config 100 | grep mp1
```

> [!tip] Redimensionnement à chaud Le redimensionnement peut se faire pendant que le conteneur est en cours d'exécution. Le système de fichiers sera automatiquement étendu dans la plupart des cas.

#### Déplacement d'un volume

```bash
# Déplacer un volume vers un autre stockage
pct move-volume 100 mp1 target-storage

# Avec suppression du volume source après migration
pct move-volume 100 mp1 target-storage --delete
```

### Bonnes pratiques {#bonnes-pratiques-montage}

> [!tip] Séparation des données Placez les données importantes sur des points de montage séparés plutôt que sur le disque racine. Cela facilite les sauvegardes sélectives et les migrations.

> [!warning] Permissions et propriété Lors de l'utilisation de bind mounts, vérifiez que les UID/GID du conteneur correspondent à ceux de l'hôte. Les conteneurs unprivileged mappent les UID, ce qui peut causer des problèmes de permissions.

```bash
# Vérifier le mapping des UID dans le conteneur
cat /etc/subuid
cat /etc/subgid

# Exemple de mapping : L'utilisateur 0 du conteneur devient 100000 sur l'hôte
# root:100000:65536
```

> [!tip] Organisation des points de montage
> 
> - `mp1` : Données applicatives principales
> - `mp2` : Logs et fichiers temporaires
> - `mp3` : Bases de données
> - `mp4+` : Autres besoins spécifiques

---

## 🔄 Partage de ressources

### Bind mounts

Les bind mounts permettent de monter un répertoire de l'hôte directement dans le conteneur. C'est la méthode la plus efficace pour partager des données entre l'hôte et les conteneurs.

#### Configuration de base

```bash
# Monter un répertoire de l'hôte
pct set 100 -mp0 /srv/data,mp=/mnt/data

# Plusieurs options de montage
pct set 100 -mp0 /srv/data,mp=/mnt/data,ro=1,backup=0
```

#### Configuration dans le fichier de conf

```bash
# /etc/pve/lxc/100.conf
mp0: /srv/data,mp=/mnt/data
mp1: /backup,mp=/backup,ro=1
mp2: /media/usb,mp=/media/usb,backup=0
```

> [!warning] Problèmes de permissions avec conteneurs unprivileged Dans un conteneur unprivileged, les UID sont mappés. L'utilisateur root (UID 0) du conteneur correspond à l'UID 100000 sur l'hôte par défaut.

#### Solution : Utilisation des ID maps

Pour résoudre les problèmes de permissions, vous pouvez mapper des UID/GID spécifiques :

```bash
# /etc/pve/lxc/100.conf
# Mapper l'UID 1000 du conteneur vers l'UID 1000 de l'hôte
lxc.idmap: u 0 100000 1000
lxc.idmap: g 0 100000 1000
lxc.idmap: u 1000 1000 1
lxc.idmap: g 1000 1000 1
lxc.idmap: u 1001 101001 64535
lxc.idmap: g 1001 101001 64535
```

> [!example] Explication du mapping
> 
> - Les 1000 premiers UID (0-999) sont mappés vers 100000-100999 sur l'hôte
> - L'UID 1000 du conteneur est mappé directement vers l'UID 1000 de l'hôte
> - Les UID suivants (1001-65535) sont mappés vers 101001-165535 sur l'hôte

#### Ajustement des permissions sur l'hôte

```bash
# Méthode 1 : Changer le propriétaire sur l'hôte pour correspondre au mapping
chown -R 100000:100000 /srv/data

# Méthode 2 : Utiliser un UID non mappé
chown -R 1000:1000 /srv/data
# Puis configurer le mapping comme montré ci-dessus

# Méthode 3 : Utiliser des ACL
setfacl -R -m u:100000:rwx /srv/data
setfacl -R -d -m u:100000:rwx /srv/data
```

### Partage de périphériques

#### Périphériques de stockage

```bash
# Partager un disque entier (DANGEREUX)
pct set 100 -mp0 /dev/sdb,mp=/mnt/external

# Partager une partition
pct set 100 -mp0 /dev/sdb1,mp=/mnt/external
```

> [!warning] Sécurité Donner l'accès direct à un périphérique de bloc peut compromettre la sécurité. Le conteneur pourrait potentiellement accéder à d'autres données de l'hôte.

#### Périphériques USB

Pour partager des périphériques USB, vous devez modifier le fichier de configuration :

```bash
# /etc/pve/lxc/100.conf
# Donner accès à tous les périphériques USB
lxc.cgroup2.devices.allow: c 189:* rwm
lxc.mount.entry: /dev/bus/usb dev/bus/usb none bind,optional,create=dir

# Donner accès à un périphérique USB spécifique
lxc.cgroup2.devices.allow: c 189:0 rwm
lxc.mount.entry: /dev/bus/usb/001 dev/bus/usb/001 none bind,optional,create=dir
```

> [!tip] Identifier un périphérique USB
> 
> ```bash
> # Lister les périphériques USB
> lsusb
> 
> # Voir les détails d'un périphérique
> ls -la /dev/bus/usb/
> ```

#### GPU et périphériques graphiques

```bash
# /etc/pve/lxc/100.conf
# Partager le GPU (pour transcoding, etc.)
lxc.cgroup2.devices.allow: c 226:0 rwm
lxc.cgroup2.devices.allow: c 226:128 rwm
lxc.mount.entry: /dev/dri dev/dri none bind,optional,create=dir
```

#### Périphériques série (Serial)

```bash
# /etc/pve/lxc/100.conf
# Donner accès à un port série
lxc.cgroup2.devices.allow: c 4:64 rwm
lxc.mount.entry: /dev/ttyS0 dev/ttyS0 none bind,optional,create=file
```

### Quota et limites

#### Quotas de stockage

Les quotas de stockage sont gérés au niveau du système de fichiers :

```bash
# Activer les quotas sur un point de montage
pct set 100 -mp0 local-lvm:100,mp=/mnt/data,quota=1

# Les quotas permettent de limiter l'espace utilisé par utilisateur dans le conteneur
```

> [!info] Quotas utilisateur vs. quotas de volume
> 
> - **Quota de volume** : Limite la taille totale du point de montage
> - **Quota utilisateur** : Limite l'espace utilisé par chaque utilisateur dans le conteneur (nécessite `quota=1`)

#### Vérification des quotas dans le conteneur

```bash
# Installer les outils de quota (dans le conteneur)
apt install quota

# Vérifier les quotas
repquota -a

# Définir un quota pour un utilisateur
setquota -u username 1000000 1100000 0 0 /mnt/data
# soft limit: 1GB, hard limit: 1.1GB
```

#### Limites de ressources réseau et CPU

Ces limites sont configurées au niveau du conteneur (sera détaillé dans une autre partie du cours), mais affectent également le partage de ressources :

```bash
# Exemple de configuration (pas le sujet principal ici)
# Limiter la bande passante réseau
# Limiter l'utilisation CPU
```

### Bonnes pratiques {#bonnes-pratiques-partage}

> [!tip] Planification des bind mounts Créez une structure claire sur l'hôte pour organiser les partages :
> 
> ```bash
> /srv/
> ├── containers/
> │   ├── shared/          # Partagé entre plusieurs conteneurs
> │   ├── ct100/           # Spécifique au conteneur 100
> │   ├── ct101/           # Spécifique au conteneur 101
> │   └── backups/         # Backups en lecture seule
> ```

> [!warning] Éviter les bind mounts sur le rootfs Ne montez jamais des répertoires systèmes critiques de l'hôte (`/etc`, `/usr`, `/var`) dans les conteneurs, sauf si vous savez exactement ce que vous faites.

> [!tip] Documentation des partages Documentez tous les bind mounts et partages de périphériques dans vos notes ou dans un fichier README :
> 
> ```bash
> # /srv/containers/README.md
> ## Conteneur 100 - Web Server
> - mp0: /srv/containers/ct100/www → /var/www
> - mp1: /srv/containers/shared/ssl → /etc/ssl/private (ro)
> ```

> [!info] Sauvegardes et bind mounts Par défaut, les bind mounts ne sont PAS inclus dans les sauvegardes Proxmox. Utilisez `backup=1` si vous voulez les inclure, ou mettez en place une stratégie de sauvegarde séparée pour ces données.

---

## ⚙️ Features LXC

Les "features" sont des fonctionnalités avancées qui peuvent être activées pour donner plus de capacités aux conteneurs. Elles sont désactivées par défaut pour des raisons de sécurité.

> [!warning] Implications de sécurité L'activation de certaines features réduit l'isolation entre le conteneur et l'hôte. N'activez que les features dont vous avez réellement besoin.

### Nesting

Le nesting permet d'exécuter des conteneurs Docker, LXC ou d'autres technologies de conteneurisation à l'intérieur du conteneur LXC.

#### Activation

```bash
# Via la ligne de commande
pct set 100 -features nesting=1

# Via l'interface web
# Options → Features → Nesting (cocher la case)
```

#### Configuration dans le fichier

```bash
# /etc/pve/lxc/100.conf
features: nesting=1
```

#### Cas d'usage

- Exécuter Docker dans un conteneur LXC
- Exécuter Kubernetes dans un conteneur
- Créer des environnements de développement isolés
- Tester des configurations de conteneurs imbriqués

> [!example] Configuration pour Docker dans LXC
> 
> ```bash
> # Activer nesting
> pct set 100 -features nesting=1
> 
> # Si vous utilisez un conteneur unprivileged, ajoutez aussi :
> # /etc/pve/lxc/100.conf
> lxc.apparmor.profile: unconfined
> lxc.cgroup2.devices.allow: a
> lxc.cap.drop:
> ```

> [!warning] Sécurité du nesting Le nesting réduit l'isolation et peut permettre à un conteneur compromis d'affecter l'hôte. Utilisez-le uniquement dans des environnements de confiance ou de développement.

#### Vérification dans le conteneur

```bash
# Dans le conteneur, vérifier que Docker fonctionne
apt update && apt install docker.io
systemctl start docker
docker run hello-world
```

### Keyctl

Keyctl permet l'accès au keyring du noyau Linux, nécessaire pour certaines opérations de sécurité et de chiffrement.

#### Activation

```bash
# Via la ligne de commande
pct set 100 -features keyctl=1

# Dans le fichier de configuration
features: keyctl=1
```

#### Cas d'usage

- Systèmes utilisant systemd avec des fonctionnalités avancées
- Applications nécessitant la gestion de clés cryptographiques
- Certains services de sécurité (Kerberos, etc.)
- Systèmes avec chiffrement de disque

> [!info] Keyctl et systemd Keyctl est souvent nécessaire pour que systemd fonctionne correctement dans les conteneurs, particulièrement pour les services qui gèrent des secrets ou des certificats.

```bash
# Vérifier si keyctl est nécessaire (dans le conteneur)
keyctl show
# Si cette commande échoue sans keyctl=1, vous en avez probablement besoin
```

### FUSE

FUSE (Filesystem in Userspace) permet de monter des systèmes de fichiers en espace utilisateur.

#### Activation

```bash
# Via la ligne de commande
pct set 100 -features fuse=1

# Dans le fichier de configuration
features: fuse=1
```

#### Configuration complète

```bash
# /etc/pve/lxc/100.conf
features: fuse=1
lxc.apparmor.profile: unconfined
lxc.cgroup2.devices.allow: c 10:229 rwm
lxc.mount.entry: /dev/fuse dev/fuse none bind,create=file
```

#### Cas d'usage

- Montage de systèmes de fichiers distants (SSHFS)
- Stockage en cloud (rclone, s3fs)
- Systèmes de fichiers chiffrés (encfs, gocryptfs)
- AppImage et autres formats nécessitant FUSE

> [!example] Utilisation de SSHFS dans le conteneur
> 
> ```bash
> # Dans le conteneur
> apt install sshfs
> 
> # Monter un répertoire distant
> sshfs user@remote:/path /mnt/remote
> 
> # Démonter
> fusermount -u /mnt/remote
> ```

### NFS

L'activation de NFS permet de monter des partages NFS depuis l'intérieur du conteneur.

#### Activation

```bash
# Via la ligne de commande
pct set 100 -features nfs=1

# Dans le fichier de configuration
features: nfs=1
```

#### Utilisation dans le conteneur

```bash
# Installer le client NFS (dans le conteneur)
apt install nfs-common

# Monter un partage NFS
mount -t nfs server:/export /mnt/nfs

# Ajouter dans /etc/fstab pour montage permanent
echo "server:/export /mnt/nfs nfs defaults 0 0" >> /etc/fstab
```

> [!tip] Alternative : Bind mount Si possible, préférez monter le NFS sur l'hôte puis utiliser un bind mount. C'est plus sûr et plus performant :
> 
> ```bash
> # Sur l'hôte
> mount -t nfs server:/export /mnt/nfs-share
> 
> # Dans Proxmox
> pct set 100 -mp0 /mnt/nfs-share,mp=/mnt/data
> ```

### CIFS

CIFS (Common Internet File System, aussi connu comme SMB) permet de monter des partages Windows/Samba.

#### Activation

```bash
# Via la ligne de commande
pct set 100 -features cifs=1

# Dans le fichier de configuration
features: cifs=1
```

#### Utilisation dans le conteneur

```bash
# Installer le client CIFS (dans le conteneur)
apt install cifs-utils

# Monter un partage SMB/CIFS
mount -t cifs //server/share /mnt/cifs -o username=user,password=pass

# Utiliser un fichier de credentials pour plus de sécurité
# /root/.smbcredentials
username=user
password=pass

# Monter avec le fichier de credentials
mount -t cifs //server/share /mnt/cifs -o credentials=/root/.smbcredentials

# Dans /etc/fstab
//server/share /mnt/cifs cifs credentials=/root/.smbcredentials 0 0
```

> [!warning] Sécurité des credentials Ne stockez jamais les mots de passe en clair dans /etc/fstab. Utilisez toujours un fichier de credentials avec les permissions 600.

### Autres features

#### mknod

Permet de créer des fichiers de périphériques dans le conteneur.

```bash
pct set 100 -features mknod=1
```

> [!info] Utilisation de mknod Cette feature est rarement nécessaire. Elle permet au conteneur de créer des nœuds de périphériques, ce qui peut être dangereux.

#### mount

Contrôle la possibilité de monter des systèmes de fichiers dans le conteneur.

```bash
# Les types de montage autorisés sont contrôlés séparément
features: mount=nfs;cifs
```

#### Configuration multiple

Vous pouvez activer plusieurs features en même temps :

```bash
# Via la ligne de commande
pct set 100 -features nesting=1,keyctl=1,fuse=1

# Dans le fichier de configuration
features: nesting=1,keyctl=1,fuse=1,nfs=1
```

### Sécurité et implications

> [!warning] Principe de moindre privilège N'activez que les features dont vous avez réellement besoin. Chaque feature activée augmente la surface d'attaque du conteneur.

#### Hiérarchie de sécurité

Du plus sûr au moins sûr :

1. **Aucune feature** : Isolation maximale
2. **keyctl** : Impact minimal sur la sécurité
3. **fuse, nfs, cifs** : Légère réduction de l'isolation
4. **nesting** : Réduction significative de l'isolation
5. **mknod** : Risque élevé si mal utilisé

#### Recommandations par environnement

|Environnement|Features recommandées|Justification|
|---|---|---|
|**Production critique**|Aucune ou keyctl uniquement|Isolation maximale|
|**Production standard**|keyctl, nfs/cifs si nécessaire|Compromis sécurité/fonctionnalité|
|**Développement**|Selon besoins (nesting OK)|Flexibilité nécessaire|
|**Test/Lab**|Toutes si nécessaire|Environnement contrôlé|

> [!tip] Audit des features Auditez régulièrement les features activées sur vos conteneurs :
> 
> ```bash
> # Lister toutes les features de tous les conteneurs
> for ct in $(pct list | awk 'NR>1 {print $1}'); do
>   echo "=== CT $ct ==="
>   pct config $ct | grep features
> done
> ```

#### Protection supplémentaire

Même avec des features activées, vous pouvez renforcer la sécurité :

```bash
# /etc/pve/lxc/100.conf
# Limiter les capabilities même avec nesting
lxc.cap.drop: sys_admin sys_module

# Utiliser AppArmor profile personnalisé
lxc.apparmor.profile: lxc-container-default-cgns

# Logger les appels système suspects
lxc.seccomp.profile: /usr/share/lxc/config/common.seccomp
```

> [!info] Documentation des features activées Documentez toujours pourquoi une feature a été activée :
> 
> ```bash
> # /etc/pve/lxc/100.conf
> # nesting=1 : Nécessaire pour exécuter Docker (environnement de dev)
> # keyctl=1 : Requis par systemd pour la gestion des secrets
> features: nesting=1,keyctl=1
> ```

---

## 🎯 Pièges courants à éviter

> [!warning] Erreurs fréquentes
> 
> - **Oublier les permissions** : Les bind mounts avec des conteneurs unprivileged nécessitent un mapping des UID/GID correct
> - **Activer trop de features** : Chaque feature réduit l'isolation, n'activez que le nécessaire
> - **Ne pas documenter** : Les configurations complexes doivent être documentées pour la maintenance future
> - **Ignorer les backups** : Les bind mounts ne sont pas sauvegardés par défaut (`backup=0`)
> - **Confondre volumes et bind mounts** : Les volumes sont gérés par Proxmox, les bind mounts pointent vers l'hôte
> - **Monter des répertoires système** : Ne montez jamais `/etc`, `/usr`, `/var` de l'hôte dans un conteneur

> [!tip] Vérifications avant la production Avant de mettre un conteneur en production avec des configurations avancées :
> 
> 1. Testez les permissions avec l'utilisateur réel de l'application
> 2. Vérifiez que les montages sont persistants après redémarrage
> 3. Testez les sauvegardes et restaurations
> 4. Documentez toutes les configurations personnalisées
> 5. Validez que seules les features nécessaires sont activées

---

_Ce cours couvre la configuration avancée des conteneurs LXC dans Proxmox. Pour les concepts de base des conteneurs LXC, référez-vous à la partie précédente du cours._