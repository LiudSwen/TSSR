

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

## 🎯 Introduction au pare-feu pfSense

pfSense utilise le sous-système **pf (Packet Filter)** de FreeBSD, considéré comme l'un des pare-feu les plus performants et fiables du monde open-source. Ce pare-feu est **stateful par défaut**, ce qui signifie qu'il suit l'état des connexions réseau de manière intelligente.

> [!info] Philosophie de pfSense Le principe fondamental de pfSense est : **tout est bloqué par défaut, sauf ce qui est explicitement autorisé**. C'est l'approche "deny all, permit by exception" qui garantit la sécurité maximale.

---

## 🔄 Fonctionnement du pare-feu stateful

### Qu'est-ce qu'un pare-feu stateful ?

Un pare-feu **stateful** (à états) maintient une table des connexions actives et comprend le contexte des flux réseau. Contrairement à un pare-feu stateless qui examine chaque paquet indépendamment, un pare-feu stateful :

- **Suit les connexions** de bout en bout
- **Autorise automatiquement** les réponses aux connexions établies
- **Détecte les anomalies** dans les échanges réseau
- **Optimise les performances** en évitant de réévaluer chaque paquet

### Mécanisme de suivi des états

```
┌─────────────────────────────────────────────────────────┐
│  Étape 1 : Paquet SYN entrant (nouvelle connexion)     │
│  ↓                                                       │
│  Vérification contre les règles du pare-feu             │
│  ↓                                                       │
│  Si autorisé → Création d'une entrée dans la table      │
│                d'états                                   │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│  Étape 2 : Paquets suivants de la même connexion       │
│  ↓                                                       │
│  Recherche dans la table d'états                        │
│  ↓                                                       │
│  Si état existe → Passage direct (pas de réévaluation   │
│                   des règles)                            │
└─────────────────────────────────────────────────────────┘
```

> [!example] Exemple pratique Vous créez une règle autorisant votre PC (192.168.1.10) à accéder au web (port 80/443).
> 
> - **Flux sortant** : Votre requête HTTP est évaluée et autorisée par la règle
> - **Flux retour** : La réponse du serveur web passe automatiquement sans nécessiter de règle supplémentaire
> 
> C'est le fonctionnement stateful qui gère cela intelligemment.

### Avantages du pare-feu stateful

|Avantage|Description|
|---|---|
|**Sécurité renforcée**|Détecte les paquets non sollicités et les attaques|
|**Simplicité**|Pas besoin de règles bidirectionnelles|
|**Performance**|Traitement rapide des paquets d'une connexion établie|
|**Protocoles complexes**|Gère FTP, SIP, H.323 avec leurs flux secondaires|

> [!warning] Important Le suivi d'états consomme de la mémoire. Chaque connexion active occupe environ 1KB dans la table d'états. Surveillez l'utilisation via **Diagnostics > States Summary**.

---

## 📏 Ordre d'évaluation des règles

### Principe fondamental : First Match Wins

pfSense évalue les règles **de haut en bas** et applique la **première règle qui correspond**. Une fois qu'une correspondance est trouvée, l'évaluation s'arrête.

```
Règle 1 : Block 192.168.1.100 → Any
Règle 2 : Pass 192.168.1.0/24 → Any
Règle 3 : Pass Any → Any

Résultat pour 192.168.1.100 : BLOQUÉ (correspond à la règle 1)
Résultat pour 192.168.1.50  : AUTORISÉ (correspond à la règle 2)
```

### Ordre de traitement complet

```
1. Rules sur l'interface concernée (ordre personnalisé)
   ↓
2. Floating rules (si configurées)
   ↓
3. Règles de sortie (outbound NAT, si applicable)
   ↓
4. Si aucune correspondance : BLOCK (défaut implicite)
```

> [!tip] Astuce de placement Placez toujours vos règles **du plus spécifique au plus général** :
> 
> 1. Règles de blocage spécifiques (IPs précises)
> 2. Règles d'autorisation spécifiques (services critiques)
> 3. Règles d'autorisation générales (plages réseau)
> 4. Règles de blocage générales (si nécessaire)

### Règles par interface vs Floating Rules

**Règles d'interface** (standard) :

- Liées à une interface spécifique (WAN, LAN, DMZ, etc.)
- Évaluées en premier
- S'appliquent uniquement au trafic entrant sur cette interface
- Organisation : par défaut de haut en bas

**Floating Rules** (avancées) :

- S'appliquent à plusieurs interfaces simultanément
- Peuvent être évaluées avant ou après les règles d'interface
- Direction configurable : in/out/any
- Utilisées pour des politiques globales

> [!warning] Piège courant Une règle trop générale placée en haut de liste peut "masquer" des règles plus spécifiques en dessous :
> 
> ```
> ❌ Mauvais ordre :
> Pass Any → Any (autorise tout)
> Block 192.168.1.100 → Any (jamais atteinte !)
> 
> ✅ Bon ordre :
> Block 192.168.1.100 → Any
> Pass Any → Any
> ```

### Réorganisation des règles

Dans l'interface pfSense (**Firewall > Rules > [Interface]**) :

- Utilisez les icônes ↑↓ pour déplacer les règles
- Ou glissez-déposez les règles (drag & drop)
- Cliquez sur "Save" puis "Apply Changes" pour activer

---

## ⚡ Actions disponibles

pfSense propose trois actions principales pour chaque règle de filtrage.

### 1. Pass (Autoriser) ✅

**Comportement** : Autorise le trafic correspondant et crée une entrée dans la table d'états.

```
Action: Pass
Source: 192.168.1.0/24
Destination: Any
Port: 80, 443
→ Autorise le trafic web depuis le réseau local
```

**Caractéristiques** :

- Le trafic retour est automatiquement autorisé (stateful)
- Une entrée est créée dans la table d'états
- Le paquet continue son chemin vers la destination

> [!example] Cas d'usage typique Autoriser l'accès Internet depuis le LAN, permettre l'accès SSH à l'administration, ouvrir des services spécifiques.

### 2. Block (Bloquer silencieusement) 🚫

**Comportement** : Bloque le trafic sans envoyer de notification à l'émetteur.

```
Action: Block
Source: Any
Destination: 192.168.10.5 (DMZ server)
Port: 22
→ Bloque SSH vers le serveur DMZ sans réponse
```

**Caractéristiques** :

- Le paquet est jeté (dropped)
- Aucune réponse n'est envoyée à l'émetteur
- L'émetteur attend un timeout (effet : connexion qui "gèle")
- Économise de la bande passante
- Plus discret (ne révèle pas l'existence du pare-feu)

> [!tip] Quand utiliser Block
> 
> - Pour bloquer le trafic malveillant (scans de ports)
> - Quand vous ne voulez pas révéler la présence du pare-feu
> - Pour économiser des ressources (pas de réponse à générer)

### 3. Reject (Bloquer avec notification) ⛔

**Comportement** : Bloque le trafic et envoie une notification d'erreur à l'émetteur.

```
Action: Reject
Source: 192.168.1.0/24
Destination: 192.168.2.0/24 (réseau isolé)
Port: Any
→ Rejette le trafic avec un message TCP RST ou ICMP
```

**Caractéristiques** :

- Le paquet est jeté (dropped)
- Envoie un **TCP RST** (pour TCP) ou **ICMP Unreachable** (pour UDP/ICMP)
- L'émetteur reçoit immédiatement une erreur
- Plus rapide pour l'utilisateur (pas d'attente de timeout)
- Consomme légèrement plus de bande passante

> [!tip] Quand utiliser Reject
> 
> - Pour les utilisateurs internes (meilleure expérience)
> - Quand vous voulez un diagnostic rapide
> - Pour les services où un échec rapide est préférable à un timeout

### Comparaison des actions

|Action|Réponse émetteur|Discrétion|Performance|Usage typique|
|---|---|---|---|---|
|**Pass**|Trafic autorisé|N/A|Normale|Autoriser services|
|**Block**|Timeout (lent)|Maximum|Économique|Bloquer menaces externes|
|**Reject**|Erreur immédiate|Faible|Légèrement coûteux|Bloquer trafic interne|

> [!warning] Attention sécurité Utiliser **Reject** vers Internet peut révéler la présence de votre pare-feu et faciliter la reconnaissance réseau par un attaquant. Privilégiez **Block** pour le trafic WAN.

### Options avancées des actions

Chaque action peut être combinée avec :

- **Log** : Journaliser le trafic correspondant
- **Description** : Documenter la raison de la règle
- **Schedule** : Appliquer la règle selon un planning horaire
- **Gateway** : Forcer le routage via une passerelle spécifique
- **Advanced options** : Définir des options TCP, limiter les connexions, etc.

---

## 📊 États des connexions

### Table d'états (State Table)

La table d'états est le cœur du pare-feu stateful de pfSense. Elle maintient toutes les connexions actives traversant le pare-feu.

**Visualisation** : **Diagnostics > States** ou **Diagnostics > States Summary**

### Cycle de vie d'un état

```
1. NOUVELLE CONNEXION
   ↓
   Paquet SYN reçu → Évaluation règles → Pass → Création état
   
2. CONNEXION ÉTABLIE
   ↓
   État: ESTABLISHED → Paquets passent directement (bypass des règles)
   
3. FERMETURE CONNEXION
   ↓
   FIN/RST reçu → État: CLOSING → Suppression après timeout
   
4. TIMEOUT
   ↓
   Pas de trafic pendant X secondes → Suppression automatique
```

### États TCP typiques

|État|Signification|Durée de vie|
|---|---|---|
|**SYN_SENT**|Tentative de connexion initiée|Quelques secondes|
|**ESTABLISHED**|Connexion active et bidirectionnelle|Jusqu'à fermeture ou timeout|
|**FIN_WAIT**|Fermeture en cours|Quelques secondes|
|**TIME_WAIT**|Fermeture complète, attente sécurité|2 minutes (typique)|
|**CLOSED**|Connexion fermée|Supprimé immédiatement|

### Timeouts des états

pfSense maintient différents timeouts selon le type de trafic :

|Protocole/Type|Timeout par défaut|Configurable via|
|---|---|---|
|**TCP établi**|24 heures|Firewall > Advanced|
|**TCP opening**|30 secondes|Firewall > Advanced|
|**TCP closing**|15 secondes|Firewall > Advanced|
|**UDP premier paquet**|60 secondes|Firewall > Advanced|
|**UDP multiple**|60 secondes|Firewall > Advanced|
|**ICMP**|10 secondes|Firewall > Advanced|

> [!info] Configuration des timeouts Accessible via **System > Advanced > Firewall & NAT**. Ajustez selon vos besoins (applications longues, VoIP, etc.).

### Visualisation et gestion des états

**Commandes pour diagnostiquer** :

Depuis **Diagnostics > States** :

- Filtrer par IP, port, protocole
- Voir l'origine et la destination
- Identifier le nombre de connexions par hôte
- Supprimer manuellement des états bloqués

**Informations affichées** :

```
Interface  Proto  Source           Destination      State      Pkts  Bytes
WAN        tcp    203.0.113.45:443 192.168.1.10:54321  ESTABLISHED  1.2K  234K
LAN        udp    192.168.1.20:5060 203.0.113.100:5060  MULTIPLE     450   89K
```

> [!example] Cas pratique : Connexion bloquée **Problème** : Un utilisateur ne peut plus accéder à un service.
> 
> **Diagnostic** :
> 
> 1. Vérifier **Diagnostics > States** pour voir si un état existe
> 2. Si état bloqué ou corrompu → Supprimer l'état manuellement
> 3. L'utilisateur peut réessayer → Nouvel état créé
> 4. Si problème persiste → Vérifier les règles de pare-feu

### Limites de la table d'états

**Taille maximale** :

- Définie par la RAM disponible
- Par défaut : calcul automatique selon la mémoire
- Configurable dans **System > Advanced > Firewall & NAT**

**Monitoring** :

```
État actuel : 12,450 / 500,000 (2.5% utilisé)
```

> [!warning] Attention aux attaques Les attaques DDoS ou les scans de ports massifs peuvent saturer la table d'états. Surveillez via **Status > Dashboard** ou **Diagnostics > States Summary**.

### États et NAT

Lorsque le NAT est actif, chaque état contient également :

- L'adresse source originale (avant NAT)
- L'adresse source après NAT (IP publique)
- Les ports traduits
- La direction du NAT

Cela permet au pare-feu de modifier correctement les paquets retour.

---

## ✅ Bonnes pratiques

### Organisation des règles

> [!tip] Règle d'or **Documentez chaque règle** avec une description claire. Dans 6 mois, vous aurez oublié pourquoi cette règle existe.

1. **Nommage cohérent** :
    
    ```
    ✅ "Allow_LAN_to_Internet_HTTP_HTTPS"
    ✅ "Block_DMZ_to_LAN_All"
    ❌ "Règle 1"
    ❌ "Test"
    ```
    
2. **Regroupement logique** :
    
    - Blocages spécifiques en haut
    - Autorisations par service (Web, Mail, VPN, etc.)
    - Règles générales en bas
3. **Désactivation plutôt que suppression** :
    
    - Utilisez le bouton "Disable" au lieu de supprimer
    - Permet de réactiver rapidement en cas de problème
    - Conserve l'historique

### Sécurité

> [!warning] Principe de moindre privilège N'autorisez que le strict nécessaire. Une règle "Allow Any → Any" est presque toujours une erreur.

1. **Spécificité maximale** :
    
    ```
    ❌ Source: Any, Destination: Any, Port: Any
    ✅ Source: 192.168.1.10, Destination: 203.0.113.5, Port: 443
    ```
    
2. **Logging stratégique** :
    
    - Activez le log sur les règles de blocage importantes
    - Loguez les accès critiques (admin, bases de données)
    - Attention : trop de logs = performances réduites
3. **Révision régulière** :
    
    - Auditez vos règles tous les 3-6 mois
    - Supprimez les règles obsolètes
    - Testez la désactivation de règles suspectes

### Performance

1. **Ordre optimal** :
    
    - Règles les plus utilisées en haut
    - Évite l'évaluation inutile de nombreuses règles
2. **Limitation des états** :
    
    - Configurez des limites par IP/sous-réseau
    - Protège contre l'épuisement de la table d'états
3. **Utilisation des alias** :
    
    - Regroupez les IPs, réseaux ou ports similaires
    - Facilite la maintenance et améliore la lisibilité

### Debugging et troubleshooting

> [!example] Méthodologie de diagnostic
> 
> 1. **Vérifier les logs** : Firewall > Log Files > Firewall
> 2. **Activer le log** sur la règle suspecte temporairement
> 3. **Packet Capture** : Diagnostics > Packet Capture pour analyser le trafic
> 4. **States Table** : Vérifier si un état existe et son statut
> 5. **Test progressif** : Désactiver/activer les règles une par une

**Outils de diagnostic** :

- **Firewall Logs** : Voir les blocages en temps réel
- **Packet Capture** : Analyse détaillée du trafic
- **States Diagnostics** : État des connexions
- **pfTop** : Vue en temps réel des états (ligne de commande)

### Sauvegarde et versioning

1. **Backup automatique** :
    
    - pfSense sauvegarde automatiquement à chaque modification
    - Accessible via **Diagnostics > Backup & Restore**
2. **Export manuel** :
    
    - Exportez la config avant modifications importantes
    - Gardez des versions datées
3. **Config History** :
    
    - Consultez l'historique : **Diagnostics > Backup & Restore > Config History**
    - Restaurez une version antérieure si besoin

---

## 🎓 Récapitulatif

Le pare-feu pfSense repose sur des principes simples mais puissants :

1. **Stateful par défaut** : Suivi intelligent des connexions, pas de règles retour nécessaires
2. **First Match Wins** : Ordre des règles crucial, du spécifique au général
3. **Trois actions** : Pass (autorise), Block (bloque silencieusement), Reject (bloque avec notification)
4. **Table d'états** : Cœur du système, maintient toutes les connexions actives avec timeouts configurables

> [!tip] Philosophie de configuration
> 
> - **Deny all, permit by exception** : Tout bloqué par défaut
> - **Spécificité maximale** : Règles les plus précises possible
> - **Documentation systématique** : Chaque règle doit être compréhensible
> - **Audit régulier** : Nettoyage et optimisation périodiques

La maîtrise de ces principes fondamentaux est essentielle pour construire un pare-feu efficace et maintenable.