

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

## Introduction aux permissions

Les permissions de fichiers constituent le système de sécurité fondamental de Linux. Elles déterminent qui peut lire, modifier ou exécuter un fichier ou répertoire. Ce mécanisme protège les données et empêche les modifications non autorisées.

> [!info] Pourquoi les permissions sont importantes
> 
> - **Sécurité** : Empêchent les accès non autorisés aux fichiers sensibles
> - **Multi-utilisateurs** : Permettent à plusieurs utilisateurs de coexister sur le même système
> - **Isolation** : Protègent les fichiers système des modifications accidentelles
> - **Partage contrôlé** : Permettent de partager des fichiers avec des restrictions

---

## Le modèle rwx

Linux utilise trois types de permissions de base, représentées par les lettres **r**, **w**, et **x**.

### 📖 Lecture (r - read)

**Pour un fichier :**

- Permet de lire le contenu du fichier
- Nécessaire pour copier, afficher ou ouvrir un fichier

**Pour un répertoire :**

- Permet de lister le contenu du répertoire (commande `ls`)
- Sans cette permission, vous ne pouvez pas voir les fichiers qu'il contient

> [!example] Exemple pratique
> 
> ```bash
> # Avec permission de lecture
> cat document.txt  # ✓ Fonctionne
> 
> # Sans permission de lecture
> cat document.txt  # ✗ Permission denied
> ```

### ✍️ Écriture (w - write)

**Pour un fichier :**

- Permet de modifier le contenu du fichier
- Permet de supprimer le fichier
- Permet de renommer le fichier

**Pour un répertoire :**

- Permet de créer de nouveaux fichiers dans le répertoire
- Permet de supprimer des fichiers du répertoire
- Permet de renommer des fichiers dans le répertoire

> [!warning] Attention La permission d'écriture sur un répertoire permet de supprimer n'importe quel fichier qu'il contient, même si vous n'avez pas les permissions sur le fichier lui-même !

### 🚀 Exécution (x - execute)

**Pour un fichier :**

- Permet d'exécuter le fichier comme un programme ou un script
- Nécessaire pour les binaires et les scripts shell

**Pour un répertoire :**

- Permet de traverser le répertoire (commande `cd`)
- Nécessaire pour accéder aux fichiers qu'il contient
- Même avec la permission de lecture, sans `x` vous ne pouvez pas accéder au contenu

> [!example] Exemple pratique
> 
> ```bash
> # Pour un script
> ./mon_script.sh  # Nécessite la permission x
> 
> # Pour un répertoire
> cd /home/user/documents  # Nécessite la permission x
> ```

---

## Les trois catégories d'utilisateurs

Linux divise les utilisateurs en trois catégories pour chaque fichier ou répertoire.

### 👤 Propriétaire (User - u)

- C'est l'utilisateur qui possède le fichier
- Généralement celui qui l'a créé
- A le contrôle total sur les permissions

### 👥 Groupe (Group - g)

- Un ensemble d'utilisateurs partageant les mêmes permissions
- Utile pour le travail collaboratif
- Chaque fichier appartient à un groupe

### 🌍 Autres (Others - o)

- Tous les autres utilisateurs du système
- N'inclut ni le propriétaire ni les membres du groupe
- Représente le "reste du monde"

> [!info] Visualisation
> 
> ```
> -rwxr-xr--
>  |||├─────┘ Autres (others) : r-- (lecture seule)
>  |||└────────┘ Groupe (group) : r-x (lecture + exécution)
>  └┴┴────────────┘ Propriétaire (user) : rwx (toutes permissions)
> ```

---

## Représentation symbolique

La représentation symbolique affiche les permissions sous forme de lettres. C'est ce que vous voyez avec la commande `ls -l`.

### Format général

```
-rwxrwxrwx
│└┬┘└┬┘└┬┘
│ │  │  └─── Permissions pour les autres (o)
│ │  └────── Permissions pour le groupe (g)
│ └───────── Permissions pour le propriétaire (u)
└─────────── Type de fichier
```

### Types de fichiers (premier caractère)

|Symbole|Type|Description|
|---|---|---|
|`-`|Fichier régulier|Fichier normal|
|`d`|Répertoire|Dossier|
|`l`|Lien symbolique|Raccourci vers un autre fichier|
|`b`|Périphérique bloc|Disque dur, clé USB|
|`c`|Périphérique caractère|Terminal, imprimante|
|`p`|Tube nommé|Communication inter-processus|
|`s`|Socket|Communication réseau|

### Lecture des permissions

```bash
ls -l fichier.txt
-rw-r--r-- 1 user group 1024 Dec 26 10:30 fichier.txt
```

Décomposition : `-rw-r--r--`

- `-` : Fichier régulier
- `rw-` : Propriétaire peut lire et écrire
- `r--` : Groupe peut seulement lire
- `r--` : Autres peuvent seulement lire

> [!example] Exemples courants
> 
> ```bash
> # Fichier texte classique
> -rw-r--r--  # 644
> 
> # Script exécutable
> -rwxr-xr-x  # 755
> 
> # Répertoire accessible à tous
> drwxr-xr-x  # 755
> 
> # Fichier privé
> -rw-------  # 600
> 
> # Répertoire privé
> drwx------  # 700
> ```

---

## Représentation octale

La représentation octale utilise des chiffres de 0 à 7 pour représenter les permissions. C'est plus compact et souvent utilisée avec la commande `chmod`.

### Conversion rwx → octal

Chaque permission a une valeur :

- `r` (read) = 4
- `w` (write) = 2
- `x` (execute) = 1

On additionne ces valeurs pour obtenir un chiffre de 0 à 7.

|Binaire|Octal|Symbolique|Signification|
|---|---|---|---|
|000|0|`---`|Aucune permission|
|001|1|`--x`|Exécution seule|
|010|2|`-w-`|Écriture seule|
|011|3|`-wx`|Écriture + Exécution|
|100|4|`r--`|Lecture seule|
|101|5|`r-x`|Lecture + Exécution|
|110|6|`rw-`|Lecture + Écriture|
|111|7|`rwx`|Toutes permissions|

### Exemples de calcul

```
rwx = 4 + 2 + 1 = 7
rw- = 4 + 2 + 0 = 6
r-x = 4 + 0 + 1 = 5
r-- = 4 + 0 + 0 = 4
--- = 0 + 0 + 0 = 0
```

### Permissions complètes en octal

On utilise trois chiffres : un pour le propriétaire, un pour le groupe, un pour les autres.

> [!example] Exemples de permissions octales courantes
> 
> ```
> 755 = rwxr-xr-x  # Exécutables, scripts
> 644 = rw-r--r--  # Fichiers texte, documents
> 600 = rw-------  # Fichiers privés (clés SSH)
> 700 = rwx------  # Répertoires privés
> 777 = rwxrwxrwx  # Toutes permissions (⚠️ dangereux)
> 000 = ---------  # Aucune permission
> ```

> [!tip] Astuce de mémorisation
> 
> - **7** : Tout (rwx) - propriétaire
> - **5** : Lecture + exécution (r-x) - utilisateurs standards
> - **4** : Lecture seule (r--) - invités
> 
> D'où le fameux **755** pour les fichiers partagés et **644** pour les documents.

---

## Commande chmod

La commande `chmod` (change mode) permet de modifier les permissions d'un fichier ou répertoire.

### Syntaxe générale

```bash
chmod [options] permissions fichier
```

### Mode symbolique

Le mode symbolique utilise des lettres pour modifier les permissions.

**Structure :** `[qui][opération][permissions]`

|Élément|Symboles|Signification|
|---|---|---|
|**Qui**|`u`|Propriétaire (user)|
||`g`|Groupe (group)|
||`o`|Autres (others)|
||`a`|Tous (all)|
|**Opération**|`+`|Ajouter|
||`-`|Retirer|
||`=`|Définir exactement|
|**Permissions**|`r`|Lecture|
||`w`|Écriture|
||`x`|Exécution|

> [!example] Exemples mode symbolique
> 
> ```bash
> # Ajouter l'exécution pour le propriétaire
> chmod u+x script.sh
> 
> # Retirer l'écriture pour le groupe et les autres
> chmod go-w document.txt
> 
> # Donner lecture à tous
> chmod a+r fichier.txt
> 
> # Définir exactement rwx pour le propriétaire, rx pour les autres
> chmod u=rwx,go=rx programme
> 
> # Ajouter exécution pour tous
> chmod +x script.sh  # Équivalent à a+x
> 
> # Retirer toutes permissions pour les autres
> chmod o-rwx secret.txt
> 
> # Combiner plusieurs modifications
> chmod u+x,g+w,o-r fichier.txt
> ```

### Mode octal

Le mode octal définit directement toutes les permissions avec trois chiffres.

```bash
chmod 755 fichier
chmod 644 document.txt
chmod 600 cle_privee
```

> [!example] Exemples mode octal
> 
> ```bash
> # Fichier exécutable standard
> chmod 755 /usr/local/bin/monprogramme
> 
> # Document lisible par tous
> chmod 644 README.md
> 
> # Fichier strictement privé
> chmod 600 ~/.ssh/id_rsa
> 
> # Répertoire privé
> chmod 700 ~/documents_perso
> 
> # Configuration système
> chmod 644 /etc/config.conf
> 
> # Script personnel
> chmod 750 ~/scripts/backup.sh
> ```

### Options importantes

|Option|Description|
|---|---|
|`-R`|Récursif : applique aux sous-répertoires|
|`-v`|Verbeux : affiche les modifications|
|`-c`|Affiche uniquement les fichiers modifiés|
|`--reference=fichier`|Copie les permissions d'un autre fichier|

> [!example] Exemples avec options
> 
> ```bash
> # Changer récursivement tous les fichiers d'un répertoire
> chmod -R 755 /var/www/html/
> 
> # Afficher les changements effectués
> chmod -v 644 *.txt
> 
> # Copier les permissions d'un fichier
> chmod --reference=fichier1.txt fichier2.txt
> 
> # Récursif avec affichage des changements uniquement
> chmod -Rc 644 documents/
> ```

> [!warning] Attention avec -R L'option `-R` change TOUS les fichiers et sous-répertoires. Utilisez-la avec précaution :
> 
> ```bash
> # ⚠️ Dangereux - donne toutes permissions à tout
> chmod -R 777 /
> 
> # ✓ Mieux - cibler précisément
> chmod -R 755 /var/www/monsite
> ```

---

## Commande chown

La commande `chown` (change owner) permet de modifier le propriétaire et/ou le groupe d'un fichier.

### Syntaxe générale

```bash
chown [options] [propriétaire][:groupe] fichier
```

### Modifier le propriétaire seul

```bash
# Changer le propriétaire
chown alice fichier.txt

# Avec chemin complet
chown bob /home/shared/document.pdf
```

### Modifier propriétaire et groupe

```bash
# Changer propriétaire et groupe
chown alice:developers projet.txt

# Même résultat avec un point (ancienne syntaxe)
chown alice.developers projet.txt
```

### Modifier uniquement le groupe

```bash
# Deux syntaxes possibles
chown :developers fichier.txt
chown .developers fichier.txt
```

> [!example] Exemples pratiques
> 
> ```bash
> # Transférer un fichier à un utilisateur
> sudo chown marie:marie /tmp/rapport.pdf
> 
> # Changer le propriétaire d'un répertoire web
> sudo chown www-data:www-data /var/www/html/index.html
> 
> # Récupérer la propriété d'un fichier
> sudo chown $USER:$USER mon_fichier.txt
> 
> # Changer récursivement un répertoire complet
> sudo chown -R apache:apache /var/www/monsite/
> 
> # Copier le propriétaire d'un autre fichier
> sudo chown --reference=fichier1.txt fichier2.txt
> ```

### Options importantes

|Option|Description|
|---|---|
|`-R`|Récursif : applique aux sous-répertoires|
|`-v`|Verbeux : affiche les modifications|
|`-c`|Affiche uniquement les changements effectués|
|`--from=ANCIEN`|Change uniquement si propriétaire actuel correspond|
|`--reference=fichier`|Copie le propriétaire d'un autre fichier|

> [!example] Exemples avec options
> 
> ```bash
> # Changer récursivement avec affichage
> sudo chown -Rv alice:users ~/projets/
> 
> # Changer uniquement si actuellement propriété de bob
> sudo chown --from=bob alice fichier.txt
> 
> # Afficher les changements effectués
> sudo chown -c marie:developers *.txt
> ```

> [!warning] Permissions root nécessaires La commande `chown` nécessite généralement les privilèges root (sudo) :
> 
> ```bash
> # ✗ Échouera sans privilèges
> chown alice fichier.txt
> 
> # ✓ Avec sudo
> sudo chown alice fichier.txt
> ```

> [!tip] Retrouver le propriétaire actuel
> 
> ```bash
> # Voir propriétaire et groupe
> ls -l fichier.txt
> 
> # Format détaillé
> stat fichier.txt
> 
> # Juste propriétaire et groupe
> stat -c "%U %G" fichier.txt
> ```

---

## Commande chgrp

La commande `chgrp` (change group) permet de modifier uniquement le groupe d'un fichier. C'est une alternative spécialisée à `chown :groupe`.

### Syntaxe générale

```bash
chgrp [options] groupe fichier
```

### Utilisation basique

```bash
# Changer le groupe d'un fichier
chgrp developers projet.txt

# Changer le groupe de plusieurs fichiers
chgrp admins fichier1.txt fichier2.txt

# Avec un chemin complet
chgrp www-data /var/www/html/index.html
```

> [!example] Exemples pratiques
> 
> ```bash
> # Partager un fichier avec une équipe
> sudo chgrp equipe-dev application.conf
> 
> # Changer le groupe d'un répertoire web
> sudo chgrp www-data /var/www/uploads/
> 
> # Assigner à un groupe système
> sudo chgrp docker /var/run/docker.sock
> 
> # Changer récursivement pour un projet
> sudo chgrp -R developers /home/shared/projet/
> ```

### Options importantes

|Option|Description|
|---|---|
|`-R`|Récursif : applique aux sous-répertoires|
|`-v`|Verbeux : affiche les modifications|
|`-c`|Affiche uniquement les fichiers modifiés|
|`--reference=fichier`|Copie le groupe d'un autre fichier|

> [!example] Exemples avec options
> 
> ```bash
> # Changer récursivement avec affichage
> sudo chgrp -Rv developers ~/projets/
> 
> # Copier le groupe d'un autre fichier
> sudo chgrp --reference=config.old config.new
> 
> # Afficher uniquement les changements
> sudo chgrp -c admins *.log
> ```

### Comparaison chgrp vs chown

```bash
# Ces commandes sont équivalentes
chgrp developers fichier.txt
chown :developers fichier.txt

# chgrp est plus explicite pour changer uniquement le groupe
# chown est plus flexible pour changer propriétaire ET groupe
```

> [!info] Quand utiliser chgrp ?
> 
> - Quand vous voulez changer UNIQUEMENT le groupe
> - Pour plus de clarté dans les scripts
> - Quand vous travaillez dans un contexte d'équipe
> 
> Utilisez `chown` pour modifier le propriétaire ou les deux à la fois.

> [!tip] Vérifier les groupes disponibles
> 
> ```bash
> # Lister tous les groupes du système
> cat /etc/group
> 
> # Voir les groupes de l'utilisateur actuel
> groups
> 
> # Voir les groupes d'un utilisateur spécifique
> groups alice
> 
> # Afficher groupe d'un fichier
> ls -l fichier.txt
> stat -c "%G" fichier.txt
> ```

---

## Pièges courants

### ⚠️ Permissions 777 - Le danger universel

```bash
# ⚠️ DANGEREUX - Ne jamais faire ça !
chmod 777 fichier.txt
chmod -R 777 /var/www/
```

**Pourquoi c'est dangereux :**

- N'importe quel utilisateur peut modifier ou supprimer le fichier
- Faille de sécurité majeure
- Porte d'entrée pour les malwares

**Alternative correcte :**

```bash
# Identifier le vrai problème d'abord
ls -l fichier.txt

# Donner les permissions appropriées
chmod 755 fichier.txt  # Pour les exécutables
chmod 644 fichier.txt  # Pour les documents
```

### ⚠️ Oublier le x sur les répertoires

```bash
# Permission de lecture mais pas d'exécution sur un répertoire
chmod 644 mon_dossier/
```

**Problème :**

- Vous pouvez voir que le répertoire existe
- Mais vous ne pouvez pas y entrer (`cd`) ni accéder à ses fichiers

**Solution :**

```bash
# Les répertoires ont TOUJOURS besoin du x
chmod 755 mon_dossier/  # Correct
```

### ⚠️ Confondre propriétaire et permissions

```bash
# Être propriétaire ne donne pas automatiquement toutes les permissions
-r--r--r-- 1 alice users fichier.txt
```

Alice est propriétaire mais ne peut que lire le fichier !

**Solution :**

```bash
# Ajouter les permissions d'écriture
chmod u+w fichier.txt
```

### ⚠️ chmod -R sans réflexion

```bash
# ⚠️ Change TOUT, y compris ce que vous ne voulez pas
chmod -R 755 ~/
```

**Problème :**

- Change les permissions de TOUS vos fichiers
- Rend vos fichiers privés lisibles par tous
- Peut rendre des fichiers non-exécutables exécutables

**Solution :**

```bash
# Être spécifique
find ~/projet -type d -exec chmod 755 {} \;  # Seulement les répertoires
find ~/projet -type f -exec chmod 644 {} \;  # Seulement les fichiers
```

### ⚠️ Permissions sur les fichiers sensibles

```bash
# ⚠️ Clé SSH lisible par tous
-rw-r--r-- 1 alice users /home/alice/.ssh/id_rsa
```

**Solution :**

```bash
# Les clés privées DOIVENT être en 600
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub  # Clé publique OK
chmod 700 ~/.ssh/  # Répertoire .ssh
```

### ⚠️ Oublier sudo pour chown/chgrp

```bash
# ✗ Permission denied
chown bob fichier.txt

# ✓ Avec sudo
sudo chown bob fichier.txt
```

> [!warning] Vérifier avant de valider Avant d'exécuter une commande de permission :
> 
> ```bash
> # 1. Voir l'état actuel
> ls -l fichier.txt
> 
> # 2. Faire un test sur une copie
> cp fichier.txt fichier_test.txt
> chmod 755 fichier_test.txt
> 
> # 3. Vérifier le résultat
> ls -l fichier_test.txt
> 
> # 4. Appliquer si OK
> chmod 755 fichier.txt
> ```

---

## Bonnes pratiques

### 🎯 Principe du moindre privilège

Donnez toujours le minimum de permissions nécessaires.

```bash
# ✓ Fichier de configuration
chmod 644 config.conf  # Lecture pour tous, écriture pour le propriétaire

# ✓ Script privé
chmod 700 mon_script.sh  # Propriétaire uniquement

# ✓ Répertoire partagé en lecture
chmod 755 /var/www/html/  # Tous peuvent lire, seul le propriétaire modifie
```

### 🎯 Permissions standards recommandées

|Type|Permissions|Octal|Usage|
|---|---|---|---|
|Fichier texte|`-rw-r--r--`|644|Documents, fichiers de config|
|Fichier privé|`-rw-------`|600|Clés SSH, mots de passe|
|Exécutable|`-rwxr-xr-x`|755|Scripts, binaires|
|Répertoire public|`drwxr-xr-x`|755|Dossiers web, partage|
|Répertoire privé|`drwx------`|700|Home, données perso|

### 🎯 Scripts avec bonnes permissions

```bash
#!/bin/bash
# Script d'installation avec vérification des permissions

# Créer un répertoire avec les bonnes permissions
install -d -m 755 /opt/mon_application

# Copier un fichier avec permissions
install -m 644 config.conf /etc/mon_app/

# Créer un exécutable
install -m 755 mon_script.sh /usr/local/bin/

# Fichier sensible
install -m 600 secret.key /etc/mon_app/
```

### 🎯 Vérifier avant de modifier

```bash
# Toujours vérifier l'état actuel
ls -la fichier.txt

# Utiliser stat pour plus de détails
stat fichier.txt

# Tester sur une copie d'abord
cp fichier.txt fichier_test.txt
chmod 755 fichier_test.txt
# Vérifier que ça fonctionne
# Puis appliquer sur l'original
```

### 🎯 Sécuriser les fichiers sensibles

```bash
# Configuration SSH stricte
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_rsa
chmod 644 ~/.ssh/id_rsa.pub
chmod 600 ~/.ssh/config
chmod 600 ~/.ssh/authorized_keys

# Fichiers de configuration système
sudo chmod 644 /etc/nginx/nginx.conf
sudo chmod 640 /etc/shadow  # Mots de passe hashés
sudo chmod 644 /etc/passwd

# Logs avec groupe adm
sudo chmod 640 /var/log/syslog
sudo chown root:adm /var/log/syslog
```

### 🎯 Permissions pour un serveur web

```bash
# Structure typique d'un site web
sudo chown -R www-data:www-data /var/www/monsite/

# Répertoires
find /var/www/monsite/ -type d -exec chmod 755 {} \;

# Fichiers PHP/HTML
find /var/www/monsite/ -type f -exec chmod 644 {} \;

# Répertoire d'upload avec écriture
sudo chmod 775 /var/www/monsite/uploads/
sudo chown -R www-data:www-data /var/www/monsite/uploads/
```

### 🎯 Permissions pour les projets collaboratifs

```bash
# Créer un groupe de projet
sudo groupadd dev-team

# Ajouter les membres
sudo usermod -aG dev-team alice
sudo usermod -aG dev-team bob

# Configurer le répertoire projet
sudo chown -R :dev-team /home/projets/webapp/
sudo chmod -R 775 /home/projets/webapp/

# Forcer les nouveaux fichiers à hériter du groupe (setgid)
sudo chmod g+s /home/projets/webapp/
```

### 🎯 Documentation et traçabilité

```bash
# Commenter les changements de permissions dans les scripts
# TOUJOURS expliquer pourquoi une permission spécifique

# Mauvais
chmod 777 fichier.txt

# Bon
# Permission 644 : Le fichier de config doit être lu par nginx (groupe www-data)
# mais seul root peut le modifier pour éviter les injections
sudo chmod 644 /etc/nginx/sites-available/default
sudo chown root:www-data /etc/nginx/sites-available/default
```

> [!tip] Automatiser les vérifications
> 
> ```bash
> # Script de vérification des permissions
> #!/bin/bash
> 
> # Vérifier les fichiers sensibles
> echo "Vérification des permissions critiques..."
> 
> if [ $(stat -c %a ~/.ssh/id_rsa) != "600" ]; then
>     echo "⚠️  Clé SSH mal protégée!"
>     chmod 600 ~/.ssh/id_rsa
> fi
> 
> if [ $(stat -c %a ~/.ssh) != "700" ]; then
>     echo "⚠️  Répertoire .ssh mal protégé!"
>     chmod 700 ~/.ssh
> fi
> 
> echo "✓ Vérification terminée"
> ```

---

## 🎓 Résumé

### Points clés à retenir

1. **Trois types de permissions** : Lecture (r), Écriture (w), Exécution (x)
2. **Trois catégories** : Propriétaire (u), Groupe (g), Autres (o)
3. **Deux représentations** : Symbolique (rwx) et Octale (0-7)
4. **Trois commandes principales** :
    - `chmod` : Modifier les permissions
    - `chown` : Modifier le propriétaire
    - `chgrp` : Modifier le groupe

### Commandes essentielles

```bash
# Voir les permissions
ls -l fichier.txt

# Modifier les permissions
chmod 644 fichier.txt        # Mode octal
chmod u+x script.sh          # Mode symbolique

# Modifier le propriétaire
sudo chown alice fichier.txt

# Modifier le groupe
sudo chgrp developers projet.txt

# Tout modifier en une fois
sudo chown alice:developers fichier.txt
```

### Permissions courantes à connaître

|Usage|Octal|Symbolique|
|---|---|---|
|Document standard|644|-rw-r--r--|
|Exécutable|755|-rwxr-xr-x|
|Fichier privé|600|-rw-------|
|Répertoire public|755|drwxr-xr-x|
|Répertoire privé|700|drwx------|

> [!tip] Règle d'or Donnez toujours le minimum de permissions nécessaires. Il est plus facile d'ajouter des permissions plus tard que de réparer les dégâts d'une faille de sécurité.

---

_Ce cours fait partie de la formation Administration Linux - Système de fichiers et permissions_