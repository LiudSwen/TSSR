---
title: "Atelier - Snort - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2355/pages/8429"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Sécurité réseau

## Atelier - Snort

Difficile

3h

Auto-validation

Sécurité réseau

## Atelier - Snort

## Introduction

La détection d’intrusion consiste en un ensemble de techniques et méthodes utilisées pour détecter des activités suspectes au niveau d’un réseau et/ou d’un équipement.  
Il existe plusieurs catégories de systèmes de détection d’intrusion: les systèmes basant leur analyse sur des signatures, ceux qui détectent les anomalies, ceux qui utilise la réputation IP.  
Les systèmes qui se basent sur la signature (ports particuliers, mots clés dans les données utiles,...) fonctionnent de la même façon que les antivirus. Ils tentent de trouver des traces particulières dans les paquets examinés.  
Les systèmes de la seconde catégorie détectent les anomalies dans les entêtes des paquets par rapport aux protocoles standards.  
Enfin, ceux qui se basent sur la réputation reconnaissent les menaces en fonction de leur niveau de réputation. Ils collectent et suivent différents attributs de fichier tels que la source, la signature, l'âge et les statistiques d'utilisation des utilisateurs utilisant le fichier. Un moteur de réputation peut également être utilisé.  
**Snort** est un système de détection d’intrusion réseau, (***Network Intrusion Detection System***) open source couramment utilisé. Il permet d’analyser les flux de données par rapport à une base de données de signature, mais aussi de détecter les anomalies.  
Dans cet atelier, tu vas te servir de 2 VM, l'une étant configurée en IDS avec Snort, et l'autre servant de machine **attaquante**.

## 🎯 Objectifs:

✅ Installer Snort de différentes manière  
✅ Configurer Snort avec des règles pré-établie  
✅ Mettre en place des règles de surveillance ciblées

## Sommaire

- [✔️ Étape 1 - Prérequis](https://odyssey.wildcodeschool.com/quests/2355/pages/8429#%EF%B8%8F-%C3%A9tape-1---pr%C3%A9requis)
- [🔧 Étape 2 - Installation de Snort](https://odyssey.wildcodeschool.com/quests/2355/pages/8429#-%C3%A9tape-2---installation-de-snort)
	- [Méthode 1 - Avec apt](https://odyssey.wildcodeschool.com/quests/2355/pages/8429#m%C3%A9thode-1---avec-apt)
		- [Méthode 2 - À partir du site officiel de Snort](https://odyssey.wildcodeschool.com/quests/2355/pages/8429#m%C3%A9thode-2---%C3%A0-partir-du-site-officiel-de-snort)
		- [Méthode 3 - En compilant le code source](https://odyssey.wildcodeschool.com/quests/2355/pages/8429#m%C3%A9thode-3---en-compilant-le-code-source)
- [🔧 Étape 3 - Configuration de Snort](https://odyssey.wildcodeschool.com/quests/2355/pages/8429#-%C3%A9tape-3---configuration-de-snort)
- [🔧 Étape 4 - Mise en place de règles](https://odyssey.wildcodeschool.com/quests/2355/pages/8429#-%C3%A9tape-4---mise-en-place-de-r%C3%A8gles)
	- [Début de configuration](https://odyssey.wildcodeschool.com/quests/2355/pages/8429#d%C3%A9but-de-configuration)
		- [Règles de base](https://odyssey.wildcodeschool.com/quests/2355/pages/8429#r%C3%A8gles-de-base)
		- [Règles personnalisées](https://odyssey.wildcodeschool.com/quests/2355/pages/8429#r%C3%A8gles-personnalis%C3%A9es)
- [🔧 Étape 5 - Utilisation de la VM attaquante](https://odyssey.wildcodeschool.com/quests/2355/pages/8429#-%C3%A9tape-5---utilisation-de-la-vm-attaquante)
	- [Simulation d'attaques](https://odyssey.wildcodeschool.com/quests/2355/pages/8429#simulation-dattaques)
		- [Vérification des alertes](https://odyssey.wildcodeschool.com/quests/2355/pages/8429#v%C3%A9rification-des-alertes)

## ✔️ Étape 1 - Prérequis

Pour pouvoir faire cette quête tu as besoin de 2 machines paramétrées comme ceci:

- 1 machines Linux **Snort**:
	- Son rôle est de recevoir les attaques et d'analyser le flux réseau
		- Elle a la configuration réseau `10.10.1.10/24` avec le `mode promiscuité` activé
- 1 machine Linux **BadGuy**:
	- Elle elle va attaquer la machine **Snort**
		- Elle a l'adresse IP `10.10.1.20/24`
```shell
Cette configuration a été choisie pour limiter le nombre de machines à utiliser.

Si tu fais cette atelier avec des VM et que ta machine hôte le permet, ajoute une VM Linux GoodGuy avec la configuration IP 10.10.1.65/24.
Les attaques se feront en direction de cette machine, au lieu de la machine Snort.
```

## 🔧 Étape 2 - Installation de Snort

Sur la machine **Snort**, on va installer le logiciel Snort.

## Méthode 1 - Avec apt

Sur la machine Snort, exécute la ligne de commande `apt install snort`.  
Mettre l'adresse de réseau `10.10.1.0/24` à l'installation de Snort.

```shell
En faisant l'installation de Snort par le système apt, tu installe une version disponible dans les dépôts Ubuntu, mais ce n'est probablement pas la dernière version à jour.

La commande apt-cache policy snort indique que la version 2.9.15.1 est disponible dans les paquets, or sur le site officiel (info ici) la version 3 est disponible.

Avec les autres méthodes ci-dessous, tu peux installer la dernière version.
```

## Méthode 2 - À partir du site officiel de Snort

```shell
Installation à partir du site officiel snort.orgSelon ta version, suis le tuto d'installation disponible sur la page d'accueilhttps://www.snort.org/
```
```shell
Si tu as des messages d'erreurs à l'installation et que tu n'arrive pas à déboguer1
# Installation bibliothèques supplémentaires
2
apt-get install build-essential
3
apt-get install flex bison
4
apt-get install git libpcap-dev
5
Clic ici
```

## Méthode 3 - En compilant le code source

```shell
Installation à partir du code sourceDans cette installation détaillée, tu installe snort à partir du code source.

Ne fait que la partie installation.https://kifarunix.com/install-and-configure-snort-3-on-ubuntu/
```

Une fois l'installation terminée, vérifie avec la commande `systemctl status snort` que Snort est en cours d’exécution.  
Dans le résultat de cette commande, tu vois des lignes avec `Preprocessor Object`. Ce sont les **préprocesseurs**. Ce sont des modules d’extension pour arranger ou modifier les paquets de données avant que le moteur de détection n’intervienne. Certains préprocesseurs détectent aussi des anomalies dans les entêtes des paquets et génèrent alors des alertes.

```shell
Les preprocesseurs dans SnortTu as ici tout le détails sur ces préprocesseurs.https://www.oreilly.com/library/view/snort-cookbook/0596007914/ch04.html
```

## 🔧 Étape 3 - Configuration de Snort

Configuration de la carte réseau en mode promiscuité:

```bash
1
# Avec enp0s8 la carte réseau du réseau interne
2
ip link set dev enp0s8 promisc on
```

Vérifier avec `ip a` qu'il y a bien `PROMISC` dans la configuration de la carte.  
Désactivation du déchargement d'interface (*Interface Offloading*) pour empêcher Snort de tronquer les gros paquets de plus de 1518 octets:

```bash
1
# Avec enp0s8 la carte réseau du réseau interne
2
sudo ethtool -K enp0s8 gro off lro off
```

Vérification (tout doit être à `off`) avec la commande `ethtool -k enp0s8 | grep receive-offload`.

```shell
Ces changements sont temporaires et ne sont valable que pendant cette session. Après un reboot, ils reviendront à leur état d'origine.

Il faut exécuter la commande suivante (en root) :
cat > /etc/systemd/system/snort3-nic.service << 'EOL'

Et copier ceci dans le prompt (attention à bien changer le nom de l'interface réseau si ce n'est pas enp0s8) :
[Unit]

Description=Set Snort 3 NIC in promiscuous mode and Disable GRO, LRO on boot

After=network.target
[Service]

Type=oneshot

ExecStart=/usr/sbin/ip link set dev enp0s8 promisc on

ExecStart=/usr/sbin/ethtool -K enp0s8 gro off lro off

TimeoutStartSec=0

RemainAfterExit=yes
[Install]

WantedBy=default.target

EOL
```

Rechargement des paramètres de configuration de **systemd** avec `sudo systemctl daemon-reload`.  
Démarrage et activation du service au boot avec `sudo systemctl enable --now snort3-nic.service`.

## 🔧 Étape 4 - Mise en place de règles

## Début de configuration

Il existe 3 types de règles:

- Les règles de la communauté
- Les règles enregistrées
- Les règles réservées aux abonnés

Ici on va utiliser **les règles de la communauté**.

Le fichier de configuration est `/usr/local/etc/snort/snort_defaults.lua`.  
Créer le répertoire `rules` des règles dans `/usr/local/etc/`.  
Exécuter les commandes ci-dessous pour télécharger les règles et décompresser le fichier dans le dossier des règles (qui est `/usr/local/etc/rules/`):

```bash
1
cd /usr/local/etc/rules/
2
sudo wget https://www.snort.org/downloads/community/snort3-community-rules.tar.gz
3
sudo tar xzf snort3-community-rules.tar.gz
```

Vérifier qu'il y a bien un fichier `snort3-community.rules` dans `/usr/local/etc/rules/snort3-community-rules/`.

## Règles de base

Editer le fichier `/usr/local/etc/snort/snort.lua`.  
Modifier la variable `HOME_NET` avec l'adresse IP de la machine Snort (au lieu de `any`).  
Ne pas oublier le CIDR!  
Modifier la variable `EXTERNAL_NET` avec la valeur `'!$HOME_NET'` (au lieu de `any`).

```shell
Cette configuration de variables sert à protéger le réseau contre les attaques.

Ici on met une adresse IP pour HOME_NET, mais cela peu être un sous-réseau.

EXTERNAL_NET ici prend toutes les valeurs autres que celles de HOME_NET.
```

Dans la partie `ips = { ...` remplacer `variables = default_variables` par:

```bash
1
variables = default_variables,
2
rules = [[ 
3
    include $RULE_PATH/snort3-community-rules/snort3-community.rules
4
    ]]
```
```shell
Ceci permet d'ajouter les règles de la communauté comme règles par défaut.
```

Sauvegarder et sortir du fichier.

## Règles personnalisées

Créer un fichier de règles personnalisées `/usr/local/etc/rules/local.rules`.  
Dans ce fichier, ajouter des règles personnalisées, par exemple:

```bash
1
alert icmp any any -> $HOME_NET any (msg:"ICMP Ping detected"; sid:1000001; rev:1;)
2
alert tcp any any -> $HOME_NET 22 (msg:"SSH connection attempt"; sid:1000002; rev:1;)
```

Sauvegarder et fermer le fichier.  
Editer le fichier de configuration principal `/usr/local/etc/snort/snort.lua` pour ajouter le path de ce fichier de règles personnalisées:

```bash
1
rules = [[ 
2
    include $RULE_PATH/snort3-community-rules/snort3-community.rules
3
    include $RULE_PATH/local.rules
4
    ]]
```

Redémarrer Snort pour appliquer les nouvelles règles.

## 🔧 Étape 5 - Utilisation de la VM attaquante

## Simulation d'attaques

Lancer des attaques depuis la machine **BadGuy** vers la machine **Snort** (ou **GoodGuy** si tu utilise 3 machines) pour vérifier la détection:

- Fais un test de ping vers la machine cible
- Fais une tentative de connexion SSH vers la machine cible

## Vérification des alertes

Sur la machine **Snort**, tu dois avoir les alertes générées par les attaques.  
Vérifie le contenu du fichier `/var/log/snort/alert`.

Cet atelier est considéré comme réussi si tu as bien la détection des attaques sur la machine snort.

Quête terminée le **vendredi 13 mars 2026**