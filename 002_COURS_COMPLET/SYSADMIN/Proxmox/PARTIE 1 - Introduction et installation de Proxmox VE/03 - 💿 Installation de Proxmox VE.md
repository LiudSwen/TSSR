

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

## 🎯 Vue d'ensemble

L'installation de Proxmox VE est un processus guidé qui transforme un serveur physique en hyperviseur complet. Cette installation crée un système basé sur Debian avec tous les composants nécessaires pour gérer des machines virtuelles et des conteneurs LXC.

> [!info] Pourquoi une installation dédiée ? Proxmox VE s'installe sur métal nu (bare metal) et prend le contrôle total du matériel. Il ne s'agit pas d'un logiciel à installer sur un OS existant, mais d'un système d'exploitation complet optimisé pour la virtualisation.

### Prérequis matériels minimaux

|Composant|Minimum|Recommandé|
|---|---|---|
|**Processeur**|64-bit (Intel EMT64 ou AMD64)|Multi-cœurs avec virtualisation matérielle (VT-x/AMD-V)|
|**RAM**|2 GB|8 GB ou plus|
|**Disque dur**|8 GB|32 GB (SSD recommandé)|
|**Réseau**|1 carte réseau|2 cartes ou plus pour séparation du trafic|

> [!warning] Vérification de la virtualisation matérielle La virtualisation matérielle (Intel VT-x ou AMD-V) doit être activée dans le BIOS. Sans elle, les performances seront considérablement réduites et certaines fonctionnalités ne seront pas disponibles.

---

## 💾 Création du support d'installation

### Téléchargement de l'ISO

L'image ISO de Proxmox VE est disponible sur le site officiel : [proxmox.com/downloads](https://www.proxmox.com/downloads)

```bash
# Vérification du checksum après téléchargement (Linux/macOS)
sha256sum proxmox-ve_*.iso

# Comparaison avec le checksum officiel publié sur le site
```

> [!tip] Versions disponibles Téléchargez toujours la dernière version stable. Les versions sont numérotées selon le format : Proxmox VE X.Y (basé sur Debian XX).

### Création d'une clé USB bootable

#### Sous Linux

```bash
# Identifier le périphérique USB
lsblk

# Écrire l'ISO sur la clé USB (remplacer sdX par votre périphérique)
sudo dd if=proxmox-ve_*.iso of=/dev/sdX bs=1M status=progress

# Synchroniser les écritures
sync
```

> [!warning] Attention à la destination La commande `dd` écrase complètement le périphérique cible. Vérifiez deux fois le nom du périphérique (`/dev/sdX`) pour ne pas effacer le mauvais disque !

#### Sous Windows

Utilisez un outil graphique comme :

- **Rufus** (recommandé) : Simple et fiable
- **balenaEtcher** : Interface moderne et sécurisée
- **Ventoy** : Permet de mettre plusieurs ISO sur une seule clé

**Configuration recommandée dans Rufus :**

- Schéma de partition : GPT
- Système de destination : UEFI (non CSM)
- Système de fichiers : FAT32

#### Sous macOS

```bash
# Identifier le disque USB
diskutil list

# Démonter le disque (remplacer diskN par votre périphérique)
diskutil unmountDisk /dev/diskN

# Écrire l'ISO
sudo dd if=proxmox-ve_*.iso of=/dev/rdiskN bs=1m

# Éjecter proprement
diskutil eject /dev/diskN
```

> [!example] Alternative avec Balena Etcher Pour les utilisateurs moins à l'aise avec le terminal, Balena Etcher offre une interface graphique simple sur tous les systèmes d'exploitation.

---

## 🚀 Démarrage et assistant d'installation

### Démarrage sur le support d'installation

1. **Insérer la clé USB** dans le serveur cible
2. **Redémarrer** et accéder au menu de boot (généralement F12, F11, ESC ou DEL selon le fabricant)
3. **Sélectionner** le support USB dans la liste des périphériques bootables

> [!info] Mode de démarrage Proxmox VE supporte à la fois le démarrage UEFI et Legacy BIOS. L'UEFI est recommandé pour les systèmes modernes et permet des fonctionnalités avancées comme Secure Boot.

### Menu de démarrage Proxmox

Au démarrage, plusieurs options sont proposées :

```
Proxmox VE (Terminal UI)          <- Installation standard (recommandé)
Proxmox VE (Terminal UI, Debug)   <- Mode debug pour dépannage
Advanced Options                   <- Options avancées et rescue
Boot from local disk               <- Démarrer sur le disque installé
```

> [!tip] Quelle option choisir ? Pour une installation normale, sélectionnez la première option "Proxmox VE (Terminal UI)". Le mode debug n'est utile qu'en cas de problème d'installation.

### Interface d'installation

L'assistant d'installation Proxmox utilise une interface texte (TUI - Terminal User Interface) avec navigation au clavier :

- **Entrée** : Valider
- **Espace** : Cocher/décocher
- **Tab** : Naviguer entre les champs
- **Flèches** : Se déplacer dans les listes

---

## ⚙️ Configuration initiale

### 1. Acceptation de la licence

La première étape présente le contrat de licence EULA (End User License Agreement).

```
┌──────────────────────────────────────┐
│ End User License Agreement (EULA)    │
│                                      │
│ [Texte de la licence...]             │
│                                      │
│         [I agree]  [Exit]            │
└──────────────────────────────────────┘
```

> [!info] Licence AGPL Proxmox VE est distribué sous licence AGPL v3 (GNU Affero General Public License). C'est un logiciel libre et open source.

### 2. Sélection du disque cible

Cette étape détermine où Proxmox VE sera installé.

```bash
# L'installateur affiche tous les disques détectés
Target Harddisk:
  /dev/sda  (500 GB, ATA Samsung SSD 850)
  /dev/sdb  (1 TB, ATA WDC WD10EZEX)
  /dev/nvme0n1 (256 GB, NVMe Samsung 970)
```

> [!warning] Effacement complet Le disque sélectionné sera **complètement effacé**. Assurez-vous d'avoir sauvegardé toutes les données importantes avant de continuer.

#### Options avancées du disque

En cliquant sur "Options", vous accédez à des paramètres avancés :

**Système de fichiers disponibles :**

|Système|Description|Usage recommandé|
|---|---|---|
|**ext4**|Système classique Linux|Serveurs simples, débutants|
|**xfs**|Performant pour gros fichiers|Serveurs avec beaucoup de stockage|
|**zfs (RAID0)**|Pas de redondance|Maximum de performance, un seul disque|
|**zfs (RAID1)**|Redondance miroir|Haute disponibilité, 2 disques minimum|
|**zfs (RAID10)**|Miroir + striping|Performance + redondance, 4 disques minimum|
|**zfs (RAIDZ-1)**|Parité simple|Bon compromis, 3 disques minimum|
|**zfs (RAIDZ-2)**|Parité double|Haute sécurité, 4 disques minimum|
|**zfs (RAIDZ-3)**|Parité triple|Très haute sécurité, 5 disques minimum|

> [!tip] Recommandation ZFS ZFS est le système de fichiers recommandé pour Proxmox VE car il offre :
> 
> - Snapshots natifs des VMs
> - Compression transparente
> - Détection et correction d'erreurs
> - Gestion avancée du cache

**Paramètres ZFS avancés :**

```
hdsize    : Taille à utiliser sur le disque (par défaut : totalité)
swapsize  : Taille du swap (par défaut : min(8GB, RAM/8))
maxroot   : Taille max de la partition root (par défaut : selon RAM)
minfree   : Espace libre à laisser (par défaut : 16GB)
maxvz     : Taille max pour les données VMs (par défaut : reste disponible)
```

> [!example] Configuration typique pour un serveur de production
> 
> - Système de fichiers : ZFS (RAID1) avec 2 SSD
> - hdsize : Totalité des disques
> - swapsize : 8 GB
> - maxroot : 32 GB (suffisant pour le système)
> - minfree : 16 GB (sécurité)
> - compression : lz4 (activé par défaut)

### 3. Configuration locale et fuseau horaire

```
┌──────────────────────────────────────┐
│ Location and Time Zone selection     │
│                                      │
│ Country:   [France____________▼]     │
│ Time zone: [Europe/Paris______▼]     │
│ Keyboard:  [fr________________▼]     │
│                                      │
│              [Next]                  │
└──────────────────────────────────────┘
```

> [!info] Importance du fuseau horaire Le fuseau horaire correct est crucial pour :
> 
> - Les logs système avec horodatage précis
> - Les sauvegardes planifiées
> - La synchronisation avec d'autres serveurs
> - Les certificats SSL

### 4. Mot de passe administrateur et email

Configuration du compte root (administrateur principal) :

```
Password:         [********************]
Confirm Password: [********************]
Email:           [admin@example.com___]
```

> [!warning] Sécurité du mot de passe root Le compte root a tous les privilèges sur le système. Utilisez un mot de passe :
> 
> - Long (minimum 16 caractères recommandé)
> - Complexe (majuscules, minuscules, chiffres, symboles)
> - Unique (jamais réutilisé ailleurs)
> - Stocké dans un gestionnaire de mots de passe

**L'adresse email est utilisée pour :**

- Recevoir les alertes système
- Les notifications de sauvegarde
- Les rapports d'état du cluster
- La récupération de compte (avec configuration supplémentaire)

### 5. Configuration réseau

C'est l'étape la plus critique de l'installation.

```
┌──────────────────────────────────────────────────┐
│ Network Configuration                            │
│                                                  │
│ Management Interface: [eno1____________▼]        │
│ Hostname (FQDN):     [pve.local.domain____]     │
│ IP Address (CIDR):   [192.168.1.100/24___]     │
│ Gateway:             [192.168.1.1________]     │
│ DNS Server:          [192.168.1.1________]     │
│                                                  │
│                     [Next]                       │
└──────────────────────────────────────────────────┘
```

#### Interface de gestion

```bash
# L'installateur détecte automatiquement les cartes réseau
eno1   - Intel Corporation I219-LM (1 Gbps)
enp3s0 - Realtek RTL8111 (1 Gbps)
```

> [!tip] Quelle interface choisir ? Sélectionnez l'interface qui sera connectée à votre réseau de gestion. Si vous avez plusieurs cartes, choisissez celle connectée au réseau où vous administrerez Proxmox.

#### Hostname (FQDN)

Le hostname doit être un nom de domaine complet (Fully Qualified Domain Name) :

```
Format correct: serveur.domaine.tld
Exemples:
  - pve.example.com
  - proxmox01.lab.local
  - hypervisor.monentreprise.fr
```

> [!warning] Format FQDN obligatoire Proxmox **exige** un FQDN valide. Un simple nom d'hôte (comme "pve" ou "proxmox") causera des problèmes, notamment :
> 
> - Échec de création de cluster
> - Problèmes avec les certificats SSL
> - Dysfonctionnements de certains services

**Structure d'un FQDN :**

```
[hostname].[domaine].[tld]
    ↓         ↓        ↓
   pve   .  local  .  lan

hostname : Nom unique du serveur
domaine  : Nom de votre domaine (peut être local)
tld      : Extension (.com, .local, .lan, etc.)
```

#### Adresse IP (notation CIDR)

L'adresse IP doit être en notation CIDR (Classless Inter-Domain Routing) :

```
192.168.1.100/24
     ↓         ↓
  Adresse    Masque

/24 = 255.255.255.0  (254 hôtes utilisables)
/16 = 255.255.0.0    (65534 hôtes)
/8  = 255.0.0.0      (16777214 hôtes)
```

**Masques courants :**

|CIDR|Masque de sous-réseau|Nombre d'hôtes|Usage typique|
|---|---|---|---|
|/32|255.255.255.255|1|Hôte unique|
|/30|255.255.255.252|2|Liaison point-à-point|
|/29|255.255.255.248|6|Très petit réseau|
|/24|255.255.255.0|254|Réseau domestique/PME|
|/23|255.255.254.0|510|Petit réseau entreprise|
|/22|255.255.252.0|1022|Réseau entreprise moyen|
|/16|255.255.0.0|65534|Grand réseau entreprise|

> [!example] Configuration réseau typique Pour un réseau local standard :
> 
> - IP : `192.168.1.100/24`
> - Gateway : `192.168.1.1` (votre box/routeur)
> - DNS : `192.168.1.1` ou `8.8.8.8` (Google DNS)

#### Passerelle (Gateway)

La passerelle est l'adresse du routeur qui donne accès à Internet et aux autres réseaux.

```bash
# Dans un réseau 192.168.1.0/24, la gateway est généralement :
192.168.1.1    # Box internet, routeur principal
```

> [!warning] Gateway obligatoire Sans gateway configurée, Proxmox ne pourra pas :
> 
> - Accéder à Internet
> - Télécharger les mises à jour
> - Communiquer avec d'autres réseaux

#### Serveur DNS

Le serveur DNS traduit les noms de domaine en adresses IP.

```bash
# Options courantes :
192.168.1.1      # DNS de votre box/routeur
8.8.8.8          # Google Public DNS
1.1.1.1          # Cloudflare DNS
9.9.9.9          # Quad9 DNS
```

> [!tip] DNS multiples Vous pourrez configurer plusieurs serveurs DNS après l'installation dans `/etc/resolv.conf`. C'est recommandé pour la redondance.

### 6. Résumé et confirmation

Avant l'installation finale, un récapitulatif s'affiche :

```
┌─────────────────────────────────────────────┐
│ Installation Summary                        │
│                                             │
│ Target disk:     /dev/sda                   │
│ Filesystem:      zfs (RAID1)                │
│ Country:         France                     │
│ Timezone:        Europe/Paris               │
│ Keyboard:        fr                         │
│ Hostname:        pve.local.lan              │
│ IP Address:      192.168.1.100/24           │
│ Gateway:         192.168.1.1                │
│ DNS:             192.168.1.1                │
│                                             │
│    [Install]  [Previous]  [Abort]           │
└─────────────────────────────────────────────┘
```

> [!warning] Dernière vérification C'est le moment de vérifier **tous** les paramètres, particulièrement :
> 
> - Le disque cible (pour éviter d'effacer le mauvais disque)
> - Le FQDN (difficile à changer après installation)
> - L'adresse IP et le masque réseau

### Processus d'installation

Une fois "Install" pressé, l'installation démarre :

```
Installing Proxmox VE...

[████████████████░░░░░░░░░░░░] 65%

- Partitioning disk
- Creating filesystems  
- Installing base system
- Configuring bootloader
- Installing packages
```

> [!info] Durée d'installation L'installation complète prend généralement entre 5 et 15 minutes selon :
> 
> - La vitesse du disque (SSD vs HDD)
> - Le système de fichiers choisi (ZFS est plus long)
> - La configuration RAID

**Une fois terminé, un message s'affiche :**

```
Installation successful!

Please remove the installation medium and reboot the system.

Point your browser to: https://192.168.1.100:8006/

[Reboot]
```

---

## 🌐 Premier accès à l'interface web

### Démarrage du système

Après le redémarrage, Proxmox affiche une console texte :

```
Welcome to the Proxmox Virtual Environment. Please use your web browser to
configure this server - connect to:

  https://192.168.1.100:8006/

You can also connect via SSH:
  
  ssh root@192.168.1.100

────────────────────────────────────────────────────────────────────
```

> [!info] Console disponible La console locale reste accessible pour le dépannage, mais l'administration se fait principalement via l'interface web.

### Connexion à l'interface web

1. **Ouvrir un navigateur web** sur un ordinateur du même réseau
2. **Saisir l'URL** : `https://192.168.1.100:8006`
3. **Accepter l'avertissement de certificat** (normal au premier démarrage)

> [!warning] Avertissement de certificat Le certificat SSL initial est auto-signé, ce qui génère un avertissement dans le navigateur. C'est normal. Vous pourrez installer un certificat valide plus tard.

**Pour accepter le certificat selon les navigateurs :**

- **Chrome/Edge** : Cliquer sur "Paramètres avancés" → "Continuer vers [adresse] (dangereux)"
- **Firefox** : Cliquer sur "Avancé" → "Accepter le risque et poursuivre"
- **Safari** : Cliquer sur "Afficher les détails" → "Visiter ce site web"

### Écran de connexion

```
┌─────────────────────────────────────┐
│      Proxmox Virtual Environment    │
│                                     │
│  Language:  [English__▼]            │
│  Username:  [root__________]        │
│  Password:  [***************]       │
│  Realm:     [Proxmox VE auth▼]      │
│                                     │
│          [Login]                    │
└─────────────────────────────────────┘
```

**Paramètres de connexion :**

|Champ|Valeur|Explication|
|---|---|---|
|**Username**|root|Utilisateur administrateur créé à l'installation|
|**Password**|(votre mot de passe)|Défini lors de l'installation|
|**Realm**|Proxmox VE authentication|Authentification locale (d'autres options apparaîtront si configurées)|

> [!tip] Sauvegarder les identifiants Stockez ces identifiants dans un gestionnaire de mots de passe sécurisé. Sans accès root, vous devrez réinitialiser le système.

### Interface principale

Après connexion, l'interface Proxmox VE s'affiche avec :

```
┌─────────────────────────────────────────────────────────────────┐
│ Proxmox                                    [?] root@pam  [≡]    │
├──────────────┬──────────────────────────────────────────────────┤
│ Datacenter   │                                                  │
│  └─ pve      │  Dashboard                                       │
│     ├─ local │  ┌──────────────────────────────────────────┐  │
│     ├─ Sys   │  │ CPU usage:      [████░░░░░░] 12%         │  │
│     └─ Tasks │  │ Memory:         [███░░░░░░░] 8%          │  │
│              │  │ Storage:        [██░░░░░░░░] 5%          │  │
│              │  └──────────────────────────────────────────┘  │
└──────────────┴──────────────────────────────────────────────────┘
```

**Zones principales de l'interface :**

1. **Barre supérieure** : Recherche, aide, utilisateur connecté, paramètres
2. **Arborescence gauche** : Hiérarchie du datacenter, nœuds, VMs, conteneurs
3. **Zone centrale** : Contenu principal, tableaux de bord, configurations
4. **Panneau inférieur** : Journal des tâches, console, logs

> [!example] Exploration initiale recommandée Parcourez ces sections pour vous familiariser :
> 
> - **Datacenter → Summary** : Vue d'ensemble du cluster
> - **pve (votre nœud) → Summary** : État du serveur physique
> - **pve → System** : Configuration système
> - **local → Content** : Stockage disponible

### Message de souscription

Au premier accès, une fenêtre popup apparaît :

```
┌────────────────────────────────────────┐
│ No valid subscription                  │
│                                        │
│ You do not have a valid subscription  │
│ for this server. Please visit         │
│ www.proxmox.com to get a list of      │
│ available options.                     │
│                                        │
│              [OK]                      │
└────────────────────────────────────────┘
```

> [!info] À propos de la souscription Proxmox VE est **gratuit et open source**. La souscription est **optionnelle** et offre :
> 
> - Accès aux dépôts enterprise (mises à jour testées)
> - Support professionnel
> - Pas de message popup au démarrage
> 
> Vous pouvez utiliser Proxmox sans souscription avec les dépôts "no-subscription" que nous configurerons dans une prochaine partie.

### Vérification de l'installation

**Vérifier que tout fonctionne correctement :**

1. **État du nœud** : Voyant vert à côté du nom du nœud
2. **Processeur et RAM** : Utilisation affichée dans le dashboard
3. **Stockage** : "local" et "local-lvm" visibles dans l'arborescence
4. **Réseau** : Connectivité Internet (coin supérieur droit, icône réseau)

```bash
# Vérification depuis la console SSH (optionnel)
pveversion    # Affiche la version de Proxmox
pvesh get /nodes/pve/status    # État du nœud en JSON
```

**Sortie attendue de `pveversion` :**

```
pve-manager/8.1.4/ec5affc9e41f1d79 (running kernel: 6.5.11-8-pve)
```

---

## ⚠️ Pièges courants

### Erreur de FQDN

**Symptôme :** Message "hostname does not look like a fully qualified domain name"

```bash
# Vérification du hostname
hostname -f
# Si retourne juste "pve" au lieu de "pve.domain.tld", c'est incorrect
```

**Cause :** Hostname mal configuré lors de l'installation ou modifié après coup.

**Solution :**

```bash
# Éditer le fichier hosts
nano /etc/hosts

# S'assurer que cette ligne existe :
192.168.1.100 pve.local.lan pve

# Format : IP FQDN hostname
```

### Problème de résolution DNS

**Symptôme :** Impossible de télécharger les mises à jour, erreur "Could not resolve host"

```bash
# Tester la résolution DNS
ping google.com
# Si échec : problème DNS
```

**Solution :**

```bash
# Vérifier la configuration DNS
cat /etc/resolv.conf

# Devrait contenir :
nameserver 192.168.1.1
# ou
nameserver 8.8.8.8

# Si vide ou incorrect, éditer :
nano /etc/resolv.conf
```

### Interface web inaccessible après installation

**Symptômes possibles :**

- Page refuse de se charger
- Timeout de connexion
- Erreur "impossible de se connecter"

**Vérifications à effectuer :**

```bash
# 1. Vérifier que le service web tourne
systemctl status pveproxy

# 2. Vérifier l'écoute sur le port 8006
ss -tlnp | grep 8006

# 3. Tester depuis le serveur lui-même
curl -k https://localhost:8006
```

**Causes fréquentes :**

- Pare-feu bloquant le port 8006
- Mauvaise configuration réseau
- Service pveproxy non démarré

**Solution :**

```bash
# Redémarrer les services Proxmox
systemctl restart pveproxy
systemctl restart pvedaemon
systemctl restart pvestatd
```

### Espace disque insuffisant après installation

**Symptôme :** Peu d'espace disponible pour les VMs malgré un grand disque

**Cause :** Partition root trop grande ou configuration LVM/ZFS inadaptée

**Vérification :**

```bash
# Afficher l'utilisation des disques
df -h

# Afficher les volumes LVM
lvs

# Pour ZFS
zfs list
```

**Prévention :** Utiliser les options avancées lors de l'installation pour ajuster `maxroot` et `maxvz`.

### Oubli du mot de passe root

Si vous avez oublié le mot de passe root, il faut le réinitialiser en mode rescue :

1. Redémarrer et appuyer sur `e` dans GRUB
2. Ajouter `init=/bin/bash` à la ligne kernel
3. Démarrer avec `Ctrl+X`
4. Monter le système en écriture : `mount -o remount,rw /`
5. Changer le mot de passe : `passwd root`
6. Redémarrer : `exec /sbin/init`

> [!warning] Sécurité physique Cette procédure montre l'importance de sécuriser physiquement vos serveurs. Quiconque a un accès physique peut réinitialiser le mot de passe.

### Certificat SSL expiré

**Symptôme :** Après quelques mois, le navigateur refuse la connexion HTTPS

**Cause :** Le certificat auto-signé par défaut a une durée de validité limitée

**Solution :**

```bash
# Régénérer le certificat auto-signé
pvecm updatecerts -f

# Ou configurer Let's Encrypt (abordé dans une partie ultérieure)
```

### IP en conflit

**Symptôme :** Connexion réseau instable, perte de connectivité aléatoire

**Cause :** Une autre machine sur le réseau utilise la même IP

**Vérification :**

```bash
# Depuis Proxmox, scanner le réseau
arp-scan --interface=vmbr0 --localnet

# Chercher l'IP en double
```

**Solution :** Modifier l'IP de Proxmox ou de la machine en conflit.

```bash
# Éditer la configuration réseau
nano /etc/network/interfaces

# Modifier l'adresse dans la section :
auto vmbr0
iface vmbr0 inet static
        address 192.168.1.100/24    # <- Changer ici
        
# Redémarrer le réseau
systemctl restart networking
```

---

## ✨ Astuces

### Raccourcis clavier dans l'interface web

|Raccourci|Action|
|---|---|
|`Shift + Ctrl + R`|Forcer le rechargement (contourne le cache)|
|`Ctrl + Click`|Ouvrir dans un nouvel onglet|
|`F5`|Rafraîchir la vue|

### Accès SSH immédiat

```bash
# Se connecter en SSH (plus rapide que l'interface web pour certaines tâches)
ssh root@192.168.1.100

# Avec clé SSH (après configuration)
ssh -i ~/.ssh/id_rsa root@192.168.1.100
```

### Console noVNC intégrée

L'interface web inclut une console noVNC pour chaque VM, évitant d'installer un client VNC séparé.

### Documentation intégrée

Cliquez sur l'icône `?` en haut à droite pour accéder à la documentation officielle directement depuis l'interface.

### Mode sombre

```bash
# Activer le thème sombre (disponible depuis Proxmox 7.0+)
# Interface web : Cliquer sur votre nom d'utilisateur → Préférences → Theme: Dark
```

### Raccourcis de terminal SSH

Créez un alias pour vous connecter rapidement :

```bash
# Sur votre machine locale
echo "alias pve='ssh root@192.168.1.100'" >> ~/.bashrc
source ~/.bashrc

# Maintenant, tapez simplement :
pve
```

### Surveillance en temps réel

```bash
# Afficher l'utilisation CPU/RAM/Disque en direct
htop

# Surveiller les logs système en temps réel
journalctl -f

# Voir les tâches en cours d'exécution
watch -n 1 'pveversion; pvesh get /cluster/resources'
```

### Sauvegarde de la configuration initiale

```bash
# Sauvegarder la configuration réseau
cp /etc/network/interfaces /etc/network/interfaces.backup

# Sauvegarder la configuration des hôtes
cp /etc/hosts /etc/hosts.backup

# Créer un snapshot de configuration complète
tar -czf /root/proxmox-config-$(date +%Y%m%d).tar.gz \
    /etc/network/interfaces \
    /etc/hosts \
    /etc/resolv.conf \
    /etc/pve/
```

> [!tip] Bonnes pratiques post-installation
> 
> - Documentez toutes vos adresses IP et configurations
> - Créez une sauvegarde de la configuration initiale
> - Testez la connectivité réseau et Internet
> - Configurez des alertes email (abordé dans une prochaine partie)
> - Planifiez une stratégie de mise à jour

### Optimisation des performances post-installation

```bash
# Désactiver le swap agressif (améliore les performances)
echo "vm.swappiness=10" >> /etc/sysctl.conf
sysctl -p

# Activer la compression ZFS (si ZFS est utilisé)
zfs set compression=lz4 rpool

# Vérifier les performances disque
dd if=/dev/zero of=/tmp/test bs=1M count=1024 conv=fdatasync
```

### Vérification matérielle complète

```bash
# Lister tout le matériel détecté
lspci -v

# Vérifier la RAM
dmidecode -t memory | grep -i size

# Vérifier les disques
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE

# Température CPU (si sensors installé)
sensors

# État SMART des disques
smartctl -a /dev/sda
```

### Préparation pour la production

Avant de mettre en production, vérifiez ces points :

- [ ] Mot de passe root fort et sauvegardé
- [ ] Adresse IP fixe et documentée
- [ ] DNS fonctionnel et testé
- [ ] Accès web HTTPS opérationnel
- [ ] Sauvegarde de la configuration initiale
- [ ] Tests de connectivité réseau
- [ ] Documentation du FQDN
- [ ] Plan de sauvegarde défini
- [ ] Surveillance système configurée

> [!info] Prochaines étapes Maintenant que Proxmox VE est installé et accessible, les prochaines parties du cours couvriront :
> 
> - Configuration avancée du réseau
> - Gestion du stockage
> - Création et gestion des machines virtuelles
> - Configuration des sauvegardes
> - Sécurisation de l'accès
> - Mise à jour et maintenance

---

## 📝 Récapitulatif

L'installation de Proxmox VE suit un processus en plusieurs étapes :

1. **Préparation** : Télécharger l'ISO et créer un support bootable USB
2. **Démarrage** : Booter sur la clé USB et lancer l'installateur
3. **Configuration disque** : Choisir le disque cible et le système de fichiers (ZFS recommandé)
4. **Localisation** : Définir le pays, fuseau horaire et clavier
5. **Sécurité** : Créer le mot de passe root et l'email administrateur
6. **Réseau** : Configurer l'IP, le FQDN, la gateway et le DNS (étape critique)
7. **Installation** : Valider et laisser l'installation se terminer (5-15 minutes)
8. **Premier accès** : Se connecter via HTTPS sur le port 8006
9. **Vérification** : S'assurer que tous les services fonctionnent correctement

> [!warning] Points critiques à retenir
> 
> - Le FQDN doit être correctement configuré (format: `hostname.domaine.tld`)
> - L'adresse IP doit utiliser la notation CIDR (`/24`, `/16`, etc.)
> - Le disque d'installation sera **complètement effacé**
> - Le certificat SSL initial est auto-signé (avertissement du navigateur normal)
> - La souscription est optionnelle, Proxmox reste gratuit et fonctionnel

---

**🎓 Vous avez maintenant un serveur Proxmox VE opérationnel, prêt pour créer et gérer des machines virtuelles et conteneurs !**