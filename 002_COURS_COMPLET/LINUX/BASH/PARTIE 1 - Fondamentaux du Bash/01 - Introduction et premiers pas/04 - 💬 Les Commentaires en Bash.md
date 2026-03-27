

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

Les commentaires sont des éléments essentiels dans tout script Bash. Ils permettent d'expliquer le code, de documenter les intentions du programmeur et de faciliter la maintenance future. Un code bien commenté est un code qui peut être compris et modifié facilement, même après plusieurs mois.

> [!info] Principe de base En Bash, tout ce qui suit le caractère `#` sur une ligne est ignoré par l'interpréteur et constitue un commentaire.

---

## Commentaires simples avec

### Syntaxe de base

Le caractère `#` transforme tout le reste de la ligne en commentaire :

```bash
# Ceci est un commentaire sur une ligne entière
echo "Hello World"  # Ceci est un commentaire en fin de ligne
```

### Utilisation et emplacements

Les commentaires simples peuvent être placés à différents endroits :

```bash
# Commentaire avant une commande
ls -la

ls -la  # Commentaire après une commande

# Commentaire expliquant un bloc de code
if [ -f "$fichier" ]; then
    echo "Le fichier existe"  # Confirmation
fi
```

> [!warning] Attention au shebang La toute première ligne `#!/bin/bash` ressemble à un commentaire mais c'est en réalité un **shebang** qui indique quel interpréteur utiliser. Elle ne doit jamais être supprimée ou considérée comme un simple commentaire.

### Quand utiliser les commentaires simples

|Situation|Exemple|
|---|---|
|Explication rapide|`# Supprime les fichiers temporaires`|
|Variable importante|`MAX_RETRY=3 # Nombre maximum de tentatives`|
|Section de code|`# === Vérification des prérequis ===`|
|Désactivation temporaire|`# echo "Debug mode" # Temporairement désactivé`|

### Commentaires en ligne

```bash
nom="Jean"        # Nom de l'utilisateur
age=25            # Âge en années
ville="Paris"     # Ville de résidence

# Alignement pour la lisibilité
compteur=0        # Initialisation du compteur
max_iterations=10 # Limite d'itérations
resultat=""       # Stockage du résultat final
```

> [!tip] Astuce d'alignement Aligner les commentaires en fin de ligne améliore considérablement la lisibilité, surtout pour les déclarations de variables.

---

## Commentaires multi-lignes

### Le problème

Bash n'a pas de syntaxe native pour les commentaires multi-lignes comme `/* ... */` en C ou `""" ... """` en Python. Cependant, plusieurs techniques existent.

### Méthode 1 : Commentaires simples consécutifs

La méthode la plus simple et la plus recommandée :

```bash
# Cette fonction calcule la somme de deux nombres
# et retourne le résultat.
# 
# Paramètres :
#   $1 - Premier nombre
#   $2 - Deuxième nombre
# 
# Retour :
#   La somme des deux nombres
fonction_somme() {
    echo $(( $1 + $2 ))
}
```

> [!tip] Avantage Cette méthode est claire, explicite et fonctionne dans tous les shells compatibles.

### Méthode 2 : Here-document avec redirection vers /dev/null

Technique utilisant un here-document :

```bash
: <<'COMMENTAIRE'
Ceci est un commentaire multi-lignes.
Toutes ces lignes seront ignorées.
On peut écrire ce qu'on veut ici :
- Des explications longues
- De la documentation
- Des exemples
COMMENTAIRE

echo "Le script continue ici"
```

**Décomposition :**

- `:` est une commande qui ne fait rien (équivalent de `true`)
- `<<'COMMENTAIRE'` crée un here-document jusqu'au mot `COMMENTAIRE`
- Les guillemets simples autour de `COMMENTAIRE` empêchent l'expansion des variables

> [!warning] Limitations
> 
> - Moins lisible que les commentaires simples
> - Peut être confus pour les débutants
> - Le délimiteur (ici `COMMENTAIRE`) ne doit apparaître nulle part dans le texte commenté

### Méthode 3 : Here-document alternatif

Variante plus concise :

```bash
: '
Commentaire
sur plusieurs
lignes
'
```

### Comparaison des méthodes

|Méthode|Lisibilité|Compatibilité|Usage recommandé|
|---|---|---|---|
|`#` multiples|⭐⭐⭐⭐⭐|Universelle|**Recommandé** pour la documentation|
|Here-doc|⭐⭐⭐|Universelle|Désactiver temporairement du code|
|`: '...'`|⭐⭐|Universelle|Commentaires très longs|

> [!example] Exemple pratique : désactiver du code temporairement
> 
> ```bash
> : <<'DISABLED'
> # Code de debug temporairement désactivé
> echo "Mode debug activé"
> set -x
> echo "Variables : $var1, $var2"
> set +x
> DISABLED
> ```

---

## Documentation en en-tête de script

Un bon script commence toujours par un en-tête documenté qui explique son objectif, son utilisation et ses prérequis.

### Structure d'un en-tête complet

```bash
#!/bin/bash

###############################################################################
# Nom du script : backup_database.sh
# Description   : Effectue une sauvegarde complète de la base de données MySQL
# Auteur        : Jean Dupont
# Date          : 2024-01-15
# Version       : 1.2.0
# Usage         : ./backup_database.sh [options] <nom_base>
# Options       :
#   -h, --help      Affiche cette aide
#   -v, --verbose   Mode verbeux
#   -d, --dir PATH  Répertoire de destination (défaut: /backups)
# Exemple       : ./backup_database.sh -v -d /tmp/backups production_db
# Prérequis     : 
#   - MySQL installé
#   - Droits sudo
#   - Espace disque suffisant (min 10GB)
# Notes         :
#   - Les sauvegardes sont compressées en .tar.gz
#   - Rotation automatique après 7 jours
###############################################################################
```

### Éléments essentiels d'un en-tête

> [!info] Composants obligatoires
> 
> 1. **Shebang** : `#!/bin/bash`
> 2. **Description** : Que fait le script ?
> 3. **Usage** : Comment l'utiliser ?
> 4. **Auteur et date** : Traçabilité

> [!tip] Composants optionnels mais utiles
> 
> - Version du script
> - Options disponibles avec exemples
> - Prérequis système
> - Dépendances externes
> - Licence
> - Changelog

### Template d'en-tête minimaliste

Pour les scripts simples :

```bash
#!/bin/bash
#
# Script : monitoring_disk.sh
# Description : Surveille l'espace disque et envoie une alerte si > 80%
# Usage : ./monitoring_disk.sh
# Auteur : Admin Système
# Date : 2024-12-16
#
```

### Template d'en-tête avancé

Pour les scripts de production :

```bash
#!/bin/bash

################################################################################
# SCRIPT: deploy_application.sh
# VERSION: 2.1.0
# DATE: 2024-12-16
# AUTHOR: DevOps Team <devops@example.com>
#
# DESCRIPTION:
#   Déploie l'application web sur les serveurs de production avec validation
#   et rollback automatique en cas d'échec.
#
# USAGE:
#   deploy_application.sh [OPTIONS] <environnement> <version>
#
# OPTIONS:
#   -h, --help              Affiche cette aide
#   -v, --verbose           Active le mode verbeux
#   -d, --dry-run           Simulation sans exécution réelle
#   -f, --force             Force le déploiement sans confirmation
#   -r, --rollback VERSION  Rollback vers une version spécifique
#
# ARGUMENTS:
#   environnement  staging|production
#   version        Numéro de version (ex: v2.1.0)
#
# EXEMPLES:
#   deploy_application.sh staging v2.1.0
#   deploy_application.sh -v production v2.1.0
#   deploy_application.sh --rollback v2.0.5 production
#
# PRÉREQUIS:
#   - Docker >= 20.10
#   - kubectl configuré avec accès au cluster
#   - Variables d'environnement : DEPLOY_TOKEN, SLACK_WEBHOOK
#   - Droits sudo pour redémarrage des services
#
# FICHIERS:
#   Configuration : /etc/deploy/config.yml
#   Logs : /var/log/deploy/deploy_$(date +%Y%m%d).log
#   Lock : /tmp/deploy.lock
#
# CODES DE SORTIE:
#   0  Succès
#   1  Erreur générale
#   2  Argument invalide
#   3  Prérequis manquant
#   10 Échec du déploiement
#   11 Échec du rollback
#
# NOTES:
#   - Un backup automatique est créé avant chaque déploiement
#   - Notification Slack envoyée à chaque étape critique
#   - Timeout de 30 minutes pour l'ensemble du processus
#
# CHANGELOG:
#   2.1.0 (2024-12-16) : Ajout du rollback automatique
#   2.0.0 (2024-11-01) : Support multi-environnements
#   1.5.0 (2024-09-15) : Intégration notifications Slack
#
# LICENSE: MIT
################################################################################
```

> [!example] En-tête avec ASCII art Pour les scripts importants ou les outils internes :
> 
> ```bash
> #!/bin/bash
> 
> ####################################################################
> #  ____             _                ____            _            #
> # | __ )  __ _  ___| | ___   _ _ __ / ___| _   _ ___| |_ ___ _ __ #
> # |  _ \ / _` |/ __| |/ / | | | '_ \\___ \| | | / __| __/ _ \ '__|#
> # | |_) | (_| | (__|   <| |_| | |_) |___) | |_| \__ \ ||  __/ |   #
> # |____/ \__,_|\___|_|\_\\__,_| .__/|____/ \__, |___/\__\___|_|   #
> #                             |_|          |___/                   #
> ####################################################################
> # Système de sauvegarde automatisé v3.0
> # Auteur: SysAdmin Team
> ####################################################################
> ```

---

## Bonnes pratiques de commentaires

### Principe général : Code auto-documenté

> [!info] Règle d'or Le meilleur commentaire est celui qu'on n'a pas besoin d'écrire. Privilégiez un code clair avec des noms de variables et fonctions explicites.

**Mauvais exemple :**

```bash
# Incrémente i
i=$((i + 1))
```

**Bon exemple :**

```bash
compteur_tentatives=$((compteur_tentatives + 1))
# Pas besoin de commentaire, le code se lit naturellement
```

### Quoi commenter et quoi ne pas commenter

#### ❌ À ÉVITER : Commentaires évidents

```bash
# Mauvais : répète ce que le code fait
x=5  # Assigne 5 à x
echo "Hello"  # Affiche Hello

# Mauvais : commentaire obsolète
MAX=100  # Maximum est 50  <- Incohérence !
```

#### ✅ À PRIVILÉGIER : Commentaires sur l'intention

```bash
# Bon : explique POURQUOI, pas QUOI
MAX_RETRY=3  # Limite à 3 pour éviter le blocage du service externe

# Bon : contexte métier
TIMEOUT=300  # 5 minutes : délai maximum accepté par le SLA client

# Bon : explication d'un choix technique
# On utilise 'find' plutôt que 'ls' pour gérer les noms avec espaces
find . -type f -name "*.log" -delete
```

### Structure des commentaires

#### Commentaires de section

Utilisez des séparateurs visuels pour structurer vos scripts :

```bash
################################################################################
# CONFIGURATION
################################################################################

CONFIG_FILE="/etc/app/config.ini"
LOG_DIR="/var/log/app"

################################################################################
# FONCTIONS
################################################################################

function verifier_prérequis() {
    # ...
}

################################################################################
# PROGRAMME PRINCIPAL
################################################################################

main() {
    # ...
}
```

Alternative avec des séparateurs légers :

```bash
# ==============================================================================
# INITIALISATION DES VARIABLES
# ==============================================================================

# === Configuration générale ===
APP_NAME="MonApp"
VERSION="1.0"

# === Chemins ===
DATA_DIR="/var/data"
BACKUP_DIR="/backups"

# === Paramètres réseau ===
HOST="localhost"
PORT=8080
```

#### Commentaires de fonction

Documentez chaque fonction avec son rôle, ses paramètres et sa valeur de retour :

```bash
################################################################################
# Fonction : sauvegarder_fichier
# Description : Crée une copie de sauvegarde horodatée d'un fichier
# Paramètres :
#   $1 - Chemin du fichier source (obligatoire)
#   $2 - Répertoire de destination (optionnel, défaut: ./backups)
# Retour :
#   0 - Succès
#   1 - Fichier source inexistant
#   2 - Erreur de copie
# Exemple :
#   sauvegarder_fichier "/etc/config.ini" "/tmp/backups"
################################################################################
sauvegarder_fichier() {
    local fichier_source="$1"
    local dest="${2:-./backups}"
    
    # Vérification de l'existence du fichier
    if [[ ! -f "$fichier_source" ]]; then
        echo "Erreur : fichier inexistant" >&2
        return 1
    fi
    
    # Création du nom de backup avec timestamp
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local nom_backup="$(basename "$fichier_source").$timestamp.bak"
    
    # Copie avec gestion d'erreur
    if cp "$fichier_source" "$dest/$nom_backup"; then
        echo "Sauvegarde créée : $dest/$nom_backup"
        return 0
    else
        echo "Erreur lors de la copie" >&2
        return 2
    fi
}
```

### Commentaires pour la logique complexe

Expliquez les algorithmes ou la logique non évidente :

```bash
# Calcul de la taille optimale du buffer
# Formule : (RAM_disponible * 0.6) / nombre_threads
# On limite à 512MB max pour éviter les OOM sur les petites machines
buffer_size=$(awk "BEGIN {
    ram = $RAM_TOTAL * 0.6;
    size = ram / $THREADS;
    print (size > 536870912) ? 536870912 : int(size)
}")

# Utilisation de 'exec' pour rediriger toutes les sorties suivantes
# Technique plus performante qu'une redirection par commande
exec 3>&1 4>&2  # Sauvegarde stdout et stderr
exec 1>>"$LOG_FILE" 2>&1  # Redirection globale
```

### Commentaires TODO, FIXME, HACK, NOTE

Utilisez des marqueurs standardisés pour signaler des points d'attention :

```bash
# TODO: Implémenter la gestion des erreurs réseau
# FIXME: Ce code plante avec des noms de fichiers contenant des guillemets
# HACK: Solution temporaire, refactoring prévu en v2.0
# NOTE: Cette fonction sera dépréciée dans la version 3.0
# XXX: Code dangereux, nécessite une révision urgente
# OPTIMIZE: Boucle inefficace pour de gros volumes (>10000 fichiers)
```

> [!tip] Intégration IDE Ces marqueurs (TODO, FIXME, etc.) sont reconnus par la plupart des éditeurs et IDEs, qui peuvent les lister automatiquement.

### Gestion de la maintenance

Ajoutez des informations de traçabilité pour les modifications importantes :

```bash
# MODIFIÉ: 2024-12-10 - Jean D. - Ajout support IPv6
if [[ "$IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] || \
   [[ "$IP" =~ ^([0-9a-fA-F]{0,4}:){7}[0-9a-fA-F]{0,4}$ ]]; then
    # ...
fi

# ANCIEN CODE (conservé pour référence jusqu'au 2025-01-01):
# if [[ "$IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
#     # ...
# fi
```

### Commentaires temporaires vs permanents

> [!warning] Nettoyage régulier Les commentaires temporaires (debug, tests) doivent être supprimés avant la mise en production.

```bash
# === CODE TEMPORAIRE - À SUPPRIMER AVANT RELEASE ===
# echo "DEBUG: valeur de \$USER = $USER"
# echo "DEBUG: valeur de \$HOME = $HOME"
# set -x  # Mode debug
# === FIN CODE TEMPORAIRE ===
```

### Longueur et format des commentaires

> [!tip] Règle des 80 caractères Limitez vos lignes de commentaires à 80 caractères pour une meilleure lisibilité sur tous les écrans.

```bash
# Mauvais : ligne trop longue
# Cette fonction effectue une validation complète de l'adresse email en vérifiant la syntaxe, l'existence du domaine via DNS, et la validité du MX record

# Bon : commentaire sur plusieurs lignes
# Cette fonction effectue une validation complète de l'adresse email :
# - Vérification de la syntaxe
# - Existence du domaine via DNS
# - Validité du MX record
```

### Commentaires et internationalisation

Pour les scripts internationaux, utilisez l'anglais dans les commentaires :

```bash
# EN: Check if user has root privileges
# FR: Vérifie si l'utilisateur a les privilèges root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root"
    exit 1
fi
```

Ou choisissez une langue unique (anglais recommandé pour le partage) :

```bash
# Check if the service is running before attempting restart
# This prevents unnecessary service disruption
if systemctl is-active --quiet "$SERVICE_NAME"; then
    systemctl restart "$SERVICE_NAME"
fi
```

### Récapitulatif des bonnes pratiques

|Pratique|✅ Faire|❌ Ne pas faire|
|---|---|---|
|**Clarté**|Expliquer le POURQUOI|Répéter le code|
|**Pertinence**|Commenter l'intention|Commenter l'évidence|
|**Mise à jour**|Actualiser avec le code|Laisser obsolète|
|**Structure**|Utiliser des sections|Commentaires anarchiques|
|**Concision**|Être précis et bref|Écrire des romans|
|**Cohérence**|Style uniforme|Formats variés|
|**Maintenance**|Utiliser TODO/FIXME|Commentaires vagues|
|**Longueur**|Max 80 caractères|Lignes infinies|

> [!tip] Astuce finale Relisez vos commentaires avant de committer votre code. Posez-vous la question : "Est-ce que ce commentaire apporte vraiment de la valeur ?" Si la réponse est non, supprimez-le ou améliorez-le.

---

## 📌 Points clés à retenir

- Les commentaires utilisent le symbole `#`
- Privilégiez les commentaires simples (`#`) aux here-documents pour la documentation
- Un bon en-tête de script facilite grandement la maintenance
- Commentez l'**intention** et le **pourquoi**, pas le **quoi**
- Utilisez des marqueurs standardisés (TODO, FIXME, HACK)
- Maintenez vos commentaires à jour avec votre code
- Un code clair avec de bons noms de variables réduit le besoin de commentaires