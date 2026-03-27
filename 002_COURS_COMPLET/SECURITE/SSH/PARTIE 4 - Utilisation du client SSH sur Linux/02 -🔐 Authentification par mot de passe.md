

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

L'authentification par mot de passe est la méthode la plus simple et la plus courante pour se connecter à un serveur SSH. Elle fonctionne comme une connexion classique : vous fournissez votre nom d'utilisateur et votre mot de passe, et le serveur vérifie vos identifiants.

> [!info] Pourquoi utiliser l'authentification par mot de passe ?
> 
> - **Simplicité** : Aucune configuration préalable nécessaire
> - **Accessibilité** : Fonctionne immédiatement sur n'importe quelle machine
> - **Familiarité** : Méthode intuitive pour les débutants

> [!warning] Limitations importantes L'authentification par mot de passe est la méthode la **moins sécurisée** pour SSH. Elle est vulnérable aux attaques par force brute et ne devrait être utilisée que temporairement ou dans des environnements de test.

---

## 🔌 Connexion interactive

### Syntaxe de base

```bash
# Connexion standard
ssh utilisateur@hôte

# Exemples concrets
ssh john@192.168.1.100
ssh admin@serveur.exemple.com
ssh root@10.0.0.50
```

### Processus de connexion

Lorsque vous exécutez la commande SSH, voici ce qui se passe :

1. **Établissement de la connexion** : Le client SSH contacte le serveur sur le port 22 (par défaut)
2. **Vérification de l'hôte** : Premier contact ? Vous devrez accepter l'empreinte du serveur
3. **Demande de mot de passe** : Le serveur demande votre mot de passe
4. **Authentification** : Le serveur vérifie vos identifiants
5. **Session ouverte** : Vous accédez au shell distant

> [!example] Exemple de première connexion
> 
> ```bash
> $ ssh admin@192.168.1.100
> The authenticity of host '192.168.1.100 (192.168.1.100)' can't be established.
> ECDSA key fingerprint is SHA256:xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx.
> Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
> Warning: Permanently added '192.168.1.100' (ECDSA) to the list of known hosts.
> admin@192.168.1.100's password: 
> ```

### Options utiles lors de la connexion

```bash
# Spécifier un port différent (si le serveur n'utilise pas le port 22)
ssh -p 2222 utilisateur@hôte

# Mode verbeux pour le débogage
ssh -v utilisateur@hôte          # Verbosité simple
ssh -vv utilisateur@hôte         # Verbosité moyenne
ssh -vvv utilisateur@hôte        # Verbosité maximale

# Forcer l'utilisation du mot de passe (utile si des clés existent)
ssh -o PreferredAuthentications=password utilisateur@hôte

# Désactiver la vérification de la clé d'hôte (DANGEREUX, à éviter)
ssh -o StrictHostKeyChecking=no utilisateur@hôte
```

> [!tip] Astuce : Saisie du mot de passe Lors de la saisie du mot de passe, **aucun caractère ne s'affiche** à l'écran (pas même des astérisques). C'est normal et c'est une mesure de sécurité pour empêcher quiconque de deviner la longueur de votre mot de passe.

### Connexion avec exécution de commande

Vous pouvez exécuter une commande distante sans ouvrir de session interactive :

```bash
# Exécuter une commande unique
ssh utilisateur@hôte 'commande'

# Exemples
ssh admin@serveur.com 'ls -la /var/log'
ssh root@192.168.1.100 'df -h'
ssh user@host 'uptime'

# Avec redirection locale
ssh user@host 'cat /var/log/syslog' > log_local.txt
```

> [!warning] Attention aux guillemets Utilisez des **guillemets simples** pour éviter que le shell local n'interprète les variables ou caractères spéciaux avant l'envoi au serveur distant.

---

## ⚠️ Problèmes courants

### 1. "Permission denied (publickey)"

**Cause** : Le serveur refuse l'authentification par mot de passe (souvent désactivée).

```bash
# Erreur typique
$ ssh user@host
user@host: Permission denied (publickey).
```

**Solutions** :

```bash
# Vérifier si l'authentification par mot de passe est activée
ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no user@host

# Si cela ne fonctionne pas, le serveur a désactivé l'authentification par mot de passe
# Vous devrez utiliser une clé SSH (abordé dans une autre partie du cours)
```

### 2. "Connection refused"

**Causes possibles** :

- Le service SSH n'est pas démarré sur le serveur
- Un pare-feu bloque la connexion
- Mauvais port spécifié

```bash
# Erreur typique
$ ssh user@host
ssh: connect to host host port 22: Connection refused
```

**Diagnostic** :

```bash
# Vérifier si le port SSH est ouvert
nc -zv host 22                    # Avec netcat
telnet host 22                    # Avec telnet

# Tester un autre port si le serveur utilise un port non standard
ssh -p 2222 user@host

# Vérifier l'état du service SSH sur le serveur (si vous avez un accès)
sudo systemctl status sshd        # Sur systemd
sudo service ssh status           # Sur SysV
```

### 3. "Host key verification failed"

**Cause** : L'empreinte du serveur a changé (réinstallation, attaque MITM potentielle).

```bash
# Erreur typique
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    WARNING: REMOTE HOST IDENTIFICATION HAS CHANGED!     @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
IT IS POSSIBLE THAT SOMEONE IS DOING SOMETHING NASTY!
```

**Solution** (après avoir vérifié qu'il ne s'agit pas d'une attaque) :

```bash
# Supprimer l'ancienne clé pour cet hôte
ssh-keygen -R hostname

# Ou éditer manuellement le fichier
nano ~/.ssh/known_hosts
# Supprimer la ligne correspondant à l'hôte
```

> [!warning] Sécurité critique Ne supprimez jamais cette clé sans avoir vérifié auprès de l'administrateur du serveur que c'est légitime. Un changement d'empreinte peut indiquer une attaque "Man-in-the-Middle".

### 4. "Too many authentication failures"

**Cause** : Trop de tentatives d'authentification échouées (souvent à cause de multiples clés SSH testées automatiquement).

```bash
# Erreur typique
Received disconnect from host: 2: Too many authentication failures
```

**Solution** :

```bash
# Limiter le nombre de clés tentées
ssh -o IdentitiesOnly=yes user@host

# Ou spécifier explicitement qu'on veut utiliser le mot de passe
ssh -o PreferredAuthentications=password -o PubkeyAuthentication=no user@host
```

### 5. Problèmes de timeout

**Cause** : Connexion lente, serveur surchargé, ou pare-feu avec inspection profonde.

```bash
# Augmenter le délai de connexion
ssh -o ConnectTimeout=30 user@host

# Activer le keepalive pour maintenir la connexion active
ssh -o ServerAliveInterval=60 -o ServerAliveCountMax=3 user@host
```

### Tableau récapitulatif des erreurs

|Erreur|Cause probable|Solution rapide|
|---|---|---|
|Permission denied (publickey)|Auth. mot de passe désactivée|Forcer avec `-o PreferredAuthentications=password`|
|Connection refused|Service SSH arrêté ou port incorrect|Vérifier le service et le numéro de port|
|Host key verification failed|Empreinte serveur modifiée|`ssh-keygen -R hostname` après vérification|
|Too many authentication failures|Trop de clés SSH testées|`-o IdentitiesOnly=yes`|
|Network unreachable|Problème réseau|Vérifier la connectivité réseau|
|Timeout|Connexion lente ou bloquée|Augmenter `ConnectTimeout`|

---

## 🔒 Désactivation pour la sécurité

### Pourquoi désactiver l'authentification par mot de passe ?

L'authentification par mot de passe présente plusieurs faiblesses :

> [!warning] Vulnérabilités de l'authentification par mot de passe
> 
> - **Attaques par force brute** : Les robots peuvent tester des milliers de mots de passe
> - **Mots de passe faibles** : Les utilisateurs choisissent souvent des mots de passe prévisibles
> - **Réutilisation** : Le même mot de passe compromis sur un service peut être testé ailleurs
> - **Pas de rotation automatique** : Les mots de passe ne changent pas automatiquement
> - **Phishing** : Les utilisateurs peuvent révéler leur mot de passe par erreur

**L'authentification par clé SSH** (abordée dans une autre partie) est **beaucoup plus sécurisée** et devrait être privilégiée pour tous les serveurs en production.

### Configuration côté serveur

Pour désactiver l'authentification par mot de passe, l'administrateur doit modifier le fichier de configuration du serveur SSH :

```bash
# Éditer le fichier de configuration SSH (nécessite les droits root)
sudo nano /etc/ssh/sshd_config
```

**Paramètres à modifier :**

```bash
# Désactiver l'authentification par mot de passe
PasswordAuthentication no

# Désactiver l'authentification "challenge-response" (méthode alternative)
ChallengeResponseAuthentication no

# Désactiver l'authentification par mot de passe vide
PermitEmptyPasswords no

# Optionnel : Désactiver la connexion root par mot de passe
PermitRootLogin prohibit-password
```

> [!tip] Bonne pratique : Configuration progressive **Avant de désactiver l'authentification par mot de passe** :
> 
> 1. Configurez d'abord l'authentification par clé SSH
> 2. Testez la connexion avec la clé dans une **nouvelle session** (gardez votre session actuelle ouverte)
> 3. Une fois certain que la clé fonctionne, désactivez l'authentification par mot de passe
> 4. Redémarrez le service SSH

**Redémarrage du service SSH après modification :**

```bash
# Sur systemd (Debian, Ubuntu, CentOS 7+, etc.)
sudo systemctl restart sshd

# Sur SysV init (anciennes versions)
sudo service ssh restart
```

> [!warning] Risque de verrouillage **NE FERMEZ JAMAIS** votre session SSH active avant d'avoir vérifié que vous pouvez vous reconnecter ! Gardez toujours une session ouverte pendant les modifications de configuration SSH.

### Vérification de la configuration

```bash
# Vérifier la syntaxe du fichier de configuration (côté serveur)
sudo sshd -t

# Voir la configuration active
sudo sshd -T | grep -i password

# Exemple de sortie quand l'authentification par mot de passe est désactivée
# passwordauthentication no
# permitemptypasswords no
```

### Impact sur les utilisateurs

Une fois l'authentification par mot de passe désactivée :

```bash
# Les tentatives de connexion par mot de passe échouent
$ ssh user@host
user@host: Permission denied (publickey).

# Les utilisateurs doivent utiliser une clé SSH
$ ssh -i ~/.ssh/id_rsa user@host
# Connexion réussie avec la clé
```

### Cas d'usage où garder l'authentification par mot de passe

|Situation|Recommandation|
|---|---|
|**Serveur de production**|❌ Désactiver (utiliser clés SSH)|
|**Environnement de test**|✅ Acceptable temporairement|
|**Accès d'urgence**|⚠️ Utiliser un compte de secours séparé|
|**Utilisateurs occasionnels**|⚠️ Préférer un VPN + clés SSH|
|**Machines personnelles**|✅ Acceptable si réseau de confiance|

> [!tip] Stratégie hybride Certains administrateurs configurent :
> 
> - Authentification par clé SSH pour les utilisateurs standards
> - Authentification par mot de passe **uniquement** depuis des IP de confiance (via `Match Address` dans `sshd_config`)
> - Authentification à deux facteurs (2FA) pour renforcer les mots de passe

### Protection complémentaire avec Fail2ban

Même avec l'authentification par mot de passe activée, vous pouvez limiter les attaques par force brute :

```bash
# Installation de Fail2ban (Debian/Ubuntu)
sudo apt install fail2ban

# Fail2ban bannit automatiquement les IP qui font trop de tentatives échouées
# Configuration par défaut dans /etc/fail2ban/jail.conf

# Vérifier les IP bannies
sudo fail2ban-client status sshd
```

---

## 📌 Résumé

|Aspect|Détail|
|---|---|
|**Commande de base**|`ssh utilisateur@hôte`|
|**Avantages**|Simple, intuitif, aucune configuration|
|**Inconvénients**|Vulnérable aux attaques, moins sécurisé|
|**Recommandation**|À utiliser uniquement pour tests ou temporairement|
|**Alternative sécurisée**|Authentification par clé SSH (voir partie suivante)|

> [!info] À retenir
> 
> - L'authentification par mot de passe est la **plus simple** mais la **moins sécurisée**
> - Elle devrait être **désactivée** sur les serveurs en production
> - Les **clés SSH** offrent une sécurité bien supérieure
> - Toujours garder une **session ouverte** lors de modifications de configuration SSH