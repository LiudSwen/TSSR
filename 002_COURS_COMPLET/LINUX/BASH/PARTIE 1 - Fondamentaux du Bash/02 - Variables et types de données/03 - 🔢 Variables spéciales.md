

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

Les variables spéciales en Bash sont des variables prédéfinies par le shell qui contiennent des informations importantes sur l'exécution du script, les arguments passés, les processus, etc. Elles sont essentielles pour créer des scripts robustes et interactifs.

> [!info] Convention de nommage Les variables spéciales commencent toujours par le symbole `$` suivi d'un caractère spécial (`?`, `#`, `@`, etc.) ou d'un chiffre pour les arguments positionnels.

---

## Variables de codes de retour

### `$?` - Code de retour de la dernière commande

**Pourquoi c'est important :** Le code de retour (exit code) indique si une commande s'est exécutée avec succès (0) ou a échoué (valeur différente de 0). C'est fondamental pour la gestion des erreurs.

**Syntaxe et utilisation :**

```bash
# Exécuter une commande et vérifier son succès
ls /tmp
echo "Code de retour: $?"  # Affiche 0 si /tmp existe

# Exemple pratique de gestion d'erreur
if mkdir /nouveau_dossier 2>/dev/null; then
    echo "Dossier créé avec succès"
else
    echo "Échec de la création (code: $?)"
fi

# Chaînage de vérifications
grep "pattern" fichier.txt
retour=$?  # Sauvegarder le code avant qu'il soit écrasé
if [ $retour -eq 0 ]; then
    echo "Pattern trouvé"
elif [ $retour -eq 1 ]; then
    echo "Pattern non trouvé"
else
    echo "Erreur lors de la recherche"
fi
```

> [!warning] Piège courant `$?` est écrasé après chaque commande. Si vous devez l'utiliser plusieurs fois, sauvegardez-le immédiatement dans une variable.

```bash
# ❌ Mauvais
ls fichier_inexistant
echo "Première vérification: $?"
echo "Deuxième vérification: $?"  # Affichera 0 (succès de echo)

# ✅ Bon
ls fichier_inexistant
code_retour=$?
echo "Première vérification: $code_retour"
echo "Deuxième vérification: $code_retour"  # Conserve la valeur
```

> [!tip] Astuce Dans vos scripts, utilisez `set -e` pour arrêter automatiquement l'exécution en cas d'erreur, ou `set -o pipefail` pour détecter les erreurs dans les pipes.

---

## Variables d'arguments

### `$#` - Nombre d'arguments

**Pourquoi c'est important :** Permet de valider que le script reçoit le bon nombre d'arguments avant de les traiter.

**Syntaxe et utilisation :**

```bash
#!/bin/bash
# Script nécessitant exactement 2 arguments

if [ $# -ne 2 ]; then
    echo "Erreur: Ce script nécessite exactement 2 arguments"
    echo "Usage: $0 <fichier_source> <fichier_destination>"
    exit 1
fi

echo "Nombre d'arguments reçus: $#"
```

> [!example] Exemple avancé Gestion flexible du nombre d'arguments :
> 
> ```bash
> case $# in
>     0)
>         echo "Mode interactif"
>         read -p "Entrez le nom: " nom
>         ;;
>     1)
>         nom=$1
>         ;;
>     *)
>         echo "Trop d'arguments (reçu: $#)"
>         exit 1
>         ;;
> esac
> ```

---

### `$@` et `$*` - Tous les arguments

**Différence fondamentale :**

|Variable|Comportement entre guillemets|Usage principal|
|---|---|---|
|`$@`|Chaque argument reste séparé|Préserver les arguments individuels|
|`$*`|Tous les arguments fusionnés en une chaîne|Affichage ou log|

**Syntaxe et utilisation :**

```bash
#!/bin/bash

# Démonstration de la différence
afficher_args() {
    echo "Nombre d'arguments reçus: $#"
    for arg in "$@"; do
        echo "  - [$arg]"
    done
}

# Test avec des arguments contenant des espaces
afficher_args "argument 1" "argument 2" "argument 3"

# $@ : préserve les arguments séparés
echo "Avec \$@:"
for arg in "$@"; do
    echo "Arg: $arg"
done

# $* : fusionne tout en une chaîne
echo "Avec \$*:"
for arg in "$*"; do
    echo "Arg: $arg"  # Boucle exécutée une seule fois
done
```

**Résultat :**

```
Avec $@:
Arg: argument 1
Arg: argument 2
Arg: argument 3

Avec $*:
Arg: argument 1 argument 2 argument 3
```

> [!warning] Piège majeur Sans guillemets, `$@` et `$*` se comportent de manière identique. Utilisez TOUJOURS `"$@"` entre guillemets pour préserver les espaces dans les arguments.

**Cas d'usage pratiques :**

```bash
# ✅ Transmettre tous les arguments à une autre commande
grep "$pattern" "$@"  # Cherche dans tous les fichiers passés en argument

# ✅ Logger tous les arguments
echo "$(date): Script appelé avec: $*" >> log.txt

# ✅ Traiter chaque argument individuellement
for fichier in "$@"; do
    if [ -f "$fichier" ]; then
        traiter_fichier "$fichier"
    fi
done
```

---

### `$0`, `$1`, `$2`, ... - Nom du script et arguments positionnels

**Pourquoi c'est important :** Permet d'accéder à chaque argument individuellement et de connaître le nom du script pour les messages d'aide.

**Syntaxe et utilisation :**

```bash
#!/bin/bash

# $0 contient le nom du script (ou son chemin)
script_name=$(basename "$0")
echo "Vous avez lancé: $script_name"

# Accès aux arguments individuels
premier_arg=$1
deuxieme_arg=$2
troisieme_arg=$3

echo "Premier argument: $premier_arg"
echo "Deuxième argument: $deuxieme_arg"
echo "Troisième argument: $troisieme_arg"

# Vérification d'arguments vides
if [ -z "$1" ]; then
    echo "Erreur: Le premier argument est obligatoire"
    exit 1
fi
```

> [!tip] Astuce - basename Utilisez `basename "$0"` pour obtenir uniquement le nom du script sans le chemin, utile pour les messages d'usage.

**Décalage d'arguments avec `shift` :**

```bash
# shift déplace tous les arguments d'une position vers la gauche
# $2 devient $1, $3 devient $2, etc.

#!/bin/bash
echo "Avant shift: \$1=$1, \$2=$2, \$3=$3"
shift
echo "Après shift: \$1=$1, \$2=$2, \$3=$3"
shift 2  # Décale de 2 positions
echo "Après shift 2: \$1=$1"

# Usage pratique : traiter les options puis les arguments
while [ $# -gt 0 ]; do
    case $1 in
        -v|--verbose)
            verbose=true
            shift
            ;;
        -o|--output)
            output_file=$2
            shift 2  # Décale l'option ET sa valeur
            ;;
        *)
            break  # Argument non reconnu, on arrête
            ;;
    esac
done

# Maintenant $@ contient uniquement les arguments restants
echo "Fichiers à traiter: $@"
```

> [!example] Exemple complet - Script de copie
> 
> ```bash
> #!/bin/bash
> 
> if [ $# -lt 2 ]; then
>     echo "Usage: $(basename "$0") <source> <destination> [options]"
>     exit 1
> fi
> 
> source=$1
> destination=$2
> shift 2  # Retire source et destination
> 
> # Les options restantes dans $@
> cp "$source" "$destination" "$@"
> ```

---

## Variables de processus

### `$$` - PID du script actuel

**Pourquoi c'est important :** Le PID (Process ID) unique permet de créer des fichiers temporaires sans conflit et d'identifier le processus.

**Syntaxe et utilisation :**

```bash
# Créer un fichier temporaire unique
temp_file="/tmp/mon_script_$$.tmp"
echo "Données temporaires" > "$temp_file"

# Nettoyer à la fin du script
trap "rm -f $temp_file" EXIT

# Créer un fichier de lock
lock_file="/var/lock/mon_script.lock"
echo $$ > "$lock_file"

# Vérifier si le script est déjà en cours d'exécution
if [ -f "$lock_file" ]; then
    old_pid=$(cat "$lock_file")
    if ps -p $old_pid > /dev/null 2>&1; then
        echo "Le script est déjà en cours d'exécution (PID: $old_pid)"
        exit 1
    fi
fi

echo $$ > "$lock_file"
trap "rm -f $lock_file" EXIT
```

> [!tip] Astuce - Fichiers temporaires Préférez `mktemp` pour créer des fichiers temporaires sécurisés plutôt que de construire le nom manuellement.

---

### `$!` - PID du dernier processus en arrière-plan

**Pourquoi c'est important :** Permet de suivre et contrôler les processus lancés en arrière-plan avec `&`.

**Syntaxe et utilisation :**

```bash
# Lancer un processus en arrière-plan
./long_traitement.sh &
pid_traitement=$!

echo "Traitement lancé avec le PID: $pid_traitement"

# Attendre la fin du processus
wait $pid_traitement
echo "Le traitement est terminé avec le code: $?"

# Surveiller un processus
./serveur.sh &
serveur_pid=$!

while ps -p $serveur_pid > /dev/null; do
    echo "Le serveur (PID: $serveur_pid) est actif..."
    sleep 5
done

echo "Le serveur s'est arrêté"
```

> [!example] Exemple - Timeout sur un processus
> 
> ```bash
> # Lancer une commande avec timeout
> ./commande_longue &
> cmd_pid=$!
> 
> # Attendre maximum 30 secondes
> timeout=30
> while [ $timeout -gt 0 ]; do
>     if ! ps -p $cmd_pid > /dev/null; then
>         wait $cmd_pid
>         echo "Commande terminée avec code: $?"
>         exit 0
>     fi
>     sleep 1
>     ((timeout--))
> done
> 
> # Timeout atteint
> echo "Timeout! Arrêt du processus $cmd_pid"
> kill $cmd_pid
> ```

> [!warning] Attention `$!` ne contient le PID que du dernier processus lancé en arrière-plan. Si vous lancez plusieurs processus, sauvegardez chaque PID dans une variable distincte.

---

## Variables diverses

### `$_` - Dernier argument de la commande précédente

**Pourquoi c'est important :** Économise de la frappe en récupérant le dernier argument de la commande précédente, particulièrement utile en ligne de commande interactive.

**Syntaxe et utilisation :**

```bash
# En ligne de commande interactive
mkdir /tmp/nouveau_dossier
cd $_  # Équivaut à: cd /tmp/nouveau_dossier

# Dans un script
touch fichier.txt
echo "Fichier créé: $_"  # Affiche: fichier.txt

# Copier puis éditer
cp /etc/config.conf /tmp/
vim $_  # Ouvre /tmp/config.conf
```

> [!info] Comportement spécial Dans un script, `$_` contient le chemin absolu du script au début de son exécution. Ensuite, elle prend la valeur du dernier argument de chaque commande.

**Différence avec `!$` (historique Bash) :**

```bash
# En interactif, !$ fait référence au dernier argument de la commande précédente
# dans l'historique (similaire à $_)

echo fichier1 fichier2 fichier3
cat !$  # Équivaut à: cat fichier3

# Mais $_ est plus portable et fonctionne dans les scripts
```

> [!tip] Astuce interactive Utilisez `Alt + .` (point) ou `Esc + .` pour insérer le dernier argument de la commande précédente directement dans la ligne de commande.

---

## Tableau récapitulatif

|Variable|Description|Exemple d'utilisation|
|---|---|---|
|`$?`|Code de retour (0 = succès)|`if [ $? -eq 0 ]; then echo "OK"; fi`|
|`$#`|Nombre d'arguments|`if [ $# -ne 2 ]; then echo "Erreur"; fi`|
|`$@`|Tous les arguments (séparés)|`for arg in "$@"; do echo "$arg"; done`|
|`$*`|Tous les arguments (chaîne)|`echo "Args: $*" >> log.txt`|
|`$$`|PID du script|`temp="/tmp/script_$$.tmp"`|
|`$0`|Nom du script|`echo "Usage: $(basename $0) <args>"`|
|`$1`, `$2`...|Arguments positionnels|`fichier_source=$1; dest=$2`|
|`$!`|PID dernier processus bg|`./cmd & pid=$!; wait $pid`|
|`$_`|Dernier argument précédent|`mkdir dir; cd $_`|

---

## Bonnes pratiques

### 1. Toujours vérifier les arguments

```bash
#!/bin/bash

# ✅ Bon - Vérification complète
if [ $# -eq 0 ]; then
    echo "Usage: $(basename "$0") <fichier> [options]" >&2
    exit 1
fi

if [ ! -f "$1" ]; then
    echo "Erreur: '$1' n'est pas un fichier valide" >&2
    exit 1
fi
```

### 2. Utiliser les guillemets avec `$@`

```bash
# ❌ Mauvais - Les espaces dans les noms de fichiers causeront des problèmes
for fichier in $@; do
    cat $fichier
done

# ✅ Bon - Préserve les espaces
for fichier in "$@"; do
    cat "$fichier"
done
```

### 3. Sauvegarder `$?` immédiatement

```bash
# ❌ Mauvais
commande_importante
echo "En train de vérifier..."  # Écrase $?
if [ $? -eq 0 ]; then  # Vérifie le code de echo, pas de commande_importante
    echo "Succès"
fi

# ✅ Bon
commande_importante
resultat=$?
echo "En train de vérifier..."
if [ $resultat -eq 0 ]; then
    echo "Succès"
fi
```

### 4. Protéger les fichiers temporaires

```bash
# ✅ Utiliser trap pour nettoyer
temp_file="/tmp/script_$$.tmp"

cleanup() {
    rm -f "$temp_file"
}

trap cleanup EXIT INT TERM

# Le fichier sera supprimé même en cas d'interruption
```

### 5. Documenter l'usage avec `$0`

```bash
usage() {
    cat << EOF
Usage: $(basename "$0") [OPTIONS] <fichier>

Options:
    -v, --verbose    Mode verbeux
    -o, --output     Fichier de sortie
    -h, --help       Affiche cette aide

Exemples:
    $(basename "$0") -v fichier.txt
    $(basename "$0") --output result.txt input.txt
EOF
}

if [ $# -eq 0 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    usage
    exit 0
fi
```

### 6. Gérer les processus en arrière-plan proprement

```bash
# ✅ Attendre tous les processus enfants
pids=()

for fichier in *.txt; do
    traiter "$fichier" &
    pids+=($!)
done

# Attendre tous les processus
for pid in "${pids[@]}"; do
    wait "$pid"
    code=$?
    if [ $code -ne 0 ]; then
        echo "Processus $pid a échoué (code: $code)" >&2
    fi
done
```

> [!warning] Piège avec shift Après `shift`, vous ne pouvez plus accéder aux arguments décalés. Sauvegardez-les d'abord si nécessaire.

> [!tip] Débogage Utilisez `set -x` en début de script pour afficher chaque commande avec les valeurs des variables substituées. Très utile pour comprendre le comportement de `$@`, `$*`, etc.

---

**📌 Points clés à retenir :**

1. **`$?`** est volatile - sauvegardez-le immédiatement
2. **`"$@"`** avec guillemets pour préserver les arguments
3. **`$#`** pour valider le nombre d'arguments
4. **`$$`** pour créer des fichiers uniques
5. **`$!`** pour gérer les processus en arrière-plan
6. **`$0`** pour des messages d'aide clairs