

## 📑 Table des matières

```table-of-contents
title: 
style: nestedList # TOC style (nestedList|nestedOrderedList|inlineFirstLevel)
minLevel: 2 # Include headings from the specified level
maxLevel: 3 # Include headings up to the specified level
include: 
exclude: 
includeLinks: true # Make headings clickable
hideWhenEmpty: false # Hide TOC if no headings are found
debugInConsole: false # Print debug info in Obsidian console
```

---

## Introduction

La gestion des mises à jour est un pilier fondamental de l'administration système Linux. Elle garantit la sécurité, la stabilité et les performances optimales de vos serveurs et postes de travail. Une stratégie de mise à jour bien pensée réduit les vulnérabilités, corrige les bugs et maintient la compatibilité avec les applications modernes.

> [!info] Pourquoi les mises à jour sont critiques
> 
> - **Sécurité** : Correction des failles de sécurité découvertes (CVE)
> - **Stabilité** : Résolution de bugs et amélioration de la fiabilité
> - **Performance** : Optimisations et nouvelles fonctionnalités
> - **Conformité** : Respect des standards de sécurité (ISO 27001, RGPD, etc.)

---

## Stratégie de mises à jour

### Mises à jour de sécurité vs mises à jour normales

#### 📊 Comparaison des types de mises à jour

|Type|Description|Priorité|Fréquence|Impact|
|---|---|---|---|---|
|**Security**|Correctifs de vulnérabilités (CVE)|🔴 Critique|Immédiate|Faible risque|
|**Updates**|Corrections de bugs mineurs|🟡 Normale|Hebdomadaire|Faible risque|
|**Upgrades**|Nouvelles versions majeures|🟢 Planifiée|Mensuelle/Trimestrielle|Risque moyen|
|**Backports**|Fonctionnalités récentes sur versions stables|🔵 Optionnelle|Variable|Risque variable|

#### 🔐 Mises à jour de sécurité

Les mises à jour de sécurité corrigent des vulnérabilités identifiées (CVE - Common Vulnerabilities and Exposures). Elles doivent être appliquées **en priorité absolue**.

```bash
# Lister uniquement les mises à jour de sécurité
apt list --upgradable | grep -i security

# Installer uniquement les correctifs de sécurité (Debian/Ubuntu)
sudo apt upgrade -y --only-upgrade $(apt list --upgradable 2>/dev/null | grep -i security | cut -d'/' -f1)

# Méthode alternative avec unattended-upgrades
sudo unattended-upgrade -d --dry-run
```

> [!warning] Urgence des mises à jour de sécurité Une vulnérabilité non corrigée peut être exploitée en quelques heures après sa divulgation publique. Les mises à jour de sécurité doivent être appliquées **dans les 24-48h** suivant leur publication.

#### 🔧 Mises à jour normales

Les mises à jour normales incluent des corrections de bugs, des améliorations de performance et de nouvelles fonctionnalités mineures.

```bash
# Mettre à jour la liste des paquets disponibles
sudo apt update

# Lister tous les paquets pouvant être mis à jour
apt list --upgradable

# Effectuer une mise à jour standard (sans changement de version majeure)
sudo apt upgrade -y

# Mise à jour complète (peut installer/supprimer des paquets)
sudo apt full-upgrade -y
```

> [!tip] Différence upgrade vs full-upgrade
> 
> - `apt upgrade` : Met à jour les paquets **sans** installer/supprimer de nouveaux paquets
> - `apt full-upgrade` : Met à jour et peut installer/supprimer des paquets pour résoudre les dépendances
> - `apt dist-upgrade` : Ancien nom de full-upgrade (toujours fonctionnel)

#### 🎯 Stratégies selon le type d'environnement

**Serveurs de production**

```bash
# 1. Test sur environnement de staging
# 2. Planifier une fenêtre de maintenance
# 3. Créer un snapshot/backup avant mise à jour
# 4. Appliquer uniquement les mises à jour de sécurité en routine
sudo apt update && sudo apt upgrade -y

# 5. Planifier les full-upgrade trimestriellement
```

**Serveurs de développement/test**

```bash
# Mises à jour plus agressives acceptables
sudo apt update && sudo apt full-upgrade -y
```

**Postes de travail**

```bash
# Mises à jour automatiques activées
# Full-upgrade mensuel planifié
```

---

### Vérifier les mises à jour disponibles

#### 📋 Commande apt list --upgradable

La commande `apt list --upgradable` affiche tous les paquets pour lesquels une version plus récente est disponible.

```bash
# Syntaxe de base
apt list --upgradable

# Exemple de sortie
Listing...
apache2/jammy-updates,jammy-security 2.4.52-1ubuntu4.7 amd64 [upgradable from: 2.4.52-1ubuntu4.6]
curl/jammy-updates,jammy-security 7.81.0-1ubuntu1.15 amd64 [upgradable from: 7.81.0-1ubuntu1.14]
openssh-server/jammy-updates,jammy-security 1:8.9p1-3ubuntu0.6 amd64 [upgradable from: 1:8.9p1-3ubuntu0.5]
```

#### 🔍 Analyse détaillée de la sortie

```bash
# Format d'une ligne :
# paquet/dépôt version architecture [upgradable from: version_actuelle]

# Décortiquer les informations :
# - apache2 : nom du paquet
# - jammy-updates,jammy-security : dépôts sources de la mise à jour
# - 2.4.52-1ubuntu4.7 : nouvelle version disponible
# - amd64 : architecture
# - 2.4.52-1ubuntu4.6 : version actuellement installée
```

#### 📊 Filtrer et analyser les résultats

```bash
# Compter le nombre de mises à jour disponibles
apt list --upgradable 2>/dev/null | grep -c upgradable

# Filtrer par mot-clé (ex: paquets liés à apache)
apt list --upgradable 2>/dev/null | grep apache

# Afficher uniquement les mises à jour de sécurité
apt list --upgradable 2>/dev/null | grep security

# Trier par nom de paquet
apt list --upgradable 2>/dev/null | sort

# Voir les détails d'une mise à jour spécifique
apt show apache2

# Voir le changelog d'un paquet avant mise à jour
apt changelog apache2
```

> [!example] Cas d'usage pratique
> 
> ```bash
> # Script pour vérifier quotidiennement les mises à jour
> #!/bin/bash
> apt update -qq
> UPDATES=$(apt list --upgradable 2>/dev/null | grep -c upgradable)
> SECURITY=$(apt list --upgradable 2>/dev/null | grep -c security)
> 
> echo "🔄 Mises à jour disponibles : $UPDATES"
> echo "🔐 Mises à jour de sécurité : $SECURITY"
> 
> if [ $SECURITY -gt 0 ]; then
>     echo "⚠️  ALERTE : Mises à jour de sécurité en attente !"
>     apt list --upgradable 2>/dev/null | grep security
> fi
> ```

#### 🛠️ Commandes complémentaires

```bash
# Simuler une mise à jour sans l'effectuer
sudo apt upgrade --dry-run

# Voir uniquement les paquets qui seront installés/mis à jour
sudo apt upgrade -s | grep ^Inst

# Vérifier si un paquet spécifique a une mise à jour
apt list --upgradable 2>/dev/null | grep "^nom-du-paquet"

# Afficher la politique de version d'un paquet
apt policy nom-du-paquet
```

> [!tip] Automatiser la vérification Ajoutez cette ligne à votre crontab pour recevoir un rapport quotidien :
> 
> ```bash
> 0 8 * * * apt update -qq && apt list --upgradable 2>/dev/null | mail -s "Mises à jour disponibles" admin@example.com
> ```

---

### Automatisation avec unattended-upgrades

#### 🤖 Qu'est-ce que unattended-upgrades ?

`unattended-upgrades` est un outil qui permet d'installer automatiquement les mises à jour de sécurité critiques sans intervention humaine. C'est **essentiel** pour maintenir la sécurité des serveurs, surtout lorsque les administrateurs ne peuvent pas surveiller les systèmes 24/7.

> [!info] Avantages de l'automatisation
> 
> - ✅ Réduction de la fenêtre d'exposition aux vulnérabilités
> - ✅ Conformité avec les politiques de sécurité
> - ✅ Réduction de la charge de travail administrative
> - ✅ Mises à jour appliquées même en dehors des heures de bureau

#### 📦 Installation

```bash
# Installer unattended-upgrades
sudo apt update
sudo apt install unattended-upgrades apt-listchanges -y

# Activer le service
sudo dpkg-reconfigure -plow unattended-upgrades
# OU
sudo systemctl enable unattended-upgrades
sudo systemctl start unattended-upgrades
```

#### ⚙️ Configuration de base

Le fichier de configuration principal est `/etc/apt/apt.conf.d/50unattended-upgrades`.

```bash
# Éditer la configuration
sudo nano /etc/apt/apt.conf.d/50unattended-upgrades
```

**Configuration recommandée :**

```bash
# Origines des mises à jour autorisées
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";     // Mises à jour de sécurité
    "${distro_id}ESMApps:${distro_codename}-apps-security";  // Ubuntu Pro
    "${distro_id}ESM:${distro_codename}-infra-security";     // Ubuntu Pro
//  "${distro_id}:${distro_codename}-updates";      // Décommenter pour mises à jour normales
};

# Paquets à exclure des mises à jour automatiques
Unattended-Upgrade::Package-Blacklist {
//  "vim";           // Exemple : exclure vim
//  "postgresql*";   // Exclure tous les paquets postgresql
};

# Mise à jour automatique des paquets même si d'autres sont en attente
Unattended-Upgrade::AutoFixInterruptedDpkg "true";

# Diviser la mise à jour pour minimiser l'impact
Unattended-Upgrade::MinimalSteps "true";

# Supprimer les dépendances devenues inutiles
Unattended-Upgrade::Remove-Unused-Dependencies "true";

# Supprimer les anciens kernels automatiquement
Unattended-Upgrade::Remove-Unused-Kernel-Packages "true";

# Redémarrage automatique si nécessaire
Unattended-Upgrade::Automatic-Reboot "false";  // À activer avec prudence !

# Heure du redémarrage automatique (si activé)
Unattended-Upgrade::Automatic-Reboot-Time "02:00";

# Notification par email
Unattended-Upgrade::Mail "admin@example.com";
Unattended-Upgrade::MailReport "on-change";  // only-on-error, on-change, always
```

> [!warning] Redémarrage automatique Activer `Automatic-Reboot "true"` peut interrompre des services critiques. Utilisez cette option uniquement sur des systèmes non critiques ou avec une haute disponibilité (load balancer, cluster).

#### 🕐 Configuration de la fréquence

Le fichier `/etc/apt/apt.conf.d/20auto-upgrades` contrôle la fréquence d'exécution.

```bash
# Vérifier la configuration actuelle
cat /etc/apt/apt.conf.d/20auto-upgrades

# Configuration recommandée
APT::Periodic::Update-Package-Lists "1";      // Mettre à jour la liste quotidiennement
APT::Periodic::Download-Upgradeable-Packages "1";  // Télécharger les paquets quotidiennement
APT::Periodic::AutocleanInterval "7";         // Nettoyer le cache hebdomadairement
APT::Periodic::Unattended-Upgrade "1";        // Installer les mises à jour quotidiennement
```

> [!tip] Valeurs possibles
> 
> - `"0"` : Désactivé
> - `"1"` : Tous les jours
> - `"7"` : Toutes les semaines
> - `"30"` : Tous les mois

#### 🧪 Tester la configuration

```bash
# Exécution en mode test (dry-run)
sudo unattended-upgrade --dry-run --debug

# Forcer une exécution manuelle
sudo unattended-upgrade --debug

# Vérifier les logs
sudo tail -f /var/log/unattended-upgrades/unattended-upgrades.log

# Vérifier le statut du service
sudo systemctl status unattended-upgrades

# Voir les dernières exécutions
sudo journalctl -u unattended-upgrades -n 50
```

#### 📊 Monitoring et logs

```bash
# Emplacement des logs principaux
/var/log/unattended-upgrades/unattended-upgrades.log           // Log principal
/var/log/unattended-upgrades/unattended-upgrades-dpkg.log      // Log dpkg
/var/log/unattended-upgrades/unattended-upgrades-shutdown.log  // Log arrêt

# Analyser les mises à jour effectuées aujourd'hui
sudo grep "$(date +%Y-%m-%d)" /var/log/unattended-upgrades/unattended-upgrades.log

# Voir si un redémarrage est nécessaire
cat /var/run/reboot-required 2>/dev/null

# Voir quels paquets nécessitent un redémarrage
cat /var/run/reboot-required.pkgs 2>/dev/null
```

> [!example] Script de monitoring
> 
> ```bash
> #!/bin/bash
> # Vérifier si unattended-upgrades fonctionne correctement
> 
> LOG="/var/log/unattended-upgrades/unattended-upgrades.log"
> LAST_RUN=$(grep "INFO Initial blacklisted packages" "$LOG" | tail -1 | cut -d' ' -f1-2)
> REBOOT_REQUIRED=$(test -f /var/run/reboot-required && echo "OUI" || echo "NON")
> 
> echo "🕐 Dernière exécution : $LAST_RUN"
> echo "🔄 Redémarrage nécessaire : $REBOOT_REQUIRED"
> 
> if [ "$REBOOT_REQUIRED" = "OUI" ]; then
>     echo "📦 Paquets nécessitant un redémarrage :"
>     cat /var/run/reboot-required.pkgs
> fi
> ```

#### 🎯 Bonnes pratiques

```bash
# 1. Toujours tester en dry-run d'abord
sudo unattended-upgrade --dry-run

# 2. Exclure les applications critiques qui nécessitent une validation
Unattended-Upgrade::Package-Blacklist {
    "mysql*";
    "postgresql*";
    "nginx";
    "apache2";
};

# 3. Configurer les notifications email
Unattended-Upgrade::Mail "equipe-ops@example.com";
Unattended-Upgrade::MailReport "only-on-error";

# 4. Planifier les redémarrages pendant les heures creuses
Unattended-Upgrade::Automatic-Reboot-Time "03:00";

# 5. Garder les anciens kernels au cas où
Unattended-Upgrade::Remove-Unused-Kernel-Packages "false";
```

> [!warning] Pièges courants
> 
> - Ne pas activer `Automatic-Reboot` sur des serveurs de production sans supervision
> - Oublier de configurer les notifications email (vous ne saurez pas si une mise à jour échoue)
> - Autoriser les mises à jour normales (`-updates`) qui peuvent introduire des changements non désirés
> - Ne pas exclure les applications critiques qui nécessitent des tests

---

### Différences Ubuntu vs Debian

#### 🎭 Philosophies divergentes

|Aspect|Debian|Ubuntu|
|---|---|---|
|**Cycle de release**|~2 ans (quand c'est prêt)|6 mois (fixe)|
|**Stabilité**|⭐⭐⭐⭐⭐ Ultra-stable|⭐⭐⭐⭐ Stable|
|**Mises à jour**|Très conservateur|Plus fréquentes|
|**Support LTS**|~3-5 ans|5 ans (10 avec Ubuntu Pro)|
|**Philosophie**|100% libre par défaut|Pragmatique (propriétaire si utile)|

#### 📦 Dépôts et sources de mises à jour

**Structure des dépôts Debian**

```bash
# /etc/apt/sources.list sur Debian 12 (Bookworm)

# Dépôt principal (stable)
deb http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian bookworm main contrib non-free non-free-firmware

# Mises à jour de sécurité (priorité absolue)
deb http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware
deb-src http://security.debian.org/debian-security bookworm-security main contrib non-free non-free-firmware

# Mises à jour mineures (corrections de bugs)
deb http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian bookworm-updates main contrib non-free non-free-firmware
```

**Structure des dépôts Ubuntu**

```bash
# /etc/apt/sources.list sur Ubuntu 22.04 LTS (Jammy)

# Dépôt principal
deb http://archive.ubuntu.com/ubuntu jammy main restricted universe multiverse
deb-src http://archive.ubuntu.com/ubuntu jammy main restricted universe multiverse

# Mises à jour de sécurité (critiques)
deb http://security.ubuntu.com/ubuntu jammy-security main restricted universe multiverse
deb-src http://security.ubuntu.com/ubuntu jammy-security main restricted universe multiverse

# Mises à jour recommandées (correctifs importants)
deb http://archive.ubuntu.com/ubuntu jammy-updates main restricted universe multiverse
deb-src http://archive.ubuntu.com/ubuntu jammy-updates main restricted universe multiverse

# Backports (nouvelles versions sur base stable - optionnel)
# deb http://archive.ubuntu.com/ubuntu jammy-backports main restricted universe multiverse
```

#### 🔐 Gestion des mises à jour de sécurité

**Debian : approche minimaliste**

```bash
# Configuration unattended-upgrades pour Debian
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
    "${distro_id}:${distro_codename}-updates";  // Optionnel
};

# Les mises à jour de sécurité Debian sont très testées
# Délai plus long mais fiabilité maximale
```

**Ubuntu : approche plus agressive**

```bash
# Configuration unattended-upgrades pour Ubuntu
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
    "${distro_id}ESMApps:${distro_codename}-apps-security";  // Ubuntu Pro
    "${distro_id}ESM:${distro_codename}-infra-security";     // Ubuntu Pro
};

# Ubuntu publie les correctifs plus rapidement
# Compromis : légèrement moins testé mais plus réactif
```

> [!info] Ubuntu Pro (anciennement ESM) Ubuntu Pro offre 10 ans de support de sécurité (vs 5 ans pour Ubuntu LTS standard). Gratuit pour usage personnel (jusqu'à 5 machines) et petites entreprises.
> 
> ```bash
> # Activer Ubuntu Pro
> sudo pro attach [token]
> 
> # Vérifier le statut
> sudo pro status
> ```

#### 📅 Fréquence des mises à jour

**Debian Stable**

```bash
# Mises à jour de sécurité : quotidiennes à hebdomadaires
# Mises à jour bookworm-updates : mensuelles à trimestrielles
# Point releases (12.1, 12.2...) : tous les 2-3 mois

# Politique très conservatrice
# Exemple : OpenSSL reste en version 1.1.1 pendant toute la vie de Debian 11
```

**Ubuntu LTS**

```bash
# Mises à jour de sécurité : quotidiennes à hebdomadaires
# Mises à jour jammy-updates : hebdomadaires à mensuelles
# Point releases (22.04.1, 22.04.2...) : tous les 2-3 mois

# Plus de backports de nouvelles fonctionnalités
# Exemple : noyau Linux HWE (Hardware Enablement) avec versions récentes
```

#### 🔄 Commandes spécifiques

**Commandes identiques**

```bash
# Ces commandes fonctionnent identiquement sur Debian et Ubuntu
sudo apt update
sudo apt upgrade
sudo apt full-upgrade
apt list --upgradable
```

**Différences mineures**

```bash
# Ubuntu : commande pro pour Ubuntu Pro
sudo pro status
sudo pro attach
sudo pro detach

# Debian : pas d'équivalent direct
# Debian utilise parfois apt-get au lieu de apt dans les scripts
# (apt est la commande moderne, apt-get l'ancienne interface)
```

#### 🎯 Choix selon le contexte

**Quand choisir Debian :**

```bash
# ✅ Serveurs de production critiques (banques, hôpitaux)
# ✅ Besoin de stabilité maximale
# ✅ Infrastructure qui ne change pas souvent
# ✅ Préférence pour le 100% libre
# ✅ Serveurs qui restent en production 5+ ans

# Configuration type pour Debian
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
};
Unattended-Upgrade::Automatic-Reboot "false";
```

**Quand choisir Ubuntu :**

```bash
# ✅ Serveurs web/app standards
# ✅ Cloud et conteneurs (excellente intégration)
# ✅ Besoin de support commercial (Canonical)
# ✅ Matériel récent (meilleur support drivers)
# ✅ DevOps et CI/CD (plus de paquets récents)

# Configuration type pour Ubuntu
Unattended-Upgrade::Allowed-Origins {
    "${distro_id}:${distro_codename}-security";
    "${distro_id}ESMApps:${distro_codename}-apps-security";
    "${distro_id}ESM:${distro_codename}-infra-security";
};
Unattended-Upgrade::Automatic-Reboot "false";
Unattended-Upgrade::Automatic-Reboot-Time "03:00";
```

> [!tip] Stratégie hybride Beaucoup d'organisations utilisent :
> 
> - **Debian** pour les serveurs de bases de données et applications critiques
> - **Ubuntu LTS** pour les serveurs web, API et applications conteneurisées
> - **Ubuntu Server** pour les environnements de développement et staging

#### 📊 Tableau comparatif des cycles de vie

|Version|Type|Release|Fin de support standard|Support étendu|
|---|---|---|---|---|
|Debian 11|Stable|2021-08|~2024|~2026 (LTS)|
|Debian 12|Stable|2023-06|~2026|~2028 (LTS)|
|Ubuntu 20.04|LTS|2020-04|2025-04|2030-04 (Pro)|
|Ubuntu 22.04|LTS|2022-04|2027-04|2032-04 (Pro)|
|Ubuntu 24.04|LTS|2024-04|2029-04|2034-04 (Pro)|

> [!warning] Fin de support Planifiez vos migrations **6 mois avant** la fin du support standard pour avoir le temps de tester en environnement de staging.

---

## 🎓 Récapitulatif des concepts clés

### Mises à jour de sécurité

- **Priorité absolue** : à appliquer dans les 24-48h
- Filtrage : `apt list --upgradable | grep security`
- Automatisation recommandée avec `unattended-upgrades`

### Vérification des mises à jour

- `apt update` : rafraîchit la liste des paquets disponibles
- `apt list --upgradable` : affiche ce qui peut être mis à jour
- `apt upgrade --dry-run` : simule sans appliquer

### Automatisation

- `unattended-upgrades` : installe automatiquement les mises à jour de sécurité
- Configuration dans `/etc/apt/apt.conf.d/50unattended-upgrades`
- Monitoring essentiel via logs et notifications email

### Debian vs Ubuntu

- **Debian** : ultra-stable, conservateur, mises à jour très testées
- **Ubuntu** : plus réactif, backports disponibles, support commercial
- Les deux utilisent les mêmes commandes `apt` de base

---

> [!tip] 💡 Astuce finale Créez un script de maintenance hebdomadaire qui :
> 
> 1. Vérifie les mises à jour disponibles
> 2. Affiche les mises à jour de sécurité en priorité
> 3. Envoie un rapport par email
> 4. Vérifie si un redémarrage est nécessaire
> 
> Cela vous donnera une vue d'ensemble régulière de l'état de vos systèmes sans avoir à vous connecter à chaque serveur.