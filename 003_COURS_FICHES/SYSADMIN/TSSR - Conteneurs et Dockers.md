# ⚡ L'essentiel en 5 minutes - Conteneurs et Docker

## 📌 C'est quoi en 2 lignes ?

Docker permet d'exécuter des applications dans des **conteneurs isolés** qui empaquètent code + dépendances + configuration. Un conteneur = processus isolé utilisant le noyau hôte (≠ VM avec son propre OS complet).

---

## 💡 Concepts clés à retenir

- **Conteneur** : Ensemble de processus isolés s'exécutant dans un environnement dédié avec son propre système de fichiers
- **Image** : Template immuable (programme + dépendances + config) servant à créer des conteneurs (conteneur = instance d'une image)
- **Volume** : Espace de stockage persistant géré par Docker, partageable entre conteneurs et survivant à leur destruction
- **Réseau bridge** : Réseau virtuel par défaut créé par Docker pour connecter les conteneurs avec NAT vers l'extérieur
- **Dockerfile** : Fichier de commandes décrivant comment construire une image (couches empilées, mise en cache)
- **Repository** : Dépôt d'images Docker (DockerHub = dépôt public officiel, possibilité de dépôts privés)
- **Namespaces & Cgroups** : Mécanismes Linux sous-jacents permettant l'isolation (ressources visibles) et limitation (CPU/RAM)

---

## 💻 Commandes essentielles

```bash
# 🐳 GESTION DES IMAGES
docker image ls                          # Liste les images locales
docker images                            # Alias de image ls
docker pull <image>:<tag>                # Télécharge une image (tag=version)
docker build -t <nom>:<tag> <path>       # Construit image depuis Dockerfile
docker image rm <image>                  # Supprime une image

# 📦 GESTION DES CONTENEURS
docker run [OPTIONS] <image> [CMD]       # Crée ET lance un conteneur
  -d                                     # Mode détaché (arrière-plan)
  -it                                    # Mode interactif + terminal
  -p 8080:80                             # Mappe port hôte:conteneur
  --name <nom>                           # Nomme le conteneur
  -v <volume>:<path>                     # Monte un volume
  --network <réseau>                     # Connecte à un réseau spécifique

docker ps                                # Liste conteneurs actifs
docker ps -a                             # Liste TOUS les conteneurs
docker start <conteneur>                 # Démarre conteneur arrêté
docker stop <conteneur>                  # Arrête conteneur en cours
docker rm <conteneur>                    # Supprime conteneur arrêté
docker exec -it <conteneur> <cmd>        # Exécute commande dans conteneur actif

# 💾 GESTION DES VOLUMES
docker volume ls                         # Liste les volumes
docker volume create <nom>               # Crée un volume nommé
docker volume rm <nom>                   # Supprime un volume
docker volume prune                      # Supprime volumes non utilisés

# 🌐 GESTION DES RÉSEAUX
docker network ls                        # Liste les réseaux
docker network create <nom>              # Crée un réseau virtuel
docker network connect <réseau> <cont>   # Connecte conteneur à réseau

# 🧹 MAINTENANCE
docker system prune                      # Nettoie éléments non utilisés
docker system df                         # Affiche usage disque Docker
```

**Dockerfile (syntaxe)**

```dockerfile
FROM <image>:<tag>              # Image de base (obligatoire, 1 seul)
WORKDIR /app                    # Définit répertoire de travail
COPY <src> <dest>               # Copie fichiers locaux vers image
RUN <commande>                  # Exécute commande lors du build
CMD ["executable", "arg1"]      # Commande par défaut au lancement (1 seul)
EXPOSE <port>                   # Documente les ports écoutés
```

---

## ⚠️ Pièges à éviter

- ❌ **Oublier le groupe docker** : Sans appartenance au groupe `docker`, impossible d'utiliser la CLI sans sudo
- ❌ **Confusion volumes/bind mounts** : Volume = géré par Docker (`/var/lib/docker/volumes/`), bind mount = dossier hôte monté directement
- ❌ **Données dans le conteneur** : Modifications fichiers conteneur = perdues à sa destruction. Toujours utiliser volumes pour données persistantes
- ❌ **Port mapping oublié** : `-p` obligatoire pour exposer un service conteneurisé vers l'extérieur (pas automatique même avec EXPOSE)
- ❌ **Images non taguées** : Risque de perdre la référence après rebuild. Toujours taguer avec `-t nom:version`
- ❌ **Multiplier les FROM** : Un seul FROM par Dockerfile (sauf multi-stage builds avancés)
- ❌ **Confondre CMD et RUN** : RUN = exécuté au build, CMD = exécuté au lancement du conteneur

---

## ✅ Bonnes pratiques

- ✅ **Un service = un conteneur** : Docker recommande 1 processus principal par conteneur (pas un système complet)
- ✅ **Images légères** : Utiliser images Alpine (ex: `node:18-alpine`) pour réduire taille et surface d'attaque
- ✅ **Layers optimisés** : Regrouper commandes RUN pour limiter couches (`RUN apt update && apt install -y pkg1 pkg2`)
- ✅ **.dockerignore** : Exclure fichiers inutiles (node_modules, .git) du contexte de build
- ✅ **Conteneurs éphémères** : Concevoir pour destruction/recréation fréquente (pas de MAJ in-place)
- ✅ **Variables d'environnement** : Utiliser `-e` ou `--env-file` pour config sensible (pas hardcodé dans image)
- ✅ **Inspect avant exec** : `docker inspect <conteneur>` pour vérifier config réseau, volumes, état

---

## 📚 Vocabulaire technique

|Terme|Définition courte|
|---|---|
|**Layer (couche)**|Chaque instruction Dockerfile crée une couche en cache, réutilisable entre images|
|**Registry**|Serveur de stockage d'images Docker (DockerHub, Harbor, registres privés)|
|**Tag**|Identifiant de version d'image (latest = dernière, sinon numéro version)|
|**Engine**|Daemon dockerd + CLI docker formant le moteur d'exécution|
|**Bind mount**|Montage direct d'un dossier hôte dans conteneur (`-v /host/path:/container/path`)|
|**Bridge**|Type de réseau virtuel par défaut créant un sous-réseau isolé avec NAT|
|**Namespace**|Mécanisme Linux isolant ressources (PID, réseau, montages) entre processus|
|**Cgroups**|Mécanisme Linux limitant ressources CPU/RAM d'un groupe de processus|
|**LXC**|Conteneurisation système (VM-like) vs Docker (conteneurisation applicative)|
|**Orchestration**|Gestion automatisée multi-conteneurs (Docker Compose, Swarm, Kubernetes)|

---

## 🎯 À retenir ABSOLUMENT

1. 💡 **Théorique** : Conteneur ≠ VM → Partage le noyau hôte, moins lourd, isolation par namespaces/cgroups
2. 💻 **Pratique** : `docker run -d -p 8080:80 --name monapp nginx` (lance Nginx détaché, port 8080→80)
3. ⚠️ **Piège** : Données sans volume = **PERTE DÉFINITIVE** à la destruction du conteneur

---

**Workflow type :**

```bash
# 1. Récupérer image
docker pull nginx:alpine

# 2. Lancer conteneur
docker run -d -p 8080:80 --name web nginx:alpine

# 3. Vérifier
docker ps
curl localhost:8080

# 4. Arrêter/supprimer
docker stop web
docker rm web
```

**Différence clé VM vs Conteneur :**

- VM = Hyperviseur + OS complet par instance (lourd, lent)
- Conteneur = Noyau partagé + isolation processus (léger, rapide)