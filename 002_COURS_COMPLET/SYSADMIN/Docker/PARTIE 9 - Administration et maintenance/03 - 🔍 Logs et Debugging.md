

> [!info] Vue d'ensemble La gestion des logs et le debugging sont essentiels pour surveiller, diagnostiquer et résoudre les problèmes dans vos conteneurs Docker. Cette section couvre la configuration des drivers de logs, l'analyse des journaux et les techniques de débogage avancées.

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

## 🚀 Configuration des logs drivers

### Qu'est-ce qu'un log driver ?

Un log driver définit comment Docker collecte et stocke les logs des conteneurs. Par défaut, Docker utilise le driver `json-file`, mais d'autres options permettent d'envoyer les logs vers des systèmes centralisés.

> [!tip] Pourquoi configurer un log driver ?
> 
> - Centraliser les logs de plusieurs conteneurs
> - Intégrer avec des outils de monitoring (Splunk, ELK, Datadog)
> - Optimiser le stockage et la rotation des logs
> - Améliorer les performances en déléguant la gestion des logs

### Drivers disponibles

|Driver|Description|Cas d'usage|
|---|---|---|
|`json-file`|Stockage JSON local (défaut)|Développement, petites applications|
|`syslog`|Envoi vers syslog|Intégration système Unix/Linux|
|`journald`|Envoi vers systemd journal|Systèmes avec systemd|
|`gelf`|Graylog Extended Log Format|Infrastructure Graylog|
|`fluentd`|Envoi vers Fluentd|Pipelines de logs complexes|
|`awslogs`|Amazon CloudWatch Logs|Applications AWS|
|`splunk`|Splunk Enterprise|Monitoring d'entreprise|
|`gcplogs`|Google Cloud Logging|Applications GCP|
|`local`|Optimisé pour la performance|Production avec rotation automatique|
|`none`|Désactive les logs|Tests, conteneurs éphémères|

### Configuration globale (daemon.json)

Pour configurer le driver par défaut pour tous les conteneurs :

```bash
# /etc/docker/daemon.json
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",      # Taille max par fichier de log
    "max-file": "3",        # Nombre de fichiers de rotation
    "labels": "production", # Métadonnées
    "compress": "true"      # Compression des logs archivés
  }
}
```

```bash
# Redémarrer Docker pour appliquer les changements
sudo systemctl restart docker
```

> [!warning] Attention Modifier le daemon.json affecte tous les nouveaux conteneurs. Les conteneurs existants conservent leur configuration de logs.

### Configuration par conteneur

#### Au lancement (docker run)

```bash
# Exemple avec json-file et rotation
docker run -d \
  --name app \
  --log-driver json-file \
  --log-opt max-size=5m \
  --log-opt max-file=2 \
  --log-opt compress=true \
  nginx

# Exemple avec syslog
docker run -d \
  --name app-syslog \
  --log-driver syslog \
  --log-opt syslog-address=tcp://192.168.1.100:514 \
  --log-opt tag="app-{{.Name}}" \
  nginx

# Exemple avec fluentd
docker run -d \
  --name app-fluentd \
  --log-driver fluentd \
  --log-opt fluentd-address=localhost:24224 \
  --log-opt tag="docker.{{.Name}}" \
  nginx

# Désactiver les logs (pour tests de performance)
docker run -d \
  --name app-nolog \
  --log-driver none \
  nginx
```

#### Avec Docker Compose

```bash
version: '3.8'

services:
  web:
    image: nginx
    logging:
      driver: json-file
      options:
        max-size: "10m"
        max-file: "3"
        compress: "true"
        labels: "app=web,env=production"
  
  api:
    image: myapi
    logging:
      driver: syslog
      options:
        syslog-address: "tcp://log-server:514"
        tag: "api-{{.Name}}"
  
  worker:
    image: worker
    logging:
      driver: fluentd
      options:
        fluentd-address: "fluentd:24224"
        fluentd-async-connect: "true"
        tag: "docker.worker"
```

### Options avancées par driver

#### json-file (driver par défaut)

```bash
docker run -d \
  --log-driver json-file \
  --log-opt max-size=20m \        # Taille max du fichier
  --log-opt max-file=5 \          # Nombre de fichiers en rotation
  --log-opt compress=true \       # Compresser les anciens logs
  --log-opt labels=env,version \  # Inclure des labels
  --log-opt env=ENV,VERSION \     # Inclure des variables d'environnement
  -e ENV=production \
  -e VERSION=1.2.3 \
  --label env=production \
  nginx
```

#### local (optimisé pour la production)

```bash
# Driver 'local' avec meilleures performances
docker run -d \
  --log-driver local \
  --log-opt max-size=100m \
  --log-opt max-file=10 \
  --log-opt compress=true \
  nginx
```

> [!tip] Driver 'local' vs 'json-file' Le driver `local` offre de meilleures performances car il utilise un format binaire optimisé et limite automatiquement l'utilisation du disque.

#### syslog

```bash
docker run -d \
  --log-driver syslog \
  --log-opt syslog-address=udp://192.168.1.100:514 \
  --log-opt syslog-facility=daemon \
  --log-opt syslog-format=rfc5424 \
  --log-opt tag="docker/{{.Name}}/{{.ID}}" \
  nginx
```

#### awslogs (CloudWatch)

```bash
docker run -d \
  --log-driver awslogs \
  --log-opt awslogs-region=eu-west-1 \
  --log-opt awslogs-group=myapp-logs \
  --log-opt awslogs-stream=container-{{.Name}} \
  --log-opt awslogs-create-group=true \
  nginx
```

### Variables de template

Docker supporte des variables dans les options de logs :

|Variable|Description|Exemple|
|---|---|---|
|`{{.ID}}`|ID court du conteneur|`abc123def456`|
|`{{.FullID}}`|ID complet du conteneur|`abc123def456...`|
|`{{.Name}}`|Nom du conteneur|`my-app`|
|`{{.ImageID}}`|ID de l'image|`sha256:abc...`|
|`{{.ImageName}}`|Nom de l'image|`nginx:latest`|
|`{{.DaemonName}}`|Nom du daemon Docker|`docker`|

```bash
# Exemple d'utilisation
docker run -d \
  --log-driver syslog \
  --log-opt tag="app={{.Name}}-id={{.ID}}" \
  nginx
```

### Pièges courants

> [!warning] Pièges à éviter
> 
> - **Logs illimités** : Sans rotation, les logs peuvent saturer le disque
> - **Perte de `docker logs`** : Certains drivers (syslog, fluentd) ne permettent pas `docker logs`
> - **Configuration incompatible** : Vérifier que le service distant est accessible avant de démarrer
> - **Performances** : Les drivers distants peuvent ralentir l'application si le réseau est lent

### Bonnes pratiques

✅ **Toujours configurer la rotation des logs** en production

```bash
--log-opt max-size=10m --log-opt max-file=3
```

✅ **Utiliser le driver `local`** pour de meilleures performances en production

✅ **Ajouter des tags structurés** pour faciliter le filtrage

```bash
--log-opt tag="app={{.Name}},env=prod,version=1.0"
```

✅ **Tester la configuration** avant de déployer en production

✅ **Monitorer l'espace disque** même avec rotation activée

---

## 📊 Analyse des logs

### Commande de base : docker logs

```bash
# Afficher tous les logs d'un conteneur
docker logs mon-conteneur

# Suivre les logs en temps réel (-f = follow)
docker logs -f mon-conteneur

# Afficher les 100 dernières lignes
docker logs --tail 100 mon-conteneur

# Afficher les logs avec timestamps
docker logs -t mon-conteneur

# Logs depuis un moment précis
docker logs --since 2024-12-25T10:00:00 mon-conteneur
docker logs --since 1h mon-conteneur
docker logs --since 30m mon-conteneur

# Logs jusqu'à un moment précis
docker logs --until 2024-12-25T12:00:00 mon-conteneur

# Combiner plusieurs options
docker logs -f --tail 50 -t --since 10m mon-conteneur
```

> [!info] Format des timestamps Les timestamps utilisent le format ISO 8601. Utilisez `-t` pour les afficher.

### Filtrage et recherche

```bash
# Filtrer avec grep
docker logs mon-conteneur | grep "ERROR"
docker logs mon-conteneur | grep -i "error\|warning"

# Compter les occurrences
docker logs mon-conteneur | grep "ERROR" | wc -l

# Filtrer par période et rechercher
docker logs --since 1h mon-conteneur | grep "404"

# Exporter les logs dans un fichier
docker logs mon-conteneur > logs.txt
docker logs --since 24h mon-conteneur > logs-24h.txt

# Analyser avec des outils (jq pour JSON)
docker logs mon-conteneur | jq 'select(.level=="error")'
```

### Analyse des logs JSON

Avec le driver `json-file`, les logs sont structurés :

```bash
# Voir le format JSON brut
cat /var/lib/docker/containers/<container-id>/<container-id>-json.log

# Exemple de sortie
{"log":"2024-12-25 10:00:00 INFO Application started\n","stream":"stdout","time":"2024-12-25T10:00:00.123456789Z"}

# Extraire uniquement le message avec jq
docker logs mon-conteneur 2>&1 | jq -r '.log'

# Filtrer par stream (stdout ou stderr)
cat /var/lib/docker/containers/*/...-json.log | jq 'select(.stream=="stderr")'
```

### Logs de plusieurs conteneurs

```bash
# Suivre les logs de plusieurs conteneurs
docker logs -f conteneur1 &
docker logs -f conteneur2 &

# Avec docker-compose
docker-compose logs

# Suivre tous les services
docker-compose logs -f

# Suivre un service spécifique
docker-compose logs -f web

# Logs de plusieurs services
docker-compose logs -f web api worker

# Avec options
docker-compose logs -f --tail=100 --timestamps web
```

### Analyse avancée avec docker events

```bash
# Surveiller les événements Docker en temps réel
docker events

# Filtrer par type d'événement
docker events --filter 'type=container'

# Filtrer par conteneur
docker events --filter 'container=mon-conteneur'

# Filtrer par événement spécifique
docker events --filter 'event=start'
docker events --filter 'event=die'

# Combiner plusieurs filtres
docker events --filter 'type=container' --filter 'event=start'

# Format personnalisé
docker events --format '{{.Time}} - {{.Action}} - {{.Actor.Attributes.name}}'

# Depuis une date
docker events --since '2024-12-25T10:00:00'
```

### Inspection des métadonnées de logs

```bash
# Voir la configuration de logs d'un conteneur
docker inspect --format='{{.HostConfig.LogConfig}}' mon-conteneur

# Voir le chemin du fichier de log
docker inspect --format='{{.LogPath}}' mon-conteneur

# Informations complètes sur les logs
docker inspect mon-conteneur | jq '.[0].HostConfig.LogConfig'
```

### Outils d'analyse tiers

> [!example] Outils populaires
> 
> - **Loki + Grafana** : Visualisation et requêtes de logs
> - **ELK Stack** (Elasticsearch, Logstash, Kibana) : Analyse avancée
> - **Graylog** : Gestion centralisée des logs
> - **Datadog, Splunk** : Solutions d'entreprise
> - **Portainer** : Interface graphique incluant la visualisation des logs

### Bonnes pratiques d'analyse

✅ **Utiliser des logs structurés** (JSON) dans vos applications

✅ **Ajouter des niveaux de log** (INFO, WARNING, ERROR, DEBUG)

✅ **Inclure des identifiants de corrélation** pour tracer les requêtes

✅ **Centraliser les logs** en production avec Fluentd, Loki ou ELK

✅ **Définir des alertes** sur les patterns d'erreurs critiques

✅ **Archiver les logs** régulièrement pour l'audit et le debugging

### Astuces

💡 **Alias pratiques**

```bash
# Ajouter dans ~/.bashrc ou ~/.zshrc
alias dlog='docker logs'
alias dlogf='docker logs -f'
alias dlogt='docker logs -f --tail 100'
```

💡 **Script de monitoring simple**

```bash
#!/bin/bash
# monitor-errors.sh
while true; do
  errors=$(docker logs --since 1m mon-conteneur 2>&1 | grep -c "ERROR")
  if [ $errors -gt 0 ]; then
    echo "[ALERT] $errors erreurs détectées"
  fi
  sleep 60
done
```

💡 **Rotation manuelle des logs**

```bash
# Trouver et tronquer les gros fichiers de logs
find /var/lib/docker/containers -name "*.log" -size +100M -exec truncate -s 0 {} \;
```

---

## 🐛 Débogage de conteneurs

### Vérifications de base

#### État du conteneur

```bash
# Lister les conteneurs en cours
docker ps

# Lister tous les conteneurs (y compris arrêtés)
docker ps -a

# Voir les conteneurs qui ont crashé
docker ps -a --filter "status=exited"

# Détails complets d'un conteneur
docker inspect mon-conteneur

# Voir uniquement l'état
docker inspect --format='{{.State.Status}}' mon-conteneur

# Voir le code de sortie
docker inspect --format='{{.State.ExitCode}}' mon-conteneur

# Voir les derniers événements
docker inspect --format='{{range .State.Health.Log}}{{.Output}}{{end}}' mon-conteneur
```

#### Codes de sortie courants

|Code|Signification|
|---|---|
|0|Arrêt normal|
|1|Erreur d'application|
|125|Erreur Docker (commande mal formée)|
|126|Commande non exécutable|
|127|Commande introuvable|
|137|Tué par SIGKILL (OOM souvent)|
|139|Erreur de segmentation|
|143|Terminé par SIGTERM|

```bash
# Afficher uniquement les conteneurs avec code de sortie non-nul
docker ps -a --filter "exited!=0"
```

### Accéder à un conteneur en cours d'exécution

```bash
# Ouvrir un shell interactif
docker exec -it mon-conteneur bash
docker exec -it mon-conteneur sh  # Si bash n'est pas disponible

# Exécuter une commande unique
docker exec mon-conteneur ls -la /app
docker exec mon-conteneur cat /etc/hosts
docker exec mon-conteneur ps aux

# En tant qu'utilisateur spécifique
docker exec -u root -it mon-conteneur bash

# Définir des variables d'environnement
docker exec -e DEBUG=true mon-conteneur python script.py

# Avec un working directory spécifique
docker exec -w /app mon-conteneur npm test
```

> [!tip] Astuce Si le conteneur n'a pas bash, essayez `sh`, `/bin/sh`, ou même `/bin/ash` (Alpine Linux).

### Déboguer un conteneur qui crash au démarrage

Quand un conteneur s'arrête immédiatement :

```bash
# 1. Voir les derniers logs
docker logs conteneur-qui-crash

# 2. Voir le code de sortie
docker inspect --format='{{.State.ExitCode}}' conteneur-qui-crash

# 3. Lancer avec override de la commande
docker run -it --rm --entrypoint sh mon-image

# 4. Lancer et garder le conteneur vivant
docker run -d mon-image tail -f /dev/null
docker exec -it <container-id> bash

# 5. Lancer en mode debug avec toutes les sorties
docker run -it --rm mon-image bash -x

# 6. Désactiver le healthcheck temporairement
docker run -d --no-healthcheck mon-image
```

### Debugging des problèmes réseau

```bash
# Voir la configuration réseau
docker inspect --format='{{.NetworkSettings.Networks}}' mon-conteneur

# Voir l'IP du conteneur
docker inspect --format='{{.NetworkSettings.IPAddress}}' mon-conteneur

# Lister les réseaux
docker network ls

# Inspecter un réseau
docker network inspect bridge

# Voir tous les conteneurs sur un réseau
docker network inspect mon-reseau --format='{{range .Containers}}{{.Name}} {{end}}'

# Tester la connectivité depuis le conteneur
docker exec mon-conteneur ping google.com
docker exec mon-conteneur curl https://api.example.com
docker exec mon-conteneur nslookup exemple.com

# Installer des outils de debug dans un conteneur (temporairement)
docker exec -u root mon-conteneur apt-get update
docker exec -u root mon-conteneur apt-get install -y curl iputils-ping dnsutils

# Inspecter les ports exposés
docker port mon-conteneur

# Capturer le trafic réseau
docker run --net container:mon-conteneur nicolaka/netshoot tcpdump -i any
```

> [!example] Conteneur netshoot pour le debugging réseau `nicolaka/netshoot` est une image spécialisée avec tous les outils réseau (tcpdump, curl, netstat, etc.)

### Debugging des problèmes de volumes et permissions

```bash
# Voir les volumes montés
docker inspect --format='{{.Mounts}}' mon-conteneur

# Lister les volumes
docker volume ls

# Inspecter un volume
docker volume inspect mon-volume

# Voir le contenu d'un volume
docker run --rm -v mon-volume:/data alpine ls -la /data

# Vérifier les permissions
docker exec mon-conteneur ls -la /path/to/mount

# Corriger les permissions (si problème)
docker exec -u root mon-conteneur chown -R 1000:1000 /app/data

# Déboguer un bind mount
docker run --rm -v /host/path:/container/path alpine ls -la /container/path
```

### Debugging des problèmes de ressources

```bash
# Voir l'utilisation des ressources en temps réel
docker stats

# Stats d'un conteneur spécifique
docker stats mon-conteneur --no-stream

# Format personnalisé
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"

# Voir les limites de ressources
docker inspect --format='{{.HostConfig.Memory}}' mon-conteneur
docker inspect --format='{{.HostConfig.CpuShares}}' mon-conteneur

# Identifier un conteneur qui consomme trop (OOM)
docker inspect --format='{{.State.OOMKilled}}' mon-conteneur

# Historique d'utilisation
docker events --filter 'event=oom' --since 24h
```

> [!warning] Out Of Memory (OOM) Si `OOMKilled` est `true`, le conteneur a été tué car il a dépassé sa limite de mémoire. Vérifiez les limites avec `--memory`.

### Debugging avec des outils avancés

#### Utiliser strace pour tracer les appels système

```bash
# Lancer un conteneur avec les capacités nécessaires
docker run --rm -it --cap-add=SYS_PTRACE --security-opt seccomp=unconfined \
  mon-image strace -f python app.py
```

#### Utiliser gdb pour déboguer une application

```bash
docker exec -it --privileged mon-conteneur gdb -p <pid>
```

#### Analyser les performances avec perf

```bash
docker run --rm -it --privileged mon-image perf top
```

### Conteneur en mode debug (sidecar)

Attacher un conteneur de debug au namespace d'un autre :

```bash
# Partager le namespace réseau
docker run -it --rm --network container:mon-conteneur nicolaka/netshoot

# Partager le namespace PID
docker run -it --rm --pid container:mon-conteneur alpine ps aux

# Partager plusieurs namespaces
docker run -it --rm \
  --network container:mon-conteneur \
  --pid container:mon-conteneur \
  --volumes-from mon-conteneur \
  alpine sh
```

### Debugging avec docker-compose

```bash
# Logs de tous les services
docker-compose logs

# Logs d'un service spécifique en temps réel
docker-compose logs -f web

# Recréer et déboguer un service
docker-compose up --force-recreate web

# Lancer un service avec override
docker-compose run --rm web bash

# Voir la configuration finale (après merge des fichiers)
docker-compose config

# Vérifier les dépendances
docker-compose ps

# Inspecter un service
docker-compose exec web env
```

### Pièges courants

> [!warning] Pièges à éviter
> 
> - **Permissions incorrectes** : Surtout avec les bind mounts (UID/GID différents)
> - **Chemins relatifs** : Utiliser des chemins absolus pour les volumes
> - **Réseau isolé** : Vérifier que le conteneur est sur le bon réseau
> - **Variables d'environnement manquantes** : Vérifier avec `docker exec env`
> - **Healthcheck trop strict** : Peut marquer un conteneur comme unhealthy prématurément
> - **Oublier --rm** : Les conteneurs de debug s'accumulent

### Bonnes pratiques de debugging

✅ **Commencer par les logs** : 90% des problèmes sont visibles dans les logs

✅ **Vérifier l'état et le code de sortie** avant d'aller plus loin

✅ **Utiliser des images de debug légères** (Alpine, BusyBox) pour les sidecars

✅ **Activer le mode debug** dans vos applications (via variables d'environnement)

✅ **Documenter les problèmes récurrents** et leurs solutions

✅ **Tester localement** avec la même configuration que la production

✅ **Utiliser `docker-compose`** pour reproduire des environnements complexes

### Astuces de debugging

💡 **Créer un alias pour l'inspection rapide**

```bash
alias dinspect='docker inspect --format="{{json .State}}" | jq'
```

💡 **Script de santé rapide**

```bash
#!/bin/bash
container=$1
echo "=== Status ==="
docker inspect --format='{{.State.Status}}' $container
echo "=== Exit Code ==="
docker inspect --format='{{.State.ExitCode}}' $container
echo "=== Last 20 logs ==="
docker logs --tail 20 $container
echo "=== Resource Usage ==="
docker stats --no-stream $container
```

💡 **Garder un conteneur vivant pour debugging**

```bash
# Ajouter à la commande : sleep infinity ou tail -f /dev/null
docker run -d mon-image tail -f /dev/null
```

💡 **Explorer une image sans la lancer**

```bash
# Utiliser dive pour analyser les layers
docker run --rm -it \
  -v /var/run/docker.sock:/var/run/docker.sock \
  wagoodman/dive:latest mon-image
```

---

> [!tip] Récapitulatif
> 
> - **Logs drivers** : Configurer la collecte et le stockage des logs (json-file, syslog, fluentd, etc.)
> - **Analyse des logs** : Utiliser `docker logs`, filtrer, exporter et analyser avec des outils tiers
> - **Debugging** : Inspecter l'état, accéder aux conteneurs, tracer les problèmes réseau/ressources/volumes
> 
> La maîtrise de ces outils est essentielle pour maintenir des applications conteneurisées en production.