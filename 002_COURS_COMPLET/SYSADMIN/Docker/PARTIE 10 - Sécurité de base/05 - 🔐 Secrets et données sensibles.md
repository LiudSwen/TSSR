

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

La gestion des données sensibles (mots de passe, clés API, certificats, tokens) est un enjeu majeur de sécurité dans Docker. Des secrets mal protégés peuvent compromettre l'ensemble d'une infrastructure.

> [!warning] Enjeu de sécurité Les secrets exposés dans les images Docker ou les logs sont accessibles à quiconque a accès à ces ressources. Une fuite peut avoir des conséquences graves : accès non autorisés, vol de données, compromission de services tiers.

---

## Variables d'environnement

### Déclaration et utilisation

Les variables d'environnement sont le mécanisme le plus simple pour transmettre des paramètres de configuration à un conteneur.

#### ✅ Dans un Dockerfile

```dockerfile
# Définir une variable d'environnement par défaut
ENV DATABASE_HOST=localhost
ENV DATABASE_PORT=5432
ENV APP_ENV=production

# Les variables peuvent être utilisées dans les instructions
RUN echo "Connexion à $DATABASE_HOST:$DATABASE_PORT"
```

#### ✅ Avec docker run

```bash
# Passer une variable individuelle
docker run -e DATABASE_PASSWORD=monMotDePasse mon-image

# Passer plusieurs variables
docker run \
  -e DATABASE_HOST=db.example.com \
  -e DATABASE_PORT=5432 \
  -e DATABASE_USER=admin \
  mon-image

# Charger depuis un fichier .env
docker run --env-file .env mon-image
```

#### ✅ Dans Docker Compose

```yaml
version: '3.8'

services:
  app:
    image: mon-app
    environment:
      # Syntaxe clé: valeur
      DATABASE_HOST: db.example.com
      DATABASE_PORT: 5432
      # Syntaxe clé=valeur
      - APP_ENV=production
    
  db:
    image: postgres:15
    env_file:
      # Charger depuis un fichier
      - ./config/database.env
```

#### ✅ Accès dans l'application

```bash
# Dans un conteneur, les variables sont accessibles normalement
echo $DATABASE_HOST

# En Python
import os
db_host = os.getenv('DATABASE_HOST')

# En Node.js
const dbHost = process.env.DATABASE_HOST;
```

> [!example] Exemple de fichier .env
> 
> ```bash
> # config/database.env
> DATABASE_HOST=postgres-server
> DATABASE_PORT=5432
> DATABASE_NAME=myapp_db
> DATABASE_USER=app_user
> # ⚠️ NE PAS mettre de mot de passe ici pour la production !
> DATABASE_PASSWORD=changeme
> ```

### Limites et risques de sécurité

> [!warning] Risques majeurs des variables d'environnement

Les variables d'environnement présentent plusieurs failles de sécurité importantes :

#### 🚨 Visibilité dans l'historique des images

```bash
# Les variables ENV dans un Dockerfile sont inscrites dans les layers
docker history mon-image
# Résultat : toutes les valeurs ENV sont visibles !

# Même problème avec docker inspect
docker inspect mon-conteneur
# Affiche toutes les variables d'environnement en clair
```

#### 🚨 Exposition dans les logs

```bash
# Si votre application log au démarrage...
echo "Connexion à la base avec le mot de passe: $DB_PASSWORD"
# ⚠️ Ce mot de passe sera dans les logs Docker !

docker logs mon-conteneur
# Le secret est maintenant visible dans les logs
```

#### 🚨 Accessible via /proc

```bash
# Dans un conteneur Linux, les variables sont dans le filesystem
docker exec mon-conteneur cat /proc/1/environ
# Affiche toutes les variables d'environnement du processus principal
```

#### 🚨 Transmises aux processus enfants

Tous les processus lancés depuis votre application héritent des variables d'environnement, augmentant la surface d'attaque.

> [!info] Quand utiliser les variables d'environnement ?
> 
> - ✅ Configuration non sensible (URLs publiques, ports, noms d'hôtes)
> - ✅ Paramètres de comportement de l'application (niveau de log, mode debug)
> - ✅ Feature flags et configurations d'environnement
> - ❌ Mots de passe, clés API, tokens d'authentification
> - ❌ Certificats ou clés de chiffrement

---

## Docker Secrets

### Qu'est-ce qu'un secret Docker ?

Docker Secrets est un mécanisme conçu spécifiquement pour gérer les données sensibles de manière sécurisée.

> [!info] Caractéristiques clés
> 
> - Les secrets sont chiffrés au repos et en transit
> - Ils sont stockés dans un gestionnaire de secrets (Swarm ou externe)
> - Ils sont montés dans le conteneur comme des fichiers en mémoire (tmpfs)
> - Ils ne sont jamais écrits sur le disque du conteneur
> - Ils ne sont pas visibles dans `docker inspect` ou les logs

#### 🔍 Fonctionnement

```
┌─────────────────────┐
│  Docker Swarm ou    │
│  Orchestrateur      │
│  (stockage chiffré) │
└──────────┬──────────┘
           │
           │ Chiffrement TLS
           │
           ▼
┌─────────────────────┐
│   Conteneur         │
│                     │
│  /run/secrets/      │ ← Montage tmpfs (RAM)
│    ├── db_password  │
│    └── api_key      │
└─────────────────────┘
```

### Utilisation de base

> [!warning] Prérequis Docker Secrets nécessite Docker Swarm mode. Pour un usage local sans Swarm, voir les alternatives dans les bonnes pratiques.

#### ✅ Créer un secret

```bash
# Depuis un fichier
echo "mon_mot_de_passe_super_secret" | docker secret create db_password -

# Depuis un fichier existant
docker secret create api_key ./api_key.txt

# Lister les secrets
docker secret ls

# Inspecter un secret (ne montre PAS la valeur)
docker secret inspect db_password
```

#### ✅ Utiliser un secret dans un service

```bash
# Créer un service avec accès à un secret
docker service create \
  --name mon-app \
  --secret db_password \
  --secret api_key \
  mon-image

# Le conteneur peut maintenant lire :
# /run/secrets/db_password
# /run/secrets/api_key
```

#### ✅ Dans Docker Compose (Swarm mode)

```yaml
version: '3.8'

services:
  app:
    image: mon-app
    secrets:
      - db_password
      - api_key
    environment:
      # On peut pointer vers le fichier secret
      DATABASE_PASSWORD_FILE: /run/secrets/db_password

secrets:
  db_password:
    external: true
  api_key:
    file: ./secrets/api_key.txt
```

#### ✅ Lire un secret dans l'application

```bash
# Dans le conteneur
cat /run/secrets/db_password

# En Python
def get_secret(secret_name):
    try:
        with open(f'/run/secrets/{secret_name}', 'r') as f:
            return f.read().strip()
    except FileNotFoundError:
        return None

db_password = get_secret('db_password')

# En Node.js
const fs = require('fs');
const dbPassword = fs.readFileSync('/run/secrets/db_password', 'utf8').trim();

# En Bash
DB_PASSWORD=$(cat /run/secrets/db_password)
```

### Différences avec les variables d'environnement

|Critère|Variables d'environnement|Docker Secrets|
|---|---|---|
|**Sécurité au repos**|❌ Texte clair|✅ Chiffré|
|**Visibilité**|❌ Visible dans `inspect`, logs|✅ Caché|
|**Stockage**|❌ Dans les layers d'image|✅ Hors de l'image|
|**Transmission**|❌ Réseau non chiffré possible|✅ TLS obligatoire|
|**Montage**|❌ En mémoire du processus|✅ tmpfs (RAM)|
|**Rotation**|❌ Redémarrage requis|✅ Peut être dynamique|
|**Compatibilité**|✅ Docker run, Compose|⚠️ Swarm ou alternatives|
|**Facilité d'usage**|✅ Très simple|⚠️ Plus complexe|

> [!tip] Astuce de migration De nombreuses applications supportent le suffixe `_FILE` pour les variables d'environnement :
> 
> ```yaml
> environment:
>   DATABASE_PASSWORD_FILE: /run/secrets/db_password
> ```
> 
> L'application lit alors le contenu du fichier au lieu de la variable directement.

---

## Bonnes pratiques de gestion

### Principe du moindre privilège

> [!tip] Principe fondamental Chaque conteneur ne doit avoir accès qu'aux secrets dont il a strictement besoin.

```yaml
version: '3.8'

services:
  frontend:
    image: mon-frontend
    secrets:
      # Le frontend n'a accès qu'à sa clé API
      - frontend_api_key
  
  backend:
    image: mon-backend
    secrets:
      # Le backend a accès aux secrets de base de données
      - db_password
      - jwt_secret
  
  admin:
    image: mon-admin
    secrets:
      # L'admin a accès à tous les secrets
      - db_password
      - jwt_secret
      - admin_master_key

secrets:
  frontend_api_key:
    file: ./secrets/frontend_api.txt
  db_password:
    external: true
  jwt_secret:
    external: true
  admin_master_key:
    external: true
```

### Rotation des secrets

La rotation régulière des secrets limite l'impact d'une compromission.

#### 📅 Stratégie de rotation

```bash
# 1. Créer un nouveau secret avec un nom versionné
echo "nouveau_mot_de_passe" | docker secret create db_password_v2 -

# 2. Mettre à jour le service pour utiliser le nouveau secret
docker service update \
  --secret-rm db_password \
  --secret-add source=db_password_v2,target=db_password \
  mon-service

# 3. Après validation, supprimer l'ancien
docker secret rm db_password

# 4. Renommer le nouveau (optionnel)
# Note: Docker ne permet pas de renommer, créer un alias si nécessaire
```

> [!warning] Coordination nécessaire Pour les secrets partagés (comme les mots de passe de base de données), assurez-vous que :
> 
> - Le nouveau secret est créé dans le système cible (ex: nouveau user DB)
> - Tous les services sont mis à jour avant de révoquer l'ancien
> - Un rollback est possible en cas de problème

#### 🔄 Automatisation recommandée

```yaml
# Exemple de stratégie avec dates
secrets:
  db_password_2025_01:
    external: true
  db_password_2025_02:
    external: true
  # Rotation mensuelle automatisée via CI/CD
```

### Fichiers .env et .dockerignore

#### ✅ Structure recommandée

```bash
mon-projet/
├── .env.example          # Template avec des valeurs factices
├── .env                  # Valeurs réelles (JAMAIS commité)
├── .env.local            # Overrides locaux
├── .dockerignore         # Exclusions pour le build
├── .gitignore            # Exclusions pour Git
└── docker-compose.yml
```

#### ✅ Fichier .env.example

```bash
# .env.example - Valeurs d'exemple pour la documentation
DATABASE_HOST=localhost
DATABASE_PORT=5432
DATABASE_NAME=myapp
DATABASE_USER=myapp_user
DATABASE_PASSWORD=CHANGEME_BEFORE_USE

API_KEY=your_api_key_here
JWT_SECRET=generate_secure_random_string

# Instructions pour l'équipe
# 1. Copier ce fichier vers .env
# 2. Remplacer toutes les valeurs CHANGEME
# 3. Ne jamais commiter le fichier .env
```

#### ✅ Fichier .dockerignore

```bash
# .dockerignore - Exclure les secrets du build context
.env
.env.local
.env.production
*.env

# Secrets
secrets/
*.key
*.pem
*.crt
*.p12

# Configurations sensibles
config/secrets/
*_password.txt
*_token.txt

# Fichiers de développement
.git/
.gitignore
README.md
node_modules/
```

> [!warning] Piège courant Le `.dockerignore` protège uniquement le **build context**. Les secrets ne doivent jamais être copiés dans l'image elle-même :
> 
> ```dockerfile
> # ❌ MAUVAIS - copie le secret dans l'image
> COPY .env /app/.env
> 
> # ✅ BON - passer via variables d'environnement ou secrets
> # (aucune instruction COPY pour les secrets)
> ```

### Ne jamais commiter les secrets

#### 🛡️ Protection Git

```bash
# .gitignore - Protection multi-niveaux
# Secrets généraux
.env
.env.*
!.env.example
*.secret
secrets/

# Fichiers de configuration sensibles
config/production/
*.key
*.pem
*.p12
*.pfx

# Backups potentiellement sensibles
*.sql
*.dump
backup/

# Logs (peuvent contenir des secrets)
*.log
logs/
```

#### 🚨 Si un secret a été commité

```bash
# 1. Supprimer le secret de l'historique Git (DANGEREUX)
git filter-branch --force --index-filter \
  'git rm --cached --ignore-unmatch chemin/vers/secret.txt' \
  --prune-empty --tag-name-filter cat -- --all

# 2. Forcer le push (affecte tous les collaborateurs)
git push origin --force --all

# 3. IMPORTANT : Révoquer et remplacer le secret exposé
# Le secret commité est maintenant public, même après suppression

# Alternative moderne : utiliser git-filter-repo
# https://github.com/newren/git-filter-repo
pip install git-filter-repo
git filter-repo --path secret.txt --invert-paths
```

> [!warning] En cas de fuite
> 
> 1. **Considérer le secret comme compromis** immédiatement
> 2. **Révoquer** le secret dans tous les systèmes concernés
> 3. **Générer et déployer** un nouveau secret
> 4. **Analyser** l'impact potentiel de la fuite
> 5. **Nettoyer** l'historique Git (attention, opération destructive)

#### 🔍 Détection préventive

```bash
# Pre-commit hook pour détecter les secrets
# .git/hooks/pre-commit

#!/bin/bash
# Rechercher des patterns de secrets
if git diff --cached | grep -E '(password|secret|api_key|private_key).*=.*[A-Za-z0-9]{20,}'; then
    echo "❌ Possible secret détecté dans le commit !"
    echo "Vérifiez les fichiers avant de commiter."
    exit 1
fi
```

### Outils complémentaires

#### 🔧 Pour le développement local

```yaml
# docker-compose.override.yml (pour développement local)
# Ce fichier peut être commité car il ne contient pas de vraies valeurs
version: '3.8'

services:
  app:
    environment:
      DATABASE_PASSWORD: dev_password_local
      DEBUG: "true"
    volumes:
      # Montage de secrets locaux en développement
      - ./secrets/local:/run/secrets:ro
```

#### 🔧 Gestionnaires de secrets tiers

Pour la production, envisagez des solutions robustes :

- **HashiCorp Vault** : Gestionnaire de secrets centralisé avec API
- **AWS Secrets Manager** : Intégration native AWS
- **Azure Key Vault** : Pour les environnements Azure
- **Google Secret Manager** : Pour GCP
- **Kubernetes Secrets** : Si vous utilisez K8s

#### 🔧 Alternative sans Swarm : docker-compose avec fichiers

```yaml
# docker-compose.yml (sans Swarm)
version: '3.8'

services:
  app:
    image: mon-app
    volumes:
      # Monter les secrets comme volumes read-only
      - ./secrets/db_password:/run/secrets/db_password:ro
      - ./secrets/api_key:/run/secrets/api_key:ro
```

```bash
# Créer la structure des secrets
mkdir -p secrets
echo "mon_password" > secrets/db_password
echo "ma_cle_api" > secrets/api_key
chmod 600 secrets/*

# S'assurer que secrets/ est dans .gitignore
echo "secrets/" >> .gitignore
```

> [!tip] Checklist de sécurité
> 
> - ✅ Aucun secret dans le code source ou les Dockerfiles
> - ✅ `.env` et `secrets/` dans `.gitignore` et `.dockerignore`
> - ✅ Utilisation de Docker Secrets ou montage en lecture seule
> - ✅ Principe du moindre privilège appliqué
> - ✅ Rotation régulière des secrets planifiée
> - ✅ Monitoring des accès aux secrets
> - ✅ Plan de réponse en cas de fuite

---

> [!info] Résumé des concepts clés
> 
> **Variables d'environnement**
> 
> - Simple et universellement supporté
> - Adapté aux configurations non sensibles
> - Risques : visibles dans inspect, logs, historique
> 
> **Docker Secrets**
> 
> - Chiffrement bout en bout
> - Montage sécurisé en tmpfs
> - Nécessite Swarm ou alternatives
> 
> **Bonnes pratiques**
> 
> - Ne jamais commiter de secrets
> - Principe du moindre privilège
> - Rotation régulière
> - Utiliser `.dockerignore` et `.gitignore`
> - Envisager des gestionnaires de secrets pour la production