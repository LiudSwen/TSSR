

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

## 🎯 Introduction

La visualisation des processus est une compétence fondamentale en administration Linux. Elle permet de comprendre ce qui s'exécute sur le système, d'identifier les problèmes de performance, et de diagnostiquer les comportements anormaux.

> [!info] Qu'est-ce qu'un processus ? Un processus est une instance d'un programme en cours d'exécution. Chaque processus possède un identifiant unique (PID), un parent (PPID), et consomme des ressources système (CPU, mémoire).

---

## 📊 La commande ps

### Fonctionnement de base

La commande `ps` (Process Status) affiche un instantané des processus actifs au moment de son exécution.

```bash
# Afficher uniquement les processus du terminal courant
ps

# Résultat typique :
#   PID TTY          TIME CMD
#  1234 pts/0    00:00:00 bash
#  5678 pts/0    00:00:00 ps
```

> [!warning] Attention aux syntaxes `ps` accepte trois types de syntaxes différentes :
> 
> - **UNIX** : avec tirets (`-aux`)
> - **BSD** : sans tirets (`aux`)
> - **GNU** : double tirets (`--help`)
> 
> Ces syntaxes ne sont pas toujours interchangeables !

### Options courantes

#### 🔹 `ps aux` (syntaxe BSD)

L'option la plus utilisée pour avoir une vue d'ensemble complète du système.

```bash
ps aux

# a = afficher les processus de tous les utilisateurs
# u = format orienté utilisateur (user-oriented)
# x = inclure les processus sans terminal de contrôle (daemons)
```

**Exemple de sortie :**

```
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.1 168548 11234 ?        Ss   08:23   0:01 /sbin/init
www-data  1234  2.3  1.5 456789 98765 ?        S    09:15   0:45 nginx: worker
john      5678  0.5  0.8 234567 54321 pts/0    R+   10:30   0:02 vim document.txt
```

> [!example] Décryptage des colonnes
> 
> - **USER** : propriétaire du processus
> - **PID** : identifiant unique du processus
> - **%CPU** : pourcentage d'utilisation CPU
> - **%MEM** : pourcentage de mémoire physique (RAM)
> - **VSZ** : taille mémoire virtuelle (en Ko)
> - **RSS** : mémoire résidente (RAM réellement utilisée, en Ko)
> - **TTY** : terminal associé (? = aucun terminal)
> - **STAT** : état du processus (voir ci-dessous)
> - **START** : heure de démarrage
> - **TIME** : temps CPU cumulé
> - **COMMAND** : commande exécutée

#### 🔹 `ps -ef` (syntaxe UNIX)

Alternative populaire affichant une vue hiérarchique avec les PPID.

```bash
ps -ef

# e = tous les processus (every)
# f = format complet (full-format) avec hiérarchie
```

**Exemple de sortie :**

```
UID        PID  PPID  C STIME TTY          TIME CMD
root         1     0  0 08:23 ?        00:00:01 /sbin/init
root       123     1  0 08:23 ?        00:00:00 /lib/systemd/systemd-journald
www-data  1234   123  0 09:15 ?        00:00:45 nginx: worker process
```

> [!tip] Quand utiliser quelle option ?
> 
> - `ps aux` : pour analyser l'utilisation des ressources (%CPU, %MEM)
> - `ps -ef` : pour comprendre la hiérarchie parent-enfant (PPID)

#### 🔹 `ps -u <utilisateur>` (filtrer par utilisateur)

Afficher uniquement les processus d'un utilisateur spécifique.

```bash
# Processus de l'utilisateur "john"
ps -u john

# Processus de l'utilisateur root
ps -u root

# Combinaison avec le format complet
ps -fu john
```

> [!example] Cas pratique
> 
> ```bash
> # Voir tous les processus web lancés par www-data
> ps -u www-data
> 
> # Identifier un processus qui consomme beaucoup de CPU
> ps aux --sort=-%cpu | head -10
> ```

### Comprendre la sortie

#### États des processus (colonne STAT)

|Code|Signification|Description|
|---|---|---|
|**R**|Running|En cours d'exécution ou prêt à s'exécuter|
|**S**|Sleeping|En attente interruptible (attend un événement)|
|**D**|Uninterruptible Sleep|En attente non interruptible (I/O généralement)|
|**T**|Stopped|Arrêté (Ctrl+Z) ou en cours de traçage|
|**Z**|Zombie|Processus terminé mais non nettoyé par le parent|
|**<**|High priority|Priorité élevée (nice < 0)|
|**N**|Low priority|Priorité basse (nice > 0)|
|**+**|Foreground|Appartient au groupe de processus au premier plan|
|**s**|Session leader|Leader de session (processus parent d'un groupe)|
|**l**|Multi-threaded|Possède plusieurs threads|

> [!warning] Attention aux zombies Un processus **Z (zombie)** indique que le processus enfant a terminé mais que le parent n'a pas récupéré son code de sortie. Quelques zombies sont normaux, mais un grand nombre peut indiquer un problème de programmation.

#### Format de sortie personnalisé

```bash
# Afficher uniquement PID, utilisateur, %CPU et commande
ps -eo pid,user,%cpu,comm

# Afficher avec un tri par utilisation mémoire
ps aux --sort=-%mem | head -20

# Format personnalisé avec largeur de colonne
ps -eo pid:10,user:15,%cpu:5,comm:30
```

### Cas d'usage pratiques

#### 🔍 Rechercher un processus spécifique

```bash
# Chercher tous les processus contenant "nginx"
ps aux | grep nginx

# Exclure le processus grep lui-même
ps aux | grep nginx | grep -v grep

# Alternative plus élégante avec pgrep
pgrep -l nginx
```

#### 📈 Identifier les processus gourmands

```bash
# Top 10 des processus consommant le plus de CPU
ps aux --sort=-%cpu | head -11

# Top 10 des processus consommant le plus de mémoire
ps aux --sort=-%mem | head -11

# Processus utilisant plus de 50% CPU
ps aux | awk '$3 > 50.0 {print $0}'
```

#### 🌳 Afficher l'arbre d'un processus spécifique

```bash
# Voir les enfants d'un processus (par PID)
ps -f --ppid 1234

# Voir toute la hiérarchie d'un processus
ps -ef --forest | grep -A 5 "nginx: master"
```

> [!tip] Astuce professionnelle Combinez `watch` avec `ps` pour surveiller les processus en temps réel :
> 
> ```bash
> watch -n 2 'ps aux --sort=-%cpu | head -20'
> ```

---

## 🌲 La commande pstree

### Visualisation hiérarchique

`pstree` affiche les processus sous forme d'arbre, mettant en évidence les relations parent-enfant.

```bash
# Affichage de base
pstree

# Exemple de sortie :
# systemd─┬─ModemManager───2*[{ModemManager}]
#         ├─NetworkManager───2*[{NetworkManager}]
#         ├─accounts-daemon───2*[{accounts-daemon}]
#         ├─apache2───5*[apache2]
#         ├─cron
#         ├─dbus-daemon
#         └─sshd───sshd───bash───pstree
```

> [!info] Comprendre la notation
> 
> - `───` : relation parent-enfant directe
> - `─┬─` : parent avec plusieurs enfants
> - `├─` : enfant intermédiaire
> - `└─` : dernier enfant
> - `5*[apache2]` : 5 processus identiques (worker processes)

### Options utiles

#### 🔹 Afficher les PIDs

```bash
# Inclure les PIDs dans l'arbre
pstree -p

# Résultat :
# systemd(1)─┬─ModemManager(567)─┬─{ModemManager}(568)
#            │                   └─{ModemManager}(569)
#            ├─apache2(1234)─┬─apache2(1235)
#            │                ├─apache2(1236)
#            │                └─apache2(1237)
```

> [!example] Cas pratique Très utile pour identifier le PID parent d'un groupe de processus avant de les arrêter.

#### 🔹 Afficher les arguments de commande

```bash
# Inclure les arguments complets
pstree -a

# Résultat :
# systemd --system --deserialize 23
#   ├─apache2 -k start
#   │   ├─apache2 -k start
#   │   └─apache2 -k start
#   └─cron -f
```

#### 🔹 Filtrer par utilisateur

```bash
# Arbre des processus de l'utilisateur "john"
pstree john

# Avec PIDs
pstree -p john
```

#### 🔹 Afficher les threads

```bash
# Inclure les threads dans l'arbre
pstree -t

# Avec PIDs des threads
pstree -pt
```

> [!warning] Différence processus vs thread Un thread partage l'espace mémoire de son processus parent, tandis qu'un processus enfant possède son propre espace mémoire.

#### 🔹 Afficher à partir d'un processus spécifique

```bash
# Arbre à partir du PID 1234
pstree 1234

# Arbre à partir d'un nom de processus
pstree apache2

# Combinaison complète
pstree -ap 1234
```

### Interpréter l'arborescence

#### Comprendre la hiérarchie système

```bash
pstree -p | head -20

# systemd(1) est le processus racine (PID 1)
# Tous les autres processus descendent de systemd
```

> [!info] Le processus init Sur les systèmes modernes Linux, `systemd` (PID 1) est le premier processus lancé par le noyau. Il est responsable du démarrage et de la gestion de tous les autres services.

#### Identifier les processus orphelins

```bash
# Les processus orphelins sont automatiquement adoptés par systemd
pstree -p | grep systemd | head -50

# Un grand nombre d'enfants directs de systemd peut indiquer
# des processus dont le parent est mort
```

#### Analyser un service et ses workers

```bash
# Voir la structure complète d'Apache
pstree -ap $(pgrep -o apache2)

# Résultat typique :
# apache2,1234 -k start
#   ├─apache2,1235 -k start
#   ├─apache2,1236 -k start
#   ├─apache2,1237 -k start
#   ├─apache2,1238 -k start
#   └─apache2,1239 -k start
```

> [!tip] Astuce pour les services web Pour un serveur web, le processus master écoute sur le port et délègue les requêtes aux workers. Si vous tuez le master, tous les workers seront également terminés.

---

## ✅ Bonnes pratiques

### 🎯 Combiner les commandes

```bash
# Trouver le PID d'un processus puis visualiser son arbre
pstree -ap $(pgrep nginx | head -1)

# Surveiller l'évolution de l'arborescence
watch -n 1 'pstree -p $(pgrep apache2 | head -1)'

# Lister tous les processus d'un service avec détails
ps -ef | grep nginx && pstree -ap $(pgrep nginx | head -1)
```

### 🔍 Diagnostiquer les problèmes

```bash
# Identifier les processus zombies
ps aux | grep 'Z'

# Trouver le parent d'un zombie
ps -ef | grep defunct

# Voir tous les processus d'une session
ps -t pts/0

# Processus consommant le plus d'I/O (nécessite iotop)
ps aux | awk '$8 ~ /D/ {print $0}'
```

### 📊 Analyser les ressources

```bash
# Vue d'ensemble des ressources par utilisateur
ps aux | awk '{users[$1]+=$3; mem[$1]+=$4} 
               END {for (u in users) 
                    printf "%s: CPU=%.2f%% MEM=%.2f%%\n", u, users[u], mem[u]}'

# Compter les processus par état
ps aux | awk '{print $8}' | sort | uniq -c

# Afficher les processus multi-threadés
ps -eLf | awk '$4 != $5 {print $0}'
```

> [!tip] Scripts de monitoring Créez des alias dans votre `.bashrc` pour vos commandes fréquentes :
> 
> ```bash
> alias psme='ps -u $USER -f'
> alias pscpu='ps aux --sort=-%cpu | head -20'
> alias psmem='ps aux --sort=-%mem | head -20'
> alias pstop='watch -n 2 "ps aux --sort=-%cpu | head -20"'
> ```

### 🚫 Pièges courants à éviter

> [!warning] Erreurs fréquentes
> 
> **1. Confondre VSZ et RSS**
> 
> - VSZ inclut la mémoire swap et partagée
> - RSS est la vraie mémoire physique utilisée
> - Utilisez RSS pour les analyses de performance
> 
> **2. Ignorer les processus sans TTY**
> 
> - Les daemons n'ont pas de terminal (`TTY = ?`)
> - Ne pas utiliser l'option `x` vous fera manquer la plupart des services
> 
> **3. Oublier que ps est un instantané**
> 
> - `ps` montre l'état à un instant T
> - Pour un monitoring continu, utilisez `top`, `htop` ou `watch`

### 🎓 Workflow recommandé

Pour diagnostiquer un problème de performance :

1. **Vue d'ensemble** : `ps aux --sort=-%cpu | head -20`
2. **Identifier le coupable** : noter le PID et l'utilisateur
3. **Comprendre la hiérarchie** : `pstree -ap <PID>`
4. **Analyser les détails** : `ps -fp <PID>`
5. **Décider de l'action** : surveillance, optimisation, ou arrêt

---

## 📝 Résumé des commandes essentielles

|Commande|Usage principal|Quand l'utiliser|
|---|---|---|
|`ps aux`|Vue complète système avec ressources|Analyse de performance globale|
|`ps -ef`|Vue hiérarchique avec PPID|Comprendre les relations parent-enfant|
|`ps -u <user>`|Processus d'un utilisateur|Audit utilisateur ou débogage|
|`pstree`|Arbre visuel simple|Vue rapide de la hiérarchie|
|`pstree -ap`|Arbre avec PIDs et arguments|Investigation approfondie|
|`ps aux \| grep <nom>`|Recherche ciblée|Trouver un processus spécifique|

---

> [!tip] Pour aller plus loin Ces commandes de visualisation sont le point de départ de la gestion des processus. Une fois un processus identifié, vous pourrez utiliser d'autres outils pour interagir avec lui (signaux, priorités, etc.).