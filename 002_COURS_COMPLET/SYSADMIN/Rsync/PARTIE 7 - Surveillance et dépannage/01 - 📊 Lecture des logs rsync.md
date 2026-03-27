

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

## Format de sortie standard

Par défaut, `rsync` produit une sortie minimale qui affiche uniquement les erreurs. Pour obtenir plus d'informations sur les opérations effectuées, il est nécessaire d'utiliser des options spécifiques.

### Sortie sans option

```bash
# Commande basique sans verbosité
rsync -a /source/ /destination/

# Aucune sortie si tout se passe bien
# Affiche uniquement les erreurs éventuelles
```

> [!info] Comportement par défaut Sans option de verbosité, `rsync` fonctionne en mode silencieux. C'est pratique pour les scripts automatisés où seules les erreurs doivent être capturées.

### Sortie avec -v (verbose)

L'option `-v` active le mode verbeux et affiche la liste des fichiers transférés :

```bash
rsync -av /source/ /destination/

# Sortie :
# sending incremental file list
# ./
# fichier1.txt
# fichier2.txt
# dossier/
# dossier/fichier3.txt
#
# sent 1,234 bytes  received 89 bytes  2,646.00 bytes/sec
# total size is 10,456  speedup is 7.90
```

**Éléments affichés :**

- Liste des fichiers et répertoires traités
- Statistiques de transfert en fin d'opération
- Taille totale et facteur d'accélération (speedup)

> [!tip] Niveaux de verbosité Vous pouvez augmenter le niveau de détail :
> 
> - `-v` : verbosité normale
> - `-vv` : verbosité accrue (affiche les fichiers ignorés)
> - `-vvv` : verbosité maximale (affiche les détails de protocole)

### Sortie avec --progress

L'option `--progress` affiche une barre de progression pour chaque fichier :

```bash
rsync -av --progress /source/ /destination/

# Sortie :
# sending incremental file list
# ./
# fichier1.txt
#           1,024 100%    0.00kB/s    0:00:00 (xfr#1, to-chk=3/5)
# gros_fichier.iso
#     524,288,000  45%  125.45MB/s    0:00:03 (xfr#2, to-chk=2/5)
```

**Informations affichées par fichier :**

- Nom du fichier
- Nombre d'octets transférés
- Pourcentage de progression
- Vitesse de transfert
- Temps restant estimé
- Numéro de transfert (xfr#)
- Fichiers restants à vérifier (to-chk)

> [!example] Exemple pratique
> 
> ```bash
> # Sauvegarde avec progression détaillée
> rsync -avh --progress /home/user/documents/ /backup/documents/
> 
> # L'option -h rend les tailles lisibles (MB, GB au lieu d'octets)
> ```

---

## Option --stats

L'option `--stats` affiche des statistiques détaillées sur l'opération de synchronisation une fois celle-ci terminée.

### Syntaxe

```bash
rsync -av --stats /source/ /destination/
```

### Statistiques affichées

```bash
Number of files: 1,245 (reg: 1,156, dir: 89)
Number of created files: 23
Number of deleted files: 0
Number of regular files transferred: 156
Total file size: 2,456,789,012 bytes
Total transferred file size: 145,678,900 bytes
Literal data: 145,678,900 bytes
Matched data: 0 bytes
File list size: 34,567
File list generation time: 0.001 seconds
File list transfer time: 0.000 seconds
Total bytes sent: 145,756,890
Total bytes received: 3,456

sent 145,756,890 bytes  received 3,456 bytes  9,717,556.40 bytes/sec
total size is 2,456,789,012  speedup is 16.85
```

### Analyse des statistiques importantes

|Statistique|Signification|
|---|---|
|**Number of files**|Nombre total de fichiers examinés (fichiers réguliers, répertoires, liens)|
|**Number of created files**|Fichiers créés à la destination|
|**Number of deleted files**|Fichiers supprimés (avec `--delete`)|
|**Number of regular files transferred**|Fichiers effectivement transférés|
|**Total file size**|Taille totale de tous les fichiers à la source|
|**Total transferred file size**|Taille des fichiers qui ont été transférés|
|**Literal data**|Données réellement envoyées sur le réseau|
|**Matched data**|Données déjà présentes à destination (algorithme delta)|
|**Speedup**|Ratio d'efficacité (taille totale / données transférées)|

> [!info] Comprendre le speedup Un speedup de 16.85 signifie que rsync a synchronisé 16.85 fois plus de données qu'il n'en a réellement transférées grâce à son algorithme de différentiel. Plus ce chiffre est élevé, plus rsync est efficace.

> [!warning] Attention aux interprétations
> 
> - Si **speedup ≈ 1** : presque tous les fichiers ont été transférés (première synchronisation)
> - Si **speedup > 10** : synchronisation incrémentale très efficace
> - **Literal data = 0** signifie qu'aucune donnée n'a été transférée (tout était déjà à jour)

### Cas d'usage pratiques

```bash
# Vérifier l'efficacité d'une synchronisation régulière
rsync -av --stats /data/ user@backup:/data/ | grep -E "speedup|transferred"

# Surveiller l'espace utilisé par les transferts
rsync -av --stats --bwlimit=5000 /source/ /dest/ | grep "Total bytes sent"

# Analyser une synchronisation avec suppression
rsync -av --delete --stats /source/ /dest/ | grep "deleted files"
```

---

## Option --itemize-changes

L'option `--itemize-changes` (ou `-i`) affiche un code pour chaque fichier indiquant précisément quel type de modification a été effectué.

### Syntaxe

```bash
rsync -avi /source/ /destination/
```

### Format de sortie

Chaque ligne suit ce format :

```
YXcstpoguax  chemin/vers/fichier
```

Où chaque caractère a une signification précise.

### Structure du code de 11 caractères

```
Position :  1  2  3  4  5  6  7  8  9  10 11
Exemple :   >  f  c  s  t  p  o  g  u  a  x
```

#### Position 1 : Type de mise à jour

|Code|Signification|
|---|---|
|`<`|Fichier reçu (pull depuis distant)|
|`>`|Fichier envoyé (push vers distant)|
|`c`|Modification locale (changement)|
|`h`|Hard link créé|
|`.`|Fichier non modifié|
|`*`|Message (erreur, information)|

#### Position 2 : Type de fichier

|Code|Signification|
|---|---|
|`f`|Fichier régulier|
|`d`|Répertoire|
|`L`|Lien symbolique|
|`D`|Périphérique (device)|
|`S`|Fichier spécial (socket, fifo)|

#### Positions 3 à 11 : Attributs modifiés

|Position|Attribut|Codes possibles|
|---|---|---|
|3|Contenu / checksum|`c` = modifié, `.` = identique, = nouveau|
|4|Taille|`s` = différente, `.` = identique|
|5|Horodatage|`t` = modifié, `.` = identique, `T` = transféré mais pas modifié|
|6|Permissions|`p` = modifiées, `.` = identiques|
|7|Propriétaire|`o` = modifié, `.` = identique|
|8|Groupe|`g` = modifié, `.` = identique|
|9|ACL utilisateur|`u` = modifiée, `.` = identique|
|10|ACL étendue|`a` = modifiée, `.` = identique|
|11|Attributs étendus|`x` = modifiés, `.` = identiques|

> [!info] Points représentent l'absence de changement Un point (`.`) à n'importe quelle position signifie que cet attribut n'a pas changé.

### Exemples d'interprétation

```bash
>f+++++++++ fichier_nouveau.txt
# > = envoi vers destination
# f = fichier régulier
# + = nouveau fichier (tous les attributs sont nouveaux)

>f.st...... fichier_modifie.txt
# > = envoi vers destination
# f = fichier régulier
# . = checksum identique (mais...)
# s = taille différente
# t = timestamp différent
# ...... = autres attributs identiques

cd+++++++++ nouveau_dossier/
# c = changement local
# d = répertoire
# + = nouveau répertoire

.f...p..... script.sh
# . = aucun transfert
# f = fichier régulier
# ...p = seules les permissions ont changé

>fcstp.g... document.pdf
# > = envoi
# f = fichier
# c = contenu modifié
# s = taille différente
# t = timestamp différent
# p = permissions modifiées
# . = propriétaire identique
# g = groupe modifié
```

> [!example] Cas pratique : audit de synchronisation
> 
> ```bash
> # Voir exactement ce qui change sans transférer
> rsync -avin --delete /source/ /destination/
> 
> # Filtrer uniquement les fichiers modifiés (contenu)
> rsync -avin /source/ /destination/ | grep "^>f.c"
> 
> # Voir uniquement les fichiers supprimés
> rsync -avin --delete /source/ /destination/ | grep "deleting"
> ```

### Combinaison avec --dry-run

L'option `-i` est particulièrement utile avec `--dry-run` pour prévisualiser les changements :

```bash
rsync -avin --dry-run --delete /source/ /destination/

# Sortie détaillée :
# >f+++++++++ nouveau.txt
# >f.st...... modifie.txt
# cd+++++++++ dossier/
# *deleting   ancien.txt
```

> [!tip] Astuce pour les scripts Utilisez `--itemize-changes` dans vos scripts pour logger précisément les modifications :
> 
> ```bash
> rsync -avi /source/ /dest/ > /var/log/rsync-changes.log 2>&1
> ```

---

## Interprétation des codes

Au-delà des codes d'itemization, `rsync` peut produire différents types de messages et codes de sortie.

### Codes de sortie (exit codes)

Lorsque `rsync` se termine, il retourne un code qui indique le résultat de l'opération :

|Code|Signification|
|---|---|
|**0**|Succès complet|
|**1**|Erreur de syntaxe ou d'usage|
|**2**|Incompatibilité de protocole|
|**3**|Erreur lors de la sélection des fichiers|
|**4**|Action non supportée|
|**5**|Erreur au démarrage du protocole|
|**10**|Erreur d'I/O socket|
|**11**|Erreur d'I/O fichier|
|**12**|Erreur dans le flux de données du protocole|
|**13**|Erreur dans les diagnostics du programme|
|**14**|Erreur dans l'allocation mémoire IPC|
|**20**|Signal SIGUSR1 ou SIGINT reçu|
|**21**|Erreur avec waitpid()|
|**22**|Erreur d'allocation mémoire|
|**23**|Transfert partiel (certains fichiers n'ont pas été transférés)|
|**24**|Fichiers disparus pendant le transfert|
|**25**|Limite du nombre de suppressions dépassée (--max-delete)|
|**30**|Timeout lors de l'envoi/réception de données|
|**35**|Timeout lors de l'attente du daemon|

> [!warning] Code 23 : transfert partiel Le code 23 est très courant et ne signifie pas nécessairement un échec total. Il indique que certains fichiers n'ont pas pu être transférés (permissions, fichiers ouverts, etc.). Vérifiez toujours les logs pour identifier les problèmes.

### Utilisation dans les scripts

```bash
#!/bin/bash

rsync -av /source/ /destination/
EXIT_CODE=$?

case $EXIT_CODE in
    0)
        echo "Synchronisation réussie"
        ;;
    23)
        echo "Synchronisation partielle - vérifier les logs"
        ;;
    24)
        echo "Certains fichiers ont disparu pendant le transfert"
        ;;
    *)
        echo "Erreur rsync (code $EXIT_CODE)"
        exit 1
        ;;
esac
```

### Messages d'erreur courants

#### Erreurs de permissions

```bash
rsync: send_files failed to open "/source/fichier.txt": Permission denied (13)
rsync: recv_generator: failed to stat "/dest/fichier.txt": Permission denied (13)
```

**Causes possibles :**

- Permissions insuffisantes sur le fichier source
- Permissions insuffisantes sur le répertoire de destination
- Conflit de propriétaire/groupe

**Solutions :**

- Vérifier les permissions avec `ls -la`
- Exécuter avec `sudo` si nécessaire
- Retirer les options `-o` et `-g` si vous n'avez pas les droits root

#### Erreurs SSH

```bash
rsync: connection unexpectedly closed (0 bytes received so far) [sender]
rsync error: error in rsync protocol data stream (code 12) at io.c(226)
```

**Causes possibles :**

- Problème d'authentification SSH
- Serveur distant inaccessible
- Port SSH non standard non spécifié

**Solutions :**

```bash
# Tester la connexion SSH
ssh user@remote-host

# Spécifier le port SSH
rsync -av -e "ssh -p 2222" /source/ user@host:/dest/

# Augmenter la verbosité SSH
rsync -av -e "ssh -vv" /source/ user@host:/dest/
```

#### Fichiers disparus

```bash
file has vanished: "/source/fichier_temporaire.txt"
```

**Explication :** Le fichier existait au début de la synchronisation mais a été supprimé avant son transfert.

**Solution :** C'est généralement sans gravité. Pour ignorer cette erreur :

```bash
rsync -av /source/ /dest/ || [ $? -eq 24 ]
```

### Messages informatifs

```bash
# Fichier ignoré car plus récent à destination
skipping non-regular file "fichier"

# Création de répertoire
created directory /destination/nouveau_dossier

# Suppression avec --delete
deleting fichier_obsolete.txt

# Hard link créé
"fichier2.txt" is a hard link
```

> [!tip] Rediriger et analyser les logs
> 
> ```bash
> # Séparer sortie standard et erreurs
> rsync -av /source/ /dest/ > /var/log/rsync.log 2> /var/log/rsync.err
> 
> # Tout dans le même fichier avec horodatage
> rsync -av /source/ /dest/ 2>&1 | ts '[%Y-%m-%d %H:%M:%S]' >> /var/log/rsync.log
> 
> # Filtrer uniquement les erreurs
> rsync -av /source/ /dest/ 2>&1 | grep -i "error\|failed\|denied"
> ```

### Analyser les performances

Avec `--stats` et un peu de traitement, vous pouvez extraire des métriques :

```bash
#!/bin/bash

OUTPUT=$(rsync -av --stats /source/ /dest/)

# Extraire le nombre de fichiers transférés
FILES_TRANSFERRED=$(echo "$OUTPUT" | grep "Number of regular files transferred" | awk '{print $6}')

# Extraire la vitesse
SPEED=$(echo "$OUTPUT" | grep "bytes/sec" | awk '{print $4, $5}')

# Extraire le speedup
SPEEDUP=$(echo "$OUTPUT" | grep "speedup" | awk '{print $NF}')

echo "Fichiers transférés : $FILES_TRANSFERRED"
echo "Vitesse : $SPEED"
echo "Efficacité (speedup) : $SPEEDUP"
```

> [!example] Dashboard de monitoring Combinez ces informations pour créer un tableau de bord de vos synchronisations :
> 
> ```bash
> # Script de logging avancé
> LOGFILE="/var/log/rsync-$(date +%Y%m%d).log"
> 
> echo "=== Synchronisation du $(date) ===" >> $LOGFILE
> rsync -avi --stats /source/ /dest/ >> $LOGFILE 2>&1
> 
> # Analyse post-synchronisation
> echo "Fichiers créés : $(grep -c ">f+++++++++" $LOGFILE)" >> $LOGFILE
> echo "Fichiers modifiés : $(grep -c ">f.c" $LOGFILE)" >> $LOGFILE
> echo "Code de sortie : $?" >> $LOGFILE
> ```

---

## 🎯 Récapitulatif

La lecture et l'interprétation correcte des logs `rsync` est essentielle pour :

1. **Vérifier le bon déroulement** des synchronisations
2. **Identifier rapidement les problèmes** grâce aux codes de sortie
3. **Optimiser les performances** en analysant les statistiques
4. **Auditer les modifications** avec `--itemize-changes`
5. **Automatiser la surveillance** dans les scripts de production

> [!tip] Bonnes pratiques de logging
> 
> - Utilisez toujours `-v` ou `-i` dans les scripts de production
> - Conservez les logs avec rotation (logrotate)
> - Combinez `--stats` avec `--dry-run` pour prévisualiser
> - Surveillez les codes de sortie dans vos scripts
> - Documentez les codes d'erreur récurrents spécifiques à votre environnement