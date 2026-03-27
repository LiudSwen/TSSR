

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

## 🎯 Introduction au mode verbose

Le mode verbose (`set -v`) est un outil de débogage qui affiche chaque ligne du script **telle qu'elle est lue** par le shell, **avant** son exécution. C'est particulièrement utile pour :

- **Comprendre le flux d'exécution** d'un script complexe
- **Visualiser les boucles et conditions** au fur et à mesure de leur lecture
- **Déboguer les problèmes de syntaxe** en voyant exactement ce que Bash interprète
- **Analyser les scripts avec des substitutions complexes**

> [!info] Pourquoi "verbose" ? Le terme "verbose" signifie littéralement "bavard". Ce mode rend le script bavard en affichant tout ce qu'il lit, ligne par ligne, sans filtrage.

---

## 🔧 Activation du mode verbose

### Syntaxe de base

```bash
# Activation dans un script
set -v

# Désactivation
set +v

# Activation au lancement du script
bash -v mon_script.sh

# Activation sur une ligne spécifique (shebang)
#!/bin/bash -v
```

### Exemple simple

```bash
#!/bin/bash

echo "Début du script"

# Activation du mode verbose
set -v

nom="Alice"
prenom="Dupont"
echo "Bonjour $nom $prenom"

# Désactivation
set +v

echo "Fin du script"
```

**Sortie :**

```
Début du script
nom="Alice"
prenom="Dupont"
echo "Bonjour $nom $prenom"
Bonjour Alice Dupont
Fin du script
```

> [!tip] Astuce : Débogage ciblé Vous pouvez activer/désactiver `-v` autour des sections problématiques uniquement, plutôt que pour tout le script.

---

## 📖 Affichage des lignes avant exécution

Le mode verbose affiche **le code source brut** tel qu'il est lu par Bash, **avant toute expansion ou exécution**.

### Comportement détaillé

```bash
#!/bin/bash
set -v

# Variables
utilisateur="root"
repertoire="/home/$utilisateur"

# Boucle
for i in 1 2 3; do
    echo "Itération $i"
done

# Condition
if [ -d "$repertoire" ]; then
    echo "Le répertoire existe"
fi
```

**Sortie verbose :**

```
utilisateur="root"
repertoire="/home/$utilisateur"

for i in 1 2 3; do
    echo "Itération $i"
done
Itération 1
Itération 2
Itération 3

if [ -d "$repertoire" ]; then
    echo "Le répertoire existe"
fi
Le répertoire existe
```

> [!example] Observation importante Notez que les lignes sont affichées **telles quelles**, sans expansion des variables. Vous voyez `echo "Itération $i"` et non `echo "Itération 1"`.

### Avec les commentaires

```bash
#!/bin/bash
set -v

# Ceci est un commentaire
echo "Hello"  # Commentaire en ligne

# Bloc de commentaires
# sur plusieurs
# lignes
echo "World"
```

**Sortie :**

```
# Ceci est un commentaire
echo "Hello"  # Commentaire en ligne
Hello

# Bloc de commentaires
# sur plusieurs
# lignes
echo "World"
World
```

> [!warning] Les commentaires sont affichés ! Contrairement à l'exécution normale, le mode verbose affiche **tous les commentaires**, ce qui peut rendre la sortie très volumineuse sur les scripts bien documentés.

---

## 🔄 Différence avec set -x

La distinction entre `set -v` et `set -x` est **fondamentale** pour un débogage efficace.

### Tableau comparatif

|Caractéristique|`set -v` (verbose)|`set -x` (xtrace)|
|---|---|---|
|**Moment d'affichage**|Avant exécution|Pendant l'exécution|
|**Contenu affiché**|Code source brut|Commandes après expansion|
|**Variables**|Non substituées (`$var`)|Substituées (`valeur`)|
|**Préfixe**|Aucun|`+` ou `$PS4`|
|**Commentaires**|Affichés|Non affichés|
|**Substitutions**|Non résolues|Résolues|
|**Usage principal**|Comprendre le flux|Voir les valeurs réelles|

### Exemple comparatif

```bash
#!/bin/bash

nom="Alice"
fichiers=$(ls *.txt 2>/dev/null)

# Test avec set -v
set -v
echo "Utilisateur : $nom"
echo "Fichiers : $fichiers"
set +v

echo "---"

# Test avec set -x
set -x
echo "Utilisateur : $nom"
echo "Fichiers : $fichiers"
set +x
```

**Sortie avec `-v` :**

```
echo "Utilisateur : $nom"
Utilisateur : Alice
echo "Fichiers : $fichiers"
Fichiers : doc.txt rapport.txt
```

**Sortie avec `-x` :**

```
+ echo 'Utilisateur : Alice'
Utilisateur : Alice
+ echo 'Fichiers : doc.txt rapport.txt'
Fichiers : doc.txt rapport.txt
```

> [!info] Quelle option choisir ?
> 
> - **`set -v`** : Pour comprendre **quelle partie du code** est exécutée
> - **`set -x`** : Pour voir **quelles valeurs** sont réellement utilisées

### Cas d'usage spécifiques

**Utilisez `set -v` quand :**

- Vous debuggez la **structure logique** (boucles, conditions)
- Vous voulez voir **l'ordre d'exécution** exact
- Vous analysez un script que vous ne connaissez pas
- Vous vérifiez que le bon **bloc de code** est atteint

**Utilisez `set -x` quand :**

- Vous debuggez les **valeurs de variables**
- Vous tracez les **substitutions de commandes**
- Vous vérifiez les **arguments passés** aux commandes
- Vous analysez des **problèmes d'expansion**

---

## 🔀 Combinaison -xv

La vraie puissance du débogage Bash vient de la **combinaison des deux modes**.

### Syntaxe

```bash
# Dans le script
set -xv

# Au lancement
bash -xv script.sh

# Dans le shebang
#!/bin/bash -xv
```

### Exemple détaillé

```bash
#!/bin/bash

nom="Bob"
age=25

set -xv

# Condition complexe
if [ $age -gt 18 ] && [ -n "$nom" ]; then
    message="$nom est majeur"
    echo "$message"
fi

# Boucle avec substitution
for fichier in $(ls *.log 2>/dev/null); do
    echo "Traitement de $fichier"
done

set +xv
```

**Sortie combinée `-xv` :**

```
if [ $age -gt 18 ] && [ -n "$nom" ]; then
+ '[' 25 -gt 18 ']'
+ '[' -n Bob ']'
    message="$nom est majeur"
+ message='Bob est majeur'
    echo "$message"
+ echo 'Bob est majeur'
Bob est majeur
fi

for fichier in $(ls *.log 2>/dev/null); do
++ ls '*.log'
+ for fichier in error.log system.log
    echo "Traitement de $fichier"
+ echo 'Traitement de error.log'
Traitement de error.log
    echo "Traitement de $fichier"
+ echo 'Traitement de system.log'
Traitement de system.log
done
```

> [!example] Lecture de la sortie `-xv`
> 
> - Les lignes **sans préfixe** : code source (`-v`)
> - Les lignes avec **`+`** : commandes exécutées (`-x`)
> - Les lignes avec **`++`** : sous-shells/substitutions (`-x`)
> - Les lignes **normales** : sortie réelle du programme

### Avantages de la combinaison

1. **Vue complète** : Code source ET valeurs réelles
2. **Corrélation facile** : On voit la correspondance entre code et exécution
3. **Débogage exhaustif** : Aucune information ne manque
4. **Compréhension profonde** : Idéal pour apprendre Bash

> [!warning] Attention au volume ! La sortie `-xv` peut être **extrêmement volumineuse**. Préférez l'utiliser sur des sections ciblées ou rediriger vers un fichier :
> 
> ```bash
> bash -xv script.sh 2> debug.log
> ```

### Débogage ciblé avec combinaison

```bash
#!/bin/bash

fonction_complexe() {
    local var1=$1
    local var2=$2
    
    # Activer le débogage uniquement ici
    set -xv
    
    if [ "$var1" = "$var2" ]; then
        resultat="égaux"
    else
        resultat="différents"
    fi
    
    echo "$resultat"
    
    set +xv
}

# Appel normal sans debug
echo "Début"
fonction_complexe "test" "test"
echo "Fin"
```

---

## ⚠️ Pièges courants

### 1. Sortie vers stderr

```bash
#!/bin/bash
set -v

echo "Message normal"
```

> [!warning] Piège : stderr vs stdout Le mode verbose écrit sur **stderr** (descripteur 2), pas stdout. Pour capturer :
> 
> ```bash
> bash -v script.sh 2> verbose.log
> ```

### 2. Volume de sortie excessif

```bash
#!/bin/bash
set -v

# Boucle qui génère beaucoup de sortie verbose
for i in {1..1000}; do
    calcul=$((i * 2))
done
```

> [!tip] Solution : Débogage sélectif
> 
> ```bash
> # N'activer que pour la zone problématique
> set +v  # Désactivé par défaut
> 
> # Code non-critique
> for i in {1..1000}; do
>     calcul=$((i * 2))
> done
> 
> # Zone à déboguer
> set -v
> if [ $calcul -gt 1000 ]; then
>     echo "Seuil dépassé"
> fi
> set +v
> ```

### 3. Confusion avec les sous-shells

```bash
#!/bin/bash
set -v

# Le mode -v ne s'applique PAS aux sous-shells
resultat=$(
    echo "Dans un sous-shell"
    calcul=$((5 + 3))
    echo $calcul
)
```

> [!info] Explication Les sous-shells héritent des options, mais la sortie verbose du sous-shell ne sera visible que si elle n'est pas capturée.

### 4. Scripts sourcés

```bash
#!/bin/bash
set -v

# Si script2.sh contient aussi du code
source script2.sh  # Le mode -v s'applique aussi à script2.sh
```

> [!warning] Propagation du mode Le `set -v` s'applique aussi aux scripts sourcés, ce qui peut créer une sortie inattendue.

---

## ✅ Bonnes pratiques

### 1. Combinaison stratégique des modes

```bash
#!/bin/bash

# Fonction de débogage personnalisée
debug_section() {
    echo "=== DÉBUT DEBUG: $1 ===" >&2
    set -xv
}

end_debug() {
    set +xv
    echo "=== FIN DEBUG ===" >&2
}

# Utilisation
traitement_donnees() {
    debug_section "Traitement données"
    
    # Code à déboguer
    donnees=$(cat fichier.txt)
    resultat=$(echo "$donnees" | grep "motif")
    
    end_debug
}
```

### 2. Redirection intelligente

```bash
#!/bin/bash

# Séparer verbose et xtrace
exec 3>&2  # Sauvegarder stderr
exec 2> xtrace.log  # xtrace vers fichier

set -x  # Traces dans xtrace.log

# Verbose vers terminal
bash -v script.sh 2>&3

set +x
exec 2>&3  # Restaurer stderr
```

### 3. Mode conditionnel

```bash
#!/bin/bash

# Activer selon une variable d'environnement
if [ "$DEBUG_MODE" = "verbose" ]; then
    set -v
elif [ "$DEBUG_MODE" = "trace" ]; then
    set -x
elif [ "$DEBUG_MODE" = "full" ]; then
    set -xv
fi

# Votre code ici
```

**Usage :**

```bash
DEBUG_MODE=full ./mon_script.sh
```

### 4. Documentation de débogage

```bash
#!/bin/bash

# === SECTION DÉBOGAGE ===
# Décommenter la ligne suivante pour activer le mode verbose
#set -v

# Décommenter pour xtrace
#set -x

# Décommenter pour les deux
#set -xv

# Code du script...
```

> [!tip] Astuce professionnelle Laissez les lignes de débogage en commentaire dans vos scripts de production. Elles servent de documentation et peuvent être rapidement activées en cas de problème.

### 5. Gestion des erreurs avec verbose

```bash
#!/bin/bash

# Combiner avec set -e (exit on error)
set -ev  # Verbose + exit on error

# Ou version plus robuste
set -euvo pipefail
# -e : exit on error
# -u : exit on undefined variable
# -v : verbose
# -o pipefail : exit on pipe failure
```

### 6. Filtrage de la sortie verbose

```bash
#!/bin/bash

# Exécuter avec filtrage
bash -v script.sh 2>&1 | grep -v "^#"  # Exclure les commentaires

# Ou garder seulement certaines sections
bash -v script.sh 2>&1 | grep -A5 "fonction_importante"
```

---

## 💡 Astuces avancées

### Créer un mode debug persistant

```bash
#!/bin/bash

# En tête de script
if [ -f ~/.bash_debug ]; then
    source ~/.bash_debug
fi

# Dans ~/.bash_debug, créer :
# set -xv
# export PS4='+ ${BASH_SOURCE}:${LINENO}: '
```

### Utiliser des marqueurs visuels

```bash
#!/bin/bash

debug_marker() {
    echo "
========================================" >&2
    echo "DEBUG: $1" >&2
    echo "========================================
" >&2
    set -xv
}

# Usage
debug_marker "Début du traitement critique"
# ... code ...
set +xv
```

### Mode verbose temporisé

```bash
#!/bin/bash

# Activer verbose pendant 5 secondes
(set -v; sleep 5) &
DEBUG_PID=$!

# Votre code ici

# Désactiver après timeout
kill $DEBUG_PID 2>/dev/null
```

---