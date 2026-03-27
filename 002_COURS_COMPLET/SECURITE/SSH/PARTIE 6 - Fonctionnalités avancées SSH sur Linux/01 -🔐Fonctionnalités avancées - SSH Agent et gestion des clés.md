

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

## 🎯 Introduction au SSH Agent

### Qu'est-ce que le SSH Agent ?

Le **SSH Agent** est un programme qui tourne en arrière-plan et conserve vos clés privées SSH en mémoire. Son rôle principal est de gérer l'authentification par clés sans avoir à retaper constamment la passphrase de vos clés privées.

### Pourquoi utiliser un SSH Agent ?

Sans SSH Agent, vous devez entrer la passphrase de votre clé privée à **chaque connexion SSH**. Avec l'agent :

- ✅ Vous déverrouillez votre clé **une seule fois** par session
- ✅ L'agent répond automatiquement aux demandes d'authentification
- ✅ Vos clés privées restent sécurisées (ne sont pas écrites sur disque)
- ✅ Possibilité de transférer l'authentification vers d'autres serveurs (forwarding)

> [!info] Fonctionnement L'agent SSH agit comme un intermédiaire : quand vous vous connectez à un serveur, le client SSH demande à l'agent de signer la requête d'authentification avec votre clé privée, sans jamais exposer la clé elle-même.

### Quand l'utiliser ?

- 🔹 Lors de sessions de travail prolongées avec multiples connexions SSH
- 🔹 Quand vous utilisez des clés protégées par passphrase (recommandé)
- 🔹 Pour automatiser des tâches nécessitant plusieurs connexions successives
- 🔹 Lors de l'utilisation de SSH jump hosts ou rebonds

---

## 🚀 Lancement de ssh-agent

### Méthodes de lancement

#### Méthode 1 : Lancement manuel

```bash
# Démarrer ssh-agent et récupérer les variables d'environnement
eval "$(ssh-agent -s)"
```

**Sortie typique :**

```
Agent pid 12345
```

> [!example] Explication
> 
> - `ssh-agent -s` démarre l'agent et affiche les commandes shell à exécuter
> - `eval` exécute ces commandes pour configurer les variables d'environnement
> - Les variables `SSH_AUTH_SOCK` et `SSH_AGENT_PID` sont alors définies

#### Méthode 2 : Lancement dans un sous-shell

```bash
# Démarrer une session bash avec ssh-agent actif
ssh-agent bash
```

Cette méthode lance un nouveau shell avec l'agent déjà configuré. Quand vous quittez ce shell, l'agent se termine automatiquement.

#### Méthode 3 : Démarrage automatique au login

Ajoutez dans votre `~/.bashrc` ou `~/.zshrc` :

```bash
# Vérifier si ssh-agent tourne déjà
if [ -z "$SSH_AUTH_SOCK" ]; then
    # Démarrer ssh-agent si nécessaire
    eval "$(ssh-agent -s)"
    # Optionnel : ajouter automatiquement vos clés
    ssh-add ~/.ssh/id_ed25519 2>/dev/null
fi
```

> [!warning] Attention avec le démarrage automatique Cette méthode peut créer plusieurs instances d'agent si vous ouvrez plusieurs terminaux. Préférez utiliser un agent système ou une solution comme `keychain`.

### Vérification de l'agent

```bash
# Afficher le PID de l'agent en cours
echo $SSH_AGENT_PID

# Afficher le socket de communication
echo $SSH_AUTH_SOCK

# Lister les clés actuellement chargées
ssh-add -l
```

### Options de lancement avancées

```bash
# Démarrer l'agent avec un timeout (en secondes)
ssh-agent -t 3600  # L'agent se termine après 1 heure

# Spécifier un socket personnalisé
ssh-agent -a /tmp/mon_socket_ssh

# Mode debug pour diagnostiquer les problèmes
ssh-agent -d
```

> [!tip] Astuce : Réutiliser un agent existant Si un agent tourne déjà, vous pouvez le réutiliser en exportant les bonnes variables :
> 
> ```bash
> export SSH_AUTH_SOCK=/tmp/ssh-XXX/agent.12345
> export SSH_AGENT_PID=12345
> ```

---

## 🔑 Ajout de clés avec ssh-add

### Commandes de base

#### Ajouter une clé spécifique

```bash
# Ajouter une clé privée particulière
ssh-add ~/.ssh/id_ed25519

# Ajouter une clé avec confirmation à chaque usage
ssh-add -c ~/.ssh/id_ed25519
```

Lors de l'ajout, si votre clé est protégée par passphrase, vous devrez la saisir une fois.

#### Ajouter toutes les clés par défaut

```bash
# Ajoute automatiquement les clés standards
ssh-add
```

Par défaut, cette commande cherche et ajoute :

- `~/.ssh/id_rsa`
- `~/.ssh/id_ed25519`
- `~/.ssh/id_ecdsa`
- `~/.ssh/id_dsa`

### Gestion des clés chargées

#### Lister les clés

```bash
# Liste simple (empreintes SHA256)
ssh-add -l

# Liste détaillée avec empreintes MD5
ssh-add -l -E md5

# Afficher les clés publiques complètes
ssh-add -L
```

**Exemple de sortie :**

```
256 SHA256:AbCdEf123456... utilisateur@machine (ED25519)
2048 SHA256:XyZ789GhIjKl... utilisateur@machine (RSA)
```

#### Supprimer des clés

```bash
# Supprimer une clé spécifique
ssh-add -d ~/.ssh/id_ed25519

# Supprimer TOUTES les clés de l'agent
ssh-add -D
```

> [!warning] Suppression totale `ssh-add -D` vide complètement l'agent. Vous devrez rajouter vos clés si vous en avez besoin.

### Options avancées

#### Durée de vie des clés

```bash
# Ajouter une clé qui expire après 1 heure (3600 secondes)
ssh-add -t 3600 ~/.ssh/id_ed25519

# Ajouter avec expiration de 30 minutes
ssh-add -t 1800 ~/.ssh/id_ed25519
```

Après le délai, la clé est automatiquement retirée de l'agent.

#### Confirmation manuelle

```bash
# Demander confirmation avant chaque usage de la clé
ssh-add -c ~/.ssh/id_ed25519
```

> [!info] Confirmation interactive Avec l'option `-c`, une fenêtre popup apparaît à chaque tentative d'utilisation de la clé, vous demandant de confirmer l'opération. Très utile pour les clés ultra-sensibles.

#### Charger une clé depuis macOS Keychain

Sur macOS uniquement :

```bash
# Charger depuis le trousseau et ajouter à l'agent
ssh-add --apple-use-keychain ~/.ssh/id_ed25519

# Charger automatiquement depuis le trousseau
ssh-add --apple-load-keychain
```

### Tableaux récapitulatifs

|Commande|Description|
|---|---|
|`ssh-add`|Ajoute les clés par défaut|
|`ssh-add <fichier>`|Ajoute une clé spécifique|
|`ssh-add -l`|Liste les clés chargées|
|`ssh-add -L`|Affiche les clés publiques|
|`ssh-add -d <fichier>`|Supprime une clé|
|`ssh-add -D`|Supprime toutes les clés|
|`ssh-add -t <sec>`|Ajoute avec expiration|
|`ssh-add -c`|Ajoute avec confirmation|

> [!tip] Bonne pratique : Clés multiples Si vous gérez plusieurs identités (travail, personnel, projets), utilisez des clés différentes et ajoutez-les sélectivement selon vos besoins :
> 
> ```bash
> ssh-add ~/.ssh/id_travail
> ssh-add ~/.ssh/id_personnel
> ```

### Pièges courants

#### Erreur "Could not open a connection to your authentication agent"

**Cause :** L'agent SSH n'est pas démarré ou les variables d'environnement ne sont pas définies.

**Solution :**

```bash
eval "$(ssh-agent -s)"
```

#### Trop de tentatives d'authentification

Si vous avez trop de clés chargées (>5), certains serveurs peuvent refuser la connexion.

**Solution :** Limitez les clés chargées ou utilisez la configuration SSH pour spécifier quelle clé utiliser pour quel serveur.

---

## 🔄 Forwarding de l'agent

### Qu'est-ce que l'agent forwarding ?

Le **forwarding d'agent** (ou transfert d'agent) permet d'utiliser vos clés SSH locales sur un serveur distant, sans avoir à copier vos clés privées sur ce serveur.

### Pourquoi c'est utile ?

Scénario typique : vous devez rebondir via plusieurs serveurs.

```
Votre PC → Bastion → Serveur final
```

Sans forwarding : vous devez copier votre clé privée sur le Bastion (❌ risque de sécurité).

Avec forwarding : vos clés restent sur votre PC, mais le Bastion peut les utiliser pour s'authentifier sur le serveur final (✅ sécurisé).

### Activation du forwarding

#### Méthode 1 : Option en ligne de commande

```bash
# Connexion avec forwarding activé
ssh -A user@bastion.example.com
```

Une fois connecté au bastion, vous pouvez faire :

```bash
# Depuis le bastion, se connecter au serveur final
ssh user@serveur-final.example.com
# L'authentification utilise votre clé locale !
```

#### Méthode 2 : Configuration permanente

Dans `~/.ssh/config` :

```bash
Host bastion
    HostName bastion.example.com
    User votre_user
    ForwardAgent yes

Host serveur-final
    HostName serveur-final.example.com
    User votre_user
    ProxyJump bastion  # Utilise bastion comme rebond
    ForwardAgent yes
```

Ensuite, connexion simplifiée :

```bash
ssh bastion
# ou directement
ssh serveur-final  # Passe automatiquement par le bastion
```

### Vérification du forwarding

Sur le serveur distant, vérifiez que le socket de l'agent est accessible :

```bash
# Afficher la variable d'environnement
echo $SSH_AUTH_SOCK

# Lister les clés disponibles depuis le serveur distant
ssh-add -l
```

Si vous voyez vos clés locales listées, le forwarding fonctionne ! 🎉

### Forwarding en cascade

Vous pouvez enchaîner plusieurs rebonds :

```
PC local → Bastion 1 → Bastion 2 → Serveur final
```

Configuration :

```bash
Host bastion1
    HostName bastion1.example.com
    ForwardAgent yes

Host bastion2
    HostName bastion2.example.com
    ProxyJump bastion1
    ForwardAgent yes

Host serveur-final
    HostName serveur-final.example.com
    ProxyJump bastion2
    ForwardAgent yes
```

> [!example] Utilisation pratique
> 
> ```bash
> # Connexion directe au serveur final
> ssh serveur-final
> # SSH gère automatiquement tous les rebonds !
> ```

### Limitations et considérations

|Avantage|Inconvénient|
|---|---|
|✅ Pas besoin de copier les clés|❌ Risque si le serveur distant est compromis|
|✅ Centralisation des clés|❌ Ne fonctionne pas avec `sudo` ou changement d'utilisateur|
|✅ Simplifie les rebonds|❌ Nécessite une connexion SSH active|

> [!warning] Sécurité du forwarding Activez le forwarding **uniquement** sur les serveurs de confiance. Un administrateur malveillant sur le serveur distant pourrait utiliser votre agent pour s'authentifier ailleurs pendant que vous êtes connecté.

---

## 🛡️ Sécurité de l'agent

### Risques potentiels

#### 1. Accès non autorisé au socket

Sur un système multi-utilisateurs, si les permissions du socket de l'agent sont mal configurées, d'autres utilisateurs pourraient utiliser vos clés.

**Vérification :**

```bash
# Afficher les permissions du socket
ls -la $SSH_AUTH_SOCK
```

**Sortie normale (sécurisée) :**

```
srwx------ 1 votre_user votre_group 0 Dec 15 10:30 /tmp/ssh-XXX/agent.12345
```

Les permissions doivent être `600` (lecture/écriture uniquement par vous).

#### 2. Agent forwarding sur serveur non fiable

Comme expliqué précédemment, un administrateur malveillant peut intercepter les requêtes d'authentification.

#### 3. Clés en mémoire

Les clés privées sont stockées en mémoire non chiffrée. Un attaquant avec accès root pourrait potentiellement les extraire.

### Bonnes pratiques de sécurité

#### 1. Limiter la durée de vie des clés

```bash
# Ajouter une clé avec expiration de 4 heures
ssh-add -t 14400 ~/.ssh/id_ed25519
```

#### 2. Demander confirmation pour les clés sensibles

```bash
# Confirmation requise avant chaque usage
ssh-add -c ~/.ssh/id_production
```

> [!tip] Clés par environnement Utilisez différentes clés pour différents environnements :
> 
> - Clé "dev" sans confirmation pour le développement quotidien
> - Clé "prod" avec confirmation pour les serveurs de production

#### 3. Nettoyer l'agent régulièrement

```bash
# Supprimer toutes les clés à la fin de la journée
ssh-add -D

# Ou arrêter complètement l'agent
ssh-agent -k
```

#### 4. Restreindre le forwarding

Dans `~/.ssh/config`, activez le forwarding **uniquement** pour les hôtes nécessaires :

```bash
# Par défaut, désactiver le forwarding
Host *
    ForwardAgent no

# Activer uniquement pour les bastions de confiance
Host bastion-production
    HostName bastion.prod.example.com
    ForwardAgent yes
```

#### 5. Utiliser des clés différentes par destination

Configuration avancée :

```bash
Host serveur-dev
    HostName dev.example.com
    IdentityFile ~/.ssh/id_dev
    ForwardAgent no

Host serveur-prod
    HostName prod.example.com
    IdentityFile ~/.ssh/id_prod
    ForwardAgent no
    # Forcer l'utilisation de cette clé uniquement
    IdentitiesOnly yes
```

### Protection du système

#### 1. Chiffrement du disque

Vos clés privées sur disque doivent être sur une partition chiffrée (LUKS, FileVault, BitLocker).

#### 2. Permissions strictes

```bash
# Vérifier les permissions de votre répertoire .ssh
ls -la ~/.ssh/

# Corriger si nécessaire
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_*
chmod 644 ~/.ssh/*.pub
```

#### 3. Utiliser des passphrases fortes

```bash
# Changer la passphrase d'une clé existante
ssh-keygen -p -f ~/.ssh/id_ed25519
```

> [!info] Force de passphrase Une bonne passphrase :
> 
> - Au moins 20 caractères
> - Mélange de mots, chiffres et symboles
> - Unique (pas réutilisée ailleurs)
> - Peut être une phrase complète pour faciliter la mémorisation

### Outils de sécurité avancés

#### 1. Keychain (Linux)

Keychain permet de réutiliser un agent entre sessions tout en gérant proprement son cycle de vie.

```bash
# Installation (Debian/Ubuntu)
sudo apt install keychain

# Dans ~/.bashrc
eval $(keychain --eval --agents ssh id_ed25519)
```

#### 2. GPG Agent comme agent SSH

GPG Agent peut remplacer ssh-agent et offre des fonctionnalités de sécurité supplémentaires.

```bash
# Dans ~/.gnupg/gpg-agent.conf
enable-ssh-support

# Dans ~/.bashrc
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
```

#### 3. Clés matérielles (YubiKey, Nitrokey)

Les clés matérielles stockent vos clés privées dans un hardware sécurisé, impossible à extraire.

> [!tip] Sécurité maximale Avec une clé matérielle, même si votre ordinateur est compromis, l'attaquant ne peut pas voler votre clé privée.

### Audit et surveillance

#### Vérifier l'activité de l'agent

```bash
# Surveiller les connexions SSH actives
who

# Afficher l'historique des connexions
last -a

# Logs SSH détaillés
sudo journalctl -u ssh
# ou
sudo tail -f /var/log/auth.log
```

#### Alertes de sécurité

Configurez des alertes pour détecter des usages anormaux :

```bash
# Exemple : script de monitoring simple
watch -n 60 'ssh-add -l | mail -s "SSH Agent Status" you@example.com'
```

### Checklist de sécurité

✅ **À faire :**

- Utiliser des passphrases fortes sur toutes vos clés
- Limiter la durée de vie des clés dans l'agent
- Nettoyer l'agent en fin de session
- Restreindre le forwarding aux hôtes de confiance
- Vérifier régulièrement les permissions
- Utiliser des clés différentes par environnement

❌ **À éviter :**

- Laisser des clés sans passphrase
- Activer le forwarding sur tous les hôtes
- Copier des clés privées sur des serveurs distants
- Réutiliser la même clé partout
- Négliger les mises à jour de sécurité

---

## 📊 Tableau récapitulatif des commandes

|Catégorie|Commande|Description|
|---|---|---|
|**Démarrage**|`eval "$(ssh-agent -s)"`|Démarre l'agent et configure l'environnement|
||`ssh-agent bash`|Lance un shell avec agent actif|
||`ssh-agent -k`|Arrête l'agent|
|**Ajout de clés**|`ssh-add`|Ajoute les clés par défaut|
||`ssh-add ~/.ssh/id_ed25519`|Ajoute une clé spécifique|
||`ssh-add -t 3600 <clé>`|Ajoute avec expiration (1h)|
||`ssh-add -c <clé>`|Ajoute avec confirmation requise|
|**Liste et suppression**|`ssh-add -l`|Liste les clés chargées|
||`ssh-add -L`|Affiche les clés publiques|
||`ssh-add -d <clé>`|Supprime une clé|
||`ssh-add -D`|Supprime toutes les clés|
|**Forwarding**|`ssh -A user@host`|Connexion avec forwarding activé|
||`ForwardAgent yes`|Active le forwarding (dans config)|
|**Diagnostic**|`echo $SSH_AUTH_SOCK`|Affiche le socket de l'agent|
||`echo $SSH_AGENT_PID`|Affiche le PID de l'agent|

---

> [!tip] 💡 Astuce finale Créez un alias dans votre `~/.bashrc` pour démarrer rapidement l'agent avec vos clés préférées :
> 
> ```bash
> alias ssh-start='eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_ed25519'
> ```