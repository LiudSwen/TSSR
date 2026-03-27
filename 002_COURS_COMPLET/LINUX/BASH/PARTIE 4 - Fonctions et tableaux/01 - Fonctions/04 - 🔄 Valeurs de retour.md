

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

En Bash, les fonctions disposent de deux mécanismes distincts pour communiquer avec le code appelant :

1. **Le code de retour** (`return`) : indique le statut d'exécution (succès/échec)
2. **La sortie standard** (`echo`) : permet de retourner des données

Cette dualité est fondamentale pour écrire des scripts robustes et maintenables.

> [!info] Pourquoi deux mécanismes ? Cette séparation permet de distinguer clairement le **statut** d'une opération de ses **résultats**. C'est une convention héritée du système Unix qui facilite la gestion d'erreurs et le chaînage de commandes.

---

## Le code de retour (`return`)

### Qu'est-ce qu'un code de retour ?

Le code de retour (ou "exit status") est un **entier entre 0 et 255** qui indique si une fonction s'est exécutée correctement ou non. C'est le mécanisme standard pour la gestion d'erreurs en Bash.

> [!example] Analogie Pensez au code de retour comme un feu tricolore : 🟢 vert (0) = tout va bien, 🔴 rouge (1-255) = problème détecté.

### Syntaxe de `return`

```bash
ma_fonction() {
    # Code de la fonction
    
    if [ condition_succès ]; then
        return 0  # Succès
    else
        return 1  # Échec
    fi
}
```

> [!warning] Limitation importante `return` n'accepte que des valeurs entre **0 et 255**. Toute valeur supérieure sera ramenée modulo 256.
> 
> Exemple : `return 256` équivaut à `return 0` !

### Convention des codes de retour

|Code|Signification|Utilisation|
|---|---|---|
|`0`|Succès|Opération réussie, tout s'est bien passé|
|`1`|Erreur générale|Échec non spécifique (le plus courant)|
|`2`|Mauvaise utilisation|Arguments incorrects, syntaxe invalide|
|`126`|Commande non exécutable|Problème de permissions|
|`127`|Commande introuvable|La commande n'existe pas|
|`128+n`|Signal fatal|Programme terminé par le signal n|
|`130`|Ctrl+C|Interruption par l'utilisateur (128+2)|

> [!tip] Codes personnalisés Vous pouvez utiliser les codes **1 à 125** pour définir vos propres erreurs spécifiques. Documentez-les clairement !

### Capture avec `$?`

La variable spéciale `$?` contient le code de retour de la **dernière commande exécutée**.

```bash
verifier_fichier() {
    if [ -f "$1" ]; then
        return 0  # Fichier existe
    else
        return 1  # Fichier n'existe pas
    fi
}

# Utilisation
verifier_fichier "/etc/passwd"

if [ $? -eq 0 ]; then
    echo "✅ Fichier trouvé"
else
    echo "❌ Fichier introuvable"
fi
```

> [!warning] Attention à l'ordre ! `$?` est écrasé après **chaque commande**. Capturez-le immédiatement si vous devez le réutiliser :
> 
> ```bash
> ma_fonction
> status=$?  # Sauvegarde immédiate
> echo "Debug..."  # Cette commande écraserait $?
> if [ $status -eq 0 ]; then
>     # Utilisation sûre
> fi
> ```

**Utilisation directe dans les conditions :**

```bash
# ✅ Recommandé : test direct sans $?
if verifier_fichier "/etc/passwd"; then
    echo "Fichier trouvé"
fi

# ⚠️ Fonctionnel mais verbeux
verifier_fichier "/etc/passwd"
if [ $? -eq 0 ]; then
    echo "Fichier trouvé"
fi
```

---

## Retourner des données avec `echo`

### Pourquoi utiliser `echo` ?

Le code de retour ne permet de transmettre qu'un nombre entre 0 et 255. Pour retourner des **chaînes de caractères, des calculs, ou des résultats complexes**, on utilise `echo` (ou `printf`) pour écrire sur la **sortie standard**.

> [!info] Principe fondamental En Bash, tout ce qu'une fonction écrit sur `stdout` peut être capturé par l'appelant. C'est comme un tuyau : la fonction envoie des données, et l'appelant les récupère.

### Syntaxe et utilisation

```bash
calculer_somme() {
    local a=$1
    local b=$2
    local resultat=$((a + b))
    
    echo "$resultat"  # Sortie sur stdout
    return 0          # Code de retour (optionnel ici)
}
```

**Différents types de retours :**

```bash
# Retour d'une chaîne simple
obtenir_nom() {
    echo "Alice"
}

# Retour d'un calcul
multiplier() {
    echo $(( $1 * $2 ))
}

# Retour de plusieurs lignes
lister_fichiers() {
    echo "fichier1.txt"
    echo "fichier2.txt"
    echo "fichier3.txt"
}

# Retour formaté
generer_json() {
    echo '{"nom": "Alice", "age": 30}'
}
```

> [!warning] Attention aux effets de bord **Tout** ce qui est écrit sur stdout est capturé, y compris les messages de debug !
> 
> ```bash
> mauvais_exemple() {
>     echo "Debug: calcul en cours..."  # ❌ Sera capturé !
>     echo $(( $1 + $2 ))
> }
> 
> bon_exemple() {
>     echo "Debug: calcul en cours..." >&2  # ✅ Envoyé sur stderr
>     echo $(( $1 + $2 ))
> }
> ```

### Capture avec substitution de commande

La **substitution de commande** permet de capturer la sortie d'une fonction dans une variable.

**Syntaxe moderne (`$(...)`) :**

```bash
# Capture simple
nom=$(obtenir_nom)
echo "Bonjour $nom"

# Capture avec arguments
resultat=$(calculer_somme 10 20)
echo "10 + 20 = $resultat"

# Capture multiligne dans un tableau
files=($(lister_fichiers))
for file in "${files[@]}"; do
    echo "- $file"
done
```

> [!tip] Préférez `$(...)` à `` `...` `` La syntaxe moderne `$(commande)` est :
> 
> - Plus lisible
> - Imbriquable facilement : `$(cmd1 $(cmd2))`
> - Moins sujette aux problèmes d'échappement

**Cas d'usage avancés :**

```bash
# Capture avec vérification du code de retour
if resultat=$(operation_risquee 2>/dev/null); then
    echo "Succès : $resultat"
else
    echo "Échec de l'opération"
fi

# Capture multiligne préservée
contenu=$(cat fichier.txt)  # Préserve les retours à la ligne
echo "$contenu"             # ⚠️ Guillemets obligatoires !

# Capture dans une boucle
while IFS= read -r ligne; do
    echo "Ligne : $ligne"
done < <(lister_fichiers)
```

---

## Comparaison : `return` vs `echo`

|Aspect|`return`|`echo`|
|---|---|---|
|**Type de données**|Entier (0-255)|Chaîne de caractères|
|**Usage**|Statut d'exécution|Données de retour|
|**Capture**|Via `$?`|Via substitution `$(...)`|
|**Visibilité**|Invisible pour l'utilisateur|Affiché ou capturé|
|**Convention**|0 = succès, autre = erreur|Pas de convention|
|**Limitation**|Une seule valeur numérique|Illimité (texte, lignes multiples)|

**Exemple combiné :**

```bash
diviser() {
    local numerateur=$1
    local denominateur=$2
    
    # Validation
    if [ "$denominateur" -eq 0 ]; then
        echo "Erreur : division par zéro" >&2
        return 1  # Code d'erreur
    fi
    
    # Calcul et retour du résultat
    echo $(( numerateur / denominateur ))
    return 0  # Succès
}

# Utilisation
if resultat=$(diviser 10 2); then
    echo "Résultat : $resultat"  # Affiche : Résultat : 5
else
    echo "La division a échoué"
fi
```

> [!example] Best Practice : Les deux en même temps La meilleure approche est souvent de **combiner les deux** :
> 
> - `return` pour indiquer le succès/échec
> - `echo` pour transmettre les données
> 
> Cela permet au code appelant de gérer proprement les erreurs tout en récupérant les résultats.

---

## Bonnes pratiques

### 1. Toujours retourner un code explicite

```bash
# ❌ Mauvais : pas de return explicite
ma_fonction() {
    echo "résultat"
    # return implicite = $? de la dernière commande (echo)
}

# ✅ Bon : code de retour explicite
ma_fonction() {
    echo "résultat"
    return 0  # Clair et intentionnel
}
```

### 2. Séparer sortie standard et sortie erreur

```bash
# ✅ Messages d'erreur sur stderr
traiter_fichier() {
    if [ ! -f "$1" ]; then
        echo "Erreur : fichier '$1' introuvable" >&2
        return 1
    fi
    
    echo "Contenu traité"
    return 0
}
```

### 3. Documenter les codes de retour personnalisés

```bash
# Codes de retour :
# 0 = succès
# 1 = fichier introuvable
# 2 = format invalide
# 3 = permissions insuffisantes

parser_config() {
    if [ ! -f "$1" ]; then
        return 1
    elif ! valider_format "$1"; then
        return 2
    elif [ ! -r "$1" ]; then
        return 3
    fi
    
    # Traitement...
    return 0
}
```

### 4. Vérifier les codes de retour critiques

```bash
# ❌ Ignore les erreurs
resultat=$(commande_critique)
echo "$resultat"

# ✅ Gère les erreurs
if resultat=$(commande_critique); then
    echo "$resultat"
else
    echo "Erreur lors de l'exécution" >&2
    exit 1
fi
```

---

## Pièges courants

### 1. Oublier que `$?` est volatile

```bash
# ❌ Bug : $? est écrasé
ma_fonction
echo "Debug..."  # Cette commande modifie $?
if [ $? -eq 0 ]; then  # Teste le code de echo, pas de ma_fonction !
    echo "Succès"
fi

# ✅ Solution : capturer immédiatement
ma_fonction
code=$?
echo "Debug..."
if [ $code -eq 0 ]; then
    echo "Succès"
fi
```

### 2. Mélanger stdout et stderr dans les captures

```bash
# ❌ Les erreurs polluent le résultat
resultat=$(commande_avec_erreurs)
echo "$resultat"  # Contient aussi les messages d'erreur !

# ✅ Rediriger stderr ailleurs
resultat=$(commande_avec_erreurs 2>/dev/null)
# ou
resultat=$(commande_avec_erreurs 2>&1)  # Capture aussi stderr si nécessaire
```

### 3. Oublier les guillemets lors de la capture

```bash
texte=$(cat fichier.txt)

# ❌ Perd les retours à la ligne et les espaces multiples
echo $texte

# ✅ Préserve le formatage
echo "$texte"
```

### 4. Utiliser `return` en dehors d'une fonction

```bash
# ❌ Erreur : return en dehors d'une fonction
if [ condition ]; then
    return 1  # Provoque une erreur !
fi

# ✅ Utiliser exit dans un script
if [ condition ]; then
    exit 1
fi
```

### 5. Confondre `return` et `exit`

```bash
# ⚠️ Attention à la différence
ma_fonction() {
    exit 1    # Termine TOUT le script
    # vs
    return 1  # Termine seulement la fonction
}
```

---

## Astuces avancées

### 1. Retour de structures complexes

```bash
# Retour de multiples valeurs séparées
obtenir_infos_user() {
    local nom="Alice"
    local age=30
    local ville="Paris"
    
    echo "$nom|$age|$ville"
}

# Utilisation avec IFS
IFS='|' read -r nom age ville < <(obtenir_infos_user)
echo "Nom: $nom, Âge: $age, Ville: $ville"
```

### 2. Gestion d'erreurs avancée avec trap

```bash
gerer_erreur() {
    local code=$?
    echo "Erreur détectée (code $code) à la ligne $1" >&2
    # Nettoyage...
    exit $code
}

trap 'gerer_erreur $LINENO' ERR

ma_fonction() {
    commande_risquee || return $?
    autre_commande || return $?
    return 0
}
```

### 3. Retour conditionnel

```bash
# Pattern utile pour les validateurs
valider_email() {
    [[ "$1" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]
    # return implicite = code de [[ ]]
}

# Utilisation élégante
if valider_email "user@example.com"; then
    echo "Email valide"
fi
```

### 4. Chaînage avec `&&` et `||`

```bash
# Enchaînement basé sur les codes de retour
fonction1() { return 0; }
fonction2() { return 0; }
fonction3() { return 1; }

# Exécute tant que les fonctions réussissent
fonction1 && fonction2 && fonction3 && echo "Tout OK"

# Exécute jusqu'à ce qu'une fonction réussisse
fonction3 || fonction2 || echo "Aucune n'a réussi"
```

### 5. Pattern pour valeurs par défaut

```bash
obtenir_config() {
    local fichier="/etc/app.conf"
    
    if [ -f "$fichier" ]; then
        cat "$fichier"
        return 0
    else
        echo "default_config"  # Valeur par défaut
        return 1              # Indique que c'est un fallback
    fi
}

# Utilisation
config=$(obtenir_config)
if [ $? -ne 0 ]; then
    echo "Utilisation de la configuration par défaut" >&2
fi
```

### 6. Retour de tableaux (via chaîne)

```bash
obtenir_liste() {
    # Retour d'éléments séparés par des espaces
    echo "element1 element2 element3"
}

# Capture dans un tableau
liste=($(obtenir_liste))

for item in "${liste[@]}"; do
    echo "- $item"
done
```

---

> [!tip] Résumé des concepts clés
> 
> - **`return`** : statut d'exécution (0 = succès, 1-255 = erreur)
> - **`$?`** : capture le code de retour de la dernière commande
> - **`echo`** : retourne des données via stdout
> - **`$()`** : capture la sortie d'une fonction
> - **Combiner les deux** : `return` pour le statut, `echo` pour les données
> - **Stderr** : `>&2` pour les messages d'erreur

---

_Ce cours couvre les mécanismes de retour de valeur en Bash. La maîtrise de ces concepts est essentielle pour écrire des fonctions robustes et maintenables._