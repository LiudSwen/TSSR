

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

## 🎯 Introduction

Un serveur LAMP est une pile logicielle complète permettant d'héberger des applications web dynamiques. Avant de procéder à l'installation et à la configuration d'un tel serveur, il est essentiel de s'assurer que le système répond aux prérequis nécessaires pour garantir stabilité, performance et sécurité.

> [!info] Pourquoi les prérequis sont importants Une infrastructure mal dimensionnée ou une distribution inadaptée peuvent entraîner des problèmes de performance, de sécurité ou de maintenance. Prendre le temps de bien choisir et configurer votre environnement de base est un investissement qui vous évitera de nombreux problèmes futurs.

---

## 🏗️ Architecture LAMP

### Qu'est-ce que LAMP ?

LAMP est un acronyme désignant une pile technologique composée de quatre composants principaux travaillant ensemble :

|Composant|Signification|Rôle|
|---|---|---|
|**L**|Linux|Système d'exploitation (fondation)|
|**A**|Apache|Serveur web (HTTP)|
|**M**|MySQL/MariaDB|Système de gestion de base de données|
|**P**|PHP|Langage de script côté serveur|

### Fonctionnement de la pile LAMP

```
┌─────────────────────────────────────────────┐
│           Navigateur Client                  │
└──────────────────┬──────────────────────────┘
                   │ Requête HTTP
                   ↓
┌─────────────────────────────────────────────┐
│              Apache (Serveur Web)            │
│  • Reçoit les requêtes HTTP/HTTPS           │
│  • Gère les fichiers statiques (HTML, CSS)  │
│  • Transmet les scripts PHP au processeur   │
└──────────────────┬──────────────────────────┘
                   │
                   ↓
┌─────────────────────────────────────────────┐
│           PHP (Moteur de script)             │
│  • Exécute le code PHP                       │
│  • Génère du contenu dynamique              │
│  • Communique avec la base de données       │
└──────────────────┬──────────────────────────┘
                   │
                   ↓
┌─────────────────────────────────────────────┐
│       MySQL/MariaDB (Base de données)       │
│  • Stocke et gère les données               │
│  • Exécute les requêtes SQL                 │
│  • Retourne les résultats à PHP             │
└─────────────────────────────────────────────┘
```

> [!example] Exemple de flux
> 
> 1. Un utilisateur demande `www.example.com/article.php?id=5`
> 2. Apache reçoit la requête et identifie qu'il s'agit d'un fichier PHP
> 3. Apache transmet le script à PHP pour exécution
> 4. PHP exécute le code, interroge MySQL pour récupérer l'article n°5
> 5. MySQL retourne les données à PHP
> 6. PHP génère une page HTML avec ces données
> 7. Apache envoie la page HTML générée au navigateur

### Variantes de la pile LAMP

> [!tip] Alternatives possibles
> 
> - **LEMP** : Nginx remplace Apache (E pour "Engine X")
> - **LAPP** : PostgreSQL remplace MySQL
> - **LAMP avec Python** : Python/Django remplace PHP
> - **WAMP** : Windows remplace Linux (environnement de développement)
> - **MAMP** : macOS remplace Linux (environnement de développement)

---

## 🐧 Distributions Linux recommandées

Le choix de la distribution Linux est crucial car il impacte la stabilité, la sécurité, la facilité de maintenance et la disponibilité des packages.

### Distributions basées sur Debian

#### Ubuntu Server (Recommandée pour débutants)

**Points forts :**

- Documentation abondante et communauté très active
- Cycle de release régulier avec support LTS (Long Term Support)
- Gestion des packages simplifiée avec APT
- Support commercial disponible via Canonical

**Versions recommandées :**

- **Ubuntu Server 22.04 LTS** (support jusqu'en 2027)
- **Ubuntu Server 24.04 LTS** (support jusqu'en 2029)

```bash
# Vérifier la version d'Ubuntu
lsb_release -a
```

> [!info] Qu'est-ce que LTS ? Les versions LTS (Long Term Support) reçoivent des mises à jour de sécurité et des correctifs pendant 5 ans minimum. Elles sont idéales pour les serveurs de production.

#### Debian

**Points forts :**

- Stabilité légendaire et fiabilité éprouvée
- Système de packages robuste
- Totalement gratuit et communautaire
- Base de nombreuses autres distributions

**Versions recommandées :**

- **Debian 12 (Bookworm)** - Stable actuelle
- **Debian 11 (Bullseye)** - Stable précédente, toujours supportée

```bash
# Vérifier la version de Debian
cat /etc/debian_version
```

> [!warning] Attention aux versions Évitez d'utiliser les versions "Testing" ou "Unstable" en production. Privilégiez toujours la version "Stable" pour un serveur LAMP.

### Distributions basées sur Red Hat

#### Rocky Linux / AlmaLinux (Successeurs de CentOS)

**Points forts :**

- Compatibilité binaire avec Red Hat Enterprise Linux (RHEL)
- Stabilité exceptionnelle pour les environnements d'entreprise
- Gestion des packages avec DNF/YUM
- Support communautaire solide

**Versions recommandées :**

- **Rocky Linux 9** (support jusqu'en 2032)
- **AlmaLinux 9** (support jusqu'en 2032)

```bash
# Vérifier la version
cat /etc/redhat-release
```

#### Fedora Server

**Points forts :**

- Technologies récentes et innovantes
- Excellente pour tester de nouvelles fonctionnalités
- Cycle de release rapide (tous les 6 mois)

> [!warning] Attention Fedora n'est PAS recommandée pour la production en raison de son cycle de vie court (environ 13 mois). Privilégiez-la pour le développement et les tests.

### Tableau comparatif

|Distribution|Difficulté|Stabilité|Support LTS|Usage recommandé|
|---|---|---|---|---|
|Ubuntu Server|⭐ Facile|⭐⭐⭐⭐|5 ans|Production, débutants|
|Debian|⭐⭐ Moyen|⭐⭐⭐⭐⭐|~5 ans|Production, expérimentés|
|Rocky Linux|⭐⭐⭐ Avancé|⭐⭐⭐⭐⭐|10 ans|Entreprise, RHEL|
|AlmaLinux|⭐⭐⭐ Avancé|⭐⭐⭐⭐⭐|10 ans|Entreprise, RHEL|
|Fedora|⭐⭐ Moyen|⭐⭐⭐|13 mois|Développement|

### Gestionnaires de packages

Chaque famille de distributions utilise son propre gestionnaire de packages :

**Debian/Ubuntu :**

```bash
# Mettre à jour la liste des packages
sudo apt update

# Mettre à jour les packages installés
sudo apt upgrade

# Installer un package
sudo apt install nom-du-package

# Rechercher un package
apt search nom-du-package
```

**Red Hat/Rocky/Alma :**

```bash
# Mettre à jour la liste des packages
sudo dnf check-update

# Mettre à jour les packages installés
sudo dnf update

# Installer un package
sudo dnf install nom-du-package

# Rechercher un package
dnf search nom-du-package
```

> [!tip] Astuce de sélection Si vous débutez : choisissez **Ubuntu Server LTS**. Si vous avez de l'expérience ou travaillez en entreprise avec des systèmes Red Hat : optez pour **Rocky Linux**.

---

## 💻 Ressources matérielles minimales

Les besoins en ressources dépendent fortement de l'usage prévu du serveur LAMP. Voici les recommandations selon différents scénarios.

### Configuration minimale (environnement de test/développement)

Cette configuration convient pour apprendre, tester et développer sur un serveur LAMP sans charge utilisateur.

|Ressource|Minimum|Recommandé|
|---|---|---|
|**CPU**|1 cœur @ 1 GHz|2 cœurs @ 2 GHz|
|**RAM**|512 MB|1 GB|
|**Disque dur**|10 GB|20 GB|
|**Réseau**|100 Mbps|1 Gbps|

```bash
# Vérifier les ressources du système
# CPU
lscpu

# RAM
free -h

# Espace disque
df -h

# Informations système complètes
htop  # Nécessite installation: sudo apt install htop
```

> [!warning] Attention Ces ressources sont vraiment minimales. Le système fonctionnera, mais les performances seront limitées. N'utilisez pas cette configuration pour un site en production.

### Configuration pour site à trafic faible (blog, site vitrine)

Adapté pour un site avec quelques centaines de visiteurs par jour.

|Ressource|Spécification|
|---|---|
|**CPU**|2 cœurs @ 2+ GHz|
|**RAM**|2 GB|
|**Disque dur**|40 GB SSD (recommandé)|
|**Réseau**|1 Gbps|
|**Bande passante**|1-2 TB/mois|

### Configuration pour site à trafic moyen (e-commerce, forum)

Pour un site avec plusieurs milliers de visiteurs quotidiens et une base de données active.

|Ressource|Spécification|
|---|---|
|**CPU**|4 cœurs @ 2.5+ GHz|
|**RAM**|4-8 GB|
|**Disque dur**|100 GB SSD|
|**Réseau**|1 Gbps|
|**Bande passante**|5-10 TB/mois|

> [!tip] Optimisation pour base de données Si votre application est gourmande en base de données, privilégiez la RAM. MySQL/MariaDB utilise intensivement la mémoire pour le cache et améliorer les performances.

### Configuration pour site à fort trafic (application web complexe)

Pour des applications recevant des dizaines de milliers de visites par jour.

|Ressource|Spécification|
|---|---|
|**CPU**|8+ cœurs @ 3+ GHz|
|**RAM**|16-32 GB|
|**Disque dur**|250 GB SSD NVMe|
|**Réseau**|10 Gbps|
|**Bande passante**|Illimitée ou 20+ TB/mois|

> [!info] Architecture distribuée À ce niveau, il est recommandé de séparer les composants : un serveur pour Apache/PHP, un autre pour MySQL, éventuellement un système de cache (Redis/Memcached), et un load balancer. Cette section ne couvre que les prérequis d'un serveur unique.

### Estimation des besoins selon le trafic

**Formule approximative pour la RAM :**

```
RAM nécessaire (GB) = (Visiteurs simultanés × 10 MB) + 512 MB (OS) + 512 MB (MySQL)
```

**Exemple :**

- 100 visiteurs simultanés : ~2 GB RAM
- 500 visiteurs simultanés : ~6 GB RAM
- 1000 visiteurs simultanés : ~11 GB RAM

> [!warning] Ce n'est qu'une estimation Ces calculs sont approximatifs et dépendent fortement de votre application. Une application mal optimisée peut consommer beaucoup plus de ressources.

### Type de stockage

|Type|Avantages|Inconvénients|Usage recommandé|
|---|---|---|---|
|**HDD**|Moins cher, grande capacité|Lent, sensible aux chocs|Sauvegardes, archives|
|**SSD SATA**|Rapide, fiable|Plus cher que HDD|Serveurs production|
|**SSD NVMe**|Très rapide|Le plus cher|Bases de données intensives|

```bash
# Vérifier le type de disque
lsblk -d -o name,rota
# rota = 1 : HDD
# rota = 0 : SSD

# Tester les performances du disque
sudo hdparm -Tt /dev/sda  # Remplacer sda par votre disque
```

> [!tip] Recommandation Privilégiez toujours un SSD pour un serveur LAMP. La différence de performance est considérable, surtout pour les opérations de base de données.

### Vérification des ressources disponibles

```bash
# Informations CPU détaillées
lscpu | grep -E 'Model name|Socket|Core|Thread'

# RAM totale et disponible
free -h

# Espace disque par partition
df -h

# Type et modèle de disque
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,MODEL

# Vitesse réseau des interfaces
ethtool eth0 | grep Speed  # Remplacer eth0 par votre interface
```

---

## 🌐 Configuration réseau de base

Une configuration réseau correcte est essentielle pour qu'un serveur LAMP soit accessible et sécurisé.

### Adressage IP

#### IP statique vs IP dynamique

**IP statique (Recommandée pour serveurs) :**

- Adresse IP fixe qui ne change jamais
- Nécessaire pour la configuration DNS
- Facilite l'administration et la maintenance

**IP dynamique (Non recommandée pour serveurs) :**

- Adresse IP attribuée automatiquement par DHCP
- Peut changer au redémarrage
- Convient aux postes clients uniquement

> [!warning] Serveur = IP statique obligatoire Un serveur web doit TOUJOURS avoir une adresse IP statique pour être accessible de manière fiable.

### Configuration de l'IP statique

#### Sur Ubuntu/Debian (Netplan)

Les versions récentes d'Ubuntu utilisent Netplan pour la configuration réseau.

```bash
# Identifier le nom de votre interface réseau
ip addr show
# ou
ip link show
```

Fichier de configuration : `/etc/netplan/00-installer-config.yaml`

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    enp0s3:  # Remplacer par le nom de votre interface
      dhcp4: no
      addresses:
        - 192.168.1.100/24  # Votre IP statique/masque
      routes:
        - to: default
          via: 192.168.1.1  # Votre passerelle (gateway)
      nameservers:
        addresses:
          - 8.8.8.8  # DNS primaire (Google)
          - 8.8.4.4  # DNS secondaire (Google)
```

```bash
# Appliquer la configuration
sudo netplan apply

# Vérifier la configuration
ip addr show enp0s3
```

> [!tip] Bonnes pratiques pour l'adresse IP
> 
> - Choisissez une IP en dehors de la plage DHCP de votre routeur
> - Documentez l'IP attribuée dans un fichier de référence
> - Utilisez une IP cohérente avec votre plan d'adressage réseau

#### Sur Debian (anciennes méthodes)

Pour les systèmes n'utilisant pas Netplan, le fichier de configuration est différent.

Fichier : `/etc/network/interfaces`

```bash
# Interface loopback
auto lo
iface lo inet loopback

# Interface principale
auto enp0s3
iface enp0s3 inet static
    address 192.168.1.100
    netmask 255.255.255.0
    gateway 192.168.1.1
    dns-nameservers 8.8.8.8 8.8.4.4
```

```bash
# Redémarrer le service réseau
sudo systemctl restart networking

# Vérifier la configuration
ip addr show
```

#### Sur Rocky Linux/AlmaLinux (NetworkManager)

Fichier : `/etc/sysconfig/network-scripts/ifcfg-enp0s3`

```bash
TYPE=Ethernet
BOOTPROTO=static
NAME=enp0s3
DEVICE=enp0s3
ONBOOT=yes
IPADDR=192.168.1.100
NETMASK=255.255.255.0
GATEWAY=192.168.1.1
DNS1=8.8.8.8
DNS2=8.8.4.4
```

```bash
# Redémarrer le service réseau
sudo systemctl restart NetworkManager

# Vérifier la configuration
nmcli device show enp0s3
```

### Nom d'hôte (Hostname)

Le nom d'hôte identifie votre serveur sur le réseau.

```bash
# Afficher le nom d'hôte actuel
hostname

# Afficher le nom d'hôte complet (FQDN)
hostname -f

# Définir un nouveau nom d'hôte (persistent)
sudo hostnamectl set-hostname monserveur.exemple.com

# Vérifier le changement
hostnamectl
```

Fichier `/etc/hosts` (à mettre à jour) :

```bash
127.0.0.1       localhost
192.168.1.100   monserveur.exemple.com monserveur

# IPv6
::1             localhost ip6-localhost ip6-loopback
```

> [!info] FQDN (Fully Qualified Domain Name) Un FQDN complet contient le nom d'hôte et le domaine : `serveur.exemple.com`. C'est important pour certaines applications et la configuration SSL/TLS.

### Ports réseau essentiels pour LAMP

|Service|Port|Protocole|Description|
|---|---|---|---|
|SSH|22|TCP|Administration à distance|
|HTTP|80|TCP|Trafic web non chiffré|
|HTTPS|443|TCP|Trafic web chiffré (SSL/TLS)|
|MySQL|3306|TCP|Base de données (ne pas exposer publiquement)|

```bash
# Vérifier les ports en écoute
sudo ss -tulpn

# Vérifier un port spécifique
sudo ss -tulpn | grep :80

# Alternative avec netstat (ancien)
sudo netstat -tulpn | grep LISTEN
```

> [!warning] Sécurité des ports
> 
> - Le port 3306 (MySQL) ne doit JAMAIS être accessible depuis Internet
> - Utilisez un pare-feu pour limiter l'accès aux services
> - Le port 22 (SSH) devrait être protégé (clés SSH, fail2ban)

### Tests de connectivité de base

```bash
# Tester la connexion Internet
ping -c 4 8.8.8.8

# Tester la résolution DNS
ping -c 4 google.com

# Tester la route réseau
traceroute google.com

# Vérifier la configuration IP
ip addr show
ip route show

# Afficher les connexions actives
ss -s
```

### Configuration du pare-feu (UFW sur Ubuntu/Debian)

UFW (Uncomplicated Firewall) simplifie la gestion du pare-feu.

```bash
# Installer UFW (si nécessaire)
sudo apt install ufw

# Vérifier le statut
sudo ufw status

# Autoriser SSH (important avant d'activer le pare-feu !)
sudo ufw allow 22/tcp

# Autoriser HTTP et HTTPS
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp

# Activer le pare-feu
sudo ufw enable

# Vérifier les règles actives
sudo ufw status numbered
```

> [!warning] Attention avec SSH Assurez-vous TOUJOURS d'autoriser le port SSH (22) avant d'activer le pare-feu, sinon vous perdrez l'accès à votre serveur distant !

### Configuration du pare-feu (Firewalld sur Rocky/Alma)

```bash
# Vérifier le statut
sudo firewall-cmd --state

# Autoriser HTTP et HTTPS de façon permanente
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https

# Recharger la configuration
sudo firewall-cmd --reload

# Vérifier les services autorisés
sudo firewall-cmd --list-all
```

### Résolution de noms (DNS)

Le fichier `/etc/resolv.conf` contient les serveurs DNS utilisés.

```bash
# Afficher la configuration DNS
cat /etc/resolv.conf
```

Exemple de contenu :

```bash
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 1.1.1.1
```

**Serveurs DNS publics populaires :**

|Fournisseur|DNS Primaire|DNS Secondaire|
|---|---|---|
|Google|8.8.8.8|8.8.4.4|
|Cloudflare|1.1.1.1|1.0.0.1|
|OpenDNS|208.67.222.222|208.67.220.220|
|Quad9|9.9.9.9|149.112.112.112|

```bash
# Tester la résolution DNS
nslookup google.com
# ou
dig google.com

# Tester avec un serveur DNS spécifique
nslookup google.com 8.8.8.8
```

> [!tip] Astuce Utilisez plusieurs serveurs DNS pour la redondance. Si le premier est indisponible, le système utilisera automatiquement le suivant.

### Vérification complète de la configuration réseau

Script de diagnostic complet :

```bash
#!/bin/bash
echo "=== Configuration réseau ==="
echo "Adresses IP :"
ip addr show | grep "inet "
echo ""

echo "Route par défaut :"
ip route show | grep default
echo ""

echo "Serveurs DNS :"
cat /etc/resolv.conf | grep nameserver
echo ""

echo "Nom d'hôte :"
hostname -f
echo ""

echo "Ports en écoute :"
sudo ss -tulpn | grep LISTEN
echo ""

echo "Test de connectivité Internet :"
ping -c 2 8.8.8.8 > /dev/null 2>&1 && echo "✓ OK" || echo "✗ ÉCHEC"
echo ""

echo "Test de résolution DNS :"
ping -c 2 google.com > /dev/null 2>&1 && echo "✓ OK" || echo "✗ ÉCHEC"
```

```bash
# Rendre le script exécutable
chmod +x verif_reseau.sh

# Exécuter le script
./verif_reseau.sh
```

---

## 📌 Pièges courants

> [!warning] Erreurs fréquentes lors de la préparation d'un serveur LAMP

**1. Oublier de configurer une IP statique**

- Symptôme : le serveur devient inaccessible après un redémarrage
- Solution : toujours configurer une IP statique sur un serveur

**2. Bloquer le port SSH avec le pare-feu**

- Symptôme : perte d'accès au serveur distant
- Solution : autoriser le port 22 AVANT d'activer le pare-feu

**3. Sous-dimensionner la RAM**

- Symptôme : serveur lent, crashes fréquents, erreurs MySQL
- Solution : prévoir au minimum 2 GB pour un serveur de production

**4. Utiliser un HDD au lieu d'un SSD**

- Symptôme : performances médiocres, temps de réponse élevés
- Solution : privilégier un SSD, surtout pour la base de données

**5. Exposer le port MySQL (3306) sur Internet**

- Symptôme : tentatives d'intrusion, risques de sécurité
- Solution : MySQL doit UNIQUEMENT écouter sur localhost (127.0.0.1)

**6. Choisir une distribution sans support LTS**

- Symptôme : mises à jour fréquentes, instabilité, fin de support rapide
- Solution : utiliser Ubuntu LTS, Debian Stable, ou Rocky Linux

**7. Ne pas mettre à jour le système avant l'installation**

- Symptôme : conflits de packages, vulnérabilités de sécurité
- Solution : toujours faire `sudo apt update && sudo apt upgrade` d'abord

---

## ✅ Checklist de vérification avant installation

Avant de procéder à l'installation de la pile LAMP, assurez-vous que :

- [ ] Vous avez choisi une distribution Linux appropriée (de préférence Ubuntu Server LTS ou Rocky Linux)
- [ ] Le système dispose des ressources matérielles suffisantes pour votre usage
- [ ] Une adresse IP statique est configurée et fonctionnelle
- [ ] Le nom d'hôte (hostname) est défini correctement
- [ ] Le fichier `/etc/hosts` est à jour
- [ ] La résolution DNS fonctionne (`ping google.com`)
- [ ] Le pare-feu est configuré avec les règles de base (SSH, HTTP, HTTPS)
- [ ] Le système est à jour (`apt update && apt upgrade` ou `dnf update`)
- [ ] Vous avez accès SSH au serveur et les privilèges sudo
- [ ] Une sauvegarde est planifiée (même si le serveur est vide)

```bash
# Script de vérification rapide
echo "Distribution : $(lsb_release -ds 2>/dev/null || cat /etc/redhat-release 2>/dev/null)"
echo "RAM disponible : $(free -h | grep Mem | awk '{print $7}')"
echo "Espace disque : $(df -h / | tail -1 | awk '{print $4}')"
echo "IP statique : $(ip addr show | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}')"
echo "Hostname : $(hostname -f)"
echo "DNS opérationnel : $(ping -c 1 google.com > /dev/null 2>&1 && echo 'OUI' || echo 'NON')"
```

---

> [!success] Vous êtes prêt ! Une fois tous ces prérequis vérifiés et validés, votre système est prêt pour l'installation et la configuration de la pile LAMP. Les étapes suivantes consisteront à installer et configurer Apache, MySQL/MariaDB et PHP.