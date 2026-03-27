

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

## 🎯 Introduction au proxy web

### Qu'est-ce qu'un proxy web ?

Un **proxy web** est un serveur intermédiaire qui se place entre les clients (navigateurs) et les serveurs web de destination. Il intercepte les requêtes HTTP/HTTPS des utilisateurs et les transmet aux serveurs distants.

> [!info] Pourquoi utiliser un proxy ?
> 
> - **Contrôle d'accès** : Filtrer les sites autorisés/interdits
> - **Sécurité** : Scanner le contenu, bloquer les malwares
> - **Performance** : Mise en cache des contenus fréquents
> - **Traçabilité** : Logs détaillés de la navigation
> - **Économie de bande passante** : Réduction du trafic Internet

### Modes de fonctionnement

|Mode|Description|Avantages|Inconvénients|
|---|---|---|---|
|**Proxy explicite**|Les clients configurent manuellement le proxy|Contrôle total, statistiques précises|Configuration sur chaque poste|
|**Proxy transparent**|Redirection automatique du trafic|Aucune configuration client|Complexité technique, problèmes HTTPS|
|**Proxy inverse**|Protège les serveurs web internes|Sécurité serveur, load balancing|Hors scope de ce cours|

> [!warning] Important Dans un environnement pfSense, le proxy transparent est le mode le plus utilisé car il ne nécessite aucune configuration côté client.

---

## 🦑 Squid Proxy

### Présentation de Squid

**Squid** est le serveur proxy le plus populaire dans le monde open source. Il supporte HTTP, HTTPS, FTP et d'autres protocoles.

> [!tip] Pourquoi Squid sur pfSense ?
> 
> - Intégration native via package
> - Performance éprouvée
> - Cache disque efficace
> - Support SSL/TLS inspection
> - Communauté active

### Installation de Squid

1. **Accéder au gestionnaire de packages** :
    
    - Menu : `System` → `Package Manager` → `Available Packages`
    - Rechercher : `squid`
    - Cliquer sur `Install` pour le package **squid**
2. **Vérification de l'installation** :
    
    - Menu : `Services` → `Squid Proxy Server`
    - L'interface de configuration doit apparaître

### Configuration de base de Squid

#### Onglet "General Settings"

```plaintext
Enable Squid Proxy: ☑ Coché
Keep Settings/Data: ☑ Coché (pour conserver config lors des mises à jour)
Proxy Interface(s): LAN (sélectionner l'interface interne)
Proxy Port: 3128 (port standard, modifiable)
Allow Users on Interface: ☑ Coché
Suppress Squid Version: ☑ Coché (sécurité)
Enable Access Logging: ☑ Coché (pour audit)
Log Rotate: 7 days (conservation des logs)
```

> [!example] Exemple de configuration minimale
> 
> ```
> Interface: LAN
> Port: 3128
> Cache: 100 MB (RAM), 500 MB (Disque)
> Logging: Activé
> ```

#### Paramètres du cache

```plaintext
Hard Disk Cache Size: 500 (en MB, selon espace disque disponible)
Hard Disk Cache System: ufs (par défaut, stable)
Memory Cache Size: 256 (en MB, selon RAM disponible)
Maximum Object Size: 4 (en MB)
Minimum Object Size: 0
```

> [!info] Dimensionnement du cache
> 
> - **RAM** : Allouer 10-20% de la RAM système
> - **Disque** : Dépend de l'espace disponible (500 MB à plusieurs GB)
> - **Objets** : Limiter la taille max pour éviter de saturer le cache

#### ACL (Access Control Lists)

Les ACL définissent qui peut utiliser le proxy et comment.

```plaintext
Allowed Subnets: 192.168.1.0/24 (réseau LAN autorisé)
Unrestricted IPs: (laisser vide ou IPs sans restriction)
Banned Hosts: (domaines/IPs à bloquer)
Whitelist: (domaines toujours autorisés)
Blacklist: (domaines toujours bloqués)
```

> [!warning] Ordre d'évaluation Squid évalue les règles dans cet ordre :
> 
> 1. Whitelist (autorise toujours)
> 2. Blacklist (bloque toujours)
> 3. ACL par défaut
> 4. Règles Squidguard (si installé)

---

## 🔍 Configuration du proxy transparent

### Principe du proxy transparent

En mode transparent, pfSense intercepte automatiquement le trafic HTTP/HTTPS des clients et le redirige vers Squid **sans configuration côté client**.

> [!info] Comment ça fonctionne ?
> 
> 1. Client envoie une requête HTTP vers Internet (port 80)
> 2. pfSense intercepte via règle firewall (redirection NAT)
> 3. Trafic redirigé vers Squid (port 3128)
> 4. Squid traite et renvoie au client de manière transparente

### Activation du mode transparent

#### Dans Squid (onglet "General Settings")

```plaintext
Transparent HTTP Proxy: ☑ Coché
Enable SSL/MITM Mode: ☐ Décoché (ou coché selon besoins HTTPS)
SSL/MITM Mode: Splice All (si HTTPS inspection non nécessaire)
CA: (générer un CA si inspection HTTPS requise)
```

> [!warning] HTTPS et mode transparent Le mode transparent fonctionne nativement pour HTTP (port 80). Pour HTTPS (port 443), il faut :
> 
> - Activer **SSL/MITM Mode**
> - Installer le certificat CA sur tous les clients
> - Attention aux implications légales et de confidentialité !

#### Configuration firewall pour la transparence

**Règle NAT (Port Forward)** :

1. Menu : `Firewall` → `NAT` → `Port Forward`
2. Cliquer sur `Add` (flèche vers le haut pour position haute)

```plaintext
Interface: LAN
Protocol: TCP
Source: LAN net
Destination: any
Destination Port Range: HTTP (80)
Redirect Target IP: 127.0.0.1
Redirect Target Port: 3128
Description: Transparent HTTP Proxy Redirect
```

3. Enregistrer et appliquer les changements

> [!tip] Pour HTTPS transparent (si nécessaire) Créer une règle identique mais avec :
> 
> ```
> Destination Port Range: HTTPS (443)
> Redirect Target Port: 3129 (port SSL Squid)
> ```

**Règle firewall LAN** :

Automatiquement créée par la règle NAT, vérifier dans `Firewall` → `Rules` → `LAN` :

```plaintext
Action: Pass
Interface: LAN
Protocol: TCP
Source: LAN net
Destination: 127.0.0.1
Destination Port: 3128
Description: Allow traffic to Squid proxy
```

### Vérification du fonctionnement transparent

#### Test depuis un client

```bash
# Vérifier l'IP publique vue (doit être celle du pfSense)
curl -I http://www.google.com

# Consulter les logs Squid sur pfSense
# Menu : Status → System Logs → Squid
# Vous devez voir les requêtes des clients
```

> [!example] Log Squid typique
> 
> ```
> 1704902400.123   145 192.168.1.50 TCP_MISS/200 12345 GET http://www.example.com/ - HIER_DIRECT/93.184.216.34 text/html
> ```
> 
> - `192.168.1.50` : IP du client
> - `TCP_MISS` : Objet non en cache
> - `200` : Code HTTP succès
> - `http://www.example.com/` : URL demandée

#### Diagnostic en cas de problème

```bash
# Sur pfSense, vérifier que Squid écoute
sockstat -4 -l | grep 3128

# Tester la redirection NAT
pfctl -s nat | grep 3128

# Vérifier les logs Squid en temps réel
tail -f /var/squid/logs/access.log
```

---

## 🛡️ Squidguard pour le filtrage

### Présentation de Squidguard

**Squidguard** est un plugin de filtrage de contenu pour Squid. Il permet de bloquer l'accès à des sites selon des **catégories** prédéfinies ou personnalisées.

> [!info] Cas d'usage de Squidguard
> 
> - **Entreprise** : Bloquer réseaux sociaux pendant heures de travail
> - **École** : Filtrer contenu adulte, violence, jeux
> - **Laboratoire** : Bloquer sites de streaming pour économiser bande passante
> - **Conformité** : Respecter obligations légales de filtrage

### Installation de Squidguard

1. **Package Manager** : `System` → `Package Manager` → `Available Packages`
2. Rechercher : `squidguard`
3. Installer : **squidGuard**

> [!warning] Dépendance Squidguard nécessite que **Squid** soit déjà installé et fonctionnel.

### Configuration de base

Menu : `Services` → `SquidGuard Proxy Filter`

#### Onglet "General Settings"

```plaintext
Enable: ☑ Coché
Enable GUI Log: ☑ Coché (pour voir les blocages dans l'interface)
Enable Log: ☑ Coché
Enable Log Rotation: ☑ Coché
Log Rotation Time: 1 week
```

#### Onglet "Common ACL"

Définit les règles par défaut pour tous les utilisateurs.

```plaintext
Target Rules List:
  - Sélectionner les catégories à bloquer (ads, porn, warez, etc.)
  
Do not allow IP-Addresses in URL: ☑ Coché (empêche contournement)
Use SafeSearch engine: ☑ Coché (force SafeSearch Google, Bing, etc.)
```

> [!tip] SafeSearch Active automatiquement le filtrage des résultats adultes sur les moteurs de recherche. Utile en complément du filtrage par catégorie.

#### Redirection des pages bloquées

```plaintext
Redirect mode: INT redirect page (page interne pfSense)
ou
Redirect mode: EXT redirect page
Redirect URL: http://www.example.com/blocked.html (page personnalisée)
```

> [!example] Message de blocage personnalisé Créer une page HTML simple :
> 
> ```html
> <!DOCTYPE html>
> <html>
> <head><title>Accès refusé</title></head>
> <body>
>   <h1>🚫 Accès refusé</h1>
>   <p>Cette page a été bloquée par la politique de sécurité.</p>
>   <p>Contact : admin@entreprise.fr</p>
> </body>
> </html>
> ```
> 
> Héberger sur un serveur web interne ou externe.

### Groupes et horaires

Squidguard permet de créer des règles différentes selon les groupes d'utilisateurs et les plages horaires.

#### Créer un groupe

Onglet "Group ACL" → Add

```plaintext
Group Name: Employes
Client (source):
  - 192.168.1.0/24 (plage IP du groupe)
  ou IPs individuelles
  
Target Rules:
  - Bloquer : ads, porn, socialnet
  - Autoriser : news, business
  
Time constraints: (optionnel)
  - Bloquer socialnet uniquement 9h-17h en semaine
```

#### Définir des plages horaires

Onglet "Times" → Add

```plaintext
Name: Heures_travail
Time Range:
  - Days: Mon Tue Wed Thu Fri
  - Start: 09:00
  - End: 17:00
```

Appliquer ensuite dans les règles de groupe.

---

## 📋 Listes noires et catégories

### Sources de listes noires

Les listes noires (blacklists) sont des bases de données de domaines classés par catégories.

> [!info] Principales sources gratuites
> 
> - **Shallalist** : Base complète, mise à jour régulière
> - **UT1** (Université Toulouse) : Catégorisation française
> - **Blocklist.de** : Orienté sécurité
> - **URLBlacklist.com** : Version payante mais très complète

### Télécharger et installer une blacklist

#### Méthode automatique (recommandée)

Menu : `Services` → `SquidGuard Proxy Filter` → `Blacklist`

```plaintext
Blacklist URL: http://www.shallalist.de/Downloads/shallalist.tar.gz
Description: Shallalist blacklist
```

Cliquer sur `Download` → Le téléchargement et l'extraction se font automatiquement.

> [!warning] Espace disque Les blacklists complètes peuvent peser 50-200 MB décompressées. Vérifier l'espace disponible sur pfSense.

#### Méthode manuelle

Si le téléchargement automatique échoue :

```bash
# Sur pfSense, via SSH
cd /var/db/squidguard
fetch http://www.shallalist.de/Downloads/shallalist.tar.gz
tar -xzf shallalist.tar.gz
chown -R proxy:proxy BL/
```

### Catégories disponibles

Exemple de catégories Shallalist :

|Catégorie|Description|Usage typique|
|---|---|---|
|`ads`|Publicités, bannières|Bloquer (performance + vie privée)|
|`porn`|Contenu adulte|Bloquer (entreprise, école)|
|`socialnet`|Réseaux sociaux|Bloquer pendant heures de travail|
|`warez`|Téléchargement illégal|Bloquer (légalité + sécurité)|
|`gamble`|Jeux d'argent|Bloquer (entreprise)|
|`violence`|Violence, armes|Bloquer (école)|
|`drugs`|Drogues|Bloquer (école, entreprise)|
|`hacking`|Sites de hacking|Bloquer ou autoriser selon contexte|
|`news`|Actualités|Autoriser généralement|
|`education`|Éducation|Autoriser|

### Activer les catégories

Onglet "Common ACL" ou "Group ACL"

```plaintext
Target Rules List:
  Deny:
    - ads
    - porn
    - socialnet (sauf en dehors heures travail)
    - warez
    - gamble
  
  Allow:
    - news
    - education
    - business
  
  Whitelist: (domaines jamais bloqués)
    - *.entreprise.com
    - *.microsoft.com
```

> [!tip] Stratégie de filtrage **Approche permissive** : Tout autoriser sauf catégories dangereuses (porn, warez) **Approche restrictive** : Tout bloquer sauf catégories autorisées (whitelist stricte)
> 
> Choisir selon le contexte et la culture de l'organisation.

### Personnaliser les listes

#### Créer une blacklist personnalisée

Menu : `Services` → `SquidGuard Proxy Filter` → `Target categories` → `Add`

```plaintext
Name: Sites_interdits_entreprise
Domains:
  facebook.com
  twitter.com
  youtube.com
  netflix.com

Expressions: (regex, optionnel)
  .*gambling.*
  .*casino.*
```

#### Créer une whitelist personnalisée

Même processus, mais utiliser dans les règles ACL comme "Allow".

```plaintext
Name: Sites_autorises_travail
Domains:
  linkedin.com
  github.com
  stackoverflow.com
  slack.com
```

> [!example] Regex utiles
> 
> ```regex
> .*\.mp3$          # Bloquer fichiers MP3
> .*\.exe$          # Bloquer exécutables
> .*torrent.*       # Bloquer torrents
> ^https?://[0-9]   # Bloquer accès par IP (bypass DNS)
> ```

### Mise à jour des blacklists

Les listes noires doivent être régulièrement mises à jour pour rester efficaces.

#### Mise à jour manuelle

Menu : `Blacklist` → Cliquer sur `Download` à nouveau

#### Mise à jour automatique (cron)

Menu : `System` → `Package Manager` → `Installed Packages` → `Cron`

Créer une tâche :

```plaintext
Minute: 0
Hour: 3
Day of Month: *
Month: *
Day of Week: 0 (Dimanche)
User: root
Command: /usr/local/pkg/squidguard_blacklist.sh
```

> [!warning] Redémarrage requis Après mise à jour d'une blacklist, redémarrer Squidguard :
> 
> ```bash
> /usr/local/etc/rc.d/squidguard.sh restart
> ```

---

## ⚠️ Pièges courants et bonnes pratiques

### Pièges à éviter

> [!warning] Problèmes fréquents

**1. Proxy transparent et HTTPS**

```
Symptôme : Sites HTTPS ne se chargent pas en mode transparent
Cause : Certificat SSL non installé sur clients
Solution : 
  - Désactiver transparent pour HTTPS
  - OU générer CA, déployer certificat via GPO/MDM
  - OU utiliser mode "Splice All" (pas d'inspection SSL)
```

**2. Boucle de redirection**

```
Symptôme : Clients ne peuvent plus naviguer, timeout
Cause : Règle NAT redirige aussi le trafic de pfSense lui-même
Solution : 
  - Exclure IP pfSense de la règle NAT
  - Ou utiliser "Destination: !LAN address" dans règle NAT
```

**3. Cache Squid saturé**

```
Symptôme : Performances dégradées, disque plein
Cause : Cache disque trop gros ou jamais purgé
Solution :
  - Limiter cache disque (500 MB - 2 GB max)
  - Activer log rotation
  - Commande manuelle : squid -k rotate
```

**4. Blacklist obsolète**

```
Symptôme : Sites malveillants non bloqués
Cause : Blacklist non mise à jour depuis des mois
Solution :
  - Configurer mise à jour hebdomadaire automatique
  - Vérifier dernière mise à jour dans logs
```

**5. Ordre des règles ACL incorrect**

```
Symptôme : Règles de filtrage ne s'appliquent pas comme prévu
Cause : Whitelist après blacklist, ou inversement
Solution :
  - Toujours : Whitelist → Blacklist → ACL générales
  - Tester avec "Enable GUI Log" pour voir ce qui bloque
```

### Bonnes pratiques

> [!tip] Recommandations

**Sécurité**

```plaintext
✓ Supprimer la version Squid des headers (Suppress Squid Version)
✓ Bloquer accès par IP directe (Do not allow IP-Addresses in URL)
✓ Activer SafeSearch sur moteurs de recherche
✓ Logger toutes les requêtes (conformité + audit)
✓ Changer le port proxy si exposition externe (éviter 3128)
```

**Performance**

```plaintext
✓ Dimensionner cache selon trafic :
  - PME (10-50 users) : 256 MB RAM, 500 MB disque
  - Entreprise (50-200 users) : 512 MB RAM, 2 GB disque
  - Grande structure (200+ users) : Envisager proxy dédié

✓ Activer compression HTTP si Squid récent
✓ Limiter taille max objets en cache (4-10 MB)
✓ Purger cache régulièrement (hebdo/mensuel)
```

**Gestion des utilisateurs**

```plaintext
✓ Créer des groupes selon départements/rôles
✓ Appliquer règles différentes par groupe
✓ Communiquer clairement la politique de filtrage
✓ Prévoir procédure de déblocage temporaire
✓ Former les utilisateurs aux règles et exceptions
```

**Monitoring**

```plaintext
✓ Vérifier logs Squid quotidiennement (Top sites, Top users)
✓ Monitorer utilisation bande passante (cache hit rate)
✓ Alerter sur tentatives accès sites interdits
✓ Auditer règles de filtrage trimestriellement
✓ Tester règles après chaque modification
```

**Backup et documentation**

```plaintext
✓ Sauvegarder configuration Squid/Squidguard régulièrement
✓ Documenter règles personnalisées et raisons
✓ Conserver historique des blacklists utilisées
✓ Tester restauration de config sur VM de test
```

### Astuces avancées

> [!tip] Optimisations

**1. Bypass proxy pour certains sites**

Si certains sites posent problème avec le proxy (applications spécifiques, sites bancaires) :

```plaintext
# Dans Squid → ACL → Whitelist
*.banque-entreprise.fr
*.site-metier-critique.com

# Ou créer règle firewall LAN avant la règle NAT transparent
# qui autorise ces domaines en direct (pass)
```

**2. Proxy authentifié (non-transparent)**

Pour traçabilité renforcée, forcer authentification :

```plaintext
# Squid → General Settings
Transparent HTTP Proxy: ☐ Décoché
Authentication Method: LDAP/Active Directory
LDAP Server: 192.168.1.10
LDAP Base DN: dc=entreprise,dc=local
```

**3. Logs Squid vers syslog externe**

Centraliser les logs pour analyse :

```plaintext
# Menu : Status → System Logs → Settings
Enable Remote Logging: ☑ Coché
Remote Log Server 1: 192.168.1.100:514
```

**4. Statistiques de cache**

Analyser l'efficacité du cache :

```bash
# Via SSH sur pfSense
squidclient mgr:info | grep -i "hit"

# Résultat exemple :
# Request Hit Ratios: 5min: 28.3%, 60min: 31.7%
# Byte Hit Ratios:    5min: 22.1%, 60min: 25.4%
```

Un bon hit rate est > 25% (plus = mieux).

**5. Bloquer téléchargements volumineux**

Économiser bande passante :

```plaintext
# Squid → Traffic Management
Maximum Download Size: 100 (MB)
# Fichiers > 100 MB seront bloqués
```

---

## 🎓 Récapitulatif

Vous maîtrisez maintenant :

- ✅ Installation et configuration de **Squid Proxy** sur pfSense
- ✅ Mise en place du **mode transparent** avec redirection NAT
- ✅ Installation et configuration de **Squidguard** pour filtrage
- ✅ Gestion des **blacklists** et catégories de filtrage
- ✅ Création de règles personnalisées et groupes d'utilisateurs
- ✅ Bonnes pratiques de sécurité, performance et monitoring

Le proxy web et le filtrage de contenu sont des outils essentiels pour contrôler et sécuriser l'accès Internet dans un réseau d'entreprise ou institutionnel. La combinaison Squid + Squidguard offre une solution robuste et flexible, adaptable à tous types de besoins.

> [!info] Pour aller plus loin
> 
> - Expérimenter avec différentes blacklists (Shallalist, UT1)
> - Tester l'inspection SSL/TLS pour filtrage HTTPS (attention légalité)
> - Intégrer avec Active Directory pour authentification transparente
> - Analyser les logs avec des outils comme Splunk ou ELK

---

_Cours rédigé pour Obsidian - pfSense Services réseau essentiels - Partie 1/X_