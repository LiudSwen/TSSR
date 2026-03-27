

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

## 🎯 Concept de branche

### Qu'est-ce qu'une branche ?

Une **branche** dans Git est un pointeur mobile vers un commit spécifique. C'est une ligne de développement indépendante qui vous permet de travailler sur différentes fonctionnalités ou corrections sans affecter le code principal.

> [!info] Métaphore de l'arbre Imaginez un arbre : le tronc principal représente votre branche principale, et chaque branche qui pousse à partir du tronc représente une ligne de développement parallèle. Vous pouvez faire grandir plusieurs branches simultanément sans qu'elles se gênent.

### Comment fonctionne une branche techniquement ?

Une branche n'est **pas** une copie complète de votre code. C'est simplement un fichier contenant les 40 caractères du hash SHA-1 du commit sur lequel elle pointe. C'est ce qui rend les branches Git si légères et rapides à créer.

```bash
# Visualiser le contenu du fichier d'une branche
cat .git/refs/heads/main
# Affiche quelque chose comme : a3f7b2c9d1e4f5a6b7c8d9e0f1a2b3c4d5e6f7a8
```

> [!tip] Git HEAD `HEAD` est un pointeur spécial qui indique sur quelle branche vous vous trouvez actuellement. Quand vous changez de branche, `HEAD` se déplace pour pointer vers la nouvelle branche.

### Structure interne des branches

```
┌──────────────┐
│    HEAD      │  ← Pointeur vers la branche courante
└──────┬───────┘
       │
       ▼
┌──────────────┐
│  main/master │  ← Pointeur vers un commit
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   Commit C3  │  ← Dernier commit de la branche
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   Commit C2  │
└──────┬───────┘
       │
       ▼
┌──────────────┐
│   Commit C1  │
└──────────────┘
```

---

## 💡 Pourquoi utiliser des branches ?

### Les avantages majeurs

Les branches sont l'une des fonctionnalités les plus puissantes de Git. Elles permettent un développement moderne et professionnel.

> [!example] Cas d'usage typiques
> 
> - **Développement de fonctionnalités** : Chaque nouvelle feature est développée dans sa propre branche
> - **Corrections de bugs** : Les hotfixes sont isolés pour ne pas perturber le développement en cours
> - **Expérimentation** : Tester des idées sans risque pour le code stable
> - **Travail collaboratif** : Plusieurs développeurs travaillent en parallèle sans conflit
> - **Releases** : Préparer des versions en isolation

### 1. Isolation du travail

Chaque branche crée un environnement isolé où vous pouvez travailler sans affecter le reste du projet.

```bash
# Scenario : Vous travaillez sur une nouvelle fonctionnalité
git checkout -b feature/nouvelle-interface

# Vous faites vos modifications, commits, etc.
# Le code sur la branche main reste intact
```

> [!warning] Sans branches Sans utiliser de branches, tous les développeurs travailleraient sur la même ligne de code, créant des conflits constants et rendant impossible le travail simultané sur plusieurs fonctionnalités.

### 2. Développement parallèle

Les branches permettent à plusieurs personnes (ou à une seule personne sur plusieurs tâches) de travailler simultanément.

```
main:         C1 ← C2 ← C3 ← C4
                   ↓
feature/login:     C5 ← C6
                   ↓
feature/api:       C7 ← C8 ← C9
```

### 3. Facilitation du code review

Les branches permettent de soumettre du code pour révision avant de l'intégrer à la branche principale (via les Pull Requests/Merge Requests).

> [!tip] Workflow moderne Le workflow typique moderne est :
> 
> 1. Créer une branche pour une tâche spécifique
> 2. Développer et committer sur cette branche
> 3. Pousser la branche vers le dépôt distant
> 4. Créer une Pull Request pour révision
> 5. Fusionner après validation

### 4. Gestion des versions et releases

Les branches permettent de maintenir plusieurs versions d'un projet simultanément.

```bash
# Branches typiques dans un projet
main          # Code de production
develop       # Code en développement
release/1.2   # Préparation de la version 1.2
hotfix/bug-42 # Correction urgente en production
```

### 5. Expérimentation sans risque

Vous pouvez créer une branche, expérimenter, et si l'expérience échoue, simplement supprimer la branche sans laisser de trace.

```bash
# Créer une branche expérimentale
git checkout -b experiment/new-algorithm

# Après des tests concluants négatifs
git checkout main
git branch -D experiment/new-algorithm  # Suppression complète
```

> [!info] Avantage de Git Créer et supprimer des branches est instantané dans Git. N'hésitez pas à en créer autant que nécessaire !

---

## 🏆 La branche main/master

### Historique et terminologie

La branche principale d'un dépôt Git est traditionnellement appelée **master**. Depuis 2020, la communauté Git a progressivement adopté le nom **main** comme nouveau standard par défaut.

> [!info] Évolution de la nomenclature
> 
> - **Avant 2020** : `master` était le nom par défaut
> - **Depuis 2020** : `main` est devenu le nouveau standard
> - **Aujourd'hui** : Les deux coexistent, mais `main` est recommandé pour les nouveaux projets

```bash
# Vérifier le nom de votre branche principale
git branch

# Renommer master en main (si nécessaire)
git branch -m master main
```

### Rôle de la branche principale

La branche principale est la branche de référence de votre projet. C'est généralement celle qui contient le code stable et prêt pour la production.

> [!warning] Branche protégée Dans la plupart des projets professionnels, la branche principale est **protégée** :
> 
> - Pas de push direct autorisé
> - Les modifications passent par des Pull Requests
> - Des tests automatiques doivent passer avant la fusion
> - Une ou plusieurs revues de code sont requises

### Caractéristiques importantes

|Caractéristique|Description|
|---|---|
|**Stabilité**|Doit toujours contenir du code fonctionnel|
|**Production**|Souvent déployée automatiquement en production|
|**Base de travail**|Point de départ pour créer de nouvelles branches|
|**Historique**|Contient l'historique principal du projet|
|**Protection**|Généralement protégée contre les modifications directes|

### Bonnes pratiques

#### 1. Ne jamais travailler directement sur main

```bash
# ❌ MAUVAISE PRATIQUE
git checkout main
# ... faire des modifications directement ...
git commit -am "Quick fix"

# ✅ BONNE PRATIQUE
git checkout -b hotfix/quick-fix
# ... faire des modifications ...
git commit -am "Quick fix"
# Puis créer une Pull Request
```

> [!tip] Règle d'or Considérez la branche `main` comme sacrée : toute modification doit passer par une branche dédiée et une revue.

#### 2. Garder main toujours fonctionnel

La branche principale doit toujours compiler, passer tous les tests, et être déployable.

```bash
# Avant de fusionner dans main, vérifier :
# 1. Les tests passent
npm test

# 2. Le code compile
npm run build

# 3. Les standards de code sont respectés
npm run lint
```

#### 3. Synchroniser régulièrement

Si vous travaillez en équipe, synchronisez régulièrement votre copie locale de `main` avec le dépôt distant.

```bash
# Récupérer les dernières modifications de main
git checkout main
git pull origin main

# Puis mettre à jour votre branche de travail
git checkout feature/ma-fonctionnalite
git merge main  # Ou git rebase main
```

> [!warning] Conflit potentiel Plus vous attendez avant de synchroniser, plus vous risquez d'avoir des conflits à résoudre. Synchronisez quotidiennement si possible.

### Configuration de la branche par défaut

#### Lors de l'initialisation d'un nouveau dépôt

```bash
# Méthode 1 : Définir main comme branche initiale
git init -b main

# Méthode 2 : Initialiser puis renommer
git init
git branch -m main
```

#### Configuration globale

Vous pouvez configurer Git pour toujours utiliser `main` comme nom de branche par défaut.

```bash
# Configuration globale pour tous les nouveaux dépôts
git config --global init.defaultBranch main

# Vérifier la configuration
git config --get init.defaultBranch
```

### Main dans différents workflows

La branche principale joue un rôle différent selon le workflow adopté :

#### Git Flow

```
main      → Code en production (stable)
develop   → Code en développement (intégration)
feature/* → Nouvelles fonctionnalités
release/* → Préparation de release
hotfix/*  → Corrections urgentes
```

> [!info] Dans Git Flow `main` contient uniquement les versions officielles. Le développement quotidien se fait sur `develop`.

#### GitHub Flow

```
main      → Code en production et développement
feature/* → Toutes les modifications (features, fixes, etc.)
```

> [!info] Dans GitHub Flow `main` est à la fois la branche de production et la base pour tout nouveau développement. Plus simple mais nécessite une excellente discipline.

#### Trunk-Based Development

```
main      → Branche unique où tout le monde commit régulièrement
```

> [!info] Dans Trunk-Based `main` (ou `trunk`) est la seule branche longue durée. Les branches de fonctionnalités sont très courtes (quelques heures à quelques jours maximum).

### Protection de la branche principale

Sur les plateformes comme GitHub, GitLab ou Bitbucket, vous pouvez configurer des règles de protection :

```
Règles de protection typiques :
├─ Require pull request reviews (1-2 approbations)
├─ Require status checks to pass (tests CI/CD)
├─ Require branches to be up to date
├─ Require signed commits
└─ Restrict who can push
```

> [!tip] Sécurité Même si vous êtes seul sur un projet, activer les protections sur `main` vous force à suivre les bonnes pratiques et évite les erreurs.

---

## 🎨 Visualisation des concepts

### Évolution d'un projet avec branches

```
Temps →

main:     C1 ← C2 ←──────────────── C7 (merge feature)
                ↓                    ↑
feature:        C3 ← C4 ← C5 ← C6 ──┘

Légende :
C1-C7 : Commits
←     : Relation parent-enfant
↓     : Création de branche
↑     : Fusion de branche
```

### État de HEAD selon la branche

```bash
# Sur la branche main
HEAD → main → C3

# Après checkout sur feature
HEAD → feature → C6

# En mode "detached HEAD" (sur un commit spécifique)
HEAD → C4
```

> [!warning] Detached HEAD Nous aborderons le mode "detached HEAD" dans une partie ultérieure. Pour l'instant, retenez simplement que `HEAD` pointe normalement vers une branche, pas directement vers un commit.

---

## 🔧 Pièges courants

### 1. Confondre HEAD et la branche courante

```bash
# HEAD pointe vers la branche, pas l'inverse
HEAD → main → commit_actuel

# Quand on change de branche, HEAD se déplace
git checkout develop
HEAD → develop → autre_commit
```

### 2. Penser qu'une branche est une copie du code

> [!warning] Idée fausse Une branche n'est PAS une copie de tout votre code. C'est juste un pointeur de 41 octets vers un commit. Git reconstruit votre répertoire de travail en fonction du commit pointé.

### 3. Avoir peur de créer des branches

```bash
# Les branches sont gratuites et instantanées !
# N'hésitez pas à en créer autant que nécessaire

# Créer une branche prend quelques millisecondes
git checkout -b test-rapide
```

### 4. Travailler directement sur main "pour aller plus vite"

C'est l'erreur classique du débutant. Cela peut sembler plus rapide au début, mais crée des problèmes par la suite :

- Impossible de revenir en arrière proprement
- Difficile de faire des revues de code
- Conflits avec les autres développeurs
- Historique confus

---

## 💎 Astuces avancées

### Astuce 1 : Nommage des branches

Adoptez une convention de nommage claire :

```bash
# Convention type
<type>/<description-courte>

# Exemples
feature/user-authentication
bugfix/login-crash
hotfix/security-patch
docs/update-readme
refactor/optimize-queries
```

### Astuce 2 : Visualiser les branches graphiquement

```bash
# Afficher un graphique ASCII des branches
git log --oneline --graph --all --decorate

# Alias pratique à ajouter dans votre config
git config --global alias.graph "log --oneline --graph --all --decorate"

# Utilisation
git graph
```

### Astuce 3 : Connaître la branche courante dans le terminal

Ajoutez la branche courante à votre prompt shell :

```bash
# Pour bash (dans ~/.bashrc)
parse_git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}
PS1='\u@\h \W$(parse_git_branch) \$ '

# Résultat : user@machine ~/project (main) $
```

### Astuce 4 : Lister les branches avec plus d'informations

```bash
# Voir toutes les branches avec leur dernier commit
git branch -v

# Voir les branches fusionnées dans main
git branch --merged main

# Voir les branches non fusionnées
git branch --no-merged main
```

---

## 📚 Récapitulatif

> [!success] Points clés à retenir
> 
> - Une **branche** est un pointeur léger vers un commit
> - Les branches permettent le **développement parallèle** et l'**isolation** du travail
> - La branche **main** (ou master) est la branche principale, généralement protégée
> - **HEAD** est un pointeur qui indique sur quelle branche vous êtes
> - Créer des branches est **gratuit et rapide** - utilisez-les sans modération
> - **Ne travaillez jamais directement sur main** en contexte professionnel
> - Les branches sont la base de tous les **workflows Git modernes**

---

_Cours créé pour une utilisation dans Obsidian - Partie : Les Branches_