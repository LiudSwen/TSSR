# 

## 📑 Table des matières

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

La sauvegarde est un élément critique de toute infrastructure virtualisée. Proxmox VE offre un système de sauvegarde intégré puissant et flexible qui permet de protéger vos VMs et containers contre les pertes de données, les erreurs humaines ou les défaillances matérielles.

> [!info] Pourquoi sauvegarder ?
> 
> - **Protection des données** : Récupération en cas de corruption ou suppression
> - **Reprise après sinistre** : Restauration rapide après incident
> - **Migration facilitée** : Déplacement de VMs entre nœuds ou clusters
> - **Tests et développement** : Création d'environnements de test identiques

---

## Stratégie de sauvegarde

Une bonne stratégie de sauvegarde repose sur trois piliers : le **type de sauvegarde**, le **mode de compression**, et la **politique de rétention**. Chaque choix impacte la durée de la sauvegarde, l'espace disque nécessaire, et la facilité de restauration.

### Types de sauvegardes

Proxmox propose trois modes de sauvegarde, chacun avec ses avantages et inconvénients selon le contexte d'utilisation.

#### 🔸 Snapshot Mode

Le mode Snapshot utilise les capacités de snapshot du système de fichiers (LVM, ZFS) ou du format de disque (QEMU) pour créer une sauvegarde cohérente sans arrêter la VM.

**Fonctionnement :**

1. Création d'un snapshot instantané du disque
2. La VM continue de fonctionner normalement
3. La sauvegarde est effectuée depuis le snapshot
4. Le snapshot est supprimé une fois la sauvegarde terminée

**Avantages :**

- ✅ Aucun downtime (VM reste en ligne)
- ✅ Sauvegarde cohérente des données
- ✅ Idéal pour les serveurs de production

**Inconvénients :**

- ❌ Nécessite un support de stockage compatible (LVM-thin, ZFS, Ceph, etc.)
- ❌ Impact sur les performances pendant la sauvegarde
- ❌ Requiert de l'espace disque supplémentaire temporaire

> [!example] Exemple d'utilisation
> 
> ```bash
> # Sauvegarde en mode Snapshot d'une VM
> vzdump 100 --mode snapshot --storage backup-storage --compress zstd
> ```

> [!tip] Quand utiliser le mode Snapshot ?
> 
> - Serveurs web en production (Apache, Nginx)
> - Bases de données avec transactions actives
> - Applications critiques ne pouvant tolérer d'interruption
> - VMs avec forte activité I/O

---

#### 🔸 Suspend Mode

Le mode Suspend met la VM en pause (état "suspended"), effectue la sauvegarde, puis reprend l'exécution de la VM.

**Fonctionnement :**

1. La VM est suspendue (mise en pause)
2. État de la RAM sauvegardé
3. Sauvegarde des disques effectuée
4. La VM reprend son exécution

**Avantages :**

- ✅ Sauvegarde très cohérente (état figé)
- ✅ Inclut l'état de la mémoire RAM
- ✅ Restauration possible à l'état exact
- ✅ Fonctionne avec tous les types de stockage

**Inconvénients :**

- ❌ Interruption de service (quelques secondes à minutes)
- ❌ Fichier de sauvegarde plus volumineux (inclut la RAM)
- ❌ Temps de sauvegarde plus long

> [!example] Exemple d'utilisation
> 
> ```bash
> # Sauvegarde en mode Suspend d'une VM avec 8 Go de RAM
> vzdump 101 --mode suspend --storage backup-storage --compress lzo
> ```

> [!warning] Attention aux connexions réseau Les connexions TCP actives peuvent être perdues pendant la suspension. Les applications doivent être capables de se reconnecter automatiquement.

> [!tip] Quand utiliser le mode Suspend ?
> 
> - Environnements de développement et de test
> - VMs avec peu de connexions actives
> - Sauvegardes hors heures de production
> - Applications tolérant quelques secondes d'interruption

---

#### 🔸 Stop Mode

Le mode Stop arrête complètement la VM avant la sauvegarde, puis la redémarre une fois terminé.

**Fonctionnement :**

1. Arrêt propre de la VM (shutdown)
2. Sauvegarde des disques à l'arrêt
3. Redémarrage automatique de la VM

**Avantages :**

- ✅ Sauvegarde la plus sûre et cohérente
- ✅ Pas d'impact sur les performances du système
- ✅ Fichiers de sauvegarde plus petits (pas de RAM)
- ✅ Compatible avec tous les stockages

**Inconvénients :**

- ❌ Downtime significatif (plusieurs minutes)
- ❌ Services indisponibles pendant la sauvegarde
- ❌ Temps de démarrage après restauration

> [!example] Exemple d'utilisation
> 
> ```bash
> # Sauvegarde en mode Stop d'une VM
> vzdump 102 --mode stop --storage backup-storage --compress gzip
> 
> # Sauvegarde de plusieurs VMs en mode Stop
> vzdump 100 101 102 --mode stop --storage backup-storage
> ```

> [!tip] Quand utiliser le mode Stop ?
> 
> - Sauvegardes planifiées la nuit (fenêtre de maintenance)
> - VMs de développement non critiques
> - Garantie maximale de cohérence des données
> - Systèmes avec bases de données complexes

---

#### 📊 Tableau comparatif des modes

|Critère|Snapshot|Suspend|Stop|
|---|---|---|---|
|**Downtime**|Aucun|Quelques secondes|Plusieurs minutes|
|**Cohérence**|Bonne|Excellente|Parfaite|
|**Taille backup**|Moyenne|Grande (+ RAM)|Petite|
|**Compatibilité stockage**|Limitée|Totale|Totale|
|**Impact performances**|Moyen|Faible|Aucun|
|**Usage recommandé**|Production|Dev/Test|Maintenance|

> [!warning] Pièges courants
> 
> - **Snapshot sans support** : Tenter un snapshot sur un stockage dir classique échouera
> - **RAM excessive en Suspend** : Une VM avec 64 Go de RAM créera des backups très volumineux
> - **Stop en production** : Oublier qu'une VM en Stop sera indisponible pendant la sauvegarde

---

### Modes de compression

La compression réduit la taille des sauvegardes au prix d'un temps de traitement CPU. Proxmox propose plusieurs algorithmes de compression avec différents compromis vitesse/taux.

#### 🔹 ZSTD (Zstandard)

**Caractéristiques :**

- Algorithme moderne développé par Facebook
- Excellent équilibre entre vitesse et ratio de compression
- Compression adaptative avec niveaux réglables

**Performance :**

- Vitesse de compression : **Très rapide**
- Ratio de compression : **Excellent** (meilleur que gzip)
- Utilisation CPU : **Modérée**
- Décompression : **Extrêmement rapide**

> [!example] Utilisation ZSTD
> 
> ```bash
> # Sauvegarde avec compression ZSTD (défaut)
> vzdump 100 --compress zstd
> 
> # ZSTD avec niveau de compression personnalisé (1-19, défaut=3)
> vzdump 100 --compress zstd --zstd 10
> ```

> [!tip] ZSTD est le choix recommandé Depuis Proxmox 7, ZSTD est le mode de compression par défaut et convient à la plupart des cas d'usage. Il offre le meilleur compromis global.

---

#### 🔹 LZO (Lempel-Ziv-Oberhumer)

**Caractéristiques :**

- Algorithme orienté vitesse
- Compression et décompression très rapides
- Ratio de compression plus faible

**Performance :**

- Vitesse de compression : **Extrêmement rapide**
- Ratio de compression : **Moyen** (le plus faible)
- Utilisation CPU : **Très faible**
- Décompression : **Très rapide**

> [!example] Utilisation LZO
> 
> ```bash
> # Sauvegarde avec compression LZO
> vzdump 100 --compress lzo --mode snapshot
> ```

> [!tip] Quand utiliser LZO ?
> 
> - Systèmes avec CPU limité ou ancien
> - Sauvegardes fréquentes nécessitant peu de temps
> - Réseaux rapides où la vitesse prime sur la taille
> - Restaurations urgentes où chaque seconde compte

---

#### 🔹 GZIP

**Caractéristiques :**

- Algorithme classique et éprouvé
- Bon ratio de compression
- Plus lent que ZSTD et LZO

**Performance :**

- Vitesse de compression : **Lente**
- Ratio de compression : **Bon** (meilleur que LZO, inférieur à ZSTD)
- Utilisation CPU : **Élevée**
- Décompression : **Modérée**

> [!example] Utilisation GZIP
> 
> ```bash
> # Sauvegarde avec compression GZIP
> vzdump 100 --compress gzip --mode stop
> 
> # GZIP avec niveau de compression (1-9, défaut=6)
> vzdump 100 --compress gzip --pigz 9
> ```

> [!info] PIGZ - GZIP parallèle Proxmox utilise automatiquement `pigz` (parallel gzip) si disponible, ce qui améliore significativement les performances sur les systèmes multi-cœurs.

> [!tip] Quand utiliser GZIP ?
> 
> - Compatibilité avec systèmes externes (largement supporté)
> - Stockage limité et coûteux (meilleur ratio avant ZSTD)
> - Sauvegardes archivées à long terme
> - Migration depuis anciens systèmes

---

#### 🔹 Sans compression (0)

**Caractéristiques :**

- Aucune compression appliquée
- Copie directe des données
- Fichiers de sauvegarde très volumineux

> [!example] Sauvegarde sans compression
> 
> ```bash
> # Désactiver la compression
> vzdump 100 --compress 0
> ```

> [!warning] Usage déconseillé La sauvegarde sans compression est rarement recommandée sauf cas très spécifiques (disques déjà compressés, ZFS avec compression native, debugging).

---

#### 📊 Tableau comparatif des compressions

|Algorithme|Vitesse|Ratio|CPU|Usage recommandé|
|---|---|---|---|---|
|**ZSTD**|⚡⚡⚡|📦📦📦|🔥🔥|**Défaut - Usage général**|
|**LZO**|⚡⚡⚡⚡|📦|🔥|CPU limité, vitesse critique|
|**GZIP**|⚡|📦📦|🔥🔥🔥|Compatibilité, archives|
|**Aucune (0)**|⚡⚡⚡⚡⚡|❌|-|Cas très spécifiques|

> [!example] Exemple de comparaison réelle Pour une VM de 50 Go avec système Linux standard :
> 
> |Compression|Taille finale|Temps|CPU moyen|
> |---|---|---|---|
> |ZSTD|~12 Go|8 min|45%|
> |LZO|~18 Go|5 min|25%|
> |GZIP|~11 Go|15 min|85%|
> |Aucune|~50 Go|3 min|5%|

> [!tip] Astuce de sélection
> 
> ```bash
> # Pour choisir la compression selon le contexte :
> 
> # Production standard → ZSTD
> vzdump 100 --compress zstd
> 
> # CPU faible ou vieux serveur → LZO
> vzdump 100 --compress lzo
> 
> # Archivage long terme → GZIP niveau max
> vzdump 100 --compress gzip --pigz 9
> 
> # Debug ou disque avec compression matérielle → Aucune
> vzdump 100 --compress 0
> ```

---

### Politique de rétention

La rétention définit combien de temps et combien de sauvegardes sont conservées. Une bonne politique de rétention équilibre protection des données et utilisation de l'espace disque.

#### 🔸 Principe de rétention

Proxmox utilise un système de rétention basé sur des règles temporelles :

**Options de rétention :**

- `keep-last` : Nombre de dernières sauvegardes à conserver
- `keep-hourly` : Sauvegardes horaires à conserver
- `keep-daily` : Sauvegardes journalières à conserver
- `keep-weekly` : Sauvegardes hebdomadaires à conserver
- `keep-monthly` : Sauvegardes mensuelles à conserver
- `keep-yearly` : Sauvegardes annuelles à conserver

> [!info] Logique de conservation Proxmox conserve la sauvegarde la plus récente pour chaque période définie. Par exemple, avec `keep-daily 7`, il garde la sauvegarde la plus récente de chacun des 7 derniers jours.

---

#### 🔸 Exemples de politiques de rétention

##### Politique basique (environnement de test)

```bash
# Conserver seulement les 3 dernières sauvegardes
vzdump 100 --storage backup-storage --keep-last 3
```

**Résultat :** Seules les 3 sauvegardes les plus récentes sont conservées, idéal pour économiser l'espace en développement.

---

##### Politique standard (production)

```bash
# Configuration équilibrée pour production
vzdump 100 --storage backup-storage \
  --keep-last 3 \
  --keep-daily 7 \
  --keep-weekly 4 \
  --keep-monthly 6
```

**Résultat :**

- 3 dernières sauvegardes (récupération immédiate)
- 1 sauvegarde par jour sur 7 jours (dernière semaine)
- 1 sauvegarde par semaine sur 4 semaines (dernier mois)
- 1 sauvegarde par mois sur 6 mois (semestre)

> [!tip] Cas d'usage Cette politique convient aux serveurs de production moyennement critiques avec un bon équilibre entre protection et espace disque.

---

##### Politique agressive (haute disponibilité)

```bash
# Maximum de protection pour serveurs critiques
vzdump 100 --storage backup-storage \
  --keep-last 5 \
  --keep-hourly 24 \
  --keep-daily 14 \
  --keep-weekly 8 \
  --keep-monthly 12 \
  --keep-yearly 3
```

**Résultat :**

- 5 dernières sauvegardes
- Sauvegardes horaires sur 24h (dernière journée)
- Sauvegardes quotidiennes sur 2 semaines
- Sauvegardes hebdomadaires sur 2 mois
- Sauvegardes mensuelles sur 1 an
- Sauvegardes annuelles sur 3 ans

> [!warning] Attention à l'espace disque Cette politique peut consommer énormément d'espace. Prévoir un stockage conséquent ou des sauvegardes incrémentielles.

---

##### Politique minimaliste (économie d'espace)

```bash
# Minimum de sauvegardes pour contraintes d'espace
vzdump 100 --storage backup-storage \
  --keep-last 1 \
  --keep-weekly 2 \
  --keep-monthly 3
```

**Résultat :**

- 1 dernière sauvegarde (récupération rapide)
- 2 sauvegardes hebdomadaires (2 semaines)
- 3 sauvegardes mensuelles (trimestre)

> [!tip] Cas d'usage Convient aux VMs non critiques, environnements de test, ou situations avec stockage limité.

---

#### 🔸 Règles de chevauchement

Lorsque plusieurs règles de rétention s'appliquent, Proxmox conserve la sauvegarde en appliquant l'union des règles (pas d'intersection).

> [!example] Exemple de chevauchement Configuration :
> 
> ```bash
> vzdump 100 --keep-daily 7 --keep-weekly 4
> ```
> 
> **Comportement :**
> 
> - Jour 1-7 : Conservées par `keep-daily`
> - Jour 8+ : Conservées si c'est la sauvegarde hebdomadaire la plus récente
> - Une sauvegarde peut satisfaire plusieurs règles simultanément

---

#### 🔸 Suppression automatique

Proxmox supprime automatiquement les sauvegardes qui ne satisfont plus aucune règle de rétention lors de la prochaine sauvegarde.

> [!warning] Pièges de la rétention
> 
> - **Absence de règle** : Sans règle de rétention, les sauvegardes s'accumulent indéfiniment
> - **Rétention trop courte** : Risque de perdre des points de restauration critiques
> - **Rétention trop longue** : Saturation du stockage, backups lents
> - **Combinaisons contradictoires** : Attention à la cohérence des règles

> [!tip] Bonnes pratiques de rétention
> 
> 1. **Règle 3-2-1** : 3 copies, 2 médias différents, 1 hors site
> 2. **Tester régulièrement** : Vérifier que les anciennes sauvegardes sont bien supprimées
> 3. **Surveiller l'espace** : Mettre en place des alertes de capacité disque
> 4. **Adapter au RPO** : Recovery Point Objective détermine la fréquence
> 5. **Documenter** : Expliquer pourquoi telle rétention pour telle VM

---

#### 📊 Exemple de calcul d'espace disque

Pour estimer l'espace nécessaire avec une politique de rétention :

**Hypothèses :**

- Taille VM : 50 Go
- Compression ZSTD : ratio 4:1 → 12,5 Go par backup
- Politique : `keep-last 3`, `keep-daily 7`, `keep-weekly 4`

**Calcul approximatif :**

- 3 dernières : 3 × 12,5 = 37,5 Go
- 7 daily : 7 × 12,5 = 87,5 Go (dont 3 déjà comptées)
- 4 weekly : 4 × 12,5 = 50 Go (dont certaines déjà comptées)

**Total réaliste** : ~125 Go (avec chevauchements)

> [!example] Script de calcul
> 
> ```bash
> # Vérifier l'espace utilisé par les sauvegardes d'une VM
> du -sh /chemin/backup/dump/vzdump-qemu-100-*.vma.*
> 
> # Compter le nombre de backups d'une VM
> ls -1 /chemin/backup/dump/vzdump-qemu-100-* | wc -l
> 
> # Afficher les backups avec leur date
> ls -lh /chemin/backup/dump/vzdump-qemu-100-*
> ```

---

#### 🔸 Configuration via l'interface web

Les paramètres de rétention peuvent être définis dans l'interface Proxmox :

1. **Datacenter** → **Backup**
2. Créer ou modifier un job de sauvegarde
3. Section **Retention** : configurer les règles
4. **Save** pour appliquer

> [!tip] Jobs de sauvegarde automatiques Les jobs de sauvegarde permettent de planifier des sauvegardes récurrentes avec des politiques de rétention prédéfinies, simplifiant grandement la gestion.

---

## 🎯 Récapitulatif des choix stratégiques

> [!tip] Guide de décision rapide
> 
> **Pour une VM de production critique :**
> 
> - Mode : **Snapshot**
> - Compression : **ZSTD**
> - Rétention : `keep-last 5 --keep-daily 7 --keep-weekly 4 --keep-monthly 6`
> 
> **Pour un environnement de développement :**
> 
> - Mode : **Suspend** ou **Stop**
> - Compression : **LZO** (rapide)
> - Rétention : `keep-last 3 --keep-weekly 2`
> 
> **Pour une base de données importante :**
> 
> - Mode : **Snapshot** (avec agent QEMU si possible)
> - Compression : **ZSTD** niveau élevé
> - Rétention : Agressive avec sauvegardes horaires
> 
> **Pour une VM avec ressources limitées :**
> 
> - Mode : **Stop** (fenêtre de maintenance)
> - Compression : **ZSTD** ou **LZO**
> - Rétention : Minimale, focus sur récent

---

## 🔑 Points clés à retenir

- **Types de sauvegarde** : Snapshot (pas de downtime), Suspend (pause courte), Stop (arrêt complet)
- **Compression** : ZSTD recommandé (meilleur compromis), LZO pour vitesse, GZIP pour compatibilité
- **Rétention** : Adapter selon criticité et espace disponible, utiliser des règles combinées
- **Test** : Toujours tester vos restaurations pour valider votre stratégie
- **Surveillance** : Monitorer l'espace disque et le succès des sauvegardes

> [!warning] N'oubliez jamais Une sauvegarde non testée est une sauvegarde potentiellement inutile. Planifiez des tests de restauration réguliers !