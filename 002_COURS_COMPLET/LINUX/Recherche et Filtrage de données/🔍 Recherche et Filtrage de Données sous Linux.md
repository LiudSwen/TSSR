
--- 

## 📋 Table des matières
```table-of-contents
```toc
minLevel: 2
maxLevel: 2
```

---
## 🎯 Introduction

La maîtrise de la recherche et du filtrage de données est **essentielle** pour un Technicien Supérieur en Systèmes et Réseaux (TSSR). Ces outils vous permettent de :

- 📊 Analyser rapidement des logs système
- 🔍 Trouver des informations dans de gros fichiers
- 🛠️ Automatiser des tâches d'administration
- 🐛 Déboguer des problèmes réseau ou système
- 📈 Générer des rapports et statistiques

> [!info] Philosophie Unix Chaque commande fait **une seule chose** mais la fait **très bien**. La puissance vient de leur **combinaison** via les pipes.

---

## 🔎 grep - Recherche de motifs

### Qu'est-ce que grep ?

`grep` (Global Regular Expression Print) recherche des lignes contenant un motif dans des fichiers ou des flux de données. C'est l'outil le plus utilisé pour filtrer du texte sous Linux.

### Pourquoi utiliser grep ?

- ✅ Rechercher des erreurs dans les logs
- ✅ Filtrer les résultats d'une commande
- ✅ Vérifier la présence d'une configuration
- ✅ Extraire des informations spécifiques

### Syntaxe de base

```bash
grep [OPTIONS] MOTIF [FICHIER...]
```

### Options essentielles

|Option|Description|Exemple|
|---|---|---|
|`-i`|Ignorer la casse (majuscules/minuscules)|`grep -i "error" log.txt`|
|`-v`|Inverser la recherche (lignes ne contenant PAS le motif)|`grep -v "debug" log.txt`|
|`-n`|Afficher les numéros de lignes|`grep -n "failed" auth.log`|
|`-r` ou `-R`|Recherche récursive dans les sous-dossiers|`grep -r "password" /etc/`|
|`-c`|Compter les occurrences|`grep -c "ERROR" app.log`|
|`-l`|Afficher uniquement les noms de fichiers|`grep -l "TODO" *.py`|
|`-w`|Correspondance exacte du mot|`grep -w "cat" file.txt`|
|`-A n`|Afficher n lignes après|`grep -A 3 "ERROR" log.txt`|
|`-B n`|Afficher n lignes avant|`grep -B 2 "CRITICAL" log.txt`|
|`-C n`|Afficher n lignes avant et après|`grep -C 5 "exception" debug.log`|
|`-E`|Utiliser des expressions régulières étendues|`grep -E "error|
|`--color`|Coloriser les résultats|`grep --color "warning" syslog`|

### Exemples pratiques

```bash
# Rechercher "error" dans un fichier (insensible à la casse)
grep -i "error" /var/log/syslog

# Afficher toutes les lignes SAUF les commentaires (#)
grep -v "^#" /etc/ssh/sshd_config

# Trouver toutes les adresses IP dans un fichier
grep -E "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" access.log

# Rechercher récursivement "function" dans tous les fichiers Python
grep -r "function" /home/user/scripts/*.py

# Compter le nombre d'erreurs dans un log
grep -c "ERROR" application.log

# Afficher le contexte (5 lignes avant/après) d'une erreur
grep -C 5 "Connection refused" /var/log/messages

# Rechercher plusieurs motifs
grep -E "error|warning|critical" system.log

# Rechercher uniquement le mot exact "cat" (pas "category")
grep -w "cat" animals.txt

# Rechercher les lignes commençant par "Failed"
grep "^Failed" auth.log

# Rechercher les lignes se terminant par ".conf"
grep "\.conf$" filelist.txt
```

> [!example] Cas d'usage réel Trouver toutes les tentatives de connexion SSH échouées :
> 
> ```bash
> grep "Failed password" /var/log/auth.log | grep -o "[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}"
> ```

> [!warning] Pièges courants
> 
> - **Oublier les guillemets** : `grep error log.txt` peut être ambigu si "error" est aussi un fichier
> - **Caractères spéciaux** : Pensez à échapper les caractères regex comme `.` `*` `?` avec `\`
> - **Performance** : Sur de gros fichiers, utilisez `-F` (recherche de chaîne fixe) au lieu de regex

> [!tip] Astuce pro Créez un alias pour grep avec couleur par défaut :
> 
> ```bash
> alias grep='grep --color=auto'
> ```

### Expressions régulières de base

|Symbole|Signification|Exemple|
|---|---|---|
|`.`|N'importe quel caractère|`gr.p` → grep, grap, gr3p|
|`^`|Début de ligne|`^Error` → lignes commençant par "Error"|
|`$`|Fin de ligne|`done$` → lignes finissant par "done"|
|`*`|0 ou plusieurs fois|`go*gle` → ggle, gogle, google|
|`+`|1 ou plusieurs fois (avec -E)|`go+gle` → gogle, google|
|`?`|0 ou 1 fois (avec -E)|`colou?r` → color, colour|
|`[]`|Ensemble de caractères|`[aeiou]` → une voyelle|
|`[^]`|Négation|`[^0-9]` → tout sauf un chiffre|
|`\|`|OU logique (avec -E)|`cat\|dog` → cat ou dog|

---

## ⚙️ awk - Traitement de texte avancé

### Qu'est-ce que awk ?

`awk` est un langage de programmation complet spécialisé dans le traitement de texte structuré (colonnes). Il lit ligne par ligne et applique des actions sur les champs.

### Pourquoi utiliser awk ?

- ✅ Extraire des colonnes spécifiques
- ✅ Effectuer des calculs sur des données
- ✅ Formater des sorties
- ✅ Filtrer selon des conditions complexes
- ✅ Traiter des fichiers CSV, logs structurés

### Syntaxe de base

```bash
awk 'MOTIF {ACTION}' fichier
awk '{ACTION}' fichier          # Action sur toutes les lignes
awk 'MOTIF' fichier             # Affiche les lignes correspondant au motif
```

### Concepts clés

|Concept|Description|Exemple|
|---|---|---|
|`$0`|Ligne complète|`awk '{print $0}' file.txt`|
|`$1, $2, $n`|Champs 1, 2, n|`awk '{print $1}' file.txt`|
|`NR`|Numéro de la ligne actuelle|`awk '{print NR, $0}' file.txt`|
|`NF`|Nombre de champs sur la ligne|`awk '{print NF}' file.txt`|
|`-F`|Définir le séparateur de champs|`awk -F':' '{print $1}' /etc/passwd`|
|`BEGIN`|Actions avant de lire le fichier|`awk 'BEGIN {print "Début"}' file.txt`|
|`END`|Actions après avoir lu le fichier|`awk 'END {print "Fin"}' file.txt`|

### Exemples pratiques

```bash
# Afficher la première colonne d'un fichier
awk '{print $1}' data.txt

# Afficher les colonnes 1 et 3 séparées par une tabulation
awk '{print $1 "\t" $3}' data.txt

# Utiliser ":" comme séparateur (fichier /etc/passwd)
awk -F':' '{print $1}' /etc/passwd

# Afficher les lignes où la 3e colonne > 100
awk '$3 > 100' data.txt

# Afficher les lignes 10 à 20
awk 'NR>=10 && NR<=20' file.txt

# Calculer la somme d'une colonne
awk '{sum += $2} END {print "Total:", sum}' numbers.txt

# Compter le nombre de lignes
awk 'END {print NR}' file.txt

# Afficher les lignes avec au moins 5 champs
awk 'NF >= 5' data.txt

# Formater une sortie personnalisée
awk '{printf "Nom: %-10s Age: %d\n", $1, $2}' users.txt

# Filtrer selon un motif avec action
awk '/ERROR/ {print "Ligne", NR ":", $0}' log.txt

# Afficher la dernière colonne
awk '{print $NF}' file.txt

# Inverser l'ordre des colonnes
awk '{print $3, $2, $1}' file.txt

# Ajouter un en-tête et un total
awk 'BEGIN {print "Rapport de ventes"} {sum += $2} END {print "Total:", sum}' sales.txt

# Utiliser plusieurs séparateurs (espace ou tabulation)
awk -F'[ \t]+' '{print $1}' file.txt
```

### Filtrer les utilisateurs système

```bash
# Afficher uniquement les utilisateurs avec UID >= 1000 (utilisateurs normaux)
awk -F: '$3 >= 1000 {print $0}' /etc/passwd

# Afficher seulement le nom d'utilisateur des utilisateurs >= 1000
awk -F: '$3 >= 1000 {print $1}' /etc/passwd

# Afficher le nom et l'UID des utilisateurs >= 1000
awk -F: '$3 >= 1000 {print $1, $3}' /etc/passwd

# Format lisible avec colonnes alignées
awk -F: '$3 >= 1000 {printf "%-20s UID: %s\n", $1, $3}' /etc/passwd

# Afficher nom, UID et répertoire personnel
awk -F: '$3 >= 1000 {printf "%-15s UID: %-5s Home: %s\n", $1, $3, $6}' /etc/passwd
```

> [!example] Cas d'usage réel Extraire les utilisateurs ayant un shell bash :
> 
> ```bash
> awk -F':' '$7 == "/bin/bash" {print $1}' /etc/passwd
> ```
> 
> Extraire les utilisateurs non-système avec bash :
> 
> ```bash
> awk -F':' '$3 >= 1000 && $7 == "/bin/bash" {print $1}' /etc/passwd
> ```

> [!warning] Pièges courants
> 
> - **Séparateur par défaut** : awk utilise l'espace/tab par défaut. Pensez à `-F` pour d'autres séparateurs
> - **Comparaisons** : Utilisez `==` pour l'égalité (pas `=` qui est une affectation)
> - **Guillemets** : Utilisez des guillemets simples pour l'ensemble du programme awk

> [!tip] Astuces avancées
> 
> - Combinez plusieurs conditions : `awk '$3 > 50 && $3 < 100'`
> - Variables personnalisées : `awk '{total += $2; count++} END {print total/count}'`
> - Expressions régulières : `awk '/^[A-Z]/ {print}' file.txt`

### Opérateurs awk

|Type|Opérateurs|Exemple|
|---|---|---|
|Arithmétiques|`+ - * / % ^`|`$3 + $4`|
|Comparaison|`== != < > <= >=`|`$2 >= 100`|
|Logiques|`&& \| !`|`$1 == "admin" && $2 > 50`|
|Correspondance|`~ !~`|`$1 ~ /^[A-Z]/`|
|Concaténation|(espace)|`$1 " " $2`|

### Variables intégrées

```bash
# FS : Séparateur de champs en entrée
awk 'BEGIN {FS=":"} {print $1}' /etc/passwd

# OFS : Séparateur de champs en sortie
awk 'BEGIN {OFS=" | "} {print $1, $2}' data.txt

# RS : Séparateur d'enregistrements en entrée (par défaut \n)
awk 'BEGIN {RS=";"} {print}' data.txt

# ORS : Séparateur d'enregistrements en sortie
awk 'BEGIN {ORS=" "} {print}' data.txt
```
---

## 🔢 sort - Tri de données

### Qu'est-ce que sort ?

`sort` trie les lignes d'un fichier ou d'une entrée selon différents critères. Indispensable pour organiser des données.

### Pourquoi utiliser sort ?

- ✅ Trier des logs par ordre chronologique
- ✅ Ordonner des listes
- ✅ Préparer des données pour d'autres traitements
- ✅ Éliminer les doublons (avec `-u`)

### Syntaxe de base

```bash
sort [OPTIONS] [FICHIER...]
```

### Options essentielles

|Option|Description|Exemple|
|---|---|---|
|`-r`|Tri inverse (décroissant)|`sort -r file.txt`|
|`-n`|Tri numérique|`sort -n numbers.txt`|
|`-h`|Tri "human-readable" (1K, 2M, 3G)|`du -h|
|`-k N`|Trier selon la colonne N|`sort -k 2 data.txt`|
|`-t`|Définir le séparateur de colonnes|`sort -t':' -k 3 /etc/passwd`|
|`-u`|Éliminer les doublons|`sort -u file.txt`|
|`-f`|Ignorer la casse|`sort -f names.txt`|
|`-V`|Tri de version (1.2, 1.10, 2.0)|`sort -V versions.txt`|
|`-o`|Fichier de sortie|`sort file.txt -o sorted.txt`|
|`-c`|Vérifier si déjà trié|`sort -c file.txt`|
|`-M`|Tri par mois (Jan, Feb...)|`sort -M months.txt`|

### Exemples pratiques

```bash
# Tri alphabétique simple
sort names.txt

# Tri inverse
sort -r names.txt

# Tri numérique (important !)
sort -n ages.txt

# Tri selon la 3e colonne (séparateur: espace)
sort -k 3 data.txt

# Tri selon la 2e colonne avec séparateur ":"
sort -t':' -k 2 /etc/passwd

# Tri numérique sur la 2e colonne
sort -k 2 -n scores.txt

# Éliminer les doublons et trier
sort -u duplicates.txt

# Tri par taille "human-readable"
du -sh * | sort -h

# Tri de versions de logiciels
sort -V versions.txt

# Tri par plusieurs clés (colonne 2, puis 3)
sort -k 2,2 -k 3,3 data.txt

# Tri inverse numérique sur colonne 4
sort -k 4 -nr data.txt

# Trier un fichier CSV par la 3e colonne
sort -t',' -k 3 data.csv

# Ignorer les espaces de début lors du tri
sort -b file.txt
```

> [!example] Cas d'usage réel Trier les 10 plus gros fichiers d'un répertoire :
> 
> ```bash
> du -sh * | sort -hr | head -10
> ```

> [!warning] Pièges courants
> 
> - **Tri alphabétique vs numérique** : `sort` fait du tri alphabétique par défaut, donc "10" < "2" ! Utilisez `-n`
> - **Colonnes** : `-k 2` trie à partir de la colonne 2 jusqu'à la fin. Utilisez `-k 2,2` pour trier UNIQUEMENT sur la colonne 2
> - **Locale** : Le tri peut varier selon la locale. Fixez-la avec `LC_ALL=C sort` pour un tri cohérent

> [!tip] Astuces avancées
> 
> - Trier sur plusieurs critères : `sort -k 1,1 -k 2,2n` (colonne 1 alpha, colonne 2 numérique)
> - Trier en ignorant les en-têtes : `(head -1 file.csv && tail -n +2 file.csv | sort -t',' -k 2)`

### Options de tri avancées

```bash
# Tri stable (préserve l'ordre relatif des lignes égales)
sort -s data.txt

# Tri avec séparateur multiple espaces/tabs
sort -k 2 -t $'\t' data.txt

# Tri par plage de caractères (du 5e au 10e caractère)
sort -k 1.5,1.10 data.txt

# Tri par ordre décroissant sur une colonne spécifique
sort -k 3,3nr data.txt
```

---

## 📊 wc - Comptage d'éléments

### Qu'est-ce que wc ?

`wc` (Word Count) compte les lignes, mots et caractères dans des fichiers ou flux de données.

### Pourquoi utiliser wc ?

- ✅ Compter le nombre de lignes dans un log
- ✅ Vérifier la taille d'un fichier en caractères
- ✅ Compter les résultats d'une recherche
- ✅ Statistiques rapides sur des fichiers texte

### Syntaxe de base

```bash
wc [OPTIONS] [FICHIER...]
```

### Options essentielles

|Option|Description|Exemple|
|---|---|---|
|`-l`|Compter les lignes|`wc -l file.txt`|
|`-w`|Compter les mots|`wc -w file.txt`|
|`-c`|Compter les octets|`wc -c file.txt`|
|`-m`|Compter les caractères|`wc -m file.txt`|
|`-L`|Afficher la longueur de la ligne la plus longue|`wc -L file.txt`|

### Exemples pratiques

```bash
# Compter les lignes d'un fichier
wc -l /var/log/syslog

# Compter les mots
wc -w document.txt

# Compter les caractères
wc -m readme.txt

# Compter les octets
wc -c binary_file

# Afficher toutes les statistiques (lignes, mots, octets)
wc file.txt

# Compter les fichiers dans un répertoire
ls | wc -l

# Compter le nombre d'utilisateurs sur le système
wc -l /etc/passwd

# Compter les erreurs dans un log
grep "ERROR" app.log | wc -l

# Compter les lignes de plusieurs fichiers
wc -l *.txt

# Longueur de la ligne la plus longue
wc -L config.txt
```

> [!example] Cas d'usage réel Compter le nombre de connexions actives sur le serveur :
> 
> ```bash
> netstat -an | grep ESTABLISHED | wc -l
> ```

> [!warning] Pièges courants
> 
> - **Fichiers sans retour à la ligne final** : wc peut compter une ligne de moins si le fichier ne se termine pas par `\n`
> - **Différence octets/caractères** : `-c` compte les octets, `-m` les caractères (important pour UTF-8)

> [!tip] Astuce pro Combiner avec d'autres commandes via pipes :
> 
> ```bash
> cat file.txt | grep "pattern" | wc -l  # Compter les occurrences
> find . -name "*.log" | wc -l           # Compter les fichiers .log
> ```

### Sortie de wc

Sans option, `wc` affiche dans l'ordre : **lignes mots octets nom_fichier**

```bash
$ wc document.txt
  42  350  2048 document.txt
  # 42 lignes, 350 mots, 2048 octets
```

---

## 🔀 Pipes et Redirections

### Concept fondamental

Les pipes (`|`) et redirections (`>`, `>>`, `<`) sont au cœur de la philosophie Unix : connecter des commandes simples pour créer des workflows puissants.

### Le Pipe `|`

Le pipe **redirige la sortie standard** d'une commande vers **l'entrée standard** d'une autre.

```bash
commande1 | commande2 | commande3
```

#### Exemples de pipes

```bash
# Lister les fichiers et compter
ls -l | wc -l

# Chercher un processus
ps aux | grep apache

# Afficher les 10 plus gros fichiers
du -sh * | sort -hr | head -10

# Compter les connexions uniques dans un log
cat access.log | awk '{print $1}' | sort -u | wc -l

# Extraire et trier les utilisateurs
cat /etc/passwd | cut -d':' -f1 | sort

# Pipeline complexe
cat sales.csv | grep "2024" | awk -F',' '{sum+=$3} END {print sum}' | bc
```

> [!info] Flux standards
> 
> - **stdin (0)** : Entrée standard (clavier par défaut)
> - **stdout (1)** : Sortie standard (écran par défaut)
> - **stderr (2)** : Sortie d'erreur (écran par défaut)

### Redirections de sortie

|Opérateur|Description|Exemple|
|---|---|---|
|`>`|Redirige stdout vers un fichier (écrase)|`ls > list.txt`|
|`>>`|Redirige stdout vers un fichier (ajoute)|`echo "log" >> app.log`|
|`2>`|Redirige stderr vers un fichier|`command 2> errors.txt`|
|`2>&1`|Redirige stderr vers stdout|`command > output.txt 2>&1`|
|`&>`|Redirige stdout et stderr|`command &> all.txt`|
|`2>&1 \|`|Pipe stderr et stdout ensemble|`command 2>&1 \| grep error`|

#### Exemples de redirections

```bash
# Sauvegarder le résultat dans un fichier
grep "ERROR" app.log > errors.txt

# Ajouter à un fichier existant
echo "Nouvelle ligne" >> journal.txt

# Rediriger les erreurs
find / -name "*.conf" 2> /dev/null

# Tout rediriger (sortie + erreurs)
script.sh &> output.log

# Séparer sortie et erreurs
command > output.txt 2> errors.txt

# Rediriger les erreurs vers la sortie standard
command 2>&1 | grep "pattern"

# Supprimer la sortie
command > /dev/null

# Supprimer les erreurs
command 2> /dev/null

# Tout supprimer
command &> /dev/null
```

### Redirection d'entrée

|Opérateur|Description|Exemple|
|---|---|---|
|`<`|Redirige stdin depuis un fichier|`wc -l < file.txt`|
|`<<`|Here document (document intégré)|Voir ci-dessous|
|`<<<`|Here string (chaîne intégrée)|`grep "text" <<< "some text"`|

#### Exemples

```bash
# Lire depuis un fichier
wc -l < /etc/passwd

# Here document (document multi-lignes)
cat << EOF > config.txt
Server: localhost
Port: 8080
Debug: true
EOF

# Here string
bc <<< "2 + 2"
grep "test" <<< "this is a test"
```

> [!example] Cas d'usage réel Créer un rapport d'erreurs filtré et sauvegardé :
> 
> ```bash
> grep -i "error\|warning\|critical" /var/log/syslog | \
>   awk '{print $1, $2, $3, $5}' | \
>   sort | \
>   uniq -c | \
>   sort -nr > rapport_erreurs.txt
> ```

> [!warning] Pièges courants
> 
> - **Écraser des fichiers** : `>` écrase ! Utilisez `>>` pour ajouter ou activez `set -o noclobber`
> - **Ordre des redirections** : L'ordre compte ! `command > file 2>&1` ≠ `command 2>&1 > file`
> - **Pipes et variables** : Les pipes créent des sous-shells, les variables ne remontent pas

> [!tip] Astuces avancées
> 
> - **Tee** : Afficher ET sauvegarder : `command | tee output.txt`
> - **Process substitution** : `diff <(sort file1) <(sort file2)`
> - **Multiple pipes** : Enchaînez autant que nécessaire pour obtenir le résultat voulu

### Combinaisons utiles

```bash
# Afficher ET sauvegarder
ls -la | tee listing.txt

# Afficher, sauvegarder et continuer le pipe
command | tee intermediate.txt | grep "pattern"

# Compter en temps réel
tail -f /var/log/syslog | grep "ERROR" | wc -l

# Pipeline avec feedback
find / -name "*.log" 2>&1 | tee search.txt | wc -l
```

---

## 🚀 Combinaisons puissantes

### Analyse de logs

```bash
# Top 10 des adresses IP dans un log Apache
awk '{print $1}' access.log | sort | uniq -c | sort -nr | head -10

# Compter les codes HTTP
awk '{print $9}' access.log | sort | uniq -c | sort -nr

# Afficher les erreurs 404 avec contexte
grep " 404 " access.log | awk '{print $1, $7}'

# Analyser les heures de pic
awk '{print $4}' access.log | cut -d: -f2 | sort | uniq -c | sort -nr

# Taille totale des requêtes
awk '{sum += $10} END {print sum/1024/1024 " MB"}' access.log
```

### Traitement de CSV

```bash
# Extraire une colonne d'un CSV
awk -F',' '{print $2}' data.csv

# Filtrer les lignes où colonne 3 > 100
awk -F',' '$3 > 100' data.csv

# Calculer la moyenne d'une colonne
awk -F',' '{sum+=$3; count++} END {print sum/count}' data.csv

# Trier un CSV par la 2e colonne
sort -t',' -k2 data.csv

# Éliminer les doublons dans un CSV
sort -u -t',' -k1,1 data.csv
```

### Administration système

```bash
# Utilisateurs connectés avec leur nombre de processus
ps aux | awk '{print $1}' | sort | uniq -c | sort -nr

# Top 10 des processus consommant de la mémoire
ps aux | sort -k4 -nr | head -10

# Nombre de connexions par port
netstat -an | awk '{print $4}' | grep -E ":[0-9]+" | cut -d: -f2 | sort | uniq -c | sort -nr

# Espace disque utilisé par répertoire (top 10)
du -sh /var/* 2>/dev/null | sort -hr | head -10

# Compter les fichiers par extension
find . -type f | grep -E "\.[a-z]+$" | sed 's/.*\.//' | sort | uniq -c | sort -nr

# Trouver les fichiers récemment modifiés
find /var/log -type f -mtime -1 -exec ls -lh {} \; | awk '{print $9, $5}'
```

### Recherche et filtrage avancés

```bash
# Trouver les lignes dupliquées dans un fichier
sort file.txt | uniq -d

# Compter les occurrences de chaque mot
cat text.txt | tr ' ' '\n' | sort | uniq -c | sort -nr

# Extraire les emails d'un fichier
grep -Eo "[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}" file.txt

# Afficher uniquement les lignes uniques (sans doublons)
sort file.txt | uniq -u

# Comparer deux fichiers et afficher les différences
comm -3 <(sort file1.txt) <(sort file2.txt)

# Statistiques sur un fichier de logs
wc -l log.txt && \
grep -c "ERROR" log.txt && \
grep -c "WARNING" log.txt && \
grep -c "INFO" log.txt
```

### Cas pratiques complexes - Niveau TSSR

> [!example] Exercice 1 : Filtrage multi-critères sur fichier CSV **Contexte** : Vous avez un fichier `apprenants.csv` avec les colonnes : Prénom, Nom, Ville, Formation initiale, Formation avancée, Projet1, Projet2, Projet3
> 
> **Objectif** : Trouver les apprenants avec :
> 
> - Projet 1 à 70 ou 80
> - Projet 2 à 80 ou 90
> - Projet 3 à 90 ou 100
> - Progression obligatoirement croissante (P1 < P2 < P3)
> 
> **Solution** :
> 
> ```bash
> awk -F',' '
>   ($6 == 70 || $6 == 80) && 
>   ($7 == 80 || $7 == 90) && 
>   ($8 == 90 || $8 == 100) && 
>   ($6 < $7 && $7 < $8) 
>   {print $2"_"$1, $6, $7, $8; count++} 
>   END {print "\nTotal:", count, "apprenants"}
> ' apprenants.csv > bonneEvolution.txt
> ```
> 
> **Points clés** :
> 
> - Combinaison de `||` (OU) et `&&` (ET)
> - Concaténation sans espace : `$2"_"$1`
> - Condition de croissance : `$6 < $7 && $7 < $8`
> - Compteur avec `count++` dans l'action
> - Affichage du total avec `END`

> [!example] Exercice 2 : Analyse de logs Apache avec seuils **Contexte** : Analyser `access.log` pour détecter des comportements suspects
> 
> **Objectif** : Trouver les IPs avec :
> 
> - Plus de 100 requêtes
> - Au moins 10 erreurs 404
> - Des tentatives d'accès à des fichiers sensibles (.env, .git, admin)
> 
> **Solution** :
> 
> ```bash
> # Étape 1 : Compter les requêtes par IP
> awk '{print $1}' access.log | sort | uniq -c | awk '$1 > 100 {print $2}' > ips_suspectes.tmp
> 
> # Étape 2 : Pour chaque IP suspecte, vérifier les 404 et fichiers sensibles
> while read ip; do
>   erreurs=$(grep "$ip" access.log | grep " 404 " | wc -l)
>   sensibles=$(grep "$ip" access.log | grep -E "\.env|\.git|admin" | wc -l)
>   
>   if [ $erreurs -ge 10 ] && [ $sensibles -gt 0 ]; then
>     total=$(grep -c "$ip" access.log)
>     echo "$ip : $total requêtes, $erreurs erreurs 404, $sensibles fichiers sensibles"
>   fi
> done < ips_suspectes.tmp
> 
> rm ips_suspectes.tmp
> ```
> 
> **Version optimisée avec awk uniquement** :
> 
> ```bash
> awk '
>   {ip=$1; total[ip]++}
>   / 404 / {erreurs404[ip]++}
>   /\.env|\.git|admin/ {sensibles[ip]++}
>   END {
>     for (ip in total) {
>       if (total[ip] > 100 && erreurs404[ip] >= 10 && sensibles[ip] > 0) {
>         printf "%s : %d requêtes, %d erreurs 404, %d fichiers sensibles\n", 
>                ip, total[ip], erreurs404[ip], sensibles[ip]
>       }
>     }
>   }
> ' access.log | sort -t':' -k2 -nr
> ```

> [!example] Exercice 3 : Gestion d'inventaire avec alertes **Contexte** : Fichier `stock.csv` avec : Produit, Catégorie, Quantité, Seuil_min, Seuil_max, Prix
> 
> **Objectif** : Générer un rapport d'alerte pour :
> 
> - Stock critique : quantité ≤ seuil_min
> - Surstock : quantité ≥ seuil_max
> - Valeur totale du stock par catégorie
> 
> **Solution** :
> 
> ```bash
> awk -F',' '
>   NR > 1 {  # Ignorer l'en-tête
>     produit=$1; categorie=$2; qte=$3; min=$4; max=$5; prix=$6
>     
>     # Stock critique
>     if (qte <= min) {
>       critique[categorie]++
>       print "🔴 CRITIQUE:", produit, "(" qte "/" min ")"
>     }
>     
>     # Surstock
>     if (qte >= max) {
>       surstock[categorie]++
>       print "🟡 SURSTOCK:", produit, "(" qte "/" max ")"
>     }
>     
>     # Calcul valeur par catégorie
>     valeur_cat[categorie] += qte * prix
>     total_general += qte * prix
>   }
>   END {
>     print "\n=== RÉSUMÉ PAR CATÉGORIE ==="
>     for (cat in valeur_cat) {
>       printf "%s : %.2f€ (Critiques: %d, Surstock: %d)\n", 
>              cat, valeur_cat[cat], critique[cat]+0, surstock[cat]+0
>     }
>     printf "\nVALEUR TOTALE : %.2f€\n", total_general
>   }
> ' stock.csv
> ```

> [!example] Exercice 4 : Analyse de performance serveur **Contexte** : Fichier `cpu_usage.log` avec timestamp et % CPU par processus Format : `2024-03-15 10:30:45 apache2 45.2`
> 
> **Objectif** : Trouver les processus qui :
> 
> - Dépassent 80% CPU au moins 5 fois
> - Ont une moyenne > 60%
> - Afficher le pic max de chaque processus
> 
> **Solution** :
> 
> ```bash
> awk '
>   {
>     process=$3
>     cpu=$4
>     
>     # Compter dépassements
>     if (cpu > 80) depassements[process]++
>     
>     # Somme pour moyenne
>     somme[process] += cpu
>     compteur[process]++
>     
>     # Pic maximum
>     if (cpu > max[process]) max[process] = cpu
>   }
>   END {
>     print "PROCESSUS PROBLÉMATIQUES :"
>     print "=========================="
>     for (p in compteur) {
>       moyenne = somme[p] / compteur[p]
>       if (depassements[p] >= 5 && moyenne > 60) {
>         printf "%-15s | Moy: %5.1f%% | Pic: %5.1f%% | Dépassements: %d\n",
>                p, moyenne, max[p], depassements[p]
>       }
>     }
>   }
> ' cpu_usage.log | sort -t'|' -k2 -nr
> ```

> [!example] Exercice 5 : Analyse de ventes avec conditions multiples **Contexte** : Fichier `ventes.csv` : Date, Vendeur, Produit, Quantité, Prix_unitaire, Region
> 
> **Objectif** : Identifier les "Top Performers" :
> 
> - Chiffre d'affaires total > 50000€
> - Au moins 3 régions différentes
> - Moyenne par vente > 500€
> - Bonus si CA > 100000€
> 
> **Solution** :
> 
> ```bash
> awk -F',' '
>   NR > 1 {
>     vendeur=$2; qte=$4; prix=$5; region=$6
>     ca = qte * prix
>     
>     # CA total par vendeur
>     ca_total[vendeur] += ca
>     
>     # Régions uniques (utilise région comme clé)
>     regions[vendeur,region] = 1
>     
>     # Nombre de ventes
>     nb_ventes[vendeur]++
>   }
>   END {
>     print "=== TOP PERFORMERS ==="
>     for (v in ca_total) {
>       # Compter régions uniques pour ce vendeur
>       nb_regions = 0
>       for (combo in regions) {
>         split(combo, arr, SUBSEP)
>         if (arr[1] == v) nb_regions++
>       }
>       
>       moyenne = ca_total[v] / nb_ventes[v]
>       
>       # Vérifier tous les critères
>       if (ca_total[v] > 50000 && nb_regions >= 3 && moyenne > 500) {
>         bonus = (ca_total[v] > 100000) ? "🏆 BONUS" : ""
>         printf "%-20s | CA: %10.2f€ | Régions: %d | Moy/vente: %8.2f€ %s\n",
>                v, ca_total[v], nb_regions, moyenne, bonus
>       }
>     }
>   }
> ' ventes.csv | sort -t'|' -k2 -nr
> ```

> [!tip] Techniques avancées utilisées Ces exercices combinent :
> 
> - **Tableaux associatifs** : `array[key]`, `array[key1,key2]`
> - **Conditions multiples** : `&&`, `||`, parenthèses pour priorité
> - **Compteurs et accumulateurs** : `count++`, `sum += value`
> - **Opérateur ternaire** : `(condition) ? valeur_si_vrai : valeur_si_faux`
> - **Formatage printf** : `printf "format", var1, var2`
> - **Boucles END** : `for (key in array)`
> - **Fonctions intégrées** : `split()`, `length()`, `substr()`

### Scripts de monitoring

```bash
# Alerter si plus de 100 erreurs dans les logs
ERROR_COUNT=$(grep -c "ERROR" /var/log/app.log)
if [ $ERROR_COUNT -gt 100 ]; then
    echo "ALERTE: $ERROR_COUNT erreurs détectées"
fi

# Surveiller l'espace disque
df -h | awk '$5 > 80 {print "ALERTE:", $1, "est à", $5}'

# Lister les connexions suspectes
netstat -an | grep ESTABLISHED | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -nr | awk '$1 > 50 {print "Suspect:", $2, "avec", $1, "connexions"}'
```

> [!tip] Conseil de pro Testez vos pipelines étape par étape :
> 
> ```bash
> # Construisez progressivement
> cat file.txt
> cat file.txt | grep "pattern"
> cat file.txt | grep "pattern" | awk '{print $1}'
> cat file.txt | grep "pattern" | awk '{print $1}' | sort -u
> ```

---

## 📑 Cheat Sheets

### grep - Aide-mémoire rapide

```bash
# Recherches de base
grep "motif" fichier                    # Recherche simple
grep -i "motif" fichier                 # Ignorer la casse
grep -v "motif" fichier                 # Inverser (lignes sans le motif)
grep -n "motif" fichier                 # Avec numéros de lignes
grep -c "motif" fichier                 # Compter les occurrences
grep -l "motif" *.txt                   # Lister les fichiers contenant le motif
grep -r "motif" /chemin/                # Recherche récursive

# Contexte
grep -A 3 "motif" fichier               # 3 lignes après
grep -B 2 "motif" fichier               # 2 lignes avant
grep -C 5 "motif" fichier               # 5 lignes avant et après

# Expressions régulières
grep "^début" fichier                   # Lignes commençant par "début"
grep "fin$" fichier                     # Lignes finissant par "fin"
grep -E "mot1|mot2" fichier             # mot1 OU mot2
grep "[0-9]\{3\}" fichier               # Exactement 3 chiffres
grep -w "mot" fichier                   # Mot exact (pas dans un autre mot)

# Options utiles
grep --color "motif" fichier            # Coloriser les résultats
grep -o "motif" fichier                 # Afficher uniquement le motif
grep -q "motif" fichier                 # Mode silencieux (code retour seulement)
grep -m 5 "motif" fichier               # S'arrêter après 5 correspondances

# Combinaisons pratiques
grep -rn "ERROR" /var/log/              # Recherche récursive avec lignes
grep -i "error" file.txt | wc -l        # Compter les erreurs
ps aux | grep -v grep | grep "apache"   # Filtrer processus (exclure grep lui-même)
```

### awk - Aide-mémoire rapide

```bash
# Affichage de colonnes
awk '{print $1}' fichier                # 1ère colonne
awk '{print $1, $3}' fichier            # 1ère et 3ème colonnes
awk '{print $NF}' fichier               # Dernière colonne
awk '{print $0}' fichier                # Ligne complète

# Séparateurs
awk -F':' '{print $1}' fichier          # Séparateur personnalisé
awk -F',' '{print $2}' fichier.csv      # Pour fichiers CSV
awk 'BEGIN {FS=":"; OFS=" | "} {print $1,$2}' fichier  # Sép. entrée/sortie

# Filtrage
awk '$3 > 100' fichier                  # Lignes où colonne 3 > 100
awk '$1 == "admin"' fichier             # Colonne 1 égale à "admin"
awk '$2 >= 50 && $3 < 100' fichier      # Conditions multiples
awk '/pattern/ {print}' fichier         # Lignes contenant "pattern"
awk '!/pattern/ {print}' fichier        # Lignes ne contenant PAS "pattern"

# Calculs
awk '{sum += $2} END {print sum}' fichier               # Somme de colonne 2
awk '{sum += $2; count++} END {print sum/count}' fic    # Moyenne
awk 'BEGIN {max=0} {if ($2>max) max=$2} END {print max}' fichier  # Maximum

# Variables intégrées
awk '{print NR, $0}' fichier            # NR = Numéro de ligne
awk '{print NF}' fichier                # NF = Nombre de champs
awk 'NR==10,NR==20' fichier             # Lignes 10 à 20
awk 'END {print NR}' fichier            # Nombre total de lignes

# BEGIN et END
awk 'BEGIN {print "Début du rapport"} {print} END {print "Fin"}' fichier
awk 'BEGIN {sum=0} {sum+=$1} END {print "Total:", sum}' fichier

# Formatage
awk '{printf "%-10s %5d\n", $1, $2}' fichier            # Format précis
awk '{print $1 "\t" $2}' fichier                        # Avec tabulation

# Exemples pratiques
awk -F':' '$3 >= 1000 {print $1}' /etc/passwd           # Utilisateurs normaux
awk '{print $1}' access.log | sort | uniq -c            # Compter par IP
ps aux | awk '{print $2, $11}'                          # PID et commande
df -h | awk '$5+0 > 80 {print $1, $5}'                  # Disques > 80%
```

### sort - Aide-mémoire rapide

```bash
# Tris de base
sort fichier                            # Tri alphabétique croissant
sort -r fichier                         # Tri décroissant
sort -n fichier                         # Tri numérique
sort -u fichier                         # Tri + éliminer doublons
sort -f fichier                         # Ignorer la casse

# Tri par colonnes
sort -k 2 fichier                       # Trier sur colonne 2
sort -k 2,2 fichier                     # Uniquement colonne 2
sort -k 2n fichier                      # Colonne 2 en numérique
sort -k 2nr fichier                     # Colonne 2 numérique décroissant
sort -t':' -k 3 fichier                 # Séparateur personnalisé

# Tris spéciaux
sort -h fichier                         # Human-readable (1K, 2M, 3G)
sort -M fichier                         # Tri par mois (Jan, Feb...)
sort -V fichier                         # Tri de versions (1.2, 1.10, 2.0)
sort -R fichier                         # Tri aléatoire

# Options utiles
sort -o sortie.txt fichier              # Sauvegarder dans un fichier
sort -c fichier                         # Vérifier si déjà trié
sort -b fichier                         # Ignorer espaces de début

# Tris multiples
sort -k 1,1 -k 2,2n fichier             # Col 1 alpha, puis col 2 numérique
sort -t',' -k 3,3n -k 1,1 fichier.csv   # Multi-colonnes CSV

# Exemples pratiques
du -sh * | sort -h                      # Trier par taille
ps aux | sort -k 4 -nr                  # Processus par mémoire
cat fichier | sort | uniq               # Éliminer doublons
sort -t':' -k 3 -n /etc/passwd          # Utilisateurs par UID
```

### wc - Aide-mémoire rapide

```bash
# Comptages de base
wc fichier                              # Lignes, mots, octets
wc -l fichier                           # Nombre de lignes
wc -w fichier                           # Nombre de mots
wc -c fichier                           # Nombre d'octets
wc -m fichier                           # Nombre de caractères
wc -L fichier                           # Longueur ligne la plus longue

# Comptages multiples
wc -l *.txt                             # Compter dans plusieurs fichiers
wc -l fichier1 fichier2 fichier3        # Total + détails par fichier

# Avec pipes
ls | wc -l                              # Nombre de fichiers
ps aux | wc -l                          # Nombre de processus
grep "ERROR" log.txt | wc -l            # Compter les erreurs
cat fichier | wc -l                     # Alternative à wc -l fichier

# Exemples pratiques
find . -name "*.log" | wc -l            # Compter fichiers .log
cat /etc/passwd | wc -l                 # Nombre d'utilisateurs
netstat -an | grep ESTABLISHED | wc -l  # Connexions actives
git log --oneline | wc -l               # Nombre de commits
du -b fichier | awk '{print $1}'        # Taille exacte en octets
```

### Pipes et Redirections - Aide-mémoire rapide

```bash
# Pipes
cmd1 | cmd2                             # Sortie de cmd1 → entrée de cmd2
cmd1 | cmd2 | cmd3                      # Chaîne de commandes

# Redirections de sortie
cmd > fichier                           # Écrire sortie (écrase)
cmd >> fichier                          # Ajouter sortie
cmd 2> fichier                          # Écrire erreurs
cmd > fichier 2>&1                      # Tout rediriger
cmd &> fichier                          # Tout rediriger (raccourci)
cmd > /dev/null                         # Supprimer sortie
cmd 2> /dev/null                        # Supprimer erreurs
cmd &> /dev/null                        # Tout supprimer

# Redirections d'entrée
cmd < fichier                           # Lire depuis fichier
cmd << EOF                              # Here document
cmd <<< "texte"                         # Here string

# Commandes utiles
cmd | tee fichier                       # Afficher ET sauvegarder
cmd | tee -a fichier                    # Afficher ET ajouter
cmd1 | tee file1 | cmd2 | tee file2     # Multiples sauvegardes

# Exemples complexes
cmd 2>&1 | tee log.txt                  # Tout capturer et afficher
cmd1 | cmd2 > out.txt 2> err.txt        # Séparer sortie/erreurs
(cmd1; cmd2) | cmd3                     # Grouper commandes
cmd1 && cmd2                            # cmd2 si cmd1 réussit
cmd1 || cmd2                            # cmd2 si cmd1 échoue
cmd1; cmd2                              # Exécuter séquentiellement
```

### Combinaisons fréquentes

```bash
# Top 10 des IP les plus fréquentes
awk '{print $1}' access.log | sort | uniq -c | sort -nr | head -10

# Utilisateurs avec leur shell
awk -F':' '{print $1, $7}' /etc/passwd | sort

# Processus par consommation mémoire
ps aux | sort -k 4 -nr | head -10 | awk '{print $2, $4, $11}'

# Compter extensions de fichiers
find . -type f | sed 's/.*\.//' | sort | uniq -c | sort -nr

# Statistiques sur un fichier
echo "Lignes: $(wc -l < file.txt) | Mots: $(wc -w < file.txt) | Chars: $(wc -m < file.txt)"

# Filtrer et compter
grep -i "error" *.log | wc -l

# Recherche avec contexte colorisé
grep --color=always -C 3 "pattern" file.txt | less -R

# Top des commandes utilisées
history | awk '{print $2}' | sort | uniq -c | sort -nr | head -10

# Moyenne d'une colonne
awk '{sum+=$3; n++} END {print sum/n}' data.txt

# Fusionner et trier deux fichiers
cat file1.txt file2.txt | sort -u

# Compter mots uniques
cat text.txt | tr ' ' '\n' | sort -u | wc -l

# Lignes communes à deux fichiers
comm -12 <(sort file1.txt) <(sort file2.txt)

# Lignes dans file1 mais pas dans file2
comm -23 <(sort file1.txt) <(sort file2.txt)

# Extraire colonne et calculer somme
awk '{print $2}' data.txt | paste -sd+ | bc

# Monitoring en temps réel
tail -f /var/log/syslog | grep --color "ERROR"

# Backup avec timestamp
cat important.txt | tee backup_$(date +%Y%m%d_%H%M%S).txt > /dev/null
```

### Expressions régulières - Rappel rapide

```bash
# Caractères spéciaux
.           # N'importe quel caractère
^           # Début de ligne
$           # Fin de ligne
*           # 0 ou plusieurs fois
+           # 1 ou plusieurs fois (avec -E)
?           # 0 ou 1 fois (avec -E)
[]          # Ensemble de caractères
[^]         # Négation
\           # Échappement
|           # OU logique (avec -E)

# Classes de caractères
[0-9]       # Un chiffre
[a-z]       # Une lettre minuscule
[A-Z]       # Une lettre majuscule
[a-zA-Z]    # Une lettre
[^0-9]      # Tout sauf un chiffre

# Quantificateurs
\{n\}       # Exactement n fois
\{n,\}      # Au moins n fois
\{n,m\}     # Entre n et m fois

# Exemples pratiques
grep "^[A-Z]" file.txt                  # Lignes commençant par majuscule
grep "[0-9]\{3\}-[0-9]\{4\}" file.txt   # Format XXX-XXXX
grep -E "^(192\.168|10\.)" file.txt     # IPs privées
grep "error.*line [0-9]+" file.txt      # "error" suivi de "line N"
```

### Astuces de performance

```bash
# Recherche fixe (plus rapide que regex)
grep -F "texte_exact" gros_fichier.txt

# Limiter la sortie
grep -m 100 "pattern" fichier           # S'arrêter après 100 résultats
head -1000 fichier | grep "pattern"     # Chercher dans 1000 premières lignes

# Parallélisation (si disponible)
cat gros_fichier | parallel --pipe grep "pattern"

# Éviter cat inutile
grep "pattern" fichier                  # Mieux que: cat fichier | grep "pattern"
awk '{print $1}' fichier                # Mieux que: cat fichier | awk '{print $1}'

# Utiliser les bons outils
grep -c "pattern" fichier               # Mieux que: grep "pattern" fichier | wc -l
awk '{print $1}' fichier                # Mieux que: cut -d' ' -f1 fichier (si espaces multiples)
```

### Debugging de pipelines

```bash
# Afficher les résultats intermédiaires
cmd1 | tee /tmp/step1.txt | cmd2 | tee /tmp/step2.txt | cmd3

# Compter à chaque étape
cmd1 | tee >(wc -l > /tmp/count1.txt) | cmd2 | tee >(wc -l > /tmp/count2.txt) | cmd3

# Mode verbeux
set -x                                  # Activer le mode debug
# vos commandes ici
set +x                                  # Désactiver

# Vérifier les codes de retour
command || echo "Erreur: $?"

# Pipeline avec gestion d'erreur
set -o pipefail                         # Le pipe échoue si une commande échoue
cmd1 | cmd2 | cmd3
if [ $? -ne 0 ]; then
    echo "Erreur dans le pipeline"
fi
```

---

## 🎓 Bonnes pratiques générales

### Lisibilité

> [!tip] Rendre vos commandes lisibles
> 
> ```bash
> # Mal - tout sur une ligne
> cat /var/log/apache2/access.log | awk '{print $1}' | sort | uniq -c | sort -nr | head -10
> 
> # Mieux - avec retours à la ligne
> cat /var/log/apache2/access.log | \
>   awk '{print $1}' | \
>   sort | \
>   uniq -c | \
>   sort -nr | \
>   head -10
> 
> # Encore mieux - avec commentaires
> cat /var/log/apache2/access.log | \  # Lire le log
>   awk '{print $1}' | \                # Extraire les IPs
>   sort | \                            # Trier
>   uniq -c | \                         # Compter les occurrences
>   sort -nr | \                        # Trier par fréquence
>   head -10                            # Top 10
> ```

### Sécurité

> [!warning] Attention aux données sensibles
> 
> - Ne redirigez jamais de mots de passe vers des fichiers
> - Faites attention aux permissions des fichiers de sortie
> - Utilisez `umask` approprié avant de créer des fichiers
> - Nettoyez les fichiers temporaires contenant des données sensibles

```bash
# Créer un fichier avec permissions restreintes
(umask 077 && grep "password" config > /tmp/secure_data)

# Supprimer de façon sécurisée
shred -vfz -n 3 fichier_sensible.txt
```

### Performance

> [!tip] Optimiser vos commandes
> 
> - Évitez les `cat` inutiles (useless use of cat)
> - Utilisez grep `-F` pour les recherches de chaînes fixes
> - Limitez les résultats avec `head`, `-m`, ou des conditions awk
> - Utilisez `sort -u` au lieu de `sort | uniq`
> - Préférez awk à de multiples pipes quand possible

```bash
# Lent
cat fichier | grep pattern | cut -d':' -f1 | sort | uniq

# Plus rapide
grep pattern fichier | cut -d':' -f1 | sort -u

# Encore mieux (une seule commande)
awk -F':' '/pattern/ {print $1}' fichier | sort -u
```

### Documentation

> [!tip] Documenter vos scripts Ajoutez des commentaires pour expliquer les étapes complexes, surtout dans les scripts de production.

```bash
#!/bin/bash
# Script: analyse_logs.sh
# Description: Analyse les logs Apache pour détecter les anomalies
# Usage: ./analyse_logs.sh /var/log/apache2/access.log

LOGFILE="$1"

# Étape 1: Extraire les IPs avec plus de 100 requêtes
echo "=== IPs suspectes (>100 req) ==="
awk '{print $1}' "$LOGFILE" | \
  sort | \
  uniq -c | \
  sort -nr | \
  awk '$1 > 100 {print $2, $1 " requêtes"}'

# Étape 2: Analyser les codes d'erreur
echo -e "\n=== Statistiques d'erreurs ==="
awk '$9 ~ /^[45]/ {print $9}' "$LOGFILE" | \
  sort | \
  uniq -c | \
  sort -nr
```

### Validation des données

> [!warning] Toujours valider Avant de traiter des données importantes, validez le format et le contenu.

```bash
# Vérifier qu'un fichier existe et n'est pas vide
if [ ! -s "$fichier" ]; then
    echo "Erreur: fichier vide ou inexistant"
    exit 1
fi

# Vérifier le format d'un CSV
if ! head -1 "$fichier" | grep -q ","; then
    echo "Erreur: le fichier ne semble pas être un CSV"
    exit 1
fi

# Compter les colonnes attendues
nb_cols=$(head -1 "$fichier" | awk -F',' '{print NF}')
if [ "$nb_cols" -ne 5 ]; then
    echo "Erreur: nombre de colonnes incorrect (attendu: 5, trouvé: $nb_cols)"
    exit 1
fi
```

---

## 🏆 Récapitulatif final

Vous avez maintenant toutes les bases pour maîtriser la recherche et le filtrage de données sous Linux !

### Les points clés à retenir

1. **grep** : Votre outil principal pour rechercher des motifs textuels
2. **awk** : Le couteau suisse pour traiter des données en colonnes
3. **sort** : Pour organiser vos données selon différents critères
4. **wc** : Pour compter rapidement lignes, mots, caractères
5. **Pipes et redirections** : Le cœur de la puissance Unix

### La clé du succès

> [!info] Pratique et expérimentation La maîtrise vient avec la pratique. N'hésitez pas à :
> 
> - Tester chaque commande individuellement
> - Construire vos pipelines progressivement
> - Consulter les pages man (`man grep`, `man awk`, etc.)
> - Expérimenter sur des fichiers de test avant la production

### Commandes à connaître par cœur

```bash
# Le trio magique pour analyser des logs
grep "ERROR" fichier.log | awk '{print $1, $5}' | sort -u

# Compter et trier
commande | sort | uniq -c | sort -nr

# Extraire, filtrer, compter
awk '{print $1}' fichier | grep "pattern" | wc -l

# Top N
commande | sort -nr | head -10
```

> [!tip] Conseil final Gardez ce cours à portée de main comme référence. La mémorisation viendra naturellement avec l'utilisation quotidienne de ces outils !

---

**Bon apprentissage et bonne pratique ! 🚀**