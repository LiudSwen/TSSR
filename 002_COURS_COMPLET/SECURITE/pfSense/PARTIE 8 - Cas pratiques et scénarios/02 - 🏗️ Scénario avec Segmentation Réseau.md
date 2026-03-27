

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

## 🎯 Introduction à la segmentation réseau {#introduction}

La segmentation réseau consiste à diviser un réseau en plusieurs sous-réseaux logiques pour améliorer la sécurité, les performances et la gestion.

> [!info] Pourquoi segmenter ?
> 
> - **Sécurité** : Limiter la propagation d'attaques ou de malwares
> - **Performance** : Réduire les domaines de broadcast
> - **Conformité** : Respecter les exigences réglementaires (PCI-DSS, RGPD)
> - **Organisation** : Séparer les départements, fonctions ou niveaux de confiance

### Concepts clés

|Concept|Description|Cas d'usage|
|---|---|---|
|**VLAN**|Virtual LAN - Segmentation au niveau 2 (liaison)|Séparer employés/invités sur même infrastructure|
|**Sous-réseau**|Division au niveau 3 (réseau)|Isolation logique avec routage contrôlé|
|**Zone de confiance**|Regroupement selon le niveau de sécurité|LAN, DMZ, Guest, Admin|

---

## 🔀 Séparation des réseaux avec VLANs {#vlans}

### Architecture type avec VLANs

```
                    ┌─────────────┐
                    │   pfSense   │
                    └──────┬──────┘
                           │
                    ┌──────┴──────┐
                    │  Switch     │
                    │  manageable │
                    └──────┬──────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
    VLAN 10            VLAN 20            VLAN 30
    (LAN Corp)         (Invités)         (Serveurs)
```

### Configuration des VLANs dans pfSense

> [!example] Création d'un VLAN

**Étape 1 : Créer l'interface VLAN**

```
Interfaces > Assignments > VLANs > Add

Parent Interface : em1 (interface physique)
VLAN Tag        : 10
Description     : VLAN_CORP
```

**Étape 2 : Assigner l'interface VLAN**

```
Interfaces > Assignments

Available network ports : VLAN 10 on em1 (VLAN_CORP)
Cliquer sur [+Add]
```

**Étape 3 : Configurer l'interface**

```
Interfaces > OPT1 (renommer en CORP)

Enable           : ✓ Enable interface
Description      : CORP
IPv4 Type        : Static IPv4
IPv4 Address     : 192.168.10.1/24
```

### Exemple complet : 4 VLANs

|VLAN ID|Nom|Réseau|Description|
|---|---|---|---|
|10|CORP|192.168.10.0/24|Réseau d'entreprise principal|
|20|GUEST|192.168.20.0/24|Réseau invités|
|30|SERVERS|192.168.30.0/24|DMZ serveurs internes|
|99|ADMIN|192.168.99.0/24|Administration réseau|

> [!tip] Bonnes pratiques pour les VLANs
> 
> - **Numérotation cohérente** : VLAN 10 → 192.168.10.0/24
> - **Réserver VLAN 1** : Ne jamais utiliser le VLAN natif pour les données
> - **VLAN Management** : Créer un VLAN dédié pour l'administration
> - **Documentation** : Maintenir un tableau de mapping VLAN/réseau/usage

---

## 🚦 Règles inter-VLAN {#regles-inter-vlan}

Par défaut, pfSense **bloque tout le trafic** entre les interfaces. Il faut créer des règles explicites pour autoriser les flux.

### Philosophie de sécurité

> [!warning] Principe du moindre privilège
> 
> - **Deny by default** : Tout est bloqué par défaut
> - **Allow explicite** : N'autoriser que ce qui est strictement nécessaire
> - **Logs** : Journaliser les tentatives de connexion pour détecter les anomalies

### Scénarios de règles inter-VLAN

#### Scénario 1 : CORP peut accéder à SERVERS

```
Firewall > Rules > CORP > Add ↑

Action      : Pass
Interface   : CORP
Protocol    : TCP
Source      : CORP net (192.168.10.0/24)
Destination : SERVERS net (192.168.30.0/24)
Dest. Port  : 443 (HTTPS)
Description : CORP vers serveurs web internes
```

> [!example] Règle détaillée avec options avancées

```
Action           : Pass
Disabled         : [ ] (activée)
Interface        : CORP
Address Family   : IPv4
Protocol         : TCP

Source:
  Source         : CORP net
  Source Port    : any

Destination:
  Destination    : SERVERS net
  Dest. Port     : 443 (HTTPS)

Extra Options:
  Log            : ✓ Log packets matched
  Description    : Accès HTTPS vers serveurs DMZ

Advanced Options:
  Gateway        : default
  State Type     : Keep state
```

#### Scénario 2 : GUEST isolé (aucun accès aux autres VLANs)

```
Firewall > Rules > GUEST

Règle 1 (en haut):
Action      : Block
Protocol    : Any
Source      : GUEST net
Destination : RFC1918 (réseaux privés)
Description : Bloquer accès aux réseaux internes

Règle 2 (en dessous):
Action      : Pass
Protocol    : Any
Source      : GUEST net
Destination : Any
Description : Autoriser Internet uniquement
```

> [!info] Alias RFC1918 Créer un alias pour les réseaux privés :
> 
> ```
> Firewall > Aliases > IP > Add
> 
> Name    : RFC1918
> Type    : Network(s)
> Networks: 192.168.0.0/16
>          172.16.0.0/12
>          10.0.0.0/8
> ```

#### Scénario 3 : ADMIN a accès complet

```
Firewall > Rules > ADMIN

Règle unique:
Action      : Pass
Protocol    : Any
Source      : ADMIN net
Destination : Any
Description : Administration - accès complet
Log         : ✓ (surveillance)
```

### Ordre des règles

> [!warning] L'ordre est crucial ! pfSense traite les règles de **haut en bas** et s'arrête à la **première correspondance**.

**Exemple d'ordre correct pour CORP :**

```
1. [Block] CORP net → ADMIN net (bloquer l'accès admin)
2. [Pass]  CORP net → SERVERS:443 (autoriser HTTPS serveurs)
3. [Pass]  CORP net → SERVERS:22 (autoriser SSH serveurs)
4. [Pass]  CORP net → Any (autoriser Internet)
```

**❌ Ordre incorrect :**

```
1. [Pass]  CORP net → Any (autoriser Internet)
2. [Block] CORP net → ADMIN net (jamais évaluée !)
```

---

## 🌐 Réseau invité isolé {#reseau-invite}

Un réseau invité doit permettre l'accès Internet tout en empêchant l'accès aux ressources internes.

### Configuration complète

#### Étape 1 : Créer le VLAN invité

```
Interfaces > Assignments > VLANs > Add

VLAN Tag    : 20
Parent      : em1
Description : VLAN_GUEST
```

#### Étape 2 : Configurer l'interface

```
Interfaces > GUEST

Enable         : ✓
IPv4 Type      : Static
IPv4 Address   : 192.168.20.1/24
```

#### Étape 3 : Activer DHCP pour les invités

```
Services > DHCP Server > GUEST

Enable         : ✓
Range          : 192.168.20.100 - 192.168.20.200
DNS Servers    : 1.1.1.1, 8.8.8.8 (DNS publics)
Gateway        : 192.168.20.1
Domain name    : guest.local
```

> [!tip] DNS pour invités Utiliser des DNS publics (1.1.1.1, 8.8.8.8) plutôt que le DNS interne pour éviter la fuite d'informations sur l'infrastructure.

#### Étape 4 : Règles de firewall strictes

```
Firewall > Rules > GUEST

┌─────────────────────────────────────────────────────┐
│ Règle 1 - Bloquer résolution DNS interne            │
├─────────────────────────────────────────────────────┤
│ Action      : Block                                 │
│ Protocol    : UDP                                   │
│ Source      : GUEST net                             │
│ Destination : LAN address                           │
│ Dest. Port  : 53                                    │
│ Description : Bloquer DNS vers pfSense              │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ Règle 2 - Bloquer tous les réseaux privés           │
├─────────────────────────────────────────────────────┤
│ Action      : Block                                 │
│ Protocol    : Any                                   │
│ Source      : GUEST net                             │
│ Destination : RFC1918 (alias)                       │
│ Log         : ✓                                     │
│ Description : Isolation des réseaux internes        │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ Règle 3 - Bloquer accès interface pfSense           │
├─────────────────────────────────────────────────────┤
│ Action      : Block                                 │
│ Protocol    : Any                                   │
│ Source      : GUEST net                             │
│ Destination : This Firewall                         │
│ Description : Bloquer accès WebGUI/SSH              │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ Règle 4 - Autoriser Internet                        │
├─────────────────────────────────────────────────────┤
│ Action      : Pass                                  │
│ Protocol    : Any                                   │
│ Source      : GUEST net                             │
│ Destination : Any                                   │
│ Description : Accès Internet uniquement             │
└─────────────────────────────────────────────────────┘
```

### Options avancées pour invités

#### Limitation de bande passante

```
Firewall > Traffic Shaper > Limiters

Limiter Name : Guest_Download
Bandwidth    : 50 Mbps
Queue        : 100

Limiter Name : Guest_Upload  
Bandwidth    : 10 Mbps
Queue        : 100

Appliquer aux règles GUEST:
In/Out pipe : Guest_Download / Guest_Upload
```

#### Portail captif (optionnel)

```
Services > Captive Portal > Add

Enable              : ✓
Interface           : GUEST
Max concurrent      : 50
Idle timeout        : 60 minutes
Hard timeout        : 180 minutes
Authentication      : No Authentication
Landing page        : Conditions d'utilisation
```

> [!warning] Sécurité du portail captif Le portail captif n'est **pas** une mesure de sécurité forte. Il sert principalement à :
> 
> - Afficher des conditions d'utilisation
> - Collecter des statistiques
> - Limiter la durée de connexion

---

## 🛡️ DMZ pour serveurs {#dmz}

Une DMZ (Zone Démilitarisée) isole les serveurs accessibles depuis Internet ou depuis plusieurs réseaux, limitant les risques en cas de compromission.

### Principes de la DMZ

```
Internet
   │
   ↓
[pfSense WAN]
   │
   ├──→ [DMZ] ← Serveurs exposés (Web, Mail, etc.)
   │      ↑
   │      │ (accès contrôlé)
   │      ↓
   └──→ [LAN] ← Postes de travail
```

> [!info] Philosophie de la DMZ
> 
> - **Exposition contrôlée** : Les serveurs sont accessibles mais isolés
> - **Segmentation bidirectionnelle** : Contrôle Internet→DMZ ET LAN→DMZ
> - **Limitation des dégâts** : Si un serveur DMZ est compromis, le LAN reste protégé

### Configuration DMZ

#### Étape 1 : Créer le réseau DMZ

```
Interfaces > Assignments > VLANs > Add

VLAN Tag    : 30
Parent      : em1
Description : VLAN_DMZ
```

```
Interfaces > DMZ

Enable         : ✓
IPv4 Type      : Static
IPv4 Address   : 192.168.30.1/24
```

#### Étape 2 : Adressage statique pour serveurs

```
Services > DHCP Server > DMZ

Enable : [ ] (désactivé - IPs statiques recommandées)
```

> [!tip] IPs statiques en DMZ Les serveurs en DMZ doivent avoir des IPs fixes pour faciliter :
> 
> - La création de règles de firewall précises
> - Le NAT/Port Forwarding
> - La documentation et l'audit

**Plan d'adressage DMZ :**

|IP|Serveur|Service|Port|
|---|---|---|---|
|192.168.30.10|web-01|HTTPS|443|
|192.168.30.11|mail-01|SMTP/IMAP|25/993|
|192.168.30.12|ftp-01|FTPS|990|

#### Étape 3 : Règles WAN → DMZ (accès depuis Internet)

```
Firewall > Rules > WAN

┌─────────────────────────────────────────────────────┐
│ Port Forwarding HTTPS vers serveur web              │
├─────────────────────────────────────────────────────┤
│ Action         : Pass                               │
│ Interface      : WAN                                │
│ Protocol       : TCP                                │
│ Source         : Any                                │
│ Destination    : WAN address                        │
│ Dest. Port     : 443                                │
│ Redirect IP    : 192.168.30.10                      │
│ Redirect Port  : 443                                │
│ NAT reflection : Enable                             │
│ Description    : HTTPS vers web-01                  │
└─────────────────────────────────────────────────────┘
```

> [!example] NAT automatique Lors de la création d'un Port Forward, pfSense crée automatiquement :
> 
> - La règle de firewall WAN
> - La règle NAT correspondante
> 
> Via : `Firewall > NAT > Port Forward > Add`

#### Étape 4 : Règles LAN → DMZ (accès interne contrôlé)

```
Firewall > Rules > LAN

┌─────────────────────────────────────────────────────┐
│ Administration SSH des serveurs DMZ                  │
├─────────────────────────────────────────────────────┤
│ Action      : Pass                                  │
│ Protocol    : TCP                                   │
│ Source      : ADMIN net (192.168.99.0/24)           │
│ Destination : DMZ net                               │
│ Dest. Port  : 22                                    │
│ Log         : ✓                                     │
│ Description : SSH admin vers DMZ                    │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ Accès utilisateurs aux services DMZ                 │
├─────────────────────────────────────────────────────┤
│ Action      : Pass                                  │
│ Protocol    : TCP                                   │
│ Source      : LAN net                               │
│ Destination : 192.168.30.10 (web-01)                │
│ Dest. Port  : 443                                   │
│ Description : LAN vers serveur web intranet         │
└─────────────────────────────────────────────────────┘
```

#### Étape 5 : Règles DMZ → autres réseaux (très restrictif)

```
Firewall > Rules > DMZ

┌─────────────────────────────────────────────────────┐
│ Bloquer tout accès aux réseaux internes             │
├─────────────────────────────────────────────────────┤
│ Action      : Block                                 │
│ Protocol    : Any                                   │
│ Source      : DMZ net                               │
│ Destination : RFC1918                               │
│ Log         : ✓                                     │
│ Description : DMZ isolée des réseaux internes       │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ Autoriser DNS externe uniquement                    │
├─────────────────────────────────────────────────────┤
│ Action      : Pass                                  │
│ Protocol    : UDP                                   │
│ Source      : DMZ net                               │
│ Destination : Any                                   │
│ Dest. Port  : 53                                    │
│ Description : DNS vers Internet                     │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ Autoriser mises à jour (HTTP/HTTPS)                 │
├─────────────────────────────────────────────────────┤
│ Action      : Pass                                  │
│ Protocol    : TCP                                   │
│ Source      : DMZ net                               │
│ Destination : Any                                   │
│ Dest. Port  : 80,443                                │
│ Description : Updates serveurs DMZ                  │
└─────────────────────────────────────────────────────┘
```

### Hardening de la DMZ

> [!warning] Mesures de sécurité supplémentaires

**1. Surveillance accrue**

```
Status > System Logs > Firewall

Filter : DMZ
Enable : ✓ Log packets matched by the default deny rule
```

**2. Limitation de connexions**

```
Firewall > Rules > WAN (règle HTTPS vers DMZ)

Advanced Options:
  Max concurrent connections : 100
  Max new connections / sec  : 10
```

**3. IDS/IPS sur DMZ** (Suricata/Snort)

```
Services > Suricata > Interfaces > Add

Interface : DMZ
Enable    : ✓
Mode      : IPS (blocking)
Rules     : Emerging Threats
```

**4. Logging des connexions**

```
Firewall > Rules > DMZ

Sur TOUTES les règles DMZ:
  Log : ✓ Log packets matched
```

---

## 🏛️ Architecture complète et bonnes pratiques {#architecture-complete}

### Architecture multi-zones type

```
                        Internet
                            │
                    ┌───────┴────────┐
                    │   pfSense WAN  │
                    └───────┬────────┘
                            │
        ┌───────────────────┼───────────────────┬───────────────┐
        │                   │                   │               │
   ┌────┴────┐         ┌────┴────┐        ┌────┴────┐    ┌────┴────┐
   │ VLAN 10 │         │ VLAN 20 │        │ VLAN 30 │    │ VLAN 99 │
   │  CORP   │         │  GUEST  │        │   DMZ   │    │  ADMIN  │
   └─────────┘         └─────────┘        └─────────┘    └─────────┘
   192.168.10.0/24     192.168.20.0/24    192.168.30.0/24  192.168.99.0/24
   
   Postes de travail   WiFi invités       Serveurs web     Administration
   Imprimantes         Smartphones        Mail servers     Jump host
```

### Matrice de flux entre zones

|Source ↓ / Dest →|WAN|CORP|GUEST|DMZ|ADMIN|
|---|---|---|---|---|---|
|**WAN**|-|❌|❌|✅ (ports)|❌|
|**CORP**|✅|✅|❌|✅ (services)|❌|
|**GUEST**|✅|❌|❌|❌|❌|
|**DMZ**|✅ (limité)|❌|❌|❌|❌|
|**ADMIN**|✅|✅|✅|✅|✅|

> [!tip] Légende
> 
> - ✅ = Autorisé (avec règles spécifiques)
> - ❌ = Bloqué par défaut
> - WAN = Accès Internet sortant

### Bonnes pratiques générales

#### 1. Nommage cohérent

```
Convention de nommage:
  Interfaces : [FONCTION]_[VLAN] (ex: CORP_10)
  Règles     : [SOURCE]→[DEST]:[SERVICE] (ex: LAN→DMZ:HTTPS)
  Alias      : [TYPE]_[NOM] (ex: NET_Servers, PORT_WebServices)
```

#### 2. Documentation des règles

> [!example] Template de description de règle
> 
> ```
> Format : [Source] → [Destination] : [Service] | [Contexte]
> 
> Exemples:
> - "CORP → Internet : Any | Navigation utilisateurs"
> - "WAN → DMZ:web-01:443 | Portail clients HTTPS"
> - "ADMIN → DMZ:22 | SSH administration serveurs"
> ```

#### 3. Utilisation des alias

```
Firewall > Aliases

┌─────────────────────────────────────┐
│ Alias : Serveurs_Web                │
├─────────────────────────────────────┤
│ Type        : Host(s)               │
│ Addresses   : 192.168.30.10         │
│              192.168.30.11         │
│ Description : Serveurs web DMZ      │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│ Alias : Ports_Web                   │
├─────────────────────────────────────┤
│ Type  : Port(s)                     │
│ Ports : 80                          │
│        443                          │
│        8080                         │
└─────────────────────────────────────┘
```

> [!info] Avantages des alias
> 
> - **Maintenance** : Modifier une IP à un seul endroit
> - **Lisibilité** : "Serveurs_Web" plus clair que "192.168.30.10"
> - **Groupement** : Appliquer une règle à plusieurs hôtes/ports

#### 4. Logging stratégique

```
Logs à activer:
  ✓ Règles de blocage inter-VLAN (détecter tentatives d'intrusion)
  ✓ Accès depuis WAN vers DMZ (surveillance exposition)
  ✓ Règles ADMIN (audit des actions admin)
  ✓ Règle par défaut de blocage (catch-all)

Logs à désactiver (bruit):
  ✗ Trafic autorisé routine (LAN → Internet)
  ✗ DNS autorisé
  ✗ NTP autorisé
```

#### 5. Révision régulière

> [!warning] Audit de sécurité **Hebdomadaire :**
> 
> - Vérifier les logs de blocage
> - Analyser les connexions DMZ
> 
> **Mensuel :**
> 
> - Revoir la matrice de flux
> - Désactiver les règles inutilisées
> - Vérifier les règles "Any/Any"
> 
> **Trimestriel :**
> 
> - Test d'intrusion inter-VLAN
> - Mise à jour documentation
> - Révision des accès ADMIN

### Pièges courants à éviter

|Piège|Impact|Solution|
|---|---|---|
|Règle "Any/Any" trop permissive|Contournement de la segmentation|Spécifier protocole/port précis|
|Ordre des règles incorrect|Règles jamais évaluées|Règles restrictives EN HAUT|
|Pas de logging sur blocages|Intrusions non détectées|Logger les deny inter-VLAN|
|DMZ peut accéder au LAN|Compromission DMZ = compromission LAN|Bloquer explicitement DMZ→RFC1918|
|Oublier "This Firewall"|Invités accèdent au WebGUI|Bloquer GUEST→This Firewall|
|Réutiliser VLAN 1|Problèmes de sécurité switch|Commencer à VLAN 10 minimum|

### Checklist de configuration

```
✓ VLANs créés et assignés
✓ Adressage IP planifié et documenté
✓ DHCP configuré (sauf DMZ)
✓ Règles par défaut : deny all
✓ Règles inter-VLAN : moindre privilège
✓ GUEST isolé des réseaux privés
✓ DMZ isolée du LAN
✓ Alias créés pour maintenance
✓ Descriptions claires sur toutes les règles
✓ Logging activé sur points critiques
✓ NAT/Port Forwarding testé
✓ Matrice de flux validée
✓ Documentation à jour
✓ Tests de connectivité effectués
```

---

> [!tip] Astuce finale La segmentation réseau est un **processus itératif**. Commencez simple (3 zones : LAN, GUEST, DMZ), testez, validez, puis ajoutez des zones selon les besoins. Une architecture trop complexe dès le départ est difficile à maintenir et source d'erreurs.