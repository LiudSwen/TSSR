

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

## 🎯 Introduction aux formats alternatifs

Les formats de paquets alternatifs répondent aux limitations des gestionnaires traditionnels (APT, YUM, DNF) en proposant une approche différente de la distribution et de l'isolation des applications.

> [!info] Pourquoi des formats alternatifs ?
> 
> - **Isolation des dépendances** : Chaque application embarque ses propres librairies
> - **Distribution universelle** : Un seul paquet pour toutes les distributions
> - **Mises à jour simplifiées** : Indépendantes du système de base
> - **Sandboxing** : Sécurité renforcée par l'isolation des applications

**Contexte d'utilisation** : Ces formats sont particulièrement utiles quand vous avez besoin d'une version spécifique d'une application qui n'est pas disponible dans les dépôts officiels, ou quand vous souhaitez isoler une application du reste du système.

---

## 📦 Snap (Ubuntu)

### Architecture et fonctionnement

Snap est un système de gestion de paquets développé par Canonical, l'entreprise derrière Ubuntu. Il repose sur une architecture unique qui encapsule les applications et leurs dépendances.

> [!info] Concepts clés de Snap **Snap** : Le paquet applicatif auto-contenu **Snapd** : Le daemon qui gère l'installation et l'exécution des snaps **Snap Store** : Le dépôt centralisé des applications snap **Confinement** : Système de sécurité qui contrôle l'accès aux ressources système

#### Niveaux de confinement

|Niveau|Description|Accès système|Cas d'usage|
|---|---|---|---|
|`strict`|Confinement maximal|Très limité, via interfaces|Applications génériques|
|`classic`|Pas de confinement|Accès complet|Outils de développement, IDE|
|`devmode`|Mode développement|Accès complet + logs|Développement de snaps|

#### Structure d'un snap

```bash
# Un snap est composé de :
# - squashfs : Système de fichiers compressé en lecture seule
# - meta/ : Métadonnées du snap (snap.yaml)
# - Dépendances : Toutes les librairies nécessaires incluses
```

> [!tip] Avantage clé Les snaps utilisent un système de fichiers en lecture seule (squashfs), ce qui garantit l'intégrité de l'application et facilite les rollbacks.

---

### Installation et configuration

#### Installation de snapd

```bash
# Sur Ubuntu (pré-installé depuis 16.04)
sudo apt update
sudo apt install snapd

# Sur Debian
sudo apt update
sudo apt install snapd
sudo systemctl enable --now snapd.socket

# Sur Fedora
sudo dnf install snapd
sudo ln -s /var/lib/snapd/snap /snap

# Sur Arch Linux (via AUR)
git clone https://aur.archlinux.org/snapd.git
cd snapd
makepkg -si
sudo systemctl enable --now snapd.socket

# Vérifier l'installation
snap version
```

> [!warning] Attention au PATH Après l'installation, il peut être nécessaire de fermer et rouvrir votre session pour que `/snap/bin` soit ajouté au PATH.

#### Configuration initiale

```bash
# Vérifier le statut du service
sudo systemctl status snapd

# S'assurer que le service démarre au boot
sudo systemctl enable snapd
sudo systemctl enable snapd.socket

# Vérifier la connexion au Snap Store
snap find vlc
```

---

### Commandes essentielles

#### Recherche et information

```bash
# Rechercher un snap dans le store
snap find <terme>
snap find "video player"

# Obtenir des informations détaillées sur un snap
snap info <nom-du-snap>
snap info firefox

# Afficher tous les snaps installés
snap list

# Afficher avec plus de détails (version, révision, taille)
snap list --all
```

> [!example] Exemple de recherche
> 
> ```bash
> $ snap find spotify
> Name      Version  Publisher    Notes  Summary
> spotify   1.2.31   spotify✓     -      Music streaming service
> ```

#### Installation et désinstallation

```bash
# Installer un snap (canal stable par défaut)
sudo snap install <nom-du-snap>

# Installer depuis un canal spécifique
sudo snap install <nom-du-snap> --channel=<canal>
sudo snap install firefox --channel=beta

# Canaux disponibles : stable, candidate, beta, edge

# Installer en mode classic (sans confinement)
sudo snap install <nom-du-snap> --classic
sudo snap install code --classic  # Visual Studio Code

# Désinstaller un snap
sudo snap remove <nom-du-snap>

# Désinstaller en supprimant aussi les données
sudo snap remove --purge <nom-du-snap>
```

> [!tip] Astuce canaux Les canaux permettent de tester des versions en développement :
> 
> - **stable** : Production (par défaut)
> - **candidate** : Release candidate
> - **beta** : Tests publics
> - **edge** : Version de développement

#### Mise à jour

```bash
# Mettre à jour tous les snaps
sudo snap refresh

# Mettre à jour un snap spécifique
sudo snap refresh <nom-du-snap>

# Changer de canal pour un snap
sudo snap refresh <nom-du-snap> --channel=<canal>

# Voir l'historique des mises à jour
snap changes

# Voir les détails d'un changement
snap change <id>
```

#### Révisions et rollback

```bash
# Afficher toutes les révisions installées d'un snap
snap list --all <nom-du-snap>

# Revenir à la révision précédente
sudo snap revert <nom-du-snap>

# Revenir à une révision spécifique
sudo snap revert <nom-du-snap> --revision=<numéro>

# Les snaps conservent les 3 dernières révisions par défaut
```

> [!example] Exemple de rollback
> 
> ```bash
> $ snap list --all firefox
> Name     Version  Rev   Tracking       Publisher   Notes
> firefox  121.0    3358  latest/stable  mozilla✓    -
> firefox  120.0    3298  -              mozilla✓    disabled
> 
> $ sudo snap revert firefox
> # Revient à la version 120.0
> ```

---

### Gestion avancée

#### Interfaces et connexions

Les interfaces snap contrôlent l'accès des applications aux ressources système. C'est le mécanisme principal de sécurité de snap.

```bash
# Lister toutes les interfaces disponibles
snap interface

# Lister les interfaces connectées
snap connections

# Lister les connexions pour un snap spécifique
snap connections <nom-du-snap>

# Connecter manuellement une interface
sudo snap connect <snap>:<plug> <snap>:<slot>

# Déconnecter une interface
sudo snap disconnect <snap>:<plug> <snap>:<slot>
```

> [!info] Interfaces courantes
> 
> - **home** : Accès au répertoire home de l'utilisateur
> - **network** : Accès réseau
> - **camera** : Accès à la webcam
> - **audio-playback** : Lecture audio
> - **removable-media** : Accès aux médias amovibles
> - **desktop** : Accès à l'environnement de bureau

```bash
# Exemple : Donner accès à un périphérique USB
sudo snap connect <snap>:raw-usb

# Exemple : Donner accès aux médias amovibles
sudo snap connect <snap>:removable-media
```

#### Services snap

Certains snaps incluent des services (daemons) qui tournent en arrière-plan.

```bash
# Lister les services d'un snap
snap services <nom-du-snap>

# Démarrer un service
sudo snap start <nom-du-snap>.<service>

# Arrêter un service
sudo snap stop <nom-du-snap>.<service>

# Redémarrer un service
sudo snap restart <nom-du-snap>.<service>

# Activer le démarrage automatique
sudo snap start --enable <nom-du-snap>.<service>

# Désactiver le démarrage automatique
sudo snap stop --disable <nom-du-snap>.<service>

# Voir les logs d'un service
snap logs <nom-du-snap>.<service>
snap logs <nom-du-snap>.<service> -f  # En temps réel
snap logs <nom-du-snap>.<service> -n=50  # Dernières 50 lignes
```

#### Gestion des données

```bash
# Les données utilisateur sont stockées dans
~/snap/<nom-du-snap>/

# Les données système sont dans
/var/snap/<nom-du-snap>/

# Sauvegarder les données d'un snap
snap save <nom-du-snap>

# Lister les snapshots
snap saved

# Restaurer depuis un snapshot
sudo snap restore <snapshot-id>

# Supprimer un snapshot
snap forget <snapshot-id>
```

#### Configuration

```bash
# Voir la configuration d'un snap
snap get <nom-du-snap>

# Définir une option de configuration
sudo snap set <nom-du-snap> <clé>=<valeur>

# Exemple
sudo snap set system refresh.timer=fri,23:00-01:00

# Options système courantes :
# - refresh.timer : Planifier les mises à jour
# - refresh.hold : Bloquer les mises à jour jusqu'à une date
```

> [!tip] Contrôler les mises à jour automatiques
> 
> ```bash
> # Bloquer les mises à jour pendant 90 jours maximum
> sudo snap refresh --hold
> 
> # Débloquer les mises à jour
> sudo snap refresh --unhold
> 
> # Planifier les mises à jour la nuit
> sudo snap set system refresh.timer=0:00-5:00
> ```

#### Aliases

```bash
# Créer un alias pour une commande snap
sudo snap alias <snap>.<commande> <alias>

# Exemple : Créer un alias pour lancer Firefox
sudo snap alias firefox.firefox ff

# Lister les aliases
snap aliases

# Supprimer un alias
sudo snap unalias <alias>
```

---

## 🌍 Différences selon les distributions

Bien que Snap soit conçu pour être universel, son intégration et son adoption varient selon les distributions Linux.

### Ubuntu

> [!info] Distribution native Snap est développé par Canonical et est profondément intégré à Ubuntu.

```bash
# Pré-installé depuis Ubuntu 16.04
# Le Snap Store remplace progressivement certains paquets DEB

# Snaps par défaut sur Ubuntu Desktop :
# - firefox (depuis 22.04)
# - thunderbird (depuis 22.10)
# - snap-store

# Vérifier les snaps pré-installés
snap list
```

**Particularités Ubuntu** :

- Snap Store intégré à GNOME Software
- Firefox et Thunderbird distribués uniquement en Snap depuis Ubuntu 22.04
- Mises à jour automatiques activées par défaut
- Support LTS complet

### Debian

```bash
# Snap n'est pas installé par défaut
sudo apt update
sudo apt install snapd

# Créer le lien symbolique nécessaire
sudo ln -s /var/lib/snapd/snap /snap
```

> [!warning] Support limité
> 
> - Snap n'est pas dans la philosophie Debian (préférence pour APT)
> - Pas d'intégration graphique par défaut
> - Peut nécessiter une configuration manuelle pour AppArmor

### Fedora / Red Hat / CentOS

```bash
# Installation
sudo dnf install snapd

# Activer le support classic
sudo ln -s /var/lib/snapd/snap /snap

# Redémarrer pour activer AppArmor/SELinux
sudo systemctl reboot
```

**Particularités** :

- SELinux peut bloquer certains snaps
- Flatpak est le format privilégié par Fedora
- Support officiel mais moins promu

### Arch Linux

```bash
# Via AUR (Arch User Repository)
git clone https://aur.archlinux.org/snapd.git
cd snapd
makepkg -si

# Ou avec un helper AUR
yay -S snapd

# Activer les services
sudo systemctl enable --now snapd.socket
sudo ln -s /var/lib/snapd/snap /snap
```

> [!warning] Philosophie Arch
> 
> - Snap n'est pas dans les dépôts officiels (AUR uniquement)
> - Préférence pour les paquets natifs ou AUR
> - Maintenance communautaire

### openSUSE

```bash
# Installation
sudo zypper install snapd

# Activer le service
sudo systemctl enable snapd
sudo systemctl start snapd

# Support AppArmor
sudo systemctl enable snapd.apparmor
sudo systemctl start snapd.apparmor
```

### Linux Mint

> [!info] Position particulière Linux Mint a choisi de bloquer Snap par défaut depuis la version 20.

```bash
# Snap est bloqué par défaut dans apt
# Pour l'activer manuellement :

# 1. Supprimer le blocage APT
sudo rm /etc/apt/preferences.d/nosnap.pref

# 2. Installer snapd
sudo apt update
sudo apt install snapd
```

**Raisons du blocage** :

- Linux Mint promeut Flatpak comme alternative
- Préoccupations sur le contrôle centralisé du Snap Store
- Préférence pour les paquets DEB traditionnels

---

## ⚖️ Comparaison des formats

### Tableau comparatif : Snap vs APT/DEB

|Critère|Snap|APT/DEB|
|---|---|---|
|**Dépendances**|Incluses dans le paquet|Partagées système|
|**Taille**|Plus volumineuse|Plus légère|
|**Isolation**|Sandboxing strict|Aucune|
|**Compatibilité**|Multi-distros|Debian/Ubuntu|
|**Mises à jour**|Automatiques, fréquentes|Manuel ou planifiées|
|**Sécurité**|Confinement par défaut|Dépend du système|
|**Performance**|Légèrement plus lent (squashfs)|Natives|
|**Espace disque**|Supérieur (dépendances dupliquées)|Optimisé|
|**Versions**|Multiples versions possibles|Une seule version|

### Quand utiliser Snap ?

> [!tip] Cas d'usage recommandés
> 
> - **Applications tierces** : Logiciels non disponibles dans les dépôts officiels
> - **Dernières versions** : Applications nécessitant des mises à jour fréquentes
> - **Environnements multi-utilisateurs** : Isolation des applications critiques
> - **Tests** : Tester différentes versions sans conflit
> - **Portabilité** : Même application sur différentes distributions

> [!warning] Éviter Snap pour
> 
> - **Bibliothèques système** : Utilisez les paquets natifs
> - **Outils système critiques** : Préférez les paquets de votre distribution
> - **Environnements à ressources limitées** : Overhead de stockage et mémoire
> - **Applications nécessitant un accès profond au système** : Contraintes du sandboxing

---

## ⚠️ Pièges courants et bonnes pratiques

### Pièges courants

#### 1. Problèmes de confinement

```bash
# Erreur : L'application ne peut pas accéder à un fichier
# Cause : Le confinement strict bloque l'accès

# Solution : Vérifier et connecter les interfaces nécessaires
snap connections <nom-du-snap>
sudo snap connect <snap>:removable-media
```

> [!warning] Accès au système de fichiers Par défaut, un snap en mode strict ne peut accéder qu'à son propre répertoire dans `~/snap/`. Pour accéder à d'autres emplacements, vous devez connecter l'interface appropriée.

#### 2. Espace disque

```bash
# Problème : Les snaps prennent beaucoup de place
# Cause : Chaque snap embarque ses dépendances + anciennes révisions

# Solution : Nettoyer les anciennes révisions
sudo snap set system refresh.retain=2  # Garder seulement 2 révisions

# Supprimer manuellement les révisions désactivées
snap list --all | grep disabled
sudo snap remove <nom-du-snap> --revision=<numéro>
```

#### 3. Mises à jour automatiques

```bash
# Problème : Snap se met à jour pendant le travail
# Solution : Configurer une fenêtre de mise à jour

# Définir une plage horaire (exemple : la nuit)
sudo snap set system refresh.timer=2:00-4:00

# Bloquer temporairement les mises à jour
sudo snap refresh --hold
```

#### 4. Variables d'environnement

```bash
# Problème : Les snaps ne voient pas les variables d'environnement personnalisées
# Cause : Isolation du snap

# Solution : Les snaps ont leurs propres variables
# Utiliser les wrappers de commande ou la configuration du snap
snap get <nom-du-snap>
sudo snap set <nom-du-snap> <variable>=<valeur>
```

#### 5. Performance au démarrage

> [!info] Premier lancement lent Le premier lancement d'un snap peut être plus lent car le système de fichiers squashfs doit être monté. Les lancements suivants sont plus rapides grâce au cache.

---

### Bonnes pratiques

#### 1. Gestion de l'espace disque

```bash
# Vérifier l'espace utilisé par les snaps
du -sh /var/lib/snapd/snaps

# Limiter le nombre de révisions conservées
sudo snap set system refresh.retain=2

# Nettoyer régulièrement
# Créer un script de maintenance mensuelle
```

#### 2. Sécurité

```bash
# Toujours vérifier les permissions d'un snap avant installation
snap info <nom-du-snap>
# Regarder la section "Confinement" et "Publisher"

# Privilégier les snaps avec confinement strict
# Éviter les snaps en mode classic sauf nécessité

# Vérifier les connexions actives
snap connections <nom-du-snap>
```

> [!tip] Vérifier le publisher Préférez les snaps publiés par des éditeurs vérifiés (marqués ✓). Cela garantit l'authenticité de l'application.

#### 3. Performance

```bash
# Pour les applications critiques, préférer les paquets natifs
# Snap ajoute un léger overhead

# Utiliser snap uniquement quand nécessaire :
# - Application non disponible en natif
# - Besoin d'isolation
# - Besoin de versions spécifiques
```

#### 4. Surveillance

```bash
# Vérifier régulièrement les mises à jour disponibles
snap refresh --list

# Consulter les logs en cas de problème
snap changes
journalctl -u snapd

# Monitorer l'utilisation des ressources
snap services
```

#### 5. Documentation

```bash
# Garder trace des snaps installés et de leur configuration
snap list > ~/snaps-installed.txt

# Documenter les connexions personnalisées
snap connections > ~/snaps-connections.txt

# Sauvegarder régulièrement
snap save
```

---

## 🎯 Astuces avancées

### Développement et débogage

```bash
# Installer un snap local (pour les développeurs)
sudo snap install <fichier.snap> --dangerous

# Mode devmode pour le développement
sudo snap install <snap> --devmode

# Consulter les logs détaillés
sudo journalctl -u snapd -f

# Shell dans un snap (pour déboguer)
sudo snap run --shell <nom-du-snap>
```

### Optimisation

```bash
# Pré-rafraîchir les snaps (télécharger sans installer)
sudo snap refresh --time

# Désactiver un snap sans le désinstaller
sudo snap disable <nom-du-snap>

# Réactiver
sudo snap enable <nom-du-snap>
```

### Gestion multi-utilisateurs

```bash
# Les snaps sont installés système-wide
# Chaque utilisateur a ses propres données dans ~/snap/

# Les configurations système affectent tous les utilisateurs
sudo snap set system <option>=<valeur>
```

> [!tip] Astuce de productivité Créez des aliases pour vos commandes snap fréquentes :
> 
> ```bash
> # Dans votre ~/.bashrc
> alias update-snaps='sudo snap refresh'
> alias list-snaps='snap list'
> ```

---

## 📝 Résumé

Snap représente une approche moderne de la gestion des paquets, privilégiant l'isolation, la sécurité et la compatibilité multi-distributions. Bien qu'il présente des compromis en termes d'espace disque et de performance, il reste un outil précieux pour installer et maintenir des applications tierces ou des versions spécifiques de logiciels.

**Points clés à retenir** :

- Snap encapsule les applications avec leurs dépendances
- Le confinement strict assure une sécurité renforcée
- Les mises à jour automatiques simplifient la maintenance
- L'adoption varie selon les distributions (Ubuntu > autres)
- Utiliser Snap de manière stratégique pour compléter les paquets natifs