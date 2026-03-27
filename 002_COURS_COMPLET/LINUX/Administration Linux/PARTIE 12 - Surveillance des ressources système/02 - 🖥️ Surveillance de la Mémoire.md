

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

La surveillance de la mémoire est une compétence essentielle en administration Linux. Contrairement à d'autres systèmes d'exploitation, Linux gère la mémoire de manière très efficace en utilisant la RAM libre pour du cache, ce qui peut prêter à confusion lors de l'analyse. Cette partie vous apprendra à interpréter correctement l'utilisation de la mémoire et à identifier les véritables problèmes de performance.

> [!info] Pourquoi surveiller la mémoire ?
> 
> - Détecter les applications gourmandes en RAM
> - Identifier les risques de saturation mémoire
> - Optimiser les performances du système
> - Anticiper les besoins en ressources

---

## La commande free

La commande `free` est l'outil de base pour consulter l'utilisation de la mémoire RAM et du swap sous Linux.

### Syntaxe et options

```bash
free [options]
```

> [!example] Exemples d'utilisation
> 
> ```bash
> # Affichage basique
> free
> 
> # Affichage en format lisible (human-readable)
> free -h
> 
> # Affichage en méga-octets
> free -m
> 
> # Affichage en giga-octets
> free -g
> 
> # Rafraîchissement continu toutes les 2 secondes
> free -h -s 2
> 
> # Affichage du total (somme RAM + swap)
> free -h -t
> 
> # Affichage large (wide) avec plus de détails
> free -h -w
> ```

### Interprétation des colonnes

Voici un exemple typique de sortie de `free -h` :

```bash
              total        used        free      shared  buff/cache   available
Mem:           15Gi       3.2Gi       8.1Gi       421Mi       4.0Gi        11Gi
Swap:         2.0Gi          0B       2.0Gi
```

|Colonne|Description|
|---|---|
|**total**|Quantité totale de RAM physique installée|
|**used**|Mémoire utilisée par les processus (hors cache/buffers)|
|**free**|Mémoire complètement inutilisée (généralement faible)|
|**shared**|Mémoire partagée entre processus (tmpfs, segments partagés)|
|**buff/cache**|Mémoire utilisée pour le cache et les buffers|
|**available**|**LA PLUS IMPORTANTE** : mémoire réellement disponible pour de nouvelles applications|

> [!warning] Piège courant Ne vous fiez PAS à la colonne "free" ! Elle est souvent très basse car Linux utilise intelligemment toute la RAM disponible. C'est la colonne **"available"** qui indique la mémoire réellement disponible pour lancer de nouveaux programmes.

### Options utiles

|Option|Description|Exemple|
|---|---|---|
|`-h`|Format lisible (human-readable)|`free -h`|
|`-m`|Affichage en mégaoctets|`free -m`|
|`-g`|Affichage en gigaoctets|`free -g`|
|`-s N`|Rafraîchissement toutes les N secondes|`free -h -s 3`|
|`-t`|Afficher le total (RAM + swap)|`free -h -t`|
|`-w`|Mode wide (sépare buffers et cache)|`free -h -w`|
|`-c N`|Répéter N fois puis arrêter|`free -h -s 2 -c 5`|

> [!tip] Astuce de surveillance continue
> 
> ```bash
> # Surveiller la mémoire en temps réel avec watch
> watch -n 1 free -h
> 
> # Ou avec l'option intégrée
> free -h -s 1
> ```

---

## Comprendre la mémoire cache et buffers

C'est l'aspect le plus mal compris de la gestion mémoire sous Linux. Comprendre ce mécanisme est crucial pour une bonne analyse.

### Différence entre cache et buffers

Linux utilise la RAM non utilisée pour améliorer les performances du système. Cette utilisation se divise en deux catégories :

**Cache (page cache)** :

- Stocke le contenu des fichiers lus depuis le disque
- Accélère les lectures répétées des mêmes fichiers
- Libéré automatiquement si une application a besoin de RAM

**Buffers** :

- Stocke les métadonnées du système de fichiers
- Informations sur les inodes, la structure des répertoires
- Optimise les opérations sur les fichiers

> [!example] Visualisation avec l'option -w
> 
> ```bash
> free -h -w
> ```
> 
> ```
>               total        used        free      shared     buffers       cache   available
> Mem:           15Gi       3.2Gi       7.1Gi       421Mi       150Mi       3.8Gi        11Gi
> Swap:         2.0Gi          0B       2.0Gi
> ```

### La mémoire "available"

La colonne **available** est calculée selon cette logique :

```
available = free + (buff/cache récupérable)
```

Cette valeur représente la quantité de mémoire qu'un nouveau processus peut utiliser **sans provoquer de swap**.

> [!info] Formule simplifiée
> 
> ```
> Mémoire disponible ≈ Free + Cache/Buffers
> ```
> 
> Le noyau Linux peut libérer instantanément le cache et les buffers si nécessaire.

### Pourquoi Linux utilise toute la RAM

> [!tip] Principe fondamental de Linux **"La RAM inutilisée est de la RAM gaspillée"**

Linux adopte une philosophie proactive :

1. **Lecture d'un fichier** → Le contenu est mis en cache
2. **Relecture du même fichier** → Lecture depuis la RAM (ultra-rapide)
3. **Besoin de RAM pour un processus** → Le cache est automatiquement libéré

```bash
# Exemple : lecture d'un gros fichier
time cat fichier_volumineux.iso > /dev/null  # Première fois : lent
time cat fichier_volumineux.iso > /dev/null  # Deuxième fois : quasi instantané (lu depuis le cache)
```

> [!example] Démonstration pratique
> 
> ```bash
> # Voir le cache augmenter lors de la lecture de fichiers
> free -h && dd if=/dev/zero of=testfile bs=1M count=1000 && free -h
> 
> # Observer la colonne buff/cache augmenter
> ```

> [!warning] Signe d'un vrai problème de mémoire Votre système manque VRAIMENT de mémoire si :
> 
> - La colonne **available** est < 10% de la RAM totale
> - Le **swap** est fortement utilisé (et en augmentation)
> - Les processus commencent à être tués par l'OOM Killer
> 
> Si seule la colonne "free" est basse mais "available" est élevée → **tout va bien** !

---

## Surveillance du swap

### Qu'est-ce que le swap

Le swap est un espace sur le disque utilisé comme extension de la RAM lorsque celle-ci est saturée.

**Types de swap** :

- **Partition swap** : partition dédiée (plus courant)
- **Fichier swap** : fichier standard utilisé comme swap

> [!info] Caractéristiques du swap
> 
> - **Beaucoup plus lent** que la RAM (facteur 100 à 1000)
> - Permet d'éviter les crashs quand la RAM est pleine
> - L'utilisation intensive du swap dégrade fortement les performances
> - Ne remplace pas la RAM, c'est une solution de secours

### Analyser l'utilisation du swap

```bash
# Voir l'état du swap avec free
free -h

# Informations détaillées sur le swap
swapon --show

# Exemple de sortie :
# NAME      TYPE      SIZE USED PRIO
# /swapfile file      2G   0B   -2
```

> [!example] Commandes de surveillance du swap
> 
> ```bash
> # Voir l'utilisation actuelle du swap
> free -h | grep Swap
> 
> # Voir quel processus utilise le swap
> for pid in /proc/[0-9]*; do 
>     printf "%s: %s KB\n" "$(basename $pid)" \
>     "$(grep VmSwap $pid/status 2>/dev/null | awk '{print $2}')"; 
> done | grep -v ": 0 KB" | sort -t: -k2 -n
> 
> # Statistiques de swap en temps réel
> vmstat 1
> # La colonne 'si' (swap in) et 'so' (swap out) indiquent l'activité
> ```

**Interprétation de vmstat** :

```bash
vmstat 1
```

```
procs -----------memory---------- ---swap-- -----io---- -system-- ------cpu-----
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st
 1  0      0 8234556 154236 3891248   0    0     5     8   45   67  2  1 97  0  0
```

|Colonne swap|Signification|
|---|---|
|**si**|Swap In : pages lues depuis le swap (KB/s)|
|**so**|Swap Out : pages écrites vers le swap (KB/s)|

> [!warning] Signes d'alerte
> 
> - **si** et **so** constamment > 0 : le système "thrash" (va-et-vient constant entre RAM et swap)
> - Swap utilisé > 50% de sa capacité
> - Utilisation du swap en augmentation constante
> 
> → Il est temps d'ajouter de la RAM !

### Swappiness et configuration

Le **swappiness** contrôle l'agressivité avec laquelle le noyau utilise le swap.

```bash
# Voir la valeur actuelle (par défaut : 60)
cat /proc/sys/vm/swappiness

# Valeur entre 0 et 100
# 0 = éviter le swap au maximum (sauf urgence absolue)
# 100 = utiliser le swap agressivement
```

> [!tip] Recommandations de swappiness
> 
> |Valeur|Usage recommandé|
> |---|---|
> |**0-10**|Serveurs avec beaucoup de RAM, performances critiques|
> |**10-30**|Serveurs de base de données, applications en mémoire|
> |**60**|Valeur par défaut, bon compromis|
> |**80-100**|Systèmes avec peu de RAM, desktop avec hibernation|

**Modifier temporairement** (perdu au redémarrage) :

```bash
# Réduire le swappiness à 10
sudo sysctl vm.swappiness=10

# Vérifier
cat /proc/sys/vm/swappiness
```

**Modifier définitivement** :

```bash
# Éditer le fichier de configuration
sudo nano /etc/sysctl.conf

# Ajouter la ligne :
vm.swappiness=10

# Appliquer sans redémarrer
sudo sysctl -p
```

> [!example] Cas pratique : serveur web
> 
> ```bash
> # Pour un serveur web avec 16 GB de RAM
> # On veut éviter le swap sauf urgence
> 
> # 1. Vérifier la configuration actuelle
> free -h
> cat /proc/sys/vm/swappiness
> 
> # 2. Réduire le swappiness
> echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf
> sudo sysctl -p
> 
> # 3. Surveiller l'effet
> watch -n 2 'free -h && echo && vmstat 1 2 | tail -1'
> ```

> [!warning] Attention avec swappiness=0 Sur les versions récentes du noyau, `swappiness=0` ne désactive PAS complètement le swap. Le noyau peut toujours swapper en cas de pression mémoire extrême. Pour vraiment désactiver le swap :
> 
> ```bash
> # Désactiver complètement le swap (temporaire)
> sudo swapoff -a
> 
> # Réactiver le swap
> sudo swapon -a
> 
> # Pour désactiver définitivement : commenter les lignes swap dans /etc/fstab
> ```

---

## 🎯 Récapitulatif

|Commande|Usage principal|
|---|---|
|`free -h`|Vue d'ensemble de la mémoire|
|`free -h -w`|Détailler buffers et cache séparément|
|`free -h -s 2`|Surveillance continue|
|`swapon --show`|Informations sur le swap|
|`vmstat 1`|Statistiques détaillées en temps réel|
|`cat /proc/sys/vm/swappiness`|Voir le comportement du swap|

> [!tip] Checklist de surveillance mémoire ✅ Surveiller la colonne **available**, pas **free**  
> ✅ Le cache/buffers élevés sont **normaux et souhaitables**  
> ✅ Le swap utilisé n'est problématique que s'il **augmente constamment**  
> ✅ Ajuster le swappiness selon le type de serveur  
> ✅ Si available < 10% de la RAM → envisager d'ajouter de la mémoire

---

_Ce document fait partie du cours d'Administration Linux - Surveillance des ressources_