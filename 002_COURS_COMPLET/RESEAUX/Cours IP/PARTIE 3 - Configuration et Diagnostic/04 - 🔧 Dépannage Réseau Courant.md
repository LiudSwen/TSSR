

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

## 🔍 Vérification de la connectivité locale

### Principe et importance

La vérification de la connectivité locale consiste à s'assurer que votre machine peut communiquer avec d'autres équipements sur le même réseau local (LAN). C'est la **première étape** de tout diagnostic réseau car si la connectivité locale échoue, aucune communication distante ne sera possible.

> [!info] Pourquoi commencer par le local ? Diagnostiquer du bas vers le haut permet d'isoler rapidement le problème : est-ce un problème de configuration locale, de réseau local, ou d'accès Internet ?

### Test de la boucle locale (loopback)

```bash
# Ping de l'interface loopback (127.0.0.1)
ping 127.0.0.1

# Ou en IPv6
ping ::1
```

> [!tip] Que teste cette commande ? Elle vérifie que la pile TCP/IP de votre système fonctionne correctement. Si ce test échoue, le problème est au niveau du système d'exploitation lui-même.

### Test de l'interface réseau locale

```bash
# Afficher votre adresse IP locale
ip addr show
# Ou sur des systèmes plus anciens
ifconfig

# Ping de votre propre adresse IP
ping 192.168.1.100  # Remplacer par votre IP réelle
```

> [!example] Exemple de sortie
> 
> ```
> PING 192.168.1.100 (192.168.1.100) 56(84) bytes of data.
> 64 bytes from 192.168.1.100: icmp_seq=1 ttl=64 time=0.045 ms
> ```

### Test de connectivité vers un autre hôte local

```bash
# Ping d'une autre machine sur votre réseau
ping 192.168.1.1  # Généralement votre routeur/box

# Test avec un nombre limité de paquets
ping -c 4 192.168.1.1

# Test continu (Ctrl+C pour arrêter)
ping 192.168.1.1
```

> [!warning] Échec de connectivité locale Si vous ne pouvez pas pinguer d'autres machines locales, vérifiez :
> 
> - Le câble réseau (pour connexion filaire)
> - Le signal WiFi (pour connexion sans fil)
> - La configuration de l'interface réseau
> - Les pare-feux locaux qui pourraient bloquer ICMP

### Vérification de la table ARP

```bash
# Afficher la table ARP (mappage IP ↔ MAC)
ip neigh show
# Ou
arp -a

# Effacer le cache ARP (peut résoudre certains problèmes)
sudo ip neigh flush all
```

> [!info] Qu'est-ce que la table ARP ? Elle associe les adresses IP aux adresses MAC physiques des équipements. Si un équipement n'apparaît pas dans cette table, votre machine ne peut pas communiquer avec lui au niveau Ethernet.

### Tests avancés de connectivité locale

```bash
# Test de connectivité avec arping (niveau 2 OSI)
sudo arping -I eth0 192.168.1.1  # Spécifier l'interface

# Scan du réseau local avec nmap
sudo nmap -sn 192.168.1.0/24  # Découverte d'hôtes

# Trace de la route locale
traceroute 192.168.1.1
```

> [!tip] Astuce professionnelle Utilisez `mtr` (My TraceRoute) pour un diagnostic en temps réel combinant ping et traceroute :
> 
> ```bash
> mtr 192.168.1.1
> ```

---

## 🌐 Problèmes de passerelle par défaut

### Principe et rôle de la passerelle

La **passerelle par défaut** (default gateway) est l'équipement (généralement votre routeur/box) qui permet à votre machine de communiquer avec des réseaux extérieurs, notamment Internet. C'est le "point de sortie" de votre réseau local.

> [!info] Analogie Pensez à la passerelle comme à la porte de sortie d'un bâtiment : sans elle, vous restez confiné à l'intérieur (réseau local) sans pouvoir accéder à l'extérieur (Internet).

### Identification de la passerelle par défaut

```bash
# Méthode 1 : avec ip route
ip route show
# La ligne contenant "default via" indique la passerelle

# Méthode 2 : avec route
route -n

# Méthode 3 : extraction directe de la passerelle
ip route | grep default | awk '{print $3}'
```

> [!example] Exemple de sortie
> 
> ```
> default via 192.168.1.1 dev eth0 proto dhcp metric 100
> 192.168.1.0/24 dev eth0 proto kernel scope link src 192.168.1.100
> ```
> 
> Ici, la passerelle est **192.168.1.1**

### Test de la passerelle

```bash
# Test de connectivité vers la passerelle
ping 192.168.1.1  # Remplacer par votre passerelle

# Test avec traceroute pour voir le chemin
traceroute 8.8.8.8  # Le premier saut doit être votre passerelle
```

> [!warning] Symptômes d'un problème de passerelle
> 
> - Vous pouvez pinguer des machines locales mais pas Internet
> - La commande `ping 8.8.8.8` échoue
> - Message "Network is unreachable"

### Configuration manuelle de la passerelle

#### Configuration temporaire

```bash
# Ajouter une passerelle par défaut
sudo ip route add default via 192.168.1.1

# Supprimer une passerelle par défaut existante
sudo ip route del default

# Remplacer la passerelle par défaut
sudo ip route replace default via 192.168.1.1 dev eth0
```

#### Configuration permanente (selon la distribution)

**Sur Ubuntu/Debian avec Netplan :**

```yaml
# /etc/netplan/01-network-manager-all.yaml
network:
  version: 2
  ethernets:
    eth0:
      addresses:
        - 192.168.1.100/24
      routes:
        - to: default
          via: 192.168.1.1
      nameservers:
        addresses: [8.8.8.8, 1.1.1.1]
```

```bash
# Appliquer la configuration
sudo netplan apply
```

**Sur Red Hat/CentOS :**

```bash
# /etc/sysconfig/network-scripts/ifcfg-eth0
GATEWAY=192.168.1.1
```

### Diagnostic des problèmes de passerelle

```bash
# Vérifier si la passerelle répond
ping -c 4 192.168.1.1

# Vérifier la table de routage complète
ip route show table all

# Vérifier les statistiques de l'interface
ip -s link show eth0

# Tester la connectivité au-delà de la passerelle
ping 8.8.8.8  # Si ça fonctionne, la passerelle est OK
```

> [!tip] Métrique de route Si plusieurs passerelles sont configurées, la métrique détermine laquelle est utilisée en priorité. Une métrique plus faible = priorité plus haute :
> 
> ```bash
> ip route add default via 192.168.1.1 metric 100
> ip route add default via 192.168.2.1 metric 200
> ```

### Problèmes courants

|Problème|Cause|Solution|
|---|---|---|
|Pas de passerelle configurée|Configuration DHCP échouée|Configurer manuellement ou relancer DHCP|
|Passerelle inaccessible|Problème physique ou de configuration|Vérifier câbles, redémarrer le routeur|
|Mauvaise passerelle configurée|Erreur de configuration|Corriger l'adresse IP de la passerelle|
|Plusieurs passerelles en conflit|Configuration manuelle + DHCP|Désactiver l'une des méthodes|

> [!warning] Piège courant Attention à ne pas confondre l'adresse de la passerelle avec celle de votre machine. La passerelle doit être sur le même réseau (même sous-réseau) que votre interface réseau.

---

## 🔤 Problèmes DNS

### Principe du DNS

Le **DNS** (Domain Name System) traduit les noms de domaine lisibles par l'homme (comme `google.com`) en adresses IP utilisables par les machines (comme `142.250.180.46`). Sans DNS fonctionnel, vous ne pouvez accéder aux sites qu'en utilisant directement leur adresse IP.

> [!info] Pourquoi le DNS est critique Même si votre connectivité réseau fonctionne parfaitement, un DNS défaillant vous empêche d'accéder à la plupart des services Internet par leur nom.

### Test de résolution DNS

```bash
# Test basique de résolution
ping google.com  # Si ça échoue mais ping 8.8.8.8 fonctionne → problème DNS

# Test avec nslookup
nslookup google.com

# Test avec dig (plus détaillé)
dig google.com

# Test avec host
host google.com
```

> [!example] Exemple avec dig
> 
> ```bash
> dig google.com
> 
> # Sortie (extrait) :
> ;; ANSWER SECTION:
> google.com.    300    IN    A    142.250.180.46
> 
> ;; Query time: 23 msec
> ;; SERVER: 8.8.8.8#53(8.8.8.8)
> ```

### Vérification de la configuration DNS

```bash
# Afficher les serveurs DNS configurés
cat /etc/resolv.conf

# Afficher la configuration DNS détaillée
resolvectl status
# Ou sur systèmes plus anciens
systemd-resolve --status
```

> [!example] Contenu typique de /etc/resolv.conf
> 
> ```
> nameserver 8.8.8.8
> nameserver 1.1.1.1
> search example.com
> ```

### Test de serveurs DNS spécifiques

```bash
# Tester un serveur DNS spécifique avec nslookup
nslookup google.com 8.8.8.8  # Google DNS
nslookup google.com 1.1.1.1  # Cloudflare DNS

# Tester avec dig
dig @8.8.8.8 google.com
dig @1.1.1.1 google.com

# Comparer les temps de réponse
dig google.com | grep "Query time"
```

### Configuration temporaire du DNS

```bash
# Modifier temporairement /etc/resolv.conf
sudo nano /etc/resolv.conf

# Ajouter des serveurs DNS
nameserver 8.8.8.8
nameserver 1.1.1.1
```

> [!warning] Configuration non persistante Les modifications directes de `/etc/resolv.conf` sont souvent écrasées au redémarrage ou par le gestionnaire de réseau. Utilisez la méthode appropriée à votre système pour une configuration permanente.

### Configuration permanente du DNS

#### Avec Netplan (Ubuntu moderne)

```yaml
# /etc/netplan/01-network-manager-all.yaml
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: yes
      nameservers:
        addresses: [8.8.8.8, 1.1.1.1]
        search: [example.com]
```

```bash
sudo netplan apply
```

#### Avec systemd-resolved

```bash
# Configurer globalement
sudo nano /etc/systemd/resolved.conf

# Ajouter :
[Resolve]
DNS=8.8.8.8 1.1.1.1
FallbackDNS=8.8.4.4 1.0.0.1

# Redémarrer le service
sudo systemctl restart systemd-resolved
```

#### Avec NetworkManager

```bash
# Configuration via nmcli
nmcli connection modify "Wired connection 1" ipv4.dns "8.8.8.8 1.1.1.1"
nmcli connection up "Wired connection 1"

# Vérifier
nmcli device show eth0 | grep DNS
```

### Diagnostic avancé DNS

```bash
# Tracer la résolution DNS complète
dig +trace google.com

# Afficher uniquement la réponse courte
dig +short google.com

# Tester tous les types d'enregistrements
dig google.com ANY

# Vérifier les enregistrements MX (mail)
dig google.com MX

# Vérifier la résolution inverse
dig -x 8.8.8.8
```

> [!tip] Cache DNS Vider le cache DNS peut résoudre certains problèmes :
> 
> ```bash
> # Avec systemd-resolved
> sudo systemd-resolve --flush-caches
> 
> # Avec nscd
> sudo /etc/init.d/nscd restart
> 
> # Redémarrer NetworkManager
> sudo systemctl restart NetworkManager
> ```

### Serveurs DNS publics populaires

|Fournisseur|DNS Primaire|DNS Secondaire|Caractéristique|
|---|---|---|---|
|Google|8.8.8.8|8.8.4.4|Rapide, fiable|
|Cloudflare|1.1.1.1|1.0.0.1|Axé sur la vie privée|
|Quad9|9.9.9.9|149.112.112.112|Blocage de malware|
|OpenDNS|208.67.222.222|208.67.220.220|Contrôle parental|

### Problèmes DNS courants

> [!warning] Symptômes de problèmes DNS
> 
> - Les commandes `ping google.com` échouent mais `ping 8.8.8.8` fonctionne
> - Navigation web impossible mais ping d'IP fonctionne
> - Messages "server not found" ou "unable to resolve host"
> - Lenteur importante lors de l'accès aux sites web

**Solutions selon les cas :**

```bash
# Cas 1 : Pas de serveur DNS configuré
# Vérifier /etc/resolv.conf et ajouter des serveurs DNS

# Cas 2 : Serveur DNS lent ou injoignable
# Changer de serveur DNS (utiliser Google ou Cloudflare)

# Cas 3 : Cache DNS corrompu
sudo systemd-resolve --flush-caches

# Cas 4 : Pare-feu bloquant le port 53
sudo ufw allow 53
```

> [!tip] Test de performance DNS Comparez les temps de réponse de différents serveurs DNS :
> 
> ```bash
> for server in 8.8.8.8 1.1.1.1 9.9.9.9; do
>   echo "Testing $server:"
>   dig @$server google.com | grep "Query time"
> done
> ```

---

## ⚠️ Conflits d'adresses IP

### Principe du conflit d'adresse IP

Un **conflit d'adresse IP** survient lorsque deux équipements sur le même réseau tentent d'utiliser la même adresse IP. Cela provoque des dysfonctionnements réseau car le routeur ne sait plus à quel équipement envoyer les paquets.

> [!warning] Impact d'un conflit IP
> 
> - Déconnexions intermittentes
> - Impossibilité de se connecter au réseau
> - Messages d'erreur "duplicate IP address"
> - Performances réseau dégradées

### Détection d'un conflit d'adresse IP

```bash
# Vérifier les logs système pour des alertes de conflit
sudo journalctl | grep -i "duplicate\|conflict"
dmesg | grep -i "duplicate\|conflict"

# Sur certains systèmes, dans /var/log/syslog
sudo grep -i "duplicate" /var/log/syslog

# Afficher votre adresse IP actuelle
ip addr show
```

> [!example] Message typique de conflit
> 
> ```
> kernel: [12345.678] eth0: IPv4 duplicate address 192.168.1.100 detected!
> ```

### Vérification du réseau local

```bash
# Scanner le réseau pour voir les adresses IP utilisées
sudo nmap -sn 192.168.1.0/24

# Vérifier la table ARP pour des doublons
arp -a | sort

# Utiliser arping pour détecter des doublons
sudo arping -D -I eth0 192.168.1.100  # -D = duplicate detection
```

> [!info] Interprétation de arping
> 
> - Aucune réponse : l'adresse est libre
> - Une réponse : l'adresse est utilisée par votre machine
> - Plusieurs réponses : **CONFLIT détecté**

### Identification de l'équipement en conflit

```bash
# Trouver l'adresse MAC de l'équipement en conflit
arp -a | grep "192.168.1.100"

# Obtenir plus d'informations avec nmap
sudo nmap -sP 192.168.1.100

# Scan avancé pour identifier le fabricant
sudo nmap -sS 192.168.1.100
```

> [!tip] Identification du fabricant Les 3 premiers octets de l'adresse MAC identifient le fabricant :
> 
> ```bash
> # Rechercher en ligne sur https://maclookup.app/
> # Ou utiliser une base locale si disponible
> macchanger -l | grep "00:11:22"
> ```

### Résolution du conflit

#### Solution 1 : Libérer et renouveler l'adresse IP (DHCP)

```bash
# Libérer l'adresse IP actuelle
sudo dhclient -r eth0

# Obtenir une nouvelle adresse IP
sudo dhclient eth0

# Ou en une seule commande
sudo dhclient -r eth0 && sudo dhclient eth0
```

#### Solution 2 : Redémarrer l'interface réseau

```bash
# Avec ip
sudo ip link set eth0 down
sudo ip link set eth0 up

# Avec ifconfig (anciennes versions)
sudo ifconfig eth0 down
sudo ifconfig eth0 up

# Avec nmcli
nmcli connection down "Wired connection 1"
nmcli connection up "Wired connection 1"
```

#### Solution 3 : Configurer une adresse IP statique différente

```bash
# Configuration temporaire
sudo ip addr flush dev eth0
sudo ip addr add 192.168.1.150/24 dev eth0
sudo ip route add default via 192.168.1.1

# Configuration permanente (Netplan)
# Éditer /etc/netplan/01-network-manager-all.yaml
```

> [!warning] Choisir une adresse IP statique Assurez-vous que l'adresse choisie :
> 
> - Est dans la plage du réseau (ex: 192.168.1.0/24)
> - N'est PAS dans la plage DHCP du routeur
> - N'est pas déjà utilisée par un autre équipement

### Prévention des conflits

#### Configurer une plage DHCP appropriée

Sur votre routeur/box, configurez le serveur DHCP pour :

- Définir une plage DHCP restreinte (ex: 192.168.1.100 - 192.168.1.200)
- Réserver les adresses en dehors de cette plage pour les IP fixes
- Activer la détection de conflit d'adresse

#### Réservation DHCP

```bash
# Sur le routeur, réserver une IP basée sur l'adresse MAC
# Interface web du routeur → DHCP → Réservation
# MAC: 00:11:22:33:44:55 → IP: 192.168.1.50
```

> [!info] Avantage de la réservation DHCP L'équipement reçoit toujours la même IP via DHCP, évitant ainsi les conflits tout en conservant une gestion centralisée.

#### Surveillance réseau

```bash
# Script de surveillance des conflits
#!/bin/bash
while true; do
  sudo arping -D -I eth0 -c 2 $(ip -4 addr show eth0 | grep -oP '(?<=inet\s)\d+(\.\d+){3}')
  if [ $? -eq 1 ]; then
    echo "ALERTE : Conflit d'adresse IP détecté !"
    # Envoyer une notification ou un email
  fi
  sleep 300  # Vérifier toutes les 5 minutes
done
```

### Cas particuliers

#### Double configuration (statique + DHCP)

```bash
# Identifier si une double configuration existe
ip addr show eth0  # Vérifier si plusieurs IP sont listées

# Supprimer les adresses en trop
sudo ip addr del 192.168.1.100/24 dev eth0

# Désactiver DHCP si vous utilisez une IP statique
sudo systemctl stop dhclient
```

> [!tip] Bonne pratique Choisissez une méthode : DHCP **OU** statique, mais pas les deux simultanément sur la même interface.

#### Conflit entre réseaux VPN

```bash
# Vérifier les plages IP de tous les réseaux
ip addr show  # Voir toutes les interfaces

# Si conflit entre réseau local et VPN
# Modifier la configuration VPN pour utiliser une plage différente
```

### Tableau récapitulatif des causes de conflits

|Cause|Description|Solution|
|---|---|---|
|IP statique dupliquée|Deux machines configurées avec la même IP fixe|Changer l'IP de l'une des machines|
|Plage DHCP mal configurée|DHCP attribue une IP déjà utilisée en statique|Ajuster la plage DHCP ou réserver l'IP|
|Cache DHCP|Serveur DHCP attribue une IP qu'il croit libre|Redémarrer le serveur DHCP|
|Machine éteinte/déconnectée|IP réattribuée puis machine d'origine se reconnecte|Utiliser des réservations DHCP|
|Clonage de VM|Plusieurs VM avec la même IP|Réinitialiser la config réseau des VM|

---

## 🔬 Méthode de diagnostic en couches (OSI)

### Principe de l'approche par couches

Le **modèle OSI** (Open Systems Interconnection) divise la communication réseau en 7 couches. Diagnostiquer méthodiquement couche par couche permet d'identifier précisément où se situe le problème.

> [!info] Pourquoi utiliser cette méthode ? Plutôt que de tester aléatoirement, l'approche en couches garantit un diagnostic systématique, efficace et complet. Vous commencez par les couches basses (physique) et remontez jusqu'aux applications.

### Rappel des 7 couches OSI

|Couche|Nom|Fonction|Exemples|
|---|---|---|---|
|7|Application|Interface utilisateur|HTTP, FTP, SSH, DNS|
|6|Présentation|Format et chiffrement|SSL/TLS, JPEG, ASCII|
|5|Session|Gestion des sessions|NetBIOS, RPC|
|4|Transport|Transmission fiable|TCP, UDP|
|3|Réseau|Routage|IP, ICMP, ARP|
|2|Liaison|Communication sur média|Ethernet, WiFi, MAC|
|1|Physique|Support de transmission|Câbles, ondes radio, bits|

> [!tip] Approche pratique En dépannage réel, on se concentre principalement sur 4 couches : Physique (1), Liaison (2), Réseau (3) et Transport/Application (4/7).

---

### 🔌 Couche 1 : Physique

#### Objectif

Vérifier que le support physique permet la transmission de données.

#### Tests à effectuer

```bash
# Vérifier l'état de l'interface réseau
ip link show eth0

# Rechercher "UP" dans la sortie
# UP = interface activée
# NO-CARRIER = pas de signal physique
```

> [!example] Sortie normale
> 
> ```
> 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP
>     link/ether 00:11:22:33:44:55 brd ff:ff:ff:ff:ff:ff
> ```

```bash
# Vérifier les statistiques d'erreurs physiques
ip -s link show eth0

# ou avec ethtool pour plus de détails
sudo ethtool eth0

# Statistiques d'erreurs
sudo ethtool -S eth0
```

#### Indicateurs de problème physique

- **État DOWN ou NO-CARRIER** : câble débranché, carte réseau défaillante
- **Nombreuses erreurs RX/TX** : câble défectueux, interférences
- **Vitesse anormale** : autonégociation échouée

> [!warning] Problèmes physiques courants
> 
> - Câble Ethernet débranché ou endommagé
> - Port réseau défectueux (carte réseau ou switch)
> - Signal WiFi trop faible
> - Pilote de carte réseau manquant ou obsolète

#### Actions correctives

```bash
# Activer l'interface si elle est DOWN
sudo ip link set eth0 up

# Vérifier et installer les pilotes
lspci | grep -i network  # Identifier la carte réseau
sudo lshw -C network     # Informations détaillées

# Recharger le module du pilote
sudo modprobe -r nom_module
sudo modprobe nom_module
```

---

### 🔗 Couche 2 : Liaison de données (Ethernet/WiFi)

#### Objectif

Vérifier que les trames Ethernet sont correctement transmises et que l'adressage MAC fonctionne.

#### Tests à effectuer

```bash
# Vérifier l'adresse MAC de l'interface
ip link show eth0 | grep link/ether

# Afficher la table ARP (mappage IP ↔ MAC)
ip neigh show
arp -a

# Vérifier la connectivité au niveau MAC avec arping
sudo arping -I eth0 192.168.1.1
```

> [!example] Table ARP normale
> 
> ```
> 192.168.1.1 dev eth0 lladdr aa:bb:cc:dd:ee:ff REACHABLE
> 192.168.1.50 dev eth0 lladdr 11:22:33:44:55:66 STALE
> ```

#### Diagnostic des problèmes couche 2

```bash
# Capturer le trafic au niveau trame
sudo tcpdump -i eth0 -e -nn

# Vérifier les erreurs de trame
sudo ethtool -S eth0 | grep -i error

# Test de boucle (loopback) au niveau Ethernet
sudo ethtool -t eth0
```

#### Indicateurs de problème couche 2

- **Table ARP vide ou incomplète** : problème de diffusion broadcast
- **État "FAILED" dans ip neigh** : machine injoignable au niveau MAC
- **Erreurs CRC** : corruption de trames, problème physique

> [!warning] Problèmes courants couche 2
> 
> - Conflit d'adresse MAC (rare)
> - VLAN mal configuré
> - Port de switch bloqué ou en erreur
> - Tempête de broadcast (boucle réseau)

#### Actions correctives

```bash
# Vider et reconstruire la table ARP
sudo ip neigh flush all

# Changer temporairement l'adresse MAC (si nécessaire)
sudo ip link set dev eth0 address 02:01:02:03:04:08

# Redémarrer l'interface pour réinitialiser la couche 2
sudo ip link set eth0 down && sudo ip link set eth0 up
```

---

### 🌐 Couche 3 : Réseau (IP)

#### Objectif

Vérifier la configuration IP et le routage.

#### Tests à effectuer

```bash
# Vérifier la configuration IP
ip addr show eth0

# Vérifier la table de routage
ip route show

# Test de connectivité locale (même sous-réseau)
ping -c 4 192.168.1.1

# Test de connectivité distante (au-delà du routeur)
ping -c 4 8.8.8.8

# Tracer le chemin réseau
traceroute 8.8.8.8
mtr 8.8.8.8  # Version améliorée
```

> [!example] Configuration IP correcte
> 
> ```
> inet 192.168.1.100/24 brd 192.168.1.255 scope global dynamic eth0
> default via 192.168.1.1 dev eth0 proto dhcp metric 100
> ```

#### Diagnostic approfondi couche 3

```bash
# Vérifier le TTL des paquets
ping -c 1 8.8.8.8 | grep ttl

# Analyser les paquets ICMP
sudo tcpdump -i eth0 icmp

# Vérifier la fragmentation
ping -M do -s 1500 8.8.8.8  # -M do = Don't Fragment

# Tester différentes tailles de paquet
ping -s 100 8.8.8.8  # Petit paquet
ping -s 1400 8.8.8.8  # Paquet standard
ping -s 8000 8.8.8.8  # Paquet nécessitant fragmentation
```

#### Indicateurs de problème couche 3

- **Pas d'adresse IP** : DHCP non fonctionnel ou IP statique non configurée
- **Mauvais masque de sous-réseau** : communication locale impossible
- **Pas de passerelle par défaut** : communication Internet impossible
- **TTL expiré** : problème de routage, boucle de routage
- **Destination unreachable** : routage incorrect ou firewall

> [!warning] Problèmes courants couche 3
> 
> - Mauvaise configuration IP (adresse, masque, passerelle)
> - Routage asymétrique
> - Filtrage par pare-feu (firewall)
> - MTU mal configuré causant fragmentation

#### Actions correctives

```bash
# Renouveler l'adresse DHCP
sudo dhclient -r eth0 && sudo dhclient eth0

# Configurer manuellement une IP
sudo ip addr add 192.168.1.100/24 dev eth0
sudo ip route add default via 192.168.1.1

# Vérifier et ajuster le MTU
ip link show eth0 | grep mtu
sudo ip link set dev eth0 mtu 1500

# Vérifier les règles de pare-feu
sudo iptables -L -n -v
sudo ufw status verbose
```

---

### 🚚 Couche 4 : Transport (TCP/UDP)

#### Objectif

Vérifier que les connexions TCP/UDP fonctionnent correctement et que les ports sont accessibles.

#### Tests à effectuer

```bash
# Vérifier les ports en écoute
ss -tuln
# Ou avec netstat
netstat -tuln

# Tester la connectivité vers un port spécifique avec telnet
telnet google.com 80
telnet 8.8.8.8 53

# Tester avec nc (netcat) - plus fiable
nc -zv google.com 80
nc -zv 192.168.1.1 22

# Scanner les ports ouverts
nmap -p 80,443,22 192.168.1.1
```

> [!example] Ports couramment testés
> 
> ```bash
> # HTTP
> nc -zv example.com 80
> # HTTPS
> nc -zv example.com 443
> # SSH
> nc -zv server.com 22
> # DNS
> nc -zvu 8.8.8.8 53  # -u pour UDP
> ```

#### Diagnostic des connexions actives

```bash
# Afficher toutes les connexions actives
ss -tupn
netstat -tupn

# Afficher les statistiques TCP
ss -s

# Afficher les connexions vers un hôte spécifique
ss -tn dst 8.8.8.8

# Vérifier les connexions établies
ss -t state established

# Capturer le trafic TCP sur un port
sudo tcpdump -i eth0 'tcp port 80'
```

> [!info] États de connexion TCP
> 
> - **LISTEN** : port en écoute, attend des connexions
> - **ESTABLISHED** : connexion active et établie
> - **TIME_WAIT** : connexion fermée, en attente de timeout
> - **SYN_SENT** : tentative de connexion en cours
> - **CLOSE_WAIT** : fermeture de connexion initiée

#### Analyse d'une connexion TCP

```bash
# Capturer le three-way handshake TCP
sudo tcpdump -i eth0 'tcp[tcpflags] & (tcp-syn) != 0'

# Afficher les retransmissions (signe de problème)
sudo tcpdump -i eth0 'tcp[tcpflags] & (tcp-rst) != 0'

# Analyser les performances TCP
ss -ti  # Informations détaillées incluant RTT, cwnd, etc.
```

#### Indicateurs de problème couche 4

- **Port fermé** : service non démarré ou firewall bloquant
- **Connection refused** : port actif mais connexion rejetée
- **Connection timeout** : aucune réponse, filtrage ou routage défaillant
- **Nombreuses retransmissions** : perte de paquets, latence élevée

> [!warning] Problèmes courants couche 4
> 
> - Pare-feu bloquant les ports
> - Service non démarré sur le serveur
> - Mauvaise configuration de port forwarding (NAT)
> - Limite de connexions atteinte
> - Problème de fenêtre TCP (TCP window)

#### Actions correctives

```bash
# Vérifier qu'un service écoute sur le bon port
sudo ss -tlnp | grep :80

# Démarrer un service si nécessaire
sudo systemctl start apache2
sudo systemctl start ssh

# Autoriser un port dans le pare-feu
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Vérifier les règles iptables
sudo iptables -L INPUT -n -v | grep dpt:80
```

---

### 📱 Couches 5-7 : Session, Présentation, Application

#### Objectif

Vérifier que les applications et protocoles fonctionnent correctement.

> [!info] Approche pratique En pratique, ces 3 couches sont souvent testées ensemble car elles concernent le fonctionnement des applications elles-mêmes.

#### Tests HTTP/HTTPS

```bash
# Test avec curl
curl -I https://google.com  # Afficher les en-têtes HTTP
curl -v https://google.com  # Mode verbeux

# Test de certificat SSL/TLS
openssl s_client -connect google.com:443

# Vérifier la validité du certificat
echo | openssl s_client -connect google.com:443 2>/dev/null | openssl x509 -noout -dates

# Test avec wget
wget --spider https://google.com
```

> [!example] Réponse HTTP normale
> 
> ```
> HTTP/2 200
> content-type: text/html; charset=ISO-8859-1
> date: Sat, 13 Dec 2025 10:00:00 GMT
> server: gws
> ```

#### Tests DNS (déjà vu mais critique pour couche 7)

```bash
# Test de résolution complète
dig google.com +trace

# Vérifier tous les types d'enregistrements
dig google.com ANY

# Mesurer le temps de résolution
time nslookup google.com
```

#### Tests SSH

```bash
# Test de connectivité SSH
ssh -v user@server  # Mode verbeux pour diagnostic

# Test sans connexion complète
nc -zv server 22

# Afficher la clé publique du serveur
ssh-keyscan server
```

#### Tests Email (SMTP)

```bash
# Test de connectivité SMTP
telnet mail.example.com 25

# Ou avec openssl pour SMTP sécurisé
openssl s_client -connect mail.example.com:587 -starttls smtp

# Test avec nc
nc -v mail.example.com 25
```

#### Tests FTP

```bash
# Test de connexion FTP
ftp ftp.example.com

# Ou avec lftp pour plus d'options
lftp ftp://ftp.example.com

# Test de connectivité
nc -zv ftp.example.com 21
```

#### Indicateurs de problème couches applicatives

- **Erreur 404, 500, 503** : problème applicatif web
- **Certificate error** : certificat SSL invalide ou expiré
- **Authentication failed** : problème d'identifiants
- **Protocol mismatch** : versions incompatibles
- **Timeout applicatif** : application surchargée ou bloquée

> [!warning] Problèmes courants couches application
> 
> - Certificat SSL expiré ou non valide
> - Mauvaise configuration d'application
> - Version de protocole incompatible
> - Proxy mal configuré
> - Authentification échouée

#### Actions correctives

```bash
# Redémarrer un service applicatif
sudo systemctl restart apache2
sudo systemctl restart nginx
sudo systemctl restart ssh

# Vérifier les logs applicatifs
sudo journalctl -u apache2 -f
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/auth.log  # Pour SSH

# Vérifier la configuration
sudo nginx -t  # Tester la config nginx
sudo apache2ctl configtest  # Tester la config apache
```

---

### 🔄 Méthodologie complète de diagnostic

#### Approche descendante (Top-Down)

**Quand l'utiliser** : L'utilisateur signale qu'une application spécifique ne fonctionne pas.

```bash
# Étape 1 : Tester l'application (Couche 7)
curl https://example.com
# ❌ Échec → Continuer

# Étape 2 : Tester le DNS (Couche 7)
nslookup example.com
# ✅ OK → Le DNS fonctionne

# Étape 3 : Tester la connectivité TCP (Couche 4)
nc -zv example.com 443
# ❌ Échec → Continuer

# Étape 4 : Tester la connectivité IP (Couche 3)
ping example.com
# ❌ Échec → Continuer

# Étape 5 : Tester la passerelle (Couche 3)
ping 192.168.1.1
# ✅ OK → Le problème est entre la passerelle et Internet

# Conclusion : Problème de routage ou FAI
```

#### Approche ascendante (Bottom-Up)

**Quand l'utiliser** : Aucune connectivité réseau, diagnostic complet nécessaire.

```bash
# Étape 1 : Vérifier le physique (Couche 1)
ip link show eth0
# ✅ UP → Câble et carte OK

# Étape 2 : Vérifier le niveau MAC (Couche 2)
ip neigh show
sudo arping 192.168.1.1
# ✅ OK → Communication locale fonctionne

# Étape 3 : Vérifier l'IP et le routage (Couche 3)
ip addr show
ip route show
ping 192.168.1.1  # Passerelle locale
ping 8.8.8.8      # Internet
# ❌ 8.8.8.8 échoue mais passerelle OK

# Étape 4 : Vérifier le DNS (Couche 7)
nslookup google.com
# ❌ Échec → Problème DNS

# Étape 5 : Configurer le DNS
sudo nano /etc/resolv.conf  # Ajouter nameserver 8.8.8.8
# ✅ Résolu
```

#### Approche « Diviser pour régner »

**Quand l'utiliser** : Diagnostic rapide, éliminer rapidement les couches fonctionnelles.

```bash
# Test du milieu de la pile (Couche 3)
ping 8.8.8.8

# Si OK → Problème dans couches supérieures (4-7)
# Si KO → Problème dans couches inférieures (1-3)

# Exemple si ping OK mais web KO :
# → Tester DNS
nslookup google.com

# Si DNS OK → Problème applicatif ou certificat
curl -v https://google.com
```

---

### 📋 Checklist complète de dépannage

> [!tip] Utiliser cette checklist Suivez ces étapes dans l'ordre pour un diagnostic méthodique et efficace.

#### Phase 1 : Collecte d'informations

```bash
# 1. Quel est le symptôme exact ?
# Notez : quel service, quel message d'erreur, depuis quand

# 2. Vérifier la configuration actuelle
ip addr show
ip route show
cat /etc/resolv.conf

# 3. Vérifier les logs
sudo journalctl -xe
sudo dmesg | tail -20
```

#### Phase 2 : Tests de base

```bash
# 1. Interface physique
ip link show

# 2. Connectivité locale
ping -c 4 192.168.1.1

# 3. Connectivité Internet (IP)
ping -c 4 8.8.8.8

# 4. Résolution DNS
nslookup google.com

# 5. Connectivité web
curl -I https://google.com
```

#### Phase 3 : Diagnostic ciblé

Selon les résultats de la phase 2, approfondir :

|Test échoué|Action de diagnostic|
|---|---|
|Interface DOWN|Vérifier câble, pilote, `dmesg`|
|Ping local échoue|Vérifier ARP, passerelle, table de routage|
|Ping Internet échoue|Vérifier passerelle, routage, firewall|
|DNS échoue|Changer serveurs DNS, vider cache|
|Curl échoue|Vérifier proxy, certificat, firewall applicatif|

#### Phase 4 : Actions correctives

```bash
# Selon le diagnostic, appliquer la solution appropriée
# Exemples :

# Problème DHCP
sudo dhclient -r eth0 && sudo dhclient eth0

# Problème DNS
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf

# Problème interface
sudo ip link set eth0 down && sudo ip link set eth0 up

# Problème firewall
sudo ufw allow from any to any
```

#### Phase 5 : Vérification

```bash
# Retester tous les éléments de la phase 2
# Vérifier les logs pour absence d'erreurs
# Tester le service final de l'utilisateur
```

---

### 🎯 Exemples de scénarios complets

#### Scénario 1 : "Je ne peux plus accéder à Internet"

```bash
# 1. Test rapide
ping 8.8.8.8
# Résultat : Network unreachable

# 2. Vérifier la configuration IP
ip addr show eth0
# Résultat : Pas d'adresse IP !

# 3. Vérifier DHCP
sudo dhclient eth0
# Résultat : DHCPDISCOVER timeout

# 4. Diagnostic : Problème DHCP
# Vérifier le câble
ip link show eth0
# Résultat : UP, LOWER_UP → Câble OK

# 5. Vérifier si le serveur DHCP répond
sudo tcpdump -i eth0 port 67 or port 68 &
sudo dhclient eth0

# 6. Solution : Configurer IP statique temporaire
sudo ip addr add 192.168.1.100/24 dev eth0
sudo ip route add default via 192.168.1.1
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf

# 7. Test
ping google.com
# ✅ Fonctionne
```

#### Scénario 2 : "Les sites web ne chargent pas"

```bash
# 1. Test IP
ping 8.8.8.8
# ✅ Fonctionne

# 2. Test DNS
ping google.com
# ❌ Échec : Name or service not known

# 3. Diagnostic : Problème DNS identifié
cat /etc/resolv.conf
# Résultat : Vide ou serveur DNS inaccessible

# 4. Test direct d'un serveur DNS
nslookup google.com 8.8.8.8
# ✅ Fonctionne avec 8.8.8.8

# 5. Solution
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
echo "nameserver 1.1.1.1" | sudo tee -a /etc/resolv.conf

# 6. Vérification
ping google.com
# ✅ Fonctionne
```

#### Scénario 3 : "Connexion très lente"

```bash
# 1. Mesurer la latence
ping -c 10 8.8.8.8
# Résultat : temps moyen 250ms (anormal)

# 2. Tracer la route
mtr --report 8.8.8.8
# Résultat : Perte de paquets à un saut spécifique

# 3. Vérifier les erreurs d'interface
ip -s link show eth0
# Résultat : Nombreuses erreurs RX

# 4. Vérifier le duplex et la vitesse
sudo ethtool eth0
# Résultat : Half duplex détecté (devrait être full duplex)

# 5. Diagnostic : Problème d'autonégociation
# Solution : Forcer le mode full duplex
sudo ethtool -s eth0 speed 1000 duplex full autoneg off

# 6. Vérification
ping -c 10 8.8.8.8
# ✅ Latence normale (<10ms)
```

---

### 💡 Astuces et bonnes pratiques

#### Scripts utiles

```bash
# Script de diagnostic rapide
#!/bin/bash
echo "=== Diagnostic réseau rapide ==="
echo ""
echo "1. Interface réseau :"
ip link show | grep -E "^[0-9]"
echo ""
echo "2. Adresses IP :"
ip addr show | grep "inet "
echo ""
echo "3. Passerelle par défaut :"
ip route | grep default
echo ""
echo "4. Serveurs DNS :"
cat /etc/resolv.conf | grep nameserver
echo ""
echo "5. Test connectivité locale :"
ping -c 2 $(ip route | grep default | awk '{print $3}')
echo ""
echo "6. Test connectivité Internet :"
ping -c 2 8.8.8.8
echo ""
echo "7. Test résolution DNS :"
nslookup google.com
```

> [!tip] Créer un alias
> 
> ```bash
> echo 'alias netcheck="/path/to/script.sh"' >> ~/.bashrc
> source ~/.bashrc
> # Utilisation : netcheck
> ```

#### Documentation des problèmes

```bash
# Créer un fichier de log de diagnostic
{
  echo "=== Diagnostic $(date) ==="
  echo "Symptôme : [décrire le problème]"
  echo ""
  ip addr show
  ip route show
  ip neigh show
  ping -c 4 8.8.8.8
  traceroute 8.8.8.8
} > ~/diagnostic_$(date +%Y%m%d_%H%M%S).log
```

#### Outils indispensables à installer

```bash
# Installation des outils de diagnostic
sudo apt update
sudo apt install -y \
  net-tools \
  iputils-ping \
  traceroute \
  mtr \
  dnsutils \
  tcpdump \
  nmap \
  netcat \
  curl \
  wget \
  ethtool \
  arp-scan
```

> [!info] Mémo des commandes essentielles
> 
> - **ip** : configuration réseau moderne
> - **ping** : test de connectivité
> - **traceroute/mtr** : tracer le chemin réseau
> - **dig/nslookup** : résolution DNS
> - **ss/netstat** : connexions et ports
> - **tcpdump** : capture de paquets
> - **ethtool** : configuration Ethernet

---

### 🎓 Récapitulatif de la méthodologie

> [!example] En résumé
> 
> 1. **Identifier le symptôme** : Qu'est-ce qui ne fonctionne pas exactement ?
> 2. **Choisir l'approche** : Bottom-up, top-down, ou diviser pour régner
> 3. **Tester systématiquement** : Suivre les couches OSI
> 4. **Isoler le problème** : Identifier la couche défaillante
> 5. **Appliquer la solution** : Corriger la configuration ou le matériel
> 6. **Vérifier et documenter** : S'assurer que le problème est résolu

### Principes clés du dépannage

|Principe|Explication|
|---|---|
|**Méthodique**|Suivre une approche structurée, ne pas sauter d'étapes|
|**Reproductible**|Pouvoir reproduire le problème pour confirmer le diagnostic|
|**Documenté**|Noter les symptômes, tests effectués et solutions|
|**Simple d'abord**|Commencer par les causes les plus communes|
|**Une chose à la fois**|Changer une seule variable pour identifier la cause|
|**Vérification finale**|Toujours confirmer que la solution fonctionne|

---

🎉 **Fin du cours sur le dépannage réseau courant**