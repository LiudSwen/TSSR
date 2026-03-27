

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

## 🎯 Introduction aux Guest Additions

### Qu'est-ce que les Guest Additions ?

Les **Guest Additions** sont un ensemble de pilotes et d'applications système qui s'installent **à l'intérieur** de la VM guest pour améliorer les performances et l'intégration avec le système hôte.

> [!info] Pourquoi les Guest Additions sont essentielles Sans les Guest Additions, votre VM fonctionne avec des pilotes génériques limités. Avec elles, vous débloquez :
> 
> - Meilleure résolution d'écran et mode plein écran
> - Partage de dossiers entre hôte et guest
> - Presse-papier partagé
> - Glisser-déposer de fichiers
> - Meilleure performance graphique
> - Synchronisation de l'heure
> - Contrôle à distance via CLI

### Architecture des Guest Additions

```
┌─────────────────────────────────────┐
│       Système Hôte (Host)           │
│  ┌──────────────────────────────┐   │
│  │     VBoxManage CLI           │   │
│  └──────────────────────────────┘   │
│              ↕                      │
│  ┌──────────────────────────────┐   │
│  │  VirtualBox Hypervisor       │   │
│  └──────────────────────────────┘   │
└─────────────────────────────────────┘
              ↕
┌─────────────────────────────────────┐
│      VM Guest (Machine Virtuelle)   │
│  ┌──────────────────────────────┐   │
│  │   Guest Additions Service    │   │
│  │   - VBoxService (daemon)     │   │
│  │   - Pilotes graphiques       │   │
│  │   - Outils système           │   │
│  └──────────────────────────────┘   │
└─────────────────────────────────────┘
```

> [!warning] Prérequis important Les Guest Additions doivent correspondre à la version de VirtualBox. Une version 7.0 de VirtualBox nécessite les Guest Additions 7.0.

---

## 💾 Installation des Guest Additions

### Montage de l'image ISO

Les Guest Additions sont fournies sous forme d'image ISO que vous devez monter dans la VM.

```bash
# Monter l'ISO des Guest Additions dans le lecteur CD/DVD
VBoxManage storageattach "MaVM" \
    --storagectl "IDE" \
    --port 1 \
    --device 0 \
    --type dvddrive \
    --medium /usr/share/virtualbox/VBoxGuestAdditions.iso
```

> [!tip] Localisation de l'ISO L'emplacement de l'ISO varie selon le système :
> 
> - **Linux** : `/usr/share/virtualbox/VBoxGuestAdditions.iso`
> - **macOS** : `/Applications/VirtualBox.app/Contents/MacOS/VBoxGuestAdditions.iso`
> - **Windows** : `C:\Program Files\Oracle\VirtualBox\VBoxGuestAdditions.iso`

### Installation dans le guest Linux

Une fois l'ISO montée, connectez-vous à la VM et exécutez :

```bash
# Créer un point de montage
sudo mkdir -p /mnt/cdrom

# Monter le CD
sudo mount /dev/cdrom /mnt/cdrom

# Installer les Guest Additions
cd /mnt/cdrom
sudo ./VBoxLinuxAdditions.run

# Redémarrer la VM pour activer les changements
sudo reboot
```

> [!warning] Dépendances nécessaires Sur certaines distributions, vous devez installer les headers du kernel avant :
> 
> ```bash
> # Debian/Ubuntu
> sudo apt install build-essential linux-headers-$(uname -r)
> 
> # RHEL/CentOS
> sudo yum install gcc kernel-devel kernel-headers
> ```

### Installation dans le guest Windows

```bash
# Une fois l'ISO montée, dans la VM Windows :
# 1. Ouvrir l'Explorateur de fichiers
# 2. Double-cliquer sur le lecteur CD
# 3. Exécuter VBoxWindowsAdditions.exe
# 4. Suivre l'assistant d'installation
# 5. Redémarrer la VM
```

### Vérification de l'installation

```bash
# Vérifier que les Guest Additions sont installées
VBoxManage guestproperty get "MaVM" "/VirtualBox/GuestAdd/Version"

# Exemple de sortie attendue :
# Value: 7.0.14
```

> [!example] Vérification complète
> 
> ```bash
> # Obtenir toutes les informations des Guest Additions
> VBoxManage guestproperty enumerate "MaVM" | grep GuestAdd
> 
> # Sortie :
> # /VirtualBox/GuestAdd/Version: 7.0.14
> # /VirtualBox/GuestAdd/Revision: 161095
> # /VirtualBox/GuestAdd/VersionExt: 7.0.14
> ```

### Démonter l'ISO après installation

```bash
# Retirer l'ISO du lecteur
VBoxManage storageattach "MaVM" \
    --storagectl "IDE" \
    --port 1 \
    --device 0 \
    --type dvddrive \
    --medium none
```

---

## 🔧 Gestion des propriétés guest (guestproperty)

### Concept des propriétés guest

Les **propriétés guest** sont des paires clé-valeur qui permettent la communication bidirectionnelle entre l'hôte et le guest. Elles servent à :

- Échanger des informations de configuration
- Surveiller l'état du guest
- Transmettre des métadonnées
- Synchroniser des paramètres

> [!info] Comment ça fonctionne Les propriétés sont stockées dans la mémoire partagée entre l'hôte et le guest. Le service VBoxService dans le guest lit et met à jour ces propriétés en temps réel.

### Lire une propriété

```bash
# Syntaxe générale
VBoxManage guestproperty get <vm> <propriété>

# Exemple : obtenir l'adresse IP du guest
VBoxManage guestproperty get "MaVM" "/VirtualBox/GuestInfo/Net/0/V4/IP"

# Sortie :
# Value: 192.168.1.100
```

### Définir une propriété

```bash
# Syntaxe générale
VBoxManage guestproperty set <vm> <propriété> <valeur>

# Exemple : définir une propriété personnalisée
VBoxManage guestproperty set "MaVM" "/CustomApp/Config/Environment" "production"

# Exemple : définir avec des drapeaux (flags)
VBoxManage guestproperty set "MaVM" "/CustomApp/Secret" "mot_de_passe" \
    --flags TRANSIENT,RDONLYGUEST
```

> [!tip] Drapeaux disponibles
> 
> - **TRANSIENT** : la propriété disparaît au redémarrage de la VM
> - **RDONLYGUEST** : lecture seule depuis le guest
> - **RDONLYHOST** : lecture seule depuis l'hôte
> - **READONLY** : lecture seule des deux côtés

### Lister toutes les propriétés

```bash
# Lister toutes les propriétés d'une VM
VBoxManage guestproperty enumerate "MaVM"

# Filtrer par pattern
VBoxManage guestproperty enumerate "MaVM" --patterns "/VirtualBox/GuestInfo/*"

# Exemple de sortie :
# /VirtualBox/GuestInfo/OS/Product: Linux
# /VirtualBox/GuestInfo/OS/Release: 5.15.0-91-generic
# /VirtualBox/GuestInfo/Net/0/V4/IP: 192.168.1.100
```

### Supprimer une propriété

```bash
# Supprimer une propriété spécifique
VBoxManage guestproperty delete "MaVM" "/CustomApp/Config/Environment"

# Supprimer avec un pattern (nécessite --delete dans enumerate)
VBoxManage guestproperty enumerate "MaVM" --patterns "/CustomApp/*" | \
    awk -F': ' '{print $1}' | \
    xargs -I {} VBoxManage guestproperty delete "MaVM" "{}"
```

### Attendre un changement de propriété

```bash
# Attendre qu'une propriété change (timeout en millisecondes)
VBoxManage guestproperty wait "MaVM" "/CustomApp/Status" --timeout 30000

# Exemple d'usage : attendre que la VM soit prête
VBoxManage guestproperty wait "MaVM" "/VirtualBox/GuestInfo/Net/0/V4/IP" \
    --timeout 60000

# Si la propriété change, elle sera affichée
# Si timeout, retourne un code d'erreur
```

> [!example] Script d'attente de démarrage
> 
> ```bash
> #!/bin/bash
> VM_NAME="MaVM"
> 
> echo "Démarrage de la VM..."
> VBoxManage startvm "$VM_NAME" --type headless
> 
> echo "Attente de l'IP réseau..."
> if VBoxManage guestproperty wait "$VM_NAME" \
>        "/VirtualBox/GuestInfo/Net/0/V4/IP" --timeout 120000; then
>     IP=$(VBoxManage guestproperty get "$VM_NAME" \
>          "/VirtualBox/GuestInfo/Net/0/V4/IP" | awk '{print $2}')
>     echo "VM prête ! IP: $IP"
> else
>     echo "Timeout : la VM n'a pas démarré correctement"
>     exit 1
> fi
> ```

### Propriétés système courantes

|Propriété|Description|Exemple de valeur|
|---|---|---|
|`/VirtualBox/GuestInfo/OS/Product`|Système d'exploitation|`Linux`, `Windows`|
|`/VirtualBox/GuestInfo/OS/Release`|Version du kernel/OS|`5.15.0-91-generic`|
|`/VirtualBox/GuestInfo/Net/0/V4/IP`|Adresse IPv4|`192.168.1.100`|
|`/VirtualBox/GuestInfo/Net/0/MAC`|Adresse MAC|`080027ABC123`|
|`/VirtualBox/GuestAdd/Version`|Version Guest Additions|`7.0.14`|
|`/VirtualBox/HostInfo/GUI/LanguageID`|Langue de l'interface|`fr_FR`|

> [!warning] Propriétés en lecture seule La plupart des propriétés système (`/VirtualBox/*`) sont mises à jour automatiquement par VBoxService et ne doivent pas être modifiées manuellement.

### Cas d'usage pratiques

```bash
# 1. Surveiller l'état du guest
VBoxManage guestproperty get "MaVM" "/VirtualBox/GuestInfo/OS/LoggedInUsers"

# 2. Obtenir les informations réseau
VBoxManage guestproperty enumerate "MaVM" --patterns "/VirtualBox/GuestInfo/Net/*"

# 3. Communication entre scripts hôte et guest
# Côté hôte : définir une commande
VBoxManage guestproperty set "MaVM" "/Scripts/Command" "backup"

# Côté guest : lire et exécuter
COMMAND=$(VBoxControl guestproperty get /Scripts/Command | awk -F': ' '{print $2}')
if [ "$COMMAND" = "backup" ]; then
    /usr/local/bin/backup.sh
fi
```

---

## 🎮 Exécution de commandes (guestcontrol)

### Introduction à guestcontrol

Le module `guestcontrol` permet d'exécuter des commandes et des programmes **à l'intérieur** de la VM depuis l'hôte, comme si vous étiez connecté en SSH.

> [!info] Prérequis
> 
> - Guest Additions installées et fonctionnelles
> - VM en cours d'exécution
> - Identifiants d'un utilisateur du guest

### Syntaxe générale

```bash
VBoxManage guestcontrol <vm> <commande> [options] \
    --username <utilisateur> \
    --password <mot_de_passe>
```

> [!warning] Sécurité des mots de passe Passer le mot de passe en ligne de commande est dangereux (visible dans l'historique). Alternatives :
> 
> - Utiliser `--passwordfile <fichier>` (fichier contenant le mot de passe)
> - Utiliser `--domain` pour l'authentification Windows
> - Configurer l'authentification par clés pour certains cas

### Exécuter une commande simple

```bash
# Exécuter une commande shell
VBoxManage guestcontrol "MaVM" run \
    --exe /bin/ls \
    --username user \
    --password pass123 \
    -- -la /home/user

# Syntaxe Windows
VBoxManage guestcontrol "WindowsVM" run \
    --exe "C:\Windows\System32\cmd.exe" \
    --username Administrator \
    --password admin123 \
    -- /c dir C:\
```

> [!tip] Le double tiret `--` Le `--` sépare les options de VBoxManage des arguments de la commande exécutée. Tout ce qui suit `--` est passé directement au programme.

### Exécuter avec options avancées

```bash
# Exécuter avec timeout et environnement personnalisé
VBoxManage guestcontrol "MaVM" run \
    --exe /usr/bin/python3 \
    --username user \
    --password pass123 \
    --timeout 30000 \
    --environment "PATH=/usr/local/bin:$PATH" "DEBUG=1" \
    --wait-stdout \
    --wait-stderr \
    -- /home/user/script.py --verbose

# Options courantes :
# --timeout <ms>        : timeout en millisecondes
# --wait-exit           : attendre la fin du processus
# --wait-stdout         : capturer la sortie standard
# --wait-stderr         : capturer la sortie d'erreur
# --environment         : définir des variables d'environnement
```

### Capturer la sortie d'une commande

```bash
# Méthode 1 : redirection dans un fichier temporaire
VBoxManage guestcontrol "MaVM" run \
    --exe /bin/bash \
    --username user \
    --password pass123 \
    --wait-stdout \
    -- -c "df -h" > /tmp/output.txt

# Méthode 2 : utiliser une variable
OUTPUT=$(VBoxManage guestcontrol "MaVM" run \
    --exe /bin/bash \
    --username user \
    --password pass123 \
    --wait-stdout \
    -- -c "hostname -I" 2>/dev/null)

echo "Adresse IP du guest : $OUTPUT"
```

> [!example] Script de diagnostic
> 
> ```bash
> #!/bin/bash
> VM="MaVM"
> USER="admin"
> PASS="admin123"
> 
> echo "=== Diagnostic de la VM ==="
> 
> # Uptime
> echo "Uptime :"
> VBoxManage guestcontrol "$VM" run \
>     --exe /usr/bin/uptime \
>     --username "$USER" --password "$PASS" \
>     --wait-stdout
> 
> # Utilisation disque
> echo -e "\nEspace disque :"
> VBoxManage guestcontrol "$VM" run \
>     --exe /bin/df \
>     --username "$USER" --password "$PASS" \
>     --wait-stdout \
>     -- -h /
> 
> # Processus consommateurs
> echo -e "\nTop 5 processus :"
> VBoxManage guestcontrol "$VM" run \
>     --exe /bin/ps \
>     --username "$USER" --password "$PASS" \
>     --wait-stdout \
>     -- aux --sort=-%cpu | head -6
> ```

### Exécution en arrière-plan

```bash
# Démarrer un processus sans attendre
VBoxManage guestcontrol "MaVM" run \
    --exe /usr/bin/python3 \
    --username user \
    --password pass123 \
    -- /home/user/long_running_script.py &

# Obtenir le PID pour un contrôle ultérieur
VBoxManage guestcontrol "MaVM" run \
    --exe /bin/bash \
    --username user \
    --password pass123 \
    --wait-stdout \
    -- -c "nohup /usr/bin/myapp > /var/log/myapp.log 2>&1 & echo \$!"
```

### Gérer les chemins et les espaces

```bash
# Chemin avec espaces (Linux)
VBoxManage guestcontrol "MaVM" run \
    --exe /bin/bash \
    --username user \
    --password pass123 \
    -- -c "cd '/home/user/My Documents' && ls -la"

# Chemin avec espaces (Windows)
VBoxManage guestcontrol "WindowsVM" run \
    --exe "C:\Windows\System32\cmd.exe" \
    --username user \
    --password pass123 \
    -- /c "dir \"C:\Program Files\""
```

> [!warning] Échappement des caractères spéciaux Les caractères spéciaux du shell (`,` , `$`, `>`, etc.) doivent être échappés ou encapsulés dans des guillemets pour éviter une interprétation par le shell de l'hôte.

---

## 📁 Copie de fichiers vers/depuis le guest

### Copier un fichier vers le guest

```bash
# Syntaxe générale
VBoxManage guestcontrol <vm> copyto <source-host> <destination-guest> \
    --username <user> \
    --password <pass>

# Exemple : copier un fichier
VBoxManage guestcontrol "MaVM" copyto \
    /home/host/document.txt \
    /home/user/document.txt \
    --username user \
    --password pass123

# Exemple : copier vers un autre nom
VBoxManage guestcontrol "MaVM" copyto \
    /tmp/config.ini \
    /etc/myapp/config.ini \
    --username root \
    --password rootpass
```

> [!tip] Créer les répertoires parents Ajoutez l'option `--target-directory` pour créer automatiquement les dossiers intermédiaires :
> 
> ```bash
> VBoxManage guestcontrol "MaVM" copyto \
>     /home/host/data.csv \
>     /opt/app/data/import/data.csv \
>     --target-directory /opt/app/data/import \
>     --username user \
>     --password pass123
> ```

### Copier un fichier depuis le guest

```bash
# Syntaxe générale
VBoxManage guestcontrol <vm> copyfrom <source-guest> <destination-host> \
    --username <user> \
    --password <pass>

# Exemple : récupérer un fichier
VBoxManage guestcontrol "MaVM" copyfrom \
    /var/log/application.log \
    /home/host/logs/app-$(date +%Y%m%d).log \
    --username user \
    --password pass123

# Exemple : récupérer un fichier de configuration
VBoxManage guestcontrol "MaVM" copyfrom \
    /etc/nginx/nginx.conf \
    /home/host/backups/nginx.conf.backup \
    --username root \
    --password rootpass
```

### Copier un répertoire complet

```bash
# Copier un répertoire vers le guest (récursif)
VBoxManage guestcontrol "MaVM" copyto \
    /home/host/projet/ \
    /home/user/projet/ \
    --username user \
    --password pass123 \
    --recursive

# Copier un répertoire depuis le guest
VBoxManage guestcontrol "MaVM" copyfrom \
    /var/www/html/ \
    /home/host/backup/www/ \
    --username www-data \
    --password pass123 \
    --recursive
```

> [!warning] Performances avec de gros fichiers Le transfert via `guestcontrol` peut être lent pour de très gros fichiers (> 100 Mo). Alternatives :
> 
> - Utiliser les dossiers partagés VirtualBox
> - Configurer un serveur SSH/SCP dans le guest
> - Utiliser le réseau avec rsync ou scp

### Gérer les permissions lors de la copie

```bash
# Spécifier les permissions du fichier destination
VBoxManage guestcontrol "MaVM" copyto \
    /home/host/script.sh \
    /usr/local/bin/backup.sh \
    --username root \
    --password rootpass

# Puis modifier les permissions via run
VBoxManage guestcontrol "MaVM" run \
    --exe /bin/chmod \
    --username root \
    --password rootpass \
    -- +x /usr/local/bin/backup.sh
```

### Cas d'usage : déploiement d'application

```bash
#!/bin/bash
VM="MaVM"
USER="deploy"
PASS="deploypass"
APP_DIR="/opt/myapp"

echo "Déploiement de l'application..."

# 1. Copier les fichiers de l'application
echo "Copie des fichiers..."
VBoxManage guestcontrol "$VM" copyto \
    ./dist/ \
    "$APP_DIR/" \
    --username "$USER" \
    --password "$PASS" \
    --recursive

# 2. Copier le fichier de configuration
echo "Copie de la configuration..."
VBoxManage guestcontrol "$VM" copyto \
    ./config.prod.yaml \
    "$APP_DIR/config.yaml" \
    --username "$USER" \
    --password "$PASS"

# 3. Redémarrer le service
echo "Redémarrage du service..."
VBoxManage guestcontrol "$VM" run \
    --exe /usr/bin/sudo \
    --username "$USER" \
    --password "$PASS" \
    -- systemctl restart myapp

echo "Déploiement terminé !"
```

### Copie avec authentification par fichier

```bash
# Créer un fichier de mot de passe (permissions 600)
echo "mon_mot_de_passe_secret" > /tmp/.vmpass
chmod 600 /tmp/.vmpass

# Utiliser le fichier pour l'authentification
VBoxManage guestcontrol "MaVM" copyto \
    /home/host/data.tar.gz \
    /tmp/data.tar.gz \
    --username admin \
    --passwordfile /tmp/.vmpass

# Nettoyer
rm /tmp/.vmpass
```

> [!tip] Astuce pour Windows Pour Windows, utilisez des chemins avec des antislashes échappés ou des slashs normaux :
> 
> ```bash
> VBoxManage guestcontrol "WindowsVM" copyto \
>     /home/host/setup.exe \
>     "C:/Users/Admin/Desktop/setup.exe" \
>     --username Admin \
>     --password pass123
> ```

---

## ⚙️ Gestion des processus guest

### Lister les processus actifs

```bash
# Lister tous les processus dans le guest
VBoxManage guestcontrol "MaVM" list processes \
    --username user \
    --password pass123

# Exemple de sortie :
# PID: 1234  Name: nginx        User: www-data
# PID: 5678  Name: python3      User: user
# PID: 9012  Name: mysqld       User: mysql
```

### Lister avec filtrage

```bash
# Filtrer par nom de processus
VBoxManage guestcontrol "MaVM" list processes \
    --username user \
    --password pass123 | grep nginx

# Obtenir les processus d'un utilisateur spécifique
VBoxManage guestcontrol "MaVM" run \
    --exe /bin/ps \
    --username root \
    --password rootpass \
    --wait-stdout \
    -- -u www-data
```

### Démarrer un processus

```bash
# Démarrer un processus et récupérer son PID
PID=$(VBoxManage guestcontrol "MaVM" run \
    --exe /usr/bin/python3 \
    --username user \
    --password pass123 \
    --wait-stdout \
    -- -c "import os; import time; print(os.getpid()); time.sleep(300)" | head -1)

echo "Processus démarré avec PID: $PID"
```

### Terminer un processus

```bash
# Méthode 1 : via kill dans le guest
VBoxManage guestcontrol "MaVM" run \
    --exe /bin/kill \
    --username user \
    --password pass123 \
    -- -9 1234

# Méthode 2 : via killall par nom
VBoxManage guestcontrol "MaVM" run \
    --exe /usr/bin/killall \
    --username root \
    --password rootpass \
    -- nginx

# Méthode 3 : via systemctl pour les services
VBoxManage guestcontrol "MaVM" run \
    --exe /bin/systemctl \
    --username root \
    --password rootpass \
    -- stop nginx
```

### Surveiller un processus

```bash
# Vérifier si un processus existe
VBoxManage guestcontrol "MaVM" run \
    --exe /bin/pgrep \
    --username user \
    --password pass123 \
    --wait-stdout \
    -- -f "python.*myapp.py"

# Si le processus existe, pgrep retourne son PID
# Si non, retourne un code d'erreur non nul
```

> [!example] Script de surveillance
> 
> ```bash
> #!/bin/bash
> VM="MaVM"
> USER="monitor"
> PASS="monitorpass"
> PROCESS_NAME="nginx"
> 
> while true; do
>     if ! VBoxManage guestcontrol "$VM" run \
>          --exe /bin/pgrep \
>          --username "$USER" \
>          --password "$PASS" \
>          --wait-stdout \
>          -- "$PROCESS_NAME" &>/dev/null; then
>         
>         echo "ALERTE : $PROCESS_NAME n'est pas en cours d'exécution !"
>         echo "Tentative de redémarrage..."
>         
>         VBoxManage guestcontrol "$VM" run \
>             --exe /bin/systemctl \
>             --username "$USER" \
>             --password "$PASS" \
>             -- start "$PROCESS_NAME"
>     else
>         echo "$(date) : $PROCESS_NAME fonctionne correctement"
>     fi
>     
>     sleep 60
> done
> ```

### Obtenir des informations détaillées sur un processus

```bash
# Informations sur l'utilisation CPU/Mémoire
VBoxManage guestcontrol "MaVM" run \
    --exe /bin/ps \
    --username user \
    --password pass123 \
    --wait-stdout \
    -- -p 1234 -o pid,pcpu,pmem,vsz,rss,cmd

# Fichiers ouverts par un processus
VBoxManage guestcontrol "MaVM" run \
    --exe /usr/bin/lsof \
    --username root \
    --password rootpass \
    --wait-stdout \
    -- -p 1234

# Connexions réseau d'un processus
VBoxManage guestcontrol "MaVM" run \
    --exe /bin/netstat \
    --username root \
    --password rootpass \
    --wait-stdout \
    -- -tulpn | grep 1234
```

### Gestion des sessions guest

```bash
# Lister les sessions actives
VBoxManage guestcontrol "MaVM" list sessions \
    --username user \
    --password pass123

# Créer une session persistante pour plusieurs commandes
SESSION_ID=$(VBoxManage guestcontrol "MaVM" session create \
    --username user \
    --password pass123 | grep "Session ID" | awk '{print $3}')

# Utiliser la session
VBoxManage guestcontrol "MaVM" session run $SESSION_ID \
    --exe /bin/ls -- /home/user

# Fermer la session
VBoxManage guestcontrol "MaVM" session close $SESSION_ID
```

> [!info] Avantage des sessions Les sessions permettent de réutiliser l'authentification et d'exécuter plusieurs commandes sans re-spécifier les identifiants à chaque fois.

### Cas d'usage : gestion automatisée des services

```bash
#!/bin/bash
VM="ProdVM"
USER="sysadmin"
PASS="admin123"

# Fonction pour vérifier un service
check_service() {
    local service=$1
    
    if VBoxManage guestcontrol "$VM" run \
         --exe /bin/systemctl \
         --username "$USER" \
         --password "$PASS" \
         --wait-stdout \
         -- is-active "$service" &>/dev/null; then
        echo "✓ $service : actif"
        return 0
    else
        echo "✗ $service : inactif"
        return 1
    fi
}

# Fonction pour redémarrer un service
restart_service() {
    local service=$1
    
    echo "Redémarrage de $service..."
    VBoxManage guestcontrol "$VM" run \
        --exe /bin/systemctl \
        --username "$USER" \
        --password "$PASS" \
        -- restart "$service"
    
    sleep 3
    
    if check_service "$service"; then
        echo "✓ $service redémarré avec succès"
        return 0
    else
        echo "✗ Échec du redémarrage de $service"
        return 1
    fi
}

# Liste des services critiques
SERVICES=("nginx" "mysql" "redis-server" "php8.1-fpm")

echo "=== Vérification des services critiques ==="
for service in "${SERVICES[@]}"; do
    if ! check_service "$service"; then
        echo "Tentative de redémarrage..."
        restart_service "$service"
    fi
done
```

### Gestion avancée : timeout et retry

```bash
#!/bin/bash

# Exécuter une commande avec retry automatique
execute_with_retry() {
    local max_attempts=3
    local timeout=10000  # 10 secondes
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        echo "Tentative $attempt/$max_attempts..."
        
        if VBoxManage guestcontrol "MaVM" run \
             --exe /bin/bash \
             --username user \
             --password pass123 \
             --timeout $timeout \
             --wait-exit \
             -- -c "$1"; then
            echo "Commande réussie !"
            return 0
        else
            echo "Échec de la tentative $attempt"
            attempt=$((attempt + 1))
            [ $attempt -le $max_attempts ] && sleep 5
        fi
    done
    
    echo "Échec après $max_attempts tentatives"
    return 1
}

# Utilisation
execute_with_retry "systemctl restart myapp && systemctl is-active myapp"
```

### Monitoring en temps réel

```bash
# Script de monitoring continu
#!/bin/bash
VM="MaVM"
USER="monitor"
PASS="pass123"

echo "Démarrage du monitoring de la VM $VM..."

while true; do
    clear
    echo "=== Monitoring - $(date) ==="
    echo ""
    
    # Load average
    echo "Load Average:"
    VBoxManage guestcontrol "$VM" run \
        --exe /bin/cat \
        --username "$USER" \
        --password "$PASS" \
        --wait-stdout \
        -- /proc/loadavg 2>/dev/null
    echo ""
    
    # Mémoire
    echo "Mémoire:"
    VBoxManage guestcontrol "$VM" run \
        --exe /usr/bin/free \
        --username "$USER" \
        --password "$PASS" \
        --wait-stdout \
        -- -h 2>/dev/null
    echo ""
    
    # Top 5 processus CPU
    echo "Top 5 processus (CPU):"
    VBoxManage guestcontrol "$VM" run \
        --exe /bin/ps \
        --username "$USER" \
        --password "$PASS" \
        --wait-stdout \
        -- aux --sort=-%cpu 2>/dev/null | head -6
    
    sleep 5
done
```

---

## 💡 Bonnes pratiques et astuces

### Sécurité des identifiants

> [!warning] Ne jamais mettre les mots de passe en clair
> 
> ```bash
> # ❌ MAUVAIS : mot de passe visible
> VBoxManage guestcontrol "MaVM" run --password "monMotDePasse123" ...
> 
> # ✅ BON : utiliser un fichier protégé
> echo "monMotDePasse123" > ~/.vm_credentials
> chmod 600 ~/.vm_credentials
> VBoxManage guestcontrol "MaVM" run --passwordfile ~/.vm_credentials ...
> 
> # ✅ BON : utiliser des variables d'environnement
> export VM_PASSWORD="monMotDePasse123"
> VBoxManage guestcontrol "MaVM" run --password "$VM_PASSWORD" ...
> ```

### Gestion des erreurs

```bash
# Toujours vérifier les codes de retour
if VBoxManage guestcontrol "MaVM" run \
     --exe /bin/bash \
     --username user \
     --password pass123 \
     -- -c "systemctl restart nginx"; then
    echo "Service redémarré avec succès"
else
    echo "ERREUR : Échec du redémarrage (code: $?)"
    # Actions de récupération
fi

# Utiliser set -e pour arrêter en cas d'erreur
set -e
VBoxManage guestcontrol "MaVM" copyto file.txt /tmp/
VBoxManage guestcontrol "MaVM" run --exe /bin/process ...
```

### Optimisation des performances

> [!tip] Réutiliser les connexions
> 
> ```bash
> # ❌ LENT : nouvelle authentification à chaque fois
> VBoxManage guestcontrol "MaVM" run --username u --password p --exe /bin/cmd1
> VBoxManage guestcontrol "MaVM" run --username u --password p --exe /bin/cmd2
> VBoxManage guestcontrol "MaVM" run --username u --password p --exe /bin/cmd3
> 
> # ✅ RAPIDE : utiliser une session
> SID=$(VBoxManage guestcontrol "MaVM" session create \
>     --username u --password p | grep "Session ID" | awk '{print $3}')
> VBoxManage guestcontrol "MaVM" session run $SID --exe /bin/cmd1
> VBoxManage guestcontrol "MaVM" session run $SID --exe /bin/cmd2
> VBoxManage guestcontrol "MaVM" session run $SID --exe /bin/cmd3
> VBoxManage guestcontrol "MaVM" session close $SID
> ```

### Logs et debugging

```bash
# Activer les logs verbeux
VBoxManage guestcontrol "MaVM" run \
    --exe /bin/bash \
    --username user \
    --password pass123 \
    --verbose \
    -- -c "mon_script.sh"

# Rediriger stderr pour capturer les erreurs
VBoxManage guestcontrol "MaVM" run \
    --exe /bin/bash \
    --username user \
    --password pass123 \
    --wait-stdout \
    --wait-stderr \
    -- -c "mon_script.sh" 2>&1 | tee /var/log/vm_execution.log
```

### Patterns avancés

```bash
# Pattern : Exécution conditionnelle
VBoxManage guestcontrol "MaVM" run \
    --exe /bin/bash \
    --username user \
    --password pass123 \
    -- -c "[ -f /tmp/flag ] && echo 'Flag exists' || echo 'Flag missing'"

# Pattern : Chaînage de commandes
VBoxManage guestcontrol "MaVM" run \
    --exe /bin/bash \
    --username user \
    --password pass123 \
    -- -c "cd /opt/app && git pull && npm install && systemctl restart app"

# Pattern : Exécution avec sudo
VBoxManage guestcontrol "MaVM" run \
    --exe /usr/bin/sudo \
    --username user \
    --password pass123 \
    -- systemctl restart nginx
```

### Gestion des Guest Additions obsolètes

```bash
# Vérifier la version des Guest Additions
GUEST_VERSION=$(VBoxManage guestproperty get "MaVM" \
    "/VirtualBox/GuestAdd/Version" 2>/dev/null | awk '{print $2}')
HOST_VERSION=$(VBoxManage --version | cut -d'r' -f1)

if [ "$GUEST_VERSION" != "$HOST_VERSION" ]; then
    echo "⚠️  Versions différentes détectées !"
    echo "Host: $HOST_VERSION"
    echo "Guest: $GUEST_VERSION"
    echo "Mise à jour recommandée des Guest Additions"
fi
```

### Automatisation complète

```bash
#!/bin/bash
# Script complet de gestion de VM

VM_NAME="MaVM"
VM_USER="admin"
VM_PASS_FILE="/secure/.vmpass"

# Fonction utilitaire
vm_exec() {
    VBoxManage guestcontrol "$VM_NAME" run \
        --exe "$1" \
        --username "$VM_USER" \
        --passwordfile "$VM_PASS_FILE" \
        --wait-stdout \
        --wait-stderr \
        "${@:2}"
}

vm_copy_to() {
    VBoxManage guestcontrol "$VM_NAME" copyto \
        "$1" "$2" \
        --username "$VM_USER" \
        --passwordfile "$VM_PASS_FILE"
}

# Utilisation simplifiée
echo "Déploiement de l'application..."
vm_copy_to ./app.tar.gz /tmp/app.tar.gz
vm_exec /bin/tar -- -xzf /tmp/app.tar.gz -C /opt
vm_exec /bin/systemctl -- restart myapp
echo "Déploiement terminé !"
```

---

## 🎯 Pièges courants et solutions

### Problème : Guest Additions non fonctionnelles

> [!warning] Symptôme Les commandes `guestcontrol` échouent avec "Guest Additions not running"

**Solutions :**

```bash
# 1. Vérifier que le service est actif dans le guest
VBoxManage guestproperty get "MaVM" "/VirtualBox/GuestAdd/Version"

# 2. Vérifier les logs dans le guest
# Connectez-vous au guest et exécutez :
sudo systemctl status vboxadd-service
sudo journalctl -u vboxadd-service

# 3. Réinstaller les Guest Additions
# Voir section "Installation des Guest Additions"
```

### Problème : Authentification échoue

> [!warning] Symptôme "Authentication failed" ou "Access denied"

**Solutions :**

```bash
# 1. Vérifier les identifiants
VBoxManage guestcontrol "MaVM" run \
    --exe /bin/whoami \
    --username user \
    --password pass123 \
    --wait-stdout

# 2. Vérifier que l'utilisateur existe dans le guest
# Se connecter au guest et vérifier : id user

# 3. Pour Windows, utiliser le domaine si nécessaire
VBoxManage guestcontrol "WindowsVM" run \
    --exe cmd.exe \
    --username Administrator \
    --password pass \
    --domain WORKGROUP \
    -- /c whoami
```

### Problème : Timeouts fréquents

> [!warning] Symptôme Les commandes se terminent avec "Timeout expired"

**Solutions :**

```bash
# Augmenter le timeout
VBoxManage guestcontrol "MaVM" run \
    --exe /bin/bash \
    --username user \
    --password pass123 \
    --timeout 60000 \
    -- -c "commande_longue"

# Exécuter en arrière-plan pour les tâches très longues
VBoxManage guestcontrol "MaVM" run \
    --exe /bin/nohup \
    --username user \
    --password pass123 \
    -- /usr/bin/long_task.sh
```

### Problème : Permissions insuffisantes

> [!warning] Symptôme "Permission denied" lors de l'exécution de commandes

**Solutions :**

```bash
# 1. Utiliser sudo si l'utilisateur est dans les sudoers
VBoxManage guestcontrol "MaVM" run \
    --exe /usr/bin/sudo \
    --username user \
    --password pass123 \
    -- systemctl restart service

# 2. S'authentifier directement avec root
VBoxManage guestcontrol "MaVM" run \
    --exe /bin/systemctl \
    --username root \
    --password rootpass \
    -- restart service

# 3. Modifier les permissions du fichier/dossier
VBoxManage guestcontrol "MaVM" run \
    --exe /usr/bin/sudo \
    --username user \
    --password pass123 \
    -- chown user:user /opt/app
```

### Problème : Chemins incorrects

> [!warning] Symptôme "No such file or directory" ou "Command not found"

**Solutions :**

```bash
# Toujours utiliser des chemins absolus
# ❌ MAUVAIS
VBoxManage guestcontrol "MaVM" run --exe python3 ...

# ✅ BON
VBoxManage guestcontrol "MaVM" run --exe /usr/bin/python3 ...

# Trouver le chemin complet d'une commande
VBoxManage guestcontrol "MaVM" run \
    --exe /usr/bin/which \
    --username user \
    --password pass123 \
    -- python3
```

---

## 🔍 Résumé des commandes essentielles

### Guest Additions

|Commande|Description|
|---|---|
|`storageattach --medium <iso>`|Monter l'ISO des Guest Additions|
|`guestproperty get <vm> "/VirtualBox/GuestAdd/Version"`|Vérifier la version installée|

### Guest Properties

|Commande|Description|
|---|---|
|`guestproperty get <vm> <clé>`|Lire une propriété|
|`guestproperty set <vm> <clé> <valeur>`|Définir une propriété|
|`guestproperty enumerate <vm>`|Lister toutes les propriétés|
|`guestproperty delete <vm> <clé>`|Supprimer une propriété|
|`guestproperty wait <vm> <clé>`|Attendre un changement|

### Guest Control - Exécution

|Commande|Description|
|---|---|
|`guestcontrol <vm> run --exe <cmd>`|Exécuter une commande|
|`guestcontrol <vm> run --wait-stdout`|Capturer la sortie|
|`guestcontrol <vm> run --timeout <ms>`|Définir un timeout|

### Guest Control - Fichiers

|Commande|Description|
|---|---|
|`guestcontrol <vm> copyto <src> <dst>`|Copier vers le guest|
|`guestcontrol <vm> copyfrom <src> <dst>`|Copier depuis le guest|
|`guestcontrol <vm> copyto --recursive`|Copier un dossier|

### Guest Control - Processus

|Commande|Description|
|---|---|
|`guestcontrol <vm> list processes`|Lister les processus|
|`guestcontrol <vm> session create`|Créer une session|
|`guestcontrol <vm> session close <id>`|Fermer une session|

---

## ✨ Conclusion

Les Guest Additions et le module `guestcontrol` transforment VirtualBox en une plateforme d'automatisation puissante. Avec ces outils, vous pouvez gérer vos VMs de manière programmatique, automatiser les déploiements, surveiller les services et intégrer vos VMs dans des workflows CI/CD complexes.

**Points clés à retenir :**

- Les Guest Additions sont indispensables pour une gestion avancée
- `guestproperty` permet la communication bidirectionnelle hôte-guest
- `guestcontrol` offre un contrôle complet sur l'exécution dans le guest
- Toujours gérer les erreurs et sécuriser les identifiants
- Utiliser des sessions pour optimiser les performances

Avec ces connaissances, vous êtes maintenant équipé pour créer des scripts d'automatisation sophistiqués et gérer efficacement vos environnements virtualisés !