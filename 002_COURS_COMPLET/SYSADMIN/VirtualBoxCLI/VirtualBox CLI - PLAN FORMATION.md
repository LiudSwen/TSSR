

📘 PARTIE 1 : Introduction et installation de VirtualBox CLI

Fichier Obsidian suggéré : `01-intro-installation-vboxmanage.md`

**Sujets à couvrir :**

1. Présentation de VirtualBox et VBoxManage
    
    - Différences entre GUI et CLI
    - Cas d'usage de la ligne de commande
    - Architecture de VirtualBox
2. Installation et configuration
    
    - Installation de VirtualBox sur différents OS
    - Vérification de l'installation de VBoxManage
    - Variables d'environnement et PATH
    - Structure des répertoires VirtualBox
3. Commandes de base
    
    - Syntaxe générale de VBoxManage
    - Aide et documentation (`--help`, `--version`)
    - Liste des catégories de commandes

---

📘 PARTIE 2 : Gestion des machines virtuelles

Fichier Obsidian suggéré : `02-gestion-vms.md`

**Sujets à couvrir :**

1. Création de VMs
    
    - `createvm` : création d'une VM
    - Paramètres de base (nom, ostype, registre)
    - Types de systèmes d'exploitation supportés
    - `registervm` et `unregistervm`
2. Configuration des VMs
    
    - `modifyvm` : modification des paramètres
    - Mémoire RAM et processeurs
    - Firmware (BIOS/EFI)
    - Boot order
    - Carte graphique et VRAM
    - Audio et USB
3. Gestion du cycle de vie
    
    - `list` : lister les VMs (vms, runningvms, ostypes)
    - `showvminfo` : afficher les informations détaillées
    - `clonevm` : cloner une VM
    - `unregistervm` et suppression
    - Import/Export (OVF/OVA)

---

📘 PARTIE 3 : Contrôle et pilotage des VMs

Fichier Obsidian suggéré : `03-controle-vms.md`

**Sujets à couvrir :**

1. Démarrage des VMs
    
    - `startvm` : modes de démarrage (gui, headless, sdl)
    - Options de démarrage avancées
    - Démarrage automatique
2. Contrôle d'exécution
    
    - `controlvm` : commandes pendant l'exécution
    - Pause et resume
    - Reset et poweroff
    - Sauvegarde de l'état (savestate)
    - ACPI shutdown
    - Gestion des snapshots en live
3. Gestion des snapshots
    
    - `snapshot` : création de snapshots
    - Liste et affichage des snapshots
    - Restauration (restore)
    - Suppression de snapshots
    - Snapshot tree et relations

---

📘 PARTIE 4 : Stockage et disques virtuels

Fichier Obsidian suggéré : `04-stockage-disques.md`

**Sujets à couvrir :**

1. Gestion des disques virtuels
    
    - `createmedium` : création de disques (VDI, VMDK, VHD)
    - Tailles fixe et dynamique
    - `modifymedium` : redimensionnement et compactage
    - `clonemedium` : clonage de disques
    - `closemedium` : fermeture et suppression
2. Contrôleurs de stockage
    
    - Types de contrôleurs (IDE, SATA, SCSI, NVMe, Floppy)
    - `storagectl` : ajout et configuration
    - Paramètres des contrôleurs
    - Suppression de contrôleurs
3. Attachement des médias
    
    - `storageattach` : attacher disques et ISO
    - Ports et devices
    - Mode passthrough
    - Médias temporaires et immutables
    - Détachement de médias

---

📘 PARTIE 5 : Réseau et connectivité

Fichier Obsidian suggéré : `05-reseau.md`

**Sujets à couvrir :**

1. Modes réseau
    
    - NAT
    - Bridged (pont)
    - Internal Network
    - Host-Only
    - NAT Network
    - Generic Driver
2. Configuration réseau
    
    - `modifyvm` : paramètres réseau par carte
    - Adresses MAC
    - Type de carte réseau (Intel, AMD, Virtio)
    - Cable connected/disconnected
    - Bandwidth groups
3. Réseaux avancés
    
    - `natnetwork` : gestion des réseaux NAT
    - `hostonlyif` : interfaces host-only
    - Port forwarding en NAT
    - `dhcpserver` : serveur DHCP intégré

---

📘 PARTIE 6 : Dossiers partagés et Guest Additions

Fichier Obsidian suggéré : `06-partage-guest-additions.md`

**Sujets à couvrir :**

1. Guest Additions
    
    - Installation des Guest Additions
    - `guestproperty` : gestion des propriétés
    - `guestcontrol` : exécution de commandes
    - Copie de fichiers vers/depuis le guest
    - Gestion des processus guest
2. Dossiers partagés
    
    - `sharedfolder add` : création de partages
    - Options (transient, readonly, automount)
    - `sharedfolder remove` : suppression
    - Montage dans le système guest
    - Droits et permissions

---

📘 PARTIE 7 : Automatisation et scripting

Fichier Obsidian suggéré : `07-automatisation-scripting.md`

**Sujets à couvrir :**

1. Scripting Bash/PowerShell
    
    - Scripts de création automatique de VMs
    - Boucles et conditions
    - Gestion des erreurs et codes retour
    - Variables et paramètres
    - Logs et traçabilité
2. Déploiement en masse
    
    - Templates et clonage
    - Configuration réseau automatique
    - Provisioning de VMs multiples
    - Fichiers de configuration
3. Intégration CI/CD
    
    - VBoxManage dans des pipelines
    - Tests automatisés sur VMs
    - Nettoyage automatique

---

📘 PARTIE 8 : Administration et monitoring

Fichier Obsidian suggéré : `08-administration-monitoring.md`

**Sujets à couvrir :**

1. Monitoring et métriques
    
    - `metrics` : collecte de métriques
    - `debugvm` : informations de debug
    - Logs VirtualBox
    - `showvminfo --machinereadable` : format parsable
2. Gestion des ressources
    
    - Limitation CPU et mémoire
    - IO throttling
    - Bandwidth groups
    - Priority et scheduling
3. Maintenance
    
    - `list systemproperties` : propriétés système
    - Chemins par défaut
    - Nettoyage des médias orphelins
    - Compact et optimisation
    - Sauvegarde et restauration

---

📘 PARTIE 9 : Fonctionnalités avancées

Fichier Obsidian suggéré : `09-fonctionnalites-avancees.md`

**Sujets à couvrir :**

1. Extension packs et VRDE
    
    - Installation d'Extension Pack
    - `vrde` : Remote Desktop
    - Configuration du serveur VRDE
    - Authentification et sécurité
2. Enregistrement et captures
    
    - `recording` : enregistrement vidéo
    - Screenshots (`screenshotvm`)
    - Configuration des codecs
3. Fonctionnalités système
    
    - USB pass-through (`usbfilter`)
    - PCI pass-through
    - Serial ports et communication
    - Clipboard et Drag'n'Drop

---

📘 PARTIE 10 : Dépannage et bonnes pratiques

Fichier Obsidian suggéré : `10-depannage-bonnes-pratiques.md`

**Sujets à couvrir :**

1. Dépannage courant
    
    - Erreurs fréquentes et solutions
    - Problèmes de démarrage
    - Conflits réseau
    - Problèmes de performance
    - Lecture des logs
2. Sécurité
    
    - Isolation des VMs
    - Gestion des accès
    - Encryption de disques
    - Snapshots et points de restauration
    - Hardening des VMs
3. Bonnes pratiques
    
    - Organisation des VMs
    - Naming conventions
    - Documentation
    - Stratégies de backup
    - Optimisation des performances
    - Gestion de l'espace disque