

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

La commande `trap` permet d'intercepter et de gérer les signaux système dans vos scripts Bash. Un signal est un message envoyé à un processus pour lui indiquer qu'un événement s'est produit (interruption utilisateur, fin de script, erreur, etc.).

> [!info] Pourquoi utiliser `trap` ?
> 
> - **Nettoyage automatique** : Supprimer les fichiers temporaires même en cas d'interruption
> - **Gestion élégante des erreurs** : Exécuter du code spécifique quand une erreur survient
> - **Robustesse** : Empêcher l'utilisateur d'interrompre des opérations critiques
> - **Journalisation** : Logger les événements importants avant la sortie du script

---

## 📝 Syntaxe de base

### Structure générale

```bash
trap 'commandes' SIGNAL
```

- **`'commandes'`** : Une ou plusieurs commandes à exécuter (entre quotes simples de préférence)
- **`SIGNAL`** : Le signal à intercepter (EXIT, INT, TERM, ERR, etc.)

### Exemples de base

```bash
# Afficher un message à la sortie du script
trap 'echo "Script terminé"' EXIT

# Exécuter plusieurs commandes
trap 'echo "Nettoyage..."; rm -f /tmp/mon_fichier.tmp' EXIT

# Appeler une fonction
trap cleanup EXIT
```

> [!tip] Quotes simples vs doubles Utilisez des **quotes simples** (`'...'`) pour éviter l'expansion des variables au moment de la définition du trap. Les variables seront évaluées lors de l'exécution du trap.
> 
> ```bash
> # ❌ Mauvais : $fichier est évalué immédiatement
> trap "rm -f $fichier" EXIT
> 
> # ✅ Bon : $fichier sera évalué à la sortie
> trap 'rm -f $fichier' EXIT
> ```

---

## 🔔 Les signaux courants

### Tableau des signaux principaux

|Signal|Numéro|Description|Cas d'usage typique|
|---|---|---|---|
|`EXIT`|-|Fin du script (normale ou erreur)|Nettoyage systématique|
|`INT`|2|Interruption (Ctrl+C)|Gestion de l'interruption utilisateur|
|`TERM`|15|Terminaison (kill par défaut)|Arrêt propre sur demande externe|
|`ERR`|-|Commande retournant un code d'erreur|Gestion centralisée des erreurs|
|`HUP`|1|Déconnexion du terminal|Sauvegarder l'état avant déconnexion|
|`QUIT`|3|Ctrl+\ (avec core dump)|Debugging avancé|

### Détail des signaux essentiels

#### EXIT

Le signal `EXIT` est déclenché quand le script se termine, quelle qu'en soit la raison (fin normale, erreur, `exit`, etc.).

```bash
#!/bin/bash

trap 'echo "Le script se termine"' EXIT

echo "Début du script"
# Le message s'affichera à la fin, peu importe comment le script se termine
```

#### INT (Interrupt)

Le signal `INT` est envoyé quand l'utilisateur appuie sur **Ctrl+C**.

```bash
#!/bin/bash

trap 'echo "Interruption détectée ! Ctrl+C pressé"' INT

echo "Tentez de presser Ctrl+C..."
sleep 10
echo "Fin normale"
```

#### TERM (Terminate)

Le signal `TERM` est envoyé par la commande `kill` (sans option) pour demander l'arrêt d'un processus.

```bash
#!/bin/bash

trap 'echo "Signal TERM reçu, arrêt propre..."; exit 0' TERM

while true; do
    echo "En cours d'exécution... (PID: $$)"
    sleep 2
done
```

#### ERR

Le signal `ERR` est déclenché quand une commande retourne un code d'erreur non nul.

```bash
#!/bin/bash
set -e  # Arrêt sur erreur (souvent utilisé avec ERR)

trap 'echo "Erreur détectée à la ligne $LINENO"' ERR

echo "Commande 1"
false  # Génère une erreur
echo "Cette ligne ne sera jamais exécutée"
```

> [!warning] Limitation de ERR Le signal `ERR` n'est pas déclenché si la commande en erreur est :
> 
> - Dans une condition (`if`, `while`, `until`)
> - Utilisée avec `||` ou `&&`
> - Dans un pipeline sauf si `set -o pipefail` est activé

---

## 🧹 Nettoyage en sortie de script

L'utilisation la plus courante de `trap` est le nettoyage automatique des ressources (fichiers temporaires, verrous, connexions, etc.).

### Exemple complet

```bash
#!/bin/bash

# Créer un fichier temporaire
TEMP_FILE=$(mktemp)
LOCK_FILE="/tmp/mon_script.lock"

# Fonction de nettoyage
cleanup() {
    echo "🧹 Nettoyage en cours..."
    rm -f "$TEMP_FILE"
    rm -f "$LOCK_FILE"
    echo "✅ Nettoyage terminé"
}

# Configurer le trap pour EXIT
trap cleanup EXIT

# Créer un verrou
touch "$LOCK_FILE"

# Simuler du travail
echo "Travail en cours..." > "$TEMP_FILE"
cat "$TEMP_FILE"

# Le nettoyage s'exécutera automatiquement à la fin
```

### Nettoyage avec gestion d'erreur

```bash
#!/bin/bash

TEMP_DIR=$(mktemp -d)

cleanup() {
    local exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        echo "✅ Script terminé avec succès"
    else
        echo "❌ Script terminé avec erreur (code: $exit_code)"
    fi
    
    echo "🧹 Suppression de $TEMP_DIR"
    rm -rf "$TEMP_DIR"
    
    exit $exit_code
}

trap cleanup EXIT

# Votre code ici
cd "$TEMP_DIR"
# ... opérations diverses ...
```

> [!tip] Capturer le code de sortie Dans une fonction appelée par `trap EXIT`, utilisez `$?` immédiatement pour capturer le code de sortie réel du script.

---

## ⛔ Gestion d'interruption Ctrl+C

### Bloquer l'interruption

Pour empêcher l'utilisateur d'interrompre une opération critique :

```bash
#!/bin/bash

# Désactiver Ctrl+C pendant l'opération critique
trap '' INT

echo "⚠️  Opération critique en cours (Ctrl+C désactivé)..."
sleep 5
echo "Opération terminée"

# Réactiver Ctrl+C
trap - INT

echo "✅ Vous pouvez maintenant interrompre avec Ctrl+C"
sleep 10
```

### Confirmation avant interruption

```bash
#!/bin/bash

interrupt_handler() {
    echo ""
    read -p "⚠️  Voulez-vous vraiment arrêter le script ? (o/N) " -n 1 -r
    echo ""
    
    if [[ $REPLY =~ ^[Oo]$ ]]; then
        echo "Interruption confirmée"
        exit 1
    else
        echo "Reprise du script..."
    fi
}

trap interrupt_handler INT

echo "Script en cours d'exécution..."
while true; do
    echo "Travail... (Ctrl+C pour interrompre)"
    sleep 2
done
```

### Interruption avec nettoyage

```bash
#!/bin/bash

TEMP_FILE="/tmp/data.tmp"

cleanup_on_interrupt() {
    echo ""
    echo "🛑 Interruption détectée"
    echo "🧹 Nettoyage avant sortie..."
    rm -f "$TEMP_FILE"
    exit 130  # Code standard pour interruption par Ctrl+C
}

trap cleanup_on_interrupt INT

# Simulation de travail
for i in {1..20}; do
    echo "Traitement $i/20..."
    echo "Données $i" >> "$TEMP_FILE"
    sleep 1
done

echo "✅ Traitement terminé"
rm -f "$TEMP_FILE"
```

> [!info] Code de sortie 130 Par convention, un script interrompu par Ctrl+C (signal INT) devrait retourner le code 130 (128 + numéro du signal INT qui est 2).

---

## 🗑️ Suppression de trap

### Réinitialiser un trap

```bash
# Définir un trap
trap 'echo "Sortie détectée"' EXIT

# Supprimer le trap (revenir au comportement par défaut)
trap - EXIT

# Désactiver un signal (ignorer complètement)
trap '' INT  # Ignore Ctrl+C
```

### Syntaxes disponibles

|Syntaxe|Effet|
|---|---|
|`trap - SIGNAL`|Supprime le trap, revient au comportement par défaut|
|`trap '' SIGNAL`|Ignore le signal (le bloque)|
|`trap 'commandes' SIGNAL`|Définit ou remplace le trap|

### Exemple pratique

```bash
#!/bin/bash

echo "Phase 1 : Ctrl+C bloqué"
trap '' INT
sleep 3

echo "Phase 2 : Trap avec message"
trap 'echo "Interruption demandée"' INT
sleep 3

echo "Phase 3 : Comportement par défaut"
trap - INT
sleep 3

echo "Script terminé"
```

---

## 🔧 Fonctions dans trap

### Appeler une fonction depuis trap

Il est recommandé d'utiliser des fonctions pour des traps complexes :

```bash
#!/bin/bash

# Définir la fonction AVANT le trap
ma_fonction_exit() {
    echo "=== Fonction de sortie ==="
    echo "Code de sortie : $?"
    echo "Dernière commande : $BASH_COMMAND"
    # ... nettoyage ...
}

# Configurer le trap pour appeler la fonction
trap ma_fonction_exit EXIT

# Votre code
echo "Script en cours..."
```

### Fonction avec paramètres

```bash
#!/bin/bash

cleanup_with_message() {
    local message=$1
    local exit_code=$2
    
    echo "📋 $message"
    echo "🔢 Code de sortie : $exit_code"
    
    # Nettoyage
    rm -rf /tmp/my_temp_*
}

# Passer des paramètres à la fonction
trap 'cleanup_with_message "Fin du script" $?' EXIT

# Code du script...
```

### Variables utiles dans les fonctions trap

```bash
#!/bin/bash

error_handler() {
    echo "❌ Erreur détectée !"
    echo "📍 Ligne : $LINENO"
    echo "🔧 Commande : $BASH_COMMAND"
    echo "📂 Script : $0"
    echo "🔢 Code erreur : $?"
}

trap error_handler ERR
set -e

# Génère une erreur
false
```

> [!warning] Portée des variables Les variables locales définies dans la fonction trap ne sont pas accessibles en dehors de celle-ci. Utilisez des variables globales si nécessaire.

### Traps multiples avec fonctions

```bash
#!/bin/bash

cleanup() {
    echo "🧹 Nettoyage général"
    rm -f /tmp/*.tmp
}

handle_interrupt() {
    echo "⛔ Interruption utilisateur"
    cleanup
    exit 130
}

handle_error() {
    echo "❌ Erreur à la ligne $LINENO : $BASH_COMMAND"
    cleanup
    exit 1
}

# Configurer plusieurs traps
trap cleanup EXIT
trap handle_interrupt INT TERM
trap handle_error ERR

set -e

# Votre code ici...
```

---

## ⚠️ Pièges courants

### 1. Ordre de définition

```bash
# ❌ MAUVAIS : la fonction n'existe pas encore
trap ma_fonction EXIT
ma_fonction() {
    echo "Nettoyage"
}

# ✅ BON : définir la fonction AVANT le trap
ma_fonction() {
    echo "Nettoyage"
}
trap ma_fonction EXIT
```

### 2. Variables non expandues

```bash
# ❌ MAUVAIS : $fichier est évalué immédiatement (vide ici)
fichier=""
trap "rm -f $fichier" EXIT
fichier="/tmp/data.tmp"

# ✅ BON : évaluation différée avec quotes simples
fichier=""
trap 'rm -f $fichier' EXIT
fichier="/tmp/data.tmp"
```

### 3. ERR et conditions

```bash
#!/bin/bash
set -e
trap 'echo "Erreur !"' ERR

# ❌ Le trap ERR ne se déclenche PAS dans ces cas :
if false; then
    echo "Jamais exécuté"
fi

false || echo "Le trap ne s'est pas déclenché"

# ✅ Le trap ERR se déclenche ici :
false  # Commande seule qui échoue
```

### 4. Traps imbriqués dans les sous-shells

```bash
#!/bin/bash

trap 'echo "Trap parent"' EXIT

# Le trap parent ne s'applique PAS au sous-shell
(
    trap 'echo "Trap sous-shell"' EXIT
    echo "Dans le sous-shell"
)  # Affiche "Trap sous-shell"

echo "Fin du script"  # Affichera "Trap parent"
```

### 5. Oublier de restaurer le code de sortie

```bash
# ❌ MAUVAIS : modifie le code de sortie
trap 'rm -f /tmp/fichier.tmp' EXIT

# ✅ BON : préserver le code de sortie
trap 'exit_code=$?; rm -f /tmp/fichier.tmp; exit $exit_code' EXIT
```

---

## ✨ Bonnes pratiques

### 1. Toujours nettoyer les ressources

```bash
#!/bin/bash

# Créer les ressources
TEMP_FILE=$(mktemp)
LOCK_FILE="/var/lock/mon_script.lock"

# Configurer le nettoyage IMMÉDIATEMENT
trap 'rm -f "$TEMP_FILE" "$LOCK_FILE"' EXIT

# Puis utiliser les ressources
touch "$LOCK_FILE"
# ... travail ...
```

### 2. Utiliser des fonctions pour la clarté

```bash
#!/bin/bash

# ✅ BON : fonction nommée et claire
cleanup() {
    echo "Nettoyage des ressources..."
    rm -rf "$TEMP_DIR"
    pkill -P $$  # Tuer les processus enfants
}

trap cleanup EXIT
```

### 3. Gérer plusieurs signaux avec une seule fonction

```bash
#!/bin/bash

handle_signal() {
    local signal=$1
    echo "Signal $signal reçu"
    
    case $signal in
        INT)  echo "Interruption utilisateur" ;;
        TERM) echo "Demande de terminaison" ;;
        EXIT) echo "Fin du script" ;;
    esac
    
    # Nettoyage commun
    cleanup
}

trap 'handle_signal INT'  INT
trap 'handle_signal TERM' TERM
trap 'handle_signal EXIT' EXIT
```

### 4. Logger les événements importants

```bash
#!/bin/bash

LOG_FILE="/var/log/mon_script.log"

log_exit() {
    local exit_code=$?
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo "[$timestamp] Script terminé (code: $exit_code)" >> "$LOG_FILE"
}

trap log_exit EXIT
```

### 5. Tester la présence de commandes critiques

```bash
#!/bin/bash

cleanup() {
    # Vérifier que les commandes existent avant de les utiliser
    command -v rm >/dev/null 2>&1 && rm -f "$TEMP_FILE"
    command -v pkill >/dev/null 2>&1 && pkill -P $$
}

trap cleanup EXIT
```

### 6. Documentation et maintenabilité

```bash
#!/bin/bash

# =============================================================================
# Gestion des signaux et nettoyage
# =============================================================================

# Fonction de nettoyage appelée à la sortie du script
# Supprime les fichiers temporaires et libère les ressources
cleanup() {
    local exit_code=$?
    
    echo "Nettoyage en cours..."
    
    # Supprimer les fichiers temporaires
    [ -n "$TEMP_DIR" ] && rm -rf "$TEMP_DIR"
    
    # Libérer le verrou
    [ -f "$LOCK_FILE" ] && rm -f "$LOCK_FILE"
    
    return $exit_code
}

# Configurer les traps
trap cleanup EXIT           # Nettoyage automatique à la sortie
trap 'exit 130' INT        # Sortie propre sur Ctrl+C
trap 'exit 143' TERM       # Sortie propre sur kill

# =============================================================================
```

### 7. Combinaison avec set -e et set -E

```bash
#!/bin/bash

# Arrêt sur erreur
set -e

# Propager ERR aux fonctions et sous-shells
set -E

error_handler() {
    local line=$1
    echo "❌ Erreur ligne $line"
    # Nettoyage...
}

trap 'error_handler $LINENO' ERR

# Votre code...
```

> [!tip] Astuce : Template de script robuste
> 
> ```bash
> #!/bin/bash
> set -euo pipefail  # Mode strict
> 
> TEMP_DIR=$(mktemp -d)
> 
> cleanup() {
>     rm -rf "$TEMP_DIR"
> }
> 
> trap cleanup EXIT
> trap 'exit 130' INT
> trap 'echo "Erreur ligne $LINENO"; exit 1' ERR
> 
> # Votre code ici...
> ```

---

## 🎓 Résumé

La commande `trap` est essentielle pour écrire des scripts Bash robustes et professionnels :

- **EXIT** : Pour le nettoyage systématique des ressources
- **INT/TERM** : Pour gérer les interruptions proprement
- **ERR** : Pour centraliser la gestion des erreurs
- Utilisez des **fonctions** pour organiser le code des traps
- Définissez les traps **tôt** dans le script
- Utilisez des **quotes simples** pour l'expansion différée
- Préservez le **code de sortie** original

Un bon usage de `trap` transforme un script fragile en un outil fiable et maintenable.