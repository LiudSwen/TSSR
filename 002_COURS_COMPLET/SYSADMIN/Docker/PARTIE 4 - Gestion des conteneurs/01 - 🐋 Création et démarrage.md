

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

## Introduction

La gestion des conteneurs Docker commence par leur création et leur démarrage. Contrairement à une machine virtuelle qui nécessite plusieurs étapes distinctes (création, configuration, démarrage), Docker unifie ces actions avec la commande `docker run`. Cette commande est le point d'entrée principal pour lancer vos applications conteneurisées.

> [!info] Concept clé Un conteneur Docker est une instance d'une image en cours d'exécution. L'image est le modèle (immuable), le conteneur est l'exécution (éphémère et modifiable).

---

## La commande docker run

### Syntaxe de base

```bash
docker run [OPTIONS] IMAGE [COMMAND] [ARG...]
```

### Fonctionnement

Quand vous exécutez `docker run`, Docker effectue automatiquement ces étapes :

1. **Vérifie** si l'image existe localement
2. **Télécharge** l'image depuis Docker Hub si elle n'existe pas (via `docker pull`)
3. **Crée** un nouveau conteneur à partir de l'image
4. **Alloue** un système de fichiers en lecture-écriture au conteneur
5. **Configure** le réseau (bridge par défaut)
6. **Démarre** le conteneur en exécutant la commande spécifiée

### Exemple minimal

```bash
# Lancer un conteneur Ubuntu simple
docker run ubuntu

# Lancer un conteneur avec une commande spécifique
docker run ubuntu echo "Hello Docker"
```

> [!warning] Attention Sans options, le conteneur s'exécute en mode "foreground" et se termine immédiatement après l'exécution de sa commande principale. Pour un serveur web ou une application longue durée, vous devrez utiliser des options supplémentaires.

---

## Options principales

### Mode détaché : -d

**Qu'est-ce que c'est ?**

L'option `-d` (ou `--detach`) lance le conteneur en arrière-plan, libérant votre terminal.

**Pourquoi l'utiliser ?**

- Pour les services de longue durée (serveurs web, bases de données)
- Pour exécuter plusieurs conteneurs simultanément
- Pour ne pas bloquer votre terminal

**Syntaxe**

```bash
docker run -d IMAGE

# Exemple : lancer un serveur nginx en arrière-plan
docker run -d nginx

# Docker retourne l'ID du conteneur
# Output: 8f3a9c7b2e1d4a5f6b8c9d0e1f2a3b4c5d6e7f8g9h0i1j2k3l4m5n6o7p8q9r0
```

**Comportement**

```bash
# Sans -d : le terminal est bloqué
docker run nginx
# Vous voyez les logs en temps réel
# Ctrl+C arrête le conteneur

# Avec -d : le terminal est libre
docker run -d nginx
# Retourne l'ID et rend la main
# Le conteneur continue de tourner en arrière-plan
```

> [!tip] Astuce Utilisez `docker logs [CONTAINER_ID]` pour voir les logs d'un conteneur détaché, et `docker logs -f [CONTAINER_ID]` pour les suivre en temps réel.

---

### Mode interactif : -it

**Qu'est-ce que c'est ?**

L'option `-it` combine deux options :

- `-i` (ou `--interactive`) : garde STDIN ouvert même si non attaché
- `-t` (ou `--tty`) : alloue un pseudo-terminal

**Pourquoi l'utiliser ?**

- Pour interagir avec le conteneur via un shell
- Pour le debugging et l'exploration
- Pour les applications en ligne de commande nécessitant des entrées utilisateur

**Syntaxe**

```bash
docker run -it IMAGE [SHELL]

# Exemple : ouvrir un terminal bash dans Ubuntu
docker run -it ubuntu bash

# Exemple : ouvrir un terminal sh dans Alpine
docker run -it alpine sh

# Vous êtes maintenant à l'intérieur du conteneur
root@a3b5c7d9e1f2:/# ls
bin  boot  dev  etc  home  lib  media  mnt  opt  proc  root  run  sbin  srv  sys  tmp  usr  var
```

**Différence entre -i et -it**

```bash
# Avec -i seulement : vous pouvez envoyer des commandes mais sans terminal formaté
docker run -i ubuntu bash
# Fonctionne mais pas de prompt propre, pas d'autocomplétion

# Avec -it : expérience terminal complète
docker run -it ubuntu bash
root@container:/# # Prompt propre, autocomplétion, couleurs
```

> [!example] Cas d'usage typique
> 
> ```bash
> # Explorer une distribution Linux
> docker run -it ubuntu bash
> 
> # Tester Python interactivement
> docker run -it python:3.11 python
> 
> # Débugger une application Node.js
> docker run -it node:18 bash
> ```

**Sortir du mode interactif**

```bash
# Sortir ET arrêter le conteneur
exit
# ou
Ctrl+D

# Détacher sans arrêter (le conteneur continue)
Ctrl+P puis Ctrl+Q
```

---

### Nommer un conteneur : --name

**Qu'est-ce que c'est ?**

L'option `--name` permet d'attribuer un nom personnalisé au conteneur au lieu d'utiliser l'ID ou le nom généré automatiquement.

**Pourquoi l'utiliser ?**

- Facilite l'identification et la gestion des conteneurs
- Améliore la lisibilité des commandes
- Indispensable pour les communications inter-conteneurs
- Permet de référencer facilement le conteneur dans les scripts

**Syntaxe**

```bash
docker run --name NOM_PERSONNALISE IMAGE

# Exemple : nommer un serveur web
docker run -d --name mon_nginx nginx

# Exemple : nommer une base de données
docker run -d --name db_postgres postgres:15
```

**Avant/Après**

```bash
# Sans --name
docker run -d nginx
# ID: 8f3a9c7b2e1d
# Nom auto: elegant_tesla

# Manipulation
docker stop 8f3a9c7b2e1d  # Avec l'ID
docker logs elegant_tesla  # Avec le nom auto

# Avec --name
docker run -d --name web nginx

# Manipulation bien plus claire
docker stop web
docker logs web
docker restart web
```

> [!warning] Unicité des noms Chaque nom de conteneur doit être unique. Si vous essayez de créer un conteneur avec un nom déjà utilisé, Docker retournera une erreur. Vous devrez d'abord supprimer ou renommer l'ancien conteneur.

```bash
# Erreur si le nom existe déjà
docker run --name web nginx
# Error: Conflict. The container name "/web" is already in use

# Solution 1 : supprimer l'ancien
docker rm -f web
docker run --name web nginx

# Solution 2 : utiliser un nom différent
docker run --name web2 nginx
```

---

### Suppression automatique : --rm

**Qu'est-ce que c'est ?**

L'option `--rm` supprime automatiquement le conteneur lorsqu'il s'arrête.

**Pourquoi l'utiliser ?**

- Pour les conteneurs temporaires et les tests
- Évite l'accumulation de conteneurs arrêtés
- Maintient un environnement propre automatiquement
- Économise de l'espace disque

**Syntaxe**

```bash
docker run --rm IMAGE

# Exemple : tester une commande et nettoyer automatiquement
docker run --rm ubuntu echo "Test terminé"

# Exemple : shell temporaire
docker run --rm -it alpine sh
```

**Comportement**

```bash
# Sans --rm
docker run ubuntu echo "Hello"
docker ps -a  # Le conteneur arrêté est toujours là
# CONTAINER ID   STATUS                     
# a3b5c7d9e1f2   Exited (0) 5 seconds ago

# Avec --rm
docker run --rm ubuntu echo "Hello"
docker ps -a  # Le conteneur a été automatiquement supprimé
# Aucune trace du conteneur
```

**Cas d'usage typiques**

```bash
# Tests rapides
docker run --rm node:18 node --version

# Scripts one-shot
docker run --rm -v $(pwd):/app python:3.11 python /app/script.py

# Environnements de développement temporaires
docker run --rm -it --name dev-env ubuntu bash

# Commandes utilitaires
docker run --rm alpine wget https://example.com -O -
```

> [!tip] Combinaison avec -it L'option `--rm` est particulièrement utile avec `-it` pour les sessions interactives temporaires :
> 
> ```bash
> docker run --rm -it ubuntu bash
> # Une fois que vous tapez 'exit', le conteneur est automatiquement nettoyé
> ```

> [!warning] Perte de données Attention : `--rm` supprime le conteneur ET son système de fichiers. Toute donnée non persistée dans un volume sera perdue. N'utilisez pas `--rm` pour des conteneurs dont vous souhaitez conserver l'état ou les données.

---

## Mode interactif vs Mode détaché

### Comparaison détaillée

|Critère|Mode interactif (`-it`)|Mode détaché (`-d`)|
|---|---|---|
|**Terminal**|Bloqué, attaché au conteneur|Libre, rendu immédiatement|
|**Interaction**|Directe avec le conteneur|Via commandes Docker|
|**Cas d'usage**|Shell, debugging, CLI|Services, démons, serveurs|
|**Logs**|Affichés en direct|Consultables via `docker logs`|
|**Arrêt**|`exit` ou Ctrl+C|`docker stop`|
|**Durée de vie**|Généralement courte|Généralement longue|

### Quand utiliser chaque mode ?

**Mode interactif (-it)** ✅

```bash
# Exploration et apprentissage
docker run -it ubuntu bash

# Debugging d'une application
docker run -it --name debug myapp bash

# Exécution de scripts nécessitant des entrées
docker run -it python:3.11 python script.py

# Tests manuels
docker run -it node:18 npm test

# REPL (Read-Eval-Print Loop)
docker run -it python:3.11 python
docker run -it node:18 node
```

**Mode détaché (-d)** ✅

```bash
# Serveurs web
docker run -d -p 80:80 nginx

# Bases de données
docker run -d -p 5432:5432 postgres

# Services backend
docker run -d --name api myapi:latest

# Workers et tâches de fond
docker run -d --name worker celery-worker

# Monitoring et logging
docker run -d --name prometheus prometheus
```

### Passer d'un mode à l'autre

```bash
# Démarrer en détaché puis attacher
docker run -d --name web nginx
docker attach web  # Vous voyez maintenant les logs en direct
# Ctrl+C arrêtera le conteneur

# Alternative : suivre les logs sans s'attacher
docker logs -f web  # Ctrl+C ne tue PAS le conteneur

# Démarrer en interactif puis détacher
docker run -it --name shell ubuntu bash
# Ctrl+P puis Ctrl+Q pour détacher sans arrêter
docker ps  # Le conteneur tourne toujours

# Réattacher plus tard
docker attach shell
```

> [!info] Bonne pratique Pour les services de production, utilisez toujours `-d`. Le mode interactif est réservé au développement et au debugging.

---

## Combinaisons d'options courantes

### Exemples pratiques avec explications

```bash
# 1. Serveur web de production
docker run -d \
  --name production_web \
  -p 80:80 \
  -p 443:443 \
  nginx:alpine

# -d : tourne en arrière-plan
# --name : nom explicite pour la gestion
# -p : mapping des ports (host:conteneur)
```

```bash
# 2. Session de debug temporaire
docker run --rm -it \
  --name debug_session \
  -v $(pwd):/workspace \
  ubuntu bash

# --rm : nettoyage automatique à la sortie
# -it : interaction complète
# -v : monte le répertoire courant (mentionné, sera détaillé dans une autre partie)
```

```bash
# 3. Base de données persistante
docker run -d \
  --name postgres_prod \
  -e POSTGRES_PASSWORD=secret \
  -v pgdata:/var/lib/postgresql/data \
  postgres:15

# -d : service en arrière-plan
# --name : identification claire
# -e : variables d'environnement (mentionné)
# -v : volume pour persistance (mentionné)
```

```bash
# 4. Test one-shot avec résultat
docker run --rm \
  -v $(pwd):/app \
  node:18 \
  npm test

# --rm : nettoyage après test
# Pas de -d : on veut voir le résultat
# Pas de -it : c'est un script automatisé
```

```bash
# 5. Conteneur de développement complet
docker run --rm -it \
  --name dev_env \
  -v $(pwd):/code \
  -p 3000:3000 \
  -e NODE_ENV=development \
  node:18 bash

# Combinaison pour environnement de dev interactif et temporaire
```

### Tableau récapitulatif des combinaisons

|Besoin|Combinaison|Exemple|
|---|---|---|
|Service permanent|`-d --name`|`docker run -d --name web nginx`|
|Debug temporaire|`--rm -it`|`docker run --rm -it ubuntu bash`|
|Test automatisé|`--rm`|`docker run --rm node npm test`|
|Service avec nom|`-d --name`|`docker run -d --name db postgres`|
|Shell temporaire nommé|`--rm -it --name`|`docker run --rm -it --name tmp ubuntu bash`|

---

## Pièges courants

### 1. Conteneur qui se termine immédiatement

```bash
# ❌ Problème
docker run ubuntu
# Le conteneur démarre et s'arrête immédiatement

# ✅ Solution : fournir une commande qui maintient le conteneur actif
docker run -d ubuntu tail -f /dev/null  # Garde le conteneur actif
docker run -it ubuntu bash               # Mode interactif
```

**Explication** : Docker arrête un conteneur quand son processus principal se termine. Sans commande, Ubuntu n'a rien à faire et s'arrête.

### 2. Oublier -d pour un service

```bash
# ❌ Problème : terminal bloqué
docker run nginx
# Votre terminal est bloqué, impossible de faire autre chose

# ✅ Solution
docker run -d nginx
```

### 3. Utiliser --rm avec des données importantes

```bash
# ❌ Danger : perte de données
docker run --rm -d --name db postgres
# À l'arrêt, toutes les données de la DB sont perdues !

# ✅ Solution : ne pas utiliser --rm pour des conteneurs avec état
docker run -d --name db postgres
# Ou utiliser des volumes pour la persistance (autre partie du cours)
```

### 4. Conflit de noms

```bash
# ❌ Erreur
docker run -d --name web nginx
docker run -d --name web nginx
# Error: The container name "/web" is already in use

# ✅ Solution : supprimer ou renommer
docker rm web
# ou
docker run -d --name web2 nginx
```

### 5. Oublier -it pour un shell interactif

```bash
# ❌ Expérience dégradée
docker run ubuntu bash
# Pas de prompt, pas d'interaction propre

# ✅ Correct
docker run -it ubuntu bash
```

### 6. Utiliser -d avec -it

```bash
# ⚠️ Comportement contre-intuitif
docker run -d -it ubuntu bash
# Le conteneur démarre en arrière-plan mais vous n'y êtes pas attaché

# ✅ Choisir l'un ou l'autre selon le besoin
docker run -it ubuntu bash     # Pour interaction immédiate
docker run -d ubuntu tail -f /dev/null  # Pour arrière-plan
```

---

## Bonnes pratiques

### 1. Toujours nommer les conteneurs importants

```bash
# ❌ À éviter
docker run -d nginx

# ✅ Recommandé
docker run -d --name web_frontend nginx
```

**Pourquoi ?** Facilite la gestion, la maintenance et le debugging.

### 2. Utiliser --rm pour les conteneurs temporaires

```bash
# ✅ Tests et scripts
docker run --rm python:3.11 python script.py

# ✅ Sessions de développement
docker run --rm -it node:18 bash
```

**Pourquoi ?** Évite l'accumulation de conteneurs arrêtés qui consomment de l'espace disque.

### 3. Choisir le bon mode selon le contexte

```bash
# ✅ Services : mode détaché
docker run -d --name api myapi:latest

# ✅ Debugging : mode interactif
docker run -it --name debug myapp bash
```

### 4. Utiliser des noms descriptifs

```bash
# ❌ Peu clair
docker run -d --name c1 nginx

# ✅ Descriptif
docker run -d --name frontend_nginx_prod nginx
```

**Convention de nommage** : `[fonction]_[techno]_[environnement]`

### 5. Vérifier avant de réutiliser un nom

```bash
# ✅ Vérifier et nettoyer si nécessaire
docker ps -a | grep mon_conteneur
docker rm mon_conteneur 2>/dev/null  # Supprime sans erreur si n'existe pas
docker run -d --name mon_conteneur nginx
```

### 6. Préférer les images officielles et légères

```bash
# ✅ Version Alpine pour la légèreté
docker run -d --name web nginx:alpine

# ✅ Version spécifique pour la reproductibilité
docker run -d --name api node:18.17-alpine
```

### 7. Documenter les options complexes

```bash
# ✅ Script avec commentaires
docker run -d \
  --name production_api \           # Nom explicite
  --restart unless-stopped \         # Redémarrage auto (autre partie)
  -e NODE_ENV=production \          # Variables d'environnement
  myapi:1.2.3                        # Version précise
```

---

## Astuces

### 1. Raccourcis pour les IDs de conteneurs

```bash
# Vous n'avez pas besoin de l'ID complet
docker stop 8f3a9c7b2e1d4a5f6b8c9d0e1f2a3b4c5d6e7f8
# Seulement les premiers caractères uniques suffisent
docker stop 8f3
```

### 2. Créer des alias pour les commandes fréquentes

```bash
# Dans votre .bashrc ou .zshrc
alias drun='docker run --rm -it'
alias drunb='docker run -d'

# Utilisation
drun ubuntu bash
drunb --name web nginx
```

### 3. Inspecter un conteneur qui plante immédiatement

```bash
# Le conteneur plante au démarrage
docker run myapp  # Se termine immédiatement

# Astuce : ouvrir un shell à la place
docker run -it myapp bash
# Ou
docker run -it --entrypoint bash myapp
```

### 4. Récupérer l'ID du dernier conteneur créé

```bash
# Stocker l'ID dans une variable
CONTAINER_ID=$(docker run -d nginx)
echo "Conteneur créé : $CONTAINER_ID"

# Utiliser directement dans une commande
docker logs $(docker run -d nginx)
```

### 5. Nommer avec des timestamps pour l'unicité

```bash
# Génération automatique de noms uniques
docker run -d --name "web_$(date +%s)" nginx
# Crée : web_1703592845
```

### 6. Tester rapidement une image

```bash
# One-liner pour explorer une image
docker run --rm -it IMAGE sh -c "ls -la && cat /etc/*-release"

# Exemple
docker run --rm -it alpine sh -c "ls -la && cat /etc/*-release"
```

### 7. Vérifier qu'un conteneur tourne correctement

```bash
# Lancer et vérifier en une ligne
docker run -d --name test nginx && docker ps | grep test && echo "✓ OK"
```

### 8. Détacher puis réattacher proprement

```bash
# Démarrer en interactif
docker run -it --name shell ubuntu bash

# Détacher sans arrêter : Ctrl+P puis Ctrl+Q

# Vérifier qu'il tourne
docker ps | grep shell

# Réattacher plus tard
docker attach shell
```

### 9. Utiliser watch pour surveiller les conteneurs

```bash
# Surveiller en temps réel les conteneurs créés
watch -n 1 'docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.CreatedAt}}"'
```

### 10. Combiner run avec inspect pour le debugging

```bash
# Lancer et inspecter immédiatement
CID=$(docker run -d nginx) && docker inspect $CID | grep IPAddress
```

---

## 📝 Résumé des commandes essentielles

```bash
# Création basique
docker run IMAGE

# Service en arrière-plan avec nom
docker run -d --name NOM IMAGE

# Session interactive temporaire
docker run --rm -it IMAGE bash

# Combinaison complète pour service
docker run -d --name NOM -p PORT:PORT IMAGE

# Combinaison complète pour développement
docker run --rm -it --name NOM -v $(pwd):/app IMAGE bash
```

---

> [!tip] Prochaine étape Maintenant que vous maîtrisez la création et le démarrage des conteneurs, vous serez prêt à apprendre leur gestion avancée : arrêt, redémarrage, suppression, et inspection de leur état.