

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

La gestion des images ISO et des templates est fondamentale dans Proxmox pour déployer rapidement des machines virtuelles et des conteneurs. Les **ISO** servent à installer des systèmes d'exploitation sur des VMs, tandis que les **templates de conteneurs** permettent de créer instantanément des conteneurs LXC préconfigurés.

> [!info] Distinction importante
> 
> - **ISO** : Images disque pour installer des OS sur des machines virtuelles (VMs)
> - **Templates CT** : Images système préconfigurées pour conteneurs LXC
> - **Templates VM** : VMs converties en modèles réutilisables (hors périmètre de cette partie)

---

## 📤 Upload d'images ISO

### Pourquoi uploader des ISO ?

L'upload d'ISO est nécessaire pour installer des systèmes d'exploitation personnalisés, des versions spécifiques non disponibles en téléchargement direct, ou des distributions propriétaires.

### Méthode 1 : Via l'interface web

**Étapes détaillées :**

1. **Accéder au stockage**
    
    - Dans l'arborescence de gauche, sélectionnez votre nœud Proxmox
    - Développez le nœud et cliquez sur le stockage souhaité (généralement `local`)
2. **Naviguer vers le contenu ISO**
    
    - Cliquez sur `ISO Images` dans le menu du stockage
    - Bouton `Upload` en haut de la fenêtre
3. **Sélectionner et uploader**
    
    - Cliquez sur `Select File` pour choisir votre ISO locale
    - Attendez la fin de l'upload (barre de progression affichée)

> [!warning] Limitations de l'interface web
> 
> - Taille maximale variable selon la configuration du serveur web (souvent limitée à 2-4 GB)
> - Pas de reprise possible en cas d'interruption
> - Peut être lent pour les gros fichiers

### Méthode 2 : Via SCP/SFTP (recommandée pour gros fichiers)

Pour les ISO volumineuses, utilisez SCP ou un client SFTP comme WinSCP, FileZilla ou Cyberduck.

**Avec SCP en ligne de commande :**

```bash
# Depuis votre machine locale
scp /chemin/vers/votre/image.iso root@IP_PROXMOX:/var/lib/vz/template/iso/

# Exemple concret
scp ubuntu-22.04.3-live-server-amd64.iso root@192.168.1.100:/var/lib/vz/template/iso/
```

**Chemin de stockage par défaut :**

|Type de stockage|Chemin par défaut|
|---|---|
|ISO images|`/var/lib/vz/template/iso/`|
|Container templates|`/var/lib/vz/template/cache/`|
|VM disks|`/var/lib/vz/images/`|

> [!tip] Astuce pour les transferts longs Utilisez `screen` ou `tmux` pour maintenir la session SSH active :
> 
> ```bash
> screen -S upload
> scp fichier.iso root@proxmox:/var/lib/vz/template/iso/
> # Ctrl+A puis D pour détacher
> # screen -r upload pour se rattacher
> ```

### Méthode 3 : Via wget directement sur le serveur

Si votre ISO est hébergée en ligne, téléchargez-la directement sur Proxmox :

```bash
# Se connecter au serveur Proxmox en SSH
ssh root@IP_PROXMOX

# Se placer dans le répertoire ISO
cd /var/lib/vz/template/iso/

# Télécharger l'ISO
wget https://releases.ubuntu.com/22.04/ubuntu-22.04.3-live-server-amd64.iso

# Vérifier le téléchargement
ls -lh
```

> [!example] Téléchargement avec barre de progression
> 
> ```bash
> # Avec wget et affichage détaillé
> wget --progress=bar:force https://url-de-votre-iso
> 
> # Avec curl (alternative)
> curl -O -# https://url-de-votre-iso
> ```

### Vérification et gestion des ISO

**Lister les ISO disponibles :**

```bash
# Lister tous les ISO
ls -lh /var/lib/vz/template/iso/

# Vérifier l'intégrité avec MD5/SHA256
md5sum ubuntu-22.04.3-live-server-amd64.iso
sha256sum ubuntu-22.04.3-live-server-amd64.iso
```

**Supprimer une ISO :**

```bash
# Via ligne de commande
rm /var/lib/vz/template/iso/nom-fichier.iso

# Via l'interface web : sélectionner l'ISO et cliquer sur "Remove"
```

> [!warning] Attention aux permissions Assurez-vous que les fichiers ISO ont les bonnes permissions :
> 
> ```bash
> chmod 644 /var/lib/vz/template/iso/*.iso
> chown root:root /var/lib/vz/template/iso/*.iso
> ```

---

## 🌐 Téléchargement depuis le web

Proxmox intègre un gestionnaire de téléchargement permettant de récupérer des ISO directement depuis Internet via l'interface web.

### Fonctionnement du téléchargement intégré

**Accès à la fonctionnalité :**

1. Datacenter → Storage → Sélectionner le stockage (ex: `local`)
2. Onglet `ISO Images`
3. Bouton `Download from URL`

**Interface de téléchargement :**

- **URL** : Lien direct vers l'ISO (doit se terminer par `.iso`)
- **Filename** : Nom du fichier (auto-rempli ou personnalisable)
- **Query URL** : Proxmox vérifie que l'URL est valide
- **Hash algorithm** : SHA256, SHA1, MD5 pour vérifier l'intégrité
- **Checksum** : Somme de contrôle pour validation automatique

> [!info] Avantages de cette méthode
> 
> - Téléchargement direct sur le serveur (pas de transit par votre PC)
> - Vérification automatique d'intégrité si checksum fourni
> - Suivi de la progression en temps réel
> - Pas de limite de taille

### Exemple pratique : Télécharger Ubuntu Server

```bash
# URL directe Ubuntu 22.04 LTS
https://releases.ubuntu.com/22.04/ubuntu-22.04.3-live-server-amd64.iso

# Checksum SHA256 (à vérifier sur le site officiel)
# https://releases.ubuntu.com/22.04/SHA256SUMS
```

**Processus dans l'interface :**

1. Coller l'URL dans le champ approprié
2. Le nom de fichier est auto-détecté : `ubuntu-22.04.3-live-server-amd64.iso`
3. Sélectionner `SHA256` comme algorithme
4. Coller le checksum officiel
5. Cliquer sur `Query URL` pour valider
6. Cliquer sur `Download` pour lancer

> [!tip] Sources d'ISO officielles
> 
> - **Ubuntu** : https://releases.ubuntu.com/
> - **Debian** : https://www.debian.org/CD/http-ftp/
> - **CentOS Stream** : https://www.centos.org/download/
> - **Rocky Linux** : https://rockylinux.org/download
> - **Alpine Linux** : https://alpinelinux.org/downloads/

### Téléchargement via ligne de commande (méthode avancée)

Pour automatiser ou scripter les téléchargements :

```bash
# Se connecter au serveur
ssh root@proxmox

# Naviguer vers le dossier ISO
cd /var/lib/vz/template/iso/

# Télécharger avec wget
wget https://releases.ubuntu.com/22.04/ubuntu-22.04.3-live-server-amd64.iso

# Vérifier le checksum automatiquement
wget https://releases.ubuntu.com/22.04/SHA256SUMS
sha256sum -c SHA256SUMS 2>&1 | grep ubuntu-22.04.3-live-server-amd64.iso
```

**Script de téléchargement automatisé :**

```bash
#!/bin/bash
# download-iso.sh - Script pour télécharger et vérifier une ISO

ISO_URL="https://releases.ubuntu.com/22.04/ubuntu-22.04.3-live-server-amd64.iso"
CHECKSUM_URL="https://releases.ubuntu.com/22.04/SHA256SUMS"
ISO_DIR="/var/lib/vz/template/iso"

cd "$ISO_DIR"

echo "Téléchargement de l'ISO..."
wget -c "$ISO_URL"  # -c pour reprendre si interruption

echo "Téléchargement du checksum..."
wget -O SHA256SUMS "$CHECKSUM_URL"

echo "Vérification de l'intégrité..."
sha256sum -c SHA256SUMS 2>&1 | grep "$(basename $ISO_URL)"

echo "Nettoyage..."
rm SHA256SUMS

echo "Terminé ! ISO disponible dans $ISO_DIR"
```

> [!example] Utilisation du script
> 
> ```bash
> chmod +x download-iso.sh
> ./download-iso.sh
> ```

### Gestion de l'espace disque

**Vérifier l'espace disponible :**

```bash
# Espace disque du stockage local
df -h /var/lib/vz/

# Taille totale des ISO
du -sh /var/lib/vz/template/iso/

# Détail par fichier
du -h /var/lib/vz/template/iso/* | sort -h
```

> [!warning] Surveillance de l'espace Les ISO peuvent rapidement occuper beaucoup d'espace. Surveillez régulièrement :
> 
> ```bash
> # Alerter si moins de 10 GB disponibles
> AVAILABLE=$(df /var/lib/vz/ | tail -1 | awk '{print $4}')
> if [ $AVAILABLE -lt 10485760 ]; then
>     echo "ATTENTION : Espace disque faible !"
> fi
> ```

---

## 📦 Templates de conteneurs CT

Les templates LXC sont des images système préconfigurées permettant de créer des conteneurs en quelques secondes. Contrairement aux VMs qui nécessitent une ISO et une installation complète, les conteneurs utilisent ces templates prêts à l'emploi.

### Différence entre VM et conteneur

|Caractéristique|Machine Virtuelle (VM)|Conteneur LXC|
|---|---|---|
|Virtualisation|Matériel complet|Système d'exploitation|
|Ressources|Lourdes (RAM, CPU)|Légères|
|Démarrage|Minutes|Secondes|
|Isolation|Totale|Partagée (noyau)|
|Source|ISO + installation|Template|

> [!info] Quand utiliser un conteneur ?
> 
> - Applications web (serveurs web, bases de données)
> - Services réseau (DNS, DHCP, reverse proxy)
> - Environnements de développement
> - Services légers ne nécessitant pas de noyau spécifique

### Téléchargement de templates via l'interface web

**Étapes détaillées :**

1. **Accéder au stockage de templates**
    
    - Sélectionnez votre nœud Proxmox
    - Cliquez sur le stockage (généralement `local`)
    - Onglet `CT Templates`
2. **Explorer les templates disponibles**
    
    - Bouton `Templates` en haut
    - Liste des distributions disponibles avec descriptions
3. **Télécharger un template**
    
    - Sélectionnez la distribution souhaitée (ex: Ubuntu 22.04)
    - Cliquez sur `Download`
    - Proxmox télécharge et installe automatiquement

> [!tip] Templates recommandés pour débuter
> 
> - **Ubuntu 22.04** : Stable, bien documenté, idéal pour la plupart des services
> - **Debian 12** : Léger, stable, excellente base pour serveurs
> - **Alpine Linux** : Ultra-léger (5-10 MB), parfait pour microservices
> - **Rocky Linux 9** : Alternative à CentOS, pour environnements entreprise

### Téléchargement via ligne de commande

Proxmox utilise l'outil `pveam` (Proxmox VE Appliance Manager) pour gérer les templates.

**Lister les templates disponibles :**

```bash
# Mettre à jour la liste des templates
pveam update

# Afficher tous les templates disponibles
pveam available

# Filtrer par distribution
pveam available | grep ubuntu
pveam available | grep debian
pveam available | grep alpine
```

**Télécharger un template spécifique :**

```bash
# Syntaxe générale
pveam download local NOM_DU_TEMPLATE

# Exemples concrets
pveam download local ubuntu-22.04-standard_22.04-1_amd64.tar.zst
pveam download local debian-12-standard_12.2-1_amd64.tar.zst
pveam download local alpine-3.18-default_20230607_amd64.tar.xz

# Télécharger dans un stockage spécifique
pveam download mon-stockage-nfs ubuntu-22.04-standard_22.04-1_amd64.tar.zst
```

> [!example] Téléchargement avec vérification
> 
> ```bash
> # Télécharger et afficher la progression
> pveam download local ubuntu-22.04-standard_22.04-1_amd64.tar.zst
> 
> # Vérifier que le template est bien installé
> pveam list local
> ```

### Gestion des templates installés

**Lister les templates locaux :**

```bash
# Tous les templates installés
pveam list local

# Affichage détaillé avec tailles
ls -lh /var/lib/vz/template/cache/

# Informations sur un template spécifique
file /var/lib/vz/template/cache/ubuntu-22.04-standard_22.04-1_amd64.tar.zst
```

**Supprimer un template :**

```bash
# Via pveam (recommandé)
pveam remove local ubuntu-20.04-standard_20.04-1_amd64.tar.gz

# Via rm (fonctionne aussi)
rm /var/lib/vz/template/cache/ubuntu-20.04-standard_20.04-1_amd64.tar.gz

# Via l'interface web : onglet CT Templates → sélectionner → Remove
```

> [!warning] Ne pas supprimer un template en cours d'utilisation Si des conteneurs sont en cours de création avec ce template, attendez la fin du processus avant de le supprimer.

### Structure et nomenclature des templates

Les templates suivent une nomenclature standardisée :

```
distribution-version-variant_build_architecture.extension
```

**Exemples décodés :**

|Nom du fichier|Distribution|Version|Variant|Build|Architecture|
|---|---|---|---|---|---|
|`ubuntu-22.04-standard_22.04-1_amd64.tar.zst`|Ubuntu|22.04|standard|22.04-1|amd64|
|`debian-12-standard_12.2-1_amd64.tar.zst`|Debian|12|standard|12.2-1|amd64|
|`alpine-3.18-default_20230607_amd64.tar.xz`|Alpine|3.18|default|20230607|amd64|

**Types de variants :**

- **standard** : Installation complète avec systemd, outils courants
- **default** : Installation minimale (Alpine)
- Certaines distributions proposent d'autres variants (cloud, minimal, etc.)

### Création d'un conteneur depuis un template

Une fois le template téléchargé, créer un conteneur est instantané :

**Via l'interface web :**

1. Bouton `Create CT` en haut à droite
2. **General** : ID, hostname, mot de passe
3. **Template** : Sélectionner le template téléchargé
4. **Disks, CPU, Memory, Network** : Configuration des ressources
5. **Confirm** : Créer le conteneur

**Via ligne de commande :**

```bash
# Créer un conteneur Ubuntu 22.04
pct create 100 local:vztmpl/ubuntu-22.04-standard_22.04-1_amd64.tar.zst \
  --hostname mon-conteneur \
  --password monmotdepasse \
  --memory 512 \
  --cores 1 \
  --net0 name=eth0,bridge=vmbr0,ip=dhcp \
  --storage local-lvm \
  --rootfs 8

# Démarrer le conteneur
pct start 100

# Se connecter au conteneur
pct enter 100
```

> [!info] Paramètres expliqués
> 
> - `100` : ID du conteneur (100-999 pour les conteneurs)
> - `local:vztmpl/...` : Chemin vers le template
> - `--hostname` : Nom du conteneur
> - `--memory` : RAM en MB
> - `--cores` : Nombre de cœurs CPU
> - `--net0` : Configuration réseau (DHCP ou IP statique)
> - `--rootfs` : Taille du disque système en GB

### Templates personnalisés et communautaires

**Turnkey Linux** (templates avancés) :

Proxmox peut télécharger des templates Turnkey Linux, qui sont des appliances préconfigurées pour des usages spécifiques :

```bash
# Lister les templates Turnkey disponibles
pveam available --section turnkeylinux

# Exemples de templates Turnkey
pveam download local turnkey-wordpress-17.1-bullseye-amd64.tar.gz
pveam download local turnkey-nextcloud-17.1-bullseye-amd64.tar.gz
pveam download local turnkey-gitlab-17.1-bullseye-amd64.tar.gz
```

> [!tip] Turnkey Linux - Applications prêtes à l'emploi Ces templates incluent des applications préinstallées et préconfigurées :
> 
> - **WordPress** : Serveur web LAMP + WordPress
> - **Nextcloud** : Solution cloud personnel
> - **GitLab** : Plateforme DevOps complète
> - **Portainer** : Interface de gestion Docker

**Créer son propre template (aperçu) :**

Vous pouvez convertir un conteneur configuré en template pour le réutiliser, mais cela relève d'une autre partie du cours (gestion des conteneurs).

---

## ✅ Bonnes pratiques

### Organisation des ISO et templates

**Structure recommandée :**

```bash
# Organiser avec des sous-dossiers (si stockage le permet)
/var/lib/vz/template/iso/
├── linux/
│   ├── ubuntu/
│   ├── debian/
│   └── centos/
├── windows/
└── autres/

# Nommage clair et versionné
ubuntu-22.04.3-server.iso
debian-12.2-netinst.iso
windows-server-2022-eval.iso
```

> [!tip] Astuce de nommage Incluez toujours la version exacte dans le nom du fichier pour éviter toute confusion :
> 
> ```bash
> # Bon
> ubuntu-22.04.3-live-server-amd64.iso
> 
> # Mauvais (trop vague)
> ubuntu-server.iso
> ubuntu-latest.iso
> ```

### Vérification systématique des checksums

**Pourquoi c'est crucial :**

- Détecter les téléchargements corrompus
- Garantir l'authenticité (sécurité)
- Éviter les installations défectueuses

**Automatisation de la vérification :**

```bash
#!/bin/bash
# verify-iso.sh - Vérifier l'intégrité d'une ISO

ISO_FILE="$1"
CHECKSUM_FILE="$2"

if [ ! -f "$ISO_FILE" ] || [ ! -f "$CHECKSUM_FILE" ]; then
    echo "Usage: $0 fichier.iso fichier.sha256"
    exit 1
fi

echo "Vérification de $ISO_FILE..."
sha256sum -c "$CHECKSUM_FILE" 2>&1 | grep "$(basename $ISO_FILE)"

if [ $? -eq 0 ]; then
    echo "✓ Vérification réussie !"
else
    echo "✗ Échec de la vérification - fichier corrompu ou modifié"
    exit 1
fi
```

### Gestion de l'espace disque

**Surveillance proactive :**

```bash
# Créer un script de monitoring
#!/bin/bash
# monitor-storage.sh

THRESHOLD=90  # Alerte si > 90% utilisé

USAGE=$(df /var/lib/vz/ | tail -1 | awk '{print $5}' | sed 's/%//')

if [ $USAGE -gt $THRESHOLD ]; then
    echo "ALERTE : Stockage à ${USAGE}% d'utilisation !"
    echo "Fichiers les plus volumineux :"
    du -h /var/lib/vz/template/iso/* | sort -rh | head -5
fi
```

**Nettoyage régulier :**

```bash
# Supprimer les anciennes versions
# Exemple : garder uniquement la dernière version d'Ubuntu
ls -t /var/lib/vz/template/iso/ubuntu-*.iso | tail -n +2 | xargs rm

# Supprimer les templates non utilisés
pveam list local | grep "old-version" | awk '{print $1}' | xargs -I {} pveam remove local {}
```

> [!warning] Attention avant de supprimer Vérifiez toujours qu'aucune VM ou conteneur n'est en cours de création avant de supprimer des ISO ou templates.

### Optimisation des téléchargements

**Utiliser un miroir local ou cache :**

Si vous gérez plusieurs serveurs Proxmox, configurez un serveur de cache central pour éviter de télécharger plusieurs fois les mêmes ISO.

```bash
# Serveur de cache avec apt-cacher-ng (pour templates Debian/Ubuntu)
apt install apt-cacher-ng

# Configurer Proxmox pour utiliser le cache
# Dans /etc/apt/apt.conf.d/02proxy
Acquire::http::Proxy "http://IP_DU_CACHE:3142";
```

**Planifier les téléchargements :**

```bash
# Télécharger la nuit avec cron
# Ajouter dans crontab (crontab -e)
0 2 * * 0 /usr/local/bin/download-updates.sh

# Script download-updates.sh
#!/bin/bash
pveam update
pveam download local ubuntu-22.04-standard_22.04-1_amd64.tar.zst
```

### Documentation et traçabilité

**Maintenir un inventaire :**

```bash
# Créer un fichier d'inventaire
cat > /var/lib/vz/template/iso/INVENTORY.md << 'EOF'
# Inventaire des ISO et Templates

## ISO disponibles

| Fichier | Version | Date d'ajout | Utilisation | Checksum vérifié |
|---------|---------|--------------|-------------|------------------|
| ubuntu-22.04.3-server.iso | 22.04.3 | 2024-01-15 | Production | ✓ |
| debian-12.2-netinst.iso | 12.2 | 2024-01-20 | Test | ✓ |

## Templates de conteneurs

| Template | Distribution | Usage | Nombre de conteneurs |
|----------|--------------|-------|----------------------|
| ubuntu-22.04-standard | Ubuntu 22.04 | Web servers | 5 |
| debian-12-standard | Debian 12 | Base services | 3 |

Dernière mise à jour : 2024-01-25
EOF
```

> [!tip] Versioning et changelog Gardez une trace des ajouts, suppressions et mises à jour pour faciliter l'audit et la maintenance.

### Sécurité des sources

**Vérifier les sources officielles :**

- Téléchargez toujours depuis les sites officiels
- Utilisez HTTPS pour tous les téléchargements
- Vérifiez les signatures GPG si disponibles

```bash
# Vérifier une signature GPG (exemple Ubuntu)
wget https://releases.ubuntu.com/22.04/ubuntu-22.04.3-live-server-amd64.iso
wget https://releases.ubuntu.com/22.04/SHA256SUMS
wget https://releases.ubuntu.com/22.04/SHA256SUMS.gpg

# Importer la clé publique Ubuntu
gpg --keyserver keyserver.ubuntu.com --recv-keys 0x843938DF228D22F7B3742BC0D94AA3F0EFE21092

# Vérifier la signature
gpg --verify SHA256SUMS.gpg SHA256SUMS
```

---

> [!tip] Récapitulatif des commandes essentielles
> 
> ```bash
> # ISO
> ls -lh /var/lib/vz/template/iso/
> wget -P /var/lib/vz/template/iso/ URL_ISO
> sha256sum fichier.iso
> 
> # Templates CT
> pveam update
> pveam available | grep ubuntu
> pveam download local nom-template
> pveam list local
> pveam remove local ancien-template
> 
> # Espace disque
> df -h /var/lib/vz/
> du -sh /var/lib/vz/template/{iso,cache}/
> ```

---

**📌 Points clés à retenir :**

- Les ISO servent à installer des OS sur des VMs, les templates CT créent instantanément des conteneurs
- Privilégiez SCP/wget pour les gros fichiers plutôt que l'upload web
- Vérifiez systématiquement les checksums pour garantir l'intégrité
- Utilisez `pveam` pour gérer efficacement les templates de conteneurs
- Surveillez l'espace disque et nettoyez régulièrement les anciennes versions
- Documentez vos ISO et templates pour faciliter la maintenance