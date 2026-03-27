# Sommaire - Guide de Configuration pfSense

[1. Première configuration](#1-première-configuration)
   - [1.1 Connexion à l'interface web](#11-connexion-à-linterface-web)
   - [1.2 Assistant de configuration initiale](#12-assistant-de-configuration-initiale)
   - [1.3 Configuration générale du système](#13-configuration-générale-du-système)
   - [1.4 Configuration du fuseau horaire](#14-configuration-du-fuseau-horaire)
   - [1.5 Configuration de l'interface WAN](#15-configuration-de-linterface-wan)
   - [1.6 Configuration de l'interface LAN](#16-configuration-de-linterface-lan)
   - [1.7 Changement du mot de passe administrateur](#17-changement-du-mot-de-passe-administrateur)
   - [1.8 Application de la configuration](#18-application-de-la-configuration)

[2. Ajout et configuration de l'interface réseau DMZ](#2-ajout-et-configuration-de-linterface-réseau-dmz)
   - [2.1 Accès aux paramètres d'interfaces](#21-accès-aux-paramètres-dinterfaces)
   - [2.2 Ajout de l'interface DMZ](#22-ajout-de-linterface-dmz)
   - [2.3 Confirmation de l'ajout](#23-confirmation-de-lajout)
   - [2.4 Accès à la configuration OPT1](#24-accès-à-la-configuration-opt1)
   - [2.5 Configuration de l'interface DMZ](#25-configuration-de-linterface-dmz)
   - [2.6 Application des changements](#26-application-des-changements)
   - [2.7 Confirmation des modifications](#27-confirmation-des-modifications)

[3. Configuration des Aliases réseaux](#3-configuration-des-aliases-réseaux)
   - [3.1 Menu Aliases](#31-menu-aliases)
   - [3.2 Ajouter un alias IP](#32-ajouter-un-alias-ip)
   - [3.3 Réseaux privé VLANs Internal_Network](#33-réseaux-privé-vlans-internal_network)
   - [3.4 Private Network](#34-private-network)
   - [3.5 Serveur mail dans la DMZ](#35-serveur-mail-dans-la-dmz)
   - [3.6 Serveur Web dans la DMZ](#36-serveur-web-dans-la-dmz)
   - [3.7 Réseau DMZ](#37-réseau-dmz)
   - [3.8 Application des changements](#38-application-des-changements)

[4. Configuration des Aliases de ports](#4-configuration-des-aliases-de-ports)
   - [4.1 Accès au menu Aliases Ports](#41-accès-au-menu-aliases-ports)
   - [4.2 Création des aliases de ports](#42-création-des-aliases-de-ports)
   - [4.3 Application des changements](#43-application-des-changements)

[5. Configuration des règles NAT pour l'interface WAN](#5-configuration-des-règles-nat-pour-linterface-wan)
   - [5.1 Accès à la configuration NAT](#51-accès-à-la-configuration-nat)
   - [5.2 Création des règles de redirection de port](#52-création-des-règles-de-redirection-de-port)
   - [5.3 Configurer les règles NAT](#53-configurer-les-règles-nat)
   - [5.4 Application des changements](#54-application-des-changements)
   - [5.5 Affichage des règles créées](#55-affichage-des-règles-créées)

[6. Configuration des règles de pare-feu LAN](#6-configuration-des-règles-de-pare-feu-lan)
   - [6.1 Accès aux règles LAN](#61-accès-aux-règles-lan)
   - [6.2 Suppression de la règle par défaut](#62-suppression-de-la-règle-par-défaut)
   - [6.3 Création des règles LAN](#63-création-des-règles-lan)
   - [6.4 Application des changements](#64-application-des-changements)
   - [6.5 Vérification de l'ordre des règles](#65-vérification-de-lordre-des-règles)

[7. Configuration des règles de pare-feu DMZ](#7-configuration-des-règles-de-pare-feu-dmz)
   - [7.1 Accès aux règles DMZ](#71-accès-aux-règles-dmz)
   - [7.2 Création des règles DMZ](#72-création-des-règles-dmz)
   - [7.3 Application des changements](#73-application-des-changements)
   - [7.4 Vérification de l'ordre des règles](#74-vérification-de-lordre-des-règles)

[8. Configuration du routage statique](#8-configuration-du-routage-statique)
   - [8.1 Création de la Gateway vers le Routeur Core](#81-création-de-la-gateway-vers-le-routeur-core)
   - [8.2 Configuration de la Gateway](#82-configuration-de-la-gateway)
   - [8.3 Application des changements](#83-application-des-changements)
   - [8.4 Accès aux routes statiques](#84-accès-aux-routes-statiques)
   - [8.5 Configuration de la route vers les VLANs internes](#85-configuration-de-la-route-vers-les-vlans-internes)
   - [8.6 Application des changements](#86-application-des-changements)
   - [8.7 Vérification de la route](#87-vérification-de-la-route)

---  

## 1. Première configuration

Cette section vous guide à travers la configuration initiale de pfSense via l'interface web.

### 1.1 Connexion à l'interface web

- Ouvrir un navigateur et accéder à `https://10.10.10.1`
- Entrer les identifiants par défaut :
    - **Nom d'utilisateur** : `admin`
    - **Mot de passe** : `pfsense`

![img](Ressources/03_configuration_interface_web/01_configuration_web.png)

### 1.2 Assistant de configuration initiale

- Cliquer sur **Next** pour démarrer l'assistant

![img](Ressources/03_configuration_interface_web/02_configuration_web.png)

- Cliquer sur **Next** pour continuer

![img](Ressources/03_configuration_interface_web/03_configuration_web.png)

### 1.3 Configuration générale du système

1. Saisir le **Hostname** : `Firewall`
2. Saisir le **Domain** : `billu.pfsense`
3. Entrer le **Primary DNS Server** : `8.8.8.8`
4. Entrer le **Secondary DNS Server** : `8.8.4.4`
5. Cliquer sur **Next**

![img](Ressources/03_configuration_interface_web/04_configuration_web.png)

### 1.4 Configuration du fuseau horaire

1. Sélectionner la **Timezone** : `Europe/Paris`
2. Cliquer sur **Next**

![img](Ressources/03_configuration_interface_web/05_configuration_web.png)

### 1.5 Configuration de l'interface WAN

1. Changer la configuration **IPv4 Configuration Type** en **Static IPv4**
2. Ajouter l'adresse IP **10.0.0.2/29**
3. Choisir **WANGW - 10.0.0.1** dans **IPv4 Upstream gateway** (si disponible)
4. Décocher `Block Private networks from entering via WAN`
5. Cliquer sur **Save**

![img](Ressources/03_configuration_interface_web/06_configuration_web.png)
![img](Ressources/03_configuration_interface_web/06_01_configuration_web.png)

### 1.6 Configuration de l'interface LAN

1. **Adresse IP** : `10.10.10.1`
2. **Masque sous-réseau** : `30`
3. Cliquer sur **Next**

![img](Ressources/03_configuration_interface_web/08_configuration_web.png)

### 1.7 Changement du mot de passe administrateur

- Entrer un nouveau mot de passe : `Azerty1*`


![img](Ressources/03_configuration_interface_web/09_configuration_web.png)

### 1.8 Application de la configuration

- Cliquer sur `Reload` pour appliquer les modifications

![img](Ressources/03_configuration_interface_web/10_configuration_web.png)

- Attendre la fin du rechargement, puis cliquer sur `Finish`

![img](Ressources/03_configuration_interface_web/12_configuration_web.png)

---  

## 2. Ajout et configuration de l'interface réseau DMZ
### 2.1 Accès aux paramètres d'interfaces
- Cliquer sur `Interfaces` et sur `Assignments`

![img](Ressources/04_configuration_interface_dmz/01_configuration_interface_dmz.png)

### 2.2 Ajout de l'interface DMZ
- Cliquer sur `Add` dans `Available network ports`

![img](Ressources/04_configuration_interface_dmz/02_configuration_interface_dmz.png)

### 2.3 Confirmation de l'ajout
- Un message confirmant l'ajout de l'interface apparait

![img](Ressources/04_configuration_interface_dmz/03_configuration_interface_dmz.png)

### 2.4 Accès à la configuration OPT1
- Cliquer sur `Interfaces` et sélectionner `OPT1`

![img](Ressources/04_configuration_interface_dmz/04_configuration_interface_dmz.png)

### 2.5 Configuration de l'interface DMZ
- Dans General Configuration :
1) Cocher `Enable interface` pour activer l'interface
2) Entrer `DMZ` dans description
3) Sélectionner `Static IPv4` dans `IPv4 Configuration Type`
4) Entrer l'adresse IP `10.10.11.1`
5) Sélectionner le CIDR `29`
6) Cliquer sur `Save`

![img](Ressources/04_configuration_interface_dmz/05_configuration_interface_dmz.png)
![img](Ressources/04_configuration_interface_dmz/06_configuration_interface_dmz.png)

### 2.6 Application des changements
- Cliquer sur `Apply Changes` 

![img](Ressources/04_configuration_interface_dmz/07_configuration_interface_dmz.png)

### 2.7 Confirmation des modifications

- Confirmation des modifications

![img](Ressources/04_configuration_interface_dmz/08_configuration_interface_dmz.png)

---  

## 3. Configuration des Aliases réseaux

### 3.1 Menu Aliases
- Cliquer sur l'onglet `Firewall` et choisir `Aliases`

![img](Ressources/05_configuration_aliases_network/01_alias_configuration.png)

### 3.2 Ajouter un alias IP
1) Choisir `IP`
2) Cliquer sur `Add`

![img](Ressources/05_configuration_aliases_network/02_alias_configuration.png)

### 3.3 Réseaux privé VLANs **Internal_Network**

![img](Ressources/05_configuration_aliases_network/03_alias_configuration.png)

1) Entrer un nom : `Internal_Networks`
2) Entrer une description : `LAN et VLANS de l'entreprise`
3) Choisir le type : `Networks`
4) Ajouter chaque réseau en cliquant sur `Add Network` et en saisissant les informations ci-dessous :

| Address | CIDR | Description |
|--------|------|-------------|
| 10.10.10.0 | /30 | LAN Liaison |
| 172.16.0.0 | /24 | LAN Interne |
| 172.16.1.0 | /24 | VLAN 10 - DEV |
| 172.16.2.0 | /26 | VLAN 20 - COMMERCIAL |
| 172.16.3.0 | /26 | VLAN 30 - COMMUNICATION |
| 172.16.5.0 | /27 | VLAN 50 - JURIDIQUE |
| 172.16.6.0 | /27 | VLAN 60 - DSI |
| 172.16.7.0 | /27 | VLAN 70 - COMPTABILITE |
| 172.16.8.0 | /28 | VLAN 80 - DIRECTION |
| 172.16.9.0 | /28 | VLAN 90 - IMPRESSION |
| 172.16.10.0 | /28 | VLAN 100 - QHSE |
| 172.16.11.0 | /28 | VLAN 110 - RH |
| 172.16.12.0 | /29 | VLAN 120 - AD/DNS/DHCP |
| 172.16.13.0 | /28 | VLAN 130 - Fichier/Message/GLPI |
| 172.16.14.0 | /26 | VLAN 140 - INVITE |
| 172.16.15.0 | /29 | VLAN 150 - ADMIN |

5) Cliquer sur `Save` pour enregistrer dès que la saisie des réseaux est terminée. 

### 3.4 Private Network

1) Entrer un nom : `RFC1918`
2) Entrer une description : `Private Network`
3) Choisir le type : `Networks`
4) Ajouter l'adresse IP `192.168.0.0/16` 
4) Ajouter l'adresse IP `172.16.0.0/12` 
4) Ajouter l'adresse IP `10.0.0.0/8` 
5) Ajouter la description `Serveur Mail DMZ`
6) Cliquer sur `Save`

### 3.5 Serveur Web dans la DMZ

1) Entrer un nom : `DMZ_WebServer`
2) Entrer une description : `Serveur Web DMZ`
3) Choisir le type : `Hosts`
4) Ajouter l'adresse IP `10.10.11.2` 
5) Ajouter la description `Serveur Web DMZ`
6) Cliquer sur `Save`

### 3.6 Réseau DMZ

1) Entrer un nom : `DMZ_Network`
2) Entrer une description : `DMZ Network`
3) Choisir le type : `Networks`
4) Ajouter l'adresse réseau `10.10.11.0` 
5) Choisir le CIDR `/29`
6) Ajouter la description `Réseau DMZ`
7) Cliquer sur `Save`

### 3.7 Application des changements

- Cliquer sur `Apply Changes` pour valider tous les aliases créés

---

## 4. Configuration des Aliases de ports

### 4.1 Accès à la configuration des alias

1) Cliquer sur l'onglet `Firewall` et choisir `Aliases`
2) Sélectionner l'onglet `Ports`
3) Cliquer sur `Add`

![img](Ressources/06_configuration_aliases_ports/01_alias_ports.png)


### 4.2 Création des alias

1) Entrer un nom : `Web_Ports`
2) Entrer une description : `Ports 80 et 443`
3) Choisir le type : `Ports`
4) Ajouter chaque alias en cliquant sur `Add Port`et en saisissant les informations ci-dessous.
5) Cliquer sur `Save`
6) Répéter l'opération pour chaque alias

**Liste des alias à créer :**

| Nom de l'alias | Port | Description du port |
|----------------|------|---------------------|
| **Web_Ports** | 80 | HTTP |
| | 443 | HTTPS |
| **DNS_Ports** | 53 | DNS |
| **Mail_SMTP** | 25 | SMTP |
| | 465 | SMTPS |
| | 587 | Submission |
| **Mail_POP_IMAP** | 110 | POP3 |
| | 143 | IMAP |
| | 993 | IMAPS |
| | 995 | POP3S |

### 4.3 Application des changements

- Cliquer sur `Apply Changes` pour valider tous les aliases de ports créés

---  

## 5. Configuration des règles NAT pour l'interface WAN

### 5.1 Accès à la configuration NAT

- Cliquer sur l'onglet `Firewall` et choisir `NAT` pour configurer le WAN

![img](Ressources/07_nat_configuration/01_firewall_configuration_NAT.png)

### 5.2 Création des règles de redirection de port
1) Sélectionner `Port Forward`
2) Cliquer sur `Add` avec la flèche vers le bas

![img](Ressources/07_nat_configuration/02_firewall_configuration_NAT.png)

### 5.3 Configurer les règles NAT

![img](Ressources/07_nat_configuration/03_firewall_configuration_NAT.png)


- Pour chaque règle ci-dessous, cliquer sur `Add`, configurer les paramètres indiqués, puis cliquer sur `Save`.
- **Important** : Cocher `Add associated filter rule` pour créer automatiquement la règle de pare-feu sur l'interface WAN

**Règle 1 : Site web public**

| Paramètre | Valeur |
|-----------|--------|
| Interface | `WAN` |
| Address Family | `IPv4` |
| Protocol | `TCP` |
| Destination | `WAN address` |
| Destination port range | `Other > Web_Ports (80, 443)` |
| Redirect target IP | `10.10.11.2` |
| Redirect target port | `Other > Web_Ports` |
| Description | `Site web public` |
| Filter rule association | `Add associated filter rule` |

**Règle 2 : SMTP entrant**

| Paramètre | Valeur |
|-----------|--------|
| Interface | `WAN` |
| Address Family | `IPv4` |
| Protocol | `TCP` |
| Destination | `WAN address` |
| Destination port range | `Other > Mail_SMTP (25, 465, 587)` |
| Redirect target IP | `10.10.11.3` |
| Redirect target port | `Other > Mail_SMTP` |
| Description | `SMTP entrant` |
| Filter rule association | `Add associated filter rule` |

**Règle 3 : Accès messagerie**

| Paramètre | Valeur |
|-----------|--------|
| Interface | `WAN` |
| Address Family | `IPv4` |
| Protocol | `TCP` |
| Destination | `WAN address` |
| Destination port range | `Other > Mail_POP_IMAP (110, 143, 993, 995)` |
| Redirect target IP | `10.10.11.3` |
| Redirect target port | `Other > Mail_POP_IMAP` |
| Description | `Accès messagerie` |
| Filter rule association | `Add associated filter rule` |

### 5.4 Application des changements

- Cliquer sur `Save` puis `Apply Changes`

### 5.5 Affichage des règles créées

![img](Ressources/07_nat_configuration/04_firewall_configuration_NAT.png)


---  

## 6. Configuration des règles de pare-feu LAN

### 6.1 Accès aux règles LAN

- Cliquer sur l'onglet `Firewall` et choisir `Rules`
- Sélectionner l'onglet `LAN`

![img](Ressources/08_firewall_lan/01_firewall_lan.png)

### 6.2 Suppression des règles par défaut

- Supprimer les règles par défaut "Default allow LAN to any rule" si elles existent
- Cliquer sur l'icône poubelle puis confirmer la suppression

![img](Ressources/08_firewall_lan/02_firewall_lan.png)

### 6.3 Création des règles LAN

**Principe important : L'ordre des règles**

Les règles de pare-feu sont évaluées de haut en bas. Dès qu'un paquet correspond à une règle, celle-ci s'applique et l'évaluation s'arrête. Il est donc crucial de placer :
1. Les règles de **blocage** (Block) en premier
2. Les règles d'**autorisation** (Pass) ensuite
3. Une règle de blocage finale si nécessaire

Cette approche "deny first, allow after" garantit que les restrictions de sécurité sont appliquées avant toute autorisation.

Pour chaque règle ci-dessous :
1) Cliquer sur `Add` avec la flèche vers le bas
2) Configurer les paramètres indiqués
3) Cliquer sur `Save`

![img](Ressources/08_firewall_lan/03_firewall_lan.png)

 **Règle 1 : Bloque l'accès LAN vers DMZ**

|Paramètre|Valeur|
|---------|------|
|Action|`Block`|
|Interface|`LAN`|
|Address Family|`IPv4`|
|Protocol|`Any`|
|Source|`Internal_Networks`|
|Destination|`DMZ_Network` (10.10.11.0/29)|
|Log|`☑ Log packets that are handled by this rule`|
|Description|`Bloquer accès LAN vers DMZ`|

 **Règle 2 : Bloque l'accès vers réseaux privés WAN**

|Paramètre|Valeur|
|---|---|
|Action|`Block`|
|Interface|`LAN`|
|Address Family|`IPv4`|
|Protocol|`Any`|
|Source|`Internal_Networks`|
|Destination|`RFC1918`|
|Log|`☑ Log packets that are handled by this rule`|
|Description|`Bloquer accès vers réseaux privés sur WAN`|

 **Règle 3 : Autorise le DNS vers pfSense**

|Paramètre|Valeur|
|---|---|
|Action|`Pass`|
|Interface|`LAN`|
|Address Family|`IPv4`|
|Protocol|`TCP/UDP`|
|Source|`Internal_Networks`|
|Destination|`LAN address` (10.10.10.1)|
|Destination port range|`DNS (53)`|
|Description|`Autoriser DNS vers pfSense`|

 **Règle 4 : Autoriser accès Internet depuis réseaux internes**

|Paramètre|Valeur|
|---|---|
|Action|`Pass`|
|Interface|`LAN`|
|Address Family|`IPv4`|
|Protocol|`Any`|
|Source|`Internal_Networks`|
|Destination|`any`|
|Description|`Autoriser accès Internet depuis réseaux internes`|

### 6.4 Application des changements

- Cliquer sur `Apply Changes` après avoir créé toutes les règles

### 6.5 Vérification de l'ordre des règles

Vérifier que les règles apparaissent dans cet ordre (du haut vers le bas) :
1. Bloque l'accès LAN vers DMZ
2. Bloque l'accès vers réseaux privés WAN
3. Autorise le DNS vers pfSense
4. Autoriser accès Internet depuis réseaux internes


---  

## 7. Configuration des règles de pare-feu DMZ

### 7.1 Accès aux règles DMZ

- Cliquer sur l'onglet `Firewall` et choisir `Rules`
- Sélectionner l'onglet `DMZ`

### 7.2 Création des règles DMZ

**Principe de sécurité pour la DMZ**

La DMZ héberge des serveurs accessibles depuis Internet et nécessite une sécurité renforcée :
- **Deny first** : Empêcher tout accès de la DMZ vers les réseaux internes (règles 1-3)
- **Allow after** : Uniquement les services publics attendus (règles 4-9)
- **Default deny** : Tout ce qui n'est pas explicitement autorisé est bloqué (règle 10)

L'ordre des règles suit le principe "deny first, allow after" avec une règle de blocage finale pour garantir une sécurité maximale.

Pour chaque règle ci-dessous :
1) Cliquer sur `Add` avec la flèche vers le bas
2) Configurer les paramètres indiqués
3) Cliquer sur `Save`

**Règle 1 : Bloquer la DMZ vers les Réseaux internes**

|Paramètre|Valeur|
|---|---|
|Action|`Block`|
|Interface|`DMZ`|
|Address Family|`IPv4`|
|Protocol|`Any`|
|Source|`DMZ net` ou `DMZ_Network`|
|Destination|`Internal_Networks` |
|Log|`☑ Log packets that are handled by this rule`|
|Description|`Bloquer la DMZ vers les Réseaux internes`|

**Règle 2 : Bloquer la DMZ vers l'interface LAN pfSense**

|Paramètre|Valeur|
|---|---|
|Action|`Block`|
|Interface|`DMZ`|
|Address Family|`IPv4`|
|Protocol|`Any`|
|Source|`DMZ_Network` (10.10.11.0/29) |
|Destination|`LAN address` (10.10.10.1)|
|Log|`☑ Log packets that are handled by this rule`|
|Description|`Bloquer la DMZ vers l'interface LAN pfSense`|

**Règle 3 : Bloquer DMZ vers pfSense (WebGUI)**

|Paramètre|Valeur|
|---|---|
|Action|`Block`|
|Interface|`DMZ`|
|Address Family|`IPv4`|
|Protocol|`TCP`|
|Source|`DMZ_Network`|
|Destination|`DMZ address` (10.10.11.1)|
|Destination port range|`Web_Ports` (HTTP et HTTPS)|
|Log|`☑ Log packets that are handled by this rule`|
|Description|`Bloquer l'accès WebGUI pfSense depuis DMZ`|

**Règle 4 : Autoriser HTTP/HTTPS vers serveur Web**

|Paramètre|Valeur|
|---|---|
|Action|`Pass`|
|Interface|`DMZ`|
|Address Family|`IPv4`|
|Protocol|`TCP`|
|Source|`any`|
|Destination|`DMZ_WebServer` (10.10.11.2)|
|Destination port range|`WEB_PORTS` (80, 443)|
|Description|`Autoriser le trafic web public vers serveur Web`|

**Règle 5 : Autoriser DNS sortant depuis DMZ**

|Paramètre|Valeur|
|---|---|
|Action|`Pass`|
|Interface|`DMZ`|
|Address Family|`IPv4`|
|Protocol|`TCP/UDP`|
|Source|`DMZ_Network`|
|Destination|`any`|
|Destination port range|`DNS_Ports` (53)|
|Description|`Autoriser le DNS sortant depuis DMZ`|

**Règle 6 : Autoriser HTTP/HTTPS sortant depuis DMZ**

|Paramètre|Valeur|
|---|---|
|Action|`Pass`|
|Interface|`DMZ`|
|Address Family|`IPv4`|
|Protocol|`TCP`|
|Source|`DMZ_Network`|
|Destination|`any`|
|Destination port range|`Web_Ports` (80, 443)|
|Description|`Autoriser HTTP/HTTPS sortant pour mises à jour DMZ`|

**Règle 7 : Bloquer tout le reste**

|Paramètre|Valeur|
|---|---|
|Action|`Block`|
|Interface|`DMZ`|
|Address Family|`IPv4`|
|Protocol|`Any`|
|Source|`DMZ_Network`|
|Destination|`any`|
|Log|`☑ Log packets that are handled by this rule`|
|Description|`Bloquer tout le reste depuis DMZ`|

### 7.3 Application des changements

- Cliquer sur `Apply Changes` après avoir créé toutes les règles

### 7.4 Vérification de l'ordre des règles

Vérifier que les règles apparaissent dans cet ordre (du haut vers le bas) :
1. Bloque la DMZ vers les Réseaux internes
2. Bloque la DMZ vers l'interface LAN pfSense
3. Bloquer DMZ vers pfSense (WebGUI)
4. Autoriser HTTP/HTTPS vers serveur Web
5. Autoriser DNS sortant depuis DMZ
6. Autoriser HTTP/HTTPS sortant depuis DMZ
7. Autoriser SMTP sortant depuis serveur Mail
8. Bloquer tout le reste

---

## 8. Configuration du routage statique

### 8.1 Création de la Gateway vers le Routeur Core

- Cliquer sur `System` puis `Routing`
- Sélectionner l'onglet `Gateways`
- Cliquer sur `Add`

![img](Ressources/09_route_static/01_static_route.png)

### 8.2 Configuration de la Gateway

1) Entrer les paramètres suivants :
   - **Interface** : `LAN`
   - **Address Family** : `IPv4`
   - **Name** : `ROUTERCORE`
   - **Gateway** : `10.10.10.2`
   - **Description** : `Gateway vers Routeur Core`
2) Cliquer sur `Save`

![img](Ressources/09_route_static/02_static_route.png)

### 8.3 Application des changements

- Cliquer sur `Apply Changes`

![img](Ressources/09_route_static/03_static_route.png)

### 8.4 Accès aux routes statiques

- Cliquer sur `System` puis `Routing`
- Sélectionner l'onglet `Static Routes`
- Cliquer sur `Add`

![img](Ressources/09_route_static/04_static_route.png)

### 8.5 Configuration de la route vers les VLANs internes

1) Entrer les paramètres suivants :
   - **Destination network** : `172.16.0.0/16`
   - **Gateway** : `ROUTERCORE - 10.10.10.2`
   - **Description** : `Route vers tous les VLANs internes via Routeur Core`
2) Cliquer sur `Save`

![img](Ressources/09_route_static/05_static_route.png)

### 8.6 Application des changements

- Cliquer sur `Apply Changes`

![img](Ressources/09_route_static/06_static_route.png)

### 8.7 Vérification de la route

- Cliquer sur `Diagnostics` puis `Routes`

![img](Ressources/09_route_static/07_static_route.png)

- Vérifier la présence de la route `172.16.0.0/16` avec comme gateway `10.10.10.2`

![img](Ressources/09_route_static/08_static_route.png)









