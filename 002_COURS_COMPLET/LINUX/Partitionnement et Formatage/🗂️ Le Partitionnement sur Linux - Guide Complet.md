
## 1. 📚 Concept de Base

### L'analogie de l'immeuble

Imagine un disque dur comme un **grand immeuble vide**. Sans partitionnement, c'est comme si tu avais un seul énorme espace ouvert de 1000 m² sans aucune cloison. Certes, tu peux tout mettre dedans, mais :

- Si un incendie démarre quelque part, tout brûle
- Impossible d'organiser : le salon, la chambre, la cuisine, tout est mélangé
- Si tu veux refaire la décoration d'une pièce, tu dois tout vider

Le **partitionnement**, c'est comme construire des **murs et créer des appartements séparés** dans cet immeuble :

- Appartement A : 300 m² pour le système d'exploitation
- Appartement B : 500 m² pour les données utilisateurs
- Appartement C : 200 m² pour les sauvegardes

Chaque appartement a sa propre porte, son propre système de sécurité, et si l'un prend feu, les autres sont protégés.

> [!info] Définition technique Le partitionnement consiste à **diviser logiquement un disque physique** en plusieurs sections indépendantes. Chaque partition est vue par le système comme un disque distinct, possédant son propre système de fichiers, ses propres permissions, et pouvant être montée/démontée indépendamment.

### Pourquoi ça existe ? Quel problème ça résout ?

**Problème n°1 : La sécurité et l'isolation**

- Un utilisateur remplit `/home` avec 500 Go de vidéos → le système dans `/` continue de fonctionner
- Un bug écrase des fichiers dans `/var` → tes données personnelles dans `/home` sont intactes

**Problème n°2 : La maintenance**

- Tu veux réinstaller le système ? Pas de souci, tu reformates uniquement la partition `/` et tu gardes `/home` intact
- Tu veux changer de distribution ? Même chose, tes données restent en place

**Problème n°3 : Les performances**

- Tu peux mettre `/var/log` sur une partition séparée pour éviter que les logs saturent ton système
- Tu peux utiliser différents systèmes de fichiers adaptés à chaque usage (ext4 pour le système, XFS pour les grosses données)

**Problème n°4 : Le multi-boot**

- Tu veux tester Ubuntu ET Debian sur le même PC ? Chaque système a sa partition
- Windows + Linux sur le même disque ? Possible grâce au partitionnement

---

## 2. 💼 Cas Concrets et Situations Réelles

### Exemple 1 : Le serveur web qui tombe à cause des logs

**Contexte :** Tu es TSSR dans une PME. Le serveur web (Debian 12, 500 Go) héberge le site e-commerce de l'entreprise. Un lundi matin à 9h, plus personne ne peut accéder au site.

**Problème découvert :**

```bash
df -h
# Filesystem      Size  Used Avail Use% Mounted on
# /dev/sda1       480G  480G    0G 100% /
```

Le disque est plein ! En creusant :

```bash
du -sh /var/log/*
# 450G    /var/log/apache2/access.log
```

Un script de rotation des logs a planté il y a 3 mois. Le fichier access.log a grossi jusqu'à remplir tout le disque. Le système ne peut plus écrire, donc Apache plante, la base de données aussi.

**Solution avec partitionnement :**

Si le serveur avait été partitionné ainsi :

```
/dev/sda1   50G   /           (système)
/dev/sda2   30G   /var/log    (logs)
/dev/sda3  400G   /var/www    (sites web)
```

Le log aurait rempli uniquement `/var/log` (30G max), mais le système et le site web auraient continué à fonctionner. Tu aurais reçu une alerte "partition /var/log pleine" sans interruption de service.

**Commandes pour créer cette structure lors de l'installation :**

```bash
# Avec fdisk pour un disque /dev/sda
fdisk /dev/sda
# n (nouvelle partition) → p (primaire) → 1 → +50G
# n → p → 2 → +30G
# n → p → 3 → (reste du disque)
# w (écrire les changements)

# Formater les partitions
mkfs.ext4 /dev/sda1
mkfs.ext4 /dev/sda2
mkfs.ext4 /dev/sda3

# Monter dans /etc/fstab
/dev/sda1  /         ext4  defaults  0  1
/dev/sda2  /var/log  ext4  defaults  0  2
/dev/sda3  /var/www  ext4  defaults  0  2
```

> [!tip] Leçon retenue Toujours isoler `/var/log` sur les serveurs en production. Budget : 20-50 Go selon l'activité.

---

### Exemple 2 : Migration Ubuntu sans perdre les données utilisateurs

**Contexte :** 35 postes de travail sous Ubuntu 20.04 LTS dans une école. La version arrive en fin de support, il faut passer à Ubuntu 24.04 LTS. Les enseignants ont des années de documents dans leurs `/home`.

**Problème :** Avec une seule partition, tu dois :

1. Sauvegarder 35 × 50 Go = 1,75 To de données utilisateurs
2. Réinstaller Ubuntu
3. Restaurer toutes les données
4. Reconfigurer les profils → **Estimation : 3 jours de travail**

**Solution si `/home` est sur une partition séparée :**

Structure actuelle :

```
/dev/sda1   100G   /       (Ubuntu 20.04 + applications)
/dev/sda2   350G   /home   (données des 35 utilisateurs)
```

Procédure de migration :

```bash
# 1. Noter l'UUID de la partition /home
blkid | grep sda2
# /dev/sda2: UUID="a3f8bc45-..." TYPE="ext4"

# 2. Booter sur clé USB Ubuntu 24.04
# 3. Lors de l'installation, choisir "Manuel"
# 4. Formater UNIQUEMENT /dev/sda1 en ext4, point de montage /
# 5. Sélectionner /dev/sda2, NE PAS formater, point de montage /home
# 6. Terminer l'installation

# 7. Premier boot : tous les comptes et données sont là !
ls /home/
# prof_martin/  prof_dubois/  prof_leclerc/ ...
```

→ **Temps réel : 45 minutes par poste** (installation automatique)

> [!example] Gain de temps Sans partition séparée : 3 jours de travail Avec partition séparée : 1 journée pour les 35 postes **Économie : 16 heures de travail = 1600€ (à 100€/h)**

---

### Exemple 3 : Serveur de fichiers qui explose

**Contexte :** PME de 80 personnes, serveur de fichiers Debian avec Samba. Disque de 2 To. Les commerciaux partagent des présentations PowerPoint avec vidéos.

**Problème un vendredi soir :**

```bash
df -h
# /dev/sdb1  1.8T  1.8T  0G  100%  /srv/shares
```

Plus personne ne peut sauvegarder de fichiers. Le service informatique reçoit 40 tickets. En analysant :

```bash
du -sh /srv/shares/*
# 1.2T    /srv/shares/commercial
# 450G    /srv/shares/comptabilite
# 150G    /srv/shares/direction
```

Les commerciaux ont monopolisé l'espace. La comptabilité ne peut plus travailler.

**Solution avec quotas et partitionnement :**

Structure optimale :

```
/dev/sdb1   500G   /srv/shares/commercial
/dev/sdb2   300G   /srv/shares/comptabilite
/dev/sdb3   200G   /srv/shares/direction
/dev/sdb4   800G   /srv/shares/archives
```

Mise en place :

```bash
# Créer les partitions avec parted (plus simple pour gros disques)
parted /dev/sdb
  mklabel gpt
  mkpart primary ext4 0% 25%
  mkpart primary ext4 25% 40%
  mkpart primary ext4 40% 50%
  mkpart primary ext4 50% 100%
  quit

# Formater
mkfs.ext4 -L commercial /dev/sdb1
mkfs.ext4 -L comptabilite /dev/sdb2
mkfs.ext4 -L direction /dev/sdb3
mkfs.ext4 -L archives /dev/sdb4

# Monter dans /etc/fstab
LABEL=commercial    /srv/shares/commercial   ext4  defaults  0  2
LABEL=comptabilite  /srv/shares/comptabilite ext4  defaults  0  2
LABEL=direction     /srv/shares/direction    ext4  defaults  0  2
LABEL=archives      /srv/shares/archives     ext4  defaults  0  2
```

**Résultat :**

- Les commerciaux peuvent remplir leurs 500 Go sans impacter les autres
- La comptabilité a son espace garanti
- Alerte automatique quand une partition atteint 80%

> [!warning] Attention Penser à dimensionner les partitions en fonction de l'usage réel + 30% de marge. Un commercial génère ~15 Go/mois en moyenne.

---

### Exemple 4 : Dual-boot Windows 11 + Ubuntu pour un développeur

**Contexte :** Un développeur a besoin de Windows 11 pour Office et Teams, mais préfère Linux pour coder. PC portable avec SSD de 512 Go.

**Problème classique du débutant :** Il installe Windows (qui prend tout le disque), puis essaie d'installer Ubuntu. L'installateur Ubuntu ne trouve pas d'espace libre et propose "d'effacer le disque".

**Solution : partitionnement bien pensé**

Plan d'action :

```
Disque original : /dev/nvme0n1 (512 Go)
└─ /dev/nvme0n1p1  512G  Windows (C:)

Plan cible :
/dev/nvme0n1p1   100M  EFI System Partition (déjà créée par Windows)
/dev/nvme0n1p2    16M  Microsoft Reserved
/dev/nvme0n1p3   220G  Windows (C:) - NTFS
/dev/nvme0n1p4    40G  Ubuntu / - ext4
/dev/nvme0n1p5     8G  Ubuntu swap
/dev/nvme0n1p6   244G  Ubuntu /home - ext4
```

Procédure depuis Windows :

```powershell
# 1. Dans Windows, ouvrir "Gestion des disques"
# 2. Clic droit sur C:, "Réduire le volume"
# 3. Libérer 292 Go (292000 Mo)
# 4. Laisser l'espace non alloué

# 5. Redémarrer sur clé USB Ubuntu
# 6. Choisir "Autre chose" lors de l'installation
# 7. Créer les partitions Ubuntu dans l'espace libre
```

Depuis l'installateur Ubuntu :

```
Espace libre de 292 Go détecté

Créer :
- 40 Go, ext4, point de montage /
- 8 Go, swap
- 244 Go, ext4, point de montage /home

Installer le chargeur GRUB sur /dev/nvme0n1
```

**Résultat :** Au démarrage, GRUB propose :

- Ubuntu (par défaut)
- Windows 11
- Options avancées

> [!tip] Conseil pro Toujours installer Windows EN PREMIER, puis Linux. Windows écrase le bootloader, Linux sait cohabiter. Prévoir 220-250 Go pour Windows (Office + Visual Studio = 80 Go facilement), 40 Go minimum pour la racine Linux.

---

### Exemple 5 : Serveur de base de données MySQL qui rame

**Contexte :** E-commerce avec 50 000 produits, MySQL sur Ubuntu Server 22.04. Les clients se plaignent de lenteur lors des recherches. Disque dur classique 1 To.

**Problème identifié :**

```bash
df -h
# /dev/sda1  900G  650G  250G  73%  /

iostat -x 1
# Device   r/s   w/s   %util
# sda      450   120    98%    ← Disque saturé !
```

Tout est sur la même partition : système, logs, base de données, site web. Le disque fait des allers-retours constants entre `/var/log` et `/var/lib/mysql`.

**Solution : partition + SSD NVMe dédié**

Ajout d'un SSD NVMe 500 Go pour la base de données :

```
Configuration avant :
/dev/sda1  900G  /  (tout mélangé)

Configuration après :
/dev/sda1   50G  /           (système)
/dev/sda2   30G  /var/log    (logs)
/dev/sda3  820G  /var/www    (site web)
/dev/nvme0n1 500G /var/lib/mysql (base de données)
```

Migration de la base :

```bash
# 1. Arrêter MySQL
systemctl stop mysql

# 2. Partitionner et formater le SSD
parted /dev/nvme0n1 mklabel gpt
parted /dev/nvme0n1 mkpart primary ext4 0% 100%
mkfs.ext4 /dev/nvme0n1p1

# 3. Sauvegarder et déplacer les données
rsync -av /var/lib/mysql/ /mnt/temp_mysql/

# 4. Monter la nouvelle partition
mount /dev/nvme0n1p1 /var/lib/mysql
rsync -av /mnt/temp_mysql/ /var/lib/mysql/
chown -R mysql:mysql /var/lib/mysql

# 5. Ajouter dans /etc/fstab
/dev/nvme0n1p1  /var/lib/mysql  ext4  defaults,noatime  0  2

# 6. Redémarrer MySQL
systemctl start mysql
```

**Résultat mesuré :**

```bash
# AVANT (HDD 7200 RPM) :
# Requête SELECT avec JOIN : 2.3 secondes
# Temps de chargement page : 4.5 secondes

# APRÈS (SSD NVMe + partition dédiée) :
# Requête SELECT avec JOIN : 0.08 secondes
# Temps de chargement page : 0.9 secondes
```

> [!example] Performance x28 ! En isolant la base de données sur un support rapide dédié, les performances ont été multipliées par 28. Le site peut maintenant gérer 500 visiteurs simultanés au lieu de 50.

---

## 3. ⚖️ Comparaisons et Choix Stratégiques

### MBR vs GPT : Quelle table de partition choisir ?

|Critère|MBR (Master Boot Record)|GPT (GUID Partition Table)|
|---|---|---|
|**Date de création**|1983|2000|
|**Taille disque max**|2 To|9,4 Zettaoctets (pratiquement illimité)|
|**Nombre de partitions**|4 primaires OU 3 primaires + 1 étendue (avec logiques)|128 partitions par défaut|
|**Compatibilité**|BIOS legacy|UEFI (+ BIOS avec protective MBR)|
|**Fiabilité**|Une seule copie de la table|Table dupliquée, CRC pour détecter corruption|
|**Support Windows**|Toutes versions|Windows 7+ (64 bits uniquement pour boot)|
|**Support Linux**|Toujours|Toujours|

**Cas d'usage MBR (de moins en moins) :**

- Vieux PC antérieur à 2010 avec BIOS legacy
- Disques < 2 To utilisés comme disques de données (pas de boot)
- Compatibilité avec Windows XP

**Cas d'usage GPT (RECOMMANDÉ) :**

- Tout disque > 2 To (obligatoire)
- PC récent avec UEFI (depuis ~2012)
- Serveurs (fiabilité supérieure)
- Besoin de plus de 4 partitions

> [!tip] Règle simple En 2025, utilise **GPT par défaut** sauf si tu as un PC de plus de 15 ans. Tous les PC vendus depuis 2012 ont l'UEFI.

### Comparaison des outils de partitionnement

|Outil|Type|Niveau|Cas d'usage|Avantages|Inconvénients|
|---|---|---|---|---|---|
|**fdisk**|CLI|Débutant/Intermédiaire|Création rapide de partitions MBR/GPT|Léger, toujours disponible, simple|Interface texte old-school, pas de redimensionnement|
|**parted**|CLI|Intermédiaire|Scripting, gros disques, GPT|Support GPT parfait, scriptable, redimensionnement|Syntaxe moins intuitive|
|**gdisk**|CLI|Intermédiaire|Manipulation exclusive GPT|Spécialisé GPT, puissant|GPT uniquement, syntaxe différente de fdisk|
|**gparted**|GUI|Débutant|Manipulation visuelle, live USB|Interface graphique claire, aperçu visuel|Nécessite environnement graphique|
|**cfdisk**|TUI|Débutant|Alternative conviviale à fdisk|Interface semi-graphique intuitive|Fonctionnalités limitées|
|**LVM**|Système|Avancé|Serveurs, flexibilité maximale|Redimensionnement à chaud, snapshots|Complexité accrue, couche d'abstraction|

**Scénarios recommandés :**

```bash
# Scénario 1 : Installation serveur rapide (disque 500 Go, structure simple)
→ Utiliser fdisk ou parted en ligne de commande

# Scénario 2 : Réorganiser disques sur PC de bureau (visuellement)
→ Utiliser gparted depuis un live USB

# Scénario 3 : Serveur de production avec évolution prévue
→ Utiliser LVM pour la flexibilité future

# Scénario 4 : Script d'installation automatique
→ Utiliser parted (meilleure syntaxe pour scripting)
```

### Systèmes de fichiers : quel choix pour quelle partition ?

|Système de fichiers|Partition recommandée|Pourquoi ?|Limites|
|---|---|---|---|
|**ext4**|`/`, `/home`, usage général|Éprouvé, stable, performant, journalisé|Pas de snapshots natifs, fragmentation possible|
|**XFS**|`/var/lib/mysql`, gros fichiers|Excellent pour gros volumes, peu de fragmentation|Impossible de réduire, récupération difficile|
|**Btrfs**|`/home`, `/` (utilisateurs avancés)|Snapshots, compression, déduplication|Moins stable qu'ext4, complexe|
|**swap**|Partition swap|Mémoire virtuelle|Pas un vrai système de fichiers|
|**FAT32**|Clés USB, `/boot/efi` (EFI)|Compatibilité universelle|Fichiers < 4 Go, pas de permissions|
|**NTFS**|Partage Windows/Linux|Interopérabilité|Permissions Linux limitées|

**Exemple concret : serveur mail (250 utilisateurs)**

```
/dev/sda1   30G  ext4  /           (système)
/dev/sda2   20G  ext4  /var/log    (logs)
/dev/sdb1  500G  XFS   /var/mail   (boîtes mail = millions de petits fichiers)
/dev/sdc1    2T  ext4  /backup     (sauvegardes)
```

Pourquoi XFS pour `/var/mail` ? Parce qu'un serveur mail génère énormément de petits fichiers (chaque email = 1 fichier). XFS gère mieux les gros volumes avec millions de fichiers qu'ext4.

---

## 4. ⚠️ Pièges et Erreurs Courantes

### Piège n°1 : Oublier de créer une partition swap

**Ce qui arrive :**

```bash
# Installation Ubuntu Desktop, tu choisis "Utiliser tout le disque"
# L'installateur crée :
/dev/sda1  500G  ext4  /

# Pas de partition swap !
```

**Conséquence :** Après 2 semaines d'utilisation, ton PC avec 8 Go de RAM :

- 30 onglets Chrome ouverts (5 Go de RAM)
- Gimp avec image 4K (2 Go de RAM)
- IntelliJ IDEA (1.5 Go de RAM)
- Spotify, Discord, etc. (1 Go de RAM)

→ **Total : 9.5 Go demandés, 8 Go disponibles**

Le système commence à "killer" des processus aléatoirement (OOM Killer). Ton travail non sauvegardé dans Gimp ? Perdu.

**Solution :** Toujours créer une partition swap OU un fichier swap :

```bash
# Vérifier si swap existe
swapon --show
# (vide = pas de swap)

# Créer un fichier swap de 8 Go
sudo fallocate -l 8G /swapfile
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile

# Rendre permanent dans /etc/fstab
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
```

**Règle de dimensionnement swap :**

- RAM < 8 Go → Swap = 2 × RAM
- RAM 8-16 Go → Swap = RAM
- RAM > 16 Go → Swap = 8 Go (ou RAM si hibernation souhaitée)

> [!warning] Hibernation Pour utiliser l'hibernation (suspend-to-disk), le swap DOIT être ≥ à la RAM. Un PC avec 16 Go de RAM nécessite 16 Go de swap minimum pour hiberner.

---

### Piège n°2 : Partitions trop petites pour la racine `/`

**Erreur classique :**

```
/dev/sda1   20G  ext4  /       ← TROP PETIT !
/dev/sda2  480G  ext4  /home
```

**Ce qui se passe 6 mois plus tard :**

```bash
sudo apt update
sudo apt upgrade
# ...
# 0 mis à jour, 0 nouvellement installés, 0 à enlever et 12 non mis à jour.
# Espace disque insuffisant dans /var/cache/apt/archives/
```

Tu ne peux plus mettre à jour le système ! En analysant :

```bash
df -h /
# /dev/sda1   20G   19.5G  0.5G  98%  /

du -sh /* 2>/dev/null | sort -h
# 450M   /boot
# 8.5G   /usr        (programmes)
# 6.2G   /var        (caches, logs)
# 3.8G   /opt        (logiciels tiers)
```

**Pourquoi c'est arrivé :**

- Installation de base Ubuntu : ~6 Go
- Tu as installé : Docker, LibreOffice, GIMP, Inkscape, Steam, etc.
- Chaque `apt upgrade` télécharge ~500 Mo dans `/var/cache`
- Les logs dans `/var/log` ont grossi

**Dimensionnement recommandé en 2025 :**

|Type d'installation|Taille racine `/`|Justification|
|---|---|---|
|**Serveur minimal**|20-30 Go|Système + quelques services|
|**Desktop léger**|40-50 Go|Système + apps bureautique|
|**Desktop standard**|60-80 Go|+ Steam, outils dev|
|**Workstation dev**|100-150 Go|+ Docker images, VMs, IDEs|

> [!tip] Règle d'or Prévoir 30 Go de base + 10 Go par catégorie d'usage (bureautique, dev, gaming, multimédia, etc.)

---

### Piège n°3 : Effacer le mauvais disque

**Le cauchemar absolu :**

Tu installes Linux sur un PC avec 2 disques :

- `/dev/sda` : SSD 500 Go (C: Windows avec tous tes fichiers)
- `/dev/sdb` : HDD 1 To (D: vide, pour Linux)

Tu lances l'installateur Ubuntu :

```
Écran : "Installation type"
→ Tu choisis : "Effacer le disque et installer Ubuntu"
→ Par défaut, il sélectionne /dev/sda ← TU NE REMARQUES PAS
→ Tu cliques sur "Installer maintenant"
```

**10 secondes plus tard :**

```
Formatage de /dev/sda1...
Création de la table de partitions...
```

💀 **Toutes tes données Windows sont perdues.**

**Comment l'éviter :**

1. **TOUJOURS vérifier le disque cible**

```bash
# Avant l'installation, identifier les disques :
lsblk -o NAME,SIZE,MODEL,SERIAL
# NAME   SIZE  MODEL              SERIAL
# sda    500G  Samsung_SSD_870    S4B2NX0R...  ← Windows
# sdb    1.0T  WDC_WD10EZEX       WD-WCC3F...  ← Pour Linux
```

2. **Débrancher physiquement le disque à protéger** (si PC de bureau)
    
3. **Dans l'installateur, choisir "Autre chose"** au lieu de "Effacer le disque"
    

> [!warning] CRITICAL Sur les PC portables, les disques sont souvent nommés `/dev/nvme0n1` et `/dev/nvme1n1`. Vérifie TOUJOURS avec `lsblk` avant toute manipulation !

---

### Piège n°4 : Partitions logiques vs primaires (MBR)

**Situation :** Tu as un vieux PC avec MBR, tu veux créer 5 partitions :

```
/dev/sda1   50G   /
/dev/sda2    8G   swap
/dev/sda3  200G   /home
/dev/sda4  100G   /games      ← Ça marche
/dev/sda5  142G   /backup     ← ERREUR !
```

**Message d'erreur fdisk :**

```
No free sectors available
```

**Explication :** MBR ne supporte que **4 partitions primaires maximum**. Pour en avoir plus, il faut :

1. Créer 3 partitions primaires
2. Créer 1 partition étendue (qui prend le reste du disque)
3. Créer des partitions logiques DANS la partition étendue

**Solution correcte :**

```
/dev/sda1   50G   Primaire   /
/dev/sda2    8G   Primaire   swap
/dev/sda3  200G   Primaire   /home
/dev/sda4  242G   Étendue    (conteneur)
  /dev/sda5  100G   Logique    /games
  /dev/sda6  142G   Logique    /backup
```

Avec fdisk :

```bash
fdisk /dev/sda
Command: n   # Nouvelle partition
Select: e   # e = Extended (étendue)
Partition number: 4
First sector: (default)
Last sector: (default = reste du disque)

Command: n   # Maintenant, créer les logiques
Select: l   # l = Logical
```

> [!info] GPT n'a pas ce problème Avec GPT, tu peux créer 128 partitions directement, sans ce système archaïque étendue/logique. Raison de plus pour utiliser GPT !

---

### Piège n°5 : Oublier de monter les partitions dans /etc/fstab

**Scénario :** Tu crées une partition `/dev/sdb1` pour `/var/www` :

```bash
mkfs.ext4 /dev/sdb1
mount /dev/sdb1 /var/www
rsync -av /old-www/ /var/www/
```

Tout fonctionne ! Tu redémarres le serveur pour appliquer d'autres mises à jour...

**Après le redémarrage :**

```bash
df -h
# /dev/sdb1 n'apparaît pas !

ls /var/www/
# (vide)
```

Le site web est down. Pourquoi ? Tu as oublié d'ajouter la partition dans `/etc/fstab` !

**Explication :** La commande `mount` est **temporaire**. Au reboot, le système ne sait pas qu'il doit monter `/dev/sdb1` sur `/var/www`.

**Solution :**

```bash
# 1. Récupérer l'UUID de la partition (plus stable que /dev/sdb1)
blkid /dev/sdb1
# /dev/sdb1: UUID="f8e9a234-..." TYPE="ext4"

# 2. Ajouter dans /etc/fstab
nano /etc/fstab

# Ajouter cette ligne :
UUID=f8e9a234-...  /var/www  ext4  defaults  0  2

# 3. Tester AVANT de rebooter
mount -a
# (si pas d'erreur, c'est bon !)

df -h | grep /var/www
# /dev/sdb1  100G  15G  85G  15%  /var/www

# 4. Maintenant tu peux rebooter en toute sécurité
```

**Syntaxe /etc/fstab expliquée :**

```
# <device>  <mountpoint>  <type>  <options>  <dump>  <pass>
UUID=xxx    /var/www      ext4    defaults   0       2

<device>      : UUID ou /dev/sdXY (UUID préféré car stable)
<mountpoint>  : Où monter la partition
<type>        : ext4, xfs, swap, ntfs, etc.
<options>     : defaults, noatime, ro, rw, etc.
<dump>        : 0 (pas de backup automatique) ou 1
<pass>        : 0 (pas de fsck), 1 (/, en premier), 2 (autres, après /)
```

> [!tip] Toujours utiliser UUID Pourquoi UUID plutôt que `/dev/sdb1` ? Parce que les noms peuvent changer ! Si tu ajoutes un disque, `/dev/sdb1` peut devenir `/dev/sdc1`. L'UUID, lui, est unique et ne change jamais.

---

### Piège n°6 : Redimensionner une partition montée

**Erreur du débutant :**

```bash
# Tu veux agrandir /home de 200G à 300G
df -h /home
# /dev/sda3  200G  180G  20G  91%  /home

resize2fs /dev/sda3 300G
# resize2fs: Device or resource busy
# The filesystem is mounted. Cannot resize.
```

**Pourquoi ça ne marche pas :** Tu ne peux pas redimensionner une partition **en cours d'utilisation**, c'est comme essayer de changer les roues d'une voiture qui roule.

**Solution :**

**Option 1 : Utiliser un Live USB (RECOMMANDÉ pour /home ou /)**

```bash
# 1. Booter sur Ubuntu Live USB
# 2. Ouvrir GParted
# 3. Démonter /dev/sda3 (clic droit → Unmount)
# 4. Redimensionner graphiquement
# 5. Appliquer les changements
# 6. Rebooter sur le système normal
```

**Option 2 : Mode rescue (si partition secondaire comme /var/www)**

```bash
# 1. Arrêter les services utilisant la partition
systemctl stop apache2 nginx mysql

# 2. Démonter
umount /var/www

# 3. Vérifier l'intégrité avant redimensionnement
e2fsck -f /dev/sdb1

# 4. Redimensionner d'abord la PARTITION (avec fdisk/parted)
parted /dev/sdb
  resizepart 1 350GB
  quit

# 5. Puis redimensionner le SYSTÈME DE FICHIERS
resize2fs /dev/sdb1

# 6. Remonter
mount /dev/sdb1 /var/www

# 7. Relancer les services
systemctl start apache2 nginx mysql
```

> [!warning] Double action requise Beaucoup confondent : il faut TOUJOURS redimensionner (1) la partition ET (2) le système de fichiers. L'un sans l'autre ne suffit pas !

---

### Piège n°7 : Swap file vs swap partition - confusion courante

**Mauvaise compréhension :** "J'ai créé un fichier `/swapfile` de 8 Go, mais quand je fais `lsblk`, je ne vois pas de partition swap. C'est cassé ?"

**Non ! C'est normal.**

Il existe 2 méthodes pour créer du swap :

**Méthode 1 : Partition swap (ancienne école)**

```bash
# Créer lors du partitionnement
fdisk /dev/sda
  n → nouvelle partition de 8G
  t → type 82 (Linux swap)
  
mkswap /dev/sda2
swapon /dev/sda2

# Dans /etc/fstab :
/dev/sda2  none  swap  sw  0  0

# Visible avec lsblk :
lsblk
# sda2   8G  [SWAP]
```

**Méthode 2 : Fichier swap (moderne, flexible)**

```bash
# Créer un fichier
fallocate -l 8G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

# Dans /etc/fstab :
/swapfile  none  swap  sw  0  0

# PAS visible dans lsblk (c'est un fichier, pas une partition !)
# Mais visible avec :
swapon --show
# NAME      SIZE  USED
# /swapfile  8G   200M
```

**Quelle méthode choisir ?**

|Critère|Partition swap|Fichier swap|
|---|---|---|
|**Flexibilité**|Difficile à redimensionner|Facile (supprimer/recréer)|
|**Performance**|Légèrement plus rapide (~2%)|Quasiment identique|
|**Installation**|Doit être prévu au partitionnement|Peut être ajouté après|
|**Cas d'usage**|Serveurs (performance max)|Desktop (flexibilité)|

> [!tip] Recommandation 2025 Sur desktop/laptop : **fichier swap** (flexible). Sur serveurs critiques : **partition swap** (performance).

---

## 5. 🔗 Liens avec d'Autres Concepts

### Partitionnement + LVM = La Flexibilité Ultime

Le partitionnement classique est **statique** : une fois créé, c'est compliqué à changer. **LVM** (Logical Volume Manager) ajoute une couche d'abstraction pour rendre tout **dynamique**.

**Analogie :**

- Partitionnement classique = **murs en béton** (définitifs)
- LVM = **cloisons amovibles** (tu peux déplacer à volonté)

**Exemple concret : serveur qui évolue**

Structure initiale (méthode classique) :

```
/dev/sda1   50G   /
/dev/sda2  200G   /home
/dev/sda3  250G   /var/www
```

Problème 6 mois plus tard : `/var/www` est plein (250G utilisés), mais `/home` est à 30% (60G/200G). Tu ne peux pas "donner" de l'espace de `/home` à `/var/www` facilement.

**Avec LVM :**

```bash
# Configuration initiale
PV (Physical Volume)    : /dev/sda (500G de disque physique)
VG (Volume Group)       : vg_data (pool de 500G)
LV (Logical Volumes)    :
  - lv_root     50G   → monté sur /
  - lv_home    200G   → monté sur /home
  - lv_www     250G   → monté sur /var/www
```

Quand `/var/www` est plein, tu peux **en direct** :

```bash
# Réduire /home de 100G
umount /home
e2fsck -f /dev/vg_data/lv_home
resize2fs /dev/vg_data/lv_home 100G
lvreduce -L 100G /dev/vg_data/lv_home
mount /home

# Agrandir /var/www de 100G (SANS démonter !)
lvextend -L +100G /dev/vg_data/lv_www
resize2fs /dev/vg_data/lv_www
# Le site web continue de tourner pendant l'opération !
```

**Quand utiliser LVM ?**

- ✅ Serveurs de production (évolution future incertaine)
- ✅ Environnements pro avec multiples disques
- ✅ Besoin de snapshots (sauvegardes instantanées)
- ❌ PC personnel simple (complexité inutile)
- ❌ Clé USB / disque externe (portabilité réduite)

> [!info] LVM en entreprise 90% des serveurs Linux en entreprise utilisent LVM. C'est le standard pour la flexibilité. Mais pour ton laptop perso, un partitionnement classique suffit largement.

---

### Partitionnement + RAID = La Redondance

**RAID** (Redundant Array of Independent Disks) combine plusieurs disques physiques. Le partitionnement intervient **après** la création du RAID.

**Scénario : serveur de fichiers critique**

Tu as 4 disques de 2 To. Tu veux :

- Que si 1 disque tombe en panne, aucune donnée ne soit perdue
- De bonnes performances

**Configuration RAID 10 (mirroring + striping) :**

```bash
# 1. Créer le RAID avec mdadm
mdadm --create /dev/md0 --level=10 --raid-devices=4 /dev/sda /dev/sdb /dev/sdc /dev/sdd
# → Résultat : /dev/md0 de 4 To utilisables (2+2 miroirs)

# 2. MAINTENANT, partitionner /dev/md0 comme un disque normal
parted /dev/md0
  mklabel gpt
  mkpart primary ext4 0% 50%     # 2 To
  mkpart primary ext4 50% 100%   # 2 To

# 3. Formater et monter
mkfs.ext4 /dev/md0p1
mkfs.ext4 /dev/md0p2
mount /dev/md0p1 /srv/shares
mount /dev/md0p2 /srv/backups
```

**Ordre logique :**

```
Disques physiques (/dev/sda, sdb, sdc, sdd)
         ↓
    RAID (/dev/md0)
         ↓
Partitionnement (/dev/md0p1, md0p2)
         ↓
Systèmes de fichiers (ext4)
         ↓
   Points de montage (/srv/shares, /srv/backups)
```

---

### Partitionnement + Chiffrement (LUKS)

Pour protéger les données sensibles, tu peux chiffrer des partitions avec **LUKS** (Linux Unified Key Setup).

**Cas d'usage : laptop d'un consultant**

Si le laptop est volé, les données client ne doivent PAS être accessibles.

**Configuration avec partition `/home` chiffrée :**

```bash
# 1. Créer les partitions normalement
/dev/nvme0n1p1  500M  EFI
/dev/nvme0n1p2   50G  / (non chiffré, pour booter)
/dev/nvme0n1p3  400G  (sera /home chiffré)

# 2. Chiffrer la partition /home
cryptsetup luksFormat /dev/nvme0n1p3
# Enter passphrase: ********

# 3. Ouvrir la partition chiffrée
cryptsetup luksOpen /dev/nvme0n1p3 home_crypt
# → Crée /dev/mapper/home_crypt

# 4. Formater le volume chiffré
mkfs.ext4 /dev/mapper/home_crypt

# 5. Monter
mount /dev/mapper/home_crypt /home

# 6. Configuration automatique dans /etc/crypttab
echo "home_crypt UUID=xxx none luks" >> /etc/crypttab

# 7. Et dans /etc/fstab
/dev/mapper/home_crypt  /home  ext4  defaults  0  2
```

**À chaque démarrage :** Le système demande le mot de passe LUKS avant de monter `/home`. Sans le mot de passe, impossible d'accéder aux données, même en retirant le disque.

> [!warning] Performance Le chiffrement consomme ~5-10% de CPU. Sur SSD récent, l'impact est négligeable. Sur vieux PC, ça peut ralentir.

---

### Partitionnement + Snapshots (Btrfs/LVM)

Les **snapshots** permettent de "figer" l'état d'une partition à un instant T.

**Cas pratique : mise à jour risquée**

Tu dois faire une mise à jour majeure (Debian 11 → Debian 12) sur un serveur. Si ça casse, tu veux pouvoir revenir en arrière en 30 secondes.

**Avec LVM :**

```bash
# AVANT la mise à jour
lvcreate -L 5G -s -n snap_root_avant_upgrade /dev/vg_sys/lv_root
# → Crée un snapshot de 5G de la partition racine

# Faire la mise à jour
apt update
apt dist-upgrade
# ... (30 minutes)

# Tester le serveur
systemctl status nginx mysql
# ❌ MySQL ne démarre plus !

# ROLLBACK en 30 secondes
umount /
lvconvert --merge /dev/vg_sys/snap_root_avant_upgrade
reboot
# → Le système redémarre sur l'état AVANT la mise à jour
```

**Avec Btrfs (encore plus simple) :**

```bash
# Créer un snapshot
btrfs subvolume snapshot / /.snapshots/avant_upgrade

# Si problème, booter sur snapshot depuis GRUB
# Le snapshot devient la nouvelle racine
```

---

### Partitionnement + Docker

Docker stocke ses images et conteneurs dans `/var/lib/docker`. Sur un serveur avec beaucoup de conteneurs, ça peut exploser.

**Problème typique :**

```bash
df -h
# /dev/sda1  50G  49.5G  0.5G  99%  /

du -sh /var/lib/docker
# 45G  /var/lib/docker
```

**Solution : partition dédiée**

```bash
# 1. Créer partition /dev/sdb1 de 200G
mkfs.ext4 /dev/sdb1

# 2. Arrêter Docker
systemctl stop docker

# 3. Déplacer les données
rsync -av /var/lib/docker/ /mnt/new-docker-location/

# 4. Monter la nouvelle partition
mount /dev/sdb1 /var/lib/docker

# 5. Copier les données
rsync -av /mnt/new-docker-location/ /var/lib/docker/

# 6. Ajouter dans /etc/fstab
/dev/sdb1  /var/lib/docker  ext4  defaults  0  2

# 7. Redémarrer Docker
systemctl start docker
```

---

### Partitionnement dans le Workflow TSSR Quotidien

**Ticket type : "Le serveur est lent"**

Checklist de diagnostic incluant partitionnement :

```bash
# 1. Vérifier l'espace disque (90% des problèmes)
df -h
# → Si une partition > 90%, investiguer

# 2. Identifier qui consomme
du -sh /* | sort -h
du -sh /var/* | sort -h

# 3. Vérifier les inodes (fichiers)
df -i
# → Parfois l'espace est libre, mais plus d'inodes dispo !

# 4. Vérifier les I/O disque
iostat -x 1 5
# → Si %util > 80%, le disque est saturé

# 5. Identifier processus gourmands en I/O
iotop -o
```

**Décision :**

- Si `/var/log` plein → Nettoyer + créer partition dédiée
- Si `/home` plein → Étendre partition OU ajouter disque
- Si `/` plein → Identifier services inutiles OU migration vers disque plus gros

---

## 6. 🎯 Résumé des Bonnes Pratiques

### Pour un Desktop Personnel

```
Disque 500 Go recommandé :
/dev/sda1   500M  EFI System Partition (si UEFI)
/dev/sda2    60G  / (ext4)
/dev/sda3     8G  swap
/dev/sda4   432G  /home (ext4)
```

**Justification :**

- EFI : obligatoire pour UEFI
- `/` 60 Go : confortable pour système + apps
- swap 8 Go : égal à la RAM (si tu as 8 Go)
- `/home` : le reste pour tes fichiers

---

### Pour un Serveur Web/Applicatif

```
Disque 500 Go recommandé :
/dev/sda1    30G  / (ext4)
/dev/sda2     4G  swap
/dev/sda3    20G  /var/log (ext4)
/dev/sda4   100G  /var/www (ext4)
/dev/sda5   346G  /var/lib/mysql (XFS ou ext4)
```

**Justification :**

- `/` minimal, juste le système
- `/var/log` isolé pour éviter saturation
- `/var/www` pour les sites
- `/var/lib/mysql` sur XFS pour performances

---

### Pour un Serveur de Fichiers

```
Disque 1: 500 Go (système)
/dev/sda1    50G  / (ext4)
/dev/sda2     8G  swap
/dev/sda3   442G  (réserve ou backup local)

Disque 2-5: 4×4 To en RAID 10 = 8 To utilisables
/dev/md0   8 To  /srv/shares (ext4 ou XFS)
```

---

### Commandes Essentielles à Connaître

```bash
# VISUALISATION
lsblk -f              # Vue d'ensemble (partitions + systèmes fichiers + UUID)
df -h                 # Espace disque utilisé
fdisk -l              # Liste toutes les partitions
parted /dev/sda print # Détails d'un disque

# PARTITIONNEMENT
fdisk /dev/sda        # Outil interactif MBR/GPT
parted /dev/sda       # Outil plus moderne
cfdisk /dev/sda       # Interface semi-graphique

# FORMATAGE
mkfs.ext4 /dev/sda1   # Créer système fichiers ext4
mkfs.xfs /dev/sda1    # Créer système fichiers XFS
mkswap /dev/sda2      # Créer partition swap

# MONTAGE
mount /dev/sda1 /mnt  # Monter temporairement
umount /mnt           # Démonter
mount -a              # Monter tout depuis /etc/fstab

# INFORMATIONS
blkid                 # UUID de toutes les partitions
findmnt               # Arbre des points de montage
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,UUID
```

---

## 7. 📊 Schéma Récapitulatif

```
┌─────────────────────────────────────────────────────────────┐
│                    DISQUE PHYSIQUE                          │
│                     /dev/sda (500 Go)                       │
└─────────────────────────────────────────────────────────────┘
                            │
                            │ Partitionnement
                            ▼
┌──────────────┬──────────────┬──────────────┬────────────────┐
│  /dev/sda1   │  /dev/sda2   │  /dev/sda3   │   /dev/sda4    │
│   500 MB     │    60 GB     │    8 GB      │    431.5 GB    │
│   (EFI)      │   (racine)   │   (swap)     │    (/home)     │
└──────────────┴──────────────┴──────────────┴────────────────┘
                            │
                            │ Formatage (système de fichiers)
                            ▼
┌──────────────┬──────────────┬──────────────┬────────────────┐
│    FAT32     │    ext4      │    swap      │     ext4       │
└──────────────┴──────────────┴──────────────┴────────────────┘
                            │
                            │ Montage
                            ▼
┌──────────────┬──────────────┬──────────────┬────────────────┐
│ /boot/efi    │      /       │  (mémoire)   │    /home       │
└──────────────┴──────────────┴──────────────┴────────────────┘
```

---

## 8. 🔧 Dépannage Express

### Problème : "No space left on device" mais `df -h` montre de l'espace libre

**Solution :**

```bash
# C'est probablement les inodes !
df -i
# /dev/sda1  100%  ← Tous les inodes utilisés

# Trouver le répertoire avec trop de fichiers
find / -xdev -type f | cut -d "/" -f 2 | sort | uniq -c | sort -n

# Souvent : /var/spool/mail ou /tmp avec millions de petits fichiers
```

---

### Problème : Partition ne se monte pas au boot

**Solution :**

```bash
# 1. Vérifier /etc/fstab
cat /etc/fstab
# Chercher les erreurs : UUID incorrect, type de FS erroné

# 2. Tester le montage manuellement
mount -a
# Les erreurs s'afficheront

# 3. Vérifier les UUID
blkid
# Comparer avec /etc/fstab

# 4. Mode rescue si système ne boot pas
# Booter sur live USB
mount /dev/sda2 /mnt
nano /mnt/etc/fstab
# Corriger les erreurs
umount /mnt
reboot
```

---

### Problème : "Read-only file system"

**Cause :** Erreur sur le disque, système de fichiers corrompu

**Solution :**

```bash
# 1. Démonter la partition (si possible)
umount /dev/sda3

# 2. Vérifier et réparer
e2fsck -f -y /dev/sda3
# -f : force la vérification
# -y : répond "yes" à toutes les questions

# 3. Remonter
mount /dev/sda3

# Si c'est la racine (/) :
# Booter en mode rescue et faire e2fsck
```

---

## 9. 📚 Pour Aller Plus Loin

**Concepts avancés à explorer après :**

- **LVM** : Gestion dynamique de volumes
- **RAID** : Redondance et performances
- **Btrfs** : Système de fichiers moderne avec snapshots
- **ZFS** : Système de fichiers avancé (nécessite licence spéciale)
- **Chiffrement LUKS** : Sécurité des données
- **NFS/CIFS** : Montage réseau de partitions distantes

**Ressources :**

- `man fdisk`, `man parted`, `man mkfs.ext4`
- ArchWiki : documentation exceptionnelle sur le partitionnement
- Debian Administrator's Handbook (gratuit)

---

> [!tip] Le meilleur apprentissage Crée une VM VirtualBox avec 3 disques virtuels de 20 Go. Expérimente le partitionnement, casse tout, recommence. C'est comme ça qu'on apprend vraiment !

---

**Bon courage dans ton apprentissage du partitionnement ! N'hésite pas si tu as des questions sur des cas spécifiques.** 🚀