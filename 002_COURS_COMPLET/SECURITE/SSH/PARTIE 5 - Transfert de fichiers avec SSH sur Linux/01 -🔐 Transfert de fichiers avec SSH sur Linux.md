

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

## 🚀 Introduction à SCP

**SCP (Secure Copy Protocol)** est un outil en ligne de commande qui permet de transférer des fichiers de manière sécurisée entre un client local et un serveur distant, ou entre deux serveurs distants. Il utilise le protocole SSH pour chiffrer les données pendant le transfert.

> [!info] Pourquoi utiliser SCP ?
> 
> - **Sécurité** : Toutes les données sont chiffrées durant le transfert
> - **Simplicité** : Syntaxe proche de la commande `cp` standard
> - **Authentification** : Utilise les mêmes mécanismes d'authentification que SSH (mot de passe, clés)
> - **Universalité** : Disponible sur tous les systèmes UNIX/Linux

> [!warning] À savoir SCP est considéré comme obsolète par OpenSSH depuis 2019. Bien qu'il reste largement utilisé et fonctionnel, `sftp` ou `rsync` sont recommandés pour les nouveaux projets. Cependant, SCP reste pertinent pour sa simplicité et sa compatibilité universelle.

---

## 📝 Syntaxe de base

La syntaxe générale de SCP suit ce modèle :

```bash
scp [options] source destination
```

Les chemins peuvent être locaux ou distants. Un chemin distant suit le format :

```bash
utilisateur@hôte:chemin/vers/fichier
```

> [!example] Décomposition d'un chemin distant Dans `user@192.168.1.10:/home/user/document.txt` :
> 
> - `user` : nom d'utilisateur sur le serveur distant
> - `192.168.1.10` : adresse IP ou nom de domaine du serveur
> - `/home/user/document.txt` : chemin absolu du fichier sur le serveur

### Format général

|Élément|Description|Exemple|
|---|---|---|
|Utilisateur|Compte SSH sur le serveur|`john`, `admin`|
|Hôte|Adresse du serveur|`192.168.1.10`, `example.com`|
|Chemin|Emplacement du fichier|`/home/user/file.txt`, `~/documents/`|

---

## 📤 Copie de fichier local vers distant

Cette opération permet d'envoyer un fichier depuis votre machine locale vers un serveur distant.

### Syntaxe

```bash
scp fichier_local utilisateur@hôte_distant:chemin_destination
```

### Exemples pratiques

```bash
# Copier un fichier vers le home directory de l'utilisateur distant
scp document.pdf user@192.168.1.10:~

# Copier vers un répertoire spécifique avec chemin absolu
scp rapport.docx admin@serveur.example.com:/var/www/documents/

# Copier en renommant le fichier
scp config.yaml user@192.168.1.10:~/backup/config_backup.yaml

# Utiliser une adresse IPv6
scp photo.jpg user@[2001:db8::1]:~/images/
```

> [!tip] Astuce : Chemin relatif vs absolu
> 
> - Si vous omettez le chemin après `:`, le fichier sera copié dans le home directory de l'utilisateur distant
> - Un chemin commençant par `/` est absolu, `~` fait référence au home directory
> - Sans `/` ni `~`, le chemin est relatif au home directory

### Cas d'usage courants

**Déploiement de configuration** : Envoyer un fichier de configuration vers un serveur

```bash
scp nginx.conf root@webserver.com:/etc/nginx/sites-available/
```

**Sauvegarde de documents** : Copier des fichiers importants vers un serveur de backup

```bash
scp contrat_important.pdf backup@nas.local:~/archives/2024/
```

**Upload de contenu web** : Mettre en ligne des fichiers sur un serveur web

```bash
scp index.html webmaster@site.com:/var/www/html/
```

---

## 📥 Copie de fichier distant vers local

Cette opération permet de récupérer un fichier depuis un serveur distant vers votre machine locale.

### Syntaxe

```bash
scp utilisateur@hôte_distant:chemin_fichier_distant destination_locale
```

### Exemples pratiques

```bash
# Télécharger un fichier dans le répertoire courant
scp user@192.168.1.10:~/rapport.pdf .

# Télécharger vers un répertoire spécifique
scp admin@serveur.com:/var/log/application.log ~/logs/

# Télécharger et renommer
scp user@192.168.1.10:~/backup.tar.gz ~/downloads/backup_2024.tar.gz

# Utiliser un chemin avec espaces (échappement)
scp user@192.168.1.10:"~/Mon\ Dossier/fichier.txt" ~/documents/
```

> [!warning] Attention aux chemins avec espaces Les chemins contenant des espaces doivent être :
> 
> - Entourés de guillemets doubles `""`
> - Les espaces échappés avec `\`
> 
> Exemple : `"~/Mes\ Documents/fichier.pdf"`

### Cas d'usage courants

**Récupération de logs** : Télécharger des fichiers journaux pour analyse

```bash
scp root@webserver:/var/log/nginx/error.log ~/analyse/logs/
```

**Téléchargement de sauvegardes** : Récupérer une sauvegarde de base de données

```bash
scp admin@dbserver:/backups/db_dump_2024.sql ~/backups/
```

**Récupération de certificats** : Copier des certificats SSL depuis un serveur

```bash
scp root@webserver:/etc/ssl/certs/mydomain.crt ~/certificates/
```

---

## 📁 Copie récursive de répertoires

Pour copier un répertoire complet avec tous ses sous-répertoires et fichiers, utilisez l'option `-r` (récursif).

### Syntaxe

```bash
# Local vers distant
scp -r répertoire_local/ utilisateur@hôte:destination/

# Distant vers local
scp -r utilisateur@hôte:répertoire_distant/ destination_locale/
```

### Exemples pratiques

```bash
# Copier un projet complet vers un serveur
scp -r ~/projets/mon_site/ user@webserver:/var/www/

# Télécharger un répertoire de configuration
scp -r admin@serveur:/etc/apache2/ ~/backup/apache_config/

# Copier un dossier avec son contenu en préservant la structure
scp -r ~/documents/rapports/ backup@nas:~/archives/2024/

# Copier plusieurs répertoires (nécessite l'option -r pour chacun)
scp -r ~/dossier1/ ~/dossier2/ user@serveur:~/destination/
```

> [!info] Comportement de la copie récursive
> 
> - Tous les fichiers et sous-répertoires sont copiés
> - La structure des répertoires est préservée
> - Les permissions des fichiers sont conservées par défaut
> - Le slash `/` final dans le chemin source n'affecte pas le comportement (contrairement à `rsync`)

### Cas d'usage courants

**Déploiement d'application** : Envoyer un projet web complet

```bash
scp -r ~/mon_app/ deploy@production:/var/www/applications/
```

**Sauvegarde de configuration système** : Copier des répertoires de configuration

```bash
scp -r root@serveur:/etc/nginx/ ~/backups/config/nginx_backup/
```

**Synchronisation de documentation** : Transférer une arborescence de documents

```bash
scp -r ~/documentation/ docs@wiki-server:~/public_html/docs/
```

> [!tip] Alternative pour les gros répertoires Pour des répertoires volumineux ou des synchronisations fréquentes, considérez `rsync` qui est plus efficace car il ne transfère que les fichiers modifiés.

---

## ⚙️ Options courantes

SCP offre plusieurs options pour personnaliser le comportement du transfert. Voici les plus utilisées.

### Option `-P` : Spécifier le port SSH

Par défaut, SCP utilise le port 22. Si votre serveur SSH écoute sur un port différent, utilisez `-P` (majuscule).

```bash
# Connexion sur le port 2222
scp -P 2222 fichier.txt user@serveur:~/

# Combinaison avec chemin complet
scp -P 8022 document.pdf admin@192.168.1.10:/home/admin/documents/
```

> [!warning] Attention : P majuscule C'est `-P` (majuscule) pour SCP, contrairement à SSH qui utilise `-p` (minuscule). C'est une source d'erreur fréquente !

### Option `-r` : Copie récursive

Permet de copier des répertoires avec tout leur contenu (déjà détaillé dans la section précédente).

```bash
# Copie récursive d'un répertoire
scp -r ~/mon_dossier/ user@serveur:~/backup/
```

### Option `-p` : Préserver les métadonnées

Conserve les horodatages (modification, accès) et les permissions des fichiers originaux.

```bash
# Copie en préservant les attributs
scp -p fichier.conf user@serveur:~/config/

# Combinaison avec récursif pour un répertoire complet
scp -rp ~/projet/ user@serveur:~/backup/
```

> [!info] Différence avec/sans `-p` **Sans `-p`** : Le fichier copié aura la date/heure du moment du transfert
> 
> **Avec `-p`** : Le fichier copié conservera sa date de modification originale

**Cas d'usage** : Utile pour les sauvegardes où vous voulez conserver l'historique exact des modifications.

### Option `-v` : Mode verbeux

Affiche des informations détaillées sur le déroulement du transfert (utile pour le débogage).

```bash
# Mode verbeux pour voir la progression
scp -v fichier.zip user@serveur:~/

# Triple verbosité pour encore plus de détails
scp -vvv gros_fichier.tar.gz user@serveur:~/
```

**Informations affichées** :

- Négociation de connexion SSH
- Algorithmes de chiffrement utilisés
- Progression du transfert
- Erreurs éventuelles détaillées

> [!example] Exemple de sortie en mode verbeux
> 
> ```
> Executing: program /usr/bin/ssh host serveur, user user, command scp -v -t ~/
> OpenSSH_8.9p1, OpenSSL 3.0.2 15 Mar 2022
> debug1: Reading configuration data /etc/ssh/ssh_config
> debug1: Connecting to serveur [192.168.1.10] port 22.
> debug1: Connection established.
> Sending file modes: C0644 1024 fichier.txt
> fichier.txt                  100% 1024     1.0KB/s   00:01
> ```

### Option `-C` : Compression

Active la compression des données durant le transfert (utile pour les connexions lentes).

```bash
# Transfert avec compression
scp -C gros_fichier.log user@serveur:~/

# Compression + récursif pour un répertoire
scp -rC ~/documents/ user@serveur:~/backup/
```

> [!tip] Quand utiliser la compression ?
> 
> - ✅ **Utile** : Connexions lentes, fichiers texte non compressés (logs, code source)
> - ❌ **Inutile** : Fichiers déjà compressés (.zip, .jpg, .mp4), connexions rapides (LAN)
> - ⚠️ **Impact** : Augmente l'utilisation CPU mais réduit la bande passante

### Option `-i` : Spécifier une clé privée

Utilise une clé SSH spécifique pour l'authentification (au lieu de la clé par défaut).

```bash
# Utiliser une clé privée spécifique
scp -i ~/.ssh/id_rsa_production fichier.txt user@serveur:~/

# Combinaison avec port et récursif
scp -i ~/.ssh/cle_backup -P 2222 -r ~/data/ backup@nas:~/
```

**Cas d'usage** : Vous avez plusieurs clés SSH pour différents serveurs ou environnements.

### Option `-q` : Mode silencieux

Supprime la barre de progression et les messages (utile dans les scripts).

```bash
# Transfert silencieux
scp -q fichier.txt user@serveur:~/

# Idéal pour les scripts automatisés
scp -q backup.tar.gz user@serveur:~/backups/
```

### Combinaison d'options

Vous pouvez combiner plusieurs options :

```bash
# Port personnalisé + récursif + préserver attributs + verbeux
scp -P 2222 -rp -v ~/mon_projet/ user@serveur:~/deploy/

# Compression + clé spécifique + silencieux
scp -C -i ~/.ssh/id_deploy -q app.tar.gz deploy@prod:~/releases/

# Toutes les options principales
scp -P 8022 -rpCv -i ~/.ssh/key ~/data/ user@backup-server:~/archives/
```

### Tableau récapitulatif des options

|Option|Description|Exemple|
|---|---|---|
|`-P port`|Spécifie le port SSH|`scp -P 2222 file.txt user@host:~`|
|`-r`|Copie récursive (répertoires)|`scp -r folder/ user@host:~`|
|`-p`|Préserve dates et permissions|`scp -p file.conf user@host:~`|
|`-v`|Mode verbeux (debug)|`scp -v file.log user@host:~`|
|`-C`|Active la compression|`scp -C largefile.txt user@host:~`|
|`-i`|Spécifie la clé privée|`scp -i ~/.ssh/key file user@host:~`|
|`-q`|Mode silencieux|`scp -q backup.tar user@host:~`|
|`-l`|Limite la bande passante (Kbit/s)|`scp -l 1000 file user@host:~`|

---

## ⚠️ Pièges courants et bonnes pratiques

### Pièges fréquents

**1. Confusion entre `-p` et `-P`**

```bash
# ❌ ERREUR : -p pour le port (ne fonctionne pas)
scp -p 2222 fichier.txt user@serveur:~/

# ✅ CORRECT : -P majuscule pour le port
scp -P 2222 fichier.txt user@serveur:~/

# ℹ️ -p minuscule sert à préserver les attributs
scp -p fichier.txt user@serveur:~/
```

**2. Oubli de l'option `-r` pour les répertoires**

```bash
# ❌ ERREUR : copie d'un répertoire sans -r
scp mon_dossier/ user@serveur:~/
# Résultat : erreur "not a regular file"

# ✅ CORRECT : ajouter -r pour la récursion
scp -r mon_dossier/ user@serveur:~/
```

**3. Chemins avec espaces mal échappés**

```bash
# ❌ ERREUR : espace non géré
scp user@serveur:~/Mon Dossier/fichier.txt .

# ✅ CORRECT : guillemets + échappement
scp user@serveur:"~/Mon\ Dossier/fichier.txt" .

# ✅ ALTERNATIVE : tout entre guillemets
scp "user@serveur:~/Mon Dossier/fichier.txt" .
```

**4. Permissions insuffisantes sur la destination**

```bash
# ❌ Erreur si vous n'avez pas les droits d'écriture
scp fichier.txt user@serveur:/etc/config/

# ✅ Solution : utiliser sudo sur le serveur (voir bonnes pratiques)
```

**5. Confusion dans l'ordre source/destination**

```bash
# ❌ ERREUR : ordre inversé
scp user@serveur:~/destination/ fichier_local.txt

# ✅ CORRECT : source puis destination
scp fichier_local.txt user@serveur:~/destination/
```

> [!warning] Rappel de syntaxe C'est toujours : `scp SOURCE DESTINATION`
> 
> Comme pour la commande `cp` standard.

### Bonnes pratiques

**1. Utiliser des clés SSH plutôt que des mots de passe**

```bash
# Configuration recommandée avec clé SSH
scp -i ~/.ssh/id_rsa_serveur fichier.txt user@serveur:~/

# Avantages : plus sécurisé, pas besoin de taper le mot de passe
```

**2. Vérifier la destination avant un transfert important**

```bash
# Utiliser d'abord SSH pour vérifier le chemin
ssh user@serveur "ls -la ~/destination/"

# Puis effectuer le transfert SCP
scp fichier_important.tar.gz user@serveur:~/destination/
```

**3. Utiliser le mode verbeux en cas de problème**

```bash
# Debug avec -v pour comprendre où ça bloque
scp -v fichier.txt user@serveur:~/

# Triple verbosité pour plus de détails
scp -vvv fichier.txt user@serveur:~/
```

**4. Limiter la bande passante pour ne pas saturer la connexion**

```bash
# Limiter à 1000 Kbit/s (≈ 125 Ko/s)
scp -l 1000 gros_fichier.iso user@serveur:~/

# Utile en production pour ne pas impacter les autres services
```

**5. Tester d'abord avec des petits fichiers**

```bash
# Test rapide de connectivité
echo "test" > test.txt
scp test.txt user@serveur:~/

# Si ça fonctionne, procéder avec les vrais fichiers
scp -r ~/gros_projet/ user@serveur:~/
```

**6. Utiliser des chemins absolus pour éviter les ambiguïtés**

```bash
# ✅ Chemin absolu : pas de doute sur la destination
scp backup.tar.gz user@serveur:/home/user/backups/

# ⚠️ Chemin relatif : dépend du répertoire courant de l'utilisateur distant
scp backup.tar.gz user@serveur:~/backups/
```

**7. Copier vers des répertoires nécessitant des privilèges élevés**

Pour copier vers `/etc`, `/var`, ou d'autres répertoires système :

```bash
# Méthode 1 : Copier d'abord dans le home, puis déplacer via SSH
scp config.conf user@serveur:~/
ssh user@serveur "sudo mv ~/config.conf /etc/myapp/"

# Méthode 2 : Utiliser un pipe avec tar (plus avancé)
tar czf - fichier.txt | ssh user@serveur "sudo tar xzf - -C /etc/config/"
```

> [!tip] Astuce : Vérification avant transfert Utilisez l'option `--dry-run` avec `rsync` pour simuler le transfert avant de l'exécuter réellement. SCP n'a pas cette option, c'est une autre raison de privilégier `rsync` pour les opérations complexes.

**8. Gestion des transferts interrompus**

```bash
# SCP ne reprend PAS les transferts interrompus
# Pour les gros fichiers, préférez rsync qui peut reprendre
rsync -avz --progress fichier.iso user@serveur:~/

# Ou utilisez screen/tmux pour maintenir la session
screen
scp gros_fichier.tar.gz user@serveur:~/
# Détacher avec Ctrl+A puis D
```

**9. Sécurité : Vérifier les empreintes SSH**

```bash
# Lors de la première connexion, vérifiez l'empreinte
# Exemple de message :
# The authenticity of host 'serveur (192.168.1.10)' can't be established.
# ED25519 key fingerprint is SHA256:abc123...
# Are you sure you want to continue connecting (yes/no)?

# ✅ Vérifiez cette empreinte avec votre administrateur
# ❌ Ne tapez pas "yes" automatiquement
```

**10. Organisation des fichiers de configuration SSH**

Créez un fichier `~/.ssh/config` pour simplifier vos commandes :

```bash
# Contenu de ~/.ssh/config
Host monserveur
    HostName 192.168.1.10
    User admin
    Port 2222
    IdentityFile ~/.ssh/id_rsa_serveur

# Puis utilisez simplement :
scp fichier.txt monserveur:~/
# Au lieu de :
scp -P 2222 -i ~/.ssh/id_rsa_serveur fichier.txt admin@192.168.1.10:~/
```

### Alternatives modernes à SCP

> [!info] Pourquoi chercher des alternatives ? OpenSSH considère SCP comme obsolète depuis 2019 en raison de limitations dans le protocole sous-jacent. Les alternatives suivantes sont recommandées :

**SFTP (SSH File Transfer Protocol)**

- Plus de fonctionnalités (navigation, suppression de fichiers distants)
- Protocole plus robuste
- Mode interactif disponible

**Rsync over SSH**

- Transfert incrémental (ne copie que les différences)
- Reprise des transferts interrompus
- Exclusion de fichiers avec patterns
- Idéal pour synchronisations régulières

Cependant, **SCP reste pertinent** pour sa simplicité et sa disponibilité universelle dans les scripts simples.

---

## 🎯 Résumé des commandes essentielles

```bash
# Local → Distant
scp fichier.txt user@host:~/

# Distant → Local
scp user@host:~/fichier.txt .

# Répertoire complet
scp -r dossier/ user@host:~/

# Avec options courantes
scp -P 2222 -rp dossier/ user@host:~/backup/

# Debug en cas de problème
scp -v fichier.txt user@host:~/
```

> [!tip] Astuce finale Créez des alias dans votre `~/.bashrc` pour les serveurs fréquemment utilisés :
> 
> ```bash
> alias scpprod='scp -P 2222 -i ~/.ssh/prod_key'
> alias scpdev='scp -P 22 -i ~/.ssh/dev_key'
> ```
> 
> Utilisation : `scpprod fichier.txt user@prod-server:~/`