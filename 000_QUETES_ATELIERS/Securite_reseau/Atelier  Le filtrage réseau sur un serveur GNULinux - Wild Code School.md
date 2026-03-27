---
title: "Atelier : Le filtrage réseau sur un serveur GNU/Linux - Wild Code School"
source: "https://odyssey.wildcodeschool.com/quests/2390/pages/14498"
author:
published:
created: 2026-03-23
description: "Odyssey by Wild Code School"
tags:
  - "clippings"
---
Sécurité réseau

## Atelier: Le filtrage réseau sur un serveur GNU/Linux

Mise en place de règle de filtrage sur le pare-feu Netfilter à l'aide de nftables, dans le contexte d'un serveur.

Moyen

2h

Auto-validation

Sécurité réseau

## Atelier: Le filtrage réseau sur un serveur GNU/Linux

## Introduction

Cet atelier consiste à configurer des règles de filtrage réseau sur **Netfilter** avec l'outil **NFtables** afin de sécuriser un serveur **GNU/Linux** classique.

![Netfilter logo](https://www.netfilter.org/images/netfilter-logo3.png)

## 📚 Pré-requis

Avant de commencer cet atelier, il est préférable d'avoir déjà terminé la quête suivante:

```shell
NFtablesDécouverte de Netfilter, le pare-feu intégré à Linux et de son outil de configuration NFtables3hVoir la quête - NFtables
```

## 🤓 Objectifs:

✅ Pratiquer la configuration de **Netfilter** avec **NFtables**  
✅ Analyser des configurations existantes  
✅ Déployer sa propre configuration

## Sommaire

- [🔬 Le contexte](https://odyssey.wildcodeschool.com/quests/2390/pages/14498#-le-contexte)
- [📌 La configuration de netfilter avec nftables (rappel)](https://odyssey.wildcodeschool.com/quests/2390/pages/14498#-la-configuration-de-netfilter-avec-nftables-rappel)
- [🔬 Étude de configurations existantes](https://odyssey.wildcodeschool.com/quests/2390/pages/14498#-%C3%A9tude-de-configurations-existantes)
- [⚙️ Création d'une configuration](https://odyssey.wildcodeschool.com/quests/2390/pages/14498#%EF%B8%8F-cr%C3%A9ation-dune-configuration)
- [💪 Conclusion](https://odyssey.wildcodeschool.com/quests/2390/pages/14498#-conclusion)

## 🔬 Le contexte

Cet atelier nécessite un serveur sur lequel tournent des services classiques ainsi qu'une machine cliente pour en tester l'accès.

Ces 2 machines doivent pouvoir communiquer via un réseau IPv4 et IPv6 quelconque. Il peut s'agir de machines virtuelles.

Dans la suite on suppose que le serveur est une VM sur VirtualBox avec une configuration réseau en pont et que la machine hôte tient lieu de client.

Pour le serveur, installe une debian serveur classique en choissisant pendant l'installation la disponibilité d'un serveur ssh et d'un serveur web. La configuration par défaut de ces 2 services est suffisante pour cet atelier.

Une fois l'installation réalisée:

Il est possible de joindre le serveur à partir du client en utilisant `ping` en IPv4 comme en IPv6.

```bash
1
wilder@host:~$ ping <server's ipv4>
2
PING <server's ipv4> (<server's ipv4>) 56(84) bytes of data.
3
64 bytes from <server's ipv4>: icmp_seq=1 ttl=64 time=0.390 ms
4
64 bytes from <server's ipv4>: icmp_seq=2 ttl=64 time=0.597 ms
5
[...]
6
wilder@host:~$ ping <server's ipv6>
7
PING <server's ipv6>(<server's ipv6>) 56 data bytes
8
64 bytes from <server's ipv6>: icmp_seq=1 ttl=64 time=0.674 ms
9
64 bytes from <server's ipv6>: icmp_seq=2 ttl=64 time=0.493 ms
10
[...]
```

Il est possible de se connecter à la machine via un client **ssh** et d'obtenir une invite de login similaire à l'exemple suivant:

```bash
1
wilder@host:~$ ssh <server>
2
The authenticity of host '<server>' can't be established.
3
ED25519 key fingerprint is SHA256:avvDFOAP4/yhEOHm/ZPOfLcbtaZ+zNPsbq3s4KeGGQk.
4
This key is not known by any other names
5
Are you sure you want to continue connecting (yes/no/[fingerprint])?
6
```

Il est aussi possible de se connecter à la machine via un client http (un navigateur web par exemple) en insérant une url type: `http://<server>` et d'obtenir la page web par défaut d'apache.

![Default apache webpage on a Debian server](https://storage.googleapis.com/quest_editor_uploads/JdLO9RwnD6EBtvouD0ffSU5NhYuy6tto.png)

Ces connexions **http** peuvent aussi être effectuées en ligne de commande (ce qui peut rendre l'analyse des résultats, notamment dans le cas d'erreur plus simple) à l'aide d'outils tels que [wget](https://www.gnu.org/software/wget/), [curl](https://curl.se/) ou même très basiquement avec la commande [telnet](https://fr.wikipedia.org/wiki/Telnet).

Exemple d'utilisation de `telnet` en supposant que le serveur s'appelle `debfw.lan` et dispose de l'adresse IP: `10.0.0.172`:

```bash
1
wilder@host:~$ telnet debfw 80
2
Trying 10.0.0.172...
3
Connected to debfw.lan.
4
Escape character is '^]'.
5
GET / HTTP/1.1
6
Host: debfw.lan
7

8
HTTP/1.1 200 OK
9
Date: Fri, 13 Jan 2023 13:47:24 GMT
10
Server: Apache/2.4.54 (Debian)
11
Last-Modified: Thu, 12 Jan 2023 13:40:10 GMT
12
ETag: "29cd-5f211417c03d8"
13
Accept-Ranges: bytes
14
Content-Length: 10701
15
Vary: Accept-Encoding
16
Content-Type: text/html
17

18

19
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
20
<html xmlns="http://www.w3.org/1999/xhtml">
21
  <head>
22
[...]
23
```

On peut envisager de vérifier qu'il n'existe pas d'autres ports ouverts sur le serveur en utilisant un outil tel que [nmap](https://nmap.org/).

```bash
1
# Scan ipv4
2
wilder@host:~$ nmap -A -T4 debfw
3
Starting Nmap 7.80 ( https://nmap.org ) at 2023-01-13 14:57 CET
4
Nmap scan report for debfw (10.0.0.172)
5
Host is up (0.000063s latency).
6
Not shown: 998 closed ports
7
PORT   STATE SERVICE VERSION
8
22/tcp open  ssh     OpenSSH 8.4p1 Debian 5+deb11u1 (protocol 2.0)
9
80/tcp open  http    Apache httpd 2.4.54 ((Debian))
10
|_http-server-header: Apache/2.4.54 (Debian)
11
|_http-title: Apache2 Debian Default Page: It works
12
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel
13

14
Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
15
Nmap done: 1 IP address (1 host up) scanned in 6.34 seconds
16

17
#Scan ipv6
18
wilder@host:~$ nmap -6 -A -T4 <ipv6 server>
19
Starting Nmap 7.80 ( https://nmap.org ) at 2023-01-13 15:21 CET
20
Nmap scan report for <ipv6 server>
21
Host is up (0.000073s latency).
22
Not shown: 998 closed ports
23
PORT   STATE SERVICE VERSION
24
22/tcp open  ssh     OpenSSH 8.4p1 Debian 5+deb11u1 (protocol 2.0)
25
80/tcp open  http    Apache httpd 2.4.54 ((Debian))
26
|_http-server-header: Apache/2.4.54 (Debian)
27
|_http-title: 400 Bad Request
28
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel
29

30
Host script results:
31
| address-info: 
32
|   IPv6 EUI-64: 
33
|     MAC address: 
34
|       address: 08:00:27:90:c1:04
35
|_      manuf: Oracle VirtualBox virtual NIC
36

37
Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
38
Nmap done: 1 IP address (1 host up) scanned in 6.35 seconds
39

40
```

## 📌 La configuration de netfilter avec nftables (rappel)

La commande `nft` permet une configuration dynamique de netfilter.  
Dans ce cas, les règles de filtrage sont changées à la volée mais ne sont pas conservées à l'extinction (et donc au redémarrage) de la machine.

À l'aide d'un script exécuté automatiquement au démarrage de la machine avec `nft -f`, par exemple au montage de la carte réseau dans `/etc/network/interfaces` il est possible d'appliquer des règles de filtrage définie dans un fichier à chaque démarrage.

Exemple de fichier `/etc/network/interfaces` indiquant de lancer le script **nftables** `/root/nftables/myrules.nft` à chaque démarrage.

```bash
1
# This file describes the network interfaces available on your system
2
# and how to activate them. For more information, see interfaces(5).
3

4
source /etc/network/interfaces.d/*
5

6
# The loopback network interface
7
auto lo
8
iface lo inet loopback
9

10
# The primary network interface
11
allow-hotplug enp0s3
12
iface enp0s3 inet dhcp
13
iface enp0s3 inet6 auto
14
    pre-up nft -f /root/nftables/myrules.nft
15
```
```shell
Wiki nftables
Plus d'information sur la syntaxe et les concepts de nftables dans le wiki officiel.https://wiki.nftables.org/wiki-nftables/index.php/Main_Page
```

---

## 🔬 Étude de configurations existantes

Une installation de nftables comporte habituellement un ensemble d'exemples de configuration dans le répertoire `/usr/share/doc/nftables/examples`.

Ouvre le fichier `workstation.nft`, qui constitue a priori un exemple de configuration de station de travail et répond aux questions du quizz.

```shell
#!/usr/sbin/nft -f

flush ruleset

table inet filter {
    chain input {
        type filter hook input priority 0;

        # accept any localhost traffic
        iif lo accept

        # accept traffic originated from us
        ct state established,related accept

        # activate the following line to accept common local services
        tcp dport { 22, 80, 443 } ct state new accept

        # ICMPv6 packets which must not be dropped, see https://tools.ietf.org/html/rfc4890#section-4.4.1
        meta nfproto ipv6 icmpv6 type { destination-unreachable, packet-too-big, time-exceeded, parameter-problem, echo-reply, echo-request, nd-router-solicit, nd-router-advert, nd-neighbor-solicit, nd-neighbor-advert, 148, 149 } accept
        ip6 saddr fe80::/10 icmpv6 type { 130, 131, 132, 143, 151, 152, 153 } accept

        # count and drop any other traffic
        counter drop
    }
}
```
```shell
# 1  - Que permet le shebang #!/usr/sbin/nft -f ?Il est indispensable pour pouvoir exécuter la commande nft -f workstation.nftC'est un commentaire, il est donc purement indicatifIl permet d'exécuter directement ce fichier comme un scriptValider# 2 À supprimer toute la configuration existante de NetfilterÀ indiquer que la suite contient un ensemble de règles completValider# 3 inputinetPlusieurs tables sont crééesfiltertableValider# 4 Plusieurs chaînes sont crééesinetchainfilterinputValider# 5 Que cette configuration s'applique bien à la chaîne inputQu'il s'agit d'ajouter des règles à la chaîneQue cette chaîne contient des règles à appliquer aux paquets entrants sur la machineValider# 6 sshsmtphttpsdnsftphttpValider# 7 Ce sont des règles de firewall de type "statefull"ConnTrack : ce sont des règles qui nécessite le suivi des connexionsDes paquets donc le champs count (ct) est dans l'état (state) indiquéCe sont des règles de firewall de type "stateless"Valider# 8 httpAucun, tout est bloquéftphttpssshTous, il n'y a pas de limitationsmtpdnsValider# 9 Non, le port 222 est bloqué dans tous les casOui, quelque soit l'origine de la connexionSeulement depuis la machine elle-même (localhost)Valider# 10 Non, ping est bloqué dans tous les casSeulement en IPv6Oui avec IPv4 et IPv6Seulement en IPv4ValiderTon score :0 / 10
```
```shell
Conseil : prends le temps, plus tard, d'étudier en détail l'ensemble de ces fichiers exemples de configuration, en essayant de bien comprendre la syntaxe à l'aide de la documentation et l'objectifs des règles proposées.
```

---

## ⚙️ Création d'une configuration

Il s'agit maintenant de créer une configuration pour notre serveur de test.

L'objectif de cette configuration est de n'autoriser que le trafic dont on a réellement besoin et donc d'interdire tous les autres.

Pour construire cette configuration, teste bien, étape par étape, chaque ajout de règles à l'aide des outils abordés en début d'atelier pour vérifier ce qui passe et ce qui est bloqué.

1. **Commence par bloquer tous les trafics en entrée et en sortie.**

À ce stade, la machine ne devrait plus pouvoir communiquer du tout.

1. **Autorise les communications locales**

Il est maintenant possible sur la machine de communiquer avec `localhost` / `ip6-localhost`

1. **Autorise maintenant icmp et icmpv6 en entrée comme en sortie**

Il redevient possible de joindre la machine avec ping.

Cette machine est un serveur qui n'a pas besoin d'initier elle-même des connexions, elle se contente de répondre aux demandes. Une exception néanmoins doit être faite pour le protocole DNS.  
Particularité des requêtes DNS, on peut savoir à l'avance avec quel·s serveur·s la machine doit pouvoir communiquer: les serveurs DNS récursifs de sa configuration.

1. **Autorise la machine à émettre des requêtes DNS, mais uniquement vers les serveurs récursifs présents sur ta configuration réseau et pense à autoriser les réponses correspondantes à entrer.**

Il est maintenant possible d'effectuer des requêtes DNS depuis le serveur.

1. **Autorise maintenant les connexions ssh entrantes (et les sorties correspondantes) uniquement depuis ton réseau interne.**

La connexion ssh sur la machine redevient accessible depuis la machine hôte.

```shell
Un autre test peut être nécessaire pour valider que le serveur ssh demeure inaccessible depuis une machine n'ayant pas une adresse IP correspondant aux plages locales.
```
1. **Autorise enfin les connexions http entrantes (et les réponses) depuis n'importe quelle adresse.**

L'accès au serveur web redevient possible.

1. **Assure toi que les règles sont bien correctement rechargées à chaque redémarrage de la machine.**

---

## 💪 Conclusion

Valide l'atelier si le script **nft** que tu as écris permet bien d'atteindre les objectifs décrits ci-dessus.

Quête terminée le **mercredi 11 février 2026**