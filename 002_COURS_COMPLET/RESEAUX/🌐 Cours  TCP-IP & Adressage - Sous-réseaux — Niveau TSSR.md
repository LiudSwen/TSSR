# 🌐 Cours : TCP/IP & Adressage / Sous-réseaux — Niveau TSSR

> **Objectif** : Comprendre le modèle TCP/IP, maîtriser l'adressage IP, savoir calculer des sous-réseaux et diagnostiquer les problèmes associés.

---

## 1. Le modèle TCP/IP vs OSI

Le modèle TCP/IP est le modèle utilisé en pratique sur Internet. Il simplifie les 7 couches OSI en 4 couches.

|Couche TCP/IP|Équivalent OSI|Protocoles|
|---|---|---|
|Application|5, 6, 7|HTTP, HTTPS, DNS, FTP, SMTP, SSH|
|Transport|4|TCP, UDP|
|Internet|3|IP, ICMP, ARP|
|Accès réseau|1, 2|Ethernet, Wi-Fi, MAC|

> 💡 En pratique, quand on parle de "TCP/IP", on parle du duo **IP** (adressage, routage) + **TCP** (fiabilité, ports). Ce sont les deux piliers d'Internet.

---

## 2. IP, TCP et UDP — les différences fondamentales

### IP — Internet Protocol (couche Internet)

- Responsable de l'**adressage** et du **routage** des paquets
- Ne garantit **pas** la livraison (best effort)
- Chaque paquet voyage **indépendamment** (peut arriver dans le désordre)

### TCP — Transmission Control Protocol

- Connexion **fiable** : établit une connexion avant d'envoyer (handshake 3 voies)
- Garantit l'**ordre** des données et la **retransmission** si perte
- Plus lent mais sûr → utilisé par HTTP, HTTPS, SSH, FTP, SMTP

### UDP — User Datagram Protocol

- **Sans connexion** : envoie et oublie
- Pas de garantie de livraison ni d'ordre
- Plus rapide → utilisé par DNS, streaming vidéo, VoIP, jeux en ligne

### Le handshake TCP en 3 étapes

```
Client                    Serveur
  |  ── SYN ──────────→  |    "Je veux me connecter"
  |  ←──── SYN-ACK ───   |    "OK, je suis prêt"
  |  ── ACK ──────────→  |    "Parfait, on commence"
  |  ←── données ──────  |
```

> 💡 Si un port ne répond pas, c'est souvent parce que le SYN reste sans réponse → timeout.

---

## 3. Adressage IPv4 — Les bases

### Structure d'une adresse IP

Une adresse IPv4 = **32 bits** écrits en 4 octets décimaux séparés par des points.

```
192    .    168    .    1    .    50
11000000  10101000  00000001  00110010
```

### Les classes d'adresses (à connaître)

|Classe|Plage|Usage|
|---|---|---|
|A|1.0.0.0 – 126.255.255.255|Très grands réseaux|
|B|128.0.0.0 – 191.255.255.255|Réseaux moyens|
|C|192.0.0.0 – 223.255.255.255|Petits réseaux (le plus courant)|

### Adresses privées (RFC 1918) — à mémoriser

|Plage|Masque par défaut|Nb d'adresses|
|---|---|---|
|10.0.0.0 – 10.255.255.255|/8|~16 millions|
|172.16.0.0 – 172.31.255.255|/16|~1 million|
|192.168.0.0 – 192.168.255.255|/24|~65 000|

> ⚠️ Ces adresses ne sont **pas routables sur Internet**. Elles nécessitent du NAT pour sortir.

### Adresses spéciales

|Adresse|Signification|
|---|---|
|127.0.0.1|Loopback (le PC lui-même)|
|0.0.0.0|Réseau non spécifié / route par défaut|
|255.255.255.255|Broadcast général|
|x.x.x.0|Adresse du réseau|
|x.x.x.255|Adresse de broadcast du réseau|

---

## 4. Le masque de sous-réseau — comprendre la notation

### Notation décimale vs CIDR

|Notation décimale|Notation CIDR|Nb de bits réseau|
|---|---|---|
|255.0.0.0|/8|8|
|255.255.0.0|/16|16|
|255.255.255.0|/24|24|
|255.255.255.128|/25|25|
|255.255.255.192|/26|26|
|255.255.255.224|/27|27|
|255.255.255.240|/28|28|
|255.255.255.252|/30|30|

### Ce que signifie le masque

Le masque sépare l'adresse en deux parties :

- **Partie réseau** : identifie le réseau (bits à 1 dans le masque)
- **Partie hôte** : identifie la machine dans ce réseau (bits à 0 dans le masque)

```
IP      : 192.168.1.50   →  11000000.10101000.00000001.00110010
Masque  : 255.255.255.0  →  11111111.11111111.11111111.00000000
                                      ← réseau →     ← hôte →
```

---

## 5. Calcul de sous-réseaux — méthode pas à pas

### Les formules à retenir

```
Nombre d'hôtes utilisables  =  2ⁿ - 2   (n = bits hôte)
Nombre de sous-réseaux      =  2ᵐ        (m = bits empruntés)
```

On soustrait **2** car : adresse réseau + adresse broadcast = inutilisables.

### Tableau de référence rapide

|CIDR|Masque|Hôtes utilisables|Incrément|
|---|---|---|---|
|/24|255.255.255.0|254|256|
|/25|255.255.255.128|126|128|
|/26|255.255.255.192|62|64|
|/27|255.255.255.224|30|32|
|/28|255.255.255.240|14|16|
|/29|255.255.255.248|6|8|
|/30|255.255.255.252|2|4|

> 💡 **L'incrément** = la taille du bloc. Il te dit de combien en combien les sous-réseaux se suivent.

### Méthode de calcul : exemple complet

**Énoncé** : Calculer les informations du réseau `192.168.1.130/26`

**Étape 1 — Identifier le masque** /26 → 255.255.255.192 → incrément = **64**

**Étape 2 — Trouver le réseau** Diviser 130 par 64 → 130 / 64 = 2 (reste 2) → 2 × 64 = **128** → Adresse réseau : `192.168.1.128`

**Étape 3 — Trouver le broadcast** 128 + 64 - 1 = **191** → Adresse broadcast : `192.168.1.191`

**Étape 4 — Plage d'hôtes** → De `192.168.1.129` à `192.168.1.190` → **62 hôtes utilisables**

**Résumé** :

|Élément|Valeur|
|---|---|
|Adresse réseau|192.168.1.128|
|Masque|255.255.255.192 (/26)|
|Première IP utilisable|192.168.1.129|
|Dernière IP utilisable|192.168.1.190|
|Broadcast|192.168.1.191|
|Nb d'hôtes|62|

---

## 5bis. Calcul de sous-réseaux — Le 3ème octet (/17 à /23)

### Pourquoi c'est plus difficile ?

Avec les CIDR /24 à /30, le calcul se fait entièrement sur le **4ème octet** — simple. Avec les CIDR /17 à /23, la "coupure" tombe sur le **3ème octet** : la partie réseau empiète dessus, et le 4ème octet devient entièrement libre (0 à 255).

```
/26 → on travaille sur le 4ème octet :  192.168.1. [xxx]
/22 → on travaille sur le 3ème octet :  192.168. [xxx] .0  ← le 4ème est libre !
```

---

### Tableau de référence rapide — 3ème octet

|CIDR|Masque complet|Valeur du 3ème octet|Taille du bloc (incrément)|Hôtes utilisables|
|---|---|---|---|---|
|/17|255.255.**128**.0|128|128|32 766|
|/18|255.255.**192**.0|192|64|16 382|
|/19|255.255.**224**.0|224|32|8 190|
|/20|255.255.**240**.0|240|16|4 094|
|/21|255.255.**248**.0|248|8|2 046|
|/22|255.255.**252**.0|252|4|1 022|
|/23|255.255.**254**.0|254|2|510|
|/24|255.255.**255**.0|255|→ retour au 4ème octet|254|

> 💡 **Astuce** : la taille du bloc correspond toujours à la valeur du **dernier bit réseau** dans le 3ème octet. Pour /22 (252 = 11111100), le dernier bit réseau vaut 4 → bloc de 4.

---

### Méthode de calcul — même logique que le 4ème octet

**Règle :** on applique exactement la même méthode, mais sur le **3ème octet**.

```
Adresse réseau (3ème octet) = (3ème octet ÷ taille du bloc) × taille du bloc
Broadcast (3ème octet)      = adresse réseau + taille du bloc - 1
Le 4ème octet               = .0 pour le réseau, .255 pour le broadcast
```

---

### Exemples pas à pas

#### Exemple 1 — `172.16.37.200 /21`

```
/21 → taille du bloc = 8  (voir tableau)

3ème octet = 37
37 ÷ 8 = 4,625 → partie entière = 4
4 × 8 = 32

→ Adresse réseau     : 172.16.32.0
→ Broadcast          : 172.16.39.255   (32 + 8 - 1 = 39, 4ème octet = 255)
→ Plage d'hôtes      : 172.16.32.1 à 172.16.39.254
→ Hôtes utilisables  : 2 046
```

> 💡 Les réseaux /21 "sautent" de 8 en 8 sur le 3ème octet : `.0.x`, `.8.x`, `.16.x`, `.24.x`, `.32.x`, `.40.x`… → 37 est bien entre .32 et .40.

---

#### Exemple 2 — `10.0.100.15 /22`

```
/22 → taille du bloc = 4

3ème octet = 100
100 ÷ 4 = 25 → partie entière = 25
25 × 4 = 100

→ Adresse réseau     : 10.0.100.0
→ Broadcast          : 10.0.103.255   (100 + 4 - 1 = 103, 4ème octet = 255)
→ Plage d'hôtes      : 10.0.100.1 à 10.0.103.254
→ Hôtes utilisables  : 1 022
```

> ⚠️ En /22, le réseau couvre **4 valeurs du 3ème octet** : .100, .101, .102 et .103 — toutes les adresses de .100.0 à .103.255 appartiennent au même réseau.

---

#### Exemple 3 — `192.168.150.1 /19`

```
/19 → taille du bloc = 32

3ème octet = 150
150 ÷ 32 = 4,6875 → partie entière = 4
4 × 32 = 128

→ Adresse réseau     : 192.168.128.0
→ Broadcast          : 192.168.159.255   (128 + 32 - 1 = 159)
→ Plage d'hôtes      : 192.168.128.1 à 192.168.159.254
→ Hôtes utilisables  : 8 190
```

---

### Récapitulatif des pièges courants

|Piège|Ce qu'il faut faire|
|---|---|
|Oublier que le 4ème octet est entièrement libre|En /22, `.100.0 /22` couvre `.100.x`, `.101.x`, `.102.x` **et** `.103.x` — le broadcast finit en **.255**|
|Croire que le broadcast finit en .0|Non — le broadcast d'un réseau /3ème octet finit **toujours en .255**|
|Appliquer l'incrément au 4ème octet|En /21, l'incrément de 8 s'applique au **3ème** octet, pas au 4ème|
|Confondre /23 et /24|En /23 le bloc est de **2** sur le 3ème octet : `.150.x` et `.151.x` font partie du même réseau si le réseau commence en `.150.0`|

---

Le VLSM permet de **découper un réseau en sous-réseaux de tailles différentes** selon les besoins réels. C'est ce qu'on utilise en entreprise pour éviter de gaspiller des adresses.

### Principe

Au lieu de couper un /24 en parts égales, on adapte la taille à chaque besoin :

- Un réseau de 100 PC → /25 (126 hôtes)
- Un réseau de 20 PC → /27 (30 hôtes)
- Une liaison point-à-point entre deux routeurs → /30 (2 hôtes)

### Méthode VLSM — toujours commencer par le plus grand besoin

**Énoncé** : Découper `192.168.10.0/24` pour :

- Site A : 100 hôtes
- Site B : 50 hôtes
- Site C : 20 hôtes
- Lien routeur A↔B : 2 hôtes

**Étape 1 — Classer par taille décroissante** 100 → 50 → 20 → 2

**Étape 2 — Attribuer les blocs**

|Site|Besoin|CIDR choisi|Hôtes dispo|Plage|
|---|---|---|---|---|
|A|100|/25|126|192.168.10.0 – 192.168.10.127|
|B|50|/26|62|192.168.10.128 – 192.168.10.191|
|C|20|/27|30|192.168.10.192 – 192.168.10.223|
|Lien|2|/30|2|192.168.10.224 – 192.168.10.227|

> 💡 Chaque bloc commence juste après le broadcast du précédent. Pas d'adresses gaspillées.

---

## 7. Scénarios de dépannage TCP/IP

---

### 🔴 Scénario 1 — Un PC ne communique pas avec les autres

**Situation** :

- PC avec IP `192.168.1.50` et masque `255.255.255.0`
- Passerelle configurée : `192.168.1.1`
- Ne peut pinger aucun autre PC du réseau (`192.168.1.x`)
- Les autres PC communiquent entre eux normalement

**Questions à se poser** :

1. Le PC est-il bien dans le même sous-réseau que les autres ?
2. Le masque est-il identique à celui des autres machines ?
3. Y a-t-il un conflit d'adresse IP ?
4. Le câble et la carte réseau fonctionnent-ils ? (LED allumée ?)

**Analyse** :

|Vérification|Résultat possible|
|---|---|
|IP dans le bon réseau|Si IP = 192.168.2.50 par erreur → hors réseau|
|Masque incorrect|/25 au lieu de /24 → plage réduite de moitié|
|Conflit IP|Une autre machine a le même 192.168.1.50|

**Marche à suivre** :

1. `ipconfig` (Windows) ou `ip a` (Linux) → vérifier IP et masque
2. `ping 192.168.1.1` (passerelle) → si KO, problème couche 3 ou en dessous
3. `arp -a` → chercher un doublon d'adresse IP
4. Vérifier que l'IP est dans la bonne plage selon le masque

**Commandes utiles** :

```bash
ip a                          # Voir IP et masque (Linux)
ipconfig /all                 # Voir IP, masque, passerelle (Windows)
ping 192.168.1.1              # Tester la passerelle
arp -a                        # Chercher les conflits
```

> 💡 **Erreur classique** : masque en /25 au lieu de /24. Le PC pense être dans un réseau plus petit et ne voit pas les machines de l'autre moitié.

---

### 🔴 Scénario 2 — Deux PC ne peuvent pas communiquer malgré le même réseau

**Situation** :

- PC-A : `192.168.1.10 /24`
- PC-B : `192.168.1.200 /25`
- Même switch, mêmes VLAN, même câblage
- PC-A → PC-B : ❌
- PC-B → PC-A : ❌

**Questions à se poser** :

1. Les deux masques sont-ils identiques ?
2. PC-B avec /25 — est-ce que 192.168.1.10 est dans sa plage réseau ?
3. Qui a tort — PC-A ou PC-B ?

**Analyse** :

PC-B avec `/25` voit le réseau `192.168.1.128/25` (plage : .128 à .255). PC-A est en `.10` → **hors de la plage de PC-B**. PC-A avec `/24` voit tout le `192.168.1.0/24` mais PC-B lui répond avec une mauvaise route.

→ **Masque incohérent entre les deux PC** : ils ne pensent pas être dans le même réseau.

**Couche suspectée** : **Couche 3 — mauvaise configuration du masque**

**Marche à suivre** :

1. Corriger le masque de PC-B : mettre `/24` (255.255.255.0)
2. Vérifier que tous les équipements du réseau ont le **même masque**
3. Re-tester le ping

> ⚠️ Un masque différent entre deux machines sur le même réseau = l'une des deux ne "voit" pas l'autre, même si elles sont physiquement sur le même switch.

---

### 🔴 Scénario 3 — Un PC obtient une adresse en 169.254.x.x

**Situation** :

- Un PC allume et obtient l'adresse `169.254.45.12`
- Impossible de se connecter au réseau
- Les autres PC fonctionnent normalement

**Questions à se poser** :

1. Le serveur DHCP est-il accessible ?
2. Y a-t-il un serveur DHCP sur le réseau ?
3. Le câble et le port switch sont-ils OK ?
4. Le service DHCP client est-il démarré sur le PC ?

**Analyse** :

`169.254.x.x` = **APIPA (Automatic Private IP Addressing)** — adresse que Windows s'attribue automatiquement quand il **ne reçoit pas de réponse DHCP**.

|Couche|État|Pourquoi|
|---|---|---|
|1-2|Peut-être ❌|Si câble KO → pas de DHCP possible|
|3 (DHCP)|❌|Pas de réponse DHCP reçue|

**Couche suspectée** : **Couche 3 — DHCP injoignable**

**Marche à suivre** :

1. Vérifier le câble et la LED (couche 1)
2. Vérifier que le service DHCP tourne sur le serveur
3. Vérifier qu'il n'y a pas de VLAN qui isole le PC du serveur DHCP
4. Tester avec une IP statique temporaire pour confirmer que le réseau fonctionne
5. `ipconfig /release` puis `ipconfig /renew` pour forcer une nouvelle demande DHCP

**Commandes utiles** :

```bash
ipconfig /release             # Libérer l'IP actuelle
ipconfig /renew               # Demander une nouvelle IP au DHCP
ipconfig /all                 # Voir si l'IP vient du DHCP
```

> 💡 **169.254.x.x = signal d'alarme**. Ça veut toujours dire que le PC n'a pas eu de réponse DHCP. C'est ton premier indice.

---

### 🔴 Scénario 4 — Le ping fonctionne par IP mais pas par nom

**Situation** :

- `ping 8.8.8.8` → ✅
- `ping google.com` → ❌ "Impossible de trouver l'hôte"
- Tous les autres PC du réseau accèdent à Internet normalement

**Questions à se poser** :

1. Quelle est l'adresse du serveur DNS configurée sur ce PC ?
2. Le serveur DNS est-il joignable (ping) ?
3. Le serveur DNS répond-il aux requêtes ?
4. Le pare-feu bloque-t-il le port 53 (DNS) ?

**Analyse** :

|Couche|État|Pourquoi|
|---|---|---|
|1 à 4|✅|Ping IP externe OK|
|7 (DNS)|❌|Résolution de nom impossible|

**Couche suspectée** : **Couche 7 — DNS mal configuré ou en panne**

**Marche à suivre** :

1. `ipconfig /all` → vérifier l'adresse du serveur DNS configuré
2. `ping <ip-du-dns>` → le DNS est-il joignable ?
3. `nslookup google.com` → tester la résolution manuellement
4. Si DNS configuré incorrectement → corriger (8.8.8.8 ou DNS interne)

**Commandes utiles** :

```bash
ipconfig /all                          # Voir le DNS configuré
nslookup google.com                    # Tester la résolution DNS
nslookup google.com 8.8.8.8            # Forcer le test sur un DNS précis
ping <ip-serveur-dns>                  # Vérifier que le DNS répond
```

---

### 🔴 Scénario 5 — Calcul de sous-réseau en situation réelle

**Situation** :

- Tu dois connecter un nouveau serveur sur le réseau `10.10.5.0/27`
- Tu dois vérifier que l'IP proposée `10.10.5.45` est utilisable

**Questions à se poser** :

1. Quelle est la plage d'hôtes de ce réseau ?
2. L'IP .45 est-elle dans cette plage ?
3. Est-ce l'adresse réseau ou broadcast ?

**Analyse** :

/27 → masque `255.255.255.224` → incrément = **32**

Blocs disponibles : .0, .32, .64, .96… → Le bloc qui contient .45 commence à **.32** → Broadcast : 32 + 32 - 1 = **.63**

|Élément|Valeur|
|---|---|
|Adresse réseau|10.10.5.32|
|Broadcast|10.10.5.63|
|Plage utilisable|10.10.5.33 → 10.10.5.62|
|IP .45 utilisable ?|✅ OUI|

**Réponse** : `10.10.5.45` est bien dans la plage → elle peut être attribuée au serveur.

---

### 🔴 Scénario 6 — Connexion TCP qui échoue mystérieusement

**Situation** :

- Un développeur teste son application : le client se connecte au serveur sur le port 5000
- La connexion échoue avec "Connection refused"
- Ping vers le serveur ✅
- Le serveur est censé écouter sur le port 5000

**Questions à se poser** :

1. Est-ce que le service écoute vraiment sur le port 5000 ?
2. Sur quelle interface écoute-t-il ? (localhost 127.0.0.1 ou 0.0.0.0 ?)
3. Un firewall bloque-t-il le port ?
4. La connexion TCP (SYN) aboutit-elle ?

**Analyse** :

"Connection refused" signifie que le port **répond** mais **refuse** la connexion → le TCP SYN arrive mais reçoit un RST (reset). Ce n'est **pas** un timeout (port filtré), c'est un refus actif.

|Cause|Explication|
|---|---|
|Service non démarré|Rien n'écoute sur le port → OS envoie RST|
|Service en écoute sur 127.0.0.1|N'accepte que les connexions locales|
|Firewall local|Bloque et RST la connexion|

**Marche à suivre** :

1. Sur le serveur : `ss -tuln | grep 5000` → le service écoute-t-il ?
2. Vérifier l'adresse d'écoute : `0.0.0.0:5000` (toutes interfaces) ou `127.0.0.1:5000` (local seulement)
3. Si local seulement → modifier la config de l'application pour écouter sur `0.0.0.0`
4. Vérifier le firewall : `iptables -L` ou `ufw status`

**Commandes utiles** :

```bash
ss -tuln | grep 5000           # Voir si le port écoute et sur quelle interface
telnet <IP-serveur> 5000       # Tester la connexion TCP
iptables -L -n | grep 5000     # Vérifier les règles firewall
```

> 💡 **Distinction importante** :
> 
> - "Connection refused" → le port est joignable mais rien n'écoute (ou firewall RST)
> - "Request timeout" → le port est filtré, les paquets sont bloqués silencieusement

---

## 8. Exercices d'entraînement

> Essaie de répondre sans regarder, puis vérifie.

---

**Exercice 1** — Pour le réseau `192.168.5.68/26`, trouve :

- L'adresse réseau
- L'adresse broadcast
- La plage d'hôtes
- Le nombre d'hôtes utilisables

<details> <summary>👁️ Voir la réponse</summary>

/26 → masque 255.255.255.192 → incrément = 64 68 / 64 = 1 (reste 4) → bloc commence à **64** Broadcast : 64 + 64 - 1 = **127**

|Élément|Valeur|
|---|---|
|Réseau|192.168.5.64|
|Broadcast|192.168.5.127|
|Plage|192.168.5.65 → 192.168.5.126|
|Nb hôtes|62|

</details>

---

**Exercice 2** — Un PC a l'IP `172.16.4.130/25`. Peut-il communiquer directement avec `172.16.4.5` ?

<details> <summary>👁️ Voir la réponse</summary>

/25 → incrément = 128

- Réseau de 172.16.4.130 : bloc à **128** → plage .128 à .255
- 172.16.4.5 est dans le bloc **0** → plage .0 à .127

Les deux machines sont dans des sous-réseaux différents → **NON**, elles ne peuvent pas communiquer directement, il faut un routeur.

</details>

---

**Exercice 3** — Tu dois créer 6 sous-réseaux à partir de `10.0.0.0/24`. Quel est le CIDR minimum pour avoir au moins 6 sous-réseaux avec le maximum d'hôtes par réseau ?

<details> <summary>👁️ Voir la réponse</summary>

Pour 6 sous-réseaux → 2³ = 8 ≥ 6 → il faut **3 bits** empruntés /24 + 3 bits = **/27**

- 8 sous-réseaux possibles
- 30 hôtes par sous-réseau
- Sous-réseaux : 10.0.0.0/27, 10.0.0.32/27, 10.0.0.64/27…

</details>

---

## 9. Aide-mémoire rapide

```
NOTATION CIDR    MASQUE               HÔTES      INCRÉMENT (3ème octet)
/17          →   255.255.128.0    →   32 766  →   128
/18          →   255.255.192.0    →   16 382  →    64
/19          →   255.255.224.0    →    8 190  →    32
/20          →   255.255.240.0    →    4 094  →    16
/21          →   255.255.248.0    →    2 046  →     8
/22          →   255.255.252.0    →    1 022  →     4
/23          →   255.255.254.0    →      510  →     2

NOTATION CIDR    MASQUE               HÔTES    INCRÉMENT (4ème octet)
/24          →   255.255.255.0    →   254   →   256
/25          →   255.255.255.128  →   126   →   128
/26          →   255.255.255.192  →    62   →    64
/27          →   255.255.255.224  →    30   →    32
/28          →   255.255.255.240  →    14   →    16
/29          →   255.255.255.248  →     6   →     8
/30          →   255.255.255.252  →     2   →     4

ADRESSE SPÉCIALE          SIGNIFICATION
169.254.x.x          →   DHCP non reçu (APIPA)
127.0.0.1            →   Loopback (le PC lui-même)
x.x.x.0              →   Adresse réseau (non utilisable)
x.x.x.255 (en /24)   →   Broadcast (non utilisable)

SYMPTÔME                         CAUSE PROBABLE
169.254.x.x                →    DHCP inaccessible
Ping IP OK, nom KO         →    DNS mal configuré
Masques différents         →    Deux PC pensent être hors réseau
"Connection refused"       →    Service arrêté ou écoute en local only
"Request timeout"          →    Port filtré par firewall
```

---

> ✅ **À retenir** : Maîtriser TCP/IP c'est avant tout comprendre **comment les adresses délimitent les réseaux**. Un masque erroné ou une IP mal placée et deux machines ne se voient plus — même branchées sur le même switch. Calcule toujours ta plage avant de configurer une IP.