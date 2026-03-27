

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

## 🔰 Introduction à APT

APT (Advanced Package Tool) est le gestionnaire de paquets standard pour les distributions Debian et Ubuntu. Il permet d'installer, mettre à jour et supprimer des logiciels de manière automatisée en gérant les dépendances.

> [!info] Qu'est-ce qu'un paquet ? Un paquet est une archive contenant un logiciel, ses fichiers de configuration, ses dépendances et les scripts nécessaires à son installation. APT télécharge ces paquets depuis des dépôts (repositories) configurés sur votre système.

### Pourquoi utiliser APT ?

- **Gestion automatique des dépendances** : APT installe automatiquement tous les logiciels nécessaires
- **Mises à jour centralisées** : un seul outil pour maintenir tout le système à jour
- **Sécurité** : les paquets des dépôts officiels sont vérifiés et signés
- **Cohérence du système** : évite les conflits entre versions de bibliothèques

### APT vs apt-get vs apt-cache

|Commande|Usage|Particularité|
|---|---|---|
|`apt`|Usage quotidien interactif|Interface moderne, simplifiée, barre de progression|
|`apt-get`|Scripts et automatisation|Interface stable, garantie de compatibilité|
|`apt-cache`|Recherche d'informations|Spécialisé dans la consultation des métadonnées|

> [!tip] Recommandation Utilisez `apt` pour vos interactions quotidiennes en ligne de commande. Réservez `apt-get` et `apt-cache` pour vos scripts automatisés où la stabilité de l'interface est critique.

---

## 🔄 Mise à jour du système

La mise à jour d'un système Linux avec APT se fait en deux étapes principales : la mise à jour de la liste des paquets disponibles, puis l'installation des nouvelles versions.

### apt update

Cette commande synchronise la liste des paquets disponibles avec les dépôts configurés.

```bash
# Mise à jour de la liste des paquets
sudo apt update
```

> [!info] Que fait réellement apt update ?
> 
> - Contacte les dépôts listés dans `/etc/apt/sources.list`
> - Télécharge les métadonnées des paquets disponibles
> - Met à jour le cache local dans `/var/lib/apt/lists/`
> - N'installe AUCUN paquet, ne modifie pas le système

**Quand utiliser apt update :**

- Avant toute installation de paquet
- Régulièrement (quotidien ou hebdomadaire)
- Après avoir ajouté un nouveau dépôt
- Après une modification de `/etc/apt/sources.list`

```bash
# Exemple de sortie
Hit:1 http://fr.archive.ubuntu.com/ubuntu jammy InRelease
Get:2 http://fr.archive.ubuntu.com/ubuntu jammy-updates InRelease [119 kB]
Get:3 http://security.ubuntu.com/ubuntu jammy-security InRelease [110 kB]
Fetched 229 kB in 2s (114 kB/s)
Reading package lists... Done
Building dependency tree... Done
3 packages can be upgraded. Run 'apt list --upgradable' to see them.
```

### apt upgrade

Installe les nouvelles versions des paquets déjà installés sans supprimer de paquets existants.

```bash
# Mise à jour des paquets installés
sudo apt upgrade

# Avec confirmation automatique (pour scripts)
sudo apt upgrade -y
```

> [!warning] Comportement d'apt upgrade `apt upgrade` ne supprimera JAMAIS un paquet existant. Si une mise à jour nécessite la suppression d'un paquet, elle sera retenue et ne sera pas effectuée.

**Caractéristiques :**

- Installe uniquement les nouvelles versions des paquets présents
- Ne supprime jamais de paquets
- Ne résout pas les conflits complexes
- Approche conservative et sûre

```bash
# Voir les paquets qui peuvent être mis à jour
apt list --upgradable
```

### apt full-upgrade

Effectue une mise à jour complète en gérant intelligemment les dépendances, quitte à installer ou supprimer des paquets si nécessaire.

```bash
# Mise à jour complète du système
sudo apt full-upgrade

# Équivalent avec l'ancienne commande
sudo apt-get dist-upgrade
```

> [!info] Différence cruciale avec upgrade `full-upgrade` peut installer de nouveaux paquets ou supprimer des paquets existants pour résoudre des conflits de dépendances. C'est l'option à utiliser pour les changements de version majeure.

**Quand utiliser full-upgrade :**

- Lors du passage à une nouvelle version de la distribution
- Quand `apt upgrade` retient des paquets (`kept back`)
- Pour résoudre des conflits de dépendances
- Mise à jour du noyau Linux

|Critère|apt upgrade|apt full-upgrade|
|---|---|---|
|Suppression de paquets|❌ Non|✅ Si nécessaire|
|Installation de nouveaux paquets|❌ Non|✅ Si nécessaire|
|Sécurité|Plus sûr|Plus complet|
|Usage recommandé|Mises à jour régulières|Changements majeurs|

> [!tip] Workflow de mise à jour recommandé
> 
> ```bash
> # 1. Mise à jour de la liste
> sudo apt update
> 
> # 2. Vérifier ce qui peut être mis à jour
> apt list --upgradable
> 
> # 3. Mise à jour standard
> sudo apt upgrade
> 
> # 4. Si des paquets sont retenus (kept back)
> sudo apt full-upgrade
> ```

### Pièges courants avec les mises à jour

> [!warning] Erreur : Oublier sudo apt update
> 
> ```bash
> # ❌ Mauvais : installation sans mise à jour
> sudo apt install nginx
> # Risque d'installer une version obsolète !
> 
> # ✅ Bon : toujours mettre à jour d'abord
> sudo apt update
> sudo apt install nginx
> ```

> [!warning] Espace disque insuffisant Les mises à jour peuvent échouer si `/var/cache/apt/archives/` est plein. Pensez à nettoyer régulièrement avec `apt clean`.

---

## 📥 Installation et suppression de paquets

### Installation de paquets

La commande `apt install` permet d'installer un ou plusieurs paquets avec toutes leurs dépendances.

```bash
# Installation d'un paquet unique
sudo apt install nginx

# Installation de plusieurs paquets
sudo apt install nginx mysql-server php-fpm

# Installation avec confirmation automatique
sudo apt install -y nginx

# Installation d'une version spécifique
sudo apt install nginx=1.18.0-0ubuntu1
```

> [!info] Gestion automatique des dépendances Lorsque vous installez un paquet, APT résout automatiquement l'arbre de dépendances et installe tous les paquets nécessaires. Vous verrez la liste complète avant confirmation.

**Exemple de sortie lors de l'installation :**

```bash
$ sudo apt install htop
Reading package lists... Done
Building dependency tree... Done
The following NEW packages will be installed:
  htop
0 upgraded, 1 newly installed, 0 to remove and 0 not upgraded.
Need to get 125 kB of archives.
After this operation, 325 kB of additional disk space will be used.
Get:1 http://fr.archive.ubuntu.com/ubuntu jammy/main amd64 htop amd64 3.0.5-7build2 [125 kB]
Fetched 125 kB in 1s (125 kB/s)
Selecting previously unselected package htop.
(Reading database ... 185432 files and directories currently installed.)
Unpacking htop (3.0.5-7build2) ...
Setting up htop (3.0.5-7build2) ...
```

### Réinstallation de paquets

Utile quand un paquet est corrompu ou que vous voulez restaurer les fichiers de configuration par défaut.

```bash
# Réinstaller un paquet
sudo apt install --reinstall nginx

# Forcer la réinstallation même si déjà installé
sudo apt install --reinstall --force-yes nginx
```

### Suppression de paquets

APT offre plusieurs niveaux de suppression selon vos besoins.

```bash
# Suppression simple (garde les fichiers de configuration)
sudo apt remove nginx

# Suppression complète (inclut les fichiers de configuration)
sudo apt purge nginx

# Alternative avec remove
sudo apt remove --purge nginx
```

|Commande|Supprime le paquet|Supprime les configs|Supprime les dépendances orphelines|
|---|---|---|---|
|`apt remove`|✅ Oui|❌ Non|❌ Non|
|`apt purge`|✅ Oui|✅ Oui|❌ Non|
|`apt autoremove`|❌ Non|❌ Non|✅ Oui|

> [!warning] Différence entre remove et purge
> 
> - `remove` : supprime les binaires mais conserve les fichiers de configuration dans `/etc/`
> - `purge` : suppression totale incluant tous les fichiers de configuration
> 
> Utilisez `purge` si vous voulez vraiment nettoyer complètement un paquet, `remove` si vous pensez le réinstaller plus tard avec la même configuration.

**Exemples pratiques :**

```bash
# Supprimer un paquet en gardant sa configuration
sudo apt remove apache2

# Supprimer complètement apache et sa configuration
sudo apt purge apache2

# Supprimer plusieurs paquets
sudo apt remove nginx mysql-server php-fpm

# Supprimer et confirmer automatiquement
sudo apt remove -y apache2
```

### Vérification avant installation/suppression

```bash
# Simuler une installation (dry-run)
sudo apt install -s nginx
# ou
sudo apt install --dry-run nginx

# Simuler une suppression
sudo apt remove -s nginx

# Voir les détails d'un paquet avant installation
apt show nginx
```

> [!tip] Astuce : simulation avant action L'option `-s` ou `--simulate` est extrêmement utile pour voir ce qui va être modifié sans toucher au système. Utilisez-la systématiquement avant des opérations importantes.

### Gestion des paquets recommandés et suggérés

Lors de l'installation, APT peut installer des paquets supplémentaires :

- **Recommandés** : installés par défaut, fortement conseillés
- **Suggérés** : non installés par défaut, optionnels

```bash
# Installer sans les paquets recommandés
sudo apt install --no-install-recommends nginx

# Installer avec les paquets suggérés
sudo apt install --install-suggests nginx

# Voir les recommandations d'un paquet
apt show nginx | grep Recommends
```

> [!tip] Optimisation de l'espace disque Sur des serveurs ou conteneurs avec peu d'espace, utilisez `--no-install-recommends` pour installer uniquement le strict nécessaire. Attention toutefois : certaines fonctionnalités peuvent manquer.

---

## 🔍 Recherche de paquets

APT offre plusieurs méthodes pour trouver des paquets et obtenir des informations à leur sujet.

### apt search

Recherche dans les noms et descriptions de tous les paquets disponibles.

```bash
# Recherche simple
apt search nginx

# Recherche avec plusieurs mots-clés
apt search web server

# Recherche exacte sur le nom uniquement
apt search --names-only nginx
```

**Exemple de sortie :**

```bash
$ apt search --names-only nginx
Sorting... Done
Full Text Search... Done
nginx/jammy-updates 1.18.0-6ubuntu14.4 all
  small, powerful, scalable web/proxy server

nginx-common/jammy-updates 1.18.0-6ubuntu14.4 all
  small, powerful, scalable web/proxy server - common files

nginx-core/jammy-updates 1.18.0-6ubuntu14.4 amd64
  nginx web/proxy server (standard version)
```

> [!info] Comment fonctionne apt search `apt search` interroge le cache local des paquets (mis à jour avec `apt update`). Il recherche dans les noms de paquets, les descriptions courtes et longues. Les résultats sont triés par pertinence.

### apt show

Affiche des informations détaillées sur un paquet spécifique.

```bash
# Afficher les détails d'un paquet
apt show nginx

# Afficher les détails d'une version spécifique
apt show nginx=1.18.0-6ubuntu14.4
```

**Informations affichées :**

- Version disponible
- Dépendances requises
- Taille du paquet et espace disque nécessaire
- Description complète
- Site web du projet
- Mainteneur du paquet

```bash
$ apt show htop
Package: htop
Version: 3.0.5-7build2
Priority: optional
Section: utils
Origin: Ubuntu
Maintainer: Ubuntu Developers
Installed-Size: 325 kB
Depends: libc6, libncursesw6, libtinfo6
Homepage: https://htop.dev/
Download-Size: 125 kB
APT-Sources: http://fr.archive.ubuntu.com/ubuntu jammy/main amd64 Packages
Description: interactive processes viewer
 Htop is an ncursed-based process viewer similar to top, but it
 allows one to scroll the list vertically and horizontally to see
 all processes and their full command lines.
```

### apt list

Liste les paquets selon différents critères.

```bash
# Lister tous les paquets disponibles (très long)
apt list

# Lister uniquement les paquets installés
apt list --installed

# Lister les paquets qui peuvent être mis à jour
apt list --upgradable

# Lister avec un motif spécifique
apt list 'nginx*'

# Lister toutes les versions disponibles d'un paquet
apt list -a nginx
```

**Exemple de sortie :**

```bash
$ apt list --installed | grep nginx
nginx-common/jammy-updates,now 1.18.0-6ubuntu14.4 all [installed]
nginx-core/jammy-updates,now 1.18.0-6ubuntu14.4 amd64 [installed]
nginx/jammy-updates,now 1.18.0-6ubuntu14.4 all [installed]
```

> [!tip] Filtrer efficacement avec grep
> 
> ```bash
> # Compter les paquets installés
> apt list --installed | wc -l
> 
> # Chercher un paquet spécifique parmi les installés
> apt list --installed | grep python
> 
> # Voir uniquement les paquets avec "lib" dans le nom
> apt list --installed 'lib*'
> ```

### apt-cache : recherche avancée

Bien que `apt search` soit suffisant pour la plupart des usages, `apt-cache` offre des fonctionnalités supplémentaires.

```bash
# Recherche dans les paquets
apt-cache search nginx

# Recherche uniquement dans les noms
apt-cache search --names-only nginx

# Afficher les informations d'un paquet
apt-cache show nginx

# Afficher les dépendances d'un paquet
apt-cache depends nginx

# Afficher les paquets qui dépendent de ce paquet
apt-cache rdepends nginx

# Afficher la politique de version
apt-cache policy nginx

# Statistiques sur le cache
apt-cache stats
```

**Cas d'usage de apt-cache depends :**

```bash
$ apt-cache depends nginx
nginx
  Depends: nginx-core
    nginx-full
    nginx-light
    nginx-extras
  Depends: nginx-common
```

> [!info] apt-cache policy : comprendre les versions
> 
> ```bash
> $ apt-cache policy nginx
> nginx:
>   Installed: 1.18.0-6ubuntu14.4
>   Candidate: 1.18.0-6ubuntu14.4
>   Version table:
>  *** 1.18.0-6ubuntu14.4 500
>         500 http://fr.archive.ubuntu.com/ubuntu jammy-updates/main amd64 Packages
>         100 /var/lib/dpkg/status
>      1.18.0-0ubuntu1 500
>         500 http://fr.archive.ubuntu.com/ubuntu jammy/main amd64 Packages
> ```
> 
> - **Installed** : version actuellement installée
> - **Candidate** : version qui serait installée par `apt install`
> - Les nombres (500, 100) indiquent la priorité des sources

### Recherche de fichiers dans les paquets

Pour trouver quel paquet fournit un fichier spécifique, vous devez installer `apt-file`.

```bash
# Installation de apt-file
sudo apt install apt-file

# Mise à jour de la base de données
sudo apt-file update

# Chercher quel paquet contient un fichier
apt-file search /usr/bin/nginx

# Lister tous les fichiers d'un paquet
apt-file list nginx
```

> [!tip] Alternative rapide avec dpkg Si vous cherchez un fichier parmi les paquets **déjà installés**, utilisez plutôt :
> 
> ```bash
> dpkg -S /usr/bin/nginx
> ```

---

## 🧹 Nettoyage du système

Au fil du temps, APT accumule des fichiers de paquets téléchargés et des dépendances devenues inutiles. Le nettoyage régulier permet de libérer de l'espace disque.

### apt clean

Supprime tous les fichiers de paquets téléchargés du cache local.

```bash
# Nettoyer complètement le cache
sudo apt clean
```

> [!info] Que supprime apt clean ?
> 
> - Vide complètement `/var/cache/apt/archives/`
> - Supprime tous les fichiers `.deb` téléchargés
> - N'affecte PAS les paquets installés
> - Libère de l'espace disque (parfois plusieurs Go)

**Quand utiliser apt clean :**

- Quand l'espace disque est critique
- Avant de créer une image système
- Lors du nettoyage d'un système

```bash
# Vérifier l'espace occupé par le cache avant nettoyage
du -sh /var/cache/apt/archives/

# Nettoyer
sudo apt clean

# Vérifier après
du -sh /var/cache/apt/archives/
```

### apt autoclean

Variante plus conservatrice qui ne supprime que les paquets obsolètes du cache.

```bash
# Nettoyer uniquement les paquets obsolètes
sudo apt autoclean
```

> [!info] Différence avec apt clean `autoclean` garde les fichiers des versions actuellement disponibles dans les dépôts, mais supprime ceux des anciennes versions qui ne sont plus téléchargeables.

|Commande|Action|Usage recommandé|
|---|---|---|
|`apt clean`|Vide tout le cache|Libération d'espace urgente|
|`apt autoclean`|Supprime fichiers obsolètes|Nettoyage régulier et sûr|

### apt autoremove

Supprime les paquets qui ont été installés automatiquement comme dépendances mais qui ne sont plus nécessaires.

```bash
# Supprimer les dépendances orphelines
sudo apt autoremove

# Supprimer avec confirmation automatique
sudo apt autoremove -y

# Supprimer ET purger les fichiers de configuration
sudo apt autoremove --purge
```

> [!warning] Vérifiez toujours avant de confirmer `apt autoremove` peut parfois proposer de supprimer des paquets que vous souhaitez garder, notamment si vous avez désinstallé un métapaquet. Lisez attentivement la liste avant de confirmer.

**Exemple de sortie :**

```bash
$ sudo apt autoremove
Reading package lists... Done
Building dependency tree... Done
The following packages will be REMOVED:
  linux-headers-5.15.0-56 linux-headers-5.15.0-56-generic
  linux-image-5.15.0-56-generic linux-modules-5.15.0-56-generic
0 upgraded, 0 newly installed, 4 to remove and 0 not upgraded.
After this operation, 345 MB disk space will be freed.
Do you want to continue? [Y/n]
```

> [!info] Pourquoi des paquets deviennent orphelins ?
> 
> - Vous avez supprimé un paquet qui les requérait
> - Après une mise à jour, de nouvelles versions ont remplacé les anciennes
> - Un métapaquet a été supprimé (ex: ubuntu-desktop)

### Marquer un paquet comme manuel

Si `autoremove` veut supprimer un paquet que vous souhaitez garder, marquez-le comme installé manuellement.

```bash
# Marquer un paquet comme manuel (ne sera pas autoremove)
sudo apt-mark manual nom-du-paquet

# Marquer comme automatique
sudo apt-mark auto nom-du-paquet

# Voir les paquets marqués manuels
apt-mark showmanual

# Voir les paquets marqués automatiques
apt-mark showauto
```

### Script de nettoyage complet

> [!tip] Routine de nettoyage recommandée
> 
> ```bash
> #!/bin/bash
> # Script de nettoyage système
> 
> echo "=== Mise à jour de la liste des paquets ==="
> sudo apt update
> 
> echo "=== Suppression des paquets orphelins ==="
> sudo apt autoremove -y
> 
> echo "=== Nettoyage du cache des paquets obsolètes ==="
> sudo apt autoclean
> 
> echo "=== Espace disque libéré ==="
> df -h / | tail -1
> 
> echo "=== Nettoyage terminé ==="
> ```

### Vérification de l'espace disque

```bash
# Espace utilisé par les différents répertoires APT
du -sh /var/cache/apt/archives/
du -sh /var/lib/apt/lists/
du -sh /var/log/apt/

# Espace total disponible sur /
df -h /
```

---

## ⚠️ Pièges courants et bonnes pratiques

### Pièges fréquents

> [!warning] Piège n°1 : Oublier sudo apt update
> 
> ```bash
> # ❌ Installation sans mise à jour préalable
> sudo apt install nginx
> # Vous risquez d'installer une version obsolète !
> 
> # ✅ Toujours mettre à jour d'abord
> sudo apt update
> sudo apt install nginx
> ```

> [!warning] Piège n°2 : Confondre remove et purge
> 
> ```bash
> # Si vous faites :
> sudo apt remove postgresql
> # Les fichiers de config restent dans /etc/postgresql/
> 
> # Pour vraiment tout supprimer :
> sudo apt purge postgresql
> # ou
> sudo apt remove --purge postgresql
> ```

> [!warning] Piège n°3 : Ne jamais nettoyer Le cache APT peut atteindre plusieurs gigaoctets au fil du temps. Nettoyez régulièrement avec `apt autoclean` ou `apt clean`.

> [!warning] Piège n°4 : Interrompre une installation Si vous interrompez apt avec Ctrl+C pendant une installation, le système de paquets peut rester dans un état incohérent. Réparez avec :
> 
> ```bash
> sudo dpkg --configure -a
> sudo apt install -f
> ```

> [!warning] Piège n°5 : Mélanger les gestionnaires de paquets N'installez pas de logiciels avec plusieurs méthodes différentes (apt, snap, compilation manuelle) pour un même logiciel. Cela crée des conflits.

### Bonnes pratiques essentielles

> [!tip] Pratique n°1 : Workflow de mise à jour régulier
> 
> ```bash
> # À faire hebdomadairement ou quotidiennement sur les serveurs critiques
> sudo apt update
> sudo apt upgrade -y
> sudo apt autoremove -y
> sudo apt autoclean
> ```

> [!tip] Pratique n°2 : Vérifier avant d'agir
> 
> ```bash
> # Toujours simuler avant une grosse opération
> sudo apt install -s paquet1 paquet2 paquet3
> 
> # Vérifier ce qui sera mis à jour
> apt list --upgradable
> ```

> [!tip] Pratique n°3 : Consulter les logs En cas de problème, les logs APT sont précieux :
> 
> ```bash
> # Historique des opérations APT
> cat /var/log/apt/history.log
> 
> # Détails techniques
> cat /var/log/apt/term.log
> 
> # Voir les dernières opérations
> tail -n 50 /var/log/apt/history.log
> ```

> [!tip] Pratique n°4 : Sauvegarder la liste des paquets installés
> 
> ```bash
> # Exporter la liste des paquets installés
> dpkg --get-selections > paquets-installes.txt
> 
> # Réinstaller sur un nouveau système
> sudo dpkg --set-selections < paquets-installes.txt
> sudo apt-get dselect-upgrade
> ```

> [!tip] Pratique n°5 : Vérifier l'intégrité du système
> 
> ```bash
> # Vérifier les dépendances cassées
> sudo apt check
> 
> # Réparer les dépendances
> sudo apt install -f
> 
> # Reconfigurer les paquets mal installés
> sudo dpkg --configure -a
> ```

### Sécurité et mises à jour

> [!info] Mises à jour de sécurité Sur Ubuntu, les mises à jour de sécurité proviennent du dépôt `security`. Vous pouvez les appliquer en priorité :
> 
> ```bash
> # Voir les mises à jour de sécurité disponibles
> apt list --upgradable | grep security
> 
> # Sur Ubuntu, unattended-upgrades installe automatiquement
> # les mises à jour de sécurité
> sudo apt install unattended-upgrades
> ```

### Gestion avancée

```bash
# Maintenir (hold) un paquet à sa version actuelle
# Empêche les mises à jour automatiques
sudo apt-mark hold nginx

# Libérer (unhold) un paquet
sudo apt-mark unhold nginx

# Voir les paquets en hold
apt-mark showhold

# Downgrade vers une version antérieure (dangereux)
sudo apt install nginx=1.18.0-0ubuntu1

# Verrouiller cette version
sudo apt-mark hold nginx
```

> [!warning] Attention au hold Utiliser `apt-mark hold` empêche les mises à jour, y compris les correctifs de sécurité. N'utilisez cette fonction que pour des raisons spécifiques et documentez-la.

### Récapitulatif des commandes essentielles

|Tâche|Commande|
|---|---|
|Mettre à jour la liste des paquets|`sudo apt update`|
|Mettre à jour les paquets installés|`sudo apt upgrade`|
|Mise à jour complète|`sudo apt full-upgrade`|
|Installer un paquet|`sudo apt install nom-paquet`|
|Supprimer un paquet|`sudo apt remove nom-paquet`|
|Supprimer complètement|`sudo apt purge nom-paquet`|
|Rechercher un paquet|`apt search mot-clé`|
|Afficher les infos d'un paquet|`apt show nom-paquet`|
|Lister les paquets installés|`apt list --installed`|
|Nettoyer les dépendances orphelines|`sudo apt autoremove`|
|Nettoyer le cache|`sudo apt autoclean`|
|Vérifier l'intégrité|`sudo apt check`|

---

> [!tip] 💡 Astuce finale Créez des alias dans votre `~/.bashrc` pour les commandes fréquentes :
> 
> ```bash
> alias update='sudo apt update && sudo apt upgrade'
> alias cleanup='sudo apt autoremove && sudo apt autoclean'
> alias search='apt search'
> ```