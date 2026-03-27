

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

## Introduction

La création de règles de pare-feu dans pfSense est le cœur de la sécurité réseau. Chaque règle définit précisément quel trafic est autorisé ou bloqué, selon des critères comme la source, la destination, le protocole et le port.

> [!info] Principe fondamental pfSense applique les règles **de haut en bas** et s'arrête à la **première correspondance**. L'ordre des règles est donc crucial pour leur efficacité.

> [!warning] Règle par défaut Par défaut, pfSense **bloque tout** ce qui n'est pas explicitement autorisé. C'est le principe du "deny all" implicite en fin de liste.

---

## Interface de création de règles

### 🎯 Accès à l'interface

**Navigation** : `Firewall` → `Rules` → Sélectionner l'interface (WAN, LAN, OPT1, etc.)

Chaque interface possède son propre ensemble de règles. Les règles s'appliquent au trafic **entrant** sur l'interface sélectionnée.

### 📋 Éléments de l'interface

|Élément|Description|
|---|---|
|**Add (↑)**|Ajoute une règle en haut de la liste|
|**Add (↓)**|Ajoute une règle en bas de la liste|
|**Icons**|Éditer (✏️), Copier (📄), Supprimer (🗑️)|
|**Drag & Drop**|Réorganiser les règles par glisser-déposer|
|**Separator**|Ajouter des séparateurs pour organiser visuellement|

> [!tip] Organisation visuelle Utilisez les séparateurs avec des titres descriptifs (ex: "Règles VPN", "Accès Admin", "Services publics") pour faciliter la maintenance.

### ✨ Création d'une nouvelle règle

Cliquez sur **Add (↑)** ou **Add (↓)** pour ouvrir le formulaire de création.

**Champs principaux** :

```
Action           : Pass / Block / Reject
Disabled         : Cocher pour désactiver temporairement
Interface        : Interface concernée (pré-rempli)
Address Family   : IPv4, IPv6, IPv4+IPv6
Protocol         : TCP, UDP, ICMP, Any, etc.
```

> [!example] Différence entre Block et Reject
> 
> - **Block** : Ignore silencieusement les paquets (timeout côté client)
> - **Reject** : Envoie une réponse TCP RST ou ICMP unreachable (connexion refusée immédiatement)
> 
> Utilisez **Block** pour l'Internet (évite de révéler la présence du pare-feu), **Reject** en interne (diagnostic plus rapide).

---

## Source et destination

### 🌐 Définition des adresses

Pour chaque règle, vous devez spécifier **Source** et **Destination** avec les mêmes options.

#### Options disponibles

|Type|Description|Exemple d'utilisation|
|---|---|---|
|**any**|Toute adresse|Règle générique|
|**Single host**|Une adresse IP unique|`192.168.1.100`|
|**Network**|Réseau CIDR|`192.168.1.0/24`|
|**Alias**|Groupe d'adresses prédéfini|`Serveurs_Web`|
|**Interface address**|IP de l'interface pfSense|Pour l'administration|
|**Interface subnet**|Sous-réseau de l'interface|Réseau LAN complet|

> [!tip] Utilisation des alias Créez des alias pour les groupes d'adresses fréquemment utilisés. Cela facilite la maintenance et améliore la lisibilité.
> 
> Navigation : `Firewall` → `Aliases` → `Add`

### 🎯 Inversion avec "not"

Cochez **"Invert match"** pour exclure une adresse ou un réseau.

> [!example] Cas d'usage de l'inversion **Autoriser tout sauf une IP spécifique** :
> 
> - Source : `LAN subnet`
> - Destination : `!192.168.1.50` (cocher "Invert")
> 
> Permet d'isoler un hôte compromis sans bloquer tout le trafic.

### 📍 Ports source et destination

Les ports peuvent être spécifiés pour TCP et UDP uniquement.

**Options** :

- **any** : Tous les ports
- **Port unique** : `80`, `443`, `22`
- **Plage** : `10000:20000`
- **Alias de ports** : `Ports_Web` (80, 443, 8080, 8443)

> [!warning] Port source Dans la plupart des cas, laissez le port source à **"any"**. Les clients utilisent des ports éphémères aléatoires (généralement 49152-65535).
> 
> Ne restreignez le port source que pour des protocoles spécifiques qui l'exigent.

### 🧩 Exemples pratiques

#### Autoriser HTTP/HTTPS depuis le LAN vers Internet

```
Action       : Pass
Interface    : LAN
Protocol     : TCP
Source       : LAN subnet    Port: any
Destination  : any           Port: 80 (HTTP)
```

Créez une règle identique avec le port `443` pour HTTPS.

#### Autoriser SSH uniquement depuis une IP admin

```
Action       : Pass
Interface    : LAN
Protocol     : TCP
Source       : 192.168.1.10  Port: any
Destination  : LAN address   Port: 22
```

> [!tip] Astuce de sécurité Créez un alias `Admin_IPs` contenant toutes les adresses autorisées à administrer pfSense, puis utilisez-le comme source.

---

## Protocoles et ports

### 🔌 Protocoles disponibles

|Protocole|Description|Cas d'usage|
|---|---|---|
|**TCP**|Connexion orientée|Web, SSH, Email|
|**UDP**|Sans connexion|DNS, VPN, Streaming|
|**TCP/UDP**|Les deux|Règles génériques|
|**ICMP**|Messages de contrôle|Ping, diagnostics|
|**ESP**|IPsec encryption|Tunnels VPN|
|**GRE**|Generic Routing|Tunnels, VPN PPTP|
|**Any**|Tous les protocoles|Règles très permissives|

### 🎭 Spécificités ICMP

Pour ICMP, vous pouvez spécifier le **type ICMP** :

```
Protocol     : ICMP
ICMP type    : Echo Request (ping)
```

**Types ICMP courants** :

- **Echo Request (8)** : Ping sortant
- **Echo Reply (0)** : Réponse au ping
- **Destination Unreachable (3)** : Hôte/port inaccessible
- **Time Exceeded (11)** : TTL expiré (traceroute)

> [!tip] Autoriser le ping Créez deux règles pour autoriser le ping bidirectionnel :
> 
> 1. Echo Request (type 8) - sortant
> 2. Echo Reply (type 0) - entrant

### 🚪 Gestion des ports

#### Ports bien connus

|Service|Port|Protocole|
|---|---|---|
|HTTP|80|TCP|
|HTTPS|443|TCP|
|SSH|22|TCP|
|DNS|53|TCP/UDP|
|SMTP|25|TCP|
|IMAP|143|TCP|
|RDP|3389|TCP|
|OpenVPN|1194|UDP|

#### Alias de ports

Créez des alias pour grouper des ports liés :

**Navigation** : `Firewall` → `Aliases` → `Ports`

> [!example] Alias Ports_Web
> 
> ```
> Nom    : Ports_Web
> Type   : Port(s)
> Ports  : 80 443 8080 8443
> ```

### 🔄 States et connexions établies

pfSense gère automatiquement les **états de connexion** (stateful firewall).

> [!info] Fonctionnement du stateful Quand vous autorisez une connexion **sortante**, la réponse **entrante** est automatiquement autorisée grâce au suivi d'état.
> 
> Vous n'avez **pas besoin** de créer une règle inverse pour les réponses.

**Exemple** :

- Règle LAN : Autoriser TCP vers any:80
- Résultat : Les clients LAN peuvent établir des connexions HTTP, et les réponses sont automatiquement autorisées sans règle supplémentaire.

---

## Options avancées

### 📝 Logging

**Activation** : Cochez **"Log packets that are handled by this rule"**

Le logging enregistre les paquets correspondants dans les logs système.

**Visualisation** : `Status` → `System Logs` → `Firewall`

> [!warning] Impact performance Le logging intensif peut affecter les performances sur du trafic à haut débit. Activez-le sélectivement :
> 
> - Toujours pour les règles **Block** (détecter les tentatives d'intrusion)
> - Temporairement pour les règles **Pass** (diagnostic)
> - Jamais pour le trafic très fréquent (DNS, trafic interne)

### ⏰ Scheduling (Planification)

Limitez l'application d'une règle à certaines périodes.

**Configuration** :

1. Créer un planning : `Firewall` → `Schedules` → `Add`
2. Définir les jours et heures
3. Sélectionner le schedule dans la règle

> [!example] Contrôle parental
> 
> ```
> Nom         : Heures_Scolaires
> Jours       : Lundi-Vendredi
> Heures      : 08:00-17:00
> 
> Règle :
> Action      : Block
> Source      : Alias_Enfants
> Destination : any
> Port        : 80, 443
> Schedule    : Heures_Scolaires
> ```
> 
> Bloque Internet pendant les heures d'école.

### 🏷️ Description et catégories

**Description** : Champ obligatoire pour documenter l'objet de la règle.

> [!tip] Conventions de nommage Adoptez une convention cohérente :
> 
> - `[SERVICE] - Description détaillée`
> - `[WEB] - Autoriser HTTP/HTTPS vers Internet`
> - `[ADMIN] - SSH depuis poste admin`
> - `[BLOCK] - Bloquer trafic P2P`

**Catégories** : Utilisez les séparateurs pour grouper visuellement les règles connexes.

### 🎚️ Advanced Options

#### Gateway

Spécifiez une passerelle particulière pour cette règle (routage par politique).

**Cas d'usage** :

- Multi-WAN : Router certain trafic vers WAN1, autre vers WAN2
- VPN : Forcer certains flux dans un tunnel VPN

#### In / Out pipe

Limite de bande passante (traffic shaping).

> [!info] Prérequis Nécessite la configuration préalable de limiters dans `Firewall` → `Traffic Shaper` → `Limiters`

#### Queue

Priorisation du trafic (QoS).

**Priorités courantes** :

- **Haute** : VoIP, visioconférence
- **Moyenne** : Navigation web, email
- **Basse** : Téléchargements, backups

#### Allow IP options

Autorise les paquets IP avec options (généralement désactivé pour la sécurité).

#### Disable reply-to

Désactive le routage de réponse automatique. Utile dans certaines configurations multi-WAN complexes.

#### Tag / Tagged

Étiquetage de paquets pour le traitement par d'autres règles (utilisation avancée).

#### Max states / Max source nodes

Limite le nombre de connexions :

- **Max states** : Limite totale de connexions pour cette règle
- **Max source nodes** : Limite par adresse IP source

> [!example] Protection anti-flood
> 
> ```
> Max states       : 100
> Max src nodes    : 50
> Max src states   : 10
> ```
> 
> Limite à 10 connexions simultanées par IP, 50 IPs différentes, 100 connexions totales.

### 🔒 State Type

|Type|Description|
|---|---|
|**Keep state**|Suivi d'état normal (défaut)|
|**Sloppy state**|Moins strict, pour trafic asymétrique|
|**Synproxy state**|Protection contre SYN flood|
|**None**|Pas de suivi d'état (stateless)|

> [!warning] Synproxy Utilisez **synproxy state** sur les règles WAN exposées à Internet pour protéger contre les attaques SYN flood. Peut légèrement augmenter la latence.

### 📊 Advanced features

#### No XMLRPC Sync

Empêche la synchronisation de cette règle vers un pare-feu secondaire en HA.

#### VLAN Priority

Définit la priorité 802.1p pour le trafic (QoS niveau 2).

#### Diffserv Code Point

Marque DSCP pour la QoS IP (priorité niveau 3).

---

## Bonnes pratiques

### ✅ Règles générales

1. **Principe du moindre privilège** : N'autorisez que le strict nécessaire
2. **Ordre des règles** : Placez les règles spécifiques avant les règles générales
3. **Documentation** : Décrivez clairement chaque règle
4. **Révision régulière** : Auditez et nettoyez les règles obsolètes
5. **Tests progressifs** : Testez les nouvelles règles avant la mise en production

### 🎯 Organisation recommandée

**Ordre des règles par interface** :

```
1. Règles anti-lockout (interface admin)
2. Règles de blocage spécifiques (sécurité)
3. Règles d'autorisation spécifiques (services)
4. Règles d'autorisation générales
5. Règle de blocage finale (logging)
```

> [!tip] Règle de blocage finale Ajoutez une règle explicite `Block any any` en fin de liste avec logging activé. Même si pfSense bloque par défaut, cela permet de logger ce qui est refusé.

### 🚨 Pièges courants

#### 1. Oublier le port source

> [!warning] Erreur fréquente
> 
> ```
> ❌ Mauvais :
> Source : LAN subnet    Port: 1024:65535
> Dest   : any           Port: 80
> 
> ✅ Correct :
> Source : LAN subnet    Port: any
> Dest   : any           Port: 80
> ```
> 
> Les clients utilisent des ports source éphémères aléatoires.

#### 2. Ordre des règles incorrect

> [!example] Problème d'ordre
> 
> ```
> Règle 1: Pass LAN subnet → any (trop permissive)
> Règle 2: Block LAN subnet → 10.0.0.0/8 (jamais appliquée)
> 
> Solution : Inverser l'ordre
> Règle 1: Block LAN subnet → 10.0.0.0/8
> Règle 2: Pass LAN subnet → any
> ```

#### 3. Confusion interface WAN vs LAN

> [!info] Direction du trafic
> 
> - **Règles LAN** : Contrôlent le trafic **depuis** le LAN
> - **Règles WAN** : Contrôlent le trafic **depuis** Internet
> 
> Pour autoriser l'accès à un serveur web interne depuis Internet, créez une règle sur **WAN**, pas sur LAN.

#### 4. Oublier les règles de retour pour les protocoles stateless

Pour les protocoles sans état (ex: certains types de VPN), vous devez créer des règles dans les deux sens.

### 🔐 Sécurité

1. **RFC1918** : Bloquez les adresses privées sur WAN (normalement activé par défaut)
2. **Bogon networks** : Bloquez les réseaux non alloués (liste mise à jour régulièrement)
3. **Anti-spoofing** : Activez la vérification anti-usurpation sur toutes les interfaces
4. **Logging des blocages** : Activez toujours le logging sur les règles de blocage
5. **Limitation de connexions** : Utilisez max states/src pour prévenir les abus

### 📈 Performance

1. **Règles spécifiques en premier** : Réduisent le nombre de règles évaluées
2. **Utilisation d'alias** : Plus efficace que de dupliquer les règles
3. **Logging modéré** : N'activez pas le logging sur tout le trafic
4. **Quick** : Par défaut, pfSense s'arrête à la première correspondance (comportement optimal)

### 🧪 Tests et validation

> [!tip] Méthodologie de test
> 
> 1. **Mode audit** : Activez le logging sans bloquer (règle Pass avec log)
> 2. **Vérification** : Consultez les logs pour confirmer le comportement
> 3. **Test limité** : Appliquez d'abord à une IP test
> 4. **Validation** : Testez tous les scénarios (autorisation + blocage)
> 5. **Documentation** : Notez les résultats et ajustez

**Outils de diagnostic** :

- `Diagnostics` → `Packet Capture` : Capture de paquets
- `Diagnostics` → `States` : Visualiser les connexions actives
- `Diagnostics` → `Test Port` : Tester l'accessibilité d'un port

---

> [!success] Points clés à retenir
> 
> - Les règles s'appliquent **de haut en bas**, première correspondance gagne
> - Toujours spécifier **Source**, **Destination**, **Protocol**, **Port**
> - Le suivi d'état gère automatiquement les réponses (stateful firewall)
> - Documenter chaque règle avec une description claire
> - Tester progressivement et logger pour diagnostiquer
> - Organiser logiquement avec des séparateurs
> - Appliquer le principe du moindre privilège