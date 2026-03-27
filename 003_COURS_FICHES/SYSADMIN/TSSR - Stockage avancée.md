# ⚡ L'essentiel en 5 minutes - Stockage Avancé RAID/LVM

## 📌 C'est quoi en 2 lignes ?

Techniques pour virtualiser et optimiser le stockage : **RAID** agrège plusieurs disques physiques pour améliorer performance/fiabilité, **LVM** crée une couche d'abstraction flexible permettant redimensionnement et snapshots à chaud.

---

## 💡 Concepts clés à retenir

- **RAID** : Redundant Array of Independent Disks - agrégation de disques physiques en volume unique
- **LVM** : Logical Volume Manager - virtualisation du stockage en 3 couches (PV → VG → LV)
- **Physical Volume (PV)** : Disque ou partition utilisé par LVM (peut être un RAID)
- **Volume Group (VG)** : Pool de stockage regroupant plusieurs PV
- **Logical Volume (LV)** : Partition virtuelle créée depuis un VG (équivalent partition classique)
- **Physical Extent (PE)** : Unité d'allocation du VG (4 Mo par défaut)
- **Snapshot (COW)** : Copie instantanée d'un LV via Copy-On-Write
- **Striping** : Répartition des données par bandes sur plusieurs disques (parallélisation)
- **Mirroring** : Duplication des données sur plusieurs disques (redondance)
- **Hot-plug** : Remplacement de disque sans arrêter le système

---

## 💻 Commandes essentielles

```bash
# 🐧 LVM - Gestion des volumes physiques
pvcreate /dev/sdb1              # Initialiser une partition en PV
pvdisplay                       # Afficher les PV
pvremove /dev/sdb1              # Supprimer un PV

# 🐧 LVM - Gestion des groupes de volumes
vgcreate vg_data /dev/sdb1      # Créer un VG
vgextend vg_data /dev/sdc1      # Ajouter un PV au VG
vgdisplay                       # Afficher les VG
vgreduce vg_data /dev/sdc1      # Retirer un PV du VG

# 🐧 LVM - Gestion des volumes logiques
lvcreate -L 10G -n lv_app vg_data   # Créer un LV de 10 Go
lvcreate -l 100%FREE -n lv_all vg   # Utiliser tout l'espace libre
lvdisplay                           # Afficher les LV
lvextend -L +5G /dev/vg_data/lv_app # Agrandir de 5 Go
lvextend -l +100%FREE /dev/vg/lv    # Utiliser tout l'espace libre
lvreduce -L -2G /dev/vg_data/lv_app # Réduire de 2 Go (DANGEREUX)
lvremove /dev/vg_data/lv_app        # Supprimer un LV

# 🐧 LVM - Redimensionnement du système de fichiers
resize2fs /dev/vg_data/lv_app       # Adapter le FS ext4 à la taille LV
xfs_growfs /mnt/app                 # Étendre un FS XFS monté

# 🐧 LVM - Snapshots
lvcreate -L 1G -s -n snap_app /dev/vg_data/lv_app  # Créer snapshot
lvconvert --merge /dev/vg_data/snap_app             # Restaurer snapshot

# 🐧 RAID logiciel (mdadm)
mdadm --create /dev/md0 --level=5 --raid-devices=3 /dev/sd[bcd]1  # Créer RAID 5
mdadm --detail /dev/md0             # Afficher détails RAID
mdadm --manage /dev/md0 --add /dev/sde1    # Ajouter disque
mdadm --manage /dev/md0 --fail /dev/sdb1   # Marquer disque défaillant
mdadm --manage /dev/md0 --remove /dev/sdb1 # Retirer disque
cat /proc/mdstat                    # Vérifier état RAID
```

---

## 📐 Niveaux RAID : Comparatif

|Niveau|Min disques|Capacité|Perf lecture|Perf écriture|Pannes tolérées|Usage|
|---|---|---|---|---|---|---|
|**JBOD**|1|100%|=|=|0|Simple agrégation|
|**RAID 0**|2|100%|×N|×N|0|Performance max|
|**RAID 1**|2|50%|≈|≈|N-1|Fiabilité max|
|**RAID 4**|3|(N-1)/N|×(N-1)|Faible|1|Obsolète|
|**RAID 5**|3|(N-1)/N|×(N-1)|Moyenne|1|Équilibre perf/fiabilité|
|**RAID 6**|4|(N-2)/N|×(N-2)|Faible|2|Fiabilité élevée|
|**RAID 10**|4|50%|×N/2|×N/2|1 par miroir|Best compromise|

**Formule capacité utile :**

- RAID 0/JBOD : N × taille_min
- RAID 1 : 1 × taille_min
- RAID 5 : (N-1) × taille_min
- RAID 6 : (N-2) × taille_min

---

## ⚠️ Pièges à éviter

- ❌ **Réduire un LV sans réduire le FS avant** : Perte de données garantie (LVM ne connaît pas le FS)
- ❌ **Utiliser RAID 0 pour données critiques** : Aucune tolérance aux pannes, risque × N
- ❌ **Croire que RAID = sauvegarde** : Protection contre panne matérielle uniquement (pas contre suppression/corruption)
- ❌ **Mélanger disques de tailles/perfs différentes** : Grappe limitée par le plus petit/lent disque
- ❌ **XFS : tenter de réduire** : XFS ne supporte PAS la réduction, seulement l'extension
- ❌ **Oublier de redimensionner le FS après LV** : Le FS reste à sa taille initiale même si le LV grandit
- ❌ **Ne pas étiqueter les partitions en LVM** : Risque que d'autres outils considèrent le disque comme vide
- ❌ **Saturer un snapshot** : Si le snapshot est plein, il devient invalide et inutilisable

---

## ✅ Bonnes pratiques

- ✅ **Utiliser des disques identiques dans un RAID** : Évite les pertes de capacité et problèmes de performance
- ✅ **Prévoir un disque de spare** : Reconstruction automatique en cas de panne
- ✅ **Toujours faire une partition étiquetée LVM** : Même pour un disque complet (évite confusion avec disque vide)
- ✅ **Réduire FS avant LV (dans cet ordre)** : 1) Réduire FS à taille cible-10%, 2) Réduire LV, 3) Agrandir FS à 100%
- ✅ **Regrouper PV similaires dans même VG** : Performance, fiabilité, usage cohérents
- ✅ **Surveiller l'espace des snapshots** : Un snapshot plein devient invalide
- ✅ **Utiliser hot-plug** : Remplacement de disque RAID sans extinction du serveur
- ✅ **Ne laisser que 10-20% d'espace libre** : Dans un VG pour flexibilité future
- ✅ **Tester les sauvegardes régulièrement** : RAID protège contre panne matérielle, pas erreur humaine

---

## 📚 Vocabulaire technique

|Terme|Définition courte|
|---|---|
|**Striping**|Répartition des données par bandes sur plusieurs disques pour paralléliser lectures/écritures|
|**Mirroring**|Duplication complète des données sur plusieurs disques (redondance)|
|**Parité**|Information calculée (XOR) permettant reconstruction données après 1 panne|
|**COW (Copy-On-Write)**|Mécanisme copiant les données uniquement lors d'une modification (base des snapshots)|
|**PE/LE (Physical/Logical Extent)**|Unité d'allocation de 4 Mo (par défaut) pour découper PV et LV|
|**Hot-plug**|Capacité à remplacer un disque sans éteindre le système|
|**Spare disk**|Disque de réserve prêt à remplacer automatiquement un disque défaillant|
|**SAN**|Storage Area Network - réseau dédié au stockage (protocoles Fibre Channel, iSCSI)|
|**NAS**|Network Attached Storage - serveur de fichiers distant (protocoles NFS, SMB/CIFS)|
|**mdadm**|Outil Linux de gestion du RAID logiciel|
|**Snapshot**|Copie instantanée d'un LV à un instant T (consomme peu d'espace initial)|

---

## 🎯 À retenir ABSOLUMENT (3 points max)

1. 💡 **Architecture LVM** : PV (disques) → VG (pool) → LV (partitions) → FS (fichiers)
    
2. 💻 **Séquence sûre agrandissement** : `lvextend -L +5G /dev/vg/lv && resize2fs /dev/vg/lv`
    
3. ⚠️ **RAID ≠ Sauvegarde** : Protège contre panne matérielle uniquement, pas contre erreur humaine/corruption/incendie