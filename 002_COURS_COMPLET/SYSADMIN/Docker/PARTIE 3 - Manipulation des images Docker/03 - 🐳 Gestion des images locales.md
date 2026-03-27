

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

## 🎯 Vue d'ensemble

La gestion des images locales est une compétence essentielle pour maintenir un environnement Docker propre et optimisé. Les images s'accumulent rapidement lors du développement, et savoir les lister, les inspecter, les supprimer et les nettoyer permet de libérer de l'espace disque et d'améliorer les performances.

> [!info] Pourquoi gérer ses images locales ?
> 
> - **Économie d'espace** : Les images Docker peuvent occuper plusieurs gigaoctets
> - **Performance** : Moins d'images = recherches plus rapides
> - **Sécurité** : Supprimer les images obsolètes réduit les risques de vulnérabilités
> - **Organisation** : Un registre local propre facilite le travail quotidien

---

## 📦 Lister les images

### Commandes principales

Il existe deux commandes équivalentes pour lister les images Docker :

```bash
# Syntaxe classique
docker images

# Syntaxe moderne (recommandée)
docker image ls
```

> [!tip] Bonne pratique Préférez `docker image ls` car elle suit la structure moderne de Docker CLI et est plus cohérente avec les autres commandes de gestion.

### Affichage standard

```bash
docker image ls
```

**Sortie typique :**

```
REPOSITORY          TAG       IMAGE ID       CREATED        SIZE
nginx               latest    a6bd71f48f68   2 weeks ago    187MB
ubuntu              22.04     3b418d7b466a   3 weeks ago    77.8MB
postgres            15        9f3ec01f884d   1 month ago    379MB
node                18-alpine e1a7f8c0e6bb   2 months ago   174MB
```

**Colonnes expliquées :**

|Colonne|Description|
|---|---|
|**REPOSITORY**|Nom de l'image (peut inclure un registry)|
|**TAG**|Version ou variante de l'image|
|**IMAGE ID**|Identifiant unique de l'image (12 premiers caractères)|
|**CREATED**|Date de création de l'image|
|**SIZE**|Taille de l'image sur le disque|

### Options de filtrage

#### Filtrer par nom de repository

```bash
# Lister uniquement les images nginx
docker image ls nginx

# Avec wildcard (ne fonctionne pas directement, utiliser grep)
docker image ls | grep node
```

#### Afficher uniquement les IDs

```bash
# Très utile pour les scripts et l'automatisation
docker image ls -q

# Exemple de sortie :
# a6bd71f48f68
# 3b418d7b466a
# 9f3ec01f884d
```

> [!example] Cas d'usage pratique Supprimer toutes les images en une commande :
> 
> ```bash
> docker rmi $(docker image ls -q)
> ```

#### Afficher toutes les images (y compris intermédiaires)

```bash
# Les images intermédiaires sont créées pendant le build
docker image ls -a
```

> [!info] Images intermédiaires Lors du build d'une image, Docker crée des images intermédiaires pour chaque instruction du Dockerfile. Elles sont normalement cachées mais peuvent être affichées avec l'option `-a`.

#### Filtres avancés

```bash
# Images créées avant une certaine image
docker image ls --filter "before=nginx:latest"

# Images créées après une certaine image
docker image ls --filter "since=ubuntu:22.04"

# Images sans tag (dangereuses à supprimer)
docker image ls --filter "dangling=true"

# Filtrer par label
docker image ls --filter "label=maintainer=John"
```

#### Format personnalisé

```bash
# Affichage personnalisé avec --format
docker image ls --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"

# Format JSON pour parsing
docker image ls --format json

# Affichage compact
docker image ls --format "{{.Repository}}:{{.Tag}}"
```

> [!tip] Astuce de productivité Créez un alias dans votre `.bashrc` ou `.zshrc` :
> 
> ```bash
> alias dils='docker image ls --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"'
> ```

### Trier les résultats

```bash
# Trier par taille (ordre décroissant)
docker image ls --format "table {{.Repository}}\t{{.Size}}" | sort -k2 -h -r

# Trier par date de création
docker image ls --format "table {{.Repository}}\t{{.CreatedAt}}"
```

---

## 🔍 Inspecter une image

### Commande de base

```bash
docker inspect <image>
```

La commande `docker inspect` retourne toutes les métadonnées d'une image au format JSON. C'est l'outil principal pour obtenir des informations détaillées sur une image.

> [!info] À quoi sert l'inspection ?
> 
> - Comprendre la configuration interne d'une image
> - Vérifier les variables d'environnement par défaut
> - Consulter l'historique des layers
> - Déboguer des problèmes de build ou de déploiement
> - Extraire des informations spécifiques via des requêtes

### Syntaxe complète

```bash
# Par nom et tag
docker inspect nginx:latest

# Par ID (complet ou abrégé)
docker inspect a6bd71f48f68

# Inspecter plusieurs images
docker inspect nginx ubuntu postgres
```

### Structure de la sortie JSON

```json
[
    {
        "Id": "sha256:a6bd71f48f68...",
        "RepoTags": ["nginx:latest"],
        "RepoDigests": ["nginx@sha256:..."],
        "Parent": "",
        "Created": "2024-01-15T10:23:45.123456789Z",
        "Container": "abc123...",
        "ContainerConfig": { ... },
        "DockerVersion": "24.0.7",
        "Architecture": "amd64",
        "Os": "linux",
        "Size": 187234567,
        "VirtualSize": 187234567,
        "GraphDriver": { ... },
        "RootFS": {
            "Type": "layers",
            "Layers": [
                "sha256:layer1...",
                "sha256:layer2...",
                "sha256:layer3..."
            ]
        },
        "Config": {
            "Env": [
                "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
                "NGINX_VERSION=1.25.3"
            ],
            "Cmd": ["nginx", "-g", "daemon off;"],
            "WorkingDir": "/",
            "ExposedPorts": {
                "80/tcp": {}
            },
            "Labels": { ... }
        }
    }
]
```

### Extraire des informations spécifiques

Docker inspect accepte l'option `--format` avec la syntaxe Go template pour extraire des champs précis.

#### Informations générales

```bash
# Afficher l'architecture
docker inspect --format='{{.Architecture}}' nginx

# Afficher la date de création
docker inspect --format='{{.Created}}' nginx

# Afficher le système d'exploitation
docker inspect --format='{{.Os}}' nginx

# Afficher la taille
docker inspect --format='{{.Size}}' nginx
```

#### Configuration

```bash
# Variables d'environnement
docker inspect --format='{{.Config.Env}}' nginx

# Commande par défaut
docker inspect --format='{{.Config.Cmd}}' nginx

# Point d'entrée
docker inspect --format='{{.Config.Entrypoint}}' nginx

# Répertoire de travail
docker inspect --format='{{.Config.WorkingDir}}' nginx

# Ports exposés
docker inspect --format='{{.Config.ExposedPorts}}' nginx

# Utilisateur par défaut
docker inspect --format='{{.Config.User}}' nginx
```

#### Layers et système de fichiers

```bash
# Lister tous les layers
docker inspect --format='{{range .RootFS.Layers}}{{println .}}{{end}}' nginx

# Nombre de layers
docker inspect --format='{{len .RootFS.Layers}}' nginx

# Type de système de fichiers
docker inspect --format='{{.GraphDriver.Name}}' nginx
```

#### Labels

```bash
# Tous les labels
docker inspect --format='{{.Config.Labels}}' nginx

# Un label spécifique
docker inspect --format='{{index .Config.Labels "maintainer"}}' nginx
```

> [!example] Exemple pratique : extraire la version d'un logiciel
> 
> ```bash
> # Extraire la version de nginx depuis les variables d'environnement
> docker inspect --format='{{range .Config.Env}}{{println .}}{{end}}' nginx:latest | grep VERSION
> ```

### Cas d'usage avancés

#### Comparer deux images

```bash
# Comparer les layers de deux images
diff <(docker inspect --format='{{range .RootFS.Layers}}{{println .}}{{end}}' nginx:1.24) \
     <(docker inspect --format='{{range .RootFS.Layers}}{{println .}}{{end}}' nginx:1.25)
```

#### Vérifier la provenance d'une image

```bash
# Afficher le digest pour vérifier l'authenticité
docker inspect --format='{{index .RepoDigests 0}}' nginx:latest

# Afficher les informations de build
docker inspect --format='{{.Config.Labels}}' nginx | grep -i build
```

> [!warning] Attention aux images non signées Toujours vérifier la provenance des images, surtout en production. Les images officielles Docker ont généralement des labels de provenance et des signatures vérifiables.

#### Script de diagnostic

```bash
#!/bin/bash
# Script pour afficher un résumé d'une image

IMAGE=$1

echo "=== Informations sur $IMAGE ==="
echo "Architecture: $(docker inspect --format='{{.Architecture}}' $IMAGE)"
echo "OS: $(docker inspect --format='{{.Os}}' $IMAGE)"
echo "Taille: $(docker inspect --format='{{.Size}}' $IMAGE | numfmt --to=iec)"
echo "Layers: $(docker inspect --format='{{len .RootFS.Layers}}' $IMAGE)"
echo "Créée le: $(docker inspect --format='{{.Created}}' $IMAGE)"
echo ""
echo "=== Configuration ==="
echo "CMD: $(docker inspect --format='{{.Config.Cmd}}' $IMAGE)"
echo "WorkDir: $(docker inspect --format='{{.Config.WorkingDir}}' $IMAGE)"
echo "Ports: $(docker inspect --format='{{.Config.ExposedPorts}}' $IMAGE)"
```

---

## 🗑️ Supprimer des images

### Commande de base

```bash
docker rmi <image>
```

La commande `docker rmi` (remove image) permet de supprimer une ou plusieurs images du système local.

> [!info] Quand supprimer une image ?
> 
> - Pour libérer de l'espace disque
> - Après avoir mis à jour vers une nouvelle version
> - Pour nettoyer des images de test ou de développement
> - Avant de reconstruire une image avec le même tag

### Syntaxe et options

```bash
# Supprimer une image par nom:tag
docker rmi nginx:latest

# Supprimer par ID
docker rmi a6bd71f48f68

# Supprimer plusieurs images
docker rmi nginx ubuntu postgres

# Forcer la suppression
docker rmi -f nginx:latest

# Supprimer sans supprimer les images parent non taguées
docker rmi --no-prune nginx:latest
```

### Comportement de suppression

#### Suppression simple

```bash
docker rmi ubuntu:22.04
```

**Ce qui se passe :**

1. Docker vérifie qu'aucun conteneur n'utilise cette image
2. Si l'image a plusieurs tags, seul le tag est supprimé
3. Si c'est le dernier tag, l'image et ses layers sont supprimés

> [!warning] Erreur courante : image utilisée
> 
> ```
> Error response from daemon: conflict: unable to remove repository reference "nginx:latest" 
> (must force) - container abc123 is using its referenced image a6bd71f48f68
> ```
> 
> **Solution** : Arrêter et supprimer le conteneur d'abord, ou utiliser `-f` pour forcer.

#### Images avec plusieurs tags

```bash
# Si une image a plusieurs tags
docker image ls
# nginx    latest    a6bd71f48f68
# nginx    1.25      a6bd71f48f68
# nginx    stable    a6bd71f48f68

# Supprimer un tag
docker rmi nginx:latest
# Seul le tag "latest" est supprimé, l'image reste avec les tags 1.25 et stable

# Supprimer tous les tags
docker rmi nginx:latest nginx:1.25 nginx:stable
# Maintenant l'image et ses layers sont supprimés
```

#### Force de suppression

```bash
# Forcer la suppression même si un conteneur utilise l'image
docker rmi -f nginx:latest
```

> [!warning] Danger : force de suppression Utiliser `-f` peut créer des conteneurs "orphelins" qui référencent des images supprimées. Ces conteneurs peuvent devenir instables. **Utilisez cette option avec précaution.**

### Patterns de suppression courants

#### Supprimer toutes les images

```bash
# Supprimer toutes les images (attention !)
docker rmi $(docker image ls -q)

# Avec force
docker rmi -f $(docker image ls -q)
```

> [!warning] Commande destructive Cette commande supprime **TOUTES** les images. Utilisez-la uniquement si vous êtes certain de vouloir tout nettoyer.

#### Supprimer les images d'un repository spécifique

```bash
# Supprimer toutes les images nginx
docker rmi $(docker image ls -q nginx)

# Supprimer toutes les images node
docker rmi $(docker image ls -q node)
```

#### Supprimer les images par filtre

```bash
# Supprimer les images sans tag (dangling)
docker rmi $(docker image ls -f "dangling=true" -q)

# Supprimer les images créées avant une certaine date
docker rmi $(docker image ls -f "before=nginx:latest" -q)
```

#### Supprimer sauf certaines images

```bash
# Supprimer toutes les images sauf nginx et ubuntu
docker image ls --format '{{.Repository}}:{{.Tag}}' | \
  grep -v -E 'nginx|ubuntu' | \
  xargs docker rmi
```

### Gestion des erreurs

#### Image référencée par un conteneur

```bash
# Erreur
docker rmi nginx
# Error: conflict: unable to remove repository reference

# Solution 1 : Arrêter et supprimer le conteneur
docker ps -a | grep nginx  # Trouver le conteneur
docker rm -f <container_id>
docker rmi nginx

# Solution 2 : Forcer (déconseillé)
docker rmi -f nginx
```

#### Image avec des images enfants

```bash
# Erreur
docker rmi ubuntu:22.04
# Error: conflict: unable to delete (must be forced) - image has dependent child images

# Solution : Supprimer d'abord les images enfants
docker image ls -a  # Identifier les images enfants
docker rmi <child_images>
docker rmi ubuntu:22.04
```

#### Espace disque non libéré immédiatement

> [!info] Layers partagés Si plusieurs images partagent des layers, la suppression d'une image ne libère que les layers qui lui sont uniques. Les layers partagés restent tant qu'une autre image les utilise.

```bash
# Vérifier l'espace disque utilisé
docker system df

# Analyser en détail
docker system df -v
```

---

## 🧹 Nettoyer les images inutilisées

### Commande de base

```bash
docker image prune
```

La commande `docker image prune` supprime automatiquement les images inutilisées (dangling images) pour libérer de l'espace disque.

> [!info] Qu'est-ce qu'une image "dangling" ? Une image dangling est une image sans tag (apparaît comme `<none>:<none>`). Elles sont créées lors de rebuilds ou quand un nouveau tag écrase un ancien.

### Options principales

```bash
# Nettoyer les images dangling (par défaut)
docker image prune

# Nettoyer TOUTES les images non utilisées par un conteneur
docker image prune -a

# Mode non-interactif (pas de confirmation)
docker image prune -f

# Combiner les options
docker image prune -a -f

# Filtrer par date
docker image prune -a --filter "until=24h"
docker image prune -a --filter "until=2024-01-01T00:00:00"
```

### Différence entre prune et prune -a

|Commande|Images supprimées|
|---|---|
|`docker image prune`|Uniquement les images dangling (`<none>:<none>`)|
|`docker image prune -a`|Toutes les images non utilisées par des conteneurs existants|

> [!warning] Attention avec -a `docker image prune -a` supprime **toutes** les images qui ne sont pas actuellement utilisées par un conteneur, même si elles ont des tags. Cela peut inclure des images que vous souhaitez conserver pour un usage ultérieur.

### Exemples pratiques

#### Nettoyage basique

```bash
# Supprimer uniquement les images dangling
docker image prune

# Sortie typique :
# WARNING! This will remove all dangling images.
# Are you sure you want to continue? [y/N] y
# Deleted Images:
# deleted: sha256:abc123...
# deleted: sha256:def456...
# Total reclaimed space: 1.2GB
```

#### Nettoyage complet automatisé

```bash
# Pour scripts ou automatisation
docker image prune -a -f
```

> [!tip] Cron job pour nettoyage automatique Ajoutez cette ligne à votre crontab pour nettoyer chaque nuit :
> 
> ```bash
> 0 2 * * * docker image prune -a -f > /var/log/docker-prune.log 2>&1
> ```

#### Nettoyage avec filtres temporels

```bash
# Supprimer les images non utilisées depuis plus de 24h
docker image prune -a --filter "until=24h"

# Supprimer les images créées il y a plus de 7 jours
docker image prune -a --filter "until=168h"

# Supprimer avant une date précise
docker image prune -a --filter "until=2024-01-01T00:00:00"
```

> [!example] Cas d'usage : nettoyage hebdomadaire
> 
> ```bash
> #!/bin/bash
> # Script de nettoyage hebdomadaire
> 
> echo "Nettoyage des images de plus d'une semaine..."
> docker image prune -a -f --filter "until=168h"
> 
> echo "Espace disque libéré :"
> docker system df
> ```

#### Nettoyage avec filtres de labels

```bash
# Supprimer les images avec un label spécifique
docker image prune --filter "label=environment=development"

# Supprimer les images sans un label spécifique
docker image prune --filter "label!=environment=production"
```

### Comprendre l'espace libéré

```bash
# Avant le nettoyage
docker system df

# Exemple de sortie :
# TYPE            TOTAL     ACTIVE    SIZE      RECLAIMABLE
# Images          25        10        5.4GB     3.2GB (59%)
# Containers      12        3         1.2GB     800MB (66%)
# Local Volumes   8         2         500MB     300MB (60%)

# Nettoyer
docker image prune -a -f

# Après le nettoyage
docker system df
```

### Stratégies de nettoyage

#### Développement local

```bash
# Nettoyage agressif hebdomadaire
docker image prune -a -f

# Garder seulement les images des 3 derniers jours
docker image prune -a -f --filter "until=72h"
```

#### Environnement CI/CD

```bash
# Nettoyer après chaque build
docker image prune -f

# Garder uniquement les images des builds du jour
docker image prune -a -f --filter "until=24h"
```

#### Serveur de production

```bash
# Nettoyage conservateur : seulement les dangling images
docker image prune -f

# Nettoyage mensuel des images anciennes
docker image prune -a -f --filter "until=720h"  # 30 jours
```

> [!tip] Bonne pratique : nettoyage régulier Configurez un nettoyage automatique adapté à votre contexte :
> 
> - **Dev local** : Hebdomadaire, agressif (`-a`)
> - **CI/CD** : Après chaque pipeline
> - **Production** : Mensuel, conservateur (sans `-a`)

### Alternatives et commandes connexes

```bash
# Nettoyer tout le système Docker (images, conteneurs, volumes, networks)
docker system prune

# Nettoyer tout avec volumes
docker system prune --volumes

# Nettoyer tout incluant les images non-dangling
docker system prune -a

# Afficher ce qui serait supprimé sans le faire
docker image prune --dry-run
```

> [!warning] Docker system prune -a --volumes Cette commande est **extrêmement destructive**. Elle supprime :
> 
> - Toutes les images non utilisées
> - Tous les conteneurs arrêtés
> - Tous les volumes non utilisés
> - Tous les networks non utilisés
> 
> **Utilisez-la uniquement si vous êtes absolument certain de vouloir tout nettoyer.**

### Surveiller l'utilisation de l'espace

```bash
# Vue d'ensemble
docker system df

# Vue détaillée
docker system df -v

# Surveiller en temps réel
watch -n 5 docker system df
```

---

## 🎯 Bonnes pratiques de gestion

### Organisation des images

> [!tip] Conventions de nommage
> 
> - Utilisez des tags significatifs : `myapp:1.0.0`, `myapp:dev`, `myapp:prod`
> - Évitez le tag `latest` en production
> - Incluez la date dans les tags de développement : `myapp:dev-20240115`

### Maintenance régulière

```bash
# Script de maintenance hebdomadaire
#!/bin/bash

echo "=== Nettoyage Docker hebdomadaire ==="

echo "Images avant nettoyage:"
docker system df

echo "Suppression des images dangling..."
docker image prune -f

echo "Suppression des images de plus de 7 jours non utilisées..."
docker image prune -a -f --filter "until=168h"

echo "Images après nettoyage:"
docker system df

echo "Espace libéré: $(docker system df | awk 'NR==2 {print $4}')"
```

### Surveillance de l'espace disque

> [!warning] Surveiller l'espace disque Docker peut rapidement consommer beaucoup d'espace. Configurez des alertes :
> 
> ```bash
> # Vérifier si plus de 80% d'espace est utilisé
> USAGE=$(docker system df | awk 'NR==2 {print $5}' | tr -d '%')
> if [ $USAGE -gt 80 ]; then
>     echo "Alerte: Espace Docker > 80%"
>     docker image prune -a -f
> fi
> ```

### Sécurité

> [!warning] Supprimer les images vulnérables
> 
> - Scannez régulièrement vos images avec `docker scan`
> - Supprimez les images avec des vulnérabilités critiques
> - Mettez à jour les images de base régulièrement

```bash
# Scanner une image pour des vulnérabilités
docker scan nginx:latest

# Supprimer une image vulnérable
docker rmi nginx:old-version

# Télécharger la dernière version
docker pull nginx:latest
```

---

## 📊 Récapitulatif des commandes

|Commande|Description|Usage typique|
|---|---|---|
|`docker image ls`|Liste les images|Consultation quotidienne|
|`docker image ls -a`|Liste toutes les images (avec intermédiaires)|Débogage|
|`docker image ls -q`|Liste uniquement les IDs|Scripts|
|`docker inspect <image>`|Détails complets d'une image|Investigation approfondie|
|`docker inspect --format`|Extraction ciblée d'information|Automatisation|
|`docker rmi <image>`|Supprime une image|Nettoyage ponctuel|
|`docker rmi -f <image>`|Force la suppression|Cas exceptionnels|
|`docker image prune`|Supprime les images dangling|Maintenance régulière|
|`docker image prune -a`|Supprime toutes images non utilisées|Grand nettoyage|
|`docker image prune --filter`|Nettoyage avec critères|Automatisation avancée|

---

## 💡 Astuces finales

### Aliases utiles

Ajoutez ces aliases dans votre `.bashrc` ou `.zshrc` :

```bash
# Lister les images de manière compacte
alias dils='docker image ls --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}"'

# Nettoyer rapidement
alias diclean='docker image prune -a -f'

# Voir l'utilisation d'espace
alias didf='docker system df'

# Supprimer les images dangling
alias diprune='docker image prune -f'
```

### Vérification avant suppression

> [!tip] Toujours vérifier avant de supprimer
> 
> ```bash
> # Voir ce qui serait supprimé
> docker image ls --filter "dangling=true"
> 
> # Vérifier l'espace qui sera libéré
> docker system df
> 
> # Puis seulement après, supprimer
> docker image prune -f
> ```

### Optimisation du stockage

```bash
# Passer à overlay2 si ce n'est pas déjà le cas (meilleure performance)
docker info | grep "Storage Driver"

# Configurer la rotation des logs
# Dans /etc/docker/daemon.json :
{
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "10m",
    "max-file": "3"
  }
}
```

---

> [!success] Vous maîtrisez maintenant la gestion des images Docker locales ! Ces commandes vous permettent de maintenir un environnement Docker propre, optimisé et sous contrôle. La clé est d'adopter une routine de nettoyage régulière adaptée à votre contexte d'utilisation.