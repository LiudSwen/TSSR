

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

## Introduction

La première chose à faire après l'installation d'un système Linux est de **mettre à jour le système**. Cette étape est cruciale pour plusieurs raisons :

- **Sécurité** : Corriger les vulnérabilités découvertes depuis la création de l'image d'installation
- **Stabilité** : Bénéficier des corrections de bugs
- **Fonctionnalités** : Accéder aux dernières améliorations des logiciels
- **Compatibilité** : Assurer le bon fonctionnement avec du matériel récent

> [!warning] Attention Sur un système nouvellement installé, des centaines voire des milliers de paquets peuvent nécessiter une mise à jour. Prévoyez du temps et une connexion Internet stable.

---

## apt update et apt upgrade

Sur les systèmes basés sur Debian (Debian, Ubuntu, Linux Mint, Pop!_OS, etc.), la gestion des paquets se fait principalement avec **APT** (Advanced Package Tool).

### apt update : Mise à jour de la liste des paquets

La commande `apt update` synchronise la liste locale des paquets disponibles avec les dépôts distants.

```bash
# Mise à jour de la liste des paquets (nécessite les droits root)
sudo apt update
```

**Ce que fait cette commande :**

1. Contacte tous les dépôts configurés dans `/etc/apt/sources.list`
2. Télécharge les métadonnées des paquets disponibles
3. Met à jour la base de données locale (dans `/var/lib/apt/lists/`)
4. Affiche un résumé des paquets pouvant être mis à jour

> [!info] À savoir `apt update` ne modifie AUCUN paquet installé sur votre système. Elle se contente de mettre à jour l'index des paquets disponibles.

**Exemple de sortie :**

```bash
Hit:1 http://fr.archive.ubuntu.com/ubuntu jammy InRelease
Get:2 http://fr.archive.ubuntu.com/ubuntu jammy-updates InRelease [119 kB]
Get:3 http://security.ubuntu.com/ubuntu jammy-security InRelease [110 kB]
Fetched 229 kB in 2s (114 kB/s)
Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
42 packages can be upgraded. Run 'apt list --upgradable' to see them.
```

> [!tip] Astuce Pour voir la liste détaillée des paquets pouvant être mis à jour :
> 
> ```bash
> apt list --upgradable
> ```

### apt upgrade : Installation des mises à jour

Une fois la liste des paquets mise à jour, `apt upgrade` installe les nouvelles versions disponibles.

```bash
# Installation des mises à jour
sudo apt upgrade
```

**Ce que fait cette commande :**

1. Compare les versions installées avec les versions disponibles
2. Calcule les dépendances nécessaires
3. Télécharge les nouveaux paquets
4. Installe les mises à jour **sans supprimer de paquets existants**

> [!warning] Comportement conservateur `apt upgrade` ne supprimera jamais un paquet installé, même si cela est nécessaire pour mettre à jour un autre paquet. Dans ce cas, le paquet sera conservé dans sa version actuelle.

**Options utiles :**

```bash
# Mise à jour avec confirmation automatique (mode non-interactif)
sudo apt upgrade -y

# Simulation de la mise à jour (aucune modification effectuée)
sudo apt upgrade --dry-run

# Afficher plus de détails pendant la mise à jour
sudo apt upgrade -V
```

**Séquence complète typique :**

```bash
# 1. Mise à jour de la liste des paquets
sudo apt update

# 2. Installation des mises à jour
sudo apt upgrade

# 3. Nettoyage des paquets téléchargés
sudo apt clean
```

### Autres commandes de mise à jour

APT propose plusieurs variantes avec des comportements différents :

|Commande|Comportement|Quand l'utiliser|
|---|---|---|
|`apt upgrade`|Met à jour sans supprimer de paquets|Mise à jour quotidienne, sécuritaire|
|`apt full-upgrade`|Met à jour en installant/supprimant si nécessaire|Mise à jour complète du système|
|`apt dist-upgrade`|Identique à `full-upgrade` (ancien nom)|Pour compatibilité avec anciens scripts|
|`apt autoremove`|Supprime les dépendances devenues inutiles|Après des mises à jour importantes|

**Exemple avec full-upgrade :**

```bash
# Mise à jour complète (peut ajouter/supprimer des paquets)
sudo apt update
sudo apt full-upgrade

# Nettoyer après la mise à jour
sudo apt autoremove
sudo apt autoclean
```

> [!example] Différence concrète **Scénario :** Un paquet A version 1.0 dépend de B version 1.0. La nouvelle version A 2.0 dépend de B 2.0 mais est incompatible avec B 1.0.
> 
> - `apt upgrade` : conservera A 1.0 et B 1.0
> - `apt full-upgrade` : installera A 2.0 et B 2.0

> [!tip] Automatisation Pour automatiser les mises à jour quotidiennes :
> 
> ```bash
> # Créer un script de mise à jour
> echo '#!/bin/bash
> apt update
> apt upgrade -y
> apt autoremove -y
> ' | sudo tee /usr/local/bin/daily-update
> 
> # Rendre le script exécutable
> sudo chmod +x /usr/local/bin/daily-update
> ```

---

## Différences dans les dépôts

### Qu'est-ce qu'un dépôt ?

Un **dépôt** (ou _repository_) est un serveur qui héberge des paquets logiciels précompilés et leurs métadonnées. Chaque distribution Linux maintient ses propres dépôts avec sa politique de gestion.

**Composants d'un dépôt :**

- **Paquets binaires** : Logiciels compilés prêts à installer
- **Métadonnées** : Descriptions, dépendances, versions
- **Signatures GPG** : Garantissent l'authenticité et l'intégrité
- **Index** : Base de données permettant la recherche rapide

### Types de dépôts selon les distributions

Chaque distribution organise ses dépôts différemment selon sa philosophie et ses priorités.

#### Debian

Debian classe ses paquets selon leur **licence et support** :

|Section|Description|Exemples|
|---|---|---|
|**main**|Logiciels libres officiellement supportés|nginx, python3, vim|
|**contrib**|Logiciels libres dépendant de non-libre|virtualbox-ext-pack|
|**non-free**|Logiciels propriétaires|firmware-realtek, rar|
|**non-free-firmware**|Micrologiciels propriétaires|firmware-iwlwifi|

**Branches de versions :**

- **stable** : Version actuelle stable (ex: bookworm)
- **testing** : Prochaine version stable en préparation
- **unstable** (sid) : Version de développement permanent
- **oldstable** : Version stable précédente

> [!info] Philosophie Debian Debian privilégie la **stabilité** et les **logiciels libres**. Les dépôts stable ne reçoivent que des correctifs de sécurité, pas de nouvelles versions majeures.

#### Ubuntu

Ubuntu hérite de Debian mais ajoute sa propre classification par **niveau de support** :

|Section|Support officiel|Mises à jour|Exemples|
|---|---|---|---|
|**main**|✅ Canonical|Sécurité + corrections|firefox, apache2|
|**restricted**|✅ Canonical|Sécurité limitée|Pilotes propriétaires|
|**universe**|❌ Communauté|Communauté|handbrake, ardour|
|**multiverse**|❌ Communauté|Communauté|skype, steam|

**Dépôts supplémentaires :**

- **updates** : Mises à jour régulières
- **security** : Correctifs de sécurité
- **backports** : Versions récentes de logiciels
- **proposed** : Paquets en test avant publication

> [!warning] Support LTS Sur les versions LTS (Long Term Support), seuls **main** et **restricted** bénéficient d'un support de 5 ans. Universe et multiverse n'ont qu'un support communautaire.

#### Fedora / RHEL / CentOS

Organisation par **stabilité et origine** :

|Dépôt|Description|Stabilité|
|---|---|---|
|**fedora**|Paquets de base|✅ Stable|
|**updates**|Mises à jour officielles|✅ Testé|
|**updates-testing**|Mises à jour en test|⚠️ Instable|
|**rpmfusion-free**|Extensions libres tierces|⚠️ Variable|
|**rpmfusion-nonfree**|Extensions non-libres|⚠️ Variable|

**Spécificités RHEL/CentOS :**

- **BaseOS** : Composants système de base
- **AppStream** : Applications et environnements
- **EPEL** : Extra Packages for Enterprise Linux (communauté)

> [!info] Cycle de vie Fedora sort une nouvelle version tous les 6 mois avec support de 13 mois. RHEL/CentOS privilégient la stabilité sur 10 ans.

#### Arch Linux

Arch utilise un modèle **rolling release** avec trois dépôts principaux :

|Dépôt|Description|Stabilité|
|---|---|---|
|**core**|Paquets système essentiels|✅ Stable|
|**extra**|Logiciels additionnels officiels|✅ Stable|
|**community**|Maintenus par la communauté|⚠️ Variable|

**Dépôts non-officiels :**

- **multilib** : Paquets 32 bits sur système 64 bits
- **testing** : Versions en test avant intégration
- **AUR** : Arch User Repository (scripts de compilation)

> [!warning] Rolling Release Arch met à jour en continu vers les dernières versions. Pas de "versions" du système, mais un flux constant de mises à jour.

### Philosophies de gestion des versions

Les distributions adoptent deux approches principales :

#### Release fixe (Debian Stable, Ubuntu LTS, RHEL)

**Caractéristiques :**

- Version figée des logiciels pendant toute la durée de vie
- Seuls les correctifs de sécurité et bugs critiques sont appliqués
- Cycle de sortie prévisible (tous les 2-3 ans)
- Idéal pour les serveurs et environnements de production

**Avantages :**

- ✅ Grande stabilité et prévisibilité
- ✅ Tests approfondis avant publication
- ✅ Changements minimaux sur la durée

**Inconvénients :**

- ❌ Logiciels parfois anciens
- ❌ Nouvelles fonctionnalités retardées

#### Rolling Release (Arch Linux, openSUSE Tumbleweed)

**Caractéristiques :**

- Mise à jour continue vers les dernières versions
- Pas de "versions" du système d'exploitation
- Nouvelles fonctionnalités disponibles immédiatement
- Nécessite des mises à jour régulières

**Avantages :**

- ✅ Logiciels toujours à jour
- ✅ Pas de migration de version majeure
- ✅ Accès aux dernières fonctionnalités

**Inconvénients :**

- ❌ Risque de régression plus élevé
- ❌ Nécessite une vigilance constante
- ❌ Potentiellement instable

> [!tip] Choisir son modèle
> 
> - **Serveur de production** → Release fixe (Debian Stable, RHEL)
> - **Poste de développement** → Semi-rolling (Fedora, Ubuntu)
> - **Enthusiaste Linux** → Rolling (Arch, openSUSE Tumbleweed)

---

## Configuration des sources

La configuration des dépôts varie selon la distribution. Voici comment gérer les sources sur les principales familles.

### Debian/Ubuntu : sources.list

Le fichier principal de configuration est `/etc/apt/sources.list`, complété par des fichiers dans `/etc/apt/sources.list.d/`.

#### Structure d'une ligne sources.list

```bash
# Format général :
deb [options] URI distribution composants

# Format pour code source :
deb-src [options] URI distribution composants
```

**Composants d'une ligne :**

- `deb` ou `deb-src` : Type de paquet (binaire ou source)
- `[options]` : Options facultatives (architecture, signature, etc.)
- `URI` : Adresse du dépôt (http, https, ftp, file)
- `distribution` : Nom de code de la version (bookworm, jammy, etc.)
- `composants` : Sections du dépôt (main, contrib, non-free, etc.)

#### Exemple Debian 12 (Bookworm)

```bash
# Éditer le fichier de sources
sudo nano /etc/apt/sources.list
```

```bash
# Dépôts principaux Debian 12 Bookworm
deb http://deb.debian.org/debian/ bookworm main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian/ bookworm main contrib non-free non-free-firmware

# Mises à jour de sécurité
deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
deb-src http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware

# Mises à jour générales
deb http://deb.debian.org/debian/ bookworm-updates main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian/ bookworm-updates main contrib non-free non-free-firmware
```

#### Exemple Ubuntu 22.04 LTS (Jammy)

```bash
# Dépôts principaux Ubuntu
deb http://fr.archive.ubuntu.com/ubuntu/ jammy main restricted universe multiverse
deb-src http://fr.archive.ubuntu.com/ubuntu/ jammy main restricted universe multiverse

# Mises à jour
deb http://fr.archive.ubuntu.com/ubuntu/ jammy-updates main restricted universe multiverse
deb-src http://fr.archive.ubuntu.com/ubuntu/ jammy-updates main restricted universe multiverse

# Sécurité
deb http://security.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse
deb-src http://security.ubuntu.com/ubuntu/ jammy-security main restricted universe multiverse

# Backports (optionnel)
deb http://fr.archive.ubuntu.com/ubuntu/ jammy-backports main restricted universe multiverse
```

> [!tip] Miroirs locaux Remplacez l'URI par un miroir géographiquement proche pour accélérer les téléchargements :
> 
> ```bash
> # France
> deb http://fr.archive.ubuntu.com/ubuntu/ jammy main
> 
> # Belgique
> deb http://be.archive.ubuntu.com/ubuntu/ jammy main
> ```

#### Options avancées

```bash
# Limiter à une architecture spécifique
deb [arch=amd64] http://example.com/ubuntu jammy main

# Spécifier une clé GPG signée
deb [signed-by=/usr/share/keyrings/example.gpg] http://example.com/repo stable main

# Combiner plusieurs options
deb [arch=amd64,arm64 signed-by=/usr/share/keyrings/key.gpg] https://repo.com/ stable main
```

#### Appliquer les modifications

Après avoir modifié les sources, il faut mettre à jour l'index :

```bash
# Mettre à jour la liste des paquets
sudo apt update

# Vérifier qu'il n'y a pas d'erreurs
echo $?  # Doit retourner 0 si succès
```

> [!warning] Erreurs courantes **"The following signatures couldn't be verified"** → Clé GPG manquante
> 
> **"Failed to fetch"** → URL incorrecte ou serveur indisponible
> 
> **"Release file expired"** → Dépôt obsolète ou horloge système incorrecte

### Fedora/RHEL : fichiers .repo

Sur les systèmes basés sur RPM (Fedora, RHEL, CentOS), les dépôts sont configurés dans `/etc/yum.repos.d/`.

#### Structure d'un fichier .repo

```ini
[identifiant]
name=Nom descriptif du dépôt
baseurl=URL_du_dépôt
enabled=1
gpgcheck=1
gpgkey=URL_de_la_clé_GPG
```

#### Exemple Fedora

```bash
# Créer un nouveau dépôt
sudo nano /etc/yum.repos.d/example.repo
```

```ini
[fedora]
name=Fedora $releasever - $basearch
baseurl=http://download.fedoraproject.org/pub/fedora/linux/releases/$releasever/Everything/$basearch/os/
enabled=1
countme=1
metadata_expire=7d
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-$releasever-$basearch

[updates]
name=Fedora $releasever - $basearch - Updates
baseurl=http://download.fedoraproject.org/pub/fedora/linux/updates/$releasever/Everything/$basearch/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-fedora-$releasever-$basearch
```

**Variables utiles :**

- `$releasever` : Version de la distribution (38, 39, etc.)
- `$basearch` : Architecture (x86_64, aarch64, etc.)
- `$arch` : Architecture exacte du processeur

#### Gestion des dépôts

```bash
# Lister tous les dépôts configurés
dnf repolist

# Lister même les dépôts désactivés
dnf repolist --all

# Activer un dépôt temporairement
sudo dnf --enablerepo=updates-testing install paquet

# Désactiver un dépôt
sudo dnf config-manager --set-disabled nom-depot

# Activer un dépôt
sudo dnf config-manager --set-enabled nom-depot
```

#### Exemple RHEL avec EPEL

```bash
# Installer EPEL (Extra Packages for Enterprise Linux)
sudo dnf install epel-release

# Le fichier créé automatiquement
cat /etc/yum.repos.d/epel.repo
```

```ini
[epel]
name=Extra Packages for Enterprise Linux $releasever - $basearch
baseurl=https://download.fedoraproject.org/pub/epel/$releasever/Everything/$basearch/
enabled=1
gpgcheck=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-$releasever
```

> [!tip] Priorités des dépôts Définir des priorités pour éviter les conflits :
> 
> ```ini
> [epel]
> name=EPEL
> baseurl=...
> priority=10
> ```
> 
> Plus le nombre est bas, plus la priorité est élevée.

### Arch Linux : pacman.conf

Arch Linux utilise le fichier `/etc/pacman.conf` pour configurer les dépôts.

#### Configuration de base

```bash
# Éditer la configuration de pacman
sudo nano /etc/pacman.conf
```

```ini
# Options générales
[options]
HoldPkg     = pacman glibc
Architecture = auto
CheckSpace
SigLevel    = Required DatabaseOptional

# Dépôts officiels
[core]
Include = /etc/pacman.d/mirrorlist

[extra]
Include = /etc/pacman.d/mirrorlist

[community]
Include = /etc/pacman.d/mirrorlist

# Support 32 bits (décommenter si nécessaire)
#[multilib]
#Include = /etc/pacman.d/mirrorlist
```

**Options importantes :**

|Option|Description|
|---|---|
|`HoldPkg`|Paquets protégés contre la suppression|
|`Architecture`|Architecture cible (auto, x86_64, etc.)|
|`CheckSpace`|Vérifier l'espace disque avant installation|
|`SigLevel`|Niveau de vérification des signatures|

#### Gestion des miroirs

Les miroirs sont listés dans `/etc/pacman.d/mirrorlist` :

```bash
# Éditer la liste des miroirs
sudo nano /etc/pacman.d/mirrorlist
```

```bash
# France
Server = https://mirror.archlinux.fr/$repo/os/$arch
Server = https://mirrors.celianvdb.fr/archlinux/$repo/os/$arch

# Allemagne
Server = https://mirror.pkgbuild.com/$repo/os/$arch

# Global CDN
Server = https://geo.mirror.pkgbuild.com/$repo/os/$arch
```

> [!tip] Optimiser les miroirs Utiliser `reflector` pour sélectionner automatiquement les miroirs les plus rapides :
> 
> ```bash
> # Installer reflector
> sudo pacman -S reflector
> 
> # Trouver les 10 miroirs les plus rapides en France
> sudo reflector --country France --latest 10 --sort rate --save /etc/pacman.d/mirrorlist
> 
> # Mettre à jour la base de données
> sudo pacman -Syy
> ```

#### Activer multilib (32 bits sur 64 bits)

Pour installer des applications 32 bits sur un système 64 bits :

```bash
# Décommenter dans /etc/pacman.conf
[multilib]
Include = /etc/pacman.d/mirrorlist

# Mettre à jour la base de données
sudo pacman -Syy
```

### Ajout de dépôts tiers

L'ajout de dépôts externes nécessite de la prudence. Voici les bonnes pratiques.

#### Debian/Ubuntu : PPA et dépôts externes

**Méthode 1 : Avec add-apt-repository (Ubuntu)**

```bash
# Installer le paquet nécessaire
sudo apt install software-properties-common

# Ajouter un PPA
sudo add-apt-repository ppa:user/ppa-name

# Mettre à jour
sudo apt update
```

**Méthode 2 : Manuelle (Debian/Ubuntu)**

```bash
# 1. Télécharger la clé GPG
wget -qO- https://example.com/key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/example.gpg

# 2. Ajouter le dépôt avec la clé
echo "deb [signed-by=/usr/share/keyrings/example.gpg] https://example.com/repo stable main" | \
  sudo tee /etc/apt/sources.list.d/example.list

# 3. Mettre à jour
sudo apt update
```

> [!warning] Sécurité des PPA Les PPA ne sont pas vérifiés par Ubuntu. N'ajoutez que des sources de confiance. Un PPA malveillant peut compromettre votre système.

**Exemple concret : Docker sur Ubuntu**

```bash
# 1. Installer les prérequis
sudo apt install ca-certificates curl gnupg

# 2. Ajouter la clé GPG officielle de Docker
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
  sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# 3. Ajouter le dépôt
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 4. Installer Docker
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io
```

#### Fedora : RPM Fusion

RPM Fusion fournit des logiciels non inclus dans Fedora (codecs, pilotes, etc.) :

```bash
# Installer RPM Fusion Free et Nonfree
sudo dnf install \
  https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# Mettre à jour
sudo dnf update
```

#### Arch Linux : AUR (à mentionner brièvement)

L'Arch User Repository contient des scripts de compilation maintenus par la communauté. L'installation de paquets AUR sera abordée dans une autre partie du cours.

> [!warning] Risques des dépôts tiers
> 
> - **Conflit de paquets** : Peut écraser des paquets officiels
> - **Sécurité** : Pas de contrôle par la distribution
> - **Stabilité** : Peut introduire des incompatibilités
> - **Support** : Pas d'assistance officielle
> 
> Règle d'or : N'ajoutez que des dépôts de sources réputées et nécessaires.

---

## Bonnes pratiques

Pour maintenir un système sain et à jour, suivez ces recommandations :

### Fréquence des mises à jour

|Type de système|Fréquence recommandée|Commandes|
|---|---|---|
|**Poste de travail**|Quotidienne ou hebdomadaire|`sudo apt update && sudo apt upgrade`|
|**Serveur de production**|Hebdomadaire avec tests|Environnement de test d'abord|
|**Serveur critique**|Mensuelle planifiée|Fenêtre de maintenance|

### Workflow recommandé

```bash
# 1. Mettre à jour la liste des paquets
sudo apt update

# 2. Voir ce qui va être mis à jour
apt list --upgradable

# 3. Installer les mises à jour
sudo apt upgrade

# 4. Si nécessaire, mise à jour complète
sudo apt full-upgrade

# 5. Nettoyer les paquets inutiles
sudo apt autoremove

# 6. Vider le cache
sudo apt clean
```

### Vérifications avant mise à jour

> [!warning] Checklist pré-mise à jour ✅ **Espace disque suffisant** : `df -h`
> 
> ✅ **Sauvegarde récente** : Surtout sur serveurs
> 
> ✅ **Fenêtre de maintenance** : Pour les serveurs
> 
> ✅ **Connexion stable** : Éviter les coupures réseau
> 
> ✅ **Notes de version** : Lire les changements importants

### Gestion des erreurs

**Dépôt inaccessible :**

```bash
# Afficher les erreurs détaillées
sudo apt update 2>&1 | grep -i error

# Désactiver temporairement un dépôt problématique
sudo mv /etc/apt/sources.list.d/problematic.list /etc/apt/sources.list.d/problematic.list.disabled
```

**Paquets cassés :**

```bash
# Réparer les paquets cassés
sudo apt --fix-broken install

# Reconfigurer les paquets partiellement installés
sudo dpkg --configure -a

# Nettoyer et réessayer
sudo apt clean
sudo apt update
sudo apt upgrade
```

**Conflit de versions :**

```bash
# Voir les paquets bloqués
apt-mark showhold

# Débloquer un paquet si nécessaire
sudo apt-mark unhold nom-du-paquet
```

### Sécurité des mises à jour

> [!tip] Mises à jour de sécurité prioritaires Sur Debian/Ubuntu, installer uniquement les correctifs de sécurité :
> 
> ```bash
> # Debian
> sudo apt install debian-security-support
> sudo apt upgrade -s | grep security
> 
> # Ubuntu
> sudo unattended-upgrades --dry-run
> ```

### Documentation des changements

Pour les environnements professionnels, documentez vos mises à jour :

```bash
# Créer un journal de mise à jour
echo "=== Mise à jour du $(date) ===" >> /var/log/manual-updates.log
apt list --upgradable >> /var/log/manual-updates.log
sudo apt upgrade -y 2>&1 | tee -a /var/log/manual-updates.log
```

**Exemple de script de mise à jour documenté :**

```bash
#!/bin/bash
# Script de mise à jour avec logging

LOGFILE="/var/log/system-updates.log"
DATE=$(date "+%Y-%m-%d %H:%M:%S")

echo "[$DATE] === Début de la mise à jour ===" | tee -a "$LOGFILE"

# Mise à jour de la liste
echo "[$DATE] Mise à jour de la liste des paquets..." | tee -a "$LOGFILE"
apt update 2>&1 | tee -a "$LOGFILE"

# Liste des paquets à mettre à jour
echo "[$DATE] Paquets à mettre à jour :" | tee -a "$LOGFILE"
apt list --upgradable 2>&1 | tee -a "$LOGFILE"

# Installation des mises à jour
echo "[$DATE] Installation des mises à jour..." | tee -a "$LOGFILE"
apt upgrade -y 2>&1 | tee -a "$LOGFILE"

# Nettoyage
echo "[$DATE] Nettoyage..." | tee -a "$LOGFILE"
apt autoremove -y 2>&1 | tee -a "$LOGFILE"

echo "[$DATE] === Fin de la mise à jour ===" | tee -a "$LOGFILE"
```

### Automatisation intelligente

Pour les systèmes nécessitant une disponibilité continue :

```bash
# Installer unattended-upgrades (Ubuntu/Debian)
sudo apt install unattended-upgrades

# Configurer les mises à jour automatiques
sudo dpkg-reconfigure -plow unattended-upgrades
```

**Configuration avancée :**

```bash
# Éditer la configuration
sudo nano /etc/apt/apt.conf.d/50unattended-upgrades
```

```bash
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}";
    "${distro_id}:${distro_codename}-security";
    "${distro_id}ESMApps:${distro_codename}-apps-security";
};

// Ne redémarrer automatiquement que si nécessaire
Unattended-Upgrade::Automatic-Reboot "false";

// Si redémarrage, le faire à 3h du matin
Unattended-Upgrade::Automatic-Reboot-Time "03:00";

// Recevoir un email en cas de problème
Unattended-Upgrade::Mail "admin@example.com";
Unattended-Upgrade::MailReport "on-change";

// Supprimer les dépendances inutiles
Unattended-Upgrade::Remove-Unused-Dependencies "true";
```

> [!tip] Stratégie hybride
> 
> - **Mises à jour de sécurité** : Automatiques
> - **Autres mises à jour** : Manuelles avec tests
> 
> C'est le meilleur compromis sécurité/stabilité pour la plupart des serveurs.

### Comparaison des commandes entre distributions

Pour faciliter la transition entre distributions, voici un tableau de correspondance :

|Opération|Debian/Ubuntu|Fedora/RHEL|Arch Linux|
|---|---|---|---|
|Mettre à jour la liste|`apt update`|`dnf check-update`|`pacman -Sy`|
|Installer mises à jour|`apt upgrade`|`dnf upgrade`|`pacman -Su`|
|Mise à jour complète|`apt full-upgrade`|`dnf upgrade`|`pacman -Syu`|
|Chercher un paquet|`apt search paquet`|`dnf search paquet`|`pacman -Ss paquet`|
|Infos sur un paquet|`apt show paquet`|`dnf info paquet`|`pacman -Si paquet`|
|Lister les dépôts|`grep ^deb /etc/apt/sources.list`|`dnf repolist`|`grep ^\[.* /etc/pacman.conf`|
|Nettoyer le cache|`apt clean`|`dnf clean all`|`pacman -Sc`|
|Supprimer orphelins|`apt autoremove`|`dnf autoremove`|`pacman -Rns $(pacman -Qtdq)`|

### Vérification post-mise à jour

Après chaque mise à jour importante, effectuez ces vérifications :

```bash
# 1. Vérifier qu'aucun paquet n'est cassé
dpkg --audit

# 2. Vérifier les services critiques
systemctl status ssh
systemctl status networking

# 3. Vérifier l'espace disque restant
df -h

# 4. Voir si un redémarrage est nécessaire
[ -f /var/run/reboot-required ] && echo "Redémarrage nécessaire" || echo "Pas de redémarrage nécessaire"

# 5. Vérifier les logs pour des erreurs
journalctl -p err -b
```

> [!warning] Redémarrage du noyau Si le noyau Linux a été mis à jour, un redémarrage est nécessaire pour l'activer. Les services peuvent être mis à jour sans redémarrage, mais certaines mises à jour critiques nécessitent de relancer les services concernés.

### Récupération en cas de problème

Si une mise à jour cause des problèmes :

```bash
# 1. Voir l'historique des installations APT
grep " install " /var/log/apt/history.log
grep " upgrade " /var/log/apt/history.log

# 2. Downgrade d'un paquet spécifique (si disponible)
apt install paquet=version-précédente

# 3. Bloquer une version spécifique
apt-mark hold paquet

# 4. En dernier recours, restaurer depuis une sauvegarde
# (si vous avez utilisé timeshift ou équivalent)
```

**Prévention :**

```bash
# Créer un snapshot avant mise à jour (avec timeshift)
sudo timeshift --create --comments "Avant mise à jour système"
```

### Surveillance des dépôts

Pour éviter les mauvaises surprises, surveillez vos dépôts :

```bash
# Vérifier l'authenticité des dépôts
apt-key list

# Voir les paquets provenant de dépôts non-officiels
aptitude search '~i !~Adebian'  # Sur Debian
aptitude search '~i !~Aubuntu'  # Sur Ubuntu

# Lister les PPA installés (Ubuntu)
grep -r --include '*.list' '^deb ' /etc/apt/sources.list.d/
```

> [!info] Audit régulier Faites régulièrement le tri dans vos dépôts tiers. Supprimez ceux qui ne sont plus utilisés ou maintenus pour réduire la surface d'attaque et éviter les conflits.

---

## 📌 Points clés à retenir

> [!example] Résumé des commandes essentielles **Debian/Ubuntu :**
> 
> ```bash
> sudo apt update          # Mettre à jour la liste
> sudo apt upgrade         # Installer les mises à jour
> sudo apt full-upgrade    # Mise à jour complète
> sudo apt autoremove      # Nettoyer les orphelins
> ```
> 
> **Fedora/RHEL :**
> 
> ```bash
> sudo dnf check-update    # Vérifier les mises à jour
> sudo dnf upgrade         # Tout mettre à jour
> sudo dnf autoremove      # Nettoyer
> ```
> 
> **Arch Linux :**
> 
> ```bash
> sudo pacman -Syu         # Mise à jour complète
> sudo pacman -Sc          # Nettoyer le cache
> ```

### Concepts fondamentaux

✅ **apt update** met à jour la liste des paquets disponibles, pas les paquets eux-mêmes

✅ **apt upgrade** installe les mises à jour sans supprimer de paquets

✅ **apt full-upgrade** peut ajouter ou supprimer des paquets pour résoudre les dépendances

✅ Chaque distribution organise ses dépôts selon sa propre philosophie

✅ Les **dépôts de sécurité** doivent toujours être activés et prioritaires

✅ Les **dépôts tiers** augmentent les risques de conflits et de sécurité

✅ La configuration des sources varie selon la distribution :

- Debian/Ubuntu : `/etc/apt/sources.list`
- Fedora/RHEL : `/etc/yum.repos.d/*.repo`
- Arch : `/etc/pacman.conf`

✅ Toujours vérifier les **signatures GPG** des dépôts pour garantir leur authenticité

### Workflow optimal

1. **Avant** : Vérifier l'espace disque et faire une sauvegarde
2. **Pendant** : `update` puis `upgrade` (ou équivalent)
3. **Après** : Nettoyer avec `autoremove` et `clean`
4. **Contrôle** : Vérifier les services critiques et les logs

### Philosophie selon l'usage

|Usage|Distribution type|Approche|
|---|---|---|
|**Serveur production**|Debian Stable, RHEL|Mises à jour conservatrices, tests préalables|
|**Poste de travail**|Ubuntu, Fedora|Mises à jour régulières, semi-automatisées|
|**Station développement**|Arch, Fedora|Mises à jour fréquentes, dernières versions|

---

_La maîtrise de la gestion des mises à jour et des dépôts est une compétence fondamentale en administration Linux. Elle garantit la sécurité, la stabilité et la pérennité de vos systèmes._