

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

## ⏰ Planification avec cron

### 🎯 Pourquoi automatiser les sauvegardes ?

L'automatisation des sauvegardes est **cruciale** pour garantir la cohérence et la fiabilité. Les sauvegardes manuelles sont souvent oubliées ou négligées. Avec cron, vous programmez vos sauvegardes pour qu'elles s'exécutent automatiquement, même la nuit ou pendant les week-ends.

> [!info] Qu'est-ce que cron ? **Cron** est le planificateur de tâches intégré à Linux. Il permet d'exécuter des commandes ou des scripts à des intervalles réguliers (horaire, quotidien, hebdomadaire, mensuel).

### 📝 Syntaxe de cron

Les tâches cron sont définies dans la **crontab** (table cron) avec la syntaxe suivante :

```bash
┌───────────── minute (0 - 59)
│ ┌───────────── heure (0 - 23)
│ │ ┌───────────── jour du mois (1 - 31)
│ │ │ ┌───────────── mois (1 - 12)
│ │ │ │ ┌───────────── jour de la semaine (0 - 7, 0 et 7 = dimanche)
│ │ │ │ │
* * * * * commande_à_exécuter
```

> [!example] Exemples de planification
> 
> ```bash
> # Tous les jours à 2h du matin
> 0 2 * * * /chemin/vers/script_sauvegarde.sh
> 
> # Tous les lundis à 3h30
> 30 3 * * 1 /usr/local/bin/backup.sh
> 
> # Le 1er de chaque mois à minuit
> 0 0 1 * * /root/backup_mensuel.sh
> 
> # Toutes les 6 heures
> 0 */6 * * * /opt/backup/incremental.sh
> 
> # Du lundi au vendredi à 23h
> 0 23 * * 1-5 /home/admin/backup_semaine.sh
> ```

### 🛠️ Gestion de la crontab

#### Éditer sa crontab

```bash
# Ouvrir l'éditeur de crontab pour l'utilisateur courant
crontab -e

# Éditer la crontab d'un autre utilisateur (root uniquement)
crontab -e -u username
```

#### Lister les tâches planifiées

```bash
# Afficher votre crontab
crontab -l

# Afficher la crontab d'un utilisateur spécifique
crontab -l -u username
```

#### Supprimer la crontab

```bash
# Supprimer toute votre crontab (avec confirmation)
crontab -r

# Supprimer sans confirmation
crontab -r -i
```

### 📍 Emplacement des fichiers crontab système

|Emplacement|Usage|
|---|---|
|`/etc/crontab`|Crontab système principal|
|`/etc/cron.d/`|Répertoire pour des fichiers crontab multiples|
|`/etc/cron.daily/`|Scripts exécutés quotidiennement|
|`/etc/cron.hourly/`|Scripts exécutés toutes les heures|
|`/etc/cron.weekly/`|Scripts exécutés hebdomadairement|
|`/etc/cron.monthly/`|Scripts exécutés mensuellement|

> [!tip] Astuce : Utiliser les répertoires système Pour des sauvegardes simples, placez votre script dans `/etc/cron.daily/` plutôt que d'éditer la crontab. Assurez-vous que le script est exécutable (`chmod +x`) et n'a pas d'extension (.sh).

### ⚠️ Pièges courants avec cron

> [!warning] Variables d'environnement limitées Cron exécute les tâches avec un environnement minimal. Le PATH est très restreint (généralement `/usr/bin:/bin`). Utilisez toujours des **chemins absolus** dans vos scripts.
> 
> ```bash
> # ❌ Mauvais - commande peut ne pas être trouvée
> 0 2 * * * tar -czf backup.tar.gz /data
> 
> # ✅ Bon - chemin absolu
> 0 2 * * * /bin/tar -czf /backups/backup.tar.gz /data
> ```

> [!warning] Gestion des sorties Par défaut, cron envoie les sorties (stdout et stderr) par email à l'utilisateur. Si le mail n'est pas configuré, les erreurs sont silencieuses.
> 
> ```bash
> # Rediriger vers un fichier de log
> 0 2 * * * /root/backup.sh >> /var/log/backup.log 2>&1
> 
> # Ignorer toutes les sorties (déconseillé)
> 0 2 * * * /root/backup.sh > /dev/null 2>&1
> ```

### 🔐 Bonnes pratiques de planification

1. **Choisir les bonnes heures** : Planifiez les sauvegardes pendant les heures creuses (nuit, week-end)
2. **Éviter les conflits** : Ne planifiez pas toutes les sauvegardes à la même heure
3. **Tester manuellement** : Exécutez votre script manuellement avant de le mettre dans cron
4. **Logger les opérations** : Conservez une trace de chaque exécution
5. **Utiliser des verrous** : Empêchez les exécutions simultanées avec `flock`

> [!example] Exemple avec verrou
> 
> ```bash
> # Empêche l'exécution si la sauvegarde précédente n'est pas terminée
> 0 2 * * * /usr/bin/flock -n /var/lock/backup.lock /root/backup.sh
> ```

---

## 📜 Scripts de sauvegarde simples

### 🎯 Pourquoi créer des scripts ?

Un script de sauvegarde permet de :

- Automatiser des tâches complexes en une seule commande
- Ajouter de la logique (conditions, boucles, notifications)
- Gérer la rotation des sauvegardes anciennes
- Logger les opérations pour le débogage
- Standardiser les processus de sauvegarde

### 🏗️ Structure d'un bon script de sauvegarde

```bash
#!/bin/bash

# ============================================
# Script de sauvegarde quotidienne
# ============================================

# 1. Définition des variables
BACKUP_DIR="/backups"
SOURCE_DIR="/var/www"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="backup_${DATE}.tar.gz"
LOG_FILE="/var/log/backup.log"
RETENTION_DAYS=7

# 2. Fonction de logging
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# 3. Vérifications préliminaires
if [ ! -d "$BACKUP_DIR" ]; then
    log_message "ERREUR : Le répertoire $BACKUP_DIR n'existe pas"
    exit 1
fi

if [ ! -d "$SOURCE_DIR" ]; then
    log_message "ERREUR : Le répertoire source $SOURCE_DIR n'existe pas"
    exit 1
fi

# 4. Début de la sauvegarde
log_message "Début de la sauvegarde de $SOURCE_DIR"

# 5. Création de l'archive
tar -czf "${BACKUP_DIR}/${BACKUP_FILE}" "$SOURCE_DIR" 2>> "$LOG_FILE"

# 6. Vérification du succès
if [ $? -eq 0 ]; then
    BACKUP_SIZE=$(du -h "${BACKUP_DIR}/${BACKUP_FILE}" | cut -f1)
    log_message "Sauvegarde réussie : ${BACKUP_FILE} (${BACKUP_SIZE})"
else
    log_message "ERREUR : Échec de la sauvegarde"
    exit 1
fi

# 7. Rotation des anciennes sauvegardes
log_message "Suppression des sauvegardes de plus de ${RETENTION_DAYS} jours"
find "$BACKUP_DIR" -name "backup_*.tar.gz" -mtime +${RETENTION_DAYS} -delete

# 8. Fin
log_message "Sauvegarde terminée avec succès"
```

### 🔍 Détails du script

#### Variables essentielles

> [!info] Variables de chemins et dates
> 
> - **BACKUP_DIR** : Où stocker les sauvegardes
> - **SOURCE_DIR** : Ce qu'on sauvegarde
> - **DATE** : Horodatage pour nommer les fichiers de manière unique
> - **LOG_FILE** : Fichier de journalisation

#### Fonction de logging

La fonction `log_message()` standardise les messages de log :

- Ajoute un timestamp automatique
- Écrit dans le fichier de log
- Affiche aussi à l'écran avec `tee -a`

#### Code de retour ($?)

```bash
if [ $? -eq 0 ]; then
```

`$?` contient le code de retour de la dernière commande :

- **0** = succès
- **Non-zéro** = erreur

### 🚀 Script avancé avec notifications

```bash
#!/bin/bash

# ============================================
# Script de sauvegarde avec notifications
# ============================================

BACKUP_DIR="/backups"
SOURCE_DIRS=("/var/www" "/etc" "/home")
DATE=$(date +%Y%m%d_%H%M%S)
LOG_FILE="/var/log/backup.log"
RETENTION_DAYS=7
EMAIL="admin@example.com"

# Fonction de logging
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Fonction de notification par email
send_notification() {
    local subject="$1"
    local message="$2"
    echo "$message" | mail -s "$subject" "$EMAIL"
}

# Début
log_message "=== Début de la sauvegarde ==="
ERRORS=0

# Boucle sur chaque répertoire à sauvegarder
for SOURCE_DIR in "${SOURCE_DIRS[@]}"; do
    DIR_NAME=$(basename "$SOURCE_DIR")
    BACKUP_FILE="${DIR_NAME}_${DATE}.tar.gz"
    
    log_message "Sauvegarde de $SOURCE_DIR..."
    
    # Création de l'archive
    tar -czf "${BACKUP_DIR}/${BACKUP_FILE}" "$SOURCE_DIR" 2>> "$LOG_FILE"
    
    if [ $? -eq 0 ]; then
        SIZE=$(du -h "${BACKUP_DIR}/${BACKUP_FILE}" | cut -f1)
        log_message "✓ ${BACKUP_FILE} créé avec succès (${SIZE})"
    else
        log_message "✗ ERREUR lors de la sauvegarde de $SOURCE_DIR"
        ERRORS=$((ERRORS + 1))
    fi
done

# Rotation des sauvegardes
log_message "Rotation des anciennes sauvegardes..."
DELETED=$(find "$BACKUP_DIR" -name "*.tar.gz" -mtime +${RETENTION_DAYS} -delete -print | wc -l)
log_message "Supprimé : $DELETED ancienne(s) sauvegarde(s)"

# Résumé et notification
if [ $ERRORS -eq 0 ]; then
    log_message "=== Sauvegarde terminée avec succès ==="
    send_notification "Sauvegarde réussie" "Toutes les sauvegardes ont été créées avec succès."
else
    log_message "=== Sauvegarde terminée avec $ERRORS erreur(s) ==="
    send_notification "Sauvegarde avec erreurs" "La sauvegarde s'est terminée avec $ERRORS erreur(s). Consultez $LOG_FILE"
    exit 1
fi
```

### 🛡️ Sécurisation du script

> [!warning] Permissions importantes
> 
> ```bash
> # Le script doit être exécutable uniquement par root
> chmod 700 /root/backup.sh
> chown root:root /root/backup.sh
> 
> # Le répertoire de sauvegarde doit être protégé
> chmod 700 /backups
> ```

### ✨ Améliorations possibles

> [!tip] Fonctionnalités avancées
> 
> - **Compression différenciée** : Utiliser `gzip -9` pour une compression maximale
> - **Sauvegardes incrémentielles** : Sauvegarder uniquement les modifications
> - **Chiffrement** : Ajouter `gpg` pour chiffrer les archives
> - **Sauvegarde distante** : Utiliser `rsync` ou `scp` pour copier ailleurs
> - **Vérification d'intégrité** : Calculer un checksum MD5/SHA256

---

## 📦 Extraction d'archives tar

### 🎯 Pourquoi bien maîtriser l'extraction ?

L'extraction est l'étape critique de la **restauration**. Une mauvaise extraction peut :

- Écraser des fichiers importants
- Restaurer au mauvais endroit
- Causer des problèmes de permissions

### 🔓 Syntaxe de base d'extraction

```bash
# Extraire une archive tar simple
tar -xf archive.tar

# Extraire une archive tar.gz
tar -xzf archive.tar.gz

# Extraire une archive tar.bz2
tar -xjf archive.tar.bz2

# Extraire une archive tar.xz
tar -xJf archive.tar.xz
```

|Option|Signification|
|---|---|
|`-x`|**Extract** - Mode extraction|
|`-f`|**File** - Spécifie le fichier archive|
|`-z`|Décompression **gzip**|
|`-j`|Décompression **bzip2**|
|`-J`|Décompression **xz**|
|`-v`|**Verbose** - Affiche les fichiers extraits|

> [!tip] Détection automatique de compression Les versions récentes de tar détectent automatiquement le type de compression :
> 
> ```bash
> # Fonctionne pour .tar.gz, .tar.bz2, .tar.xz automatiquement
> tar -xf archive.tar.gz
> ```

### 📍 Contrôler le répertoire de destination

#### Extraire dans le répertoire courant

```bash
# Par défaut, extraction dans le répertoire courant
tar -xzf /backups/backup.tar.gz
```

#### Extraire dans un répertoire spécifique

```bash
# Option -C pour changer de répertoire avant l'extraction
tar -xzf /backups/backup.tar.gz -C /tmp/restore/

# Créer le répertoire s'il n'existe pas
mkdir -p /tmp/restore
tar -xzf /backups/backup.tar.gz -C /tmp/restore/
```

> [!warning] Attention à la structure de l'archive Avant d'extraire, vérifiez la structure interne de l'archive pour éviter de polluer le répertoire courant :
> 
> ```bash
> # Lister le contenu sans extraire
> tar -tzf archive.tar.gz | head -20
> 
> # Si l'archive ne contient pas de répertoire racine,
> # créez-en un pour l'extraction
> mkdir restore_temp
> tar -xzf archive.tar.gz -C restore_temp/
> ```

### 🎯 Extraction sélective

#### Extraire un fichier spécifique

```bash
# Extraire uniquement config.php de l'archive
tar -xzf backup.tar.gz var/www/config.php

# Avec affichage
tar -xzvf backup.tar.gz var/www/config.php
```

#### Extraire un répertoire spécifique

```bash
# Extraire uniquement le répertoire /etc
tar -xzf backup.tar.gz etc/

# Extraire plusieurs éléments
tar -xzf backup.tar.gz etc/ var/www/ home/user/
```

#### Utiliser des wildcards

```bash
# Extraire tous les fichiers .conf
tar -xzf backup.tar.gz --wildcards '*.conf'

# Extraire tous les fichiers PHP d'un répertoire
tar -xzf backup.tar.gz --wildcards 'var/www/*.php'
```

> [!example] Exemple pratique de restauration sélective
> 
> ```bash
> # Scénario : Restaurer uniquement la base de données
> tar -xzf backup_complet.tar.gz var/lib/mysql/ma_base/
> 
> # Scénario : Restaurer la configuration Apache
> tar -xzf backup.tar.gz etc/apache2/
> ```

### 🔄 Options avancées d'extraction

#### Préserver les permissions et propriétaires

```bash
# Préserver les permissions (par défaut pour root)
tar -xzpf backup.tar.gz

# Option -p / --preserve-permissions
# Utile si vous n'êtes pas root mais voulez essayer de préserver
```

#### Gérer les chemins absolus

```bash
# Par défaut, tar retire le / initial des chemins absolus pour la sécurité
# Pour forcer l'extraction avec chemins absolus (DANGEREUX)
tar -xzf backup.tar.gz --absolute-names

# Mieux : utiliser --strip-components pour retirer des niveaux
tar -xzf backup.tar.gz --strip-components=2
# Retire les 2 premiers niveaux de répertoire
```

> [!warning] Danger des chemins absolus L'option `--absolute-names` peut écraser des fichiers système si l'archive contient des chemins comme `/etc/passwd`. Utilisez-la avec précaution !

#### Extraction avec remplacement conditionnel

```bash
# Ne pas écraser les fichiers existants
tar -xzf backup.tar.gz --keep-old-files

# Mettre à jour uniquement les fichiers plus anciens
tar -xzf backup.tar.gz --keep-newer-files

# Demander confirmation pour chaque fichier
tar -xzf backup.tar.gz --interactive
```

### 🔍 Résolution de problèmes d'extraction

> [!warning] Erreurs courantes
> 
> **"Cannot open: No such file or directory"**
> 
> ```bash
> # Vérifier que l'archive existe
> ls -lh /backups/backup.tar.gz
> 
> # Vérifier les permissions
> file /backups/backup.tar.gz
> ```
> 
> **"gzip: stdin: not in gzip format"**
> 
> ```bash
> # L'archive n'est pas compressée ou mal compressée
> # Vérifier le type réel
> file backup.tar.gz
> 
> # Essayer sans décompression gzip
> tar -xf backup.tar.gz
> ```
> 
> **"Exiting with failure status due to previous errors"**
> 
> ```bash
> # Extraire en mode verbeux pour voir où ça bloque
> tar -xzvf backup.tar.gz
> 
> # Ignorer les erreurs mineures et continuer
> tar -xzf backup.tar.gz --ignore-failed-read
> ```

---

## ✅ Vérification d'archives

### 🎯 Pourquoi vérifier les archives ?

La vérification est une étape **essentielle** et souvent négligée :

- Détecte les archives corrompues **avant** d'en avoir besoin
- Confirme que tous les fichiers ont été inclus
- Évite les mauvaises surprises lors d'une restauration d'urgence

> [!warning] Règle d'or **Une sauvegarde non testée n'est pas une sauvegarde !**
> 
> De nombreuses organisations découvrent que leurs sauvegardes sont inutilisables au moment critique de la restauration.

### 📋 Lister le contenu d'une archive

```bash
# Lister le contenu d'une archive tar
tar -tf archive.tar

# Lister le contenu d'une archive tar.gz
tar -tzf archive.tar.gz

# Lister avec détails (taille, permissions, date)
tar -tvzf archive.tar.gz

# Lister uniquement les premiers fichiers
tar -tzf archive.tar.gz | head -20

# Compter le nombre de fichiers
tar -tzf archive.tar.gz | wc -l
```

|Option|Effet|
|---|---|
|`-t`|**Test/list** - Mode listage|
|`-v`|**Verbose** - Format détaillé|
|`-z`|Décompression **gzip**|
|`-f`|**File** - Fichier archive|

> [!example] Lecture de la sortie détaillée
> 
> ```bash
> $ tar -tvzf backup.tar.gz
> drwxr-xr-x root/root         0 2024-12-26 14:30 var/www/
> -rw-r--r-- root/root      1234 2024-12-26 14:30 var/www/index.php
> -rw-r--r-- root/root       567 2024-12-26 14:30 var/www/config.php
> ```
> 
> Format : `permissions propriétaire/groupe taille date chemin`

### 🔍 Vérifier l'intégrité d'une archive

#### Test de base avec tar

```bash
# Tester l'intégrité sans extraire
tar -tzf backup.tar.gz > /dev/null

# Si aucune erreur, le code de retour est 0
if [ $? -eq 0 ]; then
    echo "Archive valide"
else
    echo "Archive corrompue !"
fi
```

#### Vérification approfondie

```bash
# Tester l'intégrité ET vérifier les checksums internes
tar -tzf backup.tar.gz --verify > /dev/null 2>&1

# Avec affichage des erreurs
tar -tzvf backup.tar.gz 2>&1 | grep -i error
```

### 🔐 Vérification avec checksums

#### Créer un checksum lors de la sauvegarde

```bash
# Créer l'archive
tar -czf backup.tar.gz /var/www

# Calculer le checksum MD5
md5sum backup.tar.gz > backup.tar.gz.md5

# Ou SHA256 (plus sécurisé)
sha256sum backup.tar.gz > backup.tar.gz.sha256
```

#### Vérifier le checksum plus tard

```bash
# Vérifier avec MD5
md5sum -c backup.tar.gz.md5

# Vérifier avec SHA256
sha256sum -c backup.tar.gz.sha256

# Sortie si OK :
# backup.tar.gz: OK

# Sortie si erreur :
# backup.tar.gz: FAILED
# md5sum: WARNING: 1 computed checksum did NOT match
```

> [!tip] Automatiser les checksums
> 
> ```bash
> # Script qui crée automatiquement le checksum
> #!/bin/bash
> BACKUP="backup_$(date +%Y%m%d).tar.gz"
> tar -czf "$BACKUP" /data
> sha256sum "$BACKUP" > "${BACKUP}.sha256"
> echo "Sauvegarde et checksum créés"
> ```

### 🔬 Rechercher des fichiers spécifiques

```bash
# Chercher un fichier dans l'archive
tar -tzf backup.tar.gz | grep config.php

# Chercher un répertoire
tar -tzf backup.tar.gz | grep "^etc/"

# Chercher avec expressions régulières
tar -tzf backup.tar.gz | grep -E '\.(conf|cfg)$'

# Vérifier qu'un fichier critique est présent
if tar -tzf backup.tar.gz | grep -q "etc/passwd"; then
    echo "Fichier passwd présent dans l'archive"
else
    echo "ALERTE : passwd absent de la sauvegarde !"
fi
```

### 📊 Analyse d'une archive

#### Statistiques de base

```bash
# Taille totale de l'archive
ls -lh backup.tar.gz

# Taille décompressée (estimation)
tar -tzf backup.tar.gz --totals 2>&1 | grep "Total bytes"

# Nombre de fichiers et répertoires
echo "Répertoires : $(tar -tzf backup.tar.gz | grep '/$' | wc -l)"
echo "Fichiers : $(tar -tzf backup.tar.gz | grep -v '/$' | wc -l)"
```

#### Plus gros fichiers de l'archive

```bash
# Lister les 10 plus gros fichiers
tar -tvzf backup.tar.gz | sort -k3 -rn | head -10

# Version plus lisible avec awk
tar -tvzf backup.tar.gz | awk '{print $3, $6}' | sort -rn | head -10
```

### 🛠️ Script de vérification automatique

```bash
#!/bin/bash

# ============================================
# Script de vérification de sauvegarde
# ============================================

BACKUP_FILE="$1"
LOG_FILE="/var/log/backup_verify.log"

log_msg() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Vérification du paramètre
if [ -z "$BACKUP_FILE" ]; then
    echo "Usage: $0 <fichier_archive>"
    exit 1
fi

# Vérification de l'existence
if [ ! -f "$BACKUP_FILE" ]; then
    log_msg "ERREUR : $BACKUP_FILE introuvable"
    exit 1
fi

log_msg "=== Vérification de $BACKUP_FILE ==="

# Test d'intégrité
log_msg "Test d'intégrité en cours..."
if tar -tzf "$BACKUP_FILE" > /dev/null 2>&1; then
    log_msg "✓ Intégrité OK"
else
    log_msg "✗ ERREUR : Archive corrompue"
    exit 1
fi

# Vérification du checksum si disponible
CHECKSUM_FILE="${BACKUP_FILE}.sha256"
if [ -f "$CHECKSUM_FILE" ]; then
    log_msg "Vérification du checksum..."
    if sha256sum -c "$CHECKSUM_FILE" > /dev/null 2>&1; then
        log_msg "✓ Checksum valide"
    else
        log_msg "✗ ERREUR : Checksum invalide"
        exit 1
    fi
fi

# Statistiques
FILE_COUNT=$(tar -tzf "$BACKUP_FILE" | wc -l)
FILE_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
log_msg "Contenu : $FILE_COUNT fichiers, taille : $FILE_SIZE"

# Vérification de fichiers critiques
CRITICAL_FILES=("etc/passwd" "etc/shadow" "etc/fstab")
MISSING=0

for file in "${CRITICAL_FILES[@]}"; do
    if ! tar -tzf "$BACKUP_FILE" | grep -q "^$file"; then
        log_msg "⚠ ATTENTION : $file absent de l'archive"
        MISSING=$((MISSING + 1))
    fi
done

if [ $MISSING -eq 0 ]; then
    log_msg "✓ Tous les fichiers critiques sont présents"
fi

log_msg "=== Vérification terminée ==="
```

---

## 🔄 Tests de restauration

### 🎯 L'importance critique des tests

> [!warning] Statistique alarmante Selon plusieurs études, **environ 30% des sauvegardes** échouent lors de la restauration réelle. Les causes principales :
> 
> - Archive corrompue non détectée
> - Permissions incorrectes
> - Chemins absolus/relatifs mal gérés
> - Dépendances système manquantes
> - Espace disque insuffisant

**Un test de restauration n'est pas optionnel - c'est obligatoire.**

### 🧪 Types de tests de restauration

#### 1. Test de restauration complète

```bash
# Créer un environnement de test isolé
mkdir -p /tmp/restore_test
cd /tmp/restore_test

# Extraire l'archive complète
tar -xzf /backups/backup.tar.gz

# Vérifier le résultat
ls -la
du -sh .

# Nettoyer après le test
cd /
rm -rf /tmp/restore_test
```

#### 2. Test de restauration sélective

```bash
# Tester la restauration d'un fichier critique
mkdir /tmp/restore_test
tar -xzf /backups/backup.tar.gz -C /tmp/restore_test etc/passwd

# Vérifier que le fichier est correct
cat /tmp/restore_test/etc/passwd
wc -l /tmp/restore_test/etc/passwd

# Comparer avec l'original si possible
diff /etc/passwd /tmp/restore_test/etc/passwd
```

#### 3. Test de restauration par comparaison

```bash
# Comparer l'archive avec le système en production
mkdir /tmp/backup_content
tar -xzf /backups/backup.tar.gz -C /tmp/backup_content

# Comparer les fichiers
diff -r /var/www /tmp/backup_content/var/www

# Comparer uniquement la structure
diff <(find /var/www -type f | sort) \
     <(find /tmp/backup_content/var/www -type f | sort)
```

### 📅 Plan de tests réguliers

> [!info] Fréquence recommandée des tests
> 
> - **Sauvegardes critiques** : Tester chaque semaine
> - **Sauvegardes importantes** : Tester chaque mois
> - **Sauvegardes d'archivage** : Tester chaque trimestre
> - **Après chaque modification** du système de sauvegarde

### 🔧 Procédure complète de test

```bash
#!/bin/bash

# ============================================
# Script de test de restauration complet
# ============================================

BACKUP_FILE="/backups/backup_20241226.tar.gz"
TEST_DIR="/tmp/restore_test_$(date +%s)"
LOG_FILE="/var/log/restore_test.log"
ERRORS=0

log_msg() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Début du test
log_msg "=========================================="
log_msg "Test de restauration : $BACKUP_FILE"
log_msg "=========================================="

# Étape 1 : Vérification de l'existence
log_msg "Étape 1/6 : Vérification de l'archive..."
if [ ! -f "$BACKUP_FILE" ]; then
    log_msg "✗ ERREUR : Archive introuvable"
    exit 1
fi
SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
log_msg "✓ Archive trouvée (taille : $SIZE)"

# Étape 2 : Test d'intégrité
log_msg "Étape 2/6 : Test d'intégrité..."
if tar -tzf "$BACKUP_FILE" > /dev/null 2>&1; then
    log_msg "✓ Intégrité validée"
else
    log_msg "✗ ERREUR : Archive corrompue"
    exit 1
fi

# Étape 3 : Vérification de l'espace disque
log_msg "Étape 3/6 : Vérification de l'espace disque..."
DECOMPRESSED_SIZE=$(tar -tzf "$BACKUP_FILE" --totals 2>&1 | grep -o '[0-9]*' | tail -1)
AVAILABLE_SPACE=$(df /tmp | tail -1 | awk '{print $4}')
if [ "$AVAILABLE_SPACE" -gt "$((DECOMPRESSED_SIZE / 1024))" ]; then
    log_msg "✓ Espace disque suffisant"
else
    log_msg "✗ ATTENTION : Espace disque peut être insuffisant"
    ERRORS=$((ERRORS + 1))
fi

# Étape 4 : Création du répertoire de test
log_msg "Étape 4/6 : Création de l'environnement de test..."
mkdir -p "$TEST_DIR"
if [ $? -eq 0 ]; then
    log_msg "✓ Répertoire de test créé : $TEST_DIR"
else
    log_msg "✗ ERREUR : Impossible de créer le répertoire de test"
    exit 1
fi

# Étape 5 : Extraction
log_msg "Étape 5/6 : Extraction de l'archive..."
START_TIME=$(date +%s)
tar -xzf "$BACKUP_FILE" -C "$TEST_DIR" 2>> "$LOG_FILE"
if [ $? -eq 0 ]; then
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))
    FILE_COUNT=$(find "$TEST_DIR" -type f | wc -l)
    log_msg "✓ Extraction réussie en ${DURATION}s ($FILE_COUNT fichiers)"
else
    log_msg "✗ ERREUR : Échec de l'extraction"
    rm -rf "$TEST_DIR"
    exit 1
fi

# Étape 6 : Vérification des fichiers critiques
log_msg "Étape 6/6 : Vérification des fichiers critiques..."
CRITICAL_FILES=("etc/passwd" "etc/group" "etc/hostname")
MISSING_FILES=0

for file in "${CRITICAL_FILES[@]}"; do
    if [ -f "$TEST_DIR/$file" ]; then
        log_msg "  ✓ $file présent"
    else
        log_msg "  ✗ $file ABSENT"
        MISSING_FILES=$((MISSING_FILES + 1))
        ERRORS=$((ERRORS + 1))
    fi
done

# Nettoyage
log_msg "Nettoyage de l'environnement de test..."
rm -rf "$TEST_DIR"
log_msg "✓ Nettoyage terminé"

# Résumé
log_msg "=========================================="
if [ $ERRORS -eq 0 ]; then
    log_msg "✓ TEST RÉUSSI - La sauvegarde est restaurable"
    log_msg "=========================================="
    exit 0
else
    log_msg "✗ TEST ÉCHOUÉ - $ERRORS erreur(s) détectée(s)"
    log_msg "=========================================="
    exit 1
fi
```

### 🎯 Points de contrôle essentiels

Lors d'un test de restauration, vérifiez systématiquement :

|Point de contrôle|Commande|Que vérifier|
|---|---|---|
|**Intégrité archive**|`tar -tzf`|Aucune erreur de lecture|
|**Permissions**|`ls -l` après extraction|Propriétaires et permissions corrects|
|**Taille fichiers**|`du -sh`|Taille cohérente avec l'original|
|**Liens symboliques**|`find -type l`|Liens préservés et valides|
|**Fichiers cachés**|`ls -a`|Fichiers `.config`, `.ssh` présents|
|**Structure**|`tree` ou `find`|Hiérarchie complète|
|**Contenu**|`diff` ou `md5sum`|Données identiques à l'original|

### 🔄 Simulation de scénario de disaster recovery

> [!example] Test grandeur nature Le test ultime consiste à simuler une catastrophe complète :
> 
> ```bash
> # 1. Créer une machine virtuelle vierge ou un conteneur
> docker run -it --name restore_test ubuntu:latest /bin/bash
> 
> # 2. Y copier votre archive de sauvegarde
> docker cp backup.tar.gz restore_test:/tmp/
> 
> # 3. Tenter une restauration complète du système
> docker exec -it restore_test bash
> cd /
> tar -xzf /tmp/backup.tar.gz
> 
> # 4. Vérifier que l'application fonctionne
> # Démarrer les services, tester les accès, etc.
> ```

### 📊 Documentation des tests

> [!tip] Tenir un registre de tests Documentez chaque test dans un fichier standardisé :
> 
> ```bash
> # Exemple de rapport de test
> cat >> /var/log/backup_tests.log << EOF
> ========================================
> Date du test : $(date '+%Y-%m-%d %H:%M:%S')
> Archive testée : backup_20241226.tar.gz
> Taille : 2.3 GB
> Temps d'extraction : 45 secondes
> Fichiers extraits : 12,847
> Résultat : SUCCÈS
> Testeur : admin
> Commentaires : Tous les fichiers critiques présents
> ========================================
> EOF
> ```

### ⚠️ Erreurs courantes lors des tests

> [!warning] Pièges fréquents
> 
> **1. Tester sur le même serveur que la production**
> 
> - Risque d'écraser des données en production
> - Ne teste pas la portabilité sur un autre système
> 
> **2. Tester uniquement l'intégrité technique**
> 
> - L'archive peut être valide mais les données corrompues
> - Toujours vérifier le **contenu** des fichiers restaurés
> 
> **3. Ne jamais tester les restaurations partielles**
> 
> - En production, vous aurez souvent besoin de restaurer un seul fichier
> - Testez différents scénarios de restauration sélective
> 
> **4. Oublier de tester les permissions**
> 
> - Des fichiers restaurés avec de mauvaises permissions peuvent causer des failles de sécurité
> - Vérifiez particulièrement les fichiers sensibles comme `/etc/shadow`
> 
> **5. Ne pas chronométrer les tests**
> 
> - En cas d'urgence, vous devez savoir combien de temps prendra la restauration
> - Documentez les temps de restauration pour différentes tailles

### 🎓 Bonnes pratiques de tests

1. **Tester régulièrement** : Ne pas attendre une urgence pour découvrir un problème
2. **Varier les scénarios** : Test complet, partiel, sur différents systèmes
3. **Documenter les résultats** : Tenir un journal des tests effectués
4. **Automatiser** : Créer des scripts qui testent automatiquement chaque sauvegarde
5. **Former l'équipe** : S'assurer que plusieurs personnes savent restaurer
6. **Simuler la pression** : Faire des exercices chronométrés de restauration d'urgence

> [!tip] Script de test automatique quotidien
> 
> ```bash
> #!/bin/bash
> # À ajouter dans cron : 0 4 * * * /root/test_backup.sh
> 
> LATEST_BACKUP=$(ls -t /backups/*.tar.gz | head -1)
> TEST_DIR="/tmp/daily_test_$(date +%s)"
> 
> # Test rapide : extraction de quelques fichiers clés
> mkdir -p "$TEST_DIR"
> tar -xzf "$LATEST_BACKUP" -C "$TEST_DIR" \
>     etc/passwd etc/hostname var/www/config.php 2>/dev/null
> 
> if [ $? -eq 0 ] && [ -f "$TEST_DIR/etc/passwd" ]; then
>     echo "$(date): Test OK" >> /var/log/backup_daily_tests.log
> else
>     echo "$(date): Test ÉCHOUÉ" >> /var/log/backup_daily_tests.log
>     echo "ALERTE: Test de sauvegarde échoué" | mail -s "Backup Test Failed" admin@example.com
> fi
> 
> rm -rf "$TEST_DIR"
> ```

### 🔐 Sécurité lors des tests

> [!warning] Précautions de sécurité
> 
> - **Isoler les tests** : Ne jamais tester sur le système de production
> - **Protéger les données sensibles** : Les tests exposent temporairement les données
> - **Nettoyer après test** : Supprimer complètement les fichiers restaurés
> - **Logs sécurisés** : Les logs de test ne doivent pas contenir de mots de passe
> - **Permissions** : Le répertoire de test doit avoir des permissions restrictives (700)

---

## 🎯 Récapitulatif et bonnes pratiques générales

### ✅ Checklist complète d'une stratégie de sauvegarde robuste

- [ ] **Automatisation avec cron** configurée et testée
- [ ] **Scripts de sauvegarde** documentés avec logging
- [ ] **Rotation automatique** des anciennes sauvegardes en place
- [ ] **Vérification d'intégrité** systématique de chaque archive
- [ ] **Checksums** calculés et stockés avec les archives
- [ ] **Tests de restauration** réguliers planifiés et documentés
- [ ] **Sauvegardes testées** au moins une fois par mois
- [ ] **Documentation** à jour des procédures de restauration
- [ ] **Plusieurs personnes formées** aux procédures de sauvegarde/restauration
- [ ] **Alertes** configurées en cas d'échec de sauvegarde

### 🎓 Principes fondamentaux à retenir

> [!info] La règle 3-2-1
> 
> - **3** copies de vos données
> - Sur **2** supports différents
> - **1** copie hors site (externe)

> [!tip] Les commandements de la sauvegarde
> 
> 1. **Automatiser** : Les humains oublient, les machines non
> 2. **Vérifier** : Une archive non testée est inutile
> 3. **Tester** : La restauration doit être pratiquée régulièrement
> 4. **Documenter** : En urgence, on n'a pas le temps de réfléchir
> 5. **Sécuriser** : Protéger les sauvegardes comme les données originales
> 6. **Monitorer** : Être alerté immédiatement en cas de problème
> 7. **Former** : Plusieurs personnes doivent savoir restaurer

### 📈 Évolution et amélioration continue

Votre système de sauvegarde doit évoluer :

- **Auditer régulièrement** : Revoir la stratégie tous les 6 mois
- **Adapter aux changements** : Nouvelles données = nouvelles sauvegardes
- **Optimiser** : Analyser les temps et tailles pour améliorer
- **Moderniser** : Évaluer de nouveaux outils et méthodes

---

## 💡 Synthèse

Ce chapitre vous a appris à :

✅ **Planifier des sauvegardes automatiques** avec cron et gérer la crontab ✅ **Créer des scripts robustes** avec logging, rotation et notifications ✅ **Extraire des archives** de manière sûre et sélective ✅ **Vérifier l'intégrité** des sauvegardes avec différentes méthodes ✅ **Tester les restaurations** de manière systématique et documentée

> [!warning] Message final **Ne jamais faire confiance à une sauvegarde non testée.** La pire chose qui puisse arriver est de découvrir que vos sauvegardes sont inutilisables au moment où vous en avez désespérément besoin. Testez, testez, et testez encore !

---

_Ce cours fait partie du module Administration Linux - Sauvegardes de base_