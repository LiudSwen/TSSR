

## Table des matières

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

## 🎯 Introduction aux fonctions

Les fonctions en Bash permettent de regrouper des commandes réutilisables sous un nom. Elles améliorent la lisibilité, la maintenabilité et évitent la répétition de code.

> [!info] Pourquoi utiliser des fonctions ?
> 
> - **Réutilisabilité** : Éviter de répéter le même code
> - **Organisation** : Structurer des scripts complexes
> - **Maintenance** : Modifier le code à un seul endroit
> - **Lisibilité** : Donner du sens avec des noms explicites

---

## 📝 Syntaxe `function nom { }`

### Description

La syntaxe avec le mot-clé `function` est une extension Bash (et Korn shell). Elle est explicite et claire.

### Structure

```bash
function nom_fonction {
    # Corps de la fonction
    commande1
    commande2
    return 0
}
```

### Exemple complet

```bash
function afficher_bienvenue {
    echo "==================================="
    echo "  Bienvenue dans le script Bash"
    echo "==================================="
    return 0
}

# Appel de la fonction
afficher_bienvenue
```

> [!example] Exemple avec logique métier
> 
> ```bash
> function verifier_fichier {
>     local fichier="$1"
>     
>     if [[ -f "$fichier" ]]; then
>         echo "✓ Le fichier existe : $fichier"
>         return 0
>     else
>         echo "✗ Fichier introuvable : $fichier"
>         return 1
>     fi
> }
> 
> # Utilisation
> verifier_fichier "/etc/passwd"
> ```

### Caractéristiques

- **Lisibilité** : Le mot `function` rend l'intention explicite
- **Compatibilité** : Fonctionne avec Bash et Korn shell
- **Flexibilité** : Peut omettre les parenthèses

---

## 📝 Syntaxe `nom() { }`

### Description

La syntaxe avec parenthèses est conforme au standard POSIX. Elle est compatible avec tous les shells modernes (sh, bash, zsh, dash, etc.).

### Structure

```bash
nom_fonction() {
    # Corps de la fonction
    commande1
    commande2
    return 0
}
```

### Exemple complet

```bash
afficher_bienvenue() {
    echo "==================================="
    echo "  Bienvenue dans le script Bash"
    echo "==================================="
    return 0
}

# Appel de la fonction
afficher_bienvenue
```

> [!example] Exemple avec paramètres
> 
> ```bash
> calculer_somme() {
>     local a="$1"
>     local b="$2"
>     local resultat=$((a + b))
>     
>     echo "$resultat"
>     return 0
> }
> 
> # Utilisation
> somme=$(calculer_somme 15 27)
> echo "15 + 27 = $somme"
> ```

### Caractéristiques

- **Portabilité** : Compatible POSIX, fonctionne partout
- **Standard** : Syntaxe la plus répandue
- **Obligatoire** : Les parenthèses `()` sont requises (même vides)

---

## ⚖️ Différences entre les syntaxes

### Tableau comparatif

|Critère|`function nom { }`|`nom() { }`|
|---|---|---|
|**Standard**|Extension Bash/Korn|POSIX standard|
|**Compatibilité**|Bash, Korn shell, Zsh|Tous les shells|
|**Parenthèses**|Optionnelles|Obligatoires|
|**Lisibilité**|Plus explicite|Plus concise|
|**Usage recommandé**|Scripts Bash exclusifs|Scripts portables|

### Équivalence fonctionnelle

Les deux syntaxes sont **strictement équivalentes** en termes de fonctionnalité :

```bash
# Ces deux déclarations sont identiques
function ma_fonction {
    echo "Hello"
}

ma_fonction() {
    echo "Hello"
}
```

> [!warning] Attention aux mélanges Ne mélangez pas les deux syntaxes dans le même script. Choisissez-en une et tenez-vous-y pour la cohérence.

### Cas particuliers

#### Syntaxe avec `function` et parenthèses

```bash
# Valide en Bash mais redondant
function ma_fonction() {
    echo "Cette syntaxe fonctionne mais est déconseillée"
}
```

> [!tip] Recommandation Évitez cette syntaxe hybride. Préférez soit `function nom { }` soit `nom() { }`.

### Quand utiliser quelle syntaxe ?

|Situation|Syntaxe recommandée|Raison|
|---|---|---|
|Script Bash pur|`function nom { }`|Plus explicite, idiomatique Bash|
|Script portable (sh/dash)|`nom() { }`|Compatibilité POSIX|
|Environnement mixte|`nom() { }`|Sécurité de la portabilité|
|Débutants|`function nom { }`|Plus claire pour l'apprentissage|

---

## 🏷️ Bonnes pratiques de nommage

### Conventions générales

> [!info] Règles de base
> 
> - Utilisez des noms **descriptifs** et **explicites**
> - Privilégiez le **snake_case** (mots séparés par des underscores)
> - Commencez par un **verbe d'action** quand c'est approprié
> - Évitez les noms d'une seule lettre (sauf pour les compteurs)

### Exemples de bons noms

```bash
# ✓ Noms clairs et descriptifs
function verifier_prerequis { }
function initialiser_base_donnees { }
function calculer_statistiques { }
function afficher_menu_principal { }
function sauvegarder_configuration { }

# ✓ Avec préfixes pour organiser
function db_connecter { }
function db_deconnecter { }
function ui_afficher_erreur { }
function util_logger_message { }
```

### Exemples de mauvais noms

```bash
# ✗ Trop vague ou cryptique
function f1 { }
function process { }
function do_stuff { }
function x { }
function temp { }

# ✗ Trop long
function verifier_si_le_fichier_de_configuration_existe_et_est_lisible { }
```

### Conventions de nommage selon le contexte

|Type de fonction|Convention|Exemple|
|---|---|---|
|**Action principale**|verbe_objet|`creer_utilisateur`, `supprimer_fichier`|
|**Vérification**|verifier_* ou est_*|`verifier_droits`, `est_root`|
|**Affichage**|afficher_* ou show_*|`afficher_aide`, `show_menu`|
|**Initialisation**|init_* ou initialiser_*|`init_config`, `initialiser_variables`|
|**Utilitaires**|util_* ou helper_*|`util_timestamp`, `helper_formater`|

### Règles techniques

> [!warning] Contraintes de nommage
> 
> - Ne commencez **jamais** par un chiffre : `1_fonction` ❌
> - Utilisez uniquement : lettres, chiffres, underscore `_`
> - Évitez les caractères spéciaux : `-`, `.`, `@`, etc.
> - Pas d'espaces dans les noms

```bash
# ✓ Valide
function ma_fonction { }
function fonction_2 { }
function __fonction_privee { }

# ✗ Invalide
function 2_fonction { }      # Commence par un chiffre
function ma-fonction { }     # Contient un tiret
function ma.fonction { }     # Contient un point
```

### Convention pour les fonctions "privées"

En Bash, il n'y a pas de visibilité privée/publique, mais une convention existe :

```bash
# Fonction "publique" - destinée à être appelée de l'extérieur
function traiter_donnees { }

# Fonction "privée" - usage interne seulement
function _valider_format { }
function __helper_internal { }
```

> [!tip] Underscore pour la visibilité
> 
> - **Un underscore** `_fonction` : fonction interne, non documentée
> - **Deux underscores** `__fonction` : fonction très interne, ne pas toucher

### Éviter les collisions de noms

```bash
# ✗ Risque de conflit avec des commandes système
function test { }      # Conflit avec /usr/bin/test
function echo { }      # Conflit avec la commande intégrée
function cd { }        # Conflit avec cd

# ✓ Préfixez vos fonctions dans les gros projets
function monapp_test { }
function monapp_init { }
function monapp_cleanup { }
```

### Cohérence dans un projet

> [!tip] Maintenez la cohérence Dans un même script ou projet, utilisez toujours la même convention :
> 
> - Soit `verbe_objet` partout
> - Soit `verbObject` (camelCase) partout
> - Soit une autre convention, mais **soyez constant**

---

## ⚠️ Pièges courants

### 1. Oublier les accolades

```bash
# ✗ Erreur de syntaxe
function ma_fonction
    echo "Ceci ne fonctionne pas"

# ✓ Correct
function ma_fonction {
    echo "Ceci fonctionne"
}
```

### 2. Appeler une fonction avant sa déclaration

```bash
# ✗ Erreur : commande introuvable
afficher_message    # Appelée avant d'être définie

function afficher_message {
    echo "Message"
}

# ✓ Correct : déclaration avant utilisation
function afficher_message {
    echo "Message"
}

afficher_message    # Maintenant ça fonctionne
```

> [!warning] Ordre d'exécution Bash lit le script de haut en bas. Déclarez toujours vos fonctions **avant** de les appeler.

### 3. Confondre fonction et commande externe

```bash
# Si vous avez une fonction "ls"
function ls {
    echo "Ma fonction ls personnalisée"
}

# Appeler la fonction
ls          # → Appelle votre fonction

# Appeler la commande système
command ls  # → Force l'appel de /bin/ls
/bin/ls     # → Chemin absolu vers la commande
```

### 4. Espace après le nom de fonction

```bash
# ✗ Erreur de syntaxe
function ma_fonction    { }

# ✓ Correct
function ma_fonction { }

# Ou avec retour à la ligne
function ma_fonction
{
    # Corps de la fonction
}
```

### 5. Oublier la portée locale des variables

```bash
# ✗ Variable globale modifiée par erreur
compteur=0

function incrementer {
    compteur=$((compteur + 1))    # Modifie la variable globale
}

# ✓ Variable locale explicite
compteur=0

function incrementer {
    local compteur=$((compteur + 1))    # Variable locale
    echo "$compteur"
}
```

> [!tip] Bonnes pratiques
> 
> - Utilisez toujours `local` pour les variables de fonction
> - Évitez de modifier des variables globales sans le vouloir
> - Documentez clairement les variables globales utilisées

### 6. Mauvaise gestion du code de retour

```bash
# ✗ Pas de valeur de retour explicite
function verifier_fichier {
    if [[ -f "$1" ]]; then
        echo "Fichier trouvé"
    fi
}    # Retourne le code de la dernière commande (echo → 0)

# ✓ Code de retour explicite et cohérent
function verifier_fichier {
    if [[ -f "$1" ]]; then
        echo "Fichier trouvé"
        return 0    # Succès
    else
        echo "Fichier introuvable" >&2
        return 1    # Échec
    fi
}
```

### 7. Surcharger accidentellement des commandes critiques

```bash
# ✗ Dangereux : surcharge rm
function rm {
    echo "rm est désactivé"
}

# Maintenant "rm fichier" ne supprime plus rien !

# ✓ Créez un alias ou un wrapper avec un autre nom
function safe_rm {
    echo "Suppression sécurisée de $@"
    command rm -i "$@"
}
```

---

## 💡 Astuces avancées

### Fonction avec valeur par défaut

```bash
function saluer {
    local nom="${1:-Utilisateur}"    # Valeur par défaut si $1 est vide
    echo "Bonjour, $nom !"
}

saluer              # → "Bonjour, Utilisateur !"
saluer "Alice"      # → "Bonjour, Alice !"
```

### Fonction avec nombre variable d'arguments

```bash
function afficher_tous {
    echo "Nombre d'arguments : $#"
    echo "Tous les arguments : $@"
    
    local i=1
    for arg in "$@"; do
        echo "  Argument $i : $arg"
        ((i++))
    done
}

afficher_tous un deux trois quatre
```

### Debug de fonctions

```bash
# Activer le mode debug pour voir l'exécution
function ma_fonction {
    set -x    # Active l'affichage des commandes
    echo "Traitement en cours"
    local resultat=$((2 + 2))
    echo "Résultat : $resultat"
    set +x    # Désactive le mode debug
}
```

### Documentation inline

```bash
function traiter_donnees {
    # traiter_donnees <fichier_entree> <fichier_sortie>
    #
    # Traite les données du fichier d'entrée et génère
    # un fichier de sortie formaté.
    #
    # Arguments:
    #   $1 - Chemin du fichier d'entrée
    #   $2 - Chemin du fichier de sortie
    #
    # Retourne:
    #   0 - Succès
    #   1 - Erreur de lecture
    #   2 - Erreur d'écriture
    
    local input="$1"
    local output="$2"
    
    # ... implémentation ...
}
```

> [!tip] Documenter vos fonctions Une bonne documentation en en-tête facilite la maintenance et la compréhension du code, surtout pour des fonctions complexes ou réutilisées.

---

## 📌 Résumé

- **Deux syntaxes valides** : `function nom { }` (Bash) et `nom() { }` (POSIX)
- **Équivalence fonctionnelle** : les deux syntaxes font exactement la même chose
- **Choisir selon le contexte** : portabilité → POSIX, clarté Bash → `function`
- **Nommage important** : noms descriptifs, snake_case, verbes d'action
- **Déclarez avant d'appeler** : Bash lit de haut en bas
- **Variables locales** : utilisez `local` pour éviter les effets de bord

---