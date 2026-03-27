

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

## 🎯 Introduction à VirtualBox

VirtualBox est une solution de virtualisation open source développée par Oracle qui permet d'exécuter plusieurs systèmes d'exploitation simultanément sur une seule machine physique. C'est un hyperviseur de type 2 (hébergé), ce qui signifie qu'il fonctionne au-dessus d'un système d'exploitation hôte.

> [!info] Qu'est-ce qu'un hyperviseur de type 2 ? Contrairement aux hyperviseurs de type 1 (bare-metal) qui s'exécutent directement sur le matériel, VirtualBox nécessite un OS hôte (Windows, Linux, macOS) pour fonctionner. Cela le rend plus accessible mais légèrement moins performant qu'une solution bare-metal.

**Composants principaux de VirtualBox :**

- **VirtualBox Manager** : Interface graphique de gestion
- **VBoxManage** : Outil en ligne de commande
- **VBoxHeadless** : Exécution de VMs sans interface graphique
- **Guest Additions** : Pilotes et utilitaires pour optimiser les VMs

---

## ⚖️ Différences entre GUI et CLI

### Interface Graphique (GUI)

L'interface graphique VirtualBox Manager offre une expérience visuelle intuitive pour gérer les machines virtuelles.

**Avantages :**

- Courbe d'apprentissage douce
- Navigation visuelle des paramètres
- Feedback immédiat avec prévisualisation
- Idéale pour les débutants

**Limites :**

- Actions répétitives chronophages
- Difficile à automatiser
- Pas adaptée aux environnements sans interface (serveurs)
- Gestion complexe de nombreuses VMs

### Interface en Ligne de Commande (CLI)

VBoxManage est l'outil CLI qui expose toutes les fonctionnalités de VirtualBox via le terminal.

**Avantages :**

- Automatisation via scripts
- Contrôle granulaire de tous les paramètres
- Opérations en masse facilitées
- Gestion à distance (SSH)
- Intégration dans des pipelines CI/CD
- Performance (pas de charge graphique)

**Limites :**

- Courbe d'apprentissage plus raide
- Syntaxe à mémoriser
- Pas de retour visuel immédiat

### Tableau comparatif

|Critère|GUI|CLI|
|---|---|---|
|**Facilité d'utilisation**|⭐⭐⭐⭐⭐|⭐⭐|
|**Automatisation**|⭐|⭐⭐⭐⭐⭐|
|**Rapidité d'exécution**|⭐⭐|⭐⭐⭐⭐⭐|
|**Contrôle précis**|⭐⭐⭐|⭐⭐⭐⭐⭐|
|**Gestion multiple VMs**|⭐⭐|⭐⭐⭐⭐⭐|
|**Utilisation distante**|⭐⭐|⭐⭐⭐⭐⭐|

> [!tip] Meilleure pratique Utilisez la GUI pour la découverte et la configuration initiale, puis passez au CLI pour les opérations répétitives et l'automatisation. Les deux approches sont complémentaires !

---

## 🎯 Cas d'usage de la ligne de commande

### 1. Automatisation et Scripting

La CLI brille particulièrement dans les scénarios d'automatisation.

**Exemples concrets :**

```bash
# Script de déploiement automatique de 10 VMs de test
for i in {1..10}; do
    VBoxManage createvm --name "TestVM-$i" --register
    VBoxManage modifyvm "TestVM-$i" --memory 2048 --cpus 2
    VBoxManage startvm "TestVM-$i" --type headless
done
```

> [!example] Cas d'usage réel Un développeur doit créer quotidiennement un environnement de test propre. Avec un script CLI, cette opération prend 5 secondes au lieu de 10 minutes manuellement.

### 2. Administration à distance

Gérez vos VMs sur des serveurs sans interface graphique.

```bash
# Connexion SSH au serveur et gestion des VMs
ssh admin@serveur-distant
VBoxManage list runningvms
VBoxManage controlvm "Production-Web" poweroff
```

### 3. Intégration CI/CD

Intégrez VirtualBox dans vos pipelines d'intégration continue.

```yaml
# Exemple de configuration GitLab CI
test_environment:
  script:
    - VBoxManage startvm "TestEnv" --type headless
    - ./run-tests.sh
    - VBoxManage controlvm "TestEnv" poweroff
```

### 4. Gestion en masse

Opérations simultanées sur plusieurs VMs.

```bash
# Créer un snapshot de toutes les VMs en cours d'exécution
VBoxManage list runningvms | cut -d'"' -f2 | while read vm; do
    VBoxManage snapshot "$vm" take "backup-$(date +%Y%m%d)"
done
```

### 5. Configuration avancée

Accès à des paramètres non disponibles dans la GUI.

```bash
# Configuration réseau avancée
VBoxManage modifyvm "MaVM" --nic1 natnetwork --nat-network1 "Reseau-Interne"
VBoxManage modifyvm "MaVM" --nicpromisc1 allow-all
```

### 6. Monitoring et Diagnostics

Collecte d'informations détaillées pour le monitoring.

```bash
# Récupération des métriques de toutes les VMs
VBoxManage metrics query "*" CPU/Load/User,RAM/Usage/Used
```

> [!warning] Attention La CLI offre un contrôle total, ce qui inclut la possibilité de détruire des données. Testez toujours vos commandes sur des VMs non-critiques avant de les utiliser en production.

---

## 🏗️ Architecture de VirtualBox

### Vue d'ensemble des composants

```
┌─────────────────────────────────────────────────────┐
│              Système d'exploitation hôte            │
├─────────────────────────────────────────────────────┤
│                                                     │
│  ┌──────────────────┐      ┌──────────────────┐   │
│  │  VirtualBox      │      │   VBoxManage     │   │
│  │  Manager (GUI)   │      │   (CLI)          │   │
│  └────────┬─────────┘      └────────┬─────────┘   │
│           │                         │              │
│           └──────────┬──────────────┘              │
│                      │                             │
│         ┌────────────▼────────────┐                │
│         │   VirtualBox Core       │                │
│         │   (VBoxSVC)             │                │
│         └────────────┬────────────┘                │
│                      │                             │
│         ┌────────────▼────────────┐                │
│         │   Hyperviseur           │                │
│         │   (VBoxVMM)             │                │
│         └────────────┬────────────┘                │
│                      │                             │
│  ┌───────────────────┼───────────────────┐         │
│  │  VM 1         VM 2 │ VM 3         VM 4 │         │
│  │  ┌────┐      ┌────┐┌────┐      ┌────┐│         │
│  │  │OS  │      │OS  ││OS  │      │OS  ││         │
│  │  │App │      │App ││App │      │App ││         │
│  │  └────┘      └────┘└────┘      └────┘│         │
│  └──────────────────────────────────────┘         │
└─────────────────────────────────────────────────────┘
```

### Composants détaillés

#### 1. VBoxSVC (VirtualBox Service)

Le service central qui gère toutes les opérations de VirtualBox.

**Rôles :**

- Gestion des configurations des VMs
- Coordination entre l'interface utilisateur et l'hyperviseur
- Maintien de l'état des machines virtuelles
- Gestion des ressources partagées

> [!info] Processus persistant VBoxSVC reste actif en arrière-plan même quand aucune VM n'est en cours d'exécution. Il se lance automatiquement à la première interaction avec VirtualBox.

#### 2. VBoxVMM (Virtual Machine Monitor)

Le cœur de la virtualisation, responsable de l'exécution des VMs.

**Fonctions :**

- Virtualisation du CPU
- Gestion de la mémoire virtuelle
- Interception et traitement des instructions privilégiées
- Émulation des périphériques matériels

#### 3. Couche de communication

**XPCOM (Cross Platform Component Object Model) :**

- Permet la communication entre les différents composants
- Utilisé par VBoxManage pour interagir avec VBoxSVC
- Base de l'API VirtualBox

### Flux d'une commande CLI

```
Utilisateur entre une commande VBoxManage
              ↓
        VBoxManage (CLI)
              ↓
      Traduction en appels API
              ↓
    Communication via XPCOM
              ↓
        VBoxSVC (Service)
              ↓
    Validation et orchestration
              ↓
        VBoxVMM (Hyperviseur)
              ↓
        Exécution effective
```

### Fichiers de configuration

VirtualBox stocke ses configurations dans des emplacements spécifiques selon l'OS hôte.

|OS|Emplacement principal|
|---|---|
|**Linux**|`~/.config/VirtualBox/`|
|**Windows**|`C:\Users\<user>\.VirtualBox\`|
|**macOS**|`~/Library/VirtualBox/`|

**Fichiers importants :**

- `VirtualBox.xml` : Configuration globale de VirtualBox
- `<VM-Name>.vbox` : Configuration spécifique de chaque VM
- `<VM-Name>.vdi` : Fichier de disque virtuel (format VDI)

> [!warning] Modification manuelle Bien que ces fichiers XML soient éditables à la main, utilisez toujours VBoxManage pour les modifier. L'édition manuelle peut corrompre la configuration si la syntaxe n'est pas parfaite.

---

## 🛠️ VBoxManage - L'outil CLI principal

### Présentation générale

VBoxManage est l'interface en ligne de commande complète pour gérer tous les aspects de VirtualBox. Chaque action réalisable via la GUI peut être effectuée (et souvent dépassée) via VBoxManage.

### Syntaxe de base

```bash
VBoxManage <commande> [sous-commande] [options]
```

**Structure typique :**

```bash
VBoxManage list vms              # Commande simple
VBoxManage modifyvm "MaVM" --memory 4096  # Commande avec paramètres
VBoxManage startvm "MaVM" --type headless  # Commande avec options
```

> [!tip] Sensibilité à la casse Les noms de VMs sont sensibles à la casse. "MaVM" ≠ "mavm". Utilisez toujours des guillemets pour les noms contenant des espaces.

### Catégories de commandes principales

#### 1. Gestion des VMs

|Commande|Description|
|---|---|
|`createvm`|Créer une nouvelle VM|
|`modifyvm`|Modifier la configuration d'une VM|
|`unregistervm`|Supprimer une VM de VirtualBox|
|`clonevm`|Cloner une VM existante|

#### 2. Contrôle d'exécution

|Commande|Description|
|---|---|
|`startvm`|Démarrer une VM|
|`controlvm`|Contrôler une VM en cours d'exécution|
|`savestate`|Sauvegarder l'état d'une VM|
|`discardstate`|Annuler un état sauvegardé|

#### 3. Informations et listing

|Commande|Description|
|---|---|
|`list`|Lister diverses informations|
|`showvminfo`|Afficher les détails d'une VM|
|`metrics`|Consulter les métriques de performance|

#### 4. Gestion du stockage

|Commande|Description|
|---|---|
|`createhd`|Créer un disque virtuel|
|`modifyhd`|Modifier un disque virtuel|
|`storagectl`|Gérer les contrôleurs de stockage|
|`storageattach`|Attacher/détacher des disques|

#### 5. Réseau

|Commande|Description|
|---|---|
|`natnetwork`|Gérer les réseaux NAT|
|`hostonlyif`|Gérer les interfaces host-only|
|`dhcpserver`|Gérer les serveurs DHCP|

#### 6. Snapshots

|Commande|Description|
|---|---|
|`snapshot`|Créer, restaurer, supprimer des snapshots|

### Obtenir de l'aide

VBoxManage possède un système d'aide intégré très complet.

```bash
# Aide générale
VBoxManage --help

# Aide sur une commande spécifique
VBoxManage list --help
VBoxManage modifyvm --help

# Liste exhaustive de toutes les commandes
VBoxManage --help | grep "^VBoxManage"
```

> [!example] Navigation dans l'aide L'aide peut être très longue. Utilisez `less` pour naviguer :
> 
> ```bash
> VBoxManage --help | less
> # Utilisez / pour rechercher, q pour quitter
> ```

### Commandes d'information essentielles

#### Lister les VMs

```bash
# Toutes les VMs enregistrées
VBoxManage list vms

# Uniquement les VMs en cours d'exécution
VBoxManage list runningvms

# Toutes les informations système
VBoxManage list ostypes      # Types d'OS supportés
VBoxManage list hostinfo     # Informations sur l'hôte
VBoxManage list hdds         # Tous les disques virtuels
VBoxManage list dvds         # Images ISO montées
```

**Sortie typique :**

```bash
$ VBoxManage list vms
"Ubuntu-Server" {a1b2c3d4-e5f6-7890-abcd-ef1234567890}
"Windows-10-Dev" {b2c3d4e5-f6a7-8901-bcde-f12345678901}
"Test-VM" {c3d4e5f6-a7b8-9012-cdef-123456789012}
```

#### Obtenir les détails d'une VM

```bash
# Informations complètes
VBoxManage showvminfo "MaVM"

# Format lisible par machine (pour scripts)
VBoxManage showvminfo "MaVM" --machinereadable
```

**Informations retournées :**

- Configuration matérielle (CPU, RAM, graphique)
- Configuration réseau
- Périphériques attachés
- État actuel de la VM
- Snapshots existants
- Configuration des dossiers partagés

### Conventions de nommage

**Pour les noms de VMs :**

```bash
# Bon - Utilise des guillemets pour les espaces
VBoxManage startvm "Ma VM de Test"

# Bon - Pas d'espaces
VBoxManage startvm MaVM-Test

# Mauvais - Espaces sans guillemets
VBoxManage startvm Ma VM  # ERREUR
```

**Pour les UUID :**

Chaque VM possède un UUID unique. Vous pouvez utiliser soit le nom, soit l'UUID.

```bash
# Par nom
VBoxManage showvminfo "MaVM"

# Par UUID
VBoxManage showvminfo a1b2c3d4-e5f6-7890-abcd-ef1234567890
```

> [!tip] Quand utiliser les UUID ? Privilégiez les UUID dans les scripts automatisés pour éviter les problèmes si une VM est renommée.

### Retours de commande et codes d'erreur

VBoxManage utilise les codes de retour standard Unix.

```bash
# Succès : code 0
VBoxManage list vms
echo $?  # Affiche 0

# Erreur : code non-zéro
VBoxManage startvm "VM-Inexistante"
echo $?  # Affiche un code d'erreur (ex: 1)
```

**Gestion des erreurs dans les scripts :**

```bash
#!/bin/bash

if VBoxManage startvm "MaVM" --type headless; then
    echo "✓ VM démarrée avec succès"
else
    echo "✗ Échec du démarrage de la VM"
    exit 1
fi
```

### Astuces pour utiliser VBoxManage efficacement

#### 1. Utiliser des alias

```bash
# Dans ~/.bashrc ou ~/.zshrc
alias vbm='VBoxManage'
alias vblist='VBoxManage list vms'
alias vbrun='VBoxManage list runningvms'

# Utilisation
vbm startvm "MaVM"
vblist
```

#### 2. Auto-complétion

Sur Linux/macOS, activez l'auto-complétion bash.

```bash
# Ajoutez à ~/.bashrc
source /usr/share/virtualbox/VBoxManage-completion.bash
```

#### 3. Scripts de wrapper

Créez des scripts pour les opérations fréquentes.

```bash
#!/bin/bash
# Fichier: vm-start.sh

VM_NAME="$1"
TYPE="${2:-headless}"  # headless par défaut

if [ -z "$VM_NAME" ]; then
    echo "Usage: $0 <vm-name> [gui|headless]"
    exit 1
fi

VBoxManage startvm "$VM_NAME" --type "$TYPE"
```

#### 4. Format de sortie pour scripts

```bash
# Sortie parsable facilement
VBoxManage showvminfo "MaVM" --machinereadable | grep memory
# Output: memory=4096

# Extraction avec awk
RAM=$(VBoxManage showvminfo "MaVM" --machinereadable | \
      grep "^memory=" | cut -d'=' -f2)
echo "RAM allouée: ${RAM}Mo"
```

> [!warning] Pièges courants
> 
> - **Guillemets oubliés** : Les noms avec espaces doivent être entre guillemets
> - **VM déjà démarrée** : Vérifiez l'état avant de démarrer une VM
> - **Permissions insuffisantes** : Certaines opérations requièrent l'utilisateur qui a créé la VM
> - **VBoxSVC occupé** : Attendez quelques secondes si le service est occupé par une autre opération

### Différence entre options longues et courtes

VBoxManage utilise principalement des options longues pour la clarté.

```bash
# Syntaxe longue (recommandée)
VBoxManage modifyvm "MaVM" --memory 4096 --cpus 2

# Pas de syntaxe courte (-m, -c) comme avec d'autres outils CLI
# Cela rend les commandes plus explicites et auto-documentées
```

---

## 🎓 Points clés à retenir

> [!info] Résumé essentiel
> 
> **VirtualBox CLI offre :**
> 
> - Contrôle total via VBoxManage
> - Automatisation complète des opérations
> - Gestion à distance et en masse
> - Intégration dans des workflows DevOps
> 
> **Architecture en couches :**
> 
> - VBoxManage/GUI → VBoxSVC → VBoxVMM → VMs
> 
> **Syntaxe de base :**
> 
> ```bash
> VBoxManage <commande> [sous-commande] [options]
> ```
> 
> **Commandes essentielles à connaître :**
> 
> - `list` - Informations et listages
> - `showvminfo` - Détails d'une VM
> - `createvm` - Création de VM
> - `modifyvm` - Modification de configuration
> - `startvm` / `controlvm` - Contrôle d'exécution

---

_Ce cours couvre les fondamentaux de l'interface CLI de VirtualBox. Les sections suivantes exploreront en détail chaque catégorie de commandes._