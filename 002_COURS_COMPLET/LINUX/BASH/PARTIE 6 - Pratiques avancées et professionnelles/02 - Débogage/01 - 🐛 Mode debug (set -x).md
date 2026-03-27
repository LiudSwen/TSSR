

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

## 🎯 Introduction au mode debug

Le mode debug de Bash (`set -x`) est l'outil de débogage le plus fondamental et le plus puissant pour comprendre l'exécution d'un script. Il affiche chaque commande **avant** son exécution, après expansion des variables et substitutions.

> [!info] Pourquoi utiliser le mode debug ?
> 
> - Visualiser le flux d'exécution réel du script
> - Voir les valeurs des variables au moment de l'exécution
> - Identifier les commandes qui échouent
> - Comprendre les expansions et substitutions
> - Déboguer des boucles et conditions complexes

### Que montre le mode debug ?

Quand `set -x` est activé, Bash affiche :

- Les commandes après expansion des variables
- Les substitutions de commandes
- Les expansions arithmétiques
- Les expansions de chemins (globbing)
- Un préfixe (par défaut `+`) avant chaque ligne tracée

---

## ⚡ Activation et désactivation

### Méthode 1 : Dans le script avec set

```bash
#!/bin/bash

# Désactiver le debug (état par défaut)
set +x

echo "Cette ligne n'est pas tracée"

# Activer le debug
set -x

echo "Cette ligne EST tracée"
nom="Alice"
echo "Bonjour $nom"

# Désactiver le debug
set +x

echo "Cette ligne n'est plus tracée"
```

**Sortie :**

```
Cette ligne n'est pas tracée
+ echo 'Cette ligne EST tracée'
Cette ligne EST tracée
+ nom=Alice
+ echo 'Bonjour Alice'
Bonjour Alice
Cette ligne n'est plus tracée
```

> [!tip] Astuce mnémotechnique
> 
> - `set -x` : le `-` active (on ajoute la fonctionnalité)
> - `set +x` : le `+` désactive (on retire la fonctionnalité)
> 
> C'est contre-intuitif mais c'est la convention Bash !

### Méthode 2 : Au lancement du script

```bash
# Activer le debug pour tout le script
bash -x mon_script.sh

# Ou avec le shebang
#!/bin/bash -x
```

### Méthode 3 : Combinaison avec d'autres options

```bash
#!/bin/bash -xv
# -x : mode debug (xtrace)
# -v : mode verbose (affiche les lignes avant parsing)
```

> [!warning] Différence entre -x et -v
> 
> - `-v` affiche les lignes **telles qu'elles sont lues** (avant expansion)
> - `-x` affiche les commandes **après expansion** (avant exécution)
> 
> En général, `-x` seul suffit pour le débogage.

---

## 🎯 Debug sélectif

Le debug sélectif permet de tracer uniquement les sections problématiques de votre script, réduisant ainsi le bruit dans la sortie.

### Pattern basique : Encadrer une section

```bash
#!/bin/bash

fonction_complexe() {
    set -x  # Activer le debug pour cette fonction
    
    local fichier=$1
    if [[ -f "$fichier" ]]; then
        contenu=$(cat "$fichier")
        echo "Fichier lu: ${#contenu} caractères"
    fi
    
    set +x  # Désactiver le debug
}

# Pas de trace ici
echo "Début du script"

# Trace uniquement cette fonction
fonction_complexe "/etc/hosts"

# Pas de trace ici non plus
echo "Fin du script"
```

### Pattern avancé : Debug conditionnel

```bash
#!/bin/bash

# Variable de contrôle du debug
DEBUG=${DEBUG:-0}

debug_on() {
    [[ $DEBUG -eq 1 ]] && set -x
}

debug_off() {
    [[ $DEBUG -eq 1 ]] && set +x
}

# Utilisation
echo "Pas de debug ici"

debug_on
    calcul=$((5 * 3 + 2))
    echo "Résultat: $calcul"
debug_off

echo "Pas de debug non plus ici"
```

**Lancement avec debug :**

```bash
DEBUG=1 ./mon_script.sh
```

### Pattern avec trap pour les fonctions

```bash
#!/bin/bash

# Active le debug automatiquement à l'entrée de certaines fonctions
debug_fonction() {
    trap 'set -x' DEBUG
}

# Désactive le debug
nodebug_fonction() {
    trap - DEBUG
}

ma_fonction() {
    echo "Début fonction"
    # Cette partie sera tracée
    local x=10
    echo $((x * 2))
}

debug_fonction
ma_fonction
nodebug_fonction
```

> [!tip] Stratégie de debug efficace
> 
> 1. Commencez avec `set -x` sur tout le script
> 2. Identifiez la zone problématique
> 3. Désactivez le debug global
> 4. Activez-le uniquement autour de la zone problématique
> 5. Affinez progressivement

---

## 🎨 Personnalisation avec PS4

La variable `PS4` contrôle le préfixe affiché avant chaque ligne tracée. Par défaut, c'est `+`, mais vous pouvez la personnaliser pour obtenir des informations très utiles.

### Variables utiles dans PS4

|Variable|Description|
|---|---|
|`$LINENO`|Numéro de ligne actuelle|
|`$BASH_SOURCE`|Nom du fichier source|
|`$FUNCNAME`|Nom de la fonction actuelle|
|`$SECONDS`|Secondes depuis le début du script|
|`$(date +%T)`|Horodatage|

### Exemples de personnalisation

#### Basique : Afficher le numéro de ligne

```bash
#!/bin/bash
PS4='Ligne $LINENO: '
set -x

nom="Bob"
echo "Bonjour $nom"
resultat=$((5 + 3))
echo "Résultat: $resultat"
```

**Sortie :**

```
Ligne 5: nom=Bob
Ligne 6: echo 'Bonjour Bob'
Bonjour Bob
Ligne 7: resultat=8
Ligne 8: echo 'Résultat: 8'
Résultat: 8
```

#### Avancé : Ligne + Fonction + Temps

```bash
#!/bin/bash
PS4='+[${BASH_SOURCE##*/}:$LINENO:${FUNCNAME[0]:+${FUNCNAME[0]}()}]> '
set -x

ma_fonction() {
    local x=42
    echo "Dans la fonction: $x"
}

echo "Avant la fonction"
ma_fonction
echo "Après la fonction"
```

**Sortie :**

```
+[script.sh:9:]> echo 'Avant la fonction'
Avant la fonction
+[script.sh:10:]> ma_fonction
+[script.sh:5:ma_fonction()]> local x=42
+[script.sh:6:ma_fonction()]> echo 'Dans la fonction: 42'
Dans la fonction: 42
+[script.sh:11:]> echo 'Après la fonction'
Après la fonction
```

#### Expert : Avec horodatage et couleurs

```bash
#!/bin/bash

# Codes couleur ANSI
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# PS4 personnalisé avec couleurs
PS4='${BLUE}[$(date +%T)]${NC} ${GREEN}${BASH_SOURCE##*/}${NC}:${RED}$LINENO${NC} ${FUNCNAME[0]:+${FUNCNAME[0]}()} → '

set -x

fonction_test() {
    sleep 1
    echo "Test"
}

echo "Début"
fonction_test
echo "Fin"
```

> [!example] PS4 pour le profiling Utilisez `$SECONDS` pour mesurer le temps d'exécution :
> 
> ```bash
> PS4='+ [$SECONDS s] $BASH_SOURCE:$LINENO: '
> set -x
> 
> sleep 2
> echo "Opération lente"
> sleep 1
> echo "Opération rapide"
> ```

### Template PS4 recommandé

```bash
# Pour le debug quotidien
PS4='+ [L$LINENO] '

# Pour le debug avancé
PS4='+[${BASH_SOURCE##*/}:${LINENO}${FUNCNAME[0]:+:${FUNCNAME[0]}()}] '

# Pour le profiling
PS4='+[$SECONDS s][L$LINENO] '
```

> [!warning] Attention aux substitutions dans PS4 Les substitutions de commandes dans `PS4` (comme `$(date)`) sont évaluées à **chaque ligne tracée**. Cela peut ralentir l'exécution si vous tracez beaucoup de lignes.

---

## 📁 Redirection du debug

Par défaut, la sortie du mode debug va sur `stderr` (descripteur 2). Vous pouvez la rediriger pour séparer le debug des sorties normales.

### Redirection vers un fichier

```bash
#!/bin/bash
PS4='+ [L$LINENO] '

# Rediriger le debug vers un fichier
exec 2>debug.log

set -x

nom="Alice"
echo "Bonjour $nom"
resultat=$((10 * 5))
echo "Résultat: $resultat"

set +x
```

**Résultat :**

- La sortie normale s'affiche à l'écran
- Le debug est écrit dans `debug.log`

### Redirection vers un descripteur personnalisé

```bash
#!/bin/bash

# Créer un descripteur de fichier dédié au debug
exec 3>debug.log

# Rediriger le stderr du mode debug vers ce descripteur
BASH_XTRACEFD=3

PS4='+ [L$LINENO] '
set -x

echo "Message normal"  # Visible à l'écran
resultat=$((5 + 3))    # Debug dans debug.log

set +x
```

> [!info] Variable BASH_XTRACEFD `BASH_XTRACEFD` est une variable spéciale de Bash qui spécifie le descripteur de fichier à utiliser pour la sortie de `set -x`. Par défaut, elle vaut 2 (stderr).

### Redirection avec horodatage dans le nom de fichier

```bash
#!/bin/bash

# Créer un fichier de log avec timestamp
DEBUG_FILE="debug_$(date +%Y%m%d_%H%M%S).log"
exec 2>"$DEBUG_FILE"

PS4='[$(date +%T)] + '
set -x

echo "Ce script génère un log horodaté"
echo "Fichier de debug: $DEBUG_FILE"

set +x

# Afficher où est le log
echo "Debug sauvegardé dans: $DEBUG_FILE" >&2
```

### Séparation debug/erreurs

```bash
#!/bin/bash

# Descripteur 3 pour le debug
exec 3>debug.log
BASH_XTRACEFD=3

# Descripteur 4 pour les erreurs
exec 4>errors.log

PS4='+ [L$LINENO] '
set -x

echo "Opération normale"

# Erreur intentionnelle redirigée vers errors.log
ls /fichier_inexistant 2>&4

resultat=$((10 / 2))

set +x

echo "Debug dans: debug.log"
echo "Erreurs dans: errors.log"
```

### Redirection avec rotation

```bash
#!/bin/bash

# Fonction pour logger le debug avec rotation
setup_debug_log() {
    local max_size=1048576  # 1 MB
    local debug_file="debug.log"
    
    # Si le fichier existe et dépasse la taille max, le renommer
    if [[ -f "$debug_file" ]] && [[ $(stat -f%z "$debug_file" 2>/dev/null || stat -c%s "$debug_file") -gt $max_size ]]; then
        mv "$debug_file" "debug_$(date +%Y%m%d_%H%M%S).log"
    fi
    
    exec 2>>"$debug_file"
}

setup_debug_log
PS4='[$(date +%T)] + '
set -x

# Votre script ici
for i in {1..100}; do
    echo "Ligne $i"
done

set +x
```

> [!tip] Bonnes pratiques de redirection
> 
> 1. **Utilisez `BASH_XTRACEFD`** pour séparer le debug des erreurs réelles
> 2. **Horodatez les fichiers de log** pour l'historique
> 3. **Fermez les descripteurs** avec `exec 3>&-` quand vous avez fini
> 4. **Surveillez la taille des logs** pour éviter de saturer le disque

### Redirection conditionnelle

```bash
#!/bin/bash

DEBUG_MODE=${DEBUG_MODE:-0}

if [[ $DEBUG_MODE -eq 1 ]]; then
    # Mode debug activé : log dans un fichier
    exec 3>debug_detailed.log
    BASH_XTRACEFD=3
    PS4='[$(date +%T)][L$LINENO] '
    set -x
else
    # Mode normal : pas de log de debug
    exec 3>/dev/null
    BASH_XTRACEFD=3
fi

# Votre script
echo "Test"
resultat=$((5 * 5))

[[ $DEBUG_MODE -eq 1 ]] && set +x
```

**Utilisation :**

```bash
# Sans debug
./script.sh

# Avec debug
DEBUG_MODE=1 ./script.sh
```

---

## ⚠️ Pièges courants

### 1. Debug et mots de passe

> [!warning] Sécurité : Mots de passe exposés Le mode debug affiche **tout**, y compris les mots de passe !

**Mauvais :**

```bash
set -x
password="MonMotDePasse123"
mysql -u root -p"$password" -e "SELECT * FROM users"
set +x
```

**Bon :**

```bash
# Désactiver temporairement le debug pour les opérations sensibles
set +x
password="MonMotDePasse123"
mysql -u root -p"$password" -e "SELECT * FROM users"
set -x  # Réactiver après
```

### 2. Performance avec PS4 complexe

```bash
# LENT : substitution de commande à chaque ligne
PS4='$(date +%T.%N) + '
set -x

# Sur 1000 lignes, cela appelle date 1000 fois !
for i in {1..1000}; do
    echo $i
done
```

**Solution : Utiliser `$SECONDS` ou limiter la complexité**

```bash
# RAPIDE : variable shell simple
PS4='[$SECONDS] + '
```

### 3. Debug dans les sous-shells

```bash
set -x

# Le debug ne se propage PAS aux sous-shells par défaut
(
    echo "Dans un sous-shell"
    x=42
)

echo "Dans le shell principal"
set +x
```

**Solution : Passer l'option au sous-shell**

```bash
set -x

(
    set -x  # Activer explicitement dans le sous-shell
    echo "Dans un sous-shell"
    x=42
)

set +x
```

### 4. Oubli de désactivation

```bash
set -x
# ... beaucoup de code ...
# Oups, j'ai oublié set +x
# Tout le reste du script est tracé !
```

**Solution : Utiliser une fonction ou un trap**

```bash
debug_section() {
    set -x
    "$@"
    set +x
}

debug_section ma_fonction arg1 arg2
```

### 5. Confusion avec set -e

```bash
# set -e arrête le script sur erreur
# set -x trace les commandes

set -e  # Arrêt sur erreur
set -x  # Mode debug

# Ces deux options sont indépendantes !
# Mais attention à leur interaction
```

> [!tip] Combiner set -e et set -x
> 
> ```bash
> # Forme courte pour activer les deux
> set -ex
> 
> # Ou séparément
> set -e
> set -x
> ```

### 6. Sortie debug mélangée avec stdout

```bash
set -x
# Le debug va sur stderr (2)
# Le echo va sur stdout (1)
echo "Résultat"
# Les deux s'affichent au terminal, difficile à parser
```

**Solution : Rediriger proprement**

```bash
# Séparer debug et sortie normale
exec 3>debug.log
BASH_XTRACEFD=3
set -x

echo "Résultat"  # Uniquement sur stdout
# Debug uniquement dans debug.log
```

---

## 💡 Astuces avancées

### Créer un mode "verbose" personnalisé

```bash
#!/bin/bash

VERBOSE=${VERBOSE:-0}

log() {
    [[ $VERBOSE -eq 1 ]] && echo "[DEBUG] $*" >&2
}

set -x
log "Début du traitement"
resultat=$((5 + 3))
log "Calcul terminé: $resultat"
set +x
```

### Wrapper de debug automatique

```bash
#!/bin/bash

# Active automatiquement le debug si DEBUG=1
[[ ${DEBUG:-0} -eq 1 ]] && set -x

# Votre script normal
echo "Test"
x=42
echo "x = $x"

# Pas besoin de set +x, c'est automatique à la fin
```

### Debug uniquement en cas d'erreur

```bash
#!/bin/bash

# Capturer les erreurs et activer le debug rétroactivement
trap 'set -x' ERR

commande_qui_peut_echouer

# Le debug s'active seulement si une erreur survient
```

### Compteur de lignes exécutées

```bash
#!/bin/bash

COUNTER=0
PS4='[${COUNTER}] + '

# Incrémenter le compteur à chaque ligne
trap 'let COUNTER++' DEBUG

set -x
echo "Ligne 1"
echo "Ligne 2"
echo "Ligne 3"
set +x

echo "Total de lignes exécutées: $COUNTER"
```

---

> [!tip] Résumé des commandes essentielles
> 
> - `set -x` : Activer le mode debug
> - `set +x` : Désactiver le mode debug
> - `PS4='+ [L$LINENO] '` : Personnaliser le préfixe
> - `BASH_XTRACEFD=3` : Rediriger vers un descripteur personnalisé
> - `bash -x script.sh` : Lancer un script en mode debug