# Installation de pfSense

## Sommaire

[1. Installation de pfSense](#1-installation-de-pfsense)  
[2. Première configuration CLI de pfSense](#2-première-configuration-cli-de-pfsense)  


### 1. Installation de pfSense

Dans ce premier chapitre nous allons effectuer l'installation complète de pfSense. 

- Sélectionner et appuyer sur `Accept`

![img](Ressources/01_installation/01_pfsense.png)

1) Sélectionner et appuyer sur `Install` 
2) Sélectionner et appuyer sur `OK`

![img](Ressources/01_installation/02_pfsense.png)

- Sélectionner et appuyer sur `OK`

![img](Ressources/01_installation/03_pfsense.png)

1) Sélectionner l'interface réseau `WAN`
2) Sélectionner et appuyer sur `OK`

![img](Ressources/01_installation/04_pfsense.png)

1) Sélectionner `Continue`
2) Sélectionner et appuyer sur `OK`

![img](Ressources/01_installation/05_pfsense.png)


1) Sélectionner l'interface réseau `LAN`
2) Sélectionner et appuyer sur `OK`

![img](Ressources/01_installation/06_pfsense.png)

1) Sélectionner `Continue`
2) Sélectionner et appuyer sur `OK`

![img](Ressources/01_installation/07_pfsense.png)

1) Sélectionner l'interface `WAN`
2) Sélectionner et appuyer sur `Continuer`

![img](Ressources/01_installation/08_pfsense.png)

- Vérification de la connection internet

![img](Ressources/01_installation/09_pfsense.png)

- Sélectionner et appuyer sur `Install CE`

![img](Ressources/01_installation/10_pfsense.png)

1) Sélectioner sur `Continue`
2) Sélectionner et appuyer `OK`

![img](Ressources/01_installation/11_pfsense.png)

- Sélectionner et appuyer sur `OK`

![img](Ressources/01_installation/12_pfsense.png)

1) Sélectionner le disque pour l'installation
2) Sélectionner et appuyer sur `OK`

![img](Ressources/01_installation/13_pfsense.png)

- Confirmer l'installation sur le disque sélectionné

![img](Ressources/01_installation/14_pfsense.png)

1) Sélectionner la version a installer (`Current Stable` de préférence)
2) Sélectionner et appuyer sur `OK`

![img](Ressources/01_installation/15_pfsense.png)

- Fenêtre d'installation en cours

![img](Ressources/01_installation/15_01_pfsense.png)

- Fenêtre de confirmation d'installation

![img](Ressources/01_installation/16_pfsense.png)

- Sélectionner `Reboot`

![img](Ressources/01_installation/17_pfsense.png)

- **Installation terminée**, Menu CLI

![img](Ressources/01_installation/18_pfsense.png)


## 2. Première configuration CLI de pfSense

Dans ce chapitre nous allons effectuer les premières configuration à partir de l'interface CLI de pfSense pour nous permettre un accès WEB.

- Entrer l'option 2

![img](Ressources/02_configuration_cli/01_configuration.png)

- Entrer l'option 2 pour sélectionner l'interface `LAN`

![img](Ressources/02_configuration_cli/02_configuration.png)

- Entrer `n` pour la configuration de DHCP

![img](Ressources/02_configuration_cli/03_configuration.png)

- Entrer l'adresse IP de l'interface LAN (10.10.10.1)

![img](Ressources/02_configuration_cli/04_configuration.png)

- Entrer le CIDR du réseau (30)

![img](Ressources/02_configuration_cli/05_configuration.png)

- Ne rien saisir et appuyer sur `Entrée`

![img](Ressources/02_configuration_cli/06_configuration.png)

- Entrer `n` pour la configuration de DHCP6

![img](Ressources/02_configuration_cli/08_configuration.png)

- Ne rien saisir et appuyer sur `Entrée`

![img](Ressources/02_configuration_cli/09_configuration.png)

- Entrer `n` pour l'activation du DHCP server sur le LAN

![img](Ressources/02_configuration_cli/10_configuration.png)

- Entrer `y` pour accéder à l'interface par le procotol HTTP, sinon entrer `n` pour accéder seulement pas HTTPS

![img](Ressources/02_configuration_cli/11_configuration.png)

- Ecran de confirmation de configurer, appuyer sur `Entrée` pour continuer

![img](Ressources/02_configuration_cli/12_configuration.png)

- Configuration de l'interface LAN terminé

![img](Ressources/02_configuration_cli/13_configuration.png)
