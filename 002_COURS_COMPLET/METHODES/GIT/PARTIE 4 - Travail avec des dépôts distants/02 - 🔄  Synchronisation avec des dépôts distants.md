

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

## Introduction à la synchronisation

La synchronisation est le processus qui permet de maintenir votre dépôt local en cohérence avec un ou plusieurs dépôts distants. C'est le cœur du travail collaboratif avec Git.

> [!info] Concepts clés
> 
> - **Dépôt distant** : Version du projet hébergée sur un serveur (GitHub, GitLab, etc.)
> - **Dépôt local** : Votre copie du projet sur votre machine
> - **Branches de suivi** : Branches locales qui suivent l'état des branches distantes

---

## 🔽 git fetch

### Qu'est-ce que git fetch ?

`git fetch` télécharge les modifications du dépôt distant **sans les fusionner** avec votre travail local. C'est une opération "sûre" qui met à jour vos références distantes.

### Pourquoi l'utiliser ?

- **Sécurité** : Vous pouvez examiner les changements avant de les intégrer
- **Contrôle** : Vous décidez quand et comment fusionner
- **Inspection** : Idéal pour voir ce que les autres ont fait sans modifier votre code

### Syntaxe et utilisation

```bash
# Récupérer toutes les branches de tous les dépôts distants
git fetch --all

# Récupérer uniquement depuis origin (dépôt par défaut)
git fetch origin

# Récupérer une branche spécifique
git fetch origin nom-de-branche

# Récupérer et supprimer les références obsolètes
git fetch --prune

# Voir ce qui a été récupéré (sans modification locale)
git fetch -v
```

> [!example] Exemple pratique
> 
> ```bash
> # Récupérer les modifications
> git fetch origin
> 
> # Voir les différences avec votre branche actuelle
> git log HEAD..origin/main
> 
> # Examiner les changements
> git diff HEAD origin/main
> 
> # Si tout est ok, fusionner
> git merge origin/main
> ```

### Que se passe-t-il en coulisses ?

1. Git contacte le serveur distant
2. Télécharge les nouveaux commits, fichiers et références
3. Met à jour les branches distantes locales (`origin/main`, `origin/develop`, etc.)
4. **Ne touche pas** à vos branches locales ni à votre répertoire de travail

> [!tip] Bonne pratique Utilisez `git fetch` régulièrement pour rester informé des changements sans perturber votre travail en cours.

---

## 🔽 git pull

### Qu'est-ce que git pull ?

`git pull` est une commande combinée qui effectue `git fetch` suivi de `git merge` (ou `git rebase` selon la configuration). Elle télécharge ET intègre les modifications en une seule commande.

### Pourquoi l'utiliser ?

- **Rapidité** : Mise à jour en une seule commande
- **Simplicité** : Idéal quand vous savez que vous voulez intégrer les changements
- **Flux de travail courant** : Commande standard au début d'une session de travail

### Syntaxe et utilisation

```bash
# Pull depuis la branche de suivi par défaut
git pull

# Pull depuis un dépôt et une branche spécifiques
git pull origin main

# Pull avec rebase au lieu de merge
git pull --rebase

# Pull et supprimer les références obsolètes
git pull --prune

# Pull en mode fast-forward uniquement (échoue si merge nécessaire)
git pull --ff-only
```

> [!warning] Attention `git pull` peut créer des commits de merge automatiques si votre branche locale a divergé de la branche distante. Cela peut "polluer" l'historique.

### Options importantes

|Option|Description|Quand l'utiliser|
|---|---|---|
|`--rebase`|Rejoue vos commits par-dessus les nouveaux|Pour un historique linéaire|
|`--ff-only`|Accepte uniquement les fast-forward|Pour éviter les merges automatiques|
|`--no-commit`|Effectue le merge sans créer le commit|Pour vérifier avant de valider|
|`--verbose`|Affiche plus de détails|Pour comprendre ce qui se passe|

> [!example] Exemple : workflow quotidien
> 
> ```bash
> # En arrivant le matin
> git pull --rebase origin main
> 
> # Travailler sur votre code...
> git add .
> git commit -m "Mes modifications"
> 
> # Avant de pousser, se resynchroniser
> git pull --rebase origin main
> git push
> ```

### Configuration recommandée

```bash
# Configurer pull pour toujours faire un rebase
git config --global pull.rebase true

# Ou seulement pour le dépôt actuel
git config pull.rebase true
```

---

## 🔼 git push

### Qu'est-ce que git push ?

`git push` envoie vos commits locaux vers le dépôt distant. C'est la commande qui "publie" votre travail pour le rendre accessible aux autres.

### Pourquoi l'utiliser ?

- **Partage** : Rendre votre code accessible à l'équipe
- **Sauvegarde** : Sécuriser votre travail sur un serveur distant
- **Collaboration** : Permettre les reviews et l'intégration continue

### Syntaxe et utilisation

```bash
# Push vers la branche de suivi par défaut
git push

# Push vers un dépôt et une branche spécifiques
git push origin main

# Push et créer la branche distante si elle n'existe pas
git push -u origin nouvelle-branche
# ou
git push --set-upstream origin nouvelle-branche

# Push toutes les branches
git push --all

# Push tous les tags
git push --tags

# Supprimer une branche distante
git push origin --delete nom-de-branche
```

> [!info] L'option -u (--set-upstream) Crée un lien de suivi entre votre branche locale et la branche distante. Après cette commande, un simple `git push` suffira.

### Que se passe-t-il en cas de conflit ?

Si quelqu'un a poussé avant vous, Git refusera votre push :

```bash
$ git push
To github.com:user/repo.git
 ! [rejected]        main -> main (fetch first)
error: failed to push some refs
```

**Solution :**

```bash
# 1. Récupérer les modifications
git pull --rebase origin main

# 2. Résoudre les conflits si nécessaire

# 3. Pousser à nouveau
git push
```

> [!warning] Ne jamais forcer sans raison `git push --force` peut écraser le travail des autres. À utiliser avec une extrême prudence.

---

## 🔀 Différence entre fetch et pull

### Comparaison visuelle

```
git fetch :
Distant  →  Refs distantes locales (origin/main)
            ↓
            Votre branche locale (main) ← INCHANGÉE

git pull :
Distant  →  Refs distantes locales (origin/main)
            ↓
            Votre branche locale (main) ← MODIFIÉE (merge/rebase)
```

### Tableau comparatif

|Critère|git fetch|git pull|
|---|---|---|
|**Télécharge les données**|✅ Oui|✅ Oui|
|**Modifie la branche locale**|❌ Non|✅ Oui|
|**Risque de conflits**|❌ Aucun|✅ Possible|
|**Permet l'inspection**|✅ Oui|❌ Non|
|**Crée des commits**|❌ Non|✅ Peut créer des merges|
|**Rapidité d'exécution**|⚡ Rapide|⚡ Rapide|
|**Sécurité**|🛡️ Très sûr|⚠️ Moins sûr|

### Quand utiliser quoi ?

> [!tip] Utiliser git fetch quand...
> 
> - Vous voulez voir ce qui a changé avant d'intégrer
> - Vous travaillez sur quelque chose d'important et ne voulez pas être interrompu
> - Vous voulez comparer votre travail avec celui des autres
> - Vous êtes sur une branche expérimentale

> [!tip] Utiliser git pull quand...
> 
> - Vous démarrez une nouvelle session de travail
> - Vous savez que vous voulez les dernières modifications
> - Vous êtes sur une branche stable (main, develop)
> - Vous faites confiance aux modifications distantes

### Workflow recommandé

```bash
# Approche prudente (recommandée)
git fetch origin
git log HEAD..origin/main  # Voir ce qui arrive
git diff HEAD origin/main  # Voir les changements
git merge origin/main      # Intégrer si tout est ok

# Approche rapide (si confiant)
git pull --rebase origin main
```

---

## ⚡ Options avancées de push

### --force : La force brute

```bash
git push --force origin main
```

> [!warning] Danger ! `--force` écrase l'historique distant avec votre historique local. Cela peut **détruire définitivement le travail des autres**.

**Quand l'utiliser (rarement) :**

- Vous êtes seul sur la branche
- Vous avez fait un rebase et devez mettre à jour le distant
- Vous avez l'accord explicite de l'équipe

**Conséquences :**

- Les commits distants qui ne sont pas dans votre historique sont perdus
- Les autres développeurs auront des conflits majeurs
- Peut casser les builds et les déploiements en cours

### --force-with-lease : La force intelligente

```bash
git push --force-with-lease origin main
```

> [!tip] Meilleure alternative à --force Cette option vérifie que personne n'a poussé depuis votre dernier fetch. Si c'est le cas, le push est rejeté.

**Avantages :**

- Protection contre l'écrasement accidentel du travail des autres
- Sécurité supplémentaire lors d'un rebase
- Permet de forcer tout en restant prudent

**Syntaxe détaillée :**

```bash
# Force avec vérification de la référence distante
git push --force-with-lease origin main

# Spécifier la valeur attendue
git push --force-with-lease=main:origin/main origin main

# Avec mise à jour automatique des références
git fetch origin
git push --force-with-lease origin main
```

### Comparaison des options de force

|Option|Vérification|Sécurité|Usage|
|---|---|---|---|
|`push` (normal)|✅ Complète|🛡️ Très sûr|Usage quotidien|
|`--force-with-lease`|⚠️ Partielle|🛡️ Assez sûr|Après rebase|
|`--force`|❌ Aucune|⚠️ Dangereux|Urgence uniquement|

> [!example] Workflow sécurisé avec rebase
> 
> ```bash
> # 1. Mettre à jour les références
> git fetch origin
> 
> # 2. Rebaser votre branche
> git rebase origin/main
> 
> # 3. Pousser avec protection
> git push --force-with-lease origin ma-feature
> ```

### Autres options utiles de push

```bash
# Push avec vérification des hooks côté serveur
git push --no-verify

# Push en mode dry-run (simulation)
git push --dry-run origin main

# Push avec progression détaillée
git push --progress origin main

# Push avec atomic (tout ou rien)
git push --atomic origin main feature
```

---

## ⚠️ Pièges courants

### 1. Pull sans commit des modifications locales

> [!warning] Problème
> 
> ```bash
> $ git pull
> error: Your local changes would be overwritten by merge.
> Please commit your changes or stash them before you merge.
> ```

**Solution :**

```bash
# Option 1 : Sauvegarder temporairement
git stash
git pull
git stash pop

# Option 2 : Committer avant
git add .
git commit -m "WIP: travail en cours"
git pull
```

### 2. Historique divergent après un pull

> [!warning] Problème Le `git pull` crée un commit de merge à chaque synchronisation, polluant l'historique.

**Solution :**

```bash
# Utiliser rebase au lieu de merge
git pull --rebase origin main

# Ou configurer globalement
git config --global pull.rebase true
```

### 3. Push rejeté après un rebase

> [!warning] Problème Après un rebase, `git push` est rejeté car l'historique a changé.

**Solution :**

```bash
# Utiliser force-with-lease (JAMAIS sur main/develop partagés)
git push --force-with-lease origin ma-feature
```

### 4. Oublier de pousser régulièrement

> [!tip] Bonne pratique Poussez votre travail au moins une fois par jour pour :
> 
> - Sauvegarder votre code
> - Permettre les code reviews
> - Éviter de grosses divergences

### 5. Force push sur une branche partagée

> [!warning] Ne JAMAIS faire
> 
> ```bash
> # ❌ DANGEREUX sur main, develop, release
> git push --force origin main
> ```

**Règle d'or :** Pas de force push sur les branches partagées principales.

### 6. Fetch sans merge créant de la confusion

```bash
# Vous faites fetch
git fetch origin

# Votre branche semble à jour
git status
# "Your branch is up to date with 'origin/main'"

# Mais en réalité, origin/main a avancé !
git log HEAD..origin/main  # Montre des commits
```

**Comprendre :** `git status` compare votre branche avec votre **référence locale** de origin/main, pas avec le serveur réel.

---

## 🎯 Bonnes pratiques de synchronisation

> [!tip] Workflow recommandé quotidien
> 
> ```bash
> # 1. Matin : récupérer les nouveautés
> git fetch --all --prune
> git pull --rebase origin main
> 
> # 2. Travailler...
> 
> # 3. Avant de pousser : se resynchroniser
> git fetch origin
> git rebase origin/main  # Si sur une feature branch
> git push
> 
> # 4. Nettoyer les branches obsolètes
> git fetch --prune
> ```

> [!tip] Astuce : alias Git utiles
> 
> ```bash
> # Ajouter à ~/.gitconfig
> [alias]
>   sync = !git fetch --all --prune && git pull --rebase
>   pushf = push --force-with-lease
>   up = pull --rebase --autostash
> ```

---

## 📊 Récapitulatif des commandes

|Commande|Action|Modifie le local|Risque|
|---|---|---|---|
|`git fetch`|Télécharge|❌ Non|Aucun|
|`git pull`|Télécharge + Merge|✅ Oui|Faible|
|`git pull --rebase`|Télécharge + Rebase|✅ Oui|Moyen|
|`git push`|Envoie|❌ Non|Faible|
|`git push --force`|Envoie (écrase)|❌ Non|⚠️ Élevé|
|`git push --force-with-lease`|Envoie (protégé)|❌ Non|Moyen|

---

**La synchronisation avec Git, c'est l'art de maintenir l'harmonie entre votre travail local et celui de votre équipe. Maîtrisez fetch, pull et push, et vous maîtrisez la collaboration !** 🚀