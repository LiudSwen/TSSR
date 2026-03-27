

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

## 🎯 Introduction

Par défaut, toutes les données créées à l'intérieur d'un conteneur sont **éphémères** : elles disparaissent lorsque le conteneur est supprimé. Pour persister les données au-delà du cycle de vie d'un conteneur, Docker propose trois mécanismes de stockage distincts.

> [!info] Pourquoi la persistance est-elle importante ?
> 
> - Sauvegarder les données des bases de données
> - Partager des fichiers entre conteneurs
> - Conserver les logs et configurations
> - Développer avec du code source monté en temps réel

---

## 📦 Types de stockage

### 🗄️ Volumes

Les **volumes** sont le mécanisme recommandé par Docker pour persister les données. Ils sont entièrement gérés par Docker et stockés dans une partie du système de fichiers de l'hôte (`/var/lib/docker/volumes/` sur Linux).

#### Pourquoi utiliser les volumes ?

- ✅ Gérés complètement par Docker
- ✅ Fonctionnent sur Linux, Windows et macOS
- ✅ Plus sûrs : isolés du système hôte
- ✅ Faciles à sauvegarder et migrer
- ✅ Peuvent être partagés entre plusieurs conteneurs
- ✅ Meilleure performance que les bind mounts sur Windows et macOS

#### Syntaxe et commandes

**Créer un volume :**

```bash
# Créer un volume nommé
docker volume create mon_volume

# Lister tous les volumes
docker volume ls

# Inspecter un volume
docker volume inspect mon_volume

# Supprimer un volume
docker volume rm mon_volume

# Supprimer tous les volumes non utilisés
docker volume prune
```

**Utiliser un volume avec un conteneur :**

```bash
# Méthode 1 : Option -v (ancienne syntaxe)
docker run -d \
  --name mon_conteneur \
  -v mon_volume:/chemin/dans/conteneur \
  image_name

# Méthode 2 : Option --mount (syntaxe recommandée)
docker run -d \
  --name mon_conteneur \
  --mount source=mon_volume,target=/chemin/dans/conteneur \
  image_name

# Volume anonyme (créé automatiquement)
docker run -d \
  -v /chemin/dans/conteneur \
  image_name
```

> [!example] Exemple pratique : Base de données PostgreSQL
> 
> ```bash
> # Créer un volume pour PostgreSQL
> docker volume create postgres_data
> 
> # Lancer PostgreSQL avec persistance
> docker run -d \
>   --name ma_bdd \
>   -e POSTGRES_PASSWORD=monmotdepasse \
>   --mount source=postgres_data,target=/var/lib/postgresql/data \
>   postgres:15
> 
> # Les données survivent même si on supprime le conteneur
> docker rm -f ma_bdd
> 
> # On peut recréer un nouveau conteneur avec les mêmes données
> docker run -d \
>   --name ma_bdd_v2 \
>   -e POSTGRES_PASSWORD=monmotdepasse \
>   --mount source=postgres_data,target=/var/lib/postgresql/data \
>   postgres:15
> ```

#### Options avancées des volumes

```bash
# Volume en lecture seule
docker run -d \
  --mount source=mon_volume,target=/data,readonly \
  image_name

# Volume avec un driver spécifique
docker volume create --driver local \
  --opt type=nfs \
  --opt o=addr=192.168.1.1,rw \
  --opt device=:/path/to/dir \
  nfs_volume
```

> [!tip] Astuce : Pré-remplir un volume Si un volume vide est monté sur un répertoire qui contient déjà des fichiers dans l'image Docker, Docker copiera automatiquement le contenu de l'image dans le volume lors de la première utilisation.

---

### 🔗 Bind mounts

Les **bind mounts** permettent de monter un répertoire ou un fichier du système hôte directement dans le conteneur. Le chemin complet doit être spécifié.

#### Pourquoi utiliser les bind mounts ?

- ✅ Accès direct aux fichiers de l'hôte
- ✅ Idéal pour le développement (hot reload)
- ✅ Partage de fichiers de configuration
- ⚠️ Dépend de la structure du système hôte
- ⚠️ Moins portable que les volumes
- ⚠️ Risques de sécurité (accès au système hôte)

#### Syntaxe et commandes

```bash
# Méthode 1 : Option -v avec chemin absolu
docker run -d \
  -v /chemin/absolu/sur/hote:/chemin/dans/conteneur \
  image_name

# Méthode 2 : Option --mount (recommandée)
docker run -d \
  --mount type=bind,source=/chemin/absolu/sur/hote,target=/chemin/dans/conteneur \
  image_name

# Bind mount en lecture seule
docker run -d \
  -v /chemin/sur/hote:/chemin/dans/conteneur:ro \
  image_name

# Ou avec --mount
docker run -d \
  --mount type=bind,source=/chemin/sur/hote,target=/chemin/dans/conteneur,readonly \
  image_name
```

> [!example] Exemple pratique : Développement web
> 
> ```bash
> # Monter le code source pour le développement
> docker run -d \
>   --name dev_app \
>   -p 3000:3000 \
>   -v $(pwd)/src:/app/src \
>   -v $(pwd)/public:/app/public \
>   node:18 \
>   npm run dev
> 
> # Les modifications dans src/ et public/ sont immédiatement visibles
> # dans le conteneur grâce au hot reload
> ```

> [!warning] Attention aux chemins relatifs Avec `-v`, les chemins relatifs sont résolus par Docker. Avec `--mount`, seuls les chemins absolus sont acceptés (plus sûr).
> 
> ```bash
> # Avec -v : relatif possible mais déconseillé
> docker run -v ./data:/app/data image_name
> 
> # Avec --mount : chemin absolu obligatoire
> docker run --mount type=bind,source="$(pwd)/data",target=/app/data image_name
> ```

#### Options spécifiques aux bind mounts

```bash
# Propagation du bind mount (pour les sous-montages)
docker run -d \
  --mount type=bind,source=/chemin,target=/data,bind-propagation=shared \
  image_name

# Consistency (macOS/Windows seulement)
docker run -d \
  -v /chemin:/data:cached \
  image_name
# Options : consistent (par défaut), cached (lecture optimisée), delegated (écriture optimisée)
```

---

### 💾 tmpfs

Les **tmpfs mounts** créent un système de fichiers temporaire en mémoire RAM. Les données ne sont jamais écrites sur le disque et disparaissent à l'arrêt du conteneur.

#### Pourquoi utiliser tmpfs ?

- ✅ Performances maximales (RAM)
- ✅ Sécurité : données jamais écrites sur disque
- ✅ Idéal pour les données temporaires sensibles
- ⚠️ Limité à Linux
- ⚠️ Consomme de la RAM
- ⚠️ Données perdues à l'arrêt du conteneur

#### Cas d'usage typiques

- Caches temporaires
- Fichiers de session
- Données sensibles (tokens, mots de passe temporaires)
- Sockets Unix
- Fichiers de verrouillage (lock files)

#### Syntaxe et commandes

```bash
# Option --tmpfs (syntaxe simple)
docker run -d \
  --tmpfs /chemin/dans/conteneur \
  image_name

# Option --mount (syntaxe complète)
docker run -d \
  --mount type=tmpfs,target=/chemin/dans/conteneur \
  image_name

# Limiter la taille du tmpfs
docker run -d \
  --tmpfs /app/tmp:rw,size=100m,mode=1777 \
  image_name

# Ou avec --mount
docker run -d \
  --mount type=tmpfs,target=/app/tmp,tmpfs-size=104857600,tmpfs-mode=1777 \
  image_name
```

> [!example] Exemple pratique : Application avec cache temporaire
> 
> ```bash
> # Application web avec cache en mémoire
> docker run -d \
>   --name web_app \
>   -p 8080:80 \
>   --mount type=tmpfs,target=/tmp,tmpfs-size=536870912 \
>   --mount type=tmpfs,target=/var/cache/nginx \
>   nginx:alpine
> 
> # Le cache Nginx est en RAM pour des performances optimales
> # Limite de 512 Mo pour /tmp
> ```

#### Options tmpfs

```bash
# Taille maximale (en octets)
tmpfs-size=104857600  # 100 Mo

# Permissions (format octal)
tmpfs-mode=1777       # rwxrwxrwt

# Lecture seule (rare pour tmpfs)
readonly
```

> [!tip] Astuce : Surveiller l'utilisation de la RAM
> 
> ```bash
> # Voir la consommation mémoire du conteneur
> docker stats mon_conteneur
> 
> # Les tmpfs apparaissent dans la mémoire utilisée
> ```

---

## ⚖️ Comparaison des types de stockage

|Critère|Volumes|Bind mounts|tmpfs|
|---|---|---|---|
|**Gestion**|Par Docker|Par l'utilisateur|Par Docker|
|**Emplacement**|`/var/lib/docker/volumes/`|N'importe où sur l'hôte|RAM|
|**Portabilité**|✅ Excellente|⚠️ Dépend de l'hôte|⚠️ Linux uniquement|
|**Performance**|✅ Bonne|✅ Bonne (⚠️ macOS/Win)|✅✅ Excellente|
|**Persistance**|✅ Persistant|✅ Persistant|❌ Éphémère|
|**Partage multi-conteneurs**|✅ Facile|✅ Possible|❌ Non|
|**Backup**|✅ Facile avec Docker|⚠️ Manuel|❌ Non applicable|
|**Sécurité**|✅ Isolé|⚠️ Accès système hôte|✅ Isolé|
|**Cas d'usage**|Production, BDD|Développement, config|Cache, données temporaires|

> [!info] Recommandation générale
> 
> - **Production** : Utilisez des **volumes**
> - **Développement** : Utilisez des **bind mounts** pour le hot reload
> - **Données temporaires** : Utilisez **tmpfs**

---

## ⚠️ Pièges courants

### 1. Oublier de nommer les volumes

```bash
# ❌ Volume anonyme (difficile à gérer)
docker run -v /data mysql

# ✅ Volume nommé (recommandé)
docker run -v mysql_data:/data mysql
```

Les volumes anonymes s'accumulent et sont difficiles à identifier. Utilisez toujours des noms explicites.

### 2. Confusion entre -v et --mount

```bash
# Avec -v : si la source n'existe pas, Docker crée un répertoire
docker run -v /chemin/inexistant:/data image_name

# Avec --mount : erreur si la source n'existe pas (plus sûr)
docker run --mount type=bind,source=/chemin/inexistant,target=/data image_name
# Error: invalid mount config for type "bind": bind source path does not exist
```

> [!tip] Préférez --mount La syntaxe `--mount` est plus verbeuse mais plus explicite et sûre.

### 3. Problèmes de permissions

```bash
# ❌ Le processus dans le conteneur n'a pas les droits
docker run -v $(pwd)/data:/data nginx  # nginx tourne souvent en tant que www-data

# ✅ Solution 1 : Ajuster les permissions sur l'hôte
chmod -R 755 ./data
chown -R 33:33 ./data  # UID:GID de www-data

# ✅ Solution 2 : Utiliser un volume géré par Docker
docker run -v nginx_data:/data nginx
```

### 4. Oublier de nettoyer les volumes

```bash
# Les volumes persistent même après la suppression du conteneur
docker rm mon_conteneur  # Le volume associé reste

# ✅ Supprimer le conteneur ET son volume anonyme
docker rm -v mon_conteneur

# ✅ Nettoyer tous les volumes inutilisés
docker volume prune
```

### 5. Monter des volumes trop larges

```bash
# ❌ Monter tout le répertoire home (lent, risqué)
docker run -v /home/user:/data image_name

# ✅ Monter uniquement ce qui est nécessaire
docker run -v /home/user/project:/data image_name
```

---

## 🎯 Bonnes pratiques

### 1. Nommez vos volumes de manière descriptive

```bash
# ✅ Noms explicites avec préfixe du projet
docker volume create monprojet_postgres_data
docker volume create monprojet_redis_cache
docker volume create monprojet_uploads
```

### 2. Utilisez des volumes pour la production

```bash
# ✅ Base de données en production
docker run -d \
  --name prod_db \
  -e POSTGRES_PASSWORD=secure_password \
  --mount source=prod_postgres_data,target=/var/lib/postgresql/data \
  --restart unless-stopped \
  postgres:15
```

### 3. Utilisez bind mounts pour le développement

```bash
# ✅ Développement avec hot reload
docker run -d \
  --name dev_api \
  -v $(pwd):/app \
  -v /app/node_modules \  # Volume anonyme pour éviter d'écraser node_modules
  -p 3000:3000 \
  node:18 \
  npm run dev
```

### 4. Séparez les données sensibles

```bash
# ✅ Secrets en tmpfs (jamais écrits sur disque)
docker run -d \
  --mount type=tmpfs,target=/run/secrets \
  --mount source=app_data,target=/data \
  myapp
```

### 5. Documentez vos volumes dans docker-compose.yml

```yaml
version: '3.8'

services:
  db:
    image: postgres:15
    volumes:
      - postgres_data:/var/lib/postgresql/data  # Volume nommé
      - ./init.sql:/docker-entrypoint-initdb.d/init.sql:ro  # Bind mount lecture seule
    tmpfs:
      - /tmp  # tmpfs pour fichiers temporaires

volumes:
  postgres_data:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /chemin/sur/hote/postgres_data  # Optionnel : spécifier l'emplacement
```

### 6. Sauvegardez régulièrement vos volumes

```bash
# Backup d'un volume
docker run --rm \
  -v mon_volume:/source:ro \
  -v $(pwd):/backup \
  alpine \
  tar czf /backup/backup-$(date +%Y%m%d).tar.gz -C /source .

# Restore d'un volume
docker run --rm \
  -v mon_volume:/target \
  -v $(pwd):/backup \
  alpine \
  tar xzf /backup/backup-20241225.tar.gz -C /target
```

### 7. Limitez la taille des tmpfs

```bash
# ✅ Toujours spécifier une limite pour tmpfs
docker run -d \
  --mount type=tmpfs,target=/tmp,tmpfs-size=1073741824 \  # 1 Go max
  myapp
```

### 8. Utilisez des volumes drivers pour des besoins avancés

```bash
# Volume sur NFS pour partage entre serveurs
docker volume create \
  --driver local \
  --opt type=nfs \
  --opt o=addr=192.168.1.10,rw,nolock \
  --opt device=:/shared/data \
  nfs_shared_data

# Volume chiffré (nécessite un plugin)
docker volume create \
  --driver vieux/gluster \
  --opt servers=server1:server2 \
  --opt volname=myvolume \
  encrypted_volume
```

---

> [!tip] Résumé rapide
> 
> - **Volumes** : Le choix par défaut pour la persistance (production)
> - **Bind mounts** : Pour le développement et le partage de fichiers spécifiques
> - **tmpfs** : Pour les données temporaires sensibles et les performances maximales
> 
> Privilégiez toujours la syntaxe `--mount` pour plus de clarté et de sécurité !