

## 📋 Table des matières

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

## <a id="configuration-matérielle"></a>🖥️ Configuration matérielle minimale et recommandée

### Configuration matérielle minimale

Pour faire fonctionner pfSense dans un environnement de base, voici les exigences minimales :

|Composant|Spécification minimale|
|---|---|
|**Processeur**|CPU 64-bit (AMD64) à 600 MHz|
|**RAM**|1 Go|
|**Stockage**|8 Go (SSD/HDD)|
|**Interfaces réseau**|2 cartes réseau (WAN + LAN)|
|**Architecture**|AMD64 (x86-64) uniquement|

> [!warning] Attention aux limitations La configuration minimale permet uniquement de faire fonctionner pfSense. Elle ne convient PAS pour :
> 
> - Le filtrage de paquets intensif
> - Les VPN avec chiffrement
> - Les systèmes de détection d'intrusion (IDS/IPS)
> - La gestion de nombreuses connexions simultanées

### Configuration recommandée pour un usage professionnel

Pour un déploiement en production ou un environnement exigeant :

|Composant|Spécification recommandée|Justification|
|---|---|---|
|**Processeur**|Multi-cœurs 2+ GHz (Intel/AMD)|Nécessaire pour VPN, IDS/IPS, et filtrage avancé|
|**RAM**|4 Go minimum, 8 Go+ recommandé|Packages additionnels et cache proxy consomment beaucoup|
|**Stockage**|16-32 Go SSD|Logs, packages, et meilleures performances I/O|
|**Interfaces réseau**|2-4 cartes Gigabit|Séparation WAN/LAN/DMZ/Guest|

> [!tip] Optimisation du choix matériel
> 
> - **Pour le routage simple** : Un mini-PC type Intel NUC avec 2-4 Go de RAM suffit
> - **Pour 100+ utilisateurs** : 4+ cœurs CPU, 8 Go RAM, SSD rapide
> - **Pour VPN site-to-site** : Privilégier un CPU avec support AES-NI (accélération matérielle)
> - **Pour IDS/IPS (Snort/Suricata)** : 8+ Go RAM et CPU performant indispensables

### Considérations spécifiques selon le débit réseau

|Débit souhaité|CPU recommandé|RAM|Notes|
|---|---|---|---|
|10-100 Mbps|1 GHz single-core|2 Go|Parfait pour usage domestique|
|100-500 Mbps|2+ GHz dual-core|4 Go|PME standard|
|500 Mbps - 1 Gbps|2+ GHz quad-core|8 Go|Entreprise, avec VPN/IDS|
|1+ Gbps|3+ GHz multi-core avec AES-NI|16 Go|Data center, haute disponibilité|

> [!info] Support AES-NI AES-NI (Advanced Encryption Standard - New Instructions) est une extension CPU qui accélère le chiffrement/déchiffrement. C'est **crucial** pour :
> 
> - Les tunnels VPN (OpenVPN, IPsec)
> - Le trafic HTTPS intensif
> - Maintenir le débit réseau sous charge cryptographique
> 
> Depuis pfSense 2.5+, AES-NI est **obligatoire**. Vérifiez que votre CPU le supporte.

### Cartes réseau recommandées

Toutes les cartes réseau ne sont pas égales sous pfSense. Voici les chipsets privilégiés :

**✅ Recommandés (excellent support FreeBSD)** :

- **Intel** : i350, i210, i211, 82580 (drivers `igb`, `em`)
- **Broadcom** : BCM5719, BCM5720 (driver `bge`)
- **Chelsio** : T520, T540 (pour 10G+)

**⚠️ À éviter** :

- Realtek (drivers instables, performances médiocres)
- Cartes WiFi en général (support limité, mieux vaut utiliser un AP dédié)
- Cartes USB (latence élevée, déconnexions possibles)

> [!example] Exemple de configuration type PME **Scénario** : Entreprise de 50 employés, connexion fibre 500 Mbps, VPN site-to-site, IDS/IPS actif
> 
> - **Matériel** : Supermicro SYS-E200-8D ou équivalent
> - **CPU** : Intel Xeon D-1518 (4 cœurs, 2.2 GHz, AES-NI)
> - **RAM** : 16 Go ECC
> - **Stockage** : SSD 120 Go
> - **NICs** : 4x Intel i350 Gigabit
> - **Coût approximatif** : 600-1000€

---

## <a id="architectures-réseau"></a>🏗️ Architectures réseau supportées

pfSense peut s'adapter à différentes topologies réseau selon vos besoins.

### Architecture de base : WAN + LAN

L'architecture minimale et la plus courante :

```
Internet (WAN)
      |
   pfSense
      |
   Switch ─── Réseau local (LAN)
```

**Caractéristiques** :

- 2 interfaces réseau minimum
- WAN : connexion Internet (DHCP, PPPoE, IP statique)
- LAN : réseau interne (généralement 192.168.1.0/24)
- Tous les équipements internes partagent le même segment réseau

**Cas d'usage** :

- Domicile
- Très petite entreprise (TPE)
- Lab/test

### Architecture à 3 interfaces : WAN + LAN + DMZ

Segmentation pour séparer les serveurs publics du réseau interne :

```
Internet (WAN)
      |
   pfSense ─── DMZ ─── Serveurs publics (web, mail)
      |
     LAN ─── Réseau interne
```

**Caractéristiques** :

- 3 interfaces réseau
- DMZ (zone démilitarisée) : serveurs accessibles depuis Internet
- Règles de pare-feu strictes entre DMZ et LAN
- Les serveurs DMZ ne peuvent pas initier de connexions vers le LAN

**Cas d'usage** :

- PME avec serveurs web/mail internes
- Services exposés à Internet
- Conformité sécurité (isolation des services publics)

> [!warning] Règles DMZ critiques Par défaut, créez des règles restrictives :
> 
> - DMZ → Internet : Autorisé (updates, DNS)
> - Internet → DMZ : Uniquement ports nécessaires (80, 443, 25, etc.)
> - DMZ → LAN : **INTERDIT** par défaut
> - LAN → DMZ : Autorisé pour administration

### Architecture à 4+ interfaces : Segmentation avancée

Pour une sécurité maximale avec plusieurs segments :

```
Internet (WAN)
      |
   pfSense ─── LAN (employés)
      |─────── DMZ (serveurs publics)
      |─────── GUEST (WiFi invités)
      |─────── IOT (objets connectés)
```

**Caractéristiques** :

- 4+ interfaces réseau (physiques ou VLANs)
- Isolation complète entre segments
- Règles de pare-feu granulaires par segment
- QoS possible par interface

**Cas d'usage** :

- Entreprises avec politique de sécurité stricte
- Environnements multi-tenants
- Hôtels, centres de conférences
- Écoles et universités

> [!tip] VLANs vs interfaces physiques Vous n'avez pas besoin d'une carte réseau par segment. Utilisez les **VLANs** (802.1Q) :
> 
> - 1 interface physique trunk peut porter plusieurs VLANs
> - pfSense crée des interfaces virtuelles (em0.10, em0.20, etc.)
> - Nécessite un switch manageable compatible 802.1Q
> - Plus économique et flexible

### Architecture haute disponibilité (HA)

Deux pfSense en cluster pour éliminer le point de défaillance unique :

```
Internet (WAN)
    |     |
  pfSense1 ── CARP sync ── pfSense2
    |     |
   Switch LAN
```

**Caractéristiques** :

- 2 instances pfSense (master/backup)
- CARP (Common Address Redundancy Protocol) pour le basculement
- Synchronisation automatique de la configuration
- Basculement automatique en cas de panne
- IP virtuelle partagée (VIP)

**Cas d'usage** :

- Infrastructures critiques (99.9%+ uptime requis)
- Data centers
- Sites e-commerce
- Services financiers

> [!info] Prérequis pour HA
> 
> - 3 interfaces minimum par firewall (WAN, LAN, Sync)
> - Câble réseau dédié pour la synchronisation (recommandé)
> - Configuration identique sur les deux machines
> - Licences identiques si packages commerciaux utilisés

### Tableau comparatif des architectures

|Architecture|Nb interfaces min|Complexité|Sécurité|Cas d'usage type|
|---|---|---|---|---|
|WAN + LAN|2|⭐ Faible|⭐⭐ Basique|Domicile, TPE|
|WAN + LAN + DMZ|3|⭐⭐ Moyenne|⭐⭐⭐ Bonne|PME avec serveurs|
|Segmentation multi-zones|4+|⭐⭐⭐ Élevée|⭐⭐⭐⭐ Excellente|Entreprise, conformité|
|Haute disponibilité|6+ (2x3)|⭐⭐⭐⭐ Très élevée|⭐⭐⭐⭐⭐ Maximale|Datacenter, critique|

---

## <a id="téléchargement-iso"></a>💾 Téléchargement de l'ISO

### Obtenir la dernière version de pfSense

pfSense est distribué gratuitement via le site officiel de Netgate.

**URL officielle** : [https://www.pfsense.org/download/](https://www.pfsense.org/download/)

> [!warning] Sources de téléchargement Téléchargez **UNIQUEMENT** depuis le site officiel Netgate. Les miroirs non officiels peuvent contenir :
> 
> - Des versions obsolètes avec des failles de sécurité
> - Des images modifiées avec backdoors
> - Des malwares

### Choisir la bonne image ISO

Lors du téléchargement, vous devez sélectionner plusieurs paramètres :

#### 1. Version de pfSense

|Version|Description|Recommandation|
|---|---|---|
|**CE (Community Edition)**|Version gratuite et open-source|✅ Pour la majorité des cas|
|**Plus**|Version commerciale avec support Netgate|Pour entreprises nécessitant support|

> [!info] Différences CE vs Plus
> 
> - **CE** : Gratuit, mises à jour communautaires, aucun support officiel
> - **Plus** : Payant, support technique Netgate, packages additionnels exclusifs
> 
> Pour apprendre et la plupart des déploiements, **CE suffit largement**.

#### 2. Architecture

Depuis pfSense 2.5+, seule l'architecture **AMD64** (x86-64) est supportée.

- ✅ **AMD64** : Processeurs Intel et AMD 64-bit modernes
- ❌ ~~i386~~ : Architecture 32-bit (abandonnée)
- ❌ ~~ARM~~ : Non supporté officiellement

#### 3. Type d'installation

|Type|Extension|Description|Usage|
|---|---|---|---|
|**ISO Installer**|`.iso.gz`|Image d'installation complète|Installation sur disque dur/SSD|
|**Memstick Installer**|`.img.gz`|Image pour clé USB bootable|Installation via USB|

> [!tip] Quel format choisir ?
> 
> - **ISO** : Pour machines virtuelles (VMware, VirtualBox, Proxmox) ou gravure CD
> - **Memstick** : Pour matériel physique avec boot USB

#### 4. Type de console

|Console|Description|Quand l'utiliser|
|---|---|---|
|**VGA**|Console graphique standard|Machines avec écran connecté|
|**Serial**|Console série (COM)|Serveurs headless, accès via RS-232|

**Pour débuter, choisissez VGA**.

### Exemple de téléchargement type

Configuration recommandée pour débuter :

```
Version: pfSense CE 2.7.x
Architecture: AMD64
Installer: ISO (DVD)
Console: VGA
```

Fichier obtenu : `pfSense-CE-2.7.x-RELEASE-amd64.iso.gz` (environ 800-900 Mo compressé)

### Vérification de l'intégrité

Après téléchargement, vérifiez l'intégrité du fichier avec les checksums fournis.

**Sur le site Netgate, vous trouverez** :

- **SHA256** : Empreinte cryptographique du fichier
- **Fichier de signature** : Pour vérification GPG (optionnel)

#### Vérification sous Linux/macOS

```bash
# Décompresser le fichier .gz
gunzip pfSense-CE-2.7.x-RELEASE-amd64.iso.gz

# Calculer le SHA256
sha256sum pfSense-CE-2.7.x-RELEASE-amd64.iso

# Comparer avec le SHA256 affiché sur le site
```

#### Vérification sous Windows

```powershell
# Avec PowerShell
Get-FileHash -Algorithm SHA256 pfSense-CE-2.7.x-RELEASE-amd64.iso

# Comparer manuellement avec le hash du site
```

> [!warning] Si les checksums ne correspondent pas **NE PAS UTILISER L'IMAGE** et re-télécharger. Un hash différent indique :
> 
> - Téléchargement corrompu
> - Fichier modifié (potentiellement compromis)

---

## <a id="création-support"></a>🔧 Création du support d'installation

Une fois l'ISO téléchargée et vérifiée, vous devez créer un support bootable.

### Option 1 : Installation en machine virtuelle (recommandé pour débuter)

Aucun support physique nécessaire, utilisez directement l'ISO.

#### VMware Workstation/ESXi

1. Créer nouvelle VM
2. Type de système : **FreeBSD 64-bit** (ou Other/Linux si absent)
3. Attacher l'ISO au lecteur CD/DVD virtuel
4. Configuration réseau :
    - Adapter 1 : Bridged (WAN, connexion Internet de l'hôte)
    - Adapter 2 : Host-only ou Internal (LAN)

#### VirtualBox

1. Créer nouvelle VM
2. Type : **BSD → FreeBSD (64-bit)**
3. Attacher l'ISO dans Stockage → Contrôleur IDE
4. Configuration réseau :
    - Carte 1 : Accès par pont (WAN)
    - Carte 2 : Réseau interne (LAN)

#### Proxmox VE

```bash
# Uploader l'ISO dans Proxmox (via interface web ou SCP)

# Créer la VM via CLI
qm create 100 --name pfSense --ostype l26 --memory 2048 --cores 2
qm set 100 --ide2 local:iso/pfSense-CE-2.7.x-RELEASE-amd64.iso,media=cdrom
qm set 100 --net0 virtio,bridge=vmbr0  # WAN
qm set 100 --net1 virtio,bridge=vmbr1  # LAN
qm set 100 --scsi0 local-lvm:16        # Disque 16 Go

# Démarrer
qm start 100
```

> [!tip] Configuration réseau VM Pour tester pfSense en VM sans perturber votre réseau existant :
> 
> - WAN : Bridged ou NAT vers votre réseau local
> - LAN : Réseau interne/host-only avec un segment dédié (ex: 10.0.0.0/24)
> - Créez une 2ème VM cliente sur le réseau LAN pour tester

### Option 2 : Création d'une clé USB bootable (installation physique)

Pour installer pfSense sur du matériel réel, créez une clé USB bootable.

**Prérequis** :

- Clé USB de 2 Go minimum (sera effacée)
- Image Memstick (`.img.gz`) téléchargée

#### Sous Linux

```bash
# Décompresser l'image
gunzip pfSense-CE-2.7.x-RELEASE-amd64-memstick.img.gz

# Identifier le device USB (ATTENTION : vérifier /dev/sdX)
lsblk

# Écrire l'image (REMPLACER /dev/sdX par votre clé USB)
sudo dd if=pfSense-CE-2.7.x-RELEASE-amd64-memstick.img of=/dev/sdX bs=4M status=progress

# Synchroniser les écritures
sync
```

> [!warning] Commande dd destructive La commande `dd` écrase **tout le contenu** du périphérique cible. Vérifiez TROIS FOIS que vous visez la bonne clé USB avec `lsblk` avant d'exécuter !
> 
> ❌ **Erreur courante** : `of=/dev/sda` efface votre disque système principal

#### Sous macOS

```bash
# Décompresser
gunzip pfSense-CE-2.7.x-RELEASE-amd64-memstick.img.gz

# Identifier la clé USB
diskutil list

# Démonter la clé (REMPLACER diskN)
diskutil unmountDisk /dev/diskN

# Écrire l'image (noter le 'r' dans rdiskN pour raw disk = plus rapide)
sudo dd if=pfSense-CE-2.7.x-RELEASE-amd64-memstick.img of=/dev/rdiskN bs=4m

# Éjecter proprement
diskutil eject /dev/diskN
```

#### Sous Windows

Utilisez un outil graphique comme **Rufus** ou **balenaEtcher**.

**Avec Rufus** :

1. Télécharger Rufus : [https://rufus.ie/](https://rufus.ie/)
2. Décompresser l'image `.img.gz` avec 7-Zip ou WinRAR
3. Lancer Rufus
4. **Périphérique** : Sélectionner votre clé USB
5. **Sélection de démarrage** : Cliquer "SÉLECTION" → choisir le fichier `.img`
6. **Schéma de partition** : MBR
7. **Système de destination** : BIOS (ou UEFI-CSM)
8. Cliquer **DÉMARRER**

**Avec balenaEtcher** :

1. Télécharger Etcher : [https://etcher.balena.io/](https://etcher.balena.io/)
2. Lancer Etcher
3. **Flash from file** → Sélectionner le `.img.gz` (Etcher décompresse automatiquement)
4. **Select target** → Votre clé USB
5. **Flash!**

> [!tip] UEFI vs BIOS Matériel moderne (2012+) utilise UEFI. pfSense supporte les deux modes :
> 
> - **BIOS/Legacy** : Compatibilité maximale, mode traditionnel
> - **UEFI** : Boot plus rapide, Secure Boot (désactiver Secure Boot pour pfSense)
> 
> Si vous avez des problèmes de boot, essayez de basculer entre UEFI et Legacy dans le BIOS.

### Option 3 : Gravure CD/DVD (méthode obsolète)

Si vous utilisez encore des lecteurs optiques :

- **Linux** : `brasero`, `k3b`, ou `cdrecord`
- **macOS** : Utilitaire de disque (Graver l'image)
- **Windows** : ImgBurn, CDBurnerXP, ou outil natif Windows

> [!info] DVD recommandé L'image ISO fait ~800 Mo, un CD classique (700 Mo) ne suffit plus. Utilisez un DVD ou préférez une clé USB.

### Vérification du support créé

Avant de démarrer l'installation, vérifiez que le support est bootable :

1. Insérer la clé USB / CD dans la machine cible
2. Redémarrer et accéder au menu de boot (F12, F11, ESC, DEL selon constructeur)
3. Sélectionner le support USB/CD
4. Le menu d'installation pfSense devrait apparaître

Si le boot échoue :

- Vérifier l'ordre de boot dans le BIOS (USB/CD avant le disque dur)
- Essayer de basculer entre UEFI et Legacy
- Recréer le support d'installation
- Tester sur une autre machine

---

## 🎯 Pièges courants à éviter

> [!warning] Erreurs fréquentes lors de la préparation

### 1. Matériel incompatible

**Problème** : CPU sans AES-NI sur pfSense 2.5+ **Solution** : Vérifier le support AES-NI avec `grep aes /proc/cpuinfo` (Linux) ou sur le site Intel ARK

### 2. Carte réseau Realtek

**Problème** : Performances médiocres, drivers instables sous FreeBSD **Solution** : Investir dans des cartes Intel (i350, i210) pour la fiabilité

### 3. RAM insuffisante

**Problème** : pfSense crashe avec Snort/Suricata activé **Solution** : Minimum 4 Go pour IDS/IPS, 8 Go recommandé

### 4. Mauvais choix d'architecture réseau

**Problème** : Serveurs publics sur le LAN (risque sécuritaire) **Solution** : Créer une DMZ séparée dès le départ

### 5. Support USB défectueux

**Problème** : Boot échoue ou installation se bloque **Solution** : Tester avec une autre clé USB, vérifier le checksum de l'image

### 6. Oublier la sauvegarde de configuration

**Problème** : Lors de tests/réinstallations, perte de la configuration **Solution** : Sauvegarder régulièrement via Diagnostics → Backup & Restore

---

## 💡 Bonnes pratiques

### Planification avant installation

✅ **Documenter l'infrastructure** :

- Plan d'adressage IP (WAN, LAN, DMZ, VLANs)
- Schéma réseau avec interfaces
- Liste des VLANs et leurs usages

✅ **Préparer les informations réseau** :

- Type de connexion WAN (DHCP, PPPoE, statique)
- Identifiants FAI si nécessaire
- Plages IP à utiliser pour chaque segment

✅ **Matériel redondant** :

- Prévoir 2 cartes réseau de remplacement (Intel si possible)
- Support USB de secours
- Accès console série en backup (pour serveurs distants)

### Laboratoire de test

Avant un déploiement en production :

1. Installer pfSense en VM
2. Reproduire l'architecture cible
3. Tester les règles de pare-feu
4. Valider les packages nécessaires (VPN, IDS, etc.)
5. Documenter la configuration
6. Créer une checklist d'installation

### Sécurité dès la préparation

🔒 **Checklist sécurité** :

- Télécharger uniquement depuis sources officielles
- Vérifier TOUJOURS les checksums SHA256
- Utiliser des mots de passe complexes (notés dans un gestionnaire)
- Planifier la segmentation réseau dès le départ
- Prévoir une stratégie de sauvegarde

---

Vous êtes maintenant prêt pour l'installation de pfSense ! Le matériel est choisi, l'ISO téléchargée et vérifiée, et le support d'installation créé. La préparation minutieuse garantit une installation sans problème et un déploiement sécurisé.