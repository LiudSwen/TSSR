

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

## 🚀 Introduction à l'environnement Linux

Linux est un système d'exploitation open-source qui se décline en de nombreuses **distributions**. Contrairement à Windows ou macOS, Linux offre une grande flexibilité dans le choix de l'interface utilisateur et des composants système.

> [!info] Qu'est-ce qu'une distribution Linux ? Une distribution (ou "distro") est une version complète de Linux comprenant :
> 
> - Le noyau Linux (cœur du système)
> - Un ensemble d'outils et de logiciels
> - Un gestionnaire de paquets
> - Éventuellement une interface graphique
> - Une philosophie et une communauté propres

### Pourquoi plusieurs distributions ?

Les distributions répondent à des besoins différents :

|Besoin|Distribution appropriée|
|---|---|
|Serveur stable en production|Debian, Ubuntu Server, RHEL|
|Poste de travail grand public|Ubuntu Desktop, Linux Mint, Fedora|
|Contrôle total et personnalisation|Arch Linux, Gentoo|
|Sécurité et vie privée|Qubes OS, Tails|
|Apprentissage et pédagogie|Ubuntu, Fedora|

---

## 🖥️ Interfaces graphiques vs console

L'une des différences majeures entre les distributions Linux réside dans l'interface proposée par défaut.

### Le bureau GNOME (Ubuntu Desktop)

**GNOME** est un environnement de bureau moderne et intuitif, installé par défaut sur Ubuntu Desktop.

> [!example] Caractéristiques de GNOME
> 
> - Interface graphique complète avec fenêtres, menus, icônes
> - Gestionnaire de fichiers (Nautilus)
> - Paramètres système accessibles via interface graphique
> - Applications graphiques (navigateur, éditeur de texte, etc.)
> - Recherche universelle (appuyer sur `Super`/`Windows`)

#### Avantages de l'interface graphique

- **Accessibilité** : Courbe d'apprentissage plus douce pour les débutants
- **Multitâche visuel** : Plusieurs fenêtres ouvertes simultanément
- **Applications graphiques** : Navigateur web, suite bureautique, outils de développement
- **Gestion visuelle** : Glisser-déposer, aperçus d'images, etc.

#### Inconvénients

- **Consommation de ressources** : Utilise de la RAM et du CPU
- **Dépendances** : Nécessite un serveur X ou Wayland
- **Administration** : Moins adapté pour l'automatisation

> [!tip] Astuce Sur Ubuntu Desktop, vous pouvez accéder à un terminal graphique avec `Ctrl + Alt + T` pour combiner les avantages des deux mondes.

### La console uniquement (Ubuntu Server, Debian minimal)

Sur les systèmes serveur, l'installation par défaut ne comprend **aucune interface graphique**. Vous interagissez uniquement via la **ligne de commande**.

> [!info] Qu'est-ce que la console ? La console (ou terminal, shell) est une interface texte où vous tapez des commandes qui sont immédiatement exécutées par le système.

#### Pourquoi pas d'interface graphique sur les serveurs ?

```bash
# Un serveur typique n'a pas besoin de GUI car :
# 1. Il n'y a personne devant l'écran en permanence
# 2. L'administration se fait à distance (SSH)
# 3. Les ressources sont préservées pour les services
# 4. La sécurité est renforcée (moins de surface d'attaque)
```

#### Avantages de la console

- **Performance** : Consommation minimale de ressources
- **Automatisation** : Scripts faciles à créer et exécuter
- **Accès distant** : SSH permet l'administration depuis n'importe où
- **Stabilité** : Moins de composants = moins de risques de bugs
- **Précision** : Contrôle total sur chaque action

#### L'invite de commande (prompt)

Lorsque vous vous connectez en console, vous verrez une invite de commande :

```bash
utilisateur@nomdemachine:~$
```

Décomposition :

- `utilisateur` : Votre nom d'utilisateur
- `@` : Séparateur
- `nomdemachine` : Nom d'hôte de la machine
- `:` : Séparateur
- `~` : Répertoire courant (~ = répertoire personnel)
- `$` : Vous êtes un utilisateur normal (# pour root)

> [!warning] Attention Ne confondez pas la console Linux avec :
> 
> - Le terminal graphique (fenêtre de terminal dans GNOME)
> - Une connexion SSH distante
> - Le mode de récupération
> 
> La console locale est accessible directement sur la machine, sans réseau.

---

## 📦 Les distributions Linux

### Ubuntu Desktop vs Ubuntu Server

Ubuntu propose deux éditions principales qui partagent la même base technique mais diffèrent dans leur utilisation.

#### Ubuntu Desktop

```bash
# Caractéristiques :
# - GNOME installé par défaut
# - Pilotes propriétaires (NVIDIA, Wi-Fi) inclus
# - Logithèque préinstallée
# - Mise à jour graphique
# - Codecs multimédia
```

**Utilisation typique** : Ordinateur personnel, poste de développement, machine de bureau

#### Ubuntu Server

```bash
# Caractéristiques :
# - Pas d'interface graphique
# - Installation minimale
# - Optimisé pour les services
# - Outils serveur préinstallés (SSH activé)
# - Mises à jour automatiques configurables
```

**Utilisation typique** : Serveur web, base de données, serveur d'applications, infrastructure cloud

> [!tip] Astuce Ubuntu Server peut recevoir une interface graphique après installation si nécessaire :
> 
> ```bash
> sudo apt update
> sudo apt install ubuntu-desktop
> ```

### Debian : La distribution mère

Debian est la distribution dont Ubuntu est dérivée. Elle est réputée pour sa stabilité exceptionnelle.

#### Philosophie de Debian

- **Stabilité avant tout** : Les paquets sont longuement testés
- **Liberté** : Engagement fort envers les logiciels libres
- **Universalité** : Supporte de nombreuses architectures matérielles
- **Communautaire** : Développée entièrement par des bénévoles

#### Installation minimale

Lors de l'installation de Debian, vous pouvez choisir :

```bash
# Options d'installation :
[ ] Environnement de bureau Debian
[ ] ... GNOME
[ ] ... Xfce
[ ] ... KDE Plasma
[ ] ... Cinnamon
[ ] ... MATE
[ ] ... LXDE
[x] serveur web
[x] serveur SSH
[x] utilitaires usuels du système
```

> [!info] Installation minimale Si vous ne cochez aucun environnement de bureau, vous obtenez un système en console uniquement, similaire à Ubuntu Server.

### Tableau comparatif

|Aspect|Ubuntu Desktop|Ubuntu Server|Debian|
|---|---|---|---|
|Interface par défaut|GNOME|Console|Au choix|
|Cycle de mise à jour|6 mois (LTS : 2 ans)|6 mois (LTS : 5 ans)|~2 ans (stable)|
|Facilité d'utilisation|⭐⭐⭐⭐⭐|⭐⭐⭐|⭐⭐⭐|
|Stabilité|⭐⭐⭐⭐|⭐⭐⭐⭐⭐|⭐⭐⭐⭐⭐|
|Logiciels récents|⭐⭐⭐⭐⭐|⭐⭐⭐⭐|⭐⭐⭐|
|Utilisation serveur|❌|✅|✅|
|Utilisation desktop|✅|❌|✅ (si GUI installée)|

---

## 🔐 Connexion et session locale

### Processus de démarrage

Lorsque vous allumez une machine Linux, voici ce qui se passe :

```bash
# 1. BIOS/UEFI charge le bootloader (GRUB)
# 2. GRUB charge le noyau Linux
# 3. Le noyau initialise le matériel
# 4. systemd (ou init) démarre les services
# 5. Le système affiche l'écran de connexion
```

### Connexion en mode graphique (Ubuntu Desktop)

Sur Ubuntu Desktop avec GNOME, vous verrez **GDM** (GNOME Display Manager) :

1. Liste des utilisateurs disponibles
2. Clic sur votre nom d'utilisateur
3. Saisie du mot de passe
4. Choix optionnel de l'environnement de bureau (engrenage en bas à droite)
5. Appui sur `Entrée` ou clic sur "Se connecter"

> [!example] Raccourcis utiles lors de la connexion
> 
> - `Ctrl + Alt + F1` à `F6` : Basculer vers les consoles virtuelles (TTY)
> - `Ctrl + Alt + F7` : Retourner à l'interface graphique (peut être F1 sur certains systèmes)

### Connexion en mode console (Server/Debian minimal)

En console, vous verrez un écran textuel :

```
Debian GNU/Linux 12 nomdemachine tty1

nomdemachine login: _
```

**Processus de connexion** :

1. Saisir votre nom d'utilisateur
2. Appuyer sur `Entrée`
3. Le système demande le mot de passe
4. Saisir le mot de passe (aucun caractère ne s'affiche, c'est normal !)
5. Appuyer sur `Entrée`

```bash
nomdemachine login: utilisateur
Password: 
Last login: Fri Dec 13 10:23:45 2024 from 192.168.1.50
utilisateur@nomdemachine:~$
```

> [!warning] Sécurité Lors de la saisie du mot de passe en console :
> 
> - Aucun caractère ne s'affiche (pas même des astérisques)
> - C'est un comportement de sécurité normal
> - Tapez votre mot de passe en entier puis validez
> - En cas d'erreur, le système redemande le login complet

### Les consoles virtuelles (TTY)

Linux propose plusieurs **consoles virtuelles** accessibles simultanément :

```bash
# tty1 : Console 1 (souvent l'interface graphique sur Desktop)
# tty2 : Console 2 (connexion texte)
# tty3 : Console 3 (connexion texte)
# tty4 : Console 4 (connexion texte)
# tty5 : Console 5 (connexion texte)
# tty6 : Console 6 (connexion texte)
```

**Navigation entre TTY** :

```bash
# Basculer vers tty2 :
Ctrl + Alt + F2

# Basculer vers tty3 :
Ctrl + Alt + F3

# Retourner à l'interface graphique (si installée) :
Ctrl + Alt + F1  # ou F7 selon la configuration
```

> [!tip] Utilité des TTY Les TTY sont utiles si :
> 
> - L'interface graphique se bloque
> - Vous devez diagnostiquer un problème système
> - Vous souhaitez plusieurs sessions utilisateur simultanées
> - Vous exécutez des tâches longues en arrière-plan

### Déconnexion

#### En mode graphique

- Menu utilisateur en haut à droite
- Sélectionner "Déconnexion" ou "Éteindre"
- Ou raccourci : `Ctrl + Alt + Suppr` (selon la configuration)

#### En mode console

```bash
# Méthode 1 : Commande logout
logout

# Méthode 2 : Commande exit
exit

# Méthode 3 : Raccourci clavier
Ctrl + D
```

> [!info] Différence entre déconnexion et extinction
> 
> - **Déconnexion** : Ferme votre session, le système reste allumé
> - **Extinction** : Arrête complètement la machine
> 
> Sur un serveur, privilégiez la déconnexion. L'extinction se fait rarement et de manière planifiée.

---

## ⚠️ Pièges courants et bonnes pratiques

### Pièges courants

#### 1. Confondre distribution et interface

> [!warning] Erreur fréquente "Ubuntu est plus facile que Debian"
> 
> **Réalité** : C'est l'interface graphique (GNOME) qui rend Ubuntu Desktop accessible, pas la distribution elle-même. Debian avec GNOME est tout aussi facile.

#### 2. Installer une interface graphique sur un serveur de production

```bash
# ❌ À éviter sur un serveur :
sudo apt install ubuntu-desktop

# Conséquences :
# - Consommation de RAM multipliée par 3-4
# - Services inutiles qui démarrent
# - Surface d'attaque augmentée
# - Mises à jour plus fréquentes et volumineuses
```

> [!tip] Alternative Si vous avez besoin d'outils graphiques occasionnellement, utilisez plutôt X11 forwarding via SSH (sera abordé dans une autre partie).

#### 3. Ne pas choisir la bonne édition

|Cas d'usage|Mauvais choix|Bon choix|
|---|---|---|
|Serveur web|Ubuntu Desktop|Ubuntu Server ou Debian|
|Poste de travail|Ubuntu Server|Ubuntu Desktop ou Debian + GUI|
|Apprentissage Linux|Debian minimal|Ubuntu Desktop|
|Production critique|Version récente|Version LTS (Long Term Support)|

#### 4. Oublier que le mot de passe ne s'affiche pas

Beaucoup de débutants pensent que leur clavier ne fonctionne pas lors de la première connexion console. C'est un comportement normal de sécurité !

### Bonnes pratiques

#### Choisir la bonne distribution pour le bon usage

```bash
# Serveur de production :
# → Debian Stable ou Ubuntu Server LTS
# → Installation minimale
# → Pas d'interface graphique

# Poste de développement :
# → Ubuntu Desktop LTS ou Debian + GNOME
# → Interface graphique complète
# → Outils de développement

# Apprentissage :
# → Ubuntu Desktop (interface conviviale)
# → Documentation abondante
# → Communauté active
```

#### Comprendre avant d'installer

> [!tip] Avant d'installer Linux
> 
> 1. Identifiez votre besoin (serveur, desktop, développement)
> 2. Choisissez la distribution adaptée
> 3. Décidez si vous avez besoin d'une interface graphique
> 4. Privilégiez les versions LTS pour la stabilité
> 5. Testez dans une machine virtuelle d'abord

#### Documenter votre installation

Gardez une trace de :

- La distribution choisie et sa version
- L'environnement de bureau (si applicable)
- Les packages installés manuellement
- Les configurations modifiées

#### Se familiariser avec les deux modes

Même sur Ubuntu Desktop, pratiquez régulièrement le terminal :

```bash
# Ouvrir un terminal :
Ctrl + Alt + T

# Commandes de base à maîtriser :
ls      # Lister les fichiers
cd      # Changer de répertoire
pwd     # Afficher le répertoire courant
whoami  # Afficher votre nom d'utilisateur
```

> [!info] Philosophie Un bon administrateur Linux doit être à l'aise aussi bien en interface graphique qu'en console. La plupart des tâches d'administration se feront en ligne de commande, même sur Desktop.

---

## 🎯 Récapitulatif

### Points clés à retenir

1. **Distributions** : Ubuntu Desktop (GUI), Ubuntu Server (console), Debian (flexible)
2. **Interface** : GNOME pour le desktop, console pure pour les serveurs
3. **Connexion locale** : GDM en mode graphique, login/password en console
4. **TTY** : 6 consoles virtuelles accessibles via `Ctrl + Alt + F1-F6`
5. **Choix** : Adaptez la distribution et l'interface à votre usage

### Commandes essentielles vues

```bash
# Déconnexion
logout
exit
Ctrl + D

# Navigation TTY
Ctrl + Alt + F2  # Basculer vers tty2
Ctrl + Alt + F1  # Retour à l'interface graphique
```

### Mentalité à adopter

> [!tip] Pensez comme un administrateur
> 
> - La console n'est pas plus difficile, juste différente
> - L'interface graphique n'est qu'une couche au-dessus du système
> - Un serveur n'a pas besoin de GUI
> - La stabilité prime sur les fonctionnalités pour un serveur
> - La documentation est votre meilleure amie

---

_Ce cours couvre les fondamentaux de l'environnement Linux et les différences entre distributions. La maîtrise de ces concepts est essentielle avant d'approfondir l'administration système._