

## Table des matières

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

## Introduction

La consultation de l'historique Git est essentielle pour comprendre l'évolution de votre projet, identifier quand et pourquoi des changements ont été effectués, et déboguer des problèmes. Git offre des outils puissants pour explorer l'historique des commits de manière flexible et efficace.

> [!info] Pourquoi c'est important
> 
> - **Traçabilité** : Comprendre qui a fait quoi et quand
> - **Débogage** : Identifier quand un bug a été introduit
> - **Documentation** : L'historique raconte l'histoire du projet
> - **Collaboration** : Suivre les contributions de l'équipe

---

## La commande git log

### Utilisation basique

La commande `git log` affiche l'historique des commits du dépôt.

```bash
# Afficher l'historique complet
git log

# Sortie typique :
# commit a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6q7r8s9t0
# Author: Jean Dupont <jean@example.com>
# Date:   Mon Dec 16 14:30:00 2024 +0100
#
#     Ajout de la fonctionnalité de connexion
```

> [!info] Anatomie d'un commit dans git log
> 
> - **SHA-1** : Identifiant unique du commit (40 caractères hexadécimaux)
> - **Author** : Nom et email de l'auteur
> - **Date** : Date et heure du commit
> - **Message** : Description des modifications

### Options principales

#### `--oneline` : Vue compacte

```bash
# Afficher un commit par ligne (SHA court + message)
git log --oneline

# Sortie :
# a1b2c3d Ajout de la fonctionnalité de connexion
# e4f5g6h Correction du bug d'affichage
# i7j8k9l Mise à jour de la documentation
```

> [!tip] Quand utiliser --oneline Parfait pour avoir une vue d'ensemble rapide de l'historique récent ou pour compter le nombre de commits.

#### `--graph` : Visualisation des branches

```bash
# Afficher un graphe ASCII des branches et merges
git log --graph

# Avec --oneline pour plus de clarté
git log --oneline --graph

# Sortie typique :
# * a1b2c3d Ajout de la fonctionnalité de connexion
# *   e4f5g6h Merge branch 'feature/login'
# |\
# | * i7j8k9l Implémentation du formulaire
# | * m3n4o5p Validation des données
# |/
# * q7r8s9t Initialisation du projet
```

> [!example] Visualisation graphique Le graphe utilise des caractères ASCII pour montrer :
> 
> - `*` : Un commit
> - `|` : Une ligne de branche
> - `/` et `\` : Divisions et fusions de branches

#### `--all` : Toutes les branches

```bash
# Afficher l'historique de TOUTES les branches (pas seulement la branche courante)
git log --all

# Combiné avec --graph et --oneline
git log --all --graph --oneline

# Afficher avec les noms de branches et tags
git log --all --graph --oneline --decorate
```

> [!warning] Différence avec la vue par défaut Sans `--all`, `git log` affiche uniquement l'historique de la branche courante. Avec `--all`, vous voyez tous les commits de toutes les branches.

#### Options de limitation

```bash
# Limiter le nombre de commits affichés
git log -n 5          # Afficher les 5 derniers commits
git log -3            # Afficher les 3 derniers commits

# Limiter par période
git log --since="2 weeks ago"
git log --after="2024-01-01"
git log --until="2024-12-31"
git log --before="yesterday"

# Limiter par auteur
git log --author="Jean"
git log --author="jean@example.com"

# Limiter par message de commit
git log --grep="bug"
git log --grep="feature" --grep="fix" --all-match  # Les deux termes
```

#### Options de formatage

```bash
# Format personnalisé
git log --pretty=format:"%h - %an, %ar : %s"
# Sortie : a1b2c3d - Jean Dupont, 2 hours ago : Ajout de la fonctionnalité

# Formats prédéfinis
git log --pretty=oneline
git log --pretty=short
git log --pretty=full
git log --pretty=fuller

# Afficher les statistiques de modifications
git log --stat
# Montre les fichiers modifiés et le nombre de lignes changées

# Afficher le diff complet
git log -p
# ou
git log --patch
```

> [!tip] Placeholders utiles pour --pretty=format
> 
> - `%H` : SHA-1 complet
> - `%h` : SHA-1 court
> - `%an` : Nom de l'auteur
> - `%ae` : Email de l'auteur
> - `%ad` : Date de l'auteur
> - `%ar` : Date relative (ex: "2 hours ago")
> - `%s` : Sujet (première ligne du message)
> - `%b` : Corps du message

### Combinaison d'options

Les options peuvent être combinées pour créer des vues personnalisées puissantes :

```bash
# Vue compacte et graphique de toutes les branches
git log --all --graph --oneline --decorate

# Alias populaire (à ajouter dans .gitconfig)
# git config --global alias.lg "log --all --graph --oneline --decorate"
# Utilisation : git lg

# Historique détaillé des 10 derniers commits
git log -10 --stat --graph

# Commits de la semaine dernière par un auteur spécifique
git log --author="Jean" --since="1 week ago" --oneline

# Recherche de commits touchant un fichier spécifique
git log --oneline -- path/to/file.js
```

> [!example] Configuration d'alias utiles Ajoutez ces alias dans votre `~/.gitconfig` :
> 
> ```ini
> [alias]
>     lg = log --all --graph --oneline --decorate
>     lgs = log --all --graph --oneline --decorate --stat
>     lga = log --all --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset'
> ```

---

## La commande git show

### Examiner un commit spécifique

`git show` affiche les détails complets d'un commit, incluant le diff des modifications.

```bash
# Afficher le dernier commit
git show

# Afficher un commit spécifique (par son SHA)
git show a1b2c3d

# Afficher un commit relatif
git show HEAD        # Dernier commit
git show HEAD~1      # Avant-dernier commit
git show HEAD~2      # Il y a 2 commits
git show HEAD^       # Parent du dernier commit (équivalent à HEAD~1)

# Afficher seulement certaines informations
git show --stat a1b2c3d      # Seulement les statistiques
git show --name-only a1b2c3d # Seulement les noms de fichiers
git show --name-status a1b2c3d # Noms et statuts (A=ajouté, M=modifié, D=supprimé)
```

> [!info] Notation HEAD~n vs HEAD^n
> 
> - `HEAD~n` : Remonte de n commits dans l'historique linéaire
> - `HEAD^n` : Sélectionne le nième parent (utile pour les merges)
> - Exemple : `HEAD~2` = grand-parent, `HEAD^2` = deuxième parent d'un merge

### Examiner un fichier à un moment donné

```bash
# Afficher le contenu d'un fichier à un commit donné
git show a1b2c3d:path/to/file.js

# Afficher un fichier tel qu'il était il y a 3 commits
git show HEAD~3:src/app.js

# Comparer un fichier entre deux commits
git show a1b2c3d:file.js > /tmp/old.js
git show e4f5g6h:file.js > /tmp/new.js
diff /tmp/old.js /tmp/new.js

# Afficher les modifications d'un fichier dans un commit spécifique
git show a1b2c3d -- path/to/file.js
```

> [!tip] Astuce pour les chemins Utilisez `--` pour séparer les options des chemins de fichiers, surtout si le nom du fichier pourrait être confondu avec une option ou une référence.

```bash
# Afficher plusieurs commits
git show a1b2c3d e4f5g6h i7j8k9l

# Afficher un commit avec contexte supplémentaire
git show --unified=10 a1b2c3d  # 10 lignes de contexte au lieu de 3

# Afficher seulement le message du commit
git show -s --format=%B a1b2c3d
```

---

## Recherche dans l'historique

### Recherche par contenu

#### Recherche dans les messages de commit

```bash
# Rechercher "bug" dans les messages de commit
git log --grep="bug"

# Recherche insensible à la casse
git log --grep="BUG" -i

# Recherche avec expressions régulières
git log --grep="fix.*bug" --regexp-ignore-case

# Recherche de plusieurs termes (OR logique par défaut)
git log --grep="bug" --grep="fix"

# Recherche de plusieurs termes (AND logique)
git log --grep="bug" --grep="fix" --all-match
```

#### Recherche dans le code (pickaxe)

La recherche "pickaxe" trouve les commits qui ont ajouté ou supprimé une chaîne de caractères spécifique.

```bash
# Trouver quand "function login()" a été ajouté ou supprimé
git log -S "function login()"

# Avec le diff pour voir les changements
git log -S "function login()" -p

# Recherche avec regex (plus puissant)
git log -G "function.*login"

# Recherche dans des fichiers spécifiques
git log -S "API_KEY" -- src/config.js
```

> [!warning] Différence entre -S et -G
> 
> - `-S` : Trouve les commits où le **nombre d'occurrences** de la chaîne a changé
> - `-G` : Trouve les commits où la chaîne apparaît dans le **diff** (même si le nombre total n'a pas changé)

> [!example] Cas d'usage de la pickaxe
> 
> - Trouver quand une fonction a été introduite ou supprimée
> - Rechercher l'origine d'une constante ou variable
> - Identifier quand une dépendance a été ajoutée

### Recherche par auteur et date

```bash
# Commits d'un auteur spécifique
git log --author="Jean Dupont"
git log --author="jean@example.com"

# Regex pour plusieurs auteurs
git log --author="Jean\|Marie"

# Commits dans une période
git log --since="2024-01-01" --until="2024-12-31"
git log --after="3 weeks ago"
git log --before="2024-12-01"

# Combiner plusieurs critères
git log --author="Jean" --since="2 weeks ago" --grep="feature"

# Commits entre deux dates par un auteur
git log --author="Jean" --after="2024-11-01" --before="2024-12-01" --oneline
```

> [!tip] Formats de date acceptés Git accepte de nombreux formats :
> 
> - Dates absolues : `2024-12-16`, `Dec 16 2024`
> - Dates relatives : `2 weeks ago`, `yesterday`, `last monday`
> - Formats ISO : `2024-12-16T14:30:00`

### Recherche dans les fichiers

```bash
# Historique d'un fichier spécifique
git log -- path/to/file.js
git log --oneline -- src/app.js

# Historique avec les diffs
git log -p -- path/to/file.js

# Suivre un fichier même s'il a été renommé
git log --follow -- path/to/file.js

# Historique d'un dossier
git log -- src/components/

# Trouver qui a modifié une ligne spécifique (blame)
git log -L 10,20:path/to/file.js
# Affiche l'historique des lignes 10 à 20

# Trouver quand un fichier a été supprimé
git log --diff-filter=D --summary
git log --all --full-history -- path/to/deleted-file.js
```

> [!info] L'option --follow `--follow` est particulièrement utile pour suivre l'historique d'un fichier qui a été renommé. Sans cette option, l'historique s'arrête au moment du renommage.

```bash
# Trouver les commits qui ont modifié plus de X fichiers
git log --all --oneline --name-only | grep -c "^" | awk '{if($1>10) print}'

# Chercher dans les commits non mergés
git log --no-merges

# Chercher seulement les commits de merge
git log --merges

# Commits touchant des fichiers avec une extension spécifique
git log --all --oneline -- "*.js"
git log --all --oneline -- "*.md"
```

---

## Pièges courants

> [!warning] Attention aux alias Si vous créez des alias pour `git log`, assurez-vous de comprendre toutes les options incluses. Un alias mal configuré peut masquer des informations importantes.

> [!warning] Performance avec de gros historiques Sur de très gros dépôts, certaines commandes peuvent être lentes :
> 
> - `git log --all` peut prendre du temps s'il y a beaucoup de branches
> - `git log -p` affiche tous les diffs, ce qui peut être massif
> - Utilisez `-n` pour limiter le nombre de résultats si nécessaire

> [!warning] SHA courts vs longs
> 
> - Les SHA courts (7 caractères par défaut) sont pratiques mais peuvent devenir ambigus sur de très gros dépôts
> - Utilisez toujours le SHA complet dans les scripts ou la documentation importante
> - Git vous avertira si un SHA court est ambigu

> [!warning] Recherche dans les branches supprimées Par défaut, `git log` ne montre que les commits accessibles depuis les branches actuelles. Pour voir l'historique complet, y compris les branches supprimées, utilisez le reflog (qui sera abordé dans une autre partie).

---

## Bonnes pratiques

> [!tip] Créez des alias personnalisés Configurez des alias pour vos commandes `git log` les plus fréquentes. Cela améliore votre productivité.
> 
> ```bash
> git config --global alias.lg "log --graph --oneline --all --decorate"
> git config --global alias.last "log -1 HEAD --stat"
> ```

> [!tip] Utilisez --stat pour une vue d'ensemble Avant d'examiner les diffs complets avec `-p`, utilisez `--stat` pour avoir un aperçu rapide des fichiers modifiés.

> [!tip] Combinez grep et pickaxe Pour des recherches complexes, combinez `--grep` (messages) et `-S` (code) :
> 
> ```bash
> git log --grep="refactor" -S "oldFunction" -p
> ```

> [!tip] Documentation des recherches importantes Si vous trouvez des informations importantes via `git log`, documentez la commande utilisée. Vous pourriez en avoir besoin à nouveau.

> [!tip] Utilisez les outils graphiques pour l'exploration Pour une exploration visuelle complexe de l'historique, n'hésitez pas à utiliser :
> 
> - `gitk --all` (interface Tcl/Tk fournie avec Git)
> - Outils tiers : GitKraken, SourceTree, GitHub Desktop, etc.
> - Extensions IDE : GitLens pour VS Code, Git Integration pour IntelliJ

> [!tip] Filtrez progressivement Commencez par une recherche large, puis affinez progressivement :
> 
> ```bash
> # 1. Vue d'ensemble
> git log --oneline --since="1 month ago"
> 
> # 2. Affiner par auteur
> git log --oneline --since="1 month ago" --author="Jean"
> 
> # 3. Affiner par sujet
> git log --oneline --since="1 month ago" --author="Jean" --grep="feature"
> 
> # 4. Examiner en détail
> git log -p --since="1 month ago" --author="Jean" --grep="feature"
> ```

---