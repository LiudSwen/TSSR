---
title: "Atelier - Déploiement de serveur web - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/3092/pages/11794"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Réseau

## Atelier - Déploiement de serveur web

Moyen

2h

Auto-validation

Réseau

## Atelier - Déploiement de serveur web

## Introduction

Une fois n'est pas coutume, tu vas créer un serveur web sur ta machine locale, et le rendre disponible depuis l’extérieur de ton réseau, sur internet.

## ✔️ Étape 1 - Prérequis

Pour cet atelier, tu as besoin:

- Un hyperviseur comme Virtualbox pour pouvoir créer des VM
- 1 VM nommée `webserver` avec Debian 12 installé et mise à jour, avec:
	- Une carte réseau en mode `Accès par pont` en DHCP
		- Une configuration SSH fonctionnelle
- 1 VM nommée `proxy` avec Debian 12 installé et mise à jour, avec:
	- Une carte réseau en mode `Accès par pont` en DHCP
		- Une configuration SSH fonctionnelle
- Une box opérateur Internet pour donner accès à Internet
- Un périphérique pouvant accéder à internet sans passer par ta box opérateur, comme un smartphone en 4G/5G
- Un compte sur le site de **No-IP** ([https://my.noip.com/](https://my.noip.com/))
```shell
Les expérimentations pratiques ont été testées avec un OS Debian 12 fonctionnant sur VirtualBox 7, lui-même fonctionnant sur un système hôte Ubuntu 22.04 LTS.

Elles peuvent être reproduites avec d'autres versions de systèmes, et sur d'autres environnement, mais des différences peuvent alors apparaître.
```

## 🔬 Étape 2 - Installation d’Apache

Sur la VM `webserver`, exécute les lignes de commandes suivantes pour mettre à jour ton système et installer Apache:

```bash
1
apt update && apt upgrade -y
2
apt install apache2 -y
```

Vérifie le statut du service avec `systemctl status apache2`

Trouve l'adresse IP de la carte `Accès par pont` de ton serveur Web. Cette adresse est fourni par ta box opérateur.  
Sur ta machine hôte, ouvre un navigateur web et connecte toi sur l'adresse IP privée comme `http://Adresse_IP_privée`.  
Tu dois arriver sur la page par défaut de ton serveur web.

## 🔬 Étape 3 - Configuration de la page d'accueil

La page d'accueil par défaut de ton serveur web est `/var/www/html/index.html`.  
Modifie le contenu de cette page:

- Recherche dans la page le titre de la page, que tu vois dans le navigateur
- Modifie le dans le fichier ̀index.html\`
- Enregistre-le fichier, et rafraîchit la page sur le navigateur pour voir la différence

Maintenant, tu vas complètement changer la structure de ton serveur web.  
Remplace le contenu du fichier `index.html` par ceci:

```bash
1
<!DOCTYPE html>
2
<html lang="en">
3
<head>
4
    <meta charset="UTF-8">
5
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
6
    <title>Welcome to My Server</title>
7
    <style>
8
        body {
9
            font-family: Arial, sans-serif;
10
            background-color: #f4f4f4;
11
            display: flex;
12
            justify-content: center;
13
            align-items: center;
14
            height: 100vh;
15
            margin: 0;
16
        }
17
        .container {
18
            text-align: center;
19
            background: white;
20
            padding: 20px;
21
            border-radius: 10px;
22
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
23
        }
24
        h1 {
25
            color: #333;
26
        }
27
        .button {
28
            display: inline-block;
29
            margin-top: 20px;
30
            padding: 10px 20px;
31
            font-size: 16px;
32
            color: white;
33
            background-color: #007BFF;
34
            border: none;
35
            border-radius: 5px;
36
            cursor: pointer;
37
            text-decoration: none;
38
        }
39
        .button:hover {
40
            background-color: #0056b3;
41
        }
42
    </style>
43
</head>
44
<body>
45
    <div class="container">
46
        <h1>Bienvenu sur mon serveur Personnel !</h1>
47
        <a href="next.html" class="button">OK</a>
48
    </div>
49
</body>
50
</html>
```

Ajoute également dans le même dossier que le fichier `index.html` un fichier `next.html` avec ce contenu:

```bash
1
<!DOCTYPE html>
2
<html lang="en">
3
<head>
4
    <meta charset="UTF-8">
5
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
6
    <title>Choose a Site</title>
7
    <style>
8
        body {
9
            font-family: Arial, sans-serif;
10
            background-color: #f4f4f4;
11
            display: flex;
12
            justify-content: center;
13
            align-items: center;
14
            height: 100vh;
15
            margin: 0;
16
        }
17
        .container {
18
            text-align: center;
19
            background: white;
20
            padding: 20px;
21
            border-radius: 10px;
22
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
23
        }
24
        h1 {
25
            color: #333;
26
        }
27
        .button {
28
            display: inline-block;
29
            margin: 10px;
30
            padding: 10px 20px;
31
            font-size: 16px;
32
            color: white;
33
            background-color: #007BFF;
34
            border: none;
35
            border-radius: 5px;
36
            cursor: pointer;
37
            text-decoration: none;
38
        }
39
        .button:hover {
40
            background-color: #0056b3;
41
        }
42
    </style>
43
</head>
44
<body>
45
    <div class="container">
46
        <h1>Choose a Site to Visit</h1>
47
        <a href="https://www.google.com" class="button">Google</a>
48
        <a href="https://www.wikipedia.org" class="button">Wikipedia</a>
49
        <a href="https://www.wildcodeschool.com" class="button">WCS</a>
50
        <a href="index.html" class="button">Home</a>
51
    </div>
52
</body>
53
</html>
```

Redémarre le service apache2 et regarde la différence dans ton navigateur web.

## 🔬 Étape 4 - Configuration de ta box internet

Maintenant tu vas faire en sorte que ton serveur soit accessible de l’extérieur de ton réseau.  
Fais un premier test directement en utilisant le périphérique qui a accès à internet sans passer par ta box, en 4G/5G. Ouvre un navigateur et ouvre le site `http://Adresse_IP_Privée_de_ta_VM/`.  
Est-ce que l'accès à ton site fonctionne?

C'est normal car cette adresse est privée et n'est pas vu depuis l'exterieur de ton réseau.  
Maintenant, à partir de ta machine hôte, vas sur le site [https://mon-ip.io/](https://mon-ip.io/) pour récupérer ton adresse IP publique, celle fournie par ton FAI. N’hésite pas à rafraîchir la page d'accueil du site pour être sûr d'avoir la bonne adresse.  
Maintenant, à partir de ton smartphone en 4G/5G, vas sur le site `http://Adresse_IP_Publique_de_ta_box/`  
Est-ce que l'accès à ton site fonctionne?

C'est normal, car ton site web est derrière ta box, il faut faire une redirection de port.  
Suivant ton opérateur internet, et le type de ta box, les manipulations ci-dessous peuvent être légèrement différentes.

Sur ta machine hôte, ouvre un navigateur internet:

- Dans l'URL, met l'adresse IP interne pour accéder à l'interface d'administration, comme par exemple `192.168.1.254`
- Note l'adresse IP publique de ta box, que tu as déjà eu sur le site de mon-ip
- Ensuite cherche l'emplacement du paramètre de redirection de ports (règle NAT/PAT en général)
- Créer une règle qui fais une redirection du port 80 externe (port source) de ta box, vers l'adresse IP privée de ta VM sur le port 80 (port destination)
- Enregistre ta configuration

À partir de ton appareil pouvant se connecter à interner sans ta box, ouvre un navigateur internet et mets l'adresse IP publique de ta box internet que tu as noté tout à l'heure.  
Par exemple `http://76.112.45.94`.  
Tu dois arriver sur ton serveur web hébergé par ta VM.

Pour sécuriser ta connexion, modifie ta règle de PAT en mettant un autre port que le port 80 pour le port **externe**, par exemple le 22545.  
Ensuite fais le même test à partir de ton périphérique et ajoute le port à la fin de l'URL.  
Avec l'adresse IP de tout à l'heure, cela donne `http://76.112.45.94:22545`.  
Tu dois de nouveau accéder à ton serveur web interne.

## 🔬 Étape 5 - Enregistrement d'un nom de domaine

Se connecter sur le site de **no-ip**.  
Aller dans *Dynamic DNS -> NO-IP Hostnames* et cliquer sur *Create a Hostname*.  
Mettre les informations suivantes:

- Hostname: Donne un nom pour accéder à ton site
- Domain: Sélectionne un nom de domaine dans la liste
- Record Type: Choisis un enregistrement A
- IPV4 Address: Tu dois avoir ton adresse IP publique, celle de ta box

À partir de ton appareil pouvant se connecter à interner sans ta box, ouvre un navigateur internet et mets directement le nom que tu as défini, en n'oubliant pas le domaine, ni le numéro de port que tu as modifié.  
Par exemple avec le nom de site `HomeHomeWCS` et le domaine `webhop.me` cela donne `http://HomeHomeWCS.webhop.me:22545`.  
Tu dois arriver sur ton serveur web hébergé par ta VM.

## 🔬 Étape 6 - Mise en place d'un reverse proxy

Pour sécuriser l'accès au serveur, tu vas configurer un reverse proxy.  
Au delà de cela, un reverse proxy est une solution pour héberger plusieurs serveurs web. Dans ce cas, les différentes requêtes pour les noms de domaine seront dirigées vers les serveurs appropriés.  
Sur la VM `proxy`, exécute les commandes suivantes pour installer apache2 et activer les modules du reverse proxy:

```bash
1
apt install apache2 -y
2
a2enmod proxy
3
a2enmod proxy_http
4
a2enmod proxy_balancer
5
a2enmod lbmethod_byrequests
```

Relance le service apache2 et vérifie que tout est ok.

Sauvegarde le fichier **/etc/apache2/sites-available/000-default.conf** en.bak (par exemple).  
Créer un nouveau fichier **000-default.conf** et mets le contenu suivant dedans:

```bash
1
<VirtualHost *:22545>
2
    # Ici on doit trouver le nom de ton site avec le domaine
3
    ServerName homehomewcs.webhop.me
4

5
    ProxyPreserveHost On
6
    # Les 2 paramètres ci-dessous doivent avoir l'adresse IP de la VM webserver avec le port par défaut pour le http, donc 80
7
    ProxyPass / http://192.168.1.100:80/
8
    ProxyPassReverse / http://192.168.1.100:80/
9

10
    <Location />
11
        Order allow,deny
12
        Allow from all
13
    </Location>
14
</VirtualHost>
```

Il faut aussi configurer le port d'écoute du serveur.  
Édite le fichier `/etc/apache2/ports.conf` et ajoute à la fin la ligne `Listen 22545`.

Il faut relancer la configuration avec le nouveau fichier:

```bash
1
a2ensite 000-default.conf
2
systemctl restart apache2
```

Modifie ou supprime la règle de PAT que tu as sur ta box:

- Redirige le port 22545 externe vers le port 22545 interne
- Le tout est redirigé sur l'adresse IP du proxy

À partir de ton appareil pouvant se connecter à interner sans ta box, ouvre un navigateur internet et mets la même URL que tout à l'heure avec le port.  
Avec le même exemple, cela donne `http://HomeHomeWCS.webhop.me:22545`.  
Tu dois arriver sur ton serveur web hébergé par ta VM.

Maintenant modifie le fichier **/etc/apache2/sites-available/000-default.conf** pour avoir un VirtualHost sur le port 80 (au lieu du 22545).  
Relance la configuration et vérifie que ton serveur est toujours accessible, mais cette fois-ci sans mettre le port 22545.

Quête terminée le **lundi 12 janvier 2026**