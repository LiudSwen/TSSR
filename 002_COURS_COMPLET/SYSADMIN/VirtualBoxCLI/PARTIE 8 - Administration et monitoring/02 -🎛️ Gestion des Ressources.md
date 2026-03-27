

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

La gestion des ressources dans VirtualBox permet de contrôler précisément comment les machines virtuelles consomment les ressources physiques de l'hôte. Cette capacité est essentielle pour :

- **Optimiser les performances** : Éviter qu'une VM monopolise toutes les ressources
- **Garantir la stabilité** : Prévenir les conflits entre VMs et l'hôte
- **Simuler des environnements réalistes** : Tester des applications dans des conditions de ressources limitées
- **Partager équitablement** : Faire cohabiter plusieurs VMs sur un même hôte

> [!info] Prérequis Pour modifier les paramètres de ressources, la VM doit être **éteinte** (sauf mention contraire). Utilisez `VBoxManage list vms` pour vérifier l'état de vos VMs.

---

## Limitation CPU et Mémoire

### Configuration de la mémoire RAM

La mémoire RAM est l'une des ressources les plus critiques pour les performances d'une VM.

#### Syntaxe de base

```bash
# Définir la mémoire RAM (en Mo)
VBoxManage modifyvm "NomVM" --memory <taille_en_Mo>

# Exemples pratiques
VBoxManage modifyvm "Ubuntu-Server" --memory 2048    # 2 Go
VBoxManage modifyvm "Windows10" --memory 4096        # 4 Go
VBoxManage modifyvm "TestVM" --memory 512            # 512 Mo
```

#### Vérification de la configuration

```bash
# Afficher la mémoire allouée
VBoxManage showvminfo "NomVM" | grep "Memory size"
```

> [!warning] Limites importantes
> 
> - **Minimum absolu** : 4 Mo (mais inutilisable en pratique)
> - **Minimum recommandé** : 512 Mo pour Linux minimal, 2048 Mo pour Windows
> - **Maximum** : Limité par la RAM physique de l'hôte
> - **Règle d'or** : Ne pas allouer plus de 50-75% de la RAM totale de l'hôte pour toutes les VMs combinées

> [!tip] Bonnes pratiques
> 
> - Laissez au minimum 2-4 Go pour l'OS hôte
> - Pour un système Linux léger : 1-2 Go suffisent
> - Pour Windows 10/11 : minimum 4 Go, recommandé 8 Go
> - Surveillez l'utilisation réelle avec `VBoxManage metrics query`

---

### Configuration des CPUs virtuels

Le nombre de CPUs virtuels (vCPUs) détermine la capacité de traitement parallèle de la VM.

#### Syntaxe de base

```bash
# Définir le nombre de CPUs virtuels
VBoxManage modifyvm "NomVM" --cpus <nombre>

# Exemples
VBoxManage modifyvm "DevServer" --cpus 2      # 2 cœurs
VBoxManage modifyvm "BuildMachine" --cpus 4   # 4 cœurs
VBoxManage modifyvm "TestVM" --cpus 1         # 1 cœur
```

#### Configuration avancée

```bash
# Activer PAE/NX (Physical Address Extension)
# Permet d'utiliser plus de 4 Go de RAM sur les systèmes 32 bits
VBoxManage modifyvm "NomVM" --pae on

# Activer les instructions de virtualisation matérielle
VBoxManage modifyvm "NomVM" --vtxvpid on
VBoxManage modifyvm "NomVM" --vtxux on

# Vérification
VBoxManage showvminfo "NomVM" | grep -E "CPU|PAE|VT-x"
```

> [!warning] Limitations CPU
> 
> - **Maximum** : Ne pas dépasser le nombre de cœurs physiques de l'hôte (sauf cas spécifiques)
> - **Overcommitment** : Allouer 2x plus de vCPUs que de cœurs physiques peut dégrader les performances
> - **Hyperthreading** : VirtualBox compte les threads logiques comme des cœurs

|Nombre de cœurs physiques|vCPUs recommandés par VM|vCPUs total max (toutes VMs)|
|---|---|---|
|2 cœurs|1-2|2-3|
|4 cœurs|2-3|4-6|
|8 cœurs|2-4|8-12|
|16+ cœurs|4-8|16-24|

---

### CPU Execution Cap

Le **CPU Execution Cap** limite le pourcentage de temps CPU qu'une VM peut utiliser. C'est différent du nombre de vCPUs : il s'agit d'une limitation de performance.

#### Concept

```
Execution Cap = 100% → VM peut utiliser 100% de chaque vCPU
Execution Cap = 50%  → VM ne peut utiliser que 50% de chaque vCPU
Execution Cap = 25%  → VM limitée à 25% de chaque vCPU
```

#### Syntaxe

```bash
# Définir le CPU Execution Cap (1-100%)
VBoxManage modifyvm "NomVM" --cpuexecutioncap <pourcentage>

# Exemples pratiques
VBoxManage modifyvm "BackgroundVM" --cpuexecutioncap 50   # Limiter à 50%
VBoxManage modifyvm "PriorityVM" --cpuexecutioncap 100    # Performance maximale
VBoxManage modifyvm "TestVM" --cpuexecutioncap 25         # Très limité
```

#### Cas d'usage

```bash
# Scénario 1 : VM de fond qui ne doit pas ralentir l'hôte
VBoxManage modifyvm "DownloadVM" --cpus 2 --cpuexecutioncap 30

# Scénario 2 : Tester une app sous contraintes CPU
VBoxManage modifyvm "TestEnvironment" --cpus 4 --cpuexecutioncap 40

# Scénario 3 : Serveur de production (performance max)
VBoxManage modifyvm "ProductionServer" --cpus 8 --cpuexecutioncap 100
```

> [!example] Exemple de calcul Si vous avez :
> 
> - 4 vCPUs alloués
> - Execution Cap à 50%
> 
> La VM peut utiliser : **4 × 50% = 2 vCPUs équivalents au maximum**

> [!tip] Quand utiliser l'Execution Cap
> 
> - **VMs de développement/test** : 40-60% pour économiser les ressources
> - **VMs de compilation** : 70-80% pour équilibrer vitesse et ressources hôte
> - **VMs critiques** : 100% pour des performances optimales
> - **VMs multiples simultanées** : Répartir équitablement (ex: 3 VMs à 33% chacune)

---

## IO Throttling

### Comprendre l'IO Throttling

L'**IO Throttling** (limitation des entrées/sorties) contrôle la vitesse de lecture/écriture sur les disques virtuels. Cela permet d'éviter qu'une VM monopolise le sous-système de stockage.

#### Pourquoi limiter les I/O ?

- **Équité** : Empêcher une VM d'affamer les autres en I/O
- **Protection de l'hôte** : Éviter la saturation du stockage physique
- **Tests réalistes** : Simuler des disques lents (HDD classiques, stockage réseau)
- **Conformité** : Respecter des quotas de stockage cloud

> [!info] Unités de mesure
> 
> - **Débit** : Exprimé en octets par seconde (B/s, KB/s, MB/s)
> - **IOPS** : Input/Output Operations Per Second (opérations par seconde)

---

### Configuration des limites I/O

VirtualBox permet de limiter les I/O via les **Bandwidth Groups** (voir section suivante), mais aussi directement sur les contrôleurs de stockage.

#### Limitation par contrôleur

```bash
# Définir une limite I/O sur un contrôleur de stockage
VBoxManage storageattach "NomVM" \
    --storagectl "SATA Controller" \
    --port 0 \
    --device 0 \
    --type hdd \
    --medium "/path/to/disk.vdi" \
    --bandwidthgroup "MonGroupe"  # Référence à un bandwidth group
```

#### Métriques I/O disponibles

```bash
# Surveiller les I/O en temps réel (VM en cours d'exécution)
VBoxManage metrics query "NomVM" "Guest/RAM/Usage/*,Disk/*"

# Afficher l'historique des métriques
VBoxManage metrics list
```

> [!warning] Pièges courants
> 
> - Les limites I/O s'appliquent **par disque**, pas globalement à la VM
> - Une limite trop basse (<10 MB/s) peut rendre le système inutilisable
> - Les I/O réseau et disque utilisent des mécanismes différents

---

## Bandwidth Groups

### Concept des groupes de bande passante

Les **Bandwidth Groups** sont des objets qui définissent des limites de bande passante pouvant être partagées entre plusieurs contrôleurs (disques, réseau).

#### Principe de fonctionnement

```
┌─────────────────────────────────┐
│   Bandwidth Group "Shared-50"   │
│   Limite: 50 MB/s               │
└────────┬─────────────┬──────────┘
         │             │
    ┌────▼───┐    ┌────▼───┐
    │ Disk 1 │    │ Disk 2 │
    └────────┘    └────────┘
    
→ Les 2 disques partagent 50 MB/s au total
```

---

### Création et gestion

#### Créer un Bandwidth Group

```bash
# Syntaxe générale
VBoxManage bandwidthctl "NomVM" add <nom_groupe> \
    --type disk|network \
    --limit <valeur><unité>

# Exemples de création
VBoxManage bandwidthctl "ServerVM" add "SSD-Limit" \
    --type disk \
    --limit 100M    # 100 Mo/s

VBoxManage bandwidthctl "TestVM" add "Slow-Disk" \
    --type disk \
    --limit 10M     # Simuler un disque lent

VBoxManage bandwidthctl "WebServer" add "Network-Limit" \
    --type network \
    --limit 50M     # 50 Mo/s réseau
```

#### Unités acceptées

|Unité|Signification|Exemple|
|---|---|---|
|`K`|Kilooctets/s|`5000K` = 5 Mo/s|
|`M`|Mégaoctets/s|`100M` = 100 Mo/s|
|`G`|Gigaoctets/s|`1G` = 1 Go/s|

#### Modifier un groupe existant

```bash
# Changer la limite
VBoxManage bandwidthctl "NomVM" set "SSD-Limit" --limit 200M

# Supprimer un groupe
VBoxManage bandwidthctl "NomVM" remove "SSD-Limit"

# Lister tous les groupes
VBoxManage bandwidthctl "NomVM" list
```

> [!tip] Astuce pratique Créez des groupes génériques réutilisables :
> 
> - `Fast-Storage` : 500M pour disques SSD
> - `Normal-Storage` : 100M pour disques standard
> - `Slow-Storage` : 20M pour tests/simulations
> - `LAN-Speed` : 100M pour réseau local
> - `WAN-Speed` : 10M pour simuler Internet

---

### Application aux disques et réseau

#### Attacher un disque à un Bandwidth Group

```bash
# Lors de l'attachement d'un disque
VBoxManage storageattach "ServerVM" \
    --storagectl "SATA" \
    --port 0 \
    --device 0 \
    --type hdd \
    --medium "/path/to/disk.vdi" \
    --bandwidthgroup "SSD-Limit"

# Modifier un disque déjà attaché
VBoxManage storageattach "ServerVM" \
    --storagectl "SATA" \
    --port 0 \
    --device 0 \
    --bandwidthgroup "Slow-Disk"

# Retirer la limitation
VBoxManage storageattach "ServerVM" \
    --storagectl "SATA" \
    --port 0 \
    --device 0 \
    --bandwidthgroup none
```

#### Configuration réseau avec Bandwidth Groups

```bash
# Créer un groupe pour le réseau
VBoxManage bandwidthctl "WebServer" add "Internet-Limit" \
    --type network \
    --limit 10M

# Appliquer au contrôleur réseau (VM éteinte)
VBoxManage modifyvm "WebServer" \
    --nicbandwidthgroup1 "Internet-Limit"

# Appliquer à plusieurs interfaces
VBoxManage modifyvm "Router" \
    --nicbandwidthgroup1 "WAN-Speed" \
    --nicbandwidthgroup2 "LAN-Speed"
```

> [!example] Exemple complet : VM multi-disques avec limitations
> 
> ```bash
> # Créer les groupes
> VBoxManage bandwidthctl "DatabaseServer" add "Fast-SSD" --type disk --limit 300M
> VBoxManage bandwidthctl "DatabaseServer" add "Backup-Disk" --type disk --limit 50M
> 
> # Disque système (rapide)
> VBoxManage storageattach "DatabaseServer" \
>     --storagectl "SATA" --port 0 --device 0 \
>     --type hdd --medium "/vms/db-system.vdi" \
>     --bandwidthgroup "Fast-SSD"
> 
> # Disque de données (rapide)
> VBoxManage storageattach "DatabaseServer" \
>     --storagectl "SATA" --port 1 --device 0 \
>     --type hdd --medium "/vms/db-data.vdi" \
>     --bandwidthgroup "Fast-SSD"
> 
> # Disque de sauvegarde (lent)
> VBoxManage storageattach "DatabaseServer" \
>     --storagectl "SATA" --port 2 --device 0 \
>     --type hdd --medium "/vms/db-backup.vdi" \
>     --bandwidthgroup "Backup-Disk"
> ```

> [!warning] Points d'attention
> 
> - Les Bandwidth Groups s'appliquent **pendant l'exécution** de la VM
> - Modification possible à chaud avec `VBoxManage controlvm` (pour certains paramètres)
> - La somme des limites ne doit pas dépasser les capacités physiques de l'hôte

---

## Priority et Scheduling

### CPU Priority

La priorité CPU détermine l'ordre dans lequel le système d'exploitation hôte alloue du temps CPU aux processus de VirtualBox.

#### Niveaux de priorité

VirtualBox ne fournit pas de commande CLI directe pour la priorité, mais vous pouvez influencer le scheduling via le système hôte :

**Sur Linux :**

```bash
# Démarrer une VM avec une priorité réduite
nice -n 10 VBoxManage startvm "BackgroundVM" --type headless

# Modifier la priorité d'une VM en cours d'exécution
# Trouver le PID du processus VirtualBox
ps aux | grep VBoxHeadless

# Changer la priorité (nécessite root pour augmenter)
sudo renice -n -5 -p <PID>
```

**Sur Windows (PowerShell en administrateur) :**

```powershell
# Démarrer avec priorité basse
Start-Process -FilePath "C:\Program Files\Oracle\VirtualBox\VBoxManage.exe" `
    -ArgumentList "startvm", "BackgroundVM", "--type", "headless" `
    -WindowStyle Hidden -Priority BelowNormal

# Modifier une VM en cours
Get-Process VBoxHeadless | ForEach-Object { $_.PriorityClass = "BelowNormal" }
```

#### Valeurs de nice (Linux)

|Valeur|Priorité|Usage recommandé|
|---|---|---|
|`-20` à `-10`|Très haute|VMs critiques uniquement (nécessite root)|
|`-9` à `-1`|Haute|VMs de production importantes|
|`0`|Normale|Défaut pour la plupart des VMs|
|`1` à `10`|Basse|VMs de développement, tests|
|`11` à `19`|Très basse|VMs de fond, sauvegardes|

> [!tip] Stratégie de priorité
> 
> - **Production** : nice -5 ou 0
> - **Développement** : nice 5 à 10
> - **Compilation/builds** : nice 10 à 15
> - **Sauvegardes** : nice 19

---

### Gestion avancée du scheduling

#### CPU Hot-Plugging

VirtualBox permet d'ajouter/retirer des CPUs à chaud (VM en cours d'exécution).

```bash
# Activer le CPU hot-plugging (VM éteinte)
VBoxManage modifyvm "ServerVM" --cpuhotplug on

# Définir le maximum de CPUs possibles
VBoxManage modifyvm "ServerVM" --cpus 8

# Ajouter un CPU à chaud (VM en cours d'exécution)
VBoxManage controlvm "ServerVM" plugcpu 4

# Retirer un CPU à chaud
VBoxManage controlvm "ServerVM" unplugcpu 4

# Vérifier l'état des CPUs
VBoxManage showvminfo "ServerVM" | grep "Number of CPUs"
```

> [!warning] Limitations du CPU hot-plugging
> 
> - Nécessite un OS invité compatible (Linux récent, Windows Server)
> - Le CPU 0 ne peut jamais être retiré
> - L'OS invité doit supporter l'ACPI
> - Peut nécessiter une configuration spécifique dans l'OS invité

#### NUMA (Non-Uniform Memory Access)

Pour les systèmes avec plusieurs processeurs physiques, VirtualBox peut exposer la topologie NUMA à la VM.

```bash
# Activer NUMA (VM éteinte)
VBoxManage modifyvm "HPC-VM" --numa on

# Définir le nombre de nœuds NUMA (doit diviser le nombre de CPUs)
VBoxManage modifyvm "HPC-VM" --cpus 8 --numa on
```

> [!info] Quand utiliser NUMA ?
> 
> - Serveurs avec plusieurs sockets CPU
> - Applications optimisées NUMA (bases de données, HPC)
> - VMs avec 8+ vCPUs
> - Améliore les performances en réduisant la latence mémoire

#### Configuration combinée optimale

```bash
# Exemple : VM de production haute performance
VBoxManage modifyvm "ProductionDB" \
    --memory 16384 \
    --cpus 8 \
    --cpuexecutioncap 100 \
    --cpuhotplug on \
    --pae on \
    --numa on

# Bandwidth groups
VBoxManage bandwidthctl "ProductionDB" add "DB-Storage" --type disk --limit 500M

# Attacher les disques
VBoxManage storageattach "ProductionDB" \
    --storagectl "NVMe" --port 0 --device 0 \
    --type hdd --medium "/storage/db-system.vdi" \
    --bandwidthgroup "DB-Storage"

# Démarrer avec priorité élevée (Linux)
nice -n -5 VBoxManage startvm "ProductionDB" --type headless
```

> [!example] Scénarios d'usage courants
> 
> **1. VM de développement économe en ressources**
> 
> ```bash
> VBoxManage modifyvm "DevVM" --memory 2048 --cpus 2 --cpuexecutioncap 40
> VBoxManage bandwidthctl "DevVM" add "Dev-Disk" --type disk --limit 50M
> nice -n 10 VBoxManage startvm "DevVM" --type headless
> ```
> 
> **2. VM de test avec ressources limitées (simulation)**
> 
> ```bash
> VBoxManage modifyvm "TestVM" --memory 1024 --cpus 1 --cpuexecutioncap 30
> VBoxManage bandwidthctl "TestVM" add "Slow-Disk" --type disk --limit 10M
> VBoxManage bandwidthctl "TestVM" add "Slow-Net" --type network --limit 5M
> ```
> 
> **3. VM de production optimisée**
> 
> ```bash
> VBoxManage modifyvm "ProdVM" --memory 8192 --cpus 4 --cpuexecutioncap 100
> VBoxManage bandwidthctl "ProdVM" add "Fast-Storage" --type disk --limit 300M
> nice -n -5 VBoxManage startvm "ProdVM" --type headless
> ```

---

## 🎯 Pièges courants et bonnes pratiques

### ❌ Erreurs fréquentes

1. **Sur-allocation de ressources**
    
    ```bash
    # ❌ MAUVAIS : Allouer toute la RAM
    VBoxManage modifyvm "VM" --memory 32000  # Sur un système avec 32 Go
    
    # ✅ BON : Laisser de la marge pour l'hôte
    VBoxManage modifyvm "VM" --memory 24000  # 75% de la RAM
    ```
    
2. **Oublier l'Execution Cap lors de tests**
    
    ```bash
    # ❌ MAUVAIS : Tester sans limitation
    VBoxManage modifyvm "TestVM" --cpus 8 --cpuexecutioncap 100
    
    # ✅ BON : Limiter pour ne pas perturber l'hôte
    VBoxManage modifyvm "TestVM" --cpus 2 --cpuexecutioncap 50
    ```
    
3. **Bandwidth Groups mal configurés**
    
    ```bash
    # ❌ MAUVAIS : Limite trop basse
    VBoxManage bandwidthctl "VM" add "Storage" --type disk --limit 1M
    
    # ✅ BON : Limite réaliste
    VBoxManage bandwidthctl "VM" add "Storage" --type disk --limit 100M
    ```
    

### ✅ Checklist avant production

- [ ] RAM : Maximum 75% de la RAM physique allouée (toutes VMs combinées)
- [ ] CPU : Pas plus de vCPUs que de cœurs physiques disponibles
- [ ] Execution Cap : 100% pour production, 40-70% pour développement
- [ ] Bandwidth Groups : Créés et testés pour tous les disques critiques
- [ ] Priorité : Définie selon l'importance de la VM
- [ ] NUMA : Activé pour VMs avec 8+ vCPUs sur systèmes multi-socket
- [ ] Monitoring : Métriques activées pour surveiller l'utilisation réelle

---

## 📊 Tableau récapitulatif des commandes

|Objectif|Commande|Notes|
|---|---|---|
|Définir RAM|`modifyvm --memory <Mo>`|VM éteinte|
|Définir CPUs|`modifyvm --cpus <nombre>`|VM éteinte|
|Limiter CPU %|`modifyvm --cpuexecutioncap <1-100>`|VM éteinte|
|Créer Bandwidth Group|`bandwidthctl add <nom> --type disk/network --limit <valeur>`|VM éteinte ou active|
|Attacher groupe au disque|`storageattach --bandwidthgroup <nom>`|VM éteinte|
|Attacher groupe au réseau|`modifyvm --nicbandwidthgroup1 <nom>`|VM éteinte|
|Hot-plug CPU|`controlvm plugcpu/unplugcpu <index>`|VM en cours d'exécution|
|Activer NUMA|`modifyvm --numa on`|VM éteinte|
|Surveiller métriques|`metrics query <VM>`|VM en cours d'exécution|

---

> [!tip] 💡 Conseil final La gestion efficace des ressources est un équilibre entre performance et stabilité. Commencez toujours avec des valeurs conservatrices, surveillez l'utilisation réelle, puis ajustez progressivement. Une VM qui utilise 50% de ses ressources allouées est mieux configurée qu'une VM qui en utilise 100% constamment.