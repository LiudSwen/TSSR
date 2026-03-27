

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

## 🔔 Introduction aux signaux Linux

Les **signaux** sont des notifications logicielles envoyées à un processus pour lui demander d'effectuer une action spécifique. C'est le mécanisme principal de communication inter-processus sous Linux.

> [!info] Pourquoi les signaux ? Les signaux permettent de contrôler les processus de manière asynchrone : arrêter une application proprement, recharger une configuration, ou forcer l'arrêt d'un programme bloqué.

### Fonctionnement général

Lorsqu'un processus reçoit un signal :

1. Son exécution est **interrompue**
2. Un **gestionnaire de signal** est exécuté (par défaut ou personnalisé)
3. Le processus reprend son exécution normale (sauf si le signal le termine)

> [!warning] Attention Certains signaux ne peuvent pas être interceptés ou ignorés par un processus (notamment SIGKILL et SIGSTOP).

---

## 📋 Les signaux principaux

### Vue d'ensemble

Linux dispose de **64 signaux** numérotés. Voici les plus importants pour l'administration système :

|Signal|Numéro|Action par défaut|Description|
|---|---|---|---|
|**SIGHUP**|1|Terminer|Hangup - Déconnexion du terminal|
|**SIGINT**|2|Terminer|Interruption (Ctrl+C)|
|**SIGQUIT**|3|Terminer + Core|Quitter (Ctrl+)|
|**SIGKILL**|9|Terminer|Tuer immédiatement (non interceptable)|
|**SIGTERM**|15|Terminer|Terminaison propre (signal par défaut)|
|**SIGCONT**|18|Continuer|Reprendre un processus suspendu|
|**SIGSTOP**|19|Suspendre|Suspendre (non interceptable)|
|**SIGTSTP**|20|Suspendre|Suspension (Ctrl+Z)|
|**SIGUSR1**|10|Terminer|Signal utilisateur 1 (personnalisable)|
|**SIGUSR2**|12|Terminer|Signal utilisateur 2 (personnalisable)|

### SIGTERM (15) - Terminaison propre

> [!example] Signal SIGTERM C'est le signal **par défaut** et **recommandé** pour arrêter un processus.

**Caractéristiques :**

- Demande au processus de se terminer proprement
- Le processus peut intercepter ce signal pour effectuer un nettoyage
- Permet de sauvegarder les données, fermer les fichiers, libérer les ressources
- **Peut être ignoré** par le processus

**Quand l'utiliser :**

- Arrêt normal d'une application
- Première tentative pour terminer un processus récalcitrant
- Arrêt de services qui doivent sauvegarder leur état

```bash
# Envoyer SIGTERM (signal par défaut)
kill 1234
kill -15 1234
kill -TERM 1234
kill -SIGTERM 1234  # Toutes ces commandes sont équivalentes
```

### SIGKILL (9) - Terminaison forcée

> [!warning] Signal SIGKILL - À utiliser en dernier recours SIGKILL tue immédiatement et brutalement un processus sans lui laisser le temps de nettoyer.

**Caractéristiques :**

- **Non interceptable** : le processus ne peut ni l'ignorer ni le gérer
- Terminaison **immédiate** par le noyau
- Aucun nettoyage possible (fichiers ouverts, transactions en cours, etc.)
- Risque de corruption de données

**Quand l'utiliser :**

- Processus complètement bloqué qui ne répond pas à SIGTERM
- Situation d'urgence nécessitant l'arrêt immédiat
- Après avoir tenté SIGTERM sans succès

```bash
# Envoyer SIGKILL
kill -9 1234
kill -KILL 1234
kill -SIGKILL 1234
```

> [!tip] Bonne pratique : La règle des deux temps Essayez toujours SIGTERM d'abord, attendez quelques secondes, puis utilisez SIGKILL si nécessaire.
> 
> ```bash
> kill 1234 && sleep 5 && kill -9 1234 2>/dev/null
> ```

### SIGHUP (1) - Hangup / Rechargement

> [!info] Signal polyvalent SIGHUP a deux usages principaux selon le contexte.

**Usage historique : Déconnexion du terminal**

- Envoyé automatiquement quand un terminal se déconnecte
- Termine tous les processus attachés à ce terminal
- Les démons (daemons) survivent car ils se détachent du terminal

**Usage moderne : Rechargement de configuration**

- De nombreux services utilisent SIGHUP pour recharger leur configuration
- Permet de modifier la config sans redémarrer le service
- Aucune interruption de service

**Exemples de services supportant SIGHUP :**

```bash
# Recharger la configuration de Nginx
kill -HUP $(cat /var/run/nginx.pid)
# ou
nginx -s reload

# Recharger la configuration de syslog
kill -HUP $(cat /var/run/syslogd.pid)

# Recharger SSH (attention, vérifiez la config avant !)
kill -HUP $(cat /var/run/sshd.pid)
```

> [!warning] Vérifiez la documentation Tous les processus ne gèrent pas SIGHUP de la même manière. Certains peuvent se terminer au lieu de recharger.

### SIGINT (2) et SIGQUIT (3)

**SIGINT (Ctrl+C)** :

- Signal d'interruption envoyé depuis le terminal
- Permet une terminaison propre et contrôlée
- Équivalent terminal de SIGTERM

**SIGQUIT (Ctrl+\)** :

- Demande de terminaison avec génération d'un core dump
- Utile pour le débogage (analyse post-mortem)
- Plus "violent" que SIGINT

```bash
# Simuler Ctrl+C par programme
kill -INT 1234

# Générer un core dump
kill -QUIT 1234
```

### SIGUSR1 (10) et SIGUSR2 (12)

> [!tip] Signaux personnalisables Ces signaux sont réservés pour des usages spécifiques à l'application.

Les développeurs peuvent définir librement le comportement de ces signaux. Exemples d'usages courants :

```bash
# Apache : SIGUSR1 pour log rotation gracieuse
kill -USR1 $(cat /var/run/apache2.pid)

# Certains programmes utilisent SIGUSR1 pour activer/désactiver le mode debug
kill -USR1 1234

# SIGUSR2 peut déclencher des actions spécifiques selon le programme
kill -USR2 1234
```

### Lister tous les signaux disponibles

```bash
# Afficher tous les signaux
kill -l

# Afficher le numéro d'un signal spécifique
kill -l TERM    # Affiche : 15

# Afficher le nom d'un signal par son numéro
kill -l 9       # Affiche : KILL
```

---

## 🔫 La commande kill

### Syntaxe générale

```bash
kill [OPTIONS] [SIGNAL] PID [PID...]
```

> [!info] Concept clé `kill` envoie un signal à un ou plusieurs processus identifiés par leur **PID** (Process ID).

### Utilisation basique

```bash
# Envoyer SIGTERM (par défaut) au processus 1234
kill 1234

# Envoyer un signal spécifique (plusieurs notations possibles)
kill -15 1234       # Par numéro
kill -TERM 1234     # Par nom court
kill -SIGTERM 1234  # Par nom complet

# Envoyer le même signal à plusieurs processus
kill -9 1234 5678 9012
```

### Options principales

|Option|Description|
|---|---|
|`-l`|Liste tous les signaux disponibles|
|`-s SIGNAL`|Spécifie le signal à envoyer (alternative à `-SIGNAL`)|
|`-n NUM`|Envoie le signal numéro NUM|

```bash
# Différentes façons d'envoyer SIGTERM
kill 1234
kill -15 1234
kill -s TERM 1234
kill -n 15 1234
kill -TERM 1234
```

### Exemples pratiques

> [!example] Scénarios courants

**Arrêt propre d'une application :**

```bash
# Trouver le PID
ps aux | grep "mon_application"
# ou
pgrep mon_application

# Envoyer SIGTERM
kill 1234
```

**Forcer l'arrêt après tentative propre :**

```bash
# Tentative propre
kill 1234

# Attendre 5 secondes
sleep 5

# Vérifier si le processus existe encore
if ps -p 1234 > /dev/null; then
    echo "Le processus résiste, utilisation de SIGKILL"
    kill -9 1234
else
    echo "Le processus s'est terminé proprement"
fi
```

**Recharger la configuration d'un service :**

```bash
# Nginx
kill -HUP $(cat /var/run/nginx.pid)

# Apache
kill -HUP $(cat /var/run/apache2/apache2.pid)
```

### Permissions et sudo

> [!warning] Permissions requises Vous ne pouvez envoyer des signaux qu'aux processus que vous possédez, sauf si vous êtes root.

```bash
# Processus de votre utilisateur : OK
kill 1234

# Processus root : nécessite sudo
sudo kill 1234

# Erreur courante
kill 1234
# Operation not permitted
```

### Vérifier si un processus existe

```bash
# Envoyer le signal 0 (signal nul) pour tester l'existence
kill -0 1234
echo $?
# 0 : le processus existe
# 1 : le processus n'existe pas ou pas de permission
```

> [!tip] Astuce : Signal 0 Le signal 0 ne fait rien au processus mais permet de vérifier son existence et vos permissions.

---

## 🎯 La commande killall

### Syntaxe générale

```bash
killall [OPTIONS] [SIGNAL] NOM_PROCESSUS
```

> [!info] Concept clé `killall` envoie un signal à **tous les processus** ayant un nom donné. Cible par nom au lieu de PID.

### Utilisation basique

```bash
# Terminer tous les processus nommés "firefox"
killall firefox

# Envoyer SIGKILL à tous les processus "chrome"
killall -9 chrome

# Recharger tous les processus nginx
killall -HUP nginx
```

### Options principales

|Option|Description|
|---|---|
|`-e, --exact`|Correspond exactement au nom (jusqu'à 15 caractères)|
|`-I, --ignore-case`|Ignore la casse|
|`-i, --interactive`|Demande confirmation avant chaque signal|
|`-q, --quiet`|Mode silencieux (pas d'erreur si aucun processus)|
|`-r, --regexp`|Utilise une expression régulière|
|`-s, --signal SIGNAL`|Spécifie le signal à envoyer|
|`-u, --user USER`|Cible uniquement les processus de l'utilisateur USER|
|`-w, --wait`|Attend la fin de tous les processus|
|`-y, --younger-than TEMPS`|Cible les processus plus récents que TEMPS|
|`-o, --older-than TEMPS`|Cible les processus plus anciens que TEMPS|

### Exemples pratiques

> [!example] Scénarios d'utilisation

**Terminer une application spécifique :**

```bash
# Terminer tous les Firefox
killall firefox

# Terminer tous les Chrome avec confirmation
killall -i chrome
# Kill chrome(1234) ? (y/N)
```

**Ciblage par utilisateur :**

```bash
# Terminer tous les processus firefox de l'utilisateur "john"
killall -u john firefox

# Terminer tous les processus d'un utilisateur (nécessite root)
sudo killall -u john
```

**Utilisation d'expressions régulières :**

```bash
# Terminer tous les processus dont le nom contient "python"
killall -r "python.*"

# Terminer tous les processus se terminant par "d" (démons)
killall -r ".*d$"
```

**Ciblage temporel :**

```bash
# Terminer les processus chrome plus anciens que 2 heures
killall -o 2h chrome

# Terminer les processus récents (moins de 5 minutes)
killall -y 5m firefox

# Formats de temps acceptés : s (secondes), m (minutes), h (heures), d (jours), w (semaines), M (mois), y (années)
```

**Mode interactif et attente :**

```bash
# Demander confirmation pour chaque processus
killall -i firefox

# Envoyer SIGTERM et attendre que tous se terminent
killall -w firefox

# Attendre avec timeout (15 secondes max)
timeout 15 killall -w firefox
```

**Correspondance exacte :**

```bash
# Problème : noms tronqués à 15 caractères
ps aux | grep very_long_process_name
# Affiche : very_long_proce

# Solution : utiliser -e pour correspondance exacte (15 premiers caractères)
killall -e very_long_proce

# Ou utiliser -r avec regex
killall -r "very_long.*"
```

### Limites et précautions

> [!warning] Dangers de killall `killall` peut être dangereux car il cible TOUS les processus portant un nom donné.

**Risques courants :**

```bash
# DANGER : Va terminer TOUS les processus bash de votre utilisateur !
killall bash
# Vous risquez de perdre toutes vos sessions shell ouvertes

# DANGER : Sur certains systèmes (BSD), killall sans argument tue TOUS les processus !
# (Pas sous Linux, mais bon à savoir)

# Vérifiez toujours avant
pgrep -a firefox    # Liste les processus avant d'agir
killall firefox     # Puis terminez
```

**Bonnes pratiques :**

```bash
# 1. Vérifier d'abord ce qui sera affecté
pgrep -a nom_processus

# 2. Utiliser -i en cas de doute
killall -i nom_processus

# 3. Tester avec le signal 0
killall -0 nom_processus 2>/dev/null && echo "Processus trouvés"

# 4. Préférer des noms spécifiques
killall firefox-bin      # Plus précis
killall -r "^firefox$"   # Correspondance exacte avec regex
```

---

## 🎲 La commande pkill

### Syntaxe générale

```bash
pkill [OPTIONS] [SIGNAL] MOTIF
```

> [!info] Concept clé `pkill` est l'outil le plus **flexible et puissant** pour envoyer des signaux. Il combine les avantages de `kill` et `killall` avec de nombreux critères de sélection.

### Différence avec killall

|Caractéristique|killall|pkill|
|---|---|---|
|Correspondance|Nom exact du processus|Expression régulière sur ligne complète|
|Critères|Nom uniquement (+ user, temps)|Nom, user, terminal, groupe, session, parent, etc.|
|Flexibilité|Limitée|Très étendue|
|Complexité|Simple|Plus de possibilités|

### Options de sélection principales

|Option|Description|
|---|---|
|`-u, --euid USER`|Processus de l'utilisateur USER|
|`-U, --uid UID`|Processus avec l'UID réel|
|`-G, --gid GID`|Processus du groupe GID|
|`-g, --pgroup PGID`|Processus du groupe de processus PGID|
|`-s, --sid SID`|Processus de la session SID|
|`-t, --terminal TTY`|Processus attachés au terminal TTY|
|`-P, --parent PPID`|Processus enfants du parent PPID|
|`-x, --exact`|Correspondance exacte (pas de regex)|
|`-f, --full`|Cherche dans la ligne de commande complète|
|`-n, --newest`|Sélectionne le processus le plus récent|
|`-o, --oldest`|Sélectionne le processus le plus ancien|
|`-c, --count`|Affiche le nombre de processus correspondants|

### Options de signal

|Option|Description|
|---|---|
|`-signal`|Envoie le signal spécifié (ex: `-9`, `-KILL`)|
|`-l, --list-name`|Liste les noms des processus|
|`-a, --list-full`|Liste les commandes complètes|

### Exemples pratiques

> [!example] Cas d'usage avancés

**Sélection basique par motif :**

```bash
# Terminer tous les processus contenant "firefox" dans leur nom
pkill firefox

# Terminer avec SIGKILL
pkill -9 chrome

# Correspondance exacte (pas de regex)
pkill -x firefox
```

**Recherche dans la ligne de commande complète :**

```bash
# TRÈS UTILE : chercher dans les arguments
pkill -f "python.*script.py"

# Exemple : terminer un script Python spécifique
pkill -f "python3 /home/user/mon_script.py"

# Terminer tous les processus Python d'un projet
pkill -f "python.*monprojet"
```

> [!tip] Astuce : L'option -f L'option `-f` est extrêmement utile pour cibler des scripts ou processus avec des arguments spécifiques.

**Ciblage par utilisateur :**

```bash
# Terminer tous les processus firefox de john
pkill -u john firefox

# Terminer TOUS les processus de john (attention !)
sudo pkill -u john

# Combiner utilisateur et motif
pkill -u john -f "python.*"
```

**Ciblage par terminal :**

```bash
# Lister vos terminaux
who
# john     pts/0        2024-01-15 10:30

# Terminer tous les processus d'un terminal spécifique
pkill -t pts/0

# Utile pour nettoyer une session zombie
pkill -9 -t pts/3
```

**Ciblage par processus parent :**

```bash
# Trouver le PID d'un processus parent
pgrep -a apache2
# 1234 /usr/sbin/apache2

# Terminer tous les enfants d'apache2
pkill -P 1234

# Exemple : terminer tous les processus lancés par un script
pkill -P $(pgrep mon_script.sh)
```

**Sélection par âge :**

```bash
# Terminer le processus firefox le plus récent
pkill -n firefox

# Terminer le processus firefox le plus ancien
pkill -o firefox

# Utile pour cibler une instance spécifique parmi plusieurs
pkill -n -f "python.*worker"
```

**Mode test et comptage :**

```bash
# Compter les processus qui seraient affectés
pkill -c firefox
# 3

# Lister les noms sans tuer
pkill -l firefox
# 1234 firefox
# 5678 firefox-bin

# Lister les commandes complètes
pkill -a firefox
# 1234 /usr/lib/firefox/firefox
# 5678 /usr/lib/firefox/firefox-bin
```

**Combinaisons avancées :**

```bash
# Terminer les processus Python de john sur pts/0
pkill -u john -t pts/0 -f python

# Recharger les workers nginx (pas le master)
pkill -HUP -f "nginx: worker"

# Terminer les vieux processus zombies
pkill -9 -o -f defunct

# Terminer tous les processus d'une session spécifique
pkill -s 1234
```

### Expressions régulières

> [!info] Regex avec pkill `pkill` utilise des expressions régulières étendues (ERE) par défaut.

**Exemples de patterns :**

```bash
# Début de ligne (^) et fin de ligne ($)
pkill "^firefox$"          # Exactement "firefox"
pkill "^python.*"          # Commence par "python"
pkill ".*worker$"          # Se termine par "worker"

# Alternatives (|)
pkill "firefox|chrome"     # Firefox OU Chrome

# Groupes de caractères
pkill "python[23]"         # python2 ou python3
pkill "[Ff]irefox"         # Firefox ou firefox

# Quantificateurs
pkill "nginx.*worker"      # nginx suivi de n'importe quoi puis worker
pkill "apache[0-9]+"       # apache suivi d'un ou plusieurs chiffres

# Échappement des caractères spéciaux
pkill "script\.py"         # Point littéral (pas "n'importe quel caractère")
```

**Avec l'option -f (ligne complète) :**

```bash
# Cibler un script avec des arguments spécifiques
pkill -f "python3 .*/scripts/backup\.py --daily"

# Cibler une application Java avec sa classe main
pkill -f "java.*com\.example\.MainClass"

# Processus avec un port spécifique dans les arguments
pkill -f ".*--port=8080"
```

### Précautions et bonnes pratiques

> [!warning] Testez avant de tuer ! Utilisez toujours `pgrep` (équivalent en lecture seule) pour vérifier ce qui sera affecté.

**Workflow recommandé :**

```bash
# 1. Tester la sélection avec pgrep
pgrep -a -u john firefox
# Liste tous les processus correspondants

# 2. Vérifier le nombre
pgrep -c -u john firefox
# 3

# 3. Si OK, utiliser pkill avec les mêmes options
pkill -u john firefox
```

**Éviter les dégâts :**

```bash
# DANGER : Trop vague, peut affecter des processus inattendus
pkill bash    # Peut tuer toutes vos sessions !

# MIEUX : Être spécifique
pkill -f "bash.*mon_script"

# ENCORE MIEUX : Tester d'abord
pgrep -af "bash.*mon_script"
# Vérifier la sortie
pkill -f "bash.*mon_script"
```

---

## ⚖️ Comparaison des outils

### Tableau récapitulatif

|Critère|kill|killall|pkill|
|---|---|---|---|
|**Cible par**|PID|Nom exact|Motif (regex)|
|**Flexibilité**|⭐|⭐⭐|⭐⭐⭐⭐⭐|
|**Sécurité**|⭐⭐⭐⭐⭐|⭐⭐⭐|⭐⭐⭐|
|**Facilité**|⭐⭐⭐⭐|⭐⭐⭐⭐⭐|⭐⭐⭐|
|**Puissance**|⭐⭐|⭐⭐⭐|⭐⭐⭐⭐⭐|
|**Critères multiples**|Non|Limité|Oui (nombreux)|
|**Ligne de commande complète**|Non|Non|Oui (-f)|
|**Regex**|Non|Oui (-r)|Oui (natif)|
|**Précision**|Maximale (PID unique)|Moyenne|Variable|

### Quand utiliser chaque outil ?

> [!tip] Guide de décision

**Utilisez `kill` quand :**

- Vous connaissez le PID exact du processus
- Vous voulez une **précision maximale** (un seul processus)
- Vous travaillez avec des scripts qui manipulent des PIDs
- Vous avez besoin de la **sécurité** de ne jamais affecter le mauvais processus

```bash
# Exemples typiques
kill $(cat /var/run/nginx.pid)
kill $PID_VARIABLE
kill $(pgrep -f "mon_script_unique.py")
```

**Utilisez `killall` quand :**

- Vous voulez terminer **toutes les instances** d'une application simple
- Le nom du processus est **unique et non ambigu**
- Vous voulez une commande **simple et rapide**
- Vous travaillez avec des applications courantes (firefox, chrome, etc.)

```bash
# Exemples typiques
killall firefox
killall -u john chrome
killall -HUP nginx
```

**Utilisez `pkill` quand :**

- Vous avez besoin de **critères de sélection complexes**
- Vous devez chercher dans la **ligne de commande complète** (-f)
- Vous voulez cibler des processus par **parent, terminal, session**, etc.
- Vous travaillez avec des scripts ou processus aux noms génériques
- Vous avez besoin de **regex avancées**

```bash
# Exemples typiques
pkill -f "python3.*mon_projet"
pkill -u john -t pts/0
pkill -P 1234 -f worker
pkill -9 -o defunct
```

### Exemples comparatifs

> [!example] Même tâche, différents outils

**Scénario 1 : Terminer tous les processus Firefox**

```bash
# Avec kill (nécessite de récupérer les PIDs)
kill $(pgrep firefox)
kill $(pidof firefox)

# Avec killall (le plus simple ici)
killall firefox

# Avec pkill (équivalent)
pkill firefox
```

**Scénario 2 : Terminer un script Python spécifique**

```bash
# Avec kill (nécessite de trouver le PID d'abord)
ps aux | grep "python3 backup.py"
kill 1234

# Avec killall (ne fonctionne PAS - le nom est "python3", pas "backup.py")
killall python3    # DANGER : tue tous les processus Python !

# Avec pkill (la meilleure option)
pkill -f "python3.*backup.py"
```

**Scénario 3 : Terminer les processus d'un utilisateur sur un terminal**

```bash
# Avec kill (très complexe)
ps -u john -t pts/0 -o pid= | xargs kill

# Avec killall (impossible - pas de critère terminal)
# N/A

# Avec pkill (simple et élégant)
pkill -u john -t pts/0
```

---

## ⚠️ Pièges courants

### 1. Confusion entre nom de processus et nom de commande

> [!warning] Le nom du processus n'est pas toujours ce que vous pensez

```bash
# Le processus s'appelle "python3", pas "mon_script.py"
ps aux | grep mon_script.py
# user  1234  python3 mon_script.py

# ERREUR : ne trouve rien
killall mon_script.py

# DANGER : tue tous les processus Python !
killall python3

# CORRECT : utiliser pkill avec -f
pkill -f mon_script.py
```

**Solution :** Toujours vérifier le nom réel avec `ps` ou `pgrep -a`.

### 2. Oublier que killall tue TOUS les processus

```bash
# DANGER : tue toutes vos sessions bash ouvertes !
killall bash

# DANGER : tue tous les serveurs PostgreSQL
killall postgres

# Toujours vérifier d'abord
pgrep -a bash
# Réfléchir : est-ce vraiment ce que je veux ?
```

**Solution :** Utilisez `pgrep` pour prévisualiser, ou `pkill` avec des critères plus stricts.

### 3. Permissions insuffisantes

```bash
# Tentative de tuer un processus root
kill 1234
# kill: (1234) - Operation not permitted

# Oublier sudo
killall nginx
# nginx: no process found (mais il existe, vous n'avez juste pas la permission)

# CORRECT
sudo killall nginx
```

**Solution :** Utilisez `sudo` pour les processus système, et vérifiez les propriétaires avec `ps aux`.

### 4. Signal par défaut inadapté

```bash
# SIGTERM par défaut, mais le processus ne répond pas
kill 1234
sleep 5
ps -p 1234    # Toujours là !

# Forcer avec SIGKILL
kill -9 1234
```

**Solution :** Commencez par SIGTERM, attendez, puis utilisez SIGKILL si nécessaire.

### 5. Ne pas attendre la terminaison

```bash
# Script qui ne laisse pas le temps au processus de se terminer
kill 1234
# Immédiatement après...
rm -rf /var/app/data    # DANGER : le processus peut encore écrire !
```

**Solution :** Attendez que le processus se termine complètement.

```bash
# CORRECT : attendre la fin
kill 1234

# Attendre que le processus n'existe plus
while kill -0 1234 2>/dev/null; do
    sleep 1
done

# Maintenant, c'est sûr
rm -rf /var/app/data
```

### 6. Regex trop larges ou ambiguës

```bash
# Trop vague, peut matcher n'importe quoi
pkill ".*app.*"    # Peut affecter "gnome-appearance-properties" !

# MIEUX : être spécifique
pkill "^mon_app$"
pkill -x mon_app
```

**Solution :** Testez toujours avec `pgrep -a` avant d'utiliser `pkill`.

### 7. Ignorer les processus enfants

```bash
# Tuer le parent, mais les enfants continuent (orphelins)
kill 1234

# Les processus enfants sont adoptés par init/systemd et continuent
```

**Solution :** Tuez d'abord les enfants, puis le parent, ou utilisez `pkill -P`.

```bash
# Méthode 1 : tuer les enfants d'abord
pkill -P 1234    # Enfants
kill 1234        # Parent

# Méthode 2 : tuer toute la hiérarchie
kill -TERM -1234    # Groupe de processus (note le -)
```

### 8. Utiliser SIGKILL trop rapidement

```bash
# MAUVAIS : SIGKILL immédiat
kill -9 1234    # Pas de nettoyage possible !

# BON : donner une chance avec SIGTERM
kill 1234
sleep 5
if ps -p 1234 > /dev/null; then
    kill -9 1234
fi
```

**Solution :** Privilégiez toujours SIGTERM en premier lieu.

### 9. Confusion avec les noms tronqués

```bash
# ps tronque les noms à 15 caractères
ps aux | grep very_long_process_name
# Affiche : very_long_proce

# killall cherche le nom tronqué
killall very_long_process_name    # Ne trouve rien !

# CORRECT
killall -e very_long_proce        # Nom tronqué
# ou
pkill -f very_long_process_name   # Ligne complète
```

**Solution :** Utilisez `pkill -f` pour les noms longs.

### 10. Ne pas vérifier le résultat

```bash
# Supposer que ça a marché
killall firefox

# MIEUX : vérifier
killall firefox
if pgrep firefox > /dev/null; then
    echo "Échec de la terminaison"
    killall -9 firefox
else
    echo "Terminaison réussie"
fi
```

**Solution :** Vérifiez toujours avec `pgrep`, `ps`, ou le code de retour.

---

## 💡 Astuces avancées

### 1. Fonction shell pour terminaison intelligente

```bash
# Ajouter à votre .bashrc
smart_kill() {
    local pid=$1
    local signal=${2:-TERM}
    local timeout=${3:-10}
    
    # Vérifier si le processus existe
    if ! kill -0 "$pid" 2>/dev/null; then
        echo "Processus $pid n'existe pas"
        return 1
    fi
    
    # Envoyer le signal
    kill -"$signal" "$pid"
    
    # Attendre la terminaison avec timeout
    local count=0
    while kill -0 "$pid" 2>/dev/null && [ $count -lt $timeout ]; do
        sleep 1
        count=$((count + 1))
    done
    
    # Vérifier le résultat
    if kill -0 "$pid" 2>/dev/null; then
        echo "Processus $pid ne répond pas après ${timeout}s"
        read -p "Forcer avec SIGKILL ? (y/N) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            kill -9 "$pid"
        fi
    else
        echo "Processus $pid terminé avec succès"
    fi
}

# Usage
smart_kill 1234           # SIGTERM avec timeout 10s
smart_kill 1234 HUP       # SIGHUP avec timeout 10s
smart_kill 1234 TERM 30   # SIGTERM avec timeout 30s
```

### 2. Tuer toute une arborescence de processus

```bash
# Fonction pour tuer un processus et tous ses descendants
kill_tree() {
    local pid=$1
    local signal=${2:-TERM}
    
    # Récupérer tous les descendants récursivement
    local children=$(pgrep -P "$pid")
    
    # Tuer d'abord les enfants (récursif)
    for child in $children; do
        kill_tree "$child" "$signal"
    done
    
    # Puis tuer le parent
    kill -"$signal" "$pid" 2>/dev/null
}

# Usage
kill_tree 1234        # Tuer toute l'arborescence avec SIGTERM
kill_tree 1234 KILL   # Forcer avec SIGKILL
```

### 3. Surveiller et redémarrer automatiquement

```bash
# Script watchdog simple
watch_and_restart() {
    local process_name=$1
    local restart_cmd=$2
    
    while true; do
        if ! pgrep -f "$process_name" > /dev/null; then
            echo "[$(date)] Processus mort, redémarrage..."
            $restart_cmd &
        fi
        sleep 5
    done
}

# Usage
watch_and_restart "mon_app" "/usr/bin/mon_app --daemon"
```

### 4. Recharger uniquement les workers (pas le master)

```bash
# Pour Nginx : recharger seulement les workers
pkill -HUP -f "nginx: worker process"

# Pour Gunicorn : recharger les workers
pkill -HUP -f "gunicorn.*worker"

# Alternative : utiliser le PID du master
kill -HUP $(cat /var/run/nginx.pid)
```

### 5. Rotation de logs sans redémarrage

```bash
# Forcer la réouverture des fichiers de log
# (utile après logrotate)

# Nginx
kill -USR1 $(cat /var/run/nginx.pid)

# Apache
kill -USR1 $(cat /var/run/apache2/apache2.pid)

# Application custom avec SIGUSR1
pkill -USR1 -f mon_application
```

### 6. Générer un core dump pour debug

```bash
# Forcer un core dump d'un processus qui tourne
kill -QUIT 1234    # ou -ABRT

# S'assurer que les core dumps sont activés
ulimit -c unlimited

# Le fichier core sera dans le répertoire de travail du processus
# ou dans /var/crash selon la configuration
```

### 7. Nettoyer les processus zombies

```bash
# Les zombies ont un parent qui n'a pas fait wait()
# Identifier les zombies
ps aux | grep defunct
ps aux | awk '$8=="Z" {print}'

# Envoyer SIGCHLD au parent pour qu'il nettoie
pkill -CHLD -P $(pgrep parent_process)

# Si le parent ne répond pas, le tuer (les zombies seront adoptés par init)
kill $(ps -A -o ppid= -o stat= | awk '$2=="Z" {print $1}' | sort -u)
```

### 8. Envoyer des signaux en masse avec précaution

```bash
# Script pour terminer proprement plusieurs processus
graceful_mass_kill() {
    local pattern=$1
    local pids=$(pgrep -f "$pattern")
    
    if [ -z "$pids" ]; then
        echo "Aucun processus trouvé"
        return
    fi
    
    echo "Processus à terminer :"
    pgrep -af "$pattern"
    
    read -p "Continuer ? (y/N) " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        # SIGTERM d'abord
        pkill -TERM -f "$pattern"
        sleep 5
        
        # SIGKILL pour les récalcitrants
        if pgrep -f "$pattern" > /dev/null; then
            echo "Certains processus résistent, utilisation de SIGKILL"
            pkill -KILL -f "$pattern"
        fi
    fi
}

# Usage
graceful_mass_kill "python.*worker"
```

### 9. Alias utiles

```bash
# Ajouter à votre .bashrc

# Terminer proprement puis forcer
alias k9='kill -9'
alias kt='kill -TERM'

# Fonctions pratiques
alias psgrep='ps aux | grep -v grep | grep -i -e VSZ -e'
alias psk='ps aux | grep -v grep | grep -i'

# Compter les processus
alias pscount='ps aux | wc -l'

# Trouver les plus gourmands
alias psmem='ps aux --sort=-%mem | head -n 10'
alias pscpu='ps aux --sort=-%cpu | head -n 10'
```

### 10. Déboguer les problèmes de signaux

```bash
# Tracer les signaux reçus par un processus
strace -e signal -p 1234

# Voir quels signaux sont bloqués/ignorés
cat /proc/1234/status | grep -E "Sig(Blk|Ign|Cgt)"

# SigBlk : signaux bloqués
# SigIgn : signaux ignorés
# SigCgt : signaux capturés (avec handler)

# Decoder les masques (hexadécimal -> liste de signaux)
# Utiliser kill -l avec les valeurs
```

---

## 📊 Bonnes pratiques récapitulatives

### Workflow recommandé pour terminer un processus

```bash
# 1. IDENTIFIER le processus
ps aux | grep mon_app
# ou
pgrep -a mon_app

# 2. VÉRIFIER ce qui sera affecté
pgrep -af "pattern"    # Voir tous les processus correspondants

# 3. TENTER une terminaison propre (SIGTERM)
kill 1234
# ou
pkill -TERM -f "pattern"

# 4. ATTENDRE un délai raisonnable
sleep 5

# 5. VÉRIFIER si terminé
if ps -p 1234 > /dev/null; then
    echo "Processus toujours actif"
fi

# 6. FORCER si nécessaire (SIGKILL)
kill -9 1234
# ou
pkill -KILL -f "pattern"

# 7. CONFIRMER la terminaison
ps -p 1234 || echo "Processus terminé"
```

### Règles d'or

> [!tip] Les 10 commandements des signaux Linux

1. **Toujours privilégier SIGTERM avant SIGKILL**
2. **Tester avec `pgrep` avant d'utiliser `pkill`**
3. **Vérifier les permissions (sudo si nécessaire)**
4. **Utiliser `-f` avec `pkill` pour les scripts et arguments**
5. **Attendre la terminaison avant de nettoyer les ressources**
6. **Ne jamais faire `killall bash` ou équivalent sans réfléchir**
7. **Documenter l'usage de SIGUSR1/USR2 dans vos applications**
8. **Vérifier le résultat après avoir envoyé un signal**
9. **Penser aux processus enfants**
10. **Utiliser le signal 0 pour tester l'existence d'un processus**

### Matrice de décision rapide

|Situation|Commande recommandée|
|---|---|
|Vous avez le PID exact|`kill PID`|
|Application simple et connue|`killall nom_app`|
|Script avec arguments|`pkill -f "script.py --args"`|
|Processus d'un utilisateur|`pkill -u user`|
|Processus sur un terminal|`pkill -t pts/0`|
|Recharger config|`kill -HUP $(cat pidfile)`|
|Processus bloqué|`kill PID` puis `kill -9 PID`|
|Tous les enfants d'un parent|`pkill -P PPID`|
|Pattern complexe|`pkill -f "regex"`|
|Doute sur la cible|`pgrep -a` d'abord !|

---

## 🎓 Résumé final

### Les 3 outils, en bref

**`kill`** : Précis, sûr, mais nécessite un PID

- ✅ Maximum de contrôle
- ✅ Aucun risque d'affecter le mauvais processus
- ❌ Nécessite de connaître le PID

**`killall`** : Simple et rapide pour les applications courantes

- ✅ Facile à utiliser
- ✅ Parfait pour les apps avec noms uniques
- ❌ Peut être dangereux si mal utilisé
- ❌ Limité aux noms de processus

**`pkill`** : Puissant et flexible pour les cas complexes

- ✅ Critères de sélection multiples
- ✅ Recherche dans la ligne complète (-f)
- ✅ Regex natives
- ❌ Plus complexe à maîtriser
- ❌ Risque d'erreur avec des patterns larges

### Les signaux essentiels

|Signal|Quand l'utiliser|
|---|---|
|**SIGTERM (15)**|Par défaut, terminaison propre|
|**SIGKILL (9)**|En dernier recours, force brutale|
|**SIGHUP (1)**|Recharger la configuration|
|**SIGINT (2)**|Interruption (équivalent Ctrl+C)|
|**SIGUSR1/2**|Actions personnalisées (selon l'app)|

### Commande universelle pour débuter

Quand vous ne savez pas quoi utiliser, cette commande fonctionne dans 90% des cas :

```bash
# Chercher le processus
pgrep -af "votre_motif"

# Si c'est bien ce que vous voulez
pkill -f "votre_motif"

# Attendre 5 secondes
sleep 5

# Forcer si nécessaire
pkill -9 -f "votre_motif"
```

---

**Fin du cours - Gestion des processus : Signaux Linux** 🎯