

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

## 🎯 Introduction

Dans un environnement professionnel moderne, il est courant de travailler avec plusieurs systèmes d'exploitation. La gestion des clés SSH entre Linux et Windows présente des défis spécifiques dus aux différences de formats et d'outils utilisés.

> [!info] Contexte Windows et Linux utilisent historiquement des formats différents pour stocker les clés SSH. Comprendre ces différences et savoir convertir entre les formats est essentiel pour maintenir une infrastructure de clés cohérente.

**Pourquoi c'est important :**

- Éviter la multiplication inutile de clés
- Simplifier la gestion des accès
- Maintenir une posture de sécurité cohérente
- Faciliter la mobilité entre environnements

---

## 🔑 Formats de clés SSH

### Format OpenSSH (standard Linux/macOS)

Le format OpenSSH est le format natif utilisé par les systèmes Unix/Linux et macOS. Il existe en plusieurs versions :

**Format classique (ancien format)** :

```
-----BEGIN RSA PRIVATE KEY-----
MIIEpAIBAAKCAQEA...
-----END RSA PRIVATE KEY-----
```

**Format moderne (RFC 4716)** :

```
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAA...
-----END OPENSSH PRIVATE KEY-----
```

> [!tip] Format par défaut Depuis OpenSSH 7.8, le format par défaut est le format moderne qui offre une meilleure sécurité et supporte tous les types de clés (RSA, Ed25519, ECDSA).

### Format PuTTY (PPK - PuTTY Private Key)

PuTTY, le client SSH le plus populaire sur Windows, utilise son propre format propriétaire avec l'extension `.ppk`.

**Structure d'un fichier PPK** :

```
PuTTY-User-Key-File-2: ssh-rsa
Encryption: none
Comment: rsa-key-20240101
Public-Lines: 6
AAAAB3NzaC1yc2EAAAADAQABAAAB...
Private-Lines: 14
AAABAQCx8H5t9K2L...
Private-MAC: d0e8f6a7b9c8d7e6f5a4b3c2d1e0f9a8b7c6d5e4
```

**Caractéristiques du format PPK :**

- Contient à la fois la clé publique et privée
- Inclut un MAC (Message Authentication Code) pour l'intégrité
- Supporte le chiffrement par mot de passe
- Non compatible directement avec OpenSSH

### Comparaison des formats

|Caractéristique|OpenSSH|PuTTY (PPK)|
|---|---|---|
|**Plateforme native**|Linux/macOS/Windows (natif)|Windows (PuTTY suite)|
|**Extension**|Aucune ou `.pem`|`.ppk`|
|**Lisibilité**|Base64 standard|Format propriétaire|
|**Compatibilité**|Universelle|Limitée à PuTTY|
|**Clé publique**|Fichier séparé `.pub`|Incluse dans le PPK|
|**Versions**|Ancien et moderne|PPK-2, PPK-3|

> [!warning] Attention aux versions Le format PPK-3 (introduit avec PuTTY 0.75) utilise Argon2 pour le chiffrement et n'est pas compatible avec les anciennes versions de PuTTY.

---

## 🔄 Conversion de formats (PuTTY ↔ OpenSSH)

### PuTTYgen : l'outil de conversion principal

PuTTYgen est l'outil de référence pour convertir entre les formats OpenSSH et PuTTY. Il est disponible sur Windows et Linux.

#### Installation de PuTTYgen

**Sur Windows** :

```bash
# PuTTYgen est inclus dans l'installateur PuTTY
# Télécharger depuis : https://www.putty.org/
```

**Sur Linux** :

```bash
# Debian/Ubuntu
sudo apt install putty-tools

# RedHat/CentOS/Fedora
sudo yum install putty

# Arch Linux
sudo pacman -S putty
```

### Conversion OpenSSH → PuTTY (PPK)

#### Méthode graphique (Windows)

1. Ouvrir PuTTYgen
2. Menu : `Conversions` → `Import key`
3. Sélectionner votre clé OpenSSH privée
4. (Optionnel) Ajouter une passphrase
5. Cliquer sur `Save private key`
6. Sauvegarder avec l'extension `.ppk`

#### Méthode en ligne de commande

```bash
# Conversion simple sans passphrase
puttygen id_rsa -o id_rsa.ppk

# Conversion avec commentaire personnalisé
puttygen id_rsa -o id_rsa.ppk -C "Mon commentaire"

# Conversion avec nouvelle passphrase
puttygen id_rsa -o id_rsa.ppk --new-passphrase passphrase.txt

# Conversion en spécifiant le format PPK-3
puttygen id_rsa -o id_rsa.ppk --ppk-version 3
```

> [!example] Exemple complet
> 
> ```bash
> # Convertir une clé Ed25519 OpenSSH en PPK
> puttygen ~/.ssh/id_ed25519 -o ~/Documents/my_key.ppk -C "Clé professionnelle"
> 
> # Vérifier la conversion
> puttygen ~/Documents/my_key.ppk -L
> ```

### Conversion PuTTY (PPK) → OpenSSH

#### Méthode graphique

1. Ouvrir PuTTYgen
2. Cliquer sur `Load` et sélectionner votre fichier `.ppk`
3. Menu : `Conversions` → `Export OpenSSH key`
4. Sauvegarder (généralement sans extension ou `.pem`)

#### Méthode en ligne de commande

```bash
# Exporter la clé privée au format OpenSSH
puttygen id_rsa.ppk -O private-openssh -o id_rsa

# Exporter la clé publique au format OpenSSH
puttygen id_rsa.ppk -O public-openssh -o id_rsa.pub

# Exporter la clé publique au format RFC 4716
puttygen id_rsa.ppk -O public -o id_rsa_rfc4716.pub
```

> [!tip] Extraction de la clé publique Si vous n'avez que le fichier PPK, vous pouvez toujours extraire la clé publique :
> 
> ```bash
> puttygen id_rsa.ppk -L
> # Ou directement dans un fichier
> puttygen id_rsa.ppk -o id_rsa.pub -O public-openssh
> ```

### Conversion directe avec ssh-keygen

Depuis OpenSSH 7.6, `ssh-keygen` peut importer des clés au format PuTTY :

```bash
# Importer un PPK et le convertir en OpenSSH
ssh-keygen -i -f id_rsa.ppk > id_rsa

# Important : définir les bonnes permissions
chmod 600 id_rsa
```

> [!warning] Limitations de ssh-keygen
> 
> - Ne fonctionne que pour les clés PPK non chiffrées
> - Ne supporte pas toujours les dernières versions du format PPK
> - PuTTYgen reste l'outil le plus fiable pour les conversions

### Conversion de formats de clés publiques

Les clés publiques peuvent aussi avoir des formats différents :

```bash
# Format OpenSSH (une seule ligne)
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAB... user@host

# Format RFC 4716 (multi-lignes avec en-têtes)
---- BEGIN SSH2 PUBLIC KEY ----
Comment: "user@host"
AAAAB3NzaC1yc2EAAAADAQABAAAB...
---- END SSH2 PUBLIC KEY ----
```

**Conversion avec ssh-keygen** :

```bash
# RFC 4716 → OpenSSH
ssh-keygen -i -f id_rsa_rfc4716.pub > id_rsa.pub

# OpenSSH → RFC 4716
ssh-keygen -e -f id_rsa.pub > id_rsa_rfc4716.pub
```

---

## 🔁 Utilisation des mêmes clés sur Linux et Windows

### Stratégie de gestion unifiée

L'objectif est de maintenir une seule paire de clés utilisable sur tous vos systèmes.

> [!info] Approche recommandée Générer les clés au format OpenSSH et les convertir en PPK uniquement si nécessaire. Cela garantit la compatibilité maximale.

### Scénario 1 : Génération sur Linux, utilisation sur Windows

**Étape 1 : Générer la clé sur Linux**

```bash
# Générer une clé Ed25519 (recommandé)
ssh-keygen -t ed25519 -C "utilisateur@entreprise.com" -f ~/.ssh/id_ed25519

# Résultat : deux fichiers
# ~/.ssh/id_ed25519 (clé privée)
# ~/.ssh/id_ed25519.pub (clé publique)
```

**Étape 2 : Transférer les clés vers Windows**

```bash
# Option 1 : Via SCP depuis Linux
scp ~/.ssh/id_ed25519* utilisateur@windows-pc:/Users/utilisateur/.ssh/

# Option 2 : Via partage réseau ou clé USB
```

**Étape 3 : Convertir pour PuTTY (si nécessaire)**

```powershell
# Sur Windows, avec PuTTYgen installé
puttygen C:\Users\utilisateur\.ssh\id_ed25519 -o C:\Users\utilisateur\.ssh\id_ed25519.ppk
```

**Étape 4 : Configuration**

```bash
# Linux : utiliser directement OpenSSH
ssh -i ~/.ssh/id_ed25519 user@serveur

# Windows : utiliser PuTTY avec le fichier PPK
# Ou utiliser OpenSSH natif de Windows 10+ avec le fichier original
```

### Scénario 2 : Génération sur Windows, utilisation sur Linux

**Étape 1 : Générer avec PuTTYgen ou OpenSSH Windows**

```powershell
# Option A : Avec OpenSSH natif Windows (recommandé)
ssh-keygen -t ed25519 -C "utilisateur@entreprise.com" -f C:\Users\utilisateur\.ssh\id_ed25519

# Option B : Avec PuTTYgen (génère directement en PPK)
# Interface graphique : Generate → Save private key
```

**Étape 2 : Convertir si généré avec PuTTYgen**

```powershell
# Exporter au format OpenSSH depuis PuTTYgen
puttygen id_ed25519.ppk -O private-openssh -o id_ed25519
puttygen id_ed25519.ppk -O public-openssh -o id_ed25519.pub
```

**Étape 3 : Transférer vers Linux**

```powershell
# Via SCP depuis Windows
scp C:\Users\utilisateur\.ssh\id_ed25519* utilisateur@linux-machine:~/.ssh/
```

**Étape 4 : Corriger les permissions sur Linux**

```bash
# CRUCIAL : Les clés doivent avoir les bonnes permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
```

### Utilisation avec OpenSSH natif sur Windows 10/11

Windows 10 (depuis 1809) et Windows 11 incluent OpenSSH natif, ce qui simplifie grandement l'interopérabilité.

**Vérifier la disponibilité** :

```powershell
# Vérifier si OpenSSH est installé
Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'

# Installer si nécessaire
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
```

**Utilisation directe** :

```powershell
# Utiliser les clés OpenSSH directement sous Windows
ssh -i C:\Users\utilisateur\.ssh\id_ed25519 user@serveur

# Configuration dans C:\Users\utilisateur\.ssh\config
Host monserveur
    HostName serveur.exemple.com
    User admin
    IdentityFile C:\Users\utilisateur\.ssh\id_ed25519
```

> [!tip] Meilleure pratique Si vous utilisez Windows 10/11, privilégiez OpenSSH natif plutôt que PuTTY. Cela élimine le besoin de conversion et maintient une expérience cohérente entre plateformes.

### Synchronisation des clés entre machines

**Méthode manuelle sécurisée** :

```bash
# Depuis la machine source
tar czf - ~/.ssh/id_* | ssh user@machine-cible "tar xzf - -C ~/"

# Vérifier les permissions sur la cible
ssh user@machine-cible "chmod 700 ~/.ssh && chmod 600 ~/.ssh/id_*"
```

**Stockage sécurisé avec Git (pour clés publiques uniquement)** :

```bash
# Créer un dépôt privé pour vos clés publiques
mkdir ~/ssh-keys-backup
cd ~/ssh-keys-backup
git init

# Ajouter uniquement les clés publiques
cp ~/.ssh/*.pub .
git add *.pub
git commit -m "Backup des clés publiques"

# Pousser vers un dépôt privé
git remote add origin git@github.com:utilisateur/ssh-keys-private.git
git push -u origin main
```

> [!warning] Ne jamais versionner les clés privées Les clés privées ne doivent JAMAIS être stockées dans Git, même dans un dépôt privé. Seules les clés publiques peuvent être sauvegardées ainsi.

### Gestion centralisée avec un gestionnaire de secrets

Pour un environnement professionnel, considérez des solutions comme :

- **1Password / Bitwarden** : Stockage chiffré avec synchronisation
- **HashiCorp Vault** : Gestion de secrets d'entreprise
- **AWS Secrets Manager / Azure Key Vault** : Solutions cloud

```bash
# Exemple conceptuel avec un gestionnaire de secrets
# (la syntaxe exacte dépend de l'outil)

# Stocker une clé
secret-manager store ssh-key-prod < ~/.ssh/id_ed25519

# Récupérer sur une autre machine
secret-manager retrieve ssh-key-prod > ~/.ssh/id_ed25519
chmod 600 ~/.ssh/id_ed25519
```

---

## 🛠️ Outils de conversion

### PuTTYgen : l'outil complet

PuTTYgen est plus qu'un simple convertisseur, c'est un outil complet de gestion de clés.

#### Fonctionnalités principales

**Génération de clés** :

```bash
# Générer une nouvelle clé RSA 4096
puttygen -t rsa -b 4096 -C "commentaire" -o nouvelle_cle.ppk

# Générer une clé Ed25519
puttygen -t ed25519 -C "commentaire" -o nouvelle_cle.ppk

# Générer avec passphrase depuis un fichier
puttygen -t ed25519 -o nouvelle_cle.ppk --new-passphrase passphrase.txt
```

**Inspection de clés** :

```bash
# Afficher les détails d'une clé PPK
puttygen ma_cle.ppk -L

# Afficher l'empreinte (fingerprint)
puttygen ma_cle.ppk -l

# Afficher la clé publique
puttygen ma_cle.ppk -p
```

**Modification de clés** :

```bash
# Changer la passphrase d'une clé
puttygen ma_cle.ppk -P --old-passphrase ancien.txt --new-passphrase nouveau.txt -o ma_cle_new.ppk

# Changer le commentaire
puttygen ma_cle.ppk -C "Nouveau commentaire" -o ma_cle.ppk

# Mettre à jour vers PPK-3
puttygen ma_cle_v2.ppk --ppk-version 3 -o ma_cle_v3.ppk
```

> [!example] Workflow complet avec PuTTYgen
> 
> ```bash
> # 1. Importer une clé OpenSSH
> puttygen ~/.ssh/id_rsa -o ~/keys/id_rsa.ppk
> 
> # 2. Vérifier l'importation
> puttygen ~/keys/id_rsa.ppk -L
> 
> # 3. Extraire la clé publique
> puttygen ~/keys/id_rsa.ppk -O public-openssh -o ~/keys/id_rsa.pub
> 
> # 4. Changer la passphrase
> puttygen ~/keys/id_rsa.ppk -P -o ~/keys/id_rsa_secured.ppk
> ```

### ssh-keygen : l'outil natif OpenSSH

`ssh-keygen` offre des fonctionnalités de conversion limitées mais pratiques.

**Conversions supportées** :

```bash
# Importer un format RFC 4716 ou SECSH
ssh-keygen -i -f cle_externe.pub > cle_openssh.pub

# Exporter vers RFC 4716
ssh-keygen -e -f ~/.ssh/id_rsa.pub > cle_rfc4716.pub

# Changer le format d'une clé privée
ssh-keygen -p -f ~/.ssh/id_rsa -m PEM  # Ancien format
ssh-keygen -p -f ~/.ssh/id_rsa -m RFC4716  # Format moderne
```

**Manipulation de clés** :

```bash
# Changer la passphrase
ssh-keygen -p -f ~/.ssh/id_rsa

# Afficher l'empreinte
ssh-keygen -l -f ~/.ssh/id_rsa.pub

# Afficher l'empreinte avec un hash spécifique
ssh-keygen -l -E sha256 -f ~/.ssh/id_rsa.pub
ssh-keygen -l -E md5 -f ~/.ssh/id_rsa.pub

# Générer une clé dérivée
ssh-keygen -y -f ~/.ssh/id_rsa > ~/.ssh/id_rsa_derived.pub
```

### Outils en ligne de commande alternatifs

**OpenSSL (pour conversions avancées)** :

```bash
# Convertir PEM vers format OpenSSH privé
openssl rsa -in cle.pem -out cle_openssh

# Extraire la clé publique d'une clé privée PEM
openssl rsa -in cle.pem -pubout -out cle.pub

# Vérifier une clé privée
openssl rsa -in cle.pem -check
```

**ssh-copy-id (déploiement rapide)** :

```bash
# Copier automatiquement une clé publique vers un serveur
ssh-copy-id -i ~/.ssh/id_ed25519.pub user@serveur

# Spécifier un port non-standard
ssh-copy-id -i ~/.ssh/id_ed25519.pub -p 2222 user@serveur

# Utiliser une clé d'identité différente pour la connexion
ssh-copy-id -i ~/.ssh/id_ed25519.pub -o "IdentityFile ~/.ssh/autre_cle" user@serveur
```

### Scripts de conversion automatisés

**Script Bash pour conversion en masse** :

```bash
#!/bin/bash
# convert_keys.sh - Convertir plusieurs clés OpenSSH vers PPK

for key in ~/.ssh/id_*; do
    # Ignorer les clés publiques
    [[ "$key" == *.pub ]] && continue
    
    # Nom du fichier PPK
    ppk_file="${key}.ppk"
    
    echo "Conversion de $key vers $ppk_file"
    puttygen "$key" -o "$ppk_file" -C "Converti le $(date)"
    
    if [ $? -eq 0 ]; then
        echo "✓ Conversion réussie"
    else
        echo "✗ Erreur lors de la conversion"
    fi
done
```

**Script PowerShell pour Windows** :

```powershell
# ConvertTo-PPK.ps1 - Convertir les clés OpenSSH en PPK

param(
    [string]$SourceDir = "$env:USERPROFILE\.ssh",
    [string]$OutputDir = "$env:USERPROFILE\.ssh\ppk"
)

# Créer le dossier de sortie
New-Item -ItemType Directory -Force -Path $OutputDir | Out-Null

Get-ChildItem -Path $SourceDir -File | Where-Object {
    $_.Name -like "id_*" -and $_.Extension -ne ".pub" -and $_.Extension -ne ".ppk"
} | ForEach-Object {
    $outputFile = Join-Path $OutputDir "$($_.Name).ppk"
    Write-Host "Conversion de $($_.Name)..."
    
    & puttygen $_.FullName -o $outputFile -C "Converti $(Get-Date -Format 'yyyy-MM-dd')"
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ $($_.Name) converti avec succès" -ForegroundColor Green
    } else {
        Write-Host "✗ Erreur lors de la conversion de $($_.Name)" -ForegroundColor Red
    }
}
```

---

## ✅ Bonnes pratiques multi-plateformes

### 1. Privilégier le format OpenSSH comme standard

> [!tip] Règle d'or Générez toujours vos clés au format OpenSSH, et convertissez en PPK uniquement si nécessaire. Cela garantit une compatibilité maximale.

**Avantages** :

- Standard universel reconnu partout
- Support natif sur Linux, macOS et Windows moderne
- Évolution continue avec de nouvelles fonctionnalités
- Meilleure documentation et communauté

**Mise en œuvre** :

```bash
# Sur n'importe quelle plateforme
ssh-keygen -t ed25519 -C "votre_email@exemple.com"

# Convertir pour PuTTY seulement si nécessaire
puttygen ~/.ssh/id_ed25519 -o ~/.ssh/id_ed25519.ppk
```

### 2. Organiser vos clés de manière cohérente

**Structure recommandée** :

```
~/.ssh/                          # Linux/macOS
C:\Users\utilisateur\.ssh\       # Windows

├── config                       # Configuration SSH
├── known_hosts                  # Hôtes connus
├── authorized_keys              # Clés autorisées (serveur)
│
├── id_ed25519                   # Clé privée principale
├── id_ed25519.pub               # Clé publique principale
├── id_ed25519.ppk               # Version PPK (si nécessaire)
│
├── id_rsa_work                  # Clé professionnelle
├── id_rsa_work.pub
├── id_rsa_work.ppk
│
├── id_ed25519_backup_2024       # Clé de backup
└── id_ed25519_backup_2024.pub
```

**Convention de nommage** :

```bash
# Format : id_[type]_[usage]_[date/version]
id_ed25519_prod_2024
id_rsa_client_acme
id_ecdsa_personal

# Toujours avec son .pub correspondant
id_ed25519_prod_2024.pub
```

### 3. Maintenir la cohérence des permissions

Les permissions sont cruciales pour la sécurité SSH, mais diffèrent entre plateformes.

**Sur Linux/macOS** :

```bash
# Répertoire SSH
chmod 700 ~/.ssh

# Clés privées (CRITIQUE)
chmod 600 ~/.ssh/id_*
chmod 600 ~/.ssh/config

# Clés publiques
chmod 644 ~/.ssh/*.pub

# Fichier authorized_keys
chmod 600 ~/.ssh/authorized_keys

# Script de vérification
#!/bin/bash
find ~/.ssh -type f -name "id_*" ! -name "*.pub" -exec chmod 600 {} \;
find ~/.ssh -type f -name "*.pub" -exec chmod 644 {} \;
chmod 700 ~/.ssh
```

**Sur Windows** :

```powershell
# Retirer l'héritage et définir les permissions explicites
icacls C:\Users\utilisateur\.ssh\id_ed25519 /inheritance:r
icacls C:\Users\utilisateur\.ssh\id_ed25519 /grant:r "$($env:USERNAME):(R,W)"

# Script PowerShell pour sécuriser toutes les clés privées
Get-ChildItem C:\Users\$env:USERNAME\.ssh -File | Where-Object {
    $_.Name -like "id_*" -and $_.Extension -ne ".pub"
} | ForEach-Object {
    icacls $_.FullName /inheritance:r
    icacls $_.FullName /grant:r "$($env:USERNAME):(R,W)"
}
```

> [!warning] Erreur courante Si SSH refuse vos clés avec "UNPROTECTED PRIVATE KEY FILE", c'est un problème de permissions. Les clés privées ne doivent être lisibles que par vous.

### 4. Documenter vos clés

Maintenez un inventaire clair de vos clés, surtout dans un environnement multi-plateformes.

**Fichier d'inventaire** (`~/.ssh/KEYS_INVENTORY.md`) :

```markdown
# Inventaire des clés SSH

## Clé principale
- **Fichier**: id_ed25519
- **Type**: Ed25519
- **Créée**: 2024-01-15
- **Usage**: Accès personnel à tous les serveurs
- **Serveurs**: prod-web-01, prod-db-01, backup-server
- **Passphrase**: Oui (gestionnaire de mots de passe)
- **Formats disponibles**: OpenSSH, PPK (pour PuTTY)

## Clé professionnelle
- **Fichier**: id_rsa_work
- **Type**: RSA 4096
- **Créée**: 2023-06-20
- **Usage**: Accès entreprise uniquement
- **Serveurs**: gitlab.entreprise.com, jenkins.internal
- **Expiration**: 2025-06-20
- **Passphrase**: Oui (différente de la clé principale)
```

### 5. Utiliser des alias et configurations centralisées

**Configuration SSH unifiée** (`~/.ssh/config`) :

```bash
# Configuration globale
Host *
    ServerAliveInterval 60
    ServerAliveCountMax 3
    AddKeysToAgent yes
    # Sur Linux/macOS, ajouter :
    # UseKeychain yes

# Serveur de production
Host prod
    HostName prod-server.exemple.com
    User admin
    IdentityFile ~/.ssh/id_ed25519
    Port 22

# Serveur via bastion
Host internal-*
    ProxyJump bastion.exemple.com
    IdentityFile ~/.ssh/id_rsa_work
    User deployer

Host internal-web
    HostName web-internal.local

Host internal-db
    HostName db-internal.local
```

**Synchroniser entre Linux et Windows** :

```bash
# Le fichier config est identique, seuls les chemins diffèrent
# Linux: ~/.ssh/config
# Windows: C:\Users\utilisateur\.ssh\config

# Créer des liens symboliques vers les clés
# Linux
ln -s ~/.ssh/id_ed25519 ~/.ssh/prod_key

# Windows (PowerShell en admin)
New-Item -ItemType SymbolicLink -Path "C:\Users\utilisateur\.ssh\prod_key" -Target "C:\Users\utilisateur\.ssh\id_ed25519"
```

### 6. Stratégie de sauvegarde multi-plateformes

**Sauvegarde sécurisée** :

```bash
#!/bin/bash
# backup_ssh_keys.sh

BACKUP_DIR="$HOME/Backups/ssh_backup_$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"

# Sauvegarder les clés (chiffrées)
tar czf - ~/.ssh/id_* ~/.ssh/config | gpg --symmetric --cipher-algo AES256 -o "$BACKUP_DIR/ssh_keys.tar.gz.gpg"

# Vérifier le backup
echo "Backup créé : $BACKUP_DIR"
ls -lh "$BACKUP_DIR"
```

**Restauration** :

```bash
# Déchiffrer et extraire
gpg --decrypt ssh_keys.tar.gz.gpg | tar xzf - -C ~/

# Corriger les permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_* ~/.ssh/config
chmod 644 ~/.ssh/*.pub
```

### 7. Gérer les passphrases de manière cohérente

**Utiliser un gestionnaire de mots de passe** :

- 1Password, Bitwarden, KeePassXC
- Synchronisation automatique entre appareils
- Sécurité renforcée

**SSH Agent sur Windows et Linux** :

```bash
# Linux - Ajouter au .bashrc ou .zshrc
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Windows - Démarrer le service
Get-Service ssh-agent | Set-Service -StartupType Automatic
Start-Service ssh-agent
ssh-add C:\Users\utilisateur\.ssh\id_ed25519
```

**Configuration agent avec config SSH** :

```bash
# Dans ~/.ssh/config (Linux/macOS)
Host *
    AddKeysToAgent yes
    UseKeychain yes  # macOS uniquement

# Windows utilise automatiquement l'agent si le service est démarré
```

### 8. Tester la compatibilité des clés

Avant de déployer une clé sur plusieurs plateformes, vérifiez sa compatibilité.

**Test de clé OpenSSH** :

```bash
# Vérifier l'intégrité
ssh-keygen -l -f ~/.ssh/id_ed25519

# Tester la connexion avec verbose
ssh -vvv -i ~/.ssh/id_ed25519 user@serveur

# Vérifier que la clé publique correspond à la privée
ssh-keygen -y -f ~/.ssh/id_ed25519 > /tmp/test.pub
diff ~/.ssh/id_ed25519.pub /tmp/test.pub
```

**Test de clé PPK** :

```bash
# Vérifier avec PuTTYgen
puttygen id_ed25519.ppk -L

# Tester l'empreinte
puttygen id_ed25519.ppk -l

# Vérifier la correspondance public/privé
puttygen id_ed25519.ppk -O public-openssh | diff - id_ed25519.pub
```

**Test de connexion multi-plateformes** :

```bash
# Linux/macOS
ssh -i ~/.ssh/id_ed25519 user@serveur "echo 'Test depuis $(uname)'"

# Windows PowerShell (OpenSSH)
ssh -i C:\Users\utilisateur\.ssh\id_ed25519 user@serveur "echo 'Test depuis Windows'"

# Windows (PuTTY)
plink -i C:\Users\utilisateur\.ssh\id_ed25519.ppk user@serveur "echo 'Test depuis PuTTY'"
```

### 9. Gérer les différences de fins de ligne

Les fichiers de configuration peuvent avoir des problèmes entre Windows (CRLF) et Linux (LF).

**Conversion de fins de ligne** :

```bash
# Linux - Convertir CRLF en LF
dos2unix ~/.ssh/config
dos2unix ~/.ssh/id_ed25519.pub

# Ou avec sed
sed -i 's/\r$//' ~/.ssh/config

# Windows PowerShell - Vérifier les fins de ligne
Get-Content C:\Users\utilisateur\.ssh\config -Raw | 
    Select-String -Pattern "`r`n" -AllMatches
```

**Configuration Git pour éviter les problèmes** :

```bash
# Dans le dossier .ssh (si géré par Git)
echo "* text=auto eol=lf" > ~/.ssh/.gitattributes
echo "*.ppk binary" >> ~/.ssh/.gitattributes
```

### 10. Automatiser les conversions avec des scripts

**Script de synchronisation complet** :

```bash
#!/bin/bash
# sync_ssh_keys.sh - Synchroniser les clés entre formats

set -e  # Arrêter en cas d'erreur

SSH_DIR="$HOME/.ssh"
PPK_DIR="$SSH_DIR/ppk"

# Créer le dossier PPK
mkdir -p "$PPK_DIR"

echo "=== Synchronisation des clés SSH ==="

# Parcourir toutes les clés privées OpenSSH
for key in "$SSH_DIR"/id_*; do
    # Ignorer les fichiers .pub et .ppk
    [[ "$key" == *.pub ]] && continue
    [[ "$key" == *.ppk ]] && continue
    [[ ! -f "$key" ]] && continue
    
    keyname=$(basename "$key")
    ppk_file="$PPK_DIR/${keyname}.ppk"
    
    echo "Traitement de $keyname..."
    
    # Convertir en PPK si nécessaire ou si plus récent
    if [[ ! -f "$ppk_file" ]] || [[ "$key" -nt "$ppk_file" ]]; then
        echo "  → Conversion en PPK..."
        puttygen "$key" -o "$ppk_file" -C "Sync $(date +%Y-%m-%d)"
        
        if [[ $? -eq 0 ]]; then
            echo "  ✓ Conversion réussie"
        else
            echo "  ✗ Erreur de conversion"
            continue
        fi
    else
        echo "  ⊙ PPK déjà à jour"
    fi
    
    # Vérifier la correspondance des empreintes
    openssh_fp=$(ssh-keygen -l -f "$key" | awk '{print $2}')
    ppk_fp=$(puttygen "$ppk_file" -l | awk '{print $2}')
    
    if [[ "$openssh_fp" == "$ppk_fp" ]]; then
        echo "  ✓ Empreintes correspondent"
    else
        echo "  ✗ ATTENTION : Empreintes différentes !"
    fi
    
    echo ""
done

echo "=== Synchronisation terminée ==="
echo "Clés PPK disponibles dans : $PPK_DIR"
```

**Script PowerShell équivalent** :

```powershell
# Sync-SSHKeys.ps1
param(
    [string]$SSHDir = "$env:USERPROFILE\.ssh",
    [string]$PPKDir = "$env:USERPROFILE\.ssh\ppk"
)

# Créer le dossier PPK
New-Item -ItemType Directory -Force -Path $PPKDir | Out-Null

Write-Host "=== Synchronisation des clés SSH ===" -ForegroundColor Cyan

Get-ChildItem -Path $SSHDir -File | Where-Object {
    $_.Name -like "id_*" -and 
    $_.Extension -notin @(".pub", ".ppk") -and
    $_.Name -notlike "*.ppk"
} | ForEach-Object {
    $keyFile = $_.FullName
    $keyName = $_.Name
    $ppkFile = Join-Path $PPKDir "$keyName.ppk"
    
    Write-Host "Traitement de $keyName..." -ForegroundColor Yellow
    
    # Vérifier si conversion nécessaire
    $needsConversion = $true
    if (Test-Path $ppkFile) {
        $keyTime = (Get-Item $keyFile).LastWriteTime
        $ppkTime = (Get-Item $ppkFile).LastWriteTime
        if ($ppkTime -ge $keyTime) {
            $needsConversion = $false
            Write-Host "  ⊙ PPK déjà à jour" -ForegroundColor Gray
        }
    }
    
    if ($needsConversion) {
        Write-Host "  → Conversion en PPK..." -ForegroundColor White
        $date = Get-Date -Format "yyyy-MM-dd"
        & puttygen $keyFile -o $ppkFile -C "Sync $date"
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  ✓ Conversion réussie" -ForegroundColor Green
        } else {
            Write-Host "  ✗ Erreur de conversion" -ForegroundColor Red
            return
        }
    }
    
    Write-Host ""
}

Write-Host "=== Synchronisation terminée ===" -ForegroundColor Cyan
Write-Host "Clés PPK disponibles dans : $PPKDir"
```

### 11. Résolution des problèmes courants

**Problème : "Permission denied (publickey)"** :

```bash
# Vérifier les permissions (Linux)
ls -la ~/.ssh/id_*

# Corriger si nécessaire
chmod 600 ~/.ssh/id_ed25519

# Vérifier que la clé publique est sur le serveur
ssh-copy-id -i ~/.ssh/id_ed25519.pub user@serveur

# Tester en mode verbeux
ssh -vvv -i ~/.ssh/id_ed25519 user@serveur
```

**Problème : "Invalid format" lors de la conversion** :

```bash
# Vérifier le format de la clé source
file ~/.ssh/id_rsa
head -1 ~/.ssh/id_rsa

# Essayer de régénérer la clé publique
ssh-keygen -y -f ~/.ssh/id_rsa > ~/.ssh/id_rsa.pub

# Convertir en format moderne si nécessaire
ssh-keygen -p -f ~/.ssh/id_rsa -m RFC4716
```

**Problème : Passphrase demandée à chaque fois** :

```bash
# Linux - Configurer ssh-agent
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Ajouter au démarrage (.bashrc)
if [ -z "$SSH_AUTH_SOCK" ]; then
    eval "$(ssh-agent -s)"
    ssh-add ~/.ssh/id_ed25519 2>/dev/null
fi

# Windows - Vérifier le service
Get-Service ssh-agent
Start-Service ssh-agent
ssh-add C:\Users\utilisateur\.ssh\id_ed25519
```

**Problème : PuTTY ne reconnaît pas la clé PPK** :

```bash
# Vérifier la version du format PPK
head -1 id_ed25519.ppk

# Si "PuTTY-User-Key-File-3", utiliser une version récente de PuTTY
# Ou convertir en PPK-2
puttygen id_ed25519.ppk --ppk-version 2 -o id_ed25519_v2.ppk
```

> [!warning] Versions incompatibles PuTTY 0.75+ utilise PPK-3 par défaut. Les anciennes versions de PuTTY ne peuvent pas lire ce format. Utilisez `--ppk-version 2` pour la compatibilité.

### 12. Checklist de déploiement multi-plateformes

Avant de déployer vos clés sur plusieurs systèmes, suivez cette checklist :

**Phase de préparation** :

- [ ] Générer la clé au format OpenSSH (Ed25519 recommandé)
- [ ] Définir une passphrase forte et la stocker de manière sécurisée
- [ ] Créer un backup chiffré de la clé
- [ ] Documenter l'usage prévu et les serveurs cibles

**Phase de conversion** :

- [ ] Convertir en PPK si nécessaire pour PuTTY
- [ ] Vérifier les empreintes (fingerprints) correspondent
- [ ] Tester la clé sur un serveur de test
- [ ] Valider la connexion depuis chaque plateforme

**Phase de déploiement** :

- [ ] Copier la clé publique sur les serveurs cibles
- [ ] Configurer les permissions correctes (600 pour privé, 644 pour public)
- [ ] Configurer `~/.ssh/config` avec les alias appropriés
- [ ] Ajouter les clés à l'agent SSH

**Phase de vérification** :

- [ ] Tester la connexion depuis Linux/macOS
- [ ] Tester la connexion depuis Windows (OpenSSH et/ou PuTTY)
- [ ] Vérifier que l'agent SSH fonctionne correctement
- [ ] Documenter la configuration dans l'inventaire

**Phase de maintenance** :

- [ ] Planifier un renouvellement (ex: tous les 2 ans)
- [ ] Configurer des alertes d'expiration si applicable
- [ ] Maintenir la synchronisation entre plateformes
- [ ] Auditer régulièrement l'accès et les permissions

### 13. Considérations de sécurité avancées

**Rotation des clés** :

```bash
# Script de rotation de clé
#!/bin/bash
OLD_KEY="$HOME/.ssh/id_ed25519"
NEW_KEY="$HOME/.ssh/id_ed25519_new"
BACKUP="$HOME/Backups/ssh_rotation_$(date +%Y%m%d)"

mkdir -p "$BACKUP"

# 1. Créer nouvelle clé
ssh-keygen -t ed25519 -f "$NEW_KEY" -C "Rotation $(date +%Y-%m-%d)"

# 2. Déployer sur les serveurs
for server in $(grep "^Host " ~/.ssh/config | awk '{print $2}'); do
    echo "Déploiement sur $server..."
    ssh-copy-id -i "$NEW_KEY.pub" "$server"
done

# 3. Tester la nouvelle clé
echo "Test de connexion avec nouvelle clé..."
ssh -i "$NEW_KEY" premier_serveur "echo 'Test OK'"

# 4. Sauvegarder l'ancienne clé
cp "$OLD_KEY"* "$BACKUP/"

# 5. Remplacer l'ancienne clé
mv "$NEW_KEY" "$OLD_KEY"
mv "$NEW_KEY.pub" "$OLD_KEY.pub"

# 6. Reconvertir en PPK si nécessaire
puttygen "$OLD_KEY" -o "$OLD_KEY.ppk"

echo "Rotation terminée. Ancienne clé sauvegardée dans $BACKUP"
```

**Clés avec expiration (certificats SSH)** :

```bash
# Créer un certificat SSH avec expiration
# Note: nécessite une CA SSH configurée

# Signer une clé avec expiration (30 jours)
ssh-keygen -s ca_key -I "user_cert" -n user -V +30d ~/.ssh/id_ed25519.pub

# Vérifier le certificat
ssh-keygen -L -f ~/.ssh/id_ed25519-cert.pub
```

**Audit des clés déployées** :

```bash
#!/bin/bash
# audit_deployed_keys.sh

echo "=== Audit des clés SSH déployées ==="

# Lister les clés locales
echo -e "\n📁 Clés locales :"
for key in ~/.ssh/id_*.pub; do
    echo "$(basename $key):"
    ssh-keygen -l -f "$key"
done

# Vérifier sur les serveurs
echo -e "\n🌐 Clés déployées sur les serveurs :"
for server in prod-web prod-db backup; do
    echo -e "\n$server:"
    ssh "$server" "cat ~/.ssh/authorized_keys | ssh-keygen -l -f -" 2>/dev/null || echo "  Erreur de connexion"
done
```

---

## 📌 Récapitulatif

> [!info] Points clés à retenir
> 
> - **Format standard** : Utilisez OpenSSH comme format principal, convertissez en PPK uniquement si nécessaire
> - **Outils essentiels** : PuTTYgen pour les conversions, ssh-keygen pour la gestion native
> - **Organisation** : Maintenez une structure cohérente et documentée de vos clés
> - **Permissions** : Toujours 600 pour les clés privées, 644 pour les publiques
> - **Sauvegarde** : Backups réguliers et chiffrés de vos clés
> - **Test** : Vérifiez systématiquement après chaque conversion ou déploiement

### Commandes essentielles

```bash
# Conversion OpenSSH → PPK
puttygen id_ed25519 -o id_ed25519.ppk

# Conversion PPK → OpenSSH
puttygen id_ed25519.ppk -O private-openssh -o id_ed25519

# Vérifier une clé
ssh-keygen -l -f id_ed25519.pub
puttygen id_ed25519.ppk -l

# Corriger les permissions
chmod 600 ~/.ssh/id_*
chmod 644 ~/.ssh/*.pub

# Tester une connexion
ssh -vvv -i ~/.ssh/id_ed25519 user@serveur
```

### Workflow recommandé

1. **Génération** : Créer la clé au format OpenSSH (Ed25519)
2. **Documentation** : Enregistrer dans l'inventaire des clés
3. **Conversion** : Créer une version PPK si nécessaire
4. **Déploiement** : Copier la clé publique sur les serveurs
5. **Configuration** : Configurer `~/.ssh/config` avec les alias
6. **Test** : Vérifier depuis toutes les plateformes
7. **Maintenance** : Synchroniser régulièrement et auditer

> [!tip] OpenSSH natif sur Windows Si vous utilisez Windows 10/11, privilégiez OpenSSH natif plutôt que PuTTY. Cela simplifie considérablement la gestion multi-plateformes en éliminant le besoin de conversions.

---

**Fin du cours - Gestion des clés SSH multi-plateformes** 🎓