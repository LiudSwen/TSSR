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

## Introduction aux sauvegardes manuelles

Les sauvegardes manuelles dans Proxmox permettent de créer une copie ponctuelle d'une machine virtuelle ou d'un conteneur à un instant T. Contrairement aux sauvegardes planifiées (abordées dans une autre partie), ces backups sont déclenchés à la demande.

> [!info] Quand utiliser les sauvegardes manuelles ?
> 
> - Avant une mise à jour critique du système
> - Avant une modification importante de la configuration
> - Pour créer un point de restauration avant des tests
> - Pour archiver l'état actuel d'une VM/CT

> [!warning] Important Les sauvegardes manuelles utilisent les mêmes mécanismes que les sauvegardes automatiques. La seule différence est le déclenchement : manuel vs planifié.

---

## Sauvegarde d'une VM

### Via l'interface web (VM)

L'interface web Proxmox offre une méthode intuitive pour créer des sauvegardes de machines virtuelles.

**Étapes détaillées :**

1. **Accéder à la VM**
    
    - Dans l'arborescence de gauche, sélectionnez votre VM
    - Cliquez sur l'onglet **"Backup"**
2. **Lancer la sauvegarde**
    
    - Cliquez sur le bouton **"Backup now"**
    - Une fenêtre de configuration s'ouvre
3. **Configurer les paramètres**
    
    - **Storage** : Choisir la destination du backup
    - **Mode** : Sélectionner le mode de sauvegarde (voir tableau ci-dessous)
    - **Compression** : Choisir l'algorithme de compression
    - **Notes** : Ajouter une description (optionnel mais recommandé)
4. **Valider et exécuter**
    
    - Cliquez sur **"Backup"**
    - Le processus démarre immédiatement
    - La progression s'affiche dans la console de tâches

> [!tip] Astuce Ajoutez toujours une note descriptive à vos backups manuels (ex: "Avant migration MySQL 8.0" ou "Config stable prod 2025-01-15"). Cela facilite grandement la restauration ultérieure.

### Via la ligne de commande (VM)

Pour les utilisateurs avancés ou pour l'automatisation de scripts, la commande `vzdump` est l'outil privilégié.

```bash
# Syntaxe de base
vzdump <VMID> --storage <STORAGE_NAME>

# Exemple simple - sauvegarde de la VM 100
vzdump 100 --storage local

# Exemple avec options avancées
vzdump 100 \
  --storage backup-nfs \
  --mode snapshot \
  --compress zstd \
  --notes "Avant upgrade kernel 6.x"
```

**Paramètres détaillés :**

```bash
# Spécifier le mode de sauvegarde
vzdump 100 --mode snapshot    # Utilise les snapshots (recommandé)
vzdump 100 --mode suspend     # Suspend la VM pendant le backup
vzdump 100 --mode stop        # Arrête la VM pour le backup

# Compression (impact sur taille et temps)
vzdump 100 --compress gzip    # Compression standard (lent mais compatible)
vzdump 100 --compress lzo     # Compression rapide (fichier plus gros)
vzdump 100 --compress zstd    # Compression moderne (équilibre optimal)

# Options de notification
vzdump 100 --mailto admin@example.com --mailnotification always

# Sauvegarder plusieurs VMs en une commande
vzdump 100 101 102 --storage local

# Exclure certains disques
vzdump 100 --exclude-path /dev/sdb
```

> [!example] Exemple pratique Sauvegarde complète d'une VM de production avec notification :
> 
> ```bash
> vzdump 100 \
>   --storage backup-server \
>   --mode snapshot \
>   --compress zstd \
>   --notes "Backup pre-production avant MEP 2025-01" \
>   --mailto ops@example.com \
>   --mailnotification always
> ```

### Options de sauvegarde (VM)

|Mode|Description|Temps d'arrêt|Cas d'usage|
|---|---|---|---|
|**snapshot**|Utilise les snapshots LVM/ZFS|Aucun ou < 1s|Production (recommandé)|
|**suspend**|Suspend la VM pendant le backup|Quelques secondes|Serveurs peu critiques|
|**stop**|Arrête complètement la VM|Durée du backup|Tests, développement|

|Compression|Ratio|Vitesse|Utilisation CPU|
|---|---|---|---|
|**None**|1:1|Très rapide|Minimale|
|**LZO**|~1.5:1|Rapide|Faible|
|**GZIP**|~2.5:1|Moyenne|Moyenne|
|**ZSTD**|~2.8:1|Rapide|Moyenne|

> [!warning] Attention au mode "snapshot" Le mode snapshot nécessite que le stockage de la VM supporte les snapshots (LVM-thin, ZFS, Ceph). Si ce n'est pas le cas, Proxmox basculera automatiquement en mode "suspend" ou "stop".

---

## Sauvegarde d'un conteneur

### Via l'interface web (Conteneur)

La procédure pour les conteneurs LXC est similaire aux VMs, avec quelques spécificités.

**Étapes :**

1. **Sélectionner le conteneur**
    
    - Dans l'arborescence, choisissez votre conteneur (CT)
    - Accédez à l'onglet **"Backup"**
2. **Lancer la sauvegarde**
    
    - Cliquez sur **"Backup now"**
    - La fenêtre de configuration apparaît
3. **Options spécifiques aux conteneurs**
    
    - **Storage** : Destination du backup
    - **Mode** : snapshot ou stop (suspend n'existe pas pour les CT)
    - **Compression** : Identique aux VMs
    - **Protected** : Marquer le backup comme protégé contre la suppression
4. **Exécuter**
    
    - Validez avec **"Backup"**
    - Le processus est généralement plus rapide que pour les VMs

> [!info] Différence VM vs Conteneur Les conteneurs sont généralement plus rapides à sauvegarder car ils ne contiennent pas de système d'exploitation complet, seulement le système de fichiers et la configuration.

### Via la ligne de commande (Conteneur)

La commande `vzdump` fonctionne de manière identique pour les conteneurs, en spécifiant simplement l'ID du conteneur.

```bash
# Sauvegarde basique d'un conteneur
vzdump 200 --storage local

# Avec mode snapshot (si le stockage le supporte)
vzdump 200 --mode snapshot --storage backup-nfs

# Mode stop (arrêt du conteneur)
vzdump 200 --mode stop --storage local

# Sauvegarde avec protection
vzdump 200 --storage local --protected 1
```

**Syntaxe avancée pour conteneurs :**

```bash
# Sauvegarde de plusieurs conteneurs
vzdump 200 201 202 --storage backup-nfs --compress zstd

# Exclure certains points de montage
vzdump 200 --exclude-path /mnt/data --exclude-path /mnt/temp

# Backup avec notes et compression optimale
vzdump 200 \
  --storage remote-backup \
  --mode snapshot \
  --compress zstd \
  --notes "CT web-server - avant migration PHP 8.3" \
  --protected 1
```

> [!tip] Astuce pour les conteneurs Les conteneurs démarrent et s'arrêtent beaucoup plus rapidement que les VMs. Le mode "stop" est donc souvent acceptable même en production, surtout pour les backups manuels ponctuels.

### Spécificités des conteneurs

**Modes de sauvegarde disponibles :**

|Mode|Comportement|Impact|
|---|---|---|
|**snapshot**|Snapshot instantané du système de fichiers|Aucun temps d'arrêt (si supporté)|
|**stop**|Arrêt propre du conteneur|Temps d'arrêt = durée du backup|

> [!warning] Pas de mode "suspend" pour les conteneurs Contrairement aux VMs, les conteneurs LXC ne peuvent pas être suspendus. Seuls les modes "snapshot" et "stop" sont disponibles.

**Avantages des conteneurs pour les backups :**

- 🚀 **Rapidité** : Backup et restauration très rapides (pas d'OS complet)
- 💾 **Taille réduite** : Fichiers de backup beaucoup plus petits
- ⚡ **Démarrage instantané** : Redémarrage quasi-immédiat après un backup "stop"
- 🔧 **Flexibilité** : Plus facile de manipuler le contenu du backup

**Considérations importantes :**

```bash
# Vérifier si le stockage supporte les snapshots pour un CT
pct status 200
pct config 200 | grep rootfs

# Les conteneurs sur dir/NFS ne supportent pas les snapshots natifs
# Dans ce cas, le backup utilisera le mode "stop" automatiquement
```

> [!example] Cas d'usage typique Conteneur web avec base de données légère :
> 
> ```bash
> # Arrêt propre des services, backup, puis redémarrage
> pct exec 200 -- systemctl stop nginx mysql
> vzdump 200 --mode stop --storage backup-nfs --compress zstd
> # Le CT redémarre automatiquement après le backup
> ```

---

## Destinations du backup

### Stockage local

Le stockage local fait référence aux espaces de stockage directement attachés au serveur Proxmox.

**Types de stockage local :**

|Type|Chemin par défaut|Caractéristiques|
|---|---|---|
|**local**|`/var/lib/vz/dump/`|Stockage par défaut, limité|
|**local-lvm**|Volume LVM|Performances élevées|
|**local-zfs**|Pool ZFS|Snapshots natifs, compression|
|**Directory**|Chemin personnalisé|Flexible, simple|

**Configuration typique :**

```bash
# Vérifier les stockages disponibles
pvesm status

# Sauvegarde vers le stockage local par défaut
vzdump 100 --storage local

# Vérifier l'espace disponible
df -h /var/lib/vz/dump/

# Lister les backups existants
ls -lh /var/lib/vz/dump/
```

> [!warning] Limitation du stockage local Le stockage local est limité par l'espace disque du serveur Proxmox. Pour des backups réguliers, privilégiez un stockage distant ou un disque dédié.

**Gestion de l'espace :**

```bash
# Afficher la taille des backups
du -sh /var/lib/vz/dump/*

# Supprimer manuellement un ancien backup
rm /var/lib/vz/dump/vzdump-qemu-100-2025_01_15-10_30_00.vma.zst

# Vérifier les quotas (si configurés)
pvesm status --storage local
```

### Stockage distant

Les stockages distants permettent de sécuriser les backups hors du serveur Proxmox, ce qui est essentiel pour une stratégie de sauvegarde robuste.

**Types de stockage distant supportés :**

|Type|Protocole|Cas d'usage|
|---|---|---|
|**NFS**|Network File System|Partage Linux/Unix|
|**SMB/CIFS**|Windows Share|Serveurs Windows|
|**PBS**|Proxmox Backup Server|Solution dédiée Proxmox|
|**iSCSI**|Block storage|SAN d'entreprise|
|**S3**|Object storage|Cloud (AWS, MinIO)|

**Exemple avec NFS :**

```bash
# Monter un partage NFS (déjà configuré dans Proxmox)
vzdump 100 --storage backup-nfs

# Si le stockage n'est pas configuré, vérifier
pvesm status | grep nfs

# Tester la connectivité
ping backup-server.local
showmount -e backup-server.local
```

**Exemple avec SMB/CIFS :**

```bash
# Sauvegarde vers un partage Windows
vzdump 100 --storage backup-smb --compress gzip

# Les credentials sont stockés dans la configuration Proxmox
# Pas besoin de les spécifier à chaque backup
```

> [!tip] Proxmox Backup Server (PBS) PBS est la solution de backup dédiée de Proxmox. Elle offre la déduplication, le chiffrement, et la vérification d'intégrité. Bien qu'elle soit mentionnée ici, sa configuration complète sera abordée dans une autre partie du cours.

### Configuration des destinations

**Ajouter un stockage NFS (via interface web) :**

1. **Datacenter** → **Storage** → **Add** → **NFS**
2. Renseigner :
    - **ID** : Nom unique (ex: "backup-nfs")
    - **Server** : IP ou hostname du serveur NFS
    - **Export** : Chemin du partage (ex: "/export/backups")
    - **Content** : Cocher "VZDump backup file"
3. Cliquer sur **Add**

**Ajouter un stockage NFS (via CLI) :**

```bash
# Syntaxe de base
pvesm add nfs <STORAGE_ID> \
  --server <NFS_SERVER> \
  --export <NFS_PATH> \
  --content vztmpl,backup

# Exemple concret
pvesm add nfs backup-nfs \
  --server 192.168.1.50 \
  --export /mnt/backups/proxmox \
  --content backup \
  --maxfiles 10

# Vérifier la configuration
pvesm status --storage backup-nfs

# Tester avec un backup
vzdump 100 --storage backup-nfs
```

**Ajouter un stockage SMB/CIFS :**

```bash
# Configuration d'un partage Windows
pvesm add cifs backup-smb \
  --server windows-server.local \
  --share Backups \
  --username backup-user \
  --password 'SecurePassword123!' \
  --content backup \
  --domain WORKGROUP

# Pour un domaine Active Directory
pvesm add cifs backup-smb \
  --server dc01.domain.local \
  --share ProxmoxBackups$ \
  --username DOMAIN\\backup-svc \
  --password 'ComplexPass!' \
  --content backup \
  --domain DOMAIN
```

**Ajouter un stockage Directory personnalisé :**

```bash
# Créer un répertoire dédié
mkdir -p /mnt/backup-disk

# Monter un disque externe (exemple)
mount /dev/sdb1 /mnt/backup-disk

# Ajouter comme stockage Proxmox
pvesm add dir backup-external \
  --path /mnt/backup-disk \
  --content backup \
  --maxfiles 5

# Pour un montage permanent, ajouter dans /etc/fstab
echo "/dev/sdb1 /mnt/backup-disk ext4 defaults 0 2" >> /etc/fstab
```

> [!info] Option --maxfiles L'option `--maxfiles` limite le nombre de backups conservés par VM/CT. Utile pour gérer automatiquement l'espace disque.

**Vérification et gestion des stockages :**

```bash
# Lister tous les stockages configurés
pvesm status

# Détails d'un stockage spécifique
pvesm status --storage backup-nfs

# Lister les backups sur un stockage
pvesm list backup-nfs

# Supprimer un stockage (attention, ne supprime pas les données)
pvesm remove backup-nfs

# Désactiver temporairement un stockage
pvesm set backup-nfs --disable 1

# Réactiver un stockage
pvesm set backup-nfs --disable 0
```

> [!warning] Sécurité des credentials Les mots de passe des stockages distants (SMB/CIFS notamment) sont stockés en clair dans `/etc/pve/storage.cfg`. Protégez l'accès à ce fichier et utilisez des comptes de service dédiés avec permissions minimales.

**Bonnes pratiques pour les destinations :**

- 🔐 **Séparer les backups** : Ne pas sauvegarder sur le même stockage que les VMs
- 🌐 **Utiliser le réseau dédié** : Si possible, réseau séparé pour les backups
- 📊 **Monitoring de l'espace** : Surveiller l'espace disque des destinations
- 🔄 **Rotation automatique** : Configurer `--maxfiles` pour éviter la saturation
- 🛡️ **Redondance** : Idéalement, sauvegarder vers plusieurs destinations

---

## Pièges courants

> [!warning] Espace insuffisant **Problème :** Le backup échoue avec "No space left on device"
> 
> **Solution :**
> 
> ```bash
> # Vérifier l'espace avant le backup
> df -h /var/lib/vz/dump/
> 
> # Nettoyer les anciens backups
> find /var/lib/vz/dump/ -name "*.vma.*" -mtime +30 -delete
> 
> # Ou utiliser maxfiles lors de la configuration du stockage
> pvesm set local --maxfiles 3
> ```

> [!warning] Backup en mode "snapshot" qui échoue **Problème :** Le mode snapshot ne fonctionne pas, message "snapshot mode not supported"
> 
> **Cause :** Le stockage de la VM ne supporte pas les snapshots (ex: directory sur ext4/xfs)
> 
> **Solution :**
> 
> - Utiliser le mode "suspend" ou "stop"
> - Ou migrer la VM vers un stockage compatible (LVM-thin, ZFS, Ceph)

> [!warning] Backup qui ne démarre jamais **Problème :** Le backup reste bloqué en "waiting for lock"
> 
> **Cause :** Un autre backup est en cours ou un verrou est resté actif
> 
> **Solution :**
> 
> ```bash
> # Identifier les tâches en cours
> pvesh get /cluster/tasks
> 
> # Vérifier les verrous
> qm unlock 100  # Pour une VM
> pct unlock 200 # Pour un conteneur
> 
> # Si nécessaire, tuer le processus bloqué
> ps aux | grep vzdump
> kill -9 <PID>
> ```

> [!warning] Corruption de backup **Problème :** Le backup se termine avec succès mais la restauration échoue
> 
> **Prévention :**
> 
> - Toujours utiliser la compression (détecte les erreurs)
> - Vérifier l'intégrité après création :
> 
> ```bash
> # Pour un backup compressé
> zstd -t /var/lib/vz/dump/vzdump-qemu-100-*.vma.zst
> 
> # Pour gzip
> gzip -t /var/lib/vz/dump/vzdump-qemu-100-*.vma.gz
> ```

> [!warning] Permissions insuffisantes sur stockage distant **Problème :** "Permission denied" lors de l'écriture du backup
> 
> **Solution NFS :**
> 
> ```bash
> # Sur le serveur NFS, vérifier les exports
> cat /etc/exports
> # Doit contenir : /export/backups *(rw,sync,no_root_squash,no_subtree_check)
> 
> # Recharger les exports
> exportfs -ra
> ```
> 
> **Solution SMB :**
> 
> - Vérifier que l'utilisateur a les droits en écriture
> - Tester manuellement le montage :
> 
> ```bash
> mount -t cifs //server/share /mnt/test -o username=user,password=pass
> touch /mnt/test/test.txt
> ```

---

## Bonnes pratiques

> [!tip] 💡 Nommer vos backups avec des notes descriptives Toujours ajouter une note explicite lors d'un backup manuel :
> 
> ```bash
> vzdump 100 --notes "Avant migration base données v2.5 vers v3.0"
> vzdump 200 --notes "Config stable production - fin sprint 23"
> vzdump 300 --notes "Point de restauration avant test load balancer"
> ```

> [!tip] 🎯 Stratégie 3-2-1
> 
> - **3** copies de vos données
> - **2** types de supports différents
> - **1** copie hors site
> 
> Exemple d'implémentation :
> 
> ```bash
> # Copie 1 : Backup local
> vzdump 100 --storage local
> 
> # Copie 2 : Backup sur NAS
> vzdump 100 --storage backup-nfs
> 
> # Copie 3 : Sync vers le cloud (script séparé)
> rsync -avz /var/lib/vz/dump/ backup@cloud:/backups/
> ```

> [!tip] ⚡ Optimiser la compression selon le contexte
> 
> |Situation|Compression recommandée|Raison|
> |---|---|---|
> |VM avec données déjà compressées (vidéos, images)|None ou LZO|Gain négligeable, perte de temps|
> |VM avec logs, texte, code|ZSTD ou GZIP|Excellent ratio de compression|
> |Backup urgent (panne imminente)|LZO|Le plus rapide|
> |Backup pour archivage long terme|GZIP|Meilleure compatibilité|

> [!tip] 🔍 Vérifier systématiquement les backups Ne faites jamais confiance aveuglément à un backup sans l'avoir testé :
> 
> ```bash
> # 1. Vérifier l'intégrité du fichier
> zstd -t /path/to/backup.vma.zst
> 
> # 2. Lister le contenu du backup
> vzdump --restore test --storage local \
>   --archive /path/to/backup.vma.zst
> 
> # 3. Idéalement, restaurer dans une VM de test
> qmrestore /path/to/backup.vma.zst 999 --storage local
> # Puis tester le démarrage et l'intégrité
> ```

> [!tip] 📊 Surveiller l'espace de stockage Automatiser la surveillance avec un script de monitoring :
> 
> ```bash
> #!/bin/bash
> # Script de monitoring de l'espace backup
> 
> THRESHOLD=80  # Seuil d'alerte à 80%
> STORAGE="/var/lib/vz/dump"
> 
> USAGE=$(df -h "$STORAGE" | awk 'NR==2 {print $5}' | sed 's/%//')
> 
> if [ "$USAGE" -gt "$THRESHOLD" ]; then
>     echo "ALERTE: Espace backup à ${USAGE}%"
>     # Envoyer email ou notification
> fi
> ```

> [!tip] 🔐 Sécuriser les backups sensibles Pour les VMs contenant des données critiques :
> 
> ```bash
> # 1. Utiliser des stockages chiffrés
> # 2. Protéger le backup contre la suppression
> vzdump 100 --storage encrypted-nfs --protected 1
> 
> # 3. Limiter les accès au stockage
> chmod 700 /var/lib/vz/dump/
> chown root:root /var/lib/vz/dump/
> ```

> [!tip] ⏱️ Planifier les backups manuels aux heures creuses Si vous devez faire un backup manuel en production :
> 
> - Privilégier les heures de faible activité (nuit, weekend)
> - Prévenir les utilisateurs si le service sera impacté
> - Utiliser le mode "snapshot" pour minimiser l'impact
> - Monitorer les performances pendant le backup :
> 
> ```bash
> # Surveiller l'IO pendant le backup
> iostat -x 2
> 
> # Vérifier l'impact CPU
> top -b -n 1 | grep vzdump
> ```

> [!tip] 📝 Documenter les backups importants Créer un journal des backups manuels critiques :
> 
> ```bash
> # Exemple de fichier de log
> echo "$(date) - VM 100 - Backup avant migration - vzdump-qemu-100-2025_01_15.vma.zst" \
>   >> /var/log/manual-backups.log
> ```

> [!tip] 🔄 Tester régulièrement la restauration Un backup non testé est un backup inutile :
> 
> - Planifier des tests de restauration trimestriels
> - Créer une VM de test dédiée
> - Documenter la procédure de restauration
> - Former l'équipe à la restauration d'urgence

---

**🎯 Points clés à retenir :**

1. Les backups manuels sont essentiels avant toute opération critique
2. Le mode "snapshot" est le plus adapté pour la production (si supporté)
3. Toujours documenter vos backups avec des notes descriptives
4. Privilégier les stockages distants pour la sécurité
5. Tester régulièrement vos backups en conditions réelles
6. Surveiller l'espace de stockage disponible
7. Adapter la compression selon le type de données et l'urgence

---

> [!info] 📌 Rappel Ce cours couvre uniquement les sauvegardes manuelles. Les sauvegardes planifiées, la restauration détaillée, et l'utilisation de Proxmox Backup Server seront abordées dans d'autres parties du cours.