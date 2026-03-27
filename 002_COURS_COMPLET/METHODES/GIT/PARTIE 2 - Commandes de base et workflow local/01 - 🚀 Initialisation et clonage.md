

## 📋 Table des matières

```table-of-contents
title: 
style: nestedList # TOC style (nestedList|nestedOrderedList|inlineFirstLevel)
minLevel: 2 # Include headings from the specified level
maxLevel: 3 # Include headings up to the specified level
include: 
exclude: 
includeLinks: true # Make headings clickable
hideWhenEmpty: false # Hide TOC if no headings are found
debugInConsole: false # Print debug info in Obsidian console
```

---

## 🎯 Introduction

L'initialisation et le clonage sont les deux portes d'entrée pour travailler avec Git. Ces commandes créent l'environnement nécessaire pour le versionnage de votre code. Comprendre leur fonctionnement et la structure qu'elles créent est essentiel pour maîtriser Git.

---

## 📦 git init - Créer un nouveau dépôt

### Qu'est-ce que git init ?

`git init` transforme un dossier ordinaire en **dépôt Git**. Cette commande crée la structure nécessaire pour que Git puisse suivre les modifications de vos fichiers. C'est le point de départ lorsque vous commencez un nouveau projet depuis zéro.

> [!info] Définition Un **dépôt Git** (ou repository) est un dossier contenant un sous-dossier `.git` qui stocke toute l'historique et la configuration du projet.

### Syntaxe et options

#### Syntaxe de base

```bash
# Initialiser dans le dossier courant
git init

# Initialiser dans un nouveau dossier spécifique
git init <nom-du-dossier>
```

#### Options utiles

```bash
# Créer un dépôt "bare" (sans working directory)
# Utilisé principalement pour les serveurs Git
git init --bare

# Spécifier le nom de la branche initiale
git init --initial-branch=main
# ou version courte
git init -b main

# Initialiser avec un template personnalisé
git init --template=<chemin-template>
```

> [!example] Exemple pratique
> 
> ```bash
> # Créer un nouveau projet
> mkdir mon-projet
> cd mon-projet
> git init
> 
> # Résultat affiché
> # Initialized empty Git repository in /chemin/vers/mon-projet/.git/
> 
> # Vérifier la création du dépôt
> ls -la
> # Vous verrez le dossier .git
> ```

### Quand utiliser git init ?

|Situation|Utiliser git init|
|---|---|
|🆕 Nouveau projet local|✅ Oui|
|📂 Projet existant sans Git|✅ Oui|
|🌐 Récupérer un projet distant|❌ Non (utiliser `git clone`)|
|🔄 Réinitialiser un dépôt existant|⚠️ Rarement (destructif)|

> [!tip] Astuce Avant de faire `git init`, créez un fichier `.gitignore` pour éviter de tracker des fichiers inutiles dès le premier commit.

### Pièges courants

> [!warning] Attention aux dossiers imbriqués Ne faites **jamais** `git init` dans un dossier qui est déjà à l'intérieur d'un autre dépôt Git. Cela crée des dépôts imbriqués qui causent des problèmes complexes.
> 
> ```bash
> # ❌ MAUVAIS
> ~/projet/.git/          # Dépôt parent
> ~/projet/module/.git/   # Dépôt imbriqué - À ÉVITER !
> ```

> [!warning] Réinitialiser un dépôt existant Faire `git init` dans un dossier qui contient déjà un `.git` ne le supprime pas, mais peut causer des incohérences. Si vous devez vraiment recommencer :
> 
> ```bash
> # Supprimer l'ancien dépôt
> rm -rf .git
> # Puis réinitialiser
> git init
> ```

---

## 🔗 git clone - Copier un dépôt existant

### Qu'est-ce que git clone ?

`git clone` crée une **copie complète** d'un dépôt Git existant (local ou distant). Cette commande télécharge non seulement les fichiers actuels, mais aussi tout l'historique des commits, toutes les branches, et configure automatiquement la connexion avec le dépôt d'origine.

> [!info] Ce que clone fait automatiquement
> 
> - Crée un nouveau dossier
> - Initialise un dépôt Git (comme `git init`)
> - Télécharge tout l'historique
> - Crée une branche locale liée à la branche distante
> - Configure le "remote" appelé `origin`

### Syntaxe et options

#### Syntaxe de base

```bash
# Cloner un dépôt dans un nouveau dossier
git clone <url-du-depot>

# Cloner dans un dossier avec un nom spécifique
git clone <url-du-depot> <nom-dossier>
```

#### Options utiles

```bash
# Cloner seulement la branche principale (plus rapide)
git clone --single-branch <url>

# Cloner avec une profondeur limitée (historique partiel)
git clone --depth 1 <url>
# Utile pour de très gros dépôts, économise de l'espace

# Cloner une branche spécifique
git clone --branch <nom-branche> <url>
# ou version courte
git clone -b <nom-branche> <url>

# Cloner sans checkout (ne crée pas les fichiers de travail)
git clone --no-checkout <url>

# Cloner de manière "bare" (dépôt nu, pour serveur)
git clone --bare <url>

# Cloner récursivement avec les sous-modules
git clone --recursive <url>
```

> [!example] Exemples pratiques
> 
> ```bash
> # Cloner un dépôt GitHub
> git clone https://github.com/utilisateur/projet.git
> 
> # Cloner avec un nom de dossier personnalisé
> git clone https://github.com/utilisateur/projet.git mon-projet-local
> 
> # Cloner seulement le dernier commit (clone léger)
> git clone --depth 1 https://github.com/utilisateur/gros-projet.git
> 
> # Cloner une branche spécifique
> git clone -b develop https://github.com/utilisateur/projet.git
> ```

### Différences avec git init

|Aspect|git init|git clone|
|---|---|---|
|**Usage**|Créer un nouveau dépôt|Copier un dépôt existant|
|**Historique**|Aucun (dépôt vide)|Complet (tous les commits)|
|**Remote**|Aucun configuré|`origin` configuré automatiquement|
|**Branches**|Une seule (nouvelle)|Toutes les branches distantes|
|**Fichiers**|Dossier vide|Tous les fichiers du projet|

> [!tip] Quand utiliser quoi ?
> 
> - **git init** : Vous commencez un projet from scratch
> - **git clone** : Vous rejoignez un projet existant ou récupérez votre propre code depuis un serveur

### Bonnes pratiques

> [!tip] Organisation des clones
> 
> ```bash
> # Créer une structure organisée
> ~/projets/
>   ├── personnel/
>   │   ├── mon-site/
>   │   └── mon-app/
>   ├── travail/
>   │   ├── projet-client-a/
>   │   └── projet-client-b/
>   └── opensource/
>       ├── contribution-1/
>       └── contribution-2/
> ```

> [!tip] Vérifier avant de cloner
> 
> ```bash
> # Vérifier que le dossier n'existe pas déjà
> ls mon-projet
> # Si le dossier existe, choisir un autre nom ou le supprimer
> 
> # Vérifier l'URL du dépôt
> # Pour GitHub, vous pouvez la trouver avec le bouton "Code"
> ```

> [!warning] Clones et espace disque Un clone complet peut être volumineux pour de gros projets. Si vous n'avez besoin que des fichiers récents :
> 
> ```bash
> # Clone superficiel (shallow clone)
> git clone --depth 1 <url>
> # Télécharge seulement le dernier état, pas tout l'historique
> ```

---

## 📁 Structure du dossier .git

### Vue d'ensemble

Le dossier `.git` est le **cerveau** de votre dépôt. Il contient toutes les informations nécessaires au fonctionnement de Git : l'historique complet, les branches, la configuration, les références, etc.

> [!warning] À ne jamais toucher Le dossier `.git` est géré automatiquement par Git. Vous ne devriez **jamais** modifier son contenu manuellement, sauf si vous savez exactement ce que vous faites.

```
.git/
├── HEAD              # Pointe vers la branche courante
├── config            # Configuration locale du dépôt
├── description       # Description du dépôt (rarement utilisé)
├── hooks/            # Scripts automatiques (pré-commit, post-merge, etc.)
├── info/             # Informations et exclusions locales
│   └── exclude       # Patterns à ignorer (comme .gitignore mais local)
├── objects/          # Base de données des objets Git
│   ├── pack/         # Fichiers packés (optimisation d'espace)
│   └── info/         # Informations sur les objets
├── refs/             # Références (branches et tags)
│   ├── heads/        # Branches locales
│   ├── remotes/      # Branches distantes
│   └── tags/         # Tags
├── logs/             # Historique des modifications de références
└── index             # Zone de staging (fichiers en attente de commit)
```

### Fichiers et dossiers principaux

#### HEAD

```bash
# Contenu typique du fichier HEAD
ref: refs/heads/main
```

> [!info] Rôle de HEAD `HEAD` est un pointeur qui indique sur quelle branche vous êtes actuellement. Quand vous changez de branche, Git met à jour ce fichier.

#### config

```bash
# Exemple de contenu du fichier config
[core]
    repositoryformatversion = 0
    filemode = true
    bare = false
    logallrefupdates = true
[remote "origin"]
    url = https://github.com/utilisateur/projet.git
    fetch = +refs/heads/*:refs/remotes/origin/*
[branch "main"]
    remote = origin
    merge = refs/heads/main
```

> [!info] Configuration locale Ce fichier contient la configuration spécifique à ce dépôt : les remotes, les branches trackées, des options de comportement, etc.

#### objects/

> [!info] Base de données Git Le dossier `objects/` contient **tous les objets Git** :
> 
> - **Blobs** : Contenu des fichiers
> - **Trees** : Structure des dossiers
> - **Commits** : Instantanés de l'état du projet
> - **Tags annotés** : Tags avec métadonnées
> 
> Ces objets sont stockés de manière compressée et identifiés par leur hash SHA-1.

```bash
# Exemple de structure
objects/
├── 0a/
│   └── 3b4f2c8d9e1a7b6c5d4e3f2a1b0c9d8e7f6a5b4  # Hash d'un objet
├── 1c/
│   └── 7e9f3a2b1c0d9e8f7a6b5c4d3e2f1a0b9c8d7  # Hash d'un autre objet
├── pack/
│   ├── pack-abc123...pack   # Fichiers packés
│   └── pack-abc123...idx    # Index des packs
└── info/
```

#### refs/

> [!info] Système de références Le dossier `refs/` contient les pointeurs vers les commits :
> 
> - **refs/heads/** : Chaque fichier représente une branche locale
> - **refs/remotes/** : Branches suivies depuis les dépôts distants
> - **refs/tags/** : Tags créés dans le dépôt

```bash
# Exemple de contenu d'une référence de branche
# Fichier : refs/heads/main
a3b2c1d0e9f8a7b6c5d4e3f2a1b0c9d8e7f6a5b4

# Ce hash pointe vers le commit le plus récent de la branche
```

#### index

> [!info] La zone de staging Le fichier `index` (aussi appelé "staging area") contient la liste des fichiers qui seront inclus dans le prochain commit. C'est un fichier binaire que Git met à jour automatiquement.

#### hooks/

```bash
hooks/
├── pre-commit.sample      # Exemple de hook pré-commit
├── pre-push.sample        # Exemple de hook pré-push
├── post-merge.sample      # Exemple de hook post-merge
└── ...
```

> [!tip] Hooks Git Les hooks sont des scripts qui s'exécutent automatiquement à certains moments (avant un commit, après un merge, etc.). Pour activer un hook, renommez le fichier `.sample` en supprimant ce suffixe et rendez-le exécutable.
> 
> ```bash
> # Activer un hook pre-commit
> mv .git/hooks/pre-commit.sample .git/hooks/pre-commit
> chmod +x .git/hooks/pre-commit
> ```

### À ne jamais modifier manuellement

> [!warning] Zones interdites Ne modifiez **JAMAIS** directement ces éléments :
> 
> - ❌ Le dossier `objects/` (corruption de la base de données)
> - ❌ Le fichier `index` (problèmes de staging)
> - ❌ Les fichiers dans `refs/` (sauf si vous savez vraiment ce que vous faites)
> - ❌ Le fichier `HEAD` directement
> 
> **Utilisez toujours les commandes Git** pour interagir avec le dépôt.

> [!tip] Exploration sûre Vous pouvez regarder le contenu du dossier `.git` sans danger :
> 
> ```bash
> # Voir la structure
> tree .git/
> 
> # Lire HEAD
> cat .git/HEAD
> 
> # Lire la config
> cat .git/config
> 
> # Lister les branches
> ls .git/refs/heads/
> ```

> [!info] Le fichier .gitignore n'est PAS dans .git Contrairement à ce qu'on pourrait penser, `.gitignore` est un fichier normal dans votre répertoire de travail, **pas** dans le dossier `.git`. Il est versionné comme les autres fichiers de votre projet.

---

## 🎓 Points clés à retenir

|Commande|Usage|Résultat|
|---|---|---|
|`git init`|Créer un nouveau dépôt local|Dossier `.git` créé, dépôt vide|
|`git clone <url>`|Copier un dépôt existant|Copie complète avec historique et remote|

> [!tip] Mémo rapide
> 
> - **Nouveau projet** → `git init`
> - **Rejoindre un projet** → `git clone`
> - **Ne touchez jamais** au contenu de `.git/` manuellement
> - Le dossier `.git` contient **toute la magie** de Git