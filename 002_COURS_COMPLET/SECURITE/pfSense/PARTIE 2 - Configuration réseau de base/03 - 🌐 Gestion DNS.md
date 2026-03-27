

## 📋 Table des matières

```table-of-contents
title: 
style: nestedList # TOC style (nestedList|nestedOrderedList|inlineFirstLevel)
minLevel: 2 # Include headings from the specified level
maxLevel: 2 # Include headings up to the specified level
include: 
exclude: 
includeLinks: true # Make headings clickable
hideWhenEmpty: false # Hide TOC if no headings are found
debugInConsole: false # Print debug info in Obsidian console
```

---

## Introduction

Le DNS (Domain Name System) est un service essentiel dans tout réseau. Il traduit les noms de domaine en adresses IP, permettant aux utilisateurs d'accéder aux ressources réseau avec des noms mémorisables plutôt que des adresses IP.

pfSense offre deux services DNS principaux :

- **DNS Resolver (Unbound)** - Résolveur DNS récursif
- **DNS Forwarder (Dnsmasq)** - Serveur de transfert DNS

> [!info] Pourquoi la gestion DNS est cruciale
> 
> - Résolution de noms pour tous les clients du réseau
> - Contrôle et filtrage du trafic DNS
> - Résolution de noms locaux personnalisés
> - Performance et cache des requêtes DNS
> - Sécurité (DNSSEC, blocage de domaines malveillants)

---

## DNS Resolver vs DNS Forwarder

pfSense propose deux services DNS distincts qui ne peuvent pas fonctionner simultanément sur les mêmes interfaces.

### 🔍 Comparaison détaillée

|Caractéristique|DNS Resolver (Unbound)|DNS Forwarder (Dnsmasq)|
|---|---|---|
|**Type**|Résolveur récursif|Serveur de transfert|
|**Fonctionnement**|Interroge directement les serveurs racine|Transfère les requêtes à des DNS externes|
|**Performance**|Meilleure après mise en cache|Dépend des DNS externes|
|**DNSSEC**|Support natif complet|Support limité|
|**Recommandation**|✅ **Recommandé** (défaut)|Cas spécifiques uniquement|
|**Complexité**|Plus de fonctionnalités|Plus simple|

### DNS Resolver (Unbound) - Résolveur récursif

> [!example] Comment fonctionne le DNS Resolver
> 
> 1. Client demande `www.example.com`
> 2. Unbound vérifie son cache
> 3. Si absent, interroge les **serveurs racine** (`.`)
> 4. Puis interroge les serveurs TLD (`.com`)
> 5. Puis interroge les serveurs autoritaires (`example.com`)
> 6. Retourne la réponse au client et la met en cache

**Avantages :**

- Indépendance vis-à-vis des DNS externes
- Meilleure confidentialité (pas de tiers)
- Support DNSSEC complet
- Cache performant
- Contrôle total sur la résolution

**Inconvénients :**

- Requêtes initiales légèrement plus lentes
- Consommation mémoire plus élevée

### DNS Forwarder (Dnsmasq) - Serveur de transfert

> [!example] Comment fonctionne le DNS Forwarder
> 
> 1. Client demande `www.example.com`
> 2. Dnsmasq vérifie son cache
> 3. Si absent, transfère la requête à un **serveur DNS externe** (ex: 8.8.8.8)
> 4. Le serveur externe résout et répond
> 5. Dnsmasq retourne la réponse et la met en cache

**Avantages :**

- Configuration simple
- Léger en ressources
- Rapidité pour les requêtes initiales

**Inconvénients :**

- Dépendance aux DNS externes
- Moins de confidentialité
- Support DNSSEC limité

### 🎯 Quand utiliser quel service ?

> [!tip] Recommandations **Utilisez DNS Resolver (Unbound) si :**
> 
> - Vous voulez un contrôle total et la confidentialité (cas général)
> - Vous avez besoin de DNSSEC
> - Vous gérez un réseau d'entreprise
> - **C'est le choix par défaut recommandé**
> 
> **Utilisez DNS Forwarder (Dnsmasq) si :**
> 
> - Vous avez des contraintes de ressources très limitées
> - Vous devez absolument utiliser des DNS externes spécifiques
> - Compatibilité avec des configurations héritées

---

## Configuration du DNS Resolver (Unbound)

Le DNS Resolver est accessible via **Services > DNS Resolver**.

### Activation et configuration de base

> [!info] Accès à la configuration Navigation : **Services > DNS Resolver**

#### Options essentielles

**Enable DNS Resolver**

- ✅ Active le service DNS Resolver
- Doit être coché pour que le service fonctionne

**Listen Port**

- Port d'écoute du service (défaut : `53`)
- Ne modifier que si nécessaire (conflit de port)

**Network Interfaces**

- Interfaces sur lesquelles Unbound écoute
- **Recommandé :** Sélectionner uniquement les interfaces LAN/internes
- Ne PAS sélectionner WAN pour des raisons de sécurité

```
Exemple :
☑ LAN
☑ DMZ
☐ WAN (ne jamais cocher)
```

**Outgoing Network Interfaces**

- Interfaces utilisées pour les requêtes sortantes
- **Recommandé :** Laisser sur "All" ou sélectionner WAN
- Permet à Unbound d'effectuer ses requêtes récursives

**DNSSEC**

- ✅ **Fortement recommandé** : Activer
- Valide l'authenticité des réponses DNS
- Protège contre les attaques de type DNS spoofing

**DNS Query Forwarding**

- ⚠️ Si activé, Unbound devient un forwarder (perd son mode récursif)
- **Recommandé :** Laisser désactivé sauf besoin spécifique
- Si activé, nécessite de spécifier des serveurs DNS externes

**DHCP Registration**

- Enregistre automatiquement les clients DHCP dans le DNS
- Les clients deviennent accessibles par leur hostname
- **Recommandé :** ✅ Activer pour les réseaux internes

**Static DHCP**

- Enregistre les baux DHCP statiques dans le DNS
- **Recommandé :** ✅ Activer si vous utilisez des réservations DHCP

### Configuration avancée

#### Performance et cache

> [!tip] Optimisation du cache **Advanced Settings > Advanced Privacy** (en bas de page)

**Number of Hosts to Cache**

- Nombre d'entrées DNS en cache
- Défaut : adapté à la plupart des cas
- Augmenter pour de grands réseaux (valeurs courantes : 10000-50000)

**Number of Queries per Thread**

- Nombre de requêtes simultanées par thread
- Défaut : 4096
- Augmenter si forte charge DNS

**Jostle Timeout**

- Temps avant qu'une requête lente soit abandonnée
- Défaut : 200ms
- Peut être réduit pour améliorer la réactivité

**Cache Max TTL** / **Cache Min TTL**

- Durée de conservation des entrées en cache
- Max TTL : temps maximum (défaut 86400s = 24h)
- Min TTL : temps minimum (défaut 0s)

```
Recommandation pour réseaux typiques :
- Cache Max TTL : 86400 (1 jour)
- Cache Min TTL : 300 (5 minutes)
```

#### Sécurité

**Hide Identity** / **Hide Version**

- ✅ Masque les informations de version d'Unbound
- **Recommandé :** Activer pour la sécurité

**Query Name Minimization**

- Réduit les informations envoyées lors des requêtes récursives
- **Recommandé :** ✅ Activer pour plus de confidentialité

**Strict Query Name Minimization**

- Version encore plus stricte
- Peut casser certains domaines mal configurés
- Tester avant activation en production

#### Gestion des domaines locaux

**Custom options**

- Permet d'ajouter des configurations Unbound personnalisées
- Format : directives Unbound natives

> [!example] Exemple de configuration personnalisée
> 
> ```bash
> # Définir un domaine local
> server:
>     local-zone: "lab.local." static
>     local-data: "server1.lab.local. IN A 192.168.1.100"
>     local-data: "server2.lab.local. IN A 192.168.1.101"
> 
> # Bloquer un domaine
> server:
>     local-zone: "malware.example.com" redirect
>     local-data: "malware.example.com A 0.0.0.0"
> ```

---

## Serveurs DNS externes

Même en mode DNS Resolver récursif, il peut être utile de configurer des serveurs DNS externes pour certains usages.

### Configuration des serveurs DNS

> [!info] Accès à la configuration Navigation : **System > General Setup > DNS Server Settings**

#### Ajout de serveurs DNS

**DNS Servers**

- Liste des serveurs DNS utilisés par pfSense lui-même
- Utilisés si DNS Query Forwarding est activé dans Unbound
- Également utilisés comme fallback dans certains cas

```
Serveurs DNS recommandés :

Cloudflare (privé, rapide) :
- 1.1.1.1
- 1.0.0.1

Google (fiable, rapide) :
- 8.8.8.8
- 8.8.4.4

Quad9 (sécurisé, bloque malwares) :
- 9.9.9.9
- 149.112.112.112

OpenDNS (avec filtrage) :
- 208.67.222.222
- 208.67.220.220
```

**DNS Server Override**

- ⚠️ Empêche le WAN de remplacer les DNS configurés
- ✅ **Recommandé :** Activer pour garder le contrôle
- Évite que votre FAI impose ses DNS

**Disable DNS Forwarder**

- À activer si vous utilisez DNS Resolver
- Ne peut être actif en même temps que DNS Forwarder

### Configuration dans Unbound pour le forwarding

Si vous souhaitez qu'Unbound transfère certaines requêtes :

> [!info] Accès **Services > DNS Resolver > General Settings**

**Enable Forwarding Mode**

- Active le mode transfert
- ⚠️ Désactive la résolution récursive complète

**Use SSL/TLS for Outgoing Queries (DNS over TLS)**

- Chiffre les requêtes DNS sortantes
- **Recommandé :** ✅ Activer pour la confidentialité
- Nécessite des serveurs DNS supportant DoT

> [!example] Exemple de configuration DNS over TLS
> 
> ```
> DNS Servers avec DoT :
> 
> Cloudflare :
> - 1.1.1.1@853#cloudflare-dns.com
> - 1.0.0.1@853#cloudflare-dns.com
> 
> Quad9 :
> - 9.9.9.9@853#dns.quad9.net
> - 149.112.112.112@853#dns.quad9.net
> ```

---

## Surcharges d'hôtes (Host Overrides)

Les Host Overrides permettent de définir des résolutions DNS personnalisées pour des noms spécifiques.

### Qu'est-ce qu'un Host Override ?

> [!info] Définition Un Host Override force la résolution d'un nom de domaine vers une adresse IP spécifique, indépendamment du DNS public.

**Cas d'usage :**

- Résolution de noms pour des serveurs internes
- Redirection de domaines publics vers des serveurs locaux
- Tests et développement
- Split DNS (réponses différentes interne/externe)

### Configuration des Host Overrides

> [!info] Accès à la configuration Navigation : **Services > DNS Resolver > Host Overrides**

#### Ajouter un Host Override

**Host**

- Nom d'hôte (sans le domaine)
- Exemple : `webserver`, `nas`, `pfsense`

**Domain**

- Domaine
- Exemple : `lab.local`, `internal.company.com`

**IP Address**

- Adresse IP de destination
- Exemple : `192.168.1.50`

**Description**

- Description optionnelle
- **Recommandé :** Toujours documenter l'usage

> [!example] Exemple : Serveur web interne
> 
> ```
> Host        : webserver
> Domain      : lab.local
> IP Address  : 192.168.1.100
> Description : Serveur web Apache de test
> 
> Résultat : webserver.lab.local → 192.168.1.100
> ```

> [!example] Exemple : Split DNS pour site public
> 
> ```
> Host        : www
> Domain      : company.com
> IP Address  : 192.168.1.50
> Description : Version interne du site web
> 
> Résultat (interne) : www.company.com → 192.168.1.50
> Résultat (externe) : www.company.com → IP publique
> ```

#### Alias supplémentaires

Chaque Host Override peut avoir plusieurs alias (CNAME).

**Add a new Alias for this host**

- Permet d'ajouter des noms alternatifs pointant vers le même hôte

> [!example] Exemple avec alias
> 
> ```
> Host Override principal :
> Host        : fileserver
> Domain      : lab.local
> IP          : 192.168.1.150
> 
> Alias :
> Host        : nas
> Domain      : lab.local
> 
> Host        : storage
> Domain      : lab.local
> 
> Résultat :
> fileserver.lab.local → 192.168.1.150
> nas.lab.local        → 192.168.1.150
> storage.lab.local    → 192.168.1.150
> ```

### Domain Overrides

Les Domain Overrides redirigent toutes les requêtes pour un domaine entier vers un serveur DNS spécifique.

> [!info] Accès **Services > DNS Resolver > Domain Overrides**

**Domain**

- Domaine à rediriger
- Exemple : `ad.company.local`, `internal.domain.com`

**IP Address**

- Adresse du serveur DNS qui gère ce domaine
- Exemple : Contrôleur de domaine Active Directory

**Description**

- Documentation de l'override

> [!example] Exemple : Intégration Active Directory
> 
> ```
> Domain      : ad.company.local
> IP Address  : 192.168.1.10
> Description : Contrôleur de domaine AD principal
> 
> Résultat : Toutes les requêtes pour *.ad.company.local sont
>           envoyées au serveur 192.168.1.10
> ```

> [!warning] Attention aux boucles DNS Ne créez jamais de Domain Override pointant vers pfSense lui-même, cela créerait une boucle infinie de résolution DNS.

---

## Bonnes pratiques

### 🎯 Configuration recommandée standard

```
Pour un réseau typique PME/domicile :

DNS Resolver (Unbound) :
✅ Enable DNS Resolver
✅ Network Interfaces : LAN uniquement
✅ DNSSEC : Activé
✅ DHCP Registration : Activé
✅ Static DHCP : Activé
❌ DNS Query Forwarding : Désactivé
✅ Query Name Minimization : Activé

Serveurs DNS (System > General) :
✅ DNS Server Override : Activé
DNS primaire : 1.1.1.1 (Cloudflare)
DNS secondaire : 9.9.9.9 (Quad9)
```

### 🔒 Sécurité

> [!warning] Règles de sécurité DNS
> 
> - **Ne JAMAIS** exposer le DNS Resolver sur l'interface WAN
> - Toujours activer DNSSEC
> - Utiliser DNS over TLS si possible
> - Masquer Identity et Version d'Unbound
> - Surveiller les logs DNS pour détecter les anomalies

### ⚡ Performance

> [!tip] Optimisation des performances
> 
> - Augmenter le cache pour les réseaux avec beaucoup de clients
> - Activer DHCP Registration pour éviter les requêtes externes inutiles
> - Utiliser Host Overrides pour les serveurs fréquemment accédés
> - Monitorer l'utilisation mémoire d'Unbound
> - Préférer le mode récursif pur (sans forwarding) pour de meilleures performances long terme

### 📝 Documentation et maintenance

> [!tip] Bonnes pratiques organisationnelles
> 
> - **Toujours** documenter les Host Overrides (champ Description)
> - Maintenir une liste externe des DNS configurés
> - Tester les changements DNS avant déploiement
> - Vérifier régulièrement les logs (`Status > System Logs > Resolver`)
> - Faire des sauvegardes avant modifications importantes

### 🧪 Tests et validation

**Tester la résolution DNS depuis un client :**

```bash
# Test de résolution basique
nslookup www.example.com

# Test avec serveur DNS spécifique
nslookup www.example.com 192.168.1.1

# Test détaillé avec dig (Linux/Mac)
dig @192.168.1.1 www.example.com

# Vérifier DNSSEC
dig @192.168.1.1 +dnssec www.cloudflare.com

# Test de host override
nslookup webserver.lab.local
```

**Vérifier les logs DNS Resolver :**

- Navigation : **Status > System Logs > Resolver**
- Rechercher les erreurs ou comportements anormaux
- Identifier les domaines fréquemment demandés

### ⚠️ Pièges courants

> [!warning] Erreurs fréquentes à éviter
> 
> **DNS Resolver et DNS Forwarder activés simultanément**
> 
> - Ne peuvent fonctionner ensemble
> - Choisir un seul service
> 
> **Oublier DNS Server Override**
> 
> - Le FAI peut imposer ses DNS
> - Toujours activer cette option
> 
> **Host Overrides sans domaine complet**
> 
> - Toujours spécifier Host ET Domain
> - `webserver` seul ne fonctionne pas, il faut `webserver.lab.local`
> 
> **Boucles DNS avec Domain Overrides**
> 
> - Ne jamais pointer vers pfSense lui-même
> - Vérifier la configuration avant application
> 
> **Cache DNS obsolète après modifications**
> 
> - Redémarrer Unbound après changements : **Services > DNS Resolver > Apply Changes**
> - Ou vider le cache client (ipconfig /flushdns sur Windows)

### 🔄 Maintenance régulière

```
Tâches de maintenance DNS :

Hebdomadaire :
- Vérifier les logs DNS pour anomalies
- Surveiller les performances (temps de réponse)

Mensuel :
- Nettoyer les Host Overrides obsolètes
- Vérifier que DNSSEC fonctionne correctement
- Revoir les statistiques d'utilisation

Annuel :
- Audit complet de la configuration DNS
- Mise à jour de la documentation
- Test de failover DNS
```

---

> [!success] Points clés à retenir
> 
> - **DNS Resolver (Unbound)** est le choix recommandé pour la plupart des cas
> - Toujours activer **DNSSEC** pour la sécurité
> - Utiliser les **Host Overrides** pour la résolution de noms internes
> - Ne jamais exposer le DNS sur l'interface WAN
> - Documenter toutes les configurations personnalisées