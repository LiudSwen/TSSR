

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

La gestion des erreurs est fondamentale en programmation Bash. Contrairement aux langages avec des exceptions, Bash utilise un système de **codes de retour** pour signaler le succès ou l'échec d'une commande. Comprendre ce mécanisme permet d'écrire des scripts robustes et fiables.

> [!info] Pourquoi c'est important
> 
> - Permet de détecter et gérer les échecs des commandes
> - Évite la propagation silencieuse des erreurs
> - Facilite le débogage et la maintenance
> - Permet l'automatisation avec une gestion d'erreur appropriée

---

## Codes de retour

### La variable `$?`

La variable spéciale `$?` contient le **code de retour de la dernière commande exécutée**. C'est le mécanisme central de la gestion d'erreurs en Bash.

```bash
# Exécuter une commande réussie
ls /tmp
echo $?  # Affiche : 0

# Exécuter une commande échouée
ls /repertoire_inexistant
echo $?  # Affiche : 2 (ou un autre code d'erreur)
```

> [!warning] Attention La variable `$?` est écrasée après **chaque** commande. Il faut la capturer immédiatement si vous voulez l'utiliser.

```bash
# ❌ INCORRECT
ls /fichier_inexistant
echo "Une erreur s'est produite"
echo $?  # Affiche 0 (code de retour de echo, pas de ls !)

# ✅ CORRECT
ls /fichier_inexistant
code_retour=$?
echo "Une erreur s'est produite"
echo $code_retour  # Affiche le vrai code d'erreur de ls
```

### Convention des codes de retour

La convention universelle en Unix/Linux est simple mais stricte :

|Code|Signification|
|---|---|
|**0**|Succès|
|**Non-zéro**|Échec|

```bash
# Exemple de test
if commande; then
    echo "Succès"  # Exécuté si code de retour = 0
else
    echo "Échec"   # Exécuté si code de retour ≠ 0
fi
```

> [!tip] Astuce En Bash, une commande qui retourne 0 est évaluée comme **vraie** dans un test, et non-zéro comme **fausse**. C'est l'inverse de nombreux langages de programmation !

### Codes d'erreur standards

Bien que tout code non-zéro indique une erreur, certains codes ont des significations conventionnelles :

|Code|Signification|Exemple|
|---|---|---|
|**0**|Succès|Commande réussie|
|**1**|Erreur générale|Erreur non spécifique|
|**2**|Usage incorrect|Arguments invalides|
|**126**|Commande non exécutable|Permissions insuffisantes|
|**127**|Commande introuvable|Commande n'existe pas|
|**128+N**|Signal mortel|130 = Ctrl+C (SIGINT)|
|**130**|Script terminé par Ctrl+C|-|
|**255**|Code de sortie hors plage|-|

```bash
# Exemple avec différents codes d'erreur
ls /fichier_inexistant
echo $?  # 2 : fichier/répertoire non trouvé

./script_sans_permission.sh
echo $?  # 126 : permission refusée

commande_inexistante
echo $?  # 127 : commande introuvable
```

> [!example] Exemple pratique
> 
> ```bash
> # Vérifier un code d'erreur spécifique
> grep "motif" fichier.txt
> resultat=$?
> 
> if [ $resultat -eq 0 ]; then
>     echo "Motif trouvé"
> elif [ $resultat -eq 1 ]; then
>     echo "Motif non trouvé (normal)"
> else
>     echo "Erreur lors de la recherche : code $resultat"
> fi
> ```

### Définir des codes personnalisés avec `exit`

La commande `exit` permet de terminer un script avec un code de retour spécifique.

#### Syntaxe de base

```bash
exit [code]
```

- Sans argument : utilise le code de retour de la dernière commande
- Avec un nombre (0-255) : définit explicitement le code de retour

#### Exemples d'utilisation

```bash
#!/bin/bash

# Terminer avec succès
function operation_reussie() {
    echo "Opération réussie"
    exit 0
}

# Terminer avec erreur
function operation_echouee() {
    echo "Erreur fatale" >&2
    exit 1
}

# Codes d'erreur personnalisés
if [ ! -f "$1" ]; then
    echo "Erreur : fichier non trouvé" >&2
    exit 2  # Code personnalisé pour "fichier manquant"
fi

if [ ! -r "$1" ]; then
    echo "Erreur : pas de permission de lecture" >&2
    exit 3  # Code personnalisé pour "permission refusée"
fi

# Le script continue si aucune erreur...
```

> [!tip] Bonnes pratiques pour les codes personnalisés
> 
> - **0** : réservé au succès uniquement
> - **1** : erreur générale/indéfinie
> - **2-63** : codes personnalisés pour votre application
> - **64-113** : éviter (réservés par certaines conventions)
> - **128+** : réservés aux signaux système

#### Documenter vos codes d'erreur

```bash
#!/bin/bash

# Codes de retour personnalisés :
# 0  : Succès
# 1  : Erreur générale
# 2  : Fichier manquant
# 3  : Permission refusée
# 4  : Format invalide
# 5  : Connexion réseau échouée

readonly ERR_FILE_NOT_FOUND=2
readonly ERR_PERMISSION_DENIED=3
readonly ERR_INVALID_FORMAT=4
readonly ERR_NETWORK_FAILURE=5

if [ ! -f "$fichier" ]; then
    echo "Fichier '$fichier' introuvable" >&2
    exit $ERR_FILE_NOT_FOUND
fi
```

### Vérification des codes de retour

Il existe plusieurs méthodes pour vérifier et réagir aux codes de retour.

#### Méthode 1 : Test conditionnel avec `if`

```bash
# Forme simple
if commande; then
    echo "Succès"
else
    echo "Échec"
fi

# Avec capture du code
if commande; then
    echo "Succès"
else
    code=$?
    echo "Échec avec code : $code"
fi
```

#### Méthode 2 : Opérateurs logiques `&&` et `||`

```bash
# && : exécute la commande suivante SI la précédente réussit (code 0)
commande1 && commande2 && commande3

# || : exécute la commande suivante SI la précédente échoue (code ≠ 0)
commande1 || echo "Erreur dans commande1"

# Combinaison courante
mkdir /tmp/backup && cp fichier.txt /tmp/backup/ || echo "Échec de la sauvegarde"
```

> [!example] Exemple pratique avec `&&` et `||`
> 
> ```bash
> # Chaîne de commandes avec gestion d'erreur
> cd /projet && \
>     git pull && \
>     npm install && \
>     npm test || {
>         echo "Une étape a échoué" >&2
>         exit 1
>     }
> ```

#### Méthode 3 : Comparaison directe avec `$?`

```bash
commande
code=$?

if [ $code -eq 0 ]; then
    echo "Succès"
elif [ $code -eq 1 ]; then
    echo "Erreur générale"
elif [ $code -eq 2 ]; then
    echo "Erreur spécifique"
else
    echo "Erreur inattendue : $code"
fi
```

#### Méthode 4 : Structure `case` pour codes multiples

```bash
commande
code=$?

case $code in
    0)
        echo "Succès"
        ;;
    1)
        echo "Erreur générale"
        ;;
    2)
        echo "Fichier non trouvé"
        ;;
    126|127)
        echo "Problème d'exécution"
        ;;
    *)
        echo "Erreur inconnue : $code"
        ;;
esac
```

> [!warning] Piège courant : Pipelines Dans un pipeline, `$?` retourne le code de la **dernière** commande seulement :
> 
> ```bash
> # ❌ Problématique
> commande1 | commande2 | commande3
> echo $?  # Code de commande3 uniquement
> 
> # ✅ Solution : utiliser PIPESTATUS
> commande1 | commande2 | commande3
> echo "${PIPESTATUS[@]}"  # Codes de toutes les commandes
> ```

#### Vérification systématique : fonction utilitaire

```bash
# Fonction pour vérifier et afficher les erreurs
check_error() {
    local code=$?
    local message="$1"
    
    if [ $code -ne 0 ]; then
        echo "ERREUR : $message (code : $code)" >&2
        exit $code
    fi
}

# Utilisation
cp fichier.txt /backup/
check_error "Impossible de copier le fichier"

rm fichier_temporaire.tmp
check_error "Impossible de supprimer le fichier temporaire"
```

> [!tip] Astuce avancée : Fonction avec code personnalisé
> 
> ```bash
> die() {
>     local message="$1"
>     local code="${2:-1}"  # Code par défaut : 1
>     
>     echo "ERREUR FATALE : $message" >&2
>     exit "$code"
> }
> 
> # Utilisation
> [ -f "$fichier" ] || die "Fichier '$fichier' manquant" 2
> [ -r "$fichier" ] || die "Impossible de lire '$fichier'" 3
> ```

#### Pattern : Vérification en début de script

```bash
#!/bin/bash

# Vérifications préliminaires
command -v git >/dev/null 2>&1 || {
    echo "Erreur : git n'est pas installé" >&2
    exit 127
}

[ -d ".git" ] || {
    echo "Erreur : pas un dépôt git" >&2
    exit 1
}

[ $# -ge 1 ] || {
    echo "Usage : $0 <fichier>" >&2
    exit 2
}

# Le script continue si toutes les vérifications passent...
```

---

> [!info] Points clés à retenir
> 
> - `$?` contient toujours le code de retour de la dernière commande
> - **0 = succès**, **non-zéro = échec**
> - Capturer `$?` immédiatement car il est écrasé à chaque commande
> - Utiliser `exit` pour définir le code de retour de votre script
> - Documenter vos codes d'erreur personnalisés
> - Toujours vérifier les codes de retour des commandes critiques