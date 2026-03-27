
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

## 🏠 Sauvegarde du répertoire /home

### Pourquoi sauvegarder /home ?

Le répertoire `/home` contient toutes les données utilisateurs du système. C'est souvent la partie la plus critique à sauvegarder car elle contient :
- Documents personnels
- Configurations d'applications
- Projets en cours
- Données irremplaçables

### Exemple de base

```bash
# Sauvegarde complète de /home vers /backup/home
rsync -avh /home/ /backup/home/
```

> [!warning] Attention au slash final
> `/home/` copie le **contenu** de home dans `/backup/home/`
> `/home` créerait `/backup/home/home/`

### Sauvegarde avec progression

```bash
# Afficher la progression pour les gros transferts
rsync -avh --progress /home/ /backup/home/
```

### Sauvegarde avec exclusions intelligentes

```bash
# Exclure les caches et fichiers temporaires
rsync -avh \
  --exclude='.cache/' \
  --exclude='.local/share/Trash/' \
  --exclude='*/Cache/' \
  --exclude='*/.npm/' \
  --exclude='*/node_modules/' \
  /home/ /backup/home/
```

> [!tip] Optimisation de l'espace
> Exclure les caches peut économiser plusieurs gigaoctets et accélérer considérablement la sauvegarde sans perdre de données importantes.

### Sauvegarde avec suppression des fichiers obsolètes

```bash
# Synchronisation exacte (miroir parfait)
rsync -avh --delete /home/ /backup/home/
```

> [!warning] Danger de --delete
> Si un fichier a été supprimé dans `/home/`, il sera également supprimé dans `/backup/home/`. Utilisez cette option avec précaution ou après un `--dry-run`.

### Vérification avant sauvegarde

```bash
# Simulation complète avant l'action réelle
rsync -avh --delete --dry-run /home/ /backup/home/
```

### Tableau récapitulatif des stratégies

| Stratégie | Commande | Usage recommandé |
|-----------|----------|------------------|
| Simple | `rsync -avh /home/ /backup/home/` | Première sauvegarde |
| Avec progression | `rsync -avh --progress /home/ /backup/home/` | Gros volumes de données |
| Avec exclusions | `rsync -avh --exclude='.cache/' /home/ /backup/home/` | Optimiser l'espace |
| Miroir exact | `rsync -avh --delete /home/ /backup/home/` | Synchronisation stricte |
| Sécurisée | `rsync -avh --delete --dry-run /home/ /backup/home/` | Vérification avant action |

---

## 📂 Synchronisation de dossiers de travail

### Cas d'usage typique

Vous travaillez sur plusieurs machines ou vous voulez synchroniser vos projets entre votre environnement de développement et un espace de sauvegarde local.

### Synchronisation d'un projet de développement

```bash
# Synchroniser un projet vers une zone de sauvegarde
rsync -avh ~/projets/mon-application/ /backup/projets/mon-application/
```

### Exclure les fichiers de build et dépendances

```bash
# Exclure tout ce qui peut être régénéré
rsync -avh \
  --exclude='node_modules/' \
  --exclude='vendor/' \
  --exclude='build/' \
  --exclude='dist/' \
  --exclude='*.log' \
  --exclude='.git/' \
  ~/projets/mon-application/ \
  /backup/projets/mon-application/
```

> [!tip] Pourquoi exclure .git/ ?
> Le répertoire `.git/` peut être très volumineux. Si vous avez déjà un dépôt distant (GitHub, GitLab), il n'est souvent pas nécessaire de le sauvegarder localement avec rsync.

### Synchronisation bidirectionnelle de documents

```bash
# Récupérer les modifications depuis le backup
rsync -avh --update /backup/documents/ ~/documents/

# Envoyer les modifications vers le backup
rsync -avh --update ~/documents/ /backup/documents/
```

> [!info] Option --update
> `--update` ne transfère que les fichiers plus récents que ceux de destination. Utile pour synchroniser dans les deux sens sans écraser les versions plus récentes.

### Synchronisation avec horodatage

```bash
# Créer un dossier de backup avec la date
backup_dir="/backup/projets/$(date +%Y-%m-%d)"
rsync -avh ~/projets/mon-application/ "$backup_dir/"
```

### Synchronisation de plusieurs dossiers

```bash
# Utiliser un fichier de liste
cat > /tmp/dossiers-a-sync.txt << EOF
/home/user/Documents/
/home/user/Projets/
/home/user/Scripts/
EOF

# Boucle de synchronisation
while read dossier; do
  nom_dossier=$(basename "$dossier")
  rsync -avh "$dossier" "/backup/$nom_dossier/"
done < /tmp/dossiers-a-sync.txt
```

> [!example] Scénario réel
> Vous gérez plusieurs développeurs qui ont chacun des dossiers de travail. Vous voulez créer une sauvegarde quotidienne de tous leurs projets actifs.

---

## 🎯 Copie sélective avec exclusions

### Principe des exclusions multiples

Les exclusions permettent de filtrer précisément ce qui doit être synchronisé ou non. C'est essentiel pour :
- Économiser de l'espace disque
- Réduire le temps de transfert
- Éviter de sauvegarder des données sensibles ou inutiles

### Exclusions par patterns

```bash
# Exclure tous les fichiers .tmp et .log
rsync -avh \
  --exclude='*.tmp' \
  --exclude='*.log' \
  /source/ /destination/
```

### Exclusions par répertoires

```bash
# Exclure des répertoires spécifiques
rsync -avh \
  --exclude='/cache/' \
  --exclude='/temp/' \
  --exclude='/logs/' \
  /var/www/ /backup/www/
```

> [!warning] Slash de début
> `/cache/` exclut uniquement le dossier `cache` à la racine de la source
> `cache/` ou `*/cache/` exclut tous les dossiers nommés `cache` partout

### Utilisation d'un fichier d'exclusion

```bash
# Créer un fichier d'exclusions
cat > /etc/rsync/exclude-web.txt << EOF
*.log
*.tmp
/cache/
/sessions/
/uploads/temp/
node_modules/
.git/
.env
EOF

# Utiliser le fichier
rsync -avh --exclude-from=/etc/rsync/exclude-web.txt \
  /var/www/site/ /backup/site/
```

> [!tip] Avantage du fichier d'exclusion
> Plus lisible, réutilisable, et facilite la maintenance des règles d'exclusion complexes.

### Inclusions prioritaires

```bash
# Inclure d'abord certains fichiers, puis exclure le reste
rsync -avh \
  --include='*.conf' \
  --include='*.sh' \
  --exclude='*' \
  /etc/ /backup/config/
```

> [!info] Ordre des règles
> Les règles `--include` et `--exclude` sont évaluées dans l'ordre. La première règle qui correspond est appliquée.

### Exemple complexe : sauvegarde de serveur web

```bash
# Sauvegarder un serveur web en excluant l'inutile
rsync -avh \
  --exclude='/var/www/*/cache/' \
  --exclude='/var/www/*/sessions/' \
  --exclude='*.log' \
  --exclude='error_log' \
  --exclude='access_log' \
  --include='/var/www/**/config/' \
  --include='*.conf' \
  --include='*.php' \
  --include='*.html' \
  --include='*.css' \
  --include='*.js' \
  /var/www/ /backup/www/
```

### Exclusions avec wildcards avancés

| Pattern | Signification | Exemple |
|---------|---------------|---------|
| `*.log` | Tous les .log partout | `debug.log`, `app.log` |
| `/*.log` | .log à la racine uniquement | `/app.log` mais pas `/logs/app.log` |
| `**/*.log` | .log à tous les niveaux | Équivalent à `*.log` |
| `*/cache/` | Dossier cache au 1er niveau | `/www/cache/` mais pas `/www/app/cache/` |
| `**/cache/` | Dossier cache partout | Tous les dossiers nommés `cache` |

### Cas pratique : backup de configuration système

```bash
# Sauvegarder uniquement les fichiers de configuration
rsync -avh \
  --include='*/' \
  --include='*.conf' \
  --include='*.cfg' \
  --include='*.config' \
  --include='*.yml' \
  --include='*.yaml' \
  --include='*.json' \
  --exclude='*' \
  /etc/ /backup/config-system/
```

> [!tip] Pattern include-exclude
> `--include='*/'` : inclut tous les répertoires pour permettre la descente
> `--exclude='*'` : exclut tout ce qui n'a pas été inclus explicitement

### Vérification des exclusions

```bash
# Voir ce qui serait copié sans le faire
rsync -avhn \
  --exclude='*.log' \
  --exclude='cache/' \
  /source/ /destination/ | less
```

> [!tip] Option -n
> L'option `-n` (ou `--dry-run`) est votre meilleure amie pour vérifier que vos exclusions fonctionnent comme prévu avant le vrai transfert.

---

## 🎓 Points clés à retenir

| Concept | Point important |
|---------|----------------|
| **Slash final** | Toujours vérifier `/source/` vs `/source` |
| **--delete** | Toujours tester avec `--dry-run` d'abord |
| **Exclusions** | Utiliser des fichiers pour les règles complexes |
| **--update** | Préserve les fichiers plus récents en destination |
| **Progression** | `--progress` pour les gros transferts |
| **Vérification** | `-n` ou `--dry-run` avant toute action critique |

> [!warning] Règle d'or
> Avant toute synchronisation avec `--delete` en production, **TOUJOURS** effectuer un `--dry-run` et vérifier la liste des fichiers qui seraient supprimés.

---

## 🔍 Astuces professionnelles

### Créer un alias pour les sauvegardes fréquentes

```bash
# Ajouter dans ~/.bashrc
alias backup-home='rsync -avh --exclude-from=/home/user/.rsync-exclude /home/user/ /backup/home/'
```

### Utiliser des timestamps pour l'historique

```bash
# Garder un historique des sauvegardes
rsync -avh --backup --backup-dir="/backup/incremental/$(date +%Y-%m-%d_%H-%M-%S)" \
  /home/ /backup/home/
```

### Combiner avec ionice pour ne pas saturer le disque

```bash
# Priorité basse pour ne pas gêner les autres processus
ionice -c3 rsync -avh /source/ /destination/
```

### Estimer l'espace nécessaire avant le transfert

```bash
# Simuler et compter la taille totale
rsync -avhn /source/ /destination/ | grep "total size" 
```