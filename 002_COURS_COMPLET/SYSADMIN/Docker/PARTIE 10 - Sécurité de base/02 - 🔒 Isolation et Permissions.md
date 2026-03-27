

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

L'isolation et la gestion des permissions sont les piliers de la sécurité Docker. Docker utilise plusieurs mécanismes du noyau Linux pour créer des barrières de sécurité entre les conteneurs et le système hôte.

> [!info] Pourquoi c'est crucial Par défaut, Docker offre une isolation basique, mais un conteneur compromis peut potentiellement affecter l'hôte ou d'autres conteneurs. Les mécanismes d'isolation avancés permettent de réduire drastiquement cette surface d'attaque.

---

## 👤 User Namespaces

### Concept et fonctionnement

Les **user namespaces** permettent de mapper les utilisateurs à l'intérieur d'un conteneur vers des utilisateurs différents sur l'hôte. C'est l'une des protections les plus efficaces contre les escalades de privilèges.

> [!example] Exemple de mapping
> 
> - L'utilisateur `root` (UID 0) dans le conteneur est mappé vers l'UID 100000 sur l'hôte
> - L'utilisateur avec UID 1 dans le conteneur est mappé vers l'UID 100001 sur l'hôte
> 
> Ainsi, même si un attaquant obtient les droits root dans le conteneur, il n'a aucun privilège sur l'hôte.

**Fonctionnement technique :**

```bash
# Mapping standard avec user namespaces activés
# Conteneur : UID 0-65536
# Hôte     : UID 100000-165536
```

Le noyau Linux maintient une table de correspondance qui traduit automatiquement les UID/GID lors des appels système.

### Configuration

#### Activation globale du daemon Docker

```bash
# Éditer /etc/docker/daemon.json
{
  "userns-remap": "default"
}

# Redémarrer le daemon
sudo systemctl restart docker
```

> [!warning] Impact de l'activation
> 
> - Les conteneurs existants devront être recréés
> - Les volumes existants peuvent nécessiter une remise à niveau des permissions
> - Légère baisse de performance (généralement négligeable)

#### Configuration personnalisée

```bash
# Créer un utilisateur dédié pour le mapping
sudo useradd -r -s /bin/false dockremap

# Définir les plages de subordination dans /etc/subuid et /etc/subgid
echo "dockremap:100000:65536" | sudo tee -a /etc/subuid
echo "dockremap:100000:65536" | sudo tee -a /etc/subgid

# Configurer Docker pour utiliser cet utilisateur
{
  "userns-remap": "dockremap"
}
```

#### Utilisation par conteneur

```bash
# Activer pour un conteneur spécifique (si non activé globalement)
docker run --userns=host nginx

# Vérifier le mapping actif
docker run --rm alpine id
# uid=0(root) gid=0(root) groups=0(root)

# Sur l'hôte, vérifier les processus réels
ps aux | grep nginx
# 100000   12345  ... nginx
```

### Cas d'usage pratiques

#### Conteneur avec accès aux fichiers de l'hôte

```bash
# Problème : avec user namespaces, les UID ne correspondent plus
docker run -v /data:/data alpine ls -la /data
# Permission denied

# Solution 1 : Ajuster les permissions sur l'hôte
sudo chown -R 100000:100000 /data

# Solution 2 : Désactiver user namespaces pour ce conteneur (déconseillé)
docker run --userns=host -v /data:/data alpine ls -la /data

# Solution 3 : Utiliser un volume Docker (recommandé)
docker volume create mydata
docker run -v mydata:/data alpine sh
```

> [!tip] Astuce pour le développement En développement, vous pouvez désactiver temporairement les user namespaces. En production, préférez toujours les ajustements de permissions ou les volumes Docker.

#### Vérification et debugging

```bash
# Vérifier si les user namespaces sont actifs
docker info | grep "userns"

# Inspecter le mapping d'un conteneur
docker inspect <container_id> | grep -A 10 "HostConfig"

# Voir les processus réels sur l'hôte
docker run -d --name test nginx
ps aux | grep nginx
# Observe les UIDs mappés (ex: 100033 au lieu de 33)
```

---

## 🔐 Capabilities Linux

### Comprendre les capabilities

Traditionnellement, Linux distingue deux types de processus : privilégiés (root, UID 0) et non privilégiés. Les **capabilities** divisent les privilèges de root en unités distinctes qui peuvent être accordées ou retirées indépendamment.

> [!info] Principe fondamental Au lieu de donner tous les pouvoirs de root, on peut accorder uniquement les capacités nécessaires (principe du moindre privilège).

**Exemples de capabilities :**

|Capability|Description|Exemple d'usage|
|---|---|---|
|`CAP_NET_BIND_SERVICE`|Écouter sur les ports < 1024|Serveur web sur le port 80|
|`CAP_NET_ADMIN`|Configuration réseau|Modification des routes, VPN|
|`CAP_SYS_TIME`|Modifier l'horloge système|Serveur NTP|
|`CAP_CHOWN`|Changer la propriété des fichiers|Scripts de gestion de fichiers|
|`CAP_DAC_OVERRIDE`|Outrepasser les permissions fichiers|Accès aux fichiers protégés|
|`CAP_SETUID/SETGID`|Changer l'UID/GID|su, sudo, applications serveur|

### Gestion dans Docker

#### Capabilities par défaut

Docker accorde un ensemble restreint de capabilities par défaut :

```bash
# Lister les capabilities d'un conteneur en cours
docker run --rm alpine sh -c 'apk add -q libcap; capsh --print'

# Capabilities par défaut dans Docker :
# CAP_CHOWN, CAP_DAC_OVERRIDE, CAP_FOWNER, CAP_FSETID,
# CAP_KILL, CAP_SETGID, CAP_SETUID, CAP_SETPCAP,
# CAP_NET_BIND_SERVICE, CAP_NET_RAW, CAP_SYS_CHROOT,
# CAP_MKNOD, CAP_AUDIT_WRITE, CAP_SETFCAP
```

> [!warning] Ne jamais utiliser --privileged en production L'option `--privileged` accorde TOUTES les capabilities et désactive les protections. À n'utiliser que pour le debugging ou dans des environnements très contrôlés.

#### Retirer des capabilities (principe du moindre privilège)

```bash
# Retirer des capabilities spécifiques
docker run --cap-drop=CHOWN --cap-drop=DAC_OVERRIDE alpine sh

# Retirer TOUTES les capabilities puis ajouter uniquement celles nécessaires
docker run --cap-drop=ALL --cap-add=NET_BIND_SERVICE nginx

# Exemple : serveur web minimal
docker run -d \
  --cap-drop=ALL \
  --cap-add=NET_BIND_SERVICE \
  --cap-add=CHOWN \
  --cap-add=SETUID \
  --cap-add=SETGID \
  -p 80:80 \
  nginx
```

> [!tip] Méthode recommandée Toujours partir de `--cap-drop=ALL` puis ajouter uniquement les capabilities nécessaires. Cela garantit le minimum de privilèges.

#### Ajouter des capabilities

```bash
# Application nécessitant de modifier les routes réseau
docker run --cap-add=NET_ADMIN alpine ip route add default via 172.17.0.1

# Application nécessitant d'écouter sur un port privilégié
docker run --cap-add=NET_BIND_SERVICE -p 80:80 myapp

# Serveur NTP nécessitant de modifier l'heure système
docker run --cap-add=SYS_TIME ntp-server
```

#### Configuration dans Docker Compose

```yaml
version: '3.8'

services:
  webapp:
    image: nginx
    cap_drop:
      - ALL
    cap_add:
      - NET_BIND_SERVICE
      - CHOWN
      - SETUID
      - SETGID
    ports:
      - "80:80"
  
  vpn-client:
    image: my-vpn
    cap_drop:
      - ALL
    cap_add:
      - NET_ADMIN
      - NET_RAW
    devices:
      - /dev/net/tun
```

### Liste des capabilities importantes

#### Capabilities dangereuses (à éviter)

```bash
# CAP_SYS_ADMIN : "super-capability", permet presque tout
# Éviter absolument en production
docker run --cap-add=SYS_ADMIN alpine

# CAP_SYS_PTRACE : Permet de débugger d'autres processus
# Peut être utilisé pour lire la mémoire d'autres conteneurs
docker run --cap-add=SYS_PTRACE debugger

# CAP_SYS_MODULE : Charger des modules kernel
# Permet de compromettre complètement l'hôte
docker run --cap-add=SYS_MODULE malicious
```

> [!warning] Capabilities critiques `CAP_SYS_ADMIN`, `CAP_SYS_MODULE`, `CAP_SYS_RAWIO`, `CAP_SYS_PTRACE` sont extrêmement puissantes et peuvent permettre une compromission totale du système. Ne les accordez jamais sans une raison absolument nécessaire et documentée.

#### Capabilities utiles courantes

```bash
# CAP_NET_BIND_SERVICE : Port < 1024
docker run --cap-add=NET_BIND_SERVICE -p 443:443 web-server

# CAP_NET_ADMIN + CAP_NET_RAW : Configuration réseau avancée
docker run --cap-add=NET_ADMIN --cap-add=NET_RAW vpn-container

# CAP_SYS_TIME : Synchronisation temporelle
docker run --cap-add=SYS_TIME chrony

# CAP_CHOWN : Gestion des permissions fichiers
docker run --cap-add=CHOWN backup-script
```

#### Diagnostic des capabilities nécessaires

```bash
# Méthode 1 : Tester avec toutes les capabilities puis retirer
docker run --privileged myapp
# Si ça fonctionne, identifier les capabilities réellement utilisées

# Méthode 2 : Utiliser strace pour voir les appels système refusés
docker run --cap-drop=ALL myapp
# Observer les erreurs "Operation not permitted"

# Méthode 3 : Analyser avec un outil comme pscap
docker run --rm --pid=container:myapp \
  alpine sh -c 'apk add -q libcap; pscap'
```

---

## 🛡️ AppArmor et SELinux

### Notions de base

**AppArmor** (Application Armor) et **SELinux** (Security-Enhanced Linux) sont des systèmes de **Mandatory Access Control (MAC)** qui ajoutent une couche de sécurité supplémentaire au-dessus des permissions Unix traditionnelles.

> [!info] Différences principales
> 
> - **AppArmor** : Plus simple, basé sur des chemins de fichiers, utilisé par défaut sur Ubuntu/Debian
> - **SELinux** : Plus complexe et granulaire, basé sur des labels, utilisé par défaut sur RHEL/CentOS/Fedora

**Principe de fonctionnement :**

Même si un processus tourne en root avec toutes les capabilities, AppArmor/SELinux peut l'empêcher d'effectuer certaines actions selon son profil de sécurité.

```bash
# Sans MAC : root peut tout faire
# Avec MAC : root est limité par son profil de sécurité
```

### AppArmor avec Docker

#### Vérification et statut

```bash
# Vérifier qu'AppArmor est actif
sudo aa-status

# Vérifier le profil Docker par défaut
sudo aa-status | grep docker

# Profil par défaut de Docker
# /etc/apparmor.d/docker
```

#### Profil par défaut de Docker

Docker applique automatiquement un profil AppArmor restrictif à tous les conteneurs :

```bash
# Voir le profil actif d'un conteneur
docker inspect <container_id> | grep -i apparmor
# "AppArmorProfile": "docker-default"
```

**Restrictions du profil docker-default :**

- Bloque l'accès à `/sys/kernel/security`
- Empêche le montage de systèmes de fichiers
- Limite l'accès aux fichiers sensibles du système
- Restreint certaines opérations réseau dangereuses

#### Désactiver AppArmor (déconseillé)

```bash
# Désactiver pour un conteneur spécifique
docker run --security-opt apparmor=unconfined alpine

# En Docker Compose
services:
  webapp:
    image: nginx
    security_opt:
      - apparmor=unconfined
```

> [!warning] Risque de sécurité Désactiver AppArmor supprime une couche de protection importante. Ne le faites qu'en cas de nécessité absolue et documentée.

#### Créer un profil personnalisé

```bash
# 1. Créer un profil dans /etc/apparmor.d/
sudo nano /etc/apparmor.d/docker-nginx

# Contenu du profil :
#include <tunables/global>

profile docker-nginx flags=(attach_disconnected,mediate_deleted) {
  #include <abstractions/base>
  
  # Autoriser la lecture des fichiers de configuration
  /etc/nginx/** r,
  
  # Autoriser l'écriture des logs
  /var/log/nginx/** w,
  
  # Autoriser l'accès aux sockets réseau
  network inet tcp,
  network inet udp,
  
  # Bloquer l'accès à tout le reste
  deny /** w,
}

# 2. Charger le profil
sudo apparmor_parser -r /etc/apparmor.d/docker-nginx

# 3. Utiliser le profil
docker run --security-opt apparmor=docker-nginx nginx
```

#### Debugging des problèmes AppArmor

```bash
# Voir les violations AppArmor dans les logs
sudo dmesg | grep -i apparmor
sudo journalctl -xe | grep -i apparmor

# Mettre un profil en mode "complain" (audit sans blocage)
sudo aa-complain /etc/apparmor.d/docker-nginx

# Revenir en mode "enforce"
sudo aa-enforce /etc/apparmor.d/docker-nginx

# Analyser les logs pour créer un profil
sudo aa-logprof
```

### SELinux avec Docker

#### Vérification et statut

```bash
# Vérifier que SELinux est actif
getenforce
# Enforcing (actif) / Permissive (audit) / Disabled (désactivé)

# Voir le statut détaillé
sestatus

# Voir le contexte SELinux d'un processus
ps auxZ | grep docker
```

#### Types SELinux pour Docker

Docker utilise principalement le type `container_t` pour les processus des conteneurs :

```bash
# Voir le contexte d'un conteneur en cours
docker run --rm alpine cat /proc/self/attr/current
# system_u:system_r:container_t:s0:c123,c456

# Composants du contexte :
# - User: system_u
# - Role: system_r
# - Type: container_t (restriction principale)
# - Level: s0:c123,c456 (isolation multi-catégories)
```

#### Labels SELinux pour les volumes

```bash
# Par défaut, SELinux bloque l'accès aux fichiers de l'hôte
docker run -v /data:/data alpine ls /data
# Permission denied (SELinux)

# Solution 1 : Ajouter le label :z (privé au conteneur)
docker run -v /data:/data:z alpine ls /data

# Solution 2 : Ajouter le label :Z (partagé entre conteneurs)
docker run -v /data:/data:Z alpine ls /data

# Vérifier le label SELinux d'un fichier
ls -Z /data
# system_u:object_r:container_file_t:s0
```

> [!info] Différence entre :z et :Z
> 
> - `:z` : Le conteneur peut accéder au volume, mais chaque conteneur a son propre contexte
> - `:Z` : Le volume est partageable entre plusieurs conteneurs avec le même contexte
> 
> **Règle :** Utilisez `:z` par défaut, `:Z` seulement si plusieurs conteneurs doivent accéder aux mêmes fichiers.

#### Désactiver SELinux pour un conteneur (déconseillé)

```bash
# Désactiver les restrictions SELinux
docker run --security-opt label=disable alpine

# En Docker Compose
services:
  webapp:
    image: nginx
    security_opt:
      - label=disable
```

> [!warning] Impact sur la sécurité Désactiver SELinux supprime l'isolation multi-catégories et permet potentiellement à un conteneur compromis d'accéder aux ressources d'autres conteneurs.

#### Politiques personnalisées SELinux

```bash
# Créer un module de politique personnalisée (avancé)
# 1. Activer le mode audit
setenforce 0

# 2. Exécuter l'application et collecter les violations
docker run myapp
sudo ausearch -m avc -ts recent > violations.txt

# 3. Générer un module à partir des violations
sudo audit2allow -a -M mydocker < violations.txt

# 4. Charger le module
sudo semodule -i mydocker.pp

# 5. Réactiver le mode enforce
setenforce 1
```

#### Debugging SELinux

```bash
# Voir les violations en temps réel
sudo tail -f /var/log/audit/audit.log | grep -i denied

# Analyser les problèmes SELinux
sudo sealert -a /var/log/audit/audit.log

# Passer temporairement en mode permissif
sudo setenforce 0
# Tester l'application
sudo setenforce 1

# Vérifier le contexte d'un volume monté
docker run -v /data:/data:z alpine sh
ls -Z /data
```

---

## ✅ Bonnes pratiques globales

### Combinaison des mécanismes de sécurité

```bash
# Exemple de conteneur durci avec toutes les protections
docker run -d \
  --name secure-webapp \
  --user 1000:1000 \
  --read-only \
  --tmpfs /tmp:rw,noexec,nosuid,size=100m \
  --cap-drop=ALL \
  --cap-add=NET_BIND_SERVICE \
  --security-opt=no-new-privileges:true \
  --security-opt apparmor=docker-default \
  -v /app/data:/data:ro,z \
  -p 8080:8080 \
  webapp:latest
```

**Explication de chaque option :**

- `--user 1000:1000` : Ne tourne pas en root
- `--read-only` : Système de fichiers racine en lecture seule
- `--tmpfs` : Zone temporaire isolée et limitée
- `--cap-drop=ALL --cap-add=...` : Capabilities minimales
- `--security-opt=no-new-privileges` : Empêche l'escalade de privilèges
- `--security-opt apparmor=...` : Profil AppArmor actif
- `-v ...:ro,z` : Volume en lecture seule avec SELinux

### Matrice de décision

|Scénario|User Namespaces|Capabilities|AppArmor/SELinux|
|---|---|---|---|
|Application web standard|✅ Oui|Drop ALL, add NET_BIND_SERVICE|✅ Profil par défaut|
|Base de données|✅ Oui|Drop ALL, add CHOWN,SETUID,SETGID|✅ Profil personnalisé|
|VPN/Réseau|⚠️ Désactiver si nécessaire|Add NET_ADMIN, NET_RAW|✅ Profil personnalisé|
|Conteneur privilégié (CI/CD)|❌ Non|Évaluer au cas par cas|⚠️ Mode permissif si nécessaire|

### Checklist de sécurité

> [!tip] Avant de déployer un conteneur en production
> 
> - [ ] User namespaces activés (sauf cas spécifique justifié)
> - [ ] Capabilities réduites au minimum (`--cap-drop=ALL` puis ajouts ciblés)
> - [ ] AppArmor/SELinux actif avec profil approprié
> - [ ] Utilisateur non-root dans le conteneur (`--user`)
> - [ ] Système de fichiers en lecture seule si possible (`--read-only`)
> - [ ] `no-new-privileges` activé
> - [ ] Volumes montés avec les bonnes permissions SELinux (`:z` ou `:Z`)
> - [ ] Logs de sécurité surveillés (`dmesg`, `audit.log`)

### Pièges courants

❌ **À éviter :**

```bash
# Trop permissif - accorde TOUS les privilèges
docker run --privileged myapp

# Désactive toutes les protections
docker run --security-opt apparmor=unconfined --security-opt label=disable myapp

# Donne toutes les capabilities
docker run --cap-add=ALL myapp

# Désactive user namespaces globalement sans raison
{
  "userns-remap": ""
}
```

✅ **À faire :**

```bash
# Approche progressive et sécurisée
docker run --cap-drop=ALL --cap-add=NET_BIND_SERVICE myapp

# Documentation des exceptions
# Si vous devez désactiver une protection, documentez POURQUOI
docker run --userns=host myapp  # Requis pour accès direct /dev/sda

# Tests de sécurité réguliers
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy image myapp:latest
```

### Impact sur les performances

> [!info] Considérations de performance
> 
> - **User namespaces** : Impact négligeable (< 1% dans la plupart des cas)
> - **Capabilities** : Aucun impact, c'est juste une restriction de permissions
> - **AppArmor** : Impact très faible (< 2%)
> - **SELinux** : Impact faible à modéré (2-5% selon la complexité des politiques)
> 
> Le gain en sécurité justifie largement ce léger surcoût.

---

**🎓 Points clés à retenir :**

1. **User namespaces** : Mappent les utilisateurs du conteneur vers des UID différents sur l'hôte → root dans le conteneur n'est pas root sur l'hôte
2. **Capabilities** : Divisent les privilèges de root en unités granulaires → accordez uniquement ce qui est nécessaire
3. **AppArmor/SELinux** : Ajoutent des restrictions obligatoires au-delà des permissions Unix → protection en profondeur même si un attaquant obtient root

Ces trois mécanismes se complètent et doivent être utilisés ensemble pour une sécurité maximale.