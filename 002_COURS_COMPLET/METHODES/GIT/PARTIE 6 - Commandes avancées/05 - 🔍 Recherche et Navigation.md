

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

## Introduction

Les commandes de recherche et navigation de Git sont des outils puissants pour explorer l'historique de votre projet, identifier l'origine des modifications, et retrouver des informations perdues. Ces commandes sont essentielles pour le débogage, l'audit de code, et la compréhension de l'évolution d'un projet.

---

## git blame - Identifier l'auteur

### 🎯 Objectif

`git blame` permet de voir qui a modifié chaque ligne d'un fichier et quand. Cette commande est particulièrement utile pour comprendre le contexte d'une modification, identifier l'auteur d'un bug, ou simplement pour obtenir plus d'informations sur un morceau de code.

> [!info] Pourquoi "blame" ? Le nom peut sembler négatif, mais il ne s'agit pas de "blâmer" quelqu'un. C'est simplement un moyen d'identifier l'origine des modifications pour mieux comprendre le code.

### 📖 Syntaxe de base

```bash
# Afficher l'historique ligne par ligne d'un fichier
git blame <fichier>

# Afficher uniquement les lignes 10 à 20
git blame -L 10,20 <fichier>

# Afficher avec plus de contexte (nom complet, email)
git blame -e <fichier>

# Format court (hash court + auteur)
git blame -s <fichier>
```

### 🔧 Options avancées

```bash
# Suivre les déplacements de lignes dans le même fichier
git blame -M <fichier>

# Suivre les déplacements de lignes entre fichiers
git blame -C <fichier>

# Suivre les déplacements même dans les commits de création
git blame -C -C -C <fichier>

# Ignorer les modifications d'espaces
git blame -w <fichier>

# Afficher à une date spécifique
git blame --since=2.weeks <fichier>

# Avec un format personnalisé
git blame --date=short <fichier>
```

### 💡 Cas d'usage pratiques

**1. Identifier l'origine d'un bug**

```bash
# Trouver qui a modifié la ligne problématique
git blame src/utils.js | grep "problematic_function"

# Voir le commit complet
git show <hash-du-commit>
```

**2. Comprendre le contexte d'une modification**

```bash
# Voir les modifications avec contexte
git blame -L 50,60 src/main.py

# Puis consulter le commit pour voir le message
git log -p <hash>
```

**3. Suivre l'évolution d'une fonction**

```bash
# Voir l'historique complet d'une section
git blame -L :fonction_name: src/file.js
```

> [!example] Exemple de sortie
> 
> ```
> ^4a3b2c1 (John Doe  2024-01-15 10:30:45 +0100  1) function calculate() {
> a8f7e6d5 (Jane Smith 2024-02-20 14:22:10 +0100  2)   const result = x * 2;
> a8f7e6d5 (Jane Smith 2024-02-20 14:22:10 +0100  3)   return result;
> ^4a3b2c1 (John Doe  2024-01-15 10:30:45 +0100  4) }
> ```
> 
> - Le `^` indique un commit initial (présent dès la création du fichier)
> - Chaque ligne montre : hash, auteur, date, numéro de ligne, contenu

### ⚠️ Pièges courants

|Piège|Explication|Solution|
|---|---|---|
|Refactoring massif|Un refactoring cache l'historique réel|Utiliser `-w` pour ignorer les espaces et `-C` pour suivre les déplacements|
|Commits de formatage|Les commits de reformatage masquent l'historique|Créer un fichier `.git-blame-ignore-revs` avec les commits à ignorer|
|Fichiers déplacés|L'historique est perdu après un déplacement|Utiliser `-C` plusieurs fois pour suivre entre fichiers|

### 🎓 Bonnes pratiques

1. **Utiliser avec précaution** : Ne jugez pas un collègue sur une ligne isolée, consultez toujours le commit complet
2. **Combiner avec `git log`** : Utilisez `git log -p` pour voir le contexte complet
3. **Ignorer les commits inutiles** : Configurez `.git-blame-ignore-revs` pour les commits de reformatage

```bash
# Créer un fichier .git-blame-ignore-revs
echo "a1b2c3d4e5f6" >> .git-blame-ignore-revs

# Configurer Git pour l'utiliser
git config blame.ignoreRevsFile .git-blame-ignore-revs
```

### ✨ Astuces

```bash
# Voir le blame avec les modifications non commitées
git blame HEAD <fichier>

# Format plus lisible avec couleurs
git blame --color-by-age <fichier>

# Voir uniquement l'auteur et la date
git blame --date=relative -s <fichier>

# Exporter en JSON pour analyse
git blame --line-porcelain <fichier>
```

---

## git bisect - Recherche dichotomique

### 🎯 Objectif

`git bisect` est un outil puissant pour trouver le commit qui a introduit un bug en utilisant une recherche binaire (dichotomie). Au lieu de tester chaque commit manuellement, Git divise l'historique en deux à chaque étape, réduisant drastiquement le nombre de tests nécessaires.

> [!info] Efficacité de la dichotomie Pour 1000 commits, vous ne testez que 10 versions environ (log₂(1000) ≈ 10) au lieu de 500 en moyenne avec une recherche linéaire.

### 📖 Processus de base

```bash
# 1. Démarrer la session bisect
git bisect start

# 2. Marquer le commit actuel comme mauvais (bug présent)
git bisect bad

# 3. Marquer un ancien commit comme bon (bug absent)
git bisect good <commit-hash>
# ou
git bisect good v1.0  # Utiliser un tag

# 4. Git checkout automatiquement un commit au milieu
# Tester le code, puis marquer :
git bisect good  # Si le bug n'est pas présent
# ou
git bisect bad   # Si le bug est présent

# 5. Répéter jusqu'à trouver le commit coupable

# 6. Terminer la session
git bisect reset
```

### 🤖 Bisect automatisé

Lorsque vous avez un test automatisé, vous pouvez laisser Git faire tout le travail :

```bash
# Démarrer bisect
git bisect start HEAD v1.0

# Lancer un script de test automatique
git bisect run ./test.sh

# Git va tester automatiquement chaque commit
# Le script doit retourner :
# - 0 si le test passe (good)
# - 1-127 (sauf 125) si le test échoue (bad)
# - 125 si le commit ne peut pas être testé (skip)
```

> [!example] Exemple de script de test
> 
> ```bash
> #!/bin/bash
> # test.sh
> 
> # Compiler le projet
> make build || exit 125  # Skip si la compilation échoue
> 
> # Exécuter les tests
> npm test
> 
> # Le code de sortie de npm test sera utilisé automatiquement
> ```

### 🔧 Commandes avancées

```bash
# Voir l'état actuel de bisect
git bisect log

# Voir une visualisation de la progression
git bisect visualize
# ou
git bisect view

# Sauter un commit (par exemple, s'il ne compile pas)
git bisect skip

# Réinitialiser à un état spécifique
git bisect reset <branch>

# Continuer après avoir corrigé quelque chose
git bisect replay <logfile>

# Sauvegarder la session pour la reprendre plus tard
git bisect log > bisect.log
# Reprendre
git bisect replay bisect.log
```

### 💡 Cas d'usage pratiques

**1. Trouver un bug de régression**

```bash
# Un test qui fonctionnait ne passe plus
git bisect start
git bisect bad                    # Le test échoue maintenant
git bisect good v2.3.0           # Le test passait dans cette version

# Tester manuellement ou automatiquement
git bisect run npm test
```

**2. Identifier un changement de performance**

```bash
# Script qui mesure les performances
cat > perf_test.sh << 'EOF'
#!/bin/bash
time ./benchmark.sh > /tmp/result.txt
DURATION=$(cat /tmp/result.txt | grep "Total time" | awk '{print $3}')
if (( $(echo "$DURATION > 5.0" | bc -l) )); then
    exit 1  # Trop lent = bad
else
    exit 0  # Rapide = good
fi
EOF

chmod +x perf_test.sh
git bisect start HEAD v1.0
git bisect run ./perf_test.sh
```

**3. Chercher quand un fichier a été supprimé**

```bash
git bisect start
git bisect bad HEAD              # Le fichier n'existe plus
git bisect good <ancien-commit>  # Le fichier existait

# Script de test
git bisect run test -f "path/to/file.txt"
```

### ⚠️ Pièges courants

|Piège|Explication|Solution|
|---|---|---|
|Commits qui ne compilent pas|Bloquer la recherche|Utiliser `git bisect skip`|
|Tests flaky|Résultats non déterministes|Exécuter les tests plusieurs fois dans le script|
|Dépendances manquantes|Différences d'environnement entre commits|Inclure l'installation des dépendances dans le script|
|Fusion de branches|Historique non linéaire compliqué|Utiliser `--first-parent` pour suivre uniquement la branche principale|

### 🎓 Bonnes pratiques

1. **Commencer large** : Prenez un commit "good" suffisamment ancien pour être sûr
2. **Scripts robustes** : Votre script de test doit gérer les erreurs de compilation (exit 125)
3. **Sauvegarder l'état** : Utilisez `git bisect log > fichier.log` pour reprendre plus tard
4. **Nettoyer après** : Toujours terminer avec `git bisect reset`

```bash
# Template de script robuste
cat > bisect_test.sh << 'EOF'
#!/bin/bash
set -e

# Nettoyer l'environnement
make clean

# Compiler (skip si échec)
if ! make build; then
    exit 125
fi

# Installer les dépendances si nécessaire
if [ -f "package.json" ]; then
    npm install --silent || exit 125
fi

# Exécuter le test
if ./run_test.sh; then
    exit 0  # Good
else
    exit 1  # Bad
fi
EOF
```

### ✨ Astuces

```bash
# Bisect sur un range spécifique
git bisect start <bad-commit> <good-commit>

# Utiliser des termes personnalisés au lieu de good/bad
git bisect start --term-old=fast --term-new=slow
git bisect fast <commit>
git bisect slow <commit>

# Voir le nombre de révisions restantes à tester
git bisect log | tail -n 1

# Bisect avec un sous-répertoire seulement
git bisect start -- path/to/directory/

# Combiner avec git grep
git bisect run sh -c "git grep -q 'bug_pattern' && exit 1 || exit 0"
```

---

## git grep - Recherche dans le code

### 🎯 Objectif

`git grep` est un outil de recherche optimisé pour les dépôts Git. Plus rapide que `grep` classique, il ignore automatiquement les fichiers non versionnés et offre des options puissantes pour rechercher dans l'historique du projet.

> [!info] Pourquoi git grep plutôt que grep ? `git grep` est spécialement optimisé pour Git, ignore automatiquement `.gitignore`, et peut chercher dans n'importe quel commit de l'historique.

### 📖 Syntaxe de base

```bash
# Recherche simple dans le répertoire de travail
git grep "motif"

# Recherche insensible à la casse
git grep -i "motif"

# Afficher les numéros de ligne
git grep -n "motif"

# Afficher uniquement les noms de fichiers
git grep -l "motif"

# Compter les occurrences par fichier
git grep -c "motif"
```

### 🔧 Recherche avancée

```bash
# Recherche avec expression régulière étendue
git grep -E "pattern[0-9]+"

# Recherche de mot entier uniquement
git grep -w "variable"

# Recherche avec contexte (3 lignes avant et après)
git grep -C 3 "fonction"
# ou séparément
git grep -B 3 -A 3 "fonction"

# Recherche inversée (lignes qui ne contiennent PAS le motif)
git grep -v "pattern"

# Recherche avec plusieurs patterns (OU logique)
git grep -e "pattern1" -e "pattern2"

# Recherche avec ET logique
git grep -e "pattern1" --and -e "pattern2"

# Recherche dans des fichiers spécifiques
git grep "motif" -- "*.js"
git grep "motif" -- src/

# Exclure certains fichiers
git grep "motif" -- . ":(exclude)*.min.js"
```

### 🕐 Recherche dans l'historique

```bash
# Recherche dans un commit spécifique
git grep "motif" <commit-hash>

# Recherche dans une branche
git grep "motif" main

# Recherche dans tous les commits
git log -p -S "motif"
# ou avec regex
git log -p -G "pattern.*regex"

# Recherche dans un range de commits
git grep "motif" main..develop

# Recherche dans tous les tags
git tag | xargs git grep "motif"

# Recherche dans le stash
git grep "motif" stash@{0}
```

### 💡 Cas d'usage pratiques

**1. Trouver toutes les utilisations d'une fonction**

```bash
# Recherche exacte du nom de fonction
git grep -w "calculateTotal"

# Avec contexte pour voir comment elle est utilisée
git grep -C 2 "calculateTotal"

# Dans tous les fichiers JavaScript uniquement
git grep "calculateTotal" -- "*.js"
```

**2. Identifier les TODOs et FIXMEs**

```bash
# Trouver tous les TODO
git grep -n "TODO"

# Avec le nom de l'auteur
git grep "TODO" | while read line; do
    file=$(echo $line | cut -d: -f1)
    linenum=$(echo $line | cut -d: -f2)
    git blame -L $linenum,$linenum $file
done

# Compter par type
git grep -c "TODO\|FIXME\|HACK"
```

**3. Audit de sécurité**

```bash
# Rechercher des mots-clés sensibles
git grep -i "password\|secret\|api_key"

# Dans tout l'historique
git log -p -S "password" -- "*.config"

# Recherche de patterns dangereux
git grep -E "(eval|exec)\("
```

**4. Analyser l'utilisation d'une dépendance**

```bash
# Trouver tous les imports d'une librairie
git grep "import.*lodash"

# Voir quand elle a été ajoutée
git log -p -S "lodash" -- package.json
```

### 🎨 Formatage de sortie

```bash
# Sortie colorée (par défaut si terminal supporte)
git grep --color=always "motif"

# Format personnalisé
git grep --heading --break "motif"

# Format machine-readable
git grep --null "motif"

# Avec le nom de fonction contenant la correspondance
git grep -p "motif" -- "*.c"

# Groupe par fichier
git grep --heading --break -n "motif"
```

> [!example] Sortie avec --heading --break
> 
> ```
> src/utils.js
> 12:function calculateTotal() {
> 45:  return calculateTotal(items);
> 
> src/main.js
> 23:const total = calculateTotal();
> ```

### ⚠️ Pièges courants

|Piège|Explication|Solution|
|---|---|---|
|Recherche trop large|Trop de résultats|Affiner avec `-w`, types de fichiers, ou répertoires|
|Fichiers binaires|Git grep inclut les binaires|Utiliser `--text` ou `-I` pour ignorer|
|Regex complexes|Syntaxe différente selon les options|Utiliser `-E` pour regex étendues, `-P` pour Perl|
|Performance|Lent sur gros historiques|Limiter aux branches/commits pertinents|

### 🎓 Bonnes pratiques

1. **Combiner avec d'autres commandes** : Utilisez des pipes pour affiner les résultats
2. **Créer des alias** : Pour les recherches fréquentes
3. **Utiliser les pathspec** : Pour limiter aux zones pertinentes

```bash
# Alias utiles dans .gitconfig
[alias]
    # Recherche avec contexte et numéros de ligne
    search = grep -n --heading --break
    
    # Recherche de TODOs
    todo = grep -n "TODO\\|FIXME\\|HACK"
    
    # Recherche dans l'historique
    hist-search = log -p -S
    
    # Recherche de fonctions JavaScript
    func = grep -E "function [a-zA-Z]+\\("
```

### ✨ Astuces

```bash
# Recherche avec plusieurs motifs ET
git grep --all-match -e "pattern1" -e "pattern2"

# Recherche dans les fichiers modifiés non commités
git grep "motif" HEAD

# Recherche parallèle (plus rapide)
git grep --threads 8 "motif"

# Recherche avec un maximum de correspondances
git grep -m 5 "motif"

# Combiner avec xargs pour des opérations bulk
git grep -l "old_name" | xargs sed -i 's/old_name/new_name/g'

# Recherche de lignes vides
git grep "^$"

# Recherche dans les messages de commit
git log --all --grep="motif"

# Pipeline complexe : trouver les fichiers avec le pattern et les éditer
git grep -l "TODO" | xargs $EDITOR
```

---

## git reflog - Journal des références

### 🎯 Objectif

`git reflog` est votre filet de sécurité ultime dans Git. Il enregistre chaque mouvement de HEAD et des branches, permettant de récupérer des commits "perdus", d'annuler des erreurs, et de retrouver des états précédents même après un rebase ou un reset destructif.

> [!warning] Durée de conservation Le reflog est local (non partagé avec les remotes) et les entrées sont conservées pendant 90 jours par défaut pour les commits accessibles, 30 jours pour les commits inaccessibles.

### 📖 Syntaxe de base

```bash
# Afficher le reflog de HEAD (par défaut)
git reflog

# Afficher le reflog d'une branche spécifique
git reflog show <branch>

# Format court (par défaut)
git reflog

# Format détaillé
git reflog show --all

# Avec dates relatives
git reflog --relative-date

# Avec dates absolues
git reflog --date=iso
```

### 🔧 Options et filtres

```bash
# Limiter le nombre d'entrées
git reflog -n 10

# Depuis une date spécifique
git reflog --since="2 days ago"
git reflog --after="2024-01-01"

# Jusqu'à une date
git reflog --until="1 week ago"

# Format personnalisé
git reflog --format="%C(auto)%h %gd %gs"

# Afficher le diff
git reflog -p

# Afficher les stats
git reflog --stat

# Reflog de toutes les références
git reflog --all
```

### 🔍 Comprendre la sortie

```bash
$ git reflog
a1b2c3d HEAD@{0}: commit: Add new feature
e4f5g6h HEAD@{1}: rebase finished: returning to refs/heads/main
i7j8k9l HEAD@{2}: commit: Fix bug
m0n1o2p HEAD@{3}: checkout: moving from develop to main
```

**Décryptage** :

- `a1b2c3d` : Hash court du commit
- `HEAD@{0}` : Position dans le reflog (0 = plus récent)
- `commit: Add new feature` : Action effectuée et message

### 💡 Cas d'usage pratiques

**1. Récupérer un commit après un reset --hard**

```bash
# Vous avez fait un reset destructif par erreur
git reset --hard HEAD~3

# Trouver le commit perdu
git reflog

# Restaurer
git reset --hard HEAD@{1}
# ou avec le hash
git reset --hard a1b2c3d
```

**2. Récupérer une branche supprimée**

```bash
# Vous avez supprimé une branche par erreur
git branch -D feature-branch

# Trouver le dernier commit de cette branche
git reflog | grep "feature-branch"

# Recréer la branche
git branch feature-branch HEAD@{2}
# ou
git branch feature-branch <commit-hash>
```

**3. Annuler un rebase raté**

```bash
# Un rebase a mal tourné
git rebase main
# ... conflits, confusion ...

# Revenir à l'état avant le rebase
git reflog
git reset --hard HEAD@{1}  # ou le hash avant le rebase
```

**4. Retrouver des modifications après un commit --amend**

```bash
# Vous avez amendé un commit mais voulez l'ancienne version
git reflog

# Créer une branche depuis l'ancienne version
git branch old-version HEAD@{1}

# Ou voir les différences
git diff HEAD@{1} HEAD
```

**5. Récupérer du travail après un stash drop**

```bash
# Vous avez supprimé un stash par erreur
git stash drop

# Retrouver le stash dans le reflog
git reflog show --all | grep "stash"

# Récupérer le contenu
git stash apply <commit-hash>
# ou créer une branche
git branch recovered-stash <commit-hash>
```

### 🕰️ Naviguer dans le temps

```bash
# Revenir à l'état d'il y a 2 heures
git reset --hard HEAD@{2.hours.ago}

# Revenir à hier
git reset --hard HEAD@{yesterday}

# Revenir à une date précise
git reset --hard 'HEAD@{2024-01-15 14:30:00}'

# Voir ce que vous faisiez hier
git reflog --since=yesterday --until=today
```

> [!tip] Syntaxes temporelles
> 
> - `HEAD@{2.hours.ago}`
> - `HEAD@{yesterday}`
> - `HEAD@{3.days.ago}`
> - `HEAD@{2024-01-15}`
> - `HEAD@{2024-01-15 14:30:00}`

### 🗑️ Nettoyage du reflog

```bash
# Voir la date d'expiration configurée
git config gc.reflogExpire
git config gc.reflogExpireUnreachable

# Nettoyer les entrées expirées maintenant
git reflog expire --expire=now --all

# Définir une durée personnalisée
git reflog expire --expire=60.days.ago --all

# Nettoyer et optimiser le dépôt
git gc --prune=now

# Forcer le nettoyage agressif
git gc --aggressive --prune=now
```

> [!warning] Attention au nettoyage Une fois le reflog nettoyé et `git gc` exécuté, les commits inaccessibles sont définitivement perdus.

### ⚠️ Pièges courants

|Piège|Explication|Solution|
|---|---|---|
|Reflog partagé|Le reflog n'est pas poussé vers les remotes|Récupération locale uniquement|
|Expiration|Commits perdus après 30-90 jours|Agir vite ou configurer une durée plus longue|
|Confusion HEAD vs branche|Le reflog de HEAD ≠ reflog de la branche|Spécifier `git reflog show <branch>`|
|Clone frais|Pas de reflog dans un nouveau clone|Impossible de récupérer l'historique local perdu|

### 🎓 Bonnes pratiques

1. **Vérifier avant les opérations destructives** : Notez la position actuelle du HEAD
2. **Créer des branches de sécurité** : Avant un rebase ou reset complexe
3. **Ne pas compter sur le reflog à long terme** : C'est un filet de sécurité, pas une sauvegarde

```bash
# Avant une opération risquée
git branch backup-$(date +%Y%m%d-%H%M%S)

# Ou créer un tag
git tag backup-before-rebase

# Vérifier l'état actuel
git reflog | head -1
```

### ✨ Astuces

```bash
# Voir le reflog avec un graphe
git log --walk-reflogs --graph --oneline

# Comparer avec l'état d'il y a X temps
git diff HEAD@{1.hour.ago}

# Chercher une action spécifique
git reflog | grep "checkout\|rebase\|merge"

# Reflog d'une branche distante
git reflog show origin/main

# Voir seulement les commits (pas les checkouts)
git reflog | grep "commit:"

# Statistiques sur votre activité
git reflog --since="1 week ago" | wc -l

# Créer un alias pour voir facilement les dernières actions
git config --global alias.recent "reflog -n 20 --pretty=format:'%C(yellow)%h%Creset %gs %C(cyan)(%cr)%Creset'"

# Puis utiliser
git recent

# Récupérer un fichier d'un commit perdu
git show HEAD@{2}:path/to/file > recovered_file

# Voir tous les messages de commit récents
git reflog --format="%gs" | grep "commit:"

# Audit de sécurité : voir tous les checkouts
git reflog | grep "checkout: moving"
```

### 🆘 Scénario de récupération d'urgence

```bash
# Vous avez tout cassé et ne savez pas comment revenir en arrière
# 1. Ne paniquez pas, le reflog est là
git reflog

# 2. Trouvez le dernier état stable (généralement HEAD@{1} ou HEAD@{2})
# 3. Créez une branche de sauvegarde de l'état actuel
git branch save-current-state

# 4. Retournez à l'état stable
git reset --hard HEAD@{X}

# 5. Vérifiez que tout va bien
git status
git log --oneline -5

# 6. Si besoin, comparez avec l'état cassé
git diff save-current-state

# 7. Supprimez la branche de sauvegarde si tout est OK
git branch -D save-current-state
```

---

## 🎯 Récapitulatif

|Commande|Usage principal|Quand l'utiliser|
|---|---|---|
|`git blame`|Identifier l'auteur d'une ligne|Debug, compréhension du code, audit|
|`git bisect`|Trouver le commit qui introduit un bug|Régression, recherche de bug|
|`git grep`|Rechercher dans le code et l'historique|Refactoring, audit, analyse|
|`git reflog`|Récupérer des commits perdus|Urgence, annulation d'erreurs|

> [!tip] Combiner les commandes Ces outils sont encore plus puissants lorsqu'ils sont combinés :
> 
> - `git bisect` + `git grep` : trouver quand un pattern a été introduit
> - `git blame` + `git show` : comprendre le contexte complet d'une modification
> - `git reflog` + `git diff` : comparer avec un état précédent perdu

---

**🎓 Points clés à retenir :**

1. **git blame** : Pour comprendre l'origine et le contexte des modifications
2. **git bisect** : Pour une recherche efficace de bugs par dichotomie
3. **git grep** : Pour des recherches rapides et puissantes dans le code
4. **git reflog** : Votre filet de sécurité pour récupérer ce qui semble perdu