---
title: "Atelier - Connexion SSH par clés de chiffrement - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2924/pages/13823"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Sécurité réseau

## Atelier - Connexion SSH par clés de chiffrement

Moyen

2h

Auto-validation

Sécurité réseau

## Atelier - Connexion SSH par clés de chiffrement

Prérequis:

- 3 VM dans le même réseau interne:
- 1 serveur Debian
- 1 client Ubuntu
- 1 client Windows 10

## 1\. Définition

Une connexion SSH (Secure Shell) est un protocole réseau qui permet une communication sécurisée entre deux systèmes informatiques. Voici ses caractéristiques principales et son utilité:

- **Sécurité**:  
	SSH fournit un canal de communication sécurisé en se basant sur un réseau quelconque (non sécurisé). Les données transmises sont chiffrées, ce qui protège contre l'écoute clandestine. Il permet l'authentification du serveur et du client et garanti l'intégrité des données transmises.
- **Authentification**:  
	Plusieurs méthodes existent: utilisation de mots de passe, de clés publiques/privées, ou de certificat.

## 2\. Utilisation

Une connexion ssh est établie depuis un client vers un serveur.  
Dans le cas de l'authentification par clés:

- La **Clé Privée** reste sur le poste client. Elle doit être conservée secrète, car elle permet l'authentification de l'utilisateur. La clé privée **n'est jamais partagée ou transmise**.
- La **Clé Publique** est placée sur le serveur. Cette clé peut être partagée sans risque, car elle ne peut être utilisée que pour vérifier une signature produite par la clé privée correspondante.

Dans un parc avec un serveur Debian et 2 clients Windows 10 et Ubuntu:

- Le serveurs doit avoir sshd (le serveur openssh) installé et configuré
- Le client Windows 10 peut utiliser un client SSH graphique comme PuTTY, ou l'invite de commande Windows intégrée (PowerShell ou cmd)
- Le client Ubuntu utilise la commande ssh (le client openssh) dans le terminal.

## 3\. Installation et configuration du serveur ssh

Les manipulations suivantes ont lieu sur la VM serveur debian.

## a. Installation

Pour installer: `apt install openssh-server`

```shell
Note :L'installation du serveur ssh entraîne automatiquement l'installation du client ssh.

Tu peux le constater en tapant la commande apt show openssh-server et en regardant la partie Depends:.
```

Pour voir l’état du service: `systemctl status ssh`

## b. Création d'un compte de connexion ssh

Créer le compte **wilder** avec `adduser wilder`

## c. Configuration du fichier de configuration du serveur sshd

Éditer le fichier `/etc/ssh/sshd_config`.

```shell
Avant toute modification d'un fichier de configuration, la création d'une copie de sauvegarde permettant de revenir facilement a l'état initial est une excellente pratique !

Commence donc par créer une copie de sshd_config, sshd_config.bkp par exemple.
```

On peut voir en haut une ligne `Include /etc/ssh/sshd_config.d/*.conf`. Cette ligne va prendre en compte tous les fichiers \***.conf** du dossier **sshd\_config.d** et les appliquer **avant** la configuration de ce fichier.  
Pour un mot clé dans sa configuration, **sshd** ne prend en compte que la première valeur rencontrée. Comme le `Include` est présent en premier dans le fichier de configuration, c'est la configuration présente dans le dossier **sshd\_config.d** qui a la priorité sur celle présente dans le fichier **sshd\_config**.

Les fichiers de configuration annexes sont un bon moyen de personnaliser sa configuration sans modifier le fichier **sshd\_config** d'origine.

Exemple:

- Dans `/etc/ssh/sshd_config` le port par défaut est **22**
- Dans un fichier de configuration sous `/etc/ssh/sshd_config.d/` le port par défaut est 2222.  
	Dans ce cas, le port par défaut sera 2222.

Dans un fichier `/etc/ssh/sshd_config.d/local.conf` (le nom **local** pourrait être différent, seul compte le **.conf** final) dont les droits correspondent à `-rw-r--r-- root root` ajoute les lignes suivantes:

- `Port 22`
- `AllowUsers wilder`

> ⚠️ **Attention**: La casse est importante dans les fichiers de configuration. Assure toi d'écrire les directives exactement comme elles sont supposées être, en respectant les majuscules et les minuscules.

Exemple:  
Les termes `Port` ou `AllowUsers` doivent être écrit tel quel (respect de la casse)

Bonne pratique:  
On ne se connecte jamais en root!  
On ajoute donc la ligne `PermitRootLogin no`

```shell
Note :Un petit tour dans man sshd_config permet d'avoir plus d'information sur la configuration d'un serveur ssh
```

## d. Limitation du nombre de connexion avec le compte wilder

Editer le fichier `/etc/security/limits.conf`  
Ajouter la ligne `wilder hard maxlogins 1`, pour limiter le nombre de connexion pour le compte wilder à 1 simultanément.  
Redémarrer le service ssh avec `systemctl restart sshd`

## 4\. Sur le client Ubuntu

Les manipulations suivantes ont lieu sur la VM client ubuntu.

## a. Installation d'openssh

Sur Ubuntu, installe `openssh-client`.

## b. Connexion

- Faire test de connexion en **root** => échec (normal)
```bash
1
# ssh <user>@<adresseIPServeurSSH>
2
ssh -p 22 root@192.168.1.20
```
```shell
Note : Le port 22 étant le port standard pour SSH, il n'est pas indispensable de le préciser et l'option -p peut être omise.
```
- Faire test de connexion en **wilder**
```bash
1
# ssh <user>@<adresseIPServeurSSH>
2
ssh wilder@192.168.1.20
3
[...]
4
wilder@debian:~$
```

\=> connexion en wilder

Une fois sur le serveur, on peut passer en **root**:

```bash
1
wilder@debian:~$ su -
2
Mot de passe : 
3
root@debian:~#
```

## 5\. Sur Windows 10

## a. Avec Putty

Télécharger et installer le logiciel **Putty**.

Lancer Putty et dans la fenêtre:

- Mettre l'adresse IP du serveur debian dans `Host Name`
- Mettre `22` dans `Port`  
	On peut sauvegarder la session pour plus tard en mettant un nom comme `Debian` dans `Saved Sessions` et en cliquant sur `Save`.  
	A la 1ère connexion, il est demandé de valider en cliquant sur `Yes` puis mettre le login et le mot de passe d'un compte autorisé à se connecté en ssh sur le serveur, ici `wilder`.

> Vérifier que l'accès root est bien désactivé.

## b. Avec Powershell

Vérifier si OpenSSH est installé avec `Get-WindowsCapability -Online | Where-Object { Name -like "OpenSSH*"}`.  
Si non, l'installer avec `Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0`.

Se connecter avec `ssh wilder@<AdresseIPServeur>`

## 6\. Connexion SSH par clé

## a. Génération de clés sur le client Ubuntu

Générer une clé avec `ssh-keygen`:

```bash
1
wilder@CLIENT20:~$ ssh-keygen -t rsa -b 4096
2
Generating public/private rsa key pair.
3
Enter file in which to save the key (/home/wilder/.ssh/id_rsa): /home/wilder/.ssh/ubuntu_ssh
4
Enter passphrase (empty for no passphrase): 
5
Enter same passphrase again: 
6
Your identification has been saved in /home/wilder/.ssh/debssh
7
Your public key has been saved in /home/wilder/.ssh/debssh.pub
8
The key fingerprint is:
9
SHA256:4ZasHbMNQSbD9Hg88gnD6jXVND86osf/9ddK2IylQnE wilder@CLIENT20
10
The key's randomart image is:
11
+---[RSA 4096]----+
12
|     o+ o o      |
13
|     ..O o o     |
14
|      * O o E    |
15
|     . X * + .   |
16
|    . o S +   .  |
17
|   . . B O . B   |
18
|    . o = o + = .|
19
|       . . . o .o|
20
|          ... ..o|
21
+----[SHA256]-----+
22
```

La commande ci-dessus créer 2 clés sous `/home/wilder/.ssh/`:

- **ubuntu\_ssh.pub**: La clé publique
- **ubuntu\_ssh**: La clé privée

> La commande `ssh-keygen` seule crée 2 clés **id\_rsa** et **id\_rsa.pub**.

On va copier la clé **publique** sur le serveur:

```bash
1
# ssh-copy-id <user>@<adresseIPServeurSSH>
2
ssh-copy-id -p 22 -i ubuntu_ssh.pub wilder@172.16.1.20
3
/usr/bin/ssh-copy-id: INFO: Source of key(s) to be installed: "ubuntu_ssh.pub"
4
/usr/bin/ssh-copy-id: INFO: attempting to log in with the new key(s), to filter out any that are already installed
5
/usr/bin/ssh-copy-id: INFO: 1 key(s) remain to be installed -- if you are prompted now it is to install the new keys
6
wilder@172.16.1.20's password: 
7

8
Number of key(s) added: 1
9

10
Now try logging into the machine, with:   "ssh -p '22' 'wilder@172.16.1.20'"
11
and check to make sure that only the key(s) you wanted were added.
```

Vérification sur le serveur -> la clé doit être dans le fichier `/home/wilder/.ssh/authorized_keys`

> Si le dossier `.ssh` ou le fichier `authorized_keys` n'existe pas, les créer.

## b. Génération de clés sur le client Windows

- Lancer le logiciel **Puttygen** qui est installé en même temps que Putty
- Sous `Parameter` choisir **RSA** et mettre **4096** pour `Number of bits in a generated key` et `Generate`
- Cliquer sur `Generate` et déplacer le curseur de la souris dans la fenêtre du générateur de clés PuTTY en tant que générateur aléatoire, afin de générer la clé privée
- On peut mettre une passphrase (optionnel)
- Sauvegarder les clés avec les boutons `Save public|private key`

On va copier la clé **publique** sur le serveur:

- Se connecter avec Putty sur le serveur
- Editer le fichier `/home/wilder/.ssh/authorized_keys` et coller le contenu de la clé publique dedans

Modification des paramètres dans Putty:

- Aller dans `Connection` -> `SSH` -> `Auth` -> `Credentials` et mettre l'emplacement de la clé privée
- Aller dans `Connection` -> `Data` et mettre le login à utiliser sur le serveur (ici `wilder`)

## 7\. Configuration avancée

## a. Strict mode

Sur le serveur, dans le fichier `/etc/ssh/sshd_config` on peut ajouter le paramètre `StrictModes yes`.  
Dans ce cas, il faut donner les bons droits au homedir sinon l’authentification risque d’échouer:

```bash
1
chmod go-w /home/wilder/
2
chmod 700 /home/wilder/.ssh
3
chmod 600 /home/wilder/.ssh/authorized_keys
```

Relancer le service ssh avec `systemctl restart ssh`.

## b. Connexion sans mot de passe

On peut ajouter `PasswordAuthentication no` et `ChallengeResponseAuthentication no`  
pour désactiver complètment l'accès avec mot de passe.

> Dans ce cas, bien garder la clé privé!

## c. Connexion sur de multiples serveur

On peut modifiez ou créer le fichier **~/.ssh/config** et l'adapter avec l’exemple ci-dessous:

```bash
1
Host serveur1
2
  HostName serveur1.domain.tld
3
  User wilder
4
  Port 22
5
  IdentityFile /home/remi/.ssh/id_rsa
6

7
Host serveur2
8
  HostName 192.168.1.120
9
  User wilder
10
  Port 22
11
  IdentityFile /home/remi/autre_cle/private_key
```
- **HostName**: Adresse ip ou nom de domaine du serveur
- **User**: Utilisateur à utiliser en login
- **Port**: Numéro du port à utiliser
- **IdentifyFile**: Chemin vers votre clé privée à utiliser

A partir de là, on peut se connecter au serveur directement avec `ssh serveur1`

## 8\. Connexion SSH à partir de l'hôte

Configurer la carte réseau de la VM serveur en **Réseau privé hôte** ou **Pont**.  
C'est également possible en **NAT** mais il faut faire une redirection de ports.

Quête terminée le **mercredi 26 novembre 2025**