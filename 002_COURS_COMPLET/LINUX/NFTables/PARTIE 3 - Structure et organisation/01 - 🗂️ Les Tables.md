

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

Les **tables** constituent le premier niveau d'organisation dans NFTables. Elles servent de conteneurs logiques pour regrouper l'ensemble de vos règles de filtrage, NAT, et autres opérations réseau. Contrairement à iptables où les tables étaient prédéfinies (filter, nat, mangle, raw), NFTables vous offre une liberté totale pour créer vos propres tables avec les noms de votre choix.

> [!info] Différence majeure avec iptables Dans iptables, vous étiez limité aux tables système prédéfinies. Avec NFTables, vous créez vos propres tables selon vos besoins organisationnels.

---

## Concept et rôle des tables

### 🎯 Qu'est-ce qu'une table ?

Une table NFTables est un **espace de noms** qui regroupe :

- Des chaînes (chains) qui contiennent les règles
- Une famille d'adresses spécifique (IPv4, IPv6, les deux, etc.)
- Une logique fonctionnelle (filtrage, NAT, routage, etc.)

### 📦 Rôle organisationnel

Les tables permettent de :

1. **Organiser logiquement** vos règles par fonction
2. **Isoler** différentes configurations réseau
3. **Faciliter la maintenance** en séparant les responsabilités
4. **Améliorer la lisibilité** de votre configuration

> [!example] Exemples d'organisation
> 
> - Une table `filter` pour le filtrage de paquets
> - Une table `nat` pour la translation d'adresses
> - Une table `mangle` pour la modification de paquets
> - Une table `dmz` pour les règles de votre zone démilitarisée

### 🔄 Relation avec les chaînes

```
Table (conteneur)
  └── Chaîne 1
       └── Règle 1
       └── Règle 2
  └── Chaîne 2
       └── Règle 3
```

> [!warning] Important Une table ne fait rien par elle-même. Ce sont les chaînes qu'elle contient qui appliquent les règles.

---

## Familles d'adresses

Chaque table appartient à une **famille d'adresses** qui détermine le type de trafic qu'elle peut traiter.

### 📊 Les différentes familles

|Famille|Nom|Description|Cas d'usage|
|---|---|---|---|
|`ip`|IPv4|Traite uniquement le trafic IPv4|Réseaux IPv4 uniquement|
|`ip6`|IPv6|Traite uniquement le trafic IPv6|Réseaux IPv6 uniquement|
|`inet`|IPv4 + IPv6|Traite les deux protocoles|**Recommandé** pour la plupart des cas|
|`arp`|ARP|Traite les paquets ARP|Filtrage ARP spécifique|
|`bridge`|Bridge|Traite le trafic au niveau pont|Machines faisant du bridging|
|`netdev`|Netdev|Traite au niveau interface|Filtrage très précoce (ingress)|

### 🌟 La famille `inet` (recommandée)

La famille `inet` est la plus couramment utilisée car :

- ✅ **Simplifie la configuration** : une seule table pour IPv4 et IPv6
- ✅ **Réduit la duplication** : mêmes règles pour les deux protocoles
- ✅ **Compatible dual-stack** : fonctionne même si IPv6 est désactivé

> [!tip] Astuce Sauf besoin spécifique, utilisez toujours `inet` pour vos nouvelles configurations. Cela vous évite de maintenir deux jeux de règles identiques.

### 🔍 Quand utiliser les autres familles ?

**`ip` ou `ip6`** : Uniquement si vous avez des règles très spécifiques à un protocole

```bash
# Exemple : règle spécifique IPv6 (fragmentation)
table ip6 filtrage_ipv6 {
    # Règles uniquement possibles en IPv6
}
```

**`netdev`** : Pour du filtrage très précoce (DDoS mitigation, XDP)

```bash
# Filtrage avant même le stack réseau
table netdev protection {
    # Blocage au niveau interface
}
```

**`bridge`** : Pour filtrer le trafic ponté entre interfaces

---

## Création et suppression de tables

### ➕ Créer une table

#### Syntaxe de base

```bash
nft add table [famille] <nom_table>
```

#### Exemples pratiques

```bash
# Table inet (recommandé)
nft add table inet filter

# Table IPv4 uniquement
nft add table ip filtrage_ipv4

# Table IPv6 uniquement
nft add table ip6 filtrage_ipv6

# Table pour le NAT
nft add table inet nat

# Table pour une zone spécifique
nft add table inet dmz
```

> [!info] Idempotence La commande `add` est idempotente : si la table existe déjà, elle ne génère pas d'erreur et ne modifie rien.

### 🔄 Remplacer une table

Pour recréer complètement une table :

```bash
# Supprime ET recrée la table (efface tout le contenu)
nft flush table inet filter

# Ou bien supprimer puis recréer
nft delete table inet filter
nft add table inet filter
```

> [!warning] Attention `flush table` vide le contenu (chaînes et règles) mais conserve la table. `delete table` supprime complètement la table.

### ➖ Supprimer une table

```bash
# Suppression simple
nft delete table inet filter

# Suppression de toutes les tables d'une famille
nft delete table inet
```

> [!warning] Prérequis pour la suppression La table doit être vide (aucune chaîne) pour être supprimée. Utilisez `flush table` avant si nécessaire.

### 📝 Vérifier les tables existantes

```bash
# Lister toutes les tables
nft list tables

# Lister les tables d'une famille spécifique
nft list tables inet
nft list tables ip

# Afficher le contenu complet d'une table
nft list table inet filter
```

### 💾 Configuration persistante

Les commandes `nft` sont volatiles (perdues au redémarrage). Pour rendre permanent :

**Méthode 1 : Fichier de configuration**

```bash
# Créer/éditer le fichier
sudo nano /etc/nftables.conf

# Ajouter vos tables
table inet filter {
    # Les chaînes viendront ici
}

# Recharger
sudo systemctl reload nftables
```

**Méthode 2 : Sauvegarder la configuration actuelle**

```bash
# Sauvegarder
nft list ruleset > /etc/nftables.conf

# Restaurer au démarrage (systemd)
sudo systemctl enable nftables
```

---

## Conventions de nommage

### 📏 Règles de nommage

Les noms de tables doivent respecter :

- ✅ Lettres (a-z, A-Z)
- ✅ Chiffres (0-9)
- ✅ Underscore (_)
- ✅ Tiret (-)
- ✅ Point (.)
- ❌ Pas d'espaces
- ❌ Pas de caractères spéciaux (@, #, %, etc.)
- 📏 Longueur maximum : 256 caractères

### 🎯 Bonnes pratiques de nommage

#### Noms fonctionnels (recommandé)

```bash
nft add table inet filter      # Filtrage de paquets
nft add table inet nat          # Translation d'adresses
nft add table inet mangle       # Modification de paquets
nft add table inet raw          # Traitement précoce
```

> [!tip] Pourquoi reprendre les noms iptables ? Cela facilite la migration et la compréhension pour ceux qui connaissent iptables.

#### Noms par zone réseau

```bash
nft add table inet dmz          # Zone démilitarisée
nft add table inet lan          # Réseau local
nft add table inet wan          # Internet
nft add table inet vpn          # Tunnel VPN
```

#### Noms par service

```bash
nft add table inet web          # Règles serveur web
nft add table inet mail         # Règles serveur mail
nft add table inet dns          # Règles serveur DNS
```

#### Noms descriptifs

```bash
nft add table inet entreprise_filtrage
nft add table inet production_nat
nft add table inet test_firewall
```

### ❌ Noms à éviter

```bash
# Trop génériques
nft add table inet table1
nft add table inet ma_table
nft add table inet test

# Confusants
nft add table inet chain    # Ressemble à "chaîne"
nft add table inet rule     # Ressemble à "règle"

# Non descriptifs
nft add table inet abc
nft add table inet tmp
```

### 🏷️ Convention recommandée

Pour un système professionnel :

```
[environnement]_[fonction]

Exemples :
- prod_filter
- dev_nat
- dmz_filter
- vpn_mangle
```

---

## Pièges courants

### ⚠️ Piège 1 : Oublier la famille

```bash
# ❌ ERREUR : pas de famille spécifiée
nft add table filter

# ✅ CORRECT
nft add table inet filter
```

> [!warning] Message d'erreur Sans famille, vous obtiendrez : `Error: syntax error, unexpected table`

### ⚠️ Piège 2 : Confondre flush et delete

```bash
# flush = vide la table (garde la structure)
nft flush table inet filter

# delete = supprime complètement la table
nft delete table inet filter
```

> [!info] Différence Après `flush`, la table existe encore (vide). Après `delete`, elle n'existe plus du tout.

### ⚠️ Piège 3 : Tenter de supprimer une table non vide

```bash
# ❌ Échoue si la table contient des chaînes
nft delete table inet filter

# ✅ Vider d'abord, puis supprimer
nft flush table inet filter
nft delete table inet filter
```

### ⚠️ Piège 4 : Utiliser ip au lieu de inet

```bash
# ❌ Problématique en dual-stack
nft add table ip filter    # IPv4 seulement

# ✅ Meilleur choix
nft add table inet filter  # IPv4 + IPv6
```

### ⚠️ Piège 5 : Configuration non persistante

```bash
# ❌ Perdu au redémarrage
nft add table inet filter

# ✅ Sauvegarder dans le fichier de configuration
echo "table inet filter { }" >> /etc/nftables.conf
```

---

## Bonnes pratiques

### ✅ 1. Utilisez inet par défaut

Sauf besoin très spécifique, privilégiez toujours `inet` :

```bash
# Recommandé
nft add table inet filter

# Seulement si nécessaire
nft add table ip filter_ipv4_specifique
```

### ✅ 2. Organisez par fonction

Créez des tables selon leur rôle :

```bash
nft add table inet filter   # Filtrage
nft add table inet nat       # NAT
nft add table inet mangle    # Modification paquets
```

### ✅ 3. Nommage cohérent

Adoptez une convention et respectez-la :

```bash
# Convention : environnement_fonction
nft add table inet prod_filter
nft add table inet prod_nat
nft add table inet dev_filter
```

### ✅ 4. Documentation

Ajoutez des commentaires dans vos fichiers de configuration :

```bash
# /etc/nftables.conf

# Table principale de filtrage pour production
table inet prod_filter {
    # Chaînes à venir...
}

# Table NAT pour accès Internet
table inet prod_nat {
    # Chaînes à venir...
}
```

### ✅ 5. Testez avant de déployer

```bash
# 1. Tester la syntaxe
nft -c -f /etc/nftables.conf

# 2. Charger temporairement
nft -f /tmp/test.conf

# 3. Valider le fonctionnement

# 4. Déployer en production
cp /tmp/test.conf /etc/nftables.conf
systemctl reload nftables
```

### ✅ 6. Sauvegardez régulièrement

```bash
# Backup automatique
nft list ruleset > /root/nftables-backup-$(date +%Y%m%d).conf

# Ou dans un script cron
0 2 * * * nft list ruleset > /backup/nftables-$(date +\%Y\%m\%d).conf
```

### ✅ 7. Minimalisme

Ne créez que les tables dont vous avez réellement besoin :

```bash
# ❌ Trop de tables pour un cas simple
nft add table inet filter
nft add table inet nat
nft add table inet mangle
nft add table inet raw

# ✅ Souvent suffisant
nft add table inet filter
```

---

## 🎯 Récapitulatif

|Aspect|Commande / Syntaxe|
|---|---|
|**Créer une table**|`nft add table inet <nom>`|
|**Supprimer une table**|`nft delete table inet <nom>`|
|**Vider une table**|`nft flush table inet <nom>`|
|**Lister les tables**|`nft list tables`|
|**Afficher une table**|`nft list table inet <nom>`|
|**Famille recommandée**|`inet` (IPv4 + IPv6)|
|**Persister**|Écrire dans `/etc/nftables.conf`|

> [!tip] Astuce finale Les tables sont comme des dossiers : elles organisent vos règles mais ne font rien seules. La vraie action se passe dans les chaînes et règles qu'elles contiennent.