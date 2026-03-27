

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

## 🗄️ Repository (dépôt)

### Définition

Un **repository** (ou dépôt) est l'espace où Git stocke toutes les informations sur votre projet. C'est essentiellement une base de données qui contient l'historique complet de tous les fichiers, toutes les modifications, et toutes les métadonnées associées à votre projet.

### Les deux types de repository

|Type|Description|Localisation|
|---|---|---|
|**Repository local**|Dépôt stocké sur votre machine|`.git/` à la racine de votre projet|
|**Repository distant**|Dépôt hébergé sur un serveur (GitHub, GitLab, etc.)|Serveur externe accessible via URL|

### Structure du repository local

Le dossier `.git/` contient toute la magie de Git :

```bash
mon-projet/
├── .git/              # Le repository Git (ne jamais modifier manuellement)
│   ├── objects/       # Base de données des objets (commits, fichiers)
│   ├── refs/          # Références aux branches et tags
│   ├── HEAD           # Pointeur vers la branche actuelle
│   ├── config         # Configuration locale du projet
│   └── ...
├── src/               # Vos fichiers de code
├── README.md
└── ...
```

> [!warning] Attention Ne supprimez JAMAIS le dossier `.git/` et ne modifiez pas son contenu manuellement. C'est le cœur de votre historique Git. Sa suppression détruirait tout l'historique de versions.

### Initialiser un repository

```bash
# Créer un nouveau repository local
git init

# OU 

# Cloner un repository distant existant
git clone https://github.com/utilisateur/projet.git
```

> [!info] Info La commande `git init` crée le dossier `.git/` qui transforme un dossier ordinaire en repository Git.

### Pourquoi c'est important

Le repository est la fondation de Git. Sans lui, Git ne peut pas fonctionner. Il contient :

- L'historique complet de toutes les modifications
- Toutes les branches de développement
- Les informations de configuration
- Les métadonnées des commits (auteur, date, message)

---

## 📂 Working directory (répertoire de travail)

### Définition

Le **working directory** (répertoire de travail) est le dossier de votre projet tel que vous le voyez dans votre explorateur de fichiers. C'est l'espace où vous créez, modifiez et supprimez vos fichiers au quotidien.

### Caractéristiques

- Contient la version actuelle de vos fichiers
- C'est là que vous travaillez réellement (édition de code, création de fichiers)
- Les modifications ne sont pas automatiquement enregistrées dans Git
- Peut contenir des fichiers suivis (tracked) et non suivis (untracked)

### Visualisation

```bash
mon-projet/                    # ← WORKING DIRECTORY
├── .git/                      # Repository Git (invisible en temps normal)
├── src/
│   ├── main.js               # Fichier suivi par Git
│   └── utils.js              # Fichier modifié (changements non enregistrés)
├── README.md                  # Fichier suivi par Git
├── temp.txt                   # Fichier non suivi (nouveau fichier)
└── node_modules/              # Dossier ignoré (.gitignore)
```

### Vérifier l'état du working directory

```bash
# Afficher l'état actuel des fichiers
git status

# Afficher les différences non staged
git diff
```

> [!example] Exemple de sortie
> 
> ```bash
> $ git status
> On branch main
> Changes not staged for commit:
>   modified:   src/utils.js
> 
> Untracked files:
>   temp.txt
> ```

### Types de fichiers dans le working directory

|Type|Description|État|
|---|---|---|
|**Unmodified**|Fichier identique à la dernière version commitée|✅ À jour|
|**Modified**|Fichier modifié depuis le dernier commit|⚠️ Changements non enregistrés|
|**Untracked**|Nouveau fichier que Git ne connaît pas encore|❓ Non suivi|
|**Ignored**|Fichier explicitement ignoré (`.gitignore`)|🚫 Ignoré|

> [!tip] Astuce : Utilisez `git status` fréquemment pour connaître l'état de votre working directory. C'est l'une des commandes les plus utilisées au quotidien.

### Pourquoi c'est important

Le working directory est votre espace de travail principal. Comprendre la différence entre :

- Ce qui est dans votre working directory (vos fichiers actuels)
- Ce qui est dans le repository (l'historique Git)

...est essentiel pour maîtriser Git.

---

## 🎯 Staging area (zone de préparation)

### Définition

La **staging area** (aussi appelée "index") est une zone intermédiaire entre votre working directory et le repository. C'est là que vous préparez les modifications que vous voulez inclure dans votre prochain commit.

### Pourquoi cette étape existe

Git vous donne un contrôle précis sur ce que vous voulez enregistrer. Vous pouvez :

- Modifier 10 fichiers
- N'ajouter que 3 fichiers à la staging area
- Créer un commit avec uniquement ces 3 fichiers

> [!info] Philosophie Git : La staging area permet de créer des commits logiques et atomiques, même si vous avez fait plusieurs types de modifications en même temps.

### Le workflow à trois niveaux

```
Working Directory  →  Staging Area  →  Repository
     (édition)      →    (add)      →   (commit)
```

### Ajouter des fichiers à la staging area

```bash
# Ajouter un fichier spécifique
git add fichier.txt

# Ajouter plusieurs fichiers
git add fichier1.txt fichier2.txt

# Ajouter tous les fichiers modifiés et nouveaux
git add .

# Ajouter tous les fichiers d'un dossier
git add src/

# Ajouter de manière interactive (choisir quoi ajouter)
git add -p
```

> [!tip] Astuce : git add -p La commande `git add -p` (patch mode) vous permet de choisir interactivement quelles parties d'un fichier ajouter. Très utile pour créer des commits précis !

### Retirer des fichiers de la staging area

```bash
# Retirer un fichier de la staging area (les modifications restent dans le working directory)
git restore --staged fichier.txt

# Ancienne syntaxe (toujours valide)
git reset HEAD fichier.txt

# Retirer tous les fichiers de la staging area
git restore --staged .
```

### Visualiser la staging area

```bash
# Voir ce qui est dans la staging area
git status

# Voir les différences entre staging area et dernier commit
git diff --staged
# ou
git diff --cached
```

> [!example] Exemple pratique
> 
> ```bash
> # Situation initiale
> $ git status
> On branch main
> Changes not staged for commit:
>   modified:   login.js
>   modified:   styles.css
>   modified:   documentation.md
> 
> # Vous voulez un commit pour la fonctionnalité login seulement
> $ git add login.js
> 
> # Vérification
> $ git status
> Changes to be committed:          # ← Dans la staging area
>   modified:   login.js
> 
> Changes not staged for commit:    # ← Reste dans le working directory
>   modified:   styles.css
>   modified:   documentation.md
> ```

### Schéma des zones

```
┌─────────────────────────┐
│   Working Directory     │  Vos fichiers actuels
│  (fichiers modifiés)    │
└───────────┬─────────────┘
            │ git add
            ▼
┌─────────────────────────┐
│    Staging Area         │  Préparation du commit
│   (fichiers staged)     │
└───────────┬─────────────┘
            │ git commit
            ▼
┌─────────────────────────┐
│      Repository         │  Historique permanent
│   (commits enregistrés) │
└─────────────────────────┘
```

> [!warning] Piège courant Oublier de faire `git add` après avoir modifié un fichier ! Si vous modifiez un fichier après l'avoir ajouté à la staging area, vous devez refaire `git add` pour inclure les nouvelles modifications.

### Pourquoi c'est important

La staging area est ce qui distingue Git d'autres systèmes de contrôle de version. Elle vous permet de :

- Créer des commits organisés et logiques
- Séparer différentes modifications en plusieurs commits
- Vérifier ce que vous allez commiter avant de le faire
- Construire un historique propre et compréhensible

---

## 💾 Commit

### Définition

Un **commit** est un instantané (snapshot) de votre projet à un moment précis. C'est l'unité de base de l'historique Git. Chaque commit représente un ensemble cohérent de modifications avec un message explicatif.

### Anatomie d'un commit

Un commit contient :

|Élément|Description|
|---|---|
|**SHA-1 hash**|Identifiant unique du commit (40 caractères hexadécimaux)|
|**Auteur**|Nom et email de la personne qui a créé le commit|
|**Date**|Horodatage précis de la création|
|**Message**|Description des modifications|
|**Parent(s)**|Référence au(x) commit(s) précédent(s)|
|**Contenu**|Instantané complet des fichiers|

### Créer un commit

```bash
# Créer un commit avec un message
git commit -m "Message descriptif du commit"

# Créer un commit avec un éditeur pour un message détaillé
git commit

# Ajouter tous les fichiers modifiés ET créer le commit (attention : n'inclut pas les nouveaux fichiers)
git commit -a -m "Message"
# ou
git commit -am "Message"
```

> [!warning] Attention avec -a L'option `-a` ajoute automatiquement tous les fichiers **déjà suivis** qui ont été modifiés, mais elle n'inclut PAS les nouveaux fichiers (untracked). Pour les nouveaux fichiers, vous devez faire `git add` explicitement.

### Structure du message de commit

#### Message court (recommandé pour les petits commits)

```bash
git commit -m "Ajout de la validation du formulaire de connexion"
```

#### Message détaillé (recommandé pour les commits importants)

```bash
git commit
```

Cela ouvre votre éditeur avec cette structure :

```
Titre du commit en moins de 50 caractères

Description détaillée du commit (optionnelle). Expliquez :
- Pourquoi cette modification est nécessaire
- Ce qui a été changé
- Tout contexte important

Fixes #123
```

> [!tip] Bonnes pratiques pour les messages
> 
> - **Titre** : Impératif présent ("Ajoute" pas "Ajouté" ou "Ajouter")
> - **Titre** : Maximum 50 caractères
> - **Ligne vide** entre le titre et la description
> - **Description** : Lignes de maximum 72 caractères
> - **Description** : Expliquez le "pourquoi", pas le "comment" (le code montre le comment)

### Exemples de bons messages

```bash
# ✅ Bon
git commit -m "Corrige le bug de validation des emails vides"

# ✅ Bon
git commit -m "Ajoute le support des images PNG dans l'upload"

# ✅ Bon (message détaillé)
"""
Implémente le cache Redis pour les requêtes API

Les requêtes vers l'API externe étaient trop lentes (>2s).
Ajout d'une couche de cache Redis avec un TTL de 1 heure
pour réduire la latence à <100ms.

Performance : 95% des requêtes sont maintenant servies depuis le cache.
"""

# ❌ Mauvais
git commit -m "fix"
git commit -m "modifications"
git commit -m "update"
git commit -m "wip"  # Work In Progress
```

### Historique des commits

```bash
# Voir l'historique des commits
git log

# Historique compact (une ligne par commit)
git log --oneline

# Historique avec graphique des branches
git log --graph --oneline --all

# Voir les détails d'un commit spécifique
git show <hash-du-commit>

# Voir les 5 derniers commits
git log -5
```

> [!example] Exemple de sortie
> 
> ```bash
> $ git log --oneline
> a3f5d2c (HEAD -> main) Ajoute la validation du formulaire
> 8b9e1f4 Corrige le bug d'affichage sur mobile
> 2c7d8a9 Implémente l'authentification utilisateur
> 5f1a3b2 Initial commit
> ```

### Modifier le dernier commit

```bash
# Modifier le message du dernier commit
git commit --amend -m "Nouveau message"

# Ajouter des fichiers oubliés au dernier commit
git add fichier-oublie.txt
git commit --amend --no-edit  # Garde le même message

# Modifier le dernier commit avec l'éditeur
git commit --amend
```

> [!warning] Attention avec --amend N'utilisez `--amend` que sur des commits qui n'ont **pas encore été poussés** sur un repository distant. Modifier un commit déjà partagé peut causer des problèmes pour les autres développeurs.

### Les commits sont immuables

Un point crucial à comprendre : un commit ne change jamais. Quand vous "modifiez" un commit avec `--amend`, Git crée en réalité un **nouveau commit** avec un nouveau hash.

```
Avant amend:
a3f5d2c → Commit original

Après amend:
b8e2a1f → Nouveau commit (hash différent)
```

### Pourquoi c'est important

Les commits sont l'essence de Git. Ils permettent de :

- Créer un historique lisible et compréhensible
- Revenir à n'importe quel état antérieur du projet
- Comprendre pourquoi une modification a été faite
- Collaborer efficacement avec d'autres développeurs
- Déboguer en identifiant quand un bug a été introduit

> [!tip] Philosophie du commit Un commit devrait représenter **une seule unité logique de changement**. Si vous utilisez "et" dans votre message de commit ("Ajoute le login ET corrige le CSS"), c'est probablement deux commits.

---

## 🔄 Les trois états d'un fichier

### Vue d'ensemble

Dans Git, chaque fichier peut se trouver dans l'un de ces trois états principaux. Comprendre ces états est fondamental pour maîtriser Git.

### Les trois états

```
┌─────────────┐         ┌─────────────┐         ┌─────────────┐
│  Modified   │  add    │   Staged    │ commit  │ Committed   │
│  (Modifié)  │ ──────> │ (Préparé)   │ ──────> │ (Enregistré)│
└─────────────┘         └─────────────┘         └─────────────┘
      │                                                 │
      └─────────────────── checkout ───────────────────┘
```

### 1. Modified (Modifié)

**Définition** : Le fichier a été modifié dans le working directory mais les changements ne sont pas encore dans la staging area.

**Localisation** : Working directory

**Commandes pour identifier** :

```bash
git status
# Affiche : "Changes not staged for commit:"

git diff
# Montre les différences exactes
```

**État typique** :

- Vous venez d'éditer un fichier
- Les modifications existent seulement sur votre disque
- Rien n'est préparé pour le commit

> [!example] Exemple
> 
> ```bash
> $ git status
> On branch main
> Changes not staged for commit:
>   modified:   app.js        # ← État Modified
> ```

### 2. Staged (Préparé)

**Définition** : Le fichier a été ajouté à la staging area et sera inclus dans le prochain commit.

**Localisation** : Staging area (index)

**Commandes pour identifier** :

```bash
git status
# Affiche : "Changes to be committed:"

git diff --staged
# Montre ce qui sera commité
```

**Comment y arriver** :

```bash
git add fichier.txt
```

**État typique** :

- Vous avez fait `git add`
- Le fichier est prêt à être commité
- Les modifications sont "marquées" pour inclusion

> [!example] Exemple
> 
> ```bash
> $ git add app.js
> $ git status
> On branch main
> Changes to be committed:
>   modified:   app.js        # ← État Staged
> ```

### 3. Committed (Enregistré)

**Définition** : Les modifications sont sauvegardées de manière permanente dans le repository Git.

**Localisation** : Repository (.git/)

**Comment y arriver** :

```bash
git commit -m "Message"
```

**État typique** :

- Les modifications font partie de l'historique
- Un nouveau commit a été créé
- Le fichier est identique à la version commitée

> [!example] Exemple
> 
> ```bash
> $ git commit -m "Améliore la fonction de recherche"
> $ git status
> On branch main
> nothing to commit, working tree clean  # ← Tout est Committed
> ```

### États additionnels (contexte)

#### Untracked (Non suivi)

Un fichier que Git ne connaît pas encore (nouveau fichier jamais ajouté).

```bash
$ git status
Untracked files:
  newfile.txt          # ← État Untracked
```

Pour passer à Staged :

```bash
git add newfile.txt
```

#### Ignored (Ignoré)

Un fichier explicitement ignoré via `.gitignore`.

```bash
# Contenu de .gitignore
node_modules/
*.log
.env
```

Ces fichiers n'apparaissent pas dans `git status`.

### Cycle de vie complet d'un fichier

```
      Nouveau fichier
            │
            ▼
   ┌─── Untracked ───┐
   │   (non suivi)   │
   └────────┬────────┘
            │ git add
            ▼
   ┌───── Staged ────┐
   │   (préparé)     │
   └────────┬────────┘
            │ git commit
            ▼
   ┌─── Committed ───┐
   │  (enregistré)   │
   └────────┬────────┘
            │ modification
            ▼
   ┌──── Modified ───┐
   │   (modifié)     │
   └────────┬────────┘
            │ git add
            ▼
        [retour à Staged]
```

### Tableau récapitulatif

|État|Localisation|Commande pour y arriver|Visible dans `git status`|
|---|---|---|---|
|**Untracked**|Working directory|Créer un nouveau fichier|"Untracked files:"|
|**Modified**|Working directory|Modifier un fichier suivi|"Changes not staged for commit:"|
|**Staged**|Staging area|`git add`|"Changes to be committed:"|
|**Committed**|Repository|`git commit`|Rien à afficher (clean)|
|**Ignored**|Working directory|Ajouter à `.gitignore`|Non affiché|

### Commandes pour naviguer entre les états

```bash
# Modified → Staged
git add fichier.txt

# Staged → Modified (annuler le staging, garder les modifications)
git restore --staged fichier.txt

# Modified → Committed (dernier état du commit)
git restore fichier.txt
# ⚠️ Attention : cette commande SUPPRIME vos modifications !

# Staged → Committed
git commit -m "Message"

# Working Directory → Committed directement (fichiers déjà suivis)
git commit -am "Message"
```

> [!warning] Pièges courants
> 
> 1. **Oublier de stage** : Modifier un fichier et faire `git commit` sans `git add` d'abord
> 2. **Stage incomplet** : Faire `git add`, puis modifier encore le fichier. La nouvelle modification n'est pas staged !
> 3. **Confusion des commandes** : `git restore` supprime les modifications, `git restore --staged` les garde mais les unstage

### Vérification rapide des états

```bash
# Tout en un coup d'œil
git status

# Version ultra-courte
git status -s
# M  modified.txt     (staged)
#  M modified2.txt    (not staged)
# ?? untracked.txt    (untracked)
```

> [!tip] Astuce professionnelle Utilisez `git status` constamment ! C'est votre boussole dans Git. Avant chaque action importante (commit, checkout, merge), vérifiez l'état de vos fichiers.

### Pourquoi ces trois états sont importants

Cette architecture à trois états permet :

1. **Contrôle granulaire** : Vous décidez précisément quoi commiter
2. **Commits atomiques** : Créer des commits logiques même après avoir fait plusieurs modifications
3. **Sécurité** : Les modifications ne sont pas enregistrées par accident
4. **Flexibilité** : Vous pouvez préparer certains fichiers pendant que vous continuez à travailler sur d'autres
5. **Workflow professionnel** : Séparer le travail en cours et le travail prêt à être partagé

---

## 🎯 Schéma récapitulatif des concepts

```
┌──────────────────────────────────────────────────────────────┐
│                    WORKING DIRECTORY                         │
│  (Vos fichiers, tels que vous les voyez)                     │
│                                                              │
│  📄 fichier.txt (Modified)    📄 nouveau.txt (Untracked)    │
└───────────────────────┬──────────────────────────────────────┘
                        │
                        │ git add
                        │
                        ▼
┌──────────────────────────────────────────────────────────────┐
│                    STAGING AREA                              │
│  (Zone de préparation)                                       │
│                                                              │
│  📄 fichier.txt (Staged - prêt à être commité)              │
└───────────────────────┬──────────────────────────────────────┘
                        │
                        │ git commit
                        │
                        ▼
┌──────────────────────────────────────────────────────────────┐
│                    REPOSITORY (.git/)                        │
│  (Historique permanent)                                      │
│                                                              │
│  💾 Commit abc123 → Commit def456 → Commit ghi789 (HEAD)    │
└──────────────────────────────────────────────────────────────┘
```

> [!info] Récapitulatif
> 
> - **Repository** : Base de données Git (le dossier `.git/`)
> - **Working directory** : Vos fichiers actuels
> - **Staging area** : Zone de préparation avant commit
> - **Commit** : Instantané permanent de votre projet
> - **Trois états** : Modified → Staged → Committed

Ces cinq concepts forment la base absolue de Git. Maîtrisez-les, et vous maîtriserez Git !