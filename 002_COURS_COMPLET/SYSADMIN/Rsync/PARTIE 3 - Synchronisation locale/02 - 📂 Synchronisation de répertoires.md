

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

La synchronisation de répertoires avec `rsync` va bien au-delà d'une simple copie. Elle permet de maintenir deux arborescences identiques de manière efficace, en transférant uniquement ce qui a changé. C'est l'une des fonctionnalités les plus puissantes de rsync.

> [!info] Différence copie vs synchronisation
> - **Copie** : transfert unidirectionnel de fichiers
> - **Synchronisation** : maintien de deux répertoires dans le même état, avec gestion intelligente des différences

---

## Synchronisation complète

### 🎯 Qu'est-ce qu'une synchronisation complète ?

Une synchronisation complète consiste à rendre la destination identique à la source en copiant tous les fichiers nécessaires, tout en préservant la structure et les attributs.

### Syntaxe de base

```bash
# Synchronisation complète avec l'option archive
rsync -av /source/ /destination/

# Avec affichage de la progression
rsync -avh --progress /source/ /destination/
```

> [!warning] Importance du slash final
> - `rsync -av /source/ /destination/` → copie le **contenu** de source dans destination
> - `rsync -av /source /destination/` → copie le **répertoire** source dans destination
> 
> Résultat différent :
> - Avec slash : `/destination/fichier1`, `/destination/fichier2`
> - Sans slash : `/destination/source/fichier1`, `/destination/source/fichier2`

### Exemple détaillé

```bash
# Structure initiale
# /var/data/
# ├── projet1/
# │   ├── app.py
# │   └── config.ini
# └── projet2/
#     └── readme.md

# Synchronisation complète
rsync -av /var/data/ /backup/data/

# Résultat dans /backup/data/
# ├── projet1/
# │   ├── app.py
# │   └── config.ini
# └── projet2/
#     └── readme.md
```

### Options complémentaires utiles

```bash
# Synchronisation avec statistiques détaillées
rsync -avh --stats /source/ /destination/

# Avec affichage du temps estimé
rsync -avh --progress --stats /source/ /destination/

# En mode verbeux pour debugging
rsync -avvh /source/ /destination/
```

> [!tip] Option -a décortiquée
> L'option `-a` (archive) est équivalente à `-rlptgoD` :
> - `-r` : récursif
> - `-l` : copie les liens symboliques
> - `-p` : préserve les permissions
> - `-t` : préserve les timestamps
> - `-g` : préserve le groupe
> - `-o` : préserve le propriétaire
> - `-D` : préserve les fichiers spéciaux

---

## Synchronisation incrémentale

### 🎯 Principe de l'incrémental

La synchronisation incrémentale est le cœur de la puissance de rsync : seuls les fichiers modifiés ou nouveaux sont transférés. C'est automatique et transparent.

### Comment rsync détecte les changements ?

Par défaut, rsync compare :
1. **La taille du fichier**
2. **La date de modification (mtime)**

```bash
# Synchronisation incrémentale standard
rsync -av /source/ /destination/

# Première exécution : copie tout (100 Mo)
# Deuxième exécution : copie uniquement les changements (quelques Ko)
```

### Algorithme de différence

> [!info] Fonctionnement interne
> Rsync utilise un algorithme de différence par blocs :
> 1. Découpe les fichiers en blocs
> 2. Calcule des checksums pour chaque bloc
> 3. Compare les checksums
> 4. Transfère uniquement les blocs modifiés

```bash
# Forcer la vérification par checksum (plus lent mais plus sûr)
rsync -avc /source/ /destination/
# -c : compare par checksum plutôt que par taille/date
```

### Exemple pratique

```bash
# Jour 1 : Synchronisation initiale (1000 fichiers, 5 Go)
rsync -avh --stats /home/user/documents/ /backup/documents/
# Total transferré : 5 Go

# Jour 2 : Modification de 3 fichiers
rsync -avh --stats /home/user/documents/ /backup/documents/
# Total transferré : 15 Mo (uniquement les fichiers modifiés)

# Jour 3 : Ajout de 2 nouveaux fichiers
rsync -avh --stats /home/user/documents/ /backup/documents/
# Total transferré : 8 Mo (uniquement les nouveaux fichiers)
```

> [!tip] Gain de temps et de bande passante
> Sur une synchronisation quotidienne, l'incrémental réduit typiquement le temps de transfert de 90-95% après la première copie complète.

### Options pour contrôler la détection

```bash
# Ignorer la date de modification, comparer uniquement la taille
rsync -av --size-only /source/ /destination/

# Forcer le checksum pour plus de précision
rsync -avc /source/ /destination/

# Mettre à jour uniquement les fichiers plus récents
rsync -avu /source/ /destination/
# -u : skip files that are newer on the destination
```

---

## Gestion du contenu existant

### 🎯 Comportement avec fichiers existants

Comprendre comment rsync gère les fichiers déjà présents dans la destination est crucial pour éviter les surprises.

### Cas de figure

| Situation | Comportement de rsync | Option à utiliser |
|-----------|----------------------|-------------------|
| Fichier identique | Ignoré (pas de transfert) | `-a` |
| Fichier modifié à la source | Écrasé dans destination | `-a` |
| Fichier plus récent à destination | Écrasé par défaut | `-au` pour garder le plus récent |
| Fichier existe seulement à destination | Conservé par défaut | `--delete` pour supprimer |
| Conflit de nom (fichier vs répertoire) | Erreur | Correction manuelle |

### Exemples détaillés

```bash
# Scénario 1 : Préserver les fichiers plus récents dans destination
rsync -avu /source/ /destination/
# -u : update only (ne remplace pas si destination plus récente)

# Scénario 2 : Forcer l'écrasement même si destination plus récente
rsync -av /source/ /destination/
# Comportement par défaut : écrase tout

# Scénario 3 : Mode simulation pour voir ce qui serait modifié
rsync -avn --delete /source/ /destination/
# -n : dry-run, simule sans rien modifier
```

> [!example] Cas pratique : fichiers de configuration
> ```bash
> # Vous avez modifié un fichier de config en production
> # Vous voulez synchroniser depuis votre source sans l'écraser
> 
> rsync -avu /source/config/ /production/config/
> # Les fichiers modifiés en production ne seront pas écrasés
> ```

### Gestion des conflits

```bash
# Sauvegarder les fichiers écrasés dans un répertoire de backup
rsync -avb --backup-dir=/backup/$(date +%Y%m%d) /source/ /destination/
# -b : créé des backups des fichiers écrasés

# Utiliser un suffixe pour les backups
rsync -av --suffix=.backup /source/ /destination/
# Les fichiers écrasés sont renommés avec .backup
```

> [!warning] Attention aux répertoires existants
> Si `/destination/dossier/` existe déjà, rsync **fusionne** le contenu au lieu de remplacer le répertoire entier. Les fichiers existants dans destination mais absents de source sont conservés (sauf avec `--delete`).

---

## Utilisation de --delete

### 🎯 Objectif de --delete

L'option `--delete` transforme rsync en véritable outil de **miroir** : la destination devient une copie exacte de la source, y compris les suppressions.

### Comportement sans --delete

```bash
# Structure source
/source/
├── fichier1.txt
└── fichier2.txt

# Structure destination (contient un fichier supplémentaire)
/destination/
├── fichier1.txt
├── fichier2.txt
└── ancien_fichier.txt

# Synchronisation standard
rsync -av /source/ /destination/

# Résultat : ancien_fichier.txt reste dans destination
/destination/
├── fichier1.txt
├── fichier2.txt
└── ancien_fichier.txt  # ← toujours présent !
```

### Comportement avec --delete

```bash
# Même situation, mais avec --delete
rsync -av --delete /source/ /destination/

# Résultat : ancien_fichier.txt est supprimé
/destination/
├── fichier1.txt
└── fichier2.txt
```

> [!warning] Danger potentiel
> `--delete` supprime **définitivement** les fichiers de destination absents de la source. Toujours tester avec `--dry-run` d'abord !

### Variantes de --delete

```bash
# --delete-before : supprime avant le transfert (défaut)
rsync -av --delete-before /source/ /destination/

# --delete-after : supprime après le transfert (plus sûr)
rsync -av --delete-after /source/ /destination/

# --delete-during : supprime pendant le transfert (plus rapide)
rsync -av --delete-during /source/ /destination/

# --delete-excluded : supprime aussi les fichiers exclus
rsync -av --delete --delete-excluded --exclude='*.tmp' /source/ /destination/
```

### Exemples pratiques

```bash
# Miroir exact pour sauvegarde
rsync -avh --delete --stats /home/user/important/ /backup/important/

# Test avant exécution réelle
rsync -avn --delete /source/ /destination/
# Vérifiez la liste "deleting" dans la sortie

# Miroir avec exclusions
rsync -avh --delete --exclude='cache/' --exclude='*.log' /app/ /backup/app/
```

> [!tip] Protection contre les suppressions accidentelles
> ```bash
> # Créer un backup des fichiers qui seront supprimés
> rsync -avh --delete \
>   --backup --backup-dir=/backup/deleted/$(date +%Y%m%d_%H%M%S) \
>   /source/ /destination/
> ```

### Cas d'usage typiques

| Scénario | Commande recommandée |
|----------|---------------------|
| Sauvegarde de sécurité | `rsync -av` (sans --delete) |
| Miroir exact | `rsync -av --delete` |
| Déploiement web | `rsync -av --delete --exclude='.git'` |
| Synchronisation bidirectionnelle | Utiliser un outil spécialisé (rsync unidirectionnel) |

> [!example] Déploiement d'un site web
> ```bash
> # Déployer en supprimant les anciens fichiers
> rsync -avz --delete \
>   --exclude='.git' \
>   --exclude='node_modules' \
>   --exclude='config.local.php' \
>   /local/website/ user@server:/var/www/html/
> ```

---

## Pièges courants

### 🚨 Erreurs fréquentes

> [!warning] Piège #1 : Oublier le slash final
> ```bash
> # FAUX : crée /backup/data/data/
> rsync -av /var/data /backup/data/
> 
> # CORRECT : copie le contenu dans /backup/data/
> rsync -av /var/data/ /backup/data/
> ```

> [!warning] Piège #2 : Utiliser --delete sans test
> ```bash
> # DANGEREUX : suppression sans vérification
> rsync -av --delete /source/ /destination/
> 
> # SÉCURISÉ : toujours tester d'abord
> rsync -avn --delete /source/ /destination/
> # Vérifier la sortie, puis relancer sans -n
> ```

> [!warning] Piège #3 : Synchronisation bidirectionnelle
> ```bash
> # NE FONCTIONNE PAS : rsync est unidirectionnel !
> rsync -av --delete /dossier1/ /dossier2/
> rsync -av --delete /dossier2/ /dossier1/
> # Risque de perte de données
> ```

> [!warning] Piège #4 : Permissions insuffisantes
> ```bash
> # Erreur silencieuse si pas les droits
> rsync -av /source/ /destination/
> 
> # Solution : vérifier les permissions ou utiliser sudo
> sudo rsync -av /source/ /destination/
> ```

> [!warning] Piège #5 : Espace disque insuffisant
> ```bash
> # rsync peut échouer en milieu de transfert
> # Toujours vérifier l'espace disponible avant
> 
> df -h /destination/
> rsync -avh --stats /source/ /destination/
> ```

### Confusion source/destination

```bash
# ATTENTION à l'ordre !

# Push : local → distant
rsync -av /local/data/ user@server:/remote/data/

# Pull : distant → local
rsync -av user@server:/remote/data/ /local/data/

# Inverser = désastre potentiel avec --delete !
```

---

## Bonnes pratiques

### ✅ Recommandations essentielles

> [!tip] Toujours tester avec --dry-run
> ```bash
> # 1. Test avec dry-run
> rsync -avn --delete /source/ /destination/
> 
> # 2. Vérifier la sortie
> # 3. Exécuter pour de vrai
> rsync -av --delete /source/ /destination/
> ```

> [!tip] Utiliser --stats pour le suivi
> ```bash
> rsync -avh --stats --delete /source/ /destination/
> # Donne des métriques précieuses sur le transfert
> ```

> [!tip] Logger les synchronisations
> ```bash
> # Rediriger vers un fichier de log
> rsync -avh --delete /source/ /destination/ \
>   >> /var/log/rsync/backup_$(date +%Y%m%d).log 2>&1
> ```

> [!tip] Créer des alias pour commandes fréquentes
> ```bash
> # Dans ~/.bashrc
> alias rsync-mirror='rsync -avh --delete --stats'
> alias rsync-backup='rsync -avh --stats'
> 
> # Utilisation
> rsync-mirror /source/ /destination/
> ```

### Workflow recommandé

```bash
# Étape 1 : Vérifier l'espace disque
df -h /destination/

# Étape 2 : Test dry-run
rsync -avn --delete /source/ /destination/ | tee test.log

# Étape 3 : Révision du test
grep "deleting" test.log
grep "sending" test.log

# Étape 4 : Exécution avec logging
rsync -avh --delete --stats /source/ /destination/ \
  2>&1 | tee /var/log/rsync/sync_$(date +%Y%m%d_%H%M%S).log

# Étape 5 : Vérification post-synchronisation
echo "Sync completed at $(date)" >> /var/log/rsync/history.log
```

### Organisation des synchronisations

```bash
# Structure de répertoires recommandée
/backup/
├── daily/          # Synchronisations quotidiennes
├── weekly/         # Synchronisations hebdomadaires
├── logs/           # Fichiers de log
└── scripts/        # Scripts de synchronisation

# Script type
#!/bin/bash
SOURCE="/var/data/"
DEST="/backup/daily/data/"
LOG="/backup/logs/sync_$(date +%Y%m%d).log"

echo "Starting sync at $(date)" | tee -a "$LOG"
rsync -avh --delete --stats "$SOURCE" "$DEST" 2>&1 | tee -a "$LOG"
echo "Sync completed at $(date)" | tee -a "$LOG"
```

### Astuces de performance

> [!tip] Optimiser les grosses synchronisations
> ```bash
> # Utiliser la compression pour transferts distants
> rsync -avhz --delete /source/ user@server:/destination/
> 
> # Limiter la bande passante (en Ko/s)
> rsync -avh --delete --bwlimit=5000 /source/ /destination/
> 
> # Afficher la progression pour longues opérations
> rsync -avh --delete --progress /source/ /destination/
> ```

---

## 🎯 Points clés à retenir

- **Synchronisation complète** = rendre destination identique à source
- **Synchronisation incrémentale** = automatique, transfère uniquement les changements
- **Sans --delete** = fichiers en destination sont conservés même si absents de source
- **Avec --delete** = miroir exact, supprime ce qui n'existe pas dans source
- **Toujours tester** avec `-n` (dry-run) avant d'utiliser `--delete`
- **Slash final** crucial : avec slash = contenu, sans slash = répertoire entier
- **rsync est unidirectionnel** : ne l'utilisez pas pour de la synchronisation bidirectionnelle