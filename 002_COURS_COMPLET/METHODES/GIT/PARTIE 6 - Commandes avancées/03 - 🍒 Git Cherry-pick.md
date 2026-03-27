

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

## 🎯 Introduction au cherry-pick

Le **cherry-pick** est une commande qui permet d'appliquer les modifications d'un ou plusieurs commits spécifiques d'une branche vers une autre, sans fusionner l'ensemble de la branche source.

> [!info] Métaphore Comme son nom l'indique (cueillir les cerises), cette commande vous permet de "sélectionner" précisément les commits que vous souhaitez récupérer, plutôt que de prendre tout le panier.

### Pourquoi utiliser cherry-pick ?

- **Sélectivité** : Récupérer uniquement les changements dont vous avez besoin
- **Flexibilité** : Appliquer un correctif d'une branche à une autre sans merge complet
- **Isolation** : Éviter d'importer des modifications non désirées
- **Réactivité** : Déployer rapidement un fix critique sur plusieurs branches

---

## 🔧 La commande git cherry-pick

### Syntaxe de base

```bash
# Cherry-pick d'un seul commit
git cherry-pick <commit-hash>

# Cherry-pick de plusieurs commits
git cherry-pick <commit1> <commit2> <commit3>

# Cherry-pick d'une plage de commits
git cherry-pick <commit-debut>..<commit-fin>

# Cherry-pick d'une plage inclusive (incluant le premier commit)
git cherry-pick <commit-debut>^..<commit-fin>
```

### Options principales

```bash
# Cherry-pick sans créer de commit immédiatement (staging)
git cherry-pick --no-commit <commit-hash>
git cherry-pick -n <commit-hash>

# Cherry-pick avec édition du message de commit
git cherry-pick --edit <commit-hash>
git cherry-pick -e <commit-hash>

# Cherry-pick en gardant l'auteur original
git cherry-pick -x <commit-hash>
# Ajoute une ligne "cherry picked from commit..." dans le message

# Cherry-pick avec signature
git cherry-pick --signoff <commit-hash>
git cherry-pick -s <commit-hash>
```

> [!example] Exemple pratique
> 
> ```bash
> # Vous êtes sur la branche main
> git checkout main
> 
> # Vous voulez récupérer le commit abc123 de la branche feature
> git cherry-pick abc123
> 
> # Git applique les modifications et crée un nouveau commit
> ```

### Options avancées

```bash
# Cherry-pick uniquement les modifications sans créer de commit
git cherry-pick --no-commit abc123 def456
# Permet de combiner plusieurs cherry-picks en un seul commit

# Cherry-pick en conservant les dates originales
git cherry-pick --keep-redundant-commits <commit-hash>

# Cherry-pick avec stratégie de merge spécifique
git cherry-pick -X theirs <commit-hash>
git cherry-pick -X ours <commit-hash>

# Cherry-pick en mode "mainline" pour les merge commits
git cherry-pick -m 1 <merge-commit-hash>
# -m 1 : utilise le premier parent du merge
# -m 2 : utilise le second parent du merge
```

> [!warning] Attention aux hash de commits Le cherry-pick crée un **nouveau commit** avec un nouveau hash, même si le contenu est identique. L'historique diverge donc entre les branches.

### Commandes de gestion du processus

```bash
# Continuer après résolution de conflits
git cherry-pick --continue

# Abandonner le cherry-pick en cours
git cherry-pick --abort

# Ignorer ce commit et continuer avec les suivants
git cherry-pick --skip

# Voir l'état du cherry-pick en cours
git status
```

---

## 💼 Cas d'usage du cherry-pick

### 1. Correctif urgent (hotfix) sur plusieurs branches

**Scénario** : Vous avez corrigé un bug critique en production et devez appliquer le même correctif sur les branches de développement.

```bash
# Le bug est corrigé sur main dans le commit abc123
git checkout main
git log --oneline  # Identifier le commit du fix : abc123

# Appliquer le fix sur la branche develop
git checkout develop
git cherry-pick abc123

# Appliquer le fix sur la branche release
git checkout release/v2.0
git cherry-pick abc123
```

> [!tip] Astuce Utilisez `git cherry-pick -x abc123` pour tracer l'origine du commit et faciliter le suivi.

### 2. Récupération de fonctionnalité spécifique

**Scénario** : Une fonctionnalité complète existe sur une branche, mais vous n'avez besoin que d'une partie précise.

```bash
# Identifier les commits souhaités sur la branche feature
git log --oneline feature/new-module
# abc123 - Ajout validation email
# def456 - Ajout tests unitaires
# ghi789 - Refactoring global (non désiré)
# jkl012 - Ajout documentation

# Récupérer uniquement les commits utiles
git checkout develop
git cherry-pick abc123 def456 jkl012
```

### 3. Récupération après erreur de branche

**Scénario** : Vous avez commité sur la mauvaise branche.

```bash
# Vous avez commité par erreur sur main au lieu de feature
git log --oneline -3
# abc123 - Mon nouveau feature (ERREUR)
# def456 - Commit précédent
# ghi789 - Autre commit

# Solution
git checkout feature/my-work
git cherry-pick abc123  # Récupérer le commit

git checkout main
git reset --hard HEAD~1  # Supprimer le commit erroné de main
```

> [!warning] Prudence avec reset Cette manipulation réécrit l'historique. Ne l'utilisez que si vous n'avez pas encore partagé (push) la branche main.

### 4. Intégration sélective avant merge complet

**Scénario** : Une branche de développement longue contient une fonctionnalité prête à être déployée avant le reste.

```bash
# Branche feature/big-refactor contient 50 commits
# Seuls 3 commits concernent une fonctionnalité finalisée

git checkout main
git cherry-pick feature/big-refactor~45..feature/big-refactor~43
# Récupère 3 commits spécifiques sans tout merger
```

### 5. Duplication de commits entre repositories

**Scénario** : Synchroniser un correctif entre plusieurs dépôts (monorepo vs microservices).

```bash
# Dans le repository principal
git log --oneline
# abc123 - Fix validation

# Dans le repository secondaire
git remote add main-repo https://github.com/company/main-repo.git
git fetch main-repo
git cherry-pick main-repo/main~3  # Récupère le commit abc123
```

### 6. Préparation de release avec commits sélectionnés

**Scénario** : Créer une branche de release avec uniquement les fonctionnalités stables.

```bash
git checkout -b release/v1.5 main

# Cherry-pick des fonctionnalités validées
git cherry-pick feature-A-commit
git cherry-pick feature-C-commit
# On ignore feature-B qui n'est pas prête
```

> [!info] Comparaison avec merge
> 
> |Cherry-pick|Merge|
> |---|---|
> |Sélection précise de commits|Intégration complète d'une branche|
> |Nouveau commit créé|Commit de merge ou fast-forward|
> |Historique dupliqué|Historique préservé|
> |Idéal pour correctifs ponctuels|Idéal pour intégration de features|

---

## ⚠️ Gestion des conflits lors du cherry-pick

Le cherry-pick peut générer des conflits si les modifications du commit choisi sont incompatibles avec l'état actuel de la branche cible.

### Pourquoi des conflits surviennent ?

1. **Contexte différent** : Le code autour des modifications a évolué différemment
2. **Dépendances manquantes** : Le commit dépend de changements non présents sur la branche cible
3. **Modifications concurrentes** : Les mêmes lignes ont été modifiées différemment

### Processus de résolution de conflits

```bash
# 1. Tentative de cherry-pick
git cherry-pick abc123

# Sortie en cas de conflit :
# error: could not apply abc123... Message du commit
# hint: after resolving the conflicts, mark the corrected paths
# hint: with 'git add <paths>' or 'git rm <paths>'
# hint: and commit the result with 'git commit'

# 2. Identifier les fichiers en conflit
git status
# On branch main
# You are currently cherry-picking commit abc123.
#   (fix conflicts and run "git cherry-pick --continue")
#   (use "git cherry-pick --abort" to cancel the cherry-pick)
#
# Unmerged paths:
#   (use "git add <file>..." to mark resolution)
#         both modified:   src/main.js

# 3. Ouvrir et résoudre les conflits
# Le fichier contient des marqueurs de conflit
```

### Structure des marqueurs de conflit

```javascript
function validateEmail(email) {
<<<<<<< HEAD
  // Version actuelle de la branche (votre code)
  return email.includes('@') && email.length > 5;
=======
  // Version du commit cherry-picked
  return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
>>>>>>> abc123 (Message du commit cherry-picked)
}
```

> [!tip] Comprendre les marqueurs
> 
> - `<<<<<<< HEAD` : Début du contenu de votre branche actuelle
> - `=======` : Séparateur
> - `>>>>>>> abc123` : Fin du contenu du commit cherry-picked

### Résolution manuelle

```bash
# 4. Éditer le fichier pour choisir la bonne version
# Supprimer les marqueurs et garder le code souhaité
# Option 1 : Garder la version HEAD
# Option 2 : Garder la version cherry-picked
# Option 3 : Combiner les deux
# Option 4 : Écrire une nouvelle solution

# 5. Marquer le conflit comme résolu
git add src/main.js

# 6. Vérifier que tous les conflits sont résolus
git status

# 7. Continuer le cherry-pick
git cherry-pick --continue
# Git ouvre l'éditeur pour confirmer/modifier le message de commit
```

### Résolution avec stratégies automatiques

```bash
# Accepter automatiquement la version de la branche actuelle
git cherry-pick -X ours abc123

# Accepter automatiquement la version du commit cherry-picked
git cherry-pick -X theirs abc123

# Ignorer les espaces blancs dans la détection de conflits
git cherry-pick -X ignore-space-change abc123
git cherry-pick -X ignore-all-space abc123
```

> [!warning] Attention avec les stratégies automatiques Ces options peuvent masquer des conflits réels. Utilisez-les uniquement quand vous êtes certain de la décision à prendre.

### Abandonner ou sauter un cherry-pick

```bash
# Annuler complètement le cherry-pick en cours
git cherry-pick --abort
# Retour à l'état avant le cherry-pick

# Ignorer ce commit et passer au suivant (si cherry-pick multiple)
git cherry-pick --skip

# Vérifier l'état après abandon
git status
# On branch main
# nothing to commit, working tree clean
```

### Cherry-pick de plusieurs commits avec conflits

```bash
# Cherry-pick d'une série de commits
git cherry-pick abc123 def456 ghi789

# Si conflit sur def456 :
# 1. Résoudre le conflit
git add <fichiers-résolus>
git cherry-pick --continue
# Git continuera automatiquement avec ghi789

# 2. OU abandonner toute la série
git cherry-pick --abort
```

### Prévention des conflits

> [!tip] Bonnes pratiques pour minimiser les conflits
> 
> - **Vérifier les dépendances** : S'assurer que les commits prérequis sont présents
> - **Cherry-pick récent** : Plus le commit est récent, moins il risque d'avoir des conflits
> - **Tester avant** : Créer une branche temporaire pour tester le cherry-pick
> - **Commits atomiques** : Privilégier des commits petits et indépendants
> - **Documentation** : Bien comprendre le contexte du commit avant de le cherry-pick

```bash
# Technique de test sécurisée
git checkout -b test-cherry-pick main
git cherry-pick abc123
# Si ça fonctionne :
git checkout main
git cherry-pick abc123
# Si ça échoue :
git checkout main
git branch -D test-cherry-pick
```

### Outils de visualisation des conflits

```bash
# Voir les différences pendant un conflit
git diff

# Voir uniquement les fichiers en conflit
git diff --name-only --diff-filter=U

# Utiliser un outil de merge graphique
git mergetool

# Voir l'historique des tentatives de cherry-pick
git reflog
```

### Debugging d'un cherry-pick problématique

```bash
# Voir le commit qu'on essaie de cherry-pick
git show abc123

# Comparer avec l'état actuel
git diff HEAD abc123 -- src/main.js

# Identifier les fichiers modifiés dans le commit
git show --name-only abc123

# Vérifier si ces fichiers existent sur la branche actuelle
git ls-files | grep <nom-fichier>
```

> [!example] Cas complexe : Cherry-pick d'un merge commit
> 
> ```bash
> # Un merge commit a deux parents
> git show --format="%H %P" <merge-commit>
> # abc123 def456 ghi789
> #        ^parent1 ^parent2
> 
> # Choisir quel parent utiliser comme base
> git cherry-pick -m 1 <merge-commit>  # Utilise def456
> git cherry-pick -m 2 <merge-commit>  # Utilise ghi789
> ```

### Récupération après échec

```bash
# Si vous êtes bloqué dans un cherry-pick
git status
# Montre l'état et les suggestions

# Retour à un état propre
git cherry-pick --abort
git reset --hard HEAD

# Vérification finale
git status
git log --oneline -5
```

---

## 🎓 Pièges courants et bonnes pratiques

### ❌ Pièges à éviter

1. **Duplication d'historique**
    
    - Cherry-pick crée de nouveaux commits avec des hashs différents
    - Peut créer de la confusion si les deux commits sont ensuite mergés
2. **Cherry-pick excessif**
    
    - Trop de cherry-picks indique souvent un problème de stratégie de branches
    - Privilégier les merges réguliers pour l'intégration continue
3. **Oubli de dépendances**
    
    - Cherry-pick d'un commit sans ses prérequis
    - Peut causer des bugs subtils
4. **Cherry-pick sur historique public**
    
    - Modifier ou dupliquer des commits déjà partagés crée des divergences

### ✅ Bonnes pratiques

> [!tip] Recommandations
> 
> - **Traçabilité** : Utiliser `-x` pour documenter l'origine des cherry-picks
> - **Commits atomiques** : Facilite le cherry-pick de modifications précises
> - **Communication** : Informer l'équipe des cherry-picks effectués
> - **Test** : Toujours tester après un cherry-pick, même sans conflit
> - **Alternative** : Considérer si un merge ou un rebase ne serait pas plus approprié

```bash
# Workflow recommandé pour hotfix
# 1. Créer un fix sur main
git checkout main
git commit -m "fix: Correction bug critique #123"

# 2. Cherry-pick sur les branches concernées avec traçabilité
git checkout develop
git cherry-pick -x HEAD@{1}

git checkout release/v2.0
git cherry-pick -x HEAD@{2}

# 3. Documenter dans le système de tickets
# "Fix appliqué sur main (abc123), develop (def456), release (ghi789)"
```

---

## 📊 Récapitulatif

Le **cherry-pick** est un outil puissant pour la gestion ciblée de commits, particulièrement utile pour :

- Appliquer des correctifs urgents sur plusieurs branches
- Récupérer des fonctionnalités spécifiques sans merge complet
- Corriger des erreurs de branches

**Points clés à retenir** :

- Crée de nouveaux commits (nouveaux hashs)
- Peut générer des conflits nécessitant une résolution manuelle
- À utiliser avec parcimonie et traçabilité
- Préférer les merges pour l'intégration régulière de branches

> [!warning] Rappel important Le cherry-pick est un outil pratique mais ne remplace pas une bonne stratégie de gestion de branches. Utilisez-le pour des situations exceptionnelles plutôt que comme pratique courante.