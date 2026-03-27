

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

## 🎯 Introduction au 2FA

### Qu'est-ce que l'authentification multifacteur ?

L'authentification multifacteur (2FA) ajoute une couche de sécurité supplémentaire en combinant **deux facteurs distincts** :

- **Quelque chose que vous avez** : clé SSH, token physique
- **Quelque chose que vous connaissez** : mot de passe, code PIN
- **Quelque chose que vous êtes** : empreinte digitale, reconnaissance faciale

Pour SSH, on combine généralement :

- Une **clé SSH** (ce que vous avez)
- Un **code OTP** (One-Time Password) généré par une application mobile (ce que vous connaissez)

> [!info] Pourquoi activer le 2FA sur SSH ?
> 
> - Protection contre le vol de clés SSH
> - Conformité aux normes de sécurité (PCI-DSS, ISO 27001)
> - Prévention des accès non autorisés même avec une clé compromise
> - Traçabilité renforcée des connexions

### Principes de fonctionnement

Le système 2FA pour SSH utilise **TOTP** (Time-based One-Time Password) :

1. Un secret partagé est généré et stocké sur le serveur
2. L'utilisateur scanne un QR code avec son application mobile (Google Authenticator, Authy, etc.)
3. L'application génère un code à 6 chiffres qui change toutes les 30 secondes
4. Lors de la connexion, l'utilisateur doit fournir ce code en plus de sa clé SSH

---

## 📦 Installation de Google Authenticator PAM

### Qu'est-ce que PAM ?

**PAM** (Pluggable Authentication Modules) est le système d'authentification modulaire de Linux. Il permet d'ajouter différentes méthodes d'authentification sans modifier les applications.

> [!tip] PAM vs SSH natif PAM s'intègre avec SSH pour gérer l'authentification. C'est lui qui va vérifier le code 2FA avant d'autoriser la connexion.

### Installation du module

#### Sur Debian/Ubuntu

```bash
# Mise à jour des paquets
sudo apt update

# Installation du module PAM pour Google Authenticator
sudo apt install libpam-google-authenticator -y

# Vérification de l'installation
dpkg -l | grep libpam-google-authenticator
```

#### Sur Red Hat/CentOS/Rocky/Alma

```bash
# Installation depuis EPEL (Extra Packages for Enterprise Linux)
sudo yum install epel-release -y
sudo yum install google-authenticator -y

# Ou avec dnf
sudo dnf install google-authenticator -y
```

#### Sur Arch Linux

```bash
# Installation depuis les dépôts officiels
sudo pacman -S libpam-google-authenticator
```

> [!warning] Prérequis système
> 
> - Temps système synchronisé (NTP configuré)
> - Accès root ou sudo pour la configuration
> - Application mobile compatible TOTP installée

### Vérification de l'installation

```bash
# Vérifier que le module PAM est présent
ls -l /lib/*/security/pam_google_authenticator.so

# Vérifier la commande de configuration utilisateur
which google-authenticator
```

---

## ⚙️ Configuration PAM pour SSH

### Configuration initiale pour un utilisateur

Chaque utilisateur doit générer son propre secret 2FA :

```bash
# En tant qu'utilisateur (pas root)
google-authenticator
```

#### Questions interactives et recommandations

|Question|Réponse recommandée|Explication|
|---|---|---|
|**Do you want authentication tokens to be time-based?**|`y`|Utilise TOTP (codes changeant toutes les 30s)|
|**Do you want me to update your ~/.google_authenticator file?**|`y`|Sauvegarde la configuration|
|**Do you want to disallow multiple uses of the same token?**|`y`|Empêche la réutilisation d'un code|
|**By default, tokens are good for 30 seconds. Increase window?**|`n`|Garde la fenêtre de 30s standard|
|**Do you want to enable rate-limiting?**|`y`|Limite à 3 tentatives par 30s|

> [!example] Sortie typique de la commande
> 
> ```
> Your new secret key is: JBSWY3DPEHPK3PXP
> Your verification code is 123456
> Your emergency scratch codes are:
>   12345678
>   87654321
>   11223344
>   44332211
>   55667788
> ```

#### Comprendre les fichiers générés

```bash
# Fichier de configuration généré (par utilisateur)
cat ~/.google_authenticator
```

Contenu du fichier :

```
JBSWY3DPEHPK3PXP          # Secret partagé (encodé en base32)
" RATE_LIMIT 3 30         # Limite de taux (3 tentatives/30s)
" WINDOW_SIZE 17          # Fenêtre de tolérance temporelle
" DISALLOW_REUSE          # Empêche réutilisation des codes
" TOTP_AUTH               # Type d'authentification
12345678                  # Codes d'urgence (scratch codes)
87654321
```

> [!warning] Sécurité du fichier de configuration
> 
> ```bash
> # Permissions correctes (automatiquement appliquées)
> ls -la ~/.google_authenticator
> # Doit afficher : -r-------- 1 user user
> 
> # Si les permissions sont incorrectes, corriger :
> chmod 400 ~/.google_authenticator
> ```

### Configuration du module PAM

Éditer le fichier de configuration PAM pour SSH :

```bash
sudo nano /etc/pam.d/sshd
```

#### Configuration basique (2FA obligatoire)

```bash
# Ajouter cette ligne au DÉBUT du fichier
auth required pam_google_authenticator.so

# Commentaire explicatif
# auth       : type de module (authentification)
# required   : le module DOIT réussir pour autoriser l'accès
# pam_google_authenticator.so : module à utiliser
```

#### Configuration avancée avec options

```bash
# 2FA avec codes d'urgence et tolérance temporelle
auth required pam_google_authenticator.so nullok secret=${HOME}/.ssh/.google_authenticator

# Options détaillées :
# nullok            : Permet la connexion sans 2FA si pas configuré (transition douce)
# secret=PATH       : Chemin personnalisé pour le fichier de configuration
# forward_pass      : Transmet le mot de passe au module suivant
# noskewadj         : Désactive l'ajustement automatique du décalage temporel
# no_increment_hotp : Pour HOTP au lieu de TOTP (non recommandé)
# echo_verification_code : Affiche le code saisi (debug uniquement)
```

> [!tip] Option `nullok` pour migration progressive L'option `nullok` permet aux utilisateurs sans 2FA configuré de se connecter normalement. Utile pour :
> 
> - Migration progressive d'un grand nombre d'utilisateurs
> - Tests en environnement de production
> - Éviter de bloquer les utilisateurs pendant le déploiement

#### Organisation du fichier PAM

```bash
# /etc/pam.d/sshd - Structure complète

# ========================================
# AUTHENTIFICATION 2FA (en premier)
# ========================================
auth required pam_google_authenticator.so nullok

# ========================================
# AUTHENTIFICATION STANDARD
# ========================================
# @include common-auth  # (commenté car on gère manuellement)

# Interdire root
auth required pam_deny.so
account required pam_deny.so

# Authentification Unix standard
auth required pam_unix.so

# ========================================
# GESTION DES COMPTES
# ========================================
account required pam_nologin.so
account include password-auth

# ========================================
# GESTION DES MOTS DE PASSE
# ========================================
password include password-auth

# ========================================
# GESTION DES SESSIONS
# ========================================
session required pam_loginuid.so
session required pam_selinux.so close
session required pam_selinux.so open env_params
session optional pam_keyinit.so force revoke
session include password-auth
```

> [!warning] Ordre d'exécution PAM L'ordre des lignes dans `/etc/pam.d/sshd` est **CRITIQUE** :
> 
> - Les modules `auth` sont exécutés dans l'ordre
> - Placer `pam_google_authenticator.so` en PREMIER pour demander le code 2FA avant tout
> - Si placé après `common-auth`, le mot de passe sera demandé avant le code 2FA

### Codes d'urgence (Scratch Codes)

Les codes d'urgence sont générés lors de l'initialisation et permettent l'accès si vous n'avez plus accès à votre application mobile.

```bash
# Voir vos codes d'urgence existants
grep -v '^"' ~/.google_authenticator | grep '^[0-9]'

# Régénérer complètement la configuration (avec nouveaux codes)
google-authenticator -t -d -f -r 3 -R 30 -w 3

# Options expliquées :
# -t  : Time-based (TOTP)
# -d  : Disallow token reuse
# -f  : Force (pas de questions interactives)
# -r 3 : Rate limit à 3 tentatives
# -R 30 : Sur 30 secondes
# -w 3 : Window size à 3 (±1 minute de tolérance)
```

> [!tip] Conservation des codes d'urgence
> 
> - Imprimez vos codes d'urgence et conservez-les en lieu sûr
> - Chaque code ne peut être utilisé qu'une seule fois
> - Générez de nouveaux codes après les avoir tous utilisés

---

## 🔧 Configuration sshd pour 2FA

### Activer ChallengeResponseAuthentication

Le serveur SSH doit être configuré pour accepter l'authentification par défi-réponse (challenge-response), qui permet à PAM d'interagir avec l'utilisateur.

```bash
# Éditer la configuration SSH
sudo nano /etc/ssh/sshd_config
```

#### Configuration minimale pour 2FA

```bash
# Activer l'authentification par défi-réponse (OBLIGATOIRE pour 2FA)
ChallengeResponseAuthentication yes

# Alternative sur les versions récentes de OpenSSH (>= 7.4)
KbdInteractiveAuthentication yes

# Activer PAM
UsePAM yes

# Désactiver l'authentification par mot de passe classique (optionnel)
PasswordAuthentication no
```

> [!info] ChallengeResponseAuthentication vs KbdInteractiveAuthentication
> 
> - `ChallengeResponseAuthentication` : ancien nom (déprécié depuis OpenSSH 7.4)
> - `KbdInteractiveAuthentication` : nouveau nom (équivalent)
> - Pour compatibilité, vous pouvez définir les deux

#### Configuration complète sécurisée

```bash
# /etc/ssh/sshd_config - Configuration complète

# ========================================
# PARAMÈTRES D'AUTHENTIFICATION
# ========================================

# Port SSH (modifier le port par défaut recommandé)
Port 22

# Protocole SSH version 2 uniquement
Protocol 2

# Activer l'authentification interactive (2FA)
KbdInteractiveAuthentication yes
ChallengeResponseAuthentication yes

# Activer PAM
UsePAM yes

# Désactiver l'authentification par mot de passe simple
PasswordAuthentication no

# Activer l'authentification par clé publique
PubkeyAuthentication yes

# Fichier des clés autorisées
AuthorizedKeysFile .ssh/authorized_keys

# Désactiver l'authentification par clé d'hôte
HostbasedAuthentication no

# Interdire l'authentification root par mot de passe
PermitRootLogin prohibit-password

# Interdire les comptes sans mot de passe
PermitEmptyPasswords no

# ========================================
# MÉTHODES D'AUTHENTIFICATION
# ========================================

# Ordre des méthodes d'authentification
# publickey : clé SSH d'abord
# keyboard-interactive : puis 2FA via PAM
AuthenticationMethods publickey,keyboard-interactive

# Nombre maximum de tentatives d'authentification
MaxAuthTries 3

# Timeout d'authentification
LoginGraceTime 60

# ========================================
# SÉCURITÉ ADDITIONNELLE
# ========================================

# Désactiver X11 forwarding (si non nécessaire)
X11Forwarding no

# Désactiver le forwarding de port (si non nécessaire)
AllowTcpForwarding no

# Désactiver le tunnel
PermitTunnel no

# Afficher la bannière avant connexion
Banner /etc/ssh/banner

# Niveau de log
LogLevel VERBOSE

# ========================================
# RESTRICTIONS D'ACCÈS
# ========================================

# Autoriser uniquement certains utilisateurs
AllowUsers user1 user2 admin

# Ou autoriser uniquement certains groupes
AllowGroups sshusers admins

# Ou interdire certains utilisateurs
DenyUsers baduser guest
```

### Validation de la configuration

```bash
# Tester la syntaxe de la configuration
sudo sshd -t

# Si aucune erreur, relancer SSH
sudo systemctl restart sshd

# Vérifier le statut
sudo systemctl status sshd

# Surveiller les logs en temps réel (dans un autre terminal)
sudo tail -f /var/log/auth.log    # Debian/Ubuntu
sudo tail -f /var/log/secure       # Red Hat/CentOS
```

> [!warning] Ne jamais fermer toutes les sessions SSH Avant de relancer `sshd` :
> 
> 1. Gardez une session SSH ouverte en backup
> 2. Testez la nouvelle configuration dans une NOUVELLE session
> 3. Ne fermez la session backup que si la nouvelle fonctionne
> 4. Sinon, vous risquez d'être bloqué hors du serveur

### Débogage des problèmes de connexion

#### Mode debug côté serveur

```bash
# Arrêter le service SSH
sudo systemctl stop sshd

# Lancer sshd en mode debug (en tant que daemon temporaire)
sudo /usr/sbin/sshd -d -p 2222

# Connexion depuis un autre terminal sur le port 2222
ssh -p 2222 user@serveur

# Analyse de la sortie debug pour identifier les problèmes
```

#### Mode debug côté client

```bash
# Connexion avec verbosité maximale
ssh -vvv user@serveur

# Analyse des informations :
# - Méthodes d'authentification proposées
# - Étapes PAM
# - Erreurs de configuration
```

#### Problèmes courants

|Symptôme|Cause probable|Solution|
|---|---|---|
|**"Permission denied (keyboard-interactive)"**|PAM mal configuré|Vérifier `/etc/pam.d/sshd`|
|**Pas de demande de code 2FA**|`ChallengeResponseAuthentication no`|Activer dans `sshd_config`|
|**Code toujours invalide**|Horloge désynchronisée|Synchroniser avec NTP|
|**Impossible de se connecter après config**|Erreur de syntaxe|`sudo sshd -t` puis corriger|

### Synchronisation temporelle (critique pour TOTP)

```bash
# Vérifier l'heure système
date
timedatectl

# Installer et configurer NTP
sudo apt install chrony  # Debian/Ubuntu
sudo yum install chrony  # Red Hat/CentOS

# Activer et démarrer le service
sudo systemctl enable chronyd
sudo systemctl start chronyd

# Vérifier la synchronisation
chronyc tracking

# Forcer une synchronisation immédiate
sudo chronyc makestep
```

> [!warning] Importance de la synchronisation temporelle TOTP génère des codes basés sur l'heure actuelle. Un décalage de plus de 30 secondes entre le serveur et l'appareil mobile rendra les codes invalides. La synchronisation NTP est **OBLIGATOIRE**.

---

## 🔑 Utilisation combinée clé + 2FA

### Principe de l'authentification multi-méthodes

L'authentification combinée offre le plus haut niveau de sécurité en exigeant :

1. **Quelque chose que vous avez** : clé SSH privée
2. **Quelque chose que vous connaissez** : code 2FA

### Configuration de AuthenticationMethods

#### Configuration basique (clé + 2FA obligatoires)

```bash
# /etc/ssh/sshd_config

# Activer clé publique
PubkeyAuthentication yes

# Activer keyboard-interactive (pour PAM/2FA)
KbdInteractiveAuthentication yes

# Exiger les DEUX méthodes dans l'ordre
AuthenticationMethods publickey,keyboard-interactive
```

> [!info] Syntaxe de AuthenticationMethods
> 
> - `,` (virgule) : ET logique (les deux sont requis)
> - (espace) : OU logique (l'un ou l'autre suffit)
> - Exemple : `publickey keyboard-interactive` = clé OU 2FA
> - Exemple : `publickey,keyboard-interactive` = clé ET 2FA

#### Configuration avancée par utilisateur

```bash
# /etc/ssh/sshd_config

# Configuration par défaut : 2FA obligatoire pour tous
AuthenticationMethods publickey,keyboard-interactive

# Exceptions pour certains utilisateurs
Match User admin
    AuthenticationMethods publickey

# Exceptions pour certains groupes
Match Group serviceaccounts
    AuthenticationMethods publickey
    
# Exceptions basées sur l'IP source
Match Address 192.168.1.0/24
    AuthenticationMethods publickey

# Rétablir les paramètres par défaut après les Match
Match All
```

> [!example] Cas d'usage des exceptions
> 
> - **Comptes de service** : scripts automatisés sans interaction humaine
> - **Administrateurs réseau local** : accès depuis le réseau de confiance
> - **Comptes d'urgence** : accès de secours en cas de problème 2FA

#### Configuration multi-niveaux de sécurité

```bash
# /etc/ssh/sshd_config

# Utilisateurs standards : clé + 2FA
Match Group users
    AuthenticationMethods publickey,keyboard-interactive

# Administrateurs : clé + 2FA + mot de passe (triple facteur)
Match Group admins
    AuthenticationMethods publickey,keyboard-interactive:pam,password

# Comptes restreints : mot de passe + 2FA (sans clé)
Match Group restricted
    AuthenticationMethods keyboard-interactive:pam,password

# Comptes automatisés : clé uniquement
Match Group automation
    AuthenticationMethods publickey

Match All
```

### Flux d'authentification détaillé

#### Scénario 1 : Clé + 2FA réussis

```bash
# 1. Client initie la connexion
ssh user@serveur

# 2. Serveur demande la clé publique
debug1: Offering public key: /home/user/.ssh/id_rsa

# 3. Client présente sa clé privée
debug1: Server accepts key

# 4. PAM demande le code 2FA
Verification code:

# 5. Utilisateur saisit le code depuis son téléphone
123456

# 6. PAM valide le code
debug1: Authentication succeeded (keyboard-interactive)

# 7. Connexion établie
Welcome to Ubuntu 22.04 LTS
```

#### Scénario 2 : Clé valide mais code 2FA invalide

```bash
# 1-3. Clé acceptée
debug1: Server accepts key

# 4. Code 2FA demandé
Verification code:

# 5. Code incorrect saisi
654321

# 6. Échec d'authentification
Permission denied (keyboard-interactive)

# 7. Connexion refusée malgré clé valide
```

> [!warning] Sécurité renforcée Même avec une clé SSH valide, l'accès est **REFUSÉ** si le code 2FA est incorrect. C'est le principe du double facteur : les deux doivent être valides.

### Configuration PAM spécifique pour clé + 2FA

Pour que la combinaison fonctionne correctement, PAM doit être configuré pour accepter uniquement le code 2FA, pas le mot de passe :

```bash
# /etc/pam.d/sshd

# Ne PAS inclure common-auth (qui demande mot de passe)
# @include common-auth    # COMMENTÉ

# Uniquement le module 2FA
auth required pam_google_authenticator.so

# Gestion des comptes
account required pam_nologin.so
account include password-auth

# Sessions
session required pam_loginuid.so
session include password-auth
```

### Expérience utilisateur

#### Connexion normale

```bash
# Commande de connexion classique
ssh user@serveur

# Le client SSH utilise automatiquement la clé
# Puis demande le code 2FA
Verification code: [l'utilisateur saisit le code]

# Connexion réussie
Last login: Mon Dec 15 10:30:00 2025
user@serveur:~$
```

#### Connexion avec clé spécifique

```bash
# Spécifier manuellement la clé à utiliser
ssh -i ~/.ssh/id_rsa_specific user@serveur

# Le reste du processus est identique
Verification code:
```

#### Connexion avec agent SSH

```bash
# Ajouter la clé à l'agent SSH (évite de retaper la passphrase)
ssh-add ~/.ssh/id_rsa
Enter passphrase for /home/user/.ssh/id_rsa:

# Connexion (passphrase non redemandée)
ssh user@serveur
Verification code: [seulement le code 2FA]
```

### Bonnes pratiques de déploiement

> [!tip] Migration progressive vers clé + 2FA
> 
> 1. **Phase 1** : Activer 2FA avec `nullok` (optionnel)
> 2. **Phase 2** : Former les utilisateurs à configurer leur 2FA
> 3. **Phase 3** : Retirer `nullok` pour rendre 2FA obligatoire
> 4. **Phase 4** : Ajouter `AuthenticationMethods publickey,keyboard-interactive`

#### Script de validation pour utilisateurs

```bash
#!/bin/bash
# check_2fa_setup.sh - Vérifie si les utilisateurs ont configuré leur 2FA

echo "Vérification de la configuration 2FA..."

for user in $(getent passwd | awk -F: '$3 >= 1000 && $3 < 65534 {print $1}'); do
    if [ -f "/home/$user/.google_authenticator" ]; then
        echo "✓ $user : 2FA configuré"
    else
        echo "✗ $user : 2FA NON configuré"
    fi
done
```

### Gestion des clés et codes pour administrateurs

#### Rotation des secrets 2FA

```bash
# Un utilisateur peut régénérer son secret à tout moment
google-authenticator -f

# Cela invalide l'ancien secret et génère :
# - Un nouveau QR code à scanner
# - De nouveaux codes d'urgence
```

#### Sauvegarde de la configuration 2FA

```bash
# Sauvegarder le fichier de configuration (prudence : contient le secret)
cp ~/.google_authenticator ~/.google_authenticator.backup

# Permissions restrictives
chmod 400 ~/.google_authenticator.backup

# Restauration en cas de besoin
cp ~/.google_authenticator.backup ~/.google_authenticator
```

> [!warning] Sécurité des sauvegardes Le fichier `.google_authenticator` contient le secret partagé. Protégez-le comme vous protégeriez une clé privée SSH :
> 
> - Permissions 400 (lecture seule pour le propriétaire)
> - Stockage chiffré si sauvegarde externe
> - Ne jamais le transmettre en clair

### Tests et validation

#### Test complet de la configuration

```bash
# 1. Vérifier la config SSH
sudo sshd -t

# 2. Vérifier PAM
sudo cat /etc/pam.d/sshd | grep google_authenticator

# 3. Vérifier que l'utilisateur a configuré 2FA
ls -l ~/.google_authenticator

# 4. Tester depuis une autre session (garder une session ouverte en backup)
ssh -v user@serveur
```

#### Validation de l'ordre d'authentification

```bash
# Connexion avec debug verbeux
ssh -vvv user@serveur 2>&1 | grep -i "auth"

# Rechercher dans la sortie :
# - "Offering public key" : clé SSH proposée
# - "Server accepts key" : clé acceptée
# - "keyboard-interactive" : demande du code 2FA
# - "Authentication succeeded" : succès complet
```

### Désactivation temporaire du 2FA (maintenance)

```bash
# En cas d'urgence, pour désactiver temporairement le 2FA

# Méthode 1 : Commenter dans PAM (rapide)
sudo nano /etc/pam.d/sshd
# Commenter : # auth required pam_google_authenticator.so

# Méthode 2 : Changer AuthenticationMethods (temporaire)
sudo nano /etc/ssh/sshd_config
# Modifier : AuthenticationMethods publickey

# Relancer SSH
sudo systemctl restart sshd
```

> [!warning] Procédure d'urgence uniquement Cette désactivation doit être temporaire et documentée. Réactivez le 2FA dès que possible après maintenance.

---

## 🎯 Pièges courants et solutions

### Piège 1 : Horloge désynchronisée

**Symptôme** : Codes toujours invalides malgré configuration correcte

**Cause** : Différence de temps entre serveur et appareil mobile > 30 secondes

**Solution** :

```bash
# Vérifier l'heure
date

# Synchroniser avec NTP
sudo chronyc makestep

# Vérifier à nouveau
chronyc tracking
```

### Piège 2 : Ordre incorrect dans PAM

**Symptôme** : Demande de mot de passe au lieu du code 2FA

**Cause** : `pam_google_authenticator.so` placé après `common-auth`

**Solution** :

```bash
# Placer en PREMIER dans /etc/pam.d/sshd
auth required pam_google_authenticator.so
# (puis le reste)
```

### Piège 3 : ChallengeResponseAuthentication désactivé

**Symptôme** : Pas de demande de code 2FA, connexion par clé seule

**Cause** : `ChallengeResponseAuthentication no` dans `sshd_config`

**Solution** :

```bash
# /etc/ssh/sshd_config
ChallengeResponseAuthentication yes
# ou
KbdInteractiveAuthentication yes
```

### Piège 4 : Permissions incorrectes

**Symptôme** : Erreur "Failed to read ~/.google_authenticator"

**Cause** : Permissions trop ouvertes sur le fichier de configuration

**Solution** :

```bash
chmod 400 ~/.google_authenticator
```

### Piège 5 : Verrouillage complet après configuration

**Symptôme** : Impossible de se connecter après activation

**Prévention** :

- Toujours garder une session SSH ouverte pendant les tests
- Utiliser `nullok` pendant la phase de test
- Tester avec un utilisateur non-critique d'abord

**Solution d'urgence** :

```bash
# Accès console physique ou VNC/IPMI
# Commenter temporairement dans /etc/pam.d/sshd
sudo nano /etc/pam.d/sshd
# auth required pam_google_authenticator.so

sudo systemctl restart sshd
```

---

## 📊 Récapitulatif des fichiers de configuration

|Fichier|Rôle|Commande d'édition|
|---|---|---|
|`/etc/ssh/sshd_config`|Configuration serveur SSH|`sudo nano /etc/ssh/sshd_config`|
|`/etc/pam.d/sshd`|Configuration PAM pour SSH|`sudo nano /etc/pam.d/sshd`|
|`~/.google_authenticator`|Secret 2FA de l'utilisateur|`google-authenticator`|
|`~/.ssh/authorized_keys`|Clés publiques autorisées|`nano ~/.ssh/authorized_keys`|

---

## ✅ Checklist de déploiement

- [ ] Module PAM Google Authenticator installé
- [ ] Chaque utilisateur a exécuté `google-authenticator`
- [ ] Codes d'urgence sauvegardés en lieu sûr
- [ ] `/etc/pam.d/sshd` configuré avec `pam_google_authenticator.so`
- [ ] `ChallengeResponseAuthentication yes` dans `sshd_config`
- [ ] `UsePAM yes` dans `sshd_config`
- [ ] `AuthenticationMethods publickey,keyboard-interactive` configuré
- [ ] Synchronisation NTP active et fonctionnelle
- [ ] Tests réalisés avec session backup ouverte
- [ ] Documentation des procédures d'urgence
- [ ] Formation des utilisateurs effectuée

---

**🔒 Votre serveur SSH est maintenant protégé par une authentification multifacteur robuste !**