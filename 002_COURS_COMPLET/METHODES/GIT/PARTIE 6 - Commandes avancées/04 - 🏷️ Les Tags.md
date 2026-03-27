

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

## 🎯 Introduction aux tags

Les **tags** dans Git sont des références fixes qui pointent vers des commits spécifiques. Contrairement aux branches qui évoluent avec de nouveaux commits, un tag reste toujours associé au même commit.

> [!info] Pourquoi utiliser des tags ? Les tags sont principalement utilisés pour **marquer des versions importantes** de votre projet (v1.0, v2.3.1, etc.). Ils permettent de retrouver facilement un état précis du code à un moment donné, particulièrement utile pour :
> 
> - Identifier les versions publiées en production
> - Créer des releases GitHub/GitLab
> - Établir des points de référence stables
> - Documenter l'historique du projet

---

## 🔍 Tags légers vs annotés

Git propose deux types de tags qui ont des usages différents :

### Tags légers (Lightweight tags)

Un tag léger est simplement un **pointeur vers un commit**, similaire à une branche qui ne bouge jamais.

**Caractéristiques :**

- Ne contient que le nom et la référence du commit
- Pas de métadonnées (auteur, date, message)
- Stocké comme un simple fichier dans `.git/refs/tags/`
- Rapide à créer

> [!example] Cas d'usage Idéal pour des marqueurs temporaires ou personnels qui ne seront pas partagés (tests, repères de développement).

### Tags annotés (Annotated tags)

Un tag annoté est un **objet Git complet** stocké dans la base de données Git.

**Caractéristiques :**

- Contient le nom du tagger et son email
- Date de création
- Message de tag
- Peut être signé avec GPG
- Stocké comme un objet à part entière dans la base Git
- Checksumé pour l'intégrité

> [!tip] Recommandation **Utilisez toujours des tags annotés pour les versions publiques.** Ils fournissent un contexte précieux et peuvent être vérifiés cryptographiquement.

### Comparaison

|Critère|Tag léger|Tag annoté|
|---|---|---|
|Stockage|Simple référence|Objet Git complet|
|Métadonnées|❌ Non|✅ Oui (auteur, date, message)|
|Signature GPG|❌ Non|✅ Possible|
|Usage|Temporaire/personnel|Production/releases|
|Commande|`git tag <nom>`|`git tag -a <nom>`|

---

## ✨ Créer des tags

### Créer un tag léger

```bash
# Tag sur le commit actuel (HEAD)
git tag v1.0.0

# Tag sur un commit spécifique
git tag v0.9.0 a1b2c3d
```

> [!warning] Attention Les tags légers ne contiennent aucune information supplémentaire. Si vous oubliez pourquoi vous avez créé ce tag, il sera difficile de le savoir plus tard.

### Créer un tag annoté

```bash
# Tag annoté sur HEAD avec éditeur pour le message
git tag -a v1.0.0

# Tag annoté avec message en ligne de commande
git tag -a v1.0.0 -m "Version 1.0.0 - Release initiale"

# Tag annoté sur un commit spécifique
git tag -a v0.9.0 a1b2c3d -m "Version beta finale"
```

> [!example] Exemple de message de tag
> 
> ```bash
> git tag -a v2.1.0 -m "Release 2.1.0
> 
> Nouvelles fonctionnalités:
> - Ajout du mode sombre
> - Support multi-langues
> 
> Corrections:
> - Fix du bug de login
> - Amélioration des performances"
> ```

### Tag annoté avec signature GPG

```bash
# Créer un tag signé (nécessite GPG configuré)
git tag -s v1.0.0 -m "Version 1.0.0 signée"

# Vérifier la signature d'un tag
git tag -v v1.0.0
```

> [!info] Configuration GPG Pour utiliser des tags signés, vous devez avoir configuré GPG avec Git. La signature garantit l'authenticité et l'intégrité du tag.

---

## 📋 Lister et afficher les tags

### Lister les tags

```bash
# Lister tous les tags
git tag

# Lister les tags avec un pattern
git tag -l "v1.*"
git tag -l "v2.1.*"

# Afficher les tags avec leurs messages (tags annotés)
git tag -n
git tag -n5  # Affiche jusqu'à 5 lignes du message
```

> [!example] Sortie exemple
> 
> ```bash
> $ git tag -l "v1.*"
> v1.0.0
> v1.0.1
> v1.1.0
> v1.2.0
> ```

### Afficher les détails d'un tag

```bash
# Afficher les informations complètes d'un tag annoté
git show v1.0.0

# Afficher uniquement le commit associé
git rev-parse v1.0.0

# Voir la différence entre deux tags
git diff v1.0.0 v1.1.0
```

> [!tip] Astuce `git show <tag>` affiche les métadonnées du tag annoté ET le contenu du commit associé. Pour un tag léger, il affiche uniquement le commit.

### Checkout d'un tag

```bash
# Se positionner sur un tag (detached HEAD)
git checkout v1.0.0

# Créer une branche à partir d'un tag
git checkout -b hotfix-1.0.1 v1.0.0
```

> [!warning] Detached HEAD Faire un checkout sur un tag vous met en état "detached HEAD". Tout nouveau commit ne sera attaché à aucune branche. Créez une branche si vous devez faire des modifications.

---

## 🚀 Pousser des tags

Par défaut, `git push` **ne pousse pas les tags** vers le serveur distant. Vous devez les pousser explicitement.

### Pousser un tag spécifique

```bash
# Pousser un seul tag
git push origin v1.0.0

# Pousser vers un remote spécifique
git push upstream v2.0.0
```

### Pousser tous les tags

```bash
# Pousser tous les tags (légers et annotés)
git push origin --tags

# Pousser uniquement les tags annotés (Git 2.4+)
git push origin --follow-tags
```

> [!tip] Configuration automatique Pour toujours pousser les tags annotés avec vos commits :
> 
> ```bash
> git config --global push.followTags true
> ```
> 
> Avec cette configuration, `git push` poussera automatiquement les tags annotés associés aux commits poussés.

### Forcer la mise à jour d'un tag

```bash
# Si vous avez déplacé un tag localement et voulez forcer la mise à jour
git push origin v1.0.0 --force

# Ou avec la syntaxe courte
git push origin v1.0.0 -f
```

> [!warning] Danger ! **Ne déplacez JAMAIS un tag qui a été poussé publiquement**, surtout pour des versions releases. Cela peut causer des problèmes majeurs pour les autres développeurs et les systèmes de déploiement.

---

## 🗑️ Supprimer des tags

### Supprimer un tag local

```bash
# Supprimer un tag de votre dépôt local
git tag -d v1.0.0

# Supprimer plusieurs tags
git tag -d v1.0.0 v1.0.1 v1.0.2
```

### Supprimer un tag distant

```bash
# Méthode 1 : Pousser une référence vide
git push origin :refs/tags/v1.0.0

# Méthode 2 : Utiliser --delete (plus clair)
git push origin --delete v1.0.0

# Supprimer plusieurs tags distants
git push origin --delete v1.0.0 v1.0.1
```

> [!example] Workflow complet de suppression
> 
> ```bash
> # 1. Supprimer localement
> git tag -d v1.0.0
> 
> # 2. Supprimer sur le serveur
> git push origin --delete v1.0.0
> 
> # 3. Vérifier
> git tag -l
> git ls-remote --tags origin
> ```

### Déplacer un tag

Il n'existe pas de commande "rename" pour les tags. Pour déplacer un tag :

```bash
# 1. Créer un nouveau tag sur le bon commit
git tag -a v1.0.1 -m "Correction du tag v1.0.0" a1b2c3d

# 2. Supprimer l'ancien tag localement
git tag -d v1.0.0

# 3. Pousser le nouveau tag
git push origin v1.0.1

# 4. Supprimer l'ancien tag distant
git push origin --delete v1.0.0
```

> [!warning] Tags publics Ne déplacez jamais un tag de version déjà utilisé en production. Créez plutôt une nouvelle version corrective (v1.0.1 au lieu de modifier v1.0.0).

---

## ⚠️ Pièges courants

### 1. Oublier de pousser les tags

```bash
# ❌ Les tags ne sont pas inclus automatiquement
git push origin main

# ✅ Pousser explicitement
git push origin main --follow-tags
# ou
git push origin --tags
```

### 2. Créer des tags légers pour les releases

```bash
# ❌ Tag léger sans contexte
git tag v1.0.0

# ✅ Tag annoté avec message
git tag -a v1.0.0 -m "Release 1.0.0 - Production ready"
```

### 3. Dupliquer des tags entre local et distant

```bash
# Si vous créez un tag qui existe déjà sur le distant
# Git refusera de le pousser

# Pour voir les différences :
git ls-remote --tags origin
git tag -l
```

### 4. Confondre tags et branches

> [!info] Différence clé
> 
> - **Tag** : Référence fixe, ne bouge jamais (marqueur d'un point dans l'histoire)
> - **Branche** : Référence mobile, avance avec les nouveaux commits (ligne de développement)

### 5. Supprimer un tag local sans le distant

```bash
# ❌ Supprime seulement localement
git tag -d v1.0.0

# Le tag existe toujours sur origin
# Au prochain fetch, il sera re-téléchargé

# ✅ Supprimer aussi sur le distant
git push origin --delete v1.0.0
```

---

## 💡 Bonnes pratiques

### Nomenclature des tags

> [!tip] Semantic Versioning Utilisez le versionnement sémantique : `vMAJOR.MINOR.PATCH`
> 
> - **MAJOR** : Changements incompatibles avec les versions précédentes
> - **MINOR** : Nouvelles fonctionnalités compatibles
> - **PATCH** : Corrections de bugs
> 
> Exemples : `v1.0.0`, `v2.3.1`, `v3.0.0-beta.1`

```bash
# ✅ Bon
git tag -a v1.2.3 -m "Release 1.2.3"

# ❌ À éviter
git tag -a release1 -m "First release"
git tag -a prod -m "Production"
```

### Préfixe 'v' ou pas ?

Les deux conventions existent, choisissez-en une et soyez cohérent :

```bash
# Avec 'v' (recommandé, plus lisible)
v1.0.0, v2.1.3

# Sans 'v' (plus courant dans certains écosystèmes)
1.0.0, 2.1.3
```

### Messages de tags descriptifs

```bash
# ❌ Trop vague
git tag -a v1.0.0 -m "New version"

# ✅ Descriptif et utile
git tag -a v1.0.0 -m "Release 1.0.0 - Premier déploiement production

Fonctionnalités majeures :
- Authentification utilisateur
- Dashboard analytics
- API REST complète

Breaking changes :
- Changement du format de l'API /users

Migration : voir CHANGELOG.md"
```

### Tags pour les hotfixes

```bash
# Convention pour les correctifs d'urgence
git tag -a v1.2.1 -m "Hotfix 1.2.1 - Correction bug critique login"
```

### Automatisation avec CI/CD

Intégrez la création de tags dans votre pipeline :

```bash
# Exemple : créer automatiquement un tag après validation
# Dans votre CI/CD (GitHub Actions, GitLab CI, etc.)
git tag -a v${VERSION} -m "Auto-release ${VERSION}"
git push origin v${VERSION}
```

### Vérification avant suppression

```bash
# Toujours vérifier ce que le tag pointe avant suppression
git show v1.0.0

# Lister qui utilise ce tag
git branch --contains v1.0.0
```

### Documentation des tags

Maintenez un fichier `CHANGELOG.md` ou `RELEASES.md` pour documenter chaque version :

```markdown
## v1.2.0 (2024-01-15)

### Nouvelles fonctionnalités
- Ajout du mode sombre (#123)
- Support des webhooks (#145)

### Corrections
- Fix du bug de pagination (#156)

### Notes de migration
- Nouvelle variable d'environnement `THEME_MODE` requise
```

---

## 🎓 Récapitulatif

|Commande|Description|
|---|---|
|`git tag v1.0.0`|Créer un tag léger|
|`git tag -a v1.0.0 -m "msg"`|Créer un tag annoté|
|`git tag -l "v1.*"`|Lister les tags avec pattern|
|`git show v1.0.0`|Afficher les détails d'un tag|
|`git push origin v1.0.0`|Pousser un tag spécifique|
|`git push origin --tags`|Pousser tous les tags|
|`git tag -d v1.0.0`|Supprimer un tag local|
|`git push origin --delete v1.0.0`|Supprimer un tag distant|

> [!tip] Commande favorite
> 
> ```bash
> # Configuration pour toujours pousser les tags annotés
> git config --global push.followTags true
> 
> # Puis simplement :
> git push
> ```

---

**Les tags sont essentiels pour maintenir un historique clair des versions de votre projet. Privilégiez toujours les tags annotés pour les releases importantes !** 🏷️✨