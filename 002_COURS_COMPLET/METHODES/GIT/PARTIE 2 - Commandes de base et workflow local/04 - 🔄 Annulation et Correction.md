

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

L'une des grandes forces de Git est sa capacité à annuler ou corriger des erreurs. Que vous ayez modifié un fichier par accident, créé un mauvais commit, ou besoin de revenir en arrière dans l'historique, Git offre plusieurs commandes adaptées à chaque situation.

> [!warning] Attention Certaines opérations d'annulation peuvent être destructives et irréversibles. Assurez-vous de bien comprendre ce que fait chaque commande avant de l'exécuter, surtout sur des branches partagées.

---

## git restore

### 📖 Qu'est-ce que `git restore` ?

`git restore` est une commande moderne (introduite dans Git 2.23) dédiée à la restauration de fichiers. Elle remplace les anciens usages de `git checkout` pour manipuler des fichiers, rendant les opérations plus explicites et sécurisées.

### 🎯 Quand l'utiliser ?

- Annuler des modifications locales non commitées
- Restaurer un fichier depuis le staging area
- Récupérer une version antérieure d'un fichier

### 📝 Syntaxe et exemples

#### Restaurer un fichier modifié (working directory)

```bash
# Annuler les modifications d'un fichier non stagé
git restore fichier.txt

# Annuler les modifications de plusieurs fichiers
git restore fichier1.txt fichier2.txt

# Annuler toutes les modifications non stagées
git restore .
```

> [!info] Explication Cette commande restaure le fichier à l'état du dernier commit (HEAD). Toutes les modifications locales sont perdues.

#### Restaurer un fichier depuis le staging area

```bash
# Retirer un fichier du staging area (unstage)
git restore --staged fichier.txt

# Retirer tous les fichiers du staging area
git restore --staged .
```

> [!example] Exemple pratique Vous avez fait `git add fichier.txt` par erreur et voulez le retirer de la zone de staging sans perdre vos modifications :
> 
> ```bash
> git restore --staged fichier.txt
> # Le fichier est maintenant "unstaged" mais vos modifications sont conservées
> ```

#### Restaurer depuis un commit spécifique

```bash
# Restaurer un fichier depuis un commit précis
git restore --source=HEAD~2 fichier.txt

# Restaurer depuis un commit par son hash
git restore --source=abc1234 fichier.txt

# Restaurer depuis une branche
git restore --source=main fichier.txt
```

#### Restaurer un fichier du staging ET du working directory

```bash
# Annuler complètement les modifications (staged + unstaged)
git restore --staged --worktree fichier.txt

# Raccourci équivalent
git restore -SW fichier.txt
```

### ⚠️ Pièges courants

1. **Perte de données** : `git restore` sans `--staged` écrase vos modifications locales de façon irréversible
2. **Confusion avec checkout** : Ne pas confondre avec `git checkout` qui peut aussi changer de branche
3. **Fichiers non trackés** : `git restore` n'affecte pas les fichiers non trackés par Git

> [!tip] Astuce Avant d'utiliser `git restore` sur des modifications importantes, utilisez `git stash` pour créer une sauvegarde temporaire :
> 
> ```bash
> git stash push -m "Sauvegarde avant restore"
> git restore fichier.txt
> # Si besoin, récupérez avec : git stash pop
> ```

### ✅ Bonnes pratiques

- Utilisez `git status` avant pour voir l'état des fichiers
- Vérifiez avec `git diff` ce que vous allez perdre
- Pour les fichiers critiques, faites une copie manuelle avant
- Préférez `git restore --staged` à `git reset` pour unstage

---

## git reset

### 📖 Qu'est-ce que `git reset` ?

`git reset` est une commande puissante qui déplace le pointeur de la branche courante (HEAD) vers un commit spécifique. Elle peut également modifier le staging area et le working directory selon le mode utilisé.

### 🎯 Quand l'utiliser ?

- Annuler des commits locaux non poussés
- Réorganiser l'historique local
- Unstage des fichiers (mode soft)
- Réinitialiser complètement l'état du projet

### 📝 Les trois modes de reset

Git reset fonctionne avec trois modes principaux qui déterminent ce qui est affecté :

|Mode|HEAD|Staging Area|Working Directory|
|---|---|---|---|
|`--soft`|✅ Déplacé|❌ Inchangé|❌ Inchangé|
|`--mixed` (défaut)|✅ Déplacé|✅ Réinitialisé|❌ Inchangé|
|`--hard`|✅ Déplacé|✅ Réinitialisé|✅ Réinitialisé|

#### Mode `--soft` : Le plus sûr

```bash
# Annuler le dernier commit en gardant les modifications stagées
git reset --soft HEAD~1

# Annuler les 3 derniers commits
git reset --soft HEAD~3

# Revenir à un commit spécifique
git reset --soft abc1234
```

> [!info] Utilité du mode soft Ce mode est idéal pour "défaire" un commit tout en gardant toutes les modifications prêtes à être recommitées. Parfait pour refaire un commit avec un meilleur message ou en incluant d'autres modifications.

> [!example] Exemple d'usage
> 
> ```bash
> # Vous avez commité trop tôt
> git commit -m "Feature incomplete"
> 
> # Annulez le commit mais gardez les modifications
> git reset --soft HEAD~1
> 
> # Ajoutez d'autres fichiers et recommitez
> git add autres_fichiers.txt
> git commit -m "Feature complete"
> ```

#### Mode `--mixed` : Le mode par défaut

```bash
# Annuler le dernier commit et unstage les modifications
git reset HEAD~1
# Équivalent à :
git reset --mixed HEAD~1

# Unstage tous les fichiers (sans toucher aux commits)
git reset

# Unstage un fichier spécifique
git reset fichier.txt
```

> [!info] Comportement du mode mixed Les modifications sont conservées dans votre working directory mais retirées du staging area. Vous devrez refaire `git add` avant de commiter à nouveau.

#### Mode `--hard` : Le plus dangereux ⚠️

```bash
# ATTENTION : Supprime définitivement les modifications locales !
git reset --hard HEAD~1

# Réinitialiser complètement au dernier commit
git reset --hard HEAD

# Réinitialiser à un commit spécifique
git reset --hard abc1234

# Synchroniser avec l'état distant (après un fetch)
git reset --hard origin/main
```

> [!warning] Danger ! `git reset --hard` supprime DÉFINITIVEMENT toutes vos modifications non commitées. Cette action est IRRÉVERSIBLE (sauf si vous avez un stash ou un reflog).

### 📝 Syntaxe avancée

```bash
# Reset relatif au HEAD
git reset HEAD~1      # 1 commit en arrière
git reset HEAD~5      # 5 commits en arrière
git reset HEAD^^      # 2 commits en arrière (notation alternative)

# Reset vers un commit spécifique
git reset abc1234     # Par hash
git reset main        # Vers une branche
git reset origin/main # Vers une branche distante

# Reset d'un fichier spécifique (toujours en mode mixed)
git reset HEAD fichier.txt
git reset abc1234 fichier.txt
```

### ⚠️ Pièges courants

1. **Reset sur une branche publique** : Ne jamais faire `git reset` sur des commits déjà poussés et partagés avec d'autres
2. **Confusion entre les modes** : `--hard` est destructif, `--soft` est sûr, `--mixed` est entre les deux
3. **Perte du reflog** : Même avec `--hard`, les commits sont récupérables via le reflog pendant ~30 jours
4. **Reset d'un fichier** : `git reset fichier.txt` ne fonctionne qu'en mode mixed, ignorant `--soft` et `--hard`

> [!tip] Récupération après un reset --hard Si vous avez fait un `git reset --hard` par erreur, vous pouvez souvent récupérer grâce au reflog :
> 
> ```bash
> # Voir l'historique des déplacements de HEAD
> git reflog
> 
> # Retrouver le hash du commit perdu (ex: abc1234)
> git reset --hard abc1234
> ```

### ✅ Bonnes pratiques

- **Jamais de reset sur des branches partagées** : Utilisez `git revert` à la place
- **Vérifiez avant** : `git log --oneline` pour voir où vous allez atterrir
- **Sauvegardez d'abord** : Créez une branche temporaire avant un reset risqué
    
    ```bash
    git branch backup-avant-resetgit reset --hard HEAD~3
    ```
    
- **Préférez --soft pour défaire des commits** : Plus sûr et réversible
- **Utilisez --hard avec parcimonie** : Seulement quand vous êtes sûr de vouloir tout supprimer

---

## git revert

### 📖 Qu'est-ce que `git revert` ?

`git revert` crée un **nouveau commit** qui annule les modifications d'un commit précédent. Contrairement à `git reset`, il ne réécrit pas l'historique mais ajoute un commit d'annulation.

### 🎯 Quand l'utiliser ?

- Annuler un commit sur une branche publique/partagée
- Garder une trace de l'annulation dans l'historique
- Annuler des changements sans réécrire l'historique

> [!info] Différence clé avec reset `git revert` est "safe" pour les branches partagées car il ne modifie pas l'historique existant, il l'étend avec un commit d'annulation.

### 📝 Syntaxe et exemples

#### Revert basique

```bash
# Annuler le dernier commit
git revert HEAD

# Annuler un commit spécifique
git revert abc1234

# Annuler l'avant-dernier commit
git revert HEAD~1
```

> [!example] Processus typique
> 
> ```bash
> # Votre historique
> A -- B -- C -- D (HEAD)
> 
> # Après git revert C
> A -- B -- C -- D -- D' (HEAD)
> # D' est un nouveau commit qui annule les changements de C
> ```

#### Revert sans créer de commit automatiquement

```bash
# Appliquer l'annulation sans commiter
git revert --no-commit abc1234

# Annuler plusieurs commits sans commiter
git revert --no-commit HEAD~3..HEAD

# Puis vous commitez manuellement
git commit -m "Revert des 3 derniers commits"
```

> [!info] Utilité de --no-commit Permet d'annuler plusieurs commits et de créer un seul commit de revert global, ou de modifier les changements avant de commiter.

#### Revert d'une plage de commits

```bash
# Revert de plusieurs commits consécutifs
git revert HEAD~3..HEAD

# Revert d'un commit à un autre (non inclusif du premier)
git revert abc1234..def5678

# Revert d'un commit à un autre (inclusif)
git revert abc1234^..def5678
```

#### Revert d'un merge commit

```bash
# Revert d'un merge en spécifiant le parent
git revert -m 1 abc1234

# -m 1 signifie : garder le premier parent (la branche principale)
# -m 2 signifie : garder le deuxième parent (la branche mergée)
```

> [!warning] Complexité des merge reverts Reverter un merge est plus complexe car Git doit savoir vers quelle branche parente revenir. L'option `-m` est obligatoire pour les merges.

### 📝 Options utiles

```bash
# Revert avec édition du message de commit
git revert -e abc1234
git revert --edit abc1234  # Équivalent

# Revert sans éditer le message (utilise le message par défaut)
git revert --no-edit abc1234

# Continuer un revert après résolution de conflits
git revert --continue

# Abandonner un revert en cours
git revert --abort

# Ignorer un revert si conflit (skip)
git revert --skip
```

### ⚠️ Conflits lors du revert

Comme pour un merge, un revert peut créer des conflits :

```bash
# Tentative de revert
git revert abc1234

# Si conflit
# 1. Résoudre les conflits dans les fichiers
# 2. Ajouter les fichiers résolus
git add fichier_resolu.txt

# 3. Continuer le revert
git revert --continue

# OU annuler le revert
git revert --abort
```

> [!tip] Astuce pour les conflits Si vous revertez un ancien commit et que des conflits apparaissent, c'est souvent parce que le code a évolué depuis. Prenez le temps d'analyser si le revert a toujours du sens dans le contexte actuel.

### ⚠️ Pièges courants

1. **Revert d'un revert** : Si vous revertez un commit A, puis revertez le revert, vous ne retrouvez pas exactement l'état initial si d'autres commits sont entre-temps
2. **Ordre des reverts multiples** : Reverter plusieurs commits dans le mauvais ordre peut causer des conflits complexes
3. **Merge commits** : Oublier l'option `-m` lors du revert d'un merge
4. **Confusion avec reset** : Les deux font des choses opposées (ajout vs suppression d'historique)

### ✅ Bonnes pratiques

- **Utilisez revert pour les branches publiques** : C'est la méthode sûre pour annuler sur `main`, `develop`, etc.
- **Message de commit explicite** : Expliquez pourquoi vous revertez
    
    ```bash
    git revert abc1234 -m "Revert: bug critique en production"
    ```
    
- **Testez après le revert** : Un revert peut introduire des régressions inattendues
- **Préférez revert à reset après un push** : Maintient l'historique cohérent pour toute l'équipe
- **Documentation** : Référencez le commit original dans le message du revert

---

## git commit --amend

### 📖 Qu'est-ce que `git commit --amend` ?

`git commit --amend` permet de modifier le dernier commit en le "remplaçant" par un nouveau commit. C'est particulièrement utile pour corriger un message de commit ou ajouter des fichiers oubliés.

### 🎯 Quand l'utiliser ?

- Corriger le message du dernier commit
- Ajouter des fichiers oubliés au dernier commit
- Modifier les changements du dernier commit
- Changer l'auteur du dernier commit

> [!warning] Limitation importante `--amend` ne fonctionne QUE sur le dernier commit (HEAD). Pour modifier des commits plus anciens, vous devrez utiliser `git rebase -i` (hors scope de cette partie).

### 📝 Syntaxe et exemples

#### Modifier le message du dernier commit

```bash
# Ouvrir l'éditeur pour modifier le message
git commit --amend

# Modifier le message directement en ligne de commande
git commit --amend -m "Nouveau message corrigé"
```

> [!example] Exemple pratique
> 
> ```bash
> # Vous avez fait une faute de frappe
> git commit -m "Fix teh bug"
> 
> # Correction immédiate
> git commit --amend -m "Fix the bug"
> ```

#### Ajouter des fichiers oubliés

```bash
# Vous avez oublié un fichier dans le commit
git commit -m "Add feature"

# Oups, fichier oublié !
git add fichier_oublie.txt

# Amender le commit pour inclure le fichier
git commit --amend --no-edit
```

> [!info] Option --no-edit `--no-edit` garde le message de commit existant, utile quand vous voulez juste ajouter des fichiers sans changer le message.

#### Modifier les changements du dernier commit

```bash
# Commit initial
git add fichier1.txt
git commit -m "Update files"

# Modification supplémentaire
# Éditer fichier1.txt ou ajouter fichier2.txt
git add fichier1.txt fichier2.txt

# Intégrer dans le commit précédent
git commit --amend --no-edit
```

#### Modifier l'auteur du commit

```bash
# Changer l'auteur du dernier commit
git commit --amend --author="John Doe <john@example.com>"

# Utiliser la configuration Git actuelle
git commit --amend --reset-author
```

### 📝 Options utiles

```bash
# Amend sans ouvrir l'éditeur (garde le message actuel)
git commit --amend --no-edit

# Amend et modifier le message en une seule commande
git commit --amend -m "Nouveau message"

# Amend avec édition du message dans l'éditeur
git commit --amend -e
git commit --amend --edit  # Équivalent

# Amend en changeant la date du commit
git commit --amend --date="2024-01-15 14:30:00"

# Amend en mode verbose (montre le diff dans l'éditeur)
git commit --amend -v
```

### 📝 Workflow complet

Voici un workflow typique d'utilisation de `--amend` :

```bash
# 1. Commit initial
git add fichier1.txt
git commit -m "Add new feature"

# 2. Vous réalisez qu'il manque quelque chose
#    - Message de commit incomplet
#    - Fichier oublié
#    - Petite correction à faire

# 3. Faire les modifications nécessaires
git add fichier_oublie.txt
# OU éditer fichier1.txt puis : git add fichier1.txt

# 4. Amender le commit
git commit --amend
# OU si pas besoin de changer le message :
git commit --amend --no-edit

# 5. Résultat : un seul commit propre au lieu de deux
```

### ⚠️ Pièges courants

1. **Amend sur un commit déjà pushé** : Change l'historique et crée des conflits pour les autres développeurs
2. **Amend de plusieurs commits** : Impossible, `--amend` ne fonctionne que sur HEAD
3. **Perte du commit original** : L'ancien commit est remplacé (mais reste dans le reflog temporairement)
4. **Oublier --no-edit** : L'éditeur s'ouvre alors que vous vouliez juste ajouter un fichier

> [!warning] Danger avec les commits pushés Si vous avez déjà pushé le commit et que vous l'amendez, vous devrez faire un `git push --force`, ce qui peut causer des problèmes pour vos collègues. Règle d'or : **ne jamais amender un commit pushé sur une branche partagée**.

### 📝 Amend après un push (cas particulier)

```bash
# Situation : Vous avez amendé un commit déjà pushé
git commit --amend -m "Fixed message"

# Option 1 : Force push (DANGEREUX sur branches partagées !)
git push --force

# Option 2 : Force push avec protection (recommandé)
git push --force-with-lease
# Échoue si quelqu'un d'autre a pushé entre-temps

# Option 3 : Créer un nouveau commit de correction (RECOMMANDÉ)
git reset --soft HEAD~1
git commit -m "Fixed message - correction"
git push
```

> [!tip] --force-with-lease `--force-with-lease` est plus sûr que `--force` car il vérifie que personne n'a pushé sur la branche depuis votre dernier fetch. Si quelqu'un a pushé, la commande échoue et vous évite d'écraser son travail.

### ✅ Bonnes pratiques

- **N'amendez que des commits locaux** : Avant le premier push
- **Vérifiez avec git log** : Confirmez que le commit a bien été amendé
    
    ```bash
    git log -1 --stat
    ```
    
- **Utilisez --no-edit quand approprié** : Évite d'ouvrir l'éditeur inutilement
- **Combinez avec git add -p** : Pour amender sélectivement certaines parties de fichiers
    
    ```bash
    git add -p fichier.txtgit commit --amend --no-edit
    ```
    
- **Alternative pour les commits pushés** : Créez un nouveau commit de correction plutôt que d'amender

---

## Comparaison des méthodes d'annulation

### 📊 Tableau comparatif

|Commande|Modifie l'historique ?|Cible|Usage principal|Sûr pour branches publiques ?|
|---|---|---|---|---|
|`git restore`|❌ Non|Fichiers (working dir / staging)|Annuler modifications locales|✅ Oui|
|`git reset --soft`|✅ Oui|Commits (garde modifications)|Refaire des commits locaux|❌ Non|
|`git reset --mixed`|✅ Oui|Commits + staging|Unstage et refaire commits|❌ Non|
|`git reset --hard`|✅ Oui|Commits + staging + fichiers|Réinitialisation complète|❌ Non|
|`git revert`|❌ Non (ajoute)|Commits (crée nouveau commit)|Annuler sur branches publiques|✅ Oui|
|`git commit --amend`|✅ Oui|Dernier commit uniquement|Corriger dernier commit|❌ Non (sauf local)|

### 🎯 Arbre de décision

```
Avez-vous déjà pushé le(s) commit(s) ?
│
├─ OUI → Branche publique/partagée
│   │
│   ├─ Annuler un commit → git revert
│   │
│   └─ Modifier dernier commit → Créer nouveau commit
│       (N'utilisez PAS --amend ou reset)
│
└─ NON → Commits locaux uniquement
    │
    ├─ Modifications dans fichiers non commités
    │   │
    │   ├─ Annuler modifications → git restore fichier.txt
    │   │
    │   └─ Unstage fichier → git restore --staged fichier.txt
    │
    ├─ Modifier le dernier commit
    │   │
    │   ├─ Changer message → git commit --amend
    │   │
    │   └─ Ajouter fichiers → git add + git commit --amend --no-edit
    │
    └─ Annuler plusieurs commits
        │
        ├─ Garder modifications → git reset --soft HEAD~n
        │
        ├─ Recommencer modifications → git reset --mixed HEAD~n
        │
        └─ Supprimer tout → git reset --hard HEAD~n
```

### 📝 Cas d'usage détaillés

#### Scénario 1 : Fichier modifié par erreur (non stagé)

```bash
# Problème : Modification accidentelle de config.json
git status
# modified: config.json

# Solution
git restore config.json
```

#### Scénario 2 : Fichier ajouté au staging par erreur

```bash
# Problème : git add du mauvais fichier
git add secret.txt
git status
# Changes to be committed: new file: secret.txt

# Solution
git restore --staged secret.txt
```

#### Scénario 3 : Dernier commit incomplet (local)

```bash
# Problème : Commit sans un fichier important
git commit -m "Add feature"
# Oups, j'ai oublié utils.js !

# Solution
git add utils.js
git commit --amend --no-edit
```

#### Scénario 4 : Mauvais message de commit (local)

```bash
# Problème : Faute de frappe dans le message
git commit -m "Fix teh bug in auth"

# Solution
git commit --amend -m "Fix the bug in auth"
```

#### Scénario 5 : Annuler les 3 derniers commits (local)

```bash
# Problème : Les 3 derniers commits sont mauvais
# Mais vous voulez garder les modifications

# Solution
git reset --soft HEAD~3
# Puis refaire un commit propre
git commit -m "Feature complète et fonctionnelle"
```

#### Scénario 6 : Annuler un commit (branche publique)

```bash
# Problème : Un commit cassé a été pushé sur main
git log --oneline
# abc1234 Broken feature
# def5678 Previous commit

# Solution : Revert (pas reset !)
git revert abc1234
git push origin main
```

#### Scénario 7 : Réinitialiser complètement à origin/main

```bash
# Problème : Votre branche locale est dans un état bizarre
# Vous voulez exactement l'état distant

# Solution
git fetch origin
git reset --hard origin/main
```

### ⚡ Récapitulatif rapide

> [!tip] Règle d'or
> 
> - **Commits locaux** : `reset` et `--amend` sont OK
> - **Commits pushés** : Utilisez uniquement `revert`
> - **Fichiers non commités** : Utilisez `restore`

> [!warning] Opérations destructives Ces commandes suppriment définitivement des données :
> 
> - `git restore` (sans --staged)
> - `git reset --hard`
> 
> Toujours vérifier avec `git status` et `git diff` avant !

### 🔄 Récupération d'urgence

Si vous avez fait une erreur avec reset ou restore :

```bash
# Voir l'historique de tous les déplacements de HEAD
git reflog

# Exemple de sortie :
# abc1234 HEAD@{0}: reset: moving to HEAD~3
# def5678 HEAD@{1}: commit: My commit
# ghi9012 HEAD@{2}: commit: Previous commit

# Récupérer un commit "perdu"
git reset --hard def5678
# OU créer une branche sur ce commit
git branch recovery def5678
```

> [!info] Le reflog Le reflog conserve l'historique de tous les mouvements de HEAD pendant environ 30 jours, même après un `git reset --hard`. C'est votre filet de sécurité !

---

## 🎓 Résumé

### Ce qu'il faut retenir

1. **`git restore`** : Pour les fichiers (working directory et staging area)
    
    - Sûr, moderne, explicite
    - N'affecte jamais l'historique des commits
2. **`git reset`** : Pour annuler des commits locaux
    
    - 3 modes : `--soft` (sûr), `--mixed` (défaut), `--hard` (dangereux)
    - Réécrit l'historique → jamais sur branches publiques
3. **`git revert`** : Pour annuler sur branches publiques
    
    - Crée un nouveau commit d'annulation
    - Préserve l'historique → sûr pour le travail collaboratif
4. **`git commit --amend`** : Pour corriger le dernier commit
    
    - Modification du message ou ajout de fichiers
    - Seulement avant le push (ou avec précaution après)

### Principe fondamental

> [!warning] Règle d'or de Git **Ne jamais réécrire l'historique d'une branche publique/partagée.**
> 
> Utilisez :
> 
> - `revert` pour annuler sur branches publiques
> - `reset` et `--amend` uniquement sur branches locales non pushées

---

_Fin de la partie "Annulation et correction" du cours Git_