

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

## 🎯 Introduction aux routes spéciales

Les routes spéciales sont des types de routes statiques qui répondent à des besoins particuliers en matière de gestion du trafic réseau. Contrairement aux routes statiques classiques qui dirigent le trafic vers une interface ou un next-hop spécifique, ces routes ont des comportements spéciaux qui permettent d'optimiser la sécurité, la performance et la gestion du routage.

> [!info] Pourquoi utiliser des routes spéciales ?
> 
> - **Sécurité** : Bloquer le trafic indésirable avec les routes nulles
> - **Optimisation** : Réduire la taille des tables de routage avec les routes récapitulatives
> - **Précision** : Cibler un hôte spécifique avec les routes /32
> - **Contrôle** : Éviter les boucles de routage et gérer les sous-réseaux efficacement

---

## 🚫 Route nulle (Null Route)

### Concept et utilité

Une **route nulle** (ou null route) est une route statique qui dirige le trafic vers une interface "nulle" (null0 ou discard). Tout paquet correspondant à cette route est immédiatement supprimé sans générer de message ICMP.

> [!tip] Cas d'usage principaux
> 
> - **Protection contre les attaques DDoS** : Blackholer le trafic malveillant
> - **Éviter les boucles de routage** : Avec les routes récapitulatives
> - **Filtrage du trafic** : Bloquer l'accès à certains réseaux
> - **Conformité réseau** : Empêcher le routage vers des plages d'adresses interdites

### Syntaxe et configuration

#### Sur Cisco IOS

```bash
# Syntaxe de base
Router(config)# ip route <réseau> <masque> null0

# Exemple : Bloquer le trafic vers 192.168.100.0/24
Router(config)# ip route 192.168.100.0 255.255.255.0 null0

# Avec une distance administrative personnalisée
Router(config)# ip route 10.0.0.0 255.0.0.0 null0 254

# Pour IPv6
Router(config)# ipv6 route 2001:db8:bad::/48 null0
```

#### Vérification

```bash
# Afficher la route nulle dans la table de routage
Router# show ip route 192.168.100.0

# Vérification avec un ping (doit échouer silencieusement)
Router# ping 192.168.100.10
```

> [!example] Exemple pratique : Protection DDoS
> 
> ```bash
> # Un serveur subit une attaque depuis 203.0.113.0/24
> Router(config)# ip route 203.0.113.0 255.255.255.0 null0
> 
> # Vérification
> Router# show ip route 203.0.113.0
> S    203.0.113.0/24 is directly connected, Null0
> ```

### Différence entre Null0 et interface de discard

|Caractéristique|Null0 (Cisco)|Discard (Juniper)|
|---|---|---|
|Génération ICMP|Non|Non|
|Compteurs|Disponibles|Disponibles|
|Performance|Très élevée|Très élevée|
|Utilisation CPU|Minimale|Minimale|

> [!warning] Attention aux conséquences
> 
> - Les paquets sont supprimés **sans notification**
> - Aucun message ICMP "Destination Unreachable" n'est envoyé
> - Le diagnostic réseau peut être plus difficile
> - Toujours documenter les routes nulles déployées

### Bonnes pratiques

1. **Documentation** : Commentez toujours vos routes nulles
    
    ```bash
    Router(config)# ip route 192.168.100.0 255.255.255.0 null0 name "Blocage DDoS - Ticket #12345"
    ```
    
2. **Monitoring** : Surveillez les compteurs de paquets sur Null0
    
    ```bash
    Router# show interface null0
    ```
    
3. **Temporisation** : Pour les blocages temporaires, utilisez une distance administrative élevée pour faciliter la suppression
    
4. **Précision** : Soyez aussi spécifique que possible pour éviter de bloquer du trafic légitime
    

---

## 📊 Route récapitulative (Summary Route)

### Concept et utilité

Une **route récapitulative** (ou summary route, route agrégée) est une route qui représente plusieurs sous-réseaux contigus par un seul préfixe plus court. Elle permet de regrouper plusieurs routes en une seule entrée dans la table de routage.

> [!info] Avantages du résumé de routes
> 
> - **Réduction de la table de routage** : Moins d'entrées à traiter
> - **Performance accrue** : Recherche plus rapide dans la table
> - **Stabilité** : Les changements dans les sous-réseaux n'affectent pas le reste du réseau
> - **Scalabilité** : Meilleure gestion des grands réseaux

### Calcul d'une route récapitulative

Pour créer une route récapitulative, il faut identifier le préfixe commun le plus long (CIDR) qui englobe tous les sous-réseaux.

> [!example] Exemple de calcul **Sous-réseaux à résumer :**
> 
> - 172.16.0.0/24
> - 172.16.1.0/24
> - 172.16.2.0/24
> - 172.16.3.0/24
> 
> **Conversion en binaire :**
> 
> ```
> 172.16.0.0 = 10101100.00010000.00000000.00000000
> 172.16.1.0 = 10101100.00010000.00000001.00000000
> 172.16.2.0 = 10101100.00010000.00000010.00000000
> 172.16.3.0 = 10101100.00010000.00000011.00000000
>                                   ^^^^^^ (2 bits varient)
> ```
> 
> **Route récapitulative : 172.16.0.0/22**
> 
> - Masque : 255.255.252.0
> - Englobe les adresses de 172.16.0.0 à 172.16.3.255

### Configuration avec route nulle préventive

Une bonne pratique consiste à créer une route nulle pour la route récapitulative afin d'éviter les boucles de routage si un sous-réseau est injoignable.

```bash
# Étape 1 : Créer la route nulle pour la route récapitulative
Router(config)# ip route 172.16.0.0 255.255.252.0 null0 254

# Étape 2 : Routes spécifiques vers les sous-réseaux (AD par défaut = 1)
Router(config)# ip route 172.16.0.0 255.255.255.0 10.1.1.1
Router(config)# ip route 172.16.1.0 255.255.255.0 10.1.1.1
Router(config)# ip route 172.16.2.0 255.255.255.0 10.1.1.2
Router(config)# ip route 172.16.3.0 255.255.255.0 10.1.1.2

# Étape 3 : Annoncer la route récapitulative aux voisins
Router(config)# router bgp 65001
Router(config-router)# network 172.16.0.0 mask 255.255.252.0
```

> [!warning] Pourquoi la route nulle avec AD 254 ? **Sans route nulle :**
> 
> - Si 172.16.1.0/24 devient injoignable
> - Le routeur cherche une route moins spécifique
> - Peut créer une boucle si la route récapitulative pointe vers un autre routeur
> 
> **Avec route nulle (AD=254) :**
> 
> - Les routes spécifiques (AD=1) sont préférées quand disponibles
> - Si une route spécifique tombe, le trafic est envoyé vers Null0 au lieu de boucler
> - Protection contre le black-holing accidentel

### Syntaxe complète

```bash
# Configuration d'une route récapitulative sécurisée
# AD=254 pour que les routes spécifiques soient préférées

Router(config)# ip route <réseau-récapitulatif> <masque> null0 254
Router(config)# ip route <sous-réseau-1> <masque> <next-hop>
Router(config)# ip route <sous-réseau-2> <masque> <next-hop>
```

> [!tip] Astuce pour le calcul rapide **Méthode des puissances de 2 :**
> 
> - 4 sous-réseaux /24 = 2² réseaux → Réduire le masque de 2 bits → /22
> - 8 sous-réseaux /24 = 2³ réseaux → Réduire le masque de 3 bits → /21
> - 16 sous-réseaux /24 = 2⁴ réseaux → Réduire le masque de 4 bits → /20

### Vérification

```bash
# Vérifier la table de routage
Router# show ip route 172.16.0.0

# Vérifier l'ordre de préférence (longest match)
Router# show ip route 172.16.1.5
Routing entry for 172.16.1.0/24    ← Route spécifique utilisée
  Known via "static", distance 1

# Si la route spécifique est supprimée
Router# show ip route 172.16.1.5
Routing entry for 172.16.0.0/22    ← Route récapitulative via Null0
  Known via "static", distance 254
```

### Bonnes pratiques

1. **Toujours utiliser une route nulle** avec AD élevée (254) pour la route récapitulative
2. **Documenter le calcul** : Indiquer quels sous-réseaux sont résumés
3. **Vérifier la contiguïté** : Les sous-réseaux doivent être adjacents
4. **Respecter les frontières** : Ne pas créer de résumé qui engloberait des plages non utilisées

---

## 🎯 Routes d'hôte (/32)

### Concept et utilité

Une **route d'hôte** est une route statique avec un masque /32 (255.255.255.255) qui cible une seule adresse IP spécifique. C'est la route la plus spécifique possible.

> [!info] Pourquoi utiliser des routes /32 ?
> 
> - **Précision maximale** : Cibler un seul hôte
> - **Priorité absolue** : La route la plus spécifique est toujours préférée
> - **Services critiques** : Rediriger le trafic vers des serveurs spécifiques
> - **Load balancing** : Distribuer les requêtes vers différents hôtes
> - **Migration** : Maintenir la connectivité pendant un déplacement de serveur

### Syntaxe et configuration

```bash
# Syntaxe de base
Router(config)# ip route <adresse-IP-hôte> 255.255.255.255 <next-hop>

# Exemple : Route vers un serveur DNS spécifique
Router(config)# ip route 8.8.8.8 255.255.255.255 10.0.1.254

# Avec notation CIDR (/32)
Router(config)# ip route 8.8.8.8/32 10.0.1.254

# Via une interface
Router(config)# ip route 192.168.1.100 255.255.255.255 GigabitEthernet0/1

# Avec distance administrative personnalisée
Router(config)# ip route 10.10.10.10 255.255.255.255 172.16.0.1 50
```

### Cas d'usage pratiques

#### 1. Redirection de serveur critique

```bash
# Serveur DNS primaire
Router(config)# ip route 8.8.8.8 255.255.255.255 10.0.1.254
Router(config)# ip route 8.8.4.4 255.255.255.255 10.0.1.254

# Serveur web en DMZ
Router(config)# ip route 203.0.113.50 255.255.255.255 192.168.100.10
```

#### 2. Load balancing basique (ECMP)

```bash
# Distribuer le trafic vers un serveur via deux chemins
Router(config)# ip route 10.1.1.100 255.255.255.255 172.16.0.1
Router(config)# ip route 10.1.1.100 255.255.255.255 172.16.0.2
```

> [!tip] ECMP (Equal-Cost Multi-Path) Lorsque plusieurs routes /32 avec la même distance administrative existent vers le même hôte, le routeur peut répartir le trafic entre les différents chemins.

#### 3. Migration de serveur

```bash
# Ancienne IP du serveur : 192.168.1.50
# Nouvelle IP du serveur : 192.168.2.100

# Pendant la migration, maintenir l'ancienne IP accessible
Router(config)# ip route 192.168.1.50 255.255.255.255 192.168.2.100

# Les applications continuent d'utiliser l'ancienne IP
# Le routeur redirige automatiquement vers la nouvelle
```

#### 4. Loopback virtuelle

```bash
# Créer une IP de management accessible via n'importe quelle interface
Router(config)# interface Loopback0
Router(config-if)# ip address 10.255.255.1 255.255.255.255

# Sur d'autres routeurs, créer des routes /32 vers cette loopback
Router2(config)# ip route 10.255.255.1 255.255.255.255 10.0.0.1
```

### Priorité et longest match

Les routes /32 ont la priorité maximale grâce au principe du **longest prefix match**.

> [!example] Exemple de priorité **Configuration :**
> 
> ```bash
> Router(config)# ip route 192.168.1.0 255.255.255.0 10.0.0.1      # /24
> Router(config)# ip route 192.168.1.0 255.255.255.128 10.0.0.2    # /25
> Router(config)# ip route 192.168.1.10 255.255.255.255 10.0.0.3   # /32
> ```
> 
> **Résultat :**
> 
> - Ping vers 192.168.1.10 → Utilise la route /32 via 10.0.0.3
> - Ping vers 192.168.1.50 → Utilise la route /25 via 10.0.0.2
> - Ping vers 192.168.1.200 → Utilise la route /24 via 10.0.0.1

### Vérification

```bash
# Afficher la route d'hôte spécifique
Router# show ip route 8.8.8.8
Routing entry for 8.8.8.8/32
  Known via "static", distance 1, metric 0
  Routing Descriptor Blocks:
  * 10.0.1.254
      Route metric is 0, traffic share count is 1

# Tester la connectivité
Router# ping 8.8.8.8 source GigabitEthernet0/0

# Tracer le chemin
Router# traceroute 8.8.8.8
```

### Comparaison avec les routes de sous-réseau

|Aspect|Route /32|Route /24|
|---|---|---|
|Spécificité|Maximum (1 hôte)|256 adresses|
|Priorité|Toujours préférée|Moins prioritaire|
|Flexibilité|Très ciblée|Plus générale|
|Utilisation|Hôtes critiques|Sous-réseaux entiers|
|Maintenance|Plus d'entrées|Moins d'entrées|

> [!warning] Attention à la prolifération
> 
> - Trop de routes /32 peut augmenter la taille de la table de routage
> - Impact sur les performances des recherches
> - Privilégier les routes de sous-réseau quand c'est possible
> - Réserver les /32 aux cas vraiment justifiés

### Bonnes pratiques

1. **Utiliser pour les services critiques** : DNS, NTP, serveurs de management
2. **Documenter le but** : Expliquer pourquoi la route /32 est nécessaire
    
    ```bash
    Router(config)# ip route 10.1.1.100 255.255.255.255 172.16.0.1 name "Serveur DNS principal"
    ```
    
3. **Limiter le nombre** : Ne pas abuser des routes /32
4. **Surveiller l'utilisation** : Vérifier régulièrement si elles sont toujours nécessaires
5. **Combiner avec ACL** : Pour un contrôle d'accès encore plus fin

---

## 📊 Comparaison des routes spéciales

|Type de route|Masque|Destination|Cas d'usage principal|AD recommandée|
|---|---|---|---|---|
|**Route nulle**|Variable|Null0|Blocage de trafic, protection contre les boucles|254 (pour summary) ou 1|
|**Route récapitulative**|Plus courte|Null0 + routes spécifiques|Agrégation, optimisation table|254 (null0) + 1 (spécifiques)|
|**Route d'hôte**|/32|Next-hop ou interface|Serveurs critiques, précision maximale|1 (par défaut)|

> [!tip] Combinaisons courantes **Scénario 1 : Résumé sécurisé**
> 
> ```bash
> ip route 10.0.0.0 255.255.0.0 null0 254        # Summary null
> ip route 10.0.1.0 255.255.255.0 192.168.1.1    # Sous-réseau spécifique
> ip route 10.0.1.10 255.255.255.255 192.168.1.2 # Hôte critique
> ```
> 
> **Priorité :** /32 > /24 > /16 (null0)
> 
> **Scénario 2 : Blocage avec exception**
> 
> ```bash
> ip route 192.168.0.0 255.255.0.0 null0         # Bloquer tout le /16
> ip route 192.168.10.0 255.255.255.0 10.0.0.1   # Sauf le sous-réseau /24
> ip route 192.168.10.50 255.255.255.255 10.0.0.2 # Et rediriger un hôte
> ```

---

## 🎓 Points clés à retenir

> [!tip] Synthèse
> 
> 1. **Route nulle** : Supprime le trafic sans notification, idéale pour la sécurité et éviter les boucles
> 2. **Route récapitulative** : Agrège plusieurs sous-réseaux, toujours protégée par une route nulle avec AD=254
> 3. **Route d'hôte (/32)** : Cible précise d'un seul hôte, priorité absolue grâce au longest match
> 4. **Longest prefix match** : La route la plus spécifique gagne toujours
> 5. **Distance administrative** : Permet de contrôler l'ordre de préférence entre routes de même spécificité

> [!warning] Pièges à éviter
> 
> - ❌ Route récapitulative sans route nulle → Risque de boucle
> - ❌ Trop de routes /32 → Table de routage gonflée
> - ❌ Route nulle trop large → Blocage de trafic légitime
> - ❌ Oublier de documenter les routes spéciales → Problèmes de maintenance

---

_Ce cours couvre les routes spéciales dans le cadre du routage statique. Ces concepts sont essentiels pour une gestion avancée du routage et se retrouvent également dans les protocoles de routage dynamique._