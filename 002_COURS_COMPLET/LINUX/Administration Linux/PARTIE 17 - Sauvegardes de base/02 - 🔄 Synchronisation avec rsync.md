

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

## 🎯 Introduction à rsync

**rsync** (remote synchronization) est un outil de synchronisation et de transfert de fichiers extrêmement puissant et efficace. Contrairement à `cp` ou `scp` qui copient tous les fichiers, rsync ne transfère que les différences entre la source et la destination.

> [!info] Pourquoi rsync ?
> 
> - **Efficacité** : Ne transfère que les données modifiées (algorithme delta-transfer)
> - **Rapidité** : Compression à la volée, reprise après interruption
> - **Polyvalence** : Fonctionne en local comme à distance (SSH)
> - **Contrôle** : Nombreuses options pour adapter le comportement
> - **Sécurité** : Préservation des permissions, propriétaires, et horodatages

### 🔍 Syntaxe de base

```bash
rsync [OPTIONS] SOURCE DESTINATION
```

---

## ⚙️ Options principales de rsync

### Option `-a` (archive)

L'option `-a` ou `--archive` est la plus utilisée. C'est en réalité un raccourci qui combine plusieurs options :

```bash
rsync -a source/ destination/
```

> [!info] Que fait `-a` exactement ? L'option `-a` équivaut à `-rlptgoD` :
> 
> - `-r` : récursif (parcourt les sous-répertoires)
> - `-l` : préserve les liens symboliques
> - `-p` : préserve les permissions
> - `-t` : préserve les horodatages (timestamps)
> - `-g` : préserve le groupe
> - `-o` : préserve le propriétaire (nécessite root)
> - `-D` : préserve les fichiers spéciaux et périphériques

**Quand l'utiliser** : Pour pratiquement toutes les sauvegardes où vous voulez une copie exacte.

```bash
# Exemple : sauvegarde d'un répertoire personnel
rsync -a /home/utilisateur/ /backup/home/
```

> [!warning] Le slash final est important !
> 
> - `source/` → copie le CONTENU de source dans destination
> - `source` → copie le RÉPERTOIRE source lui-même dans destination
> 
> Exemple :
> 
> ```bash
> rsync -a /data/ /backup/     # Crée /backup/fichier1, /backup/fichier2...
> rsync -a /data /backup/      # Crée /backup/data/fichier1, /backup/data/fichier2...
> ```

### Option `-v` (verbose)

L'option `-v` ou `--verbose` affiche les détails de l'opération en cours :

```bash
rsync -av source/ destination/
```

**Sortie typique** :

```
sending incremental file list
fichier1.txt
dossier/
dossier/fichier2.txt
dossier/fichier3.log

sent 1,234 bytes  received 89 bytes  2,646.00 bytes/sec
total size is 45,678  speedup is 34.51
```

> [!tip] Niveaux de verbosité
> 
> - `-v` : affiche les fichiers transférés
> - `-vv` : informations plus détaillées sur chaque fichier
> - `-vvv` : informations de débogage complètes

**Quand l'utiliser** : Toujours en mode interactif pour suivre la progression. À éviter dans les scripts automatiques (utiliser plutôt `--stats`).

### Option `-z` (compress)

L'option `-z` ou `--compress` compresse les données pendant le transfert :

```bash
rsync -avz source/ utilisateur@serveur:/destination/
```

> [!info] Comment ça fonctionne
> 
> - Compression côté source avant envoi
> - Décompression côté destination après réception
> - Réduit la bande passante utilisée
> - Augmente légèrement l'usage CPU

**Quand l'utiliser** :

- ✅ **OUI** : Connexions lentes (ADSL, 4G, connexions distantes)
- ✅ **OUI** : Fichiers texte, logs, code source (taux de compression élevé)
- ❌ **NON** : Réseau local rapide (overhead CPU non justifié)
- ❌ **NON** : Fichiers déjà compressés (jpg, mp4, zip, gz) → perte de performance

```bash
# Bon cas d'usage : synchronisation de logs vers un serveur distant
rsync -avz /var/log/ admin@backup-server:/logs/production/

# Mauvais cas d'usage : copie locale sur réseau gigabit
rsync -av /data/ /mnt/nas/data/  # Pas besoin de -z ici
```

### Option `--delete`

L'option `--delete` supprime les fichiers de la destination qui n'existent plus dans la source :

```bash
rsync -av --delete source/ destination/
```

> [!warning] Attention : Suppression irréversible ! Cette option rend la destination identique à la source en supprimant ce qui est en trop. Parfait pour les miroirs exacts, dangereux si mal utilisé.

**Comportement** :

```bash
# État initial
Source:      fichier1.txt, fichier2.txt
Destination: fichier1.txt, fichier2.txt, fichier3.txt (ancien)

# Après rsync -av --delete
Destination: fichier1.txt, fichier2.txt
# fichier3.txt a été supprimé !
```

**Variantes de `--delete`** :

|Option|Comportement|
|---|---|
|`--delete`|Supprime pendant le transfert (défaut)|
|`--delete-before`|Supprime avant le transfert|
|`--delete-after`|Supprime après le transfert (plus sûr)|
|`--delete-excluded`|Supprime aussi les fichiers exclus|

> [!tip] Bonne pratique : toujours tester d'abord
> 
> ```bash
> # Test avec --dry-run (simulation sans modification)
> rsync -av --delete --dry-run source/ destination/
> 
> # Si tout est OK, exécuter pour de vrai
> rsync -av --delete source/ destination/
> ```

**Cas d'usage typique** : Miroir exact d'un site web

```bash
rsync -avz --delete /var/www/html/ serveur-web:/var/www/html/
```

### 📊 Tableau récapitulatif des options principales

|Option|Raccourci|Fonction|Usage recommandé|
|---|---|---|---|
|`--archive`|`-a`|Mode archive complet|Toujours (ou presque)|
|`--verbose`|`-v`|Affichage détaillé|En mode interactif|
|`--compress`|`-z`|Compression du transfert|Connexions lentes|
|`--delete`|-|Supprime les fichiers en trop|Miroirs exacts|

---

## 💻 Synchronisation locale

La synchronisation locale se fait entre deux répertoires du même système ou montés localement.

### Syntaxe de base

```bash
rsync [OPTIONS] /chemin/source/ /chemin/destination/
```

### Exemples pratiques

**1. Sauvegarde simple d'un répertoire**

```bash
# Sauvegarde complète avec préservation des attributs
rsync -av /home/utilisateur/Documents/ /backup/documents/

# Avec affichage de la progression
rsync -av --progress /home/utilisateur/Documents/ /backup/documents/
```

**2. Sauvegarde incrémentielle (miroir exact)**

```bash
# Synchronisation avec suppression des fichiers obsolètes
rsync -av --delete /data/production/ /backup/production/
```

> [!example] Scénario réel : Sauvegarde quotidienne
> 
> ```bash
> #!/bin/bash
> # Script de sauvegarde quotidienne
> 
> SOURCE="/home/utilisateur/projets"
> BACKUP="/mnt/disque_externe/backup_projets"
> DATE=$(date +%Y%m%d_%H%M%S)
> LOG="/var/log/backup_${DATE}.log"
> 
> # Synchronisation avec logs
> rsync -av --delete \
>       --stats \
>       --log-file="$LOG" \
>       "$SOURCE/" "$BACKUP/"
> 
> # Vérification du statut
> if [ $? -eq 0 ]; then
>     echo "Sauvegarde réussie : $DATE" | tee -a "$LOG"
> else
>     echo "ERREUR lors de la sauvegarde !" | tee -a "$LOG"
>     exit 1
> fi
> ```

**3. Synchronisation avec exclusions**

```bash
# Exclure certains fichiers ou répertoires
rsync -av --delete \
      --exclude='*.tmp' \
      --exclude='cache/' \
      --exclude='node_modules/' \
      /projet/ /backup/projet/
```

> [!tip] Fichier d'exclusions Pour de nombreuses exclusions, utilisez un fichier :
> 
> ```bash
> # Créer /etc/rsync-exclude.txt
> *.log
> *.tmp
> .git/
> node_modules/
> __pycache__/
> 
> # Utiliser le fichier
> rsync -av --delete --exclude-from='/etc/rsync-exclude.txt' \
>       /source/ /destination/
> ```

**4. Limiter la bande passante**

```bash
# Limiter à 5000 KB/s (5 MB/s)
rsync -av --bwlimit=5000 /source/ /destination/
```

**5. Afficher uniquement les différences (mode dry-run)**

```bash
# Simuler sans modifier (très utile pour tester)
rsync -avn --delete /source/ /destination/

# Version plus lisible avec résumé
rsync -avn --delete --stats /source/ /destination/
```

### Options utiles pour la synchronisation locale

|Option|Description|Exemple|
|---|---|---|
|`--progress`|Barre de progression par fichier|`rsync -av --progress`|
|`--stats`|Statistiques finales|`rsync -av --stats`|
|`--dry-run` ou `-n`|Simulation sans modification|`rsync -avn`|
|`--exclude`|Exclure des patterns|`--exclude='*.log'`|
|`--include`|Inclure des patterns|`--include='*.txt'`|
|`--max-size`|Taille max des fichiers|`--max-size=100M`|
|`--min-size`|Taille min des fichiers|`--min-size=1K`|
|`--bwlimit`|Limiter la bande passante|`--bwlimit=5000`|
|`--partial`|Garder les fichiers partiels|`--partial`|

> [!warning] Pièges courants
> 
> **1. Oublier le slash final**
> 
> ```bash
> # Mauvais : crée /backup/data/data/fichiers
> rsync -av /data /backup/data/
> 
> # Bon : crée /backup/data/fichiers
> rsync -av /data/ /backup/data/
> ```
> 
> **2. Utiliser --delete sans vérifier**
> 
> ```bash
> # DANGER : peut supprimer des données !
> # Toujours tester d'abord avec -n
> rsync -avn --delete /source/ /destination/
> ```
> 
> **3. Mauvaise gestion des permissions**
> 
> ```bash
> # Sans -a, les permissions sont perdues
> rsync /source/ /destination/  # ❌
> 
> # Avec -a, tout est préservé
> rsync -a /source/ /destination/  # ✅
> ```

### Cas d'usage avancés

**Synchronisation bidirectionnelle (à éviter généralement)**

```bash
# Sync A → B
rsync -av --delete /dossier_a/ /dossier_b/

# Sync B → A (attention aux conflits !)
rsync -av --delete /dossier_b/ /dossier_a/
```

> [!warning] Attention rsync n'est pas conçu pour la synchronisation bidirectionnelle. Pour cela, utilisez plutôt `unison` ou `syncthing`.

**Copie avec préservation des liens durs**

```bash
# Option -H pour préserver les hard links
rsync -avH /source/ /destination/
```

**Sauvegarde avec horodatage**

```bash
#!/bin/bash
# Créer une nouvelle sauvegarde datée
BACKUP_DIR="/backups/$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"

rsync -av --link-dest=/backups/latest \
      /data/ "$BACKUP_DIR/"

# Mettre à jour le lien symbolique "latest"
ln -sfn "$BACKUP_DIR" /backups/latest
```

---

## 🌐 Synchronisation distante

La synchronisation distante permet de transférer des fichiers entre machines via SSH.

### Syntaxe de base

```bash
# Machine locale → Machine distante
rsync [OPTIONS] /source/ utilisateur@hôte:/destination/

# Machine distante → Machine locale
rsync [OPTIONS] utilisateur@hôte:/source/ /destination/

# Machine distante → Machine distante (via machine locale)
rsync [OPTIONS] utilisateur1@hôte1:/source/ utilisateur2@hôte2:/destination/
```

### Configuration SSH pour rsync

> [!tip] Prérequis : SSH configuré rsync utilise SSH par défaut pour les connexions distantes. Assurez-vous que :
> 
> - SSH est installé sur les deux machines
> - Vous pouvez vous connecter : `ssh utilisateur@serveur`
> - Idéalement, configurez l'authentification par clé SSH (sans mot de passe)

**Configuration de clés SSH** (recommandé) :

```bash
# Sur la machine locale : générer une paire de clés
ssh-keygen -t ed25519 -C "backup@monserveur"

# Copier la clé publique sur le serveur distant
ssh-copy-id utilisateur@serveur-distant

# Tester la connexion sans mot de passe
ssh utilisateur@serveur-distant
```

### Exemples de synchronisation distante

**1. Envoi vers un serveur distant (push)**

```bash
# Synchronisation de base
rsync -avz /data/local/ utilisateur@serveur.com:/data/distant/

# Avec suppression des fichiers obsolètes
rsync -avz --delete /data/local/ utilisateur@serveur.com:/data/distant/

# Avec progression détaillée
rsync -avz --progress /data/local/ utilisateur@serveur.com:/data/distant/
```

**2. Récupération depuis un serveur distant (pull)**

```bash
# Télécharger des données
rsync -avz utilisateur@serveur.com:/data/distant/ /data/local/

# Récupérer uniquement certains fichiers
rsync -avz utilisateur@serveur.com:/logs/*.log /var/log/remote/
```

**3. Spécifier un port SSH personnalisé**

```bash
# Si SSH écoute sur un port non-standard (ex: 2222)
rsync -avz -e "ssh -p 2222" /local/ utilisateur@serveur.com:/distant/

# Avec options SSH supplémentaires
rsync -avz -e "ssh -p 2222 -i ~/.ssh/backup_key" \
      /local/ utilisateur@serveur.com:/distant/
```

**4. Utiliser une configuration SSH spécifique**

```bash
# Dans ~/.ssh/config
Host backup-server
    HostName 192.168.1.100
    User backup
    Port 2222
    IdentityFile ~/.ssh/backup_key
    Compression yes

# Puis utiliser simplement
rsync -avz /local/ backup-server:/distant/
```

### Options spécifiques à la synchronisation distante

|Option|Description|Exemple|
|---|---|---|
|`-e "ssh -p PORT"`|Spécifier port SSH|`-e "ssh -p 2222"`|
|`--rsync-path`|Chemin de rsync sur le distant|`--rsync-path=/usr/local/bin/rsync`|
|`--bwlimit`|Limiter la bande passante|`--bwlimit=1000` (1 MB/s)|
|`--partial`|Reprendre les transferts interrompus|`--partial`|
|`--partial-dir`|Dossier pour fichiers partiels|`--partial-dir=/tmp/rsync-partial`|
|`-z` ou `--compress`|Compression (important à distance)|`-z`|
|`--compress-level`|Niveau de compression (0-9)|`--compress-level=6`|

### Exemples pratiques de synchronisation distante

**1. Sauvegarde d'un serveur web**

```bash
#!/bin/bash
# Script de sauvegarde d'un site web distant

SERVER="utilisateur@web-server.com"
REMOTE_PATH="/var/www/html"
LOCAL_BACKUP="/backups/website/$(date +%Y%m%d)"
LOG="/var/log/backup-web.log"

# Créer le répertoire de destination
mkdir -p "$LOCAL_BACKUP"

# Sauvegarde avec logs
rsync -avz --delete \
      --exclude='cache/' \
      --exclude='tmp/' \
      --stats \
      "$SERVER:$REMOTE_PATH/" "$LOCAL_BACKUP/" 2>&1 | tee -a "$LOG"

if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo "[$(date)] Sauvegarde réussie" >> "$LOG"
else
    echo "[$(date)] ERREUR lors de la sauvegarde" >> "$LOG"
    # Envoyer une alerte
    mail -s "Erreur sauvegarde site web" admin@example.com < "$LOG"
fi
```

**2. Synchronisation de bases de données**

```bash
#!/bin/bash
# Récupération de dumps SQL depuis un serveur

DB_SERVER="dba@database-server.com"
REMOTE_DUMPS="/backups/sql"
LOCAL_DUMPS="/var/backups/sql"

# Récupérer uniquement les dumps récents (moins de 7 jours)
rsync -avz \
      --include='*.sql.gz' \
      --include='*/' \
      --exclude='*' \
      --prune-empty-dirs \
      "$DB_SERVER:$REMOTE_DUMPS/" "$LOCAL_DUMPS/"
```

**3. Déploiement d'une application**

```bash
#!/bin/bash
# Déploiement sur serveurs de production

SERVERS=("web1.prod.com" "web2.prod.com" "web3.prod.com")
APP_PATH="/opt/myapp"
LOCAL_BUILD="/builds/myapp-v2.5"

for SERVER in "${SERVERS[@]}"; do
    echo "Déploiement sur $SERVER..."
    
    rsync -avz --delete \
          --exclude='config/local.conf' \
          --exclude='logs/' \
          --exclude='data/' \
          "$LOCAL_BUILD/" "deploy@$SERVER:$APP_PATH/"
    
    if [ $? -eq 0 ]; then
        echo "✓ Déploiement réussi sur $SERVER"
        ssh "deploy@$SERVER" "sudo systemctl restart myapp"
    else
        echo "✗ ERREUR sur $SERVER"
        exit 1
    fi
done
```

**4. Synchronisation avec plusieurs serveurs (fan-out)**

```bash
#!/bin/bash
# Distribuer des fichiers vers plusieurs serveurs

SOURCE="/shared/documents"
SERVERS=(
    "user@server1.com:/data"
    "user@server2.com:/data"
    "user@server3.com:/data"
)

for DEST in "${SERVERS[@]}"; do
    echo "Synchronisation vers $DEST"
    rsync -avz --delete "$SOURCE/" "$DEST/" &
done

# Attendre que tous les rsync se terminent
wait
echo "Synchronisation terminée sur tous les serveurs"
```

### Options avancées pour le distant

**Reprendre les transferts interrompus**

```bash
# Garder les fichiers partiellement transférés
rsync -avz --partial --partial-dir=/tmp/rsync-tmp \
      /local/ user@server:/distant/

# Ou simplement (crée .rsync-partial automatiquement)
rsync -avzP /local/ user@server:/distant/
# Note : -P est équivalent à --partial --progress
```

**Limiter la bande passante**

```bash
# Limiter à 2 MB/s (utile pour ne pas saturer la connexion)
rsync -avz --bwlimit=2000 /local/ user@server:/distant/
```

**Utiliser un chemin rsync différent sur le serveur distant**

```bash
# Si rsync est installé dans un chemin non-standard
rsync -avz --rsync-path=/usr/local/bin/rsync \
      /local/ user@server:/distant/

# Utile aussi pour exécuter avec sudo sur le distant
rsync -avz --rsync-path="sudo rsync" \
      /local/ user@server:/root/distant/
```

**Synchronisation avec vérification par checksum**

```bash
# Forcer la vérification par checksum (plus lent mais plus sûr)
rsync -avzc user@server:/distant/ /local/
```

> [!warning] Pièges de la synchronisation distante
> 
> **1. Oubli de compression sur connexions lentes**
> 
> ```bash
> # ❌ Sans -z sur connexion ADSL → très lent
> rsync -av user@server:/data/ /local/
> 
> # ✅ Avec -z → beaucoup plus rapide
> rsync -avz user@server:/data/ /local/
> ```
> 
> **2. Saturation de la connexion**
> 
> ```bash
> # Peut rendre le serveur inaccessible
> rsync -avz /huge-data/ user@server:/backup/
> 
> # Mieux : limiter la bande passante
> rsync -avz --bwlimit=5000 /huge-data/ user@server:/backup/
> ```
> 
> **3. Permissions insuffisantes sur le distant**
> 
> ```bash
> # Erreur si l'utilisateur n'a pas les droits
> rsync -avz /local/ user@server:/root/backup/
> 
> # Solution : utiliser sudo sur le distant
> rsync -avz --rsync-path="sudo rsync" \
>       /local/ user@server:/root/backup/
> ```
> 
> **4. Transferts interrompus sans --partial**
> 
> ```bash
> # Sans --partial : recommence tout à chaque fois
> rsync -avz /big-files/ user@server:/backup/
> 
> # Avec --partial : reprend là où ça s'est arrêté
> rsync -avzP /big-files/ user@server:/backup/
> ```

### Monitoring et performances

**Afficher des statistiques détaillées**

```bash
rsync -avz --stats user@server:/data/ /local/

# Sortie exemple :
# Number of files: 1,234
# Number of files transferred: 56
# Total file size: 5.67G bytes
# Total transferred file size: 123.45M bytes
# Literal data: 123.45M bytes
# Matched data: 0 bytes
# File list size: 23.45K
# Total bytes sent: 1.23K
# Total bytes received: 124.56M
# 
# sent 1.23K bytes  received 124.56M bytes  2.34M bytes/sec
# total size is 5.67G  speedup is 45.67
```

**Suivre la progression en temps réel**

```bash
# Avec barre de progression par fichier
rsync -avz --progress user@server:/data/ /local/

# Avec --info pour plus de détails
rsync -avz --info=progress2 user@server:/data/ /local/
```

**Exécuter en arrière-plan avec logs**

```bash
# Rediriger la sortie vers un fichier log
nohup rsync -avz --progress user@server:/data/ /local/ \
      > /var/log/rsync-backup.log 2>&1 &

# Suivre la progression
tail -f /var/log/rsync-backup.log
```

> [!tip] Astuces de performance
> 
> **1. Augmenter le niveau de compression pour connexions très lentes**
> 
> ```bash
> rsync -avz --compress-level=9 user@server:/data/ /local/
> ```
> 
> **2. Désactiver la compression pour fichiers déjà compressés**
> 
> ```bash
> rsync -av --no-compress='*.gz/*.zip/*.jpg/*.mp4' \
>       user@server:/data/ /local/
> ```
> 
> **3. Paralléliser avec plusieurs connexions SSH**
> 
> ```bash
> # Nécessite GNU Parallel
> find /source -maxdepth 1 -type d | parallel -j4 \
>     rsync -avz {} user@server:/destination/
> ```

---

## 🎯 Commandes essentielles à retenir

```bash
# Synchronisation locale de base
rsync -av /source/ /destination/

# Synchronisation locale avec miroir exact
rsync -av --delete /source/ /destination/

# Synchronisation distante (envoi)
rsync -avz /local/ user@server:/distant/

# Synchronisation distante (réception)
rsync -avz user@server:/distant/ /local/

# Test sans modification
rsync -avn --delete /source/ /destination/

# Avec reprise des transferts
rsync -avzP user@server:/data/ /local/

# Avec limitation de bande passante
rsync -avz --bwlimit=5000 /local/ user@server:/distant/
```

---

> [!info] Résumé des bonnes pratiques
> 
> ✅ **À FAIRE** :
> 
> - Toujours utiliser `-a` pour préserver les attributs
> - Tester avec `-n` (dry-run) avant d'utiliser `--delete`
> - Utiliser `-z` pour les connexions distantes lentes
> - Faire attention au slash final de la source
> - Utiliser `--partial` pour les gros transferts qui peuvent être interrompus
> - Logger les opérations importantes
> - Limiter la bande passante si nécessaire
> 
> ❌ **À ÉVITER** :
> 
> - Utiliser `--delete` sans vérification préalable
> - Oublier le slash final (comportement différent)
> - Compresser des fichiers déjà compressés
> - Lancer des transferts massifs sans limite de bande passante
> - Exécuter rsync sans permissions suffisantes

---

_Cours généré pour Obsidian - Administration Linux - Sauvegardes de base_