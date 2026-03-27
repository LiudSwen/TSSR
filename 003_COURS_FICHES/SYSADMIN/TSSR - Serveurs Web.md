# ⚡ L'essentiel en 5 minutes - Serveurs Web & Proxy

## 📌 C'est quoi en 2 lignes ?

Le **Web** est un système de publication hypertexte basé sur HTTP/HTTPS, URLs et HTML, créé début 90's. Les **serveurs web** répondent aux requêtes HTTP des clients (navigateurs) en servant des fichiers ou générant du contenu dynamique. Les **proxys** sont des intermédiaires qui filtrent, cachent et sécurisent le trafic HTTP.

---

## 💡 Concepts clés à retenir :

- **HTTP** : Protocole client-serveur sans état (stateless) utilisant TCP port 80, messages texte structurés
- **HTTPS** : HTTP over TLS sur port 443, obligatoire pour tout serveur web (confidentialité + authentification)
- **Serveur web** : Logiciel en écoute sur ports 80/443 qui reçoit requêtes HTTP et renvoie réponses appropriées
- **Backend** : Programme générant réponses dynamiques (PHP, Node.js, Django, Spring) vs fichiers statiques
- **Proxy** : Passerelle applicative (couche 7) entre client et serveur offrant cache, filtrage, anonymat
- **Reverse proxy** : Frontal web qui répartit charge et gère connexions pour serveurs backend
- **Virtual Host** : Un serveur web héberge plusieurs sites via configurations différentes selon nom d'hôte

---

## 💻 Syntaxe essentielle :

### 🌐 Structure URL

```
schéma://autorité/chemin?requête#fragment

schéma = http/https
autorité = [user:pass@]domaine_ou_IP[:port]
chemin = /dossier/fichier
requête = clé=valeur&clé2=valeur2
fragment = #ancre
```

### 📨 Requête HTTP

```
MÉTHODE /chemin HTTP/1.1
Host: exemple.com
Cookie: session=abc123
[autres entêtes]

[corps optionnel]
```

### 📬 Réponse HTTP

```
HTTP/1.1 CODE Description
Content-Type: text/html
Content-Encoding: gzip
[autres entêtes]

[corps avec ressource]
```

### 🔒 Certificats HTTPS

```bash
# Let's Encrypt (AC publique gratuite)
# Certificat x.509 obligatoire
# Compléments sécurité : HSTS, HPKP, CSP
```

---

## 📐 Codes de statut HTTP :

|Code|Signification|
|---|---|
|**2xx**|Succès (200 OK, 201 Created)|
|**3xx**|Redirection (301 Moved, 302 Found)|
|**4xx**|Erreur client (404 Not Found, 403 Forbidden)|
|**5xx**|Erreur serveur (500 Internal, 503 Unavailable)|

---

## ⚠️ Pièges à éviter :

- ❌ **Pas de HTTPS** : Trafic en clair = données exposées, obligatoire aujourd'hui
- ❌ **Proxy HTTPS mal configuré** : Nécessite casser TLS = attaque MitM potentielle
- ❌ **HTTP/3** : Rare, basé sur QUIC pas TCP - ne pas compter dessus par défaut
- ❌ **Confondre proxy et reverse proxy** : L'un protège client (sortant), l'autre serveur (entrant)
- ❌ **Oublier Virtual Host** : Un serveur = plusieurs sites possibles selon entête Host

---

## ✅ Bonnes pratiques :

- ✅ **HTTPS partout** : AC publique type Let's Encrypt, certificat x.509 valide obligatoire
- ✅ **Reverse proxy en frontal** : Cache, répartition charge, terminaison TLS centralisée
- ✅ **Virtual Hosts par nom** : Héberger plusieurs domaines sur une IP via entête Host
- ✅ **Séparer statique/dynamique** : Serveur web pour fichiers, backend pour génération
- ✅ **Headers sécurité** : HSTS (force HTTPS), CSP (contrôle contenus), HPKP (épinglage clés)

---

## 📚 Vocabulaire technique :

|Terme|Définition courte|
|---|---|
|**Client HTTP**|Logiciel émettant requêtes (navigateur, curl, API)|
|**Backend**|Programme générant réponses dynamiques (PHP, Node.js, Django)|
|**Stateless**|HTTP ne garde pas d'état entre requêtes (cookies pour persistance)|
|**Virtual Host**|Configuration permettant plusieurs sites sur un serveur|
|**Reverse proxy**|Proxy côté serveur : cache, load balancing, sécurité|
|**TLS**|Transport Layer Security, chiffre HTTP en HTTPS|
|**MitM**|Man-in-the-Middle, attaque interceptant communications|
|**AC**|Autorité de Certification émettant certificats x.509|

---

## 🔧 Serveurs web courants :

**Serveurs HTTP classiques :**

- **Apache** : Le plus ancien, modules PHP, Virtual Hosts robustes
- **Nginx** : Performant, async, excellent en reverse proxy
- **Node.js** : Serveur JavaScript, backend + serveur intégré

**Reverse proxy spécialisés :**

- **Varnish** : Cache HTTP ultra-rapide
- **HAproxy** : Répartition charge TCP/HTTP avancée
- **Traefik** : Moderne, auto-configuration pour containers

**Backends frameworks :**

- **Django** (Python), **Spring/JEE** (Java), **PHP** (+ Apache/Nginx)

---

## 🎯 À retenir ABSOLUMENT :

1. 💡 **Théorique** : HTTP = sans état, messages texte (ligne démarrage + entêtes + corps), HTTPS obligatoire
2. 💻 **Pratique** : Port 80 (HTTP) / 443 (HTTPS), Virtual Host par nom d'hôte, reverse proxy en frontal
3. ⚠️ **Piège** : Proxy HTTPS = casser TLS = risque MitM, toujours vérifier certificats AC publiques valides