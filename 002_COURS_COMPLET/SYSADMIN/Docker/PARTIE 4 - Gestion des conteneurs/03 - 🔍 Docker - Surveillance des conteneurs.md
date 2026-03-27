

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

La surveillance des conteneurs Docker est essentielle pour :

- **Diagnostiquer les problèmes** en temps réel
- **Optimiser les performances** et l'utilisation des ressources
- **Comprendre le comportement** des applications conteneurisées
- **Déboguer** les erreurs et incidents

Cette section couvre les 5 commandes fondamentales de monitoring que tout utilisateur Docker doit maîtriser.

---

## 1. Lister les conteneurs (docker ps)

### 🎯 Objectif

La commande `docker ps` (ou `docker container ls`) permet de visualiser l'état des conteneurs sur votre système. C'est généralement la première commande à utiliser pour avoir une vue d'ensemble.

### 📖 Syntaxe de base

```bash
# Lister uniquement les conteneurs en cours d'exécution
docker ps

# Syntaxe alternative (identique)
docker container ls
```

### 🔧 Options principales

```bash
# Afficher TOUS les conteneurs (actifs + arrêtés)
docker ps -a
docker ps --all

# Afficher uniquement les IDs des conteneurs
docker ps -q
docker ps --quiet

# Afficher les N derniers conteneurs créés
docker ps -n 5
docker ps --last 5

# Filtrer les conteneurs
docker ps --filter "status=exited"
docker ps --filter "name=nginx"
docker ps --filter "ancestor=ubuntu:22.04"

# Format personnalisé
docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}"
docker ps --format "{{.Names}}: {{.Status}}"

# Afficher la taille des conteneurs
docker ps -s
docker ps --size
```

> [!info] Information `docker ps` est l'abréviation de "docker process status". Par défaut, seuls les conteneurs actifs sont affichés.

### 📊 Colonnes affichées

|Colonne|Description|
|---|---|
|**CONTAINER ID**|Identifiant unique court (12 caractères)|
|**IMAGE**|Image source utilisée pour créer le conteneur|
|**COMMAND**|Commande exécutée au démarrage|
|**CREATED**|Date de création du conteneur|
|**STATUS**|État actuel (Up, Exited, Restarting...)|
|**PORTS**|Mappings de ports réseau|
|**NAMES**|Nom attribué au conteneur|

### 💡 Cas d'usage pratiques

```bash
# Récupérer uniquement les IDs pour les passer à une autre commande
docker stop $(docker ps -q)

# Lister tous les conteneurs arrêtés
docker ps -a --filter "status=exited"

# Afficher les conteneurs avec un format lisible
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Compter le nombre de conteneurs actifs
docker ps -q | wc -l
```

> [!tip] Astuce Créez un alias dans votre `.bashrc` ou `.zshrc` :
> 
> ```bash
> alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
> ```

> [!warning] Attention La commande `docker ps -a` peut afficher beaucoup de conteneurs arrêtés qui consomment de l'espace disque. Pensez à nettoyer régulièrement avec `docker container prune`.

---

## 2. Consulter les logs (docker logs)

### 🎯 Objectif

`docker logs` permet de consulter les sorties standard (stdout) et d'erreur (stderr) d'un conteneur. C'est l'outil principal pour déboguer et comprendre ce qui se passe à l'intérieur d'un conteneur.

### 📖 Syntaxe de base

```bash
# Afficher tous les logs d'un conteneur
docker logs <conteneur_id_ou_nom>

# Exemple
docker logs mon-nginx
docker logs abc123def456
```

### 🔧 Options principales

```bash
# Suivre les logs en temps réel (comme tail -f)
docker logs -f <conteneur>
docker logs --follow <conteneur>

# Afficher les N dernières lignes
docker logs --tail 50 <conteneur>

# Afficher les logs depuis un moment donné
docker logs --since 10m <conteneur>      # Depuis 10 minutes
docker logs --since 2024-01-01 <conteneur>
docker logs --since 1h30m <conteneur>

# Afficher jusqu'à un moment donné
docker logs --until 2024-12-25T10:00:00 <conteneur>

# Ajouter les timestamps
docker logs -t <conteneur>
docker logs --timestamps <conteneur>

# Combiner plusieurs options
docker logs -f --tail 100 --since 5m mon-app
```

> [!info] Formats de temps acceptés
> 
> - **Durée relative** : `10m`, `2h`, `1h30m`, `24h`
> - **Date RFC3339** : `2024-12-25T10:30:00Z`
> - **Date Unix** : `1640434800`

### 💡 Cas d'usage pratiques

```bash
# Déboguer une application qui crash au démarrage
docker logs --tail 50 mon-app

# Surveiller en temps réel avec timestamps
docker logs -f -t mon-service

# Chercher une erreur spécifique
docker logs mon-app 2>&1 | grep -i "error"

# Exporter les logs dans un fichier
docker logs mon-app > application.log 2>&1

# Afficher uniquement les dernières erreurs
docker logs --tail 100 mon-app 2>&1 | grep -i "error\|exception\|fatal"

# Surveiller les 5 dernières minutes
docker logs --since 5m -f mon-app
```

> [!example] Exemple pratique
> 
> ```bash
> # Démarrer un conteneur nginx
> docker run -d --name web-server nginx
> 
> # Consulter les logs d'accès
> docker logs web-server
> 
> # Suivre les logs en temps réel
> docker logs -f --tail 20 web-server
> ```

> [!warning] Limitations importantes
> 
> - `docker logs` ne fonctionne qu'avec les drivers de log qui supportent la lecture (json-file, journald)
> - Si vous utilisez un driver comme `syslog` ou `gelf`, les logs ne seront pas accessibles via cette commande
> - Les logs sont stockés sur le disque et peuvent occuper beaucoup d'espace si non rotés

> [!tip] Bonne pratique Pour les applications en production, configurez la rotation des logs :
> 
> ```bash
> docker run -d \
>   --log-opt max-size=10m \
>   --log-opt max-file=3 \
>   nginx
> ```

### 🔍 Différence stdout vs stderr

```bash
# Afficher uniquement stdout
docker logs mon-app 2>/dev/null

# Afficher uniquement stderr
docker logs mon-app 2>&1 >/dev/null

# Séparer stdout et stderr dans des fichiers
docker logs mon-app > stdout.log 2> stderr.log
```

---

## 3. Statistiques en temps réel (docker stats)

### 🎯 Objectif

`docker stats` affiche en temps réel les métriques de consommation des ressources système par les conteneurs (CPU, mémoire, réseau, I/O disque). C'est l'équivalent de `top` ou `htop` pour Docker.

### 📖 Syntaxe de base

```bash
# Afficher les stats de tous les conteneurs actifs
docker stats

# Afficher les stats de conteneurs spécifiques
docker stats <conteneur1> <conteneur2>

# Exemple
docker stats mon-nginx mon-postgres
```

### 🔧 Options principales

```bash
# Afficher tous les conteneurs (même ceux arrêtés)
docker stats -a
docker stats --all

# Afficher une seule fois (sans rafraîchissement)
docker stats --no-stream

# Format personnalisé
docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}"

# Afficher uniquement certains conteneurs avec filtre
docker stats $(docker ps --format '{{.Names}}' | grep "web")
```

> [!info] Rafraîchissement Par défaut, `docker stats` se rafraîchit automatiquement toutes les secondes. Utilisez `Ctrl+C` pour quitter.

### 📊 Métriques affichées

|Colonne|Description|Exemple|
|---|---|---|
|**CONTAINER ID**|Identifiant court du conteneur|`abc123def456`|
|**NAME**|Nom du conteneur|`mon-nginx`|
|**CPU %**|Pourcentage d'utilisation CPU|`12.50%`|
|**MEM USAGE / LIMIT**|Mémoire utilisée / limite maximale|`256MiB / 2GiB`|
|**MEM %**|Pourcentage de mémoire utilisée|`12.50%`|
|**NET I/O**|Données envoyées / reçues sur le réseau|`1.2MB / 4.5MB`|
|**BLOCK I/O**|Données lues / écrites sur disque|`100MB / 50MB`|
|**PIDS**|Nombre de processus dans le conteneur|`15`|

### 💡 Cas d'usage pratiques

```bash
# Surveiller un conteneur suspect qui consomme beaucoup
docker stats mon-app --no-stream

# Créer un format minimal pour monitoring
docker stats --format "{{.Name}}: CPU={{.CPUPerc}} MEM={{.MemPerc}}"

# Afficher uniquement les 3 conteneurs les plus gourmands (avec un script)
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}" | sort -k2 -rn | head -4

# Monitorer en continu et loguer dans un fichier
docker stats --format "{{.Name}},{{.CPUPerc}},{{.MemPerc}}" >> stats.csv

# Surveiller tous les conteneurs dont le nom commence par "web"
docker stats $(docker ps --format '{{.Names}}' | grep "^web")
```

> [!example] Exemple d'utilisation
> 
> ```bash
> # Démarrer quelques conteneurs
> docker run -d --name db postgres
> docker run -d --name cache redis
> docker run -d --name web nginx
> 
> # Surveiller leurs ressources
> docker stats db cache web
> 
> # Sortie exemple :
> # CONTAINER ID   NAME    CPU %   MEM USAGE / LIMIT   MEM %   NET I/O       BLOCK I/O
> # abc123...      db      2.50%   150MiB / 2GiB      7.32%   5MB / 10MB    100MB / 50MB
> # def456...      cache   0.50%   20MiB / 512MiB     3.91%   1MB / 2MB     10MB / 5MB
> # ghi789...      web     0.10%   5MiB / 1GiB        0.49%   500KB / 1MB   5MB / 1MB
> ```

> [!tip] Astuce de diagnostic Si un conteneur consomme 100% du CPU de manière inattendue :
> 
> 1. Utilisez `docker stats` pour identifier le coupable
> 2. Utilisez `docker top <conteneur>` pour voir les processus
> 3. Consultez `docker logs <conteneur>` pour comprendre pourquoi

> [!warning] Performance `docker stats` peut lui-même consommer des ressources si vous surveillez beaucoup de conteneurs. Pour des environnements de production avec de nombreux conteneurs, préférez des solutions de monitoring dédiées (Prometheus, Grafana, cAdvisor).

### 🎨 Formats personnalisés utiles

```bash
# Format minimal (nom et CPU)
docker stats --format "{{.Name}}: {{.CPUPerc}}"

# Format CSV pour export
docker stats --no-stream --format "{{.Name}},{{.CPUPerc}},{{.MemPerc}},{{.NetIO}}"

# Format tableau personnalisé
docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
```

---

## 4. Processus actifs (docker top)

### 🎯 Objectif

`docker top` affiche les processus en cours d'exécution à l'intérieur d'un conteneur. C'est l'équivalent de la commande `top` ou `ps` Linux, mais pour un conteneur spécifique.

### 📖 Syntaxe de base

```bash
# Afficher les processus d'un conteneur
docker top <conteneur_id_ou_nom>

# Exemple
docker top mon-nginx
```

### 🔧 Options et formats

```bash
# Utiliser un format ps personnalisé
docker top <conteneur> aux
docker top <conteneur> -ef
docker top <conteneur> -eo pid,user,comm,args

# Exemples pratiques
docker top mon-app aux
docker top mon-app -eo pid,comm,%cpu,%mem
```

> [!info] Format de sortie Par défaut, `docker top` utilise le format `ps -ef` et affiche : UID, PID, PPID, C, STIME, TTY, TIME, CMD

### 📊 Colonnes typiques

|Colonne|Description|
|---|---|
|**UID**|User ID (identifiant utilisateur)|
|**PID**|Process ID (vu depuis l'hôte)|
|**PPID**|Parent Process ID|
|**C**|Utilisation CPU|
|**STIME**|Heure de démarrage du processus|
|**TTY**|Terminal associé|
|**TIME**|Temps CPU cumulé|
|**CMD**|Commande exécutée|

### 💡 Cas d'usage pratiques

```bash
# Voir tous les processus avec détails
docker top mon-conteneur aux

# Identifier le processus principal (PID 1)
docker top mon-app | head -2

# Voir l'utilisation CPU et mémoire
docker top mon-app -eo pid,user,comm,%cpu,%mem

# Compter le nombre de processus
docker top mon-app | wc -l

# Identifier les processus zombies
docker top mon-app aux | grep defunct
```

> [!example] Exemple pratique
> 
> ```bash
> # Démarrer un conteneur nginx
> docker run -d --name web nginx
> 
> # Voir les processus
> docker top web
> 
> # Sortie exemple :
> # UID     PID    PPID   C   STIME   TTY   TIME       CMD
> # root    1234   1220   0   10:30   ?     00:00:00   nginx: master process
> # nginx   1235   1234   0   10:30   ?     00:00:00   nginx: worker process
> 
> # Format détaillé
> docker top web aux
> 
> # USER   PID   %CPU  %MEM  VSZ    RSS   TTY   STAT  START  TIME  COMMAND
> # root   1234  0.0   0.1   10940  3456  ?     Ss    10:30  0:00  nginx: master
> # nginx  1235  0.0   0.2   11200  4567  ?     S     10:30  0:00  nginx: worker
> ```

> [!tip] Astuce pour déboguer Comparez les processus avant et après une opération :
> 
> ```bash
> # Avant
> docker top mon-app > before.txt
> 
> # Effectuer une action (requête, déploiement, etc.)
> 
> # Après
> docker top mon-app > after.txt
> 
> # Comparer
> diff before.txt after.txt
> ```

> [!warning] PID sur l'hôte vs PID dans le conteneur Les PID affichés par `docker top` sont ceux visibles depuis l'**hôte**, pas depuis l'intérieur du conteneur. À l'intérieur du conteneur, le processus principal a toujours le PID 1.

### 🔍 Différence avec docker exec

```bash
# docker top : vue depuis l'hôte
docker top mon-app

# docker exec + ps : vue depuis l'intérieur du conteneur
docker exec mon-app ps aux
```

La différence principale :

- `docker top` : processus vus avec leur PID **hôte** (utile pour kill depuis l'hôte)
- `docker exec ps` : processus vus avec leur PID **conteneur** (toujours 1 pour le processus principal)

### 💡 Combiner avec d'autres commandes

```bash
# Identifier le conteneur le plus gourmand en processus
for container in $(docker ps --format '{{.Names}}'); do
  echo "$container: $(docker top $container | wc -l) processus"
done

# Surveiller un processus spécifique
watch -n 1 "docker top mon-app aux | grep 'python'"
```

---

## 5. Inspection détaillée (docker inspect)

### 🎯 Objectif

`docker inspect` retourne une description JSON complète et exhaustive d'un conteneur (ou d'une image, volume, réseau). C'est la commande la plus détaillée pour obtenir toutes les métadonnées et configurations.

### 📖 Syntaxe de base

```bash
# Inspecter un conteneur
docker inspect <conteneur_id_ou_nom>

# Inspecter plusieurs conteneurs
docker inspect <conteneur1> <conteneur2>

# Exemple
docker inspect mon-nginx
```

### 🔧 Options principales

```bash
# Formater la sortie avec un template Go
docker inspect --format '{{.State.Status}}' <conteneur>
docker inspect -f '{{.NetworkSettings.IPAddress}}' <conteneur>

# Afficher la taille
docker inspect --size <conteneur>
docker inspect -s <conteneur>

# Type d'objet (auto-détecté par défaut)
docker inspect --type container <nom>
docker inspect --type image <nom>
```

> [!info] Format de sortie Par défaut, `docker inspect` retourne un tableau JSON contenant tous les détails de configuration, état, réseau, volumes, etc.

### 📊 Sections principales du JSON

|Section|Contenu|
|---|---|
|**Id**|Identifiant complet du conteneur (64 caractères)|
|**Created**|Date/heure de création|
|**Path**|Commande exécutée|
|**Args**|Arguments de la commande|
|**State**|État actuel (Running, Paused, Exited, etc.)|
|**Image**|ID de l'image source|
|**Config**|Configuration (env, cmd, labels, etc.)|
|**NetworkSettings**|Configuration réseau (IP, ports, etc.)|
|**Mounts**|Volumes et bind mounts|
|**HostConfig**|Configuration liée à l'hôte (limites CPU/RAM, restart policy, etc.)|

### 💡 Extraire des informations spécifiques

```bash
# Récupérer l'adresse IP
docker inspect -f '{{.NetworkSettings.IPAddress}}' mon-app

# Récupérer l'état du conteneur
docker inspect -f '{{.State.Status}}' mon-app

# Voir si le conteneur est en cours d'exécution
docker inspect -f '{{.State.Running}}' mon-app

# Récupérer le code de sortie
docker inspect -f '{{.State.ExitCode}}' mon-app

# Afficher les variables d'environnement
docker inspect -f '{{.Config.Env}}' mon-app

# Récupérer le hostname
docker inspect -f '{{.Config.Hostname}}' mon-app

# Voir les volumes montés
docker inspect -f '{{.Mounts}}' mon-app

# Récupérer les ports mappés
docker inspect -f '{{.NetworkSettings.Ports}}' mon-app

# Afficher la politique de redémarrage
docker inspect -f '{{.HostConfig.RestartPolicy.Name}}' mon-app

# Voir les limites de ressources
docker inspect -f 'CPU: {{.HostConfig.NanoCpus}} - RAM: {{.HostConfig.Memory}}' mon-app
```

### 🎨 Templates Go avancés

```bash
# Formater en plusieurs lignes
docker inspect -f '
Nom: {{.Name}}
IP: {{.NetworkSettings.IPAddress}}
Status: {{.State.Status}}
' mon-app

# Parcourir un tableau (variables d'environnement)
docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' mon-app

# Parcourir les ports mappés
docker inspect -f '{{range $p, $conf := .NetworkSettings.Ports}}{{$p}} -> {{(index $conf 0).HostPort}}{{println}}{{end}}' mon-app

# Conditions
docker inspect -f '{{if .State.Running}}ACTIF{{else}}ARRETE{{end}}' mon-app
```

> [!example] Exemple complet
> 
> ```bash
> # Créer et démarrer un conteneur avec configuration
> docker run -d \
>   --name web-app \
>   -p 8080:80 \
>   -e APP_ENV=production \
>   -v /data:/app/data \
>   nginx
> 
> # Inspecter toutes les infos
> docker inspect web-app
> 
> # Extraire des infos spécifiques
> docker inspect -f '{{.NetworkSettings.IPAddress}}' web-app
> # Sortie : 172.17.0.2
> 
> docker inspect -f '{{.State.Status}}' web-app
> # Sortie : running
> 
> docker inspect -f '{{range .Config.Env}}{{println .}}{{end}}' web-app
> # Sortie :
> # PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
> # APP_ENV=production
> # NGINX_VERSION=1.25.3
> ```

### 💡 Cas d'usage pratiques

```bash
# Récupérer l'IP de tous les conteneurs actifs
docker ps -q | xargs docker inspect -f '{{.Name}} - {{.NetworkSettings.IPAddress}}'

# Vérifier si un conteneur utilise un volume spécifique
docker inspect -f '{{range .Mounts}}{{.Source}}{{println}}{{end}}' mon-app | grep "/mon/chemin"

# Extraire la date de création au format lisible
docker inspect -f '{{.Created}}' mon-app

# Créer un script de backup basé sur l'inspection
docker inspect -f '{{range .Mounts}}{{.Source}}{{println}}{{end}}' mon-app | while read path; do
  echo "Sauvegarde de $path"
done

# Voir tous les labels d'un conteneur
docker inspect -f '{{json .Config.Labels}}' mon-app | jq

# Identifier les conteneurs sans politique de redémarrage
for c in $(docker ps -q); do
  policy=$(docker inspect -f '{{.HostConfig.RestartPolicy.Name}}' $c)
  if [ "$policy" == "no" ] || [ -z "$policy" ]; then
    echo "$(docker inspect -f '{{.Name}}' $c) : pas de restart policy"
  fi
done
```

> [!tip] Combiner avec jq pour du JSON propre
> 
> ```bash
> # Installer jq : apt install jq / brew install jq
> 
> # Extraire et formatter une section
> docker inspect mon-app | jq '.[0].NetworkSettings'
> 
> # Extraire plusieurs champs
> docker inspect mon-app | jq '.[0] | {name: .Name, ip: .NetworkSettings.IPAddress, status: .State.Status}'
> 
> # Sortie :
> # {
> #   "name": "/mon-app",
> #   "ip": "172.17.0.3",
> #   "status": "running"
> # }
> ```

> [!warning] Sensibilité des données `docker inspect` peut révéler des informations sensibles comme :
> 
> - Variables d'environnement (parfois avec des mots de passe)
> - Configuration réseau interne
> - Chemins de volumes
> 
> Attention lors du partage de cette sortie !

### 🔍 Différences clés

```bash
# docker ps : vue d'ensemble rapide
docker ps

# docker inspect : détails exhaustifs
docker inspect mon-app

# docker logs : sorties applicatives
docker logs mon-app

# docker stats : métriques temps réel
docker stats mon-app

# docker top : processus
docker top mon-app
```

### 🎯 Cheat sheet des templates utiles

```bash
# Nom complet
docker inspect -f '{{.Name}}' <conteneur>

# ID complet
docker inspect -f '{{.Id}}' <conteneur>

# Image utilisée
docker inspect -f '{{.Config.Image}}' <conteneur>

# Commande de démarrage
docker inspect -f '{{.Path}} {{.Args}}' <conteneur>

# IP et Gateway
docker inspect -f 'IP: {{.NetworkSettings.IPAddress}} - Gateway: {{.NetworkSettings.Gateway}}' <conteneur>

# RAM limitée
docker inspect -f '{{.HostConfig.Memory}}' <conteneur>

# Nombre de CPUs
docker inspect -f '{{.HostConfig.NanoCpus}}' <conteneur>

# Date de démarrage
docker inspect -f '{{.State.StartedAt}}' <conteneur>

# PID du processus principal sur l'hôte
docker inspect -f '{{.State.Pid}}' <conteneur>
```

---

## 📊 Tableau comparatif des commandes

|Commande|Usage principal|Quand l'utiliser|Sortie|
|---|---|---|---|
|`docker ps`|Liste des conteneurs|Avoir une vue d'ensemble rapide|Tableau texte|
|`docker logs`|Sorties applicatives|Déboguer, voir les erreurs|Logs texte|
|`docker stats`|Métriques système|Surveiller les performances|Tableau actualisé|
|`docker top`|Processus actifs|Identifier les processus|Liste processus|
|`docker inspect`|Configuration complète|Analyser en profondeur|JSON détaillé|

### 🎯 Workflow typique de diagnostic

```bash
# 1. Identifier le conteneur problématique
docker ps -a

# 2. Consulter les logs pour comprendre l'erreur
docker logs --tail 100 <conteneur>

# 3. Vérifier les ressources système
docker stats --no-stream <conteneur>

# 4. Analyser les processus en cours
docker top <conteneur>

# 5. Inspecter la configuration complète
docker inspect <conteneur> | jq '.[0].State'
```

> [!tip] Commande combinée de monitoring
> 
> ```bash
> # Script de monitoring complet
> #!/bin/bash
> CONTAINER=$1
> 
> echo "=== État du conteneur ==="
> docker ps -a --filter "name=$CONTAINER"
> 
> echo -e "\n=== Statistiques ==="
> docker stats --no-stream $CONTAINER
> 
> echo -e "\n=== Processus ==="
> docker top $CONTAINER
> 
> echo -e "\n=== Derniers logs ==="
> docker logs --tail 20 $CONTAINER
> 
> echo -e "\n=== IP et Ports ==="
> docker inspect -f 'IP: {{.NetworkSettings.IPAddress}}' $CONTAINER
> docker inspect -f 'Ports: {{.NetworkSettings.Ports}}' $CONTAINER
> ```

---

## 🎓 Bonnes pratiques de surveillance

> [!tip] Recommandations
> 
> 1. **Vérification régulière** : Utilisez `docker ps -a` régulièrement pour détecter les conteneurs crashés
> 2. **Logs centralisés** : Pour la production, configurez un système de logs centralisé (ELK, Loki, Splunk)
> 3. **Alertes sur ressources** : Surveillez `docker stats` et configurez des alertes si CPU/RAM > 80%
> 4. **Rotation des logs** : Activez toujours `--log-opt max-size` et `--log-opt max-file`
> 5. **Automatisation** : Créez des scripts qui combinent ces commandes pour du monitoring automatisé

> [!warning] Pièges à éviter
> 
> - Ne pas monitorer en production uniquement avec `docker logs -f` (utiliser un outil dédié)
> - Ne pas ignorer les conteneurs en état "Exited" qui peuvent indiquer des problèmes
> - Ne pas oublier que `docker stats` lui-même consomme des ressources
> - Ne pas exposer les sorties de `docker inspect` qui peuvent contenir des secrets

---

**📌 Points clés à retenir :**

- `docker ps` pour lister et filtrer les conteneurs
- `docker logs` pour consulter les sorties applicatives
- `docker stats` pour surveiller les ressources en temps réel
- `docker top` pour voir les processus actifs
- `docker inspect` pour une analyse détaillée en JSON

Ces 5 commandes forment la base de la surveillance Docker et doivent être maîtrisées pour gérer efficacement vos conteneurs.