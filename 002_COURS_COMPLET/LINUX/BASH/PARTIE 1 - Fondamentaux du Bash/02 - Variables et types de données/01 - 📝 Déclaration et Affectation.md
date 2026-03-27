# 📝 Déclaration et Affectation en Bash

## 📚 Table des matières

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

Les variables en bash sont des conteneurs qui stockent des valeurs (texte, nombres, chemins, etc.). Contrairement à d'autres langages, bash est non typé : une variable peut contenir n'importe quel type de données sous forme de chaîne de caractères.

> [!info] Pourquoi apprendre la déclaration de variables ?
> 
> - Stocker des informations pour les réutiliser
> - Rendre les scripts plus flexibles et maintenables
> - Éviter la répétition de valeurs dans le code
> - Faciliter la modification et la configuration

---

## ⚡ Syntaxe de base

### Déclaration et affectation

La syntaxe pour créer une variable en bash est simple mais stricte :

```bash
variable=valeur
```

> [!warning] Règle d'or : PAS D'ESPACES autour du `=`
> 
> ```bash
> # ✅ CORRECT
> nom="Alice"
> age=25
> chemin="/home/user"
> 
> # ❌ INCORRECT - Provoque des erreurs
> nom = "Alice"      # Erreur : bash pense que "nom" est une commande
> age= 25            # Erreur de syntaxe
> chemin = "/home"   # Erreur : espaces non autorisés
> ```

### Exemples de déclarations valides

```bash
# Variables simples
utilisateur="admin"
port=8080
actif=true

# Variables avec chemins
repertoire="/var/log/app"
fichier_config="$HOME/.bashrc"

# Variables vides
resultat=""
temporaire=

# Variables avec des caractères spéciaux (nécessitent des guillemets)
message="Bonjour le monde !"
commande="ls -la"
path="/usr/local/bin:/usr/bin"
```

### Convention de nommage

```bash
# Style recommandé : snake_case (minuscules avec underscores)
nom_utilisateur="Alice"
chemin_fichier="/tmp/data.txt"
nombre_tentatives=3

# Variables d'environnement : MAJUSCULES
export PATH="/usr/local/bin:$PATH"
export DATABASE_URL="postgresql://localhost/mydb"

# Variables locales : minuscules
compteur=0
resultat=""
```

> [!tip] Astuce de nommage
> 
> - Utilisez des noms descriptifs et explicites
> - Préférez `nombre_utilisateurs` à `nb` ou `n`
> - Les variables d'environnement importantes sont traditionnellement en MAJUSCULES
> - Les variables locales de script sont en minuscules

---

## 🔧 Utilisation des variables

### Syntaxe d'accès : `$variable`

Pour accéder à la valeur d'une variable, on préfixe son nom avec `$` :

```bash
# Déclaration
nom="Bob"
age=30

# Utilisation simple
echo $nom           # Affiche : Bob
echo "Age: $age"    # Affiche : Age: 30

# Dans des commandes
mkdir $nom          # Crée un dossier nommé "Bob"
cd /home/$nom       # Change vers /home/Bob
```

### Syntaxe avec accolades : `${variable}`

Les accolades permettent de délimiter clairement le nom de la variable, notamment pour éviter les ambiguïtés :

```bash
# Sans accolades - ambiguïté
fruit="pomme"
echo "$fruits"      # Affiche rien ! Bash cherche la variable "fruits"

# Avec accolades - clarté
echo "${fruit}s"    # Affiche : pommes (correct)

# Concaténation avec texte
prenom="Jean"
echo "${prenom}_fichier.txt"    # Affiche : Jean_fichier.txt
echo "$prenom_fichier.txt"      # Erreur : cherche $prenom_fichier
```

> [!example] Quand utiliser les accolades ?
> 
> ```bash
> # Cas 1 : Concaténation immédiate
> base="rapport"
> fichier="${base}_2024.pdf"    # rapport_2024.pdf
> 
> # Cas 2 : Variables dans des chaînes complexes
> utilisateur="admin"
> echo "Bienvenue ${utilisateur}123"    # Bienvenue admin123
> 
> # Cas 3 : Manipulation de variables (vu dans d'autres parties)
> chemin="/home/user/document.txt"
> echo "${chemin%.txt}.pdf"    # /home/user/document.pdf
> ```

### Différence entre guillemets simples et doubles

```bash
nom="Alice"
age=25

# Guillemets doubles : les variables sont interprétées
echo "Nom: $nom, Age: $age"     # Affiche : Nom: Alice, Age: 25

# Guillemets simples : texte littéral (pas d'interprétation)
echo 'Nom: $nom, Age: $age'     # Affiche : Nom: $nom, Age: $age

# Sans guillemets : attention aux espaces et caractères spéciaux
message="Bonjour le monde"
echo $message      # Fonctionne mais peut causer des problèmes
echo "$message"    # Plus sûr (recommandé)
```

> [!warning] Pièges avec les guillemets
> 
> ```bash
> fichier="mon document.txt"
> 
> # ❌ DANGER : sans guillemets
> cat $fichier    # Erreur : bash voit 2 arguments "mon" et "document.txt"
> 
> # ✅ CORRECT : avec guillemets
> cat "$fichier"  # Fonctionne correctement
> ```

### Tableau comparatif

|Syntaxe|Utilisation|Exemple|Résultat|
|---|---|---|---|
|`$var`|Accès simple|`echo $nom`|Alice|
|`${var}`|Accès avec délimitation|`echo ${nom}123`|Alice123|
|`"$var"`|Avec guillemets doubles|`echo "$nom"`|Alice (sûr)|
|`'$var'`|Avec guillemets simples|`echo '$nom'`|$nom (littéral)|

---

## 🔒 Variables en lecture seule

Les variables en lecture seule sont des constantes qui ne peuvent plus être modifiées après leur déclaration.

### Syntaxe avec `readonly`

```bash
# Méthode 1 : déclaration puis readonly
API_KEY="sk-1234567890abcdef"
readonly API_KEY

# Méthode 2 : déclaration et readonly en une ligne
readonly VERSION="1.2.3"

# Méthode 3 : avec declare -r
declare -r MAX_TENTATIVES=5
```

### Comportement des variables readonly

```bash
readonly PI=3.14159

# ✅ Lecture autorisée
echo "Pi vaut $PI"
calcul=$(echo "$PI * 2" | bc)

# ❌ Modification interdite
PI=3.14    # Erreur : bash: PI: readonly variable

# ❌ Suppression interdite
unset PI   # Erreur : bash: unset: PI: cannot unset: readonly variable
```

> [!info] Quand utiliser readonly ?
> 
> - Valeurs de configuration qui ne doivent jamais changer
> - Constantes mathématiques ou applicatives
> - Clés API ou tokens sensibles (pour éviter les modifications accidentelles)
> - Chemins système critiques

### Exemples pratiques

```bash
#!/bin/bash

# Configuration du script (constantes)
readonly SCRIPT_NAME="backup.sh"
readonly VERSION="2.1.0"
readonly LOG_DIR="/var/log/backup"
readonly MAX_BACKUPS=7

# Clés et tokens
readonly DB_HOST="localhost"
readonly DB_PORT=5432

# Utilisation
echo "Démarrage de $SCRIPT_NAME v$VERSION"
echo "Logs dans : $LOG_DIR"
```

### Lister les variables readonly

```bash
# Afficher toutes les variables en lecture seule
readonly

# Ou avec declare
declare -r

# Vérifier si une variable est readonly
readonly -p | grep "^declare -r MA_VARIABLE="
```

---

## 🗑️ Suppression de variables

La commande `unset` permet de supprimer une variable de l'environnement du shell.

### Syntaxe de base

```bash
# Créer une variable
temporaire="valeur temporaire"
echo "$temporaire"    # Affiche : valeur temporaire

# Supprimer la variable
unset temporaire

# La variable n'existe plus
echo "$temporaire"    # Affiche : (rien)
```

### Comportements et cas d'usage

```bash
# Nettoyage de variables temporaires
fichier_tmp="/tmp/data_$$"
echo "Traitement..." > "$fichier_tmp"
# ... traitement ...
rm "$fichier_tmp"
unset fichier_tmp

# Libération de mémoire (pour de grandes variables)
grosse_donnee=$(cat fichier_volumineux.txt)
# ... utilisation ...
unset grosse_donnee    # Libère la mémoire

# Réinitialisation avant réutilisation
resultat="ancienne valeur"
unset resultat
resultat="nouvelle valeur"
```

### Différence entre unset et affectation vide

```bash
# Variable vide (existe toujours)
var1=""
echo "var1 existe : ${var1-non définie}"    # Affiche : var1 existe :

# Variable supprimée (n'existe plus)
var2="valeur"
unset var2
echo "var2 existe : ${var2-non définie}"    # Affiche : var2 existe : non définie
```

> [!warning] Limitations de unset
> 
> ```bash
> # ❌ Ne peut pas supprimer les variables readonly
> readonly CONSTANTE="fixe"
> unset CONSTANTE    # Erreur : cannot unset: readonly variable
> 
> # ⚠️ Attention avec les variables d'environnement
> unset PATH    # Dangereux ! Supprime le PATH (rend le shell inutilisable)
> 
> # ✅ Vérifier avant de supprimer des variables importantes
> if [[ "$variable_a_supprimer" != "PATH" ]]; then
>     unset variable_a_supprimer
> fi
> ```

### Test d'existence de variable

```bash
# Vérifier si une variable existe
if [[ -v MA_VARIABLE ]]; then
    echo "La variable existe"
else
    echo "La variable n'existe pas"
fi

# Avec paramètre d'expansion (autre méthode)
echo "${MA_VARIABLE+existe}${MA_VARIABLE-n'existe pas}"
```

---

## ⚠️ Pièges courants

### 1. Espaces autour du signe `=`

```bash
# ❌ ERREUR CLASSIQUE
nom = "Alice"
# bash interprète : exécuter la commande "nom" avec les arguments "=" et "Alice"

# ✅ CORRECT
nom="Alice"
```

### 2. Oublier le `$` lors de l'accès

```bash
prenom="Bob"

# ❌ ERREUR : utilise le texte littéral "prenom"
echo "Bonjour prenom"    # Affiche : Bonjour prenom

# ✅ CORRECT : accède à la valeur
echo "Bonjour $prenom"   # Affiche : Bonjour Bob
```

### 3. Variables non quotées avec espaces

```bash
fichier="mon document.txt"

# ❌ DANGER : bash sépare en 2 arguments
cat $fichier         # Erreur : cherche "mon" et "document.txt"
rm $fichier          # Dangereux : supprime 2 fichiers !

# ✅ SÉCURISÉ : toujours quoter
cat "$fichier"
rm "$fichier"
```

### 4. Confusion entre `=` et `-eq`

```bash
nombre=5

# ❌ ERREUR : utilise = pour comparer des nombres (syntaxe test/[])
if [ $nombre = 5 ]; then    # Fonctionne mais déconseillé pour nombres
    echo "égal"
fi

# ✅ CORRECT : utilise -eq pour comparer des nombres
if [ $nombre -eq 5 ]; then
    echo "égal"
fi

# Pour les chaînes, = est correct
nom="Alice"
if [ "$nom" = "Alice" ]; then
    echo "C'est Alice"
fi
```

### 5. Variables dans les boucles

```bash
# ❌ PIÈGE : la variable de boucle écrase une variable existante
i="important"
for i in 1 2 3; do
    echo $i    # 1, 2, 3
done
echo $i        # 3 (la valeur "important" est perdue !)

# ✅ SOLUTION : utiliser des noms différents
valeur_importante="important"
for i in 1 2 3; do
    echo $i
done
echo $valeur_importante    # "important" (préservé)
```

### 6. Export de variables

```bash
# Variable locale (uniquement dans le script actuel)
LOCAL_VAR="local"

# ❌ Les sous-processus ne voient pas les variables locales
bash -c 'echo $LOCAL_VAR'    # Affiche : (rien)

# ✅ Exporter pour rendre disponible aux sous-processus
export GLOBAL_VAR="global"
bash -c 'echo $GLOBAL_VAR'   # Affiche : global
```

---

## ✨ Bonnes pratiques

### 1. Toujours quoter les variables

```bash
# ✅ Bonne pratique
fichier="mon fichier.txt"
if [[ -f "$fichier" ]]; then
    cat "$fichier"
fi

# Protection contre les valeurs vides
utilisateur="${1:-anonyme}"
echo "Utilisateur : $utilisateur"
```

### 2. Utiliser des noms explicites

```bash
# ❌ Noms cryptiques
x="data.txt"
n=5
t=$(date +%s)

# ✅ Noms descriptifs
fichier_donnees="data.txt"
nombre_tentatives=5
timestamp_debut=$(date +%s)
```

### 3. Initialiser les variables

```bash
# ✅ Initialisation claire en début de script
compteur=0
resultat=""
fichiers_traites=0

# Évite les erreurs "unbound variable" avec set -u
```

### 4. Utiliser readonly pour les constantes

```bash
# ✅ Protéger les valeurs importantes
readonly CONFIG_FILE="/etc/myapp/config.conf"
readonly MAX_RETRY=3
readonly VERSION="1.0.0"

# Impossible de modifier accidentellement
```

### 5. Grouper les déclarations

```bash
#!/bin/bash

# === Configuration ===
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_FILE="${SCRIPT_DIR}/app.log"
readonly MAX_SIZE=1048576

# === Variables globales ===
erreur_count=0
fichiers_traites=0

# === Variables temporaires ===
temp_file=""
pid_actuel=$$
```

### 6. Nettoyer les variables temporaires

```bash
# ✅ Nettoyage en fin de script ou dans un trap
temp_dir=$(mktemp -d)
trap 'rm -rf "$temp_dir"; unset temp_dir' EXIT

# Utilisation
cp donnees.txt "$temp_dir/"
# ... traitement ...
# Nettoyage automatique à la sortie
```

### 7. Documenter les variables importantes

```bash
# Chemin vers le fichier de configuration principal
# Format : INI avec sections [section] et clés=valeur
readonly CONFIG_FILE="/etc/app/config.ini"

# Nombre maximum de tentatives de connexion avant abandon
# Valeur par défaut : 3, Min : 1, Max : 10
readonly MAX_RETRY=3

# Active le mode debug (1) ou production (0)
# En mode debug, affiche les logs détaillés
DEBUG_MODE=${DEBUG_MODE:-0}
```

> [!tip] Astuces avancées
> 
> ```bash
> # Valeur par défaut si variable non définie
> port=${PORT:-8080}
> 
> # Erreur si variable non définie
> fichier=${FICHIER:?Erreur: FICHIER non défini}
> 
> # Valeur alternative si variable vide ou non définie
> utilisateur=${USER:-${USERNAME:-invité}}
> 
> # Longueur d'une variable
> texte="Bonjour"
> echo ${#texte}    # Affiche : 7
> ```

---