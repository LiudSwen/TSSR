

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

## 🎯 Introduction au quotage

Le quotage en Bash est l'un des aspects les plus critiques pour écrire des scripts robustes et sécurisés. Un mauvais quotage est la source de nombreux bugs subtils et de failles de sécurité.

> [!info] Pourquoi le quotage est crucial En Bash, les espaces, tabulations et retours à la ligne sont des **séparateurs de mots**. Sans quotage approprié, une variable contenant `fichier important.txt` sera interprétée comme deux arguments distincts : `fichier` et `important.txt`.

### Les trois types de quotage

|Type|Syntaxe|Interprétation|Usage principal|
|---|---|---|---|
|**Guillemets doubles**|`"texte"`|Partielle (variables, commandes)|Usage général|
|**Guillemets simples**|`'texte'`|Littérale (aucune expansion)|Texte brut, expressions régulières|
|**Backslash**|`\caractère`|Échappe un seul caractère|Caractères spéciaux isolés|

---

## 📝 Guillemets doubles `" "`

Les guillemets doubles permettent l'**interprétation** de certains éléments tout en protégeant les espaces et la plupart des caractères spéciaux.

### Ce qui est interprété dans `" "`

```bash
# Variables
nom="Alice"
echo "Bonjour $nom"  # Affiche: Bonjour Alice

# Substitution de commande
echo "Nous sommes le $(date +%Y-%m-%d)"  # Affiche la date

# Expressions arithmétiques
nb=5
echo "Le résultat est $((nb * 2))"  # Affiche: Le résultat est 10

# Échappement avec backslash
echo "Prix: \$50"  # Affiche: Prix: $50
```

### Ce qui est protégé dans `" "`

```bash
# Les espaces sont préservés
fichier="mon document.txt"
touch "$fichier"  # Crée UN fichier nommé "mon document.txt"

# Les globbing patterns ne sont PAS expansés
echo "*.txt"  # Affiche littéralement: *.txt

# La plupart des caractères spéciaux
echo "Prix: 100€ & taxes incluses!"  # Fonctionne correctement
```

> [!tip] Règle d'or **Quotez toujours vos variables avec des guillemets doubles** : `"$variable"`. C'est la pratique par défaut en Bash.

### Caractères spéciaux dans `" "`

Seuls ces caractères gardent leur signification spéciale dans les guillemets doubles :

- `$` : expansion de variable
- `` ` `` : substitution de commande (ancienne syntaxe)
- `\` : échappement
- `!` : expansion d'historique (si activée en mode interactif)
- `"` : fin du guillemet (doit être échappé : `\"`)

```bash
# Échappement des caractères spéciaux
echo "Il a dit \"Bonjour\""  # Affiche: Il a dit "Bonjour"
echo "Le prix est \$100"     # Affiche: Le prix est $100
echo "Backslash: \\"         # Affiche: Backslash: \
```

---

## 🔒 Guillemets simples `' '`

Les guillemets simples créent une chaîne **complètement littérale**. Aucune interprétation n'a lieu.

### Comportement des guillemets simples

```bash
# Rien n'est interprété
nom="Alice"
echo 'Bonjour $nom'  # Affiche littéralement: Bonjour $nom

# Même les backslashes sont littéraux
echo 'Chemin: C:\Users\Alice'  # Affiche: Chemin: C:\Users\Alice

# Les caractères spéciaux sont tous protégés
echo '`date`, $(whoami), $HOME, *.txt'  # Affiche tout littéralement
```

> [!warning] Limitation importante Il est **impossible** d'inclure un guillemet simple à l'intérieur de guillemets simples, même avec un backslash. Pour inclure un guillemet simple, vous devez fermer les guillemets, échapper le caractère, puis rouvrir.

```bash
# ❌ Ceci ne fonctionne pas
echo 'C\'est impossible'

# ✅ Solutions possibles
echo 'C'"'"'est possible'    # Ferme, échappe, rouvre
echo "C'est plus simple"     # Utilisez des guillemets doubles
```

### Quand utiliser les guillemets simples

```bash
# 1. Expressions régulières
grep 'https\?://[a-z]+\.[a-z]+' fichier.txt

# 2. Texte contenant beaucoup de caractères spéciaux
msg='Le prix est $50, les taxes ≈ 10% (environ)'
echo "$msg"

# 3. Code ou commandes à passer littéralement
ssh user@host 'echo $HOSTNAME'  # Affiche le hostname distant, pas local

# 4. Heredocs avec guillemets
cat << 'FIN'
Les variables comme $HOME ne seront pas expansées
FIN
```

---

## 🎯 Quand utiliser chaque type

### Arbre de décision

```bash
# Ai-je besoin d'utiliser des variables ou des commandes ?
#
# OUI → Guillemets doubles " "
# NON → Guillemets simples ' '
```

### Tableau comparatif détaillé

|Situation|Type recommandé|Exemple|
|---|---|---|
|Variables contenant des espaces|`" "`|`cp "$fichier_source" "$destination"`|
|Texte statique sans variables|`' '`|`echo 'Bienvenue sur le système'`|
|Variables avec texte mixte|`" "`|`echo "Utilisateur: $USER, Heure: $(date)"`|
|Expressions régulières|`' '`|`sed 's/[0-9]\+/NUM/g' file`|
|Chemins Windows|`' '`|`path='C:\Users\Alice\Documents'`|
|Messages d'erreur|`" "`|`echo "Erreur: fichier $file introuvable" >&2`|
|JSON ou XML brut|`' '`|`json='{"name": "$USER", "id": 123}'`|
|Code SQL|`' '`|`sql='SELECT * FROM users WHERE id = $id'`|

### Exemples pratiques

```bash
#!/bin/bash

# ✅ Bon : guillemets doubles pour les variables
nom_fichier="rapport final.pdf"
cp "$nom_fichier" /backup/

# ✅ Bon : guillemets simples pour texte statique
echo 'Démarrage du traitement...'

# ✅ Bon : guillemets doubles avec expansion
echo "Traitement de $nom_fichier terminé à $(date)"

# ❌ Mauvais : pas de guillemets
cp $nom_fichier /backup/  # Échouera si espaces dans le nom

# ❌ Mauvais : guillemets simples avec variable
echo 'Fichier traité: $nom_fichier'  # Affiche littéralement $nom_fichier
```

---

## 🛡️ Protection des espaces et caractères spéciaux

### Le problème du word splitting

Sans quotage, Bash découpe les valeurs sur les espaces, tabulations et retours à la ligne (définis par `$IFS`).

```bash
# Démonstration du problème
fichier="mon document important.txt"

# ❌ Sans guillemets : ERREUR
touch $fichier
# Bash interprète cela comme : touch mon document important.txt
# Crée 3 fichiers : "mon", "document", "important.txt"

# ✅ Avec guillemets : CORRECT
touch "$fichier"
# Crée 1 fichier : "mon document important.txt"
```

### Caractères nécessitant une protection

```bash
# Espaces et tabulations
dossier="Mes Documents"
cd "$dossier"  # Nécessite des guillemets

# Caractères glob : * ? [ ]
pattern="*.txt"
echo "$pattern"  # Affiche: *.txt (littéral)
echo $pattern    # Affiche: liste de tous les fichiers .txt

# Caractères shell spéciaux : & | ; < > ( ) $ ` \ " ' 
texte="Prix: $100 & taxes"
echo "$texte"  # Fonctionne correctement

# Retours à la ligne
message="Ligne 1
Ligne 2
Ligne 3"
echo "$message"  # Préserve les retours à la ligne
```

> [!example] Cas réel : traitement de fichiers
> 
> ```bash
> # Script robuste pour traiter des fichiers
> for fichier in *.txt; do
>     # Toujours quoter dans les opérations
>     if [[ -f "$fichier" ]]; then
>         taille=$(stat -f%z "$fichier" 2>/dev/null || stat -c%s "$fichier")
>         echo "Traitement de \"$fichier\" ($taille octets)"
>         cp "$fichier" "/backup/$fichier"
>     fi
> done
> ```

### Protection dans les tests

```bash
# Toujours quoter dans les tests
variable="valeur avec espaces"

# ❌ Dangereux
if [ $variable = "test" ]; then  # Erreur de syntaxe
    echo "ok"
fi

# ✅ Correct
if [ "$variable" = "test" ]; then
    echo "ok"
fi

# ✅ Encore mieux : [[ ]] est plus permissif
if [[ $variable = "test" ]]; then  # Fonctionne même sans guillemets
    echo "ok"
fi
```

---

## 🔄 Quotage de `"$@"` vs `$@`

C'est l'une des distinctions les plus importantes et subtiles du quotage en Bash.

### Comportement de `$@` et `$*`

|Variable|Sans guillemets|Avec guillemets|
|---|---|---|
|`$@`|Arguments séparés par espaces|Chaque argument préservé individuellement|
|`$*`|Arguments séparés par espaces|Tous les arguments en une seule chaîne|
|`"$@"`|—|**Arguments préservés individuellement** ✅|
|`"$*"`|—|**Tous les arguments concaténés** (séparés par 1er car de IFS)|

### Démonstration avec un script

```bash
#!/bin/bash
# fichier: demo_args.sh

echo "Nombre d'arguments reçus: $#"
echo ""

echo "=== Affichage avec \$@ (sans guillemets) ==="
for arg in $@; do
    echo "  - [$arg]"
done

echo ""
echo "=== Affichage avec \"\$@\" (avec guillemets) ==="
for arg in "$@"; do
    echo "  - [$arg]"
done

echo ""
echo "=== Affichage avec \"\$*\" (avec guillemets) ==="
for arg in "$*"; do
    echo "  - [$arg]"
done
```

Exécution :

```bash
$ ./demo_args.sh "fichier 1.txt" "fichier 2.txt" "dossier avec espaces"

Nombre d'arguments reçus: 3

=== Affichage avec $@ (sans guillemets) ===
  - [fichier]
  - [1.txt]
  - [fichier]
  - [2.txt]
  - [dossier]
  - [avec]
  - [espaces]

=== Affichage avec "$@" (avec guillemets) ===
  - [fichier 1.txt]
  - [fichier 2.txt]
  - [dossier avec espaces]

=== Affichage avec "$*" (avec guillemets) ===
  - [fichier 1.txt fichier 2.txt dossier avec espaces]
```

> [!tip] Règle absolue **Utilisez toujours `"$@"` pour préserver les arguments** lorsque vous transmettez des paramètres à une autre commande ou fonction.

### Cas d'usage pratiques

```bash
# ✅ Transmission correcte des arguments à une commande
mes_arguments() {
    echo "Appel de la commande avec les arguments préservés"
    ma_commande "$@"  # Chaque argument reste intact
}

# ✅ Wrapper de commande
my_grep() {
    grep --color=auto "$@"  # Transmet tous les arguments à grep
}

# ❌ Mauvaise pratique
mauvais_wrapper() {
    ma_commande $@  # Les arguments avec espaces seront divisés
}

# ✅ Ajout d'arguments avant transmission
avec_options() {
    ma_commande --verbose --format=json "$@"
}

# Exemple d'utilisation
avec_options "fichier 1.txt" "fichier 2.txt"
# Équivaut à : ma_commande --verbose --format=json "fichier 1.txt" "fichier 2.txt"
```

### Cas spécial : concaténation d'arguments

```bash
# Quand utiliser "$*" : créer une seule chaîne
enregistrer_log() {
    local message="$*"  # Concatène tous les arguments
    echo "$(date): $message" >> app.log
}

enregistrer_log "Erreur" "dans" "le" "module" "X"
# Écrit : "2024-01-15: Erreur dans le module X"

# Versus avec "$@" : chaque argument séparé
enregistrer_liste() {
    for item in "$@"; do
        echo "- $item" >> liste.txt
    done
}

enregistrer_liste "Erreur" "dans" "le" "module" "X"
# Écrit 5 lignes séparées
```

---

## 🔍 Expansion dans guillemets

### Ce qui est expansé dans `" "`

Les guillemets doubles permettent plusieurs types d'expansions :

#### 1. Expansion de variables

```bash
nom="Alice"
age=30

# Expansion simple
echo "Nom: $nom"  # Nom: Alice

# Expansion avec accolades (recommandé)
echo "Fichier: ${nom}_report.txt"  # Fichier: Alice_report.txt

# Expansion avec modifications
echo "Majuscules: ${nom^^}"  # Majuscules: ALICE
echo "Défaut: ${inexistante:-valeur par défaut}"  # Défaut: valeur par défaut
```

#### 2. Substitution de commande

```bash
# Syntaxe moderne $(commande)
echo "Date du jour: $(date +%Y-%m-%d)"
echo "Utilisateur: $(whoami)"
echo "Répertoire: $(pwd)"

# Imbrication possible
echo "Fichiers .txt: $(ls $(find . -name "*.txt") 2>/dev/null)"

# Ancienne syntaxe `commande` (déconseillée)
echo "Date: `date`"  # Fonctionne mais moins lisible
```

#### 3. Expansion arithmétique

```bash
a=10
b=5

echo "Somme: $((a + b))"           # Somme: 15
echo "Multiplication: $((a * b))"  # Multiplication: 50
echo "Division: $((a / b))"        # Division: 2
echo "Modulo: $((a % b))"          # Modulo: 0

# Expressions complexes
echo "Résultat: $(( (a + b) * 2 - 3 ))"  # Résultat: 27
```

#### 4. Expansion de paramètres avancée

```bash
fichier="/path/to/document.txt"

# Manipulation de chemins
echo "Répertoire: ${fichier%/*}"     # Répertoire: /path/to
echo "Nom: ${fichier##*/}"           # Nom: document.txt
echo "Sans extension: ${fichier%.txt}"  # Sans extension: /path/to/document

# Remplacement
texte="Je programme en bash et j'aime bash"
echo "${texte/bash/Python}"           # Remplace la première occurrence
echo "${texte//bash/Python}"          # Remplace toutes les occurrences

# Longueur
echo "Longueur: ${#texte}"            # Nombre de caractères
```

### Ce qui N'est PAS expansé dans `" "`

```bash
# ❌ Globbing (patterns) ne sont PAS expansés
echo "Fichiers: *.txt"  # Affiche littéralement: Fichiers: *.txt

# ❌ Brace expansion ne fonctionne PAS
echo "Nombres: {1..5}"  # Affiche littéralement: Nombres: {1..5}

# ❌ Tilde expansion ne fonctionne PAS
echo "Home: ~"          # Affiche littéralement: Home: ~
echo "Home: $HOME"      # ✅ Affiche: Home: /home/user
```

> [!warning] Attention aux expansions imbriquées Soyez prudent avec les expansions dans des expansions :
> 
> ```bash
> # Peut causer des problèmes si $commande contient des caractères spéciaux
> resultat=$(eval "$commande")  # Dangereux!
> 
> # Préférez des approches plus sûres
> resultat=$($commande)          # Plus sûr
> ```

---

## ⚠️ Pièges courants

### Piège 1 : Oublier de quoter les variables

```bash
# ❌ Bug classique
fichier="mon fichier.txt"
rm $fichier  # Tente de supprimer "mon" ET "fichier.txt"

# ✅ Correct
rm "$fichier"
```

### Piège 2 : Variables vides ou non définies

```bash
# ❌ Problème avec variable vide
dossier=""
cd $dossier  # cd sans argument → retourne à $HOME !

# ✅ Solution
cd "$dossier"  # cd "" → erreur claire

# ✅ Avec test
if [[ -n "$dossier" ]]; then
    cd "$dossier"
fi
```

### Piège 3 : Confusion entre `$@` et `$*`

```bash
# ❌ Perte d'information
transferer() {
    ssh server "process $*"  # Les guillemets sont perdus côté serveur
}

transferer "fichier 1.txt" "fichier 2.txt"
# Le serveur reçoit : process fichier 1.txt fichier 2.txt (4 arguments)

# ✅ Préservation correcte
transferer() {
    ssh server "$(printf '%q ' "$@")"  # Échappe chaque argument
}
```

### Piège 4 : Globbing non intentionnel

```bash
# ❌ Problème
pattern="*.txt"
rm $pattern  # Supprime tous les fichiers .txt du répertoire !

# ✅ Solution
rm "$pattern"  # Erreur : fichier "*.txt" introuvable (comportement attendu)

# Si vous VOULEZ le globbing
shopt -s nullglob  # Évite l'erreur si aucun fichier ne correspond
rm $pattern        # OK dans ce contexte
```

### Piège 5 : Oublier les guillemets dans les tests

```bash
# ❌ Erreur de syntaxe
var="valeur avec espaces"
if [ $var = "test" ]; then  # Erreur : trop d'arguments
    echo "égal"
fi

# ✅ Correct
if [ "$var" = "test" ]; then
    echo "égal"
fi

# ✅ Ou utilisez [[ ]]
if [[ $var = "test" ]]; then  # Plus tolérant
    echo "égal"
fi
```

### Piège 6 : Échappement dans les guillemets simples

```bash
# ❌ Impossible d'échapper dans ' '
echo 'C\'est impossible'  # Erreur de syntaxe

# ✅ Solutions
echo 'C'"'"'est possible'  # Ferme, échappe, rouvre
echo "C'est facile"        # Guillemets doubles
```

### Piège 7 : Substitution de commande et espaces

```bash
# ❌ Problème
fichiers=$(find . -name "*.txt")
for f in $fichiers; do  # Les noms avec espaces sont divisés
    echo "Traitement de $f"
done

# ✅ Solution 1 : quoter
for f in "$fichiers"; do  # Mais traite tout comme un seul argument
    echo "Traitement de $f"
done

# ✅ Solution 2 : lecture correcte (meilleure approche)
while IFS= read -r f; do
    echo "Traitement de $f"
done < <(find . -name "*.txt")

# ✅ Solution 3 : tableau
mapfile -t fichiers < <(find . -name "*.txt")
for f in "${fichiers[@]}"; do
    echo "Traitement de $f"
done
```

> [!tip] Astuce de débogage Utilisez `set -x` pour voir comment Bash interprète vos commandes après expansion :
> 
> ```bash
> set -x  # Active le mode debug
> var="fichier test.txt"
> cp $var /tmp/      # Affiche : + cp fichier test.txt /tmp/
> cp "$var" /tmp/    # Affiche : + cp 'fichier test.txt' /tmp/
> set +x  # Désactive le mode debug
> ```

---

## 📋 Récapitulatif des bonnes pratiques

|Règle|Exemple|
|---|---|
|Toujours quoter les variables|`"$variable"`|
|Toujours quoter `$@`|`"$@"`|
|Utiliser `' '` pour texte littéral|`grep 'pattern[0-9]+'`|
|Utiliser `" "` pour interpolation|`echo "Résultat: $result"`|
|Quoter dans les tests|`[ "$var" = "valeur" ]`|
|Préférer `[[ ]]` à `[ ]`|`[[ $var = valeur ]]` (plus permissif)|
|Utiliser `printf %q` pour échapper|`printf '%q' "$var"`|
|Tester avec espaces et caractères spéciaux|Fichiers comme `"test file[1].txt"`|

> [!tip] Conseil final Quand vous avez un doute : **quotez !** Il vaut mieux quoter inutilement que de créer un bug subtil. La règle par défaut devrait être : "Je quote, sauf si j'ai une bonne raison de ne pas le faire."