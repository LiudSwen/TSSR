## Sommaire

## Sommaire

1. [Première connexion à l'interface WEB](#1-première-connexion-à-linterface-web)
   - 1.1 [Connexion à l'interface WEB](#11-connexion-à-linterface-web)
   - 1.2 [Création d'un compte utilisateur](#12-création-dun-compte-utilisateur)
   - 1.3 [Connexion avec le compte Admin](#13-connexion-avec-le-compte-admin)
   - 1.4 [Sélection de la langue](#14-sélection-de-la-langue)
   - 1.5 [Configuration du pare-feu Sangoma](#15-configuration-du-pare-feu-sangoma)
   - 1.6 [Validation de la configuration](#16-validation-de-la-configuration)

2. [Activation du service](#2-activation-du-service)
   - 2.1 [Activation du serveur](#21-activation-du-serveur)
   - 2.2 [Réparation des erreurs](#22-réparation-des-erreurs)
   - 2.3 [Mise à jour et activation des modules](#23-mise-à-jour-et-activation-des-modules)
   - 2.4 [Activation terminée](#24-activation-terminée)

3. [Synchronisation des utilisateurs Active Directory](#3-synchronisation-des-utilisateurs-active-directory)
   - 3.1 [Menu User Manager](#31-menu-user-manager)
   - 3.2 [Configuration du serveur](#32-configuration-du-serveur)

4. [Ajout d'utilisateurs](#4-ajout-dutilisateurs)

---  

### 1. Première connexion à l'interface WEB

#### 1.1 Connexion à l'interface WEB 

- Entrer l'adresse ip du serveur dans un navigateur web 

```
http://172.16.13.7
```

#### 1.2 Création d'un compte utilisateur

1) Entrer un nom d'utilisateur : `domadmin`
2) Entrer un mot de passe et la confirmation du mot de passe : `Azerty1*`
3) Entrer un mail de notification : `domadmin@billu.lan`
4) Entrer un system identifier : `VoIP Server`
5) Cliquer sur `Setup System`

![img](Ressources/configuration_img/01_freepbx_configuration.png)

#### 1.3 Connexion avec le compte Admin

1) Cliquer sur `FreePBX Administration`

![img](Ressources/configuration_img/02_freepbx_configuration.png)

2) Entrer les identifiants du compte utilisateur créé précédemment

![img](Ressources/configuration_img/03_freepbx_configuration.png)

#### 1.4 Sélection de la langue
1) Sound Prompts Language : `English`
2) System Language : `English (United States)`

![img](Ressources/configuration_img/04_freepbx_configuration.png)


#### 1.5 Configuration du pare-feu Sangoma
1) Cliquer sur `Abort`

![img](Ressources/configuration_img/05_freepbx_configuration.png)


#### 1.6 Validation de la configuration

1) Cliquer sur `Dashboard`
2) Cliquer sur `Apply Config`

![img](Ressources/configuration_img/06_freepbx_configuration.png)

---  

### 2. Activation du service 

#### 2.1 Activation du serveur
1) Cliquer sur `Admin`
2) Sélectionner `System Admin`

![img](Ressources/configuration_img/07_freepbx_configuration.png)

1) Ce message affirme que la machine n'est pas activé
2) Cliquer sur `Activation`

![img](Ressources/configuration_img/08_freepbx_configuration.png)

- Cliquer sur `Activate`

![img](Ressources/configuration_img/09_freepbx_configuration.png)

- Cliquer sur `Activate`

![img](Ressources/configuration_img/10_freepbx_configuration.png)

1) Entrer l'adresse mail `domadmin@billu.lan`
2) Entrer le mot de passe `Azerty1*`

**Attendre que la fenêtre s'agrandisse**

![img](Ressources/configuration_img/11_freepbx_configuration.png)

1) Entrer un nom (`Dom`)
2) Entrer un numéro de téléphone (`0102030405`)
3) Entrer un second numéro de téléphone (`0102030405`)
4) Entrer le nom de l'entreprise (`billu`)
5) Pour `Which best describes you` sélectionner `I use your products and services with my Business(s) and do not want to resell it` 
6) Entrer une adresse (`1 rue`)
7) Entrer une ville (`Paris`)
8) Entrer un code postal (`75000`)
9) Sélectionner un pays (`France`)
10) Sélectionner une région (`Centre`)
11) Pour `Do you agree to receive product and marketing emails from Sangoma ?` sélectionner `No`
12) Cocher `I agree to the terms and conditions`
13) Cliquer sur `Continue`

![img](Ressources/configuration_img/12_freepbx_configuration.png)

- Cliquer sur Activate

![img](Ressources/configuration_img/13_freepbx_configuration.png)

- Cliquer sur `Skip` à toutes les fenêtres qui s'affichent

![img](Ressources/configuration_img/14_freepbx_configuration.png)

- Cliquer sur `Update Now` dès que la fenêtre des modules apparait

![img](Ressources/configuration_img/15_freepbx_configuration.png)

- Attendre que les modules de mettent à jour et cliquer sur `Apply Config`

![img](Ressources/configuration_img/16_freepbx_configuration.png)

#### 2.2 Réparation des erreurs
**L'interface Web ne sera plus accessible après la mise à jour des modules**

1) Retourner sur le serveur FreePBX
2) Entrer les commandes : 
```
    - fwconsole ma install userman
    - fwconsole ma enable userman
    - fwconsole ma install voicemail
    - fwconsole ma enable voicemail
    - fwconsole ma install sysadmin
    - fwconsole ma enable sysadmin
```
3) Entrer `Y` lors de la demande de redémarrage du serveur, sinon entrer reboot dans le terminal

![img](Ressources/configuration_img/17_freepbx_configuration.png)

**Pour toutes erreurs sur l'interface WEB regarde la partie en haut à gauche de l'écran, une commande sera affiché similaire à celles utilisés précédemment, retourner sur le serveur FreePBX et entrer la commande affiché sur l'interface WEB.**

![img](Ressources/configuration_img/18_freepbx_configuration.png)

#### 2.3 Mise à jour et activation des modules
1) Sélectionner l'onget `Admin`
2) Cliquer sur `Module Admin`

![img](Ressources/configuration_img/19_freepbx_configuration.png)

1) Cliquer sur l'onglet `Module Updates`
2) Cliquer sur les modules `Disabled` pour les déplier
3) Sélectionner `Upgrade to ...` si l'option est disponible
4) Cliquer sur Process tout en bas de la page

![img](Ressources/configuration_img/20_freepbx_configuration.png)
![img](Ressources/configuration_img/21_freepbx_configuration.png)

- Cliquer sur `Confirm`

![img](Ressources/configuration_img/22_freepbx_configuration.png)

- Cliquer sur `Apply Config` 

![img](Ressources/configuration_img/23_freepbx_configuration.png)

#### 2.3 Activation terminée

- Dans l'onglet `Admin` > `System Admin`, vérifier l'activation de la machine

![img](Ressources/configuration_img/24_freepbx_configuration.png)

- Attendre la fin des mises à jours

![img](Ressources/configuration_img/25_freepbx_configuration.png)

---  

### 3. Synchronisation des utilisateurs Active Directory 

#### 3.1 Menu User Manager
1) Cliquer sur l'onglet `Admin`
2) Sélectionner `User Management`

![img](Ressources/configuration_img/26_freepbx_configuration.png)

1) Sélectionner l'onglet `Directories`
2) Cliquer sur l'onglet `Add`

![img](Ressources/configuration_img/27_freepbx_configuration.png)

#### 3.2 Configuration du serveur

**Un compte de serveur doit être créé dans Active Directory pour que la synchronisation fonctionne**
1) Sélectionner `Microsoft Active Directoy`
2) Entrer un nom de répertoire (`AD BillU`)
3) Sélectionner le délai entre les synchronisations (`1 hour`)
4) Entrer l'adresse sur serveur Active Directory (`172.16.12.1`)
5) Entrer le port `389`
6) Entrer le nom du compte de service créé précédemment (`billu.lan`)
7) Entrer le mot de passe du compte de service (`Azerty1*`)
8) Entrer le domaine (`billu.lan`)
9) Entrer la base du domain (Distinguished Name) (`dc=billu,dc=lan`)
10) Cliquer sur `Submit`

![img](Ressources/configuration_img/28_freepbx_configuration.png)

1) Vérifier que le répertoire apparait
2) Cliquer sur la coche pour mettre le répertoire AD par défaut

![img](Ressources/configuration_img/29_freepbx_configuration.png)

- Cliquer sur `YES`

![img](Ressources/configuration_img/30_freepbx_configuration.png)

- Cliquer sur l'onglet `Users`, la liste des utilisateurs AD doit apparaitre

![img](Ressources/configuration_img/31_freepbx_configuration.png)

---  

### 4. Ajout d'utilisateurs

1) Sélectionner l'onglet `Applications`
2) Cliquer sur `Extensions`

![img](Ressources/configuration_img/32_freepbx_configuration.png)

1) Cliquer sur `+ Add Extension`
2) Sélectionner `+ Add New SIP [chan_pjsip] Extenstion`

![img](Ressources/configuration_img/33_freepbx_configuration.png)

1) Entrer un numéro de poste (`80100`)
2) Entrer le nom de l'utilisateur (`Marie Meyer`)
3) Entrer un mot de passe (`1234`)
4) Sélectionner le répertoire créé précédemment (`AD Billu`)
5) Sélectionner l'utilisateur AD (`marie.meyer`)
6) Cliquer sur `Submit`

![img](Ressources/configuration_img/34_freepbx_configuration.png)

- L'utilisateur doit apparaitre dans la liste 

![img](Ressources/configuration_img/35_freepbx_configuration.png)

