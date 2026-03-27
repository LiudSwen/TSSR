

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

La gestion des réseaux Docker est essentielle pour contrôler la communication entre conteneurs et avec l'extérieur. Docker fournit quatre commandes principales pour gérer les réseaux : lister, créer, inspecter et supprimer.

> [!info] Pourquoi gérer les réseaux ?
> 
> - Isoler les conteneurs par environnement (dev, staging, prod)
> - Contrôler finement la communication inter-conteneurs
> - Organiser l'architecture réseau de vos applications
> - Déboguer les problèmes de connectivité

---

## 📜 docker network ls

### Description

Liste tous les réseaux Docker disponibles sur votre système. C'est la commande de base pour avoir une vue d'ensemble de votre infrastructure réseau.

### Syntaxe

```bash
docker network ls [OPTIONS]
```

### Options principales

|Option|Description|Exemple|
|---|---|---|
|`-f, --filter`|Filtre les résultats|`--filter driver=bridge`|
|`-q, --quiet`|Affiche uniquement les IDs|`docker network ls -q`|
|`--format`|Formate la sortie|`--format "{{.Name}}: {{.Driver}}"`|
|`--no-trunc`|Affiche les IDs complets|`docker network ls --no-trunc`|

### Exemples pratiques

```bash
# Lister tous les réseaux
docker network ls

# Lister uniquement les réseaux bridge
docker network ls --filter driver=bridge

# Lister avec format personnalisé
docker network ls --format "table {{.Name}}\t{{.Driver}}\t{{.Scope}}"

# Obtenir uniquement les IDs
docker network ls -q

# Filtrer par nom (regex)
docker network ls --filter name=mon-reseau
```

### Sortie type

```
NETWORK ID     NAME              DRIVER    SCOPE
3f8b5c9d1a2e   bridge            bridge    local
7a2d4e6f8b1c   host              host      local
9e3c7b2a5d8f   none              null      local
a1b2c3d4e5f6   mon-reseau-app    bridge    local
```

> [!tip] Astuce - Surveillance rapide Utilisez `docker network ls --format "{{.Name}}"` pour obtenir une liste propre des noms de réseaux, pratique pour des scripts.

> [!example] Cas d'usage réel Avant de créer un nouveau réseau, vérifiez toujours qu'il n'existe pas déjà avec `docker network ls --filter name=nom-recherche` pour éviter les conflits.

---

## 🏗️ docker network create

### Description

Crée un nouveau réseau Docker personnalisé. C'est la commande clé pour segmenter votre architecture et contrôler la communication entre conteneurs.

### Syntaxe

```bash
docker network create [OPTIONS] NETWORK_NAME
```

### Options principales

|Option|Description|Exemple|
|---|---|---|
|`-d, --driver`|Spécifie le driver réseau|`--driver bridge`|
|`--subnet`|Définit la plage d'adresses IP|`--subnet 172.20.0.0/16`|
|`--gateway`|Définit l'adresse de la passerelle|`--gateway 172.20.0.1`|
|`--ip-range`|Plage IP pour les conteneurs|`--ip-range 172.20.10.0/24`|
|`--label`|Ajoute des métadonnées|`--label env=production`|
|`--internal`|Réseau sans accès externe|`--internal`|
|`--attachable`|Permet l'attachement manuel|`--attachable`|

### Types de drivers

|Driver|Usage|Cas d'utilisation|
|---|---|---|
|`bridge`|Réseau isolé sur un hôte|Applications multi-conteneurs sur une machine|
|`host`|Utilise le réseau de l'hôte|Performance maximale, pas d'isolation|
|`overlay`|Réseau multi-hôtes (Swarm)|Applications distribuées sur plusieurs machines|
|`macvlan`|Assigne une adresse MAC|Conteneurs comme machines physiques|
|`none`|Aucun réseau|Conteneurs complètement isolés|

### Exemples pratiques

```bash
# Créer un réseau bridge simple
docker network create mon-reseau

# Créer un réseau avec subnet personnalisé
docker network create --subnet 172.25.0.0/16 --gateway 172.25.0.1 reseau-custom

# Créer un réseau interne (sans accès Internet)
docker network create --internal reseau-securise

# Créer un réseau avec plage IP limitée
docker network create \
  --subnet 10.0.0.0/24 \
  --ip-range 10.0.0.128/25 \
  --gateway 10.0.0.1 \
  reseau-limite

# Créer un réseau avec labels pour l'organisation
docker network create \
  --label projet=webapp \
  --label env=production \
  reseau-prod

# Créer un réseau overlay (pour Docker Swarm)
docker network create --driver overlay --attachable reseau-swarm
```

> [!warning] Attention aux conflits de subnet Assurez-vous que le subnet choisi ne chevauche pas avec d'autres réseaux existants (Docker ou système). Utilisez `docker network inspect` pour vérifier les subnets en cours d'utilisation.

> [!tip] Astuce - Nommage cohérent Adoptez une convention de nommage claire : `projet-environnement-type` (ex: `webapp-prod-backend`) pour faciliter la gestion de nombreux réseaux.

> [!info] Réseau par défaut Si vous n'utilisez pas `--driver`, Docker crée automatiquement un réseau bridge. C'est suffisant pour 90% des cas d'usage simples.

---

## 🔍 docker network inspect

### Description

Affiche des informations détaillées sur un ou plusieurs réseaux Docker. C'est l'outil indispensable pour le débogage et la compréhension de votre architecture réseau.

### Syntaxe

```bash
docker network inspect [OPTIONS] NETWORK [NETWORK...]
```

### Options principales

|Option|Description|Exemple|
|---|---|---|
|`-f, --format`|Formate la sortie avec Go templates|`--format '{{.IPAM.Config}}'`|
|`-v, --verbose`|Affiche plus d'informations|`docker network inspect -v`|

### Informations retournées

Le format JSON retourné contient :

- **Name** : Nom du réseau
- **Id** : Identifiant unique
- **Driver** : Type de driver utilisé
- **Scope** : Portée (local, swarm, global)
- **IPAM** : Configuration IP (subnet, gateway)
- **Containers** : Conteneurs connectés avec leurs IPs
- **Options** : Options spécifiques au driver
- **Labels** : Métadonnées personnalisées

### Exemples pratiques

```bash
# Inspecter un réseau complet
docker network inspect mon-reseau

# Obtenir uniquement le subnet
docker network inspect mon-reseau --format '{{range .IPAM.Config}}{{.Subnet}}{{end}}'

# Obtenir la gateway
docker network inspect mon-reseau --format '{{range .IPAM.Config}}{{.Gateway}}{{end}}'

# Lister les conteneurs connectés
docker network inspect mon-reseau --format '{{range $k, $v := .Containers}}{{$k}} {{end}}'

# Obtenir les IPs des conteneurs
docker network inspect mon-reseau \
  --format '{{range $k, $v := .Containers}}{{$v.Name}}: {{$v.IPv4Address}}{{"\n"}}{{end}}'

# Inspecter plusieurs réseaux en une fois
docker network inspect bridge host none

# Vérifier si un réseau est interne
docker network inspect mon-reseau --format '{{.Internal}}'

# Extraire le driver utilisé
docker network inspect mon-reseau --format '{{.Driver}}'
```

### Exemple de sortie JSON

```json
[
    {
        "Name": "mon-reseau",
        "Id": "a1b2c3d4e5f6...",
        "Driver": "bridge",
        "IPAM": {
            "Config": [
                {
                    "Subnet": "172.20.0.0/16",
                    "Gateway": "172.20.0.1"
                }
            ]
        },
        "Containers": {
            "abc123": {
                "Name": "webapp",
                "IPv4Address": "172.20.0.2/16"
            }
        }
    }
]
```

> [!tip] Astuce - Débogage réseau Combinez `docker network inspect` avec `docker inspect <container>` pour tracer complètement les configurations réseau de vos conteneurs et identifier les problèmes de connectivité.

> [!example] Cas d'usage - Vérification avant connexion Avant de connecter un conteneur à un réseau, inspectez le réseau pour vous assurer qu'il a la bonne configuration (subnet, gateway) et qu'il n'est pas saturé de conteneurs.

> [!info] Format Go templates Les templates Go permettent des requêtes complexes. Consultez la documentation Go pour des filtres avancés : `.Containers | length` pour compter les conteneurs, par exemple.

---

## 🗑️ docker network rm

### Description

Supprime un ou plusieurs réseaux Docker. Attention, cette opération est irréversible et ne peut être effectuée que sur des réseaux sans conteneurs connectés.

### Syntaxe

```bash
docker network rm NETWORK [NETWORK...]
```

### Comportement

- Supprime définitivement le réseau
- Impossible si des conteneurs y sont encore connectés
- Les réseaux prédéfinis (bridge, host, none) ne peuvent pas être supprimés
- Peut supprimer plusieurs réseaux en une seule commande

### Exemples pratiques

```bash
# Supprimer un réseau
docker network rm mon-reseau

# Supprimer plusieurs réseaux
docker network rm reseau1 reseau2 reseau3

# Supprimer tous les réseaux non utilisés (DANGER)
docker network prune

# Supprimer avec confirmation interactive
docker network prune

# Forcer la suppression après déconnexion des conteneurs
# 1. Déconnecter tous les conteneurs
docker network disconnect mon-reseau container1
docker network disconnect mon-reseau container2
# 2. Supprimer le réseau
docker network rm mon-reseau

# Supprimer tous les réseaux inutilisés sans confirmation
docker network prune -f

# Supprimer les réseaux créés il y a plus de 24h
docker network prune --filter "until=24h"
```

> [!warning] Erreur courante - Conteneurs connectés Si vous obtenez l'erreur "network has active endpoints", des conteneurs sont encore connectés. Utilisez `docker network inspect` pour les identifier, puis déconnectez-les ou arrêtez-les avant suppression.

> [!warning] docker network prune - À utiliser avec précaution La commande `docker network prune` supprime TOUS les réseaux non utilisés. En production, préférez la suppression manuelle réseau par réseau pour éviter les mauvaises surprises.

> [!tip] Astuce - Nettoyage de développement En environnement de développement local, `docker network prune -f` est très pratique pour faire un nettoyage rapide après des tests. En production, évitez cette commande.

> [!example] Script de nettoyage sécurisé
> 
> ```bash
> # Lister les réseaux custom non utilisés
> docker network ls --filter "type=custom" --format "{{.Name}}" | \
> while read network; do
>   containers=$(docker network inspect "$network" \
>     --format '{{len .Containers}}')
>   if [ "$containers" -eq 0 ]; then
>     echo "Suppression de $network"
>     docker network rm "$network"
>   fi
> done
> ```

---

## ⚠️ Pièges courants

### 1. Oublier de vérifier les conteneurs connectés

```bash
# ❌ Mauvais
docker network rm mon-reseau
# Error: network has active endpoints

# ✅ Bon
docker network inspect mon-reseau --format '{{len .Containers}}'
# Si > 0, déconnectez d'abord les conteneurs
```

### 2. Conflits de subnet

```bash
# ❌ Mauvais - Peut créer des conflits
docker network create --subnet 172.17.0.0/16 mon-reseau
# Ce subnet est souvent utilisé par le bridge par défaut

# ✅ Bon - Utiliser un subnet différent
docker network create --subnet 172.25.0.0/16 mon-reseau
```

### 3. Oublier de spécifier le réseau lors du lancement

```bash
# ❌ Mauvais - Utilise le réseau par défaut
docker run -d nginx

# ✅ Bon - Spécifie explicitement le réseau
docker run -d --network mon-reseau nginx
```

### 4. Supprimer des réseaux en production sans vérification

```bash
# ❌ Dangereux en production
docker network prune -f

# ✅ Bon - Vérifier d'abord
docker network ls --filter "type=custom"
docker network inspect <chaque-reseau>
# Puis supprimer manuellement après vérification
```

### 5. Ne pas nommer ses réseaux personnalisés

```bash
# ❌ Moins pratique - ID difficile à retenir
docker network create 7a2d4e6f8b1c

# ✅ Bon - Nom explicite
docker network create webapp-backend
```

---

## ✅ Bonnes pratiques

### 1. Convention de nommage cohérente

```bash
# Adoptez un schéma : projet-environnement-composant
docker network create webapp-prod-frontend
docker network create webapp-prod-backend
docker network create webapp-dev-all
```

### 2. Utiliser des labels pour l'organisation

```bash
docker network create \
  --label projet=ecommerce \
  --label env=production \
  --label maintainer=team-devops \
  ecommerce-prod-api
```

### 3. Documenter les subnets

```bash
# Gardez une trace de vos allocations de subnet
# 172.20.0.0/16 - Projet WebApp Production
# 172.21.0.0/16 - Projet WebApp Staging
# 172.22.0.0/16 - Projet API Production

docker network create --subnet 172.20.0.0/16 webapp-prod
```

### 4. Isoler les environnements

```bash
# Un réseau par environnement
docker network create webapp-dev
docker network create webapp-staging
docker network create webapp-prod
```

### 5. Vérifier avant de créer

```bash
# Toujours vérifier l'existence
if docker network ls --format '{{.Name}}' | grep -q "^mon-reseau$"; then
  echo "Le réseau existe déjà"
else
  docker network create mon-reseau
fi
```

### 6. Nettoyer régulièrement en développement

```bash
# Script de nettoyage hebdomadaire en dev
# (À NE PAS utiliser en production)
docker network prune -f
docker system prune --volumes -f
```

### 7. Inspecter avant de connecter

```bash
# Vérifier la configuration avant d'ajouter un conteneur
docker network inspect mon-reseau --format '{{range .IPAM.Config}}{{.Subnet}}{{end}}'
docker run -d --network mon-reseau --name app nginx
```

### 8. Utiliser des réseaux internes pour la sécurité

```bash
# Base de données sans accès Internet
docker network create --internal db-network
docker run -d --network db-network --name postgres postgres:15
```

---

> [!tip] 💡 Résumé des commandes essentielles
> 
> ```bash
> # Vue d'ensemble
> docker network ls
> 
> # Création standard
> docker network create mon-reseau
> 
> # Inspection détaillée
> docker network inspect mon-reseau
> 
> # Suppression propre
> docker network rm mon-reseau
> 
> # Nettoyage global (dev uniquement)
> docker network prune -f
> ```