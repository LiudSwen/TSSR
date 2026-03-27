

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

L'élévation de privilèges est un mécanisme de sécurité fondamental sous Linux qui permet à un utilisateur standard d'exécuter des commandes nécessitant des droits d'administration (root) de manière contrôlée et temporaire. Ce système évite de travailler en permanence avec le compte root, réduisant ainsi les risques d'erreurs catastrophiques et améliorant la traçabilité des actions système.

> [!info] Pourquoi ne pas utiliser root en permanence ?
> 
> - **Sécurité** : Limite les dégâts en cas d'erreur ou de malware
> - **Traçabilité** : Les logs indiquent quel utilisateur a exécuté quelle commande
> - **Protection** : Nécessite une confirmation explicite pour les actions sensibles
> - **Bonnes pratiques** : Standard dans l'industrie et recommandé par toutes les distributions

---

## Configuration par défaut de sudo

### Ubuntu vs Debian

Les distributions Linux ont des approches différentes concernant la configuration initiale de sudo, notamment Ubuntu et Debian qui divergent sur ce point.

#### 🟠 Ubuntu

> [!example] Configuration Ubuntu **Lors de l'installation**, Ubuntu configure automatiquement sudo pour le premier utilisateur créé.

**Caractéristiques** :

- Le premier utilisateur est automatiquement ajouté au groupe `sudo`
- Peut exécuter n'importe quelle commande avec sudo
- Le mot de passe root n'est **pas défini** par défaut
- Philosophie : encourager l'utilisation de sudo plutôt que de root

```bash
# Vérifier l'appartenance au groupe sudo
groups mon_utilisateur
# Résultat typique : mon_utilisateur : mon_utilisateur adm cdrom sudo dip ...
```

#### 🔵 Debian

> [!example] Configuration Debian **Lors de l'installation**, Debian propose de définir un mot de passe root et ne configure **pas** sudo automatiquement.

**Caractéristiques** :

- L'utilisateur créé n'a pas les droits sudo par défaut
- Le compte root est actif avec un mot de passe défini
- Sudo doit être configuré manuellement si souhaité
- Philosophie : approche plus traditionnelle Unix

```bash
# Sur Debian, pour configurer sudo après installation
# 1. Se connecter en tant que root
su -

# 2. Installer sudo si nécessaire
apt update && apt install sudo

# 3. Ajouter l'utilisateur au groupe sudo
usermod -aG sudo mon_utilisateur

# 4. Redémarrer la session utilisateur pour appliquer les changements
```

#### Tableau comparatif

|Aspect|Ubuntu|Debian|
|---|---|---|
|**Sudo configuré**|✅ Oui, automatiquement|❌ Non, manuel|
|**Groupe par défaut**|`sudo`|Aucun (doit être ajouté)|
|**Mot de passe root**|Non défini|Défini lors de l'installation|
|**Philosophie**|Favorise sudo|Favorise su et root direct|
|**Utilisateur novice**|Plus simple|Plus technique|

> [!tip] Quelle approche choisir ?
> 
> - **Ubuntu** : Idéal pour les débutants et les postes de travail
> - **Debian** : Préféré pour les serveurs où le contrôle strict est requis
> 
> Les deux approches sont valides, c'est une question de philosophie et de cas d'usage.

---

## Configuration de sudoers

Le fichier `/etc/sudoers` est le fichier de configuration central qui définit qui peut utiliser sudo et comment. Il contrôle précisément les permissions d'élévation de privilèges.

### Emplacement et structure

```bash
# Fichier principal
/etc/sudoers

# Fichiers additionnels (recommandé pour les configurations personnalisées)
/etc/sudoers.d/
```

> [!warning] Ne jamais éditer directement avec un éditeur de texte ! Toujours utiliser `visudo` pour éditer ce fichier. Une erreur de syntaxe peut vous empêcher d'utiliser sudo complètement.

### Syntaxe de base

```bash
# Format général
utilisateur hôte=(utilisateur_cible) commandes

# Exemples commentés
root    ALL=(ALL:ALL) ALL
# root peut exécuter toutes les commandes, sur tous les hôtes, en tant que n'importe quel utilisateur

%sudo   ALL=(ALL:ALL) ALL
# Les membres du groupe sudo peuvent tout faire (% indique un groupe)

%wheel  ALL=(ALL:ALL) ALL
# Sur certaines distributions (RedHat, CentOS), c'est le groupe wheel qui est utilisé
```

### Décomposition de la syntaxe

```
utilisateur  hôte=(utilisateur_cible:groupe_cible)  commandes
    ↓         ↓            ↓                          ↓
   Qui ?   Où ?     En tant que qui ?          Quelles commandes ?
```

**Exemples détaillés** :

```bash
# 1. Permettre à alice d'exécuter uniquement apt
alice ALL=(root) /usr/bin/apt

# 2. Permettre au groupe dev de redémarrer les services
%dev ALL=(root) /usr/bin/systemctl restart *

# 3. Permettre à bob d'exécuter n'importe quelle commande SANS mot de passe
bob ALL=(ALL) NOPASSWD: ALL

# 4. Permettre à l'équipe admin de gérer les utilisateurs
%admin ALL=(root) /usr/sbin/useradd, /usr/sbin/usermod, /usr/sbin/userdel

# 5. Limiter à un hôte spécifique
alice webserver1=(root) /usr/sbin/service apache2 restart
```

### Options courantes

> [!info] Options dans sudoers

**NOPASSWD** : Ne pas demander de mot de passe

```bash
alice ALL=(ALL) NOPASSWD: /usr/bin/systemctl status
```

**PASSWD** : Demander le mot de passe (comportement par défaut)

```bash
bob ALL=(ALL) PASSWD: ALL
```

**NOEXEC** : Empêcher l'exécution de sous-commandes (sécurité)

```bash
charlie ALL=(root) NOEXEC: /usr/bin/less
```

**SETENV** : Permettre la définition de variables d'environnement

```bash
dave ALL=(ALL) SETENV: /usr/local/bin/deploy.sh
```

### Alias pour simplifier la configuration

Les alias permettent de regrouper des éléments pour simplifier la maintenance.

```bash
# Alias d'utilisateurs
User_Alias ADMINS = alice, bob, charlie
User_Alias WEBMASTERS = dave, eve

# Alias d'hôtes
Host_Alias WEBSERVERS = web1, web2, web3
Host_Alias DATABASES = db1, db2

# Alias de commandes
Cmnd_Alias NETWORKING = /usr/sbin/ip, /usr/sbin/iptables, /usr/bin/netstat
Cmnd_Alias SOFTWARE = /usr/bin/apt, /usr/bin/dpkg, /usr/bin/snap
Cmnd_Alias SERVICES = /usr/bin/systemctl start, /usr/bin/systemctl stop, /usr/bin/systemctl restart

# Utilisation des alias
ADMINS ALL=(ALL) ALL
WEBMASTERS WEBSERVERS=(root) SERVICES, SOFTWARE
```

### Configuration des defaults

```bash
# Augmenter le timeout du mot de passe (par défaut 5 minutes)
Defaults timestamp_timeout=30

# Désactiver complètement le timeout (non recommandé)
Defaults timestamp_timeout=-1

# Réinitialiser le timeout immédiatement
Defaults timestamp_timeout=0

# Toujours demander le mot de passe
Defaults timestamp_timeout=0

# Préserver certaines variables d'environnement
Defaults env_keep += "http_proxy https_proxy ftp_proxy"

# Logger toutes les commandes sudo
Defaults log_output
Defaults log_input

# Afficher un message d'avertissement
Defaults lecture = always
Defaults lecture_file = /etc/sudoers.lecture

# Envoyer un mail en cas d'utilisation incorrecte
Defaults mail_badpass
Defaults mailto = "admin@example.com"
```

> [!warning] Pièges courants
> 
> - **Espace vs Tabulation** : Utilisez toujours des tabulations dans sudoers
> - **Chemins absolus** : Toujours spécifier le chemin complet des commandes
> - **Wildcards** : Soyez prudent avec `*`, cela peut créer des failles de sécurité
> - **NOPASSWD** : À utiliser avec parcimonie, évaluez le risque de sécurité

---

## Commande visudo

`visudo` est l'outil sécurisé pour éditer le fichier sudoers. Il vérifie la syntaxe avant d'enregistrer les modifications, évitant ainsi de casser la configuration.

### Pourquoi utiliser visudo ?

> [!warning] Risques d'édition directe Si vous éditez `/etc/sudoers` avec nano ou vim et faites une erreur de syntaxe, vous pourriez :
> 
> - Vous bloquer complètement hors de sudo
> - Bloquer tous les utilisateurs
> - Nécessiter un accès physique ou un mode rescue pour réparer

**Avantages de visudo** :

- ✅ Vérifie la syntaxe avant de sauvegarder
- ✅ Crée un verrou sur le fichier (évite les modifications concurrentes)
- ✅ Propose de corriger les erreurs
- ✅ Utilise l'éditeur défini dans $EDITOR ou $VISUAL

### Utilisation de base

```bash
# Éditer le fichier principal /etc/sudoers
sudo visudo

# Éditer un fichier dans /etc/sudoers.d/
sudo visudo -f /etc/sudoers.d/local-users

# Vérifier la syntaxe sans éditer
sudo visudo -c

# Vérifier la syntaxe d'un fichier spécifique
sudo visudo -cf /etc/sudoers.d/local-users
```

### Workflow typique

```bash
# 1. Ouvrir visudo
sudo visudo

# 2. Ajouter votre configuration
# (l'éditeur s'ouvre - nano par défaut sur Ubuntu/Debian)

# 3. Sauvegarder (Ctrl+O puis Entrée dans nano)

# 4. visudo vérifie la syntaxe automatiquement
# Si erreur détectée :
>>> /etc/sudoers: syntax error near line 28 <<<
What now?
Options are:
  (e)dit sudoers file again
  e(x)it without saving changes to sudoers file
  (Q)uit and save changes to sudoers file (DANGER!)

# 5. Choisir 'e' pour corriger ou 'x' pour abandonner
```

### Changer l'éditeur par défaut

```bash
# Méthode 1 : Pour la session en cours
export EDITOR=vim
sudo visudo

# Méthode 2 : Définir de manière permanente dans ~/.bashrc
echo 'export EDITOR=vim' >> ~/.bashrc
source ~/.bashrc

# Méthode 3 : Utiliser update-alternatives (Debian/Ubuntu)
sudo update-alternatives --config editor

# Liste les éditeurs disponibles et permet de choisir
There are 4 choices for the alternative editor.

  Selection    Path                Priority   Status
------------------------------------------------------------
* 0            /bin/nano            40        auto mode
  1            /bin/ed             -100       manual mode
  2            /bin/nano            40        manual mode
  3            /usr/bin/vim.basic   30        manual mode
  4            /usr/bin/vim.tiny    15        manual mode

Press <enter> to keep the current choice[*], or type selection number: 3
```

### Bonnes pratiques avec visudo

> [!tip] Organisation recommandée **Utilisez `/etc/sudoers.d/` pour vos configurations personnalisées** :

```bash
# 1. Créer un fichier pour vos utilisateurs locaux
sudo visudo -f /etc/sudoers.d/local-users

# 2. Ajouter vos règles
alice ALL=(ALL) NOPASSWD: /usr/bin/apt update, /usr/bin/apt upgrade

# 3. Vérifier que l'inclusion est active dans /etc/sudoers
sudo grep "includedir" /etc/sudoers
# Doit afficher : @includedir /etc/sudoers.d
```

**Avantages de cette approche** :

- Séparation des configurations système et personnalisées
- Facilite la gestion avec des outils de configuration (Ansible, Puppet)
- Évite les conflits lors des mises à jour système
- Permet de désactiver rapidement une règle en renommant le fichier

```bash
# Désactiver temporairement une configuration
sudo mv /etc/sudoers.d/local-users /etc/sudoers.d/local-users.disabled

# Réactiver
sudo mv /etc/sudoers.d/local-users.disabled /etc/sudoers.d/local-users
```

> [!warning] Règles de nommage pour /etc/sudoers.d/
> 
> - Pas de `.` ou `~` dans le nom (sauf extension)
> - Permissions : 0440 (lecture seule pour root et groupe root)
> - Appartenance : root:root

```bash
# Définir les bonnes permissions
sudo chmod 0440 /etc/sudoers.d/local-users
sudo chown root:root /etc/sudoers.d/local-users
```

---

## Différence entre su et sudo

Bien que `su` et `sudo` permettent tous deux l'élévation de privilèges, ils fonctionnent différemment et répondent à des besoins distincts.

### Comparaison conceptuelle

> [!info] Philosophies différentes
> 
> - **su** : "Devenir un autre utilisateur" (Substitute User)
> - **sudo** : "Exécuter une commande en tant qu'un autre utilisateur" (Super User DO)

### Tableau comparatif détaillé

|Critère|su|sudo|
|---|---|---|
|**Mot de passe demandé**|Mot de passe de l'utilisateur cible (root)|Mot de passe de l'utilisateur actuel|
|**Durée**|Session complète jusqu'à `exit`|Commande unique (ou timeout)|
|**Traçabilité**|Logs montrent "root a fait X"|Logs montrent "alice via sudo a fait X"|
|**Configuration**|Pas de configuration (juste le compte cible)|Fichier `/etc/sudoers` granulaire|
|**Shell**|Ouvre un nouveau shell complet|Exécute une commande puis revient|
|**Variables d'environnement**|Change selon l'utilisateur cible|Peut préserver l'environnement|
|**Sécurité**|Nécessite de partager le mot de passe root|Chaque utilisateur garde son mot de passe|
|**Granularité**|Tout ou rien|Contrôle fin par commande|

### Commande su

**Syntaxe et options** :

```bash
# Devenir root (nécessite le mot de passe root)
su

# Devenir root avec un environnement complet (-l ou -)
su -
# ou
su -l
# ou
su --login

# Devenir un autre utilisateur
su alice

# Devenir alice avec son environnement
su - alice

# Exécuter une seule commande en tant que root
su -c "apt update"

# Exécuter une commande en tant qu'alice
su alice -c "whoami"
```

**Différence entre `su` et `su -`** :

> [!example] Impact sur l'environnement

```bash
# Sans le tiret : garde l'environnement actuel
$ su
# Reste dans le répertoire actuel
# Variables d'environnement de l'utilisateur d'origine

# Avec le tiret : environnement complet de root
$ su -
# Bascule vers /root
# Variables d'environnement de root
# PATH de root
```

```bash
# Démonstration pratique
alice@server:~$ pwd
/home/alice

alice@server:~$ su
Password: 
root@server:/home/alice# pwd
/home/alice
root@server:/home/alice# echo $HOME
/home/alice

# Maintenant avec su -
alice@server:~$ su -
Password: 
root@server:~# pwd
/root
root@server:~# echo $HOME
/root
```

### Commande sudo

**Syntaxe et options** :

```bash
# Exécuter une commande en tant que root
sudo apt update

# Exécuter en tant qu'un autre utilisateur (-u)
sudo -u alice whoami

# Ouvrir un shell root (équivalent à su -)
sudo -i
# ou
sudo su -

# Ouvrir un shell root sans changer d'environnement
sudo -s

# Lister les privilèges de l'utilisateur actuel
sudo -l

# Lister les privilèges d'un autre utilisateur
sudo -l -U alice

# Valider les credentials (renouveler le timeout)
sudo -v

# Invalider les credentials (forcer redemande de mot de passe)
sudo -k

# Exécuter avec l'environnement préservé
sudo -E commande

# Éditer un fichier de manière sécurisée
sudoedit /etc/hosts
# ou
sudo -e /etc/hosts
```

**Comprendre le timeout de sudo** :

> [!info] Mécanisme de cache des credentials Par défaut, après avoir entré votre mot de passe pour sudo, vous n'avez pas besoin de le retaper pendant 15 minutes (configurable).

```bash
# Première commande : demande le mot de passe
sudo apt update
[sudo] password for alice: ********

# Commandes suivantes : pas de mot de passe pendant 15 minutes
sudo apt upgrade
# Pas de demande de mot de passe

# Forcer la redemande du mot de passe
sudo -k

# Commande suivante redemandera le mot de passe
sudo apt update
[sudo] password for alice: ********
```

### Cas d'usage recommandés

> [!tip] Quand utiliser su ?

**Utilisez `su` quand** :

- Vous devez effectuer de nombreuses opérations administratives consécutives
- Vous travaillez en mode rescue ou dépannage
- Vous testez des scripts qui doivent s'exécuter dans l'environnement root
- sudo n'est pas configuré ou disponible

```bash
# Exemple : maintenance système multiple
su -
apt update
apt upgrade
apt autoremove
systemctl restart apache2
systemctl status apache2
exit
```

> [!tip] Quand utiliser sudo ?

**Utilisez `sudo` quand** :

- Vous exécutez des commandes administratives ponctuelles
- Vous voulez une meilleure traçabilité
- Plusieurs administrateurs travaillent sur le même système
- Vous voulez un contrôle granulaire des permissions
- Vous travaillez sur un poste de travail personnel

```bash
# Exemple : opérations ponctuelles
sudo systemctl restart apache2
sudo journalctl -u apache2 -f
sudo cp /etc/apache2/sites-available/default /etc/apache2/sites-available/backup
```

### Sécurité et bonnes pratiques

> [!warning] Problèmes de sécurité avec su

**Partage du mot de passe root** :

- Si 10 administrateurs utilisent `su`, ils connaissent tous le mot de passe root
- Si l'un part, il faut changer le mot de passe et informer tous les autres
- Impossible de savoir qui a fait quoi dans les logs

**Avec sudo** :

- Chaque administrateur garde son propre mot de passe
- Révocation simple : retirer du groupe sudo
- Logs précis : "alice via sudo a supprimé /etc/important"

> [!tip] Bonnes pratiques générales

```bash
# ✅ BON : Commande spécifique avec sudo
sudo systemctl restart nginx

# ❌ ÉVITER : Shell root permanent
sudo su -
# (puis travailler longtemps en root)

# ✅ BON : Limiter la portée
sudo -u www-data touch /var/www/html/test.txt

# ❌ ÉVITER : Donner trop de permissions
# Dans /etc/sudoers :
alice ALL=(ALL) NOPASSWD: ALL

# ✅ MIEUX : Permissions ciblées
alice ALL=(root) /usr/bin/systemctl restart nginx
```

### Combinaison de su et sudo

Il est possible de combiner les deux outils selon le contexte :

```bash
# Devenir root via sudo (recommandé si sudo est configuré)
sudo su -

# Ou directement
sudo -i

# Exécuter une commande en tant qu'un autre utilisateur via sudo
sudo -u alice bash

# Chaîner : devenir alice, puis devenir root
sudo -u alice su -
# (demande le mot de passe root)
```

> [!warning] Anti-pattern : sudo su Bien que `sudo su -` soit pratique, c'est techniquement inutile si vous pouvez utiliser `sudo -i` directement. La commande `sudo su -` est devenue un idiome mais n'est pas la plus élégante.

---

## 🎯 Résumé des concepts clés

|Concept|Utilisation|Commande clé|
|---|---|---|
|**sudo**|Élévation ponctuelle, traçable|`sudo commande`|
|**su**|Devenir un autre utilisateur|`su -`|
|**visudo**|Éditer sudoers en sécurité|`sudo visudo`|
|**sudoers**|Configurer qui peut utiliser sudo|`/etc/sudoers`|
|**NOPASSWD**|Éviter demande de mot de passe|Dans sudoers|
|**timeout**|Cache du mot de passe|15 min par défaut|

> [!tip] Mémo rapide
> 
> - **Ubuntu** : sudo configuré par défaut
> - **Debian** : sudo à configurer manuellement
> - **Toujours** utiliser `visudo` pour éditer sudoers
> - **Préférer** sudo pour la traçabilité
> - **Utiliser** su pour les longues sessions admin
> - **Limiter** NOPASSWD aux cas vraiment nécessaires

---

## 🔒 Points de sécurité essentiels

> [!warning] À retenir absolument
> 
> 1. **Ne jamais éditer `/etc/sudoers` directement** → Utilisez `visudo`
> 2. **Éviter `NOPASSWD: ALL`** → Trop permissif, risque de sécurité
> 3. **Spécifier les chemins absolus** → `/usr/bin/apt` pas `apt`
> 4. **Attention aux wildcards** → `*` peut être dangereux
> 5. **Préférer sudo pour la traçabilité** → Logs plus précis
> 6. **Ne pas partager le mot de passe root** → Utiliser sudo
> 7. **Tester les modifications** → `sudo -l` après changement
> 8. **Documenter les permissions** → Commentaires dans sudoers