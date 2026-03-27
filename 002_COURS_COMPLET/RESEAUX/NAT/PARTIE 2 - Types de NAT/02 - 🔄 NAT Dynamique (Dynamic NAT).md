

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

## 🎯 Principe de fonctionnement

### Définition

Le **NAT dynamique** est une technique qui permet de traduire automatiquement plusieurs adresses IP privées vers un pool (groupe) d'adresses IP publiques. Contrairement au NAT statique où chaque correspondance est fixe, le NAT dynamique attribue dynamiquement une adresse publique disponible à chaque connexion sortante.

> [!info] Différence avec le NAT statique
> - **NAT statique** : Correspondance 1:1 fixe et permanente
> - **NAT dynamique** : Correspondance 1:1 temporaire et automatique depuis un pool

### Mécanisme de traduction

```
┌─────────────────┐         ┌──────────────┐         ┌─────────────┐
│  Réseau privé   │         │   Routeur    │         │  Internet   │
│                 │         │     NAT      │         │             │
│ 192.168.1.10    │────────▶│ Pool public  │────────▶│ Destination │
│ 192.168.1.20    │         │ 203.0.113.1  │         │             │
│ 192.168.1.30    │         │ 203.0.113.2  │         │             │
└─────────────────┘         └──────────────┘         └─────────────┘
```

**Étapes du processus :**

1. Un hôte interne (ex: 192.168.1.10) initie une connexion sortante
2. Le routeur NAT consulte la table de traduction
3. Si aucune traduction existante, le routeur sélectionne une IP publique disponible dans le pool
4. La traduction est créée et enregistrée dans la table NAT
5. Le paquet est modifié avec l'IP publique choisie
6. La traduction reste active tant que la connexion est utilisée
7. Après expiration du timer d'inactivité, l'IP publique retourne dans le pool

> [!example] Exemple de flux
> ```
> Avant NAT : 192.168.1.10:45678 → 8.8.8.8:53
> Après NAT : 203.0.113.1:45678 → 8.8.8.8:53
> 
> Table NAT créée :
> Inside Local    | Inside Global
> 192.168.1.10    | 203.0.113.1
> ```

### Caractéristiques principales

| Caractéristique | Description |
|----------------|-------------|
| **Allocation** | Premier arrivé, premier servi (FIFO) |
| **Durée** | Temporaire, basée sur des timers |
| **Efficacité** | Meilleure utilisation des IPs publiques que le NAT statique |
| **Prévisibilité** | Aucune garantie sur l'IP publique assignée |
| **Persistance** | Aucune (change à chaque nouvelle session) |

---

## 🏊 Pool d'adresses publiques

### Concept du pool

Un **pool d'adresses** est un ensemble d'adresses IP publiques réservées pour le NAT dynamique. Le routeur puise dans ce pool pour effectuer les traductions.

> [!info] Terminologie Cisco
> - **Inside Local** : Adresse IP privée de l'hôte interne
> - **Inside Global** : Adresse IP publique attribuée depuis le pool
> - **Outside Local** : Adresse IP du serveur distant (vue depuis l'intérieur)
> - **Outside Global** : Adresse IP réelle du serveur distant

### Configuration du pool

```bash
# Définir le pool d'adresses publiques
Router(config)# ip nat pool NOM_POOL debut fin netmask MASQUE

# Exemple concret
Router(config)# ip nat pool PUBLIC_POOL 203.0.113.1 203.0.113.10 netmask 255.255.255.0
```

> [!tip] Nomenclature
> Choisissez des noms explicites pour vos pools : `PUBLIC_POOL`, `WAN_POOL`, `INTERNET_POOL`

### Définir les réseaux internes éligibles

```bash
# Créer une ACL pour identifier le trafic à traduire
Router(config)# access-list 1 permit 192.168.1.0 0.0.0.255

# Ou avec une ACL nommée (recommandé)
Router(config)# ip access-list standard RESEAU_INTERNE
Router(config-std-nacl)# permit 192.168.1.0 0.0.0.255
Router(config-std-nacl)# permit 192.168.2.0 0.0.0.255
Router(config-std-nacl)# exit
```

### Lier le pool à l'ACL

```bash
# Activer le NAT dynamique
Router(config)# ip nat inside source list NUMERO_ACL pool NOM_POOL

# Exemple avec ACL numérotée
Router(config)# ip nat inside source list 1 pool PUBLIC_POOL

# Exemple avec ACL nommée
Router(config)# ip nat inside source list RESEAU_INTERNE pool PUBLIC_POOL
```

### Configuration des interfaces

```bash
# Interface côté LAN (réseau privé)
Router(config)# interface GigabitEthernet0/0
Router(config-if)# ip nat inside
Router(config-if)# exit

# Interface côté WAN (Internet)
Router(config)# interface GigabitEthernet0/1
Router(config-if)# ip nat outside
Router(config-if)# exit
```

### Configuration complète

```bash
# 1. Créer l'ACL
Router(config)# access-list 10 permit 192.168.0.0 0.0.255.255

# 2. Définir le pool
Router(config)# ip nat pool INTERNET_POOL 203.0.113.50 203.0.113.100 netmask 255.255.255.0

# 3. Lier ACL et pool
Router(config)# ip nat inside source list 10 pool INTERNET_POOL

# 4. Configurer les interfaces
Router(config)# interface GigabitEthernet0/0
Router(config-if)# ip nat inside
Router(config-if)# exit

Router(config)# interface GigabitEthernet0/1
Router(config-if)# ip nat outside
Router(config-if)# exit
```

> [!example] Calcul de la capacité du pool
> ```
> Pool : 203.0.113.50 à 203.0.113.100
> Capacité : 100 - 50 + 1 = 51 adresses IP publiques disponibles
> 
> Cela signifie que 51 hôtes peuvent simultanément accéder à Internet.
> Le 52ème hôte ne pourra pas établir de connexion tant qu'une IP ne se libère pas.
> ```

### Dimensionnement du pool

| Nombre d'utilisateurs | Taille du pool recommandée | Ratio |
|----------------------|---------------------------|-------|
| 50-100 | 20-30 IPs | 1:3 |
| 100-250 | 40-60 IPs | 1:4 |
| 250-500 | 80-120 IPs | 1:5 |
| 500+ | Utiliser PAT (overload) | N/A |

> [!tip] Astuce de dimensionnement
> En pratique, tous les utilisateurs n'ont pas besoin d'une connexion simultanée. Un ratio de 1 IP publique pour 3-5 utilisateurs est généralement suffisant, mais cela dépend de l'usage (serveurs, applications temps réel, etc.).

---

## ⚠️ Limites et contraintes

### 1. Épuisement du pool

**Problème** : Lorsque toutes les adresses du pool sont utilisées, les nouvelles connexions échouent.

```
┌─────────────────────────────────────────────┐
│ Pool épuisé !                               │
│                                             │
│ Pool: 203.0.113.1 - 203.0.113.5 (5 IPs)    │
│ Utilisateurs actifs: 5                      │
│ Nouvel utilisateur: ❌ REFUSÉ               │
└─────────────────────────────────────────────┘
```

> [!warning] Symptômes d'épuisement
> - Messages : `%NAT: translation failed`
> - Logs : `no valid pool address available`
> - Les utilisateurs ne peuvent plus accéder à Internet
> - Les connexions existantes continuent de fonctionner

**Solutions** :
- Augmenter la taille du pool
- Réduire les timers d'inactivité
- Passer au PAT (NAT overload) qui sera vu dans une autre partie

### 2. Coût en adresses IP publiques

**Contrainte** : Chaque traduction nécessite une adresse IP publique unique.

| Scénario | IPs publiques requises | Coût estimé |
|----------|----------------------|-------------|
| 20 connexions simultanées | 20 IPs | Élevé |
| 100 connexions simultanées | 100 IPs | Très élevé |
| 500 connexions simultanées | 500 IPs | Prohibitif |

> [!info] Contexte économique
> Les adresses IPv4 publiques sont une ressource limitée et coûteuse. Le NAT dynamique n'est donc pas économiquement viable pour les grandes organisations sans pool important.

### 3. Imprévisibilité de l'adresse source

**Problème** : L'adresse IP publique attribuée change à chaque session.

```bash
# Session 1 (8h00)
192.168.1.10 → 203.0.113.1

# Session 2 (9h00) - même utilisateur
192.168.1.10 → 203.0.113.3

# Session 3 (10h00) - même utilisateur
192.168.1.10 → 203.0.113.7
```

**Impacts** :
- ❌ Impossible d'héberger des serveurs accessibles depuis Internet
- ❌ Problématique pour les whitelists basées sur IP
- ❌ Difficultés avec les applications nécessitant une IP stable
- ❌ Logs et audit complexifiés

> [!warning] Cas d'usage inapproprié
> Ne jamais utiliser le NAT dynamique pour :
> - Des serveurs web, mail, FTP accessibles depuis Internet
> - Des applications VPN où l'IP doit être constante
> - Des systèmes avec filtrage IP strict côté distant

### 4. Timers et expirations

**Mécanisme** : Les traductions NAT expirent après une période d'inactivité.

```bash
# Afficher les timers actuels
Router# show ip nat translations verbose

# Modifier les timers (en secondes)
Router(config)# ip nat translation timeout 600           # Timeout global (défaut: 86400s = 24h)
Router(config)# ip nat translation tcp-timeout 300       # TCP (défaut: 86400s)
Router(config)# ip nat translation udp-timeout 60        # UDP (défaut: 300s)
Router(config)# ip nat translation icmp-timeout 30       # ICMP (défaut: 60s)
```

| Protocole | Timer par défaut | Recommandation |
|-----------|-----------------|----------------|
| TCP | 24 heures | 30-60 minutes pour libérer les IPs |
| UDP | 5 minutes | 1-2 minutes suffisent |
| ICMP | 1 minute | Valeur par défaut OK |

> [!tip] Optimisation des timers
> - **Timers courts** : Libèrent rapidement les IPs mais peuvent interrompre des connexions longues
> - **Timers longs** : Maintiennent les connexions mais monopolisent les IPs du pool
> - Compromis : 10-30 minutes pour TCP, 1-2 minutes pour UDP

### 5. Absence de connexions entrantes

**Limitation fondamentale** : Le NAT dynamique ne permet pas d'initier des connexions depuis Internet vers le réseau interne.

```
Internet → Routeur NAT → Réseau interne
   ❌           ?              ❌
   
Le routeur ne sait pas vers quelle IP privée router 
car il n'existe pas de mapping permanent.
```

> [!warning] Conséquence
> - Aucun serveur interne ne peut être contacté depuis l'extérieur
> - Les applications P2P (peer-to-peer) peuvent rencontrer des problèmes
> - Les protocoles nécessitant des connexions bidirectionnelles échouent

**Solutions** :
- Utiliser le NAT statique pour les serveurs (sera vu dans une autre partie)
- Configurer du port forwarding (sera vu dans une autre partie)

### 6. Problèmes de surveillance et débogage

**Complexité** : La nature dynamique rend le troubleshooting plus difficile.

```bash
# Afficher les traductions actives
Router# show ip nat translations

# Afficher les statistiques
Router# show ip nat statistics

# Effacer les traductions (avec précaution)
Router# clear ip nat translation *
```

> [!tip] Bonnes pratiques de monitoring
> - Activer les logs NAT : `Router(config)# ip nat log translations syslog`
> - Surveiller le taux d'utilisation du pool
> - Implémenter des alertes quand le pool approche 80% d'utilisation
> - Maintenir une documentation des plages IP utilisées

### 7. Tableau récapitulatif des contraintes

| Contrainte | Impact | Niveau de criticité |
|------------|--------|---------------------|
| Épuisement du pool | Perte de connectivité | 🔴 Critique |
| Coût des IPs publiques | Budget élevé | 🟠 Élevé |
| Imprévisibilité IP source | Applications incompatibles | 🟠 Élevé |
| Pas de connexions entrantes | Serveurs impossibles | 🟡 Moyen |
| Gestion des timers | Complexité opérationnelle | 🟡 Moyen |
| Débogage complexe | Temps de résolution élevé | 🟡 Moyen |

> [!info] Quand utiliser le NAT dynamique ?
> Le NAT dynamique est adapté pour :
> - ✅ Organisations de taille moyenne avec un pool d'IPs publiques limité
> - ✅ Environnements où les utilisateurs ne nécessitent qu'un accès sortant
> - ✅ Situations temporaires avant migration vers IPv6
> 
> Il n'est PAS adapté pour :
> - ❌ Très grandes organisations (préférer PAT/overload)
> - ❌ Hébergement de serveurs accessibles publiquement
> - ❌ Environnements nécessitant des IPs sources prévisibles

---

## 🔍 Commandes de vérification essentielles

```bash
# Voir toutes les traductions actives
Router# show ip nat translations

# Statistiques détaillées du NAT
Router# show ip nat statistics

# Vérifier la configuration du pool
Router# show ip nat pool

# Logs en temps réel
Router# debug ip nat
Router# debug ip nat detailed

# Désactiver le debug (important !)
Router# no debug all
```

> [!warning] Attention avec debug
> Les commandes `debug` génèrent beaucoup de trafic CPU. À utiliser uniquement en troubleshooting et désactiver immédiatement après.