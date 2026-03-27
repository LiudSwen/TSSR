

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

## 🚀 Activation du protocole

### Pourquoi activer RIPv2 ?

RIPv2 est une amélioration de RIPv1 qui apporte :

- Support du **VLSM** (Variable Length Subnet Mask)
- Support du **CIDR** (Classless Inter-Domain Routing)
- **Authentification** possible
- Utilisation du **multicast** (224.0.0.9) au lieu du broadcast

> [!info] Différence RIPv1 vs RIPv2 RIPv1 envoie les mises à jour en broadcast et ne supporte pas les masques de sous-réseau. RIPv2 corrige ces limitations et est donc préféré dans les réseaux modernes.

### Configuration de base

```bash
Router(config)# router rip
Router(config-router)# version 2
```

> [!warning] Attention à la version Sans la commande `version 2`, le routeur peut fonctionner en mode de compatibilité et envoyer/recevoir à la fois RIPv1 et RIPv2, ce qui peut causer des problèmes de convergence.

### Vérification de l'activation

```bash
Router# show ip protocols
```

**Sortie attendue :**

```
Routing Protocol is "rip"
  Outgoing update filter list for all interfaces is not set
  Incoming update filter list for all interfaces is not set
  Sending updates every 30 seconds
  Invalid after 180 seconds, hold down 180, flushed after 240
  Redistributing: rip
  Default version control: send version 2, receive version 2
```

> [!tip] Astuce de vérification La ligne `Default version control: send version 2, receive version 2` confirme que RIPv2 est bien activé. Si vous voyez "version 1 and 2", votre configuration n'est pas complète.

---

## 📢 Annonce des réseaux

### Concept fondamental

Dans RIP, vous devez **déclarer les réseaux directement connectés** que vous souhaitez annoncer aux autres routeurs. RIP annoncera alors toutes les routes qu'il connaît sur ces interfaces.

> [!info] Philosophie RIP Contrairement à OSPF où vous spécifiez les interfaces, avec RIP vous spécifiez les **réseaux classful** (classe A, B ou C). RIP activera automatiquement le protocole sur toutes les interfaces appartenant à ces réseaux.

### Syntaxe de base

```bash
Router(config)# router rip
Router(config-router)# network [adresse-reseau-classful]
```

### Exemple pratique

Supposons un routeur avec les interfaces suivantes :

- **Gi0/0** : 192.168.1.1/24
- **Gi0/1** : 10.0.1.1/24
- **Gi0/2** : 172.16.50.1/25

```bash
Router(config)# router rip
Router(config-router)# version 2
Router(config-router)# network 192.168.1.0
Router(config-router)# network 10.0.0.0
Router(config-router)# network 172.16.0.0
```

> [!warning] Adresses classful uniquement RIP accepte uniquement les adresses de **réseau classful** dans la commande `network` :
> 
> - Classe A : X.0.0.0
> - Classe B : X.X.0.0
> - Classe C : X.X.X.0
> 
> Même si vous tapez `network 10.0.1.0`, IOS le convertira automatiquement en `network 10.0.0.0`.

### Vérification des annonces

```bash
Router# show ip protocols
```

Vous verrez :

```
Routing for Networks:
  10.0.0.0
  172.16.0.0
  192.168.1.0
```

Pour voir les routes apprises :

```bash
Router# show ip route rip
```

> [!example] Exemple de sortie
> 
> ```
> R    192.168.2.0/24 [120/1] via 192.168.1.2, 00:00:15, GigabitEthernet0/0
> R    10.0.2.0/24 [120/2] via 192.168.1.2, 00:00:15, GigabitEthernet0/0
> ```
> 
> Le **[120/1]** indique : distance administrative 120, métrique 1 (1 saut).

### Pièges courants

|Problème|Cause|Solution|
|---|---|---|
|Réseau non annoncé|Oubli de la commande `network`|Vérifier avec `show ip protocols`|
|Annonces partielles|Version RIP mixte (v1/v2)|Forcer `version 2`|
|Réseau mal spécifié|Utilisation d'une adresse non classful|Utiliser l'adresse classful correcte|

> [!tip] Bonne pratique Documentez toujours vos réseaux annoncés. Dans un environnement de production, utilisez des commentaires :
> 
> ```bash
> ! Reseau LAN principal
> network 192.168.1.0
> ! Reseau datacenter
> network 10.0.0.0
> ```

---

## 🔇 Configuration des interfaces passives

### Pourquoi utiliser des interfaces passives ?

Une interface passive dans RIP est une interface qui :

- ✅ **Reçoit** les mises à jour RIP
- ✅ **Annonce** son réseau aux autres routeurs
- ❌ **N'envoie pas** de mises à jour RIP

### Cas d'usage typiques

1. **Interfaces connectées aux utilisateurs finaux** : Aucun routeur ne doit recevoir les mises à jour RIP
2. **Sécurité** : Éviter que des informations de routage soient diffusées sur des réseaux non sécurisés
3. **Performance** : Réduire le trafic inutile sur des liens où aucun routeur n'écoute

> [!warning] Sécurité critique Ne jamais envoyer de mises à jour RIP vers des réseaux publics ou non contrôlés. Un attaquant pourrait injecter de fausses routes !

### Configuration par interface

```bash
Router(config)# router rip
Router(config-router)# passive-interface GigabitEthernet0/0
```

**Exemple complet :**

```bash
Router(config)# router rip
Router(config-router)# version 2
Router(config-router)# network 192.168.1.0
Router(config-router)# network 10.0.0.0
Router(config-router)# passive-interface GigabitEthernet0/2  ! Interface LAN utilisateurs
```

### Configuration globale (toutes interfaces passives par défaut)

Dans de nombreux cas, il est plus efficace de rendre **toutes les interfaces passives par défaut**, puis d'activer explicitement RIP sur les interfaces de routage.

```bash
Router(config)# router rip
Router(config-router)# passive-interface default
Router(config-router)# no passive-interface GigabitEthernet0/0  ! Vers autre routeur
Router(config-router)# no passive-interface GigabitEthernet0/1  ! Vers autre routeur
```

> [!tip] Meilleure pratique La méthode `passive-interface default` est recommandée dans les environnements de production. C'est une approche de sécurité "deny all, permit specific" qui est plus sûre.

### Vérification

```bash
Router# show ip protocols
```

**Sortie avec interfaces passives :**

```
Routing Protocol is "rip"
  ...
  Passive Interface(s):
    GigabitEthernet0/2
  Routing for Networks:
    192.168.1.0
    10.0.0.0
```

### Tableau comparatif

|Configuration|Avantages|Inconvénients|Cas d'usage|
|---|---|---|---|
|Interface par interface|Contrôle précis|Fastidieux si beaucoup d'interfaces|Petits réseaux, peu d'interfaces|
|`passive-interface default`|Sécurisé par défaut, moins d'erreurs|Nécessite de débloquer les interfaces de routage|Réseaux moyens à grands, production|

> [!example] Scénario réel Routeur de bordure avec :
> 
> - 1 interface WAN vers Internet
> - 1 interface vers le cœur de réseau (autre routeur)
> - 8 interfaces LAN vers utilisateurs
> 
> **Configuration optimale :**
> 
> ```bash
> router rip
>  version 2
>  passive-interface default
>  no passive-interface GigabitEthernet0/0  ! Vers coeur
>  network 192.168.0.0
>  network 10.0.0.0
> ```

---

## 📦 Résumé automatique et manuel

### Résumé automatique (Auto-Summary)

#### Qu'est-ce que c'est ?

Le résumé automatique (auto-summary) est un mécanisme **hérité de RIPv1** qui agrège automatiquement les routes aux **limites de classes** (A, B, C).

> [!warning] Comportement par défaut changeant
> 
> - Avant IOS 12.3 : Auto-summary **activé** par défaut
> - Depuis IOS 15.0+ : Auto-summary **désactivé** par défaut
> 
> Toujours vérifier votre configuration !

#### Problématique

Avec l'auto-summary activé :

- Le réseau **10.1.1.0/24** devient **10.0.0.0/8**
- Le réseau **172.16.50.0/25** devient **172.16.0.0/16**
- Le réseau **192.168.1.0/24** devient **192.168.1.0/24** (déjà classful)

**Conséquences :**

```
❌ Perte de précision
❌ Problèmes avec les réseaux discontigus
❌ Boucles de routage potentielles
```

> [!info] Réseaux discontigus Un réseau discontigu est un réseau de classe A, B ou C séparé par un autre réseau. Exemple :
> 
> - Routeur1 : 10.1.0.0/24
> - Routeur2 : 172.16.0.0/16 (entre les deux)
> - Routeur3 : 10.2.0.0/24
> 
> Avec auto-summary, les deux routeurs annoncent 10.0.0.0/8, créant de l'ambiguïté !

#### Désactivation (recommandé)

```bash
Router(config)# router rip
Router(config-router)# no auto-summary
```

#### Vérification

```bash
Router# show ip protocols
```

Recherchez la ligne :

```
Automatic network summarization is not in effect
```

> [!tip] Bonne pratique moderne **Toujours désactiver l'auto-summary dans RIPv2** sauf si vous avez un cas d'usage très spécifique avec un réseau classful pur (très rare aujourd'hui).

### Résumé manuel (Manual Summarization)

#### Concept

Le résumé manuel permet de créer des **routes agrégées personnalisées** pour réduire la taille de la table de routage et optimiser l'utilisation de la bande passante.

#### Configuration

```bash
Router(config)# interface GigabitEthernet0/0
Router(config-if)# ip summary-address rip [adresse-reseau] [masque]
```

#### Exemple pratique

Supposons que vous avez plusieurs sous-réseaux :

- 192.168.1.0/24
- 192.168.2.0/24
- 192.168.3.0/24
- 192.168.4.0/24

Au lieu d'annoncer 4 routes, vous pouvez les résumer en **192.168.0.0/22** (contient de 192.168.0.0 à 192.168.3.255) ou **192.168.0.0/21** (contient de 192.168.0.0 à 192.168.7.255).

```bash
Router(config)# interface GigabitEthernet0/0
Router(config-if)# ip summary-address rip 192.168.0.0 255.255.252.0
```

> [!info] Calcul du masque de résumé Pour résumer 192.168.1.0 à 192.168.4.0 :
> 
> 1. Convertir en binaire les octets qui changent : 1, 2, 3, 4
> 2. Trouver le bit commun le plus à gauche
> 3. Utiliser /22 (255.255.252.0) qui couvre 192.168.0.0 à 192.168.3.255
> 
> Pour inclure jusqu'à 192.168.4.0, utiliser /21 qui couvre jusqu'à 192.168.7.255

#### Avantages du résumé manuel

|Avantage|Description|
|---|---|
|📉 Réduction de la table|Moins d'entrées dans la table de routage|
|🚀 Convergence plus rapide|Moins de routes à recalculer|
|💾 Économie de bande passante|Mises à jour plus petites|
|🔒 Isolation des pannes|Les changements dans un sous-réseau n'affectent pas le résumé|

> [!warning] Attention aux routes plus spécifiques Si vous résumez 192.168.0.0/22 mais qu'un routeur a aussi une route spécifique 192.168.1.0/24, la **route la plus spécifique l'emporte** (longest prefix match). Assurez-vous que votre résumé est cohérent !

#### Vérification

```bash
Router# show ip route
```

Vous devriez voir la route résumée :

```
R    192.168.0.0/22 [120/1] via 10.0.0.2, 00:00:12, GigabitEthernet0/0
```

Sur le routeur qui fait le résumé :

```bash
Router# show ip interface GigabitEthernet0/0
```

### Comparaison auto-summary vs manual summary

|Critère|Auto-summary|Manual summary|
|---|---|---|
|**Activation**|`auto-summary` (à éviter)|`ip summary-address rip`|
|**Granularité**|Classe A/B/C uniquement|N'importe quel masque CIDR|
|**Contrôle**|Aucun|Total|
|**Utilisation moderne**|Déconseillé|Recommandé si nécessaire|
|**Application**|Automatique aux limites de classe|Par interface|

> [!tip] Quand utiliser le résumé manuel ?
> 
> - Réseaux de grande taille avec hiérarchie claire
> - Lorsque vous avez de nombreux sous-réseaux contigus
> - Pour optimiser les performances dans des environnements avec bande passante limitée
> - **Jamais** dans les petits réseaux (overhead de configuration > bénéfice)

---

## 🔐 Authentication

### Pourquoi authentifier RIP ?

L'authentification RIP permet de :

- ✅ **Sécuriser** les échanges de mises à jour de routage
- ✅ **Prévenir** l'injection de routes malveillantes
- ✅ **Valider** que les mises à jour proviennent de sources légitimes

> [!warning] Risque sans authentification Sans authentification, n'importe quel équipement peut envoyer des mises à jour RIP et :
> 
> - Détourner le trafic (attaque man-in-the-middle)
> - Créer des trous noirs (black holes)
> - Provoquer un déni de service en surchargeant la table de routage

### Types d'authentification

RIPv2 supporte deux types d'authentification :

|Type|Sécurité|Description|
|---|---|---|
|**Plain text**|❌ Faible|Mot de passe en clair dans les paquets|
|**MD5**|✅ Forte|Hachage MD5 du mot de passe|

> [!info] Recommandation **Toujours utiliser MD5** en production. L'authentification plain text n'offre qu'une protection minime contre les erreurs de configuration, mais pas contre les attaques.

### Configuration de l'authentification

#### Étape 1 : Créer le keychain

Un keychain est un conteneur pour les clés d'authentification.

```bash
Router(config)# key chain NOM-KEYCHAIN
Router(config-keychain)# key NUMERO-CLE
Router(config-keychain-key)# key-string MOT-DE-PASSE
```

**Exemple :**

```bash
Router(config)# key chain RIP-AUTH
Router(config-keychain)# key 1
Router(config-keychain-key)# key-string Cisco123!
```

> [!tip] Numérotation des clés Le numéro de clé (1 dans l'exemple) permet d'avoir plusieurs clés actives en même temps, utile pour la rotation des mots de passe sans interruption de service.

#### Étape 2 : Appliquer l'authentification sur l'interface

```bash
Router(config)# interface GigabitEthernet0/0
Router(config-if)# ip rip authentication mode md5
Router(config-if)# ip rip authentication key-chain RIP-AUTH
```

### Configuration complète - Exemple

**Routeur 1 :**

```bash
R1(config)# key chain RIP-AUTH
R1(config-keychain)# key 1
R1(config-keychain-key)# key-string SecurePass2024
R1(config-keychain-key)# exit
R1(config)# interface GigabitEthernet0/0
R1(config-if)# ip rip authentication mode md5
R1(config-if)# ip rip authentication key-chain RIP-AUTH
```

**Routeur 2 (même configuration) :**

```bash
R2(config)# key chain RIP-AUTH
R2(config-keychain)# key 1
R2(config-keychain-key)# key-string SecurePass2024
R2(config-keychain-key)# exit
R2(config)# interface GigabitEthernet0/0
R2(config-if)# ip rip authentication mode md5
R2(config-if)# ip rip authentication key-chain RIP-AUTH
```

> [!warning] Synchronisation obligatoire
> 
> - Le **nom du keychain** peut être différent entre routeurs
> - Le **numéro de clé** doit être identique
> - Le **mot de passe** (key-string) doit être **strictement identique**
> - Le **mode d'authentification** (md5) doit être identique
> 
> Toute différence empêchera l'établissement de la relation de voisinage !

### Authentification en texte clair (à éviter)

Pour référence uniquement (ne pas utiliser en production) :

```bash
Router(config)# key chain RIP-AUTH
Router(config-keychain)# key 1
Router(config-keychain-key)# key-string MonMotDePasse
Router(config-keychain-key)# exit
Router(config)# interface GigabitEthernet0/0
Router(config-if)# ip rip authentication mode text
Router(config-if)# ip rip authentication key-chain RIP-AUTH
```

> [!warning] Danger du mode text Le mot de passe est visible en clair avec Wireshark ou tout autre analyseur de paquets. À réserver uniquement aux environnements de test !

### Rotation des clés (Avancé)

Pour changer de mot de passe sans interruption :

#### Étape 1 : Ajouter une nouvelle clé

```bash
Router(config)# key chain RIP-AUTH
Router(config-keychain)# key 2
Router(config-keychain-key)# key-string NewSecurePass2025
Router(config-keychain-key)# accept-lifetime 00:00:00 Jan 1 2025 infinite
Router(config-keychain-key)# send-lifetime 00:00:00 Jan 15 2025 infinite
```

#### Étape 2 : Déployer sur tous les routeurs

Configurez la clé 2 sur tous les routeurs du domaine RIP.

#### Étape 3 : Supprimer l'ancienne clé

Après que la nouvelle clé est active partout :

```bash
Router(config)# key chain RIP-AUTH
Router(config-keychain)# no key 1
```

> [!tip] Planification de la rotation Utilisez `accept-lifetime` et `send-lifetime` pour automatiser le basculement :
> 
> - **accept-lifetime** : Quand le routeur accepte cette clé en réception
> - **send-lifetime** : Quand le routeur utilise cette clé en émission
> 
> Cela permet une transition en douceur !

### Vérification de l'authentification

```bash
Router# show ip rip database
```

Aucune erreur ne doit apparaître. Si l'authentification échoue, vous verrez :

```
%RIP-4-AUTHENTICATION: RIPv2 Authentication failed from 10.0.0.2
```

Vérifier la configuration :

```bash
Router# show key chain
```

**Sortie attendue :**

```
Key-chain RIP-AUTH:
  key 1 -- text "SecurePass2024"
    accept lifetime (always valid) - (always valid) [valid now]
    send lifetime (always valid) - (always valid) [valid now]
```

### Dépannage de l'authentification

|Symptôme|Cause probable|Solution|
|---|---|---|
|Routes RIP disparues|Mot de passe différent|Vérifier avec `show key chain`|
|Message d'erreur AUTH|Mode différent (text vs md5)|Synchroniser le mode|
|Intermittence|Problème de lifetime|Vérifier les accept/send-lifetime|
|Routes partielles|Authentication sur certaines interfaces seulement|Appliquer sur toutes les interfaces RIP|

> [!example] Erreur courante
> 
> ```bash
> ! Routeur 1
> key-string SecurePass2024
> 
> ! Routeur 2
> key-string Securepass2024  ! 'p' minuscule -> ERREUR !
> ```
> 
> Les mots de passe sont **sensibles à la casse** !

### Bonnes pratiques de sécurité

1. ✅ **Toujours utiliser MD5**, jamais plain text en production
2. ✅ **Documenter** les mots de passe dans un gestionnaire sécurisé (Vault, KeePass)
3. ✅ **Rotation régulière** des clés (tous les 6-12 mois)
4. ✅ **Mots de passe complexes** : minimum 12 caractères, alphanumériques + symboles
5. ✅ **Activer sur toutes les interfaces** participant à RIP
6. ✅ **Tester** après chaque changement de configuration

> [!tip] Astuce de production Créez un mot de passe unique par domaine RIP et utilisez un préfixe identifiable :
> 
> ```
> RIP-SITE-PARIS-2024-xK9#mP2$
> RIP-SITE-LYON-2024-aL7@qR5&
> ```
> 
> Cela facilite la gestion multi-sites.

---

## 🎯 Résumé de la configuration complète

Voici une configuration complète de RIPv2 intégrant tous les concepts vus :

```bash
! === Configuration RIPv2 complete ===

! Keychains pour authentification
key chain RIP-SECURE
 key 1
  key-string MyStrongP@ssw0rd2024

! Configuration RIP
router rip
 version 2
 ! Desactiver le resume automatique
 no auto-summary
 ! Rendre toutes les interfaces passives par defaut
 passive-interface default
 ! Activer RIP uniquement sur les interfaces de routage
 no passive-interface GigabitEthernet0/0
 no passive-interface GigabitEthernet0/1
 ! Annoncer les reseaux
 network 192.168.1.0
 network 10.0.0.0
 network 172.16.0.0

! Configuration des interfaces
interface GigabitEthernet0/0
 description ** Vers Routeur R2 **
 ip address 10.0.0.1 255.255.255.252
 ! Authentification MD5
 ip rip authentication mode md5
 ip rip authentication key-chain RIP-SECURE
 ! Resume manuel si necessaire
 ip summary-address rip 192.168.0.0 255.255.252.0

interface GigabitEthernet0/1
 description ** Vers Routeur R3 **
 ip address 10.0.0.5 255.255.255.252
 ip rip authentication mode md5
 ip rip authentication key-chain RIP-SECURE

interface GigabitEthernet0/2
 description ** LAN Utilisateurs **
 ip address 192.168.1.1 255.255.255.0
 ! Interface passive (deja defini globalement)
```

> [!tip] Checklist de déploiement Avant de valider votre configuration :
> 
> - [ ] RIP version 2 activée
> - [ ] Auto-summary désactivé
> - [ ] Tous les réseaux annoncés avec `network`
> - [ ] Interfaces LAN en mode passif
> - [ ] Authentification MD5 configurée sur toutes les interfaces de routage
> - [ ] Mots de passe documentés en lieu sûr
> - [ ] Tests de connectivité effectués
> - [ ] Vérification avec `show ip protocols` et `show ip route rip`

---

**📚 Fin du cours sur la Configuration RIPv2**