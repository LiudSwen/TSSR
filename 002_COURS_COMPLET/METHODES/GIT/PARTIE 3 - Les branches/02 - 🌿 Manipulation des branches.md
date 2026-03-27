

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

La manipulation des branches est une compétence fondamentale dans Git. Elle vous permet de naviguer entre différents contextes de développement, de créer de nouveaux espaces de travail isolés, et de nettoyer les branches obsolètes. Cette maîtrise est essentielle pour un workflow Git efficace.

> [!info] Pourquoi maîtriser la manipulation des branches ?
> 
> - **Flexibilité** : Passer rapidement d'une fonctionnalité à une autre
> - **Organisation** : Maintenir un dépôt propre et structuré
> - **Collaboration** : Gérer efficacement les branches de travail en équipe
> - **Sécurité** : Éviter les suppressions accidentelles avec les bonnes commandes

---

## 📋 Lister les branches

### Commande de base

La commande `git branch` sans argument affiche toutes les branches locales :

```bash
git branch
```

**Sortie typique :**

```
  feature/login
  feature/payment
* main
  hotfix/security-patch
```

> [!tip] Astuce L'astérisque `*` indique la branche actuellement active (HEAD).

### Options de filtrage

Git offre plusieurs options pour affiner l'affichage des branches :

|Commande|Description|
|---|---|
|`git branch`|Liste toutes les branches locales|
|`git branch -r`|Liste uniquement les branches distantes (remote)|
|`git branch -a`|Liste toutes les branches (locales + distantes)|
|`git branch -v`|Affiche le dernier commit de chaque branche|
|`git branch -vv`|Affiche les branches avec leurs tracking branches|
|`git branch --merged`|Liste les branches fusionnées dans la branche courante|
|`git branch --no-merged`|Liste les branches non fusionnées|

**Exemples pratiques :**

```bash
# Voir toutes les branches avec détails
git branch -a -v

# Identifier les branches déjà fusionnées dans main
git checkout main
git branch --merged

# Trouver les branches de travail en cours
git branch --no-merged
```

> [!example] Exemple de sortie détaillée
> 
> ```bash
> $ git branch -vv
>   feature/api      a3f2b1c [origin/feature/api] Add API endpoint
> * main             d4e5f6g [origin/main] Update README
>   hotfix/bug-123   b2c3d4e Fix critical bug
> ```
> 
> Cette sortie montre le nom de la branche, le SHA court du dernier commit, la branche de suivi distante entre crochets, et le message du commit.

**Filtrage avec pattern :**

```bash
# Lister uniquement les branches commençant par "feature/"
git branch --list "feature/*"

# Avec les branches distantes
git branch -r --list "origin/hotfix/*"
```

> [!warning] Attention aux branches distantes Les branches affichées avec `-r` sont des références locales des branches distantes. Elles ne sont pas automatiquement mises à jour. Utilisez `git fetch` pour les synchroniser.

---

## 🔀 Créer des branches

La création d'une branche se fait avec `git branch` suivi du nom de la nouvelle branche :

```bash
# Créer une nouvelle branche (sans y basculer)
git branch nom-de-la-branche

# Créer une branche depuis un commit spécifique
git branch nom-de-la-branche <commit-hash>

# Créer une branche depuis une autre branche
git branch nouvelle-branche branche-existante
```

**Exemples concrets :**

```bash
# Créer une branche pour une nouvelle fonctionnalité
git branch feature/user-authentication

# Créer une branche depuis un commit précis
git branch hotfix/rollback a3f2b1c

# Créer une branche depuis une autre branche
git branch feature/payment-v2 feature/payment
```

> [!info] Note importante `git branch` crée la branche mais ne bascule pas dessus automatiquement. Vous restez sur votre branche actuelle. Pour créer ET basculer, voir la section suivante.

**Création et basculement immédiat :**

```bash
# Méthode classique
git checkout -b nouvelle-branche

# Méthode moderne (Git 2.23+)
git switch -c nouvelle-branche

# Depuis un commit spécifique
git switch -c hotfix/urgent a3f2b1c
```

> [!tip] Astuce de productivité Utilisez `git switch -c` pour créer et basculer en une seule commande. C'est plus rapide et plus intuitif que la séquence `git branch` puis `git checkout`.

---

## 🚀 Changer de branche

Il existe deux commandes pour changer de branche : l'historique `git checkout` et la moderne `git switch`.

### git checkout

`git checkout` est la commande historique, polyvalente mais parfois ambiguë :

```bash
# Basculer vers une branche existante
git checkout nom-de-la-branche

# Créer et basculer vers une nouvelle branche
git checkout -b nouvelle-branche

# Basculer vers une branche distante (crée une branche locale)
git checkout origin/feature/api

# Basculer vers un commit spécifique (mode détaché)
git checkout a3f2b1c
```

**Exemples d'utilisation :**

```bash
# Retourner sur main
git checkout main

# Créer une branche de correction et y basculer
git checkout -b hotfix/login-bug

# Basculer vers la branche précédente
git checkout -
```

> [!warning] Piège : Fichiers non commités Si vous avez des modifications non commitées qui entrent en conflit avec la branche cible, Git refusera de basculer :
> 
> ```bash
> $ git checkout feature/api
> error: Your local changes to the following files would be overwritten by checkout:
>     src/app.js
> Please commit your changes or stash them before you switch branches.
> ```
> 
> **Solution** : Commitez vos changements ou utilisez `git stash`.

### git switch (moderne)

Introduite dans Git 2.23 (2019), `git switch` est dédiée exclusivement au changement de branche :

```bash
# Basculer vers une branche existante
git switch nom-de-la-branche

# Créer et basculer vers une nouvelle branche
git switch -c nouvelle-branche

# Créer une branche depuis un point de départ spécifique
git switch -c hotfix/urgent main

# Basculer vers la branche précédente
git switch -

# Forcer le basculement (abandonner les modifications locales)
git switch --discard-changes nom-de-la-branche
```

**Exemples pratiques :**

```bash
# Créer une branche de fonctionnalité depuis develop
git switch -c feature/notifications develop

# Revenir rapidement à la branche précédente
git switch -

# Forcer le changement de branche (attention !)
git switch --discard-changes main  # Perd les modifications non commitées
```

> [!tip] Basculement rapide Le symbole `-` permet de revenir à la branche précédente, très utile pour alterner entre deux branches :
> 
> ```bash
> git switch feature/api
> # ... travail sur la branche ...
> git switch -  # Retourne à la branche précédente
> ```

### Comparaison checkout vs switch

|Critère|`git checkout`|`git switch`|
|---|---|---|
|**Clarté**|Polyvalent (branches, fichiers, commits)|Dédié uniquement aux branches|
|**Sécurité**|Peut écraser des fichiers sans prévenir|Plus sûr avec les fichiers modifiés|
|**Modernité**|Ancien (disponible partout)|Moderne (Git 2.23+, août 2019)|
|**Recommandation**|À éviter pour les nouvelles pratiques|**Recommandé** pour changer de branche|

> [!info] Pourquoi git switch ? Git a introduit `git switch` pour séparer les responsabilités :
> 
> - `git switch` : changer de branche
> - `git restore` : restaurer des fichiers
> 
> Cela rend les commandes plus explicites et réduit les erreurs.

**Tableau des équivalences :**

|Action|`git checkout`|`git switch`|
|---|---|---|
|Changer de branche|`git checkout branch`|`git switch branch`|
|Créer et basculer|`git checkout -b new`|`git switch -c new`|
|Branche précédente|`git checkout -`|`git switch -`|
|Forcer le basculement|`git checkout -f branch`|`git switch --discard-changes branch`|

> [!warning] Compatibilité `git switch` nécessite Git 2.23 ou supérieur. Vérifiez votre version avec `git --version`. Sur les systèmes anciens, continuez d'utiliser `git checkout`.

---

## 🗑️ Supprimer des branches

La suppression de branches permet de maintenir un dépôt propre et organisé. Git offre deux niveaux de suppression : sécurisée et forcée.

### Suppression sécurisée

La suppression sécurisée avec `-d` (delete) vérifie que la branche a été fusionnée :

```bash
# Supprimer une branche locale fusionnée
git branch -d nom-de-la-branche

# Supprimer plusieurs branches d'un coup
git branch -d branche1 branche2 branche3
```

**Exemple de workflow typique :**

```bash
# Fusionner une branche de fonctionnalité
git checkout main
git merge feature/login

# Supprimer la branche devenue inutile
git branch -d feature/login
```

> [!info] Vérification de fusion Avec `-d`, Git refuse de supprimer une branche si elle contient des commits non fusionnés :
> 
> ```bash
> $ git branch -d feature/experimental
> error: The branch 'feature/experimental' is not fully merged.
> If you are sure you want to delete it, run 'git branch -D feature/experimental'.
> ```
> 
> C'est une protection contre la perte de travail.

**Suppression de branches distantes :**

```bash
# Supprimer la référence locale d'une branche distante
git branch -d -r origin/feature/old

# Supprimer la branche sur le serveur distant
git push origin --delete feature/old

# Alternative plus courte
git push origin :feature/old
```

> [!example] Nettoyage après fusion Après avoir fusionné une pull request sur GitHub/GitLab, nettoyez localement :
> 
> ```bash
> git checkout main
> git pull                          # Récupérer les dernières modifications
> git branch --merged               # Identifier les branches fusionnées
> git branch -d feature/completed   # Supprimer la branche locale
> ```

### Suppression forcée

La suppression forcée avec `-D` (équivalent à `-d -f`) ignore l'état de fusion :

```bash
# Supprimer une branche non fusionnée (ATTENTION : perte de données possible)
git branch -D nom-de-la-branche

# Supprimer plusieurs branches de force
git branch -D branche1 branche2
```

> [!warning] ⚠️ Danger : Perte de données `-D` supprime la branche même si elle contient des commits non fusionnés. Utilisez cette option seulement si vous êtes certain de vouloir abandonner le travail sur cette branche.

**Quand utiliser `-D` :**

1. **Expérimentations ratées** : Vous avez testé quelque chose qui n'a pas fonctionné
2. **Branches obsolètes** : Le travail n'est plus pertinent
3. **Fausses manipulations** : Vous avez créé une branche par erreur

```bash
# Supprimer une expérimentation ratée
git branch -D experiment/failed-approach

# Nettoyer plusieurs branches de test
git branch -D test/option1 test/option2 test/option3
```

> [!tip] Récupération d'urgence Si vous supprimez une branche par erreur, vous pouvez parfois la récupérer via le reflog :
> 
> ```bash
> git reflog                    # Trouver le SHA du dernier commit
> git branch branche-recree <SHA>  # Recréer la branche
> ```

### Cas particuliers

**Impossible de supprimer la branche courante :**

```bash
$ git branch -d main
error: Cannot delete branch 'main' checked out at '/path/to/repo'

# Solution : basculer d'abord vers une autre branche
git switch develop
git branch -d main
```

**Nettoyer les branches distantes obsolètes :**

```bash
# Supprimer les références locales de branches distantes supprimées
git fetch --prune

# Voir les branches distantes supprimées
git remote prune origin --dry-run

# Effectuer le nettoyage
git remote prune origin
```

> [!example] Script de nettoyage automatique Pour nettoyer toutes les branches locales fusionnées dans main :
> 
> ```bash
> # Basculer sur main et mettre à jour
> git checkout main
> git pull
> 
> # Lister et supprimer les branches fusionnées (sauf main et develop)
> git branch --merged | grep -v "\* main" | grep -v "develop" | xargs git branch -d
> ```

**Supprimer toutes les branches sauf certaines :**

```bash
# Supprimer toutes les branches feature/ fusionnées
git branch --merged | grep "feature/" | xargs git branch -d

# Supprimer toutes les branches locales sauf main et develop
git branch | grep -v "main" | grep -v "develop" | xargs git branch -D
```

> [!warning] Attention avec xargs Testez toujours vos commandes avec `grep` seul avant d'ajouter `xargs git branch -d` pour éviter les suppressions accidentelles.

---

## 🎨 Bonnes pratiques

### Nommage des branches

```bash
# ✅ Bon : Descriptif et catégorisé
git branch feature/user-authentication
git branch bugfix/login-timeout
git branch hotfix/security-patch

# ❌ Mauvais : Trop vague
git branch test
git branch new-stuff
git branch fix
```

**Conventions populaires :**

- `feature/` : Nouvelles fonctionnalités
- `bugfix/` : Corrections de bugs non critiques
- `hotfix/` : Corrections urgentes en production
- `release/` : Préparation de release
- `experiment/` : Tests et expérimentations

### Gestion du workflow

> [!tip] Workflow efficace
> 
> 1. **Créer** : `git switch -c feature/nouvelle-fonctionnalite`
> 2. **Travailler** : Committez régulièrement vos changements
> 3. **Fusionner** : Intégrez dans la branche principale
> 4. **Nettoyer** : `git branch -d feature/nouvelle-fonctionnalite`

**Vérifier avant de supprimer :**

```bash
# Lister les branches fusionnées
git branch --merged

# Vérifier le dernier commit d'une branche
git log -1 feature/to-delete

# Vérifier les différences avec main
git diff main..feature/to-delete
```

### Maintenance régulière

```bash
# Nettoyage hebdomadaire : supprimer les branches fusionnées
git checkout main
git branch --merged | grep -v "\*" | grep -v "main" | xargs git branch -d

# Synchroniser avec le dépôt distant
git fetch --prune

# Voir l'état de toutes les branches
git branch -vv
```

> [!info] Automatisation Considérez l'ajout d'un alias Git pour automatiser le nettoyage :
> 
> ```bash
> git config --global alias.cleanup "!git branch --merged | grep -v '\*' | grep -v 'main' | grep -v 'develop' | xargs -n 1 git branch -d"
> 
> # Utilisation
> git cleanup
> ```

### Gestion des conflits lors du basculement

```bash
# Si des modifications bloquent le changement de branche
git status                    # Voir les fichiers modifiés

# Option 1 : Committer les changements
git add .
git commit -m "WIP: Travail en cours"

# Option 2 : Mettre de côté temporairement
git stash
git switch autre-branche
git switch -                  # Revenir
git stash pop                 # Récupérer les modifications

# Option 3 : Abandonner les modifications (DANGER)
git switch --discard-changes autre-branche
```

> [!warning] Protection des données Ne supprimez jamais une branche si vous n'êtes pas sûr de son état de fusion. Utilisez toujours `-d` par défaut, et `-D` seulement si vous comprenez les conséquences.

---

**Navigation** : 🏠 [[Git - Introduction]] | ⬅️ [[Git - Branches - Introduction]] | ➡️ [[Git - Branches - Fusion]]

> [!info] Version Document mis à jour pour Git 2.40+ Dernière révision : 2024