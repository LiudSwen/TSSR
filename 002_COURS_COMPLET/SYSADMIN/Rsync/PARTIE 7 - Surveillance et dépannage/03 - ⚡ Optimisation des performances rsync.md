

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

## 🎯 Comprendre les facteurs de performance

Avant d'optimiser, il est crucial de comprendre ce qui impacte les performances de rsync.

### Les trois piliers de performance

> [!info] Facteurs clés
> 
> 1. **Bande passante réseau** : vitesse de transmission des données
> 2. **CPU** : utilisé pour la compression, le chiffrement SSH, et les comparaisons de fichiers
> 3. **I/O disque** : lecture/écriture des fichiers source et destination

### Identifier le goulot d'étranglement

```bash
# Observer l'utilisation des ressources pendant un transfert
# Terminal 1 : lancer rsync avec stats
rsync -avz --progress --stats /source/ user@remote:/dest/

# Terminal 2 : surveiller les ressources
watch -n 1 'top -bn1 | head -20'
iostat -x 2
iftop  # nécessite installation
```

> [!tip] Diagnostic rapide
> 
> - **CPU à 100%** → problème de compression ou chiffrement
> - **Faible CPU, faible bande passante** → limitation réseau
> - **I/O élevé, faible réseau** → disques lents

---

## 🚦 Limitation de la bande passante

### L'option `--bwlimit`

Permet de limiter la bande passante utilisée pour ne pas saturer la connexion.

```bash
# Syntaxe
rsync --bwlimit=VALEUR [options] source destination

# VALEUR en Ko/s (kilooctets par seconde)
```

### Exemples pratiques

```bash
# Limiter à 1 Mo/s (1000 Ko/s)
rsync -av --bwlimit=1000 /data/ user@backup:/backup/

# Limiter à 500 Ko/s pour ne pas saturer une connexion modeste
rsync -avz --bwlimit=500 /home/ user@remote:/backup/home/

# Limiter à 5 Mo/s pour les gros transferts
rsync -av --bwlimit=5000 /var/www/ user@web:/var/www/
```

> [!warning] Attention à l'unité `--bwlimit` utilise des **Ko/s** (kilooctets par seconde), pas des Mbps (mégabits par seconde).
> 
> Conversion : 1 Mo/s = 8 Mbps
> 
> - Connexion 100 Mbps → environ 12500 Ko/s maximum théorique
> - Connexion 10 Mbps → environ 1250 Ko/s maximum théorique

### Calcul de la limite appropriée

|Type de connexion|Débit théorique|Limite recommandée|Valeur --bwlimit|
|---|---|---|---|
|ADSL (8 Mbps upload)|1 Mo/s|70% = 700 Ko/s|`--bwlimit=700`|
|Fibre (100 Mbps)|12.5 Mo/s|70% = 8750 Ko/s|`--bwlimit=8750`|
|Lien dédié (1 Gbps)|125 Mo/s|70% = 87500 Ko/s|`--bwlimit=87500`|
|Connexion partagée|Variable|30-50% du total|Ajuster selon contexte|

> [!example] Cas d'usage : sauvegarde en journée
> 
> ```bash
> #!/bin/bash
> # Script avec limitation horaire
> 
> HEURE=$(date +%H)
> 
> # Heures de bureau : limitation stricte
> if [ $HEURE -ge 9 ] && [ $HEURE -lt 18 ]; then
>     LIMITE=500
> else
>     # Nuit/weekend : pas de limitation
>     LIMITE=0
> fi
> 
> rsync -av --bwlimit=$LIMITE /data/ backup:/backup/
> ```

---

## 🗜️ Optimisation de la compression

### Quand utiliser la compression (`-z`)

La compression est un compromis entre CPU et bande passante.

> [!info] Principe
> 
> - **Active la compression** : réduit les données transférées → économise la bande passante
> - **Coût CPU** : nécessite de compresser/décompresser → consomme du processeur

### Matrice de décision

|Scénario|Utiliser `-z` ?|Raison|
|---|---|---|
|Transfert local (même machine)|❌ Non|Pas de limitation réseau, CPU gaspillé|
|Réseau local 1 Gbps|❌ Non|Bande passante abondante|
|Connexion Internet lente|✅ Oui|Bande passante limitée|
|Fichiers déjà compressés (.jpg, .mp4, .zip)|❌ Non|Pas de gain, perte CPU|
|Fichiers texte/logs|✅ Oui|Excellent taux de compression|
|SSH sur WAN|✅ Oui|SSH + compression = optimal|

### Exemples comparatifs

```bash
# Sans compression : rapide sur LAN
rsync -av /data/ server:/backup/

# Avec compression : optimal pour Internet
rsync -avz /data/ remote:/backup/

# Compression pour fichiers texte uniquement
rsync -av --compress-choice=zstd --skip-compress=gz/zip/z/rpm/deb/iso/bz2/tgz/7z/mp3/mp4/mov/avi/jpg/jpeg/png \
    /data/ remote:/backup/
```

### Niveau de compression personnalisé

```bash
# Compression standard (niveau 6 par défaut)
rsync -avz /source/ remote:/dest/

# Compression maximale (niveau 9) - très lent
rsync -av --compress-level=9 /source/ remote:/dest/

# Compression légère (niveau 1) - rapide
rsync -av --compress-level=1 /source/ remote:/dest/
```

> [!tip] Algorithme moderne : zstd Depuis rsync 3.2.0, l'algorithme **zstd** offre un meilleur ratio vitesse/compression que gzip.
> 
> ```bash
> # Utiliser zstd (si disponible)
> rsync -av --compress-choice=zstd /source/ remote:/dest/
> 
> # Vérifier les algorithmes disponibles
> rsync --version | grep -i compress
> ```

---

## 📦 Gestion de la taille des transferts

### Option `--max-size` et `--min-size`

Permet de filtrer les fichiers par taille pour optimiser les transferts.

```bash
# Syntaxe
rsync --max-size=TAILLE [options] source destination
rsync --min-size=TAILLE [options] source destination

# Unités : K (Ko), M (Mo), G (Go)
```

### Exemples pratiques

```bash
# Transférer uniquement les fichiers < 10 Mo
rsync -av --max-size=10M /photos/ backup:/photos/

# Exclure les petits fichiers < 1 Ko (caches, thumbnails)
rsync -av --min-size=1K /data/ backup:/data/

# Combiner les deux : fichiers entre 100 Ko et 100 Mo
rsync -av --min-size=100K --max-size=100M /documents/ backup:/documents/

# Sauvegarder les gros fichiers séparément
rsync -av --min-size=1G /media/ backup:/media/large/
rsync -av --max-size=1G /media/ backup:/media/small/
```

> [!example] Cas d'usage : optimisation de la synchronisation
> 
> ```bash
> #!/bin/bash
> # Stratégie de sauvegarde par taille
> 
> SOURCE="/data"
> DEST="backup:/backup"
> 
> # Petits fichiers : souvent modifiés, sync fréquent
> rsync -avz --max-size=10M $SOURCE/ $DEST/small/
> 
> # Gros fichiers : rarement modifiés, sync hebdomadaire
> rsync -av --min-size=10M $SOURCE/ $DEST/large/
> ```

### Option `--partial`

Reprend les transferts interrompus pour les gros fichiers.

```bash
# Activer la reprise des transferts partiels
rsync -avz --partial /large-files/ remote:/backup/

# Combinaison recommandée : --partial + --progress
rsync -avz --partial --progress /videos/ remote:/backup/

# Option combinée -P équivaut à --partial --progress
rsync -avzP /videos/ remote:/backup/
```

> [!tip] Astuce pro : `--partial-dir` Place les fichiers partiels dans un répertoire temporaire.
> 
> ```bash
> # Évite de polluer la destination avec des fichiers incomplets
> rsync -av --partial-dir=.rsync-partial /source/ remote:/dest/
> ```

---

## 🚀 Techniques d'optimisation avancées

### Parallélisation avec `--info=progress2`

Affiche la progression globale plutôt que fichier par fichier.

```bash
# Progression globale : plus clair pour de nombreux fichiers
rsync -av --info=progress2 /source/ remote:/dest/

# Combinaison optimale
rsync -av --info=progress2 --human-readable /source/ remote:/dest/
```

### Optimisation SSH

Le chiffrement SSH consomme beaucoup de CPU. Quelques optimisations possibles :

```bash
# Utiliser un algorithme de chiffrement plus rapide
rsync -av -e "ssh -c aes128-gcm@openssh.com" /source/ remote:/dest/

# Désactiver la compression SSH si rsync compresse déjà
rsync -avz -e "ssh -o Compression=no" /source/ remote:/dest/

# Combiner : chiffrement rapide + pas de compression SSH
rsync -avz -e "ssh -c aes128-ctr -o Compression=no" /source/ remote:/dest/
```

> [!warning] Sécurité vs Performance Les algorithmes de chiffrement rapides peuvent être moins sécurisés. N'utilisez cette optimisation que sur des réseaux de confiance ou pour des données non sensibles.

### Optimisation des checksums

Par défaut, rsync utilise MD5 pour les checksums. On peut accélérer avec un algorithme plus rapide.

```bash
# Utiliser xxHash (beaucoup plus rapide que MD5)
rsync -av --checksum-choice=xxh128 /source/ remote:/dest/

# Pour les transferts locaux : désactiver les checksums
rsync -av --whole-file /local-source/ /local-dest/
```

### Batch mode pour transferts différés

Créer un fichier de batch pour rejouer le transfert plus tard (utile pour préparer un transfert hors ligne).

```bash
# Créer le batch (analyse sans transfert)
rsync -av --only-write-batch=backup.batch /source/ /dest/

# Appliquer le batch ailleurs
rsync --read-batch=backup.batch /dest/
```

---

## ⚠️ Pièges courants

### Piège 1 : Compresser des fichiers déjà compressés

```bash
# ❌ INEFFICACE : perte de CPU sans gain
rsync -avz /media/videos/ backup:/videos/  # .mp4, .mkv sont déjà compressés

# ✅ CORRECT : pas de compression
rsync -av /media/videos/ backup:/videos/
```

### Piège 2 : Ne pas limiter la bande passante en production

```bash
# ❌ RISQUÉ : sature la connexion
rsync -avz /data/ backup:/backup/  # En pleine journée de travail !

# ✅ CORRECT : limite pour ne pas impacter les utilisateurs
rsync -avz --bwlimit=2000 /data/ backup:/backup/
```

### Piège 3 : Oublier --partial sur connexions instables

```bash
# ❌ FRUSTRANT : recommence à zéro si coupure
rsync -avz /large-files/ remote:/backup/

# ✅ CORRECT : reprend là où ça s'est arrêté
rsync -avzP /large-files/ remote:/backup/
```

### Piège 4 : Checksums inutiles sur LAN rapide

```bash
# ❌ LENT : checksums sur réseau local rapide
rsync -avc /source/ /backup/  # -c force les checksums

# ✅ RAPIDE : comparaison par taille/date sur LAN
rsync -av /source/ /backup/
```

### Piège 5 : Double compression SSH + rsync

```bash
# ❌ INEFFICACE : SSH compresse déjà par défaut
rsync -avz -e ssh /source/ remote:/dest/  # Double compression !

# ✅ OPTIMAL : désactiver compression SSH si rsync compresse
rsync -avz -e "ssh -o Compression=no" /source/ remote:/dest/
```

---

## 💡 Astuces professionnelles

### Astuce 1 : Profil de performance adaptatif

```bash
#!/bin/bash
# Script avec profils de performance

PROFILE=${1:-"normal"}

case $PROFILE in
    "fast")
        # Maximum vitesse : LAN rapide
        OPTS="-av --whole-file"
        ;;
    "wan")
        # Optimisé Internet
        OPTS="-avz --compress-level=6 -P"
        ;;
    "slow")
        # Connexion lente/limitée
        OPTS="-avz --bwlimit=500 -P"
        ;;
    "night")
        # Sauvegarde nocturne sans limite
        OPTS="-avz --bwlimit=0 -P"
        ;;
    *)
        # Normal : équilibré
        OPTS="-avz --bwlimit=2000 -P"
        ;;
esac

rsync $OPTS /source/ backup:/dest/
```

### Astuce 2 : Mesurer les performances

```bash
# Comparer avec/sans compression
echo "=== Sans compression ==="
time rsync -av /data/ test1/

echo "=== Avec compression ==="
time rsync -avz /data/ test2/

# Voir les statistiques détaillées
rsync -av --stats /source/ /dest/ | tail -20
```

### Astuce 3 : Optimisation multi-fichiers

```bash
# Pour de nombreux petits fichiers : augmenter le buffer
rsync -av --outbuf=L /many-small-files/ /dest/

# L = Line buffered (optimal pour nombreux petits fichiers)
# B = Block buffered (défaut)
# N = No buffering
```

### Astuce 4 : Benchmark personnalisé

```bash
#!/bin/bash
# Test de performance rsync

SOURCE="/data/test"
DEST="/tmp/rsync-bench"

echo "Testing rsync performance..."

# Test 1 : Sans options
echo -n "Basic: "
time rsync -a $SOURCE/ $DEST/ 2>&1 | grep real

# Test 2 : Avec compression
rm -rf $DEST && mkdir $DEST
echo -n "Compressed: "
time rsync -az $SOURCE/ $DEST/ 2>&1 | grep real

# Test 3 : Avec --whole-file
rm -rf $DEST && mkdir $DEST
echo -n "Whole-file: "
time rsync -a --whole-file $SOURCE/ $DEST/ 2>&1 | grep real

rm -rf $DEST
```

---

## 📊 Tableau récapitulatif des optimisations

|Contexte|Options recommandées|Explication|
|---|---|---|
|**LAN rapide (1 Gbps+)**|`-av --whole-file`|Pas de compression, pas de delta|
|**Internet haut débit**|`-avz -P`|Compression + reprise|
|**Connexion lente**|`-avz --bwlimit=500 -P`|Compression + limitation|
|**Fichiers énormes**|`-av -P --partial-dir=.rsync-tmp`|Reprise optimisée|
|**Nombreux petits fichiers**|`-av --info=progress2`|Progression globale|
|**Production (journée)**|`-avz --bwlimit=2000`|Ne pas saturer|
|**Sauvegarde (nuit)**|`-avz --bwlimit=0`|Vitesse maximale|
|**Fichiers compressés**|`-av` (sans -z)|Pas de double compression|

---

> [!tip] Conseil final **Commencez simple, mesurez, puis optimisez**. Utilisez `--stats` pour identifier les vrais goulots d'étranglement avant d'ajouter des options complexes. L'optimisation prématurée est souvent contre-productive.