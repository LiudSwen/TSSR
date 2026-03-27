

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

Chaque distribution Linux arrive avec un ensemble d'outils préinstallés qui reflètent sa philosophie et son public cible. Comprendre ces différences est crucial pour l'administration système, car vous ne pourrez pas toujours installer de nouveaux paquets (environnements restreints, systèmes de production, conteneurs minimalistes).

> [!info] Pourquoi c'est important
> 
> - Les outils préinstallés déterminent votre capacité d'intervention immédiate
> - En production, vous devez souvent travailler avec ce qui est disponible
> - Connaître les alternatives vous rend plus polyvalent entre distributions

---

## Différences dans les paquets par défaut

### 🎯 Philosophies des distributions

Les distributions se distinguent par leur approche minimaliste ou complète :

|Distribution|Philosophie|Nombre de paquets par défaut|
|---|---|---|
|**Debian (base)**|Minimaliste avec option|~300-500 paquets|
|**Ubuntu Desktop**|Prêt à l'emploi|~1500-2000 paquets|
|**CentOS/RHEL (Minimal)**|Strict minimum serveur|~200-400 paquets|
|**Arch Linux**|Absolument minimal|~150-250 paquets|
|**Fedora Workstation**|Moderne et complet|~1800-2200 paquets|

### 📦 Catégories d'outils préinstallés

#### Éditeurs de texte

```bash
# Vérifier les éditeurs disponibles
which vi vim nano emacs

# Debian/Ubuntu : généralement vi, nano
# RHEL/CentOS : vi uniquement en minimal
# Arch : vi uniquement
```

> [!tip] Astuce d'administration Apprenez au minimum `vi` (ou `vim`), car c'est le seul éditeur garanti sur presque tous les systèmes UNIX/Linux.

#### Outils de compression

```bash
# Outils standards (présents partout)
gzip, gunzip, tar

# Outils souvent absents en installation minimale
bzip2, xz, zip, unzip, 7z

# Vérifier la disponibilité
command -v bzip2 && echo "bzip2 disponible" || echo "bzip2 absent"
command -v xz && echo "xz disponible" || echo "xz absent"
```

> [!example] Exemple pratique
> 
> ```bash
> # Si xz n'est pas disponible pour décompresser un fichier .tar.xz
> # Sur Debian/Ubuntu
> apt install xz-utils
> 
> # Sur RHEL/CentOS
> yum install xz
> ```

#### Outils de développement

```bash
# Compiler GCC - souvent absent en installation minimale
which gcc

# Outils de build
which make automake

# Utilitaires de développement
which git curl wget
```

|Outil|Debian minimal|Ubuntu Desktop|RHEL minimal|Arch|
|---|---|---|---|---|
|gcc|❌|❌|❌|❌|
|make|❌|✅|❌|❌|
|git|❌|✅|❌|❌|
|curl|✅|✅|✅|✅|
|wget|✅|✅|✅|✅|

#### Outils système essentiels

```bash
# Surveillance système
top, ps, free, df, du

# Gestion des processus
kill, killall, pkill

# Informations système
uname, hostname, uptime, who, w
```

> [!warning] Attention aux variations
> 
> - `killall` peut être absent sur certaines installations minimales
> - `htop` n'est jamais préinstallé par défaut
> - `lsof` est souvent absent en installation minimale

### 🔍 Identifier les outils disponibles

#### Commandes de vérification

```bash
# Lister tous les binaires disponibles dans le PATH
compgen -c | sort | less

# Trouver l'emplacement d'une commande
which nom_commande
type nom_commande
command -v nom_commande

# Vérifier si un paquet est installé
# Debian/Ubuntu
dpkg -l | grep nom_paquet

# RHEL/CentOS
rpm -qa | grep nom_paquet

# Arch
pacman -Q | grep nom_paquet
```

#### Trouver à quel paquet appartient une commande

```bash
# Debian/Ubuntu
dpkg -S /usr/bin/commande

# RHEL/CentOS
rpm -qf /usr/bin/commande

# Arch
pacman -Qo /usr/bin/commande
```

> [!example] Exemple concret
> 
> ```bash
> # Trouver le paquet qui fournit 'netstat'
> # Debian/Ubuntu
> dpkg -S $(which netstat)
> # Résultat : net-tools: /bin/netstat
> 
> # RHEL/CentOS
> rpm -qf $(which netstat)
> # Résultat : net-tools-2.0-0.25.el8.x86_64
> ```

### 🎨 Paquets spécifiques aux distributions

#### Ubuntu spécifique

```bash
# Outils propres à Ubuntu
landscape-client    # Gestion centralisée (Ubuntu Server)
ubuntu-advantage-tools  # Support commercial
snap                # Système de paquets snap
```

#### RHEL/CentOS spécifique

```bash
# Outils Red Hat
subscription-manager  # Gestion des abonnements RHEL
yum-utils            # Utilitaires supplémentaires pour yum
selinux-policy       # Politiques SELinux
```

#### Arch Linux spécifique

```bash
# Outils Arch
pacman              # Gestionnaire de paquets
makepkg             # Construction de paquets
pacman-contrib      # Utilitaires supplémentaires
```

---

## Présence ou absence de sudo configuré

### 🔐 Philosophies de sécurité

La configuration de `sudo` varie considérablement entre distributions et reflète des choix de sécurité différents.

### 📊 État par défaut selon les distributions

|Distribution|Installation Desktop|Installation Server|Sudo préconfiguré|
|---|---|---|---|
|**Ubuntu**|Oui (utilisateur créé)|Oui|✅ Oui|
|**Debian**|Non (demande mot de passe root)|Non|❌ Non|
|**RHEL/CentOS**|Dépend de l'installation|Non|⚠️ Partiel|
|**Fedora**|Oui|Oui|✅ Oui|
|**Arch**|Non|Non|❌ Non|

### 🔧 Vérifier la configuration de sudo

```bash
# Vérifier si sudo est installé
which sudo
dpkg -l | grep sudo    # Debian/Ubuntu
rpm -qa | grep sudo    # RHEL/CentOS

# Vérifier si votre utilisateur peut utiliser sudo
sudo -l

# Voir qui a accès à sudo
grep -Po '^sudo.+:\K.*$' /etc/group

# Afficher la configuration sudo
sudo cat /etc/sudoers
# Ou mieux (ne casse pas le fichier si erreur de syntaxe)
sudo visudo -c    # Vérifie la syntaxe
```

> [!warning] Ne jamais éditer /etc/sudoers directement Utilisez toujours `visudo` qui vérifie la syntaxe avant de sauvegarder. Une erreur dans ce fichier peut vous bloquer l'accès administrateur.

### 🎯 Configurations typiques

#### Ubuntu : utilisateur dans le groupe sudo

```bash
# L'utilisateur créé lors de l'installation est automatiquement ajouté au groupe sudo
groups nom_utilisateur
# Résultat : nom_utilisateur : nom_utilisateur adm cdrom sudo dip plugdev ...

# Configuration dans /etc/sudoers
%sudo   ALL=(ALL:ALL) ALL
```

#### Debian : root uniquement par défaut

```bash
# Sur une installation Debian fraîche
sudo ls
# Erreur : nom_utilisateur is not in the sudoers file

# Solution : se connecter en root et ajouter l'utilisateur
su -
usermod -aG sudo nom_utilisateur
# Ou éditer le fichier sudoers
visudo
```

#### RHEL/CentOS : groupe wheel

```bash
# L'utilisateur doit être dans le groupe wheel
usermod -aG wheel nom_utilisateur

# Configuration dans /etc/sudoers
%wheel  ALL=(ALL)       ALL
```

### 📝 Configurer sudo manuellement

#### Ajouter un utilisateur à sudo (méthode recommandée)

```bash
# Debian/Ubuntu
su -
usermod -aG sudo nom_utilisateur
# L'utilisateur doit se déconnecter/reconnecter

# RHEL/CentOS
su -
usermod -aG wheel nom_utilisateur
```

#### Créer un fichier de configuration dédié

```bash
# Créer un fichier dans /etc/sudoers.d/ (méthode modulaire recommandée)
sudo visudo -f /etc/sudoers.d/nom_utilisateur

# Contenu du fichier
nom_utilisateur ALL=(ALL:ALL) ALL
```

> [!tip] Bonnes pratiques sudo
> 
> - Utilisez `/etc/sudoers.d/` pour vos configurations personnalisées
> - Les fichiers dans ce répertoire sont inclus automatiquement
> - Nommez les fichiers sans extension ou points (ex: `admin_users` pas `admin_users.conf`)
> - Utilisez toujours `visudo -f` pour éditer

### 🔒 Options de configuration courantes

```bash
# Éditer avec visudo
sudo visudo

# Exemples de configurations dans /etc/sudoers

# 1. Utilisateur avec tous les droits
nom_utilisateur ALL=(ALL:ALL) ALL

# 2. Utilisateur sans mot de passe (DANGEREUX, à éviter)
nom_utilisateur ALL=(ALL:ALL) NOPASSWD: ALL

# 3. Utilisateur avec droits limités (exemple : uniquement systemctl)
nom_utilisateur ALL=(ALL) /usr/bin/systemctl

# 4. Groupe avec tous les droits
%admin ALL=(ALL:ALL) ALL

# 5. Pas de mot de passe pour certaines commandes spécifiques
nom_utilisateur ALL=(ALL) NOPASSWD: /usr/bin/apt update, /usr/bin/apt upgrade

# 6. Conserver les variables d'environnement
Defaults env_keep += "HTTP_PROXY HTTPS_PROXY"
```

> [!warning] Sécurité
> 
> - `NOPASSWD` est pratique mais dangereux en production
> - Préférez des droits limités aux commandes nécessaires
> - Surveillez les logs sudo dans `/var/log/auth.log` (Debian/Ubuntu) ou `/var/log/secure` (RHEL/CentOS)

### 🐛 Problèmes courants avec sudo

#### Problème : "user is not in the sudoers file"

```bash
# Solution 1 : Se connecter en root et ajouter l'utilisateur
su -
usermod -aG sudo nom_utilisateur    # Debian/Ubuntu
usermod -aG wheel nom_utilisateur   # RHEL/CentOS

# Solution 2 : Éditer directement sudoers en tant que root
su -
visudo
# Ajouter : nom_utilisateur ALL=(ALL:ALL) ALL
```

#### Problème : "sudo: command not found"

```bash
# Sudo n'est pas installé (cas Debian minimal, Arch)
su -
apt install sudo     # Debian/Ubuntu
yum install sudo     # RHEL/CentOS
pacman -S sudo       # Arch
```

#### Problème : modifications non prises en compte

```bash
# L'utilisateur doit se déconnecter et reconnecter
# Ou dans la même session
newgrp sudo    # Recharge les groupes (Debian/Ubuntu)
newgrp wheel   # RHEL/CentOS
```

---

## Outils réseau disponibles

### 🌐 Évolution des outils réseau sous Linux

Les outils réseau traditionnels (`net-tools`) sont progressivement remplacés par de nouveaux outils plus modernes (`iproute2`). Cependant, leur disponibilité varie selon les distributions.

### 📊 Comparaison des outils anciens vs modernes

|Ancienne commande (net-tools)|Nouvelle commande (iproute2)|Préinstallé par défaut|
|---|---|---|
|`ifconfig`|`ip addr` ou `ip a`|Debian minimal: ❌, Ubuntu: ✅|
|`route`|`ip route` ou `ip r`|Debian minimal: ❌, Ubuntu: ✅|
|`netstat`|`ss`|Minimal: ❌, Standard: ✅|
|`arp`|`ip neigh`|Debian minimal: ❌, Ubuntu: ✅|
|`iwconfig`|`iw`|Minimal: ❌, Desktop: ✅|

> [!info] Transition en cours
> 
> - Les nouvelles installations privilégient `iproute2`
> - `net-tools` est considéré obsolète mais encore largement utilisé
> - Dans les conteneurs et installations minimales, seul `iproute2` est présent

### 🔧 Suite iproute2 (moderne)

#### Commande ip - outil principal

```bash
# Afficher toutes les interfaces réseau
ip link show
ip link    # Version courte

# Afficher les adresses IP
ip address show
ip addr    # Version courte
ip a       # Version très courte

# Afficher les routes
ip route show
ip route
ip r

# Afficher les voisins ARP
ip neighbor show
ip neigh

# Statistiques réseau
ip -s link    # Statistiques par interface
```

> [!example] Exemples pratiques avec ip
> 
> ```bash
> # Activer/désactiver une interface
> sudo ip link set eth0 up
> sudo ip link set eth0 down
> 
> # Ajouter une adresse IP temporaire
> sudo ip addr add 192.168.1.100/24 dev eth0
> 
> # Supprimer une adresse IP
> sudo ip addr del 192.168.1.100/24 dev eth0
> 
> # Ajouter une route
> sudo ip route add 10.0.0.0/8 via 192.168.1.1
> 
> # Afficher uniquement les interfaces actives
> ip link show up
> ```

#### Commande ss (remplace netstat)

```bash
# Afficher toutes les connexions
ss -a

# Afficher les connexions TCP
ss -t

# Afficher les connexions en écoute
ss -l

# Afficher avec les numéros de port (pas de résolution DNS)
ss -n

# Afficher les processus utilisant les sockets
ss -p

# Combinaisons courantes
ss -tunlp    # TCP+UDP, numérique, écoute, processus
ss -tanp     # TCP, toutes, numérique, processus
```

> [!tip] ss est plus rapide que netstat `ss` utilise les interfaces netlink du noyau directement, ce qui le rend beaucoup plus rapide sur les systèmes avec beaucoup de connexions.

### 🛠️ Suite net-tools (traditionnelle)

#### ifconfig

```bash
# Afficher toutes les interfaces
ifconfig

# Afficher uniquement les interfaces actives
ifconfig -s

# Afficher une interface spécifique
ifconfig eth0

# Activer/désactiver une interface
sudo ifconfig eth0 up
sudo ifconfig eth0 down

# Configurer une adresse IP (temporaire)
sudo ifconfig eth0 192.168.1.100 netmask 255.255.255.0
```

> [!warning] ifconfig montre moins d'informations Contrairement à `ip addr`, `ifconfig` n'affiche que l'interface principale et peut masquer certaines adresses IP secondaires.

#### netstat

```bash
# Afficher toutes les connexions
netstat -a

# Afficher les connexions TCP
netstat -t

# Afficher les connexions en écoute
netstat -l

# Afficher avec les numéros de port
netstat -n

# Afficher les processus
netstat -p

# Combinaisons courantes
netstat -tunlp    # TCP+UDP, numérique, écoute, processus
netstat -r        # Afficher la table de routage
```

#### route

```bash
# Afficher la table de routage
route -n    # Numérique (plus rapide)

# Ajouter une route
sudo route add -net 10.0.0.0/8 gw 192.168.1.1

# Supprimer une route
sudo route del -net 10.0.0.0/8

# Ajouter une route par défaut
sudo route add default gw 192.168.1.1
```

### 🔍 Outils de diagnostic réseau

#### ping et ping6

```bash
# Toujours préinstallé sur toutes les distributions
ping google.com
ping -c 4 8.8.8.8    # Limiter à 4 paquets
ping6 google.com     # Pour IPv6

# Options utiles
ping -i 0.2 host     # Intervalle de 0.2s entre paquets
ping -s 1000 host    # Paquets de 1000 octets
```

#### traceroute / tracepath

```bash
# traceroute : souvent NON préinstallé en minimal
traceroute google.com

# tracepath : généralement préinstallé (iproute2)
tracepath google.com

# Installer traceroute si nécessaire
sudo apt install traceroute        # Debian/Ubuntu
sudo yum install traceroute        # RHEL/CentOS
```

#### dig et nslookup

```bash
# dig : outil DNS moderne (paquet bind-utils ou dnsutils)
# Souvent ABSENT en installation minimale
dig google.com
dig @8.8.8.8 google.com    # Interroger un serveur spécifique
dig +short google.com       # Sortie courte

# nslookup : outil DNS classique (aussi dans bind-utils)
nslookup google.com
nslookup google.com 8.8.8.8

# Installer si nécessaire
sudo apt install dnsutils          # Debian/Ubuntu
sudo yum install bind-utils        # RHEL/CentOS
```

> [!example] Alternative si dig n'est pas disponible
> 
> ```bash
> # host : souvent préinstallé, plus simple
> host google.com
> host -t MX google.com    # Enregistrements MX
> ```

#### curl et wget

```bash
# Les deux sont généralement préinstallés
# Télécharger un fichier

# wget : plus simple pour téléchargements
wget https://example.com/fichier.tar.gz
wget -O nom_local.tar.gz https://example.com/fichier.tar.gz

# curl : plus polyvalent pour APIs
curl https://example.com/fichier.tar.gz -o fichier.tar.gz
curl -I https://example.com    # Headers HTTP seulement
curl -X POST -d "data=value" https://api.example.com
```

### 📦 Installation des outils manquants

#### Debian/Ubuntu

```bash
# net-tools (ifconfig, netstat, route, arp)
sudo apt install net-tools

# Outils DNS
sudo apt install dnsutils    # dig, nslookup

# Outils de diagnostic
sudo apt install traceroute inetutils-traceroute
sudo apt install tcpdump
sudo apt install nmap
```

#### RHEL/CentOS

```bash
# net-tools
sudo yum install net-tools

# Outils DNS
sudo yum install bind-utils    # dig, nslookup

# Outils de diagnostic
sudo yum install traceroute
sudo yum install tcpdump
sudo yum install nmap
```

#### Arch Linux

```bash
# net-tools
sudo pacman -S net-tools

# Outils DNS
sudo pacman -S bind-tools    # dig, nslookup

# Outils de diagnostic
sudo pacman -S traceroute
sudo pacman -S tcpdump
sudo pacman -S nmap
```

### 🎯 Vérifier la disponibilité des outils réseau

```bash
# Script de vérification rapide
for cmd in ip ifconfig ss netstat route ping dig host curl wget; do
    if command -v $cmd >/dev/null 2>&1; then
        echo "✓ $cmd est disponible"
    else
        echo "✗ $cmd est manquant"
    fi
done
```

> [!tip] Adapter ses habitudes
> 
> - Sur un système moderne : privilégiez `ip` et `ss`
> - Sur un système ancien : utilisez `ifconfig` et `netstat`
> - Dans un script : testez la disponibilité avec `command -v` avant utilisation
> - En production : documentez les dépendances nécessaires

### 🔒 Outils réseau nécessitant des privilèges

```bash
# Ces commandes nécessitent généralement root ou sudo
tcpdump          # Capture de paquets
iptables         # Pare-feu
ip link set      # Modification d'interfaces
ifconfig up/down # Activation/désactivation d'interfaces

# Vérifier les capacités nécessaires
getcap /usr/sbin/tcpdump
# Résultat : /usr/sbin/tcpdump = cap_net_raw,cap_net_admin+eip
```

---

## 🎓 Récapitulatif

> [!info] Points clés à retenir
> 
> - **Paquets par défaut** : varient énormément entre distributions (200 à 2000+ paquets)
> - **Sudo** : préconfiguré sur Ubuntu/Fedora, à configurer manuellement sur Debian/Arch
> - **Outils réseau** : transition de `net-tools` vers `iproute2` en cours
> - Toujours vérifier la disponibilité des outils avant de les utiliser en production
> - Apprendre les alternatives modernes (`ip`, `ss`) et classiques (`ifconfig`, `netstat`)

> [!tip] Conseil d'administration Créez un script de diagnostic rapide qui liste tous les outils disponibles sur vos systèmes. Cela vous fera gagner du temps lors du dépannage.