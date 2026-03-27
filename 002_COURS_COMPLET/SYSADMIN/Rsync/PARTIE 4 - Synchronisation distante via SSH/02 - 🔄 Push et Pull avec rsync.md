

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

## 🎯 Comprendre les concepts Push et Pull

> [!info] Définitions
> - **Push** : Vous **envoyez** des données depuis votre machine locale vers un serveur distant
> - **Pull** : Vous **récupérez** des données depuis un serveur distant vers votre machine locale

La différence entre push et pull dans rsync dépend uniquement de **l'emplacement de la source et de la destination** dans la commande. C'est aussi simple que ça !

```bash
# PUSH : source locale → destination distante
rsync [options] /source/locale/ utilisateur@serveur:/destination/distante/

# PULL : source distante → destination locale
rsync [options] utilisateur@serveur:/source/distante/ /destination/locale/
```

> [!tip] Mnémotechnique
> - **Push** = "Je pousse mes fichiers vers le serveur"
> - **Pull** = "Je tire les fichiers depuis le serveur"

---

## 📤 Envoi vers serveur distant (Push)

### Syntaxe du Push

```bash
rsync [options] /chemin/source/ utilisateur@serveur_distant:/chemin/destination/
```

**Éléments de la commande :**
- `/chemin/source/` : répertoire local que vous voulez envoyer
- `utilisateur@serveur_distant` : compte utilisateur et adresse du serveur
- `:/chemin/destination/` : emplacement sur le serveur distant

### Exemples pratiques de Push

#### Push simple avec options de base

```bash
# Envoi d'un dossier de projet vers un serveur
rsync -avh /home/user/projet/ admin@192.168.1.100:/backup/projet/

# Avec compression pour économiser la bande passante
rsync -avzh /home/user/documents/ backup@server.example.com:/backups/documents/

# Avec affichage de la progression
rsync -avh --progress /var/www/html/ webmaster@webserver:/var/www/html/
```

#### Push avec synchronisation complète

```bash
# Synchronisation exacte (supprime les fichiers en trop sur le serveur)
rsync -avh --delete /home/user/photos/ admin@nas.local:/storage/photos/

# Push avec exclusions
rsync -avh --exclude='*.tmp' --exclude='.cache/' \
  /home/user/workspace/ dev@devserver:/home/dev/workspace/
```

> [!example] Cas d'usage typique : Déploiement d'application web
> ```bash
> # Déploiement du code source vers un serveur web
> rsync -avz --delete \
>   --exclude='node_modules/' \
>   --exclude='.git/' \
>   --exclude='*.log' \
>   /home/dev/mon-app/ webadmin@prod-server:/var/www/mon-app/
> ```
> Cette commande envoie l'application en excluant les dépendances et fichiers inutiles.

### Push avec test préalable

> [!warning] Toujours tester avant un push important
> Utilisez `--dry-run` pour simuler le transfert sans modifier le serveur distant.

```bash
# Simulation du push
rsync -avh --dry-run --delete /source/locale/ user@server:/destination/

# Si le résultat est satisfaisant, relancez sans --dry-run
rsync -avh --delete /source/locale/ user@server:/destination/
```

### Push avec limitation de bande passante

```bash
# Limiter à 1000 Ko/s pour ne pas saturer la connexion
rsync -avh --bwlimit=1000 /gros/fichiers/ user@server:/backup/

# Push pendant les heures creuses (à combiner avec cron)
rsync -avzh --bwlimit=5000 /data/videos/ backup@nas:/videos/
```

---

## 📥 Récupération depuis serveur distant (Pull)

### Syntaxe du Pull

```bash
rsync [options] utilisateur@serveur_distant:/chemin/source/ /chemin/destination/
```

**Éléments de la commande :**
- `utilisateur@serveur_distant` : compte utilisateur et adresse du serveur
- `:/chemin/source/` : répertoire distant que vous voulez récupérer
- `/chemin/destination/` : emplacement local où copier les données

### Exemples pratiques de Pull

#### Pull simple

```bash
# Récupération d'une sauvegarde depuis un serveur
rsync -avh backup@server:/backups/database/ /home/user/restore/

# Récupération avec compression
rsync -avzh admin@nas.local:/shared/documents/ /home/user/documents/

# Pull avec progression
rsync -avh --progress user@remote:/var/log/ /tmp/logs-analysis/
```

#### Pull sélectif

```bash
# Récupérer uniquement certains types de fichiers
rsync -avh --include='*.pdf' --exclude='*' \
  user@server:/documents/ /home/user/pdf-only/

# Récupérer en excluant certains dossiers
rsync -avh --exclude='cache/' --exclude='temp/' \
  admin@server:/var/www/site/ /home/user/site-backup/
```

> [!example] Cas d'usage typique : Récupération de logs
> ```bash
> # Récupérer les logs du jour depuis un serveur
> rsync -avh --include='*.log' \
>   --include='*/' \
>   --exclude='*' \
>   sysadmin@webserver:/var/log/ /home/admin/logs-$(date +%Y%m%d)/
> ```
> Récupère uniquement les fichiers .log en préservant la structure des dossiers.

### Pull avec synchronisation miroir

```bash
# Créer un miroir local exact du serveur distant
rsync -avh --delete user@server:/data/important/ /backup/local-mirror/

# Pull d'un site web complet
rsync -avzh --delete webmaster@prod:/var/www/html/ /home/dev/site-local/
```

### Pull partiel et reprise

```bash
# Récupération avec reprise en cas d'interruption
rsync -avh --partial --progress \
  user@server:/gros-fichiers/ /home/user/telechargements/

# Pull avec timeout pour connexions instables
rsync -avh --timeout=300 --partial \
  backup@distant:/archives/ /local/backup/
```

---

## 🧭 Choix de la direction

### Quand utiliser le Push ?

| Situation | Raison |
|-----------|--------|
| **Sauvegarde locale → serveur** | Protéger vos données en les envoyant vers un espace de stockage distant |
| **Déploiement d'application** | Envoyer du code depuis votre environnement de développement vers production |
| **Upload de fichiers produits** | Transférer des fichiers générés localement vers un serveur de partage |
| **Initialisation d'un serveur** | Configurer un nouveau serveur avec des fichiers depuis votre poste |

> [!tip] Le Push est idéal quand...
> - Vous avez les données les plus récentes sur votre machine
> - Vous voulez contrôler précisément ce qui est envoyé
> - Vous gérez le déploiement depuis votre poste de travail

### Quand utiliser le Pull ?

| Situation | Raison |
|-----------|--------|
| **Récupération de sauvegardes** | Ramener des données sauvegardées sur un serveur vers votre machine locale |
| **Synchronisation descendante** | Récupérer des mises à jour depuis un serveur de référence |
| **Analyse de données** | Télécharger des logs ou données pour analyse locale |
| **Restauration après incident** | Récupérer des fichiers depuis un backup distant |

> [!tip] Le Pull est idéal quand...
> - Les données de référence sont sur le serveur distant
> - Vous voulez récupérer des sauvegardes
> - Vous analysez des données distantes localement
> - Vous restaurez après un incident

### Critères de décision

```bash
# Question : Où sont les données les plus à jour ?
# → Sur ma machine locale ? → PUSH
# → Sur le serveur distant ? → PULL

# Question : Quel est mon objectif ?
# → Sauvegarder/déployer mes fichiers → PUSH
# → Récupérer/restaurer des fichiers → PULL
```

> [!warning] Attention à la direction avec --delete
> L'option `--delete` supprime les fichiers qui n'existent pas dans la SOURCE.
> ```bash
> # DANGER : Ceci supprimera vos fichiers locaux absents du serveur !
> rsync -avh --delete user@server:/old-backup/ /home/user/important/
> 
> # CORRECT : Ceci synchronise le serveur avec votre version locale
> rsync -avh --delete /home/user/important/ user@server:/backup/
> ```

---

## ⚖️ Comparaison Push vs Pull

### Tableau récapitulatif

| Critère | Push | Pull |
|---------|------|------|
| **Direction** | Local → Distant | Distant → Local |
| **Source** | Machine locale | Serveur distant |
| **Destination** | Serveur distant | Machine locale |
| **Cas typique** | Sauvegarde, déploiement | Restauration, récupération |
| **Contrôle** | Depuis votre machine | Depuis votre machine |
| **Bande passante** | Upload | Download |

### Exemples côte à côte

```bash
# PUSH : Envoyer mes photos vers le NAS
rsync -avh /home/user/Photos/ user@nas:/Backup/Photos/

# PULL : Récupérer les photos depuis le NAS
rsync -avh user@nas:/Backup/Photos/ /home/user/Photos/
```

```bash
# PUSH : Déployer le site web
rsync -avzh --delete /var/www/local/ web@prod:/var/www/html/

# PULL : Récupérer le site de prod pour debug
rsync -avzh --delete web@prod:/var/www/html/ /var/www/local/
```

### Combinaison Push et Pull

Dans certains scénarios, vous utiliserez les deux :

```bash
# 1. PULL : Récupérer la dernière version de prod
rsync -avzh prod@server:/var/www/app/ /home/dev/app-local/

# 2. Modifications locales...

# 3. PUSH : Renvoyer les modifications vers prod
rsync -avzh --delete /home/dev/app-local/ prod@server:/var/www/app/
```

---

## ⚠️ Pièges courants

### 1. Confusion de direction avec --delete

> [!warning] Danger avec --delete
> ```bash
> # ERREUR : Vous allez ÉCRASER vos fichiers locaux avec la version distante !
> rsync -avh --delete user@old-server:/outdated/ /home/user/current/
> 
> # CORRECT : Synchroniser le serveur avec votre version locale
> rsync -avh --delete /home/user/current/ user@server:/backup/
> ```

### 2. Oubli du slash final

```bash
# PUSH sans slash : crée un sous-dossier "data" dans /backup/
rsync -avh /home/user/data user@server:/backup/
# Résultat : /backup/data/

# PUSH avec slash : copie le CONTENU dans /backup/
rsync -avh /home/user/data/ user@server:/backup/
# Résultat : /backup/fichier1, /backup/fichier2, etc.
```

### 3. Permissions insuffisantes

```bash
# PUSH : Vérifier les droits d'écriture sur le serveur distant
# Si erreur "Permission denied"
rsync -avh /local/ user@server:/root/backup/  # ❌ user n'a pas accès à /root/

# Solution : utiliser un chemin accessible
rsync -avh /local/ user@server:/home/user/backup/  # ✅
```

### 4. Chemins relatifs vs absolus

> [!tip] Bonnes pratiques
> - Utilisez des **chemins absolus** pour éviter les confusions
> - Si vous utilisez des chemins relatifs, vérifiez votre répertoire courant avec `pwd`

```bash
# RELATIF : dépend de votre position actuelle
rsync -avh ./documents/ user@server:~/backup/  # Depuis où ? ⚠️

# ABSOLU : aucune ambiguïté
rsync -avh /home/user/documents/ user@server:/home/user/backup/  # ✅
```

### 5. Test insuffisant avant --delete

> [!warning] Règle d'or
> Toujours faire un `--dry-run` avant d'utiliser `--delete` !

```bash
# 1. Simuler d'abord
rsync -avh --dry-run --delete /source/ user@server:/dest/

# 2. Vérifier la sortie attentivement

# 3. Exécuter seulement si satisfait
rsync -avh --delete /source/ user@server:/dest/
```

---

## 💡 Astuces

### Astuce 1 : Créer des alias pour Push/Pull fréquents

```bash
# Dans ~/.bashrc ou ~/.bash_aliases
alias push-photos='rsync -avzh --progress ~/Photos/ nas@192.168.1.10:/Backup/Photos/'
alias pull-docs='rsync -avzh --progress nas@192.168.1.10:/Documents/ ~/Documents-Backup/'

# Utilisation
push-photos
pull-docs
```

### Astuce 2 : Vérifier avant d'écraser

```bash
# Comparer source et destination avant le transfert
rsync -avhn --delete /source/ user@server:/dest/ | grep "^deleting"

# Si des fichiers seraient supprimés, réfléchir à deux fois !
```

### Astuce 3 : Push/Pull avec exclusions standard

```bash
# Créer un fichier d'exclusions réutilisable
cat > ~/.rsync-exclude << 'EOF'
.git/
node_modules/
*.tmp
*.log
.cache/
EOF

# Utiliser dans vos commandes
rsync -avh --exclude-from=~/.rsync-exclude /projet/ user@server:/backup/
```

### Astuce 4 : Push conditionnel

```bash
# Ne pusher que si la source a changé (script)
#!/bin/bash
SOURCE="/home/user/data/"
DEST="backup@server:/backup/data/"
CHECKSUM_FILE="/tmp/rsync-checksum"

# Calculer checksum de la source
CURRENT=$(find "$SOURCE" -type f -exec md5sum {} \; | sort | md5sum)

# Comparer avec le dernier push
if [ -f "$CHECKSUM_FILE" ]; then
    LAST=$(cat "$CHECKSUM_FILE")
    if [ "$CURRENT" = "$LAST" ]; then
        echo "Aucun changement, push annulé"
        exit 0
    fi
fi

# Push et sauvegarder le checksum
rsync -avzh --delete "$SOURCE" "$DEST" && echo "$CURRENT" > "$CHECKSUM_FILE"
```

### Astuce 5 : Notification après Pull/Push

```bash
# Avec notification système (Linux)
rsync -avzh /source/ user@server:/dest/ && \
  notify-send "Rsync" "Synchronisation terminée avec succès"

# Avec envoi d'email (nécessite mailutils)
rsync -avzh user@server:/backup/ /local/ && \
  echo "Pull terminé $(date)" | mail -s "Backup OK" admin@example.com
```

---

> [!tip] Résumé des bonnes pratiques
> - ✅ Utilisez `--dry-run` avant toute commande importante
> - ✅ Préférez les chemins absolus aux chemins relatifs
> - ✅ Testez vos commandes sur de petits ensembles avant les gros transferts
> - ✅ Documentez vos commandes Push/Pull dans des scripts commentés
> - ✅ Vérifiez toujours que vous pushez/pullez dans la bonne direction avec `--delete`