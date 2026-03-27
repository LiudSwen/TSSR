## 🔑 Les 3 critères du stockage

|Critère|Question clé|
|---|---|
|**Volume**|Quelle capacité ? Évolution dans le temps ?|
|**Performance**|Débit / latence suffisants ?|
|**Sûreté**|Tolérance de panne ? Sauvegarde ?|

> 💡 Supports : **HDD** (≈100 Mo/s, 20-30€/To) < **SSD** (≈3-7 Go/s, ~100€/To)

---

## ⚙️ RAID — Redundant Array of Independent Disks

### Principe

Virtualisation du stockage via plusieurs disques physiques pour améliorer **taille**, **performance** ou **fiabilité**.

### Types d'implémentation

|Type|Avantages|Inconvénients|
|---|---|---|
|**Matériel**|Excellentes perfs, transparent pour l'OS, boot possible|Coûteux, propriétaire|
|**Logiciel** (mdadm)|Souple, standard, gratuit|Consomme du CPU, boot compliqué|
|**Hybride**|Boot possible|Problèmes de compat., CPU, fonctions limitées|

### Niveaux de RAID

|Niveau|Principe|Capacité|Performance|Tolérance|Disques min.|
|---|---|---|---|---|---|
|**JBOD**|Concaténation|∑ disques|Identique|❌ Médiocre|1|
|**RAID 0**|Striping|n × plus petit|✅ Gain (×n)|❌ Mauvaise|2|
|**RAID 1**|Mirroring|= plus petit|≈ Identique|✅ Excellente (n-1 pannes)|2|
|**RAID 4**|Striping + parité dédiée|(n-1) × plus petit|✅ Gain|✅ 1 panne|3|
|**RAID 5**|Striping + parité répartie (round-robin)|(n-1) × plus petit|✅ Légèrement mieux que RAID 4|✅ 1 panne|3|
|**RAID 6**|RAID 5 + double parité|(n-2) × plus petit|✅ Gain|✅✅ 2 pannes|4|
|**RAID 10**|RAID 0 de grappes RAID 1|50%|✅✅|✅✅|4|

### Points importants

- Utiliser des disques **identiques** dans une grappe
- Un **disque de spare** permet la reconstruction automatique
- Associé à des disques **hot plug** (remplaçables à chaud)
- ⚠️ **Le RAID ne remplace pas les sauvegardes !**

---

## 📐 LVM — Logical Volume Manager

### Architecture (3 couches)

```
Logical Volumes (LV)   ← partitions logiques (portent le FS)
       ↑
  Volume Group (VG)    ← couche d'abstraction (pool de stockage)
       ↑
Physical Volumes (PV)  ← disques, partitions, volumes RAID, SAN
```

### Concepts clés

|Terme|Description|
|---|---|
|**PV**|Partition, disque, RAID ou SAN|
|**VG**|Pool = somme des PV. Unité : **Physical Extents (PE)**|
|**LV**|Découpage du VG. Unité : **Logical Extents (LE)**. Porte le FS|
|**Snapshot**|Copie instantanée via **Copy-On-Write (COW)**|

### Opérations clés

- **Agrandir** un LV → sûr (dans la limite du VG)
- **Rétrécir** un LV → ⚠️ risqué (réduire d'abord le FS, puis le LV)
- **Ajouter un PV** au VG → espace immédiatement disponible pour tous les LV
- Support RAID natif dans LVM (0, 1, 4, 5, 6, 10)

### Compatibilité redimensionnement à chaud

|FS|Agrandir|Rétrécir|
|---|---|---|
|**ext4**|✅|✅ (avec précaution)|
|**XFS**|✅|❌|

---

## 🌐 SAN & NAS — Stockage réseau

### NAS — Network Attached Storage

Partage de **systèmes de fichiers** via le réseau.

|Protocole|Usage|Port|
|---|---|---|
|**NFS**|Montage FS distant (Unix/Linux)|TCP/UDP **2049**|
|**SMB/CIFS**|Partage Windows|TCP **445** (139 legacy)|
|**FTP**|Transfert de fichiers|TCP **21** (données: 20)|
|**SFTP**|FTP chiffré (via SSH)|TCP **22**|

### SAN — Storage Area Network

Accès distant à des **périphériques de blocs** (bas niveau), via réseau dédié.

|Protocole|Description|Port|
|---|---|---|
|**Fibre Channel**|SCSI sur réseau LAN dédié|N/A (réseau FC)|
|**iSCSI**|SCSI sur IP (Ethernet)|TCP **3260**|
|**FCoE**|Fibre Channel sur Ethernet|N/A|

### Comparatif SAN vs NAS

| |**NAS**|**SAN**|
|---|---|---|
|Niveau d'accès|Fichier (FS)|Bloc (bas niveau)|
|Protocoles|NFS, SMB, FTP|iSCSI, FC, FCoE|
|Complexité|Faible|Élevée|
|Performance|Moyenne|Très haute|
|Coût|Abordable|Élevé|

---

## 🗂️ Répertoires à isoler (bonnes pratiques)

- `/var/log` — logs
- `/tmp` — fichiers temporaires
- Bases de données
- Fichiers utilisateurs
- Espace de swap

> ⚠️ Un stockage plein = système/application qui plante → **cloisonner** pour limiter les impacts.

---

## 📚 Pour aller plus loin

- **ZFS** — système de fichiers nouvelle génération (RAID intégré, snapshots, checksums)
- **btrfs** — alternative Linux moderne (copy-on-write natif)