---
title: "Atelier - Installation et configuration d'un serveur de messagerie iRedMail et client Thunderbird - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/3590/pages/16582"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Courrier électronique

## Atelier - Installation et configuration d'un serveur de messagerie iRedMail et client Thunderbird

Moyen

01min

Auto-validation

Courrier électronique

## Atelier - Installation et configuration d'un serveur de messagerie iRedMail et client Thunderbird

## Introduction

Le courrier électronique est un outil de communication incontournable, tant dans la sphère professionnelle que personnelle. Pour une gestion optimale de vos emails, un client mail lourd comme Thunderbird offre une alternative robuste et personnalisable aux webmails.

Cet atelier vous accompagne dans l'installation et la configuration d'un serveur de messagerie complet avec iRedMail sur Debian 12, et la configuration d'un client Thunderbird pour y accéder.

## Objectifs

✅ Installer iRedMail sur Debian 12.  
✅ Comprendre l'architecture iRedMail (Postfix, Dovecot, Roundcube, etc.).  
✅ Créer des domaines et des comptes email.  
✅ Configurer les services de messagerie (SMTP, IMAP, POP3).  
✅ Accéder à la messagerie via Roundcube.  
✅ Configurer un client Thunderbird.  
✅ Sécuriser le serveur (anti-spam, anti-virus).

## Sommaire

- [✔️ Étape 1 - Prérequis et préparation de Debian 12](https://odyssey.wildcodeschool.com/quests/3590/pages/16582#%EF%B8%8F-%C3%A9tape-1---pr%C3%A9requis-et-pr%C3%A9paration-de-debian-12)
	- [1.1. Préparation du serveur iredmail:](https://odyssey.wildcodeschool.com/quests/3590/pages/16582#11-pr%C3%A9paration-du-serveur-iredmail-)
		- [1.2. Préparation du server DNS:](https://odyssey.wildcodeschool.com/quests/3590/pages/16582#12-pr%C3%A9paration-du-server-dns-)
		- [a. **Nouvelle zone**](https://odyssey.wildcodeschool.com/quests/3590/pages/16582#a-nouvelle-zone)
				- [b. **Ajoutez les enregistrements nécessaires:**](https://odyssey.wildcodeschool.com/quests/3590/pages/16582#b-ajoutez-les-enregistrements-n%C3%A9cessaires)
- [📥 Étape 2 - Téléchargement et installation d'iRedMail](https://odyssey.wildcodeschool.com/quests/3590/pages/16582#-%C3%A9tape-2---t%C3%A9l%C3%A9chargement-et-installation-diredmail)
	- [2.1. Téléchargement](https://odyssey.wildcodeschool.com/quests/3590/pages/16582#21-t%C3%A9l%C3%A9chargement)
		- [2.2. Installation:](https://odyssey.wildcodeschool.com/quests/3590/pages/16582#22-installation-)
		- [2.3. Configuration:](https://odyssey.wildcodeschool.com/quests/3590/pages/16582#23-configuration-)
- [⚙️ Étape 3 - Configuration initiale d'iRedMail](https://odyssey.wildcodeschool.com/quests/3590/pages/16582#%EF%B8%8F-%C3%A9tape-3---configuration-initiale-diredmail)
- [🧑💻 Étape 4 - Gestion des domaines et des comptes](https://odyssey.wildcodeschool.com/quests/3590/pages/16582#-%C3%A9tape-4---gestion-des-domaines-et-des-comptes)
- [📨 Étape 5 - Accès à la messagerie via webmail](https://odyssey.wildcodeschool.com/quests/3590/pages/16582#-%C3%A9tape-5---acc%C3%A8s-%C3%A0-la-messagerie-via-webmail)
- [🖥️ Étape 6 - Configuration de Thunderbird](https://odyssey.wildcodeschool.com/quests/3590/pages/16582#%EF%B8%8F-%C3%A9tape-6---configuration-de-thunderbird)
- [🏆 Conclusion](https://odyssey.wildcodeschool.com/quests/3590/pages/16582#-conclusion)

## ✔️ Étape 1 - Prérequis et préparation de Debian 12

- **Serveur Debian 12:** une machine virtuelle.
- **Nom de domaine:** Enregistré et configuré avec les enregistrements DNS (MX, A) pour votre serveur (ex: `tssr.lab`).
- **Accès SSH:** Avec un compte root ou sudo.
- **Connexion internet:** Stable et active.
- **Connaissances Linux:** De base.
- **Ressources:** Minimum 4 Go de RAM et 20 Go d'espace disque.
- **Configuration** des VMS:

| Fonction de la VM | Serveur | Serveur | Client | Client |
| --- | --- | --- | --- | --- |
| Nom | ad-srv | mail | Clientubuntu1 | ClientWin1 |
| OS | Windows Server 2022 | debian 12 | Windows 10 | Windows 10 |
| OS version | Standard Desktop Experience | debian 12 | Professionnel | Professionnel |
| RAM | 4/8 Go | 2/4 Go | 2/4 Go | 2/4 Go |
| Langue à installer | English (US) | français | French | French |
| Time and currency / keyboard | French | français | French | French |
| Carte réseau VirtualBox | Réseau privé | Réseau privé + NAT | Réseau privé+ NAT | Réseau privé+ NAT |
| Adresse IP | 172.20.0.5 | 172.20.0.3/24 | 172.20.0.200/24 | 172.20.0.100/24 |
| Passerelle |  | \- | \- | \- |
| DNS | 127.0.0.1 | 172.20.0.5/24 ou 127.0.0.1 | 172.20.0.5 | 172.20.0.5 |
| Firewall |  | Désactivé | Désactivé | Désactivé |

## 1.1. Préparation du serveur iredmail:

- **Mise à jour du système:**
	```bash
	1
	sudo apt update && sudo apt upgrade -y
	```
- **Configuration du nom d'hôte:** Remplacez `mail.tssr.lab` par le FQDN de votre serveur.
	```bash
	1
	sudo hostnamectl set-hostname mail
	2
	echo "mail.tssr.lab" | sudo tee /etc/hostname
	```
- **Configuration du fichier /etc/hosts:**
	```bash
	1
	172.20.0.3  localhost mail.tssr.lab
	```
- **Installation des outils:**
	```bash
	1
	sudo apt install -y wget vim
	```

## 1.2. Préparation du server DNS:

### a. Nouvelle zone

- Clic droit sur "Zones de recherche directe" -> "Nouvelle Zone...".  
	Choisissez "Zone principale" et cliquez sur "Suivant".
- Entrez le nom de votre domaine (ex: *votre-domaine.com*) et cliquez sur "Suivant".
- Choisissez "Créer un nouveau fichier avec ce nom de fichier" et cliquez sur "Suivant".  
	et "Terminer".

### b. Ajoutez les enregistrements nécessaires:

**Enregistrement MX:**

- Clic droit sur votre domaine -> "Nouvel enregistrement...".
- Choisissez "Échangeur de courrier (MX)" et cliquez sur "Créer un enregistrement...".
- Dans "Nom de l'hôte de l'échangeur de courrier", entrez le nom d'hôte de votre serveur iredmail (ex: mail).
- Dans "Priorité", entrez une valeur faible (ex: 10).
- Cliquez sur "OK".

**Enregistrement A:**

- Clic droit sur votre domaine -> "Nouvel enregistrement...".
- Choisissez "Hôte (A)" et cliquez sur "Créer un enregistrement...".
- Dans "Nom", entrez le nom d'hôte de votre serveur Iredmail (ex: mail).
- Dans "Adresse IP", entrez l'adresse IP de votre serveur iredmail.
- Cliquez sur "OK".

**Enregistrement CNAME (optionnel):**

- Clic droit sur votre domaine -> "Nouvel enregistrement...".
- Choisissez "Alias (CNAME)" et cliquez sur "Créer un enregistrement...".
- Dans "Nom d'alias", entrez un alias pour votre serveur iredmail (iredmail)).
- Dans "Nom de domaine complet de la cible", entrez le nom de domaine complet de votre serveur iredmail (ex: mail.tssr.lab).
- Cliquez sur "OK".

## 📥 Étape 2 - Téléchargement et installation d'iRedMail

## 2.1. Téléchargement

Depuis le site officiel: [https://www.iredmail.org/download.html](https://www.google.com/url?sa=E&source=gmail&q=https://www.google.com/url?sa=E%26source=gmail%26q=https://www.iredmail.org/download.html)

## 2.2. Installation:

```shell
Avant de procéder à l'installation, vérifier si une version plus récente d'iRedMail est disponible.

Consultez la page de téléchargement officielle : https://www.iredmail.org/download.html pour obtenir la dernière version.

Si une version plus récente est disponible, remplacez le lien dans la commande ci-dessous par celui de la version la plus récente.
```
```bash
1
wget https://github.com/iredmail/iRedMail/archive/refs/tags/1.7.2.tar.gz
2
tar xvf 1.7.2.tar.gz
3
cd iRedMail-1.7.2
4
bash iRedMail.sh
```

## 2.3. Configuration:

- **Stockage des emails:** Choisissez l'emplacement (par défaut `/var/vmail`).
- **Serveur web:** Nginx.
- **Backend:** OpenLDAP.
- **Premier domaine:** (ex: `tssr.lab`).
- **Mot de passe administrateur de la base de donnée:** Fort et sécurisé.
- **Nom de domaine** du premier mail (ex: `tssr.lab`)
- **Mot de passe administrateur du premier mail:** Fort et sécurisé.
- **Composant optionnel** cochez toutes les options
- **Confirmation:** Vérifiez les options et confirmez.

## ⚙️ Étape 3 - Configuration initiale d'iRedMail

Depuis le client windows ou ubuntu

1. **Accès à l'administration:** `https://mail.tssr.lab/iredadmin`
2. **Connexion:** Avec `postmaster@tssr.lab` et le mot de passe.
3. **Configuration:**
	- Vérifier la configuration du **domaine** existant: Nom de domaine, adresse

## 🧑💻 Étape 4 - Gestion des domaines et des comptes

Cette étape vous permet de créer des comptes utilisateurs sur votre domaine.  
**1\. Créez un compte utilisateur:**

- Cliquez sur le bouton "Add" puis user.
- **Exemple de configuration:**
	- **Email:** `utilisateur1@tssr.lab`
		- **Password:** Un mot de passe fort (au moins 8 caractères avec des lettres majuscules et minuscules, des chiffres et des symboles).
		- **Name:** `Utilisateur Un`
		- **Quota:** 1024 (quota de 1 Go)
		- **Active:** Cochez la case pour activer le compte.
- Cliquez sur "Add" pour créer le compte utilisateur.

**2\. (Optionnel) Créez un groupe de distribution:**

- Dans le menu de gauche, cliquez sur "Mailing List".
- Cliquez sur le bouton "Add".
- **Exemple de configuration:**
	- **Address:** `equipe-support@tssr.lab`
		- **Password:** Un mot de passe fort.
		- **Name:** `Équipe de vente`
		- **Active:** Cochez la case pour activer le groupe.
- Cliquez sur "Add" pour créer le groupe de distribution.

**3\. (Optionnel) Créez un alias:**

- Dans le menu de gauche, cliquez sur "Alias".
- Cliquez sur le bouton "Add".
- **Exemple de configuration:**
	- **Address:** `info@tssr.lab`
		- **Forwarding To:** `utilisateur1@exemple.com`
- Cliquez sur "Add" pour créer l'alias.

## 📨 Étape 5 - Accès à la messagerie via webmail

1. **Webmail:** `https://mail.tssr.lab/mail` (Roundcube).

## 🖥️ Étape 6 - Configuration de Thunderbird

1. **Lancez Thunderbird** et cliquez sur "Configurer un compte existant".
2. **Saisissez les informations du compte:**
	- **Votre nom:** Votre nom complet.
		- **Adresse email:** (ex: `utilisateur@tssr.lab`).
		- **Mot de passe:** Du compte email.
3. **Configuration manuelle (si nécessaire):**
	- **Serveur entrant:** \`mail.tssr.lab (IMAP)
		- **Port:** 143
		- **Serveur sortant (SMTP):** \`mail.tssr.lab
		- **Port:** 587
		- **Nom d'utilisateur:** Adresse email complète.
		- **Authentification:** Mot de passe normal.
		- **Sécurité de la connexion:** SSL/TLS.
4. **Cliquez sur "Terminer".**

Vous pouvez maintenant tester l'envoi de mail entre les utilisateurs

## 🏆 Conclusion

Bravo! Vous avez installé et configuré iRedMail sur Debian 12, et configuré Thunderbird. Vous pouvez maintenant gérer vos emails efficacement.  
Consultez la documentation iRedMail pour plus de configuration. " [https://docs.iredmail.org/index.html](https://docs.iredmail.org/index.html) "

Quête terminée le **jeudi 12 février 2026**