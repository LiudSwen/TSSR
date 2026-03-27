
> [!info] 📌 Informations **Objectif :** Ajouter un nouveau disque dur, le partitionner, le formater et le monter automatiquement **Contexte :** Serveur ou poste de travail nécessitant plus d'espace de stockage **Durée :** 15-30 minutes **Risque :** 🔴 Élevé (risque de formater le mauvais disque)

---

## 🎯 Avant de Commencer

- [ ] Accès root ou sudo
- [ ] Disque physiquement installé et câbles connectés
- [ ] Machine redémarrée si disque ajouté à chaud
- [ ] Backup des données critiques effectué
- [ ] Note du disque à conserver (éviter confusion)

> [!warning] ⚠️ Points Critiques
> 
> - **CRITIQUE :** Vérifier 3 fois le nom du disque avant toute action (risque de formater le mauvais)
> - Ne JAMAIS travailler sur un disque monté
> - Toujours utiliser UUID dans /etc/fstab (pas /dev/sdX)
> - Avoir une session SSH de secours si travail à distance
> - Tester `mount -a` AVANT tout reboot

---

## 📋 Étapes de la Procédure

### Phase 1 : Identification du Disque

- [ ] Lister tous les disques avec `lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,MODEL`
- [ ] Identifier le nouveau disque (généralement /dev/sdb ou sdc, sans point de montage)
- [ ] Vérifier avec `fdisk -l` pour double confirmation
- [ ] Noter sur papier : nom du disque, taille, modèle
- [ ] Confirmer que c'est bien le disque vide (pas de partitions existantes)

### Phase 2 : Partitionnement

- [ ] Lancer `fdisk /dev/sdX` (remplacer sdX par ton disque)
- [ ] Créer nouvelle table GPT : taper `g` (ou `o` pour MBR si vieux PC)
- [ ] Créer nouvelle partition : taper `n`
- [ ] Accepter les valeurs par défaut (partition 1, tout l'espace)
- [ ] Écrire les changements : taper `w` (ATTENTION : vérifie le disque avant !)
- [ ] Vérifier que /dev/sdX1 apparaît dans `lsblk`

### Phase 3 : Formatage

- [ ] Formater en ext4 avec label : `mkfs.ext4 -L "NomDuDisque" /dev/sdX1`
- [ ] Vérifier le formatage avec `blkid /dev/sdX1`
- [ ] Noter l'UUID affiché (IMPORTANT pour fstab)

### Phase 4 : Test de Montage

- [ ] Créer le point de montage : `mkdir -p /mnt/mondisque`
- [ ] Monter temporairement : `mount /dev/sdX1 /mnt/mondisque`
- [ ] Vérifier avec `df -h | grep mondisque`
- [ ] Tester l'écriture : `touch /mnt/mondisque/test.txt`
- [ ] Supprimer le fichier test : `rm /mnt/mondisque/test.txt`

### Phase 5 : Permissions (Optionnel)

- [ ] Changer propriétaire : `chown utilisateur:utilisateur /mnt/mondisque`
- [ ] OU créer groupe partagé si multi-utilisateurs
- [ ] Vérifier avec `ls -ld /mnt/mondisque`

### Phase 6 : Montage Automatique

- [ ] Sauvegarder fstab : `cp /etc/fstab /etc/fstab.backup.$(date +%Y%m%d)`
- [ ] Récupérer UUID : `blkid /dev/sdX1 | grep -o 'UUID="[^"]*"'`
- [ ] Ajouter ligne dans /etc/fstab : `UUID=xxx /mnt/mondisque ext4 defaults 0 2`
- [ ] Vérifier la syntaxe en relisant /etc/fstab
- [ ] Démonter : `umount /mnt/mondisque`
- [ ] **CRITIQUE : Tester avec `mount -a`** (si erreur, corriger AVANT reboot)
- [ ] Vérifier que le disque est remonté : `df -h | grep mondisque`

### Phase 7 : Validation Post-Reboot

- [ ] Redémarrer : `reboot`
- [ ] Vérifier montage automatique : `df -h | grep mondisque`
- [ ] Vérifier avec `lsblk -f /dev/sdX`
- [ ] Tester lecture/écriture : créer et supprimer un fichier test
- [ ] Confirmer que tout fonctionne normalement

---

## ✅ Validation Finale

- [ ] Le disque est visible dans `lsblk` avec sa partition
- [ ] Partition formatée en ext4 (vérifiable avec `blkid`)
- [ ] Disque se monte automatiquement au boot (testé après reboot)
- [ ] Lecture ET écriture fonctionnent
- [ ] Permissions correctes (utilisateur peut accéder)
- [ ] /etc/fstab utilise UUID (pas /dev/sdX)
- [ ] Backup de /etc/fstab existe

---

## 📝 Commandes de Référence

**Identification**

```bash
lsblk -o NAME,SIZE,TYPE,MOUNTPOINT,MODEL,SERIAL  # Vue complète
fdisk -l                                          # Liste tous les disques
blkid                                             # UUID et types de systèmes
```

**Partitionnement**

```bash
# Méthode 1 : fdisk (STANDARD, recommandé)
fdisk /dev/sdX
  g              # Créer table GPT (ou 'o' pour MBR)
  n              # Nouvelle partition
  [Enter]        # Accepter partition number (1)
  [Enter]        # Accepter first sector (début)
  [Enter]        # Accepter last sector (fin = tout l'espace)
  w              # Écrire et quitter (VÉRIFIE LE DISQUE AVANT !)

# Méthode 2 : cfdisk (interface visuelle, plus simple)
cfdisk /dev/sdX
  # Sélectionner "gpt" si nouveau disque
  # [New] → [Enter] (accepter taille max)
  # [Write] → taper "yes" pour confirmer
  # [Quit]

# Méthode 3 : parted (moderne, moins courant)
parted /dev/sdX
  mklabel gpt
  mkpart primary ext4 0% 100%
  quit
```

**Formatage**

```bash
mkfs.ext4 -L "Label" /dev/sdX1   # Format ext4 avec label
mkfs.xfs /dev/sdX1               # Format XFS (alternative)
mkswap /dev/sdX1                 # Format swap
```

**Montage**

```bash
mount /dev/sdX1 /mnt/point       # Montage temporaire
umount /mnt/point                # Démontage
mount -a                         # Monte tout depuis fstab (TESTER avant reboot !)
```

**Vérification**

```bash
df -h                            # Espace disque utilisé
lsblk -f                         # Systèmes fichiers + UUID
findmnt                          # Arbre des montages
blkid /dev/sdX1                  # Infos partition spécifique
```

**Permissions**

```bash
chown utilisateur:utilisateur /mnt/point    # Changer propriétaire
chmod 755 /mnt/point                        # Permissions lecture/écriture
ls -ld /mnt/point                           # Vérifier permissions
```

---

## 🚨 Dépannage Rapide

### ❌ mount: wrong fs type

**Symptôme :** Erreur lors du montage **Solution :** Vérifier avec `blkid /dev/sdX1` que la partition est bien formatée, sinon reformater avec `mkfs.ext4 /dev/sdX1`

### ❌ mount -a génère une erreur

**Symptôme :** Erreur "can't find UUID" ou "bad option" **Solution :** Vérifier UUID dans /etc/fstab (sans guillemets), corriger syntaxe, pas d'espace en trop

### ❌ Permission denied lors écriture

**Symptôme :** Impossible créer fichiers en utilisateur normal **Solution :** `chown $USER:$USER /mnt/point` puis `chmod 755 /mnt/point`

### ❌ Système ne boot plus

**Symptôme :** Écran "emergency mode" au démarrage **Solution :** En mode recovery : `mount -o remount,rw /` puis `cp /etc/fstab.backup.XXXXX /etc/fstab` puis `reboot`

### ❌ Disque non détecté

**Symptôme :** lsblk ne montre pas le nouveau disque **Solution :** Rescanner : `echo "- - -" | sudo tee /sys/class/scsi_host/host*/scan` puis vérifier connexions physiques

---

## 🔙 Rollback (Annulation)

Si la procédure échoue :

- [ ] Démonter le disque : `umount /mnt/mondisque`
- [ ] Retirer ligne de /etc/fstab (éditer avec nano/vim)
- [ ] Restaurer backup : `cp /etc/fstab.backup.XXXXXXXX /etc/fstab`
- [ ] Tester : `mount -a` doit fonctionner sans erreur
- [ ] Redémarrer pour confirmer : `reboot`

> [!danger] Si système ne boot plus Booter sur live USB → monter partition racine → restaurer /etc/fstab → reboot

---

## 🏷️ Tags

```
#checklist #TSSR #linux #stockage #disque #partitionnement
Risque: élevé
Systèmes: Ubuntu, Debian, CentOS, RHEL, Fedora
Dernière MAJ: 23/11/2024
```