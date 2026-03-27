

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

## Introduction

La configuration réseau sous Linux peut se faire de plusieurs manières selon la distribution et la version utilisée. Comprendre ces différentes méthodes est essentiel pour administrer efficacement des serveurs et postes de travail Linux.

> [!info] Pourquoi c'est important
> 
> - Les serveurs nécessitent souvent des IP statiques pour garantir leur accessibilité
> - La maîtrise du réseau est fondamentale pour le dépannage et la sécurité
> - Les méthodes de configuration ont évolué : il faut connaître l'ancien et le nouveau

---

## Configuration IP statique

### IPv4 et IPv6 : Les bases

**IPv4** utilise des adresses 32 bits notées en décimal (ex: `192.168.1.10`) **IPv6** utilise des adresses 128 bits notées en hexadécimal (ex: `2001:db8::1`)

> [!example] Éléments nécessaires pour une configuration IP
> 
> - **Adresse IP** : identifiant unique de l'interface
> - **Masque de sous-réseau** (netmask/prefix) : définit la taille du réseau
> - **Passerelle** (gateway) : permet de sortir du réseau local
> - **Serveurs DNS** : pour résoudre les noms de domaine

### Méthodes de configuration

|Méthode|Distribution|Cas d'usage|
|---|---|---|
|`/etc/network/interfaces`|Debian, Ubuntu < 17.10|Serveurs legacy, configuration simple|
|Netplan|Ubuntu ≥ 17.10, Debian récent|Serveurs modernes, configuration déclarative|
|NetworkManager|Desktop Linux, RHEL/CentOS|Postes de travail, laptops, réseaux changeants|

---

## Fichiers de configuration réseau

### /etc/network/interfaces (Debian/Ubuntu legacy)

Ce fichier est le système traditionnel de configuration réseau sous Debian et ses dérivés.

> [!warning] Attention Sur les systèmes modernes utilisant Netplan ou NetworkManager, ce fichier peut être ignoré ou provoquer des conflits.

#### Structure du fichier

```bash
# Interface de loopback (toujours présente)
auto lo
iface lo inet loopback

# Configuration IP statique IPv4
auto eth0
iface eth0 inet static
    address 192.168.1.100
    netmask 255.255.255.0
    gateway 192.168.1.1
    dns-nameservers 8.8.8.8 8.8.4.4
    dns-search example.com

# Configuration DHCP
auto eth1
iface eth1 inet dhcp

# Configuration IPv6 statique
iface eth0 inet6 static
    address 2001:db8::100
    netmask 64
    gateway 2001:db8::1
```

#### Paramètres détaillés

- **auto** : démarre l'interface automatiquement au boot
- **allow-hotplug** : démarre l'interface quand le matériel est détecté (utile pour USB)
- **iface** : définit une interface
- **inet** : protocole IPv4
- **inet6** : protocole IPv6
- **static** : configuration manuelle
- **dhcp** : configuration automatique

#### Commandes de gestion

```bash
# Redémarrer le service réseau
sudo systemctl restart networking

# Activer une interface
sudo ifup eth0

# Désactiver une interface
sudo ifdown eth0

# Recharger la configuration
sudo ifdown eth0 && sudo ifup eth0
```

> [!tip] Astuce Utilisez `allow-hotplug` au lieu de `auto` pour les interfaces qui peuvent être déconnectées (USB, WiFi) afin d'éviter de bloquer le boot.

#### Pièges courants

- Oublier `auto` ou `allow-hotplug` : l'interface ne se lèvera pas au démarrage
- Erreur de syntaxe dans le netmask : privilégier la notation CIDR (`/24` au lieu de `255.255.255.0`)
- Conflits avec NetworkManager : désactiver NetworkManager sur les serveurs

---

### Netplan (Ubuntu moderne)

Netplan est un système de configuration réseau déclaratif introduit dans Ubuntu 17.10. Il génère la configuration pour les backends (NetworkManager ou systemd-networkd).

> [!info] Philosophie de Netplan Netplan utilise des fichiers YAML simples qui sont ensuite convertis en configuration pour le backend choisi. C'est une couche d'abstraction qui simplifie la gestion.

#### Localisation des fichiers

```bash
/etc/netplan/*.yaml
```

Les fichiers sont traités par ordre alphabétique. Convention : `01-netcfg.yaml`, `50-cloud-init.yaml`, etc.

#### Configuration IPv4 statique

```yaml
network:
  version: 2
  renderer: networkd  # ou 'NetworkManager'
  ethernets:
    eth0:
      dhcp4: no
      addresses:
        - 192.168.1.100/24
      routes:
        - to: default
          via: 192.168.1.1
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
        search:
          - example.com
```

#### Configuration IPv6 statique

```yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp6: no
      addresses:
        - 2001:db8::100/64
      routes:
        - to: ::/0  # Route par défaut IPv6
          via: 2001:db8::1
      nameservers:
        addresses:
          - 2001:4860:4860::8888
          - 2001:4860:4860::8844
```

#### Configuration mixte (IPv4 + IPv6)

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: no
      dhcp6: no
      addresses:
        - 192.168.1.100/24
        - 2001:db8::100/64
      routes:
        - to: default
          via: 192.168.1.1
        - to: ::/0
          via: 2001:db8::1
      nameservers:
        addresses:
          - 8.8.8.8
          - 2001:4860:4860::8888
```

#### Configuration DHCP

```yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: yes
      dhcp6: yes
```

#### Commandes Netplan

```bash
# Tester la configuration (sans appliquer)
sudo netplan try

# Appliquer la configuration
sudo netplan apply

# Générer la configuration backend
sudo netplan generate

# Afficher la configuration actuelle
sudo netplan get

# Déboguer
sudo netplan --debug apply
```

> [!tip] Astuce : netplan try La commande `netplan try` applique temporairement la config pendant 120 secondes. Si vous ne confirmez pas, elle revient à l'ancienne. Parfait pour éviter de se couper l'accès SSH !

#### Paramètres avancés

```yaml
network:
  version: 2
  ethernets:
    eth0:
      addresses:
        - 192.168.1.100/24
      routes:
        - to: default
          via: 192.168.1.1
          metric: 100  # Priorité de la route
      nameservers:
        addresses: [8.8.8.8, 1.1.1.1]
      mtu: 9000  # Jumbo frames
      optional: true  # Ne pas attendre cette interface au boot
```

#### Pièges courants

- **Indentation YAML** : utiliser des espaces, jamais de tabulations
- **Syntaxe routes** : utiliser `to: default` et non `to: 0.0.0.0/0` (même si ça marche)
- **Permissions fichiers** : les fichiers YAML doivent être en 600 ou 644
- **Multiples fichiers** : attention à l'ordre et aux conflits entre fichiers

---

### NetworkManager

NetworkManager est le gestionnaire réseau par défaut sur la plupart des distributions desktop Linux. Il gère automatiquement les connexions WiFi, Ethernet, VPN, etc.

> [!info] Quand utiliser NetworkManager
> 
> - Postes de travail et laptops
> - Environnements où le réseau change fréquemment
> - Gestion du WiFi et des VPN
> 
> Sur les serveurs, on préfère souvent systemd-networkd pour sa légèreté.

#### Fichiers de configuration

NetworkManager stocke ses connexions dans :

```bash
/etc/NetworkManager/system-connections/
```

Chaque connexion est un fichier `.nmconnection` avec des permissions 600.

#### Exemple de fichier de connexion statique

```ini
[connection]
id=eth0-static
uuid=12345678-1234-1234-1234-123456789abc
type=ethernet
interface-name=eth0
autoconnect=true

[ethernet]
mac-address=00:11:22:33:44:55

[ipv4]
method=manual
address1=192.168.1.100/24,192.168.1.1
dns=8.8.8.8;8.8.4.4;
dns-search=example.com;

[ipv6]
method=manual
address1=2001:db8::100/64,2001:db8::1
dns=2001:4860:4860::8888;
```

#### Méthodes IPv4/IPv6

- **auto** : DHCP
- **manual** : configuration statique
- **link-local** : adresse locale uniquement (169.254.x.x)
- **shared** : partage de connexion
- **disabled** : désactivé

> [!warning] Format des adresses Dans les fichiers NetworkManager, le format est : `address1=IP/MASK,GATEWAY` Attention à la virgule entre l'adresse et la passerelle !

---

## Commandes réseau essentielles

### ip (moderne)

La commande `ip` fait partie du paquet **iproute2** et remplace les anciennes commandes `ifconfig`, `route`, `arp`. C'est l'outil moderne de gestion réseau sous Linux.

> [!info] Pourquoi préférer ip à ifconfig
> 
> - Plus riche en fonctionnalités
> - Activement maintenu
> - Gère nativement IPv6
> - Syntaxe cohérente et scriptable

#### Affichage des interfaces

```bash
# Lister toutes les interfaces
ip link show
ip link  # forme courte

# Afficher une interface spécifique
ip link show dev eth0

# Afficher uniquement les interfaces actives
ip link show up
```

#### Gestion des adresses IP

```bash
# Afficher toutes les adresses IPv4 et IPv6
ip address show
ip addr  # forme courte
ip a     # forme ultra-courte

# Afficher les adresses d'une interface
ip addr show dev eth0

# Ajouter une adresse IPv4
sudo ip addr add 192.168.1.100/24 dev eth0

# Ajouter une adresse IPv6
sudo ip addr add 2001:db8::100/64 dev eth0

# Supprimer une adresse
sudo ip addr del 192.168.1.100/24 dev eth0

# Ajouter une adresse secondaire
sudo ip addr add 192.168.1.101/24 dev eth0 label eth0:1
```

> [!tip] Plusieurs adresses sur une interface Une interface peut avoir plusieurs adresses IP. Utile pour héberger plusieurs services ou migrations.

#### Activer/Désactiver des interfaces

```bash
# Activer une interface
sudo ip link set eth0 up

# Désactiver une interface
sudo ip link set eth0 down

# Changer le MTU
sudo ip link set eth0 mtu 9000

# Changer l'adresse MAC (spoofing)
sudo ip link set eth0 address 00:11:22:33:44:55
```

#### Gestion du routage

```bash
# Afficher la table de routage
ip route show
ip route  # forme courte
ip r      # forme ultra-courte

# Afficher uniquement la route IPv6
ip -6 route show

# Ajouter une route par défaut
sudo ip route add default via 192.168.1.1

# Ajouter une route vers un réseau spécifique
sudo ip route add 10.0.0.0/8 via 192.168.1.254

# Supprimer une route
sudo ip route del 10.0.0.0/8

# Ajouter une route avec métrique (priorité)
sudo ip route add default via 192.168.1.1 metric 100

# Afficher la route vers une destination
ip route get 8.8.8.8
```

#### Affichage des statistiques

```bash
# Statistiques par interface
ip -s link show
ip -s link show dev eth0

# Statistiques détaillées
ip -s -s link show dev eth0

# Affichage avec couleurs
ip -c addr
```

#### Options utiles

```bash
# Format JSON (pratique pour scripts)
ip -j addr show

# Format avec couleurs
ip -c -br addr  # br = brief (compact)

# Afficher uniquement IPv4
ip -4 addr

# Afficher uniquement IPv6
ip -6 addr
```

> [!warning] Modifications temporaires Les modifications faites avec `ip` sont **temporaires** et disparaissent au redémarrage. Pour les rendre permanentes, modifiez les fichiers de configuration (/etc/network/interfaces, Netplan, ou NetworkManager).

---

### ifconfig (legacy)

`ifconfig` est l'ancienne commande de gestion réseau. Bien que dépréciée, elle est encore présente sur de nombreux systèmes.

> [!warning] Commande dépréciée `ifconfig` fait partie du paquet **net-tools** qui n'est plus maintenu activement. Privilégiez `ip` pour les nouveaux scripts et configurations.

#### Utilisation basique

```bash
# Afficher toutes les interfaces
ifconfig

# Afficher toutes les interfaces (même inactives)
ifconfig -a

# Afficher une interface spécifique
ifconfig eth0

# Activer une interface
sudo ifconfig eth0 up

# Désactiver une interface
sudo ifconfig eth0 down

# Configurer une adresse IP
sudo ifconfig eth0 192.168.1.100 netmask 255.255.255.0

# Configurer avec notation CIDR
sudo ifconfig eth0 192.168.1.100/24

# Ajouter une adresse secondaire (alias)
sudo ifconfig eth0:0 192.168.1.101 netmask 255.255.255.0

# Changer le MTU
sudo ifconfig eth0 mtu 9000
```

#### Comparaison ip vs ifconfig

|Tâche|ifconfig (ancien)|ip (moderne)|
|---|---|---|
|Lister interfaces|`ifconfig -a`|`ip link show`|
|Ajouter IP|`ifconfig eth0 192.168.1.10/24`|`ip addr add 192.168.1.10/24 dev eth0`|
|Activer interface|`ifconfig eth0 up`|`ip link set eth0 up`|
|Route par défaut|`route add default gw 192.168.1.1`|`ip route add default via 192.168.1.1`|
|Table de routage|`route -n`|`ip route show`|
|Cache ARP|`arp -a`|`ip neigh show`|

---

### nmcli (NetworkManager CLI)

`nmcli` est l'interface en ligne de commande de NetworkManager. C'est un outil puissant pour gérer les connexions réseau de manière scriptable.

> [!info] Avantages de nmcli
> 
> - Modifications permanentes (contrairement à `ip`)
> - Gestion complète : WiFi, VPN, Ethernet, Bridges, etc.
> - Scriptable et format de sortie personnalisable
> - Intégration avec NetworkManager (GUI et CLI cohérents)

#### Structure des commandes

```bash
nmcli [OPTIONS] OBJECT { COMMAND | help }
```

Objets principaux :

- **general** : état général de NetworkManager
- **networking** : contrôle global du réseau
- **radio** : contrôle WiFi et WWAN
- **connection** : gestion des connexions (profils)
- **device** : gestion des interfaces physiques

#### Informations générales

```bash
# État de NetworkManager
nmcli general status

# Version de NetworkManager
nmcli --version

# Afficher toutes les connexions
nmcli connection show

# Afficher les connexions actives uniquement
nmcli connection show --active

# Afficher tous les périphériques
nmcli device status

# Détails d'un périphérique
nmcli device show eth0
```

#### Créer une connexion statique IPv4

```bash
# Créer une connexion Ethernet statique
sudo nmcli connection add \
    type ethernet \
    con-name eth0-static \
    ifname eth0 \
    ipv4.method manual \
    ipv4.addresses 192.168.1.100/24 \
    ipv4.gateway 192.168.1.1 \
    ipv4.dns "8.8.8.8 8.8.4.4"

# Activer la connexion
sudo nmcli connection up eth0-static
```

#### Créer une connexion statique IPv6

```bash
sudo nmcli connection add \
    type ethernet \
    con-name eth0-ipv6 \
    ifname eth0 \
    ipv6.method manual \
    ipv6.addresses 2001:db8::100/64 \
    ipv6.gateway 2001:db8::1 \
    ipv6.dns "2001:4860:4860::8888"
```

#### Modifier une connexion existante

```bash
# Changer l'adresse IP
sudo nmcli connection modify eth0-static \
    ipv4.addresses 192.168.1.150/24

# Ajouter une adresse IP secondaire
sudo nmcli connection modify eth0-static \
    +ipv4.addresses 192.168.1.151/24

# Changer la passerelle
sudo nmcli connection modify eth0-static \
    ipv4.gateway 192.168.1.254

# Ajouter un serveur DNS
sudo nmcli connection modify eth0-static \
    +ipv4.dns 1.1.1.1

# Changer le MTU
sudo nmcli connection modify eth0-static \
    802-3-ethernet.mtu 9000

# Appliquer les modifications
sudo nmcli connection up eth0-static
```

#### Créer une connexion DHCP

```bash
sudo nmcli connection add \
    type ethernet \
    con-name eth0-dhcp \
    ifname eth0 \
    ipv4.method auto
```

#### Gestion des connexions

```bash
# Activer une connexion
sudo nmcli connection up eth0-static

# Désactiver une connexion
sudo nmcli connection down eth0-static

# Recharger une connexion
sudo nmcli connection reload eth0-static

# Supprimer une connexion
sudo nmcli connection delete eth0-static

# Cloner une connexion
sudo nmcli connection clone eth0-static eth0-backup
```

#### Gestion des périphériques

```bash
# Déconnecter un périphérique
sudo nmcli device disconnect eth0

# Reconnecter un périphérique (connexion auto)
sudo nmcli device connect eth0

# Recharger la configuration d'un périphérique
sudo nmcli device reapply eth0
```

#### Options d'affichage

```bash
# Affichage compact
nmcli -t connection show

# Format personnalisé (pratique pour scripts)
nmcli -t -f NAME,TYPE,DEVICE connection show

# Avec couleurs
nmcli -p connection show

# Mode interactif pour créer une connexion
sudo nmcli connection edit type ethernet con-name eth0-new
```

#### Exemples avancés

```bash
# Connexion avec route statique supplémentaire
sudo nmcli connection add \
    type ethernet \
    con-name eth0-routes \
    ifname eth0 \
    ipv4.method manual \
    ipv4.addresses 192.168.1.100/24 \
    ipv4.gateway 192.168.1.1 \
    ipv4.routes "10.0.0.0/8 192.168.1.254"

# Connexion qui démarre automatiquement
sudo nmcli connection modify eth0-static \
    connection.autoconnect yes

# Connexion qui attend le réseau au boot
sudo nmcli connection modify eth0-static \
    connection.wait-device-timeout 30
```

> [!tip] Format de sortie pour scripts Utilisez `nmcli -t -f FIELD1,FIELD2 ...` pour un format facilement parsable :
> 
> ```bash
> nmcli -t -f NAME,STATE connection show
> ```

#### Pièges courants

- **Oublier `connection up`** : les modifications avec `modify` ne sont pas appliquées tant qu'on ne fait pas `up`
- **Conflit de connexions** : plusieurs connexions peuvent cibler la même interface, la dernière activée gagne
- **ipv4.method vs ipv4.addresses** : si `method` est `auto`, les `addresses` sont ignorées

---

## Configuration du routage statique

Le routage statique permet de définir manuellement comment les paquets doivent être acheminés vers différents réseaux.

> [!info] Quand utiliser le routage statique
> 
> - Réseaux simples et prévisibles
> - Routes vers des réseaux internes spécifiques
> - Environnements où le routage dynamique n'est pas nécessaire
> - Priorité sur certaines routes (multi-WAN)

### Concepts de base

**Table de routage** : liste des routes connues par le système **Route par défaut** : passerelle utilisée quand aucune route spécifique n'existe **Métrique** : priorité d'une route (plus petit = prioritaire) **Route statique** : route configurée manuellement (vs route dynamique apprise via protocoles)

### Afficher la table de routage

```bash
# Avec ip
ip route show
ip -6 route show  # IPv6

# Avec route (legacy)
route -n

# Avec netstat (legacy)
netstat -rn
```

### Ajouter des routes temporaires

#### Avec ip

```bash
# Route par défaut
sudo ip route add default via 192.168.1.1

# Route vers un réseau spécifique
sudo ip route add 10.0.0.0/8 via 192.168.1.254

# Route via une interface (sans passerelle)
sudo ip route add 192.168.2.0/24 dev eth1

# Route avec métrique
sudo ip route add 10.20.0.0/16 via 192.168.1.253 metric 50

# Route IPv6
sudo ip -6 route add 2001:db8:1::/64 via 2001:db8::1

# Supprimer une route
sudo ip route del 10.0.0.0/8
```

#### Avec route (legacy)

```bash
# Route par défaut
sudo route add default gw 192.168.1.1

# Route vers un réseau
sudo route add -net 10.0.0.0/8 gw 192.168.1.254

# Supprimer une route
sudo route del -net 10.0.0.0/8
```

### Routes permanentes

#### Avec /etc/network/interfaces

```bash
auto eth0
iface eth0 inet static
    address 192.168.1.100
    netmask 255.255.255.0
    gateway 192.168.1.1
    # Routes statiques
    up ip route add 10.0.0.0/8 via 192.168.1.254
    up ip route add 172.16.0.0/12 via 192.168.1.253
    down ip route del 10.0.0.0/8
    down ip route del 172.16.0.0/12
```

#### Avec Netplan

```yaml
network:
  version: 2
  ethernets:
    eth0:
      addresses:
        - 192.168.1.100/24
      routes:
        - to: default
          via: 192.168.1.1
        - to: 10.0.0.0/8
          via: 192.168.1.254
          metric: 100
        - to: 172.16.0.0/12
          via: 192.168.1.253
          metric: 200
```

#### Avec NetworkManager (nmcli)

```bash
# Ajouter une route statique
sudo nmcli connection modify eth0-static \
    +ipv4.routes "10.0.0.0/8 192.168.1.254 100"

# Plusieurs routes
sudo nmcli connection modify eth0-static \
    ipv4.routes "10.0.0.0/8 192.168.1.254 100, 172.16.0.0/12 192.168.1.253 200"

# Appliquer
sudo nmcli connection up eth0-static
```

### Routes persistantes avec fichiers dédiés

#### Debian/Ubuntu (interfaces)

Créer `/etc/network/if-up.d/static-routes` :

```bash
#!/bin/sh
ip route add 10.0.0.0/8 via 192.168.1.254
ip route add 172.16.0.0/12 via 192.168.1.253
```

Rendre exécutable :

```bash
sudo chmod +x /etc/network/if-up.d/static-routes
```

#### RHEL/CentOS

Créer `/etc/sysconfig/network-scripts/route-eth0` :

```
10.0.0.0/8 via 192.168.1.254
172.16.0.0/12 via 192.168.1.253
```

### Routage multi-WAN (route par défaut multiple)

```bash
# Ajouter plusieurs routes par défaut avec des métriques
sudo ip route add default via 192.168.1.1 metric 100
sudo ip route add default via 192.168.2.1 metric 200

# Vérifier
ip route show default
```

> [!tip] Métriques et priorité La route avec la **métrique la plus basse** est prioritaire. Si la première tombe, la seconde prend le relais automatiquement.

### Routage basé sur les règles (Policy-based routing)

```bash
# Créer une table de routage personnalisée
echo "200 custom_table" | sudo tee -a /etc/iproute2/rt_tables

# Ajouter une route dans cette table
sudo ip route add default via 192.168.2.1 table custom_table

# Créer une règle : le trafic depuis 10.0.0.0/8 utilise custom_table
sudo ip rule add from 10.0.0.0/8 table custom_table

# Lister les règles
ip rule show

# Lister les routes d'une table spécifique
ip route show table custom_table
```

### Vérification et diagnostic

```bash
# Tester la route vers une destination
ip route get 8.8.8.8
ip route get 2001:4860:4860::8888  # IPv6

# Tracer le chemin réseau
traceroute 8.8.8.8
traceroute6 2001:4860:4860::8888

# Ou avec mtr (better traceroute)
mtr 8.8.8.8
```

> [!warning] Routes conflictuelles Si deux routes couvrent le même réseau, la plus spécifique (masque le plus long) est prioritaire. En cas d'égalité, c'est la métrique qui décide.

### Exemple complet : réseau d'entreprise

```yaml
# Netplan : /etc/netplan/01-config.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    # Interface LAN
    eth0:
      addresses:
        - 192.168.10.50/24
      routes:
        - to: default
          via: 192.168.10.1
          metric: 100
        # Réseau de production
        - to: 10.0.0.0/8
          via: 192.168.10.254
        # Réseau de développement
        - to: 172.16.0.0/12
          via: 192.168.10.253
        # Réseau distant via VPN
        - to: 192.168.100.0/24
          via: 192.168.10.252
      nameservers:
        addresses:
          - 192.168.10.10
          - 192.168.10.11
        search:
          - corp.example.com
    
    # Interface WAN secondaire (backup)
    eth1:
      addresses:
        - 203.0.113.50/29
      routes:
        - to: default
          via: 203.0.113.49
          metric: 200  # Métrique plus élevée = backup
```

---

## Bonnes pratiques

### 🔒 Sécurité

- **Toujours tester avant de déployer** : utilisez `netplan try` ou testez sur une VM
- **Documenter les configurations** : commentez vos fichiers YAML et configs
- **Sauvegarder avant modification** : `cp /etc/netplan/01-config.yaml /etc/netplan/01-config.yaml.bak`
- **Permissions strictes** : fichiers de config en 600 pour NetworkManager, 644 pour Netplan
- **Éviter les conflits** : désactiver NetworkManager sur les serveurs si vous utilisez systemd-networkd

### 🎯 Choix de la méthode de configuration

**Utilisez /etc/network/interfaces si :**

- Vous êtes sur un ancien système Debian/Ubuntu
- Vous avez besoin de compatibilité avec des scripts legacy
- Vous gérez un système très simple

**Utilisez Netplan si :**

- Vous êtes sur Ubuntu ≥ 17.10 ou Debian récent
- Vous voulez une configuration déclarative et lisible
- Vous gérez des serveurs modernes
- Vous avez besoin de flexibilité (plusieurs backends possibles)

**Utilisez NetworkManager si :**

- Vous êtes sur un poste de travail
- Vous gérez du WiFi, des VPN, ou des réseaux changeants
- Vous avez besoin d'une interface graphique
- La mobilité est importante (laptop)

### 📝 Organisation des configurations

```bash
# Nommage cohérent des fichiers Netplan
/etc/netplan/
├── 01-network-manager-all.yaml  # Config NetworkManager (desktop)
├── 50-cloud-init.yaml           # Config cloud (si applicable)
└── 99-local-config.yaml         # Vos configs locales

# Nommage cohérent des connexions NetworkManager
eth0-static          # Pour configurations statiques
eth0-dhcp            # Pour DHCP
wlan0-home          # Par emplacement/usage
vpn-company         # Par fonction
```

### 🔧 Dépannage réseau

```bash
# Vérifier l'état de l'interface
ip link show eth0
ip addr show eth0

# Vérifier la connectivité de base
ping -c 4 192.168.1.1        # Passerelle
ping -c 4 8.8.8.8            # Internet (IP)
ping -c 4 google.com         # Internet (DNS)

# Vérifier les routes
ip route show
ip route get 8.8.8.8

# Vérifier les serveurs DNS
cat /etc/resolv.conf
resolvectl status            # systemd-resolved

# Vérifier l'état des services
systemctl status networking          # /etc/network/interfaces
systemctl status systemd-networkd    # Netplan (backend networkd)
systemctl status NetworkManager      # NetworkManager

# Logs de démarrage réseau
journalctl -u networking
journalctl -u systemd-networkd
journalctl -u NetworkManager

# Écouter les événements réseau en temps réel
ip monitor
```

### ⚡ Performance et optimisation

```bash
# MTU adapté au réseau
# 1500 : standard Ethernet
# 9000 : Jumbo frames (réseaux locaux haute perf)
sudo ip link set eth0 mtu 9000

# Désactiver IPv6 si non utilisé (gain de temps au boot)
# Dans /etc/sysctl.conf
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1

# Appliquer
sudo sysctl -p
```

### 🚨 Pièges courants à éviter

> [!warning] Erreurs fréquentes
> 
> - **Oublier de redémarrer le service** après modification des fichiers
> - **Conflits entre méthodes** : Netplan ET NetworkManager ET interfaces actifs
> - **Erreurs de syntaxe YAML** : tabulations au lieu d'espaces, indentation incorrecte
> - **Se couper l'accès SSH** : toujours utiliser `netplan try` ou avoir un accès console
> - **Routes en double** : vérifier avec `ip route show` avant d'ajouter
> - **Mauvaise passerelle** : vérifier que la gateway est dans le même sous-réseau
> - **DNS non configurés** : vérifier `/etc/resolv.conf` après configuration

### 📊 Tableau récapitulatif des commandes

|Action|ip (moderne)|ifconfig (legacy)|nmcli|
|---|---|---|---|
|Lister interfaces|`ip link show`|`ifconfig -a`|`nmcli device status`|
|Afficher IPs|`ip addr show`|`ifconfig`|`nmcli connection show`|
|Ajouter IP|`ip addr add IP/MASK dev IF`|`ifconfig IF IP netmask MASK`|`nmcli con add ... ipv4.addresses IP/MASK`|
|Activer interface|`ip link set IF up`|`ifconfig IF up`|`nmcli con up NAME`|
|Route par défaut|`ip route add default via GW`|`route add default gw GW`|`nmcli con mod NAME ipv4.gateway GW`|
|Afficher routes|`ip route show`|`route -n`|`nmcli con show NAME`|
|Statistiques|`ip -s link show`|`ifconfig`|`nmcli device show`|

### 🔄 Scripts utiles

#### Script de sauvegarde de configuration

```bash
#!/bin/bash
# backup-network-config.sh

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/root/network-backups"

mkdir -p "$BACKUP_DIR"

# Sauvegarder selon le système utilisé
if [ -d /etc/netplan ]; then
    tar -czf "$BACKUP_DIR/netplan_$DATE.tar.gz" /etc/netplan/
fi

if [ -f /etc/network/interfaces ]; then
    cp /etc/network/interfaces "$BACKUP_DIR/interfaces_$DATE"
fi

if [ -d /etc/NetworkManager/system-connections ]; then
    tar -czf "$BACKUP_DIR/nm_connections_$DATE.tar.gz" /etc/NetworkManager/system-connections/
fi

# Sauvegarder la config actuelle
ip addr > "$BACKUP_DIR/ip_addr_$DATE.txt"
ip route > "$BACKUP_DIR/ip_route_$DATE.txt"

echo "Sauvegarde créée dans $BACKUP_DIR"
```

#### Script de test de connectivité

```bash
#!/bin/bash
# test-connectivity.sh

echo "=== Test de connectivité réseau ==="
echo

# Interface
echo "1. Interface réseau :"
ip -br addr show
echo

# Passerelle
GATEWAY=$(ip route | grep default | awk '{print $3}' | head -n1)
echo "2. Passerelle : $GATEWAY"
if ping -c 2 -W 2 "$GATEWAY" &> /dev/null; then
    echo "   ✓ Passerelle accessible"
else
    echo "   ✗ Passerelle inaccessible"
fi
echo

# Internet (IP)
echo "3. Connectivité Internet (IP) :"
if ping -c 2 -W 2 8.8.8.8 &> /dev/null; then
    echo "   ✓ Internet accessible"
else
    echo "   ✗ Pas d'accès Internet"
fi
echo

# DNS
echo "4. Résolution DNS :"
if ping -c 2 -W 2 google.com &> /dev/null; then
    echo "   ✓ DNS fonctionnel"
else
    echo "   ✗ Problème de DNS"
    echo "   Serveurs DNS configurés :"
    grep nameserver /etc/resolv.conf
fi
echo

# Routes
echo "5. Table de routage :"
ip route show
```

### 📋 Checklist de configuration

Avant de mettre en production une configuration réseau :

- [ ] Configuration testée sur environnement de test
- [ ] Sauvegarde de la configuration actuelle effectuée
- [ ] Accès console ou IPMI disponible (en cas de problème)
- [ ] Documentation à jour (IP, passerelle, DNS, routes)
- [ ] Tests de connectivité validés (ping gateway, ping internet, DNS)
- [ ] Configuration persistante vérifiée (survit au reboot)
- [ ] Logs vérifiés pour erreurs éventuelles
- [ ] Équipe/collègues informés du changement
- [ ] Plan de rollback préparé

### 💡 Astuces avancées

#### Alias réseau persistants

```bash
# Dans .bashrc ou .bash_aliases
alias myip='ip -br -c addr show'
alias myroute='ip -br -c route show'
alias netstat='ss -tulpn'  # ss remplace netstat
alias listening='ss -tulpn | grep LISTEN'
```

#### Vérification rapide de config

```bash
# Voir toute la config réseau d'un coup
ip -c addr && echo "---" && ip -c route && echo "---" && cat /etc/resolv.conf
```

#### Monitoring en temps réel

```bash
# Surveiller les changements réseau
watch -n 1 'ip -br addr show; echo; ip route show'

# Surveiller la bande passante
iftop -i eth0
nethogs eth0  # Par processus
```

---

## 🎓 Résumé

La configuration réseau sous Linux a évolué au fil du temps, offrant plusieurs méthodes selon les besoins :

1. **Pour les serveurs modernes** : privilégiez **Netplan** avec sa syntaxe YAML claire
2. **Pour les desktops** : **NetworkManager** offre flexibilité et facilité d'utilisation
3. **Pour les systèmes legacy** : `/etc/network/interfaces` reste fonctionnel

Les outils modernes (`ip`, `nmcli`) remplacent avantageusement les anciens (`ifconfig`, `route`) avec plus de fonctionnalités et une meilleure maintenance.

**Points clés à retenir :**

- Toujours sauvegarder avant modification
- Tester avec `netplan try` ou en environnement non-prod
- Comprendre la différence entre configuration temporaire (`ip`) et permanente (fichiers)
- Documenter vos configurations
- Vérifier la persistance après reboot

> [!tip] Conseil final La maîtrise du réseau sous Linux s'acquiert par la pratique. N'hésitez pas à tester dans des VMs, à casser et réparer. C'est en expérimentant qu'on comprend vraiment les subtilités du networking Linux.