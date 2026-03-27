

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

## Introduction au dépannage

> [!info] Philosophie du dépannage Le dépannage efficace de pfSense repose sur une approche méthodique et la compréhension des couches réseau. La plupart des problèmes peuvent être résolus en suivant une procédure systématique et en utilisant les bons outils de diagnostic.

> [!tip] Conseil général Avant toute modification, **documentez l'état actuel** et **créez une sauvegarde de configuration**. Les modifications hasardeuses peuvent aggraver la situation.

---

## Problèmes de connectivité WAN

### Diagnostic de la connexion WAN

La connectivité WAN est le premier point à vérifier lors de problèmes d'accès Internet.

#### Vérifications de base

> [!example] Checklist de diagnostic WAN
> 
> 1. **Statut de l'interface** : `Status > Interfaces`
>     - L'interface WAN doit être "up"
>     - Une adresse IP valide doit être attribuée
>     - Le câble réseau doit être connecté
> 2. **État physique** : Vérifier les voyants de la carte réseau
>     - Lien établi (LED link active)
>     - Vitesse de négociation correcte
> 3. **Adressage IP** : Selon le type de connexion
>     - DHCP : IP dans la plage du FAI
>     - Statique : Configuration correcte
>     - PPPoE : Statut de la session

#### Tests de connectivité

```bash
# Test 1 : Ping de la passerelle WAN
# Diagnostics > Ping
# Host: IP de la passerelle WAN (visible dans Status > Gateways)

# Test 2 : Ping d'un serveur DNS public
# Host: 8.8.8.8 ou 1.1.1.1

# Test 3 : Test DNS
# Diagnostics > DNS Lookup
# Hostname: google.com
```

> [!warning] Interprétation des tests
> 
> - **Ping gateway OK, DNS KO** → Problème de routage ou DNS
> - **Ping gateway KO** → Problème de couche 2/3 ou configuration WAN
> - **Ping IP OK, résolution DNS KO** → Problème de configuration DNS

#### Vérification de la table de routage

```bash
# Via shell (Diagnostics > Command Prompt)
netstat -rn

# Vérifier la route par défaut
# Elle doit pointer vers la passerelle WAN
# default            <IP_GATEWAY>      UGS       <interface_wan>
```

---

### Problèmes DHCP WAN

Lorsque pfSense ne reçoit pas d'adresse IP via DHCP.

#### Causes courantes

|Symptôme|Cause probable|Solution|
|---|---|---|
|Pas d'IP attribuée|Client DHCP non démarré|Redémarrer l'interface WAN|
|IP 169.254.x.x (APIPA)|Aucun serveur DHCP trouvé|Vérifier câblage et modem|
|Bail DHCP expiré|Problème de renouvellement|Forcer le renouvellement|
|Mauvaise IP|Conflit ou mauvais scope|Libérer et renouveler|

#### Dépannage DHCP

> [!example] Procédure de résolution
> 
> **Étape 1 : Vérifier le statut DHCP**
> 
> - `Status > Interfaces` → Vérifier si une IP est attribuée
> - `Status > System Logs > System` → Rechercher "dhclient"
> 
> **Étape 2 : Forcer le renouvellement**
> 
> ```bash
> # Via l'interface Web
> Status > Interfaces > WAN > Release / Renew
> 
> # Via shell
> /etc/rc.d/dhclient restart <interface_wan>
> ```
> 
> **Étape 3 : Vérifier les logs détaillés**
> 
> ```bash
> # Activer le mode verbose temporairement
> grep dhclient /var/log/system.log | tail -50
> ```

> [!tip] Astuce modem/box Certains modems/box mémorisent l'adresse MAC du dernier équipement connecté. Si vous remplacez votre routeur par pfSense, vous devrez peut-être :
> 
> - Éteindre le modem 5 minutes
> - Cloner l'adresse MAC de l'ancien routeur (`Interfaces > WAN > MAC Address`)

#### Configuration avancée DHCP

```plaintext
Interfaces > WAN > DHCP Client Configuration

Options importantes :
┌─────────────────────────────────────────────────┐
│ ☑ Advanced DHCP Options                        │
│                                                 │
│ Option modifiers:                               │
│ • dhcp-client-identifier : Identifiant client   │
│ • host-name : Nom d'hôte à envoyer             │
│ • vendor-class-identifier : Pour FAI exigeants │
│                                                 │
│ Exemples pour certains FAI :                   │
│ • Orange : vendor-class "sagem"                │
│ • Free : client-id spécifique                  │
└─────────────────────────────────────────────────┘
```

---

### Problèmes PPPoE

PPPoE est utilisé par de nombreux FAI (notamment en France, Allemagne, etc.).

#### Symptômes de dysfonctionnement

> [!warning] Signes d'un problème PPPoE
> 
> - Statut "Connecting" permanent
> - Déconnexions/reconnexions fréquentes
> - Erreur d'authentification
> - Timeout de connexion

#### Diagnostic PPPoE

```bash
# Vérifier le statut PPPoE
Status > Interfaces > WAN

# Indicateurs de santé :
# ✓ Status: up
# ✓ Uptime: Stable (pas de reconnexions)
# ✓ IP publique attribuée

# Logs PPPoE
Status > System Logs > System
# Rechercher : "ppp", "PPPoE", "LCP", "CHAP"
```

#### Erreurs courantes

|Erreur|Signification|Solution|
|---|---|---|
|LCP timeout|Pas de réponse du serveur|Vérifier câblage/modem|
|CHAP authentication failed|Identifiants incorrects|Vérifier username/password|
|Session timeout|Déconnexion côté FAI|Vérifier MTU, keepalive|
|No carrier|Lien physique absent|Problème de câble/port|

#### Configuration optimale PPPoE

> [!example] Paramètres recommandés
> 
> **Configuration de base** (`Interfaces > WAN`)
> 
> ```plaintext
> Type: PPPoE
> Username: <identifiant_FAI>
> Password: <mot_de_passe_FAI>
> Service name: (généralement vide, sauf FAI spécifique)
> 
> Advanced Options:
> ┌────────────────────────────────────────┐
> │ ☑ Enable periodic keep-alive          │
> │   Interval: 60 seconds                 │
> │                                        │
> │ ☑ Use MLPPP (si supporté par FAI)     │
> │                                        │
> │ MTU: 1492 (PPPoE standard)            │
> │      ou 1500 si autorisé par FAI      │
> │                                        │
> │ ☑ Enable PPPoE Logs                   │
> └────────────────────────────────────────┘
> ```

> [!tip] MTU optimal La valeur MTU correcte évite la fragmentation. Test :
> 
> ```bash
> # Depuis un PC derrière pfSense
> ping -f -l 1464 google.com  # Windows
> ping -D -s 1464 google.com  # Linux/Mac
> 
> # Si ça passe : MTU = 1464 + 28 = 1492
> # Si ça ne passe pas : réduire la taille jusqu'à ce que ça passe
> ```

#### Déconnexions fréquentes

> [!example] Résolution des déconnexions
> 
> **Cause 1 : Problème de keepalive**
> 
> ```plaintext
> Interfaces > WAN > Advanced PPPoE
> ☑ Enable periodic keep-alive
> Interval: 30-60 seconds
> ```
> 
> **Cause 2 : Instabilité ligne**
> 
> - Vérifier les statistiques du modem
> - Contacter le FAI pour test de ligne
> - Vérifier les filtres ADSL sur la prise
> 
> **Cause 3 : Conflit VLAN**
> 
> - Certains FAI requièrent un VLAN tag (ex: 100 pour Swisscom, 835 pour Orange FR)
> 
> ```plaintext
> Interfaces > Assignments > VLANs > Add
> Parent Interface: <interface_physique>
> VLAN Tag: 835 (exemple Orange)
> 
> Puis assigner ce VLAN comme interface WAN
> ```

---

### Problèmes DNS

Les problèmes DNS se manifestent par l'impossibilité de résoudre les noms de domaine.

#### Diagnostic DNS

```bash
# Test depuis pfSense
Diagnostics > DNS Lookup
Hostname: google.com
DNS Server: (laisser par défaut ou tester 8.8.8.8)

# Si échec : problème de résolution DNS
# Si succès : problème côté clients
```

#### Configuration DNS sur WAN

> [!info] Sources DNS possibles
> 
> **Option 1 : DNS du FAI (automatique)**
> 
> ```plaintext
> Interfaces > WAN
> ☐ Override DNS (décoché)
> 
> → pfSense utilise les DNS fournis par DHCP/PPPoE
> ```
> 
> **Option 2 : DNS publics manuels**
> 
> ```plaintext
> System > General Setup
> DNS Servers:
> - 1.1.1.1 (Cloudflare)
> - 8.8.8.8 (Google)
> - 9.9.9.9 (Quad9)
> 
> ☑ DNS Server Override
> ```

#### Problèmes de résolution

> [!warning] DNS ne résout pas
> 
> **Vérification 1 : Connectivité aux serveurs DNS**
> 
> ```bash
> # Test ping des serveurs DNS
> Diagnostics > Ping
> Host: 8.8.8.8
> 
> # Si ping échoue : problème de routage/connectivité
> ```
> 
> **Vérification 2 : Service DNS Resolver/Forwarder**
> 
> ```bash
> Status > Services
> 
> # Vérifier que le service est actif :
> - DNS Resolver (unbound) ou
> - DNS Forwarder (dnsmasq)
> 
> # Redémarrer si nécessaire
> ```
> 
> **Vérification 3 : Règles de pare-feu**
> 
> ```plaintext
> Le trafic DNS (port 53 UDP/TCP) doit être autorisé sur WAN
> 
> Firewall > Rules > WAN
> Vérifier qu'aucune règle ne bloque le port 53 sortant
> ```

> [!tip] DNS Resolver vs DNS Forwarder
> 
> - **DNS Resolver** (Unbound) : Résolution récursive, plus moderne, recommandé
> - **DNS Forwarder** (dnsmasq) : Transfert vers d'autres DNS, plus simple
> 
> N'activez qu'un seul service à la fois !

---

### Problèmes de passerelle

La passerelle (gateway) est le point de sortie vers Internet.

#### Vérification de l'état

```plaintext
Status > Gateways

Indicateurs de santé :
┌─────────────────────────────────────────┐
│ Gateway Name: WAN_DHCP                  │
│ Status: ✓ Online                        │
│ RTT: 15ms (normal : < 50ms)            │
│ Loss: 0% (normal : < 5%)               │
│ Delay: 2ms (normal : < 30ms)           │
└─────────────────────────────────────────┘

Status problématique :
✗ Offline : Passerelle inaccessible
⚠ Delay : Latence élevée
⚠ Packet Loss : Perte de paquets
```

#### Gateway monitoring

> [!example] Configuration du monitoring
> 
> **Paramètres de surveillance** (`System > Routing > Gateways > Edit`)
> 
> ```plaintext
> ☑ Disable Gateway Monitoring (normalement décoché)
> 
> Monitor IP: 8.8.8.8
>   → IP stable pour tester la connectivité
>   → Par défaut : passerelle WAN du FAI
> 
> Alert Interval: 1 second (délai entre pings)
> Probe Interval: 500ms (fréquence des tests)
> Loss Interval: 5 (nombre d'échecs avant alerte)
> 
> Thresholds:
> - Latency Low: 200ms
> - Latency High: 500ms
> - Loss Low: 10%
> - Loss High: 20%
> ```

> [!warning] Faux positifs Certaines passerelles FAI bloquent les pings ICMP. Symptômes :
> 
> - Gateway marquée "Offline" mais connexion fonctionnelle
> - Perte de paquets à 100% dans les stats
> 
> **Solution** : Désactiver le monitoring ou utiliser un Monitor IP alternatif (8.8.8.8)

#### Passerelles multiples

```plaintext
En cas de multi-WAN, vérifier :

System > Routing > Gateway Groups
┌────────────────────────────────────────┐
│ Tier 1: WAN_DHCP (Primary)            │
│ Tier 2: WAN2_DHCP (Backup)            │
│                                        │
│ Trigger Level: Packet Loss or High    │
│               Latency                  │
└────────────────────────────────────────┘

Diagnostic :
- Vérifier que chaque gateway est "Online"
- Tester le basculement (failover)
- Vérifier les règles de pare-feu utilisant le bon gateway group
```

---

## Règles de pare-feu inefficaces

### Comprendre l'ordre des règles

> [!info] Principe fondamental pfSense traite les règles **de haut en bas** et s'arrête à la **première correspondance**. L'ordre des règles est donc critique.

#### Logique de traitement

```plaintext
Flux de traitement d'un paquet :
┌─────────────────────────────────────────────────┐
│ 1. Paquet arrive sur une interface              │
│    ↓                                            │
│ 2. Parcours des règles de haut en bas          │
│    ↓                                            │
│ 3. Première règle qui correspond ?             │
│    ↓                                            │
│ 4. Action appliquée (Pass/Block/Reject)        │
│    ↓                                            │
│ 5. Arrêt du traitement                         │
│    (les règles suivantes ne sont PAS testées)  │
└─────────────────────────────────────────────────┘
```

> [!warning] Erreur classique : Règle trop large en premier
> 
> ```plaintext
> ✗ MAUVAIS ordre :
> 1. Pass  any → any        (autorise tout)
> 2. Block LAN → 192.168.2.0/24  (jamais atteinte !)
> 
> ✓ BON ordre :
> 1. Block LAN → 192.168.2.0/24  (bloque d'abord)
> 2. Pass  LAN → any              (autorise le reste)
> ```

#### Règles implicites

> [!info] Règles par défaut invisibles pfSense applique automatiquement ces règles (non visibles dans l'interface) :
> 
> **Sur toutes les interfaces** :
> 
> - **Anti-lockout** (WAN uniquement si configuré) : Accès WebGUI/SSH
> - **Pass all** sur interface **LAN** (par défaut à l'installation)
> - **Block all** sur interfaces **WAN, OPT** (par défaut)
> 
> **En fin de liste** :
> 
> - **Block all** implicite si aucune règle ne correspond
> 
> Vous ne voyez que vos règles personnalisées, pas ces règles système.

---

### Règles qui ne s'appliquent pas

Plusieurs raisons peuvent expliquer qu'une règle ne fonctionne pas.

#### Checklist de vérification

> [!example] Diagnostic étape par étape
> 
> **1. La règle est-elle active ?**
> 
> - Icône ✓ verte visible
> - Pas d'icône ⚠ de désactivation
> 
> **2. Sur la bonne interface ?**
> 
> ```plaintext
> Interface source = interface où le trafic ENTRE
> 
> Exemple : PC LAN → Internet
> → Règle sur interface LAN (pas WAN !)
> 
> Exemple : Internet → Serveur DMZ
> → Règle sur interface WAN
> ```
> 
> **3. Direction correcte ?**
> 
> - **Source** : D'où vient le paquet
> - **Destination** : Où va le paquet
> 
> ```plaintext
> Client 192.168.1.10 → Serveur web 80.80.80.80
> Source: 192.168.1.10 (ou LAN net)
> Destination: 80.80.80.80 (ou any)
> ```
> 
> **4. Protocole et ports corrects ?**
> 
> ```plaintext
> HTTP  = TCP port 80
> HTTPS = TCP port 443
> DNS   = UDP port 53 (+ TCP pour transferts)
> SSH   = TCP port 22
> 
> Ne pas confondre :
> - Source port (port du client, généralement aléatoire)
> - Destination port (port du service, ex: 80, 443)
> ```

#### Cas courants d'échec

|Problème|Explication|Solution|
|---|---|---|
|Règle trop basse|Une règle précédente bloque/autorise déjà|Réorganiser l'ordre|
|Mauvaise interface|Règle sur WAN au lieu de LAN|Déplacer vers la bonne interface|
|Alias obsolète|Alias non mis à jour|Vérifier le contenu de l'alias|
|NAT manquant|Accès externe sans NAT/Port Forward|Configurer NAT Outbound ou Port Forward|
|États résiduels|Anciennes connexions en mémoire|Vider la table d'états|

#### Test de règles

> [!tip] Méthode de test
> 
> **Approche 1 : Règle de log temporaire**
> 
> ```plaintext
> Créer une règle avant la règle problématique :
> 
> Action: Pass
> Interface: LAN
> Source: any
> Destination: any
> ☑ Log packets that are handled by this rule
> Description: TEST - À supprimer
> 
> → Vérifier dans Status > System Logs > Firewall
> → Si vous voyez le trafic logué, la règle est atteinte
> ```
> 
> **Approche 2 : Règle "Block & Log all" temporaire**
> 
> ```plaintext
> En dernière position sur l'interface :
> 
> Action: Block
> Source: any
> Destination: any
> ☑ Log packets
> 
> → Tout trafic non autorisé sera logué
> → Identifier ce qui est bloqué à tort
> ```

---

### Analyse des logs de pare-feu

Les logs de pare-feu sont essentiels pour comprendre ce qui est bloqué.

#### Accès aux logs

```plaintext
Status > System Logs > Firewall

Colonnes importantes :
┌──────────────────────────────────────────────────┐
│ Act | Time | IF | Proto | Src | Dst | Info     │
├──────────────────────────────────────────────────┤
│  🔴 | 10:23| LAN| TCP   | 192.168.1.10:54321    │
│     |      |    |       | → 8.8.8.8:443         │
│     |      |    |       | Block Default deny    │
└──────────────────────────────────────────────────┘

Icônes :
🔴 Block (bloqué)
✅ Pass (autorisé) - si logging activé
❌ Reject (rejeté avec RST/ICMP)
```

#### Interpréter les entrées

> [!example] Exemples de logs
> 
> **Log 1 : Blocage sortant**
> 
> ```plaintext
> Block | LAN | 192.168.1.50:56789 → 93.184.216.34:80 | Default deny rule
> 
> Interprétation :
> - PC 192.168.1.50 essaie d'accéder au web (port 80)
> - Bloqué par la règle par défaut (aucune règle Pass ne correspond)
> - Action : Créer une règle Pass LAN → any sur port 80
> ```
> 
> **Log 2 : Blocage entrant WAN**
> 
> ```plaintext
> Block | WAN | 104.28.5.6:12345 → <WAN_IP>:22 | Default deny rule
> 
> Interprétation :
> - Tentative de connexion SSH depuis Internet
> - Normal : par défaut WAN bloque tout entrant
> - Si légitime : Créer un Port Forward
> - Si scan/attaque : Normal, ignorer
> ```
> 
> **Log 3 : Trafic autorisé (avec log activé)**
> 
> ```plaintext
> Pass | LAN | 192.168.1.20:45678 → 1.1.1.1:53 | User rule: Allow DNS
> 
> Interprétation :
> - Requête DNS autorisée par une règle explicite
> - Le logging était activé sur cette règle
> ```

#### Filtrage des logs

> [!tip] Astuces de filtrage
> 
> **Filtrer par IP source** :
> 
> ```plaintext
> Chercher : 192.168.1.50
> → Voir tout le trafic d'un PC spécifique
> ```
> 
> **Filtrer par port** :
> 
> ```plaintext
> Chercher : :443
> → Voir tout le trafic HTTPS
> ```
> 
> **Filtrer par action** :
> 
> ```plaintext
> Afficher uniquement : ✓ Deny ✓ Reject
> → Ne voir que le trafic bloqué
> ```
> 
> **Filtrer par interface** :
> 
> ```plaintext
> Interface : WAN
> → Voir uniquement les tentatives depuis Internet
> ```

---

### États de connexion problématiques

pfSense maintient une table d'états pour le suivi des connexions.

#### Comprendre les états

```bash
# Voir la table d'états
Diagnostics > States

Informations affichées :
┌──────────────────────────────────────────────────┐
│ Interface | Proto | Source:port → Dest:port     │
│ State     | Packets/Bytes                       │
├──────────────────────────────────────────────────┤
│ LAN       | TCP   | 192.168.1.10:54321          │
│           |       | → 93.184.216.34:443         │
│ ESTABLISHED | 150/75000                         │
└──────────────────────────────────────────────────┘

États possibles :
- ESTABLISHED : Connexion active
- TIME_WAIT : Connexion en fermeture
- FIN_WAIT : Attente de fermeture
- CLOSED : Connexion fermée (devrait disparaître)
```

#### Problèmes courants

> [!warning] États bloquants
> 
> **Symptôme 1 : Connexion qui "reste coincée"**
> 
> ```plaintext
> Cause : État résiduel d'une ancienne connexion
> 
> Exemple :
> - Serveur web redémarré
> - pfSense garde l'ancienne connexion en mémoire
> - Nouvelles connexions refusées
> 
> Solution : Vider les états de cette connexion
> Diagnostics > States > Kill States
> Filtrer par IP ou port, puis "Kill" ou "Kill All States"
> ```
> 
> **Symptôme 2 : Nouvelle règle ne fonctionne pas**
> 
> ```plaintext
> Cause : Connexions existantes utilisent les anciennes règles
> 
> Les règles pfSense s'appliquent à la CRÉATION de l'état.
> Une connexion établie garde ses paramètres même si vous changez les règles.
> 
> Solution :
> 1. Modifier la règle
> 2. Vider les états concernés (ou tous)
> 3. Retester
> ```

#### Gestion de la table d'états

> [!example] Opérations sur les états
> 
> **Vider tous les états** (attention : coupe toutes les connexions actives)
> 
> ```plaintext
> Diagnostics > States
> ☑ Kill all states
> Confirm
> 
> ⚠ Impact : Toutes les connexions actives seront réinitialisées
> Utilisez avec précaution en production
> ```
> 
> **Vider sélectivement**
> 
> ```plaintext
> Filtrer par :
> - Interface : LAN, WAN, DMZ...
> - Protocol : TCP, UDP, ICMP...
> - Address : 192.168.1.50
> - Port : 443
> 
> Puis : "Kill States" pour les résultats filtrés
> ```
> 
> **Ajuster les limites**
> 
> ```plaintext
> System > Advanced > Firewall & NAT
> 
> Firewall Maximum States:
> - Par défaut : 10% de la RAM
> - Augmenter si "State Table Full" dans les logs
> 
> Firewall Maximum Table Entries:
> - Limite des entrées de table (aliases, etc.)
> ```

> [!tip] États et NAT Les états incluent les traductions NAT. Si vous modifiez une règle NAT, pensez à vider les états correspondants pour que la nouvelle configuration s'applique immédiatement.

---

## Problèmes de performance

### Utilisation CPU élevée

Une utilisation CPU excessive ralentit pfSense et peut indiquer un problème.

#### Diagnostic CPU

```bash
# Vérifier l'utilisation CPU
Status > System

CPU usage:
┌────────────────────────────────────┐
│ Processor: Intel Xeon E5-2680     │
│ Load average: 0.15, 0.12, 0.10    │
│ CPU usage: 25%                     │
└────────────────────────────────────┘

Interprétation :
- < 30% : Normal
- 30-70% : Surveiller
- > 70% constant : Problème

Load average (1min, 5min, 15min) :
- < 1.0 : Peu de charge
- 1.0-2.0 : Charge modérée
- > 2.0 : Surcharge
```

#### Identifier le processus responsable

```bash
# Via shell
Diagnostics > Command Prompt > Execute Shell Command

top -a -S
# Affiche les processus triés par CPU

ps aux | sort -rk 3 | head -10
# Top 10 des processus par CPU
```

#### Causes courantes

> [!example] Sources de charge CPU
> 
> **1. Logging excessif**
> 
> ```plaintext
> Symptôme : Écriture logs constante
> 
> Vérification :
> Status > System Logs > Settings
> 
> Solutions :
> - Réduire le nombre de règles avec logging activé
> - Augmenter "Show log entries": 50 au lieu de 500
> - Désactiver le logging sur règles à fort trafic
> ```
> 
> **2. Snort/Suricata (IDS/IPS)**
> 
> ```plaintext
> Symptôme : CPU élevé avec package IDS/IPS installé
> 
> Vérification :
> Status > Services > Snort/Suricata CPU usage
> 
> Solutions :
> - Réduire le nombre d'interfaces surveillées
> - Désactiver les règles non essentielles
> - Limiter l'inspection profonde de paquets
> - Augmenter les ressources matérielles
> ```
> 
> **3. Trafic réseau intense**
> 
> ```plaintext
> Symptôme : Pics CPU pendant transferts massifs
> 
> Causes :
> - Inspection de paquets (pfSense traite chaque paquet)
> - NAT/Port forwarding complexe
> - Shaping/QoS actif
> 
> Solutions :
> - Désactiver temporairement le shaping pour tester
> - Vérifier si hardware offloading est disponible
> - Upgrader le matériel (CPU plus puissant)
> ```
> 
> **4. Processus système défaillant**
> 
> ```plaintext
> Processus problématiques courants :
> - php-fpm : WebGUI (peut saturer si attaque)
> - unbound : DNS Resolver (cache surchargé)
> - dhcpleases : Bail DHCP (rare)
> 
> Solution temporaire :
> Diagnostics > Reboot > Reboot (redémarre les services)
> ```

#### Optimisations CPU

> [!tip] Réduire la charge CPU
> 
> **1. Hardware offloading** (si supporté par la carte réseau)
> 
> ```plaintext
> System > Advanced > Networking
> 
> ☑ Disable hardware checksum offload (décocher pour activer)
> ☑ Disable hardware TCP segmentation offload (décocher)
> ☑ Disable hardware large receive offload (décocher)
> 
> ⚠ Attention : Tester avant/après
> Certaines cartes ont des bugs, l'offloading peut dégrader les performances
> ```
> 
> **2. Réduire les features gourmandes**
> 
> ```plaintext
> - Limiter le nombre de packages installés
> - Désactiver Snort/Suricata si non critique
> - Simplifier les règles de pare-feu
> - Réduire la fréquence des logs
> ```
> 
> **3. Tuning kernel**
> 
> ```plaintext
> System > Advanced > System Tunables
> 
> Optimisations courantes :
> - net.inet.ip.fw.one_pass: 0 (traitement complet)
> - kern.ipc.maxsockbuf: augmenter pour gros trafic
> ```

---

### Saturation mémoire

La mémoire insuffisante peut causer des crashs et des ralentissements.

#### Diagnostic mémoire

```bash
# Vérifier l'utilisation mémoire
Status > System

Memory usage:
┌────────────────────────────────────┐
│ Physical: 4096 MB                  │
│ Used: 2048 MB (50%)                │
│ Free: 2048 MB (50%)                │
└────────────────────────────────────┘

Seuils critiques :
- < 70% : Normal
- 70-85% : Surveiller
- > 85% : Critique (risque de swap/crash)
```

#### Identifier les consommateurs

```bash
# Via shell
top -a -m io
# Affiche les processus triés par mémoire

# Vérifier les processus spécifiques
ps aux | grep -E "unbound|snort|suricata|squid"
```

#### Causes de saturation

> [!warning] Consommateurs de mémoire
> 
> **1. Cache DNS (Unbound)**
> 
> ```plaintext
> Services > DNS Resolver > Advanced Settings
> 
> Message Cache Size: 4 MB (par défaut)
> → Augmenter améliore les perfs mais consomme RAM
> → Limiter à 10-20 MB sur systèmes avec peu de RAM
> 
> RRset Cache Size: 4 MB
> → Idem, ajuster selon RAM disponible
> ```
> 
> **2. Table d'états surdimensionnée**
> 
> ```plaintext
> System > Advanced > Firewall & NAT
> 
> Firewall Maximum States: 
> Par défaut : 10% de la RAM
> 
> Si RAM limitée :
> - Réduire à une valeur fixe (ex: 50000)
> - Surveiller dans Status > System (State table size)
> ```
> 
> **3. Proxy/Cache Squid**
> 
> ```plaintext
> Services > Squid Proxy Server
> 
> Cache Size: 100 MB (par défaut)
> → Très gourmand si cache volumineux (plusieurs GB)
> → Réduire ou désactiver le cache disque
> ```
> 
> **4. Logs trop volumineux**
> 
> ```plaintext
> Status > System Logs > Settings
> 
> Log File Size: 
> - Réduire de 512KB à 100KB par fichier
> - Activer la rotation plus fréquente
> - Envoyer les logs vers syslog externe
> ```

#### Optimisations mémoire

> [!tip] Libérer de la mémoire
> 
> **Actions immédiates**
> 
> ```bash
> # Vider les caches
> Services > DNS Resolver > General Settings
> "Save" (recharge le service et vide le cache)
> 
> # Vider la table d'états
> Diagnostics > States > Kill All States
> 
> # Redémarrer les services gourmands
> Status > Services > Restart
> ```
> 
> **Configuration durable**
> 
> ```plaintext
> 1. Désinstaller les packages non utilisés
>    System > Package Manager > Installed Packages
> 
> 2. Réduire les caches
>    - DNS Resolver cache
>    - Squid cache
>    - Autres caches de packages
> 
> 3. Limiter la table d'états
>    System > Advanced > Firewall & NAT
>    Firewall Maximum States: valeur raisonnable
> 
> 4. Externaliser les logs
>    Status > System Logs > Settings
>    ☑ Enable Remote Logging
>    Remote log servers: <IP_serveur_syslog>
> ```

---

### Débit réseau limité

Le débit inférieur aux attentes peut avoir plusieurs causes.

#### Mesurer le débit

> [!example] Tests de débit
> 
> **Via l'interface pfSense**
> 
> ```plaintext
> Diagnostics > Test Port
> 
> Test client vers serveur :
> - Host: speedtest.net
> - Port: 80
> - Type: HTTP
> 
> Résultat : Temps de réponse et débit estimé
> ```
> 
> **Via un client derrière pfSense**
> 
> ```bash
> # Utiliser iperf3 (plus précis)
> 
> # Sur un serveur externe (ou second PC) :
> iperf3 -s
> 
> # Sur le client :
> iperf3 -c <IP_serveur>
> 
> # Test upload :
> iperf3 -c <IP_serveur> -R
> ```
> 
> **Speedtest web**
> 
> ```plaintext
> Depuis un PC derrière pfSense :
> - fast.com (Netflix)
> - speedtest.net
> 
> Comparer avec débit théorique de la ligne
> ```

#### Goulots d'étranglement

> [!warning] Causes de limitation
> 
> **1. Configuration interface réseau**
> 
> ```bash
> # Vérifier la négociation de vitesse
> Status > Interfaces
> 
> Vérifier :
> Media: autoselect (1000baseT full-duplex)
> 
> ✓ Bon : 1000baseT (Gigabit)
> ✗ Problème : 100baseTX (Fast Ethernet)
> ✗ Problème : half-duplex (devrait être full-duplex)
> ```
> 
> **Solution : Forcer la vitesse**
> 
> ```plaintext
> Interfaces > LAN (ou WAN) > Speed and Duplex
> 
> Changer de "autoselect" vers :
> - 1000baseT full-duplex (Gigabit)
> - 100baseTX full-duplex (si câble/switch limité)
> 
> ⚠ Ne jamais forcer half-duplex sauf cas très spécifique
> ```

**2. Hardware offloading désactivé**

```plaintext
System > Advanced > Networking

Si ces options sont COCHÉES, l'offloading est DÉSACTIVÉ :
☑ Disable hardware checksum offload
☑ Disable hardware TCP segmentation offload
☑ Disable hardware large receive offload

Test :
1. Décocher ces options (active l'offloading)
2. Tester le débit
3. Si instable, recocher
```

**3. Traffic Shaper / QoS actif**

```plaintext
Firewall > Traffic Shaper

Si configuré, le shaping limite volontairement le débit.

Vérification :
- Désactiver temporairement pour tester
- Vérifier les limites configurées (upload/download)
- Ajuster les priorités si nécessaire
```

**4. CPU saturé**

```plaintext
pfSense traite chaque paquet par le CPU.

Si CPU > 80% pendant transferts :
- Le CPU est le goulot d'étranglement
- Solutions : CPU plus puissant, réduire inspection
```

**5. MTU incorrect**

```plaintext
MTU (Maximum Transmission Unit) trop bas = fragmentation

Vérification :
Interfaces > WAN > MTU
- Standard : 1500
- PPPoE : 1492
- VLAN : 1496

Test :
ping -f -l 1472 8.8.8.8  (Windows)
ping -D -s 1472 8.8.8.8  (Linux)

Si échec : MTU trop haut, réduire
```

#### Optimisations débit

> [!tip] Maximiser les performances
> 
> **1. Tuning réseau**
> 
> ```plaintext
> System > Advanced > System Tunables
> 
> Optimisations pour gros débit :
> 
> net.inet.tcp.sendbuf_max: 2097152
> net.inet.tcp.recvbuf_max: 2097152
> → Augmente les buffers TCP
> 
> net.inet.tcp.sendspace: 65536
> net.inet.tcp.recvspace: 65536
> → Taille des fenêtres TCP
> 
> kern.ipc.maxsockbuf: 4194304
> → Buffer maximum pour sockets
> ```
> 
> **2. Désactiver features non nécessaires**
> 
> ```plaintext
> - Traffic Shaper (si non utilisé)
> - Packages d'inspection (Snort/Suricata)
> - Proxy Squid (utiliser DNS uniquement)
> - Limiters (si non nécessaires)
> ```
> 
> **3. Multi-queue network**
> 
> ```plaintext
> Pour cartes réseau modernes multi-queues :
> 
> System > Advanced > Networking
> Device Polling: Disable (laisser désactivé)
> → Les cartes modernes gèrent mieux sans polling
> ```

---

### Table d'états saturée

La table d'états pleine empêche de nouvelles connexions.

#### Symptôme

```bash
# Log système
Status > System Logs > System

Erreur typique :
"pf: state table full"
"pf_state_insert: over limits"
```

#### Vérifier l'utilisation

```bash
# Voir l'état actuel
Status > System

State Table:
┌────────────────────────────────────┐
│ Current: 45000 / 50000 (90%)       │
│ Search rate: 1500/s                │
│ Insert rate: 500/s                 │
└────────────────────────────────────┘

Seuils :
- < 70% : Normal
- 70-90% : Surveiller
- > 90% : Critique
```

#### Causes

> [!warning] Pourquoi la table sature
> 
> **1. Trafic P2P / BitTorrent**
> 
> ```plaintext
> Crée des milliers de connexions simultanées
> 
> Solution :
> - Limiter le nombre de connexions par IP
> - Utiliser des règles de limitation
> - Bloquer P2P si non autorisé
> ```
> 
> **2. Attaque DDoS / SYN flood**
> 
> ```plaintext
> Tentatives de connexion massives depuis Internet
> 
> Vérification :
> Diagnostics > States
> Filtrer par interface WAN
> 
> Si milliers de connexions SYN_SENT : probable attaque
> 
> Solution :
> - Activer SYN cookies
> - Configurer rate limiting
> - Bloquer les IPs sources
> ```
> 
> **3. Limite trop basse**
> 
> ```plaintext
> Réseau avec beaucoup d'utilisateurs légitimes
> 
> Solution : Augmenter la limite
> ```

#### Augmenter la limite

> [!example] Ajuster la taille de la table
> 
> ```plaintext
> System > Advanced > Firewall & NAT
> 
> Firewall Maximum States:
> ┌────────────────────────────────────────┐
> │ Default (10% RAM): 50000               │
> │                                        │
> │ Pour augmenter :                       │
> │ - Entrer une valeur fixe : 100000      │
> │ - Ou augmenter % : 20% de RAM          │
> │                                        │
> │ ⚠ Impact : Consommation RAM accrue     │
> └────────────────────────────────────────┘
> 
> Calcul approximatif :
> - 1 état ≈ 1 KB en RAM
> - 100000 états ≈ 100 MB RAM
> ```

#### Nettoyage et protection

> [!tip] Gérer les états
> 
> **Nettoyage manuel**
> 
> ```plaintext
> Diagnostics > States
> 
> Options :
> 1. Kill All States : Vide tout (attention !)
> 2. Filtrer puis Kill : Plus sélectif
>    - Par IP source (attaquant)
>    - Par protocole
>    - Par interface
> ```
> 
> **Timeouts adaptatifs**
> 
> ```plaintext
> System > Advanced > Firewall & NAT
> 
> Firewall Adaptive Timeouts:
> ☑ Adaptive Start: 60% (commence à réduire les timeouts)
> ☑ Adaptive End: 120% (timeouts au minimum)
> 
> → Réduit automatiquement la durée de vie des états
>    quand la table approche de la saturation
> ```
> 
> **Timeouts personnalisés**
> 
> ```plaintext
> System > Advanced > Firewall & NAT > Firewall Advanced
> 
> Timeouts (en secondes) :
> - TCP First Packet: 60 (première SYN)
> - TCP Opening: 30 (handshake)
> - TCP Established: 86400 (24h par défaut, réduire à 3600)
> - TCP Closing: 900
> - TCP FIN Wait: 45
> - TCP Closed: 90
> - UDP First: 60
> - UDP Single: 30
> - UDP Multiple: 60
> 
> Réduire "TCP Established" libère les états plus vite
> ⚠ Trop court = connexions longues coupées
> ```

---

## Méthodologie de diagnostic

### Approche systématique

> [!info] Méthodologie en 7 étapes
> 
> **Étape 1 : Définir le problème**
> 
> - Quoi ? (Symptôme exact)
> - Quand ? (Depuis quand, fréquence)
> - Qui ? (Utilisateurs, services, IP affectés)
> - Où ? (Interface, réseau, segment)
> 
> **Étape 2 : Collecter les informations**
> 
> - Consulter les logs (System, Firewall, Services)
> - Vérifier le Dashboard (Status > Dashboard)
> - Noter les erreurs et messages inhabituels
> 
> **Étape 3 : Isoler la couche réseau**
> 
> ```plaintext
> Modèle OSI simplifié :
> 
> 7. Application  → Service web, DNS ne répond pas
> 8. Présentation
> 9. Session
> 10. Transport    → Problème TCP/UDP, ports
> 11. Réseau       → Problème IP, routage, passerelle
> 12. Liaison      → Problème Ethernet, VLAN, switch
> 13. Physique     → Câble débranché, carte HS
> 
> Tester de bas en haut (1→7)
> ```
> 
> **Étape 4 : Tester par élimination**
> 
> - Simplifier la configuration (désactiver temporairement)
> - Tester avec règle "allow all" temporaire
> - Isoler le composant défaillant
> 
> **Étape 5 : Vérifier les changements récents**
> 
> - Qu'est-ce qui a changé récemment ?
> - Nouvelle règle, package, mise à jour ?
> - Restaurer la configuration précédente pour tester
> 
> **Étape 6 : Appliquer la solution**
> 
> - Corriger le problème identifié
> - Tester la résolution
> - Documenter la solution
> 
> **Étape 7 : Prévenir la récurrence**
> 
> - Mettre en place monitoring
> - Créer alerte si nécessaire
> - Documenter dans les procédures

### Modèle de diagnostic en couches

```plaintext
Diagnostic systématique réseau :

┌─────────────────────────────────────────────────┐
│ Couche 1 - Physique                             │
│ ☐ Câble branché ?                               │
│ ☐ LED link active ?                             │
│ ☐ Bonne vitesse négociée ? (Status>Interfaces) │
├─────────────────────────────────────────────────┤
│ Couche 2 - Liaison                              │
│ ☐ Interface "up" ?                              │
│ ☐ VLAN correctement configuré ?                 │
│ ☐ Pas d'erreur CRC/collisions ?                 │
├─────────────────────────────────────────────────┤
│ Couche 3 - Réseau                               │
│ ☐ IP attribuée ?                                │
│ ☐ Masque de sous-réseau correct ?               │
│ ☐ Passerelle définie et joignable ?             │
│ ☐ Route par défaut présente ?                   │
├─────────────────────────────────────────────────┤
│ Couche 4 - Transport                            │
│ ☐ Port correct (TCP/UDP) ?                      │
│ ☐ Service écoute sur le port ?                  │
│ ☐ Pare-feu autorise le port ?                   │
├─────────────────────────────────────────────────┤
│ Couche 7 - Application                          │
│ ☐ Service démarré ?                             │
│ ☐ Configuration service correcte ?              │
│ ☐ DNS résout le nom ?                           │
└─────────────────────────────────────────────────┘

Commencer toujours par le bas (couche 1)
```

---

### Outils de diagnostic intégrés

pfSense inclut de nombreux outils de diagnostic dans l'interface web.

#### Diagnostics > Ping

> [!example] Test de connectivité ICMP
> 
> ```plaintext
> Utilisation :
> - Host: <IP ou nom de domaine>
> - IP Protocol: IPv4 (ou IPv6)
> - Source Address: (interface source)
> - Count: 3-5 paquets
> 
> Interprétation :
> ✓ 0% packet loss, RTT < 50ms : Excellent
> ⚠ 1-10% loss : Léger problème réseau
> ✗ 100% loss : Pas de connectivité
> ⚠ RTT > 200ms : Latence élevée
> ```

#### Diagnostics > Traceroute

> [!example] Tracer le chemin réseau
> 
> ```plaintext
> Utilisation :
> - Host: destination (IP ou nom)
> - Maximum hops: 18-30
> 
> Exemple de sortie :
> 1  192.168.1.1      1.2ms   (pfSense)
> 2  10.0.0.1         5.3ms   (routeur FAI)
> 3  172.16.1.1       12.5ms  (backbone FAI)
> 4  8.8.8.8          15.2ms  (destination)
> 
> Problèmes :
> - * * * : Timeout, routeur ne répond pas (normal)
> - !H : Host unreachable (problème de routage)
> - Latence qui augmente brusquement : goulot
> ```

#### Diagnostics > DNS Lookup

> [!example] Test de résolution DNS
> 
> ```plaintext
> Utilisation :
> - Hostname: www.google.com
> - DNS Server: (vide = serveurs configurés)
>              ou 8.8.8.8 pour tester externe
> 
> Résultat attendu :
> www.google.com has address 142.250.185.100
> 
> Erreurs :
> - "Server failure" : DNS ne répond pas
> - "NXDOMAIN" : Domaine inexistant
> - Timeout : Problème de connectivité au DNS
> ```

#### Diagnostics > States

> [!example] Inspection de la table d'états
> 
> ```plaintext
> Fonctionnalités :
> - Voir toutes les connexions actives
> - Filtrer par IP, port, protocole, interface
> - Tuer des états spécifiques ou tous
> 
> Cas d'usage :
> - Identifier les connexions gourmandes
> - Voir qui consomme de la bande passante
> - Nettoyer les états bloqués
> - Diagnostiquer les problèmes de connexion
> ```

#### Diagnostics > Packet Capture

> [!tip] Capture de paquets (tcpdump intégré)
> 
> ```plaintext
> Configuration :
> - Interface: WAN, LAN, etc.
> - Address Family: IPv4 / IPv6
> - Protocol: TCP, UDP, ICMP, any
> - Host Address: filtrer par IP
> - Port: filtrer par port
> 
> Options :
> - Packet Length: 0 (capture complète)
> - Count: 100-500 paquets
> - Level of Detail: Full (recommandé)
> 
> Résultat : fichier .pcap
> → Télécharger et analyser avec Wireshark
> ```

> [!warning] Capture de trafic La capture peut être volumineuse et ralentir pfSense.
> 
> - Utiliser des filtres précis
> - Limiter le nombre de paquets
> - Ne pas capturer en production prolongée

#### Diagnostics > Test Port

> [!example] Test de connectivité TCP
> 
> ```plaintext
> Utilisation :
> - Host: serveur distant
> - Port: port à tester (80, 443, 22, etc.)
> - Type: Simple (connexion TCP)
>         HTTP (requête GET HTTP)
> 
> Résultat :
> ✓ "Connected successfully" : Port ouvert
> ✗ "Connection refused" : Port fermé
> ✗ "Connection timeout" : Filtré/firewall
> 
> Cas d'usage :
> - Vérifier qu'un serveur web répond (port 80/443)
> - Tester un port forward
> - Diagnostiquer un blocage firewall
> ```

#### Diagnostics > Routes

> [!example] Voir la table de routage
> 
> ```plaintext
> Affiche :
> - Routes statiques configurées
> - Routes dynamiques (OSPF, BGP si configuré)
> - Route par défaut (default gateway)
> 
> Colonnes importantes :
> - Destination: Réseau destination
> - Gateway: Next hop (prochain routeur)
> - Flags: U (Up), G (Gateway), S (Static)
> - Interface: Interface de sortie
> ```

---

### Commandes shell utiles

Accès shell : `Diagnostics > Command Prompt`

#### Commandes réseau

> [!example] Commandes de diagnostic
> 
> **Voir les interfaces réseau**
> 
> ```bash
> ifconfig
> # Affiche toutes les interfaces, IP, statut
> 
> ifconfig em0
> # Détails d'une interface spécifique
> ```
> 
> **Table de routage**
> 
> ```bash
> netstat -rn
> # -r : routing table
> # -n : format numérique (pas de résolution DNS)
> ```
> 
> **Connexions actives**
> 
> ```bash
> netstat -an
> # -a : all
> # -n : numérique
> 
> netstat -an | grep ESTABLISHED
> # Voir uniquement les connexions établies
> 
> netstat -an | grep :443
> # Connexions sur port 443
> ```
> 
> **État des interfaces**
> 
> ```bash
> pfctl -si
> # Statistiques des interfaces pfSense
> 
> pfctl -ss
> # Voir les états de connexion (comme Diagnostics>States)
> ```
> 
> **DNS et résolution**
> 
> ```bash
> nslookup www.google.com
> # Test DNS simple
> 
> host www.google.com
> # Alternative à nslookup
> 
> dig www.google.com
> # Requête DNS détaillée
> ```

#### Commandes système

> [!example] Diagnostic système
> 
> **Processus et performance**
> 
> ```bash
> top
> # Vue en temps réel des processus
> # Appuyer 'q' pour quitter
> 
> ps aux
> # Liste complète des processus
> 
> ps aux | grep unbound
> # Chercher un processus spécifique
> ```
> 
> **Espace disque**
> 
> ```bash
> df -h
> # Utilisation des disques (-h : human readable)
> 
> du -sh /var/log
> # Taille d'un dossier spécifique
> ```
> 
> **Logs en temps réel**
> 
> ```bash
> tail -f /var/log/system.log
> # Suivre le log système en temps réel
> # Ctrl+C pour arrêter
> 
> tail -100 /var/log/filter.log
> # Dernières 100 lignes du log firewall
> 
> grep "dhclient" /var/log/system.log
> # Chercher dans les logs
> ```

#### Commandes pfSense spécifiques

> [!tip] Commandes utiles pfSense
> 
> **Redémarrer des services**
> 
> ```bash
> /usr/local/etc/rc.d/unbound restart
> # Redémarrer DNS Resolver
> 
> /usr/local/etc/rc.d/dhcpd restart
> # Redémarrer serveur DHCP
> 
> pfctl -f /tmp/rules.debug
> # Recharger les règles de pare-feu
> ```
> 
> **Informations système**
> 
> ```bash
> pciconf -lv
> # Lister les périphériques PCI (cartes réseau, etc.)
> 
> dmesg | grep em0
> # Messages noyau pour une interface
> 
> sysctl -a | grep net.inet
> # Voir les tunables réseau actifs
> ```
> 
> **Test de performance**
> 
> ```bash
> # Générer du trafic pour tester
> dd if=/dev/zero of=/dev/null bs=1M count=1000
> # Test CPU/mémoire
> 
> systat -vmstat 1
> # Statistiques système temps réel
> ```

---

### Interprétation des logs

#### Types de logs pfSense

```plaintext
Status > System Logs

Onglets principaux :
┌────────────────────────────────────────┐
│ System     : Logs système généraux     │
│ Firewall   : Blocages/autorisations    │
│ DHCP       : Baux DHCP                 │
│ Routing    : Événements routage        │
│ Wireless   : WiFi (si applicable)      │
│ VPN        : OpenVPN, IPsec            │
│ Services   : DNS, NTP, etc.            │
└────────────────────────────────────────┘
```

#### System Logs

> [!example] Comprendre les logs système
> 
> **Messages courants normaux**
> 
> ```plaintext
> check_reload_status: Reloading filter
> → Rechargement des règles de pare-feu (normal)
> 
> /usr/local/pkg/unbound.inc: Starting Unbound
> → Démarrage du DNS Resolver
> 
> dhclient: bound to <IP> -- renewal in <time>
> → Bail DHCP WAN obtenu/renouvelé
> ```
> 
> **Messages d'erreur importants**
> 
> ```plaintext
> kernel: em0: watchdog timeout
> → Problème matériel carte réseau (pilote, carte HS)
> 
> pf: state table full
> → Table d'états saturée (voir section dédiée)
> 
> php-fpm: WARNING: pool www seems busy
> → WebGUI surchargée (trop de connexions)
> 
> check_reload_status: Could not acquire lock
> → Problème de fichier de verrouillage (rare)
> ```

#### Firewall Logs

> [!example] Analyser les logs de pare-feu
> 
> **Structure d'une entrée**
> 
> ```plaintext
> Jan 10 14:23:45 LAN Block 192.168.1.50:54321 → 93.184.216.34:80 TCP:S
> 
> Décomposition :
> - Jan 10 14:23:45 : Timestamp
> - LAN : Interface d'entrée du paquet
> - Block : Action (Block/Pass/Reject)
> - 192.168.1.50:54321 : Source IP:Port
> - 93.184.216.34:80 : Destination IP:Port
> - TCP:S : Protocole et flags (S = SYN)
> ```
> 
> **Flags TCP courants**
> 
> ```plaintext
> S : SYN (début de connexion)
> A : ACK (acquittement)
> SA : SYN-ACK (réponse au SYN)
> F : FIN (fin de connexion)
> R : RST (reset, connexion brutalement fermée)
> P : PUSH (données à transmettre immédiatement)
> 
> Exemples :
> TCP:S     → Tentative de nouvelle connexion
> TCP:SA    → Réponse positive à une connexion
> TCP:R     → Connexion refusée/réinitialisée
> TCP:FA    → Fermeture propre de connexion
> ```
> 
> **Scénarios courants**
> 
> ```plaintext
> Scénario 1 : Blocage sortant légitime
> Block LAN 192.168.1.10:45678 → 8.8.8.8:53 UDP
> → Client essaie d'utiliser DNS mais règle manquante
> → Solution : Créer règle LAN → any port 53
> 
> Scénario 2 : Scan/attaque depuis Internet
> Block WAN 45.142.120.5:12345 → <WAN_IP>:22 TCP:S
> → Tentative de connexion SSH depuis Internet
> → Normal, ignorer (ou géolocaliser pour bloquer pays)
> 
> Scénario 3 : Blocage après changement de règle
> Block LAN 192.168.1.20:56789 → 10.0.0.5:443 TCP:S
> → Connexion vers serveur interne bloquée
> → Vérifier ordre des règles, créer exception si besoin
> 
> Scénario 4 : Spam de blocages identiques
> Block WAN 104.28.5.6:80 → <WAN_IP>:80 TCP:S (x1000 fois)
> → Attaque DDoS probable
> → Activer rate limiting ou bloquer l'IP/réseau
> ```

#### DHCP Logs

> [!example] Logs de serveur DHCP
> 
> **Événements normaux**
> 
> ```plaintext
> DHCPDISCOVER from 00:11:22:33:44:55 via em1
> → Client recherche un serveur DHCP
> 
> DHCPOFFER on 192.168.1.100 to 00:11:22:33:44:55 via em1
> → pfSense offre une adresse IP
> 
> DHCPREQUEST from 00:11:22:33:44:55 via em1
> → Client demande l'adresse offerte
> 
> DHCPACK on 192.168.1.100 to 00:11:22:33:44:55 via em1
> → pfSense confirme l'attribution
> ```
> 
> **Problèmes courants**
> 
> ```plaintext
> DHCPNAK on 192.168.1.100 to 00:11:22:33:44:55
> → Refus d'attribution (IP déjà prise, bail expiré)
> 
> DHCPDECLINE from 00:11:22:33:44:55: IP already in use
> → Client détecte que l'IP est déjà utilisée (conflit)
> → Vérifier IP statiques en conflit avec le pool DHCP
> 
> no free leases
> → Pool DHCP épuisé, toutes les IP attribuées
> → Augmenter la plage DHCP ou réduire le lease time
> ```

#### VPN Logs

> [!example] Logs OpenVPN
> 
> **Connexion réussie**
> 
> ```plaintext
> TLS: Username/Password authentication succeeded for 'user1'
> → Authentification réussie
> 
> MULTI: Learn: 10.8.0.6 -> user1/192.168.1.50
> → Attribution IP VPN (10.8.0.6) au client
> 
> Initialization Sequence Completed
> → Tunnel VPN établi
> ```
> 
> **Erreurs courantes**
> 
> ```plaintext
> TLS Error: TLS handshake failed
> → Problème de certificat ou de configuration TLS
> → Vérifier certificats, algorithmes de chiffrement
> 
> AUTH: Received control message: AUTH_FAILED
> → Identifiants incorrects
> → Vérifier username/password ou certificat client
> 
> Connection reset, restarting
> → Connexion perdue, redémarrage automatique
> → Peut indiquer problème réseau ou keepalive
> 
> Inactivity timeout, restarting
> → Pas de trafic pendant X secondes
> → Ajuster les paramètres keepalive
> ```

---

### Scénarios de dépannage complets

> [!info] Cas pratiques réels Voici des scénarios complets de dépannage avec leur résolution.

#### Scénario 1 : "Pas d'accès Internet depuis LAN"

**Symptômes** :

- Les PC du LAN ne peuvent pas accéder à Internet
- Le ping vers la gateway WAN depuis pfSense fonctionne
- Le ping vers 8.8.8.8 depuis pfSense fonctionne

**Diagnostic** :

```plaintext
Étape 1 : Vérifier la connectivité WAN
Status > Interfaces > WAN
✓ Interface up, IP attribuée : OK

Étape 2 : Tester depuis pfSense
Diagnostics > Ping > 8.8.8.8
✓ 0% loss : OK (pfSense a Internet)

Étape 3 : Tester depuis un PC LAN
ping 8.8.8.8
✗ Request timeout : Problème entre PC et Internet

Étape 4 : Tester la gateway LAN depuis le PC
ping 192.168.1.1 (IP LAN de pfSense)
✓ Répond : PC peut joindre pfSense

Étape 5 : Vérifier les règles de pare-feu
Firewall > Rules > LAN
✗ Aucune règle Pass ou règle trop restrictive
```

**Solution** :

```plaintext
1. Créer une règle LAN → any
   Firewall > Rules > LAN > Add
   Action: Pass
   Interface: LAN
   Source: LAN net
   Destination: any
   Description: Allow LAN to Internet

2. Vérifier le NAT Outbound
   Firewall > NAT > Outbound
   Mode: Automatic (ou règle manuelle pour LAN)

3. Tester à nouveau depuis un PC
   ping 8.8.8.8
   ✓ Fonctionne
```

---

#### Scénario 2 : "Déconnexions PPPoE fréquentes"

**Symptômes** :

- Connexion Internet se coupe toutes les 10-30 minutes
- Reconnexion automatique après quelques secondes
- Logs montrent des déconnexions/reconnexions

**Diagnostic** :

```bash
Status > System Logs > System
Rechercher : "pppoe"

Logs observés :
Jan 10 10:15:32 pppoe0: LCP timeout
Jan 10 10:15:33 pppoe0: PPPoE: connection closed
Jan 10 10:15:35 pppoe0: PPPoE: connection established
```

**Causes possibles** :

```plaintext
1. Problème de keepalive
2. MTU incorrect
3. Instabilité de la ligne ADSL/Fibre
4. Problème modem/ONT
```

**Solution** :

```plaintext
1. Activer le keepalive
   Interfaces > WAN > Advanced PPPoE Options
   ☑ Enable periodic keep-alive
   Interval: 30 seconds

2. Vérifier/ajuster le MTU
   MTU: 1492 (standard PPPoE)
   Tester avec : ping -f -l 1464 8.8.8.8

3. Vérifier les statistiques modem
   - Accéder à l'interface du modem
   - Vérifier SNR, atténuation, erreurs CRC
   - Si mauvais : contacter FAI

4. Vérifier les logs pour erreurs LCP/CHAP
   Si "CHAP authentication failed" : vérifier identifiants
   Si "LCP timeout" persistant : problème ligne/modem

5. Test avec VLAN si requis par FAI
   Interfaces > VLANs > Add
   VLAN Tag: 835 (Orange FR), 100 (Swisscom), etc.
```

---

#### Scénario 3 : "Règle de blocage ne fonctionne pas"

**Symptômes** :

- Règle créée pour bloquer Facebook
- Les utilisateurs peuvent toujours accéder à Facebook
- Pas d'entrée dans les logs de pare-feu

**Diagnostic** :

```plaintext
Configuration de la règle :
Firewall > Rules > LAN
Action: Block
Source: LAN net
Destination: Alias "Facebook_IPs"
Port: any

Test depuis PC :
ping facebook.com
✓ Répond encore

Vérification 1 : Ordre des règles
Position de la règle : #5
Position règle "Allow LAN to any" : #2
→ Problème : La règle Pass en #2 autorise tout AVANT le Block en #5
```

**Solution** :

```plaintext
1. Réorganiser les règles
   Déplacer la règle Block AVANT la règle Pass générale
   Nouvel ordre :
   #1 Block LAN → Facebook
   #2 Pass LAN → any

2. Vider les états existants
   Diagnostics > States
   Filtrer par destination Facebook IPs
   Kill States
   
   Ou vider tous les états :
   ☑ Kill all states

3. Améliorer le blocage (DNS + IP)
   Facebook utilise des centaines d'IPs
   
   Option A : Bloquer par DNS
   Services > DNS Resolver > Host Overrides
   Domain: facebook.com → IP: 0.0.0.0
   
   Option B : Utiliser pfBlockerNG
   Package pfBlockerNG-devel
   Bloquer par catégorie (réseaux sociaux)

4. Activer le logging pour vérifier
   ☑ Log packets that are handled by this rule
   
   Tester et vérifier dans Status > Firewall Logs
```

---

#### Scénario 4 : "CPU à 100% en permanence"

**Symptômes** :

- Dashboard montre CPU à 95-100%
- Interface Web lente à répondre
- Débit réseau réduit

**Diagnostic** :

```bash
Status > System
CPU usage: 98%
Load average: 4.5, 4.2, 4.0

Shell > top -a -S
PID   COMMAND    CPU%
1234  snort      85.2%
5678  php-fpm    8.5%
9012  unbound    3.1%
```

**Cause identifiée** : Snort (IDS) consomme 85% du CPU

**Solution** :

```plaintext
1. Solution immédiate : Désactiver temporairement
   Services > Snort > Global Settings
   ☐ Enable Snort VRT (décocher)
   Save

2. Solution permanente : Optimiser Snort
   
   a) Réduire les interfaces surveillées
      Services > Snort > Snort Interfaces
      Désactiver sur LAN si non critique
      Garder uniquement WAN
   
   b) Désactiver les règles non essentielles
      Services > Snort > WAN > Rules
      Décocher les catégories peu critiques :
      - chat, games, multimedia
      Garder : malware, exploit, policy
   
   c) Ajuster les performances
      Services > Snort > WAN > Performance
      "Search Method": AC-BS (plus rapide que AC)
      "Max Pattern Memory": 1024 (réduire)
   
   d) Alternative : Passer à Suricata
      Plus moderne, multi-threadé
      Meilleure gestion CPU multi-cœurs

3. Si toujours problématique
   → Augmenter puissance CPU
   → Ou désactiver IDS/IPS
   → Ou déplacer IDS sur machine dédiée
```

---

#### Scénario 5 : "Port forwarding ne fonctionne pas"

**Symptômes** :

- Port forward configuré pour serveur web interne
- Accès depuis Internet impossible
- Accès depuis LAN vers IP locale fonctionne

**Configuration actuelle** :

```plaintext
Firewall > NAT > Port Forward
Interface: WAN
Protocol: TCP
Destination Port: 80
Redirect Target IP: 192.168.1.100
Redirect Target Port: 80
Description: Web Server
```

**Diagnostic** :

```plaintext
Test 1 : Depuis Internet
curl http://<WAN_IP>:80
✗ Connection timeout

Test 2 : Depuis LAN vers IP locale
curl http://192.168.1.100:80
✓ Fonctionne

Test 3 : Test de port depuis pfSense
Diagnostics > Test Port
Host: 192.168.1.100
Port: 80
✓ Connected successfully

Vérification 1 : Règle de pare-feu WAN
Firewall > Rules > WAN
✓ Règle auto-créée présente pour port 80

Vérification 2 : Logs de pare-feu
Status > System Logs > Firewall
✗ Aucun log de blocage sur port 80

Vérification 3 : Service web sur le serveur
Sur 192.168.1.100 : netstat -an | grep :80
✓ Service écoute sur 0.0.0.0:80
```

**Cause identifiée** : Le modem/box en amont fait aussi du NAT (double NAT)

**Solution** :

```plaintext
Problème : Architecture réseau
Internet → Box FAI (NAT) → pfSense WAN → pfSense LAN → Serveur

Le port forward de pfSense ne sert à rien si la Box FAI
ne transfère pas le port 80 vers pfSense WAN.

Solution 1 : Mode bridge sur la Box FAI (recommandé)
1. Accéder à l'interface de la Box
2. Activer le mode bridge/passthrough
3. pfSense obtient l'IP publique directement
4. Le port forward pfSense fonctionne

Solution 2 : Double port forward (si bridge impossible)
1. Sur la Box FAI :
   Port 80 externe → <IP_WAN_pfSense>:80
   
2. Sur pfSense :
   Port 80 WAN → 192.168.1.100:80
   (déjà configuré)

Vérification après solution :
- pfSense WAN doit avoir IP publique (vérifier sur Status > Interfaces)
- Si IP en 10.x, 172.16-31.x, 192.168.x : Double NAT encore présent
- Si IP publique (hors plages privées) : OK

Test final :
curl http://<IP_PUBLIQUE>:80
✓ Doit fonctionner
```

---

### Checklist finale de dépannage

> [!tip] Aide-mémoire rapide
> 
> **Avant toute intervention** :
> 
> ```plaintext
> ☐ Sauvegarder la configuration (Diagnostics > Backup & Restore)
> ☐ Noter l'état actuel (capture d'écran si nécessaire)
> ☐ Identifier clairement le problème
> ☐ Tester de manière isolée
> ```
> 
> **Problème de connectivité** :
> 
> ```plaintext
> ☐ Vérifier statut interface (Status > Interfaces)
> ☐ Tester ping gateway
> ☐ Tester ping DNS externe (8.8.8.8)
> ☐ Vérifier règles de pare-feu
> ☐ Consulter les logs (System, Firewall)
> ☐ Vérifier table de routage
> ☐ Vider les états si règles modifiées
> ```
> 
> **Problème de performance** :
> 
> ```plaintext
> ☐ Vérifier CPU (Status > System)
> ☐ Vérifier RAM
> ☐ Vérifier table d'états (utilisation)
> ☐ Identifier processus gourmand (top)
> ☐ Vérifier vitesse interface réseau
> ☐ Tester avec features désactivées
> ```
> 
> **Problème de règles** :
> 
> ```plaintext
> ☐ Vérifier l'ordre des règles
> ☐ Vérifier l'interface source
> ☐ Activer le logging
> ☐ Consulter les logs firewall
> ☐ Créer règle de test temporaire
> ☐ Vider les états après modification
> ```
> 
> **Après résolution** :
> 
> ```plaintext
> ☐ Tester la solution complètement
> ☐ Documenter le problème et la solution
> ☐ Retirer les règles/configs de test temporaires
> ☐ Créer une sauvegarde de la configuration fonctionnelle
> ☐ Mettre en place monitoring pour prévenir récurrence
> ```

---

## 🎯 Points clés à retenir

> [!info] Synthèse du dépannage pfSense
> 
> **Philosophie** :
> 
> - Approche méthodique et progressive
> - Toujours partir de la couche la plus basse (physique)
> - Utiliser les outils de diagnostic intégrés
> - Consulter les logs avant de modifier
> 
> **Outils essentiels** :
> 
> - **Ping/Traceroute** : Connectivité réseau
> - **DNS Lookup** : Résolution de noms
> - **Logs** : Historique et erreurs
> - **States** : Connexions actives
> - **Packet Capture** : Analyse approfondie
> 
> **Pièges courants** :
> 
> - Ordre des règles incorrect
> - États résiduels après modification
> - Double NAT (box + pfSense)
> - MTU incorrect (PPPoE)
> - Limites système atteintes
> 
> **Bonnes pratiques** :
> 
> - Sauvegarder avant toute modification
> - Tester de manière isolée
> - Documenter les changements
> - Activer le logging temporairement pour diagnostic
> - Vider les états après modification de règles

---

## 📚 Ressources de dépannage

> [!tip] Où trouver de l'aide
> 
> **Documentation officielle** :
> 
> - https://docs.netgate.com/pfsense/en/latest/
> - Section "Troubleshooting"
> 
> **Communauté** :
> 
> - Forum pfSense : https://forum.netgate.com/
> - Reddit : r/pfSense
> - Netgate Discord
> 
> **Outils externes** :
> 
> - Wireshark : Analyse de paquets
> - iperf3 : Test de débit
> - mtr : Traceroute amélioré
> 
> **Logs et diagnostic** :
> 
> - Toujours consulter les logs en premier
> - Activer le logging détaillé temporairement
> - Utiliser packet capture pour cas complexes
> - Exporter les logs vers syslog externe pour analyse

---

**🔧 Fin du module de dépannage**

Ce module couvre les problèmes les plus courants rencontrés avec pfSense et fournit des méthodologies éprouvées pour les résoudre efficacement. La clé du dépannage réussi est une approche systématique, l'utilisation des bons outils, et la compréhension du fonctionnement réseau par couches.