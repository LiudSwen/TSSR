

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

Les **chaînes** (chains) sont des conteneurs organisationnels qui regroupent des règles de filtrage. Elles permettent de structurer logiquement votre configuration de pare-feu et déterminent à quel moment du traitement des paquets vos règles seront appliquées.

> [!info] Pourquoi utiliser des chaînes ? Les chaînes permettent de :
> 
> - Organiser vos règles de manière logique et modulaire
> - Définir où dans le flux réseau vos règles s'appliquent
> - Créer des sous-ensembles de règles réutilisables
> - Améliorer la lisibilité et la maintenabilité de votre configuration

---

## Chaînes de base (base chains)

Les **chaînes de base** sont directement attachées à un **hook** du système de filtrage réseau. Elles constituent les points d'entrée où les paquets réseau sont interceptés et traités.

### 🔧 Caractéristiques

- Connectées à un hook spécifique du netfilter
- Possèdent un type (filter, nat, route)
- Ont une priorité définie
- Définissent une politique par défaut (policy)

### Syntaxe de création

```bash
# Structure générale
nft add chain [famille] [table] [nom_chaîne] { \
    type [type] hook [hook] priority [priorité] \; \
    policy [policy] \; \
}
```

### 📝 Exemple pratique

```bash
# Création d'une chaîne de base pour filtrer les paquets entrants
nft add chain inet filter input { \
    type filter hook input priority 0 \; \
    policy drop \; \
}

# Création d'une chaîne de base pour le NAT sortant
nft add chain inet nat postrouting { \
    type nat hook postrouting priority 100 \; \
}
```

> [!example] Décryptage de la syntaxe
> 
> - `inet filter input` : famille inet, table filter, nom de chaîne "input"
> - `type filter` : type de chaîne pour le filtrage
> - `hook input` : attachée au hook input (paquets entrants)
> - `priority 0` : priorité d'exécution
> - `policy drop` : politique par défaut (bloquer si aucune règle ne correspond)
> - Le `\;` échappe le point-virgule pour le shell

### 📊 Tableau des composants obligatoires

|Composant|Obligatoire|Description|
|---|---|---|
|`type`|✅ Oui|Définit le type de traitement|
|`hook`|✅ Oui|Point d'accroche dans le flux réseau|
|`priority`|✅ Oui|Ordre d'exécution|
|`policy`|❌ Non|Politique par défaut (défaut: accept)|

---

## Chaînes utilisateur (regular chains)

Les **chaînes utilisateur** (ou chaînes régulières) ne sont pas directement attachées à un hook. Elles servent à organiser et modulariser vos règles.

### 🔧 Caractéristiques

- Non attachées à un hook
- Appelées depuis d'autres chaînes via `jump` ou `goto`
- Permettent de factoriser des règles communes
- Plus simple à créer (pas de type, hook, ou priorité)

### Syntaxe de création

```bash
# Structure simple
nft add chain [famille] [table] [nom_chaîne]
```

### 📝 Exemples pratiques

```bash
# Création d'une chaîne utilisateur pour les règles SSH
nft add chain inet filter check_ssh

# Ajout de règles dans cette chaîne
nft add rule inet filter check_ssh tcp dport 22 limit rate 3/minute accept
nft add rule inet filter check_ssh drop

# Appel de cette chaîne depuis la chaîne input
nft add rule inet filter input tcp dport 22 jump check_ssh
```

> [!tip] Utilisation intelligente des chaînes utilisateur Créez des chaînes utilisateur pour :
> 
> - Regrouper les règles par service (web, ssh, dns)
> - Factoriser les règles de protection communes
> - Simplifier la maintenance (modification en un seul endroit)

### Différence entre jump et goto

```bash
# jump : retourne à la chaîne appelante après traitement
nft add rule inet filter input tcp dport 80 jump web_rules

# goto : ne retourne PAS à la chaîne appelante
nft add rule inet filter input tcp dport 443 goto https_rules
```

> [!warning] Attention avec goto Avec `goto`, le traitement ne revient jamais à la chaîne d'origine. Utilisez `jump` sauf si vous avez une raison spécifique d'utiliser `goto`.

---

## Types de chaînes

Le **type** d'une chaîne de base définit le traitement qui sera effectué sur les paquets. Chaque type a un usage spécifique.

### 📋 Liste des types disponibles

|Type|Usage|Hooks compatibles|
|---|---|---|
|`filter`|Filtrage de paquets (accept/drop)|Tous|
|`nat`|Translation d'adresses (NAT)|prerouting, input, output, postrouting|
|`route`|Modification des décisions de routage|output|

### 🎯 Type filter

Le type le plus courant pour le filtrage standard.

```bash
# Chaîne pour filtrer le trafic entrant
nft add chain inet filter input { \
    type filter hook input priority 0 \; \
    policy drop \; \
}

# Chaîne pour filtrer le trafic transféré
nft add chain inet filter forward { \
    type filter hook forward priority 0 \; \
    policy drop \; \
}
```

> [!info] Quand utiliser filter Utilisez `filter` pour toutes vos règles de pare-feu classiques : autoriser ou bloquer du trafic basé sur des critères comme les ports, adresses IP, protocoles, etc.

### 🔄 Type nat

Utilisé pour modifier les adresses IP ou ports des paquets.

```bash
# Chaîne pour le NAT sortant (masquerading)
nft add chain inet nat postrouting { \
    type nat hook postrouting priority 100 \; \
}

# Chaîne pour le NAT entrant (port forwarding)
nft add chain inet nat prerouting { \
    type nat hook prerouting priority -100 \; \
}
```

> [!info] Quand utiliser nat Le type `nat` sera abordé en détail dans la Partie 7. Retenez simplement qu'il sert à modifier les adresses source ou destination des paquets.

### 🛣️ Type route

Permet de modifier les décisions de routage basées sur le marquage de paquets.

```bash
# Chaîne pour le routage basé sur des règles
nft add chain inet filter output { \
    type route hook output priority 0 \; \
}
```

> [!info] Utilisation avancée Le type `route` est rarement utilisé et concerne des scénarios avancés de routage par politique. La plupart des configurations n'en ont pas besoin.

---

## Hooks disponibles

Les **hooks** représentent les différents points d'interception des paquets dans leur parcours à travers le système.

### 🗺️ Vue d'ensemble du flux réseau

```
Internet
   │
   ↓
[prerouting] ──→ Décision de routage
   │                     │
   │                     ↓
   │              Est-ce pour nous ?
   │                     │
   ├─────────────────────┼───────────────────┐
   │ OUI                 │                   │ NON
   ↓                     ↓                   ↓
[input]            [forward]          [output]
   │                     │                   │
   ↓                     ↓                   ↓
Application      [postrouting]        [postrouting]
                        │                   │
                        └───────┬───────────┘
                                ↓
                            Internet
```

### 📋 Description détaillée des hooks

#### 🔵 prerouting

Premier point de traitement, avant toute décision de routage.

```bash
nft add chain inet nat prerouting { \
    type nat hook prerouting priority -100 \; \
}
```

**Utilisation typique :**

- DNAT (Destination NAT / redirection de ports)
- Marquage de paquets pour le routage par politique
- Modification d'en-têtes avant routage

> [!example] Cas pratique Rediriger le trafic du port 80 vers un serveur web interne avant que le système ne décide comment router le paquet.

---

#### 🟢 input

Traitement des paquets destinés à la machine locale.

```bash
nft add chain inet filter input { \
    type filter hook input priority 0 \; \
    policy drop \; \
}
```

**Utilisation typique :**

- Filtrage du trafic entrant vers les services locaux
- Protection du serveur lui-même
- Règles de pare-feu pour SSH, HTTP, etc.

> [!tip] Hook le plus utilisé C'est le hook que vous utiliserez le plus souvent pour protéger un serveur : il contrôle tout ce qui tente d'accéder aux services locaux.

---

#### 🟡 forward

Traitement des paquets qui transitent par la machine (routage).

```bash
nft add chain inet filter forward { \
    type filter hook forward priority 0 \; \
    policy drop \; \
}
```

**Utilisation typique :**

- Filtrage du trafic entre deux réseaux
- Pare-feu/routeur pour protéger un réseau interne
- Contrôle d'accès entre VLANs

> [!info] Activation du forwarding Pour que le hook `forward` soit actif, vous devez activer l'IP forwarding au niveau système (ce sera abordé dans la Partie 9).

---

#### 🟠 output

Traitement des paquets générés par la machine locale.

```bash
nft add chain inet filter output { \
    type filter hook output priority 0 \; \
    policy accept \; \
}
```

**Utilisation typique :**

- Filtrage du trafic sortant depuis le serveur
- Restriction des communications sortantes
- Marquage pour le routage avancé

> [!tip] Policy accept recommandée Contrairement à `input`, on utilise généralement `policy accept` pour `output` afin de ne pas bloquer les communications sortantes du système lui-même.

---

#### 🔴 postrouting

Dernier point de traitement, après la décision de routage.

```bash
nft add chain inet nat postrouting { \
    type nat hook postrouting priority 100 \; \
}
```

**Utilisation typique :**

- SNAT (Source NAT / masquerading)
- Modification d'adresses source pour partage de connexion
- Dernières modifications avant sortie sur le réseau

> [!example] Cas pratique Masquerading pour permettre à un réseau interne (192.168.1.0/24) de partager une connexion Internet via une IP publique unique.

---

### 📊 Tableau récapitulatif des hooks

|Hook|Moment|Types compatibles|Usage principal|
|---|---|---|---|
|`prerouting`|Avant routage|nat, filter|DNAT, redirection|
|`input`|Vers système local|filter, nat|Filtrage entrant|
|`forward`|Trafic transféré|filter|Routeur/passerelle|
|`output`|Depuis système local|filter, nat, route|Filtrage sortant|
|`postrouting`|Après routage|nat, filter|SNAT, masquerading|

---

## Priorités des chaînes

La **priorité** détermine l'ordre d'exécution des chaînes lorsque plusieurs chaînes sont attachées au même hook.

### 🔢 Principe des priorités

- Valeur numérique (peut être négative)
- Plus la valeur est **basse**, plus la priorité est **haute**
- Les chaînes sont exécutées par ordre croissant de priorité

```
priority -300  ──→  Exécutée en premier
priority -100
priority 0
priority 50
priority 100   ──→  Exécutée en dernier
```

### 📋 Valeurs standard recommandées

|Valeur|Usage typique|
|---|---|
|`-400`|Connexion tracking (très prioritaire)|
|`-300`|DNAT (redirection de ports)|
|`-225`|SELinux|
|`-200`|Mangle (modification d'en-têtes)|
|`-100`|NAT prerouting|
|`0`|**Filtrage standard** (valeur par défaut)|
|`50`|Filtrage personnalisé|
|`100`|NAT postrouting|
|`225`|SELinux|
|`300`|Connexion tracking (suivi sortant)|

### 📝 Exemples d'utilisation

```bash
# Chaîne de connexion tracking (très prioritaire)
nft add chain inet filter prerouting { \
    type filter hook prerouting priority -400 \; \
}

# Chaîne de filtrage standard
nft add chain inet filter input { \
    type filter hook input priority 0 \; \
    policy drop \; \
}

# Chaîne de NAT (après le filtrage)
nft add chain inet nat postrouting { \
    type nat hook postrouting priority 100 \; \
}
```

> [!tip] Conseil de priorité Pour la plupart des configurations simples, utilisez :
> 
> - `-100` pour le NAT prerouting (DNAT)
> - `0` pour le filtrage
> - `100` pour le NAT postrouting (SNAT)

### 🎯 Cas d'usage : Plusieurs chaînes sur le même hook

```bash
# Chaîne de logging (priorité haute pour tout loguer)
nft add chain inet filter input_log { \
    type filter hook input priority -10 \; \
}
nft add rule inet filter input_log log prefix \"[INPUT] \"

# Chaîne de filtrage principale
nft add chain inet filter input { \
    type filter hook input priority 0 \; \
    policy drop \; \
}
```

> [!example] Ordre d'exécution Avec cette configuration, les paquets passent d'abord par `input_log` (priorité -10) pour être journalisés, puis par `input` (priorité 0) pour être filtrés.

---

## Pièges courants

> [!warning] Oublier le type, hook ou priorité pour une chaîne de base
> 
> ```bash
> # ❌ ERREUR : chaîne de base incomplète
> nft add chain inet filter input
> 
> # ✅ CORRECT : tous les paramètres requis
> nft add chain inet filter input { \
>     type filter hook input priority 0 \; \
>     policy drop \; \
> }
> ```

> [!warning] Utiliser goto au lieu de jump sans raison
> 
> ```bash
> # ⚠️ ATTENTION : pas de retour possible
> nft add rule inet filter input tcp dport 22 goto check_ssh
> 
> # ✅ PRÉFÉRABLE : retour à la chaîne appelante
> nft add rule inet filter input tcp dport 22 jump check_ssh
> ```

> [!warning] Mauvaise priorité pour le NAT
> 
> ```bash
> # ❌ ERREUR : NAT après filtrage (priorité trop haute)
> nft add chain inet nat prerouting { \
>     type nat hook prerouting priority 100 \; \
> }
> 
> # ✅ CORRECT : NAT avant filtrage
> nft add chain inet nat prerouting { \
>     type nat hook prerouting priority -100 \; \
> }
> ```

> [!warning] Oublier d'activer l'IP forwarding pour le hook forward Même avec une chaîne `forward` correctement configurée, les paquets ne seront pas transférés si l'IP forwarding n'est pas activé au niveau système.

> [!warning] Policy drop sur output sans règles d'autorisation
> 
> ```bash
> # ⚠️ DANGER : risque de se bloquer soi-même
> nft add chain inet filter output { \
>     type filter hook output priority 0 \; \
>     policy drop \; \
> }
> # Sans règles d'autorisation, le système ne pourra plus rien faire !
> ```

---

## Bonnes pratiques

### ✅ Organisation par chaînes utilisateur

```bash
# Créer des chaînes thématiques
nft add chain inet filter check_web
nft add chain inet filter check_ssh
nft add chain inet filter check_dns

# Les appeler depuis la chaîne principale
nft add rule inet filter input tcp dport { 80, 443 } jump check_web
nft add rule inet filter input tcp dport 22 jump check_ssh
nft add rule inet filter input udp dport 53 jump check_dns
```

### ✅ Nommage cohérent

Adoptez une convention de nommage claire :

- Chaînes de base : noms simples (`input`, `forward`, `output`)
- Chaînes utilisateur : noms descriptifs (`check_web`, `accept_ssh`, `log_scan`)

### ✅ Commentaires et documentation

```bash
# Utiliser des commentaires pour documenter la fonction des chaînes
nft add chain inet filter input { \
    type filter hook input priority 0 \; \
    policy drop \; comment \"Filtrage du trafic entrant vers le serveur\" \; \
}
```

### ✅ Séparation des responsabilités

```bash
# Une table pour le filtrage
nft add table inet filter

# Une table séparée pour le NAT
nft add table inet nat
```

> [!tip] Modularité Plus vos chaînes sont spécialisées et modulaires, plus votre configuration sera :
> 
> - Facile à comprendre
> - Simple à maintenir
> - Moins sujette aux erreurs

### ✅ Ordre logique des chaînes

Organisez vos chaînes dans un ordre logique qui reflète le flux du trafic :

1. Connexion tracking (si utilisé)
2. NAT prerouting (DNAT)
3. Filtrage input/forward/output
4. NAT postrouting (SNAT)

---

## 🎓 Points clés à retenir

|Concept|Point essentiel|
|---|---|
|**Chaînes de base**|Attachées à un hook, nécessitent type/hook/priorité|
|**Chaînes utilisateur**|Non attachées, utilisées via jump/goto|
|**Types**|filter (filtrage), nat (NAT), route (routage)|
|**Hooks**|prerouting, input, forward, output, postrouting|
|**Priorités**|Valeur basse = haute priorité, 0 = standard|
|**Jump vs Goto**|jump retourne, goto ne retourne pas|

---