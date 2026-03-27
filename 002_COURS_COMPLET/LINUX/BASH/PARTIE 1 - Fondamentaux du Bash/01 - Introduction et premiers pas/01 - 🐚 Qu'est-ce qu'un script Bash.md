

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

## 🎯 Qu'est-ce qu'un script Bash

Un script Bash est un fichier texte contenant une série de commandes shell qui seront exécutées séquentiellement par l'interpréteur Bash. C'est un moyen d'automatiser des tâches répétitives et de créer des programmes simples sans avoir besoin d'un langage de programmation compilé.

> [!info] Pourquoi utiliser des scripts Bash ?
> 
> - **Automatisation** : Exécuter des séquences de commandes complexes en un seul clic
> - **Reproductibilité** : Garantir que les mêmes opérations sont effectuées de manière identique
> - **Gain de temps** : Éviter de retaper les mêmes commandes manuellement
> - **Documentation** : Le script lui-même documente le processus

---

## 📝 Définition d'un script shell

### Structure de base

Un script shell est simplement un fichier texte qui commence généralement par un **shebang** (prononcé "sha-bang") suivi de commandes shell.

```bash
#!/bin/bash
# Ceci est un commentaire
# Mon premier script Bash

echo "Bonjour, monde !"
echo "Nous sommes le $(date)"
```

### Le Shebang : `#!`

Le shebang indique au système quel interpréteur utiliser pour exécuter le script.

```bash
#!/bin/bash          # Utilise Bash (le plus courant)
#!/bin/sh            # Utilise le shell POSIX standard
#!/usr/bin/env bash  # Recherche bash dans le PATH (plus portable)
```

> [!tip] Bonne pratique : `#!/usr/bin/env bash` Cette syntaxe est plus portable car elle cherche `bash` dans le PATH de l'utilisateur plutôt que de supposer son emplacement exact. Utile si bash n'est pas dans `/bin/` sur certains systèmes.

### Rendre un script exécutable

Un script doit avoir les permissions d'exécution pour être lancé directement :

```bash
# Créer un fichier script
echo '#!/bin/bash' > mon_script.sh
echo 'echo "Hello"' >> mon_script.sh

# Rendre le script exécutable
chmod +x mon_script.sh

# Exécuter le script
./mon_script.sh
```

> [!warning] Attention au chemin Pour exécuter un script dans le répertoire courant, utilisez `./script.sh` et non `script.sh`. Sans le `./`, le shell cherchera le script dans les répertoires du PATH.

### Anatomie d'un script complet

```bash
#!/bin/bash
#
# Nom: backup.sh
# Description: Effectue une sauvegarde du répertoire home
# Auteur: Votre Nom
# Date: 2025-01-15
# Version: 1.0
#

# ============================================
# Configuration
# ============================================
BACKUP_DIR="/tmp/backups"
SOURCE_DIR="$HOME/documents"

# ============================================
# Corps du script
# ============================================
echo "Début de la sauvegarde..."

# Créer le répertoire de sauvegarde s'il n'existe pas
mkdir -p "$BACKUP_DIR"

# Effectuer la sauvegarde
cp -r "$SOURCE_DIR" "$BACKUP_DIR/"

echo "Sauvegarde terminée dans $BACKUP_DIR"
```

---

## 🔄 Différence entre shell interactif et script

### Shell interactif

Le shell interactif est l'environnement dans lequel vous tapez des commandes directement dans le terminal.

**Caractéristiques** :

- Attend une entrée utilisateur après chaque commande
- Affiche un prompt (PS1)
- Charge les fichiers de configuration personnalisés (`.bashrc`, `.bash_profile`)
- Permet l'édition de ligne et l'historique des commandes
- Erreurs affichées immédiatement sans arrêter la session

```bash
# Dans un terminal interactif
$ cd /tmp
$ ls
$ echo "Je peux taper des commandes une par une"
```

### Script shell

Un script est exécuté en mode non-interactif, de manière automatique et séquentielle.

**Caractéristiques** :

- Exécution automatique sans intervention utilisateur (sauf si demandée explicitement)
- Pas de prompt
- Charge uniquement certains fichiers de configuration (`.bash_profile` pour les shells de connexion)
- Les erreurs peuvent arrêter l'exécution (avec `set -e`)
- Peut être planifié via cron ou lancé à distance

```bash
#!/bin/bash
# Script exécuté automatiquement
cd /tmp
ls
echo "Toutes les commandes s'exécutent automatiquement"
```

### Tableau comparatif

|Aspect|Shell interactif|Script shell|
|---|---|---|
|**Mode d'exécution**|Manuel, commande par commande|Automatique, séquentiel|
|**Prompt**|Oui (PS1)|Non|
|**Fichiers de config**|`.bashrc`, `.bash_profile`|`.bash_profile` (login shell uniquement)|
|**Gestion erreurs**|Continue après une erreur|Peut s'arrêter (avec `set -e`)|
|**Historique**|Disponible (↑/↓)|Non disponible|
|**Édition de ligne**|Oui|Non|
|**Variables d'environnement**|Persistantes dans la session|Locales au script|
|**Utilisé pour**|Exploration, tests, commandes ponctuelles|Automatisation, tâches répétitives|

> [!example] Exemple pratique de la différence **Interactif** : Vous tapez `ls`, voyez le résultat, puis tapez `cd documents`, etc.
> 
> **Script** : Le fichier contient toutes les commandes qui s'exécutent d'un coup sans attendre.

### Comportements spécifiques

#### Variables d'environnement

```bash
# Shell interactif
$ export MA_VAR="valeur"
$ echo $MA_VAR      # Disponible
valeur
$ bash              # Nouveau shell
$ echo $MA_VAR      # Toujours disponible (exportée)
valeur

# Dans un script
#!/bin/bash
MA_VAR="valeur"     # Non exportée, locale au script
./autre_script.sh   # Ne verra pas MA_VAR
```

#### Gestion des erreurs

```bash
# Shell interactif : continue après une erreur
$ cd /repertoire/inexistant
bash: cd: /repertoire/inexistant: No such file or directory
$ echo "Je continue quand même"
Je continue quand même

# Script : peut s'arrêter
#!/bin/bash
set -e  # Arrête à la première erreur
cd /repertoire/inexistant
echo "Cette ligne ne sera jamais exécutée"
```

> [!tip] Mode strict dans les scripts Utilisez `set -euo pipefail` au début de vos scripts pour un comportement plus sûr :
> 
> - `-e` : arrête sur les erreurs
> - `-u` : erreur si variable non définie
> - `-o pipefail` : capture les erreurs dans les pipes

---

## 💼 Cas d'usage du scripting Bash

### 1. Administration système

Bash excelle dans les tâches d'administration système.

```bash
#!/bin/bash
# Nettoyage automatique des logs anciens

LOG_DIR="/var/log"
DAYS=30

# Supprimer les logs de plus de 30 jours
find "$LOG_DIR" -name "*.log" -mtime +$DAYS -delete

# Redémarrer le service de logs
systemctl restart rsyslog

echo "Nettoyage des logs terminé"
```

**Cas d'usage typiques** :

- Surveillance de l'espace disque
- Rotation des logs
- Gestion des utilisateurs
- Sauvegarde automatique
- Mise à jour des paquets

### 2. Automatisation de déploiements

```bash
#!/bin/bash
# Déploiement d'une application web

APP_DIR="/var/www/monapp"
REPO="https://github.com/user/monapp.git"

cd "$APP_DIR"
git pull origin main
npm install
npm run build
systemctl restart nginx

echo "Déploiement terminé avec succès"
```

**Cas d'usage typiques** :

- Déploiement CI/CD
- Build d'applications
- Synchronisation de serveurs
- Configuration d'environnements

### 3. Traitement de fichiers et données

```bash
#!/bin/bash
# Analyse de logs et extraction de statistiques

LOG_FILE="/var/log/access.log"

echo "=== Statistiques d'accès ==="
echo "Total de requêtes : $(wc -l < "$LOG_FILE")"
echo "Codes 404 : $(grep -c ' 404 ' "$LOG_FILE")"
echo "IPs uniques : $(awk '{print $1}' "$LOG_FILE" | sort -u | wc -l)"
```

**Cas d'usage typiques** :

- Traitement de CSV
- Parsing de logs
- Conversion de formats
- Agrégation de données
- Recherche et remplacement en masse

### 4. Tâches planifiées (cron)

```bash
#!/bin/bash
# Script de sauvegarde quotidienne (à exécuter via cron)

BACKUP_DIR="/backups/$(date +%Y%m%d)"
SOURCE="/home/user/data"

mkdir -p "$BACKUP_DIR"
tar -czf "$BACKUP_DIR/data.tar.gz" "$SOURCE"

# Supprimer les sauvegardes de plus de 7 jours
find /backups -type d -mtime +7 -exec rm -rf {} \;
```

**Planification cron** :

```bash
# Exécuter tous les jours à 2h du matin
0 2 * * * /usr/local/bin/backup.sh
```

### 5. Outils de développement

```bash
#!/bin/bash
# Script de setup d'environnement de développement

# Installer les dépendances
sudo apt-get update
sudo apt-get install -y git nodejs npm postgresql

# Cloner le projet
git clone https://github.com/user/projet.git
cd projet

# Configurer la base de données
sudo -u postgres createdb projet_dev

# Installer les dépendances du projet
npm install

echo "Environnement de développement prêt !"
```

**Cas d'usage typiques** :

- Setup d'environnements
- Scripts de build
- Tests automatisés
- Génération de documentation

### 6. Interaction avec des APIs

```bash
#!/bin/bash
# Récupération de données depuis une API

API_URL="https://api.exemple.com/data"
API_KEY="votre_cle_api"

# Récupérer et parser les données
response=$(curl -s -H "Authorization: Bearer $API_KEY" "$API_URL")

# Extraire une valeur avec jq (outil JSON)
valeur=$(echo "$response" | jq -r '.resultat')

echo "Valeur récupérée : $valeur"
```

> [!info] Quand ne PAS utiliser Bash ? Bash n'est pas adapté pour :
> 
> - Applications complexes avec beaucoup de logique
> - Calculs mathématiques avancés
> - Manipulation de structures de données complexes
> - Applications nécessitant de bonnes performances
> - Interfaces graphiques
> 
> Dans ces cas, privilégiez Python, Go, Rust ou d'autres langages de programmation.

---

## 🐚 Shells disponibles

### Vue d'ensemble

Unix et Linux proposent plusieurs interpréteurs de commandes (shells). Chacun a ses particularités et son histoire.

|Shell|Chemin|Description|Points forts|
|---|---|---|---|
|**sh**|`/bin/sh`|Bourne Shell (original)|Standard POSIX, très portable|
|**bash**|`/bin/bash`|Bourne Again Shell|Le plus utilisé, riche en fonctionnalités|
|**zsh**|`/bin/zsh`|Z Shell|Moderne, auto-complétion avancée|
|**dash**|`/bin/dash`|Debian Almquist Shell|Léger et rapide|
|**ksh**|`/bin/ksh`|Korn Shell|Puissant, utilisé en entreprise|
|**fish**|`/usr/bin/fish`|Friendly Interactive Shell|Syntaxe différente, très user-friendly|

### 1. sh (Bourne Shell)

Le shell original créé par Stephen Bourne en 1979.

```bash
#!/bin/sh
# Script POSIX compatible
echo "Shell standard"
```

**Caractéristiques** :

- ✅ Disponible sur TOUS les systèmes Unix/Linux
- ✅ Standard POSIX (portable)
- ❌ Fonctionnalités limitées
- ❌ Pas d'historique de commandes
- ❌ Pas d'auto-complétion avancée

> [!tip] Pour la portabilité maximale Si votre script doit fonctionner sur n'importe quel système Unix, utilisez `#!/bin/sh` et évitez les fonctionnalités spécifiques à Bash.

### 2. bash (Bourne Again Shell)

Le shell le plus populaire, successeur de sh.

```bash
#!/bin/bash
# Script avec fonctionnalités Bash
echo "Bonjour depuis Bash"
array=(un deux trois)
echo ${array[1]}  # Fonctionnalité non disponible en sh
```

**Caractéristiques** :

- ✅ Shell par défaut sur la plupart des distributions Linux
- ✅ Rétrocompatible avec sh
- ✅ Arrays, historique, auto-complétion
- ✅ Excellent pour le scripting
- ❌ Moins moderne que zsh pour l'usage interactif

**Fonctionnalités clés** :

- Arrays et dictionnaires (associative arrays)
- Expansion de paramètres avancée
- Arithmétique intégrée
- Gestion des processus
- Historique de commandes persistant

### 3. zsh (Z Shell)

Shell moderne et extensible, populaire dans la communauté des développeurs.

```bash
#!/bin/zsh
# Script zsh
echo "Shell moderne"
# Auto-complétion intelligente
# Correction de frappe
# Thèmes et plugins (Oh My Zsh)
```

**Caractéristiques** :

- ✅ Auto-complétion exceptionnelle
- ✅ Correction orthographique
- ✅ Thèmes et personnalisation (Oh My Zsh)
- ✅ Compatible avec la plupart des scripts bash
- ❌ Pas installé par défaut partout
- ❌ Légèrement plus lourd que bash

**Points forts interactifs** :

- Suggestion de commandes basée sur l'historique
- Expansion de chemins avancée (`cd /u/l/b` → `cd /usr/local/bin`)
- Partage d'historique entre sessions
- Plugins pour Git, Docker, etc.

### 4. dash (Debian Almquist Shell)

Shell minimaliste et ultra-rapide, souvent utilisé comme `/bin/sh` sur Debian/Ubuntu.

```bash
#!/bin/dash
# Script dash (rapide mais limité)
echo "Exécution rapide"
```

**Caractéristiques** :

- ✅ Extrêmement léger et rapide
- ✅ Conforme POSIX
- ✅ Idéal pour les scripts système
- ❌ Pas de fonctionnalités interactives
- ❌ Uniquement pour scripts, pas pour usage quotidien

> [!info] Dash comme /bin/sh Sur Debian et Ubuntu, `/bin/sh` pointe vers `dash` et non `bash`. C'est pourquoi les scripts avec `#!/bin/sh` ne doivent pas utiliser les fonctionnalités spécifiques à Bash.

### 5. fish (Friendly Interactive Shell)

Shell moderne avec une philosophie différente.

```bash
#!/usr/bin/fish
# Syntaxe différente !
set ma_variable "valeur"
echo $ma_variable
```

**Caractéristiques** :

- ✅ Syntaxe claire et cohérente
- ✅ Auto-complétion basée sur l'historique (dès le départ)
- ✅ Coloration syntaxique dans le prompt
- ✅ Configuration via web
- ❌ Syntaxe incompatible avec POSIX/bash
- ❌ Scripts non portables

**Exemple de différence syntaxique** :

```bash
# Bash
if [ -f "fichier.txt" ]; then
    echo "existe"
fi

# Fish
if test -f "fichier.txt"
    echo "existe"
end
```

### Vérifier votre shell

```bash
# Afficher le shell courant
echo $SHELL

# Lister les shells disponibles
cat /etc/shells

# Voir quel shell pointe /bin/sh
ls -l /bin/sh
```

### Changer de shell

```bash
# Changer temporairement (pour la session)
zsh

# Changer définitivement
chsh -s /bin/zsh

# Revenir à bash
chsh -s /bin/bash
```

### Compatibilité des scripts

> [!warning] Attention à la portabilité Si vous écrivez `#!/bin/bash`, votre script peut utiliser les fonctionnalités de Bash. Si vous écrivez `#!/bin/sh`, restez sur du POSIX strict pour garantir la portabilité.

**Fonctionnalités Bash non disponibles en sh** :

- `[[` pour les tests (utilisez `[` en sh)
- Arrays : `array=(1 2 3)`
- Expansion : `${var//search/replace}`
- Process substitution : `<(commande)`
- `source` (utilisez `.` en sh)

```bash
# ❌ Ne fonctionne pas en sh
#!/bin/sh
if [[ "$var" == "test" ]]; then
    echo "test"
fi

# ✅ Compatible sh
#!/bin/sh
if [ "$var" = "test" ]; then
    echo "test"
fi
```

---

## 🎓 Résumé

- Un **script Bash** est un fichier texte contenant des commandes shell, commençant par un shebang (`#!/bin/bash`)
- Il existe une différence fondamentale entre **shell interactif** (usage manuel) et **script** (automatisation)
- Bash est idéal pour l'**administration système**, l'**automatisation**, et le **traitement de fichiers**
- Plusieurs shells existent (**sh**, **bash**, **zsh**, **fish**), chacun avec ses forces
- **Bash** reste le standard pour le scripting, **zsh** est excellent pour l'usage interactif
- Pour la **portabilité maximale**, utilisez `#!/bin/sh` avec syntaxe POSIX