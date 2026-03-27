

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

## 🎯 Introduction aux sauvegardes avec tar

**tar** (Tape ARchive) est l'outil de référence sous Linux pour créer des archives de fichiers et effectuer des sauvegardes. Malgré son nom historique lié aux bandes magnétiques, tar reste aujourd'hui l'outil standard pour :

- **Regrouper plusieurs fichiers** en une seule archive
- **Préserver les métadonnées** (permissions, propriétaires, dates)
- **Sauvegarder des arborescences** complètes de répertoires
- **Compresser des données** pour économiser de l'espace
- **Transférer des données** entre systèmes

> [!info] Pourquoi tar ? Contrairement à d'autres outils d'archivage, tar préserve parfaitement les attributs Unix (permissions, liens symboliques, propriétaires) et peut traiter des fichiers de taille illimitée. C'est l'outil privilégié pour les sauvegardes système.

---

## 📦 Création d'archives tar

### Syntaxe de base

La création d'une archive tar suit cette structure :

```bash
tar -cvf nom_archive.tar fichiers_ou_repertoires
```

### Anatomie de la commande

```bash
tar -cvf backup.tar /home/user/documents/
│   │││  │          │
│   │││  │          └─ Source à archiver
│   │││  └─ Nom de l'archive de sortie
│   ││└─ f (file) : spécifie le nom du fichier archive
│   │└─ v (verbose) : affiche les fichiers traités
│   └─ c (create) : crée une nouvelle archive
└─ Commande tar
```

### Exemples pratiques

```bash
# Archiver un seul répertoire
tar -cvf documents.tar ~/Documents/

# Archiver plusieurs éléments
tar -cvf backup.tar fichier1.txt fichier2.txt dossier/

# Archiver tout le contenu d'un répertoire (depuis ce répertoire)
cd /var/www/
tar -cvf site_backup.tar html/ logs/

# Archiver avec chemin absolu
tar -cvf /backups/home_backup.tar /home/user/
```

> [!example] Cas d'usage typique Pour sauvegarder votre projet web avant une mise à jour :
> 
> ```bash
> tar -cvf site_backup_$(date +%Y%m%d).tar /var/www/monsite/
> ```
> 
> Cette commande crée une archive datée comme `site_backup_20241226.tar`

### Ce qui est préservé

Lors de la création d'une archive tar, les éléments suivants sont conservés :

|Élément préservé|Description|
|---|---|
|**Permissions**|rwxr-xr-x conservées|
|**Propriétaire**|UID et GID originaux|
|**Horodatages**|mtime, atime|
|**Liens symboliques**|Préservés en tant que liens|
|**Arborescence**|Structure des répertoires|

> [!warning] Attention aux chemins Par défaut, tar supprime le `/` initial des chemins absolus. Si vous archivez `/home/user/`, le contenu sera extrait dans `home/user/` (chemin relatif). Utilisez l'option `-P` pour forcer les chemins absolus, mais cela peut être dangereux lors de l'extraction.

---

## 🗜️ Options de compression

Les archives tar sont par défaut **non compressées**. Pour économiser de l'espace, on utilise des algorithmes de compression. Tar peut appliquer la compression à la volée lors de la création.

### Les trois principales méthodes

|Compression|Option|Extension|Ratio|Vitesse|Usage recommandé|
|---|---|---|---|---|---|
|**gzip**|`-z`|`.tar.gz` ou `.tgz`|Moyen|Rapide|Usage général, compatible partout|
|**bzip2**|`-j`|`.tar.bz2`|Meilleur|Moyen|Quand l'espace compte plus que le temps|
|**xz**|`-J`|`.tar.xz`|Excellent|Lent|Compression maximale, archives de distribution|

### Syntaxe avec compression

```bash
# Avec gzip (le plus courant)
tar -czvf archive.tar.gz /chemin/vers/donnees/

# Avec bzip2 (meilleure compression)
tar -cjvf archive.tar.bz2 /chemin/vers/donnees/

# Avec xz (compression maximale)
tar -cJvf archive.tar.xz /chemin/vers/donnees/
```

### Comparaison pratique

Prenons l'exemple d'un répertoire de 1 GB :

```bash
# Sans compression
tar -cvf backup.tar /data/
# Résultat : backup.tar = 1.0 GB

# Avec gzip
tar -czvf backup.tar.gz /data/
# Résultat : backup.tar.gz ≈ 300-400 MB (2-3x plus petit)

# Avec bzip2
tar -cjvf backup.tar.bz2 /data/
# Résultat : backup.tar.bz2 ≈ 250-350 MB (3-4x plus petit)

# Avec xz
tar -cJvf backup.tar.xz /data/
# Résultat : backup.tar.xz ≈ 200-300 MB (3-5x plus petit)
```

> [!tip] Choix de la compression
> 
> - **gzip** : choix par défaut, excellent compromis vitesse/taille
> - **bzip2** : pour archives à conserver longtemps (backups mensuels)
> - **xz** : pour distribuer des logiciels ou archives publiques

> [!info] Décompression automatique Tar détecte automatiquement le type de compression lors de l'extraction avec l'option `-x`. Pas besoin de spécifier `-z`, `-j` ou `-J` pour extraire !
> 
> ```bash
> tar -xvf archive.tar.gz   # fonctionne
> tar -xvf archive.tar.bz2  # fonctionne aussi
> tar -xvf archive.tar.xz   # fonctionne également
> ```

### Compression externe (méthode alternative)

On peut aussi compresser après avoir créé l'archive :

```bash
# Créer puis compresser
tar -cvf backup.tar /data/
gzip backup.tar          # crée backup.tar.gz
# ou
bzip2 backup.tar         # crée backup.tar.bz2
# ou
xz backup.tar            # crée backup.tar.xz
```

> [!warning] Compression et CPU La compression consomme du CPU. Sur des systèmes peu puissants ou pour de très grandes archives, privilégiez gzip ou créez l'archive sans compression.

---

## ⚙️ Options importantes de tar

Tar possède de nombreuses options. Voici les plus importantes à maîtriser.

### Options de mode d'opération

Ces options définissent ce que fait tar (mutuellement exclusives) :

|Option|Nom long|Description|
|---|---|---|
|`-c`|`--create`|**Créer** une nouvelle archive|
|`-x`|`--extract`|**Extraire** les fichiers d'une archive|
|`-t`|`--list`|**Lister** le contenu d'une archive|
|`-r`|`--append`|Ajouter des fichiers à une archive existante|
|`-u`|`--update`|Mettre à jour une archive (ajoute si plus récent)|

```bash
# Créer une archive
tar -cvf archive.tar /data/

# Lister le contenu
tar -tvf archive.tar

# Extraire l'archive
tar -xvf archive.tar

# Ajouter des fichiers à une archive existante
tar -rvf archive.tar nouveaux_fichiers/
```

> [!warning] Limitation du mode append Les options `-r` et `-u` ne fonctionnent **pas** avec les archives compressées. Il faut une archive `.tar` non compressée.

### Options de compression (déjà vues)

|Option|Compression|
|---|---|
|`-z`|gzip|
|`-j`|bzip2|
|`-J`|xz|

### Options essentielles

|Option|Nom long|Description|
|---|---|---|
|`-v`|`--verbose`|**Mode verbeux** : affiche les fichiers traités|
|`-f`|`--file=`|**Spécifie le nom** du fichier archive (obligatoire)|
|`-C`|`--directory=`|**Change de répertoire** avant l'opération|
|`-p`|`--preserve-permissions`|Préserve les permissions (par défaut pour root)|
|`-P`|`--absolute-names`|Conserve les chemins absolus (dangereux)|
|`--exclude=`||Exclut des fichiers/motifs|
|`--exclude-from=`||Exclut selon une liste dans un fichier|

### Option -f : spécifier le fichier

L'option `-f` est **obligatoire** pour indiquer le nom de l'archive.

```bash
# CORRECT
tar -cvf backup.tar /data/

# INCORRECT (erreur)
tar -cv backup.tar /data/
# tar tentera d'utiliser /data/ comme nom d'archive

# Position de -f
tar -cvzf archive.tar.gz /data/   # OK
tar -czvf archive.tar.gz /data/   # OK aussi
tar -cfvz archive.tar.gz /data/   # OK, mais moins lisible
```

> [!tip] Convention d'ordre Par convention, on place `-f` en dernier dans le groupe d'options pour que le nom du fichier suive immédiatement : `-czvf archive.tar.gz`

### Option -v : mode verbeux

Le mode verbeux affiche la progression :

```bash
# Sans -v (silencieux)
tar -czf backup.tar.gz /var/log/
# Aucune sortie

# Avec -v (verbeux)
tar -czvf backup.tar.gz /var/log/
# /var/log/
# /var/log/syslog
# /var/log/auth.log
# /var/log/kern.log
# ...
```

> [!info] Quand utiliser -v ?
> 
> - **Scripts automatiques** : omettez `-v` pour éviter du bruit dans les logs
> - **Commandes manuelles** : utilisez `-v` pour suivre la progression
> - **Débogage** : `-v` aide à identifier quel fichier pose problème

### Option -t : lister le contenu

Très utile pour inspecter une archive sans l'extraire :

```bash
# Liste simple
tar -tf backup.tar.gz

# Liste détaillée (avec -v)
tar -tvf backup.tar.gz
# drwxr-xr-x user/user  0 2024-12-26 10:30 data/
# -rw-r--r-- user/user  1024 2024-12-26 10:29 data/file.txt
```

La liste détaillée affiche : permissions, propriétaire/groupe, taille, date, nom.

```bash
# Chercher un fichier spécifique dans l'archive
tar -tzf backup.tar.gz | grep config.ini

# Compter le nombre de fichiers
tar -tzf backup.tar.gz | wc -l
```

### Option -C : changer de répertoire

Permet de changer de répertoire avant d'extraire ou de créer :

```bash
# Extraire dans un répertoire spécifique
tar -xzvf backup.tar.gz -C /tmp/restore/

# Équivalent à :
cd /tmp/restore/
tar -xzvf /path/to/backup.tar.gz

# Créer une archive depuis un répertoire
tar -czvf backup.tar.gz -C /var/www/ html/
# Archive le contenu de /var/www/html/ 
# mais sans inclure /var/www/ dans les chemins
```

> [!tip] Astuce pour extractions propres Créez toujours un répertoire dédié avant d'extraire :
> 
> ```bash
> mkdir restore
> tar -xzvf backup.tar.gz -C restore/
> ```
> 
> Cela évite de polluer le répertoire courant.

### Option --exclude : exclure des fichiers

Indispensable pour éviter d'archiver des données inutiles :

```bash
# Exclure un motif
tar -czvf backup.tar.gz --exclude='*.log' /var/www/

# Exclure plusieurs motifs
tar -czvf backup.tar.gz \
    --exclude='*.log' \
    --exclude='*.tmp' \
    --exclude='cache/*' \
    /var/www/

# Exclure un répertoire complet
tar -czvf backup.tar.gz --exclude='node_modules' /home/user/projet/

# Exclure avec chemin relatif
tar -czvf backup.tar.gz --exclude='data/temp' /home/user/
```

### Option --exclude-from : fichier d'exclusions

Pour de nombreuses exclusions, utilisez un fichier :

```bash
# Créer un fichier d'exclusions
cat > exclude-list.txt << EOF
*.log
*.tmp
cache/
node_modules/
.git/
__pycache__/
EOF

# Utiliser le fichier
tar -czvf backup.tar.gz --exclude-from=exclude-list.txt /var/www/
```

> [!example] Sauvegarde de projet web
> 
> ```bash
> # Exclure les fichiers inutiles d'un site web
> tar -czvf site_backup.tar.gz \
>     --exclude='cache/*' \
>     --exclude='logs/*' \
>     --exclude='*.log' \
>     --exclude='temp/*' \
>     /var/www/monsite/
> ```

### Option -P : chemins absolus (à utiliser avec précaution)

Par défaut, tar supprime le `/` initial pour des raisons de sécurité :

```bash
# Comportement par défaut (sûr)
tar -czvf backup.tar.gz /home/user/documents/
# Contient : home/user/documents/ (chemin relatif)

# Avec -P (dangereux)
tar -czvPf backup.tar.gz /home/user/documents/
# Contient : /home/user/documents/ (chemin absolu)
```

> [!warning] Danger de -P Avec `-P`, lors de l'extraction, les fichiers iront **exactement** au chemin absolu spécifié, ce qui peut :
> 
> - Écraser des fichiers système critiques
> - Nécessiter des droits root
> - Causer des problèmes entre différents systèmes
> 
> **Évitez -P sauf besoin très spécifique !**

### Combinaisons courantes

```bash
# Création avec compression et verbosité
tar -czvf backup.tar.gz /data/

# Extraction vers un répertoire spécifique
tar -xzvf backup.tar.gz -C /restore/

# Lister le contenu de manière détaillée
tar -tvzf backup.tar.gz

# Création avec exclusions multiples
tar -czvf backup.tar.gz \
    --exclude='*.log' \
    --exclude='cache' \
    /var/www/
```

---

## 📂 Sauvegarde de répertoires spécifiques

La sauvegarde ciblée de répertoires est une pratique courante en administration système.

### Sauvegarder un seul répertoire

```bash
# Sauvegarde simple
tar -czvf backup_home.tar.gz /home/user/

# Sauvegarde avec date dans le nom
tar -czvf backup_home_$(date +%Y%m%d).tar.gz /home/user/

# Sauvegarde avec date et heure
tar -czvf backup_home_$(date +%Y%m%d_%H%M%S).tar.gz /home/user/
```

### Sauvegarder plusieurs répertoires

```bash
# Plusieurs répertoires dans une seule archive
tar -czvf backup_multiple.tar.gz /etc/ /home/ /var/www/

# Avec exclusions
tar -czvf backup_system.tar.gz \
    --exclude='/var/log/*' \
    --exclude='/var/cache/*' \
    /etc/ /var/
```

### Sauvegarder depuis la racine du répertoire

Pour éviter d'inclure le chemin complet dans l'archive :

```bash
# Méthode 1 : avec cd
cd /var/www/
tar -czvf /backups/site.tar.gz html/ logs/

# Méthode 2 : avec -C
tar -czvf /backups/site.tar.gz -C /var/www/ html/ logs/

# Résultat : l'archive contient html/ et logs/ directement
# plutôt que var/www/html/ et var/www/logs/
```

> [!tip] Avantage de cette approche L'extraction est plus propre : les fichiers s'extraient directement dans le répertoire courant sans recréer toute la hiérarchie.

### Sauvegarde incrémentale (par date de modification)

Bien que tar ne soit pas un outil de sauvegarde incrémentale natif, on peut sauvegarder les fichiers modifiés récemment :

```bash
# Fichiers modifiés dans les dernières 24h
find /home/user/ -type f -mtime -1 -print0 | \
    tar -czvf backup_daily.tar.gz --null -T -

# Fichiers modifiés depuis une date spécifique
tar -czvf backup_recent.tar.gz \
    --newer-mtime="2024-12-20" \
    /home/user/
```

### Sauvegarde avec structure préservée

Pour conserver l'arborescence exacte :

```bash
# Archive uniquement les fichiers .conf de /etc/
# en préservant la structure des sous-répertoires
tar -czvf configs.tar.gz $(find /etc/ -name "*.conf")

# Meilleure approche pour éviter les problèmes d'espaces
find /etc/ -name "*.conf" -print0 | \
    tar -czvf configs.tar.gz --null -T -
```

### Organisation des sauvegardes

#### Structure recommandée

```bash
/backups/
├── daily/
│   ├── backup_20241224.tar.gz
│   ├── backup_20241225.tar.gz
│   └── backup_20241226.tar.gz
├── weekly/
│   ├── backup_week51.tar.gz
│   └── backup_week52.tar.gz
└── monthly/
    ├── backup_2024-11.tar.gz
    └── backup_2024-12.tar.gz
```

#### Script de sauvegarde organisée

```bash
#!/bin/bash
BACKUP_DIR="/backups/daily"
DATE=$(date +%Y%m%d)
SOURCE="/home/user/important"

# Créer le répertoire si nécessaire
mkdir -p "$BACKUP_DIR"

# Créer la sauvegarde
tar -czvf "$BACKUP_DIR/backup_$DATE.tar.gz" \
    --exclude='*.tmp' \
    --exclude='cache/*' \
    "$SOURCE"

# Nettoyer les sauvegardes de plus de 7 jours
find "$BACKUP_DIR" -name "backup_*.tar.gz" -mtime +7 -delete
```

### Vérification d'intégrité

Toujours vérifier qu'une archive est valide après sa création :

```bash
# Créer et vérifier
tar -czvf backup.tar.gz /data/
tar -tzf backup.tar.gz > /dev/null && echo "Archive OK" || echo "Archive corrompue"

# Comparer l'archive avec la source (liste les différences)
tar -diff -f backup.tar -C /

# Tester l'extraction sans extraire réellement
tar -tzvf backup.tar.gz > /dev/null
```

### Sauvegardes avec métadonnées

Pour inclure des informations sur la sauvegarde :

```bash
# Créer un fichier de métadonnées
cat > backup_info.txt << EOF
Date: $(date)
Hôte: $(hostname)
Utilisateur: $(whoami)
Source: /home/user/documents
EOF

# Inclure les métadonnées dans l'archive
tar -czvf backup.tar.gz backup_info.txt /home/user/documents/
rm backup_info.txt
```

### Sauvegarde multi-volumes

Pour archives trop volumineuses pour un seul support :

```bash
# Créer une archive divisée en morceaux de 1GB
tar -czvf - /data/ | split -b 1G - backup.tar.gz.part

# Cela crée : backup.tar.gz.partaa, backup.tar.gz.partab, etc.

# Reconstituer et extraire
cat backup.tar.gz.part* | tar -xzv
```

---

## ⚠️ Pièges courants et bonnes pratiques

### Pièges fréquents

#### 1. Oublier l'option -f

```bash
# ERREUR
tar -czv backup.tar.gz /data/
# tar: Cowardly refusing to create an empty archive

# CORRECT
tar -czvf backup.tar.gz /data/
```

#### 2. Ordre des options avec -f

```bash
# INCORRECT
tar -cvfz backup.tar.gz /data/
# tar essaiera de créer un fichier nommé "z"

# CORRECT
tar -czvf backup.tar.gz /data/
# ou
tar -cvzf backup.tar.gz /data/
```

#### 3. Écraser accidentellement des fichiers

```bash
# DANGER : écrase l'archive existante
tar -czvf backup.tar.gz /new/data/  # écrase backup.tar.gz

# MIEUX : utiliser des noms uniques
tar -czvf backup_$(date +%Y%m%d_%H%M%S).tar.gz /data/
```

#### 4. Chemins absolus dans les archives

```bash
# Problématique
tar -czvf backup.tar.gz /home/user/
# Extraction vers /home/user/ uniquement

# Solution : utiliser chemins relatifs
cd /home/
tar -czvf backup.tar.gz user/
# ou
tar -czvf backup.tar.gz -C /home/ user/
```

#### 5. Extraire sans vérifier le contenu

```bash
# DANGER : peut polluer le répertoire courant
tar -xzvf unknown.tar.gz

# SÉCURISÉ : vérifier d'abord le contenu
tar -tzf unknown.tar.gz
mkdir extraction_dir
tar -xzvf unknown.tar.gz -C extraction_dir/
```

#### 6. Oublier d'exclure des fichiers volumineux

```bash
# Archive inutilement grosse
tar -czvf backup.tar.gz /var/www/

# Mieux : exclure les caches et logs
tar -czvf backup.tar.gz \
    --exclude='*.log' \
    --exclude='cache/*' \
    /var/www/
```

#### 7. Permissions insuffisantes

```bash
# ERREUR si pas root
tar -czvf backup.tar.gz /etc/
# tar: /etc/shadow: Permission denied

# Solution : utiliser sudo
sudo tar -czvf backup.tar.gz /etc/

# Ou limiter aux fichiers accessibles
tar -czvf backup.tar.gz /etc/ 2>/dev/null
```

### Bonnes pratiques essentielles

#### ✅ Nommer clairement les archives

```bash
# Mauvais
tar -czvf backup.tar.gz /data/

# Bon
tar -czvf backup_website_20241226.tar.gz /var/www/

# Excellent (avec type et date)
PROJECT="myapp"
TYPE="full"
DATE=$(date +%Y%m%d)
tar -czvf ${PROJECT}_${TYPE}_${DATE}.tar.gz /opt/myapp/
```

#### ✅ Toujours vérifier les sauvegardes

```bash
# Créer
tar -czvf backup.tar.gz /important/data/

# Vérifier immédiatement
if tar -tzf backup.tar.gz > /dev/null 2>&1; then
    echo "✓ Sauvegarde valide"
else
    echo "✗ Sauvegarde corrompue !"
    exit 1
fi
```

#### ✅ Documenter les exclusions

```bash
# Créer un fichier d'exclusions commenté
cat > exclude-patterns.txt << EOF
# Fichiers temporaires
*.tmp
*.swp

# Caches applicatifs
cache/
tmp/

# Logs
*.log
logs/

# Dépendances (à réinstaller)
node_modules/
vendor/
EOF

tar -czvf backup.tar.gz --exclude-from=exclude-patterns.txt /projet/
```

#### ✅ Tester l'extraction

```bash
# Après création, tester dans /tmp
tar -czvf backup.tar.gz /data/
mkdir /tmp/test_restore
tar -xzvf backup.tar.gz -C /tmp/test_restore/
# Vérifier quelques fichiers clés
ls -la /tmp/test_restore/data/
rm -rf /tmp/test_restore
```

#### ✅ Utiliser la compression adaptée

```bash
# Données déjà compressées (images, vidéos, archives)
# → pas de compression (gaspillage de CPU)
tar -cvf backup_media.tar /media/photos/

# Logs, texte, code source
# → gzip (bon compromis)
tar -czvf backup_logs.tar.gz /var/log/

# Archives d'archivage long terme
# → xz (compression maximale)
tar -cJvf backup_archives.tar.xz /archives/2024/
```

#### ✅ Sécuriser les sauvegardes sensibles

```bash
# Chiffrer avec GPG après création
tar -czvf backup.tar.gz /data/
gpg --symmetric --cipher-algo AES256 backup.tar.gz
# Crée backup.tar.gz.gpg (chiffré)
rm backup.tar.gz  # supprimer la version non chiffrée

# Déchiffrer et extraire
gpg --decrypt backup.tar.gz.gpg | tar -xzv
```

#### ✅ Rotation des sauvegardes

```bash
# Conserver seulement les 7 dernières sauvegardes
BACKUP_DIR="/backups"
find "$BACKUP_DIR" -name "backup_*.tar.gz" -mtime +7 -delete

# Ou garder un nombre fixe (garder les 10 plus récentes)
ls -t "$BACKUP_DIR"/backup_*.tar.gz | tail -n +11 | xargs rm -f
```

#### ✅ Logger les opérations

```bash
# Avec log des opérations
LOG_FILE="/var/log/backups.log"
echo "$(date): Début sauvegarde" >> "$LOG_FILE"

tar -czvf backup_$(date +%Y%m%d).tar.gz /data/ \
    >> "$LOG_FILE" 2>&1

if [ $? -eq 0 ]; then
    echo "$(date): Sauvegarde réussie" >> "$LOG_FILE"
else
    echo "$(date): ERREUR sauvegarde" >> "$LOG_FILE"
fi
```

### Astuces avancées

#### 🚀 Sauvegarde parallèle (pigz)

```bash
# Installation de pigz (gzip parallèle)
# sudo apt install pigz

# Utilisation avec tar (beaucoup plus rapide sur multi-cores)
tar -cv /data/ | pigz > backup.tar.gz

# Décompression parallèle
pigz -dc backup.tar.gz | tar -xv
```

#### 🚀 Afficher la progression

```bash
# Avec pv (pipe viewer)
# sudo apt install pv

tar -czf - /data/ | pv > backup.tar.gz

# Ou lors de l'extraction
pv backup.tar.gz | tar -xzf -
```

#### 🚀 Sauvegarde distante avec SSH

```bash
# Créer et envoyer directement sur serveur distant
tar -czf - /data/ | ssh user@server "cat > /backup/backup.tar.gz"

# Récupérer depuis serveur distant
ssh user@server "tar -czf - /remote/data/" > backup.tar.gz
```

#### 🚀 Comparer deux archives

```bash
# Lister et comparer
diff <(tar -tzf backup1.tar.gz | sort) \
     <(tar -tzf backup2.tar.gz | sort)
```

> [!tip] Mémo rapide tar
> 
> - **Créer** : `tar -czvf archive.tar.gz /source/`
> - **Lister** : `tar -tzf archive.tar.gz`
> - **Extraire** : `tar -xzvf archive.tar.gz -C /destination/`
> - **Exclure** : ajouter `--exclude='pattern'`
> - **Vérifier** : toujours tester avec `tar -tzf` après création

---

> [!info] Résumé des options tar
> 
> |Option|Action|
> |---|---|
> |`-c`|Créer une archive|
> |`-x`|Extraire une archive|
> |`-t`|Lister le contenu|
> |`-v`|Mode verbeux|
> |`-f`|Spécifier le fichier (obligatoire)|
> |`-z`|Compression gzip|
> |`-j`|Compression bzip2|
> |`-J`|Compression xz|
> |`-C`|Changer de répertoire|
> |`--exclude`|Exclure des fichiers|