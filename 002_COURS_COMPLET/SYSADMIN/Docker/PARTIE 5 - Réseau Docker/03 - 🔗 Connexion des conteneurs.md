

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

## 🔌 Attacher un conteneur à un réseau

### Pourquoi attacher des conteneurs à des réseaux ?

L'attachement de conteneurs à des réseaux permet de :

- **Isoler** les conteneurs par fonction ou environnement
- **Contrôler** qui peut communiquer avec qui
- **Organiser** votre infrastructure en groupes logiques
- **Sécuriser** vos applications en limitant l'exposition

> [!info] Concept clé Un conteneur peut être attaché à plusieurs réseaux simultanément, ce qui permet des architectures complexes où un conteneur fait office de pont entre différents réseaux.

### Attacher lors de la création du conteneur

La méthode la plus courante consiste à spécifier le réseau lors du lancement :

```bash
# Syntaxe de base
docker run --network <nom_réseau> <image>

# Exemple concret
docker run -d \
  --name api-backend \
  --network app-network \
  nginx

# Avec plusieurs options réseau
docker run -d \
  --name database \
  --network app-network \
  --network-alias db \
  --ip 172.18.0.10 \
  postgres:15
```

> [!example] Explication des options
> 
> - `--network` : spécifie le réseau à utiliser
> - `--network-alias` : crée un alias DNS pour ce conteneur
> - `--ip` : assigne une IP fixe (uniquement pour les réseaux user-defined)

### Attacher un conteneur existant à un réseau

Pour connecter un conteneur déjà en cours d'exécution :

```bash
# Syntaxe de base
docker network connect <nom_réseau> <nom_conteneur>

# Exemple simple
docker network connect app-network mon-conteneur

# Avec options avancées
docker network connect \
  --alias web-server \
  --ip 172.18.0.20 \
  app-network \
  mon-nginx

# Attacher à plusieurs réseaux
docker network connect frontend-network mon-conteneur
docker network connect backend-network mon-conteneur
```

> [!tip] Multi-attachement Un conteneur attaché à plusieurs réseaux peut servir de proxy ou de passerelle entre différentes zones de votre infrastructure.

### Détacher un conteneur d'un réseau

```bash
# Syntaxe de base
docker network disconnect <nom_réseau> <nom_conteneur>

# Exemple
docker network disconnect app-network mon-conteneur

# Forcer la déconnexion (même si le conteneur est en cours d'utilisation)
docker network disconnect -f app-network mon-conteneur
```

### Vérifier les connexions réseau

```bash
# Inspecter les réseaux d'un conteneur
docker inspect mon-conteneur --format='{{json .NetworkSettings.Networks}}' | jq

# Lister les conteneurs sur un réseau spécifique
docker network inspect app-network --format='{{range .Containers}}{{.Name}} {{end}}'

# Voir tous les réseaux d'un conteneur
docker inspect mon-conteneur | grep -A 20 "Networks"
```

> [!warning] Attention au réseau par défaut Les conteneurs sur le réseau `bridge` par défaut ne bénéficient PAS de la résolution DNS automatique. Utilisez toujours des réseaux user-defined pour la production.

### Tableau récapitulatif des commandes

|Commande|Action|Moment d'utilisation|
|---|---|---|
|`docker run --network`|Attacher lors de la création|Nouveau conteneur|
|`docker network connect`|Attacher à chaud|Conteneur existant|
|`docker network disconnect`|Détacher|Retirer d'un réseau|
|`docker network inspect`|Voir les connexions|Diagnostic|

---

## 💬 Communication inter-conteneurs

### Principes de base

La communication entre conteneurs dépend du type de réseau utilisé :

> [!info] Règles de communication
> 
> - **Même réseau user-defined** : communication possible via nom ou IP
> - **Réseaux différents** : aucune communication (isolation)
> - **Réseau bridge par défaut** : communication uniquement via IP

### Communication par nom de conteneur

Sur un réseau user-defined, les conteneurs peuvent se parler par leur nom :

```bash
# Créer un réseau
docker network create mon-reseau

# Lancer un conteneur serveur
docker run -d \
  --name api \
  --network mon-reseau \
  nginx

# Lancer un conteneur client qui peut contacter "api"
docker run -it \
  --network mon-reseau \
  alpine \
  ping api
```

> [!example] Exemple réel : Application web + Base de données
> 
> ```bash
> # Base de données
> docker run -d \
>   --name postgres-db \
>   --network app-net \
>   -e POSTGRES_PASSWORD=secret \
>   postgres:15
> 
> # Application web (peut se connecter à "postgres-db:5432")
> docker run -d \
>   --name web-app \
>   --network app-net \
>   -e DB_HOST=postgres-db \
>   -e DB_PORT=5432 \
>   mon-app:latest
> ```

### Communication via alias réseau

Les alias permettent de donner plusieurs noms à un conteneur :

```bash
# Créer avec alias lors du lancement
docker run -d \
  --name db1 \
  --network app-net \
  --network-alias database \
  --network-alias db \
  postgres:15

# Les autres conteneurs peuvent utiliser "db1", "database" ou "db"
docker run -it --network app-net alpine ping database
```

> [!tip] Cas d'usage des alias
> 
> - **Load balancing** : plusieurs conteneurs avec le même alias
> - **Migration** : changer le conteneur sans modifier les clients
> - **Abstraction** : cacher le nom technique derrière un alias fonctionnel

### Communication multi-réseaux

Un conteneur sur plusieurs réseaux peut faire office de pont :

```bash
# Réseau frontend (public)
docker network create frontend

# Réseau backend (privé)
docker network create backend

# API Gateway sur les deux réseaux
docker run -d \
  --name gateway \
  --network frontend \
  nginx

docker network connect backend gateway

# Frontend accessible uniquement via frontend
docker run -d \
  --name webapp \
  --network frontend \
  mon-frontend:latest

# Database accessible uniquement via backend
docker run -d \
  --name db \
  --network backend \
  postgres:15
```

> [!info] Architecture résultante
> 
> - `webapp` peut contacter `gateway` mais pas `db`
> - `gateway` peut contacter `webapp` et `db`
> - `db` peut contacter `gateway` mais pas `webapp`

### Ports et exposition

```bash
# Communication interne (pas besoin d'exposer les ports)
docker run -d \
  --name api \
  --network app-net \
  mon-api:latest
# Les autres conteneurs accèdent via : http://api:8080

# Exposition externe en plus
docker run -d \
  --name api \
  --network app-net \
  -p 8080:8080 \
  mon-api:latest
# Accessible depuis l'hôte ET les conteneurs
```

> [!warning] Sécurité N'exposez que les ports nécessaires vers l'hôte. La communication inter-conteneurs ne nécessite PAS de `-p`.

### Tester la communication

```bash
# Test de connectivité basique
docker exec mon-conteneur ping autre-conteneur

# Test HTTP
docker exec mon-conteneur curl http://api:8080/health

# Test de port spécifique
docker exec mon-conteneur nc -zv database 5432

# Voir les connexions actives
docker exec mon-conteneur netstat -tlnp
```

### Pièges courants

> [!warning] Erreurs fréquentes
> 
> **❌ Utiliser le réseau bridge par défaut**
> 
> ```bash
> docker run -d --name api nginx
> docker run -it alpine ping api  # ❌ Ne fonctionne pas
> ```
> 
> **✅ Utiliser un réseau user-defined**
> 
> ```bash
> docker network create mon-net
> docker run -d --name api --network mon-net nginx
> docker run -it --network mon-net alpine ping api  # ✅ Fonctionne
> ```

---

## 🔍 Résolution DNS

### Fonctionnement du DNS Docker

Docker intègre un serveur DNS automatique pour les réseaux user-defined :

> [!info] Serveur DNS intégré
> 
> - **Adresse** : 127.0.0.11 dans chaque conteneur
> - **Port** : 53 (standard DNS)
> - **Fonction** : Résout les noms de conteneurs en adresses IP
> - **Portée** : Uniquement au sein d'un même réseau

```bash
# Vérifier la configuration DNS d'un conteneur
docker exec mon-conteneur cat /etc/resolv.conf
# Sortie typique :
# nameserver 127.0.0.11
# options ndots:0
```

### Résolution par nom de conteneur

Le mécanisme le plus simple et recommandé :

```bash
# Créer un réseau
docker network create test-dns

# Lancer des conteneurs
docker run -d --name web1 --network test-dns nginx
docker run -d --name web2 --network test-dns nginx
docker run -d --name db --network test-dns postgres:15

# Tester la résolution
docker run -it --network test-dns alpine nslookup web1
# Retourne l'IP de web1

docker run -it --network test-dns alpine ping db
# Fonctionne !
```

> [!tip] Recommandation Utilisez toujours les noms de conteneurs pour référencer les services. C'est plus maintenable que les adresses IP.

### Résolution par alias

Les alias créent des entrées DNS supplémentaires :

```bash
# Conteneur avec plusieurs alias
docker run -d \
  --name postgres-prod \
  --network app-net \
  --network-alias db \
  --network-alias database \
  --network-alias postgres \
  postgres:15

# Tous ces noms résolvent vers la même IP
docker exec client nslookup postgres-prod  # ✅
docker exec client nslookup db             # ✅
docker exec client nslookup database       # ✅
docker exec client nslookup postgres       # ✅
```

### Round-robin DNS (Load balancing)

Plusieurs conteneurs avec le même alias créent un load balancing automatique :

```bash
# Créer plusieurs conteneurs avec le même alias
docker run -d \
  --name web1 \
  --network app-net \
  --network-alias webserver \
  nginx

docker run -d \
  --name web2 \
  --network app-net \
  --network-alias webserver \
  nginx

docker run -d \
  --name web3 \
  --network app-net \
  --network-alias webserver \
  nginx

# Le DNS retourne les IPs dans un ordre rotatif
docker run -it --network app-net alpine nslookup webserver
# Retourne les 3 IPs, ordre changeant à chaque requête
```

> [!example] Cas d'usage pratique
> 
> ```bash
> # Application avec scaling horizontal
> for i in {1..5}; do
>   docker run -d \
>     --name api-$i \
>     --network prod \
>     --network-alias api \
>     mon-api:latest
> done
> 
> # Les clients contactent "api" et sont automatiquement répartis
> docker run --network prod client curl http://api/health
> ```

### DNS externe et personnalisé

Configurer des serveurs DNS externes :

```bash
# Utiliser des DNS personnalisés
docker run -d \
  --name mon-conteneur \
  --dns 8.8.8.8 \
  --dns 1.1.1.1 \
  nginx

# Ajouter des entrées DNS personnalisées
docker run -d \
  --name mon-conteneur \
  --add-host api.externe:93.184.216.34 \
  --add-host cache:10.0.0.50 \
  nginx

# Vérifier
docker exec mon-conteneur cat /etc/hosts
# Contient les entrées personnalisées
```

### Options de recherche DNS

```bash
# Configurer le domaine de recherche
docker run -d \
  --name mon-conteneur \
  --dns-search exemple.com \
  --dns-search corp.local \
  nginx

# Maintenant "api" résout vers "api.exemple.com" si trouvé
```

> [!info] Option dns-search Permet de référencer des services par leur nom court. Si "api" n'est pas trouvé, Docker essaie "api.exemple.com", puis "api.corp.local".

### Résolution DNS entre réseaux

```bash
# Deux réseaux différents
docker network create net-a
docker network create net-b

docker run -d --name service-a --network net-a nginx
docker run -d --name service-b --network net-b nginx

# service-a ne peut PAS résoudre service-b
docker exec service-a nslookup service-b  # ❌ Échoue

# Solution : conteneur pont
docker run -d --name gateway --network net-a nginx
docker network connect net-b gateway

# gateway peut résoudre les deux
docker exec gateway nslookup service-a  # ✅
docker exec gateway nslookup service-b  # ✅
```

### Débogage DNS

```bash
# Vérifier la configuration DNS
docker exec mon-conteneur cat /etc/resolv.conf

# Tester la résolution
docker exec mon-conteneur nslookup nom-service

# Voir les entrées hosts personnalisées
docker exec mon-conteneur cat /etc/hosts

# Test DNS détaillé
docker exec mon-conteneur dig nom-service

# Tracer les requêtes DNS (si dig disponible)
docker exec mon-conteneur dig +trace nom-service
```

### Tableau récapitulatif DNS

|Mécanisme|Syntaxe|Portée|Cas d'usage|
|---|---|---|---|
|Nom conteneur|`docker run --name X`|Réseau uniquement|Communication de base|
|Alias|`--network-alias Y`|Réseau uniquement|Abstraction, load balancing|
|DNS externe|`--dns 8.8.8.8`|Conteneur|Résolution externe|
|Hosts custom|`--add-host api:10.0.0.5`|Conteneur|Overrides spécifiques|
|DNS search|`--dns-search corp.local`|Conteneur|Noms courts|

### Bonnes pratiques DNS

> [!tip] Recommandations
> 
> **✅ À faire :**
> 
> - Utiliser des noms descriptifs pour les conteneurs
> - Créer des alias pour les services scalables
> - Documenter les alias dans votre infrastructure
> - Tester la résolution après chaque déploiement
> 
> **❌ À éviter :**
> 
> - Hardcoder des adresses IP dans votre code
> - Utiliser le réseau bridge par défaut en production
> - Créer des noms de conteneurs avec des caractères spéciaux
> - Oublier que le DNS ne fonctionne que dans le même réseau

### Pièges courants DNS

> [!warning] Erreurs fréquentes
> 
> **Problème 1 : DNS ne fonctionne pas**
> 
> ```bash
> # ❌ Sur le réseau bridge par défaut
> docker run -d --name api nginx
> docker run -it alpine ping api  # Ne fonctionne pas
> ```
> 
> **Solution :** Créer un réseau user-defined
> 
> **Problème 2 : Résolution entre réseaux**
> 
> ```bash
> # ❌ Conteneurs sur des réseaux différents
> docker network create net1
> docker network create net2
> docker run -d --name api --network net1 nginx
> docker run -it --network net2 alpine ping api  # Échec
> ```
> 
> **Solution :** Mettre les conteneurs sur le même réseau ou utiliser un gateway
> 
> **Problème 3 : Cache DNS**
> 
> ```bash
> # Le DNS peut être mis en cache par l'application
> # Redémarrer le conteneur pour forcer un refresh
> docker restart mon-conteneur
> ```

---

> [!tip] 🎯 Points clés à retenir
> 
> **Connexion des conteneurs :**
> 
> - Utilisez `--network` au lancement ou `docker network connect` après
> - Un conteneur peut être sur plusieurs réseaux simultanément
> - La communication nécessite que les conteneurs soient sur le même réseau
> 
> **Communication :**
> 
> - Sur un réseau user-defined, utilisez les noms de conteneurs
> - Les alias permettent l'abstraction et le load balancing
> - Pas besoin d'exposer les ports pour la communication interne
> 
> **DNS :**
> 
> - Le DNS automatique fonctionne uniquement sur les réseaux user-defined
> - Un alias partagé par plusieurs conteneurs = load balancing automatique
> - Le DNS est limité à un réseau spécifique (pas de cross-network)

---

_Fin de la section : Connexion des conteneurs_ 🎓