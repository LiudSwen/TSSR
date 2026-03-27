

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

## Structure de la commande

### Schéma général

La commande rsync suit toujours cette structure fondamentale :

```bash
rsync [OPTIONS] SOURCE DESTINATION
```

> [!info] Anatomie de la commande
> 
> - **rsync** : la commande elle-même
> - **[OPTIONS]** : paramètres qui modifient le comportement (optionnel mais recommandé)
> - **SOURCE** : ce que vous voulez copier (fichier, répertoire, pattern)
> - **DESTINATION** : où vous voulez copier

### Exemple minimal

```bash
# Copie d'un fichier simple
rsync fichier.txt /tmp/sauvegarde/

# Copie d'un répertoire
rsync -a /home/user/documents/ /backup/documents/
```

> [!warning] Ordre important L'ordre SOURCE → DESTINATION est **impératif**. Inverser source et destination peut écraser vos données originales !

---

## Source et destination

### Types de chemins acceptés

rsync accepte plusieurs formats pour spécifier source et destination :

|Type|Syntaxe|Exemple|
|---|---|---|
|**Chemin absolu**|`/chemin/complet`|`/var/www/html`|
|**Chemin relatif**|`chemin/relatif`|`documents/projets`|
|**Répertoire courant**|`.` ou `./`|`./data`|
|**Répertoire parent**|`..`|`../backup`|
|**Home utilisateur**|`~`|`~/Documents`|

### Spécifier plusieurs sources

```bash
# Plusieurs fichiers vers une destination
rsync file1.txt file2.txt file3.txt /backup/

# Utilisation de wildcards
rsync *.log /var/log/archives/

# Plusieurs répertoires
rsync -a dir1/ dir2/ dir3/ /backup/
```

> [!tip] Pattern matching rsync supporte les wildcards bash standards :
> 
> - `*` : n'importe quelle chaîne de caractères
> - `?` : un seul caractère
> - `[abc]` : un caractère parmi a, b, ou c
> - `{jpg,png}` : extension jpg ou png

### Destination : fichier ou répertoire ?

Le comportement change selon que la destination existe ou non :

```bash
# Si /backup/data/ existe → copie DANS ce répertoire
rsync -a documents/ /backup/data/

# Si /backup/archives n'existe pas → crée ce répertoire avec le contenu
rsync -a documents/ /backup/archives
```

> [!example] Comportement pratique
> 
> ```bash
> # Structure initiale
> documents/
>   ├── rapport.pdf
>   └── presentation.ppt
> 
> # Commande
> rsync -a documents/ /backup/data/
> 
> # Si /backup/data/ existe déjà :
> /backup/data/
>   ├── rapport.pdf
>   └── presentation.ppt
> 
> # Si /backup/data/ n'existe pas :
> /backup/data/        # Ce répertoire est créé
>   ├── rapport.pdf
>   └── presentation.ppt
> ```

---

## Copie locale vs distante

### Copie locale

Les deux chemins sont sur la même machine :

```bash
# Syntaxe locale simple
rsync [OPTIONS] /source/locale /destination/locale

# Exemples
rsync -av /home/user/photos/ /backup/photos/
rsync -av ./projet/ /media/usb/sauvegardes/
```

> [!info] Quand utiliser rsync en local ?
> 
> - Synchronisation incrémentale (plus efficace que `cp`)
> - Transferts avec vérification d'intégrité
> - Besoin d'options avancées (exclusions, préservation d'attributs)
> - Reprises de transferts interrompus

### Copie distante via SSH

Lorsque source OU destination est sur une machine distante :

```bash
# Syntaxe générale SSH
rsync [OPTIONS] [USER@]HOST:SOURCE DESTINATION
rsync [OPTIONS] SOURCE [USER@]HOST:DESTINATION
```

#### Envoi vers serveur distant (PUSH)

```bash
# Envoi avec utilisateur spécifié
rsync -av /local/data/ user@server.com:/remote/backup/

# Envoi avec utilisateur courant
rsync -av /local/data/ server.com:/remote/backup/

# Envoi avec port SSH personnalisé
rsync -av -e "ssh -p 2222" /local/data/ user@server.com:/remote/backup/
```

#### Récupération depuis serveur distant (PULL)

```bash
# Récupération avec utilisateur spécifié
rsync -av user@server.com:/remote/data/ /local/backup/

# Récupération avec utilisateur courant
rsync -av server.com:/remote/data/ /local/backup/
```

> [!warning] Attention à la direction
> 
> ```bash
> # PUSH : envoie local → distant
> rsync local/ user@distant:/chemin/
> 
> # PULL : récupère distant → local
> rsync user@distant:/chemin/ local/
> ```

### Copie distante via rsync daemon

Syntaxe spécifique utilisant le protocole rsync natif :

```bash
# Syntaxe daemon (port 873 par défaut)
rsync [OPTIONS] SOURCE HOST::MODULE
rsync [OPTIONS] HOST::MODULE DESTINATION

# Exemples
rsync -av /local/data/ backup-server::backup-module
rsync -av backup-server::backup-module /local/restore/
```

> [!info] Différence SSH vs Daemon
> 
> - **SSH** : utilise le protocole SSH (port 22), plus sécurisé par défaut
> - **Daemon** : protocole rsync natif (port 873), nécessite configuration serveur

---

## Le slash final et son importance

### Règle fondamentale du slash final

Le slash final `/` sur la **SOURCE** change radicalement le comportement de rsync :

|Syntaxe|Comportement|Résultat|
|---|---|---|
|`rsync -a source/ dest/`|Copie le **contenu** de source|`dest/` contient les fichiers|
|`rsync -a source dest/`|Copie le **répertoire** source lui-même|`dest/source/` est créé|

> [!warning] Piège le plus courant avec rsync Le slash final est la source d'erreur n°1 avec rsync. Prenez toujours le temps de vérifier !

### Exemples détaillés

```bash
# Structure de départ
documents/
  ├── rapport.pdf
  ├── notes.txt
  └── images/
      └── photo.jpg
```

#### Avec slash final sur la source

```bash
rsync -a documents/ /backup/

# Résultat dans /backup/
/backup/
  ├── rapport.pdf
  ├── notes.txt
  └── images/
      └── photo.jpg
```

> [!tip] Avec slash = "Copie le contenu" Les fichiers de `documents/` se retrouvent **directement** dans `/backup/`

#### Sans slash final sur la source

```bash
rsync -a documents /backup/

# Résultat dans /backup/
/backup/
  └── documents/          # Le répertoire lui-même est copié
      ├── rapport.pdf
      ├── notes.txt
      └── images/
          └── photo.jpg
```

> [!tip] Sans slash = "Copie le répertoire" Le répertoire `documents/` est **créé** dans `/backup/`

### Cas pratiques comparatifs

```bash
# Scénario 1 : Sauvegarde d'un site web
# AVEC slash : met les fichiers directement dans /var/www/html/
rsync -av /home/dev/monsite/ /var/www/html/

# SANS slash : crée /var/www/html/monsite/
rsync -av /home/dev/monsite /var/www/html/
```

```bash
# Scénario 2 : Synchronisation de home utilisateur
# AVEC slash : les fichiers de john vont dans /backup/
rsync -av /home/john/ /backup/

# SANS slash : crée /backup/john/
rsync -av /home/john /backup/
```

> [!example] Quelle syntaxe choisir ? **Avec slash** (`source/`) : quand vous voulez fusionner/synchroniser le contenu
> 
> ```bash
> # Mettre à jour un répertoire existant
> rsync -av ~/Documents/ /backup/Documents/
> ```
> 
> **Sans slash** (`source`) : quand vous voulez copier le répertoire entier
> 
> ```bash
> # Créer une copie complète du répertoire
> rsync -av ~/Documents /backup/
> ```

### Impact sur la destination

> [!info] Le slash sur la destination Le slash final sur la **DESTINATION** a beaucoup moins d'impact :
> 
> - Avec slash : indique clairement que c'est un répertoire
> - Sans slash : rsync devine selon le contexte
> 
> **Bonne pratique** : toujours mettre un slash final sur les destinations qui sont des répertoires pour plus de clarté.

### Tableau récapitulatif complet

|Commande|Source existe|Dest existe|Résultat|
|---|---|---|---|
|`rsync src/ dst/`|Oui|Oui|Contenu de src dans dst|
|`rsync src/ dst/`|Oui|Non|dst créé avec contenu de src|
|`rsync src dst/`|Oui|Oui|dst/src créé avec contenu|
|`rsync src dst/`|Oui|Non|dst créé comme copie de src|

### Mnémotechnique

> [!tip] Astuce pour retenir **Le slash final dit "j'ouvre le répertoire"**
> 
> - `documents/` → "j'ouvre documents, prends ce qu'il y a dedans"
> - `documents` → "prends le répertoire documents en entier"
> 
> Pensez au slash comme une porte ouverte : `/` = porte ouverte = on rentre dedans

---

## 🎯 Points clés à retenir

> [!tip] Résumé des essentiels
> 
> 1. **Structure** : `rsync [OPTIONS] SOURCE DESTINATION`
> 2. **Ordre** : toujours SOURCE puis DESTINATION
> 3. **Local** : les deux chemins sur la même machine
> 4. **Distant SSH** : `user@host:/chemin` pour les transferts sécurisés
> 5. **Slash final** : `source/` copie le contenu, `source` copie le répertoire
> 6. **Bonne pratique** : toujours vérifier le slash final avant d'exécuter

---

## ⚠️ Pièges courants à éviter

> [!warning] Erreurs fréquentes
> 
> - Inverser source et destination → **perte de données**
> - Oublier le slash final → structure inattendue
> - Confondre PUSH et PULL avec SSH
> - Ne pas tester avec `--dry-run` avant une vraie synchro
> - Utiliser des chemins relatifs sans vérifier le répertoire courant

---

## 💡 Astuces pratiques

> [!tip] Conseils d'expert **Vérifiez toujours vos chemins**
> 
> ```bash
> # Affichez la destination avant de synchroniser
> ls -la /destination/
> 
> # Testez avec --dry-run (sera vu dans les options)
> rsync -avn source/ dest/  # n = dry-run
> ```
> 
> **Utilisez des chemins absolus pour les scripts**
> 
> ```bash
> # Préférez ceci dans vos scripts :
> rsync -av /home/user/data/ /backup/data/
> 
> # Plutôt que :
> rsync -av ~/data/ ../backup/data/
> ```
> 
> **Créez des alias pour vos synchros fréquentes**
> 
> ```bash
> # Dans ~/.bashrc
> alias sync-docs='rsync -av ~/Documents/ /backup/Documents/'
> alias sync-photos='rsync -av ~/Photos/ server:/backup/Photos/'
> ```