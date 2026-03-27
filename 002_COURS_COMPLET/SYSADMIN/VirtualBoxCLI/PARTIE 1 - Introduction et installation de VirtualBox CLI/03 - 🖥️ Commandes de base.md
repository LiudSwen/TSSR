

## 📚 Table des matières

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

## Introduction à VBoxManage

`VBoxManage` est l'interface en ligne de commande (CLI) de VirtualBox. C'est un outil puissant qui expose toutes les fonctionnalités de VirtualBox, y compris celles non disponibles dans l'interface graphique.

> [!info] Pourquoi utiliser VBoxManage ?
> 
> - **Automatisation** : scriptage de tâches répétitives
> - **Fonctionnalités avancées** : accès à des options non disponibles dans la GUI
> - **Gestion à distance** : administration de VMs sans interface graphique
> - **CI/CD** : intégration dans des pipelines d'automatisation
> - **Performance** : opérations plus rapides que l'interface graphique

---

## Syntaxe générale de VBoxManage

### Structure de base

La syntaxe de VBoxManage suit toujours ce schéma :

```bash
VBoxManage <commande> [<sous-commande>] [arguments] [options]
```

> [!example] Anatomie d'une commande
> 
> ```bash
> VBoxManage startvm "MaVM" --type headless
> #    │       │       │         │
> #    │       │       │         └─ Option (modifier le comportement)
> #    │       │       └─────────── Argument (cible de la commande)
> #    │       └─────────────────── Commande principale
> #    └─────────────────────────── Exécutable VBoxManage
> ```

### Règles syntaxiques importantes

1. **Respect de la casse** : les commandes sont sensibles à la casse (généralement en minuscules)
2. **Guillemets** : utilisez des guillemets pour les noms contenant des espaces
3. **Options** : commencent par `--` (double tiret)
4. **UUID vs Nom** : vous pouvez utiliser soit le nom de la VM, soit son UUID

```bash
# Avec le nom de la VM
VBoxManage startvm "Windows 10"

# Avec l'UUID de la VM
VBoxManage startvm a1b2c3d4-e5f6-7890-abcd-ef1234567890
```

> [!tip] Astuce professionnelle Utilisez les UUID dans vos scripts pour éviter les problèmes liés aux renommages de VMs. Les UUID sont immuables.

### Conventions de nommage

|Élément|Convention|Exemple|
|---|---|---|
|Commandes|minuscules|`startvm`, `modifyvm`|
|Options|`--kebab-case`|`--memory`, `--boot-menu`|
|Valeurs booléennes|`on`/`off`|`--vrde on`|
|Chemins|Absolus recommandés|`/home/user/VMs/disk.vdi`|

---

## Aide et documentation

### La commande `--help`

VBoxManage intègre un système d'aide exhaustif accessible directement depuis le terminal.

#### Aide globale

Pour obtenir la liste de toutes les commandes disponibles :

```bash
VBoxManage --help
```

Cette commande affiche :

- La liste complète des commandes
- Une brève description de chaque commande
- La version de VBoxManage

> [!example] Extrait de sortie
> 
> ```
> Oracle VM VirtualBox Command Line Management Interface Version 7.0.x
> Copyright (C) 2005-2023 Oracle and/or its affiliates
> 
> Usage:
>   VBoxManage [<general option>] <command>
> 
> General Options:
>   [-v|--version]    print version number and exit
>   [--dump-build-type] print build type and exit
>   ...
> ```

#### Aide spécifique à une commande

Pour obtenir de l'aide sur une commande particulière :

```bash
VBoxManage <commande> --help
```

```bash
# Aide détaillée sur la commande startvm
VBoxManage startvm --help

# Aide sur la modification de VMs
VBoxManage modifyvm --help

# Aide sur la création de disques
VBoxManage createhd --help
```

> [!tip] Navigation dans l'aide L'aide peut être très longue. Utilisez un pager pour la naviguer :
> 
> ```bash
> VBoxManage modifyvm --help | less
> ```
> 
> Ou recherchez un mot-clé spécifique :
> 
> ```bash
> VBoxManage modifyvm --help | grep memory
> ```

### La commande `--version`

Pour connaître la version exacte de VBoxManage installée :

```bash
VBoxManage --version
```

> [!example] Sortie typique
> 
> ```
> 7.0.12r159484
> ```
> 
> Cette sortie signifie :
> 
> - Version majeure : 7
> - Version mineure : 0
> - Patch : 12
> - Révision SVN : 159484

> [!warning] Compatibilité des versions Certaines commandes ou options peuvent varier entre les versions de VirtualBox. Vérifiez toujours la version si vous rencontrez des erreurs dans des scripts existants.

### Options globales communes

Certaines options s'appliquent à toutes les commandes :

```bash
# Afficher plus d'informations pendant l'exécution
VBoxManage --verbose <commande>

# Spécifier un fichier de configuration alternatif
VBoxManage --settingspw <mot-de-passe> <commande>
```

---

## Liste des catégories de commandes

VBoxManage regroupe ses commandes en plusieurs catégories fonctionnelles. Voici une vue d'ensemble organisée :

### 🔧 Gestion des machines virtuelles

Commandes pour créer, configurer et gérer le cycle de vie des VMs.

|Commande|Description|Usage typique|
|---|---|---|
|`list`|Liste les VMs et ressources|Inventaire, scripts|
|`showvminfo`|Affiche les détails d'une VM|Diagnostic, vérification|
|`createvm`|Crée une nouvelle VM|Automatisation de création|
|`modifyvm`|Modifie la configuration d'une VM|Ajustement des ressources|
|`clonevm`|Clone une VM existante|Duplication rapide|
|`unregistervm`|Désenregistre une VM|Nettoyage, suppression|

```bash
# Exemples rapides
VBoxManage list vms                    # Liste toutes les VMs
VBoxManage showvminfo "MaVM"           # Détails de "MaVM"
VBoxManage createvm --name "Test"      # Crée une VM "Test"
VBoxManage modifyvm "Test" --memory 2048  # Alloue 2GB de RAM
```

### ⚡ Contrôle d'exécution

Commandes pour démarrer, arrêter et contrôler les VMs en cours d'exécution.

|Commande|Description|Usage typique|
|---|---|---|
|`startvm`|Démarre une VM|Lancement de VM|
|`controlvm`|Contrôle une VM en cours d'exécution|Pause, reset, poweroff|
|`discardstate`|Supprime l'état sauvegardé|Nettoyage après crash|

```bash
# Exemples de contrôle
VBoxManage startvm "MaVM" --type headless    # Démarre sans GUI
VBoxManage controlvm "MaVM" pause            # Met en pause
VBoxManage controlvm "MaVM" poweroff         # Arrêt forcé
```

> [!warning] Différence entre poweroff et acpipowerbutton
> 
> - `poweroff` : arrêt brutal (équivalent à débrancher la prise)
> - `acpipowerbutton` : arrêt propre (équivalent à appuyer sur le bouton power)

### 💾 Gestion du stockage

Commandes pour créer et gérer les disques virtuels et contrôleurs.

|Commande|Description|Usage typique|
|---|---|---|
|`createhd`|Crée un disque dur virtuel|Création de stockage|
|`modifyhd`|Modifie un disque existant|Redimensionnement|
|`clonehd`|Clone un disque|Sauvegarde, duplication|
|`closemedium`|Ferme un média|Libération de ressources|
|`storagectl`|Gère les contrôleurs de stockage|Configuration SATA/IDE|
|`storageattach`|Attache/détache un média|Montage de disques/ISO|

```bash
# Chaîne de création de stockage
VBoxManage createhd --filename disk.vdi --size 10240  # 10GB
VBoxManage storagectl "MaVM" --name "SATA" --add sata
VBoxManage storageattach "MaVM" --storagectl "SATA" --port 0 \
           --device 0 --type hdd --medium disk.vdi
```

### 🌐 Gestion réseau

Commandes pour configurer les interfaces réseau et les réseaux internes.

|Commande|Description|Usage typique|
|---|---|---|
|`hostonlyif`|Gère les interfaces host-only|Réseau isolé|
|`natnetwork`|Gère les réseaux NAT|Réseau partagé entre VMs|
|`dhcpserver`|Configure les serveurs DHCP|Attribution automatique d'IP|

```bash
# Création d'un réseau NAT
VBoxManage natnetwork add --netname MonReseau --network "10.0.2.0/24" --enable
VBoxManage modifyvm "MaVM" --nic1 natnetwork --nat-network1 MonReseau
```

### 📸 Snapshots (instantanés)

Commandes pour gérer les points de restauration de VMs.

|Commande|Description|Usage typique|
|---|---|---|
|`snapshot`|Crée/supprime/restaure des snapshots|Sauvegarde d'état|

```bash
# Gestion des snapshots
VBoxManage snapshot "MaVM" take "BeforeUpdate"          # Créer
VBoxManage snapshot "MaVM" list                         # Lister
VBoxManage snapshot "MaVM" restore "BeforeUpdate"       # Restaurer
VBoxManage snapshot "MaVM" delete "BeforeUpdate"        # Supprimer
```

> [!tip] Stratégie de snapshots Prenez toujours un snapshot avant des modifications majeures (mises à jour système, installation de logiciels critiques). Supprimez les snapshots obsolètes pour libérer de l'espace disque.

### 🔌 Extensions et périphériques

Commandes pour gérer les extensions, USB, et partages de dossiers.

|Commande|Description|Usage typique|
|---|---|---|
|`sharedfolder`|Gère les dossiers partagés|Échange hôte-invité|
|`usbfilter`|Configure les filtres USB|Redirection USB|
|`extpack`|Gère les packs d'extension|Installation Extension Pack|

```bash
# Partage de dossier
VBoxManage sharedfolder add "MaVM" --name "Partage" \
           --hostpath "/home/user/shared" --automount

# Filtre USB
VBoxManage usbfilter add 0 --target "MaVM" --name "MaCleUSB" \
           --vendorid 0x1234 --productid 0x5678
```

### 📊 Métriques et informations

Commandes pour surveiller et obtenir des statistiques sur les VMs.

|Commande|Description|Usage typique|
|---|---|---|
|`metrics`|Collecte des métriques de performance|Monitoring|
|`guestproperty`|Gère les propriétés invité|Communication hôte-invité|
|`guestcontrol`|Contrôle l'invité depuis l'hôte|Exécution de commandes|

```bash
# Obtenir des métriques
VBoxManage metrics collect

# Lire une propriété invité
VBoxManage guestproperty get "MaVM" "/VirtualBox/GuestInfo/OS/Product"

# Exécuter une commande dans l'invité
VBoxManage guestcontrol "MaVM" run --exe "/bin/ls" \
           --username user --password pass
```

### 🛠️ Administration système

Commandes pour la configuration globale de VirtualBox.

|Commande|Description|Usage typique|
|---|---|---|
|`setproperty`|Configure les propriétés globales|Chemins par défaut|
|`export`|Exporte une VM au format OVA|Portabilité|
|`import`|Importe une VM depuis OVA|Déploiement|

```bash
# Changer le dossier par défaut des VMs
VBoxManage setproperty machinefolder "/data/VirtualBox"

# Exporter une VM
VBoxManage export "MaVM" --output MaVM.ova

# Importer une VM
VBoxManage import MaVM.ova
```

### 🎯 Catégories moins fréquentes

D'autres commandes existent pour des cas d'usage spécifiques :

|Catégorie|Commandes|Usage|
|---|---|---|
|**Cloud**|`cloud`|Gestion VMs dans le cloud Oracle|
|**Webcam**|`webcam`|Configuration webcam virtuelle|
|**Enregistrement**|`recording`|Capture vidéo de la VM|
|**VNC**|`vrde`, `vrdeserver`|Accès à distance via VNC/RDP|
|**Bandwith**|`bandwidthctl`|Limitation de bande passante|

> [!info] Découverte progressive Ne vous sentez pas obligé de mémoriser toutes ces commandes. Commencez par les commandes de base (list, showvminfo, startvm, controlvm) et explorez progressivement les autres selon vos besoins.

---

## 🎓 Bonnes pratiques générales

### Organisation des commandes

```bash
# ✅ BON : une commande par ligne, lisible
VBoxManage modifyvm "MaVM" \
  --memory 4096 \
  --cpus 2 \
  --vram 128

# ❌ MAUVAIS : tout sur une ligne
VBoxManage modifyvm "MaVM" --memory 4096 --cpus 2 --vram 128 --nic1 nat --cableconnected1 on
```

### Gestion des erreurs dans les scripts

```bash
# Vérifier le code de retour
VBoxManage startvm "MaVM" --type headless
if [ $? -ne 0 ]; then
    echo "Erreur lors du démarrage de la VM"
    exit 1
fi

# Ou avec set -e pour arrêter en cas d'erreur
set -e
VBoxManage startvm "MaVM" --type headless
```

### Conventions de nommage pour les VMs

```bash
# ✅ BON : noms descriptifs et structurés
"dev-ubuntu-22.04-web"
"prod-windows-server-2022-db"
"test-debian-11-docker"

# ❌ MAUVAIS : noms génériques
"VM1"
"test"
"nouvelle"
```

> [!tip] Préfixes utiles Utilisez des préfixes pour catégoriser vos VMs :
> 
> - `dev-` : développement
> - `test-` : tests
> - `prod-` : production
> - `template-` : modèles de base

---

## 🚨 Pièges courants

### 1. Oublier les guillemets

```bash
# ❌ ERREUR si le nom contient des espaces
VBoxManage startvm Windows 10

# ✅ CORRECT
VBoxManage startvm "Windows 10"
```

### 2. Modifier une VM en cours d'exécution

```bash
# ❌ Beaucoup d'options ne peuvent pas être modifiées à chaud
VBoxManage modifyvm "MaVM" --memory 4096  # Erreur si VM en marche

# ✅ Vérifier l'état avant
VBoxManage showvminfo "MaVM" --machinereadable | grep VMState
```

### 3. Confusion entre commandes similaires

```bash
# createvm ≠ createhd
VBoxManage createvm --name "MaVM"      # Crée la VM (configuration)
VBoxManage createhd --filename disk.vdi # Crée le disque dur virtuel

# Les deux sont nécessaires pour une VM fonctionnelle !
```

### 4. Chemins relatifs vs absolus

```bash
# ⚠️ Chemins relatifs peuvent causer des problèmes
VBoxManage createhd --filename disk.vdi

# ✅ Préférez les chemins absolus
VBoxManage createhd --filename "/home/user/VMs/disk.vdi"
```

---

## 💡 Astuces avancées

### Chaînage de commandes efficace

```bash
# Créer et configurer une VM en une séquence
VM_NAME="TestVM"
VBoxManage createvm --name "$VM_NAME" --register && \
VBoxManage modifyvm "$VM_NAME" --memory 2048 --cpus 2 && \
VBoxManage createhd --filename "$VM_NAME.vdi" --size 20480 && \
VBoxManage storagectl "$VM_NAME" --name "SATA" --add sata && \
VBoxManage storageattach "$VM_NAME" --storagectl "SATA" --port 0 \
  --device 0 --type hdd --medium "$VM_NAME.vdi"
```

### Utiliser `--machinereadable` pour le parsing

```bash
# Format adapté aux scripts (key=value)
VBoxManage list vms --machinereadable
VBoxManage showvminfo "MaVM" --machinereadable | grep "memory="
```

### Recherche rapide dans l'aide

```bash
# Trouver toutes les options liées à la mémoire
VBoxManage modifyvm --help | grep -i memory

# Afficher seulement les options réseau
VBoxManage modifyvm --help | grep -A 2 "nic[0-9]"
```

### Création de fonctions bash réutilisables

```bash
# Dans votre .bashrc ou script
vm_info() {
    VBoxManage showvminfo "$1" | grep -E "Name:|State:|Memory:|CPUs:"
}

# Utilisation
vm_info "MaVM"
```

---

> [!success] Point clé Maîtriser la syntaxe de base et le système d'aide de VBoxManage est essentiel. Ces fondations vous permettront d'explorer toutes les fonctionnalités avancées de VirtualBox en autonomie.