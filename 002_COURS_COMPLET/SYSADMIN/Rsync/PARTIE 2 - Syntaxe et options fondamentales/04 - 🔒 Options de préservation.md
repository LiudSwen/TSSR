

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

## Introduction

Les options de préservation permettent de conserver les métadonnées des fichiers lors de la synchronisation. Ces options sont essentielles pour maintenir l'intégrité des systèmes de fichiers, particulièrement dans les contextes de sauvegarde ou de migration.

> [!info] Rappel important
> L'option `-a` (archive) inclut déjà la plupart de ces options. Cependant, comprendre chaque option individuellement permet une utilisation fine de rsync selon vos besoins spécifiques.

---

## Option `-p` : Préservation des permissions

### 🎯 Objectif

Préserve les permissions Unix (lecture, écriture, exécution) pour l'utilisateur, le groupe et les autres.

### Pourquoi c'est important

Sans cette option, les fichiers copiés héritent des permissions par défaut (généralement définies par umask), ce qui peut casser des scripts exécutables ou compromettre la sécurité.

### Syntaxe

```bash
rsync -p source/ destination/
# ou version longue
rsync --perms source/ destination/
```

### Exemple pratique

```bash
# Fichier source avec permissions spécifiques
ls -l /source/script.sh
# -rwxr-x--- 1 user group 1234 Jan 25 10:00 script.sh

# Sans -p : les permissions sont perdues
rsync /source/script.sh /destination/
ls -l /destination/script.sh
# -rw-r--r-- 1 user group 1234 Jan 25 10:00 script.sh

# Avec -p : les permissions sont préservées
rsync -p /source/script.sh /destination/
ls -l /destination/script.sh
# -rwxr-x--- 1 user group 1234 Jan 25 10:00 script.sh
```

> [!warning] Permissions spéciales
> L'option `-p` préserve aussi les bits spéciaux (setuid, setgid, sticky bit). Soyez vigilant lors de copies vers des environnements différents.

### Astuces

- Combinée avec `-v`, vous pouvez voir quelles permissions sont appliquées
- Utile pour copier des scripts shell, binaires, ou tout fichier nécessitant des permissions spécifiques

---

## Option `-o` : Préservation du propriétaire

### 🎯 Objectif

Préserve l'UID (User ID) du propriétaire du fichier.

### Pourquoi c'est important

Sans cette option, les fichiers appartiendront à l'utilisateur qui exécute rsync. Essentiel pour les sauvegardes système ou les migrations de serveurs.

### Syntaxe

```bash
rsync -o source/ destination/
# ou version longue
rsync --owner source/ destination/
```

> [!warning] Privilèges requis
> Cette option nécessite généralement les **privilèges root** (sudo). Un utilisateur normal ne peut pas attribuer des fichiers à d'autres utilisateurs.

### Exemple pratique

```bash
# Fichier appartenant à www-data
ls -l /var/www/html/index.php
# -rw-r--r-- 1 www-data www-data 5678 Jan 25 10:00 index.php

# Sans -o (en tant qu'utilisateur admin)
rsync /var/www/html/index.php /backup/
ls -l /backup/index.php
# -rw-r--r-- 1 admin admin 5678 Jan 25 10:00 index.php

# Avec -o (nécessite sudo)
sudo rsync -o /var/www/html/index.php /backup/
ls -l /backup/index.php
# -rw-r--r-- 1 www-data www-data 5678 Jan 25 10:00 index.php
```

### Cas d'usage typiques

- Sauvegarde complète de systèmes
- Migration de serveurs web (préserver www-data, nginx, etc.)
- Restauration de bases de données (préserver mysql, postgres)
- Copie de home directories

> [!tip] Astuce : Mapping d'utilisateurs
> Pour les transferts entre systèmes avec des UIDs différents, regardez les options `--usermap` et `--groupmap` (non couvertes dans cette partie).

---

## Option `-g` : Préservation du groupe

### 🎯 Objectif

Préserve le GID (Group ID) du groupe propriétaire du fichier.

### Pourquoi c'est important

Les groupes Unix contrôlent l'accès collaboratif aux fichiers. Préserver les groupes est crucial pour maintenir les permissions d'équipe.

### Syntaxe

```bash
rsync -g source/ destination/
# ou version longue
rsync --group source/ destination/
```

> [!warning] Privilèges et groupes
> Comme pour `-o`, cette option nécessite souvent les privilèges root, surtout si vous n'êtes pas membre du groupe cible.

### Exemple pratique

```bash
# Fichier appartenant au groupe 'developers'
ls -l /project/app.py
# -rw-rw-r-- 1 alice developers 2345 Jan 25 10:00 app.py

# Sans -g
rsync /project/app.py /backup/
ls -l /backup/app.py
# -rw-rw-r-- 1 alice alice 2345 Jan 25 10:00 app.py

# Avec -g (nécessite sudo si vous n'êtes pas dans 'developers')
sudo rsync -g /project/app.py /backup/
ls -l /backup/app.py
# -rw-rw-r-- 1 alice developers 2345 Jan 25 10:00 app.py
```

### Cas d'usage typiques

- Environnements de développement collaboratif
- Projets avec permissions par équipe
- Serveurs multi-utilisateurs
- Sauvegardes de dossiers partagés

> [!example] Exemple réel
> Dans un environnement avec les groupes `dev`, `ops`, et `qa`, préserver les groupes permet de maintenir les permissions d'accès après une restauration.

---

## Option `-t` : Préservation des timestamps

### 🎯 Objectif

Préserve les dates de modification (mtime) des fichiers et répertoires.

### Pourquoi c'est important

Les timestamps sont utilisés par rsync pour la synchronisation incrémentale. Sans `-t`, rsync recopiera systématiquement tous les fichiers, même s'ils n'ont pas changé.

### Syntaxe

```bash
rsync -t source/ destination/
# ou version longue
rsync --times source/ destination/
```

### Exemple pratique

```bash
# Fichier avec timestamp spécifique
ls -l /source/document.txt
# -rw-r--r-- 1 user group 1024 Jan 20 14:30 document.txt

# Sans -t
rsync /source/document.txt /destination/
ls -l /destination/document.txt
# -rw-r--r-- 1 user group 1024 Jan 25 10:00 document.txt  # Date = maintenant

# Avec -t
rsync -t /source/document.txt /destination/
ls -l /destination/document.txt
# -rw-r--r-- 1 user group 1024 Jan 20 14:30 document.txt  # Date préservée
```

### Impact sur les synchronisations suivantes

```bash
# Première synchro avec -t
rsync -t /source/ /destination/

# Le fichier n'a pas changé
# Deuxième synchro : rsync compare les timestamps
rsync -t /source/ /destination/
# Aucun fichier transféré (timestamps identiques)

# Sans -t lors de la première synchro
# Deuxième synchro : rsync ne peut pas comparer
rsync /source/ /destination/
# Tous les fichiers sont recopiés !
```

> [!warning] Performance critique
> Ne pas utiliser `-t` transforme chaque synchronisation en copie complète, annulant le principal avantage de rsync.

### Types de timestamps Unix

| Timestamp | Signification | Préservé par rsync |
|-----------|---------------|-------------------|
| **mtime** | Modification time (contenu) | Oui avec `-t` |
| **atime** | Access time (lecture) | Non par défaut |
| **ctime** | Change time (métadonnées) | Non préservable |

> [!tip] Astuce : Comparaison par checksum
> Si vous ne pouvez pas utiliser `-t`, utilisez `-c` pour comparer par checksum (plus lent mais fiable).

---

## Option `--links` : Préservation des liens symboliques

### 🎯 Objectif

Préserve les liens symboliques en tant que liens, plutôt que de copier les fichiers pointés.

### Pourquoi c'est important

Les liens symboliques sont fondamentaux dans les systèmes Unix pour organiser les fichiers, gérer les versions, et créer des alias. Les préserver maintient l'architecture du système.

### Syntaxe

```bash
rsync --links source/ destination/
# ou version courte
rsync -l source/ destination/
```

### Comportement par défaut vs avec `--links`

```bash
# Création d'un lien symbolique
ln -s /usr/share/doc/example /source/doc-link

# Sans --links : le fichier pointé est copié
rsync /source/doc-link /destination/
ls -l /destination/doc-link
# -rw-r--r-- 1 user group 4096 Jan 25 10:00 doc-link  # Fichier normal

# Avec --links : le lien est préservé
rsync --links /source/doc-link /destination/
ls -l /destination/doc-link
# lrwxrwxrwx 1 user group 24 Jan 25 10:00 doc-link -> /usr/share/doc/example
```

### Cas particuliers

#### Liens symboliques absolus

```bash
# Lien avec chemin absolu
ln -s /var/log/apache2/error.log /source/error-log

rsync --links /source/error-log /destination/
ls -l /destination/error-log
# lrwxrwxrwx 1 user group ... error-log -> /var/log/apache2/error.log

# ⚠️ Le lien pointe toujours vers /var/log/apache2/error.log
# Qui peut ne pas exister sur le système de destination !
```

> [!warning] Liens absolus et chemins
> Les liens symboliques absolus peuvent devenir invalides après copie si la structure du système de destination diffère.

#### Liens symboliques relatifs

```bash
# Lien avec chemin relatif
cd /source
ln -s ../configs/app.conf current-config

rsync --links /source/ /destination/
# Le lien relatif fonctionne si la structure est identique
```

### Options complémentaires

#### `--copy-links` : Copier les fichiers pointés

```bash
rsync --copy-links source/ destination/
# Les liens sont suivis et les fichiers pointés sont copiés
```

#### `--copy-unsafe-links` : Copier les liens dangereux

```bash
rsync --copy-unsafe-links source/ destination/
# Copie les liens qui pointent en dehors de l'arborescence source
```

> [!example] Exemple pratique : Logs rotationnés
> ```bash
> # Structure typique de logs
> # /var/log/app.log -> app.log.1
> # /var/log/app.log.1 (fichier réel)
> 
> rsync -l /var/log/ /backup/logs/
> # Le lien est préservé, structure identique
> ```

### Astuces

- Utilisez `--links` pour préserver l'architecture logique
- Vérifiez toujours les liens après copie vers un système différent
- Pour une copie "déréférencée" complète, utilisez `--copy-links`

---

## Combinaisons et interactions

### L'option `-a` : Archive mode

L'option `-a` est équivalente à :

```bash
-rlptgoD
```

Soit :
- `-r` : récursif
- `-l` : liens symboliques (`--links`)
- `-p` : permissions
- `-t` : timestamps
- `-g` : groupe
- `-o` : propriétaire
- `-D` : fichiers spéciaux (devices)

> [!info] Option recommandée
> Pour la plupart des sauvegardes, utilisez simplement `-a` qui inclut toutes les options de préservation essentielles.

### Utilisation sélective

Vous pouvez combiner manuellement les options selon vos besoins :

```bash
# Préserver permissions et timestamps, mais pas propriétaire/groupe
rsync -pt source/ destination/

# Préserver tout sauf les liens symboliques
rsync -rptgo source/ destination/

# Mode archive sans préservation du propriétaire
rsync -a --no-o source/ destination/
```

### Cas d'usage par profil

#### Sauvegarde système complète (root)

```bash
sudo rsync -aAX --delete /source/ /backup/
# -a : archive (inclut -rlptgoD)
# -A : ACLs
# -X : attributs étendus
```

#### Synchronisation utilisateur normal

```bash
rsync -rlt --delete /home/user/documents/ /backup/docs/
# -r : récursif
# -l : liens
# -t : timestamps
# (pas -o/-g car impossibles sans root)
```

#### Copie rapide sans métadonnées

```bash
rsync -r source/ destination/
# Juste récursif, permissions par défaut
```

---

## Tableau récapitulatif

| Option | Nom long | Préserve | Privilèges requis | Inclus dans `-a` |
|--------|----------|----------|-------------------|------------------|
| `-p` | `--perms` | Permissions (rwx) | Non | ✅ Oui |
| `-o` | `--owner` | Propriétaire (UID) | Souvent root | ✅ Oui |
| `-g` | `--group` | Groupe (GID) | Souvent root | ✅ Oui |
| `-t` | `--times` | Timestamp mtime | Non | ✅ Oui |
| `-l` | `--links` | Liens symboliques | Non | ✅ Oui |

---

## Pièges courants

### ❌ Oublier `-t` pour la synchro incrémentale

```bash
# MAUVAIS : recopie tout à chaque fois
rsync -av /source/ /backup/  # Ah non wait, -a inclut -t, c'est bon !

# MAUVAIS : vraiment mauvais
rsync -rpgo /source/ /backup/  # Pas de -t = recopie complète
```

> [!warning] Toujours inclure `-t`
> Sans timestamps, rsync perd sa capacité à faire de la synchronisation incrémentale.

### ❌ Utiliser `-o`/`-g` sans privilèges

```bash
# En tant qu'utilisateur normal
rsync -a /source/ /backup/
# rsync: chown "/backup/file" failed: Operation not permitted (1)
```

**Solution :**

```bash
# Soit avec sudo
sudo rsync -a /source/ /backup/

# Soit sans préservation propriétaire/groupe
rsync -rlt /source/ /backup/
```

### ❌ Liens symboliques absolus cassés

```bash
# Sur serveur A
ln -s /opt/app/config /source/config-link

# Copie vers serveur B
rsync -a serverA:/source/ /destination/

# Sur serveur B
ls -l /destination/config-link
# lrwxrwxrwx ... config-link -> /opt/app/config  # ⚠️ Peut ne pas exister !
```

**Solution :** Vérifiez manuellement les liens après copie, ou utilisez `--copy-unsafe-links`.

### ❌ Confondre mtime, atime et ctime

```bash
# -t préserve UNIQUEMENT mtime (modification)
# Les access times (atime) ne sont pas préservés par défaut
```

---

> [!tip] Bonnes pratiques finales
> 
> **Pour les sauvegardes système :**
> ```bash
> sudo rsync -aAX --delete source/ destination/
> ```
> 
> **Pour les synchronisations utilisateur :**
> ```bash
> rsync -rlt --delete source/ destination/
> ```
> 
> **Pour une copie simple sans métadonnées :**
> ```bash
> rsync -r source/ destination/
> ```

---

*Fin du chapitre sur les options de préservation*