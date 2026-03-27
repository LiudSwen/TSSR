# ⚡ L'essentiel en 5 minutes - DNS (Domain Name System)

## 📌 C'est quoi en 2 lignes ?

Le DNS traduit les noms de domaine lisibles (wildcodeschool.com) en adresses IP utilisables par les machines. C'est une base de données répartie et hiérarchique, organisée en arborescence depuis une racine unique, gérée par des serveurs faisant autorité et des résolveurs récursifs.

---

## 💡 Concepts clés à retenir :

- **Nom de domaine (FQDN)** : Identifiant textuel hiérarchique (ex: [www.wildcodeschool.com](http://www.wildcodeschool.com).) composé de labels séparés par des points
- **TLD (Top Level Domain)** : Domaine de premier niveau (.com, .fr, .org) géré par des registres délégués par l'ICANN
- **Serveur faisant autorité** : Détient les enregistrements DNS officiels d'une zone (primaire + secondaires synchronisés)
- **Résolveur récursif** : Serveur interrogeant les autorités pour le client, avec système de cache (ex: FAI, 8.8.8.8)
- **Resource Record (RR)** : Enregistrement DNS avec un type (A, AAAA, CNAME, MX...) et un TTL (durée de validité)
- **Zone DNS** : Portion de l'arborescence gérée par un serveur faisant autorité
- **Stub resolver** : Client DNS minimal intégré à l'OS, consulte /etc/hosts puis interroge le résolveur configuré

---

## 💻 Commandes essentielles :


```bash
# 🐧 Linux - Interrogation DNS
dig domaine.com                    # Requête DNS complète (outil recommandé)
dig @8.8.8.8 domaine.com          # Interroger un serveur DNS spécifique
dig domaine.com A                  # Type d'enregistrement précis
dig -x 192.168.1.1                # Résolution inverse (PTR)
dig domaine.com +short            # Affichage condensé
dig domaine.com +trace            # Trace récursive depuis la racine

host domaine.com                  # Résolution simple
nslookup domaine.com              # Outil classique (moins complet que dig)
```



```powershell
# 🪟 Windows
nslookup domaine.com              # Requête DNS de base
nslookup domaine.com 8.8.8.8      # Serveur DNS spécifique
nslookup -type=MX domaine.com     # Type d'enregistrement
nslookup -type=PTR 1.1.168.192.in-addr.arpa  # Résolution inverse
```



```bash
# 🌐 Structure nom de domaine
odyssey.wildcodeschool.com.
    ↑       ↑            ↑   ↑
sous-dom  domaine      TLD racine

# Fichier hosts local (prioritaire sur DNS)
/etc/hosts (Linux)
C:\Windows\System32\drivers\etc\hosts (Windows)
```

---

## 📐 Résolution inverse :

* **IPv4** : Inverser l'adresse + ajouter .in-addr.arpa
* **IPv6** : Chaque chiffre hexa séparé + inverser + .ip6.arpa

**Exemple IPv4 :**
```
Adresse : 172.67.146.155
Inverse : 155.146.67.172.in-addr.arpa
```

**Exemple IPv6 :**
```
Adresse : 2607:4600:1c4c:0000:0000:0000:9294:b
Inverse : b.9.2.9.3.4.c.1.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.0.7.4.6.0.6.2.ip6.arpa
```

---

## ⚠️ Pièges à éviter :

- ❌ **Oublier le point final** : FQDN complet = odyssey.wildcodeschool.com. (avec le point, souvent omis mais techniquement requis)
- ❌ **Confondre résolveur et serveur faisant autorité** : Le résolveur est un relais avec cache, l'autorité détient la source de vérité
- ❌ **Négliger le TTL** : Une info en cache peut être obsolète pendant toute la durée du TTL (ex: changement d'IP non visible immédiatement)
- ❌ **Utiliser nslookup sur Linux** : dig est plus complet et standard sur Unix
- ❌ **Ignorer la résolution inverse** : Les PTR sont requis pour les serveurs mail (anti-spam) et certains services critiques

---

## ✅ Bonnes pratiques :

- ✅ **Plusieurs serveurs DNS** : Toujours 2+ serveurs (primaire + secondaires) pour redondance
- ✅ **TTL adapté** : Court (300s) pour changements fréquents, long (86400s) pour stabilité et performance
- ✅ **DNS over TLS (DoT)** : Port 853 pour chiffrer les requêtes DNS (confidentialité)
- ✅ **DNS round-robin** : Associer plusieurs IPs à un nom pour répartition de charge basique
- ✅ **Résolveurs publics de confiance** : Quad9 (9.9.9.9), Cloudflare (1.1.1.1), Google (8.8.8.8) ou FDN (80.67.169.12)

---

## 📚 Vocabulaire technique :

|Terme|Définition courte|
|---|---|
|**FQDN**|Fully Qualified Domain Name : nom complet avec point final (ex: [www.site.com](http://www.site.com).)|
|**Label**|Composant d'un nom de domaine (max 63 car., séparé par points)|
|**ccTLD**|Country Code TLD : domaine national (.fr, .de, .uk)|
|**gTLD**|Generic TLD : domaine générique (.com, .org, .net)|
|**Registre**|Organisme gérant un TLD (ex: AFNIC pour .fr)|
|**Bureau d'enregistrement**|Revendeur commercial de noms de domaine (ex: Gandi, OVH)|
|**Hébergeur DNS**|Service fournissant les serveurs faisant autorité pour votre zone|
|**NS Record**|Enregistrement indiquant les serveurs faisant autorité pour une zone|
|**A / AAAA**|Enregistrement IPv4 / IPv6 d'un nom de domaine|
|**CNAME**|Alias pointant vers un nom canonique (redirection DNS)|
|**MX**|Mail eXchanger : serveur mail du domaine (avec priorité)|
|**PTR**|Pointer : enregistrement de résolution inverse (IP → nom)|
|**SOA**|Start Of Authority : serveur primaire et paramètres de zone|
|**Anycast**|Technique réseau permettant une IP partagée par plusieurs serveurs géographiques|
|**ICANN/IANA**|Autorité mondiale gérant la racine DNS et l'attribution des TLD|

---

## 🎯 À retenir ABSOLUMENT :

1. 💡 **Hiérarchie DNS** : Racine (13 root-servers) → TLD (.com) → Domaine (wildcodeschool) → Sous-domaine (www) / Port 53 UDP/TCP
2. 💻 **Commande de diagnostic** : `dig @8.8.8.8 domaine.com +trace` pour analyser toute la chaîne de résolution
3. ⚠️ **Cache DNS = latence** : Un changement d'enregistrement met jusqu'à TTL secondes pour se propager (prévoir le délai !)