# Guide d'installation - iRedMail

## Sommaire

1. [Préparation du système](#1-préparation-du-système)
   - 1.1 [Pré-requis](#11-pré-requis)
   - 1.2 [Connexion en root](#12-connexion-en-root)
   - 1.3 [Configurer le hostname](#13-configurer-le-hostname)
   - 1.4 [Configurer /etc/hosts](#14-configurer-etchosts)
   - 1.5 [Configurer le DNS](#15-configurer-le-dns)
   - 1.6 [Installation des outils nécessaires](#16-installation-des-outils-nécessaires)
   - 1.7 [Création de l'utilisateur de service mail dans Active Directory](#17-création-de-lutilisateur-de-service-mail-dans-active-directory)

2. [Installation d'iRedMail avec OpenLDAP](#2-installation-diredmail-avec-openldap)
   - 2.1 [Télécharger iRedMail](#21-télécharger-iredmail)
   - 2.2 [Lancer l'installateur](#22-lancer-linstallateur)
   - 2.3 [Assistant d'installation iRedMail](#23-assistant-dinstallation-iredmail)
   - 2.4 [Redémarrer après installation](#24-redémarrer-après-installation)

3. [Vérification post-installation](#3-vérification-post-installation)
   - 3.1 [Vérifier les services](#31-vérifier-les-services)
   - 3.2 [Vérifier l'accès web](#32-vérifier-laccès-web)

---

## 1. Préparation du système

### 1.1 Pré-requis

- Système d'exploitation : Debian 12
- RAM : minimum 2 Go 
- Disque : minimum 20 Go
- Connexion : Root ou Sudo (`apt install sudo`)
- Hostname FQDN : `DOM-MAIL-01.billu.lan`
- Port 389 ouvert vers le serveur AD (172.16.12.1)
- Ports mail : 25, 587, 465, 143, 993


### 1.2 Connexion en root

```bash
su -
```
*Ou utilisez `sudo` si votre utilisateur est dans le groupe sudoers*


### 1.3 Configurer le hostname
- Configurer le hostname du serveur

```bash
hostnamectl set-hostname DOM-MAIL-01.billu.lan
```
- Vérifier le hostname dans le terminal

```bash
hostname 
```  

### 1.4 Configurer /etc/hosts

```bash
nano /etc/hosts
```

```
127.0.0.1       localhost
172.16.13.5     DOM-MAIL-01.billu.lan    DOM-MAIL-01

# Contrôleur de domaine AD
172.16.12.1     DOM-AD-01.billu.lan      DOM-AD-01
```
- Vérifier le FQDN 

```bash
hostname -f     
```

> `hostname -f` doit retourner le FQDN complet. iRedMail se base dessus pour configurer tous les services.

### 1.5 Configurer le DNS

```bash
nano /etc/resolv.conf
```

```
domain billu.lan
search billu.lan
nameserver 172.16.12.1
nameserver 8.8.8.8
```

### 1.6 Installation des outils nécessaires

- Mettre à jour le gestionnaire de paquets

```bash
apt update && apt upgrade -y
```

- Installer les outils nécessaires
```bash
apt install ldap-utils net-tools dnsutils curl wget nano -y 
```
```bash
# Test de connectivité vers l'AD
ping -c 3 172.16.12.1

# Test du port LDAP (INDISPENSABLE)
nc -zv 172.16.12.1 389
# Attendu : Connection to 172.16.12.1 389 port [tcp/ldap] open
```

### 1.7 Création de l'utilisateur de service mail dans Active Directory

- **Opération à effectuer sur le serveur Active directory**

```powershell
New-ADUser `
  -Name "svc-mail" `
  -SamAccountName "svc-mail" `
  -UserPrincipalName "svc-mail@billu.lan" `
  -Path "OU=DSI,OU=BilluUsers,DC=billu,DC=lan" `
  -AccountPassword (ConvertTo-SecureString "Azerty1*" -AsPlainText -Force) `
  -PasswordNeverExpires $true `
  -CannotChangePassword $true `
  -Enabled $true `
  -Description "Compte de service iRedMail - Lecture LDAP"
```

- **Retourner sur le serveur mail Debian**

```bash
#  Test LDAP avec le compte de service
ldapsearch -x -H ldap://172.16.12.1 \
  -D "svc-mail@billu.lan" \
  -w 'Azerty1*' \
  -b "OU=BilluUsers,DC=billu,DC=lan" \
  "(objectClass=user)" sAMAccountName userPrincipalName
```

> Ne passez à l'étape suivante que si le test LDAP retourne bien des utilisateurs.

---

## 2. Installation d'iRedMail avec OpenLDAP

### 2.1 Télécharger iRedMail

```bash
cd /root
wget https://github.com/iredmail/iRedMail/archive/refs/tags/1.7.4.tar.gz
tar xvf 1.7.4.tar.gz
cd iRedMail-1.7.4
```

### 2.2 Lancer l'installateur

```bash
chmod +x iRedMail.sh
bash iRedMail.sh
```

### 2.3 Assistant d'installation iRedMail

- Sélectionner `YES`

![img](Ressources/iredmail_img/installation/01_iredmail_installation.png)

1) Laisser par défaut `/var/mail`
2) Cliquer sur **Next**

![img](Ressources/iredmail_img/installation/02_iredmail_installation.png)

1) Sélectionner Nginx
2) Cliquer sur **Next**

![img](Ressources/iredmail_img/installation/03_iredmail_installation.png)

1) Sélectionner **OpenLDAP** 
2) Cliquer sur **Next**
> IMPORTANT : Sans OpenLDAP la synchronisation avec Active Directory ne sera pas possible

![img](Ressources/iredmail_img/installation/04_iredmail_installation.png)

- Entrer `dc=billu,dc=lan`

![img](Ressources/iredmail_img/installation/05_iredmail_installation.png)

- Entrer le mot de passe Administrateur OpenLDAP `Azerty1*`

![img](Ressources/iredmail_img/installation/06_iredmail_installation.png)

1) Entrer le domain mail principal `billu.lan`
2) Cliquer sur **Next**

![img](Ressources/iredmail_img/installation/07_iredmail_installation.png)

1) Entrer le mot de passe Administrateur mail `Azerty1*`

![img](Ressources/iredmail_img/installation/08_iredmail_installation.png)

```
Compte : postmaster@billu.lan
Mot de passe : Azerty1*
```

1) Sélectionner tous les composants 
2) Cliquer sur **Next**

![img](Ressources/iredmail_img/installation/09_iredmail_installation.png)

- Entrer `Y` pour finaliser l'installation 

![img](Ressources/iredmail_img/installation/10_iredmail_installation.png)


> L'installation peut prendre quelques minutes

- Pour les 2 questions, entrer `Y`

![img](Ressources/iredmail_img/installation/11_iredmail_installation.png)

- Confirmation de fin d'installation 

![img](Ressources/iredmail_img/installation/12_iredmail_installation.png)


### 2.4 Redémarrer après installation

```bash
reboot
```

---

## 3. Vérification post-installation

### 3.1 Vérifier les services

```bash
systemctl status postfix
systemctl status dovecot
systemctl status slapd
systemctl status nginx
systemctl status amavis
```


### 3.2 Vérifier l'accès web

- **Roundcube** : https://172.16.13.5/mail/
- **iRedAdmin** : https://172.16.13.5/iredadmin/

> **Rappel :**   
Compte : postmaster@billu.lan  
Mot de passe : Azerty1*  
