## Sommaire

1. [Vue d'ensemble](#1-vue-densemble)
2. [Objectifs](#2-objectifs)
3. [Architecture](#3-architecture)
4. [Structure de la documentation](#4-structure-de-la-documentation)
5. [Outils installés](#5-outils-installés)
6. [Fonctionnalités](#6-fonctionnalités)
7. [Maintenance](#7-maintenance)
8. [Références](#8-références)
9. [Contributeurs](#10-contributeurs)

---

## 1. Vue d'ensemble

Le **G1-PC-ADMIN-01** est le poste de travail d'administration centralisé de l'infrastructure BillU. Positionné dans le VLAN 60 (DSI), ce poste permet aux administrateurs système et réseau d'accéder à l'ensemble des équipements et services de l'infrastructure de manière sécurisée.

### Caractéristiques principales

- **Système d'exploitation** : `Windows 10 Pro 22H2`
- **Positionnement** : `VLAN 60 - DSI`
- **Adresse IP** : `172.16.6.1/24`
- **Domaine** : `billu.lan`
- **Fonction** : Administration centralisée de l'infrastructure

---
## 2. Objectifs

Le PC d'administration répond aux objectifs suivants :

### Objectifs principaux

- **Centralisation** : Point d'accès unique pour l'administration de tous les équipements
- **Sécurité** : Isolation dans un VLAN dédié aux administrateurs
- **Polyvalence** : Support de multiples protocoles d'administration (RDP, SSH, HTTPS, SFTP)
- **Efficacité** : Outils d'analyse et de diagnostic intégrés

### Périmètre d'administration

- **Serveurs Windows** : Active Directory, DNS, DHCP via outils RSAT
- **Équipements réseau** : VyOS, pfSense via SSH/HTTPS
- **Serveurs Linux** : Zabbix, GLPI, Graylog
- **Infrastructure** : Supervision, analyse réseau, gestion de configuration

---
## 3. Architecture

### Spécifications matérielles
| Composant            | Spécification               |
| -------------------- | --------------------------- |
| **Type**             | Machine virtuelle (Proxmox) |
| **CPU**              | 2 vCPU                      |
| **RAM**              | 4 Go                        |
| **Disque**           | 40 Go                       |
| **Interface réseau** | 1 vmbr412                   |

### Configuration réseau
| Paramètre | Valeur |
|-----------|--------|
| **Nom de machine** | G1-PC-ADMIN-01 |
| **VLAN** | 60 - DSI |
| **Adresse IP** | 172.16.6.1/24 |
| **Masque** | 255.255.255.0 |
| **Passerelle** | 172.16.6.30 (VyOS) |
| **DNS primaire** | 172.16.12.1 (G1-SRV-AD-01) |
| **Domaine** | billu.lan |

---
## 4. Structure de la documentation

- **README.md** - Ce fichier
- **[installation.md](components/PC_Administration/installation.md)**- Procédure d'installation complète
- **[configuration.md](components/PC_Administration/configuration.md)** - Configuration des logiciels installées
- **ressources/**

---
## 5. Outils installés

### 5.1. Outils d'administration Windows (RSAT)

Les **Remote Server Administration Tools** permettent l'administration à distance des serveurs Windows.

| Outil | Fonction | Utilisation |
|-------|----------|-------------|
| **Active Directory Users and Computers** | Gestion des utilisateurs et ordinateurs AD | Création/modification comptes, gestion OU |
| **Active Directory Sites and Services** | Gestion de la topologie AD | Configuration réplication, sites |
| **DNS Manager** | Gestion du serveur DNS | Zones, enregistrements DNS |
| **DHCP Console** | Gestion du serveur DHCP | Étendues, réservations, options |
| **Group Policy Management** | Gestion des GPO | Création et édition de stratégies de groupe |
| **Server Manager** | Vue d'ensemble des serveurs | Monitoring, gestion des rôles |

### 5.2. Outils de connexion à distance

| Outil | Protocole | Usage principal |
|-------|-----------|-----------------|
| **MobaXterm** | SSH, RDP, VNC, X11 | Client tout-en-un pour administration Linux/réseau |
| **Git Bash** | SSH | Terminal Unix pour Windows, scripts Git |
| **Putty** | SSH, Telnet | Client SSH léger |
| **TightVNC** | VNC | Accès graphique à distance |
| **OpenSSH Client** | SSH | Client SSH natif Windows |
| **OpenSSH Server** | SSH | Serveur SSH pour accès distant au PC Admin |

### 5.3. Outils de transfert de fichiers

| Outil | Protocole | Usage |
|-------|-----------|-------|
| **WinSCP** | SCP, SFTP, FTP | Transfert de fichiers interface graphique |
| **FileZilla** | FTP, SFTP | Client FTP avancé |

### 5.4. Outils d'analyse et diagnostic réseau

| Outil | Fonction | Cas d'usage |
|-------|----------|-------------|
| **Wireshark** | Analyse de paquets | Capture et analyse détaillée du trafic réseau |
| **Trippy** | Traceroute avancé | Diagnostic de chemin réseau en temps réel |
| **TCPView** (Sysinternals) | Monitoring connexions TCP/UDP | Visualisation connexions actives |

### 5.5. Outils système avancés

**Sysinternals Suite** : Collection d'outils système Windows

| Outil | Fonction |
|-------|----------|
| **Process Explorer** | Gestionnaire de processus avancé |
| **Autoruns** | Gestion des programmes au démarrage |
| **Process Monitor** | Monitoring activité système en temps réel |
| **TCPView** | Vue des connexions réseau actives |
| **PsExec** | Exécution de processus à distance |
| **PsTools** | Suite d'outils d'administration système |

### 5.6. Environnement de développement

| Outil | Description |
|-------|-------------|
| **WSL (Windows Subsystem for Linux)** | Sous-système Linux complet |
| **PowerShell** | Shell et langage de script Windows |
| **Git** | Gestion de versions |

---

## 6. Fonctionnalités

### 6.1. Administration Active Directory

**Outils utilisés** : RSAT - Active Directory

**Fonctionnalités disponibles** :
- Gestion des utilisateurs et groupes
- Création et modification d'Unités d'Organisation (OU)
- Gestion des ordinateurs du domaine
- Réinitialisation de mots de passe
- Délégation de permissions
- Gestion des relations d'approbation

**Accès** :
- Console : `dsa.msc` (Active Directory Users and Computers)
- Serveur cible : G1-SRV-AD-01 (172.16.12.1)

### 6.2. Gestion DNS/DHCP

**DNS Manager**
- Gestion des zones directes et inverses
- Création/modification d'enregistrements (A, CNAME, PTR, MX, etc.)
- Configuration des redirecteurs
- Diagnostic DNS (nslookup, Resolve-DnsName)

**DHCP Console**
- Gestion des étendues DHCP
- Création de réservations
- Configuration des options DHCP (passerelle, DNS, etc.)
- Monitoring des baux actifs

**Accès** :
- DNS : `dnsmgmt.msc`
- DHCP : `dhcpmgmt.msc`
- Serveur DNS : G1-SRV-AD-01 (172.16.12.1)
- Serveur DHCP : G1-SRV-DHCP-01 (172.16.12.2)

### 6.3. Administration équipements réseau

**VyOS (Routeur)**
- **Protocole** : `SSH`
- **Adresse** : `172.16.0.254`
- **Outils** : `MobaXterm, Putty, Git Bash`
- **Fonctions** :
  - Configuration du routage inter-VLAN
  - Gestion des interfaces et VLAN
  - Configuration DHCP relay
  - ACLs et règles de filtrage

**PfSense (Firewall)**
- **Protocoles** : `HTTPS (WebGUI), SSH`
- **Adresse WAN** : `10.0.0.2`
- **Adresse LAN** : `10.10.10.1`
- **Outils** : Navigateur web, SSH
- **Fonctions** :
  - Configuration des règles de firewall
  - NAT et redirection de ports
  - VPN (si configuré)
  - Monitoring du trafic

### 6.4. Analyse et diagnostic réseau

**Wireshark**
-  Capture de trafic sur toutes les interfaces
-  Filtres d'affichage et de capture avancés
-  Analyse protocolaire détaillée
-  Export de captures pour analyse ultérieure

**Trippy**
- Traceroute visuel en temps réel
- Affichage de la latence par saut
- Détection de pertes de paquets
- Monitoring continu des chemins réseau

### 6.5. Accès SSH 

**OpenSSH Server activé** :

- Accès SSH distant au PC Admin
- Démarrage automatique du service
- Port : 22 (par défaut)
- Authentification par mot de passe
### 6.6. Gestion de stratégies de groupe (GPO)

**Group Policy Management Console**
- Création et édition de GPO
- Liaison aux OU
- Modeling et résultats de stratégie
- Sauvegarde et restauration de GPO

**Accès** : `gpmc.msc`

---
## 7. Maintenance



---
## 8. Références

### Documentation officielle

#### Microsoft
- [Documentation RSAT](https://learn.microsoft.com/fr-fr/windows-server/remote/remote-server-administration-tools)
- [OpenSSH pour Windows](https://learn.microsoft.com/fr-fr/windows-server/administration/openssh/openssh_install_firstuse)
- [PowerShell Documentation](https://learn.microsoft.com/fr-fr/powershell/)
- [Active Directory](https://learn.microsoft.com/fr-fr/windows-server/identity/ad-ds/get-started/virtual-dc/active-directory-domain-services-overview)

#### Outils tiers
- [Wireshark Documentation](https://www.wireshark.org/docs/)
- [MobaXterm](https://mobaxterm.mobatek.net/documentation.html)
- [Putty Documentation](https://documentation.help/PuTTY/)
- [WinSCP Documentation](https://winscp.net/eng/docs/start)
- [Sysinternals Suite](https://learn.microsoft.com/fr-fr/sysinternals/)
- [Trippy GitHub](https://github.com/fujiapple852/trippy)

---
## 9. Contributeurs

### Équipe projet G1

| Nom           | Rôle          | Contribution                               |
| ------------- | ------------- | ------------------------------------------ |
| **Franck **   | Technicien    | Installation, configuration, documentation |
| **Christian** | Membre équipe | Tests et validation                        |
| **Matthias**  | Membre équipe | Tests et validation                        |

---

- **Projet** : TSSR - Projet 3 - Build Your Infra
- **Entreprise fictive** : BillU
- **Équipe** : G1

---

**Dernière mise à jour** : 03 février 2025  
**Version du document** : 1.0.0