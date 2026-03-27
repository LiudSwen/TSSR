

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

## Introduction

Le nettoyage système est une tâche de maintenance essentielle pour :

- **Libérer de l'espace disque** : éviter la saturation du système
- **Optimiser les performances** : réduire la fragmentation et améliorer la réactivité
- **Maintenir la stabilité** : prévenir les problèmes liés au manque d'espace
- **Faciliter la maintenance** : avoir un système organisé et propre

> [!info] Quand nettoyer son système ?
> 
> - Après chaque mise à jour majeure
> - Lorsque l'espace disque devient limité
> - De manière régulière (mensuelle ou trimestrielle)
> - Avant des opérations critiques (sauvegardes, migrations)

---

## Nettoyage du cache APT

Le gestionnaire de paquets APT conserve les fichiers `.deb` téléchargés dans `/var/cache/apt/archives/`. Ces fichiers peuvent rapidement occuper plusieurs gigaoctets d'espace disque.

### apt clean

Supprime **tous** les fichiers de paquets téléchargés du cache.

```bash
# Vider complètement le cache APT
sudo apt clean
```

> [!example] Résultat
> 
> ```bash
> # Avant
> $ du -sh /var/cache/apt/archives/
> 2.3G    /var/cache/apt/archives/
> 
> # Après apt clean
> $ du -sh /var/cache/apt/archives/
> 32K     /var/cache/apt/archives/
> ```

**Caractéristiques** :

- Supprime **tous** les fichiers `.deb` (installés ou non)
- Ne conserve aucun paquet
- Récupère le maximum d'espace
- Action irréversible

> [!warning] Conséquence Si vous devez réinstaller un paquet, il sera re-téléchargé intégralement depuis les dépôts.

### apt autoclean

Supprime **uniquement** les fichiers de paquets obsolètes ou qui ne peuvent plus être téléchargés.

```bash
# Nettoyer uniquement les paquets obsolètes
sudo apt autoclean
```

**Caractéristiques** :

- Conserve les paquets des versions actuellement disponibles
- Supprime les anciennes versions de paquets
- Approche plus conservatrice que `clean`
- Permet de réinstaller rapidement les paquets actuels

> [!tip] Comparaison clean vs autoclean

|Commande|Supprime|Conserve|Gain d'espace|Usage recommandé|
|---|---|---|---|---|
|`apt clean`|Tout|Rien|Maximum|Manque d'espace critique|
|`apt autoclean`|Obsolètes|Versions actuelles|Modéré|Maintenance régulière|

**Exemple d'utilisation** :

```bash
# Vérifier l'espace utilisé
du -sh /var/cache/apt/archives/

# Nettoyer les paquets obsolètes
sudo apt autoclean

# Vérifier le gain
du -sh /var/cache/apt/archives/
```

---

## Suppression des paquets inutiles

### apt autoremove

Supprime automatiquement les paquets installés comme dépendances mais qui ne sont plus nécessaires.

```bash
# Supprimer les paquets devenus inutiles
sudo apt autoremove
```

> [!info] Qu'est-ce qu'un paquet inutile ? Lorsque vous installez un logiciel, APT installe également toutes ses dépendances. Si vous désinstallez le logiciel principal, ces dépendances restent installées. `autoremove` les détecte et les supprime.

**Exemple concret** :

```bash
# Installation d'un logiciel avec dépendances
$ sudo apt install gimp
# Installe gimp + 50 dépendances

# Désinstallation de gimp
$ sudo apt remove gimp
# gimp est supprimé, mais les 50 dépendances restent

# Les dépendances orphelines
$ apt list --installed | grep -i "automatically installed"
libbabl-0.1-0
libgegl-0.4-0
...

# Nettoyage automatique
$ sudo apt autoremove
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following packages will be REMOVED:
  libbabl-0.1-0 libgegl-0.4-0 libmypaint-1.5-1 ...
0 upgraded, 0 newly installed, 47 to remove and 0 not upgraded.
After this operation, 156 MB disk space will be freed.
```

**Options utiles** :

```bash
# Simulation (voir ce qui serait supprimé sans le faire)
sudo apt autoremove --dry-run

# Supprimer aussi les fichiers de configuration
sudo apt autoremove --purge

# Confirmer automatiquement
sudo apt autoremove -y
```

> [!warning] Pièges courants
> 
> - Vérifiez toujours la liste avant de confirmer
> - Certains paquets marqués comme "inutiles" peuvent être nécessaires à d'autres logiciels non-APT
> - Les paquets installés manuellement ne sont jamais supprimés par `autoremove`

> [!tip] Astuce : Marquer un paquet comme manuel Si `autoremove` veut supprimer un paquet que vous souhaitez conserver :
> 
> ```bash
> # Marquer comme installé manuellement
> sudo apt-mark manual nom-du-paquet
> 
> # Le paquet ne sera plus proposé à la suppression
> ```

**Commande combinée pour un nettoyage complet** :

```bash
# Nettoyage complet en une seule ligne
sudo apt update && sudo apt upgrade -y && sudo apt autoremove -y && sudo apt autoclean
```

---

## Nettoyage des logs système

Les logs système (journaux) sont gérés par `systemd-journald` et stockés dans `/var/log/journal/`. Ils peuvent rapidement grossir sur les systèmes actifs.

### journalctl --vacuum-time

Supprime les logs plus anciens qu'une durée spécifiée.

```bash
# Supprimer les logs de plus de 7 jours
sudo journalctl --vacuum-time=7d

# Supprimer les logs de plus de 2 semaines
sudo journalctl --vacuum-time=2weeks

# Supprimer les logs de plus de 3 mois
sudo journalctl --vacuum-time=3months

# Supprimer les logs de plus de 1 an
sudo journalctl --vacuum-time=1y
```

**Unités de temps acceptées** :

|Unité|Signification|Exemple|
|---|---|---|
|`s`|Secondes|`3600s`|
|`m`|Minutes|`30m`|
|`h`|Heures|`24h`|
|`d`|Jours|`7d`|
|`weeks`|Semaines|`2weeks`|
|`months`|Mois|`3months`|
|`y`|Années|`1y`|

> [!example] Résultat de la commande
> 
> ```bash
> $ sudo journalctl --vacuum-time=7d
> Deleted archived journal /var/log/journal/abc123.../system@00057e8f.journal (8.0M).
> Deleted archived journal /var/log/journal/abc123.../system@00057e90.journal (8.0M).
> Deleted archived journal /var/log/journal/abc123.../system@00057e91.journal (8.0M).
> Vacuuming done, freed 24.0M of archived journals from /var/log/journal/abc123...
> ```

### journalctl --vacuum-size

Limite la taille totale des logs à une valeur maximale.

```bash
# Limiter les logs à 500 Mo
sudo journalctl --vacuum-size=500M

# Limiter les logs à 1 Go
sudo journalctl --vacuum-size=1G

# Limiter les logs à 100 Mo
sudo journalctl --vacuum-size=100M
```

**Unités de taille acceptées** :

|Unité|Signification|Exemple|
|---|---|---|
|`K`|Kilooctets|`50000K`|
|`M`|Mégaoctets|`500M`|
|`G`|Gigaoctets|`2G`|

> [!info] Comment ça fonctionne ? `journalctl` supprime les journaux les plus anciens jusqu'à atteindre la taille cible. Les logs récents sont toujours conservés.

**Vérifier l'espace utilisé par les logs** :

```bash
# Voir la taille totale des logs
journalctl --disk-usage

# Exemple de sortie
$ journalctl --disk-usage
Archived and active journals take up 1.2G in the file system.
```

**Configuration permanente** :

Pour définir une limite permanente, éditez `/etc/systemd/journald.conf` :

```bash
sudo nano /etc/systemd/journald.conf
```

Ajoutez ou modifiez ces lignes :

```ini
[Journal]
# Limiter la taille totale
SystemMaxUse=500M

# Limiter la taille d'un fichier journal
SystemMaxFileSize=50M

# Conserver les logs de maximum 2 semaines
MaxRetentionSec=2week
```

Redémarrez le service :

```bash
sudo systemctl restart systemd-journald
```

> [!tip] Stratégie recommandée
> 
> - **Serveurs de production** : Conserver 1-3 mois de logs, limiter à 1-2 Go
> - **Postes de travail** : Conserver 1-2 semaines, limiter à 500M-1G
> - **Systèmes à espace limité** : Conserver 3-7 jours, limiter à 100-200M

**Combiner time et size** :

```bash
# Supprimer les logs de plus de 30 jours ET limiter à 500M
sudo journalctl --vacuum-time=30d --vacuum-size=500M
```

> [!warning] Attention aux logs critiques Ne supprimez pas tous les logs ! Ils sont essentiels pour :
> 
> - Diagnostiquer les problèmes
> - Analyser les incidents de sécurité
> - Comprendre les comportements anormaux
> 
> Conservez au minimum 7 jours de logs pour un dépannage efficace.

---

## Nettoyage de /tmp

Le répertoire `/tmp` contient les fichiers temporaires créés par les applications et le système. Ces fichiers devraient être automatiquement supprimés, mais ce n'est pas toujours le cas.

### Nettoyage automatique

Sur les systèmes modernes avec systemd, `/tmp` est souvent monté en `tmpfs` (RAM) et vidé automatiquement au redémarrage.

**Vérifier le type de montage** :

```bash
# Vérifier si /tmp est en tmpfs
df -h /tmp

# Ou
mount | grep /tmp
```

> [!example] Résultats possibles
> 
> ```bash
> # /tmp en tmpfs (vidé au redémarrage)
> $ df -h /tmp
> Filesystem      Size  Used Avail Use% Mounted on
> tmpfs           3.9G  156M  3.7G   4% /tmp
> 
> # /tmp sur disque (persistant)
> $ df -h /tmp
> Filesystem      Size  Used Avail Use% Mounted on
> /dev/sda1       50G   23G   25G  48% /
> ```

### Nettoyage manuel

**Supprimer les fichiers temporaires anciens** :

```bash
# Supprimer les fichiers de plus de 7 jours dans /tmp
sudo find /tmp -type f -atime +7 -delete

# Supprimer les fichiers de plus de 3 jours
sudo find /tmp -type f -atime +3 -delete

# Supprimer aussi les répertoires vides
sudo find /tmp -type d -empty -delete
```

**Détails de la commande** :

```bash
find /tmp              # Chercher dans /tmp
  -type f              # Seulement les fichiers (pas les répertoires)
  -atime +7            # Dernière utilisation > 7 jours
  -delete              # Supprimer
```

> [!warning] Attention avec -delete
> 
> - Testez d'abord sans `-delete` pour voir ce qui sera supprimé
> - Certaines applications peuvent avoir des fichiers locks importants dans /tmp
> - Ne supprimez jamais aveuglément tout le contenu de /tmp sur un système actif

**Version sécurisée avec preview** :

```bash
# Voir ce qui serait supprimé
sudo find /tmp -type f -atime +7 -ls

# Si le résultat est acceptable, alors supprimer
sudo find /tmp -type f -atime +7 -delete
```

### Configuration de tmpfiles.d

Systemd peut nettoyer automatiquement `/tmp` via `systemd-tmpfiles`.

**Vérifier la configuration** :

```bash
# Voir les règles de nettoyage
cat /usr/lib/tmpfiles.d/tmp.conf
```

> [!example] Contenu typique
> 
> ```
> # /tmp nettoyé après 10 jours
> d /tmp 1777 root root 10d
> 
> # /var/tmp nettoyé après 30 jours
> d /var/tmp 1777 root root 30d
> ```

**Créer une règle personnalisée** :

```bash
# Créer une configuration personnalisée
sudo nano /etc/tmpfiles.d/tmp-custom.conf
```

Contenu :

```ini
# Nettoyer /tmp après 3 jours
d /tmp 1777 root root 3d

# Nettoyer /var/tmp après 7 jours
d /var/tmp 1777 root root 7d
```

**Appliquer manuellement les règles** :

```bash
# Nettoyer selon les règles tmpfiles.d
sudo systemd-tmpfiles --clean
```

### Différence entre /tmp et /var/tmp

|Répertoire|Usage|Durée de vie|Survit au redémarrage|
|---|---|---|---|
|`/tmp`|Fichiers très temporaires|Court terme (heures/jours)|Non (si tmpfs)|
|`/var/tmp`|Fichiers temporaires persistants|Moyen terme (jours/semaines)|Oui|

> [!tip] Bonnes pratiques
> 
> - Ne stockez jamais de données importantes dans /tmp
> - Les applications doivent gérer elles-mêmes leurs fichiers temporaires
> - Utilisez `/var/tmp` pour les fichiers temporaires qui doivent survivre à un redémarrage
> - Surveillez régulièrement l'utilisation de /tmp avec `du -sh /tmp`

**Nettoyage complet et sécurisé** :

```bash
# Script de nettoyage complet de /tmp
#!/bin/bash

echo "=== Analyse de /tmp ==="
du -sh /tmp
echo ""

echo "=== Fichiers de plus de 7 jours ==="
find /tmp -type f -atime +7 -ls | head -20
echo ""

read -p "Supprimer ces fichiers ? (y/N) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    sudo find /tmp -type f -atime +7 -delete
    sudo find /tmp -type d -empty -delete
    echo "Nettoyage effectué"
    du -sh /tmp
else
    echo "Annulé"
fi
```

---

## Stratégie de nettoyage

### Script de nettoyage complet

Voici un script combinant toutes les techniques de nettoyage :

```bash
#!/bin/bash
# Script de nettoyage système complet

echo "======================================"
echo "  Nettoyage système Linux"
echo "======================================"
echo ""

# Afficher l'espace disque avant
echo "=== Espace disque AVANT nettoyage ==="
df -h / /home /var
echo ""

# Mise à jour des listes de paquets
echo "=== Mise à jour des listes de paquets ==="
sudo apt update
echo ""

# Suppression des paquets inutiles
echo "=== Suppression des paquets inutiles ==="
sudo apt autoremove -y
echo ""

# Nettoyage du cache APT
echo "=== Nettoyage du cache APT ==="
sudo apt autoclean
echo ""

# Nettoyage des logs (garder 2 semaines ou max 500M)
echo "=== Nettoyage des logs système ==="
echo "Espace utilisé par les logs :"
journalctl --disk-usage
sudo journalctl --vacuum-time=2weeks --vacuum-size=500M
echo "Après nettoyage :"
journalctl --disk-usage
echo ""

# Nettoyage de /tmp (fichiers de plus de 7 jours)
echo "=== Nettoyage de /tmp ==="
echo "Espace utilisé par /tmp :"
du -sh /tmp
sudo find /tmp -type f -atime +7 -delete 2>/dev/null
sudo find /tmp -type d -empty -delete 2>/dev/null
echo "Après nettoyage :"
du -sh /tmp
echo ""

# Afficher l'espace disque après
echo "=== Espace disque APRÈS nettoyage ==="
df -h / /home /var
echo ""

echo "======================================"
echo "  Nettoyage terminé !"
echo "======================================"
```

**Utilisation** :

```bash
# Rendre le script exécutable
chmod +x nettoyage-systeme.sh

# Exécuter
./nettoyage-systeme.sh
```

### Automatisation avec cron

Pour exécuter ce nettoyage automatiquement chaque semaine :

```bash
# Éditer la crontab root
sudo crontab -e
```

Ajouter cette ligne :

```cron
# Nettoyage système chaque dimanche à 3h du matin
0 3 * * 0 /chemin/vers/nettoyage-systeme.sh >> /var/log/nettoyage-systeme.log 2>&1
```

### Tableau récapitulatif des commandes

|Commande|Cible|Gain typique|Fréquence recommandée|
|---|---|---|---|
|`apt clean`|Cache APT complet|1-3 GB|Quand l'espace manque|
|`apt autoclean`|Cache APT obsolète|500MB-1GB|Mensuelle|
|`apt autoremove`|Paquets inutiles|100-500MB|Après chaque désinstallation|
|`journalctl --vacuum-time=2w`|Logs anciens|200MB-1GB|Hebdomadaire|
|`journalctl --vacuum-size=500M`|Logs volumineux|Variable|Mensuelle|
|`find /tmp -atime +7 -delete`|Fichiers temporaires|100-500MB|Hebdomadaire|

> [!tip] Ordre de priorité pour libérer de l'espace rapidement
> 
> 1. `apt clean` (gain immédiat et important)
> 2. `journalctl --vacuum-size=500M` (souvent négligé)
> 3. `apt autoremove` (nettoyage ciblé)
> 4. Nettoyage de /tmp (gain variable)

### Surveillance de l'espace disque

**Surveiller les répertoires gourmands** :

```bash
# Trouver les 10 plus gros répertoires
sudo du -h / --max-depth=1 2>/dev/null | sort -hr | head -10

# Analyser un répertoire spécifique en détail
sudo ncdu /var
```

**Configurer des alertes** :

```bash
# Script d'alerte espace disque
#!/bin/bash
THRESHOLD=80
USAGE=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')

if [ $USAGE -gt $THRESHOLD ]; then
    echo "Alerte : Disque / utilisé à ${USAGE}%" | mail -s "Alerte espace disque" admin@example.com
fi
```

> [!warning] Points d'attention
> 
> - Ne nettoyez jamais pendant qu'un système est en cours de mise à jour
> - Conservez toujours au minimum 10-15% d'espace libre pour le bon fonctionnement
> - Testez vos scripts sur un système de test avant la production
> - Documentez vos actions de nettoyage pour traçabilité

---

## 🎯 Récapitulatif

Le nettoyage système Linux repose sur quatre axes principaux :

1. **Cache APT** : `apt clean` / `apt autoclean` pour libérer l'espace des paquets téléchargés
2. **Paquets orphelins** : `apt autoremove` pour supprimer les dépendances inutiles
3. **Logs système** : `journalctl --vacuum-*` pour gérer la taille et l'ancienneté des journaux
4. **Fichiers temporaires** : Nettoyage de `/tmp` avec `find` ou `systemd-tmpfiles`

Une maintenance régulière prévient les problèmes d'espace disque et maintient le système performant et stable.