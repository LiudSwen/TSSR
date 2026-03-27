

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

La configuration réseau est un aspect crucial de la gestion des machines virtuelles. VirtualBox offre une flexibilité considérable via la CLI pour configurer précisément chaque aspect du réseau : du type de carte virtuelle utilisée à la limitation de bande passante, en passant par la simulation de déconnexions réseau.

Cette partie se concentre sur les paramètres réseau au niveau des cartes individuelles via la commande `VBoxManage modifyvm`, permettant un contrôle fin de chaque interface réseau de vos VMs.

> [!info] Pré-requis La VM doit être éteinte (état `poweroff`) pour modifier la plupart des paramètres réseau, sauf indication contraire (comme le cable connected/disconnected).

---

## Configuration réseau avec modifyvm

### Syntaxe générale

La commande `modifyvm` permet de modifier les paramètres d'une VM, incluant sa configuration réseau. Pour le réseau, la syntaxe suit ce pattern :

```bash
VBoxManage modifyvm <nom-vm|uuid> --nic<N> <mode> [options]
```

Où :

- `<N>` : numéro de la carte réseau (1 à 8)
- `<mode>` : mode réseau (nat, bridged, intnet, hostonly, natnetwork, generic, null, none)
- `[options]` : paramètres spécifiques à configurer

### Les 8 cartes réseau disponibles

VirtualBox permet de configurer jusqu'à **8 cartes réseau** par VM (nic1 à nic8). Chaque carte peut avoir une configuration indépendante.

```bash
# Exemple : configurer plusieurs cartes sur une même VM
VBoxManage modifyvm "MaVM" --nic1 nat               # Carte 1 en NAT
VBoxManage modifyvm "MaVM" --nic2 bridged           # Carte 2 en Bridge
VBoxManage modifyvm "MaVM" --nic3 intnet            # Carte 3 en réseau interne
VBoxManage modifyvm "MaVM" --nic4 none              # Carte 4 désactivée
```

> [!tip] Bonne pratique Activez uniquement les cartes nécessaires. Les cartes inutilisées consomment des ressources, même minimes.

---

## Adresses MAC

### Pourquoi configurer l'adresse MAC

L'adresse MAC (Media Access Control) est l'identifiant unique d'une interface réseau. Dans un contexte de virtualisation, la configuration de l'adresse MAC peut être nécessaire pour :

- **Licences logicielles** : certains logiciels se lient à l'adresse MAC
- **Serveurs DHCP** : pour attribuer toujours la même IP (réservation DHCP)
- **Sécurité réseau** : filtrage MAC sur les switches/routeurs
- **Clonage de VMs** : éviter les conflits d'adresses MAC identiques
- **Tests réseau** : simuler des équipements spécifiques

### Configuration des adresses MAC

#### Consulter l'adresse MAC actuelle

```bash
# Voir toutes les infos réseau d'une VM
VBoxManage showvminfo "MaVM" | grep MAC

# Résultat exemple :
# NIC 1:           MAC: 080027B8C9A1, Attachment: NAT, Cable connected: on
```

#### Définir une adresse MAC personnalisée

```bash
# Syntaxe générale
VBoxManage modifyvm "MaVM" --macaddress<N> <adresse-mac>

# Exemple : définir l'adresse MAC de la carte 1
VBoxManage modifyvm "MaVM" --macaddress1 080027B8C9A1

# Exemple : définir l'adresse MAC de la carte 2
VBoxManage modifyvm "MaVM" --macaddress2 080027AABBCC
```

> [!warning] Format de l'adresse MAC
> 
> - L'adresse doit être en **12 chiffres hexadécimaux** consécutifs (sans séparateurs)
> - Format : `XXXXXXXXXXXX` (pas de `:` ni de `-`)
> - Les 3 premiers octets devraient commencer par `080027` (identifiant VirtualBox) pour éviter les conflits

#### Générer automatiquement une adresse MAC

```bash
# VirtualBox génère automatiquement une nouvelle adresse MAC
VBoxManage modifyvm "MaVM" --macaddress1 auto
```

> [!example] Exemple pratique : Clonage de VM Lors du clonage d'une VM, il est impératif de régénérer les adresses MAC pour éviter les conflits réseau.
> 
> ```bash
> # Cloner une VM
> VBoxManage clonevm "VMSource" --name "VMClone" --register
> 
> # Régénérer les adresses MAC de toutes les cartes
> VBoxManage modifyvm "VMClone" --macaddress1 auto
> VBoxManage modifyvm "VMClone" --macaddress2 auto
> ```

#### Réinitialiser l'adresse MAC

Pour revenir à l'adresse MAC par défaut générée par VirtualBox :

```bash
VBoxManage modifyvm "MaVM" --macaddress1 auto
```

---

## Type de carte réseau

Le type de carte réseau définit le matériel réseau virtuel émulé ou paravirtualisé présenté au système d'exploitation invité. Ce choix impacte les performances et la compatibilité.

### Types disponibles

VirtualBox supporte plusieurs types de cartes réseau virtuelles :

|Type|Description|Cas d'usage|
|---|---|---|
|**Am79C970A**|AMD PCNet PCI II (lance)|Anciens OS (Windows 9x, très vieux Linux)|
|**Am79C973**|AMD PCNet FAST III (default)|Compatibilité large, performances correctes|
|**82540EM**|Intel PRO/1000 MT Desktop (e1000)|Windows Vista+, Linux modernes|
|**82543GC**|Intel PRO/1000 T Server (e1000)|Serveurs, meilleure performance que 82540EM|
|**82545EM**|Intel PRO/1000 MT Server (e1000)|Alternative serveur|
|**virtio-net**|Paravirtualized network adapter|**Meilleure performance**, nécessite drivers|

### Comparaison des types

> [!info] Performances **virtio-net** > Intel 82545EM ≈ 82543GC > Intel 82540EM > AMD PCNet
> 
> Virtio offre les meilleures performances car c'est une interface paravirtualisée (pas d'émulation matérielle complète).

**Tableau comparatif détaillé :**

|Critère|AMD PCNet|Intel e1000|Virtio-net|
|---|---|---|---|
|Performance|⭐⭐|⭐⭐⭐|⭐⭐⭐⭐⭐|
|Compatibilité|⭐⭐⭐⭐⭐|⭐⭐⭐⭐|⭐⭐|
|Support ancien OS|Oui|Limité|Non|
|Support moderne|Basique|Bon|Excellent|
|Drivers requis|Généralement intégrés|Intégrés dans OS modernes|Guest Additions requis|

### Configuration du type de carte

#### Syntaxe

```bash
VBoxManage modifyvm "MaVM" --nictype<N> <type>
```

Où `<type>` peut être : `Am79C970A`, `Am79C973`, `82540EM`, `82543GC`, `82545EM`, `virtio`

#### Exemples pratiques

```bash
# Carte 1 : Intel PRO/1000 MT Desktop (bon compromis)
VBoxManage modifyvm "MaVM" --nictype1 82540EM

# Carte 2 : Virtio pour performance maximale (Linux moderne)
VBoxManage modifyvm "MaVM" --nictype2 virtio

# Carte 3 : AMD PCNet pour ancien OS
VBoxManage modifyvm "MaVM" --nictype3 Am79C973
```

> [!tip] Choix recommandés selon l'OS invité
> 
> - **Linux moderne (kernel 2.6.25+)** : `virtio` (nécessite virtio-net driver)
> - **Windows 7/8/10/11** : `82540EM` ou `82545EM` (drivers intégrés)
> - **Windows XP/2003** : `82540EM` (avec drivers Intel)
> - **Windows 9x/ME** : `Am79C970A` ou `Am79C973`
> - **BSD/Solaris** : `82545EM` ou `virtio`

#### Vérifier le type de carte actuel

```bash
VBoxManage showvminfo "MaVM" | grep "NIC"

# Résultat exemple :
# NIC 1:           MAC: 080027B8C9A1, Attachment: NAT, Cable connected: on, Type: 82540EM
```

> [!warning] Changement de type de carte Changer le type de carte peut nécessiter une reconfiguration réseau dans l'OS invité, car celui-ci détectera une "nouvelle" carte réseau avec potentiellement de nouveaux drivers.

---

## Cable Connected/Disconnected

### Concept et utilité

Le paramètre "cable connected" simule la connexion/déconnexion physique d'un câble réseau. C'est l'équivalent virtuel de débrancher le câble Ethernet d'une carte réseau réelle.

**Cas d'usage :**

- **Tests de résilience réseau** : vérifier comment une application réagit à une perte réseau
- **Simulations de pannes** : formation et tests de procédures de récupération
- **Isolation temporaire** : couper le réseau sans désactiver complètement la carte
- **Économie de ressources** : désactiver temporairement le réseau sans modifier la configuration
- **Sécurité** : isoler rapidement une VM compromise

> [!info] Différence avec --nic none
> 
> - `--cableconnected off` : la carte existe mais est "débranchée" (visible par l'OS)
> - `--nic none` : la carte n'existe pas du tout pour la VM

### Configuration du câble

#### Syntaxe

```bash
VBoxManage modifyvm "MaVM" --cableconnected<N> on|off
```

#### Particularité importante

> [!tip] Modification à chaud Contrairement à la plupart des paramètres réseau, `--cableconnected` peut être modifié **pendant que la VM est en cours d'exécution** (VM running).

#### Exemples pratiques

```bash
# Déconnecter le câble de la carte 1 (VM éteinte ou en cours)
VBoxManage modifyvm "MaVM" --cableconnected1 off

# Reconnecter le câble de la carte 1
VBoxManage modifyvm "MaVM" --cableconnected1 on

# Vérifier l'état du câble
VBoxManage showvminfo "MaVM" | grep "Cable connected"
# Résultat : Cable connected: off
```

#### Simulation de panne réseau à chaud

```bash
# VM en cours d'exécution
VBoxManage list runningvms
# "ServeurWeb" {12345678-1234-1234-1234-123456789012}

# Simuler une coupure réseau
VBoxManage modifyvm "ServeurWeb" --cableconnected1 off

# Attendre 10 secondes
sleep 10

# Restaurer la connexion
VBoxManage modifyvm "ServeurWeb" --cableconnected1 on
```

> [!example] Script de test de résilience
> 
> ```bash
> #!/bin/bash
> VM_NAME="AppServeur"
> 
> echo "Test de résilience réseau..."
> for i in {1..5}; do
>     echo "Cycle $i - Déconnexion..."
>     VBoxManage modifyvm "$VM_NAME" --cableconnected1 off
>     sleep 30
>     
>     echo "Cycle $i - Reconnexion..."
>     VBoxManage modifyvm "$VM_NAME" --cableconnected1 on
>     sleep 60
> done
> ```

---

## Bandwidth Groups

### Concept et utilité

Les **Bandwidth Groups** (groupes de bande passante) permettent de **limiter et contrôler le débit réseau** des machines virtuelles. Un groupe de bande passante définit une limite de débit partagée entre toutes les cartes réseau qui lui sont associées.

**Avantages :**

- **Simulation de conditions réseaux réelles** : tester une application avec une bande passante limitée (3G, 4G, ADSL)
- **Contrôle de ressources** : éviter qu'une VM monopolise toute la bande passante de l'hôte
- **Tests de performance** : valider le comportement d'une application en conditions dégradées
- **Équité réseau** : répartir équitablement la bande passante entre plusieurs VMs
- **Environnements multi-tenants** : garantir un quota de bande passante par client/projet

> [!info] Fonctionnement Un bandwidth group définit deux limites :
> 
> - **Upload** (émission) : limite de débit sortant en KB/s ou MB/s
> - **Download** (réception) : limite de débit entrant en KB/s ou MB/s
> 
> Ces limites sont partagées entre toutes les cartes réseau associées au groupe.

### Création d'un groupe de bande passante

#### Syntaxe

```bash
VBoxManage bandwidthctl "MaVM" add <nom-groupe> --type network --limit <valeur>[k|m|g]
```

Où :

- `<nom-groupe>` : nom unique du groupe (ex: "LimitADSL", "Quota3G")
- `--type network` : type de groupe (toujours "network" pour le réseau)
- `--limit` : limite de débit avec unité
    - `k` : KB/s (kilooctets par seconde)
    - `m` ou `M` : MB/s (mégaoctets par seconde)
    - `g` ou `G` : GB/s (gigaoctets par seconde)

#### Exemples de création

```bash
# Groupe simulant une connexion ADSL (1 Mb/s = 128 KB/s)
VBoxManage bandwidthctl "MaVM" add "ADSL" --type network --limit 128k

# Groupe simulant du 3G (384 Kb/s = 48 KB/s)
VBoxManage bandwidthctl "MaVM" add "3G" --type network --limit 48k

# Groupe limitant à 10 MB/s (Fast Ethernet partagé)
VBoxManage bandwidthctl "MaVM" add "FastEthernet" --type network --limit 10m

# Groupe avec limite élevée (100 MB/s)
VBoxManage bandwidthctl "MaVM" add "HighSpeed" --type network --limit 100m
```

> [!warning] Unités de mesure Attention à la confusion entre bits et octets :
> 
> - **Réseau** : généralement mesuré en **bits par seconde** (Kb/s, Mb/s)
> - **VirtualBox** : limite en **octets par seconde** (KB/s, MB/s)
> 
> **Conversion** : 1 octet = 8 bits
> 
> - 1 Mb/s (megabit) = 128 KB/s (kilooctet)
> - 10 Mb/s = 1.25 MB/s
> - 100 Mb/s = 12.5 MB/s

#### Tableau de conversion pratique

|Type de connexion|Débit (bits/s)|Limite VirtualBox|
|---|---|---|
|Modem 56k|56 Kb/s|7k|
|ADSL basique|1 Mb/s|128k|
|ADSL moyen|8 Mb/s|1m|
|ADSL haut|20 Mb/s|2500k ou 2.5m|
|3G|384 Kb/s|48k|
|4G|10-50 Mb/s|1250k - 6250k|
|Fast Ethernet|100 Mb/s|12m ou 12500k|
|Gigabit Ethernet|1 Gb/s|125m|

### Association à une carte réseau

Une fois un groupe créé, il faut l'associer à une ou plusieurs cartes réseau.

#### Syntaxe

```bash
VBoxManage modifyvm "MaVM" --nicbandwidthgroup<N> <nom-groupe>|none
```

#### Exemples d'association

```bash
# Associer la carte 1 au groupe "ADSL"
VBoxManage modifyvm "MaVM" --nicbandwidthgroup1 "ADSL"

# Associer la carte 2 au groupe "3G"
VBoxManage modifyvm "MaVM" --nicbandwidthgroup2 "3G"

# Retirer la limitation de la carte 1
VBoxManage modifyvm "MaVM" --nicbandwidthgroup1 none
```

> [!example] Configuration complète d'une VM avec limitation
> 
> ```bash
> # 1. Créer la VM et configurer le réseau
> VBoxManage modifyvm "ServeurTest" --nic1 nat
> VBoxManage modifyvm "ServeurTest" --nictype1 82540EM
> 
> # 2. Créer un groupe de bande passante (simule ADSL 2 Mb/s)
> VBoxManage bandwidthctl "ServeurTest" add "SimulADSL" --type network --limit 256k
> 
> # 3. Associer la carte réseau au groupe
> VBoxManage modifyvm "ServeurTest" --nicbandwidthgroup1 "SimulADSL"
> 
> # 4. Vérifier la configuration
> VBoxManage showvminfo "ServeurTest" | grep -A 5 "NIC 1"
> ```

### Gestion des groupes

#### Lister les groupes existants

```bash
VBoxManage bandwidthctl "MaVM" list

# Résultat exemple :
# Name:       ADSL
# Type:       Network
# Limit:      128000 KB/s
#
# Name:       3G
# Type:       Network
# Limit:      48000 KB/s
```

#### Modifier la limite d'un groupe

```bash
# Changer la limite du groupe "ADSL" à 256 KB/s
VBoxManage bandwidthctl "MaVM" set "ADSL" --limit 256k

# Augmenter la limite du groupe "3G" à 1 MB/s (simule 4G)
VBoxManage bandwidthctl "MaVM" set "3G" --limit 1m
```

> [!tip] Modification dynamique Les modifications de limite peuvent être effectuées **pendant que la VM est en cours d'exécution**, permettant des tests dynamiques de dégradation/amélioration réseau.

#### Supprimer un groupe

```bash
# Supprimer le groupe "ADSL"
VBoxManage bandwidthctl "MaVM" remove "ADSL"
```

> [!warning] Suppression de groupe en cours d'utilisation Vous ne pouvez pas supprimer un groupe associé à une carte réseau. Dissociez d'abord toutes les cartes :
> 
> ```bash
> # 1. Dissocier toutes les cartes du groupe
> VBoxManage modifyvm "MaVM" --nicbandwidthgroup1 none
> 
> # 2. Supprimer le groupe
> VBoxManage bandwidthctl "MaVM" remove "ADSL"
> ```

#### Groupes partagés entre plusieurs cartes

Un même groupe peut être partagé entre plusieurs cartes réseau. La limite est alors **partagée** entre toutes les cartes.

```bash
# Créer un groupe avec limite de 5 MB/s
VBoxManage bandwidthctl "MaVM" add "SharedLimit" --type network --limit 5m

# Associer 3 cartes au même groupe
VBoxManage modifyvm "MaVM" --nicbandwidthgroup1 "SharedLimit"
VBoxManage modifyvm "MaVM" --nicbandwidthgroup2 "SharedLimit"
VBoxManage modifyvm "MaVM" --nicbandwidthgroup3 "SharedLimit"

# Résultat : les 3 cartes se partagent les 5 MB/s
```

> [!info] Comportement du partage Si une carte utilise 3 MB/s, les deux autres ne pourront se partager que les 2 MB/s restants. C'est utile pour simuler un lien partagé ou limiter globalement une VM multi-interfaces.

---

## Scénarios pratiques

### Scénario 1 : Configuration d'un serveur web de test

Objectif : créer un serveur web avec réseau NAT, performances optimisées, et limitation de bande passante pour tester en conditions réelles.

```bash
VM_NAME="WebServer"

# Configuration réseau de base
VBoxManage modifyvm "$VM_NAME" --nic1 nat
VBoxManage modifyvm "$VM_NAME" --nictype1 virtio          # Performance max (Linux)
VBoxManage modifyvm "$VM_NAME" --macaddress1 auto        # MAC unique

# Limitation bande passante (simule connexion serveur mutualisé)
VBoxManage bandwidthctl "$VM_NAME" add "ServerLimit" --type network --limit 50m
VBoxManage modifyvm "$VM_NAME" --nicbandwidthgroup1 "ServerLimit"

# Vérification
VBoxManage showvminfo "$VM_NAME" | grep -E "NIC 1|Bandwidth"
```

### Scénario 2 : VM multi-homed (plusieurs réseaux)

Objectif : VM avec 3 cartes réseau différentes pour tester le routage.

```bash
VM_NAME="Router"

# Carte 1 : Internet (NAT)
VBoxManage modifyvm "$VM_NAME" --nic1 nat
VBoxManage modifyvm "$VM_NAME" --nictype1 82540EM
VBoxManage modifyvm "$VM_NAME" --macaddress1 080027000001

# Carte 2 : LAN interne (intnet)
VBoxManage modifyvm "$VM_NAME" --nic2 intnet
VBoxManage modifyvm "$VM_NAME" --nictype2 82540EM
VBoxManage modifyvm "$VM_NAME" --macaddress2 080027000002

# Carte 3 : DMZ (intnet séparé)
VBoxManage modifyvm "$VM_NAME" --nic3 intnet
VBoxManage modifyvm "$VM_NAME" --nictype3 82540EM
VBoxManage modifyvm "$VM_NAME" --macaddress3 080027000003

# Désactiver les cartes 4-8 (économie ressources)
for i in {4..8}; do
    VBoxManage modifyvm "$VM_NAME" --nic$i none
done
```

### Scénario 3 : Test de résilience avec coupures réseau

Script de test automatisé simulant des coupures réseau aléatoires.

```bash
#!/bin/bash
VM_NAME="AppTest"
DUREE_TEST=300  # 5 minutes

echo "Démarrage test résilience réseau..."
VBoxManage startvm "$VM_NAME" --type headless

sleep 30  # Attendre démarrage complet

TEMPS_DEBUT=$(date +%s)
while [ $(($(date +%s) - TEMPS_DEBUT)) -lt $DUREE_TEST ]; do
    # Coupure aléatoire (10-30 secondes)
    DUREE_COUPURE=$((RANDOM % 20 + 10))
    
    echo "[$(date +%H:%M:%S)] Coupure réseau pendant ${DUREE_COUPURE}s"
    VBoxManage modifyvm "$VM_NAME" --cableconnected1 off
    sleep $DUREE_COUPURE
    
    # Connexion aléatoire (30-60 secondes)
    DUREE_CONNEXION=$((RANDOM % 30 + 30))
    
    echo "[$(date +%H:%M:%S)] Réseau rétabli pendant ${DUREE_CONNEXION}s"
    VBoxManage modifyvm "$VM_NAME" --cableconnected1 on
    sleep $DUREE_CONNEXION
done

echo "Test terminé."
VBoxManage modifyvm "$VM_NAME" --cableconnected1 on
```

### Scénario 4 : Configuration progressive de bande passante

Simuler une montée en charge progressive du réseau.

```bash
VM_NAME="LoadTest"

# Configuration initiale
VBoxManage modifyvm "$VM_NAME" --nic1 nat
VBoxManage modifyvm "$VM_NAME" --nictype1 virtio

# Créer groupe de bande passante initial (128 KB/s - ADSL lent)
VBoxManage bandwidthctl "$VM_NAME" add "Progressive" --type network --limit 128k
VBoxManage modifyvm "$VM_NAME" --nicbandwidthgroup1 "Progressive"

# Démarrer la VM
VBoxManage startvm "$VM_NAME" --type headless
sleep 30

# Augmentation progressive toutes les 60 secondes
echo "Phase 1: 128 KB/s (ADSL basique)"
sleep 60

echo "Phase 2: 1 MB/s (ADSL moyen)"
VBoxManage bandwidthctl "$VM_NAME" set "Progressive" --limit 1m
sleep 60

echo "Phase 3: 5 MB/s (ADSL++ / Fibre entrée)"
VBoxManage bandwidthctl "$VM_NAME" set "Progressive" --limit 5m
sleep 60

echo "Phase 4: 12 MB/s (Fast Ethernet)"
VBoxManage bandwidthctl "$VM_NAME" set "Progressive" --limit 12m
sleep 60

echo "Phase 5: 50 MB/s (Quasi-Gigabit)"
VBoxManage bandwidthctl "$VM_NAME" set "Progressive" --limit 50m

echo "Test terminé - bande passante finale: 50 MB/s"
```

### Scénario 5 : Clonage avec reconfiguration réseau complète

Cloner une VM et reconfigurer entièrement son réseau pour éviter conflits.

```bash
VM_SOURCE="Template"
VM_CLONE="Prod-Server-01"

# Clonage
VBoxManage clonevm "$VM_SOURCE" --name "$VM_CLONE" --register

# Régénération MAC addresses (éviter conflits)
VBoxManage modifyvm "$VM_CLONE" --macaddress1 auto
VBoxManage modifyvm "$VM_CLONE" --macaddress2 auto

# Changement type carte pour performance
VBoxManage modifyvm "$VM_CLONE" --nictype1 virtio
VBoxManage modifyvm "$VM_CLONE" --nictype2 virtio

# Configuration bande passante production
VBoxManage bandwidthctl "$VM_CLONE" add "Production" --type network --limit 100m
VBoxManage modifyvm "$VM_CLONE" --nicbandwidthgroup1 "Production"

# Vérification finale
echo "=== Configuration réseau de $VM_CLONE ==="
VBoxManage showvminfo "$VM_CLONE" | grep -E "NIC|MAC|Bandwidth"
```

---

> [!tip] 💡 Astuces finales
> 
> - Utilisez `virtio` pour les OS qui le supportent (meilleures performances)
> - Testez toujours après avoir changé le type de carte (drivers différents)
> - Les bandwidth groups peuvent être modifiés à chaud pour des tests dynamiques
> - Utilisez `--cableconnected off/on` pour tester la résilience sans modifier la configuration
> - Documentez vos adresses MAC personnalisées pour éviter les conflits
> - Pour le clonage, générez toujours de nouvelles MAC avec `auto`

> [!warning] ⚠️ Pièges courants
> 
> - Oublier de dissocier les cartes avant de supprimer un bandwidth group
> - Confondre bits/s (réseau) et octets/s (VirtualBox) pour les limites
> - Changer le type de carte sans vérifier la disponibilité des drivers dans l'OS
> - Ne pas régénérer les MAC lors du clonage → conflits réseau
> - Modifier les paramètres réseau (sauf cable) sur une VM en cours d'exécution → erreur