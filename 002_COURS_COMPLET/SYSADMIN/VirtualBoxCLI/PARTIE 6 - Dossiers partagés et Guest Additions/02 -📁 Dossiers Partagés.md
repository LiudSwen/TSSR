

## 📚 Table des matières

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

## 🎯 Introduction aux dossiers partagés

Les **dossiers partagés** (shared folders) permettent l'échange de fichiers entre le système hôte et les machines virtuelles. C'est un mécanisme bidirectionnel qui évite d'utiliser le réseau ou des supports amovibles pour transférer des données.

> [!info] Pourquoi utiliser les dossiers partagés ?
> 
> - Échange rapide et transparent de fichiers entre hôte et guest
> - Pas besoin de configuration réseau complexe
> - Idéal pour le développement (code sur l'hôte, exécution dans la VM)
> - Alternative performante au copier-coller ou aux transferts réseau

> [!warning] Prérequis Les **Guest Additions** doivent être installées sur la VM pour que les dossiers partagés fonctionnent correctement. Sans elles, les partages ne seront pas accessibles dans le système guest.

---

## ➕ Création de dossiers partagés

### Commande `sharedfolder add`

La commande `VBoxManage sharedfolder add` permet de créer un nouveau dossier partagé.

#### Syntaxe de base

```bash
VBoxManage sharedfolder add <vm-name|uuid> \
  --name <nom_partage> \
  --hostpath <chemin_hôte> \
  [options]
```

#### Paramètres obligatoires

|Paramètre|Description|
|---|---|
|`<vm-name\|uuid>`|Nom ou UUID de la machine virtuelle|
|`--name`|Nom du partage (tel qu'il apparaîtra dans la VM)|
|`--hostpath`|Chemin absolu du dossier sur le système hôte|

> [!example] Exemple simple
> 
> ```bash
> # Partager le dossier /home/user/projets avec la VM "Ubuntu-Dev"
> VBoxManage sharedfolder add "Ubuntu-Dev" \
>   --name "Projets" \
>   --hostpath "/home/user/projets"
> ```

#### Avec options avancées

```bash
# Exemple complet avec toutes les options
VBoxManage sharedfolder add "MaVM" \
  --name "Documents" \
  --hostpath "/home/user/documents" \
  --readonly \
  --automount \
  --auto-mount-point "/mnt/documents"
```

> [!tip] Convention de nommage
> 
> - Utilisez des noms courts et descriptifs pour `--name`
> - Évitez les espaces et caractères spéciaux
> - Préférez une convention cohérente (ex: PascalCase ou snake_case)

---

## ⚙️ Options des dossiers partagés

### Option `--transient`

Le mode **transient** (temporaire) crée un partage qui n'existe que pendant la session en cours de la VM.

```bash
VBoxManage sharedfolder add "MaVM" \
  --name "TempShare" \
  --hostpath "/tmp/partage" \
  --transient
```

|Caractéristique|Permanent (défaut)|Transient|
|---|---|---|
|Persistance|Survit au redémarrage|Disparaît à l'arrêt de la VM|
|Configuration|Sauvegardée dans le fichier .vbox|En mémoire uniquement|
|Usage|Partages de développement|Tests, partages temporaires|

> [!info] Quand utiliser `--transient` ?
> 
> - Pour des tests rapides sans modifier la configuration permanente
> - Pour des partages ponctuels (transfert unique de fichiers)
> - Dans des scripts qui créent/détruisent des partages dynamiquement

### Option `--readonly`

Le mode **lecture seule** empêche toute modification des fichiers depuis la VM.

```bash
VBoxManage sharedfolder add "MaVM" \
  --name "DocsLecture" \
  --hostpath "/home/user/documentation" \
  --readonly
```

> [!warning] Sécurité Utilisez `--readonly` pour :
> 
> - Protéger des fichiers importants contre les modifications accidentelles
> - Partager des ressources sans risque (ISOs, documentation)
> - Respecter le principe du moindre privilège

### Option `--automount`

L'option **automount** monte automatiquement le dossier partagé au démarrage de la VM.

```bash
VBoxManage sharedfolder add "MaVM" \
  --name "AutoPartage" \
  --hostpath "/home/user/data" \
  --automount
```

> [!info] Comportement par système d'exploitation
> 
> - **Linux** : monte généralement dans `/media/sf_<nom_partage>`
> - **Windows** : assigne une lettre de lecteur automatiquement
> - **macOS** : accessible via le montage VBoxSF

#### Spécifier le point de montage

```bash
# Linux : spécifier où monter le partage
VBoxManage sharedfolder add "MaVM" \
  --name "Data" \
  --hostpath "/home/user/data" \
  --automount \
  --auto-mount-point "/mnt/data"
```

> [!tip] Bonne pratique Combinez `--automount` avec `--auto-mount-point` pour un contrôle total sur l'emplacement de montage, évitant ainsi les chemins génériques.

### Combinaison d'options

```bash
# Partage permanent, lecture seule, monté automatiquement
VBoxManage sharedfolder add "Production-VM" \
  --name "Config" \
  --hostpath "/etc/app-config" \
  --readonly \
  --automount \
  --auto-mount-point "/opt/config"

# Partage temporaire, lecture/écriture, montage manuel
VBoxManage sharedfolder add "Test-VM" \
  --name "TempData" \
  --hostpath "/tmp/test-data" \
  --transient
```

---

## ➖ Suppression de dossiers partagés

### Commande `sharedfolder remove`

Pour supprimer un dossier partagé existant :

```bash
VBoxManage sharedfolder remove <vm-name|uuid> \
  --name <nom_partage> \
  [--transient]
```

> [!example] Exemples de suppression
> 
> ```bash
> # Supprimer un partage permanent
> VBoxManage sharedfolder remove "MaVM" --name "Projets"
> 
> # Supprimer un partage transient
> VBoxManage sharedfolder remove "MaVM" --name "TempShare" --transient
> ```

> [!warning] Attention
> 
> - La suppression d'un partage permanent est définitive
> - Les partages transients disparaissent automatiquement à l'arrêt de la VM
> - Spécifiez `--transient` si vous voulez supprimer un partage temporaire pendant que la VM tourne

### Lister les partages existants

Avant de supprimer, vérifiez les partages configurés :

```bash
# Afficher tous les partages d'une VM
VBoxManage showvminfo "MaVM" | grep -i "shared folder"

# Ou utiliser la sortie complète
VBoxManage showvminfo "MaVM" --machinereadable | grep SharedFolder
```

---

## 🔧 Montage dans le système guest

Une fois les dossiers partagés créés, ils doivent être montés dans le système guest pour être accessibles.

### Montage sous Linux

#### Avec automount activé

Si `--automount` est utilisé, le partage est automatiquement disponible :

```bash
# Vérifier le montage automatique
ls /media/sf_<nom_partage>

# Exemple
ls /media/sf_Projets
```

> [!warning] Permissions Par défaut, seul le groupe `vboxsf` peut accéder aux montages automatiques. Ajoutez votre utilisateur à ce groupe :
> 
> ```bash
> sudo usermod -aG vboxsf $USER
> # Déconnexion/reconnexion nécessaire
> ```

#### Montage manuel

Pour les partages sans automount :

```bash
# Créer le point de montage
sudo mkdir -p /mnt/partage

# Monter le dossier partagé
sudo mount -t vboxsf <nom_partage> /mnt/partage

# Exemple
sudo mount -t vboxsf Projets /mnt/partage
```

#### Montage avec options

```bash
# Montage avec UID/GID spécifiques
sudo mount -t vboxsf -o uid=1000,gid=1000 Projets /mnt/partage

# Montage en lecture seule (double sécurité)
sudo mount -t vboxsf -o ro Projets /mnt/partage

# Avec permissions particulières
sudo mount -t vboxsf -o uid=1000,gid=1000,dmode=755,fmode=644 Projets /mnt/partage
```

|Option|Description|
|---|---|
|`uid=<id>`|Propriétaire des fichiers|
|`gid=<id>`|Groupe propriétaire|
|`dmode=<mode>`|Permissions des répertoires (ex: 755)|
|`fmode=<mode>`|Permissions des fichiers (ex: 644)|
|`ro`|Montage en lecture seule|

#### Montage permanent via `/etc/fstab`

Pour un montage automatique au démarrage du système :

```bash
# Éditer /etc/fstab
sudo nano /etc/fstab

# Ajouter la ligne suivante
<nom_partage>  /mnt/partage  vboxsf  uid=1000,gid=1000,dmode=755,fmode=644  0  0
```

> [!example] Exemple complet pour fstab
> 
> ```
> Projets  /home/user/projets  vboxsf  uid=1000,gid=1000,dmode=775,fmode=664,_netdev  0  0
> ```
> 
> L'option `_netdev` indique que c'est un système de fichiers réseau, retardant le montage si nécessaire.

### Montage sous Windows

#### Accès via l'Explorateur

Les dossiers partagés avec `--automount` apparaissent automatiquement :

- Dans "Ce PC" / "Poste de travail"
- Sous forme de lecteur réseau `\\vboxsrv\<nom_partage>`

#### Assignation de lettre de lecteur

```cmd
REM Via la ligne de commande Windows
net use Z: \\vboxsrv\Projets

REM Avec persistance au redémarrage
net use Z: \\vboxsrv\Projets /persistent:yes
```

#### Via PowerShell

```powershell
# Monter un dossier partagé
New-PSDrive -Name "Z" -PSProvider FileSystem -Root "\\vboxsrv\Projets" -Persist

# Vérifier les montages
Get-PSDrive
```

### Vérification du montage

```bash
# Linux : vérifier tous les montages VirtualBox
mount | grep vboxsf

# Afficher les détails
df -h | grep vboxsf

# Tester l'accès
ls -la /media/sf_Projets
```

---

## 🔐 Droits et permissions

Les permissions sur les dossiers partagés peuvent être sources de confusion car elles impliquent deux systèmes : l'hôte et le guest.

### Modèle de permissions

```
┌─────────────────┐
│  Système Hôte   │ ← Permissions réelles du système de fichiers
└────────┬────────┘
         │
    VirtualBox
    (Partage)
         │
┌────────┴────────┐
│  Système Guest  │ ← Permissions virtuelles (mapping)
└─────────────────┘
```

### Permissions sur l'hôte

Les permissions du système hôte sont **primordiales** :

```bash
# Sur l'hôte : donner les permissions appropriées
chmod 755 /home/user/partage
chown user:user /home/user/partage

# Pour un partage avec plusieurs utilisateurs
chmod 775 /home/user/partage
chown user:vboxusers /home/user/partage
```

> [!warning] Règle fondamentale VirtualBox **ne peut pas** donner plus de droits que ceux du système hôte. Si l'hôte refuse l'écriture, le guest ne pourra pas écrire, même sans `--readonly`.

### Permissions dans le guest (Linux)

#### Groupe vboxsf

Les dossiers partagés appartiennent au groupe `vboxsf` dans le guest :

```bash
# Ajouter l'utilisateur au groupe vboxsf
sudo usermod -aG vboxsf $USER

# Vérifier l'appartenance
groups $USER

# Vérifier les permissions du montage
ls -ld /media/sf_Projets
# drwxrwx--- 1 root vboxsf 4096 Dec 14 10:00 /media/sf_Projets
```

> [!tip] Astuce Après avoir ajouté un utilisateur au groupe `vboxsf`, une déconnexion/reconnexion est nécessaire pour que les changements prennent effet.

#### Mapper les permissions avec mount

```bash
# Monter avec l'utilisateur actuel comme propriétaire
sudo mount -t vboxsf -o uid=$(id -u),gid=$(id -g) Projets /mnt/partage

# Permissions spécifiques
sudo mount -t vboxsf -o uid=1000,gid=1000,dmode=755,fmode=644 Projets /mnt/partage
```

### Permissions dans le guest (Windows)

Sous Windows, les permissions sont généralement transparentes :

- Les dossiers partagés héritent des permissions du système hôte
- L'utilisateur Windows de la VM accède avec les droits de l'utilisateur hôte
- Pour un contrôle fin, utilisez les ACL Windows sur l'hôte

### Tableau récapitulatif des scénarios

|Scénario|Hôte|VBox|Guest|Résultat|
|---|---|---|---|---|
|Lecture seule totale|rwx|`--readonly`|Montage normal|Lecture seule|
|Lecture seule partielle|r-x|Pas d'option|Montage normal|Lecture seule|
|Lecture/écriture|rwx|Pas d'option|uid/gid correct|Lecture/écriture|
|Problème de droits|rwx|Pas d'option|Pas dans vboxsf|Permission denied|

### Diagnostic des problèmes de permissions

```bash
# 1. Vérifier les permissions sur l'hôte
# (sur le système hôte)
ls -ld /chemin/vers/partage

# 2. Vérifier le montage dans le guest
mount | grep vboxsf

# 3. Vérifier l'appartenance au groupe
groups $USER

# 4. Tester l'accès
touch /media/sf_Projets/test.txt
# Si erreur "Permission denied", vérifier les étapes précédentes

# 5. Vérifier les options de montage
cat /proc/mounts | grep vboxsf
```

---

## ⚠️ Pièges courants et bonnes pratiques

### Pièges courants

> [!warning] Guest Additions manquantes **Symptôme** : Les dossiers partagés n'apparaissent pas ou ne montent pas
> 
> **Solution** :
> 
> ```bash
> # Vérifier si Guest Additions sont installées (Linux)
> lsmod | grep vboxguest
> 
> # Si absent, installer depuis le menu VM → Insert Guest Additions CD
> sudo mount /dev/cdrom /mnt
> sudo /mnt/VBoxLinuxAdditions.run
> ```

> [!warning] Oubli du groupe vboxsf **Symptôme** : "Permission denied" malgré les bonnes permissions sur l'hôte
> 
> **Solution** :
> 
> ```bash
> sudo usermod -aG vboxsf $USER
> # Puis déconnexion/reconnexion
> ```

> [!warning] Chemin inexistant sur l'hôte **Symptôme** : Erreur lors de la création du partage
> 
> **Solution** : Créer le dossier sur l'hôte avant de partager
> 
> ```bash
> # Sur l'hôte
> mkdir -p /home/user/partage
> ```

> [!warning] VM en cours d'exécution **Symptôme** : Impossible de modifier un partage permanent
> 
> **Solution** : Les partages permanents ne peuvent être modifiés que VM éteinte. Utilisez `--transient` pour des modifications à chaud.

> [!warning] Conflits de cache **Symptôme** : Fichiers modifiés sur l'hôte non visibles dans le guest
> 
> **Solution** :
> 
> ```bash
> # Remonter le partage
> sudo umount /mnt/partage
> sudo mount -t vboxsf Projets /mnt/partage
> ```

### Bonnes pratiques

> [!tip] Organisation des partages
> 
> - Créez un partage par projet ou catégorie de données
> - Utilisez des noms de partages explicites et cohérents
> - Documentez vos partages (fichier README sur l'hôte)

> [!tip] Sécurité
> 
> - Utilisez `--readonly` pour les ressources en lecture seule
> - Ne partagez que les dossiers nécessaires
> - Évitez de partager la racine du système (/)
> - Vérifiez régulièrement `VBoxManage showvminfo` pour auditer les partages

> [!tip] Performance
> 
> - Les dossiers partagés sont plus lents que le stockage natif
> - Pour les opérations intensives, copiez les fichiers dans la VM
> - Évitez les partages avec des milliers de fichiers
> - Privilégiez les partages pour l'édition, pas l'exécution

> [!tip] Développement
> 
> ```bash
> # Structure recommandée pour le développement
> # Hôte : /home/user/dev/mon-projet
> # Guest : /home/user/workspace/mon-projet (monté)
> 
> VBoxManage sharedfolder add "Dev-VM" \
>   --name "MonProjet" \
>   --hostpath "/home/user/dev/mon-projet" \
>   --automount \
>   --auto-mount-point "/home/user/workspace/mon-projet"
> ```

> [!tip] Scripts d'automatisation
> 
> ```bash
> #!/bin/bash
> # setup-shares.sh - Créer tous les partages d'un projet
> 
> VM_NAME="Dev-VM"
> PROJECT_ROOT="/home/user/dev"
> 
> # Partage code (lecture/écriture)
> VBoxManage sharedfolder add "$VM_NAME" \
>   --name "Code" \
>   --hostpath "$PROJECT_ROOT/code" \
>   --automount
> 
> # Partage config (lecture seule)
> VBoxManage sharedfolder add "$VM_NAME" \
>   --name "Config" \
>   --hostpath "$PROJECT_ROOT/config" \
>   --readonly \
>   --automount
> 
> # Partage data (temporaire pour tests)
> VBoxManage sharedfolder add "$VM_NAME" \
>   --name "TestData" \
>   --hostpath "$PROJECT_ROOT/test-data" \
>   --transient
> ```

### Cas d'usage recommandés

|Usage|Configuration recommandée|
|---|---|
|Développement|Permanent, lecture/écriture, automount|
|Partage de documentation|Permanent, readonly, automount|
|Tests temporaires|Transient, lecture/écriture|
|Ressources statiques (ISOs)|Permanent, readonly|
|Logs|Permanent, lecture/écriture, sans automount|

---

## 🎓 Récapitulatif

Les dossiers partagés VirtualBox offrent une solution flexible pour l'échange de fichiers entre hôte et guest :

1. **Création** : `sharedfolder add` avec options (transient, readonly, automount)
2. **Suppression** : `sharedfolder remove` pour nettoyer les partages
3. **Montage** : Automatique ou manuel selon la configuration
4. **Permissions** : Contrôlées par l'hôte, mappées dans le guest via vboxsf

Les clés du succès : installer les Guest Additions, comprendre le modèle de permissions, et choisir les bonnes options selon le cas d'usage.