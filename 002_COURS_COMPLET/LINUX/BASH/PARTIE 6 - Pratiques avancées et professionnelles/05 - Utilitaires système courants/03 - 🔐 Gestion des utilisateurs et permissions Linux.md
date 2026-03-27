

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

## Introduction

La gestion des utilisateurs et des permissions est un pilier fondamental de la sécurité sous Linux. Contrairement aux systèmes monoutilisateurs, Linux est conçu comme un système multi-utilisateurs où chaque utilisateur dispose de son propre espace et de permissions spécifiques.

> [!info] Philosophie Linux Sous Linux, **tout est fichier** et chaque fichier appartient à un utilisateur et un groupe. Ce modèle simple mais puissant permet de contrôler finement qui peut faire quoi sur le système.

---

## Gestion des utilisateurs

### Créer des utilisateurs

Linux propose deux commandes principales pour créer des utilisateurs : `useradd` (bas niveau) et `adduser` (interactif).

#### `useradd` - Commande bas niveau

```bash
# Syntaxe de base
useradd [options] nom_utilisateur

# Créer un utilisateur simple (sans répertoire personnel)
sudo useradd jean

# Créer un utilisateur avec répertoire personnel
sudo useradd -m pierre

# Créer un utilisateur complet avec toutes les options
sudo useradd -m -s /bin/bash -c "Marie Dupont" -G sudo,docker marie

# Options courantes :
# -m : créer le répertoire personnel (/home/utilisateur)
# -s : définir le shell par défaut
# -c : commentaire (nom complet)
# -G : groupes supplémentaires (séparés par des virgules)
# -d : définir un répertoire personnel personnalisé
# -u : spécifier un UID particulier
```

> [!example] Exemple pratique
> 
> ```bash
> # Créer un utilisateur développeur avec son environnement
> sudo useradd -m -s /bin/bash -c "Développeur Python" -G developers,docker devuser
> 
> # Vérifier la création
> id devuser
> # uid=1001(devuser) gid=1001(devuser) groups=1001(devuser),999(docker),1002(developers)
> ```

#### `adduser` - Commande interactive (Debian/Ubuntu)

```bash
# Créer un utilisateur de manière interactive
sudo adduser sophie

# Le script vous demandera :
# - Le mot de passe
# - Le nom complet
# - Le numéro de bureau
# - Le téléphone professionnel
# - Etc.
```

> [!tip] Quelle commande choisir ?
> 
> - **`adduser`** : idéal pour créer des utilisateurs manuellement (interactif, convivial)
> - **`useradd`** : parfait pour les scripts et l'automatisation (contrôle précis)

#### Fichiers importants

```bash
# Base de données des utilisateurs
cat /etc/passwd
# Format : nom:x:UID:GID:commentaire:home:shell

# Mots de passe chiffrés (nécessite sudo)
sudo cat /etc/shadow
# Format : nom:mot_de_passe_chiffré:dernière_modif:...

# Base de données des groupes
cat /etc/group
# Format : nom_groupe:x:GID:membres
```

### Supprimer des utilisateurs

#### `userdel` - Suppression d'utilisateur

```bash
# Supprimer un utilisateur (garde le répertoire personnel)
sudo userdel jean

# Supprimer un utilisateur ET son répertoire personnel
sudo userdel -r jean

# Forcer la suppression même si l'utilisateur est connecté
sudo userdel -f jean
```

> [!warning] Attention aux données L'option `-r` supprime **définitivement** le répertoire personnel et tous les fichiers de l'utilisateur. Assurez-vous de faire une sauvegarde si nécessaire avant la suppression.

```bash
# Bonne pratique : sauvegarder avant de supprimer
sudo tar -czf /backup/jean_home.tar.gz /home/jean
sudo userdel -r jean
```

### Gestion des mots de passe

#### `passwd` - Changer les mots de passe

```bash
# Changer son propre mot de passe
passwd

# Changer le mot de passe d'un autre utilisateur (root uniquement)
sudo passwd marie

# Forcer l'expiration du mot de passe (l'utilisateur devra le changer)
sudo passwd -e marie

# Verrouiller un compte utilisateur
sudo passwd -l marie

# Déverrouiller un compte
sudo passwd -u marie

# Afficher le statut du mot de passe
sudo passwd -S marie
# marie P 12/13/2024 0 99999 7 -1
# Format : nom statut date_modif min max warn inactif
```

> [!tip] Politique de sécurité
> 
> ```bash
> # Forcer un changement de mot de passe tous les 90 jours
> sudo chage -M 90 marie
> 
> # Voir les informations d'expiration
> sudo chage -l marie
> ```

---

## Gestion des groupes

Les groupes permettent de gérer les permissions pour plusieurs utilisateurs simultanément.

#### `groups` - Afficher les groupes

```bash
# Voir les groupes de l'utilisateur actuel
groups

# Voir les groupes d'un utilisateur spécifique
groups marie
# marie : marie sudo docker developers

# Voir tous les détails (UID, GID)
id marie
```

#### Gestion des groupes (commandes supplémentaires)

```bash
# Créer un nouveau groupe
sudo groupadd developers

# Ajouter un utilisateur à un groupe
sudo usermod -aG developers marie
# -a : append (ajouter sans supprimer les autres groupes)
# -G : groupes supplémentaires

# Retirer un utilisateur d'un groupe (éditer /etc/group ou utiliser gpasswd)
sudo gpasswd -d marie developers

# Changer le groupe principal d'un utilisateur
sudo usermod -g newgroup marie
```

> [!warning] Piège courant Sans l'option `-a`, la commande `usermod -G` **remplace** tous les groupes supplémentaires. Utilisez toujours `-aG` pour ajouter à un groupe.
> 
> ```bash
> # ❌ MAUVAIS : supprime les autres groupes
> sudo usermod -G docker marie
> 
> # ✅ BON : ajoute au groupe docker en gardant les autres
> sudo usermod -aG docker marie
> ```

---

## Propriété des fichiers

Chaque fichier sous Linux possède un **propriétaire** (utilisateur) et un **groupe**.

```bash
# Voir les propriétés d'un fichier
ls -l fichier.txt
# -rw-r--r-- 1 marie developers 1234 Dec 13 10:30 fichier.txt
#              │     │
#              │     └─ Groupe propriétaire
#              └─ Propriétaire (utilisateur)
```

### Changer le propriétaire

#### `chown` - Change Owner

```bash
# Syntaxe de base
chown [options] utilisateur[:groupe] fichier

# Changer le propriétaire uniquement
sudo chown marie fichier.txt

# Changer propriétaire et groupe
sudo chown marie:developers fichier.txt

# Récursif sur un répertoire
sudo chown -R marie:developers /var/www/site

# Copier la propriété d'un fichier de référence
sudo chown --reference=fichier1.txt fichier2.txt
```

> [!example] Cas pratique : serveur web
> 
> ```bash
> # Donner la propriété d'un site web à l'utilisateur www-data
> sudo chown -R www-data:www-data /var/www/monsite
> 
> # Vérifier le changement
> ls -la /var/www/monsite
> ```

### Changer le groupe

#### `chgrp` - Change Group

```bash
# Changer uniquement le groupe
sudo chgrp developers fichier.txt

# Récursif sur un répertoire
sudo chgrp -R developers /projet

# Utiliser un fichier de référence
sudo chgrp --reference=fichier1.txt fichier2.txt
```

> [!tip] `chown` vs `chgrp` `chown` peut changer à la fois le propriétaire et le groupe, ce qui rend `chgrp` moins nécessaire. Cependant, `chgrp` reste utile pour une lecture de code plus claire lorsque vous ne changez que le groupe.

---

## Permissions de fichiers

### Comprendre les permissions

Les permissions Linux suivent un modèle simple mais puissant basé sur trois types d'entités et trois types d'actions.

```bash
ls -l fichier.txt
# -rw-r--r-- 1 marie developers 1234 Dec 13 10:30 fichier.txt
# │││││││││
# ││││││││└─ Autres (other) : r-- (lecture uniquement)
# │││││└──── Groupe (group) : r-- (lecture uniquement)
# ││└────── Propriétaire (user) : rw- (lecture + écriture)
# │└─────── Type de fichier : - (fichier régulier)
# └──────── Permissions
```

#### Types de fichiers

|Symbole|Type|
|---|---|
|`-`|Fichier régulier|
|`d`|Répertoire (directory)|
|`l`|Lien symbolique|
|`b`|Périphérique bloc|
|`c`|Périphérique caractère|
|`s`|Socket|
|`p`|Pipe (tube nommé)|

#### Permissions de base

|Permission|Symbole|Valeur octale|Sur fichier|Sur répertoire|
|---|---|---|---|---|
|Lecture|`r`|4|Lire le contenu|Lister les fichiers (`ls`)|
|Écriture|`w`|2|Modifier le contenu|Créer/supprimer des fichiers|
|Exécution|`x`|1|Exécuter le fichier|Accéder au répertoire (`cd`)|

> [!info] Permissions sur les répertoires Pour un répertoire :
> 
> - `r` (lecture) : permet de lister les noms des fichiers
> - `w` (écriture) : permet de créer/supprimer des fichiers
> - `x` (exécution) : permet d'accéder au répertoire et à ses fichiers
> 
> **Important** : `x` sur un répertoire est nécessaire pour accéder à son contenu, même si vous avez `r`.

### Notation symbolique

#### `chmod` - Syntaxe symbolique

```bash
# Syntaxe : chmod [qui][opération][permission] fichier
# qui : u (user), g (group), o (others), a (all)
# opération : + (ajouter), - (retirer), = (définir exactement)
# permission : r, w, x

# Ajouter la permission d'exécution pour le propriétaire
chmod u+x script.sh

# Retirer l'écriture pour les autres
chmod o-w fichier.txt

# Définir exactement les permissions du groupe (lecture + exécution)
chmod g=rx fichier.txt

# Ajouter la lecture pour tout le monde
chmod a+r fichier.txt

# Combiner plusieurs modifications
chmod u+x,g+x,o-rwx script.sh

# Définir toutes les permissions en une fois
chmod u=rwx,g=rx,o=r fichier.txt
```

> [!example] Exemples courants
> 
> ```bash
> # Rendre un script exécutable pour tout le monde
> chmod a+x script.sh
> # ou
> chmod +x script.sh  # 'a' est implicite
> 
> # Fichier privé (lecture/écriture uniquement pour le propriétaire)
> chmod u=rw,go= fichier_prive.txt
> 
> # Répertoire accessible à tout le monde
> chmod a+rx /public/docs
> ```

### Notation octale

La notation octale représente les permissions par des nombres. Chaque ensemble de permissions (user, group, other) est représenté par un chiffre de 0 à 7.

#### Calcul des valeurs octales

|Permission|Valeur|Calcul|
|---|---|---|
|`---`|0|0 + 0 + 0|
|`--x`|1|0 + 0 + 1|
|`-w-`|2|0 + 2 + 0|
|`-wx`|3|0 + 2 + 1|
|`r--`|4|4 + 0 + 0|
|`r-x`|5|4 + 0 + 1|
|`rw-`|6|4 + 2 + 0|
|`rwx`|7|4 + 2 + 1|

#### `chmod` - Syntaxe octale

```bash
# Syntaxe : chmod [mode octal] fichier
# 3 chiffres : [user][group][other]

# rwxr-xr-x (755)
chmod 755 script.sh

# rw-r--r-- (644) - permission standard pour les fichiers
chmod 644 fichier.txt

# rwx------ (700) - accès exclusif au propriétaire
chmod 700 script_prive.sh

# rw-rw-r-- (664)
chmod 664 document.txt

# rwxrwxrwx (777) - DANGEREUX, à éviter !
chmod 777 fichier.txt
```

> [!warning] Permissions 777 dangereuses `chmod 777` donne tous les droits à tout le monde. C'est généralement une **très mauvaise pratique** en matière de sécurité. Utilisez-le uniquement si vous comprenez parfaitement les implications.

#### Comparaison symbolique vs octale

|Symbolique|Octale|Description|
|---|---|---|
|`chmod u=rwx,g=rx,o=rx`|`chmod 755`|Exécutable standard|
|`chmod u=rw,g=r,o=r`|`chmod 644`|Fichier texte standard|
|`chmod u=rwx,g=,o=`|`chmod 700`|Script privé|
|`chmod u=rw,g=rw,o=r`|`chmod 664`|Document partagé|
|`chmod u=rwx,g=rwx,o=`|`chmod 770`|Répertoire de groupe|

> [!tip] Quelle notation choisir ?
> 
> - **Octale** : rapide pour définir toutes les permissions d'un coup (ex: `chmod 644`)
> - **Symbolique** : plus lisible et précise pour modifier des permissions spécifiques (ex: `chmod u+x`)

#### Options avancées de chmod

```bash
# Récursif : appliquer aux sous-répertoires et fichiers
chmod -R 755 /var/www

# Verbeux : afficher les modifications
chmod -v u+x script.sh

# Ne pas afficher les erreurs
chmod -f u+x fichier_inexistant.sh

# Utiliser un fichier de référence
chmod --reference=fichier1.txt fichier2.txt

# Préserver le mode root (ne change que si match)
chmod --preserve-root -R 755 /
```

> [!example] Cas pratique : répertoire web
> 
> ```bash
> # Structure typique pour un site web
> sudo chown -R www-data:www-data /var/www/site
> 
> # Répertoires : 755 (rwxr-xr-x)
> sudo find /var/www/site -type d -exec chmod 755 {} \;
> 
> # Fichiers : 644 (rw-r--r--)
> sudo find /var/www/site -type f -exec chmod 644 {} \;
> 
> # Fichiers uploads en écriture pour le serveur
> sudo chmod 775 /var/www/site/uploads
> ```

---

## ACL - Permissions avancées

Les ACL (Access Control Lists) permettent de définir des permissions plus granulaires que le système classique user/group/other. Elles sont utiles lorsque vous devez accorder des permissions spécifiques à plusieurs utilisateurs ou groupes sur un même fichier.

> [!info] Pourquoi les ACL ? Le système de permissions classique est limité : un fichier ne peut avoir qu'un seul propriétaire et qu'un seul groupe. Les ACL permettent de définir des permissions pour plusieurs utilisateurs et groupes simultanément.

### Vérifier le support ACL

```bash
# Vérifier si le système de fichiers supporte les ACL
mount | grep acl

# Monter avec support ACL si nécessaire
sudo mount -o remount,acl /home
```

### `setfacl` - Définir des ACL

```bash
# Syntaxe de base
setfacl [options] règle fichier

# Accorder la lecture à un utilisateur spécifique
setfacl -m u:marie:r fichier.txt

# Accorder lecture + exécution à un utilisateur
setfacl -m u:jean:rx /projet

# Accorder des permissions à un groupe
setfacl -m g:developers:rw fichier.txt

# Définir plusieurs règles en une fois
setfacl -m u:marie:rw,u:jean:r,g:developers:rw fichier.txt

# Récursif sur un répertoire
setfacl -R -m u:marie:rwx /projet

# Définir des ACL par défaut (pour les nouveaux fichiers)
setfacl -d -m u:marie:rw /projet
```

> [!example] Cas pratique : projet collaboratif
> 
> ```bash
> # Créer un répertoire de projet
> mkdir /projet/webapp
> 
> # Définir les permissions de base
> chmod 770 /projet/webapp
> 
> # Ajouter des permissions ACL pour des développeurs spécifiques
> setfacl -m u:alice:rwx /projet/webapp
> setfacl -m u:bob:rx /projet/webapp
> setfacl -m g:testers:rx /projet/webapp
> 
> # ACL par défaut pour les nouveaux fichiers
> setfacl -d -m u:alice:rw /projet/webapp
> setfacl -d -m g:testers:r /projet/webapp
> ```

#### Options de setfacl

```bash
# -m : modifier/ajouter une ACL
setfacl -m u:marie:rw fichier.txt

# -x : supprimer une ACL spécifique
setfacl -x u:marie fichier.txt

# -b : supprimer toutes les ACL
setfacl -b fichier.txt

# -d : définir des ACL par défaut (pour les nouveaux fichiers dans un répertoire)
setfacl -d -m u:marie:rw /repertoire

# -R : récursif
setfacl -R -m u:marie:rx /repertoire

# -k : supprimer les ACL par défaut
setfacl -k /repertoire

# --set : définir exactement les ACL (remplace toutes les existantes)
setfacl --set u::rwx,g::rx,o::r fichier.txt
```

### `getfacl` - Afficher les ACL

```bash
# Afficher les ACL d'un fichier
getfacl fichier.txt

# Sortie exemple :
# file: fichier.txt
# owner: marie
# group: developers
# user::rw-
# user:jean:r--
# group::r--
# group:testers:r--
# mask::rw-
# other::r--

# Afficher de manière compacte
getfacl -c fichier.txt

# Récursif
getfacl -R /projet

# Sans les commentaires d'en-tête
getfacl --omit-header fichier.txt
```

> [!tip] Le masque (mask) Le `mask` définit les permissions maximales effectives pour les utilisateurs et groupes nommés (pas pour le propriétaire ni pour other). Il agit comme un filtre.
> 
> ```bash
> # Si mask::r--, même si u:jean:rwx, jean aura au max r--
> # Pour modifier le mask :
> setfacl -m m::rwx fichier.txt
> ```

#### Sauvegarder et restaurer les ACL

```bash
# Sauvegarder les ACL d'un répertoire
getfacl -R /projet > acl_backup.txt

# Restaurer les ACL
setfacl --restore=acl_backup.txt

# Copier les ACL d'un fichier vers un autre
getfacl fichier1.txt | setfacl --set-file=- fichier2.txt
```

### Visualisation avec `ls`

Lorsqu'un fichier possède des ACL, `ls -l` affiche un `+` après les permissions.

```bash
ls -l fichier.txt
# -rw-rw-r--+ 1 marie developers 1234 Dec 13 10:30 fichier.txt
#           ↑
#           Indique la présence d'ACL
```

> [!warning] Pièges avec les ACL
> 
> - Les ACL peuvent rendre le débogage des permissions plus complexe
> - Tous les outils ne préservent pas les ACL lors de la copie (utilisez `cp -p` ou `rsync -A`)
> - Les ACL par défaut ne s'appliquent qu'aux **nouveaux** fichiers créés dans le répertoire
> - Le `mask` peut limiter les permissions même si une ACL accorde plus de droits

### ACL par défaut vs ACL d'accès

```bash
# ACL d'accès : s'applique au fichier/répertoire lui-même
setfacl -m u:marie:rw fichier.txt

# ACL par défaut : s'applique aux NOUVEAUX fichiers créés dans le répertoire
setfacl -d -m u:marie:rw /projet

# Voir les deux types d'ACL
getfacl /projet
# # file: projet
# # owner: marie
# # group: developers
# user::rwx
# group::r-x
# other::r-x
# default:user::rwx          ← ACL par défaut
# default:user:marie:rw-     ← ACL par défaut
# default:group::r-x
# default:other::r-x
```

> [!example] Workflow complet avec ACL
> 
> ```bash
> # 1. Créer un répertoire partagé
> sudo mkdir /projet/shared
> sudo chown marie:developers /projet/shared
> sudo chmod 770 /projet/shared
> 
> # 2. Définir les ACL d'accès (pour le répertoire lui-même)
> sudo setfacl -m u:alice:rwx /projet/shared
> sudo setfacl -m u:bob:rx /projet/shared
> sudo setfacl -m g:testers:rx /projet/shared
> 
> # 3. Définir les ACL par défaut (pour les futurs fichiers)
> sudo setfacl -d -m u:alice:rw /projet/shared
> sudo setfacl -d -m u:bob:r /projet/shared
> sudo setfacl -d -m g:testers:r /projet/shared
> 
> # 4. Vérifier
> getfacl /projet/shared
> 
> # 5. Tester : créer un fichier
> touch /projet/shared/test.txt
> getfacl /projet/shared/test.txt
> # Le fichier hérite automatiquement des ACL par défaut
> ```

---

## 🎯 Récapitulatif des commandes

|Commande|Usage|Exemple|
|---|---|---|
|`useradd`|Créer un utilisateur|`sudo useradd -m -s /bin/bash jean`|
|`adduser`|Créer un utilisateur (interactif)|`sudo adduser marie`|
|`userdel`|Supprimer un utilisateur|`sudo userdel -r jean`|
|`passwd`|Gérer les mots de passe|`sudo passwd marie`|
|`groups`|Afficher les groupes|`groups marie`|
|`chown`|Changer propriétaire/groupe|`sudo chown marie:dev fichier.txt`|
|`chgrp`|Changer le groupe|`sudo chgrp developers fichier.txt`|
|`chmod`|Changer les permissions|`chmod 755 script.sh`|
|`setfacl`|Définir des ACL|`setfacl -m u:marie:rw fichier.txt`|
|`getfacl`|Afficher les ACL|`getfacl fichier.txt`|

---

## 🔑 Permissions par défaut courantes

|Type|Octal|Symbolique|Usage|
|---|---|---|---|
|Fichier texte|644|`-rw-r--r--`|Documents, configs|
|Script/exécutable|755|`-rwxr-xr-x`|Scripts, binaires|
|Fichier privé|600|`-rw-------`|Clés SSH, mots de passe|
|Répertoire standard|755|`drwxr-xr-x`|Répertoires publics|
|Répertoire privé|700|`drwx------`|Répertoires personnels|
|Répertoire partagé|770|`drwxrwx---`|Collaboration en groupe|

---

> [!tip] Bonnes pratiques générales
> 
> 1. **Principe du moindre privilège** : donnez uniquement les permissions nécessaires
> 2. **Évitez 777** : c'est presque toujours une mauvaise idée
> 3. **Utilisez les groupes** : plutôt que de multiplier les ACL
> 4. **Documentez les ACL** : elles peuvent être difficiles à débugger
> 5. **Testez les permissions** : avant de déployer en production
> 6. **Sauvegardes** : avant de modifier massivement les permissions