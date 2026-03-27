

## 📚 Table des matières

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

## Introduction

L'installation de pfSense est un processus relativement simple mais qui nécessite une attention particulière lors de certaines étapes critiques, notamment la configuration des interfaces réseau et le partitionnement. Cette phase établit les fondations de votre pare-feu et une erreur à ce stade peut nécessiter une réinstallation complète.

> [!info] Version et support pfSense est disponible en deux éditions : Community Edition (CE) gratuite et pfSense Plus. Ce cours se concentre sur la version CE qui convient à la majorité des usages.

---

## Démarrage sur le support d'installation

### Préparation du support

Avant de démarrer l'installation, vous devez avoir préparé un support d'installation :

- **USB bootable** (méthode recommandée)
- **CD/DVD** (moins courant aujourd'hui)
- **ISO montée** (pour machines virtuelles)

> [!tip] Création d'une clé USB bootable Utilisez des outils comme Rufus (Windows), dd (Linux), ou Etcher (multiplateforme) pour créer votre clé USB à partir de l'image ISO de pfSense.

### Démarrage de la machine

1. **Insérez le support d'installation** dans la machine cible
2. **Accédez au BIOS/UEFI** (généralement F2, F12, Del ou Esc au démarrage)
3. **Modifiez l'ordre de boot** pour prioriser votre support d'installation
4. **Sauvegardez et redémarrez**

> [!warning] Mode de démarrage Assurez-vous que le mode de démarrage (Legacy BIOS vs UEFI) est cohérent avec votre image pfSense et votre matériel. Les systèmes modernes utilisent généralement UEFI.

### Écran de démarrage

Lors du démarrage, vous verrez le logo pfSense avec plusieurs options :

```
1. Boot Multi user [Enter]
2. Boot Single user
3. Escape to loader prompt
4. Reboot
```

> [!example] Choix typique Dans la grande majorité des cas, appuyez simplement sur **Entrée** ou laissez le démarrage automatique se faire (option 1).

L'option **Single user** est réservée au dépannage et à la maintenance avancée.

---

## Assistant d'installation

### Écran d'accueil

Après le démarrage complet du système, vous arriverez sur l'écran d'accueil de l'installateur qui présente plusieurs options :

```
Welcome to pfSense!

1) Install pfSense
2) Rescue config.xml
3) Recover config.xml
4) Reset to factory defaults
5) Reboot
6) Halt System
```

> [!info] Signification des options
> 
> - **Install pfSense** : Installation standard
> - **Rescue config.xml** : Sauvegarder la configuration depuis une installation existante
> - **Recover config.xml** : Restaurer une configuration sauvegardée
> - **Reset to factory defaults** : Réinitialiser une installation existante
> - **Reboot/Halt** : Redémarrer ou arrêter le système

### Lancement de l'installation

1. **Sélectionnez l'option 1** (Install pfSense)
2. Appuyez sur **Entrée**

### Choix du clavier

L'installateur vous propose de configurer la disposition du clavier :

```
Select a keyboard layout:
>>> Continue with default keymap
    Select keymap from list
    Test keymap
```

> [!tip] Clavier français Si vous utilisez un clavier AZERTY, sélectionnez "Select keymap from list" puis cherchez "French" ou "fr.kbd".

### Type d'installation

Vous devez ensuite choisir le type d'installation :

```
Partitioning:
>>> Auto (UFS) BIOS
    Auto (UFS) UEFI
    Auto (ZFS)
    Manual
    Shell
```

|Option|Description|Utilisation recommandée|
|---|---|---|
|**Auto (UFS) BIOS**|Installation automatique en mode Legacy|Ancien matériel, BIOS traditionnel|
|**Auto (UFS) UEFI**|Installation automatique en mode UEFI|Matériel moderne (post-2012)|
|**Auto (ZFS)**|Installation avec système de fichiers ZFS|Systèmes avec beaucoup de RAM et besoins avancés|
|**Manual**|Partitionnement manuel|Besoins spécifiques, configurations avancées|
|**Shell**|Accès au shell pour installation manuelle|Experts uniquement|

> [!warning] UFS vs ZFS **UFS** est recommandé pour la plupart des installations, notamment avec peu de RAM (< 4 GB). **ZFS** offre des fonctionnalités avancées (snapshots, compression) mais nécessite plus de ressources (minimum 4 GB de RAM, recommandé 8 GB+).

### Sélection du disque cible

L'installateur affiche ensuite la liste des disques disponibles :

```
Please select a disk to install to:
>>> da0  16 GB  SanDisk USB
    ada0 120 GB SATA SSD Samsung
```

> [!warning] Attention à la sélection **Toutes les données sur le disque sélectionné seront effacées**. Vérifiez soigneusement que vous sélectionnez le bon disque, surtout si plusieurs disques sont présents.

> [!tip] Identification des disques
> 
> - **da0, da1...** : Disques USB
> - **ada0, ada1...** : Disques SATA/IDE
> - **nvd0, nvd1...** : Disques NVMe
> - **vtbd0, vtbd1...** : Disques virtuels (VirtIO)

### Confirmation et installation

Après avoir sélectionné le disque, une dernière confirmation vous est demandée :

```
WARNING: This will erase all data on da0!
Are you sure you want to proceed? [yes/NO]
```

Tapez **yes** en entier et appuyez sur **Entrée**.

L'installation commence alors et affiche la progression :

```
Extracting base.txz...
Extracting kernel.txz...
Installing boot loader...
```

> [!info] Durée d'installation L'installation prend généralement entre 2 et 10 minutes selon la vitesse du disque et le support d'installation.

### Fin de l'installation

Une fois terminée, vous verrez :

```
Installation complete!
Would you like to open a shell before rebooting? [yes/NO]
```

> [!tip] Shell post-installation Vous pouvez répondre **yes** pour effectuer des ajustements manuels avant le redémarrage, mais ce n'est généralement pas nécessaire pour une installation standard.

Sélectionnez **NO** et le système redémarrera.

> [!warning] Retrait du support **Retirez la clé USB ou le CD d'installation avant le redémarrage** pour éviter de rebooter sur l'installateur.

---

## Configuration du partitionnement

### Partitionnement automatique (UFS)

Le partitionnement automatique UFS crée une structure simple et efficace :

```
Partition     Size      Mount Point    Type
/dev/ada0p1   512 KB    -              freebsd-boot
/dev/ada0p2   4 GB      swap           freebsd-swap
/dev/ada0p3   Reste     /              freebsd-ufs
```

> [!info] Explication des partitions
> 
> - **freebsd-boot** : Partition de démarrage (bootcode)
> - **freebsd-swap** : Espace d'échange mémoire (swap)
> - **freebsd-ufs** : Partition racine du système de fichiers

### Dimensionnement du swap

La taille du swap est calculée automatiquement selon ces règles :

|RAM système|Taille swap|
|---|---|
|< 4 GB|2× la RAM|
|4-8 GB|4 GB|
|> 8 GB|4 GB|

> [!tip] Swap et performance Pour un système avec SSD et suffisamment de RAM (8 GB+), le swap est rarement utilisé. Cependant, il reste recommandé pour les dumps de crash et situations d'urgence.

### Partitionnement ZFS

Si vous choisissez l'installation ZFS, l'assistant propose plusieurs configurations :

```
ZFS Configuration:

T Pool Type/Disks: stripe: 1 disk
- Rescan Devices
- Disk Info
- Pool Name
- Force 4K Sectors?
- Encrypt Disks?
- Partition Scheme
- Swap Size
- Mirror Swap?

>>> Install
    Cancel
```

#### Options ZFS importantes

**Pool Type** : Type de configuration RAID

- **stripe** : Pas de redondance (1 disque minimum)
- **mirror** : Miroir RAID-1 (2 disques minimum)
- **raidz1** : RAID-5 équivalent (3 disques minimum)
- **raidz2** : RAID-6 équivalent (4 disques minimum)
- **raidz3** : Triple parité (5 disques minimum)

**Encrypt Disks** : Chiffrement des disques

- Ajoute une couche de sécurité
- Légère perte de performance
- **Nécessite la saisie d'un mot de passe à chaque démarrage**

**Force 4K Sectors** : Forcer les secteurs 4K

- Recommandé pour les SSD modernes
- Améliore les performances et l'alignement

**Swap Size** : Taille du swap

- 2g, 4g, 8g, etc.
- Peut être réglé à 0 si beaucoup de RAM

> [!warning] Chiffrement ZFS Si vous activez le chiffrement, vous devrez **obligatoirement** entrer le mot de passe à chaque démarrage. Cela rend impossible le démarrage automatique sans intervention manuelle.

### Partitionnement manuel

Pour les utilisateurs avancés, le partitionnement manuel permet un contrôle total :

1. Sélectionnez **Manual** dans l'écran de partitionnement
2. Utilisez l'outil de partitionnement FreeBSD
3. Créez les partitions nécessaires

> [!info] Structure minimale requise
> 
> - Une partition de boot (512 KB minimum)
> - Une partition swap (recommandé)
> - Une partition racine (/) en UFS ou ZFS

> [!warning] Réservé aux experts Le partitionnement manuel n'est recommandé que si vous avez des besoins très spécifiques ou si vous maîtrisez FreeBSD. Une erreur peut rendre le système non bootable.

---

## Première configuration console

### Premier démarrage

Après le redémarrage, pfSense démarre automatiquement et affiche la console :

```
*** Welcome to pfSense 2.7.x-RELEASE (amd64) on pfSense ***

WAN (wan)       -> em0        -> v4: DHCP
LAN (lan)       -> em1        -> v4: 192.168.1.1/24

0) Logout (SSH only)
1) Assign Interfaces
2) Set interface(s) IP address
3) Reset webConfigurator password
4) Reset to factory defaults
5) Reboot system
6) Halt system
7) Ping host
8) Shell
9) pfTop
10) Filter Logs
11) Restart webConfigurator
12) PHP shell + pfSense tools
13) Update from console
14) Disable Secure Shell (sshd)
15) Restore recent configuration
16) Restart PHP-FPM
```

> [!info] Interface console Cette console est votre principal outil d'administration en cas de problème ou lors de la configuration initiale. Elle reste accessible même si l'interface web est inaccessible.

### Configuration automatique des interfaces

Lors du premier démarrage, pfSense tente de détecter automatiquement les interfaces réseau :

- **Détection de 1 interface** : Assignée comme LAN
- **Détection de 2+ interfaces** : Première assignée comme WAN, deuxième comme LAN

```
Valid interfaces are:
em0    00:0c:29:xx:xx:xx (Intel Pro/1000)
em1    00:0c:29:yy:yy:yy (Intel Pro/1000)

Do you want to set up VLANs now? [y/n]
```

> [!tip] VLANs lors de l'installation Répondez **n** (non) pour le moment. Les VLANs peuvent être configurés plus tard via l'interface web de manière plus intuitive.

### Assignment des interfaces (Option 1)

Si la détection automatique ne correspond pas à vos besoins, utilisez l'option **1) Assign Interfaces** :

```
Enter the WAN interface name or 'a' for auto-detection
(em0 em1 or a):
```

#### Processus d'assignment

1. **Interface WAN** : Entrez le nom de l'interface connectée à Internet
    
    - Tapez le nom exact (ex: `em0`)
    - Ou tapez `a` pour auto-détection (en débranchant/rebranchant le câble)
2. **Interface LAN** : Entrez le nom de l'interface pour le réseau local
    
    - Généralement votre deuxième carte réseau
3. **Interfaces optionnelles** : Appuyez sur Entrée si pas d'interface supplémentaire
    
    - Vous pouvez ajouter DMZ, OPT1, OPT2, etc.
4. **Confirmation** : Vérifiez le récapitulatif et confirmez avec `y`
    

```
WAN  -> em0
LAN  -> em1

Do you want to proceed? [y/n]
```

> [!warning] Identification des interfaces **Crucial** : Assurez-vous d'assigner correctement WAN et LAN. Une inversion peut exposer votre réseau interne directement à Internet ou bloquer votre accès.

> [!tip] Auto-détection pratique La méthode `a` (auto-détection) est très pratique : débranchez tous les câbles, lancez la détection, puis branchez le câble WAN quand demandé, puis le câble LAN.

### Configuration IP des interfaces (Option 2)

Une fois les interfaces assignées, configurez leurs adresses IP avec l'option **2) Set interface(s) IP address** :

```
Available interfaces:
1 - WAN (em0)
2 - LAN (em1)

Enter the number of the interface you wish to configure:
```

#### Configuration de l'interface WAN

1. **Sélectionnez l'interface WAN** (généralement option 1)
    
2. **IPv4 via DHCP ?**
    

```
Configure IPv4 address WAN interface via DHCP? [y/n]
```

- **y** : Adresse IP automatique depuis votre modem/box (cas le plus fréquent)
- **n** : Configuration manuelle (IP fixe fournie par votre FAI)

> [!example] Configuration DHCP (typique) Pour la plupart des installations domestiques ou avec un modem/routeur en amont, répondez **y** pour obtenir automatiquement l'IP depuis votre FAI.

3. **IPv6 via DHCP6 ?** (si applicable)

```
Configure IPv6 address WAN interface via DHCP6? [y/n]
```

- Répondez **y** si votre FAI fournit de l'IPv6
- Répondez **n** sinon (vous pourrez configurer plus tard)

4. **Reverting to HTTP** (si demandé)

```
Do you want to revert to HTTP as the webConfigurator protocol? [y/n]
```

- Généralement **n** pour conserver HTTPS (plus sécurisé)

#### Configuration de l'interface LAN

1. **Sélectionnez l'interface LAN** (généralement option 2)
    
2. **Adresse IPv4**
    

```
Enter the new LAN IPv4 address:
```

> [!example] Adresse par défaut L'adresse par défaut est **192.168.1.1**. Vous pouvez la conserver ou la modifier selon votre plan d'adressage.

Exemples d'adresses courantes :

- `192.168.1.1` (par défaut)
- `10.0.0.1`
- `172.16.0.1`

3. **Masque réseau**

```
Enter the new LAN IPv4 subnet bit count (1 to 31):
```

> [!info] Masques courants
> 
> - **24** : Réseau /24 = 255.255.255.0 (254 hôtes possibles)
> - **23** : Réseau /23 = 255.255.254.0 (510 hôtes)
> - **22** : Réseau /22 = 255.255.252.0 (1022 hôtes)

Pour un réseau domestique ou PME, **24** est largement suffisant.

4. **Passerelle IPv4**

```
For a LAN, press <ENTER> for none:
```

> [!tip] Pas de gateway sur LAN Pour l'interface LAN, appuyez simplement sur **Entrée** (pas de passerelle nécessaire car pfSense EST la passerelle).

5. **IPv6 sur LAN**

```
Configure IPv6 address LAN interface via DHCP6? [y/n]
```

- Répondez **n** pour le moment (configuration IPv6 plus tard si nécessaire)

6. **Serveur DHCP**

```
Do you want to enable the DHCP server on LAN? [y/n]
```

> [!tip] DHCP recommandé Répondez **y** pour activer le serveur DHCP, ce qui permettra aux clients du réseau LAN d'obtenir automatiquement une adresse IP.

7. **Plage DHCP**

```
Enter the start address of the IPv4 client address range: 192.168.1.10
Enter the end address of the IPv4 client address range: 192.168.1.245
```

> [!example] Plage recommandée Réservez les premières adresses (1-9) pour les équipements fixes (serveurs, imprimantes) et distribuez à partir de .10.

8. **Reversion HTTP** (optionnel)

```
Do you want to revert to HTTP as the webConfigurator protocol? [y/n]
```

- **n** : Conserver HTTPS (recommandé)
- **y** : HTTP uniquement (moins sécurisé, à éviter)

### Accès à l'interface web

Une fois la configuration console terminée, vous verrez :

```
You can now access the webConfigurator from:

    https://192.168.1.1

The webConfigurator login credentials are:

    Username: admin
    Password: pfsense
```

> [!warning] Changement du mot de passe Le mot de passe par défaut **pfsense** doit être changé immédiatement après la première connexion pour des raisons de sécurité.

#### Connexion à l'interface web

1. **Connectez un PC à l'interface LAN** de pfSense
2. **Vérifiez que le PC a obtenu une IP** via DHCP (ex: 192.168.1.100)
3. **Ouvrez un navigateur** et allez sur `https://192.168.1.1`
4. **Acceptez le certificat autosigné** (normal au premier accès)
5. **Connectez-vous** avec admin / pfsense

> [!info] Certificat SSL L'avertissement de sécurité concernant le certificat est normal : pfSense utilise un certificat auto-signé par défaut. Vous pourrez installer un certificat valide plus tard.

---

## Pièges courants et bonnes pratiques

### ⚠️ Pièges à éviter

#### 1. Inversion WAN/LAN

**Problème** : Assigner le WAN sur l'interface interne et vice-versa

**Conséquence** : Exposition directe du réseau interne à Internet

**Solution** : Vérifier physiquement quel port est connecté à quoi avant l'assignment

#### 2. Oublier de retirer le média d'installation

**Problème** : Laisser la clé USB branchée après installation

**Conséquence** : Reboot sur l'installateur au lieu du système installé

**Solution** : Retirer la clé USB/CD avant le premier redémarrage

#### 3. Conflit d'adressage réseau

**Problème** : Utiliser le même réseau que votre routeur en amont (ex: 192.168.1.x des deux côtés)

**Conséquence** : Problèmes de routage, double NAT, accès impossible

**Solution** : Utiliser un réseau différent pour le LAN de pfSense (ex: 10.0.0.x ou 192.168.2.x)

#### 4. Partitionnement ZFS avec peu de RAM

**Problème** : Choisir ZFS avec moins de 4 GB de RAM

**Conséquence** : Performances médiocres, possibles problèmes de stabilité

**Solution** : Utiliser UFS si RAM < 4 GB

#### 5. Activer le chiffrement sans planification

**Problème** : Activer le chiffrement ZFS sans anticiper les redémarrages

**Conséquence** : Impossible de redémarrer automatiquement, nécessite intervention manuelle à chaque boot

**Solution** : N'activer le chiffrement que si nécessaire et avec une stratégie de gestion des mots de passe

#### 6. Mauvaise taille de disque

**Problème** : Utiliser un disque trop petit

**Conséquence** : Espace insuffisant pour les logs, packages, mises à jour

**Solution** : Minimum 8 GB recommandé, 16-32 GB idéal pour usage avec packages

### ✅ Bonnes pratiques

#### Avant l'installation

- **Documenter votre plan** : Notez quelle interface sera WAN/LAN avant de commencer
- **Vérifier la compatibilité matérielle** : Consultez la liste du matériel compatible pfSense
- **Préparer le plan d'adressage** : Décidez de vos réseaux IP à l'avance
- **Sauvegarder les configurations** : Si vous remplacez un équipement existant

#### Pendant l'installation

- **Utiliser des câbles de couleurs différentes** : WAN en rouge, LAN en bleu, etc.
- **Étiqueter les ports physiques** : Marquer physiquement WAN/LAN sur le boîtier
- **Prendre le temps** : Ne pas précipiter les étapes critiques (partitionnement, assignment)
- **Vérifier deux fois** : Confirmer chaque choix important avant de valider

#### Après l'installation

- **Changer le mot de passe immédiatement** : Via l'interface web dès la première connexion
- **Faire une sauvegarde de la config** : Diagnostics > Backup & Restore
- **Documenter la configuration** : Conserver un schéma réseau et les paramètres
- **Mettre à jour** : Vérifier les mises à jour disponibles

### 🎯 Astuces de pro

#### Récupération d'urgence

> [!tip] Accès console physique Gardez toujours un accès console physique (clavier/écran) possible. En cas de problème réseau, c'est votre seul moyen de récupération.

#### Virtualisation

> [!tip] Test en VM Avant une installation sur matériel physique, testez votre configuration en machine virtuelle pour vous familiariser avec le processus.

#### Documentation

> [!tip] Photos de configuration Prenez des photos de vos écrans de configuration au fur et à mesure. C'est une documentation rapide et efficace.

#### Performance

> [!tip] Désactivation du swap Sur un système avec 8+ GB de RAM et SSD, vous pouvez désactiver le swap après installation pour réduire l'usure du SSD. Mais laissez au moins 1-2 GB pour les crash dumps.

### 📊 Checklist post-installation

Avant de considérer l'installation comme terminée :

- [ ] Les interfaces WAN et LAN sont correctement assignées
- [ ] Le WAN obtient une IP (DHCP ou statique selon config)
- [ ] Le LAN a l'adresse IP configurée
- [ ] Le serveur DHCP fonctionne sur le LAN
- [ ] Un client peut obtenir une IP automatiquement
- [ ] L'interface web est accessible depuis le LAN
- [ ] Le mot de passe par défaut a été changé
- [ ] Une sauvegarde de configuration a été créée
- [ ] Le média d'installation a été retiré
- [ ] La documentation est à jour

> [!success] Installation réussie Si tous ces points sont validés, votre installation de base est réussie ! Vous êtes prêt pour la configuration via l'interface web et le déploiement des fonctionnalités avancées.

---

**Fin du module : Installation de pfSense**