## Sommaire

1. [Préparation du serveur](#1-préparation-du-serveur)
2. [Configuration réseau statique](#2-configuration-réseau-statique)
   - [2.1 Identification de l’interface réseau](#21-identification-de-linterface-réseau)
   - [2.2 Configuration de l’adresse IP statique](#22-configuration-de-ladresse-ip-statique)
   - [2.3 Redémarrage du service réseau](#23-redémarrage-du-service-réseau)
   - [2.4 Vérification de la configuration](#24-vérification-de-la-configuration)
3. [Configuration DNS système](#3-configuration-dns-système)
4. [Mise à jour du système](#4-mise-à-jour-du-système)
5. [Installation du service Apache](#5-installation-du-service-apache)
   - [5.1 Activation du service](#51-activation-du-service)
   - [5.2 Démarrage du service](#52-démarrage-du-service)
6. [Vérification du service Apache](#6-vérification-du-service-apache)
7. [Test local du service](#7-test-local-du-service)

---

## 1. Préparation du serveur

Le serveur Web externe est déployé sur une machine **Debian 12** positionnée en **DMZ**, afin d'exposer les services web tout en les isolant du réseau interne.

Avant toute installation, s'assurer des prérequis suivants :

- Accès console fonctionnel
- Accès `root` ou `sudo` disponible
- Connectivité réseau opérationnelle

### Vérification de la connectivité réseau

Tester l'accès à la passerelle DMZ :

```bash
ping 10.10.11.1
```

> `10.10.11.1` correspond à la passerelle DMZ gérée par **pfSense**.

Un retour de paquets confirme que la connectivité réseau est opérationnelle. En l'absence de réponse, vérifier la configuration de l'interface et les règles pfSense avant de continuer.

---

## 2. Configuration réseau statique

Le serveur Web doit disposer d'une **adresse IP fixe** afin d'être correctement référencé dans :

- Les règles de filtrage firewall
- Les règles NAT (redirection de port)
- La configuration DNS

### 2.1 Identifier l'interface réseau

Afficher les interfaces réseau disponibles :

```bash
ip a
```

Repérer le nom de l'interface active (ex : `eth0`). Cette information sera utilisée dans les étapes suivantes.

### 2.2 Modifier la configuration réseau

Ouvrir le fichier de configuration réseau :

```bash
nano /etc/network/interfaces
```

Renseigner la configuration statique suivante en adaptant le nom d'interface si nécessaire :

```
auto eth0
iface eth0 inet static
    address 10.10.11.2
    netmask 255.255.255.248
    gateway 10.10.11.1
```

Sauvegarder et quitter (`Ctrl+O` puis `Ctrl+X`).

### 2.3 Redémarrer le service réseau

Appliquer la nouvelle configuration :

```bash
systemctl restart networking
```

### 2.4 Vérification

Contrôler que l'adresse IP est bien appliquée et que la passerelle répond :

```bash
ip a
ping 10.10.11.1
```

Résultat attendu :

- L'adresse `10.10.11.2` est bien associée à l'interface
- La passerelle `10.10.11.1` répond aux requêtes ICMP

---

## 3. Configuration DNS système

Afin que le serveur puisse résoudre les noms de domaine (notamment pour les mises à jour et l'accès aux dépôts), il est nécessaire de configurer un serveur DNS.

### Modifier le fichier de résolution

```bash
nano /etc/resolv.conf
```

Renseigner le ou les serveurs DNS à utiliser :

```
nameserver 172.16.12.1
```

> Ce DNS correspond au **serveur AD DS / DNS** interne. Un DNS public (ex : `8.8.8.8`) peut être ajouté en seconde ligne si le serveur doit résoudre des noms externes.

Sauvegarder et quitter (`Ctrl+O` puis `Ctrl+X`).

### Vérification de la résolution DNS

```bash
nslookup google.com
```

Résultat attendu : une réponse avec l'adresse IP résolue confirme que le DNS fonctionne correctement.

---

## 4. Mise à jour du système

Avant d'installer Apache, il est recommandé de mettre à jour l'ensemble des paquets du système afin d'appliquer les correctifs de sécurité disponibles.

```bash
apt update
apt upgrade -y
```

L'opération peut prendre quelques minutes selon le nombre de paquets à mettre à jour.

---

## 5. Installation du service Apache

### Installation du paquet

Installer Apache2 et ses dépendances :

```bash
apt install apache2 -y
```

Les dépendances nécessaires sont installées automatiquement.

### 5.1 Activer le service au démarrage

Configurer Apache pour qu'il démarre automatiquement à chaque redémarrage du serveur :

```bash
systemctl enable apache2
```

### 5.2 Démarrer le service

Lancer le service Apache immédiatement :

```bash
systemctl start apache2
```

---

## 6. Vérification du service

### État du service

Vérifier qu'Apache est actif et en cours d'exécution :

```bash
systemctl status apache2
```

Statut attendu dans la sortie :

```
active (running)
```

Toute autre valeur (ex : `failed`, `inactive`) indique un problème de configuration ou d'installation à investiguer.

### Vérification du port d'écoute

Confirmer qu'Apache écoute bien sur le port **80** :

```bash
ss -tlnp | grep :80
```

Résultat attendu :

```
0.0.0.0:80
```

Cela confirme que le service accepte les connexions HTTP entrantes sur toutes les interfaces.

---

## 7. Test local

Tester l'accès au serveur web directement depuis la machine :

```bash
curl http://localhost
```

Résultat attendu : affichage du code HTML de la **page par défaut Apache**.

Ce test confirme que :

- Apache fonctionne correctement
- Le port 80 est accessible localement
- La configuration de base est opérationnelle
