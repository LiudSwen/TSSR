

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

## 🎯 Introduction aux processus

### Qu'est-ce qu'un processus ?

Un **processus** est une instance d'un programme en cours d'exécution. Chaque processus possède :

- Un **PID** (Process ID) : identifiant unique
- Un **PPID** (Parent Process ID) : PID du processus parent
- Un **propriétaire** : utilisateur qui a lancé le processus
- Un **état** : en cours, suspendu, zombie, etc.
- Des **ressources** : mémoire, fichiers ouverts, CPU

> [!info] Pourquoi gérer les processus ? La gestion des processus est essentielle pour :
> 
> - Surveiller les performances système
> - Identifier les programmes problématiques
> - Libérer des ressources
> - Exécuter des tâches en arrière-plan
> - Maintenir la stabilité du système

---

## 📊 Lister et surveiller les processus

### La commande `ps`

La commande `ps` (Process Status) affiche un instantané des processus actifs.

#### Syntaxe de base

```bash
ps [options]
```

#### Utilisation simple

```bash
# Afficher les processus de l'utilisateur courant dans le terminal actuel
ps

# Sortie typique :
#   PID TTY          TIME CMD
#  1234 pts/0    00:00:00 bash
#  5678 pts/0    00:00:00 ps
```

> [!example] Colonnes importantes
> 
> - **PID** : Process ID
> - **TTY** : Terminal associé
> - **TIME** : Temps CPU consommé
> - **CMD** : Commande exécutée

### La commande `ps aux`

L'option combinée `aux` est la plus utilisée pour avoir une vue complète.

```bash
# Afficher TOUS les processus du système avec détails
ps aux

# a : tous les processus de tous les utilisateurs
# u : format orienté utilisateur (avec colonnes USER, %CPU, %MEM)
# x : inclut les processus sans terminal (daemons)
```

#### Sortie détaillée

```bash
USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.1 169416 13420 ?        Ss   10:00   0:02 /sbin/init
www-data  1234  2.5  1.8 450328 75432 ?        S    10:15   1:23 nginx: worker
john      5678  0.1  0.5 123456 20480 pts/0    R+   14:30   0:00 ps aux
```

> [!info] Colonnes détaillées
> 
> |Colonne|Description|
> |---|---|
> |USER|Propriétaire du processus|
> |PID|Process ID|
> |%CPU|Pourcentage d'utilisation CPU|
> |%MEM|Pourcentage d'utilisation mémoire|
> |VSZ|Mémoire virtuelle (Ko)|
> |RSS|Mémoire physique (Ko)|
> |TTY|Terminal (? = aucun)|
> |STAT|État du processus|
> |START|Heure de démarrage|
> |TIME|Temps CPU cumulé|
> |COMMAND|Commande complète|

#### États des processus (STAT)

|Code|Signification|
|---|---|
|R|Running (en cours d'exécution)|
|S|Sleeping (en attente interruptible)|
|D|Sleeping (en attente non-interruptible)|
|T|Stopped (arrêté)|
|Z|Zombie (terminé mais non nettoyé)|
|<|Haute priorité|
|N|Basse priorité|
|s|Session leader|
|+|Au premier plan|

### Filtrer avec `grep`

```bash
# Rechercher un processus spécifique
ps aux | grep nginx

# Rechercher plusieurs processus
ps aux | grep -E 'nginx|apache|mysql'

# Exclure la ligne grep elle-même
ps aux | grep nginx | grep -v grep
```

### La commande `pgrep`

Alternative moderne pour trouver des processus par nom.

```bash
# Trouver le PID d'un processus par son nom
pgrep nginx
# Sortie : 1234

# Afficher le nom complet avec le PID
pgrep -l nginx
# Sortie : 1234 nginx

# Trouver tous les processus d'un utilisateur
pgrep -u www-data

# Trouver avec un pattern exact
pgrep -x "nginx: master"

# Afficher les informations complètes
pgrep -a nginx
# Sortie : 1234 nginx: master process /usr/sbin/nginx
```

> [!tip] Avantages de pgrep
> 
> - Plus rapide que `ps | grep`
> - Évite de capturer la commande grep elle-même
> - Options puissantes de filtrage
> - Peut retourner uniquement les PIDs pour un traitement ultérieur

### Options utiles de `ps`

```bash
# Format personnalisé
ps -eo pid,user,%cpu,%mem,command

# Trier par utilisation CPU (décroissant)
ps aux --sort=-%cpu | head -10

# Trier par utilisation mémoire (décroissant)
ps aux --sort=-%mem | head -10

# Afficher l'arborescence des processus
ps auxf
# ou
ps -ejH

# Afficher les threads
ps -eLf
```

> [!warning] Piège courant Ne confondez pas `ps aux` et `ps -aux` :
> 
> - `ps aux` : syntaxe BSD (pas de tiret)
> - `ps -aux` : syntaxe UNIX (avec tiret) qui signifie "processus de l'utilisateur x"
> 
> Les deux fonctionnent mais ont des significations différentes !

---

## ⚡ Terminer des processus

### La commande `kill`

La commande `kill` envoie des **signaux** aux processus.

#### Syntaxe

```bash
kill [options] <PID>
```

### Comprendre les signaux

Les signaux sont des messages envoyés aux processus pour leur demander d'effectuer une action.

> [!info] Signaux principaux
> 
> |Signal|Numéro|Nom|Description|
> |---|---|---|---|
> |SIGTERM|15|Termination|Demande d'arrêt propre (défaut)|
> |SIGKILL|9|Kill|Arrêt forcé immédiat|
> |SIGHUP|1|Hang Up|Rechargement config|
> |SIGINT|2|Interrupt|Interruption (Ctrl+C)|
> |SIGSTOP|19|Stop|Pause (non capturable)|
> |SIGCONT|18|Continue|Reprendre après pause|

#### Utilisation courante

```bash
# Arrêt propre (signal SIGTERM par défaut)
kill 1234

# Arrêt forcé (signal SIGKILL)
kill -9 1234
# ou
kill -KILL 1234
# ou
kill -SIGKILL 1234

# Recharger la configuration (pour services comme nginx)
kill -HUP 1234
# ou
kill -1 1234

# Lister tous les signaux disponibles
kill -l
```

> [!warning] SIGTERM vs SIGKILL **SIGTERM (15)** :
> 
> - ✅ Permet au processus de se terminer proprement
> - ✅ Sauvegarde les données
> - ✅ Ferme les fichiers ouverts
> - ✅ Libère les ressources
> - ❌ Peut être ignoré par le processus
> 
> **SIGKILL (9)** :
> 
> - ✅ Terminaison immédiate garantie
> - ❌ Pas de nettoyage possible
> - ❌ Peut laisser des fichiers corrompus
> - ❌ Peut créer des processus zombies
> 
> **Bonne pratique** : Toujours essayer SIGTERM avant SIGKILL !

#### Workflow recommandé

```bash
# 1. Essayer d'abord un arrêt propre
kill 1234

# 2. Attendre quelques secondes
sleep 5

# 3. Vérifier si le processus existe encore
ps -p 1234

# 4. Si toujours actif, forcer l'arrêt
kill -9 1234
```

### La commande `killall`

Termine tous les processus correspondant à un nom.

```bash
# Arrêter tous les processus nommés "firefox"
killall firefox

# Arrêt forcé
killall -9 firefox

# Avec confirmation interactive
killall -i firefox

# Ignorer les processus de moins de X secondes (éviter de tuer des démarrages)
killall -y 30s firefox  # Processus de plus de 30 secondes

# Mode verbeux
killall -v firefox
```

> [!warning] Attention avec killall
> 
> - Termine **TOUS** les processus avec ce nom
> - Peut affecter plusieurs instances
> - Utilisez avec précaution sur les systèmes multi-utilisateurs

### La commande `pkill`

Combine les avantages de `pgrep` et `kill`.

```bash
# Tuer par nom de processus
pkill nginx

# Tuer avec signal spécifique
pkill -9 nginx

# Tuer par utilisateur
pkill -u www-data

# Tuer par pattern exact
pkill -x "nginx: worker"

# Tuer par terminal
pkill -t pts/0

# Mode verbeux (affiche ce qui est tué)
pkill -e nginx
```

> [!tip] pkill vs killall **pkill** :
> 
> - Plus flexible (patterns regex)
> - Peut filtrer par utilisateur, terminal, etc.
> - Syntaxe similaire à pgrep
> 
> **killall** :
> 
> - Plus simple pour les noms exacts
> - Options de confirmation interactives
> - Comportement plus prévisible

### Exemples pratiques

```bash
# Tuer tous les processus Chrome d'un utilisateur
pkill -u john chrome

# Tuer un processus récalcitrant
kill -TERM 1234 && sleep 2 && kill -KILL 1234

# Tuer tous les processus zombies (en tuant leurs parents)
ps aux | grep 'Z' | awk '{print $2}' | xargs -r kill -9

# Recharger la configuration de nginx
pkill -HUP nginx

# Tuer tous les processus sauf un
pkill -v -t pts/0  # Inverse match
```

---

## 🔀 Gestion des tâches en arrière-plan

### Concepts fondamentaux

Linux distingue deux plans d'exécution pour les processus :

- **Premier plan (foreground)** : le processus contrôle le terminal, vous ne pouvez rien taper
- **Arrière-plan (background)** : le processus s'exécute sans bloquer le terminal

### Lancer une commande en arrière-plan avec `&`

```bash
# Lancer un processus en arrière-plan
sleep 100 &
# Sortie : [1] 12345
#          ↑   ↑
#     Job ID   PID

# Lancer plusieurs commandes
firefox &
gedit document.txt &
```

> [!info] Qu'affiche le `&` ?
> 
> - **[1]** : Numéro de job (identifiant de tâche pour le shell)
> - **12345** : PID du processus

### La commande `jobs`

Affiche les tâches en cours dans le shell actuel.

```bash
# Lister les jobs
jobs

# Sortie exemple :
# [1]   Running                 sleep 100 &
# [2]-  Running                 ping google.com &
# [3]+  Stopped                 nano fichier.txt
```

> [!info] Symboles dans jobs
> 
> - **+** : Job le plus récent (job courant)
> - **-** : Job précédent
> - Aucun symbole : autres jobs

#### Options de `jobs`

```bash
# Afficher les PIDs
jobs -l
# [1]  12345 Running    sleep 100 &

# Afficher uniquement les PIDs
jobs -p

# Afficher uniquement les jobs en cours
jobs -r

# Afficher uniquement les jobs arrêtés
jobs -s
```

### Suspendre un processus (Ctrl+Z)

Mettre en pause un processus au premier plan.

```bash
# Lancer une commande
ping google.com

# Appuyer sur Ctrl+Z
# Sortie :
# ^Z
# [1]+  Stopped                 ping google.com
```

> [!tip] Ctrl+Z vs Ctrl+C
> 
> - **Ctrl+Z** : Suspend le processus (SIGSTOP), il peut être repris
> - **Ctrl+C** : Termine le processus (SIGINT), il est arrêté

### La commande `bg`

Reprendre une tâche suspendue en arrière-plan.

```bash
# Suspendre un processus
ping google.com
# Ctrl+Z

# Le faire reprendre en arrière-plan
bg
# Sortie : [1]+ ping google.com &

# Reprendre un job spécifique
bg %2       # Job numéro 2
bg %ping    # Job contenant "ping"
```

#### Référencer les jobs

```bash
bg %1       # Job numéro 1
bg %2       # Job numéro 2
bg %%       # Job courant (avec +)
bg %-       # Job précédent (avec -)
bg %?ping   # Job dont la commande contient "ping"
bg %sleep   # Job commençant par "sleep"
```

### La commande `fg`

Ramener une tâche en arrière-plan au premier plan.

```bash
# Reprendre le job courant au premier plan
fg

# Reprendre un job spécifique
fg %1
fg %ping
```

#### Workflow typique

```bash
# 1. Lancer un éditeur
nano document.txt

# 2. Suspendre avec Ctrl+Z
# [1]+  Stopped    nano document.txt

# 3. Faire autre chose
ls -la
cat autre_fichier.txt

# 4. Reprendre l'éditeur
fg
# L'éditeur réapparaît exactement comme vous l'aviez laissé
```

### La commande `wait`

Attendre la fin d'un ou plusieurs processus en arrière-plan.

```bash
# Lancer plusieurs commandes en arrière-plan
sleep 10 &
sleep 20 &
sleep 30 &

# Attendre que TOUS les jobs soient terminés
wait

# Attendre un job spécifique
sleep 100 &
PID=$!  # Récupérer le PID de la dernière commande
wait $PID
echo "Le processus $PID est terminé"

# Attendre plusieurs PIDs spécifiques
wait 1234 5678 9012
```

> [!tip] Variable spéciale $! `$!` contient le PID du dernier processus lancé en arrière-plan :
> 
> ```bash
> firefox &
> echo $!  # Affiche le PID de firefox
> ```

#### Utilisation dans les scripts

```bash
#!/bin/bash

# Lancer des tâches parallèles
./traitement1.sh &
PID1=$!

./traitement2.sh &
PID2=$!

./traitement3.sh &
PID3=$!

# Attendre que tous soient finis
wait $PID1 $PID2 $PID3

echo "Tous les traitements sont terminés"
```

### Exemples pratiques

```bash
# Lancer une compilation en arrière-plan
make all &
jobs -l
# Faire autre chose pendant la compilation...
fg  # Revenir voir les éventuelles erreurs

# Télécharger plusieurs fichiers en parallèle
wget http://example.com/file1.zip &
wget http://example.com/file2.zip &
wget http://example.com/file3.zip &
wait
echo "Tous les téléchargements terminés"

# Suspendre vim, consulter un fichier, reprendre
vim script.sh
# Ctrl+Z
cat /var/log/syslog  # Consulter un log
fg  # Retour dans vim
```

> [!warning] Limitations des jobs
> 
> - Les jobs sont **spécifiques au shell courant**
> - Si vous fermez le terminal, les jobs sont terminés (sauf avec nohup)
> - Les jobs n'apparaissent pas dans `ps` avec un indicateur spécial
> - Utilisez `jobs` pour les gérer, pas `ps`

---

## 🔓 Détacher des processus du terminal

### Problème : fermeture du terminal

Quand vous fermez un terminal, tous les processus enfants reçoivent un signal **SIGHUP** et se terminent.

```bash
# Ce processus sera tué si le terminal se ferme
sleep 1000 &
```

### La commande `nohup`

`nohup` (no hang up) permet d'ignorer le signal SIGHUP.

#### Syntaxe

```bash
nohup commande [arguments] &
```

#### Utilisation de base

```bash
# Lancer un script qui continue après fermeture du terminal
nohup ./mon_script.sh &

# Sortie :
# nohup: ignoring input and appending output to 'nohup.out'
# [1] 12345
```

> [!info] Comportement de nohup Par défaut, `nohup` :
> 
> - Redirige **stdout** et **stderr** vers `nohup.out`
> - Ignore l'entrée standard (stdin)
> - Le processus continue même si le terminal est fermé
> - Le processus est rattaché au processus init (PID 1)

#### Rediriger les sorties

```bash
# Rediriger vers un fichier spécifique
nohup ./script.sh > output.log 2>&1 &

# Ignorer complètement les sorties
nohup ./script.sh > /dev/null 2>&1 &

# Séparer stdout et stderr
nohup ./script.sh > output.log 2> error.log &
```

#### Exemple pratique

```bash
# Lancer un serveur web qui persiste
nohup python3 -m http.server 8000 > server.log 2>&1 &

# Vérifier qu'il tourne
jobs -l

# Fermer le terminal et rouvrir
# Le serveur continue de tourner

# Le retrouver
ps aux | grep http.server
```

### Alternatives à nohup

#### `disown`

Détacher un job déjà lancé du shell courant.

```bash
# Lancer un processus normalement
sleep 1000 &
# [1] 12345

# Le détacher
disown %1

# Vérifier qu'il n'apparaît plus dans jobs
jobs
# (vide)

# Mais il tourne toujours
ps -p 12345
```

> [!tip] Workflow avec disown
> 
> ```bash
> # 1. Lancer une commande (oubli du &)
> ./long_process.sh
> 
> # 2. Suspendre avec Ctrl+Z
> # [1]+  Stopped
> 
> # 3. Reprendre en arrière-plan
> bg
> 
> # 4. Détacher du shell
> disown
> 
> # Maintenant, vous pouvez fermer le terminal
> ```

#### Options de `disown`

```bash
# Détacher tous les jobs
disown -a

# Détacher et empêcher de recevoir SIGHUP
disown -h %1

# Détacher le job courant
disown
```

### Tableau comparatif

|Commande|Quand utiliser|Avantages|Inconvénients|
|---|---|---|---|
|`&`|Exécution rapide, terminal reste ouvert|Simple, rapide|Tué à la fermeture du terminal|
|`nohup &`|Long traitement, terminal peut être fermé|Persiste après fermeture|Sortie redirigée automatiquement|
|`disown`|Oubli du nohup, processus déjà lancé|Détache après coup|Pas de capture des sorties|
|`screen/tmux`|Sessions interactives persistantes|Multiplexage, reconnexion|Plus complexe à apprendre|

### Exemples pratiques complets

#### Exécuter un backup nocturne

```bash
# Lancer un backup qui persiste
nohup ./backup_database.sh > /var/log/backup_$(date +%Y%m%d).log 2>&1 &

# Récupérer le PID
echo $! > /tmp/backup.pid

# Plus tard, vérifier qu'il tourne
if ps -p $(cat /tmp/backup.pid) > /dev/null; then
    echo "Backup en cours"
else
    echo "Backup terminé"
fi
```

#### Démarrer plusieurs services

```bash
#!/bin/bash

# Script de démarrage de services

echo "Démarrage des services..."

# Service 1
nohup ./service1 > /var/log/service1.log 2>&1 &
echo $! > /var/run/service1.pid

# Service 2
nohup ./service2 > /var/log/service2.log 2>&1 &
echo $! > /var/run/service2.pid

# Service 3
nohup ./service3 > /var/log/service3.log 2>&1 &
echo $! > /var/run/service3.pid

echo "Tous les services sont lancés"
```

#### Monitoring d'un processus détaché

```bash
# Lancer avec nohup
nohup ./long_task.sh > task.log 2>&1 &
TASK_PID=$!

# Fonction pour vérifier l'état
check_task() {
    if ps -p $TASK_PID > /dev/null; then
        echo "Tâche en cours (PID: $TASK_PID)"
        echo "Dernières lignes du log :"
        tail -5 task.log
    else
        echo "Tâche terminée"
        echo "Résultat :"
        tail -20 task.log
    fi
}

# Vérifier toutes les 10 secondes
while ps -p $TASK_PID > /dev/null; do
    sleep 10
    echo "$(date): Toujours en cours..."
done

echo "Tâche terminée à $(date)"
```

> [!warning] Bonnes pratiques avec nohup
> 
> - ✅ Toujours rediriger les sorties explicitement
> - ✅ Sauvegarder le PID pour pouvoir retrouver le processus
> - ✅ Utiliser des noms de fichiers de log informatifs (avec date)
> - ✅ Vérifier régulièrement les fichiers de log
> - ❌ Ne pas laisser s'accumuler des nohup.out géants
> - ❌ Ne pas oublier de nettoyer les processus terminés

---

## 🎯 Résumé des commandes

|Commande|Usage principal|Exemple|
|---|---|---|
|`ps`|Lister les processus|`ps aux`|
|`pgrep`|Trouver PID par nom|`pgrep nginx`|
|`kill`|Envoyer signal à un PID|`kill -9 1234`|
|`killall`|Tuer par nom|`killall firefox`|
|`pkill`|Tuer avec filtre|`pkill -u john`|
|`jobs`|Lister les jobs du shell|`jobs -l`|
|`bg`|Reprendre en arrière-plan|`bg %1`|
|`fg`|Ramener au premier plan|`fg`|
|`&`|Lancer en arrière-plan|`sleep 100 &`|
|`nohup`|Détacher du terminal|`nohup ./script.sh &`|
|`wait`|Attendre fin de processus|`wait 1234`|

> [!tip] Commandes essentielles à retenir Au quotidien, vous utiliserez principalement :
> 
> - `ps aux | grep ...` pour chercher un processus
> - `kill PID` pour l'arrêter proprement
> - `commande &` pour lancer en arrière-plan
> - `Ctrl+Z` puis `bg` pour libérer le terminal
> - `nohup commande &` pour les tâches longues

---