## Sommaire

1. [Création de l’arborescence du site](#1-création-de-larborescence-du-site)
2. [Configuration du VirtualHost HTTP](#2-configuration-du-virtualhost-http)
3. [Mise en place du certificat SSL auto-signé](#3-mise-en-place-du-certificat-ssl-auto-signé)
4. [Configuration du VirtualHost HTTPS](#4-configuration-du-virtualhost-https)
5. [Redirection HTTP vers HTTPS](#5-redirection-http-vers-https)
6. [Intégration DNS Active Directory](#6-intégration-dns-active-directory)
7. [Configuration des règles firewall pfSense](#7-configuration-des-règles-firewall-pfsense)
   - [7.1 Logique générale du filtrage](#71-logique-générale-du-filtrage)
   - [7.2 Règles LAN vers DMZ](#72-règles-lan-vers-dmz)
   - [7.3 Règles DMZ vers LAN](#73-règles-dmz-vers-lan)
   - [7.4 Publication WAN vers DMZ (NAT)](#74-publication-wan-vers-dmz-nat)
1. [Tests de validation](#8-tests-de-validation)


---

Partons du principe que le serveur Web externe est correctement installé sur la machine `webexterne.billu.lan`, positionnée en **DMZ**.

Apache2 est installé, actif et le service répond sur le port 80 en local.

Nous pouvons donc passer directement à la configuration du site et de la sécurisation HTTPS.

---

## 1. Création de l'arborescence du site

Avant de configurer Apache, il est nécessaire de créer l'arborescence qui accueillera les fichiers du site, et d'en attribuer les droits au compte de service Apache.

### 1.1 Création du dossier racine

```bash
mkdir -p /var/www/billu
```

### 1.2 Attribution des droits

Les fichiers doivent appartenir à l'utilisateur `www-data`, utilisé par Apache pour servir le contenu :

```bash
chown -R www-data:www-data /var/www/billu
chmod -R 755 /var/www/billu
```

### 1.3 Création de la page d'accueil

Créer un fichier `index.html` de test afin de valider la configuration :

```bash
nano /var/www/billu/index.html
```

A remplir a convenance :

``` html
<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="utf-8" />
  <title>BillU - Site vitrine</title>
</head>
<body>
  <h1>BillU</h1>
  <p>Site vitrine - Apache</p>
</body>
</html>
```
### 1.4 Vérification locale

Tester le rendu depuis le serveur avant toute configuration de VirtualHost :

```bash
curl http://localhost
```

Résultat attendu : affichage du contenu HTML de la page créée.

---

## 2. Configuration du VirtualHost HTTP

Le VirtualHost permet à Apache de répondre à un nom de domaine précis (`www.billu.lan`) et de servir les fichiers depuis le bon répertoire.

### 2.1 Création du fichier de configuration

```bash
nano /etc/apache2/sites-available/billu.conf
```

Contenu du VirtualHost :

```apache
<VirtualHost *:80>
    ServerName www.billu.lan
    ServerAlias billu.lan
    DocumentRoot /var/www/billu

    <Directory /var/www/billu>
        Options -Indexes +FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/billu_error.log
    CustomLog ${APACHE_LOG_DIR}/billu_access.log combined
</VirtualHost>
```

> L'option `-Indexes` empêche l'affichage du contenu du dossier si aucun fichier d'index n'est trouvé, ce qui est une bonne pratique de sécurité.

### 2.2 Activation du site

Activer le nouveau VirtualHost et désactiver le site par défaut Apache :

```bash
a2ensite billu.conf
a2dissite 000-default.conf
```

### 2.3 Vérification de la configuration

Contrôler la syntaxe avant de recharger Apache :

```bash
apache2ctl configtest
```

Résultat attendu :

```
Syntax OK
```

### 2.4 Rechargement du service

```bash
systemctl reload apache2
```


---

## 3. Mise en place du certificat SSL auto-signé

Afin de chiffrer les communications entre les clients et le serveur, un certificat SSL est nécessaire. Dans ce contexte, un certificat **auto-signé** est utilisé (adapté à un environnement interne ou de développement).

### 3.1 Création du dossier SSL

```bash
mkdir /etc/apache2/ssl
```

### 3.2 Génération du certificat

```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/apache2/ssl/billu.key \
    -out /etc/apache2/ssl/billu.crt
```

Lors de la génération, renseigner les informations demandées. Le champ **Common Name (CN)** doit obligatoirement correspondre au nom de domaine du site :

```
Common Name : www.billu.lan
```

> Un certificat auto-signé génèrera un avertissement dans les navigateurs. Pour un environnement de production, il conviendra de le remplacer par un certificat signé par une autorité de certification (CA interne ou publique).


---

## 4. Configuration du VirtualHost HTTPS

Le VirtualHost HTTPS écoute sur le port 443 et utilise le certificat généré précédemment pour chiffrer les échanges.

### 4.1 Activation du module SSL

```bash
a2enmod ssl
```

### 4.2 Création du fichier de configuration

```bash
nano /etc/apache2/sites-available/billu-ssl.conf
```

Contenu du VirtualHost HTTPS :

```apache
<VirtualHost *:443>
    ServerName www.billu.lan
    ServerAlias billu.lan
    DocumentRoot /var/www/billu

    SSLEngine on
    SSLCertificateFile /etc/apache2/ssl/billu.crt
    SSLCertificateKeyFile /etc/apache2/ssl/billu.key

    <Directory /var/www/billu>
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/billu_ssl_error.log
    CustomLog ${APACHE_LOG_DIR}/billu_ssl_access.log combined
</VirtualHost>
```

### 4.3 Activation du site HTTPS

```bash
a2ensite billu-ssl.conf
apache2ctl configtest
systemctl reload apache2
```

### 4.4 Vérification du port d'écoute

Confirmer qu'Apache écoute bien sur le port 443 :

```bash
ss -tlnp | grep :443
```

Résultat attendu :

```
0.0.0.0:443
```


---

## 5. Redirection HTTP vers HTTPS

Afin de forcer l'utilisation du HTTPS, toute requête arrivant sur le port 80 doit être automatiquement redirigée vers le port 443.

### 5.1 Activation du module rewrite

```bash
a2enmod rewrite
```

### 5.2 Modification du VirtualHost HTTP

Ouvrir le fichier de configuration HTTP :

```bash
nano /etc/apache2/sites-available/billu.conf
```

Ajouter les directives de redirection dans le bloc `<VirtualHost *:80>` :

```apache
RewriteEngine On
RewriteCond %{HTTPS} off
RewriteRule ^(.*)$ https://%{HTTP_HOST}%{REQUEST_URI} [L,R=301]
```

> La redirection `301` indique aux navigateurs et moteurs de recherche que le déplacement vers HTTPS est permanent.

### 5.3 Rechargement du service

```bash
systemctl reload apache2
```

Résultat attendu : toute requête HTTP vers `http://www.billu.lan` est automatiquement redirigée vers `https://www.billu.lan`.

---

## 6. Intégration DNS Active Directory

Pour que le serveur Web soit accessible par son nom depuis le réseau interne, un enregistrement DNS doit être créé dans la zone `billu.lan` du serveur Active Directory.

### 6.1 Ajout de l'enregistrement A

Depuis le serveur AD, dans la console **DNS Manager** :

- Zone : `billu.lan`
- Ajouter un enregistrement de type **A** :

|Champ|Valeur|
|---|---|
|Nom|`www`|
|IP|`10.10.11.2`|
![[Capture d'écran 2026-02-18 205945.png]]

### 6.2 Vérification de la résolution

Depuis un poste du réseau LAN, vérifier que le nom est correctement résolu :

```bash
nslookup www.billu.lan
```

Résultat attendu :

```
Name:    www.billu.lan
Address: 10.10.11.2
```

---

## 7. Configuration des règles firewall pfSense

### 7.1 Logique générale de filtrage

pfSense applique les règles de filtrage selon les principes suivants :

- Les règles sont évaluées **interface par interface**
- L'évaluation se fait **de haut en bas**
- La **première règle correspondante** est appliquée

Les règles doivent être placées :

- Sur **l'interface d'où part le trafic**
- **Au-dessus** des règles de blocage génériques

### 7.2 Règles LAN → DMZ

Ces règles autorisent les flux légitimes depuis le LAN vers le serveur Web en DMZ, et bloquent tout autre trafic.

Interface : **LAN**

**Règle – SSH Administration**

|Paramètre|Valeur|
|---|---|
|Action|Pass|
|Source|IP PC Admin|
|Destination|`10.10.11.2`|
|Port|`22` (SSH)|

**Règle – HTTP Interne**

|Paramètre|Valeur|
|---|---|
|Action|Pass|
|Source|LAN net|
|Destination|`10.10.11.2`|
|Port|`80` (HTTP)|

**Règle – HTTPS Interne**

|Paramètre|Valeur|
|---|---|
|Action|Pass|
|Source|LAN net|
|Destination|`10.10.11.2`|
|Port|`443` (HTTPS)|
![[Capture d'écran 2026-02-18 210115 1.png]]

### 7.3 Règles DMZ → LAN

Par mesure de sécurité, un serveur en DMZ ne doit jamais pouvoir initier de connexions vers le réseau interne. Cela limite l'impact en cas de compromission.

Interface : **DMZ**

|Paramètre|Valeur|
|---|---|
|Action|Block|
|Source|DMZ net|
|Destination|LAN net|

![[Capture d'écran 2026-02-18 210201.png]]
### 7.4 Publication WAN → DMZ (NAT)

Les règles NAT permettent de rediriger le trafic entrant depuis Internet vers le serveur Web en DMZ.

Interface : **WAN**

**NAT – HTTP**

|Paramètre|Valeur|
|---|---|
|Interface|WAN|
|Port destination|`80`|
|Redirection vers|`10.10.11.2:80`|

**NAT – HTTPS**

|Paramètre|Valeur|
|---|---|
|Interface|WAN|
|Port destination|`443`|
|Redirection vers|`10.10.11.2:443`|

> Pour chaque règle NAT, cocher **Add associated firewall rule** afin qu'Apache soit automatiquement accessible depuis l'extérieur.

Appliquer les changements après création des règles.

![[Capture d'écran 2026-02-18 210323.png]]
---

## 8. Tests de validation

Une fois l'ensemble de la configuration appliquée, plusieurs tests permettent de valider le bon fonctionnement du serveur.

### Test depuis le réseau interne (LAN)

Accéder au site depuis un poste du LAN via son nom DNS :

```
https://www.billu.lan
```

Résultat attendu : la page du site s'affiche. Un avertissement de sécurité lié au certificat auto-signé peut apparaître — il est normal dans ce contexte.

