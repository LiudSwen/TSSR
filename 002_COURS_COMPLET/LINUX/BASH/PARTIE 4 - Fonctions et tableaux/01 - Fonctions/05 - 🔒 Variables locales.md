

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

Les variables locales en Bash permettent de limiter la portée d'une variable à l'intérieur d'une fonction uniquement. Cette fonctionnalité est essentielle pour écrire des scripts propres, maintenables et éviter les effets de bord indésirables.

> [!info] Pourquoi utiliser des variables locales ?
> 
> - **Encapsulation** : Les données restent confinées dans la fonction
> - **Éviter les conflits** : Pas de collision avec des variables du même nom ailleurs
> - **Prévisibilité** : Le comportement de la fonction ne dépend pas de l'état global
> - **Maintenabilité** : Facilite la lecture et la modification du code

---

## 🔑 Le mot-clé `local`

Le mot-clé `local` est utilisé pour déclarer une variable comme locale à une fonction. Cette variable n'existera que durant l'exécution de la fonction.

### Syntaxe de base

```bash
function ma_fonction() {
    local ma_variable="valeur"
    # Cette variable n'existe que dans cette fonction
}
```

### Déclarations multiples

```bash
function exemple() {
    # Plusieurs déclarations séparées
    local var1="valeur1"
    local var2="valeur2"
    
    # Ou en une seule ligne
    local var3="valeur3" var4="valeur4"
    
    # Déclaration puis affectation
    local var5
    var5="valeur5"
}
```

> [!example] Exemple complet
> 
> ```bash
> #!/bin/bash
> 
> function calculer_carre() {
>     local nombre=$1          # Paramètre stocké localement
>     local resultat           # Variable locale non initialisée
>     
>     resultat=$((nombre * nombre))
>     echo "Le carré de $nombre est $resultat"
> }
> 
> calculer_carre 5
> # Affiche : Le carré de 5 est 25
> 
> echo "Nombre: $nombre"       # Vide (variable locale)
> echo "Résultat: $resultat"   # Vide (variable locale)
> ```

---

## 🎯 Portée des variables dans les fonctions

La portée (ou scope) d'une variable définit où cette variable est accessible dans le script.

### Variables globales par défaut

Sans le mot-clé `local`, **toutes les variables sont globales** en Bash, même celles déclarées dans une fonction.

```bash
#!/bin/bash

function modifier_variable() {
    ma_variable="modifiée dans la fonction"
}

ma_variable="valeur initiale"
echo "Avant: $ma_variable"      # Avant: valeur initiale

modifier_variable
echo "Après: $ma_variable"      # Après: modifiée dans la fonction
```

> [!warning] Comportement par défaut dangereux Sans `local`, une variable déclarée dans une fonction modifie l'environnement global. C'est une source majeure de bugs difficiles à détecter.

### Variables locales avec `local`

```bash
#!/bin/bash

function modifier_variable() {
    local ma_variable="modifiée dans la fonction"
    echo "Dans fonction: $ma_variable"
}

ma_variable="valeur initiale"
echo "Avant: $ma_variable"      # Avant: valeur initiale

modifier_variable                # Dans fonction: modifiée dans la fonction
echo "Après: $ma_variable"      # Après: valeur initiale
```

### Portée limitée aux fonctions

Le mot-clé `local` ne fonctionne **que dans les fonctions**. L'utiliser en dehors provoque une erreur.

```bash
#!/bin/bash

local variable="test"    # ❌ ERREUR: local can only be used in a function

function ma_fonction() {
    local variable="test"  # ✅ Correct
}
```

---

## 🎭 Masquage de variables globales

Le masquage (shadowing) se produit quand une variable locale porte le même nom qu'une variable globale. La variable locale "masque" temporairement la globale.

### Principe du masquage

```bash
#!/bin/bash

nom="Global"

function afficher_nom() {
    local nom="Local"          # Masque la variable globale
    echo "Dans fonction: $nom" # Affiche "Local"
}

echo "Avant: $nom"             # Avant: Global
afficher_nom                   # Dans fonction: Local
echo "Après: $nom"             # Après: Global
```

### Masquage à plusieurs niveaux

Les fonctions peuvent s'imbriquer, créant plusieurs niveaux de masquage :

```bash
#!/bin/bash

compteur=0

function fonction_externe() {
    local compteur=10
    echo "Externe: $compteur"        # 10
    
    function fonction_interne() {
        local compteur=20
        echo "Interne: $compteur"    # 20
    }
    
    fonction_interne
    echo "Externe après: $compteur"  # 10
}

fonction_externe
echo "Global: $compteur"             # 0
```

> [!tip] Utilité du masquage Le masquage permet de réutiliser des noms de variables courants (comme `i`, `result`, `temp`) sans risque de conflit avec le code global.

### Accéder à la variable globale masquée

Une fois masquée, il n'existe **pas de moyen direct** d'accéder à la variable globale depuis la fonction. Il faut utiliser des astuces :

```bash
#!/bin/bash

valeur="globale"

function traiter() {
    local sauvegarde="$valeur"  # Sauvegarder la globale avant masquage
    local valeur="locale"
    
    echo "Locale: $valeur"
    echo "Globale sauvegardée: $sauvegarde"
}

traiter
```

---

## ⚖️ Variables locales vs globales

### Tableau comparatif

|Caractéristique|Variables locales|Variables globales|
|---|---|---|
|**Déclaration**|`local var="valeur"`|`var="valeur"`|
|**Portée**|Uniquement dans la fonction|Tout le script|
|**Durée de vie**|Disparaît en sortie de fonction|Jusqu'à la fin du script|
|**Isolation**|✅ Protégée des modifications externes|❌ Accessible partout|
|**Performance**|Légèrement plus rapide|Standard|
|**Utilisation**|Dans les fonctions uniquement|N'importe où|

### Quand utiliser chaque type ?

#### Utilisez des variables locales pour :

- **Calculs intermédiaires** dans une fonction
- **Paramètres de fonction** que vous manipulez
- **Variables temporaires** (compteurs, flags, etc.)
- **Tout ce qui n'a pas besoin d'exister en dehors de la fonction**

```bash
function calculer_moyenne() {
    local somme=0              # Calcul intermédiaire
    local count=0              # Compteur temporaire
    local moyenne              # Résultat
    
    for valeur in "$@"; do
        somme=$((somme + valeur))
        count=$((count + 1))
    done
    
    moyenne=$((somme / count))
    echo "$moyenne"
}
```

#### Utilisez des variables globales pour :

- **Configuration** du script (chemins, options)
- **État partagé** entre plusieurs fonctions
- **Résultats** que vous voulez retourner (en complément de `echo`)
- **Constantes** du script

```bash
#!/bin/bash

# Variables globales de configuration
readonly CONFIG_FILE="/etc/app/config"
readonly LOG_FILE="/var/log/app.log"

# Variable d'état globale
ERROR_COUNT=0

function traiter_fichier() {
    local fichier=$1           # Local: paramètre
    local lignes               # Local: temporaire
    
    if [[ ! -f "$fichier" ]]; then
        ERROR_COUNT=$((ERROR_COUNT + 1))  # Modifie le global
        return 1
    fi
    
    lignes=$(wc -l < "$fichier")
    echo "$lignes"
}
```

---

## ⚠️ Pièges courants

### Piège 1 : Oublier `local` dans les fonctions

```bash
#!/bin/bash

function incrementer() {
    compteur=$((compteur + 1))  # ❌ Modifie la variable globale !
}

compteur=0
incrementer
echo "$compteur"  # Affiche 1 au lieu de 0
```

**Solution :**

```bash
function incrementer() {
    local compteur=$1           # ✅ Variable locale
    compteur=$((compteur + 1))
    echo "$compteur"
}

compteur=0
resultat=$(incrementer "$compteur")
echo "Global: $compteur, Résultat: $resultat"  # Global: 0, Résultat: 1
```

### Piège 2 : `local` et codes de retour

Le mot-clé `local` retourne toujours 0, ce qui peut masquer les erreurs :

```bash
#!/bin/bash

function probleme() {
    local result=$(commande_inexistante)  # ❌ $? vaut 0 (succès de local)
    echo "Code retour: $?"                # Affiche 0
}
```

**Solution :**

```bash
function correct() {
    local result
    result=$(commande_inexistante)        # ✅ $? contient le vrai code
    local code=$?
    echo "Code retour: $code"             # Affiche le vrai code d'erreur
    return $code
}
```

### Piège 3 : Confusion entre masquage et modification

```bash
#!/bin/bash

valeur=10

function doubler() {
    valeur=$((valeur * 2))     # Modifie le global
}

function doubler_local() {
    local valeur=$((valeur * 2))  # Crée un nouveau local (ne modifie pas le global)
}

doubler
echo "$valeur"        # Affiche 20

valeur=10
doubler_local
echo "$valeur"        # Affiche 10 (pas modifié)
```

### Piège 4 : Variables locales dans les sous-shells

Les variables locales ne sont pas héritées par les sous-shells :

```bash
#!/bin/bash

function test_subshell() {
    local ma_var="locale"
    
    echo "Direct: $ma_var"              # ✅ Fonctionne
    echo "Subshell: $(echo $ma_var)"    # ✅ Fonctionne (expansion avant subshell)
    
    (echo "Vrai subshell: $ma_var")     # ❌ Vide (nouveau processus)
}
```

---

## ✅ Bonnes pratiques

### 1. Toujours déclarer `local` en début de fonction

```bash
# ✅ Bon
function traiter_donnees() {
    local input=$1
    local output=$2
    local temp
    local result
    
    # ... logique ...
}

# ❌ Mauvais
function traiter_donnees() {
    temp="quelque chose"
    local temp              # Trop tard !
}
```

### 2. Préfixer les variables globales importantes

```bash
# Convention : MAJUSCULES pour les globales importantes
readonly GLOBAL_CONFIG="/etc/config"
GLOBAL_COUNTER=0

function process() {
    local local_var="temporary"  # Minuscules pour les locales
    GLOBAL_COUNTER=$((GLOBAL_COUNTER + 1))
}
```

### 3. Limiter les variables globales

```bash
# ❌ Trop de globales
temp1="x"
temp2="y"
result=""

function calculer() {
    result=$((temp1 + temp2))
}

# ✅ Tout en local, retourner le résultat
function calculer() {
    local a=$1
    local b=$2
    local result=$((a + b))
    echo "$result"
}

result=$(calculer 5 3)
```

### 4. Documenter les variables globales

```bash
#!/bin/bash

# Configuration globale
readonly TIMEOUT=30          # Délai d'attente en secondes
readonly MAX_RETRIES=3       # Nombre de tentatives

# État du script
ERRORS_FOUND=0               # Compteur d'erreurs rencontrées

function traiter() {
    local fichier=$1
    # ...
}
```

### 5. Utiliser `readonly` pour les constantes

```bash
#!/bin/bash

function definir_constantes() {
    local readonly PI=3.14159  # Locale ET constante
    # PI ne peut plus être modifié
}

# Ou au niveau global
readonly VERSION="1.0.0"
readonly CONFIG_DIR="/etc/app"
```

### 6. Pattern de retour de valeur sûr

```bash
#!/bin/bash

# Retour via echo (capture avec $())
function calculer() {
    local result=$((5 * 5))
    echo "$result"
}

# Retour via variable globale (pour structures complexes)
FUNCTION_RESULT=""

function calculer_complexe() {
    local temp=$((5 * 5))
    FUNCTION_RESULT="$temp"
    return 0  # Code de succès
}

# Utilisation
valeur=$(calculer)
calculer_complexe && echo "Résultat: $FUNCTION_RESULT"
```

### 7. Nommage cohérent

```bash
#!/bin/bash

# Convention de nommage claire
function traiter_utilisateur() {
    local user_name=$1           # Paramètre
    local user_email=$2          # Paramètre
    local _temp_result           # Variable interne (préfixe _)
    local is_valid=false         # Flag booléen
    
    # ... logique ...
}
```

---

> [!tip] Astuce finale **Règle d'or** : Par défaut, utilisez `local` pour toutes les variables dans vos fonctions. N'utilisez des variables globales que lorsque c'est vraiment nécessaire et documentez-les clairement.