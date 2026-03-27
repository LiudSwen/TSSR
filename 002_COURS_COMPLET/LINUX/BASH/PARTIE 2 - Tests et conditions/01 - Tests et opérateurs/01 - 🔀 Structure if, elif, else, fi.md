

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

La structure conditionnelle `if/elif/else/fi` est le pilier de la logique décisionnelle en Bash. Elle permet d'exécuter différents blocs de code selon que des conditions sont vraies ou fausses.

> [!info] Pourquoi c'est important
> 
> - Permet de créer des scripts intelligents qui s'adaptent aux situations
> - Indispensable pour la validation des entrées utilisateur
> - Base de toute logique de contrôle de flux
> - Utilisé dans pratiquement tous les scripts Bash professionnels

> [!tip] Quand l'utiliser
> 
> - Validation de paramètres ou d'arguments
> - Vérification de l'existence de fichiers ou répertoires
> - Tests sur des variables d'environnement
> - Prise de décision selon le résultat d'une commande
> - Gestion d'erreurs et de cas particuliers

---

## 📖 Syntaxe de base

### Structure minimale

```bash
if [ condition ]; then
    # Code à exécuter si la condition est vraie
    echo "Condition vraie"
fi
```

> [!info] Anatomie de la structure
> 
> - `if` : Mot-clé de début
> - `[ condition ]` : Test à évaluer (espaces obligatoires autour des crochets)
> - `then` : Séparateur avant le bloc de code
> - `fi` : Mot-clé de fin (if à l'envers)

### Exemple concret

```bash
#!/bin/bash

age=25

if [ $age -ge 18 ]; then
    echo "Vous êtes majeur"
fi
```

> [!warning] Point d'attention Le point-virgule `;` avant `then` est obligatoire si `then` est sur la même ligne que `if`. Sinon, placez `then` sur la ligne suivante sans point-virgule.

### Syntaxe alternative sans point-virgule

```bash
if [ condition ]
then
    echo "Condition vraie"
fi
```

---

## 🔄 Conditions avec elif

La clause `elif` (contraction de "else if") permet de tester plusieurs conditions successives sans imbriquer plusieurs structures if.

### Syntaxe

```bash
if [ condition1 ]; then
    # Code si condition1 est vraie
elif [ condition2 ]; then
    # Code si condition1 est fausse ET condition2 est vraie
elif [ condition3 ]; then
    # Code si condition1 et condition2 sont fausses ET condition3 est vraie
fi
```

### Exemple pratique

```bash
#!/bin/bash

note=14

if [ $note -ge 16 ]; then
    echo "Très bien"
elif [ $note -ge 14 ]; then
    echo "Bien"
elif [ $note -ge 12 ]; then
    echo "Assez bien"
elif [ $note -ge 10 ]; then
    echo "Passable"
fi
```

> [!tip] Astuce Les conditions sont évaluées de haut en bas. Dès qu'une condition est vraie, le bloc correspondant est exécuté et le reste est ignoré. Placez donc les conditions les plus spécifiques en premier.

### Utilisation avec des chaînes

```bash
#!/bin/bash

OS=$(uname -s)

if [ "$OS" = "Linux" ]; then
    echo "Système Linux détecté"
elif [ "$OS" = "Darwin" ]; then
    echo "Système macOS détecté"
elif [ "$OS" = "FreeBSD" ]; then
    echo "Système FreeBSD détecté"
fi
```

---

## 🎲 Clause else par défaut

La clause `else` définit un comportement par défaut lorsqu'aucune des conditions précédentes n'est satisfaite.

### Syntaxe complète

```bash
if [ condition1 ]; then
    # Code si condition1 est vraie
elif [ condition2 ]; then
    # Code si condition2 est vraie
else
    # Code si aucune condition n'est vraie
fi
```

### Exemple

```bash
#!/bin/bash

nombre=7

if [ $nombre -lt 0 ]; then
    echo "Nombre négatif"
elif [ $nombre -eq 0 ]; then
    echo "Nombre nul"
else
    echo "Nombre positif"
fi
```

> [!example] Cas d'usage classique : Validation d'argument
> 
> ```bash
> #!/bin/bash
> 
> if [ $# -eq 0 ]; then
>     echo "Erreur : Aucun argument fourni"
>     exit 1
> elif [ $# -gt 1 ]; then
>     echo "Erreur : Trop d'arguments"
>     exit 1
> else
>     echo "Traitement de l'argument : $1"
>     # Code principal
> fi
> ```

---

## 📐 Indentation et lisibilité

L'indentation n'est pas obligatoire en Bash (contrairement à Python), mais elle est cruciale pour la lisibilité.

### ❌ Code mal indenté

```bash
if [ $age -ge 18 ]; then
echo "Majeur"
if [ $permis = "oui" ]; then
echo "Peut conduire"
else
echo "Ne peut pas conduire"
fi
else
echo "Mineur"
fi
```

### ✅ Code bien indenté

```bash
if [ $age -ge 18 ]; then
    echo "Majeur"
    if [ $permis = "oui" ]; then
        echo "Peut conduire"
    else
        echo "Ne peut pas conduire"
    fi
else
    echo "Mineur"
fi
```

> [!tip] Standards d'indentation
> 
> - Utilisez **4 espaces** ou **2 espaces** de manière cohérente
> - Évitez les tabulations (problèmes de compatibilité)
> - Indentez chaque niveau de profondeur
> - Alignez les `then`, `elif`, `else`, et `fi` de même niveau

### Exemple avec commentaires

```bash
#!/bin/bash

# Vérification des permissions fichier
if [ -r "$fichier" ]; then
    # Fichier lisible
    echo "Lecture autorisée"
    
    if [ -w "$fichier" ]; then
        # Fichier aussi modifiable
        echo "Écriture autorisée"
    else
        # Lecture seule
        echo "Lecture seule"
    fi
else
    # Aucun accès
    echo "Accès refusé"
fi
```

---

## ⚡ If sur une ligne

Pour des tests simples, il est possible de condenser la structure `if` sur une seule ligne en utilisant des points-virgules.

### Syntaxe

```bash
if [ condition ]; then commande; fi
```

### Exemples

```bash
# Test simple
if [ -f "config.txt" ]; then echo "Config trouvée"; fi

# Avec else
if [ $USER = "root" ]; then echo "Admin"; else echo "Utilisateur"; fi

# Plusieurs commandes
if [ $debug = "true" ]; then echo "Mode debug"; set -x; fi
```

> [!warning] Attention à la lisibilité Le if sur une ligne est pratique pour des tests très simples, mais nuit à la lisibilité pour des conditions complexes. Privilégiez la forme multi-lignes dès que :
> 
> - Il y a plusieurs commandes à exécuter
> - La condition est complexe
> - Vous utilisez `elif` ou `else`

### Comparaison

|Format|Avantages|Inconvénients|
|---|---|---|
|Une ligne|Concis, rapide à taper|Difficile à lire, limité|
|Multi-lignes|Lisible, maintenable|Plus verbeux|

### Usage recommandé

```bash
# ✅ Bon usage sur une ligne (test simple)
if [ -z "$var" ]; then var="default"; fi

# ❌ Mauvais usage (trop complexe)
if [ $a -gt 5 ]; then echo "Grand"; b=$((a*2)); echo "Double: $b"; else echo "Petit"; fi

# ✅ Mieux (multi-lignes)
if [ $a -gt 5 ]; then
    echo "Grand"
    b=$((a*2))
    echo "Double: $b"
else
    echo "Petit"
fi
```

---

## 🔍 Opérateurs de test

### Tests sur les entiers

|Opérateur|Signification|Exemple|
|---|---|---|
|`-eq`|Égal à|`[ $a -eq $b ]`|
|`-ne`|Différent de|`[ $a -ne $b ]`|
|`-lt`|Inférieur à|`[ $a -lt $b ]`|
|`-le`|Inférieur ou égal|`[ $a -le $b ]`|
|`-gt`|Supérieur à|`[ $a -gt $b ]`|
|`-ge`|Supérieur ou égal|`[ $a -ge $b ]`|

```bash
if [ $age -ge 18 ]; then
    echo "Majeur"
fi
```

### Tests sur les chaînes

|Opérateur|Signification|Exemple|
|---|---|---|
|`=` ou `==`|Égalité|`[ "$str1" = "$str2" ]`|
|`!=`|Différence|`[ "$str1" != "$str2" ]`|
|`-z`|Chaîne vide|`[ -z "$str" ]`|
|`-n`|Chaîne non vide|`[ -n "$str" ]`|
|`<`|Ordre alphabétique (avec `[[`)|`[[ "$a" < "$b" ]]`|

```bash
if [ -z "$nom" ]; then
    echo "Nom non défini"
fi

if [ "$mode" = "production" ]; then
    echo "Environnement de production"
fi
```

> [!warning] Toujours quoter les variables
> 
> ```bash
> # ❌ Dangereux si $var contient des espaces ou est vide
> if [ $var = "test" ]; then
> 
> # ✅ Sûr
> if [ "$var" = "test" ]; then
> ```

### Tests sur les fichiers

|Opérateur|Signification|
|---|---|
|`-e`|Existe|
|`-f`|Fichier régulier|
|`-d`|Répertoire|
|`-L`|Lien symbolique|
|`-r`|Lisible|
|`-w`|Modifiable|
|`-x`|Exécutable|
|`-s`|Non vide (taille > 0)|

```bash
if [ -f "/etc/config.conf" ]; then
    echo "Fichier de configuration trouvé"
fi

if [ -d "/var/log" ]; then
    echo "Répertoire de logs existe"
fi

if [ -x "./script.sh" ]; then
    ./script.sh
else
    echo "Script non exécutable"
fi
```

### Opérateurs logiques

|Opérateur|Signification|Exemple|
|---|---|---|
|`-a` ou `&&`|ET logique|`[ $a -gt 0 -a $a -lt 10 ]`|
|`-o` ou `\|`|OU logique|`[ $a -eq 0 -o $a -eq 1 ]`|
|`!`|NON logique|`[ ! -f "file.txt" ]`|

```bash
# ET logique avec -a
if [ $age -ge 18 -a $age -le 65 ]; then
    echo "Âge d'activité professionnelle"
fi

# OU logique avec -o
if [ "$env" = "dev" -o "$env" = "test" ]; then
    echo "Environnement de développement"
fi

# Négation
if [ ! -d "backup" ]; then
    mkdir backup
    echo "Répertoire backup créé"
fi
```

> [!tip] Préférez `[[` pour les tests modernes La syntaxe `[[ ]]` (double crochets) est plus puissante et évite certains pièges :
> 
> ```bash
> # Avec [ ] : nécessite des quotes et échappement
> if [ "$var" = "test" -a "$var2" != "" ]; then
> 
> # Avec [[ ]] : plus naturel
> if [[ $var == "test" && $var2 != "" ]]; then
> ```

---

## ⚠️ Pièges courants

### 1. Oubli des espaces autour des crochets

```bash
# ❌ Erreur de syntaxe
if [$a -eq 5]; then

# ✅ Correct
if [ $a -eq 5 ]; then
```

> [!warning] Les espaces sont obligatoires `[` est en réalité une commande (alias de `test`). Les espaces sont nécessaires pour séparer la commande de ses arguments.

### 2. Variables non quotées

```bash
fichier="mon fichier.txt"

# ❌ Erreur si la variable contient des espaces
if [ -f $fichier ]; then

# ✅ Correct
if [ -f "$fichier" ]; then
```

### 3. Confusion entre = et -eq

```bash
# ❌ Erreur : = est pour les chaînes
if [ $nombre = 42 ]; then

# ✅ Correct pour les entiers
if [ $nombre -eq 42 ]; then

# ✅ Correct pour les chaînes
if [ "$texte" = "42" ]; then
```

### 4. Oubli du then

```bash
# ❌ Erreur de syntaxe
if [ condition ]
    echo "Test"
fi

# ✅ Correct
if [ condition ]; then
    echo "Test"
fi
```

### 5. Test sur variable non initialisée

```bash
# ❌ Erreur si $var n'existe pas
if [ $var -gt 10 ]; then

# ✅ Vérification d'existence d'abord
if [ -n "$var" ] && [ $var -gt 10 ]; then

# ✅ Ou avec valeur par défaut
if [ ${var:-0} -gt 10 ]; then
```

### 6. Utilisation de < et > sans protection

```bash
# ❌ Peut être interprété comme redirection
if [ "$a" > "$b" ]; then

# ✅ Utiliser [[ ]] pour les comparaisons de chaînes
if [[ "$a" > "$b" ]]; then

# ✅ Ou échapper avec [ ]
if [ "$a" \> "$b" ]; then
```

---

## ✨ Bonnes pratiques

### 1. Toujours quoter les variables

```bash
# ✅ Toujours quoter
if [ -f "$fichier" ]; then
if [ "$nom" = "admin" ]; then
if [ -n "$variable" ]; then
```

### 2. Utiliser des noms de variables explicites

```bash
# ❌ Noms cryptiques
if [ $a -gt $b ]; then

# ✅ Noms clairs
if [ $age_utilisateur -gt $age_minimum ]; then
```

### 3. Commenter les conditions complexes

```bash
# Vérifie si l'utilisateur a les droits admin ET que le mode debug est actif
if [ "$role" = "admin" -a "$debug" = "true" ]; then
    enable_debug_mode
fi
```

### 4. Éviter les conditions trop longues

```bash
# ❌ Difficile à lire
if [ $a -gt 10 -a $b -lt 20 -a "$c" = "test" -o $d -eq 5 ]; then

# ✅ Découper en plusieurs if ou utiliser des variables
est_valide_a=$([ $a -gt 10 ] && echo "true" || echo "false")
est_valide_b=$([ $b -lt 20 ] && echo "true" || echo "false")

if [ "$est_valide_a" = "true" ] && [ "$est_valide_b" = "true" ]; then
```

### 5. Préférer [[ ]] pour les tests modernes

```bash
# ✅ Plus lisible et moins de pièges
if [[ $var == "test" && $count -gt 0 ]]; then
    echo "Conditions remplies"
fi
```

### 6. Gérer le cas else de manière explicite

```bash
# ✅ Clair sur le comportement par défaut
if [ -f "$config" ]; then
    source "$config"
else
    echo "AVERTISSEMENT : Fichier de config absent, utilisation des valeurs par défaut"
    use_default_config
fi
```

### 7. Utiliser exit pour les erreurs critiques

```bash
if [ ! -d "$repertoire_travail" ]; then
    echo "ERREUR : Répertoire de travail introuvable" >&2
    exit 1
fi
```

---

## 🎓 Astuces avancées

### 1. Test du code de retour d'une commande

```bash
# Méthode simple
if commande_qui_peut_echouer; then
    echo "Succès"
else
    echo "Échec"
fi

# Avec capture du code de retour
if grep -q "pattern" fichier.txt; then
    echo "Pattern trouvé"
fi

# Test explicite du code de retour
commande
if [ $? -eq 0 ]; then
    echo "Commande réussie"
fi
```

### 2. Conditions imbriquées optimisées

```bash
# ✅ Sortie précoce pour éviter l'imbrication profonde
if [ ! -f "$fichier" ]; then
    echo "Fichier introuvable"
    exit 1
fi

if [ ! -r "$fichier" ]; then
    echo "Fichier non lisible"
    exit 1
fi

# Continuer le traitement normal
process_file "$fichier"
```

### 3. Tests multiples avec case comme alternative

```bash
# Parfois, case est plus lisible que de multiples elif
case "$choix" in
    1)
        echo "Option 1"
        ;;
    2)
        echo "Option 2"
        ;;
    *)
        echo "Option invalide"
        ;;
esac
```

### 4. Conditions arithmétiques avec (( ))

```bash
# Pour les calculs arithmétiques, (( )) est plus naturel
if (( count > 10 && count < 100 )); then
    echo "Count dans la plage"
fi

# Incrémentation conditionnelle
if (( ++counter > max )); then
    echo "Limite atteinte"
fi
```

### 5. Tests regex avec =~

```bash
# Vérifier un format avec regex (nécessite [[ ]])
if [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
    echo "Email valide"
else
    echo "Format d'email invalide"
fi
```

### 6. Valeurs par défaut avec ${var:-default}

```bash
# Utiliser une valeur par défaut si la variable est vide
port=${PORT:-8080}

if [ $port -lt 1024 ]; then
    echo "Port privilégié, nécessite les droits root"
fi
```

### 7. Opérateur ternaire simulé

```bash
# Simuler un opérateur ternaire
resultat=$([ $age -ge 18 ] && echo "majeur" || echo "mineur")

# Ou directement dans une commande
echo "Vous êtes $([ $age -ge 18 ] && echo 'majeur' || echo 'mineur')"
```

### 8. Tests combinés avec des fonctions

```bash
# Créer des fonctions pour des tests réutilisables
est_valide() {
    local valeur=$1
    [ -n "$valeur" ] && [ "$valeur" -ge 0 ] && [ "$valeur" -le 100 ]
}

if est_valide "$score"; then
    echo "Score valide : $score"
else
    echo "Score invalide"
fi
```

---

## 📌 Résumé

La structure `if/elif/else/fi` est l'outil fondamental de contrôle de flux en Bash. Points clés à retenir :

- ✅ Toujours respecter les espaces autour de `[` et `]`
- ✅ Quoter systématiquement les variables
- ✅ Utiliser `-eq`, `-ne`, etc. pour les entiers et `=`, `!=` pour les chaînes
- ✅ Indenter correctement pour la lisibilité
- ✅ Préférer `[[` pour les tests modernes
- ✅ Commenter les conditions complexes
- ✅ Fermer avec `fi` (if inversé)

> [!tip] Pour aller plus loin La structure `if/elif/else/fi` est souvent combinée avec d'autres structures de contrôle. Une fois maîtrisée, elle devient un réflexe naturel dans l'écriture de scripts Bash robustes et maintenables.