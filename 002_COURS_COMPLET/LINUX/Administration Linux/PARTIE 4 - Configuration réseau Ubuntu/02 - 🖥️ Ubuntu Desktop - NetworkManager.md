

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

## Introduction à NetworkManager

NetworkManager est le gestionnaire réseau par défaut sur Ubuntu Desktop. Il offre une approche dynamique et automatisée de la configuration réseau, contrairement à Netplan qui est plus statique.

> [!info] Différence avec Netplan Sur Ubuntu Desktop, NetworkManager **prend le contrôle** de la configuration réseau et Netplan agit comme un simple "renderer" pour NetworkManager. Sur Ubuntu Server, c'est l'inverse : Netplan gère directement la configuration via systemd-networkd.

### Pourquoi NetworkManager sur Desktop ?

NetworkManager est conçu pour les environnements où la configuration réseau change fréquemment :

- Connexion/déconnexion de réseaux WiFi
- Changement de réseaux (bureau, maison, café)
- Gestion automatique du VPN
- Détection et configuration automatique des interfaces

> [!tip] Quand utiliser NetworkManager ?
> 
> - Environnements desktop avec interface graphique
> - Ordinateurs portables qui changent fréquemment de réseau
> - Besoin de gestion WiFi simplifiée
> - Utilisateurs non-techniques qui préfèrent une interface graphique

---

## Interface graphique de configuration

L'interface graphique de NetworkManager est accessible via l'icône réseau dans la barre système GNOME.

### Accéder aux paramètres réseau

**Méthode 1 : Via l'icône système**

1. Cliquez sur l'icône réseau dans la barre supérieure
2. Sélectionnez "Paramètres Réseau" ou "Wired Settings"/"Wi-Fi Settings"

**Méthode 2 : Via les paramètres système**

1. Ouvrez "Paramètres" (Settings)
2. Naviguez vers "Réseau" (Network)

### Configuration d'une connexion Ethernet

> [!example] Configuration IP statique via l'interface graphique

**Étapes détaillées :**

1. **Accéder à la connexion**
    
    - Ouvrez Paramètres > Réseau
    - Cliquez sur l'icône ⚙️ à côté de votre connexion filaire
2. **Onglet IPv4**
    
    - Méthode : Sélectionnez "Manuel" (Manual)
    - Cliquez sur "Ajouter" dans la section Adresses
3. **Remplir les informations**
    
    - **Adresse** : `192.168.1.100`
    - **Masque de réseau** : `255.255.255.0` ou `24`
    - **Passerelle** : `192.168.1.1`
4. **Serveurs DNS**
    
    - Désactivez "Automatique"
    - Ajoutez les DNS : `8.8.8.8, 8.8.4.4`
5. **Appliquer**
    
    - Cliquez sur "Appliquer"
    - Désactivez/réactivez la connexion pour appliquer

> [!warning] Attention au DHCP actif Si vous configurez une IP statique alors qu'un serveur DHCP est actif, assurez-vous que l'IP choisie est en dehors de la plage DHCP pour éviter les conflits.

### Configuration WiFi

L'interface graphique permet également de gérer les connexions WiFi :

**Fonctionnalités principales :**

- Liste des réseaux disponibles avec indication de la force du signal
- Connexion automatique aux réseaux connus
- Configuration de la sécurité (WPA2, WPA3, Enterprise)
- Gestion des priorités de connexion

> [!tip] Réseau WiFi caché Pour vous connecter à un réseau caché :
> 
> 1. Cliquez sur "Connecter à un réseau caché"
> 2. Entrez le SSID exactement comme configuré
> 3. Sélectionnez le type de sécurité
> 4. Entrez le mot de passe

### Paramètres avancés

L'interface graphique donne accès à des options avancées :

|Paramètre|Description|Usage|
|---|---|---|
|**MTU**|Taille maximale des paquets|Performance sur certains réseaux|
|**Cloned MAC Address**|Modifier l'adresse MAC|Confidentialité ou contournement de restrictions|
|**Routes**|Routes statiques personnalisées|Routage avancé|
|**IPv6**|Configuration IPv6|Activer/désactiver ou configurer IPv6|

> [!warning] Modification de la MAC Changer l'adresse MAC peut violer certaines politiques réseau. Utilisez cette fonctionnalité uniquement quand c'est légitime et autorisé.

---

## Commande nmcli en ligne de commande

`nmcli` (NetworkManager Command Line Interface) est l'outil en ligne de commande pour gérer NetworkManager. C'est un outil puissant pour scripter et automatiser la configuration réseau.

### Structure générale de nmcli

```bash
nmcli [OPTIONS] OBJET { COMMANDE | help }
```

**Objets principaux :**

- `general` : État général de NetworkManager
- `networking` : Contrôle réseau global
- `connection` : Gestion des connexions
- `device` : Gestion des interfaces physiques

### Commandes de base

#### Vérifier l'état de NetworkManager

```bash
# État général
nmcli general status

# Vérifier si le réseau est activé
nmcli networking

# Permissions de l'utilisateur
nmcli general permissions
```

> [!example] Sortie typique de `nmcli general status`
> 
> ```
> STATE      CONNECTIVITY  WIFI-HW  WIFI     WWAN-HW  WWAN    
> connected  full          enabled  enabled  enabled  enabled
> ```

#### Lister les connexions

```bash
# Toutes les connexions (actives et inactives)
nmcli connection show

# Seulement les connexions actives
nmcli connection show --active

# Détails d'une connexion spécifique
nmcli connection show "Wired connection 1"
```

**Comprendre la sortie :**

```bash
NAME                UUID                                  TYPE      DEVICE 
Wired connection 1  5fb06bd0-0bb0-7ffb-45f1-d6edd65f3e03  ethernet  enp0s3
MyWiFi              a1b2c3d4-5e6f-7g8h-9i0j-k1l2m3n4o5p6  wifi      wlp2s0
```

- **NAME** : Nom de la connexion (modifiable)
- **UUID** : Identifiant unique (permanent)
- **TYPE** : Type de connexion (ethernet, wifi, vpn, etc.)
- **DEVICE** : Interface réseau associée

#### Lister les interfaces (devices)

```bash
# Toutes les interfaces
nmcli device status

# Détails d'une interface
nmcli device show enp0s3
```

> [!info] Différence entre connection et device
> 
> - **Device** : Interface physique ou virtuelle (enp0s3, wlp2s0)
> - **Connection** : Profil de configuration qui peut être appliqué à un device
> 
> Une interface peut avoir plusieurs connexions configurées (bureau, maison), mais une seule active à la fois.

### Créer une connexion

#### Connexion Ethernet avec IP statique

```bash
nmcli connection add \
    type ethernet \
    con-name "Bureau-Statique" \
    ifname enp0s3 \
    ipv4.method manual \
    ipv4.addresses 192.168.1.100/24 \
    ipv4.gateway 192.168.1.1 \
    ipv4.dns "8.8.8.8,8.8.4.4"
```

**Décomposition des paramètres :**

- `type ethernet` : Type de connexion
- `con-name` : Nom de la connexion (affiché dans la liste)
- `ifname` : Interface réseau à utiliser
- `ipv4.method manual` : IP statique (vs `auto` pour DHCP)
- `ipv4.addresses` : IP et masque en notation CIDR
- `ipv4.gateway` : Passerelle par défaut
- `ipv4.dns` : Serveurs DNS (séparés par des virgules)

> [!tip] Notation CIDR Le `/24` correspond à un masque `255.255.255.0`. Équivalences courantes :
> 
> - `/24` = `255.255.255.0` (254 hôtes)
> - `/16` = `255.255.0.0` (65534 hôtes)
> - `/8` = `255.0.0.0` (16777214 hôtes)

#### Connexion Ethernet avec DHCP

```bash
nmcli connection add \
    type ethernet \
    con-name "Maison-DHCP" \
    ifname enp0s3 \
    ipv4.method auto
```

Beaucoup plus simple ! NetworkManager obtiendra automatiquement l'IP, la passerelle et les DNS du serveur DHCP.

#### Connexion WiFi

```bash
# WiFi avec WPA2-PSK
nmcli connection add \
    type wifi \
    con-name "MonWiFi" \
    ifname wlp2s0 \
    ssid "NomDuReseau" \
    wifi-sec.key-mgmt wpa-psk \
    wifi-sec.psk "MotDePasseWiFi" \
    ipv4.method auto
```

**Paramètres WiFi supplémentaires :**

- `ssid` : Nom du réseau (sensible à la casse)
- `wifi-sec.key-mgmt` : Type de sécurité (`wpa-psk`, `wpa-eap`, `none`)
- `wifi-sec.psk` : Mot de passe (Pre-Shared Key)

> [!warning] Sécurité du mot de passe Le mot de passe WiFi sera stocké en clair ou faiblement chiffré dans les fichiers de configuration. Protégez vos fichiers de configuration avec des permissions appropriées.

### Modifier une connexion

```bash
# Modifier l'adresse IP
nmcli connection modify "Bureau-Statique" \
    ipv4.addresses 192.168.1.150/24

# Ajouter un DNS supplémentaire
nmcli connection modify "Bureau-Statique" \
    +ipv4.dns 1.1.1.1

# Changer la passerelle
nmcli connection modify "Bureau-Statique" \
    ipv4.gateway 192.168.1.254

# Activer la connexion automatique au démarrage
nmcli connection modify "Bureau-Statique" \
    connection.autoconnect yes
```

> [!tip] Symboles + et -
> 
> - `+ipv4.dns` : **Ajoute** un DNS sans supprimer les existants
> - `-ipv4.dns` : **Supprime** un DNS spécifique
> - `ipv4.dns` : **Remplace** tous les DNS par la nouvelle valeur

### Activer/Désactiver une connexion

```bash
# Activer une connexion
nmcli connection up "Bureau-Statique"

# Désactiver une connexion
nmcli connection down "Bureau-Statique"

# Redémarrer une connexion (équivalent à down puis up)
nmcli connection reload "Bureau-Statique"
nmcli connection up "Bureau-Statique"
```

> [!info] Activation automatique NetworkManager active automatiquement la dernière connexion utilisée au démarrage, sauf si `connection.autoconnect` est défini sur `no`.

### Supprimer une connexion

```bash
# Supprimer une connexion
nmcli connection delete "Maison-DHCP"

# Supprimer par UUID
nmcli connection delete 5fb06bd0-0bb0-7ffb-45f1-d6edd65f3e03
```

> [!warning] Suppression définitive La suppression d'une connexion est **irréversible** et supprime immédiatement le fichier de configuration. Assurez-vous d'avoir sauvegardé les paramètres si nécessaire.

### Gestion des interfaces (devices)

```bash
# Désactiver une interface
nmcli device disconnect enp0s3

# Réactiver une interface
nmcli device connect enp0s3

# Scanner les réseaux WiFi disponibles
nmcli device wifi list

# Se connecter à un WiFi disponible
nmcli device wifi connect "NomSSID" password "MotDePasse"
```

> [!example] Connexion WiFi rapide La commande `nmcli device wifi connect` crée automatiquement une nouvelle connexion et l'active, c'est plus rapide que de créer explicitement une connexion.

### Options de sortie utiles

```bash
# Format compact (une ligne par connexion)
nmcli -t connection show

# Format personnalisé avec champs spécifiques
nmcli -f NAME,TYPE,DEVICE connection show

# Sortie en mode parsable pour scripts
nmcli -t -f NAME,UUID connection show

# Couleurs désactivées (pour scripts)
nmcli --colors no connection show
```

**Exemples de formats :**

```bash
# Standard
NAME                UUID                                  TYPE      DEVICE 
Wired connection 1  5fb06bd0-0bb0-7ffb-45f1-d6edd65f3e03  ethernet  enp0s3

# Compact (-t)
Wired connection 1:5fb06bd0-0bb0-7ffb-45f1-d6edd65f3e03:ethernet:enp0s3

# Champs personnalisés (-f)
NAME                TYPE      DEVICE 
Wired connection 1  ethernet  enp0s3
```

### Cas d'usage avancés

#### Configuration de routes statiques

```bash
# Ajouter une route statique
nmcli connection modify "Bureau-Statique" \
    +ipv4.routes "10.0.0.0/8 192.168.1.254"

# Plusieurs routes
nmcli connection modify "Bureau-Statique" \
    +ipv4.routes "10.0.0.0/8 192.168.1.254, 172.16.0.0/12 192.168.1.254"
```

#### Désactiver IPv6

```bash
nmcli connection modify "Bureau-Statique" \
    ipv6.method disabled
```

#### Cloner une adresse MAC

```bash
nmcli connection modify "Bureau-Statique" \
    802-3-ethernet.cloned-mac-address "00:11:22:33:44:55"
```

#### Modifier le MTU

```bash
nmcli connection modify "Bureau-Statique" \
    802-3-ethernet.mtu 1400
```

> [!tip] MTU et performance Le MTU par défaut est 1500. Réduire le MTU peut résoudre des problèmes de connexion sur certains réseaux (VPN, tunnels), mais peut réduire les performances.

---

## Fichiers de configuration NetworkManager

NetworkManager stocke ses configurations dans plusieurs emplacements. Comprendre ces fichiers permet un dépannage efficace et des modifications avancées.

### Architecture des fichiers

```
/etc/NetworkManager/
├── NetworkManager.conf          # Configuration principale
├── system-connections/          # Connexions système (root)
│   ├── Wired connection 1.nmconnection
│   └── MonWiFi.nmconnection
├── conf.d/                      # Configurations supplémentaires
└── dispatcher.d/                # Scripts exécutés lors d'événements
```

### NetworkManager.conf

Le fichier principal de configuration : `/etc/NetworkManager/NetworkManager.conf`

> [!example] Exemple de fichier NetworkManager.conf

```ini
[main]
plugins=ifupdown,keyfile
dns=default

[ifupdown]
managed=false

[device]
wifi.scan-rand-mac-address=no
```

**Sections principales :**

|Section|Description|
|---|---|
|`[main]`|Configuration générale de NetworkManager|
|`[logging]`|Niveau de journalisation|
|`[connectivity]`|Vérification de la connectivité Internet|
|`[device]`|Comportement des interfaces|

**Options importantes de [main] :**

```ini
[main]
# Plugins à utiliser
plugins=ifupdown,keyfile

# Gestion du DNS (default, dnsmasq, systemd-resolved)
dns=default

# Ne pas gérer les interfaces dans /etc/network/interfaces
no-auto-default=*
```

> [!info] Plugin keyfile Le plugin `keyfile` est responsable de la lecture/écriture des fichiers `.nmconnection`. C'est le format moderne de NetworkManager.

### Fichiers de connexion (.nmconnection)

Les connexions sont stockées dans `/etc/NetworkManager/system-connections/` avec l'extension `.nmconnection`.

> [!warning] Permissions critiques Ces fichiers **doivent** avoir les permissions `600` (lecture/écriture pour root uniquement) car ils contiennent des informations sensibles (mots de passe WiFi, clés VPN).
> 
> ```bash
> -rw------- 1 root root 312 Dec 10 10:30 MonWiFi.nmconnection
> ```

#### Structure d'un fichier .nmconnection

> [!example] Connexion Ethernet avec IP statique

```ini
[connection]
id=Bureau-Statique
uuid=5fb06bd0-0bb0-7ffb-45f1-d6edd65f3e03
type=ethernet
autoconnect=true
interface-name=enp0s3
timestamp=1702195847

[ethernet]
mac-address=08:00:27:3D:9C:A1

[ipv4]
address1=192.168.1.100/24,192.168.1.1
dns=8.8.8.8;8.8.4.4;
method=manual

[ipv6]
addr-gen-mode=stable-privacy
method=auto

[proxy]
```

**Décomposition des sections :**

**`[connection]`** : Métadonnées de la connexion

- `id` : Nom affiché de la connexion
- `uuid` : Identifiant unique permanent
- `type` : Type de connexion (ethernet, wifi, vpn, etc.)
- `autoconnect` : Activation automatique au démarrage
- `interface-name` : Interface réseau spécifique (optionnel)
- `timestamp` : Dernière utilisation (timestamp Unix)

**`[ethernet]`** : Paramètres Ethernet spécifiques

- `mac-address` : Adresse MAC de l'interface
- `mtu` : Taille maximale des paquets (optionnel)
- `cloned-mac-address` : MAC personnalisée (optionnel)

**`[ipv4]`** : Configuration IPv4

- `method` : `manual` (statique), `auto` (DHCP), `link-local`, `shared`, `disabled`
- `address1` : Format `IP/MASQUE,PASSERELLE`
- `dns` : Serveurs DNS séparés par `;`
- `dns-search` : Domaines de recherche DNS

**`[ipv6]`** : Configuration IPv6

- `method` : `auto`, `dhcp`, `link-local`, `manual`, `disabled`
- `addr-gen-mode` : Mode de génération d'adresse

> [!example] Connexion WiFi avec WPA2-PSK

```ini
[connection]
id=MonWiFi
uuid=a1b2c3d4-5e6f-7g8h-9i0j-k1l2m3n4o5p6
type=wifi
autoconnect=true
permissions=

[wifi]
mode=infrastructure
ssid=NomDuReseau

[wifi-security]
key-mgmt=wpa-psk
psk=MotDePasseWiFi

[ipv4]
method=auto

[ipv6]
addr-gen-mode=stable-privacy
method=auto
```

**Sections WiFi supplémentaires :**

**`[wifi]`** : Paramètres WiFi

- `ssid` : Nom du réseau (en clair ou hex)
- `mode` : `infrastructure` (normal), `ap` (point d'accès), `adhoc`
- `band` : `a` (5GHz) ou `bg` (2.4GHz)
- `channel` : Canal spécifique (optionnel)
- `hidden` : Réseau caché (`true`/`false`)

**`[wifi-security]`** : Sécurité WiFi

- `key-mgmt` : Type de clé (`wpa-psk`, `wpa-eap`, `none`, `sae`)
- `psk` : Mot de passe pré-partagé (WPA-PSK)
- `auth-alg` : Algorithme d'authentification

> [!warning] Stockage des mots de passe Les mots de passe WiFi sont stockés **en clair** dans les fichiers `.nmconnection`. C'est pourquoi les permissions `600` sont cruciales. Ne partagez jamais ces fichiers sans supprimer les sections sensibles.

### Modifier manuellement les fichiers

Vous pouvez modifier directement les fichiers `.nmconnection`, mais suivez ces règles :

**Procédure sécurisée :**

```bash
# 1. Arrêter NetworkManager (optionnel mais recommandé)
sudo systemctl stop NetworkManager

# 2. Éditer le fichier
sudo nano /etc/NetworkManager/system-connections/Bureau-Statique.nmconnection

# 3. Vérifier les permissions (CRITIQUE)
sudo chmod 600 /etc/NetworkManager/system-connections/Bureau-Statique.nmconnection
sudo chown root:root /etc/NetworkManager/system-connections/Bureau-Statique.nmconnection

# 4. Recharger les configurations
sudo systemctl restart NetworkManager

# 5. Recharger la connexion spécifique
nmcli connection reload
nmcli connection up "Bureau-Statique"
```

> [!warning] Erreurs de syntaxe NetworkManager peut refuser de charger des connexions avec des erreurs de syntaxe. Vérifiez les logs avec `journalctl -u NetworkManager` en cas de problème.

### Fichiers de configuration supplémentaires

#### dispatcher.d - Scripts d'événements

Le dossier `/etc/NetworkManager/dispatcher.d/` contient des scripts exécutés lors d'événements réseau.

> [!example] Script dispatcher pour monter un partage NFS

```bash
#!/bin/bash
# /etc/NetworkManager/dispatcher.d/10-mount-nfs

IF=$1
STATUS=$2

if [ "$IF" = "enp0s3" ] && [ "$STATUS" = "up" ]; then
    mount -t nfs 192.168.1.50:/data /mnt/nfs
fi

if [ "$IF" = "enp0s3" ] && [ "$STATUS" = "down" ]; then
    umount /mnt/nfs
fi
```

**Événements disponibles :**

- `up` : Interface activée
- `down` : Interface désactivée
- `pre-up` : Avant l'activation
- `post-down` : Après la désactivation
- `vpn-up` : VPN connecté
- `vpn-down` : VPN déconnecté

> [!tip] Permissions des scripts dispatcher Les scripts dispatcher doivent être **exécutables** et appartenir à root :
> 
> ```bash
> sudo chmod +x /etc/NetworkManager/dispatcher.d/10-mount-nfs
> sudo chown root:root /etc/NetworkManager/dispatcher.d/10-mount-nfs
> ```

#### conf.d - Configurations modulaires

Le dossier `/etc/NetworkManager/conf.d/` permet d'ajouter des configurations sans modifier `NetworkManager.conf`.

> [!example] Désactiver la gestion du WiFi

```ini
# /etc/NetworkManager/conf.d/disable-wifi.conf
[device]
wifi.scan-rand-mac-address=no

[main]
plugins=keyfile
```

Les fichiers sont chargés par ordre alphabétique. Les paramètres surchargent ceux de `NetworkManager.conf`.

### Localisation des logs

NetworkManager écrit dans le journal systemd. Consultez les logs avec :

```bash
# Logs en temps réel
journalctl -u NetworkManager -f

# Logs récents
journalctl -u NetworkManager -n 50

# Logs depuis le dernier boot
journalctl -u NetworkManager -b

# Rechercher des erreurs
journalctl -u NetworkManager -p err
```

> [!tip] Augmenter le niveau de log Pour un débogage approfondi, modifiez `/etc/NetworkManager/NetworkManager.conf` :
> 
> ```ini
> [logging]
> level=DEBUG
> ```
> 
> Puis redémarrez : `sudo systemctl restart NetworkManager`

### Sauvegarde et restauration

**Sauvegarder toutes les connexions :**

```bash
# Créer une archive des connexions
sudo tar -czf nm-connections-backup.tar.gz \
    /etc/NetworkManager/system-connections/

# Sauvegarder la configuration principale
sudo cp /etc/NetworkManager/NetworkManager.conf \
    NetworkManager.conf.backup
```

**Restaurer des connexions :**

```bash
# Restaurer l'archive
sudo tar -xzf nm-connections-backup.tar.gz -C /

# Corriger les permissions
sudo chmod 600 /etc/NetworkManager/system-connections/*
sudo chown root:root /etc/NetworkManager/system-connections/*

# Recharger
sudo systemctl restart NetworkManager
nmcli connection reload
```

> [!warning] Conflit d'UUID Si vous restaurez des connexions sur un autre système, les UUID peuvent entrer en conflit. Régénérez les UUID avec :
> 
> ```bash
> nmcli connection modify "Nom-Connexion" connection.uuid $(uuidgen)
> ```

### Pièges courants

> [!warning] Problèmes fréquents avec les fichiers de configuration

**1. Permissions incorrectes**

```bash
# Symptôme : NetworkManager ignore la connexion
# Solution :
sudo chmod 600 /etc/NetworkManager/system-connections/*.nmconnection
```

**2. Caractères spéciaux dans le nom**

```bash
# Problème : Noms avec espaces ou caractères spéciaux
# Mauvais : "Mon WiFi Perso"
# Bon : "MonWiFiPerso" ou utiliser l'UUID
```

**3. Modifications non rechargées**

```bash
# Après modification manuelle, TOUJOURS recharger :
sudo nmcli connection reload
```

**4. Syntaxe INI stricte**

```ini
# Mauvais (espaces autour de =)
id = Bureau-Statique

# Bon (pas d'espace)
id=Bureau-Statique
```

---

## 🎯 Résumé des commandes essentielles

```bash
# État et informations
nmcli general status
nmcli connection show
nmcli device status

# Créer une connexion
nmcli connection add type ethernet con-name "MaConnexion" ifname enp0s3 \
    ipv4.method manual ipv4.addresses 192.168.1.100/24 \
    ipv4.gateway 192.168.1.1 ipv4.dns "8.8.8.8"

# Modifier une connexion
nmcli connection modify "MaConnexion" ipv4.addresses 192.168.1.150/24
nmcli connection modify "MaConnexion" +ipv4.dns 1.1.1.1

# Activer/Désactiver
nmcli connection up "MaConnexion"
nmcli connection down "MaConnexion"

# Supprimer
nmcli connection delete "MaConnexion"

# Recharger après modification manuelle
nmcli connection reload
```

---

## 📊 Tableau comparatif : GUI vs nmcli vs Fichiers

|Aspect|Interface Graphique|nmcli|Fichiers .nmconnection|
|---|---|---|---|
|**Facilité**|⭐⭐⭐⭐⭐ Très simple|⭐⭐⭐ Moyenne|⭐ Complexe|
|**Vitesse**|⭐⭐ Lente|⭐⭐⭐⭐⭐ Très rapide|⭐⭐⭐ Moyenne|
|**Scriptable**|❌ Non|✅ Oui|✅ Oui (avec précautions)|
|**Options avancées**|⭐⭐ Limitées|⭐⭐⭐⭐⭐ Complètes|⭐⭐⭐⭐⭐ Complètes|
|**Débogage**|⭐ Difficile|⭐⭐⭐⭐ Facile|⭐⭐⭐⭐⭐ Très détaillé|
|**Sauvegarde**|❌ Manuelle|⭐⭐⭐ Via export|⭐⭐⭐⭐⭐ Simple copie|

> [!tip] Recommandation d'usage
> 
> - **Débutants / Desktop** : Interface graphique
> - **Administrateurs / Scripts** : nmcli
> - **Configuration avancée / Débogage** : Fichiers manuels
> - **En pratique** : Combinez les trois selon le contexte !

---