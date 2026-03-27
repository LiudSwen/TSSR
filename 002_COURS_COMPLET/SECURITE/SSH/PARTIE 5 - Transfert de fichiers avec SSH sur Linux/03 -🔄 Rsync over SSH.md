

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

## 🎯 Introduction à Rsync

**Rsync** (Remote Sync) est un outil de synchronisation de fichiers et de répertoires puissant et versatile. Contrairement à `scp` qui copie toujours l'intégralité des fichiers, rsync analyse les différences et transfère uniquement les données modifiées.

> [!info] Quand utiliser Rsync ?
> 
> - Sauvegardes régulières et incrémentales
> - Synchronisation de gros volumes de données
> - Transferts à reprendre après interruption
> - Miroir de répertoires entre systèmes
> - Déploiements de sites web ou applications

---

## ⚡ Avantages de Rsync

### Comparaison avec SCP

|Caractéristique|SCP|Rsync|
|---|---|---|
|**Transfert différentiel**|❌ Copie tout|✅ Uniquement les changements|
|**Reprise sur erreur**|❌ Recommence à zéro|✅ Reprend où c'était arrêté|
|**Compression**|❌ Non|✅ Oui (optionnelle)|
|**Synchronisation**|❌ Copie simple|✅ Miroir exact possible|
|**Exclusions**|❌ Limitées|✅ Patterns avancés|
|**Vitesse (mise à jour)**|🐌 Lente|🚀 Très rapide|
|**Bande passante**|📊 Élevée|📉 Optimisée|

### Bénéfices principaux

**🔍 Transfert différentiel intelligent**

- Analyse les fichiers source et destination
- Transfère uniquement les blocs de données modifiés
- Économise bande passante et temps

**🔄 Synchronisation bidirectionnelle**

- Maintient deux répertoires identiques
- Supprime les fichiers supprimés (option)
- Préserve permissions, timestamps, liens symboliques

**💾 Économie de ressources**

- Compression à la volée (option `-z`)
- Bande passante limitée (option `--bwlimit`)
- Transfert incrémental pour sauvegardes

**🛡️ Fiabilité**

- Reprise automatique après interruption
- Vérification de l'intégrité
- Gestion des erreurs robuste

> [!tip] Cas d'usage idéal Si vous devez synchroniser 100 Go de données quotidiennement, SCP retransférera les 100 Go à chaque fois. Rsync ne transférera que les quelques Mo réellement modifiés !

---

## 🔧 Syntaxe avec SSH

### Syntaxe de base

```bash
rsync [OPTIONS] source destination
```

### Utilisation avec SSH

Par défaut, rsync utilise SSH pour les transferts distants. La syntaxe est similaire à SCP :

```bash
# Copier du local vers distant
rsync -avz /chemin/local/ utilisateur@hote:/chemin/distant/

# Copier du distant vers local
rsync -avz utilisateur@hote:/chemin/distant/ /chemin/local/

# Entre deux machines distantes (via l'hôte local)
rsync -avz utilisateur1@hote1:/source/ utilisateur2@hote2:/destination/
```

### Options SSH personnalisées

```bash
# Spécifier un port SSH différent
rsync -avz -e "ssh -p 2222" /local/ user@host:/distant/

# Utiliser une clé SSH spécifique
rsync -avz -e "ssh -i ~/.ssh/ma_cle" /local/ user@host:/distant/

# Options SSH multiples
rsync -avz -e "ssh -p 2222 -i ~/.ssh/ma_cle -o StrictHostKeyChecking=no" /local/ user@host:/distant/
```

### Options essentielles

|Option|Description|Utilité|
|---|---|---|
|`-a`|Mode archive|Préserve permissions, timestamps, liens symboliques, propriétaires|
|`-v`|Verbose|Affiche la progression détaillée|
|`-z`|Compression|Compresse les données pendant le transfert|
|`-h`|Human-readable|Tailles lisibles (Ko, Mo, Go)|
|`-P`|Progress + Partial|Barre de progression + reprise possible|
|`-n`|Dry-run|Simule sans rien modifier|
|`--delete`|Suppression|Supprime fichiers absents de la source|

> [!example] Commande complète recommandée
> 
> ```bash
> rsync -avzhP /local/ user@host:/distant/
> ```
> 
> Cette commande combine : archive, verbose, compression, human-readable et progress.

> [!warning] Attention au slash final !
> 
> - `/source/` → Copie le **contenu** du répertoire
> - `/source` → Copie le **répertoire lui-même**
> 
> ```bash
> rsync -avz /data/ user@host:/backup/
> # Résultat : /backup/fichier1, /backup/fichier2
> 
> rsync -avz /data user@host:/backup/
> # Résultat : /backup/data/fichier1, /backup/data/fichier2
> ```

---

## 📁 Synchronisation de répertoires

### Synchronisation simple

```bash
# Synchroniser un répertoire local vers distant
rsync -avz --delete ~/Documents/ user@server:/backup/Documents/
```

> [!info] L'option `--delete` Supprime sur la destination les fichiers qui n'existent plus dans la source. Cela crée un miroir exact.

### Synchronisation sélective

**Exclure des fichiers ou répertoires**

```bash
# Exclure un pattern
rsync -avz --exclude='*.tmp' --exclude='cache/' /source/ user@host:/dest/

# Exclure depuis un fichier
rsync -avz --exclude-from='exclusions.txt' /source/ user@host:/dest/
```

**Fichier `exclusions.txt` exemple :**

```
*.log
*.tmp
.git/
node_modules/
__pycache__/
.DS_Store
```

**Inclure uniquement certains fichiers**

```bash
# Synchroniser uniquement les fichiers .pdf
rsync -avz --include='*.pdf' --exclude='*' /source/ user@host:/dest/

# Inclure plusieurs types
rsync -avz --include='*.pdf' --include='*.docx' --exclude='*' /source/ user@host:/dest/
```

> [!tip] Ordre des règles Les règles `--include` et `--exclude` sont évaluées dans l'ordre. Mettez les inclusions avant les exclusions !

### Synchronisation bidirectionnelle

Rsync seul ne fait pas de synchronisation bidirectionnelle automatique, mais vous pouvez la simuler :

```bash
# Pousser les changements locaux vers distant
rsync -avz --delete ~/projet/ user@server:~/projet/

# Puis récupérer les changements distants
rsync -avz --delete user@server:~/projet/ ~/projet/
```

> [!warning] Risque de perte de données La synchronisation bidirectionnelle manuelle peut entraîner des pertes si des modifications ont été faites des deux côtés. Pour une vraie bidirectionnelle, considérez des outils comme `unison` ou `syncthing`.

### Limitation de bande passante

```bash
# Limiter à 1000 Ko/s (1 Mo/s)
rsync -avz --bwlimit=1000 /source/ user@host:/dest/

# Limiter à 500 Ko/s
rsync -avz --bwlimit=500 /source/ user@host:/dest/
```

> [!tip] Utilité de --bwlimit Utile pour ne pas saturer la connexion lors de transferts sur des liens partagés ou pendant les heures de travail.

### Mode dry-run (simulation)

```bash
# Voir ce qui serait transféré sans rien modifier
rsync -avzn --delete /source/ user@host:/dest/

# Avec plus de détails
rsync -avzni --delete /source/ user@host:/dest/
```

> [!example] Codes de changement avec `-i`
> 
> - `>f+++++++++` : Nouveau fichier
> - `>f.st......` : Fichier modifié (size/time)
> - `*deleting` : Fichier à supprimer
> - `cd+++++++++` : Nouveau répertoire

---

## 💾 Options de sauvegarde

### Sauvegarde simple avec horodatage

```bash
# Créer une sauvegarde avec date
BACKUP_DATE=$(date +%Y-%m-%d_%H-%M-%S)
rsync -avz /donnees/ user@backup:/sauvegardes/backup_$BACKUP_DATE/
```

### Sauvegardes incrémentales avec hard links

Les hard links permettent de créer des sauvegardes incrémentales qui ne dupliquent pas les fichiers inchangés :

```bash
# Première sauvegarde complète
rsync -avz /source/ user@backup:/backups/2024-01-15/

# Sauvegardes incrémentales suivantes
rsync -avz --link-dest=/backups/2024-01-15/ /source/ user@backup:/backups/2024-01-16/
rsync -avz --link-dest=/backups/2024-01-16/ /source/ user@backup:/backups/2024-01-17/
```

> [!info] Fonctionnement de --link-dest
> 
> - Compare avec la sauvegarde précédente
> - Fichiers identiques → hard link (pas de duplication)
> - Fichiers modifiés → nouvelle copie
> - Résultat : chaque sauvegarde semble complète mais n'utilise que l'espace des changements

**Script de sauvegarde incrémentale automatique :**

```bash
#!/bin/bash

SOURCE="/donnees"
DEST="user@backup:/backups"
BACKUP_DIR="backup_$(date +%Y-%m-%d)"
LATEST="$DEST/latest"

# Créer la nouvelle sauvegarde
rsync -avz --delete --link-dest="$LATEST" "$SOURCE/" "$DEST/$BACKUP_DIR/"

# Mettre à jour le lien symbolique "latest"
ssh user@backup "rm -f /backups/latest && ln -s /backups/$BACKUP_DIR /backups/latest"

echo "Sauvegarde terminée : $BACKUP_DIR"
```

### Option --backup pour conserver les versions

```bash
# Déplacer les fichiers modifiés/supprimés dans un répertoire de backup
rsync -avz --delete --backup --backup-dir=/backup/versions_$(date +%Y-%m-%d) \
  /source/ user@host:/dest/
```

> [!example] Résultat
> 
> - Fichiers actuels dans `/dest/`
> - Anciennes versions dans `/backup/versions_2024-01-15/`

### Rotation des sauvegardes

```bash
#!/bin/bash

DEST="user@backup:/backups"
MAX_BACKUPS=7  # Garder 7 jours

# Supprimer les anciennes sauvegardes
ssh user@backup "cd /backups && ls -t | tail -n +$((MAX_BACKUPS + 1)) | xargs rm -rf"

# Créer la nouvelle sauvegarde
BACKUP_DIR="backup_$(date +%Y-%m-%d)"
rsync -avz --delete --link-dest="$DEST/latest" /donnees/ "$DEST/$BACKUP_DIR/"

# Mettre à jour "latest"
ssh user@backup "rm -f /backups/latest && ln -s /backups/$BACKUP_DIR /backups/latest"
```

### Vérification d'intégrité avec checksums

```bash
# Comparer par checksum plutôt que par taille/date
rsync -avzc /source/ user@host:/dest/
```

> [!warning] Performance L'option `-c` (checksum) est plus lente car elle calcule le checksum de chaque fichier, mais garantit une détection précise des modifications.

### Logs et monitoring

```bash
# Créer un fichier de log détaillé
rsync -avz --log-file=/var/log/rsync_backup.log /source/ user@host:/dest/

# Stats détaillées
rsync -avz --stats /source/ user@host:/dest/

# Exemple de sortie avec --stats :
# Number of files: 1,234
# Number of created files: 45
# Number of deleted files: 12
# Total file size: 15.2G bytes
# Total transferred file size: 234.5M bytes
# Literal data: 234.5M bytes
# Speedup is 64.85
```

---

## ⚠️ Pièges courants

### 1. Le slash final qui change tout

> [!warning] Erreur fréquente
> 
> ```bash
> # DIFFÉRENT !
> rsync -avz /data user@host:/backup    # Crée /backup/data/
> rsync -avz /data/ user@host:/backup   # Copie dans /backup/
> ```

**Règle mnémotechnique :** Le slash final signifie "le contenu de", sans slash c'est "le répertoire lui-même".

### 2. Oublier --delete en mode miroir

```bash
# MAUVAIS : les fichiers supprimés localement restent sur distant
rsync -avz /source/ user@host:/dest/

# BON : miroir exact
rsync -avz --delete /source/ user@host:/dest/
```

### 3. Ordre des règles include/exclude

```bash
# MAUVAIS : exclut tout avant d'inclure
rsync -avz --exclude='*' --include='*.pdf' /source/ user@host:/dest/

# BON : inclut d'abord, puis exclut le reste
rsync -avz --include='*.pdf' --exclude='*' /source/ user@host:/dest/
```

### 4. Permissions insuffisantes

```bash
# Si erreur "permission denied" sur destination
# S'assurer que l'utilisateur SSH a les droits d'écriture

# Solution : utiliser sudo sur la destination
rsync -avz --rsync-path="sudo rsync" /source/ user@host:/dest/
```

### 5. Ne pas tester avec --dry-run

> [!tip] Toujours tester d'abord
> 
> ```bash
> # Simuler d'abord
> rsync -avzn --delete /source/ user@host:/dest/
> 
> # Si tout est OK, exécuter réellement
> rsync -avz --delete /source/ user@host:/dest/
> ```

### 6. Espaces dans les chemins

```bash
# Échapper les espaces
rsync -avz "/mon dossier/source/" user@host:"/backup/destination/"

# Ou utiliser des guillemets
rsync -avz '/mon dossier/source/' 'user@host:/backup/destination/'
```

---

## 🎓 Astuces avancées

### Afficher la progression globale

```bash
# Barre de progression + statistiques
rsync -avz --info=progress2 /source/ user@host:/dest/

# Exemple de sortie :
# 1.24G  45%  123.45MB/s    0:00:15
```

### Synchroniser uniquement les fichiers récents

```bash
# Fichiers modifiés dans les 7 derniers jours
find /source -type f -mtime -7 | rsync -avz --files-from=- / user@host:/dest/

# Ou directement :
rsync -avz --files-from=<(find /source -type f -mtime -7) / user@host:/dest/
```

### Exclure les gros fichiers

```bash
# Exclure les fichiers > 100 Mo
rsync -avz --max-size=100m /source/ user@host:/dest/

# Synchroniser uniquement les petits fichiers < 10 Mo
rsync -avz --max-size=10m /source/ user@host:/dest/
```

### Transférer avec conservation des attributs étendus

```bash
# Conserver les ACL et attributs étendus (Linux)
rsync -avzAX /source/ user@host:/dest/

# -A : ACLs
# -X : Extended attributes
```

### Rsync via un jump host

```bash
# Via un bastion/jump host
rsync -avz -e "ssh -J user@bastion" /local/ user@target:/dest/
```

### Paralléliser avec plusieurs connexions SSH

Pour de très gros transferts, diviser en plusieurs processus :

```bash
#!/bin/bash

# Liste des sous-répertoires
for dir in /source/*/; do
  rsync -avz "$dir" user@host:/dest/ &
done

wait  # Attendre que tous les rsync se terminent
```

> [!warning] Attention Cela augmente la charge réseau et CPU. À utiliser avec modération !

### Monitoring en temps réel

```bash
# Avec watch pour rafraîchir l'affichage
watch -n 1 'rsync -avz --stats --dry-run /source/ user@host:/dest/ | tail -20'

# Ou avec progress personnalisé
rsync -avz --info=progress2,stats2 /source/ user@host:/dest/
```

### Créer un alias pour les sauvegardes courantes

```bash
# Dans ~/.bashrc ou ~/.zshrc
alias backup-home='rsync -avz --delete --exclude=".cache" --exclude="Downloads" ~/ user@backup:/backups/home/'
alias backup-docs='rsync -avzP ~/Documents/ user@backup:/backups/documents/'

# Utilisation
backup-home
backup-docs
```

### Rsync avec notification à la fin

```bash
rsync -avz /source/ user@host:/dest/ && \
  notify-send "Rsync terminé" "La synchronisation est complète" || \
  notify-send "Rsync échoué" "Erreur durant la synchronisation"
```

---

> [!tip] 💡 Résumé des commandes essentielles
> 
> **Synchronisation basique :**
> 
> ```bash
> rsync -avzP /local/ user@host:/distant/
> ```
> 
> **Miroir exact (avec suppression) :**
> 
> ```bash
> rsync -avz --delete /source/ user@host:/dest/
> ```
> 
> **Sauvegarde incrémentale :**
> 
> ```bash
> rsync -avz --link-dest=/backup/previous/ /source/ user@host:/backup/current/
> ```
> 
> **Test avant exécution :**
> 
> ```bash
> rsync -avzn --delete /source/ user@host:/dest/
> ```

---

**🎯 Points clés à retenir :**

1. ✅ **Rsync = efficacité** : Transfert uniquement les différences
2. ✅ **Slash final = comportement différent** : Avec slash = contenu, sans slash = répertoire
3. ✅ **--delete pour miroir exact** : Synchronise vraiment (supprime aussi)
4. ✅ **--link-dest pour sauvegardes** : Économise de l'espace disque
5. ✅ **Toujours tester avec -n** : Dry-run avant exécution réelle
6. ✅ **-avzP = combinaison gagnante** : Archive, verbose, compression, progress