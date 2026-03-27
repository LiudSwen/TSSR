## ⚡ L'essentiel en 5 minutes - Gestion du Stockage (OS)

### 📌 C'est quoi en 2 lignes ?

Organisation abstraite des données en **fichiers** (données) et **dossiers** (conteneurs) dans une **arborescence** (structure hiérarchique). Un **système de fichiers** (FS) transforme un périphérique physique (partition) en cette arborescence logique exploitable par l'OS.

---

### 💡 Concepts clés à retenir :

- **Fichier** : Unité de stockage contenant des données, identifié par un nom unique dans son emplacement
- **Dossier/Répertoire** : Conteneur organisationnel pouvant contenir fichiers et autres dossiers
- **Arborescence** : Structure hiérarchique branches-nœuds-feuilles partant d'une **racine**
- **Chemin absolu** : Localisation complète depuis la racine (Linux: `/home/user/file` | Windows: `C:\Users\user\file`)
- **Chemin relatif** : Localisation depuis le dossier courant (sans racine) - utilise `.` (dossier actuel) et `..` (parent)
- **Système de fichiers (FS)** : Organise l'information sur un périphérique de stockage par blocs (ext4, NTFS, FAT32)
- **Partition** : Division logique d'un disque physique, chaque partition = 1 FS
- **Montage** : (Linux) Attacher un FS à un point de l'arborescence unique
- **UUID** : Identifiant unique et stable d'une partition (ne change pas contrairement à `/dev/sdXY`)
- **Métadonnées** : Informations sur fichier/dossier (nom, taille, droits, dates, propriétaire)

---

### 💻 Commandes essentielles :

```bash
# 🐧 Linux - Navigation et manipulation
pwd                        # Affiche le répertoire courant
ls -lah /chemin            # Liste détaillée (droits, taille, cachés)
cd /var/log                # Change de répertoire
cat /etc/hosts             # Affiche contenu fichier
cp -r source dest          # Copie (-r pour dossiers)
mv ancien nouveau          # Déplace/renomme
rm -rf dossier             # Supprime (-r récursif, -f force)
mkdir -p /a/b/c            # Crée dossiers (-p crée parents)
touch fichier              # Crée fichier vide/MAJ date

# 🐧 Linux - Stockage et partitions
lsblk -f                   # Liste périphériques + FS + UUID
blkid                      # Affiche UUID des partitions
fdisk -l                   # Liste disques et partitions
cfdisk /dev/sda            # Partitionne (interface TUI)
mkfs.ext4 /dev/sdb1        # Formate partition en ext4
mount /dev/sdb1 /mnt       # Monte partition sur /mnt
umount /mnt                # Démonte
df -h                      # Espace disque utilisé

# 🐧 Linux - Recherche et filtrage
find /home -name "*.txt"   # Cherche fichiers
grep "motif" fichier       # Filtre lignes
which commande             # Trouve emplacement commande
```

```powershell
# 🪟 Windows PowerShell
Get-Location (pwd)         # Répertoire courant
Get-ChildItem (ls)         # Liste contenu
Set-Location C:\Users      # Change répertoire
Get-Content fichier        # Affiche contenu
Copy-Item src dst -R       # Copie (-R récursif)
Move-Item ancien nouveau   # Déplace/renomme
Remove-Item dossier -R -F  # Supprime (-R récursif, -F force)
New-Item -ItemType Dir     # Crée dossier

# 🪟 Windows - Stockage (cmd)
diskpart                   # Gestion disques (interactif)
format E: /FS:NTFS         # Formate lecteur E en NTFS
```

```bash
# 🔧 Configuration Linux
# /etc/fstab : Montages automatiques au démarrage
UUID=xxx-xxx  /home  ext4  defaults  0  2
# Colonnes : <périph> <point-montage> <type> <options> <dump> <fsck>
```

---

### 📐 Nomenclature périphériques Linux :

- **Disques SATA/SCSI** : `/dev/sdX` (sda, sdb, sdc...)
- **Partitions SATA** : `/dev/sdXN` (sda1, sda2, sdb1...)
- **Disques NVMe** : `/dev/nvmeYnZ` (nvme0n1, nvme0n2...)
- **Partitions NVMe** : `/dev/nvmeYnZpN` (nvme0n1p1, nvme0n1p2...)

**⚠️ Piège** : L'ordre de détection varie au boot → un disque peut changer de lettre (`sda` → `sdb`) ! **Toujours utiliser UUID**.

---

### ⚠️ Pièges à éviter :

- ❌ **Utiliser `/dev/sdX` dans `/etc/fstab`** : L'ordre change au boot → utiliser `UUID=xxx` pour stabilité
- ❌ **Oublier de démonter avant retrait** : `umount` impératif sinon corruption de données
- ❌ **Confondre chemin absolu/relatif** : `/home/user` ≠ `home/user` (relatif peut pointer n'importe où selon position)
- ❌ **Utiliser `rm -rf *` sans vérifier `pwd`** : Destruction irréversible (pas de corbeille CLI)
- ❌ **Formater sans backup** : `mkfs` écrase TOUT définitivement
- ❌ **Confondre . et .. dans scripts** : `.` = répertoire courant, `..` = parent (utile pour remonter)

---

### ✅ Bonnes pratiques :

- ✅ **Vérifier UUID avant montage** : `lsblk -f` ou `blkid` pour identifier précisément la partition
- ✅ **Tester montage manuel avant `/etc/fstab`** : Évite un boot impossible si erreur de syntaxe
- ✅ **Utiliser chemins absolus dans scripts** : Garantit fonctionnement quelle que soit la position
- ✅ **Sauvegarder `/etc/fstab` avant modification** : `cp /etc/fstab /etc/fstab.bak`
- ✅ **Respecter FHS (Linux)** : `/home` = users, `/etc` = config, `/var` = données variables, `/tmp` = temporaire

---

### 📚 Vocabulaire technique :

|Terme|Définition courte|
|---|---|
|**FHS**|Filesystem Hierarchy Standard - Norme d'arborescence Linux|
|**Point de montage**|Dossier où un FS est attaché dans l'arborescence (ex: `/mnt`, `/home`)|
|**Lien physique (hard link)**|Plusieurs noms pour UN même fichier (même inode) - compteur de liens|
|**Lien symbolique (symlink)**|Fichier pointant vers un chemin - peut être cassé si cible supprimée|
|**Inode**|Structure métadonnées d'un fichier dans le FS (droits, dates, emplacement blocs)|
|**Journalisation**|Enregistrement des opérations FS avant exécution (sécurise contre corruption)|
|**Extent**|Bloc contigu d'allocation (ext4) - réduit fragmentation vs allocation bloc par bloc|
|**ACL**|Access Control List - Droits d'accès avancés (NTFS) au-delà user/group/others|
|**Pseudo-fichiers**|Fichiers virtuels représentant ressources système (`/dev`, `/proc`, `/sys`)|

---

### 🗺️ Arborescences standards :

**🐧 Linux (racine unique `/`):**

```
/bin      → Exécutables essentiels (ls, cp, cat...)
/boot     → Noyau et fichiers de démarrage
/dev      → Périphériques (sda, tty, null...)
/etc      → Configuration système
/home     → Répertoires personnels utilisateurs
/root     → Répertoire personnel de root
/tmp      → Temporaire (vidé au redémarrage)
/var      → Données variables (logs, cache, spools)
/usr      → Programmes et ressources standards
/proc     → Processus (pseudo-fichiers)
/sys      → Configuration matérielle actuelle
```

**🪟 Windows (racines multiples `C:\`, `D:\`...):**

```
C:\Users                → Utilisateurs
C:\Windows              → Système
C:\Program Files        → Applications 64-bit
C:\Program Files (x86)  → Applications 32-bit
C:\ProgramData          → Données globales apps
```

---

### 🎯 À retenir ABSOLUMENT (3 points max) :

1. 💡 **Théorique** : Linux = 1 arborescence `/` avec montages | Windows = N arborescences `C:\`, `D:\`... (1 par partition)
    
2. 💻 **Pratique** : Toujours utiliser **UUID** dans `/etc/fstab` pour éviter problèmes d'ordre de détection des disques
    
3. ⚠️ **Piège** : Pseudo-dossiers `.` (répertoire actuel) et `..` (parent) existent dans CHAQUE dossier - `rm *` ne les supprime pas mais peut tout détruire autour
    

---

### 🔥 Antisèche FS rapide :

|FS|OS|Limite fichier|Limite volume|Features|
|---|---|--:|--:|---|
|**FAT32**|Tous|4 Gio|16 Tio|Compatible universel, pas de droits|
|**NTFS**|Windows|~16 Eio|~16 Eio|Journalisation, ACL, compression, chiffrement|
|**ext4**|Linux|16 Tio|1 Eio|Journalisation, extents, défrag online|

**Variable PATH** : Liste de répertoires où le shell cherche les commandes exécutables  
→ Linux: `$PATH` | Windows: `$env:path`