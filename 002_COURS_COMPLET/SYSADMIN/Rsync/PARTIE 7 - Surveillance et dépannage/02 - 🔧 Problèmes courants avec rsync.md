

---

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

## 🔐 Erreurs de permissions

### Symptômes courants

```bash
rsync: failed to set times on "/backup/fichier.txt": Operation not permitted (1)
rsync: chown "/backup/fichier.txt" failed: Operation not permitted (1)
rsync: recv_generator: mkdir "/backup/dossier" failed: Permission denied (13)
```

### Causes et solutions

#### 1. Permissions insuffisantes sur la destination

**Problème :** L'utilisateur exécutant rsync n'a pas les droits en écriture sur le répertoire de destination.

```bash
# Vérifier les permissions
ls -ld /chemin/destination

# Solution : Ajuster les permissions
sudo chown -R utilisateur:groupe /chemin/destination
# ou
sudo chmod u+w /chemin/destination
```

#### 2. Tentative de préservation du propriétaire sans privilèges root

**Problème :** L'option `-o` (preserve owner) nécessite les privilèges root.

```bash
# ❌ Échouera pour un utilisateur normal
rsync -ao source/ destination/

# ✅ Solution 1 : Retirer l'option -o
rsync -rlptgD source/ destination/

# ✅ Solution 2 : Utiliser sudo
sudo rsync -ao source/ destination/

# ✅ Solution 3 : Utiliser --no-o avec -a
rsync -a --no-o source/ destination/
```

> [!tip] Astuce
> L'option `-a` inclut `-o`. Si vous n'avez pas besoin de préserver le propriétaire, utilisez `-rlptgD` à la place de `-a`, ou ajoutez `--no-o`.

#### 3. Permissions restrictives sur les fichiers sources

**Problème :** Les fichiers sources ne sont pas lisibles par l'utilisateur.

```bash
# Vérifier les permissions en lecture
ls -la /chemin/source

# Solution temporaire : Utiliser sudo pour la lecture
sudo rsync -av source/ destination/

# Solution permanente : Ajuster les ACL ou permissions
sudo chmod -R +r /chemin/source
```

> [!warning] Attention
> Modifier les permissions source peut avoir des implications de sécurité. Évaluez toujours l'impact avant d'exécuter des modifications globales.

#### 4. Problèmes de montage en lecture seule

```bash
# Vérifier si le système de fichiers est en lecture seule
mount | grep destination

# Si read-only, remonter en lecture-écriture
sudo mount -o remount,rw /point/montage
```

---

## 🔑 Problèmes SSH

### Symptômes courants

```bash
ssh: connect to host serveur.com port 22: Connection refused
Permission denied (publickey,password)
Host key verification failed
rsync: connection unexpectedly closed (0 bytes received so far)
```

### Causes et solutions

#### 1. Service SSH non démarré ou inaccessible

**Problème :** Le serveur SSH distant n'est pas actif ou accessible.

```bash
# Tester la connexion SSH manuellement
ssh utilisateur@serveur.com

# Vérifier le statut SSH sur le serveur distant
sudo systemctl status sshd    # ou ssh selon la distribution

# Démarrer SSH si nécessaire
sudo systemctl start sshd
sudo systemctl enable sshd
```

#### 2. Port SSH personnalisé non spécifié

**Problème :** Le serveur SSH écoute sur un port différent de 22.

```bash
# ❌ Échouera si SSH est sur le port 2222
rsync -av source/ user@serveur:/destination/

# ✅ Solution : Spécifier le port avec -e
rsync -av -e "ssh -p 2222" source/ user@serveur:/destination/

# Alternative avec variable
export RSYNC_RSH="ssh -p 2222"
rsync -av source/ user@serveur:/destination/
```

> [!example] Exemple de configuration permanente
> Créez un alias dans `~/.ssh/config` :
> ```
> Host monserveur
>     HostName serveur.com
>     Port 2222
>     User utilisateur
> ```
> Puis utilisez : `rsync -av source/ monserveur:/destination/`

#### 3. Problèmes d'authentification par clé

**Problème :** La clé SSH n'est pas acceptée ou mal configurée.

```bash
# Vérifier les permissions de la clé privée (doivent être 600)
ls -l ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa

# Vérifier que la clé publique est dans authorized_keys
ssh user@serveur "cat ~/.ssh/authorized_keys"

# Tester la connexion avec verbose pour diagnostiquer
ssh -v user@serveur

# Spécifier une clé spécifique avec rsync
rsync -av -e "ssh -i ~/.ssh/ma_cle_privee" source/ user@serveur:/dest/
```

#### 4. Vérification de l'empreinte de l'hôte

**Problème :** L'empreinte du serveur a changé ou est inconnue.

```bash
# Message d'erreur typique
# Host key verification failed

# Solution 1 : Accepter manuellement via SSH d'abord
ssh user@serveur

# Solution 2 : Supprimer l'ancienne empreinte
ssh-keygen -R serveur.com

# Solution 3 : Désactiver la vérification (NON RECOMMANDÉ en production)
rsync -av -e "ssh -o StrictHostKeyChecking=no" source/ user@serveur:/dest/
```

> [!warning] Sécurité
> Ne désactivez jamais `StrictHostKeyChecking` en production. Cela expose à des attaques de type man-in-the-middle.

#### 5. Timeout de connexion

**Problème :** La connexion SSH expire avant que rsync ne démarre.

```bash
# Augmenter le timeout SSH
rsync -av -e "ssh -o ConnectTimeout=60" source/ user@serveur:/dest/

# Ajouter des options de keep-alive
rsync -av -e "ssh -o ServerAliveInterval=60 -o ServerAliveCountMax=3" \
  source/ user@serveur:/dest/
```

#### 6. Firewall bloquant le trafic SSH

```bash
# Vérifier les règles de firewall sur le serveur distant
sudo iptables -L -n | grep 22

# Autoriser SSH si nécessaire (exemple avec ufw)
sudo ufw allow 22/tcp

# Ou avec iptables
sudo iptables -A INPUT -p tcp --dport 22 -j ACCEPT
sudo iptables-save
```

---

## 🌐 Erreurs réseau

### Symptômes courants

```bash
rsync: connection unexpectedly closed (XXX bytes received so far)
rsync error: error in rsync protocol data stream (code 12)
rsync: read error: Connection reset by peer (104)
rsync: writefd_unbuffered failed to write: Broken pipe (32)
```

### Causes et solutions

#### 1. Connexion instable ou interrompue

**Problème :** La connexion réseau est perdue pendant le transfert.

```bash
# Solution : Utiliser --partial pour reprendre les transferts interrompus
rsync -av --partial source/ user@serveur:/dest/

# Mieux : Combiner avec --append-verify pour les gros fichiers
rsync -av --partial --append-verify source/ user@serveur:/dest/

# Ou utiliser -P (équivaut à --partial --progress)
rsync -avP source/ user@serveur:/dest/
```

> [!tip] Astuce de reprise
> Créez un alias pour les transferts longue distance :
> ```bash
> alias rsync-resume='rsync -avP --partial --append-verify'
> ```

#### 2. Timeout réseau

**Problème :** Le transfert s'arrête sur de gros fichiers ou des connexions lentes.

```bash
# Augmenter le timeout
rsync -av --timeout=300 source/ user@serveur:/dest/

# Combiner avec des options de compression pour réduire le volume
rsync -avz --timeout=300 source/ user@serveur:/dest/

# Pour les connexions très lentes
rsync -avz --timeout=600 --bwlimit=1000 source/ user@serveur:/dest/
```

#### 3. Paquets trop volumineux

**Problème :** Le MTU du réseau est trop faible pour les paquets rsync.

```bash
# Vérifier le MTU actuel
ip link show | grep mtu

# Réduire la taille des paquets SSH
rsync -av -e "ssh -o 'IPQoS=throughput' -o 'Compression=yes'" \
  source/ user@serveur:/dest/
```

#### 4. Problèmes de DNS

**Problème :** Le nom d'hôte ne peut pas être résolu.

```bash
# Tester la résolution DNS
nslookup serveur.com
host serveur.com

# Solution temporaire : Utiliser l'adresse IP
rsync -av source/ user@192.168.1.100:/dest/

# Solution permanente : Ajouter dans /etc/hosts
echo "192.168.1.100 serveur.com" | sudo tee -a /etc/hosts
```

#### 5. Bande passante saturée

**Problème :** Le réseau est saturé, ralentissant ou bloquant rsync.

```bash
# Limiter la bande passante utilisée (en Ko/s)
rsync -av --bwlimit=5000 source/ user@serveur:/dest/

# Pour les transferts de nuit, retirer la limitation
rsync -av --bwlimit=0 source/ user@serveur:/dest/
```

> [!example] Script avec limitation horaire
> ```bash
> #!/bin/bash
> HEURE=$(date +%H)
> 
> if [ $HEURE -ge 9 ] && [ $HEURE -le 18 ]; then
>     # Heures de bureau : limiter à 1 Mo/s
>     BWLIMIT=1000
> else
>     # Hors heures : pas de limite
>     BWLIMIT=0
> fi
> 
> rsync -av --bwlimit=$BWLIMIT source/ user@serveur:/dest/
> ```

#### 6. Protocole rsync incompatible

**Problème :** Versions de rsync incompatibles entre client et serveur.

```bash
# Vérifier la version locale
rsync --version

# Vérifier la version distante
ssh user@serveur "rsync --version"

# Solution : Forcer un protocole compatible
rsync -av --protocol=30 source/ user@serveur:/dest/

# Ou mettre à jour rsync sur l'une des machines
sudo apt update && sudo apt install rsync
```

---

## 💾 Espace disque insuffisant

### Symptômes courants

```bash
rsync: write failed on "/destination/fichier": No space left on device (28)
rsync error: error in file IO (code 11)
rsync: rename "/destination/.fichier.XXXXXX" -> "fichier": No space left on device (28)
```

### Causes et solutions

#### 1. Partition de destination pleine

**Problème :** Il n'y a plus d'espace disponible sur la destination.

```bash
# Vérifier l'espace disponible
df -h /destination

# Identifier les gros fichiers
du -sh /destination/* | sort -rh | head -10

# Solutions possibles :
# 1. Nettoyer les fichiers temporaires
sudo find /destination -type f -name "*.tmp" -delete
sudo find /destination -type f -name ".~tmp~*" -delete

# 2. Supprimer les anciennes sauvegardes
# (faire preuve de prudence !)
rm -rf /destination/backup-old-*

# 3. Utiliser --max-size pour limiter la taille des fichiers
rsync -av --max-size=100M source/ /destination/
```

> [!warning] Fichiers temporaires rsync
> rsync crée des fichiers temporaires pendant le transfert. Assurez-vous d'avoir au moins autant d'espace libre que la taille du plus gros fichier à transférer.

#### 2. Inodes épuisés

**Problème :** Le système de fichiers n'a plus d'inodes disponibles (même si de l'espace disque reste).

```bash
# Vérifier l'utilisation des inodes
df -i /destination

# Si les inodes sont à 100%, identifier les répertoires problématiques
sudo find /destination -xdev -type d -exec sh -c \
  'echo "$(find "{}" -maxdepth 1 | wc -l) {}"' \; | sort -rn | head -20

# Solution : Supprimer les nombreux petits fichiers inutiles
# Exemple : fichiers cache, logs anciens, etc.
sudo find /destination/cache -type f -delete
```

> [!info] Comprendre les inodes
> Chaque fichier et répertoire consomme un inode. Des millions de petits fichiers peuvent épuiser les inodes avant l'espace disque.

#### 3. Quotas utilisateur atteints

**Problème :** L'utilisateur a atteint son quota de disque.

```bash
# Vérifier les quotas
quota -v

# Voir les détails
repquota -a

# Solution : Contacter l'administrateur pour augmenter le quota
# ou nettoyer les fichiers de l'utilisateur
du -sh ~/* | sort -rh | head -10
```

#### 4. Systèmes de fichiers en lecture seule par sécurité

**Problème :** Le système de fichiers est passé en lecture seule suite à des erreurs.

```bash
# Vérifier le statut
mount | grep destination

# Vérifier les erreurs système
dmesg | tail -50
sudo journalctl -xe | grep -i error

# Solution : Vérifier et réparer le système de fichiers
# (nécessite un démontage)
sudo umount /destination
sudo fsck -y /dev/sdX
sudo mount /destination
```

#### 5. Estimation incorrecte de l'espace nécessaire

**Problème :** L'espace requis a été sous-estimé.

```bash
# Estimer l'espace nécessaire AVANT de lancer rsync
rsync -av --dry-run --stats source/ /destination/ | grep "Total file size"

# Comparer avec l'espace disponible
df -h /destination

# Alternative : Utiliser du pour estimer
du -sh source/
```

> [!tip] Bonnes pratiques
> ```bash
> # Script de vérification avant sauvegarde
> #!/bin/bash
> 
> SOURCE_SIZE=$(du -sb /source | cut -f1)
> DEST_AVAIL=$(df -B1 /destination | tail -1 | awk '{print $4}')
> MARGE=1.2  # 20% de marge
> 
> ESPACE_REQUIS=$(echo "$SOURCE_SIZE * $MARGE" | bc | cut -d. -f1)
> 
> if [ $DEST_AVAIL -lt $ESPACE_REQUIS ]; then
>     echo "❌ Espace insuffisant !"
>     echo "Requis : $(numfmt --to=iec $ESPACE_REQUIS)"
>     echo "Disponible : $(numfmt --to=iec $DEST_AVAIL)"
>     exit 1
> fi
> 
> rsync -av source/ /destination/
> ```

#### 6. Fichiers sparse non gérés correctement

**Problème :** Les fichiers sparse (fichiers creux) occupent plus d'espace que prévu.

```bash
# Vérifier si un fichier est sparse
ls -lh fichier   # Taille apparente
du -h fichier    # Taille réelle sur disque

# Préserver la nature sparse avec rsync
rsync -av --sparse source/ /destination/

# Identifier les fichiers sparse
find /source -type f -exec sh -c \
  'test $(stat -c%s "{}") -gt $(stat -c%b "{}" | awk "{print \$1*512}") && echo "{}"' \;
```

---

## 🔍 Diagnostic général

### Méthodologie de dépannage

```bash
# 1. Lancer rsync en mode verbose pour voir l'erreur exacte
rsync -vv source/ destination/

# 2. Tester avec --dry-run pour simuler sans modifier
rsync -av --dry-run source/ destination/

# 3. Vérifier les logs système
sudo journalctl -u rsync -n 50
dmesg | grep rsync

# 4. Utiliser strace pour un diagnostic approfondi (cas extrêmes)
strace -o /tmp/rsync.log rsync -av source/ destination/
```

> [!tip] Checklist de dépannage
> Lorsque rsync échoue, vérifiez dans l'ordre :
> 
> 1. ✅ Les permissions (lecture source, écriture destination)
> 2. ✅ La connectivité réseau/SSH (si distant)
> 3. ✅ L'espace disque et les inodes disponibles
> 4. ✅ La syntaxe de la commande (slash final, chemins)
> 5. ✅ Les versions de rsync compatibles
> 6. ✅ Les logs système pour erreurs matérielles

---

## 📊 Codes de sortie rsync

rsync retourne des codes d'erreur spécifiques pour faciliter le diagnostic dans les scripts :

| Code | Signification |
|------|---------------|
| 0    | Succès |
| 1    | Erreur de syntaxe ou d'usage |
| 2    | Incompatibilité de protocole |
| 3    | Erreurs lors de la sélection des fichiers |
| 4    | Action non supportée |
| 5    | Erreur au démarrage du protocole rsync |
| 10   | Erreur d'I/O socket |
| 11   | Erreur d'I/O fichier |
| 12   | Erreur dans le flux de données du protocole |
| 13   | Erreurs dans les diagnostics du programme |
| 14   | Erreur dans le code IPC |
| 20   | Signal reçu (SIGUSR1, SIGINT) |
| 21   | Erreur dans l'allocation de buffer |
| 22   | Erreur à l'ouverture/lecture/écriture/fermeture |
| 23   | Erreur de transfert partiel |
| 24   | Fichiers partiellement transférés disparus |
| 25   | Limite de --max-delete atteinte |
| 30   | Timeout d'I/O |
| 35   | Timeout en attente de connexion |

```bash
# Utiliser le code de sortie dans un script
rsync -av source/ destination/
CODE_RETOUR=$?

if [ $CODE_RETOUR -eq 0 ]; then
    echo "✅ Synchronisation réussie"
elif [ $CODE_RETOUR -eq 23 ]; then
    echo "⚠️  Transfert partiel - certains fichiers n'ont pas pu être transférés"
elif [ $CODE_RETOUR -eq 24 ]; then
    echo "❌ Fichiers disparus pendant le transfert"
else
    echo "❌ Erreur rsync - Code : $CODE_RETOUR"
fi
```

---

> [!warning] Rappel important
> Face à un problème récurrent, ne multipliez pas les tentatives sans analyse. Utilisez `--dry-run` et `-vv` pour comprendre ce qui se passe avant de forcer une solution qui pourrait aggraver la situation.