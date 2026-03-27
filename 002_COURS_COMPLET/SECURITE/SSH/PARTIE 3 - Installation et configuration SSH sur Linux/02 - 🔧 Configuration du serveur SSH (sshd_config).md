

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

Le fichier `sshd_config` est le cœur de la configuration du serveur SSH (OpenSSH daemon). Il contrôle tous les aspects du comportement du serveur : ports d'écoute, méthodes d'authentification, restrictions d'accès, et paramètres de sécurité. Une configuration appropriée est cruciale pour maintenir un serveur SSH sécurisé et fonctionnel.

> [!info] Différence entre ssh_config et sshd_config
> 
> - **sshd_config** : Configuration du **serveur** SSH (daemon)
> - **ssh_config** : Configuration du **client** SSH Ne les confondez pas !

---

## Localisation du fichier de configuration

### 📂 Emplacement standard

Le fichier de configuration principal se trouve généralement à :

```bash
/etc/ssh/sshd_config
```

### Structure des fichiers de configuration

Sur les systèmes modernes, la configuration peut être organisée en plusieurs fichiers :

```bash
# Fichier principal
/etc/ssh/sshd_config

# Fichiers de configuration additionnels (inclus via Include)
/etc/ssh/sshd_config.d/*.conf
```

> [!tip] Organisation modulaire Les distributions récentes (Ubuntu 22.04+, Debian 11+) utilisent `/etc/ssh/sshd_config.d/` pour permettre une configuration modulaire. Vous pouvez créer vos propres fichiers `.conf` dans ce répertoire plutôt que de modifier directement `sshd_config`.

### Vérifier quel fichier est utilisé

```bash
# Afficher le fichier de configuration actif
sudo sshd -T

# Afficher les fichiers inclus
grep -r "^Include" /etc/ssh/sshd_config
```

### Éditer le fichier de configuration

```bash
# Avec votre éditeur préféré
sudo nano /etc/ssh/sshd_config
sudo vim /etc/ssh/sshd_config

# Pour une configuration personnalisée modulaire
sudo nano /etc/ssh/sshd_config.d/custom.conf
```

> [!warning] Attention aux permissions Le fichier `sshd_config` doit appartenir à root et avoir des permissions restrictives :
> 
> ```bash
> sudo chown root:root /etc/ssh/sshd_config
> sudo chmod 600 /etc/ssh/sshd_config
> ```

---

## Paramètres de base

### Port d'écoute

Le paramètre `Port` définit sur quel port TCP le serveur SSH écoute les connexions entrantes.

```bash
# Port par défaut
Port 22

# Port personnalisé (recommandé pour réduire les scans automatisés)
Port 2222
```

**Pourquoi changer le port ?**

- Réduire les tentatives de connexion automatisées (bots qui scannent le port 22)
- Contourner certaines restrictions réseau
- Sécurité par l'obscurité (couche supplémentaire, mais ne remplace pas une vraie sécurité)

**Écouter sur plusieurs ports :**

```bash
Port 22
Port 2222
```

> [!warning] Pare-feu et SELinux Si vous changez le port, pensez à :
> 
> 1. Ouvrir le nouveau port dans votre pare-feu
> 2. Mettre à jour SELinux (si actif) :
> 
> ```bash
> sudo semanage port -a -t ssh_port_t -p tcp 2222
> ```

### Adresse d'écoute

Le paramètre `ListenAddress` spécifie sur quelle(s) interface(s) réseau le serveur doit écouter.

```bash
# Écouter sur toutes les interfaces (IPv4 et IPv6) - par défaut
#ListenAddress 0.0.0.0
#ListenAddress ::

# Écouter uniquement sur une IP spécifique
ListenAddress 192.168.1.100

# Écouter sur plusieurs adresses
ListenAddress 192.168.1.100
ListenAddress 10.0.0.50

# Combinaison IP et port
ListenAddress 192.168.1.100:22
ListenAddress 192.168.1.100:2222
```

**Cas d'usage :**

|Scénario|Configuration|Utilité|
|---|---|---|
|Serveur avec une seule interface|`0.0.0.0` (défaut)|Standard|
|Serveur multi-interfaces|IP spécifique|Limiter l'accès SSH à certains réseaux|
|VPN + Internet|IP VPN uniquement|SSH accessible uniquement via VPN|
|IPv6 uniquement|`::`|Environnement IPv6 pur|

> [!example] Exemple : Serveur avec plusieurs interfaces Vous avez un serveur avec :
> 
> - `eth0` : 192.168.1.100 (réseau interne)
> - `eth1` : 203.0.113.50 (Internet)
> 
> Pour n'autoriser SSH que depuis le réseau interne :
> 
> ```bash
> ListenAddress 192.168.1.100
> ```

### Autres paramètres de base importants

```bash
# Famille de protocoles acceptés
AddressFamily any          # any (IPv4+IPv6), inet (IPv4 seul), inet6 (IPv6 seul)

# Nombre maximum de tentatives d'authentification par connexion
MaxAuthTries 3

# Nombre maximum de sessions concurrentes non authentifiées
MaxStartups 10:30:60       # start:rate:full

# Timeout pour l'authentification (en secondes)
LoginGraceTime 60

# Niveau de journalisation
LogLevel INFO              # QUIET, FATAL, ERROR, INFO, VERBOSE, DEBUG
```

> [!tip] MaxStartups expliqué `MaxStartups 10:30:60` signifie :
> 
> - **10** : Accepter jusqu'à 10 connexions non authentifiées
> - **30** : Au-delà de 10, rejeter 30% des nouvelles connexions de manière aléatoire
> - **60** : À partir de 60 connexions, rejeter toutes les nouvelles
> 
> Cela protège contre les attaques par déni de service.

---

## Options d'authentification

### Authentification par mot de passe

```bash
# Autoriser l'authentification par mot de passe
PasswordAuthentication yes

# Désactiver l'authentification par mot de passe (recommandé après configuration des clés)
PasswordAuthentication no
```

> [!warning] Sécurité L'authentification par mot de passe est vulnérable aux attaques par force brute. Il est fortement recommandé de la désactiver au profit de l'authentification par clé publique.

### Authentification par clé publique

```bash
# Autoriser l'authentification par clé publique (recommandé)
PubkeyAuthentication yes

# Fichier contenant les clés autorisées (relatif au home de l'utilisateur)
AuthorizedKeysFile .ssh/authorized_keys

# Fichiers alternatifs ou multiples
AuthorizedKeysFile .ssh/authorized_keys .ssh/authorized_keys2
```

**Emplacement des clés autorisées :**

- Chemin relatif par défaut : `~/.ssh/authorized_keys`
- Chemin absolu possible : `/etc/ssh/authorized_keys/%u` (%u = nom d'utilisateur)

### Authentification root

```bash
# Autoriser la connexion root
PermitRootLogin yes

# Interdire la connexion root (recommandé)
PermitRootLogin no

# Autoriser root uniquement avec clé publique (compromis acceptable)
PermitRootLogin prohibit-password

# Autoriser root uniquement pour des commandes forcées (clés avec forced-command)
PermitRootLogin forced-commands-only
```

|Valeur|Signification|Usage recommandé|
|---|---|---|
|`yes`|Root peut se connecter avec mot de passe ou clé|⚠️ Déconseillé|
|`no`|Root ne peut pas se connecter via SSH|✅ Recommandé|
|`prohibit-password`|Root peut se connecter uniquement avec clé publique|✅ Acceptable|
|`forced-commands-only`|Root avec clés ayant des commandes forcées uniquement|Cas spécifiques|

> [!tip] Bonne pratique Désactivez complètement l'accès root et utilisez `sudo` depuis un compte utilisateur normal.

### Authentification par défi-réponse

```bash
# Authentification interactive (peut inclure 2FA)
ChallengeResponseAuthentication no

# Sur les versions récentes, remplacé par :
KbdInteractiveAuthentication no
```

### Méthodes d'authentification autorisées

```bash
# Définir explicitement les méthodes acceptées (ordre de priorité)
AuthenticationMethods publickey

# Autoriser plusieurs méthodes
AuthenticationMethods publickey,password

# Exiger authentification multi-facteurs (clé PUIS mot de passe)
AuthenticationMethods publickey,keyboard-interactive
```

### Utilisateurs et groupes autorisés

```bash
# Autoriser uniquement certains utilisateurs
AllowUsers alice bob charlie

# Autoriser avec des wildcards et des restrictions d'hôtes
AllowUsers alice@192.168.1.* bob@*.example.com *@10.0.0.0/8

# Autoriser uniquement certains groupes
AllowGroups sshusers admins

# Interdire des utilisateurs spécifiques
DenyUsers guest nobody

# Interdire des groupes
DenyGroups guests
```

> [!info] Ordre de priorité L'ordre d'évaluation est :
> 
> 1. `DenyUsers`
> 2. `AllowUsers`
> 3. `DenyGroups`
> 4. `AllowGroups`
> 
> Si aucune directive n'est spécifiée, tous les utilisateurs sont autorisés (selon les autres règles).

### Bannière de connexion

```bash
# Afficher un message avant l'authentification
Banner /etc/ssh/banner.txt

# Pas de bannière (par défaut)
#Banner none
```

**Exemple de bannière (`/etc/ssh/banner.txt`) :**

```text
******************************************************************
*                                                                *
*  AVERTISSEMENT : Système privé                                *
*  Accès réservé aux utilisateurs autorisés                     *
*  Toute activité peut être surveillée et enregistrée          *
*                                                                *
******************************************************************
```

### Autoriser les mots de passe vides

```bash
# Interdire les mots de passe vides (par défaut et recommandé)
PermitEmptyPasswords no

# Autoriser (⚠️ TRÈS dangereux)
PermitEmptyPasswords yes
```

---

## Options de sécurité

### Limitations de connexion

```bash
# Timeout d'inactivité côté client (en secondes)
ClientAliveInterval 300        # Envoyer un message toutes les 5 minutes

# Nombre de messages sans réponse avant déconnexion
ClientAliveCountMax 2          # Déconnecter après 10 minutes (300s × 2)

# Timeout pour établir la connexion
LoginGraceTime 60              # 1 minute pour s'authentifier

# Nombre maximum de tentatives d'authentification
MaxAuthTries 3

# Nombre maximum de sessions par connexion réseau
MaxSessions 10
```

> [!example] Calcul du timeout d'inactivité Avec `ClientAliveInterval 300` et `ClientAliveCountMax 2` :
> 
> - Le serveur envoie un keepalive toutes les 300 secondes
> - Si pas de réponse après 2 tentatives → déconnexion
> - **Timeout total** = 300s × 2 = **600 secondes (10 minutes)**

### Redirection et tunneling

```bash
# Autoriser le forwarding X11 (affichage graphique distant)
X11Forwarding no               # Recommandé : désactivé (sauf besoin spécifique)

# Autoriser le tunneling TCP (port forwarding)
AllowTcpForwarding no          # Recommandé : désactivé (sauf besoin)

# Variante plus granulaire
AllowTcpForwarding local       # Autorise -L mais pas -R
AllowTcpForwarding remote      # Autorise -R mais pas -L

# Autoriser les tunnels TUN/TAP (VPN)
PermitTunnel no

# Autoriser le forwarding d'agent SSH
AllowAgentForwarding yes       # Permet ssh-agent forwarding
```

|Option|Utilité|Risque si activé|Recommandation|
|---|---|---|---|
|`X11Forwarding`|Applications graphiques à distance|Interception X11|Désactiver sauf besoin|
|`AllowTcpForwarding`|Tunnels SSH (port forwarding)|Contournement firewall|Désactiver par défaut|
|`PermitTunnel`|VPN via SSH|Contournement réseau|Désactiver sauf VPN|
|`AllowAgentForwarding`|Utiliser ses clés locales sur le serveur|Compromission de l'agent|Activer prudemment|

### Algorithmes cryptographiques

```bash
# Algorithmes de chiffrement autorisés (ciphers)
Ciphers aes256-gcm@openssh.com,chacha20-poly1305@openssh.com,aes256-ctr

# Algorithmes d'échange de clés (Key Exchange)
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group-exchange-sha256

# Algorithmes MAC (Message Authentication Code)
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com

# Algorithmes de clés d'hôte
HostKeyAlgorithms ssh-ed25519,rsa-sha2-512,rsa-sha2-256
```

> [!warning] Algorithmes obsolètes Évitez ces algorithmes faibles :
> 
> - Ciphers : `3des-cbc`, `aes128-cbc`, `arcfour`
> - KexAlgorithms : `diffie-hellman-group1-sha1`
> - MACs : `hmac-md5`, `hmac-sha1`
> - HostKeyAlgorithms : `ssh-dss`, `ssh-rsa` (sans SHA2)

> [!tip] Configuration moderne recommandée
> 
> ```bash
> # Ciphers modernes et performants
> Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com
> 
> # Échange de clés sécurisé
> KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group16-sha512
> 
> # MACs avec Encrypt-then-MAC
> MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com
> 
> # Clés d'hôte modernes
> HostKeyAlgorithms ssh-ed25519,rsa-sha2-512,rsa-sha2-256
> ```

### Clés d'hôte

```bash
# Fichiers contenant les clés privées du serveur
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
HostKey /etc/ssh/ssh_host_ed25519_key
```

> [!info] Types de clés d'hôte
> 
> - **RSA** : Classique, compatible partout (mais plus lent)
> - **ECDSA** : Plus rapide que RSA (mais controversé)
> - **Ed25519** : Moderne, rapide, sécurisé (recommandé)

### Strictness et permissions

```bash
# Vérifier strictement les permissions des fichiers
StrictModes yes

# Vérifier les permissions de .ssh et authorized_keys
# Si désactivé, accepte des permissions laxistes (⚠️ dangereux)
```

Avec `StrictModes yes` (recommandé), SSH vérifie que :

- Le répertoire home de l'utilisateur n'est pas accessible en écriture par les autres
- Le répertoire `~/.ssh` a les permissions `700` (rwx------)
- Le fichier `~/.ssh/authorized_keys` a les permissions `600` (rw-------)

### Compression

```bash
# Désactiver la compression (recommandé pour sécurité)
Compression no

# Activer après authentification (compromis)
Compression delayed

# Activer immédiatement (peut aider pour connexions lentes)
Compression yes
```

> [!warning] Vulnérabilité de compression La compression peut exposer à des attaques de type "CRIME" ou timing attacks. Préférez `no` ou `delayed`.

### Environnement utilisateur

```bash
# Autoriser le client à passer des variables d'environnement
PermitUserEnvironment no       # Recommandé : désactivé (risque de sécurité)

# Variables d'environnement acceptées (si PermitUserEnvironment yes)
AcceptEnv LANG LC_*           # Accepter les locales
```

### Subsystème SFTP

```bash
# Configuration du subsystème SFTP pour transferts de fichiers
Subsystem sftp /usr/lib/openssh/sftp-server

# Avec logging
Subsystem sftp /usr/lib/openssh/sftp-server -f AUTHPRIV -l INFO

# Chroot pour isoler les utilisateurs SFTP (configuration avancée)
# Match Group sftponly
#     ChrootDirectory /home/%u
#     ForceCommand internal-sftp
#     AllowTcpForwarding no
#     X11Forwarding no
```

### Configuration conditionnelle (Match)

Les directives `Match` permettent d'appliquer des règles spécifiques selon des critères.

```bash
# Exemple 1 : Règles spécifiques pour un utilisateur
Match User backupuser
    PasswordAuthentication no
    PubkeyAuthentication yes
    AllowTcpForwarding no
    X11Forwarding no
    ForceCommand /usr/local/bin/backup.sh

# Exemple 2 : Règles pour un groupe
Match Group developers
    AllowTcpForwarding yes
    PermitTunnel no

# Exemple 3 : Règles selon l'adresse source
Match Address 10.0.0.0/8
    PasswordAuthentication yes
    PermitRootLogin yes

# Exemple 4 : Règles selon l'adresse source (LAN uniquement)
Match Address 192.168.1.0/24
    PasswordAuthentication yes
Match Address !192.168.1.0/24
    PasswordAuthentication no
    
# IMPORTANT : Toutes les directives après un Match s'appliquent uniquement au Match
# Pour revenir aux règles globales, il faut soit :
# - Placer les Match à la fin du fichier (recommandé)
# - Utiliser "Match all" pour revenir au contexte global
```

> [!tip] Ordre des directives Match
> 
> - Les `Match` sont évalués dans l'ordre d'apparition
> - Placez les règles `Match` **à la fin** de `sshd_config`
> - Les directives après un `Match` ne s'appliquent qu'à ce contexte
> - Utilisez `Match all` pour revenir au contexte global si nécessaire

### Autres options de sécurité

```bash
# Afficher le message du jour après connexion réussie
PrintMotd yes

# Afficher la dernière connexion
PrintLastLog yes

# Utiliser DNS inverse pour vérifier l'hôte du client
UseDNS no                      # Recommandé : désactivé (accélère les connexions)

# Autoriser les connexions TCP keepalive
TCPKeepAlive yes

# Utiliser PAM (Pluggable Authentication Modules)
UsePAM yes

# Utiliser la séparation de privilèges
UsePrivilegeSeparation sandbox  # Ou 'yes' sur anciennes versions
```

---

## Validation de la configuration

### Tester la syntaxe du fichier

Avant de redémarrer le service SSH, il est **crucial** de valider la configuration pour éviter de se bloquer l'accès au serveur.

```bash
# Tester la configuration (sans redémarrer)
sudo sshd -t

# Test avec affichage de la configuration étendue
sudo sshd -T

# Test avec affichage pour un utilisateur spécifique
sudo sshd -T -C user=alice,host=192.168.1.100,addr=192.168.1.100
```

**Sortie attendue si la configuration est valide :**

```
(Aucun message = configuration OK)
```

**Exemple d'erreur :**

```
/etc/ssh/sshd_config line 42: Bad configuration option: InvalidOption
/etc/ssh/sshd_config: terminating, 1 bad configuration options
```

> [!warning] Ne jamais sauter cette étape Toujours exécuter `sudo sshd -t` avant de redémarrer le service SSH. Une erreur de configuration peut vous couper complètement l'accès SSH au serveur !

### Afficher la configuration effective

```bash
# Afficher tous les paramètres (ceux définis + les valeurs par défaut)
sudo sshd -T

# Afficher la config pour un contexte spécifique (avec Match)
sudo sshd -T -C user=bob,host=server.example.com,addr=192.168.1.50

# Filtrer un paramètre spécifique
sudo sshd -T | grep -i "^port"
sudo sshd -T | grep -i "^permitrootlogin"
```

### Redémarrer le service SSH

Une fois la configuration validée, appliquez les changements :

```bash
# Méthode 1 : Rechargement de la configuration (préféré, sans couper les connexions)
sudo systemctl reload sshd

# Méthode 2 : Redémarrage complet du service
sudo systemctl restart sshd

# Vérifier le statut du service
sudo systemctl status sshd

# Vérifier les erreurs dans les logs
sudo journalctl -u sshd -n 50
sudo tail -f /var/log/auth.log     # Debian/Ubuntu
sudo tail -f /var/log/secure       # RHEL/CentOS
```

> [!tip] Reload vs Restart
> 
> - **`reload`** : Recharge la configuration sans couper les connexions actives (recommandé)
> - **`restart`** : Redémarre complètement le service (coupe les connexions)

### Stratégie de test sécurisée

> [!warning] Protocole de sécurité avant modifications **Avant de modifier la configuration SSH sur un serveur distant :**
> 
> 1. **Gardez une session SSH ouverte** pendant les tests
> 2. **Testez dans une nouvelle session** (nouvel onglet/fenêtre)
> 3. **Ne fermez la session initiale** qu'après validation complète
> 4. **Ayez un accès alternatif** (console, IPMI, accès physique)
> 
> **Procédure recommandée :**
> 
> ```bash
> # Session 1 (gardez-la ouverte)
> ssh user@server
> 
> # Modifier la configuration
> sudo nano /etc/ssh/sshd_config
> sudo sshd -t
> sudo systemctl reload sshd
> 
> # Session 2 (nouveau terminal)
> ssh user@server  # Tester avec la nouvelle config
> 
> # Si Session 2 fonctionne → fermer Session 1
> # Si Session 2 échoue → corriger depuis Session 1
> ```

### Logs et débogage

```bash
# Voir les logs SSH en temps réel
sudo journalctl -u sshd -f

# Voir les dernières tentatives de connexion
sudo journalctl -u sshd -n 100

# Filtrer les échecs d'authentification
sudo journalctl -u sshd | grep "Failed"
sudo journalctl -u sshd | grep "Accepted"

# Logs système traditionnels
sudo tail -f /var/log/auth.log     # Debian/Ubuntu
sudo tail -f /var/log/secure       # RHEL/CentOS/Rocky
```

### Mode débogage du serveur

Pour diagnostiquer des problèmes complexes, vous pouvez lancer sshd en mode débogage :

```bash
# Lancer sshd en mode debug sur un port différent (pas en production !)
sudo /usr/sbin/sshd -d -p 2222

# Mode très verbeux
sudo /usr/sbin/sshd -ddd -p 2222
```

> [!warning] Mode debug Le mode debug :
> 
> - Affiche des informations sensibles (clés, authentification)
> - Accepte **une seule connexion** puis s'arrête
> - Ne doit être utilisé que pour le débogage, jamais en production

### Checklist de validation

Après avoir modifié `sshd_config`, vérifiez systématiquement :

- [ ] `sudo sshd -t` → Aucune erreur
- [ ] `sudo sshd -T` → Vérifier les paramètres critiques
- [ ] `sudo systemctl reload sshd` → Service rechargé
- [ ] `sudo systemctl status sshd` → Service actif
- [ ] Nouvelle session SSH → Connexion réussie
- [ ] `sudo journalctl -u sshd -n 20` → Pas d'erreurs dans les logs
- [ ] Tester l'authentification (mot de passe ET/OU clé selon config)
- [ ] Tester depuis l'IP/réseau attendu (si restrictions)

---

## 🎯 Résumé des bonnes pratiques

> [!tip] Configuration SSH sécurisée - Points clés
> 
> **Authentification :**
> 
> - ✅ Désactiver `PasswordAuthentication` (utiliser clés publiques)
> - ✅ Désactiver `PermitRootLogin` ou le limiter à `prohibit-password`
> - ✅ Limiter avec `AllowUsers` ou `AllowGroups`
> - ✅ Réduire `MaxAuthTries` à 3
> 
> **Réseau :**
> 
> - ✅ Changer le `Port` (optionnel mais recommandé)
> - ✅ Limiter `ListenAddress` si plusieurs interfaces
> - ✅ Configurer `ClientAliveInterval` et `ClientAliveCountMax`
> 
> **Sécurité avancée :**
> 
> - ✅ Désactiver `X11Forwarding`, `AllowTcpForwarding` (sauf besoin)
> - ✅ Utiliser des algorithmes cryptographiques modernes
> - ✅ Activer `StrictModes`
> - ✅ Désactiver `PermitUserEnvironment`
> 
> **Validation :**
> 
> - ✅ **Toujours** exécuter `sudo sshd -t` avant de redémarrer
> - ✅ Garder une session SSH active lors des tests
> - ✅ Tester depuis une nouvelle session
> - ✅ Surveiller les logs

---

## 🔍 Pièges courants

> [!warning] Erreurs fréquentes à éviter
> 
> **1. Se bloquer l'accès SSH**
> 
> - Ne jamais fermer toutes les sessions SSH avant de valider une nouvelle configuration
> - Toujours tester `sudo sshd -t` avant `systemctl reload`
> 
> **2. Ordre des directives**
> 
> - Les directives `Match` doivent être **à la fin** du fichier
> - Les paramètres après un `Match` ne s'appliquent qu'au contexte de ce `Match`
> 
> **3. Permissions des fichiers**
> 
> - `~/.ssh/authorized_keys` doit être en `600` (rw-------)
> - `~/.ssh/` doit être en `700` (rwx------)
> - `sshd_config` doit être en `600` et appartenir à root
> 
> **4. Pare-feu oublié**
> 
> - Après changement de port, ouvrir le nouveau port dans le firewall
> - Sur RHEL/Rocky : `sudo firewall-cmd --add-port=2222/tcp --permanent`
> - Sur Ubuntu/Debian : `sudo ufw allow 2222/tcp`
> 
> **5. SELinux**
> 
> - Sur RHEL/Rocky, ajouter le nouveau port à SELinux :
>     
>     ```bash
>     sudo semanage port -a -t ssh_port_t -p tcp 2222
>     ```
>     
> 
> **6. Syntaxe des valeurs**
> 
> - `yes`/`no` et non `true`/`false`
> - Respecter la casse : `PasswordAuthentication` et non `passwordauthentication`

---

## 📊 Exemple de configuration sécurisée complète

```bash
# /etc/ssh/sshd_config - Configuration SSH sécurisée

# ================== RÉSEAU ==================
Port 22
AddressFamily any
ListenAddress 0.0.0.0

# ================== AUTHENTIFICATION ==================
# Désactiver l'authentification par mot de passe
PasswordAuthentication no
PermitEmptyPasswords no

# Activer uniquement l'authentification par clé publique
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys

# Interdire la connexion root directe
PermitRootLogin no

# Limiter les utilisateurs autorisés
AllowGroups sshusers admins

# Limiter les tentatives d'authentification
MaxAuthTries 3
LoginGraceTime 60

# ================== SÉCURITÉ ==================
# Algorithmes cryptographiques modernes
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group16-sha512
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com
HostKeyAlgorithms ssh-ed25519,rsa-sha2-512,rsa-sha2-256

# Clés d'hôte
HostKey /etc/ssh/ssh_host_ed25519_key
HostKey /etc/ssh/ssh_host_rsa_key

# Vérifications strictes
StrictModes yes
PermitUserEnvironment no

# ================== TUNNELING ET FORWARDING ==================
# Désactiver les fonctionnalités non nécessaires
X11Forwarding no
AllowTcpForwarding no
AllowAgentForwarding yes
PermitTunnel no

# ================== TIMEOUTS ET KEEPALIVE ==================
# Déconnecter les sessions inactives
ClientAliveInterval 300
ClientAliveCountMax 2

# Nombre de connexions simultanées
MaxSessions 10
MaxStartups 10:30:60

# ================== LOGGING ==================
# Journalisation détaillée
LogLevel VERBOSE
SyslogFacility AUTH

# ================== DIVERS ==================
# Subsystème SFTP
Subsystem sftp /usr/lib/openssh/sftp-server -f AUTHPRIV -l INFO

# Options système
UsePAM yes
UseDNS no
TCPKeepAlive yes
Compression no

# Bannière de connexion
Banner /etc/ssh/banner.txt

# Afficher les informations de connexion
PrintMotd yes
PrintLastLog yes

# ================== CONFIGURATIONS CONDITIONNELLES ==================
# Exemple : Accès restreint pour un utilisateur de backup
Match User backupuser
    PasswordAuthentication no
    AllowTcpForwarding no
    X11Forwarding no
    ForceCommand /usr/local/bin/backup.sh

# Exemple : Autoriser mot de passe depuis le réseau local uniquement
Match Address 192.168.1.0/24
    PasswordAuthentication yes

# Fin des directives Match (retour au contexte global si nécessaire)
```

> [!example] Notes sur cette configuration Cette configuration privilégie la **sécurité maximale** :
> 
> - Authentification par clé uniquement
> - Pas d'accès root
> - Algorithmes cryptographiques modernes
> - Forwarding désactivé
> - Timeouts pour sessions inactives
> - Logging verbeux pour l'audit
> 
> **Adaptez selon vos besoins :** Si vous avez besoin de port forwarding, X11, ou d'autres fonctionnalités, activez-les de manière ciblée avec des directives `Match`.

---

## 📝 Tableau récapitulatif des paramètres principaux

|Paramètre|Valeur recommandée|Valeur par défaut|Impact|
|---|---|---|---|
|`Port`|22 ou personnalisé|22|Accès au serveur|
|`PasswordAuthentication`|no|yes|Sécurité authentification|
|`PubkeyAuthentication`|yes|yes|Authentification par clé|
|`PermitRootLogin`|no|yes|Accès root|
|`MaxAuthTries`|3|6|Protection brute-force|
|`LoginGraceTime`|60|120|Temps d'authentification|
|`X11Forwarding`|no|no|Affichage graphique|
|`AllowTcpForwarding`|no|yes|Tunnels SSH|
|`ClientAliveInterval`|300|0|Keepalive|
|`ClientAliveCountMax`|2|3|Timeout inactivité|
|`LogLevel`|VERBOSE|INFO|Détail des logs|
|`StrictModes`|yes|yes|Vérification permissions|
|`UseDNS`|no|no (récent)|Vitesse de connexion|
|`Compression`|no|no (récent)|Sécurité vs performance|

---

## 🛠️ Commandes de référence rapide

```bash
# === VALIDATION ===
# Tester la syntaxe
sudo sshd -t

# Afficher la configuration complète
sudo sshd -T

# Afficher config pour un contexte spécifique
sudo sshd -T -C user=alice,host=example.com,addr=192.168.1.100

# === SERVICE ===
# Recharger la configuration (sans couper les connexions)
sudo systemctl reload sshd

# Redémarrer le service
sudo systemctl restart sshd

# Vérifier le statut
sudo systemctl status sshd

# === LOGS ===
# Logs en temps réel
sudo journalctl -u sshd -f

# Derniers événements
sudo journalctl -u sshd -n 50

# Filtrer les erreurs
sudo journalctl -u sshd | grep -i "error\|failed"

# Logs système
sudo tail -f /var/log/auth.log      # Debian/Ubuntu
sudo tail -f /var/log/secure        # RHEL/Rocky/CentOS

# === ÉDITION ===
# Éditer la configuration principale
sudo nano /etc/ssh/sshd_config

# Créer une configuration modulaire
sudo nano /etc/ssh/sshd_config.d/custom.conf

# === PERMISSIONS ===
# Corriger les permissions du fichier de configuration
sudo chown root:root /etc/ssh/sshd_config
sudo chmod 600 /etc/ssh/sshd_config

# Corriger les permissions utilisateur
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys

# === PARE-FEU ===
# Ubuntu/Debian
sudo ufw allow 2222/tcp
sudo ufw reload

# RHEL/Rocky/CentOS
sudo firewall-cmd --add-port=2222/tcp --permanent
sudo firewall-cmd --reload

# === SELinux (RHEL/Rocky/CentOS) ===
# Ajouter un port personnalisé
sudo semanage port -a -t ssh_port_t -p tcp 2222

# Lister les ports SSH autorisés
sudo semanage port -l | grep ssh

# === DEBUG ===
# Lancer sshd en mode debug (une connexion uniquement)
sudo /usr/sbin/sshd -d -p 2222

# Mode très verbeux
sudo /usr/sbin/sshd -ddd -p 2222
```

---

## 🔐 Scénarios de configuration avancés

### Scénario 1 : Serveur avec accès interne et externe

```bash
# Accès depuis Internet : clés uniquement, port non-standard
Match Address !192.168.0.0/16,!10.0.0.0/8
    Port 2222
    PasswordAuthentication no
    PermitRootLogin no
    AllowTcpForwarding no

# Accès depuis réseau local : plus souple
Match Address 192.168.0.0/16,10.0.0.0/8
    PasswordAuthentication yes
    PermitRootLogin prohibit-password
    AllowTcpForwarding yes
```

### Scénario 2 : Serveur SFTP avec chroot

```bash
# Créer un groupe pour les utilisateurs SFTP uniquement
Match Group sftponly
    # Isoler dans leur répertoire home
    ChrootDirectory /home/%u
    
    # Forcer l'utilisation du serveur SFTP interne
    ForceCommand internal-sftp
    
    # Désactiver tout le reste
    AllowTcpForwarding no
    X11Forwarding no
    PermitTunnel no
```

> [!info] Configuration du système pour SFTP chroot Pour que le chroot fonctionne :
> 
> ```bash
> # Le répertoire home doit appartenir à root
> sudo chown root:root /home/sftpuser
> sudo chmod 755 /home/sftpuser
> 
> # Créer un sous-répertoire pour les fichiers de l'utilisateur
> sudo mkdir /home/sftpuser/uploads
> sudo chown sftpuser:sftpuser /home/sftpuser/uploads
> sudo chmod 755 /home/sftpuser/uploads
> ```

### Scénario 3 : Accès multi-facteurs (MFA)

```bash
# Exiger clé publique ET mot de passe/2FA
AuthenticationMethods publickey,keyboard-interactive

# Activer PAM pour la partie interactive (2FA)
UsePAM yes
ChallengeResponseAuthentication yes
KbdInteractiveAuthentication yes

# Pour un utilisateur spécifique uniquement
Match User admin
    AuthenticationMethods publickey,keyboard-interactive
```

> [!tip] Configuration de Google Authenticator Pour activer 2FA avec Google Authenticator :
> 
> ```bash
> # Installer le module PAM
> sudo apt install libpam-google-authenticator  # Debian/Ubuntu
> sudo yum install google-authenticator          # RHEL/Rocky
> 
> # Configurer pour chaque utilisateur
> google-authenticator
> 
> # Éditer /etc/pam.d/sshd
> # Ajouter : auth required pam_google_authenticator.so
> ```

### Scénario 4 : Jump host (bastion)

```bash
# Configuration pour un serveur bastion
# Autoriser le forwarding d'agent pour chaîner les connexions
AllowAgentForwarding yes

# Autoriser le forwarding TCP pour atteindre d'autres serveurs
AllowTcpForwarding yes

# Mais limiter les utilisateurs autorisés
AllowGroups bastion-users

# Pas de tunnels complets
PermitTunnel no

# Logging très verbeux pour l'audit
LogLevel VERBOSE

# Forcer une bannière d'avertissement
Banner /etc/ssh/bastion-warning.txt
```

### Scénario 5 : Environnement hautement sécurisé

```bash
# Authentification la plus stricte
PasswordAuthentication no
PubkeyAuthentication yes
PermitRootLogin no
AuthenticationMethods publickey

# Utilisateurs explicitement autorisés
AllowUsers alice@10.0.0.* bob@192.168.1.100

# Limites très strictes
MaxAuthTries 2
LoginGraceTime 30
MaxSessions 2
MaxStartups 5:30:10

# Désactiver toutes les fonctionnalités avancées
X11Forwarding no
AllowTcpForwarding no
AllowAgentForwarding no
PermitTunnel no
GatewayPorts no

# Déconnexion rapide des sessions inactives
ClientAliveInterval 180
ClientAliveCountMax 1

# Algorithmes uniquement les plus forts
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com
KexAlgorithms curve25519-sha256
MACs hmac-sha2-512-etm@openssh.com
HostKeyAlgorithms ssh-ed25519

# Logging maximal
LogLevel VERBOSE

# Pas de compression
Compression no
```

---

## 🎓 Astuces professionnelles

> [!tip] Gestion de configuration avec Ansible Pour gérer `sshd_config` sur plusieurs serveurs :
> 
> ```yaml
> - name: Configure SSH server
>   lineinfile:
>     path: /etc/ssh/sshd_config
>     regexp: '^#?PasswordAuthentication'
>     line: 'PasswordAuthentication no'
>     validate: '/usr/sbin/sshd -t -f %s'
>   notify: reload sshd
> ```
> 
> Le paramètre `validate` garantit que le fichier est valide avant de l'appliquer !

> [!tip] Backup automatique avant modification
> 
> ```bash
> # Créer un script de modification sécurisé
> sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.backup.$(date +%Y%m%d-%H%M%S)
> sudo nano /etc/ssh/sshd_config
> sudo sshd -t && sudo systemctl reload sshd || sudo cp /etc/ssh/sshd_config.backup.* /etc/ssh/sshd_config
> ```

> [!tip] Surveillance des modifications
> 
> ```bash
> # Installer aide (Advanced Intrusion Detection Environment)
> sudo apt install aide
> 
> # Surveiller les modifications de sshd_config
> sudo aide --init
> sudo aide --check
> ```

> [!tip] Tester depuis l'extérieur
> 
> ```bash
> # Vérifier les algorithmes acceptés par votre serveur
> nmap --script ssh2-enum-algos -p 22 votre-serveur.com
> 
> # Scanner les vulnérabilités SSH
> nmap --script ssh-auth-methods -p 22 votre-serveur.com
> ```

> [!tip] Rotation des clés d'hôte
> 
> ```bash
> # Générer de nouvelles clés d'hôte
> sudo ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""
> sudo ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -N ""
> 
> # Redémarrer SSH
> sudo systemctl restart sshd
> 
> # Les clients devront mettre à jour leur known_hosts
> ```

---

## 🎯 Points clés à retenir

1. **Toujours tester avant de redémarrer** : `sudo sshd -t` est votre meilleur ami
2. **Garder une session ouverte** lors des modifications sur un serveur distant
3. **Privilégier les clés publiques** aux mots de passe
4. **Désactiver root** ou le limiter à `prohibit-password`
5. **Placer les directives Match à la fin** du fichier
6. **Utiliser des algorithmes modernes** (Ed25519, Chacha20-Poly1305)
7. **Configurer les timeouts** pour les sessions inactives
8. **Logger de manière appropriée** pour l'audit de sécurité
9. **Limiter les fonctionnalités** aux besoins réels (forwarding, tunnels)
10. **Documenter vos changements** avec des commentaires dans le fichier

---

_Ce cours couvre la configuration complète du serveur SSH. Pour aller plus loin, explorez les mécanismes d'authentification avancés (certificats SSH, GSSAPI/Kerberos) et les outils de surveillance (fail2ban, ossec)._