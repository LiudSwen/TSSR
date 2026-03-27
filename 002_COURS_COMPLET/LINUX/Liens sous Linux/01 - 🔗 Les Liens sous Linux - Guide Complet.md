
## 📑 Table des matières

```table-of-contents
```toc
minLevel: 2
maxLevel: 2
```
---

## 📖 Introduction aux liens

> [!info] Qu'est-ce qu'un lien ? Un lien sous Linux est un mécanisme permettant d'accéder à un même fichier depuis plusieurs emplacements différents. C'est comme avoir plusieurs "portes d'entrée" vers le même contenu.

### Pourquoi utiliser des liens ?

- **Organisation** : Accéder à un fichier depuis plusieurs emplacements sans duplication
- **Maintenance** : Faciliter les mises à jour et la gestion des versions
- **Compatibilité** : Maintenir des chemins pour des applications legacy
- **Économie d'espace** : Éviter la duplication de gros fichiers

### Les deux types de liens

Linux propose deux types de liens fondamentalement différents :

1. **Liens physiques (hard links)** : Plusieurs noms pour le même contenu sur le disque
2. **Liens symboliques (soft links/symlinks)** : Raccourcis pointant vers un chemin

---

## 🔨 Les liens physiques (hard links)

### Concept et fonctionnement

> [!info] Comprendre les inodes Sous Linux, chaque fichier est identifié par un numéro unique appelé **inode**. L'inode contient toutes les métadonnées du fichier (permissions, dates, emplacement sur le disque) SAUF le nom du fichier.

Un lien physique est simplement un nom de fichier supplémentaire qui pointe vers le même inode. Tous les liens physiques d'un fichier sont **égaux** - il n'y a pas de "original" et de "copie".

```
┌─────────────┐
│   Inode     │
│   123456    │ ← Données réelles sur le disque
│             │
└─────────────┘
      ↑   ↑
      │   │
   ┌──┘   └──┐
   │         │
fichier1  fichier2  ← Deux noms différents, même inode
```

### Création de liens physiques

#### Syntaxe de base

```bash
ln FICHIER_SOURCE LIEN_CIBLE
```

> [!warning] Attention à l'ordre Contrairement à `cp`, l'ordre est : SOURCE puis CIBLE (comme `cp`)

#### Exemples pratiques

```bash
# Créer un lien physique simple
ln /home/user/document.txt /home/user/backup/document.txt

# Le fichier est maintenant accessible via deux chemins
# Modifier l'un modifie automatiquement l'autre

# Créer un lien dans le répertoire courant
ln /etc/hosts hosts_backup

# Créer plusieurs liens vers le même fichier
ln important.txt version1.txt
ln important.txt version2.txt
```

### Caractéristiques et limitations

> [!example] Caractéristiques des liens physiques
> 
> - **Même inode** : Tous les liens partagent le même numéro d'inode
> - **Compteur de liens** : Le système compte combien de noms pointent vers l'inode
> - **Suppression** : Le contenu n'est effacé que lorsque tous les liens sont supprimés
> - **Permissions identiques** : Modifier les permissions sur un lien les modifie pour tous
> - **Même propriétaire** : Tous les liens ont le même propriétaire et groupe

#### Limitations importantes

> [!warning] Contraintes des liens physiques
> 
> 1. **Impossible entre systèmes de fichiers** : Source et cible doivent être sur la même partition
> 2. **Impossible pour les répertoires** : Seuls les fichiers peuvent avoir des liens physiques (sauf `.` et `..`)
> 3. **Pas de lien vers un lien symbolique** : On lie directement le fichier cible

```bash
# ❌ ERREUR : Impossible entre partitions différentes
ln /home/user/file.txt /mnt/usb/file.txt
# ln: échec de création du lien: Lien croisé de périphérique invalide

# ❌ ERREUR : Impossible pour un répertoire
ln /home/user/dossier /tmp/lien_dossier
# ln: /home/user/dossier: hard link not allowed for directory
```

---

## 🔗 Les liens symboliques (soft links)

### Concept et fonctionnement

> [!info] Qu'est-ce qu'un lien symbolique ? Un lien symbolique est un **fichier spécial** qui contient le chemin vers un autre fichier ou répertoire. C'est comme un raccourci Windows ou un alias macOS.

Contrairement aux liens physiques, un lien symbolique :

- A son propre inode
- Contient juste un chemin (texte)
- Peut "casser" si la cible est supprimée

```
┌─────────────┐
│   Inode     │
│   123456    │ ← Fichier original
│ fichier.txt │
└─────────────┘
       ↑
       │ pointe vers
       │
┌─────────────┐
│   Inode     │
│   789012    │ ← Lien symbolique (fichier spécial)
│  "→ chemin" │
└─────────────┘
   lien.txt
```

### Création de liens symboliques

#### Syntaxe de base

```bash
ln -s FICHIER_SOURCE LIEN_CIBLE
```

> [!tip] L'option `-s` est essentielle Sans `-s`, `ln` crée un lien physique. Avec `-s`, il crée un lien symbolique (symbolic).

#### Exemples pratiques

```bash
# Lien symbolique simple
ln -s /home/user/document.txt document_lien.txt

# Lien vers un répertoire
ln -s /var/www/html/site1 ~/raccourci_site

# Lien avec chemin absolu (recommandé)
ln -s /opt/application/config.conf /etc/app/config.conf

# Lien avec chemin relatif
cd /home/user
ln -s ../shared/fichier.txt mon_lien.txt

# Créer un lien symbolique en forçant l'écrasement
ln -sf /new/target existing_link
```

#### Chemins absolus vs relatifs

> [!warning] Choix du type de chemin **Chemin absolu** : Le lien fonctionne depuis n'importe où **Chemin relatif** : Le lien ne fonctionne que par rapport à son emplacement

```bash
# CHEMIN ABSOLU (recommandé pour la plupart des cas)
ln -s /home/user/data/file.txt /tmp/link.txt
# Le lien fonctionne toujours, peu importe où on est

# CHEMIN RELATIF (utile pour des structures déplaçables)
cd /home/user/projet
ln -s ../shared/library.so lib/library.so
# Le lien fonctionne tant que la structure relative est préservée
```

### Caractéristiques et spécificités

> [!example] Caractéristiques des liens symboliques
> 
> - **Inode différent** : Le lien a son propre inode
> - **Taille** : La taille du lien = longueur du chemin qu'il contient
> - **Permissions** : Les permissions du lien sont ignorées, celles de la cible comptent
> - **Fonctionne entre partitions** : Peut pointer n'importe où
> - **Fonctionne pour les répertoires** : Pas de limitation

#### Le concept de "lien cassé"

> [!warning] Liens symboliques cassés (broken links) Si le fichier cible est supprimé ou déplacé, le lien symbolique devient **cassé** mais continue d'exister. C'est un des pièges les plus courants.

```bash
# Créer un fichier et son lien
echo "contenu" > original.txt
ln -s original.txt lien.txt

# Supprimer l'original
rm original.txt

# Le lien existe toujours mais est cassé
ls -l lien.txt
# lrwxrwxrwx 1 user user 12 Nov 23 10:00 lien.txt -> original.txt

# Essayer de lire le lien cassé génère une erreur
cat lien.txt
# cat: lien.txt: Aucun fichier ou dossier de ce type
```

---

## ⚖️ Comparaison liens physiques vs symboliques

|Critère|Lien physique|Lien symbolique|
|---|---|---|
|**Inode**|Même inode que l'original|Inode différent|
|**Contenu**|Pointe vers les données|Contient un chemin|
|**Répertoires**|❌ Impossible|✅ Possible|
|**Entre partitions**|❌ Impossible|✅ Possible|
|**Suppression source**|✅ Les données restent|❌ Lien cassé|
|**Taille**|Taille du fichier|Taille du chemin|
|**Permissions**|Identiques partout|Celles de la cible comptent|
|**Détection**|Difficile à distinguer|Facilement visible (type `l`)|
|**Performance**|Légèrement plus rapide|Nécessite une résolution|

> [!tip] Quand utiliser quoi ? **Liens physiques** : Sauvegardes, versioning, fichiers critiques ne devant pas "casser" **Liens symboliques** : Raccourcis, organisation, liens entre partitions, répertoires

---

## 🔍 Commandes de vérification et d'analyse

### Identifier le type de lien avec `ls`

```bash
# Affichage détaillé avec ls -l
ls -l fichier.txt
# -rw-r--r-- 2 user user 1024 Nov 23 10:00 fichier.txt
#            ↑ Compteur de liens (2 = 1 original + 1 hard link)

ls -l lien_symbolique
# lrwxrwxrwx 1 user user 12 Nov 23 10:00 lien_symbolique -> fichier.txt
# ↑ Type 'l' = lien symbolique
# La flèche -> indique la cible
```

> [!info] Comprendre la première colonne de `ls -l`
> 
> - `-` : Fichier ordinaire
> - `d` : Répertoire
> - `l` : Lien symbolique
> - Le chiffre après les permissions = nombre de liens physiques

### Afficher les inodes avec `ls -i`

```bash
# Afficher les numéros d'inode
ls -i fichier1.txt fichier2.txt
# 123456 fichier1.txt
# 123456 fichier2.txt  ← Même inode = lien physique

ls -i fichier.txt lien_sym.txt
# 123456 fichier.txt
# 789012 lien_sym.txt  ← Inode différent = lien symbolique
```

### Trouver tous les liens physiques d'un fichier avec `find`

```bash
# Trouver tous les fichiers partageant le même inode
INODE=$(ls -i fichier.txt | awk '{print $1}')
find / -inum $INODE 2>/dev/null

# Ou en une commande
find / -samefile fichier.txt 2>/dev/null

# Rechercher dans un répertoire spécifique
find /home -samefile /home/user/important.txt
```

### Trouver les liens symboliques avec `find`

```bash
# Tous les liens symboliques dans un répertoire
find /home/user -type l

# Liens symboliques pointant vers un fichier spécifique
find /home -lname "*fichier.txt"

# Trouver les liens symboliques cassés
find /home -type l -xtype l

# Trouver et afficher les liens cassés avec leur cible
find . -type l ! -exec test -e {} \; -print
```

### Vérifier la cible d'un lien avec `readlink`

```bash
# Afficher la cible d'un lien symbolique
readlink lien_sym.txt
# /home/user/fichier.txt

# Afficher le chemin absolu résolu (suivre tous les liens)
readlink -f lien_sym.txt
# /home/user/documents/fichier.txt

# Vérifier si un fichier est un lien
readlink lien_sym.txt && echo "C'est un lien" || echo "Pas un lien"
```

### Obtenir des statistiques avec `stat`

```bash
# Informations complètes sur un fichier
stat fichier.txt

# Sortie typique :
#   Fichier : fichier.txt
#   Taille : 1024       Blocs : 8          Blocs d'E/S : 4096
#   Device: 803h/2051d  Inode : 123456     Liens : 2
#                                                    ↑ Nombre de liens physiques
#   Accès : (0644/-rw-r--r--)  Uid : ( 1000/   user)

# Pour un lien symbolique
stat lien_sym.txt
#   Fichier : lien_sym.txt -> fichier.txt
#   Taille : 11  ← Longueur du chemin "fichier.txt"
#   Liens : 1   ← Le lien lui-même
```

### Comparer avec `diff` et liens

```bash
# Comparer deux fichiers (même s'ils sont liés)
diff fichier1.txt fichier2.txt

# Pour les liens physiques, pas de différence (même contenu)
# Pour les liens symboliques, comparer les cibles
diff "$(readlink -f lien1)" "$(readlink -f lien2)"
```

### Commande `file` pour identifier

```bash
# Identifier le type de fichier
file fichier.txt
# fichier.txt: ASCII text

file lien_sym.txt
# lien_sym.txt: symbolic link to fichier.txt
```

---

## 💼 Situations pratiques d'utilisation

### Situation 1 : Gestion de versions de configurations

> [!example] Maintenir plusieurs versions d'un fichier de configuration Vous avez une application qui doit parfois utiliser différentes configurations.

```bash
# Structure de répertoire
/opt/app/
├── config.production.conf
├── config.development.conf
├── config.test.conf
└── config.conf -> config.production.conf  # Lien symbolique actif

# Changer de configuration facilement
cd /opt/app
rm config.conf
ln -s config.development.conf config.conf

# L'application lit toujours config.conf, mais le contenu change
```

### Situation 2 : Partage de bibliothèques système

> [!example] Gestion des versions de bibliothèques partagées Les systèmes Linux utilisent intensivement les liens symboliques pour les bibliothèques.

```bash
# Structure typique dans /lib ou /usr/lib
ls -l /lib/x86_64-linux-gnu/libc.so*
# libc.so.6 -> libc-2.31.so          ← Lien symbolique
# libc-2.31.so                        ← Fichier réel

# Les programmes utilisent libc.so.6
# On peut upgrader la bibliothèque sans recompiler les programmes
```

### Situation 3 : Organisation de l'arborescence web

> [!example] Serveur web avec plusieurs sites Faciliter l'accès aux sites web depuis différents emplacements.

```bash
# Sites réels dans un emplacement
/var/www/sites/
├── site1/
├── site2/
└── site3/

# Liens dans la config Apache/Nginx
ln -s /var/www/sites/site1 /var/www/html/client-a
ln -s /var/www/sites/site2 /var/www/html/client-b

# Facilite la gestion et la maintenance
```

### Situation 4 : Sauvegarde incrémentielle avec liens physiques

> [!example] Système de backup intelligent Les outils comme `rsync` avec `--link-dest` utilisent des liens physiques pour économiser l'espace.

```bash
# Backup complet initial
rsync -a /home/user/ /backup/2024-11-01/

# Backup incrémentiel avec liens physiques
rsync -a --link-dest=/backup/2024-11-01/ /home/user/ /backup/2024-11-02/

# Les fichiers inchangés sont des liens physiques (pas de duplication)
# Seuls les fichiers modifiés occupent de l'espace supplémentaire
```

### Situation 5 : Migration de services

> [!example] Déplacer un service sans casser les dépendances Un service doit être déplacé mais d'autres scripts appellent l'ancien chemin.

```bash
# Ancien emplacement : /usr/local/bin/mon-service
# Nouveau : /opt/services/mon-service/bin/mon-service

# Créer un lien pour maintenir la compatibilité
ln -s /opt/services/mon-service/bin/mon-service /usr/local/bin/mon-service

# Les anciens scripts fonctionnent toujours
# La migration est transparente
```

### Situation 6 : Environnements de développement

> [!example] Basculer entre versions de logiciels Utiliser différentes versions de Node.js, Python, etc.

```bash
# Plusieurs versions installées
/opt/node-14.17.0/
/opt/node-16.13.0/
/opt/node-18.12.0/

# Lien symbolique pour la version active
ln -s /opt/node-18.12.0 /opt/node

# Ajouter /opt/node/bin au PATH
# Changer de version en recréant le lien
rm /opt/node
ln -s /opt/node-16.13.0 /opt/node
```

### Situation 7 : Stockage partagé entre utilisateurs

> [!example] Partager des fichiers volumineux sans duplication Plusieurs utilisateurs doivent accéder aux mêmes données volumineuses.

```bash
# Données centralisées
/data/shared/videos/

# Chaque utilisateur a un lien dans son home
ln -s /data/shared/videos /home/alice/videos
ln -s /data/shared/videos /home/bob/videos

# Un seul exemplaire sur le disque
# Accessible facilement par tous
```

### Situation 8 : Logs système

> [!example] Redirection de logs Déplacer les logs vers une partition dédiée sans modifier les applications.

```bash
# Logs initialement dans /var/log
# Nouvelle partition montée sur /mnt/logs

# Déplacer et lier
mv /var/log /mnt/logs/
ln -s /mnt/logs/log /var/log

# Les applications continuent d'écrire dans /var/log
# Mais les données sont physiquement sur /mnt/logs
```

---

## ⚠️ Pièges courants et bonnes pratiques

### Piège 1 : Suppression accidentelle de la cible

> [!warning] Attention avec `rm` Supprimer un fichier cible casse tous ses liens symboliques.

```bash
# Créer un lien
ln -s important.txt lien.txt

# ❌ ERREUR : Supprimer l'original par mégarde
rm important.txt

# Le lien existe toujours mais est cassé
ls -l lien.txt  # Affiche en rouge dans la plupart des terminaux
cat lien.txt    # Erreur : Aucun fichier ou dossier de ce type
```

**Bonne pratique** : Vérifier les liens avant de supprimer des fichiers importants.

```bash
# Trouver tous les liens symboliques pointant vers un fichier
find / -lname "*important.txt" 2>/dev/null
```

### Piège 2 : Chemins relatifs dans les liens symboliques

> [!warning] Les chemins relatifs peuvent ne pas fonctionner comme prévu

```bash
# Mauvaise pratique
cd /home/user/projet
ln -s data/fichier.txt /tmp/lien.txt

# Le lien cherche : /tmp/data/fichier.txt (n'existe pas !)
# Au lieu de : /home/user/projet/data/fichier.txt

# ✅ Bonne pratique : utiliser des chemins absolus
ln -s /home/user/projet/data/fichier.txt /tmp/lien.txt
```

### Piège 3 : Boucles infinies avec les liens symboliques

> [!warning] Créer des boucles de liens

```bash
# ❌ ERREUR : Créer une boucle
ln -s lienA lienB
ln -s lienB lienA

# Accéder provoque : "Trop de niveaux de liens symboliques"
cat lienA
```

**Bonne pratique** : Toujours vérifier la chaîne de liens avec `readlink -f`.

### Piège 4 : Éditer un lien symbolique

> [!warning] Certains éditeurs remplacent le lien au lieu de modifier la cible

```bash
# Lien : config.txt -> real_config.txt

# Avec vim (par défaut, édite la cible) ✅
vim config.txt

# Avec certains éditeurs ou options, le lien peut être remplacé ❌
# Le lien devient un fichier ordinaire, perdant la connexion à la cible
```

**Bonne pratique** : Éditer directement le fichier cible ou vérifier le comportement de votre éditeur.

### Piège 5 : Liens physiques et systèmes de fichiers

> [!warning] Impossible de créer des liens physiques entre partitions

```bash
# ❌ ERREUR
ln /home/user/file.txt /mnt/usb/file.txt
# ln: échec de création du lien: Lien croisé de périphérique invalide

# ✅ Utiliser un lien symbolique
ln -s /home/user/file.txt /mnt/usb/file.txt
```

### Piège 6 : Permissions des liens symboliques

> [!info] Les permissions d'un lien symbolique sont ignorées Les permissions affichées (généralement `rwxrwxrwx`) n'ont aucun effet. Ce sont celles de la cible qui comptent.

```bash
ls -l lien.txt
# lrwxrwxrwx 1 user user 10 Nov 23 10:00 lien.txt -> file.txt
#  ↑ Ces permissions sont ignorées

# Les vraies permissions sont celles de file.txt
ls -l file.txt
# -rw-r--r-- 1 user user 100 Nov 23 10:00 file.txt
```

### Piège 7 : Déplacer des fichiers avec des liens physiques

> [!warning] Déplacer entre partitions `mv` entre partitions copie le fichier et brise les liens physiques.

```bash
# Liens physiques sur /home
ln file.txt backup.txt
ls -i file.txt backup.txt
# 123456 file.txt
# 123456 backup.txt  ← Même inode

# Déplacer file.txt vers /tmp (autre partition)
mv file.txt /tmp/

ls -i /tmp/file.txt backup.txt
# 789012 /tmp/file.txt   ← Nouvel inode !
# 123456 backup.txt      ← Ancien inode conservé

# Les deux fichiers sont maintenant indépendants
```

### Bonnes pratiques générales

> [!tip] Recommandations professionnelles

1. **Documentation** : Toujours documenter pourquoi et où vous créez des liens
2. **Chemins absolus** : Préférer les chemins absolus pour les liens symboliques critiques
3. **Vérification** : Tester les liens après création avec `readlink` ou `ls -l`
4. **Nettoyage** : Supprimer régulièrement les liens cassés
5. **Sauvegarde** : Les liens symboliques sont sauvegardés comme liens, pas comme copies du contenu
6. **Monitoring** : Surveiller les liens cassés dans les environnements de production

```bash
# Script de vérification des liens cassés
find /opt/applications -type l -xtype l -print > broken_links.txt

# Nettoyage des liens cassés (avec prudence !)
find /tmp -type l -xtype l -delete
```

---

## 📋 Cheat Sheet

### Création de liens

```bash
# Lien physique
ln SOURCE DESTINATION

# Lien symbolique
ln -s SOURCE DESTINATION

# Lien symbolique avec écrasement forcé
ln -sf SOURCE DESTINATION

# Créer un lien vers un répertoire (symbolique seulement)
ln -s /path/to/dir /path/to/link
```

### Vérification et analyse

```bash
# Afficher le type et la cible
ls -l FICHIER

# Afficher l'inode
ls -i FICHIER

# Lire la cible d'un lien symbolique
readlink LIEN

# Résoudre le chemin complet (suivre tous les liens)
readlink -f LIEN

# Informations détaillées
stat FICHIER

# Identifier le type
file FICHIER
```

### Recherche de liens

```bash
# Trouver tous les liens symboliques
find /chemin -type l

# Trouver les liens symboliques cassés
find /chemin -type l -xtype l

# Trouver tous les liens physiques d'un fichier
find /chemin -samefile FICHIER

# Trouver par inode
find /chemin -inum NUMERO_INODE

# Trouver les liens pointant vers un pattern
find /chemin -lname "*pattern*"
```

### Manipulation de liens

```bash
# Supprimer un lien (symbolique ou physique)
rm LIEN
# Note : ne supprime jamais le fichier cible, juste le lien

# Remplacer un lien
rm LIEN && ln -s NOUVELLE_CIBLE LIEN
# Ou en une commande :
ln -sf NOUVELLE_CIBLE LIEN

# Copier en préservant les liens
cp -a SOURCE DEST           # Archive mode (préserve tout)
cp -d SOURCE DEST           # Préserve les liens symboliques

# Synchroniser avec rsync en préservant les liens
rsync -avH SOURCE DEST      # -H préserve les liens physiques
```

### Tests et conditions dans les scripts

```bash
# Tester si un fichier est un lien symbolique
if [ -L "$fichier" ]; then
    echo "C'est un lien symbolique"
fi

# Tester si un lien symbolique existe et pointe vers une cible valide
if [ -e "$lien" ]; then
    echo "Le lien existe et la cible est accessible"
fi

# Tester si un fichier existe (suit les liens)
if [ -f "$fichier" ]; then
    echo "Le fichier existe"
fi

# Obtenir la cible d'un lien
cible=$(readlink -f "$lien")
```

### Commandes utiles complémentaires

```bash
# Compter les liens physiques d'un fichier
stat -c '%h' FICHIER

# Afficher uniquement l'inode
stat -c '%i' FICHIER

# Lister avec indicateurs de type
ls -F
# / = répertoire, @ = lien symbolique, * = exécutable

# Afficher les liens symboliques en couleur
ls -l --color=auto

# Trouver et supprimer les liens cassés (ATTENTION !)
find /chemin -type l -xtype l -delete
```

### Tableau récapitulatif des options principales

|Commande|Option|Description|
|---|---|---|
|`ln`|(aucune)|Crée un lien physique|
|`ln`|`-s`|Crée un lien symbolique|
|`ln`|`-f`|Force l'écrasement|
|`ls`|`-l`|Affiche les détails (type, cible)|
|`ls`|`-i`|Affiche les inodes|
|`find`|`-type l`|Trouve les liens symboliques|
|`find`|`-xtype l`|Trouve les liens cassés|
|`find`|`-samefile`|Trouve les liens physiques|
|`readlink`|(aucune)|Lit la cible d'un lien|
|`readlink`|`-f`|Résout le chemin complet|
|`stat`|`-c '%h'`|Affiche le nombre de liens|
|`stat`|`-c '%i'`|Affiche l'inode|

### Syntaxe rapide pour situations courantes

```bash
# Créer un lien de compatibilité
ln -s /nouveau/chemin /ancien/chemin

# Basculer entre versions
rm /opt/app && ln -s /opt/app-v2.0 /opt/app

# Créer une structure miroir
find /source -type l -exec cp -d {} /destination \;

# Vérifier l'intégrité des liens dans un répertoire
for link in /chemin/*; do
    [ -L "$link" ] && ! [ -e "$link" ] && echo "Cassé: $link"
done

# Créer un backup avec lien physique
cp -l fichier.txt fichier.txt.backup

# Lister uniquement les liens symboliques d'un répertoire
ls -la | grep '^l'

# Afficher la cible de tous les liens d'un répertoire
for link in *; do
    [ -L "$link" ] && echo "$link -> $(readlink $link)"
done
```

### Exemples de scripts utiles

```bash
#!/bin/bash
# Script 1 : Vérifier et réparer les liens cassés

# Trouver tous les liens cassés
echo "Recherche des liens cassés..."
find /home/user -type l -xtype l -print | while read link; do
    echo "Lien cassé trouvé: $link"
    echo "  Pointait vers: $(readlink $link)"
done

# ------------------

#!/bin/bash
# Script 2 : Créer des liens de sauvegarde avec timestamp

SOURCE="/opt/config/app.conf"
BACKUP_DIR="/backup/configs"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

# Créer un lien physique daté
ln "$SOURCE" "$BACKUP_DIR/app.conf.$TIMESTAMP"

# Créer/mettre à jour le lien symbolique "latest"
ln -sf "app.conf.$TIMESTAMP" "$BACKUP_DIR/app.conf.latest"

# ------------------

#!/bin/bash
# Script 3 : Migrer des liens physiques en symboliques

find /chemin -type f -links +1 | while read file; do
    inode=$(stat -c '%i' "$file")
    find /chemin -inum $inode ! -path "$file" | while read link; do
        echo "Conversion: $link"
        rm "$link"
        ln -s "$file" "$link"
    done
done
```

### Mémo des comportements critiques

> [!warning] Comportements à retenir absolument

|Action|Lien physique|Lien symbolique|
|---|---|---|
|Supprimer la source|✅ Les données restent|❌ Lien cassé|
|Modifier la source|✅ Tous les liens voient le changement|✅ Change via le lien|
|Renommer la source|✅ Tous les liens fonctionnent|❌ Lien cassé|
|Déplacer la source (même partition)|✅ Fonctionne|❌ Lien cassé (si chemin relatif)|
|Copier le lien avec `cp`|Copie le fichier|Copie le lien (avec `-d`)|
|Éditer via le lien|Modifie le contenu|Modifie la cible|
|Archiver avec `tar`|Peut dédupliquer|Archive comme lien|

### Commandes de diagnostic avancées

```bash
# Afficher tous les fichiers avec plus d'un lien physique
find /chemin -type f -links +1

# Statistiques sur les liens d'un répertoire
echo "Liens symboliques: $(find /chemin -type l | wc -l)"
echo "Liens cassés: $(find /chemin -type l -xtype l | wc -l)"
echo "Fichiers avec liens multiples: $(find /chemin -type f -links +1 | wc -l)"

# Trouver les fichiers les plus liés
find /chemin -type f -printf '%n %p\n' | sort -rn | head

# Afficher la structure des liens (arbre)
ls -lR /chemin | grep '^l'

# Vérifier si deux fichiers sont le même (même inode)
[ "$(stat -c '%i' file1)" = "$(stat -c '%i' file2)" ] && echo "Même fichier"

# Suivre une chaîne de liens symboliques
file="$1"
while [ -L "$file" ]; do
    echo "$file -> $(readlink $file)"
    file=$(readlink -f "$file")
done
echo "Fichier final: $file"
```

### Options avancées de `find`

```bash
# Liens symboliques modifiés récemment
find /chemin -type l -mtime -7

# Liens symboliques de plus de 100 jours
find /chemin -type l -mtime +100

# Liens pointant vers un répertoire spécifique
find /chemin -type l -lname "/old/path/*"

# Exécuter une commande sur chaque lien trouvé
find /chemin -type l -exec readlink -f {} \;

# Liens avec permissions spécifiques sur la cible
find /chemin -type l -exec test -x {} \; -print

# Trouver les liens circulaires (détection de boucles)
find /chemin -type l -exec bash -c 'readlink -f "$0" &>/dev/null || echo "Boucle: $0"' {} \;
```

### Astuces pour l'administration système

```bash
# Créer une structure de liens pour plusieurs versions
for version in 1.0 1.1 1.2; do
    mkdir -p /opt/app-$version
    ln -s /opt/app-$version /opt/app-v$version
done
ln -s /opt/app-1.2 /opt/app  # Version active

# Rotation de logs avec liens
mv /var/log/app.log /var/log/app.log.1
ln /var/log/app.log.1 /var/log/app.log  # Hard link temporaire
# L'application continue d'écrire dans app.log.1

# Créer des liens pour tous les fichiers d'un répertoire
for file in /source/*; do
    ln -s "$file" /destination/
done

# Remplacer tous les liens d'un répertoire pointant vers un ancien chemin
find /chemin -type l -lname "/old/path/*" -exec sh -c '
    for link; do
        target=$(readlink "$link")
        new_target=$(echo "$target" | sed "s|/old/path|/new/path|")
        ln -sf "$new_target" "$link"
    done
' sh {} +

# Créer un miroir de liens symboliques
cd /source && find . -type l | while read link; do
    mkdir -p "/destination/$(dirname $link)"
    cp -d "$link" "/destination/$link"
done
```

### Cas d'usage avec `rsync` et liens

```bash
# Synchroniser en préservant les liens symboliques
rsync -av --links SOURCE/ DEST/

# Synchroniser en copiant le contenu des liens (pas les liens eux-mêmes)
rsync -av --copy-links SOURCE/ DEST/

# Synchroniser en préservant les liens physiques
rsync -avH SOURCE/ DEST/

# Backup incrémentiel avec liens physiques (économie d'espace)
rsync -av --link-dest=/backup/previous /data/ /backup/current/
```

### Debugging et troubleshooting

```bash
# Tracer l'accès à un lien (avec strace)
strace -e trace=open,openat cat lien.txt 2>&1 | grep lien.txt

# Voir si un processus utilise un lien
lsof | grep nom_du_lien

# Vérifier les permissions effectives via un lien
namei -l /path/to/lien
# Affiche toute la chaîne de répertoires et de liens

# Afficher le chemin résolu d'un lien dans un script
realpath lien.txt

# Alternative à readlink -f (plus portable)
python3 -c "import os; print(os.path.realpath('lien.txt'))"

# Vérifier si un chemin contient des liens symboliques
if [ "$(readlink -f /path)" != "/path" ]; then
    echo "Le chemin contient des liens symboliques"
fi
```

### Format de sortie personnalisé avec `stat`

```bash
# Afficher uniquement le nombre de liens
stat -c '%h' fichier.txt

# Afficher nom et inode
stat -c '%n: inode %i' fichier.txt

# Afficher type de fichier et cible (pour liens)
stat -c '%F %N' lien.txt

# Tout en une ligne
stat -c '%n | Type: %F | Inode: %i | Liens: %h | Taille: %s' fichier.txt
```

### Gestion des erreurs courantes

```bash
# Erreur: "Trop de niveaux de liens symboliques"
# Solution: Identifier et casser la boucle
namei -l chemin_problematique

# Erreur: "Lien croisé de périphérique invalide"
# Solution: Utiliser un lien symbolique au lieu de physique
ln -s SOURCE DEST

# Erreur: "Permission non accordée" en créant un lien
# Solution: Vérifier les permissions du répertoire de destination
ls -ld /repertoire/destination

# Lien cassé non détecté
# Solution: Vérifier explicitement
[ -e "$lien" ] || echo "Lien cassé ou inexistant"

# Problème avec les chemins relatifs
# Solution: Convertir en absolu
ln -s "$(readlink -f source)" destination
```

---

## 🎯 Résumé final

### Points clés à retenir

> [!tip] L'essentiel sur les liens Linux

**Liens physiques** :

- Même inode, mêmes données
- Pas de "original", tous égaux
- Impossible entre partitions
- Impossible pour répertoires
- Données préservées tant qu'un lien existe

**Liens symboliques** :

- Fichier spécial contenant un chemin
- Peut pointer n'importe où
- Peut casser si la cible disparaît
- Fonctionne pour répertoires
- Préférer les chemins absolus

**Commandes essentielles** :

- `ln` : Créer un lien physique
- `ln -s` : Créer un lien symbolique
- `ls -l` : Voir les liens et leurs cibles
- `readlink -f` : Résoudre le chemin complet
- `find -type l` : Trouver les liens symboliques
- `find -samefile` : Trouver les liens physiques

**Utilisations courantes** :

- Versions de configuration
- Bibliothèques système
- Organisation de fichiers
- Sauvegardes intelligentes
- Compatibilité après migration

---