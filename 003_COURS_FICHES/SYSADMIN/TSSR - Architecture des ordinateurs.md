# ⚡ L'essentiel en 5 minutes - Architecture des ordinateurs

## 📌 C'est quoi en 2 lignes ?

Un ordinateur est une machine électronique numérique programmable qui effectue des opérations arithmétiques de base. Il suit l'architecture de Von Neumann : UAL (calculs) + Unité de contrôle (orchestration) + Mémoire (stockage) + Entrées/Sorties (communication).

---

## 💡 Concepts clés à retenir :

- **Bit** : Unité élémentaire binaire (0 ou 1) pour stocker l'information
- **Octet (Byte)** : 8 bits regroupés = 256 valeurs possibles (0-255)
- **CPU (Central Processing Unit)** : Circuit intégré qui exécute les instructions (UAL + contrôle + registres + cache)
- **RAM (Random Access Memory)** : Mémoire vive à accès direct, temporaire, efface au redémarrage
- **Secteur** : Plus petite unité de stockage sur disque (généralement 512 octets)
- **Registre** : Mémoire ultra-rapide dans le CPU pour données immédiates
- **Cache** : Mémoires L1/L2/L3 entre CPU et RAM pour accélérer l'accès aux données fréquentes
- **Partition** : Découpage logique d'un disque physique en zones distinctes

---

## 💻 Composants essentiels :

### 🧠 CPU caractérisé par :

```
- Jeu d'instruction (x86-64, ARMv8...)
- Fréquence (GHz) : cycles par seconde
- Nombre de cœurs (cores)
- Taille registres (32/64 bits)
- Cache L1/L2/L3
```

### 💾 Hiérarchie mémoire (du + rapide au + lent) :

```
Registres       → Données unitaires, vitesse CPU (ns)
Cache L1        → ~10-100 KiB, CPU/2 à CPU/4
Cache L2        → ~256 KiB-MiB, L1/4
Cache L3        → ~10 MiB, L2/4
RAM             → ~10-64 GiB, CPU/100
SSD             → ~1 TiB, 0.1 ms
HDD             → ~10 TiB, 10 ms
LTO/Cloud       → Archivage long terme
```

### 💿 Types de stockage :

```
HDD (Hard Disk Drive)     → Mécanique, plateau/tête, séquentiel, pannes mécaniques
SSD (Solid State Drive)   → Électronique, mémoire flash, accès direct, limite d'écriture
```

---

## 📐 Calculs / Formules :

- **Valeurs binaires** : 2^n (n = nombre de bits) → 2^8 = 256 valeurs
- **Capacité max partition 32 bits** : 2^32 secteurs × 512 octets = 2 TiB
- **Capacité max partition 64 bits** : 2^64 secteurs × 512 octets = 8 ZiB (zibioctets)

**Exemple concret :**

```
Secteurs de 512 octets avec adresses 32 bits :
- 2^32 = 4 294 967 296 secteurs max
- 4 294 967 296 × 512 = 2 199 023 255 552 octets
- ≈ 2 TiB (tébioctets)
```

---

## ⚠️ Pièges à éviter :

- ❌ **Confondre bit et octet** : 1 octet = 8 bits (pas 1 bit = 1 octet !)
- ❌ **Confondre RAM et stockage** : RAM = temporaire/rapide, HDD/SSD = permanent/lent
- ❌ **MBR sur disques >2 TiB** : Utiliser GPT obligatoirement au-delà de 2 TiB
- ❌ **Négliger la taille des secteurs** : 512 octets standard, mais 4096 octets possible (Advanced Format)
- ❌ **Nombres binaires négatifs** : -1 n'existe pas en binaire pur (nécessite représentation signée)

---

## ✅ Bonnes pratiques :

- ✅ **Privilégier GPT à MBR** : Support disques >2 TiB, 128 partitions max, redondance des métadonnées
- ✅ **Optimiser hiérarchie mémoire** : Données fréquentes en cache, volumineuses sur disque
- ✅ **Respecter les types de partitions** : Flags/GUID selon usage (système, données, swap...)
- ✅ **Surveiller température CPU** : Refroidissement critique pour performances et durée de vie
- ✅ **Comprendre le BIOS/UEFI** : Interface firmware pour démarrage et configuration matérielle

---

## 📚 Vocabulaire technique :

|Terme|Définition courte|
|---|---|
|**UAL**|Unité Arithmétique et Logique - effectue calculs et opérations logiques|
|**Architecture Von Neumann**|Modèle avec mémoire unique pour données ET programmes|
|**Machine de Turing**|Modèle théorique de calcul universel|
|**BIOS**|Basic Input Output System - firmware historique de la carte mère|
|**UEFI**|Unified Extensible Firmware Interface - remplaçant moderne du BIOS|
|**MBR**|Master Boot Record - partitionnement Intel historique (max 4 primaires, 2 TiB)|
|**GPT**|GUID Partition Table - standard moderne (128 partitions, 8 ZiB)|
|**EBR**|Extended Boot Record - table pour partitions logiques dans MBR|
|**GUID**|Globally Unique IDentifier - identifiant unique pour partitions GPT|
|**ROM**|Read-Only Memory - mémoire morte non volatile|
|**Chipset**|Circuit de la carte mère gérant communication CPU/périphériques|
|**PCI Express**|Bus d'extension moderne pour cartes (GPU, réseau...)|
|**SATA / M.2 / NVMe**|Interfaces de connexion pour disques (vitesses croissantes)|

---

## 🎯 À retenir ABSOLUMENT (3 points max) :

1. 💡 **Théorique** : 1 octet = 8 bits = 256 valeurs | Hiérarchie mémoire : Registres > Cache L1/L2/L3 > RAM > SSD > HDD
2. 💻 **Pratique** : CPU caractérisé par jeu d'instruction (x86-64/ARM), fréquence (GHz), cores, cache | Utiliser GPT (pas MBR) pour disques modernes
3. ⚠️ **Piège** : MBR limité à 2 TiB → Erreur fatale sur disques récents | RAM = volatile (perte au redémarrage) ≠ Stockage permanent