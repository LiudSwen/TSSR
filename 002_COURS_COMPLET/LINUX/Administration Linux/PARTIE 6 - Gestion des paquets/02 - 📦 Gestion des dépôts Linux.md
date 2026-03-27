

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

## 🎯 Introduction aux dépôts

Les **dépôts** (repositories) sont des serveurs qui hébergent des collections de paquets logiciels. Ils constituent l'infrastructure centrale de la gestion des paquets sous Linux, permettant l'installation, la mise à jour et la suppression de logiciels de manière sécurisée et contrôlée.

> [!info] Pourquoi les dépôts sont essentiels
> 
> - **Sécurité** : Les paquets sont signés et vérifiés
> - **Cohérence** : Versions testées et compatibles entre elles
> - **Simplicité** : Installation en une commande sans chercher sur le web
> - **Mises à jour** : Système centralisé de mises à jour de sécurité

---

## 📄 /etc/apt/sources.list (Debian)

Le fichier `/etc/apt/sources.list` est le fichier principal de configuration des dépôts sous Debian. Il définit où APT doit chercher les paquets.

### Structure du fichier

```bash
# Format général :
deb [options] URI distribution composants

# Exemple concret :
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian bookworm main contrib non-free
```

### Décryptage de la syntaxe

|Élément|Description|Exemples|
|---|---|---|
|**deb**|Type de dépôt (binaires)|`deb` pour les paquets, `deb-src` pour les sources|
|**URI**|Adresse du dépôt|`http://deb.debian.org/debian`, `https://mirror.example.com`|
|**distribution**|Version de Debian|`bookworm`, `bullseye`, `stable`, `testing`|
|**composants**|Sections du dépôt|`main`, `contrib`, `non-free`, `non-free-firmware`|

### Les composants Debian expliqués

```bash
# main : Logiciels 100% libres et maintenus par Debian
deb http://deb.debian.org/debian bookworm main

# contrib : Logiciels libres mais dépendant de non-libre
deb http://deb.debian.org/debian bookworm main contrib

# non-free : Logiciels propriétaires
deb http://deb.debian.org/debian bookworm main contrib non-free

# non-free-firmware : Micrologiciels propriétaires (nouveau depuis Debian 12)
deb http://deb.debian.org/debian bookworm main non-free-firmware
```

> [!warning] Sections de mise à jour Les dépôts de sécurité et de mise à jour sont séparés :
> 
> ```bash
> # Mises à jour de sécurité (CRITIQUE)
> deb http://security.debian.org/debian-security bookworm-security main
> 
> # Mises à jour stables
> deb http://deb.debian.org/debian bookworm-updates main
> 
> # Mises à jour proposées (backports)
> deb http://deb.debian.org/debian bookworm-backports main
> ```

### Exemple de configuration complète

```bash
# Debian 12 (Bookworm) - Configuration standard

# Dépôt principal
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian bookworm main contrib non-free

# Mises à jour de sécurité
deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
deb-src http://security.debian.org/debian-security bookworm-security main contrib non-free

# Mises à jour stables
deb http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian bookworm-updates main contrib non-free
```

### Édition du fichier

```bash
# Sauvegarde avant modification (TOUJOURS)
sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup

# Édition avec votre éditeur préféré
sudo nano /etc/apt/sources.list
# ou
sudo vim /etc/apt/sources.list

# Après modification, mettre à jour la liste des paquets
sudo apt update
```

> [!tip] Utiliser un miroir proche Pour améliorer les vitesses de téléchargement, remplacez `deb.debian.org` par un miroir géographiquement proche :
> 
> ```bash
> # France
> deb http://ftp.fr.debian.org/debian bookworm main
> 
> # Liste des miroirs : https://www.debian.org/mirror/list
> ```

---

## 📁 /etc/apt/sources.list.d/ (Ubuntu)

Ubuntu utilise une approche modulaire avec le répertoire `/etc/apt/sources.list.d/` qui contient des fichiers `.list` séparés pour chaque source additionnelle.

### Philosophie d'Ubuntu

```bash
# Fichier principal (minimal sur Ubuntu moderne)
/etc/apt/sources.list

# Fichiers additionnels (un par dépôt)
/etc/apt/sources.list.d/
├── ubuntu.sources          # Format DEB822 (nouveau)
├── google-chrome.list      # Dépôt Chrome
├── docker.list             # Dépôt Docker
└── vscode.list             # Dépôt VS Code
```

> [!info] Nouveau format DEB822 Depuis Ubuntu 22.04, Ubuntu favorise le format DEB822 dans des fichiers `.sources` :
> 
> ```
> Types: deb
> URIs: http://archive.ubuntu.com/ubuntu
> Suites: noble
> Components: main restricted universe multiverse
> Signed-By: /usr/share/keyrings/ubuntu-archive-keyring.gpg
> ```

### Avantages de l'approche modulaire

|Avantage|Explication|
|---|---|
|**Séparation**|Chaque dépôt tiers dans son propre fichier|
|**Gestion**|Facile d'activer/désactiver (renommer en `.list.disabled`)|
|**Clarté**|Identification rapide de la source d'un paquet|
|**Scripts**|Ajout automatisé de dépôts sans toucher au fichier principal|

### Exemple pratique : Ajouter un dépôt tiers

```bash
# Méthode 1 : Création manuelle d'un fichier .list
echo "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | \
sudo tee /etc/apt/sources.list.d/docker.list

# Méthode 2 : Format DEB822 (moderne)
sudo tee /etc/apt/sources.list.d/docker.sources << EOF
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: $(lsb_release -cs)
Components: stable
Architectures: amd64
Signed-By: /usr/share/keyrings/docker-archive-keyring.gpg
EOF

# Mise à jour
sudo apt update
```

### Désactiver temporairement un dépôt

```bash
# Désactiver (renommer)
sudo mv /etc/apt/sources.list.d/docker.list /etc/apt/sources.list.d/docker.list.disabled

# Réactiver
sudo mv /etc/apt/sources.list.d/docker.list.disabled /etc/apt/sources.list.d/docker.list

# Alternative : commenter les lignes dans le fichier
sudo sed -i 's/^deb/#deb/' /etc/apt/sources.list.d/docker.list
```

> [!tip] Lister tous les dépôts actifs
> 
> ```bash
> # Voir tous les dépôts configurés
> grep -r --include '*.list' '^deb ' /etc/apt/sources.list /etc/apt/sources.list.d/
> 
> # Avec apt (plus lisible)
> apt-cache policy
> ```

---

## ⚖️ Différences entre Debian et Ubuntu

Bien que basé sur Debian, Ubuntu a des différences significatives dans sa gestion des dépôts.

### Comparaison des structures

|Aspect|Debian|Ubuntu|
|---|---|---|
|**Fichier principal**|`/etc/apt/sources.list` (centralisé)|`/etc/apt/sources.list` + `/etc/apt/sources.list.d/`|
|**Composants**|`main`, `contrib`, `non-free`|`main`, `restricted`, `universe`, `multiverse`|
|**Versions**|Noms (bookworm, bullseye)|Noms + adjectifs (noble, jammy)|
|**Miroirs**|`deb.debian.org`|`archive.ubuntu.com` ou régionaux|
|**PPA**|❌ Non supporté officiellement|✅ Supporté nativement|
|**Cycle**|~2 ans (stable)|6 mois (normal) ou 2 ans (LTS)|

### Composants Ubuntu expliqués

```bash
# main : Logiciels libres supportés officiellement par Ubuntu
deb http://archive.ubuntu.com/ubuntu noble main

# restricted : Pilotes propriétaires supportés par Ubuntu
deb http://archive.ubuntu.com/ubuntu noble main restricted

# universe : Logiciels libres maintenus par la communauté
deb http://archive.ubuntu.com/ubuntu noble universe

# multiverse : Logiciels propriétaires non supportés
deb http://archive.ubuntu.com/ubuntu noble multiverse
```

### Dépôts par défaut Debian vs Ubuntu

**Debian (bookworm) :**

```bash
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb http://security.debian.org/debian-security bookworm-security main
deb http://deb.debian.org/debian bookworm-updates main
```

**Ubuntu (24.04 Noble) :**

```bash
deb http://archive.ubuntu.com/ubuntu noble main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu noble-updates main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu noble-security main restricted universe multiverse
deb http://archive.ubuntu.com/ubuntu noble-backports main restricted universe multiverse
```

> [!warning] Philosophies différentes
> 
> - **Debian** privilégie la stabilité et les logiciels 100% libres par défaut
> - **Ubuntu** inclut plus de logiciels propriétaires par défaut pour la compatibilité matérielle

### Nommage des versions

```bash
# Debian : noms de personnages Toy Story
# 12 = Bookworm
# 11 = Bullseye
# 10 = Buster

# Ubuntu : Adjectif + Animal (ordre alphabétique)
# 24.04 = Noble Numbat
# 22.04 = Jammy Jellyfish
# 20.04 = Focal Fossa

# Utiliser le nom de code plutôt que "stable" est recommandé
deb http://deb.debian.org/debian bookworm main  # ✅ Bon
deb http://deb.debian.org/debian stable main    # ⚠️ Change à chaque release
```

---

## 🎁 Ajout de PPA (Ubuntu uniquement)

Les **PPA** (Personal Package Archive) sont un système spécifique à Ubuntu permettant aux développeurs de distribuer des versions plus récentes de logiciels.

### Concept et fonctionnement

> [!info] Qu'est-ce qu'un PPA ? Un PPA est un dépôt hébergé sur les serveurs Launchpad de Canonical, permettant à n'importe qui de distribuer des paquets. Format : `ppa:utilisateur/nom-ppa`

### Ajout d'un PPA

```bash
# Méthode recommandée : add-apt-repository
sudo add-apt-repository ppa:graphics-drivers/ppa
sudo apt update

# Ce qui se passe en coulisses :
# 1. Télécharge la clé GPG du PPA
# 2. Crée /etc/apt/sources.list.d/graphics-drivers-ubuntu-ppa-noble.list
# 3. Ajoute la ligne : deb https://ppa.launchpadcontent.net/graphics-drivers/ppa/ubuntu noble main
```

### Options avancées

```bash
# Ajouter sans confirmation
sudo add-apt-repository -y ppa:graphics-drivers/ppa

# Ajouter sans mettre à jour automatiquement
sudo add-apt-repository --no-update ppa:graphics-drivers/ppa

# Supprimer un PPA
sudo add-apt-repository --remove ppa:graphics-drivers/ppa

# Alternative manuelle
sudo rm /etc/apt/sources.list.d/graphics-drivers-ubuntu-ppa-*.list
sudo apt update
```

### Structure d'un dépôt PPA

```bash
# Format automatique créé par add-apt-repository
deb https://ppa.launchpadcontent.net/graphics-drivers/ppa/ubuntu noble main
# deb-src https://ppa.launchpadcontent.net/graphics-drivers/ppa/ubuntu noble main

# Décomposition :
# - Hébergeur : ppa.launchpadcontent.net
# - Utilisateur : graphics-drivers
# - Nom du PPA : ppa
# - Distribution : noble (détectée automatiquement)
# - Composant : main (toujours main pour les PPA)
```

### Lister les PPA installés

```bash
# Méthode 1 : Fichiers dans sources.list.d
ls /etc/apt/sources.list.d/*.list | grep ppa

# Méthode 2 : Contenu des fichiers
grep -r "ppa.launchpad" /etc/apt/sources.list.d/

# Méthode 3 : Avec apt
apt-cache policy | grep -i ppa
```

> [!warning] Risques des PPA
> 
> - **Non officiels** : Pas vérifiés par Ubuntu
> - **Qualité variable** : Peuvent causer des instabilités
> - **Dépendances** : Peuvent entrer en conflit avec les dépôts officiels
> - **Sécurité** : Faites confiance uniquement aux PPA reconnus
> 
> ⚠️ N'ajoutez jamais un PPA sans vérifier sa réputation !

### Exemples de PPA populaires

```bash
# Pilotes graphiques NVIDIA récents
sudo add-apt-repository ppa:graphics-drivers/ppa

# Git en version récente
sudo add-apt-repository ppa:git-core/ppa

# LibreOffice dernière version
sudo add-apt-repository ppa:libreoffice/ppa

# Wine (exécuter des applications Windows)
sudo add-apt-repository ppa:ubuntu-wine/ppa
```

### Purger complètement un PPA

```bash
# Supprimer le dépôt
sudo add-apt-repository --remove ppa:example/ppa

# Rétrograder les paquets vers les versions officielles
sudo apt install ppa-purge
sudo ppa-purge ppa:example/ppa

# ppa-purge va :
# - Supprimer le PPA
# - Réinstaller les versions officielles des paquets
# - Nettoyer les dépendances orphelines
```

> [!tip] PPA alternatif : Flatpak et Snap Pour des logiciels récents sans PPA, considérez :
> 
> - **Snap** : Intégré à Ubuntu, paquets universels
> - **Flatpak** : Alternative open source
> - **AppImage** : Binaires portables
> 
> Ces solutions évitent les risques liés aux PPA tiers.

---

## 🔐 Clés GPG des dépôts

Les **clés GPG** garantissent l'authenticité et l'intégrité des paquets en vérifiant que les dépôts sont légitimes et que les paquets n'ont pas été modifiés.

### Pourquoi les clés GPG sont cruciales

> [!warning] Sécurité fondamentale Sans vérification GPG, un attaquant pourrait :
> 
> - Intercepter les téléchargements de paquets
> - Injecter du code malveillant
> - Compromettre votre système
> 
> APT refuse d'installer des paquets non signés ou avec une signature invalide.

### Fonctionnement

```bash
# Processus de vérification :
# 1. Le mainteneur signe les métadonnées du dépôt avec sa clé privée
# 2. Votre système possède la clé publique correspondante
# 3. APT vérifie la signature avant chaque installation
# 4. Installation bloquée si la signature ne correspond pas
```

### Emplacements des clés

|Emplacement|Usage|Format|
|---|---|---|
|`/etc/apt/trusted.gpg`|Ancien (déprécié)|Trousseau binaire|
|`/etc/apt/trusted.gpg.d/`|Actuel|Fichiers `.gpg` individuels|
|`/usr/share/keyrings/`|Recommandé (moderne)|Clés système et tierces|

> [!info] Migration vers /usr/share/keyrings/ Depuis 2021, la bonne pratique est de stocker les clés dans `/usr/share/keyrings/` et de les référencer explicitement dans les sources.

### Ajouter une clé GPG (méthode moderne)

```bash
# Exemple : Ajouter le dépôt Docker avec sa clé

# 1. Télécharger et installer la clé GPG
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | \
sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# 2. Ajouter le dépôt en référençant explicitement la clé
echo \
  "deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | \
sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 3. Mettre à jour
sudo apt update
```

### Décryptage de la syntaxe `signed-by`

```bash
# Ancienne méthode (clé globale, déprécié) :
deb https://download.docker.com/linux/ubuntu noble stable

# Nouvelle méthode (clé spécifique, recommandé) :
deb [signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
    https://download.docker.com/linux/ubuntu noble stable

# Avantages :
# - Chaque dépôt utilise SA clé spécifique
# - Pas de pollution du trousseau global
# - Plus sécurisé et modulaire
```

### Ajouter une clé GPG (méthode classique)

```bash
# Méthode 1 : Depuis un serveur de clés
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys XXXXXXXX

# Méthode 2 : Depuis une URL
wget -qO - https://example.com/key.gpg | sudo apt-key add -

# Méthode 3 : Depuis un fichier
sudo apt-key add /path/to/keyfile.gpg

# ⚠️ apt-key est déprécié depuis Ubuntu 20.04 !
# Préférez la méthode moderne avec signed-by
```

### Lister les clés installées

```bash
# Anciennes clés (trusted.gpg)
sudo apt-key list

# Clés dans /usr/share/keyrings/
ls -lh /usr/share/keyrings/*.gpg

# Clés dans /etc/apt/trusted.gpg.d/
ls -lh /etc/apt/trusted.gpg.d/*.gpg

# Informations détaillées sur une clé
gpg --show-keys /usr/share/keyrings/docker-archive-keyring.gpg
```

### Résoudre les erreurs de clés

```bash
# Erreur typique :
# "The following signatures couldn't be verified because the public key is not available"

# Solution 1 : Identifier la clé manquante
sudo apt update
# Notez le code de la clé manquante (ex: NO_PUBKEY 0E98404D386FA1D9)

# Solution 2 : Récupérer la clé
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 0E98404D386FA1D9

# Solution 3 : Réinstaller les clés Ubuntu (cas extrême)
sudo apt install --reinstall ubuntu-keyring
```

> [!tip] Vérifier l'empreinte d'une clé Avant d'importer une clé, vérifiez toujours son empreinte sur le site officiel :
> 
> ```bash
> # Afficher l'empreinte d'une clé téléchargée
> gpg --show-keys --with-fingerprint /tmp/downloaded-key.gpg
> 
> # Comparer avec l'empreinte publiée officiellement
> # Exemple Docker : 9DC8 5822 9FC7 DD38 854A  E2D8 8D81 803C 0EBF CD88
> ```

### Supprimer une clé

```bash
# Méthode moderne : supprimer le fichier de clé
sudo rm /usr/share/keyrings/unwanted-keyring.gpg

# Ancienne méthode : apt-key
sudo apt-key del XXXXXXXX

# Identifier l'ID d'une clé pour la supprimer
sudo apt-key list
# Repérez les 8 derniers caractères de l'ID de clé
```

### Clés et format DEB822

```bash
# Dans un fichier .sources (format moderne)
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: noble
Components: stable
Architectures: amd64
Signed-By: /usr/share/keyrings/docker-archive-keyring.gpg

# La clé est référencée directement dans la configuration
# Plus besoin de trusted.gpg global
```

> [!example] Workflow complet : Ajouter un dépôt sécurisé
> 
> ```bash
> # 1. Créer le répertoire keyrings si nécessaire
> sudo mkdir -p /usr/share/keyrings
> 
> # 2. Télécharger et importer la clé
> curl -fsSL https://example.com/repo-key.gpg | \
> sudo gpg --dearmor -o /usr/share/keyrings/example-keyring.gpg
> 
> # 3. Vérifier l'empreinte de la clé
> gpg --show-keys /usr/share/keyrings/example-keyring.gpg
> 
> # 4. Ajouter le dépôt avec référence à la clé
> echo "deb [signed-by=/usr/share/keyrings/example-keyring.gpg] https://example.com/repo stable main" | \
> sudo tee /etc/apt/sources.list.d/example.list
> 
> # 5. Mettre à jour et installer
> sudo apt update
> sudo apt install package-name
> ```

---

## 🔍 Pièges courants et bonnes pratiques

### ⚠️ Erreurs fréquentes

> [!warning] Ne jamais mélanger les versions
> 
> ```bash
> # ❌ MAUVAIS : Mélanger Debian stable et testing
> deb http://deb.debian.org/debian bookworm main
> deb http://deb.debian.org/debian testing main
> 
> # ❌ MAUVAIS : Mélanger Ubuntu et Debian
> deb http://archive.ubuntu.com/ubuntu noble main
> deb http://deb.debian.org/debian bookworm main
> 
> # Résultat : Système cassé et instable !
> ```

> [!warning] Attention aux PPA non maintenus
> 
> ```bash
> # Vérifier la date de dernière mise à jour d'un PPA
> # Sur https://launchpad.net/~owner/+archive/ubuntu/ppa-name
> 
> # Si aucune mise à jour depuis 2+ ans : ÉVITER
> ```

### ✅ Bonnes pratiques essentielles

1. **Toujours sauvegarder avant modification**

```bash
sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup.$(date +%Y%m%d)
sudo cp -r /etc/apt/sources.list.d /etc/apt/sources.list.d.backup.$(date +%Y%m%d)
```

2. **Tester après chaque modification**

```bash
sudo apt update
# Si erreur, restaurer la sauvegarde immédiatement
```

3. **Utiliser HTTPS quand possible**

```bash
# ✅ Sécurisé
deb https://deb.debian.org/debian bookworm main

# ⚠️ Moins sûr (mais la signature GPG protège quand même)
deb http://deb.debian.org/debian bookworm main
```

4. **Documenter les modifications**

```bash
# Ajouter des commentaires dans vos fichiers
# Date: 2024-12-26
# Raison: Installation de Docker pour projet X
deb [signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
https://download.docker.com/linux/ubuntu noble stable
```

5. **Nettoyer régulièrement**

```bash
# Supprimer les dépôts non utilisés
sudo apt autoremove
sudo apt autoclean

# Vérifier les dépôts orphelins
sudo apt list --installed | grep -v -e "ubuntu" -e "debian"
```

### 🎯 Astuces avancées

```bash
# Voir quel dépôt fournit un paquet
apt-cache policy nom-paquet

# Forcer l'installation depuis un dépôt spécifique
sudo apt install -t bookworm-backports nom-paquet

# Lister tous les paquets d'un dépôt spécifique
apt-cache dumpavail | grep "Filename.*ppa" 

# Tester un sources.list sans modifier le système
apt-get update -o Dir::Etc::sourcelist=/tmp/test.list
```

---

## 📊 Résumé des commandes essentielles

```bash
# Gestion des dépôts Debian
sudo nano /etc/apt/sources.list
sudo apt update

# Gestion des dépôts Ubuntu (ajout)
sudo add-apt-repository ppa:owner/ppa-name
sudo add-apt-repository --remove ppa:owner/ppa-name

# Clés GPG (méthode moderne)
curl -fsSL https://url/key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/name.gpg

# Clés GPG (ancienne méthode, déprécié)
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys KEYID
sudo apt-key list
sudo apt-key del KEYID

# Diagnostic
apt-cache policy
apt-cache policy nom-paquet
sudo apt update

# Nettoyage
sudo apt autoremove
sudo apt autoclean
```

---

_Cours réalisé pour l'administration système Linux - Gestion des dépôts de paquets_