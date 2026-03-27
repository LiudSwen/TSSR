

## 📋 Table des matières

```table-of-contents
title: 
style: nestedList # TOC style (nestedList|nestedOrderedList|inlineFirstLevel)
minLevel: 2 # Include headings from the specified level
maxLevel: 3 # Include headings up to the specified level
include: 
exclude: 
includeLinks: true # Make headings clickable
hideWhenEmpty: false # Hide TOC if no headings are found
debugInConsole: false # Print debug info in Obsidian console
```

---

## Introduction au FHS

> [!info] Qu'est-ce que le FHS ? Le **Filesystem Hierarchy Standard (FHS)** est une norme qui définit l'organisation des répertoires et leur contenu dans les systèmes Unix et Linux. Cette standardisation permet :
> 
> - Une cohérence entre les différentes distributions Linux
> - Une meilleure portabilité des scripts et applications
> - Une maintenance facilitée du système
> - Une courbe d'apprentissage réduite lors du changement de distribution

Le FHS est maintenu par la Linux Foundation et la version actuelle est la 3.0 (juin 2015). Bien que toutes les distributions respectent globalement cette norme, certaines libertés sont prises selon les philosophies de chaque distribution.

> [!tip] Pourquoi apprendre l'arborescence ? Comprendre l'arborescence Linux est fondamental pour :
> 
> - Savoir où chercher les fichiers de configuration
> - Comprendre où installer de nouvelles applications
> - Déboguer efficacement les problèmes système
> - Écrire des scripts portables
> - Effectuer des sauvegardes intelligentes

---

## Structure des répertoires principaux

### /bin - Binaires essentiels

**Rôle** : Contient les commandes essentielles utilisables par tous les utilisateurs, nécessaires en mode single-user et pour le démarrage du système.

> [!example] Commandes typiques dans /bin
> 
> ```bash
> ls /bin/
> # Exemples de commandes présentes :
> # - ls, cp, mv, rm : manipulation de fichiers
> # - cat, grep, sed : traitement de texte
> # - bash, sh : shells
> # - ps, kill : gestion de processus
> # - ping, netstat : réseau basique
> ```

**Caractéristiques importantes** :

- Accessible même si `/usr` n'est pas monté
- Contient uniquement les commandes vitales pour le système
- Exécutables binaires (pas de scripts sauf cas exceptionnels)
- Tous les utilisateurs ont le droit d'exécution

> [!warning] Évolution moderne Sur les systèmes récents (systemd), `/bin` est souvent un lien symbolique vers `/usr/bin` pour simplifier l'arborescence. Vérifiez avec :
> 
> ```bash
> ls -ld /bin
> # Si c'est un lien : lrwxrwxrwx ... /bin -> usr/bin
> ```

---

### /sbin - Binaires système

**Rôle** : Contient les commandes d'administration système, généralement réservées au superutilisateur (root).

> [!example] Commandes typiques dans /sbin
> 
> ```bash
> ls /sbin/
> # Exemples de commandes présentes :
> # - fdisk, mkfs : gestion des disques
> # - ifconfig, ip : configuration réseau
> # - iptables : pare-feu
> # - reboot, shutdown : arrêt système
> # - fsck : vérification système de fichiers
> ```

**Différence avec /bin** :

|Critère|/bin|/sbin|
|---|---|---|
|Public cible|Tous les utilisateurs|Administrateur système|
|Type de commandes|Utilisation courante|Administration système|
|Nécessité root|Non (généralement)|Oui (souvent)|
|Exemple|`ls`, `cat`, `grep`|`fdisk`, `reboot`, `iptables`|

> [!tip] Astuce pour les utilisateurs normaux Les utilisateurs normaux peuvent exécuter certaines commandes de `/sbin` pour consultation :
> 
> ```bash
> /sbin/ifconfig  # Voir la configuration réseau
> /sbin/ip addr   # Alternative moderne
> ```

---

### /etc - Configuration système

**Rôle** : Contient **tous les fichiers de configuration du système** et des applications. C'est le cœur de la configuration Linux.

> [!info] Étymologie Le nom "etc" vient de "et cetera" (et ainsi de suite), mais on l'interprète aussi comme "Editable Text Configuration".

**Structure interne importante** :

```bash
/etc/
├── passwd              # Base de données des utilisateurs
├── group               # Base de données des groupes
├── shadow              # Mots de passe chiffrés (accès restreint)
├── fstab               # Table des systèmes de fichiers à monter
├── hostname            # Nom de la machine
├── hosts               # Résolution locale de noms
├── network/            # Configuration réseau
├── ssh/                # Configuration SSH
│   └── sshd_config     # Configuration du serveur SSH
├── systemd/            # Configuration systemd
│   └── system/         # Units systemd
├── apt/                # Configuration APT (Debian/Ubuntu)
│   └── sources.list    # Dépôts de paquets
├── yum.repos.d/        # Configuration YUM (RedHat/CentOS)
├── nginx/              # Configuration Nginx
├── apache2/            # Configuration Apache (Debian)
└── httpd/              # Configuration Apache (RedHat)
```

> [!example] Consultation de configurations courantes
> 
> ```bash
> # Voir les utilisateurs du système
> cat /etc/passwd
> 
> # Voir les groupes
> cat /etc/group
> 
> # Voir la table de montage
> cat /etc/fstab
> 
> # Voir les dépôts de paquets (Debian/Ubuntu)
> cat /etc/apt/sources.list
> 
> # Voir la configuration SSH serveur
> cat /etc/ssh/sshd_config
> ```

**Caractéristiques importantes** :

- Fichiers texte modifiables (sauf exceptions comme `/etc/shadow`)
- Nécessite généralement les droits root pour modification
- Versionnage recommandé (Git) pour tracer les modifications
- Sauvegarde critique lors des mises à jour système

> [!warning] Attention aux modifications Toujours faire une copie avant de modifier un fichier de configuration critique :
> 
> ```bash
> sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup
> sudo nano /etc/ssh/sshd_config
> ```

---

### /home - Répertoires utilisateurs

**Rôle** : Contient les répertoires personnels de tous les utilisateurs (sauf root).

**Structure typique** :

```bash
/home/
├── alice/
│   ├── Documents/
│   ├── Downloads/
│   ├── .bashrc         # Configuration personnelle bash
│   ├── .ssh/           # Clés SSH personnelles
│   └── .config/        # Configurations applications
├── bob/
└── charlie/
```

> [!example] Navigation dans son home
> 
> ```bash
> # Plusieurs façons d'accéder à son home
> cd ~               # Tilde = home de l'utilisateur courant
> cd $HOME           # Variable d'environnement
> cd                 # Sans argument = home
> 
> # Accéder au home d'un autre utilisateur
> cd ~alice          # Home d'alice (si permissions OK)
> ```

**Caractéristiques importantes** :

- Chaque utilisateur a un contrôle total sur son répertoire
- Fichiers cachés (commencent par `.`) pour configurations personnelles
- Souvent monté sur une partition séparée pour faciliter les réinstallations
- Quotas disque souvent appliqués ici

> [!tip] Bonnes pratiques
> 
> - Sauvegarder régulièrement son `/home`
> - Utiliser des dotfiles (fichiers de configuration) versionnés
> - Nettoyer régulièrement les téléchargements et caches

**Fichiers de configuration personnelle courants** :

|Fichier|Usage|
|---|---|
|`.bashrc`|Configuration bash (non-login)|
|`.bash_profile`|Configuration bash (login)|
|`.profile`|Configuration shell générique|
|`.vimrc`|Configuration Vim|
|`.gitconfig`|Configuration Git|
|`.ssh/`|Clés et configuration SSH|

---

### /root - Répertoire du superutilisateur

**Rôle** : Répertoire personnel de l'utilisateur root (administrateur système).

> [!warning] Ne pas confondre avec /
> 
> - `/` (racine) : la racine de tout le système de fichiers
> - `/root` : le répertoire personnel de l'utilisateur root

**Pourquoi séparer /root de /home ?** :

- Disponible même si `/home` est sur une partition séparée non montée
- Sécurité : isoler les données de root
- Urgence : accessible en mode de secours (single-user mode)

```bash
# Accéder au répertoire root (nécessite d'être root)
sudo su -           # Devenir root avec son environnement
cd /root            # Aller dans le home de root

# Ou directement
sudo ls -la /root
```

**Contenu typique** :

- Scripts d'administration système
- Fichiers de configuration root
- Logs d'actions administratives
- Sauvegardes temporaires

> [!tip] Bonne pratique Minimiser le travail en tant que root. Privilégier `sudo` pour des commandes ponctuelles plutôt que de rester connecté en root.

---

### /var - Données variables

**Rôle** : Contient les **données variables**, c'est-à-dire les fichiers qui changent pendant le fonctionnement normal du système.

> [!info] Pourquoi "var" ? VAR = VARiable. Ce répertoire contient tout ce qui évolue avec le temps : logs, caches, files d'attente, etc.

**Structure interne importante** :

```bash
/var/
├── log/                # Fichiers de logs système et applications
│   ├── syslog          # Log système général
│   ├── auth.log        # Logs d'authentification
│   ├── apache2/        # Logs Apache
│   └── nginx/          # Logs Nginx
├── cache/              # Caches d'applications
│   └── apt/            # Cache des paquets APT
├── spool/              # Files d'attente
│   ├── mail/           # File d'attente emails
│   └── cron/           # Tâches cron en attente
├── tmp/                # Fichiers temporaires (persistants au reboot)
├── lib/                # Informations d'état des applications
│   ├── mysql/          # Bases de données MySQL
│   ├── postgresql/     # Bases de données PostgreSQL
│   └── docker/         # Données Docker
├── www/                # Contenu web (selon distribution)
└── backups/            # Sauvegardes (convention)
```

> [!example] Consultation des logs courants
> 
> ```bash
> # Logs système récents
> sudo tail -f /var/log/syslog        # Suivi temps réel (Debian/Ubuntu)
> sudo tail -f /var/log/messages      # Suivi temps réel (RedHat/CentOS)
> 
> # Logs d'authentification
> sudo cat /var/log/auth.log          # Voir les tentatives de connexion
> 
> # Logs Apache
> sudo tail /var/log/apache2/access.log    # Accès web
> sudo tail /var/log/apache2/error.log     # Erreurs web
> 
> # Espace disque utilisé par les logs
> sudo du -sh /var/log/*              # Taille de chaque fichier de log
> ```

**Caractéristiques importantes** :

- Croissance constante → surveillance nécessaire
- Souvent monté sur partition séparée (éviter de saturer `/`)
- Rotation automatique des logs (logrotate)
- Nettoyage régulier nécessaire

> [!warning] Gestion de l'espace disque `/var` peut rapidement saturer l'espace disque. Surveiller régulièrement :
> 
> ```bash
> # Vérifier l'espace disque
> df -h /var
> 
> # Trouver les plus gros répertoires dans /var
> sudo du -sh /var/* | sort -h
> 
> # Nettoyer les anciens logs (avec prudence)
> sudo journalctl --vacuum-time=7d    # Garder 7 jours de logs systemd
> ```

---

### /tmp - Fichiers temporaires

**Rôle** : Stockage de fichiers temporaires créés par les applications et les utilisateurs.

**Caractéristiques importantes** :

- Accessible en lecture/écriture par tous les utilisateurs
- Contenu **supprimé au redémarrage** (ou régulièrement selon la distribution)
- Droits spéciaux (sticky bit) pour éviter qu'un utilisateur supprime les fichiers d'un autre
- Souvent monté en tmpfs (RAM) pour plus de performances

> [!example] Utilisation de /tmp
> 
> ```bash
> # Créer un fichier temporaire
> touch /tmp/mon_fichier_temp.txt
> 
> # Créer un répertoire temporaire unique (bonne pratique)
> tmpdir=$(mktemp -d)
> echo "Répertoire temporaire : $tmpdir"
> # Utiliser $tmpdir pour votre travail
> 
> # Créer un fichier temporaire unique
> tmpfile=$(mktemp)
> echo "Fichier temporaire : $tmpfile"
> 
> # Vérifier les permissions spéciales (sticky bit)
> ls -ld /tmp
> # Résultat : drwxrwxrwt ... /tmp
> #                      ↑ sticky bit (t)
> ```

**Différence /tmp vs /var/tmp** :

|Critère|/tmp|/var/tmp|
|---|---|---|
|Persistance|Supprimé au reboot|Conservé au reboot|
|Nettoyage|Quotidien ou au reboot|Moins fréquent (30 jours)|
|Emplacement|Peut être en RAM (tmpfs)|Sur disque physique|
|Usage|Fichiers vraiment temporaires|Fichiers temporaires mais plus importants|

> [!tip] Bonnes pratiques
> 
> - Toujours utiliser `mktemp` pour créer des fichiers/dossiers temporaires uniques
> - Nettoyer ses fichiers temporaires après usage
> - Ne jamais stocker de données importantes dans `/tmp`
> - Utiliser `/var/tmp` pour des fichiers devant survivre à un reboot

---

### /usr - Hiérarchie secondaire

**Rôle** : Contient la majorité des programmes et données **en lecture seule** partagées par tous les utilisateurs. C'est la plus grande partie de l'arborescence.

> [!info] Étymologie Historiquement "User System Resources", aujourd'hui considéré comme "Unix System Resources".

**Structure interne** :

```bash
/usr/
├── bin/                # Commandes utilisateur (non essentielles)
│   └── python3, git, vim, firefox...
├── sbin/               # Commandes d'administration (non essentielles)
├── lib/                # Bibliothèques pour /usr/bin et /usr/sbin
├── lib64/              # Bibliothèques 64 bits (sur systèmes 64 bits)
├── include/            # Fichiers d'en-tête C/C++ (.h)
├── share/              # Données partagées indépendantes de l'architecture
│   ├── doc/            # Documentation
│   ├── man/            # Pages de manuel
│   ├── icons/          # Icônes
│   └── applications/   # Fichiers .desktop
├── local/              # Logiciels installés localement
│   ├── bin/            # Programmes locaux
│   ├── lib/            # Bibliothèques locales
│   └── share/          # Données locales
└── src/                # Code source (souvent vide)
```

> [!example] Navigation dans /usr
> 
> ```bash
> # Trouver l'emplacement d'une commande
> which python3          # Affiche /usr/bin/python3
> which git              # Affiche /usr/bin/git
> 
> # Lister les bibliothèques disponibles
> ls /usr/lib/
> 
> # Consulter les pages de manuel
> ls /usr/share/man/
> 
> # Voir les programmes installés localement
> ls /usr/local/bin/
> ```

**Hiérarchie /usr/local** :

`/usr/local` reproduit la structure de `/usr` mais pour les logiciels installés **manuellement** (non gérés par le gestionnaire de paquets).

|Répertoire|Usage gestionnaire de paquets|Usage installation manuelle|
|---|---|---|
|`/usr/bin`|✅ Paquets système (apt, yum)|❌|
|`/usr/local/bin`|❌|✅ Compilation manuelle|

> [!tip] Ordre de priorité dans le PATH
> 
> ```bash
> echo $PATH
> # Typiquement : /usr/local/bin:/usr/bin:/bin
> # 
> # L'ordre signifie :
> # 1. /usr/local/bin (priorité) - installations manuelles
> # 2. /usr/bin - paquets système
> # 3. /bin - essentiels
> ```

**Caractéristiques importantes** :

- Contenu en **lecture seule** pour les utilisateurs normaux
- Peut être monté en lecture seule (sécurité)
- Peut être partagé entre plusieurs machines (NFS)
- La plupart de l'espace disque utilisé se trouve ici

---

### /opt - Applications optionnelles

**Rôle** : Répertoire pour les **packages logiciels autonomes** qui ne s'intègrent pas dans la hiérarchie `/usr`. Souvent utilisé pour les logiciels commerciaux ou tiers.

**Structure typique** :

```bash
/opt/
├── google/
│   └── chrome/         # Google Chrome
├── teamviewer/         # TeamViewer
├── lampp/              # XAMPP
└── my_custom_app/      # Application personnalisée
    ├── bin/
    ├── lib/
    └── config/
```

> [!info] Philosophie de /opt Chaque application dans `/opt` doit être **autonome et auto-contenue** :
> 
> - Tous ses fichiers dans un seul sous-répertoire
> - Facile à installer : copier le dossier
> - Facile à désinstaller : supprimer le dossier

**Différence /usr vs /opt** :

|Critère|/usr|/opt|
|---|---|---|
|Gestion|Gestionnaire de paquets|Installation manuelle|
|Structure|Hiérarchie partagée|Application autonome|
|Exemple|`/usr/bin/firefox`|`/opt/google/chrome/`|
|Désinstallation|`apt remove firefox`|`rm -rf /opt/google`|

> [!example] Installation typique dans /opt
> 
> ```bash
> # Télécharger et extraire une application
> cd /tmp
> wget https://example.com/myapp-1.0.tar.gz
> tar xzf myapp-1.0.tar.gz
> 
> # Installer dans /opt
> sudo mv myapp /opt/
> 
> # Créer un lien symbolique pour l'exécutable
> sudo ln -s /opt/myapp/bin/myapp /usr/local/bin/myapp
> 
> # Maintenant accessible depuis n'importe où
> myapp --version
> ```

> [!tip] Convention de nommage Le FHS recommande : `/opt/provider/package` où :
> 
> - `provider` : nom du fournisseur (ex: google, adobe)
> - `package` : nom de l'application (ex: chrome, acrobat)

---

### /boot - Fichiers de démarrage

**Rôle** : Contient tous les fichiers nécessaires au **démarrage du système** : noyau Linux, initramfs, configuration du chargeur d'amorçage.

**Structure typique** :

```bash
/boot/
├── vmlinuz-5.15.0-56-generic       # Noyau Linux compressé
├── initrd.img-5.15.0-56-generic    # Système de fichiers initial (initramfs)
├── System.map-5.15.0-56-generic    # Table des symboles du noyau
├── config-5.15.0-56-generic        # Configuration de compilation du noyau
├── grub/                           # Configuration GRUB (bootloader)
│   ├── grub.cfg                    # Configuration GRUB (auto-généré)
│   └── grub.conf                   # Configuration utilisateur
└── efi/                            # Fichiers EFI (systèmes UEFI)
    └── EFI/
```

> [!example] Consulter les noyaux installés
> 
> ```bash
> # Lister les noyaux disponibles
> ls -lh /boot/vmlinuz*
> 
> # Voir le noyau actuellement utilisé
> uname -r
> 
> # Voir la taille du répertoire boot
> du -sh /boot
> 
> # Lister tous les fichiers avec détails
> ls -lh /boot/
> ```

**Composants importants** :

|Fichier|Description|
|---|---|
|`vmlinuz-*`|Noyau Linux compressé (bootable)|
|`initrd.img-*`|RAM disk initial pour le démarrage|
|`System.map-*`|Table de symboles pour le debugging|
|`config-*`|Options de compilation du noyau|
|`grub/grub.cfg`|Configuration du menu de démarrage|

> [!warning] Partition /boot séparée Sur de nombreux systèmes, `/boot` est une partition séparée :
> 
> - Généralement petite (200-500 Mo)
> - Doit rester accessible au bootloader
> - Peut rapidement se remplir avec plusieurs noyaux
> 
> ```bash
> # Vérifier l'espace disque dans /boot
> df -h /boot
> 
> # Nettoyer les anciens noyaux (Ubuntu/Debian)
> sudo apt autoremove --purge
> ```

**Workflow de mise à jour du noyau** :

1. Installation du nouveau noyau → fichiers dans `/boot`
2. Mise à jour de GRUB → régénération de `grub.cfg`
3. Au redémarrage → GRUB propose les différents noyaux
4. Le système charge le noyau sélectionné depuis `/boot`

---

### /dev - Fichiers de périphériques

**Rôle** : Contient les **fichiers spéciaux représentant les périphériques** (devices). Sous Linux, tout est fichier, y compris le matériel.

> [!info] Philosophie Unix "Everything is a file" - Tous les périphériques sont accessibles comme des fichiers, ce qui unifie l'interface d'accès.

**Types de périphériques** :

|Type|Préfixe|Description|Exemple|
|---|---|---|---|
|Bloc|`b`|Périphériques avec accès par blocs (stockage)|`sda`, `nvme0n1`|
|Caractère|`c`|Périphériques avec accès séquentiel|`tty`, `random`|
|Liens|`l`|Liens symboliques|`stdout`, `stdin`|

> [!example] Exploration de /dev
> 
> ```bash
> # Lister les périphériques avec leur type
> ls -l /dev/ | head -20
> # b = bloc, c = caractère
> 
> # Disques durs et partitions
> ls -l /dev/sd*           # Disques SATA/SAS/USB
> ls -l /dev/nvme*         # Disques NVMe
> 
> # Terminaux
> ls -l /dev/tty*          # Terminaux
> 
> # Périphériques spéciaux
> ls -l /dev/null          # Trou noir (ignore toute écriture)
> ls -l /dev/zero          # Source infinie de zéros
> ls -l /dev/random        # Générateur aléatoire
> ```

**Périphériques importants** :

```bash
/dev/
├── sda, sdb, sdc...        # Disques SATA/SCSI (a=premier, b=second...)
│   ├── sda1                # Première partition du disque sda
│   ├── sda2                # Deuxième partition
│   └── sda3
├── nvme0n1, nvme1n1...     # Disques NVMe
│   ├── nvme0n1p1           # Première partition
│   └── nvme0n1p2           # Deuxième partition
├── tty                     # Terminal actuel
├── tty1, tty2...           # Consoles virtuelles
├── pts/                    # Pseudo-terminaux (SSH, terminal émulé)
│   ├── 0, 1, 2...
├── null                    # Périphérique null (absorbe tout)
├── zero                    # Source de zéros
├── random                  # Générateur aléatoire (bloquant)
├── urandom                 # Générateur aléatoire (non-bloquant)
├── loop0, loop1...         # Périphériques loop (montage d'images)
└── mapper/                 # Périphériques logiques (LVM, LUKS)
```

> [!example] Utilisation pratique des périphériques
> 
> ```bash
> # Rediriger la sortie vers /dev/null (ignorer)
> commande_bavarde > /dev/null 2>&1
> 
> # Générer des données aléatoires
> head -c 32 /dev/urandom | base64    # 32 octets aléatoires en base64
> 
> # Créer un fichier rempli de zéros (1 Mo)
> dd if=/dev/zero of=fichier.bin bs=1M count=1
> 
> # Effacer un disque (ATTENTION : destructif !)
> sudo dd if=/dev/zero of=/dev/sdX bs=1M status=progress
> 
> # Voir les partitions d'un disque
> sudo fdisk -l /dev/sda
> ```

**Nomenclature des disques** :

|Préfixe|Type de disque|
|---|---|
|`sd*`|SATA, SAS, SCSI, USB|
|`hd*`|IDE (ancien, rare)|
|`nvme*`|NVMe (SSD moderne)|
|`mmcblk*`|Carte SD / eMMC|
|`vd*`|Disque virtuel (KVM)|

> [!warning] Périphériques volatiles `/dev` est géré dynamiquement par `udev`. Les fichiers apparaissent/disparaissent selon les périphériques connectés. Ne jamais créer manuellement de fichiers dans `/dev`.

---

### /proc - Informations processus

**Rôle** : Système de fichiers **virtuel** qui expose les informations du noyau et des processus en cours. Rien n'est réellement stocké sur disque.

> [!info] Système de fichiers virtuel `/proc` est monté en **procfs**, un système de fichiers en mémoire. Les "fichiers" sont générés à la volée par le noyau quand on les lit.

**Structure** :

```bash
/proc/
├── [PID]/              # Un répertoire par processus (PID = numéro)
│   ├── cmdline         # Ligne de commande du processus
│   ├── status          # Statut détaillé
│   ├── environ         # Variables d'environnement
│   ├── fd/             # File descriptors ouverts
│   └── maps            # Carte mémoire
├── cpuinfo             # Informations sur le CPU
├── meminfo             # Informations sur la mémoire
├── version             # Version du noyau
├── uptime              # Temps de fonctionnement
├── loadavg             # Charge moyenne
├── filesystems         # Systèmes de fichiers supportés
└── net/                # Informations réseau
    ├── dev             # Interfaces réseau
    └── tcp             # Connexions TCP
```

> [!example] Consultation d'informations système
> 
> ```bash
> # Informations CPU
> cat /proc/cpuinfo                   # Détails du processeur
> grep -c processor /proc/cpuinfo    # Nombre de cœurs
> 
> # Informations mémoire
> cat /proc/meminfo                   # Mémoire détaillée
> free -h                             # Version formatée (lit /proc/meminfo)
> 
> # Version du noyau
> ```

cat /proc/version cat /proc/sys/kernel/osrelease # Version courte

# Temps de fonctionnement

cat /proc/uptime # En secondes uptime # Version formatée

# Charge système

cat /proc/loadavg # Charge moyenne (1, 5, 15 min)

# Informations d'un processus spécifique

cat /proc/1234/cmdline # Commande du processus PID 1234 cat /proc/1234/status # Statut complet ls -l /proc/1234/fd/ # Fichiers ouverts

# Processus actuels

ls -d /proc/[0-9]* # Liste de tous les PID

````

> [!tip] Utilisation pratique
> De nombreuses commandes Linux lisent `/proc` en arrière-plan :
> - `top`, `htop` → lisent `/proc/[PID]/`
> - `free` → lit `/proc/meminfo`
> - `uptime` → lit `/proc/uptime` et `/proc/loadavg`
> - `lscpu` → lit `/proc/cpuinfo`

**Informations réseau dans /proc** :

```bash
# Interfaces réseau et statistiques
cat /proc/net/dev

# Connexions TCP actives
cat /proc/net/tcp

# Table de routage
cat /proc/net/route

# Statistiques réseau
cat /proc/net/netstat
````

> [!warning] Ne jamais écrire dans /proc sans savoir Certains fichiers dans `/proc/sys/` permettent de modifier des paramètres du noyau en temps réel, mais cela nécessite une bonne compréhension du système.

---

### /sys - Informations système

**Rôle** : Système de fichiers **virtuel** (sysfs) qui expose la structure des périphériques et pilotes du noyau. Plus moderne et structuré que `/proc`.

> [!info] Différence /proc vs /sys
> 
> - `/proc` : orienté processus et informations générales
> - `/sys` : orienté matériel et pilotes (drivers)

**Structure** :

```bash
/sys/
├── block/              # Périphériques bloc (disques)
│   ├── sda/
│   └── nvme0n1/
├── class/              # Classes de périphériques
│   ├── net/            # Interfaces réseau
│   ├── input/          # Périphériques d'entrée (clavier, souris)
│   ├── backlight/      # Luminosité d'écran
│   └── power_supply/   # Batteries, alimentations
├── devices/            # Hiérarchie physique des périphériques
├── bus/                # Bus système (PCI, USB, etc.)
│   ├── pci/
│   └── usb/
├── module/             # Modules du noyau chargés
└── power/              # Gestion de l'énergie
```

> [!example] Exploration de /sys
> 
> ```bash
> # Informations sur un disque
> cat /sys/block/sda/size              # Taille en blocs de 512 octets
> cat /sys/block/sda/device/model      # Modèle du disque
> 
> # Interfaces réseau
> ls /sys/class/net/                   # Lister les interfaces
> cat /sys/class/net/eth0/address      # Adresse MAC
> cat /sys/class/net/eth0/operstate    # État (up/down)
> 
> # Luminosité d'écran (laptop)
> cat /sys/class/backlight/*/brightness
> cat /sys/class/backlight/*/max_brightness
> 
> # Batterie (laptop)
> cat /sys/class/power_supply/BAT0/capacity      # Pourcentage
> cat /sys/class/power_supply/BAT0/status        # État (Charging/Discharging)
> 
> # Modules du noyau chargés
> ls /sys/module/
> ```

> [!tip] Modification de paramètres Contrairement à `/proc`, `/sys` est davantage conçu pour la modification de paramètres système :
> 
> ```bash
> # Changer la luminosité de l'écran
> echo 500 | sudo tee /sys/class/backlight/intel_backlight/brightness
> 
> # Activer/désactiver une interface réseau (via sysfs)
> echo 1 | sudo tee /sys/class/net/eth0/device/enable
> ```

---

### /lib - Bibliothèques partagées

**Rôle** : Contient les **bibliothèques essentielles** nécessaires aux programmes de `/bin` et `/sbin`.

**Structure** :

```bash
/lib/
├── x86_64-linux-gnu/       # Bibliothèques (architecture spécifique)
│   ├── libc.so.6           # Bibliothèque C standard
│   ├── libm.so.6           # Bibliothèque mathématique
│   └── ...
├── modules/                # Modules du noyau
│   └── 5.15.0-56-generic/  # Modules pour ce noyau
│       ├── kernel/
│       └── ...
├── firmware/               # Firmware pour périphériques
└── systemd/                # Fichiers systemd
```

> [!info] Bibliothèques partagées Les bibliothèques (`.so` = Shared Object) sont l'équivalent Linux des DLL Windows. Elles évitent la duplication de code entre programmes.

> [!example] Consulter les bibliothèques
> 
> ```bash
> # Lister les bibliothèques d'un programme
> ldd /bin/ls                          # Dépendances de la commande ls
> 
> # Trouver une bibliothèque spécifique
> ldconfig -p | grep libc              # Chercher libc
> 
> # Modules du noyau disponibles
> ls /lib/modules/$(uname -r)/kernel/
> 
> # Modules actuellement chargés
> lsmod
> ```

**Différence /lib vs /usr/lib** :

|Critère|/lib|/usr/lib|
|---|---|---|
|Usage|Bibliothèques essentielles|Bibliothèques non essentielles|
|Nécessité|Démarrage système|Après montage de /usr|
|Programmes|Pour /bin et /sbin|Pour /usr/bin et /usr/sbin|

> [!warning] /lib vs /lib64 Sur les systèmes 64 bits, vous verrez souvent :
> 
> - `/lib` ou `/lib32` : bibliothèques 32 bits
> - `/lib64` : bibliothèques 64 bits
> 
> Souvent, `/lib` est un lien symbolique vers `/lib64` ou vers `/usr/lib`.

---

### /mnt et /media - Points de montage

**Rôle** : Répertoires pour **monter temporairement** des systèmes de fichiers externes.

**Différence entre /mnt et /media** :

|Répertoire|Usage|Qui l'utilise|
|---|---|---|
|`/mnt`|Montages **manuels** temporaires|Administrateur|
|`/media`|Montages **automatiques** de médias amovibles|Système (udev, udisks)|

> [!example] Utilisation de /mnt
> 
> ```bash
> # Monter manuellement une partition
> sudo mount /dev/sdb1 /mnt
> ls /mnt                              # Voir le contenu
> sudo umount /mnt                     # Démonter
> 
> # Créer des sous-répertoires pour organisation
> sudo mkdir /mnt/usb
> sudo mkdir /mnt/backup
> sudo mount /dev/sdb1 /mnt/usb
> sudo mount /dev/sdc1 /mnt/backup
> 
> # Monter une image ISO
> sudo mount -o loop image.iso /mnt
> ```

> [!example] Utilisation de /media
> 
> ```bash
> # Insérer une clé USB → montage automatique dans /media
> ls /media/$USER/                     # Voir les médias montés
> 
> # Exemple de chemin automatique
> # /media/alice/USB_DRIVE/
> # /media/alice/UBUNTU_2204/
> ```

**Structure typique** :

```bash
/mnt/                   # Vide par défaut, pour usage manuel
├── usb/                # (créé par admin si besoin)
├── backup/
└── nas/

/media/
└── alice/              # Un sous-répertoire par utilisateur
    ├── USB_DRIVE/      # Clé USB montée automatiquement
    └── DATA_DISK/      # Disque externe
```

> [!tip] Bonnes pratiques
> 
> - Utiliser `/mnt` pour les montages manuels et scripts
> - Laisser `/media` pour les montages automatiques du système
> - Toujours démonter avant de retirer un périphérique :
> 
> ```bash
> sudo umount /mnt/usb
> # ou
> udisksctl unmount -b /dev/sdb1       # Pour montages automatiques
> ```

---

### /srv - Données de services

**Rôle** : Contient les **données servies par le système** (sites web, FTP, etc.).

> [!info] Philosophie de /srv Séparer les données servies (contenu) de la configuration (/etc) et des logs (/var/log). C'est le "public" du serveur.

**Structure typique** :

```bash
/srv/
├── www/                # Données de sites web
│   ├── site1/
│   └── site2/
├── ftp/                # Données FTP
├── git/                # Dépôts Git
└── nfs/                # Exports NFS
```

> [!example] Utilisation courante
> 
> ```bash
> # Structure d'un serveur web
> /srv/www/monsite.com/
> ├── public_html/        # Contenu public
> │   ├── index.html
> │   └── images/
> └── logs/               # Logs spécifiques au site
> 
> # Configuration Apache pointant vers /srv
> # DocumentRoot /srv/www/monsite.com/public_html
> ```

**Différence /srv vs /var/www** :

|Critère|/srv|/var/www|
|---|---|---|
|Standard FHS|✅ Recommandé|⚠️ Tradition (non FHS)|
|Usage|Données servies|Historique Debian/Ubuntu|
|Philosophie|Propre et organisé|Mélangé avec /var|

> [!tip] Bonne pratique moderne Privilégier `/srv` pour les nouvelles installations selon le FHS, mais `/var/www` reste très courant sur Debian/Ubuntu pour des raisons historiques.

---

## Différences entre distributions

Bien que le FHS soit un standard, chaque distribution prend quelques libertés :

### Debian / Ubuntu

```bash
# Chemins spécifiques
/var/www/                           # Sites web (non FHS mais tradition)
/etc/apache2/                       # Apache
/etc/apt/                           # Gestionnaire de paquets
/var/cache/apt/                     # Cache APT

# Fusion des répertoires (depuis Debian 10)
/bin → /usr/bin                     # Liens symboliques
/sbin → /usr/sbin
/lib → /usr/lib
```

### Red Hat / CentOS / Rocky / Alma

```bash
# Chemins spécifiques
/etc/httpd/                         # Apache
/etc/yum.repos.d/                   # Dépôts YUM
/var/www/html/                      # Sites web par défaut

# Utilisation de SELinux
/etc/selinux/                       # Configuration SELinux
/.autorelabel                       # Trigger de relabellisation
```

### Arch Linux

```bash
# Philosophie minimaliste
/usr/local/                         # Rarement utilisé (AUR privilégié)

# Fusion complète (depuis 2013)
/bin → /usr/bin                     # Tout unifié dans /usr
/sbin → /usr/bin
/lib → /usr/lib
/lib64 → /usr/lib

# Gestionnaire de paquets
/var/cache/pacman/                  # Cache Pacman
/etc/pacman.conf                    # Configuration Pacman
```

### Différences résumées

|Aspect|Debian/Ubuntu|RedHat/CentOS|Arch|
|---|---|---|---|
|Apache|`/etc/apache2/`|`/etc/httpd/`|`/etc/httpd/`|
|Web root|`/var/www/`|`/var/www/html/`|Flexible|
|Paquets|APT (`.deb`)|YUM/DNF (`.rpm`)|Pacman|
|Fusion /bin|Depuis v10|En cours|Depuis 2013|
|Philosophie|Stabilité|Entreprise|Rolling, simplicité|

> [!tip] Portabilité des scripts Pour écrire des scripts portables :
> 
> ```bash
> # ✅ Bon : chercher dans PATH
> command -v python3
> 
> # ❌ Éviter : chemins en dur
> /usr/bin/python3
> 
> # ✅ Bon : utiliser des variables
> APACHE_CONF="/etc/apache2"
> [ -d "$APACHE_CONF" ] || APACHE_CONF="/etc/httpd"
> ```

---

## Bonnes pratiques

### 1. Comprendre avant de modifier

> [!warning] Règle d'or Ne jamais modifier un fichier système sans comprendre son rôle. Toujours sauvegarder avant modification.

```bash
# Toujours faire une sauvegarde
sudo cp /etc/important.conf /etc/important.conf.backup.$(date +%Y%m%d)

# Ou versionner avec Git
cd /etc
sudo git init
sudo git add important.conf
sudo git commit -m "Backup avant modification"
```

### 2. Respecter la hiérarchie

**Installation de logiciels** :

|Méthode|Destination|Quand l'utiliser|
|---|---|---|
|Gestionnaire de paquets|`/usr/`|✅ Toujours privilégier|
|Compilation manuelle|`/usr/local/`|Si pas de paquet disponible|
|Application autonome|`/opt/`|Logiciels commerciaux/tiers|
|Script personnel|`~/bin/`|Usage personnel uniquement|

```bash
# ✅ Bon
sudo apt install nginx              # → /usr/bin/nginx

# ✅ Acceptable
./configure --prefix=/usr/local     # Compilation manuelle
sudo make install                   # → /usr/local/bin/

# ✅ Acceptable
sudo cp -r myapp /opt/myapp/        # Application autonome

# ❌ Mauvais
sudo cp monscript.sh /bin/          # N'utilisez jamais /bin directement !
```

### 3. Surveiller les répertoires critiques

**Surveillance de l'espace disque** :

```bash
# Vérifier régulièrement
df -h                               # Vue d'ensemble
du -sh /* 2>/dev/null | sort -h     # Taille par répertoire racine

# Répertoires à surveiller particulièrement
du -sh /var/log                     # Logs
du -sh /var/cache                   # Caches
du -sh /tmp                         # Temporaires
du -sh /home/*                      # Utilisateurs
```

> [!tip] Automatiser la surveillance
> 
> ```bash
> # Créer un script de monitoring
> #!/bin/bash
> THRESHOLD=80
> USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
> 
> if [ $USAGE -gt $THRESHOLD ]; then
>     echo "ALERTE: Disque à ${USAGE}% !"
>     du -sh /* 2>/dev/null | sort -h | tail -5
> fi
> ```

### 4. Sécuriser les données

**Séparation des partitions recommandée** :

|Partition|Raison|Taille conseillée|
|---|---|---|
|`/boot`|Bootloader accessible|500 Mo - 1 Go|
|`/`|Système de base|20-50 Go|
|`/home`|Données utilisateurs|Selon besoin|
|`/var`|Logs et données variables|10-50 Go|
|`/tmp`|Temporaires (tmpfs si possible)|2-5 Go|

**Avantages** :

- Reinstallation sans perte de données (`/home` préservé)
- Limitation de la saturation d'espace (un répertoire ne peut saturer `/`)
- Optimisation possible (options de montage différentes)
- Sécurité renforcée (options noexec sur `/tmp`)

### 5. Nettoyer régulièrement

```bash
# Nettoyer les paquets (Debian/Ubuntu)
sudo apt autoremove                 # Supprimer les paquets inutiles
sudo apt clean                      # Vider le cache APT

# Nettoyer les logs anciens
sudo journalctl --vacuum-time=7d    # Garder 7 jours de logs systemd
sudo find /var/log -name "*.gz" -mtime +30 -delete  # Logs compressés >30j

# Nettoyer /tmp si nécessaire (sera fait au reboot)
sudo find /tmp -type f -atime +7 -delete    # Fichiers non accédés depuis 7j

# Nettoyer les anciens noyaux (Ubuntu)
sudo apt autoremove --purge
```

### 6. Documenter ses modifications

> [!tip] Traçabilité
> 
> ```bash
> # Tenir un journal des modifications système
> echo "$(date) - Modifié /etc/ssh/sshd_config - Désactivé root login" | \
>   sudo tee -a /root/system_changes.log
> 
> # Ou utiliser Git dans /etc
> cd /etc
> sudo git add .
> sudo git commit -m "Désactivé root login SSH"
> ```

### 7. Utiliser les bons outils

**Pour naviguer dans l'arborescence** :

```bash
# Trouver des fichiers
find / -name "config.conf" 2>/dev/null
locate config.conf                  # Plus rapide (nécessite updatedb)

# Explorer visuellement
tree -L 2 /etc                      # Arbre des 2 premiers niveaux
ncdu /var                           # Analyseur d'espace disque interactif

# Rechercher du contenu
grep -r "mot-clé" /etc/             # Chercher dans les fichiers de config
```

### 8. Comprendre les liens symboliques

```bash
# Vérifier si un répertoire est un lien
ls -ld /bin
# Si lien : lrwxrwxrwx ... /bin -> usr/bin

# Suivre un lien
readlink /bin                       # Affiche usr/bin
readlink -f /bin                    # Affiche le chemin absolu

# Créer un lien symbolique
ln -s /chemin/source /chemin/lien
```

---

## 🎯 Points clés à retenir

> [!summary] Résumé de l'arborescence Linux
> 
> **Répertoires essentiels (système de base)** :
> 
> - `/` : Racine de tout
> - `/bin`, `/sbin` : Commandes essentielles
> - `/etc` : Configuration système
> - `/boot` : Fichiers de démarrage
> 
> **Répertoires de données** :
> 
> - `/home` : Données utilisateurs
> - `/root` : Données de l'administrateur
> - `/tmp` : Temporaires (volatil)
> - `/var` : Données variables (logs, caches)
> 
> **Répertoires de programmes** :
> 
> - `/usr` : Applications et bibliothèques principales
> - `/usr/local` : Installations manuelles
> - `/opt` : Applications autonomes
> 
> **Répertoires virtuels** :
> 
> - `/dev` : Périphériques
> - `/proc` : Informations processus et noyau
> - `/sys` : Informations matériel et pilotes
> 
> **Répertoires de montage** :
> 
> - `/mnt` : Montages manuels
> - `/media` : Montages automatiques

> [!tip] Pour approfondir
> 
> - Explorez avec `tree`, `ls -la`, `du`, `df`
> - Lisez les man pages : `man hier` (hiérarchie du système de fichiers)
> - Consultez le FHS complet : https://refspecs.linuxfoundation.org/fhs.shtml
> - Pratiquez sur une VM pour comprendre sans risque

---

**🔚 Fin du cours sur l'arborescence Linux (FHS)**