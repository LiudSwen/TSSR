

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

## 🎯 Introduction

Les propriétés des tableaux permettent d'obtenir des métadonnées sur leur structure et leur contenu. Ces opérations sont essentielles pour manipuler dynamiquement des tableaux sans connaître leur taille à l'avance, valider leur contenu, ou itérer de manière sécurisée.

> [!info] Pourquoi c'est important Connaître les propriétés d'un tableau vous permet d'écrire du code robuste et adaptable, capable de gérer des données de taille variable sans erreurs d'accès ou de dépassement.

---

## 📏 Longueur du tableau

### Syntaxe de base

```bash
${#nom_tableau[@]}
```

Cette syntaxe retourne le **nombre total d'éléments** présents dans le tableau.

### Pourquoi l'utiliser ?

- Vérifier si un tableau est vide avant de le traiter
- Boucler sur tous les éléments sans connaître la taille à l'avance
- Valider des entrées utilisateur ou des résultats de commandes
- Calculer des statistiques ou des moyennes

### Exemples pratiques

```bash
# Déclaration d'un tableau
fruits=("pomme" "banane" "orange" "kiwi")

# Obtenir la longueur
echo "Nombre de fruits : ${#fruits[@]}"  # Affiche : 4

# Utilisation dans une condition
if [ ${#fruits[@]} -gt 0 ]; then
    echo "Le panier contient des fruits"
else
    echo "Le panier est vide"
fi

# Utilisation dans une boucle
for ((i=0; i<${#fruits[@]}; i++)); do
    echo "Fruit $((i+1)): ${fruits[$i]}"
done
```

> [!example] Cas d'usage réel : Vérification de paramètres
> 
> ```bash
> # Script acceptant plusieurs fichiers en argument
> fichiers=("$@")
> 
> if [ ${#fichiers[@]} -eq 0 ]; then
>     echo "Erreur : Aucun fichier spécifié"
>     exit 1
> fi
> 
> echo "Traitement de ${#fichiers[@]} fichier(s)..."
> ```

### Différence entre @ et *

```bash
tableau=("a" "b" "c")

# Les deux donnent le même résultat pour la longueur
echo ${#tableau[@]}  # 3
echo ${#tableau[*]}  # 3
```

> [!tip] Bonne pratique Utilisez toujours `[@]` plutôt que `[*]` par cohérence et pour éviter des comportements inattendus lors du passage de tableaux en paramètres de fonctions.

---

## 🔤 Longueur d'un élément

### Syntaxe de base

```bash
${#nom_tableau[indice]}
```

Cette syntaxe retourne le **nombre de caractères** de l'élément situé à l'indice spécifié.

### Pourquoi l'utiliser ?

- Valider la longueur minimale/maximale d'une chaîne
- Formatter des sorties avec alignement
- Filtrer des éléments selon leur taille
- Trouver l'élément le plus long ou le plus court

### Exemples pratiques

```bash
# Tableau de noms
noms=("Alice" "Bob" "Christopher" "Dan")

# Longueur de chaque nom
echo "Longueur du 1er nom : ${#noms[0]}"  # 5
echo "Longueur du 3e nom : ${#noms[2]}"  # 11

# Validation de longueur
if [ ${#noms[1]} -lt 3 ]; then
    echo "${noms[1]} est trop court"
fi

# Formatage avec alignement
for nom in "${noms[@]}"; do
    printf "%-15s (longueur: %d)\n" "$nom" ${#nom}
done
```

> [!example] Cas d'usage réel : Validation de mots de passe
> 
> ```bash
> mots_de_passe=("abc" "Secure123!" "test")
> 
> for i in "${!mots_de_passe[@]}"; do
>     mdp="${mots_de_passe[$i]}"
>     longueur=${#mdp}
>     
>     if [ $longueur -lt 8 ]; then
>         echo "Mot de passe $((i+1)) : INVALIDE (trop court : $longueur caractères)"
>     else
>         echo "Mot de passe $((i+1)) : VALIDE ($longueur caractères)"
>     fi
> done
> ```

### Comparaison avec les variables simples

```bash
# Pour une variable simple
texte="Bonjour"
echo ${#texte}  # 7

# Pour un élément de tableau
tableau=("Bonjour" "monde")
echo ${#tableau[0]}  # 7
echo ${#tableau[1]}  # 5
```

> [!warning] Attention aux indices non existants Si vous demandez la longueur d'un indice qui n'existe pas, vous obtiendrez 0, ce qui peut prêter à confusion.
> 
> ```bash
> arr=("test")
> echo ${#arr[5]}  # Affiche 0 (pas d'erreur !)
> ```

---

## 🔢 Indices utilisés

### Syntaxe de base

```bash
${!nom_tableau[@]}
```

Cette syntaxe retourne la **liste de tous les indices** qui contiennent effectivement des valeurs dans le tableau.

### Pourquoi l'utiliser ?

- Itérer sur des tableaux avec des indices non consécutifs (sparse arrays)
- Vérifier quels indices sont définis
- Détecter des trous dans un tableau
- Accéder aux clés d'un tableau associatif (mentionné mais non développé ici)

### Exemples pratiques

```bash
# Tableau avec indices consécutifs
fruits=("pomme" "banane" "orange")
echo "${!fruits[@]}"  # Affiche : 0 1 2

# Tableau avec indices non consécutifs (sparse array)
couleurs=()
couleurs[0]="rouge"
couleurs[3]="vert"
couleurs[7]="bleu"

echo "${!couleurs[@]}"  # Affiche : 0 3 7

# Itération sur les indices réels
for indice in ${!couleurs[@]}; do
    echo "Index $indice : ${couleurs[$indice]}"
done
```

> [!example] Cas d'usage réel : Détection de trous dans un tableau
> 
> ```bash
> # Tableau après suppressions
> data=("A" "B" "C" "D")
> unset data[1]  # Supprime l'élément à l'indice 1
> unset data[3]  # Supprime l'élément à l'indice 3
> 
> echo "Longueur du tableau : ${#data[@]}"      # 2
> echo "Indices présents : ${!data[@]}"         # 0 2
> 
> # Vérification de la continuité
> indices=(${!data[@]})
> for ((i=0; i<${#indices[@]}-1; i++)); do
>     if [ $((indices[i+1] - indices[i])) -ne 1 ]; then
>         echo "Trou détecté entre ${indices[$i]} et ${indices[i+1]}"
>     fi
> done
> ```

### Différence avec une itération classique

```bash
# Tableau sparse
arr=()
arr[0]="A"
arr[5]="B"

# Itération par indice (DANGEREUSE si sparse)
for ((i=0; i<${#arr[@]}; i++)); do
    echo "${arr[$i]}"  # Affiche seulement A et B, mais saute les indices
done

# Itération correcte sur les indices réels
for i in ${!arr[@]}; do
    echo "Index $i : ${arr[$i]}"  # Affiche "Index 0 : A" puis "Index 5 : B"
done
```

> [!tip] Bonne pratique pour l'itération Utilisez `${!tableau[@]}` pour itérer sur les indices plutôt qu'une boucle `for ((i=0; i<longueur; i++))` si votre tableau peut avoir des indices non consécutifs.

---

## 🚀 Cas d'usage avancés

### Combinaison des propriétés

```bash
# Script d'analyse de tableau
analyser_tableau() {
    local -n ref=$1  # Référence au tableau
    
    echo "=== Analyse du tableau ==="
    echo "Nombre d'éléments : ${#ref[@]}"
    echo "Indices utilisés : ${!ref[@]}"
    
    # Trouver l'élément le plus long
    local max_len=0
    local element_max=""
    
    for i in ${!ref[@]}; do
        local len=${#ref[$i]}
        if [ $len -gt $max_len ]; then
            max_len=$len
            element_max="${ref[$i]}"
        fi
    done
    
    echo "Élément le plus long : '$element_max' ($max_len caractères)"
}

# Utilisation
mots=("chat" "éléphant" "oiseau" "papillon")
analyser_tableau mots
```

### Validation de données

```bash
# Validation d'un tableau de noms d'utilisateurs
valider_usernames() {
    local usernames=("$@")
    local valides=0
    local invalides=0
    
    for i in ${!usernames[@]}; do
        local user="${usernames[$i]}"
        local len=${#user}
        
        if [ $len -ge 3 ] && [ $len -le 16 ]; then
            echo "✓ $user (valide)"
            ((valides++))
        else
            echo "✗ $user (invalide : $len caractères)"
            ((invalides++))
        fi
    done
    
    echo ""
    echo "Résumé : $valides valides, $invalides invalides sur ${#usernames[@]} total"
}

# Test
valider_usernames "ab" "john" "christopher_longname" "alice"
```

### Construction de rapports

```bash
# Génération d'un rapport statistique
generer_rapport() {
    local data=("$@")
    
    # Statistiques de base
    local total=${#data[@]}
    local indices="${!data[@]}"
    
    # Calcul longueur moyenne
    local somme=0
    for elem in "${data[@]}"; do
        somme=$((somme + ${#elem}))
    done
    local moyenne=$((somme / total))
    
    # Affichage
    echo "╔════════════════════════════╗"
    echo "║   RAPPORT D'ANALYSE        ║"
    echo "╚════════════════════════════╝"
    echo "Éléments totaux    : $total"
    echo "Indices utilisés   : $indices"
    echo "Longueur moyenne   : $moyenne caractères"
    echo ""
    echo "Détails :"
    for i in ${!data[@]}; do
        printf "  [%2d] %-20s (%2d car.)\n" $i "${data[$i]}" ${#data[$i]}
    done
}

# Exemple
langages=("Python" "JavaScript" "Bash" "Go" "Rust")
generer_rapport "${langages[@]}"
```

---

## ⚠️ Pièges courants

### 1. Confusion entre longueur de tableau et longueur d'élément

```bash
tableau=("test")

# Longueur du tableau (nombre d'éléments)
echo ${#tableau[@]}      # 1

# Longueur du premier élément (nombre de caractères)
echo ${#tableau[0]}      # 4

# ERREUR COURANTE : oublier l'indice
echo ${#tableau}         # 4 (traite comme ${#tableau[0]})
```

> [!warning] Attention au comportement par défaut Sans `[@]`, Bash traite `${#tableau}` comme `${#tableau[0]}`, ce qui peut créer de la confusion.

### 2. Tableaux vides vs non définis

```bash
# Tableau vide explicite
vide=()
echo ${#vide[@]}         # 0

# Tableau non déclaré
echo ${#inexistant[@]}   # 0 (même résultat !)

# Test robuste
if [ -v vide ]; then
    echo "Le tableau 'vide' existe (même s'il est vide)"
fi

if [ -v inexistant ]; then
    echo "Ce message ne s'affichera pas"
fi
```

### 3. Indices avec espaces ou caractères spéciaux

```bash
# Toujours utiliser des guillemets !
tableau=("un deux" "trois" "quatre cinq")

# MAUVAIS : les espaces posent problème
for i in ${!tableau[@]}; do
    echo ${tableau[$i]}  # Peut causer des problèmes
done

# BON : avec guillemets
for i in ${!tableau[@]}; do
    echo "${tableau[$i]}"  # Sécurisé
done
```

### 4. Modification de tableau pendant l'itération

```bash
# DANGEREUX
fruits=("pomme" "banane" "orange")

for i in ${!fruits[@]}; do
    if [ "${fruits[$i]}" = "banane" ]; then
        unset fruits[$i]  # Modifie le tableau pendant l'itération
    fi
done

# MEILLEUR : créer un nouveau tableau
nouveau=()
for elem in "${fruits[@]}"; do
    if [ "$elem" != "banane" ]; then
        nouveau+=("$elem")
    fi
done
fruits=("${nouveau[@]}")
```

> [!tip] Règle d'or Évitez de modifier un tableau (ajout/suppression) pendant que vous itérez dessus. Créez plutôt un nouveau tableau avec les modifications souhaitées.

### 5. Comparaison de longueurs sans conversion

```bash
arr=("a" "b" "c")

# ATTENTION : comparaison de chaînes, pas de nombres
if [ "${#arr[@]}" -gt "1" ]; then  # Correct avec -gt (test numérique)
    echo "Plus d'un élément"
fi

# ERREUR : utiliser > (comparaison lexicographique)
# Ne PAS utiliser les opérateurs de chaînes pour les nombres
```

---

## 💡 Bonnes pratiques récapitulatives

|Pratique|À faire ✓|À éviter ✗|
|---|---|---|
|**Longueur de tableau**|`${#arr[@]}`|`${#arr}` (ambigu)|
|**Itération**|`for i in ${!arr[@]}`|`for ((i=0; i<${#arr[@]}; i++))` sur sparse arrays|
|**Guillemets**|`"${arr[$i]}"`|`${arr[$i]}` (sans guillemets)|
|**Test d'existence**|`[ -v arr ]`|Comparer à zéro uniquement|
|**Modification**|Créer nouveau tableau|Modifier pendant itération|

> [!tip] Astuce professionnelle Créez des fonctions utilitaires pour encapsuler ces opérations courantes et les réutiliser dans vos scripts :
> 
> ```bash
> est_vide() { [ ${#1[@]} -eq 0 ]; }
> taille() { echo ${#1[@]}; }
> longueur_elem() { echo ${#1[$2]}; }
> ```

---

_Les propriétés des tableaux sont des outils puissants pour écrire du code Bash robuste et maintenable. Maîtriser ces concepts vous permettra de manipuler des données complexes avec confiance._