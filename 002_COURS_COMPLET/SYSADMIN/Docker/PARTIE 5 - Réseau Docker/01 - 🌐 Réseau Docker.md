

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

## Introduction aux réseaux Docker

Le réseau Docker permet aux conteneurs de communiquer entre eux et avec le monde extérieur. Par défaut, Docker crée automatiquement trois réseaux lors de son installation, chacun ayant des caractéristiques et des cas d'usage spécifiques.

> [!info] Pourquoi les réseaux Docker sont importants Les réseaux Docker permettent d'isoler les conteneurs, de contrôler la communication entre eux, et de gérer l'exposition des services. Un bon choix de réseau améliore la sécurité et les performances de vos applications conteneurisées.

### Commandes de base pour gérer les réseaux

```bash
# Lister tous les réseaux
docker network ls

# Inspecter un réseau spécifique
docker network inspect <nom_réseau>

# Créer un nouveau réseau
docker network create <nom_réseau>

# Supprimer un réseau
docker network rm <nom_réseau>

# Connecter un conteneur à un réseau
docker network connect <nom_réseau> <nom_conteneur>

# Déconnecter un conteneur d'un réseau
docker network disconnect <nom_réseau> <nom_conteneur>
```

---

## Bridge Network

### 🔍 Qu'est-ce que c'est ?

Le réseau **bridge** est le réseau par défaut utilisé par Docker. Il crée un réseau virtuel privé isolé sur l'hôte, permettant aux conteneurs connectés à ce réseau de communiquer entre eux. C'est un réseau de type "pont" qui connecte les conteneurs à l'hôte via une interface réseau virtuelle.

> [!tip] Réseau par défaut Si vous ne spécifiez pas de réseau lors du lancement d'un conteneur avec `docker run`, il sera automatiquement attaché au réseau bridge par défaut nommé `bridge`.

### 📊 Caractéristiques principales

- **Isolation** : Les conteneurs sur un réseau bridge sont isolés du réseau de l'hôte
- **Communication inter-conteneurs** : Les conteneurs peuvent communiquer entre eux via leurs adresses IP
- **DNS automatique** : Sur les réseaux bridge personnalisés, Docker fournit une résolution DNS automatique par nom de conteneur
- **Port mapping** : Nécessite un mapping de ports pour exposer les services à l'extérieur

### 💡 Quand l'utiliser ?

- Applications multi-conteneurs qui doivent communiquer entre elles sur une même machine
- Développement local et tests
- Quand vous avez besoin d'isoler les conteneurs du réseau de l'hôte
- Applications nécessitant un contrôle fin sur les ports exposés

### 🛠️ Utilisation pratique

#### Réseau bridge par défaut

```bash
# Lancer un conteneur sur le réseau bridge par défaut
docker run -d --name webapp nginx

# Le conteneur est automatiquement sur le réseau "bridge"
docker inspect webapp | grep NetworkMode
```

> [!warning] Limitation du réseau bridge par défaut Sur le réseau bridge par défaut, les conteneurs ne peuvent pas se résoudre par leur nom. Ils doivent utiliser les adresses IP ou être liés via `--link` (méthode obsolète).

#### Créer un réseau bridge personnalisé

```bash
# Créer un réseau bridge personnalisé
docker network create --driver bridge mon_reseau_app

# Lancer des conteneurs sur ce réseau
docker run -d --name database --network mon_reseau_app postgres
docker run -d --name backend --network mon_reseau_app node:14

# Les conteneurs peuvent maintenant communiquer par leur nom
# Par exemple, backend peut se connecter à "database:5432"
```

> [!example] Exemple pratique avec résolution DNS
> 
> ```bash
> # Créer un réseau personnalisé
> docker network create app_network
> 
> # Lancer une base de données
> docker run -d --name db --network app_network \
>   -e POSTGRES_PASSWORD=secret postgres
> 
> # Lancer une application web qui se connecte à la BDD
> docker run -d --name web --network app_network \
>   -e DATABASE_URL=postgresql://db:5432/mydb \
>   -p 8080:80 myapp
> 
> # L'application peut se connecter à "db" directement
> ```

#### Configuration avancée

```bash
# Créer un réseau avec un sous-réseau spécifique
docker network create --driver bridge \
  --subnet=172.20.0.0/16 \
  --ip-range=172.20.240.0/20 \
  --gateway=172.20.0.1 \
  mon_reseau_custom

# Lancer un conteneur avec une IP statique
docker run -d --name app \
  --network mon_reseau_custom \
  --ip 172.20.0.10 \
  nginx
```

### ⚠️ Pièges courants

1. **Oublier de mapper les ports** : Les conteneurs sur un réseau bridge ne sont pas accessibles depuis l'extérieur sans mapping de ports
    
    ```bash
    # ❌ Incorrect - le service n'est pas accessible
    docker run -d --name web nginx
    
    # ✅ Correct - mapping du port
    docker run -d --name web -p 8080:80 nginx
    ```
    
2. **Utiliser le réseau bridge par défaut pour des applications complexes** : Préférez toujours un réseau bridge personnalisé pour bénéficier de la résolution DNS
    
3. **Ne pas nettoyer les réseaux inutilisés** : Les réseaux personnalisés persistent après l'arrêt des conteneurs
    
    ```bash
    # Nettoyer les réseaux non utilisés
    docker network prune
    ```
    

### ✨ Bonnes pratiques

- **Créez des réseaux dédiés par application** : Cela améliore l'isolation et la sécurité
- **Utilisez la résolution DNS** : Nommez vos conteneurs de manière descriptive pour faciliter la communication
- **Documentez vos mappings de ports** : Gardez une trace des ports exposés pour éviter les conflits
- **Limitez l'exposition** : N'exposez que les ports strictement nécessaires

---

## Host Network

### 🔍 Qu'est-ce que c'est ?

Le réseau **host** supprime l'isolation réseau entre le conteneur et l'hôte Docker. Le conteneur partage directement la pile réseau de l'hôte, ce qui signifie qu'il utilise directement l'interface réseau de la machine hôte sans virtualisation.

> [!warning] Pas d'isolation réseau Avec le réseau host, le conteneur n'a pas sa propre adresse IP. Il utilise directement celle de l'hôte et tous les ports ouverts dans le conteneur sont directement accessibles sur l'hôte.

### 📊 Caractéristiques principales

- **Performance maximale** : Pas de surcharge due à la traduction d'adresses (NAT)
- **Pas d'isolation** : Le conteneur voit toutes les interfaces réseau de l'hôte
- **Pas de mapping de ports** : Les ports du conteneur sont directement ceux de l'hôte
- **Accès complet** : Le conteneur peut voir et utiliser tous les services réseau de l'hôte

### 💡 Quand l'utiliser ?

- Applications nécessitant des performances réseau maximales
- Services qui doivent gérer un grand nombre de ports dynamiques
- Outils de monitoring et de diagnostic réseau
- Applications qui ont besoin d'accéder directement au réseau de l'hôte (rare)

> [!info] Disponibilité limitée Le mode réseau host fonctionne uniquement sur Linux. Sur Docker Desktop (Windows/Mac), ce mode n'est pas disponible car Docker s'exécute dans une VM.

### 🛠️ Utilisation pratique

```bash
# Lancer un conteneur en mode host
docker run -d --name webapp --network host nginx

# Le serveur nginx sera accessible directement sur le port 80 de l'hôte
# Pas besoin de -p 8080:80, le port 80 est directement utilisé
```

> [!example] Exemple avec une application personnalisée
> 
> ```bash
> # Application qui écoute sur le port 3000
> docker run -d --name api --network host node:14 node app.js
> 
> # L'application est accessible sur http://localhost:3000
> # Sans aucun mapping de port nécessaire
> ```

#### Cas d'usage : Serveur de monitoring

```bash
# Prometheus en mode host pour capturer les métriques de l'hôte
docker run -d \
  --name prometheus \
  --network host \
  -v /path/to/prometheus.yml:/etc/prometheus/prometheus.yml \
  prom/prometheus
```

### ⚠️ Pièges courants

1. **Conflits de ports** : Si l'hôte a déjà un service sur le port utilisé par le conteneur, le conteneur ne pourra pas démarrer
    
    ```bash
    # Si nginx tourne déjà sur l'hôte sur le port 80
    docker run -d --network host nginx
    # ❌ Échouera car le port 80 est déjà utilisé
    ```
    
2. **Sécurité réduite** : Le conteneur a accès à tous les services réseau de l'hôte, ce qui peut être un risque de sécurité
    
3. **Pas portable entre OS** : Le code qui fonctionne en mode host sur Linux ne fonctionnera pas sur Windows/Mac avec Docker Desktop
    
4. **Impossible de lancer plusieurs instances** : Vous ne pouvez pas lancer plusieurs conteneurs identiques en mode host car ils entreraient en conflit pour les mêmes ports
    

### ✨ Bonnes pratiques

- **Utilisez avec parcimonie** : Préférez le réseau bridge sauf si vous avez vraiment besoin des performances du mode host
- **Documentez clairement** : Indiquez dans votre documentation que l'application utilise le mode host et pourquoi
- **Vérifiez les ports disponibles** : Assurez-vous qu'aucun service n'utilise déjà les ports nécessaires
- **Testez sur l'OS cible** : N'utilisez le mode host que si vous déployez sur Linux

> [!tip] Alternative pour les performances Si vous cherchez des performances réseau optimales mais souhaitez conserver une certaine isolation, envisagez d'utiliser le réseau bridge avec des optimisations de configuration plutôt que le mode host.

---

## None Network

### 🔍 Qu'est-ce que c'est ?

Le réseau **none** désactive complètement le réseau pour un conteneur. Le conteneur n'a accès à aucune interface réseau externe, à l'exception de l'interface loopback (localhost). C'est le niveau d'isolation réseau maximum.

> [!info] Isolation totale Un conteneur en mode none ne peut communiquer ni avec d'autres conteneurs, ni avec l'hôte, ni avec Internet. Il est complètement isolé du point de vue réseau.

### 📊 Caractéristiques principales

- **Isolation maximale** : Aucune connexion réseau externe
- **Sécurité renforcée** : Impossible d'être attaqué ou d'attaquer via le réseau
- **Loopback uniquement** : Seule l'interface `lo` (127.0.0.1) est disponible
- **Performance** : Pas de surcharge réseau du tout

### 💡 Quand l'utiliser ?

- Tests d'isolation et de sécurité
- Traitement de données sensibles sans risque de fuite réseau
- Conteneurs qui n'ont besoin que de traitements locaux (calculs, génération de fichiers)
- Environnements de développement nécessitant une isolation complète
- Conteneurs temporaires pour des opérations batch sans communication externe

### 🛠️ Utilisation pratique

```bash
# Lancer un conteneur sans réseau
docker run -d --name isolated_app --network none alpine sleep 3600

# Vérifier que le conteneur n'a pas d'interface réseau (sauf lo)
docker exec isolated_app ip addr show
# Résultat : seulement l'interface loopback
```

> [!example] Exemple : Traitement de données sensibles
> 
> ```bash
> # Conteneur pour traiter des fichiers sensibles localement
> docker run --rm \
>   --network none \
>   -v /data/input:/input:ro \
>   -v /data/output:/output \
>   my-processor process --input /input --output /output
> 
> # Le conteneur traite les données mais ne peut rien envoyer sur le réseau
> ```

#### Cas d'usage : Calcul batch

```bash
# Effectuer des calculs intensifs sans besoin de réseau
docker run --rm \
  --network none \
  -v /data:/data \
  python:3.9 python /data/compute.py

# Le script Python peut lire et écrire des fichiers
# mais ne peut pas faire d'appels réseau
```

#### Vérification de l'isolation

```bash
# Vérifier qu'aucune connexion réseau n'est possible
docker exec isolated_app ping 8.8.8.8
# ❌ Échouera : "Network is unreachable"

docker exec isolated_app wget google.com
# ❌ Échouera : pas de résolution DNS, pas de connexion
```

### ⚠️ Pièges courants

1. **Oublier que les volumes fonctionnent toujours** : L'absence de réseau ne signifie pas absence d'I/O de fichiers
    
    ```bash
    # ✅ Les volumes fonctionnent normalement
    docker run --network none -v /data:/data alpine ls /data
    ```
    
2. **Essayer d'installer des packages** : Sans réseau, impossible d'utiliser des gestionnaires de packages
    
    ```bash
    # ❌ Impossible
    docker run --network none ubuntu apt-get update
    ```
    
3. **Confondre avec l'isolation de conteneurs** : L'isolation réseau ne protège pas contre les autres types de vulnérabilités (système de fichiers, processus, etc.)
    
4. **Ne pas pouvoir déboguer facilement** : Sans réseau, impossible d'utiliser des outils de débogage distant ou de récupérer des logs via le réseau
    

### ✨ Bonnes pratiques

- **Combinez avec d'autres mesures de sécurité** : Le mode none est excellent pour l'isolation réseau, mais pensez aussi aux autres aspects (utilisateurs, capabilities, seccomp)
- **Utilisez pour les conteneurs éphémères** : Parfait pour des tâches ponctuelles qui n'ont pas besoin de réseau
- **Documentez clairement** : Expliquez pourquoi le réseau est désactivé dans vos scripts et documentation
- **Préparez vos images** : Assurez-vous que toutes les dépendances sont dans l'image avant de lancer en mode none

> [!tip] Astuce de débogage Si vous devez déboguer un conteneur qui devrait être en mode none, lancez-le temporairement avec un autre réseau pour investiguer, puis revenez au mode none pour la production.

### 🔧 Configuration avancée

```bash
# Vous pouvez toujours ajouter une interface réseau manuellement après coup
# (nécessite des privilèges et des connaissances réseau avancées)
docker run -d --name isolated --network none alpine sleep 3600

# Puis configurer manuellement le réseau depuis l'hôte
# (cas d'usage très avancé et rare)
```

---

## Overlay Network

### 🔍 Qu'est-ce que c'est ?

Le réseau **overlay** permet la communication entre conteneurs répartis sur plusieurs hôtes Docker (machines physiques ou virtuelles différentes). Il crée un réseau virtuel distribué qui encapsule le trafic réseau des conteneurs et le transporte à travers le réseau physique sous-jacent.

> [!info] Pour les environnements distribués Les réseaux overlay sont principalement utilisés dans le contexte de Docker Swarm ou Kubernetes pour permettre aux conteneurs de communiquer entre eux même s'ils sont sur des machines différentes.

### 📊 Caractéristiques principales

- **Multi-hôte** : Permet la communication entre conteneurs sur différentes machines
- **Encapsulation** : Utilise VXLAN pour encapsuler les paquets réseau
- **Service Discovery** : DNS intégré pour la découverte de services
- **Chiffrement optionnel** : Possibilité de chiffrer le trafic entre les nœuds
- **Orchestration requise** : Nécessite Docker Swarm ou un orchestrateur similaire

### 💡 Quand l'utiliser ?

- Applications distribuées sur plusieurs serveurs
- Environnements de production avec haute disponibilité
- Clusters Docker Swarm
- Microservices répartis géographiquement
- Architecture multi-datacenter

> [!warning] Prérequis Les réseaux overlay nécessitent que Docker soit en mode Swarm (`docker swarm init`). Ils ne fonctionnent pas en mode Docker autonome standard.

### 🛠️ Utilisation pratique

#### Initialisation d'un Swarm

```bash
# Sur le nœud manager (première machine)
docker swarm init --advertise-addr <IP_DU_MANAGER>

# Récupérer le token pour ajouter des workers
docker swarm join-token worker
```

#### Créer un réseau overlay

```bash
# Créer un réseau overlay
docker network create --driver overlay mon_reseau_overlay

# Créer un réseau overlay avec chiffrement
docker network create --driver overlay --opt encrypted mon_reseau_securise

# Créer un réseau overlay accessible depuis les conteneurs standalone
docker network create --driver overlay --attachable mon_reseau_attachable
```

> [!example] Exemple : Déploiement d'une application multi-nœuds
> 
> ```bash
> # Créer le réseau overlay
> docker network create --driver overlay --attachable app_network
> 
> # Déployer un service de base de données (peut être sur n'importe quel nœud)
> docker service create --name database \
>   --network app_network \
>   -e POSTGRES_PASSWORD=secret \
>   postgres
> 
> # Déployer un service web (peut être sur un autre nœud)
> docker service create --name webapp \
>   --network app_network \
>   --replicas 3 \
>   -p 80:80 \
>   -e DATABASE_URL=postgresql://database:5432/mydb \
>   myapp
> 
> # Les 3 réplicas du webapp peuvent communiquer avec database
> # même s'ils sont sur des machines différentes
> ```

#### Inspecter un réseau overlay

```bash
# Voir les détails du réseau
docker network inspect mon_reseau_overlay

# Lister les services connectés
docker network inspect mon_reseau_overlay --format '{{range .Containers}}{{.Name}} {{end}}'
```

### 📡 Fonctionnement de base

Le réseau overlay utilise le protocole **VXLAN** (Virtual Extensible LAN) pour créer un réseau de niveau 2 (couche liaison) par-dessus un réseau IP existant :

1. Le trafic du conteneur est encapsulé dans des paquets VXLAN
2. Ces paquets sont envoyés à travers le réseau physique vers l'hôte destination
3. L'hôte destination décapsule les paquets et les livre au conteneur cible

> [!tip] Ports requis pour overlay Pour que les réseaux overlay fonctionnent, assurez-vous que ces ports sont ouverts entre vos hôtes :
> 
> - TCP port 2377 (communication du cluster)
> - TCP et UDP port 7946 (communication entre nœuds)
> - UDP port 4789 (trafic overlay VXLAN)

### ⚠️ Pièges courants

1. **Oublier d'initialiser Swarm** : Les réseaux overlay nécessitent Docker Swarm
    
    ```bash
    # ❌ Échouera sans Swarm
    docker network create --driver overlay mon_reseau
    
    # ✅ D'abord initialiser Swarm
    docker swarm init
    docker network create --driver overlay mon_reseau
    ```
    
2. **Problèmes de pare-feu** : Les ports Swarm/overlay doivent être ouverts entre les nœuds
    
3. **Utiliser `docker run` au lieu de `docker service create`** : Les conteneurs standalone ne peuvent pas utiliser overlay sans `--attachable`
    
    ```bash
    # ❌ Ne fonctionnera pas sans --attachable
    docker run -d --network mon_reseau_overlay nginx
    
    # ✅ Créer le réseau avec --attachable
    docker network create --driver overlay --attachable mon_reseau_overlay
    docker run -d --network mon_reseau_overlay nginx
    ```
    
4. **Performance** : L'encapsulation VXLAN ajoute une légère surcharge, à prendre en compte pour les applications très sensibles à la latence
    

### ✨ Bonnes pratiques

- **Utilisez le chiffrement pour les données sensibles** : Activez `--opt encrypted` si vous transportez des données confidentielles
- **Segmentez vos réseaux** : Créez des réseaux overlay séparés pour différentes applications ou niveaux (frontend, backend, base de données)
- **Surveillez les performances** : L'overlay ajoute une surcharge, mesurez l'impact sur vos applications critiques
- **Documentez votre topologie** : Gardez une trace de vos réseaux overlay et des services qui y sont connectés

> [!tip] Débogage overlay Pour déboguer les problèmes de réseau overlay, vérifiez :
> 
> - `docker node ls` pour voir l'état des nœuds
> - `docker network inspect` pour les détails du réseau
> - Les logs du daemon Docker sur chaque nœud
> - La connectivité réseau entre les hôtes avec `ping` et `telnet`

### 🎯 Limites importantes

- **Complexité** : Plus complexe à configurer et maintenir que les réseaux bridge
- **Dépendance** : Nécessite une infrastructure Swarm ou un orchestrateur
- **Surcharge réseau** : L'encapsulation VXLAN consomme de la bande passante et ajoute de la latence
- **Débogage** : Plus difficile à déboguer en cas de problème réseau

---

## Comparaison des types de réseaux

|Caractéristique|Bridge|Host|None|Overlay|
|---|---|---|---|---|
|**Isolation réseau**|✅ Oui|❌ Non|✅✅ Maximum|✅ Oui|
|**Performance**|🟢 Bonne|🟢🟢 Excellente|🟢🟢 Excellente|🟡 Moyenne|
|**Communication inter-conteneurs**|✅ Même hôte|✅ Même hôte|❌ Non|✅ Multi-hôtes|
|**Résolution DNS**|✅ (réseau personnalisé)|✅ (via hôte)|❌ Non|✅ Oui|
|**Mapping de ports requis**|✅ Oui|❌ Non|N/A|✅ Oui|
|**Multi-hôte**|❌ Non|❌ Non|❌ Non|✅ Oui|
|**Complexité**|🟢 Simple|🟢 Simple|🟢 Simple|🔴 Complexe|
|**Cas d'usage principal**|Applications standard|Performance maximale|Isolation sécurité|Architecture distribuée|
|**Prérequis**|Aucun|Linux uniquement|Aucun|Docker Swarm|

### 🎯 Guide de choix rapide

```
┌─────────────────────────────────────┐
│   Besoin de communiquer entre       │
│   conteneurs sur plusieurs hôtes ?  │
└────────────┬────────────────────────┘
             │
      ┌──────┴───────┐
      │ OUI          │ NON
      │              │
      v              v
  OVERLAY     ┌──────────────────────────┐
              │ Besoin de performances   │
              │ réseau maximales ?       │
              └────────┬─────────────────┘
                       │
                ┌──────┴───────┐
                │ OUI          │ NON
                │              │
                v              v
              HOST      ┌─────────────────────┐
                        │ Besoin de réseau ?  │
                        └──────┬──────────────┘
                               │
                        ┌──────┴──────┐
                        │ OUI         │ NON
                        │             │
                        v             v
                     BRIDGE         NONE
```

> [!tip] Recommandation générale Pour la plupart des cas d'usage, **utilisez un réseau bridge personnalisé**. C'est le meilleur compromis entre simplicité, isolation, et fonctionnalités (résolution DNS, sécurité).

### 📝 Résumé des commandes essentielles

```bash
# Bridge (par défaut)
docker run -d --name app nginx

# Bridge personnalisé (recommandé)
docker network create mon_reseau
docker run -d --name app --network mon_reseau nginx

# Host (performance maximale, Linux uniquement)
docker run -d --name app --network host nginx

# None (isolation totale)
docker run -d --name app --network none alpine

# Overlay (multi-hôtes, nécessite Swarm)
docker swarm init
docker network create --driver overlay --attachable mon_overlay
docker service create --name app --network mon_overlay nginx
```

---

> [!info] 🎓 Concepts clés à retenir
> 
> - **Bridge** : Le choix par défaut pour les applications locales et le développement
> - **Host** : Pour des cas spécifiques nécessitant des performances réseau maximales (Linux uniquement)
> - **None** : Pour l'isolation de sécurité maximale sans besoin de réseau
> - **Overlay** : Pour les architectures distribuées sur plusieurs machines (nécessite un orchestrateur)
> 
> Le choix du réseau dépend de votre architecture, de vos besoins en performance, et de vos exigences de sécurité.