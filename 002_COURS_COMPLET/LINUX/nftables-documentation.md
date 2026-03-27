# Documentation NFtables - Guide Complet

**Filtrage réseau et pare-feu avec Netfilter et NFtables**

---

## 📑 Sommaire

1. [Introduction à NFtables](#1-introduction-à-nftables)
   - 1.1 [Qu'est-ce que NFtables ?](#11-quest-ce-que-nftables-)
   - 1.2 [NFtables vs IPtables](#12-nftables-vs-iptables)
   - 1.3 [Installation](#13-installation)

2. [Architecture et Fonctionnement](#2-architecture-et-fonctionnement)
   - 2.1 [Le framework Netfilter](#21-le-framework-netfilter)
   - 2.2 [Les hooks Netfilter](#22-les-hooks-netfilter)
   - 2.3 [Flux de traitement des paquets](#23-flux-de-traitement-des-paquets)

3. [Concepts Fondamentaux](#3-concepts-fondamentaux)
   - 3.1 [Les Tables](#31-les-tables)
   - 3.2 [Les Chaînes (Chains)](#32-les-chaînes-chains)
   - 3.3 [Les Règles](#33-les-règles)
   - 3.4 [Hiérarchie : Tables → Chaînes → Règles](#34-hiérarchie--tables--chaînes--règles)

4. [Syntaxe et Commandes de Base](#4-syntaxe-et-commandes-de-base)
   - 4.1 [Gestion des tables](#41-gestion-des-tables)
   - 4.2 [Gestion des chaînes](#42-gestion-des-chaînes)
   - 4.3 [Gestion des règles](#43-gestion-des-règles)
   - 4.4 [Affichage et listage](#44-affichage-et-listage)

5. [Critères de Filtrage](#5-critères-de-filtrage)
   - 5.1 [Critères IP](#51-critères-ip)
   - 5.2 [Critères réseau](#52-critères-réseau)
   - 5.3 [Critères de protocole](#53-critères-de-protocole)
   - 5.4 [Interfaces réseau](#54-interfaces-réseau)

6. [Actions et Verdicts](#6-actions-et-verdicts)
   - 6.1 [Verdicts de base](#61-verdicts-de-base)
   - 6.2 [Actions multiples](#62-actions-multiples)
   - 6.3 [Logging](#63-logging)

7. [Gestion des Flags TCP](#7-gestion-des-flags-tcp)
   - 7.1 [Les flags TCP](#71-les-flags-tcp)
   - 7.2 [Filtrage des flags](#72-filtrage-des-flags)
   - 7.3 [Protection contre les scans](#73-protection-contre-les-scans)

8. [Gestion de l'ICMP](#8-gestion-de-licmp)
   - 8.1 [Types ICMP courants](#81-types-icmp-courants)
   - 8.2 [Filtrage ICMP](#82-filtrage-icmp)

9. [Connection Tracking (conntrack)](#9-connection-tracking-conntrack)
   - 9.1 [États de connexion](#91-états-de-connexion)
   - 9.2 [Utilisation du conntrack](#92-utilisation-du-conntrack)
   - 9.3 [Filtrage stateful](#93-filtrage-stateful)

10. [NAT (Network Address Translation)](#10-nat-network-address-translation)
    - 10.1 [Source NAT (SNAT)](#101-source-nat-snat)
    - 10.2 [Destination NAT (DNAT)](#102-destination-nat-dnat)
    - 10.3 [Masquerading](#103-masquerading)
    - 10.4 [Redirection de ports](#104-redirection-de-ports)

11. [Gestion Avancée](#11-gestion-avancée)
    - 11.1 [Sets et Maps](#111-sets-et-maps)
    - 11.2 [Sauvegarde et restauration](#112-sauvegarde-et-restauration)
    - 11.3 [Fichiers de configuration](#113-fichiers-de-configuration)
    - 11.4 [Modes d'édition](#114-modes-dédition)

12. [Cas Pratiques](#12-cas-pratiques)
    - 12.1 [Protection d'un serveur web](#121-protection-dun-serveur-web)
    - 12.2 [Routeur avec NAT](#122-routeur-avec-nat)
    - 12.3 [Pare-feu complet](#123-pare-feu-complet)

13. [Migration d'IPtables vers NFtables](#13-migration-diptables-vers-nftables)
    - 13.1 [Outils de conversion](#131-outils-de-conversion)
    - 13.2 [Équivalences de commandes](#132-équivalences-de-commandes)

14. [Annexes](#14-annexes)
    - 14.1 [Commandes essentielles](#141-commandes-essentielles)
    - 14.2 [Exemples de règles courantes](#142-exemples-de-règles-courantes)
    - 14.3 [Dépannage](#143-dépannage)

---

## 1. Introduction à NFtables

### 1.1 Qu'est-ce que NFtables ?

**NFtables** est le successeur d'IPtables pour la gestion du pare-feu sous Linux. C'est un framework moderne qui s'appuie sur **Netfilter**, le système de filtrage réseau intégré au noyau Linux.

**Points clés :**
- Introduit dans le noyau Linux 3.13 (2014)
- Destiné à remplacer IPtables, IP6tables, Arptables et Ebtables
- Syntaxe plus cohérente et lisible
- Performances améliorées
- Configuration centralisée

### 1.2 NFtables vs IPtables

| Caractéristique | IPtables | NFtables |
|----------------|----------|----------|
| **Syntaxe** | Complexe, variable | Unifiée, claire |
| **Performance** | Bonne | Meilleure (règles compilées) |
| **IPv4/IPv6** | Outils séparés | Un seul outil |
| **Tables prédéfinies** | Oui (filter, nat, mangle) | Non (flexibilité totale) |
| **Modification atomique** | Non | Oui |
| **Sets/Maps** | Limité | Natif et puissant |

### 1.3 Installation

#### Sur Debian/Ubuntu :
```bash
# Installation
sudo apt update
sudo apt install nftables

# Activation du service
sudo systemctl enable nftables
sudo systemctl start nftables

# Vérification
nft --version
```

#### Sur Red Hat/CentOS :
```bash
sudo dnf install nftables
sudo systemctl enable nftables
sudo systemctl start nftables
```

---

## 2. Architecture et Fonctionnement

### 2.1 Le framework Netfilter

**Netfilter** est un framework intégré au noyau Linux qui permet de :
- Filtrer les paquets réseau
- Modifier les paquets (NAT, mangling)
- Tracer les connexions
- Gérer la qualité de service (QoS)

NFtables est l'interface utilisateur moderne pour interagir avec Netfilter.

### 2.2 Les hooks Netfilter

Netfilter intercepte les paquets à différents points de leur trajet dans le système. Ces points sont appelés **hooks** :

```
┌─────────────┐
│  PREROUTING │  ← Paquet entrant (avant routage)
└──────┬──────┘
       │
       ├──→ Vers le système local
       │         ┌───────┐
       │         │ INPUT │  ← Destination : machine locale
       │         └───────┘
       │
       └──→ Routage/Forwarding
                 ┌─────────┐
                 │ FORWARD │  ← Paquet transité (routage)
                 └────┬────┘
                      │
    ┌────────┐        │
    │ OUTPUT │  ←─────┴──── Paquet sortant (généré localement)
    └────┬───┘
         │
         ▼
   ┌─────────────┐
   │ POSTROUTING │  ← Après routage (avant sortie interface)
   └─────────────┘
```

**Les 5 hooks Netfilter :**

1. **PREROUTING** : Premier point de contact pour les paquets entrants
2. **INPUT** : Paquets destinés à la machine locale
3. **FORWARD** : Paquets transitant par la machine (routage)
4. **OUTPUT** : Paquets générés par la machine locale
5. **POSTROUTING** : Dernier point avant sortie réseau

### 2.3 Flux de traitement des paquets

```
Internet → [PREROUTING] → Décision de routage
                              │
                              ├─→ Local ? → [INPUT] → Processus local
                              │
                              └─→ Forward ? → [FORWARD] → [POSTROUTING] → Internet
                              
Processus local → [OUTPUT] → [POSTROUTING] → Internet
```

---

## 3. Concepts Fondamentaux

### 3.1 Les Tables

Une **table** est un conteneur qui regroupe des chaînes selon leur fonction.

#### Familles de tables :

| Famille | Description | Utilisation |
|---------|-------------|-------------|
| **ip** | IPv4 uniquement | Filtrage IPv4 |
| **ip6** | IPv6 uniquement | Filtrage IPv6 |
| **inet** | IPv4 + IPv6 | Filtrage mixte (recommandé) |
| **arp** | Protocole ARP | Filtrage ARP |
| **bridge** | Trafic niveau 2 | Filtrage de pont réseau |
| **netdev** | Niveau interface | Filtrage ingress/egress |

**Exemple :**
```bash
# Table pour IPv4 et IPv6
nft add table inet filter

# Table uniquement IPv4
nft add table ip mon_filtrage
```

> 💡 **Bonne pratique** : Utiliser la famille **inet** pour gérer IPv4 et IPv6 en même temps.

### 3.2 Les Chaînes (Chains)

Une **chaîne** est une liste ordonnée de règles. Elle est rattachée à un hook Netfilter.

#### Types de chaînes :

1. **Chaînes de base (base chains)** :
   - Attachées à un hook Netfilter
   - Point d'entrée pour le traitement des paquets
   - Nécessitent : type, hook, priorité, policy

2. **Chaînes utilisateur (regular chains)** :
   - Non attachées à un hook
   - Utilisées pour organiser les règles
   - Appelées depuis d'autres chaînes (avec `jump`)

#### Priorités des chaînes :

| Nom | Valeur | Utilisation |
|-----|--------|-------------|
| raw | -300 | Connection tracking |
| mangle | -150 | Modification de paquets |
| dstnat | -100 | NAT de destination |
| **filter** | **0** | **Filtrage standard** |
| security | 50 | SELinux |
| srcnat | 100 | NAT de source |

**Exemple :**
```bash
# Chaîne de base pour INPUT
nft add chain inet filter input { type filter hook input priority 0 \; policy drop \; }

# Chaîne utilisateur
nft add chain inet filter web_rules
```

### 3.3 Les Règles

Une **règle** définit une condition de filtrage et une action à effectuer.

**Structure d'une règle :**
```
nft add rule <table> <chaîne> <critères> <action>
```

**Exemple :**
```bash
nft add rule inet filter input tcp dport 22 accept
#           └─ table ─┘ └chaîne┘ └─ critères ─┘ └action┘
```

### 3.4 Hiérarchie : Tables → Chaînes → Règles

```
Table "inet filter"
│
├── Chaîne "input" (base chain)
│   ├── Règle 1: tcp dport 22 accept
│   ├── Règle 2: tcp dport 80 accept
│   └── Règle 3: drop
│
├── Chaîne "forward" (base chain)
│   └── Règle: accept
│
└── Chaîne "output" (base chain)
    └── Règle: accept
```

---

## 4. Syntaxe et Commandes de Base

### 4.1 Gestion des tables

```bash
# Créer une table
nft add table inet ma_table
nft add table ip filter_ipv4

# Lister toutes les tables
nft list tables

# Supprimer une table (et son contenu)
nft delete table inet ma_table

# Vider une table (supprimer toutes les chaînes/règles)
nft flush table inet ma_table
```

### 4.2 Gestion des chaînes

#### Créer une chaîne de base :

```bash
# Syntaxe complète
nft add chain <famille> <table> <nom> { \
  type <type> hook <hook> priority <priorité> \; \
  policy <accept|drop> \; \
}

# Exemple INPUT
nft add chain inet filter input { \
  type filter hook input priority 0 \; \
  policy drop \; \
}

# Exemple FORWARD
nft add chain inet filter forward { \
  type filter hook forward priority 0 \; \
  policy accept \; \
}
```

#### Créer une chaîne utilisateur :

```bash
nft add chain inet filter mes_regles_ssh
```

#### Autres opérations :

```bash
# Lister les chaînes d'une table
nft list chains inet filter

# Supprimer une chaîne
nft delete chain inet filter ma_chaine

# Vider une chaîne
nft flush chain inet filter input

# Modifier la policy d'une chaîne
nft chain inet filter input { policy accept \; }
```

### 4.3 Gestion des règles

#### Ajouter une règle :

```bash
# À la fin de la chaîne
nft add rule inet filter input tcp dport 80 accept

# Au début de la chaîne
nft insert rule inet filter input tcp dport 22 accept

# À une position précise (handle)
nft add rule inet filter input position 5 tcp dport 443 accept
```

#### Lister et identifier les règles :

```bash
# Lister avec les handles
nft -a list chain inet filter input

# Exemple de sortie :
# tcp dport 22 accept # handle 3
# tcp dport 80 accept # handle 5
```

#### Supprimer une règle :

```bash
# Par handle
nft delete rule inet filter input handle 5

# Supprimer toutes les règles d'une chaîne
nft flush chain inet filter input
```

#### Remplacer une règle :

```bash
nft replace rule inet filter input handle 3 tcp dport 2222 accept
```

### 4.4 Affichage et listage

```bash
# Afficher toute la configuration
nft list ruleset

# Afficher une table spécifique
nft list table inet filter

# Afficher une chaîne spécifique
nft list chain inet filter input

# Format JSON
nft -j list ruleset

# Avec numéros de handle
nft -a list ruleset
```

---

## 5. Critères de Filtrage

### 5.1 Critères IP

```bash
# Adresse IP source
nft add rule inet filter input ip saddr 192.168.1.100 accept

# Adresse IP destination
nft add rule inet filter output ip daddr 8.8.8.8 accept

# Réseau source (CIDR)
nft add rule inet filter input ip saddr 192.168.1.0/24 accept

# Exclure une IP (!=)
nft add rule inet filter input ip saddr != 192.168.1.50 drop

# IPv6
nft add rule inet filter input ip6 saddr 2001:db8::1 accept
```

### 5.2 Critères réseau

```bash
# Interface source (iif = input interface)
nft add rule inet filter input iif eth0 accept

# Interface destination (oif = output interface)
nft add rule inet filter output oif eth1 accept

# Interface avec nom générique
nft add rule inet filter input iifname "eth*" accept

# Combinaison interface + IP
nft add rule inet filter input iif eth0 ip saddr 192.168.1.0/24 accept
```

### 5.3 Critères de protocole

#### TCP/UDP :

```bash
# Port destination
nft add rule inet filter input tcp dport 22 accept
nft add rule inet filter input udp dport 53 accept

# Port source
nft add rule inet filter output tcp sport 1024-65535 accept

# Plage de ports
nft add rule inet filter input tcp dport 8000-8999 accept

# Plusieurs ports
nft add rule inet filter input tcp dport { 80, 443, 8080 } accept

# Protocole
nft add rule inet filter input ip protocol tcp accept
```

#### ICMP :

```bash
# Tous les ICMP
nft add rule inet filter input icmp type echo-request accept

# ICMPv6
nft add rule inet filter input icmpv6 type echo-request accept
```

### 5.4 Interfaces réseau

```bash
# Interface spécifique
nft add rule inet filter input iif lo accept

# Plusieurs interfaces
nft add rule inet filter input iif { eth0, eth1 } accept

# Interface non-spécifiée (toutes sauf...)
nft add rule inet filter input iif != lo drop
```

---

## 6. Actions et Verdicts

### 6.1 Verdicts de base

| Verdict | Description |
|---------|-------------|
| **accept** | Accepte le paquet |
| **drop** | Rejette silencieusement le paquet |
| **reject** | Rejette avec message d'erreur ICMP |
| **queue** | Envoie vers userspace (nfqueue) |
| **continue** | Continue l'évaluation des règles |
| **return** | Retourne à la chaîne appelante |
| **jump** | Saute vers une autre chaîne |
| **goto** | Saute sans retour possible |

**Exemples :**

```bash
# Accept
nft add rule inet filter input tcp dport 22 accept

# Drop (silencieux)
nft add rule inet filter input ip saddr 10.0.0.5 drop

# Reject (avec erreur)
nft add rule inet filter input tcp dport 23 reject

# Reject avec message personnalisé
nft add rule inet filter input tcp dport 23 reject with icmp type host-prohibited

# Jump vers une chaîne utilisateur
nft add rule inet filter input tcp dport 80 jump web_rules

# Return
nft add chain inet filter web_rules
nft add rule inet filter web_rules ip saddr 192.168.1.0/24 return
nft add rule inet filter web_rules drop
```

### 6.2 Actions multiples

Depuis NFtables, on peut effectuer plusieurs actions sur un même paquet :

```bash
# Logger ET accepter
nft add rule inet filter input tcp dport 22 log prefix \"SSH: \" accept

# Compter ET dropper
nft add rule inet filter input ip saddr 10.0.0.5 counter drop

# Logger, compter ET accepter
nft add rule inet filter input tcp dport 443 log counter accept
```

### 6.3 Logging

```bash
# Log simple
nft add rule inet filter input log

# Log avec préfixe
nft add rule inet filter input log prefix \"[DROP] \"

# Log avec niveau
nft add rule inet filter input log level info prefix \"INFO: \"

# Log avec groupe (pour ulogd)
nft add rule inet filter input log group 2

# Log complet
nft add rule inet filter input log prefix \"[FIREWALL] \" level warn flags all
```

**Niveaux de log :** emerg, alert, crit, err, warn, notice, info, debug

**Consulter les logs :**
```bash
# Avec journalctl
journalctl -kf | grep "FIREWALL"

# Avec dmesg
dmesg -w | grep "FIREWALL"
```

---

## 7. Gestion des Flags TCP

### 7.1 Les flags TCP

Les flags TCP sont des bits dans l'en-tête TCP qui contrôlent la connexion :

| Flag | Nom | Fonction |
|------|-----|----------|
| **SYN** | Synchronize | Initiation de connexion |
| **ACK** | Acknowledgment | Accusé de réception |
| **FIN** | Finish | Fin de connexion |
| **RST** | Reset | Réinitialisation de connexion |
| **PSH** | Push | Données urgentes |
| **URG** | Urgent | Pointeur urgent valide |

**Handshake TCP (3-way) :**
```
Client          Serveur
  │                │
  │─────SYN────────>│  (1) Demande de connexion
  │<───SYN+ACK─────│  (2) Acceptation
  │─────ACK────────>│  (3) Confirmation
  │                │
  │═════════════════│  Connexion établie
```

### 7.2 Filtrage des flags

```bash
# SYN uniquement (nouvelle connexion)
nft add rule inet filter input tcp flags syn tcp dport 80 accept

# SYN+ACK (réponse du serveur)
nft add rule inet filter input tcp flags syn,ack tcp dport 80 accept

# Tout sauf SYN (connexions établies)
nft add rule inet filter input tcp flags != syn accept

# ACK uniquement
nft add rule inet filter input tcp flags == ack accept

# FIN ou RST (fermeture)
nft add rule inet filter input tcp flags fin,rst drop
```

### 7.3 Protection contre les scans

#### NULL scan (aucun flag) :
```bash
nft add rule inet filter input tcp flags == 0x0 drop
```

#### Xmas scan (FIN+PSH+URG) :
```bash
nft add rule inet filter input tcp flags fin,psh,urg drop
```

#### SYN+FIN (invalide) :
```bash
nft add rule inet filter input tcp flags syn,fin drop
```

#### Protection complète :
```bash
# Bloquer les combinaisons invalides
nft add rule inet filter input tcp flags syn,fin drop
nft add rule inet filter input tcp flags syn,rst drop
nft add rule inet filter input tcp flags fin,rst drop
nft add rule inet filter input tcp flags == 0x0 drop
nft add rule inet filter input tcp flags fin,psh,urg drop
```

---

## 8. Gestion de l'ICMP

### 8.1 Types ICMP courants

| Type | Nom | Description |
|------|-----|-------------|
| 0 | echo-reply | Réponse au ping |
| 3 | destination-unreachable | Destination inaccessible |
| 5 | redirect | Redirection |
| 8 | echo-request | Requête ping |
| 11 | time-exceeded | TTL expiré |

**ICMPv6 :**
| Type | Nom | Description |
|------|-----|-------------|
| 128 | echo-request | Ping IPv6 |
| 129 | echo-reply | Réponse ping IPv6 |
| 133-137 | nd-* | Neighbor Discovery |

### 8.2 Filtrage ICMP

```bash
# Autoriser les pings entrants
nft add rule inet filter input icmp type echo-request accept
nft add rule inet filter input icmpv6 type echo-request accept

# Autoriser les réponses aux pings sortants
nft add rule inet filter input icmp type echo-reply accept

# Autoriser les messages d'erreur importants
nft add rule inet filter input icmp type destination-unreachable accept
nft add rule inet filter input icmp type time-exceeded accept

# Bloquer tout le reste
nft add rule inet filter input ip protocol icmp drop

# Limiter le taux de ping (anti-flood)
nft add rule inet filter input icmp type echo-request limit rate 1/second accept
```

#### ICMPv6 spécifique (Neighbor Discovery) :

```bash
# ND est essentiel pour IPv6
nft add rule inet filter input icmpv6 type { nd-neighbor-solicit, nd-neighbor-advert } accept
nft add rule inet filter input icmpv6 type { nd-router-solicit, nd-router-advert } accept
```

---

## 9. Connection Tracking (conntrack)

### 9.1 États de connexion

Le **connection tracking** (suivi de connexion) permet de filtrer en fonction de l'état de la connexion :

| État | Description |
|------|-------------|
| **new** | Nouveau paquet initiant une connexion |
| **established** | Paquet faisant partie d'une connexion établie |
| **related** | Paquet lié à une connexion existante (ex: FTP data) |
| **invalid** | Paquet ne correspondant à aucune connexion |
| **untracked** | Paquet non suivi |

### 9.2 Utilisation du conntrack

```bash
# Accepter les connexions établies et liées
nft add rule inet filter input ct state established,related accept

# Rejeter les paquets invalides
nft add rule inet filter input ct state invalid drop

# Autoriser les nouvelles connexions sur un port
nft add rule inet filter input tcp dport 22 ct state new accept
```

### 9.3 Filtrage stateful

**Exemple de pare-feu stateful complet :**

```bash
# Accepter le trafic sur loopback
nft add rule inet filter input iif lo accept

# Accepter les connexions établies/liées
nft add rule inet filter input ct state established,related accept

# Rejeter les paquets invalides
nft add rule inet filter input ct state invalid drop

# Autoriser SSH (nouvelles connexions)
nft add rule inet filter input tcp dport 22 ct state new accept

# Autoriser HTTP/HTTPS (nouvelles connexions)
nft add rule inet filter input tcp dport { 80, 443 } ct state new accept

# Policy : drop tout le reste
# (défini au niveau de la chaîne)
```

**Pourquoi c'est important ?**
- Évite de devoir autoriser explicitement les réponses
- Améliore la sécurité (vérifie que le paquet fait partie d'une vraie connexion)
- Simplifie les règles

---

## 10. NAT (Network Address Translation)

### 10.1 Source NAT (SNAT)

Le **SNAT** modifie l'adresse IP source. Utilisé pour permettre à un réseau privé d'accéder à Internet.

```bash
# Créer la table NAT
nft add table inet nat

# Créer la chaîne postrouting
nft add chain inet nat postrouting { type nat hook postrouting priority 100 \; }

# SNAT vers une IP fixe
nft add rule inet nat postrouting oif eth0 ip saddr 192.168.1.0/24 snat to 203.0.113.5

# Vérifier
nft list table inet nat
```

### 10.2 Destination NAT (DNAT)

Le **DNAT** modifie l'adresse IP destination. Utilisé pour rediriger du trafic vers un serveur interne.

```bash
# Créer la chaîne prerouting
nft add chain inet nat prerouting { type nat hook prerouting priority -100 \; }

# DNAT : rediriger vers un serveur web interne
nft add rule inet nat prerouting iif eth0 tcp dport 80 dnat to 192.168.1.10

# DNAT avec changement de port
nft add rule inet nat prerouting iif eth0 tcp dport 8080 dnat to 192.168.1.10:80
```

### 10.3 Masquerading

Le **masquerading** est un SNAT dynamique pour les IP dynamiques (DHCP).

```bash
# Masquerading sur interface externe
nft add rule inet nat postrouting oif eth0 masquerade

# Avec un port range
nft add rule inet nat postrouting oif eth0 masquerade to :1024-65535
```

**Différence SNAT vs Masquerade :**
- **SNAT** : IP source fixe
- **Masquerade** : IP source dynamique (détectée automatiquement)

### 10.4 Redirection de ports

La **redirection** est un DNAT vers la machine locale.

```bash
# Créer la chaîne prerouting
nft add chain inet nat prerouting { type nat hook prerouting priority -100 \; }

# Rediriger le port 80 vers 8080 localement
nft add rule inet nat prerouting tcp dport 80 redirect to 8080

# Sur une interface spécifique
nft add rule inet nat prerouting iif eth0 tcp dport 80 redirect to 8080
```

**Exemple complet : routeur NAT**

```bash
#!/bin/bash
# Configuration d'un routeur NAT

# Activer le forwarding IP
echo 1 > /proc/sys/net/ipv4/ip_forward

# Créer la table NAT
nft add table inet nat
nft add chain inet nat postrouting { type nat hook postrouting priority 100 \; }

# Masquerading sur l'interface WAN
nft add rule inet nat postrouting oif eth0 masquerade

# Table filter pour le forwarding
nft add table inet filter
nft add chain inet filter forward { type filter hook forward priority 0 \; policy drop \; }

# Autoriser le forwarding établi/lié
nft add rule inet filter forward ct state established,related accept

# Autoriser le forwarding depuis le LAN
nft add rule inet filter forward iif eth1 oif eth0 accept
```

---

## 11. Gestion Avancée

### 11.1 Sets et Maps

Les **sets** permettent de définir des ensembles d'éléments pour simplifier les règles.

#### Sets :

```bash
# Créer un set d'IPs bloquées
nft add set inet filter blacklist { type ipv4_addr \; }

# Ajouter des IPs au set
nft add element inet filter blacklist { 10.0.0.5, 10.0.0.6, 10.0.0.7 }

# Utiliser le set dans une règle
nft add rule inet filter input ip saddr @blacklist drop

# Set avec timeout automatique
nft add set inet filter bruteforce { type ipv4_addr \; flags timeout \; }
nft add element inet filter bruteforce { 10.0.0.8 timeout 1h }
```

#### Maps :

Les **maps** associent des clés à des valeurs (ex: IP → port).

```bash
# Map pour redirection de ports
nft add map inet nat portmap { type inet_service : ipv4_addr \; }
nft add element inet nat portmap { 80 : 192.168.1.10, 443 : 192.168.1.11 }

# Utiliser la map
nft add rule inet nat prerouting dnat to tcp dport map @portmap
```

### 11.2 Sauvegarde et restauration

#### Sauvegarder la configuration :

```bash
# Sauvegarder dans un fichier
nft list ruleset > /etc/nftables.conf

# Ou avec nft
nft -s list ruleset > /etc/nftables.conf
```

#### Restaurer la configuration :

```bash
# Charger depuis un fichier
nft -f /etc/nftables.conf

# Vider avant de charger
nft flush ruleset
nft -f /etc/nftables.conf
```

#### Sauvegarde automatique :

```bash
# Debian/Ubuntu
# Le fichier /etc/nftables.conf est chargé au démarrage
systemctl enable nftables

# Sauvegarder la config actuelle
nft list ruleset | tee /etc/nftables.conf
```

### 11.3 Fichiers de configuration

**Structure d'un fichier de configuration :**

```bash
#!/usr/sbin/nft -f

# Vider les règles existantes
flush ruleset

# Table filter
table inet filter {
    # Chaîne INPUT
    chain input {
        type filter hook input priority 0; policy drop;
        
        # Loopback
        iif lo accept
        
        # Connexions établies
        ct state established,related accept
        ct state invalid drop
        
        # ICMP
        icmp type echo-request limit rate 1/second accept
        
        # SSH
        tcp dport 22 accept
        
        # HTTP/HTTPS
        tcp dport { 80, 443 } accept
    }
    
    # Chaîne FORWARD
    chain forward {
        type filter hook forward priority 0; policy drop;
        ct state established,related accept
    }
    
    # Chaîne OUTPUT
    chain output {
        type filter hook output priority 0; policy accept;
    }
}

# Table NAT
table inet nat {
    chain postrouting {
        type nat hook postrouting priority 100;
        oif eth0 masquerade
    }
}
```

**Charger le fichier :**
```bash
chmod +x /etc/nftables.conf
nft -f /etc/nftables.conf
```

### 11.4 Modes d'édition

#### Mode interactif :

```bash
nft -i
nft> add table inet filter
nft> add chain inet filter input { type filter hook input priority 0 ; }
nft> list ruleset
nft> quit
```

#### Mode atomique :

Toutes les modifications dans un fichier sont appliquées en une seule transaction atomique, ce qui évite les états incohérents.

```bash
# Éditer un fichier
nano /tmp/rules.nft

# Appliquer atomiquement
nft -f /tmp/rules.nft
```

---

## 12. Cas Pratiques

### 12.1 Protection d'un serveur web

**Objectif :** Protéger un serveur web accessible publiquement.

```bash
#!/usr/sbin/nft -f

flush ruleset

table inet filter {
    # Set pour IPs bloquées
    set blacklist {
        type ipv4_addr
        flags interval
    }
    
    # Set pour limiter les connexions SSH
    set ssh_bruteforce {
        type ipv4_addr
        flags timeout
    }
    
    chain input {
        type filter hook input priority 0; policy drop;
        
        # Loopback
        iif lo accept
        
        # Connexions établies
        ct state established,related accept
        ct state invalid drop
        
        # IPs blacklistées
        ip saddr @blacklist drop
        
        # ICMP limité
        icmp type echo-request limit rate 1/second accept
        
        # SSH avec protection brute-force
        tcp dport 22 ct state new limit rate 3/minute accept
        
        # HTTP/HTTPS
        tcp dport 80 ct state new accept
        tcp dport 443 ct state new accept
        
        # Logs des rejets
        log prefix "[FIREWALL DROP] " drop
    }
    
    chain forward {
        type filter hook forward priority 0; policy drop;
    }
    
    chain output {
        type filter hook output priority 0; policy accept;
    }
}
```

### 12.2 Routeur avec NAT

**Objectif :** Configurer un routeur pour partager la connexion Internet.

```bash
#!/usr/sbin/nft -f

flush ruleset

table inet filter {
    chain input {
        type filter hook input priority 0; policy drop;
        
        iif lo accept
        ct state established,related accept
        ct state invalid drop
        
        # SSH depuis le LAN uniquement
        iif eth1 tcp dport 22 accept
        
        # DNS depuis le LAN
        iif eth1 udp dport 53 accept
        
        # DHCP depuis le LAN
        iif eth1 udp dport 67 accept
        
        icmp type echo-request accept
    }
    
    chain forward {
        type filter hook forward priority 0; policy drop;
        
        # Connexions établies
        ct state established,related accept
        
        # Forward depuis le LAN vers WAN
        iif eth1 oif eth0 accept
        
        # Logs
        log prefix "[FORWARD DROP] " drop
    }
    
    chain output {
        type filter hook output priority 0; policy accept;
    }
}

table inet nat {
    chain prerouting {
        type nat hook prerouting priority -100;
        
        # Redirection de port (exemple : serveur web interne)
        iif eth0 tcp dport 80 dnat to 192.168.1.10
    }
    
    chain postrouting {
        type nat hook postrouting priority 100;
        
        # Masquerading sur WAN
        oif eth0 masquerade
    }
}
```

### 12.3 Pare-feu complet

**Objectif :** Pare-feu complet avec protection avancée.

```bash
#!/usr/sbin/nft -f

flush ruleset

table inet filter {
    # Sets
    set tcp_accepted {
        type inet_service
        elements = { 22, 80, 443 }
    }
    
    set blacklist {
        type ipv4_addr
        flags interval
    }
    
    # Chaîne pour scans TCP
    chain scan_detect {
        # NULL scan
        tcp flags == 0x0 drop
        
        # XMAS scan
        tcp flags fin,psh,urg drop
        
        # Combinaisons invalides
        tcp flags syn,fin drop
        tcp flags syn,rst drop
        
        log prefix "[SCAN DETECTED] " drop
    }
    
    # Chaîne INPUT
    chain input {
        type filter hook input priority 0; policy drop;
        
        # Loopback
        iif lo accept
        
        # Connexions établies/liées
        ct state established,related accept
        
        # Invalides
        ct state invalid drop
        
        # IPs blacklistées
        ip saddr @blacklist drop
        
        # Protection scans
        jump scan_detect
        
        # ICMP
        icmp type echo-request limit rate 1/second accept
        icmp type destination-unreachable accept
        icmp type time-exceeded accept
        
        # Services autorisés
        tcp dport @tcp_accepted ct state new accept
        
        # Logs
        limit rate 5/minute log prefix "[INPUT DROP] "
        drop
    }
    
    chain forward {
        type filter hook forward priority 0; policy drop;
        
        ct state established,related accept
        ct state invalid drop
        
        limit rate 5/minute log prefix "[FORWARD DROP] "
        drop
    }
    
    chain output {
        type filter hook output priority 0; policy accept;
    }
}
```

---

## 13. Migration d'IPtables vers NFtables

### 13.1 Outils de conversion

#### iptables-translate :

```bash
# Installer l'outil
apt install iptables-nftables-compat

# Convertir une règle iptables
iptables-translate -A INPUT -p tcp --dport 22 -j ACCEPT

# Sortie :
# nft add rule ip filter INPUT tcp dport 22 counter accept

# Convertir toutes les règles
iptables-save | iptables-restore-translate -f /dev/stdin > /tmp/nftables-rules.nft
```

#### ip6tables-translate :

```bash
ip6tables-translate -A INPUT -p tcp --dport 22 -j ACCEPT
```

### 13.2 Équivalences de commandes

| IPtables | NFtables |
|----------|----------|
| `iptables -L` | `nft list ruleset` |
| `iptables -A INPUT` | `nft add rule inet filter input` |
| `iptables -D INPUT 1` | `nft delete rule inet filter input handle X` |
| `iptables -F` | `nft flush chain inet filter input` |
| `iptables -X` | `nft delete chain inet filter X` |
| `iptables -P INPUT DROP` | `nft chain inet filter input { policy drop ; }` |
| `iptables-save` | `nft list ruleset` |
| `iptables-restore` | `nft -f file` |

**Exemples de conversion :**

```bash
# IPtables
iptables -A INPUT -p tcp --dport 80 -j ACCEPT

# NFtables
nft add rule inet filter input tcp dport 80 accept
```

```bash
# IPtables
iptables -A INPUT -s 192.168.1.0/24 -p tcp --dport 22 -j ACCEPT

# NFtables
nft add rule inet filter input ip saddr 192.168.1.0/24 tcp dport 22 accept
```

```bash
# IPtables NAT
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE

# NFtables
nft add rule inet nat postrouting oif eth0 masquerade
```

---

## 14. Annexes

### 14.1 Commandes essentielles

```bash
# Affichage
nft list ruleset              # Tout afficher
nft list tables               # Lister les tables
nft list table inet filter    # Afficher une table
nft list chain inet filter input  # Afficher une chaîne

# Gestion
nft flush ruleset            # Tout supprimer
nft flush table inet filter  # Vider une table
nft flush chain inet filter input  # Vider une chaîne

# Sauvegarde/Restauration
nft list ruleset > backup.nft    # Sauvegarder
nft -f backup.nft                 # Restaurer

# Debug
nft -a list ruleset          # Avec handles
nft -j list ruleset          # Format JSON
nft -nn list ruleset         # Sans résolution DNS
```

### 14.2 Exemples de règles courantes

```bash
# Accepter SSH depuis un réseau spécifique
nft add rule inet filter input ip saddr 192.168.1.0/24 tcp dport 22 accept

# Bloquer une IP
nft add rule inet filter input ip saddr 10.0.0.5 drop

# Autoriser le ping avec rate-limit
nft add rule inet filter input icmp type echo-request limit rate 1/second accept

# Autoriser plusieurs ports
nft add rule inet filter input tcp dport { 80, 443, 8080 } accept

# Connection tracking
nft add rule inet filter input ct state established,related accept

# Loguer avant de dropper
nft add rule inet filter input log prefix "[DROP] " drop

# NAT sortant
nft add rule inet nat postrouting oif eth0 masquerade

# Redirection de port
nft add rule inet nat prerouting tcp dport 80 redirect to 8080
```

### 14.3 Dépannage

#### Problèmes courants :

**1. Les règles ne s'appliquent pas**
```bash
# Vérifier que nftables est actif
systemctl status nftables

# Vérifier la configuration
nft list ruleset

# Vérifier les logs
journalctl -xe
```

**2. Impossible de se connecter après activation**
```bash
# Mode rescue : flush temporaire
nft flush ruleset

# Ou redémarrer avec config vide
systemctl stop nftables
```

**3. Conflict avec iptables**
```bash
# Désactiver iptables
systemctl stop iptables
systemctl disable iptables

# Vider les règles iptables
iptables -F
iptables -X
```

**4. Forwarding ne fonctionne pas**
```bash
# Vérifier que le forwarding est activé
cat /proc/sys/net/ipv4/ip_forward
# Doit retourner 1

# Activer le forwarding
echo 1 > /proc/sys/net/ipv4/ip_forward

# Permanent dans /etc/sysctl.conf :
net.ipv4.ip_forward = 1

# Appliquer
sysctl -p
```

**5. NAT ne fonctionne pas**
```bash
# Vérifier la table NAT
nft list table inet nat

# Vérifier le forwarding
cat /proc/sys/net/ipv4/ip_forward

# Vérifier les connexions trackées
conntrack -L
```

#### Tests et vérification :

```bash
# Tester une règle sans l'appliquer
nft -c -f test.nft

# Surveiller les logs en temps réel
journalctl -kf | grep "FIREWALL"

# Voir les connexions trackées
conntrack -L

# Voir les statistiques de connexions
conntrack -S

# Tester la connectivité
ping -c 3 8.8.8.8
telnet exemple.com 80
nc -zv exemple.com 443
```

---

## 📝 Points Clés à Retenir

### ✅ Concepts essentiels :
1. **NFtables** remplace IPtables avec une syntaxe unifiée
2. **Netfilter** est le framework noyau (5 hooks : PREROUTING, INPUT, FORWARD, OUTPUT, POSTROUTING)
3. Hiérarchie : **Tables** → **Chaînes** → **Règles**
4. Utiliser la famille **inet** pour IPv4+IPv6
5. Le **connection tracking** (ct state) simplifie les règles

### ✅ Commandes de base :
```bash
nft list ruleset                    # Afficher tout
nft flush ruleset                   # Tout supprimer
nft add table inet filter           # Créer une table
nft add chain inet filter input {   # Créer une chaîne
  type filter hook input priority 0 ; policy drop ;
}
nft add rule inet filter input tcp dport 22 accept  # Ajouter une règle
```

### ✅ Configuration type d'un serveur :
1. Policy DROP sur INPUT
2. Autoriser loopback
3. Autoriser established,related
4. Bloquer invalid
5. Autoriser les services nécessaires (SSH, HTTP, HTTPS)
6. Logger les rejets

### ✅ Pour l'examen :
- Connaître les 5 hooks Netfilter et leur ordre
- Savoir créer une table, une chaîne, une règle
- Maîtriser le connection tracking (established/related)
- Comprendre la différence entre SNAT, DNAT et masquerade
- Savoir protéger contre les scans TCP
- Connaître les commandes de sauvegarde/restauration

---

## 🎯 Bonne chance pour ton examen !

N'oublie pas :
- Teste toujours tes règles dans un environnement de test
- Utilise des logs pour déboguer
- La policy par défaut devrait être DROP pour INPUT
- Toujours autoriser les connexions established,related
- Garde toujours un accès SSH de secours !

---

*Documentation créée le 11/02/2026 - Bonne révision ! 📚*
