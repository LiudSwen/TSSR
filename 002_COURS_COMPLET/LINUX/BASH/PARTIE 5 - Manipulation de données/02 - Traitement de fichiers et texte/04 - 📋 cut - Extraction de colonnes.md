
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

La commande `cut` est un outil fondamental pour **extraire des portions spécifiques** de chaque ligne d'un fichier ou d'un flux de texte. Elle permet de découper du texte structuré en colonnes et d'en extraire uniquement les parties qui nous intéressent.

> [!info] Définition `cut` découpe chaque ligne d'entrée et sélectionne des portions selon des critères de **position** (caractères) ou de **structure** (champs délimités).

---

## Pourquoi utiliser cut ?

`cut` est particulièrement utile dans les situations suivantes :

- **Traiter des fichiers structurés** : CSV, TSV, logs, fichiers de configuration
- **Extraire des colonnes spécifiques** d'un tableau de données
- **Isoler des informations** dans des fichiers systèmes comme `/etc/passwd`
- **Nettoyer des données** en ne gardant que les champs pertinents
- **Pipeline avec d'autres commandes** pour créer des chaînes de traitement efficaces

> [!example] Exemple typique Extraire uniquement les noms d'utilisateur du fichier `/etc/passwd` qui utilise `:` comme délimiteur.

---

## Syntaxe générale

```bash
cut [OPTIONS] [FICHIER...]
```

Si aucun fichier n'est spécifié, `cut` lit depuis l'entrée standard (stdin).

**Options principales** :

- `-d` : Spécifier le délimiteur de champs
- `-f` : Sélectionner des champs (colonnes)
- `-c` : Sélectionner des caractères (positions)
- `--complement` : Inverser la sélection (tout sauf ce qui est spécifié)
- `--output-delimiter` : Modifier le délimiteur en sortie

---

## Option -d : Le délimiteur

L'option `-d` (delimiter) définit **quel caractère sépare les champs** dans les lignes d'entrée.

### Syntaxe

```bash
cut -d'DELIMITEUR' -f CHAMPS fichier.txt
```

> [!warning] Important Par défaut, `cut` utilise la **tabulation** comme délimiteur. Si vos données utilisent un autre séparateur (virgule, point-virgule, espace, etc.), vous DEVEZ spécifier `-d`.

### Exemples pratiques

**Fichier CSV avec virgules** :

```bash
# Contenu de data.csv
# nom,prenom,age,ville
# Dupont,Jean,35,Paris
# Martin,Marie,28,Lyon

# Extraire la colonne "prenom" (champ 2)
cut -d',' -f2 data.csv
# Résultat :
# prenom
# Jean
# Marie
```

**Fichier /etc/passwd avec deux-points** :

```bash
# Format : username:x:UID:GID:description:home:shell
cut -d':' -f1 /etc/passwd
# Extrait tous les noms d'utilisateurs
```

**Fichier avec point-virgule** :

```bash
echo "A;B;C;D" | cut -d';' -f3
# Résultat : C
```

> [!tip] Astuce Le délimiteur doit être un **caractère unique**. Pour des délimiteurs plus complexes, utilisez `awk` à la place.

---

## Option -f : Extraction de champs

L'option `-f` (fields) permet de sélectionner des **champs** (colonnes) dans des données délimitées.

### Syntaxe

```bash
cut -d'DELIMITEUR' -f NUMERO_CHAMP fichier.txt
```

Les champs sont numérotés à partir de **1** (pas de 0).

### Sélection d'un seul champ

```bash
# Fichier : fruits.txt
# pomme,rouge,1.20
# banane,jaune,0.80
# orange,orange,1.50

# Extraire le prix (3ème colonne)
cut -d',' -f3 fruits.txt
# Résultat :
# 1.20
# 0.80
# 1.50
```

### Sélection de plusieurs champs

```bash
# Extraire nom et prix (colonnes 1 et 3)
cut -d',' -f1,3 fruits.txt
# Résultat :
# pomme,1.20
# banane,0.80
# orange,1.50
```

> [!info] Ordre préservé Les champs sont toujours affichés dans l'ordre où ils apparaissent dans le fichier, pas dans l'ordre spécifié dans la commande.

```bash
# -f3,1 donnera le même résultat que -f1,3
cut -d',' -f3,1 fruits.txt
# Équivalent à -f1,3
```

### Champs manquants

> [!warning] Comportement important Si une ligne ne contient **pas** le délimiteur spécifié, `cut -f` affichera **la ligne entière** par défaut.

```bash
# Fichier mixte.txt
# a:b:c
# ligne sans délimiteur
# x:y:z

cut -d':' -f2 mixte.txt
# Résultat :
# b
# ligne sans délimiteur  ← ligne entière affichée
# y
```

Pour supprimer ces lignes, utilisez l'option `-s` :

```bash
cut -d':' -f2 -s mixte.txt
# Résultat :
# b
# y
```

---

## Option -c : Extraction de caractères

L'option `-c` (characters) extrait des **positions de caractères** spécifiques, indépendamment de tout délimiteur.

### Syntaxe

```bash
cut -c POSITIONS fichier.txt
```

### Extraire un caractère unique

```bash
echo "Bonjour" | cut -c1
# Résultat : B

echo "Bonjour" | cut -c4
# Résultat : j
```

### Extraire plusieurs caractères

```bash
echo "Bonjour" | cut -c1,3,5
# Résultat : Bno
```

> [!example] Cas pratique : Extraire les 3 premières lettres
> 
> ```bash
> echo "Bonjour tout le monde" | cut -c1-3
> # Résultat : Bon
> ```

### Différence entre -f et -c

|Option|Utilisation|Exemple|
|---|---|---|
|`-f`|Champs séparés par un délimiteur|Colonnes CSV, fichiers structurés|
|`-c`|Positions de caractères fixes|Extraction de sous-chaînes, formatage fixe|

```bash
# Fichier : dates.txt
# 2024-12-15
# 2023-11-20

# Extraire l'année (positions 1-4)
cut -c1-4 dates.txt
# Résultat :
# 2024
# 2023

# Extraire le mois (positions 6-7)
cut -c6-7 dates.txt
# Résultat :
# 12
# 11
```

---

## Plages et sélections multiples

`cut` offre une syntaxe flexible pour sélectionner des ensembles de champs ou de caractères.

### Syntaxe des plages

|Notation|Signification|Exemple|
|---|---|---|
|`N`|Le Nième élément|`-f3` = 3ème champ|
|`N-M`|Du Nième au Mième (inclus)|`-f2-5` = champs 2, 3, 4, 5|
|`N-`|Du Nième jusqu'à la fin|`-f3-` = champ 3 et suivants|
|`-M`|Du début jusqu'au Mième|`-f-4` = champs 1, 2, 3, 4|
|`N,M`|Le Nième et le Mième|`-f1,3` = champs 1 et 3|

### Exemples avec -f

```bash
# Fichier : data.csv
# A,B,C,D,E,F

# Champs 1 à 3
cut -d',' -f1-3 data.csv
# Résultat : A,B,C

# Champ 2 et tous les suivants
cut -d',' -f2- data.csv
# Résultat : B,C,D,E,F

# Du début jusqu'au champ 3
cut -d',' -f-3 data.csv
# Résultat : A,B,C

# Champs 1, 3 et 5
cut -d',' -f1,3,5 data.csv
# Résultat : A,C,E

# Combinaison : champs 1-2 et 5
cut -d',' -f1-2,5 data.csv
# Résultat : A,B,E
```

### Exemples avec -c

```bash
echo "ABCDEFGHIJ" | cut -c1-3
# Résultat : ABC

echo "ABCDEFGHIJ" | cut -c5-
# Résultat : EFGHIJ

echo "ABCDEFGHIJ" | cut -c-4
# Résultat : ABCD

echo "ABCDEFGHIJ" | cut -c1,3,5,7,9
# Résultat : ACEGI

echo "ABCDEFGHIJ" | cut -c1-3,8-10
# Résultat : ABCHIJ
```

> [!tip] Plages chevauchantes Si des plages se chevauchent, `cut` ne répète pas les caractères :
> 
> ```bash
> echo "ABCDEFGH" | cut -c1-5,3-7
> # Résultat : ABCDEFG (pas ABCCDECDEFG)
> ```

---

## Combinaisons et cas pratiques

### Cas 1 : Extraire utilisateurs et shells

```bash
# Format /etc/passwd : username:x:UID:GID:description:home:shell
cut -d':' -f1,7 /etc/passwd
# Résultat : username,/bin/bash
```

### Cas 2 : Modifier le délimiteur de sortie

```bash
# Changer les virgules en tabulations
cut -d',' -f1-3 --output-delimiter=$'\t' data.csv
```

### Cas 3 : Extraire des colonnes d'un tableau ps

```bash
ps aux | cut -c1-15,66-
# Extrait : USER (colonnes 1-15) et COMMAND (colonne 66 et suivantes)
```

### Cas 4 : Combiner cut avec d'autres commandes

```bash
# Extraire les adresses IP d'un fichier de logs
grep "Failed password" /var/log/auth.log | cut -d' ' -f11

# Lister les extensions de fichiers uniques
ls | cut -d'.' -f2 | sort -u

# Extraire le domaine d'adresses email
echo "user@example.com" | cut -d'@' -f2
# Résultat : example.com
```

### Cas 5 : Nettoyer un CSV

```bash
# Garder uniquement certaines colonnes d'un gros CSV
cut -d',' -f1,3,5-7 huge_data.csv > cleaned_data.csv
```

---

## Pièges courants

### ❌ Piège 1 : Oublier de spécifier -d

```bash
# Fichier CSV avec virgules
# Sans -d, cut utilise TAB par défaut
cut -f1 data.csv  # ❌ Ne fonctionnera pas correctement

# Correct :
cut -d',' -f1 data.csv  # ✅
```

### ❌ Piège 2 : Délimiteurs multiples ou espaces

```bash
# Fichier avec plusieurs espaces comme séparateurs
# A    B    C    D

cut -d' ' -f2 file.txt  # ❌ Ne gérera qu'UN SEUL espace
```

> [!warning] Limitation `cut` ne gère **pas** les délimiteurs multiples consécutifs. Pour cela, utilisez `awk` :
> 
> ```bash
> awk '{print $2}' file.txt  # ✅ Gère les espaces multiples
> ```

### ❌ Piège 3 : Confusion entre -f et -c

```bash
# -f extrait des CHAMPS (selon un délimiteur)
cut -d',' -f2 data.csv

# -c extrait des CARACTÈRES (positions fixes)
cut -c5-10 data.txt

# ❌ On ne peut PAS combiner -f et -c dans la même commande
cut -d',' -f1 -c1-5 data.csv  # ERREUR
```

### ❌ Piège 4 : Ordre des champs

```bash
# cut affiche les champs dans l'ORDRE D'ORIGINE, pas l'ordre spécifié
echo "A,B,C" | cut -d',' -f3,1
# Résultat : A,C  (pas C,A)
```

Pour réordonner, utilisez `awk` :

```bash
echo "A,B,C" | awk -F',' '{print $3","$1}'
# Résultat : C,A
```

### ❌ Piège 5 : Lignes sans délimiteur

```bash
# Par défaut, les lignes sans délimiteur sont affichées entièrement
cut -d':' -f1 mixed_file.txt  # Peut produire des résultats inattendus

# Solution : utiliser -s (suppress) pour ignorer ces lignes
cut -d':' -f1 -s mixed_file.txt  # ✅
```

---

## Astuces avancées

### 🎯 Astuce 1 : Inverser la sélection

```bash
# Extraire TOUS les champs SAUF le 2ème
cut -d',' -f2 --complement data.csv
```

### 🎯 Astuce 2 : Compter les champs

```bash
# Vérifier combien de champs contient chaque ligne
awk -F',' '{print NF}' data.csv
```

### 🎯 Astuce 3 : cut avec des pipes

```bash
# Chaîner plusieurs cuts
echo "A:B:C,D,E" | cut -d':' -f3 | cut -d',' -f2
# Résultat : D
```

### 🎯 Astuce 4 : Extraire le dernier champ

```bash
# cut ne peut pas directement extraire le dernier champ
# Utiliser awk à la place
echo "A,B,C,D,E" | awk -F',' '{print $NF}'
# Résultat : E
```

### 🎯 Astuce 5 : Traiter des fichiers sans délimiteur uniforme

```bash
# Pour des fichiers avec espaces variables, utiliser tr + cut
cat file.txt | tr -s ' ' | cut -d' ' -f2
# tr -s ' ' remplace les espaces multiples par un seul
```

### 🎯 Astuce 6 : cut avec xargs

```bash
# Extraire des noms de fichiers et les supprimer
ls -l | cut -d' ' -f9 | xargs rm -f
```

### 🎯 Astuce 7 : Performance sur gros fichiers

```bash
# cut est très rapide, idéal pour les gros fichiers
# Extraire une colonne d'un fichier de 10 Go
cut -d',' -f3 huge_file.csv > column3.txt
```

---

> [!info] Récapitulatif
> 
> - **`-d`** : Définir le délimiteur (par défaut : tabulation)
> - **`-f`** : Sélectionner des champs (colonnes structurées)
> - **`-c`** : Sélectionner des caractères (positions fixes)
> - **Plages** : `1-3` (1 à 3), `2-` (2 à la fin), `-4` (début à 4)
> - **Multiples** : `1,3,5` ou `1-3,7-9`
> - **Options utiles** : `-s` (ignorer lignes sans délimiteur), `--complement` (inverser)

`cut` est un outil simple mais puissant pour l'extraction rapide de données. Pour des besoins plus complexes (réorganisation, calculs, conditions), on se tournera vers `awk`.