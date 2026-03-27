

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

## 🎯 Introduction aux snapshots

Un **snapshot** (instantané) capture l'état complet d'une machine virtuelle à un instant T, incluant :

- L'état de la mémoire RAM (si la VM est en cours d'exécution)
- Les paramètres de configuration
- L'état de tous les disques virtuels attachés

> [!info] Pourquoi utiliser des snapshots ?
> 
> - **Sauvegardes avant modifications** : testez des configurations risquées
> - **Points de restauration** : revenez en arrière en cas d'erreur
> - **Tests et développement** : expérimentez sans risque
> - **Déploiement** : créez des états de référence réutilisables

> [!warning] Attention Les snapshots ne remplacent PAS une stratégie de sauvegarde complète. Ils sont stockés dans le même emplacement que la VM et consomment de l'espace disque proportionnel aux modifications effectuées.

---

## 🆕 Création de snapshots

### Syntaxe de base

```bash
VBoxManage snapshot <vm> take <nom_snapshot> [options]
```

### Options principales

|Option|Description|
|---|---|
|`--description <texte>`|Ajoute une description détaillée|
|`--live`|Capture la RAM sans arrêter la VM|
|`--uniquename Number,Timestamp,Space,Force`|Gère les noms en double|

### Exemples pratiques

**Snapshot simple d'une VM arrêtée :**

```bash
VBoxManage snapshot "Ubuntu-Dev" take "Clean Install"
```

**Snapshot avec description :**

```bash
VBoxManage snapshot "Ubuntu-Dev" take "Pre-Update" \
    --description "État avant mise à jour système du 14/12/2024"
```

**Snapshot en direct (VM en cours d'exécution) :**

```bash
VBoxManage snapshot "Ubuntu-Dev" take "Working State" --live
```

> [!tip] Astuce - Live Snapshots L'option `--live` permet de capturer l'état RAM sans interrompre le travail en cours. Idéal pour sauvegarder sans perdre des données non enregistrées. Attention : consomme plus d'espace disque.

**Gestion des noms en double :**

```bash
# Ajoute un numéro si le nom existe déjà
VBoxManage snapshot "Ubuntu-Dev" take "Test" --uniquename Number

# Ajoute un timestamp
VBoxManage snapshot "Ubuntu-Dev" take "Test" --uniquename Timestamp

# Force l'écrasement (supprime l'ancien)
VBoxManage snapshot "Ubuntu-Dev" take "Test" --uniquename Force
```

> [!example] Cas d'usage réel Avant d'installer un nouveau paquet système :
> 
> ```bash
> VBoxManage snapshot "Production-Server" take "Pre-$(date +%Y%m%d)" \
>     --description "Avant installation de Docker" --live
> ```

---

## 📋 Liste et affichage des snapshots

### Lister tous les snapshots

```bash
VBoxManage snapshot <vm> list [--details] [--machinereadable]
```

**Affichage simple :**

```bash
VBoxManage snapshot "Ubuntu-Dev" list
```

**Sortie exemple :**

```
Name: Clean Install (UUID: 1a2b3c4d-5e6f-7g8h-9i0j-1k2l3m4n5o6p)
Name: Pre-Update (UUID: 2b3c4d5e-6f7g-8h9i-0j1k-2l3m4n5o6p7q) *
   Name: Working State (UUID: 3c4d5e6f-7g8h-9i0j-1k2l-3m4n5o6p7q8r)
```

> [!info] Lecture de l'arbre
> 
> - Les snapshots enfants sont indentés
> - L'astérisque `*` indique le snapshot **actuel** (current state)
> - L'UUID permet d'identifier précisément un snapshot

**Affichage détaillé :**

```bash
VBoxManage snapshot "Ubuntu-Dev" list --details
```

**Sortie détaillée exemple :**

```
Name: Pre-Update (UUID: 2b3c4d5e-6f7g-8h9i-0j1k-2l3m4n5o6p7q)
Description: État avant mise à jour système du 14/12/2024
Created: 2024-12-14T10:30:45.123456789Z
Size: 2.5 GB
```

**Format machine (pour scripts) :**

```bash
VBoxManage snapshot "Ubuntu-Dev" list --machinereadable
```

**Sortie pour parsing :**

```
SnapshotName="Clean Install"
SnapshotUUID="1a2b3c4d-5e6f-7g8h-9i0j-1k2l3m4n5o6p"
SnapshotDescription=""
SnapshotTimeStamp="2024-12-10T14:22:33.000000000Z"
```

### Afficher les informations d'une VM spécifique

```bash
VBoxManage showvminfo <vm> [--machinereadable]
```

Cette commande affiche l'état général incluant le snapshot actuel :

```bash
VBoxManage showvminfo "Ubuntu-Dev" | grep -i snapshot
```

> [!tip] Astuce - Filtrage efficace Utilisez `grep`, `awk` ou `jq` (avec `--machinereadable`) pour extraire des informations spécifiques dans vos scripts :
> 
> ```bash
> # Compter les snapshots
> VBoxManage snapshot "Ubuntu-Dev" list | grep "^Name:" | wc -l
> 
> # Extraire tous les UUIDs
> VBoxManage snapshot "Ubuntu-Dev" list --machinereadable | grep "SnapshotUUID" | cut -d'"' -f2
> ```

---

## ⏮️ Restauration (restore)

### Syntaxe de base

```bash
VBoxManage snapshot <vm> restore <snapshot>
```

Le paramètre `<snapshot>` peut être :

- Le **nom** du snapshot
- Son **UUID**

### Exemples de restauration

**Restaurer par nom :**

```bash
VBoxManage snapshot "Ubuntu-Dev" restore "Clean Install"
```

**Restaurer par UUID :**

```bash
VBoxManage snapshot "Ubuntu-Dev" restore 1a2b3c4d-5e6f-7g8h-9i0j-1k2l3m4n5o6p
```

> [!warning] Impact de la restauration
> 
> - La restauration **écrase l'état actuel** de la VM
> - Les modifications non sauvegardées depuis le dernier snapshot sont **perdues**
> - La VM doit être **arrêtée** pour effectuer une restauration
> - Un nouveau snapshot de l'état actuel est créé automatiquement avant restauration

**Workflow de restauration sécurisé :**

```bash
# 1. Vérifier l'état de la VM
VBoxManage showvminfo "Ubuntu-Dev" | grep "State:"

# 2. Arrêter la VM si nécessaire
VBoxManage controlvm "Ubuntu-Dev" poweroff

# 3. Lister les snapshots disponibles
VBoxManage snapshot "Ubuntu-Dev" list

# 4. Restaurer le snapshot souhaité
VBoxManage snapshot "Ubuntu-Dev" restore "Pre-Update"

# 5. Redémarrer la VM
VBoxManage startvm "Ubuntu-Dev" --type headless
```

### Restaurer au snapshot le plus récent

```bash
# Identifier le dernier snapshot
LAST_SNAPSHOT=$(VBoxManage snapshot "Ubuntu-Dev" list --machinereadable | \
    grep "SnapshotName" | tail -1 | cut -d'"' -f2)

# Restaurer
VBoxManage snapshot "Ubuntu-Dev" restore "$LAST_SNAPSHOT"
```

> [!example] Cas d'usage - Test de mise à jour
> 
> ```bash
> # Créer un snapshot avant modification
> VBoxManage snapshot "WebServer" take "Pre-Nginx-Update" --live
> 
> # ... effectuer des tests ...
> 
> # Si ça ne fonctionne pas, restaurer
> VBoxManage controlvm "WebServer" poweroff
> VBoxManage snapshot "WebServer" restore "Pre-Nginx-Update"
> VBoxManage startvm "WebServer" --type headless
> ```

---

## 🗑️ Suppression de snapshots

### Syntaxe de base

```bash
VBoxManage snapshot <vm> delete <snapshot>
```

### Comportement de la suppression

Lors de la suppression d'un snapshot :

- Les **modifications** du snapshot sont **fusionnées** avec son parent
- Les snapshots enfants restent intacts
- L'espace disque est libéré (après fusion des disques différentiels)

### Exemples de suppression

**Supprimer un snapshot spécifique :**

```bash
VBoxManage snapshot "Ubuntu-Dev" delete "Old Snapshot"
```

**Supprimer par UUID :**

```bash
VBoxManage snapshot "Ubuntu-Dev" delete 1a2b3c4d-5e6f-7g8h-9i0j-1k2l3m4n5o6p
```

> [!warning] Temps de traitement La suppression d'un snapshot peut prendre du temps (plusieurs minutes) car VirtualBox doit fusionner les fichiers de disques différentiels. Ne pas interrompre ce processus.

### Supprimer tous les snapshots (avec script)

```bash
#!/bin/bash
VM_NAME="Ubuntu-Dev"

# Lister tous les UUIDs
SNAPSHOTS=$(VBoxManage snapshot "$VM_NAME" list --machinereadable | \
    grep "SnapshotUUID" | cut -d'"' -f2)

# Supprimer chaque snapshot
for UUID in $SNAPSHOTS; do
    echo "Suppression du snapshot $UUID..."
    VBoxManage snapshot "$VM_NAME" delete "$UUID"
done
```

> [!tip] Astuce - Libération d'espace Après suppression de snapshots, l'espace disque n'est pas immédiatement libéré. VirtualBox doit fusionner les disques différentiels. Pour forcer la consolidation :
> 
> ```bash
> # Après suppression, compacter le disque
> VBoxManage modifymedium disk "chemin/vers/disque.vdi" --compact
> ```

### Supprimer le snapshot actuel (restorecurrent)

```bash
VBoxManage snapshot <vm> restorecurrent
```

Cette commande :

- Supprime l'état actuel non sauvegardé
- Restaure le dernier snapshot pris
- Utile pour annuler toutes les modifications depuis le dernier snapshot

```bash
VBoxManage snapshot "Ubuntu-Dev" restorecurrent
```

---

## 🌳 Snapshot tree et relations

### Comprendre l'arborescence

Les snapshots forment une **structure arborescente** où :

- Chaque snapshot peut avoir **un parent** et **plusieurs enfants**
- Le **current state** représente l'état actuel (non sauvegardé)
- Les branches permettent d'explorer différentes configurations

**Visualisation de l'arbre :**

```
Clean Install
│
├─→ Pre-Update
│   │
│   └─→ Working State (current)
│
└─→ Alternative Config
    │
    └─→ Test Branch
```

### Afficher l'arbre complet

```bash
VBoxManage snapshot "Ubuntu-Dev" list
```

**Sortie avec arbre :**

```
Name: Clean Install (UUID: aaa...)
   Name: Pre-Update (UUID: bbb...)
      Name: Working State (UUID: ccc...) *
   Name: Alternative Config (UUID: ddd...)
      Name: Test Branch (UUID: eee...)
```

### Navigation dans l'arbre

**Créer une branche depuis un snapshot ancien :**

```bash
# 1. Restaurer un snapshot plus ancien
VBoxManage snapshot "Ubuntu-Dev" restore "Clean Install"

# 2. Créer un nouveau snapshot (crée une branche)
VBoxManage snapshot "Ubuntu-Dev" take "New Branch"
```

**Résultat :**

```
Clean Install
│
├─→ Pre-Update
│   └─→ Working State
│
└─→ New Branch (current) *
```

> [!info] Current State Le "current state" n'est PAS un snapshot. C'est l'état actuel de la VM, qui inclut toutes les modifications depuis le dernier snapshot. Il peut être sauvegardé en créant un nouveau snapshot.

### Identifier les relations parent-enfant

```bash
VBoxManage snapshot "Ubuntu-Dev" list --details
```

Chaque snapshot affiche son **UUID** et sa position dans l'arbre. Les enfants sont indentés sous leur parent.

### Stratégies d'organisation

**Arbre linéaire (simple) :**

```
Install → Config → Updates → Production
```

Idéal pour un workflow séquentiel sans retours en arrière.

**Arbre avec branches (expérimentation) :**

```
Base Install
│
├─→ Production Branch
│   ├─→ v1.0
│   └─→ v1.1
│
└─→ Test Branch
    ├─→ Feature A
    └─→ Feature B
```

Idéal pour tester plusieurs configurations simultanément.

> [!tip] Convention de nommage Adoptez une convention claire pour faciliter la navigation :
> 
> ```bash
> # Format : [Type]-[Description]-[Date]
> VBoxManage snapshot "VM" take "PROD-Clean-20241214"
> VBoxManage snapshot "VM" take "TEST-Docker-20241214"
> VBoxManage snapshot "VM" take "DEV-Experiments-20241214"
> ```

### Consolidation de l'arbre

Au fil du temps, l'arbre peut devenir complexe. Pour simplifier :

```bash
# 1. Identifier les snapshots obsolètes
VBoxManage snapshot "Ubuntu-Dev" list

# 2. Supprimer les branches inutiles
VBoxManage snapshot "Ubuntu-Dev" delete "Old Branch"

# 3. Conserver uniquement les snapshots critiques
# (ex: Clean Install, Production State)
```

---

## ⚠️ Pièges courants et bonnes pratiques

### Pièges courants

> [!warning] Erreur 1 : Noms de snapshots non uniques **Problème :** Utiliser le même nom plusieurs fois rend la restauration ambiguë.
> 
> **Solution :** Toujours utiliser `--uniquename` ou inclure des timestamps :
> 
> ```bash
> VBoxManage snapshot "VM" take "Backup-$(date +%Y%m%d-%H%M%S)"
> ```

> [!warning] Erreur 2 : Accumulation de snapshots **Problème :** Trop de snapshots ralentissent les performances et consomment énormément d'espace.
> 
> **Solution :** Faire régulièrement le ménage :
> 
> ```bash
> # Supprimer les snapshots > 30 jours (nécessite parsing)
> # Garder uniquement 3-5 snapshots récents
> ```

> [!warning] Erreur 3 : Restauration sans sauvegarde préalable **Problème :** La restauration écrase l'état actuel sans retour possible.
> 
> **Solution :** Toujours créer un snapshot de l'état actuel avant restauration :
> 
> ```bash
> VBoxManage snapshot "VM" take "Before-Restore-$(date +%s)"
> VBoxManage snapshot "VM" restore "Target-Snapshot"
> ```

> [!warning] Erreur 4 : Confusion entre snapshot et sauvegarde **Problème :** Les snapshots NE sont PAS des sauvegardes complètes. Ils dépendent des fichiers VDI d'origine.
> 
> **Solution :** Combiner snapshots + exports réguliers :
> 
> ```bash
> # Snapshot pour restauration rapide
> VBoxManage snapshot "VM" take "Daily-$(date +%u)"
> 
> # Export mensuel pour sauvegarde complète
> VBoxManage export "VM" -o "backup-$(date +%Y%m).ova"
> ```

### Bonnes pratiques

> [!tip] 1. Stratégie de nommage cohérente
> 
> ```bash
> # Format recommandé : [ENVIRONNEMENT]-[DESCRIPTION]-[DATE]
> VBoxManage snapshot "VM" take "PROD-PreDeployment-20241214"
> VBoxManage snapshot "VM" take "DEV-CleanState-20241214"
> VBoxManage snapshot "VM" take "TEST-FeatureX-20241214"
> ```

> [!tip] 2. Documentation systématique Utilisez toujours l'option `--description` pour documenter le contexte :
> 
> ```bash
> VBoxManage snapshot "VM" take "Critical-Point" \
>     --description "Avant migration BDD PostgreSQL 14→16. Backup externe: backup-20241214.tar.gz"
> ```

> [!tip] 3. Automation avec scripts Créez des scripts pour automatiser les tâches répétitives :
> 
> ```bash
> #!/bin/bash
> # snapshot-daily.sh
> VM_NAME="Production-VM"
> SNAPSHOT_NAME="Daily-$(date +%A)"  # Lundi, Mardi, etc.
> 
> # Créer snapshot avec rotation hebdomadaire
> if VBoxManage snapshot "$VM_NAME" list | grep -q "$SNAPSHOT_NAME"; then
>     VBoxManage snapshot "$VM_NAME" delete "$SNAPSHOT_NAME"
> fi
> 
> VBoxManage snapshot "$VM_NAME" take "$SNAPSHOT_NAME" \
>     --description "Snapshot automatique du $(date)" --live
> ```

> [!tip] 4. Surveillance de l'espace disque Les snapshots consomment de l'espace. Surveillez régulièrement :
> 
> ```bash
> # Afficher la taille des snapshots
> VBoxManage list hdds | grep -E "(Location|Capacity)"
> 
> # Ou spécifique à une VM
> VBoxManage showvminfo "VM" --machinereadable | grep "Size"
> ```

> [!tip] 5. Hiérarchie claire et limitée
> 
> - Maximum **3 niveaux** de profondeur
> - Pas plus de **5-7 snapshots** par VM
> - Supprimer les snapshots obsolètes mensuellement

> [!tip] 6. Tests avant restauration critique Avant de restaurer un snapshot en production :
> 
> ```bash
> # 1. Cloner la VM
> VBoxManage clonevm "Production" --name "Test-Restore" --register
> 
> # 2. Tester la restauration sur le clone
> VBoxManage snapshot "Test-Restore" restore "Target-Snapshot"
> 
> # 3. Valider le fonctionnement
> VBoxManage startvm "Test-Restore" --type headless
> 
> # 4. Si OK, restaurer sur production
> VBoxManage snapshot "Production" restore "Target-Snapshot"
> ```

> [!tip] 7. Intégration avec sauvegarde complète
> 
> ```bash
> # Stratégie combinée :
> # - Snapshots quotidiens (restauration rapide)
> # - Export hebdomadaire (sauvegarde complète)
> # - Sauvegarde externe mensuelle (disaster recovery)
> 
> # Cron quotidien
> 0 2 * * * /usr/local/bin/snapshot-daily.sh
> 
> # Cron hebdomadaire
> 0 3 * * 0 VBoxManage export "VM" -o "/backups/weekly-$(date +%Y%W).ova"
> ```

---

## 🎓 Résumé des commandes essentielles

```bash
# Création
VBoxManage snapshot <vm> take <nom> [--description "..."] [--live]

# Listage
VBoxManage snapshot <vm> list [--details] [--machinereadable]

# Restauration
VBoxManage snapshot <vm> restore <snapshot>
VBoxManage snapshot <vm> restorecurrent

# Suppression
VBoxManage snapshot <vm> delete <snapshot>

# Informations
VBoxManage showvminfo <vm> | grep -i snapshot
```

---

**Dernière mise à jour :** 14 décembre 2024