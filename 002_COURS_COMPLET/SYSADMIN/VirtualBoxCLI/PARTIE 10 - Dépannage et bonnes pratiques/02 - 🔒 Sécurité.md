# 

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

La sécurité des machines virtuelles est cruciale, que vous les utilisiez pour tester des applications potentiellement dangereuses, héberger des environnements de production, ou simplement protéger vos données personnelles. VirtualBox offre plusieurs mécanismes de sécurité configurables via CLI pour isoler, protéger et sécuriser vos VMs.

> [!info] Pourquoi la sécurité des VMs est importante Même si les VMs sont isolées par nature, des configurations inadéquates peuvent exposer votre système hôte à des risques : accès réseau non contrôlé, partage de dossiers mal sécurisé, ou absence de chiffrement des données sensibles.

---

## Isolation des VMs

### Concept d'isolation

L'isolation permet de limiter les interactions entre les VMs et le système hôte, ainsi qu'entre les VMs elles-mêmes. C'est la première ligne de défense contre les menaces.

### Types d'isolation réseau

VirtualBox propose plusieurs modes réseau avec différents niveaux d'isolation :

|Mode réseau|Isolation VM↔Hôte|Isolation VM↔VM|Internet|Usage recommandé|
|---|---|---|---|---|
|NAT|✅ Haute|✅ Complète|✅ Oui|VM isolée avec accès web|
|Réseau NAT|✅ Moyenne|❌ Non|✅ Oui|Groupe de VMs communicantes|
|Réseau interne|✅ Complète|❌ Non|❌ Non|Lab isolé sans Internet|
|Host-only|⚠️ Faible|❌ Non|❌ Non|Dev local avec accès hôte|
|Bridge|❌ Aucune|❌ Non|✅ Oui|VM comme machine physique|

#### Configuration du mode réseau

```bash
# Configurer une VM en mode NAT (isolation maximale)
VBoxManage modifyvm "MaVM" --nic1 nat

# Créer un réseau NAT isolé pour plusieurs VMs
VBoxManage natnetwork add --netname "IsolatedNet" \
    --network "10.0.100.0/24" \
    --enable

# Connecter une VM au réseau NAT
VBoxManage modifyvm "MaVM" --nic1 natnetwork \
    --nat-network1 "IsolatedNet"

# Configurer un réseau interne (isolation complète)
VBoxManage modifyvm "MaVM" --nic1 intnet \
    --intnet1 "SecureNet"

# Désactiver complètement le réseau
VBoxManage modifyvm "MaVM" --nic1 none
```

> [!warning] Attention au mode Bridge Le mode Bridge expose votre VM directement sur le réseau physique. Utilisez-le uniquement si vous maîtrisez les implications de sécurité et que la VM est correctement sécurisée (firewall, mises à jour, etc.).

### Isolation des dossiers partagés

Les dossiers partagés peuvent être un vecteur d'attaque si mal configurés.

```bash
# Créer un dossier partagé en lecture seule
VBoxManage sharedfolder add "MaVM" \
    --name "SharedDocs" \
    --hostpath "/home/user/documents" \
    --readonly

# Créer un dossier partagé avec montage automatique
VBoxManage sharedfolder add "MaVM" \
    --name "Transfer" \
    --hostpath "/tmp/vm-transfer" \
    --automount

# Lister les dossiers partagés
VBoxManage showvminfo "MaVM" | grep "Shared folders"

# Supprimer un dossier partagé
VBoxManage sharedfolder remove "MaVM" --name "SharedDocs"
```

> [!tip] Astuce : Principe du moindre privilège Ne partagez que les dossiers strictement nécessaires, en lecture seule quand possible. Évitez de partager des répertoires système ou contenant des données sensibles.

### Isolation du clipboard et du drag-and-drop

```bash
# Désactiver complètement le presse-papiers partagé
VBoxManage modifyvm "MaVM" --clipboard-mode disabled

# Activer uniquement Host vers VM
VBoxManage modifyvm "MaVM" --clipboard-mode hosttoguest

# Activer uniquement VM vers Host
VBoxManage modifyvm "MaVM" --clipboard-mode guesttohost

# Mode bidirectionnel (moins sécurisé)
VBoxManage modifyvm "MaVM" --clipboard-mode bidirectional

# Désactiver le drag-and-drop
VBoxManage modifyvm "MaVM" --draganddrop disabled
```

> [!example] Exemple : VM pour malware analysis
> 
> ```bash
> # Configuration d'isolation maximale pour analyser des fichiers suspects
> VBoxManage modifyvm "AnalysisVM" --nic1 none
> VBoxManage modifyvm "AnalysisVM" --clipboard-mode disabled
> VBoxManage modifyvm "AnalysisVM" --draganddrop disabled
> VBoxManage modifyvm "AnalysisVM" --usb off
> # Retirer tous les dossiers partagés
> VBoxManage sharedfolder remove "AnalysisVM" --name "Shared" 2>/dev/null
> ```

---

## Gestion des accès

### Protection de l'accès aux VMs

#### Verrouillage de la configuration VM

```bash
# Empêcher les modifications de configuration pendant l'exécution
VBoxManage setextradata "MaVM" "GUI/PreventReconfiguration" 1

# Afficher les données extra
VBoxManage getextradata "MaVM" enumerate
```

#### Contrôle d'accès au niveau du système

Les VMs sont stockées sous forme de fichiers. Utilisez les permissions du système de fichiers pour contrôler l'accès.

```bash
# Rendre le répertoire de la VM accessible uniquement au propriétaire
chmod 700 ~/VirtualBox\ VMs/MaVM/

# Vérifier les permissions
ls -la ~/VirtualBox\ VMs/MaVM/

# Définir le propriétaire (si nécessaire)
sudo chown -R $USER:$USER ~/VirtualBox\ VMs/MaVM/
```

> [!warning] Pièges courants
> 
> - Ne stockez jamais de VMs sur des partitions accessibles par d'autres utilisateurs sans protection
> - Les fichiers .vbox contiennent des informations de configuration sensibles
> - Les fichiers .vdi sont les disques virtuels et peuvent contenir toutes vos données

### Gestion des ports série et parallèles

Ces ports peuvent être des vecteurs d'attaque ou de fuite de données.

```bash
# Désactiver le port série
VBoxManage modifyvm "MaVM" --uart1 off

# Configurer un port série sécurisé (pipe nommé)
VBoxManage modifyvm "MaVM" --uart1 0x3F8 4 \
    --uartmode1 file /tmp/vm-serial.log

# Désactiver le port parallèle
VBoxManage modifyvm "MaVM" --lpt1 off
```

### Protection VRDE (Remote Display)

Si vous utilisez l'accès distant, sécurisez-le correctement.

```bash
# Activer VRDE avec authentification
VBoxManage modifyvm "MaVM" --vrde on
VBoxManage modifyvm "MaVM" --vrdeport 5900
VBoxManage modifyvm "MaVM" --vrdeauthtype external

# Définir un port spécifique (au lieu de l'auto)
VBoxManage modifyvm "MaVM" --vrdeport 5901

# Limiter l'accès à une interface spécifique
VBoxManage modifyvm "MaVM" --vrdeaddress 127.0.0.1

# Désactiver VRDE si non utilisé
VBoxManage modifyvm "MaVM" --vrde off
```

> [!tip] Astuce : Sécurisation VRDE Si vous devez utiliser VRDE sur un réseau non sécurisé, utilisez un tunnel SSH :
> 
> ```bash
> ssh -L 5901:localhost:5901 user@remote-host
> # Puis connectez-vous à localhost:5901 depuis votre client RDP
> ```

---

## Encryption de disques

### Pourquoi chiffrer les disques virtuels

Le chiffrement protège vos données au repos. Sans chiffrement, n'importe qui ayant accès au fichier .vdi peut monter le disque et lire son contenu.

> [!info] Cas d'usage du chiffrement
> 
> - VMs contenant des données sensibles (mots de passe, clés privées, données personnelles)
> - Ordinateurs portables susceptibles d'être volés
> - VMs stockées sur des supports amovibles
> - Environnements multi-utilisateurs

### Activer le chiffrement sur un disque existant

```bash
# Activer le chiffrement AES-XTS256 avec mot de passe
VBoxManage encryptmedium "~/VirtualBox VMs/MaVM/MaVM.vdi" \
    --newpassword "VotreMotDePasseSécurisé" \
    --cipher "AES-XTS256-PLAIN64" \
    --newpasswordid "MainPassword"

# Vérifier l'état du chiffrement
VBoxManage showmediuminfo "~/VirtualBox VMs/MaVM/MaVM.vdi"
```

> [!warning] Attention : Opération irréversible Le chiffrement modifie le disque en place. Assurez-vous d'avoir une sauvegarde avant de procéder. Si vous perdez le mot de passe, vos données seront définitivement inaccessibles.

### Créer un nouveau disque chiffré

```bash
# Créer un disque VDI chiffré dès le départ
VBoxManage createmedium disk \
    --filename "~/VirtualBox VMs/SecureVM/SecureVM.vdi" \
    --size 20480 \
    --format VDI \
    --variant Standard

# Chiffrer immédiatement
VBoxManage encryptmedium "~/VirtualBox VMs/SecureVM/SecureVM.vdi" \
    --newpassword "MotDePasseFort123!" \
    --cipher "AES-XTS256-PLAIN64" \
    --newpasswordid "SecurePassword"

# Attacher le disque chiffré à une VM
VBoxManage storageattach "SecureVM" \
    --storagectl "SATA" \
    --port 0 \
    --device 0 \
    --type hdd \
    --medium "~/VirtualBox VMs/SecureVM/SecureVM.vdi"
```

### Gestion des mots de passe de chiffrement

```bash
# Changer le mot de passe d'un disque chiffré
VBoxManage encryptmedium "~/VirtualBox VMs/MaVM/MaVM.vdi" \
    --oldpassword "AncienMotDePasse" \
    --newpassword "NouveauMotDePasse" \
    --cipher "AES-XTS256-PLAIN64" \
    --newpasswordid "MainPassword"

# Fournir le mot de passe au démarrage (mode interactif)
VBoxManage startvm "MaVM"
# VirtualBox demandera le mot de passe via une interface graphique

# Fournir le mot de passe via CLI (moins sécurisé)
VBoxManage startvm "MaVM" --type headless
# Puis dans une autre session :
VBoxManage controlvm "MaVM" addencpassword "MainPassword" "VotreMotDePasse" --removeonsuspend yes
```

> [!warning] Sécurité du mot de passe en CLI Évitez de passer le mot de passe directement en ligne de commande car il sera visible dans l'historique bash et dans la liste des processus. Utilisez plutôt des variables d'environnement ou des fichiers temporaires sécurisés.

### Algorithmes de chiffrement disponibles

```bash
# AES-XTS128-PLAIN64 (128 bits - rapide)
VBoxManage encryptmedium "disk.vdi" \
    --newpassword "pwd" \
    --cipher "AES-XTS128-PLAIN64"

# AES-XTS256-PLAIN64 (256 bits - recommandé)
VBoxManage encryptmedium "disk.vdi" \
    --newpassword "pwd" \
    --cipher "AES-XTS256-PLAIN64"
```

|Algorithme|Longueur clé|Performance|Sécurité|Usage recommandé|
|---|---|---|---|---|
|AES-XTS128-PLAIN64|128 bits|Rapide|Bonne|Usage général|
|AES-XTS256-PLAIN64|256 bits|Moyenne|Excellente|Données très sensibles|

> [!tip] Astuce : Performance vs Sécurité Pour la plupart des usages, AES-XTS256-PLAIN64 offre le meilleur compromis. La différence de performance est négligeable sur du matériel moderne, et la sécurité supplémentaire vaut largement ce coût minimal.

### Déchiffrer un disque

```bash
# Retirer complètement le chiffrement (déchiffrer)
VBoxManage encryptmedium "~/VirtualBox VMs/MaVM/MaVM.vdi" \
    --oldpassword "MotDePasseActuel"

# Le disque redevient non chiffré
```

---

## Snapshots et points de restauration

### Concept des snapshots

Les snapshots capturent l'état complet d'une VM à un instant donné : disque, mémoire RAM, et configuration. Ils sont essentiels pour la sécurité car ils permettent de revenir en arrière après une infection, une erreur de configuration, ou un test risqué.

> [!info] Snapshots vs Backups
> 
> - **Snapshots** : Points de restauration rapides, stockés avec la VM, dépendants du disque parent
> - **Backups** : Copies complètes indépendantes, stockées séparément, protection contre la perte matérielle

### Créer un snapshot

```bash
# Créer un snapshot avec description
VBoxManage snapshot "MaVM" take "BeforeUpdate" \
    --description "État avant mise à jour système" \
    --live

# Snapshot sans la mémoire RAM (plus rapide, VM éteinte)
VBoxManage snapshot "MaVM" take "CleanState"

# Snapshot avec pause de la VM
VBoxManage snapshot "MaVM" take "TestPoint" --pause
```

> [!tip] Option --live L'option `--live` crée un snapshot pendant que la VM tourne, sans l'arrêter. Très utile pour les serveurs en production, mais génère des fichiers plus volumineux (inclut la RAM).

### Lister les snapshots

```bash
# Voir tous les snapshots d'une VM
VBoxManage snapshot "MaVM" list

# Afficher l'arbre des snapshots
VBoxManage snapshot "MaVM" list --details

# Voir les informations détaillées d'un snapshot
VBoxManage showvminfo "MaVM" | grep -A 10 "Snapshots"
```

### Restaurer un snapshot

```bash
# Restaurer un snapshot spécifique
VBoxManage snapshot "MaVM" restore "BeforeUpdate"

# Restaurer le snapshot le plus récent
VBoxManage snapshot "MaVM" restorecurrent

# Restaurer et créer un nouveau snapshot de l'état actuel
VBoxManage snapshot "MaVM" restore "CleanState" --take-new-snapshot
```

> [!warning] Perte de l'état actuel Restaurer un snapshot écrase l'état actuel de la VM. Les modifications apportées depuis le snapshot seront perdues, sauf si vous utilisez `--take-new-snapshot` pour les préserver.

### Supprimer des snapshots

```bash
# Supprimer un snapshot spécifique (fusion avec parent)
VBoxManage snapshot "MaVM" delete "OldSnapshot"

# Supprimer tous les snapshots
VBoxManage snapshot "MaVM" deleteall

# Supprimer et conserver les différences
VBoxManage snapshot "MaVM" delete "Snapshot1" --keep-disk-names
```

### Stratégies de snapshots pour la sécurité

#### Snapshot avant actions risquées

```bash
#!/bin/bash
# Script pour automatiser un snapshot avant une action risquée

VM_NAME="TestVM"
SNAPSHOT_NAME="Before_$(date +%Y%m%d_%H%M%S)"

echo "Création du snapshot de sécurité..."
VBoxManage snapshot "$VM_NAME" take "$SNAPSHOT_NAME" \
    --description "Snapshot automatique avant opération"

# Exécuter l'action risquée
echo "Exécution de l'action..."
# ... votre commande ici ...

# Option : supprimer le snapshot si tout s'est bien passé
read -p "Tout s'est bien passé ? Supprimer le snapshot ? (o/N) " reponse
if [ "$reponse" = "o" ]; then
    VBoxManage snapshot "$VM_NAME" delete "$SNAPSHOT_NAME"
    echo "Snapshot supprimé."
else
    echo "Snapshot conservé : $SNAPSHOT_NAME"
fi
```

#### Snapshots périodiques automatiques

```bash
#!/bin/bash
# Script de snapshot quotidien (à ajouter dans cron)

VM_NAME="ProdVM"
MAX_SNAPSHOTS=7  # Garder 7 jours d'historique
SNAPSHOT_PREFIX="Daily"

# Créer un nouveau snapshot
SNAPSHOT_NAME="${SNAPSHOT_PREFIX}_$(date +%Y%m%d)"
VBoxManage snapshot "$VM_NAME" take "$SNAPSHOT_NAME" \
    --description "Snapshot automatique quotidien"

# Supprimer les snapshots trop anciens
VBoxManage snapshot "$VM_NAME" list | grep "$SNAPSHOT_PREFIX" | \
    head -n -$MAX_SNAPSHOTS | while read -r line; do
    SNAP_TO_DELETE=$(echo "$line" | awk '{print $2}')
    VBoxManage snapshot "$VM_NAME" delete "$SNAP_TO_DELETE"
done
```

> [!example] Configuration cron
> 
> ```bash
> # Ajouter dans crontab (crontab -e)
> 0 2 * * * /home/user/scripts/daily-snapshot.sh >> /var/log/vm-snapshots.log 2>&1
> # Exécute tous les jours à 2h du matin
> ```

### Gestion de l'espace disque

Les snapshots consomment de l'espace disque proportionnel aux modifications effectuées.

```bash
# Voir la taille des snapshots
VBoxManage showvminfo "MaVM" | grep -i "snapshot"

# Voir l'espace utilisé par tous les disques et snapshots
du -sh ~/VirtualBox\ VMs/MaVM/

# Fusionner les snapshots pour récupérer de l'espace
VBoxManage snapshot "MaVM" delete "OldSnapshot1"
VBoxManage snapshot "MaVM" delete "OldSnapshot2"
```

> [!warning] Attention à la consommation d'espace
> 
> - Chaque snapshot crée un fichier différentiel (.vdi)
> - Plus vous gardez de snapshots, plus l'espace disque augmente
> - Les snapshots "live" incluent aussi la mémoire RAM
> - Nettoyez régulièrement les snapshots obsolètes

---

## Hardening des VMs

Le hardening consiste à réduire la surface d'attaque en désactivant les fonctionnalités inutiles et en appliquant des configurations sécurisées.

### Désactivation des périphériques inutiles

#### USB

```bash
# Désactiver complètement l'USB
VBoxManage modifyvm "MaVM" --usb off

# Activer uniquement USB 1.1 (moins de risques)
VBoxManage modifyvm "MaVM" --usb on
VBoxManage modifyvm "MaVM" --usbehci off  # Désactiver USB 2.0
VBoxManage modifyvm "MaVM" --usbxhci off  # Désactiver USB 3.0

# Lister les périphériques USB connectés
VBoxManage list usbhost

# Créer un filtre USB spécifique (whitelist)
VBoxManage usbfilter add 0 \
    --target "MaVM" \
    --name "MyKeyboard" \
    --vendorid "046d" \
    --productid "c52b"
```

> [!tip] Principe de moindre privilège N'activez l'USB que si absolument nécessaire. Pour les serveurs ou VMs d'analyse, désactivez-le complètement.

#### Audio

```bash
# Désactiver l'audio
VBoxManage modifyvm "MaVM" --audio none

# Activer l'audio en mode minimal (si nécessaire)
VBoxManage modifyvm "MaVM" --audio pulse --audiocontroller hda
```

#### Webcam

```bash
# Désactiver la webcam
VBoxManage modifyvm "MaVM" --webcam off

# Vérifier l'état
VBoxManage showvminfo "MaVM" | grep -i webcam
```

### Configuration sécurisée du firmware

```bash
# Utiliser EFI au lieu du BIOS (plus moderne et sécurisé)
VBoxManage modifyvm "MaVM" --firmware efi

# Activer Secure Boot (si supporté par le guest OS)
VBoxManage setextradata "MaVM" "VBoxInternal/Devices/efi/0/Config/SecureBoot" 1

# Désactiver le boot depuis disquette
VBoxManage modifyvm "MaVM" --boot1 dvd --boot2 disk --boot3 none --boot4 none
```

### Limiter les ressources matérielles

Limiter les ressources empêche une VM compromise de monopoliser le système hôte.

```bash
# Limiter l'utilisation CPU à 75%
VBoxManage modifyvm "MaVM" --cpuexecutioncap 75

# Limiter la RAM (exemple : 2 Go)
VBoxManage modifyvm "MaVM" --memory 2048

# Limiter le nombre de CPUs
VBoxManage modifyvm "MaVM" --cpus 2

# Limiter la bande passante réseau (en Ko/s)
VBoxManage bandwidthctl "MaVM" add "Limit" --type network --limit 1024
VBoxManage modifyvm "MaVM" --nicbandwidthgroup1 "Limit"
```

### Configuration de sécurité avancée

#### Protection PAE/NX

```bash
# Activer PAE (Physical Address Extension) et NX (No eXecute)
VBoxManage modifyvm "MaVM" --pae on
VBoxManage modifyvm "MaVM" --longmode on  # Active AMD64/Intel64

# Activer les fonctionnalités de virtualisation nested
VBoxManage modifyvm "MaVM" --nested-hw-virt on
```

#### Page fusion (KSM - Kernel Same-page Merging)

```bash
# Désactiver la fusion de pages (évite les attaques par canaux cachés)
VBoxManage modifyvm "MaVM" --pagefusion off
```

> [!warning] Attaques par canaux cachés La fusion de pages (KSM) peut théoriquement permettre à une VM d'extraire des informations d'une autre VM via des attaques temporelles. Désactivez-la pour les environnements hautement sécurisés.

#### Randomisation de l'adresse MAC

```bash
# Générer une nouvelle adresse MAC aléatoire
VBoxManage modifyvm "MaVM" --macaddress1 auto

# Définir une MAC spécifique (format sans séparateurs)
VBoxManage modifyvm "MaVM" --macaddress1 080027123456
```

### Checklist de hardening complète

> [!example] Template de VM sécurisée
> 
> ```bash
> #!/bin/bash
> # Script de hardening pour nouvelle VM
> 
> VM_NAME="SecureVM"
> 
> echo "Application du hardening sur $VM_NAME..."
> 
> # Réseau : isolation maximale
> VBoxManage modifyvm "$VM_NAME" --nic1 nat
> 
> # Désactiver les fonctionnalités non essentielles
> VBoxManage modifyvm "$VM_NAME" --audio none
> VBoxManage modifyvm "$VM_NAME" --usb off
> VBoxManage modifyvm "$VM_NAME" --webcam off
> VBoxManage modifyvm "$VM_NAME" --clipboard-mode disabled
> VBoxManage modifyvm "$VM_NAME" --draganddrop disabled
> 
> # Désactiver les ports série et parallèle
> VBoxManage modifyvm "$VM_NAME" --uart1 off
> VBoxManage modifyvm "$VM_NAME" --lpt1 off
> 
> # Désactiver VRDE si non utilisé
> VBoxManage modifyvm "$VM_NAME" --vrde off
> 
> # Configuration firmware sécurisée
> VBoxManage modifyvm "$VM_NAME" --firmware efi
> VBoxManage modifyvm "$VM_NAME" --pae on
> VBoxManage modifyvm "$VM_NAME" --longmode on
> 
> # Désactiver la fusion de pages
> VBoxManage modifyvm "$VM_NAME" --pagefusion off
> 
> # Limiter les ressources
> VBoxManage modifyvm "$VM_NAME" --cpuexecutioncap 80
> VBoxManage modifyvm "$VM_NAME" --cpus 2
> VBoxManage modifyvm "$VM_NAME" --memory 4096
> 
> # Randomiser la MAC
> VBoxManage modifyvm "$VM_NAME" --macaddress1 auto
> 
> echo "Hardening appliqué avec succès !"
> ```

### Audit de sécurité d'une VM

```bash
#!/bin/bash
# Script d'audit de sécurité

VM_NAME="$1"

if [ -z "$VM_NAME" ]; then
    echo "Usage: $0 <nom_vm>"
    exit 1
fi

echo "=== Audit de sécurité pour $VM_NAME ==="
echo ""

# Vérifier le mode réseau
echo "Réseau:"
VBoxManage showvminfo "$VM_NAME" | grep "NIC 1:" | head -1

# Vérifier les dossiers partagés
echo -e "\nDossiers partagés:"
VBoxManage showvminfo "$VM_NAME" | grep "Name: "

# Vérifier le clipboard et drag-drop
echo -e "\nClipboard et Drag-drop:"
VBoxManage showvminfo "$VM_NAME" | grep -E "(Clipboard|Drag)"

# Vérifier USB
echo -e "\nUSB:"
VBoxManage showvminfo "$VM_NAME" | grep -i usb | head -2

# Vérifier VRDE
echo -e "\nVRDE (accès distant):"
VBoxManage showvminfo "$VM_NAME" | grep -i vrde

# Vérifier le chiffrement
echo -e "\nChiffrement du disque:"
VBoxManage showvminfo "$VM_NAME" | grep -i encrypt

# Compter les snapshots
echo -e "\nSnapshots:"
SNAP_COUNT=$(VBoxManage snapshot "$VM_NAME" list 2>/dev/null | wc -l)
echo "Nombre de snapshots: $SNAP_COUNT"

echo -e "\n=== Fin de l'audit ==="
```

### Recommandations par type de VM

#### VM de développement

```bash
# Configuration équilibrée : fonctionnalité + sécurité modérée
VBoxManage modifyvm "DevVM" --nic1 nat
VBoxManage modifyvm "DevVM" --clipboard-mode bidirectional
VBoxManage modifyvm "DevVM" --draganddrop bidirectional
VBoxManage sharedfolder add "DevVM" --name "Projects" --hostpath "~/projects" --automount
```

#### VM de production / serveur

```bash
# Sécurité maximale, aucune fonctionnalité interactive
VBoxManage modifyvm "ProdVM" --nic1 natnetwork --nat-network1 "ProdNet"
VBoxManage modifyvm "ProdVM" --clipboard-mode disabled
VBoxManage modifyvm "ProdVM" --draganddrop disabled
VBoxManage modifyvm "ProdVM" --audio none
VBoxManage modifyvm "ProdVM" --usb off
VBoxManage modifyvm "ProdVM" --vrde on --vrdeauthtype external --vrdeaddress 127.0.0.1
```

#### VM d'analyse de malware

```bash
# Isolation totale
VBoxManage modifyvm "MalwareVM" --nic1 none
VBoxManage modifyvm "MalwareVM" --clipboard-mode disabled
VBoxManage modifyvm "MalwareVM" --draganddrop disabled
VBoxManage modifyvm "MalwareVM" --audio none
VBoxManage modifyvm "MalwareVM" --usb off
VBoxManage modifyvm "MalwareVM" --vrde off
# Snapshot avant chaque analyse
VBoxManage snapshot "MalwareVM" take "Clean_$(date +%Y%m%d_%H%M%S)"
```

> [!tip] Astuce finale Documentez vos configurations de sécurité ! Créez un fichier README.md dans chaque répertoire de VM pour noter les choix de sécurité et les justifications. Cela facilitera les audits futurs et la maintenance.

---

## 📌 Points clés à retenir

- **Isolation** : Utilisez le mode réseau approprié et limitez les dossiers partagés au strict nécessaire
- **Accès** : Contrôlez les permissions des fichiers VM et sécurisez l'accès distant (VRDE)
- **Chiffrement** : Chiffrez les disques contenant des données sensibles avec AES-XTS256
- **Snapshots** : Créez des snapshots avant toute action risquée et automatisez les sauvegardes périodiques
- **Hardening** : Désactivez tous les périphériques et fonctionnalités non nécessaires
- **Principe du moindre privilège** : N'accordez que les permissions minimales requises
- **Audit régulier** : Vérifiez périodiquement la configuration de sécurité de vos VMs

---

## 🎯 Synthèse des commandes essentielles

### Isolation rapide

```bash
# Configuration d'isolation standard
VBoxManage modifyvm "VM" --nic1 nat
VBoxManage modifyvm "VM" --clipboard-mode disabled
VBoxManage modifyvm "VM" --draganddrop disabled
```

### Chiffrement rapide

```bash
# Chiffrer un disque existant
VBoxManage encryptmedium "disk.vdi" \
    --newpassword "MotDePasse" \
    --cipher "AES-XTS256-PLAIN64" \
    --newpasswordid "MainPassword"
```

### Snapshot rapide

```bash
# Créer un snapshot avant modification
VBoxManage snapshot "VM" take "Backup_$(date +%Y%m%d_%H%M%S)"

# Restaurer en cas de problème
VBoxManage snapshot "VM" restore "NomDuSnapshot"
```

### Hardening rapide

```bash
# Désactiver tout ce qui est non essentiel
VBoxManage modifyvm "VM" --usb off --audio none --webcam off
VBoxManage modifyvm "VM" --uart1 off --lpt1 off --vrde off
VBoxManage modifyvm "VM" --pagefusion off
```

---

## 🔍 Scénarios pratiques

### Scénario 1 : Créer une VM sécurisée pour tests

```bash
#!/bin/bash
VM_NAME="TestVM"

# Créer la VM
VBoxManage createvm --name "$VM_NAME" --ostype "Ubuntu_64" --register

# Configuration matérielle limitée
VBoxManage modifyvm "$VM_NAME" --memory 2048 --cpus 2
VBoxManage modifyvm "$VM_NAME" --cpuexecutioncap 75

# Créer un disque chiffré
VBoxManage createmedium disk --filename "~/VirtualBox VMs/$VM_NAME/$VM_NAME.vdi" \
    --size 20480 --format VDI

VBoxManage encryptmedium "~/VirtualBox VMs/$VM_NAME/$VM_NAME.vdi" \
    --newpassword "SecurePass123!" \
    --cipher "AES-XTS256-PLAIN64" \
    --newpasswordid "TestPass"

# Attacher le contrôleur et le disque
VBoxManage storagectl "$VM_NAME" --name "SATA" --add sata --controller IntelAhci
VBoxManage storageattach "$VM_NAME" --storagectl "SATA" --port 0 --device 0 \
    --type hdd --medium "~/VirtualBox VMs/$VM_NAME/$VM_NAME.vdi"

# Isolation réseau
VBoxManage modifyvm "$VM_NAME" --nic1 nat

# Hardening complet
VBoxManage modifyvm "$VM_NAME" --clipboard-mode disabled
VBoxManage modifyvm "$VM_NAME" --draganddrop disabled
VBoxManage modifyvm "$VM_NAME" --usb off --audio none --webcam off
VBoxManage modifyvm "$VM_NAME" --vrde off

# Snapshot initial
VBoxManage snapshot "$VM_NAME" take "InitialCleanState" \
    --description "État initial propre après installation"

echo "VM sécurisée '$VM_NAME' créée avec succès !"
```

### Scénario 2 : Migration sécurisée d'une VM existante

```bash
#!/bin/bash
VM_NAME="ExistingVM"
BACKUP_DIR="~/vm-backups"

echo "Migration sécurisée de $VM_NAME..."

# 1. Créer un snapshot de sécurité
echo "Étape 1/5: Snapshot de sécurité..."
VBoxManage snapshot "$VM_NAME" take "BeforeMigration_$(date +%Y%m%d_%H%M%S)" \
    --description "Snapshot avant migration sécurisée"

# 2. Arrêter la VM si elle tourne
echo "Étape 2/5: Arrêt de la VM..."
VBoxManage controlvm "$VM_NAME" poweroff 2>/dev/null
sleep 5

# 3. Exporter la configuration actuelle
echo "Étape 3/5: Export de la configuration..."
VBoxManage showvminfo "$VM_NAME" --machinereadable > "$BACKUP_DIR/$VM_NAME-config-$(date +%Y%m%d).txt"

# 4. Appliquer le hardening
echo "Étape 4/5: Application du hardening..."
VBoxManage modifyvm "$VM_NAME" --nic1 nat
VBoxManage modifyvm "$VM_NAME" --clipboard-mode disabled
VBoxManage modifyvm "$VM_NAME" --draganddrop disabled
VBoxManage modifyvm "$VM_NAME" --usb off
VBoxManage modifyvm "$VM_NAME" --audio none
VBoxManage modifyvm "$VM_NAME" --vrde off
VBoxManage modifyvm "$VM_NAME" --pagefusion off

# 5. Chiffrer le disque
echo "Étape 5/5: Chiffrement du disque..."
read -sp "Entrez le mot de passe de chiffrement: " DISK_PASSWORD
echo ""

DISK_PATH=$(VBoxManage showvminfo "$VM_NAME" --machinereadable | grep "SATA-0-0" | cut -d'"' -f4)

VBoxManage encryptmedium "$DISK_PATH" \
    --newpassword "$DISK_PASSWORD" \
    --cipher "AES-XTS256-PLAIN64" \
    --newpasswordid "MigrationEncryption"

echo "Migration sécurisée terminée avec succès !"
echo "Configuration sauvegardée dans: $BACKUP_DIR/$VM_NAME-config-$(date +%Y%m%d).txt"
```

### Scénario 3 : Rotation automatique de snapshots

```bash
#!/bin/bash
# Script pour rotation automatique des snapshots (à placer dans cron)

VM_NAME="ProductionVM"
SNAPSHOT_PREFIX="AutoBackup"
KEEP_DAILY=7      # Garder 7 snapshots quotidiens
KEEP_WEEKLY=4     # Garder 4 snapshots hebdomadaires
KEEP_MONTHLY=12   # Garder 12 snapshots mensuels

DATE=$(date +%Y%m%d)
DAY_OF_WEEK=$(date +%u)  # 1=lundi, 7=dimanche
DAY_OF_MONTH=$(date +%d)

# Déterminer le type de snapshot
if [ "$DAY_OF_MONTH" = "01" ]; then
    SNAPSHOT_TYPE="Monthly"
    KEEP_COUNT=$KEEP_MONTHLY
elif [ "$DAY_OF_WEEK" = "7" ]; then
    SNAPSHOT_TYPE="Weekly"
    KEEP_COUNT=$KEEP_WEEKLY
else
    SNAPSHOT_TYPE="Daily"
    KEEP_COUNT=$KEEP_DAILY
fi

SNAPSHOT_NAME="${SNAPSHOT_PREFIX}_${SNAPSHOT_TYPE}_${DATE}"

# Créer le nouveau snapshot
echo "Création du snapshot: $SNAPSHOT_NAME"
VBoxManage snapshot "$VM_NAME" take "$SNAPSHOT_NAME" \
    --description "Snapshot automatique $SNAPSHOT_TYPE du $DATE" \
    --live

# Supprimer les anciens snapshots du même type
echo "Nettoyage des anciens snapshots $SNAPSHOT_TYPE..."
VBoxManage snapshot "$VM_NAME" list | grep "${SNAPSHOT_PREFIX}_${SNAPSHOT_TYPE}" | \
    awk '{print $2}' | sed 's/Name://g' | sort -r | tail -n +$((KEEP_COUNT + 1)) | \
    while read -r OLD_SNAP; do
        echo "Suppression de: $OLD_SNAP"
        VBoxManage snapshot "$VM_NAME" delete "$OLD_SNAP"
    done

echo "Rotation des snapshots terminée."
```

> [!example] Configuration cron pour rotation automatique
> 
> ```bash
> # Éditer le crontab
> crontab -e
> 
> # Ajouter ces lignes :
> # Snapshot quotidien à 2h du matin
> 0 2 * * * /home/user/scripts/snapshot-rotation.sh >> /var/log/vm-snapshots.log 2>&1
> 
> # Vérification hebdomadaire de sécurité tous les lundis à 3h
> 0 3 * * 1 /home/user/scripts/security-audit.sh >> /var/log/vm-audit.log 2>&1
> ```

---

## 🛡️ Matrice de sécurité par environnement

|Critère|Dev|Test|Prod|Malware Analysis|
|---|---|---|---|---|
|**Réseau**|NAT|NAT/Internal|NAT Network|None|
|**Clipboard**|Bidirectional|Disabled|Disabled|Disabled|
|**Drag-drop**|Bidirectional|Disabled|Disabled|Disabled|
|**Dossiers partagés**|Oui (RW)|Oui (RO)|Non|Non|
|**USB**|On|Off|Off|Off|
|**Audio**|On|Off|Off|Off|
|**VRDE**|Optional|Optional|Localhost only|Off|
|**Chiffrement disque**|Optional|Recommandé|Obligatoire|Obligatoire|
|**Snapshots quotidiens**|Non|Oui|Oui|Avant chaque test|
|**CPU Cap**|100%|80%|80%|50%|
|**Page Fusion**|On|Off|Off|Off|

---

## ⚠️ Pièges courants et solutions

### Piège 1 : Mot de passe de chiffrement perdu

**Problème** : Le mot de passe du disque chiffré est perdu, la VM est inaccessible.

**Solution préventive** :

```bash
# Toujours documenter dans un gestionnaire de mots de passe sécurisé
# Créer une clé de récupération séparée

# Option : créer un second disque non chiffré pour les données non sensibles
VBoxManage createmedium disk --filename "data.vdi" --size 10240
VBoxManage storageattach "VM" --storagectl "SATA" --port 1 \
    --device 0 --type hdd --medium "data.vdi"
```

### Piège 2 : Snapshots qui consomment tout l'espace disque

**Problème** : Accumulation de snapshots sans nettoyage.

**Solution** :

```bash
# Vérifier l'espace utilisé
du -sh ~/VirtualBox\ VMs/MaVM/

# Script de nettoyage mensuel
#!/bin/bash
VM_NAME="MaVM"
CUTOFF_DATE=$(date -d "30 days ago" +%Y%m%d)

VBoxManage snapshot "$VM_NAME" list | grep "Name:" | while read -r line; do
    SNAP_NAME=$(echo "$line" | awk '{print $2}')
    SNAP_DATE=$(echo "$SNAP_NAME" | grep -o '[0-9]\{8\}' | head -1)
    
    if [ "$SNAP_DATE" -lt "$CUTOFF_DATE" ]; then
        echo "Suppression de $SNAP_NAME (trop ancien)"
        VBoxManage snapshot "$VM_NAME" delete "$SNAP_NAME"
    fi
done
```

### Piège 3 : Performance dégradée après chiffrement

**Problème** : La VM est très lente après activation du chiffrement.

**Solution** :

```bash
# Vérifier que la virtualisation matérielle est activée
VBoxManage modifyvm "VM" --hwvirtex on
VBoxManage modifyvm "VM" --nestedpaging on

# Allouer plus de RAM si possible
VBoxManage modifyvm "VM" --memory 4096

# Utiliser un SSD pour stocker les VMs chiffrées
# Le chiffrement est très I/O intensif
```

### Piège 4 : Isolation réseau mal comprise

**Problème** : Croire que NAT isole complètement du réseau local.

**Clarification** :

```bash
# NAT = La VM peut accéder à Internet via l'hôte
# Mais l'hôte et le réseau local ne peuvent pas accéder à la VM

# Pour une isolation TOTALE (pas d'Internet) :
VBoxManage modifyvm "VM" --nic1 intnet --intnet1 "IsolatedNet"

# Ou carrément :
VBoxManage modifyvm "VM" --nic1 none
```

### Piège 5 : Oublier de sécuriser l'hôte

**Rappel important** :

> [!warning] L'hôte est le maillon faible Même avec des VMs parfaitement sécurisées, si votre système hôte est compromis, toutes les VMs le sont aussi. Sécurisez toujours l'hôte en priorité :
> 
> - Chiffrement complet du disque hôte (LUKS, BitLocker, FileVault)
> - Mises à jour régulières du système
> - Firewall activé
> - Antivirus à jour
> - Authentification forte (2FA si possible)
> - Permissions fichiers correctes sur les répertoires VMs

---

## 📋 Checklist finale de sécurité

Avant de mettre une VM en production ou de l'utiliser pour des données sensibles :

- [ ] Mode réseau approprié configuré (NAT minimum)
- [ ] Clipboard et drag-drop désactivés si non nécessaires
- [ ] Dossiers partagés limités au strict minimum (lecture seule si possible)
- [ ] USB, audio, webcam désactivés si non utilisés
- [ ] VRDE désactivé ou sécurisé (localhost + authentification)
- [ ] Disque chiffré avec AES-XTS256 (pour données sensibles)
- [ ] Mot de passe de chiffrement sauvegardé dans un gestionnaire sécurisé
- [ ] Snapshot initial "clean state" créé
- [ ] Snapshots automatiques configurés (si nécessaire)
- [ ] Limites de ressources appliquées (CPU cap, RAM)
- [ ] Page fusion désactivée (environnements critiques)
- [ ] Ports série/parallèle désactivés
- [ ] Firmware EFI configuré
- [ ] PAE/NX activés
- [ ] Adresse MAC randomisée
- [ ] Permissions fichiers vérifiées (700 sur répertoire VM)
- [ ] Documentation de la configuration créée
- [ ] Audit de sécurité effectué avec script
- [ ] Plan de backup/restauration en place

---

## 🔐 Conclusion

La sécurité des machines virtuelles est un processus continu qui nécessite vigilance et discipline. En appliquant les principes présentés dans ce cours, vous pouvez créer des environnements virtuels robustes et sécurisés adaptés à vos besoins spécifiques.

**Les trois piliers de la sécurité VM** :

1. **Isolation** : Limitez les communications et interactions non nécessaires
2. **Protection** : Chiffrez les données sensibles et contrôlez les accès
3. **Résilience** : Utilisez des snapshots pour pouvoir restaurer rapidement après incident

N'oubliez pas : la sécurité parfaite n'existe pas, mais une approche méthodique et des bonnes pratiques cohérentes réduisent considérablement les risques.