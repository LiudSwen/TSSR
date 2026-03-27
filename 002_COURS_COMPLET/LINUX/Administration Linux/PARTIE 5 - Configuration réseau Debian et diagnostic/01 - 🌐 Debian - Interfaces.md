

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

## Introduction

La configuration réseau sous Debian utilise traditionnellement le fichier `/etc/network/interfaces` pour définir les paramètres des interfaces réseau. Cette méthode, bien que considérée comme "classique", reste largement utilisée sur les serveurs Debian et dans de nombreux environnements de production.

> [!info] Contexte historique Cette méthode de configuration existe depuis les débuts de Debian et offre une approche simple, fiable et scriptable. Elle fait partie du paquet `ifupdown` qui est installé par défaut sur Debian.

> [!warning] Alternatives modernes D'autres systèmes existent (NetworkManager, systemd-networkd, netplan), mais ce cours se concentre sur la méthode traditionnelle `/etc/network/interfaces` qui reste pertinente, notamment pour les serveurs.

---

## Le fichier /etc/network/interfaces

### 📍 Emplacement et rôle

Le fichier `/etc/network/interfaces` est le fichier de configuration central pour la gestion réseau sous Debian avec ifupdown.

**Caractéristiques :**

- Chemin complet : `/etc/network/interfaces`
- Permissions typiques : `644` (rw-r--r--)
- Propriétaire : `root:root`
- Format : texte brut, une directive par ligne

### 📐 Structure générale

```bash
# Interface de bouclage (loopback)
auto lo
iface lo inet loopback

# Interface Ethernet principale
auto eth0
iface eth0 inet static
    address 192.168.1.100
    netmask 255.255.255.0
    gateway 192.168.1.1
```

### 🔑 Directives principales

|Directive|Description|Exemple|
|---|---|---|
|`auto`|Interface démarrée automatiquement au boot|`auto eth0`|
|`allow-hotplug`|Interface démarrée à la détection du matériel|`allow-hotplug wlan0`|
|`iface`|Définit une configuration d'interface|`iface eth0 inet static`|
|`source`|Inclut d'autres fichiers de configuration|`source /etc/network/interfaces.d/*`|

> [!tip] Organisation modulaire Utilisez la directive `source /etc/network/interfaces.d/*` pour diviser vos configurations en plusieurs fichiers. Cela facilite la maintenance et l'organisation.

### 📊 Différence entre auto et allow-hotplug

```bash
# auto : démarre l'interface au boot du système
auto eth0

# allow-hotplug : démarre l'interface quand le matériel est détecté
# Utile pour les périphériques amovibles (USB, PCMCIA, etc.)
allow-hotplug wlan0
```

**Quand utiliser quoi ?**

- `auto` : interfaces fixes (cartes réseau intégrées, serveurs)
- `allow-hotplug` : interfaces amovibles ou qui peuvent ne pas être présentes au boot

---

## Configuration IP statique

### 🎯 Pourquoi une IP statique ?

Une adresse IP statique est essentielle pour :

- Les serveurs (web, base de données, DNS, etc.)
- Les équipements réseau (routeurs, switchs managés)
- Les machines nécessitant une adresse prévisible
- Les configurations avec règles firewall basées sur l'IP

### 📝 Syntaxe complète

```bash
# Interface avec IPv4 statique
auto eth0
iface eth0 inet static
    # Adresse IP de la machine
    address 192.168.1.100
    
    # Masque de sous-réseau (notation décimale)
    netmask 255.255.255.0
    
    # Passerelle par défaut (routeur)
    gateway 192.168.1.1
    
    # Serveurs DNS (facultatif, peut être dans /etc/resolv.conf)
    dns-nameservers 8.8.8.8 8.8.4.4
    
    # Domaine de recherche DNS (facultatif)
    dns-search exemple.local
    
    # Adresse réseau (optionnel, calculé automatiquement)
    network 192.168.1.0
    
    # Adresse de broadcast (optionnel, calculé automatiquement)
    broadcast 192.168.1.255
```

> [!example] Configuration minimale fonctionnelle
> 
> ```bash
> auto eth0
> iface eth0 inet static
>     address 192.168.1.100
>     netmask 255.255.255.0
>     gateway 192.168.1.1
> ```
> 
> C'est suffisant pour la plupart des cas d'usage basiques.

### 🔢 Notation CIDR (alternative moderne)

Depuis Debian 9 (Stretch), vous pouvez utiliser la notation CIDR :

```bash
auto eth0
iface eth0 inet static
    # Notation CIDR : adresse/préfixe
    address 192.168.1.100/24
    gateway 192.168.1.1
    dns-nameservers 8.8.8.8 8.8.4.4
```

> [!tip] Notation CIDR recommandée La notation CIDR (`192.168.1.100/24`) est plus concise et moderne. Elle remplace la combinaison `address` + `netmask`.

### 🌐 Configuration multi-IP (aliases)

Pour assigner plusieurs adresses IP à une même interface :

```bash
# IP principale
auto eth0
iface eth0 inet static
    address 192.168.1.100/24
    gateway 192.168.1.1

# IP secondaire (alias)
auto eth0:0
iface eth0:0 inet static
    address 192.168.1.101/24

# IP tertiaire (alias)
auto eth0:1
iface eth0:1 inet static
    address 192.168.1.102/24
```

> [!warning] Limitation des aliases
> 
> - Une seule passerelle (gateway) par interface physique
> - Les aliases partagent les paramètres physiques de l'interface principale
> - La syntaxe avec `:` est historique, la méthode moderne utilise `iface eth0 inet static` plusieurs fois

### 📡 Configuration avec routes statiques

```bash
auto eth0
iface eth0 inet static
    address 192.168.1.100/24
    gateway 192.168.1.1
    
    # Routes statiques supplémentaires
    up ip route add 10.0.0.0/8 via 192.168.1.254
    up ip route add 172.16.0.0/12 via 192.168.1.253
    
    # Supprimer les routes au désactivation
    down ip route del 10.0.0.0/8 via 192.168.1.254
    down ip route del 172.16.0.0/12 via 192.168.1.253
```

> [!info] Directives up/down
> 
> - `up` : commandes exécutées après l'activation de l'interface
> - `down` : commandes exécutées avant la désactivation de l'interface
> - `pre-up` : avant l'activation
> - `post-down` : après la désactivation

---

## Configuration DHCP

### 🎯 Pourquoi le DHCP ?

Le DHCP (Dynamic Host Configuration Protocol) est approprié pour :

- Les postes de travail clients
- Les machines dont l'IP peut changer
- Les environnements où la gestion centralisée est préférée
- Les configurations temporaires ou de test

### 📝 Syntaxe de base

```bash
# Configuration DHCP simple
auto eth0
iface eth0 inet dhcp
```

> [!tip] Simplicité du DHCP Trois lignes suffisent ! Le serveur DHCP fournit automatiquement : IP, masque, passerelle, DNS, et autres paramètres.

### ⚙️ Configuration DHCP avec options

```bash
auto eth0
iface eth0 inet dhcp
    # Nom d'hôte envoyé au serveur DHCP
    hostname monserveur
    
    # Durée du bail DHCP demandée (en secondes)
    leasetime 86400
    
    # Client DHCP à utiliser (dhclient par défaut)
    dhcp-client dhclient
    
    # Options spécifiques au client
    request subnet-mask, broadcast-address, routers, domain-name-servers
```

### 🔒 DHCP avec IP de secours (fallback)

```bash
auto eth0
iface eth0 inet dhcp
    # Configuration de secours si DHCP échoue
    post-up [ -z "$(ip addr show eth0 | grep 'inet ')" ] && ip addr add 192.168.1.100/24 dev eth0 || true
```

### 🛡️ DHCP avec restrictions

```bash
auto eth0
iface eth0 inet dhcp
    # Accepter uniquement certains serveurs DHCP
    # (nécessite configuration supplémentaire dans /etc/dhcp/dhclient.conf)
    
    # Refuser certaines options DHCP
    reject routers
```

> [!warning] Configuration hybride rare Accepter l'IP via DHCP mais refuser la passerelle est une configuration peu courante. Assurez-vous de bien comprendre votre besoin avant de l'utiliser.

---

## Commandes ifup/ifdown

### 🔧 Rôle et fonctionnement

Les commandes `ifup` et `ifdown` sont les outils de gestion des interfaces réseau définis dans `/etc/network/interfaces`.

**Principes :**

- Elles lisent la configuration depuis `/etc/network/interfaces`
- Elles activent/désactivent les interfaces selon la configuration définie
- Elles exécutent les scripts associés (up, down, pre-up, post-down)

### 📘 Syntaxe ifup

```bash
# Activer une interface
ifup eth0

# Activer plusieurs interfaces
ifup eth0 eth1

# Activer toutes les interfaces marquées "auto"
ifup -a

# Mode verbeux (affiche les détails)
ifup -v eth0

# Forcer l'activation même si déjà active
ifup --force eth0

# Tester sans réellement activer
ifup -n eth0
```

> [!example] Activation simple
> 
> ```bash
> sudo ifup eth0
> ```
> 
> Active l'interface eth0 selon la configuration dans `/etc/network/interfaces`.

### 📕 Syntaxe ifdown

```bash
# Désactiver une interface
ifdown eth0

# Désactiver plusieurs interfaces
ifdown eth0 eth1

# Désactiver toutes les interfaces (sauf lo)
ifdown -a

# Mode verbeux
ifdown -v eth0

# Forcer la désactivation
ifdown --force eth0
```

> [!warning] Attention avec ifdown -a La commande `ifdown -a` désactive TOUTES les interfaces (sauf loopback). Sur un serveur distant, cela vous coupera l'accès SSH !

### 🔄 Redémarrage d'une interface

```bash
# Méthode classique : down puis up
sudo ifdown eth0 && sudo ifup eth0

# Alternative en une commande (si disponible)
sudo ifdown eth0 ; sudo ifup eth0
```

> [!tip] Double astuce L'opérateur `&&` n'exécute la seconde commande que si la première réussit. Avec `;`, les deux commandes s'exécutent quoi qu'il arrive.

### 📊 Vérification de l'état

```bash
# Lister les interfaces configurées
ifquery --list

# Afficher la configuration d'une interface
ifquery eth0

# Vérifier l'état actuel
ifquery --state eth0

# Vérifier si une interface peut être activée
ifup -n eth0
```

### ⚡ Cas d'usage courants

**Appliquer une nouvelle configuration :**

```bash
# Éditer la configuration
sudo nano /etc/network/interfaces

# Redémarrer l'interface
sudo ifdown eth0 && sudo ifup eth0
```

**Diagnostic réseau :**

```bash
# Vérifier la configuration avant activation
sudo ifup -nv eth0

# Activer en mode verbeux pour voir les erreurs
sudo ifup -v eth0
```

**Désactivation temporaire :**

```bash
# Désactiver l'interface
sudo ifdown eth0

# Réactiver plus tard
sudo ifup eth0
```

---

## Service networking

### 🎯 Rôle du service

Le service `networking` est le service systemd qui gère l'activation des interfaces réseau au démarrage du système selon la configuration `/etc/network/interfaces`.

**Responsabilités :**

- Démarre automatiquement les interfaces marquées `auto` au boot
- Gère l'ordre de démarrage des interfaces
- Intègre la configuration réseau avec systemd

### 🔧 Commandes de gestion

```bash
# Démarrer le service (active toutes les interfaces "auto")
sudo systemctl start networking

# Arrêter le service (désactive les interfaces)
sudo systemctl stop networking

# Redémarrer le service (redémarre toutes les interfaces)
sudo systemctl restart networking

# Recharger la configuration sans redémarrer
sudo systemctl reload networking

# Vérifier l'état du service
sudo systemctl status networking

# Activer le démarrage automatique au boot
sudo systemctl enable networking

# Désactiver le démarrage automatique
sudo systemctl disable networking
```

> [!info] Service par défaut Le service `networking` est activé par défaut sur Debian. Il démarre automatiquement au boot système.

### 📊 Vérification de l'état

```bash
# État détaillé du service
sudo systemctl status networking
```

**Sortie typique :**

```
● networking.service - Raise network interfaces
     Loaded: loaded (/lib/systemd/system/networking.service; enabled)
     Active: active (exited) since Mon 2024-01-15 10:30:22 CET; 2h ago
       Docs: man:interfaces(5)
    Process: 432 ExecStart=/sbin/ifup -a --read-environment (code=exited, status=0/SUCCESS)
   Main PID: 432 (code=exited, status=0/SUCCESS)
```

### 🔄 Restart vs Reload

```bash
# restart : arrête PUIS redémarre toutes les interfaces
sudo systemctl restart networking
# ⚠️ Coupe temporairement la connexion réseau !

# reload : recharge la config sans couper les connexions
sudo systemctl reload networking
# ✅ Méthode préférée si disponible
```

> [!warning] Attention au restart sur serveur distant `systemctl restart networking` coupera temporairement TOUTES vos connexions réseau. Sur un serveur distant (SSH), préférez `ifdown/ifup` interface par interface.

### 🛠️ Fichier de service systemd

**Emplacement :** `/lib/systemd/system/networking.service`

```ini
[Unit]
Description=Raise network interfaces
Documentation=man:interfaces(5)
DefaultDependencies=no
Wants=network.target
Before=network.target

[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/sbin/ifup -a --read-environment
ExecStop=/sbin/ifdown -a --read-environment

[Install]
WantedBy=multi-user.target
```

> [!info] Type oneshot Le service est de type `oneshot`, ce qui signifie qu'il exécute simplement `ifup -a` au démarrage puis se termine. L'option `RemainAfterExit=yes` le maintient dans l'état "active" même après la fin du processus.

### 📈 Logs et diagnostic

```bash
# Voir les logs du service networking
sudo journalctl -u networking

# Logs en temps réel
sudo journalctl -u networking -f

# Logs depuis le dernier boot
sudo journalctl -u networking -b

# Logs des 100 dernières lignes
sudo journalctl -u networking -n 100
```

### ⚙️ Alternatives de redémarrage réseau

```bash
# Méthode 1 : Service networking (redémarre TOUT)
sudo systemctl restart networking

# Méthode 2 : Interface par interface (recommandé à distance)
sudo ifdown eth0 && sudo ifup eth0

# Méthode 3 : Script de compatibilité
sudo /etc/init.d/networking restart

# Méthode 4 : Forcer ifup sur toutes les interfaces
sudo ifdown -a && sudo ifup -a
```

> [!tip] Méthode recommandée à distance Pour un serveur distant accessible uniquement par SSH, la méthode la plus sûre est :
> 
> ```bash
> sudo ifdown eth0 && sudo ifup eth0
> ```
> 
> Cela ne redémarre que l'interface concernée. En cas d'erreur dans la config, la connexion reste active le temps de corriger.

---

## Pièges courants et bonnes pratiques

### ⚠️ Pièges fréquents

#### 1. Redémarrage réseau à distance

```bash
# ❌ DANGER sur serveur distant
sudo systemctl restart networking
# Coupe TOUTES les connexions, risque de perdre l'accès !

# ✅ PRÉFÉRER
sudo ifdown eth0 && sudo ifup eth0
# Ne redémarre qu'une interface à la fois
```

#### 2. Erreurs de syntaxe

```bash
# ❌ INCORRECT : indentation manquante
auto eth0
iface eth0 inet static
address 192.168.1.100

# ✅ CORRECT : paramètres indentés
auto eth0
iface eth0 inet static
    address 192.168.1.100
    netmask 255.255.255.0
```

#### 3. Conflits auto vs allow-hotplug

```bash
# ❌ ÉVITER : utiliser les deux simultanément
auto eth0
allow-hotplug eth0
iface eth0 inet dhcp

# ✅ CHOISIR un seul mode
auto eth0
iface eth0 inet dhcp
```

#### 4. Oubli de la loopback

```bash
# ❌ NE JAMAIS supprimer ou oublier
auto lo
iface lo inet loopback
# L'interface lo est OBLIGATOIRE pour le système !
```

> [!warning] Interface loopback critique L'interface `lo` (loopback) est essentielle au fonctionnement du système. De nombreux services en dépendent. Ne la supprimez JAMAIS de la configuration.

#### 5. Gateway multiple

```bash
# ❌ INCORRECT : plusieurs gateways sur interfaces différentes
auto eth0
iface eth0 inet static
    address 192.168.1.100/24
    gateway 192.168.1.1

auto eth1
iface eth1 inet static
    address 10.0.0.100/24
    gateway 10.0.0.1  # Conflit !

# ✅ CORRECT : une seule gateway par défaut
auto eth0
iface eth0 inet static
    address 192.168.1.100/24
    gateway 192.168.1.1

auto eth1
iface eth1 inet static
    address 10.0.0.100/24
    # Pas de gateway, ou utiliser des routes statiques
```

### ✅ Bonnes pratiques

#### 1. Sauvegarde avant modification

```bash
# Toujours sauvegarder avant de modifier
sudo cp /etc/network/interfaces /etc/network/interfaces.backup.$(date +%Y%m%d)

# Ou avec horodatage complet
sudo cp /etc/network/interfaces /etc/network/interfaces.bak-$(date +%Y%m%d-%H%M%S)
```

#### 2. Validation de la syntaxe

```bash
# Vérifier la configuration sans l'appliquer
sudo ifup -n -v eth0

# Tester la configuration avant de redémarrer
sudo ifquery --state eth0
```

#### 3. Organisation modulaire

```bash
# Dans /etc/network/interfaces
source /etc/network/interfaces.d/*

# Créer un fichier par interface
# /etc/network/interfaces.d/eth0
auto eth0
iface eth0 inet static
    address 192.168.1.100/24
    gateway 192.168.1.1

# /etc/network/interfaces.d/eth1
auto eth1
iface eth1 inet static
    address 10.0.0.100/24
```

#### 4. Documentation inline

```bash
# Documenter vos configurations
auto eth0
# Interface WAN - Production
# Contact: admin@exemple.com
# Mis à jour: 2024-01-15
iface eth0 inet static
    address 203.0.113.10/24
    gateway 203.0.113.1
    dns-nameservers 8.8.8.8 8.8.4.4
```

#### 5. Gestion des DNS

```bash
# Méthode recommandée : dans interfaces
auto eth0
iface eth0 inet static
    address 192.168.1.100/24
    gateway 192.168.1.1
    dns-nameservers 8.8.8.8 8.8.4.4
    dns-search exemple.local

# Alternative : fichier séparé /etc/resolv.conf
# Mais risque d'écrasement par le système
```

> [!tip] DNS dans interfaces Définir les DNS directement dans `/etc/network/interfaces` évite qu'ils soient écrasés par d'autres services (comme resolvconf ou NetworkManager s'ils sont installés).

#### 6. Scripts de sécurité

```bash
auto eth0
iface eth0 inet static
    address 192.168.1.100/24
    gateway 192.168.1.1
    
    # Appliquer des règles de sécurité au démarrage
    post-up /usr/local/bin/firewall-rules.sh
    
    # Nettoyer à l'arrêt
    pre-down iptables -F
```

#### 7. Monitoring et logs

```bash
auto eth0
iface eth0 inet static
    address 192.168.1.100/24
    gateway 192.168.1.1
    
    # Logger l'activation
    post-up logger "Interface eth0 activée avec IP $(ip addr show eth0 | grep 'inet ' | awk '{print $2}')"
    
    # Logger la désactivation
    pre-down logger "Interface eth0 en cours de désactivation"
```

### 🔍 Checklist de déploiement

Avant de redémarrer une interface en production :

- [ ] Sauvegarde de `/etc/network/interfaces` effectuée
- [ ] Syntaxe validée avec `ifup -n -v`
- [ ] Configuration testée sur environnement de dev/test si possible
- [ ] Accès console physique disponible (ou KVM/IPMI)
- [ ] Horaire de maintenance planifié et communiqué
- [ ] Plan de rollback préparé
- [ ] Monitoring en place pour détecter rapidement les problèmes

> [!warning] Règle d'or Sur un serveur de production distant, **ne jamais** utiliser `systemctl restart networking` ou `ifdown -a`. Toujours redémarrer interface par interface avec un moyen de récupération en cas d'erreur.

---

## 🎓 Récapitulatif

**Concepts clés à retenir :**

1. **Fichier de configuration** : `/etc/network/interfaces` est le fichier central pour la configuration réseau traditionnelle Debian
    
2. **Directives essentielles** :
    
    - `auto` : démarrage automatique au boot
    - `allow-hotplug` : démarrage à la détection matérielle
    - `iface` : définition de la configuration
3. **IP statique** : nécessite `address`, `netmask`/notation CIDR, et `gateway`
    
4. **DHCP** : simple (`iface eth0 inet dhcp`), configuration automatique
    
5. **Commandes de gestion** :
    
    - `ifup` : activer une interface
    - `ifdown` : désactiver une interface
    - `systemctl {start|stop|restart} networking` : gérer le service global
6. **Sécurité** : toujours sauvegarder avant modification, tester avec `-n`, et privilégier les redémarrages interface par interface sur serveurs distants