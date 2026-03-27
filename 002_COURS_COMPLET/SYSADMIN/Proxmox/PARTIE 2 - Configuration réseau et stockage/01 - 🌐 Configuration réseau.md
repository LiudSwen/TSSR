# 

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

## 🎯 Introduction à la configuration réseau {#introduction}

La configuration réseau dans Proxmox est un élément fondamental qui détermine comment vos machines virtuelles et conteneurs communiqueront avec le monde extérieur et entre eux. Une mauvaise configuration réseau peut isoler complètement votre infrastructure ou créer des problèmes de performances difficiles à diagnostiquer.

> [!info] Pourquoi c'est critique
> 
> - Le réseau est configuré au niveau de l'hyperviseur (Proxmox)
> - Une erreur peut vous déconnecter de votre serveur
> - La configuration persiste après redémarrage
> - Elle impacte directement les performances des VMs

---

## 🔌 Interfaces réseau {#interfaces-reseau}

Proxmox supporte trois types principaux d'interfaces réseau, chacune répondant à des besoins spécifiques.

### 📡 Physical Interface {#physical-interface}

Une interface physique correspond à une carte réseau réelle (NIC) de votre serveur.

**Quand l'utiliser :**

- Pour l'interface de gestion de Proxmox lui-même
- Quand vous n'avez besoin que de connectivité basique
- Pour des configurations simples sans virtualisation réseau

**Caractéristiques :**

- Nommée généralement `enpXsY` ou `ethX` (selon la convention de nommage)
- Directement liée au matériel physique
- Ne peut pas être partagée nativement avec les VMs

```bash
# Exemple de configuration d'une interface physique
auto eno1
iface eno1 inet static
    address 192.168.1.10/24
    gateway 192.168.1.1
```

> [!warning] Attention N'utilisez JAMAIS une interface physique directement pour vos VMs. Utilisez toujours un bridge pour permettre le partage de la connexion.

---

### 🌉 Linux Bridge {#linux-bridge}

Le Linux Bridge est un switch virtuel logiciel qui permet de connecter plusieurs interfaces ensemble. C'est le composant central du réseau Proxmox.

**Pourquoi utiliser un Bridge :**

- Permet de partager une interface physique entre Proxmox et les VMs
- Crée un réseau local virtuel
- Fonctionne comme un switch réseau classique
- Indispensable pour la virtualisation réseau

**Architecture typique :**

```
┌───────────────────────────────────────────┐
│       Proxmox Host (192.168.1.10)         │
│                                           │
│  ┌─────────────────────────────────────┐  │
│  │       vmbr0 (Linux Bridge)          │  │
│  │         192.168.1.10/24             │  │
│  └──────┬─────────┬─────────┬──────────┘  │
│         │         │         │             │
│    ┌────┴───┐ ┌──┴───┐ ┌───┴────┐         │
│    │  VM1   │ │ VM2  │ │  eno1  │         │
│    └────────┘ └──────┘ └───┬────┘         │
└────────────────────────────┼──────────────┘
                             │
                        Réseau physique
```

**Configuration d'un bridge :**

```bash
# Bridge pour VMs avec accès réseau standard
auto vmbr0
iface vmbr0 inet static
    address 192.168.1.10/24
    gateway 192.168.1.1
    bridge-ports eno1        # Interface physique attachée
    bridge-stp off           # Spanning Tree Protocol (désactivé par défaut)
    bridge-fd 0              # Forward Delay à 0 pour démarrage rapide
```

> [!tip] Astuce Vous pouvez créer plusieurs bridges pour segmenter votre réseau. Par exemple, `vmbr0` pour le réseau de production et `vmbr1` pour un réseau isolé de test.

**Bridge sans interface physique (réseau isolé) :**

```bash
# Bridge interne uniquement pour communication inter-VMs
auto vmbr1
iface vmbr1 inet static
    address 10.10.10.1/24
    bridge-ports none        # Aucune interface physique
    bridge-stp off
    bridge-fd 0
```

> [!example] Cas d'usage Un bridge sans interface physique est parfait pour :
> 
> - Créer un réseau DMZ isolé
> - Tester des configurations réseau sans impact externe
> - Interconnecter des VMs sans accès internet

---

### 🔗 Bond (Agrégation de liens) {#bond}

Le bonding permet de combiner plusieurs interfaces physiques en une seule interface logique pour augmenter la bande passante ou la redondance.

**Modes de bonding courants :**

|Mode|Nom|Description|Usage|
|---|---|---|---|
|0|balance-rr|Round-robin, distribue les paquets|Performance maximale|
|1|active-backup|Une seule active, bascule si panne|Haute disponibilité simple|
|2|balance-xor|Distribution par hash MAC|Charge équilibrée|
|4|802.3ad (LACP)|Agrégation standard IEEE|Production avec switch manageable|
|6|balance-alb|Équilibrage adaptatif|Performance sans config switch|

**Configuration d'un bond en mode active-backup :**

```bash
# Bond avec deux interfaces pour redondance
auto bond0
iface bond0 inet manual
    bond-slaves eno1 eno2      # Interfaces physiques membres
    bond-miimon 100            # Vérification de lien toutes les 100ms
    bond-mode active-backup    # Mode redondance
    bond-primary eno1          # Interface primaire préférée

# Bridge utilisant le bond
auto vmbr0
iface vmbr0 inet static
    address 192.168.1.10/24
    gateway 192.168.1.1
    bridge-ports bond0         # Le bridge utilise le bond
    bridge-stp off
    bridge-fd 0
```

**Configuration LACP (802.3ad) pour performance :**

```bash
# Bond en mode LACP (nécessite support switch)
auto bond0
iface bond0 inet manual
    bond-slaves eno1 eno2
    bond-miimon 100
    bond-mode 802.3ad          # Mode LACP
    bond-xmit-hash-policy layer2+3  # Hash basé sur MAC + IP
    bond-lacp-rate fast        # Négociation LACP rapide

auto vmbr0
iface vmbr0 inet static
    address 192.168.1.10/24
    gateway 192.168.1.1
    bridge-ports bond0
    bridge-stp off
    bridge-fd 0
```

> [!warning] Prérequis pour LACP
> 
> - Votre switch doit supporter et avoir LACP activé
> - Les ports du switch doivent être dans le même agrégat
> - La configuration doit être identique des deux côtés

> [!tip] Choix du mode de bond
> 
> - **Mode 1 (active-backup)** : Le plus simple et fiable, aucune config switch requise
> - **Mode 4 (LACP)** : Meilleure performance mais nécessite un switch manageable
> - **Mode 6 (balance-alb)** : Bon compromis sans config switch

---

## 🏷️ Configuration VLAN {#configuration-vlan}

Les VLANs (Virtual Local Area Network) permettent de segmenter logiquement un réseau physique en plusieurs réseaux isolés. Dans Proxmox, ils sont essentiels pour organiser et sécuriser votre infrastructure.

**Pourquoi utiliser des VLANs :**

- Isolation du trafic réseau entre différents services
- Sécurité renforcée (séparation logique)
- Économie de ports physiques
- Flexibilité dans l'organisation réseau

### Architecture VLAN typique

```
                    Switch avec VLANs
                    ┌──────────────┐
            VLAN 10 │   VLAN 20    │ VLAN 30
         (Gestion)  │  (Production)│ (DMZ)
                    └───────┬──────┘
                            │ Trunk
                    ┌───────┴──────┐
                    │   Proxmox    │
                    │    eno1      │
                    └──────────────┘
                    │   │   │   │
              vmbr0 │   │   │   │ vmbr0.30
         (Natif)    │   │   │   └─(VLAN 30)
                    │   │   └─vmbr0.20
                    │   │      (VLAN 20)
                    │   └─vmbr0.10
                    │      (VLAN 10)
```

### Configuration VLAN-aware bridge

**Méthode recommandée : VLAN-aware bridge**

```bash
# Bridge principal VLAN-aware
auto vmbr0
iface vmbr0 inet static
    address 192.168.1.10/24
    gateway 192.168.1.1
    bridge-ports eno1
    bridge-stp off
    bridge-fd 0
    bridge-vlan-aware yes      # Active le support VLAN
    bridge-vids 2-4094         # VLANs autorisés (tous)
```

> [!info] VLAN-aware vs interfaces VLAN traditionnelles Le mode VLAN-aware est plus moderne et performant. Il permet de gérer tous les VLANs depuis un seul bridge plutôt que de créer une interface par VLAN.

**Avec un VLAN-aware bridge :**

- Vous configurez le VLAN directement sur la VM dans l'interface Proxmox
- Plus simple à gérer
- Meilleur pour de nombreux VLANs
- Recommandé depuis Proxmox 5.1+

### Configuration avec interfaces VLAN traditionnelles

**Méthode classique (toujours valide) :**

```bash
# Bridge principal sans VLAN
auto vmbr0
iface vmbr0 inet static
    address 192.168.1.10/24
    gateway 192.168.1.1
    bridge-ports eno1
    bridge-stp off
    bridge-fd 0

# Interface VLAN 10 (Gestion)
auto vmbr0.10
iface vmbr0.10 inet static
    address 10.0.10.1/24

# Interface VLAN 20 (Production)
auto vmbr0.20
iface vmbr0.20 inet static
    address 10.0.20.1/24

# Interface VLAN 30 (DMZ)
auto vmbr0.30
iface vmbr0.30 inet static
    address 10.0.30.1/24
```

**Bridge dédié par VLAN :**

```bash
# Bridge pour VLAN 10
auto vmbr10
iface vmbr10 inet static
    address 10.0.10.1/24
    bridge-ports eno1.10       # Sous-interface VLAN
    bridge-stp off
    bridge-fd 0

# Bridge pour VLAN 20
auto vmbr20
iface vmbr20 inet static
    address 10.0.20.1/24
    bridge-ports eno1.20
    bridge-stp off
    bridge-fd 0
```

> [!tip] Quelle méthode choisir ?
> 
> - **VLAN-aware** : Nouveau déploiement, nombreux VLANs, gestion simplifiée
> - **Interfaces traditionnelles** : Infrastructure existante, besoin de contrôle granulaire par VLAN

### Configuration du switch

> [!warning] Configuration switch obligatoire Pour que les VLANs fonctionnent, votre switch doit être configuré :
> 
> - Le port connecté à Proxmox doit être en mode **Trunk** (ou Tagged)
> - Les VLANs doivent être autorisés sur ce port
> - Un VLAN natif peut être défini (généralement VLAN 1)

**Exemple de configuration switch Cisco :**

```bash
interface GigabitEthernet0/1
  description Proxmox Server
  switchport mode trunk
  switchport trunk allowed vlan 10,20,30
  switchport trunk native vlan 1
```

---

## 📄 Le fichier /etc/network/interfaces {#fichier-interfaces}

Le fichier `/etc/network/interfaces` est le cœur de la configuration réseau sous Proxmox (basé sur Debian). Toute modification de ce fichier impacte directement la connectivité.

### Structure et syntaxe

**Localisation :** `/etc/network/interfaces`

**Anatomie du fichier :**

```bash
# Le fichier interfaces(5) est utilisé par ifup et ifdown
# Voir interfaces(5) pour plus d'informations

# Interface de loopback (toujours présente)
auto lo
iface lo inet loopback

# Interface physique (optionnel, souvent en manual si utilisée via bridge)
auto eno1
iface eno1 inet manual

# Bridge principal avec adresse IP de gestion
auto vmbr0
iface vmbr0 inet static
    address 192.168.1.10/24      # IP de Proxmox
    gateway 192.168.1.1          # Passerelle par défaut
    bridge-ports eno1            # Interface(s) physique(s)
    bridge-stp off               # Spanning Tree Protocol
    bridge-fd 0                  # Forward Delay
    # Options DNS (optionnel)
    dns-nameservers 8.8.8.8 1.1.1.1
    dns-search mondomaine.local
```

### Directives importantes

|Directive|Description|Valeurs courantes|
|---|---|---|
|`auto`|Démarre l'interface au boot|`auto eth0`|
|`iface`|Définit une interface|`inet static/dhcp/manual`|
|`address`|Adresse IP|Format CIDR: `192.168.1.10/24`|
|`gateway`|Passerelle par défaut|IP: `192.168.1.1`|
|`bridge-ports`|Interfaces membres du bridge|`eno1` ou `bond0` ou `none`|
|`bridge-stp`|Spanning Tree Protocol|`on` ou `off`|
|`bridge-fd`|Forward Delay|`0` à `30` (secondes)|
|`bridge-vlan-aware`|Support VLAN moderne|`yes` ou `no`|
|`bond-slaves`|Interfaces du bond|`eno1 eno2`|
|`bond-mode`|Mode d'agrégation|`active-backup`, `802.3ad`, etc.|

### Exemples de configurations complètes

**Configuration simple (serveur unique) :**

```bash
auto lo
iface lo inet loopback

auto eno1
iface eno1 inet manual

auto vmbr0
iface vmbr0 inet static
    address 192.168.1.100/24
    gateway 192.168.1.1
    bridge-ports eno1
    bridge-stp off
    bridge-fd 0
    dns-nameservers 8.8.8.8
```

**Configuration avancée (bond + VLANs) :**

```bash
auto lo
iface lo inet loopback

# Interfaces physiques en mode manual
auto eno1
iface eno1 inet manual

auto eno2
iface eno2 inet manual

# Bond en mode active-backup
auto bond0
iface bond0 inet manual
    bond-slaves eno1 eno2
    bond-miimon 100
    bond-mode active-backup
    bond-primary eno1

# Bridge principal VLAN-aware
auto vmbr0
iface vmbr0 inet static
    address 192.168.1.10/24
    gateway 192.168.1.1
    bridge-ports bond0
    bridge-stp off
    bridge-fd 0
    bridge-vlan-aware yes
    bridge-vids 2-4094

# Bridge interne pour réseau isolé
auto vmbr1
iface vmbr1 inet static
    address 10.10.10.1/24
    bridge-ports none
    bridge-stp off
    bridge-fd 0
```

**Configuration avec VLANs traditionnels :**

```bash
auto lo
iface lo inet loopback

auto eno1
iface eno1 inet manual

# Bridge principal (VLAN natif)
auto vmbr0
iface vmbr0 inet static
    address 192.168.1.10/24
    gateway 192.168.1.1
    bridge-ports eno1
    bridge-stp off
    bridge-fd 0

# VLAN 10 - Gestion
auto eno1.10
iface eno1.10 inet manual

auto vmbr10
iface vmbr10 inet static
    address 10.0.10.1/24
    bridge-ports eno1.10
    bridge-stp off
    bridge-fd 0

# VLAN 20 - Production
auto eno1.20
iface eno1.20 inet manual

auto vmbr20
iface vmbr20 inet static
    address 10.0.20.1/24
    bridge-ports eno1.20
    bridge-stp off
    bridge-fd 0
```

### Modification du fichier

> [!warning] Danger : perte de connectivité Une erreur dans ce fichier peut vous déconnecter complètement du serveur. Toujours :
> 
> - Avoir un accès physique ou IPMI en backup
> - Faire une copie avant modification
> - Tester avec `ifreload -a` avant de redémarrer

**Procédure sécurisée de modification :**

```bash
# 1. Sauvegarde du fichier actuel
cp /etc/network/interfaces /etc/network/interfaces.backup

# 2. Édition du fichier
nano /etc/network/interfaces

# 3. Vérification de la syntaxe (pas d'outil dédié, relecture manuelle)

# 4. Application des changements sans redémarrage
ifreload -a

# 5. Test de connectivité
ping -c 3 192.168.1.1

# 6. Si problème, restauration immédiate
cp /etc/network/interfaces.backup /etc/network/interfaces
ifreload -a
```

> [!tip] Astuce de sécurité Créez un script avec un revert automatique :
> 
> ```bash
> #!/bin/bash
> cp /etc/network/interfaces.backup /etc/network/interfaces
> ifreload -a
> ```
> 
> Planifiez-le avec `at` pour dans 5 minutes. Si tout fonctionne, annulez-le.

---

## 🛠️ Commandes utiles {#commandes-utiles}

### Gestion des interfaces

```bash
# Lister toutes les interfaces
ip addr show
# ou
ip a

# Afficher une interface spécifique
ip addr show vmbr0

# Afficher les bridges
brctl show
# ou (plus moderne)
bridge link show

# Afficher l'état d'un bond
cat /proc/net/bonding/bond0

# Voir les VLANs configurés
cat /proc/net/vlan/config
```

### Application de configurations

```bash
# Recharger la configuration réseau (méthode douce)
ifreload -a

# Redémarrer le service réseau (méthode forte)
systemctl restart networking

# Activer une interface
ifup vmbr0

# Désactiver une interface
ifdown vmbr0

# Redémarrer une interface
ifdown vmbr0 && ifup vmbr0
```

### Diagnostic réseau

```bash
# Tester la connectivité
ping -c 4 192.168.1.1

# Tracer la route
traceroute 8.8.8.8

# Afficher la table de routage
ip route show

# Tester la résolution DNS
nslookup google.com

# Statistiques réseau en temps réel
iftop -i vmbr0
# ou
nload vmbr0

# Capturer le trafic
tcpdump -i vmbr0 -n

# Vérifier les ports ouverts
ss -tulpn
# ou
netstat -tulpn
```

### Manipulation des bridges

```bash
# Créer un bridge temporaire (non persistant)
ip link add name vmbr2 type bridge

# Ajouter une interface à un bridge
ip link set eno1 master vmbr0

# Retirer une interface d'un bridge
ip link set eno1 nomaster

# Activer un bridge
ip link set vmbr2 up

# Afficher les interfaces d'un bridge
bridge link show vmbr0
```

### Manipulation des VLANs

```bash
# Créer une interface VLAN (temporaire)
ip link add link eno1 name eno1.10 type vlan id 10

# Supprimer une interface VLAN
ip link delete eno1.10

# Afficher les VLANs sur un bridge VLAN-aware
bridge vlan show dev vmbr0

# Ajouter un VLAN à un port de bridge
bridge vlan add vid 20 dev vmbr0
```

### Vérification de configuration

```bash
# Vérifier la configuration actuelle
cat /etc/network/interfaces

# Comparer avec la sauvegarde
diff /etc/network/interfaces /etc/network/interfaces.backup

# Voir les changements non appliqués
# (nécessite de comparer avec ip a)

# Tester la configuration avant application
ifup --no-act vmbr0
```

> [!tip] Commandes de dépannage rapide
> 
> ```bash
> # Commande tout-en-un pour diagnostic
> ip a && ip r && cat /etc/resolv.conf
> 
> # Voir tous les services réseau
> systemctl status networking
> ```

### Logs et monitoring

```bash
# Journaux du système réseau
journalctl -u networking -n 50

# Logs en temps réel
journalctl -u networking -f

# Messages kernel liés au réseau
dmesg | grep -i eth
dmesg | grep -i link

# Statistiques des interfaces
cat /sys/class/net/eno1/statistics/rx_bytes
cat /sys/class/net/eno1/statistics/tx_bytes
```

---

## 🎯 Pièges courants et bonnes pratiques

### ❌ Erreurs fréquentes

**1. Oublier `bridge-ports` dans un bridge**

```bash
# ❌ INCORRECT - Bridge sans interface attachée (sauf si volontaire)
auto vmbr0
iface vmbr0 inet static
    address 192.168.1.10/24
    # Manque bridge-ports !

# ✅ CORRECT
auto vmbr0
iface vmbr0 inet static
    address 192.168.1.10/24
    bridge-ports eno1
```

**2. Interface physique avec IP alors qu'elle est dans un bridge**

```bash
# ❌ INCORRECT - Conflit d'adressage
auto eno1
iface eno1 inet static
    address 192.168.1.10/24  # Ne pas mettre d'IP ici !

auto vmbr0
iface vmbr0 inet static
    address 192.168.1.10/24  # L'IP doit être sur le bridge
    bridge-ports eno1

# ✅ CORRECT
auto eno1
iface eno1 inet manual       # Mode manual, pas d'IP

auto vmbr0
iface vmbr0 inet static
    address 192.168.1.10/24
    bridge-ports eno1
```

**3. Oublier `auto` pour une interface**

```bash
# ❌ INCORRECT - L'interface ne démarrera pas au boot
iface vmbr0 inet static
    address 192.168.1.10/24

# ✅ CORRECT
auto vmbr0
iface vmbr0 inet static
    address 192.168.1.10/24
```

**4. Mauvais masque de sous-réseau**

```bash
# ❌ INCORRECT - Format ancien
iface vmbr0 inet static
    address 192.168.1.10
    netmask 255.255.255.0

# ✅ CORRECT - Format CIDR moderne
iface vmbr0 inet static
    address 192.168.1.10/24
```

### ✅ Bonnes pratiques

> [!tip] Conventions de nommage
> 
> - `vmbr0` : Bridge principal de gestion
> - `vmbr1, vmbr2...` : Bridges secondaires
> - `vmbr10, vmbr20` : Bridges par VLAN (avec numéro de VLAN)
> - `bond0, bond1` : Bonds d'agrégation

> [!tip] Sécurité réseau
> 
> - Désactivez les bridges inutilisés
> - Utilisez des VLANs pour isoler les environnements
> - Documentez votre configuration dans le fichier avec des commentaires
> - Ne jamais configurer plusieurs gateways par défaut

> [!tip] Performance
> 
> - Désactivez `bridge-stp` sauf besoin spécifique de redondance
> - Utilisez `bridge-fd 0` pour accélérer le démarrage
> - Pour de la performance, préférez le bond mode 802.3ad avec LACP
> - Activez le mode VLAN-aware plutôt que de créer de nombreuses interfaces

> [!tip] Maintenance
> 
> - Toujours sauvegarder `/etc/network/interfaces` avant modification
> - Testez avec `ifreload -a` avant de redémarrer
> - Documentez vos changements avec des commentaires
> - Gardez un historique des configurations qui fonctionnent

---

## 📊 Tableau récapitulatif des composants réseau

|Composant|Rôle|Quand l'utiliser|Configuration minimale|
|---|---|---|---|
|**Physical Interface**|Carte réseau physique|Toujours nécessaire|`auto eno1` + `inet manual`|
|**Linux Bridge**|Switch virtuel|Pour connecter les VMs|`bridge-ports` + IP|
|**Bond**|Agrégation de liens|Redondance ou performance|2+ interfaces + mode|
|**VLAN**|Segmentation logique|Isolation réseau|Tag VLAN + bridge|
|**VLAN-aware Bridge**|Gestion centralisée VLANs|Nombreux VLANs|`bridge-vlan-aware yes`|

---

## 🔍 Résumé des points clés

**Configuration réseau dans Proxmox :**

- Le fichier `/etc/network/interfaces` est central et critique
- Les bridges sont indispensables pour les VMs
- Le mode VLAN-aware simplifie la gestion multi-VLAN
- Le bonding améliore redondance et performance
- Toujours tester avant de redémarrer (`ifreload -a`)

**Hiérarchie réseau typique :**

1. Interface(s) physique(s) en mode `manual`
2. Bond (optionnel) pour agréger les interfaces
3. Bridge(s) connecté(s) au bond ou à l'interface
4. VLANs sur le bridge ou interfaces dédiées
5. VMs connectées aux bridges

**Commandes essentielles à retenir :**

- `ip a` : voir toutes les interfaces
- `ifreload -a` : appliquer les changements
- `brctl show` : lister les bridges
- `bridge vlan show` : voir les VLANs

> [!warning] Règle d'or Avant toute modification réseau importante, assurez-vous d'avoir un accès alternatif au serveur (console physique, IPMI, ou ILO).