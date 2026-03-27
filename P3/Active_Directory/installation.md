## Sommaire

1. [Prérequis](#1-prerequis)
    - [1.1 Matériel requis](#11-materiel-requis)
	- [1.2 Configuration réseau](#12-configuration-reseau)
	- [1.3 Logiciels](#13-logiciels)
2. [Préparation du serveur](#2-préparation-du-serveur)
	- [2.1 Renommage du serveur](#21-renommage-du-serveur)
	- [2.2 Configuration IP statique via GUI](#22-configuration-ip-statique-via-gui)
3. [Installation du rôle AD DS via GUI](#3-installation-du-role-ad-ds-via-gui)
4. [Création du domaine Active Directory](#4-creation-du-domaine-active-directory)
	- [4.1 Création d'une nouvelle forêt](#41-creation-d-une-nouvelle-foret)
	- [4.2 Options du contrôleur de domaine](#42-options-du-controleur-de-domaine)
5. [Vérification de l'installation](#5-verification-de-l-installation)
	- [5.1 Service AD DS](#51-service-ad-ds)
	- [5.2 Service DNS](#52-service-dns)
	- [5.3 Rôles FSMO](#53-roles-fsmo)


## 1. Prérequis
#### 1.1 Matériel requis

- Serveur Windows Server 2022
- 4 GO RAM minimum
- 40 Go d'espace disque minimum
#### 1.2 Configuration réseau

- Adresse IP statique : **172.16.12.1**
- Masque de sous réseau : **255.255.255.248**
- Adresse de Passerelle : **172.16.12.6**

#### 1.3 Logiciels

- Windows Server 2022 Standard
- Dernières mise à jour installées

## 2. Préparation du serveur

#### 2.1 Renommage du serveur

Voici la commande pour renommer le serveur, PowerShell doit être en administrateur :

```powershell
Rename-Computer -NewName "DOM-AD-01" -Restart
```


#### 2.2 Configuration IP statique via GUI

1. **Ouvrir le menu Windows** :
	- Cliquer droit sur l'icône réseau (barre des taches)
	- Cliquer sur **network & Internet settings**

 
![image01](Ressources/Screenshots-Installation/01_conf_ip_ad.png)


 2. **Accéder aux propriétés de la carte réseau** :
	 - Cliquer sur Change adapter options
	 - Cliquer droit sur **"Ethernet2"** (ou le nom de votre carte réseau)
	 - Sélectionner **"Properties"**

![image02](Ressources/Screenshots-Installation/02_conf_ip_ad.png)


3. **Configurer IPv4** :

	- Double -cliquer sur **"Internet Protocol Version 4"**
	- Cocher la case **"Use the following IP address"**
	- **"IP adress"** : 172.16.12.1
	- **"Subnet mask"** : 255.255.255.248
	- **"Default gateway"**: 172.16.12.6
	- Cliquer sur **"OK"**

![image03](Ressources/Screenshots-Installation/03_conf_ip_ad.png)


4. Vérification de la configuration

Taper cette commande dans PowerShell pour vérifier notre configuration :

```powershell
ipconfig /all
```

![image04](Ressources/Screenshots-Installation/04_conf_ip_ad.png)


## 3. Installation du rôle AD DS via GUI

- Dans le **"Server Manager"**, aller dans le menu  **"Manage ==>Add Roles and Feautures"**:

![image01](Ressources/Screenshots-Installation/01_install_adds.png)

- Cliquer 3 fois sur la touche **"Next"**
- Cocher les cases **"Active Directory Domain Service"** et **"DNS Server"**

![image02](Ressources/Screenshots-Installation/02_install_adds.png)


- Cliquer 4 fois sur **"Next"**
- Cliquer sur **"Install"** et **"Close"**

![image03](Ressources/Screenshots-Installation/03_install_adds.png)

![image04](Ressources/Screenshots-Installation/04_install_adds.png)


- Attendre la fin de la configuration et redémarrer le serveur.
![image05](Ressources/Screenshots-Installation/05_install_adds.png)


## 4. Création du domaine Active Directory

#### 4.1 Création d'une nouvelle Forêt

- Cliquer sur le drapeau de notification dans **"Server Manager"**
- Cliquer sur **"Promote this server to a domain controller"**
![image01](Ressources/Screenshots-Installation/01_creation_foret_ad.png)

- Sélectionner **"Add a new forest"**
- Nom du domaine racine : **"billu.lan"**

![image02](Ressources/Screenshots-Installation/02_creation_foret_ad.png)


- Clique sur **"Next"**
#### 4.2 Options du contrôleur de domaine

- Vérifier que la case **"Domain Name System (DNS) server"** soit coché.
- Vérifier également la case **"Global Catalog (gc)"** soit coché.
- Définir le mot de passe **"DSRM"** en cas de restauration.
- Dans ce cas cela sera : **Azerty1****

![image01](Ressources/Screenshots-Installation/01_controleur_domaine_ad.png)


- Clique sur **"Next"** 4 fois.
- Clique sur **"Install"**
- Attendre la fin de l'installation et le serveur va redémarrer automatiquement.
![image02](Ressources/Screenshots-Installation/02_controleur_domaine_ad.png)


## 5. Vérification de l'installation

#### 5.1 Service AD DS

- Ouvrir **"Server Manager"**
- Cliqué sur **"AD DS"** dans le menu de gauche
- Vérifier que le serveur **"DOM-AD-01"** apparaît avec le statut **"Online"**

![image01](Ressources/Screenshots-Installation/01_verif_install_dns.png)


#### 5.2 Service DNS

- Ouvrir **"Server Manager"**
- Cliqué sur **"DNS"** dans le menu de gauche
- Vérifier que le serveur **"DOM-AD-01"** apparaît avec le statut **"Online"**
![image02](Ressources/Screenshots-Installation/02_verif_install_dns.png)


#### 5.3 Rôles FSMO

- Dans PowerShell tape les commandes suivantes :

```powershell
Get-ADDomain | Select-Object PDCEmulator, RIDMaster, InfrastructureMaster
```

![image03](Ressources/Screenshots-Installation/03_verif_install_FSMO.png)


```powershell
Get-ADForest | Select-Object 
```

![image04](Ressources/Screenshots-Installation/04_verif_install_FSMO.png)


Les 5 rôles pointent bien vers le serveur **"DOM-AD-01"** donc l'installation à bien été effectuer.