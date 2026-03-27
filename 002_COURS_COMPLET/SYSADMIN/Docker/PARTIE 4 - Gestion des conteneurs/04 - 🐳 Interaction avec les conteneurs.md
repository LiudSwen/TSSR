

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

L'interaction avec les conteneurs Docker en cours d'exécution est une compétence essentielle pour le debugging, la maintenance et l'administration des applications conteneurisées. Docker propose plusieurs commandes pour interagir avec vos conteneurs de différentes manières : exécuter des commandes à l'intérieur d'un conteneur, se connecter à son processus principal, ou échanger des fichiers entre l'hôte et le conteneur.

> [!info] Pourquoi interagir avec les conteneurs ?
> 
> - **Debugging** : Inspecter l'état interne d'un conteneur en production
> - **Maintenance** : Effectuer des opérations ponctuelles sans reconstruire l'image
> - **Développement** : Tester rapidement des modifications ou récupérer des logs
> - **Dépannage** : Diagnostiquer des problèmes de configuration ou de réseau

---

## 🔧 docker exec

### Concept et utilité {#concept-et-utilité-exec}

`docker exec` permet d'exécuter une nouvelle commande dans un conteneur **déjà en cours d'exécution**. C'est l'outil le plus utilisé pour interagir avec les conteneurs, car il crée un nouveau processus indépendant du processus principal du conteneur.

> [!tip] Quand utiliser `docker exec` ?
> 
> - Explorer le système de fichiers du conteneur
> - Lancer un shell interactif pour du debugging
> - Exécuter des scripts de maintenance
> - Vérifier des variables d'environnement ou des configurations
> - Tester des commandes sans affecter le processus principal

### Syntaxe et options {#syntaxe-et-options-exec}

```bash
docker exec [OPTIONS] CONTAINER COMMAND [ARG...]
```

#### Options principales

|Option|Description|Exemple|
|---|---|---|
|`-i, --interactive`|Garde STDIN ouvert même si non attaché|`docker exec -i mon_conteneur cat file.txt`|
|`-t, --tty`|Alloue un pseudo-TTY (terminal)|`docker exec -t mon_conteneur ls`|
|`-d, --detach`|Exécute la commande en arrière-plan|`docker exec -d mon_conteneur script.sh`|
|`-e, --env`|Définit des variables d'environnement|`docker exec -e VAR=value mon_conteneur env`|
|`-w, --workdir`|Définit le répertoire de travail|`docker exec -w /app mon_conteneur pwd`|
|`-u, --user`|Spécifie l'utilisateur (nom ou UID)|`docker exec -u root mon_conteneur whoami`|
|`--privileged`|Donne des privilèges étendus à la commande|`docker exec --privileged mon_conteneur fdisk -l`|

> [!warning] Important Le conteneur **doit être en état "running"** pour utiliser `docker exec`. Si le conteneur est arrêté, la commande échouera.

### Cas d'usage courants {#cas-dusage-courants-exec}

#### 1. Ouvrir un shell interactif (le plus courant)

```bash
# Shell bash interactif
docker exec -it mon_conteneur bash

# Si bash n'est pas disponible, utiliser sh
docker exec -it mon_conteneur sh

# Spécifier un shell particulier
docker exec -it mon_conteneur /bin/zsh
```

> [!example] Exemple pratique
> 
> ```bash
> # Ouvrir un shell dans un conteneur nginx
> docker exec -it nginx_web bash
> 
> # Une fois à l'intérieur, vous pouvez :
> cd /etc/nginx
> cat nginx.conf
> ls -la /usr/share/nginx/html
> exit  # Quitter le shell
> ```

#### 2. Exécuter une commande unique

```bash
# Lister les fichiers
docker exec mon_conteneur ls -la /app

# Vérifier les processus en cours
docker exec mon_conteneur ps aux

# Afficher le contenu d'un fichier
docker exec mon_conteneur cat /var/log/app.log

# Vérifier la connectivité réseau
docker exec mon_conteneur ping -c 3 google.com
```

#### 3. Exécuter des commandes en tant qu'utilisateur root

```bash
# Installer un package pour du debugging temporaire
docker exec -u root mon_conteneur apt-get update
docker exec -u root mon_conteneur apt-get install -y vim

# Modifier des permissions
docker exec -u root mon_conteneur chown -R www-data:www-data /var/www
```

> [!warning] Attention Les modifications effectuées avec `exec` sont **temporaires** et seront perdues si le conteneur est supprimé. Pour des changements permanents, modifiez le Dockerfile et reconstruisez l'image.

#### 4. Exécuter en arrière-plan

```bash
# Lancer un script de maintenance en arrière-plan
docker exec -d mon_conteneur /scripts/cleanup.sh

# Démarrer un processus supplémentaire
docker exec -d mon_conteneur python /app/worker.py
```

#### 5. Définir des variables d'environnement

```bash
# Passer une variable d'environnement
docker exec -e DEBUG=true mon_conteneur python app.py

# Plusieurs variables
docker exec -e VAR1=value1 -e VAR2=value2 mon_conteneur env
```

#### 6. Travailler dans un répertoire spécifique

```bash
# Exécuter une commande depuis un répertoire particulier
docker exec -w /app/data mon_conteneur ls -la

# Combiner avec un shell interactif
docker exec -it -w /var/log mon_conteneur bash
```

### Pièges et bonnes pratiques {#pièges-et-bonnes-pratiques-exec}

> [!warning] Pièges courants
> 
> **1. Oublier les flags `-it` pour un shell interactif**
> 
> ```bash
> # ❌ Mauvais : le shell ne sera pas utilisable
> docker exec mon_conteneur bash
> 
> # ✅ Bon : terminal interactif complet
> docker exec -it mon_conteneur bash
> ```
> 
> **2. Le shell n'existe pas**
> 
> ```bash
> # ❌ Peut échouer sur des images minimalistes (alpine)
> docker exec -it mon_conteneur bash
> 
> # ✅ Utiliser sh qui est presque toujours disponible
> docker exec -it mon_conteneur sh
> ```
> 
> **3. Problèmes de permissions**
> 
> ```bash
> # ❌ Peut échouer si l'utilisateur n'a pas les droits
> docker exec mon_conteneur cat /root/secret.txt
> 
> # ✅ Utiliser root si nécessaire
> docker exec -u root mon_conteneur cat /root/secret.txt
> ```

> [!tip] Bonnes pratiques
> 
> **1. Utiliser des noms de conteneurs explicites**
> 
> ```bash
> # ✅ Plus lisible et maintenable
> docker exec -it web_frontend bash
> 
> # ❌ Difficile à retenir
> docker exec -it a1b2c3d4 bash
> ```
> 
> **2. Vérifier l'état du conteneur avant**
> 
> ```bash
> # Vérifier que le conteneur tourne
> docker ps | grep mon_conteneur
> 
> # Puis exécuter la commande
> docker exec -it mon_conteneur bash
> ```
> 
> **3. Pour du debugging, installer temporairement des outils**
> 
> ```bash
> # Installer des outils de debugging sans modifier l'image
> docker exec -u root mon_conteneur apt-get update
> docker exec -u root mon_conteneur apt-get install -y curl vim htop
> ```
> 
> **4. Nettoyer après le debugging**
> 
> ```bash
> # Supprimer les outils installés temporairement
> docker exec -u root mon_conteneur apt-get remove -y curl vim htop
> docker exec -u root mon_conteneur apt-get autoremove -y
> ```

> [!info] Astuce : Créer des alias Gagnez du temps avec des alias dans votre `.bashrc` ou `.zshrc` :
> 
> ```bash
> alias dexec='docker exec -it'
> alias droot='docker exec -it -u root'
> 
> # Utilisation :
> dexec mon_conteneur bash
> droot mon_conteneur apt-get update
> ```

---

## 🔗 docker attach

### Concept et utilité {#concept-et-utilité-attach}

`docker attach` vous connecte au **processus principal** (PID 1) d'un conteneur en cours d'exécution. Contrairement à `exec` qui crée un nouveau processus, `attach` se connecte au flux STDIN/STDOUT/STDERR du processus existant.

> [!info] Différence fondamentale avec exec
> 
> - **exec** : Crée un **nouveau processus** dans le conteneur
> - **attach** : Se connecte au **processus principal existant** (celui lancé au démarrage)

> [!tip] Quand utiliser `docker attach` ?
> 
> - Voir les logs en temps réel du processus principal
> - Interagir avec une application interactive (si elle lit STDIN)
> - Débugger le comportement du processus principal
> - Envoyer des signaux au processus principal

### Syntaxe et options {#syntaxe-et-options-attach}

```bash
docker attach [OPTIONS] CONTAINER
```

#### Options principales

|Option|Description|Exemple|
|---|---|---|
|`--detach-keys`|Séquence de touches pour se détacher|`docker attach --detach-keys="ctrl-q" mon_conteneur`|
|`--no-stdin`|Ne pas attacher STDIN|`docker attach --no-stdin mon_conteneur`|
|`--sig-proxy`|Proxy des signaux (true par défaut)|`docker attach --sig-proxy=false mon_conteneur`|

### Différences avec exec {#différences-avec-exec}

|Aspect|`docker exec`|`docker attach`|
|---|---|---|
|**Processus**|Crée un nouveau processus|Se connecte au processus principal|
|**Indépendance**|Indépendant du processus principal|Lié au processus principal|
|**Arrêt conteneur**|Sortir n'arrête pas le conteneur|Sortir peut arrêter le conteneur|
|**Cas d'usage**|Shell interactif, commandes ponctuelles|Voir les logs, interagir avec l'app principale|
|**Flexibilité**|Peut exécuter n'importe quelle commande|Limité au processus principal|

> [!example] Comparaison pratique
> 
> ```bash
> # Scénario 1 : Conteneur nginx
> docker run -d --name web nginx
> 
> # exec : Ouvre un shell SÉPARÉ, nginx continue de tourner
> docker exec -it web bash
> exit  # Nginx continue de tourner
> 
> # attach : Se connecte aux logs nginx
> docker attach web
> # Vous voyez les logs d'accès en temps réel
> # CTRL+C arrêtera nginx et donc le conteneur !
> ```

### Cas d'usage courants {#cas-dusage-courants-attach}

#### 1. Voir les logs en temps réel

```bash
# Se connecter pour voir les logs du processus principal
docker attach mon_conteneur

# Exemple avec une application Python
docker run -d --name app python app.py
docker attach app
# Vous verrez tous les print() en temps réel
```

#### 2. Interagir avec une application interactive

```bash
# Conteneur avec une application Python interactive
docker run -it --name python_app python

# Détacher avec CTRL+P puis CTRL+Q (sans arrêter)
# Puis réattacher plus tard
docker attach python_app
```

#### 3. Se détacher proprement sans arrêter le conteneur

```bash
# Lancer un conteneur en mode interactif
docker run -it --name ubuntu_test ubuntu bash

# Pour se détacher SANS arrêter le conteneur :
# Appuyez sur CTRL+P puis CTRL+Q
# (c'est la séquence par défaut pour se détacher)

# Vérifier que le conteneur tourne toujours
docker ps | grep ubuntu_test

# Réattacher plus tard
docker attach ubuntu_test
```

> [!warning] Attention au CTRL+C
> 
> ```bash
> docker attach mon_conteneur
> 
> # ❌ Si vous faites CTRL+C, vous envoyez SIGINT au processus principal
> # Cela arrêtera le processus et donc le conteneur !
> 
> # ✅ Pour se détacher sans arrêter : CTRL+P puis CTRL+Q
> ```

#### 4. Personnaliser la séquence de détachement

```bash
# Utiliser une séquence différente pour se détacher
docker attach --detach-keys="ctrl-q,ctrl-q" mon_conteneur

# Maintenant CTRL+Q puis CTRL+Q vous détache
```

### Pièges et bonnes pratiques {#pièges-et-bonnes-pratiques-attach}

> [!warning] Pièges courants
> 
> **1. Arrêter accidentellement le conteneur**
> 
> ```bash
> # ❌ CTRL+C envoie SIGINT au processus principal
> docker attach mon_conteneur
> # CTRL+C → Le conteneur s'arrête !
> 
> # ✅ Utiliser la séquence de détachement
> docker attach mon_conteneur
> # CTRL+P puis CTRL+Q → Se détache sans arrêter
> ```
> 
> **2. Attach sur un conteneur en arrière-plan sans TTY**
> 
> ```bash
> # ❌ Lancé sans -it, attach ne sera pas interactif
> docker run -d --name web nginx
> docker attach web
> # Vous verrez les logs mais ne pourrez pas interagir
> 
> # ✅ Pour un conteneur interactif, lancer avec -it
> docker run -it --name ubuntu_test ubuntu bash
> # CTRL+P puis CTRL+Q pour détacher
> docker attach ubuntu_test  # Réattacher fonctionne bien
> ```
> 
> **3. Plusieurs utilisateurs s'attachent au même conteneur**
> 
> ```bash
> # Si plusieurs personnes font attach au même conteneur,
> # elles voient toutes le même flux et leurs entrées sont mélangées !
> # Utiliser exec pour des sessions indépendantes
> ```

> [!tip] Bonnes pratiques
> 
> **1. Préférer `exec` pour l'administration quotidienne**
> 
> ```bash
> # ✅ Pour un shell interactif, exec est plus sûr
> docker exec -it mon_conteneur bash
> 
> # ✅ Réserver attach pour voir les logs en temps réel
> docker attach mon_conteneur
> ```
> 
> **2. Mémoriser la séquence de détachement**
> 
> ```bash
> # CTRL+P puis CTRL+Q : séquence par défaut
> # Pratiquez-la pour ne pas arrêter vos conteneurs par erreur
> ```
> 
> **3. Utiliser --sig-proxy=false pour éviter d'envoyer des signaux**
> 
> ```bash
> # Ne pas envoyer les signaux au processus principal
> docker attach --sig-proxy=false mon_conteneur
> # CTRL+C ne sera pas transmis au conteneur
> ```
> 
> **4. Vérifier le point d'entrée du conteneur**
> 
> ```bash
> # Savoir quel est le processus principal avant d'attacher
> docker inspect mon_conteneur | grep -A 5 "Cmd"
> ```

> [!info] Astuce : Quand utiliser quoi ?
> 
> - **Logs en temps réel** → `docker attach` ou `docker logs -f`
> - **Shell interactif** → `docker exec -it conteneur bash`
> - **Commande ponctuelle** → `docker exec conteneur commande`
> - **Interagir avec l'app principale** → `docker attach` (rare)

---

## 📁 docker cp

### Concept et utilité {#concept-et-utilité-cp}

`docker cp` permet de **copier des fichiers et des répertoires** entre le système de fichiers de l'hôte et celui d'un conteneur (dans les deux sens). C'est l'équivalent de la commande `cp` Linux mais entre deux espaces de fichiers différents.

> [!info] Pourquoi c'est utile ? `docker cp` fonctionne même si le conteneur est **arrêté**, contrairement à `exec`. C'est idéal pour :
> 
> - Récupérer des logs ou des fichiers de configuration
> - Injecter des fichiers de test ou des correctifs temporaires
> - Extraire des données générées par le conteneur
> - Débugger sans redémarrer le conteneur

> [!tip] Quand utiliser `docker cp` ?
> 
> - Récupérer des logs depuis un conteneur crashé
> - Copier une configuration modifiée pour analyse
> - Injecter un fichier de test rapidement
> - Extraire des données de sauvegarde
> - Récupérer des artefacts de build

### Syntaxe et options {#syntaxe-et-options-cp}

```bash
# Copier de l'hôte vers le conteneur
docker cp [OPTIONS] SRC_PATH CONTAINER:DEST_PATH

# Copier du conteneur vers l'hôte
docker cp [OPTIONS] CONTAINER:SRC_PATH DEST_PATH
```

#### Options principales

|Option|Description|Exemple|
|---|---|---|
|`-a, --archive`|Mode archive (préserve permissions, propriétaires)|`docker cp -a ./config mon_conteneur:/app/`|
|`-L, --follow-link`|Suit les liens symboliques|`docker cp -L mon_conteneur:/app/link ./`|

> [!info] Notation du chemin
> 
> - `CONTAINER:PATH` : Fichier/dossier dans le conteneur
> - `PATH` : Fichier/dossier sur l'hôte
> - Le conteneur peut être spécifié par son nom ou son ID

### Cas d'usage courants {#cas-dusage-courants-cp}

#### 1. Copier un fichier de l'hôte vers le conteneur

```bash
# Copier un fichier de configuration
docker cp ./config.json mon_conteneur:/app/config.json

# Copier un script
docker cp ./script.sh mon_conteneur:/usr/local/bin/script.sh

# Copier avec préservation des permissions
docker cp -a ./important.conf mon_conteneur:/etc/app/
```

> [!example] Exemple pratique
> 
> ```bash
> # Scénario : Corriger une typo dans un fichier de config sans rebuild
> 
> # 1. Récupérer le fichier du conteneur
> docker cp web_app:/etc/nginx/nginx.conf ./nginx.conf
> 
> # 2. Éditer localement
> vim nginx.conf  # Corriger la typo
> 
> # 3. Renvoyer le fichier corrigé
> docker cp ./nginx.conf web_app:/etc/nginx/nginx.conf
> 
> # 4. Recharger nginx
> docker exec web_app nginx -s reload
> ```

#### 2. Copier un fichier du conteneur vers l'hôte

```bash
# Récupérer des logs
docker cp mon_conteneur:/var/log/app.log ./app.log

# Récupérer une base de données
docker cp db_container:/var/lib/mysql/mydb.sql ./backup.sql

# Récupérer tout un répertoire
docker cp mon_conteneur:/app/data ./data_backup
```

#### 3. Copier des répertoires entiers

```bash
# Copier un dossier de l'hôte vers le conteneur
docker cp ./static_files/ mon_conteneur:/usr/share/nginx/html/

# Copier un dossier du conteneur vers l'hôte
docker cp mon_conteneur:/var/www/uploads ./uploads_backup/

# Attention au slash final !
# ./dir/  → copie le CONTENU de dir
# ./dir   → copie le DOSSIER dir lui-même
```

> [!warning] Comportement du slash final
> 
> ```bash
> # Avec slash final : copie le CONTENU
> docker cp ./mydir/ conteneur:/app/
> # Résultat : /app/file1, /app/file2, etc.
> 
> # Sans slash final : copie le DOSSIER
> docker cp ./mydir conteneur:/app/
> # Résultat : /app/mydir/file1, /app/mydir/file2, etc.
> ```

#### 4. Récupérer des données depuis un conteneur arrêté

```bash
# Même si le conteneur est arrêté, vous pouvez récupérer des fichiers
docker stop mon_conteneur

# Récupérer les logs avant de supprimer
docker cp mon_conteneur:/var/log/app.log ./derniers_logs.log

# Récupérer une configuration
docker cp mon_conteneur:/etc/config/settings.yml ./settings_backup.yml
```

#### 5. Copier depuis/vers un conteneur spécifique dans un compose

```bash
# Utiliser le nom complet du conteneur
docker cp ./data.csv projet_db_1:/tmp/import.csv

# Ou trouver le nom exact
docker ps --format "{{.Names}}" | grep db
docker cp ./data.csv nom_exact_trouvé:/tmp/import.csv
```

#### 6. Sauvegarder des artefacts de build

```bash
# Récupérer un binaire compilé dans un conteneur de build
docker cp build_container:/app/target/release/mybinary ./mybinary

# Récupérer des assets générés
docker cp node_build:/app/dist ./dist_output
```

### Pièges et bonnes pratiques {#pièges-et-bonnes-pratiques-cp}

> [!warning] Pièges courants
> 
> **1. Confusion avec le slash final**
> 
> ```bash
> # ❌ Comportement inattendu
> docker cp ./config mon_conteneur:/app/
> # Résultat : /app/config/fichiers...
> 
> # ✅ Copier le contenu uniquement
> docker cp ./config/ mon_conteneur:/app/
> # Résultat : /app/fichiers...
> ```
> 
> **2. Problèmes de permissions**
> 
> ```bash
> # ❌ Le fichier copié appartient à root dans le conteneur
> docker cp ./script.sh mon_conteneur:/app/script.sh
> 
> # ✅ Changer le propriétaire après la copie
> docker cp ./script.sh mon_conteneur:/app/script.sh
> docker exec -u root mon_conteneur chown appuser:appuser /app/script.sh
> ```
> 
> **3. Oublier que les modifications sont temporaires**
> 
> ```bash
> # ❌ Copier un fichier dans un conteneur ne modifie pas l'image
> docker cp ./fix.conf mon_conteneur:/etc/app/fix.conf
> # Si vous supprimez et recréez le conteneur, la modification est PERDUE
> 
> # ✅ Pour des modifications permanentes, modifier le Dockerfile
> ```
> 
> **4. Chemin du conteneur inexistant**
> 
> ```bash
> # ❌ Le chemin parent doit exister
> docker cp ./file.txt mon_conteneur:/non/existent/path/file.txt
> # Erreur : le répertoire /non/existent/path n'existe pas
> 
> # ✅ Créer le répertoire d'abord
> docker exec mon_conteneur mkdir -p /non/existent/path
> docker cp ./file.txt mon_conteneur:/non/existent/path/file.txt
> ```

> [!tip] Bonnes pratiques
> 
> **1. Toujours vérifier le chemin de destination**
> 
> ```bash
> # Vérifier que le répertoire existe
> docker exec mon_conteneur ls -la /app/
> 
> # Puis copier
> docker cp ./file.txt mon_conteneur:/app/
> ```
> 
> **2. Utiliser -a pour préserver les métadonnées**
> 
> ```bash
> # Préserver permissions, timestamps, etc.
> docker cp -a ./important_dir mon_conteneur:/data/
> ```
> 
> **3. Sauvegarder avant de modifier**
> 
> ```bash
> # Récupérer l'original avant de modifier
> docker cp mon_conteneur:/etc/config/app.conf ./app.conf.backup
> 
> # Modifier et renvoyer
> vim app.conf
> docker cp ./app.conf mon_conteneur:/etc/config/app.conf
> ```
> 
> **4. Combiner avec tar pour de gros volumes**
> 
> ```bash
> # Pour de très gros répertoires, utiliser tar
> docker exec mon_conteneur tar czf /tmp/backup.tar.gz /var/data
> docker cp mon_conteneur:/tmp/backup.tar.gz ./backup.tar.gz
> ```
> 
> **5. Scripts pour automatiser les sauvegardes**
> 
> ```bash
> #!/bin/bash
> # Script de backup automatique
> DATE=$(date +%Y%m%d_%H%M%S)
> docker cp mon_conteneur:/var/log/app.log ./backups/app_${DATE}.log
> echo "Backup créé : app_${DATE}.log"
> ```

> [!info] Astuce : Alternative avec volumes Pour des échanges fréquents de fichiers, préférez utiliser des volumes Docker plutôt que `docker cp` :
> 
> ```bash
> # ✅ Meilleure solution pour du développement
> docker run -v $(pwd)/local_dir:/app/data mon_image
> # Les fichiers sont automatiquement synchronisés
> 
> # ⚠️ docker cp est mieux pour des opérations ponctuelles
> docker cp ./oneshot.sql conteneur:/tmp/import.sql
> ```

---

## 📊 Comparaison des commandes

|Critère|`docker exec`|`docker attach`|`docker cp`|
|---|---|---|---|
|**Conteneur arrêté**|❌ Non|❌ Non|✅ Oui|
|**Crée un nouveau processus**|✅ Oui|❌ Non|N/A|
|**Peut arrêter le conteneur**|❌ Non|⚠️ Oui (CTRL+C)|❌ Non|
|**Interactivité**|✅ Excellente|⚠️ Limitée|❌ Aucune|
|**Transfert de fichiers**|❌ Non|❌ Non|✅ Oui|
|**Cas d'usage principal**|Shell, commandes|Logs temps réel|Copie de fichiers|
|**Indépendance**|✅ Totale|❌ Liée au PID 1|✅ Totale|
|**Sécurité**|✅ Plus sûr|⚠️ Risqué|✅ Sûr|

> [!tip] Décision rapide : quelle commande utiliser ?
> 
> **Je veux...**
> 
> - 🔧 **Ouvrir un shell** → `docker exec -it conteneur bash`
> - 📝 **Voir les logs en direct** → `docker attach conteneur` ou `docker logs -f conteneur`
> - 🚀 **Exécuter une commande** → `docker exec conteneur commande`
> - 📁 **Copier un fichier** → `docker cp source destination`
> - 🔍 **Débugger un crash** → `docker cp` (fonctionne même si arrêté)
> - 🛠️ **Installer des outils temporaires** → `docker exec -u root conteneur apt install ...`
> - 💾 **Récupérer des données** → `docker cp conteneur:/data ./backup`

> [!example] Workflow de debugging typique
> 
> ```bash
> # 1. Vérifier que le conteneur tourne
> docker ps | grep mon_app
> 
> # 2. Ouvrir un shell pour explorer
> docker exec -it mon_app bash
> 
> # 3. Installer des outils de debugging si nécessaire
> apt-get update && apt-get install -y curl vim
> 
> # 4. Explorer et identifier le problème
> cd /var/log
> cat app.log
> exit
> 
> # 5. Récupérer les logs pour analyse
> docker cp mon_app:/var/log/app.log ./debug.log
> 
> # 6. Si besoin, modifier un fichier de config
> vim config.json
> docker cp ./config.json mon_app:/etc/app/config.json
> 
> # 7. Redémarrer le service dans le conteneur
> docker exec mon_app systemctl restart app
> ```

---

## 🎯 Résumé

Les trois commandes d'interaction avec les conteneurs Docker (`exec`, `attach`, `cp`) sont des outils essentiels qui répondent à des besoins différents. Maîtriser leurs spécificités vous permettra de gérer efficacement vos conteneurs en toutes circonstances.

### Points clés à retenir

> [!success] docker exec
> 
> - **Outil principal** pour l'administration quotidienne
> - Crée un **nouveau processus** indépendant
> - **Sûr** : quitter n'arrête pas le conteneur
> - Idéal pour : shells interactifs, commandes ponctuelles, debugging
> - Syntaxe courante : `docker exec -it conteneur bash`

> [!info] docker attach
> 
> - Se connecte au **processus principal** (PID 1)
> - **Risqué** : CTRL+C peut arrêter le conteneur
> - Détachement : **CTRL+P puis CTRL+Q**
> - Idéal pour : voir les logs en temps réel, interagir avec l'app principale
> - Utilisation limitée dans la pratique (préférer `exec` ou `logs -f`)

> [!note] docker cp
> 
> - Copie de fichiers entre **hôte ↔ conteneur**
> - Fonctionne même si le conteneur est **arrêté**
> - Attention au **slash final** dans les chemins
> - Idéal pour : récupérer logs/données, injecter fichiers de test, backup
> - Modifications temporaires (perdues si conteneur supprimé)

### Schéma de décision

```
Besoin d'interagir avec un conteneur ?
│
├─ Conteneur arrêté ?
│  └─ OUI → docker cp uniquement
│
├─ Besoin de copier des fichiers ?
│  └─ OUI → docker cp
│
├─ Besoin d'un shell interactif ?
│  └─ OUI → docker exec -it conteneur bash
│
├─ Besoin de voir les logs en direct ?
│  ├─ docker logs -f conteneur (recommandé)
│  └─ docker attach conteneur (alternative)
│
└─ Besoin d'exécuter une commande ?
   └─ docker exec conteneur commande
```

> [!warning] Rappels de sécurité
> 
> - Les modifications avec `exec` et `cp` sont **temporaires** (perdues si conteneur recréé)
> - Pour des changements permanents, modifiez le **Dockerfile** et **reconstruisez l'image**
> - Évitez d'installer trop de packages avec `exec`, cela alourdit le conteneur
> - `docker attach` peut arrêter le conteneur par erreur (préférer `exec`)
> - Soyez vigilant avec les permissions lors de l'utilisation de `cp`

### Commandes essentielles à mémoriser

```bash
# Shell interactif (le plus utilisé)
docker exec -it <conteneur> bash

# Exécuter une commande
docker exec <conteneur> <commande>

# Exécuter en tant que root
docker exec -u root -it <conteneur> bash

# Voir les logs en temps réel
docker logs -f <conteneur>
# ou
docker attach <conteneur>  # CTRL+P puis CTRL+Q pour détacher

# Copier de l'hôte vers le conteneur
docker cp <fichier_local> <conteneur>:<chemin_conteneur>

# Copier du conteneur vers l'hôte
docker cp <conteneur>:<fichier_conteneur> <chemin_local>

# Copier un répertoire (attention au slash)
docker cp <dossier>/ <conteneur>:<destination>/
```

---

**Fin du cours - Interaction avec les conteneurs** 🎓