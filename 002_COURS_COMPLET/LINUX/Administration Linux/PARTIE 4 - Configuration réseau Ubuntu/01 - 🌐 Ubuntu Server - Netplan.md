

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

## 🎯 Introduction à Netplan

Netplan est l'outil de configuration réseau par défaut sur Ubuntu Server depuis la version 17.10. Il remplace les anciennes méthodes de configuration (/etc/network/interfaces) et propose une approche déclarative basée sur des fichiers YAML.

> [!info] Pourquoi Netplan ?
> 
> - **Simplicité** : Configuration déclarative claire et lisible
> - **Abstraction** : Netplan agit comme une couche d'abstraction au-dessus des moteurs réseau (NetworkManager ou systemd-networkd)
> - **Validation** : Vérification de la syntaxe avant application
> - **Cohérence** : Format unifié pour toutes les configurations réseau

### Fonctionnement de Netplan

Netplan ne gère pas directement le réseau. Il génère la configuration pour l'un des deux moteurs réseau :

- **systemd-networkd** : Utilisé par défaut sur Ubuntu Server (léger, performant)
- **NetworkManager** : Utilisé sur Ubuntu Desktop

---

## 📁 Structure des fichiers YAML

### Emplacement des fichiers

Les fichiers de configuration Netplan se trouvent dans `/etc/netplan/` et suivent une nomenclature spécifique :

```bash
/etc/netplan/
├── 00-installer-config.yaml      # Fichier créé lors de l'installation
├── 01-netcfg.yaml                # Configuration personnalisée
└── 50-cloud-init.yaml            # Configuration cloud (si cloud-init présent)
```

> [!warning] Ordre de traitement Les fichiers sont traités par ordre alphabétique. Les numéros en préfixe permettent de contrôler l'ordre d'application. Un fichier `50-*` écrasera les paramètres d'un fichier `00-*` pour une même interface.

### Structure de base d'un fichier YAML

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    nom_interface:
      # Configuration de l'interface
```

> [!info] Éléments clés
> 
> - **network** : Bloc racine obligatoire
> - **version** : Toujours `2` (version actuelle du format)
> - **renderer** : `networkd` (server) ou `NetworkManager` (desktop)
> - **ethernets** : Type d'interface (peut aussi être `wifis`, `bonds`, `bridges`, `vlans`)

### Règles importantes du YAML

> [!warning] Syntaxe YAML stricte
> 
> - L'indentation doit être faite avec des **espaces** (jamais de tabulations)
> - Chaque niveau d'indentation = **2 espaces**
> - Les `:` doivent être suivis d'un espace
> - Respecter la casse (sensible aux majuscules/minuscules)

---

## 🔧 Configuration IP statique

### Cas d'usage

Une IP statique est nécessaire pour :

- Les serveurs (web, bases de données, DNS, etc.)
- Les équipements d'infrastructure (routeurs, pare-feu)
- Les services réseau critiques nécessitant une adresse fixe

### Configuration complète

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    ens33:                              # Nom de l'interface (varie selon le système)
      dhcp4: no                         # Désactive le DHCP IPv4
      dhcp6: no                         # Désactive le DHCP IPv6
      addresses:
        - 192.168.1.100/24              # Adresse IP + masque en notation CIDR
      routes:
        - to: default                   # Route par défaut
          via: 192.168.1.1              # Passerelle (gateway)
      nameservers:
        addresses:
          - 8.8.8.8                     # DNS primaire (Google)
          - 8.8.4.4                     # DNS secondaire (Google)
        search:
          - example.local               # Domaine de recherche DNS
```

> [!example] Exemple avec plusieurs adresses IP
> 
> ```yaml
> network:
>   version: 2
>   renderer: networkd
>   ethernets:
>     ens33:
>       dhcp4: no
>       addresses:
>         - 192.168.1.100/24
>         - 192.168.1.101/24
>         - 10.0.0.50/8
>       routes:
>         - to: default
>           via: 192.168.1.1
>       nameservers:
>         addresses: [8.8.8.8, 1.1.1.1]
> ```

### Paramètres détaillés

|Paramètre|Description|Exemple|
|---|---|---|
|`dhcp4`|Active/désactive DHCP IPv4|`yes` ou `no`|
|`dhcp6`|Active/désactive DHCP IPv6|`yes` ou `no`|
|`addresses`|Liste des adresses IP avec masque CIDR|`192.168.1.100/24`|
|`routes`|Configuration des routes|`to: default, via: IP`|
|`nameservers`|Serveurs DNS|`addresses: [IP1, IP2]`|
|`search`|Domaines de recherche DNS|`example.local`|

> [!tip] Notation CIDR
> 
> - `/24` = 255.255.255.0 (masque de sous-réseau classe C)
> - `/16` = 255.255.0.0 (masque de sous-réseau classe B)
> - `/8` = 255.0.0.0 (masque de sous-réseau classe A)

### Configuration avec route statique supplémentaire

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    ens33:
      dhcp4: no
      addresses:
        - 192.168.1.100/24
      routes:
        - to: default
          via: 192.168.1.1
        - to: 10.0.0.0/8                # Route vers un autre réseau
          via: 192.168.1.254
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]
```

---

## 📡 Configuration DHCP

### Cas d'usage

Le DHCP est adapté pour :

- Les postes de travail et stations clientes
- Les environnements de test et développement
- Les machines temporaires ou mobiles
- Les configurations où l'adresse IP n'a pas besoin d'être fixe

### Configuration minimale

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    ens33:
      dhcp4: yes                        # Active le DHCP IPv4
```

> [!info] Configuration par défaut Cette configuration minimale suffit dans la plupart des cas. Le serveur DHCP fournira automatiquement :
> 
> - L'adresse IP
> - Le masque de sous-réseau
> - La passerelle par défaut
> - Les serveurs DNS

### Configuration DHCP IPv4 et IPv6

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    ens33:
      dhcp4: yes                        # DHCP pour IPv4
      dhcp6: yes                        # DHCP pour IPv6
```

### Configuration DHCP avec options avancées

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    ens33:
      dhcp4: yes
      dhcp4-overrides:
        use-dns: no                     # N'utilise pas les DNS fournis par DHCP
        use-routes: yes                 # Accepte les routes du serveur DHCP
      nameservers:
        addresses:
          - 1.1.1.1                     # DNS personnalisé (Cloudflare)
          - 1.0.0.1
```

> [!tip] Options de surcharge DHCP Les `dhcp4-overrides` permettent de personnaliser certains paramètres tout en gardant le DHCP :
> 
> - `use-dns: no` : Ignorer les DNS du serveur DHCP
> - `use-routes: no` : Ignorer les routes du serveur DHCP
> - `use-hostname: no` : Ne pas accepter le hostname du serveur DHCP
> - `use-ntp: no` : Ignorer les serveurs NTP du DHCP

### Configuration DHCP avec DNS statiques

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    ens33:
      dhcp4: yes
      dhcp4-overrides:
        use-dns: no
      nameservers:
        addresses: [9.9.9.9, 149.112.112.112]    # Quad9 DNS
        search: [lan.local]
```

### Tableau comparatif DHCP vs IP statique

|Critère|DHCP|IP Statique|
|---|---|---|
|Configuration|Automatique|Manuelle|
|Maintenance|Faible|Moyenne|
|Flexibilité|Haute|Faible|
|Prévisibilité|Faible|Haute|
|Usage recommandé|Clients|Serveurs|

---

## ⚙️ Application des changements

### Commande `netplan apply`

Cette commande applique immédiatement la configuration sans possibilité de retour arrière :

```bash
sudo netplan apply
```

> [!warning] Risque de perte de connexion Sur un serveur distant (SSH), l'utilisation de `netplan apply` avec une configuration erronée peut vous déconnecter définitivement. Privilégiez `netplan try` dans ce cas.

**Workflow typique** :

```bash
# 1. Éditer la configuration
sudo nano /etc/netplan/00-installer-config.yaml

# 2. Vérifier la syntaxe
sudo netplan generate

# 3. Appliquer les changements
sudo netplan apply
```

### Commande `netplan try`

Cette commande applique la configuration temporairement et demande confirmation :

```bash
sudo netplan try
```

**Fonctionnement** :

1. La nouvelle configuration est appliquée
2. Un compte à rebours de 120 secondes démarre
3. Vous devez taper `Entrée` pour confirmer
4. Si pas de confirmation : retour automatique à l'ancienne configuration

> [!tip] Sécurité recommandée Utilisez **toujours** `netplan try` lors de modifications réseau sur un serveur distant. C'est une protection contre les erreurs de configuration qui vous couperaient de votre serveur.

```bash
# Application sécurisée avec délai personnalisé (60 secondes)
sudo netplan try --timeout 60
```

### Commande `netplan generate`

Génère la configuration pour le moteur réseau (systemd-networkd ou NetworkManager) sans l'appliquer :

```bash
sudo netplan generate
```

> [!info] Utilité
> 
> - Valide la syntaxe YAML
> - Génère les fichiers dans `/run/systemd/network/` ou `/run/NetworkManager/`
> - Permet de vérifier avant application
> - Utile pour déboguer les problèmes de configuration

### Commande `netplan --debug apply`

Active le mode verbeux pour diagnostiquer les problèmes :

```bash
sudo netplan --debug apply
```

Cette commande affiche des informations détaillées sur le processus d'application de la configuration.

### Vérification de la configuration appliquée

```bash
# Afficher l'adresse IP actuelle
ip addr show

# Afficher les routes
ip route show

# Tester la connectivité
ping -c 4 8.8.8.8

# Vérifier la résolution DNS
nslookup google.com
```

### Commandes de diagnostic

```bash
# Vérifier le statut de l'interface
networkctl status ens33

# Afficher toutes les interfaces
networkctl list

# Journaux de systemd-networkd
journalctl -u systemd-networkd -f
```

---

## ⚠️ Pièges courants

### 1. Erreurs d'indentation

> [!warning] Problème fréquent n°1 Les erreurs d'indentation sont la cause la plus courante d'échec de configuration.

❌ **Mauvais exemple** (tabulations ou mauvaise indentation) :

```yaml
network:
  version: 2
    ethernets:     # Mauvaise indentation
      ens33:
```

✅ **Bon exemple** :

```yaml
network:
  version: 2
  ethernets:       # 2 espaces d'indentation
    ens33:         # 4 espaces d'indentation
```

### 2. Nom d'interface incorrect

Les noms d'interfaces modernes suivent la nomenclature "Predictable Network Interface Names" :

```bash
# Lister les interfaces disponibles
ip link show

# ou
networkctl list
```

Exemples de noms :

- `ens33`, `ens18` : Interface Ethernet sur bus PCI
- `enp0s3`, `enp2s0` : Interface Ethernet, position PCI spécifique
- `eth0`, `eth1` : Ancien format (rare sur systèmes récents)

> [!tip] Vérification du nom Toujours vérifier le nom exact de votre interface avant de configurer Netplan. Un nom incorrect rendra la configuration inefficace.

### 3. Oublier le masque CIDR

❌ **Mauvais** :

```yaml
addresses:
  - 192.168.1.100      # Masque manquant !
```

✅ **Bon** :

```yaml
addresses:
  - 192.168.1.100/24   # Avec notation CIDR
```

### 4. Conflits avec cloud-init

Sur les instances cloud (AWS, Azure, OpenStack), cloud-init peut gérer automatiquement le réseau :

```bash
# Vérifier si cloud-init gère le réseau
ls -la /etc/netplan/

# Si présent : 50-cloud-init.yaml
```

> [!warning] Cloud-init prioritaire Si cloud-init est actif, il peut écraser vos configurations Netplan. Pour désactiver la gestion réseau par cloud-init :

```bash
# Créer un fichier de configuration cloud-init
sudo nano /etc/cloud/cloud.cfg.d/99-disable-network-config.cfg
```

```yaml
network: {config: disabled}
```

### 5. Syntaxe des routes

❌ **Mauvais** :

```yaml
routes:
  - to: 0.0.0.0/0              # Ancienne syntaxe
    via: 192.168.1.1
```

✅ **Bon** (Netplan moderne) :

```yaml
routes:
  - to: default                # Syntaxe moderne recommandée
    via: 192.168.1.1
```

### 6. Permissions des fichiers

Les fichiers Netplan doivent avoir les bonnes permissions :

```bash
# Vérifier les permissions
ls -l /etc/netplan/

# Corriger si nécessaire (600 ou 644)
sudo chmod 600 /etc/netplan/*.yaml
```

> [!info] Sécurité Les fichiers Netplan peuvent contenir des informations sensibles (clés WiFi, etc.). Des permissions restrictives sont recommandées.

### 7. Ne pas tester avant déconnexion

> [!warning] Erreur critique sur serveur distant Ne jamais se déconnecter d'un serveur SSH sans avoir testé la nouvelle configuration réseau !

**Procédure sécurisée** :

```bash
# 1. Utiliser netplan try (avec confirmation)
sudo netplan try

# 2. Ouvrir une NOUVELLE session SSH dans un autre terminal
ssh user@server

# 3. Si la connexion fonctionne, confirmer dans le premier terminal
# 4. Seulement après, fermer les sessions
```

### 8. Format des listes YAML

Deux syntaxes valides pour les listes :

**Style sur plusieurs lignes** (recommandé pour la lisibilité) :

```yaml
nameservers:
  addresses:
    - 8.8.8.8
    - 8.8.4.4
```

**Style inline** (compact) :

```yaml
nameservers:
  addresses: [8.8.8.8, 8.8.4.4]
```

> [!tip] Les deux sont valides Choisissez le style qui vous semble le plus lisible. Le style sur plusieurs lignes est généralement préféré pour les configurations complexes.

---

## 🎯 Bonnes pratiques

### Sauvegarde avant modification

```bash
# Sauvegarder la configuration actuelle
sudo cp /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.backup

# Avec horodatage
sudo cp /etc/netplan/00-installer-config.yaml /etc/netplan/00-installer-config.yaml.$(date +%Y%m%d)
```

### Validation de la syntaxe

```bash
# Valider sans appliquer
sudo netplan generate

# Si pas d'erreur, la syntaxe est correcte
```

### Documentation des changements

Ajouter des commentaires dans les fichiers YAML :

```yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    ens33:
      # Configuration serveur web - IP statique requise
      # Modifié le 2024-12-26 par admin
      dhcp4: no
      addresses:
        - 192.168.1.100/24
      routes:
        - to: default
          via: 192.168.1.1  # Gateway principale Cisco
      nameservers:
        addresses: [8.8.8.8, 8.8.4.4]  # Google DNS
```

### Utilisation de fichiers multiples

Pour une meilleure organisation, séparez les configurations par rôle :

```bash
/etc/netplan/
├── 01-main-interface.yaml        # Interface principale
├── 02-secondary-interface.yaml   # Interface secondaire
└── 03-vlan-config.yaml           # Configuration VLAN
```

> [!tip] Nomenclature Utilisez des noms de fichiers explicites avec des numéros de priorité pour maintenir l'ordre et la clarté.

---

## 📊 Récapitulatif des commandes essentielles

|Commande|Usage|Sécurité|
|---|---|---|
|`netplan generate`|Valider la syntaxe|✅ Sûr|
|`netplan try`|Appliquer avec confirmation|✅ Sûr|
|`netplan apply`|Appliquer définitivement|⚠️ Risqué en distant|
|`netplan --debug apply`|Diagnostic verbeux|⚠️ Risqué en distant|
|`ip addr show`|Vérifier les IP|✅ Sûr|
|`ip route show`|Vérifier les routes|✅ Sûr|
|`networkctl status`|Statut interface|✅ Sûr|

---

**💡 Astuce finale** : Gardez toujours une sauvegarde de votre configuration réseau fonctionnelle et utilisez `netplan try` pour toute modification sur un serveur distant. Une erreur de configuration réseau peut rendre votre serveur inaccessible !