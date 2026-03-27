

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

## Introduction à dpkg

**dpkg** (Debian Package) est l'outil de bas niveau pour gérer les paquets sur les systèmes Debian et dérivés (Ubuntu, Linux Mint, etc.). Contrairement aux outils de haut niveau comme APT, dpkg ne gère **pas automatiquement les dépendances**.

> [!info] Pourquoi utiliser dpkg ?
> 
> - **Contrôle précis** : manipulation directe des paquets .deb
> - **Diagnostic** : inspection détaillée de l'état du système
> - **Installation manuelle** : paquets téléchargés hors dépôts
> - **Scripting** : automatisation de tâches d'administration

> [!warning] Limite importante dpkg ne résout pas les dépendances. Si un paquet nécessite d'autres paquets, vous devrez les installer manuellement ou utiliser `apt` pour finaliser l'installation.

---

## Installation de paquets .deb

### 📥 Installation basique

```bash
# Installation d'un paquet .deb
sudo dpkg -i paquet.deb

# Installation de plusieurs paquets
sudo dpkg -i paquet1.deb paquet2.deb paquet3.deb

# Installation avec wildcard
sudo dpkg -i *.deb
```

> [!example] Exemple pratique
> 
> ```bash
> # Téléchargement et installation de Google Chrome
> wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
> sudo dpkg -i google-chrome-stable_current_amd64.deb
> 
> # Si des dépendances manquent, vous verrez des erreurs
> # Résolution avec apt :
> sudo apt install -f
> ```

### 🔧 Options d'installation

|Option|Description|Utilisation|
|---|---|---|
|`-i, --install`|Installe le paquet|Standard|
|`--force-depends`|Ignore les dépendances|⚠️ Dangereux|
|`--force-conflicts`|Ignore les conflits|⚠️ Dangereux|
|`--force-overwrite`|Écrase les fichiers existants|Résolution de conflits|
|`--no-act`|Simulation (dry-run)|Test avant installation|

```bash
# Simulation d'installation
sudo dpkg --no-act -i paquet.deb

# Forcer l'installation malgré des conflits (à utiliser avec précaution)
sudo dpkg -i --force-overwrite paquet.deb
```

> [!tip] Astuce Après une installation dpkg qui échoue à cause de dépendances manquantes, utilisez `sudo apt install -f` pour résoudre automatiquement les problèmes.

---

## Interrogation des paquets

### dpkg -l : Lister les paquets

La commande `dpkg -l` affiche la liste des paquets installés sur le système.

```bash
# Lister tous les paquets installés
dpkg -l

# Filtrer par nom de paquet
dpkg -l | grep firefox

# Recherche avec pattern
dpkg -l 'lib*'

# Afficher uniquement un paquet spécifique
dpkg -l firefox
```

#### 📊 Comprendre la sortie

```
Souhait=inconnU/Installé/suppRimé/Purgé/H=à garder
| État=Non/Installé/fichier-Config/dépaqUeté/échec-conFig/H=semi-installé/W=attend-traitement-déclenchements
|/ Err?=(aucune)/besoin Réinstallation (État,Err: majuscule=mauvais)
||/ Nom                    Version          Architecture Description
+++-======================-================-============-=====================================
ii  firefox               120.0+build2-1    amd64        Mozilla Firefox web browser
rc  apache2               2.4.52-1ubuntu4   amd64        Apache HTTP Server
```

**Statuts importants** :

|Code|Signification|
|---|---|
|`ii`|Installé correctement|
|`rc`|Supprimé mais fichiers de config restants|
|`iU`|Installé mais non configuré|
|`iF`|Installation échouée|

> [!tip] Filtrage efficace
> 
> ```bash
> # Compter les paquets installés
> dpkg -l | grep '^ii' | wc -l
> 
> # Lister uniquement les noms de paquets
> dpkg -l | awk '/^ii/ {print $2}'
> 
> # Paquets avec fichiers de config résiduels
> dpkg -l | grep '^rc'
> ```

---

### dpkg -L : Lister les fichiers d'un paquet

Cette commande affiche **tous les fichiers** installés par un paquet donné.

```bash
# Lister les fichiers d'un paquet
dpkg -L firefox

# Compter le nombre de fichiers
dpkg -L firefox | wc -l

# Trouver les exécutables d'un paquet
dpkg -L firefox | grep bin/
```

> [!example] Exemple de sortie
> 
> ```bash
> $ dpkg -L curl
> /.
> /usr
> /usr/bin
> /usr/bin/curl
> /usr/share
> /usr/share/doc
> /usr/share/doc/curl
> /usr/share/doc/curl/copyright
> /usr/share/man
> /usr/share/man/man1
> /usr/share/man/man1/curl.1.gz
> ```

> [!tip] Cas d'usage pratiques
> 
> ```bash
> # Vérifier où est installé un service
> dpkg -L nginx | grep systemd
> 
> # Localiser les fichiers de configuration
> dpkg -L apache2 | grep '\.conf$'
> 
> # Trouver la documentation d'un paquet
> dpkg -L python3 | grep '/doc/'
> ```

---

### dpkg -S : Rechercher le paquet propriétaire

Cette commande identifie **quel paquet** a installé un fichier donné sur le système.

```bash
# Rechercher le paquet propriétaire d'un fichier
dpkg -S /usr/bin/python3

# Rechercher avec un pattern
dpkg -S */python3

# Rechercher plusieurs fichiers
dpkg -S /bin/bash /usr/bin/vim
```

> [!example] Exemples pratiques
> 
> ```bash
> $ dpkg -S /usr/bin/curl
> curl: /usr/bin/curl
> 
> $ dpkg -S /etc/nginx/nginx.conf
> nginx-common: /etc/nginx/nginx.conf
> 
> # Si le fichier n'appartient à aucun paquet :
> $ dpkg -S /tmp/monfichier
> dpkg-query: aucun paquet trouvé correspondant à /tmp/monfichier
> ```

> [!tip] Astuces avancées
> 
> ```bash
> # Trouver tous les paquets qui contiennent "libssl"
> dpkg -S libssl | cut -d: -f1 | sort -u
> 
> # Identifier le paquet d'une commande dans le PATH
> dpkg -S $(which htop)
> 
> # Vérifier si un fichier appartient au système
> if dpkg -S /path/to/file 2>/dev/null; then
>     echo "Fichier géré par un paquet"
> else
>     echo "Fichier manuel ou externe"
> fi
> ```

---

## Manipulation directe des paquets

### 🗑️ Suppression de paquets

```bash
# Supprimer un paquet (garde les fichiers de configuration)
sudo dpkg -r paquet

# Purger complètement un paquet (supprime aussi les configs)
sudo dpkg -P paquet

# Supprimer plusieurs paquets
sudo dpkg -r paquet1 paquet2 paquet3
```

> [!warning] Différence remove vs purge
> 
> - `dpkg -r` : supprime les fichiers du paquet mais **conserve** les fichiers de configuration
> - `dpkg -P` : supprime **tout**, y compris les configurations personnalisées

### 📋 Informations sur un paquet

```bash
# Afficher les informations d'un paquet installé
dpkg -s firefox

# Afficher les informations d'un fichier .deb
dpkg -I paquet.deb

# Lister le contenu d'un fichier .deb (avant installation)
dpkg -c paquet.deb
```

> [!example] Sortie de dpkg -s
> 
> ```bash
> $ dpkg -s curl
> Package: curl
> Status: install ok installed
> Priority: optional
> Section: web
> Installed-Size: 451
> Maintainer: Ubuntu Developers
> Architecture: amd64
> Version: 7.81.0-1ubuntu1.15
> Depends: libc6, libcurl4, zlib1g
> Description: command line tool for transferring data with URL syntax
> ```

### 🔍 Vérification de l'intégrité

```bash
# Vérifier l'intégrité des fichiers d'un paquet
dpkg -V paquet

# Vérifier tous les paquets installés
dpkg -V
```

Si des fichiers ont été modifiés, dpkg affichera les différences détectées.

---

## Gestion avancée

### 🔄 Reconfiguration de paquets

```bash
# Reconfigurer un paquet
sudo dpkg-reconfigure paquet

# Reconfigurer avec interface graphique (si disponible)
sudo dpkg-reconfigure -plow paquet

# Reconfigurer les locales du système
sudo dpkg-reconfigure locales

# Reconfigurer le fuseau horaire
sudo dpkg-reconfigure tzdata
```

### 🛠️ Réparation du système

```bash
# Configurer tous les paquets non configurés
sudo dpkg --configure -a

# Forcer la reconfiguration d'un paquet problématique
sudo dpkg --configure paquet

# Supprimer les informations d'un paquet cassé
sudo dpkg --remove --force-remove-reinstreq paquet
```

> [!tip] Commande de secours Si APT refuse de fonctionner à cause de paquets cassés :
> 
> ```bash
> sudo dpkg --configure -a
> sudo apt install -f
> ```

### 📦 Extraction sans installation

```bash
# Extraire le contenu d'un .deb dans un répertoire
dpkg-deb -x paquet.deb /tmp/extraction/

# Extraire les métadonnées de contrôle
dpkg-deb -e paquet.deb /tmp/control/

# Créer un paquet .deb à partir d'un répertoire
dpkg-deb --build mon-paquet/
```

### 📊 Statistiques et analyse

```bash
# Taille des paquets installés
dpkg-query -W -f='${Installed-Size}\t${Package}\n' | sort -rn | head

# Lister les paquets d'une architecture spécifique
dpkg -l | grep :i386

# Afficher la version d'un paquet
dpkg-query -W -f='${Version}' paquet
```

---

## Pièges courants et bonnes pratiques

### ⚠️ Erreurs fréquentes

> [!warning] Problème : Dépendances non satisfaites
> 
> ```bash
> # Erreur typique :
> dpkg: dependency problems prevent configuration of paquet:
>  paquet depends on libxyz; however:
>   Package libxyz is not installed.
> 
> # Solution :
> sudo apt install -f
> ```

> [!warning] Problème : Paquet cassé bloque APT
> 
> ```bash
> # Solution étape par étape :
> sudo dpkg --remove --force-remove-reinstreq paquet-problematique
> sudo apt update
> sudo apt install -f
> ```

> [!warning] Problème : Fichiers en conflit
> 
> ```bash
> # Erreur :
> trying to overwrite '/usr/bin/fichier', which is also in package autre-paquet
> 
> # Solution temporaire (vérifier avant !) :
> sudo dpkg -i --force-overwrite paquet.deb
> ```

### ✅ Bonnes pratiques

1. **Toujours préférer APT pour l'installation normale**
    
    ```bash
    # Bon : APT gère les dépendances
    sudo apt install paquet
    
    # À éviter sauf cas spécial
    sudo dpkg -i paquet.deb
    ```
    
2. **Vérifier avant de forcer**
    
    ```bash
    # Simuler d'abord
    sudo dpkg --no-act -i paquet.deb
    
    # Inspecter le contenu
    dpkg -c paquet.deb
    ```
    
3. **Sauvegarder les listes de paquets**
    
    ```bash
    # Exporter la liste des paquets installés
    dpkg --get-selections > paquets-installes.txt
    
    # Restaurer sur un nouveau système
    sudo dpkg --set-selections < paquets-installes.txt
    sudo apt-get dselect-upgrade
    ```
    
4. **Nettoyer les paquets résiduels**
    
    ```bash
    # Lister les paquets avec config résiduelle
    dpkg -l | grep '^rc'
    
    # Purger tous les paquets résiduels
    dpkg -l | grep '^rc' | awk '{print $2}' | xargs sudo dpkg -P
    ```
    

> [!tip] Mémo des commandes essentielles
> 
> |Commande|Action|
> |---|---|
> |`dpkg -i`|Installer un .deb|
> |`dpkg -r`|Supprimer (garder config)|
> |`dpkg -P`|Purger complètement|
> |`dpkg -l`|Lister les paquets|
> |`dpkg -L`|Fichiers d'un paquet|
> |`dpkg -S`|Paquet propriétaire d'un fichier|
> |`dpkg -s`|Infos sur un paquet installé|
> |`dpkg -I`|Infos sur un fichier .deb|
> |`dpkg --configure -a`|Réparer les paquets cassés|

---

> [!info] 💡 Rappel important dpkg est un outil puissant mais de **bas niveau**. Pour un usage quotidien, privilégiez les outils de haut niveau (APT, aptitude) qui gèrent automatiquement les dépendances et les mises à jour. Utilisez dpkg pour les cas spécifiques nécessitant un contrôle fin ou pour le diagnostic système.