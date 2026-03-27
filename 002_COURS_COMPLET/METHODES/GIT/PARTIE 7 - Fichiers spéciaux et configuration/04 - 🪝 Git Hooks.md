

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

## Qu'est-ce qu'un hook ?

Les **hooks Git** sont des scripts personnalisés qui s'exécutent automatiquement à des moments précis du cycle de vie Git. Ils permettent d'automatiser des tâches, d'appliquer des règles de qualité ou de déclencher des actions avant ou après certaines opérations.

> [!info] Emplacement des hooks Les hooks se trouvent dans le répertoire `.git/hooks/` de votre dépôt. Par défaut, Git fournit des exemples avec l'extension `.sample` qui doivent être renommés pour être activés.

### 🎯 Pourquoi utiliser les hooks ?

- **Automatisation** : Exécuter des tests, vérifier le code, formater automatiquement
- **Qualité** : Empêcher les commits qui ne respectent pas certaines règles
- **Sécurité** : Bloquer les commits contenant des secrets ou données sensibles
- **Standardisation** : Garantir le respect des conventions d'équipe

### 📝 Caractéristiques des hooks

```bash
# Les hooks sont des fichiers exécutables
# Ils peuvent être écrits dans n'importe quel langage (bash, python, ruby, node...)
# Leur nom détermine quand ils s'exécutent
# Un code de retour non-zéro (erreur) annule l'opération en cours
```

> [!warning] Hooks non versionnés Les hooks dans `.git/hooks/` ne sont **pas versionnés** par défaut. Pour partager des hooks avec votre équipe, vous devez les placer ailleurs (ex: `scripts/hooks/`) et documenter leur installation, ou utiliser des outils comme `husky` (Node.js).

---

## Hooks côté client vs serveur

Git propose deux grandes catégories de hooks selon l'endroit où ils s'exécutent.

### 🖥️ Hooks côté client

Ils s'exécutent sur la machine du développeur, **localement**.

|Caractéristique|Description|
|---|---|
|**Localisation**|`.git/hooks/` du dépôt local|
|**Exécution**|Machine du développeur|
|**Partage**|Non versionnés par défaut|
|**Contournement**|Possibles avec `--no-verify`|
|**Usage principal**|Validation locale, formatage, tests rapides|

**Hooks clients courants :**

- `pre-commit` : Avant la création du commit
- `prepare-commit-msg` : Prépare le message de commit
- `commit-msg` : Valide le message de commit
- `post-commit` : Après la création du commit
- `pre-push` : Avant l'envoi vers le remote
- `post-checkout` : Après un checkout
- `post-merge` : Après un merge

> [!tip] Astuces pour les hooks clients
> 
> - Gardez-les rapides pour ne pas ralentir le workflow
> - Documentez comment les installer dans votre README
> - Considérez des outils comme `husky` ou `pre-commit` pour la gestion

### 🌐 Hooks côté serveur

Ils s'exécutent sur le serveur Git (GitHub, GitLab, serveur interne), lors des opérations de push.

|Caractéristique|Description|
|---|---|
|**Localisation**|Serveur Git distant|
|**Exécution**|Serveur lors du push|
|**Partage**|Centralisés|
|**Contournement**|Impossible (sauf accès admin)|
|**Usage principal**|Politique d'équipe stricte, CI/CD|

**Hooks serveurs courants :**

- `pre-receive` : Avant d'accepter des refs du client
- `update` : Comme pre-receive mais par branche
- `post-receive` : Après avoir accepté les refs (déploiements, notifications)

> [!info] Différence clé Les hooks **clients** peuvent être contournés par le développeur (`git commit --no-verify`), tandis que les hooks **serveurs** sont imposés à tous et ne peuvent pas être ignorés.

### 🆚 Comparaison pratique

```bash
# Hook CLIENT : Le développeur peut le contourner
git commit --no-verify  # Ignore pre-commit et commit-msg

# Hook SERVEUR : Impossible à contourner
git push  # Si le hook pre-receive rejette, le push échoue
```

**Stratégie recommandée :**

- **Hooks clients** : Feedback rapide, aide au développement (linting, formatage)
- **Hooks serveurs** : Règles strictes, sécurité, déclenchement CI/CD

---

## Hooks courants

Explorons en détail les trois hooks clients les plus utilisés.

### pre-commit

Le hook `pre-commit` s'exécute **juste avant** la création d'un commit, avant même que le message de commit ne soit demandé.

#### 🎯 Cas d'usage

- Vérifier le style du code (linting)
- Formater automatiquement le code
- Lancer des tests unitaires rapides
- Vérifier l'absence de secrets (clés API, tokens)
- Vérifier la présence de conflits non résolus

#### 📝 Structure de base

```bash
#!/bin/bash
# .git/hooks/pre-commit

# Si le script retourne 0 : le commit continue
# Si le script retourne non-zéro : le commit est annulé

echo "🔍 Exécution du pre-commit hook..."

# Votre logique ici
# ...

exit 0  # Succès
```

> [!warning] Fichiers staged uniquement Le pre-commit s'exécute sur les fichiers **staged** (ajoutés avec `git add`). Les modifications non staged ne sont pas concernées.

#### 💡 Exemple complet : Vérification de linting JavaScript

```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "🔍 Vérification du code JavaScript..."

# Récupérer les fichiers JS staged
FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.js$')

# Si aucun fichier JS, on sort
if [ -z "$FILES" ]; then
    exit 0
fi

# Vérifier si ESLint est installé
if ! command -v eslint &> /dev/null; then
    echo "❌ ESLint n'est pas installé"
    exit 1
fi

# Lancer ESLint
echo "$FILES" | xargs eslint

# Récupérer le code de sortie d'ESLint
RESULT=$?

if [ $RESULT -ne 0 ]; then
    echo "❌ ESLint a détecté des erreurs. Commit annulé."
    echo "💡 Corrigez les erreurs ou utilisez --no-verify pour forcer"
    exit 1
fi

echo "✅ Code validé avec succès"
exit 0
```

#### 🛠️ Installation et activation

```bash
# Créer le hook
touch .git/hooks/pre-commit

# Le rendre exécutable (obligatoire !)
chmod +x .git/hooks/pre-commit

# Éditer avec votre script
nano .git/hooks/pre-commit
```

> [!tip] Contourner temporairement Si vous devez exceptionnellement ignorer le pre-commit :
> 
> ```bash
> git commit --no-verify -m "Message"
> # ou
> git commit -n -m "Message"
> ```

---

### post-commit

Le hook `post-commit` s'exécute **juste après** qu'un commit a été créé avec succès. Il ne peut **pas annuler** le commit.

#### 🎯 Cas d'usage

- Envoyer des notifications (Slack, email)
- Générer des logs ou statistiques
- Mettre à jour des fichiers de documentation
- Déclencher des builds locaux
- Afficher des rappels ou informations

#### 📝 Structure de base

```bash
#!/bin/bash
# .git/hooks/post-commit

echo "✅ Commit créé avec succès !"

# Actions après le commit
# ...

# Le code de retour n'affecte pas le commit (déjà créé)
exit 0
```

> [!info] Pas d'annulation possible Contrairement au `pre-commit`, le `post-commit` ne peut pas empêcher le commit car celui-ci est déjà créé. Il sert uniquement à des actions post-traitement.

#### 💡 Exemple : Notification et statistiques

```bash
#!/bin/bash
# .git/hooks/post-commit

# Récupérer les infos du commit
COMMIT_HASH=$(git rev-parse HEAD)
COMMIT_MSG=$(git log -1 --pretty=%B)
AUTHOR=$(git log -1 --pretty=%an)
FILES_CHANGED=$(git diff-tree --no-commit-id --name-only -r HEAD | wc -l)

# Afficher un résumé
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Commit créé avec succès !"
echo "📝 Hash: ${COMMIT_HASH:0:7}"
echo "👤 Auteur: $AUTHOR"
echo "📄 Fichiers modifiés: $FILES_CHANGED"
echo "💬 Message: $COMMIT_MSG"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Logger dans un fichier
echo "$(date '+%Y-%m-%d %H:%M:%S') - $COMMIT_HASH - $AUTHOR" >> .git/commit-log.txt

exit 0
```

#### 💡 Exemple : Rappel de push

```bash
#!/bin/bash
# .git/hooks/post-commit

# Vérifier si la branche a des commits non pushés
UNPUSHED=$(git log @{u}.. 2>/dev/null | wc -l)

if [ "$UNPUSHED" -gt 3 ]; then
    echo ""
    echo "⚠️  Vous avez $UNPUSHED commits non pushés"
    echo "💡 Pensez à faire un 'git push' bientôt"
    echo ""
fi

exit 0
```

---

### pre-push

Le hook `pre-push` s'exécute **juste avant** qu'un push ne soit envoyé vers le dépôt distant. Il peut **annuler** le push.

#### 🎯 Cas d'usage

- Lancer une suite de tests complète
- Vérifier que la branche est à jour
- Empêcher le push sur certaines branches (protection)
- Valider que tous les commits ont un message correct
- Vérifier l'absence de code de debug (console.log, debugger)

#### 📝 Structure de base

```bash
#!/bin/bash
# .git/hooks/pre-push

# Paramètres automatiques fournis par Git :
# $1 = remote name (ex: origin)
# $2 = remote URL

REMOTE="$1"
URL="$2"

echo "🚀 Préparation du push vers $REMOTE..."

# Votre logique de validation
# ...

# Retourner 0 pour autoriser le push
# Retourner non-zéro pour annuler le push
exit 0
```

> [!warning] Hook bloquant Le pre-push peut ralentir significativement votre workflow si vous lancez des tests longs. Réservez-le pour des validations importantes.

#### 💡 Exemple : Lancer les tests avant push

```bash
#!/bin/bash
# .git/hooks/pre-push

echo "🧪 Lancement des tests avant push..."

# Lancer la suite de tests
npm test

# Récupérer le résultat
TEST_RESULT=$?

if [ $TEST_RESULT -ne 0 ]; then
    echo ""
    echo "❌ Les tests ont échoué !"
    echo "🚫 Push annulé"
    echo "💡 Corrigez les tests ou utilisez --no-verify pour forcer"
    echo ""
    exit 1
fi

echo "✅ Tous les tests passent, push autorisé"
exit 0
```

#### 💡 Exemple : Protection de la branche main

```bash
#!/bin/bash
# .git/hooks/pre-push

# Récupérer la branche actuelle
CURRENT_BRANCH=$(git symbolic-ref --short HEAD)

# Bloquer le push direct sur main
if [ "$CURRENT_BRANCH" = "main" ]; then
    echo ""
    echo "🚫 Push direct sur 'main' interdit !"
    echo "💡 Créez une branche et faites une Pull Request"
    echo ""
    exit 1
fi

echo "✅ Push autorisé depuis la branche $CURRENT_BRANCH"
exit 0
```

#### 💡 Exemple : Vérifier l'absence de code de debug

```bash
#!/bin/bash
# .git/hooks/pre-push

echo "🔍 Vérification du code de debug..."

# Récupérer les commits qui vont être pushés
while read local_ref local_sha remote_ref remote_sha
do
    if [ "$local_sha" != "0000000000000000000000000000000000000000" ]; then
        # Chercher console.log et debugger dans les nouveaux commits
        FORBIDDEN=$(git diff "$remote_sha..$local_sha" --name-only | \
                    xargs grep -n -E "(console\.log|debugger)" 2>/dev/null)
        
        if [ -n "$FORBIDDEN" ]; then
            echo ""
            echo "❌ Code de debug détecté :"
            echo "$FORBIDDEN"
            echo ""
            echo "🚫 Push annulé"
            echo "💡 Supprimez les console.log et debugger"
            exit 1
        fi
    fi
done

echo "✅ Aucun code de debug détecté"
exit 0
```

> [!tip] Contourner le pre-push Comme pour pre-commit, vous pouvez ignorer le hook :
> 
> ```bash
> git push --no-verify
> # ou
> git push -n
> ```

---

## Exemples d'utilisation

Voici des cas d'usage pratiques et complets pour illustrer la puissance des hooks.

### 📋 Exemple 1 : Validation du format de message de commit

**Hook utilisé :** `commit-msg`

```bash
#!/bin/bash
# .git/hooks/commit-msg

# Le message de commit est dans $1
COMMIT_MSG_FILE=$1
COMMIT_MSG=$(cat "$COMMIT_MSG_FILE")

# Format attendu : type(scope): message
# Exemples: feat(auth): ajout login, fix(api): correction bug
PATTERN="^(feat|fix|docs|style|refactor|test|chore)(\(.+\))?: .{10,}$"

if ! echo "$COMMIT_MSG" | grep -qE "$PATTERN"; then
    echo ""
    echo "❌ Format de message de commit invalide !"
    echo ""
    echo "📋 Format attendu :"
    echo "   type(scope): description"
    echo ""
    echo "📌 Types valides : feat, fix, docs, style, refactor, test, chore"
    echo "📌 Le message doit faire au moins 10 caractères"
    echo ""
    echo "✅ Exemples valides :"
    echo "   feat(auth): ajout du système de login"
    echo "   fix(api): correction du bug de timeout"
    echo "   docs: mise à jour du README"
    echo ""
    exit 1
fi

exit 0
```

**Installation :**

```bash
# Créer et activer le hook
touch .git/hooks/commit-msg
chmod +x .git/hooks/commit-msg
# Copier le script ci-dessus
```

---

### 🔒 Exemple 2 : Détection de secrets et données sensibles

**Hook utilisé :** `pre-commit`

```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "🔐 Vérification des secrets..."

# Patterns à rechercher
PATTERNS=(
    "password\s*=\s*['\"][^'\"]{3,}['\"]"
    "api[_-]?key\s*=\s*['\"][^'\"]{10,}['\"]"
    "secret\s*=\s*['\"][^'\"]{10,}['\"]"
    "token\s*=\s*['\"][^'\"]{10,}['\"]"
    "-----BEGIN (RSA |DSA )?PRIVATE KEY-----"
    "aws_access_key_id"
    "mongodb(\+srv)?:\/\/[^:]+:[^@]+"
)

# Fichiers staged
FILES=$(git diff --cached --name-only --diff-filter=ACM)

FOUND=0
for pattern in "${PATTERNS[@]}"; do
    for file in $FILES; do
        if git diff --cached "$file" | grep -qiE "$pattern"; then
            echo "❌ Potentiel secret détecté dans : $file"
            echo "   Pattern : $pattern"
            FOUND=1
        fi
    done
done

if [ $FOUND -eq 1 ]; then
    echo ""
    echo "🚫 Commit annulé : secrets potentiels détectés"
    echo "💡 Vérifiez les fichiers mentionnés ci-dessus"
    echo "💡 Utilisez des variables d'environnement pour les secrets"
    exit 1
fi

echo "✅ Aucun secret détecté"
exit 0
```

---

### 🎨 Exemple 3 : Formatage automatique du code

**Hook utilisé :** `pre-commit`

```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "🎨 Formatage automatique du code..."

# Récupérer les fichiers JS et TS staged
FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(js|ts)$')

if [ -z "$FILES" ]; then
    exit 0
fi

# Vérifier si prettier est installé
if ! command -v prettier &> /dev/null; then
    echo "⚠️  Prettier n'est pas installé, formatage ignoré"
    exit 0
fi

# Formater les fichiers
echo "$FILES" | xargs prettier --write

# Re-stager les fichiers formatés
echo "$FILES" | xargs git add

echo "✅ Fichiers formatés et re-stagés"
exit 0
```

> [!tip] Formatage non bloquant Ce hook formate automatiquement sans bloquer le commit. Les fichiers sont re-stagés après formatage.

---

### 📊 Exemple 4 : Rapport de couverture de tests

**Hook utilisé :** `pre-push`

```bash
#!/bin/bash
# .git/hooks/pre-push

echo "📊 Vérification de la couverture de tests..."

# Lancer les tests avec couverture
npm run test:coverage > /dev/null 2>&1

# Vérifier si le rapport de couverture existe
if [ ! -f "coverage/coverage-summary.json" ]; then
    echo "⚠️  Impossible de générer le rapport de couverture"
    exit 0
fi

# Extraire le pourcentage de couverture (nécessite jq)
if command -v jq &> /dev/null; then
    COVERAGE=$(jq '.total.lines.pct' coverage/coverage-summary.json)
    MIN_COVERAGE=80
    
    if (( $(echo "$COVERAGE < $MIN_COVERAGE" | bc -l) )); then
        echo ""
        echo "❌ Couverture de tests insuffisante : ${COVERAGE}%"
        echo "🎯 Minimum requis : ${MIN_COVERAGE}%"
        echo "🚫 Push annulé"
        echo ""
        exit 1
    fi
    
    echo "✅ Couverture de tests : ${COVERAGE}% (OK)"
fi

exit 0
```

---

### 🔄 Exemple 5 : Hook multi-langage avec détection automatique

**Hook utilisé :** `pre-commit`

```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "🔍 Analyse du code..."

# Fonction pour vérifier Python
check_python() {
    local files=$(git diff --cached --name-only --diff-filter=ACM | grep '\.py$')
    if [ -n "$files" ]; then
        echo "🐍 Vérification Python..."
        if command -v flake8 &> /dev/null; then
            echo "$files" | xargs flake8 || return 1
        fi
    fi
    return 0
}

# Fonction pour vérifier JavaScript/TypeScript
check_javascript() {
    local files=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(js|ts)x?$')
    if [ -n "$files" ]; then
        echo "📜 Vérification JavaScript/TypeScript..."
        if command -v eslint &> /dev/null; then
            echo "$files" | xargs eslint || return 1
        fi
    fi
    return 0
}

# Fonction pour vérifier Go
check_go() {
    local files=$(git diff --cached --name-only --diff-filter=ACM | grep '\.go$')
    if [ -n "$files" ]; then
        echo "🔵 Vérification Go..."
        if command -v golint &> /dev/null; then
            echo "$files" | xargs golint || return 1
        fi
        echo "$files" | xargs go vet || return 1
    fi
    return 0
}

# Exécuter toutes les vérifications
FAILED=0

check_python || FAILED=1
check_javascript || FAILED=1
check_go || FAILED=1

if [ $FAILED -eq 1 ]; then
    echo ""
    echo "❌ Des erreurs ont été détectées"
    echo "🚫 Commit annulé"
    exit 1
fi

echo "✅ Toutes les vérifications ont réussi"
exit 0
```

---

### 🛠️ Bonnes pratiques pour les hooks

> [!tip] Rendre les hooks rapides
> 
> - Limitez les opérations lourdes dans pre-commit
> - Utilisez pre-push pour les tests longs
> - Cachez les résultats quand possible

> [!tip] Documenter l'installation Créez un script d'installation pour votre équipe :
> 
> ```bash
> # install-hooks.sh
> #!/bin/bash
> cp scripts/hooks/* .git/hooks/
> chmod +x .git/hooks/*
> echo "✅ Hooks installés"
> ```

> [!tip] Utiliser des outils dédiés Pour des projets professionnels, considérez :
> 
> - **husky** (Node.js) : Gestion simplifiée des hooks
> - **pre-commit** (Python) : Framework multi-langage
> - **lefthook** (Go) : Rapide et multi-langage

> [!warning] Ne jamais commiter de hooks actifs Les hooks dans `.git/hooks/` ne sont pas versionnés. Stockez-les ailleurs et documentez l'installation.

### 🎯 Pièges courants

1. **Oublier chmod +x** : Le hook ne s'exécutera pas
2. **Chemins relatifs** : Utilisez des chemins absolus ou relatifs au root Git
3. **Environnement différent** : Les hooks s'exécutent dans un environnement minimal
4. **Shebang manquant** : Toujours inclure `#!/bin/bash` ou équivalent
5. **Hooks trop lents** : Frustre les développeurs qui vont les contourner

---

> [!example] Résumé des hooks courants
> 
> |Hook|Moment|Peut bloquer|Usage principal|
> |---|---|---|---|
> |**pre-commit**|Avant le commit|✅ Oui|Lint, format, tests rapides|
> |**commit-msg**|Validation du message|✅ Oui|Format de message|
> |**post-commit**|Après le commit|❌ Non|Notifications, logs|
> |**pre-push**|Avant le push|✅ Oui|Tests complets, validations|
> |**pre-receive** (serveur)|Avant acceptation push|✅ Oui|Politique d'équipe|
> |**post-receive** (serveur)|Après acceptation push|❌ Non|CI/CD, déploiement|