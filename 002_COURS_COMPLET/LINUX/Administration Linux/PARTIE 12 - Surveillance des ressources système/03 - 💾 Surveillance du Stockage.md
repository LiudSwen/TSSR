

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

La surveillance du stockage est une tâche critique en administration Linux. Un système de fichiers plein peut causer des dysfonctionnements graves, des pertes de données ou l'arrêt de services. Les outils `df` et `du` permettent de surveiller l'utilisation de l'espace disque à différents niveaux : `df` pour une vue globale des systèmes de fichiers, `du` pour une analyse détaillée des répertoires.

> [!info] Pourquoi surveiller le stockage ?
> 
> - Prévenir les crashes système dus à un manque d'espace
> - Identifier les répertoires ou fichiers qui consomment trop d'espace
> - Planifier l'extension des capacités de stockage
> - Optimiser l'utilisation des ressources

---

## df - Espace disque des systèmes de fichiers

### Concept et utilité

La commande `df` (disk free) affiche l'espace disque disponible sur tous les systèmes de fichiers montés. Elle donne une vue d'ensemble de l'utilisation du stockage au niveau des partitions et points de montage.

> [!tip] Quand utiliser df ?
> 
> - Vérification rapide de l'espace disponible sur les partitions
> - Surveillance globale des systèmes de fichiers
> - Identification des partitions proches de la saturation
> - Monitoring automatisé via scripts

### Syntaxe de base

```bash
df [OPTIONS] [SYSTÈME_DE_FICHIERS...]
```

Sans argument, `df` affiche tous les systèmes de fichiers montés.

### Options principales

|Option|Description|Cas d'usage|
|---|---|---|
|`-h`|Format humainement lisible (K, M, G)|Usage quotidien, lecture rapide|
|`-H`|Format SI (base 1000 au lieu de 1024)|Conformité aux standards SI|
|`-T`|Affiche le type de système de fichiers|Identification des types (ext4, xfs, tmpfs, etc.)|
|`-i`|Affiche les inodes au lieu des blocs|Diagnostic de problèmes d'inodes|
|`-t TYPE`|Affiche uniquement le type spécifié|Filtrage par type (ext4, nfs, etc.)|
|`-x TYPE`|Exclut le type spécifié|Exclure tmpfs, devtmpfs, etc.|
|`--total`|Ajoute une ligne de total|Vue d'ensemble du stockage total|

### Exemples pratiques

#### Utilisation basique

```bash
# Affichage standard
df

# Sortie typique :
# Filesystem     1K-blocks    Used Available Use% Mounted on
# /dev/sda1       50196348 8234556  39375952  18% /
# /dev/sdb1      204774348 98234556 106539792  48% /data
```

#### Format lisible (-h)

```bash
# Format humain (recommandé)
df -h

# Sortie :
# Filesystem      Size  Used Avail Use% Mounted on
# /dev/sda1        48G  7.9G   38G  18% /
# /dev/sdb1       196G   94G  102G  48% /data
# tmpfs           7.8G  1.2M  7.8G   1% /run
```

> [!example] Option -h en pratique L'option `-h` convertit automatiquement les valeurs en unités lisibles (K, M, G, T), ce qui est beaucoup plus intuitif que des blocs de 1 Ko.

#### Afficher le type de système de fichiers (-T)

```bash
# Voir les types de FS
df -hT

# Sortie :
# Filesystem     Type      Size  Used Avail Use% Mounted on
# /dev/sda1      ext4       48G  7.9G   38G  18% /
# /dev/sdb1      xfs       196G   94G  102G  48% /data
# tmpfs          tmpfs     7.8G  1.2M  7.8G   1% /run
```

#### Filtrer par type de système de fichiers

```bash
# Afficher uniquement les systèmes ext4
df -hT -t ext4

# Exclure les systèmes temporaires (tmpfs, devtmpfs)
df -h -x tmpfs -x devtmpfs

# Très utile pour éviter le bruit des pseudo-systèmes
```

#### Vérifier les inodes (-i)

```bash
# Afficher l'utilisation des inodes
df -hi

# Sortie :
# Filesystem     Inodes IUsed IFree IUse% Mounted on
# /dev/sda1        3.1M  245K  2.9M    8% /
# /dev/sdb1         13M  1.2M   12M   10% /data
```

> [!warning] Problème d'inodes Un système de fichiers peut être "plein" même si de l'espace disque est disponible, si tous les inodes sont utilisés. Cela arrive souvent avec de nombreux petits fichiers.

#### Vue d'ensemble avec total

```bash
# Ajouter une ligne de total
df -h --total

# Sortie :
# Filesystem      Size  Used Avail Use% Mounted on
# /dev/sda1        48G  7.9G   38G  18% /
# /dev/sdb1       196G   94G  102G  48% /data
# total           244G  102G  140G  42%
```

### Interprétation des résultats

Les colonnes principales de la sortie `df` :

|Colonne|Signification|Important pour|
|---|---|---|
|**Filesystem**|Nom du périphérique ou point de montage|Identifier la partition|
|**Size**|Taille totale du système de fichiers|Capacité installée|
|**Used**|Espace utilisé|Consommation actuelle|
|**Avail**|Espace disponible pour les utilisateurs|Planification|
|**Use%**|Pourcentage d'utilisation|Alertes et seuils|
|**Mounted on**|Point de montage dans l'arborescence|Localisation|

> [!info] Espace réservé au root Sur les systèmes ext4, environ 5% de l'espace est réservé au superutilisateur. C'est pourquoi `Used + Avail ≠ Size`. Cette réserve évite qu'un système devienne totalement inutilisable si une partition se remplit.

### Pièges courants

> [!warning] Fichiers supprimés mais toujours ouverts Si un processus garde un fichier ouvert après sa suppression, l'espace ne sera libéré qu'à la fermeture du processus. `df` montrera l'espace comme utilisé alors que `du` ne verra pas le fichier.

```bash
# Trouver les fichiers supprimés mais ouverts
lsof | grep deleted

# Solution : redémarrer le processus ou le serveur
```

> [!warning] Différence entre df et du `df` peut montrer plus d'espace utilisé que `du` en raison de :
> 
> - Fichiers supprimés mais encore ouverts
> - Métadonnées du système de fichiers
> - Espace réservé au système
> - Snapshots ou fonctionnalités du FS

---

## du - Utilisation de l'espace par répertoire

### Concept et utilité

La commande `du` (disk usage) calcule l'utilisation de l'espace disque par fichier et répertoire. Elle est essentielle pour identifier précisément où l'espace est consommé dans l'arborescence.

> [!tip] Quand utiliser du ?
> 
> - Identifier les répertoires volumineux
> - Trouver ce qui consomme de l'espace après une alerte `df`
> - Auditer l'utilisation du stockage par projet ou utilisateur
> - Nettoyer les fichiers inutiles

### Syntaxe de base

```bash
du [OPTIONS] [FICHIER|RÉPERTOIRE...]
```

Sans argument, `du` analyse le répertoire courant et tous ses sous-répertoires.

### Options principales

|Option|Description|Cas d'usage|
|---|---|---|
|`-h`|Format humainement lisible (K, M, G)|Lecture facile des résultats|
|`-s`|Résumé (summary) - affiche uniquement le total|Vue d'ensemble d'un répertoire|
|`-c`|Ajoute un grand total à la fin|Total de plusieurs répertoires|
|`-a`|Affiche tous les fichiers, pas seulement les répertoires|Analyse détaillée|
|`--max-depth=N`|Limite la profondeur de descente|Contrôle du niveau de détail|
|`-d N`|Équivalent à --max-depth (sur certains systèmes)|Même fonction|
|`--exclude=PATTERN`|Exclut les fichiers correspondants|Ignorer certains types de fichiers|
|`-x`|Ne pas traverser les autres systèmes de fichiers|Rester sur une partition|
|`--time`|Affiche la date de dernière modification|Trouver les anciens fichiers|

### Exemples pratiques

#### Utilisation basique

```bash
# Analyser le répertoire courant
du -h

# Sortie (partielle) :
# 4.0K    ./subdir1
# 12K     ./subdir2
# 156M    ./large_dir
# 160M    .
```

#### Résumé d'un répertoire (-s)

```bash
# Total d'un seul répertoire
du -sh /var/log

# Sortie :
# 2.3G    /var/log

# Comparer plusieurs répertoires
du -sh /var/log /home /tmp

# Sortie :
# 2.3G    /var/log
# 45G     /home
# 128M    /tmp
```

> [!example] Utilisation courante `du -sh` est probablement la combinaison la plus utilisée pour obtenir rapidement la taille totale d'un répertoire.

#### Total cumulé (-c)

```bash
# Total de plusieurs répertoires avec somme
du -shc /var/log /home /tmp

# Sortie :
# 2.3G    /var/log
# 45G     /home
# 128M    /tmp
# 47G     total
```

#### Analyser tous les fichiers (-a)

```bash
# Afficher les fichiers individuels
du -ah /etc | head -10

# Sortie :
# 4.0K    /etc/hostname
# 8.0K    /etc/hosts
# 16K     /etc/passwd
# ...
```

#### Limiter la profondeur (--max-depth)

```bash
# Vue d'ensemble des sous-répertoires directs
du -h --max-depth=1 /var

# Sortie :
# 128K    /var/cache
# 2.3G    /var/log
# 45M     /var/lib
# 12K     /var/tmp
# 2.4G    /var

# Deux niveaux de profondeur
du -h --max-depth=2 /home

# Équivalent court (sur certains systèmes)
du -h -d 1 /var
```

> [!tip] Trouver les gros répertoires `du -h --max-depth=1 /` suivi d'un tri permet d'identifier rapidement les répertoires volumineux à la racine.

#### Trier les résultats

```bash
# Trier par taille (nécessite de retirer -h pour du)
du --max-depth=1 /var | sort -n

# Ou utiliser sort -h avec l'option -h de du (GNU sort)
du -h --max-depth=1 /var | sort -hr

# Les 10 plus gros répertoires
du -h --max-depth=1 /home | sort -hr | head -10
```

#### Exclure des patterns

```bash
# Exclure les fichiers de logs
du -sh --exclude='*.log' /var

# Exclure plusieurs patterns
du -sh --exclude='*.log' --exclude='*.tmp' /var

# Exclure un répertoire spécifique
du -sh --exclude='cache' /var
```

#### Afficher les dates (--time)

```bash
# Voir les dates de modification
du -h --time /var/log/*

# Sortie :
# 1.2G    2024-03-15 10:30    /var/log/syslog
# 456M    2024-03-14 08:15    /var/log/auth.log
# ...
```

### Combinaisons utiles

#### Trouver les 10 plus gros répertoires

```bash
# Méthode 1 : à partir de la racine
du -h --max-depth=1 / 2>/dev/null | sort -hr | head -10

# Méthode 2 : dans un répertoire spécifique
du -h --max-depth=2 /home | sort -hr | head -10
```

> [!info] Redirection des erreurs `2>/dev/null` supprime les messages d'erreur (permissions refusées), utile lors de l'analyse de `/`.

#### Analyser l'utilisation par utilisateur

```bash
# Taille des répertoires home
du -sh /home/*

# Avec tri
du -sh /home/* | sort -hr
```

#### Trouver les fichiers de plus de 100 Mo

```bash
# Avec find et du
find /var -type f -size +100M -exec du -h {} \; | sort -hr

# Alternative plus simple avec find seul
find /var -type f -size +100M -exec ls -lh {} \; | awk '{print $5, $9}'
```

#### Surveiller un répertoire en temps réel

```bash
# Observer l'évolution de la taille
watch -n 5 'du -sh /var/log'

# Affiche la taille toutes les 5 secondes
```

### Pièges courants

> [!warning] Lenteur sur les gros systèmes de fichiers `du` parcourt physiquement tous les fichiers et peut être très lent sur des arborescences volumineuses. Utilisez `--max-depth` pour limiter la profondeur.

> [!warning] Liens symboliques Par défaut, `du` ne suit pas les liens symboliques. Utilisez `-L` pour suivre tous les liens, mais attention aux boucles infinies.

```bash
# Suivre les liens symboliques (attention !)
du -shL /var

# Peut compter deux fois certains fichiers
```

> [!warning] Fichiers avec liens durs Si un fichier a plusieurs liens durs (hard links), `du` peut le compter plusieurs fois selon le contexte.

```bash
# Compter les liens durs une seule fois
du -sh --count-links /path
```

> [!warning] Permissions insuffisantes `du` ne peut analyser que les fichiers auxquels vous avez accès. Utilisez `sudo` pour une analyse complète.

```bash
# Analyse complète (en tant que root)
sudo du -h --max-depth=1 /

# Sans sudo, certains répertoires seront ignorés
```

---

## Comparaison df vs du

|Aspect|df|du|
|---|---|---|
|**Niveau d'analyse**|Systèmes de fichiers (partitions)|Fichiers et répertoires|
|**Rapidité**|Très rapide (lit les métadonnées FS)|Plus lent (parcourt tous les fichiers)|
|**Usage**|Vue d'ensemble globale|Analyse détaillée|
|**Précision**|Inclut métadonnées et fichiers ouverts|N'inclut que les fichiers visibles|
|**Cas d'usage**|Monitoring, alertes, vue globale|Investigation, nettoyage, audit|

> [!info] Workflow typique
> 
> 1. Utiliser `df -h` pour identifier une partition pleine
> 2. Utiliser `du -h --max-depth=1` pour trouver le répertoire problématique
> 3. Descendre progressivement avec `du` pour identifier les fichiers à nettoyer

---

## Bonnes pratiques

### Monitoring régulier

```bash
# Script de monitoring simple
#!/bin/bash
THRESHOLD=80

df -h | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 " " $6 }' | while read output;
do
  usage=$(echo $output | awk '{ print $1}' | cut -d'%' -f1)
  partition=$(echo $output | awk '{ print $2 }')
  if [ $usage -ge $THRESHOLD ]; then
    echo "Alerte : $partition est à ${usage}% d'utilisation"
  fi
done
```

### Nettoyage efficace

```bash
# Identifier les gros fichiers anciens
find /var/log -type f -size +100M -mtime +30

# Comprimer les vieux logs
find /var/log -name "*.log" -mtime +7 -exec gzip {} \;

# Supprimer les fichiers temporaires anciens
find /tmp -type f -atime +7 -delete
```

### Exclusions courantes

```bash
# Analyser sans les fichiers cachés
du -sh --exclude='.*' /home/user

# Ignorer les répertoires de cache
du -sh --exclude='cache' --exclude='.cache' /home/user
```

> [!tip] Utiliser ncdu L'outil `ncdu` (NCurses Disk Usage) offre une interface interactive très pratique pour naviguer dans l'arborescence et identifier les gros fichiers. Installation : `apt install ncdu` ou `yum install ncdu`.

---

## Astuces avancées

### Alias utiles

```bash
# Ajouter dans ~/.bashrc ou ~/.zshrc

# Disque usage top 10
alias ducks='du -sh * | sort -hr | head -10'

# Système de fichiers avec types
alias dft='df -hT -x tmpfs -x devtmpfs'

# Résumé du répertoire courant
alias dus='du -sh'
```

### Combiner avec d'autres commandes

```bash
# Trouver et afficher la taille des fichiers ISO
find / -name "*.iso" -exec du -h {} \; 2>/dev/null

# Répertoires modifiés dans les 7 derniers jours
find /home -type d -mtime -7 -exec du -sh {} \; | sort -hr

# Compter le nombre de fichiers par répertoire
du --inodes -d 1 /var/log
```

### Surveillance avec inotify

```bash
# Observer les changements sur un répertoire
inotifywait -m -r -e create,delete,modify /var/log
```

### Rapport d'utilisation formaté

```bash
# Générer un rapport HTML
(
  echo "<html><body><h1>Rapport de stockage</h1><pre>"
  df -h
  echo "</pre><h2>Top répertoires</h2><pre>"
  du -h --max-depth=1 /home | sort -hr | head -20
  echo "</pre></body></html>"
) > /tmp/storage_report.html
```

### Différence entre deux analyses

```bash
# Capturer l'état actuel
du -sh /var > /tmp/var_before.txt

# ... après des modifications ...

# Comparer
du -sh /var > /tmp/var_after.txt
diff /tmp/var_before.txt /tmp/var_after.txt
```

> [!tip] Automatisation Planifiez des tâches cron pour surveiller automatiquement l'utilisation du disque et recevoir des alertes par email lorsque des seuils sont dépassés.

---

## 🎯 Points clés à retenir

- **df** donne une vue globale rapide des systèmes de fichiers montés
- **du** permet une analyse détaillée de l'utilisation dans l'arborescence
- L'option **-h** rend les résultats lisibles pour les deux commandes
- **--max-depth** avec du limite la profondeur d'analyse et améliore les performances
- Une différence entre df et du est normale (métadonnées, fichiers ouverts)
- Surveillez les inodes avec **df -i** pour éviter les surprises
- Combinez df et du dans un workflow : détection globale puis investigation détaillée