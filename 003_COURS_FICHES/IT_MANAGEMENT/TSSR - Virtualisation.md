## ⚡ L'essentiel en 5 minutes - La Virtualisation

### 📌 C'est quoi en 2 lignes ?

Créer des machines virtuelles (VM) qui partagent les ressources d'un serveur physique via un hyperviseur. Permet d'exécuter plusieurs OS isolés sur une même machine pour optimiser le matériel et faciliter la gestion.

---

### 💡 Concepts clés à retenir :

- **Machine Virtuelle (VM)** : Ordinateur virtuel hébergé par un système hôte avec son propre OS invité
- **Hyperviseur** : Couche logicielle qui permet à plusieurs VM de fonctionner simultanément sur une machine physique
- **Host OS / Guest OS** : Système d'exploitation principal (hôte) vs système installé dans la VM (invité)
- **Overhead** : Ressources supplémentaires nécessaires pour faire fonctionner l'hyperviseur (CPU, RAM)
- **Paravirtualisation** : Les VM "savent" qu'elles sont virtualisées et peuvent faire des appels directs à l'hyperviseur (hyper-call) pour réduire l'overhead

---

### 💻 Types d'hyperviseurs :

```bash
# 🏢 Type 1 - Bare Metal (production)
VMware ESXi          # Leader du marché, robuste, payant
Microsoft Hyper-V    # Intégration Windows, payant
Xen                  # Open source, haute performance
KVM                  # Open source Linux
Proxmox VE           # Open source, interface web, VM + conteneurs

# 💻 Type 2 - Hosted (développement/test)
VirtualBox           # Open source, gratuit, formation
VMware Workstation   # Payant, professionnel
QEMU                 # Open source, émulation + virtualisation
```

---

### 🔄 Différences essentielles :

|Concept|Définition|Exemple|
|---|---|---|
|**Simulation**|Modèle abstrait qui reproduit le comportement d'un système|Calcul d'heure d'arrivée, Packet Tracer|
|**Émulation**|Reproduit à l'identique le fonctionnement d'un système (toutes les variables)|Console de jeu sur PC, ARM sur x86, GNS3|
|**Virtualisation**|Émulation utilisant l'architecture du système hôte (même CPU)|Windows dans Proxmox sur serveur x86|
|**Paravirtualisation**|Les VM interagissent directement avec l'hyperviseur (hyper-calls)|Réduit l'overhead, performances optimales|

---

### 📊 Architecture comparée :

**Type 1 (Bare Metal)** :

```
┌─────────────────────────────┐
│   VM1    │   VM2    │   VM3  │  ← Guest OS
├─────────────────────────────┤
│      Hyperviseur Type 1      │  ← VMware ESXi, Hyper-V
├─────────────────────────────┤
│    Serveur physique (HW)     │
└─────────────────────────────┘
```

**Type 2 (Hosted)** :

```
┌─────────────────────────────┐
│   VM1    │   VM2    │   VM3  │  ← Guest OS
├─────────────────────────────┤
│      Hyperviseur Type 2      │  ← VirtualBox, VMware WS
├─────────────────────────────┤
│      OS Hôte (Windows/Linux) │
├─────────────────────────────┤
│    Serveur physique (HW)     │
└─────────────────────────────┘
```

---

### ⚖️ Avantages & Inconvénients :

**✅ AVANTAGES** :

- **Consolidation serveurs** : 3 serveurs physiques → 1 serveur avec 3 VM = économies (matériel, énergie)
- **Isolation** : Une VM qui plante n'affecte pas les autres
- **Flexibilité** : Clonage, templates, migration à chaud
- **Déploiement rapide** : Créer une VM en minutes vs installer un serveur physique

**❌ INCONVÉNIENTS** :

- **SPOF (Single Point Of Failure)** : Si le serveur physique tombe, toutes les VM tombent → nécessite redondance
- **Overhead** : L'hyperviseur consomme des ressources (CPU, RAM) → dimensionner en conséquence
- **Complexité** : Erreur peut venir du Guest OS, Host OS, hyperviseur ou matériel
- **Performance** : Toujours inférieure au bare metal (sauf avec paravirtualisation optimale)

---

### ⚠️ Pièges à éviter :

- ❌ **Consolider sans analyser les pics** : Si 3 VM sollicitent le CPU à 40% en même temps → saturation à 120% !
- ❌ **Pas de redondance** : Un seul serveur physique = toutes les VM perdues en cas de panne
- ❌ **Sous-dimensionnement** : Oublier l'overhead → performances dégradées
- ❌ **Confondre émulation et virtualisation** : ARM sur x86 = émulation (lent) ≠ Linux sur x86 dans VM = virtualisation (rapide)
- ❌ **Applications critiques I/O** : Carte matérielle spécifique ou haute performance → parfois incompatible avec virtualisation

---

### ✅ Bonnes pratiques :

- ✅ **Utiliser Type 1 en production** : Performances optimales (accès direct matériel)
- ✅ **Mettre en place la HA (Haute Disponibilité)** : Clustering, VM de secours prêtes à démarrer
- ✅ **Créer des templates** : Déploiement rapide et standardisé des nouvelles VM
- ✅ **Dimensionner avec overhead** : Prévoir 10-20% de ressources supplémentaires pour l'hyperviseur
- ✅ **Séparer les charges** : Ne pas mettre toutes les VM critiques sur le même serveur physique
- ✅ **Virtualisation du stockage** : Facilite la migration et la sauvegarde (VMDK, QCOW2)

---

### 📚 Vocabulaire technique :

|Terme|Définition courte|
|---|---|
|**VM (Virtual Machine)**|Ordinateur virtuel avec son propre OS invité|
|**Hyperviseur**|Logiciel gérant plusieurs VM sur un serveur physique|
|**Host OS**|Système d'exploitation principal du serveur physique|
|**Guest OS**|Système d'exploitation installé dans une VM|
|**Overhead**|Ressources consommées par l'hyperviseur (10-20% CPU/RAM)|
|**SPOF**|Single Point Of Failure = point de défaillance unique|
|**HA**|High Availability = haute disponibilité (redondance automatique)|
|**Bare Metal**|Installation directe sur le matériel (Type 1)|
|**Template**|Modèle de VM préconfiguré pour déploiement rapide|
|**Migration à chaud**|Déplacer une VM d'un serveur à l'autre sans interruption|
|**Clustering**|Regrouper plusieurs serveurs pour partager les VM|

---

### 🎯 À retenir ABSOLUMENT :

1. 💡 **Théorique** : Hyperviseur Type 1 = bare metal (production), Type 2 = sur OS (dev/test). Paravirtualisation réduit l'overhead.
    
2. 💻 **Pratique** : Proxmox (formation) = VM + conteneurs, interface web. VMware ESXi = leader production mais payant. VirtualBox = gratuit formation.
    
3. ⚠️ **Piège** : SPOF → toujours prévoir redondance ! Overhead → dimensionner +20% ressources. Pics simultanés → analyser avant consolidation.
    

---

**🔑 Schéma mental rapide** :

- **SIMULATION** = modèle simplifié (Packet Tracer)
- **ÉMULATION** = copie exacte (console Playstation sur PC)
- **VIRTUALISATION** = émulation optimisée (même architecture CPU)
- **Type 1** = sur matériel → PROD
- **Type 2** = sur OS → DEV/TEST