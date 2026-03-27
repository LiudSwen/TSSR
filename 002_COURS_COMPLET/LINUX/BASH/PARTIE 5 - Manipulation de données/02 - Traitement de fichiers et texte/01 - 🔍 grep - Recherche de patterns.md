
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

`grep` (Global Regular Expression Print) est un outil fondamental en ligne de commande pour rechercher des motifs (patterns) dans des fichiers texte. C'est l'un des outils les plus utilisés pour filtrer, analyser et extraire des informations.

> [!info] Pourquoi grep est essentiel
> 
> - Recherche rapide dans des milliers de fichiers
> - Filtrage de logs et de sorties de commandes
> - Validation de données
> - Extraction d'informations spécifiques
> - Débogage et analyse de code

---

## Syntaxe de base

```bash
grep [OPTIONS] PATTERN [FILE...]
```

**Composants :**

- `PATTERN` : le motif à rechercher (texte simple ou expression régulière)
- `FILE` : un ou plusieurs fichiers où chercher
- Si aucun fichier n'est spécifié, grep lit depuis l'entrée standard (stdin)

> [!example] Exemples simples
> 
> ```bash
> # Rechercher "error" dans un fichier
> grep error logfile.txt
> 
> # Rechercher dans plusieurs fichiers
> grep error file1.txt file2.txt
> 
> # Utiliser grep avec un pipe
> cat logfile.txt | grep error
> ps aux | grep apache
> ```

---

## Options principales

### Option `-i` : Ignorer la casse

Rend la recherche insensible aux majuscules/minuscules.

```bash
# Trouve "Error", "ERROR", "error", "ErRoR", etc.
grep -i error logfile.txt
```

> [!tip] Quand l'utiliser Idéal pour les recherches où la casse n'a pas d'importance (noms propres, mots-clés variables).

---

### Option `-v` : Inverser la recherche

Affiche toutes les lignes qui NE contiennent PAS le pattern.

```bash
# Afficher toutes les lignes sans "debug"
grep -v debug logfile.txt

# Exclure les lignes vides
grep -v "^$" file.txt

# Exclure les commentaires (commençant par #)
grep -v "^#" config.conf
```

> [!example] Cas d'usage pratique
> 
> ```bash
> # Voir tous les processus sauf grep lui-même
> ps aux | grep apache | grep -v grep
> 
> # Filtrer les logs sans les messages INFO
> grep -v "INFO" application.log
> ```

---

### Option `-r` : Recherche récursive

Parcourt tous les fichiers dans les répertoires et sous-répertoires.

```bash
# Chercher "TODO" dans tous les fichiers du répertoire courant
grep -r "TODO" .

# Chercher dans un répertoire spécifique
grep -r "function" /path/to/project/
```

> [!warning] Attention aux performances La recherche récursive peut être lente sur de grands répertoires. Considère l'utilisation de `--include` ou `--exclude` pour filtrer.
> 
> ```bash
> # Chercher seulement dans les fichiers .py
> grep -r --include="*.py" "import" .
> 
> # Exclure certains répertoires
> grep -r --exclude-dir=node_modules "error" .
> ```

---

### Option `-l` : Afficher uniquement les noms de fichiers

Affiche les noms des fichiers contenant le pattern, sans afficher les lignes correspondantes.

```bash
# Lister les fichiers contenant "TODO"
grep -l "TODO" *.txt

# Avec recherche récursive
grep -rl "password" /var/log/
```

> [!tip] Combinaison utile
> 
> ```bash
> # Trouver tous les fichiers Python contenant une fonction spécifique
> grep -rl --include="*.py" "def process_data" .
> ```

---

### Option `-n` : Afficher les numéros de lignes

Préfixe chaque ligne de résultat avec son numéro de ligne dans le fichier.

```bash
# Afficher "error" avec numéros de lignes
grep -n error logfile.txt
# Sortie : 42:Error: Connection failed
#          87:Fatal error: Out of memory
```

> [!example] Utilisation en débogage
> 
> ```bash
> # Trouver rapidement où se trouve une fonction
> grep -n "def calculate" script.py
> 
> # Combiner avec d'autres options
> grep -rn "FIXME" src/
> ```

---

### Option `-c` : Compter les occurrences

Affiche le nombre de lignes correspondant au pattern (pas le nombre total d'occurrences).

```bash
# Compter les lignes contenant "error"
grep -c error logfile.txt
# Sortie : 15

# Compter dans plusieurs fichiers
grep -c "import" *.py
# Sortie :
# main.py:7
# utils.py:12
# config.py:3
```

> [!warning] Distinction importante `-c` compte les LIGNES contenant le pattern, pas le nombre total d'occurrences. Si une ligne contient 3 fois le mot, elle compte pour 1.
> 
> ```bash
> # Pour compter le nombre total d'occurrences :
> grep -o "pattern" file.txt | wc -l
> ```

---

### Option `-E` : Expressions régulières étendues (egrep)

Active les regex étendues, permettant d'utiliser `+`, `?`, `|`, `()` sans échappement.

```bash
# Chercher "color" ou "colour"
grep -E "colou?r" file.txt

# Chercher des lignes commençant par "Error" ou "Warning"
grep -E "^(Error|Warning)" logfile.txt

# Trouver des nombres de 2 à 4 chiffres
grep -E "[0-9]{2,4}" data.txt
```

> [!info] grep vs grep -E vs egrep
> 
> - `grep` : regex basiques (BRE)
> - `grep -E` ou `egrep` : regex étendues (ERE)
> - La différence principale : certains métacaractères nécessitent `\` en BRE mais pas en ERE

**Tableau comparatif :**

|Fonctionnalité|BRE (grep)|ERE (grep -E)|
|---|---|---|
|Une ou plusieurs|`\+`|`+`|
|Zéro ou un|`\?`|`?`|
|Alternance|`\|`|`|
|Groupes|`\( \)`|`( )`|
|Accolades|`\{ \}`|`{ }`|

---

### Option `-o` : Afficher seulement la correspondance

Affiche uniquement la partie de la ligne qui correspond au pattern, pas la ligne entière.

```bash
# Extraire toutes les adresses email d'un fichier
grep -Eo "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}" file.txt

# Extraire toutes les adresses IP
grep -Eo "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" logfile.txt

# Extraire tous les mots en majuscules
grep -Eo "\b[A-Z]+\b" document.txt
```

> [!tip] Cas d'usage courants
> 
> ```bash
> # Compter le nombre total d'occurrences (pas seulement les lignes)
> grep -o "error" log.txt | wc -l
> 
> # Extraire des URLs
> grep -Eo "https?://[a-zA-Z0-9./?=_-]+" page.html
> 
> # Lister tous les identifiants uniques
> grep -Eo "ID: [0-9]+" data.txt | sort -u
> ```

---

## Expressions régulières basiques

Les expressions régulières basiques (BRE) sont le mode par défaut de `grep`. Voici les métacaractères principaux :

### Métacaractères de position

|Symbole|Signification|Exemple|
|---|---|---|
|`^`|Début de ligne|`^Error` : lignes commençant par "Error"|
|`$`|Fin de ligne|`error$` : lignes finissant par "error"|
|`\<`|Début de mot|`\<error` : "error" en début de mot|
|`\>`|Fin de mot|`error\>` : "error" en fin de mot|

```bash
# Lignes commençant par "Error"
grep "^Error" logfile.txt

# Lignes se terminant par un point
grep "\.$" document.txt

# Lignes vides
grep "^$" file.txt

# Lignes contenant uniquement "OK"
grep "^OK$" status.txt
```

### Métacaractères de correspondance

|Symbole|Signification|Exemple|
|---|---|---|
|`.`|N'importe quel caractère|`a.c` : "abc", "a1c", "a c"|
|`*`|0 ou plus du caractère précédent|`ab*c` : "ac", "abc", "abbc"|
|`[...]`|Classe de caractères|`[aeiou]` : une voyelle|
|`[^...]`|Négation de classe|`[^0-9]` : pas un chiffre|
|`\`|Échappement|`\.` : un point littéral|

```bash
# Trouver des lignes avec 3 chiffres consécutifs
grep "[0-9][0-9][0-9]" file.txt

# Mots commençant par une voyelle
grep "\<[aeiouAEIOU]" words.txt

# Lignes contenant au moins un chiffre
grep "[0-9]" data.txt

# Lignes ne contenant que des lettres et espaces
grep "^[a-zA-Z ]*$" text.txt
```

### Quantificateurs en BRE

> [!warning] Attention à l'échappement ! En BRE (grep par défaut), certains quantificateurs nécessitent `\` pour être traités comme métacaractères.

```bash
# Un ou plusieurs 'a' (nécessite \+ en BRE)
grep "a\+b" file.txt

# Zéro ou un 'a' (nécessite \? en BRE)
grep "a\?b" file.txt

# Entre 2 et 4 'a' (nécessite \{ \} en BRE)
grep "a\{2,4\}" file.txt

# Exactement 3 'a'
grep "a\{3\}" file.txt

# Au moins 2 'a'
grep "a\{2,\}" file.txt
```

### Classes de caractères prédéfinies

|Classe|Équivalent|Description|
|---|---|---|
|`[:alnum:]`|`[A-Za-z0-9]`|Alphanumérique|
|`[:alpha:]`|`[A-Za-z]`|Alphabétique|
|`[:digit:]`|`[0-9]`|Chiffres|
|`[:lower:]`|`[a-z]`|Minuscules|
|`[:upper:]`|`[A-Z]`|Majuscules|
|`[:space:]`|`[ \t\n\r]`|Espaces blancs|
|`[:punct:]`||Ponctuation|

```bash
# Mots contenant uniquement des lettres
grep "^[[:alpha:]]*$" words.txt

# Lignes avec au moins un chiffre
grep "[[:digit:]]" data.txt

# Mots en majuscules
grep "\<[[:upper:]]*\>" text.txt
```

---

## Expressions régulières étendues

Avec `grep -E` (ou `egrep`), les regex sont plus puissantes et intuitives.

### Quantificateurs sans échappement

```bash
# Un ou plusieurs (pas besoin de \+)
grep -E "a+b" file.txt

# Zéro ou un (pas besoin de \?)
grep -E "colou?r" file.txt  # Trouve "color" et "colour"

# Répétitions {n,m} (pas besoin de \{ \})
grep -E "[0-9]{3,5}" file.txt  # 3 à 5 chiffres
```

### Alternance avec |

```bash
# "error" OU "warning"
grep -E "error|warning" logfile.txt

# Lignes commençant par "Error", "Warning" ou "Fatal"
grep -E "^(Error|Warning|Fatal)" logfile.txt

# Extensions de fichiers multiples
grep -E "\.(jpg|png|gif)$" filelist.txt
```

### Groupes de capture

```bash
# Répétition d'un groupe
grep -E "(ab)+" file.txt  # "ab", "abab", "ababab"

# Alternance dans un groupe
grep -E "log(in|out)" file.txt  # "login" ou "logout"

# Groupes imbriqués
grep -E "(https?://)?(www\.)?" urls.txt
```

### Exemples pratiques avancés

```bash
# Adresses email valides
grep -E "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$" emails.txt

# Numéros de téléphone français (formats variés)
grep -E "^(0|\+33)[1-9]( ?[0-9]{2}){4}$" phones.txt

# Adresses IPv4
grep -E "^([0-9]{1,3}\.){3}[0-9]{1,3}$" ips.txt

# Dates au format YYYY-MM-DD
grep -E "^[0-9]{4}-(0[1-9]|1[0-2])-(0[1-9]|[12][0-9]|3[01])$" dates.txt

# URLs HTTP/HTTPS
grep -E "^https?://[a-zA-Z0-9.-]+(/[a-zA-Z0-9./_-]*)?$" urls.txt

# Mots de 5 à 10 lettres
grep -E "\b[a-zA-Z]{5,10}\b" text.txt
```

---

## Pièges courants

> [!warning] Piège 1 : Oublier les guillemets
> 
> ```bash
> # MAUVAIS - le shell peut interpréter les métacaractères
> grep *.txt file.txt
> 
> # BON - toujours mettre le pattern entre guillemets
> grep "*.txt" file.txt
> grep '*.txt' file.txt
> ```

> [!warning] Piège 2 : Confondre BRE et ERE
> 
> ```bash
> # MAUVAIS - en grep normal, + est littéral
> grep "a+" file.txt  # Cherche "a+"
> 
> # BON - utiliser -E pour les regex étendues
> grep -E "a+" file.txt  # Cherche un ou plusieurs 'a'
> 
> # Alternative : échapper en BRE
> grep "a\+" file.txt  # Fonctionne aussi
> ```

> [!warning] Piège 3 : grep dans sa propre sortie
> 
> ```bash
> # MAUVAIS - grep apparaît dans les résultats
> ps aux | grep apache
> # Sortie inclut : user 1234 grep apache
> 
> # BON - exclure grep de la recherche
> ps aux | grep apache | grep -v grep
> 
> # MEILLEUR - utiliser une astuce avec crochets
> ps aux | grep [a]pache  # Le pattern ne correspond pas à lui-même
> ```

> [!warning] Piège 4 : Ne pas échapper les caractères spéciaux du shell
> 
> ```bash
> # MAUVAIS - $ est interprété par le shell
> grep "price: $100" file.txt
> 
> # BON - utiliser des guillemets simples
> grep 'price: $100' file.txt
> 
> # Ou échapper
> grep "price: \$100" file.txt
> ```

> [!warning] Piège 5 : Oublier que -c compte les LIGNES, pas les occurrences
> 
> ```bash
> # Ligne : "error error error"
> grep -c "error" file.txt  # Retourne 1, pas 3
> 
> # Pour compter les occurrences totales :
> grep -o "error" file.txt | wc -l
> ```

---

## Astuces avancées

### 🎯 Astuce 1 : Contexte autour des correspondances

```bash
# Afficher 3 lignes avant (-B) la correspondance
grep -B 3 "error" logfile.txt

# Afficher 3 lignes après (-A) la correspondance
grep -A 3 "error" logfile.txt

# Afficher 3 lignes avant ET après (-C)
grep -C 3 "error" logfile.txt
```

### 🎯 Astuce 2 : Colorisation pour meilleure lisibilité

```bash
# Colorer les correspondances (souvent activé par défaut)
grep --color=always "error" logfile.txt

# Désactiver la couleur
grep --color=never "error" logfile.txt

# Rendre permanent dans votre shell
alias grep='grep --color=auto'
```

### 🎯 Astuce 3 : Recherche multi-patterns

```bash
# Plusieurs patterns avec -e
grep -e "error" -e "warning" -e "fatal" logfile.txt

# Avec un fichier de patterns (-f)
cat patterns.txt
# error
# warning
# fatal

grep -f patterns.txt logfile.txt
```

### 🎯 Astuce 4 : Ignorer les fichiers binaires

```bash
# Par défaut, grep peut afficher des résultats dans les binaires
grep -r "text" .

# Ignorer complètement les fichiers binaires
grep -rI "text" .

# Ou afficher juste le nom si binaire
grep -r --binary-files=without-match "text" .
```

### 🎯 Astuce 5 : Performance avec grands fichiers

```bash
# Arrêter après la première correspondance
grep -m 1 "pattern" huge_file.txt

# Limiter à 10 correspondances
grep -m 10 "pattern" huge_file.txt

# Utiliser --line-buffered pour le streaming
tail -f application.log | grep --line-buffered "ERROR"
```

### 🎯 Astuce 6 : Combinaisons puissantes

```bash
# Trouver les fichiers Python avec des TODOs, avec numéro de ligne
grep -rn --include="*.py" "TODO" .

# Statistiques : compter les erreurs par fichier de log
grep -c "ERROR" /var/log/*.log | sort -t: -k2 -nr

# Extraire et trier des adresses IP uniques
grep -Eo "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" access.log | sort -u

# Pipeline complexe : trouver les 10 erreurs les plus fréquentes
grep "ERROR" app.log | cut -d':' -f3- | sort | uniq -c | sort -rn | head -10
```

### 🎯 Astuce 7 : Recherche insensible aux accents

```bash
# Utiliser iconv pour normaliser
iconv -f utf-8 -t ascii//TRANSLIT file.txt | grep -i "cafe"
```

### 🎯 Astuce 8 : Mode silencieux pour scripting

```bash
# Vérifier si un pattern existe (exit code 0 si trouvé)
if grep -q "pattern" file.txt; then
    echo "Pattern trouvé"
fi

# Compter sans afficher les lignes
count=$(grep -c "pattern" file.txt)
echo "Trouvé $count fois"
```

---

> [!tip] Mémo rapide
> 
> ```bash
> grep pattern file           # Recherche basique
> grep -i pattern file        # Ignorer la casse
> grep -v pattern file        # Inverser (exclure)
> grep -r pattern dir/        # Récursif
> grep -n pattern file        # Avec numéros de lignes
> grep -l pattern files       # Noms de fichiers uniquement
> grep -c pattern file        # Compter les lignes
> grep -E "pat1|pat2" file    # Regex étendues
> grep -o pattern file        # Seulement les matches
> grep -A3 -B3 pattern file   # Avec contexte
> ```

---

**Fin du cours** 🎓