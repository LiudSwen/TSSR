

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

La portée (ou _scope_) d'une variable définit où cette variable est accessible et modifiable dans votre code. Comprendre la portée des variables est essentiel pour :

- **Éviter les conflits** entre différentes parties du code
- **Contrôler l'héritage** des variables entre processus
- **Optimiser la mémoire** en limitant la durée de vie des variables
- **Écrire du code maintenable** et prévisible

> [!info] Concept clé En Bash, les variables ont par défaut une portée globale au sein d'un même processus, mais ne sont pas automatiquement transmises aux processus enfants.

---

## 📍 Variables locales dans un script

### Qu'est-ce qu'une variable locale ?

Une variable est considérée comme "locale au script" lorsqu'elle est définie dans un script sans utiliser `export`. Elle est accessible partout dans le script, mais **pas** dans les sous-processus (scripts appelés, commandes externes, etc.).

### Syntaxe et comportement

```bash
#!/bin/bash

# Variable locale au script
ma_variable="valeur"

# Accessible partout dans le script
echo "Dans le script : $ma_variable"

# Appel d'un sous-script
./autre_script.sh  # Ne verra PAS ma_variable

# Appel d'une commande externe
env | grep ma_variable  # Ne trouvera PAS ma_variable
```

### Exemple complet

```bash
#!/bin/bash
# script_principal.sh

nom="Alice"
age=30

echo "Script principal - Nom : $nom, Age : $age"

# Cette variable est accessible dans tout le script
afficher_info() {
    echo "Dans la fonction - Nom : $nom, Age : $age"
}

afficher_info

# Mais pas dans les sous-processus
bash -c 'echo "Sous-processus - Nom : $nom"'  # Affichera une ligne vide
```

**Sortie :**

```
Script principal - Nom : Alice, Age : 30
Dans la fonction - Nom : Alice, Age : 30
Sous-processus - Nom : 
```

> [!warning] Attention Une variable définie dans un script reste en mémoire jusqu'à la fin de l'exécution du script, même si elle n'est plus utilisée.

---

## 🌍 Variables globales

### Définition

En Bash, une variable est **globale** par défaut au sein d'un même processus (script ou session interactive). Cela signifie qu'elle est accessible depuis n'importe quelle fonction ou partie du code dans le même processus.

### Comportement par défaut

```bash
#!/bin/bash

# Variable globale (accessible partout dans ce processus)
compteur=0

incrementer() {
    # Accès à la variable globale
    compteur=$((compteur + 1))
    echo "Compteur dans la fonction : $compteur"
}

incrementer  # Affiche : 1
incrementer  # Affiche : 2
echo "Compteur global : $compteur"  # Affiche : 2
```

### Portée entre fonctions

```bash
#!/bin/bash

fonction_a() {
    variable_a="Définie dans A"
    echo "Fonction A : $variable_a"
}

fonction_b() {
    # Peut accéder à variable_a si fonction_a a été appelée avant
    echo "Fonction B : $variable_a"
}

fonction_a
fonction_b
```

**Sortie :**

```
Fonction A : Définie dans A
Fonction B : Définie dans A
```

> [!tip] Astuce Les variables globales sont pratiques mais peuvent rendre le code difficile à déboguer. Utilisez-les avec parcimonie et privilégiez les passages de paramètres.

---

## 🔒 Le mot-clé `local` dans les fonctions

### Pourquoi utiliser `local` ?

Le mot-clé `local` permet de créer des variables dont la portée est **limitée à une fonction**. Cela évite les effets de bord et les conflits de noms.

### Syntaxe

```bash
fonction() {
    local variable_locale="valeur"
    # variable_locale n'existe que dans cette fonction
}
```

### Exemple détaillé

```bash
#!/bin/bash

# Variable globale
nom="Global"

modifier_nom() {
    # Variable locale (ne modifie pas la globale)
    local nom="Local"
    echo "Dans la fonction : $nom"
}

echo "Avant : $nom"        # Affiche : Global
modifier_nom              # Affiche : Local
echo "Après : $nom"       # Affiche : Global (inchangé)
```

### Exemple sans `local`

```bash
#!/bin/bash

nom="Global"

modifier_nom_sans_local() {
    # Sans local, modifie la variable globale !
    nom="Modifié"
    echo "Dans la fonction : $nom"
}

echo "Avant : $nom"              # Affiche : Global
modifier_nom_sans_local          # Affiche : Modifié
echo "Après : $nom"              # Affiche : Modifié (changé !)
```

### Variables locales multiples

```bash
#!/bin/bash

calculer() {
    local a=10
    local b=20
    local resultat=$((a + b))
    
    echo "Résultat : $resultat"
}

calculer
# a, b et resultat ne sont plus accessibles ici
echo "A l'extérieur : $a"  # Affiche une ligne vide
```

### Portée imbriquée

```bash
#!/bin/bash

fonction_externe() {
    local var_externe="Externe"
    
    fonction_interne() {
        local var_interne="Interne"
        # Peut accéder à var_externe
        echo "Interne voit : $var_externe et $var_interne"
    }
    
    fonction_interne
    # Ne peut PAS accéder à var_interne
    echo "Externe voit : $var_externe et $var_interne"
}

fonction_externe
```

**Sortie :**

```
Interne voit : Externe et Interne
Externe voit : Externe et 
```

> [!example] Cas d'usage typique Utilisez `local` pour les variables temporaires, les compteurs de boucle, et tout ce qui ne doit pas "fuiter" hors de la fonction.

---

## 🚀 Export pour les processus enfants

### Concept fondamental

Par défaut, les variables Bash ne sont **pas** transmises aux processus enfants (sous-shells, scripts appelés, commandes externes). Le mot-clé `export` permet de rendre une variable disponible dans l'environnement des processus enfants.

### Syntaxe

```bash
# Définition et export en une ligne
export VARIABLE="valeur"

# Ou en deux temps
VARIABLE="valeur"
export VARIABLE

# Export sans valeur (exporte une variable existante)
variable="test"
export variable
```

### Différence entre variable normale et exportée

```bash
#!/bin/bash

# Variable normale (non exportée)
var_normale="Je reste ici"

# Variable exportée
export var_exportee="Je voyage"

# Test avec un sous-shell
bash -c 'echo "Normale : $var_normale"'       # Vide
bash -c 'echo "Exportée : $var_exportee"'    # Affiche la valeur
```

### Exemple avec un script enfant

**script_parent.sh :**

```bash
#!/bin/bash

COULEUR="rouge"
export ANIMAL="chat"

echo "=== Dans le parent ==="
echo "COULEUR : $COULEUR"
echo "ANIMAL : $ANIMAL"

# Appel du script enfant
./script_enfant.sh
```

**script_enfant.sh :**

```bash
#!/bin/bash

echo "=== Dans l'enfant ==="
echo "COULEUR : $COULEUR"  # Vide (non exportée)
echo "ANIMAL : $ANIMAL"    # Affiche "chat" (exportée)
```

**Sortie :**

```
=== Dans le parent ===
COULEUR : rouge
ANIMAL : chat
=== Dans l'enfant ===
COULEUR : 
ANIMAL : chat
```

### Variables d'environnement courantes

```bash
#!/bin/bash

# Ces variables sont généralement exportées par le système
echo "PATH : $PATH"
echo "HOME : $HOME"
echo "USER : $USER"
echo "SHELL : $SHELL"

# Modifier PATH pour les processus enfants
export PATH="$PATH:/mon/nouveau/chemin"

# Définir une variable personnalisée
export MON_APP_CONFIG="/etc/monapp/config"
```

### Export dans les fonctions

```bash
#!/bin/bash

configurer_environnement() {
    # Ces exports affectent le processus courant ET ses enfants
    export DB_HOST="localhost"
    export DB_PORT="5432"
    export DB_NAME="mabase"
}

configurer_environnement

# Lance un sous-processus qui verra ces variables
psql -h $DB_HOST -p $DB_PORT -d $DB_NAME
```

### Vérifier les variables exportées

```bash
#!/bin/bash

# Lister toutes les variables exportées
export -p

# Lister toutes les variables (exportées et non exportées)
declare -p

# Voir si une variable est exportée
export | grep MA_VARIABLE
```

> [!warning] Modification par l'enfant Si un processus enfant modifie une variable exportée, cette modification ne remonte **pas** au parent. Chaque processus a sa propre copie.

```bash
#!/bin/bash

export compteur=0
echo "Parent avant : $compteur"

# Le sous-processus modifie sa copie
bash -c 'export compteur=10; echo "Enfant : $compteur"'

echo "Parent après : $compteur"  # Toujours 0 !
```

---

## 🧬 Héritage des variables

### Direction de l'héritage

L'héritage des variables en Bash est **unidirectionnel** : du parent vers l'enfant uniquement.

```
┌─────────────┐
│   Parent    │
│  var=value  │
│  export var │
└──────┬──────┘
       │
       ↓ (héritage)
┌──────────────┐
│    Enfant    │
│  var=value   │  ← Reçoit la copie
└──────────────┘
```

### Tableau récapitulatif

|Type de variable|Accessible dans script|Accessible dans fonction|Accessible dans sous-processus|
|---|---|---|---|
|Variable simple|✅ Oui|✅ Oui|❌ Non|
|Variable `local`|❌ Non (hors fonction)|✅ Oui (fonction actuelle)|❌ Non|
|Variable `export`|✅ Oui|✅ Oui|✅ Oui|

### Exemple complet d'héritage

```bash
#!/bin/bash

# Variables de différents types
var_simple="Simple"
local_var="Local"  # N'a de sens que dans une fonction
export var_exportee="Exportée"

test_heritage() {
    echo "=== Dans la fonction ==="
    echo "Simple : $var_simple"
    echo "Exportée : $var_exportee"
    
    # Variable locale à cette fonction
    local var_locale_fonction="Locale fonction"
    echo "Locale fonction : $var_locale_fonction"
}

test_heritage

echo -e "\n=== Dans un sous-shell ==="
bash -c '
    echo "Simple : $var_simple"
    echo "Exportée : $var_exportee"
'

echo -e "\n=== Après le sous-shell ==="
echo "var_locale_fonction : $var_locale_fonction"  # Vide (hors de la fonction)
```

### Chaîne d'héritage

```bash
#!/bin/bash
# grand_parent.sh

export GENERATION="Grand-parent"
export NIVEAU=1

echo "Grand-parent (niveau $NIVEAU) : $GENERATION"

# Appelle le parent
./parent.sh
```

```bash
#!/bin/bash
# parent.sh

# Hérite de GENERATION et NIVEAU
echo "Parent (niveau $NIVEAU) : $GENERATION"

# Modifie et exporte
export GENERATION="$GENERATION > Parent"
export NIVEAU=$((NIVEAU + 1))

# Appelle l'enfant
./enfant.sh
```

```bash
#!/bin/bash
# enfant.sh

# Hérite des modifications du parent
echo "Enfant (niveau $NIVEAU) : $GENERATION"
```

**Sortie :**

```
Grand-parent (niveau 1) : Grand-parent
Parent (niveau 1) : Grand-parent
Enfant (niveau 2) : Grand-parent > Parent
```

### Sous-shells vs scripts séparés

```bash
#!/bin/bash

export VAR="Originale"

# Sous-shell (entre parenthèses) - hérite et peut modifier localement
(
    VAR="Modifiée dans sous-shell"
    echo "Sous-shell : $VAR"
)
echo "Après sous-shell : $VAR"  # Toujours "Originale"

# Script séparé - hérite aussi
echo '#!/bin/bash
echo "Script séparé : $VAR"
VAR="Modifiée dans script"
echo "Script modifié : $VAR"' > temp.sh
chmod +x temp.sh
./temp.sh
echo "Après script : $VAR"  # Toujours "Originale"
rm temp.sh
```

---

## ⚠️ Pièges courants

### 1. Modification involontaire de variables globales

```bash
#!/bin/bash

compteur=0

incrementer() {
    # PIÈGE : modifie la variable globale sans le vouloir
    compteur=$((compteur + 1))
}

incrementer
echo $compteur  # 1 (peut être inattendu)

# SOLUTION : utiliser local
incrementer_safe() {
    local compteur=0
    compteur=$((compteur + 1))
    echo $compteur
}
```

### 2. Oublier `export` pour les sous-processus

```bash
#!/bin/bash

# PIÈGE : la variable ne sera pas vue par les enfants
CONFIG_FILE="/etc/app.conf"

# Lance un script qui a besoin de CONFIG_FILE
./setup.sh  # Ne verra pas CONFIG_FILE

# SOLUTION : exporter
export CONFIG_FILE="/etc/app.conf"
./setup.sh  # Verra CONFIG_FILE
```

### 3. Croire que les modifications remontent

```bash
#!/bin/bash

export valeur=10

# PIÈGE : penser que cette modification remonte
bash -c 'valeur=20; echo "Enfant : $valeur"'

echo "Parent : $valeur"  # Toujours 10 !

# SOLUTION : utiliser des fichiers temporaires ou la sortie standard
nouveau_valeur=$(bash -c 'echo 20')
valeur=$nouveau_valeur
```

### 4. Confusion entre `local` et portée de bloc

```bash
#!/bin/bash

# PIÈGE : Bash n'a pas de portée de bloc (contrairement à C/Java)
if [ true ]; then
    var_if="Dans if"
fi

echo $var_if  # Accessible ! (pas de portée de bloc)

# SOLUTION : utiliser des fonctions avec local
creer_scope() {
    local var_locale="Dans fonction"
    echo $var_locale
}
creer_scope
echo $var_locale  # Vide (bonne isolation)
```

### 5. Utilisation excessive de variables globales

```bash
#!/bin/bash

# MAUVAIS : trop de globales
resultat=""
erreur=""
statut=0

fonction1() {
    resultat="valeur1"
    erreur=""
    statut=0
}

fonction2() {
    # Peut accidentellement écraser les valeurs de fonction1
    resultat="valeur2"
}

# MEILLEUR : retourner des valeurs
fonction1_amelioree() {
    echo "valeur1"
    return 0
}

resultat=$(fonction1_amelioree)
statut=$?
```

---

## ✅ Bonnes pratiques

### 1. Utiliser `local` systématiquement dans les fonctions

```bash
#!/bin/bash

# ✅ BONNE PRATIQUE
calculer_somme() {
    local a=$1
    local b=$2
    local resultat=$((a + b))
    
    echo $resultat
}

# Utilisation
somme=$(calculer_somme 5 3)
echo "Somme : $somme"
```

### 2. Exporter explicitement les variables nécessaires

```bash
#!/bin/bash

# ✅ BONNE PRATIQUE : être explicite
export API_KEY="secret123"
export API_URL="https://api.example.com"
export DEBUG_MODE="true"

# Documentation claire de ce qui est exporté
echo "Variables d'environnement configurées :"
export | grep -E "(API_|DEBUG_)"
```

### 3. Préfixer les variables globales

```bash
#!/bin/bash

# ✅ BONNE PRATIQUE : préfixe pour les globales
readonly GLOBAL_APP_NAME="MonApp"
readonly GLOBAL_VERSION="1.0"

# Variables locales sans préfixe
traiter_fichier() {
    local fichier=$1
    local compteur=0
    # ...
}
```

### 4. Utiliser `readonly` pour les constantes

```bash
#!/bin/bash

# ✅ BONNE PRATIQUE : constantes immuables
readonly CONFIG_DIR="/etc/monapp"
readonly MAX_RETRIES=3

# Empêche toute modification accidentelle
# CONFIG_DIR="/tmp"  # Erreur !
```

### 5. Isoler les effets de bord

```bash
#!/bin/bash

# ✅ BONNE PRATIQUE : fonctions sans effets de bord
obtenir_date_formatee() {
    local format=$1
    date "+$format"
}

# Pas de variable globale modifiée
date_actuelle=$(obtenir_date_formatee "%Y-%m-%d")
```

### 6. Documenter les variables exportées

```bash
#!/bin/bash

# ✅ BONNE PRATIQUE : documentation claire

# Variables d'environnement exportées :
# - DB_HOST : adresse du serveur de base de données
# - DB_PORT : port de connexion
# - DB_NAME : nom de la base de données

export DB_HOST="${DB_HOST:-localhost}"
export DB_PORT="${DB_PORT:-5432}"
export DB_NAME="${DB_NAME:-production}"
```

### 7. Nettoyer l'environnement

```bash
#!/bin/bash

# ✅ BONNE PRATIQUE : nettoyer après utilisation
export TEMP_VAR="temporaire"

# ... utilisation ...

# Nettoyer si nécessaire
unset TEMP_VAR
```

### 8. Valider l'héritage des variables critiques

```bash
#!/bin/bash

# ✅ BONNE PRATIQUE : vérifier les variables héritées
if [ -z "$PATH" ]; then
    echo "ERREUR : PATH non défini" >&2
    exit 1
fi

if [ -z "$HOME" ]; then
    echo "ERREUR : HOME non défini" >&2
    exit 1
fi
```

---

## 💡 Astuces avancées

### Astuce 1 : Détecter si une variable est exportée

```bash
#!/bin/bash

verifier_export() {
    local nom_var=$1
    if export -p | grep -q "declare -x $nom_var="; then
        echo "$nom_var est exportée"
    else
        echo "$nom_var n'est pas exportée"
    fi
}

variable_normale="test"
export variable_exportee="test"

verifier_export variable_normale     # N'est pas exportée
verifier_export variable_exportee    # Est exportée
```

### Astuce 2 : Exporter toutes les variables d'un fichier

```bash
#!/bin/bash

# config.env
# API_KEY=abc123
# API_URL=https://api.example.com

# Charger et exporter
set -a  # Active l'export automatique
source config.env
set +a  # Désactive l'export automatique
```

### Astuce 3 : Portée temporaire avec sous-shell

```bash
#!/bin/bash

var="originale"

# Modification temporaire dans un sous-shell
(
    var="temporaire"
    ./script_qui_utilise_var.sh
)

echo $var  # Toujours "originale"
```

### Astuce 4 : Mesurer l'impact mémoire

```bash
#!/bin/bash

# Avant
avant=$(set | wc -l)

# Créer beaucoup de variables
for i in {1..1000}; do
    eval "var_$i='valeur'"
done

# Après
apres=$(set | wc -l)

echo "Variables ajoutées : $((apres - avant))"
```

---