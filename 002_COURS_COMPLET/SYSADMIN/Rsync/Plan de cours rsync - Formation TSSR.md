

## 📘 PARTIE 1 - Introduction et concepts de base

**Dossier Obsidian suggéré :** `01-introduction-rsync/`

**Sujets à couvrir :**

1. Présentation de rsync → `01-presentation-rsync.md`
    
    - Qu'est-ce que rsync
    - Utilité et cas d'usage courants
    - Avantages par rapport à cp, scp, ftp
    - Protocoles supportés (local, SSH, daemon)
2. Installation et vérification → `02-installation.md`
    
    - Installation sur Debian/Ubuntu
    - Installation sur RedHat/CentOS
    - Vérification de la version
    - Emplacement des fichiers de configuration

---

## 📘 PARTIE 2 - Syntaxe et options fondamentales

**Dossier Obsidian suggéré :** `02-syntaxe-options/`

**Sujets à couvrir :**

1. Syntaxe de base → `01-syntaxe-base.md`
    
    - Structure de la commande
    - Source et destination
    - Copie locale vs distante
    - Slash final et son importance
2. Options essentielles → `02-options-essentielles.md`
    
    - `-a` (archive)
    - `-v` (verbose)
    - `-z` (compression)
    - `-h` (human-readable)
    - `--progress`
3. Options de filtrage → `03-options-filtrage.md`
    
    - `--exclude`
    - `--include`
    - `--exclude-from`
    - `--delete`
    - `--dry-run`
4. Options de préservation → `04-options-preservation.md`
    
    - `-p` (permissions)
    - `-o` (owner)
    - `-g` (group)
    - `-t` (times)
    - `--links`

---

## 📘 PARTIE 3 - Synchronisation locale

**Dossier Obsidien suggéré :** `03-synchronisation-locale/`

**Sujets à couvrir :**

1. Copie simple de fichiers → `01-copie-fichiers.md`
    
    - Copie d'un fichier unique
    - Copie de plusieurs fichiers
    - Comportement avec répertoires
2. Synchronisation de répertoires → `02-sync-repertoires.md`
    
    - Synchronisation complète
    - Synchronisation incrémentale
    - Gestion du contenu existant
    - Utilisation de --delete
3. Exemples pratiques locaux → `03-exemples-pratiques.md`
    
    - Sauvegarde de /home
    - Synchronisation de dossiers de travail
    - Copie sélective avec exclusions

---

## 📘 PARTIE 4 - Synchronisation distante via SSH

**Dossier Obsidian suggéré :** `04-synchronisation-ssh/`

**Sujets à couvrir :**

1. Configuration SSH pour rsync → `01-config-ssh.md`
    
    - Syntaxe avec SSH
    - Authentification par mot de passe
    - Authentification par clé
    - Port SSH personnalisé
2. Push et Pull → `02-push-pull.md`
    
    - Envoi vers serveur distant (push)
    - Récupération depuis serveur distant (pull)
    - Choix de la direction
3. Cas d'usage SSH → `03-cas-usage-ssh.md`
    
    - Sauvegarde sur serveur de backup
    - Synchronisation entre serveurs
    - Déploiement de fichiers

---

## 📘 PARTIE 5 - Mode daemon et rsyncd

**Dossier Obsidian suggéré :** `05-mode-daemon/`

**Sujets à couvrir :**

1. Configuration du daemon → `01-config-daemon.md`
    
    - Fichier rsyncd.conf
    - Structure de configuration
    - Modules rsync
    - Options globales et par module
2. Sécurisation du daemon → `02-securisation.md`
    
    - Authentification par utilisateur/mot de passe
    - Restrictions d'hôtes
    - Mode read-only
    - Chroot
3. Utilisation du daemon → `03-utilisation-daemon.md`
    
    - Syntaxe client vers daemon
    - Liste des modules disponibles
    - Connexion authentifiée

---

## 📘 PARTIE 6 - Automatisation et scripting

**Dossier Obsidian suggéré :** `06-automatisation/`

**Sujets à couvrir :**

1. Scripts de sauvegarde → `01-scripts-sauvegarde.md`
    
    - Structure d'un script basique
    - Gestion des logs
    - Gestion des erreurs
    - Variables et paramètres
2. Planification avec cron → `02-planification-cron.md`
    
    - Création d'une tâche cron
    - Fréquences courantes
    - Redirections des sorties
    - Bonnes pratiques
3. Fichiers d'exclusion → `03-fichiers-exclusion.md`
    
    - Création de fichiers .rsync-exclude
    - Patterns et wildcards
    - Organisation des exclusions

---

## 📘 PARTIE 7 - Surveillance et dépannage

**Dossier Obsidian suggéré :** `07-surveillance-depannage/`

**Sujets à couvrir :**

1. Lecture des logs → `01-lecture-logs.md`
    
    - Format de sortie standard
    - Option --stats
    - Option --itemize-changes
    - Interprétation des codes
2. Problèmes courants → `02-problemes-courants.md`
    
    - Erreurs de permissions
    - Problèmes SSH
    - Erreurs réseau
    - Espace disque insuffisant
3. Optimisation des performances → `03-optimisation.md`
    
    - Utilisation de la bande passante
    - Option --bwlimit
    - Compression adaptée
    - Taille des transferts