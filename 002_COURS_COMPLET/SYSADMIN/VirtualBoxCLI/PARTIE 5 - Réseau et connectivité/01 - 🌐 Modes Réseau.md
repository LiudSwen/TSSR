

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

## 🎯 Introduction aux modes réseau

VirtualBox propose **6 modes réseau** différents pour configurer la connectivité de vos machines virtuelles. Chaque mode répond à des besoins spécifiques en termes d'isolation, de communication et d'accès réseau.

> [!info] Configuration réseau Chaque VM peut avoir jusqu'à **8 cartes réseau** (NIC). Chaque carte peut être configurée dans un mode différent selon vos besoins.

### Pourquoi c'est important

Le choix du mode réseau détermine :

- La capacité de la VM à accéder à Internet
- La possibilité de communication entre VMs
- L'accessibilité depuis l'hôte ou depuis l'extérieur
- Le niveau d'isolation et de sécurité

### Configuration générale

```bash
# Lister les informations réseau d'une VM
VBoxManage showvminfo "NomVM" | grep NIC

# Activer/désactiver une carte réseau
VBoxManage modifyvm "NomVM" --nic1 none
VBoxManage modifyvm "NomVM" --nic1 nat

# Vérifier l'état de toutes les cartes
VBoxManage showvminfo "NomVM" --machinereadable | grep nic
```

---

## 🔀 NAT (Network Address Translation)

### Concept

Le mode **NAT** est le mode réseau par défaut. La VM accède au réseau externe via l'adresse IP de l'hôte, mais reste invisible depuis l'extérieur. C'est comme si la VM "empruntait" l'identité réseau de l'hôte.

### Caractéristiques

- ✅ Accès Internet immédiat (si l'hôte a Internet)
- ✅ Aucune configuration requise
- ✅ Isolation maximale (invisible depuis l'extérieur)
- ❌ Pas de communication entre VMs
- ❌ Difficile d'accéder à la VM depuis l'hôte sans port forwarding

### Quand l'utiliser

- Configuration rapide pour tester une VM
- VM qui nécessite uniquement un accès sortant
- Environnement sécurisé où la VM ne doit pas être accessible
- Situations où vous n'avez pas les droits admin pour configurer un pont

### Configuration

```bash
# Activer le mode NAT sur la carte 1
VBoxManage modifyvm "MaVM" --nic1 nat

# Configurer le type de carte réseau (optionnel)
VBoxManage modifyvm "MaVM" --nictype1 82540EM
# Types disponibles: Am79C970A, Am79C973, 82540EM, 82543GC, 82545EM, virtio

# Définir une adresse MAC personnalisée (optionnel)
VBoxManage modifyvm "MaVM" --macaddress1 080027123456
```

### Port Forwarding (redirection de ports)

Pour rendre un service de la VM accessible depuis l'hôte :

```bash
# Ajouter une règle de port forwarding
VBoxManage modifyvm "MaVM" --natpf1 "ssh,tcp,,2222,,22"
# Format: "nom,protocole,ip_hote,port_hote,ip_guest,port_guest"

# Exemples pratiques
VBoxManage modifyvm "MaVM" --natpf1 "web,tcp,,8080,,80"      # Serveur web
VBoxManage modifyvm "MaVM" --natpf1 "mysql,tcp,,3306,,3306"  # MySQL
VBoxManage modifyvm "MaVM" --natpf1 "rdp,tcp,,3389,,3389"    # Bureau à distance

# Lister les règles de forwarding
VBoxManage showvminfo "MaVM" | grep "NIC 1 Rule"

# Supprimer une règle
VBoxManage modifyvm "MaVM" --natpf1 delete "ssh"
```

> [!example] Connexion SSH avec port forwarding
> 
> ```bash
> # Après avoir configuré le forwarding SSH sur le port 2222
> ssh -p 2222 utilisateur@localhost
> ```

### Configuration avancée du moteur NAT

```bash
# Limiter la bande passante (en Kbps)
VBoxManage modifyvm "MaVM" --natbindip1 "127.0.0.1"

# Configurer le réseau NAT interne (par défaut 10.0.2.0/24)
VBoxManage modifyvm "MaVM" --natnet1 "192.168.100.0/24"

# Configurer les DNS
VBoxManage modifyvm "MaVM" --natdnsproxy1 on
VBoxManage modifyvm "MaVM" --natdnshostresolver1 on

# Activer le mode promiscuous (capture de paquets)
VBoxManage modifyvm "MaVM" --nicpromisc1 allow-all
```

> [!tip] DNS et résolution de noms Avec `--natdnshostresolver1 on`, la VM utilise le DNS de l'hôte, ce qui permet de résoudre les noms de domaine même en VPN.

> [!warning] Pièges courants
> 
> - Les VMs en NAT ne peuvent **pas** communiquer entre elles, même sur le même hôte
> - L'adresse IP de la VM est toujours dans le réseau 10.0.2.0/24 (sauf modification)
> - Chaque VM en NAT a sa propre instance NAT isolée

### Bonnes pratiques

- Utilisez des noms explicites pour vos règles de port forwarding
- Documentez les ports redirigés dans un fichier séparé
- Évitez de rediriger des ports système (<1024) vers des ports <1024
- Préférez des ports hôte >1024 pour éviter les conflits

---

## 🌉 Bridged (Pont)

### Concept

Le mode **Bridged** connecte directement la VM au réseau physique de l'hôte. La VM apparaît comme un périphérique distinct sur le réseau, avec sa propre adresse IP attribuée par le serveur DHCP du réseau (ou configurée en statique).

### Caractéristiques

- ✅ La VM est visible sur le réseau local
- ✅ Communication directe entre VMs et autres machines
- ✅ Accès Internet via la passerelle du réseau
- ✅ Pas besoin de port forwarding
- ❌ Nécessite des droits réseau sur l'hôte
- ❌ Moins isolé (exposé au réseau local)

### Quand l'utiliser

- Serveurs qui doivent être accessibles depuis le réseau local
- Test d'applications en conditions réelles
- Développement d'applications client-serveur
- Quand vous voulez que la VM se comporte comme une machine physique

### Configuration

```bash
# Lister les interfaces réseau disponibles sur l'hôte
VBoxManage list bridgedifs

# Activer le mode Bridged sur la carte 1
VBoxManage modifyvm "MaVM" --nic1 bridged

# Spécifier l'interface physique à utiliser
VBoxManage modifyvm "MaVM" --bridgeadapter1 "eth0"       # Linux
VBoxManage modifyvm "MaVM" --bridgeadapter1 "en0"        # macOS
VBoxManage modifyvm "MaVM" --bridgeadapter1 "Ethernet"   # Windows

# Exemple complet
VBoxManage modifyvm "WebServer" \
  --nic1 bridged \
  --bridgeadapter1 "eth0" \
  --nictype1 82540EM \
  --cableconnected1 on
```

> [!info] Détection automatique de l'interface Si vous ne spécifiez pas `--bridgeadapter`, VirtualBox choisit automatiquement l'interface active.

### Configuration réseau dans la VM

Une fois le mode Bridged activé, configurez le réseau dans la VM :

```bash
# Configuration DHCP (recommandé)
# La VM obtiendra automatiquement une IP du réseau local

# Configuration statique (exemple pour Debian/Ubuntu)
# /etc/network/interfaces
auto enp0s3
iface enp0s3 inet static
    address 192.168.1.100
    netmask 255.255.255.0
    gateway 192.168.1.1
    dns-nameservers 8.8.8.8 8.8.4.4
```

### Mode promiscuous

Le mode promiscuous permet à la carte réseau de capturer tout le trafic réseau :

```bash
# Désactiver (défaut, plus sécurisé)
VBoxManage modifyvm "MaVM" --nicpromisc1 deny

# Autoriser uniquement les VMs
VBoxManage modifyvm "MaVM" --nicpromisc1 allow-vms

# Autoriser tout (pour analyse réseau)
VBoxManage modifyvm "MaVM" --nicpromisc1 allow-all
```

> [!warning] Sécurité en mode Bridged
> 
> - La VM est exposée au réseau local (firewall, attaques, etc.)
> - Configurez toujours un pare-feu dans la VM
> - Attention aux règles de sécurité de votre réseau d'entreprise
> - Certains réseaux WiFi publics bloquent le mode Bridged

> [!tip] Astuces
> 
> - Sur WiFi, le mode Bridged peut ne pas fonctionner selon la configuration du point d'accès
> - Préférez une connexion Ethernet pour plus de fiabilité
> - Utilisez `tcpdump` ou Wireshark pour déboguer les problèmes réseau

### Bonnes pratiques

- Réservez des adresses IP statiques dans votre serveur DHCP pour les VMs importantes
- Documentez les adresses IP attribuées à vos VMs
- Utilisez un VLAN dédié pour vos VMs en production
- Configurez des noms d'hôte DNS pour faciliter l'accès

---

## 🔒 Internal Network

### Concept

Le mode **Internal Network** crée un réseau virtuel isolé entre plusieurs VMs. Aucune communication n'est possible avec l'hôte ou l'extérieur, sauf configuration explicite d'une VM en tant que routeur.

### Caractéristiques

- ✅ Communication entre VMs sur le même réseau interne
- ✅ Isolation totale du réseau externe
- ✅ Parfait pour tester des architectures réseau
- ❌ Pas d'accès Internet direct
- ❌ Pas d'accès depuis l'hôte

### Quand l'utiliser

- Créer des réseaux isolés pour des tests de sécurité
- Simuler des architectures réseau complexes
- Environnements de formation réseau
- Tests de clustering ou de haute disponibilité

### Configuration

```bash
# Créer un réseau interne nommé "intnet1"
VBoxManage modifyvm "VM1" --nic1 intnet
VBoxManage modifyvm "VM1" --intnet1 "intnet1"

# Connecter une autre VM au même réseau
VBoxManage modifyvm "VM2" --nic1 intnet
VBoxManage modifyvm "VM2" --intnet1 "intnet1"

# Exemple: créer un réseau isolé pour 3 VMs
for vm in "Client1" "Client2" "Serveur"; do
  VBoxManage modifyvm "$vm" --nic1 intnet --intnet1 "lab_network"
done
```

> [!info] Nommage des réseaux internes Le nom du réseau interne est sensible à la casse. Toutes les VMs utilisant le même nom communiqueront entre elles.

### Configuration réseau dans les VMs

Il faut configurer manuellement les adresses IP car il n'y a pas de serveur DHCP par défaut :

```bash
# Dans VM1
sudo ip addr add 192.168.100.10/24 dev enp0s3
sudo ip link set enp0s3 up

# Dans VM2
sudo ip addr add 192.168.100.20/24 dev enp0s3
sudo ip link set enp0s3 up

# Tester la connectivité
ping 192.168.100.20  # Depuis VM1
```

### Architecture multi-réseaux

Une VM peut avoir plusieurs cartes réseau dans différents réseaux :

```bash
# VM Routeur avec 3 interfaces
VBoxManage modifyvm "Routeur" \
  --nic1 nat \                           # Internet
  --nic2 intnet --intnet2 "dmz" \        # Zone DMZ
  --nic3 intnet --intnet3 "interne"      # Réseau interne

# VM dans la DMZ
VBoxManage modifyvm "WebServer" \
  --nic1 intnet --intnet1 "dmz"

# VM dans le réseau interne
VBoxManage modifyvm "Database" \
  --nic1 intnet --intnet1 "interne"
```

> [!example] Architecture réseau d'entreprise simulée
> 
> ```
> Internet (NAT)
>      |
>   Routeur (VM)
>      |
>      +--- DMZ (Internal Network "dmz")
>      |     |
>      |     +--- WebServer
>      |
>      +--- LAN (Internal Network "lan")
>            |
>            +--- Client1
>            +--- Client2
>            +--- FileServer
> ```

> [!tip] Serveur DHCP interne Vous pouvez créer une VM dédiée avec un serveur DHCP (dnsmasq, isc-dhcp-server) pour attribuer automatiquement des IPs dans votre réseau interne.

> [!warning] Pièges courants
> 
> - N'oubliez pas de configurer les routes statiques dans vos VMs routeurs
> - Sans serveur DHCP, chaque VM doit être configurée manuellement
> - Les noms de réseaux internes sont **case-sensitive** : "Reseau1" ≠ "reseau1"

### Bonnes pratiques

- Utilisez des noms de réseaux explicites : "dmz", "backend", "frontend"
- Documentez votre architecture réseau dans un schéma
- Créez des scripts pour configurer automatiquement les IPs au démarrage
- Utilisez des plages IP privées RFC 1918 (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16)

---

## 🏠 Host-Only

### Concept

Le mode **Host-Only** crée un réseau privé entre l'hôte et les VMs. Les VMs peuvent communiquer entre elles et avec l'hôte, mais n'ont pas d'accès direct à Internet.

### Caractéristiques

- ✅ Communication entre VMs
- ✅ Communication avec l'hôte
- ✅ Serveur DHCP intégré optionnel
- ❌ Pas d'accès Internet direct
- ❌ Pas accessible depuis le réseau externe

### Quand l'utiliser

- Développement et tests nécessitant un accès depuis l'hôte
- Environnements de laboratoire isolés mais accessibles
- Services internes accessibles uniquement depuis votre machine
- Combinaison avec NAT pour Internet + accès hôte

### Gestion des réseaux Host-Only

```bash
# Lister les réseaux host-only existants
VBoxManage list hostonlyifs

# Créer un nouveau réseau host-only
VBoxManage hostonlyif create
# Retourne: Interface 'vboxnet0' was successfully created

# Configurer l'interface créée
VBoxManage hostonlyif ipconfig vboxnet0 \
  --ip 192.168.56.1 \
  --netmask 255.255.255.0

# Supprimer un réseau host-only
VBoxManage hostonlyif remove vboxnet0
```

### Configuration du serveur DHCP

VirtualBox peut fournir un serveur DHCP pour les réseaux host-only :

```bash
# Ajouter un serveur DHCP
VBoxManage dhcpserver add \
  --ifname vboxnet0 \
  --ip 192.168.56.1 \
  --netmask 255.255.255.0 \
  --lowerip 192.168.56.100 \
  --upperip 192.168.56.200 \
  --enable

# Modifier un serveur DHCP existant
VBoxManage dhcpserver modify \
  --ifname vboxnet0 \
  --lowerip 192.168.56.50 \
  --upperip 192.168.56.150

# Lister les serveurs DHCP
VBoxManage list dhcpservers

# Supprimer un serveur DHCP
VBoxManage dhcpserver remove --ifname vboxnet0
```

> [!info] Plage DHCP Définissez une plage DHCP qui ne chevauche pas l'IP de l'interface hôte ni vos IPs statiques.

### Connecter une VM au réseau Host-Only

```bash
# Configurer une VM en host-only
VBoxManage modifyvm "MaVM" --nic1 hostonly
VBoxManage modifyvm "MaVM" --hostonlyadapter1 vboxnet0

# Exemple avec plusieurs VMs sur le même réseau
for vm in "Dev1" "Dev2" "TestServer"; do
  VBoxManage modifyvm "$vm" \
    --nic1 hostonly \
    --hostonlyadapter1 vboxnet0
done
```

### Configuration double réseau (Internet + Host-Only)

La configuration la plus courante combine NAT et Host-Only :

```bash
# Carte 1: NAT pour Internet
VBoxManage modifyvm "MaVM" --nic1 nat

# Carte 2: Host-Only pour accès depuis l'hôte
VBoxManage modifyvm "MaVM" --nic2 hostonly
VBoxManage modifyvm "MaVM" --hostonlyadapter2 vboxnet0

# Vérifier la configuration
VBoxManage showvminfo "MaVM" | grep "NIC [12]"
```

Dans la VM, vous aurez deux interfaces :

- `enp0s3` (NAT) : pour Internet
- `enp0s8` (Host-Only) : pour communication avec l'hôte

### Accès aux services depuis l'hôte

```bash
# Si la VM a l'IP 192.168.56.101 en Host-Only
ssh utilisateur@192.168.56.101
curl http://192.168.56.101:8080
mysql -h 192.168.56.101 -u root -p
```

> [!tip] Configuration réseau recommandée pour le développement
> 
> ```bash
> VBoxManage modifyvm "DevVM" \
>   --nic1 nat \                           # Internet
>   --nic2 hostonly \                      # Accès hôte
>   --hostonlyadapter2 vboxnet0
> ```
> 
> Cela donne Internet à la VM tout en restant accessible depuis l'hôte.

> [!warning] Pièges courants
> 
> - Sur certains systèmes, créer un réseau host-only nécessite des privilèges root
> - Windows peut bloquer les réseaux host-only via le pare-feu
> - Sous Linux, vérifiez que le module kernel `vboxnetadp` est chargé

### Configuration réseau dans la VM

```bash
# Avec DHCP activé (automatique)
# L'interface obtiendra une IP dans la plage définie

# Configuration statique (si pas de DHCP)
# /etc/network/interfaces (Debian/Ubuntu)
auto enp0s8
iface enp0s8 inet static
    address 192.168.56.50
    netmask 255.255.255.0
```

### Bonnes pratiques

- Créez des réseaux host-only dédiés pour différents projets
- Utilisez des plages IP différentes pour éviter les conflits (ex: 192.168.56.x, 192.168.57.x)
- Configurez le DHCP avec une plage restreinte pour garder des IPs statiques disponibles
- Documentez les IPs statiques assignées

---

## 🌐 NAT Network

### Concept

Le mode **NAT Network** est une évolution du mode NAT. Il crée un réseau NAT partagé où plusieurs VMs peuvent communiquer entre elles **et** accéder à Internet, tout en restant invisibles depuis l'extérieur.

### Différences avec NAT simple

|Caractéristique|NAT|NAT Network|
|---|---|---|
|Communication inter-VMs|❌ Non|✅ Oui|
|Accès Internet|✅ Oui|✅ Oui|
|Isolation réseau|Totale|Partagée|
|Configuration|Aucune|Réseau à créer|
|Port forwarding|Par VM|Possible|

### Quand l'utiliser

- Plusieurs VMs devant communiquer ensemble avec accès Internet
- Alternative plus simple au Host-Only + NAT
- Tests de communication client-serveur avec Internet
- Environnements isolés mais interconnectés

### Créer un réseau NAT Network

```bash
# Créer un nouveau réseau NAT
VBoxManage natnetwork add \
  --netname natnet1 \
  --network "10.0.10.0/24" \
  --enable \
  --dhcp on

# Lister les réseaux NAT existants
VBoxManage natnetwork list

# Modifier un réseau NAT existant
VBoxManage natnetwork modify \
  --netname natnet1 \
  --network "10.0.20.0/24"

# Supprimer un réseau NAT
VBoxManage natnetwork remove --netname natnet1
```

> [!info] Serveur DHCP intégré Par défaut, un serveur DHCP est activé sur les réseaux NAT Network et attribue automatiquement des IPs aux VMs.

### Connecter des VMs au NAT Network

```bash
# Configurer une VM pour utiliser le NAT Network
VBoxManage modifyvm "VM1" --nic1 natnetwork
VBoxManage modifyvm "VM1" --nat-network1 "natnet1"

# Connecter plusieurs VMs
for vm in "Client" "Server" "Database"; do
  VBoxManage modifyvm "$vm" \
    --nic1 natnetwork \
    --nat-network1 "natnet1"
done
```

### Port Forwarding sur NAT Network

Le port forwarding fonctionne au niveau du réseau, pas de la VM :

```bash
# Ajouter une règle de port forwarding
VBoxManage natnetwork modify --netname natnet1 \
  --port-forward-4 "ssh:tcp:[]:2222:[10.0.10.10]:22"

# Format: "nom:protocole:[ip_hote]:port_hote:[ip_guest]:port_guest"

# Exemples pratiques
VBoxManage natnetwork modify --netname natnet1 \
  --port-forward-4 "web:tcp:[]:8080:[10.0.10.5]:80"

VBoxManage natnetwork modify --netname natnet1 \
  --port-forward-4 "db:tcp:[]:3306:[10.0.10.6]:3306"

# Supprimer une règle
VBoxManage natnetwork modify --netname natnet1 \
  --port-forward-4 delete ssh
```

> [!warning] Différence importante avec NAT Dans NAT Network, vous devez spécifier l'IP de la VM cible dans le réseau. Assurez-vous que la VM a une IP fixe (via DHCP statique ou configuration manuelle).

### Configuration IPv6

NAT Network supporte également IPv6 :

```bash
# Activer IPv6 sur le réseau NAT
VBoxManage natnetwork modify --netname natnet1 \
  --ipv6 on \
  --ipv6-prefix "fd00::/64"
```

### Options avancées

```bash
# Créer un réseau NAT complet avec options
VBoxManage natnetwork add \
  --netname "production" \
  --network "172.16.0.0/24" \
  --enable \
  --dhcp on \
  --ipv6 off \
  --loopback-4 "127.0.1.1=2"

# Désactiver/activer un réseau NAT
VBoxManage natnetwork modify --netname natnet1 --disable
VBoxManage natnetwork modify --netname natnet1 --enable
```

> [!example] Architecture typique avec NAT Network
> 
> ```
> Internet
>     |
> [NAT Network "devnet" - 10.0.10.0/24]
>     |
>     +--- WebServer (10.0.10.10) :80 → localhost:8080
>     +--- AppServer (10.0.10.11)
>     +--- Database (10.0.10.12) :3306 → localhost:3306
>     +--- Client (10.0.10.20)
> ```

> [!tip] Astuces
> 
> - Utilisez le DHCP avec des réservations pour des IPs prévisibles
> - Préférez NAT Network à NAT simple si vous avez plusieurs VMs qui doivent communiquer
> - Plus facile à gérer que Internal Network + routeur NAT

### Bonnes pratiques

- Créez des réseaux NAT séparés pour différents environnements (dev, test, prod)
- Utilisez des plages IP privées non utilisées sur votre réseau local
- Documentez les règles de port forwarding
- Nommez explicitement vos réseaux NAT ("dev-network", "test-cluster", etc.)

---

## 🔧 Generic Driver

### Concept

Le mode **Generic Driver** est un mode avancé qui permet d'utiliser des pilotes réseau personnalisés ou spécifiques. Il est principalement utilisé pour des cas d'usage spécialisés comme UDP Tunnel ou VDE (Virtual Distributed Ethernet).

### Caractéristiques

- ✅ Flexibilité maximale
- ✅ Support de protocoles personnalisés
- ✅ Interconnexion avec d'autres hyperviseurs
- ❌ Configuration complexe
- ❌ Documentation limitée
- ❌ Rarement nécessaire

### Quand l'utiliser

- Connexion de VMs VirtualBox avec d'autres hyperviseurs (VMware, QEMU)
- Tunneling réseau via UDP
- Utilisation de VDE (Virtual Distributed Ethernet)
- Recherche et développement réseau
- Cas d'usage très spécifiques non couverts par les autres modes

### Pilotes disponibles

VirtualBox supporte principalement deux pilotes génériques :

1. **UDP Tunnel** : tunnel réseau via UDP
2. **VDE** : Virtual Distributed Ethernet

### Configuration UDP Tunnel

Le mode UDP Tunnel permet de connecter des VMs via un tunnel UDP, même à travers Internet :

```bash
# VM 1 (serveur du tunnel)
VBoxManage modifyvm "VM1" --nic1 generic
VBoxManage modifyvm "VM1" --nicgenericdrv1 UDPTunnel
VBoxManage modifyvm "VM1" --nicproperty1 dest=192.168.1.100
VBoxManage modifyvm "VM1" --nicproperty1 sport=10000
VBoxManage modifyvm "VM1" --nicproperty1 dport=10001

# VM 2 (client du tunnel)
VBoxManage modifyvm "VM2" --nic1 generic
VBoxManage modifyvm "VM2" --nicgenericdrv1 UDPTunnel
VBoxManage modifyvm "VM2" --nicproperty1 dest=192.168.1.50
VBoxManage modifyvm "VM2" --nicproperty1 sport=10001
VBoxManage modifyvm "VM2" --nicproperty1 dport=10000
```

Paramètres UDP Tunnel :

- `dest` : adresse IP de destination
- `sport` : port source UDP
- `dport` : port destination UDP

> [!info] Communication bidirectionnelle Notez que les ports source/destination sont inversés entre les deux VMs pour établir une communication bidirectionnelle.

### Configuration VDE

VDE permet de connecter plusieurs VMs ou hyperviseurs via un switch virtuel :

```bash
# Installer VDE (sur l'hôte Debian/Ubuntu)
sudo apt-get install vde2

# Démarrer un switch VDE
vde_switch -sock /tmp/vde.ctl -daemon

# Connecter une VM au switch VDE
VBoxManage modifyvm "MaVM" --nic1 generic
VBoxManage modifyvm "MaVM" --nicgenericdrv1 VDE
VBoxManage modifyvm "MaVM" --nicproperty1 network=/tmp/vde.ctl
```

### Cas d'usage : Interconnexion multi-hyperviseur

Connecter une VM VirtualBox à une VM QEMU via VDE :

```bash
# VM VirtualBox
VBoxManage modifyvm "VBoxVM" --nic1 generic
VBoxManage modifyvm "VBoxVM" --nicgenericdrv1 VDE
VBoxManage modifyvm "VBoxVM" --nicproperty1 network=/tmp/vde.ctl

# VM QEMU (commande de lancement)
qemu-system-x86_64 \
  -net nic \
  -net vde,sock=/tmp/vde.ctl \
  disk.img
```

### Propriétés avancées

```bash
# Définir plusieurs propriétés
VBoxManage modifyvm "MaVM" --nic1 generic
VBoxManage modifyvm "MaVM" --nicgenericdrv1 UDPTunnel
VBoxManage modifyvm "MaVM" --nicproperty1 dest=10.0.0.100
VBoxManage modifyvm "MaVM" --nicproperty1 sport=9000
VBoxManage modifyvm "MaVM" --nicproperty1 dport=9001

# Vérifier la configuration
VBoxManage showvminfo "MaVM" | grep -A 5 "NIC 1"
```

### Déboguer les connexions UDP Tunnel

```bash
# Sur l'hôte, vérifier que les ports UDP sont ouverts
sudo netstat -ulnp | grep 10000

# Capturer le trafic du tunnel
sudo tcpdump -i any udp port 10000 -v

# Tester la connectivité UDP entre hôtes
nc -u 192.168.1.100 10000  # Client
nc -u -l 10001              # Serveur
```

> [!warning] Pièges courants
> 
> - Les pare-feux peuvent bloquer les ports UDP
> - NAT sur le routeur peut interférer avec UDP Tunnel
> - Les ports doivent être accessibles entre les hôtes
> - Generic Driver est **beaucoup** plus complexe que les autres modes

> [!tip] Alternatives plus simples Pour la plupart des cas d'usage :
> 
> - Utilisez **NAT Network** au lieu d'UDP Tunnel pour connecter des VMs locales
> - Utilisez **Bridged** pour connecter des VMs sur le même réseau physique
> - Utilisez **VPN** pour connecter des VMs à travers Internet

### Bonnes pratiques

- N'utilisez Generic Driver que si aucun autre mode ne répond à vos besoins
- Documentez exhaustivement votre configuration
- Testez d'abord en local avant de déployer à distance
- Vérifiez les logs VirtualBox en cas de problème : `~/.VirtualBox/VBox.log`

---

## 📊 Tableau comparatif

Voici un tableau récapitulatif pour vous aider à choisir le bon mode réseau :

|Mode|VM → Internet|VM ↔ VM|VM ↔ Hôte|VM ↔ Réseau externe|Complexité|Cas d'usage principal|
|---|---|---|---|---|---|---|
|**NAT**|✅|❌|⚠️ Port forward|❌|⭐ Très simple|Accès Internet isolé|
|**Bridged**|✅|✅|✅|✅|⭐⭐ Simple|VM comme machine physique|
|**Internal Network**|❌|✅ Même réseau|❌|❌|⭐⭐⭐ Moyen|Réseaux isolés|
|**Host-Only**|❌|✅|✅|❌|⭐⭐ Simple|Dev avec accès hôte|
|**NAT Network**|✅|✅|⚠️ Port forward|❌|⭐⭐ Simple|VMs interconnectées + Internet|
|**Generic Driver**|Dépend|Dépend|Dépend|Dépend|⭐⭐⭐⭐⭐ Complexe|Cas spécifiques avancés|

### Recommandations par scénario

|Scénario|Mode recommandé|Alternative|
|---|---|---|
|Test rapide avec Internet|NAT|NAT Network|
|Serveur web accessible du réseau|Bridged|NAT + Port forwarding|
|Développement local|Host-Only + NAT (2 cartes)|NAT Network|
|Cluster de VMs avec Internet|NAT Network|Internal + VM routeur|
|Lab sécurité isolé|Internal Network|Host-Only|
|Architecture réseau complexe|Internal Network (multiple)|NAT Network|
|Interconnexion multi-hyperviseur|Generic Driver (VDE)|VPN + Bridged|

### Combinaisons courantes

Les configurations multi-cartes permettent de combiner les avantages :

```bash
# Configuration développement : Internet + Accès hôte
VBoxManage modifyvm "DevVM" \
  --nic1 nat \                    # Internet
  --nic2 hostonly \                # Accès depuis l'hôte
  --hostonlyadapter2 vboxnet0

# Configuration serveur : Internet + Réseau interne
VBoxManage modifyvm "AppServer" \
  --nic1 nat \                    # Internet
  --nic2 intnet \                 # Backend privé
  --intnet2 "backend"

# Configuration routeur : Internet + 2 réseaux internes
VBoxManage modifyvm "Router" \
  --nic1 nat \                    # WAN
  --nic2 intnet --intnet2 "dmz" \ # DMZ
  --nic3 intnet --intnet3 "lan"   # LAN

# Configuration cluster : Bridged + Internal
VBoxManage modifyvm "Node1" \
  --nic1 bridged \                # Accès réseau
  --bridgeadapter1 eth0 \
  --nic2 intnet \                 # Communication cluster
  --intnet2 "cluster-heartbeat"
```

> [!example] Architecture complète d'un lab
> 
> ```
> Hôte (192.168.1.50)
>   |
>   +--- vboxnet0 (192.168.56.1/24)
>         |
>         +--- Routeur VM
>               |-- NIC1: NAT (Internet)
>               |-- NIC2: Host-Only (Management)
>               |-- NIC3: Internal "dmz"
>               |-- NIC4: Internal "lan"
>               |
>               +--- DMZ
>               |     |-- WebServer (Public)
>               |     |-- LoadBalancer
>               |
>               +--- LAN
>                     |-- AppServer
>                     |-- Database
>                     |-- Client
> ```

### Comparaison des performances

|Mode|Latence|Débit|Overhead CPU|Usage mémoire|
|---|---|---|---|---|
|NAT|Moyenne|Moyen|Moyen (NAT engine)|Moyen|
|Bridged|Faible|Élevé|Faible|Faible|
|Internal Network|Très faible|Très élevé|Très faible|Très faible|
|Host-Only|Faible|Élevé|Faible|Faible|
|NAT Network|Moyenne|Moyen|Moyen (NAT partagé)|Moyen|
|Generic Driver|Variable|Variable|Variable|Variable|

> [!info] Performances relatives
> 
> - **Internal Network** et **Host-Only** offrent les meilleures performances (communication directe en mémoire)
> - **NAT** et **NAT Network** ont un léger overhead dû à la translation d'adresses
> - **Bridged** dépend de la carte réseau physique
> - Pour des benchmarks réseau ou du calcul distribué, privilégiez Internal Network

### Sécurité par mode

|Mode|Niveau d'isolation|Exposition|Recommandation|
|---|---|---|---|
|NAT|Très élevé|Aucune|Production isolée|
|Bridged|Faible|Réseau local complet|Avec firewall VM|
|Internal Network|Total|Aucune|Environnements sensibles|
|Host-Only|Élevé|Hôte uniquement|Développement sécurisé|
|NAT Network|Élevé|Groupe de VMs|Production multi-tiers|
|Generic Driver|Variable|Dépend config|Cas par cas|

> [!warning] Considérations de sécurité
> 
> - **Bridged** expose la VM au réseau : configurez toujours un pare-feu dans la VM
> - **Host-Only** expose la VM à l'hôte : si l'hôte est compromis, les VMs le sont aussi
> - **NAT** et **NAT Network** offrent la meilleure isolation par défaut
> - **Internal Network** est parfait pour isoler des services backend
> - Appliquez toujours le principe du moindre privilège : utilisez le mode le plus restrictif possible

### Commandes de diagnostic réseau

```bash
# Vérifier la configuration réseau d'une VM
VBoxManage showvminfo "MaVM" | grep -i nic

# Vérifier tous les paramètres réseau en format lisible
VBoxManage showvminfo "MaVM" --machinereadable | grep -i nic

# Lister toutes les interfaces host-only
VBoxManage list hostonlyifs

# Lister toutes les interfaces bridged disponibles
VBoxManage list bridgedifs

# Lister tous les réseaux NAT
VBoxManage list natnets

# Lister tous les serveurs DHCP
VBoxManage list dhcpservers

# Statistiques réseau en temps réel (VM en cours d'exécution)
VBoxManage showvminfo "MaVM" | grep -i "NIC 1"
```

### Scripts utiles

```bash
#!/bin/bash
# Script pour afficher la configuration réseau de toutes les VMs

echo "=== Configuration réseau de toutes les VMs ==="
for vm in $(VBoxManage list vms | cut -d'"' -f2); do
    echo ""
    echo "VM: $vm"
    echo "---"
    VBoxManage showvminfo "$vm" | grep -E "NIC [1-4]:" | head -4
done
```

```bash
#!/bin/bash
# Script pour créer un environnement de développement standard

VM_NAME="DevEnvironment"

echo "Configuration de $VM_NAME..."

# Carte 1: NAT pour Internet
VBoxManage modifyvm "$VM_NAME" --nic1 nat

# Carte 2: Host-Only pour accès hôte
VBoxManage modifyvm "$VM_NAME" \
  --nic2 hostonly \
  --hostonlyadapter2 vboxnet0

# Port forwarding SSH
VBoxManage modifyvm "$VM_NAME" \
  --natpf1 "ssh,tcp,,2222,,22"

echo "✓ Configuration terminée"
echo "  - Internet : Carte 1 (NAT)"
echo "  - Accès hôte : Carte 2 (vboxnet0)"
echo "  - SSH : ssh -p 2222 user@localhost"
```

---

## 🎯 Récapitulatif et aide-mémoire

### Commandes essentielles

```bash
# Changer le mode d'une carte réseau
VBoxManage modifyvm "VM" --nic1 <mode>
# Modes: none, null, nat, natnetwork, bridged, intnet, hostonly, generic

# NAT
VBoxManage modifyvm "VM" --nic1 nat
VBoxManage modifyvm "VM" --natpf1 "ssh,tcp,,2222,,22"

# Bridged
VBoxManage modifyvm "VM" --nic1 bridged --bridgeadapter1 eth0

# Internal Network
VBoxManage modifyvm "VM" --nic1 intnet --intnet1 "monreseau"

# Host-Only
VBoxManage modifyvm "VM" --nic1 hostonly --hostonlyadapter1 vboxnet0

# NAT Network
VBoxManage modifyvm "VM" --nic1 natnetwork --nat-network1 "natnet1"

# Generic Driver
VBoxManage modifyvm "VM" --nic1 generic --nicgenericdrv1 UDPTunnel
```

### Gestion des réseaux

```bash
# Host-Only
VBoxManage hostonlyif create
VBoxManage hostonlyif ipconfig vboxnet0 --ip 192.168.56.1

# NAT Network
VBoxManage natnetwork add --netname natnet1 --network "10.0.10.0/24" --enable

# DHCP
VBoxManage dhcpserver add --ifname vboxnet0 --ip 192.168.56.1 \
  --netmask 255.255.255.0 --lowerip 192.168.56.100 --upperip 192.168.56.200
```

### Choix rapide du mode réseau

**Vous avez besoin que la VM accède à Internet ?**

- Oui, et c'est tout → **NAT**
- Oui, et qu'elle communique avec d'autres VMs → **NAT Network**
- Oui, et qu'elle soit accessible du réseau → **Bridged**

**Vous voulez isoler complètement des VMs ?**

- Entre elles uniquement → **Internal Network**
- Avec l'hôte seulement → **Host-Only**

**Vous avez un cas complexe ?**

- Utilisez **plusieurs cartes réseau** avec différents modes
- En dernier recours → **Generic Driver**

> [!tip] Conseil final Commencez toujours simple (NAT ou Bridged), puis ajoutez de la complexité seulement si nécessaire. La plupart des besoins sont couverts par NAT, Bridged, ou une combinaison NAT + Host-Only.

---

## 📝 Notes finales

### Dépannage général

Problèmes courants et solutions :

```bash
# La VM n'a pas d'accès réseau
# 1. Vérifier que la carte est connectée
VBoxManage modifyvm "VM" --cableconnected1 on

# 2. Vérifier le mode réseau
VBoxManage showvminfo "VM" | grep "NIC 1"

# 3. Dans la VM, vérifier l'interface
ip link show
ip addr show

# 4. Redémarrer le service réseau (dans la VM)
sudo systemctl restart networking  # Debian/Ubuntu
sudo systemctl restart NetworkManager  # Fedora/CentOS

# La VM ne communique pas avec d'autres VMs
# Vérifier qu'elles sont sur le même réseau (intnet, hostonly, natnetwork)
# Vérifier les noms de réseaux (case-sensitive)

# Impossible de créer un réseau host-only
# Vérifier les permissions (peut nécessiter root)
# Sur Linux, charger le module : sudo modprobe vboxnetadp
```

### Logs et diagnostic

```bash
# Logs VirtualBox (sur l'hôte)
tail -f ~/.config/VirtualBox/VBox.log

# Logs réseau détaillés
VBoxManage modifyvm "VM" --nictrace1 on
VBoxManage modifyvm "VM" --nictracefile1 /tmp/vm-nic1.pcap
# Analyser avec Wireshark: wireshark /tmp/vm-nic1.pcap
```

### Astuces avancées

```bash
# Limiter la bande passante d'une carte
VBoxManage bandwidthctl "VM" add Limit --type network --limit 1m  # 1 Mbps
VBoxManage modifyvm "VM" --nicbandwidthgroup1 Limit

# Simuler une déconnexion réseau
VBoxManage controlvm "VM" setlinkstate1 off
VBoxManage controlvm "VM" setlinkstate1 on

# Changer le type de carte réseau (pour compatibilité)
VBoxManage modifyvm "VM" --nictype1 virtio  # Meilleure performance
VBoxManage modifyvm "VM" --nictype1 82540EM  # Compatibilité
```

> [!info] Types de cartes réseau
> 
> - **virtio** : Performances optimales (nécessite pilotes dans la VM)
> - **82540EM** : Intel PRO/1000 MT Desktop (e1000), bon compromis
> - **82545EM** : Intel PRO/1000 MT Server (e1000e), serveurs
> - **Am79C973** : AMD PCnet-FAST III, anciens OS
> - **82543GC** : Intel PRO/1000 T Server, compatibilité étendue

---

🎉 **Fin du cours sur les modes réseau VirtualBox CLI**

Ce cours vous a présenté les 6 modes réseau disponibles dans VirtualBox. Vous devriez maintenant être capable de :

- Comprendre les différences entre chaque mode
- Choisir le mode approprié selon vos besoins
- Configurer n'importe quel mode via la ligne de commande
- Créer des architectures réseau complexes
- Dépanner les problèmes réseau courants

N'hésitez pas à expérimenter avec différentes configurations pour trouver celle qui correspond le mieux à votre cas d'usage !