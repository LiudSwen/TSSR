

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

## Introduction au Stash

> [!info] Qu'est-ce que le stash ? Le **stash** (réserve/cachette en français) est une zone de stockage temporaire qui permet de sauvegarder vos modifications en cours sans avoir à créer un commit. C'est comme un "tiroir" où vous pouvez ranger temporairement votre travail.

### 🎯 Pourquoi utiliser le stash ?

Le stash est particulièrement utile dans ces situations :

- **Changement de branche urgent** : Vous travaillez sur une fonctionnalité, mais un bug critique nécessite votre attention immédiate sur une autre branche
- **Travail incomplet** : Vos modifications ne sont pas prêtes pour un commit, mais vous devez nettoyer votre working directory
- **Expérimentation** : Vous voulez tester quelque chose rapidement sans perdre votre travail actuel
- **Pull avec modifications locales** : Vous devez faire un `git pull` mais avez des modifications locales qui pourraient entrer en conflit

> [!warning] Attention Le stash sauvegarde uniquement les modifications dans votre **working directory** et votre **staging area**. Les fichiers non suivis (untracked) ne sont pas inclus par défaut.

---

## git stash - Sauvegarder temporairement

### Syntaxe de base

```bash
git stash
# Ou la forme complète
git stash push
```

Cette commande va :

1. Sauvegarder toutes les modifications trackées (suivies)
2. Nettoyer votre working directory
3. Revenir à l'état du dernier commit (HEAD)

### 📝 Options importantes

#### Sauvegarder avec un message descriptif

```bash
git stash push -m "WIP: Ajout du système d'authentification"
# WIP = Work In Progress (Travail en cours)
```

> [!tip] Astuce Toujours ajouter un message descriptif ! Cela facilite grandement la gestion de plusieurs stashs.

#### Inclure les fichiers non suivis (untracked)

```bash
git stash -u
# Ou
git stash --include-untracked
```

Cette option sauvegarde également les nouveaux fichiers que vous avez créés mais pas encore ajoutés avec `git add`.

#### Inclure TOUS les fichiers (même ignorés)

```bash
git stash -a
# Ou
git stash --all
```

Cela inclut même les fichiers listés dans `.gitignore`.

> [!warning] Prudence avec --all L'option `--all` peut sauvegarder des fichiers de build, node_modules, etc. Utilisez-la avec parcimonie.

#### Sauvegarder seulement certains fichiers

```bash
git stash push -m "Fix CSS" src/styles.css src/components/Header.css
```

#### Créer un stash interactif (sélection fichier par fichier)

```bash
git stash -p
# Ou
git stash --patch
```

Git vous demandera pour chaque modification si vous voulez la stasher.

### 🔄 Que se passe-t-il après un stash ?

```bash
# Avant le stash
$ git status
On branch feature/login
Changes not staged for commit:
  modified:   src/auth.js
  modified:   src/login.js

# Après git stash
$ git status
On branch feature/login
nothing to commit, working tree clean
```

Votre working directory est propre, comme si les modifications n'avaient jamais existé !

---

## git stash list - Lister les stashs

### Syntaxe

```bash
git stash list
```

### 📊 Format de sortie

```bash
$ git stash list
stash@{0}: WIP on feature/login: 3a2b1c4 Add login form
stash@{1}: On main: Fix header styling
stash@{2}: WIP on feature/api: 7d8e9f0 API integration
```

Chaque ligne contient :

- **Identifiant** : `stash@{n}` où n est l'index (0 = le plus récent)
- **Branche d'origine** : Sur quelle branche le stash a été créé
- **Message** : Description du stash
- **Commit de référence** : Le commit sur lequel était basé le stash

> [!info] Organisation en pile (Stack) Les stashs fonctionnent comme une **pile** (LIFO - Last In, First Out). Le stash le plus récent est `stash@{0}`, le suivant `stash@{1}`, etc.

### Voir le contenu d'un stash spécifique

```bash
# Voir un résumé des modifications
git stash show stash@{0}

# Voir le diff complet
git stash show -p stash@{0}
# Ou
git stash show --patch stash@{1}
```

Exemple de sortie :

```bash
$ git stash show -p stash@{0}
diff --git a/src/auth.js b/src/auth.js
index 1a2b3c4..5d6e7f8 100644
--- a/src/auth.js
+++ b/src/auth.js
@@ -10,6 +10,8 @@ export function login(username, password) {
+  // Nouvelle validation
+  if (!username || !password) return false;
```

---

## git stash apply / pop - Récupérer un stash

### 🔄 Deux approches : apply vs pop

|Commande|Effet|Garde le stash ?|
|---|---|---|
|`git stash apply`|Applique les modifications|✅ Oui|
|`git stash pop`|Applique les modifications|❌ Non (supprime automatiquement)|

### git stash pop

```bash
# Pop le stash le plus récent (stash@{0})
git stash pop

# Pop un stash spécifique
git stash pop stash@{2}
```

**Comportement** :

1. Applique les modifications du stash
2. Si succès → supprime automatiquement le stash
3. Si conflit → conserve le stash (vous devez le supprimer manuellement après résolution)

> [!example] Workflow typique avec pop
> 
> ```bash
> # Vous êtes sur feature/login avec des modifications
> git stash -m "Auth logic in progress"
> 
> # Changement de branche pour un hotfix
> git checkout main
> # ... corrections et commit ...
> 
> # Retour sur la branche
> git checkout feature/login
> git stash pop  # Récupère ET supprime le stash
> ```

### git stash apply

```bash
# Apply le stash le plus récent
git stash apply

# Apply un stash spécifique
git stash apply stash@{1}
```

**Comportement** :

1. Applique les modifications du stash
2. **Conserve** le stash dans la liste

> [!tip] Quand utiliser apply plutôt que pop ?
> 
> - Vous voulez appliquer le même stash sur **plusieurs branches**
> - Vous voulez être **prudent** et garder une copie de sauvegarde
> - Vous faites des **tests** et voulez pouvoir revenir en arrière

### 🎯 Appliquer un stash sur une branche différente

```bash
# Créer une nouvelle branche ET appliquer un stash
git stash branch nouvelle-branche stash@{0}
```

Cette commande :

1. Crée une nouvelle branche depuis le commit où le stash a été créé
2. Applique le stash
3. Supprime le stash si l'application réussit

### ⚠️ Gestion des conflits

Lors de l'application d'un stash, des conflits peuvent survenir :

```bash
$ git stash pop
Auto-merging src/auth.js
CONFLICT (content): Merge conflict in src/auth.js
The stash entry is kept in case you need it again.
```

**Résolution** :

```bash
# 1. Ouvrir les fichiers en conflit et résoudre
# 2. Ajouter les fichiers résolus
git add src/auth.js

# 3. Pas besoin de commit ! Les modifications sont dans le working directory
# 4. Supprimer le stash manuellement si vous avez utilisé pop
git stash drop stash@{0}
```

> [!warning] Le stash n'est PAS supprimé en cas de conflit Si `git stash pop` rencontre un conflit, le stash est **conservé** pour que vous puissiez réessayer. Pensez à le supprimer manuellement après résolution.

### Options utiles pour apply/pop

#### Conserver l'index (staging area)

```bash
git stash pop --index
```

Sans `--index`, toutes les modifications sont remises dans le working directory (unstaged).  
Avec `--index`, les fichiers qui étaient staged le redeviennent.

```bash
# Avant le stash
$ git status
Changes to be committed:
  modified:   file1.js
Changes not staged for commit:
  modified:   file2.js

# Après git stash pop --index
# file1.js sera staged, file2.js sera unstaged
```

---

## git stash drop - Supprimer un stash

### Syntaxe

```bash
# Supprimer le stash le plus récent
git stash drop

# Supprimer un stash spécifique
git stash drop stash@{2}
```

### 🗑️ Supprimer tous les stashs

```bash
git stash clear
```

> [!warning] Danger : Action irréversible ! `git stash clear` supprime **définitivement** tous vos stashs. Il n'y a pas de corbeille pour les récupérer. Utilisez avec précaution !

### Quand supprimer un stash ?

|Situation|Action recommandée|
|---|---|
|Stash appliqué avec succès via `pop`|Automatique ✅|
|Stash appliqué via `apply` et validé|`git stash drop` manuellement|
|Stash obsolète ou erroné|`git stash drop`|
|Nettoyage général|`git stash clear` (avec précaution)|

---

## Scénarios d'utilisation pratiques

### 🔥 Scénario 1 : Hotfix urgent

```bash
# Vous êtes en plein développement
$ git status
Modified: src/feature.js, src/components/Widget.js

# Un bug critique est signalé sur main !
$ git stash push -m "WIP: Feature X - halfway done"
Saved working directory and index state On feature/x: WIP: Feature X

# Changement vers main pour le fix
$ git checkout main
$ # ... correctifs et commit ...
$ git push origin main

# Retour sur votre travail
$ git checkout feature/x
$ git stash pop
```

### 🔄 Scénario 2 : Appliquer les mêmes modifications sur plusieurs branches

```bash
# Vous avez fait des améliorations CSS que vous voulez tester sur 2 branches
$ git stash push -m "New button styles"

# Tester sur la branche develop
$ git checkout develop
$ git stash apply  # On garde le stash
$ # ... tests ...
$ git reset --hard HEAD  # Annuler si non satisfait

# Tester sur la branche staging
$ git checkout staging
$ git stash apply  # On réutilise le même stash
$ # ... tests ...

# Satisfait ? Commit sur la bonne branche et supprimer le stash
$ git add .
$ git commit -m "Improve button styles"
$ git stash drop
```

### 🧪 Scénario 3 : Expérimentation rapide

```bash
# Vous voulez tester une idée sans perdre votre travail actuel
$ git stash push -m "Current progress"

# Expérimentation
$ # ... modifications de test ...

# Ça ne marche pas ? Retour en arrière
$ git reset --hard HEAD
$ git stash pop  # Récupérer le travail original
```

### 📦 Scénario 4 : Pull avec modifications locales

```bash
# Vous avez des modifications locales
$ git status
Modified: src/config.js

# Vous voulez faire un pull
$ git stash
$ git pull origin main
$ git stash pop

# Résoudre les conflits éventuels
```

---

## Pièges courants

### ❌ Piège 1 : Oublier les fichiers untracked

```bash
# Vous créez de nouveaux fichiers
$ touch newFeature.js
$ git stash  # ⚠️ newFeature.js N'EST PAS stashé !

# Solution
$ git stash -u  # ✅ Inclut les fichiers untracked
```

### ❌ Piège 2 : Confusion entre stash@{0} et stash@{1}

```bash
$ git stash list
stash@{0}: WIP on main: Fix A
stash@{1}: WIP on feature: Fix B

# Après un git stash pop :
$ git stash list
stash@{0}: WIP on feature: Fix B  # ⚠️ Les indices changent !
```

> [!warning] Renumérotation automatique Quand vous supprimez un stash, tous les indices sont renumérotés. Le stash@{1} devient stash@{0}.

### ❌ Piège 3 : Stash sur la mauvaise branche

```bash
# Vous faites un stash sur la branche A
$ git checkout branchA
$ git stash

# Vous changez de branche et pop
$ git checkout branchB
$ git stash pop  # ⚠️ Les modifications peuvent ne pas avoir de sens ici

# Solution : Vérifier d'où vient le stash
$ git stash list  # Regarder la branche d'origine
```

### ❌ Piège 4 : Oublier de drop après apply

```bash
$ git stash apply
$ git commit -m "Feature complete"
$ git stash list  # ⚠️ Le stash est toujours là !

# Nettoyage
$ git stash drop
```

### ❌ Piège 5 : Conflits non résolus avec pop

```bash
$ git stash pop
CONFLICT (content): Merge conflict in file.js
The stash entry is kept in case you need it again.

# ⚠️ Erreur : faire un autre pop sans résoudre
$ git stash pop  # Risque d'aggraver les conflits !

# ✅ Bonne pratique : résoudre d'abord
$ git add file.js
$ git stash drop stash@{0}
```

---

## Bonnes pratiques

### ✅ 1. Toujours nommer vos stashs

```bash
# ❌ Mauvais
$ git stash

# ✅ Bon
$ git stash push -m "Feature login: email validation in progress"
```

### ✅ 2. Nettoyer régulièrement vos stashs

```bash
# Vérifier tous les stashs et supprimer les obsolètes
$ git stash list
$ git stash drop stash@{3}
$ git stash drop stash@{5}
```

### ✅ 3. Préférer pop à apply pour un usage simple

```bash
# Si vous savez que vous n'aurez plus besoin du stash
$ git stash pop  # Plus simple, auto-nettoyage
```

### ✅ 4. Utiliser apply pour des réutilisations

```bash
# Si vous voulez appliquer le même stash plusieurs fois
$ git stash apply
# ... tests ...
$ git stash apply  # Réappliquer si besoin
```

### ✅ 5. Vérifier avant de clear

```bash
# ❌ Dangereux sans vérification
$ git stash clear

# ✅ Vérifier d'abord
$ git stash list
$ git stash show -p stash@{0}  # Vérifier le contenu
$ git stash clear  # OK si sûr
```

### ✅ 6. Utiliser stash branch pour les gros changements

```bash
# Si votre stash contient beaucoup de modifications
$ git stash branch feature/new-experiment stash@{0}
# Crée une branche dédiée avec le stash appliqué
```

### ✅ 7. Documenter les stashs complexes

```bash
# Pour des stashs importants, ajouter des détails
$ git stash push -m "API refactor: step 2/5 - middleware extraction. 
> Need to test before continuing. Related to ticket #234"
```

### ✅ 8. Stash atomique

```bash
# Stasher des modifications liées ensemble
$ git stash push -m "Auth system" src/auth/ src/middleware/auth.js

# Plutôt que tout stasher en une fois
```

---

## 📚 Récapitulatif des commandes

|Commande|Description|Supprime le stash ?|
|---|---|---|
|`git stash`|Sauvegarder les modifications|Non|
|`git stash -u`|Sauvegarder avec fichiers untracked|Non|
|`git stash push -m "msg"`|Sauvegarder avec message|Non|
|`git stash list`|Lister tous les stashs|Non|
|`git stash show stash@{n}`|Voir le contenu d'un stash|Non|
|`git stash apply`|Appliquer le dernier stash|Non|
|`git stash apply stash@{n}`|Appliquer un stash spécifique|Non|
|`git stash pop`|Appliquer et supprimer le dernier stash|Oui|
|`git stash pop stash@{n}`|Appliquer et supprimer un stash spécifique|Oui|
|`git stash drop`|Supprimer le dernier stash|Oui|
|`git stash drop stash@{n}`|Supprimer un stash spécifique|Oui|
|`git stash clear`|Supprimer TOUS les stashs|Oui|
|`git stash branch nom`|Créer une branche avec un stash|Oui|

> [!tip] Mnémotechnique
> 
> - **push** = mettre de côté (dans le tiroir)
> - **pop** = sortir et jeter (du tiroir)
> - **apply** = copier (garder dans le tiroir)
> - **drop** = jeter (vider le tiroir)

---

🎉 Vous maîtrisez maintenant le stash Git ! Cette fonctionnalité est un outil puissant pour gérer votre workflow de développement avec flexibilité.