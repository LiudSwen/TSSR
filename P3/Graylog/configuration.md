# Sommaire - Guide de configuration Graylog

1. [Création d'un compte Administrateur](#1-création-dun-compte-administrateur)
2. [Installation et configuration des agents NXLog sur les machines Windows Graphique](#2-installation-et-configuration-des-agents-nxlog-sur-les-machines-windows-graphique)
   - 2.1 [Liste des machines pour l'installation des agents](#21-liste-des-machines-pour-linstallation-des-agents)
   - 2.2 [Téléchargement et installation de NXLog sur Windows](#22-téléchargement-et-installation-de-nxlog-sur-windows)
   - 2.3 [Modification du fichier nxlog.conf](#23-modification-du-fichier-nxlogconf)
   - 2.4 [Redémarrage du service](#24-redémarrage-du-service)
3. [Installation et configuration des agents NXLog sur les machines Windows Core](#3-installation-et-configuration-des-agents-nxlog-sur-les-machines-windows-core)
   - 3.1 [Liste des machines pour l'installation des agents](#31-liste-des-machines-pour-linstallation-des-agents)
   - 3.2 [Copie du fichier MSI et installation de NXLog sur Windows Core](#32-copie-du-fichier-msi-et-installation-de-nxlog-sur-windows-core)
   - 3.3 [Modification du fichier nxlog.conf](#33-modification-du-fichier-nxlogconf)
   - 3.4 [Redémarrage du service](#34-redémarrage-du-service)
4. [Configuration de Linux](#4-configuration-de-linux)
   - 4.1 [Liste des machines pour la configuration rsyslog](#41-liste-des-machines-pour-la-configuration-rsyslog)
   - 4.2 [Installation et vérification de rsyslog](#42-installation-et-vérification-de-rsyslog)
   - 4.3 [Configuration du fichier rsyslog](#43-configuration-du-fichier-rsyslog)
   - 4.4 [Redémarrage du service](#44-redémarrage-du-service)
5. [Configuration de Graylog](#5-configuration-de-graylog)
   - 5.1 [Création d'un input NXLog pour Windows](#51-création-dun-input-nxlog-pour-windows)
   - 5.2 [Création d'un input Syslog pour Linux](#52-création-dun-input-syslog-pour-linux)
   - 5.3 [Création des Streams pour chaque serveur](#53-création-des-streams-pour-chaque-serveur)
      - 5.3.1 [Création d'un stream](#531-création-dun-stream)
      - 5.3.2 [Création des streams de l'infrastructure](#532-création-des-streams-de-linfrastructure)
---  

### 1. Création d'un compte Administrateur

1) Naviguer dans l'onglet **System**
2) Cliquer sur **Users and Teams**
3) Cliquer sur **Create user**

![img](Ressources/graylog_img/configuration/01_admin_account/01_graylog_configuration.png)

1) Entrer un prénom 
2) Entrer un nom 
3) Entrer un username 
4) Entrer une adresse Email
5) Choisir la Time Zone **Paris**
6) Assigner le rôle **Admin**
7) Il doit apparaître dans les **Selected Roles**
8) Saisir un mot de passe
9) Cliquer sur **Create user**

![img](Ressources/graylog_img/configuration/01_admin_account/02_graylog_configuration.png)

- Le compte doit apparaître dans les **Users**

![img](Ressources/graylog_img/configuration/01_admin_account/03_graylog_configuration.png)

---  

### 2. Installation et configuration des agents NXLog sur les machines Windows Graphique

#### 2.1 Liste des machines pour l'installation des agents
- DOM-AD-01


#### 2.2 Téléchargement et installation de NXLog sur Windows

1) Télécharger NXLog pour Windows : https://nxlog.co/downloads

2) Installer NXLog, pour chaque étape cliquer sur `Next`

#### 2.3 Modification du fichier nxlog.conf

1) Ouvrir le fichier `C:\Program Files\nxlog\conf\nxlog.conf` avec un éditeur de texte

2) Remplacer tout le contenu du fichier par :
  
```
Panic Soft
#NoFreeOnExit TRUE

define ROOT     C:\Program Files\nxlog
define CERTDIR  %ROOT%\cert
define CONFDIR  %ROOT%\conf\nxlog.d
define LOGDIR   %ROOT%\data
define LOGFILE  %LOGDIR%\nxlog.log

LogFile %LOGFILE%
Moduledir %ROOT%\modules
CacheDir  %ROOT%\data
Pidfile   %ROOT%\data\nxlog.pid
SpoolDir  %ROOT%\data

# NE PAS inclure d'autres fichiers pour éviter les conflits
# include %CONFDIR%\\*.conf

<Extension _syslog>
    Module      xm_syslog
</Extension>

<Extension _charconv>
    Module      xm_charconv
    AutodetectCharsets iso8859-2, utf-8, utf-16, utf-32
</Extension>

<Extension _exec>
    Module      xm_exec
</Extension>

<Extension _fileop>
    Module      xm_fileop
    <Schedule>
        Every   1 hour
        Exec    if (file_exists('%LOGFILE%') and \
                   (file_size('%LOGFILE%') >= 5M)) \
                    file_cycle('%LOGFILE%', 8);
    </Schedule>
    <Schedule>
        When    @weekly
        Exec    if file_exists('%LOGFILE%') file_cycle('%LOGFILE%', 8);
    </Schedule>
</Extension>

<Extension gelf>
    Module      xm_gelf
</Extension>

# ============================================================================
# INPUT - Collecte TOUS les événements Windows
# ============================================================================
<Input in>
    Module      im_msvistalog
</Input>

# ============================================================================
# OUTPUT - Envoi vers Graylog
# ============================================================================
<Output out>
    Module      om_tcp
    Host        172.16.13.2
    Port        12201
    OutputType  GELF_TCP
    Exec $Hostname = hostname();
</Output>

# ============================================================================
# ROUTE - Connexion Input -> Output
# ============================================================================
<Route 1>
    Path        in => out
</Route>
```

#### 2.4 Redémarrage du service

1) Redémarrer le service NXLog avec la commande Powershell :

- **Utiliser une console powershell en mode Administrateur**

```bash
Restart-Service nxlog
```

2) Vérifier que le service est bien démarré avec la commande Powershell : 
```bash
Get-Service nxlog
```

---  

### 3. Installation et configuration des agents NXLog sur les machines Windows Core

#### 3.1 Liste des machines pour l'installation des agents
- DOM-DHCP-01 - 172.16.12.2
- DOM-FS-01 - 172.16.13.4

#### 3.2 Copie du fichier MSI et installation de NXLog sur Windows Core

- **A partir du PC Administration**

1) A partir de l'explorateur Windows de la machine Administration, entrer l'adresse de l'emplacement du fichier d'installation NXLog :
```
\\DOM-FS-01\departements\dsi\softwares
```

2) Créer le dossier **Temp** à la racine de `C:\` des machines distantes à l'emplacement :
```
# Pour le serveur DHCP
\\DOM-DHCP-01\c$\
```
```
# Pour le serveur FS
\\DOM-FS-01\c$\
```

3) Copier le fichier `nxlog-ce-3.2.2329.msi` sur le serveur Core à l'emplacement :  

```
# Pour le serveur DHCP
\\DOM-DHCP-01\c$\Temp
```

```
# Pour le serveur FS
\\DOM-FS-01\c$\Temp
```

3) Executer la commande pour installer NXLog dans la console du Windows Core ou par SSH sur la machine distante :

- La terminaison du fichier MSI nxlog peut changer suivant la version du fichier.

```
msiexec /i "C:\Temp\nxlog-ce-3.2.2329.msi" /qn /norestart
```


#### 3.3 Modification du fichier nxlog.conf


1) Ouvrir le fichier `nxlog.conf` avec un éditeur de texte à l'emplacement : 

```
# Pour le serveur DHCP
\\DOM-DHCP-01\c$\Program Files\nxlog\conf\nxlog.conf
```

```
# Pour le serveur FS
\\DOM-FS-01\c$\Program Files\nxlog\conf\nxlog.conf
```

2) Remplacer tout le contenu du fichier par :
  
```
Panic Soft
#NoFreeOnExit TRUE

define ROOT     C:\Program Files\nxlog
define CERTDIR  %ROOT%\cert
define CONFDIR  %ROOT%\conf\nxlog.d
define LOGDIR   %ROOT%\data
define LOGFILE  %LOGDIR%\nxlog.log

LogFile %LOGFILE%
Moduledir %ROOT%\modules
CacheDir  %ROOT%\data
Pidfile   %ROOT%\data\nxlog.pid
SpoolDir  %ROOT%\data

# NE PAS inclure d'autres fichiers pour éviter les conflits
# include %CONFDIR%\\*.conf

<Extension _syslog>
    Module      xm_syslog
</Extension>

<Extension _charconv>
    Module      xm_charconv
    AutodetectCharsets iso8859-2, utf-8, utf-16, utf-32
</Extension>

<Extension _exec>
    Module      xm_exec
</Extension>

<Extension _fileop>
    Module      xm_fileop
    <Schedule>
        Every   1 hour
        Exec    if (file_exists('%LOGFILE%') and \
                   (file_size('%LOGFILE%') >= 5M)) \
                    file_cycle('%LOGFILE%', 8);
    </Schedule>
    <Schedule>
        When    @weekly
        Exec    if file_exists('%LOGFILE%') file_cycle('%LOGFILE%', 8);
    </Schedule>
</Extension>

<Extension gelf>
    Module      xm_gelf
</Extension>

# ============================================================================
# INPUT - Collecte TOUS les événements Windows
# ============================================================================
<Input in>
    Module      im_msvistalog
</Input>

# ============================================================================
# OUTPUT - Envoi vers Graylog
# ============================================================================
<Output out>
    Module      om_tcp
    Host        172.16.13.2
    Port        12201
    OutputType  GELF_TCP
    Exec $Hostname = hostname();
</Output>

# ============================================================================
# ROUTE - Connexion Input -> Output
# ============================================================================
<Route 1>
    Path        in => out
</Route>
```

#### 3.4 Redémarrage du service

1) Redémarrer le service NXLog avec la commande Powershell :

- **Utiliser une console powershell en mode Administrateur**

```bash
Restart-Service nxlog
```

2) Vérifier que le service est bien démarré avec la commande Powershell : 
```bash
Get-Service nxlog
```

---  

### 4. Configuration de Linux

#### 4.1 Liste des machines pour la configuration rsyslog
- DOM-GLPI-01 - 172.16.13.1
- DOM-LOGS-01 - 172.16.13.2
- DOM-ZABBIX-01 - 172.16.13.3
- DOM-WEBINT-01 - 172.16.13.5

#### 4.2 Installation et vérification de rsyslog

**Se connecter en root ou utiliser sudo pour les commandes nécessaires**

1) Vérifier si **rsyslog** est bien installé
```bash
systemctl status rsyslog
```

2) Installer syslog si celui-ci n'est pas installé avec la commande 
```bash
apt install rsyslog -y
```

#### 4.3 Configuration du fichier rsyslog

1) Ouvrir ou créer le fichier `nano /etc/rsyslog.d/90-graylog.conf` et ajouter :

> **Note :** L'adresse IP `172.16.13.2` correspond au serveur Graylog
```bash
# Configuration Graylog
*.* @172.16.13.2:514
```

2) Vérifier la configuration avec la commande `rsyslogd -N1`
```bash
rsyslogd -N1
```

#### 4.4 Redémarrage du service

1) Redémarrer le service avec la commande :
```bash
systemctl restart rsyslog
```

2) Vérifier le status du service :
```bash
systemctl status rsyslog
```

---  

### 5. Configuration de Graylog

#### 5.1 Création d'un input NXLog pour Windows

- Naviguer dans l'onglet **System** et cliquer sur **Inputs**

![img](Ressources/graylog_img/configuration/03_create_input/01_graylog_input.png)

1) Sélectionner **GELF TCP** dans la liste
2) Cliquer sur **Launch new input**

![img](Ressources/graylog_img/configuration/03_create_input/02_graylog_input.png)

1) Mettre en titre `NXLog_TCP_Windows`
2) Descendre et cliquer sur **Launch Input**

![img](Ressources/graylog_img/configuration/03_create_input/03_graylog_input.png)
![img](Ressources/graylog_img/configuration/03_create_input/04_graylog_input.png)

- L'input **NXLog_TCP_Windows** doit apparaître dans **Global inputs**

![img](Ressources/graylog_img/configuration/03_create_input/05_graylog_input.png)


1) Cliquer sur **Set-up Input**
2) Cliquer sur **Next**

![img](Ressources/graylog_img/configuration/03_create_input/06_graylog_input.png)

- Cliquer sur **Start Input**

![img](Ressources/graylog_img/configuration/03_create_input/07_graylog_input.png)

- Cliquer sur **Launch Input Diagnosis**

![img](Ressources/graylog_img/configuration/03_create_input/08_graylog_input.png)

- Vérifier que l'input est bien actif 

![img](Ressources/graylog_img/configuration/03_create_input/09_graylog_input.png)

#### 5.2 Création d'un input Syslog pour Linux

- Sélectionner **Syslog UDP** dans la liste et cliquer sur **Launch new input**

![img](Ressources/graylog_img/configuration/03_create_input/10_graylog_input.png)

1) Mettre en titre `SYSLOG_UDP_Linux`
2) Descendre et sélectionner `Europe/Paris` dans la **Time Zone**
3) Cliquer sur **Launch Input**

![img](Ressources/graylog_img/configuration/03_create_input/11_graylog_input.png)
![img](Ressources/graylog_img/configuration/03_create_input/12_graylog_input.png)

- L'input **SYSLOG_UDP_Linux** doit apparaître dans **Global inputs**

![img](Ressources/graylog_img/configuration/03_create_input/13_graylog_input.png)

1) Cliquer sur **Set-up Input**
2) Cliquer sur **Create Stream**
3) Cliquer sur **Next**

![img](Ressources/graylog_img/configuration/03_create_input/14_graylog_input.png)

- Cliquer sur **Start Input**

![img](Ressources/graylog_img/configuration/03_create_input/15_graylog_input.png)

- Cliquer sur **Launch Input Diagnosis**

![img](Ressources/graylog_img/configuration/03_create_input/16_graylog_input.png)

- Vérifier que l'input est bien actif 

![img](Ressources/graylog_img/configuration/03_create_input/17_graylog_input.png)


#### 5.3 Création des Streams pour chaque serveur

##### 5.3.1 Création d'un stream

**Pour cette partie, la première partie sert d'exemple. Entrer les paramètres pour chaque stream dans la partie 4.3.2**

1) Cliquer sur l'onglet **Streams**
2) Cliquer sur **Create Stream**

![img](Ressources/graylog_img/configuration/04_create_streams/01_graylog_streams.png)

1) Title : DOM-AD-01
2) Description : Serveur Active Directory
3) Add Collaborator : 
    - **Un Administrateur** `DOM Admin`
    - Sélectionner `Manager` 
    - Cliquer sur **Add Collaborator**
4) Cliquer sur **Create stream**

![img](Ressources/graylog_img/configuration/04_create_streams/02_graylog_streams.png)

- Cliquer sur **Data Routing**

![img](Ressources/graylog_img/configuration/04_create_streams/03_graylog_streams.png)

- Cliquer sur **Create Rule**

![img](Ressources/graylog_img/configuration/04_create_streams/04_graylog_streams.png)

1) Field : Sélectionner `source`
2) Type : Sélectionner `Contain`
3) Value : Entrer le nom du serveur `DOM-AD-01`
4) Description : Serveur Active Directory
5) Cliquer sur **Create Rule**

![img](Ressources/graylog_img/configuration/04_create_streams/05_graylog_streams.png)

- La règle doit apparaître dans **Rule**

![img](Ressources/graylog_img/configuration/04_create_streams/06_graylog_streams.png)

- Cliquer sur le bouton `Lecture` pour activer le stream

![img](Ressources/graylog_img/configuration/04_create_streams/07_graylog_streams.png)

---  

##### 5.3.2 Création des streams de l'infrastructure

**Instructions :** Pour chaque serveur ci-dessous, suivre la procédure détaillée en 5.3.1 en utilisant les paramètres indiqués.

> **Note :** Le Stream 1 (DOM-AD-01) a déjà été créé comme exemple en section 5.3.1. Voici les paramètres pour les streams restants.

---  

###### Stream 2 : Serveur DHCP
**Paramètres du Stream :**
- **Title :** DOM-DHCP-01
- **Description :** Serveur DHCP
- **Add Collaborator :** 
    - **Un Administrateur** `DOM Admin`
    - Sélectionner `Manager` 
    - Cliquer sur **Add Collaborator**

**Paramètres de la règle de routage :**
- **Field :** source
- **Type :** Contain
- **Value :** DOM-DHCP-01
- **Description :** Serveur DHCP

---

###### Stream 3 : Serveur GLPI
**Paramètres du Stream :**
- **Title :** DOM-GLPI-01
- **Description :** Serveur GLPI
- **Add Collaborator :** 
    - **Un Administrateur** `DOM Admin`
    - Sélectionner `Manager` 
    - Cliquer sur **Add Collaborator**

**Paramètres de la règle de routage :**
- **Field :** source
- **Type :** Contain
- **Value :** DOM-GLPI-01
- **Description :** Serveur GLPI

---

###### Stream 4 : Serveur Zabbix
**Paramètres du Stream :**
- **Title :** DOM-ZABBIX-01
- **Description :** Serveur Zabbix
- **Add Collaborator :** 
    - **Un Administrateur** `DOM Admin`
    - Sélectionner `Manager` 
    - Cliquer sur **Add Collaborator**

**Paramètres de la règle de routage :**
- **Field :** source
- **Type :** Contain
- **Value :** DOM-ZABBIX-01
- **Description :** Serveur Zabbix

---

###### Stream 5 : Serveur de Fichiers
**Paramètres du Stream :**
- **Title :** DOM-FS-01
- **Description :** Serveur de fichiers
- **Add Collaborator :** 
    - **Un Administrateur** `DOM Admin`
    - Sélectionner `Manager` 
    - Cliquer sur **Add Collaborator**

**Paramètres de la règle de routage :**
- **Field :** source
- **Type :** Contain
- **Value :** DOM-FS-01
- **Description :** Serveur de fichiers

---

###### Stream 6 : Serveur Web Interne
**Paramètres du Stream :**
- **Title :** DOM-WEBINT-01
- **Description :** Serveur Web Interne
- **Add Collaborator :** 
    - **Un Administrateur** `DOM Admin`
    - Sélectionner `Manager` 
    - Cliquer sur **Add Collaborator**

**Paramètres de la règle de routage :**
- **Field :** source
- **Type :** Contain
- **Value :** DOM-WEBINT-01
- **Description :** Serveur Web Interne

---

###### Stream 7 : Serveur Active Directory PDC
**Paramètres du Stream :**
- **Title :** DOM-AD-PDC-01
- **Description :** Serveur Active Directory PDC
- **Add Collaborator :** 
    - **Un Administrateur** `DOM Admin`
    - Sélectionner `Manager` 
    - Cliquer sur **Add Collaborator**

**Paramètres de la règle de routage :**
- **Field :** source
- **Type :** Contain
- **Value :** DOM-AD-PDC-01
- **Description :** Serveur Active Directory PDC

---

###### Stream 8 : Serveur Active Directory RID
**Paramètres du Stream :**
- **Title :** DOM-AD-RID-01
- **Description :** Serveur Active Directory RID
- **Add Collaborator :** 
    - **Un Administrateur** `DOM Admin`
    - Sélectionner `Manager` 
    - Cliquer sur **Add Collaborator**

**Paramètres de la règle de routage :**
- **Field :** source
- **Type :** Contain
- **Value :** DOM-AD-RID-01
- **Description :** Serveur Active Directory RID

---

###### Stream 8 : Serveur Web Externe
**Paramètres du Stream :**
- **Title :** DOM-WEBEXT-01
- **Description :** Serveur Web Externe
- **Add Collaborator :** 
    - **Un Administrateur** `DOM Admin`
    - Sélectionner `Manager` 
    - Cliquer sur **Add Collaborator**

**Paramètres de la règle de routage :**
- **Field :** source
- **Type :** Contain
- **Value :** DOM-WEBEXT-01
- **Description :** Serveur Web Externe

---

###### Stream 9 : Serveur WSUS
**Paramètres du Stream :**
- **Title :** DOM-WSUS-01
- **Description :** Serveur WSUS
- **Add Collaborator :** 
    - **Un Administrateur** `DOM Admin`
    - Sélectionner `Manager` 
    - Cliquer sur **Add Collaborator**

**Paramètres de la règle de routage :**
- **Field :** source
- **Type :** Contain
- **Value :** DOM-WSUS-01
- **Description :** Serveur WSUS

---

###### Stream 10 : Serveur WDS
**Paramètres du Stream :**
- **Title :** DOM-WDS-01
- **Description :** Serveur WDS
- **Add Collaborator :** 
    - **Un Administrateur** `DOM Admin`
    - Sélectionner `Manager` 
    - Cliquer sur **Add Collaborator**

**Paramètres de la règle de routage :**
- **Field :** source
- **Type :** Contain
- **Value :** DOM-WDS-01
- **Description :** Serveur WDS

---
**Note :** Après la création de chaque stream, ne pas oublier de cliquer sur le bouton Lecture pour l'activer.
