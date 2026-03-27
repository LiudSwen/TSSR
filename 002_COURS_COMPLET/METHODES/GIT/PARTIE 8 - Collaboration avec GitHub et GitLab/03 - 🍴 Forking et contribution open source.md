

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

Le **forking** est le mécanisme central de la collaboration open source. Contrairement au travail en équipe où vous avez directement accès au repository principal, la contribution open source nécessite de créer votre propre copie du projet (un fork) sur laquelle vous travaillez librement avant de proposer vos modifications.

> [!info] Philosophie du fork Le fork permet à quiconque de contribuer à un projet sans avoir besoin de permissions spéciales. C'est la base de la collaboration décentralisée dans l'open source.

---

## 🔱 Fork d'un repository

### Qu'est-ce qu'un fork ?

Un **fork** est une copie complète d'un repository distant dans votre propre compte GitHub/GitLab. Cette copie :

- Contient tout l'historique du projet original
- Est totalement indépendante (vous pouvez la modifier sans affecter l'original)
- Maintient un lien avec le repository source pour faciliter la synchronisation

> [!example] Analogie C'est comme photocopier un livre pour y annoter vos notes personnelles. L'original reste intact, mais vous pouvez travailler librement sur votre copie.

**Quand forker ?**

- Vous souhaitez contribuer à un projet open source
- Vous voulez expérimenter sur un projet sans risque
- Vous voulez créer une variante personnalisée d'un projet

### Créer un fork

**Sur GitHub :**

1. Rendez-vous sur le repository que vous souhaitez forker
2. Cliquez sur le bouton **"Fork"** en haut à droite
3. Choisissez votre compte personnel ou une organisation
4. (Optionnel) Décochez "Copy the main branch only" si vous voulez toutes les branches

```bash
# Aucune commande Git nécessaire, 
# le fork se fait via l'interface web
```

**Sur GitLab :**

1. Allez sur le projet source
2. Cliquez sur **"Fork"**
3. Sélectionnez le namespace (votre compte ou un groupe)
4. Configurez la visibilité si nécessaire

> [!tip] Astuce Vous pouvez également forker via la CLI GitHub : `gh repo fork <owner/repo> --clone`

### Cloner son fork

Une fois le fork créé, clonez-le en local pour commencer à travailler :

```bash
# Cloner votre fork (remplacez par votre nom d'utilisateur)
git clone https://github.com/VOTRE_USERNAME/nom-du-projet.git
cd nom-du-projet

# Vérifier l'origine
git remote -v
# origin  https://github.com/VOTRE_USERNAME/nom-du-projet.git (fetch)
# origin  https://github.com/VOTRE_USERNAME/nom-du-projet.git (push)
```

> [!warning] Ne clonez pas le repository original Si vous clonez directement le repository original (pas votre fork), vous ne pourrez pas pousser vos modifications. Clonez toujours **votre fork**.

---

## 🔄 Upstream et Origin

### Comprendre les remotes

Dans le workflow de contribution, vous travaillez avec **deux repositories distants** :

|Remote|Description|URL typique|
|---|---|---|
|**origin**|Votre fork personnel|`https://github.com/VOUS/projet.git`|
|**upstream**|Le repository original|`https://github.com/AUTEUR_ORIGINAL/projet.git`|

```
          [Repository Original - upstream]
                      ⬇️ fork
          [Votre Fork - origin]
                      ⬇️ clone
          [Votre copie locale]
```

> [!info] Pourquoi deux remotes ?
> 
> - **origin** : Vous poussez vos modifications vers votre fork
> - **upstream** : Vous récupérez les dernières mises à jour du projet original

### Configurer l'upstream

Après avoir cloné votre fork, ajoutez le repository original comme remote "upstream" :

```bash
# Ajouter l'upstream (remplacez par l'URL du repo original)
git remote add upstream https://github.com/AUTEUR_ORIGINAL/nom-du-projet.git

# Vérifier la configuration
git remote -v
# origin    https://github.com/VOUS/nom-du-projet.git (fetch)
# origin    https://github.com/VOUS/nom-du-projet.git (push)
# upstream  https://github.com/AUTEUR_ORIGINAL/nom-du-projet.git (fetch)
# upstream  https://github.com/AUTEUR_ORIGINAL/nom-du-projet.git (push)
```

> [!tip] Convention de nommage "upstream" est le nom conventionnel, mais vous pourriez utiliser n'importe quel nom. Respectez la convention pour faciliter la collaboration.

### Visualiser ses remotes

```bash
# Lister les remotes avec leurs URLs
git remote -v

# Voir les détails d'un remote spécifique
git remote show origin
git remote show upstream

# Voir toutes les branches distantes
git branch -r
# origin/main
# origin/develop
# upstream/main
# upstream/develop
```

> [!example] Configuration complète Après setup, vous devriez avoir :
> 
> - `origin` → pointe vers votre fork (lecture/écriture)
> - `upstream` → pointe vers le repo original (lecture seule en pratique)

---

## 🤝 Contribution à un projet externe

### Le workflow de contribution

Le workflow standard de contribution open source suit ces étapes :

```
1. Fork du projet
2. Clone de votre fork
3. Ajout de l'upstream
4. Création d'une branche de feature
5. Développement et commits
6. Push vers votre fork
7. Création d'une Pull Request (PR)
8. Revue et itérations
9. Merge par les mainteneurs
```

> [!info] Pull Request vs Merge Request GitHub utilise le terme "Pull Request" (PR), GitLab utilise "Merge Request" (MR). C'est exactement la même chose : une demande d'intégration de vos modifications.

### Créer une branche de travail

**Ne travaillez jamais directement sur `main` !** Créez toujours une branche dédiée à votre contribution :

```bash
# D'abord, assurez-vous d'être à jour avec l'upstream
git checkout main
git fetch upstream
git merge upstream/main

# Créer et basculer sur une nouvelle branche
git checkout -b fix/typo-in-readme

# Ou pour une feature
git checkout -b feature/add-dark-mode

# Ou pour une correction de bug
git checkout -b bugfix/fix-login-error
```

> [!tip] Nommage des branches Utilisez des noms descriptifs avec un préfixe :
> 
> - `feature/` : nouvelle fonctionnalité
> - `fix/` ou `bugfix/` : correction de bug
> - `docs/` : documentation
> - `refactor/` : refactorisation
> - `test/` : ajout de tests

### Préparer ses commits

Faites des commits clairs, atomiques et bien documentés :

```bash
# Faire vos modifications dans les fichiers
# ...

# Ajouter les fichiers modifiés
git add fichier1.js fichier2.css

# Commit avec un message descriptif
git commit -m "Fix: Correct typo in README installation section"

# Pour un commit plus détaillé
git commit -m "Feature: Add dark mode toggle

- Add theme switcher component
- Implement CSS variables for theming
- Add user preference persistence in localStorage
- Update documentation with usage examples"
```

> [!warning] Qualité des commits Les mainteneurs jugeront votre contribution aussi sur la qualité de vos commits. Des commits clairs facilitent la revue et l'historique du projet.

**Structure d'un bon message de commit pour l'open source :**

```
Type: Short description (max 50 chars)

- Detailed explanation if needed (wrap at 72 chars)
- Why the change was made
- What was the previous behavior
- What is the new behavior
- Any breaking changes or migration notes

Fixes #123
```

### Créer une Pull Request

Une fois vos commits prêts, poussez votre branche vers votre fork :

```bash
# Push de votre branche vers origin (votre fork)
git push origin fix/typo-in-readme

# Si c'est la première fois, Git vous suggérera :
git push --set-upstream origin fix/typo-in-readme
```

**Ensuite, sur GitHub/GitLab :**

1. Allez sur votre fork, GitHub affichera un message "Compare & pull request"
2. Cliquez sur **"Create Pull Request"**
3. Remplissez le template de PR (s'il existe)
4. Donnez un titre clair et une description détaillée

> [!example] Template de description de PR
> 
> ```markdown
> ## Description
> Brief description of what this PR does
> 
> ## Type of change
> - [ ] Bug fix
> - [ ] New feature
> - [ ] Breaking change
> - [ ] Documentation update
> 
> ## Checklist
> - [ ] My code follows the project's style guidelines
> - [ ] I have added tests that prove my fix/feature works
> - [ ] All new and existing tests pass
> - [ ] I have updated the documentation
> 
> ## Related Issues
> Fixes #123
> ```

> [!tip] Première contribution Beaucoup de projets ont un label "good first issue" pour les débutants. Cherchez ces issues pour votre première contribution !

### Gérer les retours et révisions

Les mainteneurs vont probablement demander des modifications :

```bash
# Faire les modifications demandées
# ...

# Commit des changements
git add .
git commit -m "Address review comments: improve error handling"

# Push vers la même branche
git push origin fix/typo-in-readme
```

> [!info] Mise à jour automatique Dès que vous poussez sur votre branche, la Pull Request est automatiquement mise à jour !

**Si on vous demande de squash vos commits :**

```bash
# Rebaser interactivement les 3 derniers commits
git rebase -i HEAD~3

# Dans l'éditeur, changez 'pick' en 'squash' (ou 's') 
# pour les commits à fusionner

# Force push (nécessaire après un rebase)
git push --force-with-lease origin fix/typo-in-readme
```

> [!warning] Force push sur les PRs Utilisez `--force-with-lease` plutôt que `--force`. C'est plus sûr car ça vérifie que personne d'autre n'a poussé entre temps.

---

## ⚡ Synchronisation avec l'upstream

### Pourquoi synchroniser ?

Le projet original évolue constamment. Pour éviter les conflits et garder votre fork à jour :

```
Temps →
upstream: A---B---C---D---E
                  ↓
origin:   A---B---C (votre fork est en retard)
```

> [!warning] Risque de divergence Si vous ne synchronisez pas régulièrement, votre fork s'éloignera de l'upstream, rendant les Pull Requests difficiles à merger.

### Récupérer les changements

```bash
# Récupérer les dernières modifications de l'upstream
git fetch upstream

# Voir les différences
git log --oneline main..upstream/main

# Ou voir les commits graphiquement
git log --all --graph --oneline
```

> [!tip] Fetch vs Pull `fetch` télécharge les changements sans les appliquer. C'est plus sûr car ça vous laisse inspecter avant de fusionner.

### Mettre à jour sa branche

**Méthode 1 : Merge (conserve l'historique)**

```bash
# Se placer sur main
git checkout main

# Fusionner les changements upstream
git merge upstream/main

# Pousser vers votre fork
git push origin main
```

**Méthode 2 : Rebase (historique linéaire)**

```bash
# Se placer sur main
git checkout main

# Rebaser sur upstream/main
git rebase upstream/main

# Force push car l'historique a été réécrit
git push --force-with-lease origin main
```

> [!info] Merge vs Rebase
> 
> - **Merge** : Préserve l'historique complet, crée un commit de merge
> - **Rebase** : Historique linéaire, plus propre, mais réécrit l'histoire (nécessite force push)
> 
> Pour un fork personnel, le rebase est souvent préféré.

**Mettre à jour une branche de feature :**

```bash
# D'abord, mettre à jour main
git checkout main
git fetch upstream
git merge upstream/main
git push origin main

# Puis rebaser votre branche de feature
git checkout feature/my-feature
git rebase main

# Si des conflits apparaissent, les résoudre puis :
git rebase --continue

# Force push de votre branche
git push --force-with-lease origin feature/my-feature
```

> [!tip] Workflow quotidien Prenez l'habitude de synchroniser votre fork chaque matin avant de commencer à travailler.

### Résoudre les conflits

Si des conflits surviennent lors du merge/rebase :

```bash
# Git vous indique les fichiers en conflit
git status
# both modified: fichier.txt

# Ouvrir le fichier et chercher les marqueurs
<<<<<<< HEAD
Votre version
=======
Version upstream
>>>>>>> upstream/main

# Éditer le fichier pour résoudre le conflit
# Supprimer les marqueurs et garder le code correct

# Marquer comme résolu
git add fichier.txt

# Si c'était un merge
git commit

# Si c'était un rebase
git rebase --continue
```

> [!warning] Gestion des conflits complexes Si les conflits sont trop nombreux, vous pouvez annuler :
> 
> - `git merge --abort` (pour un merge)
> - `git rebase --abort` (pour un rebase)

---

## ⚠️ Pièges courants

> [!warning] Travailler directement sur main **Problème** : Vous modifiez directement la branche `main` de votre fork **Solution** : Toujours créer une branche dédiée pour chaque contribution

> [!warning] Oublier d'ajouter l'upstream **Problème** : Impossible de récupérer les mises à jour du projet original **Solution** : `git remote add upstream <URL_ORIGINAL>`

> [!warning] Force push sur une branche partagée **Problème** : Récrire l'historique d'une branche où d'autres collaborent **Solution** : N'utilisez force push que sur vos branches personnelles

> [!warning] Commits trop gros ou non descriptifs **Problème** : "Fixed stuff", "WIP", ou un commit de 50 fichiers **Solution** : Commits atomiques avec messages clairs

> [!warning] Ne pas lire le CONTRIBUTING.md **Problème** : Votre PR ne suit pas les conventions du projet **Solution** : Lisez toujours `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md` et les issues templates

> [!warning] Push vers l'upstream **Problème** : Tenter de push directement vers le repo original **Solution** : Vous ne pouvez pas (heureusement !). Vous devez passer par une PR

---

## 💡 Bonnes pratiques

### Avant de contribuer

✅ **Lisez la documentation de contribution**

```bash
# Cherchez ces fichiers dans le repo
- CONTRIBUTING.md
- CODE_OF_CONDUCT.md
- .github/PULL_REQUEST_TEMPLATE.md
```

✅ **Vérifiez si l'issue existe déjà**

- Consultez les issues ouvertes
- Commentez pour proposer votre aide
- Attendez qu'un mainteneur vous assigne

✅ **Commencez petit**

- Corrections de typos
- Documentation
- Tests
- Puis des features plus complexes

### Pendant le développement

✅ **Synchronisez régulièrement**

```bash
# Tous les matins
git fetch upstream
git rebase upstream/main
```

✅ **Testez votre code**

```bash
# Lancez les tests du projet
npm test  # ou yarn test, pytest, etc.

# Vérifiez le linting
npm run lint
```

✅ **Commits atomiques et clairs**

```bash
# Un commit = une modification logique
git commit -m "Docs: Fix typo in installation guide"
git commit -m "Test: Add unit tests for auth module"
```

✅ **Gardez votre PR à jour**

```bash
# Rebaser régulièrement sur main pour éviter les conflits
git fetch upstream
git rebase upstream/main
git push --force-with-lease origin feature/my-feature
```

### Communication

✅ **Soyez patient et poli**

- Les mainteneurs sont souvent bénévoles
- Acceptez les retours constructifs
- N'insistez pas si votre PR est refusée

✅ **Expliquez vos choix**

- Justifiez pourquoi vous avez fait ce choix de design
- Mentionnez les alternatives considérées
- Liez vers la documentation pertinente

✅ **Répondez aux commentaires**

- Accusez réception des reviews
- Expliquez vos modifications
- Demandez des clarifications si besoin

---

## 🎓 Astuces avancées

### Automatiser la synchronisation

Créez un alias pour synchroniser facilement :

```bash
# Dans votre .gitconfig
git config --global alias.sync '!git fetch upstream && git rebase upstream/main'

# Utilisation
git sync
```

### Maintenir plusieurs forks

Si vous contribuez à plusieurs projets :

```bash
# Dans chaque repo, configurez l'upstream
cd projet1
git remote add upstream <URL1>

cd ../projet2  
git remote add upstream <URL2>

# Créez un alias pour tout synchroniser
# Dans votre .bashrc ou .zshrc
alias sync-forks='
  cd ~/projets/fork1 && git fetch upstream && git rebase upstream/main && git push origin main &&
  cd ~/projets/fork2 && git fetch upstream && git rebase upstream/main && git push origin main
'
```

### Utiliser GitHub CLI pour les PRs

```bash
# Installer gh (GitHub CLI)
# https://cli.github.com/

# Créer une PR directement depuis le terminal
gh pr create --title "Fix: Correct login bug" --body "Description..."

# Voir les PRs
gh pr list

# Checkout une PR pour la tester
gh pr checkout 123

# Merger une PR
gh pr merge 123
```

### Contribuer sans fork (pour les petites corrections)

GitHub permet d'éditer directement dans l'interface web :

1. Trouvez le fichier à modifier
2. Cliquez sur l'icône crayon ✏️
3. Faites vos modifications
4. GitHub crée automatiquement un fork et une branche
5. Proposez directement la PR

> [!tip] Parfait pour les typos Idéal pour corriger une faute de frappe dans la doc sans passer par tout le workflow !

### Surveiller un projet

Pour rester informé des évolutions d'un projet :

```bash
# Via GitHub CLI
gh repo watch OWNER/REPO

# Ou sur l'interface web
# Cliquez sur "Watch" et choisissez vos notifications
```

Options de surveillance :

- **Participating** : Seulement vos conversations
- **All Activity** : Tous les issues, PRs, releases
- **Custom** : Choisir ce qui vous intéresse

### Nettoyer après un merge

Une fois votre PR mergée :

```bash
# Supprimer la branche locale
git branch -d feature/my-feature

# Supprimer la branche distante sur votre fork
git push origin --delete feature/my-feature

# Mettre à jour votre main
git checkout main
git fetch upstream
git merge upstream/main
git push origin main
```

> [!tip] Automatisation GitHub GitHub propose de supprimer automatiquement la branche après merge. Activez cette option dans les settings de votre repo !

---

> [!info] Vous êtes prêt à contribuer ! Le forking et la contribution open source peuvent sembler intimidants au début, mais avec de la pratique, ce workflow deviendra naturel. Commencez par de petites contributions et progressez graduellement vers des features plus complexes. La communauté open source est généralement bienveillante et ravie d'accueillir de nouveaux contributeurs ! 🚀