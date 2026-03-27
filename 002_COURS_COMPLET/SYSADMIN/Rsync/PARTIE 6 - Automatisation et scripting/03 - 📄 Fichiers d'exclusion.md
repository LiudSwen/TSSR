

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

## Introduction

Les fichiers d'exclusion permettent de centraliser et d'organiser les règles d'exclusion pour vos synchronisations rsync. Plutôt que d'encombrer vos commandes avec de multiples options `--exclude`, vous pouvez créer des fichiers réutilisables qui définissent clairement ce qui doit être ignoré.

> [!info] Pourquoi utiliser des fichiers d'exclusion ?
> 
> - **Réutilisabilité** : Un même fichier peut être utilisé dans plusieurs scripts
> - **Maintenabilité** : Modifier les règles sans toucher aux scripts
> - **Lisibilité** : Meilleure organisation que des lignes de commande surchargées
> - **Documentation** : Les fichiers peuvent contenir des commentaires explicatifs

---

## Création de fichiers d'exclusion

### 🎯 Principe de base

Un fichier d'exclusion est un simple fichier texte contenant une règle par ligne. Chaque ligne représente un pattern que rsync utilisera pour filtrer les fichiers et répertoires.

### 📝 Syntaxe d'utilisation

```bash
# Utiliser un fichier d'exclusion
rsync -av --exclude-from='/chemin/vers/exclusions.txt' source/ destination/

# Syntaxe alternative (même résultat)
rsync -av --exclude-from=exclusions.txt source/ destination/
```

> [!tip] Astuce Le chemin du fichier d'exclusion peut être relatif ou absolu. Si relatif, il est interprété depuis le répertoire où vous lancez rsync.

### 🔧 Exemple de fichier d'exclusion simple

Créez un fichier `.rsync-exclude` :

```bash
# Fichiers temporaires
*.tmp
*.temp
~*

# Répertoires système
.cache/
.Trash/

# Logs
*.log
logs/

# Fichiers de sauvegarde
*.bak
*.backup
```

**Utilisation :**

```bash
rsync -av --exclude-from='.rsync-exclude' /home/user/ /backup/user/
```

> [!warning] Attention aux commentaires
> 
> - Les lignes commençant par `#` sont des commentaires et sont ignorées
> - Les lignes vides sont également ignorées
> - Tout le reste est interprété comme un pattern d'exclusion

---

## Patterns et wildcards

### 🎨 Wildcards de base

|Wildcard|Signification|Exemple|Correspondances|
|---|---|---|---|
|`*`|N'importe quelle séquence de caractères (sauf `/`)|`*.log`|`error.log`, `app.log`|
|`**`|N'importe quelle séquence incluant `/`|`**/temp`|`temp`, `dir/temp`, `a/b/temp`|
|`?`|Un seul caractère|`file?.txt`|`file1.txt`, `fileA.txt`|
|`[abc]`|Un caractère parmi ceux listés|`file[123].txt`|`file1.txt`, `file2.txt`|
|`[a-z]`|Un caractère dans la plage|`log[0-9].txt`|`log0.txt`, `log5.txt`|

### 📖 Exemples de patterns courants

```bash
# Extensions spécifiques
*.mp3                    # Tous les fichiers MP3
*.{jpg,png,gif}         # Images (nécessite shell expansion)

# Répertoires
cache/                   # Répertoire "cache" à la racine
**/cache/               # Répertoire "cache" n'importe où

# Fichiers cachés
.*                      # Tous les fichiers cachés (commence par .)
.*/                     # Tous les répertoires cachés

# Patterns avancés
temp_*_backup.sql       # temp_users_backup.sql, temp_data_backup.sql
file[0-9][0-9].txt     # file00.txt jusqu'à file99.txt
```

> [!example] Exemple pratique : Exclure les fichiers de compilation
> 
> ```bash
> # fichier: exclude-dev.txt
> *.o
> *.pyc
> __pycache__/
> node_modules/
> .git/
> .vscode/
> *.swp
> ```

### 🔍 Patterns absolus vs relatifs

```bash
# Pattern relatif (commence sans /)
cache/                  # Correspond à "cache/" à n'importe quel niveau

# Pattern absolu (commence avec /)
/cache/                 # Correspond uniquement à "cache/" à la racine de la source

# Pattern avec joker global
**/node_modules/        # "node_modules" à n'importe quel niveau
```

**Démonstration :**

```bash
# Structure :
# project/
# ├── cache/           ← exclu par "cache/" et "/cache/"
# ├── src/
# │   └── cache/       ← exclu par "cache/" mais PAS par "/cache/"
# └── tmp/

# Avec pattern relatif
echo "cache/" > exclusions.txt
rsync -av --exclude-from=exclusions.txt project/ backup/
# Résultat : Les DEUX répertoires "cache" sont exclus

# Avec pattern absolu
echo "/cache/" > exclusions.txt
rsync -av --exclude-from=exclusions.txt project/ backup/
# Résultat : Seul "project/cache/" est exclu, "project/src/cache/" est copié
```

> [!warning] Slash final pour les répertoires Ajouter un `/` à la fin d'un pattern indique explicitement un répertoire. Cela évite les ambiguïtés si un fichier et un répertoire portent le même nom.

---

## Organisation des exclusions

### 🗂️ Structure recommandée

Organisez vos fichiers d'exclusion par contexte ou par type de données :

```bash
# Organisation suggérée
~/.rsync/
├── exclude-global.txt          # Règles communes à toutes les sauvegardes
├── exclude-home.txt            # Spécifique aux sauvegardes /home
├── exclude-web.txt             # Spécifique aux sites web
├── exclude-development.txt     # Environnements de développement
└── exclude-media.txt           # Fichiers multimédia volumineux
```

### 📋 Exemple : Fichier d'exclusion global

```bash
# ~/.rsync/exclude-global.txt
# Fichier d'exclusion global pour toutes les sauvegardes rsync

# === Fichiers système ===
.Trash/
.cache/
.local/share/Trash/
lost+found/

# === Fichiers temporaires ===
*.tmp
*.temp
*~
.~*

# === Fichiers de verrouillage ===
*.lock
*.lck
.*.swp
.*.swo

# === Logs ===
*.log
*.log.*
/var/log/

# === Caches d'applications ===
thumbs.db
Thumbs.db
.DS_Store
desktop.ini
```

### 📋 Exemple : Fichier d'exclusion pour développement

```bash
# ~/.rsync/exclude-development.txt
# Exclusions pour environnements de développement

# === Contrôle de version ===
.git/
.svn/
.hg/

# === Dépendances ===
node_modules/
vendor/
venv/
__pycache__/
.pytest_cache/

# === Build artifacts ===
dist/
build/
*.egg-info/
target/
out/

# === IDE ===
.vscode/
.idea/
*.sublime-project
*.sublime-workspace

# === Compilation ===
*.o
*.a
*.so
*.pyc
*.class
```

### 🔗 Combiner plusieurs fichiers d'exclusion

Vous pouvez utiliser plusieurs options `--exclude-from` dans une même commande :

```bash
rsync -av \
  --exclude-from="$HOME/.rsync/exclude-global.txt" \
  --exclude-from="$HOME/.rsync/exclude-development.txt" \
  /home/user/projects/ \
  /backup/projects/
```

> [!tip] Astuce : Variables d'environnement Définissez un répertoire standard pour vos fichiers d'exclusion :
> 
> ```bash
> # Dans votre .bashrc ou .zshrc
> export RSYNC_EXCLUDE_DIR="$HOME/.rsync"
> 
> # Utilisation
> rsync -av \
>   --exclude-from="$RSYNC_EXCLUDE_DIR/exclude-global.txt" \
>   source/ destination/
> ```

### 🎯 Organisation par projet

Pour des projets spécifiques, placez le fichier d'exclusion à la racine du projet :

```bash
# Structure projet
myproject/
├── .rsync-exclude      # Fichier d'exclusion du projet
├── src/
├── data/
└── docs/

# Contenu de .rsync-exclude
data/raw/              # Données brutes volumineuses
*.csv                  # Fichiers CSV temporaires
/temp/                 # Répertoire temp à la racine
docs/drafts/           # Brouillons de documentation
```

**Script de sauvegarde du projet :**

```bash
#!/bin/bash
# backup-project.sh

PROJECT_DIR="/home/user/myproject"
BACKUP_DIR="/backup/myproject"
EXCLUDE_FILE="$PROJECT_DIR/.rsync-exclude"

rsync -av \
  --exclude-from="$EXCLUDE_FILE" \
  "$PROJECT_DIR/" \
  "$BACKUP_DIR/"
```

---

## Pièges courants

### ⚠️ Piège n°1 : Ordre des règles

Les règles sont évaluées dans l'ordre. La première règle qui correspond est appliquée.

```bash
# ❌ INCORRECT - L'ordre pose problème
*.log                   # Exclut TOUS les .log
!/important.log         # Essaie de réinclure (ne fonctionne pas comme attendu)

# ✅ CORRECT - Les inclusions avant les exclusions
!/important.log         # D'abord inclure l'exception
*.log                   # Puis exclure le reste
```

> [!warning] Attention Pour réinclure des fichiers avec `!`, vous devez utiliser l'option `--include` en ligne de commande ou structurer soigneusement vos règles. La syntaxe `!` dans les fichiers d'exclusion a un comportement spécifique.

### ⚠️ Piège n°2 : Espaces dans les noms

```bash
# ❌ INCORRECT
My Documents/           # Ne fonctionnera pas

# ✅ CORRECT - Plusieurs solutions
My\ Documents/          # Échapper l'espace
"My Documents/"         # Utiliser des guillemets (dans certains contextes)
My?Documents/           # Utiliser un wildcard (moins précis)
```

> [!tip] Recommandation Dans les fichiers d'exclusion, préférez échapper les espaces avec `\` plutôt que d'utiliser des guillemets.

### ⚠️ Piège n°3 : Patterns trop génériques

```bash
# ❌ DANGEREUX - Trop large
*                       # Exclut TOUT !
*/                      # Exclut tous les répertoires

# ✅ MIEUX - Plus spécifique
*.tmp                   # Seulement les fichiers .tmp
temp_*/                 # Seulement les répertoires commençant par "temp_"
```

### ⚠️ Piège n°4 : Encodage du fichier

Assurez-vous que votre fichier d'exclusion est en **UTF-8 sans BOM** pour éviter les problèmes avec les caractères spéciaux.

```bash
# Vérifier l'encodage
file -i .rsync-exclude

# Convertir si nécessaire
iconv -f ISO-8859-1 -t UTF-8 .rsync-exclude -o .rsync-exclude.utf8
mv .rsync-exclude.utf8 .rsync-exclude
```

### ⚠️ Piège n°5 : Fins de ligne

Les fichiers créés sous Windows peuvent avoir des fins de ligne CRLF (`\r\n`) qui posent problème sous Linux.

```bash
# Convertir CRLF en LF
dos2unix .rsync-exclude

# Ou avec sed
sed -i 's/\r$//' .rsync-exclude
```

### 🔍 Tester vos exclusions

Avant de lancer une synchronisation réelle, testez avec `--dry-run` :

```bash
rsync -avn \
  --exclude-from='.rsync-exclude' \
  source/ destination/
```

> [!tip] Astuce de débogage Utilisez `-vv` (très verbeux) pour voir exactement quelles règles d'exclusion sont appliquées :
> 
> ```bash
> rsync -avv --dry-run \
>   --exclude-from='.rsync-exclude' \
>   source/ destination/ | grep excluding
> ```

---

## 💡 Bonnes pratiques récapitulatives

1. **Commentez vos fichiers** : Expliquez pourquoi chaque règle existe
2. **Organisez par catégories** : Regroupez les règles par type (système, temporaire, etc.)
3. **Utilisez des noms explicites** : `exclude-web.txt` plutôt que `ex1.txt`
4. **Testez toujours** : Utilisez `--dry-run` avant une synchronisation importante
5. **Versionnez vos fichiers** : Gardez vos fichiers d'exclusion dans Git
6. **Soyez spécifique** : Préférez `*.tmp` à `*tmp*`
7. **Documentez les cas particuliers** : Si une règle semble étrange, expliquez-la

---

> [!example] Template de fichier d'exclusion complet
> 
> ```bash
> # .rsync-exclude - Template générique
> # Auteur: [Votre nom]
> # Date: [Date]
> # Description: Fichier d'exclusion pour [contexte]
> 
> # ============================================
> # SYSTÈME
> # ============================================
> .cache/
> .Trash/
> lost+found/
> 
> # ============================================
> # TEMPORAIRES
> # ============================================
> *.tmp
> *.temp
> *~
> 
> # ============================================
> # LOGS
> # ============================================
> *.log
> *.log.*
> 
> # ============================================
> # SPÉCIFIQUE AU PROJET
> # ============================================
> # [Ajoutez vos règles personnalisées ici]
> ```

---