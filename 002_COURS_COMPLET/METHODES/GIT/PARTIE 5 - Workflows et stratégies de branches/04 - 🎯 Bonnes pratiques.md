

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

## 🏷️ Nommage des branches

### Pourquoi c'est important

Un bon nommage de branches permet à toute l'équipe de comprendre instantanément le but d'une branche, facilite la recherche et maintient un historique Git clair et organisé.

### Conventions de nommage recommandées

#### Format général

```bash
<type>/<description-courte>
# ou
<type>/<ticket-id>-<description-courte>
```

#### Types de branches courants

|Type|Usage|Exemple|
|---|---|---|
|`feature/`|Nouvelles fonctionnalités|`feature/user-authentication`|
|`bugfix/`|Correction de bugs non urgents|`bugfix/login-error-message`|
|`hotfix/`|Corrections urgentes en production|`hotfix/payment-gateway-down`|
|`refactor/`|Refactorisation du code|`refactor/database-queries`|
|`docs/`|Documentation uniquement|`docs/api-endpoints`|
|`test/`|Ajout ou modification de tests|`test/unit-tests-user-service`|
|`chore/`|Tâches de maintenance|`chore/update-dependencies`|
|`release/`|Préparation d'une release|`release/v2.3.0`|

> [!example] Exemples concrets
> 
> ```bash
> # Avec ID de ticket (JIRA, GitHub, etc.)
> feature/PROJ-123-dark-mode
> bugfix/PROJ-456-navbar-responsive
> 
> # Sans ID de ticket
> feature/shopping-cart
> hotfix/critical-security-patch
> refactor/clean-user-controller
> ```

### Règles d'écriture

> [!tip] Bonnes pratiques de nommage
> 
> - **Utilisez des tirets** (`-`) plutôt que des underscores ou espaces
> - **Tout en minuscules** pour éviter les problèmes de casse
> - **Soyez descriptif mais concis** (max 50 caractères idéalement)
> - **Pas de caractères spéciaux** sauf `-` et `/`
> - **Évitez les noms trop génériques** comme `fix` ou `update`

```bash
# ✅ BON
git checkout -b feature/user-profile-page
git checkout -b bugfix/ISSUE-789-broken-link
git checkout -b hotfix/xss-vulnerability

# ❌ MAUVAIS
git checkout -b fix                    # Trop vague
git checkout -b My_New_Feature         # Underscores et majuscules
git checkout -b feature/this-is-a-very-long-branch-name-that-explains-everything  # Trop long
git checkout -b amélioration           # Caractères spéciaux
```

> [!warning] Attention aux branches personnelles Si vous travaillez sur des expérimentations personnelles, préfixez avec votre nom :
> 
> ```bash
> git checkout -b john/experiment-new-ui
> git checkout -b marie/poc-graphql
> ```

### Nommage des branches principales

Les branches principales ont souvent des noms standardisés :

```bash
main      # Branche de production (anciennement master)
develop   # Branche de développement intégré
staging   # Environnement de pré-production
```

---

## ⏱️ Fréquence des commits

### Philosophie : Small commits, often

> [!info] Principe fondamental Il vaut mieux faire **des petits commits fréquents** plutôt que de gros commits espacés. Chaque commit devrait représenter une **unité logique de changement**.

### Quand commiter ?

#### ✅ Moments opportuns pour commiter

- Après avoir complété une **sous-tâche fonctionnelle**
- Quand un **test passe** pour la première fois
- Après une **petite refactorisation** terminée
- Avant de **changer de contexte** (pause, réunion)
- Quand le code **compile et fonctionne** (même partiellement)
- Avant de **merger ou rebaser**

```bash
# Exemple de workflow avec commits fréquents
git add src/auth/login.js
git commit -m "feat: add login form validation"

git add src/auth/api.js
git commit -m "feat: implement authentication API call"

git add tests/auth.test.js
git commit -m "test: add login validation tests"
```

#### ❌ Quand NE PAS commiter

- Code qui **ne compile pas** (sauf commit WIP explicite)
- Changements **non testés** sur des fonctionnalités critiques
- Mélange de **plusieurs changements non liés**
- Code avec des **console.log() ou debugger** oubliés
- Fichiers **sensibles** (mots de passe, clés API)

### Le principe "Atomic Commits"

> [!tip] Commits atomiques Un commit atomique = **une seule idée, un seul objectif**. Si vous devez utiliser "et" dans votre message de commit, c'est probablement qu'il faut séparer en deux commits.

```bash
# ❌ MAUVAIS - Commit trop large
git commit -m "Add user profile and fix navbar bug and update dependencies"

# ✅ BON - Commits séparés
git commit -m "feat: add user profile page"
git commit -m "fix: correct navbar mobile display"
git commit -m "chore: update React to v18.3"
```

### Fréquence recommandée

|Situation|Fréquence|
|---|---|
|Développement actif|Toutes les 30-60 minutes|
|Feature complexe|À chaque sous-étape fonctionnelle|
|Bugfix simple|1-2 commits maximum|
|Refactoring|Après chaque transformation logique|

> [!warning] Commits WIP (Work In Progress) Si vous devez commiter du code incomplet (fin de journée, sauvegarde), utilisez un préfixe explicite :
> 
> ```bash
> git commit -m "WIP: user authentication - validation incomplete"
> 
> # Le lendemain, vous pouvez modifier ce commit
> git commit --amend -m "feat: complete user authentication with validation"
> ```

### Avantages des commits fréquents

- 🔍 **Historique détaillé** : Plus facile de retrouver quand un bug a été introduit
- ⏮️ **Reverts ciblés** : Annuler un changement spécifique sans tout casser
- 👥 **Revues de code facilitées** : Plus simple de reviewer de petits changements
- 🔄 **Moins de conflits** : Les merges sont plus fluides
- 💾 **Sauvegarde progressive** : Moins de risque de perdre du travail

---

## 📝 Messages de commit conventionnels

### Le format Conventional Commits

> [!info] Standard de l'industrie Conventional Commits est un standard largement adopté qui rend les messages de commit lisibles par les humains ET les machines (changelog automatiques, semantic versioning).

#### Structure de base

```
<type>[scope optionnel]: <description>

[corps optionnel]

[footer optionnel]
```

### Types de commits

|Type|Description|Exemples|
|---|---|---|
|`feat`|Nouvelle fonctionnalité|Ajouter une page, créer une API|
|`fix`|Correction de bug|Réparer un crash, corriger un calcul|
|`docs`|Documentation uniquement|README, commentaires|
|`style`|Formatage, style de code|Indentation, espaces, semi-colons|
|`refactor`|Refactorisation sans changement de comportement|Réorganiser le code, renommer|
|`perf`|Amélioration des performances|Optimisation, cache|
|`test`|Ajout ou modification de tests|Tests unitaires, e2e|
|`build`|Système de build, dépendances|webpack, npm, gradle|
|`ci`|Configuration CI/CD|GitHub Actions, Jenkins|
|`chore`|Tâches de maintenance|Mise à jour de dépendances|
|`revert`|Annulation d'un commit précédent|Revert d'un changement problématique|

### Exemples détaillés

#### Format simple (description courte)

```bash
git commit -m "feat: add dark mode toggle"
git commit -m "fix: correct email validation regex"
git commit -m "docs: update installation instructions"
git commit -m "refactor: simplify authentication logic"
git commit -m "perf: optimize image loading with lazy loading"
```

#### Avec scope (contexte)

```bash
git commit -m "feat(auth): implement OAuth2 login"
git commit -m "fix(cart): resolve total calculation error"
git commit -m "style(navbar): adjust mobile responsiveness"
git commit -m "test(api): add integration tests for user endpoints"
```

> [!example] Scopes courants
> 
> - `(auth)` - Authentification
> - `(api)` - API backend
> - `(ui)` - Interface utilisateur
> - `(db)` - Base de données
> - `(config)` - Configuration
> - `(deps)` - Dépendances

#### Avec corps et footer (commit complet)

```bash
git commit -m "feat(payment): integrate Stripe payment gateway

Add Stripe SDK and implement payment flow including:
- Card validation
- Payment intent creation
- Webhook handling for payment confirmation

This allows users to make secure payments directly on the platform.

Closes #234
Refs #189"
```

### Règles d'écriture du message

> [!tip] Bonnes pratiques
> 
> 1. **Première ligne (sujet)** :
>     - Maximum 50-72 caractères
>     - Impératif présent : "add" pas "added" ou "adds"
>     - Pas de point final
>     - Commence par une minuscule après le type
> 2. **Corps (optionnel)** :
>     - Séparé du sujet par une ligne vide
>     - Explique le "pourquoi" et le "quoi", pas le "comment"
>     - Limite à 72 caractères par ligne
> 3. **Footer (optionnel)** :
>     - Références aux issues : `Closes #123`, `Fixes #456`
>     - Breaking changes : `BREAKING CHANGE: description`

```bash
# ✅ BON
feat(auth): add JWT token refresh mechanism

Implements automatic token refresh before expiration to improve
user experience and reduce forced logouts. Token is refreshed
5 minutes before expiration.

Closes #567

# ❌ MAUVAIS
Updated stuff  # Trop vague, pas de type
FIX: Fixed the bug.  # Type en majuscules, point final, pas descriptif
feat(api):Added a new endpoint for users  # Pas d'espace après ":", majuscule incorrecte
```

### Breaking Changes

> [!warning] Changements incompatibles (Breaking Changes) Si votre commit introduit un changement incompatible avec les versions précédentes, ajoutez `!` après le type ou un footer `BREAKING CHANGE:` :

```bash
# Méthode 1 : ! dans le type
git commit -m "feat!: remove deprecated API v1 endpoints"

# Méthode 2 : Footer BREAKING CHANGE
git commit -m "refactor(auth): change authentication method

BREAKING CHANGE: JWT tokens now expire after 1 hour instead of 24 hours.
All clients must implement token refresh."
```

### Outils pour forcer les conventions

```bash
# Installation de commitlint (Node.js)
npm install --save-dev @commitlint/cli @commitlint/config-conventional

# Avec Husky pour vérifier automatiquement
npm install --save-dev husky
npx husky add .husky/commit-msg 'npx --no -- commitlint --edit "$1"'
```

---

## 🌿 Quand créer une branche

### Règle d'or

> [!info] Principe fondamental **Une branche = une unité de travail isolée**. Créez une nouvelle branche chaque fois que vous commencez un travail qui peut évoluer indépendamment du reste.

### Situations où créer une branche

#### ✅ Toujours créer une branche pour :

1. **Nouvelle fonctionnalité** (feature)

```bash
# Même petite, une feature mérite sa branche
git checkout -b feature/add-search-bar
```

2. **Correction de bug** (bugfix)

```bash
# Isole le fix pour faciliter le test et le déploiement
git checkout -b bugfix/fix-login-redirect
```

3. **Hotfix urgent** (hotfix)

```bash
# Correctif critique en production
git checkout -b hotfix/security-patch
```

4. **Refactoring significatif** (refactor)

```bash
# Restructuration de code sans changement fonctionnel
git checkout -b refactor/optimize-database-queries
```

5. **Expérimentation** (experiment/poc)

```bash
# Tests ou proof of concept
git checkout -b experiment/test-new-framework
```

6. **Tâches multiples en parallèle**

```bash
# Vous travaillez sur plusieurs choses en même temps
git checkout -b feature/user-dashboard
# Plus tard...
git checkout -b bugfix/navbar-mobile
```

#### ❌ Ne PAS créer de branche pour :

- Un **changement d'une ligne** trivial (typo dans un commentaire)
- Une **mise à jour de documentation** mineure (si c'est la seule chose)
- Un **commit direct sur main/develop** autorisé par votre workflow

> [!warning] Exception : branches protégées Dans la plupart des projets professionnels, `main` et `develop` sont **protégées** : vous DEVEZ toujours passer par une branche, même pour un changement trivial.

### Stratégies de création de branches

#### Approche par feature (recommandée)

```bash
# Une branche par fonctionnalité, peu importe la taille
git checkout -b feature/user-profile
# Développement...
git checkout main
git merge feature/user-profile
git branch -d feature/user-profile  # Suppression après merge
```

#### Approche par tâche

```bash
# Si vous utilisez un système de tickets (Jira, GitHub Issues)
git checkout -b feature/PROJ-123-shopping-cart
git checkout -b bugfix/PROJ-456-payment-error
```

#### Branches de longue durée vs courte durée

|Type|Durée de vie|Usage|
|---|---|---|
|**Courte durée**|1-5 jours|Features, bugfix, hotfix|
|**Moyenne durée**|1-4 semaines|Grandes features, refactoring majeur|
|**Longue durée**|Permanente|`main`, `develop`, `staging`|

> [!tip] Privilégiez les branches courtes Plus une branche vit longtemps, plus elle risque de diverger et de créer des conflits. Essayez de merger vos branches **le plus rapidement possible**.

### Workflow de création typique

```bash
# 1. Assurez-vous d'être à jour
git checkout main
git pull origin main

# 2. Créez votre branche
git checkout -b feature/new-dashboard

# 3. Travaillez et commitez
git add .
git commit -m "feat(dashboard): add initial layout"

# 4. Poussez régulièrement
git push -u origin feature/new-dashboard

# 5. Ouvrez une Pull Request quand prêt
# (via GitHub/GitLab/Bitbucket)

# 6. Après merge, nettoyez
git checkout main
git pull origin main
git branch -d feature/new-dashboard
```

### Quand fusionner plusieurs changements dans une seule branche ?

> [!example] Changements liés Si plusieurs modifications sont **étroitement liées** et ne peuvent fonctionner indépendamment, groupez-les dans une seule branche :
> 
> ```bash
> # ✅ BON - Changements interdépendants
> git checkout -b feature/user-authentication
> # Inclut : login form + API endpoint + JWT handling + tests
> 
> # ❌ MAUVAIS - Changements indépendants
> git checkout -b feature/multiple-things
> # Inclut : authentification + dark mode + refactor navbar
> # → Devrait être 3 branches séparées !
> ```

### Checklist avant de créer une branche

- [ ] Mon travail est-il une **unité logique** distincte ?
- [ ] Ai-je synchronisé avec la **branche parente** (`main`/`develop`) ?
- [ ] Le nom de ma branche suit-il les **conventions** ?
- [ ] Cette branche peut-elle vivre **indépendamment** des autres ?
- [ ] Suis-je sur le **bon point de départ** (bonne branche parent) ?

```bash
# Vérifiez votre point de départ
git status                    # Sur quelle branche suis-je ?
git branch -a                 # Liste toutes les branches
git log --oneline -n 5        # Derniers commits du point de départ
```

### Gestion des branches obsolètes

> [!tip] Nettoyage régulier Supprimez les branches mergées pour garder un historique propre :
> 
> ```bash
> # Supprimer une branche locale
> git branch -d feature/old-feature
> 
> # Supprimer une branche distante
> git push origin --delete feature/old-feature
> 
> # Lister les branches déjà mergées
> git branch --merged main
> 
> # Supprimer toutes les branches mergées (sauf main)
> git branch --merged main | grep -v "main" | xargs git branch -d
> ```

---

## 🎯 Récapitulatif des bonnes pratiques

|Pratique|Recommandation|
|---|---|
|**Nommage**|`<type>/<description>` en minuscules avec tirets|
|**Fréquence commits**|Petits commits atomiques toutes les 30-60 minutes|
|**Messages**|Format Conventional Commits : `type(scope): description`|
|**Création branches**|Une branche par feature/bugfix, même petite|
|**Durée de vie**|Merger rapidement (1-5 jours idéalement)|
|**Nettoyage**|Supprimer les branches après merge|

> [!tip] Conseil final Ces bonnes pratiques ne sont pas des règles absolues mais des **conventions largement adoptées** dans l'industrie. Adaptez-les aux besoins de votre équipe, mais **restez cohérent** dans votre projet !

---

_Cours complet sur les bonnes pratiques Git - Workflows et stratégies de branches_