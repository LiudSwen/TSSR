# iRedMail — Serveur de messagerie BillU

## Sommaire

1. [Vue d'ensemble](#1-vue-densemble)
2. [Objectifs](#2-objectifs)
3. [Architecture](#3-architecture)
	- 3.1 [Serveur iRedMail](#31-serveur-iredmail)
	- 3.2 [Informations réseau](#32-informations-réseau)
	- 3.3 [Composants installés](#33-composants-installés)
4. [Structure de la documentation](#4-structure-de-la-documentation)
5. [Services installés](#5-services-installés)
6. [Fonctionnalités](#6-fonctionnalités)
	- 6.1 [Envoi et réception de mails](#61-envoi-et-réception-de-mails)
	- 6.2 [Authentification via Active Directory](#62-authentification-via-active-directory)
	- 6.3 [Interfaces web](#63-interfaces-web)
7. [Maintenance](#7-maintenance)
	- 7.1 [Sauvegardes](#71-sauvegardes)
	- 7.2 [Monitoring](#72-monitoring)
8. [Références](#8-références)
9. [Historique des modifications](#9-historique-des-modifications)
10. [Contributeurs](#10-contributeurs)

---

## 1. Vue d'ensemble

Ce document présente l'installation et la configuration complète d'iRedMail pour l'entreprise BillU. iRedMail est une solution open source de serveur de messagerie complète, permettant la gestion centralisée des emails avec intégration à l'Active Directory de l'infrastructure BillU.

iRedMail permet :
- La gestion centralisée des boîtes mail de tous les utilisateurs du domaine `billu.lan`
- L'authentification des utilisateurs via l'Active Directory (LDAP)
- L'envoi et la réception de mails via Postfix (SMTP) et Dovecot (IMAP)
- L'accès web aux boîtes mail via Roundcube
- L'administration des comptes via l'interface iRedAdmin
- La consultation du carnet d'adresses global de l'entreprise depuis l'AD

---

## 2. Objectifs

- **Centraliser la messagerie** : Fournir un serveur mail unique pour l'ensemble des utilisateurs BillU
- **Intégrer l'Active Directory** : Authentifier les utilisateurs via les comptes AD existants pour éviter la double gestion des identités
- **Sécuriser les communications** : Activer SSL/TLS sur tous les protocoles mail (IMAPS, SMTP, HTTPS)
- **Faciliter l'accès** : Proposer une interface web Roundcube accessible depuis le réseau interne
- **Administrer simplement** : Utiliser iRedAdmin pour la gestion des domaines et comptes mail

---

## 3. Architecture

#### 3.1 Serveur iRedMail

- **Hostname** : DOM-MAIL-01.billu.lan
- **OS** : Debian 12
- **Services** : Postfix, Dovecot, OpenLDAP, Nginx, Amavis, Roundcube, iRedAdmin
- **Fuseau horaire** : Europe/Paris

#### 3.2 Informations réseau

| Composant | Adresse IP | Description |
|-----------|------------|-------------|
| **Serveur iRedMail** | 172.16.13.5 | VLAN 130 - Fichier/Message/GLPI |
| **Serveur AD** | 172.16.12.1 | VLAN 120 - Contrôleur de domaine |
| **Roundcube (Web)** | https://172.16.13.5/mail/ | Interface webmail utilisateurs |
| **iRedAdmin (Web)** | https://172.16.13.5/iredadmin/ | Console d'administration |

**VLAN** : VLAN 130 (172.16.13.0/29)  
**Domaine mail** : billu.lan  
**Compte postmaster** : postmaster@billu.lan

**Ports utilisés :**
- **443** : HTTPS — Roundcube & iRedAdmin
- **587** : SMTP — Envoi authentifié (STARTTLS)
- **25** : SMTP — Réception MX
- **993** : IMAPS — Accès boîtes mail (SSL/TLS)
- **143** : IMAP — Accès boîtes mail (STARTTLS)
- **389** : LDAP — Requêtes vers l'Active Directory (interne)

#### 3.3 Composants installés

| Composant | Version | Rôle |
|-----------|---------|------|
| **iRedMail** | 1.7.4 | Suite d'installation du serveur mail |
| **Postfix** | Intégré Debian | Serveur SMTP — envoi et réception |
| **Dovecot** | Intégré Debian | Serveur IMAP — accès aux boîtes mail |
| **OpenLDAP (slapd)** | Intégré Debian | Annuaire LDAP local (bridge AD) |
| **Nginx** | Intégré Debian | Serveur web — Roundcube & iRedAdmin |
| **Amavis** | Intégré Debian | Antispam / antivirus |
| **Roundcube** | Intégré iRedMail | Interface webmail utilisateurs |
| **iRedAdmin** | Intégré iRedMail | Interface d'administration |

---

## 4. Structure de la documentation

- **README.md** - Ce fichier - Vue d'ensemble du projet
- **[installation.md](installation.md)** - Procédure d'installation complète d'iRedMail :
  - Préparation du système Debian (hostname, DNS, /etc/hosts)
  - Installation des outils nécessaires
  - Création du compte de service AD `svc-mail`
  - Installation d'iRedMail avec OpenLDAP
  - Vérification post-installation des services
- **[configuration.md](configuration.md)** - Guide détaillé de configuration :
  - Intégration Active Directory dans Postfix
  - Intégration Active Directory dans Dovecot
  - Intégration AD dans Roundcube (carnet d'adresses global)
  - Plan de tests et validation
  - Guide de dépannage
- **Ressources/**
  - iredmail_img/ - Captures d'écran de l'installation et configuration

---

## 5. Services installés

### Services système
- **Postfix** : Serveur SMTP pour l'envoi et la réception des emails
- **Dovecot** : Serveur IMAP/POP3 pour l'accès aux boîtes mail
- **OpenLDAP (slapd)** : Annuaire LDAP local installé par iRedMail, utilisé comme passerelle vers l'AD
- **Nginx** : Serveur web pour les interfaces Roundcube et iRedAdmin
- **Amavis** : Filtrage antispam et antivirus des emails entrants

### Interfaces web
- **Roundcube** : Webmail accessible aux utilisateurs du domaine
- **iRedAdmin** : Interface d'administration pour la gestion des domaines et comptes

### Compte de service Active Directory
- **Compte** : `svc-mail@billu.lan`
- **Rôle** : Lecture LDAP de l'annuaire AD pour l'authentification Postfix et Dovecot
- **OU** : `OU=DSI,OU=BilluUsers,DC=billu,DC=lan`
- **Mot de passe expiré** : Non (PasswordNeverExpires)

### Configuration Postfix
- **Domaine virtuel** : billu.lan
- **Transport** : dovecot
- **Fichiers LDAP** :
  - `ad_sender_login_maps.cf` — Vérification des expéditeurs SMTP
  - `ad_virtual_mailbox_maps.cf` — Vérification des destinataires
  - `ad_virtual_group_maps.cf` — Groupes AD comme listes de diffusion

### Configuration Dovecot
- **Authentification** : LDAP via Active Directory (172.16.12.1:389)
- **Stockage des mails** : `/var/vmail/vmail1/<domaine>/<utilisateur>/Maildir/`
- **Fichier de configuration LDAP** : `/etc/dovecot/dovecot-ldap.conf`

---

## 6. Fonctionnalités

#### 6.1 Envoi et réception de mails

**Protocoles configurés :**
- **SMTP (Postfix)** : Réception MX sur le port 25, envoi authentifié sur le port 587 (STARTTLS)
- **IMAP (Dovecot)** : Accès aux boîtes mail sur le port 993 (SSL/TLS) et 143 (STARTTLS)

**Flux de traitement d'un email entrant :**
1. Réception par Postfix sur le port 25
2. Vérification du destinataire via requête LDAP vers l'AD
3. Filtrage antispam/antivirus par Amavis
4. Livraison dans la boîte mail Dovecot (`/var/vmail/...`)

#### 6.2 Authentification via Active Directory

**Intégration AD :**
- Authentification Postfix et Dovecot via le compte de service `svc-mail@billu.lan`
- Requêtes LDAP vers l'AD sur le port 389 (172.16.12.1)
- Filtre d'exclusion des comptes désactivés (`userAccountControl`)
- Carnet d'adresses global Roundcube synchronisé depuis l'AD

**Fichiers de requêtes LDAP Postfix :**
- Base DN : `OU=BilluUsers,DC=billu,DC=lan`
- Attribut utilisateur : `userPrincipalName`
- Filtre actif : exclusion des comptes désactivés

#### 6.3 Interfaces web

**Roundcube (Webmail) :**
- URL : https://172.16.13.5/mail/
- Authentification : compte AD au format `prenom.nom@billu.lan`
- Carnet d'adresses global : synchronisé depuis l'Active Directory

**iRedAdmin (Administration) :**
- URL : https://172.16.13.5/iredadmin/
- Compte : `postmaster@billu.lan`
- Fonctions : gestion des domaines, des boîtes mail, des quotas

---

## 7. Maintenance

#### 7.1 Sauvegardes

- Sauvegarder les fichiers de configuration Postfix : `/etc/postfix/`
- Sauvegarder la configuration Dovecot : `/etc/dovecot/`
- Sauvegarder les mails stockés : `/var/vmail/`
- Sauvegarder la configuration Roundcube : `/opt/www/roundcubemail/config/`

#### 7.2 Monitoring

```bash
# Vérifier l'état des services principaux
systemctl status postfix
systemctl status dovecot
systemctl status slapd
systemctl status nginx
systemctl status amavis

# Consulter les logs mail en temps réel
tail -f /var/log/mail.log

# Tester l'authentification d'un utilisateur
doveadm auth test prenom.nom@billu.lan 'MotDePasse'
```

---

## 8. Références

- https://www.iredmail.org/ - Site officiel iRedMail
- https://docs.iredmail.org/install.iredmail.on.debian.ubuntu.html - Guide d'installation sur Debian
- https://docs.iredmail.org/active.directory.html - Intégration Active Directory
- https://doc.dovecot.org/configuration_manual/authentication/ldap/ - Documentation Dovecot LDAP
- https://www.postfix.org/ - Documentation Postfix

---

## 9. Historique des modifications

| Date       | Auteur    | Modification                             |
| ---------- | --------- | ---------------------------------------- |
| 23/02/2026 | Christian | Création du README iRedMail              |

---

## 10. Contributeurs

- **Christian** - Installation, configuration et documentation

---

**Projet** : TSSR1025 Projet 3 - Build Your Infra  
**Entreprise** : BillU  
**Sprint** : 3  
**Dernière mise à jour** : 23/02/2026  

---
