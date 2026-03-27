📘 PARTIE 1 : Introduction et installation de Proxmox VE Fichier Obsidian suggéré : `01-introduction-installation-proxmox.md`

**Sujets à couvrir :**

1. Présentation de Proxmox VE
    
    - Qu'est-ce que Proxmox VE
    - Hyperviseur Type 1 vs Type 2
    - Cas d'usage et avantages
    - Architecture de Proxmox
2. Prérequis et préparation
    
    - Configuration matérielle minimale et recommandée
    - Compatibilité CPU (Intel VT-x / AMD-V)
    - Stockage et réseau
    - Téléchargement de l'ISO
3. Installation de Proxmox VE
    
    - Création du support d'installation
    - Démarrage et assistant d'installation
    - Configuration initiale (disque, réseau, mot de passe)
    - Premier accès à l'interface web
4. Découverte de l'interface web
    
    - Navigation dans l'interface
    - Structure de l'arborescence
    - Dashboard et vue d'ensemble
    - Accès console (Shell)

---

📘 PARTIE 2 : Configuration réseau et stockage Fichier Obsidian suggéré : `02-reseau-stockage-proxmox.md`

**Sujets à couvrir :**

1. Configuration réseau
    
    - Interfaces réseau (Physical, Bridge, Bond)
    - Linux Bridge
    - Configuration VLAN
    - Fichier /etc/network/interfaces
2. Gestion du stockage
    
    - Types de stockage disponibles (Local, LVM, LVM-Thin, Directory, NFS, iSCSI)
    - Stockage local (local et local-lvm)
    - Ajout d'un stockage
    - Content types (images, iso, backups, etc.)
3. Gestion des ISO et templates
    
    - Upload d'images ISO
    - Téléchargement depuis le web
    - Templates de conteneurs CT

---

📘 PARTIE 3 : Machines virtuelles (VM) Fichier Obsidian suggéré : `03-machines-virtuelles.md`

**Sujets à couvrir :**

1. Création d'une VM
    
    - Assistant de création
    - Paramètres généraux (ID, nom, notes)
    - Système (BIOS/UEFI, machine type)
    - Configuration disque
    - Configuration CPU
    - Configuration mémoire
    - Configuration réseau
2. Installation d'un OS
    
    - Montage de l'ISO
    - Installation Windows
    - Installation Linux
    - Drivers et agents (qemu-guest-agent)
3. Gestion des VM
    
    - Démarrage, arrêt, redémarrage
    - Console (noVNC, SPICE)
    - Snapshots
    - Clonage (Full clone, Linked clone)
    - Migration (à froid)
    - Suppression
4. Options avancées des VM
    
    - Options de démarrage (boot order, autostart)
    - Cloud-init
    - Périphériques (USB passthrough, PCI passthrough)
    - Limites de ressources

---

📘 PARTIE 4 : Conteneurs LXC Fichier Obsidian suggéré : `04-conteneurs-lxc.md`

**Sujets à couvrir :**

1. Introduction aux conteneurs LXC
    
    - Différence VM vs Conteneur
    - Avantages et limitations
    - Cas d'usage des conteneurs
2. Création d'un conteneur
    
    - Téléchargement de templates
    - Assistant de création
    - Configuration (unprivileged vs privileged)
    - Paramètres CPU et mémoire
    - Configuration réseau
    - Configuration stockage
3. Gestion des conteneurs
    
    - Démarrage, arrêt, redémarrage
    - Console
    - Snapshots et backups
    - Clonage
    - Migration
4. Configuration avancée
    
    - Points de montage (Mount Points)
    - Partage de ressources
    - Features (nesting, keyctl, etc.)

---

📘 PARTIE 5 : Sauvegardes et restauration Fichier Obsidian suggéré : `05-sauvegardes-restauration.md`

**Sujets à couvrir :**

1. Stratégie de sauvegarde
    
    - Types de sauvegardes (Snapshot, Suspend, Stop)
    - Modes de compression
    - Rétention
2. Sauvegardes manuelles
    
    - Sauvegarde d'une VM
    - Sauvegarde d'un conteneur
    - Destination du backup
3. Sauvegardes automatiques
    
    - Configuration d'un job de backup
    - Planification (Schedule)
    - Sélection des machines
    - Notifications
4. Restauration
    
    - Restauration complète
    - Restauration de fichiers
    - Restauration sur un autre nœud

---

📘 PARTIE 6 : Gestion des utilisateurs et sécurité Fichier Obsidian suggéré : `06-utilisateurs-securite.md`

**Sujets à couvrir :**

1. Gestion des utilisateurs
    
    - Realms d'authentification (PAM, PVE, LDAP, AD)
    - Création d'utilisateurs
    - Groupes
    - Tokens API
2. Permissions et rôles
    
    - Système de permissions Proxmox
    - Rôles prédéfinis (Administrator, PVEAdmin, etc.)
    - Création de rôles personnalisés
    - Attribution de permissions (Pools, ressources)
3. Pools de ressources
    
    - Création de pools
    - Ajout de ressources
    - Gestion multi-utilisateurs
4. Sécurité de base
    
    - Mise à jour du système
    - Configuration du pare-feu Proxmox
    - Certificats SSL
    - Authentification à deux facteurs (2FA)

---

📘 PARTIE 7 : Maintenance et supervision Fichier Obsidian suggéré : `07-maintenance-supervision.md`

**Sujets à couvrir :**

1. Mises à jour
    
    - Dépôts APT (Enterprise, No-Subscription, Test)
    - Mise à jour via interface web
    - Mise à jour en ligne de commande
    - Mise à niveau de version majeure
2. Monitoring et logs
    
    - Dashboard de surveillance
    - Graphiques de ressources (CPU, RAM, réseau)
    - Logs système
    - Journal des tâches
    - Syslog
3. Tâches de maintenance
    
    - Nettoyage des anciens kernels
    - Vérification du stockage
    - Gestion de l'espace disque
    - Vérification de l'état des services
4. Dépannage courant
    
    - VM qui ne démarre pas
    - Problèmes de réseau
    - Problèmes de stockage
    - Accès à l'interface perdu
    - Récupération en mode rescue

---

📘 PARTIE 8 : Cluster Proxmox (notions de base) Fichier Obsidian suggéré : `08-cluster-base.md`

**Sujets à couvrir :**

1. Introduction au clustering
    
    - Qu'est-ce qu'un cluster Proxmox
    - Avantages du clustering
    - Prérequis réseau
    - Quorum et Corosync
2. Création d'un cluster
    
    - Création du cluster sur le premier nœud
    - Ajout de nœuds au cluster
    - Vérification de l'état du cluster
3. Fonctionnalités du cluster
    
    - Gestion centralisée
    - Migration à chaud (Live Migration)
    - Haute disponibilité (HA) - concepts de base
    - Stockage partagé
4. Bonnes pratiques
    
    - Réseau dédié pour le cluster
    - Nombre de nœuds (impair)
    - Sauvegarde de la configuration cluster