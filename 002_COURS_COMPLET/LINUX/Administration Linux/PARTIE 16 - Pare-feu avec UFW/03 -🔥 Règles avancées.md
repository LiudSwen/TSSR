

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

## 🎯 Autorisation par adresse IP ou plage

### Pourquoi filtrer par IP ?

Le filtrage par adresse IP permet de créer des règles granulaires pour autoriser ou refuser l'accès à des services uniquement depuis des sources de confiance. C'est essentiel pour :

- Limiter l'accès SSH à votre réseau administratif
- Autoriser uniquement certains serveurs à accéder à une base de données
- Créer des zones de confiance dans votre infrastructure
- Réduire la surface d'attaque en limitant les accès publics

### Autoriser une IP spécifique

```bash
# Autoriser tout le trafic depuis une IP spécifique
sudo ufw allow from 192.168.1.100

# Autoriser une IP spécifique sur un port précis
sudo ufw allow from 192.168.1.100 to any port 22

# Autoriser une IP sur un port avec un protocole spécifique
sudo ufw allow from 192.168.1.100 to any port 3306 proto tcp
```

> [!example] Exemple pratique Vous voulez autoriser uniquement votre machine de bureau (IP : 10.0.0.50) à accéder au SSH de votre serveur :
> 
> ```bash
> sudo ufw allow from 10.0.0.50 to any port 22
> ```
> 
> Résultat : Seule votre machine peut se connecter en SSH, toutes les autres sont bloquées (si la politique par défaut est deny).

### Autoriser une plage d'IP (CIDR)

La notation CIDR (Classless Inter-Domain Routing) permet de spécifier un bloc d'adresses IP.

```bash
# Autoriser tout un sous-réseau /24 (256 adresses)
sudo ufw allow from 192.168.1.0/24

# Autoriser un sous-réseau sur un port spécifique
sudo ufw allow from 10.0.0.0/8 to any port 443

# Autoriser une plage plus petite /29 (8 adresses)
sudo ufw allow from 172.16.0.0/29 to any port 5432 proto tcp
```

> [!info] Rappel CIDR
> 
> - `/32` = 1 seule adresse (équivalent à une IP spécifique)
> - `/24` = 256 adresses (192.168.1.0 à 192.168.1.255)
> - `/16` = 65 536 adresses
> - `/8` = 16 777 216 adresses

### Filtrer par IP source et port de destination

Vous pouvez combiner plusieurs critères pour un contrôle précis :

```bash
# IP source spécifique vers un port de destination
sudo ufw allow from 203.0.113.5 to any port 80 proto tcp

# Plage IP vers une interface réseau spécifique
sudo ufw allow from 192.168.100.0/24 to 10.0.0.1 port 22

# Autoriser depuis un réseau local vers plusieurs ports
sudo ufw allow from 192.168.1.0/24 to any port 80,443 proto tcp
```

> [!tip] Astuce : Combiner avec des interfaces Vous pouvez aussi spécifier l'interface réseau :
> 
> ```bash
> sudo ufw allow in on eth1 from 192.168.1.0/24 to any port 22
> ```
> 
> Cela autorise le SSH uniquement depuis le réseau 192.168.1.0/24 sur l'interface eth1.

### Refuser des IP spécifiques

Parfois, il est plus simple de bloquer quelques IP malveillantes plutôt que de tout refuser :

```bash
# Bloquer une IP spécifique
sudo ufw deny from 198.51.100.44

# Bloquer une IP sur un port précis
sudo ufw deny from 198.51.100.44 to any port 22

# Bloquer tout un sous-réseau
sudo ufw deny from 203.0.113.0/24
```

> [!warning] Ordre des règles important UFW traite les règles dans l'ordre. Si vous avez une règle `allow from 192.168.1.0/24` et ensuite `deny from 192.168.1.50`, l'IP 192.168.1.50 sera autorisée car la première règle correspond en premier.
> 
> Pour bloquer une IP spécifique d'un réseau autorisé, placez la règle `deny` AVANT la règle `allow`.

---

## 🗑️ Suppression de règles

### Méthode 1 : Par numéro de règle

C'est la méthode la plus pratique et la plus sûre.

```bash
# Lister les règles avec leurs numéros
sudo ufw status numbered

# Exemple de sortie :
# Status: active
# 
#      To                         Action      From
#      --                         ------      ----
# [ 1] 22/tcp                     ALLOW IN    192.168.1.100
# [ 2] 80/tcp                     ALLOW IN    Anywhere
# [ 3] 443/tcp                    ALLOW IN    Anywhere
# [ 4] 22/tcp (v6)                ALLOW IN    Anywhere (v6)

# Supprimer la règle numéro 1
sudo ufw delete 1
```

> [!example] Supprimer plusieurs règles Pour supprimer plusieurs règles, commencez toujours par les numéros les plus élevés pour éviter le décalage des numéros :
> 
> ```bash
> sudo ufw delete 4
> sudo ufw delete 3
> sudo ufw delete 2
> ```

### Méthode 2 : Par règle exacte

Vous pouvez aussi supprimer une règle en répétant exactement la commande qui l'a créée, en ajoutant `delete` devant.

```bash
# Si vous avez créé cette règle :
sudo ufw allow from 192.168.1.100 to any port 22

# Vous la supprimez ainsi :
sudo ufw delete allow from 192.168.1.100 to any port 22
```

```bash
# Autres exemples
sudo ufw delete allow 80/tcp
sudo ufw delete deny from 198.51.100.44
sudo ufw delete allow from 10.0.0.0/8 to any port 443
```

> [!warning] Syntaxe exacte requise La syntaxe doit être EXACTEMENT la même que lors de la création. Si vous avez écrit :
> 
> ```bash
> sudo ufw allow 22
> ```
> 
> Alors `sudo ufw delete allow 22/tcp` ne fonctionnera pas. Utilisez plutôt la méthode par numéro.

### Vérification après suppression

```bash
# Vérifier que la règle est bien supprimée
sudo ufw status numbered

# Vérifier les règles détaillées
sudo ufw status verbose
```

> [!tip] Bonne pratique Avant de supprimer une règle critique (comme SSH), assurez-vous d'avoir un accès physique ou console au serveur, ou une règle de secours en place.

---

## 🔄 Réinitialisation d'UFW

### Réinitialisation complète

La réinitialisation supprime **toutes** les règles et restaure UFW à son état par défaut.

```bash
# Réinitialiser UFW (demande confirmation)
sudo ufw reset

# Exemple de sortie :
# Resetting all rules to installed defaults. This may disrupt existing ssh
# connections. Proceed with operation (y|n)? y
# Backing up 'user.rules' to '/etc/ufw/user.rules.20241227_143052'
# Backing up 'user6.rules' to '/etc/ufw/user6.rules.20241227_143052'
```

> [!warning] Attention aux connexions SSH ! La réinitialisation peut couper vos connexions SSH actives. Les sauvegardes sont créées automatiquement, mais **toutes vos règles personnalisées seront supprimées**.

### Ce qui se passe après un reset

```bash
# Après un reset, UFW est dans cet état :
# - Status : inactive
# - Toutes les règles personnalisées supprimées
# - Politiques par défaut restaurées (généralement : deny incoming, allow outgoing)
# - Les fichiers de configuration originaux sont sauvegardés

# Vérifier l'état après reset
sudo ufw status
# Status: inactive
```

### Cas d'usage de la réinitialisation

|Situation|Action|
|---|---|
|Configuration corrompue|`sudo ufw reset` puis reconfigurer proprement|
|Trop de règles en désordre|Reset et repartir de zéro|
|Migration de configuration|Reset, puis importer la nouvelle config|
|Problème de connectivité inexpliqué|Reset temporairement pour diagnostiquer|
|Audit de sécurité|Repartir d'une base saine|

> [!tip] Alternative au reset complet Si vous voulez simplement désactiver UFW temporairement sans perdre les règles :
> 
> ```bash
> sudo ufw disable
> # Faire vos tests ou modifications
> sudo ufw enable
> ```

### Restauration après reset

Si vous voulez restaurer une configuration précédente :

```bash
# Les sauvegardes sont dans /etc/ufw/
ls -la /etc/ufw/*.rules.*

# Exemple de sauvegardes :
# /etc/ufw/user.rules.20241227_143052
# /etc/ufw/user6.rules.20241227_143052

# Pour restaurer (avec précaution) :
sudo cp /etc/ufw/user.rules.20241227_143052 /etc/ufw/user.rules
sudo cp /etc/ufw/user6.rules.20241227_143052 /etc/ufw/user6.rules
sudo ufw reload
```

> [!warning] Restauration manuelle La restauration manuelle doit être faite avec précaution. Assurez-vous que les fichiers de sauvegarde correspondent bien à la configuration que vous souhaitez restaurer.

---

## 🐧 Différences selon les distributions

### Tableau comparatif

|Distribution|UFW préinstallé ?|Installation|Particularités|
|---|---|---|---|
|**Ubuntu**|✅ Oui (depuis 8.04)|Déjà présent|Configuration par défaut inactive|
|**Debian**|❌ Non|`apt install ufw`|Nécessite installation manuelle|
|**Linux Mint**|✅ Oui|Déjà présent|Basé sur Ubuntu, même comportement|
|**Fedora**|❌ Non (utilise firewalld)|`dnf install ufw` puis désactiver firewalld|Conflit possible avec firewalld|
|**CentOS/RHEL**|❌ Non (utilise firewalld)|`yum install ufw`|Nécessite EPEL, conflit avec firewalld|
|**Arch Linux**|❌ Non|`pacman -S ufw`|Installation depuis dépôts officiels|
|**openSUSE**|❌ Non (utilise firewalld)|`zypper install ufw`|Conflit possible avec firewalld|
|**Pop!_OS**|✅ Oui|Déjà présent|Basé sur Ubuntu|
|**Kali Linux**|✅ Oui|Déjà présent|Basé sur Debian, mais préinstallé|

### Installation sur différentes distributions

#### Ubuntu / Linux Mint / Pop!_OS

```bash
# UFW est déjà installé, il suffit de l'activer
sudo ufw status
# Status: inactive

# Si besoin de l'installer (rare)
sudo apt update
sudo apt install ufw
```

#### Debian

```bash
# Installation
sudo apt update
sudo apt install ufw

# Vérification
sudo ufw status
```

#### Fedora

```bash
# Désactiver firewalld d'abord
sudo systemctl stop firewalld
sudo systemctl disable firewalld

# Installer UFW
sudo dnf install ufw

# Activer UFW
sudo systemctl enable ufw
sudo systemctl start ufw
```

> [!warning] Conflit avec firewalld Sur Fedora, CentOS, et RHEL, **firewalld** est le pare-feu par défaut. Vous devez le désactiver avant d'utiliser UFW pour éviter les conflits.

#### CentOS / RHEL

```bash
# Activer le dépôt EPEL
sudo yum install epel-release

# Désactiver firewalld
sudo systemctl stop firewalld
sudo systemctl disable firewalld

# Installer UFW
sudo yum install ufw

# Activer UFW au démarrage
sudo systemctl enable ufw
sudo systemctl start ufw
```

#### Arch Linux

```bash
# Installation
sudo pacman -S ufw

# Activer au démarrage
sudo systemctl enable ufw
sudo systemctl start ufw
```

#### openSUSE

```bash
# Désactiver firewalld
sudo systemctl stop firewalld
sudo systemctl disable firewalld

# Installer UFW
sudo zypper install ufw

# Activer UFW
sudo systemctl enable ufw
sudo systemctl start ufw
```

### Comportement par défaut selon la distribution

```bash
# Vérifier si UFW démarre automatiquement
systemctl is-enabled ufw

# Sur Ubuntu/Debian : généralement 'disabled' par défaut
# Sur d'autres distributions : dépend de l'installation
```

> [!info] Politique par défaut Quelle que soit la distribution, après installation d'UFW :
> 
> - Status : **inactive** par défaut
> - Politique incoming : **deny** (après activation)
> - Politique outgoing : **allow** (après activation)
> - Aucune règle personnalisée

### Spécificités importantes

#### Ubuntu et dérivés

```bash
# Sur Ubuntu, UFW est intégré mais désactivé
# Cela évite de bloquer accidentellement l'accès lors de l'installation

# Premier démarrage recommandé :
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw enable
```

#### Distributions avec firewalld

Sur les distributions qui utilisent **firewalld** par défaut (Fedora, CentOS, RHEL, openSUSE), vous devez faire un choix :

```bash
# Option 1 : Utiliser firewalld (recommandé sur ces distributions)
sudo firewall-cmd --list-all

# Option 2 : Passer à UFW
sudo systemctl stop firewalld
sudo systemctl disable firewalld
sudo systemctl mask firewalld  # Empêche la réactivation accidentelle
sudo dnf install ufw
sudo systemctl enable --now ufw
```

> [!tip] Cohérence dans l'infrastructure Si vous gérez plusieurs serveurs :
> 
> - Gardez le même pare-feu sur toutes vos machines (UFW partout ou firewalld partout)
> - Cela simplifie la maintenance et réduit les erreurs
> - Utilisez des outils de gestion de configuration (Ansible, Puppet) pour uniformiser

---

## 🎯 Pièges courants à éviter

> [!warning] Erreurs fréquentes
> 
> **1. Ordre des règles incorrect**
> 
> ```bash
> # ❌ Mauvais : l'IP sera autorisée par la première règle
> sudo ufw allow from 192.168.1.0/24
> sudo ufw deny from 192.168.1.50
> 
> # ✅ Bon : deny avant allow
> sudo ufw deny from 192.168.1.50
> sudo ufw allow from 192.168.1.0/24
> ```
> 
> **2. Oublier de spécifier le protocole**
> 
> ```bash
> # ❌ Autorise TCP et UDP
> sudo ufw allow from 10.0.0.5 to any port 53
> 
> # ✅ Spécifique pour DNS
> sudo ufw allow from 10.0.0.5 to any port 53 proto udp
> sudo ufw allow from 10.0.0.5 to any port 53 proto tcp
> ```
> 
> **3. Se bloquer l'accès SSH**
> 
> ```bash
> # ❌ Danger : reset sans règle SSH
> sudo ufw reset
> sudo ufw default deny incoming
> sudo ufw enable  # Vous êtes bloqué !
> 
> # ✅ Toujours autoriser SSH avant d'activer
> sudo ufw reset
> sudo ufw default deny incoming
> sudo ufw allow 22/tcp
> sudo ufw enable
> ```

---

## 📚 Récapitulatif des commandes essentielles

```bash
# Filtrage par IP
sudo ufw allow from <IP>
sudo ufw allow from <IP> to any port <PORT>
sudo ufw allow from <IP/CIDR> to any port <PORT> proto <tcp|udp>

# Suppression de règles
sudo ufw status numbered              # Lister avec numéros
sudo ufw delete <NUMERO>              # Supprimer par numéro
sudo ufw delete <REGLE_COMPLETE>      # Supprimer par règle exacte

# Réinitialisation
sudo ufw reset                        # Reset complet
sudo ufw disable                      # Désactiver temporairement
sudo ufw enable                       # Réactiver

# Vérifications
sudo ufw status verbose               # Statut détaillé
sudo ufw status numbered              # Avec numéros de règles
systemctl is-enabled ufw              # Vérifie démarrage auto
```

---

**📌 Points clés à retenir :**

1. **Filtrage par IP** : Utilisez CIDR pour des plages d'adresses, spécifiez toujours le protocole si nécessaire
2. **Suppression** : Privilégiez la méthode par numéro, plus fiable et plus sûre
3. **Reset** : Fait une sauvegarde automatique, mais détruit toute la configuration actuelle
4. **Distributions** : UFW est natif sur Ubuntu, nécessite installation ailleurs et peut entrer en conflit avec firewalld

> [!tip] Bonne pratique finale Documentez toujours vos règles UFW dans un fichier texte ou un système de gestion de configuration. En cas de reset ou de migration, vous pourrez recréer votre configuration rapidement et sans erreur.