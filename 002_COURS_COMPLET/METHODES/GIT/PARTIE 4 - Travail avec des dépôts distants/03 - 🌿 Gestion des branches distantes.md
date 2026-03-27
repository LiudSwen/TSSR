

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

La gestion des branches distantes est essentielle pour collaborer efficacement avec Git. Elle permet de synchroniser votre travail local avec un dépôt distant (comme GitHub, GitLab, etc.) et de coordonner les contributions de plusieurs développeurs.

> [!info] Rappel Une branche distante est une référence à l'état d'une branche sur un dépôt distant. Elle suit l'évolution de cette branche mais n'est pas modifiable directement depuis votre dépôt local.

---

## Tracking Branches

### Qu'est-ce qu'une tracking branch ?

Une **tracking branch** (branche de suivi) est une branche locale qui possède une relation directe avec une branche distante. Cette relation permet à Git de savoir automatiquement où pousser et d'où tirer les modifications.

> [!example] Exemple de relation Si votre branche locale `feature-login` suit la branche distante `origin/feature-login`, Git établit un lien bidirectionnel qui facilite la synchronisation.

**Avantages d'une tracking branch :**

- ✅ Permet d'utiliser `git push` et `git pull` sans spécifier la destination
- ✅ Git affiche automatiquement le nombre de commits d'avance/retard par rapport à la branche distante
- ✅ Simplifie les commandes et réduit les erreurs

### Création et configuration

#### Créer une tracking branch lors du checkout

```bash
# Créer une branche locale qui suit automatiquement origin/feature-api
git checkout -b feature-api origin/feature-api

# Version raccourcie (si la branche distante existe déjà)
git checkout feature-api
# Git détecte automatiquement origin/feature-api et configure le tracking
```

#### Configurer le tracking sur une branche existante

```bash
# Méthode 1 : Avec git branch
git branch --set-upstream-to=origin/ma-branche ma-branche

# Méthode 2 : Avec git branch -u (équivalent, plus court)
git branch -u origin/ma-branche ma-branche

# Si vous êtes déjà sur la branche ma-branche
git branch -u origin/ma-branche
```

> [!tip] Astuce L'option `-u` est un raccourci pour `--set-upstream-to`. Utilisez celle que vous préférez !

### Vérifier le tracking

```bash
# Afficher les branches avec leur upstream (branche suivie)
git branch -vv

# Sortie exemple :
#   main                 a1b2c3d [origin/main: ahead 2] Dernier commit
# * feature-api          d4e5f6g [origin/feature-api] Ajout API
#   feature-login        g7h8i9j Connexion utilisateur
```

> [!info] Lecture de la sortie
> 
> - `[origin/main: ahead 2]` : votre branche locale a 2 commits d'avance sur origin/main
> - `[origin/feature-api]` : votre branche est à jour avec origin/feature-api
> - Absence de `[...]` : la branche n'a pas de tracking configuré

---

## Push avec option -u

### La commande `git push -u`

L'option `-u` (ou `--set-upstream`) lors d'un push permet de configurer le tracking ET de pousser les modifications en une seule commande.

```bash
# Pousser la branche locale et configurer le tracking
git push -u origin ma-nouvelle-branche

# Équivalent à :
# 1. git push origin ma-nouvelle-branche
# 2. git branch -u origin/ma-nouvelle-branche
```

> [!warning] Important Utilisez `-u` principalement lors du **premier push** d'une nouvelle branche. Les push suivants n'en ont généralement pas besoin.

### Différences entre push simple et push -u

|Commande|Configuration du tracking|Utilisation future|
|---|---|---|
|`git push origin ma-branche`|❌ Non|Vous devrez toujours spécifier `origin ma-branche`|
|`git push -u origin ma-branche`|✅ Oui|Vous pourrez utiliser simplement `git push`|

**Sans `-u` :**

```bash
# Premier push
git push origin feature-api

# Push suivants - vous devez toujours spécifier la destination
git push origin feature-api
git push origin feature-api
```

**Avec `-u` :**

```bash
# Premier push avec configuration du tracking
git push -u origin feature-api

# Push suivants - Git connaît la destination
git push
git push
```

### Workflow recommandé

```bash
# 1. Créer une nouvelle branche locale
git checkout -b feature-paiement

# 2. Travailler sur votre fonctionnalité
git add .
git commit -m "Ajout module de paiement"

# 3. Premier push avec -u pour configurer le tracking
git push -u origin feature-paiement
# Message Git : Branch 'feature-paiement' set up to track remote branch 'feature-paiement' from 'origin'.

# 4. Modifications supplémentaires
git add .
git commit -m "Correction validation paiement"

# 5. Push suivants sans spécifier la destination
git push
```

> [!tip] Astuce : Push automatique du tracking Vous pouvez configurer Git pour toujours utiliser `-u` automatiquement :
> 
> ```bash
> git config --global push.autoSetupRemote true
> ```
> 
> Avec cette configuration, `git push` configurera automatiquement le tracking lors du premier push d'une nouvelle branche.

---

## Suppression de branches distantes

### Méthodes de suppression

Il existe plusieurs façons de supprimer une branche sur le dépôt distant :

#### Méthode 1 : Push avec suppression

```bash
# Supprimer la branche distante origin/ancienne-feature
git push origin --delete ancienne-feature

# Syntaxe alternative (historique, moins lisible)
git push origin :ancienne-feature
```

> [!example] Exemple pratique
> 
> ```bash
> # Votre feature est mergée, vous voulez nettoyer
> git checkout main
> git branch -d feature-completed  # Suppression locale
> git push origin --delete feature-completed  # Suppression distante
> ```

#### Méthode 2 : Via l'interface web

La plupart des plateformes (GitHub, GitLab, Bitbucket) permettent de supprimer des branches via leur interface web, notamment après un merge de Pull Request.

> [!tip] Bonne pratique Sur GitHub, activez l'option "Automatically delete head branches" dans les paramètres du dépôt pour supprimer automatiquement les branches après un merge.

### Nettoyage local après suppression

Lorsqu'une branche distante est supprimée (par vous ou un collègue), votre dépôt local conserve des références obsolètes.

```bash
# Lister les branches distantes (peut afficher des branches supprimées)
git branch -r
# Sortie :
#   origin/main
#   origin/feature-active
#   origin/ancienne-feature  # <- Cette branche a été supprimée sur origin

# Nettoyer les références obsolètes
git fetch --prune
# ou
git fetch -p

# Vérifier le nettoyage
git branch -r
# Sortie :
#   origin/main
#   origin/feature-active
```

> [!info] Automatisation du nettoyage Configurez Git pour toujours faire le nettoyage automatiquement :
> 
> ```bash
> git config --global fetch.prune true
> ```

#### Supprimer aussi les branches locales correspondantes

```bash
# Trouver les branches locales dont l'upstream n'existe plus
git branch -vv | grep ': gone]'

# Supprimer manuellement une branche locale
git branch -d nom-branche

# Script pour supprimer toutes les branches dont l'upstream est "gone"
git fetch -p && git branch -vv | grep ': gone]' | awk '{print $1}' | xargs git branch -d
```

> [!warning] Attention Utilisez `-d` pour une suppression sûre (Git refuse si des commits ne sont pas mergés). Utilisez `-D` pour forcer la suppression même avec des commits non mergés.

---

## Visualisation des branches

### `git branch -r` : branches distantes

Cette commande affiche **uniquement** les branches du dépôt distant.

```bash
git branch -r

# Sortie exemple :
#   origin/main
#   origin/develop
#   origin/feature-api
#   origin/hotfix-bug-123
```

> [!info] Format de nommage Les branches distantes sont préfixées par le nom du remote (généralement `origin`). Le format est : `remote/nom-branche`

**Cas d'usage :**

- Voir quelles branches existent sur le serveur
- Vérifier si une branche a été poussée
- Identifier les branches disponibles pour checkout

### `git branch -a` : toutes les branches

Cette commande affiche **toutes** les branches : locales ET distantes.

```bash
git branch -a

# Sortie exemple :
#   main
# * feature-login
#   feature-api
#   remotes/origin/main
#   remotes/origin/develop
#   remotes/origin/feature-api
#   remotes/origin/feature-dashboard
```

> [!info] Lecture de la sortie
> 
> - Sans préfixe : branches locales
> - `*` : branche actuellement active
> - `remotes/origin/` : branches distantes

**Cas d'usage :**

- Vue d'ensemble complète de toutes les branches
- Comparer branches locales et distantes
- Identifier les branches qui existent uniquement en local ou uniquement en distant

### Informations détaillées

```bash
# Afficher les branches avec des informations supplémentaires
git branch -av

# Sortie exemple :
#   main                 a1b2c3d [origin/main: ahead 1] Fix typo
# * feature-login        c3d4e5f [origin/feature-login] Add login form
#   feature-api          e5f6g7h Add API endpoints
#   remotes/origin/main  a1b2c3d Fix typo
#   remotes/origin/develop 9z8y7x6 Merge feature-X

# Pour encore plus de détails (tracking info)
git branch -avv
```

**Options utiles :**

|Option|Description|
|---|---|
|`-r`|Branches distantes uniquement|
|`-a`|Toutes les branches (locales + distantes)|
|`-v`|Verbose : affiche le hash et le message du dernier commit|
|`-vv`|Très verbose : ajoute les informations de tracking|

> [!tip] Astuce : Filtrer les résultats
> 
> ```bash
> # Trouver toutes les branches contenant "feature" dans le nom
> git branch -a | grep feature
> 
> # Branches distantes commençant par "hotfix"
> git branch -r | grep hotfix
> ```

---

## Pièges courants

> [!warning] Piège 1 : Oublier de fetch avant de lister
> 
> ```bash
> # ❌ Mauvais - affiche l'état local potentiellement obsolète
> git branch -r
> 
> # ✅ Bon - met à jour puis affiche
> git fetch
> git branch -r
> ```

> [!warning] Piège 2 : Confondre suppression locale et distante
> 
> ```bash
> # Supprime uniquement la branche locale
> git branch -d ma-branche
> 
> # La branche distante existe toujours !
> # Il faut aussi faire :
> git push origin --delete ma-branche
> ```

> [!warning] Piège 3 : Push sans -u puis confusion
> 
> ```bash
> # Premier push sans -u
> git push origin nouvelle-branche
> 
> # Plus tard, tentative de pull
> git pull
> # Erreur : There is no tracking information for the current branch
> 
> # Solution : configurer le tracking
> git branch -u origin/nouvelle-branche
> ```

> [!warning] Piège 4 : Branches "gone" qui s'accumulent Après qu'un collègue supprime des branches distantes, vos références locales restent obsolètes. Pensez à `git fetch --prune` régulièrement !

---

## Bonnes pratiques

> [!tip] ✅ Toujours utiliser -u au premier push
> 
> ```bash
> git push -u origin ma-nouvelle-branche
> ```
> 
> Cela évite de devoir spécifier la destination à chaque fois.

> [!tip] ✅ Nettoyer régulièrement les branches obsolètes
> 
> ```bash
> # Dans votre routine hebdomadaire
> git fetch --prune
> git branch -vv | grep ': gone]' | awk '{print $1}' | xargs git branch -d
> ```

> [!tip] ✅ Vérifier le tracking avant de travailler
> 
> ```bash
> git branch -vv
> ```
> 
> Assurez-vous que votre branche suit la bonne branche distante.

> [!tip] ✅ Utiliser des noms de branches cohérents
> 
> ```bash
> # Bon : même nom local et distant
> git checkout -b feature-paiement
> git push -u origin feature-paiement
> 
> # Éviter : noms différents qui créent de la confusion
> git checkout -b mon-feature
> git push -u origin feature-paiement-final-v2
> ```

> [!tip] ✅ Documenter les branches importantes Utilisez des noms descriptifs et ajoutez une description si votre plateforme le permet :
> 
> ```bash
> # Sur GitHub, vous pouvez ajouter une description via l'interface web
> # Ou dans le message de commit du premier push
> git commit -m "feat: Système de paiement Stripe
> 
> Implémentation complète du module de paiement avec :
> - Intégration Stripe
> - Gestion des webhooks
> - Tests unitaires"
> ```

> [!tip] ✅ Configuration globale recommandée
> 
> ```bash
> # Auto-setup du tracking lors du push
> git config --global push.autoSetupRemote true
> 
> # Auto-prune lors du fetch
> git config --global fetch.prune true
> 
> # Affichage des branches avec couleurs
> git config --global color.branch auto
> ```

---

## 🎯 Résumé des commandes essentielles

```bash
# Tracking
git checkout -b ma-branche origin/ma-branche  # Créer avec tracking
git branch -u origin/ma-branche                # Configurer tracking
git branch -vv                                 # Vérifier tracking

# Push avec tracking
git push -u origin ma-branche                  # Premier push + tracking
git push                                       # Push suivants

# Suppression
git push origin --delete vieille-branche       # Supprimer branche distante
git fetch --prune                              # Nettoyer références locales

# Visualisation
git branch -r                                  # Branches distantes
git branch -a                                  # Toutes les branches
git branch -av                                 # Toutes + infos détaillées
```