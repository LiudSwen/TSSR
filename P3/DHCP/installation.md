## Sommaire

1. [Configuration réseau du serveur DHCP (Server Core)](#1-configuration-reseau-du-serveur-dhcp-server-core)
2. [Configuration DNS sur le serveur DHCP](#2-configuration-dns-sur-le-serveur-dhcp)
3. [Installation du rôle DHCP (Windows Server Core)](#3-installation-du-role-dhcp-windows-server-core)
4. [Désactivation temporaire du pare-feu Windows](#4-desactivation-temporaire-du-pare-feu-windows)
5. [Jonction du serveur DHCP au domaine Active Directory](#5-jonction-du-serveur-dhcp-au-domaine-active-directory)
6. [Post-installation du rôle DHCP et autorisation dans Active Directory](#6-post-installation-du-role-dhcp-et-autorisation-dans-active-directory)
7. [Installation des outils d’administration DHCP sur le serveur GLI](#7-installation-des-outils-dadministration-dhcp-sur-le-serveur-gli)
8. [Administration du serveur DHCP depuis le serveur GLI](#8-administration-du-serveur-dhcp-depuis-le-serveur-gli)
9. [Conclusion](#9-conclusion)


## 1. Configuration réseau du serveur DHCP (Server Core)

À l’arrivée sur l’interface **SConfig**, l’objectif est de configurer une **adresse IP statique** afin d’intégrer correctement le serveur au réseau et au domaine.

### Accès aux paramètres réseau
- Appuyer sur **8** puis **Entrée** pour accéder à la configuration réseau.

![Accès au menu réseau SConfig](Ressources/01_installation/dhcp-sconfig-network-menu.png)

Vous arrivez dans le menu des paramètres réseau.

### Sélection de la carte réseau
- Choisir la carte réseau à modifier

![Sélection de la carte réseau](Ressources/01_installation/dhcp-sconfig-select-nic.png)

- Appuyer sur **Entrée**

### Configuration de l’adresse IP
Dans le menu **Network Adapter Settings** :

- Appuyer sur **1** pour accéder aux paramètres IP

Renseigner les champs suivants :
- **S** (Static)
- **Adresse IP** : `172.16.12.2`
- **Masque** : `255.255.255.248`
- **Passerelle** : `172.16.12.6`

![Configuration de l’adresse IP statique](Ressources/01_installation/dhcp-sconfig-ip-config.png)

Valider avec **Entrée**.

![Résultat de la configuration IP](Ressources/01_installation/dhcp-sconfig-ip-result.png)

Une fois la configuration appliquée, appuyer à nouveau sur **Entrée** pour revenir au menu précédent.

---

## 2. Configuration DNS sur le serveur DHCP

Toujours dans le menu de configuration de la carte réseau :
### Paramétrage du serveur DNS

- Appuyer sur **2** pour accéder à **Set DNS Server**

Renseigner :
- **Preferred DNS** : `172.16.12.1`

![Configuration du serveur DNS](Ressources/01_installation/dhcp-sconfig-dns-config.png)

- **Alternate DNS** : laisser vide (Entrée)

Ce DNS correspond au **serveur AD DS / DNS**.

---

## 3. Installation du rôle DHCP (Server Core)

Retourner au menu principal de **SConfig** puis :

- Choisir **15 – Exit to command line**

Dans la console PowerShell, exécuter la commande suivante :
Install-WindowsFeature DHCP -IncludeManagementTools

![Commande d’installation du rôle DHCP](Ressources/01_installation/dhcp-role-install-command.png)

L’installation démarre.

![Progression de l’installation DHCP](Ressources/01_installation/dhcp-role-install-progress.png)

Une fois la barre de progression terminée, le rôle DHCP est installé sur le serveur Core.

![Installation du rôle DHCP terminée](Ressources/01_installation/dhcp-role-install-success.png)

---

## 4. Désactivation temporaire du pare-feu Windows

Dans l’attente de la mise en place du pare-feu **pfSense**, le pare-feu Windows est désactivé temporairement afin d’assurer la communication réseau.

Commande PowerShell :
`Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False`

![Désactivation temporaire du pare-feu Windows](Ressources/01_installation/dhcp-firewall-disable.png)

Cette désactivation est **temporaire** et doit être revue en production.

---

## 5. Jonction du serveur DHCP au domaine Active Directory

Le serveur DHCP doit être joint au domaine `billu.lan`.

Dans PowerShell :
Add-Computer -DomainName "billu.lan" -Credential (Get-Credential)

![Jonction du serveur DHCP au domaine](Ressources/01_installation/dhcp-join-domain-command.png)

Renseigner les identifiants d’un compte autorisé à joindre des machines au domaine.

Après validation :
- Se connecter avec le compte **Administrator du domaine**
- Utiliser le mot de passe défini précédemment

![Connexion avec le compte domaine](Ressources/01_installation/dhcp-domain-login.png)

Un redémarrage est nécessaire.

Une fois redémarré, le serveur DHCP est **membre du domaine**.

---

## 6. Post-installation DHCP et autorisation dans l’AD

Depuis le **serveur GLI**, ouvrir **Server Manager**.

### Ajout du serveur DHCP Core
- Dans **Manage** → **Add Servers**

![Ajout du serveur DHCP dans Server Manager](Ressources/01_installation/dhcp-gli-add-server.png)

- Rechercher le serveur DHCP par son nom
- Le sélectionner et l’ajouter

### Autorisation du serveur DHCP
Lors de la configuration du déploiement DHCP :
- Dans la section **Authorization**
- Choisir **Use the following user's credentials**
- Cliquer sur **Commit**

![Autorisation du serveur DHCP dans Active Directory](Ressources/01_installation/dhcp-gli-authorization.png)

Le serveur DHCP est maintenant autorisé dans Active Directory.

---
## 7. Installation des outils DHCP sur le serveur GLI

Afin d’administrer le serveur DHCP Core, les outils DHCP doivent être installés sur le serveur GLI.

Sur le **serveur GLI** :
1. **Server Manager**
2. **Add Roles and Features**
3. **Features**
4. Cocher :
    - Remote Server Administration Tools (RSAT)
    - Role Administration Tools
    - DHCP Server Tools
        - DHCP Management Tools
5. Installer

---

## 8. Ajout et administration du serveur DHCP depuis le GLI

### Ouverture de la console DHCP

- Menu Windows → **Tools** → **DHCP**
### Ajout du serveur DHCP

- Clic droit sur **DHCP**
- **Add Server…**

![Ajout du serveur DHCP dans la console DHCP](Ressources/01_installation/dhcp-gli-console-add-server.png)

- Choisir :
    - **This authorized DHCP server**
- Sélectionner le serveur DHCP souhaité

Validation.

---

## Conclusion

Le serveur DHCP est désormais :
- Installé sur **Windows Server Core**
- Joint au domaine Active Directory
- Autorisé dans l’AD
- Administrable à distance depuis le serveur GLI

L’infrastructure est prête pour la création des **scopes DHCP**, options réseau et réservations.
