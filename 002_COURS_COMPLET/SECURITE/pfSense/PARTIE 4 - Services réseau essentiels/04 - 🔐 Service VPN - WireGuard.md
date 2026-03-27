

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

## Introduction à WireGuard

> [!info] Objectif de cette section WireGuard est un protocole VPN moderne qui révolutionne la manière de sécuriser les connexions réseau. Cette section vous apprendra à déployer et gérer WireGuard sur pfSense pour créer des tunnels VPN performants et sécurisés.

WireGuard est le nouveau standard de facto pour les VPN modernes grâce à sa simplicité, sa performance et sa sécurité renforcée. Contrairement aux solutions traditionnelles (OpenVPN, IPsec), WireGuard adopte une approche minimaliste avec seulement 4 000 lignes de code contre plus de 400 000 pour OpenVPN.

---

## Présentation de WireGuard

### Qu'est-ce que WireGuard ?

WireGuard est un protocole VPN extrêmement simple, rapide et moderne qui utilise une cryptographie de pointe. Développé par Jason A. Donenfeld, il a été intégré au noyau Linux en 2020 et est maintenant disponible sur toutes les plateformes majeures.

> [!tip] Philosophie de WireGuard **"Simplicité avant tout"** - WireGuard élimine la complexité inutile des VPN traditionnels en se concentrant sur l'essentiel : établir un tunnel sécurisé de manière fiable et performante.

**Caractéristiques principales :**

- **Léger** : Code source minimal (~4 000 lignes)
- **Rapide** : Performances supérieures à OpenVPN et IPsec
- **Moderne** : Cryptographie state-of-the-art uniquement
- **Simple** : Configuration en quelques lignes
- **Multi-plateforme** : Linux, Windows, macOS, iOS, Android, FreeBSD
- **Roaming** : Changement d'IP transparent (mobile/Wi-Fi)

### Principe de fonctionnement

WireGuard fonctionne au niveau 3 (couche réseau) et crée une interface réseau virtuelle qui encapsule le trafic IP.

```
┌─────────────┐                      ┌─────────────┐
│   Client    │                      │   Serveur   │
│  (Peer A)   │                      │  (Peer B)   │
├─────────────┤                      ├─────────────┤
│ wg0: 10.0.0.2│◄────Tunnel VPN────►│ wg0: 10.0.0.1│
│             │   (Port UDP 51820)  │             │
│ Public Key A│                      │ Public Key B│
└─────────────┘                      └─────────────┘
```

**Processus de connexion :**

1. **Échange de clés pré-partagées** : Chaque peer possède sa paire de clés (publique/privée)
2. **Association des peers** : Configuration mutuelle des clés publiques
3. **Établissement du tunnel** : Handshake cryptographique automatique
4. **Transmission de données** : Chiffrement/déchiffrement transparent
5. **Roaming automatique** : Le tunnel suit le client (changement d'IP)

> [!warning] Concept important WireGuard n'utilise **PAS** de client/serveur au sens traditionnel. Tous les participants sont des **peers** (pairs) égaux. Le terme "serveur" désigne simplement le peer qui écoute sur un port et accepte les connexions.

### Architecture et cryptographie

WireGuard utilise exclusivement des algorithmes cryptographiques modernes et audités :

|Composant|Algorithme|Usage|
|---|---|---|
|**Chiffrement**|ChaCha20|Chiffrement symétrique du trafic|
|**Authentification**|Poly1305|MAC (Message Authentication Code)|
|**Échange de clés**|Curve25519|ECDH (Elliptic Curve Diffie-Hellman)|
|**Hachage**|BLAKE2s|Fonction de hachage cryptographique|
|**Hashage de clés**|HKDF|Dérivation de clés|

> [!info] Noise Protocol Framework WireGuard utilise le **Noise Protocol Framework** (pattern IKpsk2) pour l'établissement du tunnel. C'est le même framework utilisé par WhatsApp et Signal pour leurs communications chiffrées.

**Avantages cryptographiques :**

- **Pas de négociation** : Aucun choix d'algorithme, donc pas de downgrade attacks
- **Perfect Forward Secrecy** : Rotation des clés toutes les 2 minutes
- **Résistance au quantum** : Possibilité d'ajouter une clé pré-partagée (PSK)
- **Identité cryptographique** : Pas de certificats X.509 complexes

---

## Configuration du tunnel WireGuard

### Prérequis

Avant de configurer WireGuard sur pfSense, assurez-vous que :

- pfSense est à jour (version 2.5.0 minimum)
- Le package WireGuard est installé via le gestionnaire de paquets
- Vous avez planifié votre adressage réseau VPN
- Les ports UDP nécessaires sont disponibles (par défaut 51820)

> [!tip] Installation du package `System > Package Manager > Available Packages` → Rechercher "WireGuard" → Install

### Génération des clés

WireGuard utilise une cryptographie à clé publique. Chaque peer nécessite une paire de clés.

**Méthode 1 : Génération depuis pfSense**

1. Accéder à `VPN > WireGuard > Settings`
2. Cliquer sur le bouton "Generate" pour créer une paire de clés
3. Les clés apparaissent automatiquement dans les champs correspondants

**Méthode 2 : Génération en ligne de commande**

```bash
# Sur pfSense ou un système Linux/BSD
wg genkey | tee privatekey | wg pubkey > publickey

# Afficher la clé privée
cat privatekey
# Exemple : YJKbZVwmkzlZ/9P3VLqF9k0qM8fLGxN2kN4n3XyHj2E=

# Afficher la clé publique
cat publickey
# Exemple : 8LqBxVmGVJQXZfL6d8N9kF3wPjL2mN8k5XyHj2E7P4Q=
```

> [!warning] Sécurité des clés
> 
> - **Jamais partager la clé privée** : Elle doit rester secrète sur son peer
> - **Sauvegarde sécurisée** : Conservez une copie chiffrée des clés privées
> - **Rotation** : Changez les clés régulièrement (tous les 6-12 mois)

**Structure des clés :**

```
Serveur pfSense               Client (peer)
├── Clé privée serveur ───┐   ├── Clé privée client ───┐
├── Clé publique serveur  │   ├── Clé publique client  │
                          │                             │
                          └──► Partagée avec client    │
                                                        │
                               Partagée avec serveur ◄──┘
```

### Configuration du serveur (pfSense)

**Étape 1 : Créer le tunnel WireGuard**

1. Naviguer vers `VPN > WireGuard > Tunnels`
2. Cliquer sur `+ Add Tunnel`
3. Configurer les paramètres suivants :

|Paramètre|Valeur|Description|
|---|---|---|
|**Enable**|☑|Activer le tunnel|
|**Description**|VPN WireGuard Principal|Nom descriptif|
|**Listen Port**|51820|Port UDP d'écoute (personnalisable)|
|**Interface Keys**|[Générées]|Paire de clés du serveur|
|**MTU**|1420|Maximum Transmission Unit (1500 - 80)|

> [!info] Calcul du MTU
> 
> ```
> MTU WireGuard = MTU interface physique - 80 octets
> 
> Overhead WireGuard :
> - 20 octets : En-tête IPv4 externe
> - 8 octets  : En-tête UDP
> - 4 octets  : Type message WireGuard
> - 4 octets  : Index peer
> - 8 octets  : Nonce
> - 16 octets : Poly1305 MAC
> - 20 octets : En-tête IPv4 interne (encapsulé)
> ───────────
> = 80 octets total
> ```

4. Sauvegarder la configuration

**Étape 2 : Configurer les paramètres avancés (optionnel)**

Dans l'onglet "Advanced" :

```bash
# Intervalle de keep-alive (en secondes)
# Utile pour maintenir la connexion à travers un NAT
PersistentKeepalive = 25

# Table de routage (pour configuration multi-wan)
Table = auto

# Clé pré-partagée (pour résistance quantique)
PreSharedKey = [générer une clé supplémentaire]
```

### Configuration de l'interface WireGuard

**Créer l'interface réseau associée :**

1. Aller dans `Interfaces > Assignments`
2. Sélectionner `wg0` (ou wgX selon le numéro) dans le menu déroulant
3. Cliquer sur `+ Add`
4. Nommer l'interface (ex: `WG_VPN`)
5. Cliquer sur le nom nouvellement créé pour le configurer

**Configuration de l'interface :**

|Paramètre|Valeur|Description|
|---|---|---|
|**Enable**|☑|Activer l'interface|
|**Description**|WireGuard VPN|Nom descriptif|
|**IPv4 Configuration Type**|Static IPv4|Adressage statique|
|**IPv4 Address**|10.0.8.1/24|IP du serveur VPN + masque|
|**IPv6 Configuration Type**|None|Désactivé (ou Static si IPv6)|

> [!tip] Choix du réseau VPN Utilisez un réseau privé non utilisé ailleurs :
> 
> - `10.0.8.0/24` (exemple ci-dessus)
> - `10.200.200.0/24`
> - `192.168.99.0/24`
> 
> Évitez les plages communes comme `192.168.1.0/24` pour éviter les conflits.

6. Sauvegarder et appliquer les changements

### Configuration du pare-feu

**Règle 1 : Autoriser le trafic WireGuard entrant (WAN)**

1. `Firewall > Rules > WAN`
2. `Add` (bouton en haut avec flèche vers le haut)

```
Action      : Pass
Interface   : WAN
Protocol    : UDP
Source      : any (ou limiter à des IPs spécifiques)
Destination : WAN address
Dest. Port  : 51820
Description : WireGuard VPN Inbound
```

> [!warning] Sécurité Pour limiter l'exposition, créez un alias d'IPs autorisées plutôt que d'utiliser "any" comme source.

**Règle 2 : Autoriser le trafic des clients VPN**

1. `Firewall > Rules > WG_VPN` (votre interface WireGuard)
2. `Add`

```
Action      : Pass
Interface   : WG_VPN
Protocol    : any
Source      : WG_VPN net (10.0.8.0/24)
Destination : any (ou LAN net selon vos besoins)
Description : WireGuard Clients - Allow All
```

**Règle optionnelle : DNS pour les clients**

```
Action      : Pass
Interface   : WG_VPN
Protocol    : TCP/UDP
Source      : WG_VPN net
Destination : WG_VPN address
Dest. Port  : 53
Description : WireGuard - Allow DNS
```

> [!tip] Organisation des règles Placez les règles les plus spécifiques en haut et les plus générales en bas pour optimiser les performances du pare-feu.

---

## Gestion des peers

### Ajout d'un peer

Un peer représente un client VPN (ordinateur portable, smartphone, serveur distant, etc.).

**Procédure d'ajout :**

1. `VPN > WireGuard > Peers`
2. `+ Add Peer`
3. Configurer les paramètres :

|Paramètre|Valeur|Description|
|---|---|---|
|**Tunnel**|wg0|Tunnel associé|
|**Description**|Laptop-Jean|Nom descriptif du peer|
|**Dynamic Endpoint**|☑|Le client peut avoir une IP changeante|
|**Endpoint**|[vide]|Laissé vide pour endpoint dynamique|
|**Endpoint Port**|[vide]|Non nécessaire pour client|
|**Keep Alive**|25|Maintien de connexion (secondes)|
|**Public Key**|[clé publique du client]|Clé publique générée côté client|
|**Allowed IPs**|10.0.8.2/32|IP VPN assignée au client (notation /32)|

> [!info] Allowed IPs - Concept clé **Allowed IPs** définit deux choses simultanément :
> 
> 1. **Routage** : Quelles destinations envoyer à travers ce peer
> 2. **Filtrage** : Quels paquets sources accepter de ce peer
> 
> Format : `10.0.8.2/32` = Une seule IP (le /32 signifie masque complet)

**Exemple de configuration multi-peers :**

```
Peer 1 - Laptop Jean
├── Public Key : abc123...
├── Allowed IPs : 10.0.8.2/32
└── Description : Laptop-Jean

Peer 2 - Smartphone Marie
├── Public Key : def456...
├── Allowed IPs : 10.0.8.3/32
└── Description : Mobile-Marie

Peer 3 - Serveur Remote
├── Public Key : ghi789...
├── Allowed IPs : 10.0.8.10/32, 192.168.50.0/24
└── Description : Bureau-Distant (accès réseau complet)
```

> [!warning] Unicité des Allowed IPs Chaque IP dans "Allowed IPs" ne peut être assignée qu'à **un seul peer**. Deux peers ne peuvent pas avoir la même IP.

### Configuration des clients

Après avoir ajouté un peer sur pfSense, il faut configurer le client correspondant.

**Fichier de configuration client (exemple pour Linux/Windows/macOS) :**

```ini
[Interface]
# Clé privée du CLIENT (générée sur le client)
PrivateKey = kLqBxVmGVJQXZfL6d8N9kF3wPjL2mN8k5XyHj2E7P4Q=

# Adresse IP VPN assignée au client
Address = 10.0.8.2/24

# DNS à utiliser (optionnel, IP du pfSense ou DNS public)
DNS = 10.0.8.1

# MTU (optionnel)
MTU = 1420

[Peer]
# Clé publique du SERVEUR pfSense
PublicKey = 8LqBxVmGVJQXZfL6d8N9kF3wPjL2mN8k5XyHj2E7P4Q=

# Clé pré-partagée (si configurée sur le serveur)
# PresharedKey = xyz789...

# Endpoint = IP publique du pfSense + port
Endpoint = 203.0.113.50:51820

# Allowed IPs = Trafic à router via le VPN
# 0.0.0.0/0 = tout le trafic (VPN total)
# 10.0.0.0/8, 192.168.0.0/16 = seulement réseaux privés (split tunnel)
AllowedIPs = 0.0.0.0/0

# Keep-alive toutes les 25 secondes
PersistentKeepalive = 25
```

> [!tip] VPN total vs Split Tunnel **VPN total (0.0.0.0/0)** :
> 
> - ✅ Tout le trafic passe par le VPN
> - ✅ Meilleure sécurité sur Wi-Fi public
> - ❌ Peut ralentir la connexion
> 
> **Split Tunnel (réseaux spécifiques)** :
> 
> - ✅ Seul le trafic entreprise passe par VPN
> - ✅ Meilleures performances
> - ❌ Trafic internet non protégé

**Configuration mobile (iOS/Android) :**

Les applications WireGuard officielles permettent soit :

- Scanner un QR code généré depuis le fichier de configuration
- Importer manuellement le fichier `.conf`
- Saisir manuellement les paramètres

**Génération d'un QR code (sur le client ou serveur) :**

```bash
# Installer qrencode si nécessaire
pkg install qrencode  # FreeBSD/pfSense
apt install qrencode  # Debian/Ubuntu

# Générer le QR code
qrencode -t ansiutf8 < client-config.conf

# Ou sauvegarder en image
qrencode -o qrcode.png -r client-config.conf
```

### Gestion des adresses IP

**Planification d'adressage :**

Pour un réseau WireGuard `10.0.8.0/24` :

|Plage|Usage|Exemple|
|---|---|---|
|10.0.8.1|Serveur pfSense|Passerelle VPN|
|10.0.8.2-10.0.8.50|Clients individuels|Laptops, smartphones|
|10.0.8.51-10.0.8.100|Serveurs distants|Sites branch, IoT|
|10.0.8.101-10.0.8.200|Clients temporaires|Invités, tests|
|10.0.8.201-10.0.8.254|Réservé|Future expansion|

> [!info] Réservation DHCP-like WireGuard ne supporte pas DHCP. Toutes les IPs sont assignées statiquement. Maintenez un tableau de suivi :
> 
> ```
> | IP | Peer | User | Device | Date |
> |----|------|------|--------|------|
> | 10.0.8.2 | Laptop-Jean | jean.d | MacBook Pro | 2025-01-05 |
> | 10.0.8.3 | Mobile-Marie | marie.l | iPhone 15 | 2025-01-06 |
> ```

**Révocation d'un peer :**

1. `VPN > WireGuard > Peers`
2. Cliquer sur l'icône de suppression du peer concerné
3. Confirmer la suppression
4. Le peer ne pourra plus se connecter instantanément

> [!warning] Pas de révocation de clé WireGuard ne gère pas de liste de révocation de certificats (CRL). Pour révoquer un accès, il faut supprimer le peer entier. C'est pourquoi il est important de créer un peer par appareil plutôt qu'un peer par utilisateur.

### Surveillance et monitoring

**Méthode 1 : Interface web pfSense**

1. `Status > WireGuard`
2. Affiche :
    - Status de chaque tunnel (up/down)
    - Liste des peers connectés
    - Dernière communication (handshake)
    - Trafic RX/TX par peer

**Méthode 2 : Ligne de commande**

```bash
# Se connecter en SSH à pfSense

# Afficher l'état du tunnel
wg show

# Sortie exemple :
interface: wg0
  public key: 8LqBxVmGVJQXZfL6d8N9kF3wPjL2mN8k5XyHj2E7P4Q=
  private key: (hidden)
  listening port: 51820

peer: abc123def456...
  endpoint: 198.51.100.42:54321
  allowed ips: 10.0.8.2/32
  latest handshake: 1 minute, 23 seconds ago
  transfer: 15.2 MiB received, 8.7 MiB sent
  persistent keepalive: every 25 seconds

# Afficher uniquement les peers actifs
wg show wg0 latest-handshakes

# Monitorer en temps réel
watch -n 5 wg show
```

> [!tip] Indicateurs de santé
> 
> - **Latest handshake < 3 minutes** : Connexion active et saine
> - **Latest handshake > 3 minutes** : Client probablement déconnecté
> - **Pas de handshake** : Problème de configuration ou réseau
> - **Transfer RX/TX** : Volume de données échangées

**Méthode 3 : Logs système**

```bash
# Consulter les logs WireGuard
clog /var/log/system.log | grep wireguard

# Filtrer par interface
clog /var/log/system.log | grep wg0

# Surveiller en temps réel
tail -f /var/log/system.log | grep wireguard
```

**Intégration avec outils de monitoring :**

WireGuard expose des métriques via l'interface `wg show` qui peuvent être récupérées par :

- Prometheus + Grafana
- Zabbix
- Nagios/Icinga
- Scripts personnalisés

---

## WireGuard vs OpenVPN vs IPsec

### Tableau comparatif

|Critère|WireGuard|OpenVPN|IPsec|
|---|---|---|---|
|**Complexité du code**|~4 000 lignes|~400 000 lignes|~400 000 lignes|
|**Configuration**|⭐⭐⭐⭐⭐ Simple|⭐⭐⭐ Moyenne|⭐⭐ Complexe|
|**Performance**|⭐⭐⭐⭐⭐ Excellent|⭐⭐⭐ Bon|⭐⭐⭐⭐ Très bon|
|**Vitesse (Mbps)**|1000+|100-300|400-600|
|**Latence**|Très faible (~1ms)|Moyenne (~5ms)|Faible (~2ms)|
|**Overhead**|60-80 octets|100+ octets|80-100 octets|
|**Cryptographie**|Moderne uniquement|Négociable (risque)|Négociable (risque)|
|**Roaming**|⭐⭐⭐⭐⭐ Transparent|⭐⭐⭐ Avec reconnect|⭐⭐ Complexe|
|**Mobilité**|Excellent|Bon|Limité|
|**Audit sécurité**|Facile (petit code)|Difficile|Difficile|
|**Consommation CPU**|Très faible|Moyenne/Haute|Moyenne|
|**Batterie (mobile)**|⭐⭐⭐⭐⭐ Excellent|⭐⭐⭐ Moyen|⭐⭐⭐ Moyen|
|**NAT Traversal**|Automatique|Nécessite config|Complexe|
|**Port requis**|1 UDP|1 TCP ou UDP|Multiples (500, 4500, ESP)|
|**Authentification**|Clé publique|Certificat/Login|PSK/Certificat|
|**Site-to-Site**|✅ Oui|✅ Oui|✅ Oui (natif)|
|**Client mobile**|✅ Natif iOS/Android|✅ App tierce|❌ Limité|
|**Split tunneling**|✅ Simple|✅ Configurable|✅ Oui|
|**Maturité**|Jeune (2016)|Mature (2001)|Très mature (1995)|
|**Support entreprise**|Croissant|Excellent|Excellent|

### Quand utiliser WireGuard

**Cas d'usage idéaux ✅ :**

1. **VPN nomade (road warrior)** :
    
    - Utilisateurs en déplacement
    - Connexions mobiles 4G/5G/Wi-Fi
    - Changements d'IP fréquents
    - Besoin de performances élevées
2. **IoT et appareils embarqués** :
    
    - Faible consommation CPU
    - Petite empreinte mémoire
    - Connexions intermittentes
3. **Site-to-Site moderne** :
    
    - Connexions entre sites distants
    - Backup de liens IPsec existants
    - Faible latence requise
4. **Conteneurs et cloud** :
    
    - Docker, Kubernetes networking
    - Interconnexion de VPC cloud
    - Overlay networks
5. **VPN personnel** :
    
    - Simplicité de configuration
    - Pas besoin de PKI complexe
    - Auto-hébergement

> [!example] Scénario typique **Entreprise avec télétravail** :
> 
> - 50 employés en télétravail
> - Accès aux ressources internes (fichiers, CRM, intranet)
> - Connexions depuis divers lieux (domicile, café, coworking)
> - Budget limité pour support VPN
> 
> → **WireGuard est parfait** : simple à déployer, performant, fonctionne sur tous les appareils modernes.

**Quand préférer OpenVPN :**

- Besoin d'authentification utilisateur (LDAP/RADIUS)
- Environnement corporate très règlementé
- Nécessité de traverser des pare-feux très restrictifs (TCP 443)
- Support de systèmes legacy

**Quand préférer IPsec :**

- Interconnexion avec équipements Cisco/Juniper
- Standards de conformité stricts (gouvernement, finance)
- VPN site-to-site haute disponibilité
- Intégration avec infrastructure existante

### Limites de WireGuard

> [!warning] Limitations à connaître

**1. Pas d'authentification utilisateur native**

WireGuard n'intègre pas de mécanisme d'authentification par login/mot de passe ou LDAP. L'authentification se fait uniquement par clé publique.

**Solutions :**

- Portail web d'auto-provisioning
- Scripts de génération automatique de configs
- Intégration avec SSO via proxy/wrapper

**2. Gestion des clés manuelle**

Pas de protocole automatique de distribution de clés (contrairement à IKEv2/IPsec).

**Impact :**

- Configuration initiale requise pour chaque client
- Pas de renouvellement automatique des clés
- Révocation = suppression complète du peer

**3. Pas de pool d'adresses IP dynamique**

Toutes les IPs doivent être assignées statiquement dans la configuration.

**Impact :**

- Planification d'adressage nécessaire
- Maintenance d'un registre des assignations
- Pas de DHCP pour simplifier la gestion

**4. Visibilité du dernier handshake**

WireGuard expose le timestamp du dernier handshake, ce qui peut révéler si un utilisateur est actif.

**Considération :**

- Potentiel problème de confidentialité dans certains contextes
- Non bloquant pour la plupart des usages

**5. Jeunesse relative**

Bien qu'intégré au kernel Linux et largement adopté, WireGuard est plus jeune qu'OpenVPN/IPsec.

**Impact :**

- Moins d'exemples de déploiements à grande échelle
- Écosystème d'outils tiers en développement
- Certifications de sécurité en cours

> [!tip] Mitigation La plupart de ces limites peuvent être contournées avec des outils et scripts complémentaires. La simplicité et les performances de WireGuard compensent largement ces contraintes pour la majorité des cas d'usage.

---

## Bonnes pratiques et sécurité

### Organisation des clés

**Principe de base : Une paire de clés par appareil**

```
❌ MAUVAIS : Un peer par utilisateur
User: Jean → Peer "Jean" (utilisé sur laptop + smartphone + tablette)
Problème : Si un appareil est perdu, impossible de révoquer sans bloquer tous

✅ BON : Un peer par appareil
User: Jean → Peer "Jean-Laptop"
            → Peer "Jean-iPhone"
            → Peer "Jean-iPad"
Avantage : Révocation granulaire, meilleur audit
```

**Nomenclature des peers :**

```
Format recommandé : [Utilisateur]-[Type]-[Identifiant]

Exemples :
- jean.dupont-laptop-dell5520
- marie.martin-mobile-iphone15
- service-monitoring-srv01
- iot-camera-garage
```

> [!tip] Documentation Maintenez un tableau de mapping dans une documentation sécurisée :
> 
> |Peer|User|Device|Public Key (début)|Date création|Status|
> |---|---|---|---|---|---|
> |jean-laptop|Jean D.|Dell Latitude|8LqBxVm...|2025-01-05|Actif|
> |marie-iphone|Marie L.|iPhone 15|kF3wPjL...|2025-01-08|Actif|
> |temp-guest|Invité|MacBook|2mN8k5X...|2025-01-10|Révoqué|

### Sécurisation du serveur

**1. Changement du port par défaut**

```bash
# Au lieu du port 51820 par défaut, utiliser un port non-standard
Listen Port : 51194  # Exemple
```

> [!info] Pourquoi ?
> 
> - Réduit le scanning automatique
> - Évite les attaques opportunistes
> - Note : C'est de la "security through obscurity" (faible protection)

**2. Limitation par IP source (si possible)**

Si vos utilisateurs ont des IPs fixes ou des plages connues :

```
Firewall > Rules > WAN
Source : Alias "VPN_Allowed_IPs"
  ├── 203.0.113.0/24    # Bureau principal
  ├── 198.51.100.50/32   # Maison Jean
  └── 192.0.2.100/32     # Serveur cloud autorisé
```

**3. Rate limiting**

Protégez contre les attaques par force brute (bien que WireGuard soit résistant par design) :

```
Firewall > Rules > WAN > Advanced
├── Max connections : 100
├── Max connection rate : 10/second
└── Max src nodes : 5
```

**4. Monitoring des connexions**

Configurez des alertes pour :

- Nouvelles connexions depuis des pays inhabituels
- Nombre anormal de tentatives de handshake
- Trafic inhabituel (volume, horaires)

**5. Clé pré-partagée (PSK) pour résistance quantique**

```ini
# Configuration serveur (pfSense)
PreSharedKey = [générer avec: wg genpsk]

# Configuration client
[Peer]
PresharedKey = [même clé que le serveur]
```

> [!info] Résistance quantique La PSK ajoute une couche de protection symétrique qui resterait sécurisée même si les ordinateurs quantiques cassaient Curve25519. C'est une protection "future-proof".

### Segmentation réseau

**Isoler le trafic VPN selon les besoins :**

```
Scénario : Entreprise avec différents types d'accès

VPN Employés (wg0)
├── Tunnel : 10.0.8.0/24
├── Accès : LAN complet
└── Règles : Firewall permissif

VPN Sous-traitants (wg1)
├── Tunnel : 10.0.9.0/24
├── Accès : Serveurs spécifiques uniquement
└── Règles : Firewall restrictif (whitelist)

VPN IoT/Devices (wg2)
├── Tunnel : 10.0.10.0/24
├── Accès : Internet sortant + serveur monitoring
└── Règles : Pas d'accès inter-VLAN
```

**Règles de pare-feu par tunnel :**

```bash
# Tunnel Employés - Accès complet
Interface: WG_EMPLOYEES
Source: 10.0.8.0/24
Destination: LAN net, VLAN_SERVEURS
Action: Pass

# Tunnel Sous-traitants - Whitelist
Interface: WG_CONTRACTORS
Source: 10.0.9.0/24
Destination: Alias "Serveurs_Projet_X"
Ports: 443, 22
Action: Pass
+ Règle par défaut: Block

# Tunnel IoT - Internet only
Interface: WG_IOT
Source: 10.0.10.0/24
Destination: !RFC1918 (pas de réseaux privés)
Action: Pass
```

### Rotation des clés

**Calendrier de rotation recommandé :**

|Type de peer|Fréquence|Méthode|
|---|---|---|
|**Utilisateurs standards**|12 mois|Planifié|
|**Administrateurs**|6 mois|Planifié|
|**Serveurs site-to-site**|24 mois|Planifié|
|**Appareils partagés**|3 mois|Planifié|
|**Après compromission**|Immédiat|D'urgence|
|**Départ d'employé**|Immédiat|D'urgence|

**Procédure de rotation :**

```bash
# 1. Générer nouvelle paire de clés (côté client)
wg genkey | tee new-privatekey | wg pubkey > new-publickey

# 2. Mettre à jour le peer sur pfSense
VPN > WireGuard > Peers > Edit peer
└── Remplacer Public Key par la nouvelle

# 3. Mettre à jour la configuration client
[Interface]
PrivateKey = [nouvelle clé privée]

[Peer]
PublicKey = [clé publique du serveur - inchangée]

# 4. Redémarrer le client WireGuard
wg-quick down wg0
wg-quick up wg0

# 5. Vérifier la connexion
wg show
```

> [!warning] Coordination Pour éviter les coupures de service, préparez la nouvelle configuration avant de changer la clé publique sur le serveur. Appliquez les changements rapidement (serveur puis client dans la foulée).

### Sauvegarde et récupération

**Éléments critiques à sauvegarder :**

1. **Configuration pfSense** (automatique via AutoConfigBackup ou manuel)
2. **Clés privées du serveur** (stockage sécurisé hors ligne)
3. **Tableau de mapping peers** (documentation)
4. **Configurations clients** (coffre-fort de mots de passe)

**Procédure de sauvegarde manuelle :**

```bash
# SSH vers pfSense

# Sauvegarder la config WireGuard
cat /usr/local/etc/wireguard/wg0.conf

# Sauvegarder les clés
cp /usr/local/etc/wireguard/keys/* /root/backup-wg/

# Exporter la config complète pfSense
Diagnostics > Backup & Restore > Download configuration
```

**Récupération après incident :**

```bash
# Scénario : Réinstallation complète de pfSense

1. Restaurer la configuration pfSense complète
   └── Diagnostics > Backup & Restore > Restore

2. Réinstaller le package WireGuard
   └── System > Package Manager

3. Vérifier les tunnels
   └── VPN > WireGuard > Tunnels
   └── Status > WireGuard

4. Tester la connexion d'un client
   └── wg-quick up wg0

5. Valider le routage
   └── ping 10.0.8.1 (IP serveur VPN)
   └── ping 192.168.1.1 (passerelle LAN)
```

### Optimisations de performance

**1. MTU optimal**

```bash
# Tester le MTU optimal depuis un client connecté
ping -M do -s 1400 10.0.8.1  # Linux
ping -D -s 1400 10.0.8.1     # macOS
ping -f -l 1400 10.0.8.1     # Windows

# Réduire progressivement jusqu'à absence de fragmentation
# Valeurs typiques : 1420, 1400, 1380

# Appliquer dans la config
[Interface]
MTU = 1400  # Valeur trouvée
```

> [!tip] Impact du MTU Un MTU mal configuré peut causer :
> 
> - Fragmentation de paquets → perte de performance
> - Latence accrue
> - Paquets rejetés sur certains réseaux
> 
> Un MTU optimal améliore le débit de 10-20%.

**2. Optimisation noyau FreeBSD (pfSense)**

```bash
# Augmenter les buffers réseau
# System > Advanced > System Tunables

# Ajouter/modifier :
net.inet.udp.recvspace = 1048576
net.inet.udp.maxdgram = 16384
kern.ipc.maxsockbuf = 4194304
```

**3. Offloading matériel**

```bash
# Vérifier les capacités de la carte réseau
ifconfig <interface>

# Si disponible, activer :
System > Advanced > Networking
├── Hardware Checksum Offloading : ☑
├── Hardware TCP Segmentation Offloading : ☑
└── Hardware Large Receive Offloading : ☑
```

> [!warning] Attention Sur certaines cartes réseau (notamment Realtek), l'offloading peut causer des problèmes. Testez les performances avant/après.

**4. Réduction de la latence**

```bash
# Configuration client pour faible latence
[Peer]
PersistentKeepalive = 10  # Au lieu de 25

# Priorisation QoS sur pfSense
Firewall > Traffic Shaper
└── Créer une queue haute priorité pour le port 51820
```

### Troubleshooting courant

**Problème 1 : Peer ne se connecte pas**

```bash
# Vérifications côté serveur (pfSense)

1. Tunnel actif ?
   Status > WireGuard > wg0 doit être "up"

2. Règle firewall WAN ?
   Firewall > Rules > WAN
   └── Vérifier règle UDP 51820 en "Pass"

3. Logs systèmes
   Status > System Logs > System
   └── Rechercher "wireguard" ou "wg0"

# Vérifications côté client

4. Endpoint correct ?
   [Peer]
   Endpoint = IP_PUBLIQUE_CORRECTE:51820

5. Clé publique serveur exacte ?
   PublicKey = [doit correspondre à wg show sur pfSense]

6. Connectivité réseau
   ping IP_PUBLIQUE_PFSENSE
   telnet IP_PUBLIQUE_PFSENSE 51820
```

> [!example] Erreur typique
> 
> ```
> Symptôme : Pas de handshake
> Cause : Clé publique incorrecte (espace ou caractère en trop)
> Solution : Régénérer les clés et copier-coller avec précaution
> ```

**Problème 2 : Connexion établie mais pas de trafic**

```bash
# Vérifier le routage

1. Allowed IPs correct côté serveur ?
   VPN > WireGuard > Peers
   └── Le peer a bien 10.0.8.X/32

2. Allowed IPs correct côté client ?
   [Peer]
   AllowedIPs = 0.0.0.0/0  # Ou réseaux spécifiques

3. Règles firewall interface WG ?
   Firewall > Rules > WG_VPN
   └── Doit avoir au minimum une règle "Pass any any"

4. NAT si nécessaire ?
   Firewall > NAT > Outbound
   └── Vérifier que le trafic VPN est NATé vers WAN

5. Table de routage client
   # Linux/macOS
   ip route | grep wg0
   
   # Windows
   route print
```

**Problème 3 : Performances dégradées**

```bash
# Diagnostics

1. Vérifier MTU
   ping -M do -s 1400 <destination>

2. Vérifier CPU serveur
   top -S  # Sur pfSense
   └── wg-quick ne doit pas consommer >10% CPU

3. Tester débit
   # Client vers serveur
   iperf3 -c 10.0.8.1
   
   # Comparer avec/sans VPN
   iperf3 -c <IP_LAN_DIRECTE>

4. Vérifier latence
   ping -c 100 10.0.8.1
   └── Latence doit être <10ms en moyenne

5. Inspecter les erreurs réseau
   netstat -i | grep wg0
   └── Vérifier colonne "Ierrs" et "Oerrs"
```

**Problème 4 : Déconnexions fréquentes (mobile)**

```bash
# Solutions

1. Augmenter PersistentKeepalive
   [Peer]
   PersistentKeepalive = 15  # Au lieu de 25

2. Vérifier les power saving
   # iOS : Désactiver "Low Power Mode" temporairement
   # Android : Whitelist l'app WireGuard

3. Timeout NAT
   # Certains opérateurs mobiles ont un timeout court
   # PersistentKeepalive à 10-15 secondes résout souvent

4. Endpoint dynamique
   # Côté serveur, vérifier :
   VPN > WireGuard > Peers
   └── "Dynamic Endpoint" doit être coché
```

### Cas d'usage avancés

**1. Site-to-Site VPN**

```bash
# Bureau Principal (pfSense A)          Bureau Distant (pfSense B)
# 192.168.1.0/24                        192.168.2.0/24
# WG IP: 10.0.8.1                       WG IP: 10.0.8.2

# Configuration pfSense A
[Peer]
PublicKey = <clé publique pfSense B>
Endpoint = IP_PUBLIQUE_B:51820
AllowedIPs = 10.0.8.2/32, 192.168.2.0/24  # Peer + réseau distant

# Configuration pfSense B
[Peer]
PublicKey = <clé publique pfSense A>
Endpoint = IP_PUBLIQUE_A:51820
AllowedIPs = 10.0.8.1/32, 192.168.1.0/24  # Peer + réseau distant

# Routes statiques (automatiques via AllowedIPs)
# Bureau A : 192.168.2.0/24 via 10.0.8.2
# Bureau B : 192.168.1.0/24 via 10.0.8.1
```

**2. Hub-and-Spoke (plusieurs sites vers central)**

```
        Site Central (Hub)
             10.0.8.1
            /    |    \
           /     |     \
    Site A   Site B   Site C
   10.0.8.2  10.0.8.3  10.0.8.4
```

**Configuration Hub :**

```bash
# Un peer par site distant
Peer Site A: AllowedIPs = 10.0.8.2/32, 192.168.10.0/24
Peer Site B: AllowedIPs = 10.0.8.3/32, 192.168.20.0/24
Peer Site C: AllowedIPs = 10.0.8.4/32, 192.168.30.0/24
```

**3. Double VPN (cascade)**

```bash
# Client → VPN1 (WireGuard) → VPN2 (WireGuard) → Internet

# Cas d'usage : Anonymat renforcé, contournement censure

# Configuration client
[Peer - VPN1]
Endpoint = serveur1.vpn.com:51820
AllowedIPs = 10.0.8.0/24  # Seulement le réseau VPN1

# Configuration VPN1 (route vers VPN2)
[Peer - VPN2]
Endpoint = serveur2.vpn.com:51820
AllowedIPs = 0.0.0.0/0  # Tout le reste va vers VPN2
```

> [!warning] Latence Chaque saut VPN ajoute de la latence. Double VPN ≈ 2x latence. Réservé aux cas nécessitant haute confidentialité.

---

## 🎯 Points clés à retenir

> [!tip] L'essentiel WireGuard
> 
> **Concepts fondamentaux :**
> 
> - WireGuard = VPN moderne, simple, rapide (protocole layer 3)
> - Cryptographie fixe = pas de négociation = sécurité renforcée
> - Peers égalitaires = pas de distinction client/serveur stricte
> - Allowed IPs = routage + filtrage simultanés
> 
> **Configuration pfSense :**
> 
> 1. Tunnel = interface virtuelle wg0 + port UDP
> 2. Peers = ajout des clients avec clé publique + IP VPN
> 3. Firewall = règle WAN (port 51820) + règles interface WG
> 4. Interface = assignation avec IP statique
> 
> **Sécurité :**
> 
> - 1 peer = 1 appareil (pas 1 peer par utilisateur)
> - Clés privées = secrètes et sauvegardées
> - Rotation des clés tous les 6-12 mois
> - PSK optionnelle pour résistance quantique
> 
> **Performance :**
> 
> - MTU optimal = 1420 (ajuster selon le réseau)
> - PersistentKeepalive = 25s (10-15s pour mobile)
> - Offloading matériel si carte réseau compatible
> 
> **Avantages vs alternatives :**
> 
> - OpenVPN : WireGuard 5-10x plus rapide, config 10x plus simple
> - IPsec : WireGuard meilleur roaming, moins complexe
> - Cas d'usage idéal : VPN nomade, IoT, site-to-site moderne

---

## 📚 Synthèse technique

**Architecture WireGuard :**

```
Application
    ↓
Interface wg0 (Layer 3)
    ↓
Cryptographie (ChaCha20-Poly1305)
    ↓
Encapsulation UDP
    ↓
Interface physique (eth0)
```

**Flux de connexion :**

```
1. Client envoie handshake initié → Serveur (UDP:51820)
2. Serveur répond avec handshake response
3. Établissement tunnel (clés de session dérivées)
4. Transmission données (chiffrées, authentifiées)
5. Rotation clés toutes les 2 minutes (transparente)
6. Keepalive si configuré (maintien NAT)
```

**Commandes essentielles :**

```bash
# Afficher statut
wg show

# Afficher config
wg showconf wg0

# Générer clés
wg genkey | tee privatekey | wg pubkey > publickey

# Redémarrer interface
wg-quick down wg0 && wg-quick up wg0

# Logs temps réel
tail -f /var/log/system.log | grep wireguard
```

---

**🎓 Vous maîtrisez maintenant WireGuard sur pfSense !**

Ce VPN moderne vous permet de sécuriser vos connexions distantes avec une simplicité et des performances inégalées. Que ce soit pour du télétravail, de l'interconnexion de sites, ou des appareils IoT, WireGuard offre une solution élégante et robuste pour tous vos besoins VPN.