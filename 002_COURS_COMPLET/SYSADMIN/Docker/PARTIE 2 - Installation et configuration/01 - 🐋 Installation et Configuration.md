

## 📑 Table des matières

```table-of-contents
title: 
style: nestedList # TOC style (nestedList|nestedOrderedList|inlineFirstLevel)
minLevel: 2 # Include headings from the specified level
maxLevel: 3 # Include headings up to the specified level
include: 
exclude: 
includeLinks: true # Make headings clickable
hideWhenEmpty: false # Hide TOC if no headings are found
debugInConsole: false # Print debug info in Obsidian console
```

---

## 🔧 Prérequis système

Avant d'installer Docker, il est essentiel de vérifier que votre système répond aux exigences minimales. Docker étant une technologie qui interagit directement avec le noyau Linux, la compatibilité système est cruciale pour garantir un fonctionnement optimal et éviter les problèmes de stabilité.

### Versions Ubuntu/Debian compatibles

Docker Engine est officiellement supporté sur plusieurs versions de distributions Linux basées sur Debian. Le choix de la bonne version garantit l'accès aux dernières fonctionnalités de Docker et aux mises à jour de sécurité.

#### 📋 Distributions supportées

|Distribution|Versions supportées|Architecture|
|---|---|---|
|**Ubuntu**|24.04 LTS (Noble Numbat)|x86_64, arm64, armhf|
||23.10 (Mantic Minotaur)|x86_64, arm64, armhf|
||22.04 LTS (Jammy Jellyfish)|x86_64, arm64, armhf, s390x|
||20.04 LTS (Focal Fossa)|x86_64, arm64, armhf, s390x|
|**Debian**|Debian 12 (Bookworm)|x86_64, arm64, armhf|
||Debian 11 (Bullseye)|x86_64, arm64, armhf|
|**Raspberry Pi OS**|Bookworm (64-bit)|arm64|
||Bullseye (32-bit/64-bit)|armhf, arm64|

> [!info] Versions LTS recommandées Les versions LTS (Long Term Support) d'Ubuntu sont fortement recommandées pour les environnements de production. Elles bénéficient de 5 ans de support et de mises à jour de sécurité, garantissant une stabilité maximale.

> [!warning] Versions EOL (End of Life) Les versions comme Ubuntu 18.04 LTS (Bionic) ne sont plus officiellement supportées par Docker, même si elles peuvent encore fonctionner techniquement. L'utilisation de ces versions présente des risques de sécurité importants.

#### 🔍 Vérifier votre version

Pour connaître la version de votre distribution, utilisez la commande suivante :

```bash
# Afficher les informations détaillées du système
lsb_release -a

# Sortie exemple :
# Distributor ID: Ubuntu
# Description:    Ubuntu 22.04.3 LTS
# Release:        22.04
# Codename:       jammy

# Alternative : vérifier le fichier os-release
cat /etc/os-release
```

> [!tip] Astuce pour les serveurs : Sur un serveur distant, la commande `hostnamectl` fournit également des informations système complètes incluant la version du kernel, essentielle pour Docker.

```bash
hostnamectl

# Sortie exemple incluant :
# Operating System: Ubuntu 22.04.3 LTS
# Kernel: Linux 5.15.0-91-generic
```

#### 🎯 Pourquoi ces versions spécifiques ?

Docker nécessite des fonctionnalités modernes du noyau Linux pour fonctionner correctement, notamment :

- **cgroups v1/v2** : Pour l'isolation et la limitation des ressources des conteneurs
- **namespaces** : Pour l'isolation des processus, du réseau et du système de fichiers
- **OverlayFS** : Système de fichiers en couches pour le stockage efficace des images
- **seccomp** : Filtrage des appels système pour la sécurité
- **AppArmor/SELinux** : Profils de sécurité pour le confinement des conteneurs

Les distributions listées intègrent un noyau suffisamment récent (généralement ≥ 3.10, mais ≥ 5.x recommandé) avec ces fonctionnalités activées par défaut.

---

### Ressources minimales

Docker lui-même est relativement léger, mais les ressources nécessaires dépendent fortement de la charge de travail prévue. Il est important de dimensionner correctement votre système pour éviter les problèmes de performances et d'instabilité.

#### 💾 Configuration minimale (environnement de test)

|Ressource|Minimum absolu|Recommandé pour débuter|
|---|---|---|
|**RAM**|2 GB|4 GB|
|**CPU**|2 cœurs|4 cœurs|
|**Stockage**|20 GB|50 GB (SSD préféré)|
|**Swap**|1 GB|2 GB|

> [!warning] Attention au swap Un swap excessif dégrade considérablement les performances. Si vos conteneurs utilisent massivement le swap, c'est un signe que la RAM est insuffisante. Il vaut mieux ajouter de la RAM physique.

#### 🏢 Configuration pour production

|Type de charge|RAM|CPU|Stockage|
|---|---|---|---|
|**Microservices légers**|8-16 GB|4-8 cœurs|100-200 GB SSD|
|**Applications moyennes**|16-32 GB|8-16 cœurs|200-500 GB SSD|
|**Charge intensive**|32-128 GB|16-64 cœurs|500 GB - 2 TB NVMe|

> [!info] Règle empirique Prévoyez 20-30% de marge sur les ressources utilisées. Docker lui-même consomme peu (environ 100-200 MB de RAM), mais chaque conteneur ajoute sa propre empreinte.

#### 🔍 Vérifier les ressources disponibles

```bash
# RAM totale et disponible
free -h

# Sortie :
#               total        used        free      shared  buff/cache   available
# Mem:           15Gi       2.1Gi       8.9Gi       180Mi       4.7Gi        13Gi
# Swap:         2.0Gi          0B       2.0Gi

# Informations CPU
lscpu | grep -E "^CPU\(s\)|Model name|Thread|Core"

# Sortie exemple :
# CPU(s):                          8
# Model name:                      Intel(R) Core(TM) i7-10750H
# Thread(s) per core:              2
# Core(s) per socket:              4

# Espace disque disponible
df -h /var/lib/docker

# Note : /var/lib/docker est le répertoire par défaut de Docker
```

> [!tip] Monitoring continu Installez `htop` ou `btop` pour surveiller l'utilisation des ressources en temps réel pendant l'exécution de vos conteneurs :
> 
> ```bash
> sudo apt install htop
> htop
> ```

#### 💿 Stockage : considérations importantes

Le choix du système de stockage impacte directement les performances de Docker :

**Types de stockage :**

- **HDD (disque dur)** : Suffisant pour le développement, mais lent pour les builds et les opérations I/O intensives
- **SSD SATA** : Bon compromis pour la plupart des usages, nettement plus rapide qu'un HDD
- **NVMe** : Idéal pour la production avec builds fréquents et applications nécessitant de l'I/O rapide

```bash
# Vérifier le type de disque
lsblk -d -o name,rota

# ROTA = 1 : disque rotatif (HDD)
# ROTA = 0 : disque SSD/NVMe

# Tester les performances du disque
sudo hdparm -Tt /dev/sda  # Remplacer sda par votre disque

# Alternative plus précise avec fio (à installer)
sudo apt install fio
fio --name=random-write --ioengine=libaio --iodepth=32 --rw=randwrite \
    --bs=4k --direct=1 --size=1G --numjobs=1 --runtime=60 --group_reporting
```

> [!warning] Espace disque et Docker Docker peut rapidement consommer de l'espace avec :
> 
> - Les images téléchargées (plusieurs GB par image)
> - Les couches intermédiaires lors des builds
> - Les volumes persistants
> - Les logs des conteneurs
> 
> Surveillez régulièrement l'espace avec `docker system df` et nettoyez avec `docker system prune`.

#### 🎯 Dimensionnement par cas d'usage

**Développement local :**

- 4-8 GB RAM suffisent pour exécuter 3-5 conteneurs simultanément
- 2-4 cœurs CPU pour des builds raisonnablement rapides
- 50 GB de stockage pour images et données de test

**CI/CD :**

- 8-16 GB RAM pour exécuter plusieurs pipelines en parallèle
- 4-8 cœurs pour des builds rapides
- 100-200 GB SSD pour le cache des builds

**Serveur de production :**

- RAM = (nb conteneurs × RAM moyenne par conteneur) × 1.3
- CPU selon la charge applicative (monitoring requis)
- Stockage dimensionné pour 6-12 mois de logs et données

---

### Architecture processeur

Docker utilise la conteneurisation au niveau système, ce qui signifie qu'il partage le noyau de l'hôte avec les conteneurs. L'architecture du processeur est donc critique car elle détermine quelles images Docker peuvent s'exécuter sur votre système.

#### 🖥️ Architectures supportées

|Architecture|Nom technique|Cas d'usage typique|Support Docker|
|---|---|---|---|
|**x86_64**|AMD64|Serveurs, PC de bureau, laptops|✅ Support complet|
|**ARM64**|aarch64|Raspberry Pi 4/5, Mac M1/M2/M3, serveurs ARM|✅ Support complet|
|**ARMv7**|armhf|Raspberry Pi 2/3, anciens ARM|✅ Support partiel|
|**s390x**|IBM Z|Mainframes IBM|✅ Support spécifique|
|**ppc64le**|PowerPC 64-bit|Serveurs IBM Power|✅ Support spécifique|

> [!info] x86_64 vs AMD64 Ces termes sont interchangeables. AMD64 est le nom officiel de l'architecture 64 bits x86 (développée initialement par AMD), mais on utilise couramment x86_64 ou x64.

#### 🔍 Identifier votre architecture

```bash
# Méthode 1 : Architecture du processeur
uname -m

# Sorties possibles :
# x86_64   → Architecture 64 bits Intel/AMD
# aarch64  → Architecture ARM 64 bits
# armv7l   → Architecture ARM 32 bits

# Méthode 2 : Informations détaillées
dpkg --print-architecture

# Sortie : amd64, arm64, armhf, etc.

# Méthode 3 : Détails complets du CPU
lscpu | grep Architecture

# Sortie exemple :
# Architecture:                    x86_64
# CPU op-mode(s):                  32-bit, 64-bit
```

> [!tip] Vérification rapide La commande `arch` affiche directement l'architecture du système, c'est l'équivalent de `uname -m`.

#### 🎯 Importance de l'architecture

L'architecture du processeur détermine **quelles images Docker vous pouvez exécuter**. Voici pourquoi c'est crucial :

**Compatibilité des images :**

Les images Docker sont compilées pour une architecture spécifique. Une image construite pour x86_64 ne fonctionnera pas nativement sur ARM64, et vice versa.

```bash
# Exemple : tirer une image multi-architecture
docker pull nginx

# Docker télécharge automatiquement la version correspondant à votre architecture

# Vérifier l'architecture d'une image
docker image inspect nginx | grep Architecture

# Sortie :
# "Architecture": "amd64"   (sur un système x86_64)
# "Architecture": "arm64"   (sur un système ARM64)
```

> [!warning] Images mono-architecture Certaines images anciennes ou spécialisées ne sont disponibles que pour x86_64. Vérifiez toujours la compatibilité sur Docker Hub avant de planifier un déploiement sur ARM.

**Images multi-architecture (manifests) :**

Les images modernes sur Docker Hub utilisent des **manifests** qui regroupent plusieurs variantes d'architecture. Docker sélectionne automatiquement la bonne version.

```bash
# Inspecter le manifest d'une image
docker manifest inspect nginx:latest

# La sortie montre toutes les architectures disponibles :
# - linux/amd64
# - linux/arm64
# - linux/arm/v7
# - etc.
```

> [!info] Avantage des manifests Avec les manifests, vous pouvez utiliser la même commande `docker pull nginx` sur n'importe quelle architecture, et Docker télécharge la bonne version automatiquement. Cela simplifie considérablement le déploiement multi-plateforme.

#### 🔄 Émulation d'architecture avec QEMU

Si vous devez absolument exécuter des conteneurs d'une architecture différente, Docker peut utiliser QEMU pour l'émulation. Cependant, **les performances sont considérablement réduites** (jusqu'à 10-20x plus lent).

```bash
# Installer QEMU pour l'émulation multi-architecture
sudo apt install qemu-user-static

# Activer binfmt_misc pour Docker
docker run --rm --privileged multiarch/qemu-user-static --reset -p yes

# Maintenant vous pouvez exécuter des images d'autres architectures
# (mais avec des performances dégradées)
docker run --platform linux/arm64 nginx   # Sur un système x86_64
```

> [!warning] Émulation : usage limité L'émulation via QEMU est acceptable pour :
> 
> - Tester des images multi-architecture localement
> - Builder des images pour d'autres plateformes
> 
> Mais **jamais pour la production** à cause des performances médiocres.

#### 🏗️ Builder pour plusieurs architectures

Si vous développez des images Docker, vous pouvez créer des images multi-architecture avec `docker buildx` :

```bash
# Créer un builder multi-plateforme
docker buildx create --name multiarch --use

# Builder pour plusieurs architectures
docker buildx build --platform linux/amd64,linux/arm64,linux/arm/v7 \
  -t monimage:latest --push .
```

Cette approche nécessite d'utiliser QEMU pour l'émulation des architectures non natives pendant le build, mais le résultat final est une image optimisée pour chaque plateforme.

#### 📊 Cas d'usage par architecture

**x86_64 (AMD64) :**

- **Avantages** : Écosystème le plus mature, presque toutes les images disponibles, performances optimales
- **Usage** : Serveurs d'entreprise, cloud computing, postes de développement
- **Exemples** : AWS EC2, Azure VMs, serveurs Dell/HP

**ARM64 (aarch64) :**

- **Avantages** : Efficacité énergétique supérieure, coût souvent réduit, écosystème en croissance rapide
- **Usage** : Edge computing, IoT, serveurs basse consommation, Mac Silicon
- **Exemples** : Raspberry Pi 4/5, AWS Graviton, Apple M1/M2/M3, Ampere Altra

**ARMv7 (armhf) :**

- **Avantages** : Support des anciens dispositifs ARM
- **Usage** : Anciens Raspberry Pi, dispositifs embarqués legacy
- **Limitations** : Support Docker en déclin, moins d'images disponibles

> [!tip] Choix d'architecture pour un nouveau projet En 2024-2025, privilégiez :
> 
> - **x86_64** pour la compatibilité maximale et les workloads intensifs
> - **ARM64** pour l'efficacité énergétique et les coûts optimisés (si votre stack logicielle est compatible)

#### 🔍 Vérifications spécifiques aux architectures

**Pour ARM (Raspberry Pi, etc.) :**

```bash
# Vérifier si le système est 32 ou 64 bits
getconf LONG_BIT

# Sortie : 32 ou 64

# Vérifier les flags CPU ARM
cat /proc/cpuinfo | grep Features

# Les flags importants pour Docker :
# - vfp, vfpv3, vfpv4 : opérations flottantes
# - neon : SIMD pour ARM
# - lpae : Large Physical Address Extension (>4GB RAM)
```

**Pour x86_64 :**

```bash
# Vérifier le support de la virtualisation matérielle
egrep -o '(vmx|svm)' /proc/cpuinfo

# vmx : Intel VT-x
# svm : AMD-V
# (Important pour des performances optimales, bien que Docker n'utilise pas
#  directement la virtualisation matérielle comme les VMs)

# Vérifier les instructions CPU modernes
lscpu | grep -E "avx|sse"

# AVX, AVX2, AVX-512 : accélération pour certaines charges de calcul
```

> [!info] Instructions CPU et performances Bien que Docker n'exige pas d'instructions CPU spécifiques, les applications dans vos conteneurs peuvent bénéficier d'instructions modernes (AVX, SSE) pour les calculs intensifs (ML, traitement d'image, etc.).

---

> [!tip] 💡 Checklist avant installation Avant de procéder à l'installation de Docker, vérifiez que vous avez :
> 
> - ✅ Une distribution supportée (Ubuntu 20.04+ ou Debian 11+)
> - ✅ Au minimum 4 GB de RAM (8 GB recommandés)
> - ✅ Au moins 50 GB d'espace disque (SSD préféré)
> - ✅ Identifié votre architecture processeur
> - ✅ Vérifié que le noyau est ≥ 5.x (`uname -r`)
> - ✅ Les droits administrateur (sudo) sur le système

---

## 🎓 Points clés à retenir

|Concept|À retenir|
|---|---|
|**Versions OS**|Privilégiez les LTS (Ubuntu 22.04/24.04, Debian 11/12) pour la stabilité|
|**RAM**|Minimum 4 GB, adaptez selon le nombre de conteneurs|
|**Stockage**|SSD fortement recommandé, minimum 50 GB|
|**Architecture**|x86_64 pour compatibilité max, ARM64 pour efficacité énergétique|
|**Vérifications**|`lsb_release -a`, `free -h`, `df -h`, `uname -m`|

> [!success] Prêt pour l'installation Une fois ces prérequis validés, vous pouvez procéder à l'installation de Docker Engine avec la certitude que votre système est correctement configuré pour héberger des conteneurs.