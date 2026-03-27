

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

## Introduction

La première configuration de NFTables consiste à créer une structure de base fonctionnelle : une table contenant des chaînes, elles-mêmes contenant des règles. Cette approche modulaire permet de construire progressivement un pare-feu efficace.

> [!info] Philosophie de NFTables NFTables suit une hiérarchie stricte : **Tables → Chaînes → Règles**. Contrairement à iptables, on commence toujours par créer explicitement ces conteneurs avant d'y ajouter des règles.

---

## Création d'une table

### Qu'est-ce qu'une table ?

Une table est le conteneur de plus haut niveau dans NFTables. Elle regroupe des chaînes qui traitent un type spécifique de trafic selon la famille d'adresses (IPv4, IPv6, etc.).

### Pourquoi créer une table ?

- **Organisation logique** : séparer les règles par fonction (filtrage, NAT, etc.)
- **Performance** : NFTables n'évalue que les tables pertinentes
- **Maintenance** : facilite la gestion et la suppression groupée de règles

### Syntaxe de base

```bash
# Syntaxe générale
nft add table [famille] [nom_table]

# Exemples pratiques
nft add table inet filter        # Table pour IPv4 et IPv6
nft add table ip filter          # Table uniquement IPv4
nft add table ip6 filter         # Table uniquement IPv6
nft add table netdev filtrage    # Table au niveau périphérique réseau
```

### Familles de tables disponibles

|Famille|Description|Usage typique|
|---|---|---|
|`inet`|IPv4 + IPv6 combinés|**Recommandé** pour la plupart des cas|
|`ip`|IPv4 uniquement|Règles spécifiques à IPv4|
|`ip6`|IPv6 uniquement|Règles spécifiques à IPv6|
|`arp`|Protocole ARP|Filtrage ARP (rare)|
|`bridge`|Trafic de pont|Pare-feu pour bridges réseau|
|`netdev`|Niveau interface|Filtrage très précoce (ingress/egress)|

> [!tip] Bonne pratique Utilisez `inet` pour simplifier vos règles : une seule table gérera IPv4 et IPv6 simultanément, évitant la duplication de configuration.

### Exemples complets

```bash
# Configuration minimale recommandée
nft add table inet mon_firewall

# Vérifier la création
nft list tables

# Afficher les détails d'une table
nft list table inet mon_firewall

# Supprimer une table (supprime aussi toutes ses chaînes et règles)
nft delete table inet mon_firewall
```

> [!warning] Attention La suppression d'une table efface **TOUTES** ses chaînes et règles sans confirmation. Sauvegardez votre configuration avant toute suppression.

---

## Création d'une chaîne

### Qu'est-ce qu'une chaîne ?

Une chaîne (chain) est un conteneur de règles au sein d'une table. Elle définit :

- **Où** les règles s'appliquent (hook point)
- **Quand** elles sont évaluées (priorité)
- **Que faire** si aucune règle ne correspond (policy)

### Types de chaînes

#### 1. Chaînes de base (base chains)

Attachées à un point d'accroche (hook) du noyau. Elles interceptent le trafic à des moments précis du traitement des paquets.

```bash
# Syntaxe
nft add chain [famille] [table] [nom_chain] '{ type [type] hook [hook] priority [priorité] ; policy [policy] ; }'

# Exemple : chaîne d'entrée
nft add chain inet filter input '{ type filter hook input priority 0 ; policy drop ; }'
```

**Paramètres essentiels :**

|Paramètre|Valeurs possibles|Description|
|---|---|---|
|`type`|filter, nat, route|Type de traitement|
|`hook`|prerouting, input, forward, output, postrouting|Point d'interception|
|`priority`|-300 à 300 (entier)|Ordre d'évaluation (plus bas = prioritaire)|
|`policy`|accept, drop|Action par défaut si aucune règle ne correspond|

#### 2. Chaînes régulières (regular chains)

Non attachées à un hook. Utilisées pour organiser des règles réutilisables, appelées depuis d'autres chaînes.

```bash
# Création d'une chaîne régulière
nft add chain inet filter services_tcp

# Pas de hook, ni de policy
```

### Points d'accroche (hooks) disponibles

```
                    ┌─────────────┐
                    │  Réseau     │
                    └──────┬──────┘
                           │
                    ┌──────▼───────┐
                    │  prerouting  │  ← Avant routage
                    └──────┬───────┘
                           │
                    ┌──────▼───────┐
                    │   Routage    │
                    └──┬───────┬───┘
                       │       │
            ┌──────────▼─┐   ┌─▼──────────┐
            │   input    │   │  forward   │
            └──────┬─────┘   └─────┬──────┘
                   │               │
            ┌──────▼─────┐   ┌─────▼──────┐
            │   Local    │   │  output    │
            │  Process   │   └─────┬──────┘
            └──────┬─────┘         │
                   │         ┌─────▼──────┐
                   └─────────►postrouting │  ← Après routage
                             └─────┬──────┘
                                   │
                             ┌─────▼──────┐
                             │   Réseau   │
                             └────────────┘
```

|Hook|Moment|Usage typique|
|---|---|---|
|`prerouting`|Avant décision de routage|DNAT, marquage de paquets|
|`input`|Vers processus local|**Filtrage entrant**|
|`forward`|Traversée du système|Filtrage pour routeur/firewall|
|`output`|Depuis processus local|**Filtrage sortant**|
|`postrouting`|Après routage|SNAT, masquerading|

### Exemples de chaînes courantes

```bash
# Chaîne INPUT : filtrage du trafic entrant
nft add chain inet filter input '{ type filter hook input priority 0 ; policy drop ; }'

# Chaîne OUTPUT : filtrage du trafic sortant
nft add chain inet filter output '{ type filter hook output priority 0 ; policy accept ; }'

# Chaîne FORWARD : filtrage du trafic traversant (routeur)
nft add chain inet filter forward '{ type filter hook forward priority 0 ; policy drop ; }'

# Chaîne régulière pour sous-règles
nft add chain inet filter tcp_services
```

> [!tip] Astuce : Priorités Les priorités courantes :
> 
> - `-300` à `-1` : traitement précoce (raw, connection tracking)
> - `0` : **filtrage standard** (valeur par défaut)
> - `1` à `300` : traitement tardif (NAT, mangling)

### Lister et supprimer des chaînes

```bash
# Lister toutes les chaînes d'une table
nft list table inet filter

# Lister une chaîne spécifique
nft list chain inet filter input

# Supprimer une chaîne (doit être vide)
nft delete chain inet filter tcp_services

# Vider une chaîne (supprimer toutes ses règles)
nft flush chain inet filter input
```

> [!warning] Suppression de chaîne Une chaîne ne peut être supprimée que si elle est vide. Utilisez `nft flush chain` avant `nft delete chain`.

---

## Ajout de règles simples

### Anatomie d'une règle NFTables

Une règle est composée de trois éléments :

1. **Critère de sélection** : quels paquets sont concernés
2. **Action** : que faire avec ces paquets
3. **Compteurs/logs** (optionnel) : suivi et journalisation

```bash
# Structure générale
nft add rule [famille] [table] [chaîne] [critères] [action]
```

### Actions disponibles

|Action|Description|Usage|
|---|---|---|
|`accept`|Accepter le paquet|Autoriser le trafic|
|`drop`|Rejeter silencieusement|Bloquer sans notification|
|`reject`|Rejeter avec notification|Bloquer en informant l'émetteur|
|`return`|Retourner à la chaîne appelante|Sortir d'une sous-chaîne|
|`jump [chaîne]`|Aller vers une autre chaîne|Organisation modulaire|
|`goto [chaîne]`|Aller sans retour possible|Optimisation|
|`counter`|Compter les paquets|Statistiques|
|`log`|Journaliser|Débogage et audit|

### Règles de base essentielles

#### 1. Autoriser le loopback

```bash
# Accepter tout le trafic sur l'interface locale
nft add rule inet filter input iif lo accept
```

> [!info] Pourquoi c'est crucial De nombreux services locaux communiquent via `lo` (localhost). Bloquer cette interface peut casser des applications.

#### 2. Autoriser les connexions établies

```bash
# Accepter les paquets des connexions déjà établies ou associées
nft add rule inet filter input ct state established,related accept
```

**États de connexion (conntrack) :**

- `new` : nouvelle connexion
- `established` : connexion établie
- `related` : lié à une connexion établie (ex: FTP data)
- `invalid` : paquet malformé ou non reconnu

> [!tip] Règle fondamentale Cette règle est **indispensable** dans presque tous les pare-feu : elle permet les réponses aux connexions initiées par le système.

#### 3. Autoriser des services spécifiques

```bash
# Autoriser SSH (port 22)
nft add rule inet filter input tcp dport 22 accept

# Autoriser HTTP et HTTPS
nft add rule inet filter input tcp dport { 80, 443 } accept

# Autoriser ping (ICMP echo request)
nft add rule inet filter input icmp type echo-request accept
nft add rule inet filter input icmpv6 type echo-request accept
```

#### 4. Règles de logging et comptage

```bash
# Logger les paquets bloqués avant la policy drop
nft add rule inet filter input counter log prefix \"INPUT DROP: \" drop

# Compter le trafic SSH
nft add rule inet filter input tcp dport 22 counter accept
```

### Exemple complet : configuration minimale fonctionnelle

```bash
# 1. Créer la table
nft add table inet filter

# 2. Créer la chaîne INPUT avec policy drop
nft add chain inet filter input '{ type filter hook input priority 0 ; policy drop ; }'

# 3. Règles essentielles
nft add rule inet filter input iif lo accept
nft add rule inet filter input ct state established,related accept
nft add rule inet filter input ct state invalid drop

# 4. Autoriser SSH
nft add rule inet filter input tcp dport 22 ct state new accept

# 5. Autoriser ping
nft add rule inet filter input icmp type echo-request limit rate 5/second accept

# 6. Logger les paquets rejetés
nft add rule inet filter input counter log prefix \"Blocked: \"
```

> [!example] Explication Cette configuration :
> 
> - Accepte le trafic local (loopback)
> - Permet les réponses aux connexions établies
> - Autorise SSH pour l'administration
> - Limite le ping à 5 par seconde (anti-flood)
> - Logue tout ce qui sera bloqué par la policy drop

### Gestion des règles

```bash
# Lister les règles avec leurs handles (identifiants)
nft -a list chain inet filter input

# Insérer une règle à une position spécifique (début)
nft insert rule inet filter input position 0 ip saddr 192.168.1.0/24 accept

# Supprimer une règle par son handle
nft delete rule inet filter input handle 5

# Vider toutes les règles d'une chaîne
nft flush chain inet filter input
```

> [!warning] Ordre des règles L'ordre est **critique** ! NFTables évalue les règles de haut en bas et s'arrête à la première correspondance avec une action terminale (accept/drop/reject).

### Syntaxe avancée des critères

```bash
# Source et destination
nft add rule inet filter input ip saddr 192.168.1.100 accept
nft add rule inet filter output ip daddr 8.8.8.8 accept

# Interfaces réseau
nft add rule inet filter input iifname "eth0" accept
nft add rule inet filter output oifname "wlan0" accept

# Plages de ports
nft add rule inet filter input tcp dport 1000-2000 drop

# Protocoles multiples
nft add rule inet filter input meta l4proto { tcp, udp } accept

# Combinaisons
nft add rule inet filter input ip saddr 10.0.0.0/8 tcp dport 22 accept
```

---

## Activation au démarrage

### Pourquoi sauvegarder la configuration ?

Par défaut, les règles NFTables ajoutées avec `nft` sont **volatiles** : elles disparaissent au redémarrage. Il faut donc les rendre persistantes.

### Méthode 1 : Fichier de configuration système

La méthode standard et recommandée sur la plupart des distributions Linux.

#### Sauvegarder la configuration actuelle

```bash
# Exporter toute la configuration dans un fichier
nft list ruleset > /etc/nftables.conf

# Ou avec sudo si nécessaire
sudo nft list ruleset | sudo tee /etc/nftables.conf
```

#### Structure du fichier `/etc/nftables.conf`

```bash
#!/usr/sbin/nft -f

# Vider toute configuration précédente
flush ruleset

# Définir la table
table inet filter {
    # Définir la chaîne input
    chain input {
        type filter hook input priority 0; policy drop;
        
        # Règles
        iif lo accept
        ct state established,related accept
        tcp dport 22 accept
        counter log prefix "INPUT DROP: "
    }
}
```

> [!tip] Format du fichier Le fichier utilise une syntaxe déclarative plus lisible que les commandes `nft add`. C'est le format préféré pour la maintenance.

#### Activer au démarrage

**Sur Debian/Ubuntu :**

```bash
# Activer le service nftables
sudo systemctl enable nftables.service

# Démarrer immédiatement
sudo systemctl start nftables.service

# Vérifier le statut
sudo systemctl status nftables.service
```

**Sur Arch Linux :**

```bash
# Même procédure
sudo systemctl enable nftables.service
sudo systemctl start nftables.service
```

**Sur Red Hat/CentOS/Fedora :**

```bash
# Le service peut s'appeler nftables ou firewalld (qui utilise nftables)
sudo systemctl enable nftables
sudo systemctl start nftables
```

### Méthode 2 : Rechargement manuel depuis un fichier

```bash
# Charger un fichier de configuration
sudo nft -f /etc/nftables.conf

# Charger et vérifier la syntaxe sans appliquer
sudo nft -c -f /etc/nftables.conf
```

> [!warning] Option -c L'option `-c` (check) vérifie la syntaxe sans l'appliquer. **Toujours vérifier** avant de charger une nouvelle configuration sur un serveur distant !

### Méthode 3 : Script personnalisé

Pour des configurations complexes ou des besoins spécifiques.

```bash
#!/bin/bash
# /usr/local/bin/firewall-init.sh

# Vider la configuration
nft flush ruleset

# Charger depuis un fichier
nft -f /etc/nftables.conf

echo "Firewall NFTables activé"
```

Rendre le script exécutable et l'ajouter au démarrage :

```bash
sudo chmod +x /usr/local/bin/firewall-init.sh

# Créer un service systemd
sudo nano /etc/systemd/system/mon-firewall.service
```

Contenu du service :

```ini
[Unit]
Description=Mon firewall NFTables personnalisé
After=network.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/firewall-init.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

Activer le service :

```bash
sudo systemctl daemon-reload
sudo systemctl enable mon-firewall.service
sudo systemctl start mon-firewall.service
```

### Tester la persistance

```bash
# 1. Configurer vos règles
nft add table inet filter
nft add chain inet filter input '{ type filter hook input priority 0 ; policy drop ; }'
nft add rule inet filter input iif lo accept

# 2. Sauvegarder
sudo nft list ruleset > /etc/nftables.conf

# 3. Vider pour tester
sudo nft flush ruleset

# 4. Recharger
sudo nft -f /etc/nftables.conf

# 5. Vérifier
nft list ruleset
```

### Gestion des mises à jour

```bash
# Sauvegarder l'ancienne configuration
sudo cp /etc/nftables.conf /etc/nftables.conf.bak

# Modifier la configuration
sudo nano /etc/nftables.conf

# Tester la syntaxe
sudo nft -c -f /etc/nftables.conf

# Si OK, appliquer
sudo nft -f /etc/nftables.conf

# Sauvegarder dans systemd si tout fonctionne
sudo systemctl restart nftables.service
```

> [!tip] Bonnes pratiques de sauvegarde
> 
> - Versionnez `/etc/nftables.conf` avec Git
> - Gardez toujours une sauvegarde avant modification
> - Testez d'abord sur une machine non critique
> - Documentez vos règles avec des commentaires

---

## Pièges courants

### 1. Oublier la règle loopback

```bash
# ❌ ERREUR : sans règle loopback avec policy drop
nft add chain inet filter input '{ type filter hook input priority 0 ; policy drop ; }'
nft add rule inet filter input tcp dport 22 accept

# Conséquence : les applications locales ne peuvent plus communiquer
```

```bash
# ✅ CORRECT
nft add rule inet filter input iif lo accept  # TOUJOURS en premier !
nft add rule inet filter input tcp dport 22 accept
```

### 2. Bloquer ses propres connexions SSH

```bash
# ❌ ERREUR : policy drop sans autoriser les connexions établies
nft add chain inet filter input '{ type filter hook input priority 0 ; policy drop ; }'
nft add rule inet filter input tcp dport 22 accept

# Conséquence : la connexion SSH initiale fonctionne, mais se coupe après
```

```bash
# ✅ CORRECT
nft add rule inet filter input ct state established,related accept
nft add rule inet filter input tcp dport 22 ct state new accept
```

> [!warning] Serveur distant Sur un serveur accessible uniquement via SSH, **TOUJOURS** tester localement d'abord ou garder une session SSH ouverte avant d'appliquer de nouvelles règles !

### 3. Ordre incorrect des règles

```bash
# ❌ ERREUR : règle trop générale en premier
nft add rule inet filter input drop           # Bloque TOUT
nft add rule inet filter input tcp dport 22 accept  # Jamais atteint !
```

```bash
# ✅ CORRECT : règles spécifiques avant la policy/règle générale
nft add rule inet filter input tcp dport 22 accept
# La policy drop en fin de chaîne s'occupera du reste
```

### 4. Oublier IPv6

```bash
# ❌ ERREUR : uniquement IPv4
nft add table ip filter  # Seulement IPv4
nft add rule ip filter input tcp dport 22 accept

# Conséquence : SSH fonctionne en IPv4 mais pas en IPv6
```

```bash
# ✅ CORRECT : utiliser inet pour les deux
nft add table inet filter  # IPv4 ET IPv6
nft add rule inet filter input tcp dport 22 accept
```

### 5. Ne pas valider la syntaxe avant application

```bash
# ❌ ERREUR : charger directement
sudo nft -f /etc/nftables.conf  # Erreur = configuration cassée

# ✅ CORRECT : toujours vérifier d'abord
sudo nft -c -f /etc/nftables.conf  # Vérifier
sudo nft -f /etc/nftables.conf     # Appliquer si OK
```

### 6. Confusion entre insert et add

```bash
# add : ajoute à la FIN
nft add rule inet filter input tcp dport 80 accept

# insert : ajoute au DÉBUT
nft insert rule inet filter input tcp dport 443 accept

# Résultat : la règle 443 est évaluée avant la règle 80
```

### 7. Oublier de sauvegarder

```bash
# ❌ Modifications volatiles
nft add rule inet filter input tcp dport 80 accept
# Après redémarrage : règle perdue !

# ✅ Toujours sauvegarder
sudo nft list ruleset > /etc/nftables.conf
sudo systemctl restart nftables.service
```

### 8. Policy accept avec des règles drop

```bash
# ⚠️ Configuration incohérente
nft add chain inet filter input '{ type filter hook input priority 0 ; policy accept ; }'
nft add rule inet filter input tcp dport 23 drop

# Conséquence : le port 23 est bloqué, mais TOUT le reste passe
# Plus sûr d'inverser la logique avec policy drop
```

> [!tip] Principe de sécurité **Whitelist > Blacklist** : préférez `policy drop` + règles `accept` plutôt que `policy accept` + règles `drop`.

---

## 🎓 Récapitulatif

Vous savez maintenant :

✅ Créer une table pour organiser vos règles  
✅ Créer des chaînes de base attachées aux hooks du noyau  
✅ Ajouter des règles simples de filtrage  
✅ Rendre votre configuration persistante au redémarrage  
✅ Éviter les pièges courants qui cassent la connectivité

Cette base solide vous permet de déployer un pare-feu fonctionnel sur n'importe quel système Linux moderne.

---

_Configuration NFTables maîtrisée ! 🚀_