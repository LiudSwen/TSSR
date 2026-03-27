

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

## Introduction au filtrage

Le journal systemd peut contenir des millions d'entrées. Sans filtrage, il serait impossible d'exploiter efficacement ces données. `journalctl` offre des options de filtrage puissantes pour cibler précisément les informations recherchées.

> [!info] Pourquoi filtrer ?
> 
> - **Performance** : Évite de charger des millions de lignes inutiles
> - **Pertinence** : Trouve rapidement l'information critique
> - **Débogage** : Isole les problèmes spécifiques
> - **Audit** : Analyse des périodes ou services précis

---

## Filtrage par service (-u)

### Concept

L'option `-u` (ou `--unit`) permet de filtrer les logs d'une unité systemd spécifique (service, socket, timer, etc.).

### Syntaxe de base

```bash
# Afficher les logs d'un service
journalctl -u nom_du_service

# Plusieurs services simultanément
journalctl -u service1 -u service2

# Avec le suffixe .service (équivalent)
journalctl -u nginx.service
```

### Exemples pratiques

```bash
# Logs du serveur web Apache
journalctl -u apache2

# Logs du serveur SSH
journalctl -u sshd

# Logs de plusieurs services liés
journalctl -u nginx -u php-fpm

# Suivre en temps réel les logs d'un service
journalctl -u docker -f
```

> [!example] Cas d'usage typique Après le redémarrage d'un service qui ne fonctionne pas :
> 
> ```bash
> sudo systemctl restart postgresql
> # Le service a échoué, analysons pourquoi
> journalctl -u postgresql -n 50
> ```

### Patterns et wildcards

```bash
# Tous les services commençant par "docker"
journalctl -u 'docker*'

# Attention : utiliser les guillemets pour éviter l'expansion du shell
journalctl -u 'nginx*'
```

> [!warning] Nom exact requis Le nom doit correspondre exactement à celui utilisé par systemd. Utilisez `systemctl list-units` pour vérifier les noms exacts.

### Astuces

```bash
# Identifier le nom exact d'une unité
systemctl list-units --type=service | grep nginx

# Vérifier qu'une unité a bien des logs
journalctl -u mon-service --no-pager | wc -l

# Logs d'un service avec sortie JSON (utile pour parsing)
journalctl -u ssh -o json-pretty
```

---

## Filtrage par priorité (-p)

### Concept

L'option `-p` (ou `--priority`) filtre selon le niveau de gravité des messages. Systemd utilise les niveaux syslog standards.

### Niveaux de priorité

|Niveau|Valeur|Description|Usage typique|
|---|---|---|---|
|`emerg`|0|Système inutilisable|Panique kernel, crash critique|
|`alert`|1|Action immédiate requise|Corruption de données|
|`crit`|2|Conditions critiques|Erreur matérielle|
|`err`|3|Conditions d'erreur|Échec de service|
|`warning`|4|Conditions d'avertissement|Espace disque faible|
|`notice`|5|Normal mais significatif|Démarrage de service|
|`info`|6|Information|Logs verbeux|
|`debug`|7|Messages de débogage|Développement|

### Syntaxe

```bash
# Afficher uniquement les erreurs et plus grave
journalctl -p err

# Syntaxe alternative avec numéro
journalctl -p 3

# Plage de priorités (du niveau X au niveau le plus grave)
journalctl -p warning  # warning, err, crit, alert, emerg
```

> [!info] Comportement par défaut `-p err` affiche les messages de niveau `err` **et tous les niveaux plus graves** (crit, alert, emerg).

### Exemples pratiques

```bash
# Uniquement les erreurs critiques et plus
journalctl -p crit

# Tous les avertissements et erreurs depuis hier
journalctl -p warning --since yesterday

# Erreurs d'un service spécifique
journalctl -u nginx -p err

# Debug d'un service (très verbeux)
journalctl -u ma-app -p debug
```

> [!example] Diagnostic rapide du système
> 
> ```bash
> # Voir toutes les erreurs récentes du système
> journalctl -p err --since "1 hour ago"
> 
> # Compter les erreurs par jour
> journalctl -p err --since "7 days ago" --until "now" | grep -c "^-- Logs begin"
> ```

### Plage de priorités précise

```bash
# Plage inclusive (non supporté directement, mais contournable)
# Pour obtenir seulement warning et err (pas crit+) :
journalctl -p warning | grep -E "warning|error"

# Approche plus propre : filtrer après coup avec des outils
journalctl -o json | jq 'select(.PRIORITY == "4" or .PRIORITY == "3")'
```

> [!tip] Astuce de production Configurez des alertes sur les messages `err` et plus graves :
> 
> ```bash
> # Script de monitoring simple
> if journalctl -p err --since "5 minutes ago" | grep -q "error"; then
>     echo "Erreurs détectées !" | mail -s "Alert" admin@example.com
> fi
> ```

---

## Filtrage par date (--since, --until)

### Concept

Les options `--since` et `--until` permettent de délimiter une fenêtre temporelle pour l'analyse des logs.

### Formats acceptés

Systemd accepte une grande variété de formats de dates :

```bash
# Formats relatifs (les plus pratiques)
--since "10 minutes ago"
--since "2 hours ago"
--since "yesterday"
--since "today"

# Formats absolus
--since "2024-12-27 14:30:00"
--since "2024-12-27"
--since "2024-12-27 14:30"

# Formats relatifs avec unités
--since "-1h"      # Dernière heure
--since "-30min"   # 30 dernières minutes
--since "-2d"      # 2 derniers jours
```

### Syntaxe de base

```bash
# Logs depuis un point dans le temps
journalctl --since "1 hour ago"

# Logs jusqu'à un point dans le temps
journalctl --until "2024-12-20"

# Fenêtre temporelle précise
journalctl --since "2024-12-27 08:00" --until "2024-12-27 12:00"
```

### Exemples pratiques

```bash
# Logs d'aujourd'hui
journalctl --since today

# Logs depuis hier à 18h
journalctl --since "yesterday 18:00"

# Logs de la dernière heure
journalctl --since "1 hour ago"

# Logs entre deux dates précises
journalctl --since "2024-12-20 00:00" --until "2024-12-21 00:00"

# Logs de la semaine dernière
journalctl --since "1 week ago" --until "yesterday"
```

> [!example] Analyse d'incident
> 
> ```bash
> # Un service a planté à 14h32, analysons les 10 minutes avant et après
> journalctl -u mon-service \
>   --since "2024-12-27 14:22" \
>   --until "2024-12-27 14:42"
> ```

### Formats spéciaux

```bash
# Début/fin de la journée
--since "00:00"
--until "23:59"

# Combinaisons intelligentes
--since "monday"           # Depuis le dernier lundi
--since "last monday"      # Depuis le lundi dernier
--since "2 weeks ago"      # 2 dernières semaines

# UTC vs local (par défaut : heure locale)
journalctl --since "2024-12-27 14:00:00 UTC"
```

> [!warning] Attention aux fuseaux horaires Par défaut, `journalctl` utilise l'heure locale du système. Si vous travaillez avec des serveurs dans différents fuseaux, spécifiez toujours UTC pour éviter la confusion.

### Astuces

```bash
# Logs du boot actuel depuis une heure
journalctl -b --since "1 hour ago"

# Compter les entrées par période
journalctl --since "today" | wc -l

# Exporter les logs d'une période pour analyse
journalctl --since "2024-12-20" --until "2024-12-21" > logs_20dec.txt

# Trouver le premier et dernier log
journalctl --no-pager | head -n 1  # Premier
journalctl --no-pager | tail -n 1  # Dernier
```

> [!tip] Performance Plus la fenêtre temporelle est restreinte, plus la recherche sera rapide. Utilisez toujours `--since` et `--until` pour optimiser les requêtes sur de gros journaux.

---

## Filtrage par boot (-b)

### Concept

L'option `-b` (ou `--boot`) permet de filtrer les logs par session de démarrage. Chaque fois que le système démarre, un nouvel ID de boot est créé.

### Syntaxe

```bash
# Boot actuel (par défaut)
journalctl -b
journalctl -b 0

# Boot précédent
journalctl -b -1

# Avant-dernier boot
journalctl -b -2

# Boot spécifique par ID
journalctl -b <boot_id>

# Lister tous les boots enregistrés
journalctl --list-boots
```

### Identifier les boots

```bash
# Liste complète des boots avec ID et timestamps
journalctl --list-boots

# Sortie typique :
# -2 abc123... Mon 2024-12-25 10:23:45 CET—Mon 2024-12-25 18:45:12 CET
# -1 def456... Tue 2024-12-26 09:15:33 CET—Tue 2024-12-26 23:59:01 CET
#  0 ghi789... Wed 2024-12-27 08:00:00 CET—Wed 2024-12-27 15:30:22 CET
```

### Exemples pratiques

```bash
# Logs du démarrage actuel
journalctl -b

# Pourquoi le système a-t-il redémarré hier ?
journalctl -b -1

# Analyser un crash survenu il y a 3 boots
journalctl -b -3 -p err

# Logs d'un service lors du boot précédent
journalctl -b -1 -u nginx

# Temps de boot (combien de temps pour démarrer ?)
journalctl -b | grep "Startup finished"
```

> [!example] Diagnostic de problème au démarrage
> 
> ```bash
> # Le système a mal démarré ce matin, analysons
> journalctl -b 0 -p err
> 
> # Comparer avec le démarrage précédent (qui fonctionnait)
> journalctl -b -1 -p err
> ```

### Boot ID spécifique

```bash
# Utiliser un boot ID exact
journalctl --list-boots  # Copier le boot ID voulu
journalctl -b abc123def456...

# Utile pour automatisation et scripts
BOOT_ID=$(journalctl --list-boots | head -n 1 | awk '{print $2}')
journalctl -b "$BOOT_ID"
```

### Statistiques de boot

```bash
# Nombre de boots enregistrés
journalctl --list-boots | wc -l

# Durée du dernier boot
journalctl -b 0 | grep "Startup finished in"

# Tous les redémarrages avec leur cause
journalctl | grep -i "reboot\|shutdown"
```

> [!info] Conservation des logs de boot Par défaut, systemd conserve les logs des boots précédents si la journalisation persistante est activée (`Storage=persistent` dans `/etc/systemd/journald.conf`). Sans cela, seuls les logs du boot actuel sont disponibles.

### Combinaison boot + date

```bash
# Logs du boot actuel depuis 10h ce matin
journalctl -b --since "10:00"

# Logs du boot précédent pendant sa première heure
journalctl -b -1 --since "@boot" --until "1 hour after boot"

# En pratique : obtenir l'heure de début du boot
START_TIME=$(journalctl -b -1 --no-pager | head -n 1 | awk '{print $1, $2, $3}')
journalctl -b -1 --since "$START_TIME" --until "$START_TIME + 1 hour"
```

> [!warning] Limitation temporelle La rétention des logs de boot dépend de la configuration. Par défaut, systemd garde environ 4 semaines de logs. Vérifiez `/etc/systemd/journald.conf` pour `SystemMaxUse` et `MaxRetentionSec`.

### Astuces

```bash
# Identifier un boot problématique
journalctl --list-boots | while read line; do
    BOOT=$(echo $line | awk '{print $1}')
    ERRORS=$(journalctl -b $BOOT -p err --no-pager | wc -l)
    echo "Boot $BOOT : $ERRORS erreurs"
done

# Logs de démarrage uniquement (init + services)
journalctl -b -u systemd --since "@boot" --until "5 minutes after boot"
```

---

## Combinaison de filtres

### Principe

La vraie puissance de `journalctl` réside dans la combinaison de plusieurs filtres pour cibler précisément l'information recherchée.

### Syntaxe et logique

```bash
# Les filtres sont combinés avec un AND logique
journalctl -u nginx -p err --since "1 hour ago"
# = erreurs nginx de la dernière heure

# Plusieurs unités = OR logique
journalctl -u nginx -u apache2 -p err
# = erreurs de nginx OU apache2
```

### Exemples de combinaisons courantes

```bash
# Erreurs d'un service lors du boot précédent
journalctl -b -1 -u postgresql -p err

# Warnings d'un service pendant une fenêtre temporelle
journalctl -u docker -p warning \
  --since "2024-12-27 08:00" \
  --until "2024-12-27 12:00"

# Logs critiques du boot actuel depuis ce matin
journalctl -b 0 -p crit --since "today"

# Plusieurs services, erreurs uniquement, dernière heure
journalctl -u nginx -u php-fpm -p err --since "1 hour ago"

# Service spécifique, boot spécifique, période précise
journalctl -u sshd -b -2 \
  --since "2024-12-25 10:00" \
  --until "2024-12-25 11:00"
```

> [!example] Scénario réel : analyse d'un incident
> 
> ```bash
> # Un service web a été lent hier entre 14h et 15h
> # 1. Identifier les erreurs
> journalctl -u nginx -p err \
>   --since "yesterday 14:00" \
>   --until "yesterday 15:00"
> 
> # 2. Regarder aussi PHP-FPM (backend)
> journalctl -u php-fpm -p warning \
>   --since "yesterday 14:00" \
>   --until "yesterday 15:00"
> 
> # 3. Vérifier les ressources système
> journalctl -p err \
>   --since "yesterday 14:00" \
>   --until "yesterday 15:00" | grep -E "memory|disk|cpu"
> ```

### Filtres avancés avec follow

```bash
# Suivre en temps réel les erreurs de plusieurs services
journalctl -f -u nginx -u mysql -p err

# Suivre un service depuis un moment précis
journalctl -u mon-app -f --since "5 minutes ago"
```

### Tableau récapitulatif des combinaisons utiles

|Combinaison|Commande|Usage|
|---|---|---|
|Service + erreurs|`journalctl -u SERVICE -p err`|Debug d'un service|
|Service + période|`journalctl -u SERVICE --since DATE`|Analyse post-incident|
|Boot + erreurs|`journalctl -b -1 -p err`|Pourquoi le reboot ?|
|Multi-services + temps réel|`journalctl -f -u S1 -u S2`|Monitoring live|
|Priorité + période + boot|`journalctl -b 0 -p crit --since today`|Audit sécurité|

### Options de sortie combinées

```bash
# JSON pour parsing automatisé
journalctl -u nginx -p err --since "1 hour ago" -o json-pretty

# Format court pour lecture rapide
journalctl -u docker -p warning --since today -o cat

# Avec numéros de ligne (via less)
journalctl -u ssh --since today | less -N

# Export pour analyse externe
journalctl -u postgres -p err \
  --since "2024-12-20" \
  --until "2024-12-27" \
  --no-pager -o json > postgres_errors.json
```

> [!tip] Performance des requêtes complexes Plus vous ajoutez de filtres restrictifs, plus la requête sera rapide. L'ordre importe peu, mais privilégiez :
> 
> 1. Fenêtre temporelle (`--since`, `--until`)
> 2. Boot spécifique (`-b`)
> 3. Unité (`-u`)
> 4. Priorité (`-p`)

---

## Pièges courants

### 1. Confusion sur les priorités

> [!warning] Erreur fréquente
> 
> ```bash
> # ❌ FAUX : ne montrera QUE les warnings
> # En réalité, montre warning ET plus grave
> journalctl -p warning
> 
> # ✅ Pour avoir UNIQUEMENT les warnings
> journalctl -o json | jq 'select(.PRIORITY == "4")'
> ```

### 2. Nom d'unité incorrect

```bash
# ❌ Erreur courante
journalctl -u nginx
# Alors que le service s'appelle nginx.service ou www

# ✅ Vérifier d'abord
systemctl list-units --type=service | grep nginx
journalctl -u nginx.service
```

### 3. Oubli du fuseau horaire

```bash
# ❌ Sur un serveur en UTC, ceci peut surprendre
journalctl --since "14:00"
# Quelle 14h ? UTC ou locale ?

# ✅ Être explicite
journalctl --since "2024-12-27 14:00:00 UTC"
```

### 4. Croire que les logs existent

> [!warning] Vérification indispensable
> 
> ```bash
> # Pas de logs = service non démarré ou journalisation désactivée
> journalctl -u mon-service
> # -- No entries --
> 
> # Vérifier que le service existe et a tourné
> systemctl status mon-service
> ```

### 5. Performance sur gros journaux

```bash
# ❌ Très lent sur des journaux volumineux
journalctl | grep "error"

# ✅ Filtrer en amont
journalctl -p err --since "1 hour ago"
```

### 6. Wildcards sans guillemets

```bash
# ❌ Le shell interprète le *
journalctl -u docker*

# ✅ Protéger avec des guillemets
journalctl -u 'docker*'
```

### 7. Format de date ambigu

```bash
# ❌ Peut être mal interprété
journalctl --since 12/27/2024  # Jour/mois ou mois/jour ?

# ✅ Format ISO-8601 sans ambiguïté
journalctl --since "2024-12-27"
```

---

> [!tip] Bonnes pratiques générales
> 
> - Toujours commencer par une fenêtre temporelle (`--since`) pour limiter la quantité de données
> - Utiliser `-n` pour limiter le nombre de lignes affichées lors des tests
> - Combiner `-f` (follow) avec des filtres pour du monitoring ciblé
> - Exporter en JSON pour traitement automatisé : `journalctl -o json`
> - Documenter vos commandes dans des scripts pour reproduire les analyses

---

**Mémo rapide des options de filtrage :**

```bash
-u SERVICE              # Filtrer par service
-p PRIORITÉ             # Filtrer par niveau (err, warning, etc.)
--since DATE            # Depuis une date
--until DATE            # Jusqu'à une date
-b [N]                  # Boot N (0=actuel, -1=précédent)
-f                      # Suivre en temps réel (follow)
-n NOMBRE               # Limiter à N dernières lignes
--no-pager              # Sortie brute sans pagination
```