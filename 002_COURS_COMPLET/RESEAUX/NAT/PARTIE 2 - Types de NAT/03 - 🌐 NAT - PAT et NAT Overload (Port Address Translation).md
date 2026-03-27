

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

## 🎯 Introduction au PAT

Le **PAT (Port Address Translation)**, également appelé **NAT Overload**, est la forme de NAT la plus utilisée dans le monde. C'est celle que vous utilisez probablement chez vous et dans la plupart des entreprises.

> [!info] Définition Le PAT permet de traduire **plusieurs adresses IP privées** en **une seule adresse IP publique** en utilisant des **numéros de ports différents** pour distinguer chaque connexion.

### Pourquoi PAT plutôt que NAT statique ou dynamique ?

Le PAT résout un problème majeur : **la pénurie d'adresses IPv4 publiques**. Avec le PAT, des milliers d'utilisateurs peuvent partager une seule IP publique, ce qui optimise considérablement l'utilisation des ressources.

**Comparaison rapide :**

|Type de NAT|Ratio IP privée/publique|Usage typique|
|---|---|---|
|Statique|1:1|Serveurs accessibles depuis Internet|
|Dynamique|N:M (pool)|Entreprises avec plusieurs IP publiques|
|PAT/Overload|N:1|Accès Internet pour utilisateurs finaux|

---

## ⚙️ Principe de fonctionnement

Le PAT fonctionne en ajoutant une couche supplémentaire d'identification : **les ports TCP/UDP**.

### Mécanisme détaillé

Lorsqu'un paquet sort du réseau privé :

1. **Le routeur examine** l'adresse source privée et le port source
2. **Il traduit** l'adresse IP source privée en l'adresse IP publique
3. **Il modifie** le port source par un port unique (si nécessaire)
4. **Il enregistre** cette correspondance dans sa **table NAT**
5. **Il envoie** le paquet avec la nouvelle adresse et le nouveau port

Lorsqu'une réponse revient :

1. **Le routeur examine** l'adresse destination (IP publique) et le port destination
2. **Il consulte** sa table NAT pour trouver la correspondance
3. **Il traduit** l'IP publique en IP privée et le port vers le port original
4. **Il transmet** le paquet au bon hôte interne

> [!example] Exemple concret **Situation :** Deux ordinateurs (192.168.1.10 et 192.168.1.20) visitent www.google.com
> 
> |Étape|PC1 (192.168.1.10)|PC2 (192.168.1.20)|Routeur (IP publique: 203.0.113.5)|
> |---|---|---|---|
> |Paquet sortant|192.168.1.10:49152 → 142.250.185.46:80|192.168.1.20:49153 → 142.250.185.46:80|Traduit en 203.0.113.5:1024 et 203.0.113.5:1025|
> |Paquet entrant|← 203.0.113.5:1024|← 203.0.113.5:1025|Retraduit vers les IP privées respectives|

---

## 🔌 Multiplexage par ports

Le cœur du PAT réside dans le **multiplexage par ports**. C'est ce qui permet de partager une seule IP publique entre de nombreux utilisateurs.

### Comment fonctionnent les ports dans le PAT ?

> [!info] Rappel sur les ports Les ports TCP et UDP sont des nombres de 16 bits, allant de **0 à 65535**. Ils permettent de distinguer différentes connexions sur une même machine.

#### Plages de ports

|Plage|Nom|Usage|
|---|---|---|
|0-1023|Ports bien connus|Services système (HTTP:80, HTTPS:443, SSH:22)|
|1024-49151|Ports enregistrés|Applications enregistrées auprès de l'IANA|
|49152-65535|Ports dynamiques/éphémères|Attribués dynamiquement par le système|

**Le PAT utilise principalement les ports dynamiques** (49152-65535) pour créer des traductions uniques.

### Table de traduction PAT

Le routeur maintient une **table de traduction** qui associe :

```
[IP privée : Port source] ↔ [IP publique : Port traduit] ↔ [IP destination : Port destination]
```

> [!example] Table NAT en action
> 
> ```
> Inside Local          Inside Global         Outside Global
> 192.168.1.10:49152 ↔  203.0.113.5:1024  ↔  142.250.185.46:80
> 192.168.1.10:49153 ↔  203.0.113.5:1025  ↔  172.217.16.14:443
> 192.168.1.20:49152 ↔  203.0.113.5:1026  ↔  142.250.185.46:80
> 192.168.1.30:49154 ↔  203.0.113.5:1027  ↔  93.184.216.34:80
> ```
> 
> **Observation :** Même si PC1 et PC2 utilisent le même port source (49152), le routeur leur attribue des ports traduits différents (1024 et 1026).

### Limites théoriques

Avec une seule IP publique, le nombre maximum de connexions simultanées est limité par :

- **Nombre de ports disponibles :** ~64 000 (65535 - 1024)
- **En pratique :** Dépend aussi de la mémoire du routeur et des timeouts de connexion

> [!tip] Astuce Les connexions TCP ont généralement un timeout de quelques minutes après fermeture, tandis que les connexions UDP peuvent expirer plus rapidement (30-60 secondes d'inactivité).

---

## 💼 Cas d'usage le plus courant

Le PAT est **partout**. C'est le type de NAT par défaut dans la grande majorité des déploiements.

### Scénarios typiques

#### 1. Box Internet domestique / Routeur SOHO

**Contexte :** Une famille avec plusieurs appareils (smartphones, ordinateurs, TV connectée, IoT) partageant une seule connexion Internet.

```
[Tous les appareils] → [Box Internet avec PAT] → [Internet]
    192.168.1.x              203.0.113.5             
```

> [!info] Pourquoi PAT ici ?
> 
> - Une seule IP publique fournie par le FAI
> - Plusieurs appareils doivent accéder simultanément à Internet
> - Économique et simple à gérer

#### 2. Entreprise PME

**Contexte :** 50-200 employés accédant à Internet via une ou quelques IP publiques.

```
[Réseau interne 10.0.0.0/8] → [Routeur avec PAT] → [Internet]
                                 198.51.100.10
```

**Avantages :**

- Économie d'adresses IP publiques
- Sécurité par obscurcissement (les IP internes ne sont pas exposées)
- Gestion centralisée des accès

#### 3. Datacenter / Cloud provider

**Contexte :** Des milliers de machines virtuelles dans un réseau privé accédant à Internet pour des mises à jour, téléchargements, etc.

```
[Instances VM 172.16.0.0/12] → [NAT Gateway avec PAT] → [Internet]
                                  IP publique élastique
```

> [!tip] Bonne pratique Cloud Dans AWS, Azure, GCP, on utilise des **NAT Gateways** ou **NAT Instances** qui implémentent du PAT pour permettre aux ressources privées d'accéder à Internet sans être directement exposées.

### Comparaison avec les autres types de NAT

|Scénario|NAT Statique|NAT Dynamique|PAT|
|---|---|---|---|
|Accès Internet général|❌ Trop coûteux|⚠️ Possible mais limité|✅ Idéal|
|Héberger un serveur web|✅ Recommandé|❌ Inadapté|⚠️ Possible avec port forwarding|
|Économie d'IP publiques|❌ Aucune|⚠️ Moyenne|✅ Maximum|
|Nombre d'utilisateurs simultanés|Très limité|Limité par le pool|Très élevé|

---

## 🛠️ Configuration détaillée

### Configuration Cisco IOS

> [!warning] Prérequis
> 
> - Interface interne (LAN) configurée
> - Interface externe (WAN) configurée avec IP publique
> - Routage fonctionnel

#### Étape 1 : Définir les interfaces Inside et Outside

```bash
Router(config)# interface GigabitEthernet0/0
Router(config-if)# description Interface LAN (Inside)
Router(config-if)# ip address 192.168.1.1 255.255.255.0
Router(config-if)# ip nat inside  # Désigne cette interface comme "inside"
Router(config-if)# no shutdown
Router(config-if)# exit

Router(config)# interface GigabitEthernet0/1
Router(config-if)# description Interface WAN (Outside)
Router(config-if)# ip address 203.0.113.5 255.255.255.252
Router(config-if)# ip nat outside  # Désigne cette interface comme "outside"
Router(config-if)# no shutdown
Router(config-if)# exit
```

#### Étape 2 : Créer une ACL pour identifier le trafic à traduire

```bash
# Méthode avec ACL standard numérotée
Router(config)# access-list 1 permit 192.168.1.0 0.0.0.255
# Autorise tout le réseau 192.168.1.0/24 à être traduit

# OU avec ACL nommée (plus lisible)
Router(config)# ip access-list standard NAT_INSIDE
Router(config-std-nacl)# permit 192.168.1.0 0.0.0.255
Router(config-std-nacl)# exit
```

> [!tip] Bonnes pratiques ACL
> 
> - Utilisez des ACL nommées pour une meilleure lisibilité
> - Documentez avec des descriptions
> - Soyez aussi spécifique que possible pour éviter de traduire du trafic non désiré

#### Étape 3 : Configurer le PAT (NAT Overload)

```bash
# Utiliser l'IP de l'interface Outside
Router(config)# ip nat inside source list 1 interface GigabitEthernet0/1 overload
# "overload" active le PAT (multiplexage par ports)

# OU avec ACL nommée
Router(config)# ip nat inside source list NAT_INSIDE interface GigabitEthernet0/1 overload
```

**Syntaxe décortiquée :**

- `ip nat inside source` : Traduit les adresses source qui viennent de l'inside
- `list 1` ou `list NAT_INSIDE` : Utilise l'ACL 1 ou NAT_INSIDE pour identifier quelles IP traduire
- `interface GigabitEthernet0/1` : Utilise l'IP de cette interface comme IP publique
- `overload` : Active le PAT (sans ce mot-clé, ce serait du NAT dynamique simple)

#### Étape 4 : Vérification de la configuration

```bash
# Afficher la configuration NAT
Router# show ip nat translations

# Exemple de sortie :
# Pro Inside global      Inside local       Outside local      Outside global
# tcp 203.0.113.5:1024  192.168.1.10:49152  142.250.185.46:80  142.250.185.46:80
# tcp 203.0.113.5:1025  192.168.1.10:49153  172.217.16.14:443  172.217.16.14:443
# tcp 203.0.113.5:1026  192.168.1.20:49152  142.250.185.46:80  142.250.185.46:80

# Afficher les statistiques NAT
Router# show ip nat statistics

# Nettoyer les traductions (utile pour le dépannage)
Router# clear ip nat translation *
```

> [!info] Lecture de la table de traductions
> 
> - **Inside local :** IP et port de la machine sur le réseau interne
> - **Inside global :** IP et port après traduction (ce que voit Internet)
> - **Outside local :** IP et port du serveur distant (généralement identique à Outside global)
> - **Outside global :** IP et port du serveur distant tel que vu depuis l'extérieur

### Configuration alternative : PAT avec pool d'adresses

Si vous disposez de plusieurs IP publiques mais souhaitez quand même du PAT :

```bash
# Créer un pool d'IP publiques
Router(config)# ip nat pool PUBLIC_POOL 203.0.113.5 203.0.113.10 netmask 255.255.255.248

# Configurer PAT avec le pool
Router(config)# ip nat inside source list 1 pool PUBLIC_POOL overload
```

**Avantage :** Si une IP publique atteint sa limite de ports, le routeur bascule sur la suivante.

---

## ⚠️ Pièges courants et bonnes pratiques

### Pièges fréquents

> [!warning] Piège #1 : Oubli du mot-clé "overload" **Symptôme :** Le NAT fonctionne pour un seul utilisateur, puis plus rien.
> 
> **Cause :** Sans `overload`, c'est du NAT dynamique 1:1, donc une seule machine peut utiliser l'IP publique à la fois.
> 
> **Solution :** Toujours ajouter `overload` dans la commande `ip nat inside source`.

> [!warning] Piège #2 : ACL trop permissive ou incorrecte **Symptôme :** Du trafic non désiré est traduit, ou au contraire rien ne fonctionne.
> 
> **Cause :** ACL mal configurée (mauvais masque wildcard, mauvais réseau).
> 
> **Solution :**
> 
> ```bash
> # Vérifier l'ACL
> Router# show access-lists
> 
> # S'assurer que le masque wildcard est correct
> # Pour un /24 : 0.0.0.255
> # Pour un /16 : 0.0.255.255
> ```

> [!warning] Piège #3 : Oubli de désigner les interfaces inside/outside **Symptôme :** Le NAT ne fonctionne pas du tout.
> 
> **Cause :** Sans `ip nat inside` et `ip nat outside`, le routeur ne sait pas où appliquer le NAT.
> 
> **Solution :** Vérifier avec `show ip interface` que les interfaces sont correctement marquées.

> [!warning] Piège #4 : Saturation de la table NAT **Symptôme :** Nouvelles connexions impossibles même si des ports sont théoriquement disponibles.
> 
> **Cause :** La table NAT a atteint sa limite (mémoire du routeur).
> 
> **Solution :**
> 
> ```bash
> # Réduire les timeouts
> Router(config)# ip nat translation timeout 60  # 60 secondes au lieu de 86400 par défaut
> Router(config)# ip nat translation tcp-timeout 300
> Router(config)# ip nat translation udp-timeout 60
> ```

### Bonnes pratiques

> [!tip] ✅ Documenter vos ACLs
> 
> ```bash
> Router(config)# ip access-list standard NAT_INSIDE
> Router(config-std-nacl)# remark === ACL pour NAT - Reseau interne ===
> Router(config-std-nacl)# permit 192.168.1.0 0.0.0.255
> ```

> [!tip] ✅ Monitorer les traductions actives Mettez en place un monitoring régulier :
> 
> ```bash
> # Compter les traductions actives
> Router# show ip nat statistics | include translations
> 
> # Surveiller les top talkers
> Router# show ip nat translations verbose
> ```

> [!tip] ✅ Planifier la capacité **Règle empirique :** Prévoir ~100 connexions simultanées par utilisateur actif (navigateurs modernes ouvrent de nombreuses connexions parallèles).
> 
> **Exemple :** 50 utilisateurs = ~5000 connexions potentielles. Vérifiez que votre routeur peut gérer cette charge.

> [!tip] ✅ Logging sélectif Pour le dépannage, activez le logging temporairement :
> 
> ```bash
> Router(config)# ip nat log translations syslog
> ```
> 
> ⚠️ **Attention :** Génère beaucoup de logs, à désactiver après dépannage.

> [!tip] ✅ Utiliser des pools pour la haute disponibilité Si vous avez plusieurs IP publiques, utilisez un pool avec PAT pour éviter la saturation d'une seule IP.

### Sécurité et PAT

> [!info] Le PAT améliore-t-il la sécurité ? **Oui, indirectement :**
> 
> - Les IP internes ne sont pas directement exposées sur Internet
> - Agit comme un firewall stateful basique (seules les connexions établies depuis l'intérieur peuvent recevoir des réponses)
> 
> **Mais ce n'est PAS un firewall complet :**
> 
> - N'inspecte pas le contenu des paquets
> - Ne protège pas contre les attaques applicatives
> - Doit être complété par un vrai firewall pour une sécurité robuste

---

## 🎓 Points clés à retenir

✅ **Le PAT est le type de NAT le plus utilisé** car il optimise l'utilisation des IP publiques

✅ **Le multiplexage par ports** permet de partager une IP publique entre des milliers d'utilisateurs

✅ **Toujours utiliser le mot-clé `overload`** pour activer le PAT dans la configuration

✅ **Surveiller la table NAT** et ajuster les timeouts selon les besoins

✅ **Le PAT améliore la sécurité** mais ne remplace pas un firewall complet

---

_Cours complet sur le PAT/NAT Overload - Prêt pour Obsidian_ 📚