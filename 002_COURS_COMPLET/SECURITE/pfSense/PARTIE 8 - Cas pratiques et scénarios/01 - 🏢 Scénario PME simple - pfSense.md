

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

## 🏗️ Architecture réseau typique

### Présentation du contexte PME

Une PME (Petite et Moyenne Entreprise) de 10 à 50 employés nécessite une infrastructure réseau simple, sécurisée et facile à maintenir. L'architecture typique comprend :

- **Connexion Internet** via un modem/routeur FAI
- **Firewall pfSense** comme point central de sécurité
- **Réseau LAN** pour les postes de travail
- **Serveurs internes** (optionnel : serveur de fichiers, imprimante réseau)

### Schéma d'architecture recommandée

```
Internet (WAN)
      |
   [Modem FAI]
      |
  [pfSense] ← Point central de sécurité
      |
   [Switch]
      |
      ├─ Postes de travail (192.168.1.0/24)
      ├─ Imprimantes réseau
      └─ Serveur de fichiers (optionnel)
```

> [!info] Pourquoi cette architecture ? Cette topologie en étoile permet de centraliser toute la sécurité sur pfSense, simplifiant la gestion et le dépannage. Tous les flux passent par le firewall, offrant une visibilité complète sur le trafic.

### Choix des plages d'adresses

|Segment|Plage IP|Masque|Utilisation|
|---|---|---|---|
|WAN|Fournie par FAI|Variable|Connexion Internet|
|LAN|192.168.1.0/24|255.255.255.0|Réseau principal (254 hôtes)|

> [!tip] Bonnes pratiques d'adressage
> 
> - Réservez les premières adresses (192.168.1.1-10) pour les équipements critiques
> - pfSense : 192.168.1.1
> - Switch manageable : 192.168.1.2
> - Serveur : 192.168.1.10
> - DHCP pool : 192.168.1.100-192.168.1.254

---

## 🌐 Configuration WAN/LAN

### Configuration de l'interface WAN

L'interface WAN connecte pfSense à Internet via le modem du FAI.

#### Étapes de configuration WAN

**Navigation :** `Interfaces > WAN`

|Paramètre|Valeur recommandée|Explication|
|---|---|---|
|**Enable**|✓ Coché|Active l'interface|
|**IPv4 Configuration Type**|DHCP|Le FAI attribue l'IP automatiquement|
|**IPv6 Configuration Type**|None (ou DHCPv6)|Selon support FAI|
|**MAC Address**|Vide|Utilise le MAC natif (sauf clonage nécessaire)|
|**MTU**|1500|Valeur standard Ethernet|
|**MSS**|Vide|Auto-détection|

> [!warning] Clonage MAC Certains FAI lient l'accès Internet au MAC address de l'ancien routeur. Si vous remplacez un routeur existant, vous devrez peut-être cloner son adresse MAC dans le champ "MAC Address".

#### Options avancées WAN

```
Block private networks: ✓ Coché
Block bogon networks: ✓ Coché
```

> [!info] Sécurité WAN
> 
> - **Block private networks** : Empêche le trafic depuis les IP privées (RFC 1918) d'entrer par le WAN
> - **Block bogon networks** : Bloque les plages IP non allouées ou réservées par l'IANA

### Configuration de l'interface LAN

L'interface LAN connecte le réseau interne.

**Navigation :** `Interfaces > LAN`

|Paramètre|Valeur PME type|Explication|
|---|---|---|
|**Enable**|✓ Coché|Active l'interface|
|**IPv4 Configuration Type**|Static IPv4|IP fixe pour le firewall|
|**IPv4 Address**|192.168.1.1/24|Gateway du réseau interne|
|**IPv6 Configuration Type**|None|Simplifie la config initiale|

> [!example] Exemple de configuration LAN complète
> 
> ```
> Interface: LAN (em1)
> Enable interface: ✓
> IPv4 Configuration Type: Static IPv4
> IPv4 Address: 192.168.1.1 / 24
> 
> Description: Réseau Bureau Principal
> ```

### Vérification de la connectivité

Après configuration, vérifiez :

**Navigation :** `Diagnostics > Ping`

1. **Test WAN** : Pingez `8.8.8.8` depuis pfSense
2. **Test LAN** : Depuis un PC, pingez `192.168.1.1`

> [!tip] Dépannage connectivité
> 
> - Si le ping WAN échoue : vérifiez le câble, le modem, les paramètres DHCP WAN
> - Si le ping LAN échoue : vérifiez le câble, l'adresse IP du PC, le masque de sous-réseau

---

## 🛡️ Règles de pare-feu de base

### Philosophie des règles pfSense

pfSense applique un principe fondamental :

> [!info] Règle par défaut **Tout le trafic est bloqué par défaut**, sauf ce qui est explicitement autorisé par une règle.

Les règles sont évaluées :

- **De haut en bas** (première correspondance gagne)
- **Par interface** (WAN, LAN, etc.)
- **État par état** (stateful firewall : retours de connexion autorisés automatiquement)

### Configuration WAN - Blocage total

**Navigation :** `Firewall > Rules > WAN`

> [!warning] Sécurité WAN Par défaut, pfSense ne doit avoir AUCUNE règle "Allow" sur l'interface WAN pour une PME simple. Tout accès entrant depuis Internet est bloqué.

Configuration par défaut recommandée :

```
WAN Rules:
-----------
[Aucune règle] → Tout est bloqué (deny implicit)
```

> [!example] Pourquoi aucune règle WAN ? Une PME n'expose généralement aucun service vers Internet. Tous les accès se font de l'intérieur vers l'extérieur. Si vous devez exposer un service (serveur web, VPN), vous utiliserez le NAT Port Forward, traité dans d'autres parties du cours.

### Configuration LAN - Accès Internet

**Navigation :** `Firewall > Rules > LAN`

Règles de base pour permettre aux employés d'accéder à Internet :

#### Règle 1 : Anti-lockout (présente par défaut)

```
Action: Pass
Interface: LAN
Protocol: Any
Source: LAN net
Destination: LAN address
Description: Anti-Lockout Rule (accès WebGUI)
```

> [!info] Anti-lockout Cette règle empêche de se bloquer l'accès à l'interface web pfSense. Elle permet d'accéder à https://192.168.1.1 depuis le LAN.

#### Règle 2 : Accès Internet complet

```
Action: Pass
Interface: LAN
Protocol: Any
Source: LAN net
Destination: Any
Description: Autoriser LAN vers Internet
```

|Paramètre|Valeur|Signification|
|---|---|---|
|**Action**|Pass ✓|Autoriser le trafic|
|**Interface**|LAN|Règle sur le trafic LAN sortant|
|**Protocol**|Any|Tous les protocoles (TCP, UDP, ICMP, etc.)|
|**Source**|LAN net|Depuis n'importe quelle IP du réseau 192.168.1.0/24|
|**Destination**|Any|Vers n'importe quelle destination Internet|

> [!tip] Simplicité vs. Sécurité Cette règle "Any/Any" est simple mais permissive. Pour plus de sécurité, vous pourriez créer des règles spécifiques par service (HTTP/HTTPS, DNS, etc.), mais c'est généralement excessif pour une PME de 10-50 personnes.

#### Vue complète des règles LAN

```
LAN Rules (ordre d'évaluation):
--------------------------------
1. [Pass] Anti-Lockout Rule
   Protocol: Any | Source: LAN net | Dest: LAN address

2. [Pass] Autoriser LAN vers Internet  
   Protocol: Any | Source: LAN net | Dest: Any
```

### Test des règles

Depuis un PC du réseau LAN :

```bash
# Test navigation web
ping google.com

# Test résolution DNS
nslookup google.com

# Test accès pfSense
ping 192.168.1.1
```

> [!warning] Pièges courants
> 
> - **Règles dans le mauvais ordre** : Une règle "Block" placée avant une règle "Pass" bloquera le trafic
> - **Interface incorrecte** : Les règles LAN contrôlent le trafic sortant du LAN, pas entrant
> - **Oubli de Apply Changes** : Toujours cliquer sur "Apply Changes" après modification

### Logs et monitoring

**Navigation :** `Status > System Logs > Firewall`

Visualisez en temps réel les connexions bloquées ou autorisées :

```
Colonnes importantes:
- Act (Action): Pass ou Block
- Interface: WAN, LAN, etc.
- Source: IP source
- Destination: IP destination
- Proto: TCP, UDP, ICMP
```

> [!tip] Astuce de dépannage Ajoutez temporairement une règle "Log" sur les blocs pour identifier pourquoi un trafic légitime est refusé. Une fois le problème trouvé, créez la règle spécifique nécessaire.

---

## ⚙️ Services essentiels (DHCP, DNS)

### Service DHCP

Le serveur DHCP de pfSense attribue automatiquement les configurations IP aux postes de travail.

#### Configuration DHCP LAN

**Navigation :** `Services > DHCP Server > LAN`

| Paramètre              | Valeur PME type | Explication                        |
| ---------------------- | --------------- | ---------------------------------- |
| **Enable**             | ✓ Coché         | Active le serveur DHCP sur LAN     |
| **Range From**         | 192.168.1.100   | Début de la plage d'attribution    |
| **Range To**           | 192.168.1.254   | Fin de la plage d'attribution      |
| **DNS Servers**        | Vide            | pfSense s'auto-configure comme DNS |
| **Gateway**            | 192.168.1.1     | Gateway = pfSense                  |
| **Domain name**        | exemple.local   | Nom de domaine interne             |
| **Default lease time** | 7200 (2h)       | Durée de bail standard             |
| **Maximum lease time** | 86400 (24h)     | Durée maximale du bail             |

> [!example] Configuration DHCP complète
> 
> ```
> DHCP Server sur LAN:
> Enable: ✓
> Range: 192.168.1.100 - 192.168.1.254 (155 adresses)
> DNS Servers: [vide] → utilise 192.168.1.1
> Gateway: 192.168.1.1
> Domain: entreprise.local
> Lease time: 7200 secondes (2 heures)
> ```

#### Réservations DHCP statiques

Pour les équipements nécessitant une IP fixe (imprimantes, serveurs) :

**Navigation :** `Services > DHCP Server > LAN` → Onglet "DHCP Static Mappings"

```
Ajouter une réservation:
- MAC Address: 00:11:22:33:44:55
- IP Address: 192.168.1.50
- Hostname: imprimante-rh
- Description: Imprimante bureau RH
```

> [!tip] Bonnes pratiques réservations
> 
> - Réservez toujours les imprimantes réseau (évite les changements d'IP)
> - Réservez les serveurs (même si IP statique, c'est une documentation)
> - Documentez chaque réservation dans le champ "Description"

#### Vérification des baux DHCP

**Navigation :** `Status > DHCP Leases`

Vous verrez :

- **IP Address** : IP attribuée
- **MAC Address** : Adresse physique du client
- **Hostname** : Nom de l'ordinateur
- **Start/End** : Début et fin du bail
- **Online** : État de la connexion

> [!info] Utilité de cette page Identifiez rapidement quel appareil utilise quelle IP, utile pour le dépannage et la surveillance réseau.

### Service DNS Resolver

pfSense inclut Unbound, un résolveur DNS récursif qui traduit les noms de domaine en adresses IP.

#### Configuration DNS Resolver

**Navigation :** `Services > DNS Resolver`

|Paramètre|Valeur PME type|Explication|
|---|---|---|
|**Enable**|✓ Coché|Active Unbound|
|**Listen Port**|53|Port DNS standard|
|**Network Interfaces**|LAN|Écoute uniquement sur le LAN|
|**Outgoing Network Interfaces**|WAN|Requêtes DNS vers Internet via WAN|
|**DHCP Registration**|✓ Coché|Enregistre les noms DHCP dans le DNS|
|**Static DHCP**|✓ Coché|Enregistre les réservations statiques|
|**DNSSEC**|✓ Coché|Valide l'authenticité des réponses DNS|

> [!warning] DNS Resolver vs. DNS Forwarder pfSense propose deux options :
> 
> - **DNS Resolver (Unbound)** : Recommandé, résout directement depuis les serveurs racines
> - **DNS Forwarder (dnsmasq)** : Ancienne méthode, transfère vers des DNS tiers
> 
> Pour une PME, utilisez **DNS Resolver**.

#### Configuration avancée

Dans l'onglet "Advanced Settings" :

```
Query Forwarding: ☐ Désactivé (Unbound résout directement)
Use SSL/TLS for outgoing queries: ✓ Activé (DNS over TLS)
```

> [!tip] DNS over TLS Active "Use SSL/TLS for outgoing DNS queries" pour chiffrer les requêtes DNS vers Internet, améliorant la confidentialité.

#### Host Overrides (DNS local)

Pour créer des enregistrements DNS locaux personnalisés :

**Navigation :** `Services > DNS Resolver` → Onglet "Host Overrides"

```
Exemple - Serveur de fichiers:
Host: serveur
Domain: entreprise.local
IP Address: 192.168.1.10
Description: Serveur de fichiers principal

Résultat: serveur.entreprise.local → 192.168.1.10
```

> [!example] Cas d'usage Host Overrides
> 
> - Nommer le serveur de fichiers : `fichiers.entreprise.local`
> - Créer un alias pour l'interface web pfSense : `firewall.entreprise.local → 192.168.1.1`
> - Pointer vers une imprimante : `imprimante-compta.entreprise.local`

#### Domain Overrides (Redirection DNS)

Pour rediriger certains domaines vers des serveurs DNS spécifiques :

**Navigation :** `Services > DNS Resolver` → Onglet "Domain Overrides"

```
Exemple - Active Directory local:
Domain: ad.entreprise.local
IP Address: 192.168.1.20
Description: Serveur Active Directory

Résultat: Toutes les requêtes *.ad.entreprise.local → 192.168.1.20
```

> [!info] Quand utiliser Domain Overrides ? Si vous avez un serveur Active Directory ou un autre serveur DNS interne gérant un domaine spécifique, Domain Overrides redirige ces requêtes vers le bon serveur.

### Test des services DNS

Depuis un PC Windows :

```cmd
# Vérifier le serveur DNS configuré
ipconfig /all

# Tester la résolution
nslookup google.com
nslookup serveur.entreprise.local
```

Depuis un PC Linux :

```bash
# Vérifier le serveur DNS
cat /etc/resolv.conf

# Tester la résolution
dig google.com
dig serveur.entreprise.local
```

> [!tip] Vérification rapide Le serveur DNS doit être `192.168.1.1` (l'IP de pfSense). Si ce n'est pas le cas, le DHCP n'a pas correctement configuré le client.

### Logs DNS

**Navigation :** `Status > System Logs > System > DNS Resolver`

Surveillez :

- Les requêtes DNS effectuées
- Les erreurs de résolution
- Les requêtes bloquées (si blocklists activées)

---

## 🎯 Synthèse du scénario PME

### Configuration minimale fonctionnelle

```
1. WAN: DHCP (obtenu du FAI)
2. LAN: 192.168.1.1/24
3. DHCP: Pool 192.168.1.100-254
4. DNS Resolver: Activé sur LAN
5. Firewall LAN: Autoriser LAN net vers Any
6. Firewall WAN: Aucune règle (tout bloqué)
```

### Checklist de mise en service

- [ ] Interface WAN obtient une IP publique
- [ ] Interface LAN configurée en 192.168.1.1/24
- [ ] PC du LAN obtient une IP DHCP (192.168.1.100-254)
- [ ] PC peut pinguer 192.168.1.1 (pfSense)
- [ ] PC peut pinguer google.com (Internet)
- [ ] PC peut résoudre google.com (DNS)
- [ ] Accès WebGUI pfSense depuis https://192.168.1.1

> [!warning] Pièges courants de déploiement
> 
> - **Câbles inversés** : WAN branché sur LAN et vice-versa
> - **Double NAT** : Modem FAI en mode routeur ET pfSense en mode routeur (mettre le modem en mode bridge)
> - **Conflit d'adressage** : Réseau LAN pfSense identique au réseau du modem FAI (changer l'un des deux)
> - **DNS non fonctionnel** : DNS Resolver désactivé ou mal configuré

### Évolutions possibles

Cette configuration de base peut évoluer vers :

- **Segmentation réseau** : Ajouter un VLAN invités, un VLAN serveurs (traité dans d'autres parties)
- **VPN** : Accès distant pour les employés (traité dans d'autres parties)
- **Règles avancées** : Filtrage par URL, horaires, quotas (traité dans d'autres parties)
- **Haute disponibilité** : Cluster pfSense CARP (traité dans d'autres parties)

---

**Dernière mise à jour :** Janvier 2025  
**Version du cours :** 1.0