

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

## 🎯 Introduction à AWK

AWK est un langage de programmation spécialisé dans le traitement de fichiers texte structurés en colonnes. Son nom vient de ses créateurs : **A**ho, **W**einberger et **K**ernighan.

> [!info] Pourquoi utiliser AWK ?
> 
> - **Traitement rapide** de fichiers CSV, logs, ou tout fichier avec des colonnes
> - **Extraction** de données spécifiques basée sur des patterns
> - **Calculs** sur des colonnes (sommes, moyennes, statistiques)
> - **Transformation** de données (reformatage, filtrage)
> - **Alternative légère** à Python/Perl pour des tâches simples

> [!tip] Cas d'usage typiques
> 
> - Analyser des logs système (Apache, nginx, syslog)
> - Traiter des fichiers CSV ou TSV
> - Calculer des statistiques sur des colonnes numériques
> - Extraire et reformater des données

---

## 📝 Syntaxe de base

La syntaxe générale d'AWK suit ce modèle :

```bash
awk 'pattern {action}' fichier
```

- **pattern** : condition pour sélectionner les lignes (optionnel)
- **action** : commandes à exécuter sur les lignes sélectionnées
- Si aucun pattern n'est spécifié, l'action s'applique à toutes les lignes
- Si aucune action n'est spécifiée, AWK affiche les lignes correspondant au pattern

### Exemples de base

```bash
# Afficher tout le fichier (équivalent à cat)
awk '{print}' fichier.txt

# Afficher la première colonne
awk '{print $1}' fichier.txt

# Afficher les colonnes 1 et 3
awk '{print $1, $3}' fichier.txt

# Afficher avec un séparateur personnalisé
awk '{print $1 "-" $3}' fichier.txt
```

> [!example] Exemple concret Fichier `users.txt` :
> 
> ```
> Alice 25 Paris
> Bob 30 Lyon
> Charlie 22 Marseille
> ```
> 
> ```bash
> # Afficher seulement les noms
> awk '{print $1}' users.txt
> # Résultat :
> # Alice
> # Bob
> # Charlie
> ```

---

## 🔢 Variables intégrées

AWK dispose de nombreuses variables prédéfinies pour manipuler les données :

|Variable|Description|Exemple d'utilisation|
|---|---|---|
|`$0`|Ligne entière|`{print $0}`|
|`$1, $2, $3...`|Colonne n|`{print $1}`|
|`$NF`|Dernière colonne|`{print $NF}`|
|`NF`|Nombre de colonnes|`{print NF}`|
|`NR`|Numéro de ligne|`{print NR, $0}`|
|`FNR`|Numéro de ligne dans le fichier courant|Utile avec plusieurs fichiers|
|`FS`|Séparateur de champs en entrée|`BEGIN {FS=","}`|
|`OFS`|Séparateur de champs en sortie|`BEGIN {OFS="\t"}`|
|`RS`|Séparateur d'enregistrements|Par défaut `\n`|
|`ORS`|Séparateur d'enregistrements en sortie|Par défaut `\n`|
|`FILENAME`|Nom du fichier en cours|`{print FILENAME, $0}`|

### Exemples avec variables

```bash
# Afficher le numéro de ligne avec chaque ligne
awk '{print NR, $0}' fichier.txt

# Afficher la dernière colonne
awk '{print $NF}' fichier.txt

# Afficher l'avant-dernière colonne
awk '{print $(NF-1)}' fichier.txt

# Afficher le nombre de colonnes de chaque ligne
awk '{print NF}' fichier.txt

# Afficher ligne + nombre de colonnes
awk '{print "Ligne", NR, "contient", NF, "colonnes"}' fichier.txt
```

> [!example] Exemple pratique Fichier `data.txt` :
> 
> ```
> produit1 15.50 5
> produit2 22.30 12
> produit3 8.99 3
> ```
> 
> ```bash
> # Afficher produit et dernière colonne (quantité)
> awk '{print $1, "quantité:", $NF}' data.txt
> # Résultat :
> # produit1 quantité: 5
> # produit2 quantité: 12
> # produit3 quantité: 3
> ```

> [!warning] Piège courant : $NF vs NF
> 
> - `$NF` : contenu de la dernière colonne
> - `NF` : nombre de colonnes (valeur numérique)
> 
> Ne pas confondre !

---

## ✂️ Séparateur de champs

Par défaut, AWK utilise l'espace ou la tabulation comme séparateur. L'option `-F` permet de définir un séparateur personnalisé.

### Syntaxe

```bash
awk -F'séparateur' 'commande' fichier

# Ou dans le script AWK
awk 'BEGIN {FS="séparateur"} {action}' fichier
```

### Séparateurs courants

```bash
# Virgule (CSV)
awk -F',' '{print $1, $3}' fichier.csv

# Point-virgule
awk -F';' '{print $1}' fichier.txt

# Deux-points (fichiers système comme /etc/passwd)
awk -F':' '{print $1, $6}' /etc/passwd

# Tabulation
awk -F'\t' '{print $1}' fichier.tsv

# Plusieurs caractères
awk -F' :: ' '{print $1}' fichier.txt

# Expression régulière
awk -F'[,:]' '{print $1}' fichier.txt  # Virgule OU deux-points
```

### Modifier le séparateur de sortie

```bash
# Séparateur d'entrée : virgule, sortie : tabulation
awk -F',' 'BEGIN {OFS="\t"} {print $1, $2, $3}' fichier.csv

# Important : utiliser la virgule dans print pour que OFS soit appliqué
awk -F',' 'BEGIN {OFS=" | "} {print $1, $2}' fichier.csv
```

> [!example] Exemple avec CSV Fichier `ventes.csv` :
> 
> ```
> Produit,Prix,Quantité
> Laptop,899.99,5
> Souris,15.50,120
> Clavier,45.00,30
> ```
> 
> ```bash
> # Extraire produit et prix
> awk -F',' 'NR>1 {print $1, "coûte", $2, "€"}' ventes.csv
> # Résultat :
> # Laptop coûte 899.99 €
> # Souris coûte 15.50 €
> # Clavier coûte 45.00 €
> ```

> [!tip] Astuce : séparateur multiple Pour traiter plusieurs espaces comme un seul séparateur :
> 
> ```bash
> awk -F' +' '{print $1}' fichier.txt
> # ou simplement (comportement par défaut)
> awk '{print $1}' fichier.txt
> ```

---

## 🚀 BEGIN et END

Les blocs `BEGIN` et `END` permettent d'exécuter des commandes avant et après le traitement du fichier.

### Syntaxe

```bash
awk 'BEGIN {avant} {pendant} END {après}' fichier
```

- **BEGIN** : exécuté une seule fois avant de lire le fichier
- **Bloc principal** : exécuté pour chaque ligne
- **END** : exécuté une seule fois après avoir lu tout le fichier

### Utilisations typiques

```bash
# Initialiser des variables
awk 'BEGIN {total=0} {total += $2} END {print "Total:", total}' fichier.txt

# Afficher un en-tête
awk 'BEGIN {print "=== Rapport ==="} {print $0} END {print "=== Fin ==="}' fichier.txt

# Définir des séparateurs
awk 'BEGIN {FS=","; OFS="\t"} {print $1, $2}' fichier.csv

# Compter les lignes (alternative à wc -l)
awk 'END {print NR}' fichier.txt

# Afficher des statistiques
awk 'BEGIN {sum=0; count=0} 
     {sum += $1; count++} 
     END {print "Moyenne:", sum/count}' nombres.txt
```

> [!example] Exemple complet : calculer une moyenne Fichier `notes.txt` :
> 
> ```
> 15
> 12
> 18
> 14
> 16
> ```
> 
> ```bash
> awk 'BEGIN {
>     print "=== Calcul de moyenne ===" 
>     somme = 0
>     count = 0
> } 
> {
>     somme += $1
>     count++
>     print "Note", count ":", $1
> } 
> END {
>     print "---"
>     print "Nombre de notes:", count
>     print "Somme:", somme
>     print "Moyenne:", somme/count
> }' notes.txt
> ```

> [!warning] Attention avec END Si le fichier est vide, le bloc END est quand même exécuté, mais les variables comme NR vaudront 0.

> [!tip] BEGIN sans fichier Vous pouvez utiliser BEGIN pour des calculs sans fichier d'entrée :
> 
> ```bash
> awk 'BEGIN {print 5 * 7}'  # Affiche 35
> awk 'BEGIN {for(i=1; i<=10; i++) print i}'  # Compte de 1 à 10
> ```

---

## 🎯 Conditions et filtres

AWK permet de filtrer les lignes avec des conditions (patterns) avant d'appliquer des actions.

### Syntaxe générale

```bash
awk 'condition {action}' fichier
```

### Opérateurs de comparaison

|Opérateur|Signification|
|---|---|
|`==`|Égal|
|`!=`|Différent|
|`<`|Inférieur|
|`<=`|Inférieur ou égal|
|`>`|Supérieur|
|`>=`|Supérieur ou égal|
|`~`|Correspond à (regex)|
|`!~`|Ne correspond pas (regex)|

### Opérateurs logiques

|Opérateur|Signification|
|---|---|
|`&&`|ET logique|
|`||
|`!`|NON logique|

### Exemples de filtres

```bash
# Lignes où la 3ème colonne est supérieure à 100
awk '$3 > 100' fichier.txt

# Lignes où la 1ère colonne contient "error"
awk '$1 ~ /error/' log.txt

# Lignes qui ne contiennent PAS "debug"
awk '$0 !~ /debug/' log.txt

# Lignes où la 2ème colonne est "actif"
awk '$2 == "actif"' fichier.txt

# Conditions multiples (ET)
awk '$3 > 50 && $4 < 100' fichier.txt

# Conditions multiples (OU)
awk '$1 == "ERROR" || $1 == "FATAL"' log.txt

# Lignes de 1 à 10
awk 'NR >= 1 && NR <= 10' fichier.txt

# Toutes les lignes sauf la première (ignorer en-tête)
awk 'NR > 1' fichier.csv
```

### Patterns spéciaux

```bash
# Lignes avec un pattern regex
awk '/pattern/' fichier.txt

# Lignes commençant par #
awk '/^#/' fichier.txt

# Lignes finissant par .txt
awk '/\.txt$/' fichier.txt

# Plage de lignes (de la ligne contenant "START" à "END")
awk '/START/,/END/' fichier.txt

# Lignes paires
awk 'NR % 2 == 0' fichier.txt

# Lignes impaires
awk 'NR % 2 == 1' fichier.txt
```

> [!example] Exemple pratique : filtrer un fichier de logs Fichier `server.log` :
> 
> ```
> 2024-01-15 INFO Serveur démarré
> 2024-01-15 ERROR Connexion échouée
> 2024-01-15 WARNING Mémoire faible
> 2024-01-15 INFO Requête traitée
> 2024-01-15 ERROR Timeout base de données
> ```
> 
> ```bash
> # Afficher seulement les erreurs
> awk '$3 == "ERROR"' server.log
> 
> # Afficher erreurs et warnings
> awk '$3 == "ERROR" || $3 == "WARNING"' server.log
> 
> # Afficher les erreurs avec numéro de ligne
> awk '$3 == "ERROR" {print "Ligne", NR ":", $0}' server.log
> ```

> [!tip] Combiner condition et action
> 
> ```bash
> # Si condition vraie, exécuter action
> awk '$3 > 100 {print $1, "dépasse 100 avec", $3}' fichier.txt
> 
> # Plusieurs conditions et actions
> awk '$1 == "ERROR" {errors++} 
>      $1 == "WARNING" {warnings++} 
>      END {print "Erreurs:", errors, "Warnings:", warnings}' log.txt
> ```

---

## 🔢 Opérations arithmétiques

AWK supporte toutes les opérations arithmétiques classiques et peut traiter les colonnes comme des nombres.

### Opérateurs arithmétiques

|Opérateur|Opération|Exemple|
|---|---|---|
|`+`|Addition|`$1 + $2`|
|`-`|Soustraction|`$3 - $4`|
|`*`|Multiplication|`$2 * $3`|
|`/`|Division|`$5 / $6`|
|`%`|Modulo|`$1 % 2`|
|`^` ou `**`|Puissance|`$1 ^ 2`|
|`++`|Incrémentation|`count++`|
|`--`|Décrémentation|`count--`|

### Opérateurs d'assignation

|Opérateur|Équivalent|Exemple|
|---|---|---|
|`+=`|`x = x + y`|`total += $2`|
|`-=`|`x = x - y`|`reste -= $3`|
|`*=`|`x = x * y`|`produit *= $1`|
|`/=`|`x = x / y`|`moyenne /= count`|
|`%=`|`x = x % y`|`i %= 10`|

### Exemples de calculs

```bash
# Calculer le total de la 2ème colonne
awk '{total += $2} END {print "Total:", total}' fichier.txt

# Calculer prix * quantité
awk '{print $1, $2 * $3}' fichier.txt

# Moyenne de la 3ème colonne
awk '{sum += $3; count++} END {print sum/count}' fichier.txt

# Pourcentage
awk '{print $1, ($2/$3)*100 "%"}' fichier.txt

# Arrondir à 2 décimales
awk '{printf "%.2f\n", $1}' fichier.txt

# Min et Max
awk 'NR==1 {min=max=$1} 
     {if($1<min) min=$1; if($1>max) max=$1} 
     END {print "Min:", min, "Max:", max}' nombres.txt
```

> [!example] Exemple : calcul de statistiques Fichier `ventes.txt` :
> 
> ```
> Produit1 50 10
> Produit2 30 15
> Produit3 80 5
> ```
> 
> ```bash
> # Calculer le total des ventes (prix * quantité)
> awk '{
>     vente = $2 * $3
>     total += vente
>     print $1, ":", vente, "€"
> } END {
>     print "---"
>     print "Total des ventes:", total, "€"
> }' ventes.txt
> ```

> [!warning] Division par zéro AWK ne génère pas d'erreur pour une division par zéro, il retourne `inf` ou `-inf`. Testez toujours avant :
> 
> ```bash
> awk '{if($2 != 0) print $1/$2; else print "Division par zéro"}' fichier.txt
> ```

### Calculs complexes

```bash
# Écart-type (simple)
awk '{sum+=$1; sumsq+=$1*$1} 
     END {print sqrt(sumsq/NR - (sum/NR)^2)}' nombres.txt

# Somme cumulée
awk '{sum += $1; print $1, sum}' fichier.txt

# Différence avec ligne précédente
awk '{if(NR>1) print $1-prev; prev=$1}' fichier.txt

# Calculer une TVA (20%)
awk '{tva = $2 * 0.20; ttc = $2 + tva; print $1, ttc}' prix.txt
```

---

## 🔧 Fonctions intégrées

AWK dispose de nombreuses fonctions pour manipuler les chaînes de caractères, faire des calculs mathématiques, etc.

### Fonctions sur les chaînes

|Fonction|Description|Exemple|
|---|---|---|
|`length(s)`|Longueur de la chaîne|`length($1)`|
|`substr(s, pos, len)`|Sous-chaîne|`substr($1, 1, 5)`|
|`index(s, t)`|Position de t dans s|`index($1, "@")`|
|`tolower(s)`|Convertir en minuscules|`tolower($1)`|
|`toupper(s)`|Convertir en majuscules|`toupper($1)`|
|`split(s, a, sep)`|Découper une chaîne|`split($0, arr, ",")`|
|`gsub(r, s, t)`|Remplacer globalement|`gsub(/old/, "new", $1)`|
|`sub(r, s, t)`|Remplacer 1ère occurrence|`sub(/old/, "new", $1)`|
|`match(s, r)`|Tester une regex|`match($1, /[0-9]+/)`|
|`sprintf(fmt, ...)`|Formater une chaîne|`sprintf("%05d", $1)`|

### Fonctions mathématiques

|Fonction|Description|Exemple|
|---|---|---|
|`int(x)`|Partie entière|`int(3.7)` → 3|
|`sqrt(x)`|Racine carrée|`sqrt(16)` → 4|
|`exp(x)`|Exponentielle|`exp(1)` → 2.71828|
|`log(x)`|Logarithme naturel|`log(10)`|
|`sin(x)`, `cos(x)`, `atan2(y,x)`|Trigonométrie|`sin(3.14/2)`|
|`rand()`|Nombre aléatoire [0,1[|`rand()`|
|`srand(x)`|Initialiser générateur|`srand()`|

### Exemples avec length()

```bash
# Afficher lignes de plus de 50 caractères
awk 'length($0) > 50' fichier.txt

# Longueur de chaque colonne
awk '{print $1, "longueur:", length($1)}' fichier.txt

# Filtrer par longueur de la première colonne
awk 'length($1) == 5' fichier.txt

# Trouver la ligne la plus longue
awk 'length > max {max = length; ligne = $0} 
     END {print "Ligne la plus longue:", ligne}' fichier.txt
```

### Exemples avec substr()

```bash
# Extraire les 5 premiers caractères
awk '{print substr($1, 1, 5)}' fichier.txt

# Extraire à partir du 3ème caractère
awk '{print substr($1, 3)}' fichier.txt

# Masquer les 4 derniers chiffres d'une carte bancaire
awk '{print substr($1, 1, 12) "****"}' cartes.txt

# Extraire extension de fichier
awk '{ext = substr($1, length($1)-3); print ext}' fichiers.txt
```

### Exemples avec tolower() et toupper()

```bash
# Convertir tout en majuscules
awk '{print toupper($0)}' fichier.txt

# Convertir première colonne en minuscules
awk '{print tolower($1), $2, $3}' fichier.txt

# Recherche insensible à la casse
awk 'tolower($1) == "error"' log.txt

# Capitaliser (première lettre majuscule)
awk '{print toupper(substr($1,1,1)) tolower(substr($1,2))}' fichier.txt
```

### Exemples avec gsub() et sub()

```bash
# Remplacer toutes les virgules par des points
awk '{gsub(/,/, "."); print}' fichier.txt

# Remplacer seulement la première occurrence
awk '{sub(/old/, "new"); print}' fichier.txt

# Supprimer les espaces
awk '{gsub(/ /, ""); print}' fichier.txt

# Remplacer dans une colonne spécifique
awk '{gsub(/@/, " at ", $2); print}' fichier.txt

# Compter les remplacements
awk '{n = gsub(/error/, "ERROR"); print "Remplacé", n, "fois"}' log.txt
```

### Exemples avec split()

```bash
# Découper une adresse email
awk '{split($1, parts, "@"); print "User:", parts[1], "Domain:", parts[2]}' emails.txt

# Découper une date
awk '{split($1, date, "-"); print "Année:", date[1], "Mois:", date[2]}' dates.txt

# Compter le nombre d'éléments après découpage
awk '{n = split($1, arr, ","); print n, "éléments"}' fichier.txt
```

> [!example] Exemple complet : traiter des emails Fichier `contacts.txt` :
> 
> ```
> alice@example.com
> bob@company.org
> charlie@test.net
> ```
> 
> ```bash
> awk '{
>     # Extraire nom et domaine
>     split($1, parts, "@")
>     user = parts[1]
>     domain = parts[2]
>     
>     # Capitaliser le nom
>     user = toupper(substr(user,1,1)) tolower(substr(user,2))
>     
>     # Afficher
>     print user, ":", domain
> }' contacts.txt
> # Résultat :
> # Alice : example.com
> # Bob : company.org
> # Charlie : test.net
> ```

> [!tip] Fonction match() et variables RSTART, RLENGTH Après `match()`, les variables `RSTART` et `RLENGTH` contiennent la position et la longueur de la correspondance :
> 
> ```bash
> awk '{
>     if(match($0, /[0-9]+/)) 
>         print "Trouvé nombre à position", RSTART, "longueur", RLENGTH
> }' fichier.txt
> ```

---

## 📊 Tableaux associatifs

AWK supporte les tableaux associatifs (dictionnaires) qui permettent de stocker des valeurs avec des clés arbitraires.

### Syntaxe de base

```bash
# Création et assignation
array[key] = value

# Accès
print array[key]

# Test d'existence
if (key in array) { ... }

# Suppression
delete array[key]
```

### Exemples simples

```bash
# Compter les occurrences de chaque mot
awk '{for(i=1; i<=NF; i++) count[$i]++} 
     END {for(word in count) print word, count[word]}' fichier.txt

# Compter les occurrences d'une colonne
awk '{count[$1]++} END {for(item in count) print item, count[item]}' fichier.txt

# Somme par catégorie
awk '{sum[$1] += $2} END {for(cat in sum) print cat, sum[cat]}' fichier.txt

# Stocker et afficher la dernière occurrence
awk '{last[$1] = $0} END {for(key in last) print last[key]}' fichier.txt
```

### Parcourir un tableau

```bash
# Boucle for..in (ordre non garanti)
awk '{count[$1]++} 
     END {
         for(key in count) {
             print key, ":", count[key]
         }
     }' fichier.txt

# Trier par clés (avec pipe vers sort)
awk '{count[$1]++} 
     END {
         for(key in count) 
             print key, count[key]
     }' fichier.txt | sort
```

> [!warning] Ordre des éléments L'ordre des éléments dans un tableau associatif n'est PAS garanti. Pour un ordre spécifique, il faut piper vers `sort`.

### Tableaux multidimensionnels (simulés)

```bash
# Utiliser une clé composite avec SUBSEP (séparateur par défaut)
awk '{
    key = $1 SUBSEP $2
    array[key] += $3
} END {
    for(k in array) {
        split(k, parts, SUBSEP)
        print parts[1], parts[2], ":", array[k]
    }
}' fichier.txt

# Ou avec une syntaxe plus claire
awk '{
    array[$1, $2] += $3  # AWK concatène automatiquement avec SUBSEP
} END {
    for(key in array) print key, array[key]
}' fichier.txt
```

> [!example] Exemple : statistiques par catégorie Fichier `ventes_categorie.txt` :
> 
> ```
> Électronique Laptop 899
> Électronique Souris 15
> Mobilier Chaise 150
> Électronique Clavier 45
> Mobilier Bureau 300
> ```
> 
> ```bash
> awk '{
>     categorie = $1
>     produit = $2
>     prix = $3
>     
>     # Accumuler par catégorie
>     total[categorie] += prix
>     count[categorie]++
>     
>     # Stocker les produits de chaque catégorie
>     if(produits[categorie] == "")
>         produits[categorie] = produit
>     else
>         produits[categorie] = produits[categorie] ", " produit
> } END {
>     print "=== Rapport par catégorie ==="
>     for(cat in total) {
>         print ""
>         print "Catégorie:", cat
>         print "  Produits:", produits[cat]
>         print "  Nombre:", count[cat]
>         print "  Total:", total[cat], "€"
>         print "  Moyenne:", total[cat]/count[cat], "€"
>     }
> }' ventes_categorie.txt
> ```

### Cas d'usage avancés

```bash
# Dédupliquer un fichier
awk '!seen[$0]++' fichier.txt

# Compter lignes uniques par groupe
awk '{seen[$1,$2]++} END {print length(seen)}' fichier.txt

# Top 10 des valeurs les plus fréquentes
awk '{count[$1]++} 
     END {
         for(item in count) 
             print count[item], item
     }' fichier.txt | sort -rn | head -10

# Agrégation complexe
awk '{
    # Plusieurs statistiques par clé
    sum[$1] += $2
    count[$1]++
    if($2 > max[$1]) max[$1] = $2
    if(min[$1] == "" || $2 < min[$1]) min[$1] = $2
} END {
    for(key in sum) {
        print key ":"
        print "  Total:", sum[key]
        print "  Moyenne:", sum[key]/count[key]
        print "  Min:", min[key]
        print "  Max:", max[key]
    }
}' fichier.txt
```

> [!tip] Test d'existence efficace
> 
> ```bash
> # Vérifier si une clé existe
> if (key in array) {
>     # La clé existe
> } else {
>     # La clé n'existe pas
> }
> 
> # Éviter : array[key] == "" (crée la clé si elle n'existe pas)
> ```

---

## 🖨️ printf dans AWK

La fonction `printf` permet un contrôle précis du formatage de sortie, contrairement à `print` qui ajoute automatiquement un retour à la ligne et des espaces.

### Différence entre print et printf

```bash
# print : ajoute automatiquement un retour à la ligne
awk '{print $1, $2}' fichier.txt

# printf : contrôle total du format, pas de retour à la ligne automatique
awk '{printf "%s %s\n", $1, $2}' fichier.txt
```

### Syntaxe de printf

```bash
printf "format", valeur1, valeur2, ...
```

### Spécificateurs de format

|Spécificateur|Type|Description|
|---|---|---|
|`%s`|String|Chaîne de caractères|
|`%d` ou `%i`|Integer|Entier|
|`%f`|Float|Nombre décimal|
|`%e`|Scientific|Notation scientifique|
|`%g`|General|Format le plus compact|
|`%c`|Character|Caractère unique|
|`%x`|Hex|Hexadécimal minuscule|
|`%X`|Hex|Hexadécimal majuscule|
|`%o`|Octal|Nombre octal|
|`%%`|Literal|Caractère % littéral|

### Modificateurs de format

```bash
# Largeur minimale
%10s    # Chaîne sur 10 caractères minimum (alignée à droite)
%-10s   # Chaîne sur 10 caractères minimum (alignée à gauche)

# Précision pour les nombres décimaux
%.2f    # 2 chiffres après la virgule
%8.2f   # 8 caractères total, 2 après la virgule

# Compléter avec des zéros
%05d    # Entier sur 5 chiffres, complété par des zéros (00123)

# Signe toujours affiché
%+d     # Affiche le signe + pour les nombres positifs
```

### Exemples de base

```bash
# Formatage de nombres décimaux
awk '{printf "%.2f\n", $1}' fichier.txt  # 2 décimales

# Alignement et largeur
awk '{printf "%-20s %10.2f\n", $1, $2}' fichier.txt

# Nombres avec zéros de tête
awk '{printf "%05d\n", NR}' fichier.txt  # 00001, 00002, etc.

# Plusieurs colonnes formatées
awk '{printf "%s : %d (%.1f%%)\n", $1, $2, $3}' fichier.txt

# Tableaux bien alignés
awk '{printf "|%-15s|%10s|%8.2f|\n", $1, $2, $3}' fichier.txt
```

> [!example] Exemple : créer un tableau formaté Fichier `produits.txt` :
> 
> ```
> Laptop 899.99 5
> Souris 15.5 120
> Clavier 45 30
> ```
> 
> ```bash
> awk 'BEGIN {
>     printf "+------------------+----------+----------+\n"
>     printf "| %-16s | %-8s | %-8s |\n", "Produit", "Prix", "Quantité"
>     printf "+------------------+----------+----------+\n"
> } 
> {
>     printf "| %-16s | %8.2f | %8d |\n", $1, $2, $3
> } 
> END {
>     printf "+------------------+----------+----------+\n"
> }' produits.txt
> ```
> 
> **Résultat :**
> 
> ```
> +------------------+----------+----------+
> | Produit          | Prix     | Quantité |
> +------------------+----------+----------+
> | Laptop           |   899.99 |        5 |
> | Souris           |    15.50 |      120 |
> | Clavier          |    45.00 |       30 |
> +------------------+----------+----------+
> ```

### Formatage avancé

```bash
# Notation scientifique
awk '{printf "%e\n", $1}' fichier.txt  # 1.234500e+03

# Hexadécimal
awk '{printf "0x%X\n", $1}' fichier.txt  # 0x1A2B

# Afficher un pourcentage
awk '{printf "%s: %.1f%%\n", $1, ($2/$3)*100}' fichier.txt

# Aligner des nombres à droite
awk '{printf "%10d\n", $1}' fichier.txt

# Créer un CSV formaté
awk '{printf "\"%s\",%.2f,%d\n", $1, $2, $3}' fichier.txt

# Padding avec des caractères
awk 'BEGIN {printf "%s\n", sprintf("%-20s", "test") }' # Pas direct, utiliser sprintf
```

### printf avec sprintf

`sprintf` permet de formater une chaîne sans l'afficher :

```bash
# Créer une chaîne formatée
awk '{
    formatted = sprintf("%05d-%s", NR, $1)
    print formatted
}' fichier.txt

# Combiner plusieurs formats
awk '{
    label = sprintf("[%3d]", NR)
    value = sprintf("%.2f", $2)
    print label, $1, "=", value
}' fichier.txt
```

> [!example] Exemple : rapport de ventes formaté
> 
> ```bash
> awk 'BEGIN {
>     print "╔════════════════════════════════════════╗"
>     print "║       RAPPORT DE VENTES - 2024         ║"
>     print "╠════════════════════════════════════════╣"
>     printf "║ %-20s %8s %8s ║\n", "Produit", "Prix", "Stock"
>     print "╠════════════════════════════════════════╣"
> }
> {
>     printf "║ %-20s %7.2f€ %8d ║\n", $1, $2, $3
>     total += $2 * $3
> }
> END {
>     print "╠════════════════════════════════════════╣"
>     printf "║ %-20s %16.2f€ ║\n", "TOTAL", total
>     print "╚════════════════════════════════════════╝"
> }' produits.txt
> ```

### Cas d'usage pratiques

```bash
# Générer du code SQL
awk '{printf "INSERT INTO users VALUES (%d, '\''%s'\'', '\''%s'\'');\n", NR, $1, $2}' users.txt

# Créer des commandes shell
awk '{printf "mv \"%s\" \"backup/%s\"\n", $1, $1}' fichiers.txt

# Formater des logs horodatés
awk '{printf "[%s] %s: %s\n", strftime("%Y-%m-%d %H:%M:%S"), $1, $2}' log.txt

# Créer un rapport financier
awk '{
    printf "%s", $1
    for(i=2; i<=NF; i++) 
        printf "%12.2f", $i
    printf "\n"
}' rapport.txt

# Afficher une barre de progression ASCII
awk '{
    pct = ($2/$3)*100
    bars = int(pct/2)
    printf "%s [%-50s] %.1f%%\n", $1, sprintf("%.*s", bars, "##################################################"), pct
}' progress.txt
```

> [!warning] N'oubliez pas le \n Contrairement à `print`, `printf` n'ajoute PAS de retour à la ligne automatique. Il faut toujours terminer par `\n` :
> 
> ```bash
> # Mauvais : tout sur une ligne
> awk '{printf "%s", $1}' fichier.txt
> 
> # Bon : avec retour à la ligne
> awk '{printf "%s\n", $1}' fichier.txt
> ```

> [!tip] Astuces de formatage
> 
> ```bash
> # Centrer du texte (approximativement)
> awk 'BEGIN {
>     text = "TITRE"
>     width = 50
>     padding = (width - length(text)) / 2
>     printf "%*s%s\n", padding, "", text
> }'
> 
> # Créer des séparateurs dynamiques
> awk 'BEGIN {
>     for(i=0; i<50; i++) printf "="
>     printf "\n"
> }'
> 
> # Afficher des valeurs monétaires
> awk '{printf "%\047.2f €\n", $1}'  # Avec séparateurs de milliers (selon locale)
> ```

### Combinaison printf et tableaux

```bash
# Rapport avec statistiques
awk '{
    sum[$1] += $2
    count[$1]++
} END {
    printf "%-15s %10s %10s %10s\n", "Catégorie", "Total", "Nombre", "Moyenne"
    printf "%s\n", "--------------------------------------------------------"
    for(cat in sum) {
        printf "%-15s %10.2f %10d %10.2f\n", 
               cat, sum[cat], count[cat], sum[cat]/count[cat]
    }
}' fichier.txt
```

---

## 🎓 Récapitulatif et bonnes pratiques

### Points clés à retenir

> [!info] Syntaxe AWK
> 
> - Structure : `awk 'pattern {action}' fichier`
> - `BEGIN` pour initialisation, `END` pour finalisation
> - `$0` = ligne entière, `$1, $2, ...` = colonnes
> - `NR` = numéro de ligne, `NF` = nombre de colonnes

> [!info] Manipulation de données
> 
> - Utiliser `-F` pour définir le séparateur de champs
> - Les tableaux associatifs sont puissants pour compter et grouper
> - Préférer `printf` pour un formatage précis
> - Les fonctions `gsub`, `sub`, `split` sont essentielles pour les chaînes

### Bonnes pratiques

```bash
# 1. Toujours tester le séparateur de champs
awk -F',' 'NR==1 {print NF}' fichier.csv  # Vérifier le nombre de colonnes

# 2. Ignorer les en-têtes si nécessaire
awk 'NR>1 {traitement}' fichier.csv

# 3. Gérer les lignes vides
awk 'NF>0 {print}' fichier.txt  # Ignorer les lignes vides

# 4. Toujours initialiser les variables dans BEGIN
awk 'BEGIN {total=0} {total+=$1} END {print total}' fichier.txt

# 5. Utiliser des noms de variables explicites
awk '{prix=$2; quantite=$3; total=prix*quantite; print total}' fichier.txt

# 6. Commenter les scripts complexes
awk '
# Calcul des statistiques de ventes
BEGIN {
    FS=","
    total=0
}
{
    # Ignorer la première ligne (en-tête)
    if(NR>1) {
        total += $2 * $3
    }
}
END {
    print "Total:", total
}
' ventes.csv
```

> [!warning] Pièges courants à éviter
> 
> - **Ne pas oublier `\n`** dans printf
> - **Attention à la division par zéro** : toujours tester avant
> - **Les tableaux associatifs ne sont pas ordonnés** : utiliser `| sort` si nécessaire
> - **OFS ne fonctionne qu'avec la virgule dans print** : `print $1, $2` (avec virgule)
> - **Les variables ne sont pas typées** : "10" + 5 = 15 (conversion automatique)

### Scripts AWK réutilisables

```bash
# Créer un fichier .awk pour les scripts complexes
# stats.awk
BEGIN {
    FS=","
    print "=== Analyse de données ==="
}
NR>1 {
    sum += $2
    count++
}
END {
    print "Total:", sum
    print "Moyenne:", sum/count
}

# Utilisation
awk -f stats.awk donnees.csv
```

### Performance

> [!tip] Optimisations
> 
> - AWK est très rapide pour les fichiers texte
> - Éviter les regex complexes quand possible
> - Utiliser `getline` avec parcimonie (casse le flux)
> - Pour les très gros fichiers (>1GB), considérer des outils spécialisés
> - Les tableaux associatifs consomment de la mémoire

### Quand utiliser AWK vs autres outils

|Situation|Outil recommandé|
|---|---|
|Extraction simple de colonnes|`cut` ou `awk`|
|Fichiers CSV avec calculs|**AWK**|
|Recherche de motifs|`grep`|
|Traitement ligne par ligne avec logique|**AWK**|
|Transformations complexes|`sed` ou **AWK**|
|Statistiques sur colonnes|**AWK**|
|Scripts complexes avec structures de données|Python, Perl|

---

## 📚 Exemples pratiques complets

### Exemple 1 : Analyser des logs Apache

```bash
# Format log Apache : IP - - [date] "requête" status taille
awk '{
    ip[$1]++
    status[$9]++
    total_size += $10
} END {
    print "=== Top 5 IPs ==="
    for(ip in ip) print ip, ip[ip] | "sort -rn -k2 | head -5"
    close("sort -rn -k2 | head -5")
    
    print "\n=== Codes HTTP ==="
    for(code in status) print code, status[code]
    
    print "\n=== Bande passante ==="
    print "Total:", total_size/1024/1024, "MB"
}' access.log
```

### Exemple 2 : Traiter un fichier CSV complexe

```bash
# ventes.csv : date,produit,quantite,prix_unitaire,client
awk -F',' '
BEGIN {
    OFS="\t"
    print "Produit", "Ventes Totales", "Quantité", "Prix Moyen"
    print "---------------------------------------------------"
}
NR>1 {
    produit = $2
    qte = $3
    prix = $4
    
    total[produit] += qte * prix
    quantite[produit] += qte
    count[produit]++
}
END {
    for(p in total) {
        printf "%-20s %12.2f € %8d %10.2f €\n", 
               p, total[p], quantite[p], total[p]/quantite[p]
    }
}' ventes.csv
```

### Exemple 3 : Générer un rapport HTML

```bash
awk 'BEGIN {
    print "<html><head><title>Rapport</title></head><body>"
    print "<table border=\"1\">"
    print "<tr><th>Produit</th><th>Prix</th><th>Stock</th></tr>"
}
{
    printf "<tr><td>%s</td><td>%.2f €</td><td>%d</td></tr>\n", $1, $2, $3
}
END {
    print "</table></body></html>"
}' produits.txt > rapport.html
```

---

**🎉 Félicitations !** Vous maîtrisez maintenant AWK pour le traitement de données en colonnes. AWK est un outil extrêmement puissant qui, combiné avec d'autres commandes Unix, vous permet de réaliser des traitements de données complexes en une seule ligne de commande.