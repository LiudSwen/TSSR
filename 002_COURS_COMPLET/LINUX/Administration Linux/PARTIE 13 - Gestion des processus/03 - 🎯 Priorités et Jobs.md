

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

## 🎚️ Gestion des Priorités (nice et renice)

### Comprendre les priorités Linux

Linux utilise un système de priorités pour déterminer quel processus obtient du temps CPU. Chaque processus possède une valeur de **niceness** (gentillesse) qui influence sa priorité d'ordonnancement.

> [!info] Valeurs de niceness
> 
> - **Plage** : -20 (priorité maximale) à +19 (priorité minimale)
> - **Défaut** : 0 (priorité normale)
> - **Plus la valeur est basse**, plus le processus est prioritaire
> - **Plus la valeur est haute**, plus le processus est "gentil" (laisse la place aux autres)

#### Relation entre niceness et priorité

|Niceness|Priorité|Usage typique|
|---|---|---|
|-20 à -10|Très haute|Processus système critiques|
|-9 à -1|Haute|Tâches importantes|
|0|Normale|Processus standards|
|1 à 10|Basse|Tâches non urgentes|
|11 à 19|Très basse|Tâches de fond, batch|

> [!warning] Permissions requises
> 
> - **Augmenter la priorité** (niceness négative) : nécessite les droits root
> - **Diminuer la priorité** (niceness positive) : accessible à tous les utilisateurs
> - Un utilisateur normal peut uniquement rendre ses propres processus "plus gentils"

---

### La commande nice

La commande `nice` permet de **lancer un nouveau processus** avec une priorité modifiée.

#### Syntaxe de base

```bash
nice [OPTIONS] [COMMANDE]
```

#### Options principales

```bash
# -n VALEUR : définit la valeur de niceness (par défaut +10 si non spécifié)
nice -n VALEUR commande

# Raccourci : -VALEUR équivaut à -n VALEUR
nice -15 commande
```

#### Exemples pratiques

```bash
# Lancer un processus avec priorité basse (+10 par défaut)
nice ./script_long.sh

# Spécifier une valeur de niceness précise (+15)
nice -n 15 ffmpeg -i video.mp4 output.avi

# Syntaxe raccourcie
nice -15 tar czf backup.tar.gz /home

# Priorité haute (nécessite root)
sudo nice -n -10 ./processus_critique

# Priorité maximale (root uniquement)
sudo nice -n -20 ./processus_temps_reel
```

> [!example] Cas d'usage concrets
> 
> ```bash
> # Compilation en arrière-plan sans ralentir le système
> nice -n 15 make -j4
> 
> # Encodage vidéo avec faible priorité
> nice -n 19 handbrake-cli -i input.mkv -o output.mp4
> 
> # Sauvegarde nocturne avec priorité réduite
> nice -n 10 rsync -av /data /backup
> 
> # Processus critique avec haute priorité (root)
> sudo nice -n -15 /usr/sbin/serveur_critique
> ```

#### Vérifier la niceness d'un processus

```bash
# Avec ps
ps -eo pid,ni,comm | grep nom_processus

# Avec top (colonne NI)
top

# Avec htop (plus visuel)
htop
```

---

### La commande renice

La commande `renice` permet de **modifier la priorité d'un processus déjà en cours d'exécution**.

#### Syntaxe de base

```bash
renice [-n] PRIORITÉ [-p PID] [-g GID] [-u USER]
```

#### Options principales

|Option|Description|
|---|---|
|`-n PRIORITÉ`|Nouvelle valeur de niceness|
|`-p PID`|Modifier le processus avec ce PID|
|`-g GID`|Modifier tous les processus du groupe|
|`-u USER`|Modifier tous les processus de l'utilisateur|

#### Exemples pratiques

```bash
# Modifier la priorité d'un processus par PID
renice -n 10 -p 1234

# Syntaxe alternative (sans -n)
renice 10 -p 1234

# Modifier plusieurs processus simultanément
renice -n 15 -p 1234 -p 5678 -p 9012

# Modifier tous les processus d'un utilisateur
sudo renice -n 5 -u pierre

# Modifier un groupe de processus
sudo renice -n 10 -g 500

# Augmenter la priorité (nécessite root)
sudo renice -n -10 -p 1234
```

> [!example] Scénarios réels
> 
> ```bash
> # Réduire la priorité d'une compilation qui consomme trop
> renice -n 19 -p $(pgrep gcc)
> 
> # Donner plus de priorité à un serveur web surchargé (root)
> sudo renice -n -5 -p $(pgrep nginx)
> 
> # Ralentir tous les processus d'un utilisateur
> sudo renice -n 15 -u backup_user
> 
> # Trouver et modifier un processus gourmand
> top  # Noter le PID
> renice -n 15 -p 8765
> ```

> [!tip] Astuce : Combiner avec pgrep
> 
> ```bash
> # Modifier tous les processus d'un programme
> renice -n 10 -p $(pgrep nom_programme)
> 
> # Exemple : réduire la priorité de tous les ffmpeg
> renice -n 19 -p $(pgrep ffmpeg)
> 
> # Avec confirmation
> ps aux | grep ffmpeg
> renice -n 19 -p $(pgrep ffmpeg)
> ```

#### Limitations et permissions

> [!warning] Règles importantes
> 
> - **Utilisateur normal** :
>     - Peut uniquement augmenter la niceness (réduire la priorité)
>     - Ne peut modifier que ses propres processus
>     - Ne peut pas revenir à une valeur plus basse
> - **Root** :
>     - Peut définir n'importe quelle valeur (-20 à 19)
>     - Peut modifier n'importe quel processus
>     - Peut augmenter ou diminuer la priorité

```bash
# ❌ Impossible pour un utilisateur normal
renice -n -5 -p 1234  # Erreur : permission denied

# ✅ Possible pour un utilisateur normal
renice -n 10 -p 1234  # OK : réduction de priorité

# ✅ Avec sudo
sudo renice -n -5 -p 1234  # OK : augmentation de priorité
```

---

## ⚙️ Jobs en Arrière-plan

Les **jobs** permettent d'exécuter des commandes en arrière-plan, libérant ainsi le terminal pour d'autres tâches. C'est une fonctionnalité du shell (bash, zsh, etc.).

### Lancer des jobs en arrière-plan (&)

#### Syntaxe de base

```bash
# Lancer une commande en arrière-plan
commande &

# Lancer avec redirections
commande > output.log 2>&1 &
```

#### Exemples pratiques

```bash
# Compilation en arrière-plan
make -j4 &

# Téléchargement long
wget https://example.com/fichier_volumineux.iso &

# Script de traitement
./traitement_donnees.sh &

# Avec redirection de sortie
find / -name "*.log" > logs.txt 2>&1 &

# Serveur de développement
python -m http.server 8000 &
```

> [!info] Comportement du &
> 
> - Le processus s'exécute en arrière-plan
> - Le shell affiche un **numéro de job** et le **PID**
> - Le terminal reste disponible pour d'autres commandes
> - La sortie standard peut toujours s'afficher dans le terminal (sauf redirection)

```bash
# Exemple de sortie
$ sleep 100 &
[1] 12345
# [1] = numéro du job
# 12345 = PID du processus
```

---

### Gérer les jobs (bg, fg, jobs)

#### La commande `jobs`

Liste tous les jobs actifs dans le shell actuel.

```bash
# Lister tous les jobs
jobs

# Afficher également les PIDs
jobs -l

# Afficher uniquement les jobs en cours d'exécution
jobs -r

# Afficher uniquement les jobs stoppés
jobs -s
```

**Exemple de sortie** :

```bash
$ jobs -l
[1]  12345 Running     make -j4 &
[2]- 12346 Stopped     vim document.txt
[3]+ 12347 Running     ./script.sh &
```

> [!info] Symboles dans jobs
> 
> - `+` : job actuel (celui qui sera ciblé par défaut par fg/bg)
> - `-` : job précédent
> - **Running** : en cours d'exécution
> - **Stopped** : suspendu (Ctrl+Z)

#### La commande `fg` (foreground)

Ramène un job en avant-plan.

```bash
# Ramener le job actuel (+) en avant-plan
fg

# Ramener un job spécifique par numéro
fg %1
fg %2

# Ramener le job précédent
fg %-

# Ramener par nom de commande
fg %make
fg %vim
```

**Exemples pratiques** :

```bash
# Lancer en arrière-plan puis ramener en avant
sleep 100 &
fg  # Ramène sleep en avant-plan

# Gérer plusieurs jobs
vim fichier1.txt &
vim fichier2.txt &
jobs
fg %2  # Ramener le second vim
```

#### La commande `bg` (background)

Relance un job suspendu en arrière-plan.

```bash
# Relancer le job actuel en arrière-plan
bg

# Relancer un job spécifique
bg %1
bg %2

# Relancer par nom
bg %make
```

**Scénario typique** :

```bash
# Lancer une commande
./script_long.sh

# Suspendre avec Ctrl+Z
^Z
[1]+  Stopped     ./script_long.sh

# Relancer en arrière-plan
bg
[1]+ ./script_long.sh &

# Vérifier
jobs
[1]+  Running     ./script_long.sh &
```

---

### Contrôle des jobs au clavier

#### Raccourcis clavier essentiels

|Raccourci|Action|Résultat|
|---|---|---|
|`Ctrl+Z`|Suspend le processus|Passe en état "Stopped"|
|`Ctrl+C`|Interrompt le processus|Termine le processus (SIGINT)|
|`Ctrl+D`|EOF (End Of File)|Ferme l'entrée standard|

#### Workflow typique

```bash
# 1. Lancer une commande
ping google.com

# 2. Suspendre avec Ctrl+Z
^Z
[1]+  Stopped     ping google.com

# 3. Vérifier les jobs
jobs
[1]+  Stopped     ping google.com

# 4a. Continuer en arrière-plan
bg
[1]+ ping google.com &

# OU 4b. Ramener en avant-plan
fg
ping google.com
```

> [!example] Cas pratiques
> 
> ```bash
> # Éditer un fichier, le suspendre, vérifier quelque chose, puis y revenir
> vim config.conf
> # Ctrl+Z pour suspendre
> cat /var/log/app.log  # Vérifier les logs
> fg  # Revenir à vim
> 
> # Lancer une compilation, la suspendre si elle prend trop de ressources
> make -j8
> # Ctrl+Z
> renice -n 15 -p $(pgrep make)
> bg  # Continuer en arrière-plan avec priorité réduite
> ```

#### Arrêter un job

```bash
# Avec kill et le numéro de job
kill %1
kill %2

# Avec kill et le PID
kill 12345

# Force kill (SIGKILL)
kill -9 %1
kill -9 12345

# Arrêter tous les jobs en arrière-plan
kill $(jobs -p)
```

---

## 🔒 Persistance des Processus (nohup et disown)

Par défaut, lorsqu'un terminal est fermé, tous les jobs associés reçoivent un signal **SIGHUP** (hangup) et se terminent. Les commandes `nohup` et `disown` permettent de faire persister les processus même après la déconnexion.

### La commande nohup

`nohup` (no hangup) lance une commande en l'immunisant contre le signal SIGHUP.

#### Syntaxe de base

```bash
nohup COMMANDE [ARGUMENTS] &
```

#### Comportement

> [!info] Caractéristiques de nohup
> 
> - **Ignore SIGHUP** : le processus continue après fermeture du terminal
> - **Redirige automatiquement** : stdout et stderr vers `nohup.out` (dans le répertoire courant)
> - **Doit être utilisé au lancement** : ne peut pas être appliqué à un processus déjà en cours
> - **Souvent combiné avec &** : pour exécution en arrière-plan

#### Exemples pratiques

```bash
# Lancement basique
nohup ./script_long.sh &

# Avec redirection personnalisée
nohup ./script.sh > mon_log.txt 2>&1 &

# Sans fichier de sortie (redirigé vers /dev/null)
nohup ./script.sh > /dev/null 2>&1 &

# Serveur web persistant
nohup python -m http.server 8000 &

# Sauvegarde longue
nohup rsync -av /source /destination > backup.log 2>&1 &

# Encodage vidéo overnight
nohup ffmpeg -i input.mp4 output.avi > encoding.log 2>&1 &
```

#### Vérifier le fichier nohup.out

```bash
# Voir la sortie en temps réel
tail -f nohup.out

# Voir les dernières lignes
tail -n 50 nohup.out

# Chercher dans la sortie
grep "ERROR" nohup.out
```

> [!warning] Gestion du fichier nohup.out
> 
> - Le fichier `nohup.out` est créé **dans le répertoire courant**
> - Si pas d'accès en écriture, il est créé dans `$HOME/nohup.out`
> - Le fichier peut devenir très volumineux avec le temps
> - Pensez à rediriger vers un fichier spécifique ou `/dev/null`

#### Retrouver un processus nohup

```bash
# Lister tous les processus
ps aux | grep nom_script

# Avec le fichier nohup.out
ls -l nohup.out
tail nohup.out

# Arrêter un processus nohup
kill $(pgrep -f nom_script)
```

---

### La commande disown

`disown` détache un job déjà en cours d'exécution du shell actuel, lui permettant de survivre à la fermeture du terminal.

#### Syntaxe de base

```bash
disown [OPTIONS] [%JOB_ID]
```

#### Options principales

|Option|Description|
|---|---|
|`disown`|Retire le job actuel (+)|
|`disown %1`|Retire le job numéro 1|
|`disown -h %1`|Marque le job pour ignorer SIGHUP (mais reste dans jobs)|
|`disown -a`|Retire tous les jobs|
|`disown -r`|Retire uniquement les jobs en cours d'exécution|

#### Exemples pratiques

```bash
# Scénario 1 : Oubli du & au lancement
./script_long.sh
# Ctrl+Z pour suspendre
bg  # Relancer en arrière-plan
disown  # Détacher du shell

# Scénario 2 : Job déjà en arrière-plan
./traitement.sh &
disown %1

# Scénario 3 : Plusieurs jobs à détacher
make -j4 &
rsync -av /data /backup &
jobs
disown -a  # Détacher tous les jobs

# Scénario 4 : Garder le job dans la liste mais ignorer SIGHUP
./serveur.sh &
disown -h %1  # Le job reste visible avec jobs mais ignore SIGHUP
```

#### Workflow typique

```bash
# 1. Lancer une commande (oubli de nohup)
python train_model.py

# 2. Réaliser qu'il faut déconnecter
# Ctrl+Z

# 3. Relancer en arrière-plan
bg

# 4. Détacher du shell
disown

# 5. Vérifier que le processus existe toujours
ps aux | grep train_model.py

# 6. Fermer le terminal - le processus continue
exit
```

> [!tip] Astuce : Combiner avec nohup pour les redirections
> 
> ```bash
> # Si vous avez oublié nohup et voulez la redirection
> ./script.sh > output.log 2>&1
> # Ctrl+Z
> bg
> disown
> 
> # Attention : la sortie reste attachée au terminal
> # Mieux vaut : fermer stdin/stdout/stderr
> ./script.sh > output.log 2>&1 < /dev/null &
> disown
> ```

---

### Comparaison et cas d'usage

#### Tableau comparatif

|Critère|nohup|disown|
|---|---|---|
|**Quand l'utiliser**|Au lancement|Après lancement|
|**Protection SIGHUP**|Oui|Oui|
|**Redirection auto**|Oui (nohup.out)|Non|
|**Reste dans jobs**|Oui|Non (sauf -h)|
|**Nécessite &**|Recommandé|Oui (bg avant)|
|**Retrouver le processus**|Avec nohup.out|Avec ps/pgrep|

#### Quand utiliser quoi ?

> [!example] Cas d'usage de **nohup**
> 
> - **Planification** : Vous savez à l'avance que vous allez vous déconnecter
> - **Scripts longs** : Sauvegardes, compilations nocturnes, traitements batch
> - **Besoin de logs** : Vous voulez conserver automatiquement la sortie
> - **Serveurs persistants** : Applications qui doivent tourner en permanence
> 
> ```bash
> # Exemples typiques
> nohup ./backup_nightly.sh > backup.log 2>&1 &
> nohup python train_model.py > training.log 2>&1 &
> nohup node server.js > server.log 2>&1 &
> ```

> [!example] Cas d'usage de **disown**
> 
> - **Oubli** : Vous avez lancé une commande sans nohup
> - **Décision tardive** : Vous réalisez en cours de route que ça va prendre du temps
> - **Nettoyage** : Vous voulez retirer des jobs de la liste sans les tuer
> - **Sessions interactives** : Processus lancés depuis un shell interactif
> 
> ```bash
> # Exemples typiques
> ./long_process.sh  # Oups, oublié le &
> # Ctrl+Z
> bg
> disown
> 
> # Job déjà lancé
> rsync -av /huge /backup &
> disown  # On se déconnecte, ça va être long
> ```

#### Combinaison des deux

```bash
# Meilleure pratique : nohup + & + disown pour une persistance maximale
nohup ./script_critique.sh > output.log 2>&1 &
disown

# Ou avec redirection complète
nohup ./script.sh > /dev/null 2>&1 < /dev/null &
disown
```

#### Vérifier les processus persistants

```bash
# Lister tous vos processus
ps -u $USER

# Rechercher un processus spécifique
ps aux | grep nom_script

# Avec pgrep (plus propre)
pgrep -fl nom_script

# Surveiller un processus
watch -n 2 'ps aux | grep nom_script'

# Voir l'arborescence des processus
pstree -p

# Détails complets d'un processus
ps -fp PID
```

---

## 🎓 Bonnes Pratiques

### Gestion des priorités

> [!tip] Recommandations
> 
> - **Utilisez nice** pour les tâches de fond non urgentes (encodage, backup)
> - **Évitez les priorités négatives** sauf nécessité absolue (peut déstabiliser le système)
> - **Surveillez l'impact** avec `top` ou `htop` après modification
> - **Documentez** les processus avec priorités modifiées en production
> - **Combinez avec ionice** pour gérer aussi les priorités I/O (hors sujet ici)

```bash
# ✅ Bon usage
nice -n 15 make -j4  # Compilation sans gêner l'interactif
nice -n 19 rsync -av /data /backup  # Backup très discret

# ⚠️ Usage avec précaution
sudo nice -n -10 ./serveur_critique  # Seulement si vraiment nécessaire

# ❌ À éviter
sudo nice -n -20 firefox  # Inutile et potentiellement problématique
```

### Gestion des jobs

> [!tip] Recommandations
> 
> - **Toujours rediriger** la sortie pour les jobs en arrière-plan
> - **Utilisez des noms explicites** pour les scripts destinés à l'arrière-plan
> - **Documentez les jobs** critiques dans un fichier README ou logs
> - **Testez en avant-plan** d'abord avant de passer en arrière-plan
> - **Utilisez screen/tmux** pour des sessions persistantes plus robustes

```bash
# ✅ Bonnes pratiques
./backup.sh > backup_$(date +%Y%m%d).log 2>&1 &
nohup python script.py > script.log 2>&1 &
rsync -av --progress /src /dst > rsync.log 2>&1 &

# ❌ À éviter
./backup.sh &  # Sortie non redirigée, pollue le terminal
python script.py > /dev/null 2>&1 &  # Perte de logs en cas d'erreur
```

### Persistance des processus

> [!tip] Recommandations
> 
> - **Préférez nohup** si vous savez que vous allez vous déconnecter
> - **Utilisez disown** comme solution de secours
> - **Envisagez systemd** pour les services permanents (hors sujet ici)
> - **Utilisez screen/tmux** pour des sessions multiplexées (hors sujet ici)
> - **Gardez une trace** des processus persistants lancés

```bash
# ✅ Approche recommandée pour un script long
nohup ./script_long.sh > script_$(date +%Y%m%d_%H%M%S).log 2>&1 &
echo $! > script.pid  # Sauvegarder le PID

# ✅ Récupération après oubli
./script.sh > output.log 2>&1  # Oups
# Ctrl+Z
bg
disown
echo "Script lancé en arrière-plan, voir output.log"

# ✅ Vérification ultérieure
cat script.pid | xargs ps -p  # Vérifier que le processus existe encore
tail -f output.log  # Suivre la progression
```

---

## ⚠️ Pièges Courants

### Piège 1 : Confusion nice/renice

```bash
# ❌ Erreur : tenter d'utiliser nice sur un processus existant
nice -n 10 -p 1234  # Ne fonctionne pas !

# ✅ Correct : utiliser renice
renice -n 10 -p 1234
```

### Piège 2 : Oublier la redirection avec &

```bash
# ❌ Problème : la sortie continue de s'afficher
./script_verbeux.sh &

# ✅ Solution : rediriger la sortie
./script_verbeux.sh > output.log 2>&1 &
```

### Piège 3 : Jobs vs Processus

```bash
# Les jobs sont propres à chaque shell
# ❌ Ceci ne fonctionnera pas dans un autre terminal
fg %1  # Erreur : no such job

# ✅ Utiliser le PID avec ps/kill fonctionne partout
kill 12345
ps -p 12345
```

### Piège 4 : disown sur un processus déjà détaché

```bash
# ❌ Erreur : le job n'existe plus
./script.sh &
disown %1
disown %1  # Erreur : no such job

# ✅ Vérifier avant
jobs
disown %1
```

### Piège 5 : Croire que nohup suffit sans &

```bash
# ⚠️ Bloque le terminal (mais survivra à SIGHUP)
nohup ./script.sh

# ✅ Libère le terminal
nohup ./script.sh &
```

### Piège 6 : Permissions et priorités

```bash
# ❌ Erreur commune
renice -n -5 -p 1234  # Permission denied (utilisateur normal)

# ✅ Avec sudo
sudo renice -n -5 -p 1234

# ⚠️ Attention : un utilisateur peut se bloquer
renice -n 19 -p $$  # Rend le shell actuel très lent !
```

---

## 💡 Astuces Avancées

### Astuce 1 : Combiner nice avec ionice

```bash
# Processus à très faible priorité (CPU et I/O)
nice -n 19 ionice -c 3 rsync -av /source /destination
```

### Astuce 2 : Script avec gestion automatique de la priorité

```bash
#!/bin/bash
# auto_nice.sh - Se lance automatiquement avec low priority

# Si pas déjà "nice", se relancer avec nice
if [ "$NICE_LAUNCHED" != "1" ]; then
    export NICE_LAUNCHED=1
    exec nice -n 15 "$0" "$@"
fi

# Script normal ici
echo "Running with low priority"
```

### Astuce 3 : Fonction bash pour disown automatique

```bash
# À ajouter dans ~/.bashrc
background() {
    "$@" > /dev/null 2>&1 &
    disown
}

# Usage
background ./long_script.sh
```

### Astuce 4 : Monitorer les processus nice

```bash
# Voir tous les processus avec priorité modifiée
ps axo pid,ni,comm | awk '$2 != 0'

# Trouver les processus très prioritaires (potentiellement problématiques)
ps axo pid,ni,comm | awk '$2 < 0'
```

### Astuce 5 : Job control avancé

```bash
# Lancer plusieurs commandes en séquence en arrière-plan
(cmd1 && cmd2 && cmd3) > combined.log 2>&1 &

# Lancer en parallèle
cmd1 & cmd2 & cmd3 &
wait  # Attendre que tous se terminent

# Avec timeout et priorité
timeout 1h nice -n 15 ./script.sh &
```

### Astuce 6 : Logging amélioré pour nohup

```bash
# Fonction helper pour nohup avec logs horodatés
nohup_run() {
    local cmd="$1"
    local logfile="${2:-nohup_$(date +%Y%m%d_%H%M%S).log}"
    
    nohup bash -c "$cmd" > "$logfile" 2>&1 &
    local pid=$!
    
    echo "Process started:"
    echo "  PID: $pid"
    echo "  Log: $logfile"
    echo "  Command: $cmd"
    echo "$pid" > "${logfile}.pid"
}

# Usage
nohup_run "./training.py --epochs 100" "training.log"
```

### Astuce 7 : Réattacher un processus disowned

```bash
# Impossible de réattacher directement un processus disowned
# Mais on peut utiliser reptyr (à installer)
reptyr PID  # Réattache le processus au terminal actuel

# Ou utiliser gdb (méthode avancée)
gdb -p PID
# Dans gdb : call close(1), call close(2), etc.
```

### Astuce 8 : Liste de tous les jobs de tous les terminaux

```bash
# Voir tous vos processus en arrière-plan
ps -u $USER -o pid,ppid,ni,cmd | grep -v grep

# Avec l'arborescence
pstree -p $USER
```