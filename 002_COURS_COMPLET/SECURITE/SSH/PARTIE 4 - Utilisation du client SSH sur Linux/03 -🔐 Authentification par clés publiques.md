

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

L'authentification par clés publiques est la méthode recommandée pour sécuriser les connexions SSH. Elle remplace l'authentification par mot de passe en utilisant la **cryptographie asymétrique**.

> [!info] Principe de fonctionnement
> 
> - Vous générez une **paire de clés** : une clé privée (secrète) et une clé publique
> - La clé publique est déposée sur le serveur distant
> - La clé privée reste sur votre machine locale et ne doit JAMAIS être partagée
> - Lors de la connexion, le serveur vérifie que vous possédez la clé privée correspondant à la clé publique

### Avantages de cette méthode

|Avantage|Explication|
|---|---|
|🔒 **Sécurité renforcée**|Impossible de deviner une clé de 4096 bits, contrairement à un mot de passe|
|⚡ **Connexion rapide**|Plus besoin de taper le mot de passe à chaque connexion|
|🤖 **Automatisation**|Permet les scripts automatisés sans interaction humaine|
|🛡️ **Protection contre brute-force**|Les attaques par force brute deviennent impossibles|

---

## 🔑 Génération de paires de clés

### La commande ssh-keygen

La commande `ssh-keygen` permet de créer une nouvelle paire de clés SSH.

```bash
# Génération basique (par défaut : RSA 3072 bits)
ssh-keygen

# Génération avec algorithme ED25519 (recommandé en 2024)
ssh-keygen -t ed25519 -C "mon-email@exemple.com"

# Génération RSA avec 4096 bits (alternative robuste)
ssh-keygen -t rsa -b 4096 -C "mon-email@exemple.com"
```

> [!tip] Quel algorithme choisir ?
> 
> - **ED25519** : Plus moderne, plus rapide, clés plus courtes, recommandé
> - **RSA 4096** : Compatible avec les systèmes plus anciens
> - Évitez DSA et ECDSA pour des raisons de sécurité

### Processus interactif

Lors de l'exécution de `ssh-keygen`, vous serez guidé :

```bash
$ ssh-keygen -t ed25519 -C "user@exemple.com"

# 1. Emplacement du fichier
Generating public/private ed25519 key pair.
Enter file in which to save the key (/home/user/.ssh/id_ed25519): 
# Appuyez sur Entrée pour accepter le chemin par défaut
# Ou spécifiez un chemin personnalisé : /home/user/.ssh/id_ed25519_perso

# 2. Passphrase (phrase de passe)
Enter passphrase (empty for no passphrase): 
# Entrez une passphrase FORTE ou laissez vide (déconseillé pour la sécurité)

# 3. Confirmation
Enter same passphrase again: 

# 4. Confirmation de création
Your identification has been saved in /home/user/.ssh/id_ed25519
Your public key has been saved in /home/user/.ssh/id_ed25519.pub
The key fingerprint is:
SHA256:ABC123... user@exemple.com
```

> [!warning] Importance de la passphrase La passphrase protège votre clé privée. Si quelqu'un vole votre fichier de clé privée :
> 
> - **Avec passphrase** : Il ne pourra pas l'utiliser sans la passphrase
> - **Sans passphrase** : Il aura un accès immédiat à tous vos serveurs
> 
> Utilisez TOUJOURS une passphrase pour les environnements de production.

### Options avancées de ssh-keygen

```bash
# Spécifier un nom de fichier personnalisé
ssh-keygen -t ed25519 -f ~/.ssh/id_prod_server -C "serveur-production"

# Générer sans interaction (automatisation)
ssh-keygen -t ed25519 -f ~/.ssh/id_auto -N "" -C "clé-auto"
# -N "" : passphrase vide

# Afficher l'empreinte d'une clé existante
ssh-keygen -lf ~/.ssh/id_ed25519.pub

# Changer la passphrase d'une clé existante
ssh-keygen -p -f ~/.ssh/id_ed25519
```

### Structure des fichiers générés

Après la génération, vous obtenez **deux fichiers** :

```bash
~/.ssh/
├── id_ed25519      # ⚠️ CLÉ PRIVÉE - À PROTÉGER ABSOLUMENT
└── id_ed25519.pub  # ✅ Clé publique - Peut être partagée
```

> [!example] Contenu des fichiers
> 
> **Clé privée** (`id_ed25519`) :
> 
> ```
> -----BEGIN OPENSSH PRIVATE KEY-----
> b3BlbnNzaC1rZXktdjEAAAAACmFlczI1Ni1jdHIAAAAGYmNyeXB0AAAAGAAAABCJ...
> (très long, à ne JAMAIS partager)
> -----END OPENSSH PRIVATE KEY-----
> ```
> 
> **Clé publique** (`id_ed25519.pub`) :
> 
> ```
> ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKj8... user@exemple.com
> ```

---

## 📤 Copie de la clé publique

### Méthode automatique : ssh-copy-id

`ssh-copy-id` est l'outil le plus simple pour copier votre clé publique sur un serveur distant.

```bash
# Syntaxe de base
ssh-copy-id utilisateur@serveur.com

# Avec un port personnalisé
ssh-copy-id -p 2222 utilisateur@serveur.com

# Avec une clé spécifique
ssh-copy-id -i ~/.ssh/id_ed25519.pub utilisateur@serveur.com

# Combinaison : clé spécifique + port personnalisé
ssh-copy-id -i ~/.ssh/id_rsa.pub -p 2222 utilisateur@serveur.com
```

> [!info] Ce que fait ssh-copy-id
> 
> 1. Se connecte au serveur distant (demande le mot de passe)
> 2. Crée le répertoire `~/.ssh` s'il n'existe pas
> 3. Ajoute votre clé publique au fichier `~/.ssh/authorized_keys`
> 4. Configure les permissions correctes automatiquement

### Exemple d'utilisation

```bash
$ ssh-copy-id admin@192.168.1.100

/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "/home/user/.ssh/id_ed25519.pub"
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s)
admin@192.168.1.100's password: [tapez le mot de passe]

Number of key(s) added: 1

Now try logging into the machine, with:   "ssh 'admin@192.168.1.100'"
and check to make sure that only the key(s) you wanted were added.
```

> [!tip] Astuce Après avoir copié votre clé, testez immédiatement la connexion sans fermer votre session actuelle. Si ça ne fonctionne pas, vous pourrez corriger le problème sans être bloqué.

### Copie vers plusieurs serveurs

```bash
# Script pour copier vers plusieurs serveurs
for server in serveur1.com serveur2.com serveur3.com; do
    echo "Copie vers $server..."
    ssh-copy-id user@$server
done
```

---

## ⚙️ Configuration manuelle

Parfois, `ssh-copy-id` n'est pas disponible ou ne fonctionne pas. Voici comment procéder manuellement.

### Méthode 1 : Une seule commande

```bash
# Copier la clé publique directement dans authorized_keys
cat ~/.ssh/id_ed25519.pub | ssh utilisateur@serveur.com "mkdir -p ~/.ssh && cat >> ~/.ssh/authorized_keys"
```

> [!info] Décortication de la commande
> 
> - `cat ~/.ssh/id_ed25519.pub` : Affiche le contenu de votre clé publique
> - `|` : Pipe, envoie le résultat à la commande suivante
> - `ssh utilisateur@serveur.com "..."` : Exécute les commandes sur le serveur distant
> - `mkdir -p ~/.ssh` : Crée le répertoire .ssh s'il n'existe pas (-p évite l'erreur si déjà existant)
> - `cat >> ~/.ssh/authorized_keys` : Ajoute le contenu à la fin du fichier authorized_keys

### Méthode 2 : Étape par étape

#### Sur votre machine locale

```bash
# 1. Afficher et copier votre clé publique
cat ~/.ssh/id_ed25519.pub

# Résultat à copier (exemple) :
# ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKj8... user@exemple.com
```

#### Sur le serveur distant

```bash
# 2. Se connecter au serveur
ssh utilisateur@serveur.com

# 3. Créer le répertoire .ssh s'il n'existe pas
mkdir -p ~/.ssh

# 4. Éditer le fichier authorized_keys
nano ~/.ssh/authorized_keys
# ou
vim ~/.ssh/authorized_keys

# 5. Coller votre clé publique (une clé par ligne)
# IMPORTANT : Chaque clé doit être sur UNE SEULE ligne

# 6. Sauvegarder et quitter
# Nano : Ctrl+X, puis Y, puis Entrée
# Vim : Appuyez sur Échap, puis tapez :wq et Entrée
```

### Méthode 3 : Via un serveur web ou FTP

Si SSH n'accepte que les mots de passe et que vous n'y avez pas encore accès :

```bash
# 1. Copier la clé via FTP/SFTP
scp ~/.ssh/id_ed25519.pub utilisateur@serveur.com:/tmp/ma_cle.pub

# 2. Sur le serveur, l'ajouter à authorized_keys
ssh utilisateur@serveur.com
cat /tmp/ma_cle.pub >> ~/.ssh/authorized_keys
rm /tmp/ma_cle.pub  # Nettoyer
```

### Structure du fichier authorized_keys

```bash
# Format du fichier ~/.ssh/authorized_keys

# Exemple avec plusieurs clés
ssh-ed25519 AAAAC3Nza... user@laptop "Clé de mon laptop"
ssh-rsa AAAAB3NzaC... user@desktop "Clé de mon PC bureau"
ssh-ed25519 AAAAC3Nza... admin@work "Clé professionnelle"

# Options avancées (optionnel)
from="192.168.1.*" ssh-ed25519 AAAAC3... user@laptop "Restreint aux IP locales"
command="rsync --server" ssh-rsa AAAAB3... backup@server "Uniquement pour rsync"
```

> [!warning] Attention au format
> 
> - Une clé = une ligne complète
> - Pas de retours à la ligne à l'intérieur d'une clé
> - Pas de lignes vides inutiles
> - Les commentaires commencent par #

---

## 🔒 Permissions des fichiers

Les permissions correctes sont **CRITIQUES** pour la sécurité SSH. Si elles sont incorrectes, SSH **refusera** d'utiliser les clés.

### Permissions requises

|Fichier/Répertoire|Permissions|Numérique|Propriétaire|
|---|---|---|---|
|`~/.ssh/`|`drwx------`|`700`|Utilisateur uniquement|
|`~/.ssh/id_ed25519` (privée)|`-rw-------`|`600`|Utilisateur uniquement|
|`~/.ssh/id_ed25519.pub` (publique)|`-rw-r--r--`|`644`|Utilisateur (lecture pour tous OK)|
|`~/.ssh/authorized_keys`|`-rw-------`|`600`|Utilisateur uniquement|
|`~/.ssh/config`|`-rw-------`|`600`|Utilisateur uniquement|

### Commandes pour corriger les permissions

#### Sur votre machine locale

```bash
# Corriger les permissions du répertoire .ssh
chmod 700 ~/.ssh

# Corriger la clé privée (TRÈS IMPORTANT)
chmod 600 ~/.ssh/id_ed25519

# Corriger la clé publique
chmod 644 ~/.ssh/id_ed25519.pub

# Tout corriger d'un coup
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_*
chmod 644 ~/.ssh/*.pub
```

#### Sur le serveur distant

```bash
# Se connecter au serveur
ssh utilisateur@serveur.com

# Corriger les permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys

# Vérifier le résultat
ls -la ~/.ssh
# Résultat attendu :
# drwx------  2 user user 4096 Dec 15 10:00 .
# -rw-------  1 user user  564 Dec 15 10:00 authorized_keys
```

> [!warning] Erreurs fréquentes Si les permissions sont trop ouvertes, vous verrez des erreurs comme :
> 
> ```
> @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
> @         WARNING: UNPROTECTED PRIVATE KEY FILE!      @
> @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
> Permissions 0644 for '/home/user/.ssh/id_ed25519' are too open.
> ```

### Script de vérification

```bash
#!/bin/bash
# Vérifier les permissions SSH

echo "🔍 Vérification des permissions SSH..."

# Vérifier ~/.ssh
if [ -d ~/.ssh ]; then
    perm=$(stat -c %a ~/.ssh)
    if [ "$perm" = "700" ]; then
        echo "✅ ~/.ssh : OK (700)"
    else
        echo "❌ ~/.ssh : $perm (devrait être 700)"
        echo "   Correction : chmod 700 ~/.ssh"
    fi
fi

# Vérifier les clés privées
for key in ~/.ssh/id_*; do
    if [[ -f "$key" ]] && [[ ! "$key" =~ \.pub$ ]]; then
        perm=$(stat -c %a "$key")
        if [ "$perm" = "600" ]; then
            echo "✅ $key : OK (600)"
        else
            echo "❌ $key : $perm (devrait être 600)"
            echo "   Correction : chmod 600 $key"
        fi
    fi
done

# Vérifier authorized_keys
if [ -f ~/.ssh/authorized_keys ]; then
    perm=$(stat -c %a ~/.ssh/authorized_keys)
    if [ "$perm" = "600" ]; then
        echo "✅ ~/.ssh/authorized_keys : OK (600)"
    else
        echo "❌ ~/.ssh/authorized_keys : $perm (devrait être 600)"
        echo "   Correction : chmod 600 ~/.ssh/authorized_keys"
    fi
fi
```

### Propriétaire des fichiers

```bash
# Vérifier le propriétaire
ls -l ~/.ssh

# Si besoin, changer le propriétaire (en root ou avec sudo)
sudo chown -R utilisateur:utilisateur ~/.ssh
```

> [!tip] Conseil de sécurité Le répertoire personnel (`/home/utilisateur`) doit également avoir des permissions correctes :
> 
> ```bash
> # Le home ne doit pas être accessible en écriture par le groupe ou autres
> chmod 755 ~
> # ou plus strict :
> chmod 750 ~
> ```

---

## ⚠️ Pièges courants

### 1. Clé ajoutée mais connexion impossible

**Symptôme** : La connexion demande toujours le mot de passe.

**Causes possibles** :

```bash
# Vérifier les permissions sur le serveur
ssh utilisateur@serveur.com "ls -la ~/.ssh"

# Vérifier que la clé est bien dans authorized_keys
ssh utilisateur@serveur.com "cat ~/.ssh/authorized_keys"

# Vérifier les logs SSH du serveur (sur le serveur)
sudo tail -f /var/log/auth.log
# ou
sudo journalctl -u ssh -f
```

> [!warning] Problèmes fréquents
> 
> - Permissions incorrectes (voir section précédente)
> - Clé publique mal copiée (retour à la ligne au milieu)
> - Mauvais utilisateur (clé copiée pour user1, connexion en user2)
> - SELinux activé (nécessite `restorecon -R ~/.ssh`)

### 2. Plusieurs clés SSH

Si vous avez plusieurs clés pour différents serveurs :

```bash
# Spécifier quelle clé utiliser lors de la connexion
ssh -i ~/.ssh/id_prod_server utilisateur@prod.serveur.com

# Ou configurer dans ~/.ssh/config (voir partie configuration SSH)
```

### 3. Passphrase oubliée

> [!warning] Impossible à récupérer Si vous oubliez votre passphrase, il est **impossible** de la récupérer. Vous devrez :
> 
> 1. Générer une nouvelle paire de clés
> 2. Copier la nouvelle clé publique sur tous vos serveurs
> 3. Supprimer l'ancienne clé

### 4. Clé privée compromise

Si votre clé privée est compromise ou volée :

```bash
# 1. Sur le serveur, retirer immédiatement la clé publique
ssh serveur.com
nano ~/.ssh/authorized_keys
# Supprimer la ligne correspondante

# 2. Sur votre machine locale, supprimer la clé compromise
rm ~/.ssh/id_compromised*

# 3. Générer une nouvelle paire
ssh-keygen -t ed25519 -C "nouvelle-cle-securisee"

# 4. Copier la nouvelle clé sur vos serveurs
ssh-copy-id utilisateur@serveur.com
```

### 5. Trop de tentatives d'authentification

**Symptôme** : `Too many authentication failures`

**Cause** : Vous avez trop de clés dans `~/.ssh/` et SSH essaie toutes les clés.

**Solution** :

```bash
# Limiter les clés à essayer
ssh -o IdentitiesOnly=yes -i ~/.ssh/id_specifique utilisateur@serveur.com

# Ou configurer dans ~/.ssh/config
```

### 6. Agent SSH et ssh-add

Si vous utilisez une passphrase, vous devez la taper à chaque connexion. L'agent SSH mémorise temporairement votre clé déverrouillée.

```bash
# Démarrer l'agent SSH (généralement déjà actif)
eval $(ssh-agent)

# Ajouter votre clé à l'agent
ssh-add ~/.ssh/id_ed25519
# Entrez votre passphrase une fois

# Vérifier les clés chargées
ssh-add -l

# Maintenant, connexions sans retaper la passphrase
ssh utilisateur@serveur.com
```

> [!tip] Astuce pour GNOME/KDE Les environnements de bureau modernes lancent automatiquement un agent SSH et vous demandent la passphrase via une fenêtre graphique lors de la première utilisation.

### 7. Désactiver l'authentification par mot de passe

Une fois que l'authentification par clés fonctionne, sécurisez davantage en désactivant les mots de passe (sur le serveur) :

```bash
# ⚠️ ATTENTION : À faire SEULEMENT après avoir testé les clés

# Sur le serveur, éditer la configuration SSH
sudo nano /etc/ssh/sshd_config

# Modifier ces lignes :
PasswordAuthentication no
ChallengeResponseAuthentication no
UsePAM no

# Redémarrer SSH
sudo systemctl restart sshd
```

> [!warning] Risque de blocage Ne désactivez JAMAIS l'authentification par mot de passe avant d'avoir :
> 
> 1. Testé que l'authentification par clés fonctionne
> 2. Gardé une session SSH ouverte pour corriger en cas de problème
> 3. Un moyen alternatif d'accès (console physique, KVM, etc.)

---

## 🎯 Bonnes pratiques récapitulatives

|Pratique|Détail|
|---|---|
|🔐 **Passphrase forte**|Toujours protéger les clés privées par passphrase|
|🗂️ **Organisation**|Une clé par usage (perso, pro, serveur spécifique)|
|🔒 **Permissions strictes**|700 pour .ssh, 600 pour clés privées et authorized_keys|
|📦 **Sauvegarde**|Sauvegarder les clés privées dans un endroit sécurisé|
|🔄 **Rotation**|Renouveler les clés tous les 1-2 ans|
|🚫 **Jamais partager**|Ne JAMAIS partager la clé privée|
|✅ **Tester avant**|Toujours tester avant de désactiver les mots de passe|
|🧹 **Nettoyage**|Supprimer les clés publiques inutilisées de authorized_keys|