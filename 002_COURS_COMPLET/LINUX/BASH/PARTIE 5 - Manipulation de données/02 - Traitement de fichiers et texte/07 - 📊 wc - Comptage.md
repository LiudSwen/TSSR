

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

La commande `wc` (word count) est un outil fondamental pour analyser et compter le contenu de fichiers texte. Elle permet de déterminer rapidement le nombre de lignes, mots, octets ou caractères d'un ou plusieurs fichiers.

> [!info] Pourquoi utiliser wc ?
> 
> - **Analyse rapide** : connaître instantanément la taille d'un fichier
> - **Validation de données** : vérifier qu'un fichier a le bon nombre de lignes
> - **Scripts** : automatiser des vérifications de contenu
> - **Logs** : surveiller la croissance de fichiers journaux
> - **Développement** : compter les lignes de code d'un projet

---

## 📝 Syntaxe générale

```bash
wc [OPTIONS] [FICHIER...]
```

**Sans option**, `wc` affiche trois valeurs dans cet ordre :

1. Nombre de lignes
2. Nombre de mots
3. Nombre d'octets

```bash
# Affichage par défaut
wc fichier.txt
# Sortie : 42 156 1024 fichier.txt
#          │   │    │    └─ nom du fichier
#          │   │    └────── octets
#          │   └─────────── mots
#          └─────────────── lignes
```

> [!tip] Lire depuis l'entrée standard Sans fichier spécifié, `wc` lit depuis stdin :
> 
> ```bash
> echo "Bonjour le monde" | wc
> cat fichier.txt | wc -l
> ```

---

## 🔧 Options principales

### Compter les lignes (`-l`)

L'option `-l` (lines) compte uniquement le nombre de lignes dans un fichier.

```bash
wc -l fichier.txt
# Sortie : 42 fichier.txt
```

> [!info] Qu'est-ce qu'une ligne ? Une ligne est définie par la présence d'un caractère de nouvelle ligne (`\n`). Si un fichier ne se termine pas par `\n`, la dernière ligne ne sera pas comptée.

**Cas d'usage courants :**

```bash
# Compter les lignes d'un fichier de logs
wc -l /var/log/syslog

# Compter le nombre d'utilisateurs du système
wc -l /etc/passwd

# Compter les résultats d'une recherche
grep "ERROR" app.log | wc -l

# Vérifier qu'un CSV a le bon nombre d'entrées
wc -l data.csv
```

> [!example] Exemple pratique
> 
> ```bash
> # Compter les fichiers dans un répertoire
> ls | wc -l
> 
> # Compter les processus en cours
> ps aux | wc -l
> 
> # Compter les lignes de code Python dans un projet
> find . -name "*.py" -exec wc -l {} + | tail -1
> ```

---

### Compter les mots (`-w`)

L'option `-w` (words) compte le nombre de mots dans un fichier.

```bash
wc -w fichier.txt
# Sortie : 156 fichier.txt
```

> [!info] Qu'est-ce qu'un mot ? Un mot est une séquence de caractères délimitée par des espaces, tabulations ou retours à la ligne. Les signes de ponctuation attachés aux mots sont comptés avec eux.

**Exemples d'utilisation :**

```bash
# Compter les mots d'un document
wc -w rapport.txt

# Compter les mots d'un article Markdown
wc -w article.md

# Compter les mots dans plusieurs fichiers
wc -w chapitre*.txt

# Compter les mots depuis une commande
echo "Ceci est un test de comptage" | wc -w
# Sortie : 6
```

> [!warning] Attention aux caractères spéciaux Les mots contenant des caractères accentués ou non-ASCII sont correctement comptés, mais la définition de "mot" reste basée sur les espaces blancs.

---

### Compter les octets (`-c`)

L'option `-c` (bytes) compte le nombre d'octets (bytes) dans un fichier.

```bash
wc -c fichier.txt
# Sortie : 1024 fichier.txt
```

> [!info] Octets vs Caractères Un octet = 8 bits. Pour les caractères ASCII simples, 1 caractère = 1 octet. Mais pour les caractères Unicode (UTF-8), un caractère peut occuper plusieurs octets.

**Utilisations typiques :**

```bash
# Vérifier la taille d'un fichier en octets
wc -c image.jpg

# Comparer avec la taille réelle du fichier
ls -l fichier.txt  # Affiche aussi la taille en octets
wc -c fichier.txt

# Vérifier la taille d'une réponse HTTP
curl -s https://example.com | wc -c

# Calculer la taille totale de plusieurs fichiers
wc -c *.log
```

> [!example] Comparaison pratique
> 
> ```bash
> # Fichier avec uniquement des caractères ASCII
> echo "Hello" > ascii.txt
> wc -c ascii.txt  # 6 octets (5 lettres + 1 \n)
> wc -m ascii.txt  # 6 caractères
> 
> # Fichier avec caractères UTF-8
> echo "Héllo" > utf8.txt
> wc -c utf8.txt  # 7 octets (é prend 2 octets)
> wc -m utf8.txt  # 6 caractères
> ```

---

### Compter les caractères (`-m`)

L'option `-m` (characters) compte le nombre de caractères dans un fichier, en tenant compte de l'encodage.

```bash
wc -m fichier.txt
# Sortie : 1000 fichier.txt
```

> [!info] Différence avec -c
> 
> - `-c` compte les **octets** (bytes)
> - `-m` compte les **caractères** (characters)
> 
> Pour l'UTF-8, un caractère accentué ou un emoji peut occuper 2 à 4 octets, mais reste 1 caractère.

**Exemples concrets :**

```bash
# Compter les caractères d'un texte français
wc -m texte_français.txt

# Compter les caractères dans un fichier avec emojis
echo "Hello 👋 World 🌍" | wc -m
# Sortie : 15 (espaces et emojis comptent chacun pour 1)

# Vérifier la longueur d'un tweet
echo "Mon message Twitter" | wc -m

# Comparaison octets vs caractères
echo "café" > test.txt
wc -c test.txt  # 6 octets (c, a, f, é[2 octets], \n)
wc -m test.txt  # 5 caractères (c, a, f, é, \n)
```

> [!tip] Quand utiliser -m plutôt que -c ?
> 
> - Textes multilingues (chinois, arabe, cyrillique)
> - Textes avec accents (français, espagnol, etc.)
> - Contenu avec emojis
> - Validation de longueur de champs (formulaires, bases de données)

---

## 🚀 Utilisation avancée

### Combiner plusieurs options

Vous pouvez utiliser plusieurs options simultanément :

```bash
# Compter lignes et mots
wc -lw fichier.txt
# Sortie : 42 156 fichier.txt

# Compter lignes, mots et caractères
wc -lwm fichier.txt
# Sortie : 42 156 1000 fichier.txt

# Toutes les informations (équivalent à pas d'option)
wc -lwc fichier.txt
# Sortie : 42 156 1024 fichier.txt
```

### Traiter plusieurs fichiers

`wc` peut analyser plusieurs fichiers et affiche un total :

```bash
# Compter dans plusieurs fichiers
wc -l file1.txt file2.txt file3.txt
# Sortie :
# 10 file1.txt
# 20 file2.txt
# 15 file3.txt
# 45 total

# Avec wildcards
wc -l *.txt

# Compter récursivement avec find
find . -name "*.py" -exec wc -l {} +
```

> [!tip] La ligne "total" Quand plusieurs fichiers sont traités, `wc` ajoute automatiquement une ligne de total. Pour l'obtenir uniquement, utilisez `tail -1`.

### Supprimer le nom du fichier

Pour obtenir uniquement le nombre sans le nom du fichier :

```bash
# Méthode 1 : utiliser stdin
wc -l < fichier.txt
# Sortie : 42

# Méthode 2 : extraire avec awk
wc -l fichier.txt | awk '{print $1}'
# Sortie : 42

# Méthode 3 : utiliser cut
wc -l fichier.txt | cut -d' ' -f1
# Sortie : 42
```

---

## 🔗 Combinaisons avec d'autres commandes

### Avec grep

```bash
# Compter les occurrences d'un pattern
grep "ERROR" app.log | wc -l

# Compter les lignes qui ne contiennent pas un pattern
grep -v "DEBUG" app.log | wc -l

# Compter les fichiers contenant un pattern
grep -l "TODO" *.py | wc -l
```

### Avec find

```bash
# Compter tous les fichiers dans un répertoire
find . -type f | wc -l

# Compter les fichiers Python
find . -name "*.py" | wc -l

# Compter les lignes de code total
find . -name "*.py" -exec cat {} \; | wc -l

# Trouver le fichier le plus long
find . -name "*.txt" -exec wc -l {} \; | sort -n | tail -1
```

### Avec cat et pipes

```bash
# Compter les lignes de plusieurs fichiers concaténés
cat file1.txt file2.txt | wc -l

# Compter les lignes uniques
cat fichier.txt | sort -u | wc -l

# Compter les lignes non vides
cat fichier.txt | grep -v '^$' | wc -l
```

### Dans des scripts

```bash
#!/bin/bash

# Vérifier qu'un fichier a au moins 100 lignes
nb_lignes=$(wc -l < data.csv)
if [ "$nb_lignes" -lt 100 ]; then
    echo "Erreur : le fichier doit contenir au moins 100 lignes"
    exit 1
fi

# Surveiller la croissance d'un fichier de log
taille_avant=$(wc -l < app.log)
sleep 60
taille_après=$(wc -l < app.log)
nouvelles_lignes=$((taille_après - taille_avant))
echo "Nouvelles lignes en 1 minute : $nouvelles_lignes"
```

---

## ⚠️ Pièges courants

> [!warning] Fichier sans nouvelle ligne finale Si un fichier ne se termine pas par `\n`, la dernière ligne ne sera pas comptée par `wc -l` :
> 
> ```bash
> # Créer un fichier sans \n final
> printf "ligne1\nligne2" > test.txt
> wc -l test.txt  # Affiche : 1 (au lieu de 2)
> 
> # Vérifier si un fichier se termine par \n
> [ -n "$(tail -c1 fichier.txt)" ] && echo "Pas de \\n final"
> ```

> [!warning] Confusion octets vs caractères
> 
> ```bash
> # Dans les encodages multi-octets
> echo "café" | wc -c  # 6 octets
> echo "café" | wc -m  # 5 caractères
> 
> # Toujours utiliser -m pour les textes internationaux
> ```

> [!warning] Espaces dans les noms de fichiers
> 
> ```bash
> # Problème avec les espaces
> wc -l mon fichier.txt  # Erreur : cherche "mon" et "fichier.txt"
> 
> # Solutions
> wc -l "mon fichier.txt"
> wc -l mon\ fichier.txt
> ```

> [!warning] Différence entre stdin et fichier
> 
> ```bash
> wc -l fichier.txt       # Affiche : 42 fichier.txt
> wc -l < fichier.txt     # Affiche : 42
> cat fichier.txt | wc -l # Affiche : 42
> 
> # Le nom du fichier n'apparaît qu'avec la première syntaxe
> ```

---

## ✅ Bonnes pratiques

|Pratique|Description|
|---|---|
|**Utiliser `-l` pour les logs**|`wc -l` est idéal pour compter les entrées dans les fichiers de logs|
|**Préférer `-m` pour le texte**|Pour les textes internationaux, utilisez `-m` plutôt que `-c`|
|**Vérifier l'encodage**|Assurez-vous que l'encodage du fichier est cohérent (UTF-8 recommandé)|
|**Utiliser stdin pour les pipes**|`commande|
|**Combiner avec sort**|`wc -l *.txt|
|**Capturer dans des variables**|`nb=$(wc -l < fichier.txt)` pour utiliser dans des scripts|

---

## 💡 Astuces

### Compter les fichiers d'un type spécifique

```bash
# Compter les fichiers Python dans un projet
find . -name "*.py" | wc -l

# Compter les fichiers modifiés aujourd'hui
find . -type f -mtime 0 | wc -l
```

### Comparer des fichiers

```bash
# Vérifier si deux fichiers ont le même nombre de lignes
if [ $(wc -l < file1.txt) -eq $(wc -l < file2.txt) ]; then
    echo "Même nombre de lignes"
fi
```

### Statistiques rapides sur un répertoire

```bash
# Compter tous les types de fichiers
echo "Fichiers totaux : $(find . -type f | wc -l)"
echo "Répertoires : $(find . -type d | wc -l)"
echo "Lignes de code : $(find . -name "*.sh" -exec cat {} \; | wc -l)"
```

### Affichage formaté

```bash
# Ajouter des séparateurs de milliers (nécessite numfmt)
wc -l gros_fichier.txt | awk '{printf "%'\''d lignes\n", $1}'

# Créer un rapport de statistiques
cat > rapport.sh << 'EOF'
#!/bin/bash
echo "=== Statistiques du fichier $1 ==="
echo "Lignes :     $(wc -l < $1)"
echo "Mots :       $(wc -w < $1)"
echo "Caractères : $(wc -m < $1)"
echo "Octets :     $(wc -c < $1)"
EOF
chmod +x rapport.sh
./rapport.sh fichier.txt
```

### Surveiller en temps réel

```bash
# Surveiller la croissance d'un fichier de log
watch -n 1 'wc -l app.log'

# Afficher le nombre de lignes avec la date
while true; do
    echo "$(date) : $(wc -l < app.log) lignes"
    sleep 5
done
```

### Trouver les fichiers les plus longs

```bash
# Top 5 des fichiers les plus longs
find . -type f -name "*.txt" -exec wc -l {} \; | sort -rn | head -5

# Avec affichage formaté
find . -type f -name "*.txt" -exec wc -l {} \; | \
    sort -rn | head -5 | \
    awk '{printf "%8d lignes : %s\n", $1, $2}'
```

---

## 📊 Tableau récapitulatif des options

|Option|Description|Exemple|Sortie typique|
|---|---|---|---|
|(aucune)|Lignes, mots, octets|`wc fichier.txt`|`42 156 1024 fichier.txt`|
|`-l`|Nombre de lignes|`wc -l fichier.txt`|`42 fichier.txt`|
|`-w`|Nombre de mots|`wc -w fichier.txt`|`156 fichier.txt`|
|`-c`|Nombre d'octets|`wc -c fichier.txt`|`1024 fichier.txt`|
|`-m`|Nombre de caractères|`wc -m fichier.txt`|`1000 fichier.txt`|
|`-L`|Longueur de la ligne la plus longue|`wc -L fichier.txt`|`80 fichier.txt`|

> [!info] Option bonus : -L L'option `-L` affiche la longueur de la ligne la plus longue du fichier, utile pour vérifier la conformité à des limites de colonnes (par exemple, PEP 8 en Python suggère 79 caractères maximum).

---