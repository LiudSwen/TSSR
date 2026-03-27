

> [!info] Introduction Les outils de diagnostic réseau sont essentiels pour tout administrateur système et réseau. Ils permettent d'identifier, d'analyser et de résoudre les problèmes de connectivité, de routage et de performance. Ce guide couvre les outils fondamentaux utilisés au quotidien.

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

## 🏓 Ping et Ping6

### Concept fondamental

`ping` est l'outil de diagnostic réseau le plus basique et le plus utilisé. Il envoie des paquets ICMP Echo Request à une destination et attend les réponses ICMP Echo Reply. C'est comme "frapper à la porte" d'une machine distante pour vérifier qu'elle répond.

`ping6` est la variante pour IPv6, utilisant ICMPv6 au lieu d'ICMP.

### Pourquoi l'utiliser ?

- **Vérifier la connectivité** : Est-ce que la machine distante est joignable ?
- **Mesurer la latence** : Quel est le temps de réponse (RTT - Round Trip Time) ?
- **Détecter les pertes de paquets** : Le réseau est-il stable ?
- **Tester la résolution DNS** : En pingant un nom de domaine

### Syntaxe et options

```bash
# Ping basique (IPv4)
ping <adresse_ip_ou_domaine>

# Ping IPv6
ping6 <adresse_ipv6_ou_domaine>
# Ou sur certains systèmes modernes
ping -6 <adresse_ipv6_ou_domaine>

# Options courantes
ping -c 4 google.com              # Envoyer 4 paquets puis s'arrêter (-c = count)
ping -i 2 192.168.1.1             # Intervalle de 2 secondes entre paquets
ping -s 1000 8.8.8.8              # Taille du paquet 1000 octets
ping -W 5 192.168.1.100           # Timeout de 5 secondes
ping -f 10.0.0.1                  # Flood ping (nécessite root, à utiliser avec précaution)
ping -t 64 example.com            # Définir le TTL (Time To Live)

# Ping continu (Ctrl+C pour arrêter)
ping example.com

# Ping avec timestamp
ping -D google.com                # Affiche l'horodatage de chaque réponse
```

> [!example] Exemple pratique
> 
> ```bash
> $ ping -c 4 8.8.8.8
> PING 8.8.8.8 (8.8.8.8) 56(84) bytes of data.
> 64 bytes from 8.8.8.8: icmp_seq=1 ttl=117 time=12.3 ms
> 64 bytes from 8.8.8.8: icmp_seq=2 ttl=117 time=11.8 ms
> 64 bytes from 8.8.8.8: icmp_seq=3 ttl=117 time=12.1 ms
> 64 bytes from 8.8.8.8: icmp_seq=4 ttl=117 time=12.0 ms
> 
> --- 8.8.8.8 ping statistics ---
> 4 packets transmitted, 4 received, 0% packet loss, time 3004ms
> rtt min/avg/max/mdev = 11.802/12.050/12.299/0.186 ms
> ```

### Interprétation des résultats

|Élément|Signification|
|---|---|
|`64 bytes from`|Taille de la réponse reçue|
|`icmp_seq`|Numéro de séquence du paquet|
|`ttl`|Time To Live - nombre de sauts restants|
|`time`|Temps de réponse en millisecondes (RTT)|
|`packet loss`|Pourcentage de paquets perdus|
|`rtt min/avg/max/mdev`|Statistiques : minimum, moyenne, maximum, écart-type|

> [!warning] Pièges courants
> 
> - **Pas de réponse ne signifie pas toujours que la machine est éteinte** : De nombreux pare-feu bloquent les paquets ICMP par sécurité
> - **Le ping peut être trompeur** : Une machine peut être inaccessible pour d'autres services même si elle répond au ping
> - **Flood ping** : Ne jamais utiliser `-f` sur un réseau de production sans autorisation, c'est considéré comme une attaque DoS

> [!tip] Astuces
> 
> - **Tester la résolution DNS** : `ping example.com` teste à la fois DNS et connectivité
> - **Identifier un problème réseau** : Si ping vers IP fonctionne mais pas vers nom de domaine, c'est un problème DNS
> - **Surveillance continue** : `ping -i 60 gateway.local` pour surveiller la connectivité toutes les 60 secondes
> - **Diagnostic de MTU** : `ping -s 1472 -M do <host>` pour tester la taille MTU (1472 + 28 headers = 1500)

### Bonnes pratiques

- Toujours faire un ping vers plusieurs destinations pour isoler le problème (localhost → gateway → DNS public → site externe)
- Utiliser `-c` pour limiter le nombre de paquets dans les scripts
- Ne jamais laisser un ping tourner indéfiniment sur des serveurs de production
- Préférer `ping6` explicitement pour IPv6 plutôt que de compter sur l'auto-détection

---

## 🗺️ Traceroute / Tracert

### Concept fondamental

`traceroute` (Linux/Mac) et `tracert` (Windows) permettent de visualiser le chemin complet qu'emprunte un paquet IP pour atteindre sa destination. L'outil affiche tous les routeurs (sauts) traversés et le temps de réponse pour chacun.

Le principe repose sur l'incrémentation du TTL : le premier paquet a TTL=1 et expire au premier routeur, qui renvoie un message ICMP "Time Exceeded". Le deuxième paquet a TTL=2, etc.

### Pourquoi l'utiliser ?

- **Identifier où se situe un problème** : À quel saut la connexion échoue ou ralentit ?
- **Visualiser la topologie réseau** : Comprendre le chemin emprunté par les paquets
- - **Détecter des boucles de routage** : Si les mêmes routeurs apparaissent plusieurs fois
- **Mesurer la latence par segment** : Identifier les liens lents

### Syntaxe et options

```bash
# Linux/Mac - traceroute
traceroute <destination>
traceroute -I google.com          # Utiliser ICMP au lieu d'UDP
traceroute -T example.com         # Utiliser TCP SYN
traceroute -n 8.8.8.8            # Ne pas résoudre les noms (plus rapide)
traceroute -m 20 target.com      # Maximum 20 sauts
traceroute -w 2 host.local       # Timeout de 2 secondes par saut
traceroute -q 1 example.com      # 1 seule requête par saut (par défaut 3)

# Windows - tracert
tracert <destination>
tracert -d google.com            # Ne pas résoudre les noms
tracert -h 20 example.com        # Maximum 20 sauts
tracert -w 2000 8.8.8.8         # Timeout de 2000 ms

# IPv6
traceroute6 <destination_ipv6>
tracert -6 <destination_ipv6>    # Windows
```

> [!example] Exemple pratique
> 
> ```bash
> $ traceroute -I google.com
> traceroute to google.com (142.250.185.46), 30 hops max, 60 byte packets
>  1  gateway (192.168.1.1)  1.234 ms  1.156 ms  1.089 ms
>  2  10.255.255.1 (10.255.255.1)  8.456 ms  8.392 ms  8.334 ms
>  3  * * *
>  4  72.14.232.85 (72.14.232.85)  12.567 ms  12.501 ms  12.445 ms
>  5  108.170.252.1 (108.170.252.1)  13.234 ms  13.178 ms  13.123 ms
>  6  142.250.185.46 (142.250.185.46)  13.890 ms  12.678 ms  12.567 ms
> ```

### Interprétation des résultats

|Élément|Signification|
|---|---|
|Numéro|Position du routeur dans le chemin (nombre de sauts)|
|Adresse IP|Adresse du routeur intermédiaire|
|Nom d'hôte|Nom DNS du routeur (si résolution activée)|
|3 temps|Temps de réponse pour 3 paquets de test|
|`* * *`|Pas de réponse (timeout) - le routeur ne répond pas ou bloque ICMP|

> [!warning] Pièges courants
> 
> - **Les `* * *` ne signifient pas forcément un blocage** : Beaucoup de routeurs sont configurés pour ne pas répondre aux requêtes traceroute par sécurité
> - **Les temps peuvent fluctuer** : C'est normal, le routage peut changer dynamiquement
> - **Asymétrie du routage** : Le chemin aller peut être différent du chemin retour
> - **Windows vs Linux** : `tracert` (Windows) utilise ICMP par défaut, `traceroute` (Linux) utilise UDP par défaut, ce qui peut donner des résultats différents

> [!tip] Astuces
> 
> - **Comparer plusieurs protocoles** : Essayez `-I` (ICMP), `-T` (TCP), et UDP par défaut pour voir si certains sont bloqués
> - **Utiliser `-n` pour accélérer** : La résolution DNS peut considérablement ralentir traceroute
> - **Identifier un FAI** : Les noms d'hôtes des routeurs contiennent souvent des informations sur le fournisseur
> - **Détecter un changement de route** : Lancer plusieurs traceroutes espacés dans le temps

### Bonnes pratiques

- Exécuter plusieurs traceroutes successifs pour confirmer les résultats (le routage peut varier)
- Utiliser `-n` dans les scripts pour éviter les ralentissements dus au DNS
- Combiner avec ping pour confirmer les problèmes identifiés
- Noter que certains réseaux bloquent complètement traceroute pour des raisons de sécurité

---

## 🔍 Nslookup / Dig

### Concept fondamental

`nslookup` et `dig` sont des outils d'interrogation DNS (Domain Name System). Ils permettent de traduire des noms de domaine en adresses IP et inversement, ainsi que d'interroger divers types d'enregistrements DNS.

`dig` (Domain Information Groper) est plus puissant et plus flexible que `nslookup`, qui est considéré comme déprécié sur de nombreux systèmes Linux mais reste très utilisé sur Windows.

### Pourquoi les utiliser ?

- **Résoudre des noms de domaine** : Obtenir l'adresse IP d'un domaine
- **Vérifier les enregistrements DNS** : MX (mail), NS (nameservers), TXT (SPF, DKIM), etc.
- **Diagnostiquer des problèmes DNS** : Serveur DNS défaillant, propagation incomplète
- **Tester différents serveurs DNS** : Comparer les réponses de plusieurs serveurs
- **Effectuer des recherches inversées** : Trouver le nom de domaine à partir d'une IP

### Syntaxe et options

#### Nslookup

```bash
# Requête simple
nslookup example.com

# Spécifier un serveur DNS
nslookup example.com 8.8.8.8

# Mode interactif
nslookup
> server 1.1.1.1          # Changer de serveur DNS
> set type=MX             # Définir le type d'enregistrement
> example.com             # Effectuer la requête
> exit

# Requêtes spécifiques
nslookup -type=MX example.com       # Enregistrements mail
nslookup -type=NS example.com       # Serveurs de noms
nslookup -type=TXT example.com      # Enregistrements texte
nslookup -type=A example.com        # Adresses IPv4
nslookup -type=AAAA example.com     # Adresses IPv6
nslookup -type=SOA example.com      # Start of Authority
nslookup -type=CNAME www.example.com # Alias

# Recherche inversée
nslookup 8.8.8.8
```

#### Dig (recommandé pour Linux)

```bash
# Requête simple
dig example.com

# Requête courte (juste la réponse)
dig example.com +short

# Spécifier un serveur DNS
dig @8.8.8.8 example.com
dig @1.1.1.1 example.com

# Types d'enregistrements
dig example.com A           # IPv4
dig example.com AAAA        # IPv6
dig example.com MX          # Mail servers
dig example.com NS          # Name servers
dig example.com TXT         # Text records
dig example.com SOA         # Start of Authority
dig example.com CNAME       # Canonical name
dig example.com ANY         # Tous les enregistrements (souvent désactivé)

# Recherche inversée
dig -x 8.8.8.8

# Options avancées
dig example.com +trace      # Trace complète depuis les root servers
dig example.com +noall +answer  # Afficher seulement la section answer
dig example.com +tcp        # Utiliser TCP au lieu d'UDP
dig example.com +dnssec     # Interroger avec DNSSEC
```

> [!example] Exemple pratique avec dig
> 
> ```bash
> $ dig google.com +short
> 142.250.185.46
> 
> $ dig google.com MX +short
> 10 smtp.google.com.
> 
> $ dig @8.8.8.8 example.com
> 
> ; <<>> DiG 9.18.1 <<>> @8.8.8.8 example.com
> ; (1 server found)
> ;; global options: +cmd
> ;; Got answer:
> ;; ->>HEADER<<- opcode: QUERY, status: NOERROR, id: 12345
> ;; flags: qr rd ra; QUERY: 1, ANSWER: 1, AUTHORITY: 0, ADDITIONAL: 1
> 
> ;; QUESTION SECTION:
> ;example.com.			IN	A
> 
> ;; ANSWER SECTION:
> example.com.		86400	IN	A	93.184.216.34
> 
> ;; Query time: 23 msec
> ;; SERVER: 8.8.8.8#53(8.8.8.8)
> ;; WHEN: Fri Dec 12 10:30:00 CET 2025
> ;; MSG SIZE  rcvd: 56
> ```

### Interprétation des résultats (dig)

|Section|Signification|
|---|---|
|`HEADER`|Informations sur la requête (statut, flags)|
|`QUESTION`|La question posée au serveur DNS|
|`ANSWER`|La réponse du serveur (les enregistrements demandés)|
|`AUTHORITY`|Les serveurs DNS faisant autorité pour ce domaine|
|`ADDITIONAL`|Informations supplémentaires (adresses des NS)|
|`Query time`|Temps de réponse du serveur DNS|
|`SERVER`|Le serveur DNS interrogé|

#### Flags importants

- `qr` : Query Response - c'est une réponse
- `rd` : Recursion Desired - récursion demandée
- `ra` : Recursion Available - récursion disponible
- `aa` : Authoritative Answer - réponse faisant autorité

#### Status codes

- `NOERROR` : Succès
- `NXDOMAIN` : Le domaine n'existe pas
- `SERVFAIL` : Échec du serveur DNS
- `REFUSED` : Le serveur refuse de répondre

> [!warning] Pièges courants
> 
> - **Cache DNS** : Les résultats peuvent être en cache, ne reflétant pas les modifications récentes
> - **Propagation DNS** : Les changements DNS peuvent prendre jusqu'à 48h pour se propager mondialement
> - **TTL** : Le Time To Live indique combien de temps l'enregistrement sera en cache
> - **Différences entre serveurs** : Différents serveurs DNS peuvent renvoyer des résultats différents pendant la propagation

> [!tip] Astuces
> 
> - **Vider le cache DNS local** :
>     - Linux : `sudo systemd-resolve --flush-caches` ou `sudo resolvectl flush-caches`
>     - Windows : `ipconfig /flushdns`
>     - Mac : `sudo dscacheutil -flushcache`
> - **Tester plusieurs serveurs DNS** : Comparez `@8.8.8.8` (Google), `@1.1.1.1` (Cloudflare), `@9.9.9.9` (Quad9)
> - **Trace complète** : `dig +trace example.com` pour voir le processus de résolution complet depuis les root servers
> - **Format court pour scripts** : `dig +short` ne renvoie que les adresses IP
> - **Vérifier DNSSEC** : `dig +dnssec example.com` pour voir si le domaine est sécurisé

### Bonnes pratiques

- Préférer `dig` à `nslookup` sur Linux pour des fonctionnalités avancées
- Toujours spécifier le serveur DNS (`@serveur`) lors de tests pour éviter les confusions dues au cache
- Utiliser `+short` dans les scripts pour simplifier le parsing
- Documenter le TTL lors de changements DNS pour prévoir le temps de propagation
- Vérifier plusieurs serveurs DNS géographiquement distribués lors de mises à jour importantes

---

## 🔗 ARP et IP Neigh

### Concept fondamental

ARP (Address Resolution Protocol) est un protocole de la couche 2 (liaison de données) qui permet de faire la correspondance entre une adresse IP (couche 3) et une adresse MAC (couche 2) sur un réseau local.

`arp` est l'outil traditionnel pour manipuler le cache ARP. `ip neigh` (neighbor) est son équivalent moderne faisant partie de la suite `iproute2`, plus puissant et recommandé sur les systèmes Linux récents.

### Pourquoi les utiliser ?

- **Résoudre des problèmes de connectivité locale** : Vérifier que les machines communiquent correctement au niveau MAC
- **Détecter des conflits d'adresses IP** : Plusieurs machines avec la même IP
- **Identifier les équipements sur le réseau local** : Lister les machines actives
- **Diagnostiquer des problèmes de routage local** : Vérifier que la passerelle est accessible
- **Sécurité réseau** : Détecter du spoofing ARP ou des comportements suspects

### Syntaxe et options

#### Commande arp (traditionnelle)

```bash
# Afficher le cache ARP
arp
arp -a                    # Format alternatif (BSD-style)
arp -n                    # Ne pas résoudre les noms (plus rapide)

# Afficher une entrée spécifique
arp 192.168.1.1
arp -a 192.168.1.1

# Ajouter une entrée statique (nécessite root)
sudo arp -s 192.168.1.100 00:11:22:33:44:55

# Supprimer une entrée
sudo arp -d 192.168.1.100

# Afficher par interface
arp -i eth0
```

#### Commande ip neigh (moderne, recommandée)

```bash
# Afficher toutes les entrées neighbor
ip neigh
ip neigh show

# Afficher pour une interface spécifique
ip neigh show dev eth0

# Afficher pour une adresse spécifique
ip neigh show 192.168.1.1

# Ajouter une entrée statique permanente
sudo ip neigh add 192.168.1.100 lladdr 00:11:22:33:44:55 dev eth0 nud permanent

# Ajouter une entrée temporaire
sudo ip neigh add 192.168.1.100 lladdr 00:11:22:33:44:55 dev eth0 nud reachable

# Supprimer une entrée
sudo ip neigh del 192.168.1.100 dev eth0

# Vider le cache (flush)
sudo ip neigh flush dev eth0
sudo ip neigh flush all      # Toutes les interfaces
```

> [!example] Exemple pratique
> 
> ```bash
> $ ip neigh show
> 192.168.1.1 dev eth0 lladdr a4:12:42:8e:f3:21 REACHABLE
> 192.168.1.50 dev eth0 lladdr 00:1b:63:84:45:e6 STALE
> fe80::a612:42ff:fe8e:f321 dev eth0 lladdr a4:12:42:8e:f3:21 router REACHABLE
> 192.168.1.105 dev eth0  FAILED
> 
> $ arp -n
> Address         HWtype  HWaddress           Flags Mask      Iface
> 192.168.1.1     ether   a4:12:42:8e:f3:21   C               eth0
> 192.168.1.50    ether   00:1b:63:84:45:e6   C               eth0
> ```

### États des entrées (NUD - Neighbor Unreachability Detection)

|État|Signification|
|---|---|
|`PERMANENT`|Entrée statique, ne peut pas expirer|
|`NOARP`|Entrée valide, aucune tentative de validation|
|`REACHABLE`|Entrée valide et récemment confirmée|
|`STALE`|Entrée valide mais non confirmée récemment, sera vérifiée à la prochaine utilisation|
|`DELAY`|Un paquet a été envoyé, en attente de confirmation|
|`PROBE`|Envoi de sondes pour vérifier l'accessibilité|
|`FAILED`|La résolution a échoué, l'hôte n'est pas accessible|
|`INCOMPLETE`|Résolution en cours, pas encore de réponse|

> [!warning] Pièges courants
> 
> - **Cache obsolète** : Les entrées STALE peuvent être anciennes et ne plus correspondre à la réalité
> - **FAILED ne signifie pas toujours hors ligne** : L'hôte peut avoir un pare-feu bloquant ARP
> - **Entrées fantômes** : Des machines déconnectées peuvent rester dans le cache pendant plusieurs minutes
> - **ARP spoofing** : Un attaquant peut polluer le cache ARP pour détourner le trafic (attaque man-in-the-middle)

> [!tip] Astuces
> 
> - **Forcer une mise à jour** : `sudo ip neigh flush all && ping -c 1 <ip>` pour régénérer les entrées
> - **Surveiller en temps réel** : `watch -n 1 'ip neigh'` pour voir l'évolution du cache
> - **Identifier la passerelle** : `ip route | grep default` puis vérifier son entrée dans `ip neigh`
> - **Diagnostic de conflit IP** : Si une IP apparaît avec deux MAC différentes, c'est un conflit
> - **Vérifier IPv6** : `ip -6 neigh` pour les voisins IPv6

### Différences arp vs ip neigh

|Caractéristique|arp|ip neigh|
|---|---|---|
|Modernité|Déprécié|Recommandé|
|Fonctionnalités|Basiques|Avancées|
|États détaillés|Non|Oui (NUD states)|
|IPv6|Non|Oui|
|Filtrage|Limité|Flexible|
|Performance|Correcte|Meilleure|

### Bonnes pratiques

- Utiliser `ip neigh` plutôt que `arp` sur les systèmes Linux modernes
- Ne jamais ajouter d'entrées statiques sans raison valable (automatisation, tests)
- Vider le cache ARP après des changements matériels sur le réseau
- Surveiller les entrées FAILED lors de diagnostics de connectivité
- Utiliser des outils comme `arpwatch` pour détecter les anomalies (ARP spoofing)
- Dans les scripts, parser `ip -json neigh` pour une sortie structurée

---

## 📊 Netstat / SS

### Concept fondamental

`netstat` (network statistics) et `ss` (socket statistics) sont des outils d'analyse des connexions réseau, des sockets et des statistiques d'interfaces. Ils affichent les connexions actives, les ports en écoute, les tables de routage et diverses métriques réseau.

`ss` est l'outil moderne qui remplace `netstat` sur les systèmes Linux récents. Il est plus rapide, plus puissant et mieux maintenu.

### Pourquoi les utiliser ?

- **Identifier les connexions actives** : Qui est connecté à quoi ?
- **Vérifier les ports ouverts** : Quels services écoutent sur quels ports ?
- **Diagnostiquer des problèmes de connexion** : Identifier les connexions en attente, fermées ou bloquées
- **Surveiller l'utilisation réseau** : Statistiques par interface et par protocole
- **Sécurité** : Détecter des connexions suspectes ou non autorisées
- **Déboguer des applications** : Voir quels processus utilisent quels ports

### Syntaxe et options

#### Commande netstat (traditionnelle)

```bash
# Afficher toutes les connexions
netstat -a                # Toutes les connexions et sockets en écoute
netstat -at               # Toutes les connexions TCP
netstat -au               # Toutes les connexions UDP

# Afficher les connexions actives uniquement
netstat -t                # Connexions TCP établies
netstat -u                # Connexions UDP

# Afficher les ports en écoute
netstat -l                # Sockets en écoute
netstat -lt               # Ports TCP en écoute
netstat -lu               # Ports UDP en écoute
netstat -lx               # Sockets Unix en écoute

# Options de formatage
netstat -n                # Afficher IP numériques (pas de résolution DNS)
netstat -p                # Afficher le PID et nom du processus (nécessite root)
netstat -e                # Informations étendues (utilisateur, etc.)
netstat -c                # Mode continu (rafraîchissement automatique)

# Combinaisons courantes
netstat -tuln             # TCP+UDP, ports en écoute, numérique (très utilisé)
netstat -tulnp            # Idem + processus (commande la plus courante)
netstat -an               # Toutes les connexions en format numérique

# Statistiques
netstat -s                # Statistiques par protocole
netstat -i                # Statistiques par interface
netstat -r                # Table de routage (équivalent à route -n)

# Windows
netstat -ano              # Toutes connexions + PID (Windows)
netstat -b                # Avec nom exécutable (nécessite admin, Windows)
```

#### Commande ss (moderne, recommandée)

```bash
# Afficher toutes les connexions
ss -a                     # Toutes les sockets
ss -at                    # Toutes les sockets TCP
ss -au                    # Toutes les sockets UDP

# Afficher les connexions actives
ss -t                     # Connexions TCP établies
ss -u                     # Connexions UDP

# Afficher les ports en écoute
ss -l                     # Sockets en écoute
ss -lt                    # Ports TCP en écoute
ss -lu                    # Ports UDP en écoute
ss -lx                    # Sockets Unix en écoute

# Options importantes
ss -n                     # Format numérique (pas de résolution)
ss -p                     # Afficher les processus (nécessite root)
ss -e                     # Informations étendues
ss -m                     # Informations mémoire des sockets
ss -o                     # Informations sur les timers

# Combinaisons courantes
ss -tulnp                 # TCP+UDP, écoute, numérique + processus (LA commande)
ss -tanp                  # TCP, toutes, numérique + processus
ss -s                     # Statistiques résumées

# Filtres puissants
ss state established      # Connexions établies seulement
ss state listening        # Ports en écoute seulement
ss -t state time-wait     # Connexions TCP en TIME_WAIT

# Filtrer par port
ss -t sport = :80         # Connexions TCP avec port source 80
ss -t dport = :443        # Connexions TCP avec port destination 443
ss -t '( dport = :80 or dport = :443 )'  # Port 80 OU 443

# Filtrer par adresse
ss dst 192.168.1.100      # Destination spécifique
ss src 10.0.0.0/8         # Source dans un réseau

# Informations avancées
ss -ti                    # Informations TCP internes (retransmissions, RTT, etc.)
ss -tei                   # Encore plus d'infos (congestion window, etc.)
```

> [!example] Exemple pratique avec ss
> 
> ```bash
> $ ss -tulnp
> Netid State   Recv-Q Send-Q Local Address:Port  Peer Address:Port Process
> tcp   LISTEN  0      128    0.0.0.0:22          0.0.0.0:*     users:(("sshd",pid=1234,fd=3))
> tcp   LISTEN  0      128    0.0.0.0:80          0.0.0.0:*     users:(("nginx",pid=5678,fd=6))
> tcp   ESTAB   0      0      192.168.1.10:22    192.168.1.50:54321 users:(("sshd",pid=9012,fd=4))
> udp   UNCONN  0      0      0.0.0.0:68          0.0.0.0:*     users:(("dhclient",pid=456,fd=5))
> 
> $ ss -ti state established
> Recv-Q Send-Q Local Address:Port   Peer Address:Port Process
> 0      0      192.168.1.10:443    93.184.216.34:52841
>          cubic wscale:7,7 rto:204 rtt:3.5/1.5 ato:40 mss:1460 pmtu:1500 
>          rcvmss:1460 advmss:1460 cwnd:10 bytes_sent:2456 bytes_retrans:0
>          bytes_acked:2456 segs_out:15 segs_in:12 send 33.1Mbps lastsnd:1234
> ```

### Interprétation des résultats

#### Colonnes principales

|Colonne|Signification|
|---|---|
|`Netid`|Type de socket (tcp, udp, unix, raw)|
|`State`|État de la connexion (LISTEN, ESTAB, TIME-WAIT, etc.)|
|`Recv-Q`|Octets en attente de lecture par l'application|
|`Send-Q`|Octets en attente d'envoi|
|`Local Address:Port`|Adresse et port local|
|`Peer Address:Port`|Adresse et port distant|
|`Process`|PID et nom du processus (avec -p)|

#### États TCP importants

|État|Signification|
|---|---|
|`LISTEN`|Port en écoute, attend des connexions|
|`ESTABLISHED`|Connexion active et établie|
|`SYN-SENT`|Tentative de connexion active en cours|
|`SYN-RECV`|Connexion passive en cours d'établissement|
|`FIN-WAIT-1/2`|Fermeture de connexion initiée localement|
|`CLOSE-WAIT`|Fermeture de connexion initiée par le distant|
|`TIME-WAIT`|Connexion fermée, en attente de sécurité (2*MSL)|
|`CLOSED`|Connexion fermée|

> [!warning] Pièges courants
> 
> - **Recv-Q élevé** : L'application ne lit pas assez vite → problème de performance applicative
> - **Send-Q élevé** : Le réseau est lent ou congestionné → problème réseau
> - **Trop de TIME-WAIT** : Peut saturer les ports disponibles sur des serveurs à fort trafic
> - **CLOSE-WAIT accumulés** : L'application ne ferme pas correctement les connexions → bug applicatif
> - **0.0.0.0 vs 127.0.0.1** : `0.0.0.0` écoute sur toutes les interfaces, `127.0.0.1` uniquement en local

> [!tip] Astuces
> 
> - **Trouver qui utilise un port** : `ss -tulnp | grep :80` ou `ss -tulnp '( sport = :80 )'`
> - **Surveiller en temps réel** : `watch -n 1 'ss -s'` pour voir l'évolution des statistiques
> - **Compter les connexions** : `ss -tan | wc -l` pour le nombre total
> - **Identifier les plus actifs** : `ss -tunp | awk '{print $6}' | sort | uniq -c | sort -rn`
> - **Vérifier si un port est libre** : `ss -tuln | grep :8080` (aucun résultat = port libre)
> - **Export JSON** : Certaines versions récentes de ss supportent `ss -j` pour sortie JSON

### Différences netstat vs ss

|Caractéristique|netstat|ss|
|---|---|---|
|Performance|Lent sur systèmes chargés|Rapide (utilise netlink)|
|Modernité|Déprécié|Recommandé|
|Filtrage|Basique (grep)|Intégré et puissant|
|Informations TCP|Limitées|Détaillées (RTT, cwnd, etc.)|
|Maintenance|Minimale|Active|
|Disponibilité|Partout|Linux récents|

### Commandes pratiques combinées

```bash
# Trouver quel processus utilise le port 80
sudo ss -tulnp | grep :80
sudo netstat -tulnp | grep :80

# Voir toutes les connexions établies vers un serveur web
ss -tn state established '( dport = :80 or dport = :443 )'

# Compter les connexions par état
ss -tan | awk '{print $2}' | sort | uniq -c

# Identifier les IP qui se connectent le plus
ss -tn | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -rn | head

# Vérifier les connexions d'un processus spécifique
ss -tp | grep nginx

# Afficher les connexions avec retransmissions
ss -ti | grep -i retrans

# Lister tous les services en écoute avec leur nom
sudo ss -tulnp | column -t
```

> [!warning] Sécurité **Connexions suspectes à surveiller :**
> 
> - Connexions vers des ports inhabituels (surtout > 1024)
> - Trop de connexions SYN-RECV → possible attaque SYN flood
> - Connexions vers des IPs étrangères depuis des services internes
> - Ports en écoute sur 0.0.0.0 qui ne devraient pas être exposés
> - Processus inconnus avec des connexions réseau actives

### Bonnes pratiques

- Utiliser `ss` plutôt que `netstat` sur Linux moderne pour de meilleures performances
- Toujours utiliser `-n` pour éviter les ralentissements dus à la résolution DNS
- Combiner avec `-p` pour identifier rapidement les processus responsables (nécessite root)
- Surveiller régulièrement l'état TIME-WAIT sur les serveurs haute charge
- Automatiser la surveillance avec des scripts qui alertent sur des anomalies
- Utiliser les filtres de `ss` plutôt que `grep` pour de meilleures performances
- Sur Windows, privilégier `netstat -ano` puis `tasklist` pour identifier les processus

---

## 🦈 Wireshark

### Concept fondamental

Wireshark est un analyseur de protocoles réseau (packet sniffer) graphique et open-source. Il capture le trafic réseau en temps réel et permet d'analyser en détail chaque paquet, de la couche 2 (Ethernet) jusqu'à la couche 7 (application).

C'est l'outil de référence pour le diagnostic réseau avancé, l'analyse de protocoles, le débogage d'applications réseau et l'investigation de sécurité.

### Pourquoi l'utiliser ?

- **Diagnostic approfondi** : Voir exactement ce qui transite sur le réseau, octet par octet
- **Analyse de protocoles** : Comprendre comment fonctionnent réellement les protocoles (HTTP, DNS, TCP, etc.)
- **Débogage d'applications** : Identifier les problèmes de communication entre client et serveur
- **Analyse de performance** : Détecter les retransmissions, latences, problèmes de fenêtrage TCP
- **Sécurité réseau** : Détecter des attaques, du trafic malveillant, des fuites de données
- **Apprentissage** : Comprendre concrètement le fonctionnement des réseaux

### Installation

```bash
# Linux (Debian/Ubuntu)
sudo apt update
sudo apt install wireshark

# Autoriser les utilisateurs non-root à capturer (recommandé)
sudo dpkg-reconfigure wireshark-common  # Répondre 'Yes'
sudo usermod -aG wireshark $USER        # Ajouter votre utilisateur au groupe
# Se déconnecter et reconnecter pour appliquer

# Linux (RedHat/CentOS)
sudo yum install wireshark wireshark-gnome

# macOS
brew install --cask wireshark

# Windows
# Télécharger depuis https://www.wireshark.org/download.html
# Installer WinPcap ou Npcap lors de l'installation
```

### Interface graphique - Éléments principaux

```
┌─────────────────────────────────────────────────────────────┐
│ Fichier  Édition  Affichage  Aller  Capturer  Analyser  ... │
├─────────────────────────────────────────────────────────────┤
│ [▶ Start] [⏹ Stop]  Interface: eth0 ▼   Filtre: http       │
├─────────────────────────────────────────────────────────────┤
│ Liste des paquets capturés (Packet List)                    │
│ No. Time    Source         Dest          Protocol  Info     │
│ 1   0.000   192.168.1.10   8.8.8.8       DNS       Query    │
│ 2   0.023   8.8.8.8        192.168.1.10  DNS       Response │
├─────────────────────────────────────────────────────────────┤
│ Détails du paquet sélectionné (Packet Details)              │
│ ▶ Frame 1: 74 bytes on wire                                 │
│ ▶ Ethernet II                                               │
│ ▼ Internet Protocol Version 4                               │
│   ▶ Source: 192.168.1.10                                    │
│   ▶ Destination: 8.8.8.8                                    │
│ ▶ User Datagram Protocol                                    │
│ ▶ Domain Name System (query)                                │
├─────────────────────────────────────────────────────────────┤
│ Contenu brut du paquet (Packet Bytes)                       │
│ 0000  00 11 22 33 44 55 66 77 88 99 aa bb 08 00 45 00      │
│ 0010  00 3c 1c 46 40 00 40 11 b1 e6 c0 a8 01 0a 08 08      │
└─────────────────────────────────────────────────────────────┘
```

### Filtres de capture (Capture Filters)

Les filtres de capture utilisent la syntaxe BPF (Berkeley Packet Filter) et s'appliquent **avant** la capture pour réduire la quantité de données capturées.

```bash
# Protocoles
tcp                          # Capturer uniquement TCP
udp                          # Capturer uniquement UDP
icmp                         # Capturer uniquement ICMP
arp                          # Capturer uniquement ARP

# Hôtes
host 192.168.1.100           # Trafic depuis ou vers cette IP
src host 192.168.1.100       # Trafic depuis cette IP
dst host 192.168.1.100       # Trafic vers cette IP

# Réseaux
net 192.168.1.0/24           # Trafic du réseau 192.168.1.0/24
src net 10.0.0.0/8           # Trafic depuis le réseau 10.0.0.0/8

# Ports
port 80                      # Port 80 (source ou destination)
src port 443                 # Port source 443
dst port 53                  # Port destination 53
portrange 8000-9000          # Plage de ports

# Combinaisons (avec and, or, not)
tcp and port 80              # TCP sur port 80
host 192.168.1.100 and tcp   # TCP depuis/vers cette IP
not broadcast and not multicast  # Exclure broadcast/multicast
tcp port 80 or tcp port 443  # HTTP ou HTTPS
```

### Filtres d'affichage (Display Filters)

Les filtres d'affichage s'appliquent **après** la capture et permettent de filtrer l'affichage sans perdre de données. Syntaxe plus riche et intuitive.

#### Filtres de base

```bash
# Protocoles
ip                           # Tout paquet IP
ipv6                         # Tout paquet IPv6
tcp                          # Tout paquet TCP
udp                          # Tout paquet UDP
dns                          # Tout paquet DNS
http                         # Tout paquet HTTP
tls                          # Tout paquet TLS/SSL
arp                          # Tout paquet ARP

# Adresses IP
ip.addr == 192.168.1.100     # IP source ou destination
ip.src == 192.168.1.100      # IP source
ip.dst == 8.8.8.8            # IP destination

# Ports TCP/UDP
tcp.port == 80               # Port 80 (source ou destination)
tcp.srcport == 443           # Port source 443
tcp.dstport == 22            # Port destination 22
udp.port == 53               # UDP port 53

# Flags TCP
tcp.flags.syn == 1           # Paquets SYN
tcp.flags.ack == 1           # Paquets ACK
tcp.flags.reset == 1         # Paquets RST
tcp.flags.fin == 1           # Paquets FIN
```

#### Filtres avancés

```bash
# HTTP spécifique
http.request.method == "GET"        # Requêtes GET
http.request.method == "POST"       # Requêtes POST
http.response.code == 200           # Réponses HTTP 200
http.response.code >= 400           # Erreurs HTTP (4xx, 5xx)
http.host == "example.com"          # Requêtes vers ce domaine
http.user_agent contains "Mozilla"  # User-Agent contenant Mozilla

# DNS
dns.qry.name == "google.com"        # Requêtes DNS pour google.com
dns.flags.response == 1             # Réponses DNS uniquement
dns.qry.type == 1                   # Requêtes de type A (IPv4)

# TCP analyse
tcp.analysis.retransmission         # Retransmissions TCP
tcp.analysis.duplicate_ack          # ACK dupliqués
tcp.analysis.lost_segment           # Segments perdus
tcp.analysis.window_full            # Fenêtre TCP pleine
tcp.stream eq 5                     # Suivre le stream TCP #5

# Taille de paquets
frame.len > 1000                    # Paquets > 1000 octets
ip.len < 100                        # Paquets IP < 100 octets

# Temps
frame.time >= "2025-12-12 10:00:00" # Paquets après cette heure
frame.time_delta > 1                # Délai > 1 seconde depuis dernier paquet

# Combinaisons
ip.addr == 192.168.1.100 && tcp.port == 80
(http.request or tls.handshake.type == 1) and ip.src == 192.168.1.0/24
not arp and not (udp.port == 53)
```

#### Opérateurs

|Opérateur|Signification|Exemple|
|---|---|---|
|`==`|Égal|`ip.src == 192.168.1.1`|
|`!=`|Différent|`tcp.port != 80`|
|`>` `<` `>=` `<=`|Comparaisons|`frame.len > 1000`|
|`contains`|Contient|`http.host contains "google"`|
|`matches`|Regex|`http.host matches ".*\.com$"`|
|`&&` ou `and`|ET logique|`tcp && http`|
|`\|` ou `or`|OU logique|`tcp.port == 80 or tcp.port == 443`|
|`!` ou `not`|NON logique|`not arp`|
|`in`|Dans un ensemble|`tcp.port in {80 443 8080}`|

> [!example] Exemples pratiques de filtres
> 
> ```bash
> # Voir uniquement les requêtes HTTP GET vers un site
> http.request.method == "GET" && http.host == "example.com"
> 
> # Identifier les problèmes TCP
> tcp.analysis.flags
> 
> # Suivre une conversation complète
> ip.addr == 192.168.1.100 && tcp.port == 443
> # Puis clic droit > Follow > TCP Stream
> 
> # Détecter des scans de ports
> tcp.flags.syn == 1 && tcp.flags.ack == 0
> 
> # Trouver des transferts de gros fichiers
> http.content_length > 1000000
> 
> # Analyse DNS
> dns && ip.dst == 8.8.8.8
> ```

### Fonctionnalités avancées

#### 1. Follow Stream (Suivre le flux)

Permet de voir la conversation complète entre deux hôtes.

```
Clic droit sur un paquet > Follow > TCP Stream / UDP Stream / HTTP Stream
```

Affiche la conversation entière de manière lisible, très utile pour :

- Voir les requêtes/réponses HTTP complètes
- Analyser des protocoles textuels (SMTP, FTP, etc.)
- Détecter des fuites de données en clair

#### 2. Statistiques réseau

```
Menu : Statistics > ...

- Summary : Résumé de la capture
- Protocol Hierarchy : Distribution des protocoles
- Conversations : Conversations entre hôtes
- Endpoints : Liste des hôtes actifs
- IO Graph : Graphique du trafic dans le temps
- Flow Graph : Diagramme de séquence
```

#### 3. Expert Information

```
Menu : Analyze > Expert Information
```

Wireshark analyse automatiquement le trafic et signale :

- ⚠️ **Warnings** : Retransmissions, ACK dupliqués
- 🔴 **Errors** : Problèmes graves (checksums, segments manquants)
- 💬 **Notes** : Informations utiles
- 💡 **Chats** : Événements normaux

#### 4. Export d'objets

```
Menu : File > Export Objects > HTTP / DICOM / SMB / TLS
```

Permet d'extraire les fichiers transférés via HTTP, SMB, etc.

### Ligne de commande - TShark

TShark est la version ligne de commande de Wireshark, très utile pour les scripts et l'automatisation.

```bash
# Capturer sur une interface
sudo tshark -i eth0

# Capturer avec un filtre
sudo tshark -i eth0 -f "tcp port 80"

# Lire un fichier de capture
tshark -r capture.pcap

# Appliquer un filtre d'affichage
tshark -r capture.pcap -Y "http.request"

# Afficher des champs spécifiques
tshark -r capture.pcap -T fields -e ip.src -e ip.dst -e tcp.port

# Statistiques
tshark -r capture.pcap -q -z conv,tcp     # Conversations TCP
tshark -r capture.pcap -q -z io,stat,1    # IO statistiques par seconde

# Capturer dans un fichier
sudo tshark -i eth0 -w capture.pcap

# Capturer avec rotation de fichiers
sudo tshark -i eth0 -w capture.pcap -b filesize:100000 -b files:5
```

> [!warning] Pièges courants
> 
> - **Captures volumineuses** : Wireshark peut consommer énormément de RAM avec de grosses captures (>1GB)
> - **Interfaces promiscuité** : Sur un switch moderne, vous ne verrez que votre propre trafic (pas de hub)
> - **Trafic chiffré** : HTTPS/TLS ne peut pas être déchiffré sans les clés privées
> - **Performance** : La capture peut ralentir le système sur des réseaux à haut débit
> - **Permissions** : Capturer nécessite des droits root ou l'appartenance au groupe wireshark
> - **VLAN** : Le trafic VLAN peut ne pas être visible selon la configuration

> [!tip] Astuces professionnelles
> 
> - **Colorier les paquets** : View > Coloring Rules pour faciliter l'analyse visuelle
> - **Créer des profils** : Créer des profils avec filtres et colonnes personnalisés par cas d'usage
> - **Sauvegarder les filtres** : Bookmarker les filtres complexes fréquemment utilisés
> - **Utiliser les colonnes** : Personnaliser les colonnes affichées (Edit > Preferences > Columns)
> - **Captures ring buffer** : `-b filesize:10000 -b files:10` pour capturer en continu sans saturer le disque
> - **Comparaison** : Comparer deux captures pour identifier les différences de comportement
> - **Décryptage SSL/TLS** : Configurer les clés dans Edit > Preferences > Protocols > TLS
> - **Macros** : Utiliser `${variable}` dans les filtres pour réutilisation

### Cas d'usage pratiques

#### Diagnostiquer une lenteur web

1. Capturer le trafic HTTP/HTTPS
2. Filtrer : `http || tls`
3. Statistiques > HTTP > Requests pour voir les temps de réponse
4. Identifier les requêtes lentes
5. Analyser les retransmissions TCP (`tcp.analysis.retransmission`)

#### Détecter une attaque

1. Vérifier les SYN flood : filtre `tcp.flags.syn==1 && tcp.flags.ack==0`
2. Compter les tentatives : Statistics > Conversations
3. Identifier les IPs sources suspectes
4. Analyser le pattern temporel avec IO Graph

#### Déboguer une API REST

1. Capturer : filtre `host api.example.com`
2. Follow HTTP Stream sur une requête
3. Vérifier les headers (Authorization, Content-Type)
4. Examiner le JSON envoyé/reçu
5. Vérifier les codes de réponse HTTP

#### Analyser DNS

1. Filtre : `dns`
2. Vérifier les requêtes : `dns.qry.name`
3. Chercher les NXDOMAIN : `dns.flags.rcode == 3`
4. Mesurer les temps de réponse
5. Identifier les serveurs DNS utilisés

### Bonnes pratiques

- **Toujours utiliser des filtres de capture** pour limiter la taille des fichiers
- **Capturer dans des fichiers temporaires** avec rotation pour éviter la saturation
- **Anonymiser les captures** avant de les partager (`TraceWrangler` ou option de Wireshark)
- **Documenter les captures** : ajouter un commentaire avec le contexte (File > Capture File Properties)
- **Ne jamais capturer en production sans autorisation** : risques légaux et de sécurité
- **Chiffrer les captures sensibles** : elles peuvent contenir des données confidentielles
- **Apprendre les filtres progressivement** : commencer simple, complexifier au besoin
- **Utiliser tshark pour l'automatisation** : plus efficace que l'interface graphique pour les tâches répétitives

---

## 🎯 Résumé des outils

|Outil|Usage principal|Quand l'utiliser|
|---|---|---|
|`ping/ping6`|Test connectivité basique|Première étape de tout diagnostic|
|`traceroute/tracert`|Visualiser le chemin réseau|Identifier où un problème se situe|
|`nslookup/dig`|Interroger DNS|Problèmes de résolution de noms|
|`arp/ip neigh`|Cache ARP local|Problèmes de communication locale|
|`netstat/ss`|Connexions et ports actifs|Voir qui écoute et qui est connecté|
|`wireshark`|Analyse détaillée des paquets|Diagnostic avancé, débogage protocoles|

> [!tip] Méthodologie de diagnostic **Approche en couches (bottom-up) :**
> 
> 1. **Couche physique** : Câbles, interfaces (`ip link`, `ethtool`)
> 2. **Couche liaison** : ARP, switches (`ip neigh`, `arp`)
> 3. **Couche réseau** : IP, routage (`ping`, `traceroute`, `ip route`)
> 4. **Couche transport** : TCP/UDP (`ss`, `netstat`, Wireshark)
> 5. **Couche application** : HTTP, DNS (`dig`, `curl`, Wireshark)
> 
> **Partir du simple vers le complexe** : commencer par `ping`, puis progresser vers `wireshark` si nécessaire.

---

## 📚 Ressources et références

- **Documentation officielle** : `man ping`, `man ss`, `man dig`
- **RFC** : RFC 792 (ICMP), RFC 1035 (DNS), RFC 826 (ARP)
- **Wireshark** : https://www.wireshark.org/docs/
- **Packet analysis** : https://packetlife.net/

> [!success] Compétences acquises Après avoir maîtrisé ces outils, vous êtes capable de :
> 
> - ✅ Diagnostiquer efficacement les problèmes de connectivité
> - ✅ Identifier rapidement la source d'un problème réseau
> - ✅ Analyser le trafic réseau en profondeur
> - ✅ Comprendre le fonctionnement réel des protocoles
> - ✅ Sécuriser et surveiller votre infrastructure réseau