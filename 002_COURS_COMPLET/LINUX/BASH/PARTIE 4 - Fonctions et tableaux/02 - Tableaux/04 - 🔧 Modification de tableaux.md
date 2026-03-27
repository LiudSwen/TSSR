

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

La modification de tableaux en Bash est une opération courante lors de la manipulation dynamique de données. Contrairement à certains langages, Bash offre une flexibilité particulière : les tableaux peuvent être modifiés à tout moment, et les indices ne doivent pas nécessairement être contigus.

> [!info] Pourquoi modifier des tableaux ?
> 
> - **Accumulation de résultats** : collecter progressivement des données dans une boucle
> - **Mise à jour dynamique** : modifier des valeurs existantes selon des conditions
> - **Gestion de collections** : ajouter ou supprimer des éléments selon les besoins
> - **Traitement de fichiers** : construire des listes de fichiers ou de chemins

---

## ➕ Ajout d'éléments

### Syntaxe de base

L'opérateur `+=` permet d'ajouter un ou plusieurs éléments à la fin d'un tableau existant.

```bash
# Ajout d'un seul élément
fruits=("pomme" "banane")
fruits+=("orange")
echo "${fruits[@]}"  # pomme banane orange

# Ajout de plusieurs éléments d'un coup
fruits+=("kiwi" "mangue" "ananas")
echo "${fruits[@]}"  # pomme banane orange kiwi mangue ananas
```

### Cas particuliers

```bash
# Ajout avec un tableau vide initial
legumes=()
legumes+=("carotte")
legumes+=("tomate" "poivron")
echo "${legumes[@]}"  # carotte tomate poivron

# Ajout à un indice spécifique (remplit les indices intermédiaires)
nombres=(1 2 3)
nombres[10]="onze"
echo "${nombres[@]}"      # 1 2 3 onze
echo "${#nombres[@]}"     # 4 éléments (indices 0, 1, 2, 10)
echo "${!nombres[@]}"     # 0 1 2 10 (liste des indices)
```

> [!example] Exemple pratique : collecter des fichiers
> 
> ```bash
> # Rechercher tous les fichiers .txt et .log
> fichiers=()
> for fichier in *.txt; do
>     [[ -f "$fichier" ]] && fichiers+=("$fichier")
> done
> for fichier in *.log; do
>     [[ -f "$fichier" ]] && fichiers+=("$fichier")
> done
> 
> echo "Fichiers trouvés : ${#fichiers[@]}"
> printf '%s\n' "${fichiers[@]}"
> ```

### Ajout par concaténation

```bash
# Fusionner deux tableaux
array1=("a" "b" "c")
array2=("d" "e" "f")
array_complet=("${array1[@]}" "${array2[@]}")
echo "${array_complet[@]}"  # a b c d e f

# Alternative avec +=
array1+=("${array2[@]}")
echo "${array1[@]}"  # a b c d e f
```

> [!tip] Astuce : ajout conditionnel
> 
> ```bash
> # Ajouter uniquement si la valeur n'existe pas déjà
> valeurs=("alpha" "beta" "gamma")
> nouvelle="beta"
> 
> if [[ ! " ${valeurs[@]} " =~ " ${nouvelle} " ]]; then
>     valeurs+=("$nouvelle")
>     echo "Ajouté"
> else
>     echo "Déjà présent"
> fi
> ```

---

## ✏️ Modification d'éléments

### Modification par indice

La modification d'un élément existant se fait en assignant directement une nouvelle valeur à un indice spécifique.

```bash
# Modification simple
animaux=("chat" "chien" "oiseau")
animaux[1]="lapin"
echo "${animaux[@]}"  # chat lapin oiseau

# Modification du premier élément
animaux[0]="souris"
echo "${animaux[@]}"  # souris lapin oiseau

# Modification du dernier élément
animaux[-1]="poisson"
echo "${animaux[@]}"  # souris lapin poisson
```

> [!warning] Attention aux indices négatifs Les indices négatifs (comme `-1` pour le dernier élément) sont supportés à partir de Bash 4.3. Sur des versions antérieures, utilisez plutôt :
> 
> ```bash
> # Méthode compatible toutes versions
> dernier_index=$((${#animaux[@]} - 1))
> animaux[$dernier_index]="nouvelle_valeur"
> ```

### Modification conditionnelle

```bash
# Modifier tous les éléments qui correspondent à un critère
scores=(10 25 30 15 40)

for i in "${!scores[@]}"; do
    if (( scores[i] < 20 )); then
        scores[i]=0
    fi
done

echo "${scores[@]}"  # 0 25 30 0 40
```

### Modification avec transformation

```bash
# Convertir tous les éléments en majuscules
noms=("alice" "bob" "charlie")

for i in "${!noms[@]}"; do
    noms[i]="${noms[i]^^}"  # ^^ convertit en majuscules
done

echo "${noms[@]}"  # ALICE BOB CHARLIE

# Ajouter un préfixe à chaque élément
fichiers=("doc1.txt" "doc2.txt" "doc3.txt")

for i in "${!fichiers[@]}"; do
    fichiers[i]="backup_${fichiers[i]}"
done

echo "${fichiers[@]}"  # backup_doc1.txt backup_doc2.txt backup_doc3.txt
```

> [!example] Exemple pratique : normalisation de données
> 
> ```bash
> # Nettoyer des entrées utilisateur
> entrees=("  Alice  " "BOB" "charlie   ")
> 
> for i in "${!entrees[@]}"; do
>     # Supprimer espaces + première lettre en majuscule
>     temp="${entrees[i]// /}"           # Supprimer tous les espaces
>     temp="${temp,,}"                    # Tout en minuscules
>     entrees[i]="${temp^}"              # Première lettre en majuscule
> done
> 
> echo "${entrees[@]}"  # Alice Bob Charlie
> ```

---

## 🗑️ Suppression d'éléments

### Suppression par indice avec unset

La commande `unset` permet de supprimer un élément spécifique d'un tableau. L'indice est libéré mais les autres indices restent inchangés.

```bash
# Suppression d'un élément
couleurs=("rouge" "vert" "bleu" "jaune" "violet")
unset couleurs[2]

echo "${couleurs[@]}"    # rouge vert jaune violet
echo "${#couleurs[@]}"   # 4 éléments
echo "${!couleurs[@]}"   # 0 1 3 4 (l'indice 2 n'existe plus)
```

> [!warning] L'indice supprimé n'est pas réutilisé automatiquement Après un `unset`, l'indice est libéré mais le tableau n'est pas "compacté". Si vous ajoutez un nouvel élément avec `+=`, il prendra le prochain indice disponible après le maximum actuel.
> 
> ```bash
> array=(a b c d)
> unset array[1]
> echo "${!array[@]}"  # 0 2 3
> array+=(e)
> echo "${!array[@]}"  # 0 2 3 4 (pas 0 1 2 3 4)
> ```

### Suppression du premier ou dernier élément

```bash
# Supprimer le premier élément (indice 0)
nombres=(10 20 30 40 50)
unset nombres[0]
echo "${nombres[@]}"  # 20 30 40 50

# Supprimer le dernier élément (indice -1 ou calcul)
nombres=(10 20 30 40 50)
unset nombres[-1]
# Ou : unset "nombres[${#nombres[@]}-1]"
echo "${nombres[@]}"  # 10 20 30 40
```

### Compacter un tableau après suppression

Si vous souhaitez réorganiser les indices après suppression :

```bash
# Méthode 1 : créer un nouveau tableau
original=("a" "b" "c" "d" "e")
unset original[2]
compacte=("${original[@]}")

echo "${!original[@]}"   # 0 1 3 4
echo "${!compacte[@]}"   # 0 1 2 3

# Méthode 2 : réassignation directe
original=("${original[@]}")
echo "${!original[@]}"   # 0 1 2 3
```

### Suppression par valeur

```bash
# Supprimer un élément par sa valeur (première occurrence)
animaux=("chat" "chien" "chat" "oiseau")
valeur_a_supprimer="chat"

for i in "${!animaux[@]}"; do
    if [[ "${animaux[i]}" == "$valeur_a_supprimer" ]]; then
        unset animaux[i]
        break  # Supprimer seulement la première occurrence
    fi
done

echo "${animaux[@]}"  # chien chat oiseau
```

> [!example] Exemple pratique : filtrage de tableau
> 
> ```bash
> # Supprimer tous les éléments qui commencent par "test_"
> fichiers=("data.txt" "test_1.log" "report.pdf" "test_2.log" "config.ini")
> 
> for i in "${!fichiers[@]}"; do
>     if [[ "${fichiers[i]}" == test_* ]]; then
>         unset fichiers[i]
>     fi
> done
> 
> # Compacter le tableau
> fichiers=("${fichiers[@]}")
> echo "${fichiers[@]}"  # data.txt report.pdf config.ini
> ```

### Suppression de plusieurs éléments

```bash
# Supprimer une plage d'indices
notes=(12 15 8 18 14 10 16)
for i in {2..4}; do
    unset notes[i]
done
echo "${notes[@]}"  # 12 15 10 16

# Supprimer tous les éléments pairs (par indice)
valeurs=(a b c d e f g h)
for i in "${!valeurs[@]}"; do
    if (( i % 2 == 0 )); then
        unset valeurs[i]
    fi
done
echo "${valeurs[@]}"  # b d f h
```

---

## 🧹 Suppression complète

### Supprimer tout le tableau

La commande `unset` peut également supprimer complètement un tableau.

```bash
# Suppression complète
langages=("Python" "JavaScript" "Bash" "Ruby")
unset langages

echo "${langages[@]}"    # (rien, tableau n'existe plus)
echo "${#langages[@]}"   # 0

# Vérifier si un tableau existe
if declare -p langages 2>/dev/null | grep -q 'declare -a'; then
    echo "Le tableau existe"
else
    echo "Le tableau n'existe pas"
fi
```

> [!info] Différence entre tableau vide et tableau inexistant
> 
> ```bash
> # Tableau vide (existe mais ne contient rien)
> vide=()
> echo "${#vide[@]}"  # 0
> declare -p vide     # declare -a vide=()
> 
> # Tableau inexistant (n'existe pas du tout)
> unset inexistant
> echo "${#inexistant[@]}"  # 0 (même résultat)
> declare -p inexistant     # bash: declare: inexistant: not found
> ```

### Réinitialisation vs suppression

```bash
# Réinitialisation (le tableau existe toujours, mais vide)
fruits=("pomme" "poire" "orange")
fruits=()
echo "${#fruits[@]}"  # 0
declare -p fruits     # declare -a fruits=()

# Suppression complète (le tableau n'existe plus)
fruits=("pomme" "poire" "orange")
unset fruits
declare -p fruits 2>&1  # bash: declare: fruits: not found
```

---

## ⚠️ Pièges courants

### 1. Oublier les guillemets avec les indices

```bash
# ❌ MAUVAIS : sans guillemets, peut causer des problèmes
array=("valeur 1" "valeur 2")
unset array[1]  # Fonctionne mais risqué

# ✅ BON : avec guillemets pour la sécurité
unset "array[1]"
```

### 2. Utiliser unset sur @{array[@]}

```bash
# ❌ MAUVAIS : ceci ne vide pas le tableau
array=(a b c d)
unset "${array[@]}"  # Ne fait rien ou comportement imprévisible

# ✅ BON : pour vider, réassigner ou unset le tableau entier
array=()
# Ou : unset array
```

### 3. Confusion entre suppression et vidage

```bash
# Supprimer tous les éléments un par un ne supprime pas le tableau
data=(1 2 3)
for i in "${!data[@]}"; do
    unset data[i]
done

declare -p data  # declare -a data=() (existe toujours, vide)

# Pour supprimer complètement :
unset data
```

### 4. Modification pendant l'itération

```bash
# ❌ PROBLÉMATIQUE : modifier le tableau pendant la boucle
numbers=(1 2 3 4 5)
for i in "${!numbers[@]}"; do
    if (( numbers[i] < 3 )); then
        unset numbers[i]  # Peut causer des comportements inattendus
    fi
done

# ✅ SOLUTION : construire un nouveau tableau
numbers=(1 2 3 4 5)
nouveau=()
for val in "${numbers[@]}"; do
    (( val >= 3 )) && nouveau+=("$val")
done
numbers=("${nouveau[@]}")
```

### 5. Indices non contigus après suppressions

```bash
array=(a b c d e)
unset array[1]
unset array[3]

echo "${!array[@]}"   # 0 2 4
echo "${#array[@]}"   # 3

# Attention lors de l'itération par indice
for i in {0..4}; do
    echo "[$i] = ${array[i]}"  # [1] et [3] seront vides
done

# ✅ MIEUX : itérer sur les indices réels
for i in "${!array[@]}"; do
    echo "[$i] = ${array[i]}"
done
```

---

## ✨ Bonnes pratiques

### 1. Toujours utiliser des guillemets

```bash
# Protection contre les espaces et caractères spéciaux
fichiers=("mon fichier.txt" "data.csv")
fichiers[0]="nouveau fichier.txt"
echo "${fichiers[0]}"  # ✅ Fonctionne correctement
```

### 2. Vérifier l'existence avant modification

```bash
# Vérifier si un indice existe avant de le modifier
if [[ -v array[5] ]]; then
    array[5]="nouvelle_valeur"
else
    echo "L'indice 5 n'existe pas"
fi
```

### 3. Documenter les tableaux avec indices non contigus

```bash
# Si vous utilisez volontairement des indices non contigus, commentez
config=()
config[0]="hostname"
config[10]="port"        # Indice 10 pour les paramètres réseau
config[20]="database"    # Indice 20 pour les paramètres DB
# Indices intermédiaires réservés pour usage futur
```

### 4. Préférer la création d'un nouveau tableau pour les filtres complexes

```bash
# Au lieu de supprimer des éléments, créer un tableau filtré
original=("pomme" "test" "orange" "test" "banane")
filtre=()

for item in "${original[@]}"; do
    [[ "$item" != "test" ]] && filtre+=("$item")
done

echo "${filtre[@]}"  # pomme orange banane
```

### 5. Utiliser des fonctions pour encapsuler les opérations

```bash
# Fonction pour ajouter un élément unique
ajouter_unique() {
    local -n arr=$1
    local val=$2
    
    for item in "${arr[@]}"; do
        [[ "$item" == "$val" ]] && return 0
    done
    
    arr+=("$val")
}

# Utilisation
tags=("linux" "bash")
ajouter_unique tags "scripting"
ajouter_unique tags "bash"  # Ne sera pas ajouté (doublon)
echo "${tags[@]}"  # linux bash scripting
```

### 6. Compacter systématiquement après suppressions multiples

```bash
# Après plusieurs suppressions, compacter pour éviter les indices épars
data=(1 2 3 4 5 6 7 8 9 10)

# Suppression de plusieurs éléments
for i in {2..5}; do
    unset data[i]
done

# Compactage
data=("${data[@]}")

echo "${!data[@]}"  # 0 1 2 3 4 5 (indices contigus)
```

---

> [!tip] Astuce finale Pour déboguer vos opérations sur les tableaux, utilisez ces commandes utiles :
> 
> ```bash
> # Afficher tous les indices
> echo "Indices : ${!array[@]}"
> 
> # Afficher le nombre d'éléments
> echo "Nombre : ${#array[@]}"
> 
> # Afficher la déclaration complète
> declare -p array
> 
> # Afficher chaque élément avec son indice
> for i in "${!array[@]}"; do
>     printf "[%s] = %s\n" "$i" "${array[i]}"
> done
> ```

---