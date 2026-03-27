

## 📑 Table des matières

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

## 🎯 Introduction

La configuration des routes statiques consiste à définir manuellement les chemins que les paquets doivent emprunter pour atteindre des réseaux distants. Contrairement au routage dynamique, l'administrateur contrôle explicitement chaque entrée dans la table de routage.

> [!info] Pourquoi utiliser le routage statique ?
> 
> - **Contrôle total** : Vous décidez exactement par où passent les données
> - **Sécurité** : Pas d'échange d'informations de routage avec d'autres routeurs
> - **Performances** : Pas de surcharge CPU liée aux protocoles de routage dynamique
> - **Prévisibilité** : Les chemins ne changent pas automatiquement

> [!warning] Limites à connaître Le routage statique n'est pas adapté aux grandes infrastructures complexes car il nécessite une configuration manuelle de chaque route et ne s'adapte pas automatiquement aux changements de topologie.

---

## 📝 Syntaxe de base

La commande de configuration d'une route statique suit une structure précise qui doit être respectée pour fonctionner correctement.

### Structure générale

```bash
Router(config)# ip route <réseau_destination> <masque> {<next-hop> | <interface_sortie>} [distance_administrative]
```

### Décomposition des paramètres

|Paramètre|Description|Exemple|
|---|---|---|
|`réseau_destination`|Adresse réseau à atteindre|`192.168.10.0`|
|`masque`|Masque de sous-réseau|`255.255.255.0`|
|`next-hop`|Adresse IP du prochain routeur|`10.0.0.2`|
|`interface_sortie`|Interface par laquelle sortir|`GigabitEthernet0/0`|
|`distance_administrative`|Priorité de la route (optionnel)|`1` à `255`|

> [!example] Exemple simple
> 
> ```bash
> Router(config)# ip route 172.16.0.0 255.255.0.0 10.1.1.2
> ```
> 
> Cette commande indique : "Pour atteindre le réseau 172.16.0.0/16, envoie les paquets vers 10.1.1.2"

### Vérification des routes configurées

```bash
# Afficher la table de routage complète
Router# show ip route

# Afficher uniquement les routes statiques
Router# show ip route static

# Afficher une route spécifique
Router# show ip route 172.16.0.0
```

> [!tip] Astuce de vérification Utilisez `show running-config | include ip route` pour voir rapidement toutes les routes statiques configurées dans la configuration active.

---

## 🌐 Route vers un réseau distant

Une route vers un réseau distant permet au routeur de savoir comment atteindre un réseau qui n'est pas directement connecté.

### Contexte d'utilisation

Vous configurez une route vers un réseau distant lorsque :

- Le réseau n'est pas directement connecté à votre routeur
- Vous connaissez le chemin pour y accéder
- Vous voulez un contrôle précis sur le routage

### Configuration détaillée

```bash
# Accéder au mode de configuration globale
Router> enable
Router# configure terminal

# Configurer la route statique
Router(config)# ip route 192.168.20.0 255.255.255.0 10.0.0.2

# Sauvegarder la configuration
Router(config)# end
Router# write memory
# ou
Router# copy running-config startup-config
```

### Exemple pratique avec topologie

```
[R1] --- 10.0.0.0/30 --- [R2] --- 192.168.20.0/24
Gi0/0: 10.0.0.1         Gi0/0: 10.0.0.2
                        Gi0/1: 192.168.20.1
```

**Configuration sur R1 :**

```bash
R1(config)# ip route 192.168.20.0 255.255.255.0 10.0.0.2
```

> [!info] Explication R1 sait maintenant que pour atteindre le réseau 192.168.20.0/24, il doit envoyer les paquets à R2 (10.0.0.2) qui est directement connecté.

### Routes multiples vers différents réseaux

```bash
# Plusieurs réseaux distants via le même next-hop
R1(config)# ip route 192.168.20.0 255.255.255.0 10.0.0.2
R1(config)# ip route 192.168.30.0 255.255.255.0 10.0.0.2
R1(config)# ip route 172.16.0.0 255.255.0.0 10.0.0.2

# Réseaux distants via différents next-hops
R1(config)# ip route 192.168.40.0 255.255.255.0 10.0.1.2
R1(config)# ip route 192.168.50.0 255.255.255.0 10.0.2.2
```

> [!warning] Pièges courants
> 
> - **Next-hop non joignable** : Assurez-vous que l'adresse du next-hop est dans un réseau directement connecté
> - **Masque incorrect** : Un masque erroné peut entraîner un routage vers une plage d'adresses incorrecte
> - **Routage asymétrique** : Pensez à configurer la route de retour sur l'autre routeur

### Vérification et dépannage

```bash
# Vérifier que la route apparaît dans la table
R1# show ip route
S    192.168.20.0/24 [1/0] via 10.0.0.2

# Tester la connectivité
R1# ping 192.168.20.1

# Tracer le chemin emprunté
R1# traceroute 192.168.20.1

# Vérifier les statistiques de l'interface
R1# show ip interface brief
```

> [!tip] Bonne pratique Toujours documenter vos routes statiques avec des commentaires dans la configuration ou un document externe, surtout dans les environnements avec de nombreuses routes.

---

## 🚪 Route par défaut statique

La route par défaut (default route) est une route spéciale qui capture tout le trafic dont la destination n'est pas explicitement définie dans la table de routage. C'est la "porte de sortie" pour les destinations inconnues.

### Pourquoi utiliser une route par défaut ?

- **Simplification** : Une seule route au lieu de dizaines ou centaines
- **Internet** : Typiquement utilisée pour diriger le trafic vers Internet
- **Réseau de secours** : Point de sortie pour tout trafic non spécifiquement routé

### Syntaxe

```bash
Router(config)# ip route 0.0.0.0 0.0.0.0 {<next-hop> | <interface_sortie>}
```

> [!info] Signification de 0.0.0.0 0.0.0.0
> 
> - **0.0.0.0** : Réseau de destination (toutes les adresses)
> - **0.0.0.0** : Masque (capture tout)
> - Cette combinaison signifie "n'importe quelle destination"

### Exemple de configuration

```bash
# Route par défaut avec next-hop
R1(config)# ip route 0.0.0.0 0.0.0.0 203.0.113.1

# Route par défaut avec interface de sortie
R1(config)# ip route 0.0.0.0 0.0.0.0 Serial0/0/0
```

### Cas d'usage typique : Connexion Internet

```
[LAN] --- [Routeur] --- Internet
      192.168.1.0/24    ISP: 203.0.113.1
```

**Configuration :**

```bash
Router(config)# ip route 0.0.0.0 0.0.0.0 203.0.113.1
```

> [!example] Que se passe-t-il ? Lorsqu'un utilisateur du LAN tente d'accéder à un site web (ex: 142.250.185.46), le routeur :
> 
> 1. Cherche une route spécifique vers 142.250.185.46 → non trouvée
> 2. Utilise la route par défaut → envoie à 203.0.113.1 (ISP)
> 3. L'ISP se charge du reste du routage

### Configuration avec routes spécifiques et route par défaut

```bash
# Routes spécifiques pour les réseaux internes
R1(config)# ip route 192.168.10.0 255.255.255.0 10.0.0.2
R1(config)# ip route 192.168.20.0 255.255.255.0 10.0.0.3

# Route par défaut pour tout le reste (Internet)
R1(config)# ip route 0.0.0.0 0.0.0.0 203.0.113.1
```

### Vérification

```bash
R1# show ip route
Gateway of last resort is 203.0.113.1 to network 0.0.0.0

S*   0.0.0.0/0 [1/0] via 203.0.113.1
S    192.168.10.0/24 [1/0] via 10.0.0.2
S    192.168.20.0/24 [1/0] via 10.0.0.3
```

> [!info] Symbole S* Dans la table de routage, `S*` indique une route statique par défaut (static default route). Le `*` signifie qu'il s'agit de la "gateway of last resort".

### Route par défaut dans une architecture hiérarchique

```bash
# Routeur de périphérie (edge router)
Edge(config)# ip route 0.0.0.0 0.0.0.0 Internet_Gateway

# Routeur de distribution
Distribution(config)# ip route 0.0.0.0 0.0.0.0 Edge_Router

# Routeur d'accès
Access(config)# ip route 0.0.0.0 0.0.0.0 Distribution_Router
```

> [!warning] Attention aux boucles de routage Ne configurez JAMAIS de routes par défaut qui pointent les unes vers les autres, cela créerait une boucle de routage infinie.
> 
> **Exemple à éviter :**
> 
> ```bash
> R1(config)# ip route 0.0.0.0 0.0.0.0 10.0.0.2  # vers R2
> R2(config)# ip route 0.0.0.0 0.0.0.0 10.0.0.1  # vers R1 ❌
> ```

> [!tip] Bonne pratique en entreprise Dans une architecture d'entreprise, seul le routeur de bordure (edge router) connecté à l'ISP devrait avoir une vraie route par défaut vers Internet. Les autres routeurs ont des routes par défaut qui pointent vers ce routeur de bordure.

### Tests de validation

```bash
# Vérifier la route par défaut
R1# show ip route 0.0.0.0

# Tester avec une adresse Internet aléatoire
R1# ping 8.8.8.8

# Tracer le chemin
R1# traceroute 1.1.1.1

# Vérifier la gateway of last resort
R1# show ip route | include gateway
Gateway of last resort is 203.0.113.1 to network 0.0.0.0
```

---

## 🔄 Route avec next-hop vs interface de sortie

Lors de la configuration d'une route statique, vous avez deux options pour indiquer où envoyer les paquets : spécifier l'adresse IP du prochain routeur (next-hop) ou l'interface de sortie. Chaque méthode a ses avantages et inconvénients.

### Next-hop (Adresse IP du prochain saut)

**Syntaxe :**

```bash
Router(config)# ip route <réseau> <masque> <adresse_next-hop>
```

**Exemple :**

```bash
R1(config)# ip route 192.168.10.0 255.255.255.0 10.0.0.2
```

#### Fonctionnement

Lorsque vous spécifiez un next-hop, le routeur doit :

1. Recevoir un paquet destiné à 192.168.10.0/24
2. Consulter la table de routage
3. Trouver la route vers 10.0.0.2
4. Effectuer une résolution ARP pour obtenir l'adresse MAC de 10.0.0.2
5. Envoyer le paquet via l'interface appropriée

#### Avantages

- ✅ Fonctionne sur tous les types d'interfaces (Ethernet, Serial, etc.)
- ✅ Peut choisir automatiquement l'interface si plusieurs chemins existent
- ✅ Recommandé pour les réseaux multi-accès (Ethernet)

#### Inconvénients

- ❌ Nécessite une résolution ARP supplémentaire (léger surcoût)
- ❌ Dépend de la joignabilité du next-hop

> [!example] Cas d'usage typique
> 
> ```bash
> # Réseau Ethernet multi-accès
> R1(config)# ip route 172.16.0.0 255.255.0.0 10.1.1.2
> ```

### Interface de sortie

**Syntaxe :**

```bash
Router(config)# ip route <réseau> <masque> <interface_sortie>
```

**Exemple :**

```bash
R1(config)# ip route 192.168.10.0 255.255.255.0 GigabitEthernet0/0
```

#### Fonctionnement

Lorsque vous spécifiez une interface de sortie, le routeur :

1. Reçoit un paquet destiné à 192.168.10.0/24
2. L'envoie directement via l'interface spécifiée
3. Traite la destination comme "directement connectée" (proxy ARP)

#### Avantages

- ✅ Pas de résolution récursive nécessaire
- ✅ Légèrement plus rapide (pas de lookup supplémentaire)
- ✅ Idéal pour les liaisons point-à-point

#### Inconvénients

- ❌ Peut causer des problèmes sur les réseaux multi-accès Ethernet
- ❌ Crée une entrée ARP pour chaque destination (problème de scalabilité)
- ❌ Ne fonctionne correctement que sur les interfaces point-à-point

> [!warning] Problème sur les réseaux Ethernet Sur un réseau Ethernet multi-accès, spécifier uniquement l'interface de sortie peut causer des problèmes car le routeur ne sait pas vers quelle adresse MAC envoyer le paquet.

### Configuration hybride (Recommandée)

La meilleure pratique pour les réseaux Ethernet est de spécifier **à la fois** l'interface de sortie **et** le next-hop.

**Syntaxe :**

```bash
Router(config)# ip route <réseau> <masque> <interface_sortie> <adresse_next-hop>
```

**Exemple :**

```bash
R1(config)# ip route 192.168.10.0 255.255.255.0 GigabitEthernet0/0 10.0.0.2
```

#### Avantages de la configuration hybride

- ✅ Combine les avantages des deux méthodes
- ✅ Évite les problèmes de résolution récursive
- ✅ Fonctionne correctement sur tous les types de réseaux
- ✅ Recommandé par Cisco pour la plupart des cas

### Tableau comparatif

|Critère|Next-hop uniquement|Interface uniquement|Hybride|
|---|---|---|---|
|**Types d'interfaces**|Toutes|Point-à-point surtout|Toutes|
|**Performance**|Bonne|Excellente (P2P)|Excellente|
|**Réseaux Ethernet**|✅ Recommandé|⚠️ Problématique|✅ Optimal|
|**Liaisons Serial**|✅ Fonctionne|✅ Recommandé|✅ Fonctionne|
|**Complexité**|Simple|Simple|Légèrement plus complexe|

### Exemples selon le type d'interface

#### 1. Liaison Serial (point-à-point)

```bash
# Interface seule suffit (recommandé pour Serial)
R1(config)# ip route 192.168.10.0 255.255.255.0 Serial0/0/0
```

#### 2. Réseau Ethernet (multi-accès)

```bash
# Méthode recommandée : hybride
R1(config)# ip route 192.168.10.0 255.255.255.0 GigabitEthernet0/0 10.0.0.2

# Alternative acceptable : next-hop uniquement
R1(config)# ip route 192.168.10.0 255.255.255.0 10.0.0.2

# À éviter : interface seule
R1(config)# ip route 192.168.10.0 255.255.255.0 GigabitEthernet0/0  # ⚠️
```

#### 3. Tunnel VPN ou interfaces logiques

```bash
# Next-hop recommandé
R1(config)# ip route 192.168.10.0 255.255.255.0 10.0.0.2
```

### Vérification dans la table de routage

```bash
R1# show ip route static

# Avec next-hop uniquement
S    192.168.10.0/24 [1/0] via 10.0.0.2

# Avec interface uniquement
S    192.168.10.0/24 is directly connected, GigabitEthernet0/0

# Avec configuration hybride
S    192.168.10.0/24 [1/0] via 10.0.0.2, GigabitEthernet0/0
```

> [!tip] Règle générale simple
> 
> - **Liaisons point-à-point (Serial, PPP)** : Interface de sortie seule
> - **Réseaux Ethernet** : Next-hop seul OU configuration hybride
> - **En cas de doute** : Utilisez la configuration hybride (interface + next-hop)

### Cas pratique : Dépannage

```bash
# Problème : route configurée mais pas de connectivité
R1(config)# ip route 192.168.10.0 255.255.255.0 GigabitEthernet0/0

# Vérification
R1# show ip route
S    192.168.10.0/24 is directly connected, GigabitEthernet0/0

R1# ping 192.168.10.1
.....  # échec

# Solution : ajouter le next-hop
R1(config)# no ip route 192.168.10.0 255.255.255.0 GigabitEthernet0/0
R1(config)# ip route 192.168.10.0 255.255.255.0 GigabitEthernet0/0 10.0.0.2

R1# ping 192.168.10.1
!!!!!  # succès
```

---

## 🎈 Routes statiques flottantes

Une route statique flottante (floating static route) est une route de secours qui n'est utilisée que lorsque la route principale devient indisponible. Elle "flotte" au-dessus de la route active et n'entre en action qu'en cas de défaillance.

### Concept de distance administrative

Pour comprendre les routes flottantes, il faut d'abord comprendre la distance administrative (AD).

> [!info] Distance Administrative (AD) La distance administrative est une valeur de 0 à 255 qui indique la fiabilité d'une source de routage. Plus la valeur est **basse**, plus la route est **préférée**.

#### Valeurs par défaut des distances administratives

|Source de route|Distance Administrative|
|---|---|
|Interface connectée|0|
|Route statique|1|
|EIGRP (résumé)|5|
|eBGP|20|
|EIGRP (interne)|90|
|OSPF|110|
|IS-IS|115|
|RIP|120|
|EIGRP (externe)|170|
|iBGP|200|
|Route non fiable|255 (jamais utilisée)|

### Principe de la route flottante

Une route flottante a une distance administrative **plus élevée** que la route principale. Elle n'apparaît dans la table de routage que lorsque la route principale disparaît.

**Syntaxe :**

```bash
Router(config)# ip route <réseau> <masque> <next-hop_principal>
Router(config)# ip route <réseau> <masque> <next-hop_secours> <AD_élevée>
```

### Exemple de configuration basique

```
Internet
   |
[R1] --- Lien Principal (AD=1) --- [ISP1]
   |
   +---- Lien Secours (AD=5) ----- [ISP2]
```

**Configuration :**

```bash
# Route principale (utilise l'AD par défaut = 1)
R1(config)# ip route 0.0.0.0 0.0.0.0 203.0.113.1

# Route flottante (AD augmentée à 5)
R1(config)# ip route 0.0.0.0 0.0.0.0 198.51.100.1 5
```

> [!info] Comportement
> 
> - **En temps normal** : Seule la route via 203.0.113.1 (AD=1) est active
> - **Si le lien principal tombe** : La route via 198.51.100.1 (AD=5) devient active automatiquement
> - **Si le lien principal revient** : La route principale reprend sa place (AD=1 < AD=5)

### Vérification de l'état

```bash
# Situation normale - seule la route principale est visible
R1# show ip route
Gateway of last resort is 203.0.113.1 to network 0.0.0.0

S*   0.0.0.0/0 [1/0] via 203.0.113.1

# Après panne du lien principal - la route flottante prend le relais
R1# show ip route
Gateway of last resort is 198.51.100.1 to network 0.0.0.0

S*   0.0.0.0/0 [5/0] via 198.51.100.1
```

### Configuration avancée : Redondance complète

```bash
# Route principale vers réseau 1
R1(config)# ip route 192.168.10.0 255.255.255.0 10.1.1.2

# Route flottante vers réseau 1 (même destination, chemin différent)
R1(config)# ip route 192.168.10.0 255.255.255.0 10.2.2.2 10

# Route principale vers réseau 2
R1(config)# ip route 192.168.20.0 255.255.255.0 10.1.1.2

# Route flottante vers réseau 2
R1(config)# ip route 192.168.20.0 255.255.255.0 10.2.2.2 10

# Route par défaut principale
R1(config)# ip route 0.0.0.0 0.0.0.0 10.1.1.1

# Route par défaut flottante
R1(config)# ip route 0.0.0.0 0.0.0.0 10.2.2.1 5
```

### Choix de la valeur de distance administrative

> [!tip] Recommandations pour choisir l'AD
> 
> - **Route de secours pour route statique** : Utilisez 5-10 (plus élevé que 1)
> - **Route de secours pour OSPF** : Utilisez 120-130 (plus élevé que 110)
> - **Route de secours pour EIGRP** : Utilisez 100-110 (plus élevé que 90)
> - **Laissez de la marge** : Ne mettez pas 2 pour une route statique de secours, préférez 5 ou 10

### Cas d'usage pratique : Double connexion Internet

```
[Réseau d'entreprise]
        |
      [R1]
       / \
      /   \
  Fibre  ADSL
  (1Gb)  (20Mb)
    |      |
  [ISP1] [ISP2]
```

**Configuration :**

```bash
# Lien principal (Fibre) - AD par défaut
R1(config)# ip route 0.0.0.0 0.0.0.0 GigabitEthernet0/0 203.0.113.1

# Lien de secours (ADSL) - AD augmentée
R1(config)# ip route 0.0.0.0 0.0.0.0 GigabitEthernet0/1 198.51.100.1 5
```

### Interaction avec les protocoles de routage dynamique

Vous pouvez combiner routes flottantes et protocoles dynamiques pour une redondance optimale.

```bash
# OSPF est actif (AD = 110) pour le routage principal

# Route statique flottante en cas de défaillance OSPF
R1(config)# ip route 192.168.10.0 255.255.255.0 10.1.1.2 120
```

> [!info] Fonctionnement
> 
> - **Normal** : OSPF annonce la route (AD=110), la route statique n'est pas utilisée
> - **Panne OSPF** : La route statique (AD=120) devient active
> - **Retour OSPF** : OSPF reprend le contrôle (110 < 120)

### Vérification et dépannage

```bash
# Voir toutes les routes, y compris les flottantes non actives
R1# show ip route static

# Forcer l'affichage de toutes les routes candidates
R1# show ip route 192.168.10.0 255.255.255.0 longer-prefixes

# Tester manuellement la bascule en désactivant l'interface principale
R1(config)# interface GigabitEthernet0/0
R1(config-if)# shutdown
R1(config-if)# exit

# Vérifier que la route de secours est active
R1# show ip route
S*   0.0.0.0/0 [5/0] via 198.51.100.1  # AD = 5

# Réactiver l'interface
R1(config)# interface GigabitEthernet0/0
R1(config-if)# no shutdown
```

### Configuration avec Object Tracking

Pour une détection plus précise des pannes, vous pouvez utiliser le suivi d'objets (object tracking) combiné aux routes flottantes.

```bash
# Créer un objet de suivi pour pinger un serveur distant
R1(config)# ip sla 1
R1(config-ip-sla)# icmp-echo 8.8.8.8 source-interface GigabitEthernet0/0
R1(config-ip-sla)# frequency 10
R1(config-ip-sla)# exit

R1(config)# ip sla schedule 1 life forever start-time now

# Lier le tracking à l'objet SLA
R1(config)# track 1 ip sla 1 reachability

# Route principale avec tracking
R1(config)# ip route 0.0.0.0 0.0.0.0 203.0.113.1 track 1

# Route flottante (devient active si le tracking échoue)
R1(config)# ip route 0.0.0.0 0.0.0.0 198.51.100.1 5
```

> [!warning] Attention au flapping Si le lien principal est instable, les routes peuvent basculer trop fréquemment (flapping). Ajustez les timers de tracking et laissez une marge suffisante dans les AD pour éviter ce problème.

> [!tip] Bonne pratique
> 
> - Testez vos routes flottantes régulièrement en simulant des pannes
> - Documentez clairement quelles routes sont principales et lesquelles sont de secours
> - Utilisez des valeurs d'AD cohérentes dans toute votre infrastructure
> - Considérez l'utilisation du tracking pour une détection plus fine des pannes

### Exemple complet : Infrastructure à trois liens

```bash
# Configuration d'un routeur avec trois chemins possibles

# Chemin 1 : Lien principal haute capacité (AD = 1, par défaut)
R1(config)# ip route 0.0.0.0 0.0.0.0 10.1.1.1

# Chemin 2 : Lien secondaire moyenne capacité (AD = 5)
R1(config)# ip route 0.0.0.0 0.0.0.0 10.2.2.1 5

# Chemin 3 : Lien tertiaire faible capacité (AD = 10)
R1(config)# ip route 0.0.0.0 0.0.0.0 10.3.3.1 10
```

Dans cet exemple, le trafic utilise toujours le meilleur lien disponible selon l'ordre de préférence :

1. **Si lien 1 actif** → Utilise 10.1.1.1 (AD=1)
2. **Si lien 1 en panne** → Bascule sur 10.2.2.1 (AD=5)
3. **Si liens 1 et 2 en panne** → Bascule sur 10.3.3.1 (AD=10)
4. **Dès qu'un lien de meilleure priorité revient** → Retour automatique sur ce lien

### Scénarios de test

```bash
# Scénario 1 : Tous les liens fonctionnent
R1# show ip route
S*   0.0.0.0/0 [1/0] via 10.1.1.1
# Les deux autres routes ne sont pas visibles (AD plus élevées)

# Scénario 2 : Simulation de panne du lien principal
R1(config)# interface GigabitEthernet0/0
R1(config-if)# shutdown

R1# show ip route
S*   0.0.0.0/0 [5/0] via 10.2.2.1
# La route avec AD=5 prend le relais

# Scénario 3 : Panne des deux premiers liens
R1(config)# interface GigabitEthernet0/1
R1(config-if)# shutdown

R1# show ip route
S*   0.0.0.0/0 [10/0] via 10.3.3.1
# La route avec AD=10 (dernier recours) devient active
```

### Monitoring et logs

```bash
# Activer les logs pour voir les changements de routes
R1(config)# ip route static log-changes

# Voir l'historique des changements
R1# show logging | include route

# Exemple de logs générés
%ROUTING-5-ROUTE_ADJUST: Route 0.0.0.0/0 adjusted to new next-hop
%ROUTING-5-CONFIG_I: Configured from console by admin
```

---

## 🎯 Pièges courants et bonnes pratiques

### ⚠️ Pièges à éviter

#### 1. Oublier la route de retour

```bash
# Configuration sur R1
R1(config)# ip route 192.168.20.0 255.255.255.0 10.0.0.2

# ❌ ERREUR : Oublier la configuration sur R2
# Il faut aussi configurer la route retour sur R2 !

# ✅ CORRECT : Configuration sur R2
R2(config)# ip route 192.168.10.0 255.255.255.0 10.0.0.1
```

> [!warning] Routage asymétrique Si vous oubliez la route de retour, les paquets peuvent arriver à destination mais les réponses ne reviendront jamais, créant une panne unilatérale difficile à diagnostiquer.

#### 2. Masque de sous-réseau incorrect

```bash
# ❌ Masque trop large (capture trop de trafic)
R1(config)# ip route 192.168.10.0 255.255.0.0 10.0.0.2
# Cela capture 192.168.0.0/16 au lieu de 192.168.10.0/24

# ✅ Masque correct
R1(config)# ip route 192.168.10.0 255.255.255.0 10.0.0.2
```

#### 3. Next-hop non directement connecté

```bash
# ❌ Le next-hop doit être dans un réseau directement connecté
R1(config)# ip route 192.168.30.0 255.255.255.0 172.16.5.1
# Si 172.16.5.0/24 n'est pas directement connecté, la route ne fonctionnera pas

# ✅ Next-hop dans un réseau adjacent
R1(config)# ip route 192.168.30.0 255.255.255.0 10.0.0.2
```

#### 4. Distance administrative incorrecte pour les routes flottantes

```bash
# ❌ AD identique à la route principale (conflit)
R1(config)# ip route 0.0.0.0 0.0.0.0 10.1.1.1
R1(config)# ip route 0.0.0.0 0.0.0.0 10.2.2.1 1
# Les deux routes ont AD=1, comportement imprévisible

# ✅ AD différente pour créer une hiérarchie
R1(config)# ip route 0.0.0.0 0.0.0.0 10.1.1.1
R1(config)# ip route 0.0.0.0 0.0.0.0 10.2.2.1 5
```

#### 5. Surcharge de routes statiques dans une grande infrastructure

```bash
# ❌ 50+ routes statiques sur un même routeur
R1(config)# ip route 192.168.1.0 255.255.255.0 10.0.0.2
R1(config)# ip route 192.168.2.0 255.255.255.0 10.0.0.2
R1(config)# ip route 192.168.3.0 255.255.255.0 10.0.0.2
# ... (47 autres routes)
# Maintenance complexe et sources d'erreurs

# ✅ Solution : Utiliser une route résumée ou du routage dynamique
R1(config)# ip route 192.168.0.0 255.255.0.0 10.0.0.2
```

### ✅ Bonnes pratiques recommandées

#### 1. Documentation systématique

```bash
# Utiliser des commentaires dans la configuration
R1(config)# ! === ROUTES VERS SITE DISTANT PARIS ===
R1(config)# ip route 192.168.10.0 255.255.255.0 10.1.1.2
R1(config)# ip route 192.168.20.0 255.255.255.0 10.1.1.2
R1(config)# !
R1(config)# ! === ROUTE PAR DEFAUT VERS INTERNET ===
R1(config)# ip route 0.0.0.0 0.0.0.0 203.0.113.1
```

#### 2. Nommage cohérent des interfaces

```bash
# Utiliser des descriptions claires sur les interfaces
R1(config)# interface GigabitEthernet0/0
R1(config-if)# description LIEN_VERS_SITE_PARIS
R1(config-if)# ip address 10.1.1.1 255.255.255.252

R1(config)# interface GigabitEthernet0/1
R1(config-if)# description CONNEXION_INTERNET_ISP1
R1(config-if)# ip address 203.0.113.2 255.255.255.252
```

#### 3. Vérification après chaque ajout

```bash
# Après l'ajout d'une route
R1(config)# ip route 192.168.50.0 255.255.255.0 10.0.0.2
R1(config)# end

# Vérification immédiate
R1# show ip route 192.168.50.0
R1# ping 192.168.50.1
R1# traceroute 192.168.50.1
```

#### 4. Sauvegarde régulière de la configuration

```bash
# Sauvegarder après chaque modification importante
R1# copy running-config startup-config
# ou
R1# write memory

# Exporter la configuration
R1# copy running-config tftp:
Address or name of remote host []? 192.168.1.100
Destination filename [r1-confg]? R1-backup-2024-12-19.cfg
```

#### 5. Utilisation de routes résumées quand possible

```bash
# ❌ Routes multiples vers des sous-réseaux contigus
R1(config)# ip route 192.168.10.0 255.255.255.0 10.0.0.2
R1(config)# ip route 192.168.11.0 255.255.255.0 10.0.0.2
R1(config)# ip route 192.168.12.0 255.255.255.0 10.0.0.2
R1(config)# ip route 192.168.13.0 255.255.255.0 10.0.0.2

# ✅ Une seule route résumée (si approprié)
R1(config)# ip route 192.168.10.0 255.255.252.0 10.0.0.2
# Couvre 192.168.10.0 à 192.168.13.255
```

#### 6. Planification des distances administratives

|Scénario|AD recommandée|Justification|
|---|---|---|
|Route principale|1 (défaut)|Priorité maximale|
|Première route de secours|5-10|Marge confortable|
|Deuxième route de secours|15-20|Hiérarchie claire|
|Secours pour OSPF|111-120|Juste au-dessus de 110|
|Secours pour EIGRP|91-100|Juste au-dessus de 90|

#### 7. Monitoring et alertes

```bash
# Activer le logging des changements de routes
R1(config)# ip route static log-changes

# Configurer SNMP pour les alertes (mention uniquement)
R1(config)# snmp-server enable traps routing

# Utiliser IP SLA pour le monitoring actif
R1(config)# ip sla 10
R1(config-ip-sla)# icmp-echo 192.168.10.1
R1(config-ip-sla)# frequency 30
```

#### 8. Tests réguliers de basculement

```bash
# Tester mensuellement les routes de secours
# 1. Simuler la panne
R1(config)# interface GigabitEthernet0/0
R1(config-if)# shutdown

# 2. Vérifier la bascule
R1# show ip route
R1# ping <destination_test>

# 3. Rétablir et vérifier le retour
R1(config)# interface GigabitEthernet0/0
R1(config-if)# no shutdown
R1# show ip route
```

---

## 📊 Synthèse et aide-mémoire

### Commandes essentielles

```bash
# Configuration de base
ip route <réseau> <masque> <next-hop>
ip route <réseau> <masque> <interface>
ip route <réseau> <masque> <interface> <next-hop>

# Route par défaut
ip route 0.0.0.0 0.0.0.0 <next-hop>

# Route flottante
ip route <réseau> <masque> <next-hop> <AD>

# Suppression
no ip route <réseau> <masque> <next-hop>

# Vérification
show ip route
show ip route static
show ip route <adresse_IP>
show running-config | include ip route

# Tests
ping <destination>
traceroute <destination>
```

### Checklist de configuration

- [ ] Vérifier que tous les réseaux adjacents sont configurés
- [ ] Configurer les routes dans les deux sens (aller ET retour)
- [ ] Valider les masques de sous-réseau
- [ ] S'assurer que les next-hops sont joignables
- [ ] Tester la connectivité avec ping et traceroute
- [ ] Documenter chaque route dans la configuration
- [ ] Sauvegarder la configuration
- [ ] Pour les routes flottantes : tester le basculement
- [ ] Vérifier l'absence de boucles de routage
- [ ] Activer le logging des changements si nécessaire

### Quand utiliser chaque type de route

|Type de route|Cas d'usage idéal|
|---|---|
|**Route vers réseau distant**|Réseaux spécifiques connus et stables|
|**Route par défaut**|Connexion Internet, gateway centrale|
|**Next-hop**|Réseaux Ethernet multi-accès|
|**Interface de sortie**|Liaisons point-à-point (Serial, PPP)|
|**Configuration hybride**|Meilleure pratique générale pour Ethernet|
|**Routes flottantes**|Redondance, liens de secours, haute disponibilité|

---

## 🔍 Dépannage rapide

### Problème : Route configurée mais pas de connectivité

```bash
# 1. Vérifier que la route est bien dans la table
R1# show ip route 192.168.10.0

# 2. Vérifier que le next-hop est joignable
R1# ping 10.0.0.2

# 3. Vérifier l'état de l'interface
R1# show ip interface brief

# 4. Vérifier les ACLs qui pourraient bloquer
R1# show access-lists

# 5. Tracer le chemin
R1# traceroute 192.168.10.1
```

### Problème : Route flottante ne bascule pas

```bash
# 1. Vérifier les distances administratives
R1# show ip route
# Comparer les [AD/métrique]

# 2. Vérifier que le next-hop principal est réellement down
R1# ping <next-hop_principal>

# 3. Forcer la désactivation de l'interface principale
R1(config)# interface GigabitEthernet0/0
R1(config-if)# shutdown

# 4. Vérifier la nouvelle route active
R1# show ip route
```

### Problème : Paquets n'arrivent pas à destination

```bash
# Vérifier le chemin complet (aller ET retour)
# Sur le routeur source
Source# traceroute <destination>

# Sur le routeur destination
Dest# show ip route <source_IP>

# Vérifier qu'il y a bien une route retour !
```

---

## 💡 Points clés à retenir

> [!tip] Les 10 règles d'or du routage statique
> 
> 1. **Toujours configurer les routes dans les deux sens** (aller ET retour)
> 2. **Vérifier la joignabilité du next-hop** avant de configurer
> 3. **Utiliser des masques corrects** adaptés à vos sous-réseaux
> 4. **Préférer la configuration hybride** (interface + next-hop) pour Ethernet
> 5. **Documenter chaque route** avec des commentaires
> 6. **Tester immédiatement** après chaque configuration
> 7. **Utiliser des routes flottantes** pour la redondance
> 8. **Sauvegarder régulièrement** votre configuration
> 9. **Éviter la surcharge** de routes statiques (considérer le routage dynamique)
> 10. **Planifier les distances administratives** de manière cohérente

> [!warning] Erreurs fatales à éviter absolument
> 
> - ❌ Créer des boucles de routage (routes circulaires)
> - ❌ Oublier la route de retour
> - ❌ Utiliser un next-hop non joignable
> - ❌ Configurer des routes flottantes avec la même AD que la route principale
> - ❌ Ne pas tester les configurations de secours

---

_Ce cours couvre la configuration complète des routes statiques. Pour aller plus loin, vous explorerez d'autres aspects du routage dans les parties suivantes de votre formation._