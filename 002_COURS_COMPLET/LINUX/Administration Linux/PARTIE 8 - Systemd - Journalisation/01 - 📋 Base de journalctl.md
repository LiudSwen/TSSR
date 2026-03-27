

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

## Introduction à journalctl

`journalctl` est l'outil de consultation des logs du système journaling de systemd. Contrairement aux logs textuels traditionnels (`/var/log/syslog`, `/var/log/messages`), systemd stocke les logs dans un format binaire structuré via le service `systemd-journald`.

> [!info] Pourquoi journalctl ?
> 
> - **Logs structurés** : Chaque entrée contient des métadonnées (service, priorité, PID, timestamp, etc.)
> - **Recherche puissante** : Filtrage rapide par service, période, priorité
> - **Centralisation** : Tous les logs système au même endroit
> - **Rotation automatique** : Gestion intelligente de l'espace disque

> [!warning] Emplacement des logs Les logs journald sont stockés dans `/var/log/journal/` (persistant) ou `/run/log/journal/` (volatile, effacé au redémarrage). La persistance dépend de la configuration dans `/etc/systemd/journald.conf`.

---

## Consultation des logs

### Affichage de base

```bash
# Afficher tous les logs (du plus ancien au plus récent)
journalctl

# Afficher uniquement les logs du boot actuel
journalctl -b

# Afficher les logs d'un boot précédent
journalctl -b -1  # Boot précédent
journalctl -b -2  # Avant-dernier boot

# Lister tous les boots disponibles
journalctl --list-boots
```

> [!example] Exemple de sortie
> 
> ```
> Jan 15 14:23:45 hostname systemd[1]: Started Session 2 of user john.
> Jan 15 14:23:46 hostname sshd[1234]: Accepted password for john from 192.168.1.100
> Jan 15 14:23:47 hostname sudo[1235]: john : TTY=pts/0 ; PWD=/home/john ; USER=root ; COMMAND=/bin/systemctl status nginx
> ```

### Filtrage par service ou unité

```bash
# Logs d'un service spécifique
journalctl -u nginx.service
journalctl -u ssh.service

# Logs de plusieurs services
journalctl -u nginx.service -u mysql.service

# Logs du kernel uniquement
journalctl -k
```

> [!tip] Astuce Utilisez `tab` pour l'autocomplétion des noms de services après `-u`.

### Filtrage par niveau de priorité

```bash
# Afficher uniquement les erreurs et plus grave
journalctl -p err

# Afficher les avertissements et plus grave
journalctl -p warning
```

|Niveau|Valeur|Description|
|---|---|---|
|`emerg`|0|Système inutilisable|
|`alert`|1|Action immédiate requise|
|`crit`|2|Condition critique|
|`err`|3|Erreur|
|`warning`|4|Avertissement|
|`notice`|5|Notice normale mais significative|
|`info`|6|Information|
|`debug`|7|Message de débogage|

### Filtrage par période

```bash
# Depuis une date précise
journalctl --since "2025-01-15 14:00:00"

# Depuis aujourd'hui
journalctl --since today

# Depuis hier
journalctl --since yesterday

# Dernière heure
journalctl --since "1 hour ago"

# Entre deux dates
journalctl --since "2025-01-15" --until "2025-01-16 12:00:00"
```

> [!example] Formats de date acceptés
> 
> - `"YYYY-MM-DD HH:MM:SS"`
> - `"2 days ago"`
> - `"30 minutes ago"`
> - `yesterday`, `today`, `now`

---

## Navigation dans les logs

### Interface de pagination

Par défaut, `journalctl` utilise `less` comme paginateur, permettant une navigation intuitive.

|Commande|Action|
|---|---|
|`Espace` ou `PgDn`|Page suivante|
|`b` ou `PgUp`|Page précédente|
|`g`|Aller au début|
|`G`|Aller à la fin|
|`/motif`|Rechercher un motif (vers le bas)|
|`?motif`|Rechercher un motif (vers le haut)|
|`n`|Occurrence suivante|
|`N`|Occurrence précédente|
|`q`|Quitter|

> [!tip] Recherche efficace Utilisez `/ERROR` puis `n` pour naviguer rapidement entre les erreurs dans les logs.

### Désactiver le paginateur

```bash
# Sortie directe sans pagination (utile pour pipes)
journalctl --no-pager

# Exemple : redirection vers un fichier
journalctl --no-pager > logs.txt

# Exemple : comptage des erreurs
journalctl -p err --no-pager | wc -l
```

---

## Options essentielles

### Option `-f` (follow)

Suit les logs en temps réel, comme `tail -f` pour les fichiers logs traditionnels.

```bash
# Suivre tous les nouveaux logs
journalctl -f

# Suivre un service spécifique
journalctl -u nginx.service -f

# Suivre uniquement les erreurs en temps réel
journalctl -p err -f
```

> [!info] Quand utiliser `-f` ?
> 
> - **Débogage en direct** : Observer le comportement d'une application
> - **Surveillance** : Détecter des erreurs en temps réel
> - **Déploiement** : Suivre les logs pendant un redémarrage de service

> [!warning] Attention Appuyez sur `Ctrl+C` pour arrêter le suivi. Sans cela, le terminal reste bloqué.

### Option `-n` (nombre de lignes)

Limite le nombre de lignes affichées, similaire à `tail -n`.

```bash
# Afficher les 50 dernières lignes
journalctl -n 50

# Afficher les 100 dernières lignes d'un service
journalctl -u apache2.service -n 100

# Combiner avec -f pour suivre les 20 dernières lignes puis continuer
journalctl -n 20 -f
```

> [!example] Cas d'usage courant
> 
> ```bash
> # Vérifier rapidement les derniers événements d'un service
> journalctl -u mysql.service -n 30
> ```

**Valeur par défaut** : Sans `-n`, `journalctl` affiche les 1000 dernières lignes lorsqu'il est paginé.

### Option `-r` (reverse)

Inverse l'ordre d'affichage : du plus récent au plus ancien.

```bash
# Afficher les logs du plus récent au plus ancien
journalctl -r

# Les 50 logs les plus récents
journalctl -r -n 50

# Les erreurs les plus récentes d'un service
journalctl -u nginx.service -p err -r -n 20
```

> [!tip] Pourquoi utiliser `-r` ?
> 
> - **Analyse rapide** : Les informations les plus récentes apparaissent en premier
> - **Dépannage** : Identifier immédiatement le dernier problème survenu
> - **Gain de temps** : Pas besoin de scroller jusqu'à la fin

### Combinaisons utiles

```bash
# Les 30 dernières lignes en temps réel, du plus récent au plus ancien
journalctl -r -n 30 -f

# Suivre les erreurs d'un service en temps réel
journalctl -u ssh.service -p err -f

# Les 100 dernières erreurs, triées du plus récent au plus ancien
journalctl -p err -r -n 100

# Logs d'aujourd'hui, les 50 plus récents
journalctl --since today -r -n 50
```

---

## Pièges courants

> [!warning] Piège n°1 : Oublier `sudo` ou les permissions La plupart des logs systèmes nécessitent des privilèges root. Sans `sudo`, vous verrez un sous-ensemble limité.
> 
> ```bash
> # Limité
> journalctl -u nginx.service
> 
> # Complet
> sudo journalctl -u nginx.service
> ```

> [!warning] Piège n°2 : Confusion avec les boots Par défaut, `journalctl` affiche **tous** les boots. Pour le boot actuel uniquement :
> 
> ```bash
> journalctl -b
> ```

> [!warning] Piège n°3 : Logs trop verbeux Sans filtre, `journalctl` peut afficher des milliers de lignes. Toujours filtrer par service, période ou priorité.

> [!warning] Piège n°4 : Formats de date incorrects
> 
> ```bash
> # ❌ Incorrect
> journalctl --since 2025-01-15
> 
> # ✅ Correct
> journalctl --since "2025-01-15"
> ```

> [!warning] Piège n°5 : Utiliser `-f` sans contexte `-f` seul suit TOUS les logs système. Toujours combiner avec un filtre :
> 
> ```bash
> # Trop verbeux
> journalctl -f
> 
> # Mieux
> journalctl -u myapp.service -f
> ```

---

## Bonnes pratiques

### 🎯 Stratégie de consultation

1. **Commencer large, affiner progressivement**

```bash
# Étape 1 : Vue d'ensemble
journalctl -b -p err

# Étape 2 : Identifier le service problématique
journalctl -u nginx.service -p err

# Étape 3 : Contexte temporel
journalctl -u nginx.service --since "10 minutes ago"

# Étape 4 : Détails complets
journalctl -u nginx.service -xe
```

2. **Utiliser des alias pour les commandes fréquentes**

```bash
# Dans ~/.bashrc
alias jf='journalctl -f'
alias je='journalctl -p err -r -n 50'
alias jb='journalctl -b -p err'
```

### 📊 Format de sortie

```bash
# Format JSON (utile pour parsing)
journalctl -u nginx.service -o json

# Format JSON condensé (une ligne par entrée)
journalctl -u nginx.service -o json-pretty

# Format court (sans hostname, timestamp simplifié)
journalctl -u nginx.service -o short

# Format verbeux (toutes les métadonnées)
journalctl -u nginx.service -o verbose
```

### 🔍 Recherche avancée

```bash
# Combiner plusieurs critères
journalctl -u nginx.service \
  --since "2025-01-15 10:00" \
  --until "2025-01-15 12:00" \
  -p warning

# Exclure avec grep
journalctl -u nginx.service | grep -v "GET /health"

# Rechercher un PID spécifique
journalctl _PID=1234
```

> [!tip] Astuce : Utiliser `grep` avec couleur
> 
> ```bash
> journalctl -u nginx.service | grep --color=always -i error
> ```

### 💾 Export et sauvegarde

```bash
# Exporter vers un fichier
journalctl -u nginx.service --since today > nginx-today.log

# Exporter avec horodatage dans le nom
journalctl -b > "boot-$(date +%Y%m%d-%H%M%S).log"

# Exporter en JSON pour analyse
journalctl -u myapp.service -o json > myapp.json
```

### ⚡ Optimisation des performances

```bash
# Utiliser --no-pager pour les scripts
journalctl --no-pager -u nginx.service | grep ERROR

# Limiter la période pour les recherches rapides
journalctl --since "1 hour ago" -p err

# Utiliser -q (quiet) pour supprimer les messages de progression
journalctl -q -u nginx.service
```

---

> [!tip] Mémo rapide
> 
> - `journalctl -b` : Logs du boot actuel
> - `journalctl -u service` : Logs d'un service
> - `journalctl -f` : Suivi en temps réel
> - `journalctl -r -n 50` : Les 50 derniers logs
> - `journalctl -p err` : Uniquement les erreurs
> - `journalctl --since today` : Logs d'aujourd'hui