

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

## Introduction au NAT

Le **NAT (Network Address Translation)** est un mécanisme fondamental qui permet de traduire des adresses IP privées en adresses IP publiques et inversement. Dans pfSense, le NAT joue un rôle crucial pour permettre aux machines du réseau local d'accéder à Internet et pour rendre accessible des services internes depuis l'extérieur.

> [!info] Pourquoi le NAT est-il essentiel ?
> 
> - **Conservation des adresses IPv4** : Permet à plusieurs machines privées de partager une seule IP publique
> - **Sécurité** : Masque la topologie interne du réseau
> - **Flexibilité** : Permet de rediriger le trafic selon les besoins

### Types de NAT dans pfSense

|Type|Objectif|Usage typique|
|---|---|---|
|**Outbound NAT**|Traduit les IP privées vers l'IP publique en sortie|Navigation Internet depuis le LAN|
|**Port Forward**|Redirige un port public vers une machine interne|Héberger un serveur web, SSH, etc.|
|**NAT 1:1**|Associe une IP publique à une IP privée de façon bidirectionnelle|Serveurs nécessitant une IP publique dédiée|
|**NPt**|Translation de préfixes IPv6|Environnements IPv6 avec plusieurs FAI|

---

## NAT Sortant (Outbound NAT)

Le NAT sortant permet aux machines du réseau local (adresses privées RFC1918) de communiquer avec Internet en traduisant leur adresse source vers l'adresse IP publique du WAN.

### 🎯 Principe de fonctionnement

Lorsqu'un client LAN (ex: 192.168.1.10) envoie une requête vers Internet :

1. **Paquet sortant** : Source 192.168.1.10:45678 → Destination 8.8.8.8:53
2. **Après NAT** : Source IP_PUBLIQUE_WAN:12345 → Destination 8.8.8.8:53
3. **Réponse** : Le pare-feu inverse la traduction pour router vers 192.168.1.10

> [!tip] Conservation des états pfSense maintient une **table d'états** qui enregistre chaque connexion NAT pour pouvoir inverser correctement la traduction lors du retour des paquets.

### Modes de configuration

#### Mode automatique (Automatic Outbound NAT)

C'est le mode par défaut et le plus simple.

**Navigation** : `Firewall → NAT → Outbound`

> [!example] Configuration automatique pfSense génère automatiquement les règles NAT pour tous les réseaux LAN détectés. Ce mode convient à 90% des installations.

**Avantages** :

- Configuration automatique
- Maintenance minimale
- Adapté aux topologies simples

**Limites** :

- Pas de contrôle fin
- Impossible de personnaliser le comportement NAT

#### Mode hybride (Hybrid Outbound NAT)

Combine les règles automatiques avec des règles manuelles personnalisées.

> [!warning] Attention à l'ordre Les règles manuelles sont évaluées **avant** les règles automatiques. La première correspondance gagne.

**Cas d'usage** :

- Forcer certains réseaux à utiliser une IP source spécifique
- Désactiver le NAT pour certains flux (VPN site-à-site)
- Modifier le port source pour certains services

#### Mode manuel (Manual Outbound NAT)

Contrôle total : vous devez créer **toutes** les règles NAT manuellement.

> [!tip] Quand utiliser le mode manuel ?
> 
> - Environnements complexes avec plusieurs WAN
> - Besoins spécifiques de translation d'adresses
> - Débogage avancé du NAT

### Création d'une règle Outbound NAT manuelle

**Navigation** : `Firewall → NAT → Outbound → Add`

```
Interface            : WAN
Protocol             : any (ou TCP/UDP/ICMP selon besoin)
Source               : 192.168.10.0/24 (réseau interne)
Destination          : any
Translation Address  : Interface Address (IP du WAN)
Translation Port     : * (aléatoire)
Static Port          : Non coché (sauf cas particulier)
Description          : NAT pour réseau VLAN10
```

#### Paramètres importants

**Translation Address** :

- `Interface Address` : Utilise l'IP du WAN (cas standard)
- IP spécifique : Utile si plusieurs IP publiques disponibles
- Alias : Pour gérer des pools d'IP

**Static Port** :

- ☐ **Non coché** (défaut) : pfSense change le port source (recommandé)
- ☑ **Coché** : Conserve le port source d'origine (nécessaire pour certains protocoles VoIP, jeux)

> [!warning] Static Port et épuisement de ports Activer "Static Port" peut causer des conflits si deux machines internes utilisent le même port source simultanément.

**No NAT** :

- Permet de désactiver le NAT pour certains flux
- Utile pour les VPN site-à-site (le trafic doit garder son IP source privée)

### Scénarios courants

#### Forcer une IP source spécifique pour un serveur

```
Interface            : WAN
Source               : 192.168.1.100/32 (serveur spécifique)
Translation Address  : 203.0.113.50 (IP publique dédiée)
Description          : NAT serveur mail vers IP publique secondaire
```

#### Désactiver le NAT pour un tunnel VPN

```
Interface            : WAN
Source               : 192.168.1.0/24
Destination          : 10.20.30.0/24 (réseau distant VPN)
No NAT               : ☑ Coché
Description          : Pas de NAT vers site distant IPsec
```

> [!tip] Astuce de débogage Utilisez `Diagnostics → States → Show States` pour visualiser les connexions NAT actives et vérifier les translations d'adresses en temps réel.

---

## Redirection de Ports (Port Forward)

La redirection de ports (Port Forwarding) permet de rendre accessible un service interne depuis Internet en redirigeant un port public vers une machine et un port du réseau local.

### 🎯 Principe de fonctionnement

Une requête externe arrive sur l'IP publique → pfSense la redirige vers une machine interne spécifique.

**Exemple** : Héberger un serveur web interne

1. **Requête externe** : 203.0.113.10:80 → Arrive sur le WAN
2. **Port Forward** : pfSense redirige vers 192.168.1.50:80
3. **Réponse** : Le serveur web répond, pfSense inverse la NAT
4. **Retour** : Le client externe voit la réponse venir de 203.0.113.10:80

### Configuration d'une redirection de port

**Navigation** : `Firewall → NAT → Port Forward → Add`

#### Exemple 1 : Serveur Web (HTTP)

```
Interface              : WAN
Protocol               : TCP
Destination            : WAN address
Destination Port Range : HTTP (80) to HTTP (80)
Redirect Target IP     : 192.168.1.50
Redirect Target Port   : HTTP (80)
Description            : Web server interne
Filter rule association: Add associated filter rule
```

> [!info] Règle de firewall automatique Par défaut, pfSense crée automatiquement une règle de firewall sur le WAN pour autoriser le trafic redirigé. Vous pouvez désactiver ce comportement avec "Filter rule association: None".

#### Exemple 2 : SSH sur un port non-standard

```
Interface              : WAN
Protocol               : TCP
Destination            : WAN address
Destination Port Range : 2222 to 2222
Redirect Target IP     : 192.168.1.100
Redirect Target Port   : 22
Description            : SSH serveur administration (port custom)
```

> [!tip] Sécurité par obscurité Utiliser un port non-standard (ex: 2222 au lieu de 22) réduit les tentatives de scan automatisé, mais ne remplace **pas** une authentification forte.

#### Exemple 3 : Plage de ports (FTP passif)

```
Interface              : WAN
Protocol               : TCP
Destination            : WAN address
Destination Port Range : 50000 to 50100
Redirect Target IP     : 192.168.1.60
Redirect Target Port   : 50000
Description            : FTP passif - plage de ports data
```

### Paramètres avancés

#### Destination

- **WAN address** : Redirige le trafic arrivant sur l'IP principale du WAN
- **WAN subnet** : Redirige pour toutes les IP du subnet WAN (si plusieurs IP)
- **IP spécifique** : Utile si vous avez plusieurs IP publiques

#### NAT Reflection

Le NAT Reflection permet aux clients du LAN d'accéder au service en utilisant l'IP publique.

**Problème sans NAT Reflection** :

- Client LAN (192.168.1.20) tente d'accéder à 203.0.113.10:80
- La requête part vers le WAN mais ne revient pas correctement

**Solution** : Activer le NAT Reflection

**Navigation** : `System → Advanced → Firewall & NAT → NAT Reflection mode`

Options :

- **Disabled** : Pas de reflection (le client doit utiliser l'IP locale)
- **NAT + Proxy** : pfSense agit comme proxy (recommandé)
- **Pure NAT** : Translation complète (peut causer des problèmes)

> [!warning] Performance NAT Reflection utilise des ressources supplémentaires. Sur les grandes installations, privilégiez l'utilisation de Split DNS (résolution différente interne/externe).

#### Filter rule association

- **Add associated filter rule** : Crée automatiquement la règle firewall (recommandé)
- **Add unassociated filter rule** : Crée la règle mais sans lien (manuel)
- **Pass** : Autorise directement sans créer de règle séparée
- **None** : Aucune règle (vous devez la créer manuellement)

### Redirections multiples vers la même IP

Vous pouvez créer plusieurs redirections vers le même serveur interne :

```
Port 80  → 192.168.1.50:80  (HTTP)
Port 443 → 192.168.1.50:443 (HTTPS)
Port 25  → 192.168.1.50:25  (SMTP)
```

> [!example] Serveur multi-services Un seul serveur interne peut exposer plusieurs services via différentes redirections de ports.

### Pièges courants

> [!warning] Boucle de redirection Ne créez **jamais** une redirection de port qui pointe vers pfSense lui-même (ex: rediriger le port 443 WAN vers l'IP LAN de pfSense).

> [!warning] Port déjà utilisé par pfSense Si pfSense utilise déjà un port (ex: 80 pour le WebGUI, 53 pour DNS), la redirection échouera. Changez le port du service pfSense ou utilisez un port différent.

> [!tip] Tester une redirection Utilisez `Diagnostics → Test Port` pour vérifier qu'un port interne est bien ouvert avant de créer la redirection.

### Validation et débogage

**Vérifier les états actifs** : `Diagnostics → States → Show States`

Recherchez votre IP publique et le port concerné pour voir si les connexions sont établies.

**Vérifier les logs** : `Status → System Logs → Firewall`

Filtrez par l'IP source externe pour voir si le trafic est bloqué ou autorisé.

---

## NAT 1:1

Le **NAT 1:1** (ou Static NAT) établit une correspondance bidirectionnelle permanente entre une adresse IP publique et une adresse IP privée. Contrairement au Port Forward, **tous les ports** sont mappés.

### 🎯 Principe de fonctionnement

Une IP publique est "collée" à une IP privée dans les deux sens :

- **Trafic sortant** : 192.168.1.50 → traduit en 203.0.113.20
- **Trafic entrant** : 203.0.113.20:XXXX → redirigé vers 192.168.1.50:XXXX

> [!info] Tous les ports Avec le NAT 1:1, **tous les ports et protocoles** sont traduits, pas seulement certains ports spécifiques comme avec Port Forward.

### Quand utiliser le NAT 1:1 ?

**Cas d'usage typiques** :

- Serveur nécessitant une IP publique dédiée (certification SSL)
- Serveur de jeux nécessitant de nombreux ports
- Équipement réseau devant être accessible complètement (caméras IP, NAS)
- Appliance tierce nécessitant une exposition complète

> [!warning] Limitation Vous devez disposer de **plusieurs adresses IP publiques** pour utiliser le NAT 1:1 (une par machine interne).

### Configuration d'un NAT 1:1

**Navigation** : `Firewall → NAT → 1:1 → Add`

#### Exemple : Serveur mail avec IP dédiée

```
Interface           : WAN
External subnet IP  : 203.0.113.25/32
Internal IP         : 192.168.1.75
Destination         : any
Description         : Serveur mail - IP publique dédiée
NAT reflection      : Enable (si besoin d'accès interne)
```

**Explication** :

- Toute connexion vers 203.0.113.25 (n'importe quel port) → redirigée vers 192.168.1.75
- Toute connexion sortante de 192.168.1.75 → apparaît comme provenant de 203.0.113.25

### Paramètres importants

**External subnet IP** :

- L'adresse IP publique supplémentaire à utiliser
- Doit être configurée comme Virtual IP (VIP) au préalable
- Format : IP/32 pour une seule adresse

**Internal IP** :

- L'adresse IP privée de la machine interne
- Généralement une IP statique (pas DHCP)

**Destination** :

- `any` : Le NAT s'applique pour toute destination (standard)
- Réseau spécifique : Limite le NAT 1:1 à certaines destinations

> [!tip] Virtual IP requis Avant de créer un NAT 1:1, vous devez d'abord configurer l'IP publique supplémentaire comme Virtual IP dans `Firewall → Virtual IPs`.

### NAT 1:1 vs Port Forward

|Critère|NAT 1:1|Port Forward|
|---|---|---|
|**Ports mappés**|Tous les ports|Ports spécifiques uniquement|
|**IP publiques requises**|Une par machine|Une partagée pour toutes|
|**Flexibilité**|Faible (tout ou rien)|Haute (port par port)|
|**Sécurité**|Exposition totale|Exposition ciblée|
|**Complexité**|Simple|Moyenne|
|**Coût**|Élevé (IP publiques multiples)|Faible (une IP suffit)|

> [!warning] Sécurité Le NAT 1:1 expose **complètement** la machine interne. Assurez-vous que :
> 
> - Le serveur est correctement sécurisé
> - Un pare-feu local (host firewall) est actif
> - Seuls les services nécessaires sont en écoute

### Règles de firewall associées

> [!info] Règles manuelles requises Contrairement au Port Forward, le NAT 1:1 **ne crée pas automatiquement** de règles de firewall. Vous devez les créer manuellement sur l'interface WAN.

**Exemple de règles WAN pour un serveur NAT 1:1** :

```
Action      : Pass
Interface   : WAN
Protocol    : TCP
Source      : any
Destination : 203.0.113.25 (VIP)
Dest. Port  : HTTP (80)
Description : Autoriser HTTP vers serveur NAT 1:1
```

```
Action      : Pass
Interface   : WAN
Protocol    : TCP
Source      : any
Destination : 203.0.113.25 (VIP)
Dest. Port  : HTTPS (443)
Description : Autoriser HTTPS vers serveur NAT 1:1
```

> [!tip] Stratégie de sécurité Même avec un NAT 1:1, n'autorisez que les ports strictement nécessaires dans les règles de firewall pour limiter la surface d'attaque.

### Combinaison avec Outbound NAT

Le NAT 1:1 affecte également le trafic **sortant** :

```
Avant NAT 1:1 :
192.168.1.75 → Internet (avec IP WAN principale)

Après NAT 1:1 :
192.168.1.75 → Internet (avec 203.0.113.25)
```

Cela peut être utile pour :

- Whitelisting d'IP sur des services externes
- Logs avec IP source dédiée
- Reverse DNS cohérent

---

## NPt (IPv6)

**NPt (Network Prefix Translation)** est l'équivalent IPv6 du NAT, mais avec des différences fondamentales. Il traduit les préfixes de réseau IPv6 plutôt que les adresses individuelles.

### 🎯 Différences NAT vs NPt

|Aspect|NAT (IPv4)|NPt (IPv6)|
|---|---|---|
|**Translation**|Adresses IP + ports|Préfixes réseau uniquement|
|**Objectif principal**|Économie d'adresses|Multi-homing, indépendance FAI|
|**Port mapping**|Oui (PAT)|Non (pas nécessaire)|
|**État**|Stateful (table d'états)|Stateless ou Stateful|
|**Performance**|Impact modéré|Impact minimal|

> [!info] Philosophie IPv6 IPv6 a été conçu pour éliminer le besoin de NAT grâce à l'abondance d'adresses. NPt est utilisé principalement pour le **multi-homing** (plusieurs FAI) et l'**indépendance de FAI**, pas pour économiser des adresses.

### Principe de fonctionnement

NPt remplace un préfixe IPv6 par un autre tout en conservant les bits d'interface (partie host) :

**Exemple** :

```
Préfixe interne  : fd00:1234:5678::/48
Préfixe externe  : 2001:db8:abcd::/48
Machine interne  : fd00:1234:5678::1:2:3:4

Après NPt sortant :
2001:db8:abcd::1:2:3:4 (même partie host, préfixe traduit)
```

> [!tip] Préservation de la partie host NPt conserve les 64 derniers bits (identifiant d'interface), seul le préfixe réseau (64 premiers bits) est traduit.

### Cas d'usage

#### 1. Multi-homing (plusieurs FAI)

Vous avez deux fournisseurs d'accès avec deux préfixes différents :

```
FAI A : 2001:db8:aaaa::/48
FAI B : 2001:db8:bbbb::/48
Interne : fd00:1111::/48 (ULA - Unique Local Address)
```

NPt permet de :

- Utiliser un préfixe interne stable (ULA)
- Traduire vers FAI A ou FAI B selon la route
- Changer de FAI sans renumérter le réseau interne

#### 2. Indépendance de FAI

Éviter de renumérter tout le réseau lors d'un changement de FAI :

```
Ancien FAI : 2001:db8:old::/48
Nouveau FAI : 2001:db8:new::/48
Interne : fd00:1234::/48 (reste inchangé)
```

Modification uniquement de la règle NPt, pas de reconfiguration des machines.

### Configuration NPt

**Navigation** : `Firewall → NAT → NPt → Add`

#### Exemple : Translation vers préfixe FAI

```
Interface           : WAN
Internal IPv6 Prefix: fd00:1234:5678::/48
External IPv6 Prefix: 2001:db8:abcd::/48
Description         : NPt vers préfixe FAI principal
```

**Fonctionnement** :

- **Sortant** : fd00:1234:5678::xxxx → 2001:db8:abcd::xxxx
- **Entrant** : 2001:db8:abcd::xxxx → fd00:1234:5678::xxxx

### ULA (Unique Local Address)

Les adresses ULA sont l'équivalent IPv6 des RFC1918 (10.0.0.0/8, 172.16.0.0/12, 192.168.0.0/16) :

**Préfixe ULA** : `fc00::/7` (en pratique `fd00::/8`)

> [!example] Génération d'un préfixe ULA Utilisez un générateur ULA pour créer un préfixe aléatoire unique : `fd[hex random]::[hex random]::[hex random]::/48`
> 
> Exemple : `fd3a:b2c1:9876::/48`

**Avantages des ULA** :

- Routables localement
- Non routables sur Internet (comme les IP privées IPv4)
- Stables lors de changement de FAI
- Évitent les renumbering

### NPt avec plusieurs WAN

Configuration avancée pour basculer entre plusieurs FAI :

```
Règle 1 :
Interface : WAN1
Internal  : fd00:1111::/48
External  : 2001:db8:aaaa::/48

Règle 2 :
Interface : WAN2
Internal  : fd00:1111::/48
External  : 2001:db8:bbbb::/48
```

Le routage détermine quelle règle NPt est appliquée selon l'interface de sortie.

### Considérations importantes

> [!warning] End-to-end connectivity NPt brise le principe de connectivité end-to-end d'IPv6. À utiliser seulement si nécessaire (multi-homing, contraintes FAI).

> [!tip] Préférer le routage natif Lorsque c'est possible, privilégiez le routage IPv6 natif sans translation. NPt devrait être une solution de dernier recours.

**Alternatives à NPt** :

- Utiliser directement les préfixes du FAI (renumbering si changement)
- BGP multi-homing avec préfixe propre (PI - Provider Independent)
- Dual-stack avec IPv4 + IPv6 natif

### Règles de firewall

Comme pour le NAT 1:1, NPt **ne crée pas automatiquement** de règles de firewall :

```
Action      : Pass
Interface   : WAN
Protocol    : IPv6
Source      : any
Destination : 2001:db8:abcd::/48
Description : Autoriser trafic entrant vers réseau NPt
```

> [!info] Filtrage stateful pfSense maintient l'état des connexions IPv6 comme pour IPv4, garantissant que seules les connexions légitimes sont autorisées.

---

## 🎯 Récapitulatif des types de NAT

|Type NAT|Translation|Ports|IP publiques|Bidirectionnel|Usage principal|
|---|---|---|---|---|---|
|**Outbound**|IP privée → IP publique|Port aléatoire|1 partagée|Non|Navigation Internet|
|**Port Forward**|Port public → IP:Port privé|Sélectifs|1 partagée|Entrant uniquement|Serveurs accessibles|
|**1:1**|IP publique ↔ IP privée|Tous|1 par machine|Oui|Exposition complète|
|**NPt**|Préfixe IPv6 ↔ Préfixe IPv6|N/A|Préfixe entier|Oui|Multi-homing IPv6|

> [!tip] Choisir le bon type de NAT
> 
> - **Accès Internet simple** → Outbound NAT automatique
> - **Serveur web, SSH, etc.** → Port Forward
> - **Serveur complexe, appliance** → NAT 1:1 (si IP disponibles)
> - **Multi-homing IPv6, indépendance FAI** → NPt

---

## 💡 Bonnes pratiques globales

### Sécurité

- **Principle of Least Privilege** : N'ouvrez que les ports strictement nécessaires
- **Utilisez des ports non-standard** pour les services sensibles (SSH sur 2222 au lieu de 22)
- **Combinez avec fail2ban/blocklist** pour bloquer les tentatives de brute-force
- **Surveillez les logs** régulièrement pour détecter les tentatives d'intrusion
- **NAT 1:1 = exposition totale** : assurez-vous que le serveur est durci (hardened)

### Performance

- **Mode Outbound automatique** pour la majorité des cas (moins de maintenance)
- **NAT Reflection** : préférez le Split DNS quand possible (meilleures performances)
- **Static Port** : à éviter sauf nécessité absolue (risque d'épuisement)
- **NPt** : préférez le routage IPv6 natif quand applicable

### Documentation

- **Descriptions claires** pour chaque règle NAT (qui, quoi, pourquoi)
- **Conventions de nommage** cohérentes
- **Documentation externe** : conservez un schéma réseau à jour
- **Changelog** : notez les modifications avec dates et raisons

### Débogage

**Ordre de vérification en cas de problème** :

1. **Règle NAT existe-t-elle ?** → Vérifier dans `Firewall → NAT`
2. **Règle firewall associée ?** → Vérifier dans `Firewall → Rules → WAN`
3. **État créé ?** → `Diagnostics → States`
4. **Logs** → `Status → System Logs → Firewall`
5. **Service interne actif ?** → `Diagnostics → Test Port`
6. **Route correcte ?** → `Diagnostics → Routes`

> [!tip] Capture de paquets En dernier recours, utilisez `Diagnostics → Packet Capture` pour analyser le trafic au niveau paquet et comprendre où il est bloqué.

---

## ⚠️ Pièges courants à éviter

### 1. Redirection vers pfSense lui-même

```
❌ Port Forward : WAN:443 → IP_LAN_pfSense:443
```

Cela créera une boucle. Si vous devez accéder au WebGUI depuis l'extérieur, utilisez un VPN.

### 2. Oublier la règle de firewall avec NAT 1:1

NAT 1:1 ne crée **pas** automatiquement de règle firewall → le trafic sera bloqué même si le NAT est configuré.

### 3. NAT Reflection sans considération de performance

Sur des réseaux avec beaucoup de trafic, NAT Reflection peut surcharger pfSense. Préférez le Split DNS.

### 4. Port déjà utilisé par pfSense

Si pfSense écoute déjà sur le port (ex: 53 pour DNS), la redirection échouera silencieusement. Vérifiez `Diagnostics → Sockets`.

### 5. DHCP sur une machine avec NAT 1:1

Une machine avec NAT 1:1 devrait avoir une IP **statique** pour garantir la cohérence du mapping.

### 6. Overlapping NPt prefixes

Vérifiez que vos préfixes internes et externes ne se chevauchent pas :

```
❌ Internal: 2001:db8:aaaa::/48
   External: 2001:db8:aaaa::/48
```

### 7. Modification du NAT sans rafraîchir les états

Après modification d'une règle NAT, les connexions existantes utilisent encore l'ancien mapping. Rafraîchissez les états : `Diagnostics → States → Reset States`.

---

## 🔍 Commandes de diagnostic utiles

### Vérifier les règles NAT actives

**Via WebGUI** :

- `Firewall → NAT` (configuration)
- `Diagnostics → States` (états actifs)
- `Status → System Logs → Firewall` (logs)

**Via CLI/Shell** :

```bash
# Voir toutes les règles NAT
pfctl -s nat

# Voir les états NAT actifs
pfctl -s state | grep NAT

# Voir les connexions actives avec détails
pfctl -s state -vv

# Statistiques des règles NAT
pfctl -s nat -v
```

### Tester la connectivité

```bash
# Depuis pfSense vers une machine interne
ping 192.168.1.50

# Test de port ouvert (depuis pfSense)
nc -zv 192.168.1.50 80

# Vérifier l'IP source externe (depuis machine LAN)
curl ifconfig.me
```

---

**Le NAT dans pfSense est un outil puissant mais qui nécessite une compréhension précise de chaque mécanisme. Choisissez le type de NAT adapté à votre besoin et documentez systématiquement vos configurations pour faciliter la maintenance future.**