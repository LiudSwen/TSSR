
> [!info] Lien vers le cours technique Pour la syntaxe détaillée et les commandes : voir [[Liens Linux - Cours complet]]

---

## 🎯 Concept de base

### Qu'est-ce qu'un lien physique vraiment ?

**Analogie simple** : Imagine une personne qui s'appelle "Marie Dupont". On peut l'appeler :

- "Marie"
- "Madame Dupont"
- "Maman" (pour ses enfants)
- "Dr. Dupont" (au travail)

Ce sont **quatre noms différents** mais c'est toujours **la même personne**. Si quelqu'un dit "Marie n'existe plus", elle existe toujours sous les autres noms. Elle n'existe vraiment plus que quand **tous ses noms** ont disparu.

**C'est exactement ça un lien physique** : plusieurs noms pour le même contenu sur le disque.

### Ce que ça n'est PAS

> [!warning] Attention aux idées fausses
> 
> - ❌ Ce n'est PAS un raccourci (ça c'est le lien symbolique)
> - ❌ Ce n'est PAS une copie (ça prendrait de l'espace)
> - ❌ Il n'y a PAS d'original et de copie (tous les liens sont égaux)

### Pourquoi ça existe ?

Le problème que ça résout : **Comment avoir le même fichier accessible à plusieurs endroits sans gaspiller d'espace disque et sans risquer de le perdre ?**

Avant les liens physiques, tu avais deux options :

1. **Copier le fichier** → gaspillage d'espace (2x, 3x, 10x la taille)
2. **Ne pas dupliquer** → si quelqu'un supprime l'unique exemplaire, tout est perdu

Les liens physiques offrent **le meilleur des deux mondes** : accessibilité multiple + protection + 0 espace supplémentaire.

---

## 💼 Cas concrets et situations réelles

### Cas 1 : Protection contre la suppression accidentelle

> [!example] Situation typique en entreprise Tu administres un serveur web. Le fichier `/etc/apache2/sites-available/important-client.conf` contient la configuration critique d'un gros client. Un stagiaire a les droits sudo...

**Problème** : Si quelqu'un supprime ce fichier, le site tombe et tu dois restaurer depuis une sauvegarde (perte de temps, stress).

**Solution avec lien physique** :

```bash
# Créer un lien physique de sécurité
ln /etc/apache2/sites-available/important-client.conf /root/backup-configs/important-client.conf

# Vérification
ls -li /etc/apache2/sites-available/important-client.conf /root/backup-configs/important-client.conf
# 524288 -rw-r--r-- 2 root root 2048 Nov 23 10:00 /etc/apache2/sites-available/important-client.conf
# 524288 -rw-r--r-- 2 root root 2048 Nov 23 10:00 /root/backup-configs/important-client.conf
#   ↑ Même inode = même fichier !
```

**Ce qui se passe** :

- Le stagiaire fait `rm /etc/apache2/sites-available/important-client.conf`
- Le fichier "disparaît" de ce chemin
- **MAIS** le contenu existe toujours dans `/root/backup-configs/`
- Tu peux le restaurer instantanément : `ln /root/backup-configs/important-client.conf /etc/apache2/sites-available/important-client.conf`
- Temps de rétablissement : 2 secondes au lieu de 10 minutes

**Gain** : Tranquillité d'esprit, zéro espace disque utilisé, récupération instantanée.

---

### Cas 2 : Sauvegardes incrémentales intelligentes

> [!example] Scénario réel : Sauvegarde quotidienne de 500 Go Tu dois sauvegarder `/home` tous les jours. Les utilisateurs ont 500 Go de données. Chaque jour, seulement 2-3 Go changent.

**Sans liens physiques** :

```bash
# Lundi : 500 Go
cp -r /home /backup/2024-11-18/

# Mardi : encore 500 Go
cp -r /home /backup/2024-11-19/

# Mercredi : encore 500 Go
cp -r /home /backup/2024-11-20/

# Résultat : 1500 Go utilisés pour 3 jours !
```

**Avec liens physiques** (méthode rsync) :

```bash
# Lundi : sauvegarde complète (500 Go)
rsync -a /home/ /backup/2024-11-18/

# Mardi : sauvegarde incrémentale avec liens physiques
rsync -a --link-dest=/backup/2024-11-18/ /home/ /backup/2024-11-19/
# Seuls les fichiers MODIFIÉS sont copiés (3 Go)
# Les fichiers INCHANGÉS sont des liens physiques (0 Go supplémentaire)

# Mercredi : pareil
rsync -a --link-dest=/backup/2024-11-19/ /home/ /backup/2024-11-20/
# Encore 3 Go seulement
```

**Résultat** :

- Espace utilisé : 506 Go (au lieu de 1500 Go !)
- Économie : **66% d'espace disque**
- Tu peux garder 30 jours de backup au lieu de 3 jours
- Chaque backup est accessible comme si c'était complet

**Magie** : Tu vas dans `/backup/2024-11-19/` et tu vois TOUS les fichiers comme si c'était une copie complète, mais ça ne prend que 3 Go !

**Outils qui utilisent ça** : rsnapshot, Time Machine (macOS), Back In Time, duplicity.

---

### Cas 3 : Base de données partagée sans duplication

> [!example] Environnement de développement Ton équipe de 5 développeurs travaille sur un projet avec une grosse base de test de 20 Go. Chacun a besoin d'y accéder depuis son répertoire home.

**Sans liens physiques** :

```bash
# Chaque dev a sa copie
cp database.db /home/alice/projet/database.db    # 20 Go
cp database.db /home/bob/projet/database.db      # 20 Go
cp database.db /home/charlie/projet/database.db  # 20 Go
cp database.db /home/david/projet/database.db    # 20 Go
cp database.db /home/emma/projet/database.db     # 20 Go

# Total : 100 Go utilisés !
# Problème : Si la base doit être mise à jour, il faut recopier partout
```

**Avec liens physiques** :

```bash
# Base originale
/data/shared/database.db  # 20 Go

# Chaque dev a un lien physique
ln /data/shared/database.db /home/alice/projet/database.db
ln /data/shared/database.db /home/bob/projet/database.db
ln /data/shared/database.db /home/charlie/projet/database.db
ln /data/shared/database.db /home/david/projet/database.db
ln /data/shared/database.db /home/emma/projet/database.db

# Total : 20 Go utilisés !
```

**Avantages** :

- **Économie** : 80 Go d'espace disque économisés
- **Synchronisation automatique** : Si Alice modifie la base, tout le monde voit les changements
- **Protection** : Si Bob supprime son lien, les 4 autres continuent de travailler
- **Accessibilité** : Chacun accède à "sa" base depuis son répertoire

---

### Cas 4 : Versioning de fichiers de configuration

> [!example] Gestion de versions sans Git Tu gères un fichier de config qui évolue. Tu veux garder l'historique sans utiliser Git et sans dupliquer.

**Situation** :

```bash
# Configuration actuelle (5 MB)
/etc/app/config.xml

# Tu veux garder des versions datées
```

**Solution avec liens physiques** :

```bash
# Créer une version datée
ln /etc/app/config.xml /etc/app/archive/config-2024-11-01.xml

# Quelques jours plus tard, avant une modification importante
ln /etc/app/config.xml /etc/app/archive/config-2024-11-15.xml

# Modifier le fichier actuel
vim /etc/app/config.xml

# Créer une nouvelle version après modification
ln /etc/app/config.xml /etc/app/archive/config-2024-11-23.xml
```

**Résultat** :

```bash
ls -lh /etc/app/archive/
# -rw-r--r-- 4 root root 5.0M config-2024-11-01.xml
# -rw-r--r-- 4 root root 5.0M config-2024-11-15.xml
# -rw-r--r-- 2 root root 5.0M config-2024-11-23.xml  ← Version modifiée
#            ↑ Compteur de liens
```

**Explication** :

- Les versions 01 et 15 partagent le même contenu (4 liens physiques)
- La version 23 est différente (2 liens physiques)
- Espace réel utilisé : 10 MB (au lieu de 15 MB si c'étaient des copies)
- Tu peux revenir à n'importe quelle version instantanément

---

### Cas 5 : Rotation de logs sans interruption

> [!example] Serveur de production avec logs volumineux Ton application web génère `/var/log/app/access.log` qui grossit de 2 GB par jour. Tu dois faire une rotation quotidienne sans perdre une seule ligne.

**Problème** : Si tu fais juste `mv access.log access.log.1`, l'application continue d'écrire dans l'ancien fichier (même après le renommage, car Linux utilise les inodes).

**Solution avec lien physique** :

```bash
# Script de rotation
#!/bin/bash

# 1. Créer un lien physique
ln /var/log/app/access.log /var/log/app/access.log.1

# 2. Tronquer le fichier original
> /var/log/app/access.log

# 3. Recharger l'application pour qu'elle rouvre le fichier
systemctl reload application

# Résultat :
# - L'application écrivait dans access.log (inode 123456)
# - Après le lien, access.log ET access.log.1 pointent vers le même inode
# - Après la troncature, un NOUVEAU access.log est créé (inode 789012)
# - L'application continue d'écrire dans l'ancien (via access.log.1) jusqu'au reload
# - Après reload, elle écrit dans le nouveau
# - Aucune ligne perdue !
```

**Comparaison avec la mauvaise méthode** :

```bash
# ❌ Méthode risquée
mv /var/log/app/access.log /var/log/app/access.log.1
touch /var/log/app/access.log
# Pendant le mv et le touch, des lignes peuvent être perdues
```

---

### Cas 6 : Fichiers système "indestructibles"

> [!example] Protection d'une licence logicielle critique Tu as un serveur avec une licence logicielle à 10 000€. Le fichier de licence est dans `/opt/software/license.key`. Si ce fichier est supprimé, l'appli s'arrête.

**Stratégie de protection maximale** :

```bash
# Créer plusieurs liens physiques "cachés"
ln /opt/software/license.key /root/.license_backup
ln /opt/software/license.key /usr/local/etc/.lic
ln /opt/software/license.key /var/backups/.software.key
ln /opt/software/license.key /.license_safe

# Vérification
ls -li /opt/software/license.key
# 445566 -rw-r--r-- 5 root root 2048 license.key
#                    ↑ 5 liens physiques !
```

**Avantages** :

- Même si un attaquant ou un bug supprime `/opt/software/license.key`
- Le fichier existe toujours dans 4 autres emplacements
- Tu peux le restaurer en 2 secondes : `ln /root/.license_backup /opt/software/license.key`
- Coût : 0 octet d'espace disque supplémentaire
- Le logiciel ne s'interrompt jamais

**Note** : Pense à documenter ces liens cachés, sinon toi-même tu risques de les oublier !

---

### Cas 7 : Environnement de test et production

> [!example] Application avec environnements multiples Tu as une application avec des assets (images, CSS, JS) qui font 10 GB. Tu veux des environnements séparés dev/test/prod mais avec les mêmes assets.

**Structure traditionnelle (gourmande)** :

```bash
/var/www/app-dev/assets/     # 10 GB
/var/www/app-test/assets/    # 10 GB
/var/www/app-prod/assets/    # 10 GB
# Total : 30 GB
```

**Structure avec liens physiques** :

```bash
# Assets centralisés
/var/www/shared-assets/
├── images/
├── css/
└── js/

# Créer des liens physiques pour chaque environnement
cd /var/www/shared-assets
find . -type f -exec sh -c '
  ln "$1" "/var/www/app-dev/assets/$1"
  ln "$1" "/var/www/app-test/assets/$1"
  ln "$1" "/var/www/app-prod/assets/$1"
' sh {} \;

# Total : 10 GB (économie de 20 GB !)
```

**Avantages** :

- Les trois environnements ont accès aux mêmes assets
- Tu peux modifier un asset et le tester dans dev
- Quand c'est validé, il est déjà en test et prod (même fichier)
- Économie massive d'espace

**Attention** : Si tu modifies un asset, il change partout. Si tu veux une version différente pour un env, il faudra faire une vraie copie de ce fichier spécifique.

---

## ⚖️ Comparaisons : Quand utiliser quoi ?

### Lien physique vs Copie du fichier

|Critère|Lien physique|Copie|
|---|---|---|
|**Espace disque**|0 octet supplémentaire|Taille du fichier × nombre de copies|
|**Modification**|Change partout|Chaque copie indépendante|
|**Suppression**|Données préservées si au moins 1 lien existe|Chaque copie indépendante|
|**Protection**|✅ Protège contre suppression accidentelle|❌ Si supprimé, perdu|
|**Indépendance**|❌ Tout est lié|✅ Chaque copie séparée|

> [!tip] Utilise un lien physique quand...
> 
> - Tu veux économiser de l'espace
> - Tu veux que les modifications se propagent partout
> - Tu veux protéger contre la suppression
> 
> Utilise une copie quand...
> 
> - Tu veux modifier chaque version indépendamment
> - Tu veux un vrai backup isolé

### Lien physique vs Lien symbolique

|Critère|Lien physique|Lien symbolique|
|---|---|---|
|**Robustesse**|✅ Ne casse jamais (sauf dernier lien supprimé)|❌ Casse si cible supprimée/déplacée|
|**Visibilité**|❌ Difficile à identifier|✅ Facilement visible avec `ls -l`|
|**Répertoires**|❌ Impossible|✅ Possible|
|**Entre partitions**|❌ Impossible|✅ Possible|
|**Espace**|0 octet|~longueur du chemin|
|**Utilisation typique**|Sauvegardes, protection|Raccourcis, organisation|

> [!tip] Utilise un lien physique quand...
> 
> - La robustesse est critique (ne doit pas casser)
> - C'est sur la même partition
> - C'est pour des fichiers (pas des répertoires)
> - Tu veux une protection contre la suppression
> 
> Utilise un lien symbolique quand...
> 
> - Tu veux un "raccourci" visible
> - C'est vers un répertoire
> - C'est entre partitions différentes
> - Tu veux que ça casse si la cible disparaît (détection)

---

## ⚠️ Pièges et erreurs courantes

### Piège 1 : "J'ai supprimé le fichier mais il prend toujours de l'espace !"

> [!warning] Incompréhension fréquente

**Situation** :

```bash
# Tu as un gros fichier
ls -lh film.mp4
# -rw-r--r-- 2 user user 8.5G film.mp4

# Tu le supprimes
rm film.mp4

# Tu vérifies l'espace disque
df -h
# Hein ? L'espace n'a pas augmenté !
```

**Explication** : Le chiffre "2" après les permissions indique qu'il y a **2 liens physiques**. Le fichier existe encore ailleurs !

**Solution** :

```bash
# Trouver l'autre lien
find /home -samefile film.mp4 2>/dev/null
# /home/user/backup/film.mp4

# Supprimer aussi celui-là
rm /home/user/backup/film.mp4

# MAINTENANT l'espace est libéré
```

> [!tip] Comment éviter Avant de supprimer un gros fichier, vérifie le nombre de liens :
> 
> ```bash
> ls -l fichier | awk '{print $2}'
> # Si > 1, trouve les autres liens d'abord !
> ```

---

### Piège 2 : "Je ne peux pas créer de lien physique vers mon disque externe"

> [!warning] Limitation des systèmes de fichiers

**Erreur typique** :

```bash
ln /home/user/document.pdf /mnt/usb/document.pdf
# ln: échec de création du lien: Lien croisé de périphérique invalide
```

**Explication** : Les liens physiques ne fonctionnent **que sur la même partition/système de fichiers**. Ton disque externe est une partition différente.

**Solution** : Utilise un lien symbolique à la place :

```bash
ln -s /home/user/document.pdf /mnt/usb/document.pdf
```

**Vérification avant de créer un lien physique** :

```bash
# Vérifier si deux chemins sont sur la même partition
df /home/user /mnt/usb
# Filesystem     1K-blocks    Used Available Use% Mounted on
# /dev/sda1      480588496   25000  455588496   6% /home
# /dev/sdb1      120588496    5000  115583496   5% /mnt/usb
#  ↑ Différent = lien physique impossible
```

---

### Piège 3 : "J'ai modifié un fichier et ça a changé partout !"

> [!warning] Comportement normal mais surprenant

**Situation** :

```bash
# Tu as créé des liens pour "sauvegarder"
ln config.conf config-backup.conf
ln config.conf config-safe.conf

# Tu modifies config.conf
echo "nouvelle ligne" >> config.conf

# Tu regardes le backup
cat config-backup.conf
# Horreur ! La nouvelle ligne est là aussi !
```

**Explication** : C'est **normal** ! Les liens physiques pointent vers le **même contenu**. Il n'y a pas d'original et de copie, c'est le même fichier.

**Solution** : Si tu veux vraiment une copie indépendante, utilise `cp` :

```bash
cp config.conf config-backup.conf
```

> [!tip] Quand c'est voulu C'est justement l'intérêt dans certains cas ! Si tu veux que plusieurs emplacements restent synchronisés automatiquement, les liens physiques sont parfaits.

---

### Piège 4 : "Je ne trouve plus mes liens physiques !"

> [!warning] Pas de flèche comme les liens symboliques

**Problème** : Avec `ls -l`, les liens physiques ressemblent à des fichiers normaux :

```bash
ls -l
# -rw-r--r-- 3 user user 1024 Nov 23 10:00 fichier.txt
# -rw-r--r-- 3 user user 1024 Nov 23 10:00 autre_nom.txt
# -rw-r--r-- 3 user user 1024 Nov 23 10:00 encore_un.txt
```

Impossible de savoir lesquels sont liés juste en regardant !

**Solution** : Utilise l'inode pour identifier :

```bash
# Afficher les inodes
ls -li
# 123456 -rw-r--r-- 3 user user 1024 Nov 23 10:00 fichier.txt
# 123456 -rw-r--r-- 3 user user 1024 Nov 23 10:00 autre_nom.txt
# 123456 -rw-r--r-- 3 user user 1024 Nov 23 10:00 encore_un.txt
#   ↑ Même numéro = liens physiques entre eux !

# Ou trouver tous les liens d'un fichier
find / -samefile fichier.txt 2>/dev/null
```

> [!tip] Bonne pratique Documente tes liens physiques ! Crée un fichier README expliquant où sont les liens importants.

---

### Piège 5 : "Mon backup rsync a recréé tous les fichiers !"

> [!warning] Mauvaise option rsync

**Problème** :

```bash
# Premier backup
rsync -a /home/ /backup/monday/

# Deuxième backup incrémental (SANS --link-dest)
rsync -a /home/ /backup/tuesday/

# Résultat : tuesday/ est une COPIE COMPLÈTE, pas incrémentale !
```

**Solution** : Toujours utiliser `--link-dest` pour les backups incrémentaux :

```bash
rsync -a --link-dest=/backup/monday/ /home/ /backup/tuesday/
```

**Vérification que ça a marché** :

```bash
# Comparer les inodes d'un fichier inchangé
ls -i /backup/monday/document.txt /backup/tuesday/document.txt
# 123456 /backup/monday/document.txt
# 123456 /backup/tuesday/document.txt  ← Même inode = lien physique ✅
```

---

### Piège 6 : "Je veux lier un répertoire mais ça ne marche pas"

> [!warning] Impossible pour les répertoires

**Erreur** :

```bash
ln /var/www/site /home/user/raccourci-site
# ln: /var/www/site: hard link not allowed for directory
```

**Explication** : Linux n'autorise pas les liens physiques vers les répertoires (sauf `.` et `..`) pour éviter les boucles infinies dans l'arborescence.

**Solution** : Utilise un lien symbolique :

```bash
ln -s /var/www/site /home/user/raccourci-site
```

---

## 🔗 Lien avec d'autres concepts

### Avec les sauvegardes

Les liens physiques sont la base de nombreux systèmes de sauvegarde modernes :

- **rsnapshot** : Snapshots quotidiens avec liens physiques
- **Time Machine** (macOS) : Même principe
- **Déduplication** : Certains systèmes détectent les fichiers identiques et les convertissent en liens physiques

### Avec les permissions

> [!info] Tous les liens partagent les mêmes permissions Si tu fais `chmod 600` sur un lien physique, TOUS les autres liens auront aussi `600`. C'est normal : c'est le même fichier !

```bash
ln fichier.txt lien.txt

chmod 600 fichier.txt

ls -l lien.txt
# -rw------- 2 user user ... lien.txt
# Les permissions ont changé partout
```

### Avec les systèmes de fichiers

Différents systèmes de fichiers ont des comportements différents :

- **ext4, ext3** : Support complet des liens physiques
- **FAT32, exFAT** : ❌ Pas de support
- **NTFS** : ✅ Support (depuis Windows Vista)
- **Btrfs, ZFS** : Support + fonctionnalités avancées

### Avec la sécurité

Les liens physiques peuvent être un **risque de sécurité** :

```bash
# Utilisateur malveillant
ln /etc/shadow /tmp/shadow_link

# Tente de modifier via le lien
# Si les permissions ne sont pas bien gérées, il pourrait accéder au fichier
```

**Protection** : Les systèmes modernes empêchent de créer des liens physiques vers des fichiers qu'on ne possède pas.

---

## 📊 Résumé visuel

```
┌─────────────────────────────────────────────────────────┐
│              QUAND UTILISER UN LIEN PHYSIQUE            │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ✅ Économiser de l'espace (backups incrémentaux)       │
│  ✅ Protéger contre suppression accidentelle            │
│  ✅ Partager de gros fichiers entre utilisateurs        │
│  ✅ Versioning simple sans duplication                  │
│  ✅ Fichiers critiques "indestructibles"                │
│  ✅ Rotation de logs sans interruption                  │
│                                                          │
│  ❌ Entre différentes partitions                        │
│  ❌ Pour des répertoires                                │
│  ❌ Quand tu veux des copies vraiment indépendantes     │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

---

## 🎓 Points clés à retenir

> [!tip] En une phrase **Un lien physique = un nom supplémentaire pour le même fichier, qui protège contre la suppression et économise l'espace disque.**

**Les 3 cas d'usage principaux en TSSR** :

1. 🛡️ **Protection** : Fichiers critiques avec liens de backup
2. 💾 **Sauvegardes** : Backups incrémentaux avec rsync --link-dest
3. 🤝 **Partage** : Gros fichiers accessibles à plusieurs utilisateurs/emplacements

**Ce qu'il faut absolument retenir** :

- Même inode = même fichier = 0 espace supplémentaire
- Suppression du dernier lien = suppression des données
- Impossible entre partitions différentes
- Impossible pour les répertoires
- Modifications visibles partout