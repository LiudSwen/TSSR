

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

## 🎯 Vue d'ensemble

La comparaison des différents types de NAT est cruciale pour choisir la solution adaptée à votre infrastructure. Chaque type présente des caractéristiques spécifiques qui influencent la sécurité, la scalabilité et les coûts.

> [!info] Les trois types principaux
> 
> - **Static NAT (1:1)** : Mappage permanent entre une IP privée et une IP publique
> - **Dynamic NAT (N:N)** : Attribution dynamique d'IPs publiques depuis un pool
> - **PAT/NAT Overload (N:1)** : Plusieurs IPs privées partagent une seule IP publique via les ports

---

## ⚖️ Avantages et inconvénients

### Static NAT (1:1)

#### ✅ Avantages

- **Accessibilité constante** : L'IP publique reste toujours la même pour l'hôte
- **Services hébergés** : Idéal pour les serveurs accessibles depuis Internet
- **Traçabilité** : Facilite les logs et l'audit (correspondance fixe)
- **Reverse DNS** : Configuration simplifiée pour les enregistrements PTR
- **Aucune limitation de ports** : Tous les ports sont accessibles
- **Bidirectionnel natif** : Les connexions entrantes et sortantes fonctionnent naturellement

#### ❌ Inconvénients

- **Coût élevé** : Nécessite une IP publique par hôte interne
- **Gaspillage d'adresses** : Utilise des IPs publiques même si l'hôte est inactif
- **Non scalable** : Limité par le nombre d'IPs publiques disponibles
- **Gestion manuelle** : Configuration individuelle pour chaque mappage
- **Sécurité limitée** : Exposition directe des hôtes (pas de masquage)

> [!warning] Utilisation des IPs publiques Avec l'épuisement des adresses IPv4, le Static NAT est coûteux et doit être réservé aux cas où il est vraiment nécessaire.

---

### Dynamic NAT (N:N)

#### ✅ Avantages

- **Flexibilité** : Attribution automatique des IPs publiques
- **Économie relative** : Moins d'IPs publiques que d'hôtes internes
- **Simplicité d'administration** : Gestion par pool plutôt qu'individuelle
- **Tous les ports disponibles** : Pas de contrainte de port
- **Adapté aux pics de charge** : Gère les variations de trafic

#### ❌ Inconvénients

- **Coût encore élevé** : Nécessite plusieurs IPs publiques
- **Non prédictible** : L'IP publique change à chaque nouvelle connexion
- **Problème de saturation** : Si le pool est épuisé, les nouveaux flux échouent
- **Incompatible avec les services** : Impossible d'héberger des serveurs accessibles
- **Complexité des logs** : Difficulté à tracer les connexions dans le temps
- **Pas de connexions entrantes** : Seules les connexions sortantes sont possibles

> [!example] Cas typique de saturation Pool de 10 IPs publiques pour 100 utilisateurs : si 10 utilisateurs maintiennent des connexions longues (VPN, streaming), les autres sont bloqués.

---

### PAT / NAT Overload (N:1)

#### ✅ Avantages

- **Économie maximale** : Une seule IP publique pour des milliers d'hôtes
- **Scalabilité** : Théoriquement jusqu'à 65 535 connexions simultanées
- **Sécurité renforcée** : Masquage complet du réseau interne
- **Standard actuel** : Solution la plus répandue dans le monde
- **Simple à déployer** : Configuration minimale requise
- **Faible coût** : Optimal pour l'utilisation des ressources

#### ❌ Inconvénients

- **Incompatible avec certains protocoles** : FTP, SIP, H.323 nécessitent des ALG
- **Connexions entrantes bloquées** : Nécessite du port forwarding manuel
- **Limite de ports** : Épuisement possible en cas de très forte charge
- **Traçabilité complexe** : Logs nécessitant IP + port + timestamp
- **Problèmes avec les applications P2P** : NAT traversal requis
- **Latence ajoutée** : Traitement de la table de traduction

> [!tip] Optimisation PAT Activez les timeouts agressifs pour les connexions TCP et UDP inactives afin de libérer rapidement les entrées de la table NAT.

---

## 🎯 Choix selon le contexte

### Cas d'usage : Static NAT

**Quand l'utiliser ?**

- Serveurs web, mail, DNS accessibles depuis Internet
- Équipements nécessitant une IP publique fixe (caméras, VPN)
- Applications nécessitant un reverse DNS stable
- Conformité réglementaire exigeant une traçabilité stricte
- Services bancaires ou financiers avec whitelisting IP

**Configuration type :**

```bash
# Serveur web public
ip nat inside source static 192.168.1.10 203.0.113.5

# Serveur mail
ip nat inside source static 192.168.1.20 203.0.113.6

# Serveur VPN
ip nat inside source static 192.168.1.30 203.0.113.7
```

> [!example] Exemple concret Une entreprise héberge 3 serveurs (web, mail, FTP) nécessitant un accès public permanent. Static NAT est le choix optimal malgré le coût de 3 IPs publiques.

---

### Cas d'usage : Dynamic NAT

**Quand l'utiliser ?**

- PME avec trafic sortant modéré
- Laboratoires de test nécessitant des IPs publiques temporaires
- Environnements où les IPs publiques sont disponibles mais limitées
- Transition vers PAT (phase intermédiaire)
- Besoins de tous les ports sans prévisibilité d'IP

**Configuration type :**

```bash
# Définir le pool d'IPs publiques
ip nat pool PUBLIC_POOL 203.0.113.10 203.0.113.20 netmask 255.255.255.0

# ACL pour le trafic à traduire
access-list 10 permit 192.168.0.0 0.0.255.255

# Appliquer le Dynamic NAT
ip nat inside source list 10 pool PUBLIC_POOL
```

> [!warning] Attention au dimensionnement Dimensionnez le pool en fonction du nombre de connexions simultanées **réelles**, pas du nombre total d'hôtes. Un ratio de 1:10 est souvent suffisant.

---

### Cas d'usage : PAT (NAT Overload)

**Quand l'utiliser ?**

- Réseaux domestiques et SOHO
- Entreprises avec forte population d'utilisateurs
- Environnements où une seule IP publique est disponible
- Situations où la sécurité par obscurité est un plus
- Tout contexte nécessitant une économie d'IPs publiques

**Configuration type :**

```bash
# PAT avec interface externe
access-list 1 permit 192.168.0.0 0.0.255.255
ip nat inside source list 1 interface GigabitEthernet0/1 overload

# OU PAT avec IP spécifique
ip nat inside source list 1 pool PAT_POOL overload
ip nat pool PAT_POOL 203.0.113.50 203.0.113.50 netmask 255.255.255.255
```

> [!tip] Best practice Préférez l'utilisation d'un pool avec une IP plutôt que directement l'interface pour plus de flexibilité en cas de changement d'interface.

---

## 📊 Tableau comparatif détaillé

|Critère|Static NAT|Dynamic NAT|PAT (Overload)|
|---|---|---|---|
|**Ratio IP publique/privée**|1:1|N:N (N < Total hôtes)|N:1|
|**Nombre d'IPs publiques**|Élevé|Moyen|Minimal (1+)|
|**Coût**|💰💰💰|💰💰|💰|
|**Scalabilité**|⭐ Faible|⭐⭐ Moyenne|⭐⭐⭐ Excellente|
|**Connexions entrantes**|✅ Oui (natives)|❌ Non|❌ Non (sauf port forwarding)|
|**Connexions sortantes**|✅ Oui|✅ Oui|✅ Oui|
|**Hébergement de services**|✅ Idéal|❌ Impossible|⚠️ Possible (port forwarding)|
|**Prévisibilité IP**|✅ Totale|❌ Aucune|❌ Aucune|
|**Sécurité (masquage)**|⭐ Faible|⭐⭐ Moyenne|⭐⭐⭐ Élevée|
|**Complexité configuration**|⭐⭐⭐ Manuelle|⭐⭐ Automatisée|⭐ Simple|
|**Limite de connexions**|Aucune|Pool exhaustible|~65k par IP|
|**Traçabilité logs**|✅ Simple|⚠️ Complexe|⚠️ Très complexe|
|**Compatibilité protocoles**|✅ Totale|✅ Totale|⚠️ ALG requis|
|**Usage CPU/mémoire**|⭐ Faible|⭐⭐ Moyen|⭐⭐⭐ Élevé|
|**Cas d'usage principal**|Serveurs publics|Trafic sortant PME|Accès Internet général|

---

## 🚨 Pièges courants

### Piège 1 : Sous-estimer les besoins en ports (PAT)

**Problème :**

```bash
# Configuration PAT basique
ip nat inside source list 1 interface Gi0/1 overload
```

En forte charge, certaines applications (notamment P2P, multiplexage HTTP/2) peuvent consommer des milliers de ports par utilisateur.

**Solution :**

- Monitorer les entrées de table NAT : `show ip nat statistics`
- Augmenter les timeouts uniquement si nécessaire
- Considérer plusieurs IPs publiques en PAT si le trafic dépasse 40 000 connexions simultanées

---

### Piège 2 : Oublier les ACL restrictives

**Problème :**

```bash
# Trop permissif !
access-list 1 permit any
ip nat inside source list 1 pool PUBLIC_POOL
```

Cela permet à tout trafic de consommer le pool NAT, y compris le trafic de gestion.

**Solution :**

```bash
# Restreindre aux réseaux utilisateurs seulement
access-list 1 deny   10.0.0.0 0.0.0.255      # Réseau de gestion
access-list 1 permit 192.168.0.0 0.0.255.255 # Réseaux utilisateurs
access-list 1 deny   any
```

---

### Piège 3 : Mélanger les types de NAT

**Problème :** Utiliser Static NAT et Dynamic NAT sur les mêmes IPs publiques crée des conflits.

```bash
# ERREUR : Conflit d'IPs
ip nat inside source static 192.168.1.10 203.0.113.5
ip nat pool DYN_POOL 203.0.113.1 203.0.113.10 netmask 255.255.255.0
```

**Solution :** Segmenter clairement les plages d'IPs publiques :

```bash
# IPs 1-5 : Static NAT
# IPs 10-20 : Dynamic NAT
ip nat inside source static 192.168.1.10 203.0.113.5
ip nat pool DYN_POOL 203.0.113.10 203.0.113.20 netmask 255.255.255.0
```

---

### Piège 4 : Ignorer l'épuisement du pool (Dynamic NAT)

**Problème :**

```bash
# Pool trop petit pour la charge
ip nat pool SMALL_POOL 203.0.113.10 203.0.113.12 netmask 255.255.255.0
```

3 IPs pour 100 utilisateurs = saturation rapide.

**Solution :**

- Analyser les statistiques : `show ip nat statistics`
- Dimensionner selon les connexions simultanées réelles (pas le nombre d'utilisateurs)
- Implémenter des timeouts agressifs : `ip nat translation timeout 300`

---

### Piège 5 : Négliger les logs en PAT

**Problème :** En PAT, un simple log IP est insuffisant pour identifier un utilisateur.

```
2025-12-17 10:30:15 203.0.113.50 accessed malicious-site.com
```

Impossible de savoir quel utilisateur interne est concerné !

**Solution :** Activer le logging NAT avec ports et timestamps :

```bash
ip nat log translations syslog
```

Log complet :

```
2025-12-17 10:30:15 NAT: s=192.168.1.45:52341 -> 203.0.113.50:52341, d=93.184.216.34:80
```

---

## 💡 Astuces professionnelles

### Astuce 1 : Combiner les types intelligemment

```bash
# Static NAT pour les serveurs critiques
ip nat inside source static 192.168.1.10 203.0.113.5

# PAT pour les utilisateurs
access-list 100 deny   ip host 192.168.1.10 any  # Exclure le serveur
access-list 100 permit ip 192.168.0.0 0.0.255.255 any
ip nat inside source list 100 interface Gi0/1 overload
```

Cette combinaison optimise coûts et fonctionnalités.

---

### Astuce 2 : Répartir la charge PAT

Pour les très gros volumes, utilisez plusieurs IPs publiques en PAT :

```bash
# Pool de 4 IPs pour PAT
ip nat pool PAT_MULTI 203.0.113.50 203.0.113.53 netmask 255.255.255.0
ip nat inside source list 1 pool PAT_MULTI overload
```

Avantage : 4 × 65 535 = ~262 000 connexions possibles.

---

### Astuce 3 : Monitoring proactif

```bash
# Créer un script de surveillance
show ip nat statistics | include translations
show ip nat translations total

# Alerter si > 80% de la capacité
# Pour PAT : > 52 000 connexions
# Pour Dynamic NAT : > 80% du pool
```

---

### Astuce 4 : Documentation des mappings

Maintenez une documentation claire des mappings Static NAT :

```bash
# Dans les commentaires de configuration
ip nat inside source static 192.168.1.10 203.0.113.5
! WEB-SERVER-01 - Production - Contact: admin@company.com

ip nat inside source static 192.168.1.20 203.0.113.6
! MAIL-SERVER - Exchange 2019 - Contact: it@company.com
```

---

### Astuce 5 : Tester avant de déployer

```bash
# Activer le debug temporairement
debug ip nat detailed

# Tester une connexion spécifique
telnet <destination> <port>

# Vérifier la traduction
show ip nat translations | include <internal-ip>

# Désactiver le debug
no debug all
```

> [!warning] Debug en production Le `debug ip nat` est très verbeux ! Ne l'activez que brièvement et en dehors des heures de pointe.

---

## 🎓 Résumé décisionnel

**Utilisez Static NAT si :**

- Vous hébergez des services accessibles publiquement
- La traçabilité stricte est requise
- Le budget IPs publiques n'est pas une contrainte

**Utilisez Dynamic NAT si :**

- Vous avez un pool d'IPs publiques disponible
- Le trafic est principalement sortant
- Vous ne pouvez pas utiliser PAT pour des raisons de compatibilité

**Utilisez PAT si :**

- Vous devez maximiser l'économie d'IPs publiques
- Le trafic est essentiellement sortant (navigation, email)
- La scalabilité est prioritaire
- Vous acceptez l'incompatibilité native avec certains protocoles

> [!tip] Recommandation générale Dans 90% des cas, **PAT** est le choix optimal pour les utilisateurs finaux, complété par **Static NAT** pour les quelques serveurs nécessitant un accès public.