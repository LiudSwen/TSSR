

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

## 🎯 Définition et fonctionnement

### Qu'est-ce que le routage statique ?

Le **routage statique** est une méthode de configuration manuelle des routes réseau sur un routeur. Contrairement aux protocoles de routage dynamique (qui seront abordés dans une autre partie), les routes statiques sont définies explicitement par l'administrateur réseau et ne changent pas automatiquement en fonction de l'état du réseau.

> [!info] Principe fondamental Une route statique indique au routeur : "Pour atteindre le réseau X, envoie les paquets vers le routeur Y (next-hop) ou via l'interface Z".

### Comment fonctionne une route statique ?

Lorsqu'un routeur reçoit un paquet, il consulte sa **table de routage** pour déterminer où envoyer ce paquet. Cette table contient des entrées qui associent :

- Un **réseau de destination** (adresse réseau + masque)
- Un **next-hop** (adresse IP du prochain routeur) OU une **interface de sortie**
- Une **métrique** (distance administrative)

```bash
# Exemple de syntaxe générique d'une route statique
ip route [réseau_destination] [masque] [next-hop | interface_sortie] [distance_administrative]
```

> [!example] Exemple concret
> 
> ```bash
> # Sur un routeur Cisco
> ip route 192.168.10.0 255.255.255.0 10.0.0.2
> ```
> 
> Cette commande signifie : "Pour atteindre le réseau 192.168.10.0/24, envoie les paquets vers le routeur ayant l'IP 10.0.0.2"

### Processus de consultation de la table de routage

1. Le routeur reçoit un paquet destiné à une IP spécifique
2. Il examine sa table de routage
3. Il cherche la correspondance la plus spécifique (longest prefix match)
4. Il transmet le paquet selon la route trouvée
5. Si aucune route n'existe, le paquet est abandonné

> [!warning] Point d'attention Les routes statiques sont **unidirectionnelles**. Si vous voulez une communication bidirectionnelle entre deux réseaux, vous devez configurer des routes statiques dans les DEUX sens sur les routeurs concernés.

### Types de routes statiques

|Type|Description|Syntaxe typique|
|---|---|---|
|**Route standard**|Spécifie un réseau de destination et un next-hop|`ip route 192.168.1.0 255.255.255.0 10.0.0.1`|
|**Route par défaut**|Route "catch-all" pour tout trafic sans correspondance|`ip route 0.0.0.0 0.0.0.0 203.0.113.1`|
|**Route vers interface**|Utilise une interface de sortie au lieu d'un next-hop|`ip route 192.168.1.0 255.255.255.0 Serial0/0`|
|**Route flottante**|Route de secours avec une distance administrative élevée|`ip route 192.168.1.0 255.255.255.0 10.0.0.2 200`|

> [!tip] Astuce - Route par défaut La route par défaut (0.0.0.0/0) est essentielle dans la plupart des réseaux. Elle indique où envoyer tout le trafic qui ne correspond à aucune autre route spécifique. C'est particulièrement utile pour diriger le trafic Internet vers le FAI.

---

## ⚖️ Avantages et inconvénients

### ✅ Avantages du routage statique

#### 1. Simplicité de configuration

Dans les petits réseaux avec peu de routeurs, configurer quelques routes statiques est rapide et direct. Pas besoin de comprendre des protocoles complexes.

#### 2. Contrôle total

L'administrateur décide exactement du chemin que prendront les paquets. Aucune surprise, aucun calcul automatique qui pourrait choisir un chemin non optimal selon vos critères métier.

#### 3. Sécurité renforcée

- Aucune information de routage n'est échangée sur le réseau
- Pas de risque d'attaque par injection de routes malveillantes
- Pas de protocole de routage à sécuriser (authentification, chiffrement)

#### 4. Consommation de ressources minimale

- Pas de bande passante utilisée pour les mises à jour de routage
- Pas de CPU consommé pour calculer des routes
- Pas de mémoire RAM nécessaire pour maintenir des tables de voisinage

#### 5. Prévisibilité absolue

Les routes ne changent jamais sauf intervention manuelle. Le comportement du réseau est parfaitement déterministe.

> [!tip] Astuce - Performance Sur des équipements avec des ressources limitées (petits routeurs, routeurs anciens), le routage statique peut significativement améliorer les performances en évitant la surcharge des protocoles dynamiques.

### ❌ Inconvénients du routage statique

#### 1. Absence de résilience automatique

Si un lien tombe ou un routeur devient inaccessible, les routes statiques pointant vers ce chemin restent actives. Le trafic continue d'être envoyé vers un chemin mort jusqu'à intervention manuelle.

```bash
# Exemple de problème
# Si le routeur 10.0.0.2 tombe en panne, cette route reste active
ip route 192.168.10.0 255.255.255.0 10.0.0.2
# Les paquets seront perdus jusqu'à ce que vous supprimiez ou modifiez cette route
```

> [!warning] Risque majeur Dans un réseau utilisant uniquement du routage statique, une panne réseau nécessite une intervention humaine immédiate pour restaurer la connectivité. Il n'y a aucune adaptation automatique.

#### 2. Charge administrative élevée dans les grands réseaux

Plus le réseau grandit, plus le nombre de routes à configurer augmente de façon exponentielle. Chaque ajout de réseau nécessite de modifier potentiellement plusieurs routeurs.

**Exemple concret** : Un réseau avec 10 routeurs et 20 réseaux pourrait nécessiter des dizaines voire des centaines d'entrées de routes à configurer manuellement.

#### 3. Erreurs humaines fréquentes

La configuration manuelle est sujette aux fautes de frappe, aux oublis, aux erreurs d'adressage qui peuvent causer :

- Des boucles de routage (paquets qui tournent en boucle)
- Des routes incohérentes (asymétrie de routage)
- Des réseaux inaccessibles (routes manquantes)

#### 4. Difficulté de maintenance

- Documentation indispensable mais souvent obsolète
- Difficulté à tracer les chemins de bout en bout
- Modifications complexes lors de restructurations réseau

#### 5. Inadapté aux réseaux redondants

Dans les topologies avec plusieurs chemins possibles, le routage statique ne peut pas profiter automatiquement de la redondance. Il faut implémenter manuellement des mécanismes de basculement.

### 📊 Tableau comparatif synthétique

|Critère|Routage statique|Impact|
|---|---|---|
|**Configuration initiale**|✅ Simple pour petits réseaux|Rapide à déployer|
|**Scalabilité**|❌ Très limitée|Problématique au-delà de 5-10 routeurs|
|**Adaptation aux pannes**|❌ Aucune|Nécessite intervention manuelle|
|**Ressources système**|✅ Minimales|Idéal pour équipements limités|
|**Sécurité**|✅ Excellente|Pas d'échange d'informations|
|**Prévisibilité**|✅ Totale|Comportement déterministe|
|**Maintenance**|❌ Lourde sur grands réseaux|Erreurs fréquentes|

---

## 🎯 Cas d'usage appropriés

### Scénarios idéaux pour le routage statique

#### 1. Réseaux de petite taille

**Contexte** : Entreprise avec 2-5 sites connectés par liens WAN, peu de routeurs, topologie simple.

> [!example] Exemple concret Une PME avec un siège social, deux agences et une connexion Internet. Total : 4 routeurs, 8-10 réseaux. Le routage statique suffit amplement et simplifie la gestion.

#### 2. Réseaux stub (cul-de-sac)

Un **réseau stub** est un réseau qui n'a qu'un seul point de sortie vers le reste de l'infrastructure.

```bash
# Configuration typique d'un réseau stub
# Il n'a besoin que d'une route par défaut vers le routeur principal
ip route 0.0.0.0 0.0.0.0 192.168.1.1
```

**Avantages** :

- Une seule route nécessaire (route par défaut)
- Aucun intérêt à utiliser un protocole dynamique
- Configuration minimale

> [!tip] Identification d'un réseau stub Posez-vous la question : "Ce réseau peut-il servir de transit vers d'autres réseaux ?" Si la réponse est non, c'est un réseau stub parfait pour le routage statique.

#### 3. Connexion à Internet (route par défaut)

La plupart des entreprises utilisent une route statique par défaut pour diriger le trafic Internet vers leur FAI.

```bash
# Route par défaut vers le FAI
ip route 0.0.0.0 0.0.0.0 203.0.113.1
```

**Pourquoi ?**

- Les FAI ne partagent pas leurs tables de routage complètes avec les clients
- Une simple route par défaut suffit pour atteindre Internet
- Plus sécurisé que d'établir une adjacence de routage dynamique

#### 4. Routes de secours (floating static routes)

Les routes flottantes sont des routes statiques avec une **distance administrative élevée** qui ne deviennent actives que si la route principale tombe.

```bash
# Route principale via un lien principal (distance admin par défaut)
ip route 192.168.10.0 255.255.255.0 10.0.0.2

# Route de secours via un lien de backup (distance admin 200)
ip route 192.168.10.0 255.255.255.0 10.0.0.10 200
```

> [!info] Principe de la distance administrative La **distance administrative** (AD) est une valeur de confiance. Plus elle est basse, plus la route est préférée. Par défaut, les routes statiques ont une AD de 1. En augmentant cette valeur (ex: 200), la route n'est utilisée que si les routes avec une AD plus basse sont inactives.

#### 5. Routage de précision pour des flux critiques

Forcer certains flux critiques à emprunter un chemin spécifique, même si un protocole dynamique existe pour le reste du réseau.

**Exemple** : Trafic de voix (VoIP) ou de vidéoconférence qui doit absolument emprunter le lien avec la latence la plus faible.

#### 6. Environnements avec contraintes de sécurité strictes

- Réseaux militaires ou gouvernementaux
- Infrastructures critiques (centrales électriques, systèmes SCADA)
- Réseaux où aucun protocole ne doit circuler pour éviter la reconnaissance

#### 7. Lab et environnements de test

Pour l'apprentissage et les tests, le routage statique permet de :

- Comprendre les fondamentaux du routage
- Tester des scénarios spécifiques
- Avoir un contrôle total pour le dépannage

### Scénarios à ÉVITER pour le routage statique

|Situation|Raison|
|---|---|
|**Réseau avec topologie maillée**|Trop de chemins possibles, explosion combinatoire des routes|
|**Réseau avec redondance active**|Impossible de profiter automatiquement des chemins multiples|
|**Réseau en croissance rapide**|Maintenance rapidement ingérable|
|**Réseau multi-sites avec +10 sites**|Charge administrative écrasante|
|**Besoin de basculement rapide**|Pas d'adaptation automatique aux pannes|

> [!warning] Règle empirique Au-delà de 5-7 routeurs ou 15-20 réseaux, envisagez sérieusement un protocole de routage dynamique. Le temps gagné en automatisation dépasse largement l'effort d'apprentissage du protocole.

---

## 🔧 Charge administrative

### Tâches de configuration initiale

#### 1. Planification du schéma d'adressage

Avant même de configurer la première route, l'administrateur doit :

- Documenter tous les réseaux et leurs masques
- Identifier tous les routeurs et leurs interfaces
- Dessiner la topologie réseau
- Déterminer les chemins optimaux

**Temps estimé** : 2-4 heures pour un réseau de 5 routeurs

#### 2. Configuration des routes sur chaque routeur

Pour chaque routeur, il faut configurer des routes vers TOUS les réseaux distants.

> [!example] Exemple de calcul **Réseau avec 5 routeurs et 12 réseaux** :
> 
> - Chaque routeur connaît directement 2-3 réseaux (ses interfaces)
> - Chaque routeur doit donc avoir ~9-10 routes statiques configurées
> - Total : 45-50 routes à configurer manuellement sur l'ensemble du réseau

```bash
# Routeur A - Exemple de configuration
ip route 192.168.10.0 255.255.255.0 10.0.0.2
ip route 192.168.20.0 255.255.255.0 10.0.0.2
ip route 192.168.30.0 255.255.255.0 10.0.0.6
ip route 192.168.40.0 255.255.255.0 10.0.0.6
# ... et ainsi de suite pour chaque réseau distant
```

**Temps estimé** : 30-60 minutes par routeur (avec vérifications)

#### 3. Tests de connectivité

- Ping de bout en bout entre tous les réseaux
- Traceroute pour vérifier les chemins
- Validation du plan de numérotation
- Tests de scénarios de défaillance

**Temps estimé** : 1-2 heures pour un réseau de 5 routeurs

### Tâches de maintenance continue

#### 1. Ajout d'un nouveau réseau

**Procédure complète** :

1. Documenter le nouveau réseau dans le schéma
2. Identifier tous les routeurs qui doivent connaître ce réseau
3. Se connecter à chaque routeur concerné
4. Ajouter la route statique appropriée
5. Tester la connectivité depuis/vers le nouveau réseau
6. Mettre à jour la documentation

**Temps estimé** : 30-90 minutes selon la complexité

> [!warning] Erreur fréquente Oublier de configurer les routes de retour ! Si vous ajoutez une route sur le routeur A vers un nouveau réseau via le routeur B, n'oubliez pas que le routeur B (et autres) doivent aussi avoir une route de retour.

#### 2. Modification de la topologie

Changement de lien, ajout d'un routeur, modification d'architecture :

- Révision complète du plan de routage
- Modification de multiples routeurs
- Risque élevé d'incohérences temporaires
- Nécessite souvent une fenêtre de maintenance

**Temps estimé** : 2-8 heures selon l'ampleur des changements

#### 3. Dépannage des problèmes de routage

En cas de problème de connectivité, l'administrateur doit :

- Vérifier les tables de routage de multiples routeurs
- Comparer avec la documentation (si elle est à jour)
- Tracer manuellement le chemin des paquets
- Identifier les routes manquantes ou incorrectes

**Temps estimé** : 30 minutes à plusieurs heures selon la complexité

> [!tip] Astuce de dépannage Utilisez systématiquement `show ip route` pour visualiser la table de routage et identifier les routes problématiques. Tracez le chemin hop par hop pour localiser où la connectivité se rompt.

### Documentation obligatoire

Le routage statique ne fonctionne bien que si la documentation est **impeccable et à jour**.

#### Documents essentiels à maintenir :

|Document|Contenu|Fréquence de mise à jour|
|---|---|---|
|**Schéma de topologie**|Tous les routeurs, liens, réseaux|À chaque modification|
|**Plan d'adressage**|Tous les réseaux et masques|À chaque ajout|
|**Table de routage logique**|Routes attendues par routeur|À chaque changement|
|**Procédures de configuration**|Commandes standards et conventions|Trimestriel|
|**Historique des changements**|Log des modifications et raisons|Chaque intervention|

> [!warning] Conséquence d'une documentation obsolète Une documentation non maintenue rend le dépannage cauchemardesque et augmente drastiquement le risque d'erreurs lors des modifications. Dans les faits, c'est souvent le principal problème des réseaux en routage statique.

### Charge administrative comparée

**Comparaison effort initial vs effort continu** :

|Phase|Routage statique|Routage dynamique|
|---|---|---|
|**Apprentissage**|⭐⭐ Facile|⭐⭐⭐⭐ Complexe|
|**Configuration initiale**|⭐⭐ Rapide|⭐⭐⭐ Modérée|
|**Ajout de réseau**|⭐⭐⭐⭐ Lourd|⭐ Automatique|
|**Dépannage de panne**|⭐⭐⭐⭐⭐ Très lourd|⭐⭐ Auto-adaptatif|
|**Documentation**|⭐⭐⭐⭐⭐ Critique|⭐⭐ Utile mais moins critique|

### Calcul du coût total d'administration

> [!info] Formule empirique **Temps mensuel = (Nombre de routeurs × 0.5h) + (Modifications × 1h) + (Incidents × 2h)**

**Exemple concret** :

- Réseau de 8 routeurs
- 2 modifications par mois (ajout de réseau, changement)
- 1 incident de connectivité par mois

**Calcul** : (8 × 0.5) + (2 × 1) + (1 × 2) = 4 + 2 + 2 = **8 heures/mois**

Pour un réseau similaire en routage dynamique : **~2-3 heures/mois** (principalement monitoring et incidents exceptionnels)

### Stratégies pour réduire la charge administrative

#### 1. Utiliser la récursivité des routes

Au lieu de configurer des routes spécifiques vers chaque réseau distant, utilisez des routes agrégées quand c'est possible.

```bash
# Au lieu de :
ip route 192.168.10.0 255.255.255.0 10.0.0.2
ip route 192.168.11.0 255.255.255.0 10.0.0.2
ip route 192.168.12.0 255.255.255.0 10.0.0.2

# Utilisez (si le plan d'adressage le permet) :
ip route 192.168.0.0 255.255.240.0 10.0.0.2
```

#### 2. Standardiser les conventions de nommage

Utilisez des descriptions claires sur les interfaces et dans la documentation.

```bash
interface GigabitEthernet0/0
 description ** Lien vers RouterB - Reseau 10.0.0.0/30 **
 ip address 10.0.0.1 255.255.255.252
```

#### 3. Automatiser avec des scripts

Pour les modifications répétitives, utilisez des scripts (Python, Ansible) pour déployer les configurations.

#### 4. Mettre en place un processus de gestion des changements

- Validation par un pair avant application
- Tests en environnement de lab si possible
- Planification des fenêtres de maintenance
- Backups de configuration avant chaque changement

> [!tip] Astuce pro Utilisez des outils de gestion de configuration (Git pour les configs, Netbox pour l'inventaire) même pour des petits réseaux. L'investissement initial est vite rentabilisé.

---

## 🎓 Synthèse des points clés

Le routage statique est une méthode de configuration manuelle des routes, idéale pour les petits réseaux, les réseaux stub et les connexions Internet. Ses principaux **avantages** sont la simplicité, le contrôle total, la sécurité et la faible consommation de ressources. Ses **inconvénients majeurs** sont l'absence de résilience automatique et la charge administrative qui devient rapidement ingérable dans les réseaux moyens à grands.

**Règle d'or** : Utilisez le routage statique quand le réseau est petit, la topologie simple et les changements rares. Dès que l'un de ces critères n'est plus respecté, envisagez un protocole de routage dynamique.

> [!tip] Conseil final Dans la pratique, la plupart des réseaux professionnels utilisent une **combinaison** : routage dynamique pour le cœur du réseau et routes statiques pour des cas spécifiques (route par défaut, réseaux stub, routes de secours). C'est souvent la meilleure approche.