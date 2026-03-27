

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

## 🎯 Introduction à Git Flow

**Git Flow** est un modèle de workflow créé par Vincent Driessen qui définit une structure stricte de branches pour organiser le développement d'un projet. C'est une méthodologie complète qui régit comment et quand créer des branches, fusionner du code et publier des releases.

> [!info] Pourquoi utiliser Git Flow ?
> 
> - **Organisation claire** : structure prédéfinie qui élimine l'ambiguïté
> - **Développement parallèle** : plusieurs features peuvent être développées simultanément
> - **Releases planifiées** : cycle de release bien défini avec phases de stabilisation
> - **Hotfixes rapides** : possibilité de corriger la production sans perturber le développement
> - **Traçabilité** : historique clair des features, releases et corrections

> [!warning] Quand Git Flow n'est PAS adapté
> 
> - Projets avec déploiement continu (CD)
> - Petites équipes avec livraisons très fréquentes
> - Applications web déployées plusieurs fois par jour
> - Projets nécessitant une grande agilité
> 
> Dans ces cas, préférez GitHub Flow ou GitLab Flow (autres workflows).

---

## 🌳 Architecture des branches

### 🏛️ Branches principales

Git Flow repose sur **deux branches principales infinies** qui existent pendant toute la durée de vie du projet.

#### 1️⃣ La branche `main` (ou `master`)

**Rôle** : Représente l'état de production stable et déployable.

> [!info] Caractéristiques de `main`
> 
> - Contient **uniquement du code prêt pour la production**
> - Chaque commit sur `main` représente une **nouvelle version en production**
> - **Toujours stable** : ne doit jamais contenir de code non testé
> - Les merges vers `main` créent automatiquement un **tag de version** (v1.0.0, v1.1.0, etc.)

```bash
# La branche main ne reçoit des commits QUE via merge
# Jamais de commit direct sur main !

# Exemple de ce qui se passe lors d'une release
git checkout main
git merge --no-ff release/1.2.0
git tag -a v1.2.0 -m "Version 1.2.0"
git push origin main --tags
```

#### 2️⃣ La branche `develop`

**Rôle** : Branche d'intégration pour le développement en cours.

> [!info] Caractéristiques de `develop`
> 
> - Point de départ de toutes les **branches de feature**
> - Reflète l'état du **prochain release**
> - Intègre toutes les features complétées
> - Doit rester fonctionnelle mais peut contenir des features non finalisées
> - C'est la branche par défaut pour les développeurs

```bash
# Initialisation d'un projet avec Git Flow
git checkout -b develop main

# develop devient la branche principale de travail
git push -u origin develop
```

> [!example] Schéma conceptuel
> 
> ```
> main     : ---v1.0.0--------v1.1.0--------v2.0.0--->
>                  ↑             ↑             ↑
> develop  : ------•---F1---F2--•---F3---F4---•------->
>                merge        merge         merge
> ```

---

### 🔧 Branches de support

Les branches de support sont **temporaires** et servent des objectifs spécifiques. Elles sont supprimées après leur fusion.

#### 1️⃣ Branches `feature/*`

**Rôle** : Développer de nouvelles fonctionnalités.

|Caractéristique|Détail|
|---|---|
|**Branche depuis**|`develop`|
|**Fusionne vers**|`develop`|
|**Convention de nommage**|`feature/nom-de-la-fonctionnalite`|
|**Durée de vie**|De quelques heures à plusieurs semaines|
|**Visibilité**|Peut rester locale ou être poussée sur origin|

> [!tip] Cycle de vie d'une feature
> 
> 1. **Création** depuis `develop`
> 2. **Développement** avec commits réguliers
> 3. **Tests** locaux et validation
> 4. **Merge** dans `develop`
> 5. **Suppression** de la branche

```bash
# Créer une nouvelle feature
git checkout develop
git checkout -b feature/authentification-oauth

# Travailler sur la feature
git add .
git commit -m "Ajoute le provider OAuth Google"
git commit -m "Implémente le callback OAuth"
git commit -m "Ajoute les tests d'intégration OAuth"

# Mettre à jour avec develop si nécessaire (longue feature)
git checkout develop
git pull origin develop
git checkout feature/authentification-oauth
git merge develop
# Ou avec rebase pour un historique plus propre
git rebase develop

# Finaliser la feature : merge dans develop
git checkout develop
git merge --no-ff feature/authentification-oauth

# Supprimer la branche locale
git branch -d feature/authentification-oauth

# Si poussée sur origin, supprimer aussi
git push origin --delete feature/authentification-oauth
```

> [!warning] Attention avec `--no-ff` Le flag `--no-ff` (no fast-forward) crée **toujours un commit de merge**, même si le merge pourrait être fast-forward. C'est important dans Git Flow car :
> 
> - Préserve l'historique de la feature comme une entité distincte
> - Facilite l'identification des features dans l'historique
> - Permet de revenir en arrière sur toute une feature si nécessaire

#### 2️⃣ Branches `release/*`

**Rôle** : Préparer une nouvelle version de production.

|Caractéristique|Détail|
|---|---|
|**Branche depuis**|`develop`|
|**Fusionne vers**|`main` ET `develop`|
|**Convention de nommage**|`release/X.Y.Z` (semantic versioning)|
|**Durée de vie**|Quelques jours à quelques semaines|
|**Contenu autorisé**|Corrections de bugs, ajustements mineurs, metadata|

> [!info] Qu'est-ce qu'une branche release ? Une branche release est un **état figé** du code qui va être déployé en production. Elle permet de :
> 
> - **Stabiliser** le code avant la mise en production
> - **Corriger les derniers bugs** sans bloquer `develop`
> - **Préparer les métadonnées** (numéro de version, changelog, etc.)
> - **Tester** de manière intensive dans un environnement de staging
> 
> Pendant qu'une release est en préparation, `develop` continue d'avancer avec de nouvelles features.

```bash
# Créer une branche release depuis develop
git checkout develop
git checkout -b release/1.2.0

# Mettre à jour le numéro de version dans le projet
# (package.json, version.txt, etc.)
echo "1.2.0" > VERSION
git commit -am "Bump version to 1.2.0"

# Corrections de bugs trouvés en phase de test
git commit -am "Corrige le bug #142 dans le formulaire"
git commit -am "Ajuste les marges sur mobile"

# Une fois la release validée, merger dans main
git checkout main
git merge --no-ff release/1.2.0

# Créer le tag de version
git tag -a v1.2.0 -m "Release version 1.2.0"

# Reporter les corrections dans develop
git checkout develop
git merge --no-ff release/1.2.0

# Supprimer la branche release
git branch -d release/1.2.0

# Pousser tout sur origin
git push origin main develop --tags
```

> [!warning] Règle d'or des releases **AUCUNE nouvelle feature** ne doit être ajoutée dans une branche release. Seulement :
> 
> - Corrections de bugs
> - Ajustements de configuration
> - Mise à jour de documentation
> - Modifications de métadonnées (version, changelog)
> 
> Si une feature importante est nécessaire, retournez sur `develop` et reportez la release.

#### 3️⃣ Branches `hotfix/*`

**Rôle** : Corriger rapidement un bug critique en production.

|Caractéristique|Détail|
|---|---|
|**Branche depuis**|`main`|
|**Fusionne vers**|`main` ET `develop` (ou release en cours)|
|**Convention de nommage**|`hotfix/X.Y.Z` ou `hotfix/description`|
|**Durée de vie**|Quelques heures à quelques jours|
|**Urgence**|Haute - contourne le cycle normal|

> [!info] Pourquoi les hotfixes sont spéciaux Les hotfixes permettent de :
> 
> - **Corriger la production immédiatement** sans attendre la prochaine release
> - **Contourner** la branche develop si elle contient du code non prêt
> - **Minimiser le risque** en ne touchant que le code nécessaire
> - **Incrémenter** uniquement le numéro de patch (1.2.3 → 1.2.4)

```bash
# Un bug critique est découvert en production (v1.2.3)
git checkout main
git checkout -b hotfix/1.2.4

# Corriger le bug rapidement
git commit -am "Corrige la faille de sécurité CVE-2024-1234"
git commit -am "Ajoute des tests pour prévenir la régression"

# Mettre à jour le numéro de version
echo "1.2.4" > VERSION
git commit -am "Bump version to 1.2.4"

# Merger dans main et créer le tag
git checkout main
git merge --no-ff hotfix/1.2.4
git tag -a v1.2.4 -m "Hotfix 1.2.4: Security patch"

# Reporter le fix dans develop
git checkout develop
git merge --no-ff hotfix/1.2.4

# Si une release est en cours, merger dans la release au lieu de develop
# git checkout release/1.3.0
# git merge --no-ff hotfix/1.2.4

# Supprimer la branche hotfix
git branch -d hotfix/1.2.4

# Pousser immédiatement en production
git push origin main develop --tags
```

> [!tip] Gestion des conflits avec les releases Si une branche `release/*` existe au moment du hotfix :
> 
> ```bash
> # Merger le hotfix dans la release au lieu de develop
> git checkout release/1.3.0
> git merge --no-ff hotfix/1.2.4
> ```
> 
> Le fix sera automatiquement inclus dans develop quand la release sera mergée.

---

## 🔄 Cycle de vie complet

Voici un exemple de cycle de vie complet d'un projet utilisant Git Flow.

### 📋 Scénario : Développement de la version 1.2.0

```bash
# === ÉTAT INITIAL ===
# main: v1.1.0 (en production)
# develop: avance sur les features pour v1.2.0

# === PHASE 1 : Développement de features ===

# Feature A : Nouveau dashboard
git checkout develop
git checkout -b feature/nouveau-dashboard
# ... développement ...
git checkout develop
git merge --no-ff feature/nouveau-dashboard
git branch -d feature/nouveau-dashboard

# Feature B : Export PDF (développée en parallèle)
git checkout develop
git checkout -b feature/export-pdf
# ... développement ...
git checkout develop
git merge --no-ff feature/export-pdf
git branch -d feature/export-pdf

# Feature C : Authentification 2FA
git checkout develop
git checkout -b feature/authentification-2fa
# ... développement ...
git checkout develop
git merge --no-ff feature/authentification-2fa
git branch -d feature/authentification-2fa

# === PHASE 2 : Préparation de la release ===

# Créer la branche release
git checkout develop
git checkout -b release/1.2.0
echo "1.2.0" > VERSION
git commit -am "Bump version to 1.2.0"

# Tests intensifs et corrections de bugs
git commit -am "Corrige le bug d'affichage sur Safari"
git commit -am "Ajuste les performances du dashboard"
git commit -am "Met à jour le CHANGELOG.md"

# Pendant ce temps, develop continue avec de nouvelles features pour 1.3.0
git checkout develop
git checkout -b feature/notifications-push
# ... développement continue sur develop ...

# === PHASE 3 : Déploiement de la release ===

# Merger dans main
git checkout main
git merge --no-ff release/1.2.0
git tag -a v1.2.0 -m "Release 1.2.0: Dashboard, Export PDF, 2FA"

# Reporter dans develop
git checkout develop
git merge --no-ff release/1.2.0

# Nettoyage
git branch -d release/1.2.0
git push origin main develop --tags

# === PHASE 4 : Hotfix en production ===

# Un bug critique est découvert 2 jours après
git checkout main
git checkout -b hotfix/1.2.1

git commit -am "Corrige le bug critique dans l'export PDF"
echo "1.2.1" > VERSION
git commit -am "Bump version to 1.2.1"

# Merger dans main
git checkout main
git merge --no-ff hotfix/1.2.1
git tag -a v1.2.1 -m "Hotfix 1.2.1: PDF export fix"

# Reporter dans develop
git checkout develop
git merge --no-ff hotfix/1.2.1

# Nettoyage
git branch -d hotfix/1.2.1
git push origin main develop --tags
```

> [!example] Visualisation du cycle complet
> 
> ```
> main      : ---v1.1.0-----------------v1.2.0---v1.2.1--->
>                    ↑                     ↑       ↑
>                    |                     |       hotfix/1.2.1
>                    |                     |
> release   :        |         release/1.2.0
>                    |              ↑
> develop   : -------•---F1---F2---•---F3---F4------------>
>                  init    |   |       |   |
>                       features  (continue pendant release)
> ```

---

## ⚙️ Commandes Git Flow

Git Flow dispose d'une **extension Git officielle** qui simplifie les commandes.

### Installation de git-flow

```bash
# macOS (Homebrew)
brew install git-flow

# Linux (Ubuntu/Debian)
apt-get install git-flow

# Linux (Fedora)
yum install gitflow

# Windows (Git Bash)
# Télécharger depuis https://github.com/nvie/gitflow/wiki/Installation
```

### Initialisation

```bash
# Initialiser git-flow dans un dépôt existant
git flow init

# Répondre aux questions (accepter les valeurs par défaut)
# Branch name for production releases: [main]
# Branch name for "next release" development: [develop]
# Feature branches prefix: [feature/]
# Release branches prefix: [release/]
# Hotfix branches prefix: [hotfix/]
# Support branches prefix: [support/]
# Version tag prefix: []
```

### Commandes Features

```bash
# Créer et basculer sur une nouvelle feature
git flow feature start nom-de-la-feature
# Équivalent à:
# git checkout develop
# git checkout -b feature/nom-de-la-feature

# Publier la feature sur origin
git flow feature publish nom-de-la-feature
# Équivalent à:
# git push -u origin feature/nom-de-la-feature

# Récupérer une feature publiée par quelqu'un d'autre
git flow feature track nom-de-la-feature
# Équivalent à:
# git checkout -b feature/nom-de-la-feature origin/feature/nom-de-la-feature

# Finaliser la feature (merge + suppression)
git flow feature finish nom-de-la-feature
# Équivalent à:
# git checkout develop
# git merge --no-ff feature/nom-de-la-feature
# git branch -d feature/nom-de-la-feature
```

### Commandes Releases

```bash
# Créer une nouvelle release
git flow release start 1.2.0
# Équivalent à:
# git checkout develop
# git checkout -b release/1.2.0

# Publier la release pour tests collaboratifs
git flow release publish 1.2.0
# Équivalent à:
# git push -u origin release/1.2.0

# Finaliser la release
git flow release finish 1.2.0
# Équivalent à:
# git checkout main
# git merge --no-ff release/1.2.0
# git tag -a v1.2.0
# git checkout develop
# git merge --no-ff release/1.2.0
# git branch -d release/1.2.0

# Note : finish ouvre un éditeur pour le message du tag
```

### Commandes Hotfixes

```bash
# Créer un hotfix depuis main
git flow hotfix start 1.2.1
# Équivalent à:
# git checkout main
# git checkout -b hotfix/1.2.1

# Finaliser le hotfix
git flow hotfix finish 1.2.1
# Équivalent à:
# git checkout main
# git merge --no-ff hotfix/1.2.1
# git tag -a v1.2.1
# git checkout develop
# git merge --no-ff hotfix/1.2.1
# git branch -d hotfix/1.2.1
```

> [!tip] Extension git-flow vs commandes manuelles L'extension `git-flow` est pratique mais **optionnelle**. Elle :
> 
> - Simplifie les commandes répétitives
> - Réduit les erreurs humaines
> - Applique automatiquement les conventions
> 
> Cependant, comprendre les commandes Git sous-jacentes est **essentiel** pour :
> 
> - Déboguer les problèmes
> - Personnaliser le workflow
> - Travailler sans l'extension installée

---

## ⚠️ Pièges courants

### 1. Commit direct sur `main` ou `develop`

> [!warning] Erreur fréquente
> 
> ```bash
> # ❌ MAUVAIS : commit direct sur develop
> git checkout develop
> git commit -am "Corrige un petit bug"
> ```
> 
> **Pourquoi c'est problématique** :
> 
> - Contourne le processus de review
> - Pas de traçabilité de la feature
> - Difficile à revenir en arrière
> 
> **Solution** :
> 
> ```bash
> # ✅ BON : toujours passer par une branche
> git checkout develop
> git checkout -b feature/correction-bug-mineur
> git commit -am "Corrige un petit bug"
> git checkout develop
> git merge --no-ff feature/correction-bug-mineur
> git branch -d feature/correction-bug-mineur
> ```

### 2. Ajouter des features dans une release

> [!warning] Erreur fréquente
> 
> ```bash
> # ❌ MAUVAIS : ajouter une feature en phase de release
> git checkout release/1.2.0
> git commit -am "Ajoute le mode sombre (nouvelle feature)"
> ```
> 
> **Pourquoi c'est problématique** :
> 
> - Rallonge indéfiniment la phase de release
> - Introduit de l'instabilité
> - Dégrade la qualité du code
> 
> **Solution** :
> 
> - Reporter la feature à la prochaine release
> - Ou annuler la release actuelle et repartir de `develop` avec la nouvelle feature

### 3. Oublier de merger le hotfix dans develop

> [!warning] Erreur fréquente
> 
> ```bash
> # ❌ MAUVAIS : oublier develop après le hotfix
> git checkout main
> git merge --no-ff hotfix/1.2.1
> git tag -a v1.2.1
> # ... et c'est tout
> ```
> 
> **Conséquence** : Le bug réapparaît dans la prochaine release car develop ne contient pas le fix.
> 
> **Solution** :
> 
> ```bash
> # ✅ BON : toujours merger aussi dans develop
> git checkout develop
> git merge --no-ff hotfix/1.2.1
> ```

### 4. Branches feature de trop longue durée

> [!warning] Problème Des features qui durent des semaines ou des mois créent :
> 
> - Des conflits de merge massifs
> - Une divergence importante avec `develop`
> - Des difficultés d'intégration
> 
> **Solution** :
> 
> - Découper les features en sous-features plus petites
> - Merger fréquemment les petites parties
> - Synchroniser régulièrement avec `develop` :
> 
> ```bash
> git checkout feature/grosse-feature
> git merge develop  # ou git rebase develop
> ```

### 5. Ne pas tester avant de merger une feature

> [!warning] Problème Merger du code non testé dans `develop` introduit de l'instabilité pour toute l'équipe.
> 
> **Solution** :
> 
> - Toujours tester localement avant de merger
> - Utiliser la CI/CD sur les branches de feature
> - Demander une review de code (pull request)

---

## ✅ Bonnes pratiques

### 1. Convention de nommage cohérente

```bash
# Features : verbe à l'infinitif + objet
feature/ajouter-authentification-2fa
feature/ameliorer-performances-dashboard
feature/corriger-bug-export-pdf

# Releases : semantic versioning strict
release/1.2.0
release/2.0.0
release/1.2.1

# Hotfixes : version patch ou description urgente
hotfix/1.2.4
hotfix/faille-securite-critique
```

### 2. Messages de commit clairs

```bash
# ✅ BON : message descriptif et contextualisé
git commit -m "feature(auth): Ajoute l'authentification OAuth Google

- Implémente le flow OAuth 2.0
- Configure les credentials dans l'environnement
- Ajoute les tests d'intégration
- Met à jour la documentation

Closes #123"

# ❌ MAUVAIS : message vague
git commit -m "fix bug"
git commit -m "update"
git commit -m "wip"
```

### 3. Utiliser `--no-ff` systématiquement

```bash
# Toujours merger avec --no-ff pour préserver l'historique
git merge --no-ff feature/ma-feature

# Configurer --no-ff par défaut
git config --global merge.ff false
```

### 4. Protéger les branches principales

```bash
# Sur GitHub/GitLab, configurer les branch protection rules :
# - main : aucun push direct, require pull request + reviews
# - develop : aucun push direct, require pull request
```

### 5. Automatiser avec CI/CD

```yaml
# Exemple : déclencher des actions selon la branche
# .github/workflows/ci.yml

on:
  push:
    branches:
      - develop
      - 'feature/**'
      - 'release/**'
      - 'hotfix/**'

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - run: npm test

  deploy-staging:
    if: startsWith(github.ref, 'refs/heads/release/')
    runs-on: ubuntu-latest
    steps:
      - run: deploy-to-staging.sh

  deploy-production:
    if: github.ref == 'refs/heads/main'
    runs-on: ubuntu-latest
    steps:
      - run: deploy-to-production.sh
```

### 6. Documenter les releases

```bash
# Maintenir un CHANGELOG.md selon Keep a Changelog
# https://keepachangelog.com/

# CHANGELOG.md
## [1.2.0] - 2024-12-15

### Added
- Nouveau tableau de bord avec widgets personnalisables
- Export PDF des rapports
- Authentification à deux facteurs (2FA)

### Changed
- Amélioration des performances de 40%
- Nouvelle interface utilisateur

### Fixed
- Correction du bug d'affichage sur Safari
- Correction de la faille de sécurité CVE-2024-1234

### Security
- Mise à jour des dépendances avec vulnérabilités
```

### 7. Synchroniser régulièrement

```bash
# Mettre à jour develop et main régulièrement
git checkout develop
git pull origin develop

git checkout main
git pull origin main

# Synchroniser sa feature avec develop
git checkout feature/ma-feature
git merge develop
# Résoudre les conflits si nécessaire
```

---

## 💡 Astuces

### Alias Git pour Git Flow

```bash
# Ajouter dans ~/.gitconfig
[alias]
    # Raccourcis features
    fs = flow feature start
    ff = flow feature finish
    fp = flow feature publish

    # Raccourcis releases
    rs = flow release start
    rf = flow release finish
    rp = flow release publish

    # Raccourcis hotfixes
    hs = flow hotfix start
    hf = flow hotfix finish

    # Visualiser l'arbre Git Flow
    lg = log --graph --oneline --all --decorate
    lga = log --graph --all --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --abbrev-commit

# Utilisation
git fs ma-nouvelle-feature
git ff ma-nouvelle-feature
```

### Script de démarrage de projet Git Flow

```bash
#!/bin/bash
# init-gitflow.sh

# Initialiser le dépôt
git init
git commit --allow-empty -m "Initial commit"

# Créer develop
git checkout -b develop

# Initialiser git-flow avec valeurs par défaut
git flow init -d

# Premier commit sur develop
echo "# Mon Projet" > README.md
git add README.md
git commit -m "docs: Ajoute le README"

# Pousser sur origin
git remote add origin $1  # URL du dépôt distant
git push -u origin main develop

echo "✅ Git Flow initialisé avec succès!"
echo "📦 Branches : main (production) et develop (intégration)"
echo "🚀 Vous pouvez commencer avec : git flow feature start ma-feature"
```

### Vérifier l'état de Git Flow

```bash
# Afficher toutes les branches avec leur type
git branch -a | grep -E "feature/|release/|hotfix/"

# Compter les branches de chaque type
echo "Features: $(git branch -a | grep -c feature/)"
echo "Releases: $(git branch -a | grep -c release/)"
echo "Hotfixes: $(git branch -a | grep -c hotfix/)"

# Voir les branches non mergées dans develop
git branch --no-merged develop

# Voir les branches déjà mergées (à supprimer)
git branch --merged develop | grep -E "feature/"
```

### Template de Pull Request pour Git Flow

```markdown
<!-- .github/pull_request_template.md -->

## Type de changement
- [ ] Feature (branche feature/*)
- [ ] Release (branche release/*)
- [ ] Hotfix (branche hotfix/*)

## Description
<!-- Décrire les changements apportés -->

## Checklist
- [ ] Le code compile sans erreur
- [ ] Les tests passent localement
- [ ] Les tests couvrent les nouveaux changements
- [ ] La documentation est à jour
- [ ] Le CHANGELOG.md est mis à jour (pour release/hotfix)
- [ ] Le numéro de version est incrémenté (pour release/hotfix)

## Lien vers l'issue
Closes #

## Environnement de test
<!-- Comment tester ce changement -->

## Screenshots
<!-- Si applicable -->
```

### Récupération après erreur

```bash
# Annuler un merge non désiré (avant push)
git reset --hard HEAD~1

# Retrouver un commit "perdu" après suppression de branche
git reflog
git checkout <commit-sha>
git checkout -b feature/recuperee

# Annuler une release finish partielle
git reset --hard origin/main  # sur main
git reset --hard origin/develop  # sur develop
git tag -d v1.2.0  # supprimer le tag si créé

# Forcer la recréation d'une branche
git checkout -B feature/ma-feature develop
```

### Intégration avec des outils

```bash
# Générer automatiquement un CHANGELOG depuis les commits
npx conventional-changelog-cli -p angular -i CHANGELOG.md -s

# Créer un tag avec notes de release automatiques
git tag -a v1.2.0 -m "$(git log v1.1.0..HEAD --pretty=format:'- %s')"

# Notifier Slack lors d'une release
# Dans CI/CD
curl -X POST -H 'Content-type: application/json' \
  --data '{"text":"🚀 Release v1.2.0 déployée!"}' \
  $SLACK_WEBHOOK_URL
```

---

> [!tip] Résumé Git Flow
> 
> **Branches infinies** :
> 
> - `main` : production stable
> - `develop` : intégration continue
> 
> **Branches temporaires** :
> 
> - `feature/*` : nouvelles fonctionnalités (depuis develop → vers develop)
> - `release/*` : préparation de version (depuis develop → vers main + develop)
> - `hotfix/*` : corrections urgentes (depuis main → vers main + develop)