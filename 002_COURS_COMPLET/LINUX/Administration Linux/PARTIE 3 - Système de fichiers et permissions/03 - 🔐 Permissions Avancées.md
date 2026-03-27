

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

Les permissions classiques Linux (rwx pour user/group/other) constituent la base de la sécurité des fichiers, mais elles montrent rapidement leurs limites dans des environnements complexes. Les permissions avancées offrent des mécanismes supplémentaires pour gérer finement les accès et les comportements des fichiers et répertoires.

> [!info] Pourquoi des permissions avancées ? Les permissions standards ne permettent pas de :
> 
> - Exécuter un programme avec les privilèges de son propriétaire
> - Garantir l'héritage de groupe dans un répertoire partagé
> - Protéger les fichiers dans les répertoires publics
> - Définir des permissions granulaires pour plusieurs utilisateurs/groupes
> - Contrôler les permissions par défaut des nouveaux fichiers

---

## SUID (Set User ID)

### 🎯 Concept et utilité

Le **SUID** (Set User ID) permet à un utilisateur d'exécuter un fichier avec les permissions de son **propriétaire** plutôt qu'avec ses propres permissions. C'est un mécanisme puissant mais potentiellement dangereux.

> [!example] Cas d'usage typique La commande `passwd` doit modifier `/etc/shadow`, un fichier accessible uniquement à root. Grâce au SUID, n'importe quel utilisateur peut exécuter `passwd` avec les privilèges de root pour changer son propre mot de passe.

### 📝 Syntaxe et utilisation

#### Activation du SUID

```bash
# Méthode symbolique
chmod u+s fichier

# Méthode octale (4 en premier chiffre)
chmod 4755 fichier

# Exemple pratique
chmod u+s /usr/bin/mon_programme
```

#### Vérification du SUID

```bash
# Le 's' remplace le 'x' dans les permissions du propriétaire
ls -l /usr/bin/passwd
# -rwsr-xr-x 1 root root 68208 mai 28  2023 /usr/bin/passwd
#    ^ Le 's' indique le SUID

# 'S' majuscule = SUID activé mais pas de permission d'exécution
# 's' minuscule = SUID activé avec permission d'exécution
```

#### Recherche des fichiers SUID

```bash
# Trouver tous les fichiers avec SUID dans le système
find / -perm -4000 -type f 2>/dev/null

# Recherche plus détaillée
find / -perm -4000 -type f -ls 2>/dev/null

# Dans un répertoire spécifique
find /usr/bin -perm -4000 -type f
```

#### Suppression du SUID

```bash
# Méthode symbolique
chmod u-s fichier

# Méthode octale (remplacer par 0)
chmod 0755 fichier
```

> [!warning] Risques de sécurité
> 
> - Le SUID sur des scripts shell est **ignoré** par Linux pour des raisons de sécurité
> - Un fichier SUID appartenant à root peut être une faille majeure s'il est mal sécurisé
> - Ne jamais mettre SUID sur des programmes qui acceptent une entrée utilisateur non validée
> - Auditez régulièrement les fichiers SUID sur votre système

> [!tip] Bonnes pratiques
> 
> - Utilisez SUID uniquement quand c'est absolument nécessaire
> - Préférez des solutions alternatives comme `sudo` avec des permissions ciblées
> - Documentez tous les fichiers SUID personnalisés
> - Établissez une baseline des fichiers SUID système et surveillez les changements

---

## SGID (Set Group ID)

### 🎯 Concept et utilité

Le **SGID** (Set Group ID) a deux comportements différents selon qu'il est appliqué à un fichier ou à un répertoire.

**Sur un fichier exécutable** : L'utilisateur exécute le fichier avec les permissions du **groupe** propriétaire du fichier.

**Sur un répertoire** : Les nouveaux fichiers créés héritent automatiquement du groupe du répertoire parent (au lieu du groupe primaire de l'utilisateur créateur).

> [!example] Cas d'usage typique Un répertoire de projet partagé `/projets/web` où tous les fichiers doivent appartenir au groupe `webdev`, quel que soit l'utilisateur qui les crée.

### 📝 Syntaxe et utilisation

#### Activation du SGID

```bash
# Sur un fichier
chmod g+s fichier

# Sur un répertoire
chmod g+s repertoire/

# Méthode octale (2 en premier chiffre)
chmod 2755 repertoire/

# Exemple pratique pour un projet collaboratif
mkdir /projets/equipe
chgrp developpeurs /projets/equipe
chmod 2775 /projets/equipe
```

#### Vérification du SGID

```bash
# Le 's' remplace le 'x' dans les permissions du groupe
ls -ld /projets/equipe
# drwxrwsr-x 2 root developpeurs 4096 déc 26 10:00 /projets/equipe
#       ^ Le 's' indique le SGID

# Tester l'héritage de groupe
cd /projets/equipe
touch test.txt
ls -l test.txt
# -rw-r--r-- 1 utilisateur developpeurs 0 déc 26 10:01 test.txt
#                         ^^^^^^^^^^^^ Groupe hérité du répertoire
```

#### Recherche des fichiers/répertoires SGID

```bash
# Tous les fichiers et répertoires avec SGID
find / -perm -2000 2>/dev/null

# Uniquement les répertoires
find / -type d -perm -2000 2>/dev/null

# Uniquement les fichiers
find / -type f -perm -2000 2>/dev/null
```

#### Suppression du SGID

```bash
# Méthode symbolique
chmod g-s fichier

# Méthode octale
chmod 0755 fichier
```

> [!tip] Astuce pour les répertoires partagés Combinez SGID avec umask pour une collaboration optimale :
> 
> ```bash
> # Configuration d'un répertoire de travail collaboratif
> mkdir /travail/commun
> chgrp equipe /travail/commun
> chmod 2775 /travail/commun
> 
> # Les utilisateurs devraient avoir umask 002 ou 007
> # pour que les fichiers créés soient accessibles au groupe
> ```

> [!warning] Points d'attention
> 
> - SGID sur un fichier exécutable est moins utilisé et moins connu que SUID
> - Attention aux conflits si un utilisateur appartient à plusieurs groupes
> - Le groupe primaire de l'utilisateur n'a plus d'effet dans un répertoire SGID

---

## Sticky Bit

### 🎯 Concept et utilité

Le **Sticky Bit** sur un répertoire empêche les utilisateurs de supprimer ou renommer des fichiers qui ne leur appartiennent pas, même s'ils ont les permissions d'écriture sur le répertoire.

> [!example] Cas d'usage typique Le répertoire `/tmp` utilise le sticky bit : tous les utilisateurs peuvent créer des fichiers, mais seul le propriétaire (ou root) peut supprimer ses propres fichiers.

### 📝 Syntaxe et utilisation

#### Activation du Sticky Bit

```bash
# Méthode symbolique
chmod +t repertoire/

# Méthode octale (1 en premier chiffre)
chmod 1777 repertoire/

# Exemple : créer un répertoire de partage temporaire
mkdir /partage/temp
chmod 1777 /partage/temp
```

#### Vérification du Sticky Bit

```bash
# Le 't' ou 'T' apparaît à la place du 'x' pour others
ls -ld /tmp
# drwxrwxrwt 20 root root 4096 déc 26 10:00 /tmp
#         ^ Le 't' indique le sticky bit

# 'T' majuscule = sticky bit sans permission d'exécution pour others
# 't' minuscule = sticky bit avec permission d'exécution pour others
```

#### Comportement pratique

```bash
# Utilisateur1 crée un fichier dans un répertoire avec sticky bit
user1$ touch /tmp/fichier_user1.txt
user1$ ls -l /tmp/fichier_user1.txt
# -rw-r--r-- 1 user1 user1 0 déc 26 10:00 /tmp/fichier_user1.txt

# Utilisateur2 essaie de le supprimer
user2$ rm /tmp/fichier_user1.txt
# rm: impossible de supprimer '/tmp/fichier_user1.txt': Opération non permise

# Mais user2 peut créer son propre fichier
user2$ touch /tmp/fichier_user2.txt
# Succès

# Seul user1, root ou le propriétaire du répertoire peut supprimer fichier_user1.txt
```

#### Recherche des répertoires avec Sticky Bit

```bash
# Trouver tous les répertoires avec sticky bit
find / -type d -perm -1000 2>/dev/null

# Liste détaillée
find / -type d -perm -1000 -ls 2>/dev/null
```

#### Suppression du Sticky Bit

```bash
# Méthode symbolique
chmod -t repertoire/

# Méthode octale
chmod 0777 repertoire/
```

> [!tip] Utilisation recommandée Le sticky bit est idéal pour :
> 
> - Répertoires temporaires partagés (`/tmp`, `/var/tmp`)
> - Espaces de dépôt où chaque utilisateur gère ses propres fichiers
> - Répertoires de travail collaboratifs avec protection contre les suppressions accidentelles

> [!warning] Différence importante Le sticky bit n'empêche **pas** la modification du contenu des fichiers, seulement leur suppression ou renommage. Pour protéger le contenu, utilisez les permissions classiques.

### 📊 Tableau récapitulatif des bits spéciaux

|Bit|Valeur octale|Symbole|Appliqué à|Effet|
|---|---|---|---|---|
|SUID|4000|s (user)|Fichier exécutable|Exécution avec les droits du propriétaire|
|SGID|2000|s (group)|Fichier exécutable|Exécution avec les droits du groupe|
|SGID|2000|s (group)|Répertoire|Héritage du groupe pour les nouveaux fichiers|
|Sticky|1000|t (others)|Répertoire|Protection contre suppression par non-propriétaires|

### 🔢 Combinaison des bits spéciaux

```bash
# SUID + SGID + Sticky bit
chmod 7755 fichier  # Rarement utilisé, généralement dangereux

# SGID + Sticky bit (courant pour répertoires collaboratifs)
chmod 3770 /projets/partage

# Visualisation des combinaisons
# 4755 = SUID + rwxr-xr-x
# 2755 = SGID + rwxr-xr-x
# 1777 = Sticky + rwxrwxrwx
# 6755 = SUID + SGID + rwxr-xr-x
# 3770 = SGID + Sticky + rwxrwx---
```

> [!info] Notation complète en octal Les permissions complètes s'écrivent en **4 chiffres** :
> 
> - 1er chiffre : bits spéciaux (SUID=4, SGID=2, Sticky=1)
> - 2ème chiffre : propriétaire (user)
> - 3ème chiffre : groupe (group)
> - 4ème chiffre : autres (others)

---

## Umask

### 🎯 Concept et utilité

Le **umask** (user file-creation mode mask) définit les permissions **retirées** par défaut lors de la création de nouveaux fichiers et répertoires. C'est un masque de soustraction, pas d'addition.

> [!info] Principe de fonctionnement
> 
> - Permissions maximales par défaut : **666** pour les fichiers, **777** pour les répertoires
> - Le umask **retire** des permissions à ces valeurs maximales
> - Formule : `Permissions finales = Permissions maximales - umask`

### 📝 Syntaxe et utilisation

#### Consultation du umask

```bash
# Afficher le umask actuel (notation octale)
umask
# 0022

# Afficher le umask en notation symbolique
umask -S
# u=rwx,g=rx,o=rx
```

#### Calcul des permissions résultantes

```bash
# Avec umask 0022 (le plus courant)
# Fichier : 666 - 022 = 644 (rw-r--r--)
# Répertoire : 777 - 022 = 755 (rwxr-xr-x)

# Avec umask 0002 (pour travail collaboratif)
# Fichier : 666 - 002 = 664 (rw-rw-r--)
# Répertoire : 777 - 002 = 775 (rwxrwxr-x)

# Avec umask 0077 (restrictif)
# Fichier : 666 - 077 = 600 (rw-------)
# Répertoire : 777 - 077 = 700 (rwx------)
```

#### Modification temporaire du umask

```bash
# Changer le umask pour la session shell actuelle
umask 0002

# Tester l'effet
touch test1.txt
mkdir test_dir
ls -l
# -rw-rw-r-- 1 user group 0 déc 26 test1.txt
# drwxrwxr-x 2 user group 4096 déc 26 test_dir/

# Retour à un umask restrictif
umask 0077
touch test2.txt
ls -l test2.txt
# -rw------- 1 user group 0 déc 26 test2.txt
```

#### Modification permanente du umask

```bash
# Pour un utilisateur spécifique : ~/.bashrc ou ~/.profile
echo "umask 0002" >> ~/.bashrc

# Pour tous les utilisateurs : /etc/profile ou /etc/bashrc
# (nécessite les droits root)
sudo echo "umask 0022" >> /etc/profile

# Appliquer immédiatement
source ~/.bashrc
```

### 📊 Valeurs umask courantes

|Umask|Fichiers créés|Répertoires créés|Usage typique|
|---|---|---|---|
|0022|644 (rw-r--r--)|755 (rwxr-xr-x)|Défaut système, utilisateurs standards|
|0002|664 (rw-rw-r--)|775 (rwxrwxr-x)|Travail collaboratif en groupe|
|0007|660 (rw-rw----)|770 (rwxrwx---)|Groupe privé, exclusion des others|
|0077|600 (rw-------)|700 (rwx------)|Maximum de confidentialité|
|0000|666 (rw-rw-rw-)|777 (rwxrwxrwx)|Partage total (déconseillé)|

> [!example] Scénarios pratiques
> 
> **Développeur solo** :
> 
> ```bash
> umask 0077  # Tous les fichiers privés par défaut
> ```
> 
> **Équipe de développement** :
> 
> ```bash
> umask 0002  # Fichiers accessibles au groupe
> ```
> 
> **Serveur web** :
> 
> ```bash
> umask 0022  # Fichiers lisibles par tous, modifiables par le propriétaire
> ```

> [!tip] Astuce pour les projets collaboratifs Combinez umask 0002 avec SGID sur les répertoires de projet :
> 
> ```bash
> # Configuration du répertoire
> mkdir /projets/app
> chgrp developers /projets/app
> chmod 2775 /projets/app  # SGID + rwxrwxr-x
> 
> # Configuration utilisateur
> umask 0002
> 
> # Résultat : tous les fichiers créés seront rw-rw-r--
> # et appartiendront au groupe "developers"
> ```

> [!warning] Pièges courants
> 
> - Le umask est une **soustraction**, pas une addition (confusion fréquente)
> - Le umask affecte **uniquement** la création de fichiers, pas les fichiers existants
> - Un fichier ne peut jamais avoir la permission d'exécution par défaut (sécurité)
> - Le umask est lié à la session : il faut le définir dans les fichiers de configuration pour le rendre permanent

### 🔍 Déterminer le umask idéal

```bash
# Formule inverse : trouver le umask nécessaire
# umask = Permissions maximales - Permissions souhaitées

# Exemple : je veux que mes fichiers soient rw-r-----  (640)
# umask = 666 - 640 = 026

# Je veux que mes répertoires soient rwxr-x---  (750)
# umask = 777 - 750 = 027

# Compromis : umask 0027 pour les deux
umask 0027
```

---

## ACL (Access Control Lists)

### 🎯 Concept et utilité

Les **ACL** (Access Control Lists) étendent le modèle de permissions traditionnel Linux en permettant de définir des permissions spécifiques pour plusieurs utilisateurs et groupes sur un même fichier ou répertoire, au-delà du trio user/group/others.

> [!info] Pourquoi les ACL ? Les permissions standard limitent à 3 entités : 1 utilisateur, 1 groupe, et "les autres". Les ACL permettent de :
> 
> - Donner des permissions à plusieurs utilisateurs différents
> - Donner des permissions à plusieurs groupes différents
> - Définir des permissions par défaut pour les nouveaux fichiers
> - Créer des configurations de permissions complexes et granulaires

### 📝 Prérequis et vérification

#### Vérifier le support ACL

```bash
# Vérifier si le système de fichiers supporte les ACL
tune2fs -l /dev/sda1 | grep "Default mount options"
# Default mount options:    user_xattr acl

# Vérifier les options de montage actuelles
mount | grep acl
# /dev/sda1 on / type ext4 (rw,relatime,acl)

# Monter avec support ACL si nécessaire
sudo mount -o remount,acl /
```

#### Installation des outils ACL

```bash
# Debian/Ubuntu
sudo apt install acl

# Red Hat/CentOS/Fedora
sudo yum install acl

# Arch Linux
sudo pacman -S acl
```

### 📝 Commandes de base

#### getfacl - Consulter les ACL

```bash
# Afficher les ACL d'un fichier
getfacl fichier.txt

# Sortie typique :
# file: fichier.txt
# owner: alice
# group: users
# user::rw-
# user:bob:r--
# group::r--
# mask::r--
# other::---

# Afficher les ACL d'un répertoire
getfacl -d repertoire/  # -d pour les ACL par défaut

# Format plus compact
getfacl -c fichier.txt  # Sans commentaires
```

#### setfacl - Définir les ACL

```bash
# Donner des permissions de lecture à un utilisateur spécifique
setfacl -m u:bob:r fichier.txt

# Donner des permissions rwx à un utilisateur
setfacl -m u:alice:rwx script.sh

# Donner des permissions à un groupe
setfacl -m g:developers:rw fichier.txt

# Définir plusieurs ACL en une commande
setfacl -m u:bob:r,u:alice:rw,g:admins:rwx fichier.txt

# Retirer une ACL spécifique
setfacl -x u:bob fichier.txt

# Retirer toutes les ACL
setfacl -b fichier.txt
```

### 🔄 ACL récursives et par défaut

#### Application récursive

```bash
# Appliquer des ACL à tous les fichiers d'un répertoire
setfacl -R -m u:bob:rx repertoire/

# -R = récursif (tous les sous-répertoires et fichiers)

# Exemple pratique : donner accès à un projet
setfacl -R -m u:stagiaire:r-x /projets/webapp/
```

#### ACL par défaut

Les ACL par défaut s'appliquent automatiquement aux nouveaux fichiers créés dans un répertoire.

```bash
# Définir une ACL par défaut sur un répertoire
setfacl -d -m u:bob:rw repertoire/

# Les nouveaux fichiers créés hériteront de cette ACL

# Exemple complet : répertoire collaboratif
mkdir /projets/partage
setfacl -m u:alice:rwx,u:bob:rwx /projets/partage
setfacl -d -m u:alice:rwx,u:bob:rwx /projets/partage

# Vérification
getfacl /projets/partage
# file: /projets/partage
# owner: root
# group: root
# user::rwx
# user:alice:rwx
# user:bob:rwx
# group::r-x
# mask::rwx
# other::r-x
# default:user::rwx
# default:user:alice:rwx
# default:user:bob:rwx
# default:group::r-x
# default:mask::rwx
# default:other::r-x
```

### 🎭 Le masque ACL

Le **masque** limite les permissions effectives maximales pour tous les utilisateurs et groupes (sauf le propriétaire et others).

```bash
# Définir le masque
setfacl -m m::r fichier.txt

# Même si bob a rw, le masque r limitera ses permissions à r

# Exemple
setfacl -m u:bob:rw fichier.txt  # bob devrait avoir rw
setfacl -m m::r fichier.txt       # mais le masque limite à r
getfacl fichier.txt
# user:bob:rw-                    # ACL définie
# effective:r--                   # Permission effective à cause du masque
```

> [!info] Calcul des permissions effectives Permissions effectives = Permissions ACL **ET** Masque
> 
> Si l'ACL dit `rwx` et le masque dit `r--`, la permission effective sera `r--`.

### 📊 Exemples pratiques complets

#### Exemple 1 : Projet avec accès multi-utilisateurs

```bash
# Créer un répertoire de projet
mkdir /projets/site_web

# Propriétaire : accès total
chown webmaster:webteam /projets/site_web
chmod 750 /projets/site_web

# Développeurs : lecture/écriture
setfacl -m u:alice:rwx /projets/site_web
setfacl -m u:bob:rwx /projets/site_web

# Designer : lecture seule
setfacl -m u:claire:r-x /projets/site_web

# Stagiaire : lecture uniquement des fichiers HTML
setfacl -R -m u:stagiaire:r /projets/site_web/*.html

# ACL par défaut pour les nouveaux fichiers
setfacl -d -m u:alice:rwx,u:bob:rwx,u:claire:r-x /projets/site_web

# Vérification
getfacl /projets/site_web
```

#### Exemple 2 : Répertoire de logs avec accès audit

```bash
# Répertoire de logs applicatifs
mkdir /var/log/monapp

# Propriétaire : application
chown appuser:appgroup /var/log/monapp
chmod 750 /var/log/monapp

# Équipe support : lecture seule
setfacl -m g:support:r-x /var/log/monapp
setfacl -d -m g:support:r-x /var/log/monapp

# Auditeur externe : lecture ponctuelle
setfacl -m u:auditeur:r-x /var/log/monapp

# Aucun accès pour les autres
chmod o-rwx /var/log/monapp
```

#### Exemple 3 : Sauvegarde et restauration des ACL

```bash
# Sauvegarder les ACL d'un répertoire
getfacl -R /projets/partage > acl_backup.txt

# Restaurer les ACL
setfacl --restore=acl_backup.txt

# Copier les ACL d'un fichier à un autre
getfacl fichier_source.txt | setfacl --set-file=- fichier_destination.txt
```

### 🔍 Interaction avec ls

```bash
# Un '+' apparaît dans les permissions quand des ACL sont présentes
ls -l fichier.txt
# -rw-r--r--+ 1 alice users 1234 déc 26 10:00 fichier.txt
#           ^ Le '+' indique la présence d'ACL

# Pour voir les détails, utiliser getfacl
getfacl fichier.txt
```

### 📊 Tableau de comparaison ACL vs Permissions standards

|Aspect|Permissions standards|ACL|
|---|---|---|
|Utilisateurs|1 propriétaire|Plusieurs utilisateurs|
|Groupes|1 groupe|Plusieurs groupes|
|Granularité|3 catégories (u/g/o)|Illimitée|
|Héritage|Via SGID (groupes)|Via ACL par défaut|
|Complexité|Simple|Plus complexe|
|Support|Universel|Nécessite support système de fichiers|
|Performance|Rapide|Légèrement plus lent|

> [!tip] Quand utiliser les ACL ? Utilisez les ACL quand :
> 
> - Vous avez besoin de permissions pour plus de 3 entités
> - Vous devez gérer des accès temporaires (plus facile à retirer qu'un changement de groupe)
> - Vous voulez un contrôle fin sur les permissions héritées
> - Les permissions standards deviennent trop complexes à gérer
> 
> Restez avec les permissions standards quand :
> 
> - La structure user/group/others suffit
> - Vous privilégiez la simplicité
> - Vous devez assurer la compatibilité maximale

> [!warning] Pièges et limitations
> 
> - Les ACL ne sont pas supportées par tous les systèmes de fichiers (vérifiez avant)
> - Les outils de sauvegarde doivent supporter les ACL (tar avec `--acls`, rsync avec `-A`)
> - Les ACL complexes peuvent devenir difficiles à maintenir et auditer
> - Le masque ACL peut limiter des permissions de façon non intuitive
> - Les ACL ne se copient pas automatiquement avec `cp` (utiliser `cp -a` ou `cp --preserve=all`)

### 🔧 Commandes avancées

```bash
# Copier les ACL avec les fichiers
cp -a --preserve=all source.txt destination.txt

# Synchroniser avec les ACL
rsync -avAX source/ destination/
# -A = préserver les ACL
# -X = préserver les attributs étendus

# Supprimer toutes les ACL étendues, garder uniquement les permissions de base
setfacl -b fichier.txt

# Afficher uniquement les entrées ACL (sans les permissions de base)
getfacl --access fichier.txt

# Modifier les ACL de façon interactive (depuis un fichier)
getfacl fichier1.txt > acl.tmp
# Éditer acl.tmp
setfacl --set-file=acl.tmp fichier2.txt
```

---

## 🎓 Synthèse des permissions avancées

### Ordre de priorité des mécanismes

1. **ACL utilisateur spécifique** (si définie)
2. **Propriétaire du fichier** (user)
3. **ACL groupe spécifique** (si définie)
4. **Groupe propriétaire** (group)
5. **Autres** (others)

### Combinaisons courantes

```bash
# Répertoire collaboratif optimal
mkdir /projets/equipe
chgrp developers /projets/equipe
chmod 2770 /projets/equipe              # SGID + rwxrwx---
setfacl -d -m g::rwx /projets/equipe    # ACL par défaut
# Les utilisateurs doivent avoir umask 0002

# Répertoire public avec protection
mkdir /public/depot
chmod 1777 /public/depot                # Sticky bit + rwxrwxrwx
# Tout le monde peut créer, mais seul le propriétaire peut supprimer

# Script système privilégié
chmod 4750 /usr/local/bin/admin_tool   # SUID + rwxr-x---
chown root:admins /usr/local/bin/admin_tool
# Seuls les admins peuvent exécuter avec les privilèges root
```

### Checklist de sécurité

> [!warning] Points de vigilance
> 
> ✅ **À faire** :
> 
> - Auditer régulièrement les fichiers SUID/SGID : `find / -perm -4000 -o -perm -2000`
> - Documenter toutes les ACL complexes dans votre documentation système
> - Établir une baseline des fichiers avec bits spéciaux et surveiller les changements
> - Utiliser `umask 0077` pour les données sensibles, `0002` pour le travail collaboratif
> - Sauvegarder les ACL lors des backups : `getfacl -R / > acl_backup.txt`
> - Tester les permissions avec différents utilisateurs avant la mise en production
> - Combiner SGID + umask approprié pour les répertoires partagés
> - Utiliser le sticky bit sur tous les répertoires temporaires publics
> 
> ❌ **À éviter** :
> 
> - SUID sur des scripts shell (ignoré par le système de toute façon)
> - SUID sur des programmes acceptant une entrée utilisateur non validée
> - umask 0000 (permissions totales par défaut = dangereux)
> - ACL trop complexes difficiles à maintenir
> - Oublier les ACL par défaut sur les répertoires collaboratifs
> - Copier des fichiers sans préserver les ACL (`cp` sans `-a`)
> - Laisser des fichiers SUID/SGID appartenant à des utilisateurs non-root sans justification

### Commandes de diagnostic

```bash
# Audit complet des permissions spéciales
echo "=== Fichiers SUID ==="
find / -perm -4000 -type f -ls 2>/dev/null

echo "=== Fichiers SGID ==="
find / -perm -2000 -type f -ls 2>/dev/null

echo "=== Répertoires avec Sticky Bit ==="
find / -perm -1000 -type d -ls 2>/dev/null

echo "=== Fichiers avec ACL ==="
find / -type f -exec getfacl {} \; 2>/dev/null | grep "file:"

echo "=== Umask actuel ==="
umask
umask -S

# Script de surveillance des changements
#!/bin/bash
# Créer une baseline
find / -perm -4000 -o -perm -2000 -o -perm -1000 > /var/log/special_perms_baseline.txt

# Comparer régulièrement (dans un cron)
find / -perm -4000 -o -perm -2000 -o -perm -1000 > /tmp/special_perms_current.txt
diff /var/log/special_perms_baseline.txt /tmp/special_perms_current.txt
```

### Tableau récapitulatif final

|Mécanisme|Notation|Valeur octale|S'applique à|Objectif principal|
|---|---|---|---|---|
|SUID|u+s|4000|Fichiers exécutables|Exécution avec droits du propriétaire|
|SGID|g+s|2000|Fichiers exécutables|Exécution avec droits du groupe|
|SGID|g+s|2000|Répertoires|Héritage automatique du groupe|
|Sticky Bit|+t|1000|Répertoires|Protection contre suppression|
|Umask|umask|Valeur|Processus|Permissions par défaut des nouveaux fichiers|
|ACL|setfacl|-|Fichiers/Répertoires|Permissions granulaires multi-utilisateurs|

### Exemples de scénarios réels

#### Scénario 1 : Environnement de développement

```bash
# Structure d'équipe avec 3 développeurs et 1 designer
mkdir -p /projets/webapp/{src,assets,docs}

# Configuration de base
chown -R lead:devteam /projets/webapp
find /projets/webapp -type d -exec chmod 2770 {} \;  # SGID sur répertoires
find /projets/webapp -type f -exec chmod 660 {} \;   # Fichiers rw-rw----

# ACL pour accès spécifiques
# Designer : lecture seule sur assets, pas d'accès au code
setfacl -R -m u:designer:r-x /projets/webapp/assets
setfacl -d -m u:designer:r-x /projets/webapp/assets

# Stagiaire : lecture seule partout
setfacl -R -m u:stagiaire:r-x /projets/webapp
setfacl -R -d -m u:stagiaire:r-x /projets/webapp

# Client : lecture seule sur docs uniquement
setfacl -R -m u:client:r-x /projets/webapp/docs
setfacl -d -m u:client:r-x /projets/webapp/docs

# Umask pour les développeurs
echo "umask 0002" >> /home/dev1/.bashrc
echo "umask 0002" >> /home/dev2/.bashrc
echo "umask 0002" >> /home/dev3/.bashrc
```

#### Scénario 2 : Serveur web avec logging

```bash
# Répertoire web public
mkdir -p /var/www/html
chown www-data:www-data /var/www/html
chmod 755 /var/www/html

# Répertoire d'upload avec sticky bit
mkdir /var/www/html/uploads
chown www-data:www-data /var/www/html/uploads
chmod 1733 /var/www/html/uploads  # Sticky + rwx-wx-wx
# Les utilisateurs peuvent uploader, mais pas supprimer les fichiers des autres

# Logs accessibles à l'équipe support
mkdir /var/log/webapp
chown www-data:www-data /var/log/webapp
chmod 750 /var/log/webapp
setfacl -m g:support:r-x /var/log/webapp
setfacl -d -m g:support:r-x /var/log/webapp

# Script de rotation avec SUID (attention !)
# Uniquement si absolument nécessaire et bien sécurisé
cat > /usr/local/bin/rotate_logs.sh << 'EOF'
#!/bin/bash
# Script sécurisé de rotation
cd /var/log/webapp || exit 1
gzip -9 access.log
mv access.log.gz "access.$(date +%Y%m%d).log.gz"
touch access.log
chown www-data:www-data access.log
EOF

chmod 4750 /usr/local/bin/rotate_logs.sh
chown root:logadmins /usr/local/bin/rotate_logs.sh
```

#### Scénario 3 : Répertoire partagé entre départements

```bash
# Espace de collaboration inter-départements
mkdir -p /partage/{marketing,tech,commun}

# Marketing : accès total à leur dossier
chgrp marketing /partage/marketing
chmod 2770 /partage/marketing
setfacl -d -m g::rwx /partage/marketing

# Tech : accès total à leur dossier
chgrp tech /partage/tech
chmod 2770 /partage/tech
setfacl -d -m g::rwx /partage/tech

# Commun : accessible aux deux groupes
chgrp marketing /partage/commun
chmod 2770 /partage/commun
setfacl -m g:tech:rwx /partage/commun
setfacl -d -m g:marketing:rwx,g:tech:rwx /partage/commun

# Le manager a accès à tout
setfacl -R -m u:manager:rwx /partage
setfacl -R -d -m u:manager:rwx /partage

# Protection avec sticky bit sur commun pour éviter suppressions accidentelles
chmod 3770 /partage/commun  # SGID + Sticky + rwxrwx---
```

### Débogage des problèmes de permissions

```bash
# Test 1 : Vérifier les permissions effectives d'un utilisateur
sudo -u utilisateur test -r fichier.txt && echo "Lecture OK" || echo "Lecture refusée"
sudo -u utilisateur test -w fichier.txt && echo "Écriture OK" || echo "Écriture refusée"
sudo -u utilisateur test -x fichier.txt && echo "Exécution OK" || echo "Exécution refusée"

# Test 2 : Simuler l'accès d'un utilisateur
sudo -u bob ls -la /projets/partage
sudo -u bob cat /projets/partage/fichier.txt

# Test 3 : Voir les permissions effectives avec ACL
getfacl fichier.txt | grep "effective"

# Test 4 : Tracer les appels système de permissions
strace -e trace=access,open,openat,stat ls -l fichier.txt 2>&1 | grep EACCES

# Test 5 : Afficher les capacités d'un fichier (si utilisées)
getcap /usr/bin/ping

# Test 6 : Vérifier l'appartenance aux groupes
groups utilisateur
id utilisateur
```

### Résolution de problèmes courants

> [!example] Problème : "Permission denied" malgré les bonnes permissions
> 
> **Causes possibles** :
> 
> ```bash
> # 1. Vérifier le masque ACL
> getfacl fichier.txt | grep mask
> # Si mask::r--, les permissions effectives sont limitées
> 
> # 2. Vérifier les permissions des répertoires parents
> namei -l /chemin/vers/fichier.txt
> # Tous les répertoires parents doivent avoir +x
> 
> # 3. Vérifier SELinux/AppArmor
> getenforce  # SELinux
> aa-status   # AppArmor
> # Si Enforcing, vérifier le contexte de sécurité
> 
> # 4. Vérifier les attributs étendus
> lsattr fichier.txt
> # 'i' = immutable (même root ne peut pas modifier)
> # Retirer avec : chattr -i fichier.txt
> ```

> [!example] Problème : Les nouveaux fichiers n'ont pas les bonnes permissions
> 
> **Solutions** :
> 
> ```bash
> # 1. Vérifier le umask
> umask
> 
> # 2. Vérifier les ACL par défaut du répertoire
> getfacl -d repertoire/
> 
> # 3. Vérifier le SGID
> ls -ld repertoire/
> # Doit afficher 's' dans les permissions du groupe
> 
> # 4. Corriger la configuration
> setfacl -d -m g::rwx repertoire/
> chmod g+s repertoire/
> echo "umask 0002" >> ~/.bashrc
> ```

> [!example] Problème : Impossible de supprimer un fichier dans un répertoire
> 
> **Diagnostic** :
> 
> ```bash
> # 1. Vérifier le sticky bit
> ls -ld repertoire/
> # Si 't' présent, seul le propriétaire peut supprimer
> 
> # 2. Vérifier l'attribut immutable
> lsattr fichier
> 
> # 3. Vérifier les processus utilisant le fichier
> lsof fichier
> 
> # 4. Vérifier les montages
> findmnt -T repertoire/
> # Si 'ro' (read-only), le système de fichiers est en lecture seule
> ```

### Outils d'analyse et d'audit

```bash
# Générer un rapport complet des permissions
#!/bin/bash
echo "=== RAPPORT DE SÉCURITÉ DES PERMISSIONS ==="
echo "Date: $(date)"
echo ""

echo "1. Fichiers SUID (attention : risque de sécurité)"
find / -perm -4000 -type f 2>/dev/null | while read file; do
    ls -l "$file"
    echo "   Propriétaire: $(stat -c %U "$file")"
done

echo ""
echo "2. Fichiers SGID"
find / -perm -2000 -type f 2>/dev/null | head -20

echo ""
echo "3. Répertoires avec sticky bit"
find / -perm -1000 -type d 2>/dev/null | head -20

echo ""
echo "4. Fichiers avec ACL complexes (>3 entrées)"
find /home /var /opt -type f 2>/dev/null | while read file; do
    acl_count=$(getfacl "$file" 2>/dev/null | grep -c "^user:\|^group:")
    if [ "$acl_count" -gt 3 ]; then
        echo "$file ($acl_count entrées ACL)"
    fi
done

echo ""
echo "5. Fichiers world-writable (dangereux !)"
find / -type f -perm -002 ! -type l 2>/dev/null

echo ""
echo "6. Répertoires avec permissions trop permissives"
find / -type d -perm -777 2>/dev/null
```

---

## 🎯 Points clés à retenir

1. **SUID** : Exécution avec les droits du propriétaire - utilisez avec **extrême prudence**
2. **SGID** : Sur fichiers = droits du groupe, sur répertoires = héritage du groupe
3. **Sticky Bit** : Protection contre la suppression dans les répertoires partagés
4. **Umask** : Définit les permissions **retirées** par défaut (c'est une soustraction !)
5. **ACL** : Permissions granulaires quand user/group/others ne suffit plus

> [!tip] Philosophie générale
> 
> - Utilisez les permissions standard autant que possible (principe KISS)
> - Ajoutez les bits spéciaux uniquement quand nécessaire
> - Réservez les ACL pour les cas vraiment complexes
> - Documentez toute configuration non-standard
> - Auditez régulièrement votre système
> - Testez toujours avec des utilisateurs réels avant la production

> [!warning] Règle d'or de sécurité **Le principe du moindre privilège** : donnez toujours le minimum de permissions nécessaires pour accomplir une tâche, jamais plus. Chaque permission supplémentaire est une surface d'attaque potentielle.