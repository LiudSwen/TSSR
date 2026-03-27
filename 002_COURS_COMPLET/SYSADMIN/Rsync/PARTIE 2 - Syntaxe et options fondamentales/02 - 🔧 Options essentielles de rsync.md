

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

Les options essentielles de rsync sont celles que vous utiliserez dans pratiquement toutes vos commandes. Elles constituent le socle de base pour effectuer des synchronisations efficaces et transparentes. Maîtriser ces options est fondamental pour exploiter correctement rsync.

> [!info] Philosophie de rsync
> rsync fonctionne avec un système d'options modulaires : vous activez uniquement ce dont vous avez besoin. Par défaut, rsync copie simplement les fichiers sans préserver leurs attributs ni afficher de détails.

---

## Option `-a` (archive)

### 📖 Description

L'option `-a` (ou `--archive`) est **l'option la plus importante** de rsync. Elle active un ensemble d'options qui permettent de préserver la structure complète des fichiers et répertoires.

> [!tip] Règle d'or
> Dans 90% des cas, vous utiliserez l'option `-a`. Elle garantit que la copie sera une réplique fidèle de la source.

### 🔍 Ce que `-a` active automatiquement

L'option `-a` est équivalente à `-rlptgoD`, ce qui active :

| Option | Signification | Fonction |
|--------|---------------|----------|
| `-r` | recursive | Parcourt les sous-répertoires |
| `-l` | links | Préserve les liens symboliques |
| `-p` | perms | Préserve les permissions |
| `-t` | times | Préserve les timestamps (dates de modification) |
| `-g` | group | Préserve le groupe propriétaire |
| `-o` | owner | Préserve le propriétaire (nécessite root) |
| `-D` | devices | Préserve les fichiers device et spéciaux |

### 💻 Syntaxe

```bash
# Synchronisation en mode archive
rsync -a /source/ /destination/

# Exemple concret
rsync -a /home/user/documents/ /backup/documents/
```

### ⚠️ Points d'attention

> [!warning] Permissions propriétaire avec -o
> L'option `-o` (incluse dans `-a`) ne fonctionne que si vous exécutez rsync en tant que root. En utilisateur normal, vous pouvez utiliser `-a` mais le propriétaire des fichiers copiés sera l'utilisateur qui exécute la commande.

```bash
# En tant qu'utilisateur normal
rsync -a /source/ /destination/
# ✓ Préserve tout SAUF le propriétaire

# En tant que root
sudo rsync -a /source/ /destination/
# ✓ Préserve TOUT, y compris le propriétaire
```

### 🎯 Quand utiliser `-a`

- ✅ Sauvegardes complètes
- ✅ Synchronisation de répertoires de travail
- ✅ Migration de données
- ✅ Réplication de systèmes de fichiers
- ❌ Copie simple où les métadonnées n'importent pas

---

## Option `-v` (verbose)

### 📖 Description

L'option `-v` (ou `--verbose`) affiche les détails de ce que rsync est en train de faire. Elle liste chaque fichier traité pendant la synchronisation.

> [!info] Niveaux de verbosité
> Vous pouvez augmenter le niveau de détails en utilisant plusieurs `-v` : `-vv` ou `-vvv` pour encore plus d'informations (utile pour le débogage).

### 💻 Syntaxe

```bash
# Synchronisation avec affichage des fichiers
rsync -av /source/ /destination/

# Verbosité accrue pour le débogage
rsync -avv /source/ /destination/
```

### 📊 Exemple de sortie

```bash
$ rsync -av /home/user/documents/ /backup/documents/

sending incremental file list
./
rapport.pdf
projet/
projet/notes.txt
projet/schema.png

sent 15,234 bytes  received 89 bytes  30,646.00 bytes/sec
total size is 2,456,789  speedup is 160.23
```

### 🎯 Quand utiliser `-v`

- ✅ Vérifier quels fichiers sont copiés
- ✅ Surveillance en temps réel des transferts
- ✅ Débogage de problèmes
- ✅ Logs pour traçabilité
- ❌ Scripts automatisés silencieux
- ❌ Très gros volumes (trop de sortie)

> [!tip] Combinaison intelligente
> Combinez `-v` avec `--progress` pour un suivi optimal lors de transferts manuels, mais utilisez uniquement `--stats` pour les scripts automatisés.

---

## Option `-z` (compression)

### 📖 Description

L'option `-z` (ou `--compress`) active la compression des données pendant le transfert. Les fichiers sont compressés avant l'envoi et décompressés à l'arrivée.

> [!info] Quand la compression est utile
> La compression est particulièrement bénéfique lors de transferts réseau, surtout avec des connexions lentes. En local, elle peut ralentir le transfert car le CPU devient le goulot d'étranglement.

### 💻 Syntaxe

```bash
# Synchronisation avec compression (transfert réseau)
rsync -avz /source/ user@serveur:/destination/

# En local, la compression est généralement inutile
rsync -av /source/ /destination/  # Pas de -z
```

### 📊 Gain de performance

L'efficacité de `-z` dépend du type de fichiers :

| Type de fichier | Gain de compression | Recommandation |
|-----------------|---------------------|----------------|
| Texte (.txt, .log, .csv) | 60-80% | ✅ Utilisez `-z` |
| Code source (.c, .py, .js) | 50-70% | ✅ Utilisez `-z` |
| Documents (.doc, .pdf) | 10-30% | ⚠️ Gain modéré |
| Images (.jpg, .png) | 0-5% | ❌ Déjà compressé |
| Vidéos (.mp4, .mkv) | 0-2% | ❌ Déjà compressé |
| Archives (.zip, .gz, .7z) | 0% | ❌ Déjà compressé |

### ⚡ Impact sur les performances

```bash
# Sans compression - Connexion 100 Mbps - Fichiers texte 1 GB
rsync -av /source/ user@serveur:/destination/
# Temps : ~80 secondes
# Bande passante utilisée : 1 GB

# Avec compression - Connexion 100 Mbps - Fichiers texte 1 GB
rsync -avz /source/ user@serveur:/destination/
# Temps : ~25 secondes (gain de 70%)
# Bande passante utilisée : ~300 MB
```

### 🎯 Quand utiliser `-z`

- ✅ Transferts sur connexion lente (ADSL, 4G)
- ✅ Transferts sur Internet longue distance
- ✅ Fichiers texte, logs, code source
- ❌ Transfert local (même machine)
- ❌ Réseau local rapide (Gigabit)
- ❌ Fichiers déjà compressés (images, vidéos, archives)

> [!warning] Surconsommation CPU
> Sur des machines peu puissantes, la compression peut ralentir significativement le transfert car le CPU passera plus de temps à compresser qu'à transférer.

---

## Option `-h` (human-readable)

### 📖 Description

L'option `-h` (ou `--human-readable`) affiche les tailles de fichiers dans un format lisible par l'humain (KB, MB, GB) au lieu d'octets bruts.

### 💻 Syntaxe

```bash
# Affichage lisible des tailles
rsync -avh /source/ /destination/

# Sans -h (sortie en octets)
rsync -av /source/ /destination/
```

### 📊 Comparaison de sortie

```bash
# Sans -h
sent 15234567 bytes  received 89 bytes  30646.00 bytes/sec
total size is 2456789123

# Avec -h
sent 15.23M bytes  received 89 bytes  30.65K/sec
total size is 2.46G
```

### 🎯 Quand utiliser `-h`

- ✅ Utilisation manuelle interactive
- ✅ Lecture rapide des statistiques
- ✅ Rapports destinés aux humains
- ❌ Scripts avec parsing automatique
- ❌ Logs destinés à être analysés par des outils

> [!tip] Bonne pratique
> Utilisez **toujours** `-h` lors d'utilisations manuelles. C'est devenu un standard et rend la sortie immédiatement compréhensible.

---

## Option `--progress`

### 📖 Description

L'option `--progress` affiche une barre de progression pour chaque fichier en cours de transfert. Elle indique le pourcentage, la vitesse de transfert et le temps estimé restant.

> [!info] Différence avec -v
> `-v` liste les fichiers traités, `--progress` affiche l'avancement en temps réel de CHAQUE fichier. Les deux sont complémentaires.

### 💻 Syntaxe

```bash
# Synchronisation avec barre de progression
rsync -av --progress /source/ /destination/

# Combinaison classique
rsync -avh --progress /source/ user@serveur:/destination/
```

### 📊 Exemple de sortie

```bash
$ rsync -av --progress /source/ /destination/

sending incremental file list
./
video.mp4
    1,258,291,200  52%  125.82MB/s    0:00:08
rapport.pdf
       45,678 100%   43.56KB/s    0:00:00
```

### 🔍 Détails affichés

| Information | Description |
|-------------|-------------|
| Nom du fichier | Fichier en cours de transfert |
| Octets transférés | Nombre d'octets déjà envoyés |
| Pourcentage | Progression du fichier actuel |
| Vitesse | Débit du transfert |
| Temps restant | Estimation pour ce fichier |

### 🎯 Quand utiliser `--progress`

- ✅ Transferts de gros fichiers
- ✅ Connexions lentes où l'attente est longue
- ✅ Surveillance manuelle en direct
- ✅ Vérifier que le transfert progresse
- ❌ Scripts automatisés (pollution des logs)
- ❌ Très nombreux petits fichiers (sortie trop chargée)

> [!tip] Alternative pour les scripts
> Pour les scripts, préférez `--stats` à la fin pour un résumé propre au lieu de `--progress` qui génère énormément de lignes.

```bash
# Pour surveillance manuelle
rsync -avh --progress /source/ /destination/

# Pour script automatisé
rsync -av --stats /source/ /destination/
```

---

## Combinaison des options

### 🎯 Combinaisons courantes et cas d'usage

#### 📦 Synchronisation locale standard

```bash
# Cas : Sauvegarde locale simple
rsync -av /home/user/documents/ /backup/documents/

# Explication :
# -a : Mode archive (préserve tout)
# -v : Affiche les fichiers copiés
```

#### 🌐 Synchronisation réseau

```bash
# Cas : Sauvegarde vers serveur distant
rsync -avzh --progress /home/user/data/ user@backup-server:/backups/data/

# Explication :
# -a : Mode archive
# -v : Verbose pour traçabilité
# -z : Compression (transfert réseau)
# -h : Tailles lisibles
# --progress : Suivi en temps réel
```

#### 🔄 Synchronisation incrémentale quotidienne

```bash
# Cas : Script de sauvegarde automatique
rsync -az --stats /var/www/ user@backup:/backups/www/

# Explication :
# -a : Mode archive
# -z : Compression
# --stats : Résumé final (pas de --progress dans un script)
# Pas de -v pour éviter de polluer les logs
```

#### 💾 Transfert local rapide

```bash
# Cas : Copie rapide sur disque local
rsync -avh --progress /media/usb/photos/ /home/user/photos/

# Explication :
# -a : Mode archive
# -v : Liste les fichiers
# -h : Tailles lisibles
# --progress : Suivi visuel
# Pas de -z (inutile en local)
```

### 📋 Tableau récapitulatif des combinaisons

| Scénario | Options recommandées | Justification |
|----------|----------------------|---------------|
| Sauvegarde locale | `-av` | Simple et efficace |
| Sauvegarde distante | `-avz` | Compression pour réseau |
| Usage manuel | `-avh --progress` | Maximum de visibilité |
| Script automatisé | `-a --stats` | Propre et informatif |
| Gros fichiers réseau | `-avzh --progress` | Suivi et compression |
| Migration système | `-aAXv` | Préserve ACL et attributs étendus |

> [!example] Exemple complet commenté
> ```bash
> # Sauvegarde quotidienne d'un serveur web
> rsync -avzh \
>   --stats \
>   --exclude='*.log' \
>   --exclude='cache/' \
>   /var/www/production/ \
>   backup-user@backup-server:/backups/www/$(date +%Y-%m-%d)/
> 
> # -a : Archive complète
> # -v : Logs détaillés
> # -z : Compression (transfert réseau)
> # -h : Lisibilité des tailles
> # --stats : Résumé final
> # --exclude : Ignore les logs et cache
> ```

### ⚡ Astuces de performance

> [!tip] Optimisation selon le contexte
> - **Réseau lent** : Ajoutez `-z` et éventuellement `--bwlimit`
> - **CPU faible** : Évitez `-z` même sur réseau
> - **Nombreux petits fichiers** : Évitez `--progress`, utilisez seulement `-v`
> - **Gros fichiers** : `--progress` est idéal
> - **Scripts** : Minimaliste `-a` + `--stats`, sans `-v` ni `--progress`

### 🎓 Mémorisation facile

Pour retenir les options essentielles, pensez au mnémonique **"AVZHP"** :

- **A**rchive : `-a` (toujours)
- **V**erbose : `-v` (souvent)
- **Z**ip/Compression : `-z` (si réseau)
- **H**uman : `-h` (pour lisibilité)
- **P**rogress : `--progress` (si manuel)

---

> [!warning] Pièges courants
> - ❌ Oublier `-a` et perdre les permissions/timestamps
> - ❌ Utiliser `-z` en local (ralentit inutilement)
> - ❌ Utiliser `--progress` dans les scripts cron (pollue les logs)
> - ❌ Oublier `-h` et avoir des tailles illisibles
> - ✅ Toujours commencer avec `-av` comme base
> - ✅ Ajouter `-z` uniquement pour les transferts réseau
> - ✅ Ajouter `-h --progress` pour l'utilisation interactive