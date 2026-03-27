

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

Par défaut, Bash continue l'exécution d'un script même quand une commande échoue. Ce comportement peut masquer des erreurs critiques et produire des résultats imprévisibles. Les options `set` permettent de modifier ce comportement pour rendre vos scripts plus robustes et prévisibles.

> [!info] Pourquoi utiliser les options `set` ?
> 
> - **Détecter les erreurs tôt** : Éviter les effets en cascade d'une erreur non détectée
> - **Code plus sûr** : Empêcher l'utilisation de variables non initialisées
> - **Debugging facilité** : Tracer l'exécution pour comprendre les problèmes
> - **Scripts production-ready** : Standards de l'industrie pour les scripts critiques

---

## `set -e` : Arrêt sur erreur

### 🎯 Concept

L'option `-e` (exit on error) arrête immédiatement l'exécution du script dès qu'une commande retourne un code de sortie non nul (échec).

### Syntaxe

```bash
#!/bin/bash
set -e  # Active l'arrêt sur erreur

# Toute commande qui échoue arrêtera le script
commande1
commande2  # Si cette commande échoue, le script s'arrête ici
commande3  # Cette ligne ne sera jamais exécutée
```

### 📊 Comparaison avec/sans `set -e`

|Sans `set -e`|Avec `set -e`|
|---|---|
|Les erreurs sont ignorées|Arrêt immédiat sur erreur|
|Le script continue jusqu'à la fin|Prévient les corruptions de données|
|Comportement imprévisible|Comportement déterministe|

### Exemple pratique

```bash
#!/bin/bash
set -e

# Création d'un backup
echo "Création du backup..."
tar -czf backup.tar.gz /important/data/  # Si échec, arrêt ici

# Suppression des anciens fichiers (ne s'exécute que si backup réussi)
echo "Nettoyage des anciens fichiers..."
rm -rf /important/data/old/

echo "Backup terminé avec succès"
```

> [!warning] Exceptions importantes `set -e` ne s'applique PAS dans les cas suivants :
> 
> - Commandes dans un test conditionnel : `if commande; then`
> - Commandes avec `||` ou `&&`
> - Commandes dans un pipeline (sauf avec `set -o pipefail`)
> - Fonctions appelées dans un test

### Gestion conditionnelle des erreurs

```bash
#!/bin/bash
set -e

# Cette commande peut échouer sans arrêter le script
if ! commande_optionnelle; then
    echo "Commande optionnelle a échoué, mais on continue"
fi

# Autre méthode : désactiver temporairement
set +e  # Désactive -e
commande_qui_peut_echouer
set -e  # Réactive -e

# Ou utiliser || true
commande_optionnelle || true  # Ne provoque pas d'arrêt
```

---

## `set -u` : Erreur sur variable non définie

### 🎯 Concept

L'option `-u` (unset variable) provoque une erreur et l'arrêt du script si vous tentez d'utiliser une variable non définie. Par défaut, Bash remplace les variables non définies par une chaîne vide, ce qui peut causer des bugs silencieux.

### Syntaxe

```bash
#!/bin/bash
set -u  # Active la détection des variables non définies

echo "$VARIABLE_INEXISTANTE"  # Erreur : variable non définie
```

### Exemple de bug évité

```bash
#!/bin/bash
# Sans set -u (DANGEREUX)
rm -rf /data/$DOSSIER_UTILISATEUR/*
# Si $DOSSIER_UTILISATEUR est vide, cela devient : rm -rf /data/*
# CATASTROPHE : suppression de tout /data/ !

# Avec set -u (SÉCURISÉ)
set -u
rm -rf /data/$DOSSIER_UTILISATEUR/*
# Si $DOSSIER_UTILISATEUR n'est pas défini, le script s'arrête avec erreur
```

### Vérifier l'existence d'une variable

```bash
#!/bin/bash
set -u

# Méthode 1 : Valeur par défaut avec ${var:-default}
UTILISATEUR=${USER:-"anonyme"}
echo "Utilisateur : $UTILISATEUR"

# Méthode 2 : Valeur par défaut avec ${var:=default}
# (définit la variable si elle n'existe pas)
: ${CONFIG_FILE:="/etc/app/config.conf"}
echo "Fichier de config : $CONFIG_FILE"

# Méthode 3 : Test d'existence explicite
if [ -z "${OPTIONAL_VAR+x}" ]; then
    echo "OPTIONAL_VAR n'est pas définie"
else
    echo "OPTIONAL_VAR = $OPTIONAL_VAR"
fi

# Méthode 4 : Désactiver temporairement
set +u
echo "Variable peut-être vide : $PEUT_ETRE_VIDE"
set -u
```

> [!tip] Astuce : Variables d'environnement Utilisez `${VAR:-valeur_par_defaut}` pour fournir une valeur par défaut aux variables d'environnement qui peuvent ne pas être définies.

---

## `set -o pipefail` : Échec dans les pipes

### 🎯 Concept

Par défaut, le code de retour d'un pipeline est celui de la **dernière commande**. Avec `pipefail`, le pipeline échoue si **n'importe quelle commande** du pipeline échoue.

### Syntaxe

```bash
#!/bin/bash
set -o pipefail  # Active la détection d'échec dans les pipes
```

### 📊 Comportement par défaut vs pipefail

```bash
# Sans pipefail
commande_qui_echoue | commande_qui_reussit
echo $?  # Affiche 0 (succès) car la dernière commande a réussi

# Avec pipefail
set -o pipefail
commande_qui_echoue | commande_qui_reussit
echo $?  # Affiche code d'erreur de commande_qui_echoue
```

### Exemple pratique

```bash
#!/bin/bash
set -eo pipefail

# Sans pipefail, cette ligne retournerait 0 même si grep échoue
cat fichier.log | grep "ERROR" | wc -l

# Avec pipefail, le script s'arrête si :
# - cat ne peut pas lire le fichier
# - grep ne trouve rien et retourne 1
# - wc échoue
```

### Cas d'usage courants

```bash
#!/bin/bash
set -eo pipefail

# Pipeline de traitement de données
curl -s https://api.example.com/data \
    | jq '.results[]' \
    | while read item; do
        process_item "$item"
    done
# Si curl, jq, ou process_item échoue, tout s'arrête

# Extraction et traitement
gunzip -c fichier.gz \
    | grep "pattern" \
    | sort \
    | uniq \
    > resultat.txt
# Chaque étape doit réussir
```

> [!warning] Attention avec grep `grep` retourne 1 quand il ne trouve rien, ce qui peut être un comportement normal. Utilisez `grep || true` si l'absence de résultat est acceptable.

```bash
#!/bin/bash
set -eo pipefail

# Gérer le cas où grep ne trouve rien
cat fichier.log | grep "PATTERN" || true | wc -l
# ou
if cat fichier.log | grep "PATTERN" > resultats.txt; then
    echo "Pattern trouvé"
else
    echo "Pattern non trouvé (normal)"
fi
```

---

## `set -x` : Mode debug

### 🎯 Concept

L'option `-x` (xtrace) affiche chaque commande avant son exécution, avec les variables expandées. C'est l'outil de debugging le plus utilisé en Bash.

### Syntaxe

```bash
#!/bin/bash
set -x  # Active le mode debug

# Chaque commande sera affichée avec un '+' avant son exécution
variable="valeur"
echo "$variable"
```

### Sortie du mode debug

```bash
+ variable=valeur
+ echo valeur
valeur
```

### Debugging ciblé

```bash
#!/bin/bash

# Code normal (pas de trace)
preparation_initiale

# Active le debug pour une section spécifique
set -x
fonction_complexe_a_debugger
calculs_importants
set +x  # Désactive le debug

# Retour au mode normal
finalisation
```

### Redirection des traces

```bash
#!/bin/bash

# Rediriger les traces vers un fichier
exec 2> debug.log  # Toutes les erreurs et traces vers debug.log
set -x

# Vos commandes ici
commande1
commande2

# Les traces sont dans debug.log, pas à l'écran
```

### Debug conditionnel avec variable d'environnement

```bash
#!/bin/bash

# Active le debug si DEBUG=1
if [ "${DEBUG:-0}" = "1" ]; then
    set -x
fi

# Utilisation :
# DEBUG=1 ./script.sh  # Mode debug activé
# ./script.sh          # Mode normal
```

> [!tip] Astuce : PS4 personnalisé Personnalisez le prompt de debug avec la variable `PS4` pour des traces plus informatives.

```bash
#!/bin/bash

# Afficher le numéro de ligne, la fonction, et le timestamp
export PS4='+ [${BASH_SOURCE}:${LINENO}] ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
set -x

fonction_exemple() {
    echo "Dans la fonction"
}

fonction_exemple
# Sortie : + [script.sh:10] fonction_exemple(): echo 'Dans la fonction'
```

---

## Combinaison `set -euo pipefail`

### 🎯 Le "mode strict" de Bash

La combinaison `set -euo pipefail` est considérée comme la meilleure pratique pour écrire des scripts robustes. C'est le "mode strict" de Bash.

### Syntaxe

```bash
#!/bin/bash
set -euo pipefail
# ou en une seule ligne au début du script :
# #!/bin/bash -euo pipefail
```

### Ce que cette combinaison apporte

|Option|Protection|
|---|---|
|`-e`|Arrêt immédiat sur erreur de commande|
|`-u`|Arrêt sur utilisation de variable non définie|
|`-o pipefail`|Arrêt si une commande d'un pipe échoue|

### Template de script robuste

```bash
#!/bin/bash
set -euo pipefail

# Configuration des traces pour debug
# Décommentez la ligne suivante pour activer le debug :
# set -x

# Nettoyage en cas de sortie (normale ou erreur)
cleanup() {
    echo "Nettoyage..."
    # Vos actions de nettoyage ici
}
trap cleanup EXIT

# Gestion d'erreur personnalisée
error_handler() {
    local line_number=$1
    echo "Erreur à la ligne $line_number" >&2
    exit 1
}
trap 'error_handler ${LINENO}' ERR

# Variables par défaut
CONFIG_FILE="${CONFIG_FILE:-/etc/app/config.conf}"
LOG_DIR="${LOG_DIR:-/var/log/app}"

# Votre code ici
main() {
    echo "Début du script..."
    # ...
}

main "$@"
```

### Exemple complet d'utilisation

```bash
#!/bin/bash
set -euo pipefail

# Script de déploiement sécurisé
DEPLOY_DIR="${1:?Usage: $0 <deploy_directory>}"
BACKUP_DIR="/backups/$(date +%Y%m%d_%H%M%S)"

echo "Création du backup dans $BACKUP_DIR..."
mkdir -p "$BACKUP_DIR"
tar -czf "$BACKUP_DIR/backup.tar.gz" "$DEPLOY_DIR"

echo "Déploiement de la nouvelle version..."
rsync -av --delete /tmp/new_version/ "$DEPLOY_DIR/"

echo "Redémarrage du service..."
systemctl restart myapp.service

echo "Vérification..."
curl -f http://localhost:8080/health || {
    echo "Échec de la vérification, rollback..."
    tar -xzf "$BACKUP_DIR/backup.tar.gz" -C /
    systemctl restart myapp.service
    exit 1
}

echo "Déploiement réussi !"
```

> [!warning] Attention aux commandes interactives Certaines commandes peuvent ne pas bien fonctionner avec `set -e` (par exemple `read` peut retourner 1 à la fin d'un fichier).

---

## Désactivation avec `+`

### 🎯 Concept

Toutes les options `set` peuvent être désactivées en remplaçant `-` par `+`. Cela permet un contrôle fin du comportement du script.

### Syntaxe

```bash
set -e   # Active
set +e   # Désactive

set -u   # Active
set +u   # Désactive

set -x   # Active
set +x   # Désactive

set -o pipefail   # Active
set +o pipefail   # Désactive
```

### Désactivation temporaire

```bash
#!/bin/bash
set -euo pipefail

# Code normal avec protection

# Section où les erreurs sont acceptables
set +e
commande_optionnelle_1
commande_optionnelle_2
set -e

# Retour au mode strict
commande_critique
```

### Cas d'usage : Commandes de test

```bash
#!/bin/bash
set -euo pipefail

# Tester si un service répond (échec acceptable)
set +e
curl -s http://localhost:8080/health > /dev/null
HEALTH_STATUS=$?
set -e

if [ $HEALTH_STATUS -eq 0 ]; then
    echo "Service opérationnel"
else
    echo "Service ne répond pas, démarrage..."
    systemctl start myservice
fi
```

### Désactivation de variables non définies

```bash
#!/bin/bash
set -euo pipefail

# Lire des variables d'environnement optionnelles
set +u
OPTIONAL_CONFIG="${OPTIONAL_CONFIG}"
OPTIONAL_DEBUG="${OPTIONAL_DEBUG}"
set -u

# Utiliser avec valeurs par défaut
CONFIG="${OPTIONAL_CONFIG:-/etc/default.conf}"
DEBUG="${OPTIONAL_DEBUG:-false}"
```

### Sauvegarder et restaurer les options

```bash
#!/bin/bash

# Sauvegarder l'état actuel des options
OLD_STATE=$-

# Modifier les options
set -x

# Votre code ici
commandes_a_tracer

# Restaurer l'état précédent
if [[ $OLD_STATE == *x* ]]; then
    set -x
else
    set +x
fi
```

> [!tip] Astuce : Vérifier les options actives Utilisez `$-` pour voir quelles options sont actives. Par exemple, `echo $-` peut afficher `himBHs` où `e` indiquerait que `-e` est actif.

```bash
#!/bin/bash

# Fonction pour afficher les options actives
show_options() {
    echo "Options actives : $-"
    [[ $- == *e* ]] && echo "  -e (errexit) est actif"
    [[ $- == *u* ]] && echo "  -u (nounset) est actif"
    [[ $- == *x* ]] && echo "  -x (xtrace) est actif"
}

set -euo pipefail
show_options
```

---

## Pièges courants

### ⚠️ Piège 1 : set -e et tests conditionnels

```bash
#!/bin/bash
set -e

# ❌ PIÈGE : Cette commande peut échouer sans arrêter le script
if grep "pattern" fichier.txt; then
    echo "Trouvé"
fi

# ✅ SOLUTION : Capturer explicitement l'échec
if ! grep "pattern" fichier.txt > /dev/null; then
    echo "Non trouvé" >&2
    exit 1
fi
```

### ⚠️ Piège 2 : Substitution de commande

```bash
#!/bin/bash
set -e

# ❌ PIÈGE : L'échec dans $() n'arrête pas toujours le script
resultat=$(commande_qui_peut_echouer)

# ✅ SOLUTION : Séparer les opérations
commande_qui_peut_echouer > /tmp/resultat
resultat=$(cat /tmp/resultat)
```

### ⚠️ Piège 3 : Fonctions et set -e

```bash
#!/bin/bash
set -e

# ❌ PIÈGE : Si cette fonction est appelée dans un test, -e ne s'applique pas
ma_fonction() {
    commande_qui_peut_echouer
    return 0
}

# Appel dans un test : -e désactivé dans la fonction
if ma_fonction; then
    echo "Succès"
fi

# ✅ SOLUTION : Tester explicitement dans la fonction
ma_fonction() {
    if ! commande_qui_peut_echouer; then
        echo "Erreur dans ma_fonction" >&2
        return 1
    fi
    return 0
}
```

### ⚠️ Piège 4 : Boucles while avec pipefail

```bash
#!/bin/bash
set -eo pipefail

# ❌ PIÈGE : Peut s'arrêter prématurément
cat fichier.txt | while read ligne; do
    traiter "$ligne"
done

# ✅ SOLUTION : Utiliser la redirection
while read ligne; do
    traiter "$ligne"
done < fichier.txt
```

---

## Bonnes pratiques

### ✅ 1. Template standard en début de script

```bash
#!/bin/bash
set -euo pipefail
IFS=$'\n\t'  # Séparateur de champs plus sûr
```

### ✅ 2. Gestion d'erreur avec trap

```bash
#!/bin/bash
set -euo pipefail

# Fonction d'erreur détaillée
err_handler() {
    echo "❌ Erreur ligne $1" >&2
    echo "Commande : $BASH_COMMAND" >&2
    echo "Code sortie : $?" >&2
}

trap 'err_handler ${LINENO}' ERR
```

### ✅ 3. Validation des arguments

```bash
#!/bin/bash
set -euo pipefail

# Validation avec messages d'erreur clairs
: "${1:?Usage: $0 <argument_requis>}"
FICHIER="${1}"

[ -f "$FICHIER" ] || {
    echo "Erreur : $FICHIER n'existe pas" >&2
    exit 1
}
```

### ✅ 4. Documentation des désactivations

```bash
#!/bin/bash
set -euo pipefail

# Désactivation justifiée et documentée
# Note : grep retourne 1 si aucune correspondance (comportement normal ici)
set +e
grep "PATTERN_OPTIONNEL" fichier.txt > resultats.txt
GREP_STATUS=$?
set -e

if [ $GREP_STATUS -eq 0 ]; then
    echo "Pattern trouvé"
elif [ $GREP_STATUS -eq 1 ]; then
    echo "Pattern non trouvé (normal)"
else
    echo "Erreur lors de la recherche" >&2
    exit 1
fi
```

### ✅ 5. Variables avec valeurs par défaut

```bash
#!/bin/bash
set -euo pipefail

# Toujours fournir des valeurs par défaut sensées
TIMEOUT="${TIMEOUT:-30}"
MAX_RETRIES="${MAX_RETRIES:-3}"
LOG_LEVEL="${LOG_LEVEL:-INFO}"
CONFIG_FILE="${CONFIG_FILE:-/etc/app/config.conf}"
```

### ✅ 6. Debug facilité

```bash
#!/bin/bash
# Active toutes les protections + debug si demandé
set -euo pipefail
[ "${DEBUG:-0}" = "1" ] && set -x

# Utilisation : DEBUG=1 ./script.sh
```

---

> [!info] Résumé des options essentielles
> 
> |Option|Effet|Utilisation|
> |---|---|---|
> |`set -e`|Arrêt sur erreur|Scripts de production|
> |`set -u`|Erreur si variable non définie|Éviter les bugs silencieux|
> |`set -o pipefail`|Échec si erreur dans pipe|Pipelines de traitement|
> |`set -x`|Trace des commandes|Debugging|
> |`set -euo pipefail`|Mode strict complet|**Recommandé pour tous les scripts**|