## 1. Les outils de déploiement

|Outil|Type|Rôle principal|
|---|---|---|
|**WDS**|Rôle serveur Windows|Déploiement d'images via le réseau (PXE/TFTP)|
|**MDT**|Logiciel gratuit|Automatisation avancée via séquences de tâches|
|**WADK**|Suite d'outils|Boîte à outils pour créer et gérer les images|
|**SCCM**|Suite complète (payante)|Gestion globale du parc + déploiement|

### WDS (Windows Deployment Services)

- Successeur de RIS — rôle à ajouter sur un serveur Windows
- Nécessite : une **partition dédiée** + un **serveur DHCP** (AD DS optionnel)
- Déploie des images **WIM** via **PXE** (TFTP)
- Supporte les fichiers de réponse XML pour automatiser l'installation

### MDT (Microsoft Deployment Toolkit)

- Solution **gratuite**, nécessite **WADK** pour fonctionner
- Plus personnalisable que WDS : nom PC, jonction domaine, scripts, drivers, BitLocker…
- 2 modes :
    - **LiteTouch** (MDT seul) → interventions humaines requises
    - **ZeroTouch** (MDT + SCCM) → 100% automatisé
- ⚠️ MDT n'inclut **pas** de service TFTP → pas de PXE seul → combiner avec WDS

### WADK (Windows Assessment and Deployment Kit)

|Outil|Rôle|
|---|---|
|**USMT**|Migration des données utilisateur|
|**DISM**|Gestion des images WIM (pilotes, montage…)|
|**WinPE**|Environnement de préinstallation léger|
|**VAMT**|Activation de licences (MAK/KMS)|
|**Sysprep**|Initialisation d'un OS avant capture|
|**ACT**|Test de compatibilité des applications|

### SCCM (System Center Configuration Manager)

- Licence **propriétaire**, pour **grands parcs** informatiques
- Contient WDS + MDT
- Fonctions bonus : prise de main à distance, correctifs, inventaire, conformité, sécurité
- Architecture : CAS → Sites primaires (100k clients) → Sites secondaires (5k clients) → DP (4k clients)

---

## 2. Le déploiement Windows

### Déploiement standard (étapes)

```
Poste vierge → Boot (support/réseau) → WinPE → Assistant → Installation Windows → Poste prêt
```

### Le Master (image de référence)

|Type|Contenu|Avantage / Inconvénient|
|---|---|---|
|**Thin image**|OS uniquement|✅ Légère, flexible — logiciels déployés après|
|**Thick image**|OS + tous les logiciels|✅ Prête à l'emploi — ❌ à refaire à chaque MAJ|
|**Hybrid image**|OS + logiciels de base|✅ Bon compromis|

### Sysprep — Préparer le master

Outil qui "rescelle" un Windows pour le rendre déployable sur d'autres machines.

```
C:\Windows\System32\sysprep\sysprep.exe /oobe /generalize /shutdown
```

|Option|Rôle|
|---|---|
|`/oobe`|Lance la séquence de personnalisation au 1er démarrage|
|`/generalize`|Rend l'image compatible avec tout type de matériel|
|`/shutdown`|Éteint le PC après le sysprep|

> ⚠️ **Ne jamais rallumer le PC après un sysprep** — capturer l'image directement !

---

## 3. Les technologies clés

### WinPE (Windows Preinstallation Environment)

- Noyau léger de Windows, successeur de MS-DOS
- Utilisable depuis le réseau ou un support amovible
- Disponible dans MDT et WDS
- Commandes utiles via `diskpart` :

```
list disk          → liste les disques
list volume        → liste les volumes
clean              → supprime toutes les partitions
create partition   → crée une partition
active             → rend un volume bootable
```

### PXE (Preboot Execution Environment) — Boot réseau

```
1. Client → DHCP (UDP 67) : demande @IP + fichier d'amorçage
2. DHCP → Client (UDP 68) : @IP + options PXE (60, 66, 67)
3. Client → TFTP : téléchargement du fichier d'amorce
4. Client → HTTP : récupération de l'installateur
```

> PXE n'est pas propre à Windows (ex : Syslinux sur Linux)

### WIM (Windows Imaging Format)

- Format d'image disque Microsoft (`.wim` / `.swm`)
- **Indépendant du matériel** — 1 fichier peut contenir plusieurs images
- Basé sur les fichiers/métadonnées (≠ .ghost orienté secteurs)

**Gestion avec DISM :**

|Action|Commande|
|---|---|
|Monter une image|`DISM /Mount-Wim /WimFile:fichier.WIM /index:N /MountDir:Dossier`|
|Sauvegarder les modifs|`DISM /Unmount-Wim /MountDir:Dossier /commit`|

> `install.wim` et `boot.wim` (WinPE) se trouvent dans le dossier `sources` de l'ISO Windows.

---

## 4. Vue d'ensemble — Qui fait quoi ?

```
WADK (Sysprep, DISM, WinPE…)
    ↓ crée/gère
Image WIM
    ↓ déployée par
WDS ──(PXE/TFTP)──────────────────→ Client
MDT ──(LiteTouch)─────────────────→ Client
MDT + WDS ────────────────────────→ Client
MDT + SCCM ──(ZeroTouch)──────────→ Client
```

---

## 5. Comparatif rapide WDS / MDT / SCCM

| |WDS|MDT|SCCM|
|---|---|---|---|
|Coût|Gratuit (rôle)|Gratuit|Payant|
|PXE natif|✅|❌ (besoin WDS)|✅|
|Personnalisation|Basique|Avancée|Très avancée|
|Taille de parc|Petite/moyenne|Moyenne|Grande|
|Intervention humaine|Oui|Oui (LiteTouch)|Non (ZeroTouch)|
