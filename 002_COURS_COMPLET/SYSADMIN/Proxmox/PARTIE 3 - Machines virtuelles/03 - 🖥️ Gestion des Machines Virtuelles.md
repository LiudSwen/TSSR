

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

## 🔄 Démarrage, Arrêt et Redémarrage

### Comprendre les états d'une VM

Une machine virtuelle dans Proxmox peut se trouver dans différents états :

|État|Description|Action possible|
|---|---|---|
|**Stopped**|VM éteinte, consomme 0 ressource|Démarrage|
|**Running**|VM active, consomme ressources|Arrêt, Redémarrage, Pause|
|**Paused**|VM suspendue en mémoire|Reprise, Arrêt|

> [!info] Pourquoi gérer les états ? La gestion des états permet d'économiser les ressources, de planifier la maintenance et d'optimiser les performances du cluster.

### Démarrage d'une VM

#### Via l'interface Web

1. Sélectionner la VM dans l'arborescence
2. Cliquer sur **Start** dans le menu supérieur
3. La VM démarre et charge son système d'exploitation

#### Via la ligne de commande

```bash
# Démarrer une VM
qm start <vmid>

# Exemple : démarrer la VM 100
qm start 100

# Démarrer avec des options
qm start 100 --skiplock  # Ignore les verrous éventuels
```

> [!tip] Démarrage automatique Vous pouvez configurer une VM pour qu'elle démarre automatiquement au boot du serveur Proxmox via l'onglet **Options** > **Start at boot**.

### Arrêt d'une VM

Il existe plusieurs méthodes d'arrêt, chacune avec ses spécificités :

#### Arrêt propre (Shutdown)

```bash
# Arrêt propre via ACPI
qm shutdown <vmid>

# Exemple avec timeout
qm shutdown 100 --timeout 60  # Attend 60 secondes max
```

> [!info] Fonctionnement du Shutdown Envoie un signal ACPI au système invité qui déclenche l'arrêt normal (équivalent à un arrêt depuis le système). Le système ferme proprement ses applications et services.

#### Arrêt forcé (Stop)

```bash
# Arrêt immédiat sans attendre
qm stop <vmid>

# Stop avec confirmation forcée
qm stop 100 --skiplock
```

> [!warning] Attention avec Stop Cette commande coupe immédiatement l'alimentation de la VM (équivalent à débrancher le câble). Risque de corruption de données ou de filesystem. À utiliser uniquement si shutdown ne fonctionne pas.

#### Différence entre Shutdown et Stop

|Méthode|Type|Sécurité|Délai|Utilisation|
|---|---|---|---|---|
|**Shutdown**|Arrêt propre|✅ Sûr|Quelques secondes|Par défaut|
|**Stop**|Arrêt brutal|⚠️ Risqué|Immédiat|Urgence uniquement|

### Redémarrage d'une VM

```bash
# Redémarrage propre
qm reboot <vmid>

# Exemple
qm reboot 100

# Redémarrage avec timeout
qm reboot 100 --timeout 120
```

> [!tip] Astuce de redémarrage Pour un redémarrage garanti même si la VM ne répond pas :
> 
> ```bash
> qm shutdown 100 --timeout 30 && qm start 100
> ```

### Options avancées de gestion

#### Pause et Resume

```bash
# Mettre en pause (suspend)
qm suspend <vmid>

# Reprendre depuis la pause
qm resume <vmid>
```

> [!info] Différence Pause vs Stop **Pause** conserve l'état RAM de la VM sur disque. Elle reprend exactement où elle s'était arrêtée. **Stop** éteint complètement la VM qui doit redémarrer depuis le début.

#### Reset (redémarrage brutal)

```bash
# Reset matériel
qm reset <vmid>
```

> [!warning] À éviter Reset force un redémarrage immédiat sans arrêt propre du système. Même risques que Stop.

---

## 🖥️ Console d'accès (noVNC, SPICE)

### Pourquoi utiliser la console ?

La console permet d'accéder à l'écran de la VM comme si vous étiez physiquement devant elle. Indispensable pour :

- Installation initiale d'OS
- Dépannage réseau (quand SSH ne fonctionne pas)
- Configuration BIOS/UEFI
- Récupération de mots de passe

### noVNC (Console par défaut)

#### Caractéristiques

|Avantage|Inconvénient|
|---|---|
|✅ Fonctionne directement dans le navigateur|❌ Légères latences|
|✅ Aucune installation nécessaire|❌ Performance limitée|
|✅ Compatible tous OS|❌ Pas de copier-coller natif|

#### Utilisation

1. Sélectionner la VM
2. Cliquer sur **Console** dans le menu
3. La console s'ouvre dans un nouvel onglet

> [!tip] Raccourcis clavier noVNC
> 
> - **Ctrl+Alt+Del** : Menu > Envoyer Ctrl+Alt+Del
> - **Plein écran** : Icône plein écran en bas à droite
> - **Ajustement d'échelle** : Options > Scaling Mode

#### Configuration via CLI

```bash
# Voir la configuration d'affichage
qm config <vmid> | grep vga

# Modifier le type d'affichage
qm set <vmid> -vga std  # Affichage standard
qm set <vmid> -vga qxl  # Meilleure performance (recommandé)
```

### SPICE (Simple Protocol for Independent Computing Environments)

#### Caractéristiques

|Avantage|Inconvénient|
|---|---|
|✅ Excellentes performances|❌ Nécessite un client installé|
|✅ Copier-coller bidirectionnel|❌ Configuration plus complexe|
|✅ Redirection USB|❌ Moins universel que noVNC|
|✅ Multi-écrans||

#### Installation du client SPICE

```bash
# Debian/Ubuntu
sudo apt install virt-viewer

# RedHat/CentOS/Fedora
sudo dnf install virt-viewer

# Windows : télécharger virt-viewer depuis le site officiel
# macOS : installer via Homebrew
brew install virt-viewer
```

#### Configuration d'une VM pour SPICE

```bash
# Activer SPICE pour une VM
qm set <vmid> -vga qxl
qm set <vmid> -agent 1  # Active l'agent QEMU pour plus de fonctionnalités

# Exemple complet
qm set 100 -vga qxl -agent 1
```

#### Utilisation de SPICE

1. Dans Proxmox Web UI, cliquer sur **Console** > **SPICE**
2. Télécharger le fichier `.vv`
3. Ouvrir avec virt-viewer

```bash
# Ou directement en ligne de commande
remote-viewer spice://PROXMOX_IP:PORT?password=XXXXXXX
```

> [!tip] Copier-coller avec SPICE Pour activer le copier-coller bidirectionnel, assurez-vous que l'agent QEMU est installé dans la VM :
> 
> ```bash
> # Dans la VM Debian/Ubuntu
> sudo apt install qemu-guest-agent
> sudo systemctl enable --now qemu-guest-agent
> ```

### Comparaison noVNC vs SPICE

|Critère|noVNC|SPICE|
|---|---|---|
|**Installation**|Aucune|Client requis|
|**Performance**|Correcte|Excellente|
|**Latence**|Moyenne|Faible|
|**Résolution**|Adaptative|Native|
|**Copier-coller**|Limité|Natif|
|**USB Redirect**|❌|✅|
|**Multi-écrans**|❌|✅|
|**Usage**|Dépannage rapide|Travail quotidien|

> [!info] Conseil d'utilisation
> 
> - **noVNC** : pour accès occasionnel, dépannage rapide, installation initiale
> - **SPICE** : pour administration régulière, meilleure expérience utilisateur

### Accès série (Serial Console)

Alternative à la console graphique, utile pour les systèmes headless :

```bash
# Activer la console série
qm set <vmid> -serial0 socket

# Se connecter
qm terminal <vmid>
```

> [!tip] Console série pour débogage La console série fonctionne même si le système graphique est cassé. Idéal pour récupérer un système qui ne boot plus en mode graphique.

---

## 📸 Snapshots

### Qu'est-ce qu'un Snapshot ?

Un snapshot est une **photographie instantanée** de l'état complet d'une VM à un moment T :

- État du disque
- Configuration de la VM
- Optionnellement : état de la RAM

> [!info] Cas d'usage des snapshots
> 
> - Avant une mise à jour critique
> - Avant modification de configuration
> - Point de sauvegarde avant tests
> - Création de points de restauration réguliers

### Fonctionnement technique

Les snapshots Proxmox utilisent la technologie **QCOW2 COW** (Copy-On-Write) :

- Le snapshot stocke uniquement les **différences** depuis sa création
- Pas de duplication complète du disque
- Performances légèrement réduites avec beaucoup de snapshots

> [!warning] Attention aux performances Chaque snapshot ajoute une couche de lecture. Plus de 3-4 snapshots peuvent impacter les performances d'I/O.

### Créer un Snapshot

#### Via l'interface Web

1. Sélectionner la VM
2. Onglet **Snapshots**
3. Cliquer sur **Take Snapshot**
4. Renseigner :
    - **Name** : nom du snapshot
    - **Description** : contexte/raison
    - **Include RAM** : cocher pour sauvegarder l'état RAM

#### Via CLI

```bash
# Snapshot simple (disque uniquement)
qm snapshot <vmid> <snapshot_name>

# Exemple
qm snapshot 100 avant_update_kernel

# Snapshot avec description
qm snapshot 100 avant_update --description "Avant mise à jour Ubuntu 24.04"

# Snapshot incluant la RAM (VM doit être running)
qm snapshot 100 avec_ram --vmstate 1
```

> [!info] Snapshot avec RAM Un snapshot avec RAM permet de restaurer la VM exactement dans son état d'exécution (applications ouvertes, sessions actives). Utile mais plus lourd en stockage.

### Restaurer un Snapshot

#### Via l'interface Web

1. Onglet **Snapshots**
2. Sélectionner le snapshot
3. Cliquer sur **Rollback**
4. Confirmer l'action

> [!warning] Rollback destructif Le rollback **écrase** l'état actuel de la VM. Toutes les modifications depuis le snapshot sont **perdues définitivement**.

#### Via CLI

```bash
# Restaurer un snapshot
qm rollback <vmid> <snapshot_name>

# Exemple
qm rollback 100 avant_update_kernel

# Restaurer et démarrer automatiquement
qm rollback 100 avant_update && qm start 100
```

### Gérer les Snapshots

#### Lister les snapshots

```bash
# Lister tous les snapshots d'une VM
qm listsnapshot <vmid>

# Affichage détaillé
qm listsnapshot 100
```

#### Supprimer un snapshot

```bash
# Supprimer un snapshot spécifique
qm delsnapshot <vmid> <snapshot_name>

# Exemple
qm delsnapshot 100 ancien_snapshot
```

> [!tip] Suppression de snapshots La suppression d'un snapshot **fusionne** ses données avec le snapshot parent. Peut prendre du temps selon la taille des modifications.

### Arborescence de Snapshots

Proxmox permet de créer des **snapshots imbriqués** :

```
État initial
    ↓
Snapshot_1 (avant update)
    ↓
Snapshot_2 (après update, avant config)
    ↓
Snapshot_3 (après config)
```

> [!info] Navigation dans l'arborescence Vous pouvez revenir à n'importe quel point de l'arborescence. Les branches abandonnées sont automatiquement nettoyées.

### Bonnes pratiques

|✅ À faire|❌ À éviter|
|---|---|
|Nommer clairement les snapshots|Accumuler plus de 5 snapshots|
|Ajouter descriptions détaillées|Oublier de supprimer les anciens|
|Créer avant modifications importantes|Utiliser comme solution de backup|
|Supprimer après validation|Faire des snapshots de VM en production intensive|

> [!warning] Snapshots ≠ Backups Les snapshots sont sur le **même stockage** que la VM. En cas de panne du stockage, vous perdez tout. Pour la sauvegarde, utilisez le système de **Backup Proxmox** (partie différente du cours).

### Limites et contraintes

- **Espace disque** : les snapshots consomment de l'espace au fur et à mesure des modifications
- **Performances** : impact sur les I/O avec trop de snapshots
- **Dépendance** : ne peuvent être déplacés indépendamment de la VM
- **Suppression longue** : la fusion peut prendre du temps sur gros disques

---

## 🧬 Clonage

### Qu'est-ce que le clonage ?

Le clonage crée une **copie complète** d'une VM existante. Deux types :

- **Full Clone** : copie complète et indépendante
- **Linked Clone** : copie légère liée au disque source

> [!info] Cas d'usage du clonage
> 
> - Créer des environnements de test identiques
> - Déployer rapidement plusieurs serveurs similaires
> - Créer des templates réutilisables
> - Dupliquer une configuration complexe

### Full Clone (Clone complet)

#### Caractéristiques

|Avantage|Inconvénient|
|---|---|
|✅ Totalement indépendant|❌ Consomme espace disque complet|
|✅ Peut être migré séparément|❌ Création plus longue|
|✅ Pas de dépendance|❌ Plus coûteux en stockage|
|✅ Performances identiques à l'original||

#### Créer un Full Clone

##### Via l'interface Web

1. Sélectionner la VM source
2. Cliquer sur **Clone** (en haut à droite)
3. Configurer :
    - **VM ID** : nouveau numéro unique
    - **Name** : nom du clone
    - **Mode** : **Full Clone**
    - **Target Storage** : où stocker le clone
4. Cliquer sur **Clone**

##### Via CLI

```bash
# Syntaxe de base
qm clone <vmid_source> <vmid_nouveau> --name <nom> --full

# Exemple : cloner VM 100 vers VM 101
qm clone 100 101 --name "web-server-prod-clone" --full

# Cloner vers un stockage spécifique
qm clone 100 102 --name "db-server-test" --full --target local-lvm

# Cloner avec description
qm clone 100 103 --name "app-clone" --full --description "Clone pour tests"
```

> [!tip] Clonage et démarrage Le clone créé est **arrêté** par défaut. N'oubliez pas de le démarrer :
> 
> ```bash
> qm clone 100 101 --name "clone-1" --full && qm start 101
> ```

### Linked Clone (Clone lié)

#### Caractéristiques

|Avantage|Inconvénient|
|---|---|
|✅ Très rapide à créer|❌ Dépend de la VM source|
|✅ Économe en espace disque|❌ Ne peut être migré seul|
|✅ Idéal pour tests temporaires|❌ Source ne peut être supprimée|

#### Fonctionnement technique

Le Linked Clone utilise la VM source comme **base en lecture seule** :

- Le disque source devient un **backing file**
- Le clone stocke uniquement les **différences** (COW)
- Si vous modifiez le clone, seules ces modifications sont stockées

```
VM Source (backing file)
    ↓ (lecture seule)
Linked Clone 1 (+ différences)
Linked Clone 2 (+ différences)
```

#### Créer un Linked Clone

##### Via l'interface Web

1. Sélectionner la VM source
2. **Clone**
3. **Mode** : **Linked Clone**
4. **Clone**

##### Via CLI

```bash
# Créer un linked clone
qm clone <vmid_source> <vmid_nouveau> --name <nom>

# Exemple (pas de --full = linked clone par défaut)
qm clone 100 201 --name "test-env-1"

# Plusieurs clones liés depuis une même source
qm clone 100 202 --name "test-env-2"
qm clone 100 203 --name "test-env-3"
```

> [!warning] Dépendance critique Si vous supprimez la VM source, **tous les linked clones deviennent inutilisables**. Protégez toujours la source.

### Comparaison Full vs Linked Clone

|Critère|Full Clone|Linked Clone|
|---|---|---|
|**Vitesse de création**|Lente (copie complète)|Très rapide (instantané)|
|**Espace disque**|Taille complète|Minime au départ|
|**Indépendance**|Totale|Dépend de la source|
|**Performance**|Identique à l'original|Légèrement inférieure|
|**Migration**|Possible|Impossible seul|
|**Usage**|Production, long terme|Tests, développement|

### Workflow avec Templates

Pour un déploiement efficace, combinez clonage et templates :

1. **Créer un Template** (VM de base configurée)
2. **Cloner le template** pour créer de nouvelles VM
3. **Personnaliser** chaque clone

```bash
# 1. Convertir une VM en template
qm template <vmid>

# Exemple : convertir VM 100 en template
qm template 100

# 2. Cloner le template (full clone recommandé pour production)
qm clone 100 110 --name "web-server-01" --full
qm clone 100 111 --name "web-server-02" --full
```

> [!info] Template = VM en lecture seule Une fois convertie en template, la VM ne peut plus être démarrée. Elle sert uniquement de base pour le clonage.

### Gestion post-clonage

#### Changements nécessaires après clonage

Les clones héritent de **toute la configuration** de la source, y compris :

- **Adresse MAC** (automatiquement regénérée)
- **Hostname** (à changer manuellement)
- **Adresse IP** (si statique, à changer)
- **SSH Host Keys** (à régénérer)
- **Machine ID** (à régénérer)

```bash
# Dans le clone, régénérer les identifiants uniques

# Changer le hostname
sudo hostnamectl set-hostname nouveau-nom

# Régénérer SSH host keys
sudo rm /etc/ssh/ssh_host_*
sudo dpkg-reconfigure openssh-server

# Régénérer machine-id (systemd)
sudo rm /etc/machine-id
sudo systemd-machine-id-setup
```

> [!tip] Script de post-clonage Créez un script exécuté au premier démarrage du clone pour automatiser ces changements.

### Clonage entre storages

```bash
# Cloner d'un storage vers un autre
qm clone 100 120 --name "clone-autre-storage" --full --target autre-storage

# Voir les storages disponibles
pvesm status
```

---

## 🚚 Migration à froid

### Qu'est-ce que la migration ?

La migration consiste à **déplacer une VM** d'un nœud Proxmox vers un autre. Deux types :

- **Migration à froid** : VM arrêtée pendant le transfert
- **Migration à chaud** (live) : VM reste active (pas dans cette partie)

> [!info] Focus sur la migration à froid Cette section couvre uniquement la migration à froid. La migration à chaud (live migration) nécessite un cluster Proxmox configuré et sera abordée dans une autre partie du cours.

### Prérequis pour la migration

#### Configuration réseau

- Les deux nœuds doivent être **sur le même réseau**
- Possibilité de communication SSH entre nœuds
- Ports nécessaires ouverts (22 pour SSH, 8006 pour l'API)

#### Stockage

Deux scénarios possibles :

|Type de stockage|Description|Migration|
|---|---|---|
|**Stockage partagé**|NFS, Ceph, iSCSI|Migration simple (métadonnées uniquement)|
|**Stockage local**|local, local-lvm, ZFS local|Migration complète (transfert des disques)|

> [!warning] Migration avec stockage local Avec stockage local, **tous les disques** de la VM doivent être transférés. Peut prendre beaucoup de temps selon la taille et la bande passante réseau.

### Migration à froid via l'interface Web

#### Étapes de migration

1. **Arrêter la VM** si elle est en cours d'exécution
    
    ```bash
    qm shutdown <vmid>
    ```
    
2. Dans Proxmox Web UI :
    
    - Sélectionner la VM
    - Cliquer sur **Migrate** (menu en haut)
    - Configurer :
        - **Target node** : nœud de destination
        - **Target storage** : stockage cible (si différent)
    - Cliquer sur **Migrate**
3. Suivre la progression dans la fenêtre de tâches
    

> [!info] Fenêtre de tâches La progression de migration est visible dans l'onglet **Tasks** du nœud source ou dans la vue **Tasks** globale.

### Migration à froid via CLI

#### Syntaxe de base

```bash
# Migration simple (stockage partagé)
qm migrate <vmid> <target_node>

# Exemple : migrer VM 100 vers le nœud pve2
qm migrate 100 pve2
```

#### Migration avec stockage local

```bash
# Migration avec transfert de disque
qm migrate <vmid> <target_node> --targetstorage <storage_cible>

# Exemple : migrer vers pve2 avec stockage local-lvm
qm migrate 100 pve2 --targetstorage local-lvm

# Migration avec plusieurs disques vers différents storages
qm migrate 100 pve2 --targetstorage "scsi0:local-lvm,scsi1:local-zfs"
```

#### Options avancées

```bash
# Migration forcée (ignore certains avertissements)
qm migrate 100 pve2 --force

# Migration en ligne (nécessite VM arrêtée pour migration à froid)
qm migrate 100 pve2 --online 0

# Spécifier le stockage pour chaque disque
qm migrate 100 pve2 --targetstorage local-lvm --online 0
```

### Vérifications avant migration

#### Vérifier la configuration de la VM

```bash
# Voir la config complète
qm config <vmid>

# Vérifier les disques attachés
qm config 100 | grep -E '(scsi|ide|virtio)'

# Vérifier le stockage utilisé
pvesm status
```

#### Vérifier l'espace disponible sur la cible

```bash
# Se connecter au nœud cible et vérifier l'espace
ssh root@noeud-cible "df -h"

# Ou depuis Proxmox Web UI : Datacenter > Storage > voir l'usage
```

> [!warning] Vérifier l'espace Assurez-vous que le nœud cible a **suffisamment d'espace** pour accueillir les disques de la VM, surtout avec stockage local.

### Durée de migration

La durée dépend de plusieurs facteurs :

|Facteur|Impact|
|---|---|
|**Taille des disques**|Plus la VM est grosse, plus long|
|**Type de stockage**|Partagé = rapide, Local = lent|
|**Bande passante réseau**|1 Gbps vs 10 Gbps|
|**Charge du système**|I/O élevés ralentissent|

> [!tip] Estimation
> 
> - Stockage partagé : quelques secondes (métadonnées)
> - Stockage local 100 GB sur réseau 1 Gbps : ~15-20 minutes
> - Stockage local 500 GB sur réseau 10 Gbps : ~5-10 minutes

### Que se passe-t-il pendant la migration ?

1. **Vérifications préliminaires** : compatibilité, espace, réseau
2. **Verrouillage de la VM** : empêche modifications pendant transfert
3. **Transfert des données** :
    - Métadonnées de configuration
    - Disques (si stockage local)
4. **Enregistrement sur le nœud cible**
5. **Suppression sur le nœud source** (uniquement métadonnées si stockage partagé)

### Gestion d'erreurs de migration

#### Erreurs courantes

|Erreur|Cause|Solution|
|---|---|---|
|`storage not available`|Stockage cible inexistant|Créer ou spécifier un storage valide|
|`not enough space`|Espace insuffisant|Libérer de l'espace ou changer de cible|
|`migration aborted`|Problème réseau|Vérifier connectivité SSH entre nœuds|
|`VM is locked`|Migration précédente échouée|Débloquer avec `qm unlock <vmid>`|

#### Déblocage d'une VM

```bash
# Si une migration échoue et laisse la VM verrouillée
qm unlock <vmid>

# Exemple
qm unlock 100
```

> [!warning] Unlock avec précaution N'utilisez `unlock` que si vous êtes **certain** qu'aucune opération n'est en cours sur la VM.

### Migration et réseau

#### Conservation de la configuration réseau

Par défaut, la VM conserve :

- ✅ Configuration réseau (adresse IP, gateway)
- ✅ Interfaces réseau (nombre, type)
- ✅ Configuration bridge

> [!info] Vérifier les bridges Assurez-vous que les **mêmes bridges** (vmbr0, vmbr1...) existent sur le nœud cible avec la même configuration.

#### Adaptation post-migration

Si les bridges diffèrent entre nœuds :

```bash
# Modifier le bridge d'une interface après migration
qm set <vmid> -net0 virtio,bridge=<nouveau_bridge>

# Exemple : passer de vmbr0 à vmbr1
qm set 100 -net0 virtio,bridge=vmbr1
```

### Workflow de migration type

```bash
# 1. Arrêter la VM
qm shutdown 100

# 2. Vérifier que la VM est bien arrêtée
qm status 100

# 3. Migrer (avec stockage local)
qm migrate 100 pve2 --targetstorage local-lvm

# 4. Vérifier que la migration est terminée (sur le nœud cible)
ssh root@pve2 "qm list"

# 5. Démarrer la VM sur le nouveau nœud
ssh root@pve2 "qm start 100"

# 6. Vérifier le bon fonctionnement
ssh root@pve2 "qm status 100"
```

### Bonnes pratiques de migration

|✅ À faire|❌ À éviter|
|---|---|
|Arrêter proprement la VM avant|Migrer une VM en production sans test|
|Vérifier l'espace disque cible|Migrer pendant les heures de pointe|
|Tester sur VM non-critique d'abord|Migrer sans backup récent|
|Documenter les migrations|Oublier de vérifier les bridges réseau|
|Planifier pendant fenêtre de maintenance|Migrer plusieurs VM lourdes en même temps|

---

## 🗑️ Suppression de VM

### Comprendre la suppression

La suppression d'une VM dans Proxmox est une opération **définitive** qui :

- Supprime la configuration de la VM
- Supprime les disques associés
- Libère le VMID pour réutilisation
- Supprime tous les snapshots liés

> [!warning] Action irréversible Une fois supprimée, une VM ne peut **pas** être récupérée sauf si vous avez un backup. Soyez toujours certain avant de supprimer.

### Avant de supprimer : checklist

Avant toute suppression, vérifier :

- [ ] La VM n'est plus utilisée en production
- [ ] Un backup récent existe (si données importantes)
- [ ] Aucune dépendance (linked clones, snapshots externes)
- [ ] La VM est bien arrêtée
- [ ] Confirmation auprès de l'équipe/utilisateurs
- [ ] Documentation de la suppression

> [!tip] Snapshot avant suppression Si vous avez un doute, créez un backup ou un snapshot complet avant de supprimer, même si vous pensez ne plus avoir besoin de la VM.

### Supprimer une VM via l'interface Web

#### Méthode standard

1. **Arrêter la VM** si elle est en cours d'exécution
2. Sélectionner la VM dans l'arborescence
3. Cliquer sur **More** > **Remove**
4. Une fenêtre de confirmation apparaît
5. Cocher **Purge from job configurations** (optionnel)
6. Confirmer avec **Remove**

> [!info] Purge from job configurations Cette option supprime la VM de tous les jobs de backup automatiques. Recommandé pour éviter des erreurs dans les tâches planifiées.

### Supprimer une VM via CLI

#### Suppression simple

```bash
# Supprimer une VM (doit être arrêtée)
qm destroy <vmid>

# Exemple
qm destroy 100
```

> [!warning] VM doit être arrêtée La commande `qm destroy` échoue si la VM est en cours d'exécution. Arrêtez-la d'abord avec `qm stop`.

#### Suppression forcée

```bash
# Forcer la suppression même si la VM est en cours
qm destroy <vmid> --skiplock --purge

# Exemple : suppression forcée avec purge
qm destroy 100 --skiplock --purge
```

#### Options de suppression

|Option|Description|Usage|
|---|---|---|
|`--skiplock`|Ignore les verrous|Si VM bloquée|
|`--purge`|Supprime des jobs de backup|Nettoyage complet|
|`--destroy-unreferenced-disks`|Supprime disques non référencés|Nettoyage storage|

### Supprimer les disques manuellement

Dans certains cas, des disques peuvent rester après suppression :

```bash
# Lister les disques d'un storage
pvesm list <storage>

# Exemple : lister les disques sur local-lvm
pvesm list local-lvm

# Supprimer un disque orphelin manuellement
pvesm free <storage>:<disque>

# Exemple
pvesm free local-lvm:vm-100-disk-0
```

> [!info] Disques orphelins Les disques orphelins peuvent apparaître si une suppression a été interrompue ou si des disques ont été détachés de la VM.

### Workflow complet de suppression

```bash
# 1. Vérifier l'état de la VM
qm status 100

# 2. Créer un dernier backup (optionnel mais recommandé)
vzdump 100 --mode snapshot --storage backup-storage

# 3. Arrêter la VM proprement
qm shutdown 100

# 4. Attendre l'arrêt complet
while qm status 100 | grep -q "running"; do sleep 2; done

# 5. Supprimer la VM avec purge
qm destroy 100 --purge

# 6. Vérifier la suppression
qm list | grep 100  # Ne doit rien retourner

# 7. Vérifier le storage (optionnel)
pvesm list local-lvm | grep vm-100
```

### Suppression et stockage partagé

> [!warning] Attention au stockage partagé Sur un stockage partagé (NFS, Ceph), la suppression d'une VM sur un nœud supprime également les données pour **tous les autres nœuds** du cluster.

### Cas particuliers de suppression

#### VM avec snapshots

Les snapshots sont automatiquement supprimés avec la VM :

```bash
# Lister les snapshots avant suppression
qm listsnapshot 100

# La suppression de la VM supprime tous ses snapshots
qm destroy 100
```

> [!info] Snapshots et suppression Impossible de conserver les snapshots après suppression de la VM. Si vous voulez conserver un état, créez un clone ou un backup avant de supprimer.

#### VM utilisée comme template

```bash
# Tenter de supprimer un template
qm destroy 100
# Erreur : "unable to remove template"

# Reconvertir en VM normale puis supprimer
qm set 100 --template 0
qm destroy 100
```

> [!tip] Templates et suppression Proxmox protège les templates contre la suppression accidentelle. Vous devez d'abord désactiver le mode template.

#### VM avec linked clones

```bash
# Impossible de supprimer une VM source de linked clones
qm destroy 100
# Erreur : "base volume still referenced by linked clones"

# Solution 1 : Supprimer d'abord tous les linked clones
qm destroy 201  # Clone 1
qm destroy 202  # Clone 2
qm destroy 100  # Puis la source

# Solution 2 : Convertir les linked clones en full clones
# (Impossible directement, nécessite recréation)
```

> [!warning] Dépendances de clonage Vous ne pouvez pas supprimer une VM qui sert de base à des linked clones. Supprimez d'abord les clones ou migrez-les.

### Récupération après suppression accidentelle

#### Si vous avez un backup

```bash
# Restaurer depuis un backup
qmrestore /chemin/backup/vzdump-qemu-100-*.vma.zst 100

# Ou depuis l'interface Web : Storage > Backups > Restore
```

#### Si vous n'avez pas de backup

> [!warning] Suppression définitive Sans backup, la récupération est **impossible** dans Proxmox. Les données sont définitivement perdues.

Possible uniquement avec des outils de récupération de données au niveau filesystem (très complexe, peu de chances de succès).

### Protection contre la suppression

#### Activer la protection

```bash
# Activer la protection contre la suppression
qm set <vmid> --protection 1

# Exemple
qm set 100 --protection 1
```

Avec la protection activée :

- Impossible de supprimer via l'interface Web
- Impossible de supprimer via CLI sans désactiver la protection
- Protection visible dans l'onglet Options

#### Désactiver la protection

```bash
# Désactiver la protection
qm set <vmid> --protection 0

# Puis supprimer
qm destroy 100
```

> [!tip] Protection des VM critiques Activez systématiquement la protection sur les VM de production critiques, les templates, et les VM sources de linked clones.

### Suppression en masse

Pour supprimer plusieurs VM d'un coup :

```bash
# Supprimer plusieurs VM par boucle
for vmid in 100 101 102 103; do
  echo "Suppression de la VM $vmid"
  qm shutdown $vmid --timeout 60
  qm destroy $vmid --purge
done

# Ou supprimer toutes les VM arrêtées d'un nœud
qm list | grep stopped | awk '{print $1}' | while read vmid; do
  echo "Suppression de VM $vmid"
  qm destroy $vmid --purge
done
```

> [!warning] Suppression en masse dangereuse Testez toujours votre script sur une VM de test avant de l'exécuter sur plusieurs VM. Une erreur peut entraîner la suppression de VM importantes.

### Logs et audit de suppression

#### Consulter les logs de suppression

```bash
# Logs système Proxmox
tail -f /var/log/pve/tasks/active

# Chercher les suppressions récentes
grep "destroy" /var/log/pve/tasks/index
```

#### Journal des tâches dans l'interface

1. **Datacenter** > **Tasks**
2. Filtrer par type : "qmdestroy"
3. Voir l'historique complet des suppressions

> [!info] Traçabilité Toutes les opérations de suppression sont enregistrées avec horodatage, utilisateur et résultat. Utile pour l'audit et le dépannage.

### Nettoyage post-suppression

#### Vérifier les ressources libérées

```bash
# Vérifier l'espace libéré sur le storage
pvesm status

# Détail d'un storage spécifique
df -h /dev/pve/data  # Pour LVM
zfs list              # Pour ZFS
```

#### Nettoyer les configurations résiduelles

```bash
# Vérifier les fichiers de configuration orphelins
ls -la /etc/pve/qemu-server/

# Supprimer manuellement un fichier .conf orphelin (rare)
rm /etc/pve/qemu-server/100.conf
```

### Bonnes pratiques de suppression

|✅ À faire|❌ À éviter|
|---|---|
|Créer un backup avant suppression|Supprimer sans vérifier les dépendances|
|Vérifier qu'aucun linked clone n'existe|Supprimer une VM en production sans validation|
|Activer la protection sur VM critiques|Supprimer en masse sans vérification|
|Documenter les suppressions importantes|Oublier de purger des jobs de backup|
|Arrêter proprement avant de supprimer|Forcer la suppression systématiquement|
|Vérifier l'espace libéré après|Supprimer un template sans désactiver le mode|

### Tableau récapitulatif des commandes

|Action|Commande|Options importantes|
|---|---|---|
|**Supprimer VM**|`qm destroy <vmid>`|`--purge`, `--skiplock`|
|**Forcer suppression**|`qm destroy <vmid> --skiplock`|Ignore les verrous|
|**Activer protection**|`qm set <vmid> --protection 1`|Empêche suppression|
|**Désactiver protection**|`qm set <vmid> --protection 0`|Permet suppression|
|**Lister VM**|`qm list`|Vérifier VM supprimée|
|**Supprimer disque**|`pvesm free <storage>:<disk>`|Nettoyage manuel|

---

## 📋 Résumé de la gestion des VM

### Vue d'ensemble des opérations

|Opération|Temps|Réversible|Risque|Usage|
|---|---|---|---|---|
|**Démarrage/Arrêt**|Secondes|✅ Oui|Faible|Quotidien|
|**Console**|Instantané|✅ N/A|Aucun|Dépannage, config|
|**Snapshot**|Rapide|✅ Oui|Faible|Avant modifications|
|**Clone (Full)**|Minutes-Heures|✅ Oui|Faible|Duplication|
|**Clone (Linked)**|Instantané|⚠️ Partiel|Moyen|Tests temporaires|
|**Migration**|Variable|✅ Oui|Moyen|Maintenance cluster|
|**Suppression**|Rapide|❌ Non|**Élevé**|Fin de vie VM|

### Commandes essentielles à retenir

```bash
# Gestion de base
qm start <vmid>              # Démarrer
qm shutdown <vmid>           # Arrêter proprement
qm reboot <vmid>             # Redémarrer
qm status <vmid>             # État de la VM

# Snapshots
qm snapshot <vmid> <nom>     # Créer snapshot
qm rollback <vmid> <nom>     # Restaurer snapshot
qm listsnapshot <vmid>       # Lister snapshots
qm delsnapshot <vmid> <nom>  # Supprimer snapshot

# Clonage
qm clone <source> <dest> --full --name "nom"  # Full clone
qm clone <source> <dest> --name "nom"         # Linked clone
qm template <vmid>                            # Convertir en template

# Migration
qm migrate <vmid> <node_cible>                          # Migration simple
qm migrate <vmid> <node> --targetstorage <storage>      # Avec storage

# Suppression
qm destroy <vmid>            # Supprimer VM
qm set <vmid> --protection 1 # Protéger contre suppression
```

### Scénarios courants

#### Scénario 1 : Mise à jour système critique

```bash
# 1. Créer un snapshot avant mise à jour
qm snapshot 100 avant_maj_noyau --description "Avant upgrade kernel 6.x"

# 2. Effectuer la mise à jour dans la VM
# ... mise à jour ...

# 3a. Si succès : supprimer le snapshot après validation
qm delsnapshot 100 avant_maj_noyau

# 3b. Si échec : restaurer le snapshot
qm rollback 100 avant_maj_noyau
qm start 100
```

#### Scénario 2 : Création d'environnements de test

```bash
# 1. Créer une VM de base configurée
# ... configuration ...

# 2. Convertir en template
qm shutdown 100
qm template 100

# 3. Créer des clones pour les tests
qm clone 100 201 --name "test-env-dev"
qm clone 100 202 --name "test-env-staging"

# 4. Démarrer et personnaliser
qm start 201
qm start 202
```

#### Scénario 3 : Maintenance d'un nœud

```bash
# 1. Lister les VM du nœud à maintenir
qm list

# 2. Migrer toutes les VM vers un autre nœud
for vmid in $(qm list | grep "running" | awk '{print $1}'); do
  qm shutdown $vmid --timeout 60
  qm migrate $vmid pve2 --targetstorage local-lvm
done

# 3. Effectuer la maintenance
# ... maintenance du nœud ...

# 4. Optionnel : migrer les VM en retour après maintenance
```

### Points de vigilance critiques

> [!warning] Attention particulière requise
> 
> - **Snapshots** : ne remplacent pas les backups, limiter à 3-4 maximum
> - **Linked clones** : ne jamais supprimer la VM source tant que des clones existent
> - **Migration** : vérifier l'espace disque disponible sur la cible
> - **Suppression** : toujours vérifier les dépendances et créer un backup
> - **Protection** : activer sur toutes les VM de production critiques

### Ressources système

#### Impact sur les performances

|Opération|CPU|RAM|I/O Disque|Réseau|
|---|---|---|---|---|
|Démarrage|Moyen|Moyen|Élevé|Faible|
|Console noVNC|Faible|Faible|Faible|Moyen|
|Console SPICE|Faible|Faible|Faible|Faible|
|Snapshot (création)|Faible|Faible|Moyen|Aucun|
|Snapshot (rollback)|Moyen|Faible|Élevé|Aucun|
|Full Clone|Moyen|Faible|Très élevé|Faible|
|Linked Clone|Faible|Faible|Faible|Aucun|
|Migration (local)|Moyen|Faible|Très élevé|Très élevé|
|Suppression|Faible|Faible|Moyen|Aucun|

---

🎯 **Vous maîtrisez maintenant la gestion complète des machines virtuelles dans Proxmox !** Ce cours couvre tous les aspects essentiels pour administrer efficacement vos VM au quotidien.