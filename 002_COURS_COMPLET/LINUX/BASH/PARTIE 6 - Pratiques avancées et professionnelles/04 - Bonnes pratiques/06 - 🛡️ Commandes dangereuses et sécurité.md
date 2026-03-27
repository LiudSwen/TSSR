

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

Certaines commandes Bash peuvent causer des dommages irréversibles à votre système si elles sont mal utilisées. Cette section couvre les commandes les plus dangereuses et les pratiques de sécurité essentielles pour les utiliser en toute sécurité.

> [!warning] Attention critique Les commandes présentées ici peuvent détruire des données, corrompre votre système ou créer des failles de sécurité. Une erreur peut être irréversible.

---

## rm -rf : La commande destructrice

### 🎯 Pourquoi c'est dangereux

La commande `rm -rf` combine deux options qui la rendent particulièrement destructrice :

- `-r` (recursive) : supprime les répertoires et leur contenu
- `-f` (force) : ignore les avertissements et force la suppression

Cette combinaison supprime tout sans demander confirmation et sans possibilité de récupération facile.

### 📚 Syntaxe et options

```bash
# Syntaxe de base (DANGEREUSE)
rm -rf /chemin/vers/dossier

# Options importantes
rm -r          # Récursif seul (demande confirmation pour fichiers protégés)
rm -f          # Force seul (pas récursif)
rm -i          # Mode interactif (demande confirmation)
rm -I          # Confirmation une fois si >3 fichiers
rm -v          # Mode verbeux (affiche ce qui est supprimé)
```

### ✅ Vérifications multiples obligatoires

> [!tip] Checklist de sécurité Avant d'exécuter `rm -rf`, suivez TOUJOURS cette procédure :

**1. Vérifier le chemin avec `ls`**

```bash
# TOUJOURS vérifier avant de supprimer
ls -la /chemin/vers/dossier

# Vérifier les wildcards
ls -la *.log

# Compter les fichiers concernés
ls -la /chemin | wc -l
```

**2. Utiliser `echo` pour prévisualiser**

```bash
# Prévisualiser avec echo avant suppression
echo rm -rf /chemin/vers/$VARIABLE

# Vérifier l'expansion des variables
DOSSIER="/tmp/data"
echo "Je vais supprimer : $DOSSIER"
```

**3. Tester avec des options plus sûres**

```bash
# Mode interactif (demande confirmation)
rm -ri /chemin/vers/dossier

# Mode verbeux + interactif
rm -riv /chemin/vers/dossier

# Confirmation intelligente (-I : une seule fois si >3 fichiers)
rm -rI /chemin/vers/dossier
```

**4. Utiliser des chemins absolus**

```bash
# ❌ DANGEREUX - chemin relatif avec variable
rm -rf $DOSSIER/*

# ✅ SÛRE - chemin absolu vérifié
DOSSIER="/home/user/temp"
if [[ -d "$DOSSIER" && "$DOSSIER" != "/" ]]; then
    rm -rf "$DOSSIER"/*
fi
```

### 🔒 Protections dans les scripts

```bash
#!/bin/bash

# Protection 1 : Vérifier que la variable n'est pas vide
DOSSIER="${1}"
if [[ -z "$DOSSIER" ]]; then
    echo "Erreur : aucun dossier spécifié"
    exit 1
fi

# Protection 2 : Vérifier que le dossier existe
if [[ ! -d "$DOSSIER" ]]; then
    echo "Erreur : $DOSSIER n'existe pas"
    exit 1
fi

# Protection 3 : Vérifier qu'on ne vise pas la racine ou home
case "$DOSSIER" in
    /|/home|/usr|/var|/etc|/bin|/sbin)
        echo "Erreur : tentative de suppression d'un répertoire système"
        exit 1
        ;;
esac

# Protection 4 : Demander confirmation explicite
read -p "Supprimer $DOSSIER ? (tapez 'oui' pour confirmer) : " CONFIRM
if [[ "$CONFIRM" != "oui" ]]; then
    echo "Annulé"
    exit 0
fi

# Protection 5 : Mode verbeux pour traçabilité
rm -rfv "$DOSSIER"
```

### ⚠️ Pièges courants

> [!warning] Danger avec les variables vides

```bash
# ❌ CATASTROPHIQUE si $DOSSIER est vide
rm -rf /$DOSSIER/*
# Devient : rm -rf /* (supprime tout le système !)

# ✅ Protection avec quotes et vérification
DOSSIER="${DOSSIER}"
if [[ -n "$DOSSIER" && -d "/$DOSSIER" ]]; then
    rm -rf "/$DOSSIER"/*
fi
```

> [!warning] Danger avec les espaces

```bash
# ❌ DANGEREUX - sans quotes
FICHIER="mon fichier.txt"
rm -rf $FICHIER
# Devient : rm -rf mon fichier.txt (supprime 'mon' ET 'fichier.txt')

# ✅ Toujours quoter les variables
rm -rf "$FICHIER"
```

### 💡 Alternatives plus sûres

```bash
# 1. Déplacer vers la corbeille au lieu de supprimer
mkdir -p ~/.local/share/Trash
mv fichier.txt ~/.local/share/Trash/

# 2. Utiliser trash-cli (si installé)
trash fichier.txt  # Envoi à la corbeille
trash-list          # Liste le contenu
trash-restore       # Restaure un fichier

# 3. Archiver avant de supprimer
tar -czf backup-$(date +%Y%m%d).tar.gz dossier/
rm -rf dossier/

# 4. Supprimer avec timeout (pour annuler)
echo "Suppression dans 10 secondes... CTRL+C pour annuler"
sleep 10
rm -rf dossier/
```

---

## mv et cp : Éviter les écrasements

### 🎯 Le problème des écrasements silencieux

Par défaut, `mv` et `cp` écrasent les fichiers existants sans avertissement, ce qui peut entraîner une perte de données.

### 📚 Options de protection

```bash
# Options de sécurité pour mv et cp
-i    # Interactive : demande confirmation avant écrasement
-n    # No-clobber : n'écrase jamais (refuse si fichier existe)
-b    # Backup : crée une sauvegarde avant écrasement
-u    # Update : copie seulement si source plus récente
-v    # Verbose : affiche les actions effectuées
```

### ✅ Utilisation sécurisée de mv

```bash
# ❌ DANGEREUX - écrasement silencieux
mv fichier1.txt fichier2.txt

# ✅ Mode interactif (-i)
mv -i fichier1.txt fichier2.txt
# Demande : overwrite 'fichier2.txt'? (y/n)

# ✅ Mode no-clobber (-n) - refuse d'écraser
mv -n fichier1.txt fichier2.txt
# Si fichier2.txt existe, ne fait rien

# ✅ Mode verbeux + interactif
mv -iv *.txt /destination/
# Affiche chaque fichier déplacé et demande confirmation

# ✅ Backup automatique (-b)
mv -b fichier1.txt fichier2.txt
# Crée fichier2.txt~ (backup de l'ancien fichier2.txt)

# ✅ Backup avec suffix personnalisé
mv --backup=numbered fichier1.txt fichier2.txt
# Crée fichier2.txt.~1~, fichier2.txt.~2~, etc.
```

### ✅ Utilisation sécurisée de cp

```bash
# ❌ DANGEREUX - écrasement silencieux
cp fichier1.txt fichier2.txt

# ✅ Mode interactif (-i)
cp -i fichier1.txt fichier2.txt

# ✅ Mode no-clobber (-n)
cp -n fichier1.txt fichier2.txt

# ✅ Update mode (-u) - copie seulement si plus récent
cp -u source.txt destination.txt

# ✅ Copie récursive sécurisée
cp -riv dossier_source/ dossier_destination/

# ✅ Combinaison d'options pour sécurité maximale
cp -rinv dossier_source/ dossier_destination/
# -r: récursif, -i: interactif, -n: no-clobber, -v: verbeux
```

### 🔧 Vérifications avant copie/déplacement

```bash
# Vérifier si la destination existe
if [[ -e "destination.txt" ]]; then
    echo "ATTENTION : destination.txt existe déjà"
    read -p "Écraser ? (o/n) : " REPONSE
    [[ "$REPONSE" != "o" ]] && exit 0
fi
cp fichier.txt destination.txt

# Vérifier l'espace disque avant copie
TAILLE_SOURCE=$(du -sb source/ | cut -f1)
ESPACE_DISPO=$(df --output=avail -B1 /destination | tail -n1)

if [[ $TAILLE_SOURCE -gt $ESPACE_DISPO ]]; then
    echo "Erreur : espace disque insuffisant"
    exit 1
fi

# Comparer dates avant écrasement
if [[ fichier_dest.txt -nt fichier_source.txt ]]; then
    echo "ATTENTION : destination plus récente que source !"
fi
```

### 💡 Bonnes pratiques de copie

```bash
# 1. Toujours utiliser -v (verbeux) pour traçabilité
cp -v important.txt backup.txt

# 2. Créer un timestamp dans le nom de backup
cp important.txt "important_$(date +%Y%m%d_%H%M%S).txt"

# 3. Vérifier l'intégrité après copie
cp fichier.txt destination.txt
diff fichier.txt destination.txt || echo "Erreur de copie !"

# 4. Copie avec préservation des attributs
cp -av source/ destination/
# -a : archive mode (préserve tout)

# 5. Utiliser rsync pour copies complexes
rsync -av --progress source/ destination/
```

### 📊 Tableau comparatif des options

|Option|mv|cp|Comportement|
|---|---|---|---|
|`-i`|✅|✅|Demande confirmation avant écrasement|
|`-n`|✅|✅|N'écrase jamais (refuse si existe)|
|`-f`|✅|✅|Force (écrase sans demander)|
|`-v`|✅|✅|Mode verbeux|
|`-b`|✅|✅|Crée un backup avant écrasement|
|`-u`|❌|✅|Copie seulement si plus récent|

---

## Opérations sur la racine (/)

### 🎯 Pourquoi la racine est critique

Le répertoire `/` (racine) contient l'intégralité du système d'exploitation. Toute opération destructrice sur `/` peut rendre le système inutilisable.

### 🚫 Protections système modernes

Depuis GNU coreutils 6.4, `rm` inclut une protection contre la suppression de `/` :

```bash
# ❌ Bloqué par défaut
rm -rf /
# Erreur : it is dangerous to operate recursively on '/'

# ⚠️ Peut être contourné (NE JAMAIS FAIRE)
rm -rf --no-preserve-root /
# DÉTRUIT LE SYSTÈME ENTIER !
```

### ⚠️ Dangers indirects sur la racine

> [!danger] Pièges avec variables vides

```bash
# ❌ CATASTROPHIQUE si $DIR est vide
DIR=""
rm -rf /$DIR/*
# Devient : rm -rf /* (suppression de tout !)

# ✅ Toujours vérifier les variables
DIR="${DIR}"
if [[ -z "$DIR" ]]; then
    echo "Erreur : variable DIR vide"
    exit 1
fi
if [[ "$DIR" == "/" ]]; then
    echo "Erreur : tentative d'opération sur /"
    exit 1
fi
rm -rf "/$DIR"/*
```

### 🔒 Protections dans les scripts

```bash
#!/bin/bash

# Fonction de validation de chemin
valider_chemin() {
    local CHEMIN="$1"
    
    # Vérifier que le chemin n'est pas vide
    if [[ -z "$CHEMIN" ]]; then
        echo "Erreur : chemin vide"
        return 1
    fi
    
    # Liste noire des répertoires critiques
    local INTERDITS=(
        "/"
        "/bin"
        "/boot"
        "/dev"
        "/etc"
        "/lib"
        "/lib64"
        "/proc"
        "/root"
        "/sbin"
        "/sys"
        "/usr"
        "/var"
    )
    
    # Vérifier si le chemin commence par un répertoire interdit
    for INTERDIT in "${INTERDITS[@]}"; do
        if [[ "$CHEMIN" == "$INTERDIT" ]] || [[ "$CHEMIN" == "$INTERDIT"/* ]]; then
            echo "Erreur : opération interdite sur $INTERDIT"
            return 1
        fi
    done
    
    return 0
}

# Utilisation
CIBLE="/home/user/data"
if valider_chemin "$CIBLE"; then
    rm -rf "$CIBLE"
else
    exit 1
fi
```

### 🛡️ Protections supplémentaires

```bash
# 1. Toujours utiliser des chemins absolus
# ❌ Éviter
cd /tmp && rm -rf *

# ✅ Préférer
rm -rf /tmp/*

# 2. Vérifier PWD avant opérations dangereuses
if [[ "$PWD" == "/" ]]; then
    echo "Erreur : répertoire courant est /"
    exit 1
fi

# 3. Utiliser realpath pour résoudre les liens symboliques
CHEMIN=$(realpath "/chemin/qui/pourrait/etre/un/lien")
if [[ "$CHEMIN" == "/" ]]; then
    echo "Erreur : résolution vers /"
    exit 1
fi

# 4. Créer un whitelist plutôt qu'une blacklist
WHITELIST="/home/user/projets /tmp/mes_fichiers"
if [[ ! "$WHITELIST" =~ "$CIBLE" ]]; then
    echo "Erreur : $CIBLE n'est pas dans la whitelist"
    exit 1
fi
```

### 💡 Bonnes pratiques système

> [!tip] Sécurité système
> 
> - Toujours travailler dans `/home`, `/tmp` ou `/opt` pour vos données
> - N'JAMAIS exécuter de scripts avec sudo sans les avoir lus
> - Utiliser des environnements isolés (conteneurs, VM) pour les tests
> - Maintenir des backups réguliers du système

```bash
# Exemple de script sécurisé avec zone de travail
#!/bin/bash

# Définir une zone de travail sûre
ZONE_TRAVAIL="/home/$USER/workspace"

# Vérifier qu'on est dans la zone de travail
if [[ ! "$PWD" =~ ^$ZONE_TRAVAIL ]]; then
    echo "Erreur : ce script doit s'exécuter dans $ZONE_TRAVAIL"
    exit 1
fi

# Opérations sûres uniquement dans la zone de travail
rm -rf "$ZONE_TRAVAIL/temp"/*
```

---

## Wildcards : Les caractères jokers dangereux

### 🎯 Pourquoi les wildcards sont dangereux

Les wildcards (`*`, `?`, `[]`) s'expansent de manière imprévisible et peuvent correspondre à des fichiers non souhaités, causant des suppressions ou modifications accidentelles.

### 📚 Les wildcards en Bash

```bash
*       # Correspond à n'importe quelle chaîne (0 ou plus caractères)
?       # Correspond à exactement un caractère
[abc]   # Correspond à a, b, ou c
[a-z]   # Correspond à n'importe quelle lettre minuscule
[!abc]  # Correspond à tout sauf a, b, ou c
```

### ⚠️ Pièges courants avec wildcards

> [!danger] Expansion dangereuse avec espaces

```bash
# ❌ DANGEREUX - fichier nommé "-rf" ou "--no-preserve-root"
ls > -rf
rm *
# Devient : rm -rf (supprime tout !)

# ❌ Fichier commençant par "-"
touch -- "-fichier.txt"
rm *
# Interprète -fichier.txt comme une option
```

> [!danger] Expansion dans mauvais répertoire

```bash
# ❌ DANGEREUX - si cd échoue
cd /tmp/dossier || rm *.txt
# Si cd échoue, rm s'exécute dans le répertoire courant !

# ✅ Toujours vérifier le cd
cd /tmp/dossier || exit 1
rm *.txt
```

### ✅ Quotage des wildcards

```bash
# Pour passer un wildcard littéral (sans expansion)
# Utiliser des quotes simples ou échapper

# ❌ Expansion immédiate
echo *.txt
# Affiche : fichier1.txt fichier2.txt fichier3.txt

# ✅ Wildcard littéral (pas d'expansion)
echo '*.txt'
# Affiche : *.txt

# ✅ Échappement
echo \*.txt
# Affiche : *.txt

# Utilisation dans find
find . -name '*.txt'    # ✅ Quotes pour éviter expansion shell
find . -name \*.txt     # ✅ Échappement alternatif
```

### 🔍 Vérification avant utilisation

> [!tip] Toujours prévisualiser l'expansion

```bash
# 1. Utiliser echo pour prévisualiser
echo rm *.log
# Affiche : rm fichier1.log fichier2.log

# 2. Utiliser ls pour vérifier
ls -la *.txt

# 3. Compter les fichiers concernés
echo *.conf | wc -w
ls *.conf | wc -l

# 4. Vérifier avec find (plus contrôlable)
find . -maxdepth 1 -name "*.log"
```

### 🔒 Utilisation sécurisée des wildcards

```bash
# Protection 1 : Toujours avec un chemin complet
# ❌ RISQUÉ
rm *.log

# ✅ SÛRE
rm /var/log/app/*.log

# Protection 2 : Utiliser -- pour séparer options et fichiers
rm -- *.txt
# -- indique la fin des options

# Protection 3 : Utiliser find avec -delete
find /chemin -name "*.log" -type f -delete
# Plus contrôlable, peut ajouter -maxdepth, -mtime, etc.

# Protection 4 : Boucle avec vérification
for fichier in *.txt; do
    if [[ -f "$fichier" ]]; then
        echo "Suppression de : $fichier"
        rm "$fichier"
    fi
done

# Protection 5 : Désactiver nullglob pour détecter absence
shopt -u nullglob  # Par défaut
rm *.txt
# Si aucun .txt, erreur "*.txt: No such file"

# OU activer nullglob pour gérer l'absence
shopt -s nullglob
for fichier in *.txt; do
    rm "$fichier"  # Boucle n'exécute rien si aucun fichier
done
```

### 🛡️ Patterns sûrs vs dangereux

|Pattern|Dangereux|Sûr|Raison|
|---|---|---|---|
|`rm *`|❌|`rm ./*.txt`|Trop large|
|`rm *.txt`|⚠️|`rm -- *.txt`|Fichiers nommés `-*.txt`|
|`rm $(ls)`|❌|`for f in *; do rm "$f"; done`|Problème avec espaces|
|`cd $DIR && rm *`|❌|`cd "$DIR"||

### 💡 Alternatives avec find

```bash
# find est plus sûr et plus contrôlable que les wildcards

# Supprimer fichiers .log de plus de 7 jours
find /var/log -name "*.log" -type f -mtime +7 -delete

# Supprimer avec confirmation interactive
find . -name "*.tmp" -type f -exec rm -i {} \;

# Supprimer avec affichage
find . -name "*.bak" -type f -print -delete

# Supprimer seulement dans le répertoire courant (pas récursif)
find . -maxdepth 1 -name "*.cache" -type f -delete

# Conditions multiples
find . -name "*.log" -size +100M -mtime +30 -delete
```

### 🎯 Cas d'usage avancés

```bash
# 1. Wildcard avec exclusion
shopt -s extglob
rm !(important.txt|*.conf)  # Supprime tout sauf ces patterns

# 2. Wildcard avec globstar (récursif)
shopt -s globstar
ls **/*.txt  # Liste tous les .txt récursivement

# 3. Vérification de correspondance
if compgen -G "*.txt" > /dev/null; then
    echo "Des fichiers .txt existent"
    rm *.txt
else
    echo "Aucun fichier .txt trouvé"
fi

# 4. Wildcard dans variable (attention à l'expansion)
PATTERN="*.log"
# ❌ Expansion trop tôt
rm $PATTERN

# ✅ Quote pour contrôler l'expansion
rm "$PATTERN"  # Cherche littéralement un fichier nommé "*.log"

# ✅ Expansion contrôlée
for fichier in $PATTERN; do
    [[ -f "$fichier" ]] && rm "$fichier"
done
```

---

## chmod et chown récursifs

### 🎯 Pourquoi c'est dangereux

Les commandes `chmod` et `chown` avec l'option `-R` (récursive) modifient les permissions et propriétés de TOUS les fichiers d'une arborescence. Une erreur peut :

- Rendre des fichiers système inaccessibles
- Créer des failles de sécurité
- Bloquer l'accès à vos propres données

### 📚 Syntaxe de chmod et chown

```bash
# chmod : CHange MODe (permissions)
chmod [options] mode fichier/dossier
chmod -R 755 dossier/  # Récursif

# chown : CHange OWNer (propriétaire)
chown [options] utilisateur:groupe fichier/dossier
chown -R user:group dossier/  # Récursif
```

### ⚠️ Erreurs catastrophiques classiques

> [!danger] Chmod récursif sur /

```bash
# ❌ CATASTROPHIQUE - système inutilisable
chmod -R 777 /
# Donne tous les droits à tout le monde sur tout le système !

# ❌ DANGEREUX - sur home entier
chmod -R 755 ~
# Change les permissions de TOUS vos fichiers personnels
```

> [!danger] Chown récursif incorrect

```bash
# ❌ CATASTROPHIQUE - perte de propriété
sudo chown -R mauvais_user /etc
# Les fichiers système n'appartiennent plus à root !

# ❌ DANGEREUX - mauvais répertoire
sudo chown -R www-data /home
# Tous les homes appartiennent maintenant à www-data
```

### ✅ Vérifications avant chmod/chown récursif

```bash
# 1. Vérifier le chemin avec ls
ls -la /chemin/vers/dossier

# 2. Prévisualiser avec find
find /chemin -type f -o -type d
# Compte les éléments concernés
find /chemin -type f -o -type d | wc -l

# 3. Afficher les permissions actuelles
find /chemin -ls

# 4. Tester sur un sous-ensemble
chmod -R 755 /chemin/test_subdir/
ls -la /chemin/test_subdir/
```

### 🔒 Utilisation sécurisée de chmod récursif

```bash
# ❌ ÉVITER - chmod aveugle
chmod -R 777 dossier/

# ✅ Différencier fichiers et dossiers
# Dossiers : 755 (rwxr-xr-x) - exécutable pour navigation
find dossier/ -type d -exec chmod 755 {} \;

# Fichiers : 644 (rw-r--r--) - pas exécutable par défaut
find dossier/ -type f -exec chmod 644 {} \;

# ✅ Scripts exécutables uniquement
find dossier/ -type f -name "*.sh" -exec chmod 755 {} \;

# ✅ Chmod sélectif avec find
# Seulement les fichiers modifiés récemment
find dossier/ -type f -mtime -7 -exec chmod 644 {} \;

# Seulement les fichiers d'un certain propriétaire
find dossier/ -type f -user olduser -exec chmod 640 {} \;
```

### 🔒 Utilisation sécurisée de chown récursif

```bash
# ✅ Toujours spécifier le chemin complet
sudo chown -R user:group /chemin/absolu/dossier

# ✅ Vérifier le propriétaire actuel avant
ls -la /chemin/dossier
stat /chemin/dossier

# ✅ Mode verbeux pour traçabilité
sudo chown -Rv user:group /chemin/dossier

# ✅ Chown sélectif avec find
# Changer seulement les fichiers d'un ancien propriétaire
sudo find /chemin -user ancien_user -exec chown nouveau_user:nouveau_group {} \;

# ✅ Conserver la structure utilisateur/groupe existante
# Changer seulement le groupe
sudo chown -R :nouveau_group /chemin/dossier

# Changer seulement l'utilisateur
sudo chown -R nouvel_user: /chemin/dossier
```

### 🛡️ Protections dans les scripts

```bash
#!/bin/bash

# Script sécurisé pour chmod/chown récursif

CIBLE="$1"
PERMISSIONS="$2"
PROPRIETAIRE="$3"

# Validation du chemin
if [[ -z "$CIBLE" ]]; then
    echo "Erreur : chemin non spécifié"
    exit 1
fi

if [[ ! -d "$CIBLE" ]]; then
    echo "Erreur : $CIBLE n'existe pas ou n'est pas un dossier"
    exit 1
fi

# Interdire opérations sur répertoires système
case "$CIBLE" in
    /|/bin|/boot|/dev|/etc|/lib|/proc|/root|/sbin|/sys|/usr|/var)
        echo "Erreur : opération interdite sur répertoire système"
        exit 1
        ;;
esac

# Vérifier que le chemin est dans /home ou /opt
if [[ ! "$CIBLE" =~ ^/home/ ]] && [[ ! "$CIBLE" =~ ^/opt/ ]]; then
    echo "ATTENTION : chemin hors de /home et /opt"
    read -p "Continuer ? (oui/non) : " CONFIRM
    [[ "$CONFIRM" != "oui" ]] && exit 0
fi

# Afficher un résumé
echo "Opération prévue :"
echo "  Chemin : $CIBLE"
echo "  Permissions : $PERMISSIONS"
echo "  Propriétaire : $PROPRIETAIRE"
echo "  Nombre d'éléments : $(find "$CIBLE" | wc -l)"

read -p "Confirmer ? (oui/non) : " CONFIRM
[[ "$CONFIRM" != "oui" ]] && exit 0

# Exécution avec verbosité
if [[ -n "$PERMISSIONS" ]]; then
    chmod -Rv "$PERMISSIONS" "$CIBLE"
fi

if [[ -n "$PROPRIETAIRE" ]]; then
    sudo chown -Rv "$PROPRIETAIRE" "$CIBLE"
fi

echo "Opération terminée avec succès"
```

### 💡 Patterns de permissions courants

```bash
# Web : répertoire accessible par serveur web
sudo chown -R www-data:www-data /var/www/monsite
find /var/www/monsite -type d -exec chmod 755 {} \;  # Dossiers
find /var/www/monsite -type f -exec chmod 644 {} \;  # Fichiers

# Projet Git : permissions standard développeur
chown -R user:user ~/projets/monprojet
find ~/projets/monprojet -type d -exec chmod 755 {} \;
find ~/projets/monprojet -type f -exec chmod 644 {} \;
find ~/projets/monprojet -type f -name "*.sh" -exec chmod 755 {} \;

# Base de données : permissions restrictives
sudo chown -R mysql:mysql /var/lib/mysql
sudo chmod -R 750 /var/lib/mysql  # Lecture limitée au groupe

# Logs : lecture pour groupe, écriture pour service
sudo chown -R syslog:adm /var/log/monapp
find /var/log/monapp -type f -exec chmod 640 {} \;
find /var/log/monapp -type d -exec chmod 750 {} \;

# Fichiers de configuration sensibles
sudo chown root:root /etc/monapp/config.conf
sudo chmod 600 /etc/monapp/config.conf  # Seulement root en lecture/écriture
```

### 🎯 Comprendre les permissions numériques

```bash
# Format : [user][group][others]
# Chaque chiffre est la somme de : 4 (read) + 2 (write) + 1 (execute)

755 = rwxr-xr-x  # Propriétaire: tout, autres: lecture+exécution
644 = rw-r--r--  # Propriétaire: lecture+écriture, autres: lecture seule
600 = rw-------  # Seulement propriétaire en lecture+écriture
700 = rwx------  # Seulement propriétaire avec tous les droits
640 = rw-r-----  # Propriétaire: rw, groupe: r, autres: rien
750 = rwxr-x---  # Propriétaire: tout, groupe: rx, autres: rien
```

### 📊 Tableau des permissions recommandées

|Type de fichier|Permissions|Raison|
|---|---|---|
|Dossiers publics|`755`|Navigation publique|
|Dossiers privés|`700`|Accès propriétaire seul|
|Fichiers données|`644`|Lecture publique|
|Fichiers config|`600`|Lecture propriétaire seul|
|Scripts exécutables|`755`|Exécution publique|
|Scripts privés|`700`|Exécution propriétaire seul|
|Fichiers sensibles|`400`|Lecture seule propriétaire|
|Logs partagés|`640`|Propriétaire rw, groupe r|

### 🔍 Audit des permissions

```bash
# Trouver les fichiers avec permissions dangereuses

# 1. Fichiers world-writable (777, 666, etc.)
find /chemin -type f -perm -002 -ls
# -002 : bit "write" actif pour "others"

# 2. Répertoires world-writable
find /chemin -type d -perm -002 -ls

# 3. Fichiers setuid (potentiellement dangereux)
find /chemin -type f -perm -4000 -ls

# 4. Fichiers setgid
find /chemin -type f -perm -2000 -ls

# 5. Fichiers sans propriétaire (orphelins)
find /chemin -nouser -o -nogroup

# 6. Fichiers appartenant à un utilisateur spécifique
find /chemin -user root -ls

# 7. Générer un rapport complet
find /chemin -ls > rapport_permissions.txt
```

### ⚠️ Erreurs courantes à éviter

> [!warning] Pièges fréquents

```bash
# ❌ Oublier le point avec chown
sudo chown user:group dossier  # Change seulement le dossier
sudo chown -R user:group dossier  # Change récursivement

# ❌ Confusion entre : et .
sudo chown user:group fichier   # ✅ Correct
sudo chown user.group fichier   # ⚠️ Ancienne syntaxe (déconseillée)
sudo chown user groupe fichier  # ❌ Erreur (interprété comme 2 fichiers)

# ❌ Chmod sur un lien symbolique
chmod 755 lien_symbolique  # Change la cible, pas le lien
chmod -h 755 lien_symbolique  # Change le lien lui-même

# ❌ Permissions excessives "par sécurité"
chmod -R 777 dossier/  # ❌ DANGEREUX - tout le monde peut tout faire
chmod -R 000 dossier/  # ❌ Personne ne peut accéder (même root galère)
```

### 💡 Restauration après erreur

```bash
# Si vous avez fait une erreur de chmod/chown, options de restauration :

# 1. Restaurer depuis une sauvegarde
tar -xzpvf backup.tar.gz  # -p préserve les permissions

# 2. Copier les permissions d'un fichier de référence
chmod --reference=fichier_reference.txt fichier_a_corriger.txt
chown --reference=fichier_reference.txt fichier_a_corriger.txt

# 3. Restaurer permissions système depuis un autre système
getfacl -R /chemin/reference > permissions.acl  # Sur système sain
setfacl --restore=permissions.acl  # Sur système à réparer

# 4. Réinitialiser avec valeurs par défaut
# Pour /home/user
chmod -R u+rwX,go-w ~/  # u: rwX, group/others: pas de write
find ~/ -type f -exec chmod 644 {} \;
find ~/ -type d -exec chmod 755 {} \;
```

### 🔐 Bonnes pratiques avancées

> [!tip] Recommandations de sécurité

```bash
# 1. Utiliser umask pour permissions par défaut
umask 022  # Nouveaux fichiers : 644, nouveaux dossiers : 755
umask 077  # Nouveaux fichiers : 600, nouveaux dossiers : 700

# Ajouter au ~/.bashrc pour permanence
echo "umask 022" >> ~/.bashrc

# 2. Utiliser ACL (Access Control Lists) pour permissions fines
# Donner accès à un utilisateur spécifique sans changer le groupe
setfacl -R -m u:username:rwx dossier/

# Afficher les ACL
getfacl dossier/

# 3. Utiliser sudo avec précaution
# ❌ Éviter
sudo chmod -R 777 /var/www

# ✅ Préférer
sudo -u www-data chmod -R 755 /var/www

# 4. Logger les changements de permissions critiques
chmod -v 600 fichier_important.conf >> /var/log/chmod.log

# 5. Créer un alias sécurisé
alias chmod='chmod -v'  # Toujours verbeux
alias chown='sudo chown -v'  # Toujours verbeux et avec sudo
```

### 🎯 Script de vérification automatique

```bash
#!/bin/bash
# Script de vérification des permissions dangereuses

echo "=== Audit de sécurité des permissions ==="
echo ""

# 1. Fichiers world-writable
echo "📝 Fichiers world-writable (dangereux) :"
WRITABLE=$(find /home -type f -perm -002 2>/dev/null | wc -l)
if [[ $WRITABLE -gt 0 ]]; then
    echo "⚠️  $WRITABLE fichiers trouvés !"
    find /home -type f -perm -002 -ls 2>/dev/null | head -5
else
    echo "✅ Aucun fichier world-writable"
fi
echo ""

# 2. Fichiers setuid root (risque élevé)
echo "🔒 Fichiers setuid root :"
SETUID=$(find /home -type f -perm -4000 -user root 2>/dev/null | wc -l)
if [[ $SETUID -gt 0 ]]; then
    echo "⚠️  $SETUID fichiers setuid root trouvés"
    find /home -type f -perm -4000 -user root -ls 2>/dev/null
else
    echo "✅ Aucun fichier setuid root suspect"
fi
echo ""

# 3. Fichiers appartenant à root dans /home
echo "👤 Fichiers root dans /home :"
ROOT_FILES=$(find /home -user root 2>/dev/null | wc -l)
if [[ $ROOT_FILES -gt 0 ]]; then
    echo "⚠️  $ROOT_FILES fichiers appartenant à root"
    find /home -user root -ls 2>/dev/null | head -5
else
    echo "✅ Pas de fichiers root dans /home"
fi
echo ""

# 4. Répertoires sans permissions d'exécution
echo "📁 Dossiers sans permission d'exécution (inaccessibles) :"
NO_EXEC=$(find /home -type d ! -perm -100 2>/dev/null | wc -l)
if [[ $NO_EXEC -gt 0 ]]; then
    echo "⚠️  $NO_EXEC dossiers potentiellement inaccessibles"
    find /home -type d ! -perm -100 -ls 2>/dev/null | head -5
else
    echo "✅ Tous les dossiers sont accessibles"
fi
echo ""

echo "=== Audit terminé ==="
```

---

## Résumé des bonnes pratiques

### 🎯 Checklist de sécurité générale

> [!tip] À faire TOUJOURS

**Avant toute commande dangereuse :**

- [ ] Vérifier le chemin avec `ls` ou `echo`
- [ ] Utiliser l'option `-v` (verbose) pour traçabilité
- [ ] Tester sur un sous-ensemble de fichiers
- [ ] Vérifier que les variables ne sont pas vides
- [ ] Utiliser des chemins absolus, pas relatifs
- [ ] Quoter toutes les variables : `"$VAR"`
- [ ] Ajouter `|| exit 1` après les `cd`

**Pour rm :**

- [ ] Ne JAMAIS utiliser `rm -rf` sans vérifications multiples
- [ ] Toujours utiliser `rm -i` ou `rm -I` en interactif
- [ ] Préférer `mv` vers corbeille au lieu de `rm`
- [ ] Protéger contre les variables vides
- [ ] Utiliser `--` pour séparer options et fichiers

**Pour mv/cp :**

- [ ] Utiliser `-i` (interactif) ou `-n` (no-clobber)
- [ ] Vérifier si la destination existe déjà
- [ ] Utiliser `-b` pour créer des backups automatiques
- [ ] Toujours utiliser `-v` pour voir ce qui se passe

**Pour chmod/chown :**

- [ ] Ne JAMAIS utiliser `777` ou `666`
- [ ] Différencier fichiers et dossiers avec `find`
- [ ] Vérifier le chemin avant exécution récursive
- [ ] Utiliser `-v` pour traçabilité
- [ ] Tester sur un sous-répertoire d'abord

**Pour wildcards :**

- [ ] Toujours prévisualiser avec `echo`
- [ ] Vérifier l'expansion avec `ls`
- [ ] Quoter les wildcards dans `find`
- [ ] Utiliser `--` pour protéger contre fichiers commençant par `-`
- [ ] Préférer `find` pour les opérations complexes

### 📋 Commandes à bannir de la production

```bash
# ❌ INTERDITES EN PRODUCTION

rm -rf /                    # Destruction système
rm -rf /*                   # Destruction système
rm -rf $VAR/*               # Si $VAR vide = catastrophe
chmod -R 777 /              # Faille de sécurité totale
chown -R user /             # Corruption des propriétés système
:(){ :|:& };:               # Fork bomb (crash système)
dd if=/dev/random of=/dev/sda  # Écrase le disque
mkfs.ext4 /dev/sda          # Formate le disque sans demander
> /dev/sda                  # Écrase le disque
mv /* /tmp                  # Déplace tout le système
```

### ✅ Alternatives sécurisées recommandées

|Commande dangereuse|Alternative sûre|
|---|---|
|`rm -rf dir/`|`rm -riv dir/` ou `mv dir/ ~/.trash/`|
|`mv file1 file2`|`mv -iv file1 file2`|
|`cp -r src/ dst/`|`rsync -av src/ dst/`|
|`chmod -R 777 dir/`|`find dir/ -type d -exec chmod 755 {} \;`|
|`rm *.txt`|`find . -name "*.txt" -type f -delete`|
|`cd $DIR && rm *`|`cd "$DIR"|

### 🛡️ Configuration de sécurité dans .bashrc

```bash
# Ajouter à ~/.bashrc pour plus de sécurité

# 1. Alias sécurisés
alias rm='rm -i'          # Toujours demander confirmation
alias mv='mv -i'          # Toujours demander confirmation
alias cp='cp -i'          # Toujours demander confirmation
alias ln='ln -i'          # Toujours demander confirmation

# 2. Protection contre rm accidentel de /
alias rm='rm --preserve-root'

# 3. Historique étendu pour audit
HISTSIZE=10000
HISTFILESIZE=10000
HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S "  # Timestamp dans l'historique

# 4. Umask sécurisé
umask 022  # Fichiers: 644, Dossiers: 755

# 5. Désactiver les coredumps (fichiers de crash)
ulimit -c 0

# 6. Protection prompt pour root
if [[ $EUID -eq 0 ]]; then
    PS1='\[\e[1;31m\][\u@\h \W]#\[\e[0m\] '  # Rouge pour root
else
    PS1='\[\e[1;32m\][\u@\h \W]$\[\e[0m\] '  # Vert pour user
fi
```

### 🔍 Commandes de vérification post-opération

```bash
# Après une opération dangereuse, vérifier :

# 1. Que les fichiers/dossiers existent toujours
ls -la /chemin/critique

# 2. Que les permissions sont correctes
stat /chemin/fichier
ls -la /chemin/

# 3. Que le système fonctionne toujours
df -h              # Espace disque
free -h            # Mémoire
systemctl status   # Services système
journalctl -xe     # Logs d'erreurs récentes

# 4. Test d'accès
sudo -u www-data cat /var/www/fichier  # Test d'accès utilisateur
su - utilisateur -c "ls /home/utilisateur"  # Test connexion user
```

### 📚 Ressources pour aller plus loin

> [!info] Documentation officielle
> 
> - `man rm` - Manuel complet de rm
> - `man chmod` - Gestion des permissions
> - `man find` - Recherche avancée de fichiers
> - `man bash` - Documentation complète de Bash

### 🎓 Points clés à retenir

1. **Prévenez plutôt que guérissez** : Une vérification de 5 secondes peut éviter des heures de récupération
2. **Testez toujours** : Utilisez `echo`, `ls` ou un environnement de test
3. **Soyez verbeux** : `-v` vous permet de voir ce qui se passe réellement
4. **Protégez vos scripts** : Validez TOUTES les entrées utilisateur
5. **Gardez des backups** : La seule vraie protection contre les erreurs
6. **Méfiez-vous des wildcards** : Ils peuvent correspondre à plus que prévu
7. **Utilisez find** : Plus contrôlable et prévisible que les wildcards
8. **Permissions minimales** : Donnez le minimum de droits nécessaires
9. **Ne travaillez jamais en root** : Utilisez `sudo` seulement quand nécessaire
10. **Documentez vos actions** : Utilisez `-v` et gardez des logs

---

> [!quote] Citation de sécurité "Avec de grands pouvoirs viennent de grandes responsabilités. Une seule commande mal exécutée peut détruire des années de travail. Vérifiez deux fois, exécutez une fois."

---

**Fin du cours : Commandes dangereuses et sécurité** 🛡️