
---

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

## 🚫 L'option --exclude

### Qu'est-ce que c'est ?

L'option `--exclude` permet d'exclure des fichiers ou répertoires spécifiques de la synchronisation. C'est l'une des options les plus utilisées pour affiner vos transferts.

### Pourquoi l'utiliser ?

- Éviter de synchroniser des fichiers temporaires ou de cache
- Exclure des répertoires volumineux non nécessaires
- Ignorer des fichiers sensibles ou de configuration
- Réduire le temps de transfert et l'espace utilisé

### Syntaxe de base

```bash
rsync -av --exclude 'pattern' source/ destination/
```

> [!info] Pattern Le pattern peut être un nom de fichier, un répertoire, ou utiliser des wildcards comme `*` et `?`.

### Exemples pratiques

```bash
# Exclure un fichier spécifique
rsync -av --exclude 'config.local' /source/ /destination/

# Exclure tous les fichiers .log
rsync -av --exclude '*.log' /source/ /destination/

# Exclure un répertoire complet
rsync -av --exclude 'cache/' /source/ /destination/

# Exclure plusieurs éléments (multiple --exclude)
rsync -av --exclude '*.tmp' --exclude '*.swp' --exclude '.git/' /source/ /destination/
```

> [!warning] Slash final dans les exclusions
> 
> - `--exclude 'dossier'` : exclut tout fichier ou dossier nommé "dossier"
> - `--exclude 'dossier/'` : exclut uniquement les répertoires nommés "dossier"

### Wildcards et patterns avancés

```bash
# Exclure tous les fichiers commençant par "temp"
rsync -av --exclude 'temp*' /source/ /destination/

# Exclure tous les .txt dans n'importe quel sous-répertoire
rsync -av --exclude '**/*.txt' /source/ /destination/

# Exclure les fichiers cachés (commençant par .)
rsync -av --exclude '.*' /source/ /destination/

# Exclure plusieurs extensions
rsync -av --exclude '*.{tmp,log,cache}' /source/ /destination/
```

> [!tip] Double astérisque (**) Le pattern `**/` signifie "dans n'importe quel niveau de sous-répertoire". Par exemple, `**/.git/` exclura tous les dossiers `.git` peu importe leur profondeur.

---

## ✅ L'option --include

### Qu'est-ce que c'est ?

L'option `--include` permet de spécifier explicitement ce qui doit être inclus dans la synchronisation. Elle est souvent utilisée en combinaison avec `--exclude`.

### Pourquoi l'utiliser ?

- Créer des exceptions aux règles d'exclusion
- Synchroniser uniquement certains types de fichiers
- Construire des filtres complexes et précis

### Syntaxe de base

```bash
rsync -av --include 'pattern' --exclude '*' source/ destination/
```

> [!warning] Ordre crucial L'ordre des options `--include` et `--exclude` est extrêmement important ! rsync les évalue dans l'ordre où elles apparaissent.

### Exemples pratiques

```bash
# Inclure uniquement les fichiers .pdf
rsync -av --include '*.pdf' --exclude '*' /source/ /destination/

# Inclure les .jpg mais exclure tout le reste
rsync -av --include '*.jpg' --exclude '*' /source/ /destination/

# Inclure un dossier spécifique malgré une exclusion globale
rsync -av --include 'important/' --exclude 'temp*/' /source/ /destination/
```

### Cas d'usage complexe : synchroniser une structure de dossiers

```bash
# Synchroniser uniquement les fichiers .conf dans tous les sous-répertoires
# en préservant la structure des dossiers
rsync -av \
  --include '*/' \
  --include '*.conf' \
  --exclude '*' \
  /etc/ /backup/etc/
```

> [!example] Explication de l'exemple
> 
> 1. `--include '*/'` : inclut tous les répertoires (pour traverser l'arborescence)
> 2. `--include '*.conf'` : inclut tous les fichiers .conf
> 3. `--exclude '*'` : exclut tout le reste

---

## 📄 L'option --exclude-from

### Qu'est-ce que c'est ?

Cette option permet de charger les patterns d'exclusion depuis un fichier externe. Idéal quand vous avez de nombreuses exclusions à gérer.

### Pourquoi l'utiliser ?

- Maintenir une liste réutilisable d'exclusions
- Faciliter la gestion de filtres complexes
- Rendre vos scripts plus lisibles
- Partager des configurations entre plusieurs tâches

### Syntaxe de base

```bash
rsync -av --exclude-from='/chemin/fichier-exclusions.txt' source/ destination/
```

### Format du fichier d'exclusions

```bash
# Créer un fichier d'exclusions
cat > rsync-exclude.txt << 'EOF'
# Commentaires autorisés avec #
*.log
*.tmp
.cache/
node_modules/
.git/
*.swp
*.bak
~*
EOF

# Utiliser ce fichier
rsync -av --exclude-from='rsync-exclude.txt' /source/ /destination/
```

> [!info] Format du fichier
> 
> - Un pattern par ligne
> - Les commentaires commencent par `#`
> - Les lignes vides sont ignorées
> - Pas besoin de guillemets autour des patterns

### Exemple de fichier d'exclusions pour un projet web

```bash
# rsync-web-exclude.txt

# Fichiers temporaires
*.tmp
*.temp
*~
.*.swp

# Dossiers de développement
node_modules/
vendor/
.git/
.svn/

# Fichiers de cache
.cache/
cache/
tmp/

# Logs
*.log
logs/

# Configuration locale
.env.local
config.local.php

# Médias volumineux (optionnel)
*.mp4
*.avi
```

```bash
# Utilisation
rsync -av --exclude-from='rsync-web-exclude.txt' /var/www/site/ user@backup:/backups/site/
```

> [!tip] Bonne pratique Créez un fichier `.rsyncexclude` à la racine de vos projets pour standardiser vos exclusions.

---

## 🗑️ L'option --delete

### Qu'est-ce que c'est ?

L'option `--delete` supprime dans la destination les fichiers qui n'existent plus dans la source. Elle transforme rsync en un véritable outil de synchronisation miroir.

### Pourquoi l'utiliser ?

- Maintenir une copie exacte de la source
- Nettoyer automatiquement les anciens fichiers
- Économiser de l'espace disque sur la destination

> [!warning] Attention : option destructive ! Cette option SUPPRIME des fichiers. Utilisez-la avec précaution et testez toujours avec `--dry-run` d'abord.

### Syntaxe de base

```bash
rsync -av --delete source/ destination/
```

### Comportement détaillé

```bash
# Situation initiale
# Source:       fichier1, fichier2, fichier3
# Destination:  fichier1, fichier2, fichier3, fichier4

# Après : rsync -av --delete source/ destination/
# Destination:  fichier1, fichier2, fichier3
# (fichier4 a été supprimé car absent de la source)
```

### Variantes de --delete

|Option|Comportement|
|---|---|
|`--delete`|Supprime pendant le transfert (par défaut)|
|`--delete-before`|Supprime avant de commencer le transfert|
|`--delete-after`|Supprime après avoir terminé le transfert|
|`--delete-during`|Supprime pendant le transfert (alias de --delete)|
|`--delete-excluded`|Supprime aussi les fichiers exclus de la destination|

```bash
# Supprimer avant le transfert (plus sûr)
rsync -av --delete-before source/ destination/

# Supprimer après le transfert (économise de l'espace durant le transfert)
rsync -av --delete-after source/ destination/
```

> [!tip] Quelle variante choisir ?
> 
> - `--delete-before` : plus sûr, libère de l'espace avant le transfert
> - `--delete-after` : préserve les anciens fichiers jusqu'à la fin du transfert
> - `--delete-during` : compromis entre les deux (comportement par défaut)

### Exemple pratique avec exclusions

```bash
# Synchroniser en miroir mais en préservant certains fichiers
rsync -av \
  --delete \
  --exclude 'config.local' \
  --exclude 'uploads/' \
  /var/www/site/ /backup/site/
```

> [!warning] --delete avec --exclude Les fichiers exclus dans la destination ne seront PAS supprimés, sauf si vous utilisez `--delete-excluded`.

### Protection contre les suppressions accidentelles

```bash
# Option --max-delete : limite le nombre de suppressions
rsync -av --delete --max-delete=100 source/ destination/

# Si plus de 100 fichiers doivent être supprimés, rsync s'arrête
# Utile pour détecter des erreurs (source vide par accident, etc.)
```

---

## 🧪 L'option --dry-run

### Qu'est-ce que c'est ?

L'option `--dry-run` (ou `-n`) effectue une simulation complète sans réellement modifier les fichiers. C'est votre meilleur ami pour tester vos commandes.

### Pourquoi l'utiliser ?

- Vérifier ce qui sera transféré avant de le faire réellement
- Tester des options complexes sans risque
- Valider des filtres d'inclusion/exclusion
- **INDISPENSABLE** avant toute utilisation de `--delete`

### Syntaxe de base

```bash
rsync -av --dry-run source/ destination/

# Forme courte
rsync -avn source/ destination/
```

> [!tip] Toujours tester d'abord ! Prenez l'habitude d'ajouter `--dry-run` à toute nouvelle commande rsync, surtout avec `--delete`.

### Exemples pratiques

```bash
# Tester une synchronisation avec suppression
rsync -av --dry-run --delete /source/ /destination/

# Voir exactement ce qui sera exclu
rsync -av --dry-run --exclude '*.log' /source/ /destination/

# Combiner avec --verbose pour plus de détails
rsync -avv --dry-run source/ destination/

# Combiner avec --itemize-changes pour un format détaillé
rsync -av --dry-run --itemize-changes source/ destination/
```

### Interpréter la sortie

```bash
$ rsync -avn --delete /source/ /backup/

sending incremental file list
./
fichier_nouveau.txt
fichier_modifie.txt
deleting fichier_ancien.txt

sent 156 bytes  received 25 bytes  362.00 bytes/sec
total size is 45,678  speedup is 252.30 (DRY RUN)
```

> [!info] Lecture de la sortie
> 
> - Les fichiers listés seront copiés/modifiés
> - `deleting nom_fichier` : ce fichier sera supprimé
> - `(DRY RUN)` : confirmation qu'aucune modification réelle n'a été faite

### Workflow recommandé

```bash
# 1. Tester d'abord
rsync -avn --delete --exclude '*.log' /source/ /destination/

# 2. Vérifier la sortie attentivement

# 3. Si tout est OK, relancer sans --dry-run
rsync -av --delete --exclude '*.log' /source/ /destination/
```

> [!warning] Attention aux redirections Avec `--dry-run`, les fichiers ne sont pas modifiés, mais rsync parcourt quand même la source et la destination. Sur de gros volumes, cela peut prendre du temps.

---

## 🔄 Ordre d'évaluation et combinaisons

### Comprendre l'ordre d'évaluation

rsync évalue les règles d'inclusion/exclusion **dans l'ordre où elles apparaissent** sur la ligne de commande. La première règle qui correspond détermine le sort du fichier.

> [!warning] Règle d'or L'ordre compte ! `--include` puis `--exclude` est différent de `--exclude` puis `--include`.

### Principe de fonctionnement

```bash
# Pour chaque fichier, rsync parcourt les règles dans l'ordre :
# 1. Si une règle --include correspond → fichier inclus
# 2. Si une règle --exclude correspond → fichier exclu
# 3. Si aucune règle ne correspond → fichier inclus par défaut
```

### Exemples de combinaisons

#### Exemple 1 : Inclure seulement certains types de fichiers

```bash
# Synchroniser uniquement les images (jpg, png, gif)
rsync -av \
  --include '*.jpg' \
  --include '*.png' \
  --include '*.gif' \
  --include '*/' \
  --exclude '*' \
  /photos/ /backup/photos/
```

> [!example] Explication
> 
> 1. Inclure les .jpg, .png, .gif
> 2. Inclure les répertoires (*/nécessaire pour parcourir l'arborescence)
> 3. Exclure tout le reste

#### Exemple 2 : Exclure sauf exceptions

```bash
# Exclure tous les .txt sauf important.txt
rsync -av \
  --include 'important.txt' \
  --exclude '*.txt' \
  /source/ /destination/
```

> [!info] Ordre important `--include` avant `--exclude` : important.txt sera inclus avant que la règle d'exclusion ne s'applique.

#### Exemple 3 : Filtrage par répertoire

```bash
# Synchroniser seulement le contenu du dossier "production"
# mais exclure les logs même dans production
rsync -av \
  --include 'production/***' \
  --exclude '*' \
  --exclude '*.log' \
  /data/ /backup/data/
```

### Tableau récapitulatif des patterns

|Pattern|Signification|Exemple|
|---|---|---|
|`*`|N'importe quel caractère (sauf /)|`*.txt` = tous les .txt|
|`**`|N'importe quel chemin|`**/cache/` = cache à tout niveau|
|`***`|Tout sous un répertoire|`dir/***` = tout dans dir/ récursivement|
|`?`|Un caractère quelconque|`file?.txt` = file1.txt, fileA.txt|
|`[abc]`|Un caractère parmi a, b, c|`file[123].txt`|
|`/` en fin|Uniquement les répertoires|`temp/`|
|`/` en début|Depuis la racine source|`/etc/`|

### Combinaison complexe : cas réel

```bash
# Sauvegarder un serveur web en excluant cache, logs et uploads
# mais en gardant la structure
rsync -av \
  --exclude 'cache/' \
  --exclude 'logs/' \
  --exclude '*.log' \
  --exclude 'uploads/' \
  --exclude 'node_modules/' \
  --exclude '.git/' \
  --include '*/uploads/.gitkeep' \
  --delete \
  --dry-run \
  /var/www/site/ user@backup:/backups/site/
```

> [!tip] Construire progressivement Testez vos filtres un par un avec `--dry-run` avant de tous les combiner.

### Patterns avancés avec chemins absolus

```bash
# Exclure uniquement le cache à la racine, pas les sous-répertoires
rsync -av --exclude '/cache/' /source/ /destination/

# vs exclure tous les dossiers cache partout
rsync -av --exclude 'cache/' /source/ /destination/
```

### Debugging des filtres

```bash
# Voir exactement quels fichiers sont inclus/exclus
rsync -av --dry-run --itemize-changes \
  --exclude '*.log' \
  --include '*.conf' \
  /source/ /destination/ | less

# Utiliser -vv pour plus de verbosité sur les filtres
rsync -avv --dry-run \
  --exclude '*.tmp' \
  /source/ /destination/
```

---

## 🎯 Pièges courants et bonnes pratiques

### ⚠️ Pièges à éviter

1. **Oublier `--dry-run` avant `--delete`**
    
    ```bash
    # ❌ DANGEREUX
    rsync -av --delete source/ destination/
    
    # ✅ TOUJOURS tester d'abord
    rsync -avn --delete source/ destination/
    ```
    
2. **Ordre incorrect des includes/excludes**
    
    ```bash
    # ❌ Ceci exclut TOUT (l'exclusion vient en premier)
    rsync -av --exclude '*' --include '*.pdf' source/ dest/
    
    # ✅ L'include doit venir AVANT
    rsync -av --include '*.pdf' --exclude '*' source/ dest/
    ```
    
3. **Confusion avec les slashes**
    
    ```bash
    # ❌ Exclut les fichiers ET dossiers nommés "cache"
    rsync -av --exclude 'cache' source/ dest/
    
    # ✅ Exclut uniquement les dossiers
    rsync -av --exclude 'cache/' source/ dest/
    ```
    
4. **Oublier d'inclure les répertoires dans les filtres sélectifs**
    
    ```bash
    # ❌ Ne marchera pas (ne peut pas traverser les dossiers)
    rsync -av --include '*.pdf' --exclude '*' source/ dest/
    
    # ✅ Inclure les répertoires pour traverser l'arborescence
    rsync -av --include '*/' --include '*.pdf' --exclude '*' source/ dest/
    ```
    

### ✅ Bonnes pratiques

1. **Utilisez des fichiers d'exclusions pour les configurations complexes**
    
    - Plus lisible et maintenable
    - Réutilisable entre projets
    - Versionnable avec Git
2. **Testez toujours avec --dry-run**
    
    - Obligatoire avant toute commande avec --delete
    - Validez vos patterns de filtrage
    - Vérifiez le volume de données à transférer
3. **Documentez vos exclusions**
    
    ```bash
    # Dans votre fichier d'exclusions
    # Exclusions pour backup quotidien projet XYZ
    # Créé le: 2025-01-25
    # Maintenu par: Équipe Ops
    
    *.log        # Logs applicatifs (régénérés)
    cache/       # Cache temporaire
    node_modules/ # Dépendances (installables)
    ```
    
4. **Utilisez --max-delete comme filet de sécurité**
    
    ```bash
    rsync -av --delete --max-delete=1000 source/ dest/
    ```
    

### 💡 Astuces

1. **Créer un alias pour vos commandes fréquentes**
    
    ```bash
    # Dans ~/.bashrc
    alias rsync-backup='rsync -av --delete --exclude-from=/etc/rsync-exclude.txt'
    
    # Utilisation
    rsync-backup /data/ /backup/data/
    ```
    
2. **Combiner avec find pour des filtres ultra-précis**
    
    ```bash
    # Synchroniser uniquement les fichiers modifiés dans les 7 derniers jours
    find /source -type f -mtime -7 > /tmp/recent-files.txt
    rsync -av --files-from=/tmp/recent-files.txt /source/ /destination/
    ```
    
3. **Utiliser des variables pour des scripts plus flexibles**
    
    ```bash
    #!/bin/bash
    SOURCE="/var/www/site"
    DEST="backup@server:/backups/site"
    EXCLUDE_FILE="/etc/rsync/web-exclude.txt"
    
    rsync -av \
      --delete \
      --dry-run \
      --exclude-from="$EXCLUDE_FILE" \
      "$SOURCE/" "$DEST/"
    ```
    

---

> [!tip] Mémo rapide
> 
> - `--exclude` : exclut des fichiers/dossiers
> - `--include` : inclut explicitement (utile avec --exclude)
> - `--exclude-from` : charge les exclusions depuis un fichier
> - `--delete` : supprime ce qui n'existe pas dans la source (⚠️ destructif)
> - `--dry-run` : simule sans modifier (🛡️ toujours tester d'abord)
> - **L'ordre des règles compte !**