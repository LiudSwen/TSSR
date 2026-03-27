

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

Les tableaux associatifs (aussi appelés dictionnaires ou maps) permettent d'associer des **clés** (chaînes de caractères) à des **valeurs**, contrairement aux tableaux indexés qui utilisent des indices numériques.

> [!info] Pourquoi utiliser les tableaux associatifs ?
> 
> - Stocker des données structurées avec des identifiants significatifs
> - Créer des systèmes de configuration clé-valeur
> - Mapper des relations (ex: utilisateur → email)
> - Éviter les recherches linéaires dans des tableaux indexés
> - Améliorer la lisibilité du code avec des clés descriptives

> [!warning] Disponibilité Les tableaux associatifs sont disponibles **uniquement à partir de Bash 4.0**. Vérifiez votre version avec `bash --version`.

---

## 📝 Déclaration et initialisation

### Déclaration de base

Pour créer un tableau associatif, utilisez la commande `declare -A` :

```bash
# Déclaration d'un tableau associatif vide
declare -A mon_tableau

# Déclaration avec initialisation
declare -A utilisateurs=(
    [alice]="alice@example.com"
    [bob]="bob@example.com"
    [charlie]="charlie@example.com"
)
```

> [!warning] Le flag `-A` est obligatoire Sans `declare -A`, Bash traite la variable comme un tableau indexé classique, ce qui peut créer des comportements inattendus.

### Différentes méthodes d'initialisation

```bash
# Méthode 1 : Déclaration puis affectation
declare -A config
config[host]="localhost"
config[port]="8080"
config[protocol]="https"

# Méthode 2 : Initialisation en une ligne
declare -A config=([host]="localhost" [port]="8080" [protocol]="https")

# Méthode 3 : Initialisation multiligne (plus lisible)
declare -A config=(
    [host]="localhost"
    [port]="8080"
    [protocol]="https"
    [timeout]="30"
)
```

> [!tip] Astuce de lisibilité Pour les tableaux avec plusieurs entrées, privilégiez l'initialisation multiligne pour une meilleure maintenance du code.

---

## 🔑 Syntaxe clé-valeur

### Affectation de valeurs

```bash
declare -A dictionnaire

# Affectation simple
dictionnaire[nom]="Jean"
dictionnaire[prenom]="Dupont"
dictionnaire[age]="35"

# Les clés peuvent contenir des caractères spéciaux
dictionnaire[email_principal]="jean.dupont@mail.com"
dictionnaire[date-naissance]="1989-05-15"

# Les valeurs peuvent contenir des espaces
dictionnaire[adresse]="12 rue de la Paix, Paris"
```

### Caractères autorisés dans les clés

```bash
declare -A exemples

# ✓ Valide
exemples[user_name]="ok"
exemples[user-name]="ok"
exemples[user.name]="ok"
exemples[user123]="ok"
exemples[USER_NAME]="ok"

# ⚠️ Nécessite des guillemets
exemples["user name"]="espaces nécessitent des guillemets"
exemples["user@name"]="arobase nécessite des guillemets"
```

> [!warning] Clés sensibles à la casse `config[Host]` et `config[host]` sont deux clés différentes !

### Modification et suppression

```bash
declare -A data
data[key1]="valeur1"

# Modification
data[key1]="nouvelle_valeur"

# Suppression d'une clé
unset data[key1]

# Suppression de tout le tableau
unset data
```

---

## 🔍 Accès aux valeurs

### Syntaxe de base

```bash
declare -A utilisateur=(
    [nom]="Martin"
    [prenom]="Sophie"
    [age]="28"
)

# Accès à une valeur
echo "${utilisateur[nom]}"           # Affiche: Martin
echo "${utilisateur[prenom]}"        # Affiche: Sophie

# Utilisation dans une variable
nom_complet="${utilisateur[prenom]} ${utilisateur[nom]}"
echo "$nom_complet"                  # Affiche: Sophie Martin
```

> [!warning] Toujours utiliser les accolades Utilisez `${tableau[cle]}` et non `$tableau[cle]`. Sans accolades, Bash interprète incorrectement l'expression.

### Valeurs par défaut

```bash
declare -A config=(
    [timeout]="30"
)

# Si la clé n'existe pas, affiche une valeur par défaut
echo "${config[retry]:-3}"           # Affiche: 3 (valeur par défaut)
echo "${config[timeout]:-5}"         # Affiche: 30 (valeur existante)

# Assigner une valeur par défaut si la clé n'existe pas
echo "${config[max_connections]:=100}"  # Affiche 100 et crée la clé
echo "${config[max_connections]}"       # Affiche: 100
```

### Concaténation et manipulation

```bash
declare -A paths=(
    [home]="/home/user"
    [config]=".config"
)

# Concaténation
full_path="${paths[home]}/${paths[config]}/app.conf"
echo "$full_path"  # /home/user/.config/app.conf

# Manipulation de chaîne
url="${paths[base_url]}/api/v1"
upper_key="${paths[env]^^}"  # Conversion en majuscules
```

---

## 🗝️ Liste des clés

### Obtenir toutes les clés

```bash
declare -A contacts=(
    [alice]="555-1234"
    [bob]="555-5678"
    [charlie]="555-9012"
)

# Lister toutes les clés
echo "${!contacts[@]}"
# Affiche: alice bob charlie (ordre non garanti)

# Stocker les clés dans un tableau
keys=("${!contacts[@]}")
echo "Nombre de clés: ${#keys[@]}"
```

> [!info] Ordre des clés L'ordre des clés n'est **pas garanti** dans les tableaux associatifs. Ne comptez jamais sur un ordre spécifique.

### Utilisation avec boucles

```bash
declare -A serveurs=(
    [web]="192.168.1.10"
    [db]="192.168.1.20"
    [cache]="192.168.1.30"
)

# Afficher toutes les clés
echo "Serveurs disponibles:"
for cle in "${!serveurs[@]}"; do
    echo "  - $cle"
done
```

### Compter les éléments

```bash
declare -A stock=(
    [pommes]="50"
    [poires]="30"
    [bananes]="75"
)

# Nombre total d'éléments
nb_produits="${#stock[@]}"
echo "Nombre de produits: $nb_produits"  # Affiche: 3
```

---

## ✅ Vérification d'existence de clé

### Test avec paramètre expansion

```bash
declare -A config=(
    [debug]="true"
    [verbose]="false"
)

# Vérifier si une clé existe
if [[ -v config[debug] ]]; then
    echo "La clé 'debug' existe"
fi

if [[ -v config[production] ]]; then
    echo "La clé 'production' existe"
else
    echo "La clé 'production' n'existe pas"
fi
```

> [!tip] Opérateur `-v` L'opérateur `-v` (disponible depuis Bash 4.2) est la méthode recommandée pour tester l'existence d'une clé.

### Méthode alternative (Bash < 4.2)

```bash
declare -A data=(
    [key1]="value1"
)

# Méthode compatible avec les anciennes versions
if [[ -n "${data[key1]+x}" ]]; then
    echo "key1 existe"
fi

# Attention : cette méthode ne fonctionne pas si la valeur est vide
data[key2]=""
if [[ -n "${data[key2]+x}" ]]; then
    echo "key2 existe (même avec valeur vide)"
fi
```

### Gestion sécurisée des clés manquantes

```bash
declare -A db_config=(
    [host]="localhost"
    [port]="5432"
)

# Fonction pour obtenir une valeur avec gestion d'erreur
get_config() {
    local key="$1"
    if [[ -v db_config[$key] ]]; then
        echo "${db_config[$key]}"
    else
        echo "ERREUR: Clé '$key' non trouvée" >&2
        return 1
    fi
}

# Utilisation
host=$(get_config "host")      # OK
user=$(get_config "user")      # Affiche une erreur
```

---

## 🔄 Parcours des tableaux associatifs

### Parcourir les clés

```bash
declare -A notes=(
    [maths]="15"
    [physique]="17"
    [francais]="14"
)

# Méthode 1 : Parcourir les clés
echo "Notes obtenues:"
for matiere in "${!notes[@]}"; do
    echo "$matiere: ${notes[$matiere]}/20"
done
```

### Parcourir clés et valeurs simultanément

```bash
declare -A prix=(
    [pomme]="2.50"
    [orange]="3.00"
    [banane]="1.80"
)

# Affichage formaté
echo "Liste des prix:"
for fruit in "${!prix[@]}"; do
    printf "%-10s : %s €\n" "$fruit" "${prix[$fruit]}"
done
```

> [!example] Résultat
> 
> ```
> Liste des prix:
> pomme      : 2.50 €
> orange     : 3.00 €
> banane     : 1.80 €
> ```

### Parcours avec traitement conditionnel

```bash
declare -A utilisateurs=(
    [admin]="actif"
    [user1]="actif"
    [user2]="inactif"
    [user3]="actif"
)

# Compter les utilisateurs actifs
actifs=0
for user in "${!utilisateurs[@]}"; do
    if [[ "${utilisateurs[$user]}" == "actif" ]]; then
        ((actifs++))
        echo "✓ $user est actif"
    fi
done
echo "Total: $actifs utilisateurs actifs"
```

### Parcours avec tableau trié

```bash
declare -A scores=(
    [alice]="95"
    [bob]="87"
    [charlie]="92"
)

# Trier les clés alphabétiquement
echo "Scores par ordre alphabétique:"
for joueur in $(echo "${!scores[@]}" | tr ' ' '\n' | sort); do
    echo "$joueur: ${scores[$joueur]}"
done
```

### Parcours avec modification

```bash
declare -A compteurs=(
    [visites]="100"
    [clicks]="250"
    [conversions]="15"
)

# Augmenter tous les compteurs de 10%
for cle in "${!compteurs[@]}"; do
    valeur="${compteurs[$cle]}"
    nouvelle_valeur=$((valeur + valeur / 10))
    compteurs[$cle]="$nouvelle_valeur"
done

# Vérification
for cle in "${!compteurs[@]}"; do
    echo "$cle: ${compteurs[$cle]}"
done
```

---

## 🔧 Opérations avancées

### Copie de tableaux associatifs

```bash
declare -A original=(
    [key1]="value1"
    [key2]="value2"
)

# Copie d'un tableau associatif
declare -A copie
for cle in "${!original[@]}"; do
    copie[$cle]="${original[$cle]}"
done
```

### Fusion de tableaux

```bash
declare -A config_defaut=(
    [timeout]="30"
    [retry]="3"
    [debug]="false"
)

declare -A config_user=(
    [timeout]="60"
    [verbose]="true"
)

# Fusion (config_user écrase config_defaut)
declare -A config_final
for cle in "${!config_defaut[@]}"; do
    config_final[$cle]="${config_defaut[$cle]}"
done
for cle in "${!config_user[@]}"; do
    config_final[$cle]="${config_user[$cle]}"
done
```

### Filtrage de valeurs

```bash
declare -A produits=(
    [laptop]="1200"
    [souris]="25"
    [clavier]="80"
    [ecran]="350"
)

# Filtrer les produits > 100€
declare -A produits_premium
for produit in "${!produits[@]}"; do
    prix="${produits[$produit]}"
    if ((prix > 100)); then
        produits_premium[$produit]="$prix"
    fi
done
```

### Sérialisation et désérialisation

```bash
declare -A config=(
    [host]="localhost"
    [port]="8080"
    [ssl]="true"
)

# Sérialisation en chaîne
serialize() {
    local -n tableau=$1
    local resultat=""
    for cle in "${!tableau[@]}"; do
        resultat+="$cle=${tableau[$cle]};"
    done
    echo "$resultat"
}

# Désérialisation
deserialize() {
    local -n tableau=$1
    local chaine=$2
    IFS=';' read -ra paires <<< "$chaine"
    for paire in "${paires[@]}"; do
        if [[ -n "$paire" ]]; then
            IFS='=' read -r cle valeur <<< "$paire"
            tableau[$cle]="$valeur"
        fi
    done
}

# Utilisation
config_str=$(serialize config)
echo "Sérialisé: $config_str"

declare -A nouveau_config
deserialize nouveau_config "$config_str"
```

---

## ⚠️ Pièges courants

### Piège 1 : Oublier `declare -A`

```bash
# ❌ INCORRECT
tableau[key]="value"
echo "${tableau[key]}"  # Peut ne pas fonctionner comme attendu

# ✅ CORRECT
declare -A tableau
tableau[key]="value"
echo "${tableau[key]}"
```

### Piège 2 : Clés avec espaces

```bash
declare -A data

# ❌ INCORRECT
data[ma cle]="value"  # Erreur de syntaxe

# ✅ CORRECT
data["ma cle"]="value"
echo "${data[ma cle]}"
```

### Piège 3 : Guillemets oubliés lors de l'accès

```bash
declare -A config=([user-name]="john")

# ❌ INCORRECT (peut causer des problèmes)
echo ${config[user-name]}

# ✅ CORRECT
echo "${config[user-name]}"
```

### Piège 4 : Supposer un ordre spécifique

```bash
declare -A alphabet=(
    [a]="1"
    [b]="2"
    [c]="3"
)

# ❌ L'ordre n'est PAS garanti
for lettre in "${!alphabet[@]}"; do
    echo "$lettre"  # Peut afficher: b c a (ordre aléatoire)
done

# ✅ Trier explicitement si nécessaire
for lettre in $(echo "${!alphabet[@]}" | tr ' ' '\n' | sort); do
    echo "$lettre"  # Affiche: a b c
done
```

### Piège 5 : Test d'existence incorrecte

```bash
declare -A data=(
    [key1]="value"
    [key2]=""
)

# ❌ INCORRECT (ne détecte pas les valeurs vides)
if [[ -n "${data[key2]}" ]]; then
    echo "key2 existe"  # Ne s'exécute pas !
fi

# ✅ CORRECT
if [[ -v data[key2] ]]; then
    echo "key2 existe"  # S'exécute correctement
fi
```

### Piège 6 : Passage en paramètre de fonction

```bash
declare -A original=(
    [key]="value"
)

# ❌ INCORRECT (perd le type associatif)
fonction() {
    local tableau=$1
    echo "${tableau[key]}"  # Ne fonctionne pas
}
fonction "${original[@]}"

# ✅ CORRECT (utiliser nameref)
fonction() {
    local -n tableau=$1
    echo "${tableau[key]}"  # Fonctionne
}
fonction original
```

---

## 💡 Bonnes pratiques

### 1. Nommage cohérent

```bash
# ✅ Utilisez des noms descriptifs
declare -A user_credentials
declare -A server_config
declare -A error_messages

# ✅ Convention de nommage cohérente
declare -A db_connection_params
declare -A api_endpoints
declare -A cache_settings
```

### 2. Initialisation explicite

```bash
# ✅ Déclarez toujours explicitement
declare -A config=(
    [timeout]="30"
    [retry]="3"
)

# ✅ Documentez les clés attendues
declare -A api_config=(
    [base_url]="https://api.example.com"
    [api_key]=""        # À remplir
    [timeout]="30"
    [retry]="3"
)
```

### 3. Validation des entrées

```bash
declare -A allowed_envs=(
    [dev]="development"
    [staging]="staging"
    [prod]="production"
)

set_environment() {
    local env=$1
    if [[ -v allowed_envs[$env] ]]; then
        echo "Environnement: ${allowed_envs[$env]}"
    else
        echo "ERREUR: Environnement '$env' invalide" >&2
        echo "Environnements autorisés: ${!allowed_envs[@]}" >&2
        return 1
    fi
}
```

### 4. Fonctions utilitaires réutilisables

```bash
# Fonction pour afficher un tableau associatif
print_assoc_array() {
    local -n arr=$1
    local title="${2:-Tableau Associatif}"
    
    echo "=== $title ==="
    for key in "${!arr[@]}"; do
        printf "  %-20s : %s\n" "$key" "${arr[$key]}"
    done
    echo ""
}

# Fonction pour vérifier les clés requises
check_required_keys() {
    local -n arr=$1
    shift
    local required_keys=("$@")
    
    for key in "${required_keys[@]}"; do
        if [[ ! -v arr[$key] ]]; then
            echo "ERREUR: Clé requise '$key' manquante" >&2
            return 1
        fi
    done
    return 0
}

# Utilisation
declare -A config=(
    [host]="localhost"
    [port]="8080"
)

print_assoc_array config "Configuration Serveur"
check_required_keys config host port database || exit 1
```

### 5. Documentation dans le code

```bash
# ✅ Documentez les structures de données complexes
declare -A user_roles=(
    # Format: [username]="role:permissions"
    [admin]="administrator:all"
    [john]="editor:read,write"
    [jane]="viewer:read"
)
```

### 6. Gestion d'erreur robuste

```bash
# ✅ Toujours gérer les cas d'erreur
get_value_safe() {
    local -n table=$1
    local key=$2
    local default=${3:-""}
    
    if [[ -v table[$key] ]]; then
        echo "${table[$key]}"
    else
        echo "$default"
    fi
}

# Utilisation
declare -A config=([timeout]="30")
timeout=$(get_value_safe config timeout "60")
port=$(get_value_safe config port "8080")
```

---

> [!tip] Astuces finales
> 
> - Utilisez `declare -p nom_tableau` pour déboguer et voir le contenu complet
> - Les tableaux associatifs sont parfaits pour les configurations
> - Préférez-les aux variables multiples pour les données structurées
> - Testez toujours l'existence des clés avant l'accès en production
> - Pensez à trier les clés lors de l'affichage pour une meilleure lisibilité