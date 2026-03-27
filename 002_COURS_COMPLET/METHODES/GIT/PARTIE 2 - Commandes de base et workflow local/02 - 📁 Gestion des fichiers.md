

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

## 🔍 git status

### Qu'est-ce que c'est ?

`git status` est la commande la plus utilisée en Git. Elle affiche l'état actuel de votre répertoire de travail et de la zone de staging (index). C'est votre boussole dans Git.

### Pourquoi l'utiliser ?

- **Connaître l'état de vos fichiers** : modifiés, non suivis, en staging
- **Éviter les surprises** avant un commit
- **Vérifier sur quelle branche** vous travaillez
- **Identifier les conflits** après un merge

### Syntaxe

```bash
# Affichage complet de l'état
git status

# Affichage court (format condensé)
git status -s
git status --short

# Afficher aussi les fichiers ignorés
git status --ignored
```

### Les différents états d'un fichier

> [!info] Les zones dans Git Git gère trois zones principales :
> 
> 1. **Working Directory** (répertoire de travail) : vos fichiers actuels
> 2. **Staging Area/Index** : fichiers préparés pour le commit
> 3. **Repository** : historique des commits

```bash
# Exemple de sortie de git status
On branch main
Your branch is up to date with 'origin/main'.

Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
        modified:   fichier1.txt      # ✅ En staging
        new file:   fichier2.txt      # ✅ En staging

Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes)
        modified:   fichier3.txt      # ⚠️ Modifié mais pas en staging

Untracked files:
  (use "git add <file>..." to include in what will be committed)
        fichier4.txt                  # 🆕 Non suivi par Git
```

### Format court (-s)

```bash
git status -s

# Sortie :
M  fichier1.txt    # Modified in staging
 M fichier3.txt    # Modified in working directory
MM fichier5.txt    # Modified in both staging and working
A  fichier2.txt    # Added to staging
?? fichier4.txt    # Untracked
```

> [!tip] Astuce Utilisez `git status` **systématiquement** avant et après chaque opération Git. C'est gratuit et ça évite beaucoup d'erreurs !

### Pièges courants

|Piège|Explication|
|---|---|
|Fichiers modifiés après staging|Un fichier peut être à la fois en staging ET modifié dans le working directory|
|Fichiers ignorés invisibles|Les fichiers dans `.gitignore` n'apparaissent pas par défaut|
|État trompeur|Ne pas faire `git status` avant un commit = risque de commiter plus ou moins que prévu|

---

## ➕ git add

### Qu'est-ce que c'est ?

`git add` ajoute des fichiers à la zone de staging (index). C'est la première étape pour enregistrer vos modifications dans Git. On dit qu'on "stage" les fichiers.

### Pourquoi l'utiliser ?

- **Préparer un commit** : sélectionner précisément ce qui sera enregistré
- **Contrôle granulaire** : commiter certaines modifications et pas d'autres
- **Créer des commits atomiques** : un commit = une fonctionnalité/correction

### Syntaxe

```bash
# Ajouter un fichier spécifique
git add fichier.txt

# Ajouter plusieurs fichiers
git add fichier1.txt fichier2.txt fichier3.txt

# Ajouter tous les fichiers modifiés et nouveaux
git add .

# Ajouter tous les fichiers du projet (depuis la racine)
git add -A
git add --all

# Ajouter uniquement les fichiers modifiés (pas les nouveaux)
git add -u
git add --update

# Ajouter de manière interactive
git add -i
git add --interactive

# Ajouter des parties d'un fichier (patch mode)
git add -p
git add --patch

# Ajouter tous les fichiers d'un dossier
git add dossier/

# Ajouter selon un pattern
git add "*.txt"
git add "src/**/*.js"
```

### Différences entre les options

|Commande|Nouveaux fichiers|Fichiers modifiés|Fichiers supprimés|
|---|---|---|---|
|`git add .`|✅|✅|✅|
|`git add -A`|✅|✅|✅|
|`git add -u`|❌|✅|✅|
|`git add fichier.txt`|✅|✅|✅|

> [!warning] Attention `git add .` ajoute tout **depuis votre répertoire courant**. Si vous êtes dans un sous-dossier, seuls les fichiers de ce dossier seront ajoutés. Utilisez `git add -A` pour tout ajouter depuis la racine du projet.

### Mode interactif (-i)

```bash
git add -i

# Menu interactif :
           staged     unstaged path
  1:    unchanged        +0/-1 README.md
  2:    unchanged        +5/-0 src/app.js

*** Commands ***
  1: status       2: update       3: revert       4: add untracked
  5: patch        6: diff         7: quit         8: help
What now>
```

### Mode patch (-p)

Le mode le plus puissant : permet d'ajouter des modifications **ligne par ligne** ou **par bloc**.

```bash
git add -p fichier.txt

# Git affiche chaque bloc de modifications :
diff --git a/fichier.txt b/fichier.txt
@@ -1,3 +1,4 @@
 ligne 1
+ligne ajoutée
 ligne 2
 ligne 3

# Options :
# y - stage this hunk (oui)
# n - do not stage this hunk (non)
# q - quit; do not stage this or remaining hunks (quitter)
# a - stage this hunk and all later hunks in the file (tout)
# d - do not stage this hunk or any later hunks (rien)
# s - split the current hunk into smaller hunks (diviser)
# e - manually edit the current hunk (éditer manuellement)
# ? - print help (aide)
```

> [!example] Exemple d'utilisation du mode patch Vous avez modifié un fichier en ajoutant une fonctionnalité ET en corrigeant un bug. Vous voulez faire 2 commits séparés :
> 
> ```bash
> # Ajouter seulement la correction du bug
> git add -p fichier.js
> # Sélectionner 'y' pour le bug, 'n' pour la fonctionnalité
> git commit -m "fix: correction du bug"
> 
> # Ajouter la fonctionnalité
> git add fichier.js
> git commit -m "feat: ajout de la nouvelle fonctionnalité"
> ```

### Pièges courants

> [!warning] Piège : Fichiers modifiés après staging Si vous modifiez un fichier APRÈS l'avoir ajouté au staging, les nouvelles modifications ne seront PAS dans le prochain commit.
> 
> ```bash
> git add fichier.txt        # Le fichier est en staging
> # Vous modifiez encore fichier.txt
> git status
> # Vous verrez :
> # Changes to be committed:
> #   modified:   fichier.txt
> # Changes not staged for commit:
> #   modified:   fichier.txt
> ```

> [!warning] Piège : git add . dans un sous-dossier
> 
> ```bash
> cd src/components/
> git add .    # ⚠️ N'ajoute que les fichiers de src/components/
> 
> # Préférez :
> git add -A   # ✅ Ajoute tout depuis la racine
> ```

### Bonnes pratiques

1. **Vérifier avant d'ajouter** : `git status` puis `git diff`
2. **Commits atomiques** : n'ajoutez que les fichiers liés à une même fonctionnalité
3. **Utiliser -p pour la précision** : quand un fichier contient plusieurs modifications distinctes
4. **Éviter `git add .` aveuglément** : vérifiez toujours ce que vous ajoutez

> [!tip] Astuce : Annuler un git add
> 
> ```bash
> # Retirer un fichier du staging (sans perdre les modifications)
> git restore --staged fichier.txt
> 
> # Ou l'ancienne syntaxe (toujours valide)
> git reset HEAD fichier.txt
> 
> # Retirer tous les fichiers du staging
> git restore --staged .
> ```

---

## 💾 git commit

### Qu'est-ce que c'est ?

`git commit` enregistre les fichiers en staging dans l'historique Git. C'est un **snapshot** (instantané) de votre projet à un moment donné. Chaque commit a un identifiant unique (hash SHA-1).

### Pourquoi l'utiliser ?

- **Sauvegarder votre travail** de manière permanente
- **Créer un historique** consultable et réversible
- **Documenter les changements** avec des messages descriptifs
- **Collaborer efficacement** : partager des modifications atomiques

### Syntaxe

```bash
# Commit avec éditeur de texte pour le message
git commit

# Commit avec message en ligne
git commit -m "message du commit"

# Commit avec message détaillé (titre + description)
git commit -m "titre" -m "description détaillée"

# Ajouter automatiquement les fichiers modifiés ET commiter
git commit -a -m "message"
git commit -am "message"

# Modifier le dernier commit (message et/ou contenu)
git commit --amend

# Modifier le dernier commit sans changer le message
git commit --amend --no-edit

# Commit avec signature GPG
git commit -S -m "message"

# Commit vide (pour déclencher un CI par exemple)
git commit --allow-empty -m "trigger CI"
```

### Anatomie d'un commit

Un commit contient :

```
commit abc123def456... (hash SHA-1 unique)
Author: Jean Dupont <jean@example.com>
Date:   Mon Dec 16 10:30:00 2024 +0100

    feat: ajout de la fonctionnalité de recherche
    
    - Implémentation de la barre de recherche
    - Ajout des filtres par catégorie
    - Tests unitaires inclus
```

> [!info] Structure d'un commit
> 
> - **Hash** : identifiant unique (ex: `abc123...`)
> - **Author** : qui a créé le commit
> - **Date** : quand le commit a été créé
> - **Message** : description des modifications
> - **Parent(s)** : commit(s) précédent(s) (non visible dans `git log` simple)
> - **Tree** : snapshot des fichiers

### Écrire un bon message de commit

> [!example] Convention Conventional Commits Format : `<type>(<scope>): <description>`
> 
> **Types courants :**
> 
> - `feat`: nouvelle fonctionnalité
> - `fix`: correction de bug
> - `docs`: documentation
> - `style`: formatage, point-virgules manquants, etc.
> - `refactor`: refactoring de code
> - `test`: ajout ou modification de tests
> - `chore`: tâches de maintenance
> 
> **Exemples :**
> 
> ```bash
> git commit -m "feat(auth): ajout de l'authentification OAuth"
> git commit -m "fix(api): correction de la gestion d'erreur 404"
> git commit -m "docs(readme): mise à jour des instructions d'installation"
> ```

#### Règles pour un bon message

```bash
# ✅ BON - Message clair et concis
git commit -m "fix: correction du calcul de TVA pour les produits en promo"

# ❌ MAUVAIS - Message vague
git commit -m "fix bug"

# ✅ BON - Message détaillé avec description
git commit -m "refactor: réorganisation du module de paiement" \
           -m "- Extraction de la logique de validation dans un service séparé
- Ajout de tests unitaires pour chaque méthode de paiement
- Amélioration de la gestion des erreurs réseau"

# ❌ MAUVAIS - Message trop long en une ligne
git commit -m "j'ai corrigé le bug qui faisait que quand on cliquait..."
```

**Règles d'or :**

1. **Utiliser l'impératif** : "ajoute" pas "ajouté" ni "ajouter"
2. **Première ligne ≤ 50 caractères** (titre)
3. **Ligne vide** entre le titre et la description
4. **Description ≤ 72 caractères par ligne**
5. **Expliquer le QUOI et le POURQUOI**, pas le comment

### Commit avec -a (auto-staging)

```bash
# Sans -a (méthode standard) :
git add fichier.txt
git commit -m "message"

# Avec -a (raccourci) :
git commit -am "message"
```

> [!warning] Attention avec -a `git commit -a` ajoute SEULEMENT les fichiers **déjà suivis** qui ont été **modifiés**. Il n'ajoute PAS :
> 
> - Les nouveaux fichiers (untracked)
> - Les fichiers supprimés (sauf si vous utilisez `git rm`)
> 
> Préférez la méthode standard pour un meilleur contrôle !

### Modifier un commit avec --amend

```bash
# Vous venez de faire un commit mais vous avez oublié un fichier
git add fichier-oublie.txt
git commit --amend --no-edit

# Vous voulez changer le message du dernier commit
git commit --amend -m "nouveau message"

# Vous voulez modifier le message dans l'éditeur
git commit --amend
```

> [!warning] Danger de --amend `--amend` **réécrit l'historique**. Ne l'utilisez JAMAIS sur un commit déjà partagé (pushed) avec d'autres personnes ! Cela créera des conflits.
> 
> ✅ OK : `--amend` sur un commit local non partagé ❌ DANGER : `--amend` sur un commit déjà pushé

### Pièges courants

|Piège|Solution|
|---|---|
|Message de commit vague|Prendre 30 secondes pour écrire un message clair|
|Commits trop gros|Faire des commits atomiques (une fonctionnalité = un commit)|
|Oubli de fichiers|Vérifier `git status` avant de commiter|
|Utiliser -a aveuglément|Préférer `git add` explicite puis `git commit`|
|Amender un commit public|Ne JAMAIS utiliser `--amend` sur un commit pushé|

### Bonnes pratiques

1. **Commits atomiques** : un commit = une modification logique
2. **Commiter souvent** : ne pas attendre d'avoir terminé toute une fonctionnalité
3. **Messages descriptifs** : imaginez que vous lisez le message dans 6 mois
4. **Vérifier avant de commiter** : `git status` puis `git diff --staged`
5. **Convention de nommage** : adoptez une convention (Conventional Commits, etc.)

> [!tip] Astuce : Configurer l'éditeur de commit
> 
> ```bash
> # Utiliser VS Code pour les messages de commit
> git config --global core.editor "code --wait"
> 
> # Utiliser Vim
> git config --global core.editor "vim"
> 
> # Utiliser Nano
> git config --global core.editor "nano"
> ```

> [!tip] Astuce : Template de message
> 
> ```bash
> # Créer un template de message
> echo "# <type>(<scope>): <description>
> # 
> # [description détaillée optionnelle]
> # 
> # [footer optionnel]" > ~/.gitmessage.txt
> 
> # Configurer Git pour utiliser ce template
> git config --global commit.template ~/.gitmessage.txt
> ```

---

## 📜 git log

### Qu'est-ce que c'est ?

`git log` affiche l'historique des commits. C'est votre machine à voyager dans le temps pour comprendre l'évolution du projet.

### Pourquoi l'utiliser ?

- **Consulter l'historique** du projet
- **Comprendre les modifications** : qui, quand, pourquoi
- **Trouver des bugs** : quand un bug a été introduit
- **Générer des changelogs** : documenter les versions
- **Naviguer dans le code** : retrouver une fonctionnalité

### Syntaxe de base

```bash
# Affichage complet de l'historique
git log

# Limiter le nombre de commits affichés
git log -n 5        # Les 5 derniers commits
git log -3          # Les 3 derniers commits

# Format condensé (une ligne par commit)
git log --oneline

# Afficher un graphe des branches
git log --graph

# Combiner plusieurs options
git log --oneline --graph --all --decorate
```

### Formats d'affichage

#### Format par défaut

```bash
git log

# Sortie :
commit abc123def456... (HEAD -> main, origin/main)
Author: Jean Dupont <jean@example.com>
Date:   Mon Dec 16 10:30:00 2024 +0100

    feat: ajout de la fonctionnalité de recherche
    
    - Implémentation de la barre de recherche
    - Ajout des filtres par catégorie

commit 789ghi012jkl...
Author: Marie Martin <marie@example.com>
Date:   Mon Dec 16 09:15:00 2024 +0100

    fix: correction du bug d'affichage mobile
```

#### Format --oneline (le plus utilisé)

```bash
git log --oneline

# Sortie :
abc123d (HEAD -> main) feat: ajout de la recherche
789ghi0 fix: correction bug mobile
456mno7 refactor: nettoyage du code
123pqr4 docs: mise à jour README
```

#### Format personnalisé

```bash
# Format custom avec couleurs
git log --pretty=format:"%Cred%h%Creset - %s %Cgreen(%cr)%Creset %C(bold blue)<%an>%Creset"

# Format détaillé avec statistiques
git log --stat

# Format avec les modifications (patch)
git log -p

# Format avec graphe complet
git log --oneline --graph --all --decorate
```

> [!example] Alias utile pour un bel historique
> 
> ```bash
> # Créer un alias pour un log visuel
> git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
> 
> # Utilisation :
> git lg
> 
> # Sortie :
> * abc123d - (HEAD -> main) feat: ajout de la recherche (2 hours ago) <Jean>
> * 789ghi0 - fix: correction bug mobile (5 hours ago) <Marie>
> * 456mno7 - refactor: nettoyage du code (1 day ago) <Jean>
> ```

### Filtrer l'historique

#### Par nombre et date

```bash
# Les 10 derniers commits
git log -10

# Commits depuis une date
git log --since="2024-12-01"
git log --since="2 weeks ago"
git log --since="yesterday"

# Commits jusqu'à une date
git log --until="2024-12-15"

# Combinaison
git log --since="1 month ago" --until="1 week ago"
```

#### Par auteur

```bash
# Commits d'un auteur spécifique
git log --author="Jean"
git log --author="jean@example.com"

# Plusieurs auteurs
git log --author="Jean\|Marie"
```

#### Par message de commit

```bash
# Rechercher dans les messages
git log --grep="fix"
git log --grep="bug" --grep="error"
git log --grep="feature" --oneline

# Recherche insensible à la casse
git log --grep="bug" -i
```

#### Par fichier

```bash
# Historique d'un fichier spécifique
git log fichier.txt
git log src/app.js

# Historique avec les modifications
git log -p fichier.txt

# Suivre un fichier même s'il a été renommé
git log --follow fichier.txt

# Commits qui ont modifié un dossier
git log src/
```

#### Par contenu

```bash
# Rechercher les commits qui ont ajouté ou supprimé un mot
git log -S "function login"

# Rechercher par regex
git log -G "function.*login"
```

### Visualiser les modifications

```bash
# Afficher les fichiers modifiés
git log --name-only

# Afficher les fichiers avec statut (A=ajouté, M=modifié, D=supprimé)
git log --name-status

# Afficher les statistiques (lignes ajoutées/supprimées)
git log --stat

# Afficher les modifications complètes (patch)
git log -p

# Limiter le patch à un fichier
git log -p fichier.txt
```

### Historique des branches

```bash
# Tous les commits de toutes les branches
git log --all

# Graphe de toutes les branches
git log --oneline --graph --all

# Commits d'une branche spécifique
git log develop
git log feature/nouvelle-fonctionnalite

# Commits de la branche actuelle pas dans main
git log main..HEAD

# Commits dans main mais pas dans la branche actuelle
git log HEAD..main

# Différence entre deux branches
git log main..develop
```

### Options avancées

```bash
# Afficher les commits de merge
git log --merges

# Exclure les commits de merge
git log --no-merges

# Afficher uniquement les premiers/derniers parents dans les merges
git log --first-parent

# Inverser l'ordre (du plus ancien au plus récent)
git log --reverse

# Format compact avec graphe (très utile)
git log --oneline --graph --decorate --all

# Recherche avancée : commits avec "fix" SANS "test"
git log --grep="fix" --grep="test" --invert-grep
```

### Formats de sortie personnalisés

```bash
# Variables disponibles :
# %H  = hash complet
# %h  = hash abrégé
# %an = nom de l'auteur
# %ae = email de l'auteur
# %ad = date de l'auteur
# %ar = date relative (ex: "2 hours ago")
# %s  = sujet (message)
# %d  = decorations (branches, tags)

# Format simple et lisible
git log --pretty=format:"%h - %s (%ar) <%an>"

# Format détaillé
git log --pretty=format:"%C(yellow)%h%Creset %C(blue)%ad%Creset | %s %C(green)(%ar)%Creset %C(bold)<%an>%Creset" --date=short

# Format pour export (CSV-like)
git log --pretty=format:"%h;%an;%ae;%ad;%s" --date=short > commits.csv
```

### Pièges courants

> [!warning] Log trop verbeux `git log` sans options peut afficher des centaines de commits. Utilisez toujours des filtres ou `--oneline`.

> [!warning] Confusion entre --since et --after `--since` et `--after` sont identiques, tout comme `--until` et `--before`. Choisissez celui qui vous semble le plus intuitif.

### Bonnes pratiques

1. **Utiliser --oneline par défaut** : plus lisible
2. **Créer des alias** : `git lg`, `git l`, etc.
3. **Combiner avec grep** : `git log --oneline | grep "feature"`
4. **Utiliser le graphe** : pour comprendre les branches
5. **Limiter les résultats** : `-n 10` pour éviter la surcharge

> [!tip] Mes alias recommandés
> 
> ```bash
> # Historique simple
> git config --global alias.l "log --oneline -20"
> 
> # Historique visuel complet
> git config --global alias.lg "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --all"
> 
> # Historique avec stats
> git config --global alias.ls "log --stat --oneline -10"
> 
> # Qui a modifié quoi récemment
> git config --global alias.recent "log --oneline --all --graph --decorate -20"
> ```

### Naviguer dans les résultats

Quand `git log` affiche beaucoup de résultats, Git utilise un pager (généralement `less`) :

```
# Commandes dans less :
# j ou ↓     : ligne suivante
# k ou ↑     : ligne précédente
# d          : page suivante (down)
# u          : page précédente (up)
# /texte     : rechercher "texte"
# n          : occurrence suivante
# N          : occurrence précédente
# q          : quitter
# h          : aide
```

---

## 🔄 git diff

### Qu'est-ce que c'est ?

`git diff` affiche les différences entre différentes versions de fichiers. C'est votre microscope pour examiner précisément ce qui a changé.

### Pourquoi l'utiliser ?

- **Vérifier les modifications** avant de commiter
- **Comprendre ce qui a changé** entre deux commits
- **Éviter les erreurs** : relire le code modifié
- **Résoudre des bugs** : voir ce qui a été changé récemment
- **Code review** : examiner les modifications avant un merge

### Syntaxe de base

```bash
# Différences entre working directory et staging area
git diff

# Différences entre staging area et dernier commit
git diff --staged
git diff --cached

# Différences entre working directory et dernier commit
git diff HEAD

# Différences pour un fichier spécifique
git diff fichier.txt

# Différences entre deux commits
git diff commit1 commit2

# Différences entre deux branches
git diff branche1 branche2
```

### Les trois comparaisons principales

> [!info] Les trois zones à comparer
> 
> 1. **Working Directory** : vos fichiers actuels (non stagés)
> 2. **Staging Area (Index)** : fichiers préparés pour le commit
> 3. **Repository (HEAD)** : dernier commit
> 
> ```
> Working Directory  →  Staging Area  →  Repository (HEAD)
>       |                    |                |
>       |← git diff ---------|                |
>       |← git diff HEAD --------------------|
>       |                    |← git diff --staged
> ```

#### 1. Working Directory vs Staging

```bash
# Voir ce qui n'est PAS encore staged
git diff

# Exemple de sortie :
diff --git a/fichier.txt b/fichier.txt
index 1234567..abcdefg 100644
--- a/fichier.txt
+++ b/fichier.txt
@@ -1,3 +1,4 @@
 ligne 1
-ligne 2 ancienne
+ligne 2 modifiée
+ligne ajoutée
 ligne 3
```

#### 2. Staging vs Repository (HEAD)

```bash
# Voir ce qui SERA dans le prochain commit
git diff --staged
git diff --cached    # Synonyme

# Très utile avant un commit !
git diff --staged    # Vérifier ce qui sera committé
git commit -m "..."  # Puis commiter en toute confiance
```

#### 3. Working Directory vs Repository

```bash
# Toutes les modifications depuis le dernier commit (stagées + non stagées)
git diff HEAD
```

### Comparer des commits

```bash
# Différence entre deux commits (par hash)
git diff abc123d 456efgh

# Différence avec le commit précédent
git diff HEAD~1 HEAD
git diff HEAD~1        # Raccourci

# Différence avec N commits en arrière
git diff HEAD~3        # 3 commits avant HEAD
git diff HEAD~5 HEAD~2 # Entre le 5ème et le 2ème commit avant HEAD

# Différence entre un commit et maintenant
git diff abc123d
```

### Comparer des branches

```bash
# Différences entre deux branches
git diff main develop

# Ce qui est dans develop mais pas dans main
git diff main..develop

# Ce qui a changé dans develop depuis qu'elle a divergé de main
git diff main...develop  # Triple point !

# Fichiers modifiés entre deux branches
git diff --name-only main develop

# Statistiques des différences
git diff --stat main develop
```

> [!info] Double point vs Triple point
> 
> - `main..develop` : différences entre les deux branches
> - `main...develop` : différences depuis le point de divergence (merge-base)
> 
> Le triple point est plus utile pour les code reviews car il montre uniquement les changements de la feature branch.

### Filtrer les différences

#### Par fichier

```bash
# Un fichier spécifique
git diff fichier.txt

# Plusieurs fichiers
git diff fichier1.txt fichier2.txt

# Tous les fichiers d'un dossier
git diff src/

# Fichiers selon un pattern
git diff "*.js"
git diff "src/**/*.vue"
```

#### Par type de modification

```bash
# Uniquement les noms de fichiers modifiés
git diff --name-only

# Noms de fichiers avec statut (A/M/D)
git diff --name-status

# Statistiques (lignes ajoutées/supprimées par fichier)
git diff --stat

# Statistiques courtes
git diff --shortstat
```

#### Par contenu

```bash
# Ignorer les changements d'espaces
git diff -w
git diff --ignore-all-space

# Ignorer les changements de fin de ligne
git diff --ignore-space-at-eol

# Ignorer les changements dans les lignes vides
git diff --ignore-blank-lines

# Rechercher des différences contenant un mot
git diff -S "function"
git diff -G "class.*User"
```

### Formats d'affichage

```bash
# Format côte à côte (side-by-side)
git diff --color-words

# Voir le contexte (lignes autour des modifications)
git diff -U10          # 10 lignes de contexte au lieu de 3
git diff --unified=10

# Format minimal (sans contexte)
git diff -U0

# Afficher uniquement les lignes ajoutées
git diff --diff-filter=A

# Afficher uniquement les lignes modifiées
git diff --diff-filter=M

# Afficher uniquement les fichiers supprimés
git diff --diff-filter=D
```

### Lire un diff

```diff
diff --git a/fichier.txt b/fichier.txt        # Fichiers comparés
index 1234567..abcdefg 100644                  # Métadonnées (hash)
--- a/fichier.txt                              # Version ancienne (-)
+++ b/fichier.txt                              # Version nouvelle (+)
@@ -1,3 +1,4 @@                                # Position : ligne 1, 3 lignes → ligne 1, 4 lignes
 ligne 1                                       # Ligne inchangée (contexte)
-ligne 2 ancienne                              # Ligne supprimée (rouge)
+ligne 2 modifiée                              # Ligne ajoutée (vert)
+ligne ajoutée                                 # Ligne ajoutée (vert)
 ligne 3                                       # Ligne inchangée (contexte)
```

> [!info] Comprendre le format @@ @@ `@@ -1,3 +1,4 @@` signifie :
> 
> - **Ancien fichier** : à partir de la ligne 1, 3 lignes
> - **Nouveau fichier** : à partir de la ligne 1, 4 lignes
> - Une ligne a été ajoutée (3 → 4)

### Options avancées

```bash
# Ignorer les modifications de permissions
git diff --no-ext-diff

# Comparer uniquement les fichiers binaires
git diff --binary

# Afficher les différences de sous-modules
git diff --submodule

# Format patch (pour envoyer par email)
git diff > modifications.patch

# Appliquer un patch
git apply modifications.patch

# Différences avec statistiques détaillées
git diff --numstat

# Différences en une ligne par fichier
git diff --compact-summary
```

### Cas d'usage pratiques

#### Avant un commit

```bash
# 1. Voir toutes les modifications non stagées
git diff

# 2. Voir ce qui sera committé
git diff --staged

# 3. Vérifier un fichier spécifique
git diff --staged fichier.js

# 4. Si tout est bon, commit
git commit -m "message"
```

#### Comparer votre travail avec la branche principale

```bash
# Voir ce que vous avez fait sur votre branche feature
git diff main

# Avec statistiques
git diff --stat main

# Uniquement les fichiers modifiés
git diff --name-only main
```

#### Trouver quand une ligne a changé

```bash
# Voir les modifications d'une fonction spécifique
git diff -S "function login"

# Voir l'historique de modifications d'une ligne
git log -p -S "function login"
```

#### Code Review

```bash
# Voir toutes les modifications d'une feature branch
git diff main...feature/nouvelle-fonctionnalite

# Avec les noms de fichiers uniquement
git diff --name-status main...feature/nouvelle-fonctionnalite

# Examiner fichier par fichier
git diff main...feature/nouvelle-fonctionnalite -- src/app.js
```

### Outils visuels pour les diffs

```bash
# Utiliser un outil graphique (si configuré)
git difftool

# Configurer un difftool (exemple avec VS Code)
git config --global diff.tool vscode
git config --global difftool.vscode.cmd 'code --wait --diff $LOCAL $REMOTE'

# Configurer avec Meld
git config --global diff.tool meld

# Utiliser le difftool configuré
git difftool main develop
```

### Pièges courants

> [!warning] Diff vide alors que git status montre des modifications **Cause** : Les modifications sont déjà en staging **Solution** : Utilisez `git diff --staged` au lieu de `git diff`

> [!warning] Trop de contexte rend le diff illisible **Solution** : Réduisez le contexte avec `-U0` ou `-U1`
> 
> ```bash
> git diff -U1  # Une seule ligne de contexte
> ```

> [!warning] Différences dues aux espaces/tabs **Solution** : Ignorez les espaces
> 
> ```bash
> git diff -w  # Ignore tous les changements d'espaces
> ```

### Bonnes pratiques

1. **Toujours utiliser git diff avant git commit** : vérifiez ce que vous commitez
2. **git diff --staged avant chaque commit** : dernière vérification
3. **Utiliser -w pour ignorer les espaces** : focus sur le code réel
4. **Comparer avec le triple point (...) pour les branches** : voir uniquement vos modifications
5. **Configurer un difftool visuel** : plus confortable pour les gros diffs

> [!tip] Alias utiles pour git diff
> 
> ```bash
> # Diff des fichiers stagés
> git config --global alias.ds "diff --staged"
> 
> # Diff avec statistiques
> git config --global alias.dstat "diff --stat"
> 
> # Diff ignore whitespace
> git config --global alias.dw "diff -w"
> 
> # Voir uniquement les fichiers modifiés
> git config --global alias.dname "diff --name-only"
> 
> # Utilisation :
> git ds        # au lieu de git diff --staged
> git dstat     # au lieu de git diff --stat
> ```

> [!tip] Coloration syntaxique
> 
> ```bash
> # Activer la coloration (normalement activée par défaut)
> git config --global color.diff auto
> 
> # Personnaliser les couleurs
> git config --global color.diff.meta "yellow bold"
> git config --global color.diff.old "red bold"
> git config --global color.diff.new "green bold"
> ```

### Combinaisons puissantes

```bash
# Voir les modifications non commitées avec statistiques
git diff HEAD --stat

# Comparer deux branches en ignorant les espaces
git diff -w main develop

# Voir uniquement les fichiers JavaScript modifiés entre deux commits
git diff --name-only abc123d def456e -- "*.js"

# Statistiques détaillées d'une feature branch
git diff --stat --summary main...feature/auth

# Rechercher toutes les modifications contenant "TODO"
git diff | grep -C3 "TODO"

# Export d'un diff en fichier pour review
git diff main > review.diff
```

### Raccourcis clavier dans le pager

Quand `git diff` affiche beaucoup de contenu, Git utilise `less` :

```
# Navigation :
# j ou ↓     : ligne suivante
# k ou ↑     : ligne précédente
# d          : demi-page suivante
# u          : demi-page précédente
# f ou Space : page suivante
# b          : page précédente
# g          : début du fichier
# G          : fin du fichier

# Recherche :
# /pattern   : rechercher "pattern" vers le bas
# ?pattern   : rechercher "pattern" vers le haut
# n          : occurrence suivante
# N          : occurrence précédente

# Autres :
# q          : quitter
# h          : aide
```

---

## 🎯 Récapitulatif

### Workflow typique

```bash
# 1. Vérifier l'état actuel
git status

# 2. Voir les modifications non stagées
git diff

# 3. Ajouter les fichiers au staging
git add fichier1.txt fichier2.txt

# 4. Vérifier ce qui sera committé
git diff --staged

# 5. Commiter avec un message clair
git commit -m "feat: ajout de la fonctionnalité X"

# 6. Vérifier l'historique
git log --oneline -5
```

### Commandes essentielles à retenir

|Commande|Usage principal|
|---|---|
|`git status`|Connaître l'état actuel (TOUJOURS faire avant autre chose)|
|`git add <fichier>`|Préparer des fichiers pour le commit|
|`git add -p`|Ajouter des modifications par blocs (contrôle précis)|
|`git commit -m "msg"`|Enregistrer les modifications|
|`git commit --amend`|Corriger le dernier commit (attention si déjà pushé)|
|`git log --oneline`|Voir l'historique condensé|
|`git log --graph`|Visualiser les branches|
|`git diff`|Voir modifications non stagées|
|`git diff --staged`|Voir ce qui sera committé|
|`git diff HEAD`|Voir toutes les modifications depuis le dernier commit|

### Checklist avant chaque commit

> [!example] Checklist du commit parfait
> 
> - [ ] `git status` : vérifier les fichiers modifiés
> - [ ] `git diff` : relire les modifications
> - [ ] `git add` : ajouter uniquement les fichiers pertinents
> - [ ] `git diff --staged` : vérifier ce qui sera committé
> - [ ] Message clair et descriptif
> - [ ] Commit atomique (une seule fonctionnalité/correction)
> - [ ] `git log --oneline -3` : vérifier que le commit apparaît bien

### Commandes pour se rattraper

```bash
# J'ai ajouté un fichier par erreur au staging
git restore --staged fichier.txt

# J'ai oublié un fichier dans mon dernier commit (non pushé)
git add fichier-oublie.txt
git commit --amend --no-edit

# Je veux changer le message du dernier commit (non pushé)
git commit --amend -m "nouveau message"

# Je veux voir ce que j'ai fait dans mon dernier commit
git show
git log -1 -p

# Je veux annuler toutes mes modifications non commitées
git restore .          # Annule working directory
git restore --staged . # Retire du staging
```

---

## 📚 Synthèse visuelle

```
┌─────────────────────────────────────────────────────────────┐
│                     WORKFLOW GIT LOCAL                      │
└─────────────────────────────────────────────────────────────┘

Working Directory         Staging Area           Repository
  (fichiers)                (index)              (commits)
      │                        │                      │
      │  git add fichier.txt   │                      │
      ├───────────────────────>│                      │
      │                        │  git commit -m "..."  │
      │                        ├─────────────────────>│
      │                        │                      │
      │  git diff              │                      │
      │<─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─>│                      │
      │                        │  git diff --staged   │
      │                        │<─ ─ ─ ─ ─ ─ ─ ─ ─ ─>│
      │              git diff HEAD                    │
      │<─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─ ─>│
      │                        │                      │
      │  git restore fichier   │                      │
      │<───────────────────────┤                      │
      │                        │  git restore --staged│
      │                        │<─────────────────────┤
      │                        │                      │
                               
    git status : voir l'état de toutes les zones
    git log    : voir l'historique des commits
```

### États d'un fichier

```
┌──────────────┐
│  Untracked   │  Nouveau fichier, Git ne le suit pas
└──────┬───────┘
       │ git add
       ↓
┌──────────────┐
│   Staged     │  Prêt pour le commit
│  (à commit)  │
└──────┬───────┘
       │ git commit
       ↓
┌──────────────┐
│  Unmodified  │  Dans le repo, pas de changement
└──────┬───────┘
       │ modification
       ↓
┌──────────────┐
│   Modified   │  Modifié mais pas stagé
└──────┬───────┘
       │ git add
       ↓
   (retour à Staged)
```

---

## 💡 Astuces de pro

### 1. Configuration recommandée

```bash
# Éditeur pour les messages de commit
git config --global core.editor "code --wait"

# Couleurs activées
git config --global color.ui auto

# Alias utiles
git config --global alias.st "status -s"
git config --global alias.co "commit"
git config --global alias.lg "log --oneline --graph --all"
git config --global alias.ds "diff --staged"
git config --global alias.last "log -1 HEAD --stat"

# Template de commit
git config --global commit.template ~/.gitmessage.txt
```

### 2. Commandes composées

```bash
# Voir les fichiers modifiés ET les modifications
git status && git diff --stat

# Add, commit et log en une fois (à utiliser avec prudence)
git add -A && git commit -m "message" && git log -1

# Voir le dernier commit avec détails
git log -1 -p
```

### 3. Recherche avancée

```bash
# Trouver qui a modifié une ligne (blame)
git log -p -S "ma fonction" -- fichier.js

# Chercher dans les messages de commit
git log --grep="bug" --oneline

# Chercher par auteur et date
git log --author="Jean" --since="1 week ago" --oneline
```

### 4. Productivité

```bash
# Voir rapidement ce qui a changé aujourd'hui
git log --since="midnight" --author="$(git config user.name)" --oneline

# Statistiques de votre travail
git log --author="$(git config user.name)" --stat --since="1 week ago"

# Compter les commits par auteur
git shortlog -s -n

# Voir les fichiers les plus modifiés
git log --pretty=format: --name-only | sort | uniq -c | sort -rg | head -10
```

> [!tip] Commande magique : git show
> 
> ```bash
> # Voir le dernier commit avec toutes les infos
> git show
> 
> # Voir un commit spécifique
> git show abc123d
> 
> # Voir un fichier à un commit donné
> git show abc123d:fichier.txt
> 
> # Voir les modifications d'un fichier dans un commit
> git show abc123d -- fichier.txt
> ```

---

## ⚠️ Erreurs fréquentes et solutions

### Erreur 1 : "J'ai committé trop tôt"

```bash
# Solution : amend (si pas encore pushé)
git add fichier-oublie.txt
git commit --amend --no-edit
```

### Erreur 2 : "J'ai committé sur la mauvaise branche"

```bash
# Cette solution sera vue dans une autre partie du cours
# Pour l'instant : évitez cette erreur en vérifiant git status !
git status  # Toujours vérifier la branche actuelle
```

### Erreur 3 : "Mon diff est illisible (trop d'espaces)"

```bash
# Solution : ignorer les whitespaces
git diff -w
```

### Erreur 4 : "Je ne vois rien avec git diff mais git status montre des modifications"

```bash
# Cause : les fichiers sont déjà en staging
# Solution :
git diff --staged  # Voir les modifications stagées
```

### Erreur 5 : "J'ai fait un commit avec un mauvais message"

```bash
# Solution : amend (si pas encore pushé)
git commit --amend -m "nouveau message correct"
```

### Erreur 6 : "git log affiche trop de commits"

```bash
# Solutions :
git log -10           # Limiter le nombre
git log --oneline     # Format condensé
git log --since="1 week ago"  # Filtrer par date
```

---

## 🎓 Exercice de validation

> [!example] Mini-projet pour pratiquer Créez un petit projet et pratiquez le workflow :
> 
> ```bash
> # 1. Créer un repo
> mkdir test-git && cd test-git
> git init
> 
> # 2. Créer et commiter un fichier
> echo "# Mon Projet" > README.md
> git add README.md
> git commit -m "docs: ajout du README"
> 
> # 3. Modifier le fichier
> echo "Description du projet" >> README.md
> 
> # 4. Vérifier l'état et les différences
> git status
> git diff
> 
> # 5. Ajouter et vérifier avant commit
> git add README.md
> git diff --staged
> 
> # 6. Commiter
> git commit -m "docs: ajout de la description"
> 
> # 7. Voir l'historique
> git log --oneline
> git log -2 -p
> 
> # 8. Créer un nouveau fichier
> echo "console.log('Hello');" > app.js
> 
> # 9. Utiliser git add -p pour un contrôle précis
> echo "const x = 1;" >> app.js
> echo "const y = 2;" >> app.js
> git add -p app.js
> 
> # 10. Vérifier tout le workflow
> git status
> git diff HEAD
> git log --oneline --graph
> ```

---

**🎉 Vous maîtrisez maintenant les commandes de gestion des fichiers avec Git !**

Ces 5 commandes (`status`, `add`, `commit`, `log`, `diff`) constituent 80% de votre utilisation quotidienne de Git. Prenez le temps de les pratiquer jusqu'à ce qu'elles deviennent des réflexes naturels.