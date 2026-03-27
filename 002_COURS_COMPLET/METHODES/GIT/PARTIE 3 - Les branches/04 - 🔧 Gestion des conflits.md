

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

## 🎯 Introduction

Les conflits Git surviennent lorsque deux branches ont modifié la même partie d'un fichier de manière différente. Git ne peut pas déterminer automatiquement quelle version conserver, et nécessite une intervention humaine pour résoudre le conflit.

> [!info] Quand surviennent les conflits ? Les conflits apparaissent principalement lors de :
> 
> - **Merge** : fusion de deux branches ayant des modifications divergentes
> - **Rebase** : réapplication de commits sur une nouvelle base
> - **Cherry-pick** : application d'un commit spécifique
> - **Pull** : récupération de modifications distantes qui entrent en conflit avec les modifications locales

---

## 🔍 Identifier un conflit

### Détection automatique

Lorsqu'un conflit survient lors d'un merge, Git vous en informe immédiatement :

```bash
# Tentative de fusion
git merge feature-branch

# Sortie en cas de conflit
Auto-merging fichier.txt
CONFLICT (content): Merge conflict in fichier.txt
Automatic merge failed; fix conflicts and then commit the result.
```

### Vérifier l'état des conflits

```bash
# Lister les fichiers en conflit
git status

# Sortie typique
On branch main
You have unmerged paths.
  (fix conflicts and run "git commit")
  (use "git merge --abort" to abort the merge)

Unmerged paths:
  (use "git add <file>..." to mark resolution)
        both modified:   fichier.txt
        both added:      nouveau.txt
```

### Types de conflits affichés

|État|Signification|
|---|---|
|`both modified`|Les deux branches ont modifié le même fichier|
|`both added`|Les deux branches ont ajouté un fichier avec le même nom|
|`deleted by us`|Vous avez supprimé un fichier modifié dans l'autre branche|
|`deleted by them`|L'autre branche a supprimé un fichier que vous avez modifié|

> [!warning] État du dépôt pendant un conflit Tant que les conflits ne sont pas résolus, vous êtes dans un état de merge incomplet. Vous ne pouvez pas effectuer d'autres merges ou certaines opérations Git.

### Commandes utiles pendant un conflit

```bash
# Voir les détails des conflits
git diff

# Voir uniquement les fichiers en conflit
git diff --name-only --diff-filter=U

# Afficher les commits impliqués
git log --merge --oneline

# Abandonner le merge en cours
git merge --abort

# Annuler le rebase en cours
git rebase --abort
```

---

## 🏷️ Marqueurs de conflit

### Structure des marqueurs

Lorsqu'un conflit survient, Git modifie le fichier en y insérant des marqueurs spéciaux pour délimiter les versions conflictuelles :

```bash
<<<<<<< HEAD
Version actuelle (votre branche)
=======
Version entrante (branche à fusionner)
>>>>>>> feature-branch
```

### Anatomie complète d'un conflit

```bash
<<<<<<< HEAD                    # Début de votre version (branche actuelle)
def calculer_prix(quantite):
    return quantite * 10
||||||| merged common ancestors  # Version commune (ancêtre commun) - optionnel
def calculer_prix(quantite):
    return quantite * 5
=======                          # Séparateur
def calculer_prix(quantite):
    return quantite * 15         # Version de la branche à fusionner
>>>>>>> feature-branch          # Fin du conflit
```

> [!info] Marqueur `merged common ancestors` Ce marqueur optionnel n'apparaît que si vous activez le style de conflit "diff3" :
> 
> ```bash
> git config --global merge.conflictstyle diff3
> ```
> 
> Il affiche la version originale avant que les deux branches ne divergent, ce qui aide à comprendre l'intention des modifications.

### Exemple réel complet

```python
# fichier: app.py

def traiter_commande(commande):
    # Code sans conflit
    total = 0
    
<<<<<<< HEAD
    # Calcul avec TVA à 20%
    for item in commande.items:
        total += item.prix * 1.20
    
    # Appliquer une réduction
    if commande.code_promo:
        total *= 0.9
||||||| merged common ancestors
    # Calcul simple
    for item in commande.items:
        total += item.prix
=======
    # Calcul avec TVA à 25% et frais de service
    for item in commande.items:
        total += item.prix * 1.25
    
    total += 5.00  # Frais de service
>>>>>>> feature-pricing
    
    return total  # Code sans conflit continue ici
```

### Types de marqueurs selon le contexte

|Commande|Marqueur HEAD|Marqueur opposé|
|---|---|---|
|`git merge`|`<<<<<<< HEAD`|`>>>>>>> branch-name`|
|`git rebase`|`<<<<<<< HEAD`|`>>>>>>> commit-hash`|
|`git cherry-pick`|`<<<<<<< HEAD`|`>>>>>>> commit-hash`|
|`git pull`|`<<<<<<< HEAD`|`>>>>>>> origin/branch`|

> [!tip] Rechercher tous les conflits Pour trouver rapidement tous les marqueurs de conflit dans votre projet :
> 
> ```bash
> # Rechercher les marqueurs de début
> git grep -n "<<<<<<< HEAD"
> 
> # Ou utiliser grep classique
> grep -r "<<<<<<< HEAD" .
> ```

### Déchiffrer les noms de branches

```bash
# Merge simple
<<<<<<< HEAD
=======
>>>>>>> feature-login

# Merge avec remote
<<<<<<< HEAD
=======
>>>>>>> origin/main

# Rebase
<<<<<<< HEAD
=======
>>>>>>> abc1234... (Message du commit)

# Cherry-pick
<<<<<<< HEAD
=======
>>>>>>> abc1234 (fix: correction bug critique)
```

> [!warning] Ne jamais committer les marqueurs Les marqueurs `<<<<<<<`, `=======`, et `>>>>>>>` doivent être supprimés du fichier avant de committer. Git ne les retirera pas automatiquement.

---

## ✏️ Résolution manuelle

### Processus de résolution

La résolution manuelle consiste à éditer directement les fichiers en conflit pour choisir ou combiner les versions conflictuelles.

#### Étape 1 : Ouvrir le fichier en conflit

```bash
# Ouvrir avec votre éditeur préféré
code fichier.txt
vim fichier.txt
nano fichier.txt
```

#### Étape 2 : Analyser le conflit

Examinez attentivement les trois sections :

1. **Version HEAD** : Votre version actuelle
2. **Version commune** (si diff3 activé) : Version avant divergence
3. **Version entrante** : Version de l'autre branche

#### Étape 3 : Choisir la résolution

Vous avez plusieurs options :

**Option A : Garder votre version**

```python
# Supprimer les marqueurs et la version entrante
def calculer_prix(quantite):
    return quantite * 10
```

**Option B : Garder la version entrante**

```python
# Supprimer les marqueurs et votre version
def calculer_prix(quantite):
    return quantite * 15
```

**Option C : Combiner les deux versions**

```python
# Fusionner les logiques des deux versions
def calculer_prix(quantite, categorie="standard"):
    prix_base = 10 if categorie == "standard" else 15
    return quantite * prix_base
```

**Option D : Réécrire complètement**

```python
# Créer une nouvelle solution qui prend en compte les deux intentions
def calculer_prix(quantite, avec_promo=False):
    prix_unitaire = 12  # Compromis entre 10 et 15
    total = quantite * prix_unitaire
    if avec_promo:
        total *= 0.85
    return total
```

> [!tip] Astuces pour décider
> 
> - Regardez l'historique des commits : `git log --oneline --graph --all`
> - Communiquez avec l'auteur de l'autre branche si possible
> - Testez la solution après résolution
> - En cas de doute, conservez les deux fonctionnalités

### Exemple de résolution complète

**Conflit initial :**

```python
<<<<<<< HEAD
def valider_email(email):
    # Validation basique
    return "@" in email and "." in email
||||||| merged common ancestors
def valider_email(email):
    return "@" in email
=======
def valider_email(email):
    # Validation avec regex
    import re
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return re.match(pattern, email) is not None
>>>>>>> feature-validation
```

**Résolution optimale (combinaison) :**

```python
def valider_email(email):
    # Validation complète avec regex et vérifications basiques
    import re
    
    # Vérification basique rapide
    if "@" not in email or "." not in email:
        return False
    
    # Validation précise avec regex
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return re.match(pattern, email) is not None
```

#### Étape 4 : Marquer comme résolu

```bash
# Ajouter le fichier résolu à la staging area
git add fichier.txt

# Vérifier l'état
git status
# Sortie : All conflicts fixed but you are still merging.
```

#### Étape 5 : Finaliser le merge

```bash
# Committer le merge
git commit

# Git ouvre un éditeur avec un message par défaut
# Vous pouvez le personnaliser ou le garder tel quel
# Message par défaut : "Merge branch 'feature-branch'"
```

> [!info] Message de commit automatique Git génère automatiquement un message de commit pour les merges. Vous pouvez l'enrichir avec des détails sur la résolution :
> 
> ```bash
> git commit -m "Merge branch 'feature-branch'
> 
> Résolution des conflits dans calculer_prix() :
> - Combiné les deux logiques de tarification
> - Ajouté paramètre de catégorie pour flexibilité"
> ```

### Stratégies de résolution avancées

#### Accepter tout d'un côté

```bash
# Accepter toutes les modifications de votre branche (HEAD)
git checkout --ours fichier.txt
git add fichier.txt

# Accepter toutes les modifications de l'autre branche
git checkout --theirs fichier.txt
git add fichier.txt
```

> [!warning] Utilisation de --ours et --theirs
> 
> - Ces commandes ne fonctionnent que pendant un conflit actif
> - Elles remplacent **tout** le fichier, pas seulement les sections en conflit
> - Utilisez-les avec prudence, vérifiez toujours le résultat

#### Résolution par section

Pour les gros fichiers avec plusieurs conflits :

```bash
# Résoudre un conflit à la fois
# 1. Éditer et résoudre le premier conflit
# 2. Sauvegarder
# 3. Continuer avec le suivant
# 4. git add après avoir résolu tous les conflits du fichier
```

### Annuler une résolution

```bash
# Si vous avez fait une erreur dans la résolution
# Avant le git add
git checkout -m fichier.txt  # Restaure les marqueurs de conflit

# Après le git add mais avant le commit
git reset HEAD fichier.txt   # Désindexe
git checkout -m fichier.txt  # Restaure les marqueurs

# Recommencer complètement le merge
git merge --abort
```

> [!tip] Prévention des conflits
> 
> - Communiquez avec votre équipe sur les zones de code en cours de modification
> - Faites des merges/rebase fréquents pour éviter les divergences importantes
> - Utilisez des branches de courte durée
> - Structurez votre code de manière modulaire

---

## 🛠️ Outils de résolution de conflits

### Éditeurs de texte avec support Git

La plupart des éditeurs modernes offrent des fonctionnalités intégrées pour faciliter la résolution des conflits.

#### Visual Studio Code

VS Code détecte automatiquement les conflits et affiche des actions cliquables :

```markdown
Fonctionnalités VS Code :
┌─────────────────────────────────────────────┐
│ Accept Current Change                       │
│ Accept Incoming Change                      │
│ Accept Both Changes                         │
│ Compare Changes                             │
└─────────────────────────────────────────────┘
```

Configuration utile dans VS Code :

```json
// settings.json
{
    "merge-conflict.autoNavigateNextConflict.enabled": true,
    "git.mergeEditor": true
}
```

**Raccourcis VS Code :**

- `Alt + F5` : Aller au conflit suivant
- `Shift + Alt + F5` : Aller au conflit précédent

#### JetBrains IDEs (IntelliJ, PyCharm, WebStorm)

Interface tri-panneaux sophistiquée :

```markdown
┌──────────┬──────────┬──────────┐
│   Yours  │  Result  │  Theirs  │
│  (HEAD)  │          │ (Branch) │
│          │          │          │
│  Modifs  │  Fusion  │  Modifs  │
│  locales │  finale  │ distantes│
└──────────┴──────────┴──────────┘
```

**Actions disponibles :**

- `Accept Left` / `Accept Right` pour chaque bloc
- `Compare with Base` pour voir l'ancêtre commun
- Navigation par conflit avec `F7` / `Shift + F7`

#### Vim / Neovim

Avec le plugin **vim-fugitive** :

```vim
" Commandes en mode conflit
:Gdiffsplit!        " Vue 3-way diff
:diffget //2        " Accepter version de gauche (HEAD)
:diffget //3        " Accepter version de droite (branche)
:Gwrite!            " Sauvegarder et marquer comme résolu
```

#### Sublime Text / Sublime Merge

Sublime Merge offre une interface visuelle dédiée :

```bash
# Ouvrir Sublime Merge sur le dépôt
smerge .
```

Fonctionnalités :

- Vue côte à côte des versions
- Édition en ligne de la résolution
- Staging visuel après résolution

### Outils en ligne de commande

#### git diff avec options

```bash
# Afficher le conflit sous forme de diff
git diff

# Afficher uniquement les fichiers en conflit
git diff --name-only --diff-filter=U

# Afficher les deux versions côte à côte
git diff --color-words

# Afficher avec plus de contexte
git diff -U10  # 10 lignes de contexte au lieu de 3
```

#### git show

```bash
# Voir la version de HEAD
git show :1:fichier.txt  # Ancêtre commun
git show :2:fichier.txt  # Votre version (HEAD)
git show :3:fichier.txt  # Leur version (branche)

# Extraire une version spécifique
git show :2:fichier.txt > fichier_notre_version.txt
git show :3:fichier.txt > fichier_leur_version.txt
```

> [!info] Numéros de stage Git stocke temporairement trois versions pendant un conflit :
> 
> - `:1:` = version de l'ancêtre commun (base)
> - `:2:` = votre version (ours/HEAD)
> - `:3:` = leur version (theirs/branche)

#### git checkout avec --ours / --theirs

```bash
# Accepter votre version pour tous les conflits d'un fichier
git checkout --ours fichier.txt
git add fichier.txt

# Accepter leur version pour tous les conflits d'un fichier
git checkout --theirs fichier.txt
git add fichier.txt

# Accepter votre version pour TOUS les fichiers en conflit
git checkout --ours .

# Accepter leur version pour TOUS les fichiers en conflit
git checkout --theirs .
```

> [!warning] Attention à --ours et --theirs Le sens de `--ours` et `--theirs` s'inverse pendant un **rebase** :
> 
> - En **merge** : `--ours` = votre branche, `--theirs` = branche à fusionner
> - En **rebase** : `--ours` = branche de base, `--theirs` = vos commits

### Outils graphiques dédiés

#### Meld

Outil open-source populaire sur Linux :

```bash
# Installation
sudo apt install meld  # Ubuntu/Debian
brew install meld      # macOS

# Utilisation manuelle
meld fichier_base.txt fichier_ours.txt fichier_theirs.txt
```

Fonctionnalités :

- Comparaison 3-way
- Édition directe dans l'interface
- Coloration syntaxique
- Navigation intuitive

#### KDiff3

Outil multiplateforme puissant :

```bash
# Installation
sudo apt install kdiff3  # Linux
brew install kdiff3      # macOS
```

Avantages :

- Fusion automatique intelligente
- Gestion des fichiers binaires
- Support des encodages multiples

#### Beyond Compare

Outil commercial professionnel :

```bash
# macOS
brew install --cask beyond-compare

# Configuration Git
git config --global diff.tool bc
git config --global merge.tool bc
```

Fonctionnalités premium :

- Comparaison de dossiers
- Synchronisation
- Plugins pour IDE

#### P4Merge (Perforce)

Outil gratuit de qualité professionnelle :

```bash
# Installation
brew install --cask p4v  # macOS

# Configuration
git config --global merge.tool p4merge
git config --global mergetool.p4merge.path /Applications/p4merge.app/Contents/MacOS/p4merge
```

Interface claire avec vue 3-panneaux.

### Comparaison des outils

|Outil|Type|Plateforme|Courbe d'apprentissage|Intégration Git|
|---|---|---|---|---|
|VS Code|Éditeur|Multi|Facile|Native|
|IntelliJ|IDE|Multi|Moyenne|Native|
|Vim|Éditeur|Multi|Difficile|Plugin|
|Meld|GUI|Linux/Mac|Facile|Manuelle|
|KDiff3|GUI|Multi|Moyenne|Excellente|
|Beyond Compare|GUI|Multi|Facile|Excellente|
|P4Merge|GUI|Multi|Facile|Bonne|

> [!tip] Choisir son outil
> 
> - **Débutants** : VS Code ou Meld (interface claire et actions guidées)
> - **Développeurs expérimentés** : IntelliJ ou Beyond Compare (fonctionnalités avancées)
> - **Terminal addicts** : Vim avec fugitive (efficacité au clavier)
> - **Projets complexes** : KDiff3 ou Beyond Compare (comparaison de répertoires)

### Configuration des outils dans Git

```bash
# VS Code
git config --global merge.tool vscode
git config --global mergetool.vscode.cmd 'code --wait $MERGED'

# IntelliJ/PyCharm/WebStorm
git config --global merge.tool intellij
git config --global mergetool.intellij.cmd 'idea merge "$LOCAL" "$REMOTE" "$BASE" "$MERGED"'

# Meld
git config --global merge.tool meld

# Sublime Merge
git config --global merge.tool smerge
git config --global mergetool.smerge.cmd 'smerge mergetool "$BASE" "$LOCAL" "$REMOTE" -o "$MERGED"'

# Désactiver la création de fichiers .orig
git config --global mergetool.keepBackup false
```

---

## 🔧 git mergetool

### Concept et utilité

`git mergetool` est une commande qui lance automatiquement l'outil de résolution de conflits configuré pour vous aider à résoudre les conflits de manière visuelle et interactive.

> [!info] Pourquoi utiliser mergetool ?
> 
> - **Interface visuelle** : Plus intuitive que l'édition manuelle des marqueurs
> - **Comparaison côte à côte** : Vue claire des différences
> - **Moins d'erreurs** : Réduit les risques d'oublier des marqueurs de conflit
> - **Efficacité** : Navigation rapide entre les conflits

### Configuration initiale

#### Choisir et configurer un outil

```bash
# Lister les outils supportés nativement par Git
git mergetool --tool-help

# Configurer l'outil par défaut
git config --global merge.tool <nom-outil>

# Exemples de configuration
git config --global merge.tool vimdiff    # Vim
git config --global merge.tool meld       # Meld
git config --global merge.tool kdiff3     # KDiff3
git config --global merge.tool vscode     # VS Code
git config --global merge.tool bc         # Beyond Compare
git config --global merge.tool p4merge    # P4Merge
```

#### Configuration manuelle d'un outil

Si votre outil préféré n'est pas reconnu automatiquement :

```bash
# Exemple avec VS Code
git config --global merge.tool vscode
git config --global mergetool.vscode.cmd 'code --wait --merge $REMOTE $LOCAL $BASE $MERGED'
git config --global mergetool.vscode.trustExitCode true

# Exemple avec IntelliJ IDEA
git config --global merge.tool idea
git config --global mergetool.idea.cmd 'idea merge "$LOCAL" "$REMOTE" "$BASE" "$MERGED"'
git config --global mergetool.idea.trustExitCode true

# Exemple avec Sublime Merge
git config --global merge.tool smerge
git config --global mergetool.smerge.cmd 'smerge mergetool "$BASE" "$LOCAL" "$REMOTE" -o "$MERGED"'
git config --global mergetool.smerge.trustExitCode true
```

#### Variables disponibles

Lors de la configuration, vous pouvez utiliser ces variables :

|Variable|Description|
|---|---|
|`$BASE`|Version de l'ancêtre commun|
|`$LOCAL`|Votre version (HEAD)|
|`$REMOTE`|Version de la branche à fusionner|
|`$MERGED`|Fichier de sortie où sauvegarder la résolution|

#### Options de configuration

```bash
# Ne pas demander confirmation avant de lancer l'outil
git config --global mergetool.prompt false

# Supprimer les fichiers .orig après résolution
git config --global mergetool.keepBackup false

# Faire confiance au code de sortie de l'outil
git config --global mergetool.<outil>.trustExitCode true

# Définir un timeout (en secondes)
git config --global mergetool.timeout 60
```

> [!tip] Fichiers .orig Par défaut, Git crée des fichiers `.orig` contenant la version avec les marqueurs de conflit avant la résolution. Désactivez cette option si vous utilisez un système de contrôle de version (ce qui est redondant).

### Utilisation de git mergetool

#### Lancement basique

```bash
# Lancer mergetool pour tous les fichiers en conflit
git mergetool

# Sortie typique
Merging:
fichier1.txt
fichier2.py
fichier3.js

Normal merge conflict for 'fichier1.txt':
  {local}: modified file
  {remote}: modified file
Hit return to start merge resolution tool (meld):
```

#### Résolution sélective

```bash
# Lancer mergetool pour un fichier spécifique
git mergetool fichier.txt

# Lancer mergetool pour plusieurs fichiers
git mergetool fichier1.txt fichier2.py

# Utiliser un outil différent ponctuellement
git mergetool --tool=kdiff3
git mergetool --tool=meld fichier.txt
```

#### Processus de résolution

**Étape 1** : Git lance l'outil configuré avec une vue 3-way :

```markdown
┌─────────────┬──────────────┬─────────────┐
│    LOCAL    │    BASE      │   REMOTE    │
│   (Yours)   │  (Original)  │  (Theirs)   │
├─────────────┴──────────────┴─────────────┤
│           MERGED (Result)                 │
│        Votre résolution finale            │
└───────────────────────────────────────────┘
```

**Étape 2** : Vous résolvez le conflit dans l'interface de l'outil

**Étape 3** : Sauvegardez et fermez l'outil

**Étape 4** : Git vous demande confirmation :

```bash
Was the merge successful? [y/n]
```

- **y** : Le fichier est automatiquement ajouté au staging (`git add`)
- **n** : Le fichier reste en conflit, vous pouvez réessayer

**Étape 5** : Git passe automatiquement au fichier suivant

### Interface typique d'un mergetool

#### Vue 3-way merge

La plupart des outils présentent 4 panneaux :

```markdown
┌──────────────────────────────────────────┐
│  PANNEAU 1 : LOCAL (votre version)       │
│  - Modifications de votre branche        │
│  - Référence : HEAD                      │
├──────────────────────────────────────────┤
│  PANNEAU 2 : BASE (ancêtre commun)       │
│  - Version avant la divergence           │
│  - Référence historique                  │
├──────────────────────────────────────────┤
│  PANNEAU 3 : REMOTE (leur version)       │
│  - Modifications de la branche à merger  │
│  - Référence : nom de branche            │
├──────────────────────────────────────────┤
│  PANNEAU 4 : MERGED (résultat final)     │
│  - Éditable : votre résolution           │
│  - Sera sauvegardé dans le fichier       │
└──────────────────────────────────────────┘
```

#### Actions courantes

Les outils offrent généralement ces actions :

- **Accept Left** : Garder la version LOCAL
- **Accept Right** : Garder la version REMOTE
- **Accept Both** : Combiner les deux versions
- **Edit Manually** : Éditer directement le résultat
- **Previous/Next Conflict** : Navigation entre conflits
- **Mark as Resolved** : Finaliser la résolution

### Workflow complet avec mergetool

```bash
# 1. Tentative de merge qui échoue
git merge feature-branch
# CONFLICT (content): Merge conflict in app.py

# 2. Vérifier les fichiers en conflit
git status
# Unmerged paths:
#   both modified:   app.py
#   both modified:   config.json

# 3. Lancer mergetool
git mergetool
# Normal merge conflict for 'app.py':
#   {local}: modified file
#   {remote}: modified file
# Hit return to start merge resolution tool (meld):

# 4. [L'outil s'ouvre, vous résolvez le conflit]
# 5. [Sauvegardez et fermez]

# 6. Git demande confirmation
# Was the merge successful? [y/n] y
# app.py: 1 conflict resolved

# 7. Mergetool passe au fichier suivant
# Normal merge conflict for 'config.json':
# [Répétez le processus]

# 8. Une fois tous les conflits résolus
git status
# All conflicts fixed but you are still merging.
#   modified:   app.py
#   modified:   config.json

# 9. Finaliser le merge
git commit
# [Git ouvre l'éditeur avec un message par défaut]

# 10. Vérifier le résultat
git log --oneline --graph -5
```

### Annuler ou recommencer

```bash
# Quitter mergetool sans résoudre
# Dans l'outil : fermez simplement la fenêtre
# Git demandera : Was the merge successful? [y/n]
# Répondez : n

# Recommencer la résolution d'un fichier
git checkout -m fichier.txt  # Restaure les marqueurs
git mergetool fichier.txt    # Relance l'outil

# Abandonner complètement le merge
git merge --abort

# Supprimer manuellement les fichiers .orig (si keepBackup = true)
find . -name "*.orig" -delete
```

### Astuces et optimisations

#### Résolution par lot

```bash
# Accepter automatiquement LOCAL pour tous les conflits
git merge -X ours feature-branch

# Accepter automatiquement REMOTE pour tous les conflits
git merge -X theirs feature-branch

# Ces options évitent les conflits mais ATTENTION : danger de perte de code
```

> [!warning] Stratégies -X ours/theirs Ces options sont dangereuses car elles ignorent complètement un côté. Utilisez-les uniquement si vous êtes certain de vouloir privilégier une branche.

#### Mergetool avec rebase

```bash
# Pendant un rebase interactif
git rebase main
# CONFLICT (content): Merge conflict in fichier.txt

# Lancer mergetool
git mergetool

# Continuer le rebase après résolution
git rebase --continue
```

> [!info] Rebase et mergetool Pendant un rebase, `--ours` et `--theirs` sont inversés :
> 
> - `--ours` = la branche de base (où vous rebasez)
> - `--theirs` = vos commits (qui sont réappliqués)

#### Script pour automatisation

```bash
# Créer un alias Git pour résolution rapide
git config --global alias.resolve '!git mergetool && git clean -f'

# Utilisation
git resolve  # Lance mergetool et nettoie les .orig
```

#### Pré-configuration des outils multiples

```bash
# Avoir plusieurs outils disponibles
git config --global merge.tool meld
git config --global mergetool.kdiff3.path /usr/bin/kdiff3
git config --global mergetool.vscode.cmd 'code --wait --merge $REMOTE $LOCAL $BASE $MERGED'

# Choisir à la volée
git mergetool --tool=kdiff3
git mergetool --tool=vscode
```

### Dépannage mergetool

#### L'outil ne se lance pas

```bash
# Vérifier la configuration
git config --global --get merge.tool
git config --global --get mergetool.<outil>.cmd
git config --global --get mergetool.<outil>.path

# Tester manuellement la commande
# Exemple pour VS Code
code --wait --merge test1.txt test2.txt test3.txt test4.txt

# Réinitialiser la configuration
git config --global --unset merge.tool
git config --global --unset mergetool.<outil>.cmd
```

#### L'outil se ferme immédiatement

Problème courant : l'option `--wait` manque

```bash
# Corriger pour VS Code
git config --global mergetool.vscode.cmd 'code --wait --merge $REMOTE $LOCAL $BASE $MERGED'

# Corriger pour Sublime
git config --global mergetool.sublime.cmd 'subl --wait "$MERGED"'
```

#### Fichiers .orig encombrants

```bash
# Désactiver globalement
git config --global mergetool.keepBackup false

# Nettoyer les fichiers existants
git clean -f "*.orig"

# Ajouter au .gitignore
echo "*.orig" >> .gitignore
```

#### Git ne détecte pas la résolution

```bash
# Vérifier que trustExitCode est activé
git config --global mergetool.<outil>.trustExitCode true

# Marquer manuellement comme résolu
git add fichier-resolu.txt

# Forcer Git à considérer le fichier comme résolu
git checkout --ours fichier.txt  # ou --theirs
git add fichier.txt
```

### Comparaison mergetool vs résolution manuelle

|Critère|Mergetool|Résolution manuelle|
|---|---|---|
|**Vitesse**|Plus rapide pour conflits complexes|Plus rapide pour conflits simples|
|**Visualisation**|Vue claire 3-way|Marqueurs textuels uniquement|
|**Courbe d'apprentissage**|Nécessite configuration initiale|Immédiate|
|**Risque d'erreur**|Faible (pas de marqueurs oubliés)|Moyen (marqueurs à supprimer)|
|**Flexibilité**|Dépend de l'outil|Contrôle total|
|**Contexte**|Vue d'ensemble excellente|Limité à l'éditeur|
|**Automatisation**|Possible avec scripts|Difficile|

> [!tip] Quand utiliser mergetool ?
> 
> - **Conflits multiples** : Plus de 3-4 conflits dans un fichier
> - **Conflits complexes** : Modifications entrelacées sur plusieurs lignes
> - **Code structuré** : Python, Java, JSON où la structure est importante
> - **Comparaison nécessaire** : Besoin de voir l'ancêtre commun (BASE)
> 
> **Quand résoudre manuellement ?**
> 
> - **Conflit unique** : Un seul petit conflit évident
> - **Contexte clair** : Vous savez exactement quoi garder
> - **Modifications triviales** : Espaces, imports, commentaires
> - **Pas d'outil configuré** : Sur une machine temporaire

---

## ✅ Bonnes pratiques

### Avant la résolution

#### 1. Comprendre le contexte

```bash
# Examiner l'historique des branches
git log --oneline --graph --all -10

# Voir les commits impliqués dans le conflit
git log --merge --oneline

# Comparer les branches avant le merge
git diff main...feature-branch

# Identifier les auteurs des modifications
git log --oneline --all -- fichier-en-conflit.txt
```

> [!tip] Communication d'équipe Avant de résoudre un conflit complexe, parlez avec l'auteur de l'autre branche si possible. Comprenez l'intention derrière les modifications.

#### 2. Sauvegarder l'état actuel

```bash
# Créer une branche de sauvegarde
git branch backup-avant-resolution

# Ou créer un commit temporaire
git add .
git commit -m "WIP: avant résolution conflits"
```

#### 3. Faire un merge à blanc (dry-run)

```bash
# Simuler le merge sans modifications
git merge --no-commit --no-ff feature-branch

# Examiner les conflits potentiels
git status

# Annuler si nécessaire
git merge --abort
```

### Pendant la résolution

#### 1. Résoudre un fichier à la fois

```bash
# Ne pas se précipiter
# Résoudre complètement un fichier avant de passer au suivant
git mergetool fichier1.txt
# [Résolution complète]
git add fichier1.txt

# Puis le suivant
git mergetool fichier2.py
```

#### 2. Tester après chaque résolution

```bash
# Après avoir résolu un fichier critique
git stash  # Sauvegarder temporairement les autres conflits
python fichier-resolu.py  # Tester
npm test fichier-resolu.js
./run-tests.sh

git stash pop  # Restaurer les autres fichiers
```

> [!warning] Ne jamais committer sans tester Un conflit mal résolu peut introduire des bugs subtils. Testez toujours le code après résolution, surtout pour les fonctions critiques.

#### 3. Documenter les décisions

```bash
# Ajouter des commentaires dans le code résolu
# RESOLUTION CONFLIT : Combiné validation basique + regex
# Raison : Garder performance ET précision
def valider_email(email):
    # ...
```

#### 4. Vérifier l'absence de marqueurs

```bash
# Avant de committer, vérifier qu'il ne reste aucun marqueur
git diff --check

# Rechercher manuellement les marqueurs
grep -r "<<<<<<< HEAD" .
grep -r "=======" .
grep -r ">>>>>>>" .

# Ou utiliser un hook pre-commit (voir ci-dessous)
```

### Après la résolution

#### 1. Commit explicite

```bash
# Message de commit descriptif
git commit -m "Merge branch 'feature-pricing'

Résolution des conflits :
- calculer_prix() : combiné les deux logiques de tarification
- valider_email() : ajouté regex tout en gardant vérification rapide
- config.json : conservé les nouveaux paramètres de la feature

Tests : tous passent après résolution"
```

#### 2. Revue de code post-merge

```bash
# Examiner les différences introduites
git diff HEAD~1

# Comparer avec la branche mergée
git diff feature-branch

# Demander une revue si résolution complexe
git push
# Créer une PR ou demander review
```

#### 3. Tests complets

```bash
# Suite de tests complète
npm test
pytest
./run-all-tests.sh

# Tests d'intégration
# Tests end-to-end si disponibles
```

### Prévention des conflits

#### 1. Stratégie de branches

```bash
# Garder les branches courtes (< 1 semaine)
# Merger fréquemment depuis main
git checkout feature-branch
git merge main  # Régulièrement

# Ou rebaser fréquemment
git rebase main
```

#### 2. Communication

- Annoncer les zones de code en cours de modification
- Utiliser des systèmes de tickets (Jira, GitHub Issues)
- Code reviews fréquentes pour synchroniser l'équipe

#### 3. Architecture modulaire

```python
# Mauvais : un seul gros fichier
# app.py (2000 lignes) - conflits fréquents

# Bon : code modulaire
# app/
#   auth.py
#   billing.py
#   users.py
# Moins de développeurs touchent le même fichier
```

#### 4. Conventions de code

```bash
# Utiliser des formatters automatiques
black .                    # Python
prettier --write .         # JavaScript
gofmt -w .                # Go

# Évite les conflits de style
```

### Hooks Git pour prévenir les erreurs

#### Hook pre-commit

Créez `.git/hooks/pre-commit` :

```bash
#!/bin/bash
# Vérifier qu'il ne reste pas de marqueurs de conflit

if git diff --cached | grep -E '^(\+.*<<<<<<<|^(\+.*=======|^(\+.*>>>>>>>)'; then
    echo "ERREUR: Des marqueurs de conflit sont présents dans les fichiers staged"
    echo "Fichiers concernés :"
    git diff --cached --name-only | xargs grep -l "<<<<<<< HEAD"
    exit 1
fi

exit 0
```

Rendre le script exécutable :

```bash
chmod +x .git/hooks/pre-commit
```

#### Hook post-merge

Créez `.git/hooks/post-merge` :

```bash
#!/bin/bash
# Lancer les tests automatiquement après un merge

echo "🧪 Lancement des tests après merge..."
npm test || echo "⚠️  Des tests ont échoué après le merge"
```

### Cas particuliers

#### Conflits dans les fichiers binaires

```bash
# Git ne peut pas merger les binaires
# Choisir une version

# Garder votre version
git checkout --ours image.png
git add image.png

# Garder leur version
git checkout --theirs image.png
git add image.png

# Ou les renommer tous les deux
git checkout --ours image.png
mv image.png image-v1.png
git checkout --theirs image.png
mv image.png image-v2.png
# Puis décider manuellement
```

#### Conflits dans les fichiers générés

```bash
# Fichiers générés (package-lock.json, Pipfile.lock)
# Régénérer plutôt que résoudre

# Garder une version
git checkout --theirs package-lock.json

# Régénérer
npm install

# Ajouter la version régénérée
git add package-lock.json
```

#### Conflits dans les migrations de base de données

```bash
# Migrations en conflit (Django, Rails, etc.)
# NE PAS merger les fichiers de migration

# Solution : créer une nouvelle migration
git checkout --ours migration_001.py
git checkout --theirs migration_002.py
git add migration_001.py migration_002.py

# Puis créer une migration de fusion
python manage.py makemigrations --merge
git add migration_003_merge.py
```

### Récapitulatif des commandes essentielles

```bash
# ====== IDENTIFICATION ======
git status                        # Voir les fichiers en conflit
git diff                          # Examiner les conflits
git log --merge --oneline         # Voir les commits en conflit

# ====== RÉSOLUTION MANUELLE ======
# [Éditer le fichier]
git add fichier.txt               # Marquer comme résolu
git commit                        # Finaliser le merge

# ====== RÉSOLUTION AVEC OUTIL ======
git mergetool                     # Lancer l'outil configuré
git mergetool --tool=meld         # Utiliser un outil spécifique
git mergetool fichier.txt         # Résoudre un fichier spécifique

# ====== STRATÉGIES RAPIDES ======
git checkout --ours fichier.txt   # Garder votre version
git checkout --theirs fichier.txt # Garder leur version
git merge -X ours branch          # Privilégier votre branche
git merge -X theirs branch        # Privilégier leur branche

# ====== ANNULATION ======
git merge --abort                 # Annuler le merge
git rebase --abort                # Annuler le rebase
git checkout -m fichier.txt       # Restaurer les marqueurs

# ====== VÉRIFICATION ======
git diff --check                  # Vérifier les erreurs
grep -r "<<<<<<< HEAD" .          # Chercher les marqueurs
git diff HEAD~1                   # Voir le résultat du merge

# ====== CONFIGURATION MERGETOOL ======
git config --global merge.tool vscode
git config --global mergetool.prompt false
git config --global mergetool.keepBackup false
```

> [!tip] Mémo de décision rapide
> 
> 1. **Conflit simple** (1-2 lignes) → Résolution manuelle
> 2. **Conflit moyen** (3-10 lignes) → Mergetool OU manuel selon préférence
> 3. **Conflit complexe** (10+ lignes, plusieurs sections) → Mergetool obligatoire
> 4. **Choix évident** (garder tout d'un côté) → `--ours` ou `--theirs`
> 5. **Fichier généré** → Régénérer plutôt que résoudre
> 6. **Doute** → Communiquer avec l'équipe avant de résoudre

---

## 🎓 Points clés à retenir

1. **Les conflits sont normaux** : Ils font partie du workflow Git et ne sont pas une erreur
2. **Comprendre avant de résoudre** : Examinez l'historique et le contexte
3. **Un fichier à la fois** : Ne vous précipitez pas, résolvez méthodiquement
4. **Toujours tester** : Un conflit mal résolu = bug potentiel
5. **Documenter les décisions** : Dans les commits et parfois dans le code
6. **Utiliser les bons outils** : Mergetool pour les cas complexes
7. **Prévenir plutôt que guérir** : Merges fréquents, branches courtes, communication
8. **Vérifier l'absence de marqueurs** : Avant chaque commit
9. **Ne jamais paniquer** : `git merge --abort` est toujours disponible
10. **Apprendre de chaque conflit** : Améliorer le workflow pour en éviter d'autres

> [!success] Vous maîtrisez maintenant la gestion des conflits ! Avec ces connaissances, vous êtes capable de :
> 
> - ✅ Identifier et comprendre n'importe quel conflit Git
> - ✅ Choisir la meilleure stratégie de résolution selon le contexte
> - ✅ Utiliser efficacement les outils de merge
> - ✅ Prévenir les conflits futurs
> - ✅ Résoudre sereinement même les situations complexes