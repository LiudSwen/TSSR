

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

## 🏗️ Structure de la commande nft

### Principe général

La commande `nft` suit une structure cohérente et logique qui facilite son apprentissage. Contrairement à iptables qui utilisait différentes commandes selon le contexte, nft unifie tout sous une seule syntaxe.

### Syntaxe de base

```bash
nft [options] <commande> <famille> <objet> [identifiant] [paramètres]
```

> [!info] Composants de la commande
> 
> - **options** : Modificateurs globaux (-a, -n, -s, etc.)
> - **commande** : Action à effectuer (add, delete, list, flush, etc.)
> - **famille** : Type de trafic (ip, ip6, inet, arp, bridge, netdev)
> - **objet** : Élément concerné (table, chain, rule, set, etc.)
> - **identifiant** : Nom de la table, chaîne, etc.
> - **paramètres** : Spécifications supplémentaires

### Les familles de protocoles

|Famille|Description|Usage typique|
|---|---|---|
|`ip`|IPv4 uniquement|Firewall IPv4 classique|
|`ip6`|IPv6 uniquement|Firewall IPv6 dédié|
|`inet`|IPv4 + IPv6|Firewall unifié (recommandé)|
|`arp`|Protocole ARP|Filtrage ARP rare|
|`bridge`|Trafic ponté|Filtrage au niveau pont réseau|
|`netdev`|Niveau périphérique|Filtrage très précoce (ingress)|

> [!tip] Bonne pratique Utilisez la famille `inet` pour gérer IPv4 et IPv6 avec un seul jeu de règles, sauf si vous avez besoin de règles spécifiques à un protocole.

### Les principales commandes

```bash
# Gestion des objets
nft add <objet>      # Ajouter un nouvel élément
nft create <objet>   # Créer (échoue si existe déjà)
nft delete <objet>   # Supprimer un élément
nft list <objet>     # Lister le contenu
nft flush <objet>    # Vider le contenu

# Manipulation
nft insert <règle>   # Insérer en première position
nft replace <règle>  # Remplacer une règle existante
```

> [!warning] Différence add vs create
> 
> - `add` ajoute ou fusionne si l'objet existe
> - `create` échoue si l'objet existe déjà
> - Utilisez `create` pour éviter les doublons accidentels

### Exemples de base

```bash
# Créer une table
nft add table inet mon_firewall

# Créer une chaîne dans cette table
nft add chain inet mon_firewall input { type filter hook input priority 0 \; policy drop \; }

# Ajouter une règle dans cette chaîne
nft add rule inet mon_firewall input tcp dport 22 accept

# Supprimer une table complète
nft delete table inet mon_firewall
```

> [!example] Syntaxe avec échappement Notez le `\;` dans les exemples : les points-virgules doivent être échappés en ligne de commande pour éviter qu'ils soient interprétés par le shell.

---

## 📖 Lister les règles

### Commande list de base

La commande `list` est votre principal outil de diagnostic et de vérification.

```bash
# Lister tout le ruleset
nft list ruleset

# Lister une table spécifique
nft list table inet mon_firewall

# Lister une chaîne spécifique
nft list chain inet mon_firewall input

# Lister un type d'objet dans une table
nft list chains inet mon_firewall
nft list sets inet mon_firewall
```

### Options d'affichage utiles

```bash
# Afficher avec les handles (identifiants numériques)
nft -a list ruleset

# Afficher sans résolution DNS (plus rapide)
nft -n list ruleset

# Afficher avec des statistiques
nft -s list ruleset

# Format JSON (pour scripts)
nft -j list ruleset

# Combinaison d'options
nft -ann list ruleset  # Handles + pas de DNS
```

> [!info] À quoi servent les handles ? Les handles (`-a`) sont des identifiants numériques uniques pour chaque règle. Ils sont essentiels pour supprimer ou modifier une règle spécifique.

### Exemples pratiques de listing

```bash
# Voir toutes les tables existantes
nft list tables

# Voir une table avec tous ses détails
nft list table inet filter

# Voir uniquement une chaîne précise
nft list chain inet filter input

# Obtenir les handles pour manipulation
nft -a list chain inet filter input
```

> [!example] Sortie avec handles
> 
> ```bash
> table inet filter {
>   chain input {
>     type filter hook input priority 0; policy drop;
>     tcp dport 22 accept # handle 3
>     tcp dport 80 accept # handle 4
>     tcp dport 443 accept # handle 5
>   }
> }
> ```

### Filtrage de l'affichage

```bash
# Lister seulement les tables d'une famille
nft list tables inet
nft list tables ip

# Lister toutes les chaînes de toutes les tables
nft list chains

# Affichage compact pour scripts
nft -t list ruleset  # Format terse (compact)
```

> [!tip] Astuce pour debugger Utilisez `nft -a list ruleset > debug.txt` pour capturer l'état complet de votre firewall avec les handles, très utile avant des modifications importantes.

### Comprendre la sortie

```bash
# Exemple de sortie typique
table inet filter {
  set allowed_ips {
    type ipv4_addr
    elements = { 192.168.1.10, 192.168.1.20 }
  }
  
  chain input {
    type filter hook input priority filter; policy drop;
    ct state established,related accept # handle 1
    ip saddr @allowed_ips accept # handle 2
  }
}
```

> [!info] Éléments de la sortie
> 
> - **table** : Conteneur principal
> - **set** : Ensemble de valeurs réutilisables
> - **chain** : Chaîne de règles avec ses attributs (type, hook, priority, policy)
> - **handle** : Identifiant unique pour chaque règle (avec option -a)

---

## 🗑️ Vider les règles

### Commande flush

La commande `flush` permet de vider le contenu d'un objet sans le supprimer lui-même.

```bash
# Vider tout le ruleset (DANGEREUX !)
nft flush ruleset

# Vider une table spécifique
nft flush table inet mon_firewall

# Vider une chaîne spécifique
nft flush chain inet mon_firewall input

# Vider un set
nft flush set inet mon_firewall allowed_ips
```

> [!warning] Attention : flush ruleset `nft flush ruleset` supprime **toutes** les règles de **toutes** les tables de **toutes** les familles. En SSH, cela peut vous couper l'accès immédiatement !

### Différence entre flush et delete

```bash
# flush : vide le contenu mais garde la structure
nft flush chain inet filter input
# La chaîne existe toujours, mais sans règles

# delete : supprime complètement l'objet
nft delete chain inet filter input
# La chaîne n'existe plus du tout
```

|Commande|Effet|Structure conservée|Usage typique|
|---|---|---|---|
|`flush`|Vide le contenu|✅ Oui|Réinitialiser les règles|
|`delete`|Supprime l'objet|❌ Non|Nettoyer complètement|

### Stratégies de nettoyage sécurisées

```bash
# 1. Sauvegarder avant de vider
nft list ruleset > backup_avant_flush.nft
nft flush ruleset

# 2. Vider table par table
nft flush table inet filter
nft flush table ip nat

# 3. Vider chaîne par chaîne pour plus de contrôle
nft flush chain inet filter input
nft flush chain inet filter output
nft flush chain inet filter forward

# 4. Vider uniquement les éléments dynamiques
nft flush set inet filter blacklist_ips
```

> [!tip] Sécurité en SSH Avant de faire `flush ruleset` en SSH, ajoutez une règle temporaire qui s'auto-supprime :
> 
> ```bash
> # Créer une règle qui permet SSH pendant 5 minutes
> nft add rule inet filter input tcp dport 22 accept
> # Puis faire vos modifications
> # Si vous perdez la connexion, la règle permettra la reconnexion
> ```

### Flush sélectif

```bash
# Vider seulement les règles d'une famille
nft flush table inet filter   # IPv4 + IPv6
nft flush table ip nat         # IPv4 NAT uniquement

# Vider tout sauf une table spécifique
# (nécessite de lister puis supprimer les autres)
nft list tables | grep -v "filter" | while read family table; do
  nft flush table $family $table
done
```

### Scénarios d'utilisation du flush

> [!example] Cas d'usage courants
> 
> **Redémarrage propre du firewall :**
> 
> ```bash
> nft flush ruleset
> nft -f /etc/nftables.conf
> ```
> 
> **Réinitialiser une chaîne pour tests :**
> 
> ```bash
> nft flush chain inet filter input
> # Ajouter nouvelles règles de test
> ```
> 
> **Vider les sets dynamiques (blacklists, etc.) :**
> 
> ```bash
> nft flush set inet filter blocked_ips
> ```

---

## 💾 Sauvegarder et restaurer la configuration

### Principe de persistance

Par défaut, les règles nft sont volatiles et disparaissent au redémarrage. La sauvegarde est donc essentielle.

### Sauvegarder la configuration actuelle

```bash
# Méthode standard : export complet
nft list ruleset > /etc/nftables.conf

# Sauvegarder avec une date
nft list ruleset > /etc/nftables.backup.$(date +%Y%m%d-%H%M%S).conf

# Sauvegarder une table spécifique
nft list table inet filter > /etc/nftables.d/filter.conf

# Export en JSON (pour traitement automatisé)
nft -j list ruleset > /etc/nftables.json
```

> [!info] Format de sauvegarde Le format de sortie de `nft list ruleset` est directement réutilisable comme fichier de configuration. C'est l'équivalent de `iptables-save` mais en plus lisible.

### Restaurer une configuration

```bash
# Méthode 1 : Fichier complet (recommandé)
nft -f /etc/nftables.conf

# Méthode 2 : Via stdin
nft list ruleset | nft -f -

# Méthode 3 : Fusion avec existant
nft -f /etc/nftables.d/additional-rules.conf

# Méthode 4 : Flush puis restore (reset complet)
nft flush ruleset
nft -f /etc/nftables.conf
```

> [!warning] Option -f et sécurité `nft -f fichier` **ajoute** les règles par défaut, il ne remplace pas. Pour un reset complet, faites `flush ruleset` d'abord.

### Structure d'un fichier de configuration

```bash
#!/usr/sbin/nft -f
# /etc/nftables.conf - Configuration principale

# Vider les règles existantes
flush ruleset

# Définir les tables
table inet filter {
  # Définir les chaînes
  chain input {
    type filter hook input priority 0; policy drop;
    
    # Règles de base
    ct state established,related accept
    iif lo accept
    tcp dport 22 accept
  }
  
  chain forward {
    type filter hook forward priority 0; policy drop;
  }
  
  chain output {
    type filter hook output priority 0; policy accept;
  }
}
```

> [!tip] Shebang pour exécution directe La ligne `#!/usr/sbin/nft -f` en début de fichier permet de l'exécuter directement : `chmod +x /etc/nftables.conf && /etc/nftables.conf`

### Activation automatique au démarrage

```bash
# Debian/Ubuntu avec systemd
systemctl enable nftables.service
systemctl start nftables.service

# Vérifier le statut
systemctl status nftables.service

# Le service charge /etc/nftables.conf par défaut
```

> [!info] Emplacement du fichier principal
> 
> - Debian/Ubuntu : `/etc/nftables.conf`
> - RHEL/CentOS : `/etc/sysconfig/nftables.conf`
> - Arch Linux : `/etc/nftables.conf`

### Organisation modulaire

```bash
# Structure recommandée
/etc/
├── nftables.conf          # Fichier principal
└── nftables.d/            # Règles modulaires
    ├── 00-flush.conf      # Nettoyage initial
    ├── 10-tables.conf     # Définition des tables
    ├── 20-sets.conf       # Définition des sets
    ├── 30-chains.conf     # Définition des chaînes
    └── 40-rules.conf      # Règles détaillées

# Fichier principal qui inclut tout
# /etc/nftables.conf
#!/usr/sbin/nft -f

include "/etc/nftables.d/*.conf"
```

> [!example] Utilisation d'include
> 
> ```bash
> # /etc/nftables.conf
> #!/usr/sbin/nft -f
> 
> flush ruleset
> 
> include "/etc/nftables.d/tables.conf"
> include "/etc/nftables.d/sets.conf"
> include "/etc/nftables.d/rules.conf"
> ```

### Sauvegarde automatisée

```bash
# Script de sauvegarde quotidienne
# /usr/local/bin/backup-nftables.sh

#!/bin/bash
BACKUP_DIR="/var/backups/nftables"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
KEEP_DAYS=30

# Créer le répertoire si nécessaire
mkdir -p "$BACKUP_DIR"

# Sauvegarder
nft list ruleset > "$BACKUP_DIR/nftables-$TIMESTAMP.conf"

# Nettoyer les anciennes sauvegardes
find "$BACKUP_DIR" -name "nftables-*.conf" -mtime +$KEEP_DAYS -delete

# Crontab : tous les jours à 2h du matin
# 0 2 * * * /usr/local/bin/backup-nftables.sh
```

### Validation avant application

```bash
# Tester un fichier de configuration sans l'appliquer
nft -c -f /etc/nftables.conf

# Si pas d'erreur, appliquer
if nft -c -f /etc/nftables.conf; then
  nft flush ruleset
  nft -f /etc/nftables.conf
  echo "Configuration appliquée avec succès"
else
  echo "Erreur dans la configuration !"
  exit 1
fi
```

> [!tip] Option -c pour validation L'option `-c` (check) valide la syntaxe sans appliquer les règles. Toujours tester avant d'appliquer en production !

### Restauration d'urgence

```bash
# En cas de problème, restaurer la dernière sauvegarde valide
# 1. Identifier la sauvegarde
ls -lt /var/backups/nftables/

# 2. Valider la sauvegarde
nft -c -f /var/backups/nftables/nftables-20250115-020001.conf

# 3. Appliquer
nft flush ruleset
nft -f /var/backups/nftables/nftables-20250115-020001.conf

# 4. Vérifier
nft list ruleset
```

> [!warning] Accès physique recommandé En cas de blocage SSH suite à une mauvaise configuration, vous aurez besoin d'un accès console (physique ou KVM) pour restaurer.

### Export et import entre systèmes

```bash
# Exporter depuis système A
ssh root@systemA 'nft list ruleset' > systemA-rules.conf

# Adapter si nécessaire (interfaces, IPs...)
sed -i 's/eth0/ens33/g' systemA-rules.conf

# Importer vers système B
scp systemA-rules.conf root@systemB:/tmp/
ssh root@systemB 'nft -c -f /tmp/systemA-rules.conf && nft -f /tmp/systemA-rules.conf'
```

---

## 🎯 Récapitulatif des commandes essentielles

```bash
# Structure de base
nft [options] <commande> <famille> <objet> [identifiant]

# Lister
nft list ruleset                    # Tout afficher
nft -a list ruleset                 # Avec handles
nft list table inet filter          # Une table spécifique

# Vider
nft flush ruleset                   # Tout vider (dangereux)
nft flush table inet filter         # Vider une table
nft flush chain inet filter input   # Vider une chaîne

# Sauvegarder
nft list ruleset > /etc/nftables.conf

# Restaurer
nft -f /etc/nftables.conf

# Valider
nft -c -f /etc/nftables.conf

# Persistance
systemctl enable nftables.service
```

> [!tip] Mémo des options principales
> 
> - `-a` : Afficher les handles
> - `-n` : Pas de résolution DNS
> - `-s` : Afficher les statistiques
> - `-j` : Format JSON
> - `-f` : Charger depuis fichier
> - `-c` : Vérifier la syntaxe sans appliquer

---