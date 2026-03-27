

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

## 🎯 Introduction aux mécanismes de transition {#introduction}

La coexistence d'IPv4 et IPv6 sur Internet nécessite des mécanismes permettant la communication entre les deux protocoles. Ces mécanismes de transition garantissent une migration progressive sans interruption de service.

> [!info] Contexte IPv6 n'est pas rétrocompatible avec IPv4. Les équipements purement IPv6 ne peuvent pas communiquer directement avec des équipements IPv4, et vice-versa. D'où la nécessité de mécanismes de transition.

### Catégories de mécanismes

|Catégorie|Principe|Exemples|
|---|---|---|
|**Dual Stack**|Support simultané IPv4 et IPv6|Dual Stack natif|
|**Tunneling**|Encapsulation d'un protocole dans l'autre|6to4, 6in4, ISATAP|
|**Translation**|Traduction entre IPv4 et IPv6|NAT64, NAT-PT|

---

## 🔀 Dual Stack {#dual-stack}

### Principe

Le **Dual Stack** est la configuration d'un équipement réseau (routeur, serveur, ordinateur) pour qu'il supporte simultanément IPv4 et IPv6. Chaque interface possède à la fois une adresse IPv4 et une adresse IPv6.

> [!tip] Mécanisme recommandé Le Dual Stack est le mécanisme de transition le plus simple et le plus recommandé par l'IETF (Internet Engineering Task Force).

### Fonctionnement

```
┌─────────────────────────────────────┐
│     Application utilisateur         │
└─────────────────┬───────────────────┘
                  │
          ┌───────┴────────┐
          │                │
    ┌─────▼─────┐    ┌────▼─────┐
    │  Stack    │    │  Stack   │
    │   IPv4    │    │   IPv6   │
    └─────┬─────┘    └────┬─────┘
          │                │
          └───────┬────────┘
                  │
         ┌────────▼────────┐
         │  Interface      │
         │  Dual Stack     │
         │  10.0.1.5       │
         │  2001:db8::1    │
         └─────────────────┘
```

### Configuration

#### Sur Linux

```bash
# Afficher les adresses IPv4 et IPv6
ip addr show

# Configuration IPv4
sudo ip addr add 192.168.1.10/24 dev eth0

# Configuration IPv6
sudo ip addr add 2001:db8::10/64 dev eth0

# Activer IPv6 si désactivé
sudo sysctl -w net.ipv6.conf.all.disable_ipv6=0
sudo sysctl -w net.ipv6.conf.default.disable_ipv6=0
```

#### Configuration persistante (Debian/Ubuntu)

```bash
# Fichier /etc/network/interfaces
auto eth0
iface eth0 inet static
    address 192.168.1.10
    netmask 255.255.255.0
    gateway 192.168.1.1

iface eth0 inet6 static
    address 2001:db8::10
    netmask 64
    gateway 2001:db8::1
```

### Sélection automatique du protocole

Lorsqu'une application initie une connexion, le système d'exploitation choisit automatiquement entre IPv4 et IPv6 :

```bash
# Test de connectivité
ping -4 example.com  # Force IPv4
ping -6 example.com  # Force IPv6
ping example.com     # Choix automatique
```

> [!info] Préférence IPv6 Par défaut, la plupart des systèmes modernes préfèrent IPv6 quand les deux protocoles sont disponibles (RFC 6724).

### Avantages et inconvénients

**✅ Avantages :**

- Simple à mettre en œuvre
- Pas de surcharge (overhead) de tunneling
- Communication native dans les deux protocoles
- Flexibilité maximale

**❌ Inconvénients :**

- Nécessite des adresses IPv4 (problème de pénurie)
- Double configuration et maintenance
- Consommation de ressources mémoire accrue

> [!warning] Double pile = double configuration Chaque mécanisme de sécurité (firewall, ACL) doit être configuré pour les deux protocoles.

---

## 🚇 Tunneling {#tunneling}

Le **tunneling** consiste à encapsuler des paquets IPv6 dans des paquets IPv4 (ou l'inverse) pour traverser un réseau qui ne supporte qu'un seul des deux protocoles.

```
┌──────────────────────────────────────────────────┐
│         Paquet IPv6 original                     │
└──────────────────┬───────────────────────────────┘
                   │ Encapsulation
         ┌─────────▼──────────────────────────┐
         │  En-tête IPv4  │  Paquet IPv6      │
         └────────────────────────────────────┘
                   │ Transmission sur réseau IPv4
                   │ Décapsulation
         ┌─────────▼──────────────────────────┐
         │         Paquet IPv6 original        │
         └─────────────────────────────────────┘
```

---

### 6to4 {#6to4}

#### Principe

**6to4** (RFC 3056) est un mécanisme de tunneling automatique permettant à des sites IPv6 isolés de communiquer à travers un réseau IPv4 sans configuration manuelle de tunnels.

> [!info] Préfixe spécial 6to4 utilise le préfixe **2002::/16**. Une adresse IPv4 publique est intégrée dans l'adresse IPv6 pour permettre l'encapsulation automatique.

#### Format d'adresse 6to4

```
2002:AABB:CCDD::/48
     │   │   │
     └───┴───┴─── Adresse IPv4 en hexadécimal
```

**Exemple :**

- Adresse IPv4 : `192.0.2.1`
- En hexadécimal : `C0.00.02.01`
- Préfixe 6to4 : `2002:c000:0201::/48`

#### Configuration

```bash
# Convertir une adresse IPv4 en préfixe 6to4
# IPv4 : 203.0.113.50 → C3:00:71:32
# Préfixe : 2002:c300:7132::/48

# Configuration d'un routeur 6to4
sudo ip tunnel add tun6to4 mode sit remote any local 203.0.113.50
sudo ip link set dev tun6to4 up
sudo ip -6 addr add 2002:c300:7132::1/16 dev tun6to4
sudo ip -6 route add 2000::/3 via ::192.88.99.1 dev tun6to4
```

#### Relais 6to4

Les **relais 6to4** (6to4 relay routers) permettent la communication entre le monde 6to4 et l'IPv6 natif. L'adresse anycast `192.88.99.1` est réservée pour ces relais.

```
┌─────────────┐       ┌─────────────┐       ┌──────────────┐
│   Site      │       │   Réseau    │       │   Internet   │
│   IPv6      │◄─────►│   IPv4      │◄─────►│   IPv6       │
│  (6to4)     │ Tunnel│  Internet   │ Relai │   natif      │
└─────────────┘       └─────────────┘ 6to4  └──────────────┘
```

> [!warning] Obsolète 6to4 est considéré comme obsolète (RFC 7526) en raison de problèmes de fiabilité et de sécurité. Il est déconseillé de l'utiliser pour de nouveaux déploiements.

---

### 6in4 {#6in4}

#### Principe

**6in4** (IPv6 in IPv4), aussi appelé **proto-41** ou **SIT** (Simple Internet Transition), est un tunneling manuel où les points d'extrémité du tunnel sont configurés explicitement.

> [!tip] Tunnel statique Contrairement à 6to4, 6in4 nécessite une configuration manuelle mais offre plus de stabilité et de contrôle.

#### Fonctionnement

Le protocole IP numéro **41** est utilisé pour encapsuler les paquets IPv6 dans IPv4.

```
┌──────────────────────────────────────────────────┐
│  En-tête IPv4                                     │
│  Protocol = 41 (IPv6)                             │
│  Source = Adresse IPv4 locale                     │
│  Destination = Adresse IPv4 distante              │
├───────────────────────────────────────────────────┤
│  Paquet IPv6 complet                              │
│  (en-tête + données)                              │
└───────────────────────────────────────────────────┘
```

#### Configuration

**Routeur A (local) :**

```bash
# Créer le tunnel
sudo ip tunnel add sit1 mode sit \
    remote 198.51.100.50 \
    local 203.0.113.10 \
    ttl 255

# Activer l'interface
sudo ip link set dev sit1 up

# Configurer les adresses IPv6
sudo ip -6 addr add 2001:db8:1::1/64 dev sit1

# Ajouter une route
sudo ip -6 route add 2001:db8:2::/64 dev sit1
```

**Routeur B (distant) :**

```bash
# Créer le tunnel (miroir)
sudo ip tunnel add sit1 mode sit \
    remote 203.0.113.10 \
    local 198.51.100.50 \
    ttl 255

sudo ip link set dev sit1 up
sudo ip -6 addr add 2001:db8:1::2/64 dev sit1
sudo ip -6 route add 2001:db8:1::/64 dev sit1
```

#### Vérification

```bash
# Voir les tunnels actifs
ip -6 tunnel show

# Test de connectivité
ping6 2001:db8:1::2

# Tracer la route
traceroute6 2001:db8:2::1

# Statistiques du tunnel
ip -s tunnel show sit1
```

> [!warning] Pare-feu Les pare-feu doivent autoriser le protocole IP 41. Certains FAI peuvent bloquer ce protocole.

```bash
# iptables : autoriser le protocole 41
sudo iptables -A INPUT -p 41 -j ACCEPT
sudo iptables -A OUTPUT -p 41 -j ACCEPT
```

#### Avantages et inconvénients

**✅ Avantages :**

- Stable et fiable
- Contrôle total sur la configuration
- Fonctionne avec n'importe quel préfixe IPv6

**❌ Inconvénients :**

- Configuration manuelle nécessaire
- Ne passe pas à travers NAT standard
- Maintenance des deux extrémités du tunnel

---

### ISATAP {#isatap}

#### Principe

**ISATAP** (Intra-Site Automatic Tunnel Addressing Protocol, RFC 5214) est un mécanisme de tunneling automatique conçu pour faciliter le déploiement d'IPv6 au sein d'un site utilisant IPv4.

> [!info] Usage intra-site ISATAP est principalement destiné aux réseaux d'entreprise, pas à Internet public.

#### Format d'adresse ISATAP

Les adresses ISATAP utilisent un format spécial intégrant l'adresse IPv4 :

```
┌─────────────────────────────────────────────────────┐
│  Préfixe IPv6 (64 bits)  │ 0000:5EFE │ IPv4 (32b)  │
└─────────────────────────────────────────────────────┘
                              │
                              └─── Identifiant ISATAP fixe
```

**Exemple :**

- Préfixe : `2001:db8::/64`
- Adresse IPv4 : `192.168.1.100` (en hex: `C0A8:0164`)
- Adresse ISATAP : `2001:db8::5efe:c0a8:0164`

#### Configuration

**Sur Windows :**

```powershell
# Activer ISATAP
netsh interface ipv6 isatap set router isatap.example.com

# Configurer l'état
netsh interface ipv6 isatap set state enabled

# Afficher la configuration
netsh interface ipv6 isatap show state
netsh interface ipv6 show interface
```

**Sur Linux :**

```bash
# Créer une interface ISATAP
sudo ip tunnel add isatap0 mode isatap local 192.168.1.100

# Activer l'interface
sudo ip link set dev isatap0 up

# Configurer l'adresse
sudo ip -6 addr add 2001:db8::5efe:c0a8:0164/64 dev isatap0

# Routage par défaut via le routeur ISATAP
sudo ip -6 route add default via 2001:db8::5efe:c0a8:0001 dev isatap0
```

#### Routeur ISATAP

Un routeur ISATAP doit être configuré pour annoncer les préfixes IPv6 :

```bash
# Activer le forwarding IPv6
sudo sysctl -w net.ipv6.conf.all.forwarding=1

# Configurer radvd pour ISATAP
# Fichier /etc/radvd.conf
interface isatap0
{
    AdvSendAdvert on;
    prefix 2001:db8::/64
    {
        AdvOnLink on;
        AdvAutonomous on;
    };
};
```

#### Architecture ISATAP typique

```
┌──────────────────────────────────────────────────┐
│              Réseau d'entreprise IPv4            │
│                                                  │
│  ┌─────────┐         ┌─────────┐                │
│  │   PC    │         │   PC    │                │
│  │ ISATAP  │         │ ISATAP  │                │
│  │ Client  │         │ Client  │                │
│  └────┬────┘         └────┬────┘                │
│       │                   │                      │
│       │    Tunnels IPv6   │                      │
│       └────────┬──────────┘                      │
│                │                                 │
│         ┌──────▼──────┐                          │
│         │   Routeur   │                          │
│         │   ISATAP    │◄────────────────────────►│ Internet IPv6
│         └─────────────┘                          │
└──────────────────────────────────────────────────┘
```

> [!tip] Découverte automatique Les clients ISATAP peuvent découvrir automatiquement le routeur ISATAP via DNS en cherchant le nom `isatap.domain.com`.

#### Avantages et inconvénients

**✅ Avantages :**

- Configuration automatique côté client
- Idéal pour migration progressive interne
- Fonctionne à travers NAT

**❌ Inconvénients :**

- Complexité de déploiement à grande échelle
- Support limité sur certains systèmes
- Performance moindre que Dual Stack natif

> [!warning] Désactivation par défaut ISATAP est désactivé par défaut sur Windows depuis Windows 10 pour des raisons de sécurité.

---

## 🔄 NAT64 et DNS64 {#nat64-dns64}

### Principe général

**NAT64** et **DNS64** travaillent ensemble pour permettre à des clients IPv6-only de communiquer avec des serveurs IPv4-only, sans nécessiter de support IPv4 côté client.

```
┌──────────────┐      ┌─────────┐      ┌──────────────┐
│   Client     │      │  NAT64  │      │   Serveur    │
│   IPv6-only  │─────►│  +      │─────►│   IPv4-only  │
│              │ IPv6 │  DNS64  │ IPv4 │              │
└──────────────┘      └─────────┘      └──────────────┘
```

### DNS64

#### Fonctionnement

**DNS64** synthétise des enregistrements AAAA (IPv6) à partir d'enregistrements A (IPv4) lorsqu'aucun enregistrement IPv6 n'existe.

```
Client demande : www.example.com AAAA ?
         │
         ▼
    ┌─────────┐
    │  DNS64  │
    └────┬────┘
         │ Recherche AAAA → Aucun résultat
         │ Recherche A → 192.0.2.1
         │ Synthèse : 64:ff9b::192.0.2.1
         ▼
Client reçoit : 64:ff9b::c000:0201
```

#### Préfixe Well-Known

Le préfixe **64:ff9b::/96** (RFC 6052) est le préfixe standard pour NAT64/DNS64.

```
64:ff9b::192.0.2.1
│        │
│        └─── Adresse IPv4 intégrée
│
└─── Préfixe NAT64 Well-Known
```

#### Configuration DNS64 (BIND9)

```bash
# Fichier /etc/bind/named.conf.options
options {
    // Configuration DNS64
    dns64 64:ff9b::/96 {
        clients { any; };
        mapped { !64:ff9b::/96; any; };
        exclude { ::ffff:0:0/96; };
    };
};
```

#### Configuration DNS64 (Unbound)

```bash
# Fichier /etc/unbound/unbound.conf
server:
    module-config: "dns64 validator iterator"

dns64:
    dns64-prefix: 64:ff9b::/96
```

### NAT64

#### Fonctionnement

**NAT64** traduit les paquets IPv6 en IPv4 et vice-versa, en maintenant une table de correspondance des sessions.

**Traduction IPv6 → IPv4 :**

```
┌────────────────────────────────────────────┐
│  Paquet IPv6                               │
│  Source: 2001:db8::1                       │
│  Dest: 64:ff9b::c000:0201 (192.0.2.1)     │
└────────────────┬───────────────────────────┘
                 │ NAT64
                 ▼
┌────────────────────────────────────────────┐
│  Paquet IPv4                               │
│  Source: 203.0.113.50 (adresse NAT64)     │
│  Dest: 192.0.2.1                           │
└────────────────────────────────────────────┘
```

**Traduction IPv4 → IPv6 (retour) :**

```
┌────────────────────────────────────────────┐
│  Paquet IPv4                               │
│  Source: 192.0.2.1                         │
│  Dest: 203.0.113.50                        │
└────────────────┬───────────────────────────┘
                 │ NAT64 (table de sessions)
                 ▼
┌────────────────────────────────────────────┐
│  Paquet IPv6                               │
│  Source: 64:ff9b::c000:0201                │
│  Dest: 2001:db8::1                         │
└────────────────────────────────────────────┘
```

#### Configuration NAT64 (Jool)

**Jool** est une implémentation open-source populaire de NAT64 pour Linux.

```bash
# Installation
sudo apt install jool-dkms jool-tools

# Activer le module
sudo modprobe jool

# Configuration basique
sudo jool instance add "default" --netfilter --pool6 64:ff9b::/96

# Ajouter un pool d'adresses IPv4
sudo jool -i "default" pool4 add \
    --tcp 203.0.113.50 1024-65535 \
    --udp 203.0.113.50 1024-65535 \
    --icmp 203.0.113.50 1024-65535

# Activer
sudo jool instance enable "default"

# Vérifier l'état
sudo jool instance display
sudo jool -i "default" stats display
```

#### Configuration NAT64 (Tayga)

**Tayga** est une alternative légère à Jool.

```bash
# Installation
sudo apt install tayga

# Configuration /etc/tayga.conf
tun-device nat64
ipv4-addr 192.168.255.1
ipv6-addr 2001:db8:1::1
prefix 64:ff9b::/96
dynamic-pool 192.168.255.0/24
data-dir /var/spool/tayga

# Démarrer le service
sudo systemctl start tayga
sudo systemctl enable tayga

# Configuration réseau
sudo ip link set nat64 up
sudo ip route add 64:ff9b::/96 dev nat64
sudo ip route add 192.168.255.0/24 dev nat64
```

### Avantages et inconvénients

**✅ Avantages :**

- Permet aux clients IPv6-only d'accéder à Internet IPv4
- Solution de transition progressive
- Réduit le besoin d'adresses IPv4 côté client

**❌ Inconvénients :**

- Point de traduction centralisé (SPOF)
- Perte de la connectivité end-to-end
- Problèmes avec certains protocoles (FTP, SIP)
- Performance impactée par la translation

> [!warning] Incompatibilités protocolaires NAT64 ne fonctionne pas bien avec les protocoles intégrant des adresses IP dans les données applicatives (FTP actif, SIP, etc.).

### Architecture typique NAT64/DNS64

```
┌────────────────────────────────────────────────────┐
│           Réseau IPv6-only                         │
│                                                    │
│  ┌──────────┐        ┌──────────┐                  │
│  │  Client  │        │  Client  │                  │
│  │   IPv6   │        │   IPv6   │                  │
│  └────┬─────┘        └────┬─────┘                  │
│       │                   │                        │
│       └─────────┬─────────┘                        │
│                 │                                  │
│          ┌──────▼──────┐                           │
│          │   DNS64     │                           │
│          │   Server    │                           │
│          └──────┬──────┘                           │
│                 │                                  │
│          ┌──────▼──────┐                           │
│          │   NAT64     │                           │
│          │   Gateway   │◄──────────────────────────┼─► Internet IPv4
│          └─────────────┘                           │
│                                                    │
└────────────────────────────────────────────────────┘
```

---

## 🔀 Translation (NAT-PT) {#translation}

### Principe

**NAT-PT** (Network Address Translation - Protocol Translation, RFC 2766) était un mécanisme de translation bidirectionnelle entre IPv4 et IPv6, similaire à NAT64 mais permettant l'initiation de connexion dans les deux sens.

> [!warning] Obsolète et déprécié NAT-PT a été officiellement déprécié par le RFC 4966 en 2007 en raison de nombreux problèmes techniques. Il ne doit plus être utilisé.

### Problèmes de NAT-PT

**Raisons de la dépréciation :**

1. **Incompatibilités protocolaires**
    
    - Problèmes avec les protocoles intégrant des adresses (FTP, SIP, H.323)
    - Nécessité d'ALG (Application Layer Gateway) pour chaque protocole
2. **Violation du modèle end-to-end**
    
    - Perte de traçabilité
    - Problèmes d'authentification IPsec
    - Corruption des checksums
3. **Problèmes de gestion d'état**
    
    - Table de correspondance complexe à maintenir
    - Expiration des entrées NAT
    - Scalabilité limitée
4. **Fragmentation**
    
    - Problèmes avec la fragmentation IPv4/IPv6
    - MTU mismatch
5. **DNS et découverte**
    
    - Complexité de la résolution DNS
    - Problèmes avec DNSSEC

### Différence avec NAT64

|Caractéristique|NAT-PT (déprécié)|NAT64|
|---|---|---|
|Standard|RFC 2766 (obsolète)|RFC 6146|
|Direction|Bidirectionnelle|Principalement IPv6→IPv4|
|DNS|DNS-ALG intégré|DNS64 séparé|
|Statut|Déprécié (2007)|Actif|
|Complexité|Très élevée|Modérée|

> [!info] Evolution vers NAT64 NAT64 a été conçu en tirant les leçons des échecs de NAT-PT, avec une architecture plus simple et mieux définie.

### Alternative recommandée

Au lieu de NAT-PT, utilisez :

- **NAT64/DNS64** pour IPv6-only vers IPv4
- **Dual Stack** quand possible
- **Tunneling 6in4** pour connectivité IPv6 sur IPv4

---

## 🎯 Comparaison des mécanismes

|Mécanisme|Type|Usage|Avantages|Inconvénients|
|---|---|---|---|---|
|**Dual Stack**|Support double|Production|Simple, natif|Coût IPv4|
|**6to4**|Tunnel auto|❌ Obsolète|Automatique|Peu fiable|
|**6in4**|Tunnel manuel|Transition|Stable|Config manuelle|
|**ISATAP**|Tunnel auto|Intra-site|Auto-config|Support limité|
|**NAT64/DNS64**|Translation|IPv6-only|Sans IPv4 client|Complexe|
|**NAT-PT**|Translation|❌ Déprécié|-|Trop de problèmes|

### Recommandations d'utilisation

> [!tip] Stratégie de déploiement
> 
> 1. **Court terme** : Dual Stack sur tous les équipements
> 2. **Moyen terme** : NAT64/DNS64 pour les réseaux IPv6-only
> 3. **Long terme** : IPv6 natif partout (objectif final)

**Scénarios d'usage :**

- **Dual Stack** : Solution privilégiée pour tous les réseaux en production
- **6in4** : Connectivité IPv6 via FAI IPv4-only (tunnels broker comme Hurricane Electric)
- **ISATAP** : Migration progressive dans réseaux d'entreprise (usage en déclin)
- **NAT64/DNS64** : Réseaux mobiles modernes (4G/5G), IoT IPv6-only

> [!warning] Éviter
> 
> - 6to4 : obsolète et peu fiable
> - NAT-PT : déprécié et problématique
> - Tunneling en production longue durée : préférer Dual Stack ou IPv6 natif

---

## 🔍 Astuces pratiques

### Débugger les problèmes de connectivité

```bash
# Vérifier support IPv6
ping6 ::1
ping6 2001:4860:4860::8888  # Google DNS

# Tester Dual Stack
curl -4 ifconfig.co  # Force IPv4
curl -6 ifconfig.co  # Force IPv6

# Tracer les tunnels
ip -6 tunnel show
ip link show type sit

# Voir les routes IPv6
ip -6 route show

# Capture de paquets tunnel
sudo tcpdump -i any proto 41  # 6in4
sudo tcpdump -i any 'ip6 or proto 41'
```

### Tester NAT64/DNS64

```bash
# Résoudre via DNS64
dig AAAA ipv4only.arpa @dns64.server.com

# Vérifier la synthèse DNS64
dig +short AAAA example-ipv4-only.com @64:ff9b::8.8.8.8

# Tester connectivité via NAT64
ping6 64:ff9b::8.8.8.8  # Ping Google DNS via NAT64
```

### Calcul manuel d'adresses

```bash
# Convertir IPv4 en 6to4
# Exemple : 203.0.113.5
# En hex : CB.00.71.05
# Préfixe 6to4 : 2002:cb00:7105::/48

# Convertir IPv4 en ISATAP
# Exemple : 192.168.1.100
# En hex : C0A8:0164
# ISATAP : 2001:db8::5efe:c0a8:0164

# Script bash pour conversion
ipv4_to_6to4() {
    IFS='.' read -r a b c d <<< "$1"
    printf "2002:%02x%02x:%02x%02x::/48\n" $a $b $c $d
}

ipv4_to_isatap() {
    local prefix="$1"
    IFS='.' read -r a b c d <<< "$2"
    printf "${prefix}:5efe:%02x%02x:%02x%02x\n" $a $b $c $d
}

# Utilisation
ipv4_to_6to4 "203.0.113.5"
# Résultat : 2002:cb00:7105::/48

ipv4_to_isatap "2001:db8::" "192.168.1.100"
# Résultat : 2001:db8::5efe:c0a8:0164
```

### Vérifier la préférence IPv4/IPv6

```bash
# Voir la table de préférence (Linux)
cat /etc/gai.conf

# Forcer IPv4 en priorité (temporaire)
echo "precedence ::ffff:0:0/96  100" | sudo tee -a /etc/gai.conf

# Restaurer préférence IPv6
sudo sed -i '/precedence ::ffff:0:0\/96/d' /etc/gai.conf
```

### Monitoring des tunnels

```bash
# Script de monitoring d'un tunnel 6in4
#!/bin/bash
TUNNEL="sit1"
REMOTE_IPV6="2001:db8:1::2"

while true; do
    if ping6 -c 1 -W 2 $REMOTE_IPV6 > /dev/null 2>&1; then
        echo "[$(date)] Tunnel $TUNNEL : OK"
    else
        echo "[$(date)] Tunnel $TUNNEL : DOWN"
        # Redémarrage automatique
        sudo ip link set $TUNNEL down
        sudo ip link set $TUNNEL up
    fi
    sleep 60
done
```

### Performance et MTU

```bash
# Vérifier le MTU optimal pour un tunnel
ping6 -M do -s 1452 2001:db8::1  # Test avec payload 1452
# Si échec, réduire progressivement

# Configurer MTU sur tunnel
sudo ip link set sit1 mtu 1480

# MTU recommandés
# Réseau standard : 1500
# Tunnel 6in4/6to4 : 1480 (1500 - 20 octets IPv4)
# Tunnel ISATAP : 1480
# PPPoE + tunnel : 1460
```

---

## 📊 Bonnes pratiques de déploiement

### Phase 1 : Préparation

1. **Audit du réseau**
    
    ```bash
    # Inventaire des équipements
    # - Vérifier support IPv6 sur tous les équipements
    # - Identifier les applications critiques
    # - Tester la compatibilité
    ```
    
2. **Formation des équipes**
    
    - Comprendre les différences IPv4/IPv6
    - Maîtriser les outils de diagnostic
    - Planifier la migration
3. **Tests en laboratoire**
    
    - Valider tous les mécanismes
    - Tester les applications critiques
    - Simuler les pannes

### Phase 2 : Déploiement progressif

1. **Activer Dual Stack**
    
    ```bash
    # Commencer par les serveurs DNS
    # Puis les serveurs web
    # Enfin les postes clients
    ```
    
2. **Monitoring intensif**
    
    ```bash
    # Surveiller les logs
    # Mesurer les performances
    # Détecter les anomalies
    ```
    
3. **Optimisation**
    
    - Ajuster les MTU
    - Affiner les règles de routage
    - Optimiser les préférences

### Phase 3 : Consolidation

1. **Désactivation progressive d'IPv4**
    
    - Commencer par les nouveaux services
    - Maintenir IPv4 pour la compatibilité
    - Migration complète à long terme
2. **Documentation**
    
    - Schémas réseau à jour
    - Procédures de dépannage
    - Base de connaissance

> [!tip] Règle d'or Ne jamais déployer de mécanisme de transition en production sans tests approfondis en environnement de développement/pré-production.

---

## 🚨 Pièges courants à éviter

### 1. Configuration Dual Stack incomplète

**❌ Erreur :**

```bash
# Oublier de configurer les pare-feu pour IPv6
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
# IPv6 est bloqué !
```

**✅ Correction :**

```bash
# Toujours configurer les deux
sudo iptables -A INPUT -p tcp --dport 80 -j ACCEPT
sudo ip6tables -A INPUT -p tcp --dport 80 -j ACCEPT
```

### 2. MTU mal configuré dans les tunnels

**❌ Erreur :**

```bash
# Garder MTU 1500 sur un tunnel 6in4
# Provoque fragmentation et pertes de paquets
```

**✅ Correction :**

```bash
# Toujours réduire le MTU pour tunnels
sudo ip link set sit1 mtu 1480
```

### 3. Oublier les routes de retour

**❌ Erreur :**

```bash
# Configurer seulement un côté du tunnel
# Trafic aller OK, retour KO
```

**✅ Correction :**

```bash
# Toujours configurer les deux extrémités
# Routeur A
sudo ip -6 route add 2001:db8:2::/64 dev sit1

# Routeur B
sudo ip -6 route add 2001:db8:1::/64 dev sit1
```

### 4. NAT64 sans DNS64

**❌ Erreur :**

```bash
# Déployer NAT64 seul
# Les clients ne peuvent pas résoudre les IPv4
```

**✅ Correction :**

```bash
# Toujours coupler NAT64 avec DNS64
# Les deux mécanismes sont interdépendants
```

### 5. Utiliser 6to4 en production

**❌ Erreur :**

```bash
# Déployer 6to4 pour un service critique
# Fiabilité médiocre, relais publics instables
```

**✅ Correction :**

```bash
# Utiliser 6in4 avec tunnel broker fiable
# Ou mieux : Dual Stack natif
```

### 6. Négliger la sécurité des tunnels

**❌ Erreur :**

```bash
# Tunnels sans filtrage
# Accepter tous les paquets proto 41
sudo iptables -A INPUT -p 41 -j ACCEPT
```

**✅ Correction :**

```bash
# Filtrer par source/destination
sudo iptables -A INPUT -p 41 -s 198.51.100.50 -d 203.0.113.10 -j ACCEPT
sudo iptables -A INPUT -p 41 -j DROP
```

### 7. Mauvaise gestion des préférences

**❌ Erreur :**

```bash
# Laisser le système choisir aléatoirement
# Peut causer des comportements imprévisibles
```

**✅ Correction :**

```bash
# Définir explicitement les préférences
# Tester avec -4 et -6 pour forcer le protocole
curl -4 example.com  # Force IPv4
curl -6 example.com  # Force IPv6
```

---

## 🔐 Considérations de sécurité

### Tunnels et pare-feu

```bash
# Sécuriser les tunnels 6in4
sudo iptables -A INPUT -p 41 -s REMOTE_IPV4 -j ACCEPT
sudo iptables -A INPUT -p 41 -j LOG --log-prefix "Tunnel reject: "
sudo iptables -A INPUT -p 41 -j DROP

# Filtrage IPv6 sur tunnel
sudo ip6tables -A INPUT -i sit1 -m state --state ESTABLISHED,RELATED -j ACCEPT
sudo ip6tables -A INPUT -i sit1 -p ipv6-icmp -j ACCEPT
sudo ip6tables -A INPUT -i sit1 -j DROP
```

### Protection contre les attaques

**Spoofing via tunnels :**

```bash
# Filtrage anti-spoofing
sudo ip6tables -A INPUT -i sit1 -s 2001:db8:1::/64 -j ACCEPT
sudo ip6tables -A INPUT -i sit1 -j DROP

# Limiter ICMP pour éviter flood
sudo ip6tables -A INPUT -p ipv6-icmp --icmpv6-type echo-request \
    -m limit --limit 1/s -j ACCEPT
sudo ip6tables -A INPUT -p ipv6-icmp --icmpv6-type echo-request -j DROP
```

**NAT64 et sécurité :**

```bash
# Logs des translations NAT64
sudo jool -i "default" global update logging-session true

# Limiter le nombre de sessions
sudo jool -i "default" global update maximum-simultaneous-opens 10000
```

### Audit et conformité

```bash
# Vérifier les configurations de sécurité
sudo ip6tables -L -v -n
sudo iptables -L -v -n

# Vérifier l'absence de routes non autorisées
ip -6 route show | grep -v "fe80\|::/0\|2001:db8"

# Tester les vulnérabilités IPv6
# Utiliser des outils comme THC-IPv6, Chiron
```

> [!warning] Sécurité par défaut IPv6 n'est pas automatiquement plus sûr qu'IPv4. Tous les mécanismes de sécurité (pare-feu, IDS, authentification) doivent être configurés pour IPv6.

---

## 📈 Métriques et indicateurs

### KPI à surveiller

```bash
# Taux d'utilisation IPv6 vs IPv4
# Commande exemple pour collecter les stats
sudo tcpdump -n -c 1000 | grep -c "IP6"
sudo tcpdump -n -c 1000 | grep -c "IP" | grep -v "IP6"

# Latence des tunnels
ping6 -c 100 REMOTE_IPV6 | tail -1

# Perte de paquets
sudo mtr -6 -c 100 --report REMOTE_IPV6

# Utilisation bande passante par protocole
sudo iftop -i sit1
```

### Dashboard de monitoring

**Métriques importantes :**

- % trafic IPv6 vs IPv4
- Latence moyenne tunnels
- Taux de perte paquets
- Nombre de sessions NAT64 actives
- Utilisation CPU/RAM des gateways
- Disponibilité des tunnels

### Logs et alertes

```bash
# Configuration syslog pour tunnels
# /etc/rsyslog.d/tunnel-monitoring.conf
:msg, contains, "sit1" /var/log/tunnel.log

# Script d'alerte tunnel down
#!/bin/bash
if ! ping6 -c 3 REMOTE_IPV6 > /dev/null 2>&1; then
    echo "ALERT: Tunnel down" | mail -s "Tunnel Alert" admin@example.com
fi
```

---

## 🎓 Résumé des concepts clés

### Points essentiels à retenir

1. **Dual Stack** est la solution recommandée pour la transition
2. **6to4** est obsolète et ne doit plus être utilisé
3. **6in4** reste valable pour des tunnels stables
4. **ISATAP** est adapté aux réseaux internes uniquement
5. **NAT64/DNS64** permet l'IPv6-only avec compatibilité IPv4
6. **NAT-PT** est déprécié et ne doit jamais être utilisé

### Choix du mécanisme selon le contexte

|Contexte|Mécanisme recommandé|
|---|---|
|Production moderne|**Dual Stack**|
|FAI sans IPv6 natif|**6in4 avec tunnel broker**|
|Réseau d'entreprise legacy|**ISATAP** (temporaire)|
|Réseau mobile 4G/5G|**NAT64/DNS64**|
|Migration progressive|**Dual Stack → IPv6-only**|

### Commandes essentielles à maîtriser

```bash
# Diagnostic général
ip -6 addr show
ip -6 route show
ping6 ::1
traceroute6 2001:4860:4860::8888

# Gestion tunnels
ip tunnel show
ip link set TUNNEL up/down
ip -6 addr add ADDRESS dev TUNNEL

# Tests de connectivité
curl -6 ifconfig.co
dig AAAA example.com
nc -6 example.com 80
```

---

## ✅ Checklist de mise en œuvre

### Avant le déploiement

- [ ] Audit complet du réseau existant
- [ ] Vérification support IPv6 tous équipements
- [ ] Tests en laboratoire réussis
- [ ] Documentation technique complète
- [ ] Formation des équipes techniques
- [ ] Plan de rollback défini
- [ ] Outils de monitoring en place

### Pendant le déploiement

- [ ] Activation Dual Stack progressive
- [ ] Monitoring en temps réel
- [ ] Tests de connectivité continus
- [ ] Validation des applications critiques
- [ ] Ajustements MTU si nécessaire
- [ ] Configuration pare-feu IPv6
- [ ] Vérification des performances

### Après le déploiement

- [ ] Collecte des métriques
- [ ] Analyse des logs
- [ ] Optimisation des configurations
- [ ] Documentation des incidents
- [ ] Retour d'expérience
- [ ] Planification phase suivante
- [ ] Maintien des compétences équipes

---

🎯 **Ce cours couvre l'intégralité des mécanismes de transition IPv4/IPv6 nécessaires pour comprendre et implémenter la coexistence des deux protocoles.**