

📘 PARTIE 1 : Premiers pas et différences entre distributions Fichier Obsidian suggéré : `01-premiers-pas-differences.md`

**Sujets à couvrir :**

1. Interface et environnement
    - Bureau GNOME sur Ubuntu Desktop
    - Console uniquement sur Ubuntu Server et Debian (installation minimale)
    - Connexion locale
2. Outils d'administration préinstallés
    - Différences dans les paquets par défaut
    - Présence ou absence de sudo configuré
    - Outils réseau disponibles
3. Première mise à jour
    - apt update et apt upgrade
    - Différences dans les dépôts
    - Configuration des sources

---

📘 PARTIE 2 : Gestion des utilisateurs et des permissions Fichier Obsidian suggéré : `02-utilisateurs-permissions.md`

**Sujets à couvrir :**

1. Comptes utilisateurs
    - Création et suppression d'utilisateurs (useradd, adduser, userdel)
    - Modification des comptes utilisateurs (usermod)
    - Gestion des mots de passe (passwd, chage)
    - Fichiers /etc/passwd et /etc/shadow
2. Comptes groupes
    - Création et suppression de groupes (groupadd, groupdel)
    - Ajout/retrait d'utilisateurs aux groupes
    - Groupes primaires et secondaires
    - Fichier /etc/group
3. Le compte root
    - Rôle et spécificités du compte root
    - Différences Ubuntu/Debian (root activé ou non)
    - Activation/désactivation du compte root
    - Bonnes pratiques de sécurité
4. Élévation de privilèges
    - Configuration par défaut de sudo (Ubuntu vs Debian)
    - Configuration de sudoers (/etc/sudoers)
    - Commande visudo
    - Différence entre su et sudo

---

📘 PARTIE 3 : Système de fichiers et permissions Fichier Obsidian suggéré : `03-systeme-fichiers-permissions.md`

**Sujets à couvrir :**

1. Arborescence Linux (FHS)
    - Structure des répertoires (/etc, /var, /home, /usr, /bin, /sbin, /tmp, /opt)
    - Rôle de chaque répertoire principal
    - Différences mineures entre distributions
2. Permissions de fichiers
    - Lecture, écriture, exécution (rwx)
    - Propriétaire, groupe, autres
    - Représentation octale et symbolique
    - Commandes chmod, chown, chgrp
3. Permissions avancées
    - SUID, SGID, Sticky bit
    - Umask
    - ACL (Access Control Lists)

---

📘 PARTIE 4 : Configuration réseau Ubuntu Fichier Obsidian suggéré : `04-configuration-reseau-ubuntu.md`

**Sujets à couvrir :**

1. Ubuntu Server - Netplan
    - Structure des fichiers YAML (/etc/netplan/)
    - Configuration IP statique avec Netplan
    - Configuration DHCP avec Netplan
    - Application des changements (netplan apply, netplan try)
2. Ubuntu Desktop - NetworkManager
    - Interface graphique de configuration
    - Commande nmcli en ligne de commande
    - Fichiers de configuration NetworkManager
3. Configuration DNS sur Ubuntu
    - systemd-resolved
    - Fichier /etc/resolv.conf
    - Configuration DNS dans Netplan et NetworkManager

---

📘 PARTIE 5 : Configuration réseau Debian et diagnostic Fichier Obsidian suggéré : `05-configuration-reseau-debian-diagnostic.md`

**Sujets à couvrir :**

1. Debian - interfaces
    - Fichier /etc/network/interfaces
    - Configuration IP statique traditionnelle
    - Configuration DHCP
    - Commandes ifup/ifdown
    - Service networking
2. Configuration DNS sur Debian
    - Fichier /etc/resolv.conf
    - Différences avec Ubuntu
3. Outils de diagnostic réseau
    - ip addr, ip link, ip route
    - ping, traceroute
    - ss, netstat
    - nmcli, ifconfig (obsolète)

---

📘 PARTIE 6 : Gestion des paquets Fichier Obsidian suggéré : `06-gestion-paquets.md`

**Sujets à couvrir :**

1. APT (commun à Ubuntu et Debian)
    - apt update, apt upgrade, apt full-upgrade
    - Installation et suppression de paquets
    - Recherche de paquets (apt search, apt-cache)
    - Nettoyage (apt clean, apt autoremove)
2. Gestion des dépôts
    - /etc/apt/sources.list (Debian)
    - /etc/apt/sources.list.d/ (Ubuntu)
    - Différences dans les dépôts par défaut
    - Ajout de PPA (Ubuntu uniquement)
    - Clés GPG des dépôts
3. Outils de bas niveau
    - dpkg pour manipulation directe
    - Installation de paquets .deb
    - dpkg -l, dpkg -L, dpkg -S
4. Formats alternatifs
    - Snap (Ubuntu)
    - Différences selon les distributions

---

📘 PARTIE 7 : Systemd - Gestion des services Fichier Obsidian suggéré : `07-systemd-gestion-services.md`

**Sujets à couvrir :**

1. Commandes systemctl de base
    - start, stop, restart, reload, status
    - enable, disable (activation au démarrage)
    - is-active, is-enabled
    - list-units, list-unit-files
2. Unités systemd
    - Types d'unités (service, socket, timer, mount, target)
    - Localisation des fichiers unit (/etc/systemd/, /lib/systemd/)
    - Lecture d'un fichier unit
    - Structure d'un fichier .service
3. Gestion des targets
    - multi-user.target, graphical.target
    - Changement de target (isolate)
    - Target par défaut (get-default, set-default)

---

📘 PARTIE 8 : Systemd - Journalisation Fichier Obsidian suggéré : `08-systemd-journalisation.md`

**Sujets à couvrir :**

1. Bases de journalctl
    - Consultation des logs
    - Navigation dans les logs
    - Options -f (follow), -n (nombre de lignes), -r (reverse)
2. Filtrage des logs
    - Filtrage par service (-u)
    - Filtrage par priorité (-p)
    - Filtrage par date (--since, --until)
    - Filtrage par boot (-b)
3. Configuration de la journalisation
    - Logs persistants vs volatiles
    - Configuration dans /etc/systemd/journald.conf
    - Gestion de l'espace disque des logs

---

📘 PARTIE 9 : Stockage - Disques et partitionnement Fichier Obsidian suggéré : `09-stockage-disques-partitionnement.md`

**Sujets à couvrir :**

1. Visualisation des disques
    - lsblk pour visualiser la structure
    - fdisk -l pour lister les disques
    - blkid pour identifier les partitions
2. Partitionnement de disques
    - fdisk pour partitionnement MBR
    - gdisk et parted pour partitionnement GPT
    - Différences MBR vs GPT
3. Formatage de partitions
    - mkfs pour créer des systèmes de fichiers
    - Types de systèmes de fichiers (ext4, xfs, btrfs)
    - Création de swap (mkswap)

---

📘 PARTIE 10 : Stockage - Montage et fstab Fichier Obsidian suggéré : `10-stockage-montage-fstab.md`

**Sujets à couvrir :**

1. Montage manuel
    - Commande mount
    - Commande umount
    - Options de montage courantes
2. Montage automatique avec fstab
    - Structure du fichier /etc/fstab
    - Identification par UUID et LABEL
    - Options de montage dans fstab
    - Commande mount -a pour tester fstab
3. Points de montage
    - Création de points de montage
    - Conventions de nommage
    - Montage de partitions supplémentaires

---

📘 PARTIE 11 : Stockage - LVM Fichier Obsidian suggéré : `11-stockage-lvm.md`

**Sujets à couvrir :**

1. Concepts du LVM
    - Volumes physiques (PV)
    - Groupes de volumes (VG)
    - Volumes logiques (LV)
    - Avantages du LVM
2. Création d'une structure LVM
    - pvcreate pour créer des volumes physiques
    - vgcreate pour créer des groupes de volumes
    - lvcreate pour créer des volumes logiques
    - Formatage et montage de volumes logiques
3. Gestion et redimensionnement
    - Commandes de visualisation (pvs, vgs, lvs, pvdisplay, vgdisplay, lvdisplay)
    - Extension de volumes logiques (lvextend)
    - Réduction de volumes logiques (lvreduce)
    - Extension de systèmes de fichiers (resize2fs, xfs_growfs)

---

📘 PARTIE 12 : Surveillance des ressources système Fichier Obsidian suggéré : `12-surveillance-ressources.md`

**Sujets à couvrir :**

1. Surveillance de la charge système
    - uptime et load average
    - top - interface interactive
    - htop - alternative améliorée
2. Surveillance de la mémoire
    - free - utilisation de la mémoire
    - Comprendre la mémoire cache et buffers
    - Surveillance du swap
3. Surveillance du stockage
    - df - espace disque des systèmes de fichiers
    - du - utilisation de l'espace par répertoire
    - Options utiles (-h, -a, --max-depth)

---

📘 PARTIE 13 : Gestion des processus Fichier Obsidian suggéré : `13-gestion-processus.md`

**Sujets à couvrir :**

1. Visualisation des processus
    - ps - lister les processus
    - Options courantes (aux, ef, -u)
    - pstree - arborescence des processus
2. Gestion des processus
    - Signaux Linux (SIGTERM, SIGKILL, SIGHUP, etc.)
    - kill - envoyer des signaux par PID
    - killall - envoyer des signaux par nom
    - pkill - envoyer des signaux avec critères
3. Priorités et jobs
    - nice et renice pour les priorités
    - Jobs en arrière-plan (&, bg, fg)
    - nohup et disown

---

📘 PARTIE 14 : Logs système Fichier Obsidian suggéré : `14-logs-systeme.md`

**Sujets à couvrir :**

1. Répertoire /var/log
    - Organisation du répertoire
    - Différences selon les distributions
2. Fichiers de logs importants
    - /var/log/syslog ou /var/log/messages
    - /var/log/auth.log - logs d'authentification
    - /var/log/kern.log - logs du noyau
    - /var/log/apt/ - logs de gestion de paquets
3. Consultation des logs
    - cat, less, tail pour lire les logs
    - tail -f pour suivre en temps réel
    - grep pour rechercher dans les logs

---

📘 PARTIE 15 : Tâches planifiées Fichier Obsidian suggéré : `15-taches-planifiees.md`

**Sujets à couvrir :**

1. Cron
    - Structure de crontab (minute, heure, jour, mois, jour de semaine)
    - crontab -e, -l, -r pour gérer les crontabs utilisateurs
    - Fichiers /etc/crontab, /etc/cron.d/
    - Répertoires cron.daily, cron.weekly, cron.monthly, cron.hourly
2. Systemd timers
    - Alternative moderne à cron
    - Création d'un timer simple
    - Commandes systemctl pour les timers (list-timers)
3. Commande at
    - Planification de tâches ponctuelles
    - at, atq, atrm

---

📘 PARTIE 16 : Pare-feu avec UFW Fichier Obsidian suggéré : `16-pare-feu-ufw.md`

**Sujets à couvrir :**

1. Installation et activation d'UFW
    - Installation (si nécessaire selon la distribution)
    - Activation et désactivation (ufw enable/disable)
    - Vérification du statut (ufw status verbose)
2. Gestion des règles
    - Règles de base (allow, deny, reject)
    - Ouverture/fermeture de ports
    - Règles par service (ufw allow ssh, http, https)
    - Limitation des connexions (limit)
3. Règles avancées
    - Autorisation par adresse IP ou plage
    - Suppression de règles
    - Réinitialisation d'UFW
    - Différences selon les distributions (préinstallé ou non)

---

📘 PARTIE 17 : Sauvegardes de base Fichier Obsidian suggéré : `17-sauvegardes-base.md`

**Sujets à couvrir :**

1. Sauvegardes avec tar
    - Création d'archives tar
    - Options de compression (gzip, bzip2, xz)
    - Options importantes (-c, -x, -t, -v, -f, -z, -j, -J)
    - Sauvegarde de répertoires spécifiques
2. Synchronisation avec rsync
    - Options principales de rsync (-a, -v, -z, --delete)
    - Synchronisation locale
    - Synchronisation distante
3. Automatisation et restauration
    - Planification avec cron
    - Scripts de sauvegarde simples
    - Extraction d'archives tar
    - Vérification d'archives (-t)
    - Importance des tests de restauration

---

📘 PARTIE 18 : Mises à jour et maintenance système Fichier Obsidian suggéré : `18-mises-a-jour-maintenance.md`

**Sujets à couvrir :**

1. Stratégie de mises à jour
    - Mises à jour de sécurité vs mises à jour normales
    - apt list --upgradable
    - unattended-upgrades pour automatisation
    - Différences Ubuntu/Debian
2. Nettoyage système
    - apt clean, apt autoclean
    - apt autoremove pour supprimer les paquets inutiles
    - Nettoyage des logs anciens (journalctl --vacuum-time, --vacuum-size)
    - Nettoyage de /tmp
3. Vérification de l'état du système
    - Vérification de l'espace disque disponible
    - Vérification des services critiques
    - Analyse des logs d'erreurs
    - Surveillance de la charge système