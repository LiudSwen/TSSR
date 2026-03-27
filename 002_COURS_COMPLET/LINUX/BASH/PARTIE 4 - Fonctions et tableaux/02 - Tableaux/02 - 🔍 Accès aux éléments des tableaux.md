

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

L'accès aux éléments d'un tableau en Bash est une opération fondamentale qui permet de manipuler et d'exploiter les données stockées dans des structures de type array. Contrairement à d'autres langages, Bash utilise une syntaxe particulière avec des accolades `{}` et le symbole dollar `$` pour accéder aux éléments.

> [!info] Pourquoi c'est important Maîtriser l'accès aux tableaux est essentiel pour :
> 
> - Traiter des listes de fichiers ou de données
> - Itérer sur des collections d'éléments
> - Manipuler les arguments de scripts
> - Gérer des configurations complexes

---

## 🔢 Accès par index

### Syntaxe de base

```bash
# Déclaration d'un tableau
fruits=("pomme" "banane" "orange" "kiwi" "mangue")

# Accès à un élément spécifique
echo "${fruits[0]}"  # Affiche : pomme
echo "${fruits[2]}"  # Affiche : orange
echo "${fruits[4]}"  # Affiche : mangue
```

### Explication détaillée

La syntaxe `${array[index]}` est composée de plusieurs parties :

- `$` : Indique qu'on veut la valeur de la variable
- `{}` : Les accolades sont **obligatoires** pour l'accès aux tableaux
- `array` : Le nom du tableau
- `[index]` : L'index de l'élément (commence à 0)

> [!warning] Accolades obligatoires Sans les accolades, Bash interprétera incorrectement l'expression :
> 
> ```bash
> echo $fruits[0]  # ❌ Affiche le premier élément suivi de "[0]"
> echo ${fruits[0]} # ✅ Affiche correctement le premier élément
> ```

### Utilisation pratique

```bash
# Exemple avec des chemins de fichiers
configs=("/etc/nginx/nginx.conf" "/etc/apache2/apache2.conf" "/etc/ssh/sshd_config")

# Vérifier si le premier fichier existe
if [[ -f "${configs[0]}" ]]; then
    echo "Le fichier ${configs[0]} existe"
fi

# Utiliser un index dans une variable
index=1
echo "Configuration à vérifier : ${configs[$index]}"
```

> [!tip] Astuce Vous pouvez utiliser des variables comme indices :
> 
> ```bash
> i=2
> echo "${fruits[$i]}"  # Affiche l'élément à l'index 2
> ```

---

## 🥇 Premier élément (index 0)

### Syntaxe

```bash
array=("premier" "deuxième" "troisième")

# Accès au premier élément
premier="${array[0]}"
echo "$premier"  # Affiche : premier
```

### Pourquoi l'index 0 ?

Bash utilise l'indexation à partir de zéro, comme la plupart des langages de programmation. Le premier élément se trouve donc à l'index 0, le deuxième à l'index 1, etc.

|Position|Index|Valeur|
|---|---|---|
|1er|0|premier|
|2ème|1|deuxième|
|3ème|2|troisième|

### Cas d'usage courants

```bash
# Récupérer le premier argument après le nom du script
args=("$@")
commande="${args[0]}"

# Premier élément d'une liste de serveurs
serveurs=("prod-01" "prod-02" "prod-03")
serveur_principal="${serveurs[0]}"
echo "Serveur principal : $serveur_principal"

# Vérification si le tableau n'est pas vide
if [[ -n "${array[0]}" ]]; then
    echo "Le tableau contient au moins un élément"
fi
```

> [!example] Exemple pratique
> 
> ```bash
> # Script de déploiement
> environnements=("dev" "staging" "production")
> env_par_defaut="${environnements[0]}"
> 
> echo "Déploiement sur l'environnement : ${1:-$env_par_defaut}"
> ```

---

## 🎯 Dernier élément (index -1)

### Syntaxe

```bash
array=("un" "deux" "trois" "quatre" "cinq")

# Accès au dernier élément (Bash 4.3+)
dernier="${array[-1]}"
echo "$dernier"  # Affiche : cinq

# Avant-dernier
avant_dernier="${array[-2]}"
echo "$avant_dernier"  # Affiche : quatre
```

> [!info] Compatibilité L'indexation négative est disponible à partir de **Bash 4.3**. Pour les versions antérieures, utilisez cette méthode alternative :
> 
> ```bash
> # Méthode compatible avec toutes les versions
> dernier="${array[${#array[@]}-1]}"
> ```

### Comment ça fonctionne ?

Les indices négatifs comptent à partir de la fin du tableau :

- `-1` : dernier élément
- `-2` : avant-dernier élément
- `-3` : antépénultième élément, etc.

|Index positif|Index négatif|Valeur|
|---|---|---|
|0|-5|un|
|1|-4|deux|
|2|-3|trois|
|3|-2|quatre|
|4|-1|cinq|

### Cas d'usage pratiques

```bash
# Récupérer le dernier fichier d'une liste triée
fichiers=($(ls -t *.log))
dernier_log="${fichiers[-1]}"
echo "Dernier fichier de log : $dernier_log"

# Traiter le dernier argument d'une commande
arguments=("$@")
dernier_arg="${arguments[-1]}"

# Vérifier le dernier statut dans un historique
statuts=("pending" "running" "completed")
statut_actuel="${statuts[-1]}"
```

> [!warning] Attention avec les tableaux vides Accéder à l'index -1 d'un tableau vide ne produit pas d'erreur mais retourne une chaîne vide :
> 
> ```bash
> vide=()
> echo "${vide[-1]}"  # N'affiche rien (chaîne vide)
> ```

---

## 📦 Tous les éléments (@)

### Syntaxe

```bash
array=("pomme" "banane" "orange")

# Accès à tous les éléments avec @
echo "${array[@]}"  # Affiche : pomme banane orange

# Utilisation dans une boucle
for fruit in "${array[@]}"; do
    echo "Fruit : $fruit"
done
```

### Comportement avec les guillemets

Le `@` a un comportement spécial lorsqu'il est entouré de guillemets doubles : **chaque élément est traité comme un argument séparé**.

```bash
array=("fichier avec espaces.txt" "autre fichier.doc" "script.sh")

# Avec guillemets : chaque élément est préservé
for item in "${array[@]}"; do
    echo "Item : [$item]"
done
# Affiche :
# Item : [fichier avec espaces.txt]
# Item : [autre fichier.doc]
# Item : [script.sh]
```

### Cas d'usage courants

```bash
# Passer tous les éléments comme arguments à une commande
fichiers=("file1.txt" "file2.txt" "file3.txt")
cat "${fichiers[@]}"

# Copier un tableau
original=("a" "b" "c")
copie=("${original[@]}")

# Ajouter des éléments à un tableau
nouveau_tableau=("${array[@]}" "nouvel_element")

# Compter le nombre d'éléments
nombre="${#array[@]}"
echo "Le tableau contient $nombre éléments"
```

> [!tip] Astuce pour le débogage Pour voir comment les éléments sont interprétés, utilisez `printf` :
> 
> ```bash
> array=("un" "deux trois" "quatre")
> printf "Argument %s\n" "${array[@]}"
> # Affiche :
> # Argument un
> # Argument deux trois
> # Argument quatre
> ```

### Expansion avec préfixe/suffixe

```bash
extensions=("txt" "md" "log")

# Ajouter un préfixe à tous les éléments
echo "${extensions[@]/#/file.}"
# Affiche : file.txt file.md file.log

# Transformer tous les éléments
fichiers=("rapport" "données" "config")
echo "${fichiers[@]/%/.txt}"
# Affiche : rapport.txt données.txt config.txt
```

---

## 🔸 Tous les éléments (*)

### Syntaxe

```bash
array=("pomme" "banane" "orange")

# Accès à tous les éléments avec *
echo "${array[*]}"  # Affiche : pomme banane orange
```

### Comportement avec les guillemets

Contrairement à `@`, l'astérisque `*` avec des guillemets doubles **concatène tous les éléments en une seule chaîne**, séparés par le premier caractère de la variable `IFS` (Internal Field Separator, par défaut un espace).

```bash
array=("fichier avec espaces.txt" "autre fichier.doc" "script.sh")

# Avec guillemets : tous les éléments sont fusionnés
for item in "${array[*]}"; do
    echo "Item : [$item]"
done
# Affiche :
# Item : [fichier avec espaces.txt autre fichier.doc script.sh]
```

### Utilisation avec IFS personnalisé

```bash
# Joindre les éléments avec un séparateur personnalisé
fruits=("pomme" "banane" "orange")

# Séparateur virgule
IFS=','
echo "${fruits[*]}"  # Affiche : pomme,banane,orange

# Restaurer IFS
IFS=' '

# Ou en une ligne
(IFS=','; echo "${fruits[*]}")  # N'affecte pas le shell parent
```

### Cas d'usage pratiques

```bash
# Créer une chaîne CSV
colonnes=("nom" "prénom" "âge" "ville")
entete=$(IFS=','; echo "${colonnes[*]}")
echo "$entete"  # Affiche : nom,prénom,âge,ville

# Construire une commande SQL
champs=("id" "name" "email" "created_at")
select_clause="SELECT $(IFS=', '; echo "${champs[*]}") FROM users"

# Logger tous les arguments en une seule ligne
log_message="Exécution avec paramètres : ${array[*]}"
```

> [!warning] Attention aux espaces dans les éléments Avec `*`, les espaces dans les éléments individuels sont perdus lors de la concaténation :
> 
> ```bash
> array=("un deux" "trois quatre")
> echo "${array[*]}"  # Affiche : un deux trois quatre
> # Impossible de distinguer où sont les limites des éléments originaux
> ```

---

## ⚖️ Différence entre @ et *

### Comparaison synthétique

|Aspect|`"${array[@]}"`|`"${array[*]}"`|
|---|---|---|
|**Avec guillemets**|Chaque élément = argument séparé|Tous les éléments = une seule chaîne|
|**Préserve les espaces**|✅ Oui|❌ Non|
|**Utilisation en boucle**|✅ Recommandé|⚠️ Rarement approprié|
|**Comme arguments**|✅ Idéal|❌ Problématique|
|**Concaténation**|❌ Non|✅ Oui (avec IFS)|

### Démonstration pratique

```bash
# Tableau de test avec espaces
files=("mon fichier.txt" "autre document.pdf" "script shell.sh")

echo "=== Test avec @ ==="
for file in "${files[@]}"; do
    echo "Fichier : [$file]"
done
# Résultat :
# Fichier : [mon fichier.txt]
# Fichier : [autre document.pdf]
# Fichier : [script shell.sh]

echo "=== Test avec * ==="
for file in "${files[*]}"; do
    echo "Fichier : [$file]"
done
# Résultat :
# Fichier : [mon fichier.txt autre document.pdf script shell.sh]
```

### Sans guillemets (à éviter)

```bash
array=("un deux" "trois" "quatre")

# Sans guillemets, @ et * se comportent de la même façon
for item in ${array[@]}; do echo "[$item]"; done
# Affiche :
# [un]
# [deux]
# [trois]
# [quatre]

for item in ${array[*]}; do echo "[$item]"; done
# Même résultat (word splitting appliqué)
```

> [!warning] Toujours utiliser les guillemets ! Sans guillemets, les espaces dans les éléments causent un word splitting indésirable. **Utilisez toujours les guillemets doubles.**

### Quand utiliser quoi ?

```bash
# ✅ Utiliser @ pour les boucles et les arguments
for element in "${array[@]}"; do
    process "$element"
done

commande "${array[@]}"  # Passe chaque élément comme argument

# ✅ Utiliser * pour créer des chaînes jointes
liste=$(IFS=', '; echo "${array[*]}")
echo "Éléments : $liste"

# ✅ Utiliser @ pour copier des tableaux
nouveau=("${ancien[@]}")
```

---

## ⚠️ Pièges courants

### 1. Oublier les accolades

```bash
array=("a" "b" "c")

# ❌ Incorrect
echo $array[0]     # Affiche : a[0]
echo $array[@]     # Affiche : a[@]

# ✅ Correct
echo "${array[0]}" # Affiche : a
echo "${array[@]}" # Affiche : a b c
```

### 2. Oublier les guillemets avec @

```bash
files=("fichier un.txt" "fichier deux.txt")

# ❌ Incorrect : word splitting
for f in ${files[@]}; do
    echo "$f"
done
# Affiche :
# fichier
# un.txt
# fichier
# deux.txt

# ✅ Correct : préserve les espaces
for f in "${files[@]}"; do
    echo "$f"
done
# Affiche :
# fichier un.txt
# fichier deux.txt
```

### 3. Confondre @ et * dans les boucles

```bash
array=("un deux" "trois")

# ❌ Incorrect : ne crée qu'une seule itération
for item in "${array[*]}"; do
    echo "[$item]"
done
# Affiche :
# [un deux trois]

# ✅ Correct : une itération par élément
for item in "${array[@]}"; do
    echo "[$item]"
done
# Affiche :
# [un deux]
# [trois]
```

### 4. Accéder à un index inexistant

```bash
array=("a" "b" "c")

# Pas d'erreur, mais retourne une chaîne vide
echo "${array[10]}"  # N'affiche rien

# Vérification recommandée
if [[ -n "${array[10]}" ]]; then
    echo "L'élément existe"
else
    echo "L'élément n'existe pas"
fi
```

### 5. Modification lors de l'itération

```bash
array=("a" "b" "c")

# ❌ Incorrect : modifie une copie
for item in "${array[@]}"; do
    item="X"  # Ne modifie PAS le tableau
done
echo "${array[@]}"  # Affiche : a b c

# ✅ Correct : utiliser les indices
for i in "${!array[@]}"; do
    array[$i]="X"  # Modifie le tableau
done
echo "${array[@]}"  # Affiche : X X X
```

### 6. Confusion avec les tableaux associatifs

```bash
# Tableau indexé
declare -a indexed=("a" "b" "c")
echo "${indexed[0]}"  # Fonctionne

# Tableau associatif (nécessite -A)
declare -A associative=([key1]="value1" [key2]="value2")
echo "${associative[key1]}"  # Fonctionne
echo "${associative[0]}"      # Ne fonctionne PAS (pas d'index numérique)
```

---

## ✅ Bonnes pratiques

### 1. Toujours utiliser les accolades et les guillemets

```bash
# ✅ Bonne pratique
echo "${array[0]}"
for item in "${array[@]}"; do
    process "$item"
done
```

### 2. Vérifier l'existence avant l'accès

```bash
# Vérifier si le tableau a des éléments
if [[ ${#array[@]} -gt 0 ]]; then
    echo "Premier élément : ${array[0]}"
fi

# Vérifier un index spécifique
index=5
if [[ -n "${array[$index]}" ]]; then
    echo "L'élément $index existe : ${array[$index]}"
fi
```

### 3. Utiliser des noms de variables explicites

```bash
# ❌ Peu clair
a=("x" "y" "z")

# ✅ Explicite
serveurs_production=("srv-01" "srv-02" "srv-03")
fichiers_config=("/etc/app/config.yml" "/etc/app/database.yml")
```

### 4. Documenter les tableaux complexes

```bash
# Liste des environnements de déploiement (ordre : dev, staging, prod)
environnements=("development" "staging" "production")

# Correspondance entre environnements et URLs
declare -A urls=(
    [development]="https://dev.example.com"
    [staging]="https://staging.example.com"
    [production]="https://example.com"
)
```

### 5. Utiliser @ par défaut dans les boucles

```bash
# ✅ Recommandé : @ préserve l'intégrité des éléments
for fichier in "${fichiers[@]}"; do
    [[ -f "$fichier" ]] && cat "$fichier"
done

# ⚠️ Utiliser * seulement pour la concaténation
log_entry="$(date) - Fichiers traités : ${fichiers[*]}"
```

### 6. Éviter les variables globales pour les indices

```bash
# ❌ À éviter : variable globale
i=0
echo "${array[$i]}"

# ✅ Préférer : variable locale dans une fonction
function get_first_element() {
    local arr=("$@")
    echo "${arr[0]}"
}
```

### 7. Utiliser des fonctions pour les opérations complexes

```bash
# Fonction pour obtenir le dernier élément (compatible toutes versions)
function get_last_element() {
    local arr=("$@")
    local last_index=$((${#arr[@]} - 1))
    echo "${arr[$last_index]}"
}

# Utilisation
fruits=("pomme" "banane" "orange")
dernier=$(get_last_element "${fruits[@]}")
echo "$dernier"  # Affiche : orange
```

### 8. Préférer les indices nommés pour les tableaux associatifs

```bash
# Pour les données structurées, utilisez des tableaux associatifs
declare -A utilisateur=(
    [nom]="Dupont"
    [prenom]="Jean"
    [email]="jean.dupont@example.com"
)

echo "Email : ${utilisateur[email]}"
```

---

> [!tip] Résumé rapide
> 
> - **Index numérique** : `${array[0]}`, `${array[2]}`, `${array[-1]}`
> - **Tous les éléments** : Toujours utiliser `"${array[@]}"` dans les boucles
> - **Concaténation** : Utiliser `"${array[*]}"` avec IFS personnalisé
> - **Règle d'or** : Toujours utiliser accolades `{}` et guillemets `""`