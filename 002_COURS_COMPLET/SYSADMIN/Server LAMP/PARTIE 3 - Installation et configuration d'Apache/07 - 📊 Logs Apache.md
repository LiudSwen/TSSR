

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

## 🎯 Introduction

Les logs Apache sont essentiels pour :

- **Diagnostiquer** les problèmes techniques
- **Analyser** le trafic et le comportement des visiteurs
- **Détecter** les tentatives d'intrusion ou activités suspectes
- **Optimiser** les performances du serveur
- **Respecter** les obligations légales de conservation

Apache génère deux types principaux de logs : les logs d'accès (qui a demandé quoi) et les logs d'erreur (qu'est-ce qui n'a pas fonctionné).

> [!info] Emplacement par défaut des logs
> 
> - **Debian/Ubuntu** : `/var/log/apache2/`
> - **RedHat/CentOS** : `/var/log/httpd/`

---

## 📝 Types de logs Apache

### Access Log

Le **Access Log** enregistre toutes les requêtes HTTP reçues par le serveur, qu'elles soient réussies ou non.

#### Configuration

```apache
# Dans httpd.conf ou apache2.conf
CustomLog /var/log/apache2/access.log combined

# Pour un Virtual Host spécifique
<VirtualHost *:80>
    ServerName exemple.com
    CustomLog /var/log/apache2/exemple-access.log combined
</VirtualHost>
```

#### Exemple de ligne dans access.log

```
192.168.1.100 - - [21/Dec/2025:14:32:10 +0100] "GET /index.html HTTP/1.1" 200 2326 "https://google.com" "Mozilla/5.0"
```

**Décomposition** :

- `192.168.1.100` : IP du client
- `-` : identité RFC 1413 (rarement utilisé)
- `-` : utilisateur authentifié (si authentification HTTP)
- `[21/Dec/2025:14:32:10 +0100]` : timestamp
- `"GET /index.html HTTP/1.1"` : méthode, ressource, protocole
- `200` : code de statut HTTP
- `2326` : taille de la réponse en octets
- `"https://google.com"` : référent (d'où vient le visiteur)
- `"Mozilla/5.0"` : user-agent (navigateur)

> [!tip] Utilité du Access Log
> 
> - Analyse du trafic et des pages populaires
> - Détection des bots et crawlers
> - Identification des sources de trafic
> - Statistiques de fréquentation

---

### Error Log

Le **Error Log** enregistre tous les problèmes rencontrés par Apache : erreurs d'exécution, avertissements, erreurs de configuration, etc.

#### Configuration

```apache
# Niveau de log : emerg, alert, crit, error, warn, notice, info, debug
LogLevel warn

ErrorLog /var/log/apache2/error.log

# Pour un Virtual Host
<VirtualHost *:80>
    ServerName exemple.com
    ErrorLog /var/log/apache2/exemple-error.log
    LogLevel error
</VirtualHost>
```

#### Niveaux de log

|Niveau|Description|Utilisation|
|---|---|---|
|`emerg`|Système inutilisable|Crash total du serveur|
|`alert`|Action immédiate requise|Problème critique à résoudre|
|`crit`|Conditions critiques|Erreurs graves mais serveur opérationnel|
|`error`|Erreurs|Problèmes fonctionnels (404, 500, etc.)|
|`warn`|Avertissements|Problèmes potentiels|
|`notice`|Normal mais significatif|Événements importants|
|`info`|Informatif|Informations générales|
|`debug`|Debug|Tout le détail (très verbeux)|

> [!warning] Attention au niveau debug Le niveau `debug` génère énormément de logs et peut impacter les performances. À utiliser uniquement pour le débogage temporaire.

#### Exemple de lignes dans error.log

```
[Sun Dec 21 14:32:10.123456 2025] [core:error] [pid 12345] [client 192.168.1.100:54321] File does not exist: /var/www/html/favicon.ico

[Sun Dec 21 14:35:22.987654 2025] [php7:warn] [pid 12346] [client 192.168.1.101:54322] PHP Warning: Division by zero in /var/www/html/script.php on line 42
```

**Décomposition** :

- `[Sun Dec 21 14:32:10.123456 2025]` : timestamp précis
- `[core:error]` : module et niveau
- `[pid 12345]` : ID du processus
- `[client 192.168.1.100:54321]` : IP et port du client
- Message d'erreur détaillé

---

## 🎨 Formats de logs

Apache permet de personnaliser le format des logs d'accès selon vos besoins.

### Format Common

Le format le plus simple et universel.

```apache
LogFormat "%h %l %u %t \"%r\" %>s %b" common
CustomLog /var/log/apache2/access.log common
```

**Variables** :

- `%h` : IP du client
- `%l` : identité RFC 1413
- `%u` : utilisateur authentifié
- `%t` : timestamp
- `%r` : première ligne de la requête
- `%>s` : code de statut final
- `%b` : taille de la réponse

---

### Format Combined

Le format le plus utilisé, inclut référent et user-agent.

```apache
LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" combined
CustomLog /var/log/apache2/access.log combined
```

> [!info] Format recommandé Le format `combined` est recommandé car il fournit suffisamment d'informations pour l'analyse tout en restant lisible.

---

### Format personnalisé

Vous pouvez créer vos propres formats selon vos besoins.

```apache
# Format avec temps de traitement
LogFormat "%h %l %u %t \"%r\" %>s %b %D" custom_timing
CustomLog /var/log/apache2/access.log custom_timing

# Format JSON pour parsing automatisé
LogFormat "{ \"time\":\"%t\", \"client\":\"%h\", \"request\":\"%r\", \"status\":%>s, \"bytes\":%b }" json
CustomLog /var/log/apache2/access.log json

# Format pour analyse de performance
LogFormat "%h %t \"%r\" %>s %b %D \"%{Referer}i\"" performance
CustomLog /var/log/apache2/performance.log performance

# Format avec Virtual Host
LogFormat "%v %h %l %u %t \"%r\" %>s %b" vhost_combined
CustomLog /var/log/apache2/access.log vhost_combined
```

---

### Variables disponibles

Voici les variables les plus utiles pour créer des formats personnalisés :

#### Variables de requête

|Variable|Description|Exemple|
|---|---|---|
|`%h`|IP du client|`192.168.1.100`|
|`%a`|IP du client (même derrière proxy)|`192.168.1.100`|
|`%A`|IP locale du serveur|`10.0.0.5`|
|`%{REMOTE_ADDR}i`|Adresse IP distante|`192.168.1.100`|
|`%l`|Identité RFC 1413|`-` (rarement utilisé)|
|`%u`|Utilisateur authentifié|`john` ou `-`|
|`%t`|Timestamp|`[21/Dec/2025:14:32:10 +0100]`|
|`%r`|Première ligne de requête|`GET /index.html HTTP/1.1`|
|`%m`|Méthode HTTP|`GET`, `POST`, `PUT`|
|`%U`|URL demandée|`/admin/config.php`|
|`%q`|Query string|`?id=123&page=2`|
|`%H`|Protocole|`HTTP/1.1`|

#### Variables de réponse

|Variable|Description|Exemple|
|---|---|---|
|`%s`|Code de statut initial|`200`|
|`%>s`|Code de statut final|`200`, `301`, `404`|
|`%b`|Taille réponse (octets)|`2326` ou `-` si 0|
|`%B`|Taille réponse (0 si vide)|`2326` ou `0`|
|`%D`|Temps traitement (microsecondes)|`523142`|
|`%T`|Temps traitement (secondes)|`0`|
|`%{msec}t`|Timestamp en millisecondes|`1703166730123`|

#### En-têtes HTTP

|Variable|Description|Exemple|
|---|---|---|
|`%{Referer}i`|Page d'origine|`https://google.com`|
|`%{User-Agent}i`|Navigateur/bot|`Mozilla/5.0...`|
|`%{Cookie}i`|Cookies envoyés|`session=abc123`|
|`%{Accept-Language}i`|Langue acceptée|`fr-FR,fr;q=0.9`|
|`%{Host}i`|Nom de domaine|`www.exemple.com`|
|`%{Content-Type}o`|Type MIME envoyé|`text/html`|
|`%{X-Forwarded-For}i`|IP derrière proxy|`192.168.1.100`|

#### Variables serveur

|Variable|Description|Exemple|
|---|---|---|
|`%v`|Nom du serveur virtuel|`exemple.com`|
|`%V`|Nom canonique du serveur|`www.exemple.com`|
|`%p`|Port serveur|`80`, `443`|
|`%P`|PID du processus|`12345`|
|`%{pid}P`|PID du processus|`12345`|
|`%{tid}P`|Thread ID|`140234567890`|

> [!example] Exemple de format avancé
> 
> ```apache
> # Format complet pour analyse détaillée
> LogFormat "%h %l %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\" %D %v %p %{X-Forwarded-For}i" detailed
> CustomLog /var/log/apache2/detailed.log detailed
> ```

---

## 🔄 Rotation des logs

### Pourquoi faire de la rotation

Sans rotation, les fichiers de logs :

- **Grossissent indéfiniment** et peuvent saturer le disque
- **Ralentissent** l'écriture et la lecture
- **Deviennent difficiles** à analyser et archiver
- **Peuvent crasher** le serveur si le disque est plein

La rotation consiste à :

1. Archiver le fichier actuel
2. Créer un nouveau fichier vide
3. Compresser et/ou supprimer les anciens logs

> [!warning] Importance critique Un serveur sans rotation de logs finira par planter quand le disque sera plein. La rotation est **obligatoire** en production.

---

### Rotation avec logrotate

**logrotate** est l'outil standard sous Linux pour gérer la rotation automatique des logs.

#### Configuration de base

```bash
# Fichier : /etc/logrotate.d/apache2
/var/log/apache2/*.log {
    daily                    # Rotation quotidienne
    missingok               # Pas d'erreur si fichier absent
    rotate 14               # Garder 14 archives
    compress                # Compresser les anciennes archives
    delaycompress           # Ne pas compresser le dernier fichier
    notifempty              # Ne pas faire de rotation si vide
    create 640 root adm     # Permissions du nouveau fichier
    sharedscripts           # Exécuter les scripts qu'une fois
    postrotate
        /usr/sbin/apache2ctl graceful > /dev/null
    endscript
}
```

#### Options de fréquence

```apache
# Rotation quotidienne
daily

# Rotation hebdomadaire (le lundi)
weekly

# Rotation mensuelle (le 1er du mois)
monthly

# Rotation à partir d'une certaine taille
size 100M
# ou
size 1G
```

#### Configuration avancée

```bash
# Configuration complète avec options avancées
/var/log/apache2/access.log {
    daily
    rotate 30               # 30 jours d'archives
    compress
    delaycompress
    notifempty
    create 0640 www-data adm
    missingok
    dateext                 # Ajoute la date : access.log-20251221
    dateformat -%Y%m%d
    maxage 365              # Supprime après 1 an
    sharedscripts
    postrotate
        /usr/sbin/apache2ctl graceful > /dev/null 2>&1
    endscript
}

/var/log/apache2/error.log {
    weekly
    rotate 52               # 1 an d'archives
    compress
    delaycompress
    notifempty
    create 0640 www-data adm
    missingok
    dateext
    sharedscripts
    postrotate
        /usr/sbin/apache2ctl graceful > /dev/null 2>&1
    endscript
}

# Rotation par taille pour logs très actifs
/var/log/apache2/high-traffic-access.log {
    size 500M               # Rotation dès 500Mo
    rotate 10
    compress
    delaycompress
    notifempty
    create 0640 www-data adm
    missingok
    sharedscripts
    postrotate
        /usr/sbin/apache2ctl graceful > /dev/null 2>&1
    endscript
}
```

#### Commandes utiles

```bash
# Tester la configuration
sudo logrotate -d /etc/logrotate.d/apache2

# Forcer une rotation manuelle
sudo logrotate -f /etc/logrotate.d/apache2

# Vérifier le statut de logrotate
sudo cat /var/lib/logrotate/status

# Voir quand la dernière rotation a eu lieu
ls -lh /var/log/apache2/
```

> [!tip] Commande graceful `apache2ctl graceful` redémarre Apache en douceur sans couper les connexions existantes, permettant la rotation sans interruption de service.

---

### Rotation avec rotatelogs

**rotatelogs** est un utilitaire fourni avec Apache pour la rotation en temps réel.

#### Rotation par temps

```apache
# Rotation toutes les 24h (86400 secondes)
CustomLog "|/usr/bin/rotatelogs /var/log/apache2/access.log.%Y-%m-%d 86400" combined

# Rotation toutes les heures (3600 secondes)
ErrorLog "|/usr/bin/rotatelogs /var/log/apache2/error.log.%Y-%m-%d-%H 3600"

# Rotation toutes les semaines (604800 secondes)
CustomLog "|/usr/bin/rotatelogs /var/log/apache2/weekly.log.%Y-W%W 604800" combined
```

#### Rotation par taille

```apache
# Rotation tous les 100Mo
CustomLog "|/usr/bin/rotatelogs -l /var/log/apache2/access.log.%Y-%m-%d 100M" combined

# Rotation tous les 500Mo avec 10 fichiers max
CustomLog "|/usr/bin/rotatelogs -l -n 10 /var/log/apache2/access.log 500M" combined
```

#### Options de rotatelogs

```apache
# Format complet avec toutes les options
CustomLog "|/usr/bin/rotatelogs -l -f -n 15 /var/log/apache2/access.log.%Y-%m-%d 86400" combined
```

**Options** :

- `-l` : Utilise l'heure locale (pas UTC)
- `-f` : Force l'ouverture immédiate du fichier
- `-n X` : Garde maximum X fichiers
- `-t` : Tronque le fichier au lieu de le renommer

**Patterns de date** :

- `%Y` : Année (2025)
- `%m` : Mois (01-12)
- `%d` : Jour (01-31)
- `%H` : Heure (00-23)
- `%M` : Minute (00-59)
- `%S` : Seconde (00-59)
- `%W` : Numéro de semaine (00-53)

> [!info] Avantages de rotatelogs
> 
> - Rotation en temps réel sans redémarrage
> - Pas besoin de logrotate
> - Intégré directement à Apache
> 
> **Inconvénient** : pas de compression automatique

---

### Rotation avec cronolog

**cronolog** est une alternative à rotatelogs avec plus de flexibilité.

#### Installation

```bash
# Debian/Ubuntu
sudo apt-get install cronolog

# RedHat/CentOS
sudo yum install cronolog
```

#### Configuration

```apache
# Rotation quotidienne organisée par mois
CustomLog "|/usr/bin/cronolog /var/log/apache2/%Y/%m/%d/access.log" combined

# Rotation horaire
ErrorLog "|/usr/bin/cronolog /var/log/apache2/%Y/%m/%d/error-%H.log"

# Rotation par virtual host
<VirtualHost *:80>
    ServerName exemple.com
    CustomLog "|/usr/bin/cronolog /var/log/apache2/vhosts/exemple.com/%Y-%m-%d-access.log" combined
</VirtualHost>
```

#### Avantages

- Crée automatiquement la structure de répertoires
- Organisation hiérarchique par date
- Très flexible pour l'archivage
- Gestion de symbolic link pour le fichier actuel

```apache
# Avec symbolic link vers le fichier actuel
CustomLog "|/usr/bin/cronolog -l /var/log/apache2/current.log /var/log/apache2/%Y/%m/%d/access.log" combined
```

---

## ⚙️ Configuration avancée

### Logs conditionnels

Vous pouvez logger uniquement certaines requêtes selon des conditions.

```apache
# Ne pas logger les images
SetEnvIf Request_URI "\.(gif|jpg|jpeg|png|css|js)$" dontlog
CustomLog /var/log/apache2/access.log combined env=!dontlog

# Logger uniquement les erreurs
SetEnvIfNoCase Request_URI "^/api/" api_log
CustomLog /var/log/apache2/api-access.log combined env=api_log

# Ne pas logger les bots connus
SetEnvIf User-Agent "Googlebot" dontlog
SetEnvIf User-Agent "bingbot" dontlog
CustomLog /var/log/apache2/access.log combined env=!dontlog

# Logger séparément les erreurs 404
SetEnvIf Request_Status ^404$ error404
CustomLog /var/log/apache2/404.log combined env=error404
```

### Logs multiples

```apache
# Logger dans plusieurs fichiers simultanément
CustomLog /var/log/apache2/access.log combined
CustomLog /var/log/apache2/access-backup.log common
CustomLog "|/usr/bin/rotatelogs /var/log/apache2/rotated-%Y%m%d.log 86400" combined

# Logs par type de contenu
SetEnvIf Request_URI "\.php$" php_request
CustomLog /var/log/apache2/php-access.log combined env=php_request
```

### Logs par Virtual Host

```apache
# Chaque vhost a ses propres logs
<VirtualHost *:80>
    ServerName site1.com
    CustomLog /var/log/apache2/site1-access.log combined
    ErrorLog /var/log/apache2/site1-error.log
</VirtualHost>

<VirtualHost *:80>
    ServerName site2.com
    CustomLog /var/log/apache2/site2-access.log combined
    ErrorLog /var/log/apache2/site2-error.log
</VirtualHost>

# Tous les vhosts dans un seul fichier avec identification
LogFormat "%v %h %l %u %t \"%r\" %>s %b" vhost_combined
<VirtualHost *:80>
    ServerName site1.com
    CustomLog /var/log/apache2/all-vhosts.log vhost_combined
</VirtualHost>
```

### Envoi vers syslog

```apache
# Envoyer les logs vers syslog
CustomLog "|/usr/bin/logger -t apache -p local6.info" combined
ErrorLog syslog:local6
```

### Logs vers un serveur distant

```apache
# Via netcat (attention : non sécurisé)
CustomLog "|/bin/nc log-server.com 514" combined

# Via syslog-ng ou rsyslog (sécurisé)
ErrorLog syslog:local1
# Puis configurer syslog pour transférer vers serveur distant
```

---

## 🔍 Analyse et monitoring des logs

### Commandes utiles pour analyser les logs

```bash
# Voir les logs en temps réel
sudo tail -f /var/log/apache2/access.log
sudo tail -f /var/log/apache2/error.log

# Voir les 100 dernières lignes
sudo tail -n 100 /var/log/apache2/access.log

# Compter le nombre de requêtes
sudo wc -l /var/log/apache2/access.log

# Trouver les IP les plus actives
sudo awk '{print $1}' /var/log/apache2/access.log | sort | uniq -c | sort -rn | head -20

# Trouver les pages les plus demandées
sudo awk '{print $7}' /var/log/apache2/access.log | sort | uniq -c | sort -rn | head -20

# Voir les codes d'erreur
sudo awk '{print $9}' /var/log/apache2/access.log | sort | uniq -c | sort -rn

# Filtrer les erreurs 404
sudo grep ' 404 ' /var/log/apache2/access.log

# Voir les erreurs récentes
sudo grep error /var/log/apache2/error.log | tail -20

# Analyser les User-Agents (bots)
sudo awk -F'"' '{print $6}' /var/log/apache2/access.log | sort | uniq -c | sort -rn | head -20

# Bandwidth consommée par IP
sudo awk '{sum[$1] += $10} END {for (ip in sum) print ip, sum[ip]}' /var/log/apache2/access.log | sort -k2 -rn | head -20

# Temps de réponse moyens (si %D dans le format)
sudo awk '{sum+=$NF; count++} END {print sum/count/1000000 " secondes"}' /var/log/apache2/access.log
```

### Outils d'analyse

**GoAccess** : Analyseur de logs en temps réel

```bash
# Installation
sudo apt-get install goaccess

# Analyse en terminal
sudo goaccess /var/log/apache2/access.log -c

# Génération d'un rapport HTML
sudo goaccess /var/log/apache2/access.log -o /var/www/html/report.html --log-format=COMBINED

# En temps réel dans le terminal
sudo tail -f /var/log/apache2/access.log | goaccess -
```

**AWStats** : Statistiques détaillées

```bash
# Installation
sudo apt-get install awstats

# Configuration dans /etc/awstats/
# Génération du rapport
sudo /usr/lib/cgi-bin/awstats.pl -config=exemple.com -update
```

**Webalizer** : Génération de rapports HTML

```bash
sudo apt-get install webalizer
sudo webalizer -c /etc/webalizer/webalizer.conf
```

---

## ⚠️ Pièges courants

### 1. Oubli de rotation

> [!warning] Risque de saturation Sans rotation, les logs peuvent remplir tout le disque et crasher le serveur.
> 
> **Solution** : Toujours configurer logrotate ou rotatelogs.

### 2. Permissions incorrectes

```bash
# Erreur courante : Apache ne peut pas écrire dans le fichier
# Vérifier les permissions
ls -lh /var/log/apache2/

# Corriger si nécessaire
sudo chown www-data:adm /var/log/apache2/*.log
sudo chmod 640 /var/log/apache2/*.log
```

### 3. Logs trop verbeux

```apache
# Éviter le debug en production
# ❌ Mauvais
LogLevel debug

# ✅ Bon
LogLevel warn
```

### 4. Logger les fichiers statiques

```apache
# Cela surcharge inutilement les logs
# ❌ Logger toutes les requêtes incluant CSS, JS, images

# ✅ Exclure les statiques
SetEnvIf Request_URI "\.(gif|jpg|jpeg|png|css|js|ico|woff|woff2)$" dontlog
CustomLog /var/log/apache2/access.log combined env=!dontlog
```

### 5. Oublier de recharger Apache après modification

```bash
# Après changement de config des logs
sudo apache2ctl configtest
sudo systemctl reload apache2
```

### 6. Ne pas archiver avant suppression

> [!tip] Bonne pratique Avant de supprimer d'anciens logs, assurez-vous qu'ils ont été archivés ou que vous n'en avez plus besoin pour audit ou analyse.

```bash
# Archiver avant suppression
sudo tar -czf logs-backup-$(date +%Y%m%d).tar.gz /var/log/apache2/*.log.*
sudo mv logs-backup-*.tar.gz /backup/logs/
```

### 7. Format de log incompatible avec l'outil d'analyse

Si vous utilisez GoAccess, AWStats ou autre, vérifiez que votre format de log est compatible.

```apache
# GoAccess attend du combined par défaut
CustomLog /var/log/apache2/access.log combined
```

### 8. Ne pas monitorer l'espace disque

```bash
# Vérifier régulièrement l'espace disque
df -h /var/log

# Alerte si > 80%
if [ $(df /var/log | tail -1 | awk '{print $5}' | sed 's/%//') -gt 80 ]; then
    echo "ALERTE: Espace disque /var/log > 80%"
fi
```

---

> [!tip] Bonnes pratiques finales
> 
> 1. **Toujours** configurer la rotation des logs
> 2. Utiliser le format `combined` sauf besoin spécifique
> 3. Séparer les logs par Virtual Host en production
> 4. Monitorer l'espace disque régulièrement
> 5. Archiver les logs importants avant suppression
> 6. Utiliser `LogLevel warn` en production
> 7. Ne pas logger les fichiers statiques si non nécessaire
> 8. Tester la configuration avec `apache2ctl configtest`
> 9. Protéger les fichiers de logs (permissions 640)
> 10. Documenter votre configuration de logs

---

**🎯 Points clés à retenir :**

- Les **Access logs** enregistrent toutes les requêtes
- Les **Error logs** enregistrent les problèmes et erreurs
- Le format **combined** est le plus complet et universel
- La **rotation** est obligatoire pour éviter la saturation du disque
- **logrotate** est l'outil standard pour la rotation automatique
- Les logs sont essentiels pour le **monitoring**, le **debug** et l'**audit**