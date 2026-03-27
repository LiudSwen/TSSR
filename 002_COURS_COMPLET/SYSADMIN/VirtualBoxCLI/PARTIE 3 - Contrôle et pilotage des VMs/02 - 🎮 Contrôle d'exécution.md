

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

## Introduction au contrôle d'exécution

Le contrôle d'exécution dans VirtualBox CLI permet de gérer l'état d'une machine virtuelle **pendant qu'elle est en cours d'exécution**. C'est l'équivalent des boutons de contrôle dans l'interface graphique, mais avec la puissance et la flexibilité de la ligne de commande.

> [!info] Pourquoi utiliser le contrôle d'exécution en CLI ?
> 
> - **Automatisation** : Intégrer les actions dans des scripts
> - **Administration à distance** : Contrôler des VMs sur des serveurs sans interface graphique
> - **Précision** : Accès à des options avancées non disponibles dans l'interface graphique
> - **Efficacité** : Actions rapides sans naviguer dans les menus

---

## La commande controlvm

### Syntaxe générale

```bash
VBoxManage controlvm <nom-vm|uuid-vm> <commande> [paramètres]
```

> [!warning] Prérequis important La commande `controlvm` ne fonctionne que sur des machines virtuelles **déjà démarrées**. Pour une VM éteinte, utilisez plutôt `modifyvm`.

### Structure de base

```bash
# Utilisation avec le nom de la VM
VBoxManage controlvm "Ubuntu-Server" pause

# Utilisation avec l'UUID de la VM
VBoxManage controlvm {a8f2c9d1-4b3e-4c5d-8a7b-9c8d7e6f5a4b} pause
```

> [!tip] Astuce pour l'UUID Récupérez l'UUID d'une VM avec : `VBoxManage list vms`

### Vérification de l'état actuel

Avant d'utiliser `controlvm`, il est utile de connaître l'état de la VM :

```bash
# Lister toutes les VMs en cours d'exécution
VBoxManage list runningvms

# Afficher les détails d'état d'une VM spécifique
VBoxManage showvminfo "Ubuntu-Server" | grep "State"
```

---

## Pause et Resume

### Concept

La **pause** gèle l'exécution de la machine virtuelle. Le processeur virtuel s'arrête, mais la mémoire RAM reste allouée. C'est comme mettre la VM en mode "congélation".

### Pause d'une VM

```bash
# Mettre en pause
VBoxManage controlvm "Ubuntu-Server" pause
```

**Effets de la pause :**

- ⏸️ Le CPU virtuel s'arrête immédiatement
- 💾 La RAM reste allouée et son contenu est préservé
- 🌐 Les connexions réseau sont suspendues
- ⏱️ L'horloge virtuelle s'arrête

> [!example] Cas d'usage de la pause
> 
> - Libérer temporairement des ressources CPU sur la machine hôte
> - Suspendre une VM pendant un diagnostic
> - Geler l'état pour une inspection sans modification

### Resume d'une VM

```bash
# Reprendre l'exécution
VBoxManage controlvm "Ubuntu-Server" resume
```

**Effets du resume :**

- ▶️ Le CPU virtuel reprend exactement où il s'était arrêté
- 🔄 Les processus continuent sans interruption perceptible
- 🌐 Les connexions réseau tentent de se reconnecter

> [!warning] Attention aux timeouts Si la pause est trop longue, certaines connexions réseau (SSH, bases de données) peuvent expirer et nécessiter une reconnexion.

### Différence avec savestate

|Caractéristique|Pause|Savestate|
|---|---|---|
|RAM|Reste en mémoire|Écrite sur disque|
|Ressources hôte|CPU libéré, RAM occupée|Tout libéré|
|Vitesse reprise|Instantanée|Quelques secondes|
|Persistance|Non (perdue au redémarrage hôte)|Oui (survit au redémarrage)|

---

## Reset et Poweroff

### Reset : Redémarrage forcé

Le **reset** simule un appui sur le bouton reset physique d'un ordinateur. C'est un redémarrage immédiat et brutal.

```bash
# Reset de la VM
VBoxManage controlvm "Ubuntu-Server" reset
```

**Comportement du reset :**

- 🔄 Redémarrage immédiat sans arrêt propre du système d'exploitation
- ⚡ Équivalent à couper puis rallumer l'alimentation
- ⚠️ Aucune sauvegarde des données non écrites sur disque

> [!warning] Risques du reset
> 
> - **Corruption de données** : Les fichiers en cours d'écriture peuvent être corrompus
> - **Perte de travail** : Les données non sauvegardées sont perdues
> - **Problèmes système** : Peut causer des erreurs au prochain démarrage
> 
> ⚠️ **À utiliser uniquement en dernier recours** quand la VM ne répond plus !

> [!example] Quand utiliser reset ?
> 
> - La VM est complètement bloquée (freeze)
> - Le système d'exploitation ne répond plus à aucune commande
> - Un processus critique est bloqué et empêche l'arrêt normal

### Poweroff : Extinction forcée

Le **poweroff** coupe immédiatement l'alimentation virtuelle de la VM.

```bash
# Extinction forcée
VBoxManage controlvm "Ubuntu-Server" poweroff
```

**Comportement du poweroff :**

- 🔌 Extinction immédiate sans procédure d'arrêt
- 💾 État de la VM non sauvegardé
- ⚡ Équivalent à débrancher le câble d'alimentation

> [!warning] Même risques que reset Le `poweroff` présente les **mêmes risques de corruption** que le `reset`. La différence est que la VM s'éteint au lieu de redémarrer.

### Bonnes pratiques

```bash
# ❌ MAUVAIS : Extinction brutale d'une VM saine
VBoxManage controlvm "Ubuntu-Server" poweroff

# ✅ BON : Tentative d'arrêt propre d'abord
VBoxManage controlvm "Ubuntu-Server" acpipowerbutton
# Attendre 30 secondes
sleep 30
# Si la VM ne s'est pas éteinte, forcer l'arrêt
VBoxManage controlvm "Ubuntu-Server" poweroff
```

---

## Sauvegarde de l'état (savestate)

### Concept

Le **savestate** capture l'état complet de la machine virtuelle (RAM, registres CPU, périphériques) et le sauvegarde sur le disque. C'est comme une "hibernation" complète.

### Utilisation de savestate

```bash
# Sauvegarder l'état et éteindre la VM
VBoxManage controlvm "Ubuntu-Server" savestate
```

**Ce qui est sauvegardé :**

- 💾 Contenu complet de la RAM
- 🎯 État des registres CPU
- 🖥️ État de tous les périphériques virtuels
- 📊 État exact de tous les processus en cours

### Processus de savestate

```bash
# 1. Sauvegarder l'état
VBoxManage controlvm "Ubuntu-Server" savestate
# La VM s'éteint automatiquement après la sauvegarde

# 2. Plus tard, redémarrer exactement où on s'était arrêté
VBoxManage startvm "Ubuntu-Server"
```

> [!info] Reprise après savestate Quand vous redémarrez une VM après un `savestate`, elle reprend **exactement** au même point. Les applications ouvertes, les connexions réseau, tout est restauré comme si rien ne s'était passé.

### Avantages du savestate

✅ **Conservation parfaite de l'état** : Rien n'est perdu, tout est figé  
✅ **Libération complète des ressources** : CPU et RAM de l'hôte sont libérés  
✅ **Reprise rapide** : Plus rapide qu'un démarrage complet du système  
✅ **Survit au redémarrage de l'hôte** : L'état est persistant sur disque

### Inconvénients et limites

❌ **Temps de sauvegarde** : Peut prendre plusieurs secondes selon la RAM allouée  
❌ **Espace disque** : Nécessite de l'espace équivalent à la RAM allouée  
❌ **Snapshots incompatibles** : Vous ne pouvez pas créer de snapshot pendant un savestate

> [!tip] Optimisation de savestate
> 
> ```bash
> # Avant un savestate, libérer la mémoire inutilisée dans la VM
> # (sous Linux dans la VM)
> sync && echo 3 > /proc/sys/vm/drop_caches
> 
> # Puis savestate
> VBoxManage controlvm "Ubuntu-Server" savestate
> ```

### Différence avec les snapshots

|Caractéristique|Savestate|Snapshot|
|---|---|---|
|Cible|État RAM + registres|Disques virtuels|
|Moment|VM en cours|N'importe quand|
|Usage|Pause longue durée|Point de restauration|
|Reprise|Automatique au démarrage|Manuelle (restore)|
|Multiplicité|Un seul à la fois|Plusieurs snapshots possibles|

---

## ACPI Shutdown

### Concept

L'**ACPI shutdown** simule un appui sur le bouton power physique d'un ordinateur moderne. C'est la méthode **recommandée** pour éteindre proprement une VM.

### Utilisation d'ACPI

```bash
# Envoyer un signal d'arrêt propre
VBoxManage controlvm "Ubuntu-Server" acpipowerbutton
```

**Comportement d'ACPI shutdown :**

- 🔘 Simule un appui sur le bouton power
- 🖥️ Le système d'exploitation invité reçoit le signal
- 📝 Les applications se ferment proprement
- 💾 Les données sont synchronisées sur disque
- ✅ Arrêt propre et sécurisé

> [!info] Qu'est-ce que l'ACPI ? **ACPI** (Advanced Configuration and Power Interface) est un standard qui permet au système d'exploitation de gérer l'alimentation et la configuration matérielle. L'ACPI powerbutton envoie un signal que le système d'exploitation interprète comme une demande d'extinction.

### Comportement selon le système d'exploitation

#### Linux

```bash
VBoxManage controlvm "Ubuntu-Server" acpipowerbutton
# Le système exécute généralement : shutdown -h now
# Délai typique : 5-30 secondes selon les services à arrêter
```

#### Windows

```bash
VBoxManage controlvm "Windows-VM" acpipowerbutton
# Windows ferme les applications et demande confirmation si nécessaire
# Délai typique : 10-60 secondes selon les mises à jour et applications
```

> [!warning] ACPI nécessite les Guest Additions Pour fonctionner correctement, **VirtualBox Guest Additions** doit être installé dans la VM. Sans cela, l'ACPI peut ne pas être reconnu.

### Gestion des timeouts

L'ACPI shutdown est **asynchrone** : la commande retourne immédiatement, mais l'extinction prend du temps.

```bash
# Script d'arrêt avec attente
#!/bin/bash

VM_NAME="Ubuntu-Server"

# Envoyer le signal ACPI
echo "Envoi du signal d'arrêt à $VM_NAME..."
VBoxManage controlvm "$VM_NAME" acpipowerbutton

# Attendre que la VM s'éteigne (maximum 60 secondes)
echo "Attente de l'extinction..."
for i in {1..60}; do
    STATE=$(VBoxManage showvminfo "$VM_NAME" --machinereadable | grep "VMState=" | cut -d'"' -f2)
    if [ "$STATE" = "poweroff" ]; then
        echo "VM éteinte avec succès après $i secondes"
        exit 0
    fi
    sleep 1
done

# Si timeout, forcer l'arrêt
echo "Timeout : extinction forcée"
VBoxManage controlvm "$VM_NAME" poweroff
```

### Comparaison des méthodes d'arrêt

|Méthode|Type|Sécurité|Vitesse|Usage|
|---|---|---|---|---|
|`acpipowerbutton`|Propre|✅ Sûr|🐢 5-60s|**Recommandé**|
|`savestate`|Hibernation|✅ Sûr|🐇 2-10s|Pause longue|
|`poweroff`|Forcé|⚠️ Risqué|⚡ Instantané|Urgence uniquement|
|`reset`|Redémarrage forcé|⚠️ Risqué|⚡ Instantané|VM bloquée|

> [!tip] Bonne pratique d'extinction
> 
> ```bash
> # Toujours privilégier ACPI en premier
> VBoxManage controlvm "Ma-VM" acpipowerbutton
> 
> # Attendre un délai raisonnable (30-60 secondes)
> 
> # Si nécessaire seulement, forcer l'arrêt
> VBoxManage controlvm "Ma-VM" poweroff
> ```

---

## Gestion des snapshots en live

### Concept des snapshots en live

Un **snapshot en live** (ou snapshot à chaud) capture l'état des disques virtuels **pendant que la VM est en cours d'exécution**. Contrairement à un snapshot classique qui nécessite d'éteindre la VM, le snapshot en live permet de créer un point de restauration sans interruption de service.

> [!info] Différence snapshot en live vs snapshot classique
> 
> - **Snapshot classique** : VM éteinte, capture uniquement les disques
> - **Snapshot en live** : VM en cours d'exécution, capture disques + état mémoire (optionnel)

### Création d'un snapshot en live

```bash
# Snapshot basique en live (disques uniquement)
VBoxManage snapshot "Ubuntu-Server" take "Snapshot-Avant-MaJ" \
    --live

# Snapshot avec description
VBoxManage snapshot "Ubuntu-Server" take "Avant-Installation-Apache" \
    --description "État avant installation du serveur web Apache 2.4" \
    --live
```

**Comportement du snapshot en live :**

- 📸 La VM continue de fonctionner sans interruption
- 💾 Les modifications futures sont écrites dans un nouveau disque différentiel
- 🔄 L'ancien état reste accessible pour restauration
- ⚡ Impact minimal sur les performances pendant la capture

### Snapshot en live avec état mémoire

Pour capturer également l'état de la RAM (équivalent à un savestate + snapshot) :

```bash
# Snapshot avec état mémoire
VBoxManage snapshot "Ubuntu-Server" take "Snapshot-Complet" \
    --live \
    --description "Snapshot avec état RAM pour restauration exacte"
```

> [!warning] Impact de l'état mémoire
> 
> - Augmente considérablement la taille du snapshot (+ taille de la RAM)
> - Augmente le temps de création du snapshot
> - Permet une restauration exacte incluant les processus en cours

### Avantages du snapshot en live

✅ **Pas d'interruption de service** : Les utilisateurs ne voient aucune coupure  
✅ **Flexibilité** : Possibilité de revenir en arrière rapidement  
✅ **Sécurité** : Créer un point de sauvegarde avant une opération risquée  
✅ **Capture cohérente** : L'état du système est figé au moment du snapshot

### Cas d'usage typiques

```bash
# 1. Avant une mise à jour système
VBoxManage snapshot "Prod-Server" take "Avant-Update-Kernel" --live
# Effectuer la mise à jour
# Si problème : restaurer le snapshot

# 2. Avant un changement de configuration critique
VBoxManage snapshot "Database-Server" take "Avant-Config-Replication" --live
# Modifier la configuration
# Si échec : restaurer

# 3. Avant l'installation d'un logiciel
VBoxManage snapshot "Dev-VM" take "Avant-Install-Docker" --live
# Installer Docker
# Si conflits : restaurer
```

### Restauration d'un snapshot en live

> [!info] Restauration = Arrêt nécessaire Même si le snapshot a été pris en live, la **restauration nécessite d'arrêter la VM**. C'est une limitation technique de VirtualBox.

```bash
# 1. Arrêter la VM proprement
VBoxManage controlvm "Ubuntu-Server" acpipowerbutton
# Attendre l'extinction...

# 2. Restaurer le snapshot
VBoxManage snapshot "Ubuntu-Server" restore "Snapshot-Avant-MaJ"

# 3. Redémarrer la VM
VBoxManage startvm "Ubuntu-Server" --type headless
```

### Gestion des snapshots pendant l'exécution

```bash
# Lister les snapshots (VM en cours d'exécution ou non)
VBoxManage snapshot "Ubuntu-Server" list

# Voir les détails d'un snapshot spécifique
VBoxManage snapshot "Ubuntu-Server" showvminfo "Snapshot-Avant-MaJ"

# Supprimer un snapshot ancien (libère l'espace disque)
# Note : La VM peut rester en cours d'exécution
VBoxManage snapshot "Ubuntu-Server" delete "Vieux-Snapshot"
```

> [!warning] Performance lors de la suppression La suppression d'un snapshot **fusionne les disques différentiels**, ce qui peut prendre du temps et impacter temporairement les performances de la VM, même si elle reste en cours d'exécution.

### Bonnes pratiques pour les snapshots en live

```bash
# ✅ BON : Snapshot avant opération risquée
VBoxManage snapshot "Prod-DB" take "Avant-Migration-Schema" \
    --live \
    --description "Avant migration du schéma de la base v3.2 vers v4.0"

# ❌ MAUVAIS : Trop de snapshots en chaîne
# Créer 10 snapshots successifs dégrade les performances
# Privilégier : prendre un snapshot, tester, valider, supprimer si OK

# ✅ BON : Nettoyer les anciens snapshots
# Après validation d'une mise à jour
VBoxManage snapshot "Prod-DB" delete "Avant-Migration-Schema"
```

### Limitations et considérations

|Aspect|Impact|
|---|---|
|**Performance**|Légère dégradation des I/O disque (lecture via chaîne différentielle)|
|**Espace disque**|Chaque snapshot consomme de l'espace (croissance avec modifications)|
|**Chaîne de snapshots**|Plus il y a de snapshots, plus les performances se dégradent|
|**Restauration**|Nécessite toujours l'arrêt de la VM|

> [!tip] Optimisation des snapshots
> 
> - **Limiter le nombre** : Maximum 3-5 snapshots actifs par VM
> - **Supprimer régulièrement** : Fusionner les anciens snapshots validés
> - **Privilégier les snapshots disques seuls** : Plus rapides et moins gourmands en espace
> - **Monitorer l'espace disque** : Les snapshots peuvent rapidement consommer l'espace disponible

---

## Récapitulatif des commandes

### Tableau de référence rapide

|Commande|Action|Type|Sécurité|
|---|---|---|---|
|`controlvm <vm> pause`|Geler l'exécution|Réversible|✅ Sûr|
|`controlvm <vm> resume`|Reprendre l'exécution|Réversible|✅ Sûr|
|`controlvm <vm> reset`|Redémarrage forcé|Brutal|⚠️ Risqué|
|`controlvm <vm> poweroff`|Extinction forcée|Brutal|⚠️ Risqué|
|`controlvm <vm> savestate`|Hibernation|Propre|✅ Sûr|
|`controlvm <vm> acpipowerbutton`|Arrêt propre|Propre|✅ Sûr|
|`snapshot <vm> take <nom> --live`|Snapshot à chaud|Non-intrusif|✅ Sûr|

### Script complet d'administration

```bash
#!/bin/bash
# Script de gestion avancée d'une VM

VM_NAME="Ubuntu-Server"

# Fonction d'arrêt propre avec timeout
shutdown_vm() {
    echo "🔌 Envoi du signal d'arrêt ACPI..."
    VBoxManage controlvm "$VM_NAME" acpipowerbutton
    
    for i in {1..60}; do
        STATE=$(VBoxManage showvminfo "$VM_NAME" --machinereadable | grep "VMState=" | cut -d'"' -f2)
        if [ "$STATE" = "poweroff" ]; then
            echo "✅ VM éteinte proprement après $i secondes"
            return 0
        fi
        sleep 1
    done
    
    echo "⚠️ Timeout : extinction forcée"
    VBoxManage controlvm "$VM_NAME" poweroff
}

# Fonction de mise à jour avec protection snapshot
safe_update() {
    echo "📸 Création du snapshot de sécurité..."
    VBoxManage snapshot "$VM_NAME" take "Avant-Update-$(date +%Y%m%d-%H%M)" --live
    
    echo "🔄 Effectuer la mise à jour maintenant..."
    echo "   En cas de problème, restaurer avec :"
    echo "   VBoxManage snapshot '$VM_NAME' restore 'Avant-Update-...'"
}

# Fonction de sauvegarde longue durée
hibernate_vm() {
    echo "💾 Sauvegarde de l'état et hibernation..."
    VBoxManage controlvm "$VM_NAME" savestate
    echo "✅ VM en hibernation, ressources libérées"
}

# Menu principal
case "$1" in
    shutdown)
        shutdown_vm
        ;;
    update)
        safe_update
        ;;
    hibernate)
        hibernate_vm
        ;;
    pause)
        VBoxManage controlvm "$VM_NAME" pause
        echo "⏸️ VM en pause"
        ;;
    resume)
        VBoxManage controlvm "$VM_NAME" resume
        echo "▶️ VM reprise"
        ;;
    *)
        echo "Usage: $0 {shutdown|update|hibernate|pause|resume}"
        exit 1
        ;;
esac
```

### Aide-mémoire des états de VM

```
┌─────────────────────────────────────────────────────────┐
│                   États d'une VM                        │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  poweroff  ──startvm──> running ──acpipowerbutton──┐  │
│     ↑                      │                        │  │
│     │                      │                        ↓  │
│     │                   pause ────resume────>   poweroff
│     │                      │                           │
│     │                      ↓                           │
│     │                   paused                         │
│     │                      │                           │
│     │                   resume                         │
│     │                      │                           │
│     │                      ↓                           │
│     │                   running                        │
│     │                      │                           │
│     └──────savestate───────┘                           │
│                                                         │
│  saved ───startvm──> running                           │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

> [!tip] Mémo final
> 
> - **Pour éteindre** : Toujours `acpipowerbutton` en premier
> - **Pour sauvegarder** : `savestate` pour libérer les ressources
> - **Pour figer** : `pause` pour libérer le CPU uniquement
> - **Pour protéger** : `snapshot --live` avant toute opération risquée
> - **En urgence seulement** : `poweroff` ou `reset`

---

**📌 Points clés à retenir :**

1. ⚡ `controlvm` ne fonctionne que sur des VMs en cours d'exécution
2. 🛡️ Privilégiez toujours l'arrêt propre (`acpipowerbutton`) au lieu de l'arrêt forcé
3. 💾 `savestate` libère toutes les ressources tout en préservant l'état exact
4. ⏸️ `pause` est utile pour libérer temporairement le CPU
5. 📸 Les snapshots en live permettent de créer des points de restauration sans interruption
6. ⚠️ `reset` et `poweroff` sont des méthodes brutales à utiliser uniquement en dernier recours