

## 📘 PARTIE 1 : Introduction et concepts fondamentaux

**Fichier Obsidian suggéré :** `01-git-introduction-concepts.md`

**Sujets à couvrir :**

1. **Qu'est-ce que GIT ?**
    
    - Définition et historique
    - Différence entre GIT et GitHub/GitLab/Bitbucket
    - Système de contrôle de version distribué vs centralisé
    - Cas d'usage et avantages
2. **Installation et configuration**
    
    - Installation sur Windows/Linux/macOS
    - Configuration initiale (user.name, user.email)
    - Configuration de l'éditeur par défaut
    - Vérification de l'installation
3. **Concepts de base**
    
    - Repository (dépôt)
    - Working directory (répertoire de travail)
    - Staging area (zone de préparation)
    - Commit
    - Les trois états d'un fichier

---

## 📘 PARTIE 2 : Commandes de base et workflow local

**Fichier Obsidian suggéré :** `02-git-commandes-base.md`

**Sujets à couvrir :**

1. **Initialisation et clonage**
    
    - `git init`
    - `git clone`
    - Structure du dossier .git
2. **Gestion des fichiers**
    
    - `git status`
    - `git add`
    - `git commit`
    - `git log`
    - `git diff`
3. **Consultation de l'historique**
    
    - `git log` avec options (--oneline, --graph, --all)
    - `git show`
    - Recherche dans l'historique
4. **Annulation et correction**
    
    - `git restore`
    - `git reset`
    - `git revert`
    - `git commit --amend`
    - Différences entre les méthodes d'annulation

---

## 📘 PARTIE 3 : Les branches

**Fichier Obsidian suggéré :** `03-git-branches.md`

**Sujets à couvrir :**

1. **Concept de branche**
    
    - Qu'est-ce qu'une branche ?
    - Pourquoi utiliser des branches ?
    - La branche main/master
2. **Manipulation des branches**
    
    - `git branch`
    - `git checkout` / `git switch`
    - `git branch -d` / `git branch -D`
    - Lister et filtrer les branches
3. **Fusion de branches**
    
    - `git merge`
    - Fast-forward vs merge commit
    - Stratégies de fusion
4. **Gestion des conflits**
    
    - Identifier un conflit
    - Marqueurs de conflit
    - Résolution manuelle
    - Outils de résolution de conflits
    - `git mergetool`

---

## 📘 PARTIE 4 : Travail avec des dépôts distants

**Fichier Obsidian suggéré :** `04-git-depots-distants.md`

**Sujets à couvrir :**

1. **Configuration des remotes**
    
    - `git remote add`
    - `git remote -v`
    - `git remote remove`
    - `git remote rename`
2. **Synchronisation**
    
    - `git fetch`
    - `git pull`
    - `git push`
    - Différence entre fetch et pull
    - Options de push (--force, --force-with-lease)
3. **Gestion des branches distantes**
    
    - Tracking branches
    - `git push -u origin <branch>`
    - Supprimer une branche distante
    - `git branch -r` et `git branch -a`

---

## 📘 PARTIE 5 : Workflows et stratégies de branches

**Fichier Obsidian suggéré :** `05-git-workflows.md`

**Sujets à couvrir :**

1. **Git Flow**
    
    - Branches principales (main, develop)
    - Branches de support (feature, release, hotfix)
    - Cycle de vie complet
2. **GitHub Flow**
    
    - Principe de fonctionnement
    - Création de feature branches
    - Pull requests
    - Déploiement continu
3. **Trunk-Based Development**
    
    - Principe
    - Short-lived branches
    - Feature flags
4. **Bonnes pratiques**
    
    - Nommage des branches
    - Fréquence des commits
    - Messages de commit conventionnels
    - Quand créer une branche

---

## 📘 PARTIE 6 : Commandes avancées

**Fichier Obsidian suggéré :** `06-git-avance.md`

**Sujets à couvrir :**

1. **Rebase**
    
    - `git rebase`
    - Différence entre merge et rebase
    - Rebase interactif
    - Golden rule du rebase
2. **Stash**
    
    - `git stash`
    - `git stash list`
    - `git stash apply` / `git stash pop`
    - `git stash drop`
3. **Cherry-pick**
    
    - `git cherry-pick`
    - Cas d'usage
    - Gestion des conflits lors du cherry-pick
4. **Tags**
    
    - `git tag`
    - Tags légers vs annotés
    - Pousser des tags
    - Supprimer des tags
5. **Recherche et navigation**
    
    - `git blame`
    - `git bisect`
    - `git grep`
    - `git reflog`

---

## 📘 PARTIE 7 : Fichiers spéciaux et configuration

**Fichier Obsidian suggéré :** `07-git-fichiers-config.md`

**Sujets à couvrir :**

1. **.gitignore**
    
    - Syntaxe et patterns
    - Fichiers .gitignore globaux vs locaux
    - Templates .gitignore
    - Ignorer des fichiers déjà trackés
2. **.gitattributes**
    
    - Normalisation des fins de ligne
    - Filtres et diff personnalisés
    - Gestion des fichiers binaires
3. **Configuration GIT**
    
    - Niveaux de configuration (system, global, local)
    - Alias
    - Configurations utiles
    - `git config --list`
4. **Hooks**
    
    - Qu'est-ce qu'un hook ?
    - Hooks côté client vs serveur
    - Hooks courants (pre-commit, post-commit, pre-push)
    - Exemples d'utilisation

---

## 📘 PARTIE 8 : Collaboration avec GitHub/GitLab

**Fichier Obsidian suggéré :** `08-git-collaboration-plateformes.md`

**Sujets à couvrir :**

1. **Authentification**
    
    - HTTPS vs SSH
    - Génération de clés SSH
    - Personal Access Tokens
    - Configuration des credentials
2. **Pull Requests / Merge Requests**
    
    - Création d'une PR/MR
    - Review de code
    - Commentaires et suggestions
    - Approbation et merge
3. **Forking et contribution open source**
    
    - Fork d'un repository
    - Upstream et origin
    - Contribution à un projet externe
    - Synchronisation avec l'upstream
4. **Issues et gestion de projet**
    
    - Création et gestion d'issues
    - Labels et milestones
    - Lien entre commits et issues
    - Projects boards

---

## 📘 PARTIE 9 : Sécurité et bonnes pratiques

**Fichier Obsidian suggéré :** `09-git-securite-bonnes-pratiques.md`

**Sujets à couvrir :**

1. **Sécurité**
    
    - Ne jamais committer de secrets
    - Outils de scan (git-secrets, gitleaks)
    - Suppression de données sensibles de l'historique
    - Signature des commits (GPG)
2. **Gestion des gros fichiers**
    
    - Problématiques des fichiers binaires
    - Git LFS (Large File Storage)
    - Alternatives à GIT pour les gros fichiers
3. **Performance et optimisation**
    
    - `git gc`
    - Shallow clone
    - Sparse checkout
    - Optimisation du repository
4. **Résolution de problèmes courants**
    
    - Repository corrompu
    - Commits perdus
    - Détached HEAD state
    - Merge en cours bloqué

---

## 📘 PARTIE 10 : CI/CD et automatisation

**Fichier Obsidian suggéré :** `10-git-cicd-automatisation.md`

**Sujets à couvrir :**

1. **Introduction à la CI/CD**
    
    - Concepts de base
    - Intégration avec GIT
    - Déclencheurs basés sur GIT
2. **GitHub Actions**
    
    - Workflows
    - Actions et jobs
    - Secrets et variables d'environnement
    - Exemples de pipelines
3. **GitLab CI/CD**
    
    - .gitlab-ci.yml
    - Runners
    - Stages et jobs
    - Exemples de pipelines
4. **Automatisation**
    
    - Tests automatiques
    - Déploiement automatique
    - Versioning automatique
    - Release notes automatiques