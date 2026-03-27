
## 📚 Table des matières

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

## 🎯 Introduction

Les commandes d'information système permettent d'obtenir des détails essentiels sur votre environnement Linux : configuration matérielle, identité utilisateur, ressources disponibles et état du système. Ces commandes sont cruciales pour :

- **Diagnostiquer** des problèmes système
- **Surveiller** les ressources (CPU, mémoire, disque)
- **Vérifier** la configuration avant d'exécuter des scripts
- **Documenter** l'environnement pour le support technique
- **Automatiser** des tâches selon le contexte système

> [!tip] Conseil pour débutants Ces commandes sont en lecture seule et sans danger. N'hésitez pas à les tester pour vous familiariser avec votre système !

---

## 🏷️ uname - Informations sur le système

### Qu'est-ce que c'est ?

`uname` (Unix Name) affiche des informations de base sur le système d'exploitation et le noyau Linux.

### Pourquoi l'utiliser ?

- Identifier la version du noyau Linux
- Connaître l'architecture du processeur (32/64 bits)
- Vérifier la compatibilité avant d'installer un logiciel
- Obtenir le nom du système d'exploitation

### Syntaxe et options

```bash
# Afficher uniquement le nom du système
uname

# Afficher toutes les informations disponibles
uname -a

# Options spécifiques
uname -s    # Nom du noyau (ex: Linux)
uname -n    # Nom du réseau (hostname)
uname -r    # Version du noyau (ex: 5.15.0-56-generic)
uname -v    # Version complète avec date de compilation
uname -m    # Architecture matérielle (ex: x86_64, aarch64)
uname -p    # Type de processeur
uname -i    # Plateforme matérielle
uname -o    # Système d'exploitation (ex: GNU/Linux)
```

> [!example] Exemples pratiques
> 
> ```bash
> # Connaître l'architecture pour télécharger le bon paquet
> uname -m
> # Sortie : x86_64
> 
> # Afficher toutes les infos d'un coup
> uname -a
> # Sortie : Linux monserveur 5.15.0-56-generic #62-Ubuntu SMP x86_64 GNU/Linux
> 
> # Combiner plusieurs options
> uname -srm
> # Sortie : Linux 5.15.0-56-generic x86_64
> ```

### Informations détaillées sur la sortie de `uname -a`

```bash
Linux monserveur 5.15.0-56-generic #62-Ubuntu SMP Tue Nov 22 19:54:14 UTC 2022 x86_64 x86_64 x86_64 GNU/Linux
```

|Élément|Signification|
|---|---|
|`Linux`|Nom du noyau|
|`monserveur`|Nom d'hôte de la machine|
|`5.15.0-56-generic`|Version du noyau|
|`#62-Ubuntu`|Numéro de build|
|`SMP`|Support multiprocesseur symétrique|
|`Tue Nov 22...`|Date de compilation|
|`x86_64` (×3)|Architecture CPU / Processeur / Plateforme|
|`GNU/Linux`|Système d'exploitation|

> [!warning] Attention La version du noyau (`uname -r`) est différente de la version de la distribution (Ubuntu 22.04, Debian 11, etc.). Pour connaître la version de votre distribution, utilisez `lsb_release -a` ou `cat /etc/os-release`.

### Cas d'usage courants

````bash
# Vérifier l'espace d'un dossier spécifique
> df -h /var/log
> 
> # Voir uniquement les partitions physiques (exclure tmpfs, etc.)
> df -h -t ext4 -t xfs
> 
> # Surveiller les partitions critiques
> df -h / /home /var
> ```

### Décryptage de la sortie

```bash
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1       100G   45G   50G  48% /
/dev/sdb1       500G  350G  150G  70% /home
tmpfs           7.8G  1.2M  7.8G   1% /run
````

|Colonne|Signification|
|---|---|
|`Filesystem`|Périphérique ou système de fichiers|
|`Size`|Taille totale de la partition|
|`Used`|Espace utilisé|
|`Avail`|Espace disponible|
|`Use%`|Pourcentage d'utilisation|
|`Mounted on`|Point de montage (où est accessible la partition)|

> [!info] Types de systèmes de fichiers courants
> 
> - **ext4** : Système de fichiers Linux standard
> - **xfs** : Performant pour gros fichiers (Red Hat/CentOS par défaut)
> - **btrfs** : Moderne avec snapshots et compression
> - **tmpfs** : Système de fichiers en mémoire RAM (temporaire)
> - **devtmpfs** : Périphériques système
> - **nfs** / **cifs** : Montages réseau (NFS, Samba)

### Surveiller les inodes

Les **inodes** sont les structures de données qui stockent les métadonnées des fichiers. On peut manquer d'inodes même avec de l'espace disque disponible !

```bash
# Afficher l'utilisation des inodes
df -i

# Sortie exemple :
# Filesystem      Inodes  IUsed   IFree IUse% Mounted on
# /dev/sda1      6553600 450000 6103600    7% /
# /dev/sdb1     32768000 3200000 29568000   10% /home
```

> [!warning] Problème d'inodes saturés Si vous voyez `IUse% = 100%` même avec de l'espace disque disponible :
> 
> - Trop de petits fichiers (logs fragmentés, cache, etc.)
> - Impossible de créer de nouveaux fichiers
> - Solution : supprimer des fichiers ou reformater avec plus d'inodes

```bash
# Trouver quel dossier contient le plus de fichiers
sudo find / -xdev -type f | cut -d "/" -f 2 | sort | uniq -c | sort -rn | head -10

# Compter les fichiers dans un dossier
find /var/log -type f | wc -l
```

### Seuils d'alerte recommandés

```bash
# 🟢 NORMAL : < 80% d'utilisation
# 🟡 ATTENTION : 80-90% d'utilisation
# 🔴 CRITIQUE : > 90% d'utilisation

# Script de vérification
df -h | awk '+$5 > 90 {print "🔴 CRITIQUE:", $0}'
df -h | awk '+$5 > 80 && +$5 <= 90 {print "🟡 ATTENTION:", $0}'
```

> [!tip] Que faire quand le disque est plein ?
> 
> 1. **Identifier les gros fichiers** : `du -sh /* | sort -rh | head -10`
> 2. **Nettoyer les logs** : `sudo journalctl --vacuum-time=7d`
> 3. **Vider les caches** : `sudo apt clean` (Ubuntu/Debian)
> 4. **Supprimer les anciens kernels** : `sudo apt autoremove`
> 5. **Trouver les gros dossiers** : `du -h --max-depth=1 / | sort -rh`

### Filtrer et personnaliser l'affichage

```bash
# Afficher uniquement les partitions physiques (pas les virtuelles)
df -h --output=source,size,used,avail,pcent,target -x tmpfs -x devtmpfs

# Afficher uniquement certaines colonnes
df -h --output=target,pcent,avail
# Sortie :
# Mounted on    Use% Avail
# /              48%   50G
# /home          70%  150G

# Trier par utilisation (le plus plein en premier)
df -h | tail -n +2 | sort -k5 -rn

# Surveiller en temps réel
watch -n 5 'df -h | grep -E "^/dev"'
```

### Cas d'usage pratiques

```bash
# Script d'alerte simple
#!/bin/bash
THRESHOLD=80
df -h | awk -v threshold=$THRESHOLD '
  NR>1 && $5+0 > threshold {
    print "⚠️ ALERTE: "$1" est plein à "$5" (montée sur "$6")"
  }'

# Avant d'écrire un gros fichier
AVAILABLE=$(df /home | tail -1 | awk '{print $4}')
if [ "$AVAILABLE" -lt 10485760 ]; then  # Moins de 10GB en KB
    echo "❌ Espace insuffisant !"
    exit 1
fi

# Rapport de synthèse
echo "=== Espace disque ==="
df -h / /home | tail -n +2 | awk '{printf "%-20s %5s utilisé / %5s total (%s)\n", $6, $3, $2, $5}'
```

### Différence entre df et du

```bash
# df : espace des SYSTÈMES DE FICHIERS (partitions)
df -h /home
# → Affiche l'espace total de la partition /home

# du : espace utilisé par des DOSSIERS/FICHIERS spécifiques
du -sh /home/alice
# → Affiche l'espace utilisé par le dossier /home/alice
```

---

## 📊 du - Usage disque

### Qu'est-ce que c'est ?

`du` (Disk Usage) calcule et affiche l'espace disque utilisé par des fichiers et des dossiers spécifiques.

### Pourquoi l'utiliser ?

- Identifier les dossiers qui consomment le plus d'espace
- Nettoyer l'espace disque de manière ciblée
- Analyser la croissance des données
- Trouver les fichiers volumineux cachés
- Auditer l'utilisation du stockage

### Syntaxe

```bash
# Usage d'un dossier spécifique
du chemin/vers/dossier

# Format lisible (human-readable)
du -h chemin

# Résumé uniquement (summary)
du -sh chemin

# Trier par taille
du -h chemin | sort -rh

# Profondeur limitée
du -h --max-depth=1 chemin

# Afficher tous les fichiers (pas seulement dossiers)
du -ah chemin

# Exclure certains types de fichiers
du -h --exclude="*.log" chemin
```

> [!example] Exemples pratiques
> 
> ```bash
> # Taille totale d'un dossier
> du -sh /var/log
> # Sortie : 2.4G    /var/log
> 
> # Top 10 des plus gros dossiers dans /home
> du -h --max-depth=1 /home | sort -rh | head -10
> 
> # Tous les fichiers > 100MB dans un dossier
> du -ah /home/alice | sort -rh | head -20
> 
> # Comparer plusieurs dossiers
> du -sh /var/log /var/cache /tmp
> # Sortie :
> # 2.4G    /var/log
> # 856M    /var/cache
> # 124M    /tmp
> 
> # Voir la progression en temps réel (gros calculs)
> du -h --apparent-size /home | sort -rh
> ```

### Options importantes

|Option|Description|
|---|---|
|`-h`|Format lisible (K, M, G)|
|`-s`|Résumé uniquement (summary)|
|`-a`|Tous les fichiers, pas seulement les dossiers (all)|
|`-c`|Afficher le total à la fin|
|`-d N` / `--max-depth=N`|Limiter la profondeur de recherche|
|`--exclude=PATTERN`|Exclure des fichiers/dossiers|
|`--apparent-size`|Taille apparente (pas l'espace réellement occupé)|
|`-x`|Rester sur le même système de fichiers|
|`-L`|Suivre les liens symboliques|

### Profondeur d'analyse

```bash
# Analyse complète récursive (peut être très long)
du -h /var

# Un seul niveau de profondeur (recommandé pour commencer)
du -h --max-depth=1 /var | sort -rh
# Sortie :
# 3.2G    /var
# 2.4G    /var/log
# 450M    /var/cache
# 280M    /var/lib
# 95M     /var/tmp

# Deux niveaux
du -h --max-depth=2 /var/log | sort -rh | head -10

# Équivalent court pour --max-depth
du -h -d 1 /var
```

> [!tip] Astuce pour les gros systèmes Commencez toujours par `du -sh` puis augmentez la profondeur progressivement :
> 
> ```bash
> du -sh /                    # Vue d'ensemble
> du -h --max-depth=1 / | sort -rh | head -10  # 1er niveau
> du -h --max-depth=2 /var | sort -rh | head -10  # Zoomer sur /var
> ```

### Trouver les plus gros fichiers

```bash
# Top 20 des plus gros fichiers
du -ah /home/alice | sort -rh | head -20

# Uniquement les fichiers (pas les dossiers)
find /home/alice -type f -exec du -h {} + | sort -rh | head -20

# Fichiers > 1GB
find /home -type f -size +1G -exec du -h {} + | sort -rh

# Fichiers > 100MB dans /var
sudo find /var -type f -size +100M -exec du -h {} + | sort -rh
```

> [!example] Script de nettoyage intelligent
> 
> ```bash
> #!/bin/bash
> # Trouver les gros fichiers suspects
> 
> echo "=== Fichiers > 500MB ==="
> sudo find / -type f -size +500M -exec du -h {} + 2>/dev/null | sort -rh | head -10
> 
> echo -e "\n=== Logs volumineux ==="
> sudo du -sh /var/log/* | sort -rh | head -10
> 
> echo -e "\n=== Caches ==="
> du -sh ~/.cache ~/.local/share/Trash /var/cache 2>/dev/null
> ```

### Apparent size vs taille réelle

```bash
# Taille sur disque (blocs utilisés)
du -h fichier.txt
# → 4.0K    fichier.txt

# Taille apparente (contenu réel)
du -h --apparent-size fichier.txt
# → 156     fichier.txt
```

> [!info] Pourquoi cette différence ? Les systèmes de fichiers allouent l'espace par **blocs** (généralement 4KB). Un fichier de 156 octets occupe donc un bloc entier de 4KB sur le disque.
> 
> - `du` sans option = espace réellement occupé sur le disque
> - `du --apparent-size` = taille du contenu du fichier

### Exclure des éléments

```bash
# Exclure un dossier spécifique
du -h --exclude=node_modules /home/alice/projets

# Exclure plusieurs patterns
du -h --exclude="*.log" --exclude="*.tmp" --exclude=".cache" /home/alice

# Exclure tous les fichiers cachés
du -h --exclude=".*" /home/alice

# Script avec exclusions multiples
du -h / --exclude=/proc --exclude=/sys --exclude=/dev --exclude=/run | sort -rh | head -20
```

### Comparer l'utilisation avant/après nettoyage

```bash
# Sauvegarder l'état initial
du -sh /var/log > avant.txt

# Nettoyer les logs
sudo journalctl --vacuum-time=7d
sudo find /var/log -name "*.gz" -delete

# Comparer
du -sh /var/log > apres.txt
paste avant.txt apres.txt
```

### Cas d'usage avancés

```bash
# Analyse par type de fichier
for ext in jpg png mp4 pdf zip; do
    echo "=== .$ext ==="
    find /home/alice -name "*.$ext" -exec du -ch {} + | tail -1
done

# Trouver les doublons volumineux (avec fdupes)
fdupes -r -S /home/alice

# Comparer deux dossiers
echo "Dossier A :"
du -sh /backup/ancien
echo "Dossier B :"
du -sh /backup/nouveau

# Rapport d'audit complet
{
    echo "=== Audit disque $(date) ==="
    echo ""
    echo "Top 10 dossiers :"
    du -h --max-depth=2 /home | sort -rh | head -10
    echo ""
    echo "Gros fichiers :"
    find /home -type f -size +100M -exec du -h {} + | sort -rh | head -10
} > rapport_disque.txt
```

> [!warning] Pièges courants
> 
> - `du` peut être **très lent** sur de gros systèmes de fichiers
> - Évitez `du -a /` sans filtrage (peut prendre des heures)
> - Utilisez `--max-depth` pour limiter la récursion
> - Sur les systèmes NFS, `du` peut être extrêmement lent
> - Attention aux boucles infinies avec les liens symboliques (option `-L`)

### Différence avec df

```bash
# df = vue GLOBALE des partitions
df -h
# → Affiche TOUTES les partitions montées

# du = vue DÉTAILLÉE d'un dossier spécifique
du -sh /home/alice
# → Affiche l'espace de ce dossier uniquement

# Parfois df et du ne correspondent pas !
# Raisons possibles :
# - Fichiers supprimés mais encore ouverts par un processus
# - Réserve système (5% sur ext4 par défaut)
# - Différence entre blocs et taille apparente
```

---

## 🧠 free - Mémoire disponible

### Qu'est-ce que c'est ?

`free` affiche la quantité de mémoire RAM libre et utilisée dans le système, ainsi que l'utilisation du swap (mémoire virtuelle sur disque).

### Pourquoi l'utiliser ?

- Surveiller la consommation mémoire
- Détecter les fuites mémoire (memory leaks)
- Identifier si le système utilise le swap (ralentissements)
- Vérifier s'il reste assez de RAM pour une application
- Diagnostiquer les problèmes de performance

### Syntaxe

```bash
# Affichage par défaut (en kilooctets)
free

# Format lisible (human-readable)
free -h

# Afficher en mébioctets
free -m

# Afficher en gibioctets
free -g

# Rafraîchir toutes les N secondes
free -s 2

# Affichage large (toutes les colonnes)
free -w

# Afficher le total (ligne supplémentaire)
free -h -t
```

> [!example] Exemples pratiques
> 
> ```bash
> # Affichage standard lisible
> free -h
> # Sortie :
> #               total        used        free      shared  buff/cache   available
> # Mem:           15Gi       4.2Gi       8.1Gi       256Mi       3.0Gi        10Gi
> # Swap:         2.0Gi          0B       2.0Gi
> 
> # Surveiller en temps réel (rafraîchir chaque seconde)
> free -h -s 1
> 
> # Avec le total
> free -h -t
> # Ajoute une ligne "Total:" avec RAM + Swap
> 
> # Format large (sépare buff et cache)
> free -h -w
> ```

### Décryptage de la sortie

```bash
              total        used        free      shared  buff/cache   available
Mem:           15Gi       4.2Gi       8.1Gi       256Mi       3.0Gi        10Gi
Swap:         2.0Gi          0B       2.0Gi
```

|Colonne|Signification|
|---|---|
|**total**|Quantité totale de RAM installée|
|**used**|Mémoire utilisée par les applications|
|**free**|Mémoire complètement libre (non utilisée)|
|**shared**|Mémoire partagée (tmpfs, etc.)|
|**buff/cache**|Mémoire utilisée pour les buffers et caches|
|**available**|⭐ **Mémoire réellement disponible pour de nouvelles apps**|

> [!info] Colonne "available" - La plus importante ! **Ne regardez PAS "free", regardez "available" !**
> 
> - Linux utilise la RAM libre pour mettre en cache les fichiers (buff/cache)
> - Ces caches peuvent être libérés instantanément si besoin
> - **available** = free + cache récupérable
> - C'est la vraie quantité de mémoire disponible pour vos applications

### Comprendre la mémoire sous Linux

```bash
# ❌ FAUSSE ALARME : "free" est bas
              total        used        free      buff/cache   available
Mem:           16Gi        8Gi        1Gi            7Gi         12Gi
#                                     ↑ Semble plein          ↑ Mais beaucoup dispo !

# ✅ VRAI PROBLÈME : "available" est bas
              total        used        free      buff/cache   available
Mem:           16Gi       14Gi        1Gi            1Gi          1Gi
#                                                               ↑ Vraiment un problème !
```

> [!tip] Règle d'or **Un système Linux en bonne santé utilise presque toute sa RAM !**
> 
> - RAM libre = RAM gaspillée
> - Linux met automatiquement en cache les fichiers fréquemment utilisés
> - Si une app a besoin de mémoire, le cache est libéré automatiquement
> - Regardez toujours la colonne **available**, jamais **free**

### Le Swap - Mémoire virtuelle

```bash
Swap:         2.0Gi       500Mi       1.5Gi
              ↑           ↑           ↑
              Total       Utilisé     Libre
```

> [!warning] Utilisation du swap **Swap utilisé = problème potentiel de performance !**
> 
> - Le swap est de la mémoire sur disque (1000× plus lent que la RAM)
> - Si swap > 0 : le système manque de RAM et compense par le disque
> - Si swap > 50% du total : envisagez d'ajouter de la RAM
> - Si swap actif en continu : ralentissements garantis

```bash
# Vérifier l'utilisation du swap
free -h | grep Swap

# Si le swap est plein mais qu'il ne sert plus, le vider
sudo swapoff -a && sudo swapon -a

# Désactiver le swap (temporaire)
sudo swapoff -a

# Réactiver le swap
sudo swapon -a
```

### Seuils d'alerte

```bash
# 🟢 NORMAL : available > 20% de la RAM totale
# 🟡 ATTENTION : available < 20% de la RAM totale
# 🔴 CRITIQUE : available < 5% de la RAM totale OU swap > 50% utilisé

# Script de surveillance
#!/bin/bash
TOTAL=$(free -m | awk '/Mem:/ {print $2}')
AVAILABLE=$(free -m | awk '/Mem:/ {print $7}')
SWAP_USED=$(free -m | awk '/Swap:/ {print $3}')

PERCENT=$((AVAILABLE * 100 / TOTAL))

if [ $PERCENT -lt 5 ]; then
    echo "🔴 CRITIQUE: Seulement $PERCENT% de RAM disponible"
elif [ $PERCENT -lt 20 ]; then
    echo "🟡 ATTENTION: Seulement $PERCENT% de RAM disponible"
fi

if [ $SWAP_USED -gt 512 ]; then
    echo "⚠️  Swap utilisé: ${SWAP_USED}MB"
fi
```

### Trouver ce qui consomme la mémoire

```bash
# Top 10 des processus par consommation mémoire
ps aux --sort=-%mem | head -11

# Avec des colonnes spécifiques
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%mem | head -20

# Version avec formatage
ps -eo pid,user,%mem,rss,comm --sort=-%mem | awk 'NR==1 || NR<=11' | column -t

# Avec htop (plus visuel)
htop

# Somme de la mémoire utilisée par un processus
ps -C firefox -o rss= | awk '{sum+=$1} END {print sum/1024 " MB"}'
```

> [!example] Interpréter ps aux
> 
> ```bash
> ps aux --sort=-%mem | head -5
> # USER   PID  %CPU %MEM    VSZ   RSS TTY  STAT START   TIME COMMAND
> # alice  1234  5.2 12.3 456789 123456 ?   Sl   10:30   5:12 /usr/bin/chrome
> ```
> 
> - **%MEM** : Pourcentage de RAM utilisée
> - **RSS** : Resident Set Size (RAM réellement utilisée en KB)
> - **VSZ** : Virtual Size (mémoire virtuelle totale allouée)

### Vider les caches manuellement

```bash
# ⚠️ Généralement inutile, Linux gère très bien les caches !

# Vider le cache de pages (page cache)
sudo sync && echo 1 | sudo tee /proc/sys/vm/drop_caches

# Vider les dentries et inodes
sudo sync && echo 2 | sudo tee /proc/sys/vm/drop_caches

# Vider tout (page cache + dentries + inodes)
sudo sync && echo 3 | sudo tee /proc/sys/vm/drop_caches
```

> [!warning] NE videz PAS les caches sauf si :
> 
> - Vous faites des tests de performance précis
> - Un développeur vous le demande pour déboguer
> - Vous voulez mesurer les performances "à froid"
> 
> **Vider les caches dégrade les performances** car Linux devra tout recharger !

### Monitorer la mémoire en continu

```bash
# Toutes les 2 secondes
watch -n 2 free -h

# Avec l'historique
while true; do
    clear
    date
    free -h
    echo "---"
    ps aux --sort=-%mem | head -6
    sleep 5
done

# Logger dans un fichier
while true; do
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $(free -m | grep Mem:)" >> mem_usage.log
    sleep 60
done &
```

### Cas d'usage pratiques

```bash
# Vérifier avant de lancer une application gourmande
AVAILABLE=$(free -m | awk '/Mem:/ {print $7}')
if [ $AVAILABLE -lt 2048 ]; then
    echo "❌ Pas assez de mémoire disponible (${AVAILABLE}MB)"
    exit 1
fi

# Rapport mémoire complet
echo "=== Rapport Mémoire ==="
free -h
echo ""
echo "Top 5 processus :"
ps aux --sort=-%mem | head -6

# Alerte si swap actif
SWAP=$(free -m | awk '/Swap:/ {print $3}')
if [ "$SWAP" -gt 0 ]; then
    echo "⚠️  ATTENTION: $SWAP MB de swap utilisé"
    echo "Processus consommant le plus :"
    ps aux --sort=-%mem | head -6
fi
```

### Informations détaillées sur la mémoire

```bash
# Informations complètes depuis /proc/meminfo
cat /proc/meminfo

# Quelques lignes intéressantes
grep -E "MemTotal|MemFree|MemAvailable|Buffers|Cached|SwapTotal|SwapFree" /proc/meminfo

# Taille de la RAM totale uniquement
grep MemTotal /proc/meminfo | awk '{print $2/1024/1024 " GB"}'

# Avec vmstat (statistiques de mémoire virtuelle)
vmstat 1 5
# Rafraîchit 5 fois, toutes les secondes
```

### Différences entre les outils

|Outil|Usage principal|
|---|---|
|`free`|Vue d'ensemble RAM + swap|
|`top` / `htop`|Processus + utilisation en temps réel|
|`ps aux`|Liste détaillée des processus|
|`vmstat`|Statistiques de mémoire virtuelle|
|`/proc/meminfo`|Informations brutes du noyau|

---

## 🎯 Récapitulatif

|Commande|Usage principal|Exemple clé|
|---|---|---|
|`uname`|Infos système et noyau|`uname -a`|
|`hostname`|Nom de la machine|`hostname -f`|
|`whoami`|Utilisateur courant|`whoami`|
|`id`|Identité + groupes|`id -Gn`|
|`date`|Date/heure + calculs|`date '+%Y-%m-%d'`|
|`uptime`|Temps fonctionnement + charge|`uptime -p`|
|`df`|Espace disque des partitions|`df -h`|
|`du`|Espace de dossiers/fichiers|`du -sh /var/log`|
|`free`|Mémoire RAM et swap|`free -h`|

> [!tip] Commande de diagnostic rapide
> 
> ```bash
> # Script tout-en-un pour un aperçu système
> echo "=== 📊 État du système ==="
> echo "Système : $(uname -sr)"
> echo "Hostname : $(hostname)"
> echo "Utilisateur : $(whoami)"
> echo "Uptime : $(uptime -p)"
> echo ""
> echo "=== 💾 Disque ==="
> df -h / /home | tail -n +2
> echo ""
> echo "=== 🧠 Mémoire ==="
> free -h | grep -E "Mem|Swap"
> echo ""
> echo "=== ⚡ Charge ==="
> uptime | awk -F'load average:' '{print $2}'
> ```

---

## 📝 Pièges courants à éviter

> [!warning] Erreurs fréquentes
> 
> 1. **Regarder "free" au lieu de "available"** dans `free -h`
>     - Solution : Toujours vérifier la colonne "available"
> 2. **Paniquer quand "free" est bas**
>     - C'est normal ! Linux utilise la RAM libre pour les caches
> 3. **Utiliser `du` sans limite de profondeur**
>     - Peut prendre des heures sur `/`
>     - Toujours commencer par `--max-depth=1`
> 4. **Confondre `df` et `du`**
>     - `df` = partitions entières
>     - `du` = dossiers/fichiers spécifiques
> 5. **Oublier que le load average dépend du nombre de cœurs**
>     - Load de 4.0 = OK sur 8 cœurs, critique sur 2 cœurs
> 6. **Modifier le hostname sans mettre à jour `/etc/hosts`**
>     - Peut casser des services
> 7. **Vider les caches mémoire sans raison**
>     - Dégrade les performances
> 8. **Ignorer l'utilisation du swap**
>     - Swap actif = ralentissements garantis

---

## 💡 Bonnes pratiques

1. **Surveillez régulièrement** : Créez des scripts de monitoring
2. **Documentez votre environnement** : `uname -a`, `hostname`, etc.
3. **Automatisez les alertes** : Seuils pour disque, RAM, load
4. **Nettoyez régulièrement** : Logs, caches, anciens fichiers
5. **Utilisez `watch`** pour surveiller en temps réel
6. **Combinez les commandes** pour des rapports complets
7. **Loggez les métriques** pour analyser les tendances
8. **Adaptez les seuils** à votre environnement spécifique

---

_Fin du cours 5.2 - Informations système_ifier si le système est 64 bits if [ "$(uname -m)" = "x86_64" ]; then echo "Système 64 bits détecté" fi

# Script qui s'adapte au système

KERNEL=$(uname -s) if [ "$KERNEL" = "Linux" ]; then echo "Configuration pour Linux" elif [ "$KERNEL" = "Darwin" ]; then echo "Configuration pour macOS" fi

````

---

## 🌐 hostname - Nom de la machine

### Qu'est-ce que c'est ?

`hostname` affiche ou modifie le nom réseau de la machine (le nom par lequel elle est identifiée sur le réseau).

### Pourquoi l'utiliser ?

- Identifier rapidement la machine sur laquelle vous travaillez
- Vérifier la configuration réseau
- Éviter les erreurs lors de connexions SSH multiples
- Personnaliser le prompt du shell

### Syntaxe

```bash
# Afficher le hostname
hostname

# Afficher le nom de domaine complet (FQDN)
hostname -f
hostname --fqdn

# Afficher le nom de domaine DNS
hostname -d
hostname --domain

# Afficher l'adresse IP associée
hostname -I
hostname --all-ip-addresses

# Afficher uniquement la première adresse IP
hostname -i

# Modifier le hostname (nécessite root, temporaire jusqu'au redémarrage)
sudo hostname nouveau-nom
````

> [!example] Exemples pratiques
> 
> ```bash
> # Simple hostname
> hostname
> # Sortie : serveur-web
> 
> # FQDN (Fully Qualified Domain Name)
> hostname -f
> # Sortie : serveur-web.monentreprise.local
> 
> # Toutes les adresses IP
> hostname -I
> # Sortie : 192.168.1.100 172.17.0.1
> 
> # Dans un script pour logger
> echo "[$(date)] Action sur $(hostname)" >> /var/log/monscript.log
> ```

### Hostname vs FQDN

```bash
# Hostname simple (nom court)
hostname
# → monserveur

# FQDN (nom complet avec domaine)
hostname -f
# → monserveur.exemple.com

# Domaine uniquement
hostname -d
# → exemple.com
```

> [!info] Différence importante
> 
> - **Hostname** : nom local de la machine
> - **FQDN** : nom complet incluant le domaine (utilisé pour la résolution DNS)
> - Le FQDN est configuré dans `/etc/hosts` ou via le serveur DNS

### Modifier le hostname de façon permanente

```bash
# Méthode moderne (systemd)
sudo hostnamectl set-hostname nouveau-nom

# Vérifier le changement
hostnamectl

# Ancienne méthode (éditer directement)
sudo nano /etc/hostname
# Puis redémarrer ou exécuter : sudo systemctl restart systemd-logind
```

> [!warning] Attention lors du changement de hostname
> 
> - Pensez à mettre à jour `/etc/hosts` également
> - Certains services peuvent nécessiter un redémarrage
> - Les certificats SSL peuvent être liés au hostname

### Astuces

```bash
# Ajouter le hostname au prompt bash (dans ~/.bashrc)
PS1="\u@\h:\w\$ "
# \h = hostname, \u = username, \w = working directory

# Utiliser le hostname dans les scripts
BACKUP_FILE="backup_$(hostname)_$(date +%Y%m%d).tar.gz"
# → backup_monserveur_20231215.tar.gz
```

---

## 👤 whoami - Utilisateur courant

### Qu'est-ce que c'est ?

`whoami` affiche le nom de l'utilisateur actuellement connecté (l'utilisateur effectif qui exécute la commande).

### Pourquoi l'utiliser ?

- Vérifier sous quel utilisateur vous êtes connecté
- Confirmer que vous n'êtes pas root avant une action sensible
- Utile dans les scripts pour adapter le comportement
- Vérifier l'identité après un `su` ou `sudo -i`

### Syntaxe

```bash
# Afficher l'utilisateur courant
whoami

# Équivalent avec id
id -un
```

> [!example] Exemples pratiques
> 
> ```bash
> # Vérification simple
> whoami
> # Sortie : alice
> 
> # Après passage en root
> sudo -i
> whoami
> # Sortie : root
> 
> # Dans un script de sécurité
> if [ "$(whoami)" = "root" ]; then
>     echo "⚠️  ATTENTION : Vous êtes root !"
> fi
> 
> # Bloquer l'exécution si on n'est pas root
> if [ "$(whoami)" != "root" ]; then
>     echo "Ce script nécessite les droits root"
>     exit 1
> fi
> ```

### Différence avec d'autres commandes

```bash
# whoami : utilisateur effectif
whoami
# → alice

# who : tous les utilisateurs connectés au système
who
# → alice    pts/0    2024-12-13 10:30 (192.168.1.50)
# → bob      pts/1    2024-12-13 11:15 (192.168.1.51)

# w : utilisateurs connectés + ce qu'ils font
w
# Affiche la charge système + activité de chaque utilisateur

# logname : utilisateur qui s'est connecté initialement
logname
# → alice (même après sudo -i)

# $USER : variable d'environnement
echo $USER
# → alice
```

> [!tip] Astuce : whoami vs $USER
> 
> - `whoami` reflète l'utilisateur **effectif** actuel (après `su` ou `sudo`)
> - `$USER` conserve souvent le nom de l'utilisateur **initial**
> - Pour les scripts, préférez `whoami` ou `id -un` qui sont plus fiables

### Cas d'usage dans les scripts

```bash
#!/bin/bash
# Script qui s'adapte selon l'utilisateur

CURRENT_USER=$(whoami)

if [ "$CURRENT_USER" = "root" ]; then
    CONFIG_DIR="/etc/monapp"
    LOG_FILE="/var/log/monapp.log"
else
    CONFIG_DIR="$HOME/.config/monapp"
    LOG_FILE="$HOME/.local/share/monapp.log"
fi

echo "Configuration dans : $CONFIG_DIR"
echo "Logs dans : $LOG_FILE"
```

---

## 🆔 id - Identité complète

### Qu'est-ce que c'est ?

`id` affiche l'identité complète d'un utilisateur : UID (User ID), GID (Group ID), et tous les groupes auxquels il appartient.

### Pourquoi l'utiliser ?

- Obtenir l'UID et le GID (nécessaires pour certaines configurations)
- Vérifier les appartenances aux groupes (droits d'accès)
- Déboguer les problèmes de permissions
- Plus complet que `whoami` pour comprendre les droits

### Syntaxe

```bash
# Afficher toutes les informations de l'utilisateur courant
id

# Afficher les infos d'un autre utilisateur
id nom_utilisateur

# Options spécifiques
id -u          # UID uniquement
id -g          # GID du groupe principal uniquement
id -G          # Tous les GIDs (groupes secondaires)
id -un         # Nom d'utilisateur
id -gn         # Nom du groupe principal
id -Gn         # Noms de tous les groupes
```

> [!example] Exemples pratiques
> 
> ```bash
> # Information complète
> id
> # Sortie : uid=1000(alice) gid=1000(alice) groupes=1000(alice),4(adm),27(sudo),44(video)
> 
> # UID uniquement (utile dans scripts)
> id -u
> # Sortie : 1000
> 
> # Vérifier si on est dans le groupe sudo
> id -Gn | grep -q sudo && echo "Vous avez les droits sudo"
> 
> # Comparer deux utilisateurs
> echo "Alice : $(id alice)"
> echo "Bob : $(id bob)"
> 
> # Dans un script Dockerifle
> USER_UID=$(id -u)
> USER_GID=$(id -g)
> ```

### Décryptage de la sortie

```bash
uid=1000(alice) gid=1000(alice) groupes=1000(alice),4(adm),27(sudo),44(video),998(docker)
```

|Élément|Signification|
|---|---|
|`uid=1000`|User ID numérique (identifiant unique)|
|`(alice)`|Nom d'utilisateur correspondant|
|`gid=1000`|Group ID principal|
|`groupes=...`|Liste de tous les groupes (principal + secondaires)|
|`4(adm)`|Groupe 4 nommé "adm" (lecture logs système)|
|`27(sudo)`|Groupe sudo (droits d'administration)|
|`44(video)`|Accès aux périphériques vidéo|
|`998(docker)`|Groupe docker (exécuter des conteneurs)|

> [!info] Les UID spéciaux
> 
> - **0** : root (superutilisateur)
> - **1-999** : utilisateurs système (services, démons)
> - **1000+** : utilisateurs normaux (premier utilisateur humain = 1000)

### Vérifier les appartenances aux groupes

```bash
# Lister tous les groupes avec leurs noms
id -Gn
# Sortie : alice adm sudo video docker

# Vérifier si on appartient à un groupe spécifique
groups
# Sortie : alice adm sudo video docker

# Vérifier pour un autre utilisateur
groups bob

# Connaître le GID d'un groupe
getent group sudo
# Sortie : sudo:x:27:alice,bob
```

### Cas d'usage pratiques

```bash
# Script qui nécessite les droits sudo
if ! id -Gn | grep -q sudo; then
    echo "❌ Vous devez être dans le groupe sudo"
    exit 1
fi

# Créer un fichier avec le bon propriétaire dans un script
CURRENT_UID=$(id -u)
CURRENT_GID=$(id -g)
touch fichier.txt
chown $CURRENT_UID:$CURRENT_GID fichier.txt

# Docker : éviter de lancer en root
if [ "$(id -u)" = "0" ]; then
    echo "⚠️  Ne lancez pas ce conteneur en root"
    exit 1
fi
```

> [!warning] Groupes et nouvelles sessions Si vous venez d'être ajouté à un groupe (ex: `sudo usermod -aG docker alice`), vous devez :
> 
> 1. Fermer votre session
> 2. Vous reconnecter
> 3. Ou utiliser `newgrp nom_du_groupe` pour activer immédiatement
> 
> `id` ne reflétera le changement qu'après reconnexion !

---

## 📅 date - Date et heure système

### Qu'est-ce que c'est ?

`date` affiche ou configure la date et l'heure du système. C'est un outil essentiel pour l'horodatage, la planification et les logs.

### Pourquoi l'utiliser ?

- Horodater des fichiers de log
- Créer des noms de fichiers avec timestamp
- Vérifier le fuseau horaire du système
- Calculer des dates futures ou passées
- Convertir entre différents formats de date

### Syntaxe de base

```bash
# Afficher date et heure actuelles (format par défaut)
date

# Afficher avec un format personnalisé
date +FORMAT

# Afficher une date spécifique
date -d "chaîne de date"
date --date="chaîne de date"

# Modifier la date système (nécessite root)
sudo date -s "YYYY-MM-DD HH:MM:SS"
```

> [!example] Exemples de formats
> 
> ```bash
> # Format par défaut
> date
> # Sortie : mer. 13 déc. 2024 14:35:22 CET
> 
> # Format ISO 8601 (standard international)
> date +%Y-%m-%d
> # Sortie : 2024-12-13
> 
> # Date et heure complètes
> date "+%Y-%m-%d %H:%M:%S"
> # Sortie : 2024-12-13 14:35:22
> 
> # Timestamp Unix (secondes depuis 1970)
> date +%s
> # Sortie : 1702478122
> 
> # Format pour noms de fichiers
> date +%Y%m%d_%H%M%S
> # Sortie : 20241213_143522
> ```

### Formats personnalisés - Principaux codes

|Code|Signification|Exemple|
|---|---|---|
|`%Y`|Année (4 chiffres)|2024|
|`%y`|Année (2 chiffres)|24|
|`%m`|Mois (01-12)|12|
|`%B`|Nom du mois complet|décembre|
|`%b` / `%h`|Nom du mois abrégé|déc|
|`%d`|Jour du mois (01-31)|13|
|`%A`|Nom du jour complet|mercredi|
|`%a`|Nom du jour abrégé|mer|
|`%H`|Heure (00-23)|14|
|`%I`|Heure (01-12)|02|
|`%M`|Minutes (00-59)|35|
|`%S`|Secondes (00-59)|22|
|`%p`|AM/PM|PM|
|`%s`|Timestamp Unix|1702478122|
|`%Z`|Fuseau horaire|CET|
|`%z`|Décalage horaire|+0100|

> [!tip] Formats prédéfinis pratiques
> 
> ```bash
> # Format RFC 3339 (pour les logs)
> date --rfc-3339=seconds
> # → 2024-12-13 14:35:22+01:00
> 
> # Format ISO 8601 complet
> date --iso-8601=seconds
> # → 2024-12-13T14:35:22+01:00
> 
> # Format RFC 2822 (emails)
> date --rfc-email
> # → Wed, 13 Dec 2024 14:35:22 +0100
> ```

### Manipulations de dates

```bash
# Date d'hier
date -d "yesterday"
date -d "1 day ago"

# Date de demain
date -d "tomorrow"
date -d "1 day"

# Dans une semaine
date -d "1 week"
date -d "7 days"

# Il y a 3 mois
date -d "3 months ago"

# Date spécifique + calcul
date -d "2024-12-01 +15 days"
# → Lun 16 déc 2024

# Combiner plusieurs opérations
date -d "next monday +2 weeks"

# Premier jour du mois prochain
date -d "next month" +%Y-%m-01
```

> [!example] Cas d'usage pratiques
> 
> ```bash
> # Créer un fichier de backup avec date
> cp fichier.txt "fichier_backup_$(date +%Y%m%d).txt"
> # → fichier_backup_20241213.txt
> 
> # Logger avec timestamp
> echo "[$(date '+%Y-%m-%d %H:%M:%S')] Opération effectuée" >> app.log
> 
> # Créer un dossier par mois
> mkdir "rapports_$(date +%Y-%m)"
> # → rapports_2024-12
> 
> # Archiver avec horodatage précis
> tar -czf "backup_$(date +%Y%m%d_%H%M%S).tar.gz" /dossier
> 
> # Calculer une date d'expiration
> DATE_EXPIRATION=$(date -d "+30 days" +%Y-%m-%d)
> echo "Expire le : $DATE_EXPIRATION"
> ```

### Afficher l'heure dans différents fuseaux horaires

```bash
# Heure locale
date

# Heure UTC
date -u
date --utc

# Heure dans un autre fuseau horaire
TZ='America/New_York' date
TZ='Asia/Tokyo' date
TZ='Europe/Paris' date

# Lister les fuseaux disponibles
timedatectl list-timezones

# Changer le fuseau horaire système (permanent)
sudo timedatectl set-timezone Europe/Paris
```

### Calculer la différence entre deux dates

```bash
# Nombre de jours entre deux dates
date1=$(date -d "2024-01-01" +%s)
date2=$(date -d "2024-12-13" +%s)
diff_seconds=$((date2 - date1))
diff_days=$((diff_seconds / 86400))
echo "$diff_days jours"
# → 347 jours

# Convertir un timestamp en date lisible
date -d @1702478122
# → mer. 13 déc. 2024 14:35:22 CET
```

> [!warning] Attention aux formats de date
> 
> - Les formats de date varient selon la locale du système
> - `date -d` accepte de nombreux formats mais peut être ambigu (01/02 = 1er février ou 2 janvier ?)
> - Privilégiez le format ISO `YYYY-MM-DD` pour éviter les ambiguïtés
> - La commande `date -d` n'est pas disponible sur tous les Unix (BSD/macOS utilisent une syntaxe différente)

### Synchronisation de l'heure

```bash
# Vérifier l'état de synchronisation NTP
timedatectl status

# Afficher les serveurs NTP utilisés
timedatectl show-timesync --all

# Activer la synchronisation automatique
sudo timedatectl set-ntp true

# Forcer une synchronisation (si chrony est installé)
sudo chronyc -a makestep
```

---

## ⏱️ uptime - Temps de fonctionnement

### Qu'est-ce que c'est ?

`uptime` affiche depuis combien de temps le système fonctionne sans interruption, le nombre d'utilisateurs connectés, et la charge moyenne du système.

### Pourquoi l'utiliser ?

- Vérifier si le serveur a redémarré récemment
- Surveiller la stabilité du système
- Détecter une surcharge (load average élevée)
- Confirmer qu'un reboot a bien eu lieu
- Évaluer les performances globales

### Syntaxe

```bash
# Afficher le temps de fonctionnement
uptime

# Format compact (uptime uniquement)
uptime -p
uptime --pretty

# Date du dernier démarrage
uptime -s
uptime --since
```

> [!example] Exemples pratiques
> 
> ```bash
> # Sortie complète
> uptime
> # → 14:35:22 up 45 days, 3:12, 2 users, load average: 0.15, 0.25, 0.30
> 
> # Format lisible
> uptime -p
> # → up 45 days, 3 hours, 12 minutes
> 
> # Date de démarrage
> uptime -s
> # → 2024-10-29 11:23:15
> 
> # Depuis combien de temps le serveur tourne
> echo "Serveur démarré le $(uptime -s)"
> ```

### Décryptage de la sortie

```bash
14:35:22 up 45 days, 3:12, 2 users, load average: 0.15, 0.25, 0.30
```

|Élément|Signification|
|---|---|
|`14:35:22`|Heure actuelle|
|`up 45 days, 3:12`|Temps depuis le dernier démarrage|
|`2 users`|Nombre d'utilisateurs connectés actuellement|
|`load average: 0.15, 0.25, 0.30`|Charge moyenne sur 1, 5 et 15 minutes|

### Comprendre le Load Average

Le **load average** représente le nombre moyen de processus en attente d'exécution CPU.

```bash
load average: 0.15, 0.25, 0.30
              └─1min └─5min └─15min
```

> [!info] Interprétation du load average **Pour un système avec N cœurs CPU** :
> 
> - **Load < N** : Le système n'est pas surchargé ✅
> - **Load = N** : Le système est pleinement utilisé ⚠️
> - **Load > N** : Le système est en surcharge 🔴
> 
> Exemple avec 4 cœurs CPU :
> 
> - `load average: 2.0, 1.5, 1.0` → OK (2 < 4)
> - `load average: 4.0, 3.8, 4.1` → Limite haute
> - `load average: 8.0, 7.5, 6.0` → SURCHARGÉ !

```bash
# Connaître le nombre de cœurs CPU
nproc
# ou
grep -c processor /proc/cpuinfo
```

### Tendances et alertes

```bash
# Comparer les 3 valeurs pour identifier les tendances

# Load CROISSANT = problème qui s'aggrave
load average: 0.5, 1.2, 2.8
              └─récent  └─ancien

# Load DÉCROISSANT = problème résolu ou en amélioration
load average: 2.8, 1.2, 0.5

# Load STABLE = charge constante
load average: 1.5, 1.4, 1.6
```

> [!warning] Pièges courants
> 
> - Un load average élevé sur **1 minute** peut être un pic temporaire (pas alarmant)
> - Un load average élevé sur **15 minutes** indique un problème persistant
> - Sur les systèmes modernes multi-cœurs, comparez toujours au nombre de cœurs
> - Un load de 1.0 sur un système 8 cœurs = très faible utilisation (12.5%)

### Cas d'usage pratiques

```bash
# Vérifier rapidement l'état du serveur
uptime

# Script de monitoring simple
LOAD=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | tr -d ',')
if (( $(echo "$LOAD > 4.0" | bc -l) )); then
    echo "⚠️  ALERTE : Charge système élevée : $LOAD"
fi

# Vérifier si le serveur a redémarré récemment
UPTIME_DAYS=$(uptime -p | grep -oP '\d+(?= day)')
if [ "$UPTIME_DAYS" -lt 1 ]; then
    echo "⚠️  Le serveur a redémarré il y a moins de 24h"
fi

# Afficher un rapport système simple
echo "=== Rapport système ==="
echo "Hostname: $(hostname)"
echo "Uptime: $(uptime -p)"
echo "Charge: $(uptime | awk -F'load average:' '{print $2}')"
```

### Alternatives et compléments

```bash
# Voir le temps de fonctionnement dans /proc
cat /proc/uptime
# → 3896745.23 3645872.11
#   └─secondes  └─idle time

# Historique des redémarrages (avec last)
last reboot

# Temps de fonctionnement + infos détaillées
w

# Surveiller la charge en temps réel
watch -n 1 uptime

# Top pour voir quels processus consomment
top
htop  # Version améliorée
```

---

## 💾 df - Espace disque

### Qu'est-ce que c'est ?

`df` (Disk Free) affiche l'espace disque disponible et utilisé sur tous les systèmes de fichiers montés.

### Pourquoi l'utiliser ?

- Surveiller l'espace disque disponible
- Identifier les partitions pleines
- Prévenir les problèmes d'espace disque (logs, bases de données)
- Vérifier le montage des périphériques
- Planifier l'ajout de stockage

### Syntaxe

```bash
# Afficher l'espace disque de toutes les partitions
df

# Format lisible par l'humain (human-readable)
df -h

# Afficher uniquement les systèmes de fichiers locaux (pas les montages réseau)
df -l

# Afficher le type de système de fichiers
df -T

# Afficher en inodes au lieu de blocs
df -i

# Afficher un système de fichiers spécifique
df /chemin/vers/dossier

# Exclure les systèmes de fichiers temporaires
df -h -x tmpfs -x devtmpfs
```

> [!example] Exemples pratiques
> 
> ```bash
> # Affichage standard lisible
> df -h
> # Sortie :
> # Filesystem      Size  Used Avail Use% Mounted on
> # /dev/sda1       100G   45G   50G  48% /
> # /dev/sdb1       500G  350G  150G  70% /home
> # tmpfs           7.8G  1.2M  7.8G   1% /run
> 
> # Avec le type de système de fichiers
> df -Th
> # Ajoute une colonne "Type" (ext4, xfs, btrfs, etc.)
> 
> # Vér
> ```