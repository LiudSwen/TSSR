

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

## Introduction aux patterns

Les **patterns** (ou motifs) en Bash permettent de faire correspondre des chaînes de caractères selon des règles de comparaison flexibles. Ils sont principalement utilisés dans les structures `case` et pour le globbing de fichiers.

> [!info] Différence entre patterns et regex Les patterns Bash ne sont **pas** des expressions régulières complètes. Ils utilisent une syntaxe plus simple, spécifique au shell, appelée "glob patterns" ou "wildcards".

### Pourquoi utiliser les patterns ?

- **Simplifier les conditions multiples** : au lieu de nombreux `if-elif-else`
- **Filtrage flexible** : traiter plusieurs cas similaires en une seule règle
- **Lisibilité** : code plus clair et plus maintenable
- **Performance** : plus rapide que les comparaisons multiples

---

## Pattern simple (valeur exacte)

Le pattern le plus basique est la **correspondance exacte** d'une chaîne de caractères.

### Syntaxe

```bash
case "$variable" in
    valeur_exacte)
        # Code exécuté si $variable == "valeur_exacte"
        ;;
esac
```

### Exemple pratique

```bash
#!/bin/bash

choix="oui"

case "$choix" in
    oui)
        echo "Vous avez choisi oui"
        ;;
    non)
        echo "Vous avez choisi non"
        ;;
esac
```

> [!example] Cas d'usage Menus interactifs, validation de réponses utilisateur, traitement de configurations avec valeurs fixes.

### Points importants

- Les patterns sont **sensibles à la casse** par défaut
- Utilisez toujours des guillemets autour de `"$variable"` pour gérer les espaces
- Chaque pattern se termine par `)`
- Chaque bloc de code se termine par `;;`

> [!warning] Attention aux espaces
> 
> ```bash
> # ❌ Incorrect (espace dans le pattern)
> case "$var" in
>     oui )  # L'espace avant ) peut causer des problèmes
>         ;;
> esac
> 
> # ✅ Correct
> case "$var" in
>     oui)
>         ;;
> esac
> ```

---

## Le wildcard `*` (n'importe quelle chaîne)

Le symbole `*` correspond à **zéro ou plusieurs caractères** quelconques.

### Syntaxe et comportement

```bash
case "$variable" in
    motif*)      # Commence par "motif"
        ;;
    *motif)      # Se termine par "motif"
        ;;
    *motif*)     # Contient "motif" n'importe où
        ;;
    *)           # N'importe quelle valeur (catch-all)
        ;;
esac
```

### Exemples détaillés

```bash
#!/bin/bash

fichier="document.txt"

case "$fichier" in
    *.txt)
        echo "Fichier texte"
        ;;
    *.pdf)
        echo "Fichier PDF"
        ;;
    *.*)
        echo "Fichier avec extension"
        ;;
    *)
        echo "Fichier sans extension"
        ;;
esac
```

### Utilisation avancée

```bash
#!/bin/bash

url="https://www.example.com/page"

case "$url" in
    http://*)
        echo "URL non sécurisée (HTTP)"
        ;;
    https://*)
        echo "URL sécurisée (HTTPS)"
        ;;
    ftp://*)
        echo "Serveur FTP"
        ;;
    *)
        echo "Protocole inconnu"
        ;;
esac
```

> [!tip] Astuce - Ordre des patterns L'ordre des patterns dans un `case` est crucial. Les patterns plus **spécifiques** doivent venir **avant** les plus génériques, car le premier pattern qui correspond est exécuté.
> 
> ```bash
> # ❌ Mauvais ordre
> case "$file" in
>     *)              # Attrape tout en premier !
>         echo "Fichier quelconque"
>         ;;
>     *.txt)          # Ne sera jamais atteint
>         echo "Fichier texte"
>         ;;
> esac
> 
> # ✅ Bon ordre
> case "$file" in
>     *.txt)
>         echo "Fichier texte"
>         ;;
>     *)
>         echo "Fichier quelconque"
>         ;;
> esac
> ```

### Cas d'usage courants

|Pattern|Correspond à|Exemple|
|---|---|---|
|`*.log`|Fichiers log|`app.log`, `error.log`|
|`test*`|Commence par "test"|`test123`, `test_file`|
|`*error*`|Contient "error"|`my_error.log`, `error_handler`|
|`*`|Tout|N'importe quelle valeur|

> [!warning] Piège du `*` seul Le pattern `*` dans un `case` attrape **absolument tout**, y compris les chaînes vides. Placez-le toujours en dernier comme cas par défaut.

---

## Le wildcard `?` (un caractère quelconque)

Le symbole `?` correspond à **exactement un caractère** quelconque (mais pas zéro).

### Syntaxe

```bash
case "$variable" in
    ?)           # Exactement 1 caractère
        ;;
    ??)          # Exactement 2 caractères
        ;;
    ???*)        # 3 caractères ou plus
        ;;
    fichier?.txt) # "fichier" + 1 caractère + ".txt"
        ;;
esac
```

### Exemples pratiques

```bash
#!/bin/bash

code="A5"

case "$code" in
    ??)
        echo "Code à 2 caractères : $code"
        ;;
    ???)
        echo "Code à 3 caractères : $code"
        ;;
    ?)
        echo "Code à 1 caractère : $code"
        ;;
    *)
        echo "Code de longueur différente"
        ;;
esac
```

### Validation de formats

```bash
#!/bin/bash

plaque="AB-123-CD"

case "$plaque" in
    ??-???-??)
        echo "Format de plaque valide"
        ;;
    *)
        echo "Format de plaque invalide"
        ;;
esac
```

### Différences avec `*`

|Wildcard|Correspond à|Exemple avec "A"|Exemple avec "ABC"|
|---|---|---|---|
|`?`|Exactement 1 caractère|✅ Match|❌ Pas de match|
|`*`|0 ou plus|✅ Match|✅ Match|
|`??`|Exactement 2 caractères|❌ Pas de match|❌ Pas de match (3 chars)|
|`?*`|1 ou plus|✅ Match|✅ Match|

> [!example] Cas d'usage
> 
> - Validation de codes postaux : `?????` pour 5 chiffres
> - Formats de fichiers : `image?.png` pour `image1.png`, `imageA.png`
> - Masquage partiel : `user-????` pour `user-1234`

> [!tip] Combiner `?` et `*`
> 
> ```bash
> case "$fichier" in
>     ?.txt)          # 1 caractère + .txt → "a.txt"
>         ;;
>     ??.txt)         # 2 caractères + .txt → "ab.txt"
>         ;;
>     ???*.txt)       # 3+ caractères + .txt → "abc.txt", "abcd.txt"
>         ;;
> esac
> ```

---

## Les classes de caractères `[abc]`

Les **crochets** `[]` définissent un ensemble de caractères possibles. Le pattern correspond si **un seul** des caractères de l'ensemble est présent.

### Syntaxe de base

```bash
case "$variable" in
    [abc])          # 'a' ou 'b' ou 'c' (1 caractère)
        ;;
    [a-z])          # Toute lettre minuscule (1 caractère)
        ;;
    [A-Z])          # Toute lettre majuscule (1 caractère)
        ;;
    [0-9])          # Tout chiffre (1 caractère)
        ;;
    [a-zA-Z])       # Toute lettre (1 caractère)
        ;;
    [!0-9])         # Tout sauf un chiffre (1 caractère)
        ;;
esac
```

> [!info] La négation avec `!` `[!xyz]` correspond à n'importe quel caractère **sauf** x, y ou z. C'est l'équivalent de "NOT" pour les classes de caractères.

### Exemples détaillés

```bash
#!/bin/bash

note="B"

case "$note" in
    [A-C])
        echo "Excellente note !"
        ;;
    [D-E])
        echo "Note moyenne"
        ;;
    [F])
        echo "Note insuffisante"
        ;;
    *)
        echo "Note invalide"
        ;;
esac
```

### Classes combinées avec d'autres wildcards

```bash
#!/bin/bash

fichier="data123.txt"

case "$fichier" in
    [a-z]*.txt)
        echo "Fichier .txt commençant par une minuscule"
        ;;
    [A-Z]*.txt)
        echo "Fichier .txt commençant par une majuscule"
        ;;
    [0-9]*.txt)
        echo "Fichier .txt commençant par un chiffre"
        ;;
    *)
        echo "Autre type de fichier"
        ;;
esac
```

### Validation de format avec classes

```bash
#!/bin/bash

code_produit="A12345"

case "$code_produit" in
    [A-Z][0-9][0-9][0-9][0-9][0-9])
        echo "Code produit valide : 1 lettre + 5 chiffres"
        ;;
    [A-Z][0-9]*)
        echo "Code produit avec lettre et chiffres, mais format incorrect"
        ;;
    *)
        echo "Format de code invalide"
        ;;
esac
```

### Classes de caractères spéciales

```bash
case "$char" in
    [[:alpha:]])    # Toute lettre (équivalent à [a-zA-Z])
        ;;
    [[:digit:]])    # Tout chiffre (équivalent à [0-9])
        ;;
    [[:alnum:]])    # Lettre ou chiffre
        ;;
    [[:space:]])    # Espace, tab, newline
        ;;
    [[:upper:]])    # Majuscule
        ;;
    [[:lower:]])    # Minuscule
        ;;
esac
```

> [!tip] Classes POSIX portables Les classes `[[:alpha:]]`, `[[:digit:]]`, etc. sont plus portables que `[a-z]` ou `[0-9]` car elles respectent les locales et fonctionnent avec les caractères accentués.

### Tableau récapitulatif

|Pattern|Correspond à|Exemple match|Exemple non-match|
|---|---|---|---|
|`[abc]`|a, b, ou c|`a`|`d`, `ab`|
|`[a-z]`|Minuscule (1 char)|`m`|`M`, `5`, `abc`|
|`[0-9]`|Chiffre (1 char)|`7`|`a`, `17`|
|`[!0-9]`|Tout sauf chiffre|`a`, `_`|`5`|
|`[a-z]*`|Commence par minuscule|`hello`, `a`|`Hello`, `123`|
|`[0-9][0-9]`|Exactement 2 chiffres|`42`|`7`, `123`|

> [!warning] Erreurs courantes
> 
> ```bash
> # ❌ [abc]* ne veut pas dire "commence par a, b ou c"
> # Il veut dire "zéro ou plus occurrences de a, b ou c"
> # Donc "bbbccc" match aussi !
> 
> # ✅ Pour "commence par a, b ou c puis n'importe quoi"
> case "$var" in
>     [abc]*)
>         ;;
> esac
> 
> # ❌ [a-Z] n'est PAS valide (ordre ASCII incorrect)
> # ✅ Utilisez [a-zA-Z] pour toutes les lettres
> ```

---

## L'opérateur `|` (alternative)

L'opérateur `|` (pipe) permet de combiner plusieurs patterns en mode **OU logique**. Si l'un des patterns correspond, le bloc est exécuté.

### Syntaxe

```bash
case "$variable" in
    pattern1|pattern2|pattern3)
        # Exécuté si $variable correspond à pattern1 OU pattern2 OU pattern3
        ;;
esac
```

### Exemples simples

```bash
#!/bin/bash

reponse="o"

case "$reponse" in
    o|oui|O|OUI|yes|YES)
        echo "Confirmation reçue"
        ;;
    n|non|N|NON|no|NO)
        echo "Annulation"
        ;;
    *)
        echo "Réponse non reconnue"
        ;;
esac
```

### Combinaison avec wildcards

```bash
#!/bin/bash

fichier="archive.tar.gz"

case "$fichier" in
    *.tar.gz|*.tgz|*.tar.bz2|*.tbz)
        echo "Archive compressée détectée"
        echo "Type : archive tar"
        ;;
    *.zip|*.rar|*.7z)
        echo "Archive compressée détectée"
        echo "Type : archive standard"
        ;;
    *.tar)
        echo "Archive non compressée"
        ;;
    *)
        echo "Pas une archive"
        ;;
esac
```

### Cas d'usage avancés

```bash
#!/bin/bash

commande="$1"

case "$commande" in
    start|run|execute|launch)
        echo "Démarrage de l'application..."
        ;;
    stop|halt|kill|terminate)
        echo "Arrêt de l'application..."
        ;;
    restart|reload|reboot)
        echo "Redémarrage de l'application..."
        ;;
    status|info|check)
        echo "Vérification du statut..."
        ;;
    help|--help|-h|?)
        echo "Affichage de l'aide"
        ;;
    *)
        echo "Commande inconnue : $commande"
        exit 1
        ;;
esac
```

### Validation d'extensions multiples

```bash
#!/bin/bash

fichier="$1"

case "$fichier" in
    *.jpg|*.jpeg|*.png|*.gif|*.bmp)
        echo "Format d'image supporté"
        convert "$fichier" "${fichier%.*}.webp"
        ;;
    *.mp4|*.avi|*.mkv|*.mov)
        echo "Format vidéo supporté"
        ;;
    *.mp3|*.wav|*.flac|*.ogg)
        echo "Format audio supporté"
        ;;
    *)
        echo "Format non supporté"
        exit 1
        ;;
esac
```

> [!tip] Astuce - Lisibilité Pour de longues listes d'alternatives, vous pouvez les séparer sur plusieurs lignes :
> 
> ```bash
> case "$extension" in
>     jpg|jpeg|\
>     png|gif|\
>     bmp|webp)
>         echo "Image"
>         ;;
> esac
> ```

### Tableau comparatif

| Sans `|` | Avec `|` | |----------|----------| | `bash<br>case "$x" in<br> a) echo "A" ;;<br> b) echo "A" ;;<br> c) echo "A" ;;<br>esac<br>` | `bash<br>case "$x" in<br> a\|b\|c) echo "A" ;;<br>esac<br>` |

> [!warning] Ne pas confondre avec le pipe shell Dans un `case`, `|` est un **opérateur de pattern**, pas un pipe de commande. Il ne redirige aucune sortie.
> 
> ```bash
> # ✅ Pattern alternatif (dans case)
> case "$var" in
>     a|b|c) echo "ok" ;;
> esac
> 
> # ❌ Ceci est un pipe de commande (pas dans un case)
> echo "test" | grep "pattern"
> ```

---

## Le cas par défaut avec `*)`

Le pattern `*)` est le **cas par défaut** (catch-all, fallback) qui correspond à **toute valeur** qui n'a été attrapée par aucun pattern précédent.

### Syntaxe et position

```bash
case "$variable" in
    pattern1)
        # Traitement spécifique
        ;;
    pattern2)
        # Autre traitement
        ;;
    *)
        # ⚠️ TOUJOURS EN DERNIER
        # Cas par défaut pour toute autre valeur
        ;;
esac
```

### Exemple basique

```bash
#!/bin/bash

jour="$1"

case "$jour" in
    lundi|mardi|mercredi|jeudi|vendredi)
        echo "Jour de la semaine"
        ;;
    samedi|dimanche)
        echo "Week-end"
        ;;
    *)
        echo "Jour invalide : $jour"
        echo "Utilisez : lundi, mardi, ..., dimanche"
        exit 1
        ;;
esac
```

### Gestion d'erreurs avec `*)`

```bash
#!/bin/bash

action="$1"

case "$action" in
    install)
        echo "Installation en cours..."
        ;;
    remove)
        echo "Désinstallation en cours..."
        ;;
    update)
        echo "Mise à jour en cours..."
        ;;
    *)
        echo "❌ ERREUR : Action '$action' non reconnue"
        echo ""
        echo "Actions disponibles :"
        echo "  - install : Installer le paquet"
        echo "  - remove  : Supprimer le paquet"
        echo "  - update  : Mettre à jour le paquet"
        exit 1
        ;;
esac
```

### Cas par défaut avec journalisation

```bash
#!/bin/bash

niveau="$1"
message="$2"

case "$niveau" in
    info|INFO)
        echo "[INFO] $message"
        ;;
    warning|WARNING|warn|WARN)
        echo "[⚠️  WARNING] $message" >&2
        ;;
    error|ERROR)
        echo "[❌ ERROR] $message" >&2
        exit 1
        ;;
    *)
        # Log avec niveau inconnu
        echo "[UNKNOWN:$niveau] $message" >&2
        echo "Note: Niveau de log non standard utilisé" >&2
        ;;
esac
```

### Quand omettre le cas par défaut ?

> [!info] Le `*)` n'est pas toujours obligatoire Vous pouvez omettre le cas par défaut si :
> 
> - Vous êtes **certain** que tous les cas sont couverts
> - L'absence de correspondance ne nécessite aucune action
> 
> Cependant, c'est **fortement déconseillé** en production car cela peut masquer des bugs.

```bash
# ⚠️ Sans cas par défaut (risqué)
case "$couleur" in
    rouge)
        echo "Stop"
        ;;
    orange)
        echo "Attention"
        ;;
    vert)
        echo "Passez"
        ;;
    # Si $couleur = "bleu", rien ne se passe (silence)
esac

# ✅ Avec cas par défaut (recommandé)
case "$couleur" in
    rouge)
        echo "Stop"
        ;;
    orange)
        echo "Attention"
        ;;
    vert)
        echo "Passez"
        ;;
    *)
        echo "Couleur de feu invalide : $couleur"
        ;;
esac
```

> [!tip] Bonne pratique **Toujours** inclure un cas par défaut `*)`, même si c'est juste pour loguer un avertissement. Cela rend le code plus robuste et facilite le débogage.
> 
> ```bash
> case "$var" in
>     expected1) ... ;;
>     expected2) ... ;;
>     *)
>         echo "DEBUG: Valeur inattendue : '$var'" >&2
>         ;;
> esac
> ```

### Cas par défaut interactif

```bash
#!/bin/bash

choix="$1"

case "$choix" in
    1)
        echo "Option 1 sélectionnée"
        ;;
    2)
        echo "Option 2 sélectionnée"
        ;;
    3)
        echo "Option 3 sélectionnée"
        ;;
    *)
        echo "Choix invalide : $choix"
        echo ""
        echo "Veuillez choisir :"
        echo "  1) Première option"
        echo "  2) Deuxième option"
        echo "  3) Troisième option"
        read -p "Votre choix : " nouveau_choix
        # On pourrait relancer le script ou boucler
        ;;
esac
```

> [!warning] Ordre critique Le pattern `*)` attrape **TOUT**. S'il est placé avant d'autres patterns, ces derniers ne seront **jamais** atteints.
> 
> ```bash
> # ❌ ERREUR : Le cas par défaut en premier
> case "$var" in
>     *)
>         echo "Défaut"  # Attrape tout !
>         ;;
>     specific)           # ⚠️ Jamais atteint
>         echo "Spécifique"
>         ;;
> esac
> 
> # ✅ CORRECT : Le cas par défaut en dernier
> case "$var" in
>     specific)
>         echo "Spécifique"
>         ;;
>     *)
>         echo "Défaut"
>         ;;
> esac
> ```

---

## Fall-through avec `;;&` et `;&`

Par défaut, Bash sort du `case` dès qu'un pattern correspond. Les opérateurs `;;&` et `;&` permettent de **continuer l'évaluation** vers les patterns suivants.

### Comportements des terminateurs

|Terminateur|Comportement|Nom|
|---|---|---|
|`;;`|**Stop** : sort du case (défaut)|Break|
|`;;&`|**Continue** : teste les patterns suivants|Fall-through avec test|
|`;&`|**Execute** : exécute le bloc suivant sans tester|Fall-through direct|

> [!warning] Attention `;;&` et `;&` sont des fonctionnalités **Bash 4+**. Elles ne fonctionnent pas dans tous les shells POSIX ni dans les vieux scripts.

### L'opérateur `;;&` (fall-through avec test)

Avec `;;&`, Bash continue à **tester** les patterns suivants même après une correspondance.

#### Syntaxe

```bash
case "$variable" in
    pattern1)
        # Code pour pattern1
        ;;&  # Continue à tester les patterns suivants
    pattern2)
        # Code pour pattern2 (testé même si pattern1 match)
        ;;
esac
```

#### Exemple : Catégorisation multiple

```bash
#!/bin/bash

fichier="script.sh"

echo "Analyse de : $fichier"
echo ""

case "$fichier" in
    *.sh)
        echo "✓ C'est un script shell"
        ;;&  # Continue l'évaluation
    *.bash)
        echo "✓ C'est un script Bash spécifique"
        ;;&
    script*)
        echo "✓ Le nom commence par 'script'"
        ;;&
    *.[sb][ha]*)
        echo "✓ Extension de script détectée"
        ;;
esac

# Sortie possible :
# ✓ C'est un script shell
# ✓ Le nom commence par 'script'
# ✓ Extension de script détectée
```

#### Cas d'usage : Validation cumulative

```bash
#!/bin/bash

password="Passw0rd!"

echo "Vérification du mot de passe..."
valide=true

case "$password" in
    *[A-Z]*)
        echo "✓ Contient une majuscule"
        ;;&
    *[a-z]*)
        echo "✓ Contient une minuscule"
        ;;&
    *[0-9]*)
        echo "✓ Contient un chiffre"
        ;;&
    *[[:punct:]]*)
        echo "✓ Contient un caractère spécial"
        ;;&
    ????????*)
        echo "✓ Longueur suffisante (8+ caractères)"
        ;;
    *)
        echo "❌ Le mot de passe ne respecte pas tous les critères"
        valide=false
        ;;
esac

if $valide; then
    echo ""
    echo "Mot de passe accepté !"
fi
```

### L'opérateur `;&` (fall-through direct)

Avec `;&`, Bash **exécute directement** le bloc suivant **sans tester** son pattern.

#### Syntaxe

```bash
case "$variable" in
    pattern1)
        # Code pour pattern1
        ;&  # Exécute le bloc suivant SANS tester son pattern
    pattern2)
        # Code toujours exécuté si pattern1 match
        ;;
esac
```

#### Exemple : Cascade d'actions

```bash
#!/bin/bash

niveau="$1"

case "$niveau" in
    critical)
        echo "🚨 NIVEAU CRITIQUE"
        echo "  → Alerte envoyée à l'équipe"
        ;&  # Exécute aussi le bloc suivant
    error)
        echo "❌ Erreur détectée"
        echo "  → Log dans le fichier d'erreurs"
        ;&
    warning)
        echo "⚠️  Avertissement"
        echo "  → Log dans le fichier principal"
        ;&
    info)
        echo "ℹ️  Information"
        echo "  → Affichage console"
        ;;
    *)
        echo "Niveau inconnu"
        ;;
esac

# Si niveau="error", affiche :
# ❌ Erreur détectée
#   → Log dans le fichier d'erreurs
# ⚠️  Avertissement
#   → Log dans le fichier principal
# ℹ️  Information
#   → Affichage console
```

#### Exemple : Menu avec actions cumulatives

```bash
#!/bin/bash

action="full-reset"

case "$action" in
    full-reset)
        echo "1. Sauvegarde des données..."
        ;&
    reset)
        echo "2. Réinitialisation de la config..."
        ;&
    restart)
        echo "3. Redémarrage du service..."
        ;;
    *)
        echo "Action inconnue"
        ;;
esac

# Si action="full-reset" :
# 1. Sauvegarde des données...
# 2. Réinitialisation de la config...
# 3. Redémarrage du service...
```

### Comparaison des trois terminateurs

```bash
#!/bin/bash

valeur="test"

echo "=== Avec ;; (défaut) ==="
case "$valeur" in
    t*)
        echo "Commence par 't'"
        ;;
    *e*)
        echo "Contient 'e'"
        ;;
    *)
        echo "Autre"
        ;;
esac
# Sortie : "Commence par 't'" (puis sort)

echo ""
echo "=== Avec ;;& (teste les suivants) ==="
case "$valeur" in
    t*)
        echo "Commence par 't'"
        ;;&
    *e*)
        echo "Contient 'e'"
        ;;&
    *)
        echo "Autre"
        ;;
esac
# Sortie :
# Commence par 't'
# Contient 'e'
# Autre

echo ""
echo "=== Avec ;& (exécute le suivant) ==="
case "$valeur" in
    t*)
        echo "Commence par 't'"
        ;&
    *e*)
        echo "Contient 'e' (exécuté sans test)"
        ;;
    *)
        echo "Autre"
        ;;
esac
# Sortie :
# Commence par 't'
# Contient 'e' (exécuté sans test)
```

### Tableau récapitulatif

|Opérateur|Après match|Teste les patterns suivants ?|Cas d'usage|
|---|---|---|---|
|`;;`|**Sortie** du case|Non|Comportement standard|
|`;;&`|**Continue** l'évaluation|**Oui**|Validations multiples, catégorisation|
|`;&`|**Continue** sans test|**Non** (exécution directe)|Actions en cascade, héritage de comportement|

> [!tip] Quand utiliser `;;&` vs `;&` ?
> 
> - **`;;&`** : Quand vous voulez appliquer **plusieurs règles indépendantes** à la même valeur (ex: validation de plusieurs critères)
> - **`;&`** : Quand vous voulez une **cascade d'actions** où une action implique automatiquement les suivantes (ex: niveaux d'alerte)

### Exemple pratique : Système de permissions

```bash
#!/bin/bash

role="$1"
fichier="$2"

echo "Vérification des permissions pour le rôle : $role"
echo ""

case "$role" in
    admin)
        echo "✓ Peut supprimer des fichiers"
        ;&  # Admin hérite des droits editor
    editor)
        echo "✓ Peut modifier des fichiers"
        ;&  # Editor hérite des droits viewer
    viewer)
        echo "✓ Peut lire des fichiers"
        ;;
    guest)
        echo "✓ Accès limité en lecture seule"
        ;;
    *)
        echo "❌ Rôle inconnu"
        exit 1
        ;;
esac
```

### Exemple pratique : Analyse de fichiers

```bash
#!/bin/bash

fichier="$1"

echo "Analyse de : $fichier"
echo ""

case "$fichier" in
    *.tar.gz|*.tgz)
        echo "📦 Archive tar compressée (gzip)"
        ;;&  # Continue à tester
    *.tar*)
        echo "📦 Archive tar détectée"
        ;;&
    *.gz|*.zip|*.bz2)
        echo "🗜️  Fichier compressé"
        ;;&
    *.tar.gz|*.zip|*.rar)
        echo "💾 Archive prête pour extraction"
        ;;
    *)
        echo "📄 Fichier standard"
        ;;
esac
```

> [!warning] Attention à la logique Avec `;;&` et `;&`, la logique peut devenir complexe rapidement. Documentez bien votre code et testez tous les cas possibles.
> 
> ```bash
> # ⚠️ Peut être confus
> case "$x" in
>     a*) echo "A" ;;& 
>     *b) echo "B" ;&
>     c*) echo "C" ;;
> esac
> 
> # ✅ Plus clair avec des commentaires
> case "$x" in
>     a*)
>         echo "Commence par 'a'"
>         ;;&  # Teste aussi les autres patterns
>     *b)
>         echo "Se termine par 'b'"
>         ;&   # Exécute toujours le bloc suivant
>     c*)
>         echo "Traitement final" # Exécuté même si pattern ne match pas
>         ;;
> esac
> ```

### Limites et alternatives

Si vous avez besoin de logique très complexe avec de nombreux fall-throughs, considérez d'autres approches :

```bash
# Au lieu d'un case complexe avec ;;& et ;&
case "$var" in
    pattern1) action1 ;;&
    pattern2) action2 ;;&
    pattern3) action3 ;;&
    pattern4) action4 ;;
esac

# Parfois, des if simples sont plus lisibles
if [[ $var == pattern1 ]]; then
    action1
fi
if [[ $var == pattern2 ]]; then
    action2
fi
if [[ $var == pattern3 ]]; then
    action3
fi
if [[ $var == pattern4 ]]; then
    action4
fi
```

> [!info] Compatibilité Les opérateurs `;;&` et `;&` sont spécifiques à **Bash 4.0+**. Pour des scripts portables (sh, dash, ou vieux systèmes), utilisez uniquement `;;` ou restructurez votre code avec des `if`.

---

## 🎯 Bonnes pratiques générales

### 1. Toujours citer les variables

```bash
# ❌ Dangereux si $var contient des espaces
case $var in
    pattern) echo "ok" ;;
esac

# ✅ Toujours utiliser des guillemets
case "$var" in
    pattern) echo "ok" ;;
esac
```

### 2. Ordre des patterns : du spécifique au général

```bash
# ✅ Bon ordre
case "$fichier" in
    *.tar.gz)       # Plus spécifique
        echo "Archive tar gzip"
        ;;
    *.tar*)         # Moins spécifique
        echo "Archive tar"
        ;;
    *)              # Le plus général
        echo "Autre"
        ;;
esac
```

### 3. Utiliser des patterns lisibles

```bash
# ❌ Difficile à comprendre
case "$f" in
    [a-zA-Z][0-9][0-9][0-9][0-9][0-9]) ... ;;
esac

# ✅ Plus clair avec des commentaires
case "$code_produit" in
    [A-Z][0-9][0-9][0-9][0-9][0-9])
        # Format : 1 lettre majuscule + 5 chiffres
        # Exemple : A12345
        echo "Code valide"
        ;;
esac
```

### 4. Valider les entrées utilisateur

```bash
#!/bin/bash

if [ -z "$1" ]; then
    echo "Erreur : argument manquant"
    exit 1
fi

choix="$1"

case "$choix" in
    1|2|3)
        echo "Choix valide : $choix"
        ;;
    *)
        echo "Erreur : choix invalide '$choix'"
        echo "Attendu : 1, 2 ou 3"
        exit 1
        ;;
esac
```

### 5. Documenter les patterns complexes

```bash
case "$extension" in
    # Extensions d'images raster
    jpg|jpeg|png|gif|bmp|webp)
        type="image_raster"
        ;;
    
    # Extensions d'images vectorielles
    svg|eps|pdf|ai)
        type="image_vector"
        ;;
    
    # Extensions vidéo courantes
    mp4|avi|mkv|mov|wmv|flv)
        type="video"
        ;;
    
    # Cas par défaut
    *)
        type="unknown"
        ;;
esac
```

### 6. Éviter les patterns trop permissifs

```bash
# ❌ Trop large, attrape trop de choses
case "$input" in
    *error*)  # Match "error", "errors", "error_log", "no_error"...
        ;;
esac

# ✅ Plus précis
case "$input" in
    error|ERROR)
        ;;
    *_error|error_*)
        ;;
esac
```

### 7. Tester avec des cas limites

```bash
# Toujours tester :
# - Chaînes vides : ""
# - Espaces : " ", "  "
# - Caractères spéciaux : "!@#$%"
# - Valeurs très longues
# - Valeurs inattendues

case "$input" in
    "")
        echo "Erreur : entrée vide"
        exit 1
        ;;
    *[[:space:]]*)
        echo "Attention : contient des espaces"
        ;;
    *)
        echo "Entrée valide"
        ;;
esac
```

---

## 📊 Tableau comparatif complet

### Wildcards et leur utilisation

|Pattern|Signification|Exemple|Match|Ne match pas|
|---|---|---|---|---|
|`abc`|Exactement "abc"|`abc`|`abc`|`ab`, `abcd`, `ABC`|
|`*`|0+ caractères|`*.txt`|`a.txt`, `.txt`|`txt`, `a.txt.bak`|
|`?`|1 caractère|`?.txt`|`a.txt`, `1.txt`|`.txt`, `ab.txt`|
|`[abc]`|Un parmi a,b,c|`[abc].txt`|`a.txt`, `b.txt`|`d.txt`, `ab.txt`|
|`[a-z]`|Lettre minuscule|`[a-z]*`|`hello`, `a`|`Hello`, `123`|
|`[!0-9]`|Tout sauf chiffre|`[!0-9]*`|`abc`, `_test`|`123`, `1abc`|
|`a\|b`|a OU b|`*.txt\|*.md`|`file.txt`, `doc.md`|`file.pdf`|

### Terminateurs case

|Opérateur|Action|Continue ?|Use case|
|---|---|---|---|
|`;;`|Sort du case|Non|Standard|
|`;;&`|Teste les suivants|Oui (avec test)|Validations multiples|
|`;&`|Exécute le suivant|Oui (sans test)|Cascade d'actions|

---

## 🔍 Pièges courants à éviter

### Piège 1 : Oublier les guillemets

```bash
var="hello world"

# ❌ ERREUR : word splitting
case $var in
    "hello world") echo "ok" ;;
esac
# Bash voit : case hello world in

# ✅ CORRECT
case "$var" in
    "hello world") echo "ok" ;;
esac
```

### Piège 2 : Patterns dans le mauvais ordre

```bash
# ❌ Le cas par défaut attrape tout
case "$file" in
    *)
        echo "Défaut"
        ;;
    *.txt)  # ⚠️ Jamais atteint !
        echo "Texte"
        ;;
esac

# ✅ Spécifique avant général
case "$file" in
    *.txt)
        echo "Texte"
        ;;
    *)
        echo "Défaut"
        ;;
esac
```

### Piège 3 : Confondre `*` et `?`

```bash
fichier="a"

# `*` match ZÉRO ou plus
case "$fichier" in
    a*) echo "Match" ;;  # ✅ Match "a"
esac

# `?` match EXACTEMENT UN
case "$fichier" in
    a?) echo "Match" ;;  # ❌ Ne match PAS "a" (besoin d'un char après)
esac

# Pour "a" seulement
case "$fichier" in
    a) echo "Match" ;;   # ✅ Match exactement "a"
esac
```

### Piège 4 : Classes de caractères mal formées

```bash
# ❌ Ordre incorrect dans la plage
case "$char" in
    [z-a]) echo "?" ;;  # Erreur : z > a en ASCII
esac

# ❌ Mixing ranges incorrectly
case "$char" in
    [a-Z]) echo "?" ;;  # Problème : a-z puis A-Z, pas a-Z
esac

# ✅ Correct
case "$char" in
    [a-z]) echo "Minuscule" ;;
    [A-Z]) echo "Majuscule" ;;
    [a-zA-Z]) echo "Lettre" ;;
esac
```

### Piège 5 : Ne pas gérer les cas vides

```bash
# ❌ Crash si $1 est vide
action="$1"
case "$action" in
    start) ... ;;
    stop) ... ;;
esac

# ✅ Gérer le cas vide
action="${1:-}"  # Vide si $1 non défini
case "$action" in
    start) ... ;;
    stop) ... ;;
    "")
        echo "Erreur : action requise"
        exit 1
        ;;
    *)
        echo "Action inconnue"
        exit 1
        ;;
esac
```

### Piège 6 : Fall-through non voulu avec `;&`

```bash
# ⚠️ Attention avec ;&
case "$niveau" in
    high)
        echo "Niveau élevé"
        ;&  # Exécute TOUJOURS le bloc suivant
    low)
        echo "Niveau bas"  # Affiché même pour "high" !
        ;;
esac

# Si vous voulez tester, utilisez ;;&
case "$niveau" in
    high)
        echo "Niveau élevé"
        ;;&  # Teste si "low" match aussi
    low)
        echo "Niveau bas"  # Affiché seulement si $niveau == "low"
        ;;
esac
```

---

## 🎓 Astuces avancées

### Astuce 1 : Validation de format complexe

```bash
#!/bin/bash

# Valider un email simple
email="user@example.com"

case "$email" in
    *@*.*)
        echo "Format email basique valide"
        ;;
    *)
        echo "Format email invalide"
        ;;
esac

# Valider une adresse IP (basique)
ip="192.168.1.1"

case "$ip" in
    [0-9]*.[0-9]*.[0-9]*.[0-9]*)
        echo "Format IP basique détecté"
        # Note : cette validation est simpliste
        ;;
esac
```

### Astuce 2 : Patterns pour les chemins

```bash
#!/bin/bash

chemin="/home/user/documents/file.txt"

case "$chemin" in
    /home/*)
        echo "Dans le répertoire home"
        ;;
    /etc/*)
        echo "Fichier de configuration système"
        ;;
    /var/log/*)
        echo "Fichier de log"
        ;;
    */temp/*|*/tmp/*)
        echo "Fichier temporaire"
        ;;
    *)
        echo "Autre emplacement"
        ;;
esac
```

### Astuce 3 : Normalisation de l'entrée

```bash
#!/bin/bash

# Accepter plusieurs variations de "oui"
reponse="$1"

# Convertir en minuscules pour comparaison insensible à la casse
reponse_lower=$(echo "$reponse" | tr '[:upper:]' '[:lower:]')

case "$reponse_lower" in
    y|yes|oui|o|1|true)
        echo "Confirmation"
        ;;
    n|no|non|0|false)
        echo "Refus"
        ;;
    *)
        echo "Réponse non reconnue"
        ;;
esac
```

### Astuce 4 : Pattern matching avec variables

```bash
#!/bin/bash

# Vous pouvez utiliser des variables dans les patterns
prefix="test"

case "$fichier" in
    "$prefix"*)
        echo "Commence par $prefix"
        ;;
    *"$prefix"*)
        echo "Contient $prefix"
        ;;
esac
```

### Astuce 5 : Débogage de patterns

```bash
#!/bin/bash

# Activer le mode debug pour voir les patterns testés
set -x

case "$input" in
    pattern1) echo "1" ;;
    pattern2) echo "2" ;;
    *) echo "défaut" ;;
esac

set +x
```

### Astuce 6 : Menu interactif avec case

```bash
#!/bin/bash

while true; do
    echo ""
    echo "=== Menu Principal ==="
    echo "1) Démarrer"
    echo "2) Arrêter"
    echo "3) Redémarrer"
    echo "4) Statut"
    echo "q) Quitter"
    echo ""
    read -p "Votre choix : " choix
    
    case "$choix" in
        1|start|démarrer)
            echo "Démarrage..."
            ;;
        2|stop|arrêter)
            echo "Arrêt..."
            ;;
        3|restart|redémarrer)
            echo "Redémarrage..."
            ;;
        4|status|statut)
            echo "Vérification du statut..."
            ;;
        q|quit|quitter|exit)
            echo "Au revoir !"
            break
            ;;
        *)
            echo "❌ Choix invalide"
            ;;
    esac
done
```

---

## 🏁 Résumé

Les patterns en Bash offrent un moyen puissant et lisible de gérer des correspondances de chaînes :

- **`valeur`** : correspondance exacte
- **`*`** : zéro ou plusieurs caractères (le plus flexible)
- **`?`** : exactement un caractère
- **`[abc]`** : un caractère parmi ceux listés
- **`[a-z]`** : plages de caractères
- **`[!abc]`** : négation (tout sauf)
- **`a|b|c`** : alternatives (OU logique)
- **`*)`** : cas par défaut (toujours en dernier)

**Terminateurs** :

- **`;;`** : sortie standard (break)
- **`;;&`** : continue avec test des patterns suivants
- **`;&`** : continue en exécutant directement le bloc suivant

**Principes clés** :

1. Toujours citer les variables : `"$var"`
2. Ordre spécifique → général
3. Toujours inclure un cas par défaut `*)`
4. Tester les cas limites
5. Documenter les patterns complexes

Les patterns Bash sont essentiels pour écrire des scripts robustes, maintenables et élégants. Maîtrisez-les pour améliorer considérablement la qualité de vos scripts shell ! 🚀