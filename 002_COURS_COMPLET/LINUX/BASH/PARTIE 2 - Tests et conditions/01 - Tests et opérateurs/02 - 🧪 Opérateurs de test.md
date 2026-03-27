

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

## Introduction aux tests

Les opérateurs de test en Bash permettent d'évaluer des conditions et de prendre des décisions dans vos scripts. Ils sont essentiels pour créer des scripts intelligents et réactifs.

> [!info] Pourquoi c'est important Les tests conditionnels sont au cœur de toute logique de programmation. Sans eux, impossible de créer des scripts qui s'adaptent aux situations, vérifient l'existence de fichiers, comparent des valeurs, ou gèrent des erreurs.

---

## Les trois syntaxes de test

Bash propose **trois façons** d'effectuer des tests conditionnels. Toutes évaluent une expression et retournent un code de sortie :

- **0** (vrai/succès) si la condition est vraie
- **1** (faux/échec) si la condition est fausse

```bash
# Les trois syntaxes équivalentes
test -f fichier.txt
[ -f fichier.txt ]
[[ -f fichier.txt ]]
```

> [!tip] Code de retour Vous pouvez vérifier le résultat d'un test avec `$?` :
> 
> ```bash
> [ 5 -gt 3 ]
> echo $?  # Affiche 0 (vrai)
> ```

---

## `test` : la commande originale

### Présentation

`test` est une **commande externe** (ou builtin shell) historique, héritée des premiers shells Unix. C'est la forme la plus ancienne et portable.

### Syntaxe

```bash
test EXPRESSION
```

### Exemples

```bash
# Test d'existence de fichier
test -f /etc/passwd
if test -f /etc/passwd; then
    echo "Le fichier existe"
fi

# Comparaison numérique
test 10 -gt 5
echo $?  # Retourne 0 (vrai)

# Comparaison de chaînes
test "$USER" = "root"
```

### Caractéristiques

|Aspect|Détail|
|---|---|
|**Portabilité**|Maximum (POSIX)|
|**Lisibilité**|Faible (syntaxe verbeuse)|
|**Utilisation**|Rare aujourd'hui|
|**Type**|Commande externe ou builtin|

> [!warning] Lisibilité `test` est rarement utilisé directement car sa syntaxe est moins intuitive que `[ ]`. La forme entre crochets est préférée.

---

## `[ ]` : test classique POSIX

### Présentation

`[ ]` est un **alias syntaxique** de la commande `test`, mais plus lisible. C'est la forme standard POSIX, garantissant une portabilité maximale.

> [!info] Astuce de mémorisation `[` est littéralement une commande ! Elle s'appelle "crochet" et nécessite un espace après elle et avant `]` qui marque la fin des arguments.

### Syntaxe

```bash
[ EXPRESSION ]
```

**Règles impératives :**

- Espace obligatoire après `[`
- Espace obligatoire avant `]`
- `]` clôt la liste d'arguments

```bash
# ✅ Correct
[ -f fichier.txt ]

# ❌ Incorrect (pas d'espaces)
[-f fichier.txt]
[-f fichier.txt ]
[ -f fichier.txt]
```

### Tests de fichiers

```bash
# Existence et types
[ -e fichier ]      # Existe (n'importe quel type)
[ -f fichier ]      # Est un fichier régulier
[ -d repertoire ]   # Est un répertoire
[ -L lien ]         # Est un lien symbolique
[ -S socket ]       # Est un socket
[ -p pipe ]         # Est un pipe nommé
[ -b device ]       # Est un périphérique bloc
[ -c device ]       # Est un périphérique caractère

# Permissions
[ -r fichier ]      # Lisible
[ -w fichier ]      # Modifiable
[ -x fichier ]      # Exécutable
[ -u fichier ]      # A le bit SUID
[ -g fichier ]      # A le bit SGID
[ -k fichier ]      # A le sticky bit

# Caractéristiques
[ -s fichier ]      # Existe et n'est pas vide
[ -t fd ]           # Le descripteur fd est un terminal

# Comparaison de fichiers
[ fichier1 -nt fichier2 ]  # fichier1 plus récent que fichier2
[ fichier1 -ot fichier2 ]  # fichier1 plus ancien que fichier2
[ fichier1 -ef fichier2 ]  # Même fichier (hardlinks)
```

### Tests de chaînes

```bash
# Existence et longueur
[ -z "$chaine" ]    # Chaîne vide (zero length)
[ -n "$chaine" ]    # Chaîne non vide (non-zero length)
[ "$chaine" ]       # Équivalent à -n (non vide)

# Comparaison
[ "$a" = "$b" ]     # Égalité (POSIX préfère = à ==)
[ "$a" != "$b" ]    # Différence
[ "$a" \< "$b" ]    # Ordre lexicographique (< doit être échappé)
[ "$a" \> "$b" ]    # Ordre lexicographique (> doit être échappé)
```

> [!warning] Guillemets obligatoires Toujours mettre les variables entre guillemets avec `[ ]` pour éviter les erreurs si la variable est vide :
> 
> ```bash
> var=""
> [ $var = "test" ]   # ❌ Erreur : [ = "test" ]
> [ "$var" = "test" ] # ✅ Correct : [ "" = "test" ]
> ```

### Tests numériques

```bash
[ "$a" -eq "$b" ]   # Égal (equal)
[ "$a" -ne "$b" ]   # Différent (not equal)
[ "$a" -lt "$b" ]   # Inférieur (less than)
[ "$a" -le "$b" ]   # Inférieur ou égal (less or equal)
[ "$a" -gt "$b" ]   # Supérieur (greater than)
[ "$a" -ge "$b" ]   # Supérieur ou égal (greater or equal)
```

```bash
# Exemple pratique
age=25
if [ "$age" -ge 18 ]; then
    echo "Majeur"
fi
```

### Opérateurs logiques

```bash
# ET logique
[ "$a" -gt 5 ] && [ "$a" -lt 10 ]      # Méthode recommandée
[ "$a" -gt 5 -a "$a" -lt 10 ]          # Forme compacte (déconseillée)

# OU logique
[ "$a" -eq 5 ] || [ "$a" -eq 10 ]      # Méthode recommandée
[ "$a" -eq 5 -o "$a" -eq 10 ]          # Forme compacte (déconseillée)

# Négation
[ ! -f fichier ]    # Le fichier n'existe pas
! [ -f fichier ]    # Équivalent mais moins lisible
```

> [!tip] Opérateurs logiques Préférez `&&` et `||` entre plusieurs tests plutôt que `-a` et `-o` pour une meilleure lisibilité et éviter les ambiguïtés.

### Parenthèses pour le groupement

```bash
# Groupement avec -a et -o (nécessite des échappements)
[ \( "$a" -gt 5 -a "$a" -lt 10 \) -o "$b" = "test" ]

# Mieux : utiliser && et ||
[ "$a" -gt 5 ] && [ "$a" -lt 10 ] || [ "$b" = "test" ]
```

---

## `[[ ]]` : test étendu Bash

### Présentation

`[[ ]]` est un **mot-clé du shell Bash** (pas une commande), offrant des fonctionnalités avancées et une syntaxe plus sûre. C'est l'évolution moderne de `[ ]`.

> [!info] Mot-clé vs Commande Contrairement à `[ ]`, `[[ ]]` est directement interprété par Bash comme une structure du langage, ce qui lui permet d'offrir plus de fonctionnalités et une meilleure gestion des variables.

### Syntaxe

```bash
[[ EXPRESSION ]]
```

### Avantages principaux

#### 1. Pas besoin de guillemets pour les variables

```bash
var=""
# Avec [ ]
[ "$var" = "test" ]  # Guillemets obligatoires

# Avec [[ ]]
[[ $var = "test" ]]  # Guillemets optionnels (mais recommandés pour la clarté)
```

> [!tip] Sécurité automatique `[[ ]]` gère automatiquement les variables vides et les espaces, vous protégeant de nombreuses erreurs courantes.

#### 2. Correspondance de motifs (globbing)

```bash
# Pattern matching avec =
[[ "$fichier" = *.txt ]]        # Termine par .txt
[[ "$fichier" = log_* ]]        # Commence par log_
[[ "$nom" = [A-Z]* ]]           # Commence par une majuscule

# Exemple pratique
if [[ "$fichier" = *.sh ]]; then
    echo "C'est un script shell"
fi
```

#### 3. Expressions régulières

```bash
# Opérateur =~ pour les regex
[[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]

# Validation d'un numéro
[[ "$numero" =~ ^[0-9]+$ ]]

# Capture de groupes
if [[ "$texte" =~ ([0-9]{4})-([0-9]{2})-([0-9]{2}) ]]; then
    annee="${BASH_REMATCH[1]}"
    mois="${BASH_REMATCH[2]}"
    jour="${BASH_REMATCH[3]}"
fi
```

> [!example] Validation d'email
> 
> ```bash
> email="user@example.com"
> if [[ $email =~ ^[a-z]+@[a-z]+\.[a-z]{2,}$ ]]; then
>     echo "Email valide"
> else
>     echo "Email invalide"
> fi
> ```

#### 4. Opérateurs logiques intégrés

```bash
# ET logique avec &&
[[ $a -gt 5 && $a -lt 10 ]]

# OU logique avec ||
[[ $a -eq 5 || $a -eq 10 ]]

# Négation avec !
[[ ! -f fichier ]]

# Groupement avec des parenthèses (sans échappement)
[[ ($a -gt 5 && $a -lt 10) || $b = "test" ]]
```

#### 5. Comparaison de chaînes améliorée

```bash
# Opérateurs < et > sans échappement
[[ "$a" < "$b" ]]   # Ordre lexicographique
[[ "$a" > "$b" ]]   # Pas besoin de \< ou \>

# Comparaison avec ==
[[ "$a" == "$b" ]]  # Équivalent à =, mais plus familier pour les programmeurs
```

### Tous les tests disponibles

```bash
# Tests de fichiers (identiques à [ ])
[[ -e fichier ]]    # Existe
[[ -f fichier ]]    # Fichier régulier
[[ -d repertoire ]] # Répertoire
[[ -L lien ]]       # Lien symbolique
[[ -r fichier ]]    # Lisible
[[ -w fichier ]]    # Modifiable
[[ -x fichier ]]    # Exécutable
[[ -s fichier ]]    # Non vide

# Tests de chaînes
[[ -z $chaine ]]    # Vide
[[ -n $chaine ]]    # Non vide
[[ $a = $b ]]       # Égalité (peut être un motif)
[[ $a == $b ]]      # Égalité (alias de =)
[[ $a != $b ]]      # Différence
[[ $a < $b ]]       # Inférieur (lexicographique)
[[ $a > $b ]]       # Supérieur (lexicographique)

# Tests numériques (identiques à [ ])
[[ $a -eq $b ]]     # Égal
[[ $a -ne $b ]]     # Différent
[[ $a -lt $b ]]     # Inférieur
[[ $a -le $b ]]     # Inférieur ou égal
[[ $a -gt $b ]]     # Supérieur
[[ $a -ge $b ]]     # Supérieur ou égal
```

### Exemples complets

```bash
#!/bin/bash

# Validation d'un fichier de configuration
config_file="app.conf"

if [[ -f $config_file && -r $config_file && -s $config_file ]]; then
    echo "Fichier de config valide"
fi

# Pattern matching pour filtrer des fichiers
for fichier in *; do
    if [[ $fichier == *.log || $fichier == *.tmp ]]; then
        echo "Fichier temporaire : $fichier"
    fi
done

# Validation d'entrée utilisateur
read -p "Entrez votre âge : " age
if [[ $age =~ ^[0-9]+$ && $age -ge 18 && $age -le 120 ]]; then
    echo "Âge valide : $age"
else
    echo "Âge invalide"
fi

# Test complexe avec groupement
if [[ ($USER == "root" || $UID -eq 0) && -w /etc/passwd ]]; then
    echo "Vous avez les droits d'administration"
fi
```

---

## Différences entre `[ ]` et `[[ ]]`

### Tableau comparatif

|Fonctionnalité|`[ ]`|`[[ ]]`|
|---|---|---|
|**Type**|Commande (builtin)|Mot-clé du shell|
|**Portabilité**|POSIX (sh, bash, dash, etc.)|Bash uniquement (+ zsh, ksh)|
|**Guillemets variables**|Obligatoires|Optionnels|
|**Pattern matching**|Non|Oui (`*.txt`)|
|**Expressions régulières**|Non|Oui (`=~`)|
|**Opérateurs logiques**|`-a`, `-o` (ou `&&`, `\|` entre tests)|`&&`, `\|` intégrés|
|**Comparaison chaînes**|`\<`, `\>` échappés|`<`, `>` sans échappement|
|**Groupement**|`\(` `\)` échappés|`(` `)` sans échappement|
|**Sécurité**|Erreurs possibles si variables vides|Gestion automatique|
|**Performance**|Légèrement plus lent|Plus rapide|

### Exemples côte à côte

```bash
# Guillemets
[ "$var" = "test" ]     # Obligatoire
[[ $var = "test" ]]     # Optionnel

# Pattern matching
# Impossible avec [ ]
[[ $fichier = *.txt ]]  # Possible avec [[ ]]

# Expressions régulières
# Impossible avec [ ]
[[ $email =~ ^.+@.+$ ]] # Possible avec [[ ]]

# Opérateurs logiques
[ "$a" -gt 5 ] && [ "$a" -lt 10 ]  # Deux tests séparés
[[ $a -gt 5 && $a -lt 10 ]]        # Un seul test

# Comparaison lexicographique
[ "$a" \< "$b" ]        # Échappement nécessaire
[[ $a < $b ]]           # Pas d'échappement

# Groupement
[ \( "$a" -gt 5 -a "$b" -lt 10 \) ] # Échappements
[[ ($a -gt 5 && $b -lt 10) ]]       # Parenthèses simples
```

### Cas où `[ ]` échoue mais `[[ ]]` fonctionne

```bash
# Variable vide
var=""
[ $var = "test" ]      # ❌ Erreur : [ = "test" ]
[[ $var = "test" ]]    # ✅ Fonctionne

# Variable avec espaces
var="hello world"
[ $var = "hello world" ]    # ❌ Erreur : trop d'arguments
[[ $var = "hello world" ]]  # ✅ Fonctionne

# Pattern matching
[ $fichier = *.txt ]   # ❌ Compare littéralement avec "*.txt"
[[ $fichier = *.txt ]] # ✅ Vérifie si se termine par .txt
```

---

## Quand utiliser chaque syntaxe

### Utilisez `[ ]` quand :

✅ **Vous écrivez un script portable** devant fonctionner sur tous les systèmes POSIX (sh, dash, busybox)

```bash
#!/bin/sh
# Script POSIX strict
if [ -f /etc/passwd ]; then
    echo "Système Unix standard"
fi
```

✅ **Vous écrivez des scripts système** qui pourraient être exécutés dans des environnements minimalistes

✅ **Les tests sont simples** et ne nécessitent pas de fonctionnalités avancées

### Utilisez `[[ ]]` quand :

✅ **Vous ciblez spécifiquement Bash** (pas de contrainte de portabilité)

```bash
#!/bin/bash
# Script Bash moderne
if [[ -f /etc/passwd && $UID -eq 0 ]]; then
    echo "Root avec fichier passwd"
fi
```

✅ **Vous utilisez pattern matching ou regex**

```bash
if [[ $fichier = *.log ]]; then
    echo "Fichier de log"
fi
```

✅ **Vous manipulez des variables qui peuvent être vides ou contenir des espaces**

✅ **Vous écrivez des conditions complexes** avec plusieurs opérateurs logiques

✅ **Vous voulez une meilleure lisibilité** et moins de pièges

### Évitez `test` directement

❌ La forme `test` est rarement utilisée aujourd'hui car moins lisible que `[ ]`

```bash
# Moins lisible
test -f fichier && echo "existe"

# Plus lisible
[ -f fichier ] && echo "existe"
```

### Recommandation générale

> [!tip] Conseil moderne **Pour les nouveaux scripts Bash**, préférez `[[ ]]` par défaut. C'est plus sûr, plus puissant, et la portabilité n'est plus un problème majeur aujourd'hui où Bash est omniprésent.
> 
> **Pour les scripts système ou embarqués**, utilisez `[ ]` pour garantir la compatibilité POSIX.

---

## Pièges courants

### 1. Oublier les espaces avec `[ ]`

```bash
# ❌ Erreur commune
[$var = "test"]
[ $var="test" ]

# ✅ Correct
[ "$var" = "test" ]
```

> [!warning] Les espaces sont obligatoires `[` est une commande, donc elle nécessite des espaces pour séparer les arguments, exactement comme `ls -l fichier`.

### 2. Variables non quotées avec `[ ]`

```bash
var="hello world"

# ❌ Erreur : trop d'arguments
[ $var = "hello world" ]

# ✅ Correct
[ "$var" = "hello world" ]

# ✅ Avec [[ ]], optionnel mais recommandé
[[ $var = "hello world" ]]
```

### 3. Confondre `=` et `-eq`

```bash
# Comparaison de chaînes
[ "$a" = "$b" ]      # ✅ Correct
[ "$a" -eq "$b" ]    # ❌ Erreur si a et b ne sont pas des nombres

# Comparaison de nombres
[ "$num1" -eq "$num2" ]  # ✅ Correct
[ "$num1" = "$num2" ]    # ⚠️ Compare comme des chaînes ("10" = "010" → faux)
```

> [!warning] Type de comparaison
> 
> - `=`, `!=`, `<`, `>` : comparaison **lexicographique** (chaînes)
> - `-eq`, `-ne`, `-lt`, `-gt` : comparaison **numérique**

### 4. Pattern matching involontaire avec `[[ ]]`

```bash
var="test.txt"
pattern="*.txt"

# Avec [[ ]], = fait du pattern matching
[[ $var = $pattern ]]   # ✅ Vrai (test.txt correspond à *.txt)

# Pour comparer littéralement, utiliser des guillemets
[[ $var = "$pattern" ]] # ❌ Faux (test.txt ≠ *.txt littéralement)
```

### 5. Oublier l'échappement avec `[ ]`

```bash
# ❌ Erreur : < est une redirection
[ "$a" < "$b" ]

# ✅ Correct : échapper le symbole
[ "$a" \< "$b" ]

# ✅ Avec [[ ]], pas d'échappement nécessaire
[[ $a < $b ]]
```

### 6. Confusion entre `&&` et `-a`

```bash
# Avec [ ]
[ "$a" -gt 5 -a "$a" -lt 10 ]    # ⚠️ Fonctionne mais déconseillé
[ "$a" -gt 5 ] && [ "$a" -lt 10 ] # ✅ Préféré (plus clair)

# Avec [[ ]]
[[ $a -gt 5 && $a -lt 10 ]]      # ✅ Syntaxe intégrée
```

### 7. Tester l'existence ET les permissions

```bash
# ❌ Erreur : si le fichier n'existe pas, -r échoue avec une erreur
[ -r /chemin/fichier ]

# ✅ Correct : vérifier l'existence d'abord
[ -e /chemin/fichier ] && [ -r /chemin/fichier ]

# ✅ Ou avec [[ ]]
[[ -e /chemin/fichier && -r /chemin/fichier ]]
```

---

## Bonnes pratiques

### 1. Toujours quoter les variables avec `[ ]`

```bash
# ✅ Toujours entre guillemets
[ "$var" = "valeur" ]
[ -n "$var" ]
[ "$var1" != "$var2" ]
```

### 2. Utiliser les bons opérateurs selon le type

```bash
# Pour les chaînes
[[ $string1 = $string2 ]]
[[ $string1 != $string2 ]]

# Pour les nombres
[[ $num1 -eq $num2 ]]
[[ $num1 -gt $num2 ]]
```

### 3. Privilégier `&&` et `||` pour combiner des tests

```bash
# ✅ Lisible et recommandé
[ -f fichier ] && [ -r fichier ]

# ⚠️ Fonctionne mais moins clair
[ -f fichier -a -r fichier ]

# ✅ Avec [[ ]], syntaxe intégrée
[[ -f fichier && -r fichier ]]
```

### 4. Tester l'existence avant les autres propriétés

```bash
# ✅ Vérifier l'existence d'abord
if [ -e "$fichier" ]; then
    if [ -r "$fichier" ]; then
        cat "$fichier"
    fi
fi

# ✅ Version compacte avec [[ ]]
[[ -e $fichier && -r $fichier ]] && cat "$fichier"
```

### 5. Préférer `[[ ]]` pour les regex et patterns

```bash
# ✅ Avec [[ ]] pour pattern matching
if [[ $fichier = *.sh ]]; then
    bash "$fichier"
fi

# ✅ Avec [[ ]] pour les regex
if [[ $email =~ ^[a-z]+@[a-z]+\.[a-z]{2,}$ ]]; then
    echo "Email valide"
fi
```

### 6. Documenter les tests complexes

```bash
# ✅ Ajouter des commentaires pour la clarté
# Vérifie que l'utilisateur est root ET que le fichier existe et est modifiable
if [[ $UID -eq 0 && -f /etc/passwd && -w /etc/passwd ]]; then
    echo "Modification autorisée"
fi
```

### 7. Utiliser des variables pour les tests répétés

```bash
# ✅ Éviter la répétition
log_dir="/var/log/myapp"
if [[ -d $log_dir && -w $log_dir ]]; then
    echo "Log dans $log_dir"
fi
```

### 8. Gérer les cas d'erreur explicitement

```bash
# ✅ Vérifier les conditions d'erreur en premier
if [[ ! -f $config_file ]]; then
    echo "Erreur : fichier de configuration manquant" >&2
    exit 1
fi

if [[ ! -r $config_file ]]; then
    echo "Erreur : impossible de lire le fichier" >&2
    exit 1
fi

# Continuer le traitement normal
source "$config_file"
```

### 9. Utiliser `set -u` pour détecter les variables non définies

```bash
#!/bin/bash
set -u  # Erreur si variable non définie

# ✅ Cette approche force à déclarer les variables
config_file="${1:-/etc/default.conf}"  # Valeur par défaut

if [[ -f $config_file ]]; then
    echo "Utilisation de : $config_file"
fi
```

### 10. Préférer la clarté à la concision

```bash
# ⚠️ Concis mais cryptique
[[ -f $1 && -r $1 ]] && cat $1 || echo "Erreur"

# ✅ Plus verbeux mais clair
if [[ -f "$1" && -r "$1" ]]; then
    cat "$1"
else
    echo "Erreur : fichier inaccessible"
fi
```

---

## 🎯 Résumé

|Syntaxe|Quand l'utiliser|Points clés|
|---|---|---|
|`test`|Jamais (obsolète)|Forme historique, peu lisible|
|`[ ]`|Scripts portables POSIX|Guillemets obligatoires, échappements nécessaires|
|`[[ ]]`|Scripts Bash modernes|Pattern matching, regex, plus sûr, plus puissant|

> [!tip] Conseil final Dans un contexte Bash moderne, **utilisez `[[ ]]` par défaut**. C'est plus sûr, plus expressif et moins sujet aux erreurs. Réservez `[ ]` aux rares cas où la portabilité POSIX stricte est critique.