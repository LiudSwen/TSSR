

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

Le monitoring et la collecte de métriques sont essentiels pour surveiller les performances de vos machines virtuelles, diagnostiquer des problèmes et automatiser la gestion de votre infrastructure virtuelle. VirtualBox offre plusieurs outils en ligne de commande pour collecter des données détaillées sur l'état et les performances de vos VMs.

> [!info] Pourquoi monitorer ?
> 
> - **Performance** : Identifier les goulots d'étranglement (CPU, RAM, I/O)
> - **Debugging** : Diagnostiquer les problèmes avant qu'ils deviennent critiques
> - **Automatisation** : Intégrer les données dans des scripts de supervision
> - **Optimisation** : Ajuster les ressources allouées en fonction de l'utilisation réelle

---

## 1. Collecte de métriques avec `metrics`

### Qu'est-ce que la collecte de métriques ?

La commande `metrics` permet de collecter en temps réel des statistiques de performance sur une VM en cours d'exécution. Ces données incluent l'utilisation CPU, mémoire, réseau et disque.

### Syntaxe de base

```bash
# Activer la collecte de métriques
VBoxManage metrics setup

# Lister les métriques disponibles
VBoxManage metrics list

# Collecter des métriques spécifiques
VBoxManage metrics query [VM_name|*] [metric_list]

# Activer la collecte périodique
VBoxManage metrics enable --list [metric_list] [VM_name|*]

# Désactiver la collecte
VBoxManage metrics disable --list [metric_list] [VM_name|*]

# Obtenir des données collectées
VBoxManage metrics collect [VM_name|*]
```

### Métriques disponibles

|Métrique|Description|Unité|
|---|---|---|
|`CPU/Load/User`|Charge CPU en mode utilisateur|%|
|`CPU/Load/Kernel`|Charge CPU en mode noyau|%|
|`RAM/Usage/Used`|Mémoire RAM utilisée|MB|
|`RAM/Usage/Free`|Mémoire RAM libre|MB|
|`Net/Rate/Rx`|Taux de réception réseau|bytes/s|
|`Net/Rate/Tx`|Taux de transmission réseau|bytes/s|
|`Disk/Usage/Used`|Espace disque utilisé|MB|

### Exemples pratiques

```bash
# Lister toutes les métriques disponibles pour toutes les VMs
VBoxManage metrics list

# Activer la collecte CPU et RAM pour une VM spécifique
VBoxManage metrics enable --list "CPU/Load/User,RAM/Usage/Used" "Ubuntu-Server"

# Collecter les métriques actuelles pour toutes les VMs
VBoxManage metrics query "*" "CPU/Load/User,RAM/Usage/Used"

# Collecter avec un intervalle de 5 secondes pendant 30 secondes
VBoxManage metrics collect --period 5 --samples 6 "Ubuntu-Server"

# Désactiver toutes les métriques
VBoxManage metrics disable --list "*" "*"
```

### Exemple de sortie

```bash
$ VBoxManage metrics query "Ubuntu-Server" "CPU/Load/User,RAM/Usage/Used"

Object     Metric                   Value
---------- ------------------------ ----------
Ubuntu-Server CPU/Load/User            23 %
Ubuntu-Server RAM/Usage/Used          1024 MB
```

> [!tip] Astuce : Monitoring automatisé Créez un script qui collecte les métriques toutes les 10 secondes et les enregistre dans un fichier pour analyse :
> 
> ```bash
> #!/bin/bash
> while true; do
>   VBoxManage metrics query "Ubuntu-Server" "*" >> metrics.log
>   sleep 10
> done
> ```

> [!warning] Attention aux performances La collecte de métriques consomme des ressources. Sur des systèmes avec de nombreuses VMs, limitez les métriques collectées ou augmentez l'intervalle de collecte.

### Pièges courants

1. **VM éteinte** : Les métriques ne peuvent être collectées que sur des VMs en cours d'exécution
2. **Métriques désactivées** : Par défaut, la collecte est désactivée. Pensez à activer avec `metrics enable`
3. **Wildcards** : L'utilisation de `*` peut collecter trop de données sur des systèmes chargés

---

## 2. Debugging avec `debugvm`

### Qu'est-ce que `debugvm` ?

`debugvm` est un outil avancé pour obtenir des informations de débogage détaillées sur une VM en cours d'exécution. Il permet d'inspecter l'état interne de la VM, de modifier des paramètres à la volée et de diagnostiquer des problèmes complexes.

### Syntaxe de base

```bash
# Obtenir des informations générales
VBoxManage debugvm [VM_name] info [type]

# Obtenir des statistiques détaillées
VBoxManage debugvm [VM_name] statistics [options]

# Dump de la mémoire
VBoxManage debugvm [VM_name] dumpvmcore --filename=[fichier.elf]

# Obtenir les logs de la VM
VBoxManage debugvm [VM_name] getregisters

# Injecter un NMI (Non-Maskable Interrupt)
VBoxManage debugvm [VM_name] injectnmi
```

### Types d'informations disponibles

```bash
# Informations sur le système d'exploitation invité
VBoxManage debugvm "Ubuntu-Server" info osinfo

# Informations sur la configuration matérielle
VBoxManage debugvm "Ubuntu-Server" info cfgm

# Statistiques sur les devices
VBoxManage debugvm "Ubuntu-Server" info device

# Informations sur les timers
VBoxManage debugvm "Ubuntu-Server" info timers
```

### Statistiques détaillées

```bash
# Obtenir toutes les statistiques
VBoxManage debugvm "Ubuntu-Server" statistics --reset --pattern "*"

# Statistiques CPU uniquement
VBoxManage debugvm "Ubuntu-Server" statistics --pattern "/CPU/*"

# Statistiques réseau
VBoxManage debugvm "Ubuntu-Server" statistics --pattern "/Net/*"

# Réinitialiser les statistiques
VBoxManage debugvm "Ubuntu-Server" statistics --reset
```

### Exemple : Diagnostic d'un freeze

```bash
# 1. Obtenir l'état général de la VM
VBoxManage debugvm "Ubuntu-Server" info osinfo

# 2. Vérifier les statistiques CPU
VBoxManage debugvm "Ubuntu-Server" statistics --pattern "/CPU/Load/*"

# 3. Créer un dump mémoire pour analyse approfondie
VBoxManage debugvm "Ubuntu-Server" dumpvmcore --filename=/tmp/vm-crash.elf

# 4. Injecter un NMI pour forcer un dump de stack
VBoxManage debugvm "Ubuntu-Server" injectnmi
```

> [!example] Cas d'usage : VM qui ne répond plus Lorsqu'une VM semble figée mais est toujours en état "running" :
> 
> 1. Utilisez `debugvm info osinfo` pour vérifier si le guest OS répond
> 2. Examinez les statistiques avec `debugvm statistics --pattern "/EMT/*"` pour voir si les threads d'exécution sont actifs
> 3. Si nécessaire, créez un dump mémoire pour analyse post-mortem

> [!warning] Commandes avancées `debugvm` est un outil puissant qui peut affecter le fonctionnement de la VM. Utilisez-le avec précaution, particulièrement en production. Certaines commandes comme `injectnmi` peuvent provoquer un crash du système invité.

### Pièges courants

1. **Permissions insuffisantes** : Certaines commandes nécessitent des privilèges administrateur
2. **VM éteinte** : La plupart des commandes `debugvm` requièrent une VM en cours d'exécution
3. **Taille des dumps** : Les dumps mémoire peuvent être très volumineux (taille = RAM allouée)

---

## 3. Logs VirtualBox

### Où trouver les logs ?

VirtualBox génère automatiquement des fichiers de log pour chaque VM. Ces logs sont essentiels pour diagnostiquer des problèmes de démarrage, de performance ou de configuration.

### Emplacements des logs

|Système|Emplacement par défaut|
|---|---|
|**Linux**|`~/.VirtualBox/Machines/[VM_name]/Logs/`|
|**macOS**|`~/Library/VirtualBox/Machines/[VM_name]/Logs/`|
|**Windows**|`%USERPROFILE%\.VirtualBox\Machines\[VM_name]\Logs\`|

### Structure des fichiers de log

```bash
# Exemple de structure dans le dossier Logs/
VBox.log          # Log actuel de la VM
VBox.log.1        # Log de la session précédente
VBox.log.2        # Log de l'avant-dernière session
VBoxHardening.log # Logs de sécurité (si activés)
```

### Commandes pour accéder aux logs

```bash
# Afficher le chemin du dossier de logs d'une VM
VBoxManage showvminfo "Ubuntu-Server" | grep "Log folder"

# Lire directement le log actuel (Linux/macOS)
cat ~/.VirtualBox/Machines/Ubuntu-Server/Logs/VBox.log

# Suivre le log en temps réel
tail -f ~/.VirtualBox/Machines/Ubuntu-Server/Logs/VBox.log

# Rechercher des erreurs dans les logs
grep -i "error\|warning\|fail" ~/.VirtualBox/Machines/Ubuntu-Server/Logs/VBox.log
```

### Configuration du niveau de log

```bash
# Activer le logging détaillé (niveau Debug)
VBoxManage modifyvm "Ubuntu-Server" --uartmode1 file /tmp/vm-uart.log

# Modifier le niveau de log via variable d'environnement
export VBOX_LOG=+all.e.l.f
export VBOX_LOG_DEST=file=/tmp/vbox-debug.log
export VBOX_LOG_FLAGS=time

# Relancer la VM avec ces paramètres
VBoxManage startvm "Ubuntu-Server"
```

### Niveaux de logging

|Variable|Description|
|---|---|
|`VBOX_LOG`|Définit quels composants logger et à quel niveau|
|`VBOX_LOG_DEST`|Destination des logs (file, stdout, etc.)|
|`VBOX_LOG_FLAGS`|Options de formatage (time, thread, etc.)|

### Exemple de configuration avancée

```bash
# Logger uniquement les erreurs du réseau et du disque
export VBOX_LOG="+net.e+disk.e"

# Logger tout en mode debug dans un fichier horodaté
export VBOX_LOG="+all"
export VBOX_LOG_DEST="file=/tmp/vbox-$(date +%Y%m%d-%H%M%S).log"
export VBOX_LOG_FLAGS="time thread"
```

### Analyser les logs

```bash
# Identifier les problèmes de démarrage
grep "rc=" ~/.VirtualBox/Machines/Ubuntu-Server/Logs/VBox.log

# Trouver les erreurs de devices
grep "DevPCI\|DevATA\|DevE1000" ~/.VirtualBox/Machines/Ubuntu-Server/Logs/VBox.log

# Analyser les performances réseau
grep "NAT\|Rate" ~/.VirtualBox/Machines/Ubuntu-Server/Logs/VBox.log

# Vérifier les Guest Additions
grep "Guest Additions" ~/.VirtualBox/Machines/Ubuntu-Server/Logs/VBox.log
```

> [!tip] Rotation automatique des logs VirtualBox conserve automatiquement les 3 derniers fichiers de log. Pour une rotation plus agressive :
> 
> ```bash
> # Script de nettoyage des anciens logs
> find ~/.VirtualBox/Machines/*/Logs/ -name "VBox.log.*" -mtime +7 -delete
> ```

> [!info] Logs et confidentialité Les logs peuvent contenir des informations sensibles (chemins, noms d'utilisateurs). Pensez à anonymiser les logs avant de les partager pour du support.

### Pièges courants

1. **Logs trop volumineux** : En mode debug, les logs peuvent croître rapidement (plusieurs GB)
2. **Permissions** : Vérifiez que l'utilisateur a accès en lecture au dossier des logs
3. **Rotation non gérée** : Par défaut, seuls 3 logs sont conservés, les plus anciens sont écrasés

---

## 4. Format parsable avec `showvminfo --machinereadable`

### Pourquoi utiliser `--machinereadable` ?

Par défaut, `VBoxManage showvminfo` retourne des informations dans un format lisible par l'humain. L'option `--machinereadable` transforme la sortie en format clé-valeur facilement parsable par des scripts.

### Syntaxe

```bash
# Format lisible par l'humain (défaut)
VBoxManage showvminfo "Ubuntu-Server"

# Format parsable par machine
VBoxManage showvminfo "Ubuntu-Server" --machinereadable

# Combiner avec des filtres
VBoxManage showvminfo "Ubuntu-Server" --machinereadable | grep "memory"
```

### Différence de format

**Format standard :**

```
Name:            Ubuntu-Server
Memory size:     2048MB
State:           running
```

**Format `--machinereadable` :**

```
name="Ubuntu-Server"
memory=2048
VMState="running"
```

### Extraction de valeurs spécifiques

```bash
# Récupérer la mémoire allouée
VBoxManage showvminfo "Ubuntu-Server" --machinereadable | grep "^memory=" | cut -d'=' -f2

# Récupérer l'état de la VM
VBoxManage showvminfo "Ubuntu-Server" --machinereadable | grep "^VMState=" | cut -d'=' -f2 | tr -d '"'

# Récupérer l'adresse MAC
VBoxManage showvminfo "Ubuntu-Server" --machinereadable | grep "^macaddress1="

# Lister tous les disques attachés
VBoxManage showvminfo "Ubuntu-Server" --machinereadable | grep "^\".*-ImageUUID"
```

### Script d'exemple : Monitoring automatisé

```bash
#!/bin/bash
# Script pour surveiller plusieurs VMs

VMS=("Ubuntu-Server" "Windows-10" "Debian-Test")

for vm in "${VMS[@]}"; do
  echo "=== $vm ==="
  
  # État de la VM
  state=$(VBoxManage showvminfo "$vm" --machinereadable | grep "^VMState=" | cut -d'=' -f2 | tr -d '"')
  echo "État: $state"
  
  # Mémoire
  memory=$(VBoxManage showvminfo "$vm" --machinereadable | grep "^memory=" | cut -d'=' -f2)
  echo "Mémoire: ${memory}MB"
  
  # CPUs
  cpus=$(VBoxManage showvminfo "$vm" --machinereadable | grep "^cpus=" | cut -d'=' -f2)
  echo "CPUs: $cpus"
  
  echo ""
done
```

### Parsing JSON pour intégration moderne

```bash
# Convertir la sortie en JSON pour manipulation avec jq
VBoxManage showvminfo "Ubuntu-Server" --machinereadable | \
  awk -F'=' '{gsub(/"/, "", $2); print "\"" $1 "\":" "\"" $2 "\""}' | \
  sed '1s/^/{/; $s/$/}/; s/$/,/; $s/,$//' | \
  jq '.'

# Exemple de script Python pour parser les données
cat << 'EOF' > parse_vm.py
#!/usr/bin/env python3
import subprocess
import json

def get_vm_info(vm_name):
    result = subprocess.run(
        ['VBoxManage', 'showvminfo', vm_name, '--machinereadable'],
        capture_output=True,
        text=True
    )
    
    info = {}
    for line in result.stdout.split('\n'):
        if '=' in line:
            key, value = line.split('=', 1)
            info[key] = value.strip('"')
    
    return info

# Utilisation
vm_info = get_vm_info('Ubuntu-Server')
print(json.dumps(vm_info, indent=2))
EOF

chmod +x parse_vm.py
./parse_vm.py
```

### Champs utiles en `--machinereadable`

|Champ|Description|Exemple|
|---|---|---|
|`name`|Nom de la VM|`"Ubuntu-Server"`|
|`VMState`|État actuel|`"running"`, `"poweroff"`|
|`memory`|RAM en MB|`2048`|
|`cpus`|Nombre de CPUs|`2`|
|`ostype`|Type d'OS|`"Ubuntu_64"`|
|`macaddress1`|MAC du NIC 1|`"080027123456"`|
|`storagecontroller...`|Contrôleurs de stockage|Divers|

### Automatisation avec Bash

```bash
#!/bin/bash
# Génération de rapport HTML de toutes les VMs

OUTPUT="vm_report.html"

cat > "$OUTPUT" << 'HTML'
<!DOCTYPE html>
<html>
<head><title>VirtualBox VMs Report</title></head>
<body>
<h1>VirtualBox Machines Report</h1>
<table border="1">
<tr><th>Name</th><th>State</th><th>Memory</th><th>CPUs</th></tr>
HTML

VBoxManage list vms | while read line; do
  vm_name=$(echo "$line" | cut -d'"' -f2)
  
  info=$(VBoxManage showvminfo "$vm_name" --machinereadable)
  state=$(echo "$info" | grep "^VMState=" | cut -d'=' -f2 | tr -d '"')
  memory=$(echo "$info" | grep "^memory=" | cut -d'=' -f2)
  cpus=$(echo "$info" | grep "^cpus=" | cut -d'=' -f2)
  
  echo "<tr><td>$vm_name</td><td>$state</td><td>${memory}MB</td><td>$cpus</td></tr>" >> "$OUTPUT"
done

echo "</table></body></html>" >> "$OUTPUT"
echo "Rapport généré: $OUTPUT"
```

> [!tip] Intégration avec outils de monitoring Utilisez `--machinereadable` pour alimenter des outils comme :
> 
> - **Prometheus** : Exporter des métriques via un exporter custom
> - **Grafana** : Créer des dashboards de monitoring
> - **Nagios/Zabbix** : Scripts de vérification personnalisés
> - **ELK Stack** : Indexation des données pour analyse

> [!example] Exemple : Détection de VMs en erreur
> 
> ```bash
> #!/bin/bash
> # Alerter si une VM est dans un état anormal
> 
> for vm in $(VBoxManage list vms | cut -d'"' -f2); do
>   state=$(VBoxManage showvminfo "$vm" --machinereadable | grep "^VMState=" | cut -d'=' -f2 | tr -d '"')
>   
>   if [[ "$state" == "aborted" || "$state" == "guru meditation" ]]; then
>     echo "ALERTE: $vm est en état: $state"
>     # Envoyer une notification, email, etc.
>   fi
> done
> ```

### Pièges courants

1. **Guillemets dans les valeurs** : Pensez à utiliser `tr -d '"'` pour nettoyer les valeurs
2. **Espaces dans les noms** : Toujours entourer les noms de VM de guillemets
3. **Changement de format** : Le format peut évoluer entre versions de VirtualBox, validez vos scripts après mise à jour
4. **Encodage** : Certaines valeurs peuvent contenir des caractères spéciaux, utilisez UTF-8

---

## 🎯 Bonnes pratiques générales

### Monitoring en production

1. **Collecte périodique** : Mettez en place une collecte automatique toutes les 5-10 minutes
2. **Rétention des données** : Conservez au moins 7 jours d'historique
3. **Alerting** : Définissez des seuils (CPU > 80%, RAM > 90%) pour déclencher des alertes
4. **Rotation des logs** : Implémentez une rotation pour éviter la saturation disque

### Script de monitoring complet

```bash
#!/bin/bash
# Script complet de monitoring VirtualBox

LOG_DIR="/var/log/vbox-monitoring"
TIMESTAMP=$(date +%Y%m%d-%H%M%S)

mkdir -p "$LOG_DIR"

# 1. Collecter les métriques de toutes les VMs en cours d'exécution
VBoxManage list runningvms | while read vm; do
  vm_name=$(echo "$vm" | cut -d'"' -f2)
  
  # Métriques système
  VBoxManage metrics query "$vm_name" "*" > "$LOG_DIR/${vm_name}_metrics_$TIMESTAMP.log"
  
  # Informations parsables
  VBoxManage showvminfo "$vm_name" --machinereadable > "$LOG_DIR/${vm_name}_info_$TIMESTAMP.txt"
  
  # Statistiques de debug
  VBoxManage debugvm "$vm_name" statistics --pattern "*" > "$LOG_DIR/${vm_name}_stats_$TIMESTAMP.log" 2>&1
done

# 2. Copier les logs récents
find ~/.VirtualBox/Machines/*/Logs/VBox.log -mtime -1 -exec cp {} "$LOG_DIR/" \;

# 3. Générer un résumé
echo "=== Monitoring Report $TIMESTAMP ===" > "$LOG_DIR/summary_$TIMESTAMP.txt"
VBoxManage list runningvms >> "$LOG_DIR/summary_$TIMESTAMP.txt"

# 4. Nettoyage des anciens logs (> 7 jours)
find "$LOG_DIR" -type f -mtime +7 -delete

echo "Monitoring effectué: $LOG_DIR"
```

### Intégration systemd (Linux)

```ini
# /etc/systemd/system/vbox-monitoring.service
[Unit]
Description=VirtualBox Monitoring Service
After=vboxdrv.service

[Service]
Type=oneshot
User=votre_utilisateur
ExecStart=/usr/local/bin/vbox-monitor.sh

[Install]
WantedBy=multi-user.target
```

```ini
# /etc/systemd/system/vbox-monitoring.timer
[Unit]
Description=Run VirtualBox Monitoring every 10 minutes

[Timer]
OnBootSec=5min
OnUnitActiveSec=10min

[Install]
WantedBy=timers.target
```

```bash
# Activer le monitoring automatique
sudo systemctl enable vbox-monitoring.timer
sudo systemctl start vbox-monitoring.timer
```

---

## 📝 Résumé des commandes essentielles

```bash
# Métriques
VBoxManage metrics list                    # Lister les métriques disponibles
VBoxManage metrics enable --list "*" "*"   # Activer toutes les métriques
VBoxManage metrics query "*" "*"           # Collecter les métriques actuelles

# Debug
VBoxManage debugvm [VM] info osinfo        # Infos système invité
VBoxManage debugvm [VM] statistics         # Statistiques détaillées
VBoxManage debugvm [VM] dumpvmcore         # Créer un dump mémoire

# Logs
tail -f ~/.VirtualBox/Machines/[VM]/Logs/VBox.log  # Suivre le log en temps réel
grep -i error [chemin_log]                         # Rechercher les erreurs

# Format parsable
VBoxManage showvminfo [VM] --machinereadable       # Sortie structurée
VBoxManage showvminfo [VM] --machinereadable | grep "^memory="  # Extraction spécifique
```

---

> [!success] Vous maîtrisez maintenant
> 
> - La collecte de métriques en temps réel avec `metrics`
> - Le debugging avancé avec `debugvm` et les dumps mémoire
> - La localisation et l'analyse des logs VirtualBox
> - L'extraction de données structurées avec `--machinereadable`
> - L'intégration de ces outils dans des scripts de monitoring automatisé