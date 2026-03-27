

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

## Introduction

Les issues sont le système de gestion de tâches intégré à GitHub et GitLab. Elles permettent de suivre bugs, fonctionnalités, améliorations et toute autre tâche liée au projet. Contrairement aux commits qui tracent les changements de code, les issues tracent les discussions, décisions et l'organisation du travail.

> [!info] Pourquoi utiliser les issues ?
> 
> - **Centralisation** : Toute la communication projet au même endroit que le code
> - **Traçabilité** : Historique complet des décisions et discussions
> - **Collaboration** : Plusieurs personnes peuvent travailler ensemble efficacement
> - **Automatisation** : Lien direct entre le code et les tâches

---

## Création et gestion d'issues

### Qu'est-ce qu'une issue ?

Une issue est un ticket de suivi qui peut représenter :

- 🐛 Un bug à corriger
- ✨ Une nouvelle fonctionnalité à développer
- 📚 Une amélioration de documentation
- 💡 Une question ou discussion
- 🔧 Une tâche de maintenance

### Anatomie d'une issue

Une issue bien structurée contient :

|Élément|Description|Obligatoire|
|---|---|---|
|**Titre**|Résumé court et clair (50-70 caractères)|✅ Oui|
|**Description**|Détails, contexte, étapes de reproduction|✅ Oui|
|**Assignés**|Personnes responsables de l'issue|❌ Non|
|**Labels**|Catégorisation (bug, feature, etc.)|❌ Non|
|**Milestone**|Objectif ou version associée|❌ Non|
|**Projects**|Tableau de gestion associé|❌ Non|

### Créer une issue sur GitHub

#### Via l'interface web

1. Aller dans l'onglet **Issues** du repository
2. Cliquer sur **New issue**
3. Remplir le formulaire avec titre et description
4. Assigner des labels, personnes, milestones
5. Cliquer sur **Submit new issue**

#### Via GitHub CLI

```bash
# Installation de gh (si nécessaire)
# macOS: brew install gh
# Linux: sudo apt install gh
# Windows: winget install GitHub.cli

# Authentification
gh auth login

# Créer une issue simple
gh issue create --title "Bug: Erreur 404 sur la page d'accueil" --body "Description du bug"

# Créer une issue avec labels et assignation
gh issue create \
  --title "Feature: Ajouter l'authentification OAuth" \
  --body "Implémenter OAuth 2.0 avec Google et GitHub" \
  --label "enhancement,priority-high" \
  --assignee "@me"

# Créer une issue interactive (pose des questions)
gh issue create
```

### Créer une issue sur GitLab

#### Via l'interface web

1. Aller dans **Issues** → **New issue**
2. Remplir le formulaire
3. GitLab propose des templates d'issues

#### Via GitLab CLI

```bash
# Installation de glab
# macOS: brew install glab
# Linux: voir documentation GitLab
# Windows: scoop install glab

# Authentification
glab auth login

# Créer une issue
glab issue create --title "Bug: Crash au démarrage" --description "L'application crash..."

# Avec options
glab issue create \
  --title "Feature: Export PDF" \
  --description "Ajouter export PDF des rapports" \
  --label "enhancement" \
  --assignee @username
```

### Gérer les issues

#### Lister les issues

```bash
# GitHub - Lister toutes les issues ouvertes
gh issue list

# Filtrer par état
gh issue list --state closed
gh issue list --state all

# Filtrer par label
gh issue list --label "bug"
gh issue list --label "bug,priority-high"

# Filtrer par assigné
gh issue list --assignee "@me"
gh issue list --assignee "username"

# Limiter le nombre de résultats
gh issue list --limit 50

# GitLab - Même logique
glab issue list
glab issue list --closed
glab issue list --labels "bug"
```

#### Afficher une issue spécifique

```bash
# GitHub - Par numéro
gh issue view 42

# Afficher dans le navigateur
gh issue view 42 --web

# GitLab
glab issue view 42
glab issue view 42 --web
```

#### Modifier une issue

```bash
# GitHub - Éditer le titre
gh issue edit 42 --title "Nouveau titre"

# Éditer le corps
gh issue edit 42 --body "Nouvelle description"

# Ajouter des labels
gh issue edit 42 --add-label "bug,priority-high"

# Retirer des labels
gh issue edit 42 --remove-label "needs-triage"

# Assigner quelqu'un
gh issue edit 42 --add-assignee "@username"

# GitLab - Syntaxe similaire
glab issue update 42 --title "Nouveau titre"
glab issue update 42 --labels "bug,critical"
```

#### Fermer et rouvrir une issue

```bash
# GitHub - Fermer une issue
gh issue close 42

# Fermer avec commentaire
gh issue close 42 --comment "Résolu dans le commit abc123"

# Rouvrir une issue
gh issue reopen 42

# GitLab
glab issue close 42
glab issue reopen 42
```

#### Commenter une issue

```bash
# GitHub - Ajouter un commentaire
gh issue comment 42 --body "Je travaille dessus"

# Éditer dans l'éditeur par défaut
gh issue comment 42

# GitLab
glab issue note 42 --message "Commentaire"
```

> [!tip] Astuces pour de bonnes issues
> 
> - **Titre descriptif** : "Bug: Erreur 500 lors de l'upload" plutôt que "Ça marche pas"
> - **Contexte complet** : Version, système d'exploitation, étapes de reproduction
> - **Visuels** : Screenshots, GIFs, logs pour illustrer
> - **Markdown** : Utilisez la mise en forme pour la lisibilité
> - **Templates** : Créez des templates d'issues pour standardiser

### Templates d'issues

Les templates permettent de standardiser la création d'issues.

#### GitHub - Créer un template

Créer le fichier `.github/ISSUE_TEMPLATE/bug_report.md` :

```markdown
---
name: Bug Report
about: Signaler un bug
title: '[BUG] '
labels: bug
assignees: ''
---

## Description du bug
Une description claire et concise du bug.

## Étapes de reproduction
1. Aller sur '...'
2. Cliquer sur '...'
3. Voir l'erreur

## Comportement attendu
Ce qui devrait se passer normalement.

## Comportement actuel
Ce qui se passe réellement.

## Captures d'écran
Si applicable, ajoutez des screenshots.

## Environnement
- OS: [ex. Ubuntu 22.04]
- Navigateur: [ex. Chrome 120]
- Version: [ex. 1.2.3]

## Informations supplémentaires
Tout autre contexte utile.
```

#### GitLab - Créer un template

Créer le fichier `.gitlab/issue_templates/Bug.md` :

```markdown
## Résumé
Brève description du bug

## Étapes de reproduction
1. 
2. 
3. 

## Résultat actuel
Ce qui se passe

## Résultat attendu
Ce qui devrait se passer

## Logs pertinents
```

> [!warning] Pièges courants
> 
> - **Issues trop vagues** : "Améliorer les performances" sans détails exploitables
> - **Duplication** : Vérifier qu'une issue similaire n'existe pas déjà
> - **Pas de suivi** : Mettre à jour l'issue quand la situation évolue
> - **Assignation multiple** : Limiter à 1-2 personnes pour éviter la dilution de responsabilité

---

## Labels et milestones

### Labels (étiquettes)

Les labels permettent de catégoriser et filtrer les issues. Ils sont essentiels pour organiser le travail dans les projets de taille moyenne à grande.

#### Labels par défaut

GitHub et GitLab proposent des labels par défaut :

|Label|Signification|Couleur|
|---|---|---|
|`bug`|Quelque chose ne fonctionne pas|🔴 Rouge|
|`enhancement`|Nouvelle fonctionnalité ou amélioration|🟢 Vert|
|`documentation`|Amélioration de la documentation|🔵 Bleu|
|`duplicate`|Issue ou PR en doublon|🔘 Gris|
|`good first issue`|Bon pour les débutants|🟣 Violet|
|`help wanted`|Aide externe demandée|🟢 Vert clair|
|`invalid`|Pas un problème valide|⚪ Blanc|
|`question`|Plus d'information demandée|🟣 Rose|
|`wontfix`|Ne sera pas corrigé|⚪ Blanc|

#### Stratégies de labeling

**Approche par type** :

```
type: bug          # Bugs
type: feature      # Nouvelles fonctionnalités
type: refactor     # Refactoring
type: docs         # Documentation
type: test         # Tests
```

**Approche par priorité** :

```
priority: critical  # Bloque le fonctionnement
priority: high      # Importante mais non bloquante
priority: medium    # Standard
priority: low       # Peut attendre
```

**Approche par statut** :

```
status: needs-triage     # Doit être triée
status: in-progress      # En cours
status: blocked          # Bloquée
status: needs-review     # Attend une review
status: ready-to-merge   # Prête à merger
```

**Approche par composant** :

```
component: frontend
component: backend
component: database
component: api
component: infrastructure
```

#### Gérer les labels via CLI

```bash
# GitHub - Lister les labels
gh label list

# Créer un label
gh label create "priority-critical" \
  --description "Problème critique" \
  --color "d73a4a"

# Créer plusieurs labels d'un coup
gh label create "type: bug" --color "d73a4a"
gh label create "type: feature" --color "0e8a16"
gh label create "type: docs" --color "0075ca"

# Modifier un label
gh label edit "bug" --name "type: bug" --color "d73a4a"

# Supprimer un label
gh label delete "old-label"

# GitLab - Via API ou interface web
# glab ne supporte pas encore la gestion des labels
```

#### Codes couleur recommandés

```
Rouge (#d73a4a)    → Bugs, critiques
Orange (#d93f0b)   → Priorité haute
Jaune (#fbca04)    → À vérifier, attention
Vert (#0e8a16)     → Fonctionnalités, améliorations
Bleu (#0075ca)     → Documentation
Violet (#a371f7)   → Questions, discussions
Gris (#d4d4d4)     → Duplicate, wontfix
```

> [!example] Exemple de système de labels complet
> 
> ```
> # Types
> type: bug           # Rouge #d73a4a
> type: feature       # Vert #0e8a16
> type: refactor      # Bleu clair #1d76db
> type: docs          # Bleu #0075ca
> 
> # Priorités
> priority: critical  # Rouge foncé #b60205
> priority: high      # Orange #d93f0b
> priority: medium    # Jaune #fbca04
> priority: low       # Vert clair #c5def5
> 
> # Statut
> status: triage      # Gris #d4d4d4
> status: confirmed   # Jaune #fbca04
> status: in-progress # Bleu #0052cc
> status: blocked     # Rouge #d73a4a
> 
> # Composants
> area: frontend      # Cyan #00e5ff
> area: backend       # Violet #5319e7
> area: database      # Rose #c51162
> ```

### Milestones (jalons)

Les milestones regroupent des issues et PRs vers un objectif commun, généralement une version ou une échéance.

#### Qu'est-ce qu'un milestone ?

Un milestone représente :

- 📅 Une version (v1.0, v2.0, v2.1)
- 🎯 Un sprint (Sprint 15, Q1 2024)
- 🚀 Une release (Beta, RC1, Stable)
- 📊 Un objectif fonctionnel (MVP, Launch Ready)

#### Structure d'un milestone

|Élément|Description|
|---|---|
|**Titre**|Nom de la version ou sprint|
|**Description**|Objectifs et scope|
|**Date d'échéance**|Deadline (optionnel)|
|**Issues associées**|Liste des issues dans ce milestone|
|**Progression**|% de completion automatique|

#### Créer et gérer des milestones

```bash
# GitHub - Lister les milestones
gh api repos/:owner/:repo/milestones

# Via l'interface web (recommandé pour la création)
# Issues → Milestones → New milestone

# GitLab - Créer un milestone
glab api projects/:id/milestones \
  --method POST \
  --field title="v2.0" \
  --field description="Version 2.0 avec nouvelles features"
```

#### Assigner des issues à un milestone

```bash
# GitHub - Assigner une issue existante
gh issue edit 42 --milestone "v2.0"

# Créer une issue directement dans un milestone
gh issue create \
  --title "Implémenter authentification" \
  --milestone "v2.0"

# GitLab
glab issue update 42 --milestone "v2.0"
```

#### Suivi de progression

Les plateformes calculent automatiquement :

- Nombre d'issues ouvertes vs fermées
- Pourcentage de complétion
- Date d'échéance et temps restant

```bash
# GitHub - Voir l'état d'un milestone
gh api repos/:owner/:repo/milestones | jq '.[] | select(.title=="v2.0")'

# Afficher dans le navigateur
# https://github.com/owner/repo/milestone/1
```

> [!tip] Bonnes pratiques pour les milestones
> 
> - **Scope limité** : 20-50 issues max par milestone pour rester gérable
> - **Dates réalistes** : Planifier avec marge, pas trop ambitieux
> - **Review régulière** : Ajuster le contenu selon l'avancement
> - **Fermeture propre** : Déplacer les issues non terminées avant de fermer
> - **Documentation** : Créer des release notes à la fermeture

> [!warning] Erreurs fréquentes
> 
> - **Milestones fourre-tout** : Éviter de mettre toutes les issues dans "v2.0"
> - **Pas de triage** : Les issues doivent être évaluées avant assignation
> - **Deadlines ignorées** : Si la date est dépassée, ajuster ou déplacer les issues
> - **Oublier de fermer** : Fermer explicitement le milestone quand terminé

---

## Lien entre commits et issues

Une des fonctionnalités les plus puissantes de Git + GitHub/GitLab est la possibilité de lier automatiquement commits, branches et pull requests aux issues.

### Pourquoi lier commits et issues ?

- ✅ **Traçabilité** : Voir quel code résout quelle issue
- ✅ **Automatisation** : Fermer automatiquement les issues
- ✅ **Contexte** : Comprendre le "pourquoi" derrière un changement
- ✅ **Navigation** : Passer facilement du code à la discussion

### Mots-clés pour fermer les issues

Ces mots-clés dans un message de commit ou une PR ferment automatiquement l'issue :

|Mot-clé|Variantes|Exemple|
|---|---|---|
|`close`|`closes`, `closed`|`closes #42`|
|`fix`|`fixes`, `fixed`|`fixes #42`|
|`resolve`|`resolves`, `resolved`|`resolves #42`|

#### Syntaxe de base

```bash
# Format : Mot-clé #numéro
git commit -m "Fix login bug - fixes #42"

# Plusieurs issues
git commit -m "Refactor auth system - closes #42, closes #43, fixes #44"

# Issue dans un autre repo (même organisation)
git commit -m "Update API - fixes owner/other-repo#15"
```

#### Exemples pratiques

```bash
# Bug fix simple
git commit -m "Fix: Erreur 404 sur /dashboard
Corrige le routing pour la page dashboard.
Fixes #127"

# Feature complète
git commit -m "Feature: Ajouter export PDF
- Implémentation du service d'export
- Tests unitaires et d'intégration
- Documentation API

Closes #89"

# Fermeture multiple
git commit -m "Refactor: Restructurer le module auth
Cette refonte touche plusieurs aspects:
- Séparation des concerns (closes #45)
- Amélioration des tests (fixes #52)
- Documentation mise à jour (resolves #61)"

# Mention sans fermeture
git commit -m "WIP: Progression sur l'authentification OAuth
Travail en cours pour #73, pas encore prêt."
```

### Référencer sans fermer

Pour simplement **mentionner** une issue sans la fermer :

```bash
# Juste le numéro avec #
git commit -m "Amélioration des performances pour #42"

# Dans le corps du message
git commit -m "Optimisation de la DB

Voir la discussion dans #42 pour le contexte."

# Avec 'relates to' ou 'related to'
git commit -m "Add caching layer

Related to #42, améliore les performances."
```

### Syntaxe dans les Pull Requests

Les mêmes mots-clés fonctionnent dans les descriptions de PR :

```markdown
## Description
Cette PR implémente l'authentification OAuth avec Google.

## Issues liées
Closes #89
Fixes #92
Related to #85
```

> [!info] Différence commit vs PR
> 
> - **Commit** : Issue fermée quand le commit arrive dans la branche par défaut (main/master)
> - **PR** : Issue fermée quand la PR est mergée

### Nomenclature de branches

Créer des branches avec le numéro d'issue facilite le suivi :

```bash
# Format : type/issue-description
git checkout -b feature/42-oauth-authentication
git checkout -b fix/127-dashboard-404
git checkout -b refactor/89-auth-module

# Format alternatif : issue-type-description
git checkout -b 42-feature-oauth
git checkout -b 127-fix-dashboard

# Commits sur cette branche
git commit -m "Implement OAuth flow for #42"
git commit -m "Add tests for OAuth - part of #42"
```

### Workflow complet

```bash
# 1. Créer l'issue (ou elle existe déjà)
gh issue create --title "Bug: Login fails with special characters"
# Issue #153 créée

# 2. Créer une branche dédiée
git checkout -b fix/153-login-special-chars

# 3. Travailler et commiter avec référence
git add src/auth/login.js
git commit -m "Fix: Échapper les caractères spéciaux dans login

Le formulaire de login n'échappait pas correctement 
les caractères spéciaux, causant des erreurs SQL.

- Ajout de sanitization
- Tests avec caractères Unicode
- Validation côté serveur

Fixes #153"

# 4. Pousser et créer une PR
git push -u origin fix/153-login-special-chars

gh pr create \
  --title "Fix: Login with special characters" \
  --body "Resolves #153

Détails des changements:
- Sanitization des inputs
- Tests ajoutés
- Documentation mise à jour"

# 5. Après merge de la PR, l'issue #153 se ferme automatiquement
```

### Automatisation via PR

```markdown
## Description
Implémentation complète du système d'export PDF.

## Type de changement
- [ ] Bug fix
- [x] New feature
- [ ] Breaking change

## Issues
Closes #89
Closes #90
Related to #85

## Checklist
- [x] Tests ajoutés
- [x] Documentation mise à jour
- [x] Reviewed par @teammate
```

> [!tip] Meilleures pratiques de linkage
> 
> - **Un commit = une tâche** : Commit atomique lié à une issue spécifique
> - **Messages descriptifs** : Expliquer le "pourquoi", pas juste le "quoi"
> - **Fermer au bon moment** : Utiliser `fixes` seulement quand vraiment résolu
> - **Cross-référencer** : Mentionner les issues liées pour le contexte
> - **Branches nommées** : Inclure le numéro d'issue dans le nom de branche

> [!warning] Pièges à éviter
> 
> - **Fermeture prématurée** : Ne pas utiliser `fixes #42` si le travail n'est pas complet
> - **Références ambiguës** : "#42" seul peut être interprété comme une PR plutôt qu'une issue
> - **Oublier les références** : Le lien manuel a posteriori est fastidieux
> - **Numéros incorrects** : Vérifier le bon numéro avant de commiter

### Cas d'usage avancés

#### Fermer des issues depuis une autre repo

```bash
# Format: owner/repo#issue
git commit -m "Update API client - fixes myorg/frontend#24"
```

#### Lier plusieurs types d'objets

```bash
# Issue + PR
git commit -m "Implement feature X

Implements #42
Part of PR #156"
```

#### Utiliser dans les merge commits

```bash
# Lors d'un merge de PR
git merge --no-ff feature/89-oauth -m "Merge feature/89-oauth

Closes #89
Closes #92"
```

---

## Projects boards

Les project boards sont des tableaux Kanban intégrés pour visualiser et gérer le workflow. Ils offrent une vue d'ensemble du travail en cours et permettent une gestion agile.

### Types de boards

#### GitHub Projects

GitHub propose deux versions :

**Projects (classic)** :

- Tableaux Kanban simples
- Colonnes personnalisables
- Cards = Issues ou Notes

**Projects (beta/nouvelle version)** :

- Vues multiples (Board, Table, Roadmap)
- Champs personnalisés
- Automatisation avancée
- Grouping et filtering puissants

#### GitLab Boards

- Issue Boards natifs
- Multiple boards par projet
- Labels comme colonnes
- Workflow automatisé

### Créer un project board

#### GitHub - Via l'interface

1. Aller dans **Projects** → **New project**
2. Choisir un template :
    - **Team backlog** : Kanban classique
    - **Feature** : Suivi de features
    - **Bug triage** : Gestion de bugs
    - **Blank** : Vide à personnaliser
3. Personnaliser les colonnes

#### GitHub - Via CLI

```bash
# Lister les projects
gh project list --owner @me

# Créer un project (nécessite l'extension)
# gh extension install github/gh-projects
gh project create --title "Sprint 15" --owner @me
```

#### GitLab - Créer un board

1. **Issues** → **Boards** → **New board**
2. Nommer le board
3. Choisir le scope (labels, milestones, assignees)

### Structure classique d'un board

#### Colonnes Kanban standards

|Colonne|Description|Issues typiques|
|---|---|---|
|**📥 Backlog**|Issues à faire, non planifiées|Toutes les nouvelles issues|
|**📋 To Do**|Issues priorisées pour le sprint|Issues assignées, pas commencées|
|**🚧 In Progress**|En cours de développement|Issues avec branche active|
|**👀 In Review**|En review de code|PRs ouvertes|
|**✅ Done**|Terminées|Issues fermées, PRs mergées|

#### Colonnes avancées

```
📥 Backlog            → Issues non triées
🔍 Triage             → À évaluer et prioriser
📝 Planned            → Planifiées pour le prochain sprint
🚀 Ready              → Prêtes à démarrer
🏗️ In Progress        → Développement actif
⏸️ Blocked            → Bloquées par une dépendance
🧪 Testing            → En phase de test
👁️ Review             → En code review
✅ Done               → Terminées
🗄️ Archived           → Archivées
```

### Automatisation des boards

#### GitHub - Automations classiques

```yaml
# Dans Project settings → Workflows

# Auto-add issues
- Quand une issue est créée → Ajouter à "Backlog"

# Auto-move based on status
- Quand une issue est assignée → Déplacer vers "To Do"
- Quand une PR est créée → Déplacer vers "In Review"
- Quand une PR est mergée → Déplacer vers "Done"
- Quand une issue est fermée → Déplacer vers "Done"

# Auto-archive
- Quand une issue est dans "Done" depuis 7 jours → Archiver
```

#### GitHub Projects (nouvelle version) - Workflows

La nouvelle version offre des workflows plus puissants :

```yaml
# Exemple de workflow automatique

1. "Auto-add to project"
   Trigger: Item opened
   Action: Add to project
   
2. "Move to In Progress when assigned"
   Trigger: Item assigned
   Action: Set Status to "In Progress"
   
3. "Move to Done when closed"
   Trigger: Item closed
   Action: Set Status to "Done"
   
4. "Set priority based on labels"
   Trigger: Label added
   Conditions: Label is "priority-high"
   Action: Set Priority to "High"
```

#### GitLab - Workflow automatique

GitLab automatise via labels :

```yaml
# Configuration du board

Colonne "To Do"       → Label: status::todo
Colonne "In Progress" → Label: status::doing  
Colonne "Review"      → Label: status::review
Colonne "Done"        → Label: status::done

# Déplacer une issue = changer son label automatiquement
```

### Champs personnalisés (GitHub Projects v2)

Les nouveaux projects permettent d'ajouter des champs :

#### Types de champs disponibles

|Type|Utilisation|
|---|---|
|**Text**|Notes, descriptions courtes|
|**Number**|Story points, estimation|
|**Date**|Due dates, start dates|
|**Single select**|Priorité, statut, type|
|**Iteration**|Sprints, cycles|

#### Exemple de configuration

```
Champs personnalisés :
- Status (Single select): Backlog, Todo, In Progress, Review, Done
- Priority (Single select): Critical, High, Medium, Low
- Size (Number): 1, 2, 3, 5, 8 (story points)
- Sprint (Iteration): Sprint 1, Sprint 2, Sprint 3...
- Due Date (Date): Deadline
- Assignee: Personne responsable
```

### Vues multiples

#### Board view (Kanban)

```
La vue par défaut, colonnes avec cards déplaçables.
Idéale pour : visualiser le workflow quotidien
```

#### Table view

```
Vue tableau avec toutes les issues et leurs champs.
Idéale pour : vue d'ensemble, tri et filtrage massif
```

#### Roadmap view

```
Timeline Gantt avec les dates.
Idéale pour : planification long terme, dépendances
```

### Filtrage et grouping

```bash
# Exemples de filtres

# Par assigné
assignee:@me

# Par label
label:"bug" label:"priority-high"

# Par statut
status:"In Progress"

# Par milestone
milestone:"v2.0"

# Combinaisons
is:issue is:open label:"bug" assignee:@me
```

#### Grouping

Les nouvelles Projects permettent de grouper par :

- Statut
- Assigné
- Labels
- Milestones
- Champs personnalisés

```
Exemple : Grouper par Priority
├── Critical
│   ├── Issue #42
│   └── Issue #89
├── High
│   ├── Issue #56
│   └── Issue #127
└── Medium
    └── Issue #234
```

### Workflow d'équipe typique

#### Sprint planning

```bash
# 1. Créer le milestone pour le sprint
gh api repos/:owner/:repo/milestones --method POST \
  --field title="Sprint 15" \
  --field due_on="2024-02-15T00:00:00Z"

# 2. Trier le backlog dans le project board
# Drag & drop des issues depuis "Backlog" vers "To Do"

# 3. Assigner les issues
gh issue edit 42 --assignee "@teammate1"
gh issue edit 43 --assignee "@teammate2"

# 4. Définir le milestone
gh issue edit 42 --milestone "Sprint 15"
```

#### Daily standup

```
Utiliser le board pour :
1. Voir qui travaille sur quoi (colonne "In Progress")
2. Identifier les blocages (colonne "Blocked")
3. Reviews en attente (colonne "In Review")
4. Progression générale (nombre dans "Done")
```

#### Sprint review

```
1. Filtrer les issues par milestone "Sprint 15"
2. Vérifier la complétion (issues dans "Done")
3. Déplacer les issues non terminées au prochain sprint
4. Fermer le milestone
```

#### Retrospective

```
Utiliser le board pour analyser :
- Vélocité : Combien d'issues complétées ?
- Blocages : Quelles issues sont restées bloquées ?
- Workflow : Les colonnes reflètent-elles la réalité ?
- Automatisation : Quelles tâches manuelles automatiser ?
```

### Bonnes pratiques pour les boards

> [!tip] Organisation efficace
> 
> - **WIP limits** : Limiter le nombre d'issues "In Progress" (ex: 2 par personne)
> - **Mise à jour régulière** : Déplacer les cards quotidiennement
> - **Archivage** : Archiver les issues anciennes pour garder le board lisible
> - **Templates** : Créer des boards templates pour les sprints récurrents
> - **Cohérence** : Toute l'équipe doit suivre le même workflow

> [!tip] Utilisation des labels sur les boards
> 
> - **Couleurs visuelles** : Les labels ajoutent des indicateurs visuels rapides
> - **Filtrage rapide** : Afficher uniquement les bugs ou features
> - **Priorité visible** : Labels de priorité immédiatement identifiables
> 
> ```bash
> # Filtrer le board pour voir seulement les bugs critiques
> label:"bug" label:"priority-critical"
> ```

> [!warning] Erreurs à éviter
> 
> - **Board abandonné** : Si non mis à jour, il perd toute valeur
> - **Trop de colonnes** : 5-7 colonnes maximum, sinon illisible
> - **Pas de définition claire** : Chaque colonne doit avoir des critères précis
> - **Micro-management** : Le board sert à visualiser, pas à contrôler chaque minute
> - **Issues orphelines** : Toutes les issues actives doivent être sur le board

### Intégration board + CLI

#### Voir l'état du board via CLI

```bash
# GitHub - Lister les issues d'un project
gh project item-list 1 --owner @me

# Avec formatage JSON pour parsing
gh project item-list 1 --owner @me --format json | jq

# Ajouter une issue à un project
gh project item-add 1 --owner @me --url https://github.com/owner/repo/issues/42

# GitLab - Lister les issues d'un board
glab issue list --milestone "Sprint 15"
```

#### Automatiser via scripts

```bash
#!/bin/bash
# Script pour déplacer toutes les issues assignées vers "In Progress"

# Récupérer les issues assignées à moi
ISSUES=$(gh issue list --assignee "@me" --state open --json number --jq '.[].number')

for issue in $ISSUES; do
  echo "Traitement de l'issue #$issue"
  # Ajouter un label pour automatiser le mouvement sur le board
  gh issue edit $issue --add-label "status:in-progress"
done
```

### Cas d'usage avancés

#### Board multi-repos

GitHub Projects (v2) peut agréger des issues de plusieurs repositories :

```
Project "Engineering Q1"
├── Issues de "frontend" repo
├── Issues de "backend" repo
├── Issues de "mobile" repo
└── Issues de "docs" repo

Permet une vue unifiée du travail cross-repo
```

#### Board privé vs public

- **Board privé** : Visible uniquement par l'équipe, pour le travail interne
- **Board public** : Visible par tous, pour la transparence open-source

```bash
# Définir la visibilité lors de la création
# Dans les settings du project sur GitHub
```

#### Synchronisation avec outils externes

Les boards peuvent être synchronisés avec :

- **Jira** : Via GitHub/GitLab apps
- **Trello** : Via Zapier ou intégrations
- **Slack** : Notifications automatiques
- **Discord** : Webhooks sur changements

```yaml
# Exemple de webhook Slack
# Dans Settings → Webhooks

URL: https://hooks.slack.com/services/YOUR/WEBHOOK/URL
Triggers:
  - Issues opened
  - Issues closed
  - Pull request opened
  - Pull request merged
```

### Métriques et reporting

#### Vélocité d'équipe

```bash
# Compter les issues fermées dans le sprint
gh issue list \
  --state closed \
  --milestone "Sprint 15" \
  --json number \
  | jq 'length'

# Compter les story points complétés
# (nécessite parsing des champs personnalisés)
```

#### Cycle time

```
Temps moyen entre :
- Issue créée → Issue dans "In Progress"
- Issue dans "In Progress" → Issue dans "Done"

Utiliser les timestamps des events GitHub/GitLab
```

#### Burndown chart

```
Créer un burndown chart en trackant quotidiennement :
- Nombre d'issues restantes dans le sprint
- Nombre d'issues dans "Done"
- Comparaison avec la vélocité attendue
```

### Templates de boards

#### Board de features

```
Colonnes :
📝 Proposals       → Idées de features
🔍 Evaluation      → En évaluation (faisabilité, impact)
✅ Approved        → Approuvées pour développement
🏗️ In Development  → En cours
🧪 Testing         → En phase de test
🚀 Deployed        → Déployées en production
```

#### Board de bugs

```
Colonnes :
🐛 Reported        → Bugs signalés
🔍 Triage          → À évaluer (gravité, priorité)
✅ Confirmed       → Confirmés et reproductibles
🔧 Fixing          → En cours de correction
✅ Fixed           → Corrigés (en attente de déploiement)
🚀 Deployed        → Déployés en production
```

#### Board de releases

```
Colonnes :
📋 Planned         → Features planifiées pour la release
🏗️ Development     → En développement
✅ Feature Complete → Développement terminé
🧪 QA Testing      → En test qualité
🐛 Bug Fixing      → Correction de bugs pré-release
🚀 Ready to Ship   → Prête pour déploiement
✅ Released        → Déployée en production
```

### Raccourcis et astuces

#### Raccourcis clavier GitHub

```
/ : Focus sur la barre de recherche
c : Créer une nouvelle issue
ctrl/cmd + k : Command palette
t : Ouvrir le file finder
```

#### Mentions rapides

```markdown
# Dans les issues et PR
@username           → Mention une personne
#42                 → Référence l'issue #42
owner/repo#42       → Référence une issue d'un autre repo
GH-42               → Alternative pour référencer
```

#### Markdown avancé dans les issues

````markdown
## Checklist
- [x] Tâche complétée
- [ ] Tâche en cours
- [ ] Tâche à faire

## Tables
| Feature | Status | Owner |
|---------|--------|-------|
| Auth    | ✅ Done | @alice |
| API     | 🚧 WIP  | @bob   |

## Code
```python
def example():
    return "Code avec syntax highlighting"
````

## Quotes

> Citation importante ou note

## Collapsed sections

<details> <summary>Détails techniques</summary>

Contenu caché par défaut

</details>

## Emojis

:bug: :sparkles: :rocket: :fire:

````

> [!example] Workflow complet d'une feature
> ```bash
> # 1. Créer l'issue
> gh issue create \
>   --title "Feature: Export des données en CSV" \
>   --body "Permettre aux utilisateurs d'exporter leurs données" \
>   --label "enhancement,priority-medium" \
>   --milestone "Sprint 15"
> 
> # Issue #156 créée
> 
> # 2. Ajouter au project board (automatique si configuré)
> # Sinon manuellement :
> gh project item-add 1 --owner @me --url https://github.com/owner/repo/issues/156
> 
> # 3. Assigner et déplacer vers "To Do"
> gh issue edit 156 --assignee "@me"
> gh issue edit 156 --add-label "status:todo"
> 
> # 4. Créer la branche
> git checkout -b feature/156-csv-export
> 
> # 5. Développer et commiter
> git commit -m "Add CSV export service - part of #156"
> 
> # 6. Marquer comme "In Progress"
> gh issue edit 156 --remove-label "status:todo" --add-label "status:in-progress"
> 
> # 7. Créer la PR
> gh pr create \
>   --title "Feature: CSV Export" \
>   --body "Implements #156" \
>   --label "status:review"
> 
> # 8. Après merge, l'issue se ferme automatiquement
> # et est déplacée vers "Done" sur le board
> ```

### Intégration continue et boards

#### GitHub Actions et Projects

```yaml
# .github/workflows/project-automation.yml
name: Project Automation

on:
  issues:
    types: [opened, assigned, closed]
  pull_request:
    types: [opened, closed]

jobs:
  update-project:
    runs-on: ubuntu-latest
    steps:
      - name: Add issue to project
        if: github.event.action == 'opened'
        uses: actions/add-to-project@v0.5.0
        with:
          project-url: https://github.com/users/USERNAME/projects/1
          github-token: ${{ secrets.PAT }}
      
      - name: Move to In Progress
        if: github.event.action == 'assigned'
        run: |
          # Script pour déplacer l'item dans le project
````

#### GitLab CI et Boards

```yaml
# .gitlab-ci.yml
update-board:
  stage: deploy
  script:
    - |
      # Mettre à jour les labels pour déplacer sur le board
      curl --request PUT \
        --header "PRIVATE-TOKEN: $CI_JOB_TOKEN" \
        --data "labels=status::deployed" \
        "https://gitlab.com/api/v4/projects/$CI_PROJECT_ID/issues/$ISSUE_IID"
  only:
    - main
```

---

## 🎯 Résumé des commandes essentielles

### Issues

```bash
# Créer
gh issue create --title "Titre" --body "Description"

# Lister
gh issue list --state open --label "bug"

# Voir
gh issue view 42

# Éditer
gh issue edit 42 --add-label "priority-high"

# Fermer
gh issue close 42 --comment "Résolu"

# Commenter
gh issue comment 42 --body "Commentaire"
```

### Labels

```bash
# Lister
gh label list

# Créer
gh label create "priority-high" --color "d93f0b"

# Éditer
gh label edit "bug" --name "type:bug"

# Supprimer
gh label delete "old-label"
```

### Liens commits-issues

```bash
# Dans les commits
git commit -m "Fix bug - fixes #42"
git commit -m "WIP for #42"

# Dans les PR
gh pr create --body "Closes #42"
```

### Projects

```bash
# Lister
gh project list

# Ajouter une issue
gh project item-add 1 --url https://github.com/owner/repo/issues/42

# Lister les items
gh project item-list 1
```

---

## 💡 Points clés à retenir

1. **Issues = Communication centralisée** : Tout discuter au même endroit que le code
2. **Labels = Organisation** : Système de catégorisation essentiel pour les grands projets
3. **Milestones = Planification** : Regrouper le travail par objectifs ou versions
4. **Liens automatiques** : Utiliser `fixes #42` pour automatiser la fermeture
5. **Boards = Visualisation** : Vue d'ensemble du workflow et de l'avancement
6. **Automatisation** : Configurer les workflows pour réduire le travail manuel
7. **Cohérence d'équipe** : Définir et suivre des conventions communes

> [!tip] La règle d'or **Si ce n'est pas dans une issue, ça n'existe pas.** Toute décision, bug, ou feature doit être documentée dans une issue pour assurer la traçabilité et la collaboration efficace.