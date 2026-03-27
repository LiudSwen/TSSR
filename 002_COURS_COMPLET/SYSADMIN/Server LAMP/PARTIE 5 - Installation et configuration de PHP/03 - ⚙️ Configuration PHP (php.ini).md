

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

## 🎯 Introduction

Le fichier **php.ini** est le fichier de configuration principal de PHP. Il contrôle le comportement de l'interpréteur PHP et définit des limites importantes pour l'exécution des scripts, la gestion des erreurs, et bien d'autres aspects.

> [!info] Pourquoi configurer php.ini ?
> 
> - **Sécurité** : Contrôler l'affichage des erreurs en production
> - **Performance** : Ajuster la mémoire disponible pour les scripts
> - **Fonctionnalités** : Permettre l'upload de fichiers volumineux
> - **Stabilité** : Adapter PHP aux besoins spécifiques de vos applications

---

## 📍 Localisation du fichier php.ini

PHP peut utiliser différents fichiers php.ini selon le contexte d'exécution (CLI vs serveur web). Il est crucial de savoir quel fichier est réellement utilisé.

### Trouver le fichier php.ini actif

```bash
# Méthode 1 : Via la ligne de commande
php --ini

# Sortie attendue :
# Configuration File (php.ini) Path: /etc/php/8.1/cli
# Loaded Configuration File:         /etc/php/8.1/cli/php.ini
# Scan for additional .ini files in: /etc/php/8.1/cli/conf.d
```

```bash
# Méthode 2 : Via phpinfo() (pour le serveur web)
# Créer un fichier info.php dans /var/www/html/
echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/info.php

# Accéder ensuite à http://votre-serveur/info.php
# Rechercher la ligne "Loaded Configuration File"
```

> [!warning] Fichiers multiples PHP utilise généralement deux fichiers php.ini distincts :
> 
> - `/etc/php/X.X/cli/php.ini` : Pour les scripts en ligne de commande
> - `/etc/php/X.X/apache2/php.ini` : Pour les scripts exécutés via Apache
> 
> Modifiez le bon fichier selon votre contexte !

### Emplacements courants

|Distribution|Chemin Apache|Chemin CLI|
|---|---|---|
|Ubuntu/Debian|`/etc/php/8.1/apache2/php.ini`|`/etc/php/8.1/cli/php.ini`|
|CentOS/RHEL|`/etc/php.ini`|`/etc/php.ini`|
|Arch Linux|`/etc/php/php.ini`|`/etc/php/php.ini`|

> [!tip] Astuce Après avoir trouvé votre fichier php.ini, faites-en une sauvegarde avant toute modification :
> 
> ```bash
> sudo cp /etc/php/8.1/apache2/php.ini /etc/php/8.1/apache2/php.ini.backup
> ```

---

## 🔧 Directives importantes

### memory_limit

La directive **memory_limit** définit la quantité maximale de mémoire qu'un script PHP peut consommer.

#### Concept et utilité

Cette limite protège le serveur contre les scripts mal optimisés qui pourraient consommer toute la RAM disponible et bloquer le système. C'est une mesure de sécurité essentielle.

```ini
; Syntaxe dans php.ini
memory_limit = 128M
```

#### Valeurs recommandées

|Contexte|Valeur recommandée|Justification|
|---|---|---|
|Site vitrine simple|64M - 128M|Peu de traitement de données|
|Application web classique|128M - 256M|Valeur standard équilibrée|
|CMS (WordPress, Drupal)|256M - 512M|Beaucoup de plugins et traitements|
|Application complexe|512M - 1G|Traitement d'images, exports massifs|

> [!example] Exemple de configuration
> 
> ```ini
> ; Configuration pour un WordPress avec plusieurs plugins
> memory_limit = 256M
> ```

#### Modification de la directive

```bash
# Ouvrir le fichier php.ini
sudo nano /etc/php/8.1/apache2/php.ini

# Rechercher la ligne memory_limit (Ctrl+W dans nano)
# Modifier la valeur
memory_limit = 256M

# Sauvegarder (Ctrl+O) et quitter (Ctrl+X)
```

> [!warning] Piège courant Augmenter memory_limit sans analyser pourquoi votre script consomme autant de mémoire peut masquer un problème de performance ou une fuite mémoire. Analysez d'abord votre code avant d'augmenter cette limite aveuglément.

> [!tip] Vérification dynamique Vous pouvez vérifier la limite actuelle dans vos scripts PHP :
> 
> ```php
> <?php
> echo ini_get('memory_limit'); // Affiche : 256M
> ?>
> ```

---

### upload_max_filesize

La directive **upload_max_filesize** définit la taille maximale d'un fichier individuel qui peut être uploadé via un formulaire HTML.

#### Concept et utilité

Cette limite empêche les utilisateurs d'uploader des fichiers trop volumineux qui pourraient saturer votre espace disque ou votre bande passante. Elle protège également contre certaines attaques par déni de service.

```ini
; Syntaxe dans php.ini
upload_max_filesize = 2M
```

#### Valeurs recommandées

|Usage|Valeur recommandée|Exemple|
|---|---|---|
|Formulaire contact simple|2M - 5M|Documents PDF, images|
|Galerie photos|10M - 20M|Photos haute résolution|
|Plateforme de partage|50M - 100M|Vidéos courtes, archives|
|Stockage cloud personnel|500M - 2G|Fichiers volumineux|

> [!example] Exemple de configuration
> 
> ```ini
> ; Configuration pour une galerie d'images professionnelles
> upload_max_filesize = 20M
> ```

#### Modification de la directive

```bash
# Éditer php.ini
sudo nano /etc/php/8.1/apache2/php.ini

# Rechercher upload_max_filesize
upload_max_filesize = 20M
```

> [!warning] Attention à la cohérence La directive **upload_max_filesize** doit TOUJOURS être inférieure ou égale à **post_max_size** (voir section suivante). Si ce n'est pas le cas, l'upload échouera silencieusement !

---

### post_max_size

La directive **post_max_size** définit la taille maximale des données POST, c'est-à-dire l'ensemble du contenu d'un formulaire incluant tous les fichiers uploadés.

#### Concept et utilité

Lorsqu'un formulaire est soumis, toutes les données (champs texte, fichiers, etc.) sont envoyées en une seule requête POST. Cette directive limite la taille totale de cette requête.

```ini
; Syntaxe dans php.ini
post_max_size = 8M
```

#### Relation avec upload_max_filesize

```
┌─────────────────────────────────────┐
│       post_max_size = 50M           │  ← Taille totale du formulaire
│  ┌──────────────────────────────┐   │
│  │  upload_max_filesize = 20M   │   │  ← Taille d'un fichier individuel
│  │  ┌────────┐ ┌────────┐       │   │
│  │  │Fichier1│ │Fichier2│ + txt │   │
│  │  │  15M   │ │  12M   │  3M   │   │
│  │  └────────┘ └────────┘       │   │
│  └──────────────────────────────┘   │
└─────────────────────────────────────┘
```

> [!info] Règle d'or **post_max_size** doit être supérieur à **upload_max_filesize**
> 
> Formule recommandée : `post_max_size = (upload_max_filesize × nombre_fichiers) + marge`

#### Valeurs recommandées

|Scénario|Configuration|Explication|
|---|---|---|
|Upload simple (1 fichier)|`upload_max_filesize = 20M`<br>`post_max_size = 25M`|Marge de 5M pour les métadonnées|
|Upload multiple (3 fichiers)|`upload_max_filesize = 20M`<br>`post_max_size = 65M`|(20M × 3) + 5M de marge|
|Formulaire complexe|`upload_max_filesize = 10M`<br>`post_max_size = 50M`|Plusieurs fichiers + nombreux champs texte|

> [!example] Exemple de configuration complète
> 
> ```ini
> ; Configuration pour un formulaire avec plusieurs fichiers
> upload_max_filesize = 20M
> post_max_size = 50M
> ```

#### Modification de la directive

```bash
# Éditer php.ini
sudo nano /etc/php/8.1/apache2/php.ini

# Configurer les deux directives de manière cohérente
upload_max_filesize = 20M
post_max_size = 50M
```

> [!tip] Astuce de dépannage Si vos uploads échouent sans message d'erreur :
> 
> 1. Vérifiez que `post_max_size >= upload_max_filesize`
> 2. Vérifiez les logs Apache : `sudo tail -f /var/log/apache2/error.log`
> 3. Activez temporairement `display_errors = On` pour voir les erreurs PHP

---

## 🐛 Gestion des erreurs

La gestion des erreurs PHP est cruciale pour le développement et la sécurité en production. Deux directives principales contrôlent ce comportement.

### display_errors

La directive **display_errors** contrôle si les erreurs PHP sont affichées directement dans le navigateur.

#### Concept et utilité

En développement, voir les erreurs immédiatement est indispensable pour déboguer. En production, afficher les erreurs expose des informations sensibles sur votre infrastructure (chemins de fichiers, structure de base de données, versions de logiciels) aux utilisateurs et aux attaquants potentiels.

```ini
; Syntaxe dans php.ini
display_errors = Off
```

#### Valeurs et contextes

|Valeur|Environnement|Justification|
|---|---|---|
|`On`|Développement local|Débogage rapide et efficace|
|`Off`|Production|Sécurité et professionnalisme|
|`stderr`|Scripts CLI|Erreurs dans le terminal, pas dans la sortie|

> [!warning] Danger en production ! **Ne JAMAIS laisser display_errors = On en production**
> 
> Conséquences possibles :
> 
> - Exposition de chemins système
> - Révélation de noms de tables et colonnes SQL
> - Affichage de versions de logiciels (vulnérabilités connues)
> - Expérience utilisateur dégradée
> - Non-conformité RGPD (fuite potentielle de données)

#### Configuration recommandée

```ini
; === ENVIRONNEMENT DE DÉVELOPPEMENT ===
display_errors = On
error_reporting = E_ALL

; === ENVIRONNEMENT DE PRODUCTION ===
display_errors = Off
log_errors = On
error_log = /var/log/php/error.log
error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT
```

> [!example] Exemple de risque sécuritaire Avec `display_errors = On`, une erreur SQL affichera :
> 
> ```
> Fatal error: Uncaught mysqli_sql_exception: Table 'myapp.users' 
> doesn't exist in /var/www/html/includes/database.php:42
> ```
> 
> Un attaquant apprend :
> 
> - Le chemin complet du code source
> - Le nom de la base de données (myapp)
> - Le nom d'une table (users)
> - Le système de base de données utilisé (MySQL)

---

### error_reporting

La directive **error_reporting** définit quels types d'erreurs PHP doivent être rapportés (affichés ou loggés).

#### Concept et utilité

PHP génère différents niveaux d'erreurs : des simples avertissements aux erreurs fatales. Cette directive vous permet de filtrer ce qui doit être considéré comme une erreur.

```ini
; Syntaxe dans php.ini
error_reporting = E_ALL
```

#### Niveaux d'erreurs PHP

|Niveau|Description|Exemple|
|---|---|---|
|`E_ERROR`|Erreurs fatales (arrêt du script)|Appel de fonction inexistante|
|`E_WARNING`|Avertissements (script continue)|Inclusion d'un fichier manquant|
|`E_PARSE`|Erreurs de syntaxe|Oubli d'un point-virgule|
|`E_NOTICE`|Notifications (problèmes mineurs)|Variable non initialisée|
|`E_DEPRECATED`|Fonctions obsolètes|Utilisation de fonctions dépréciées|
|`E_STRICT`|Recommandations de code|Suggestions d'amélioration|
|`E_ALL`|Tous les types d'erreurs|Combinaison de tous les niveaux|

#### Combinaisons avec opérateurs

PHP utilise des opérateurs binaires pour combiner les niveaux d'erreurs :

```ini
; Opérateur | (OU) : Inclure plusieurs types
error_reporting = E_ERROR | E_WARNING | E_PARSE

; Opérateur & (ET) : Combiner avec exclusion
; Opérateur ~ (NON) : Exclure un type

; Tout afficher sauf les avertissements d'obsolescence et strict
error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT
```

#### Configurations par environnement

```ini
; === DÉVELOPPEMENT : Tout afficher ===
error_reporting = E_ALL
; Raison : Détecter tous les problèmes, même mineurs

; === STAGING : Tout sauf notices ===
error_reporting = E_ALL & ~E_NOTICE
; Raison : Environnement proche de la prod, ignorer les petits warnings

; === PRODUCTION : Seulement les erreurs critiques ===
error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT & ~E_NOTICE
; Raison : Logger uniquement ce qui peut casser l'application
```

> [!info] Bonne pratique Même en production avec `display_errors = Off`, gardez un `error_reporting` élevé et activez `log_errors = On`. Ainsi, toutes les erreurs sont enregistrées dans les logs pour analyse ultérieure, sans être exposées aux utilisateurs.

> [!example] Exemple complet de configuration
> 
> ```ini
> ; Configuration de développement
> [Development]
> display_errors = On
> error_reporting = E_ALL
> log_errors = On
> error_log = /var/log/php/dev-error.log
> 
> ; Configuration de production
> [Production]
> display_errors = Off
> error_reporting = E_ALL & ~E_DEPRECATED & ~E_STRICT
> log_errors = On
> error_log = /var/log/php/prod-error.log
> ```

#### Vérification de la configuration

```bash
# Créer un script de test
echo "<?php
error_reporting(E_ALL);
ini_set('display_errors', 1);

// Déclencher volontairement une notice
echo \$variable_non_definie;

// Déclencher un warning
include('fichier_inexistant.php');
?>" | sudo tee /var/www/html/test_errors.php

# Accéder à http://votre-serveur/test_errors.php
# Vous devriez voir les erreurs s'afficher
```

> [!tip] Modification dynamique Vous pouvez temporairement changer ces paramètres dans un script :
> 
> ```php
> <?php
> // Activer l'affichage d'erreurs pour ce script uniquement
> ini_set('display_errors', 1);
> ini_set('error_reporting', E_ALL);
> ?>
> ```

---

## 🌍 Configuration du fuseau horaire

### date.timezone

La directive **date.timezone** définit le fuseau horaire par défaut utilisé par toutes les fonctions de date et d'heure de PHP.

#### Concept et utilité

Sans fuseau horaire défini, PHP génère des avertissements et utilise par défaut UTC. Cela peut créer des incohérences dans l'affichage des dates et heures, particulièrement pour les applications localisées.

```ini
; Syntaxe dans php.ini
date.timezone = "Europe/Paris"
```

#### Importance de la configuration

```php
// SANS date.timezone configuré :
<?php
echo date('H:i'); // Affiche l'heure en UTC + WARNING
?>
// Résultat : 14:30 + Warning: date(): It is not safe to rely on...

// AVEC date.timezone = "Europe/Paris" :
<?php
echo date('H:i'); // Affiche l'heure en Europe/Paris, pas de warning
?>
// Résultat : 16:30 (si UTC+2 en été)
```

#### Fuseaux horaires courants

|Région|Identifiant timezone|Décalage UTC (hiver/été)|
|---|---|---|
|France métropolitaine|`Europe/Paris`|UTC+1 / UTC+2|
|Belgique|`Europe/Brussels`|UTC+1 / UTC+2|
|Suisse|`Europe/Zurich`|UTC+1 / UTC+2|
|Canada (Montréal)|`America/Montreal`|UTC-5 / UTC-4|
|Canada (Vancouver)|`America/Vancouver`|UTC-8 / UTC-7|
|Martinique|`America/Martinique`|UTC-4|
|Réunion|`Indian/Reunion`|UTC+4|

> [!info] Liste complète Liste complète des fuseaux horaires PHP : https://www.php.net/manual/fr/timezones.php

#### Configuration de la directive

```bash
# Éditer php.ini
sudo nano /etc/php/8.1/apache2/php.ini

# Rechercher la ligne date.timezone (souvent commentée avec ;)
# Décommenter et définir le fuseau horaire
date.timezone = "Europe/Paris"
```

> [!example] Exemple pour différentes régions
> 
> ```ini
> ; Pour la France
> date.timezone = "Europe/Paris"
> 
> ; Pour le Québec
> date.timezone = "America/Montreal"
> 
> ; Pour la Suisse
> date.timezone = "Europe/Zurich"
> 
> ; Pour la Réunion
> date.timezone = "Indian/Reunion"
> ```

#### Impact sur les applications

|Fonction PHP|Sans timezone|Avec timezone|
|---|---|---|
|`date()`|UTC + Warning|Heure locale correcte|
|`time()`|Timestamp UTC (ok)|Timestamp UTC (ok)|
|`strtotime()`|Interprétation UTC|Interprétation locale|
|`DateTime`|Exception ou UTC|Heure locale|

> [!warning] Base de données et timezone Attention : Cette directive affecte PHP uniquement, pas votre base de données MySQL/MariaDB. Pour une cohérence totale, configurez aussi le timezone de votre SGBD.

#### Vérification de la configuration

```bash
# Créer un script de test
echo "<?php
echo 'Fuseau horaire configuré : ' . date_default_timezone_get() . '<br>';
echo 'Date/heure actuelle : ' . date('Y-m-d H:i:s') . '<br>';
echo 'Timestamp : ' . time();
?>" | sudo tee /var/www/html/test_timezone.php

# Accéder à http://votre-serveur/test_timezone.php
```

> [!tip] Modification dynamique Vous pouvez changer le timezone dans un script spécifique :
> 
> ```php
> <?php
> // Pour toute l'application
> date_default_timezone_set('Europe/Paris');
> 
> // Pour une opération spécifique (objet DateTime)
> $date = new DateTime('now', new DateTimeZone('America/New_York'));
> ?>
> ```

---

## 🔄 Redémarrage après modification

Toute modification du fichier **php.ini** nécessite un redémarrage du service concerné pour être prise en compte. C'est une étape souvent oubliée qui cause beaucoup de confusion.

### Pourquoi redémarrer ?

PHP charge sa configuration au démarrage du processus. Lorsque Apache démarre, il lit php.ini une seule fois et garde ces paramètres en mémoire. Modifier php.ini sans redémarrer n'a donc aucun effet sur les processus déjà en cours.

```
┌──────────────────────────────────────────┐
│  1. Apache démarre                       │
│     ↓                                    │
│  2. PHP charge php.ini en mémoire        │
│     ↓                                    │
│  3. Traitement des requêtes avec         │
│     ces paramètres                       │
│     ↓                                    │
│  Modification de php.ini (sans effet)    │
│     ↓                                    │
│  4. Redémarrage d'Apache                 │
│     ↓                                    │
│  5. PHP recharge php.ini (nouveaux       │
│     paramètres actifs)                   │
└──────────────────────────────────────────┘
```

### Commandes de redémarrage

#### Apache2 (Ubuntu/Debian)

```bash
# Méthode 1 : Redémarrage complet (recommandé)
sudo systemctl restart apache2

# Méthode 2 : Rechargement gracieux (sans couper les connexions)
sudo systemctl reload apache2

# Vérifier le statut après redémarrage
sudo systemctl status apache2
```

> [!info] Différence restart vs reload
> 
> - **restart** : Arrête complètement Apache puis le redémarre (connexions coupées)
> - **reload** : Recharge la configuration sans interrompre les connexions actives
> 
> Pour des modifications de php.ini, **reload suffit généralement**.

#### Apache2 (CentOS/RHEL)

```bash
# Redémarrage
sudo systemctl restart httpd

# Rechargement
sudo systemctl reload httpd

# Vérification
sudo systemctl status httpd
```

#### PHP-FPM (si utilisé)

Si vous utilisez PHP-FPM au lieu du module Apache traditionnel, vous devez redémarrer PHP-FPM :

```bash
# Redémarrage de PHP-FPM
sudo systemctl restart php8.1-fpm

# Rechargement de PHP-FPM
sudo systemctl reload php8.1-fpm

# Puis recharger Apache
sudo systemctl reload apache2
```

### Workflow complet de modification

```bash
# 1. Sauvegarder le fichier original
sudo cp /etc/php/8.1/apache2/php.ini /etc/php/8.1/apache2/php.ini.backup

# 2. Éditer le fichier
sudo nano /etc/php/8.1/apache2/php.ini

# 3. Vérifier la syntaxe (important !)
php -c /etc/php/8.1/apache2/php.ini -m
# Si erreurs, restaurer la sauvegarde

# 4. Recharger Apache
sudo systemctl reload apache2

# 5. Vérifier que les changements sont actifs
php -i | grep memory_limit
# ou via phpinfo() dans le navigateur
```

> [!warning] Erreurs de syntaxe Une erreur dans php.ini peut empêcher PHP de démarrer complètement !
> 
> Signes d'un php.ini corrompu :
> 
> - Page blanche au lieu de votre site
> - Erreur 500 dans Apache
> - Message "PHP module not loaded"
> 
> Solution : Restaurer la sauvegarde et redémarrer Apache

### Vérification des changements

#### Méthode 1 : Via la ligne de commande

```bash
# Vérifier une directive spécifique
php -i | grep memory_limit
# Sortie : memory_limit => 256M => 256M

# Voir toute la configuration
php -i | less
```

#### Méthode 2 : Via phpinfo()

```bash
# Créer un fichier phpinfo
echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/info.php

# Accéder à http://votre-serveur/info.php
# Chercher vos directives modifiées

# IMPORTANT : Supprimer ce fichier après vérification (sécurité)
sudo rm /var/www/html/info.php
```

#### Méthode 3 : Via un script de test

```php
<?php
// test_config.php
$settings = [
    'memory_limit',
    'upload_max_filesize',
    'post_max_size',
    'display_errors',
    'error_reporting',
    'date.timezone'
];

echo "<h2>Configuration PHP actuelle</h2>";
echo "<table border='1' cellpadding='10'>";
echo "<tr><th>Directive</th><th>Valeur</th></tr>";

foreach ($settings as $setting) {
    $value = ini_get($setting);
    echo "<tr><td>$setting</td><td>$value</td></tr>";
}

echo "</table>";
?>
```

> [!tip] Astuce de production Créez un script de monitoring qui vérifie automatiquement vos directives critiques et vous alerte si elles ne correspondent pas aux valeurs attendues.

### Que faire en cas de problème ?

```bash
# 1. Vérifier les logs Apache
sudo tail -f /var/log/apache2/error.log

# 2. Vérifier les logs PHP (si log_errors = On)
sudo tail -f /var/log/php/error.log

# 3. Tester la configuration Apache
sudo apache2ctl configtest

# 4. Restaurer la sauvegarde si nécessaire
sudo cp /etc/php/8.1/apache2/php.ini.backup /etc/php/8.1/apache2/php.ini
sudo systemctl restart apache2
```

> [!example] Checklist post-modification Après avoir modifié php.ini :
> 
> - [ ] Fichier php.ini sauvegardé
> - [ ] Modifications effectuées
> - [ ] Apache rechargé (`systemctl reload apache2`)
> - [ ] Changements vérifiés via phpinfo() ou `php -i`
> - [ ] Site web toujours accessible
> - [ ] Logs vérifiés (pas d'erreur)
> - [ ] Fichier phpinfo.php supprimé (sécurité)

---

## 📊 Tableau récapitulatif des directives

|Directive|Valeur développement|Valeur production|Impact|
|---|---|---|---|
|`memory_limit`|256M - 512M|128M - 256M|Performance, sécurité|
|`upload_max_filesize`|50M|10M - 20M|Fonctionnalité upload|
|`post_max_size`|60M|15M - 25M|Fonctionnalité formulaires|
|`display_errors`|On|**Off**|Sécurité critique|
|`error_reporting`|E_ALL|E_ALL & ~E_DEPRECATED|Débogage|
|`log_errors`|On|**On**|Traçabilité|
|`date.timezone`|"Europe/Paris"|"Europe/Paris"|Cohérence dates|

> [!tip] Conseil final Documentez vos modifications de php.ini dans un fichier changelog ou dans votre documentation projet. Cela facilitera grandement le déploiement sur d'autres serveurs et le dépannage futur.

---

**🎓 Fin de la partie : Configuration PHP (php.ini)**