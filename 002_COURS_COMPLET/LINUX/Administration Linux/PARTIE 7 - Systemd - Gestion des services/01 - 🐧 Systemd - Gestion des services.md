

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

## 🎯 Introduction à systemctl {#introduction}

> [!info] Qu'est-ce que systemctl ? `systemctl` est l'outil de contrôle principal de **systemd**, le système d'init moderne utilisé par la majorité des distributions Linux actuelles (Ubuntu, Debian, RHEL, Arch, etc.). Il permet de gérer l'intégralité du cycle de vie des services système.

**Pourquoi c'est important :**

- Contrôle centralisé de tous les services (web, base de données, réseau, etc.)
- Gestion du démarrage automatique au boot
- Supervision de l'état des services en temps réel
- Logs intégrés via journald

**Syntaxe générale :**

```bash
systemctl [COMMANDE] [NOM_SERVICE]
```

> [!tip] Astuce - Privilèges root La plupart des commandes systemctl nécessitent les privilèges root. Utilisez `sudo` si vous n'êtes pas connecté en tant que root.

---

## 🎮 Gestion de l'état des services {#gestion-etat}

### ▶️ start - Démarrer un service {#start}

**Quand l'utiliser :**

- Lancer un service actuellement arrêté
- Après une installation de logiciel
- Suite à un arrêt manuel ou un crash

**Syntaxe :**

```bash
sudo systemctl start nom_service
```

**Exemples concrets :**

```bash
# Démarrer le serveur web Apache
sudo systemctl start apache2

# Démarrer le serveur SSH
sudo systemctl start ssh

# Démarrer MySQL/MariaDB
sudo systemctl start mysql
```

> [!example] Cas d'usage typique Vous venez d'installer nginx et il n'est pas encore démarré :
> 
> ```bash
> sudo apt install nginx
> sudo systemctl start nginx
> # Le serveur web est maintenant actif
> ```

> [!warning] Attention `start` ne produit aucun message si le démarrage réussit. Utilisez `status` pour vérifier que tout fonctionne correctement.

---

### ⏹️ stop - Arrêter un service {#stop}

**Quand l'utiliser :**

- Avant une maintenance
- Pour libérer des ressources
- Avant de modifier la configuration (selon le service)
- Avant une désinstallation propre

**Syntaxe :**

```bash
sudo systemctl stop nom_service
```

**Exemples concrets :**

```bash
# Arrêter le serveur web
sudo systemctl stop nginx

# Arrêter une base de données
sudo systemctl stop postgresql

# Arrêter le pare-feu
sudo systemctl stop firewalld
```

> [!warning] Arrêt vs Kill `systemctl stop` envoie un signal SIGTERM permettant un arrêt propre du service. Si le service ne répond pas dans le délai imparti (généralement 90s), systemd enverra un SIGKILL.

> [!tip] Astuce - Maintenance Avant d'arrêter un service critique en production, vérifiez les dépendances :
> 
> ```bash
> systemctl list-dependencies nom_service
> ```

---

### 🔄 restart - Redémarrer un service {#restart}

**Quand l'utiliser :**

- Après modification de la configuration
- Pour résoudre un comportement anormal
- Appliquer des changements sans `reload`

**Syntaxe :**

```bash
sudo systemctl restart nom_service
```

**Différence avec stop + start :** `restart` est atomique : systemd gère l'arrêt puis le redémarrage automatiquement.

**Exemples concrets :**

```bash
# Après modification de /etc/ssh/sshd_config
sudo systemctl restart ssh

# Après changement de configuration Apache
sudo systemctl restart apache2

# Redémarrer Docker
sudo systemctl restart docker
```

> [!example] Scénario réel Vous avez modifié la configuration de votre serveur web :
> 
> ```bash
> sudo nano /etc/nginx/nginx.conf
> # ... modifications ...
> sudo systemctl restart nginx
> # Les nouvelles configurations sont maintenant actives
> ```

> [!warning] Impact utilisateur `restart` provoque une interruption de service (downtime). Pour les services critiques, préférez `reload` si disponible.

---

### 🔃 reload - Recharger la configuration {#reload}

**Quand l'utiliser :**

- Appliquer des changements de configuration sans interruption
- Recharger des certificats SSL
- Mettre à jour des règles sans downtime

**Syntaxe :**

```bash
sudo systemctl reload nom_service
```

**Différence cruciale avec restart :**

|Caractéristique|reload|restart|
|---|---|---|
|Interruption de service|❌ Non|✅ Oui|
|Connexions existantes|Préservées|Fermées|
|Changements appliqués|Configuration uniquement|Tout|
|Rapidité|Très rapide|Plus lent|

**Exemples concrets :**

```bash
# Recharger la config nginx sans couper les connexions
sudo systemctl reload nginx

# Recharger les règles du pare-feu
sudo systemctl reload firewalld

# Recharger Apache après modification VirtualHost
sudo systemctl reload apache2
```

> [!tip] Bonne pratique Toujours privilégier `reload` quand c'est possible pour les services en production :
> 
> ```bash
> # Vérifier si le service supporte reload
> systemctl show nom_service | grep CanReload
> ```

> [!warning] Tous les services ne supportent pas reload Si un service ne supporte pas `reload`, la commande échouera. Dans ce cas, utilisez `restart`.

---

### 📊 status - Consulter l'état {#status}

**Quand l'utiliser :**

- Vérifier si un service fonctionne
- Diagnostiquer un problème
- Consulter les derniers logs
- Voir les informations détaillées (PID, mémoire, etc.)

**Syntaxe :**

```bash
systemctl status nom_service
```

**Exemples concrets :**

```bash
# Vérifier l'état de nginx
systemctl status nginx

# Diagnostic SSH
systemctl status ssh

# État détaillé avec plus de logs
systemctl status -l nginx
```

**Interprétation de la sortie :**

```bash
● nginx.service - A high performance web server
     Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
     Active: active (running) since Mon 2024-12-26 10:30:15 CET; 2h 15min ago
       Docs: man:nginx(8)
    Process: 1234 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
    Process: 1235 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
   Main PID: 1236 (nginx)
      Tasks: 5 (limit: 4915)
     Memory: 12.5M
        CPU: 1.234s
     CGroup: /system.slice/nginx.service
             ├─1236 nginx: master process /usr/sbin/nginx
             └─1237 nginx: worker process
```

**Décryptage des informations importantes :**

|Élément|Signification|
|---|---|
|`●` (vert)|Service actif|
|`●` (rouge)|Service en échec|
|`Loaded: enabled`|Démarre automatiquement au boot|
|`Active: active (running)`|Service en cours d'exécution|
|`Active: inactive (dead)`|Service arrêté|
|`Active: failed`|Le service a crashé|
|`Main PID`|Processus principal du service|

> [!tip] Astuce - Options utiles
> 
> ```bash
> # Afficher tout le texte sans troncature
> systemctl status -l nom_service
> 
> # Suivre les logs en temps réel
> systemctl status -f nom_service
> 
> # Format court (juste l'état)
> systemctl is-active nom_service
> ```

> [!example] Diagnostic d'un problème
> 
> ```bash
> systemctl status apache2
> # Si le statut montre "failed", consultez les logs détaillés :
> journalctl -u apache2 -n 50
> ```

---

## 🚀 Gestion du démarrage automatique {#demarrage-auto}

### ✅ enable - Activer au boot {#enable}

**Quand l'utiliser :**

- Pour qu'un service démarre automatiquement au boot
- Après installation d'un nouveau service
- Pour les services critiques (web, base de données, etc.)

**Syntaxe :**

```bash
sudo systemctl enable nom_service
```

**Ce qui se passe techniquement :** `enable` crée des liens symboliques dans `/etc/systemd/system/` qui permettent à systemd de démarrer le service au boot.

**Exemples concrets :**

```bash
# Activer nginx au démarrage
sudo systemctl enable nginx

# Activer et démarrer en une seule commande
sudo systemctl enable --now mysql
```

> [!info] enable vs start
> 
> - `enable` : configure le démarrage automatique (mais ne démarre pas maintenant)
> - `start` : démarre le service maintenant (mais pas au prochain boot)
> - `enable --now` : fait les deux en une seule commande

**Options utiles :**

```bash
# Activer ET démarrer immédiatement
sudo systemctl enable --now service_name

# Forcer la réactivation (utile si les liens sont corrompus)
sudo systemctl reenable service_name
```

> [!example] Cas d'usage - Installation d'un serveur web
> 
> ```bash
> # Installation de nginx
> sudo apt install nginx
> 
> # Le service est installé mais pas activé au boot
> sudo systemctl enable nginx
> 
> # Démarrer maintenant
> sudo systemctl start nginx
> 
> # Ou tout en une fois :
> sudo systemctl enable --now nginx
> ```

> [!tip] Vérifier l'activation
> 
> ```bash
> systemctl is-enabled nginx
> # Retourne : enabled, disabled, ou static
> ```

---

### ❌ disable - Désactiver au boot {#disable}

**Quand l'utiliser :**

- Empêcher un service de démarrer automatiquement
- Désactiver un service inutile pour économiser des ressources
- Sécurité : désactiver des services non nécessaires

**Syntaxe :**

```bash
sudo systemctl disable nom_service
```

**Exemples concrets :**

```bash
# Désactiver un service web non utilisé
sudo systemctl disable apache2

# Désactiver et arrêter en une commande
sudo systemctl disable --now bluetooth
```

> [!warning] disable n'arrête pas le service `disable` empêche le démarrage au boot, mais n'arrête pas le service s'il tourne actuellement. Utilisez `disable --now` pour faire les deux.

**Comparaison enable/disable :**

|Commande|Effet immédiat|Effet au prochain boot|
|---|---|---|
|`enable`|Aucun|Service démarre|
|`disable`|Aucun|Service ne démarre pas|
|`enable --now`|Démarre|Service démarre|
|`disable --now`|Arrête|Service ne démarre pas|

> [!example] Désactivation de services inutiles
> 
> ```bash
> # Sur un serveur sans Bluetooth
> sudo systemctl disable --now bluetooth
> 
> # Si vous n'utilisez pas l'impression
> sudo systemctl disable --now cups
> 
> # Vérifier l'état
> systemctl is-enabled bluetooth
> # Retourne : disabled
> ```

---

## 🔍 Interrogation de l'état {#interrogation}

### 🟢 is-active - Vérifier si actif {#is-active}

**Quand l'utiliser :**

- Dans les scripts shell pour tester l'état
- Vérification rapide sans détails
- Monitoring automatisé

**Syntaxe :**

```bash
systemctl is-active nom_service
```

**Valeurs de retour possibles :**

- `active` : le service tourne
- `inactive` : le service est arrêté
- `failed` : le service a échoué
- `activating` : en cours de démarrage
- `deactivating` : en cours d'arrêt

**Exemples concrets :**

```bash
# Test simple
systemctl is-active nginx
# Affiche : active

# Utilisation dans un script
if systemctl is-active --quiet nginx; then
    echo "Nginx fonctionne"
else
    echo "Nginx est arrêté"
    sudo systemctl start nginx
fi
```

> [!tip] Option --quiet
> 
> ```bash
> # Ne produit aucune sortie, utilise juste le code de retour
> systemctl is-active --quiet service_name
> echo $?  # 0 = actif, autre = inactif
> ```

**Utilisation avancée dans les scripts :**

```bash
#!/bin/bash
# Script de vérification de services critiques

services=("nginx" "mysql" "ssh")

for service in "${services[@]}"; do
    if ! systemctl is-active --quiet "$service"; then
        echo "ALERTE : $service est arrêté !"
        # Envoyer une notification, email, etc.
    fi
done
```

> [!example] Cas pratique - Déploiement automatisé
> 
> ```bash
> # Avant de déployer, vérifier que le service tourne
> if systemctl is-active --quiet nginx; then
>     sudo systemctl reload nginx
> else
>     echo "Erreur : nginx n'est pas actif"
>     exit 1
> fi
> ```

---

### 🔵 is-enabled - Vérifier si activé {#is-enabled}

**Quand l'utiliser :**

- Vérifier si un service démarre au boot
- Audit de la configuration système
- Scripts de configuration automatisés

**Syntaxe :**

```bash
systemctl is-enabled nom_service
```

**Valeurs de retour possibles :**

- `enabled` : démarre au boot
- `disabled` : ne démarre pas au boot
- `static` : ne peut pas être désactivé (dépendance d'autres services)
- `masked` : complètement désactivé, impossible de le démarrer
- `indirect` : activé via un autre service

**Exemples concrets :**

```bash
# Vérification simple
systemctl is-enabled ssh
# Affiche : enabled

# Dans un script de vérification
if systemctl is-enabled --quiet nginx; then
    echo "Nginx démarrera au prochain boot"
else
    echo "Nginx ne démarrera PAS au prochain boot"
fi
```

> [!info] Différence is-active vs is-enabled
> 
> ```bash
> # is-active = état ACTUEL
> systemctl is-active nginx    # active/inactive maintenant
> 
> # is-enabled = état AU BOOT
> systemctl is-enabled nginx   # enabled/disabled au démarrage
> ```

**Cas particuliers :**

```bash
# Service "static" - exemple : systemd-journald
systemctl is-enabled systemd-journald
# Retourne : static
# Ces services ne peuvent pas être désactivés manuellement

# Service "masked" - complètement bloqué
sudo systemctl mask nginx
systemctl is-enabled nginx
# Retourne : masked
```

> [!warning] Service masked Un service "masked" est un cas spécial où systemd empêche totalement son démarrage, même manuel. Pour le réactiver :
> 
> ```bash
> sudo systemctl unmask nom_service
> ```

**Script d'audit :**

```bash
#!/bin/bash
# Lister tous les services activés au boot

echo "Services activés au démarrage :"
systemctl list-unit-files --state=enabled --type=service | grep enabled
```

---

## 📋 Listage et exploration {#listage}

### 📦 list-units - Lister les unités chargées {#list-units}

**Quand l'utiliser :**

- Voir tous les services actuellement chargés en mémoire
- Identifier les services actifs
- Diagnostiquer l'état global du système

**Syntaxe :**

```bash
systemctl list-units [OPTIONS]
```

**Par défaut, affiche toutes les unités chargées (services, sockets, timers, etc.)**

**Options essentielles :**

```bash
# Lister uniquement les services
systemctl list-units --type=service

# Lister uniquement les services actifs
systemctl list-units --type=service --state=active

# Lister les services en échec
systemctl list-units --type=service --state=failed

# Afficher tout, même les unités inactives
systemctl list-units --type=service --all
```

**Exemples concrets :**

```bash
# Tous les services actuellement en cours d'exécution
systemctl list-units --type=service --state=running

# Services qui ont échoué (utile pour le diagnostic)
systemctl list-units --type=service --state=failed

# Format de sortie typique :
# UNIT                     LOAD   ACTIVE SUB     DESCRIPTION
# nginx.service            loaded active running A high performance web server
# ssh.service              loaded active running OpenBSD Secure Shell server
```

**Filtrage et recherche :**

```bash
# Rechercher un service spécifique
systemctl list-units --type=service | grep nginx

# Lister les services qui contiennent "network"
systemctl list-units --type=service | grep network

# Afficher seulement les noms de services
systemctl list-units --type=service --no-legend | awk '{print $1}'
```

> [!tip] Différence avec list-unit-files
> 
> - `list-units` : unités **chargées en mémoire** (actives ou récemment utilisées)
> - `list-unit-files` : **tous les fichiers d'unité** disponibles sur le système

**Types d'unités disponibles :**

|Type|Description|
|---|---|
|`service`|Services standards|
|`socket`|Sockets d'activation|
|`target`|Groupes de services|
|`timer`|Tâches planifiées (comme cron)|
|`mount`|Points de montage|
|`device`|Périphériques|

> [!example] Diagnostic de problèmes
> 
> ```bash
> # Trouver tous les services en échec
> systemctl list-units --type=service --state=failed
> 
> # Si un service apparaît, consulter ses logs :
> journalctl -u nom_service.service -n 50
> ```

**Sortie formatée personnalisée :**

```bash
# Format JSON (utile pour scripts)
systemctl list-units --type=service --output=json

# Format court
systemctl list-units --type=service --no-legend --plain
```

---

### 📄 list-unit-files - Lister tous les fichiers {#list-unit-files}

**Quand l'utiliser :**

- Voir TOUS les services disponibles sur le système
- Vérifier l'état d'activation (enabled/disabled)
- Audit complet de la configuration

**Syntaxe :**

```bash
systemctl list-unit-files [OPTIONS]
```

**Différence cruciale avec list-units :**

|list-units|list-unit-files|
|---|---|
|Unités **chargées**|Tous les fichiers **disponibles**|
|État actuel|État de configuration|
|active/inactive|enabled/disabled|

**Exemples concrets :**

```bash
# Lister tous les fichiers de service
systemctl list-unit-files --type=service

# Lister uniquement les services activés
systemctl list-unit-files --type=service --state=enabled

# Lister les services désactivés
systemctl list-unit-files --type=service --state=disabled

# Format de sortie typique :
# UNIT FILE              STATE   VENDOR PRESET
# nginx.service          enabled enabled
# apache2.service        disabled enabled
# bluetooth.service      disabled enabled
```

**États possibles :**

|État|Signification|
|---|---|
|`enabled`|Démarre automatiquement au boot|
|`disabled`|Ne démarre pas au boot|
|`static`|Ne peut pas être activé manuellement (dépendance)|
|`masked`|Complètement désactivé|
|`generated`|Généré dynamiquement|
|`indirect`|Activé via un autre service|

**Filtrage avancé :**

```bash
# Services activés qui devraient démarrer au boot
systemctl list-unit-files --type=service --state=enabled

# Identifier les services masqués
systemctl list-unit-files --type=service --state=masked

# Compter le nombre de services
systemctl list-unit-files --type=service | wc -l
```

> [!example] Audit de sécurité
> 
> ```bash
> # Lister tous les services activés pour vérification
> systemctl list-unit-files --type=service --state=enabled > enabled_services.txt
> 
> # Vérifier si des services inutiles sont activés
> grep -E "bluetooth|cups|avahi" enabled_services.txt
> ```

**Recherche de services :**

```bash
# Trouver tous les services liés au réseau
systemctl list-unit-files --type=service | grep network

# Services liés à une application spécifique
systemctl list-unit-files --type=service | grep -i docker

# Services fournis par un package
dpkg -L package_name | grep systemd | grep service
```

> [!tip] Combiner les deux commandes
> 
> ```bash
> # Voir si un service est installé ET son état
> echo "Fichier de service :"
> systemctl list-unit-files nginx.service
> echo "État actuel :"
> systemctl list-units nginx.service
> ```

**Script d'analyse comparative :**

```bash
#!/bin/bash
# Comparer services disponibles vs services actifs

echo "=== Services disponibles sur le système ==="
total_services=$(systemctl list-unit-files --type=service | wc -l)
echo "Total : $total_services"

echo -e "\n=== Services actuellement chargés ==="
loaded_services=$(systemctl list-units --type=service --all | wc -l)
echo "Chargés : $loaded_services"

echo -e "\n=== Services activés au boot ==="
enabled_services=$(systemctl list-unit-files --type=service --state=enabled | wc -l)
echo "Activés : $enabled_services"
```

---

## ⚠️ Pièges courants et bonnes pratiques {#pieges}

### 🚫 Erreurs fréquentes

> [!warning] Oublier sudo
> 
> ```bash
> # ❌ Erreur courante
> systemctl start nginx
> # Failed to start nginx.service: Access denied
> 
> # ✅ Correct
> sudo systemctl start nginx
> ```

> [!warning] Confusion start/enable
> 
> ```bash
> # ❌ Le service démarre MAINTENANT mais pas au boot
> sudo systemctl start nginx
> 
> # ✅ Le service démarre au boot ET maintenant
> sudo systemctl enable --now nginx
> ```

> [!warning] Ne pas vérifier après modification
> 
> ```bash
> # ❌ Mauvaise pratique
> sudo systemctl restart nginx
> # Pas de vérification = on ne sait pas si ça marche
> 
> # ✅ Bonne pratique
> sudo systemctl restart nginx
> systemctl status nginx
> # Vérifier que le service est bien "active (running)"
> ```

### ✅ Bonnes pratiques essentielles

**1. Toujours vérifier avant d'agir en production**

```bash
# Vérifier l'état actuel
systemctl status service_name

# Tester la configuration avant reload
sudo nginx -t  # Pour nginx
sudo apache2ctl configtest  # Pour Apache

# Puis recharger si OK
sudo systemctl reload service_name
```

**2. Préférer reload à restart quand possible**

```bash
# ✅ Pas d'interruption de service
sudo systemctl reload nginx

# ❌ Interruption des connexions actuelles
sudo systemctl restart nginx
```

**3. Utiliser les options --now pour la cohérence**

```bash
# ✅ Activation complète en une commande
sudo systemctl enable --now service_name

# ✅ Désactivation complète en une commande
sudo systemctl disable --now service_name
```

**4. Logger les modifications importantes**

```bash
#!/bin/bash
# Script de modification avec logging

echo "$(date) - Redémarrage de nginx" >> /var/log/admin-actions.log
sudo systemctl restart nginx
systemctl status nginx >> /var/log/admin-actions.log
```

### 🛠️ Astuces avancées

**Chaînage de commandes pour workflows complets**

```bash
# Arrêter, désactiver, et vérifier
sudo systemctl stop nginx && \
sudo systemctl disable nginx && \
systemctl status nginx

# Modifier config, tester, recharger
sudo nano /etc/nginx/nginx.conf && \
sudo nginx -t && \
sudo systemctl reload nginx
```

**Surveillance en temps réel**

```bash
# Suivre les changements d'état d'un service
watch -n 2 'systemctl status nginx'

# Suivre les logs en temps réel
journalctl -u nginx -f
```

**Gestion de plusieurs services**

```bash
# Redémarrer plusieurs services liés
for service in nginx mysql redis; do
    sudo systemctl restart $service
    echo "$service : $(systemctl is-active $service)"
done
```

**Vérification de dépendances**

```bash
# Voir ce qui démarre avec ce service
systemctl list-dependencies nginx

# Voir ce qui dépend de ce service
systemctl list-dependencies --reverse nginx
```

### 📊 Tableau récapitulatif des commandes

|Commande|Action immédiate|Effet au boot|Usage|
|---|---|---|---|
|`start`|Démarre|Aucun|Démarrer maintenant|
|`stop`|Arrête|Aucun|Arrêter maintenant|
|`restart`|Redémarre|Aucun|Appliquer changements|
|`reload`|Recharge config|Aucun|Sans interruption|
|`enable`|Aucun|Démarre|Activation permanente|
|`disable`|Aucun|N'démarre pas|Désactivation permanente|
|`enable --now`|Démarre|Démarre|Tout activer|
|`disable --now`|Arrête|N'démarre pas|Tout désactiver|

### 🎯 Checklist de maintenance

**Avant une modification en production :**

- [ ] Vérifier l'état actuel avec `status`
- [ ] Tester la nouvelle configuration si possible
- [ ] Choisir `reload` plutôt que `restart` si supporté
- [ ] Avoir un plan de rollback
- [ ] Vérifier l'état après modification
- [ ] Consulter les logs pour erreurs éventuelles

**Pour l'optimisation système :**

- [ ] Identifier les services inutiles avec `list-unit-files`
- [ ] Désactiver les services non nécessaires
- [ ] Vérifier les services en échec avec `--state=failed`
- [ ] Documenter les services personnalisés
- [ ] Maintenir une liste des services critiques

---

_Ce cours couvre les commandes systemctl essentielles pour la gestion quotidienne des services Linux sous systemd._