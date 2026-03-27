

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

La portabilité d'un script shell garantit qu'il pourra s'exécuter sur différents systèmes Unix/Linux sans modification. Les scripts portables sont essentiels dans les environnements hétérogènes (serveurs, containers, machines de développement diverses) et pour les projets open source destinés à une large audience.

> [!info] Pourquoi la portabilité est importante
> 
> - **Universalité** : Votre script fonctionne sur Debian, Red Hat, macOS, BSD, Alpine, etc.
> - **Maintenance** : Moins de versions spécifiques à maintenir
> - **Fiabilité** : Évite les comportements inattendus liés aux différences d'implémentation
> - **Professionnalisme** : Montre une compréhension approfondie des systèmes Unix

---

## Shebang portable avec /usr/bin/env bash

### Concept

Le **shebang** (`#!`) en première ligne d'un script indique quel interpréteur utiliser. L'emplacement de Bash varie selon les systèmes, rendant un chemin absolu problématique.

### Syntaxe recommandée

```bash
#!/usr/bin/env bash
```

### Comparaison des approches

|Shebang|Avantages|Inconvénients|
|---|---|---|
|`#!/bin/bash`|Simple, direct|Échoue si bash est ailleurs (ex: `/usr/local/bin/bash` sur macOS avec Homebrew)|
|`#!/usr/bin/bash`|Standard sur certains systèmes|N'existe pas sur tous les Unix|
|`#!/usr/bin/env bash`|✅ Trouve bash dans le PATH|Dépend de la configuration du PATH|
|`#!/bin/sh`|Maximum de portabilité|Ne permet pas les fonctionnalités spécifiques à Bash|

### Pourquoi utiliser `/usr/bin/env`

```bash
#!/usr/bin/env bash
# Ce script trouvera bash automatiquement dans le PATH de l'utilisateur
# Fonctionne sur Linux, macOS, BSD, etc.

echo "Bash trouvé : $BASH"
echo "Version : $BASH_VERSION"
```

> [!tip] Astuce pratique La commande `env` est presque toujours située à `/usr/bin/env` sur tous les systèmes Unix, ce qui en fait un point d'ancrage fiable.

### Cas particuliers

```bash
#!/usr/bin/env -S bash -e -u
# L'option -S permet de passer des arguments à bash
# -e : exit on error
# -u : exit on undefined variable
# Note : -S n'est pas supporté sur tous les systèmes (macOS ancien, Solaris)
```

> [!warning] Attention avec les options dans le shebang Certains systèmes limitent le nombre d'arguments dans le shebang ou ne supportent pas `-S`. Pour une portabilité maximale, définissez les options dans le script :
> 
> ```bash
> #!/usr/bin/env bash
> set -euo pipefail
> ```

### Pièges courants

1. **Espaces dans le chemin** : `/usr/bin/env` ne gère pas bien les chemins avec espaces
2. **Scripts setuid** : `/usr/bin/env` peut poser des problèmes de sécurité avec les scripts setuid
3. **Environnements restreints** : Certains conteneurs ou chroots peuvent avoir un PATH minimal

```bash
#!/usr/bin/env bash
# ✅ BIEN : Vérification de l'environnement
if [[ -z "${BASH_VERSION:-}" ]]; then
    echo "Erreur : Ce script nécessite Bash" >&2
    exit 1
fi
```

---

## Éviter les bashismes si sh est requis

### Qu'est-ce qu'un bashisme ?

Un **bashisme** est une fonctionnalité ou syntaxe spécifique à Bash qui n'existe pas dans le shell POSIX standard (`sh`). Si votre script doit fonctionner avec `/bin/sh`, vous devez les éviter.

> [!info] Quand utiliser sh vs bash
> 
> - **Utilisez `#!/bin/sh`** pour : scripts système de base, init scripts, scripts embarqués, maximum de portabilité
> - **Utilisez `#!/usr/bin/env bash`** pour : scripts complexes, interaction utilisateur, fonctionnalités avancées

### Bashismes courants à éviter

#### 1. Doubles crochets `[[ ]]`

```bash
# ❌ BASHISME
if [[ "$var" == "valeur" ]]; then
    echo "égal"
fi

# ✅ POSIX
if [ "$var" = "valeur" ]; then
    echo "égal"
fi
```

#### 2. Tableaux

```bash
# ❌ BASHISME
array=(un deux trois)
echo "${array[1]}"

# ✅ POSIX : utiliser des variables séparées ou une chaîne
set -- un deux trois
echo "$2"  # Accès au deuxième élément
```

#### 3. Syntaxe `[[ ]]` avec regex

```bash
# ❌ BASHISME
if [[ "$email" =~ ^[a-z]+@[a-z]+\.[a-z]+$ ]]; then
    echo "Email valide"
fi

# ✅ POSIX : utiliser expr ou case
case "$email" in
    *@*.*)
        echo "Email probablement valide"
        ;;
esac
```

#### 4. Here-strings `<<<`

```bash
# ❌ BASHISME
grep "pattern" <<< "$variable"

# ✅ POSIX
echo "$variable" | grep "pattern"
# ou
printf '%s\n' "$variable" | grep "pattern"
```

#### 5. Substitution de processus `<()` et `>()`

```bash
# ❌ BASHISME
diff <(sort file1) <(sort file2)

# ✅ POSIX
sort file1 > /tmp/sorted1.$$
sort file2 > /tmp/sorted2.$$
diff /tmp/sorted1.$$ /tmp/sorted2.$$
rm -f /tmp/sorted1.$$ /tmp/sorted2.$$
```

#### 6. Expansion de brace `{}`

```bash
# ❌ BASHISME
echo {1..10}
cp file.{txt,bak}

# ✅ POSIX
seq 1 10
cp file.txt file.bak
```

#### 7. Arithmétique avec `(( ))`

```bash
# ❌ BASHISME
((count++))
if ((count > 5)); then
    echo "Plus de 5"
fi

# ✅ POSIX
count=$((count + 1))
if [ "$count" -gt 5 ]; then
    echo "Plus de 5"
fi
```

#### 8. Variables spéciales Bash

```bash
# ❌ BASHISME
echo "$RANDOM"
echo "${BASH_VERSION}"
echo "${PIPESTATUS[@]}"

# ✅ POSIX : utiliser des alternatives
# Pour random : utiliser /dev/urandom ou awk
random=$(od -An -N2 -i /dev/urandom | tr -d ' ')
```

### Tableau récapitulatif

|Fonctionnalité|Bashisme|Alternative POSIX|
|---|---|---|
|Test avancé|`[[ ]]`|`[ ]`|
|Égalité|`==`|`=`|
|Regex|`=~`|`case` ou `expr`|
|Tableaux|`array=()`|Variables séparées ou `set`|
|Arithmétique|`((expr))`|`$((expr))` ou `expr`|
|Here-string|`<<< "$var"`|`echo "$var" \|`|

> [!warning] Piège : dash vs bash Sur de nombreux systèmes Debian/Ubuntu, `/bin/sh` pointe vers `dash`, un shell POSIX strict qui rejette tous les bashismes. Testez vos scripts avec dash !

### Test de compatibilité sh

```bash
# Pour tester si votre script est compatible POSIX
sh -n votre_script.sh  # Vérification syntaxique
dash votre_script.sh   # Exécution avec dash (si disponible)

# Ou utilisez shellcheck avec l'option shell
shellcheck -s sh votre_script.sh
```

---

## Vérification de version de Bash

### Pourquoi vérifier la version

Certaines fonctionnalités Bash ne sont disponibles qu'à partir d'une version spécifique. Par exemple :

- Bash 4.0+ : tableaux associatifs
- Bash 4.3+ : `declare -n` (nameref)
- Bash 5.0+ : nouvelles options de `shopt`

> [!info] Distribution des versions
> 
> - **macOS** : livre Bash 3.2 par défaut (licence GPLv2)
> - **Linux moderne** : généralement Bash 4.4 ou 5.x
> - **Serveurs anciens** : peuvent avoir Bash 3.x ou 4.0

### Méthode de vérification

```bash
#!/usr/bin/env bash

# Variable intégrée contenant la version
echo "Version de Bash : $BASH_VERSION"
# Exemple de sortie : 5.1.16(1)-release

# Extraire le numéro de version majeure
BASH_MAJOR="${BASH_VERSION%%.*}"
echo "Version majeure : $BASH_MAJOR"
```

### Vérification de version minimale

```bash
#!/usr/bin/env bash

# Fonction pour comparer les versions
check_bash_version() {
    local required_major=$1
    local required_minor=${2:-0}
    
    # Extraction de la version actuelle
    local current_major="${BASH_VERSION%%.*}"
    local version_rest="${BASH_VERSION#*.}"
    local current_minor="${version_rest%%.*}"
    
    # Comparaison
    if ((current_major < required_major)) || \
       ((current_major == required_major && current_minor < required_minor)); then
        echo "Erreur : Ce script nécessite Bash ${required_major}.${required_minor}+" >&2
        echo "Version actuelle : ${BASH_VERSION}" >&2
        exit 1
    fi
}

# Vérifier Bash 4.0 minimum
check_bash_version 4 0

# Le reste du script peut utiliser les fonctionnalités Bash 4+
declare -A config  # Tableau associatif (Bash 4+)
config[host]="localhost"
config[port]="8080"
```

### Vérification simplifiée

```bash
#!/usr/bin/env bash

# Vérification rapide de la version majeure
if ((BASH_VERSINFO[0] < 4)); then
    echo "Erreur : Bash 4+ requis (version actuelle : $BASH_VERSION)" >&2
    exit 1
fi

# BASH_VERSINFO est un tableau :
# [0] = version majeure
# [1] = version mineure
# [2] = patch level
# [3] = build version
# [4] = release status
# [5] = valeur de MACHTYPE
```

### Adaptation selon la version

```bash
#!/usr/bin/env bash

# Script qui s'adapte à la version disponible
if ((BASH_VERSINFO[0] >= 4)); then
    # Utiliser les tableaux associatifs (Bash 4+)
    declare -A users
    users[alice]="admin"
    users[bob]="user"
else
    # Fallback pour Bash 3.x
    # Utiliser des variables classiques ou des fichiers temporaires
    echo "alice:admin" > /tmp/users.$$
    echo "bob:user" >> /tmp/users.$$
fi
```

> [!tip] Conseil pour macOS Si vous développez sur macOS et avez besoin de Bash 4+, installez-le via Homebrew :
> 
> ```bash
> brew install bash
> # Puis utilisez /usr/local/bin/bash ou /opt/homebrew/bin/bash
> ```

### Pièges courants

```bash
# ❌ MAUVAIS : comparaison de chaînes
if [[ "$BASH_VERSION" > "4.0" ]]; then
    # Ceci compare alphabétiquement, pas numériquement !
    # "3.9" > "4.0" retournerait vrai
    echo "Bash 4+"
fi

# ✅ BON : comparaison numérique
if ((BASH_VERSINFO[0] >= 4)); then
    echo "Bash 4+"
fi
```

---

## Commandes POSIX vs GNU

### Le problème de la portabilité des commandes

Les utilitaires Unix ont deux principales implémentations :

- **POSIX** : standard minimal, disponible partout
- **GNU** : version enrichie (GNU coreutils), standard sur Linux

> [!warning] Piège majeur Un script qui fonctionne sur Linux (GNU) peut échouer sur macOS/BSD (POSIX) et vice-versa, car les options et comportements diffèrent.

### Différences importantes par commande

#### `sed` - Stream Editor

```bash
# ❌ GNU sed (Linux) : -i sans extension
sed -i 's/foo/bar/g' fichier.txt

# ✅ POSIX/BSD sed (macOS) : -i nécessite une extension
sed -i '' 's/foo/bar/g' fichier.txt

# ✅ PORTABLE : créer un fichier temporaire
sed 's/foo/bar/g' fichier.txt > fichier.txt.tmp
mv fichier.txt.tmp fichier.txt

# Ou détection automatique
if sed --version 2>/dev/null | grep -q GNU; then
    # GNU sed
    sed -i 's/foo/bar/g' fichier.txt
else
    # BSD sed
    sed -i '' 's/foo/bar/g' fichier.txt
fi
```

#### `grep` - Recherche de motifs

```bash
# ❌ GNU grep : -P pour Perl regex
grep -P '\d+' fichier.txt

# ✅ POSIX : ERE avec -E
grep -E '[0-9]+' fichier.txt

# ❌ GNU : --color
grep --color=auto "pattern" fichier.txt

# ✅ PORTABLE : sans color ou détection
if grep --help 2>&1 | grep -q -- --color; then
    grep --color=auto "pattern" fichier.txt
else
    grep "pattern" fichier.txt
fi
```

#### `date` - Manipulation de dates

```bash
# ❌ GNU date : calcul de date
date -d "2 days ago" +%Y-%m-%d
date -d "@1234567890"

# ✅ BSD date (macOS) : syntaxe différente
date -v -2d +%Y-%m-%d
date -r 1234567890

# ✅ PORTABLE : utiliser une fonction
get_date_n_days_ago() {
    local days=$1
    if date --version 2>/dev/null | grep -q GNU; then
        # GNU date
        date -d "${days} days ago" +%Y-%m-%d
    else
        # BSD date
        date -v -"${days}"d +%Y-%m-%d
    fi
}
```

#### `stat` - Informations sur fichiers

```bash
# ❌ GNU stat
stat -c '%s' fichier.txt  # Taille du fichier

# ❌ BSD stat
stat -f '%z' fichier.txt  # Taille du fichier

# ✅ PORTABLE : utiliser une solution alternative
get_file_size() {
    local file=$1
    if stat -c '%s' "$file" 2>/dev/null; then
        # GNU stat
        return
    else
        # BSD stat
        stat -f '%z' "$file"
    fi
}

# Ou encore mieux : utiliser wc ou ls
wc -c < fichier.txt | tr -d ' '
```

#### `find` - Recherche de fichiers

```bash
# ❌ GNU find : -printf
find . -type f -printf '%f\n'

# ✅ POSIX : utiliser -exec
find . -type f -exec basename {} \;

# ❌ GNU find : -delete
find . -name "*.tmp" -delete

# ✅ POSIX : utiliser -exec rm
find . -name "*.tmp" -exec rm {} \;
# ou plus sûr
find . -name "*.tmp" -exec rm {} +
```

#### `xargs` - Construction de commandes

```bash
# ❌ GNU xargs : -r (ne pas exécuter si stdin vide)
find . -name "*.log" | xargs -r rm

# ✅ PORTABLE : vérification explicite
files=$(find . -name "*.log")
if [ -n "$files" ]; then
    echo "$files" | xargs rm
fi

# ❌ GNU xargs : -d pour délimiteur
find . -print0 | xargs -0 -d '\n' command

# ✅ POSIX : utiliser -0 seul (supporté partout pour null)
find . -print0 | xargs -0 command
```

#### `readlink` - Résolution de liens

```bash
# ❌ GNU readlink : -f pour chemin canonique
readlink -f fichier.txt

# ❌ BSD readlink : pas de -f
# ✅ PORTABLE : fonction de résolution
realpath_portable() {
    local path=$1
    if command -v realpath >/dev/null 2>&1; then
        realpath "$path"
    elif readlink -f "$path" 2>/dev/null; then
        return
    else
        # Fallback manuel
        (cd "$(dirname "$path")" && pwd -P)/$(basename "$path")
    fi
}
```

### Tableau récapitulatif des différences

|Commande|GNU (Linux)|BSD/POSIX (macOS)|Solution portable|
|---|---|---|---|
|`sed -i`|`sed -i`|`sed -i ''`|Fichier temporaire|
|`grep -P`|Perl regex|Non supporté|`grep -E` (ERE)|
|`date -d`|Calcul de date|Syntaxe différente|Fonction de détection|
|`stat`|`-c` format|`-f` format|`wc`, `ls`, ou fonction|
|`find -printf`|Formatage|Non supporté|`-exec` avec commandes|
|`readlink -f`|Canonique|Non supporté|`realpath` ou fonction|
|`xargs -r`|Skip si vide|Non supporté|Test explicite|

> [!tip] Stratégie de portabilité
> 
> 1. **Préférez les options POSIX** : utilisez le plus petit dénominateur commun
> 2. **Détectez l'environnement** : testez la présence d'options avec `--help` ou `--version`
> 3. **Créez des wrappers** : fonctions qui s'adaptent à l'environnement
> 4. **Testez sur plusieurs OS** : Linux, macOS, BSD si possible

### Fonction de détection globale

```bash
#!/usr/bin/env bash

# Détection de l'environnement au début du script
detect_environment() {
    # Détection OS
    case "$(uname -s)" in
        Linux*)     OS_TYPE="Linux";;
        Darwin*)    OS_TYPE="macOS";;
        *BSD)       OS_TYPE="BSD";;
        *)          OS_TYPE="Unknown";;
    esac
    
    # Détection GNU vs BSD tools
    if date --version 2>/dev/null | grep -q GNU; then
        DATE_TYPE="GNU"
    else
        DATE_TYPE="BSD"
    fi
    
    if sed --version 2>/dev/null | grep -q GNU; then
        SED_TYPE="GNU"
    else
        SED_TYPE="BSD"
    fi
    
    export OS_TYPE DATE_TYPE SED_TYPE
}

# Utilisation
detect_environment

if [[ "$SED_TYPE" == "GNU" ]]; then
    sed -i 's/foo/bar/' fichier.txt
else
    sed -i '' 's/foo/bar/' fichier.txt
fi
```

---

## Tests de compatibilité

### Stratégie de test multi-plateforme

Pour garantir la portabilité, il est essentiel de tester vos scripts sur différents environnements.

> [!info] Philosophie du test Un script portable doit être testé sur au moins deux types d'environnements différents (Linux et BSD/macOS minimum) avant d'être considéré comme production-ready.

### Outils de vérification statique

#### ShellCheck - L'outil indispensable

```bash
# Installation
# Ubuntu/Debian
sudo apt install shellcheck

# macOS
brew install shellcheck

# Utilisation basique
shellcheck votre_script.sh

# Vérification POSIX stricte
shellcheck -s sh votre_script.sh

# Vérification Bash
shellcheck -s bash votre_script.sh

# Ignorer certains avertissements
shellcheck -e SC2034,SC2086 votre_script.sh
```

**Exemple de sortie ShellCheck** :

```bash
#!/bin/bash
name="Alice"
echo "Hello $name"  # Pas de problème

# ShellCheck détectera :
if [ $name == "Alice" ]; then  # SC2086 et SC2039
    echo "Found"
fi

# ✅ Correction suggérée :
if [ "$name" = "Alice" ]; then
    echo "Found"
fi
```

> [!tip] Intégration ShellCheck Intégrez ShellCheck dans votre workflow :
> 
> - Hook Git pre-commit
> - Pipeline CI/CD
> - Plugin éditeur (VS Code, Vim, etc.)

#### Checkbashisms - Détecteur de bashismes

```bash
# Installation (Debian/Ubuntu)
sudo apt install devscripts

# Utilisation
checkbashisms votre_script.sh

# Exemple de détection
# Script : script.sh
#!/bin/sh
if [[ "$var" == "value" ]]; then  # Bashisme détecté
    echo "OK"
fi

# Sortie :
# possible bashisme in script.sh line 2 ([[ ]] test):
# if [[ "$var" == "value" ]]; then
```

### Tests manuels sur différents shells

```bash
# Test avec différents shells
bash votre_script.sh    # Bash
sh votre_script.sh      # Shell POSIX par défaut
dash votre_script.sh    # Dash (Debian Almquist Shell)
ksh votre_script.sh     # Korn Shell
zsh votre_script.sh     # Z Shell

# Vérification syntaxique sans exécution
bash -n votre_script.sh
sh -n votre_script.sh
```

### Conteneurs Docker pour tests multi-OS

```bash
# Créer un Dockerfile de test
cat > Dockerfile.test << 'EOF'
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y bash shellcheck
COPY votre_script.sh /test/
WORKDIR /test
RUN shellcheck votre_script.sh
RUN bash votre_script.sh
EOF

# Construire et tester
docker build -f Dockerfile.test -t script-test .

# Tester sur Alpine (utilise ash/busybox)
docker run --rm -v "$PWD:/scripts" alpine:latest sh /scripts/votre_script.sh

# Tester sur Debian
docker run --rm -v "$PWD:/scripts" debian:latest bash /scripts/votre_script.sh

# Tester sur CentOS
docker run --rm -v "$PWD:/scripts" centos:latest bash /scripts/votre_script.sh
```

### Framework de test : BATS

**BATS** (Bash Automated Testing System) permet d'écrire des tests unitaires pour vos scripts.

```bash
# Installation
# macOS
brew install bats-core

# Linux
git clone https://github.com/bats-core/bats-core.git
cd bats-core
sudo ./install.sh /usr/local

# Exemple de fichier de test : test_script.bats
#!/usr/bin/env bats

# Test basique
@test "Script s'exécute sans erreur" {
    run ./votre_script.sh
    [ "$status" -eq 0 ]
}

# Test de sortie
@test "Script affiche le bon message" {
    run ./votre_script.sh
    [ "$output" = "Hello World" ]
}

# Test avec argument
@test "Script accepte un argument" {
    run ./votre_script.sh test
    [ "$status" -eq 0 ]
    [[ "$output" =~ "test" ]]
}

# Test de création de fichier
@test "Script crée un fichier" {
    run ./votre_script.sh create
    [ -f "output.txt" ]
    rm -f "output.txt"  # Cleanup
}

# Exécution des tests
# bats test_script.bats
```

### Checklist de compatibilité

> [!example] Checklist avant déploiement
> 
> **Syntaxe et portabilité**
> 
> - [ ] Shebang portable (`#!/usr/bin/env bash`)
> - [ ] Version de Bash vérifiée si nécessaire
> - [ ] Pas de bashismes si `#!/bin/sh`
> - [ ] Quotage correct des variables (`"$var"`)
> - [ ] Gestion des espaces dans les noms de fichiers
> 
> **Commandes et outils**
> 
> - [ ] Utilisation d'options POSIX uniquement
> - [ ] Alternatives portables pour `sed -i`, `date`, etc.
> - [ ] Pas de dépendance à GNU-specific features
> - [ ] Vérification de présence des commandes requises
> 
> **Tests**
> 
> - [ ] ShellCheck sans erreur
> - [ ] Checkbashisms validé (si sh)
> - [ ] Testé sur Linux
> - [ ] Testé sur macOS ou BSD
> - [ ] Tests BATS écrits et passants
> 
> **Robustesse**
> 
> - [ ] Gestion des erreurs (`set -e`, `set -u`)
> - [ ] Validation des entrées utilisateur
> - [ ] Messages d'erreur informatifs
> - [ ] Code de sortie approprié

### Script de test automatique

```bash
#!/usr/bin/env bash
# test_portability.sh - Script pour tester la portabilité

set -euo pipefail

SCRIPT_TO_TEST="${1:?Usage: $0 <script_path>}"

echo "=== Test de portabilité pour $SCRIPT_TO_TEST ==="

# 1. Vérification statique avec ShellCheck
echo -e "\n[1/5] ShellCheck..."
if command -v shellcheck >/dev/null 2>&1; then
    shellcheck "$SCRIPT_TO_TEST" && echo "✅ ShellCheck OK" || echo "❌ ShellCheck a détecté des problèmes"
else
    echo "⚠️  ShellCheck non installé"
fi

# 2. Vérification des bashismes
echo -e "\n[2/5] Checkbashisms..."
if command -v checkbashisms >/dev/null 2>&1; then
    checkbashisms "$SCRIPT_TO_TEST" && echo "✅ Pas de bashismes" || echo "⚠️  Bashismes détectés"
else
    echo "⚠️  checkbashisms non installé"
fi

# 3. Vérification syntaxique
echo -e "\n[3/5] Vérification syntaxique..."
bash -n "$SCRIPT_TO_TEST" && echo "✅ Syntaxe Bash valide" || echo "❌ Erreur de syntaxe Bash"
sh -n "$SCRIPT_TO_TEST" 2>/dev/null && echo "✅ Syntaxe sh valide" || echo "⚠️  Syntaxe sh invalide (bashismes?)"

# 4. Test d'exécution
echo -e "\n[4/5] Test d'exécution..."
bash "$SCRIPT_TO_TEST" && echo "✅ Exécution Bash réussie" || echo "❌ Échec d'exécution Bash"

# 5. Test avec différents shells (si disponibles)
echo -e "\n[5/5] Test avec différents shells..."
for shell in dash ksh zsh; do
    if command -v "$shell" >/dev/null 2>&1; then
        "$shell" "$SCRIPT_TO_TEST" 2>/dev/null && echo "✅ $shell OK" || echo "⚠️  $shell a échoué"
    fi
done

echo -e "\n=== Tests terminés ==="
```

**Utilisation** :

```bash
chmod +x test_portability.sh
./test_portability.sh votre_script.sh
```

### Intégration continue (CI/CD)

Exemple de configuration GitHub Actions pour tester la portabilité :

```yaml
# .github/workflows/test.yml
name: Test portabilité

on: [push, pull_request]

jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        os: [ubuntu-latest, macos-latest]
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Install ShellCheck
      run: |
        if [ "$RUNNER_OS" = "Linux" ]; then
          sudo apt-get install -y shellcheck
        elif [ "$RUNNER_OS" = "macOS" ]; then
          brew install shellcheck
        fi
    
    - name: Run ShellCheck
      run: shellcheck *.sh
    
    - name: Test scripts
      run: |
        for script in *.sh; do
          bash -n "$script"
          bash "$script"
        done
```

> [!warning] N'oubliez pas La portabilité est un compromis entre universalité et fonctionnalités. Parfois, il vaut mieux documenter les prérequis (ex: "Bash 4.0+ requis") plutôt que de créer des contournements complexes.

### Bonnes pratiques de test

#### 1. Tests automatisés réguliers

```bash
#!/usr/bin/env bash
# Intégrez des tests dans votre workflow de développement

# Makefile pour automatiser les tests
cat > Makefile << 'EOF'
.PHONY: test lint check-portability

test:
	@echo "Running tests..."
	@bats tests/*.bats

lint:
	@echo "Running ShellCheck..."
	@shellcheck scripts/*.sh

check-portability:
	@echo "Checking for bashisms..."
	@checkbashisms scripts/*.sh || true

all: lint check-portability test
EOF
```

#### 2. Documentation des dépendances

```bash
#!/usr/bin/env bash
# Script: deploy.sh
# Prérequis:
#   - Bash 4.0+
#   - GNU coreutils (Linux) ou équivalent BSD (macOS)
#   - curl, jq
# Testé sur: Ubuntu 20.04+, Debian 11+, macOS 12+

# Vérification des prérequis
check_dependencies() {
    local missing=()
    
    # Vérifier la version de Bash
    if ((BASH_VERSINFO[0] < 4)); then
        echo "Erreur: Bash 4.0+ requis (version actuelle: $BASH_VERSION)" >&2
        exit 1
    fi
    
    # Vérifier les commandes requises
    for cmd in curl jq; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing+=("$cmd")
        fi
    done
    
    if ((${#missing[@]} > 0)); then
        echo "Erreur: commandes manquantes: ${missing[*]}" >&2
        echo "Installez-les avec: apt install ${missing[*]} # ou brew install ${missing[*]}" >&2
        exit 1
    fi
}

check_dependencies
```

#### 3. Tests de régression

```bash
# tests/regression.bats
#!/usr/bin/env bats

# Tester que les corrections de bugs restent fixées
@test "Bug #42: gestion des espaces dans les noms" {
    # Ce bug a été corrigé dans v1.2.0
    touch "fichier avec espaces.txt"
    run ./script.sh "fichier avec espaces.txt"
    [ "$status" -eq 0 ]
    rm -f "fichier avec espaces.txt"
}

@test "Bug #58: caractères spéciaux dans les chemins" {
    # Corrigé dans v1.3.0
    mkdir -p "dossier[spécial]"
    run ./script.sh "dossier[spécial]"
    [ "$status" -eq 0 ]
    rm -rf "dossier[spécial]"
}
```

#### 4. Matrice de compatibilité

Maintenez une documentation de compatibilité testée :

```markdown
## Matrice de compatibilité

| OS/Distribution | Version Shell | Status | Notes |
|-----------------|---------------|--------|-------|
| Ubuntu 22.04    | Bash 5.1      | ✅ OK  | Tests complets |
| Debian 11       | Bash 5.1      | ✅ OK  | Tests complets |
| CentOS 8        | Bash 4.4      | ✅ OK  | Fonctionnel |
| Alpine 3.18     | Bash 5.2      | ✅ OK  | Tests basiques |
| macOS 13        | Bash 3.2      | ⚠️ Limité | Installer Bash 5 via Homebrew recommandé |
| macOS 14        | Bash 5.2      | ✅ OK  | Avec Homebrew |
| FreeBSD 13      | Bash 5.1      | ✅ OK  | Tests basiques |
| OpenBSD 7.3     | Bash 5.2      | 🔶 Non testé | Devrait fonctionner |
```

### Détection avancée de l'environnement

```bash
#!/usr/bin/env bash

# Fonction complète de détection d'environnement
detect_full_environment() {
    # OS et distribution
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        OS_NAME="$NAME"
        OS_VERSION="$VERSION_ID"
    elif [[ "$(uname -s)" == "Darwin" ]]; then
        OS_NAME="macOS"
        OS_VERSION="$(sw_vers -productVersion)"
    else
        OS_NAME="$(uname -s)"
        OS_VERSION="unknown"
    fi
    
    # Architecture
    ARCH="$(uname -m)"
    
    # Version Bash
    BASH_MAJOR="${BASH_VERSINFO[0]}"
    BASH_MINOR="${BASH_VERSINFO[1]}"
    
    # Type de commandes (GNU vs BSD)
    if date --version 2>/dev/null | grep -q GNU; then
        TOOLS_TYPE="GNU"
    else
        TOOLS_TYPE="BSD"
    fi
    
    # Shells disponibles
    AVAILABLE_SHELLS=()
    for shell in bash sh dash zsh ksh; do
        if command -v "$shell" >/dev/null 2>&1; then
            AVAILABLE_SHELLS+=("$shell")
        fi
    done
    
    # Affichage du rapport
    cat << EOF
=== Environnement détecté ===
OS: $OS_NAME $OS_VERSION
Architecture: $ARCH
Bash: $BASH_VERSION (v$BASH_MAJOR.$BASH_MINOR)
Type d'outils: $TOOLS_TYPE
Shells disponibles: ${AVAILABLE_SHELLS[*]}
=============================
EOF
    
    # Export pour utilisation dans le script
    export OS_NAME OS_VERSION ARCH BASH_MAJOR BASH_MINOR TOOLS_TYPE
}

# Utilisation
detect_full_environment

# Adapter le comportement selon l'environnement
if [[ "$TOOLS_TYPE" == "GNU" ]]; then
    SED_INPLACE="sed -i"
    DATE_AGO="date -d"
else
    SED_INPLACE="sed -i ''"
    DATE_AGO="date -v"
fi
```

### Gestion des erreurs de compatibilité

```bash
#!/usr/bin/env bash

# Fonction pour gérer élégamment les incompatibilités
handle_compatibility_error() {
    local feature=$1
    local min_version=$2
    local current_version=$3
    
    cat << EOF >&2
❌ Erreur de compatibilité

Fonctionnalité: $feature
Version minimale requise: $min_version
Version actuelle: $current_version

Solutions possibles:
1. Mettre à jour Bash: 
   - Ubuntu/Debian: sudo apt update && sudo apt install bash
   - macOS: brew install bash
   - CentOS: sudo yum update bash

2. Utiliser un conteneur Docker avec une version récente
3. Contacter l'administrateur système

Pour plus d'informations: https://www.gnu.org/software/bash/
EOF
    
    exit 1
}

# Exemple d'utilisation
if ((BASH_VERSINFO[0] < 4)); then
    handle_compatibility_error \
        "Tableaux associatifs" \
        "Bash 4.0" \
        "$BASH_VERSION"
fi
```

### Pattern de fallback intelligent

```bash
#!/usr/bin/env bash

# Stratégie de fallback pour différentes implémentations
portable_realpath() {
    local path=$1
    
    # Essayer realpath (moderne)
    if command -v realpath >/dev/null 2>&1; then
        realpath "$path" 2>/dev/null && return 0
    fi
    
    # Essayer readlink -f (GNU)
    if readlink -f "$path" 2>/dev/null; then
        return 0
    fi
    
    # Fallback manuel (POSIX)
    if [[ -d "$path" ]]; then
        (cd "$path" && pwd -P)
    elif [[ -f "$path" ]]; then
        local dir=$(dirname "$path")
        local file=$(basename "$path")
        (cd "$dir" && echo "$(pwd -P)/$file")
    else
        echo "$path" >&2
        return 1
    fi
}

# Test de la fonction
portable_realpath "../script.sh"
```

### Exemple complet : Script portable

```bash
#!/usr/bin/env bash
# backup.sh - Script de backup portable
# Compatible: Bash 4+, Linux, macOS, BSD
# Testé: Ubuntu 22.04, Debian 11, macOS 13+, Alpine Linux

set -euo pipefail

# === Configuration ===
readonly SCRIPT_NAME="$(basename "$0")"
readonly SCRIPT_VERSION="1.0.0"
readonly MIN_BASH_VERSION=4

# === Vérifications préliminaires ===
check_bash_version() {
    if ((BASH_VERSINFO[0] < MIN_BASH_VERSION)); then
        echo "Erreur: Bash ${MIN_BASH_VERSION}+ requis" >&2
        echo "Version actuelle: $BASH_VERSION" >&2
        exit 1
    fi
}

check_dependencies() {
    local deps=(tar gzip find)
    local missing=()
    
    for cmd in "${deps[@]}"; do
        if ! command -v "$cmd" >/dev/null 2>&1; then
            missing+=("$cmd")
        fi
    done
    
    if ((${#missing[@]} > 0)); then
        echo "Erreur: commandes manquantes: ${missing[*]}" >&2
        exit 1
    fi
}

# === Fonctions portables ===
portable_date() {
    # Retourne la date au format ISO
    if date --version 2>/dev/null | grep -q GNU; then
        date -u +"%Y-%m-%dT%H:%M:%SZ"
    else
        date -u +"%Y-%m-%dT%H:%M:%SZ"
    fi
}

portable_find_modified() {
    # Trouve les fichiers modifiés dans les dernières 24h
    local dir=$1
    
    # find avec -mtime fonctionne partout
    find "$dir" -type f -mtime -1
}

portable_file_size() {
    # Retourne la taille d'un fichier en octets
    local file=$1
    
    if [[ ! -f "$file" ]]; then
        echo "0"
        return 1
    fi
    
    # wc -c est portable
    wc -c < "$file" | tr -d ' '
}

# === Logique métier ===
create_backup() {
    local source_dir=$1
    local backup_dir=$2
    local timestamp=$(portable_date | tr ':' '-')
    local backup_file="${backup_dir}/backup-${timestamp}.tar.gz"
    
    echo "Création du backup..."
    echo "Source: $source_dir"
    echo "Destination: $backup_file"
    
    # tar et gzip sont portables
    if tar -czf "$backup_file" -C "$(dirname "$source_dir")" "$(basename "$source_dir")"; then
        local size=$(portable_file_size "$backup_file")
        echo "✅ Backup créé: $backup_file ($size octets)"
        return 0
    else
        echo "❌ Échec de création du backup" >&2
        return 1
    fi
}

# === Main ===
main() {
    check_bash_version
    check_dependencies
    
    # Arguments
    local source_dir="${1:-.}"
    local backup_dir="${2:-./backups}"
    
    # Validation
    if [[ ! -d "$source_dir" ]]; then
        echo "Erreur: $source_dir n'existe pas" >&2
        exit 1
    fi
    
    # Création du dossier de backup
    mkdir -p "$backup_dir"
    
    # Création du backup
    create_backup "$source_dir" "$backup_dir"
}

# Point d'entrée
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

### Pièges finaux à éviter

> [!warning] Pièges courants de portabilité
> 
> **1. Supposer que `/bin/bash` existe toujours**
> 
> ```bash
> # ❌ Peut échouer sur certains systèmes
> #!/bin/bash
> 
> # ✅ Portable
> #!/usr/bin/env bash
> ```
> 
> **2. Utiliser `echo -e` ou `echo -n`**
> 
> ```bash
> # ❌ Comportement variable selon les shells
> echo -e "Line1\nLine2"
> 
> # ✅ Utilisez printf
> printf "Line1\nLine2\n"
> ```
> 
> **3. Dépendre de `[[` avec sh**
> 
> ```bash
> # ❌ Si #!/bin/sh
> if [[ "$var" == "value" ]]; then
> 
> # ✅ POSIX
> if [ "$var" = "value" ]; then
> ```
> 
> **4. Oublier de quoter les variables**
> 
> ```bash
> # ❌ Problème avec espaces et globbing
> file=$1
> cat $file
> 
> # ✅ Toujours quoter
> file=$1
> cat "$file"
> ```
> 
> **5. Utiliser `source` au lieu de `.`**
> 
> ```bash
> # ❌ Non POSIX
> source config.sh
> 
> # ✅ POSIX
> . config.sh
> ```

---

## Résumé des bonnes pratiques

> [!tip] Checklist finale de portabilité
> 
> **Shebang et versions**
> 
> - ✅ Utiliser `#!/usr/bin/env bash` pour la portabilité
> - ✅ Vérifier la version de Bash si fonctionnalités avancées nécessaires
> - ✅ Documenter les prérequis dans les commentaires
> 
> **Éviter les bashismes**
> 
> - ✅ Utiliser `[ ]` au lieu de `[[ ]]` pour sh
> - ✅ Éviter les tableaux, `<<<`, `<()`, `{1..10}` si POSIX requis
> - ✅ Préférer `printf` à `echo -e/-n`
> - ✅ Utiliser `.` au lieu de `source`
> 
> **Commandes portables**
> 
> - ✅ Détecter GNU vs BSD et adapter le code
> - ✅ Créer des wrappers pour `sed -i`, `date`, `stat`, etc.
> - ✅ Utiliser des options POSIX quand possible
> - ✅ Tester la présence des commandes avant usage
> 
> **Tests et validation**
> 
> - ✅ Passer ShellCheck sans erreur
> - ✅ Tester sur Linux ET macOS/BSD
> - ✅ Vérifier avec `bash -n` et `sh -n`
> - ✅ Écrire des tests BATS
> - ✅ Intégrer dans CI/CD
> 
> **Robustesse**
> 
> - ✅ Quoter toutes les variables : `"$var"`
> - ✅ Gérer les espaces dans les noms de fichiers
> - ✅ Messages d'erreur clairs et informatifs
> - ✅ Codes de sortie appropriés
> - ✅ Documentation des limitations connues

---

## 📚 Conclusion

La portabilité en Bash est un équilibre entre :

- **Fonctionnalités** : utiliser les capacités puissantes de Bash
- **Compatibilité** : fonctionner sur le maximum de systèmes
- **Maintenabilité** : code clair et compréhensible

**Règles d'or** :

1. Connaissez votre cible : Bash moderne ou POSIX strict ?
2. Testez sur plusieurs environnements réels
3. Documentez les prérequis et limitations
4. Utilisez des outils d'analyse statique (ShellCheck)
5. Créez des tests automatisés

Un script portable bien conçu sera utilisable pendant des années sur une multitude de systèmes, tandis qu'un script non-portable causera frustration et perte de temps aux utilisateurs.

> [!success] Vous maîtrisez maintenant
> 
> - La création de shebangs portables avec `/usr/bin/env bash`
> - L'identification et l'évitement des bashismes pour la compatibilité sh
> - La vérification et gestion des versions de Bash
> - Les différences entre commandes POSIX et GNU et comment les gérer
> - Les techniques et outils pour tester la compatibilité de vos scripts

**Prochaine étape** : Mettez en pratique ces concepts en auditant vos scripts existants avec ShellCheck et en les testant sur différents environnements !