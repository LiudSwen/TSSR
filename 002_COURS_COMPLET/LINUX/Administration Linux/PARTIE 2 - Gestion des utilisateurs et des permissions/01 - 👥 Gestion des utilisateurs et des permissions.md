

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

La gestion des utilisateurs est un aspect fondamental de l'administration Linux. Chaque utilisateur possède un compte unique qui définit son identité sur le système, ses droits d'accès et son environnement de travail.

> [!info] Pourquoi c'est important
> 
> - **Sécurité** : Chaque utilisateur a ses propres permissions
> - **Traçabilité** : Les actions sont liées à des comptes spécifiques
> - **Isolation** : Les utilisateurs ne peuvent pas interférer entre eux
> - **Organisation** : Structure claire des accès et responsabilités

---

## Création d'utilisateurs

### useradd vs adduser

Il existe deux commandes principales pour créer des utilisateurs sous Linux, et il est crucial de comprendre leurs différences.

|Caractéristique|useradd|adduser|
|---|---|---|
|Type|Commande bas niveau|Script interactif|
|Disponibilité|Toutes distributions|Principalement Debian/Ubuntu|
|Interactivité|Non interactif|Interactif|
|Configuration|Manuel|Automatique|
|Répertoire home|Pas créé par défaut|Créé automatiquement|
|Complexité|Plus de contrôle|Plus simple|

> [!tip] Recommandation
> 
> - Utilisez `adduser` pour une création rapide et interactive (Debian/Ubuntu)
> - Utilisez `useradd` pour des scripts automatisés ou un contrôle précis

---

### Commande useradd

`useradd` est la commande système de bas niveau pour créer des utilisateurs.

#### Syntaxe de base

```bash
useradd [options] nom_utilisateur
```

#### Options principales

```bash
# Créer un utilisateur basique (sans répertoire home)
sudo useradd alice

# Créer un utilisateur avec répertoire home (-m)
sudo useradd -m bob

# Créer un utilisateur avec shell spécifique (-s)
sudo useradd -m -s /bin/bash charlie

# Créer un utilisateur avec UID spécifique (-u)
sudo useradd -m -u 1500 david

# Créer un utilisateur avec groupe principal spécifique (-g)
sudo useradd -m -g developers emma

# Créer un utilisateur avec groupes secondaires (-G)
sudo useradd -m -G sudo,docker,www-data frank

# Créer un utilisateur avec commentaire/description (-c)
sudo useradd -m -c "Frank Martin - DevOps Engineer" frank

# Créer un utilisateur avec répertoire home personnalisé (-d)
sudo useradd -m -d /home/custom/george george

# Créer un utilisateur système (-r)
sudo useradd -r service_app
```

#### Options avancées

```bash
# Définir la date d'expiration du compte (-e)
sudo useradd -m -e 2025-12-31 temp_user

# Définir le nombre de jours après expiration du mot de passe 
# avant désactivation du compte (-f)
sudo useradd -m -f 7 helen

# Créer un utilisateur complet en une seule commande
sudo useradd -m -s /bin/bash -c "Ian Smith - Développeur" \
  -G sudo,docker -u 1600 ian
```

> [!example] Exemple complet
> 
> ```bash
> # Créer un utilisateur pour un développeur
> sudo useradd -m -s /bin/bash -c "Marie Dupont - Dev Full Stack" \
>   -G developers,docker,www-data marie
> 
> # Définir son mot de passe
> sudo passwd marie
> 
> # Vérifier la création
> id marie
> # uid=1001(marie) gid=1001(marie) groups=1001(marie),999(docker),33(www-data),1002(developers)
> ```

> [!warning] Pièges courants
> 
> - **Oublier `-m`** : Sans cette option, le répertoire home n'est pas créé
> - **Shell par défaut** : Si non spécifié, peut être `/bin/sh` au lieu de `/bin/bash`
> - **Pas de mot de passe** : L'utilisateur est créé mais ne peut pas se connecter sans `passwd`
> - **Groupes secondaires** : Utilisez `-G` (majuscule) pour les groupes secondaires, `-g` pour le groupe principal

---

### Commande adduser

`adduser` est un script Perl interactif qui simplifie la création d'utilisateurs (Debian/Ubuntu).

#### Syntaxe de base

```bash
adduser nom_utilisateur
```

#### Utilisation interactive

```bash
# Création interactive complète
sudo adduser julie

# Le script demande interactivement :
# - Mot de passe (2 fois)
# - Nom complet
# - Numéro de bureau
# - Téléphone professionnel
# - Téléphone personnel
# - Autre information
# - Confirmation
```

#### Options courantes

```bash
# Créer un utilisateur sans interaction
sudo adduser --disabled-password --gecos "" kevin

# Ajouter un utilisateur à un groupe existant
sudo adduser laura sudo

# Créer un utilisateur système
sudo adduser --system --group service_web

# Créer un utilisateur avec home personnalisé
sudo adduser --home /var/www/webapp webapp_user

# Créer un utilisateur sans shell de connexion
sudo adduser --shell /usr/sbin/nologin backup_user
```

> [!example] Exemple pratique
> 
> ```bash
> # Créer rapidement un utilisateur avec accès sudo
> sudo adduser nathan
> sudo adduser nathan sudo
> 
> # Vérifier
> groups nathan
> # nathan : nathan sudo
> ```

> [!tip] Avantage d'adduser `adduser` configure automatiquement :
> 
> - Création du répertoire home avec les bons fichiers de configuration
> - Copie des fichiers squelette depuis `/etc/skel`
> - Définition du shell par défaut
> - Création du groupe personnel
> - Demande interactive du mot de passe

---

## Suppression d'utilisateurs

### Commande userdel

La suppression d'utilisateurs doit être effectuée avec précaution pour éviter de laisser des fichiers orphelins.

#### Syntaxe de base

```bash
userdel [options] nom_utilisateur
```

#### Options principales

```bash
# Supprimer uniquement le compte (garde le répertoire home)
sudo userdel alice

# Supprimer le compte ET le répertoire home (-r)
sudo userdel -r bob

# Forcer la suppression même si l'utilisateur est connecté (-f)
sudo userdel -f charlie
```

> [!warning] Attention avec -f L'option `-f` (force) est dangereuse :
> 
> - Supprime l'utilisateur même s'il a des processus actifs
> - Peut causer des instabilités système
> - À utiliser uniquement en dernier recours

#### Procédure recommandée

```bash
# 1. Vérifier que l'utilisateur n'est pas connecté
who | grep david

# 2. Vérifier les processus en cours
ps -u david

# 3. Terminer les processus si nécessaire
sudo pkill -u david

# 4. Verrouiller le compte (optionnel, pour transition)
sudo passwd -l david

# 5. Sauvegarder les données importantes
sudo tar -czf /backup/david_home.tar.gz /home/david

# 6. Supprimer l'utilisateur et ses données
sudo userdel -r david

# 7. Vérifier la suppression
id david
# id: 'david': no such user
```

> [!tip] Fichiers résiduels Même avec `-r`, certains fichiers peuvent rester :
> 
> ```bash
> # Rechercher les fichiers appartenant à un UID orphelin
> sudo find / -uid 1001 -ls 2>/dev/null
> 
> # Rechercher dans /var
> sudo find /var -user david 2>/dev/null
> 
> # Nettoyer manuellement si nécessaire
> sudo find / -uid 1001 -exec rm -rf {} \; 2>/dev/null
> ```

---

## Modification des comptes

### Commande usermod

`usermod` permet de modifier les propriétés d'un compte utilisateur existant.

#### Syntaxe de base

```bash
usermod [options] nom_utilisateur
```

#### Modifications courantes

```bash
# Changer le nom d'utilisateur (-l)
sudo usermod -l nouveau_nom ancien_nom

# Changer le répertoire home (-d)
sudo usermod -d /home/nouveau_rep -m emma
# -m déplace les fichiers existants

# Changer le shell (-s)
sudo usermod -s /bin/zsh frank

# Changer l'UID (-u)
sudo usermod -u 2000 george

# Changer le groupe principal (-g)
sudo usermod -g developers helen

# Ajouter des groupes secondaires (-aG)
sudo usermod -aG docker,sudo ian
# -a (append) est crucial pour ne pas écraser les groupes existants

# Remplacer tous les groupes secondaires (-G sans -a)
sudo usermod -G docker,www-data julie
# Attention : supprime tous les autres groupes

# Changer le commentaire/description (-c)
sudo usermod -c "Kevin Martin - Senior DevOps" kevin
```

#### Gestion du verrouillage de compte

```bash
# Verrouiller un compte (-L)
sudo usermod -L laura
# Ajoute ! devant le hash du mot de passe dans /etc/shadow

# Déverrouiller un compte (-U)
sudo usermod -U laura

# Définir une date d'expiration (-e)
sudo usermod -e 2025-12-31 temp_account

# Supprimer la date d'expiration
sudo usermod -e "" temp_account
```

> [!example] Cas pratique : Promouvoir un utilisateur
> 
> ```bash
> # Utilisateur devient administrateur
> sudo usermod -aG sudo,adm,wheel marie
> 
> # Changer son shell pour zsh
> sudo usermod -s /bin/zsh marie
> 
> # Mettre à jour la description
> sudo usermod -c "Marie Dupont - Administratrice Système" marie
> 
> # Vérifier les modifications
> id marie
> grep marie /etc/passwd
> ```

> [!warning] Pièges fréquents
> 
> - **Oublier `-a` avec `-G`** : Écrase tous les groupes secondaires existants
>     
>     ```bash
>     # MAUVAIS : supprime tous les groupes sauf dockersudo usermod -G docker nathan# BON : ajoute docker aux groupes existantssudo usermod -aG docker nathan
>     ```
>     
> - **Modifier un utilisateur connecté** : Peut causer des problèmes
> - **Changer l'UID** : Tous les fichiers gardent l'ancien UID

#### Renommer un utilisateur complètement

```bash
# Procédure complète pour renommer un utilisateur
# 1. Tuer les processus de l'utilisateur
sudo pkill -u oldname

# 2. Renommer le compte
sudo usermod -l newname oldname

# 3. Renommer le groupe principal
sudo groupmod -n newname oldname

# 4. Renommer et déplacer le répertoire home
sudo usermod -d /home/newname -m newname

# 5. Mettre à jour la description
sudo usermod -c "New Name - Description" newname

# 6. Corriger la propriété des fichiers
sudo find / -user $(id -u newname) -exec chown newname:newname {} \; 2>/dev/null
```

---

## Gestion des mots de passe

### Commande passwd

`passwd` gère les mots de passe des utilisateurs.

#### Syntaxe de base

```bash
passwd [options] [utilisateur]
```

#### Utilisations courantes

```bash
# Changer son propre mot de passe
passwd

# Changer le mot de passe d'un autre utilisateur (root uniquement)
sudo passwd alice

# Définir un mot de passe depuis stdin (pour scripts)
echo "bob:nouveau_mdp" | sudo chpasswd

# Forcer le changement de mot de passe à la prochaine connexion (-e)
sudo passwd -e charlie

# Verrouiller un compte (-l)
sudo passwd -l david

# Déverrouiller un compte (-u)
sudo passwd -u david

# Supprimer le mot de passe (dangereux!) (-d)
sudo passwd -d emma

# Afficher le statut du mot de passe (-S)
sudo passwd -S frank
# frank PS 2024-12-15 0 99999 7 -1
# Format: nom statut date_modif min max warn inact
```

#### Statuts de mot de passe

|Statut|Signification|
|---|---|
|PS|Password Set (mot de passe défini)|
|LK|Locked (compte verrouillé)|
|NP|No Password (pas de mot de passe)|

> [!example] Workflow de création d'utilisateur
> 
> ```bash
> # Créer l'utilisateur
> sudo useradd -m -s /bin/bash george
> 
> # Définir un mot de passe temporaire
> echo "george:TempPass123!" | sudo chpasswd
> 
> # Forcer le changement à la première connexion
> sudo passwd -e george
> 
> # Vérifier
> sudo passwd -S george
> # george PS 2024-12-26 0 99999 7 -1
> ```

---

### Commande chage

`chage` (change age) gère la politique d'expiration des mots de passe.

#### Syntaxe de base

```bash
chage [options] utilisateur
```

#### Options principales

```bash
# Afficher les informations d'expiration (-l)
sudo chage -l helen

# Définir la date de dernière modification (-d)
sudo chage -d 0 helen
# 0 = force le changement à la prochaine connexion

# Définir le nombre minimum de jours entre changements (-m)
sudo chage -m 7 ian
# L'utilisateur ne peut pas changer son mot de passe avant 7 jours

# Définir le nombre maximum de jours avant expiration (-M)
sudo chage -M 90 julie
# Le mot de passe expire après 90 jours

# Définir le nombre de jours d'avertissement (-W)
sudo chage -W 14 kevin
# Avertit 14 jours avant l'expiration

# Définir le nombre de jours d'inactivité avant désactivation (-I)
sudo chage -I 30 laura
# Compte désactivé 30 jours après expiration du mot de passe

# Définir la date d'expiration du compte (-E)
sudo chage -E 2025-12-31 temp_user

# Supprimer la date d'expiration
sudo chage -E -1 marie
```

#### Configuration interactive

```bash
# Modifier toutes les options interactivement
sudo chage nathan

# Demande successivement :
# - Date de dernière modification
# - Minimum de jours entre changements
# - Maximum de jours avant expiration
# - Nombre de jours d'avertissement
# - Nombre de jours d'inactivité
# - Date d'expiration du compte
```

> [!example] Politique de sécurité standard
> 
> ```bash
> # Appliquer une politique de sécurité stricte
> sudo chage -m 1 -M 90 -W 7 -I 14 olivier
> 
> # Signification :
> # -m 1  : Pas de changement avant 1 jour
> # -M 90 : Expiration après 90 jours
> # -W 7  : Avertissement 7 jours avant
> # -I 14 : Désactivation 14 jours après expiration
> 
> # Vérifier
> sudo chage -l olivier
> ```

> [!tip] Forcer le changement de mot de passe Trois méthodes équivalentes :
> 
> ```bash
> # Méthode 1 : avec passwd
> sudo passwd -e utilisateur
> 
> # Méthode 2 : avec chage (date = 0)
> sudo chage -d 0 utilisateur
> 
> # Méthode 3 : avec usermod
> sudo usermod -e 1 utilisateur
> ```

---

## Fichiers de configuration

### /etc/passwd

Le fichier `/etc/passwd` contient les informations de base sur tous les comptes utilisateurs du système.

#### Structure du fichier

```bash
# Visualiser le fichier
cat /etc/passwd

# Format de chaque ligne (7 champs séparés par :)
username:x:UID:GID:GECOS:home:shell
```

#### Détail des champs

|Position|Nom|Description|Exemple|
|---|---|---|---|
|1|Username|Nom de connexion|alice|
|2|Password|Mot de passe (x = dans /etc/shadow)|x|
|3|UID|User ID (identifiant numérique)|1000|
|4|GID|Group ID (groupe principal)|1000|
|5|GECOS|Informations utilisateur|Alice Martin,Dev|
|6|Home|Répertoire personnel|/home/alice|
|7|Shell|Shell de connexion|/bin/bash|

> [!example] Exemples de lignes
> 
> ```bash
> # Utilisateur normal
> alice:x:1000:1000:Alice Martin,Développeuse:/home/alice:/bin/bash
> 
> # Utilisateur système
> www-data:x:33:33:www-data:/var/www:/usr/sbin/nologin
> 
> # Root
> root:x:0:0:root:/root:/bin/bash
> 
> # Utilisateur sans shell
> backup:x:1050:1050:Backup User:/var/backups:/usr/sbin/nologin
> ```

#### UID standards

```bash
# UID 0
# - Toujours root (super-utilisateur)

# UID 1-999
# - Utilisateurs système
# - Comptes de services

# UID 1000+
# - Utilisateurs normaux
# - Première création : 1000
```

> [!warning] Ne jamais modifier directement **NE JAMAIS** éditer `/etc/passwd` directement avec un éditeur de texte !
> 
> ```bash
> # MAUVAIS
> sudo nano /etc/passwd
> 
> # BON : utiliser vipw (vérifie la syntaxe)
> sudo vipw
> 
> # Encore mieux : utiliser les commandes dédiées
> sudo usermod [options] utilisateur
> ```

#### Extraire des informations

```bash
# Lister tous les utilisateurs normaux (UID >= 1000)
awk -F: '$3 >= 1000 && $3 < 65534 {print $1}' /etc/passwd

# Afficher les utilisateurs avec leur shell
awk -F: '{print $1 ": " $7}' /etc/passwd

# Trouver les utilisateurs sans mot de passe (dangereux)
awk -F: '$2 == "" {print $1}' /etc/passwd

# Lister les utilisateurs avec /bin/bash
grep '/bin/bash$' /etc/passwd

# Compter le nombre d'utilisateurs
wc -l /etc/passwd
```

---

### /etc/shadow

Le fichier `/etc/shadow` contient les mots de passe chiffrés et les informations d'expiration.

#### Permissions et sécurité

```bash
# Vérifier les permissions
ls -l /etc/shadow
# -rw-r----- 1 root shadow 1234 Dec 26 10:00 /etc/shadow

# Seul root peut lire ce fichier
# Groupe shadow peut lire (pour certains services)
sudo cat /etc/shadow
```

#### Structure du fichier

```bash
# Format de chaque ligne (9 champs séparés par :)
username:password:lastchange:min:max:warn:inactive:expire:reserved
```

#### Détail des champs

|Position|Nom|Description|Exemple|
|---|---|---|---|
|1|Username|Nom d'utilisateur|alice|
|2|Password|Hash du mot de passe|$6$random$hash...|
|3|Last change|Date dernière modif (jours depuis 1/1/1970)|19723|
|4|Min|Jours min avant changement|0|
|5|Max|Jours max avant expiration|99999|
|6|Warn|Jours d'avertissement|7|
|7|Inactive|Jours avant désactivation|14|
|8|Expire|Date d'expiration du compte|20000|
|9|Reserved|Réservé pour usage futur|(vide)|

> [!example] Exemples de lignes
> 
> ```bash
> # Utilisateur normal avec mot de passe
> alice:$6$rounds=656000$YQZq:19723:0:99999:7:::
> 
> # Compte verrouillé (! devant le hash)
> bob:!$6$rounds=656000$abc:19700:0:99999:7:::
> 
> # Pas de mot de passe (dangereux)
> charlie::19723:0:99999:7:::
> 
> # Compte système sans connexion
> daemon:*:19000:0:99999:7:::
> 
> # Avec politique d'expiration
> david:$6$rounds=656000$xyz:19723:7:90:14:30:19900:
> ```

#### Format du hash de mot de passe

```bash
# Format général
$id$salt$hash

# Types d'algorithmes (id)
$1$  # MD5 (obsolète, non sécurisé)
$5$  # SHA-256
$6$  # SHA-512 (recommandé)
$y$  # yescrypt (moderne)

# Exemple décomposé
$6$rounds=656000$YQZqSaltValue$HashValue...
│  │             │              │
│  │             │              └─ Hash du mot de passe
│  │             └─ Salt (valeur aléatoire)
│  └─ Nombre de rounds (itérations)
└─ Algorithme SHA-512
```

#### États spéciaux du champ password

|Valeur|Signification|
|---|---|
|(vide)|Pas de mot de passe (dangereux)|
|!|Compte verrouillé|
|*|Compte système sans connexion|
|!!|Mot de passe jamais défini|
|!$6$...|Compte verrouillé avec mot de passe enregistré|

> [!warning] Sécurité critique
> 
> - **Permissions strictes** : Seul root doit pouvoir lire/écrire
> - **Ne jamais partager** : Même les hashs ne doivent pas être exposés
> - **Utiliser vipw -s** : Pour éditer en toute sécurité
> 
> ```bash
> # Éditer /etc/shadow de manière sécurisée
> sudo vipw -s
> ```

#### Convertir les dates

```bash
# Date en jours depuis epoch -> date lisible
date -d "1970-01-01 + 19723 days"

# Date actuelle en jours depuis epoch
echo $(( $(date +%s) / 86400 ))

# Vérifier la date de dernière modification du mot de passe
sudo awk -F: '/^alice:/ {print $3}' /etc/shadow | \
  xargs -I {} date -d "1970-01-01 + {} days"
```

#### Analyser les comptes

```bash
# Trouver les comptes sans mot de passe
sudo awk -F: '$2 == "" {print $1}' /etc/shadow

# Trouver les comptes verrouillés
sudo awk -F: '$2 ~ /^!/ {print $1}' /etc/shadow

# Trouver les comptes avec mot de passe expiré
sudo awk -F: -v today=$(( $(date +%s) / 86400 )) \
  '$3 + $5 < today && $5 != "" {print $1}' /etc/shadow

# Lister les comptes avec expiration du compte définie
sudo awk -F: '$8 != "" {print $1 " expire le: " $8}' /etc/shadow
```

> [!tip] Outils de diagnostic
> 
> ```bash
> # Afficher toutes les infos d'un utilisateur
> sudo getent shadow alice
> 
> # Vérifier l'intégrité des fichiers
> sudo pwck      # Vérifie /etc/passwd
> sudo grpck     # Vérifie /etc/group
> 
> # Afficher les infos d'expiration
> sudo chage -l alice
> ```

---

## Bonnes pratiques

### 🔐 Sécurité

> [!tip] Principes de sécurité
> 
> **Comptes utilisateurs**
> 
> - Créez un compte individuel pour chaque utilisateur (pas de comptes partagés)
> - Désactivez ou supprimez les comptes inutilisés
> - Utilisez des noms d'utilisateur explicites (pas de "user1", "user2")
> - Documentez le rôle de chaque compte dans le champ GECOS
> 
> **Mots de passe**
> 
> - Forcez des mots de passe forts (longueur minimum, complexité)
> - Définissez une politique d'expiration (90 jours recommandé)
> - Forcez le changement à la première connexion
> - N'utilisez jamais de comptes sans mot de passe
> - Verrouillez les comptes après plusieurs échecs de connexion
> 
> **Privilèges**
> 
> - Appliquez le principe du moindre privilège
> - N'utilisez pas root pour les tâches quotidiennes
> - Utilisez `sudo` pour les opérations administratives ponctuelles
> - Limitez les membres du groupe `sudo` au strict nécessaire
> - Vérifiez régulièrement les membres des groupes privilégiés

### 📋 Organisation

```bash
# Convention de nommage cohérente
# Format: prenom.nom (en minuscules)
marie.dupont
jean.martin

# UID organisés
# 1000-1999 : Administrateurs
# 2000-2999 : Développeurs  
# 3000-3999 : Utilisateurs standard
# 5000-5999 : Comptes de service applicatifs

# Groupes organisés
# Créer des groupes par fonction/département
sudo groupadd -g 2000 developers
sudo groupadd -g 2100 devops
sudo groupadd -g 3000 support

# Description complète dans GECOS
sudo usermod -c "Marie Dupont - Dev Full Stack - Équipe Backend" marie.dupont
```

### 🛡️ Maintenance régulière

```bash
# Script de vérification hebdomadaire
#!/bin/bash

echo "=== Audit des comptes utilisateurs ==="

# Comptes sans mot de passe
echo "
## Comptes sans mot de passe:"
sudo awk -F: '$2 == "" {print $1}' /etc/shadow

# Comptes avec UID 0 (root)
echo "
## Comptes avec UID 0:"
awk -F: '$3 == 0 {print $1}' /etc/passwd

# Comptes inactifs (pas connectés depuis 90 jours)
echo "
## Comptes inactifs (90+ jours):"
lastlog -b 90 | grep -v "Never"

# Comptes verrouillés
echo "
## Comptes verrouillés:"
sudo passwd -S -a | grep " L "

# Mots de passe expirés
echo "
## Mots de passe expirés:"
sudo awk -F: -v today=$(( $(date +%s) / 86400 )) \
  '$3 + $5 < today && $5 != "" && $5 != "99999" {print $1}' /etc/shadow

# Utilisateurs avec accès sudo
echo "
## Utilisateurs sudo:"
getent group sudo | cut -d: -f4 | tr ',' '
'
```

### 📝 Documentation

> [!example] Template de documentation
> 
> ```markdown
> # Compte: marie.dupont
> 
> ## Informations générales
> - **Nom complet**: Marie Dupont
> - **Poste**: Développeuse Full Stack
> - **Équipe**: Backend
> - **Date de création**: 2024-12-26
> - **UID**: 2042
> 
> ## Accès et permissions
> - Groupe principal: developers (2000)
> - Groupes secondaires: docker, www-data, git
> - Accès sudo: Oui
> - Serveurs: prod-web-01, dev-db-01
> 
> ## Politique de sécurité
> - Expiration mot de passe: 90 jours
> - Changement forcé à la création: Oui
> - Expiration compte: Aucune
> 
> ## Notes
> - Accès au repository principal: github.com/company/backend
> - Dernière révision d'accès: 2024-12-26
> ```

### 🔍 Surveillance et audit

```bash
# Surveiller les connexions réussies
last -10

# Surveiller les tentatives de connexion échouées
sudo lastb -10

# Historique de connexion d'un utilisateur spécifique
last alice

# Qui est actuellement connecté
who
w

# Vérifier la dernière connexion de tous les utilisateurs
lastlog

# Surveiller les modifications de /etc/passwd et /etc/shadow
sudo ls -l /etc/passwd /etc/shadow

# Activer la journalisation des modifications (avec auditd)
sudo auditctl -w /etc/passwd -p wa -k user_modification
sudo auditctl -w /etc/shadow -p wa -k password_modification
```

### 🚀 Automatisation

```bash
# Script de création d'utilisateur standardisé
#!/bin/bash
# create_user.sh

if [ "$#" -ne 4 ]; then
    echo "Usage: $0 username fullname team uid"
    exit 1
fi

USERNAME=$1
FULLNAME=$2
TEAM=$3
UID=$4

# Créer l'utilisateur
sudo useradd -m -s /bin/bash -c "$FULLNAME - $TEAM" -u $UID $USERNAME

# Définir mot de passe temporaire
TEMP_PASS=$(openssl rand -base64 12)
echo "$USERNAME:$TEMP_PASS" | sudo chpasswd

# Forcer le changement à la première connexion
sudo passwd -e $USERNAME

# Politique d'expiration
sudo chage -m 1 -M 90 -W 7 -I 14 $USERNAME

# Afficher les informations
echo "=== Utilisateur créé ==="
echo "Nom: $USERNAME"
echo "Mot de passe temporaire: $TEMP_PASS"
echo "L'utilisateur devra changer son mot de passe à la première connexion"

# Envoyer par email sécurisé (à adapter)
# mail -s "Compte créé" $USERNAME@company.com < message.txt
```

```bash
# Script de suppression sécurisée
#!/bin/bash
# remove_user.sh

if [ "$#" -ne 1 ]; then
    echo "Usage: $0 username"
    exit 1
fi

USERNAME=$1

# Vérifications
if ! id "$USERNAME" &>/dev/null; then
    echo "Erreur: L'utilisateur $USERNAME n'existe pas"
    exit 1
fi

# Confirmation
read -p "Supprimer l'utilisateur $USERNAME et ses données ? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    echo "Annulé"
    exit 0
fi

# Backup du home
BACKUP_DIR="/backup/users/$(date +%Y%m%d)"
sudo mkdir -p $BACKUP_DIR
sudo tar -czf "$BACKUP_DIR/$USERNAME.tar.gz" /home/$USERNAME 2>/dev/null

# Terminer les processus
sudo pkill -u $USERNAME

# Verrouiller le compte temporairement
sudo passwd -l $USERNAME

# Attendre quelques secondes
sleep 3

# Supprimer l'utilisateur
sudo userdel -r $USERNAME

# Vérifier les fichiers résiduels
UID=$(grep "^$USERNAME:" /etc/passwd.bak | cut -d: -f3)
if [ ! -z "$UID" ]; then
    echo "Recherche de fichiers résiduels..."
    sudo find / -uid $UID -ls 2>/dev/null > "$BACKUP_DIR/$USERNAME-orphan-files.txt"
fi

echo "=== Suppression terminée ==="
echo "Backup: $BACKUP_DIR/$USERNAME.tar.gz"
```

### ⚠️ Pièges courants à éviter

> [!warning] Erreurs fréquentes
> 
> **1. Modifier un utilisateur connecté**
> 
> ```bash
> # Vérifier TOUJOURS avant une modification importante
> who | grep alice
> ps -u alice
> 
> # Si connecté, demander à l'utilisateur de se déconnecter
> # ou terminer proprement les sessions
> ```
> 
> **2. Oublier -a avec usermod -G**
> 
> ```bash
> # ❌ MAUVAIS - Écrase tous les groupes
> sudo usermod -G docker bob
> 
> # ✅ BON - Ajoute docker aux groupes existants
> sudo usermod -aG docker bob
> ```
> 
> **3. Supprimer un utilisateur avec des processus actifs**
> 
> ```bash
> # Toujours vérifier et nettoyer avant
> ps -u charlie
> sudo pkill -u charlie
> sleep 2
> sudo userdel -r charlie
> ```
> 
> **4. Modifier directement /etc/passwd ou /etc/shadow**
> 
> ```bash
> # ❌ JAMAIS ça
> sudo nano /etc/passwd
> 
> # ✅ Utiliser les commandes dédiées
> sudo usermod ...
> # ✅ Ou vipw pour édition manuelle sécurisée
> sudo vipw
> ```
> 
> **5. Créer des utilisateurs sans home**
> 
> ```bash
> # ❌ MAUVAIS - Pas de répertoire home
> sudo useradd david
> 
> # ✅ BON - Avec répertoire home
> sudo useradd -m david
> ```
> 
> **6. Ne pas documenter les comptes**
> 
> ```bash
> # ❌ MAUVAIS - Pas d'info
> sudo useradd -m emma
> 
> # ✅ BON - Avec description claire
> sudo useradd -m -c "Emma Wilson - Développeuse Frontend - Équipe Web" emma
> ```
> 
> **7. Partager des comptes**
> 
> ```bash
> # ❌ MAUVAIS - Compte partagé "dev"
> # Impossible de tracer qui fait quoi
> 
> # ✅ BON - Un compte par personne
> sudo useradd -m alice
> sudo useradd -m bob
> sudo usermod -aG developers alice
> sudo usermod -aG developers bob
> ```
> 
> **8. Ignorer les fichiers orphelins après suppression**
> 
> ```bash
> # Après userdel -r, toujours vérifier
> sudo find / -nouser -ls 2>/dev/null
> sudo find / -uid 1042 -ls 2>/dev/null  # UID de l'ancien user
> ```

### 🎯 Checklist de sécurité

> [!tip] Checklist mensuelle
> 
> **Révision des comptes**
> 
> - [ ] Lister tous les utilisateurs avec UID >= 1000
> - [ ] Identifier les comptes inactifs (lastlog > 90 jours)
> - [ ] Vérifier les comptes sans mot de passe
> - [ ] Vérifier les comptes verrouillés qui peuvent être supprimés
> - [ ] Réviser les membres du groupe sudo
> - [ ] Vérifier les UID 0 (seul root devrait être 0)
> 
> **Politique des mots de passe**
> 
> - [ ] Vérifier les mots de passe expirés non renouvelés
> - [ ] Contrôler que tous les comptes ont une expiration définie
> - [ ] Vérifier que tous les nouveaux comptes forcent le changement initial
> - [ ] Tester la robustesse des mots de passe (avec john/hashcat en test)
> 
> **Intégrité des fichiers**
> 
> - [ ] Vérifier les permissions de /etc/passwd (644)
> - [ ] Vérifier les permissions de /etc/shadow (640)
> - [ ] Exécuter pwck pour vérifier l'intégrité
> - [ ] Comparer avec les backups précédents
> 
> **Documentation**
> 
> - [ ] Mettre à jour la liste des utilisateurs actifs
> - [ ] Documenter les changements de rôles
> - [ ] Vérifier que tous les comptes ont une description GECOS
> - [ ] Archiver les logs d'audit

### 📊 Commandes de diagnostic rapide

```bash
# Vue d'ensemble complète du système utilisateurs
sudo cat << 'EOF' > /usr/local/bin/user-audit
#!/bin/bash
echo "╔════════════════════════════════════════╗"
echo "║   AUDIT DES COMPTES UTILISATEURS       ║"
echo "╚════════════════════════════════════════╝"

echo -e "\n📊 STATISTIQUES"
echo "Total utilisateurs: $(wc -l < /etc/passwd)"
echo "Utilisateurs normaux (UID>=1000): $(awk -F: '$3>=1000 && $3<65534' /etc/passwd | wc -l)"
echo "Utilisateurs système: $(awk -F: '$3<1000 || $3>=65534' /etc/passwd | wc -l)"

echo -e "\n👥 UTILISATEURS CONNECTÉS"
w -h | wc -l
who

echo -e "\n🔐 COMPTES À RISQUE"
echo "Sans mot de passe:"
sudo awk -F: '$2==""' /etc/shadow | cut -d: -f1

echo -e "\nVerrouillés:"
sudo passwd -S -a | grep " L " | cut -d' ' -f1

echo -e "\n⏰ DERNIÈRES CONNEXIONS"
lastlog | head -20

echo -e "\n👮 UTILISATEURS PRIVILÉGIÉS"
echo "Groupe sudo:"
getent group sudo | cut -d: -f4

echo -e "\nUID 0 (root):"
awk -F: '$3==0' /etc/passwd | cut -d: -f1

echo -e "\n📅 EXPIRATIONS"
echo "Comptes expirés:"
sudo awk -F: -v today=$(( $(date +%s) / 86400 )) \
  '$8!="" && $8<today' /etc/shadow | cut -d: -f1

echo -e "\nMots de passe expirés:"
sudo awk -F: -v today=$(( $(date +%s) / 86400 )) \
  '$3+$5<today && $5!="" && $5!="99999"' /etc/shadow | cut -d: -f1

echo -e "\n✅ Audit terminé - $(date)"
EOF

sudo chmod +x /usr/local/bin/user-audit
```

```bash
# Rapport détaillé d'un utilisateur
sudo cat << 'EOF' > /usr/local/bin/user-info
#!/bin/bash
if [ -z "$1" ]; then
    echo "Usage: $0 username"
    exit 1
fi

USER=$1

echo "╔════════════════════════════════════════╗"
echo "║   INFORMATIONS UTILISATEUR: $USER"
echo "╚════════════════════════════════════════╝"

echo -e "\n📋 IDENTITÉ"
getent passwd $USER

echo -e "\n🔑 AUTHENTIFICATION"
sudo passwd -S $USER
sudo chage -l $USER

echo -e "\n👥 GROUPES"
groups $USER
id $USER

echo -e "\n🏠 RÉPERTOIRE HOME"
ls -ld /home/$USER 2>/dev/null || echo "Pas de répertoire home"

echo -e "\n📊 UTILISATION DISQUE"
du -sh /home/$USER 2>/dev/null || echo "N/A"

echo -e "\n⚡ PROCESSUS ACTIFS"
ps -u $USER -o pid,tty,time,cmd 2>/dev/null | head -10

echo -e "\n🔌 CONNEXIONS"
echo "Actuellement connecté:"
w -h $USER 2>/dev/null

echo -e "\nDernière connexion:"
lastlog -u $USER

echo -e "\n📝 FICHIERS CRONTAB"
sudo crontab -u $USER -l 2>/dev/null || echo "Pas de crontab"

echo -e "\n🔐 CLÉS SSH"
if [ -d "/home/$USER/.ssh" ]; then
    ls -la /home/$USER/.ssh/
else
    echo "Pas de répertoire .ssh"
fi
EOF

sudo chmod +x /usr/local/bin/user-info
```

### 🔄 Migration et sauvegarde

```bash
# Script de sauvegarde des comptes utilisateurs
#!/bin/bash
# backup_users.sh

BACKUP_DIR="/backup/users/$(date +%Y%m%d_%H%M%S)"
mkdir -p $BACKUP_DIR

echo "Sauvegarde des comptes utilisateurs dans $BACKUP_DIR"

# Fichiers système
sudo cp /etc/passwd $BACKUP_DIR/
sudo cp /etc/shadow $BACKUP_DIR/
sudo cp /etc/group $BACKUP_DIR/
sudo cp /etc/gshadow $BACKUP_DIR/

# Liste des utilisateurs avec détails
awk -F: '$3>=1000 && $3<65534' /etc/passwd > $BACKUP_DIR/users_list.txt

# Informations d'expiration
while IFS=: read -r user _; do
    sudo chage -l $user > $BACKUP_DIR/chage_${user}.txt 2>/dev/null
done < $BACKUP_DIR/users_list.txt

# Groupes de chaque utilisateur
while IFS=: read -r user _; do
    groups $user > $BACKUP_DIR/groups_${user}.txt 2>/dev/null
done < $BACKUP_DIR/users_list.txt

# Permissions sudo
getent group sudo > $BACKUP_DIR/sudo_members.txt

# Archiver
tar -czf $BACKUP_DIR.tar.gz -C $(dirname $BACKUP_DIR) $(basename $BACKUP_DIR)
rm -rf $BACKUP_DIR

echo "Sauvegarde terminée: $BACKUP_DIR.tar.gz"
```

```bash
# Script de migration d'utilisateur vers un autre serveur
#!/bin/bash
# migrate_user.sh

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 username target_server"
    exit 1
fi

USER=$1
TARGET=$2

echo "Migration de $USER vers $TARGET"

# Extraire les infos
PASSWD_LINE=$(getent passwd $USER)
SHADOW_LINE=$(sudo getent shadow $USER)
GROUPS=$(groups $USER | cut -d: -f2)

# Créer script de recréation
cat > /tmp/recreate_${USER}.sh << EOF
#!/bin/bash
# Recréation de $USER sur $TARGET

# Extraire les informations
IFS=: read -r name x uid gid gecos home shell <<< "$PASSWD_LINE"

# Créer l'utilisateur
useradd -m -u \$uid -g \$gid -c "\$gecos" -d \$home -s \$shell \$name

# Restaurer le hash du mot de passe
sed -i "/^\$name:/d" /etc/shadow
echo "$SHADOW_LINE" >> /etc/shadow

# Ajouter aux groupes
usermod -aG $GROUPS \$name

echo "Utilisateur \$name recréé avec succès"
EOF

# Archiver le home
sudo tar -czf /tmp/${USER}_home.tar.gz -C /home $USER

# Transférer vers le serveur cible
scp /tmp/recreate_${USER}.sh $TARGET:/tmp/
scp /tmp/${USER}_home.tar.gz $TARGET:/tmp/

echo "=== Instructions pour $TARGET ==="
echo "1. Exécuter: sudo bash /tmp/recreate_${USER}.sh"
echo "2. Extraire: sudo tar -xzf /tmp/${USER}_home.tar.gz -C /home/"
echo "3. Corriger: sudo chown -R $USER:$USER /home/$USER"

# Nettoyage
rm /tmp/recreate_${USER}.sh /tmp/${USER}_home.tar.gz
```

---

## 📚 Récapitulatif des commandes essentielles

### Création et suppression

```bash
# Créer un utilisateur (bas niveau)
sudo useradd -m -s /bin/bash -c "Description" username

# Créer un utilisateur (interactif Debian/Ubuntu)
sudo adduser username

# Supprimer un utilisateur (garder home)
sudo userdel username

# Supprimer un utilisateur (supprimer home)
sudo userdel -r username
```

### Modification

```bash
# Modifier le nom
sudo usermod -l nouveau_nom ancien_nom

# Modifier les groupes (ajouter)
sudo usermod -aG groupe1,groupe2 username

# Modifier le shell
sudo usermod -s /bin/zsh username

# Modifier le home
sudo usermod -d /nouveau/home -m username

# Verrouiller un compte
sudo usermod -L username

# Déverrouiller un compte
sudo usermod -U username
```

### Mots de passe

```bash
# Changer le mot de passe
sudo passwd username

# Forcer le changement à la prochaine connexion
sudo passwd -e username

# Verrouiller le compte
sudo passwd -l username

# Afficher le statut
sudo passwd -S username
```

### Expiration

```bash
# Afficher les infos d'expiration
sudo chage -l username

# Forcer changement immédiat
sudo chage -d 0 username

# Définir expiration mot de passe (90 jours)
sudo chage -M 90 username

# Définir expiration du compte
sudo chage -E 2025-12-31 username
```

### Consultation

```bash
# Informations utilisateur
id username
getent passwd username
sudo getent shadow username

# Groupes
groups username

# Dernière connexion
lastlog -u username

# Utilisateurs connectés
who
w

# Processus de l'utilisateur
ps -u username
```

### Vérification et audit

```bash
# Vérifier intégrité /etc/passwd
sudo pwck

# Vérifier intégrité /etc/group
sudo grpck

# Lister utilisateurs normaux
awk -F: '$3>=1000 && $3<65534 {print $1}' /etc/passwd

# Trouver fichiers orphelins
sudo find / -nouser -ls 2>/dev/null
```

---

## 🎓 Synthèse

La gestion des utilisateurs sous Linux repose sur plusieurs composants clés :

**Fichiers système**

- `/etc/passwd` : Informations de base des utilisateurs
- `/etc/shadow` : Mots de passe chiffrés et politique d'expiration
- `/etc/group` : Définition des groupes (sera vu dans une autre partie)
- `/etc/gshadow` : Mots de passe de groupes (sera vu dans une autre partie)

**Commandes principales**

- `useradd`/`adduser` : Création de comptes
- `userdel` : Suppression de comptes
- `usermod` : Modification de comptes
- `passwd` : Gestion des mots de passe
- `chage` : Politique d'expiration

**Principes de sécurité**

- Un compte par utilisateur (jamais de comptes partagés)
- Politique stricte de mots de passe avec expiration
- Principe du moindre privilège
- Audit régulier des comptes et accès
- Documentation systématique

**Bonnes pratiques**

- Toujours utiliser les commandes dédiées (jamais éditer directement les fichiers)
- Vérifier avant de modifier ou supprimer
- Sauvegarder les données avant suppression
- Documenter chaque compte (champ GECOS)
- Automatiser les tâches répétitives
- Surveiller et auditer régulièrement

La maîtrise de ces concepts est essentielle pour tout administrateur système Linux, car la gestion des utilisateurs est la base de la sécurité et de l'organisation du système.

---

_📝 Cours généré pour Obsidian - Administration Linux - Partie: Gestion des utilisateurs et des permissions_