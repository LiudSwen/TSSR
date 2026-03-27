

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

La gestion du cycle de vie des conteneurs Docker est essentielle pour contrôler l'exécution de vos applications. Un conteneur passe par différents états : créé, démarré, en pause, arrêté, et supprimé. Maîtriser les commandes de transition entre ces états vous permet d'optimiser les ressources système et de gérer efficacement vos environnements.

> [!info] États d'un conteneur Docker Un conteneur peut être dans l'un des états suivants :
> 
> - **created** : créé mais pas démarré
> - **running** : en cours d'exécution
> - **paused** : gelé temporairement
> - **stopped** : arrêté proprement
> - **exited** : terminé (avec code de sortie)
> - **dead** : arrêté de force

---

## docker start/stop/restart

### docker start

La commande `docker start` permet de démarrer un ou plusieurs conteneurs précédemment arrêtés.

#### Syntaxe

```bash
docker start [OPTIONS] CONTAINER [CONTAINER...]
```

#### Options principales

|Option|Description|
|---|---|
|`-a, --attach`|Attache STDOUT/STDERR et transmet les signaux|
|`-i, --interactive`|Attache STDIN du conteneur|
|`--detach-keys`|Définit la séquence de touches pour détacher|

#### Exemples d'utilisation

```bash
# Démarrer un conteneur arrêté
docker start mon_conteneur

# Démarrer plusieurs conteneurs
docker start web_app db_app cache_app

# Démarrer et attacher le terminal
docker start -a mon_conteneur

# Démarrer en mode interactif
docker start -ai mon_conteneur_bash
```

> [!tip] Astuce : Démarrage multiple Vous pouvez démarrer tous les conteneurs arrêtés d'un coup :
> 
> ```bash
> docker start $(docker ps -aq -f status=exited)
> ```

#### Quand utiliser docker start ?

- Redémarrer un conteneur temporairement arrêté
- Reprendre un environnement de développement
- Relancer des services après maintenance
- Remettre en service des conteneurs après un redémarrage système

---

### docker stop

La commande `docker stop` arrête un conteneur en cours d'exécution de manière propre, en envoyant d'abord un signal SIGTERM puis SIGKILL après un délai.

#### Syntaxe

```bash
docker stop [OPTIONS] CONTAINER [CONTAINER...]
```

#### Options principales

|Option|Description|
|---|---|
|`-t, --time int`|Délai en secondes avant SIGKILL (défaut: 10)|
|`-s, --signal string`|Signal à envoyer au conteneur|

#### Exemples d'utilisation

```bash
# Arrêter un conteneur (délai par défaut de 10s)
docker stop mon_conteneur

# Arrêter avec un délai personnalisé
docker stop -t 30 mon_conteneur

# Arrêter plusieurs conteneurs
docker stop web_app db_app

# Arrêter tous les conteneurs en cours d'exécution
docker stop $(docker ps -q)

# Arrêter avec un signal personnalisé
docker stop -s SIGTERM mon_conteneur
```

> [!warning] Délai d'arrêt Le délai par défaut de 10 secondes peut être insuffisant pour certaines applications (bases de données, traitements en cours). Augmentez-le avec `-t` pour permettre un arrêt propre.

#### Comment fonctionne docker stop ?

1. Docker envoie un signal **SIGTERM** au processus principal (PID 1)
2. Le conteneur a le temps de se terminer proprement (fermer connexions, sauvegarder état)
3. Si le délai expire, Docker envoie **SIGKILL** pour forcer l'arrêt

> [!example] Exemple de shutdown propre
> 
> ```bash
> # Application Node.js avec gestion gracieuse
> docker stop -t 60 nodejs_app
> # Laisse 60 secondes pour terminer les requêtes en cours
> ```

---

### docker restart

La commande `docker restart` combine stop et start en une seule opération : arrêt propre puis redémarrage du conteneur.

#### Syntaxe

```bash
docker restart [OPTIONS] CONTAINER [CONTAINER...]
```

#### Options principales

|Option|Description|
|---|---|
|`-t, --time int`|Délai en secondes avant SIGKILL (défaut: 10)|
|`-s, --signal string`|Signal à envoyer au conteneur|

#### Exemples d'utilisation

```bash
# Redémarrer un conteneur
docker restart mon_conteneur

# Redémarrer avec délai personnalisé
docker restart -t 20 database_app

# Redémarrer plusieurs conteneurs
docker restart web1 web2 web3

# Redémarrer tous les conteneurs
docker restart $(docker ps -q)
```

#### Quand utiliser docker restart ?

- Appliquer des changements de configuration nécessitant un redémarrage
- Résoudre des problèmes de mémoire ou de ressources
- Rafraîchir l'état d'une application qui devient instable
- Forcer la reconnexion aux services externes

> [!tip] Alternative à restart Parfois, recréer le conteneur est préférable au restart :
> 
> ```bash
> docker stop mon_app
> docker rm mon_app
> docker run --name mon_app -d mon_image
> ```
> 
> Cela garantit un état complètement neuf.

---

## docker pause/unpause

Les commandes `pause` et `unpause` permettent de geler et dégeler l'exécution d'un conteneur sans l'arrêter complètement. Elles utilisent la fonctionnalité **cgroups freezer** du kernel Linux.

### docker pause

Gèle tous les processus d'un conteneur. Le conteneur reste en mémoire mais n'utilise plus de CPU.

#### Syntaxe

```bash
docker pause CONTAINER [CONTAINER...]
```

#### Exemples d'utilisation

```bash
# Mettre en pause un conteneur
docker pause mon_conteneur

# Mettre en pause plusieurs conteneurs
docker pause web1 web2 worker1

# Vérifier l'état
docker ps --filter "status=paused"
```

> [!info] Différence avec stop
> 
> - **pause** : le conteneur reste en mémoire, suspension instantanée
> - **stop** : le conteneur est arrêté proprement, libère les ressources

#### Quand utiliser docker pause ?

- Libérer temporairement du CPU sans perdre l'état en mémoire
- Débugger un conteneur à un instant précis
- Gérer des pics de charge en priorisant certains services
- Tests et développement nécessitant un état figé

---

### docker unpause

Reprend l'exécution d'un conteneur mis en pause.

#### Syntaxe

```bash
docker unpause CONTAINER [CONTAINER...]
```

#### Exemples d'utilisation

```bash
# Reprendre l'exécution
docker unpause mon_conteneur

# Reprendre plusieurs conteneurs
docker unpause web1 web2 worker1

# Reprendre tous les conteneurs en pause
docker unpause $(docker ps -aq --filter "status=paused")
```

> [!example] Cas d'usage pratique
> 
> ```bash
> # Mise en pause pendant une maintenance
> docker pause $(docker ps -q --filter "name=worker*")
> 
> # Effectuer la maintenance système...
> 
> # Reprendre les workers
> docker unpause $(docker ps -aq --filter "status=paused")
> ```

> [!warning] Limitations
> 
> - Ne fonctionne que sur Linux (utilise cgroups)
> - Ne sauvegarde pas l'état sur disque
> - Les connexions réseau peuvent timeout pendant la pause
> - Pas adapté aux pauses longues

---

## docker kill

La commande `docker kill` arrête brutalement un conteneur en envoyant un signal, sans laisser le temps d'un arrêt propre. Par défaut, elle envoie SIGKILL.

#### Syntaxe

```bash
docker kill [OPTIONS] CONTAINER [CONTAINER...]
```

#### Options principales

|Option|Description|
|---|---|
|`-s, --signal string`|Signal à envoyer (défaut: SIGKILL)|

#### Exemples d'utilisation

```bash
# Tuer immédiatement un conteneur
docker kill mon_conteneur

# Envoyer un signal spécifique
docker kill -s SIGTERM mon_conteneur
docker kill -s HUP mon_conteneur

# Tuer plusieurs conteneurs
docker kill web1 web2 db1

# Tuer tous les conteneurs
docker kill $(docker ps -q)
```

#### Différence entre kill et stop

|Aspect|docker stop|docker kill|
|---|---|---|
|**Signal initial**|SIGTERM|SIGKILL|
|**Arrêt propre**|✅ Oui|❌ Non|
|**Délai**|10s par défaut|Immédiat|
|**Perte de données**|Peu probable|Possible|
|**Use case**|Arrêt normal|Conteneur bloqué|

> [!warning] Attention aux données `docker kill` ne laisse aucun temps au conteneur pour :
> 
> - Fermer les connexions aux bases de données
> - Sauvegarder l'état en cours
> - Libérer proprement les ressources
> - Terminer les transactions en cours

#### Quand utiliser docker kill ?

- Conteneur qui ne répond plus à `docker stop`
- Processus bloqué qui ne peut pas se terminer proprement
- Urgence : besoin d'arrêter immédiatement un service
- Tests de résilience et de récupération après crash

> [!tip] Signaux Unix courants
> 
> ```bash
> # Rechargement de configuration
> docker kill -s HUP nginx_container
> 
> # Arrêt propre alternatif
> docker kill -s TERM mon_app
> 
> # Dump de l'état (si l'app le gère)
> docker kill -s USR1 mon_app
> ```

> [!example] Récupération d'un conteneur bloqué
> 
> ```bash
> # Tentative d'arrêt propre
> docker stop -t 5 conteneur_bloque
> 
> # Si ça ne fonctionne pas...
> docker kill conteneur_bloque
> ```

---

## docker rm

La commande `docker rm` supprime définitivement un ou plusieurs conteneurs arrêtés. C'est la dernière étape du cycle de vie.

#### Syntaxe

```bash
docker rm [OPTIONS] CONTAINER [CONTAINER...]
```

#### Options principales

|Option|Description|
|---|---|
|`-f, --force`|Force la suppression (tue le conteneur si nécessaire)|
|`-v, --volumes`|Supprime aussi les volumes anonymes associés|
|`-l, --link`|Supprime le lien réseau spécifié|

#### Exemples d'utilisation

```bash
# Supprimer un conteneur arrêté
docker rm mon_conteneur

# Forcer la suppression d'un conteneur en cours
docker rm -f mon_conteneur

# Supprimer plusieurs conteneurs
docker rm web1 web2 db1

# Supprimer avec les volumes
docker rm -v mon_conteneur

# Supprimer tous les conteneurs arrêtés
docker rm $(docker ps -aq -f status=exited)

# Nettoyage complet (tous les conteneurs arrêtés)
docker container prune
```

> [!warning] Suppression irréversible La suppression d'un conteneur est **définitive**. Vous perdez :
> 
> - Les logs du conteneur
> - Les modifications du système de fichiers non persistées dans des volumes
> - La configuration réseau spécifique
> - L'historique d'exécution

#### Bonnes pratiques de suppression

```bash
# 1. Arrêter proprement avant de supprimer
docker stop mon_conteneur && docker rm mon_conteneur

# 2. Vérifier ce qui va être supprimé
docker ps -a --filter "status=exited"

# 3. Suppression sécurisée avec confirmation
docker rm $(docker ps -aq -f status=exited) --dry-run

# 4. Supprimer en conservant les volumes nommés
docker rm mon_conteneur
# (les volumes nommés persistent)

# 5. Tout supprimer incluant volumes anonymes
docker rm -v mon_conteneur
```

> [!tip] Nettoyage automatique avec --rm Pour éviter l'accumulation de conteneurs :
> 
> ```bash
> docker run --rm -d mon_image
> # Le conteneur sera automatiquement supprimé à l'arrêt
> ```

#### Gestion des volumes lors de la suppression

```bash
# Lister les volumes avant suppression
docker inspect -f '{{ .Mounts }}' mon_conteneur

# Supprimer conteneur ET volumes anonymes
docker rm -v mon_conteneur

# Les volumes nommés persistent même après rm
docker volume ls
docker volume rm mon_volume  # Suppression manuelle si nécessaire
```

> [!example] Script de nettoyage complet
> 
> ```bash
> #!/bin/bash
> # Arrêter tous les conteneurs
> docker stop $(docker ps -q)
> 
> # Supprimer tous les conteneurs
> docker rm $(docker ps -aq)
> 
> # Nettoyer les volumes non utilisés
> docker volume prune -f
> 
> # Nettoyer les réseaux non utilisés
> docker network prune -f
> ```

---

## Comparaison des commandes

### Tableau récapitulatif

|Commande|Effet|Brutal/Propre|Temps|État final|
|---|---|---|---|---|
|**start**|Démarre|-|Immédiat|running|
|**stop**|Arrête|Propre|10s défaut|exited|
|**restart**|Arrête + Démarre|Propre|10s + démarrage|running|
|**pause**|Gèle|Immédiat|Instantané|paused|
|**unpause**|Dégèle|Immédiat|Instantané|running|
|**kill**|Tue|Brutal|Immédiat|exited|
|**rm**|Supprime|-|Immédiat|(supprimé)|

### Flux de décision

```
Conteneur en cours d'exécution
         │
         ├─→ Arrêt temporaire normal ? → docker stop
         ├─→ Gel temporaire ? → docker pause
         ├─→ Redémarrage ? → docker restart
         ├─→ Conteneur bloqué ? → docker kill
         └─→ Suppression ? → docker stop + docker rm
```

> [!info] Enchaînement des commandes Ordre typique du cycle de vie complet :
> 
> ```bash
> docker run → running
> docker pause → paused
> docker unpause → running
> docker stop → exited
> docker start → running
> docker restart → running
> docker kill → exited
> docker rm → (supprimé)
> ```

---

## Bonnes pratiques

### 1. Arrêts propres

```bash
# ❌ Mauvais : kill direct sans raison
docker kill mon_app

# ✅ Bon : stop avec délai approprié
docker stop -t 30 mon_app
```

> [!tip] Adapter le délai selon l'application
> 
> - Applications web simples : 10s suffit
> - Bases de données : 30-60s recommandé
> - Jobs de traitement : adapter au temps moyen de traitement

### 2. Vérifications avant suppression

```bash
# ❌ Mauvais : suppression aveugle
docker rm -f $(docker ps -aq)

# ✅ Bon : vérifier d'abord
docker ps -a
docker rm $(docker ps -aq -f status=exited)
```

### 3. Gestion des ressources

```bash
# Conteneurs temporaires : auto-suppression
docker run --rm mon_image

# Nettoyage régulier
docker container prune  # Supprime conteneurs arrêtés
docker system prune     # Nettoyage global
```

### 4. Logging et debugging

```bash
# Vérifier l'état avant actions
docker ps -a
docker inspect mon_conteneur

# Consulter les logs avant de supprimer
docker logs mon_conteneur

# Sauvegarder les logs
docker logs mon_conteneur > logs_backup.txt 2>&1
```

### 5. Scripts de gestion

```bash
# Arrêt gracieux de tous les services
#!/bin/bash
for container in $(docker ps -q); do
    echo "Arrêt de $container..."
    docker stop -t 30 "$container"
done
```

> [!warning] Pièges courants
> 
> - Oublier que `rm` ne supprime pas les volumes nommés
> - Utiliser `kill` par défaut au lieu de `stop`
> - Ne pas adapter le timeout de stop à l'application
> - Supprimer sans vérifier les dépendances entre conteneurs
> - Pause longue qui fait timeout les connexions réseau

### 6. Surveillance et monitoring

```bash
# Surveiller l'état des conteneurs
watch docker ps

# Vérifier l'utilisation des ressources
docker stats

# Inspecter un conteneur spécifique
docker inspect --format='{{.State.Status}}' mon_conteneur
```

> [!tip] Automatisation avec Docker events
> 
> ```bash
> # Écouter les événements Docker
> docker events --filter 'type=container'
> 
> # Scripter des actions sur événements
> docker events --filter 'event=stop' --format '{{.Actor.Attributes.name}}'
> ```

---

## Récapitulatif

La maîtrise du cycle de vie des conteneurs Docker repose sur :

1. **Comprendre les états** : created, running, paused, stopped, exited
2. **Choisir la bonne commande** : start/stop pour le normal, kill pour l'urgence, pause pour le gel temporaire
3. **Respecter les délais** : laisser le temps aux applications de s'arrêter proprement
4. **Gérer la persistance** : comprendre que rm supprime le conteneur mais pas forcément les volumes
5. **Automatiser intelligemment** : utiliser --rm, prune, et scripts adaptés

> [!success] Points clés à retenir
> 
> - `docker stop` : arrêt propre (toujours privilégier)
> - `docker kill` : arrêt brutal (seulement si nécessaire)
> - `docker pause/unpause` : gel temporaire (garde l'état mémoire)
> - `docker rm` : suppression définitive (vérifier les volumes)
> - Adapter les timeouts selon vos applications