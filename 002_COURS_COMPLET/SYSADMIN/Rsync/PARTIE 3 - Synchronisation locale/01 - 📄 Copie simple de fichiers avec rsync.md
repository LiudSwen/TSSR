

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

## Copie d'un fichier unique

### 🎯 Principe de base

La copie d'un fichier unique avec rsync est l'opération la plus simple. Bien que `cp` soit souvent suffisant pour cette tâche, rsync offre des avantages même dans ce cas simple : reprise en cas d'interruption, vérification de l'intégrité, et options de préservation avancées.

### Syntaxe fondamentale

```bash
rsync source.txt destination.txt
```

> [!info] Comparaison avec cp Cette commande rsync est fonctionnellement équivalente à `cp source.txt destination.txt`, mais rsync vérifie si le fichier de destination existe déjà et ne le copie que si nécessaire.

### Avec options courantes

```bash
# Copie avec préservation des attributs et affichage détaillé
rsync -av fichier.txt /chemin/destination/

# Copie avec progression en temps réel
rsync -av --progress document.pdf /backup/

# Copie avec affichage lisible des tailles
rsync -avh --progress grosfichier.iso /media/usb/
```

> [!tip] Option -a (archive) L'option `-a` est quasi-systématique car elle préserve :
> 
> - Les permissions
> - Les dates de modification
> - Les liens symboliques
> - Les propriétaires (si exécuté en root)

### Exemple détaillé avec sortie

```bash
$ rsync -avh --progress presentation.pptx /backup/documents/

sending incremental file list
presentation.pptx
      45.23M 100%   89.45MB/s    0:00:00 (xfr#1, to-chk=0/1)

sent 45.25M bytes  received 35 bytes  30.17M bytes/sec
total size is 45.23M  speedup is 1.00
```

---

## Copie de plusieurs fichiers

### 🎯 Méthodes de sélection multiple

Il existe plusieurs façons de copier plusieurs fichiers en une seule commande rsync.

### Énumération explicite

```bash
# Copie de fichiers spécifiques vers un répertoire
rsync -av fichier1.txt fichier2.txt fichier3.txt /destination/

# Avec chemins complets
rsync -av /home/user/doc1.pdf /home/user/doc2.pdf /backup/
```

> [!warning] Destination obligatoirement un répertoire Quand vous spécifiez plusieurs sources, la destination **doit** être un répertoire existant, sinon rsync retournera une erreur.

### Utilisation de wildcards (patterns)

```bash
# Tous les fichiers .txt du répertoire courant
rsync -av *.txt /backup/textes/

# Tous les fichiers .log et .conf
rsync -av *.log *.conf /backup/config/

# Fichiers commençant par "rapport"
rsync -av rapport*.pdf /archives/2024/
```

### Copie sélective avec filtres

```bash
# Tous les .jpg mais pas les thumbnails
rsync -av --exclude='thumb_*' *.jpg /photos/backup/

# Fichiers modifiés aujourd'hui uniquement
find . -maxdepth 1 -type f -mtime 0 | rsync -av --files-from=- . /backup/today/
```

> [!example] Cas pratique : sauvegarde de logs
> 
> ```bash
> # Copier tous les logs du mois en cours
> rsync -av --progress /var/log/app-2024-01-*.log /backup/logs/janvier/
> ```

---

## Comportement avec répertoires

### 🎯 Différence fondamentale : slash final

Le comportement de rsync change **radicalement** selon la présence ou l'absence d'un slash final sur la source.

### Sans slash final (copie du répertoire lui-même)

```bash
rsync -av /source/dossier /destination/
```

**Résultat :** Crée `/destination/dossier/` avec tout son contenu

```
Avant :
/source/dossier/
    ├── fichier1.txt
    └── fichier2.txt

Après :
/destination/dossier/
    ├── fichier1.txt
    └── fichier2.txt
```

### Avec slash final (copie du contenu uniquement)

```bash
rsync -av /source/dossier/ /destination/
```

**Résultat :** Copie le **contenu** de dossier directement dans /destination/

```
Avant :
/source/dossier/
    ├── fichier1.txt
    └── fichier2.txt

Après :
/destination/
    ├── fichier1.txt
    └── fichier2.txt
```

> [!warning] Piège fréquent du slash final C'est l'une des erreurs les plus courantes avec rsync ! Toujours vérifier le slash final avant de lancer une commande importante.

### Tableau comparatif

|Commande|Source|Destination|Résultat|
|---|---|---|---|
|`rsync -av dir /dest/`|Sans /|Quelconque|`/dest/dir/` créé|
|`rsync -av dir/ /dest/`|Avec /|Quelconque|Contenu copié dans `/dest/`|
|`rsync -av dir /dest`|Sans /|Sans / existant|`/dest/dir/` créé|
|`rsync -av dir/ /dest/`|Avec /|Avec /|Contenu fusionné dans `/dest/`|

### Exemples pratiques comparés

```bash
# Exemple 1 : Copier le dossier "projets" dans /backup
rsync -av /home/user/projets /backup/
# Résultat : /backup/projets/

# Exemple 2 : Copier le contenu de "projets" dans /backup
rsync -av /home/user/projets/ /backup/
# Résultat : fichiers directement dans /backup/

# Exemple 3 : Synchroniser contenu identique
rsync -av /home/user/documents/ /media/usb/documents/
# Les deux dossiers "documents" auront le même contenu
```

> [!tip] Astuce mnémotechnique **Slash final = "je veux le contenu, pas le contenant"**
> 
> Pensez au slash comme à une indication : "ouvre ce dossier et prends ce qu'il y a dedans"

### Copie récursive de sous-répertoires

Par défaut avec `-a`, rsync copie récursivement tous les sous-répertoires :

```bash
rsync -av /source/projet/ /backup/

# Structure complète préservée :
/source/projet/
    ├── src/
    │   ├── main.c
    │   └── utils.c
    ├── docs/
    │   └── readme.md
    └── tests/
        └── test.sh

# Devient :
/backup/
    ├── src/
    │   ├── main.c
    │   └── utils.c
    ├── docs/
    │   └── readme.md
    └── tests/
        └── test.sh
```

### Limiter la profondeur de copie

```bash
# Copier uniquement le premier niveau (pas de récursion)
rsync -av --max-depth=1 /source/ /destination/

# Copier jusqu'à 2 niveaux de profondeur
rsync -av --max-depth=2 /source/ /destination/
```

> [!info] Option --max-depth Utile pour copier une structure de dossiers sans aller trop en profondeur, par exemple pour une vue d'ensemble ou un audit rapide.

---

## 💡 Bonnes pratiques pour la copie simple

### Vérification avant exécution

```bash
# Toujours tester avec --dry-run d'abord
rsync -av --dry-run source/ destination/

# Vérifier ce qui serait copié
rsync -avn source/ destination/
```

### Gestion des fichiers existants

```bash
# Mode par défaut : écrase si différent, ignore si identique
rsync -av source.txt /destination/

# Préserver les fichiers plus récents en destination
rsync -avu source/ destination/

# Sauvegarder les versions écrasées
rsync -av --backup --suffix=.old source/ destination/
```

> [!tip] Option -u (update) L'option `-u` évite d'écraser des fichiers plus récents en destination, utile pour éviter de perdre des modifications récentes.

### Affichage et suivi

```bash
# Affichage minimal
rsync -a source/ destination/

# Affichage détaillé
rsync -av source/ destination/

# Avec progression pour gros fichiers
rsync -av --progress source/ destination/

# Format lisible pour les tailles
rsync -avh --progress source/ destination/
```

---

## ⚠️ Pièges courants

### 1. Oubli du slash final

```bash
# ❌ ERREUR : Va créer /backup/home au lieu de copier le contenu
rsync -av /home /backup

# ✅ CORRECT : Copie le contenu de /home dans /backup
rsync -av /home/ /backup/
```

### 2. Destination non-existante avec plusieurs fichiers

```bash
# ❌ ERREUR : /inexistant n'existe pas
rsync -av fichier1 fichier2 fichier3 /inexistant/
# rsync: link_stat "/inexistant" failed: No such file or directory

# ✅ CORRECT : Créer d'abord la destination
mkdir -p /destination
rsync -av fichier1 fichier2 fichier3 /destination/
```

### 3. Permissions insuffisantes

```bash
# ❌ Peut échouer si fichiers appartiennent à root
rsync -av /var/log/ /backup/

# ✅ Utiliser sudo si nécessaire
sudo rsync -av /var/log/ /backup/
```

> [!warning] Préservation des propriétaires L'option `-a` inclut `-o` (owner) et `-g` (group), qui nécessitent les droits root pour être appliqués. Sans root, vous aurez des warnings mais la copie continuera.

---

## 🎓 Cas d'usage typiques

### Sauvegarde d'un fichier important avant modification

```bash
# Créer une copie de sécurité datée
rsync -av config.conf config.conf.backup-$(date +%Y%m%d)
```

### Copie de fichiers volumineux avec reprise

```bash
# Si la connexion est interrompue, relancer la même commande
rsync -av --partial --progress film-4K.mp4 /media/disque-externe/
```

> [!tip] Option --partial Conserve les fichiers partiellement transférés, permettant la reprise exactement où le transfert s'est arrêté.

### Migration sélective de fichiers

```bash
# Copier tous les PDF sauf les brouillons
rsync -av --exclude='*draft*' *.pdf /archives/documents-finaux/
```

### Copie avec préservation maximale

```bash
# Préserver absolument tous les attributs (ACL, xattrs, etc.)
rsync -avAX --hard-links source/ destination/
```