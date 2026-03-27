

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

## 🎯 Introduction

SSH (Secure Shell) est un protocole de communication sécurisé qui permet de se connecter à distance à un serveur Linux. Pour accepter des connexions SSH entrantes, une machine doit avoir un **serveur SSH** installé et configuré. La solution la plus répandue est **OpenSSH**, qui offre à la fois le client (`ssh`) et le serveur (`sshd`).

> [!info] Pourquoi installer un serveur SSH ?
> 
> - Administrer des serveurs distants de manière sécurisée
> - Transférer des fichiers via SCP ou SFTP
> - Créer des tunnels sécurisés
> - Automatiser des tâches avec des scripts

---

## 📦 Installation du serveur OpenSSH

### Installation sur Debian/Ubuntu

Sur les distributions basées sur Debian, le paquet à installer s'appelle `openssh-server`.

```bash
# Mise à jour de la liste des paquets
sudo apt update

# Installation du serveur OpenSSH
sudo apt install openssh-server -y
```

> [!tip] Astuce L'option `-y` permet de confirmer automatiquement l'installation sans interaction manuelle.

### Vérification de l'installation

Une fois l'installation terminée, vous pouvez vérifier que le paquet est bien installé :

```bash
# Vérifier la version installée
ssh -V

# Vérifier que le démon sshd est présent
which sshd

# Afficher les informations du paquet
dpkg -l | grep openssh-server
```

> [!example] Exemple de sortie
> 
> ```
> OpenSSH_8.9p1 Ubuntu-3ubuntu0.6, OpenSSL 3.0.2 15 Mar 2022
> /usr/sbin/sshd
> ii  openssh-server  1:8.9p1-3ubuntu0.6  amd64  secure shell (SSH) server
> ```

### Différence entre client et serveur

|Composant|Paquet|Rôle|Commande principale|
|---|---|---|---|
|**Client SSH**|`openssh-client`|Se connecter à des serveurs distants|`ssh`|
|**Serveur SSH**|`openssh-server`|Accepter des connexions entrantes|`sshd`|

> [!info] Note Le client SSH (`openssh-client`) est généralement préinstallé sur la plupart des distributions Linux. Le serveur doit être installé manuellement.

---

## 🚀 Démarrage et arrêt du service

Le serveur SSH est géré par **systemd** sur les distributions modernes. Le service s'appelle `ssh` (Debian/Ubuntu) ou `sshd` (RedHat/CentOS).

### Démarrer le service SSH

```bash
# Démarrer le service (Debian/Ubuntu)
sudo systemctl start ssh

# Ou sur RedHat/CentOS
sudo systemctl start sshd
```

> [!warning] Attention Sur Debian/Ubuntu, le service s'appelle `ssh`, mais sur d'autres distributions comme CentOS/RHEL, il s'appelle `sshd`. Adaptez les commandes selon votre distribution.

### Arrêter le service SSH

```bash
# Arrêter le service
sudo systemctl stop ssh

# Vérifier que le service est bien arrêté
sudo systemctl is-active ssh
```

> [!tip] Quand arrêter le service ?
> 
> - Pour effectuer des modifications sensibles de configuration
> - Pour des raisons de sécurité temporaires
> - Pour diagnostiquer des problèmes de connexion

### Tableau récapitulatif des commandes de base

|Action|Commande|Effet|
|---|---|---|
|Démarrer|`sudo systemctl start ssh`|Lance le service SSH|
|Arrêter|`sudo systemctl stop ssh`|Arrête le service SSH|
|Redémarrer|`sudo systemctl restart ssh`|Arrête puis redémarre le service|
|Recharger|`sudo systemctl reload ssh`|Recharge la configuration sans couper les connexions|

---

## 🔄 Activation au démarrage

Par défaut, après l'installation d'OpenSSH, le service est souvent activé automatiquement au démarrage. Il est néanmoins important de savoir gérer ce comportement.

### Activer le service au démarrage

```bash
# Activer le démarrage automatique
sudo systemctl enable ssh

# Vérifier que l'activation est bien configurée
sudo systemctl is-enabled ssh
```

> [!example] Sortie attendue
> 
> ```
> enabled
> ```

### Désactiver le service au démarrage

```bash
# Désactiver le démarrage automatique
sudo systemctl disable ssh

# Vérifier la désactivation
sudo systemctl is-enabled ssh
```

> [!example] Sortie attendue
> 
> ```
> disabled
> ```

### Activation ET démarrage en une seule commande

```bash
# Active le service au démarrage ET le démarre immédiatement
sudo systemctl enable --now ssh

# Désactive le service au démarrage ET l'arrête immédiatement
sudo systemctl disable --now ssh
```

> [!tip] Bonne pratique Sur un serveur de production, laissez toujours le service SSH activé au démarrage pour pouvoir accéder à la machine en cas de redémarrage.

### Comprendre la différence : start vs enable

|Commande|Effet immédiat|Effet au prochain démarrage|
|---|---|---|
|`systemctl start`|Démarre le service maintenant|❌ Aucun effet|
|`systemctl enable`|❌ Aucun effet|Démarre le service automatiquement|
|`systemctl enable --now`|Démarre le service maintenant|Démarre le service automatiquement|

---

## 🔍 Vérification du statut

La commande `systemctl status` est l'outil principal pour diagnostiquer l'état du service SSH.

### Afficher le statut complet

```bash
# Afficher le statut détaillé du service
sudo systemctl status ssh
```

> [!example] Exemple de sortie d'un service actif
> 
> ```
> ● ssh.service - OpenBSD Secure Shell server
>      Loaded: loaded (/lib/systemd/system/ssh.service; enabled; vendor preset: enabled)
>      Active: active (running) since Mon 2024-12-15 10:30:45 CET; 2h 15min ago
>        Docs: man:sshd(8)
>              man:sshd_config(5)
>     Process: 1234 ExecStartPre=/usr/sbin/sshd -t (code=exited, status=0/SUCCESS)
>    Main PID: 1235 (sshd)
>       Tasks: 1 (limit: 4915)
>      Memory: 3.2M
>         CPU: 45ms
>      CGroup: /system.slice/ssh.service
>              └─1235 sshd: /usr/sbin/sshd -D [listener] 0 of 10-100 startups
> 
> Dec 15 10:30:45 serveur systemd[1]: Starting OpenBSD Secure Shell server...
> Dec 15 10:30:45 serveur sshd[1235]: Server listening on 0.0.0.0 port 22.
> Dec 15 10:30:45 serveur sshd[1235]: Server listening on :: port 22.
> Dec 15 10:30:45 serveur systemd[1]: Started OpenBSD Secure Shell server.
> ```

### Interpréter la sortie de systemctl status

|Élément|Description|Valeurs courantes|
|---|---|---|
|**Loaded**|Le service est-il chargé ?|`loaded` (présent) ou `not-found` (absent)|
|**Active**|État du service|`active (running)` (en cours), `inactive (dead)` (arrêté), `failed` (échec)|
|**enabled**|Démarre-t-il au boot ?|`enabled` (oui), `disabled` (non)|
|**Main PID**|Processus principal|Numéro du processus `sshd`|
|**Logs récents**|Dernières lignes du journal|Messages de démarrage et événements|

### Commandes rapides de vérification

```bash
# Vérifier si le service est actif (running)
sudo systemctl is-active ssh

# Vérifier si le service est activé au démarrage
sudo systemctl is-enabled ssh

# Vérifier si le service a échoué
sudo systemctl is-failed ssh

# Afficher uniquement l'état principal (sans les logs)
sudo systemctl show -p ActiveState ssh

# Vérifier que le port 22 est bien en écoute
sudo ss -tlnp | grep :22
# ou
sudo netstat -tlnp | grep :22
```

> [!example] Sortie de la vérification du port
> 
> ```
> LISTEN  0  128  0.0.0.0:22  0.0.0.0:*  users:(("sshd",pid=1235,fd=3))
> LISTEN  0  128     [::]:22     [::]:*  users:(("sshd",pid=1235,fd=4))
> ```

> [!tip] Astuce de diagnostic Si `systemctl status` indique que le service est actif mais que vous ne pouvez pas vous connecter, vérifiez :
> 
> - Le pare-feu (firewall) : `sudo ufw status` ou `sudo iptables -L`
> - Le port d'écoute : `sudo ss -tlnp | grep ssh`
> - Le fichier de configuration : `sudo sshd -t` (test de syntaxe)

---

## 🔧 Redémarrage et rechargement

Lorsque vous modifiez la configuration SSH, vous devez informer le service de prendre en compte ces changements. Il existe deux approches : le redémarrage et le rechargement.

### Redémarrer le service

Le redémarrage **arrête complètement** le service puis le redémarre. Cela **coupe toutes les connexions SSH actives**.

```bash
# Redémarrer le service SSH
sudo systemctl restart ssh
```

> [!warning] Attention - Connexions coupées ! Un `restart` déconnecte tous les utilisateurs SSH actuellement connectés. À utiliser avec précaution sur des serveurs en production.

### Recharger la configuration

Le rechargement lit à nouveau le fichier de configuration **sans interrompre les connexions actives**. Les nouvelles connexions utiliseront la nouvelle configuration, mais les sessions existantes continuent avec l'ancienne.

```bash
# Recharger la configuration SSH
sudo systemctl reload ssh
```

> [!tip] Bonne pratique Privilégiez toujours `reload` plutôt que `restart` pour éviter de déconnecter les utilisateurs. Le `restart` ne devrait être utilisé que si le rechargement ne fonctionne pas ou si un changement majeur le nécessite.

### Différences entre restart et reload

|Aspect|`restart`|`reload`|
|---|---|---|
|**Connexions actives**|❌ Coupées immédiatement|✅ Conservées|
|**Nouvelles connexions**|✅ Nouvelle config appliquée|✅ Nouvelle config appliquée|
|**Temps d'interruption**|Quelques secondes|Aucun|
|**Cas d'usage**|Changements majeurs, dépannage|Modifications de configuration normales|

### Tester la configuration avant de recharger

Avant de recharger ou redémarrer, il est **crucial** de vérifier que le fichier de configuration ne contient pas d'erreurs.

```bash
# Tester la syntaxe du fichier de configuration
sudo sshd -t

# Tester et afficher la configuration complète
sudo sshd -T
```

> [!example] Sortie en cas de succès
> 
> ```
> # Aucune sortie = configuration valide
> ```

> [!example] Sortie en cas d'erreur
> 
> ```
> /etc/ssh/sshd_config line 42: Bad configuration option: InvalidOption
> /etc/ssh/sshd_config: terminating, 1 bad configuration options
> ```

> [!warning] Piège courant Si vous redémarrez le service SSH avec une configuration invalide, le service **ne démarrera pas** et vous risquez de perdre l'accès à votre serveur distant ! Utilisez **toujours** `sshd -t` avant un `restart`.

### Workflow recommandé pour modifier la configuration

```bash
# 1. Sauvegarder la configuration actuelle
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup

# 2. Modifier la configuration
sudo nano /etc/ssh/sshd_config

# 3. Tester la syntaxe
sudo sshd -t

# 4. Si le test est OK, recharger la configuration
sudo systemctl reload ssh

# 5. Vérifier que le service fonctionne toujours
sudo systemctl status ssh
```

> [!tip] Astuce de sécurité Avant de redémarrer SSH sur un serveur distant, ouvrez une **deuxième session SSH** de secours. Si votre modification casse le service, vous aurez toujours cette session pour corriger le problème.

### Commandes avancées

```bash
# Forcer un redémarrage même si l'arrêt échoue
sudo systemctl restart --force ssh

# Recharger la configuration de systemd (si vous avez modifié le fichier .service)
sudo systemctl daemon-reload
sudo systemctl restart ssh

# Afficher les erreurs détaillées en cas de problème
sudo journalctl -xeu ssh
```

---

## 🎯 Récapitulatif des commandes essentielles

|Objectif|Commande|Note|
|---|---|---|
|**Installer**|`sudo apt install openssh-server`|Debian/Ubuntu|
|**Démarrer**|`sudo systemctl start ssh`|Effet immédiat uniquement|
|**Arrêter**|`sudo systemctl stop ssh`|Coupe les connexions|
|**Activer au boot**|`sudo systemctl enable ssh`|Persistant après redémarrage|
|**Désactiver au boot**|`sudo systemctl disable ssh`|N'arrête pas le service actuel|
|**Statut**|`sudo systemctl status ssh`|Diagnostic complet|
|**Redémarrer**|`sudo systemctl restart ssh`|⚠️ Coupe les connexions|
|**Recharger**|`sudo systemctl reload ssh`|✅ Préférez cette option|
|**Tester la config**|`sudo sshd -t`|À faire AVANT tout restart|
|**Vérifier le port**|`sudo ss -tlnp \| grep :22`|Port d'écoute|

---

## ⚠️ Pièges courants et solutions

### Problème 1 : Service qui ne démarre pas

**Symptôme** : `sudo systemctl start ssh` échoue

```bash
# Vérifier les logs d'erreur
sudo journalctl -xeu ssh

# Tester la configuration
sudo sshd -t

# Vérifier qu'un autre processus n'occupe pas le port 22
sudo ss -tlnp | grep :22
```

### Problème 2 : Configuration cassée après un restart

**Symptôme** : Impossible de se connecter après un `restart`

> [!warning] Solution préventive
> 
> - Toujours utiliser `sudo sshd -t` AVANT de redémarrer
> - Garder une session SSH ouverte de secours
> - Faire une copie de sauvegarde : `sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup`

**Solution curative** :

```bash
# Restaurer la sauvegarde
sudo cp /etc/ssh/sshd_config.backup /etc/ssh/sshd_config

# Redémarrer
sudo systemctl restart ssh
```

### Problème 3 : Confusion restart vs reload

**Erreur courante** : Utiliser `restart` systématiquement

> [!tip] Règle à retenir
> 
> - `reload` = garde les connexions → à privilégier
> - `restart` = coupe tout → seulement si nécessaire

### Problème 4 : Pare-feu bloque les connexions

**Symptôme** : Service actif mais connexion impossible

```bash
# Vérifier le pare-feu UFW (Ubuntu)
sudo ufw status
sudo ufw allow 22/tcp

# Vérifier iptables
sudo iptables -L -n | grep 22
```

---

> [!info] 📚 Fin de la partie Installation et Configuration Vous savez maintenant installer, démarrer, arrêter et gérer le service SSH sur Linux. Les parties suivantes du cours aborderont la configuration détaillée du serveur SSH, la sécurisation, l'authentification par clés, et bien plus encore.