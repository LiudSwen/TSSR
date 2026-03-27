

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

## 🎯 Introduction à la fusion

La **fusion de branches** (merge) est l'opération qui permet de combiner les modifications de deux branches différentes. C'est l'un des mécanismes fondamentaux de Git qui permet le travail collaboratif et parallèle.

> [!info] Pourquoi fusionner ?
> 
> - Intégrer une fonctionnalité développée dans une branche séparée
> - Synchroniser votre branche avec les dernières modifications
> - Réunir le travail de plusieurs développeurs
> - Finaliser une feature avant un déploiement

### Contexte de fusion

Lorsque vous fusionnez, vous combinez toujours **une branche source** (celle que vous souhaitez intégrer) dans **une branche cible** (celle où vous vous trouvez actuellement).

```bash
# Vous êtes sur la branche cible
git checkout main

# Vous fusionnez la branche source
git merge feature/nouvelle-fonctionnalité
```

---

## ⚡ Git merge - La commande de fusion

### Syntaxe de base

```bash
git merge <nom-de-la-branche>
```

Cette commande fusionne la branche spécifiée dans votre branche actuelle.

> [!example] Exemple pratique
> 
> ```bash
> # Vous travaillez sur une feature
> git checkout -b feature/login
> # ... vous faites des commits ...
> 
> # Vous retournez sur main pour fusionner
> git checkout main
> git merge feature/login
> ```

### Options principales

```bash
# Fusion standard
git merge feature/login

# Fusion sans fast-forward (force un commit de merge)
git merge --no-ff feature/login

# Fusion avec message personnalisé
git merge -m "Intégration du système de login" feature/login

# Annuler une fusion en cours (en cas de conflit)
git merge --abort

# Continuer après résolution de conflits
git merge --continue
```

> [!tip] Astuce Utilisez `git merge --no-ff` pour garder une trace explicite de l'intégration d'une feature, même si un fast-forward est possible.

### Vérifier l'état avant fusion

```bash
# Voir les différences avant de fusionner
git diff main feature/login

# Visualiser l'historique des deux branches
git log --oneline --graph --all

# Vérifier quels commits seront intégrés
git log main..feature/login
```

---

## 🚀 Fast-forward vs Merge commit

Git peut effectuer deux types de fusion selon la configuration de l'historique des branches.

### Fast-forward (avance rapide)

Un **fast-forward** se produit quand la branche cible n'a pas évolué depuis la création de la branche source. Git déplace simplement le pointeur sans créer de commit de fusion.

```bash
# Situation initiale
main:     A---B
               \
feature:        C---D

# Après git merge feature (fast-forward)
main:     A---B---C---D
```

```bash
# Fast-forward automatique (comportement par défaut)
git checkout main
git merge feature/login
# Output: Fast-forward
```

> [!info] Caractéristiques du fast-forward
> 
> - ✅ Historique linéaire et propre
> - ✅ Pas de commit supplémentaire
> - ❌ Perd la notion de "branche feature"
> - ❌ Difficile de savoir où commence/finit une feature

### Merge commit (commit de fusion)

Un **merge commit** est créé quand les deux branches ont divergé (chacune a de nouveaux commits). Git crée un nouveau commit avec deux parents.

```bash
# Situation avec divergence
main:     A---B---E---F
               \
feature:        C---D

# Après git merge feature (merge commit)
main:     A---B---E---F---G
               \         /
feature:        C---D---
```

```bash
# Git crée automatiquement un merge commit
git checkout main
git merge feature/login
# Output: Merge made by the 'ort' strategy.
```

> [!info] Caractéristiques du merge commit
> 
> - ✅ Préserve l'historique complet
> - ✅ Montre clairement les points d'intégration
> - ✅ Facilite l'identification des features
> - ❌ Historique plus complexe visuellement

### Forcer un type de fusion

```bash
# Forcer un merge commit (désactive fast-forward)
git merge --no-ff feature/login

# Autoriser uniquement fast-forward (échoue si impossible)
git merge --ff-only feature/login
```

### Comparaison

|Aspect|Fast-forward|Merge commit|
|---|---|---|
|**Historique**|Linéaire|Avec branches|
|**Lisibilité**|Simple|Détaillé|
|**Traçabilité**|Faible|Forte|
|**Commits**|Aucun ajouté|+1 commit|
|**Quand ?**|Branch simple|Collaboration|

> [!tip] Recommandation
> 
> - Utilisez **fast-forward** pour des branches personnelles courtes
> - Utilisez **--no-ff** pour les features importantes en équipe
> - Configurez `git config merge.ff false` pour toujours créer des merge commits

---

## 🛠️ Stratégies de fusion

Git propose plusieurs **stratégies de fusion** (merge strategies) qui définissent comment les modifications sont combinées. La stratégie est choisie automatiquement, mais peut être spécifiée manuellement.

### Stratégie ORT (par défaut depuis Git 2.34)

**ORT** (Ostensibly Recursive's Twin) est la stratégie par défaut moderne, optimisée et plus performante.

```bash
# Utilisée automatiquement
git merge feature/login

# Explicitement
git merge -s ort feature/login
```

> [!info] Caractéristiques ORT
> 
> - Détection intelligente des conflits
> - Gestion optimisée des renommages
> - Performance améliorée sur gros projets
> - Remplace l'ancienne stratégie "recursive"

### Stratégie Recursive (ancienne par défaut)

Stratégie historique, toujours disponible mais remplacée par ORT.

```bash
git merge -s recursive feature/login
```

### Stratégie Resolve

Fusion simple et rapide, ne gère qu'un ancêtre commun.

```bash
git merge -s resolve feature/login
```

> [!warning] Limitation Ne fonctionne pas bien avec des historiques complexes (plusieurs ancêtres communs).

### Stratégie Octopus

Permet de fusionner **plus de deux branches simultanément**.

```bash
# Fusionner 3 branches en une seule opération
git merge -s octopus feature/login feature/signup feature/profile
```

> [!info] Cas d'usage
> 
> - Intégration de plusieurs features en même temps
> - Préparation d'une release combinant plusieurs branches
> - ⚠️ Échoue dès qu'un conflit apparaît (pas de résolution manuelle)

### Stratégie Ours

Conserve **uniquement** le contenu de la branche actuelle, ignore complètement l'autre branche.

```bash
git merge -s ours old-feature
```

> [!example] Exemple d'utilisation
> 
> ```bash
> # Vous voulez "fermer" une branche sans intégrer ses changements
> # mais garder une trace dans l'historique
> git checkout main
> git merge -s ours experimental-feature
> # Résultat : main reste identique, mais l'historique montre la fusion
> ```

### Stratégie Subtree

Fusionne un projet dans un sous-répertoire d'un autre projet.

```bash
git merge -s subtree feature/module
```

> [!tip] Alternative moderne Préférez `git subtree` (commande dédiée) pour ce cas d'usage.

### Options de stratégie

Vous pouvez affiner les stratégies avec des options :

```bash
# Favoriser notre version en cas de conflit
git merge -X ours feature/login

# Favoriser leur version en cas de conflit
git merge -X theirs feature/login

# Ignorer les changements d'espacement
git merge -X ignore-space-change feature/login

# Patience : algorithme plus lent mais meilleur
git merge -X patience feature/login
```

> [!warning] Attention `-X ours` (option) ≠ `-s ours` (stratégie)
> 
> - `-X ours` : résout les conflits en favorisant votre version
> - `-s ours` : ignore complètement l'autre branche

### Tableau récapitulatif

|Stratégie|Usage principal|Gère conflits|Performance|
|---|---|---|---|
|**ort**|Par défaut moderne|✅ Oui|⚡⚡⚡|
|**recursive**|Ancien défaut|✅ Oui|⚡⚡|
|**resolve**|Fusion simple|✅ Oui|⚡⚡⚡|
|**octopus**|Multi-branches|❌ Non|⚡|
|**ours**|Ignorer l'autre|N/A|⚡⚡⚡|
|**subtree**|Sous-projets|✅ Oui|⚡|

---

## ⚠️ Pièges courants et bonnes pratiques

### 🚫 Pièges à éviter

> [!warning] Ne jamais fusionner avec des changements non commités
> 
> ```bash
> # ❌ MAUVAIS - risque de perte de données
> git merge feature/login  # avec des fichiers modifiés
> 
> # ✅ BON - commitez ou stashez d'abord
> git stash
> git merge feature/login
> git stash pop
> ```

> [!warning] Attention à la branche active
> 
> ```bash
> # ❌ ERREUR COURANTE
> git checkout feature/login
> git merge main  # Vous fusionnez main dans votre feature !
> 
> # ✅ CORRECT
> git checkout main
> git merge feature/login  # Vous fusionnez la feature dans main
> ```

> [!warning] Ne forcez pas un fast-forward si impossible
> 
> ```bash
> # ❌ Cela échouera si les branches ont divergé
> git merge --ff-only feature/login
> # error: Not possible to fast-forward, aborting.
> 
> # ✅ Vérifiez d'abord ou acceptez un merge commit
> git merge feature/login
> ```

### ✅ Bonnes pratiques

> [!tip] Toujours mettre à jour avant de fusionner
> 
> ```bash
> # Récupérez les dernières modifications
> git checkout main
> git pull origin main
> 
> # Puis fusionnez
> git merge feature/login
> ```

> [!tip] Testez avant de fusionner dans main
> 
> ```bash
> # Créez une branche de test
> git checkout -b test-merge
> git merge feature/login
> 
> # Testez votre code
> # Si OK, fusionnez réellement dans main
> git checkout main
> git merge feature/login
> 
> # Supprimez la branche de test
> git branch -d test-merge
> ```

> [!tip] Utilisez des messages de merge descriptifs
> 
> ```bash
> # ❌ Message automatique peu informatif
> git merge feature/login
> 
> # ✅ Message personnalisé clair
> git merge --no-ff -m "feat: intégration du système d'authentification
> 
> - Login par email/password
> - Token JWT
> - Gestion des sessions
> 
> Closes #42" feature/login
> ```

> [!tip] Gardez un historique propre
> 
> ```bash
> # Option 1 : Rebase avant merge pour un historique linéaire
> git checkout feature/login
> git rebase main
> git checkout main
> git merge feature/login  # Fast-forward possible
> 
> # Option 2 : Squash merge pour un seul commit
> git checkout main
> git merge --squash feature/login
> git commit -m "feat: système de login complet"
> ```

### 🎯 Workflow recommandé

```bash
# 1. Préparez votre branche
git checkout feature/login
git rebase main          # Optionnel : pour un historique linéaire

# 2. Revenez sur main et mettez à jour
git checkout main
git pull origin main

# 3. Fusionnez avec un merge commit explicite
git merge --no-ff -m "feat: intégration login" feature/login

# 4. Vérifiez le résultat
git log --oneline --graph -10

# 5. Poussez vers le dépôt distant
git push origin main

# 6. Nettoyez (optionnel)
git branch -d feature/login          # Local
git push origin --delete feature/login  # Remote
```

### 📊 Visualiser les fusions

```bash
# Historique graphique complet
git log --oneline --graph --all --decorate

# Voir uniquement les merge commits
git log --merges --oneline

# Voir les commits d'une feature fusionnée
git log --first-parent main

# Comparer deux branches avant fusion
git log --oneline --graph main..feature/login
```

> [!tip] Alias utile
> 
> ```bash
> # Ajoutez cet alias pour visualiser facilement
> git config --global alias.graph "log --oneline --graph --all --decorate"
> 
> # Utilisez-le
> git graph
> ```

---

## 🎓 Résumé

La fusion de branches est essentielle pour intégrer du travail parallèle :

- **`git merge`** combine deux branches en une
- **Fast-forward** : déplacement simple du pointeur (historique linéaire)
- **Merge commit** : création d'un nouveau commit avec deux parents (historique avec branches)
- **Stratégies** : ORT (défaut), recursive, octopus, ours, etc.
- **Bonnes pratiques** : mettre à jour avant fusion, tester, messages clairs, historique propre

> [!tip] Pour aller plus loin La gestion des conflits de fusion sera abordée dans une autre section du cours.