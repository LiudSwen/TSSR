

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

## 🎯 Introduction

Le compte **root** (également appelé superutilisateur) est le compte administrateur ultime sur un système Linux. Il possède tous les privilèges et peut effectuer n'importe quelle opération sur le système, sans aucune restriction. Comprendre son fonctionnement et savoir l'utiliser de manière sécurisée est fondamental en administration système.

> [!warning] Attention Le compte root a un pouvoir absolu sur le système. Une mauvaise manipulation peut rendre le système inutilisable ou compromettre sa sécurité.

---

## 🔑 Rôle et spécificités du compte root

### Caractéristiques techniques

Le compte root possède des caractéristiques uniques qui le distinguent de tous les autres comptes utilisateurs :

|Caractéristique|Valeur|Description|
|---|---|---|
|**UID**|0|Identifiant utilisateur unique qui confère tous les privilèges|
|**GID**|0|Groupe principal (groupe root)|
|**Répertoire personnel**|`/root`|Distinct de `/home` pour des raisons de sécurité|
|**Shell par défaut**|`/bin/bash`|Shell de commande interactif|
|**Prompt**|`#`|Le symbole `#` indique une session root (vs `$` pour utilisateur normal)|

> [!info] UID 0 : La clé du pouvoir C'est l'UID 0 qui confère les privilèges root, pas le nom du compte. Tout compte avec UID 0 a les mêmes pouvoirs que root.

### Capacités et privilèges

Le compte root peut effectuer toutes les opérations système sans restriction :

**Gestion des fichiers et système de fichiers :**

- Lire, modifier ou supprimer n'importe quel fichier
- Changer les permissions et propriétaires de tous les fichiers
- Monter et démonter des systèmes de fichiers
- Créer des partitions et formater des disques

**Gestion des utilisateurs et groupes :**

- Créer, modifier ou supprimer n'importe quel compte utilisateur
- Modifier les mots de passe de tous les utilisateurs
- Attribuer ou retirer des privilèges

**Administration système :**

- Installer et désinstaller des logiciels
- Configurer le réseau (adresses IP, pare-feu, etc.)
- Gérer les services système (démarrage, arrêt, configuration)
- Charger et décharger des modules noyau
- Modifier la configuration du noyau

**Processus :**

- Tuer n'importe quel processus, même ceux d'autres utilisateurs
- Modifier les priorités des processus sans limitation
- Accéder à tous les processus en cours d'exécution

> [!example] Exemple de vérification Pour vérifier les informations du compte root :
> 
> ```bash
> # Afficher les informations du compte root
> grep "^root:" /etc/passwd
> # Résultat : root:x:0:0:root:/root:/bin/bash
> 
> # Vérifier l'UID de l'utilisateur actuel
> id
> # Si root : uid=0(root) gid=0(root) groups=0(root)
> 
> # Afficher le répertoire personnel
> echo $HOME
> # Résultat si connecté en root : /root
> ```

### Pourquoi le compte root existe-t-il ?

Le compte root est nécessaire pour plusieurs raisons fondamentales :

1. **Administration système** : Certaines tâches requièrent des privilèges élevés par conception (installation de logiciels système, modification de configurations critiques)
    
2. **Séparation des privilèges** : Le modèle de sécurité UNIX/Linux repose sur la distinction entre utilisateurs normaux (limités) et administrateur (privilégié)
    
3. **Récupération système** : En cas de problème, root peut toujours intervenir pour réparer le système
    
4. **Gestion multi-utilisateurs** : Sur un système partagé, root peut gérer tous les utilisateurs sans avoir accès à leurs comptes individuels
    

---

## 🔄 Différences Ubuntu/Debian

Ubuntu et Debian, bien que très similaires, adoptent des philosophies différentes concernant le compte root, notamment pour des raisons de sécurité et de convivialité.

### Debian : root activé par défaut

**Configuration initiale :**

- Lors de l'installation, Debian demande de définir un mot de passe root
- Le compte root est directement accessible et utilisable
- L'utilisateur créé pendant l'installation n'a pas automatiquement les droits sudo

**Utilisation typique :**

```bash
# Connexion en tant que root
su -
# Ou depuis un autre terminal
su - root

# Exécution d'une commande unique en tant que root
su -c "apt update && apt upgrade"
```

> [!info] Approche traditionnelle Debian suit l'approche UNIX traditionnelle où root est un compte séparé et explicite.

### Ubuntu : root désactivé par défaut

**Configuration initiale :**

- Lors de l'installation, aucun mot de passe root n'est demandé
- Le compte root existe mais est verrouillé (pas de mot de passe défini)
- L'utilisateur créé est automatiquement ajouté au groupe `sudo`
- L'utilisation de `sudo` est privilégiée pour les tâches administratives

**Utilisation typique :**

```bash
# Exécution d'une commande avec privilèges root
sudo apt update

# Obtenir un shell root temporaire
sudo -i
# Ou
sudo su -

# Le mot de passe demandé est celui de l'utilisateur, pas de root
```

> [!tip] Philosophie Ubuntu Ubuntu considère que l'utilisation de `sudo` est plus sécurisée car elle évite les sessions root prolongées et crée un journal d'audit.

### Tableau comparatif

|Aspect|Debian|Ubuntu|
|---|---|---|
|**Mot de passe root**|Défini à l'installation|Non défini (compte verrouillé)|
|**Connexion root directe**|Possible par défaut|Impossible sans activation|
|**Méthode privilégiée**|`su` pour devenir root|`sudo` pour exécuter en tant que root|
|**Configuration sudo**|Optionnelle pour l'utilisateur initial|Automatique pour l'utilisateur initial|
|**Fichier /etc/shadow**|Hash du mot de passe présent|`!` ou `*` (compte verrouillé)|
|**Philosophie**|Séparation stricte root/utilisateur|Élévation de privilèges contrôlée|

### Vérifier l'état du compte root

```bash
# Vérifier si le compte root est verrouillé
sudo passwd -S root
# Résultats possibles :
# "root L ..." = Locked (verrouillé) - typique Ubuntu
# "root P ..." = Password set (mot de passe défini) - typique Debian

# Vérifier le hash du mot de passe dans /etc/shadow
sudo grep "^root:" /etc/shadow
# Si commence par "root:!" ou "root:*" = verrouillé
# Si commence par "root:$" = mot de passe défini

# Vérifier si l'utilisateur actuel peut utiliser sudo
sudo -l
# Liste les commandes autorisées via sudo
```

> [!example] Exemple de résultat sur Ubuntu
> 
> ```bash
> $ sudo passwd -S root
> root L 01/15/2024 0 99999 7 -1
> # Le "L" indique que le compte est "Locked"
> 
> $ sudo grep "^root:" /etc/shadow
> root:!:19736:0:99999:7:::
> # Le "!" indique qu'aucun mot de passe valide n'est défini
> ```

---

## 🔧 Activation et désactivation du compte root

### Activer le compte root (Ubuntu)

Sur Ubuntu, si vous souhaitez activer le compte root (par exemple pour une compatibilité avec des scripts Debian ou des besoins spécifiques), vous devez définir un mot de passe.

```bash
# Définir un mot de passe pour le compte root
sudo passwd root
# Vous serez invité à entrer deux fois le nouveau mot de passe

# Vérifier que le compte est maintenant actif
sudo passwd -S root
# Devrait afficher "root P ..." au lieu de "root L ..."

# Se connecter en tant que root
su -
# Entrer le mot de passe root défini précédemment
```

> [!warning] Attention à la sécurité Activer root sur Ubuntu désactive partiellement les avantages de sécurité de l'approche par défaut. Assurez-vous d'utiliser un mot de passe fort et complexe.

### Désactiver le compte root (Debian ou Ubuntu après activation)

Pour revenir à une configuration plus sécurisée où root est verrouillé :

```bash
# Verrouiller le compte root (empêche la connexion par mot de passe)
sudo passwd -l root
# Ou
sudo usermod -L root

# Vérifier que le compte est verrouillé
sudo passwd -S root
# Devrait afficher "root L ..."

# Alternative : supprimer complètement le mot de passe
sudo passwd -d root
# Attention : cela permet une connexion sans mot de passe dans certains contextes
```

> [!info] Différence entre -l et -d
> 
> - `passwd -l` : Verrouille le compte en préfixant le hash du mot de passe avec `!`
> - `passwd -d` : Supprime le mot de passe (champ vide dans /etc/shadow)
> 
> Le verrouillage avec `-l` est généralement préférable car il conserve le mot de passe pour un éventuel déverrouillage ultérieur.

### Configurer sudo sur Debian

Si vous utilisez Debian et souhaitez adopter l'approche Ubuntu avec sudo :

```bash
# Se connecter en tant que root
su -

# Installer sudo s'il n'est pas déjà présent
apt update && apt install sudo

# Ajouter votre utilisateur au groupe sudo
usermod -aG sudo votre_nom_utilisateur
# Le "-aG" ajoute au groupe sans retirer des autres groupes

# Vérifier l'ajout au groupe
groups votre_nom_utilisateur
# Devrait inclure "sudo" dans la liste

# Optionnel : verrouiller le compte root
passwd -l root

# Déconnecter et reconnecter pour que les changements de groupe prennent effet
exit
```

> [!tip] Prise en compte des changements Après avoir ajouté un utilisateur au groupe sudo, il doit se déconnecter complètement et se reconnecter pour que les nouveaux privilèges soient actifs.

### Permettre sudo sans mot de passe (usage avancé)

Pour des environnements de développement ou d'automatisation, il est parfois nécessaire d'autoriser sudo sans demande de mot de passe :

```bash
# Éditer la configuration sudo (utilise l'éditeur par défaut)
sudo visudo

# Ajouter cette ligne pour un utilisateur spécifique
votre_nom_utilisateur ALL=(ALL) NOPASSWD: ALL

# Ou pour tout le groupe sudo
%sudo ALL=(ALL) NOPASSWD: ALL

# Sauvegarder et quitter (Ctrl+X puis Y puis Entrée pour nano)
```

> [!warning] Risque de sécurité majeur Permettre sudo sans mot de passe réduit considérablement la sécurité. Ne le faites que dans des environnements contrôlés (machines virtuelles de développement, conteneurs isolés) et jamais sur des serveurs de production.

**Syntaxe de la ligne sudo :**

```bash
utilisateur HOSTS=(RUNAS) NOPASSWD: COMMANDES

# Exemples :
# Autoriser toutes les commandes sans mot de passe
john ALL=(ALL) NOPASSWD: ALL

# Autoriser uniquement certaines commandes sans mot de passe
john ALL=(ALL) NOPASSWD: /usr/bin/apt, /usr/bin/systemctl

# Autoriser avec mot de passe pour tout sauf quelques commandes
john ALL=(ALL) ALL, NOPASSWD: /usr/bin/apt update
```

---

## 🛡️ Bonnes pratiques de sécurité

### Principe du moindre privilège

> [!tip] Règle d'or N'utilisez les privilèges root que lorsque c'est strictement nécessaire, et pour la durée minimale requise.

**Approches recommandées :**

1. **Utiliser sudo pour des commandes ponctuelles**
    
    ```bash
    # Bien : exécution ponctuelle avec élévation
    sudo apt update
    sudo systemctl restart nginx
    
    # À éviter : session root prolongée
    sudo su -  # puis des heures de travail en root
    ```
    
2. **Préférer sudo à su**
    
    ```bash
    # Recommandé : utilisation de sudo
    sudo commande
    
    # Moins recommandé : devenir root
    su -
    commande
    exit
    ```
    
3. **Limiter les privilèges sudo par utilisateur**
    
    ```bash
    # Dans /etc/sudoers (avec visudo)
    # Permettre seulement certaines commandes
    webadmin ALL=(ALL) /usr/bin/systemctl restart nginx, /usr/bin/systemctl reload nginx
    backupadmin ALL=(ALL) /usr/bin/rsync, /usr/bin/tar
    ```
    

### Protection du mot de passe root

**Complexité du mot de passe :**

- Minimum 16 caractères (idéalement 20+)
- Mélange de majuscules, minuscules, chiffres et symboles
- Pas de mots du dictionnaire ou d'informations personnelles
- Unique (ne jamais réutiliser le mot de passe root ailleurs)

```bash
# Générer un mot de passe fort aléatoire
openssl rand -base64 32
# Ou
pwgen -s 32 1

# Définir le mot de passe
sudo passwd root
```

**Stockage sécurisé :**

- Utiliser un gestionnaire de mots de passe (KeePassXC, Bitwarden, 1Password)
- Ne jamais stocker en clair dans des fichiers
- Documenter où le mot de passe est stocké pour les urgences

> [!warning] Ne jamais faire cela
> 
> - Écrire le mot de passe sur un post-it
> - L'envoyer par email ou messagerie instantanée
> - Le stocker dans un fichier texte non chiffré
> - Utiliser le même mot de passe que d'autres comptes

### Journalisation et audit

Maintenir une traçabilité des actions administratives est crucial pour la sécurité et le débogage.

**Configuration de l'audit sudo :**

```bash
# Les actions sudo sont enregistrées dans les logs système
# Vérifier les logs sudo
sudo grep "sudo" /var/log/auth.log    # Sur Debian/Ubuntu
sudo grep "sudo" /var/log/secure      # Sur RedHat/CentOS

# Afficher les dernières commandes sudo
sudo journalctl _COMM=sudo -n 50

# Exemple de sortie :
# Dec 26 10:15:32 serveur sudo: utilisateur : TTY=pts/0 ; PWD=/home/utilisateur ; USER=root ; COMMAND=/usr/bin/apt update
```

**Configurer des alertes :**

```bash
# Dans /etc/sudoers (avec visudo)
# Envoyer un mail à chaque utilisation de sudo
Defaults    mail_always
Defaults    mailto="admin@exemple.com"

# Enregistrer les entrées/sorties des commandes
Defaults    log_input, log_output
Defaults    iolog_dir=/var/log/sudo-io
```

### Désactivation de la connexion root directe

**Interdire la connexion root via SSH :**

```bash
# Éditer la configuration SSH
sudo nano /etc/ssh/sshd_config

# Trouver et modifier la ligne suivante
PermitRootLogin no
# Ou pour permettre seulement avec clés SSH (pas de mot de passe)
PermitRootLogin prohibit-password

# Redémarrer le service SSH
sudo systemctl restart sshd
```

> [!info] Pourquoi c'est important Les attaques par force brute ciblent systématiquement le compte root. Désactiver sa connexion SSH réduit considérablement la surface d'attaque.

**Désactiver la connexion root sur les consoles physiques (usage avancé) :**

```bash
# Éditer le fichier /etc/securetty
sudo nano /etc/securetty

# Commenter toutes les lignes pour interdire complètement
# tty1
# tty2
# ...

# Ou ne laisser qu'une console d'urgence
tty1  # Seulement la première console physique
```

### Utilisation de clés SSH au lieu de mots de passe

Pour les connexions à distance, les clés SSH sont bien plus sécurisées que les mots de passe.

```bash
# Générer une paire de clés (sur votre machine locale)
ssh-keygen -t ed25519 -C "votre_email@exemple.com"
# Ou pour une compatibilité maximale
ssh-keygen -t rsa -b 4096 -C "votre_email@exemple.com"

# Copier la clé publique vers le serveur
ssh-copy-id utilisateur@serveur
# Entrer le mot de passe une dernière fois

# Tester la connexion
ssh utilisateur@serveur
# Devrait se connecter sans demander de mot de passe

# Sur le serveur : désactiver complètement l'authentification par mot de passe
sudo nano /etc/ssh/sshd_config
# Modifier :
PasswordAuthentication no
ChallengeResponseAuthentication no

# Redémarrer SSH
sudo systemctl restart sshd
```

### Surveillance et détection d'intrusion

**Installer et configurer fail2ban :**

```bash
# Installer fail2ban
sudo apt install fail2ban

# Créer une configuration locale
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local

# Éditer la configuration
sudo nano /etc/fail2ban/jail.local

# Configuration de base pour SSH
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600
findtime = 600

# Démarrer et activer fail2ban
sudo systemctl start fail2ban
sudo systemctl enable fail2ban

# Vérifier l'état
sudo fail2ban-client status
sudo fail2ban-client status sshd
```

### Mises à jour et correctifs de sécurité

Maintenir le système à jour est une des mesures de sécurité les plus importantes.

```bash
# Mettre à jour la liste des paquets et installer les mises à jour
sudo apt update && sudo apt upgrade -y

# Installer les mises à jour de sécurité automatiquement (Ubuntu/Debian)
sudo apt install unattended-upgrades
sudo dpkg-reconfigure -plow unattended-upgrades

# Vérifier les paquets qui nécessitent un redémarrage
sudo needrestart
```

### Checklist de sécurité root

> [!tip] Checklist à appliquer sur chaque système
> 
> - [ ] Mot de passe root fort et unique (ou compte verrouillé si sudo)
> - [ ] Utilisateurs administratifs dans le groupe sudo avec des privilèges limités
> - [ ] PermitRootLogin no dans /etc/ssh/sshd_config
> - [ ] Authentification SSH par clés uniquement (PasswordAuthentication no)
> - [ ] fail2ban installé et configuré
> - [ ] Logs sudo activés et surveillés
> - [ ] Mises à jour automatiques de sécurité activées
> - [ ] Firewall configuré (ufw ou iptables)
> - [ ] Surveillance régulière des logs (/var/log/auth.log)
> - [ ] Sessions root minimales et tracées

### Erreurs courantes à éviter

> [!warning] Pièges fréquents **1. Travailler en root de façon permanente**
> 
> ```bash
> # ❌ Mauvais : session root prolongée
> sudo su -
> # ... des heures de travail ...
> 
> # ✅ Bon : élévation ponctuelle
> sudo commande_nécessitant_root
> ```
> 
> **2. Permissions trop permissives**
> 
> ```bash
> # ❌ Mauvais : donner tous les droits sudo sans restriction
> utilisateur ALL=(ALL) NOPASSWD: ALL
> 
> # ✅ Bon : limiter aux commandes nécessaires
> utilisateur ALL=(ALL) /usr/bin/systemctl restart nginx
> ```
> 
> **3. Partager le mot de passe root**
> 
> ```bash
> # ❌ Mauvais : plusieurs personnes connaissent le mot de passe root
> # Impossible de tracer qui fait quoi
> 
> # ✅ Bon : chacun utilise sudo avec son propre compte
> # Les actions sont tracées individuellement dans les logs
> ```
> 
> **4. Ne pas surveiller les logs**
> 
> ```bash
> # ❌ Mauvais : ne jamais regarder les logs
> 
> # ✅ Bon : vérification régulière
> sudo grep "FAILED\|Failed" /var/log/auth.log | tail -n 20
> sudo last -f /var/log/wtmp | head -n 20
> ```

---

## 🎓 Récapitulatif

Le compte root est l'administrateur ultime d'un système Linux avec un pouvoir absolu (UID 0). Les distributions modernes comme Ubuntu privilégient l'approche sudo pour limiter les risques, tandis que Debian maintient une séparation traditionnelle avec un compte root actif.

**Points clés à retenir :**

- Le compte root a tous les privilèges sans exception (UID 0)
- Ubuntu verrouille root par défaut et favorise sudo
- Debian active root par défaut et utilise su
- Utiliser root seulement quand nécessaire (principe du moindre privilège)
- Préférer sudo à su pour la traçabilité et la sécurité
- Protéger l'accès root avec des mots de passe forts et des clés SSH
- Journaliser et surveiller toutes les actions administratives
- Désactiver la connexion root directe en SSH
- Maintenir le système à jour pour corriger les vulnérabilités

> [!info] En pratique Sur un système de production moderne, la configuration idéale est généralement : compte root verrouillé, accès sudo limité par utilisateur et commande, authentification SSH par clés uniquement, et surveillance active des logs.