

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

Les outils de diagnostic réseau sont essentiels pour l'administration système. Ils permettent d'identifier les problèmes de connectivité, d'analyser les configurations réseau et de surveiller l'état des connexions. Cette section couvre les outils modernes de la suite **iproute2** qui remplacent les anciennes commandes, ainsi que les utilitaires classiques de diagnostic.

> [!info] Évolution des outils réseau La suite **iproute2** (commandes `ip`) est le standard moderne sous Linux et remplace progressivement les anciennes commandes comme `ifconfig`, `route` et `arp`. Les distributions récentes privilégient exclusivement iproute2.

---

## Suite iproute2

La suite **iproute2** fournit un ensemble cohérent de commandes pour gérer tous les aspects du réseau Linux. La commande principale est `ip`, qui regroupe plusieurs sous-commandes.

### ip addr - Gestion des adresses IP

La commande `ip addr` (ou `ip a`) affiche et configure les adresses IP des interfaces réseau.

#### 📊 Affichage des adresses

```bash
# Afficher toutes les interfaces et leurs adresses
ip addr show
ip a  # Version courte

# Afficher une interface spécifique
ip addr show dev eth0
ip a s eth0  # Version courte

# Afficher uniquement les interfaces actives (UP)
ip addr show up

# Afficher uniquement les adresses IPv4
ip -4 addr show

# Afficher uniquement les adresses IPv6
ip -6 addr show
```

> [!example] Lecture de la sortie
> 
> ```
> 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
>     link/ether 00:0c:29:3a:6f:91 brd ff:ff:ff:ff:ff:ff
>     inet 192.168.1.100/24 brd 192.168.1.255 scope global eth0
>        valid_lft forever preferred_lft forever
>     inet6 fe80::20c:29ff:fe3a:6f91/64 scope link
>        valid_lft forever preferred_lft forever
> ```
> 
> - **2:** numéro de l'interface
> - **eth0:** nom de l'interface
> - **UP:** interface activée
> - **mtu 1500:** taille maximale des paquets
> - **inet 192.168.1.100/24:** adresse IPv4 avec masque CIDR
> - **scope global:** portée de l'adresse (global = routable)

#### ➕ Ajout d'adresses IP

```bash
# Ajouter une adresse IPv4
sudo ip addr add 192.168.1.200/24 dev eth0

# Ajouter une adresse IPv4 avec broadcast
sudo ip addr add 192.168.1.201/24 brd + dev eth0

# Ajouter une adresse IPv6
sudo ip addr add 2001:db8::1/64 dev eth0

# Ajouter une adresse secondaire (alias)
sudo ip addr add 192.168.1.202/24 dev eth0 label eth0:0
```

> [!tip] Adresses multiples Une même interface peut avoir plusieurs adresses IP. C'est utile pour héberger plusieurs services sur différentes IP ou pour migrer progressivement d'une adresse à une autre.

#### ➖ Suppression d'adresses IP

```bash
# Supprimer une adresse IPv4
sudo ip addr del 192.168.1.200/24 dev eth0

# Supprimer toutes les adresses d'une interface
sudo ip addr flush dev eth0
```

> [!warning] Attention avec flush La commande `ip addr flush` supprime TOUTES les adresses de l'interface, y compris l'adresse principale. Vous pouvez perdre l'accès SSH si vous l'exécutez sur l'interface de connexion.

---

### ip link - Gestion des interfaces réseau

La commande `ip link` gère l'état et les propriétés des interfaces réseau au niveau liaison (couche 2).

#### 📊 Affichage des interfaces

```bash
# Afficher toutes les interfaces
ip link show
ip link  # Version courte

# Afficher une interface spécifique
ip link show dev eth0

# Afficher les statistiques d'une interface
ip -s link show dev eth0
ip -s -s link show dev eth0  # Statistiques détaillées
```

> [!example] Sortie des statistiques
> 
> ```
> 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
>     link/ether 00:0c:29:3a:6f:91 brd ff:ff:ff:ff:ff:ff
>     RX: bytes  packets  errors  dropped overrun mcast
>     1234567    9876     0       0       0       123
>     TX: bytes  packets  errors  dropped carrier collsns
>     7654321    8765     0       0       0       0
> ```

#### 🔧 Modification de l'état des interfaces

```bash
# Activer une interface
sudo ip link set dev eth0 up

# Désactiver une interface
sudo ip link set dev eth0 down

# Modifier le MTU (Maximum Transmission Unit)
sudo ip link set dev eth0 mtu 9000  # Jumbo frames

# Modifier l'adresse MAC
sudo ip link set dev eth0 address 00:11:22:33:44:55

# Renommer une interface (doit être DOWN)
sudo ip link set dev eth0 down
sudo ip link set dev eth0 name lan0
sudo ip link set dev lan0 up
```

> [!warning] Changement d'adresse MAC Changer l'adresse MAC nécessite que l'interface soit désactivée. De plus, certaines cartes réseau ne supportent pas le changement d'adresse MAC ou reviennent à leur adresse d'origine au redémarrage.

#### 🔗 Gestion des interfaces virtuelles

```bash
# Créer une interface VLAN
sudo ip link add link eth0 name eth0.100 type vlan id 100

# Créer un pont (bridge)
sudo ip link add name br0 type bridge

# Créer une paire veth (virtual ethernet)
sudo ip link add veth0 type veth peer name veth1

# Supprimer une interface virtuelle
sudo ip link delete dev eth0.100
```

---

### ip route - Gestion des routes

La commande `ip route` (ou `ip r`) gère la table de routage du système.

#### 📊 Affichage des routes

```bash
# Afficher la table de routage
ip route show
ip r  # Version courte

# Afficher la route par défaut
ip route show default

# Afficher les routes pour un réseau spécifique
ip route show 192.168.1.0/24

# Obtenir la route vers une destination
ip route get 8.8.8.8
ip route get 2001:4860:4860::8888  # IPv6
```

> [!example] Lecture de la table de routage
> 
> ```
> default via 192.168.1.1 dev eth0 proto static metric 100
> 192.168.1.0/24 dev eth0 proto kernel scope link src 192.168.1.100
> 10.0.0.0/8 via 192.168.1.254 dev eth0 proto static metric 200
> ```
> 
> - **default via 192.168.1.1:** passerelle par défaut
> - **dev eth0:** interface de sortie
> - **proto kernel:** route créée automatiquement par le noyau
> - **metric 100:** priorité de la route (plus faible = plus prioritaire)
> - **src 192.168.1.100:** adresse source utilisée pour ce réseau

#### ➕ Ajout de routes

```bash
# Ajouter une route par défaut
sudo ip route add default via 192.168.1.1 dev eth0

# Ajouter une route vers un réseau spécifique
sudo ip route add 10.0.0.0/8 via 192.168.1.254 dev eth0

# Ajouter une route avec métrique personnalisée
sudo ip route add 172.16.0.0/12 via 192.168.1.253 metric 50

# Ajouter une route directe (sans passerelle)
sudo ip route add 192.168.2.0/24 dev eth1

# Route IPv6
sudo ip -6 route add default via fe80::1 dev eth0
```

> [!tip] Métriques de route Lorsque plusieurs routes existent vers la même destination, le système choisit celle avec la **métrique la plus faible**. Cela permet de définir des routes de secours (failover).

#### ➖ Suppression de routes

```bash
# Supprimer une route spécifique
sudo ip route del 10.0.0.0/8 via 192.168.1.254

# Supprimer la route par défaut
sudo ip route del default

# Supprimer toutes les routes d'une interface
sudo ip route flush dev eth0
```

#### 🎯 Tables de routage multiples

Linux supporte plusieurs tables de routage (routage basé sur des politiques).

```bash
# Afficher une table spécifique
ip route show table local
ip route show table main

# Afficher toutes les tables
ip route show table all

# Ajouter une route dans une table personnalisée
sudo ip route add 10.0.0.0/8 via 192.168.1.254 table 100

# Lister les tables configurées
cat /etc/iproute2/rt_tables
```

> [!info] Tables de routage standards
> 
> - **local (255):** routes locales (adresses de l'hôte)
> - **main (254):** table principale de routage
> - **default (253):** règles par défaut
> - **0:** table anonyme, non utilisée

---

## Outils de connectivité

### ping - Test de connectivité

L'outil `ping` envoie des paquets ICMP Echo Request pour tester la connectivité réseau et mesurer la latence.

#### 🎯 Utilisation basique

```bash
# Ping simple (Ctrl+C pour arrêter)
ping 8.8.8.8

# Ping avec nombre limité de paquets
ping -c 4 8.8.8.8

# Ping avec intervalle personnalisé (en secondes)
ping -i 0.5 8.8.8.8  # Toutes les 0.5 secondes

# Ping avec timeout
ping -W 2 8.8.8.8  # Timeout de 2 secondes par paquet

# Ping IPv6
ping6 2001:4860:4860::8888
ping -6 google.com  # Avec résolution DNS
```

> [!example] Sortie typique
> 
> ```
> PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
> 64 bytes from 8.8.8.8: icmp_seq=1 ttl=118 time=12.3 ms
> 64 bytes from 8.8.8.8: icmp_seq=2 ttl=118 time=11.8 ms
> 64 bytes from 8.8.8.8: icmp_seq=3 ttl=118 time=12.1 ms
> 
> --- 8.8.8.8 ping statistics ---
> 3 packets transmitted, 3 received, 0% packet loss, time 2003ms
> rtt min/avg/max/mdev = 11.826/12.067/12.289/0.190 ms
> ```
> 
> - **ttl=118:** Time To Live restant (nombre de sauts possibles)
> - **time=12.3 ms:** latence aller-retour
> - **0% packet loss:** aucun paquet perdu
> - **rtt:** statistiques de temps de réponse (min/moyen/max/écart-type)

#### 🔧 Options avancées

```bash
# Ping avec taille de paquet personnalisée
ping -s 1400 8.8.8.8  # 1400 bytes de données

# Ping flood (test de charge, nécessite root)
sudo ping -f 8.8.8.8

# Ping avec timestamp
ping -D 8.8.8.8

# Ping avec source IP spécifique
ping -I 192.168.1.100 8.8.8.8
ping -I eth0 8.8.8.8  # Via interface spécifique

# Ping sans résolution DNS
ping -n 8.8.8.8

# Ping avec pattern de données spécifique
ping -p ff 8.8.8.8  # Remplir avec 0xff
```

> [!warning] Limitations de ping
> 
> - Certains pare-feu bloquent les paquets ICMP, rendant ping inefficace
> - Un ping réussi ne garantit pas que les services applicatifs fonctionnent
> - Le ping flood peut être considéré comme une attaque DoS

> [!tip] Diagnostic avec ping
> 
> - **100% packet loss:** problème de connectivité ou pare-feu
> - **Latence élevée (>100ms):** congestion réseau ou liaison lente
> - **TTL faible (<30):** destination très éloignée ou boucle de routage
> - **Perte intermittente:** problème de stabilité réseau ou matériel défaillant

---

### traceroute - Traçage de route

`traceroute` identifie le chemin réseau entre votre machine et une destination en affichant tous les routeurs intermédiaires.

#### 🎯 Utilisation basique

```bash
# Traceroute basique
traceroute 8.8.8.8
traceroute google.com

# Traceroute IPv6
traceroute6 2001:4860:4860::8888

# Traceroute avec résolution DNS désactivée
traceroute -n 8.8.8.8

# Limiter le nombre de sauts
traceroute -m 15 8.8.8.8  # Maximum 15 sauts
```

> [!example] Sortie typique
> 
> ```
> traceroute to 8.8.8.8 (8.8.8.8), 30 hops max, 60 byte packets
>  1  192.168.1.1 (192.168.1.1)  1.234 ms  1.567 ms  1.890 ms
>  2  10.0.0.1 (10.0.0.1)  8.123 ms  8.456 ms  8.789 ms
>  3  * * *
>  4  72.14.213.114 (72.14.213.114)  15.234 ms  15.567 ms  15.890 ms
>  5  8.8.8.8 (8.8.8.8)  18.123 ms  18.456 ms  18.789 ms
> ```
> 
> - Chaque ligne représente un saut (routeur)
> - Trois temps sont affichés (trois sondes envoyées)
> - *** * *:** le routeur ne répond pas aux sondes (filtrage ICMP)

#### 🔧 Options avancées

```bash
# Utiliser TCP au lieu d'UDP
sudo traceroute -T 8.8.8.8

# Utiliser ICMP (comme ping)
sudo traceroute -I 8.8.8.8

# Spécifier le port de destination (pour UDP/TCP)
traceroute -p 443 8.8.8.8

# Modifier le nombre de sondes par saut
traceroute -q 1 8.8.8.8  # Une seule sonde

# Définir le TTL initial
traceroute -f 5 8.8.8.8  # Commencer au saut 5

# Spécifier l'interface source
traceroute -i eth0 8.8.8.8

# Utiliser une taille de paquet personnalisée
traceroute 8.8.8.8 1400  # 1400 bytes
```

> [!info] Protocoles de traceroute
> 
> - **UDP (défaut):** envoie des paquets UDP sur des ports élevés
> - **ICMP (-I):** utilise des Echo Request ICMP (comme ping)
> - **TCP (-T):** utilise des paquets TCP SYN, utile quand UDP/ICMP sont bloqués

#### 🎯 Alternative : mtr (My TraceRoute)

`mtr` combine ping et traceroute en mode interactif avec des statistiques continues.

```bash
# Installer mtr si nécessaire
sudo apt install mtr

# Lancer mtr
mtr 8.8.8.8

# Mode non-interactif (rapport)
mtr -r -c 10 8.8.8.8  # 10 cycles

# Mode TCP
mtr -T -P 443 google.com
```

> [!tip] Avantages de mtr
> 
> - Affichage en temps réel des statistiques
> - Détecte les pertes de paquets par saut
> - Plus informatif que traceroute pour diagnostiquer les problèmes intermittents
> - Interface interactive avec tri et filtrage

---

## Outils d'analyse des connexions

### ss - Socket Statistics

`ss` est l'outil moderne pour examiner les sockets réseau. Il remplace `netstat` et est plus rapide et plus complet.

#### 📊 Affichage des connexions

```bash
# Afficher toutes les connexions
ss

# Afficher toutes les connexions TCP
ss -t

# Afficher toutes les connexions UDP
ss -u

# Afficher les sockets en écoute
ss -l

# Afficher toutes les connexions (établies + écoute)
ss -a

# Combinaisons courantes
ss -tuln  # TCP + UDP, écoute, numérique (sans résolution DNS)
ss -tulpn # Avec les processus (nécessite root)
ss -tan   # TCP, tous, numérique
```

> [!example] Sortie typique de ss -tuln
> 
> ```
> Netid  State   Recv-Q Send-Q  Local Address:Port   Peer Address:Port
> tcp    LISTEN  0      128     0.0.0.0:22            0.0.0.0:*
> tcp    LISTEN  0      80      127.0.0.1:3306        0.0.0.0:*
> tcp    ESTAB   0      0       192.168.1.100:22      192.168.1.50:54321
> udp    UNCONN  0      0       0.0.0.0:68            0.0.0.0:*
> ```
> 
> - **LISTEN:** socket en écoute de connexions
> - **ESTAB:** connexion établie
> - **UNCONN:** socket UDP non connecté
> - **Recv-Q/Send-Q:** données en attente dans les buffers

#### 🔍 Filtrage avancé

```bash
# Afficher les connexions sur un port spécifique
ss -tuln sport = :80  # Port source 80
ss -tuln dport = :443 # Port destination 443

# Afficher les connexions vers une IP spécifique
ss dst 8.8.8.8

# Afficher les connexions depuis une IP
ss src 192.168.1.0/24

# Filtrer par état de connexion
ss state established  # Connexions établies
ss state listening    # Sockets en écoute
ss state time-wait    # Connexions en TIME_WAIT

# Combinaisons de filtres
ss -t state established '( dport = :22 or sport = :22 )'
```

> [!tip] États des connexions TCP
> 
> - **LISTEN:** en attente de connexions
> - **SYN-SENT:** tentative de connexion en cours
> - **SYN-RECV:** réception d'une demande de connexion
> - **ESTABLISHED:** connexion active
> - **FIN-WAIT-1/2:** fermeture en cours
> - **TIME-WAIT:** attente après fermeture
> - **CLOSE-WAIT:** attente de fermeture locale
> - **CLOSED:** socket fermé

#### 📊 Statistiques et informations détaillées

```bash
# Afficher les statistiques résumées
ss -s

# Afficher les informations détaillées (timer, mémoire)
ss -e

# Afficher les informations de congestion TCP
ss -i

# Afficher les statistiques par socket
ss -m

# Tout afficher avec maximum de détails
ss -tulpnei
```

> [!example] Statistiques avec ss -s
> 
> ```
> Total: 1200
> TCP:   45 (estab 12, closed 25, orphaned 0, timewait 8)
> UDP:   18
> RAW:   0
> FRAG:  0
> ```

#### 🎯 Cas d'usage pratiques

```bash
# Trouver quel processus écoute sur un port
sudo ss -tulpn | grep :80

# Lister toutes les connexions SSH actives
ss -t state established '( dport = :22 or sport = :22 )'

# Compter le nombre de connexions par état
ss -tan | awk '{print $1}' | sort | uniq -c

# Surveiller les nouvelles connexions en temps réel
watch -n 1 'ss -tuln | grep ESTAB'

# Identifier les connexions consommant le plus de bande passante
ss -ti
```

---

### netstat - Network Statistics

`netstat` est l'outil historique d'analyse réseau. Bien que remplacé par `ss`, il reste largement utilisé et connu.

> [!warning] Outil obsolète `netstat` fait partie du paquet `net-tools` qui n'est plus maintenu activement. Privilégiez `ss` pour les nouvelles tâches. Cependant, `netstat` reste disponible sur la plupart des systèmes et sa connaissance est utile.

#### 📊 Affichage des connexions

```bash
# Afficher toutes les connexions
netstat -a

# Afficher les connexions TCP
netstat -t

# Afficher les connexions UDP
netstat -u

# Afficher les sockets en écoute
netstat -l

# Combinaisons courantes
netstat -tuln  # TCP + UDP, écoute, numérique
netstat -tulpn # Avec les processus (nécessite root)
netstat -tan   # TCP, tous, numérique
```

#### 📈 Tables de routage et statistiques

```bash
# Afficher la table de routage
netstat -r
netstat -rn  # Version numérique (sans résolution DNS)

# Afficher les statistiques par protocole
netstat -s

# Statistiques pour un protocole spécifique
netstat -st  # TCP uniquement
netstat -su  # UDP uniquement

# Afficher les interfaces réseau
netstat -i

# Statistiques détaillées des interfaces
netstat -ie
```

> [!example] Statistiques avec netstat -s
> 
> ```
> Tcp:
>     12345 active connection openings
>     6789 passive connection openings
>     123 failed connection attempts
>     45 connection resets received
>     67 connections established
>     890123 segments received
>     765432 segments sent out
>     234 segments retransmitted
> ```

#### 🔍 Filtrage et recherche

```bash
# Rechercher les connexions sur un port
netstat -tuln | grep :80

# Afficher uniquement les connexions ESTABLISHED
netstat -tun | grep ESTABLISHED

# Compter les connexions par état
netstat -tan | awk '{print $6}' | sort | uniq -c

# Afficher les connexions avec leur processus
sudo netstat -tulpn | grep LISTEN
```

#### 📊 Comparaison netstat vs ss

|Fonctionnalité|netstat|ss|
|---|---|---|
|**Vitesse**|Lent sur beaucoup de connexions|Très rapide|
|**Maintenance**|Obsolète (net-tools)|Actif (iproute2)|
|**Filtrage**|Limité (via grep/awk)|Natif et puissant|
|**Informations**|Basiques|Détaillées (timer, mémoire, congestion)|
|**Syntaxe**|Simple et connue|Plus complexe mais plus flexible|

> [!tip] Migration de netstat vers ss
> 
> - `netstat -tuln` → `ss -tuln`
> - `netstat -tulpn` → `ss -tulpn`
> - `netstat -r` → `ip route`
> - `netstat -i` → `ip -s link`
> - `netstat -s` → `ss -s`

---

## Outils de gestion réseau

### nmcli - NetworkManager CLI

`nmcli` est l'interface en ligne de commande de NetworkManager, le gestionnaire réseau standard sur la plupart des distributions Linux modernes (desktop et serveur).

> [!info] Quand utiliser nmcli NetworkManager est idéal pour les postes de travail et les serveurs qui changent fréquemment de réseau. Pour les serveurs de production avec configuration statique, les fichiers de configuration manuels (dans `/etc/network/interfaces` ou `/etc/systemd/network/`) sont souvent préférés.

#### 📊 Affichage de l'état réseau

```bash
# Afficher l'état général du réseau
nmcli general status
nmcli g

# Afficher toutes les connexions
nmcli connection show
nmcli c s  # Version courte

# Afficher les détails d'une connexion
nmcli connection show "Wired connection 1"

# Afficher toutes les interfaces (devices)
nmcli device status
nmcli d

# Afficher les détails d'une interface
nmcli device show eth0
```

> [!example] Sortie de nmcli connection show
> 
> ```
> NAME                UUID                                  TYPE      DEVICE
> Wired connection 1  5fb06bd0-0bb0-7ffb-45f1-d6edd65f3e03  ethernet  eth0
> WiFi Home           6ab04cd1-1cc1-8ggc-56g2-e7fee76g4f14  wifi      wlan0
> ```

#### 🔧 Gestion des connexions

```bash
# Créer une connexion avec IP statique
nmcli connection add \
  con-name "eth0-static" \
  ifname eth0 \
  type ethernet \
  ip4 192.168.1.100/24 \
  gw4 192.168.1.1

# Créer une connexion DHCP
nmcli connection add \
  con-name "eth0-dhcp" \
  ifname eth0 \
  type ethernet \
  ipv4.method auto

# Modifier une connexion existante
nmcli connection modify "eth0-static" ipv4.addresses 192.168.1.150/24
nmcli connection modify "eth0-static" ipv4.gateway 192.168.1.254
nmcli connection modify "eth0-static" ipv4.dns "8.8.8.8 8.8.4.4"

# Activer/Désactiver une connexion
nmcli connection up "eth0-static"
nmcli connection down "eth0-static"

# Recharger les connexions
nmcli connection reload

# Supprimer une connexion
nmcli connection delete "eth0-old"
```

> [!tip] Nommage des connexions Le **con-name** est le nom de la configuration NetworkManager (peut être changé), tandis que **ifname** est le nom de l'interface physique (doit correspondre au système). Une même interface peut avoir plusieurs connexions configurées.

#### 🌐 Configuration DNS et routes

```bash
# Définir les serveurs DNS
nmcli connection modify "eth0-static" ipv4.dns "8.8.8.8 8.8.4.4"

# Ajouter un serveur DNS supplémentaire
nmcli connection modify "eth0-static" +ipv4.dns "1.1.1.1"

# Ajouter une route statique
nmcli connection modify "eth0-static" +ipv4.routes "10.0.0.0/8 192.168.1.254"

# Ne jamais utiliser cette connexion comme route par défaut
nmcli connection modify "eth0-static" ipv4.never-default yes
```

#### 🔌 Gestion des interfaces

```bash
# Activer/Désactiver une interface
nmcli device connect eth0
nmcli device disconnect eth0

# Réactiver WiFi/networking
nmcli radio wifi on
nmcli networking on

# Scanner les réseaux WiFi disponibles
nmcli device wifi list

# Se connecter à un réseau WiFi
nmcli device wifi connect "SSID" password "motdepasse"
```

#### 🎯 Mode interactif

```bash
# Lancer l'éditeur interactif
nmcli connection edit "eth0-static"

# Dans l'éditeur :
# - print             : afficher la configuration
# - set ipv4.addresses 192.168.1.100/24
# - save              : sauvegarder
# - activate          : activer la connexion
# - quit              : quitter
```

> [!tip] Debugging avec nmcli
> 
> ```bash
> # Voir les logs NetworkManager en temps réel
> journalctl -u NetworkManager -f
> 
> # Vérifier pourquoi une connexion échoue
> nmcli connection show "eth0-static" | grep -i error
> 
> # Tester la connectivité d'une interface
> nmcli device status
> nmcli -f GENERAL,IP4,IP6 device show eth0
> ```

#### 📝 Configuration avancée

```bash
# Définir la métrique d'une connexion (priorité)
nmcli connection modify "eth0-static" ipv4.route-metric 100

# Configurer IPv6
nmcli connection modify "eth0-static" ipv6.method auto
nmcli connection modify "eth0-static" ipv6.addresses "2001:db8::100/64"
nmcli connection modify "eth0-static" ipv6.gateway "2001:db8::1"

# Ignorer DNS automatique (DHCP)
nmcli connection modify "eth0-dhcp" ipv4.ignore-auto-dns yes
nmcli connection modify "eth0-dhcp" ipv4.dns "8.8.8.8"

# Cloner l'adresse MAC
nmcli connection modify "eth0-static" 802-3-ethernet.cloned-mac-address "00:11:22:33:44:55"

# Configuration d'un VLAN
nmcli connection add \
  type vlan \
  con-name vlan100 \
  ifname eth0.100 \
  dev eth0 \
  id 100 \
  ip4 192.168.100.10/24
```

> [!warning] Persistance des changements Les modifications avec `nmcli` sont **persistantes** et survivent aux redémarrages. Les fichiers de configuration sont stockés dans `/etc/NetworkManager/system-connections/`.

---

### ifconfig - Configuration d'interface (obsolète)

`ifconfig` est l'outil historique de configuration des interfaces réseau. Il fait partie du paquet `net-tools` qui n'est plus maintenu.

> [!warning] Outil obsolète `ifconfig` est **déprécié** depuis plus de 10 ans. Utilisez `ip addr` et `ip link` à la place. Cette section est fournie uniquement pour référence et compatibilité avec d'anciens systèmes ou scripts.

#### 📊 Affichage des interfaces

```bash
# Afficher toutes les interfaces actives
ifconfig

# Afficher toutes les interfaces (y compris DOWN)
ifconfig -a

# Afficher une interface spécifique
ifconfig eth0

# Afficher uniquement les statistiques
ifconfig -s
```

> [!example] Sortie typique d'ifconfig
> 
> ```
> eth0: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
>         inet 192.168.1.100  netmask 255.255.255.0  broadcast 192.168.1.255
>         inet6 fe80::20c:29ff:fe3a:6f91  prefixlen 64  scopeid 0x20<link>
>         ether 00:0c:29:3a:6f:91  txqueuelen 1000  (Ethernet)
>         RX packets 12345  bytes 8901234 (8.9 MB)
>         RX errors 0  dropped 0  overruns 0  frame 0
>         TX packets 6789  bytes 1234567 (1.2 MB)
>         TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
> ```

#### 🔧 Configuration des interfaces

```bash
# Activer une interface
sudo ifconfig eth0 up

# Désactiver une interface
sudo ifconfig eth0 down

# Assigner une adresse IP
sudo ifconfig eth0 192.168.1.100 netmask 255.255.255.0

# Assigner une adresse IP avec notation CIDR (selon version)
sudo ifconfig eth0 192.168.1.100/24

# Modifier le MTU
sudo ifconfig eth0 mtu 9000

# Modifier l'adresse MAC
sudo ifconfig eth0 hw ether 00:11:22:33:44:55

# Ajouter une adresse IP alias
sudo ifconfig eth0:0 192.168.1.200 netmask 255.255.255.0
```

> [!warning] Changements non persistants Contrairement à `nmcli`, les modifications effectuées avec `ifconfig` sont **temporaires** et perdues au redémarrage. Pour rendre les changements permanents, il faut modifier les fichiers de configuration réseau du système.

#### 📊 Tableau de migration ifconfig vers ip

|Commande ifconfig|Équivalent avec ip|
|---|---|
|`ifconfig`|`ip addr show`|
|`ifconfig -a`|`ip link show`|
|`ifconfig eth0`|`ip addr show dev eth0`|
|`ifconfig eth0 up`|`ip link set eth0 up`|
|`ifconfig eth0 down`|`ip link set eth0 down`|
|`ifconfig eth0 192.168.1.100`|`ip addr add 192.168.1.100/24 dev eth0`|
|`ifconfig eth0 mtu 9000`|`ip link set eth0 mtu 9000`|
|`ifconfig eth0 hw ether XX:XX:XX:XX:XX:XX`|`ip link set eth0 address XX:XX:XX:XX:XX:XX`|
|`ifconfig eth0:0 192.168.1.200`|`ip addr add 192.168.1.200/24 dev eth0 label eth0:0`|

> [!tip] Pourquoi migrer vers ip ?
> 
> - **Performance:** `ip` est plus rapide, surtout sur les systèmes avec beaucoup d'interfaces
> - **Fonctionnalités:** `ip` supporte toutes les fonctionnalités modernes du noyau Linux
> - **Cohérence:** Une seule suite d'outils (`iproute2`) pour tout le réseau
> - **Maintenance:** `net-tools` n'est plus maintenu depuis 2001
> - **Disponibilité:** Les nouvelles distributions n'installent plus `net-tools` par défaut

#### 🔍 Différences importantes

```bash
# ifconfig n'affiche QUE les interfaces UP par défaut
ifconfig          # Interfaces actives uniquement
ifconfig -a       # Toutes les interfaces

# ip affiche TOUTES les interfaces par défaut
ip link show      # Toutes les interfaces
ip link show up   # Seulement les interfaces UP
```

> [!info] Compatibilité Si vous devez maintenir des scripts anciens utilisant `ifconfig`, vous pouvez installer le paquet `net-tools`:
> 
> ```bash
> sudo apt install net-tools  # Debian/Ubuntu
> sudo yum install net-tools  # CentOS/RHEL
> ```

---

## 🎯 Synthèse et bonnes pratiques

### Choix des outils selon le contexte

|Besoin|Outil recommandé|Alternative|
|---|---|---|
|Afficher les adresses IP|`ip addr`|`nmcli device show`|
|Gérer l'état des interfaces|`ip link`|`nmcli device`|
|Gérer les routes|`ip route`|-|
|Tester la connectivité|`ping`|-|
|Tracer le chemin réseau|`mtr`|`traceroute`|
|Analyser les connexions|`ss`|`netstat` (obsolète)|
|Configuration persistante|`nmcli`|Fichiers de config manuels|

### 🔒 Considérations de sécurité

> [!warning] Droits d'administration La plupart des commandes de modification réseau nécessitent les privilèges root (`sudo`). Soyez particulièrement vigilant avec :
> 
> - `ip addr flush` : supprime TOUTES les adresses
> - `ip link set down` : coupe la connectivité
> - `ip route del default` : supprime la passerelle par défaut

### 📋 Workflow de diagnostic typique

Lorsque vous rencontrez un problème réseau, suivez cette méthodologie :

```bash
# 1. Vérifier la configuration locale
ip addr show
ip link show

# 2. Vérifier les routes
ip route show

# 3. Tester la connectivité locale (passerelle)
ping -c 4 192.168.1.1

# 4. Tester la connectivité Internet (DNS)
ping -c 4 8.8.8.8

# 5. Tester la résolution DNS
ping -c 4 google.com

# 6. Analyser le chemin réseau si problème
mtr --report --report-cycles 10 8.8.8.8

# 7. Vérifier les connexions actives
ss -tulpn

# 8. Examiner les logs
journalctl -u NetworkManager -n 50
dmesg | grep -i eth0
```

> [!tip] Diagnostic par élimination Suivez le modèle OSI de bas en haut :
> 
> 1. **Couche physique:** le câble est-il branché ? (`ip link`)
> 2. **Couche liaison:** l'interface est-elle UP ? (`ip link`)
> 3. **Couche réseau:** avez-vous une IP ? (`ip addr`)
> 4. **Routage:** avez-vous une route par défaut ? (`ip route`)
> 5. **Connectivité:** pouvez-vous ping la passerelle ?
> 6. **Internet:** pouvez-vous ping 8.8.8.8 ?
> 7. **DNS:** pouvez-vous résoudre un nom de domaine ?
> 8. **Application:** le service écoute-t-il ? (`ss -tulpn`)

### 🛠️ Commandes utiles pour scripts

```bash
# Obtenir uniquement l'adresse IP principale d'une interface
ip -4 addr show dev eth0 | grep inet | awk '{print $2}' | cut -d'/' -f1 | head -n1

# Vérifier si une interface existe
ip link show dev eth0 &> /dev/null && echo "Existe" || echo "N'existe pas"

# Attendre qu'une interface soit UP
while ! ip link show dev eth0 | grep -q "state UP"; do
    sleep 1
done

# Tester la connectivité en silence (pour scripts)
ping -c 1 -W 2 8.8.8.8 > /dev/null 2>&1 && echo "OK" || echo "KO"

# Compter le nombre de connexions ESTABLISHED
ss -tan state established | wc -l

# Obtenir la passerelle par défaut
ip route | grep default | awk '{print $3}'
```

### ⚡ Astuces de productivité

```bash
# Créer des alias pour les commandes fréquentes
alias ipa='ip -c addr'          # ip addr avec couleurs
alias ipr='ip -c route'         # ip route avec couleurs
alias ports='ss -tulpn'         # ports en écoute
alias myip='ip -4 addr show | grep inet | grep -v 127.0.0.1 | awk "{print \$2}"'

# Surveiller les changements réseau en temps réel
watch -n 1 'ip -c addr show'
watch -n 1 'ss -s'

# Combiner plusieurs diagnostics
{
    echo "=== INTERFACES ==="
    ip -br addr
    echo -e "\n=== ROUTES ==="
    ip route
    echo -e "\n=== DNS ==="
    cat /etc/resolv.conf
    echo -e "\n=== CONNEXIONS ==="
    ss -s
} | less
```

### 📚 Aide-mémoire rapide

```bash
# Affichage
ip a              # Adresses IP
ip l              # Interfaces (état, MAC)
ip r              # Routes
ss -tuln          # Ports en écoute
ss -tulpn         # Ports + processus (root)

# Configuration (temporaire)
sudo ip addr add 192.168.1.100/24 dev eth0
sudo ip link set eth0 up
sudo ip route add default via 192.168.1.1

# Configuration (persistante)
nmcli con mod "eth0" ipv4.addresses 192.168.1.100/24
nmcli con mod "eth0" ipv4.gateway 192.168.1.1
nmcli con up "eth0"

# Diagnostic
ping -c 4 8.8.8.8              # Test connectivité
mtr google.com                 # Trace route interactive
ss state established           # Connexions actives
journalctl -u NetworkManager   # Logs réseau
```

> [!info] Documentation complète Pour approfondir vos connaissances sur ces outils :
> 
> - `man ip`, `man ip-address`, `man ip-link`, `man ip-route`
> - `man ss`
> - `man ping`, `man traceroute`
> - `man nmcli`, `man NetworkManager`
> - Documentation en ligne : https://www.kernel.org/doc/html/latest/networking/

---

## 🎓 Points clés à retenir

✅ **iproute2 (ip) est le standard moderne** - Remplace ifconfig, route, arp ✅ **ss est plus performant que netstat** - Plus rapide et plus complet ✅ **nmcli pour la configuration persistante** - Idéal pour les postes de travail ✅ **ping pour tester, mtr pour diagnostiquer** - Complémentaires ✅ **Les modifications avec ip sont temporaires** - Utilisez nmcli ou les fichiers de config pour la persistance ✅ **Suivre une méthodologie de diagnostic** - De la couche physique vers l'application ✅ **Toujours vérifier les privilèges nécessaires** - Beaucoup de commandes requièrent root

---

_Fin du cours - Configuration réseau Debian - Partie 3 : Outils de diagnostic réseau_