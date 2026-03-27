

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

## Introduction

Les tests sur fichiers en Bash permettent de vérifier l'existence, le type, les permissions et l'état de fichiers ou répertoires avant d'effectuer des opérations. Ces tests sont fondamentaux pour écrire des scripts robustes qui gèrent correctement les erreurs et évitent les comportements imprévisibles.

> [!info] Syntaxe générale
> 
> ```bash
> if [ -option fichier ]; then
>     # commandes si le test est vrai
> fi
> ```
> 
> On peut aussi utiliser `[[ ]]` (recommandé) ou la commande `test`.

---

## Tests d'existence

### `-e` : Fichier existe

Teste si un fichier ou répertoire existe, quel que soit son type.

```bash
# Vérifier si un fichier existe
if [ -e "/etc/passwd" ]; then
    echo "Le fichier existe"
fi

# Forme recommandée avec [[]]
if [[ -e "$fichier" ]]; then
    echo "Le fichier existe"
fi
```

> [!warning] Attention `-e` retourne vrai pour TOUT type de fichier (fichier régulier, répertoire, lien symbolique, device, etc.). Si vous avez besoin de vérifier un type spécifique, utilisez un test plus précis.

**Quand l'utiliser :**

- Avant de tenter de lire ou modifier un fichier
- Pour vérifier qu'un chemin existe avant de le supprimer
- Comme test préliminaire général

```bash
# Exemple pratique : créer un fichier s'il n'existe pas
fichier="config.txt"
if [[ ! -e "$fichier" ]]; then
    touch "$fichier"
    echo "Fichier créé"
fi
```

---

## Tests de type

### `-f` : Fichier régulier existe

Teste si le chemin existe ET est un fichier régulier (pas un répertoire, lien symbolique, etc.).

```bash
if [[ -f "/etc/passwd" ]]; then
    echo "C'est un fichier régulier"
fi
```

> [!tip] Différence avec -e
> 
> - `-e fichier` → vrai si le chemin existe (n'importe quel type)
> - `-f fichier` → vrai si c'est spécifiquement un fichier régulier

**Cas d'usage typiques :**

```bash
# Vérifier avant de lire un fichier de configuration
config="/etc/myapp.conf"
if [[ -f "$config" ]]; then
    source "$config"
else
    echo "Erreur : fichier de configuration introuvable" >&2
    exit 1
fi
```

### `-d` : Répertoire existe

Teste si le chemin existe ET est un répertoire.

```bash
if [[ -d "/home/user" ]]; then
    echo "C'est un répertoire"
fi
```

**Utilisations courantes :**

```bash
# Créer un répertoire s'il n'existe pas
backup_dir="/var/backups/myapp"
if [[ ! -d "$backup_dir" ]]; then
    mkdir -p "$backup_dir"
    echo "Répertoire de backup créé"
fi

# Vérifier avant de lister le contenu
if [[ -d "$1" ]]; then
    ls -la "$1"
else
    echo "Erreur : $1 n'est pas un répertoire" >&2
    exit 1
fi
```

### `-L` / `-h` : Lien symbolique

Teste si le chemin est un lien symbolique.

```bash
# Les deux options sont équivalentes
if [[ -L "/usr/bin/python" ]]; then
    echo "C'est un lien symbolique"
fi

if [[ -h "/usr/bin/python" ]]; then
    echo "C'est un lien symbolique"
fi
```

> [!info] Note importante Ces tests retournent vrai même si le lien symbolique est cassé (pointe vers un fichier inexistant).

```bash
# Vérifier si un lien symbolique pointe vers un fichier valide
if [[ -L "$lien" ]] && [[ -e "$lien" ]]; then
    echo "Lien symbolique valide"
elif [[ -L "$lien" ]]; then
    echo "Lien symbolique cassé"
fi

# Résoudre un lien symbolique
if [[ -L "/usr/bin/python" ]]; then
    cible=$(readlink -f "/usr/bin/python")
    echo "Pointe vers : $cible"
fi
```

### Tests de fichiers spéciaux

#### `-b` : Fichier bloc

Teste si c'est un fichier bloc (block device), comme un disque dur.

```bash
if [[ -b "/dev/sda" ]]; then
    echo "C'est un périphérique bloc"
fi
```

#### `-c` : Fichier caractère

Teste si c'est un fichier caractère (character device), comme un terminal.

```bash
if [[ -c "/dev/tty" ]]; then
    echo "C'est un périphérique caractère"
fi
```

#### `-p` : Pipe nommé (FIFO)

Teste si c'est un pipe nommé (named pipe).

```bash
if [[ -p "/tmp/mypipe" ]]; then
    echo "C'est un pipe nommé"
fi

# Créer et utiliser un pipe nommé
mkfifo /tmp/mypipe
if [[ -p "/tmp/mypipe" ]]; then
    # Écrire dans le pipe en arrière-plan
    echo "message" > /tmp/mypipe &
    # Lire depuis le pipe
    read message < /tmp/mypipe
fi
```

#### `-S` : Socket

Teste si c'est un socket Unix.

```bash
if [[ -S "/var/run/docker.sock" ]]; then
    echo "C'est un socket"
fi
```

> [!example] Tableau récapitulatif des types
> 
> |Test|Type de fichier|Exemple typique|
> |---|---|---|
> |`-f`|Fichier régulier|`/etc/passwd`, `script.sh`|
> |`-d`|Répertoire|`/home`, `/usr/bin`|
> |`-L` / `-h`|Lien symbolique|`/usr/bin/python` → `python3.9`|
> |`-b`|Périphérique bloc|`/dev/sda`, `/dev/nvme0n1`|
> |`-c`|Périphérique caractère|`/dev/tty`, `/dev/null`|
> |`-p`|Pipe nommé (FIFO)|`/tmp/mypipe`|
> |`-S`|Socket|`/var/run/docker.sock`|

---

## Tests de permissions

### `-r` : Fichier lisible

Teste si le fichier est lisible par l'utilisateur courant.

```bash
if [[ -r "/etc/shadow" ]]; then
    echo "Vous pouvez lire ce fichier"
else
    echo "Accès en lecture refusé"
fi
```

### `-w` : Fichier modifiable

Teste si le fichier est modifiable par l'utilisateur courant.

```bash
if [[ -w "$fichier" ]]; then
    echo "Modification du fichier..." >> "$fichier"
else
    echo "Erreur : pas de permission d'écriture" >&2
    exit 1
fi
```

### `-x` : Fichier exécutable

Teste si le fichier est exécutable par l'utilisateur courant.

```bash
# Vérifier qu'un script est exécutable
script="./deploy.sh"
if [[ -x "$script" ]]; then
    "$script"
else
    echo "Erreur : $script n'est pas exécutable"
    echo "Utilisez : chmod +x $script"
    exit 1
fi
```

> [!warning] Permissions vs capacité réelle Ces tests vérifient les **permissions du système de fichiers**, pas si vous avez réellement accès au fichier. D'autres facteurs peuvent intervenir (SELinux, AppArmor, ACL, etc.).

**Exemple complet de vérification des permissions :**

```bash
fichier="data.txt"

# Vérifier toutes les permissions
if [[ -e "$fichier" ]]; then
    echo "Analyse des permissions de $fichier :"
    [[ -r "$fichier" ]] && echo "✓ Lecture : OK" || echo "✗ Lecture : KO"
    [[ -w "$fichier" ]] && echo "✓ Écriture : OK" || echo "✗ Écriture : KO"
    [[ -x "$fichier" ]] && echo "✓ Exécution : OK" || echo "✗ Exécution : KO"
else
    echo "Erreur : le fichier n'existe pas"
fi
```

---

## Tests d'état

### `-s` : Fichier non vide

Teste si le fichier existe ET a une taille supérieure à zéro.

```bash
log_file="/var/log/app.log"

if [[ -s "$log_file" ]]; then
    echo "Le fichier log contient des données"
    # Traiter les logs
else
    echo "Le fichier log est vide ou inexistant"
fi
```

> [!tip] Astuce `-s` est parfait pour vérifier si un fichier contient des données avant de le traiter.

**Cas d'usage pratiques :**

```bash
# Archiver seulement si le fichier contient des données
backup_file="backup.sql"
if [[ -s "$backup_file" ]]; then
    tar -czf "$backup_file.tar.gz" "$backup_file"
    echo "Backup archivé"
else
    echo "Attention : le backup est vide !"
fi

# Vérifier qu'une commande a produit un résultat
output="result.txt"
commande_complexe > "$output"
if [[ -s "$output" ]]; then
    echo "La commande a produit un résultat"
else
    echo "Erreur : aucun résultat produit" >&2
fi
```

### `-N` : Fichier modifié depuis dernière lecture

Teste si le fichier a été modifié depuis sa dernière lecture.

```bash
fichier="config.conf"

if [[ -N "$fichier" ]]; then
    echo "Le fichier a été modifié depuis la dernière lecture"
    # Recharger la configuration
    source "$fichier"
fi
```

> [!info] Fonctionnement Ce test compare l'**atime** (access time) et le **mtime** (modification time) du fichier. Si mtime > atime, le test est vrai.

**Exemple de surveillance de fichier :**

```bash
# Script de surveillance simple
config="/etc/myapp/config"

while true; do
    if [[ -N "$config" ]]; then
        echo "Configuration modifiée, rechargement..."
        # Recharger la config
        kill -HUP $(cat /var/run/myapp.pid)
    fi
    sleep 60
done
```

---

## Tests de comparaison

Ces tests permettent de comparer deux fichiers entre eux.

### `file1 -nt file2` : Plus récent que (newer than)

Teste si `file1` est plus récent que `file2`.

```bash
source="script.sh"
backup="script.sh.bak"

if [[ "$source" -nt "$backup" ]]; then
    echo "Le fichier source est plus récent que le backup"
    cp "$source" "$backup"
    echo "Backup mis à jour"
fi
```

### `file1 -ot file2` : Plus ancien que (older than)

Teste si `file1` est plus ancien que `file2`.

```bash
# Supprimer les fichiers temporaires plus anciens qu'un fichier de référence
reference="/tmp/.cleanup_marker"
touch -d "7 days ago" "$reference"

for fichier in /tmp/temp_*; do
    if [[ "$fichier" -ot "$reference" ]]; then
        echo "Suppression de $fichier (plus ancien que 7 jours)"
        rm "$fichier"
    fi
done
```

### `file1 -ef file2` : Même fichier (equal file)

Teste si deux chemins pointent vers le même inode (même fichier physique).

```bash
# Vérifier si deux chemins sont le même fichier
if [[ "/usr/bin/python" -ef "/usr/bin/python3" ]]; then
    echo "Ces deux chemins pointent vers le même fichier"
fi

# Détecter les liens durs
fichier1="data.txt"
fichier2="backup/data.txt"

if [[ "$fichier1" -ef "$fichier2" ]]; then
    echo "Ces fichiers sont liés en dur (même inode)"
else
    echo "Ce sont des fichiers différents"
fi
```

> [!example] Tableau comparatif des tests de comparaison
> 
> |Test|Signification|Cas d'usage|
> |---|---|---|
> |`f1 -nt f2`|f1 plus récent que f2|Vérifier si une source est plus récente qu'une copie|
> |`f1 -ot f2`|f1 plus ancien que f2|Identifier les fichiers obsolètes|
> |`f1 -ef f2`|f1 et f2 sont le même fichier|Détecter les liens durs, éviter les copies inutiles|

**Exemple pratique complet :**

```bash
#!/bin/bash
# Script de synchronisation intelligente

source="$1"
destination="$2"

if [[ ! -f "$source" ]]; then
    echo "Erreur : fichier source introuvable" >&2
    exit 1
fi

if [[ ! -e "$destination" ]]; then
    # Le fichier destination n'existe pas
    cp "$source" "$destination"
    echo "Fichier copié"
elif [[ "$source" -ef "$destination" ]]; then
    # C'est le même fichier
    echo "Source et destination sont identiques (même inode)"
elif [[ "$source" -nt "$destination" ]]; then
    # La source est plus récente
    cp "$source" "$destination"
    echo "Destination mise à jour"
else
    echo "La destination est déjà à jour"
fi
```

---

## Combinaison de tests

Les tests peuvent être combinés avec des opérateurs logiques pour créer des conditions complexes.

### Opérateurs logiques

```bash
# ET logique : && (ou -a dans [ ])
if [[ -f "$fichier" && -r "$fichier" ]]; then
    echo "Le fichier existe ET est lisible"
fi

# OU logique : || (ou -o dans [ ])
if [[ -f "$fichier" || -d "$fichier" ]]; then
    echo "Le chemin existe (fichier OU répertoire)"
fi

# NON logique : ! 
if [[ ! -e "$fichier" ]]; then
    echo "Le fichier n'existe PAS"
fi
```

> [!warning] Différence entre [ ] et [[ ]]
> 
> - Avec `[ ]` : utilisez `-a` (AND) et `-o` (OR)
> - Avec `[[ ]]` : utilisez `&&` et `||` (recommandé)
> 
> ```bash
> # Ancienne syntaxe (éviter)
> if [ -f "$f" -a -r "$f" ]; then
>     echo "ok"
> fi
> 
> # Syntaxe moderne (préférer)
> if [[ -f "$f" && -r "$f" ]]; then
>     echo "ok"
> fi
> ```

### Exemples de combinaisons courantes

```bash
# Vérifier qu'un fichier est un script exécutable
if [[ -f "$script" && -x "$script" ]]; then
    "./$script"
fi

# Créer un fichier ou répertoire selon ce qui manque
chemin="/data/config"
if [[ ! -e "$chemin" ]]; then
    if [[ "$create_as_dir" == "yes" ]]; then
        mkdir -p "$chemin"
    else
        touch "$chemin"
    fi
fi

# Vérifier qu'un fichier log est lisible ET non vide
log="/var/log/app.log"
if [[ -f "$log" && -r "$log" && -s "$log" ]]; then
    tail -f "$log"
else
    echo "Erreur : impossible de lire le fichier log" >&2
fi

# Tester plusieurs conditions avec des parenthèses
if [[ ( -f "$config" && -r "$config" ) || -f "$config_default" ]]; then
    echo "Configuration disponible"
fi
```

### Cas pratiques avancés

```bash
# Fonction de validation de fichier complet
valider_fichier() {
    local fichier="$1"
    
    # Le fichier doit exister
    [[ -e "$fichier" ]] || { echo "Erreur : n'existe pas"; return 1; }
    
    # Ce doit être un fichier régulier
    [[ -f "$fichier" ]] || { echo "Erreur : n'est pas un fichier"; return 1; }
    
    # Il doit être lisible
    [[ -r "$fichier" ]] || { echo "Erreur : non lisible"; return 1; }
    
    # Il ne doit pas être vide
    [[ -s "$fichier" ]] || { echo "Erreur : fichier vide"; return 1; }
    
    echo "Fichier valide"
    return 0
}

# Vérification de fichier avec alternatives
trouver_config() {
    local configs=(
        "$HOME/.myapp/config"
        "/etc/myapp/config"
        "/usr/local/etc/myapp/config"
    )
    
    for config in "${configs[@]}"; do
        if [[ -f "$config" && -r "$config" ]]; then
            echo "$config"
            return 0
        fi
    done
    
    echo "Erreur : aucun fichier de configuration trouvé" >&2
    return 1
}
```

---

## Bonnes pratiques

### 1. Toujours protéger les variables avec des guillemets

```bash
# ✗ MAUVAIS : peut échouer si $fichier contient des espaces
if [[ -f $fichier ]]; then
    echo "ok"
fi

# ✓ BON : guillemets protecteurs
if [[ -f "$fichier" ]]; then
    echo "ok"
fi
```

### 2. Préférer [[ ]] à [ ]

```bash
# ✓ Syntaxe moderne recommandée
if [[ -f "$fichier" && -r "$fichier" ]]; then
    cat "$fichier"
fi

# Plutôt que l'ancienne syntaxe
if [ -f "$fichier" -a -r "$fichier" ]; then
    cat "$fichier"
fi
```

> [!tip] Avantages de [[]]
> 
> - Pas besoin d'échapper les opérateurs
> - Support natif de `&&` et `||`
> - Meilleure gestion des chaînes vides
> - Globbing et regex intégrés

### 3. Vérifier l'existence avant les autres tests

```bash
# ✓ BON : test d'existence en premier
if [[ -e "$fichier" ]]; then
    if [[ -r "$fichier" ]]; then
        cat "$fichier"
    fi
fi

# Ou combiné
if [[ -e "$fichier" && -r "$fichier" ]]; then
    cat "$fichier"
fi
```

### 4. Utiliser le bon test selon le contexte

```bash
# Pour vérifier qu'un PATH existe (n'importe quel type)
if [[ -e "$chemin" ]]; then
    echo "Le chemin existe"
fi

# Pour vérifier spécifiquement un fichier
if [[ -f "$fichier" ]]; then
    cat "$fichier"
fi

# Pour vérifier spécifiquement un répertoire
if [[ -d "$dossier" ]]; then
    ls "$dossier"
fi
```

### 5. Gérer les erreurs explicitement

```bash
# ✓ BON : messages d'erreur clairs
if [[ ! -f "$config" ]]; then
    echo "Erreur : fichier de configuration '$config' introuvable" >&2
    exit 1
fi

# ✓ BON : offrir des alternatives
if [[ ! -d "$backup_dir" ]]; then
    echo "Répertoire de backup inexistant, création..." >&2
    mkdir -p "$backup_dir" || exit 1
fi
```

### 6. Éviter les tests redondants

```bash
# ✗ MAUVAIS : -f implique déjà -e
if [[ -e "$fichier" ]]; then
    if [[ -f "$fichier" ]]; then
        cat "$fichier"
    fi
fi

# ✓ BON : -f suffit
if [[ -f "$fichier" ]]; then
    cat "$fichier"
fi
```

### 7. Documenter les tests complexes

```bash
# Vérifier que le fichier est :
# - un fichier régulier (pas un lien ou répertoire)
# - plus récent que le dernier backup
# - non vide
if [[ -f "$source" && "$source" -nt "$backup" && -s "$source" ]]; then
    echo "Backup nécessaire"
    cp "$source" "$backup"
fi
```

### 8. Attention aux liens symboliques

```bash
# ✗ RISQUE : -f suit les liens symboliques
if [[ -f "$lien" ]]; then
    # Peut être vrai même si $lien est un symlink
fi

# ✓ BON : tester explicitement
if [[ -L "$lien" ]]; then
    echo "C'est un lien symbolique"
    cible=$(readlink -f "$lien")
    echo "Pointe vers : $cible"
elif [[ -f "$lien" ]]; then
    echo "C'est un fichier régulier"
fi
```

> [!warning] Pièges courants
> 
> - `-f` retourne vrai pour un lien symbolique pointant vers un fichier
> - `-e` retourne faux pour un lien symbolique cassé
> - `-L` retourne vrai même pour un lien cassé
> - Toujours tester le type avant les permissions

### 9. Pattern de validation robuste

```bash
#!/bin/bash
# Pattern complet de validation de fichier

fichier="$1"

# Vérification étape par étape avec messages clairs
if [[ -z "$fichier" ]]; then
    echo "Erreur : aucun fichier spécifié" >&2
    exit 1
fi

if [[ ! -e "$fichier" ]]; then
    echo "Erreur : '$fichier' n'existe pas" >&2
    exit 1
fi

if [[ -L "$fichier" ]]; then
    echo "Avertissement : '$fichier' est un lien symbolique" >&2
fi

if [[ ! -f "$fichier" ]]; then
    echo "Erreur : '$fichier' n'est pas un fichier régulier" >&2
    exit 1
fi

if [[ ! -r "$fichier" ]]; then
    echo "Erreur : pas de permission de lecture sur '$fichier'" >&2
    exit 1
fi

if [[ ! -s "$fichier" ]]; then
    echo "Avertissement : '$fichier' est vide" >&2
fi

# Toutes les vérifications sont OK
echo "Traitement de '$fichier'..."
```

---

> [!tip] Mémo rapide **Tests d'existence :**
> 
> - `-e` : existe (n'importe quel type)
> - `-f` : fichier régulier
> - `-d` : répertoire
> 
> **Tests de permissions :**
> 
> - `-r` : lisible
> - `-w` : modifiable
> - `-x` : exécutable
> 
> **Tests d'état :**
> 
> - `-s` : non vide
> - `-N` : modifié depuis dernière lecture
> 
> **Tests de comparaison :**
> 
> - `-nt` : plus récent
> - `-ot` : plus ancien
> - `-ef` : même fichier (inode)
> 
> **Types spéciaux :**
> 
> - `-L` / `-h` : lien symbolique
> - `-b` : périphérique bloc
> - `-c` : périphérique caractère
> - `-p` : pipe nommé
> - `-S` : socket