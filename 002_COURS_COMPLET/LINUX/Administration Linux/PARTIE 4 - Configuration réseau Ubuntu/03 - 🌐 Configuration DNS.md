

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

## 🎯 Introduction au DNS

Le DNS (Domain Name System) est le système qui traduit les noms de domaine (comme `example.com`) en adresses IP. Sur Ubuntu, la configuration DNS peut être gérée de plusieurs manières selon la version du système et les outils utilisés.

> [!info] Évolution de la gestion DNS sur Ubuntu Ubuntu moderne utilise **systemd-resolved** comme résolveur DNS par défaut depuis Ubuntu 16.10. Cela change la façon dont `/etc/resolv.conf` est géré par rapport aux systèmes traditionnels.

---

## 🔧 systemd-resolved

### Qu'est-ce que systemd-resolved ?

`systemd-resolved` est un service système qui fournit la résolution de noms DNS, la résolution de noms d'hôtes locaux via mDNS et LLMNR, ainsi que la validation DNSSEC.

**Avantages :**

- Cache DNS intégré pour améliorer les performances
- Support DNSSEC pour la sécurité
- Intégration native avec systemd
- Gestion intelligente du DNS split-horizon (différents DNS selon le réseau)

**Quand l'utiliser :**

- Configuration par défaut recommandée pour Ubuntu moderne
- Systèmes avec plusieurs interfaces réseau
- Besoin de cache DNS local

### Configuration de systemd-resolved

Le fichier de configuration principal se trouve dans `/etc/systemd/resolved.conf`.

```bash
# Éditer la configuration
sudo nano /etc/systemd/resolved.conf
```

**Structure du fichier :**

```ini
[Resolve]
# Serveurs DNS globaux (fallback)
DNS=8.8.8.8 8.8.4.4
FallbackDNS=1.1.1.1 1.0.0.1

# Domaines de recherche
Domains=example.com local

# Activation de DNSSEC
DNSSEC=allow-downgrade

# Cache DNS
Cache=yes
CacheFromLocalhost=no

# Support mDNS et LLMNR
MulticastDNS=yes
LLMNR=yes

# Stub listener (interface locale)
DNSStubListener=yes
DNSStubListenerExtra=127.0.0.1:5355
```

> [!warning] Options DNSSEC
> 
> - `no` : DNSSEC désactivé
> - `allow-downgrade` : Active DNSSEC mais autorise le repli si non supporté (recommandé)
> - `yes` : DNSSEC obligatoire (peut causer des problèmes avec certains réseaux)

### Commandes de gestion

```bash
# Vérifier le statut du service
systemctl status systemd-resolved

# Redémarrer après modification de la configuration
sudo systemctl restart systemd-resolved

# Voir les statistiques DNS actuelles
resolvectl status

# Afficher la configuration DNS par interface
resolvectl

# Vider le cache DNS
sudo resolvectl flush-caches

# Statistiques du cache
resolvectl statistics

# Requête DNS spécifique
resolvectl query example.com

# Voir les serveurs DNS utilisés
resolvectl dns

# Définir un serveur DNS pour une interface
sudo resolvectl dns eth0 8.8.8.8 1.1.1.1
```

> [!example] Exemple de sortie resolvectl status
> 
> ```
> Global
>        Protocols: +LLMNR +mDNS -DNSOverTLS DNSSEC=allow-downgrade
> resolv.conf mode: stub
>   Current DNS Server: 8.8.8.8
>          DNS Servers: 8.8.8.8 8.8.4.4
> 
> Link 2 (eth0)
>     Current Scopes: DNS LLMNR/IPv4 LLMNR/IPv6
>          Protocols: +DefaultRoute +LLMNR -mDNS -DNSOverTLS DNSSEC=allow-downgrade
>        DNS Servers: 192.168.1.1
> ```

### Modes de fonctionnement

`systemd-resolved` peut fonctionner selon plusieurs modes, contrôlés par `/etc/resolv.conf` :

|Mode|Description|Lien symbolique|
|---|---|---|
|**stub**|Mode par défaut, utilise un listener local sur 127.0.0.53|`/run/systemd/resolve/stub-resolv.conf`|
|**static**|Utilise les serveurs DNS configurés directement|`/usr/lib/systemd/resolv.conf`|
|**uplink**|Utilise les serveurs DNS fournis par DHCP/réseau|`/run/systemd/resolve/resolv.conf`|

```bash
# Vérifier le mode actuel
ls -l /etc/resolv.conf

# Changer pour le mode stub (recommandé)
sudo ln -sf /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

# Changer pour le mode uplink
sudo ln -sf /run/systemd/resolve/resolv.conf /etc/resolv.conf
```

> [!tip] Astuce : Mode stub recommandé Le mode stub (127.0.0.53) permet à systemd-resolved de gérer intelligemment le cache DNS et le routage des requêtes selon l'interface réseau active.

---

## 📄 Le fichier /etc/resolv.conf

### Rôle et structure

`/etc/resolv.conf` est le fichier traditionnel de configuration DNS sous Linux. Il indique aux applications quels serveurs DNS interroger.

**Structure classique :**

```bash
# Serveurs DNS (maximum 3 recommandés)
nameserver 8.8.8.8
nameserver 8.8.4.4
nameserver 1.1.1.1

# Domaine de recherche par défaut
search example.com local

# Domaines supplémentaires pour les recherches
domain example.com

# Options de résolution
options timeout:2 attempts:3 rotate ndots:1
```

**Directives principales :**

|Directive|Description|Exemple|
|---|---|---|
|`nameserver`|Adresse IP d'un serveur DNS (max 3 utilisés)|`nameserver 8.8.8.8`|
|`search`|Liste de domaines pour compléter les noms courts|`search corp.com example.com`|
|`domain`|Domaine local par défaut (obsolète, utiliser search)|`domain example.com`|
|`options`|Options de comportement du résolveur|`options timeout:2`|

**Options courantes :**

```bash
options timeout:2        # Timeout de 2 secondes par requête (défaut: 5)
options attempts:3       # Nombre de tentatives (défaut: 2)
options rotate           # Rotation entre les serveurs DNS
options ndots:1          # Nombre de points pour considérer un nom complet (défaut: 1)
options single-request   # Une requête à la fois (évite des bugs)
options edns0            # Active les extensions DNS
```

### Gestion du fichier

> [!warning] Attention : Fichier géré automatiquement Sur Ubuntu moderne avec systemd-resolved, `/etc/resolv.conf` est généralement un lien symbolique géré automatiquement. Les modifications manuelles seront écrasées !

```bash
# Vérifier si c'est un lien symbolique
ls -l /etc/resolv.conf
# Résultat typique : lrwxrwxrwx [...] /etc/resolv.conf -> /run/systemd/resolve/stub-resolv.conf

# Voir le contenu réel
cat /etc/resolv.conf
```

**Trois cas de figure :**

1. **Système avec systemd-resolved** : Lien symbolique vers un fichier géré automatiquement
2. **Système avec NetworkManager** : Fichier géré par NetworkManager
3. **Configuration statique manuelle** : Fichier normal éditable

### Configuration manuelle

Pour empêcher l'écrasement automatique du fichier :

**Méthode 1 : Désactiver la gestion automatique (systemd-resolved)**

```bash
# Supprimer le lien symbolique
sudo rm /etc/resolv.conf

# Créer un fichier statique
sudo nano /etc/resolv.conf
```

```bash
# Configuration manuelle
nameserver 8.8.8.8
nameserver 8.8.4.4
search example.com
options timeout:2 attempts:3
```

```bash
# Protéger le fichier contre l'écrasement
sudo chattr +i /etc/resolv.conf

# Pour déverrouiller plus tard
sudo chattr -i /etc/resolv.conf
```

> [!warning] Inconvénients de la configuration manuelle
> 
> - Perd les avantages du cache DNS de systemd-resolved
> - Ne s'adapte pas automatiquement aux changements de réseau
> - Nécessite une maintenance manuelle À utiliser uniquement pour des cas spécifiques (serveurs, environnements statiques)

**Méthode 2 : Utiliser resolvconf (ancien système)**

```bash
# Installer resolvconf si nécessaire
sudo apt install resolvconf

# Éditer la configuration de base
sudo nano /etc/resolvconf/resolv.conf.d/base
```

```bash
nameserver 8.8.8.8
nameserver 8.8.4.4
```

```bash
# Regénérer resolv.conf
sudo resolvconf -u
```

---

## 🔌 Configuration DNS dans Netplan

Netplan est l'outil de configuration réseau par défaut sur Ubuntu depuis la version 17.10. Il génère la configuration pour systemd-networkd ou NetworkManager.

### Syntaxe de base

Les fichiers de configuration Netplan se trouvent dans `/etc/netplan/` avec l'extension `.yaml`.

```bash
# Lister les fichiers de configuration
ls /etc/netplan/

# Éditer la configuration (nom de fichier peut varier)
sudo nano /etc/netplan/01-netcfg.yaml
```

**Structure YAML pour DNS :**

```yaml
network:
  version: 2
  renderer: networkd  # ou NetworkManager
  
  ethernets:
    eth0:
      dhcp4: no
      addresses:
        - 192.168.1.100/24
      routes:
        - to: default
          via: 192.168.1.1
      
      # Configuration DNS
      nameservers:
        addresses:
          - 8.8.8.8
          - 8.8.4.4
          - 1.1.1.1
        search:
          - example.com
          - local
```

> [!info] Renderer : networkd vs NetworkManager
> 
> - **networkd** : Backend léger, idéal pour serveurs et configurations statiques
> - **NetworkManager** : Backend complet, recommandé pour desktops et portables

### Exemples de configuration

**Configuration DHCP avec DNS personnalisés :**

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: yes
      dhcp4-overrides:
        use-dns: no  # Ignorer les DNS fournis par DHCP
      nameservers:
        addresses:
          - 8.8.8.8
          - 1.1.1.1
```

**Configuration avec plusieurs interfaces et DNS différents :**

```yaml
network:
  version: 2
  renderer: networkd
  
  ethernets:
    # Interface LAN - DNS interne
    eth0:
      dhcp4: no
      addresses: [192.168.1.100/24]
      routes:
        - to: default
          via: 192.168.1.1
      nameservers:
        addresses: [192.168.1.10, 192.168.1.11]
        search: [corp.local]
    
    # Interface WAN - DNS publics
    eth1:
      dhcp4: yes
      nameservers:
        addresses: [8.8.8.8, 1.1.1.1]
```

**Configuration Wi-Fi avec DNS :**

```yaml
network:
  version: 2
  renderer: NetworkManager
  
  wifis:
    wlan0:
      dhcp4: yes
      access-points:
        "MonReseau":
          password: "motdepasse"
      nameservers:
        addresses: [1.1.1.1, 1.0.0.1]
        search: [home.local]
```

**Configuration avec IPv6 :**

```yaml
network:
  version: 2
  renderer: networkd
  
  ethernets:
    eth0:
      dhcp4: yes
      dhcp6: yes
      nameservers:
        addresses:
          - 8.8.8.8        # IPv4
          - 8.8.4.4        # IPv4
          - 2001:4860:4860::8888  # IPv6
          - 2001:4860:4860::8844  # IPv6
```

### Application des changements

```bash
# Tester la configuration sans l'appliquer
sudo netplan try

# Si la configuration est correcte, elle s'applique après 120 secondes
# Appuyer sur Entrée pour confirmer, ou attendre le rollback automatique

# Appliquer directement (attention aux erreurs !)
sudo netplan apply

# Voir la configuration générée pour debug
sudo netplan generate

# Activer le mode debug pour plus d'informations
sudo netplan --debug apply
```

> [!tip] Astuce : Toujours utiliser netplan try Lors de modifications réseau à distance (SSH), utilisez toujours `netplan try` pour éviter de perdre l'accès en cas d'erreur. La configuration sera automatiquement annulée après 2 minutes si vous ne confirmez pas.

> [!warning] Attention à l'indentation YAML YAML est sensible à l'indentation. Utilisez toujours des espaces (pas de tabulations) et respectez l'alignement. Une erreur d'indentation empêchera l'application de la configuration.

**Validation de la syntaxe YAML :**

```bash
# Vérifier la syntaxe sans appliquer
sudo netplan generate

# Avec yamllint (à installer)
sudo apt install yamllint
yamllint /etc/netplan/*.yaml
```

---

## 🖧 Configuration DNS dans NetworkManager

NetworkManager est l'outil de gestion réseau principal pour les environnements desktop Ubuntu. Il peut être contrôlé via CLI, GUI ou fichiers de configuration.

### Via l'interface CLI (nmcli)

**Commandes de base :**

```bash
# Lister toutes les connexions
nmcli connection show

# Afficher les détails d'une connexion
nmcli connection show "Wired connection 1"

# Voir uniquement les DNS d'une connexion
nmcli -f ipv4.dns,ipv6.dns connection show "Wired connection 1"
```

**Configurer les serveurs DNS :**

```bash
# Définir les serveurs DNS IPv4
sudo nmcli connection modify "Wired connection 1" ipv4.dns "8.8.8.8 8.8.4.4"

# Ajouter un serveur DNS supplémentaire
sudo nmcli connection modify "Wired connection 1" +ipv4.dns "1.1.1.1"

# Retirer un serveur DNS
sudo nmcli connection modify "Wired connection 1" -ipv4.dns "8.8.8.8"

# Définir les serveurs DNS IPv6
sudo nmcli connection modify "Wired connection 1" ipv6.dns "2001:4860:4860::8888 2001:4860:4860::8844"

# Configurer les domaines de recherche
sudo nmcli connection modify "Wired connection 1" ipv4.dns-search "example.com,local"

# Ignorer les DNS automatiques (DHCP)
sudo nmcli connection modify "Wired connection 1" ipv4.ignore-auto-dns yes

# Réactiver la connexion pour appliquer les changements
sudo nmcli connection down "Wired connection 1"
sudo nmcli connection up "Wired connection 1"
```

**Configuration complète en une commande :**

```bash
sudo nmcli connection modify "Wired connection 1" \
  ipv4.dns "8.8.8.8 8.8.4.4 1.1.1.1" \
  ipv4.dns-search "example.com,local" \
  ipv4.ignore-auto-dns yes
```

**Créer une nouvelle connexion avec DNS :**

```bash
sudo nmcli connection add \
  type ethernet \
  con-name "Static-Eth0" \
  ifname eth0 \
  ipv4.method manual \
  ipv4.addresses 192.168.1.100/24 \
  ipv4.gateway 192.168.1.1 \
  ipv4.dns "8.8.8.8 8.8.4.4" \
  ipv4.dns-search "example.com"
```

> [!example] Exemple pratique : Basculer entre DNS publics
> 
> ```bash
> # Utiliser les DNS de Google
> sudo nmcli connection modify "Wired connection 1" ipv4.dns "8.8.8.8 8.8.4.4"
> 
> # Utiliser les DNS de Cloudflare
> sudo nmcli connection modify "Wired connection 1" ipv4.dns "1.1.1.1 1.0.0.1"
> 
> # Utiliser les DNS de Quad9 (avec filtrage)
> sudo nmcli connection modify "Wired connection 1" ipv4.dns "9.9.9.9 149.112.112.112"
> 
> # Appliquer
> sudo nmcli connection up "Wired connection 1"
> ```

### Via les fichiers de configuration

NetworkManager stocke ses connexions dans `/etc/NetworkManager/system-connections/`.

```bash
# Lister les fichiers de connexion
sudo ls -l /etc/NetworkManager/system-connections/

# Éditer une connexion (remplacer par le nom réel)
sudo nano /etc/NetworkManager/system-connections/Wired\ connection\ 1.nmconnection
```

**Structure du fichier de connexion :**

```ini
[connection]
id=Wired connection 1
uuid=12345678-1234-1234-1234-123456789abc
type=ethernet
interface-name=eth0
timestamp=1234567890

[ethernet]

[ipv4]
method=manual
address1=192.168.1.100/24,192.168.1.1
dns=8.8.8.8;8.8.4.4;1.1.1.1;
dns-search=example.com;local;
ignore-auto-dns=true

[ipv6]
method=auto
dns=2001:4860:4860::8888;2001:4860:4860::8844;
addr-gen-mode=stable-privacy

[proxy]
```

> [!warning] Permissions strictes requises Les fichiers dans `/etc/NetworkManager/system-connections/` doivent avoir les permissions 600 (lecture/écriture propriétaire uniquement) pour des raisons de sécurité.

```bash
# Définir les bonnes permissions
sudo chmod 600 /etc/NetworkManager/system-connections/*

# Recharger la configuration après modification
sudo nmcli connection reload

# Ou redémarrer NetworkManager
sudo systemctl restart NetworkManager
```

**Options DNS importantes :**

|Option|Description|Exemple|
|---|---|---|
|`dns`|Serveurs DNS séparés par des point-virgules|`dns=8.8.8.8;1.1.1.1;`|
|`dns-search`|Domaines de recherche|`dns-search=example.com;local;`|
|`dns-priority`|Priorité DNS (négatif = prioritaire)|`dns-priority=-50`|
|`ignore-auto-dns`|Ignorer DNS DHCP|`ignore-auto-dns=true`|

### Ordre de priorité DNS

NetworkManager gère plusieurs connexions simultanées et utilise un système de priorité pour déterminer quels DNS utiliser.

**Priorités par défaut :**

```bash
# Voir les priorités actuelles
nmcli -f name,device,ipv4.dns-priority connection show --active

# Définir une priorité personnalisée (plus bas = plus prioritaire)
sudo nmcli connection modify "Wired connection 1" ipv4.dns-priority -100

# VPN généralement prioritaire
sudo nmcli connection modify "VPN" ipv4.dns-priority -200

# Interface secondaire avec priorité basse
sudo nmcli connection modify "WiFi" ipv4.dns-priority 100
```

**Valeurs de priorité :**

|Priorité|Usage typique|
|---|---|
|-200|VPN (très prioritaire)|
|-100|Connexion principale|
|0|Défaut|
|50|Connexion secondaire|
|100|Connexion de secours|

> [!tip] Astuce : DNS split-horizon Utilisez les priorités pour avoir des DNS différents selon l'interface :
> 
> - DNS d'entreprise sur l'Ethernet (priorité haute) pour le domaine interne
> - DNS publics sur le WiFi (priorité basse) pour Internet

**Configuration DNS conditionnelle :**

```bash
# DNS uniquement pour certains domaines (avec systemd-resolved)
sudo nmcli connection modify "VPN" ipv4.dns-search "~corp.local"

# Le tilde (~) signifie "routage DNS" : 
# seules les requêtes pour corp.local utiliseront ce DNS
```

**Scripts de dispatcher NetworkManager :**

Pour des actions automatiques lors de changements réseau, créez des scripts dans `/etc/NetworkManager/dispatcher.d/` :

```bash
sudo nano /etc/NetworkManager/dispatcher.d/99-custom-dns
```

```bash
#!/bin/bash
# Script exécuté lors des événements réseau

INTERFACE=$1
STATUS=$2

if [ "$STATUS" = "up" ]; then
    # Connexion établie
    if [ "$INTERFACE" = "eth0" ]; then
        # Configuration spécifique pour eth0
        nmcli connection modify "$CONNECTION_ID" ipv4.dns "192.168.1.1"
    fi
fi
```

```bash
# Rendre le script exécutable
sudo chmod +x /etc/NetworkManager/dispatcher.d/99-custom-dns
```

---

## ⚠️ Pièges courants et bonnes pratiques

### Pièges courants

> [!warning] Piège #1 : Modifications écrasées **Problème :** Modifier `/etc/resolv.conf` directement alors qu'il est géré par systemd-resolved ou NetworkManager.
> 
> **Solution :** Configurer DNS via l'outil de gestion approprié (Netplan, nmcli, ou resolved.conf).

> [!warning] Piège #2 : Conflit entre outils **Problème :** Avoir NetworkManager ET systemd-networkd actifs simultanément, ou avoir plusieurs configurations qui se battent.
> 
> **Solution :** Choisir un seul outil de gestion et désactiver les autres.
> 
> ```bash
> # Vérifier les services actifs
> systemctl is-active NetworkManager
> systemctl is-active systemd-networkd
> 
> # Désactiver celui non utilisé
> sudo systemctl disable --now NetworkManager
> # OU
> sudo systemctl disable --now systemd-networkd
> ```

> [!warning] Piège #3 : Trop de serveurs DNS **Problème :** Lister 5-10 serveurs DNS en pensant améliorer la redondance.
> 
> **Solution :** Utiliser 2-3 serveurs maximum. Les systèmes Linux n'utilisent que les 3 premiers et n'essaient les suivants qu'après timeout.

> [!warning] Piège #4 : Oublier de redémarrer les services **Problème :** Modifier la configuration sans redémarrer le service concerné.
> 
> **Solution :** Toujours redémarrer ou recharger après modification.
> 
> ```bash
> sudo systemctl restart systemd-resolved
> sudo netplan apply
> sudo nmcli connection up "Wired connection 1"
> ```

> [!warning] Piège #5 : DNS IPv6 ignorés **Problème :** Configurer uniquement ipv4.dns alors que le système utilise IPv6.
> 
> **Solution :** Configurer également ipv6.dns si IPv6 est actif.
> 
> ```bash
> nmcli connection show "Wired connection 1" | grep -E "ipv[46]"
> ```

### Bonnes pratiques

> [!tip] Pratique #1 : Utiliser des DNS fiables **Recommandations de serveurs DNS publics :**
> 
> |Fournisseur|IPv4|IPv6|Particularités|
> |---|---|---|---|
> |Google|8.8.8.8, 8.8.4.4|2001:4860:4860::8888|Rapide, pas de filtrage|
> |Cloudflare|1.1.1.1, 1.0.0.1|2606:4700:4700::1111|Axé sur la vie privée|
> |Quad9|9.9.9.9, 149.112.112.112|2620:fe::fe|Filtrage malware|
> |OpenDNS|208.67.222.222, 208.67.220.220|2620:119:35::35|Contrôle parental|

> [!tip] Pratique #2 : Tester la résolution DNS
> 
> ```bash
> # Test simple
> nslookup example.com
> 
> # Test avec serveur spécifique
> nslookup example.com 8.8.8.8
> 
> # Test détaillé avec dig
> dig example.com
> 
> # Voir quel serveur DNS répond
> dig +short example.com
> 
> # Tracer le chemin de résolution
> dig +trace example.com
> 
> # Test avec host
> host example.com
> 
> # Vérifier le cache de systemd-resolved
> resolvectl query example.com
> ```

> [!tip] Pratique #3 : Documenter la configuration Ajouter des commentaires dans les fichiers de configuration :
> 
> ```yaml
> # /etc/netplan/01-netcfg.yaml
> # Configuration DNS mise à jour le 2025-01-15
> # Utilise les DNS Google pour la redondance
> network:
>   version: 2
>   renderer: networkd
>   ethernets:
>     eth0:
>       nameservers:
>         addresses: [8.8.8.8, 8.8.4.4]  # DNS Google
> ```

> [!tip] Pratique #4 : Sauvegarder avant modification
> 
> ```bash
> # Sauvegarder la configuration Netplan
> sudo cp -r /etc/netplan/ /etc/netplan.backup/
> 
> # Sauvegarder la configuration NetworkManager
> sudo cp -r /etc/NetworkManager/system-connections/ /etc/NetworkManager/system-connections.backup/
> 
> # Sauvegarder resolved.conf
> sudo cp /etc/systemd/resolved.conf /etc/systemd/resolved.conf.backup
> ```

> [!tip] Pratique #5 : Monitorer la résolution DNS
> 
> ```bash
> # Surveiller les requêtes DNS en temps réel
> sudo tcpdump -i any port 53
> 
> # Statistiques systemd-resolved
> resolvectl statistics
> 
> # Logs de systemd-resolved
> sudo journalctl -u systemd-resolved -f
> 
> # Logs NetworkManager
> sudo journalctl -u NetworkManager -f
> ```

> [!tip] Pratique #6 : Configuration pour serveurs Pour les serveurs en production, privilégier :
> 
> - Configuration statique via Netplan
> - systemd-networkd comme renderer (plus léger)
> - DNS multiples pour la redondance
> - Documentation de la configuration
> 
> ```yaml
> network:
>   version: 2
>   renderer: networkd
>   ethernets:
>     ens3:
>       dhcp4: no
>       addresses: [192.168.1.10/24]
>       routes:
>         - to: default
>           via: 192.168.1.1
>       nameservers:
>         # DNS primaire interne
>         addresses: [192.168.1.1, 8.8.8.8]
>         search: [prod.internal]
> ```

> [!tip] Pratique #7 : Vérifier la cohérence de la configuration
> 
> ```bash
> # Script de vérification rapide
> echo "=== Contenu de /etc/resolv.conf ==="
> cat /etc/resolv.conf
> 
> echo -e "\n=== Type de fichier resolv.conf ==="
> ls -l /etc/resolv.conf
> 
> echo -e "\n=== Status systemd-resolved ==="
> resolvectl status | head -n 20
> 
> echo -e "\n=== Configuration Netplan ==="
> sudo cat /etc/netplan/*.yaml 2>/dev/null || echo "Pas de Netplan"
> 
> echo -e "\n=== Connexions NetworkManager actives ==="
> nmcli -f NAME,DEVICE,IP4.DNS connection show --active 2>/dev/null || echo "NetworkManager non actif"
> 
> echo -e "\n=== Test de résolution ==="
> nslookup google.com
> ```

### Diagnostic des problèmes DNS

**Symptômes courants et solutions :**

|Symptôme|Cause probable|Solution|
|---|---|---|
|`Temporary failure in name resolution`|Pas de DNS configuré|Vérifier `/etc/resolv.conf` et `resolvectl status`|
|Résolution lente|Cache DNS désactivé ou DNS éloignés|Activer le cache systemd-resolved ou utiliser DNS plus proches|
|Certains domaines ne résolvent pas|Split-DNS mal configuré|Vérifier `dns-search` et les priorités dans NetworkManager|
|DNS changent après reboot|Configuration non persistante|Utiliser Netplan ou NetworkManager au lieu de modifier directement resolv.conf|
|`SERVFAIL` dans les logs|Problème DNSSEC|Passer DNSSEC à `allow-downgrade` dans resolved.conf|

**Commandes de diagnostic :**

```bash
# 1. Vérifier quel DNS est réellement utilisé
resolvectl status

# 2. Tester la résolution avec différents outils
nslookup google.com
dig google.com
host google.com

# 3. Vérifier la connectivité vers les DNS
ping -c 3 8.8.8.8
ping -c 3 1.1.1.1

# 4. Tracer la résolution DNS
dig +trace google.com

# 5. Vérifier les logs pour erreurs
sudo journalctl -u systemd-resolved -n 50
sudo journalctl -u NetworkManager -n 50

# 6. Tester avec un DNS spécifique
dig @8.8.8.8 google.com

# 7. Vérifier le cache
resolvectl statistics

# 8. Forcer un flush du cache
sudo resolvectl flush-caches
```

**Procédure de diagnostic complète :**

```bash
#!/bin/bash
# Script de diagnostic DNS

echo "=== 1. Configuration DNS actuelle ==="
resolvectl status | grep -A 10 "Global\|Link"

echo -e "\n=== 2. Contenu de /etc/resolv.conf ==="
cat /etc/resolv.conf

echo -e "\n=== 3. Type de gestion ==="
ls -l /etc/resolv.conf

echo -e "\n=== 4. Test de résolution ==="
nslookup google.com 2>&1 | head -n 10

echo -e "\n=== 5. Connectivité DNS ==="
for dns in 8.8.8.8 1.1.1.1 9.9.9.9; do
    echo -n "Test $dns: "
    ping -c 1 -W 2 $dns >/dev/null 2>&1 && echo "OK" || echo "FAIL"
done

echo -e "\n=== 6. Services actifs ==="
systemctl is-active systemd-resolved NetworkManager systemd-networkd

echo -e "\n=== 7. Dernières erreurs DNS ==="
sudo journalctl -u systemd-resolved --since "1 hour ago" | grep -i error | tail -n 5
```

> [!tip] Astuce : En cas de problème persistant
> 
> 1. Vider complètement le cache : `sudo resolvectl flush-caches`
> 2. Redémarrer systemd-resolved : `sudo systemctl restart systemd-resolved`
> 3. Tester avec un DNS public connu : `dig @8.8.8.8 google.com`
> 4. Si ça fonctionne avec un DNS public mais pas avec la config, le problème est dans la configuration locale
> 5. Si même avec un DNS public ça échoue, le problème est réseau (firewall, routage)

### Sécurité DNS

> [!info] Considérations de sécurité
> 
> - **DNS classique** : Non chiffré, visible par le FAI et intermédiaires
> - **DNSSEC** : Authentifie les réponses DNS mais ne chiffre pas
> - **DNS-over-TLS (DoT)** : Chiffre les requêtes DNS (port 853)
> - **DNS-over-HTTPS (DoH)** : Chiffre les requêtes via HTTPS (port 443)

**Activer DNSSEC avec systemd-resolved :**

```bash
sudo nano /etc/systemd/resolved.conf
```

```ini
[Resolve]
DNSSEC=yes
DNSOverTLS=opportunistic  # ou 'yes' pour forcer
```

```bash
sudo systemctl restart systemd-resolved

# Vérifier que DNSSEC fonctionne
resolvectl query sigfail.verteiltesysteme.net
# Devrait échouer (test DNSSEC)

resolvectl query sigok.verteiltesysteme.net
# Devrait réussir
```

**DNS-over-TLS avec systemd-resolved :**

```bash
sudo nano /etc/systemd/resolved.conf
```

```ini
[Resolve]
DNS=1.1.1.1#cloudflare-dns.com 8.8.8.8#dns.google
DNSOverTLS=yes
DNSSEC=yes
```

```bash
sudo systemctl restart systemd-resolved

# Vérifier avec tcpdump que le trafic passe sur port 853
sudo tcpdump -i any port 853
```

> [!warning] DoT vs DoH
> 
> - **DoT** (DNS-over-TLS) : Supporté nativement par systemd-resolved, port dédié 853
> - **DoH** (DNS-over-HTTPS) : Non supporté nativement, nécessite un proxy comme dnscrypt-proxy ou cloudflared
> - DoT est plus facile à bloquer (port dédié) mais plus facile à configurer
> - DoH est plus discret (utilise le port 443 HTTPS) mais plus complexe à mettre en place

### Performance DNS

**Optimiser les performances :**

```bash
# Activer le cache DNS
sudo nano /etc/systemd/resolved.conf
```

```ini
[Resolve]
Cache=yes
CacheFromLocalhost=no

# Augmenter la taille du cache (défaut: 4096)
# Nombre d'entrées en cache
# Cache=yes active déjà un cache de taille raisonnable
```

**Mesurer les performances DNS :**

```bash
# Installer namebench pour tester les DNS
sudo apt install namebench

# Ou utiliser dig pour mesurer manuellement
for i in {1..10}; do
    dig google.com | grep "Query time"
done

# Test de plusieurs DNS publics
for dns in 8.8.8.8 1.1.1.1 9.9.9.9; do
    echo "Test $dns:"
    dig @$dns google.com | grep "Query time"
done
```

**Benchmark simple en bash :**

```bash
#!/bin/bash
# Test de performance DNS

DNS_SERVERS="8.8.8.8 1.1.1.1 9.9.9.9 208.67.222.222"
TEST_DOMAINS="google.com amazon.com facebook.com github.com"

for dns in $DNS_SERVERS; do
    echo "Testing $dns..."
    total=0
    count=0
    
    for domain in $TEST_DOMAINS; do
        time=$(dig @$dns $domain | grep "Query time" | awk '{print $4}')
        if [ ! -z "$time" ]; then
            total=$((total + time))
            count=$((count + 1))
        fi
    done
    
    if [ $count -gt 0 ]; then
        avg=$((total / count))
        echo "$dns - Average: ${avg}ms"
    fi
    echo ""
done
```

---

## 🔍 Résumé et aide-mémoire

### Commandes essentielles

```bash
# === Vérification ===
resolvectl status                    # État complet DNS
cat /etc/resolv.conf                 # Voir DNS actuels
nslookup google.com                  # Test résolution

# === systemd-resolved ===
sudo systemctl restart systemd-resolved    # Redémarrer
sudo resolvectl flush-caches               # Vider cache
resolvectl statistics                      # Stats cache

# === Netplan ===
sudo netplan try                     # Tester config (safe)
sudo netplan apply                   # Appliquer config
sudo nano /etc/netplan/*.yaml        # Éditer config

# === NetworkManager ===
nmcli connection show                              # Lister connexions
nmcli connection show "Wired connection 1"         # Détails connexion
sudo nmcli connection modify "Con" ipv4.dns "8.8.8.8 1.1.1.1"  # Définir DNS
sudo nmcli connection up "Con"                     # Appliquer

# === Diagnostic ===
dig +trace google.com                # Tracer résolution
sudo journalctl -u systemd-resolved  # Logs
ping 8.8.8.8                        # Test connectivité DNS
```

### Fichiers de configuration importants

```bash
/etc/resolv.conf                              # Config DNS (souvent lien symb.)
/etc/systemd/resolved.conf                    # Config systemd-resolved
/etc/netplan/*.yaml                           # Config Netplan
/etc/NetworkManager/system-connections/       # Config NetworkManager
/run/systemd/resolve/stub-resolv.conf         # DNS stub systemd-resolved
/run/systemd/resolve/resolv.conf              # DNS uplink systemd-resolved
```

### Serveurs DNS publics recommandés

|Provider|Primaire|Secondaire|Caractéristique|
|---|---|---|---|
|**Cloudflare**|1.1.1.1|1.0.0.1|Rapide, privé|
|**Google**|8.8.8.8|8.8.4.4|Fiable, mondial|
|**Quad9**|9.9.9.9|149.112.112.112|Filtrage malware|
|**OpenDNS**|208.67.222.222|208.67.220.220|Contrôle parental|

### Décision rapide : Quel outil utiliser ?

```
Serveur avec IP fixe
└─→ Netplan + networkd

Desktop / Laptop
└─→ NetworkManager (GUI + CLI)

Besoin de cache DNS local
└─→ systemd-resolved (déjà actif)

Configuration temporaire
└─→ nmcli ou resolvectl

DNS différents par interface
└─→ NetworkManager avec priorités

Configuration complexe / Split-DNS
└─→ systemd-resolved + NetworkManager
```

### Troubleshooting rapide

```
Problème: Pas de résolution DNS
├─→ Vérifier: resolvectl status
├─→ Vérifier: cat /etc/resolv.conf
├─→ Tester: ping 8.8.8.8
└─→ Solution: Définir DNS manuellement

Problème: DNS lents
├─→ Vérifier: resolvectl statistics
├─→ Mesurer: dig google.com (Query time)
└─→ Solution: Changer de DNS ou activer cache

Problème: Configuration écrasée
├─→ Vérifier: ls -l /etc/resolv.conf
└─→ Solution: Utiliser Netplan ou NetworkManager

Problème: DNSSEC erreurs
├─→ Logs: journalctl -u systemd-resolved
└─→ Solution: DNSSEC=allow-downgrade
```

---

## 📚 Synthèse des concepts clés

> [!info] Points clés à retenir
> 
> 1. **systemd-resolved** est le gestionnaire DNS moderne d'Ubuntu
>     - Cache DNS intégré
>     - Support DNSSEC et DNS-over-TLS
>     - Gestion intelligente multi-interfaces
> 2. **/etc/resolv.conf** est généralement un lien symbolique
>     - Ne pas modifier directement sur systèmes modernes
>     - Utiliser les outils de gestion appropriés
> 3. **Netplan** pour configuration statique
>     - Format YAML déclaratif
>     - Idéal pour serveurs
>     - Utiliser `netplan try` pour tester
> 4. **NetworkManager** pour environnements dynamiques
>     - Interface CLI avec nmcli
>     - Gestion des priorités DNS
>     - Parfait pour desktops/laptops
> 5. **Ordre de priorité** : VPN > Ethernet > WiFi
>     - Utiliser dns-priority pour contrôler
>     - Split-DNS pour routage intelligent
> 6. **Toujours tester** après modification
>     - `nslookup`, `dig`, `resolvectl query`
>     - Vérifier les logs en cas de problème

---

_Configuration DNS sur Ubuntu - Version 2025_