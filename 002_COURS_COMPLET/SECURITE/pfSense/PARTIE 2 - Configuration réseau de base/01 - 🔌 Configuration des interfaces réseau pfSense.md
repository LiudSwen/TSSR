

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

## 🎯 Introduction aux interfaces

Les interfaces réseau constituent la fondation de toute configuration pfSense. Elles représentent les points de connexion physiques ou virtuels entre le firewall et les différents segments du réseau.

> [!info] Définition Une interface réseau dans pfSense est un point de connexion qui permet au firewall de communiquer avec un segment réseau spécifique. Chaque interface possède sa propre configuration IP, ses règles de firewall, et ses services associés.

### Pourquoi c'est important ?

- **Segmentation réseau** : Séparer les différents types de trafic (Internet, LAN interne, DMZ, invités)
- **Sécurité** : Contrôler précisément les flux entre les segments
- **Performance** : Optimiser le routage et éviter les goulots d'étranglement
- **Organisation** : Structurer logiquement l'infrastructure réseau

---

## 🏷️ Types d'interfaces

pfSense utilise une nomenclature spécifique pour identifier les différents types d'interfaces. Comprendre ces types est essentiel pour une configuration correcte.

### WAN (Wide Area Network)

> [!example] Interface WAN L'interface WAN est la connexion vers l'extérieur, typiquement Internet ou un réseau étendu.

**Caractéristiques :**

- Interface publique exposée à Internet
- Souvent configurée en DHCP (box opérateur) ou IP statique (ligne professionnelle)
- Point d'entrée principal pour le trafic entrant
- Applique par défaut des règles restrictives (deny all inbound)

**Cas d'usage typiques :**

- Connexion Internet via modem/box FAI
- Liaison WAN privée (MPLS, VPN site-to-site)
- Connexion 4G/5G de backup

### LAN (Local Area Network)

> [!example] Interface LAN L'interface LAN connecte le réseau local interne, généralement le réseau des utilisateurs et équipements de confiance.

**Caractéristiques :**

- Interface privée sécurisée
- Typiquement configurée en IP statique
- Serveur DHCP souvent activé pour les clients
- Règles par défaut permissives (allow all outbound)

**Configuration standard :**

- Réseau privé : `192.168.1.0/24`, `10.0.0.0/8`, ou `172.16.0.0/12`
- pfSense en passerelle : `192.168.1.1` par exemple
- Services activés : DHCP, DNS resolver

### OPT (Optional interfaces)

> [!example] Interfaces optionnelles Les interfaces OPT1, OPT2, OPT3... sont des interfaces supplémentaires pour segmenter davantage le réseau.

**Cas d'usage courants :**

|Interface|Usage typique|Exemple de réseau|
|---|---|---|
|OPT1 (DMZ)|Serveurs publics|`10.10.10.0/24`|
|OPT2 (GUEST)|Wi-Fi invités|`192.168.100.0/24`|
|OPT3 (VOIP)|Téléphonie IP|`172.16.50.0/24`|
|OPT4 (MGMT)|Administration|`192.168.200.0/24`|
|OPT5 (IOT)|Objets connectés|`192.168.150.0/24`|

> [!tip] Renommage des interfaces Il est fortement recommandé de renommer les interfaces OPTx avec des noms explicites (DMZ, GUEST, VOIP) pour faciliter la gestion et éviter les erreurs de configuration.

---

## 🔧 Attribution des interfaces réseau

L'attribution consiste à associer une interface physique (ou virtuelle) du système à un rôle spécifique dans pfSense (WAN, LAN, OPT).

### Processus d'attribution initial

Lors de la première installation, pfSense propose un assistant de configuration accessible :

- Via la console (setup wizard)
- Via l'interface web (après configuration minimale)

> [!warning] Attention à l'ordre L'ordre d'attribution des interfaces est crucial. Une erreur peut vous couper l'accès à l'interface web et nécessiter une reconfiguration via la console.

### Attribution via la console

**Accès au menu d'attribution :**

```bash
# Dans le menu principal pfSense, sélectionner l'option :
1) Assign interfaces
```

**Processus étape par étape :**

1. **Identification des interfaces physiques**
    
    - pfSense liste toutes les interfaces détectées (`em0`, `em1`, `igb0`, `vtnet0`, etc.)
    - Vérifier les adresses MAC pour identifier correctement chaque interface
2. **Attribution de la WAN**
    
    ```
    Enter the WAN interface name or 'a' for auto-detection
    (em0 em1 or a): em0
    ```
    
3. **Attribution de la LAN**
    
    ```
    Enter the LAN interface name or 'a' for auto-detection
    (em1 or a): em1
    ```
    
4. **Attribution des interfaces optionnelles**
    
    ```
    Enter the Optional interface name or 'a' for auto-detection
    (or press ENTER to finish): em2
    ```
    
5. **Validation**
    
    ```
    Do you want to proceed [y|n]? y
    ```
    

> [!tip] Auto-détection L'option 'a' permet à pfSense de tenter une auto-détection en générant du trafic sur l'interface. Connecter temporairement un câble réseau actif peut aider.

### Attribution via l'interface web

**Navigation :** `Interfaces > Assignments`

**Avantages de la méthode web :**

- Interface visuelle plus claire
- Possibilité de voir toutes les interfaces simultanément
- Ajout/suppression d'interfaces sans interruption de service

**Procédure :**

1. Accéder à `Interfaces > Assignments`
2. Dans la section "Available network ports", sélectionner l'interface physique
3. Cliquer sur `+ Add` pour créer une nouvelle interface OPT
4. L'interface apparaît comme "OPTx"
5. Cliquer sur le nom de l'interface (ex: OPT1) pour la configurer

### Identification des interfaces physiques

> [!warning] Piège courant Sur un serveur avec plusieurs cartes réseau identiques, il est facile de confondre les interfaces. Toujours vérifier l'adresse MAC et effectuer des tests de connectivité.

**Méthodes d'identification :**

1. **Via l'adresse MAC**
    
    - Noter l'adresse MAC physique sur l'équipement
    - Comparer avec celle affichée dans pfSense
2. **Test de lien (link detection)**
    
    - Brancher/débrancher un câble
    - Observer quelle interface change d'état
3. **Génération de trafic**
    
    - Connecter un équipement qui génère du trafic
    - Utiliser `Diagnostics > Traffic Graph` pour voir l'activité

**Console - Affichage des interfaces :**

```bash
# Option 8) Shell du menu pfSense
ifconfig
# ou
ifconfig -a | grep -E "^[a-z]|ether|status"
```

---

## 🌐 Configuration IP : Statique vs DHCP

Chaque interface pfSense peut obtenir son adresse IP de différentes manières selon son rôle et son environnement.

### Configuration IP statique

> [!info] Quand utiliser une IP statique ?
> 
> - Interface LAN (toujours)
> - Interfaces OPT (généralement)
> - WAN pour connexions professionnelles avec IP fixe
> - Toute interface servant de passerelle pour un réseau

**Configuration via l'interface web :**

**Navigation :** `Interfaces > [Nom de l'interface]` (ex: LAN, WAN, OPT1)

**Paramètres essentiels :**

```
Enable interface: ☑ Coché

IPv4 Configuration Type: Static IPv4

IPv4 Address: 192.168.1.1 / 24
```

**Détails des champs :**

|Champ|Description|Exemple|
|---|---|---|
|IPv4 Address|Adresse IP de l'interface pfSense|`192.168.1.1`|
|Subnet Mask|Masque de sous-réseau (notation CIDR)|`/24` (= 255.255.255.0)|
|IPv4 Upstream Gateway|Passerelle pour joindre d'autres réseaux|Laisser vide pour LAN, remplir pour WAN|

**Configuration d'une interface LAN typique :**

```
Enable interface: ☑
Description: LAN
IPv4 Configuration Type: Static IPv4
IPv6 Configuration Type: None

IPv4 Address: 192.168.1.1 / 24
```

**Configuration d'une interface DMZ (OPT1) :**

```
Enable interface: ☑
Description: DMZ
IPv4 Configuration Type: Static IPv4
IPv6 Configuration Type: None

IPv4 Address: 10.10.10.1 / 24
```

> [!tip] Choix du masque de sous-réseau
> 
> - `/24` (254 hôtes) : Réseaux LAN standards
> - `/23` (510 hôtes) : Grands réseaux LAN
> - `/26` (62 hôtes) : Petits segments (VOIP, DMZ)
> - `/29` (6 hôtes) : Liens point-to-point

### Configuration DHCP Client

> [!info] Quand utiliser DHCP Client ?
> 
> - Interface WAN connectée à une box/modem FAI
> - Interface connectée à un réseau géré par un autre équipement
> - Environnements de test où l'IP est attribuée dynamiquement

**Configuration via l'interface web :**

```
Enable interface: ☑
IPv4 Configuration Type: DHCP

DHCP Client Configuration:
  Hostname: [optionnel - nom envoyé au serveur DHCP]
  Alias IPv4 address: [optionnel - IP supplémentaire]
  Reject Leases From: [optionnel - rejeter certains serveurs DHCP]
```

**Options avancées DHCP :**

|Option|Usage|Exemple|
|---|---|---|
|Hostname|Identification auprès du FAI|`pfsense-site1`|
|Send Host Name|Envoyer le hostname au serveur DHCP|Coché pour certains FAI|
|Protocol Timing|Ajuster les délais de requête|Défaut OK dans 99% des cas|
|Reject Leases From|Sécurité - bloquer des serveurs DHCP spécifiques|`192.168.0.1`|

> [!warning] DHCP sur l'interface WAN Avec DHCP, pfSense reçoit également automatiquement les serveurs DNS du FAI. Vérifier que les règles de firewall et le DNS resolver sont correctement configurés pour éviter les fuites DNS.

### Configuration PPPoE

> [!info] Quand utiliser PPPoE ?
> 
> - Connexions ADSL/VDSL/Fibre nécessitant une authentification
> - Certains FAI français (Orange, Free dans certains cas)
> - Connexions directes sans box intermédiaire

**Configuration via l'interface web :**

```
Enable interface: ☑
IPv4 Configuration Type: PPPoE

PPPoE Configuration:
  Username: fti/votre_login
  Password: ••••••••
  Service name: [généralement vide]
  Dial on demand: ☐ Décoché (connexion permanente)
```

**Paramètres spécifiques PPPoE :**

|Paramètre|Description|Valeur typique|
|---|---|---|
|Idle timeout|Déconnexion après inactivité|0 (désactivé)|
|MTU|Taille maximale des paquets|1492 (PPPoE)|
|MRU|Taille maximale en réception|1492|

> [!tip] MTU pour PPPoE La valeur standard pour PPPoE est 1492 (1500 - 8 octets d'overhead PPPoE). Une mauvaise valeur MTU peut causer des problèmes de performance ou de connectivité.

### Comparaison des méthodes

|Méthode|Avantages|Inconvénients|Cas d'usage|
|---|---|---|---|
|**IP Statique**|Contrôle total, prévisible, stable|Configuration manuelle|LAN, DMZ, serveurs|
|**DHCP Client**|Simple, automatique, adaptable|Dépendance externe, IP changeante|WAN (box FAI), test|
|**PPPoE**|Authentification, connexion directe FAI|Plus complexe, overhead|ADSL/VDSL/Fibre pro|

---

## 🏷️ VLANs sur les interfaces

Les VLANs (Virtual Local Area Networks) permettent de segmenter logiquement un réseau physique en plusieurs réseaux virtuels isolés, en utilisant la norme IEEE 802.1Q.

### Concepts fondamentaux

> [!info] Qu'est-ce qu'un VLAN ? Un VLAN est un réseau local virtuel qui permet de segmenter un réseau physique en plusieurs domaines de diffusion séparés. Chaque VLAN fonctionne comme un réseau indépendant, même s'il partage la même infrastructure physique.

**Avantages des VLANs :**

- **Économie** : Utiliser une seule interface physique pour plusieurs réseaux
- **Flexibilité** : Déplacer des équipements entre VLANs sans recâblage
- **Sécurité** : Isolation du trafic entre segments
- **Organisation** : Grouper logiquement les équipements (par fonction, département, etc.)

**Terminologie :**

|Terme|Définition|
|---|---|
|**VLAN ID**|Identifiant numérique du VLAN (1-4094)|
|**Tagged / Trunk**|Port qui transporte plusieurs VLANs avec marquage|
|**Untagged / Access**|Port appartenant à un seul VLAN sans marquage|
|**Parent Interface**|Interface physique sur laquelle les VLANs sont créés|
|**VLAN Interface**|Interface virtuelle correspondant à un VLAN spécifique|

### Configuration des VLANs dans pfSense

#### Étape 1 : Création des VLANs

**Navigation :** `Interfaces > Assignments > VLANs`

**Procédure :**

1. Cliquer sur `+ Add` pour créer un nouveau VLAN
2. Remplir les paramètres :

```
Parent Interface: em1 (interface physique sur laquelle créer le VLAN)
VLAN Tag: 10 (ID du VLAN - doit correspondre à la config du switch)
VLAN Priority: [optionnel - QoS 802.1p]
Description: VLAN_SERVEURS
```

**Paramètres détaillés :**

|Champ|Description|Exemple|Notes|
|---|---|---|---|
|Parent Interface|Interface physique parente|`em1`, `igb0`|Doit supporter 802.1Q|
|VLAN Tag|ID du VLAN (1-4094)|`10`, `20`, `100`|Éviter 1 et 1002-1005|
|VLAN Priority|Priorité 802.1p (0-7)|`0` (défaut)|Pour QoS avancé|
|Description|Nom descriptif|`VLAN_SERVEURS`|Facilite l'identification|

> [!example] Exemple de plan VLAN
> 
> ```
> VLAN 10 - Serveurs (10.10.10.0/24)
> VLAN 20 - Postes de travail (10.10.20.0/24)
> VLAN 30 - VOIP (10.10.30.0/24)
> VLAN 40 - Invités (10.10.40.0/24)
> VLAN 99 - Management (10.10.99.0/24)
> ```

#### Étape 2 : Attribution des interfaces VLAN

**Navigation :** `Interfaces > Assignments`

Une fois les VLANs créés, ils apparaissent dans la liste "Available network ports" sous la forme `em1.10`, `em1.20`, etc.

**Procédure :**

1. Sélectionner le VLAN dans le menu déroulant "Available network ports"
2. Cliquer sur `+ Add`
3. L'interface VLAN est créée (OPTx)
4. Cliquer sur le nom de l'interface (ex: OPT1) pour la renommer et configurer

#### Étape 3 : Configuration de l'interface VLAN

**Navigation :** `Interfaces > [OPTx]` (où OPTx est l'interface VLAN créée)

**Configuration typique d'un VLAN :**

```
Enable interface: ☑
Description: SERVEURS (renommer depuis OPT1)
IPv4 Configuration Type: Static IPv4

IPv4 Address: 10.10.10.1 / 24

Block private networks: ☐ Décoché
Block bogon networks: ☐ Décoché
```

**Répéter pour chaque VLAN :**

```
VLAN 10 (SERVEURS):
  Interface: em1.10
  IP: 10.10.10.1/24
  
VLAN 20 (POSTES):
  Interface: em1.20
  IP: 10.10.20.1/24
  
VLAN 30 (VOIP):
  Interface: em1.30
  IP: 10.10.30.1/24
```

### Configuration du switch réseau

> [!warning] Configuration du switch indispensable Les VLANs ne fonctionneront pas correctement si le switch réseau n'est pas configuré pour supporter et transporter les VLANs. Le port connecté à pfSense DOIT être en mode trunk/tagged.

**Configuration switch - Port vers pfSense :**

```
Port: 1 (exemple)
Mode: Trunk / Tagged
VLANs autorisés: 10, 20, 30, 40, 99
VLAN natif: none ou 1 (selon le switch)
```

**Configuration switch - Ports vers équipements :**

```
Port: 5 (serveur dans VLAN 10)
Mode: Access / Untagged
VLAN: 10

Port: 10 (poste de travail dans VLAN 20)
Mode: Access / Untagged
VLAN: 20
```

### Cas d'usage avancés

#### VLAN sur plusieurs interfaces physiques

Si votre pfSense possède plusieurs interfaces physiques, vous pouvez créer des VLANs sur chacune :

```
Interface em1 (Switch LAN):
  - VLAN 10 (Serveurs)
  - VLAN 20 (Postes)

Interface em2 (Switch DMZ):
  - VLAN 50 (DMZ Web)
  - VLAN 51 (DMZ Mail)
```

#### Inter-VLAN routing

> [!info] Routage entre VLANs Par défaut, les VLANs sont isolés. Pour permettre la communication entre VLANs, il faut créer des règles de firewall spécifiques sur chaque interface VLAN.

**Exemple :** Autoriser VLAN 20 (Postes) à accéder VLAN 10 (Serveurs) sur le port 445 (SMB)

```
Firewall > Rules > POSTES (interface VLAN 20)

Action: Pass
Protocol: TCP
Source: POSTES net
Destination: SERVEURS net (10.10.10.0/24)
Destination Port: 445
```

> [!tip] Bonnes pratiques VLANs
> 
> - Documenter le plan d'adressage VLAN et l'afficher
> - Utiliser des ID de VLAN cohérents (10, 20, 30... ou 100, 200, 300...)
> - Nommer explicitement les interfaces VLAN (pas OPT1, OPT2...)
> - Créer un VLAN dédié au management des équipements réseau
> - Toujours tester la connectivité après création d'un VLAN

### Dépannage VLANs

**Problèmes courants :**

|Symptôme|Cause probable|Solution|
|---|---|---|
|Pas de connectivité sur le VLAN|Switch non configuré en trunk|Vérifier la config du switch|
|VLAN ID incorrect|Mauvais tag sur pfSense ou switch|Vérifier la cohérence des tags|
|Pas d'adresse IP (DHCP)|Serveur DHCP non activé sur l'interface VLAN|Activer DHCP dans Services > DHCP Server|
|Impossible de pinger la gateway|Interface VLAN non activée|Cocher "Enable interface"|
|Trafic entre VLANs bloqué|Règles de firewall manquantes|Créer règles inter-VLAN appropriées|

**Commandes de diagnostic :**

```bash
# Shell pfSense (Option 8 du menu)

# Voir toutes les interfaces VLAN
ifconfig | grep vlan

# Voir le trafic sur une interface VLAN
tcpdump -i em1.10 -n

# Statistiques d'une interface
netstat -I em1.10
```

---

## ✅ Bonnes pratiques

### Nomenclature et organisation

> [!tip] Nommage cohérent
> 
> - Renommer toutes les interfaces OPT avec des noms explicites
> - Utiliser des conventions claires : `SERVEURS`, `DMZ`, `WIFI_GUESTS`, `VOIP`
> - Éviter les espaces dans les noms d'interfaces
> - Documenter chaque interface avec une description complète

**Exemple de plan de nommage :**

```
WAN - Connexion Internet (Fibre Orange)
LAN - Réseau utilisateurs principal (192.168.1.0/24)
DMZ - Serveurs publics (10.10.10.0/24)
MGMT - Administration équipements (192.168.200.0/24)
VOIP - Téléphonie IP (172.16.50.0/24)
GUEST - Wi-Fi invités (192.168.100.0/24)
```

### Sécurité des interfaces

> [!warning] Règles de base
> 
> - L'interface WAN doit toujours être la plus restrictive (deny all inbound par défaut)
> - Ne jamais exposer l'interface de management directement sur la WAN
> - Utiliser des règles explicites plutôt que "allow any"
> - Activer le blocage des réseaux privés et bogons sur WAN

**Configuration WAN sécurisée :**

```
Interfaces > WAN

Block private networks: ☑ Coché
Block bogon networks: ☑ Coché
```

### Planification des adresses IP

> [!tip] Plan d'adressage Toujours établir un plan d'adressage cohérent avant de configurer les interfaces :

**Exemple de schéma :**

|Interface|Réseau|Passerelle pfSense|Plage DHCP|Usage|
|---|---|---|---|---|
|LAN|192.168.1.0/24|192.168.1.1|.100-.250|Utilisateurs|
|DMZ|10.10.10.0/24|10.10.10.1|Aucun (IPs fixes)|Serveurs publics|
|VOIP|172.16.50.0/26|172.16.50.1|.10-.60|Téléphones IP|
|GUEST|192.168.100.0/24|192.168.100.1|.50-.200|Wi-Fi invités|

### Performance et optimisation

> [!tip] Optimisations
> 
> - Désactiver IPv6 si non utilisé pour réduire la charge
> - Utiliser des interfaces dédiées plutôt que des VLANs pour les segments critiques (haute charge)
> - Activer le hardware offloading si supporté par la carte réseau
> - Monitorer régulièrement l'utilisation de la bande passante par interface

**Vérification du hardware offloading :**

```
System > Advanced > Networking

Hardware Checksum Offloading: ☑ Coché (si supporté)
Hardware TCP Segmentation Offloading: ☑ Coché (si supporté)
Hardware Large Receive Offloading: ☑ Coché (si supporté)
```

### Documentation

> [!info] Maintenir à jour Pour chaque interface, documenter :
> 
> - Nom et rôle de l'interface
> - Adressage IP et masque
> - Services activés (DHCP, DNS, etc.)
> - Connexion physique (port switch, câble, équipement connecté)
> - Règles de firewall principales
> - Historique des modifications

**Exemple de documentation :**

```markdown
## Interface DMZ
- **Nom physique:** em2
- **IP pfSense:** 10.10.10.1/24
- **Réseau:** 10.10.10.0/24
- **Connexion:** Port 24 du switch HP 1920 (rack A)
- **Services:** Aucun DHCP (IPs fixes seulement)
- **Équipements connectés:** 
  - Serveur Web: 10.10.10.10
  - Serveur Mail: 10.10.10.20
- **Dernière modification:** 2026-01-05 - Ajout serveur Web
```

### Sauvegardes

> [!warning] Sauvegarder avant toute modification Avant de modifier la configuration des interfaces :
> 
> - Créer une sauvegarde : `Diagnostics > Backup & Restore`
> - Télécharger le fichier XML de configuration
> - Conserver plusieurs versions avec dates

---

## 🎓 Points clés à retenir

- Les interfaces sont la fondation de la configuration réseau pfSense
- **WAN** = Internet/extérieur, **LAN** = réseau interne, **OPT** = segments additionnels
- L'attribution des interfaces peut se faire via console ou interface web
- **IP statique** pour les interfaces servant de passerelle (LAN, OPT)
- **DHCP Client** pour l'interface WAN connectée à une box FAI
- Les **VLANs** permettent de segmenter un réseau physique en plusieurs réseaux virtuels
- Toujours configurer le switch réseau en mode trunk pour supporter les VLANs
- Renommer les interfaces OPT avec des noms explicites
- Documenter systématiquement chaque interface et son rôle
- Sauvegarder avant toute modification de configuration réseau

---

**Dernière mise à jour :** 2026-01-10